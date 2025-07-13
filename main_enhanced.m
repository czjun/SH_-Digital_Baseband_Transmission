% main_enhanced.m
% 数字通信系统仿真主控脚本
% 包含：调制前后序列图、星座图、眼图、性能图、滚降系数分析、信道编码分析、调制方式分析

clear; clc; close all;

%% 参数设置
L = 1000;                    % 信源长度
SNR_range = 0:2:20;          % 信噪比范围（dB）
rolloff_factors = [0.1, 0.3, 0.5, 0.7]; % 升余弦滚降系数
modulation_types = {'BPSK', 'QPSK', '8PSK'}; % 支持的调制方式
coding_types = {'none', 'repeat', 'convolutional'}; % 支持的信道编码方式

%% 1. 调制前后序列图、星座图、眼图、性能图分析
fprintf('=== 开始系统仿真 ===\n');

% 生成信源（0/1比特流）
x = makingData(1, L);

% 信道编码（默认卷积编码）
x_encoded = channel_coding(x, 'convolutional', 2);

% QPSK调制
[modulated_signal, constellation] = modulation(x_encoded, 'QPSK', 4);

% 信号周期扩展（插值，便于后续滤波）
y = extrudeMultiples(real(modulated_signal), 20);

% 升余弦发送滤波
rolloff = 0.3;
hn = rcosdesign(rolloff, 6, 4, 'sqrt');
send1 = filterDeal(y, hn);

% 添加AWGN噪声
SNR = 10;
send2 = addNoise(SNR, send1, x);

% 接收滤波
send3 = filterDeal(send2, hn);

% 采样与判决
send4 = sample_AY(send3, 20);
send5 = judgeCode(1, send4);

% QPSK解调
rx_bits = demodulation(send5, 'QPSK');

% 卷积解码
decoded_bits = channel_decoding(rx_bits, 'convolutional', 2);

% 误码率计算
min_len = min(length(decoded_bits), length(x));
ber = errorRate(decoded_bits(1:min_len), x(1:min_len));

fprintf('当前误码率: %.2e\n', ber);

% 绘制调制前后序列图
figure(1);
subplot(4,1,1); stem(x(1:30)); title('原始信源序列'); ylabel('幅度');
subplot(4,1,2); stem(x_encoded(1:60)); title('编码后序列'); ylabel('幅度');
subplot(4,1,3); stem(real(modulated_signal(1:30))); title('调制后序列'); ylabel('幅度');
subplot(4,1,4); stem(hn); title('升余弦滤波器响应'); ylabel('幅度');

%% 2. 不同滚降系数对眼图和性能的影响
fprintf('\n=== 分析不同滚降系数的影响 ===\n');
figure(2);
for i = 1:length(rolloff_factors)
    rolloff = rolloff_factors(i);
    hn = rcosdesign(rolloff, 6, 4, 'sqrt');
    send_filtered = filterDeal(y, hn);
    send_noisy = addNoise(10, send_filtered, x);
    send_received = filterDeal(send_noisy, hn);
    send_sampled = sample_AY(send_received, 20);
    subplot(2,2,i);
    eyediagram(send_sampled, 4, 1, 0);
    title(sprintf('滚降系数 = %.1f', rolloff));
end

% 滚降系数对性能的影响
figure(3);
ber_rolloff = zeros(length(rolloff_factors), length(SNR_range));
for i = 1:length(rolloff_factors)
    rolloff = rolloff_factors(i);
    hn = rcosdesign(rolloff, 6, 4, 'sqrt');
    for j = 1:length(SNR_range)
        SNR = SNR_range(j);
        send_filtered = filterDeal(y, hn);
        send_noisy = addNoise(SNR, send_filtered, x);
        send_received = filterDeal(send_noisy, hn);
        send_sampled = sample_AY(send_received, 20);
        send_judged = judgeCode(1, send_sampled);
        demod_bits = demodulation(send_judged, 'QPSK');
        decoded_bits = channel_decoding(demod_bits, 'convolutional', 2);
        ber_rolloff(i,j) = errorRate(decoded_bits(1:length(x)), x);
        hold on;
    end
    subplot(1,1,1);
    semilogy(SNR_range, ber_rolloff(i,:), 'LineWidth', 2, 'DisplayName', sprintf('α=%.1f', rolloff));
end
grid on; xlabel('SNR (dB)'); ylabel('误码率 (BER)');
title('不同滚降系数的性能对比');
legend show; hold off;

%% 3. 信道编码前后性能对比
fprintf('\n=== 分析信道编码的影响 ===\n');
figure(4);
ber_coding = zeros(length(coding_types), length(SNR_range));
for i = 1:length(coding_types)
    coding_type = coding_types{i};
    for j = 1:length(SNR_range)
        SNR = SNR_range(j);
        x_encoded = channel_coding(x, coding_type, 2);
        [modulated_signal, ~] = modulation(x_encoded, 'BPSK', 2);
        y_coded = extrudeMultiples(real(modulated_signal), 20);
        hn = rcosdesign(0.3, 6, 4, 'sqrt');
        send_filtered = filterDeal(y_coded, hn);
        send_noisy = addNoise(SNR, send_filtered, x);
        send_received = filterDeal(send_noisy, hn);
        send_sampled = sample_AY(send_received, 20);
        send_judged = judgeCode(1, send_sampled);
        demod_bits = demodulation(send_judged, 'BPSK');
        decoded_bits = channel_decoding(demod_bits, coding_type, 2);
        ber_coding(i,j) = errorRate(decoded_bits(1:length(x)), x);
        hold on;
    end
    subplot(1,1,1);
    semilogy(SNR_range, ber_coding(i,:), 'LineWidth', 2, 'DisplayName', coding_type);
end
grid on; xlabel('SNR (dB)'); ylabel('误码率 (BER)');
title('信道编码前后性能对比');
legend show; hold off;

%% 4. 不同调制方式性能对比
fprintf('\n=== 分析不同调制方式的性能 ===\n');
figure(5);
ber_modulation = zeros(length(modulation_types), length(SNR_range));
for i = 1:length(modulation_types)
    mod_type = modulation_types{i};
    for j = 1:length(SNR_range)
        SNR = SNR_range(j);
        x_encoded = channel_coding(x, 'convolutional', 2);
        [modulated_signal, ~] = modulation(x_encoded, mod_type, 2^(i));
        y_mod = extrudeMultiples(real(modulated_signal), 20);
        hn = rcosdesign(0.3, 6, 4, 'sqrt');
        send_filtered = filterDeal(y_mod, hn);
        send_noisy = addNoise(SNR, send_filtered, x);
        send_received = filterDeal(send_noisy, hn);
        send_sampled = sample_AY(send_received, 20);
        send_judged = judgeCode(1, send_sampled);
        demod_bits = demodulation(send_judged, mod_type);
        decoded_bits = channel_decoding(demod_bits, 'convolutional', 2);
        ber_modulation(i,j) = errorRate(decoded_bits(1:length(x)), x);
        hold on;
    end
    subplot(1,1,1);
    semilogy(SNR_range, ber_modulation(i,:), 'LineWidth', 2, 'DisplayName', mod_type);
end
grid on; xlabel('SNR (dB)'); ylabel('误码率 (BER)');
title('不同调制方式性能对比');
legend show; hold off;

%% 5. 误码率目标分析
fprintf('\n=== 分析达到1×10^-5误码率要求 ===\n');
target_ber = 1e-5;
for i = 1:length(modulation_types)
    mod_type = modulation_types{i};
    target_snr_idx = find(ber_modulation(i,:) <= target_ber, 1);
    if ~isempty(target_snr_idx)
        target_snr = SNR_range(target_snr_idx);
        fprintf('%s调制在SNR = %.1f dB时达到目标误码率\n', mod_type, target_snr);
    else
        fprintf('%s调制在给定SNR范围内未达到目标误码率\n', mod_type);
    end
end

%% 综合性能分析
figure(6);
best_config_ber = min(ber_modulation, [], 1);
semilogy(SNR_range, best_config_ber, 'b-o', 'LineWidth', 2);
hold on;
yline(target_ber, 'r--', 'LineWidth', 2);
grid on;
xlabel('SNR (dB)'); ylabel('误码率 (BER)');
title('最佳配置性能曲线');
legend('最佳配置', '目标误码率');
hold off;

%% 绘制星座图和眼图
scatterplot(modulated_signal); title('发送星座图');
scatterplot(send5); title('接收星座图');
eyediagram(send4, 4, 1, 0); title('眼图');

fprintf('\n=== 仿真完成 ===\n');
fprintf('所有图形已生成，请查看结果\n'); 
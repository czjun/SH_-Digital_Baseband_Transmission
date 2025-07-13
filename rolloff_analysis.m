clear all; close all; clc;

fprintf('=== 滚降系数影响分析 ===\n');

%% 参数设置
L = 500;
SNR_range = 0:2:16;
rolloff_factors = [0.1, 0.3, 0.5, 0.7, 0.9];

%% 生成测试数据
x = makingData(1, L);
x_encoded = channel_coding(x, 'convolutional', 2);
[modulated_signal, ~] = modulation(x_encoded, 'QPSK', 4);
y = extrudeMultiples(real(modulated_signal), 20);

%% 分析不同滚降系数的影响
fprintf('分析不同滚降系数的性能...\n');

ber_rolloff = zeros(length(rolloff_factors), length(SNR_range));

for i = 1:length(rolloff_factors)
    rolloff = rolloff_factors(i);
    fprintf('处理滚降系数 α = %.1f...\n', rolloff);
    
    % 设计滤波器
    hn = rcosdesign(rolloff, 6, 4, 'sqrt');
    
    % 测试不同SNR下的性能
    for j = 1:length(SNR_range)
        SNR = SNR_range(j);
        
        % 发送滤波
        send_filtered = filterDeal(y, hn);
        
        % 添加噪声
        send_noisy = addNoise(SNR, send_filtered, x);
        
        % 接收滤波
        send_received = filterDeal(send_noisy, hn);
        
        % 采样和判决
        send_sampled = sample_AY(send_received, 20);
        send_judged = judgeCode(1, send_sampled);
        
        % 解调和解码
        demod_bits = demodulation(send_judged, 'QPSK');
        decoded_bits = channel_decoding(demod_bits, 'convolutional', 2);
        
        % 计算误码率
        ber_rolloff(i,j) = errorRate(decoded_bits(1:length(x)), x);
    end
end

%% 绘制性能对比图
figure(1);
colors = {'b-o', 'r-s', 'g-^', 'm-d', 'c-v'};
for i = 1:length(rolloff_factors)
    semilogy(SNR_range, ber_rolloff(i,:), colors{i}, 'LineWidth', 2, 'MarkerSize', 8);
    hold on;
end
grid on;
xlabel('SNR (dB)', 'FontSize', 12);
ylabel('误码率 (BER)', 'FontSize', 12);
title('不同滚降系数的性能对比', 'FontSize', 14);
legend_labels = cell(1, length(rolloff_factors));
for i = 1:length(rolloff_factors)
    legend_labels{i} = sprintf('α = %.1f', rolloff_factors(i));
end
legend(legend_labels, 'Location', 'southwest');
set(gca, 'FontSize', 11);

%% 绘制眼图对比
figure(2);
SNR_eye = 10; % 用于眼图的SNR
for i = 1:length(rolloff_factors)
    rolloff = rolloff_factors(i);
    hn = rcosdesign(rolloff, 6, 4, 'sqrt');
    
    send_filtered = filterDeal(y, hn);
    send_noisy = addNoise(SNR_eye, send_filtered, x);
    send_received = filterDeal(send_noisy, hn);
    send_sampled = sample_AY(send_received, 20);
    
    subplot(2,3,i);
    eyediagram(send_sampled, 4, 1, 0);
    title(sprintf('α = %.1f', rolloff));
end

%% 分析最佳滚降系数
fprintf('\n=== 滚降系数分析结果 ===\n');
target_ber = 1e-5;

for i = 1:length(rolloff_factors)
    rolloff = rolloff_factors(i);
    target_snr_idx = find(ber_rolloff(i,:) <= target_ber, 1);
    
    if ~isempty(target_snr_idx)
        target_snr = SNR_range(target_snr_idx);
        fprintf('滚降系数 α = %.1f: 在SNR = %.1f dB时达到目标误码率\n', rolloff, target_snr);
    else
        fprintf('滚降系数 α = %.1f: 在给定SNR范围内未达到目标误码率\n', rolloff);
    end
end

% 找到最佳滚降系数
[min_ber, best_idx] = min(ber_rolloff(:,end));
best_rolloff = rolloff_factors(best_idx);
fprintf('\n最佳滚降系数: α = %.1f (在SNR = %.1f dB时误码率 = %.2e)\n', ...
    best_rolloff, SNR_range(end), min_ber);

fprintf('\n=== 分析完成 ===\n'); 
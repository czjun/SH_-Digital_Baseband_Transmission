clear all; close all; clc;

fprintf('=== 调制方式性能对比分析 ===\n');

%% 参数设置
L = 500;
SNR_range = 0:2:20;
modulation_types = {'BPSK', 'QPSK', '8PSK'};
coding_types = {'none', 'convolutional'};

%% 生成测试数据
x = makingData(1, L);

%% 分析不同调制方式的性能
fprintf('分析不同调制方式的性能...\n');

ber_modulation = zeros(length(modulation_types), length(SNR_range));
ber_coding = zeros(length(coding_types), length(modulation_types), length(SNR_range));

for i = 1:length(modulation_types)
    mod_type = modulation_types{i};
    fprintf('处理调制方式: %s...\n', mod_type);
    
    for j = 1:length(SNR_range)
        SNR = SNR_range(j);
        
        % 无编码情况
        [modulated_signal, ~] = modulation(x, mod_type, 2^(i));
        y = extrudeMultiples(real(modulated_signal), 20);
        hn = rcosdesign(0.3, 6, 4, 'sqrt');
        send_filtered = filterDeal(y, hn);
        send_noisy = addNoise(SNR, send_filtered, x);
        send_received = filterDeal(send_noisy, hn);
        send_sampled = sample_AY(send_received, 20);
        send_judged = judgeCode(1, send_sampled);
        demod_bits = demodulation(send_judged, mod_type);
        ber_modulation(i,j) = errorRate(demod_bits(1:length(x)), x);
        
        % 有编码情况
        x_encoded = channel_coding(x, 'convolutional', 2);
        [modulated_signal_coded, ~] = modulation(x_encoded, mod_type, 2^(i));
        y_coded = extrudeMultiples(real(modulated_signal_coded), 20);
        send_filtered_coded = filterDeal(y_coded, hn);
        send_noisy_coded = addNoise(SNR, send_filtered_coded, x);
        send_received_coded = filterDeal(send_noisy_coded, hn);
        send_sampled_coded = sample_AY(send_received_coded, 20);
        send_judged_coded = judgeCode(1, send_sampled_coded);
        demod_bits_coded = demodulation(send_judged_coded, mod_type);
        decoded_bits_coded = channel_decoding(demod_bits_coded, 'convolutional', 2);
        ber_coding(2,i,j) = errorRate(decoded_bits_coded(1:length(x)), x);
    end
end

%% 绘制性能对比图
figure(1);
colors = {'b-o', 'r-s', 'g-^'};
for i = 1:length(modulation_types)
    semilogy(SNR_range, ber_modulation(i,:), colors{i}, 'LineWidth', 2, 'MarkerSize', 8);
    hold on;
end
grid on;
xlabel('SNR (dB)', 'FontSize', 12);
ylabel('误码率 (BER)', 'FontSize', 12);
title('不同调制方式性能对比（无编码）', 'FontSize', 14);
legend(modulation_types, 'Location', 'southwest');
set(gca, 'FontSize', 11);

%% 绘制编码前后对比
figure(2);
for i = 1:length(modulation_types)
    subplot(1,3,i);
    semilogy(SNR_range, ber_modulation(i,:), 'b-o', 'LineWidth', 2);
    hold on;
    semilogy(SNR_range, ber_coding(2,i,:), 'r-s', 'LineWidth', 2);
    grid on;
    xlabel('SNR (dB)');
    ylabel('误码率 (BER)');
    title(sprintf('%s调制', modulation_types{i}));
    legend('无编码', '卷积编码');
end

%% 绘制星座图对比
figure(3);
SNR_constellation = 15;
for i = 1:length(modulation_types)
    mod_type = modulation_types{i};
    [modulated_signal, constellation] = modulation(x, mod_type, 2^(i));
    
    subplot(1,3,i);
    scatterplot(modulated_signal);
    title(sprintf('%s星座图', mod_type));
end

%% 分析达到目标误码率的要求
fprintf('\n=== 目标误码率分析 ===\n');
target_ber = 1e-5;

for i = 1:length(modulation_types)
    mod_type = modulation_types{i};
    
    % 无编码情况
    target_snr_idx = find(ber_modulation(i,:) <= target_ber, 1);
    if ~isempty(target_snr_idx)
        target_snr = SNR_range(target_snr_idx);
        fprintf('%s调制（无编码）: 在SNR = %.1f dB时达到目标误码率\n', mod_type, target_snr);
    else
        fprintf('%s调制（无编码）: 在给定SNR范围内未达到目标误码率\n', mod_type);
    end
    
    % 有编码情况
    target_snr_idx_coded = find(ber_coding(2,i,:) <= target_ber, 1);
    if ~isempty(target_snr_idx_coded)
        target_snr_coded = SNR_range(target_snr_idx_coded);
        fprintf('%s调制（卷积编码）: 在SNR = %.1f dB时达到目标误码率\n', mod_type, target_snr_coded);
    else
        fprintf('%s调制（卷积编码）: 在给定SNR范围内未达到目标误码率\n', mod_type);
    end
end

%% 计算编码增益
fprintf('\n=== 编码增益分析 ===\n');
for i = 1:length(modulation_types)
    mod_type = modulation_types{i};
    
    % 找到无编码和有编码达到相同误码率的SNR差异
    for ber_target = [1e-3, 1e-4, 1e-5]
        idx_no_coding = find(ber_modulation(i,:) <= ber_target, 1);
        idx_coding = find(ber_coding(2,i,:) <= ber_target, 1);
        
        if ~isempty(idx_no_coding) && ~isempty(idx_coding)
            snr_no_coding = SNR_range(idx_no_coding);
            snr_coding = SNR_range(idx_coding);
            coding_gain = snr_no_coding - snr_coding;
            fprintf('%s调制在BER=%.1e时的编码增益: %.1f dB\n', mod_type, ber_target, coding_gain);
        end
    end
end

%% 综合性能分析
figure(4);
% 绘制最佳配置的性能曲线
best_ber = min(ber_coding(2,:,:), [], 2);
best_ber = squeeze(best_ber);
semilogy(SNR_range, best_ber, 'b-o', 'LineWidth', 2);
hold on;
yline(target_ber, 'r--', 'LineWidth', 2);
grid on;
xlabel('SNR (dB)');
ylabel('误码率 (BER)');
title('最佳配置性能曲线');
legend('最佳配置', '目标误码率');

fprintf('\n=== 分析完成 ===\n'); 
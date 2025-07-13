clear all; close all; clc;

fprintf('=== 简化测试程序 ===\n');

%% 基本参数
L = 50;  % 很短的序列用于测试
SNR = 15;

%% 测试1: 信源生成
fprintf('测试1: 信源生成...\n');
x = makingData(1, L);
fprintf('信源长度: %d\n', length(x));

%% 测试2: 调制
fprintf('\n测试2: 调制...\n');
[modulated_signal, ~] = modulation(x, 'BPSK', 2);
fprintf('调制后符号数: %d\n', length(modulated_signal));

%% 测试3: 信号处理
fprintf('\n测试3: 信号处理...\n');
y = extrudeMultiples(real(modulated_signal), 10);
hn = rcosdesign(0.3, 6, 4, 'sqrt');
send1 = filterDeal(y, hn);
send2 = addNoise(SNR, send1, x);
send3 = filterDeal(send2, hn);

%% 测试4: 解调
fprintf('\n测试4: 解调...\n');
send4 = sample_AY(send3, 10);
send5 = judgeCode(1, send4);
demod_bits = demodulation(send5, 'BPSK');

%% 测试5: 误码率计算
fprintf('\n测试5: 误码率计算...\n');
min_len = min(length(demod_bits), length(x));
ber = errorRate(demod_bits(1:min_len), x(1:min_len));
fprintf('误码率: %.2e\n', ber);

%% 绘制结果
figure(1);
subplot(2,1,1); stem(x(1:20)); title('原始信源'); ylabel('幅度');
subplot(2,1,2); stem(demod_bits(1:min(20,length(demod_bits)))); title('解调后信号'); ylabel('幅度');

figure(2);
scatterplot(modulated_signal);
title('BPSK星座图');

fprintf('\n=== 简化测试完成 ===\n'); 
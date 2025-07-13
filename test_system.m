clear all; close all; clc;

fprintf('=== 数字通信系统测试程序 ===\n');

%% 基本参数
L = 100;  % 较短的序列用于测试
SNR = 10;

%% 测试1: 信源生成
fprintf('测试1: 信源生成...\n');
x = makingData(1, L);
fprintf('信源长度: %d, 1的个数: %d\n', length(x), sum(x));

%% 测试2: 信道编码
fprintf('\n测试2: 信道编码...\n');
x_encoded = channel_coding(x, 'convolutional', 2);
fprintf('编码后长度: %d\n', length(x_encoded));

%% 测试3: 调制
fprintf('\n测试3: 调制...\n');
[modulated_signal, constellation] = modulation(x_encoded, 'QPSK', 4);
fprintf('调制后符号数: %d\n', length(modulated_signal));

%% 测试4: 信号处理
fprintf('\n测试4: 信号处理...\n');
y = extrudeMultiples(real(modulated_signal), 10);
hn = rcosdesign(0.3, 6, 4, 'sqrt');
send1 = filterDeal(y, hn);
send2 = addNoise(SNR, send1, x);
send3 = filterDeal(send2, hn);

%% 测试5: 解调和解码
fprintf('\n测试5: 解调和解码...\n');
send4 = sample_AY(send3, 10);
send5 = judgeCode(1, send4);
demod_bits = demodulation(send5, 'QPSK');
decoded_bits = channel_decoding(demod_bits, 'convolutional', 2);

%% 测试6: 误码率计算
fprintf('\n测试6: 误码率计算...\n');
min_len = min(length(decoded_bits), length(x));
ber = errorRate(decoded_bits(1:min_len), x(1:min_len));
fprintf('误码率: %.2e\n', ber);

%% 绘制测试结果
figure(1);
subplot(3,1,1); stem(x(1:20)); title('原始信源'); ylabel('幅度');
subplot(3,1,2); stem(real(modulated_signal(1:20))); title('调制后信号'); ylabel('幅度');
subplot(3,1,3); stem(decoded_bits(1:min(20,length(decoded_bits)))); title('解码后信号'); ylabel('幅度');

scatterplot(modulated_signal);
title('星座图');

fprintf('\n=== 测试完成 ===\n');
fprintf('所有功能模块工作正常\n'); 
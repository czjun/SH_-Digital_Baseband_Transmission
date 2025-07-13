function [modulated_signal, constellation] = modulation(input_bits, mod_type, M)
% 调制函数
% input_bits: 输入比特流
% mod_type: 调制类型 ('BPSK', 'QPSK', '8PSK')
% M: 调制阶数
% modulated_signal: 调制后的信号
% constellation: 星座图数据

switch mod_type
    case 'BPSK'
        % BPSK调制
        modulated_signal = 2 * input_bits - 1; % 0->-1, 1->1
        constellation = [-1, 1];
        
    case 'QPSK'
        % QPSK调制
        if mod(length(input_bits), 2) ~= 0
            input_bits = [input_bits, 0]; % 补齐偶数位
        end
        
        % 将比特流分成I和Q两路
        I_bits = input_bits(1:2:end);
        Q_bits = input_bits(2:2:end);
        
        % 映射到星座点
        I_symbols = 2 * I_bits - 1;
        Q_symbols = 2 * Q_bits - 1;
        
        % 组合成复数信号
        modulated_signal = I_symbols + 1j * Q_symbols;
        constellation = [-1-1j, -1+1j, 1-1j, 1+1j];
        
    case '8PSK'
        % 8PSK调制（格雷映射）
        if mod(length(input_bits), 3) ~= 0
            % 补齐到3的倍数
            padding = 3 - mod(length(input_bits), 3);
            input_bits = [input_bits, zeros(1, padding)];
        end
        
        % 格雷映射表
        gray_map = [0, 1, 3, 2, 6, 7, 5, 4]; % 格雷码映射
        
        modulated_signal = [];
        for i = 1:3:length(input_bits)
            % 取3位比特
            bits = input_bits(i:i+2);
            % 转换为十进制
            symbol_idx = bits(1) * 4 + bits(2) * 2 + bits(3) + 1;
            % 格雷映射
            gray_symbol = gray_map(symbol_idx);
            % 转换为相位
            phase = gray_symbol * pi / 4;
            % 生成复数信号
            modulated_signal = [modulated_signal, exp(1j * phase)];
        end
        
        % 星座图
        angles = (0:7) * pi / 4;
        constellation = exp(1j * angles);
        
    otherwise
        error('不支持的调制类型');
end
end 
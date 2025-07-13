function output_bits = demodulation(received_signal, mod_type)
% 解调函数
% received_signal: 接收到的信号
% mod_type: 调制类型 ('BPSK', 'QPSK', '8PSK')
% output_bits: 解调后的比特流

switch mod_type
    case 'BPSK'
        % BPSK解调
        output_bits = (real(received_signal) > 0);
        
    case 'QPSK'
        % QPSK解调
        I_bits = (real(received_signal) > 0);
        Q_bits = (imag(received_signal) > 0);
        
        % 交错合并I和Q比特
        output_bits = zeros(1, 2*length(received_signal));
        output_bits(1:2:end) = I_bits;
        output_bits(2:2:end) = Q_bits;
        
    case '8PSK'
        % 8PSK解调（格雷映射）
        % 格雷映射表
        gray_map = [0, 1, 3, 2, 6, 7, 5, 4];
        
        output_bits = [];
        for i = 1:length(received_signal)
            % 计算相位
            phase = angle(received_signal(i));
            if phase < 0
                phase = phase + 2*pi;
            end
            
            % 量化到最近的星座点
            symbol_idx = round(phase / (pi/4)) + 1;
            if symbol_idx > 8
                symbol_idx = 1;
            end
            
            % 格雷解码
            gray_symbol = symbol_idx - 1;
            % 格雷码到二进制转换
            binary = gray_to_binary(gray_symbol);
            
            % 转换为3位比特
            bits = zeros(1, 3);
            bits(1) = floor(binary / 4);
            bits(2) = floor((binary - bits(1)*4) / 2);
            bits(3) = binary - bits(1)*4 - bits(2)*2;
            
            output_bits = [output_bits, bits];
        end
        
    otherwise
        error('不支持的调制类型');
end
end

function binary = gray_to_binary(gray)
% 格雷码到二进制转换
binary = gray;
mask = floor(binary / 2);
while mask ~= 0
    binary = bitxor(binary, mask);
    mask = floor(mask / 2);
end
end 
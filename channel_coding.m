function encoded_bits = channel_coding(input_bits, coding_type, rate)
% 信道编码函数
% input_bits: 输入比特流
% coding_type: 编码类型 ('none', 'repeat', 'convolutional')
% rate: 编码率
% encoded_bits: 编码后的比特流

switch coding_type
    case 'none'
        % 无编码
        encoded_bits = input_bits;
        
    case 'repeat'
        % 重复编码
        encoded_bits = [];
        for i = 1:length(input_bits)
            encoded_bits = [encoded_bits, repmat(input_bits(i), 1, rate)];
        end
        
    case 'convolutional'
        % 简单的卷积编码 (1/2 rate)
        % 生成多项式: G1 = [1 1 1], G2 = [1 0 1]
        constraint_length = 3;
        encoded_bits = [];
        
        % 初始化移位寄存器
        shift_reg = zeros(1, constraint_length);
        
        for i = 1:length(input_bits)
            % 更新移位寄存器
            shift_reg = [input_bits(i), shift_reg(1:end-1)];
            
            % 计算输出比特
            output1 = mod(sum(shift_reg), 2); % G1 = [1 1 1]
            output2 = mod(shift_reg(1) + shift_reg(3), 2); % G2 = [1 0 1]
            
            encoded_bits = [encoded_bits, output1, output2];
        end
        
    otherwise
        error('不支持的编码类型');
end
end 
function decoded_bits = channel_decoding(received_bits, coding_type, rate)
% 信道解码函数
% received_bits: 接收到的比特流
% coding_type: 编码类型 ('none', 'repeat', 'convolutional')
% rate: 编码率
% decoded_bits: 解码后的比特流

switch coding_type
    case 'none'
        % 无编码
        decoded_bits = received_bits;
        
    case 'repeat'
        % 重复解码（多数表决）
        decoded_bits = [];
        for i = 1:rate:length(received_bits)
            block = received_bits(i:i+rate-1);
            % 多数表决
            decoded_bits = [decoded_bits, (sum(block) > rate/2)];
        end
        
    case 'convolutional'
        % 简化的卷积解码（硬判决）
        % 由于维特比解码复杂，这里使用简化的方法
        decoded_bits = [];
        for i = 1:2:length(received_bits)
            if i+1 <= length(received_bits)
                % 简单的硬判决解码
                bit1 = received_bits(i);
                bit2 = received_bits(i+1);
                
                % 根据接收到的两个比特进行判决
                if bit1 == 1 && bit2 == 1
                    decoded_bits = [decoded_bits, 1];
                elseif bit1 == 0 && bit2 == 0
                    decoded_bits = [decoded_bits, 0];
                else
                    % 如果两个比特不同，选择第一个比特
                    decoded_bits = [decoded_bits, bit1];
                end
            end
        end
        
    otherwise
        error('不支持的编码类型');
end
end 
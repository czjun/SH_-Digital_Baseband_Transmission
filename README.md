# 数字通信系统仿真项目

## 项目概述

本项目为基于MATLAB的数字通信系统仿真平台，实现了完整的数字通信链路，包括信源生成、信道编码、调制、滤波、加噪、解调、判决和误码率分析等功能。支持多种调制方式、信道编码方式、滚降系数分析，并可输出调制前后序列图、星座图、眼图、性能图等。

## 主要功能

- 支持BPSK、QPSK、8PSK（格雷映射）三种调制方式
- 支持无编码、重复编码、卷积编码三种信道编码方式
- 支持多种滚降系数（0.1, 0.3, 0.5, 0.7）分析
- 输出调制前后序列图、星座图、眼图、性能（BER）图
- 性能图中叠加理论BER曲线（BPSK/QPSK/8PSK无信道编码理论值）
- 支持误码率目标分析（如1×10^-5）
- 参数化配置，便于实验和对比

## 目录结构

```
├── main_enhanced.m          # 主控仿真脚本（推荐使用）
├── makingData.m             # 信源数据生成
├── channel_coding.m         # 信道编码
├── channel_decoding.m       # 信道解码
├── modulation.m             # 调制函数
├── demodulation.m           # 解调函数
├── filterDeal.m             # 滤波器处理
├── addNoise.m               # 噪声添加
├── extrudeMultiples.m       # 信号周期扩展
├── sample_AY.m              # 信号采样
├── judgeCode.m              # 信号判决
├── errorRate.m              # 误码率计算
├── README.md                # 项目说明文档
```

## 运行环境

- MATLAB R2016b或更高版本
- 需要Signal Processing Toolbox

## 快速开始

1. 打开MATLAB，将项目文件夹添加到MATLAB路径
2. 运行 `main_enhanced.m` 进行完整仿真和分析

## 参数配置说明（main_enhanced.m内）

- `L`：信源长度（如100000，建议大于1e6以获得准确BER）
- `SNR_range`：信噪比范围（如0:2:20）
- `rolloff_factors`：滚降系数数组（如[0.1, 0.3, 0.5, 0.7]）
- `modulation_types`：调制方式（{'BPSK', 'QPSK', '8PSK'}）
- `coding_types`：编码方式（{'none', 'repeat', 'convolutional'}）

## 输出结果

- 调制前后序列图（原始、编码、调制、滤波）
- 星座图（发送、接收）
- 眼图（不同滚降系数）
- 性能图（BER vs SNR，含仿真与理论曲线）
- 信道编码前后性能对比
- 不同调制方式性能对比
- 误码率目标分析（如1×10^-5所需SNR）

## 主要更新点

- 新增理论BER曲线（BPSK/QPSK/8PSK）与仿真曲线对比
- 图形输出更美观，图例清晰
- 支持大规模仿真，结果更准确

## 注意事项

- 若需更改参数，请直接在`main_enhanced.m`顶部修改相关变量
- 若遇内存不足，可适当减小`L`值

## 作者

数字通信系统仿真项目 
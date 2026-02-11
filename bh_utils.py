import torch
import random
import numpy as np
import matplotlib.pyplot
import math

import os


os.environ["KMP_DUPLICATE_LIB_OK"] = "TRUE"


def layer_cut_generator(threshold, sg_width, learning_rate, verbose = False):
    # Parameters
    weight_exp = 0
    sg_width = sg_width / 1024
    scale_v = 2**(weight_exp)
    v_bit = 15 # 이건 별로 상관없음
    dw_bit = 8




    alpha = sg_width
    sg_bit = 4
    sg_temp_max = 1.0
    sg_temp_max -= 2 ** (-(sg_bit - 1))
    scale_sg_temp = 2 ** math.ceil(math.log2(sg_temp_max / (2 ** (sg_bit - 1) - 1)))

    # v = torch.arange(-2**v_bit, 2**v_bit + 1) * scale_v
    v = torch.arange((-2**v_bit)/0.25 +((2**(-weight_exp))*threshold), (2**v_bit + 1)/0.25 + ((2**(-weight_exp))*threshold) +1) * scale_v
    # v = torch.arange((-2**v_bit)/2 +((2**(-weight_exp))*threshold), (2**v_bit + 1)/2 + ((2**(-weight_exp))*threshold) +1) * scale_v

    # Surrogate gradient function
    def sg(v):
        sig = torch.sigmoid(alpha * v)
        sg_temp = 4.0 * sig * (1 - sig)  # smooth surrogate gradient (max 1.0)
        sg_temp *= sg_temp_max
        sg_temp_quantized = torch.clamp((sg_temp / scale_sg_temp).round(),
                                        -2 ** (sg_bit - 1) + 1, 2 ** (sg_bit - 1) - 1) * scale_sg_temp
        return sg_temp_quantized
    y = sg(v)


    # Find where y changes
    change_indices = torch.nonzero(y[1:] != y[:-1], as_tuple=False).squeeze() + 1
    x_change = v[change_indices] * (2**(-weight_exp)) + ((2**(-weight_exp))*threshold)  # shift by +512 
    y_change = y[change_indices]
    x_change_before_lr = x_change.clone()
    #설명약간
    assert len(x_change_before_lr) == 14, f"Error: Expected 14 change points before learning rate application, but got {len(change_indices)}."

    if verbose:
        # Plotting
        matplotlib.pyplot.figure(figsize=(14, 7))
        matplotlib.pyplot.plot(v * (2**(-weight_exp)) + ((2**(-weight_exp))*threshold), y, label='Quantized Surrogate Gradient', linewidth=2)
        matplotlib.pyplot.scatter(x_change, y_change, color='red', label='Change Points', s=40)

        # Annotate change points
        for x, y_val in zip(x_change, y_change):
            matplotlib.pyplot.text(x.item(), y_val.item() + 0.01, f'{x.item():.0f}',
                    fontsize=16, ha='center', rotation=0)

        matplotlib.pyplot.xlabel("membrane_potential", fontsize=35)
        matplotlib.pyplot.ylabel("Quantized Surrogate Gradient", fontsize=18)
        matplotlib.pyplot.title("3bit Quantized Surrogate Gradient ", fontsize=50)
        matplotlib.pyplot.grid(True)
        matplotlib.pyplot.legend(fontsize=16)
        matplotlib.pyplot.xticks(fontsize=16)
        matplotlib.pyplot.yticks(fontsize=50)
        matplotlib.pyplot.tight_layout()
        matplotlib.pyplot.show()

    # print(y,'hihi')
    # print(f'nonzero_y: {y[y != 0]} hihi')
    y = learning_rate * y  # Apply learning rate
    y = torch.clamp(torch.sign(y / scale_v) * torch.floor(torch.abs(y / scale_v) + 0.5), -2**(dw_bit-1) + 1, 2**(dw_bit-1) - 1) * scale_v

    # Find where y changes
    change_indices = torch.nonzero(y[1:] != y[:-1], as_tuple=False).squeeze() + 1
    x_change = v[change_indices] * (2**(-weight_exp)) + ((2**(-weight_exp))*threshold)  # shift by +512 

    x_change_after_lr = x_change.clone()
    #설명약간

    y_change = y[change_indices]
    if verbose:
        # Plotting
        matplotlib.pyplot.figure(figsize=(14, 7))
        matplotlib.pyplot.plot(v * (2**(-weight_exp)) + ((2**(-weight_exp))*threshold), y, label='Quantized Surrogate Gradient', linewidth=2)
        matplotlib.pyplot.scatter(x_change, y_change, color='red', label='Change Points', s=40)

        # Annotate change points
        for x, y_val in zip(x_change, y_change):
            matplotlib.pyplot.text(x.item(), y_val.item() , f'{x.item():.0f}',
                    fontsize=16, ha='center', rotation=0)

        matplotlib.pyplot.xlabel("membrane_potential", fontsize=35)
        matplotlib.pyplot.ylabel("Quantized Surrogate Gradient", fontsize=18)
        matplotlib.pyplot.title("3bit Quantized Surrogate Gradient ", fontsize=50)
        matplotlib.pyplot.grid(True)
        matplotlib.pyplot.legend(fontsize=16)
        matplotlib.pyplot.xticks(fontsize=16)
        matplotlib.pyplot.yticks(fontsize=16)
        matplotlib.pyplot.tight_layout()
        matplotlib.pyplot.show()
    
    if len(x_change_after_lr) == 14:
        pass
        x_change_after_lr_extension = x_change_after_lr.clone().tolist()
    elif len(x_change_after_lr) in [12, 10, 8, 6, 4, 2]:
        extension = 14 - len(x_change_after_lr)
        extension_start_index = len(x_change_after_lr)//2 - 1
        x_change_after_lr_extension = x_change_after_lr.clone()
        # x_change_after_lr_extension의 extension_start_index + 1 번째 자리에 x_change_after_lr[extension_start_index]를 extension만큼 채워넣어서 14개 만들기
        # 중간에 삽입할 값 (해당 인덱스의 값)
        padding_value = int(x_change_after_lr[extension_start_index])

        # 1. 슬라이싱을 이용한 방법 (깔끔함)
        x_change_after_lr_extension = (
            [int(x) for x in x_change_after_lr[:extension_start_index + 1]] +  # 앞부분
            [padding_value] * extension +                                      # 중간 채우기
            [int(x) for x in x_change_after_lr[extension_start_index + 1:]]    # 뒷부분
        )

        # 결과 확인
        if verbose:
            print(f"Original length: {len(x_change_after_lr)}")
            print(f"Extended length: {len(x_change_after_lr_extension)}")
            print(f"Result: {x_change_after_lr_extension}")
    else:
        assert False, f"Error: Unexpected number of change points after learning rate application. {len(x_change_after_lr)}"
    
    if verbose:
        print(f'x_change_before_lr: {x_change_before_lr}')
        print(f'x_change_after_lr: {x_change_after_lr}')
        print(f'x_change_after_lr_extension: {x_change_after_lr_extension}')

    final_output = [threshold] + x_change_after_lr_extension
    final_output = [int(x) for x in final_output]
    if verbose:
        print(f'final_output: {final_output}')
    return final_output



def quantize_tensor(tensor, bit=8, scale=1.0, zero_point=0):
    qmin, qmax = -2**(bit-1), 2**(bit-1) - 1
    q_x = torch.clamp((tensor / scale + zero_point).round(), qmin, qmax) * scale
    return q_x
def seed_assign(seed):
    random.seed(seed)                          # Python random 시드 고정
    np.random.seed(seed)                       # NumPy 시드 고정
    torch.manual_seed(seed) 
def weight_plot(w):
    w = w.view(-1).numpy()
    w_max = w.max()
    w_min = w.min()
    matplotlib.pyplot.figure()
    matplotlib.pyplot.hist(w, bins=256)
    # INT8 range
    matplotlib.pyplot.axvline(127, linestyle="--", label="INT8 max (127)")
    matplotlib.pyplot.axvline(-128, linestyle="--", label="INT8 min (-128)")
    # actual max/min
    matplotlib.pyplot.axvline(w_max, linestyle="-.", label=f"max = {w_max:.2f}")
    matplotlib.pyplot.axvline(w_min, linestyle="-.", label=f"min = {w_min:.2f}")
    matplotlib.pyplot.legend()
    matplotlib.pyplot.grid(True)
    matplotlib.pyplot.show()


def seed_assign(seed):
    random.seed(seed)                          # Python random 시드 고정
    np.random.seed(seed)                       # NumPy 시드 고정
    torch.manual_seed(seed) 
def quantize_tensor(tensor, bit=8, scale=1.0, zero_point=0):
    qmin, qmax = -2**(bit-1), 2**(bit-1) - 1
    q_x = torch.clamp((tensor / scale + zero_point).round(), qmin, qmax) * scale
    return q_x

def signed_encoding_32bit(value):
    return value & 0xFFFFFFFF
def signed_decoding_32bit(value):
    return value - 0x100000000 if value & 0x80000000 else value
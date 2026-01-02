# 원본 bitstream 경로
set src_bit "C:/Users/User/xem7310_750T_test1/xem7310_750T_test1.runs/impl_1/top_bh_fpga.bit"

# 목적지 경로
set dst_bit "C:/Users/User/measurement_setting/bitstream/top_bh_fpga.bit"

# bitstream 복사
file copy -force $src_bit $dst_bit

puts "Bitstream copied to $dst_bit"

from random import randrange
import random

valid_opcode = [
    '0000000',
    '1000000',
    '0000010',
    '0000101',
    '0001000',
    '0001001',
    '0001010',
    '0001011',
    '0100010',
    '0100101',
    '0101000',
    '0101001',
    '0101010',
    '1000010',
    '1000101',
    '0001100',
    '0001101',
    '0001110',
    '0010000',
    '0100000',
    '1110000',
    '1100101',
    '1100000',
    '1001000',
    '1101100',
    '0110000'
]
instruction = []

for i in range(0, 2048):
    opcode = random.choice(valid_opcode)
    dr = bin(randrange(32))
    dr = dr[2:].zfill(5)
    sa = bin(randrange(32))
    sa = sa[2:].zfill(5)
    sb = bin(randrange(8))
    sb = dr[2:].zfill(5)
    pending = bin(randrange(1024))
    pending = pending[2:].zfill(10)
    print(opcode + '_' + dr + '_' + sa + '_' + sb + '_' + pending)

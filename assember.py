import re

def D2B(x):
    distiny = 2
    B = []
    while True:
        s = x // distiny
        y = x % distiny
        B = B + [y]
        if s == 0 :
            break
        x = s
    B.reverse()
    BS = ''
    for i in B:
        BS = BS + str(i)
    return BS

def transform_op(operation, pe_id):
    addr_loop = '0'
    if(operation == 'loadA' and pe_id <= 7):
        opcode = '00'
    elif(operation == 'loadA' and pe_id > 7):
        opcode = '10'
    elif(operation == 'loadB' and pe_id <= 7):
        opcode = '00'
        addr_loop = '1'
    elif(operation == 'loadB' and pe_id > 7):
        opcode = '10'
        addr_loop = '1'
    elif(operation == 'storeA' and pe_id <= 7):
        opcode = '01'
    elif(operation == 'storeA' and pe_id > 7):
        opcode = '11'
    elif(operation == 'storeB' and pe_id <= 7):
        opcode = '01'
        addr_loop = '1'
    elif(operation == 'storeB' and pe_id > 7):
        opcode = '11'
        addr_loop = '1'
    elif operation == 'nop':
        opcode = '00000'
    elif operation == 'router':
        opcode = '00001'
    elif operation == 'add':
        opcode = '00010'
    elif operation == 'sub':
        opcode = '00011'
    elif operation == 'uadd':
        opcode = '00100'
    elif operation == 'usub':
        opcode = '00101'
    elif operation == 'and':
        opcode = '00110'
    elif operation == 'or':
        opcode = '00111'
    elif operation == 'xor':
        opcode = '01000'
    elif operation == 'not':
        opcode = '01001'
    elif operation == 'sel':
        opcode = '01010'
    elif operation == 'sll':
        opcode = '01011'
    elif operation == 'srl':
        opcode = '01100'
    elif operation == 'arl':
        opcode = '01101'
    elif operation == 'all':
        opcode = '01110'
    elif operation == 'clz':
        opcode = '01111'
    elif operation == 'mul':
        opcode = '10000'
    elif operation == 'mac':
        opcode = '10001'
    elif operation == 'umul':
        opcode = '10010'
    elif operation == 'umac':
        opcode = '10011'
    elif operation == 'mrl':
        opcode = '10100'
    elif operation == 'umrl':
        opcode = '10101'
    elif operation == 'equal':
        opcode = '10110'
    elif operation == 'div':
        opcode = '10111'
    elif operation == 'udiv':
        opcode = '11000'
    else:
        opcode = 'xxxxx'
    return opcode, addr_loop


def transform_index(pe_id, data_f):
    if pe_id == 0:
        if data_f == 'righ':
            index = '0000'
        elif data_f == 'di2r':
            index = '0001'
        elif data_f == 'di3r':
            index = '0010'
        elif(data_f == 'left' or data_f == 'rite'):
            index = '0011'
        elif data_f == 'down':
            index = '0100'
        elif data_f == 'di2c':
            index = '0101'
        elif data_f == 'di3c':
            index = '0110'
        elif(data_f == 'upup' or data_f == 'dote'):
            index = '0111'
        else:
            index = 'xxxx'
    elif pe_id == 7:
        if data_f == 'left':
            index = '0000'
        elif data_f == 'di2r':
            index = '0001'
        elif data_f == 'di3r':
            index = '0010'
        elif(data_f == 'righ' or data_f == 'lete'):
            index = '0011'
        elif data_f == 'down':
            index = '0100'
        elif data_f == 'di2c':
            index = '0101'
        elif data_f == 'di3c':
            index = '0110'
        elif(data_f == 'upup' or data_f == 'dote'):
            index = '0111'
        else:
            index = 'xxxx'
    elif pe_id == 56:
        if data_f == 'righ':
            index = '0000'
        elif data_f == 'di2r':
            index = '0001'
        elif data_f == 'di3r':
            index = '0010'
        elif(data_f == 'left' or data_f == 'rite'):
            index = '0011'
        elif data_f == 'upup':
            index = '0100'
        elif data_f == 'di2c':
            index = '0101'
        elif data_f == 'di3c':
            index = '0110'
        elif(data_f == 'down' or data_f == 'upte'):
            index = '0111'
        else:
            index = 'xxxx'
    elif pe_id == 63:
        if data_f == 'left':
            index = '0000'
        elif data_f == 'di2r':
            index = '0001'
        elif data_f == 'di3r':
            index = '0010'
        elif(data_f == 'righ' or data_f == 'lete'):
            index = '0011'
        elif data_f == 'upup':
            index = '0100'
        elif data_f == 'di2c':
            index = '0101'
        elif data_f == 'di3c':
            index = '0110'
        elif(data_f == 'down' or data_f == 'upte'):
            index = '0111'
        else:
            index = 'xxxx'
    elif(pe_id > 0 and pe_id < 7):
        if data_f == 'left':
            index = '0000'
        elif data_f == 'righ':
            index = '0001'
        elif data_f == 'lete':
            index = '0010'
        elif data_f == 'rite':
            index = '0011'
        elif data_f == 'down':
            index = '0100'
        elif data_f == 'di2c':
            index = '0101'
        elif data_f == 'di3c':
            index = '0110'
        elif(data_f == 'dote' or data_f == 'upup'):
            index = '0111'
        else:
            index = 'xxxx'
    elif(pe_id > 56 and pe_id < 63):
        if data_f == 'left':
            index = '0000'
        elif data_f == 'righ':
            index = '0001'
        elif data_f == 'lete':
            index = '0010'
        elif data_f == 'rite':
            index = '0011'
        elif data_f == 'upup':
            index = '0100'
        elif data_f == 'di2c':
            index = '0101'
        elif data_f == 'di3c':
            index = '0110'
        elif(data_f == 'upte' or data_f == 'down'):
            index = '0111'
        else:
            index = 'xxxx'
    elif((pe_id % 8) == 0 ):
        if data_f == 'upup':
            index = '0000'
        elif data_f == 'down':
            index = '0001'
        elif data_f == 'upte':
            index = '0010'
        elif data_f == 'dote':
            index = '0011'
        elif data_f == 'righ':
            index = '0100'
        elif data_f == 'di2r':
            index = '0101'
        elif data_f == 'di3r':
            index = '0110'
        elif(data_f == 'rite' or data_f == 'left'):
            index = '0111'
        else:
            index = 'xxxx'
    elif((pe_id % 8) == 7 ):
        if data_f == 'upup':
            index = '0000'
        elif data_f == 'down':
            index = '0001'
        elif data_f == 'upte':
            index = '0010'
        elif data_f == 'dote':
            index = '0011'
        elif data_f == 'left':
            index = '0100'
        elif data_f == 'di2r':
            index = '0101'
        elif data_f == 'di3r':
            index = '0110'
        elif(data_f == 'lete' or data_f == 'righ'):
            index = '0111'
        else:
            index = 'xxxx'
    elif((pe_id % 8) < 4 and pe_id < 32 ):
        if data_f == 'upup':
            index = '0000'
        elif data_f == 'down':
            index = '0001'
        elif data_f == 'left':
            index = '0010'
        elif data_f == 'righ':
            index = '0011'
        elif data_f == 'upte':
            index = '0100'
        elif data_f == 'dote':
            index = 'none'
        elif data_f == 'lete':
            index = '0110'
        elif data_f == 'rite':
            index = 'none'
        else:
            index = 'xxxx'
    elif((pe_id % 8) > 3 and pe_id < 32 ):
        if data_f == 'upup':
            index = '0000'
        elif data_f == 'down':
            index = '0001'
        elif data_f == 'left':
            index = '0010'
        elif data_f == 'righ':
            index = '0011'
        elif data_f == 'upte':
            index = '0100'
        elif data_f == 'dote':
            index = 'none'
        elif data_f == 'lete':
            index = 'none'
        elif data_f == 'rite':
            index = '0111'
        else:
            index = 'xxxx'
    elif((pe_id % 8) < 4 and pe_id > 31 ):
        if data_f == 'upup':
            index = '0000'
        elif data_f == 'down':
            index = '0001'
        elif data_f == 'left':
            index = '0010'
        elif data_f == 'righ':
            index = '0011'
        elif data_f == 'upte':
            index = 'none'
        elif data_f == 'dote':
            index = '0101'
        elif data_f == 'lete':
            index = '0110'
        elif data_f == 'rite':
            index = 'none'
        else:
            index = 'xxxx'
    elif((pe_id % 8) > 3 and pe_id > 31 ):
        if data_f == 'upup':
            index = '0000'
        elif data_f == 'down':
            index = '0001'
        elif data_f == 'left':
            index = '0010'
        elif data_f == 'righ':
            index = '0011'
        elif data_f == 'upte':
            index = 'none'
        elif data_f == 'dote':
            index = '0101'
        elif data_f == 'lete':
            index = 'none'
        elif data_f == 'rite':
            index = '0111'
        else:
            index = 'xxxx'
    return index

def transform_in(pe_id, data_from):
    Imm = '0'
    if data_from[0:2] == 'LR':
        bin = '000' + D2B(int(data_from[2:])).zfill(5)
    elif data_from[0:2] == 'GR':
        bin = '001' + D2B(int(data_from[2:])).zfill(5)
    elif data_from[0:2] == 'SM':
        bin = '100' + D2B(int(data_from[2:])).zfill(13)
    elif data_from[0:2] == 'IM':
        if data_from[2] == '-':
            bin = '1' + D2B(128 - int(data_from[3:])).zfill(7)
        else:
            bin = D2B(int(data_from[2:])).zfill(8)
        Imm = '1'
    elif(data_from[0:3] == 'PE0' and data_from[4:] != 'self'):
        if data_from[3] == 'A':
            bin = '0100' + transform_index(pe_id, data_from[4:])
        else:
            bin = '0101' + transform_index(pe_id, data_from[4:])
    elif((data_from[0:3] == 'PE0' or data_from[0:3] == 'PE1') and data_from[4:] == 'self'):
        if data_from[3] == 'A':
            if data_from[0:3] == 'PE0':
                bin = '01100000'
            else:
                bin = '01101000'
        else:
            if data_from[0:3] == 'PE0':
                bin = '01110000'
            else:
                bin = '01111000'
    elif(data_from[0:3] == 'PE1' and data_from[4:] != 'self'):
        if data_from[3] == 'A':
            bin = '1000' + transform_index(pe_id, data_from[4:])
        else:
            bin = '1001' + transform_index(pe_id, data_from[4:])
    elif data_from[0:3] == 'PE2':
        if data_from[4:] == 'self':
            if data_from[3] == 'A':
                bin = '000000'
            else:
                bin = '010000'
        else:
            if data_from[3] == 'A':
                bin = '10' + transform_index(pe_id, data_from[4:])
            else:
                bin = '11' + transform_index(pe_id, data_from[4:])


    else:
        bin = 'xxxxxxxx'
    return bin, Imm

def transform_out(data_to):
    if data_to[0:2] == 'LR':
        bin = '00' + D2B(int(data_to[2:])).zfill(5)
    elif data_to[0:2] == 'GR':
        bin = '01' + D2B(int(data_to[2:])).zfill(5)
    else:
        bin = '1000000'
    return bin

def transform_iteration(iteration, II):
    if II < 0:
        II = -II
        IItype = '1'
    else:
        IItype = '0'
    if II == 8:
        bin = '01' + D2B(iteration).zfill(5) + '000'
    elif II == 16:
        bin = '10' + D2B(iteration).zfill(5) + '000'
    else:
        bin = '00' + D2B(iteration).zfill(5) + D2B(II).zfill(3)
    return bin, IItype

def B2H(bin_in, length = 64):
    bin_in = bin_in.replace('_', '')
    hex = ''
    for i in range(int(length/4)):
        bin4 = bin_in[4*i:4*i+4]
        dec1 = int(bin4[0])*8 +int(bin4[1])*4 +int(bin4[2])*2 +int(bin4[3])*1
        if dec1 == 10:
            hex1 = 'a'
        elif dec1 == 11:
            hex1 = 'b'
        elif dec1 == 12:
            hex1 = 'c'
        elif dec1 == 13:
            hex1 = 'd'
        elif dec1 == 14:
            hex1 = 'e'
        elif dec1 == 15:
            hex1 = 'f'
        else:
            hex1 = str(dec1)
        hex = hex + hex1
    return hex






def main():
    with open("test.txt", "r") as f:
        allfile = []
        for line in f.readlines():
            if(line != '\n'):
                line = line.strip('\n')
                allfile.append(line)
    PES = []
    PE = []
    i = 0
    for fileline in allfile:
        if(fileline[0:2] == 'PE'):
            if(i != 0):
                PES.append(PE)
                PE = []
                PE.append(fileline)
                i = i + 1
            else:
                PE.append(fileline)
                i = 1
        else:
            PE.append(fileline)
    PES.append(PE)
    PES_bin = []
    for PE in PES:
        PE_bin = []
        top_bin = ['0', '00', '00000', '000', '00000', '000', '00000000', '0000000', '0000000', '000000', '00', '00', '0'
                   , '000000', '000000']
        pefunction_bin = []
        pefunction = []
        for line_in_PE in PE:
            if(line_in_PE[0:2] == 'PE'):
                pe_id = int(line_in_PE[3:-1])
                top_bin[6] = D2B(pe_id).zfill(8)
            elif(line_in_PE[1:4] == 'top'):
                number = [int(s) for s in re.findall(r'\b\d+\b', line_in_PE)]
                task_packageNum = number[0]
                package_index = number[1]
                iteration_pea = number[2]
                iteration_pe = number[3]
                initial_idle = number[4]
                iteration_line = number[5]
                count = number[6]
                top_bin[2] = D2B(task_packageNum).zfill(5)
                top_bin[4] = D2B(package_index).zfill(5)
                top_bin[7] = D2B(iteration_pea).zfill(7)
                top_bin[12] = D2B(iteration_pe).zfill(8)[0:1]
                top_bin[8] = D2B(iteration_pe).zfill(8)[1:]
                top_bin[11] = D2B(initial_idle).zfill(8)[0:2]
                top_bin[9] = D2B(initial_idle).zfill(8)[2:]
                top_bin[10] = D2B(iteration_line).zfill(2)
                top_bin[14] = D2B(count).zfill(6)
            elif(line_in_PE[0:2] == '//'):
                line_in_PE = line_in_PE.strip('//').split('|')
                iteration = int((line_in_PE[0].split('='))[1])
                II = int((line_in_PE[2].split('='))[1])
            else:
                line_in_PE = line_in_PE.strip('%').split(' ')
                operation = line_in_PE[0]
                in_out_detail = line_in_PE[1].split(',')
                if operation[0:4] == 'load':
                    len_in_out = len(in_out_detail)
                    if len_in_out == 2:
                        load_out = '1000000'
                    else:
                        load_out = transform_out(in_out_detail[2])
                    offset = int(in_out_detail[1])
                    if offset < 0:
                        offset = - offset
                        increase_flag = '10'
                    elif offset == 0:
                        increase_flag = '00'
                    else:
                        increase_flag = '01'
                    if in_out_detail[0][0:2] == 'SM':
                        each_line_bin = '0_' + '10_' + transform_in(pe_id, in_out_detail[0])[0][0:8]+'_' + '00000000_' \
                                        + transform_in(pe_id, in_out_detail[0])[0][8:]+'_' + D2B(offset).zfill(5)[1:]+'_' \
                                        + D2B(offset).zfill(5)[0]+'_' + '00_' + load_out+'_'  \
                                        + '0000_' + transform_op(operation, pe_id)[1]+'_' + transform_iteration(iteration, II)[1]+'_' \
                                        + increase_flag+'_' + transform_iteration(iteration, II)[0]+'_' + '000_' \
                                        + transform_op(operation, pe_id)[0]
                    else:
                        each_line_bin = '0_' + '10_' + transform_in(pe_id, in_out_detail[0])[0]+'_' + '00000000_' \
                                        + '00000000_' + D2B(offset).zfill(5)[1:]+'_' \
                                        + D2B(offset).zfill(5)[0]+'_' + '00_' + load_out+'_'  \
                                        + '0000_' + transform_op(operation, pe_id)[1]+'_' + transform_iteration(iteration, II)[1]+'_' \
                                        + increase_flag+'_' + transform_iteration(iteration, II)[0]+'_' + '000_' \
                                        + transform_op(operation, pe_id)[0]
                elif operation[0:4] == 'stor':
                    offset = int(in_out_detail[2])
                    if offset < 0:
                        offset = - offset
                        increase_flag = '10'
                    elif offset == 0:
                        increase_flag = '00'
                    else:
                        increase_flag = '01'
                    if in_out_detail[0][0:2] == 'SM':
                        each_line_bin = '0_' + '10_' + transform_in(pe_id, in_out_detail[0])[0][0:8]+'_' + transform_in(pe_id, in_out_detail[1])[0] \
                                        +'_'+ transform_in(pe_id, in_out_detail[0])[0][8:]+'_' + D2B(offset).zfill(5)[1:]+'_' \
                                        + D2B(offset).zfill(5)[0]+'_' + '00_' + '1000000_'  \
                                        + '0000_' + transform_op(operation, pe_id)[1]+'_' + transform_iteration(iteration, II)[1]+'_' \
                                        + increase_flag+'_' + transform_iteration(iteration, II)[0]+'_' + '000_' \
                                        + transform_op(operation, pe_id)[0]
                    else:
                        each_line_bin = '0_' + '10_' + transform_in(pe_id, in_out_detail[0])[0]+'_' + \
                                        transform_in(pe_id, in_out_detail[1])[0]+'_' \
                                        + '00000000_' + D2B(offset).zfill(5)[1:]+'_' \
                                        + D2B(offset).zfill(5)[0]+'_' + '00_' + '1000000_'  \
                                        + '0000_' + transform_op(operation, pe_id)[1]+'_' + transform_iteration(iteration, II)[1]+'_' \
                                        + increase_flag+'_' + transform_iteration(iteration, II)[0]+'_' + '000_' \
                                        + transform_op(operation, pe_id)[0]
                else:
                    in_out_num = len(in_out_detail)
                    num0 = ['nop']
                    num1 = ['not', 'clz']
                    num2 = ['router', 'add', 'sub', 'uadd', 'usub', 'and', 'or', 'xor', 'sll', 'srl', 'arl', 'all', 'mul', 'umul',
                            'equal', 'div', 'udiv']
                    num3 = ['mac', 'umac', 'mrl', 'umrl' ]
                    num4 = ['sel']
                    if operation in num0:
                        in1 = '00000000'
                        in2 = '00000000'
                        in3 = '00000000'
                        in4 = '000000'
                        Imm = '0'
                        out1 = '1000000'
                        out2 = '1000000'
                        IItype = transform_iteration(iteration, II)[1]
                        iteration = transform_iteration(iteration, II)[0]
                        opcode = transform_op(operation, pe_id)[0]
                    elif operation in num1:
                        in1 = transform_in(pe_id, in_out_detail[0])[0]
                        in2 = '00000000'
                        in3 = '00000000'
                        in4 = '000000'
                        Imm = '0'
                        if in_out_num == 2:
                            out1 = transform_out(in_out_detail[1])
                        else:
                            out1 = '1000000'
                        out2 = '1000000'
                        IItype = transform_iteration(iteration, II)[1]
                        iteration = transform_iteration(iteration, II)[0]
                        opcode = transform_op(operation, pe_id)[0]
                    elif operation in num2:
                        in1 = transform_in(pe_id, in_out_detail[0])[0]
                        in2 = transform_in(pe_id, in_out_detail[1])[0]
                        in3 = '00000000'
                        in4 = '000000'
                        Imm = transform_in(pe_id, in_out_detail[1])[1]
                        if in_out_num == 3:
                            out1 = transform_out(in_out_detail[2])
                        else:
                            out1 = '1000000'
                        out2 = '1000000'
                        IItype = transform_iteration(iteration, II)[1]
                        iteration = transform_iteration(iteration, II)[0]
                        opcode = transform_op(operation, pe_id)[0]
                    elif operation in num3:
                        in1 = transform_in(pe_id, in_out_detail[0])[0]
                        in2 = transform_in(pe_id, in_out_detail[1])[0]
                        in3 = transform_in(pe_id, in_out_detail[2])[0]
                        in4 = '000000'
                        Imm = transform_in(pe_id, in_out_detail[1])[1]
                        if in_out_num == 4:
                            out1 = transform_out(in_out_detail[3])
                        else:
                            out1 = '1000000'
                        out2 = '1000000'
                        IItype = transform_iteration(iteration, II)[1]
                        iteration = transform_iteration(iteration, II)[0]
                        opcode = transform_op(operation, pe_id)[0]
                    elif operation in num4:
                        in1 = transform_in(pe_id, in_out_detail[0])[0]
                        in2 = transform_in(pe_id, in_out_detail[1])[0]
                        in3 = '00000000'
                        in4 = transform_in(pe_id, in_out_detail[2])[0]
                        Imm = transform_in(pe_id, in_out_detail[1])[1]
                        if in_out_num == 4:
                            out1 = transform_out(in_out_detail[3])
                        else:
                            out1 = '1000000'
                        out2 = '1000000'
                        IItype = transform_iteration(iteration, II)[1]
                        iteration = transform_iteration(iteration, II)[0]
                        opcode = transform_op(operation, pe_id)[0]
                    else:
                        in1 = 'xxxxxxxx'
                        in2 = 'xxxxxxxx'
                        in3 = 'xxxxxxxx'
                        in4 = 'xxxxxx'
                        Imm = 'x'
                        out1 = 'xxxxxxx'
                        out2 = 'xxxxxxx'
                        IItype = 'x'
                        iteration = 'xxxxxxxxxx'
                        opcode = 'xxxxx'
                    each_line_bin = '0_' + '01_' + in1 + '_' + in2 + '_' + in3 + '_' + in4 + '_' + Imm + '_' + out1 + '_' \
                                    + out2 + '_' + IItype + '_' + iteration + '_' + opcode
                pefunction_bin.append(each_line_bin)
            top_final = ''
            for top_bin_each in top_bin:
                top_final = top_final + top_bin_each + '_'
            top_final = top_final.strip('_')
        PE_bin.append(top_final)
        for pefunction_bin_each in pefunction_bin:
            PE_bin.append(pefunction_bin_each)
        PES_bin.append(PE_bin)

        #print(D2B(-6))
        # print(pefunction_bin)
        # print(PE_bin)
        # print(PES_bin)
        # print(B2H(pefunction_bin[0]))

        fout = open('ddr_32_cnn_BIN.txt', 'w')
        for outPE in PES_bin:
            for PELINE in outPE:
                fout.write(PELINE + '\n')
            fout.write('\n\n')
        fout.close()

        fout1 = open('ddr_32_cnn_HEX.txt', 'w')
        for outPE in PES_bin:
            for PELINE in outPE:
                fout1.write(B2H(PELINE)[8:] + '\n' + B2H(PELINE)[0:8] + '\n')
        fout1.close()

if __name__ == '__main__':
    main()







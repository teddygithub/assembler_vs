import sys
def _main():
    f = open('ConfigPack_conven1_assemble_out.txt','r', encoding='utf-8')
    s = open('ConfigPack_conven1_assemble.txt','w', encoding='utf-8')
    result = list()
    for line in f.readlines():
        if line == '\n':
            line = line.strip('\n')
        line = line.strip()
        line = line.replace('_','')
        line = list(map(int, line))
        if line != []:
            if line[1:3] == [0, 0]:
                PEnum, PEindex = PE_index(line)
                TOPconfig = TOP_config(line)
                s.writelines("\n" + PEindex + "\n")
                s.writelines(TOPconfig + "\n")
            elif line[1:3] == [0, 1]:
                iterlenII = iteration_length_II(line)
                s.writelines(iterlenII + "\n")
                opcode = opcode_ALU(line)
                if opcode == '%nop':
                    s.writelines(opcode + ' 0,0' + "\n")
                else:
                    routerlabel1 = router_label(PEnum, line[7:11])
                    alunin1 = ALU_in1(opcode, line, routerlabel1)
                    routerlabel2 = router_label(PEnum, line[15:19])
                    alunin2 = ALU_in2(opcode, line, routerlabel2)
                    routerlabel3 = router_label(PEnum, line[23:27])
                    alunin3 = ALU_in3(opcode, line, routerlabel3)
                    routerlabel4 = router_label(PEnum, line[29:33])
                    alunin4 = ALU_in4(opcode, line, routerlabel4)
                    aluout1 = ALU_out1(line)
                    ALUconfig = opcode + ' ' + alunin1 + alunin2 + alunin3 + alunin4 + aluout1
                    s.writelines(ALUconfig + "\n")
            elif line[1:3] == [1, 0]:
                iterlenII = iteration_length_II(line)
                s.writelines(iterlenII + "\n")
                opcode = opcode_LSU(line)
                routerlabel1 = router_label(PEnum, line[7:11])
                lsuaddrmem = LSU_AddrMem(line, routerlabel1)
                routerlabel2 = router_label(PEnum, line[23:27])
                lsuinmem = LSU_InMem(opcode, line, routerlabel2)
                lsuoffset = LSU_Offset(line)
                LSUconfig = opcode + ' ' + lsuaddrmem + lsuinmem + lsuoffset
                s.writelines(LSUconfig + "\n")

def LSU_AddrMem(line, routerlabel):
    if line[3:6] == [0, 0, 0]:
        LR_index = line[10] * (2 ** 0) + line[9] * (2 ** 1) + line[8] * (2 ** 2) + line[7] * (2 ** 3) + line[6] * (
                2 ** 4)
        lsuaddrmem = 'LR' + str(LR_index)
    elif line[3:6] == [0, 0, 1]:
        GR_index = line[10] * (2 ** 0) + line[9] * (2 ** 1) + line[8] * (2 ** 2) + line[7] * (2 ** 3) + line[6] * (
                2 ** 4)
        lsuaddrmem = 'GR' + str(GR_index)
    elif line[3:6] == [0, 1, 0]:
        if line[6] == 0 or line[6] == 1:
            lsuaddrmem = 'PE0' + routerlabel
    elif line[3:6] == [0, 1, 1]:
        if line[6] == 0 or line[6] == 1:
            lsuaddrmem = 'PE0self'
    elif line[3:6] == [1, 0, 0]:
        if line[6] == 0 or line[6] == 1:
            SMindex = line[18] * (2 ** 0) + line[17] * (2 ** 1) + line[16] * (2 ** 2) + line[15] * (2 ** 3) + line[14] * (
                    2 ** 4) + line[13] * (2 ** 5) + line[12] * (2 ** 6) + line[11] * (2 ** 7) + line[10] * (2 ** 8
                    ) + line[9] * (2 ** 9) + line[8] * (2 ** 10) + line[7] * (2 ** 11)
            lsuaddrmem = 'SM' + str(SMindex)
        return lsuaddrmem

def LSU_InMem(opcode, line, routerlabel):
    if opcode == '%store':
        if line[19:22] == [0, 0, 0]:
            LR_index = line[26] * (2 ** 0) + line[25] * (2 ** 1) + line[24] * (2 ** 2) + line[23] * (2 ** 3) + line[
                22] * (2 ** 4)
            lsuinmem = ',LR' + str(LR_index)
        elif line[19:22] == [0, 0, 1]:
            GR_index = line[26] * (2 ** 0) + line[25] * (2 ** 1) + line[24] * (2 ** 2) + line[23] * (2 ** 3) + line[
                22] * (2 ** 4)
            lsuinmem = ',GR' + str(GR_index)
        elif line[19:22] == [0, 1, 0]:
            if line[22] == 0 or line[22] == 1:
                lsuinmem = ',PE0' + routerlabel
        elif line[19:22] == [0, 1, 1]:
            if line[22] == 0 or line[22] == 1:
                lsuinmem = ',PE0self'
        elif line[19:22] == [1, 0, 0]:
            if line[22] == 0 or line[22] == 1:
                lsuinmem = ',PE1' + routerlabel
    else:
        lsuinmem = ''
    return lsuinmem

def LSU_Offset(line):
    offset = line[30] * (2 ** 0) + line[29] * (2 ** 1) + line[28] * (2 ** 2) + line[27] * (2 ** 3)
    lsuoffset = ',' + str(offset)
    return lsuoffset

def ALU_in1(opcode, line, routerlabel):
    if opcode !='%router':
        if line[3:6] == [0, 0, 0]:
            LR_index = line[10] * (2 ** 0) + line[9] * (2 ** 1) + line[8] * (2 ** 2) + line[7] * (2 ** 3) + line[6] * (
                    2 ** 4)
            aluin1 = 'LR' + str(LR_index)
        elif line[3:6] == [0, 0, 1]:
            GR_index = line[10] * (2 ** 0) + line[9] * (2 ** 1) + line[8] * (2 ** 2) + line[7] * (2 ** 3) + line[6] * (
                    2 ** 4)
            aluin1 = 'GR' + str(GR_index)
        elif line[3:6] == [0, 1, 0]:
            if line[6] == 0 or line[6] == 1:
                aluin1 = 'PE0' + routerlabel
        elif line[3:6] == [0, 1, 1]:
            if line[6] == 0 or line[6] == 1:
                aluin1 = 'PE0self'
        elif line[3:6] == [1, 0, 0]:
            if line[6] == 0 or line[6] == 1:
                aluin1 = 'PE1' + routerlabel
    else:
        aluin1 = ''
    return aluin1

def ALU_in2(opcode, line, routerlabel):
    global aluin2
    if opcode != '%not':
        if line[33] == 0:
            if line[11:14] == [0, 0, 0]:
                LR_index = line[18] * (2 ** 0) + line[17] * (2 ** 1) + line[16] * (2 ** 2) + line[15] * (2 ** 3) + line[
                    14] * (2 ** 4)
                aluin2 = 'LR' + str(LR_index)
            elif line[11:14] == [0, 0, 1]:
                GR_index = line[18] * (2 ** 0) + line[17] * (2 ** 1) + line[16] * (2 ** 2) + line[15] * (2 ** 3) + line[
                    14] * (2 ** 4)
                aluin2 = 'GR' + str(GR_index)
            elif line[11:14] == [0, 1, 0]:
                if line[14] == 0 or line[14] == 1:
                    aluin2 = 'PE0' + routerlabel
            elif line[11:14] == [0, 1, 1]:
                if line[14] == 0 or line[14] == 1:
                    aluin2 = 'PE0self'
            elif line[11:14] == [1, 0, 0]:
                if line[14] == 0 or line[14] == 1:
                    aluin2 = 'PE1' + routerlabel
        elif line[33] == 1:
            immediate = line[18] * (2 ** 0) + line[17] * (2 ** 1) + line[16] * (2 ** 2) + line[15] * (2 ** 3) + line[
                14] * (2 ** 4) + line[13] * (2 ** 5) + line[12] * (2 ** 6) + line[11] * (2 ** 7)
            aluin2 = 'IM' + str(immediate)
        if opcode !='%router':
            aluin2 = ',' + aluin2
    else:
        aluin2 = ''
    return aluin2

def ALU_in3(opcode, line, routerlabel):
    if opcode == '%mac' or opcode == '%umac':
        if line[19:22] == [0, 0, 0]:
            LR_index = line[26] * (2 ** 0) + line[25] * (2 ** 1) + line[24] * (2 ** 2) + line[23] * (2 ** 3) + line[22] * (
                    2 ** 4)
            aluin3 = ',LR' + str(LR_index)
        elif line[19:22] == [0, 0, 1]:
            GR_index = line[26] * (2 ** 0) + line[25] * (2 ** 1) + line[24] * (2 ** 2) + line[23] * (2 ** 3) + line[22] * (
                    2 ** 4)
            aluin3 = ',GR' + str(GR_index)
        elif line[19:22] == [0, 1, 0]:
            if line[22] == 0 or line[22] == 1:
                aluin3 = ',PE0' + routerlabel
        elif line[19:22] == [0, 1, 1]:
            if line[22] == 0 or line[22] == 1:
                aluin3 = ',PE0self'
        elif line[19:22] == [1, 0, 0]:
            if line[22] == 0 or line[22] == 1:
                aluin3 = ',PE1' + routerlabel
    else:
        aluin3 = ''
    return aluin3

def ALU_in4(opcode, line, routerlabel):
    if opcode == '%sel':
        if line[27] == 1:
            if line[28] == 0 or line[28] == 1:
                aluin4 = ',PE2' + routerlabel
        elif line[27] == 0:
            if line[28] == 0 or line[28] == 1:
                aluin4 = ',PE2self'
    else:
        aluin4 = ''
    return aluin4

def ALU_out1(line):
    if line[34:36] == [0,0]:
        LR_index = line[40] * (2 ** 0) + line[39] * (2 ** 1) + line[38] * (2 ** 2) + line[37] * (2 ** 3) + line[36] * (
                2 ** 4)
        aluout1 = ',LR' + str(LR_index)
    elif line[34:36] == [0,1]:
        GR_index = line[40] * (2 ** 0) + line[39] * (2 ** 1) + line[38] * (2 ** 2) + line[37] * (2 ** 3) + line[36] * (
                2 ** 4)
        aluout1 = ',GR' + str(GR_index)
    else:
        aluout1 = ''
    return aluout1

def opcode_ALU(line):
    if line[59:64] == [0, 0, 0, 0, 0]:
        opcode = '%nop'
    elif line[59:64] == [0, 0, 0, 0, 1]:
        opcode = '%router'
    elif line[59:64] == [0, 0, 0, 1, 0]:
        opcode = '%add'
    elif line[59:64] == [0, 0, 0, 1, 1]:
        opcode = '%sub'
    elif line[59:64] == [0, 0, 1, 0, 0]:
        opcode = '%uadd'
    elif line[59:64] == [0, 0, 1, 0, 1]:
        opcode = '%usub'
    elif line[59:64] == [0, 0, 1, 1, 0]:
        opcode = '%and'
    elif line[59:64] == [0, 0, 1, 1, 1]:
        opcode = '%or'
    elif line[59:64] == [0, 1, 0, 0, 0]:
        opcode = '%xor'
    elif line[59:64] == [0, 1, 0, 0, 1]:
        opcode = '%or' #new insert
    elif line[59:64] == [0, 1, 0, 1, 0]:
        opcode = '%sel'
    elif line[59:64] == [0, 1, 0, 1, 1]:
        opcode = '%sll'
    elif line[59:64] == [0, 1, 1, 0, 0]:
        opcode = '%srl'
    elif line[59:64] == [0, 1, 1, 0, 1]:
        opcode = '%arl'
    elif line[59:64] == [0, 1, 1, 1, 0]:
        opcode = '%all'
    elif line[59:64] == [0, 1, 1, 1, 1]:
        opcode = '%clz'
    elif line[59:64] == [1, 0, 0, 0, 0]:
        opcode = '%mul'
    elif line[59:64] == [1, 0, 0, 0, 1]:
        opcode = '%mac'
    elif line[59:64] == [1, 0, 0, 1, 0]:
        opcode = '%umul'
    elif line[59:64] == [1, 0, 0, 1, 1]:
        opcode = '%umac'
    elif line[59:64] == [1, 0, 1, 1, 0]:
        opcode = '%equa'
    elif line[59:64] == [1, 0, 1, 1, 1]:
        opcode = '%div'
    elif line[59:64] == [1, 1, 0, 0, 0]:
        opcode = '%udiv'
    #elif line[59:64] == [0, 1, 0, 0, 1]:
        #opcode = '%abs'
    else:
        sys.exit(0)
    return opcode

def opcode_LSU(line):
    if line[62:64] == [0, 0] or line[62:64] == [1, 0]:
        opcode = '%load'
    elif line[62:64] == [0, 1] or line[62:64] == [1, 1]:
        opcode = '%store'
    else:
        sys.exit(0)
    return opcode

def iteration_length_II(line):
    if line[49:51] == [0, 0]:
        Iter_Num = line[55] * (2 ** 0) + line[54] * (2 ** 1) + line[53] * (2 ** 2) + line[52] * (2 ** 3) + line[51] * (
                2 ** 4)
        Iter_II = line[58] * (2 ** 0) + line[57] * (2 ** 1) + line[56] * (2 ** 2)
    iterlenII = '//iteration=' + str(Iter_Num) + '|II=' + str(Iter_II)
    return(iterlenII)

def PE_index(line):
    PEnum = line[26] * (2 ** 0) + line[25] * (2 ** 1) + line[24] * (2 ** 2) + line[23] * (2 ** 3) + line[22] * (
                2 ** 4) + line[21] * (2 ** 5) + line[20] * (2 ** 6) + line[19] * (2 ** 7)
    PEindex = 'PE[' + str(PEnum) + ']'
    return PEnum,PEindex

def TOP_config(line):
    Task_PackageNum = line[7] * (2 ** 0) + line[6] * (2 ** 1) + line[5] * (2 ** 2) + line[4] * (2 ** 3) + line[3] * (
                2 ** 4)
    Package_Index = line[15] * (2 ** 0) + line[14] * (2 ** 1) + line[13] * (2 ** 2) + line[12] * (2 ** 3) + line[11] * (
                2 ** 4)
    Iteration_PEA = line[33] * (2 ** 0) + line[32] * (2 ** 1) + line[31] * (2 ** 2) + line[30] * (2 ** 3) + line[29] * (
                2 ** 4) + line[28] * (2 ** 5) + line[27] * (2 ** 6)
    Iteration_PE = line[40] * (2 ** 0) + line[39] * (2 ** 1) + line[38] * (2 ** 2) + line[37] * (2 ** 3) + line[36] * (
                2 ** 4) + line[35] * (2 ** 5) + line[34] * (2 ** 6)
    Initial_Idle = line[46] * (2 ** 0) + line[45] * (2 ** 1) + line[44] * (2 ** 2) + line[43] * (2 ** 3) + line[42] * (
                2 ** 4) + line[41] * (2 ** 5)
    Count = line[63] * (2 ** 0) + line[62] * (2 ** 1) + line[61] * (2 ** 2) + line[60] * (2 ** 3) + line[59] * (
                2 ** 4) + line[58] * (2 ** 5)
    Topconfig = '%top ' + str(Task_PackageNum) + ',' + str(Package_Index) + ',' + str(Iteration_PEA) + ',' + str(
        Iteration_PE) + ',' + str(Initial_Idle) + ',0,' + str(Count)
    return Topconfig

def router_label(PEnum, index):
    global routerlabel
    if index == [0, 0, 0, 0]:
        if PEnum == 0:
            routerlabel = 'righ'
        elif PEnum == 7:
            routerlabel = 'left'
        elif PEnum == 56:
            routerlabel = 'righ'
        elif PEnum == 63:
            routerlabel = 'left'
        elif PEnum >0 and PEnum < 7:
            routerlabel = 'left'
        elif PEnum >56 and PEnum < 63:
            routerlabel = 'left'
        elif PEnum % 8 ==0:
            routerlabel = 'upup'
        elif (PEnum+1) % 8 ==0:
            routerlabel = 'upup'
        elif (PEnum > 8 and PEnum < 15) or (PEnum > 16 and PEnum < 23) or (PEnum > 24 and PEnum < 31) or \
                (PEnum > 32 and PEnum < 39) or (PEnum > 40 and PEnum < 47) or (PEnum > 48 and PEnum < 55):
            routerlabel = 'upup'
        else:
            routerlabel = 'none'
    elif index == [0, 0, 0, 1]:
        if PEnum == 0:
            routerlabel = 'di2r'
        elif PEnum == 7:
            routerlabel = 'di2r'
        elif PEnum == 56:
            routerlabel = 'di2r'
        elif PEnum == 63:
            routerlabel = 'di2r'
        elif PEnum >0 and PEnum < 7:
            routerlabel = 'righ'
        elif PEnum >56 and PEnum < 63:
            routerlabel = 'righ'
        elif PEnum % 8 ==0:
            routerlabel = 'down'
        elif (PEnum+1) % 8 ==0:
            routerlabel = 'down'
        elif (PEnum > 8 and PEnum < 15) or (PEnum > 16 and PEnum < 23) or (PEnum > 24 and PEnum < 31) or \
                (PEnum > 32 and PEnum < 39) or (PEnum > 40 and PEnum < 47) or (PEnum > 48 and PEnum < 55):
            routerlabel = 'down'
        else:
            routerlabel = 'none'
    elif index == [0, 0, 1, 0]:
        if PEnum == 0:
            routerlabel = 'di3r'
        elif PEnum == 7:
            routerlabel = 'di3r'
        elif PEnum == 56:
            routerlabel = 'di3r'
        elif PEnum == 63:
            routerlabel = 'di3r'
        elif PEnum >0 and PEnum < 7:
            routerlabel = 'lete'
        elif PEnum >56 and PEnum < 63:
            routerlabel = 'lete'
        elif PEnum % 8 ==0:
            routerlabel = 'upte'
        elif (PEnum+1) % 8 ==0:
            routerlabel = 'upte'
        elif (PEnum > 8 and PEnum < 15) or (PEnum > 16 and PEnum < 23) or (PEnum > 24 and PEnum < 31) or \
                (PEnum > 32 and PEnum < 39) or (PEnum > 40 and PEnum < 47) or (PEnum > 48 and PEnum < 55):
            routerlabel = 'left'
        else:
            routerlabel = 'none'
    elif index == [0, 0, 1, 1]:
        if PEnum == 0:
            routerlabel = 'left'
        elif PEnum == 7:
            routerlabel = 'righ'
        elif PEnum == 56:
            routerlabel = 'left'
        elif PEnum == 63:
            routerlabel = 'righ'
        elif PEnum >0 and PEnum < 7:
            routerlabel = 'rite'
        elif PEnum >56 and PEnum < 63:
            routerlabel = 'rite'
        elif PEnum % 8 ==0:
            routerlabel = 'dote'
        elif (PEnum+1) % 8 ==0:
            routerlabel = 'dote'
        elif (PEnum > 8 and PEnum < 15) or (PEnum > 16 and PEnum < 23) or (PEnum > 24 and PEnum < 31) or \
                (PEnum > 32 and PEnum < 39) or (PEnum > 40 and PEnum < 47) or (PEnum > 48 and PEnum < 55):
            routerlabel = 'righ'
        else:
            routerlabel = 'none'
    elif index == [0, 1, 0, 0]:
        if PEnum == 0:
            routerlabel = 'down'
        elif PEnum == 7:
            routerlabel = 'down'
        elif PEnum == 56:
            routerlabel = 'upup'
        elif PEnum == 63:
            routerlabel = 'upup'
        elif PEnum >0 and PEnum < 7:
            routerlabel = 'down'
        elif PEnum >56 and PEnum < 63:
            routerlabel = 'upup'
        elif PEnum % 8 ==0:
            routerlabel = 'righ'
        elif (PEnum+1) % 8 ==0:
            routerlabel = 'left'
        elif (PEnum > 8 and PEnum < 15) or (PEnum > 16 and PEnum < 23) or (PEnum > 24 and PEnum < 31) or \
                (PEnum > 32 and PEnum < 39) or (PEnum > 40 and PEnum < 47) or (PEnum > 48 and PEnum < 55):
            routerlabel = 'upte'
        else:
            routerlabel = 'none'
    elif index == [0, 1, 0, 1]:
        if PEnum == 0:
            routerlabel = 'di2c'
        elif PEnum == 7:
            routerlabel = 'di2c'
        elif PEnum == 56:
            routerlabel = 'di2c'
        elif PEnum == 63:
            routerlabel = 'di2c'
        elif PEnum >0 and PEnum < 7:
            routerlabel = 'di2c'
        elif PEnum >56 and PEnum < 63:
            routerlabel = 'di2c'
        elif PEnum % 8 ==0:
            routerlabel = 'di2r'
        elif (PEnum+1) % 8 ==0:
            routerlabel = 'di2r'
        elif (PEnum > 8 and PEnum < 15) or (PEnum > 16 and PEnum < 23) or (PEnum > 24 and PEnum < 31) or \
                (PEnum > 32 and PEnum < 39) or (PEnum > 40 and PEnum < 47) or (PEnum > 48 and PEnum < 55):
            routerlabel = 'dote'
        else:
            routerlabel = 'none'
    elif index == [0, 1, 1, 0]:
        if PEnum == 0:
            routerlabel = 'di3c'
        elif PEnum == 7:
            routerlabel = 'di3c'
        elif PEnum == 56:
            routerlabel = 'di3c'
        elif PEnum == 63:
            routerlabel = 'di3c'
        elif PEnum >0 and PEnum < 7:
            routerlabel = 'di3c'
        elif PEnum >56 and PEnum < 63:
            routerlabel = 'di3c'
        elif PEnum % 8 ==0:
            routerlabel = 'di3r'
        elif (PEnum+1) % 8 ==0:
            routerlabel = 'di3r'
        elif (PEnum > 8 and PEnum < 15) or (PEnum > 16 and PEnum < 23) or (PEnum > 24 and PEnum < 31) or \
                (PEnum > 32 and PEnum < 39) or (PEnum > 40 and PEnum < 47) or (PEnum > 48 and PEnum < 55):
            routerlabel = 'lete'
        else:
            routerlabel = 'none'
    elif index == [0, 1, 1, 1]:
        if PEnum == 0:
            routerlabel = 'upup'
        elif PEnum == 7:
            routerlabel = 'upup'
        elif PEnum == 56:
            routerlabel = 'down'
        elif PEnum == 63:
            routerlabel = 'down'
        elif PEnum >0 and PEnum < 7:
            routerlabel = 'upup'
        elif PEnum >56 and PEnum < 63:
            routerlabel = 'down'
        elif PEnum % 8 ==0:
            routerlabel = 'left'
        elif (PEnum+1) % 8 ==0:
            routerlabel = 'righ'
        elif (PEnum > 8 and PEnum < 15) or (PEnum > 16 and PEnum < 23) or (PEnum > 24 and PEnum < 31) or \
                (PEnum > 32 and PEnum < 39) or (PEnum > 40 and PEnum < 47) or (PEnum > 48 and PEnum < 55):
            routerlabel = 'rite'
        else:
            sys.exit(0)

    return routerlabel



if __name__ == '__main__':
    _main()

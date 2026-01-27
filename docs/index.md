---
layout: default
title: Main page
---

# Welcome to the documentation

# Custom super reduced instruction set:

## Overview:


<table>
    <tr>
        <th colspan="2">Instruction</th>
        <th colspan="16">Bit meaning</th>
    </tr>
    <tr>
        <th colspan="2"> </th><th>0</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th><th>7</th>
        <th>8</th><th>9</th><th>A</th><th>B</th><th>C</th><th>D</th><th>E</th><th>F</th>
    </tr>
    <tr>
        <td colspan="2">Add</td>
        <th colspan="1">0</th>
        <th colspan="1">0</th>
        <th colspan="1">0</th>
        <th colspan="1">0</th>
        <th colspan="4">Dest</th>
        <th colspan="4">Source 1</th>
        <th colspan="4">Source 2</th>
    </tr>
    <tr>
        <td colspan="2">Addi</td>
        <th colspan="1">0</th>
        <th colspan="1">0</th>
        <th colspan="1">0</th>
        <th colspan="1">1</th>
        <th colspan="4">Target reg</th>
        <th colspan="8">Immediate</th>
    </tr>
    <tr>
        <td colspan="2">Sub</td>
        <th colspan="1">0</th>
        <th colspan="1">0</th>
        <th colspan="1">1</th>
        <th colspan="1">0</th>
        <th colspan="4">Dest</th>
        <th colspan="4">Source 1</th>
        <th colspan="4">Source 2</th>
    </tr>
    <tr>
        <td colspan="2">And</td>
        <th colspan="1">0</th>
        <th colspan="1">0</th>
        <th colspan="1">1</th>
        <th colspan="1">1</th>
        <th colspan="4">Dest</th>
        <th colspan="4">Source 1</th>
        <th colspan="4">Source 2</th>
    </tr>
    <tr>
        <td colspan="2">Or</td>
        <th colspan="1">0</th>
        <th colspan="1">1</th>
        <th colspan="1">0</th>
        <th colspan="1">0</th>
        <th colspan="4">Dest</th>
        <th colspan="4">Source 1</th>
        <th colspan="4">Source 2</th>
    </tr>
    <tr>
        <td colspan="2">Xor</td>
        <th colspan="1">0</th>
        <th colspan="1">1</th>
        <th colspan="1">0</th>
        <th colspan="1">1</th>
        <th colspan="4">Dest</th>
        <th colspan="4">Source 1</th>
        <th colspan="4">Source 2</th>
    </tr>
    <tr>
        <td colspan="2">Loadi</td>
        <th colspan="1">0</th>
        <th colspan="1">1</th>
        <th colspan="1">1</th>
        <th colspan="1">0</th>
        <th colspan="4">Dest</th>
        <th colspan="8">Immediate</th>
    </tr>
    <!-- Load word -->
    <tr>
        <td colspan="2">Load</td>
        <th colspan="1">0</th>
        <th colspan="1">1</th>
        <th colspan="1">1</th>
        <th colspan="1">1</th>
        <th colspan="4">Dest</th>
        <th colspan="4">Source 1</th>
        <th colspan="4">Offset</th>
    </tr>
    <!-- Store word -->
    <tr>
        <td colspan="2">Store</td>
        <th colspan="1">1</th>
        <th colspan="1">0</th>
        <th colspan="1">0</th>
        <th colspan="1">0</th>
        <th colspan="4">Source 2</th>
        <th colspan="4">Source 1</th>
        <th colspan="4">Offset</th>
    </tr>
    <tr>
        <td colspan="2">Jump</td>
        <th colspan="1">1</th>
        <th colspan="1">0</th>
        <th colspan="1">0</th>
        <th colspan="1">1</th>
        <th colspan="12">Offset</th>
    </tr>
    <tr>
        <td colspan="2">Branch if zero</td>
        <th colspan="1">1</th>
        <th colspan="1">0</th>
        <th colspan="1">1</th>
        <th colspan="1">0</th>
        <th colspan="12">Offset</th>
    </tr>
    <tr>
        <td colspan="2">Branch if not zero</td>
        <th colspan="1">1</th>
        <th colspan="1">0</th>
        <th colspan="1">1</th>
        <th colspan="1">1</th>
        <th colspan="12">Offset</th>
    </tr>
    <tr>
        <td colspan="2">Branch if not specific flag</td>
        <th colspan="1">1</th>
        <th colspan="1">1</th>
        <th colspan="1">0</th>
        <th colspan="1">0</th>
        <th colspan="12">Offset</th>
    </tr>
    <tr>
        <td colspan="2">Shift left </td>
        <th colspan="1">1</th>
        <th colspan="1">1</th>
        <th colspan="1">0</th>
        <th colspan="1">1</th>
        <th colspan="4">Reg to shift</th>
        <th colspan="4">Reg holding shift amount</th>
        <th colspan="1">Imm?</th>
        <th colspan="3">Imm</th>
    </tr>
    <tr>
        <td colspan="2">Shift right</td>
        <th colspan="1">1</th>
        <th colspan="1">1</th>
        <th colspan="1">1</th>
        <th colspan="1">0</th>
        <th colspan="4">Reg to shift</th>
        <th colspan="4">Reg holding shift amount</th>
        <th colspan="1">Imm?</th>
        <th colspan="3">Imm</th>
    </tr>
    <tr>
        <td colspan="2">Compare</td>
        <th colspan="1">1</th>
        <th colspan="1">1</th>
        <th colspan="1">1</th>
        <th colspan="1">1</th>
        <th colspan="4">Source 1</th>
        <th colspan="4">Source 2</th>
        <th colspan="4">Nop?</th>
    </tr>
</table>

## Detailed instruction set:

## Arithmetic Operations
### Addition:

Op mnemonic: `add`

<table>
    <tr>
        <th>0</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th><th>7</th>
        <th>8</th><th>9</th><th>A</th><th>B</th><th>C</th><th>D</th><th>E</th><th>F</th>
    </tr>
    <tr>
        <th colspan="1">0</th>
        <th colspan="1">0</th>
        <th colspan="1">0</th>
        <th colspan="1">0</th>
        <th colspan="4">RD</th>
        <th colspan="4">RS1</th>
        <th colspan="4">RS2</th>
    </tr>
</table>

| Effect          |
|-----------------|
| RD <= RS1 + RS2 |

Details: Here, the Op specific flag is used for overflow detection. If the addition results in an overflow, the Op specific flag is set to 1; otherwise, it is set to 0. 

Flags modified:

| Zero | Op specific|
|:----:|:--------:|
| x         | x        |

### Immediate addition:

Op mnemonic: `addi`

<table>
    <tr>
        <th>0</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th><th>7</th>
        <th>8</th><th>9</th><th>A</th><th>B</th><th>C</th><th>D</th><th>E</th><th>F</th>
    </tr>
    <tr>
        <td colspan="1">0</td>
        <td colspan="1">0</td>
        <td colspan="1">0</td>
        <td colspan="1">1</td>
        <td colspan="4">RD</td>
        <td colspan="8">Immediate value</td>
    </tr>
</table>

| Effect               |
|----------------------|
| RD <= RD + Immediate |

Details: The immediate value is a signed 8 bit value. There is no immediate subtraction instruction, because the immediate addition instruction can be used to achieve the same effect by negating the immediate value.

Flags modified:

| Zero |Op specific|
|:----:|:--------:|
| x      | x        |

### Subtraction:

Op mnemonic: `sub`

<table>
    <tr>
        <th>0</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th><th>7</th>
        <th>8</th><th>9</th><th>A</th><th>B</th><th>C</th><th>D</th><th>E</th><th>F</th>
    </tr>
    <tr>
        <th colspan="1">0</th>
        <th colspan="1">0</th>
        <th colspan="1">1</th>
        <th colspan="1">0</th>
        <th colspan="4">RD</th>
        <th colspan="4">RS1</th>
        <th colspan="4">RS2</th>
    </tr>
</table>

| Effect          |
|-----------------|
| RD <= RS1 - RS2 |

Details: Op specific is set to 1 in case of underflow, otherwise it is set to 0. The Zero flag is set if the result is zero.

Flags modified:

| Zero |Op specific|
|:----:|:--------:|
| x    | x   |

### Bitwise AND:

Op mnemonic: `and`

<table>
    <tr>
        <th>0</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th><th>7</th>
        <th>8</th><th>9</th><th>A</th><th>B</th><th>C</th><th>D</th><th>E</th><th>F</th>
    </tr>
    <tr>
        <th colspan="1">0</th>
        <th colspan="1">0</th>
        <th colspan="1">1</th>
        <th colspan="1">1</th>
        <th colspan="4">RD</th>
        <th colspan="4">RS1</th>
        <th colspan="4">RS2</th>
    </tr>
</table>

| Effect          |
|-----------------|
| RD <= RS1 & RS2 |

Details: /

Flags modified:

| Zero |Op specific|
|:----:|:--------:|
| x         |          |

### Bitwise OR:

Op mnemonic: `or`

<table>
    <tr>
        <th>0</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th><th>7</th>
        <th>8</th><th>9</th><th>A</th><th>B</th><th>C</th><th>D</th><th>E</th><th>F</th>
    </tr>
    <tr>
        <th colspan="1">0</th>
        <th colspan="1">1</th>
        <th colspan="1">0</th>
        <th colspan="1">0</th>
        <th colspan="4">RD</th>
        <th colspan="4">RS1</th>
        <th colspan="4">RS2</th>
    </tr>
</table>

| Effect           |
|------------------|
| RD <= RS1 \| RS2 |

Details: /

Flags modified:

| Zero |Op specific|
|:----:|:--------:|
| x        |          |

### Bitwise XOR:

Op mnemonic: `xor`

<table>
    <tr>
        <th>0</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th><th>7</th>
        <th>8</th><th>9</th><th>A</th><th>B</th><th>C</th><th>D</th><th>E</th><th>F</th>
    </tr>
    <tr>
        <th colspan="1">0</th>
        <th colspan="1">1</th>
        <th colspan="1">0</th>
        <th colspan="1">1</th>
        <th colspan="4">RD</th>
        <th colspan="4">RS1</th>
        <th colspan="4">RS2</th>
    </tr>
</table>

| Effect          |
|-----------------|
| RD <= RS1 ^ RS2 |

Details: /

Flags modified:

| Zero |Op specific|
|:----:|:--------:|
| x         |          |

## Memory Operations

### Load Immediate:

Op mnemonic: `loadi`

<table>
    <tr>
        <th>0</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th><th>7</th>
        <th>8</th><th>9</th><th>A</th><th>B</th><th>C</th><th>D</th><th>E</th><th>F</th>
    </tr>
    <tr>
        <th colspan="1">0</th>
        <th colspan="1">1</th>
        <th colspan="1">1</th>
        <th colspan="1">0</th>
        <th colspan="4">RD</th>
        <th colspan="8">Immediate</th>
    </tr>
</table>

| Effect          |
|-----------------|
| RD <= Immediate |

Details: Loads a sign-extended 8-bit immediate value into the destination register.

Flags modified:

| Zero |Op specific|
|:----:|:--------:|
|         |          |

### Load Word:

Op mnemonic: `load`


<table>
    <tr>
        <th>0</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th><th>7</th>
        <th>8</th><th>9</th><th>A</th><th>B</th><th>C</th><th>D</th><th>E</th><th>F</th>
    </tr>
    <tr>
        <th colspan="1">0</th>
        <th colspan="1">1</th>
        <th colspan="1">1</th>
        <th colspan="1">1</th>
        <th colspan="4">RD</th>
        <th colspan="4">RS1 (Base)</th>
        <th colspan="4">Offset</th>
    </tr>
</table>

| Effect                     |
|----------------------------|
| RD <= Memory[RS1 + Offset] |

Details: Loads a word from memory at the address computed by adding the base register and a 4-bit offset.

Flags modified:

| Zero |Op specific|
|:----:|:--------:|
|          |          |

### Store Word:

Op mnemonic: `store`


<table>
    <tr>
        <th>0</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th><th>7</th>
        <th>8</th><th>9</th><th>A</th><th>B</th><th>C</th><th>D</th><th>E</th><th>F</th>
    </tr>
    <tr>
        <th colspan="1">1</th>
        <th colspan="1">0</th>
        <th colspan="1">0</th>
        <th colspan="1">0</th>
        <th colspan="4">RS2 (Source)</th>
        <th colspan="4">RS1 (Base)</th>
        <th colspan="4">Offset</th>
    </tr>
</table>

| Effect                       |
|------------------------------|
| Memory[RS1 + Offset] <= RS2  |

Details: Stores a word from a source register into memory at the address computed by adding the base register and a 4-bit offset.

Flags modified:

| Zero |Op specific|
|:----:|:--------:|
|              |          |

## Control Flow Operations

### Jump:

Op mnemonic: `jmp`

<table>
    <tr>
        <th>0</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th><th>7</th>
        <th>8</th><th>9</th><th>A</th><th>B</th><th>C</th><th>D</th><th>E</th><th>F</th>
    </tr>
    <tr>
        <th colspan="1">1</th>
        <th colspan="1">0</th>
        <th colspan="1">0</th>
        <th colspan="1">1</th>
        <th colspan="12">Offset</th>
    </tr>
</table>

| Effect            |
|-------------------|
| PC <= PC + Offset |

Details: Unconditionally jumps to a new address by adding a 12-bit signed offset to the program counter.

Flags modified:

| Zero |Op specific|
|:----:|:--------:|
|              |          |

### Branch if Zero:

Op mnemonic: `brz`

<table>
    <tr>
        <th>0</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th><th>7</th>
        <th>8</th><th>9</th><th>A</th><th>B</th><th>C</th><th>D</th><th>E</th><th>F</th>
    </tr>
    <tr>
        <th colspan="1">1</th>
        <th colspan="1">0</th>
        <th colspan="1">1</th>
        <th colspan="1">0</th>
        <th colspan="12">Offset</th>
    </tr>
</table>

| Effect                                |
|---------------------------------------|
| if (Zero_flag == 1) PC <= PC + Offset |

Details: Jumps to a new address if the Zero flag is set.

Flags modified:

| Zero |Op specific|
|:----:|:--------:|
|           |          |

### Branch if Not Zero:

Op mnemonic: `brnz`
<table>
    <tr>
        <th>0</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th><th>7</th>
        <th>8</th><th>9</th><th>A</th><th>B</th><th>C</th><th>D</th><th>E</th><th>F</th>
    </tr>
    <tr>
        <th colspan="1">1</th>
        <th colspan="1">0</th>
        <th colspan="1">1</th>
        <th colspan="1">1</th>
        <th colspan="12">Offset</th>
    </tr>
</table>

| Effect                                |
|---------------------------------------|
| if (Zero_flag == 0) PC <= PC + Offset |

Details: Jumps to a new address if the Zero flag is not set.

Flags modified:

| Zero |Op specific|
|:----:|:--------:|
|            |          |

### Branch if Not Negative:

Op mnemonic: `brns`

<table>
    <tr>
        <th>0</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th><th>7</th>
        <th>8</th><th>9</th><th>A</th><th>B</th><th>C</th><th>D</th><th>E</th><th>F</th>
    </tr>
    <tr>
        <th colspan="1">1</th>
        <th colspan="1">1</th>
        <th colspan="1">0</th>
        <th colspan="1">0</th>
        <th colspan="12">Offset</th>
    </tr>
</table>

| Effect                                    |
|-------------------------------------------|
| if (Specific_flag == 0) PC <= PC + Offset |

Details: Jumps to a new address if the Specific flag is not set.

Flags modified:

| Zero |Op specific|
|:----:|:--------:|
|            |          |

## Shift and Compare Operations

### Shift Left:

Op mnemonic: `shl`
<table>
    <tr>
        <th>0</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th><th>7</th>
        <th>8</th><th>9</th><th>A</th><th>B</th><th>C</th><th>D</th><th>E</th><th>F</th>
    </tr>
    <tr>
        <th colspan="1">1</th>
        <th colspan="1">1</th>
        <th colspan="1">0</th>
        <th colspan="1">1</th>
        <th colspan="4">RD</th>
        <th colspan="4">RS (Shift amount)</th>
        <th colspan="1">Imm?</th>
        <th colspan="3">Immediate shift amount</th>
    </tr>
</table>

| Effect                |
|-----------------------|
| Imm?==0: RD <= RD << RS (logical) |
| Imm?==1: RD <= RD << Immediate (logical) |

Details: Shifts the value in a register to the left by an immediate amount (logical shift). The register is both source and destination. If the Imm? field is set to 0, the shift amount is taken from another register (RS). If Imm? is set to 1, the shift amount is taken from an immediate value.

Flags modified:

| Zero |Op specific|
|:----:|:--------:|
| x           |          |

### Shift Right:

Op mnemonic: `shr`

<table>
    <tr>
        <th>0</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th><th>7</th>
        <th>8</th><th>9</th><th>A</th><th>B</th><th>C</th><th>D</th><th>E</th><th>F</th>
    </tr>
    <tr>
        <th colspan="1">1</th>
        <th colspan="1">1</th>
        <th colspan="1">1</th>
        <th colspan="1">0</th>
        <th colspan="4">RD</th>
        <th colspan="4">RS (Shift amount)</th>
        <th colspan="1">Imm?</th>
        <th colspan="3">Immediate shift amount</th>
    </tr>
</table>

| Effect                          |
|---------------------------------|
| Imm?==0: RD <= RD >> RS (logical) |
| Imm?==1: RD <= RD >> Immediate (logical) |

Details: Shifts the value in a register to the right by an immediate amount (logical shift). The register is both source and destination. If the Imm? field is set to 0, the shift amount is taken from another register (RS). If Imm? is set to 1, the shift amount is taken from an immediate value.

Flags modified:

| Zero |Op specific|
|:----:|:--------:|
| x           |          |

### Compare:

Op mnemonic: `cmp`

<table>
    <tr>
        <th>0</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th><th>7</th>
        <th>8</th><th>9</th><th>A</th><th>B</th><th>C</th><th>D</th><th>E</th><th>F</th>
    </tr>
    <tr>
        <th colspan="1">1</th>
        <th colspan="1">1</th>
        <th colspan="1">1</th>
        <th colspan="1">1</th>
        <th colspan="4">RS1</th>
        <th colspan="4">RS2</th>
        <th colspan="4">Nop?</th>
    </tr>
</table>

| Effect             |
|--------------------|
| Nop?==0: Flags <= RS1 - RS2 |
| Nop?==0b1111: Nop |

Details: Compares two registers by subtracting them and updates the flags, without storing the result. If the Nop? field is set to 0, the flags are updated based on the result of the subtraction. If Nop? is set to 0b1111, the instruction does nothing (acts as a NOP).

Flags modified: 

| Zero |Op specific|
|:----:|:--------:|
| x        | x        |



// Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
//
// This Source Code Form is subject to the terms of
// the Mozilla Public License version 2.0 and additional exceptions,
// more details in file LICENSE, LICENSE.additional and CONTRIBUTING.

// Volume 1: Basic Architecture
// 3.4.1 General-Purpose Registers
#[derive(Debug, Clone, Copy)]
pub enum Register {
    // general purpose
    AL,
    AH,
    AX,
    EAX,
    RAX,
    BL,
    BH,
    BX,
    EBX,
    RBX,
    CL,
    CH,
    CX,
    ECX,
    RCX,
    DL,
    DH,
    DX,
    EDX,
    RDX,
    SIL,
    SI,
    ESI,
    RSI,
    DIL,
    DI,
    EDI,
    RDI,
    BPL,
    BP,
    EBP,
    RBP,
    SPL,
    SP,
    ESP,
    RSP,

    // instruction pointer
    IP,
    EIP,
    RIP,

    // 64-bit mode
    R8B,
    R8W,
    R8D,
    R8,
    R9B,
    R9W,
    R9D,
    R9,
    R10B,
    R10W,
    R10D,
    R10,
    R11B,
    R11W,
    R11D,
    R11,
    R12B,
    R12W,
    R12D,
    R12,
    R13B,
    R13W,
    R13D,
    R13,
    R14B,
    R14W,
    R14D,
    R14,
    R15B,
    R15W,
    R15D,
    R15,

    // flags
    FLAGS,
    EFLAGS,
    RFLAGS,

    // AVX
    XMM0,
    YMM0,
    ZMM0,
    XMM1,
    YMM1,
    ZMM1,
    XMM2,
    YMM2,
    ZMM2,
    XMM3,
    YMM3,
    ZMM3,
    XMM4,
    YMM4,
    ZMM4,
    XMM5,
    YMM5,
    ZMM5,
    XMM6,
    YMM6,
    ZMM6,
    XMM7,
    YMM7,
    ZMM7,
    XMM8,
    YMM8,
    ZMM8,
    XMM9,
    YMM9,
    ZMM9,
    XMM10,
    YMM10,
    ZMM10,
    XMM11,
    YMM11,
    ZMM11,
    XMM12,
    YMM12,
    ZMM12,
    XMM13,
    YMM13,
    ZMM13,
    XMM14,
    YMM14,
    ZMM14,
    XMM15,
    YMM15,
    ZMM15,
    XMM16,
    YMM16,
    ZMM16,
    XMM17,
    YMM17,
    ZMM17,
    XMM18,
    YMM18,
    ZMM18,
    XMM19,
    YMM19,
    ZMM19,
    XMM20,
    YMM20,
    ZMM20,
    XMM21,
    YMM21,
    ZMM21,
    XMM22,
    YMM22,
    ZMM22,
    XMM23,
    YMM23,
    ZMM23,
    XMM24,
    YMM24,
    ZMM24,
    XMM25,
    YMM25,
    ZMM25,
    XMM26,
    YMM26,
    ZMM26,
    XMM27,
    YMM27,
    ZMM27,
    XMM28,
    YMM28,
    ZMM28,
    XMM29,
    YMM29,
    ZMM29,
    XMM30,
    YMM30,
    ZMM30,
    XMM31,
    YMM31,
    ZMM31,

    // control registers
    CR0,
    CR2,
    CR3,
    CR4,
    CR8,

    // system table pointer registers
    GDTR,
    LDTR,
    IDTR,
    TR,

    // debug registers
    DR0,
    DR1,
    DR2,
    DR3,
    DR4,
    DR5,
    DR6,
    DR7,

    // legacy
    // segment registers (code, data, stack, dest strings)
    CS,
    DS,
    SS,
    ES,
    // segment registers avaliable in 64-bit mode
    FS,
    GS,

    // legacy
    // x87 fpu, 80-bit
    ST,
    ST0,
    ST1,
    ST2,
    ST3,
    ST4,
    ST5,
    ST6,
    ST7,

    // legacy
    // mmx, 64-bit
    MM0,
    MM1,
    MM2,
    MM3,
    MM4,
    MM5,
    MM6,
    MM7,

    // other
    //
    // TR3, TR4, TR5, TR6, TR7,
    // XCR, MSR, PMC,

    // mask registers
    K0,
    K1,
    K2,
    K3,
    K4,
    K5,
    K6,
    K7,

    // bounds registers
    // see Volumn 1
    // E.3.1 Detection and Enumeration of Intel MPX Interfaces
    BND0,
    BND1,
    BND2,
    BND3,
}

impl From<&str> for Register {
    fn from(value: &str) -> Self {
        match value {
            "AL" => Register::AL,
            "AX" => Register::AX,
            "EAX" => Register::EAX,
            "RAX" => Register::RAX,
            _ => todo!(),
        }
    }
}

#[derive(Debug, Clone, Copy)]
// 64-bit mode registers
// - https://en.wikipedia.org/wiki/X86#x86_registers
// - The Manual, CHAPTER 3 BASIC EXECUTION ENVIRONMENT
pub enum RegisterType {
    General, // A,C,D,B,SP,BP,SI,DI,R8..15 (16/32/64 bits)
    X87FPU,  // ST0..7 (32-bit)
    MMX,     // MM0..MM7 (64-bit)
    AVX,     // XMM0..15 (128-bit)/YMM0..15 (256-bit)/ZMM0..31 (512-bit)
    Segment, // CS, DS, SS, ES, FS, GS (16-bit)
    Control, // CR0, CR2, CR3, CR4, CR8 (64-bit)
    Debug,   // DR0..DR15 (64-bit)

    Bound, // BND0..BND3
    Mask,  // K0..K7

           // SystamTablePointer,  // GDTR, LDRT, IDTR, TR (16-bit)
           // RFlags,              // Flags, EFlags, RFlags
           // RDX_RAX              // RDX:RAX (128-bit)
}

#[derive(Debug, Clone, Copy)]
pub enum OperandSize {
    Undefined,
    Byte,  // 8-Bit, byte
    Word,  // 16-Bit, intel word
    DWord, // 32-Bit, intel dword
    QWord, // 64-Bit, intel qword
    XMM,   // 128-Bit, xmm
    YMM,   // 256-Bit, ymm
    ZMM,   // 512-Bit, zmm
    Far16, // segment:offset, e.g. m16:16 = 32
    Far32, // segment:offset, e.g. m16:32 = 48
    Far64, // segment:offset, e.g. m16:64 = 80
}

impl From<i32> for OperandSize {
    fn from(value: i32) -> Self {
        match value {
            8 => OperandSize::Byte,
            16 => OperandSize::Word,
            32 => OperandSize::DWord,
            64 => OperandSize::QWord,
            128 => OperandSize::XMM,
            256 => OperandSize::YMM,
            512 => OperandSize::ZMM,
            _ => panic!("Unsupported operand size"),
        }
    }
}

impl OperandSize {
    pub fn from_far(value: i32) -> Self {
        match value {
            16 => OperandSize::Far16,
            32 => OperandSize::Far32,
            64 => OperandSize::Far64,
            _ => unreachable!(),
        }
    }
}

// Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
//
// This Source Code Form is subject to the terms of
// the Mozilla Public License version 2.0 and additional exceptions,
// more details in file LICENSE, LICENSE.additional and CONTRIBUTING.

use std::{cell::OnceCell, collections::HashMap};

use ason::{AsonNode, ParseError};
use regex::Regex;

use crate::types::{OperandSize, Register, RegisterType};

const REGEX_INST_PARAMS: OnceCell<Vec<(&str, Regex)>> = OnceCell::new();

#[derive(Debug, Clone)]
enum InstructionParameter {
    Register(RegisterType, OperandSize), // r8, r16, r32, ...
    Memory(OperandSize),                 // m8, m16, m32, ...
    Immediate(OperandSize),              // imm8, imm16, imm32, ...
    Offset(OperandSize),                 // moffs8, moffs16, moffs32, ...
    FixedRegister(Register),             // AL, AX, EAX, RAX, ...

    // m32bcst, m64bcst, m32bcst{er}, m64bcst{er}.
    //
    // e.g.
    // `VPANDN ymm1 {k1}{z}, xmm2, m32bcst``
    // - ymm1 is the destination vector register (512 bits wide).
    // - xmm2 is a source vector register (128 bits wide).
    // - m32bcst indicates that a 32-bit value will be loaded from memory and broadcast across all elements of ymm1.
    //
    // - "{er}" represents the extended register size (512 bits in the AVX-512 instruction set)
    // - "{sae}" This optional operand stands for "SAE" (suppression of underflow-caused exceptions).
    //   If set to 1, underflow exceptions (when the result is too small to represent accurately)
    //   are not signaled. Denormal inputs (very small non-zero values) are
    //   treated as zeros without generating a Divide-By-Zero exception.
    // - "{k1}" This is an optional writemask operand. It's a 64-bit register that controls
    //   which elements of zmm1 are written to. Elements where the corresponding bit in k1
    //   is set to 1 will be updated, while others will remain unchanged.
    // - "{z}" This is an optional zeroing operand. If set to 1 (z), all elements of zmm1
    //   will be set to zero before the calculation. Otherwise,
    //   the existing values in zmm1 are used.
    Broadcast(OperandSize),

    // 'mib' represents a memory address that points to a Bound Table Entry (BTE).
    // This BTE contains the actual bound values.
    MIB,

    Rel(OperandSize),

    MultipleParameters(Vec<InstructionParameter>),
}

fn load_encoding_table() -> Result<AsonNode, ParseError> {
    let ason_text = include_str!("data/x86_64.ason");
    ason::parse(ason_text)
}

fn parse_encoding_records(records: &[AsonNode]) -> Result<(), ParseError> {
    /*
     * the encoding records:
     *
     * ```ason
     * [
     * (instruction, opcode, valid_64, valid_32, valid_16, features, operand1, operand2, operand3, operand4,)
     * ...
     * ]
     * ```
     *
     * the data types:
     *
     * - `instruction`: String
     * - `opcode`: String
     * - `valid_64`, `valid_32`, `valid_16`: Boolean
     * - `features`: Array<String>
     * - `operandN`: Option<String>
     *
     */

    let instruction_parameter_regex_list = generate_instruction_parameter_regex_list();

    for record in records {
        let fields = if let AsonNode::Tuple(t) = record {
            t
        } else {
            return Err(ParseError::new("Instruction encoding table error."));
        };

        // only parse instruction which is valid in 64-bit mode
        if !matches!(&fields[2], AsonNode::Boolean(true)) {
            continue;
        }

        let instruction_str = if let AsonNode::String_(s) = &fields[0] {
            s
        } else {
            return Err(ParseError::new("Instruction encoding table error."));
        };

        let opcode_str = if let AsonNode::String_(s) = &fields[1] {
            s
        } else {
            return Err(ParseError::new("Instruction encoding table error."));
        };

        if let Ok((mnemonic, params)) =
            parse_instruction_str(&instruction_parameter_regex_list, instruction_str)
        {
            // println!("OK INST: {}, PARAMS: {:?}", mnemonic, params);
        } else {
            println!("SKIP INST: {}, OPCODE: {}", instruction_str, opcode_str);
            break;
        }
    }

    Ok(())
}

fn generate_instruction_parameter_regex_list() -> Vec<(&'static str, Regex)> {
    let mut list = Vec::<(&str, Regex)>::new();

    list.push(("rm", Regex::new(r"^r/m(8|16|32|64)").unwrap()));
    list.push(("far", Regex::new(r"^m16:(16|32|64)").unwrap()));
    // list.push(("m_int", Regex::new(r"^m(8|16|32|64)int").unwrap())); // x87 fpu
    // list.push(("m_fp", Regex::new(r"^m(8|16|32|64)fp").unwrap())); // x87 fpu
    list.push((
        "boardcast",
        Regex::new(r"^m(32|64)bcst\s?(\{er\})?(\{sae\})?").unwrap(),
    ));
    list.push((
        "m",
        Regex::new(r"^m(8|16|32|64|128|256|512)\s?(\{er\})?(\{sae\})?").unwrap(),
    ));
    list.push(("imm", Regex::new(r"^imm(8|16|32|64)").unwrap()));
    list.push(("r", Regex::new(r"^r(8|16|32|64)([a-z])?").unwrap()));
    list.push(("r_fixed", Regex::new(r"^(AL|AX|EAX|RAX)").unwrap()));
    list.push(("r_bound", Regex::new(r"^bnd(\d)?").unwrap()));
    list.push(("r_mask", Regex::new(r"^k1 (\{k2\})?").unwrap()));
    list.push(("rel", Regex::new(r"^rel(8|16|32)").unwrap()));
    // list.push(("sti", Regex::new(r"^ST\(i\)").unwrap())); // x87 fpu
    // list.push(("st0", Regex::new(r"^(ST\(0\)|ST)").unwrap())); // x87 fpu
    // list.push(("mm", Regex::new(r"^mm\d?").unwrap())); // x87 fpu
    list.push(("xmm", Regex::new(r"^xmm\d?\s?(\{k1\})?(\{z\})?").unwrap()));
    list.push(("ymm", Regex::new(r"^ymm\d?\s?(\{k1\})?(\{z\})?").unwrap()));
    list.push(("zmm", Regex::new(r"^zmm\d?\s?(\{k1\})?(\{z\})?").unwrap()));
    list.push(("cr0_7", Regex::new(r"^CR0-CR7").unwrap()));
    list.push(("cr8", Regex::new(r"^CR8").unwrap()));
    list.push(("dr0-7", Regex::new(r"^DR0-DR7").unwrap()));
    list.push(("reg", Regex::new(r"^reg").unwrap()));
    list.push(("mib", Regex::new(r"^mib").unwrap()));

    list
}

fn parse_instruction_str(
    instruction_parameter_regex_list: &[(&str, Regex)],
    instruction_str: &str,
) -> Result<(String, Vec<InstructionParameter>), ParseError> {
    // instruction string examples:
    //
    // - "LEAVE"
    // - "MOV r64,imm64"
    // - "MOVSX r64, r/m16"
    // - "MOVSS xmm2/m32, xmm1"
    // - "VMAXPD zmm1 {k1}{z}, zmm2, zmm3/m512/m64bcst{sae}"

    // println!("------------------ PARSE INST: {}", instruction_str);

    let mnemonic_end_pos_opt = instruction_str.find(' ');
    let mnemonic_end_pos = if let Some(p) = mnemonic_end_pos_opt {
        p
    } else {
        return Ok((instruction_str.to_owned(), vec![]));
    };

    let (mnemonic, remains) = instruction_str.split_at(mnemonic_end_pos);
    let param_strs = remains.split(',').map(|s| s.trim()).collect::<Vec<&str>>();

    let mut inst_params = vec![];
    for param_str in param_strs {
        // exclude some implicit parameters, e.g.
        //
        // the "<XMM0>" in the following instructions:
        // - "BLENDVPD xmm1, xmm2/m128, <XMM0>"
        // - "BLENDVPS xmm1, xmm2/m128, <XMM0>"
        // - "PBLENDVB xmm1, xmm2/m128, <XMM0>"
        if param_str == "<XMM0>" {
            continue;
        }

        let inst_param = parse_instruction_param(instruction_parameter_regex_list, param_str)?;
        // println!("    PARAM STR: {}, VEC: {:?}", param_str, inst_param);
        inst_params.push(inst_param);
    }
    Ok((mnemonic.to_owned(), inst_params))
}

fn parse_instruction_param(
    regex_list: &[(&str, Regex)],
    param_str: &str,
) -> Result<InstructionParameter, ParseError> {
    let mut params = Vec::<InstructionParameter>::new();
    let mut remain = param_str;

    loop {
        let mut found = false;

        for (category, regex) in regex_list {
            let caps_opt = regex.captures(remain);
            if let Some(caps) = caps_opt {
                match category {
                    &"rm" => {
                        // - cap 1: operand size
                        let operand_size: OperandSize =
                            caps.get(1).unwrap().as_str().parse::<i32>().unwrap().into();
                        params.push(InstructionParameter::Register(
                            RegisterType::General,
                            operand_size,
                        ));
                        params.push(InstructionParameter::Memory(operand_size));
                    }
                    &"boardcast" => {
                        // - cap 1: operand size
                        // - cap 2: {er}
                        // - cap 3: {sae}
                        let operand_size: OperandSize =
                            caps.get(1).unwrap().as_str().parse::<i32>().unwrap().into();
                        params.push(InstructionParameter::Broadcast(operand_size));
                    }
                    &"m" => {
                        // - cap 1: operand size
                        let operand_size: OperandSize =
                            caps.get(1).unwrap().as_str().parse::<i32>().unwrap().into();
                        params.push(InstructionParameter::Memory(operand_size));
                    }
                    &"imm" => {
                        // - cap 1: operand size
                        let operand_size: OperandSize =
                            caps.get(1).unwrap().as_str().parse::<i32>().unwrap().into();
                        params.push(InstructionParameter::Immediate(operand_size));
                    }
                    &"far" => {
                        // - cap 1: operand size
                        let operand_size = OperandSize::from_far(
                            caps.get(1).unwrap().as_str().parse::<i32>().unwrap(),
                        );
                        params.push(InstructionParameter::Memory(operand_size));
                    }
                    &"r" => {
                        // - cap 1: operand size
                        let operand_size: OperandSize =
                            caps.get(1).unwrap().as_str().parse::<i32>().unwrap().into();
                        params.push(InstructionParameter::Register(
                            RegisterType::General,
                            operand_size,
                        ));
                    }
                    &"r_fixed" => {
                        // - cap 1: name of register
                        let reg: Register = caps.get(1).unwrap().as_str().into();
                        params.push(InstructionParameter::FixedRegister(reg));
                    }
                    &"r_bound" => {
                        params.push(InstructionParameter::Register(
                            RegisterType::Bound,
                            OperandSize::Undefined,
                        ));
                    }
                    &"r_mask" => {
                        params.push(InstructionParameter::Register(
                            RegisterType::Mask,
                            OperandSize::Undefined,
                        ));
                    }
                    &"rel" => {
                        // - cap 1: operand size
                        let operand_size: OperandSize =
                            caps.get(1).unwrap().as_str().parse::<i32>().unwrap().into();
                        params.push(InstructionParameter::Rel(operand_size));
                    }
                    &"xmm" => {
                        // - cap 1: {k1}, mask
                        // - cap 2: {z}, zero
                        params.push(InstructionParameter::Register(
                            RegisterType::AVX,
                            OperandSize::XMM,
                        ))
                    }
                    &"ymm" => {
                        // - cap 1: {k1}, mask
                        // - cap 2: {z}, zero
                        params.push(InstructionParameter::Register(
                            RegisterType::AVX,
                            OperandSize::YMM,
                        ))
                    }
                    &"zmm" => {
                        // - cap 1: {k1}, mask
                        // - cap 2: {z}, zero
                        params.push(InstructionParameter::Register(
                            RegisterType::AVX,
                            OperandSize::ZMM,
                        ))
                    }
                    &"mib" => {
                        params.push(InstructionParameter::MIB);
                    }
                    _ => {
                        println!(
                            "missing handle the match of instruction parameter: {}, category: {}",
                            remain, category
                        );

                        unreachable!()
                    }
                }

                // the remains of parameter string
                let mat = caps.get(0).unwrap();
                let end_pos = mat.end();
                remain = remain.split_at(end_pos).1.trim();
                found = true;
                break;
            }
        }

        if !found {
            let msg = format!("Unsupported instruction param: {}", remain);
            println!("{}", msg);
            return Err(ParseError::new(&msg));
        }

        if remain.starts_with('/') {
            // e.g.
            // "xmm2/m32"
            remain = remain.split_at(1).1;
        }

        if remain.is_empty() {
            break;
        }
    }

    if params.len() == 1 {
        let first = params.pop().unwrap();
        Ok(first)
    } else {
        Ok(InstructionParameter::MultipleParameters(params))
    }
}

#[cfg(test)]
mod tests {
    use ason::AsonNode;

    use crate::record_parser::{load_encoding_table, parse_encoding_records};

    #[test]
    fn test_load_encoding_table() {
        let s = load_encoding_table();
        let node = s.unwrap();
        assert!(matches!(node, AsonNode::Array(_)))
    }

    #[test]
    fn test_parse_encoding_records() {
        let s = load_encoding_table();
        let records = if let AsonNode::Array(rs) = s.unwrap() {
            rs
        } else {
            panic!()
        };

        parse_encoding_records(&records).unwrap();
    }
}

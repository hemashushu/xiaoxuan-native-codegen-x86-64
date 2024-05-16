// Copyright (c) 2024 Hemashushu <hippospark@gmail.com>, All rights reserved.
//
// This Source Code Form is subject to the terms of
// the Mozilla Public License version 2.0 and additional exceptions,
// more details in file LICENSE, LICENSE.additional and CONTRIBUTING.

use ason::{AsonNode, ParseError};

fn load_encoding_table() -> Result<AsonNode, ParseError> {
    let ason_text = include_str!("data/x86_64.ason");
    ason::parse(ason_text)
}

fn parse_encoding_records(records: &[AsonNode]) -> Result<(), ParseError> {
    for record in records {
        let tuple = if let AsonNode::Tuple(t) = record {
            t
        } else {
            return Err(ParseError::new("Instruction encoding table error."));
        };

        let instruction_str = if let AsonNode::String_(s) = &tuple[0] {
            s.to_owned()
        } else {
            return Err(ParseError::new("Instruction encoding table error."));
        };

        let opcode_str = if let AsonNode::String_(s) = &tuple[1] {
            s.to_owned()
        } else {
            return Err(ParseError::new("Instruction encoding table error."));
        };

        println!("{} :: {}", instruction_str, opcode_str);
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use ason::AsonNode;

    use crate::{load_encoding_table, parse_encoding_records};

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

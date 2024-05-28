## x86_64.ason

`x86_64` instruction encoding table in ASON format.

```ason
[
(instruction, opcode, valid_64, valid_32, valid_16, features, operand1, operand2, operand3, operand4,)
...
]
```

The data types:
- `instruction`: String
- `opcode`: String
- `valid_64`, `valid_32`, `valid_16`: Boolean
- `features`: Array<String>
- `operandN`: Option<String>

See also:
- https://github.com/hemashushu/x86_encoding_ason
- https://github.com/StanfordPL/x64asm/blob/develop/SPREADSHEET.md
- http://ref.x86asm.net/coder64.html
- http://ref.x86asm.net/coder64-abc.html

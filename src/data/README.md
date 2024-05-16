## x86_64.ason

`x86_64` instruction encoding table in ASON format.

```ason
[
(instruction, opcode, operand1, operand2, operand3, operand4,)
...
]
```

Both `instruction` and `opcode` are `String`, and `operandN` are `Option<String>`.

See also:
- https://github.com/hemashushu/x86_encoding_ason
- https://github.com/StanfordPL/x64asm/blob/develop/SPREADSHEET.md
- http://ref.x86asm.net/coder64.html
- http://ref.x86asm.net/coder64-abc.html
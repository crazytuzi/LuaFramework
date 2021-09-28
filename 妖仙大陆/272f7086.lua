









local dis_x86 = require((string.match(..., ".*%.") or "").."dis_x86")
return {
  create = dis_x86.create64,
  disass = dis_x86.disass64,
  regname = dis_x86.regname64
}

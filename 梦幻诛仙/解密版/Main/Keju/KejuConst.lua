local cfg = {}
local KeJuState = require("netio.protocol.mzm.gsp.question.KeJuState")
cfg.ExamType = {
  XIANG_SHI = KeJuState.XIANGSHI,
  HUI_SHI = KeJuState.HUISHI,
  DIAN_SHI = KeJuState.DIANSHI
}
cfg.UIType = {
  QUESTION = 1,
  RESULT = 2,
  LEFTTIME = 3,
  WORDQUESTION = 4
}
cfg.ExamStatus = {
  OPEN = KeJuState.START,
  NOTOPEN = KeJuState.NOT_START,
  DENY = KeJuState.CAN_NOT_ACCESS,
  FINISH = KeJuState.END
}
return cfg

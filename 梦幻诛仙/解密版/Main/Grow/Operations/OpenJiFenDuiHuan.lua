local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenJiFenDuiHuan = Lplus.Extend(Operation, CUR_CLASS_NAME)
local def = OpenJiFenDuiHuan.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  local TokenType = require("consts.mzm.gsp.item.confbean.TokenType")
  Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.CREDITS_SHOP, {
    TokenType.JINGJICHANG_JIFEN
  })
  return false
end
return OpenJiFenDuiHuan.Commit()

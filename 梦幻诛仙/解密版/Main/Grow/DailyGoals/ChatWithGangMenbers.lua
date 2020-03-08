local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local BaseGoal = import(".BaseGoal")
local ChatWithGangMenbers = Lplus.Extend(BaseGoal, CUR_CLASS_NAME)
local def = ChatWithGangMenbers.define
def.override("=>", "boolean").Go = function(self)
  if self:HasGang() then
    require("Main.Chat.ui.ChannelChatPanel").ShowChannelChatPanel(2, 2)
  else
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_GANG_CLICK, nil)
    return false
  end
end
def.method("=>", "boolean").HasGang = function(self)
  return require("Main.Gang.GangModule").Instance():HasGang()
end
return ChatWithGangMenbers.Commit()

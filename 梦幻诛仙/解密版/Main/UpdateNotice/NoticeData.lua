local MODULE_NAME = (...)
local Lplus = require("Lplus")
local NoticeData = Lplus.Class(MODULE_NAME)
local def = NoticeData.define
def.const("table").NoticeType = {
  SINGLE_UI_BANNER = 1,
  INNER_BANNER = 2,
  UNIQUE_BANNER = 3,
  NORMAL = 4
}
def.const("table").PopupPeriod = {DAILY_FIRST_LOGIN = 1, LOGIN = 2}
def.const("table").LinkType = {
  NONE = 1,
  URL = 2,
  JUMP = 3
}
def.const("table").TagType = {
  None = 1,
  Notice = 2,
  Welfare = 3,
  Discount = 4
}
def.const("table").SendType = {Alert = 1, Mail = 2}
def.field("string").id = ""
def.field("number").type = 0
def.field("string").title = ""
def.field("string").content = ""
def.field("string").url = ""
def.field("table").picArray = nil
def.field("number").sortId = 0
def.field("number").hrefType = 0
def.field("string").hrefText = ""
def.field("number").sendType = 0
def.field("string").pictureUrl = ""
def.field("number").tag = 0
def.field("boolean").badge = false
def.field("userdata").startTime = nil
def.field("userdata").endTime = nil
def.field("number").popupPeriod = 0
def.field("table").displayConds = nil
def.method("=>", "boolean").HasExternalLink = function(self)
  if self.hrefType == NoticeData.LinkType.NONE then
    return false
  end
  return #self.url > 3
end
def.method("=>", "boolean").HasPicInfo = function(self)
  if self.picArray and #self.picArray > 0 then
    return true
  end
  return false
end
return NoticeData.Commit()

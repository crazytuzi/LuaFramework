local ChatContent = require("netio.protocol.mzm.gsp.chat.ChatContent")
local STeamMatchBro = class("STeamMatchBro")
STeamMatchBro.TYPEID = 12593684
function STeamMatchBro:ctor(content)
  self.id = 12593684
  self.content = content or ChatContent.new()
end
function STeamMatchBro:marshal(os)
  self.content:marshal(os)
end
function STeamMatchBro:unmarshal(os)
  self.content = ChatContent.new()
  self.content:unmarshal(os)
end
function STeamMatchBro:sizepolicy(size)
  return size <= 65535
end
return STeamMatchBro

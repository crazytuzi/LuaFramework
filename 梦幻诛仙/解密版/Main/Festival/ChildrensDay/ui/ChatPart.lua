local Lplus = require("Lplus")
local ChatPart = Lplus.Class("ChatPart")
local def = ChatPart.define
local instance
local GUIUtils = require("GUI.GUIUtils")
local ChildrensDayMgr = require("Main.Festival.ChildrensDay.ChildrensDayMgr")
local ChatMsgBuilder = require("Main.Chat.ChatMsgBuilder")
local ENUM_MSG_TYPE = {
  SYSTEM = 1,
  NORMAL = 2,
  MYSELF = 3
}
def.field("userdata")._panel = nil
def.field("table")._uiGOs = nil
def.field("table")._arrMsgs = nil
def.field("table")._roles = nil
def.field("table")._roleId2Rolesinfo = nil
def.field("table")._sendMsgQueue = nil
def.field("userdata")._myRoleId = nil
local ENUM_COLOR = {SYS = "#4f3018", PLAYER = "#00ffff"}
def.static("=>", ChatPart).Instance = function()
  if instance == nil then
    instance = ChatPart()
  end
  return instance
end
def.method("userdata", "table").OnCreate = function(self, panel, roles)
  self._uiGOs = {}
  self._arrMsgs = {}
  self._sendMsgQueue = {}
  self._panel = panel
  local ctrlRoot = self._panel:FindDirect("Img_Bg0/Group_BgChat/Group_Input")
  self._uiGOs.scrollView = self._panel:FindDirect("Img_Bg0/Group_BgChat/Scrollview")
  self._uiGOs.lblInput = ctrlRoot:FindDirect("Img_BgInput/Label_Input")
  self._uiGOs.btnEmoj = ctrlRoot:FindDirect("Btn_Add")
  self._uiGOs.btnEmoj:SetActive(false)
  self._uiGOs.comInput = ctrlRoot:FindDirect("Img_BgInput"):GetComponent("UIInput")
  GUIUtils.SetText(self._uiGOs.lblInput, textRes.Festival.ChildrensDay[11])
  self._uiGOs.ctrlMsg = self._panel:FindDirect("Img_Bg0/Group_BgChat/Scrollview/Drag_Chat"):GetComponent("UILabel")
  local iniContent = ""
  for i = 1, 9 do
    iniContent = iniContent .. "\n"
  end
  self._uiGOs.ctrlMsg:set_text(iniContent)
  self._roles = roles
  self._roleId2Rolesinfo = ChildrensDayMgr.TransArr2Tbl(roles)
  self._myRoleId = require("Main.Hero.HeroModule").Instance():GetHeroProp().id
  Event.RegisterEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.RCV_ANSWER, ChatPart.OnRcvMsg)
  Event.RegisterEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.SEND_MSG_SUCCESS, ChatPart.OnSendMsgSuccess)
  Event.RegisterEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.SEND_MSG_FAILED, ChatPart.OnSendMsgFailed)
end
def.method().OnDestroy = function(self)
  self._panel = nil
  self._uiGOs = nil
  self._arrMsgs = nil
  self._roles = nil
  self._roleId2Rolesinfo = nil
  self._sendMsgQueue = nil
  self._myRoleId = nil
  Event.UnregisterEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.RCV_ANSWER, ChatPart.OnRcvMsg)
  Event.UnregisterEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.SEND_MSG_SUCCESS, ChatPart.OnSendMsgSuccess)
  Event.UnregisterEvent(ModuleId.FESTIVAL, gmodule.notifyId.Festival.ChildrensDay.SEND_MSG_FAILED, ChatPart.OnSendMsgFailed)
end
def.method("string", "=>", "boolean").onClick = function(self, id)
  if id == "Label_Input" then
    self:OnLblInputClick()
    return true
  elseif id == "Btn_Send" then
    self:OnBtnSendClick()
    return true
  elseif id == "Btn_Menu" then
    self:OnBtnMenuClick()
  elseif id == "Btn_Add" then
    self:OnBtnEmojClick()
    return true
  elseif id == "Input_Clear" then
    self._uiGOs.comInput:set_value("")
    return true
  end
  return false
end
def.method().OnLblInputClick = function(self)
end
def.method().OnBtnEmojClick = function(self)
end
local NameFilter = require("Main.Common.NameValidator")
local ChatUtils = require("Main.Chat.ChatUtils")
def.method().OnBtnSendClick = function(self)
  if not self._uiGOs.comInput.enabled then
    GUIUtils.SetText(self._uiGOs.lblInput, textRes.Festival.ChildrensDay[26])
  end
  local msg = self._uiGOs.comInput:get_value()
  self._uiGOs.comInput:set_value("")
  if msg == nil or msg == "" or msg == " " then
    Toast(textRes.Festival.ChildrensDay[27])
    return
  end
  msg = ChatMsgBuilder.CustomFilter(msg)
  msg = _G.TrimIllegalChar(msg)
  msg = ChatUtils.ChatContentTrim(msg)
  warn("msg = " .. (msg or ""))
  if msg == nil or msg == "" or msg == " " then
    Toast(textRes.Festival.ChildrensDay[27])
    return
  end
  local wordLen = NameFilter.Instance():GetWordNum(GameUtil.Utf8ToUnicode(msg))
  local charaLimit = self._uiGOs.comInput:get_characterLimit()
  warn("charaLimit", charaLimit)
  if wordLen > charaLimit then
    Toast(textRes.Festival.ChildrensDay[30])
    return
  end
  self:SendMsg(msg)
  table.insert(self._sendMsgQueue, msg)
end
def.method().OnBtnMenuClick = function(self)
end
def.method("string", "userdata").onSubmit = function(self, id, ctrl)
  warn(">>>input ctrl id = " .. id)
  if id == "Img_BgInput" then
    self:OnBtnSendClick()
  end
end
def.method("string").SendMsg = function(self, msg)
  if msg == nil or msg == "" then
    return
  end
  ChildrensDayMgr.SendAnswerReq(msg)
end
def.static("table", "table").OnRcvMsg = function(p, context)
  local self = ChatPart.Instance()
  if self._panel == nil then
    return
  end
  local roleInfo = self._roleId2Rolesinfo[p.roleId:tostring()]
  warn("------rcv msg roleName=" .. roleInfo.roleName, " result=" .. tostring(p.result))
  if p.result then
    roleInfo.result = true
    local msg = textRes.Festival.ChildrensDay[15]:format(roleInfo.roleName)
    self:AddSystemMsg(msg, p.roleId)
  elseif p.roleId == self._myRoleId then
    ChatPart.OnSendMsgSuccess(p)
  else
    local msg = string.format(textRes.Festival.ChildrensDay[17], roleInfo.roleName, p.answer)
    self:AddPlayerMsg(msg, p.roleId)
  end
  for i = 1, #self._roles do
    warn(">>>>>result = " .. tostring(self._roles[i].result))
  end
end
def.method("string", "userdata").AddSystemMsg = function(self, msg, roleId)
  self:_addMsg(msg, ENUM_MSG_TYPE.SYSTEM)
end
def.method("string", "userdata").AddPlayerMsg = function(self, msg, roleId)
  self:_addMsg(msg, ENUM_MSG_TYPE.NORMAL)
end
def.method("string").AddMySelfMsg = function(self, msg)
  self:_addMsg(msg, ENUM_MSG_TYPE.MYSELF)
end
def.method("string", "number")._addMsg = function(self, msg, msgType)
  local tblmsg = {}
  msg = ChatMsgBuilder.CustomFilter(msg)
  msg = _G.TrimIllegalChar(msg)
  if msg == nil or msg == "" then
    return
  end
  tblmsg.content = msg
  tblmsg.type = msgType
  local mainHtml = ""
  if msgType == ENUM_MSG_TYPE.SYSTEM then
    mainHtml = string.format(textRes.Festival.ChildrensDay[14], ENUM_COLOR.SYS, tblmsg.content)
  elseif msgType == ENUM_MSG_TYPE.PLAYER then
    mainHtml = string.format(textRes.Festival.ChildrensDay[14], ENUM_COLOR.PLAYER, tblmsg.content)
  elseif msgType == ENUM_MSG_TYPE.MYSELF then
    mainHtml = string.format(textRes.Festival.ChildrensDay[14], ENUM_COLOR.PLAYER, tblmsg.content)
  end
  local lblContent = self._uiGOs.ctrlMsg:get_text()
  lblContent = lblContent .. tblmsg.content .. "\n"
  warn(">>>>msg =" .. mainHtml)
  self._uiGOs.ctrlMsg:set_text(lblContent)
  local widget = self._uiGOs.ctrlMsg:GetComponent("UIWidget")
  self._uiGOs.scrollView:GetComponent("UIScrollView"):SetDragAmount(0, 1, false)
end
def.method().InitMsgView = function(self)
end
def.method("string", "=>", "table").GetSenstiveChars = function(self, str)
  local res = {}
  local strLen = _G.StrLen(str)
  for i = 1, strLen do
    table.insert(res, str[i])
  end
  return res
end
def.method("boolean").EnableChat = function(self, bEnable)
  self._uiGOs.comInput:RemoveFocus()
  self._uiGOs.comInput.enabled = bEnable
  if bEnable then
    GUIUtils.SetText(self._uiGOs.lblInput, textRes.Festival.ChildrensDay[11])
    self._uiGOs.comInput:set_defaultText(textRes.Festival.ChildrensDay[11])
  else
    GUIUtils.SetText(self._uiGOs.lblInput, textRes.Festival.ChildrensDay[26])
    self._uiGOs.comInput:set_defaultText(textRes.Festival.ChildrensDay[26])
  end
end
def.static("table", "table").OnSendMsgSuccess = function(p, c)
  local self = ChatPart.Instance()
  if self._panel == nil then
    return
  end
  local msg = ""
  local HINTS = textRes.Festival.ChildrensDay
  if self._sendMsgQueue ~= nil and #self._sendMsgQueue ~= 0 then
    local inputMsg = self._sendMsgQueue[1]
    msg = HINTS[18]:format(inputMsg)
    warn("...mysend msg =" .. inputMsg)
    table.remove(self._sendMsgQueue, 1)
  end
  if p.result then
    msg = msg .. "\n" .. HINTS[16]:format(HINTS[23])
    local myRoleInfo = self._roleId2Rolesinfo[self._myRoleId:tostring()]
    myRoleInfo.result = true
  end
  self:AddMySelfMsg(msg)
end
def.static("table", "table").OnSendMsgFailed = function(p, c)
  local self = ChatPart.Instance()
  if self._sendMsgQueue ~= nil and #self._sendMsgQueue ~= 0 then
    table.remove(self._sendMsgQueue, 1)
  end
  if p.state == 10 then
    Toast(textRes.Festival.ChildrensDay[24])
  elseif p.state == 11 then
    Toast(textRes.Festival.ChildrensDay[25])
  end
end
return ChatPart.Commit()

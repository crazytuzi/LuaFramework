local Lplus = require("Lplus")
local FriendModule = Lplus.ForwardDeclare("FriendModule")
local ECPanelBase = require("GUI.ECPanelBase")
local Vector = require("Types.Vector")
local FriendTestDlg = Lplus.Extend(ECPanelBase, "FriendTestDlg")
local FriendTestValidator = require("Main.friend.FriendTestValidator")
local FriendUtils = require("Main.friend.FriendUtils")
local def = FriendTestDlg.define
def.field("userdata")._testId = nil
def.field("string")._testTittle = ""
def.field("function")._callback = nil
def.field("table")._tag = nil
local instance
def.static("=>", FriendTestDlg).Instance = function()
  if instance == nil then
    instance = FriendTestDlg()
  end
  return instance
end
def.override().OnCreate = function(self)
  self:UpdateInfo()
end
def.static("userdata", "string", "function", "table").ShowTest = function(friendId, tittle, callback, tag)
  local testDlg = FriendTestDlg.Instance()
  testDlg._testId = friendId
  testDlg._testTittle = tittle
  testDlg._callback = callback
  testDlg._tag = tag
  if testDlg:IsShow() then
    testDlg:UpdateTittle()
    testDlg:UpdataInput()
  else
    testDlg:CreatePanel(RESPATH.PREFAB_FRIEND_TEST_PANEL, 2)
  end
end
def.method().UpdateInfo = function(self)
  self:UpdateTittle()
  self:UpdataInput()
end
def.method().UpdateTittle = function(self)
  self.m_panel:FindDirect("Label_Descibe"):GetComponent("UILabel"):set_text(self._testTittle)
end
def.method().UpdataInput = function(self)
  local Img_BgInput = self.m_panel:FindDirect("Img_BgFriendTest/Img_BgInput"):GetComponent("UIInput")
  local max = FriendUtils.GetValidateWordsMax()
  Img_BgInput:set_characterLimit(0)
end
def.method("string", "string").onTextChange = function(self, id, val)
  local Img_BgInput = self.m_panel:FindDirect("Img_BgFriendTest/Img_BgInput"):GetComponent("UIInput")
  if Img_BgInput:get_isSelected() then
    local val = Img_BgInput:get_value()
    local max = FriendUtils.GetValidateWordsMax()
    FriendTestValidator.Instance():SetCharacterNum(0, max)
    local b, _, len = FriendTestValidator.Instance():IsValid(val)
    if max < len then
      Toast(string.format(textRes.Gang[95], max))
      local real = FriendTestValidator.Instance():GetWordMaxVal(val)
      Img_BgInput:set_value(real)
    end
  end
end
def.method("string").OnSendMsgClick = function(self, content)
  local isValid = FriendUtils.ValidEnteredName(content)
  if false == isValid then
    return
  end
  self._callback(self._testId, content, self._tag)
  self:Hide()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Confirm" then
    local content = self.m_panel:FindDirect("Img_BgFriendTest/Img_BgInput"):GetComponent("UIInput"):get_value()
    if "" == content then
      content = textRes.Friend[6]
    end
    self:OnSendMsgClick(content)
  elseif id == "Btn_Cancel" then
    self:Hide()
  elseif id == "Btn_Close" then
    self:Hide()
  end
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
FriendTestDlg.Commit()
return FriendTestDlg

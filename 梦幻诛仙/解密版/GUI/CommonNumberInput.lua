local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECGUIMan = require("GUI.ECGUIMan")
local CommonNumberInput = Lplus.Extend(ECPanelBase, "CommonNumberInput")
local Vector3 = require("Types.Vector3").Vector3
local def = CommonNumberInput.define
local instance
def.static("=>", CommonNumberInput).Instance = function()
  if instance == nil then
    instance = CommonNumberInput()
  end
  return instance
end
def.field("number").curNum = 0
def.field("number").step = 1
def.field("string").title = ""
def.field("string").desc = ""
def.field("function").callback = nil
def.static("number", "number", "string", "string", "function").ShowNumberInput = function(num, step, title, desc, callback)
  if step < 0 then
    warn("Param [step] should not less than Zero")
    return
  end
  if num < 0 then
    warn("Param [num] should not less than Zero")
    return
  end
  local dlg = CommonNumberInput.Instance()
  if dlg.m_created then
    dlg:Close()
  end
  dlg.curNum = num
  dlg.step = step
  dlg.title = title
  dlg.desc = desc
  dlg.callback = callback
  dlg:CreatePanel(RESPATH.PREFAB_NUMBERINPUT, 2)
end
def.override().OnCreate = function(self)
  self:UpdateText()
  self:UpdateNumber()
end
def.override().OnDestroy = function(self)
end
def.method().UpdateText = function(self)
  local Lbltitle = self.m_panel:FindDirect("Img_0/Label_Title")
  local lblCmp = Lbltitle:GetComponent("UILabel")
  lblCmp:set_text(self.title)
  local Lbldesc = self.m_panel:FindDirect("Img_0/Label_Description")
  local lblCmp2 = Lbldesc:GetComponent("UILabel")
  lblCmp2:set_text(self.desc)
end
def.method().UpdateNumber = function(self)
  local lblNum = self.m_panel:FindDirect("Img_0/Img_BgNumber/Label_Number")
  local lblCmp = lblNum:GetComponent("UILabel")
  lblCmp:set_text(tostring(self.curNum))
end
def.method().Plus = function(self)
  self.curNum = self.curNum + self.step
  self:UpdateNumber()
end
def.method().Minus = function(self)
  self.curNum = self.curNum - self.step
  self.curNum = self.curNum >= 0 and self.curNum or 0
  self:UpdateNumber()
end
def.method().Close = function(self)
  self:DestroyPanel()
  self:DoCallback(false, self.curNum)
end
def.static("number", "table").OnKeyBoardInput = function(value, tag)
  local self = tag.self
  self.curNum = value
  self:UpdateNumber()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:Close()
  elseif id == "Btn_Plus" then
    self:Plus()
  elseif id == "Btn_Minus" then
    self:Minus()
  elseif id == "Label_Number" then
    local CommonDigitalKeyboard = require("GUI.CommonDigitalKeyboard")
    CommonDigitalKeyboard.Instance():ShowPanelEx(-1, CommonNumberInput.OnKeyBoardInput, {self = self})
    CommonDigitalKeyboard.Instance():SetPos(300, 0)
  elseif id == "Btn_Confirm" then
    self:DestroyPanel()
    self:DoCallback(true, self.curNum)
  end
end
def.method("boolean", "number").DoCallback = function(self, confirm, num)
  if self.callback then
    self.callback(confirm, num)
  end
end
return CommonNumberInput.Commit()

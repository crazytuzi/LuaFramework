local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECGUIMan = require("GUI.ECGUIMan")
local CommonDigitalKeyboard = Lplus.Extend(ECPanelBase, "CommonDigitalKeyboard")
local Vector3 = require("Types.Vector3").Vector3
local def = CommonDigitalKeyboard.define
def.field("function").callback = nil
def.field("table").tag = nil
def.field("table").pos = nil
def.field("boolean").isConfirm = false
def.field("number")._maxValue = -1
def.field("number").mode = 0
def.field("number")._enteredValue = 0
local instance
def.static("=>", CommonDigitalKeyboard).Instance = function()
  if instance == nil then
    instance = CommonDigitalKeyboard()
  end
  return instance
end
def.method("number", "function", "table").ShowPanelEx = function(self, maxValue, callback, tag)
  self._maxValue = maxValue
  self.callback = callback
  self.tag = tag
  self.mode = 2
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_COMMON_DIGITAL_KEYBOARD_RES, 2)
  self:SetOutTouchDisappear()
end
def.method("number").SetEnteredValue = function(self, value)
  self._enteredValue = value
  if self._enteredValue > self._maxValue and self._maxValue > 0 then
    self._enteredValue = self._maxValue
  elseif self._enteredValue < 0 then
    self._enteredValue = 0
  end
end
def.method("function", "table").ShowPanel = function(self, callback, tag)
  self.callback = callback
  self.tag = tag
  self.mode = 1
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_COMMON_DIGITAL_KEYBOARD_RES, 2)
  self:SetOutTouchDisappear()
end
def.method().HidePanel = function(self)
  self:DestroyPanel()
end
def.override().OnCreate = function(self)
  self:UpdatePos()
end
def.override().OnDestroy = function(self)
  self:DoCallback("ENTER")
  self.callback = nil
  self.tag = nil
  self.pos = nil
  self.isConfirm = false
  self._maxValue = -1
  self._enteredValue = 0
end
def.method("number", "number").SetPos = function(self, x, y)
  if not self:IsShow() then
    self.pos = self.pos or {}
    self.pos.x = x
    self.pos.y = y
    return
  end
  self.m_panel:FindChild("Img_Bg0").transform.localPosition = Vector3.new(x, y, 0)
end
def.method().UpdatePos = function(self)
  if self.pos ~= nil then
    self.m_panel:FindChild("Img_Bg0").transform.localPosition = Vector3.new(self.pos.x, self.pos.y, 0)
  end
end
def.method("string").onClick = function(self, id)
  print(string.format("%s click event: id = %s", tostring(self), id))
  if id == "Btn_Confirm" then
    self:HidePanel()
  elseif id == "Btn_Delete" then
    self:DoCallback("DEL")
  elseif tonumber(string.sub(id, -1, -1)) ~= nil then
    self:DoCallback(string.sub(id, -1, -1))
  end
end
def.method("string").DoCallback = function(self, key)
  if self.callback == nil then
    return
  end
  if self.mode == 1 then
    self.callback(key, self.tag)
  elseif self.mode == 2 then
    self:DoCallback2(key)
  end
end
def.method("string").DoCallback2 = function(self, key)
  local value = self._enteredValue
  if key == "DEL" then
    value = math.floor(self._enteredValue / 10)
  elseif key == "ENTER" then
    return
  else
    local numeralValue = tonumber(key)
    value = self._enteredValue * 10 + numeralValue
  end
  self:SetEnteredValue(value)
  self.callback(self._enteredValue, self.tag)
end
return CommonDigitalKeyboard.Commit()

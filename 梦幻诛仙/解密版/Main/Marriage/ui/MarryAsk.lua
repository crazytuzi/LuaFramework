local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local MarryAsk = Lplus.Extend(ECPanelBase, "MarryAsk")
local GUIUtils = require("GUI.GUIUtils")
local def = MarryAsk.define
local _instance
def.static("=>", "table").Instance = function()
  if _instance == nil then
    _instance = MarryAsk()
  end
  return _instance
end
def.field("string").desc = ""
def.field("number").duration = 0
def.field("number").timer = 0
def.field("number").buttonNumber = 0
def.field("function").callback = nil
def.static("string", "number", "number", "function").ShowMarryAsk = function(desc, time, btnnum, cb)
  if time <= 0 or cb == nil or btnnum <= 0 then
    return
  end
  local dlg = MarryAsk.Instance()
  dlg.desc = desc
  dlg.duration = time
  dlg.buttonNumber = btnnum
  dlg.callback = cb
  dlg:CreatePanel(RESPATH.PREFAB_MARRY_CONFIRM, 1)
  dlg:SetModal(true)
end
def.static().Close = function()
  local dlg = MarryAsk.Instance()
  dlg:DestroyPanel()
end
def.override().OnCreate = function(self)
  local twoGroup = self.m_panel:FindDirect("Img_Bg/Group_Offer")
  local oneGroup = self.m_panel:FindDirect("Img_Bg/Group_Wait")
  if self.buttonNumber == 1 then
    twoGroup:SetActive(false)
    oneGroup:SetActive(true)
    do
      local lbl = oneGroup:FindDirect("Label_Wait"):GetComponent("UILabel")
      lbl:set_text(self.desc)
      local btn = oneGroup:FindDirect("Btn_Cancel/Label"):GetComponent("UILabel")
      local leftTime = self.duration
      btn:set_text(string.format(textRes.Marriage[1], leftTime))
      self.timer = GameUtil.AddGlobalTimer(1, false, function()
        leftTime = leftTime - 1
        if btn and not btn.isnil then
          btn:set_text(string.format(textRes.Marriage[1], leftTime))
        end
        if leftTime < 0 then
          GameUtil.RemoveGlobalTimer(self.timer)
          self.timer = 0
          if callback then
            callback(0)
          end
          self:DestroyPanel()
        end
      end)
    end
  elseif self.buttonNumber >= 2 then
    oneGroup:SetActive(false)
    twoGroup:SetActive(true)
    do
      local lbl = twoGroup:FindDirect("Label_Propose"):GetComponent("UILabel")
      lbl:set_text(self.desc)
      local btn = twoGroup:FindDirect("Btn_Cancel/Label"):GetComponent("UILabel")
      local leftTime = self.duration
      btn:set_text(string.format(textRes.Marriage[1], leftTime))
      self.timer = GameUtil.AddGlobalTimer(1, false, function()
        leftTime = leftTime - 1
        if btn and not btn.isnil then
          btn:set_text(string.format(textRes.Marriage[1], leftTime))
        end
        if leftTime < 0 then
          GameUtil.RemoveGlobalTimer(self.timer)
          self.timer = 0
          if self.callback then
            self.callback(0)
          end
          self:DestroyPanel()
        end
      end)
    end
  end
end
def.override().OnDestroy = function(self)
  GameUtil.RemoveGlobalTimer(self.timer)
  self.timer = 0
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Cancel" then
    GameUtil.RemoveGlobalTimer(self.timer)
    self.timer = 0
    if self.callback then
      self.callback(0)
    end
    self:DestroyPanel()
  elseif id == "Btn_Confirm" then
    GameUtil.RemoveGlobalTimer(self.timer)
    self.timer = 0
    if self.callback then
      self.callback(1)
    end
    self:DestroyPanel()
  end
end
MarryAsk.Commit()
return MarryAsk

local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local StepDlg = Lplus.Extend(ECPanelBase, "StepDlg")
local GUIUtils = require("GUI.GUIUtils")
local def = StepDlg.define
local _instance
def.static("=>", "table").Instance = function()
  if _instance == nil then
    _instance = StepDlg()
  end
  return _instance
end
def.field("table").steps = nil
def.field("boolean").switch = true
def.field("string").title = ""
def.field("number").tipId = 0
def.field("function").callback = nil
def.method("string", "table", "number", "function").ShowStepDlg = function(self, title, steps, tipId, cb)
  local dlg = StepDlg.Instance()
  if dlg:IsShow() then
    dlg:DestroyPanel()
  end
  dlg.title = title
  dlg.steps = steps
  dlg.tipId = tipId
  dlg.callback = cb
  dlg.switch = true
  dlg:SetDepth(GUIDEPTH.BOTTOM)
  dlg:CreatePanel(RESPATH.PREFAB_COMMONSTEP, 0)
end
def.method("table").SetStep = function(self, steps)
  local dlg = StepDlg.Instance()
  dlg.steps = steps
  if dlg:IsShow() then
    dlg:UpdateStep()
  end
end
def.method().CloseStepDlg = function(self)
  local dlg = StepDlg.Instance()
  dlg:DestroyPanel()
end
def.override().OnCreate = function(self)
  self:UpdateTitle()
  self:UpdateStep()
  self:UpdateSwitch(self.switch)
end
def.method().UpdateStep = function(self)
  local count = #self.steps
  local bg = self.m_panel:FindDirect("Container/Img_Bg")
  local list = bg:FindDirect("Target_List")
  local listCmp = list:GetComponent("UIList")
  listCmp:set_itemCount(count)
  listCmp:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not listCmp.isnil then
      listCmp:Reposition()
    end
  end)
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if bg and not bg.isnil then
      bg:GetComponent("UITableResizeBackground"):Reposition()
    end
  end)
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local info = self.steps[i]
    local name = uiGo:FindDirect("Label_" .. i)
    local btn = uiGo:FindDirect(string.format("Btn_Do_%d", i))
    local btnlbl = btn:FindDirect(string.format("Label_%d", i))
    name:GetComponent("UILabel"):set_text(info.name)
    btnlbl:GetComponent("UILabel"):set_text(info.btn)
    if info.highLight then
      btn:GetComponent("UISprite"):set_spriteName("Btn_White")
    else
      btn:GetComponent("UISprite"):set_spriteName("Btn_WhiteDisable ")
    end
    self.m_msgHandler:Touch(uiGo)
  end
end
def.method().UpdateTitle = function(self)
  local title = self.m_panel:FindDirect("Container/Label_Title")
  title:GetComponent("UILabel"):set_text(self.title)
end
def.method("boolean").UpdateSwitch = function(self, switch)
  self.switch = switch
  local up = self.m_panel:FindDirect("Container/Img_Up")
  local down = self.m_panel:FindDirect("Container/Img_Down")
  local bg = self.m_panel:FindDirect("Container/Img_Bg")
  local list = bg:FindDirect("Target_List")
  if self.switch then
    up:SetActive(true)
    down:SetActive(false)
    list:SetActive(true)
  else
    up:SetActive(false)
    down:SetActive(true)
    list:SetActive(false)
  end
  bg:GetComponent("UITableResizeBackground"):Reposition()
end
def.method().ShowTip = function(self)
  local tmpPosition = {x = 0, y = 0}
  local CommonDescDlg = require("GUI.CommonUITipsDlg")
  local tipString = require("Main.Common.TipsHelper").GetHoverTip(self.tipId)
  if tipString == "" then
    return
  end
  CommonDescDlg.ShowCommonTip(tipString, tmpPosition)
end
def.method("number").DoClick = function(self, id)
  if self.callback then
    self.callback(id)
  end
end
def.override().OnDestroy = function(self)
end
def.method("string").onClick = function(self, id)
  warn("onClick", id)
  if string.sub(id, 1, 7) == "Btn_Do_" then
    local index = tonumber(string.sub(id, 8))
    if index then
      local info = self.steps[index]
      if info then
        self:DoClick(info.id)
      end
    end
  elseif id == "Img_Down" then
    self:UpdateSwitch(true)
  elseif id == "Img_Up" then
    self:UpdateSwitch(false)
  elseif id == "Btn_Tips" then
    self:ShowTip()
  end
end
StepDlg.Commit()
return StepDlg

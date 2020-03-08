local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local NewActivity = Lplus.Extend(ECPanelBase, "NewActivity")
local GUIUtils = require("GUI.GUIUtils")
local GuideUtils = require("Main.Guide.GuideUtils")
local Vector = require("Types.Vector")
local MainUIModule = Lplus.ForwardDeclare("MainUIModule")
local def = NewActivity.define
local _instance
def.static("=>", NewActivity).Instance = function()
  if _instance == nil then
    _instance = NewActivity()
  end
  return _instance
end
def.field("boolean").trigger = false
def.field("table")._cfg = nil
def.field("function")._callback = nil
def.static("=>", "boolean").IsExist = function()
  return NewActivity.Instance().m_created
end
def.static("table", "function").ShowNewActivity = function(cfg, callback)
  local dlg = NewActivity.Instance()
  if dlg.m_panel then
    return
  end
  dlg.trigger = false
  dlg._cfg = cfg
  dlg._callback = callback
  dlg:CreatePanel(RESPATH.PREFAB_NEW_ACTIVITY, 0)
end
def.static().Close = function()
  local dlg = NewActivity.Instance()
  dlg:DestroyPanel()
end
def.override().OnCreate = function(self)
  self:UpdateContent()
  GameUtil.AddGlobalTimer(3, true, function()
    if self.m_panel then
      self:onClick("Img_Bg0")
    end
  end)
end
def.override().OnDestroy = function(self)
  if self._callback then
    self._callback()
  end
  self._cfg = nil
  self._callback = nil
  self.trigger = false
end
def.method().UpdateContent = function(self)
  if not self._cfg then
    return
  end
  local Img_Icon = self.m_panel:FindDirect("Img_Bg1/Img_BgIcon/Img_Icon")
  local uiTexture = Img_Icon:GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, self._cfg.activityIcon)
  local descLabel = self.m_panel:FindDirect("Img_Bg1/Label_Describe"):GetComponent("UILabel")
  descLabel:set_text(self._cfg.activityName)
  local Img_FloatIcon = self.m_panel:FindDirect("Img_FloatIcon")
  Img_FloatIcon:SetActive(false)
end
def.method("string").onClick = function(self, id)
  if id == "Img_Bg0" and not self.trigger then
    self.m_panel:FindDirect("Img_Bg0"):SetActive(false)
    self.m_panel:FindDirect("Img_Bg1"):SetActive(false)
    do
      local floatIcon = self.m_panel:FindDirect("Img_FloatIcon")
      floatIcon:SetActive(true)
      local uiTexture = floatIcon:GetComponent("UITexture")
      GUIUtils.FillIcon(uiTexture, self._cfg.activityIcon)
      local uiRoot = require("GUI.ECGUIMan").Instance().m_UIRoot
      local btnActivity = uiRoot:FindDirect("panel_main/Pnl_BtnGroup_Top/BtnGroup_Top/Btn_Activity")
      if not btnActivity then
        return
      end
      local position = btnActivity.transform.position
      local tp = TweenPosition.Begin(floatIcon, 0.5, position)
      tp.from = floatIcon.transform.position
      tp:set_worldSpace(true)
      local scale = Vector.Vector3.new(0.01, 0.01, 0.01)
      local ts = TweenScale.Begin(floatIcon, 0.5, scale)
      local function ShowBubble()
        local activityName = self._cfg.activityName
        local bubbleLabel = uiRoot:FindDirect("panel_main/Pnl_BtnGroup_Top/BtnGroup_Top/Btn_Activity/Label_New")
        if not bubbleLabel then
          return
        end
        bubbleLabel:SetActive(true)
        bubbleLabel:GetComponent("UILabel"):set_text(string.format(textRes.activity[272], activityName))
        GameUtil.AddGlobalTimer(5, true, function()
          if not bubbleLabel or bubbleLabel.isnil then
            return
          end
          bubbleLabel:SetActive(false)
        end)
      end
      GameUtil.AddGlobalTimer(0.7, true, function()
        ShowBubble()
        self:DestroyPanel()
      end)
      self.trigger = true
    end
  end
end
NewActivity.Commit()
return NewActivity

local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local NewFunction = Lplus.Extend(ECPanelBase, "NewFunction")
local GUIUtils = require("GUI.GUIUtils")
local GuideUtils = require("Main.Guide.GuideUtils")
local Vector = require("Types.Vector")
local MainUIModule = Lplus.ForwardDeclare("MainUIModule")
local def = NewFunction.define
local _instance
def.static("=>", NewFunction).Instance = function()
  if _instance == nil then
    _instance = NewFunction()
  end
  return _instance
end
def.field("number").cfgId = 0
def.field("function").callback = nil
def.field("boolean").trigger = false
def.static("number", "function").ShowNewFunction = function(cfgId, cb)
  local dlg = NewFunction.Instance()
  dlg.cfgId = cfgId
  dlg.callback = cb
  dlg.trigger = false
  dlg:CreatePanel(RESPATH.PREFAB_NEW_FUNCTION, 0)
end
def.static().Close = function()
  local dlg = NewFunction.Instance()
  dlg:DestroyPanel()
end
def.override().OnCreate = function(self)
  require("GUI.ECGUIMan").Instance():LockUI(false)
  self:UpdateContent()
  GameUtil.AddGlobalTimer(3, true, function()
    if self.m_panel then
      self:onClick("Img_Bg0")
    end
  end)
  gmodule.moduleMgr:GetModule(ModuleId.HERO):Stop()
  require("GUI.ECGUIMan").Instance():DestroyUIAtLevel(1)
  require("Main.Chat.ui.ChannelChatPanel").CloseChannelChatPanel()
  require("Main.friend.ui.SocialDlg").CloseSocialDlg()
  require("Main.task.ui.TaskTalk").Instance():HideDlg()
end
def.method().UpdateContent = function(self)
  local funcSprite = self.m_panel:FindDirect("Img_Bg1/Img_BgIcon/Img_Icon"):GetComponent("UISprite")
  local descLabel = self.m_panel:FindDirect("Img_Bg1/Label_Describe"):GetComponent("UILabel")
  local stepCfg = GuideUtils.GetStepCfg(self.cfgId)
  descLabel:set_text(stepCfg.textdesc)
  local funcOpenCfg = GuideUtils.GetFunctionOpenCfg(stepCfg.param)
  local funcId = funcOpenCfg.func
  funcSprite:set_spriteName(funcOpenCfg.icon)
  self.m_panel:FindDirect("Img_FloatIcon"):SetActive(false)
end
def.method("string").onClick = function(self, id)
  if id == "Img_Bg0" and not self.trigger then
    local stepCfg = GuideUtils.GetStepCfg(self.cfgId)
    local funcOpenCfg = GuideUtils.GetFunctionOpenCfg(stepCfg.param)
    local funcId = funcOpenCfg.func
    local position = MainUIModule.AddFunction(funcId, 0.5)
    if position == nil then
      self.callback(self.cfgId)
      return
    end
    self.m_panel:FindDirect("Img_Bg0"):GetComponent("UISprite"):set_alpha(0.00392156862745098)
    self.m_panel:FindDirect("Img_Bg1"):SetActive(false)
    local floatIcon = self.m_panel:FindDirect("Img_FloatIcon")
    floatIcon:SetActive(true)
    floatIcon:GetComponent("UISprite"):set_spriteName()
    local tp = TweenPosition.Begin(floatIcon, 0.5, position)
    tp.from = floatIcon.transform.position
    tp:set_worldSpace(true)
    print("TweenPosition", position.x, position.y, position.z)
    GameUtil.AddGlobalTimer(0.5, true, function()
      self.callback(self.cfgId)
    end)
    self.trigger = true
  end
end
NewFunction.Commit()
return NewFunction

local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local MenpaiStarCanvass = Lplus.Extend(ECPanelBase, "MenpaiStarCanvass")
local MenpaiStarUtils = require("Main.MenpaiStar.MenpaiStarUtils")
local MenpaiStarModule = Lplus.ForwardDeclare("MenpaiStarModule")
local def = MenpaiStarCanvass.define
local instance
def.static("=>", MenpaiStarCanvass).Instance = function()
  if instance == nil then
    instance = MenpaiStarCanvass()
  end
  return instance
end
def.field("function").callback = nil
def.field("number").selectWord = 0
def.field("table").canvassTexts = nil
def.static("function").ShowMenpaiStarCanvass = function(cb)
  local self = MenpaiStarCanvass.Instance()
  self.callback = cb
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PERFAB_MENPAISTAR_CANVASS, 2)
end
def.override().OnCreate = function(self)
  self:UpdateTemplate()
  self:SelectTemplate(0)
end
def.method().UpdateTemplate = function(self)
  self.canvassTexts = MenpaiStarUtils.GetCanvassText()
  local count = self.canvassTexts and #self.canvassTexts or 0
  local list = self.m_panel:FindDirect("Img_Bg0/Group_Example/Group_Toggle")
  local listCmp = list:GetComponent("UIList")
  listCmp:set_itemCount(count)
  listCmp:Resize()
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if not listCmp.isnil then
      listCmp:Reposition()
    end
  end)
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local text = self.canvassTexts[i]
    local nameLbl = uiGo:FindDirect(string.format("Label_Name_%d", i))
    nameLbl:GetComponent("UILabel"):set_text(string.format(textRes.MenpaiStar[21], i))
    self.m_msgHandler:Touch(uiGo)
  end
end
def.method("number").SelectTemplate = function(self, select)
  if self.canvassTexts and self.canvassTexts[select] then
    self.selectWord = select
  else
    self.selectWord = 0
  end
  local text = self.canvassTexts and self.canvassTexts[select] or ""
  text = text or ""
  self:SetInput(text)
end
def.method("string").SetInput = function(self, content)
  local input = self.m_panel:FindDirect("Img_Bg0/Group_Input/Img_BgInput")
  input:GetComponent("UIInput"):set_value(content)
end
def.method("=>", "string").GetInput = function(self)
  local input = self.m_panel:FindDirect("Img_Bg0/Group_Input/Img_BgInput")
  return input:GetComponent("UIInput"):get_value()
end
def.override().OnDestroy = function(self)
  self.callback = nil
  self.selectWord = 0
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif string.sub(id, 1, 12) == "Btn_Example_" then
    local index = tonumber(string.sub(id, 13))
    if index then
      self:SelectTemplate(index)
    end
  elseif id == "Btn_Send" then
    local text = self:GetInput()
    if text and text ~= "" then
      if SensitiveWordsFilter.ContainsSensitiveWord(text) then
        Toast(textRes.MenpaiStar[39])
      else
        if self.callback then
          self.callback(text)
        end
        self:DestroyPanel()
      end
    else
      Toast(textRes.MenpaiStar[22])
    end
  elseif id == "Btn_Clear" then
    self:SetInput("")
  elseif id == "Btn_Help" then
    require("GUI.GUIUtils").ShowHoverTip(constant.CMenPaiStarConst.CANVASS_UI_TIP_ID, 0, 0)
  end
end
return MenpaiStarCanvass.Commit()

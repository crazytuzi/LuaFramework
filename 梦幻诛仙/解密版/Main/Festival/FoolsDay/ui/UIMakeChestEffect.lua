local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UIMakeChestEffect = Lplus.Extend(ECPanelBase, "UIMakeChestEffect")
local GUIFxMan = require("Fx.GUIFxMan")
local def = UIMakeChestEffect.define
local instance
def.field("table")._buffInfo = nil
def.field("table")._arrAwardInfo = nil
def.field("number")._timer = -1
def.field("userdata")._fx = nil
def.const("number").UI_DURATION = 1.8
def.static("=>", UIMakeChestEffect).Instance = function()
  if instance == nil then
    instance = UIMakeChestEffect()
  end
  return instance
end
def.override().OnCreate = function(self)
  local GUIUtils = require("GUI.GUIUtils")
  local img = self.m_panel:FindDirect("Img_BgEquip/Group_Material/Head_001/Img_Head")
  local ctrlAwardRoot = self.m_panel:FindDirect("Img_BgEquip/Group_Material")
  if self._arrAwardInfo ~= nil then
    for i = 1, #self._arrAwardInfo do
      local awardImg = ctrlAwardRoot:FindDirect(string.format("Img_Material_%d", i))
      local texId = self._arrAwardInfo[i].img_id
      if awardImg ~= nil then
        local comUISprite = awardImg:GetComponent("UISprite")
        if comUISprite then
          GUIUtils.SetSprite(awardImg, texId)
        else
          GUIUtils.SetTexture(awardImg, texId)
        end
      end
    end
  end
  if self._buffInfo ~= nil then
    GUIUtils.SetTexture(img, self._buffInfo.image_id)
  end
  self:DisplayGUIEffect()
  self._timer = GameUtil.AddGlobalTimer(UIMakeChestEffect.UI_DURATION, true, function()
    self:HidePanel()
  end)
end
def.method().DisplayGUIEffect = function(self)
  local effectID = constant.CFoolsDayConsts.MAKE_CHEST_EFFECT_ID
  local effectPath = _G.GetEffectRes(effectID)
  local effectName = "effectMakeChest"
  self._fx = GUIFxMan.Instance():Play(effectPath.path, effectName, 0, 0, UIMakeChestEffect.UI_DURATION, true)
end
def.override().OnDestroy = function(self)
  self._buffInfo = nil
  self._timer = -1
  if self._fx ~= nil then
    GUIFxMan.Instance():RemoveFx(self._fx)
    self._fx = nil
  end
end
def.method("table", "table").ShowPanel = function(self, buffInfo, arrAwardInfo)
  if self._timer ~= -1 then
    GameUtil.RemoveGlobalTimer(self._timer)
    if self._fx ~= nil then
      GUIFxMan.Instance():RemoveFx(self._fx)
      self._fx = nil
    end
    self:HidePanel()
  end
  if self:IsShow() then
    return
  end
  self._buffInfo = buffInfo
  self._arrAwardInfo = arrAwardInfo
  self:CreatePanel(RESPATH.PREFAB_UI_MAKECHEST, 2)
  self:SetModal(true)
end
def.method().HidePanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
end
return UIMakeChestEffect.Commit()

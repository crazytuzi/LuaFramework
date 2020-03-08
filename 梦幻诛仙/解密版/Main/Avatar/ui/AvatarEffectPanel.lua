local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AvatarEffectPanel = Lplus.Extend(ECPanelBase, "AvatarEffectPanel")
local AvatarInterface = require("Main.Avatar.AvatarInterface")
local avatarInterface = AvatarInterface.Instance()
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local GUIUtils = require("GUI.GUIUtils")
local def = AvatarEffectPanel.define
def.field("table").effectList = nil
local instance
def.static("=>", AvatarEffectPanel).Instance = function()
  if instance == nil then
    instance = AvatarEffectPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PERFAB_CHANGE_HEAD_EFFECT, 0)
  self:SetModal(true)
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:setAvatarList()
  else
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Change, AvatarEffectPanel.OnAvatarChange)
  Event.RegisterEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Get_New_Avatar, AvatarEffectPanel.OnAvatarChange)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Change, AvatarEffectPanel.OnAvatarChange)
  Event.UnregisterEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Get_New_Avatar, AvatarEffectPanel.OnAvatarChange)
end
def.static("table", "table").OnAvatarChange = function(p1, p2)
  if instance and instance:IsShow() then
    instance:setAvatarList()
  end
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("--------AvatarEffectPanel onClick:", id)
  local strs = string.split(id, "_")
  if id == "Btn_Close" then
    self:Hide()
  elseif strs[1] == "Img" and strs[2] == "Toggle" then
    local idx = tonumber(strs[3])
    if idx then
      local uiToggle = clickObj:GetComponent("UIToggle")
      warn("------AvatarEffectPanel uiToggle value:", uiToggle.value)
      if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_AVATAR) then
        Toast(textRes.Avatar[1])
        return
      end
      if uiToggle.value then
        local avatarCfg = self.effectList[idx]
        local p = require("netio.protocol.mzm.gsp.avatar.CActivateAvatarReq").new(avatarCfg.id)
        gmodule.network.sendProtocol(p)
      else
        local p = require("netio.protocol.mzm.gsp.avatar.CActivateAvatarReq").new(0)
        gmodule.network.sendProtocol(p)
      end
    end
  end
end
def.method().setAvatarList = function(self)
  local effectList = avatarInterface:getActiveAndEffectAvatarCfgList()
  self.effectList = effectList
  warn("--------effectList len:", #effectList)
  local List_Effect = self.m_panel:FindDirect("Img_0/Group_Content/Scroll View/List_Effect")
  local uiList = List_Effect:GetComponent("UIList")
  uiList.itemCount = #effectList
  uiList:Resize()
  local curAttrAvatarId = avatarInterface.curAttrAvatarId
  for i, v in ipairs(effectList) do
    local Img_Effect = List_Effect:FindDirect("Img_Effect_" .. i)
    local Label_Name = Img_Effect:FindDirect("Label_Name_" .. i)
    local Label_Info = Img_Effect:FindDirect("Label_Info_" .. i)
    local Img_Toggle = Img_Effect:FindDirect("Img_Toggle_" .. i)
    Label_Name:GetComponent("UILabel"):set_text(v.name)
    local desc = {}
    for i, v in pairs(v.attrs) do
      local propertyCfg = _G.GetCommonPropNameCfg(i)
      if propertyCfg ~= nil then
        table.insert(desc, string.format("%s + %d", propertyCfg.propName, v))
      end
    end
    if #desc > 0 then
      GUIUtils.SetText(Label_Info, table.concat(desc, "\227\128\129"))
    else
      GUIUtils.SetText(Label_Info, "")
    end
    Img_Toggle:GetComponent("UIToggle").value = curAttrAvatarId == v.id
  end
end
AvatarEffectPanel.Commit()
return AvatarEffectPanel

local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local MakeEnchantingSkill = Lplus.Extend(ECPanelBase, "MakeEnchantingSkill")
local LivingSkillUtility = require("Main.Skill.LivingSkillUtility")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local CommonDescDlg = require("GUI.CommonUITipsDlg")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local def = MakeEnchantingSkill.define
local dlg
def.field("number").skillId = 0
def.field("number").skillLv = 0
def.field("number").itemId = 0
def.field("number").needVigor = 0
def.field("number").skillBagId = 0
def.field("boolean").bWaitToShowPanel = false
def.static("=>", MakeEnchantingSkill).Instance = function(self)
  if nil == dlg then
    dlg = MakeEnchantingSkill()
  end
  return dlg
end
def.static().ShowEnChantingSkill = function()
  local SkillMgr = require("Main.Skill.SkillMgr")
  local enchantingSkill = SkillMgr.Instance():GetEnchantingSkill()
  MakeEnchantingSkill.Instance().skillId = enchantingSkill.id
  MakeEnchantingSkill.Instance().skillLv = enchantingSkill.level
  MakeEnchantingSkill.Instance().itemId = 0
  MakeEnchantingSkill.Instance().needVigor = 0
  MakeEnchantingSkill.Instance().skillBagId = enchantingSkill.bagId
  MakeEnchantingSkill.RequireToEnchatId()
end
def.static().RequireToEnchatId = function()
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.skill.CFuMoSkillPreviewReq").new(MakeEnchantingSkill.Instance().skillId, MakeEnchantingSkill.Instance().skillBagId))
  MakeEnchantingSkill.Instance().bWaitToShowPanel = true
end
def.static("number", "number", "number").ShowEnChantingSkillPanel = function(skillId, needVigor, itemId)
  if MakeEnchantingSkill.Instance().skillId == skillId then
    MakeEnchantingSkill.Instance().itemId = itemId
    MakeEnchantingSkill.Instance().needVigor = needVigor
    MakeEnchantingSkill.Instance().bWaitToShowPanel = false
    MakeEnchantingSkill.Instance():SetModal(true)
    MakeEnchantingSkill.Instance():CreatePanel(RESPATH.PREFAB_SKILL_ENCHANTING_PANEL, 2)
  end
end
def.override().OnCreate = function(self)
  self:UpdateInfo()
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_ENERGY_CHANGED, MakeEnchantingSkill.OnEnergyChanged)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_ENERGY_CHANGED, MakeEnchantingSkill.OnEnergyChanged)
end
def.method().UpdateInfo = function(self)
  self:UpdateContent()
  self:UpdateVigor()
end
def.method().UpdateContent = function(self)
  local Img_BgTitle = self.m_panel:FindDirect("Img_Bg0/Img_BgTitle")
  local Img_Item = self.m_panel:FindDirect("Img_Bg0/Img_Item")
  local itemBase = ItemUtils.GetItemBase(self.itemId)
  local level = math.modf(self.skillLv / 10)
  if itemBase ~= nil then
    Img_BgTitle:FindDirect("Label_Name"):GetComponent("UILabel"):set_text(itemBase.name)
    GUIUtils.FillIcon(Img_Item:FindDirect("Icon_Item"):GetComponent("UITexture"), itemBase.icon)
  else
    warn("makeenchantingskill error itemid = ", self.itemId)
  end
end
def.method().UpdateVigor = function(self)
  local Group_Make = self.m_panel:FindDirect("Img_Bg0/Group_Make")
  Group_Make:FindDirect("Label_UseNum"):GetComponent("UILabel"):set_text(self.needVigor)
  local Group_Make = self.m_panel:FindDirect("Img_Bg0/Group_Make")
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  Group_Make:FindDirect("Label_HaveNum"):GetComponent("UILabel"):set_text(heroProp.energy)
  if heroProp.energy < self.needVigor then
    Group_Make:FindDirect("Label_UseNum"):GetComponent("UILabel"):set_textColor(Color.red)
  else
    Group_Make:FindDirect("Label_UseNum"):GetComponent("UILabel"):set_textColor(Color.Color(0.30980392156862746, 0.18823529411764706, 0.09411764705882353))
  end
end
def.static("table", "table").OnEnergyChanged = function(params, context)
  local self = MakeEnchantingSkill.Instance()
  self:UpdateVigor()
end
def.method().OnMakeEnchantClick = function(self)
  local bBagFull = ItemModule.Instance():IsBagFull(ItemModule.BAG)
  if bBagFull then
    Toast(textRes.Skill.LivingSkillMakeRes[1])
    return
  end
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp.energy < self.needVigor then
    Toast(textRes.Skill.LivingSkillMakeRes[0])
    return
  end
  MakeEnchantingSkill.RequireToUseSkill(self.skillId, self.skillBagId)
end
def.static("number", "number").RequireToUseSkill = function(skillId, skillBagId)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.skill.CUseFuMoSkillReq").new(skillId, skillBagId))
end
def.static("number").SucceedMakeEnChat = function(itemId)
  local itemBase = ItemUtils.GetItemBase(itemId)
  Toast(string.format(textRes.Skill[53], itemBase.name))
end
def.static("number", "table").UseEnchantPropCallback = function(i, tag)
  if i == 1 then
    MakeEnchantingSkill.RequireToUseEnchantProp(tag.skillId, tag.skillBagId)
  end
end
def.static("number").UseEnchant = function(propId)
  local propInfo = LivingSkillUtility.GetEnchantingPropInfo(propId)
  local wearPos = propInfo.wearPos
  local extraProperty = propInfo.extraProperty
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp.energy < MakeEnchantingSkill.Instance().needVigor then
    Toast(textRes.Skill.LivingSkillMakeRes[0])
    return
  end
  local key, item = ItemModule.Instance():GetItemByPosition(ItemModule.EQUIPBAG, wearPos)
  if item == nil then
    Toast(textRes.Skill[63])
    return
  else
    local bHaveProp = false
    for k, v in pairs(item.fumoProList) do
      if v.proType == extraProperty then
        bHaveProp = true
        break
      end
    end
    if bHaveProp then
      local tag = {
        skillId = MakeEnchantingSkill.Instance().skillId,
        skillBagId = MakeEnchantingSkill.Instance().skillBagId
      }
      CommonConfirmDlg.ShowConfirm("", textRes.Skill[62], MakeEnchantingSkill.UseEnchantPropCallback, tag)
      return
    end
    MakeEnchantingSkill.RequireToUseEnchantProp(MakeEnchantingSkill.Instance().skillId, MakeEnchantingSkill.Instance().skillBagId)
  end
end
def.static("number", "number").RequireToUseEnchantProp = function(skillId, skillBagId)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.skill.CAutoFuMoReq").new(skillId, skillBagId))
end
def.static("number", "number", "number").SucceedUseEnchant = function(propId, propertyType, addValue)
  local itemBase = ItemUtils.GetItemBase(propId)
  local cfg = GetCommonPropNameCfg(propertyType)
  local str = ""
  if addValue == 0 then
    str = string.format(textRes.Skill[65], itemBase.name)
  else
    local HtmlHelper = require("Main.Chat.HtmlHelper")
    str = string.format(textRes.Skill[64], HtmlHelper.NameColor[itemBase.namecolor], itemBase.name, cfg.propName, addValue)
  end
  Toast(str)
end
def.method().OnUseEnchantClick = function(self)
  MakeEnchantingSkill.UseEnchant(self.itemId)
end
def.method("userdata").ShowTips = function(self, clickobj)
  local position = clickobj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = clickobj:GetComponent("UISprite")
  local itemId = self.itemId
  ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), -1, false)
end
def.method().ShowInfoTips = function(self)
  local desc = textRes.Skill[61]
  local tmpPosition = {x = 0, y = 0}
  CommonDescDlg.ShowCommonTip(desc, tmpPosition)
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Btn_Make" == id then
    self:OnMakeEnchantClick()
  elseif "Btn_Fumo" == id then
    self:OnUseEnchantClick()
  elseif "Img_Item" == id then
    self:ShowTips(clickobj)
  elseif "Btn_Tips" == id then
    self:ShowInfoTips()
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.PANELNAME, {
      self.m_panelName
    })
  elseif "Btn_Close" == id then
    self:DestroyPanel()
    self = nil
  elseif "Modal" == id then
    self:DestroyPanel()
    self = nil
  end
end
MakeEnchantingSkill.Commit()
return MakeEnchantingSkill

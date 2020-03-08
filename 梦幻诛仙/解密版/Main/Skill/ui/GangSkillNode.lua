local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SkillPanelNodeBase = require("Main.Skill.ui.SkillPanelNodeBase")
local GangSkillNode = Lplus.Extend(SkillPanelNodeBase, "GangSkillNode")
local SkillMgr = require("Main.Skill.SkillMgr")
local SkillUtility = require("Main.Skill.SkillUtility")
local def = GangSkillNode.define
local GangSkillData = require("Main.Skill.data.GangSkillData")
local ItemModule = require("Main.Item.ItemModule")
local GangModule = require("Main.Gang.GangModule")
local GangData = require("Main.Gang.data.GangData")
local GangUtility = require("Main.Gang.GangUtility")
local instance
def.field("userdata").ui_List_Skill = nil
def.field("userdata").Group_Gang_SkillName = nil
def.field("userdata").Group_Activity = nil
def.field("userdata").Group_Gang_SkillShow = nil
def.field("userdata").Group_Gang_Use = nil
def.field("userdata").Group_Gang_Have = nil
def.field("number").lastSelectedIndex = 1
def.static("=>", GangSkillNode).Instance = function()
  if instance == nil then
    instance = GangSkillNode()
    GangSkillData.Instance():InitGangSkillBags()
  end
  return instance
end
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  SkillPanelNodeBase.Init(self, base, node)
  self:InitUI()
end
def.override().OnShow = function(self)
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_BanggongChanged, GangSkillNode.OnBanggongChanged)
  Event.RegisterEvent(ModuleId.SKILL, gmodule.notifyId.Skill.GANG_SKILL_LEVEL_UP_SUCCESS, GangSkillNode.SucceedSkillBagLevelUp)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_BanggongChanged, GangSkillNode.OnBanggongChanged)
  Event.UnregisterEvent(ModuleId.SKILL, gmodule.notifyId.Skill.GANG_SKILL_LEVEL_UP_SUCCESS, GangSkillNode.SucceedSkillBagLevelUp)
  SkillPanelNodeBase.OnHide(self)
end
def.override().InitUI = function(self)
  SkillPanelNodeBase.InitUI(self)
  local node = self.m_node
  self.ui_List_Skill = node:FindDirect("Img_Gang_BgList/Scroll View_Gang_List/List_Gang_Skill")
  self.Group_Gang_SkillName = node:FindDirect("Group_Gang_SkillName")
  self.Group_Activity = node:FindDirect("Group_Activity")
  self.Group_Gang_SkillShow = node:FindDirect("Group_Gang_SkillShow")
  self.Group_Gang_Use = node:FindDirect("Group_Gang_LvUp/Group_Gang_Use")
  self.Group_Gang_Have = node:FindDirect("Group_Gang_LvUp/Group_Gang_Have")
end
def.override("=>", "boolean").IsUnlock = function(self)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  return heroProp.level >= SkillUtility.GetGangSkillConst("ENABLE_GANG_SKILL_ROLE_LEVEL")
end
def.method().UpdateUI = function(self)
  self:FillGangSkillList()
  self:FillSelectedSkillBag()
end
def.method().FillGangSkillList = function(self)
  local skillsList = GangSkillData.Instance():GetBagList()
  local uiList = self.ui_List_Skill:GetComponent("UIList")
  local skillBagAmount = #skillsList
  uiList:set_itemCount(skillBagAmount)
  uiList:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not uiList.isnil then
      uiList:Reposition()
    end
  end)
  local items = uiList:get_children()
  for i = 1, skillBagAmount do
    do
      local item = items[i]
      local skillBag = skillsList[i]
      self:FillGangSkillBagInfo(item, i, skillBag)
      local uiToggle = item:GetComponent("UIToggle")
      GameUtil.AddGlobalTimer(0.1, true, function()
        if self.m_base.m_panel and false == self.m_base.m_panel.isnil then
          if self.lastSelectedIndex == i then
            uiToggle:set_value(true)
          else
            uiToggle:set_value(false)
          end
        end
      end)
    end
  end
  self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
end
def.method("userdata", "number", "table").FillGangSkillBagInfo = function(self, item, index, skillBag)
  local skillInfo = SkillUtility.GetPassiveSkillCfg(skillBag.skillid)
  local ui_Name_SkillGroup = item:FindDirect(string.format("Label_Gang_Skill_%d", index)):GetComponent("UILabel")
  ui_Name_SkillGroup:set_text(skillInfo.name)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local maxLevel = heroProp.level
  local curLevel = GangSkillData.Instance():GetSkillLevel(skillBag.skillid)
  local shuyuanLevel = GangData.Instance():GetBookLevel()
  local shuyuanCfg = GangUtility.GetBookGangBasicCfg(shuyuanLevel)
  if maxLevel > SkillUtility.GetGangSkillConst("MAX_SKILL_LEVEL") then
    maxLevel = SkillUtility.GetGangSkillConst("MAX_SKILL_LEVEL")
  end
  local ui_Lv_SkillGroup = item:FindDirect(string.format("Label_Gang_Lv_%d", index)):GetComponent("UILabel")
  ui_Lv_SkillGroup:set_text(string.format("%d/%d", curLevel, maxLevel))
  local ui_Texture_IconGroup = item:FindDirect(string.format("Img_Gang_BgIconGroup_%d/Texture_IconGroup_%d", index, index)):GetComponent("UITexture")
  require("GUI.GUIUtils").FillIcon(ui_Texture_IconGroup, skillInfo.iconId)
end
def.method().FillSelectedSkillBag = function(self)
  local skillsList = GangSkillData.Instance():GetBagList()
  local skillBag = skillsList[self.lastSelectedIndex]
  if nil == skillBag then
    return
  end
  local skillInfo = SkillUtility.GetPassiveSkillCfg(skillBag.skillid)
  local curLevel = GangSkillData.Instance():GetSkillLevel(skillBag.skillid)
  self.Group_Gang_SkillName:FindDirect("Label_Gang_SkillName"):GetComponent("UILabel"):set_text(skillInfo.name)
  self.Group_Gang_SkillName:FindDirect("Label_Gang_SkillLv"):GetComponent("UILabel"):set_text(string.format(textRes.Skill[69], curLevel))
  self.Group_Gang_SkillName:FindDirect("Label_Gang_Describe"):GetComponent("UILabel"):set_text(skillBag.skilldesc)
  self.Group_Activity:FindDirect("Label_Life_Have"):GetComponent("UILabel"):set_text(skillInfo.description)
  local needSilver, needBanggong, needLevel = SkillUtility.GetGangSkillCost(skillBag.typeId, curLevel)
  self.Group_Gang_Use:FindDirect("Label_Gang_UseMoneyNum"):GetComponent("UILabel"):set_text(needSilver)
  self.Group_Gang_Use:FindDirect("Label_Gang_UseGangNum"):GetComponent("UILabel"):set_text(needBanggong)
  self:UpdateGangSkillEffect()
  self:UpdateSilverMoney()
  self:UpdateGangMoney()
end
def.method().UpdateGangSkillEffect = function(self)
  local skillsList = GangSkillData.Instance():GetBagList()
  local skillBag = skillsList[self.lastSelectedIndex]
  local curLevel = GangSkillData.Instance():GetSkillLevel(skillBag.skillid)
  local skillId = skillBag.skillid
  local skillInfo = SkillUtility.GetPassiveSkillCfg(skillId)
  local effInfo = SkillUtility.GetOutFightEffectGroup(skillInfo.effectIdList[1])
  local roleEffInfo = SkillUtility.GetRoleEffectCfg(effInfo.effectId)
  if roleEffInfo == nil then
    self.Group_Gang_SkillShow:SetActive(false)
    return
  end
  self.Group_Gang_SkillShow:SetActive(true)
  local skillEffects = SkillMgr.Instance():GetPassiveSkillEffects(skillId, curLevel)
  local nextSkillEffects = SkillMgr.Instance():GetPassiveSkillEffects(skillId, curLevel + 1)
  local curLevelEffects, nextlevelEffects = SkillUtility.GetFormatSkillEffects(skillEffects, nextSkillEffects)
  local curlevelEffect = curLevelEffects[1]
  if curlevelEffect then
    local Label_Gang_SkillNow = self.Group_Gang_SkillShow:FindDirect("Label_Gang_SkillNow"):GetComponent("UILabel")
    Label_Gang_SkillNow:set_text(string.format("%s:", curlevelEffect.name))
    local Label_Gang_SkillNow_Num = self.Group_Gang_SkillShow:FindDirect("Label_Gang_SkillNow_Num"):GetComponent("UILabel")
    Label_Gang_SkillNow_Num:set_text(string.format("%s", curlevelEffect.valueText))
  else
    warn(string.format("no passive effect for skillId", skillId))
  end
  local Label2 = self.Group_Gang_SkillShow:FindDirect("Label2")
  local Label_Gang_SkillNext = self.Group_Gang_SkillShow:FindDirect("Label_Gang_SkillNext")
  local Label_Gang_SkillNext_Num = self.Group_Gang_SkillShow:FindDirect("Label_Gang_SkillNext_Num")
  if curLevel >= SkillUtility.GetGangSkillConst("MAX_SKILL_LEVEL") then
    Label_Gang_SkillNext:SetActive(false)
    Label_Gang_SkillNext_Num:SetActive(false)
    Label2:SetActive(false)
  else
    local nextlevelEffect = nextlevelEffects[1]
    Label2:SetActive(true)
    Label_Gang_SkillNext:SetActive(true)
    Label_Gang_SkillNext_Num:SetActive(true)
    Label_Gang_SkillNext:GetComponent("UILabel"):set_text(string.format("%s:", nextlevelEffect.name))
    Label_Gang_SkillNext_Num:GetComponent("UILabel"):set_text(string.format("%s", nextlevelEffect.valueText))
  end
end
def.method().UpdateSilverMoney = function(self)
  self.Group_Gang_Have:FindDirect("Label_Gang_UseMoneyNum"):GetComponent("UILabel"):set_text(Int64.tostring(ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)))
  local skillsList = GangSkillData.Instance():GetBagList()
  local skillBag = skillsList[self.lastSelectedIndex]
  if nil == skillBag then
    return
  end
  local curLevel = GangSkillData.Instance():GetSkillLevel(skillBag.skillid)
  local needSilver, needBanggong, needLevel = SkillUtility.GetGangSkillCost(skillBag.typeId, curLevel)
  if Int64.gt(needSilver, Int64.tostring(ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER))) then
    self.Group_Gang_Use:FindDirect("Label_Gang_UseMoneyNum"):GetComponent("UILabel"):set_textColor(Color.red)
  else
    self.Group_Gang_Use:FindDirect("Label_Gang_UseMoneyNum"):GetComponent("UILabel"):set_textColor(Color.Color(0.31, 0.188, 0.094, 1))
  end
end
def.method().UpdateGangMoney = function(self)
  local curBanggong = GangModule.Instance():GetHeroCurBanggong()
  self.Group_Gang_Have:FindDirect("Label_Gang_UseGangNum"):GetComponent("UILabel"):set_text(curBanggong)
  local skillsList = GangSkillData.Instance():GetBagList()
  local skillBag = skillsList[self.lastSelectedIndex]
  if nil == skillBag then
    return
  end
  local curLevel = GangSkillData.Instance():GetSkillLevel(skillBag.skillid)
  local needSilver, needBanggong, needLevel = SkillUtility.GetGangSkillCost(skillBag.typeId, curLevel)
  if curBanggong < needBanggong then
    self.Group_Gang_Use:FindDirect("Label_Gang_UseGangNum"):GetComponent("UILabel"):set_textColor(Color.red)
  else
    self.Group_Gang_Use:FindDirect("Label_Gang_UseGangNum"):GetComponent("UILabel"):set_textColor(Color.Color(0.31, 0.188, 0.094, 1))
  end
end
def.override("table", "table").OnSilverMoneyChanged = function(self, params, context)
  self:UpdateSilverMoney()
end
def.static("table", "table").OnBanggongChanged = function(self, params, context)
  local self = instance
  self:UpdateGangMoney()
end
def.static("table", "table").SucceedSkillBagLevelUp = function(params, context)
  local skillId = params[1]
  local level = params[2]
  GangSkillNode.Instance():SkillBagLevelUpSucceed(skillId, level)
end
def.method("number", "number").SkillBagLevelUpSucceed = function(self, skillId, level)
  local skillInfo = SkillUtility.GetPassiveSkillCfg(skillId)
  Toast(string.format(textRes.Skill[5], skillInfo.name, level))
  if self.m_panel:get_activeInHierarchy() then
    self:FillGangSkillList()
    local skillsList = GangSkillData.Instance():GetBagList()
    local skillBag = skillsList[self.lastSelectedIndex]
    if skillBag.skillid == skillId then
      self:FillSelectedSkillBag()
    end
  end
end
def.method("number").OnSkillBagSelected = function(self, index)
  self.lastSelectedIndex = index
  self:FillSelectedSkillBag()
end
def.static("number", "table").LevelUpCallback = function(i, tag)
  if i == 1 then
    GoToBuySilver(false)
  end
end
def.method().RequireToLevelUp = function(self)
  local skillsList = GangSkillData.Instance():GetBagList()
  local skillBag = skillsList[self.lastSelectedIndex]
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gangskill.CGangSkillLevelUpReq").new(skillBag.skillid))
end
def.method().OnLevelUpClick = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local skillsList = GangSkillData.Instance():GetBagList()
  local skillBag = skillsList[self.lastSelectedIndex]
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local curLevel = GangSkillData.Instance():GetSkillLevel(skillBag.skillid)
  local shuyuanLevel = GangData.Instance():GetBookLevel()
  local shuyuanCfg = GangUtility.GetBookGangBasicCfg(shuyuanLevel)
  local needSilver, needBanggong, needLevel = SkillUtility.GetGangSkillCost(skillBag.typeId, curLevel)
  local bHasGang = GangModule.Instance():HasGang()
  if false == bHasGang then
    Toast(textRes.Skill[100])
    return
  end
  if curLevel >= heroProp.level then
    Toast(textRes.Skill[101])
    return
  end
  if curLevel >= shuyuanCfg.maxSkillLevel then
    Toast(textRes.Skill[102])
    return
  end
  if needLevel > heroProp.level then
    Toast(string.format(textRes.Skill[103], needLevel))
    return
  end
  if Int64.gt(needSilver, ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)) then
    local tag = {id = self}
    local skillInfo = SkillUtility.GetPassiveSkillCfg(skillBag.skillid)
    local content = string.format(textRes.Skill[50], skillInfo.name)
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    CommonConfirmDlg.ShowConfirm("", content, GangSkillNode.LevelUpCallback, tag)
    return
  end
  local curBanggong = GangModule.Instance():GetHeroCurBanggong()
  if needBanggong > curBanggong then
    Toast(textRes.Skill[71])
    return
  end
  if curLevel >= SkillUtility.GetGangSkillConst("MAX_SKILL_LEVEL") then
    Toast(textRes.Skill[104])
    return
  end
  self:RequireToLevelUp()
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if string.sub(id, 1, #"Img_Gang_BgSkillGroup_") == "Img_Gang_BgSkillGroup_" then
    local index = tonumber(string.sub(id, #"Img_Gang_BgSkillGroup_" + 1, -1))
    self:OnSkillBagSelected(index)
  elseif "Btn_Gang_LvUp" == id then
    self:OnLevelUpClick()
  end
end
return GangSkillNode.Commit()

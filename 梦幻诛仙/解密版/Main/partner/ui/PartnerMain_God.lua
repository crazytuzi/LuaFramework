local Lplus = require("Lplus")
local ECGUIMan = require("GUI.ECGUIMan")
local GUIUtils = require("GUI.GUIUtils")
local GUIFxMan = require("Fx.GUIFxMan")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local SkillUtils = require("Main.Skill.SkillUtility")
local PartnerMain = Lplus.ForwardDeclare("PartnerMain")
local PartnerMain_God = Lplus.Class("PartnerMain_God")
local PartnerInterface = require("Main.partner.PartnerInterface")
local partnerInterface = PartnerInterface.Instance()
local def = PartnerMain_God.define
local instance
def.const("number").SUB_YUANSHEN_NUM = 6
def.const("string").YUANSHEN_SKILL_EFFECT_NAME = "yuanshen_skill_effect"
def.field(PartnerMain)._partnerMain = nil
def.field("boolean")._isShow = false
def.field("number")._curLevelUpIndex = 1
def.field("table")._skillGos = nil
def.static(PartnerMain, "=>", PartnerMain_God).New = function(panel)
  if instance == nil then
    instance = PartnerMain_God()
    instance._partnerMain = panel
    instance:Init()
  end
  return instance
end
def.static("=>", PartnerMain_God).Instance = function()
  return instance
end
def.method().Init = function(self)
end
def.method().OnCreate = function(self)
end
def.method().OnDestroy = function(self)
  self._skillGos = {}
end
def.method("=>", "boolean").IsShow = function(self)
  return self._isShow
end
def.method("boolean").OnShow = function(self, b)
  if b then
    local partnerCfg = self._partnerMain._partnerList[self._partnerMain._selectedIndex]
    if partnerCfg then
      local Yuanshen = self._partnerMain.m_panel:FindDirect("Img_Bg0/Group_Right/Yuanshen")
      local Group_skill = Yuanshen:FindDirect("Group_Skill")
      for i = 1, 8 do
        local Img_skill = Group_skill:FindDirect(string.format("Img_Skill_%02d", i))
        local skillId = partnerCfg.skillIds[i]
        if skillId ~= nil then
          local partnerSkillCfg = PartnerInterface.GetPartnerSkillCfg(skillId)
          Img_skill:SetActive(true)
          local Skill_Icon = Img_skill:FindDirect("Img_SkillIcon" .. i)
          local skill_effect = Skill_Icon:FindDirect(PartnerMain_God.YUANSHEN_SKILL_EFFECT_NAME)
          if skill_effect then
            Object.Destroy(skill_effect)
          end
        end
      end
      self:setPartnerInfo()
    end
  elseif self._partnerMain and self._partnerMain.m_panel then
    local Yuanshen = self._partnerMain.m_panel:FindDirect("Img_Bg0/Group_Right/Yuanshen")
    local Img_TipsBg = Yuanshen:FindDirect("Img_TipsBg")
    Img_TipsBg:SetActive(false)
  end
  self._isShow = b
end
def.static("table", "table").refreshPartnerSkill = function(p1, p2)
  instance:setPartnerSkill()
  if p1 == nil then
    return
  end
  local unlockSkills = p1[1].unlock
  local levelUpSkills = p1[1].levelUp
  for _, v in ipairs(unlockSkills) do
    local partnerSkillCfg = PartnerInterface.GetPartnerSkillCfg(v)
    if partnerSkillCfg then
      instance:playSkillEffect(v)
      Toast(string.format(textRes.Partner[61], partnerSkillCfg.skillCfg.name))
    end
  end
  for _, v in ipairs(levelUpSkills) do
    local partnerSkillCfg = PartnerInterface.GetPartnerSkillCfg(v)
    if partnerSkillCfg then
      instance:playSkillEffect(v)
      Toast(string.format(textRes.Partner[62], partnerSkillCfg.skillCfg.name))
    end
  end
end
def.static("table", "table").refreshYuanshenInfo = function(p1, p2)
  instance:setPartnerInfo()
  if p1.isLevelUp then
    local fx = GameUtil.RequestFx(RESPATH.YUAN_SHEN_TI_SHENG, 1)
    if fx then
      local Vector = require("Types.Vector")
      local fxone = fx:GetComponent("FxOne")
      fx.parent = GUIRoot.GetUIRootObj()
      fx.localPosition = Vector.Vector3.new(0, 0, 0)
      fx.localScale = Vector.Vector3.one
      fxone:Play2(-1, false)
    end
  end
  if p1.subYuanLevelup then
    local partnerCfg = PartnerInterface.GetPartnerCfg(p1.partnerId)
    local yuanshenCfg = PartnerInterface.GetPartnerYuanshenCfg(partnerCfg.yuanCfgId)
    for i, v in pairs(p1.subYuanLevelup) do
      local skillId = yuanshenCfg.pasSkillIds[i]
      local pasSkillCfg = SkillUtils.GetPassiveSkillCfg(skillId)
      if pasSkillCfg then
        Toast(string.format(textRes.Partner[66], pasSkillCfg.name, v))
      end
    end
  end
  instance._partnerMain._panelListGrid:refreshCurSelectedPartnerInfo()
end
def.static("table", "table").OnBagInfoSynchronized = function(p1, p2)
  if instance then
    instance:setCostItemInfo()
  end
end
def.method("number").playSkillEffect = function(self, skillId)
  local go = self._skillGos[skillId]
  if go then
    local widget = go:GetComponent("UIWidget")
    local w = widget:get_width()
    local h = widget:get_height()
    local xScale = w / 64
    local yScale = h / 64
    GUIFxMan.Instance():PlayAsChildLayer(go, RESPATH.YUANSHEN_SKILL_LEVELUP, PartnerMain_God.YUANSHEN_SKILL_EFFECT_NAME, 0, 0, xScale, yScale, -1, false)
  end
end
def.method().setCurLevelUpYuanshen = function(self)
  local index = 1
  local partnerCfg = self._partnerMain._partnerList[self._partnerMain._selectedIndex]
  if partnerCfg then
    local partnerId = partnerCfg.id
    for i = 2, PartnerMain_God.SUB_YUANSHEN_NUM do
      local lastLevel = partnerInterface:getSubYuanshenLevel(partnerId, i - 1)
      local subYuanshenLv = partnerInterface:getSubYuanshenLevel(partnerId, i)
      if lastLevel > subYuanshenLv then
        index = i
        break
      end
    end
    local Yuanshen = self._partnerMain.m_panel:FindDirect("Img_Bg0/Group_Right/Yuanshen")
    local Group_Yuanshen = Yuanshen:FindDirect("Group_YS")
    local Img_Shuxing = Group_Yuanshen:FindDirect("Img_Shuxing_" .. index)
    local Img_Selected = Img_Shuxing:FindDirect("Img_Selected")
    Img_Selected:SetActive(true)
    if self._curLevelUpIndex ~= index then
      Img_Shuxing = Group_Yuanshen:FindDirect("Img_Shuxing_" .. self._curLevelUpIndex)
      Img_Selected = Img_Shuxing:FindDirect("Img_Selected")
      Img_Selected:SetActive(false)
      self._curLevelUpIndex = index
    end
  end
end
def.method("string", "=>", "boolean").onClick = function(self, id)
  local Yuanshen = self._partnerMain.m_panel:FindDirect("Img_Bg0/Group_Right/Yuanshen")
  local Img_TipsBg = Yuanshen:FindDirect("Img_TipsBg")
  if id ~= "Img_Yuanshen" and Img_TipsBg.activeSelf then
    Img_TipsBg:SetActive(false)
  end
  local strs = string.split(id, "_")
  if id == "Btn_Train" then
    self:sendImproveYuanshen()
    return true
  elseif id == "Btn_Chouli" then
    self:sendRemoveYuanshen()
    return true
  elseif id == "Img_IconBg" then
    self:showCostItemTip()
    return true
  elseif id == "Btn_Tips" then
    local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
    local tipContent = require("Main.Common.TipsHelper").GetHoverTip(701605007)
    CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = 0, y = 0})
    return true
  elseif id == "Img_Yuanshen" then
    local Label_Info = Img_TipsBg:FindDirect("Label_Info")
    Label_Info:GetComponent("UILabel"):set_text(string.format(textRes.Partner[67], constant.PartnerConstants.Partner_YUAN_LV_MAX))
    Img_TipsBg:SetActive(true)
    local partnerCfg = self._partnerMain._partnerList[self._partnerMain._selectedIndex]
    local invited = partnerInterface:HasThePartner(partnerCfg.id)
    local Btn_Chouli = Img_TipsBg:FindDirect("Btn_Chouli")
    Btn_Chouli:SetActive(invited)
    return true
  elseif strs[1] == "Img" and strs[2] == "Shuxing" then
    local partnerCfg = self._partnerMain._partnerList[self._partnerMain._selectedIndex]
    local idx = tonumber(strs[3])
    local Yuanshen = self._partnerMain.m_panel:FindDirect("Img_Bg0/Group_Right/Yuanshen")
    local Group_Yuanshen = Yuanshen:FindDirect("Group_YS")
    local Img_Shuxing = Group_Yuanshen:FindDirect("Img_Shuxing_" .. idx)
    local yuanshenCfg = PartnerInterface.GetPartnerYuanshenCfg(partnerCfg.yuanCfgId)
    local skillId = yuanshenCfg.pasSkillIds[idx]
    local pasSkillCfg = SkillUtils.GetPassiveSkillCfg(skillId)
    local position = Img_Shuxing:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local widget = Img_Shuxing:GetComponent("UIWidget")
    require("Main.Skill.SkillTipMgr").Instance():ShowTipById(skillId, screenPos.x, screenPos.y, widget.width, widget.height, 0)
    return true
  elseif strs[1] == "Img" and strs[2] == "Skill" then
    local index = tonumber(strs[3])
    local cfg = self._partnerMain._partnerList[self._partnerMain._selectedIndex]
    local skillId = cfg.skillIds[index]
    local skillCfg = PartnerInterface.GetPartnerSkillCfg(skillId)
    local Yuanshen = self._partnerMain.m_panel:FindDirect("Img_Bg0/Group_Right/Yuanshen")
    local Group_skill = Yuanshen:FindDirect("Group_Skill")
    local Skill = Group_skill:FindDirect(string.format("Img_Skill_%02d", index))
    self:showSkillTip(skillCfg, Skill)
    return true
  end
  return false
end
def.method().sendImproveYuanshen = function(self)
  local partnerCfg = self._partnerMain._partnerList[self._partnerMain._selectedIndex]
  local curYuanshenLv = partnerInterface:getYuanshenLevel(partnerCfg.id)
  if curYuanshenLv >= constant.PartnerConstants.Partner_YUAN_LV_MAX then
    Toast(textRes.Partner[64])
    return
  end
  local yuanshenCfg = PartnerInterface.GetPartnerYuanshenCfg(partnerCfg.yuanCfgId)
  local constNum = partnerInterface:getCostItemNum(yuanshenCfg.costId, curYuanshenLv)
  local itemData = require("Main.Item.ItemData").Instance()
  local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
  local count = itemData:GetNumberByItemId(BagInfo.BAG, yuanshenCfg.costItemId)
  if constNum <= count then
    local subLevel = partnerInterface:getSubYuanshenLevel(partnerCfg.id, self._curLevelUpIndex)
    local CImproveYuanShenReq = require("netio.protocol.mzm.gsp.partner.CImproveYuanReq").new(partnerCfg.id, self._curLevelUpIndex, subLevel + 1)
    gmodule.network.sendProtocol(CImproveYuanShenReq)
  else
    local itemBase = ItemUtils.GetItemBase(yuanshenCfg.costItemId)
    if itemBase then
      Toast(string.format(textRes.Partner[56], itemBase.name))
    end
  end
end
def.method().sendRemoveYuanshen = function(self)
  local partnerCfg1 = self._partnerMain._partnerList[self._partnerMain._selectedIndex]
  local bCanRemove = false
  local i
  for i = 1, PartnerMain_God.SUB_YUANSHEN_NUM do
    local subYuanshenLv = partnerInterface:getSubYuanshenLevel(partnerCfg1.id, i)
    if subYuanshenLv > 1 then
      bCanRemove = true
      break
    end
  end
  if false == bCanRemove then
    Toast(textRes.Partner[68])
    return
  end
  local function confirmCallback(id)
    if id == 1 then
      local partnerCfg = self._partnerMain._partnerList[self._partnerMain._selectedIndex]
      local CRecoveryYuanShen = require("netio.protocol.mzm.gsp.partner.CRecoveryYuanShen").new(partnerCfg.id)
      gmodule.network.sendProtocol(CRecoveryYuanShen)
    end
  end
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirmCoundDown("", textRes.Partner[57], textRes.Partner[58], textRes.Partner[59], 0, 0, confirmCallback, {})
end
def.method("table", "userdata").showSkillTip = function(self, skillCfg, gameObject)
  local cfg = self._partnerMain._partnerList[self._partnerMain._selectedIndex]
  if skillCfg then
    local position = gameObject:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local widget = gameObject:GetComponent("UIWidget")
    local property = partnerInterface:GetPartnerProperty(cfg.id)
    local isUnlock = true
    local partnerSkillCfg = PartnerInterface.GetPartnerSkillCfg(skillCfg.id)
    local curYuanshenLv = partnerInterface:getYuanshenLevel(cfg.id)
    if curYuanshenLv < partnerSkillCfg.unLockYuanLevel then
      isUnlock = false
    end
    require("Main.Skill.SkillTipMgr").Instance():ShowPartnerSkillTip(skillCfg, isUnlock, screenPos.x, screenPos.y, widget.width, widget.height, 0)
  end
end
def.method().showCostItemTip = function(self)
  local partnerCfg = self._partnerMain._partnerList[self._partnerMain._selectedIndex]
  local yuanshenCfg = PartnerInterface.GetPartnerYuanshenCfg(partnerCfg.yuanCfgId)
  local itemBase = ItemUtils.GetItemBase(yuanshenCfg.costItemId)
  if itemBase then
    local Yuanshen = self._partnerMain.m_panel:FindDirect("Img_Bg0/Group_Right/Yuanshen")
    local Group_Yuanshen = Yuanshen:FindDirect("Group_YS")
    local Img_IconBg = Group_Yuanshen:FindDirect("Img_IconBg")
    local Img_ItemIcon = Img_IconBg:FindDirect("Img_ItemIcon")
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(yuanshenCfg.costItemId, Img_ItemIcon, 0, true)
  end
end
def.method().setPartnerInfo = function(self)
  self._skillGos = {}
  local selectedIdx = self._partnerMain._selectedIndex
  local cfg = self._partnerMain._partnerList[selectedIdx]
  local Yuanshen = self._partnerMain.m_panel:FindDirect("Img_Bg0/Group_Right/Yuanshen")
  self:setPartnerSkill()
  self:setPartnerYuanshen()
  self:setCurLevelUpYuanshen()
end
def.method().setPartnerSkill = function(self)
  local partnerCfg = self._partnerMain._partnerList[self._partnerMain._selectedIndex]
  if partnerCfg then
    local Yuanshen = self._partnerMain.m_panel:FindDirect("Img_Bg0/Group_Right/Yuanshen")
    local Group_skill = Yuanshen:FindDirect("Group_Skill")
    for i = 1, 8 do
      local Img_skill = Group_skill:FindDirect(string.format("Img_Skill_%02d", i))
      local skillId = partnerCfg.skillIds[i]
      if skillId ~= nil then
        local partnerSkillCfg = PartnerInterface.GetPartnerSkillCfg(skillId)
        Img_skill:SetActive(true)
        local Skill_Icon = Img_skill:FindDirect("Img_SkillIcon" .. i)
        local skill_effect = Skill_Icon:FindDirect(PartnerMain_God.YUANSHEN_SKILL_EFFECT_NAME)
        if skill_effect then
        end
        local Label_Level = Img_skill:FindDirect("Label_LevelUp" .. i)
        local Img_Grey = Img_skill:FindDirect("Img_Grey" .. i)
        local Img_Lock = Img_skill:FindDirect("Img_Lock" .. i)
        self._skillGos[skillId] = Skill_Icon
        local uiTexture = Skill_Icon:GetComponent("UITexture")
        GUIUtils.FillIcon(uiTexture, partnerSkillCfg.skillCfg.iconId)
        local curYuanshenLv = partnerInterface:getYuanshenLevel(partnerCfg.id)
        if curYuanshenLv >= partnerSkillCfg.unLockYuanLevel then
          Img_Grey:SetActive(false)
          Img_Lock:SetActive(false)
          local skillInfos = partnerInterface:GetPartnerSkillInfos(partnerCfg.id)
          local skillLv = 1
          if skillInfos then
            skillLv = skillInfos[skillId]
          end
          if skillLv < partnerSkillCfg.upLimit then
            Label_Level:GetComponent("UILabel"):set_text(string.format(textRes.Partner[2], skillLv))
          else
            Label_Level:GetComponent("UILabel"):set_text(textRes.Partner[63])
          end
        else
          Img_Grey:SetActive(true)
          Img_Lock:SetActive(true)
          Label_Level:GetComponent("UILabel"):set_text(string.format(textRes.Partner[1], partnerSkillCfg.unLockYuanLevel))
        end
      else
        Img_skill:SetActive(false)
      end
    end
  end
end
def.method().setPartnerYuanshen = function(self)
  local partnerCfg = self._partnerMain._partnerList[self._partnerMain._selectedIndex]
  if partnerCfg then
    local Yuanshen = self._partnerMain.m_panel:FindDirect("Img_Bg0/Group_Right/Yuanshen")
    local Group_Yuanshen = Yuanshen:FindDirect("Group_YS")
    local Label_NoYuanshen = Group_Yuanshen:FindDirect("Label_NoYuanshen")
    local Label_Tips = Group_Yuanshen:FindDirect("Label_Tips")
    local Img_IconBg = Group_Yuanshen:FindDirect("Img_IconBg")
    local Btn_Train = Group_Yuanshen:FindDirect("Btn_Train")
    local Btn_Chouli = Group_Yuanshen:FindDirect("Btn_Chouli")
    local invited = partnerInterface:HasThePartner(partnerCfg.id)
    Label_NoYuanshen:SetActive(not invited)
    Label_Tips:SetActive(invited)
    Img_IconBg:SetActive(invited)
    Btn_Train:SetActive(invited)
    local yuanshenCfg = PartnerInterface.GetPartnerYuanshenCfg(partnerCfg.yuanCfgId)
    local Img_liuzhejiekoubeiyongde = Group_Yuanshen:FindDirect("Img_Yuanshen/Img_liuzhejiekoubeiyongde")
    local Img_Texture = Img_liuzhejiekoubeiyongde:GetComponent("UITexture")
    GUIUtils.FillIcon(Img_Texture, yuanshenCfg.picId)
    self:setCostItemInfo()
    local curYuanshenLv = partnerInterface:getYuanshenLevel(partnerCfg.id)
    local Label_YuanshenLevel = Group_Yuanshen:FindDirect("Img_Yuanshen/Label_YuanshenLevel")
    Label_YuanshenLevel:GetComponent("UILabel"):set_text(string.format(textRes.Partner[2], curYuanshenLv))
    for i = 1, PartnerMain_God.SUB_YUANSHEN_NUM do
      local skillId = yuanshenCfg.pasSkillIds[i]
      local pasSkillCfg = SkillUtils.GetPassiveSkillCfg(skillId)
      if pasSkillCfg then
        local Img_Shuxing = Group_Yuanshen:FindDirect("Img_Shuxing_" .. i)
        local Label_Name = Img_Shuxing:FindDirect("Label_Name_" .. i)
        local Label_Level = Img_Shuxing:FindDirect("Label_Level_" .. i)
        local Img_Icon = Img_Shuxing:FindDirect("Img_Icon_" .. i)
        local Img_Selected = Img_Shuxing:FindDirect("Img_Selected")
        Img_Selected:SetActive(false)
        local subYuanshenLv = partnerInterface:getSubYuanshenLevel(partnerCfg.id, i)
        Label_Name:GetComponent("UILabel"):set_text("")
        Label_Level:GetComponent("UILabel"):set_text(string.format(textRes.Partner[2], subYuanshenLv))
        local Icon_Texture = Img_Icon:GetComponent("UITexture")
        GUIUtils.FillIcon(Icon_Texture, pasSkillCfg.iconId)
      else
        warn("!!!!!!!!invalid pasSKillId:", skillId)
      end
    end
  end
end
def.method().setCostItemInfo = function(self)
  local partnerCfg = self._partnerMain._partnerList[self._partnerMain._selectedIndex]
  if partnerCfg then
    local Yuanshen = self._partnerMain.m_panel:FindDirect("Img_Bg0/Group_Right/Yuanshen")
    local Group_Yuanshen = Yuanshen:FindDirect("Group_YS")
    local yuanshenCfg = PartnerInterface.GetPartnerYuanshenCfg(partnerCfg.yuanCfgId)
    local itemBase = ItemUtils.GetItemBase(yuanshenCfg.costItemId)
    if itemBase then
      local Img_IconBg = Group_Yuanshen:FindDirect("Img_IconBg")
      local Img_ItemIcon = Img_IconBg:FindDirect("Img_ItemIcon")
      local Icon_Texture = Img_ItemIcon:GetComponent("UITexture")
      GUIUtils.FillIcon(Icon_Texture, itemBase.icon)
      local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
      local itemData = require("Main.Item.ItemData").Instance()
      local yuanshenLv = partnerInterface:getYuanshenLevel(partnerCfg.id)
      local constNum = partnerInterface:getCostItemNum(yuanshenCfg.costId, yuanshenLv + 1)
      local count = itemData:GetNumberByItemId(BagInfo.BAG, yuanshenCfg.costItemId)
      local Label_ItemNumber = Img_IconBg:FindDirect("Label_ItemNumber")
      Label_ItemNumber:GetComponent("UILabel"):set_text(count .. "/" .. constNum)
      local Label_ItemName = Img_IconBg:FindDirect("Label_ItemName")
      Label_ItemName:GetComponent("UILabel"):set_text(itemBase.name)
    else
      warn("!!!!!!!!!itemBase is nil:", yuanshenCfg.costItemId)
    end
  end
end
PartnerMain_God.Commit()
return PartnerMain_God

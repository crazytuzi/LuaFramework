local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local MountsInfoPanel = Lplus.Extend(ECPanelBase, "MountsInfoPanel")
local GUIUtils = require("GUI.GUIUtils")
local EC = require("Types.Vector3")
local MountsMgr = require("Main.Mounts.mgr.MountsMgr")
local MountsUtils = require("Main.Mounts.MountsUtils")
local MountsTypeEnum = require("consts.mzm.gsp.mounts.confbean.MountsTypeEnum")
local Vector = require("Types.Vector")
local Vector3 = require("Types.Vector3").Vector3
local MountsConst = require("netio.protocol.mzm.gsp.mounts.MountsConst")
local MountsUIModel = require("Main.Mounts.MountsUIModel")
local SkillUtility = require("Main.Skill.SkillUtility")
local SkillTipMgr = require("Main.Skill.SkillTipMgr")
local ItemColor = require("consts.mzm.gsp.item.confbean.Color")
local def = MountsInfoPanel.define
local instance
def.field("table").uiObjs = nil
def.field("table").mounts = nil
def.field(MountsUIModel).model = nil
def.field("boolean").isDragModel = false
def.static("=>", MountsInfoPanel).Instance = function()
  if instance == nil then
    instance = MountsInfoPanel()
  end
  return instance
end
def.method("table").ShowPanel = function(self, mounts)
  if self.m_panel ~= nil or mounts == nil then
    return
  end
  self.mounts = mounts
  self:CreatePanel(RESPATH.PREFAB_MOUNTS_INFO, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:FillMountsInfo()
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.mounts = nil
  if self.model ~= nil then
    self.model:Destroy()
    self.model = nil
  end
  self.isDragModel = false
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Label_PowerNum = self.uiObjs.Img_Bg0:FindDirect("Label_PowerNum")
  self.uiObjs.Img_SX_Bg0 = self.uiObjs.Img_Bg0:FindDirect("Img_SX_Bg0")
  self.uiObjs.Group_Attribute = self.uiObjs.Img_Bg0:FindDirect("Group_Attribute")
  self.uiObjs.Group_StarAttribute = self.uiObjs.Img_Bg0:FindDirect("Group_StarAttribute")
  self.uiObjs.Label_StarTitle = self.uiObjs.Img_Bg0:FindDirect("Label_StarTitle")
  self.uiObjs.Group_Skill = self.uiObjs.Img_Bg0:FindDirect("Group_Skill")
end
def.method().FillMountsInfo = function(self)
  local mountsCfg = MountsUtils.GetMountsCfgById(self.mounts.mounts_cfg_id)
  local mountsRankCfg = MountsUtils.GetMountsCfgOfRank(self.mounts.mounts_cfg_id, self.mounts.mounts_rank)
  if mountsCfg == nil or mountsRankCfg == nil then
    self:DestroyPanel()
    return
  end
  local MountsName = self.uiObjs.Img_SX_Bg0:FindDirect("Label_Name")
  local Img_Type = self.uiObjs.Img_SX_Bg0:FindDirect("Img_Type")
  local Model_CW = self.uiObjs.Img_SX_Bg0:FindDirect("Model_CW")
  local uiModel = Model_CW:GetComponent("UIModel")
  GUIUtils.SetText(MountsName, string.format(textRes.Mounts[60], mountsCfg.mountsName, self.mounts.mounts_rank))
  GUIUtils.SetSprite(Img_Type, textRes.Mounts.MountsTypeSprite[mountsCfg.mountsType])
  self.model = MountsUtils.LoadMountsModel(uiModel, self.mounts.mounts_cfg_id, self.mounts.current_ornament_rank, self.mounts.color_id, function()
    if self.model ~= nil then
      self.model:SetDir(-135)
    end
  end)
  local mount_seat_num = self.uiObjs.Img_Bg0:FindDirect("Img_CW_RidingNum/Label_CW_AttributeNum03")
  GUIUtils.SetText(mount_seat_num, tostring(mountsCfg.maxMountRoleNum))
  local lableSXNumInPanel = 3
  local attrIndex = 1
  local propertyMap = mountsRankCfg.property
  for k, v in pairs(propertyMap) do
    local valueLabel = self.uiObjs.Group_Attribute:FindDirect(string.format("Img_CW_BgAttribute%02d/Label_CW_AttributeNum%02d", attrIndex, attrIndex))
    local nameLabel = self.uiObjs.Group_Attribute:FindDirect(string.format("Img_CW_BgAttribute%02d/Label_CW_Attribute%02d", attrIndex, attrIndex))
    local propertyCfg = _G.GetCommonPropNameCfg(k)
    if valueLabel and nameLabel and propertyCfg then
      local propertyName = propertyCfg.propName
      GUIUtils.SetActive(nameLabel, true)
      GUIUtils.SetActive(valueLabel, true)
      GUIUtils.SetText(nameLabel, propertyName)
      GUIUtils.SetText(valueLabel, v)
      attrIndex = attrIndex + 1
    end
  end
  for i = attrIndex, lableSXNumInPanel do
    local valueLabel = self.uiObjs.Group_Attribute:FindDirect(string.format("Img_CW_BgAttribute%02d/Label_CW_AttributeNum%02d", i, i))
    local nameLabel = self.uiObjs.Group_Attribute:FindDirect(string.format("Img_CW_BgAttribute%02d/Label_CW_Attribute%02d", i, i))
    GUIUtils.SetText(nameLabel, "")
    GUIUtils.SetText(valueLabel, "")
  end
  local curStarLevel = self.mounts.current_star_level
  local curStarNum = self.mounts.current_max_active_star_num
  local starProperty = {}
  local mountsStartMapCfg = MountsUtils.GetMountsStartLifeMapCfg(self.mounts.mounts_cfg_id)
  local starCount = 0
  if mountsStartMapCfg ~= nil then
    starCount = #mountsStartMapCfg
  end
  if curStarLevel > 1 and curStarNum == 0 then
    curStarLevel = curStarLevel - 1
    curStarNum = starCount
  end
  local mountsStarCfg = MountsUtils.GetMountsStartLifeCfgById(self.mounts.mounts_cfg_id)
  if mountsStarCfg ~= nil then
    for i = 1, starCount do
      local isActive = true
      local cfg
      if mountsStarCfg[i] ~= nil then
        if curStarLevel <= 1 then
          cfg = mountsStarCfg[i][1]
          if i > curStarNum then
            isActive = false
          end
        elseif i <= curStarNum then
          cfg = mountsStarCfg[i][curStarLevel]
        elseif i > curStarNum then
          cfg = mountsStarCfg[i][curStarLevel - 1]
        end
      end
      if cfg ~= nil then
        local property = cfg.propertyList[1]
        if property ~= nil then
          local showProperty = {}
          showProperty.nameKey = property.nameKey
          showProperty.isActive = isActive
          showProperty.value = property.value
          starProperty[#starProperty + 1] = showProperty
        end
      end
    end
  end
  local lableStarNumInPanel = 5
  local attrStarIndex = 1
  local starPropertyMap = starProperty
  for k, v in pairs(starPropertyMap) do
    local valueLabel = self.uiObjs.Group_StarAttribute:FindDirect(string.format("Img_CW_BgAttribute%02d/Label_CW_AttributeNum%02d", attrStarIndex, attrStarIndex))
    local nameLabel = self.uiObjs.Group_StarAttribute:FindDirect(string.format("Img_CW_BgAttribute%02d/Label_CW_Attribute%02d", attrStarIndex, attrStarIndex))
    local Label_Active = self.uiObjs.Group_StarAttribute:FindDirect(string.format("Img_CW_BgAttribute%02d/Label_Active", attrStarIndex))
    local propertyCfg = _G.GetCommonPropNameCfg(v.nameKey)
    if valueLabel and nameLabel and propertyCfg then
      local propertyName = propertyCfg.propName
      GUIUtils.SetActive(nameLabel, true)
      GUIUtils.SetActive(valueLabel, true)
      GUIUtils.SetActive(Label_Active, false)
      GUIUtils.SetText(nameLabel, propertyName)
      if v.isActive then
        GUIUtils.SetText(valueLabel, v.value)
      else
        GUIUtils.SetText(valueLabel, textRes.Mounts[110])
      end
      attrStarIndex = attrStarIndex + 1
    end
  end
  GUIUtils.SetActive(self.uiObjs.Label_StarTitle, attrStarIndex > 1)
  for i = attrStarIndex, lableStarNumInPanel do
    local valueLabel = self.uiObjs.Group_StarAttribute:FindDirect(string.format("Img_CW_BgAttribute%02d/Label_CW_AttributeNum%02d", i, i))
    local nameLabel = self.uiObjs.Group_StarAttribute:FindDirect(string.format("Img_CW_BgAttribute%02d/Label_CW_Attribute%02d", i, i))
    local Label_Active = self.uiObjs.Group_StarAttribute:FindDirect(string.format("Img_CW_BgAttribute%02d/Label_Active", i))
    GUIUtils.SetText(nameLabel, "")
    GUIUtils.SetText(valueLabel, "")
    GUIUtils.SetActive(Label_Active, false)
  end
  local Img_ZhudongSkill = self.uiObjs.Group_Skill:FindDirect("Img_ZhudongSkill")
  local Img_ZhudongSkillName = Img_ZhudongSkill:FindDirect("Label_SkillName")
  local ZhudongSkillIcon = Img_ZhudongSkill:FindDirect("Img_JN_IconSkill")
  local zhudongSkillDesc = textRes.Mounts[35]
  local skillId = 0
  local skillLevel = 0
  local needGray = false
  GUIUtils.SetItemCellSprite(Img_ZhudongSkill, MountsUtils.GetMountsSkillColor(mountsRankCfg.activeSkillIconColor))
  local mountsActiveSkillRankCfg = MountsUtils.GetMountsActiveSkillRankChange(self.mounts.mounts_cfg_id)
  if mountsActiveSkillRankCfg[self.mounts.mounts_rank] ~= nil then
    local curSkill = mountsActiveSkillRankCfg[self.mounts.mounts_rank]
    if curSkill ~= nil then
      if curSkill.skillId == 0 then
        if curSkill.nextSkillRank ~= nil then
          local nextSkill = mountsActiveSkillRankCfg[curSkill.nextSkillRank]
          if nextSkill ~= nil then
            skillId = nextSkill.skillId
            skillLevel = nextSkill.skillLevel
            needGray = true
          end
        end
      else
        skillId = curSkill.skillId
        skillLevel = curSkill.skillLevel
      end
    end
  end
  local skillCfg = SkillUtility.GetSkillCfg(skillId)
  if skillCfg ~= nil then
    GUIUtils.FillIcon(ZhudongSkillIcon:GetComponent("UITexture"), skillCfg.iconId)
    if needGray then
      GUIUtils.SetTextureEffect(ZhudongSkillIcon:GetComponent("UITexture"), GUIUtils.Effect.Gray)
    else
      GUIUtils.SetTextureEffect(ZhudongSkillIcon:GetComponent("UITexture"), GUIUtils.Effect.Normal)
    end
    zhudongSkillDesc = skillCfg.name
  else
    GUIUtils.FillIcon(ZhudongSkillIcon:GetComponent("UITexture"), 0)
  end
  GUIUtils.SetText(Img_ZhudongSkillName, zhudongSkillDesc)
  local unlockSkillRank = MountsUtils.GetMountsSortedUnlockPassiveSkillRank(self.mounts.mounts_cfg_id)
  local passiveNumInJN = 3
  for i = 1, passiveNumInJN do
    local passiveSkill = self.uiObjs.Group_Skill:FindDirect(string.format("Img_BeidongSkill_%d", i))
    if unlockSkillRank[i] == nil then
      GUIUtils.SetActive(passiveSkill, false)
    else
      GUIUtils.SetActive(passiveSkill, true)
      local skill = self.mounts.passive_skill_list[i]
      if skill ~= nil and self.mounts.mounts_rank >= unlockSkillRank[i] then
        local skillCfg = SkillUtility.GetSkillCfg(skill.current_passive_skill_cfg_id)
        GUIUtils.SetText(passiveSkill:FindDirect("Label_SkillName"), skillCfg.name)
        GUIUtils.FillIcon(passiveSkill:FindDirect("Img_JN_IconSkill"):GetComponent("UITexture"), skillCfg.iconId)
        local passiveSkillCfg = MountsUtils.GetMountsPassiveSkillCfgByMountsIdAndSkillId(self.mounts.mounts_cfg_id, skill.current_passive_skill_cfg_id)
        if passiveSkillCfg ~= nil then
          GUIUtils.SetItemCellSprite(passiveSkill, MountsUtils.GetMountsSkillColor(passiveSkillCfg.passiveSkillIconColor))
        else
          GUIUtils.SetItemCellSprite(passiveSkill, ItemColor.WHITE)
        end
      else
        GUIUtils.SetText(passiveSkill:FindDirect("Label_SkillName"), string.format(textRes.Mounts[9], unlockSkillRank[i]))
        GUIUtils.FillIcon(passiveSkill:FindDirect("Img_JN_IconSkill"):GetComponent("UITexture"), 0)
        GUIUtils.SetItemCellSprite(passiveSkill, ItemColor.WHITE)
      end
    end
  end
  local property = MountsMgr.Instance():PacketMountsProperty(self.mounts)
  local score = MountsUtils.CalculateMountsPropertyScore(property)
  GUIUtils.SetText(self.uiObjs.Label_PowerNum, score)
end
def.method("userdata").ShowMountsActiveSkillTips = function(self, source)
  if self.mounts ~= nil then
    local mountsActiveSkillRankCfg = MountsUtils.GetMountsActiveSkillRankChange(self.mounts.mounts_cfg_id)
    if mountsActiveSkillRankCfg[self.mounts.mounts_rank] == nil then
      Toast(textRes.Mounts[35])
    elseif mountsActiveSkillRankCfg[self.mounts.mounts_rank].skillId == 0 then
      if mountsActiveSkillRankCfg[self.mounts.mounts_rank + 1] ~= nil then
        SkillTipMgr.Instance():ShowTipByIdEx(mountsActiveSkillRankCfg[self.mounts.mounts_rank + 1].skillId, source, 0)
      end
    else
      SkillTipMgr.Instance():ShowTipByIdEx(mountsActiveSkillRankCfg[self.mounts.mounts_rank].skillId, source, 0)
    end
  end
end
def.method("number", "userdata").ShowMountsPassiveSkillTips = function(self, skillIdx, source)
  if self.mounts ~= nil then
    local skill = self.mounts.passive_skill_list[skillIdx]
    if skill ~= nil then
      SkillTipMgr.Instance():ShowTipByIdEx(skill.current_passive_skill_cfg_id, source, 0)
    else
      Toast(textRes.Mounts[11])
    end
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Img_ZhudongSkill" then
    self:ShowMountsActiveSkillTips(clickObj)
  elseif string.find(id, "Img_BeidongSkill_") then
    local idx = tonumber(string.sub(id, #"Img_BeidongSkill_" + 1))
    self:ShowMountsPassiveSkillTips(idx, clickObj)
  end
end
def.method("string").onDragStart = function(self, id)
  if id == "Model_CW" then
    self.isDragModel = true
  end
end
def.method("string").onDragEnd = function(self, id)
  self.isDragModel = false
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.model and self.isDragModel then
    self.model:SetDir(self.model.m_ang - dx / 2)
  end
end
MountsInfoPanel.Commit()
return MountsInfoPanel

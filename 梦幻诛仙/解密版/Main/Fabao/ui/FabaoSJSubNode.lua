local Lplus = require("Lplus")
local FabaoSubNodeBase = require("Main.Fabao.ui.FabaoSubNodeBase")
local ECPanelBase = require("GUI.ECPanelBase")
local FabaoUtils = require("Main.Fabao.FabaoUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ECUIModel = require("Model.ECUIModel")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local FabaoConst = require("netio.protocol.mzm.gsp.fabao.FaBaoConst")
local FabaoModule = Lplus.ForwardDeclare("FabaoModule")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local FabaoSJSubNode = Lplus.Extend(FabaoSubNodeBase, "FabaoSJSubNode")
local def = FabaoSJSubNode.define
def.field("table").m_UIObjs = nil
def.field(ECUIModel).m_UIModel = nil
def.override(ECPanelBase, "userdata").Init = function(self, base, nodeRoot)
  FabaoSubNodeBase.Init(self, base, nodeRoot)
end
def.override().OnShow = function(self)
  self:InitUI()
  self:InitData()
  self:Update()
end
def.override().OnHide = function(self)
  self.m_UIObjs = nil
  self:DestroyModel()
end
def.method().DestroyModel = function(self)
  if self.m_UIModel then
    self.m_UIModel:Destroy()
    self.m_UIModel = nil
  end
end
def.method().InitUI = function(self)
end
def.method().InitData = function(self)
end
def.override().Update = function(self)
  self:UpdateUI()
end
def.method().UpdateUI = function(self)
  local curFabao = self.m_CurFabao
  if nil == curFabao then
    return
  end
  local fabaoItemInfo = FabaoModule.GetFabaoItemInfo(curFabao.key, curFabao.fabaoType)
  local fabaoItemBase = ItemUtils.GetItemBase(fabaoItemInfo.id)
  local fabaoBase = ItemUtils.GetFabaoItem(fabaoItemInfo.id)
  local rootGroup = self.m_nodeRoot
  local modelGroup = rootGroup:FindDirect("Group_Icon/Icon_Equip01")
  local GroupInfo = rootGroup:FindDirect("Group_Info")
  local GroupSlider = rootGroup:FindDirect("Group_Slide")
  local GroupFull = rootGroup:FindDirect("Group_Full")
  local curFabaoExp = fabaoItemInfo.extraMap[ItemXStoreType.FABAO_CUR_EXP] or 0
  local curFabaoSkillID = fabaoItemInfo.extraMap[ItemXStoreType.FABAO_OWN_SKILL_ID] or 0
  local curFabaoLevel = fabaoItemInfo.extraMap[ItemXStoreType.FABAO_CUR_LV] or 1
  local curFabaoAttrId = fabaoBase.attrId
  local curFabaoScore = FabaoUtils.GetFabaoScore(curFabaoAttrId, curFabaoLevel, curFabaoSkillID)
  local nameLabel = GroupInfo:FindDirect("Label_Name"):GetComponent("UILabel")
  local levelLabel = GroupInfo:FindDirect("Label_LevelNumber"):GetComponent("UILabel")
  local scoreLabel = GroupInfo:FindDirect("Label_TotalNumber"):GetComponent("UILabel")
  nameLabel:set_text(fabaoItemBase.name)
  levelLabel:set_text(curFabaoLevel)
  scoreLabel:set_text(curFabaoScore)
  local isMaxLevel = FabaoUtils.IsMaxFabaoLevel(fabaoBase.classId, curFabaoLevel)
  if isMaxLevel then
    GroupInfo:SetActive(false)
    GroupFull:SetActive(true)
    local curProCfg = FabaoUtils.GetFabaoAttrTypeAndValue(curFabaoAttrId, curFabaoLevel)
    for i = 1, 3 do
      local curLabel = GroupFull:FindDirect(string.format("Label_CurrentAttribute_%d", i))
      if curProCfg then
        local curPro = curProCfg[i]
        if curPro and 0 ~= curPro.proType then
          curLabel:SetActive(true)
          local curAttr = FabaoUtils.GetFabaoProName(curPro.proType) .. string.format(" +%d", curPro.proValue)
          curLabel:GetComponent("UILabel"):set_text(curAttr)
        else
          curLabel:SetActive(false)
        end
      end
    end
  else
    GroupInfo:SetActive(true)
    GroupFull:SetActive(false)
    local curProCfg = FabaoUtils.GetFabaoAttrTypeAndValue(curFabaoAttrId, curFabaoLevel)
    local nextProCfg = FabaoUtils.GetFabaoAttrTypeAndValue(curFabaoAttrId, curFabaoLevel + 1)
    for i = 1, 3 do
      local curLabel = GroupInfo:FindDirect(string.format("Label_CurrentAttribute_%d", i))
      local nextLabel = GroupInfo:FindDirect(string.format("Label_NextAttribute_%d", i))
      if curProCfg then
        local curPro = curProCfg[i]
        if curPro and 0 ~= curPro.proType then
          curLabel:SetActive(true)
          local curAttr = FabaoUtils.GetFabaoProName(curPro.proType) .. string.format(" +%d", curPro.proValue)
          curLabel:GetComponent("UILabel"):set_text(curAttr)
        else
          curLabel:SetActive(false)
        end
      end
      if nextProCfg then
        local nextPro = nextProCfg[i]
        if nextPro and 0 ~= nextPro.proType then
          nextLabel:SetActive(true)
          local nextAttr = FabaoUtils.GetFabaoProName(nextPro.proType) .. string.format(" +%d", nextPro.proValue)
          nextLabel:GetComponent("UILabel"):set_text(nextAttr)
        else
          nextLabel:SetActive(false)
        end
      end
    end
  end
  local proInstruction = fabaoBase.proInstruction
  local proAlglorithmLabel1 = GroupInfo:FindDirect("Label_Algorithm_1"):GetComponent("UILabel")
  local proAlglorithmLabel2 = GroupInfo:FindDirect("Label_Algorithm_2"):GetComponent("UILabel")
  proAlglorithmLabel1:set_text(proInstruction)
  proAlglorithmLabel2:set_text(proInstruction)
  local levelLimitLabel = GroupInfo:FindDirect("Label_LevelLimit"):GetComponent("UILabel")
  local levelLimit = FabaoUtils.GetFabaoLevelLimitByRoleLevel(fabaoBase.classId)
  levelLimitLabel:set_text(levelLimit)
  warn("fabaoMax is  ~~~~ ", levelLimit, fabaoBase.classId)
  self:UpdateFabaoExpInfoView()
  self:UpdateFabaoModel(modelGroup)
end
def.method().UpdateFabaoExpInfoView = function(self)
  local curFabao = self.m_CurFabao
  if nil == curFabao then
    return
  end
  local rootGroup = self.m_nodeRoot
  if not rootGroup or rootGroup.isnil then
    return
  end
  local fabaoItemInfo = FabaoModule.GetFabaoItemInfo(curFabao.key, curFabao.fabaoType)
  local fabaoBase = ItemUtils.GetFabaoItem(fabaoItemInfo.id)
  local fabaoItemBase = ItemUtils.GetItemBase(fabaoItemInfo.id)
  local GroupInfo = rootGroup:FindDirect("Group_Info")
  local GroupSlider = rootGroup:FindDirect("Group_Slide")
  local curFabaoLevel = fabaoItemInfo.extraMap[ItemXStoreType.FABAO_CUR_LV] or 1
  local curFabaoExp = fabaoItemInfo.extraMap[ItemXStoreType.FABAO_CUR_EXP] or 0
  local isMaxLevel = FabaoUtils.IsMaxFabaoLevel(fabaoBase.classId, curFabaoLevel)
  local expLabel = GroupSlider:FindDirect("Label_ExpNum")
  local maxExpLabel = expLabel:FindDirect("Label")
  local SJBtn = rootGroup:FindDirect("Btn_SJ")
  if isMaxLevel then
    expLabel:GetComponent("UILabel"):set_text("")
    maxExpLabel:SetActive(true)
    SJBtn:SetActive(false)
    GroupSlider:FindDirect("Img_Bg"):GetComponent("UISlider").value = 1
  else
    local levelUpNeedExp = FabaoUtils.GetFabaoLevelUpNeedExp(fabaoBase.classId, curFabaoLevel)
    local expStr = string.format("%s/%s", curFabaoExp, levelUpNeedExp)
    maxExpLabel:SetActive(false)
    SJBtn:SetActive(true)
    expLabel:GetComponent("UILabel"):set_text(expStr)
    GroupSlider:FindDirect("Img_Bg"):GetComponent("UISlider").value = curFabaoExp / levelUpNeedExp
  end
end
def.method("userdata").UpdateFabaoModel = function(self, modelRoot)
  local curFabao = self.m_CurFabao
  if nil == curFabao then
    return
  end
  local uiModelComponent = modelRoot:GetComponent("UIModel")
  if nil == uiModelComponent then
    return
  end
  local fabaoItemInfo = FabaoModule.GetFabaoItemInfo(curFabao.key, curFabao.fabaoType)
  local fabaoBase = require("Main.Item.ItemUtils").GetFabaoItem(fabaoItemInfo.id)
  local modelId = fabaoBase.modelId
  local modelPath = GetModelPath(modelId)
  if nil == modelPath then
    return
  end
  local function SetModelStatus(uiModel)
    if nil == uiModel or nil == uiModel.m_model then
      return
    end
    local offsetCfg = FabaoUtils.GetFabaoModelOffset(modelId)
    uiModelComponent:set_mOffsetX(offsetCfg.offsetX)
    uiModelComponent:set_mOffsetY(offsetCfg.offsetY)
    uiModel:SetDir(180)
    uiModel:SetScale(3)
    uiModel:SetPos(0, 10)
    uiModelComponent.modelGameObject = uiModel.m_model
    local color = FabaoUtils.GetFabaoModelColor(fabaoItemInfo.id)
    if color then
      local render = uiModel.m_model:GetComponentInChildren("SkinnedMeshRenderer")
      render.material:SetColor("_Tint", color)
    end
  end
  local function loadCallback(ret)
    if nil == self.m_UIModel or nil == self.m_UIModel.m_model then
      return
    end
    SetModelStatus(self.m_UIModel)
  end
  self:DestroyModel()
  self.m_UIModel = ECUIModel.new(modelId)
  self.m_UIModel.m_bUncache = true
  self.m_UIModel:LoadUIModel(modelPath, loadCallback)
end
def.override("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if "Btn_SJ" == id then
    self:OnClickLevelUp(clickObj)
  end
end
def.method("userdata").OnClickLevelUp = function(self, clickObj)
  local curFabao = self.m_CurFabao
  if nil == curFabao then
    return
  end
  if _G.CheckCrossServerAndToast() then
    return
  end
  local FabaoModule = Lplus.ForwardDeclare("FabaoModule")
  local fabaoItemInfo = FabaoModule.GetFabaoItemInfo(curFabao.key, curFabao.fabaoType)
  local fabaoBase = ItemUtils.GetFabaoItem(fabaoItemInfo.id)
  local fabaoItemBase = ItemUtils.GetItemBase(fabaoItemInfo.id)
  local fabaoLevel = fabaoItemInfo.extraMap[ItemXStoreType.FABAO_CUR_LV]
  local fabaoClassId = fabaoBase.classId
  local levelUpNeedExp = FabaoUtils.GetFabaoLevelUpNeedExp(fabaoClassId, fabaoLevel)
  local curFabaoExp = fabaoItemInfo.extraMap[ItemXStoreType.FABAO_CUR_EXP]
  local isMaxLevel = FabaoUtils.IsMaxFabaoLevel(fabaoBase.classId, fabaoLevel)
  if isMaxLevel then
    Toast(textRes.Fabao[84])
    return
  end
  if levelUpNeedExp <= curFabaoExp then
    local needHeroLevel = FabaoUtils.GetNeedRoleLevelUpToFabaoLevel(fabaoBase.classId, fabaoLevel + 1)
    local heroLevel = require("Main.Hero.Interface").GetHeroProp().level
    if needHeroLevel > heroLevel then
      Toast(string.format(textRes.Fabao[83], needHeroLevel))
      return
    end
  end
  local function addFabaoExp(itemId, isAll)
    if itemId then
      local ItemModule = require("Main.Item.ItemModule")
      local itemKey, itemInfo = ItemModule.Instance():SelectOneItemByItemId(ItemModule.BAG, itemId)
      if -1 ~= itemKey then
        local fabaouuid = fabaoItemInfo.uuid[1]
        local equiped = FabaoConst.EQUIPED
        if not self.m_CurFabao.equiped then
          equiped = FabaoConst.UNEQUIPED
        end
        local useCount = 1
        if isAll then
          useCount = itemInfo.number
        end
        FabaoModule.RequestAddFabaoExp(equiped, fabaouuid, itemKey, useCount)
        return true
      else
        return false
      end
    else
      warn("add fabaoExp itemid is error ~~~~~~")
      return false
    end
  end
  local expItemIds = ItemUtils.GetItemTypeRefIdList(ItemType.FABAO_EXP_ITEM)
  if expItemIds then
    local canUseIds = {}
    for k, v in pairs(expItemIds) do
      local expItemBase = ItemUtils.GetFabaoExpItem(v)
      if expItemBase and expItemBase.isShowUpDlg then
        table.insert(canUseIds, v)
      end
    end
    local CommonItemUsePanel = require("Main.Wing.ui.CommonItemUse")
    CommonItemUsePanel.ShowCommonUseByItemId(textRes.Fabao[90], canUseIds, addFabaoExp)
  end
end
def.method("number", "number").OnSFabaoAddExpSucc = function(self, fabaoId, addExp)
  if self.m_nodeRoot and not self.m_nodeRoot.isnil and self.m_nodeRoot:get_activeInHierarchy() then
    local curFabaoId = self.m_CurFabao.id
    if curFabaoId == fabaoId then
      warn("add exp succ !!!!!!!!! ", fabaoId, addExp)
      local fabaoItemInfo = FabaoModule.GetFabaoItemInfo(curFabao.key, curFabao.fabaoType)
      if fabaoItemInfo then
        fabaoItemInfo.extraMap[ItemXStoreType.FABAO_CUR_EXP] = fabaoItemInfo.extraMap[ItemXStoreType.FABAO_CUR_EXP] + addExp
      end
      self:UpdateFabaoExpInfoView()
    end
  end
end
def.method("number", "number", "number").OnSFabaoLevelUp = function(self, fabaoId, oldLevel, curLevel)
  if self.m_nodeRoot and not self.m_nodeRoot.isnil and self.m_nodeRoot:get_activeInHierarchy() then
    local curFabaoId = self.m_CurFabao.id
    if curFabaoId == fabaoId then
      warn("OnSFabaoLevelUp!!!!!!!!! ", fabaoId, oldLevel, curLevel)
      local fabaoItemInfo = FabaoModule.GetFabaoItemInfo(curFabao.key, curFabao.fabaoType)
      if fabaoItemInfo then
        fabaoItemInfo.extraMap[ItemXStoreType.FABAO_CUR_LV] = curLevel
      end
      self:UpdateUI()
    end
  end
end
def.method().OnLevelUpLimitByRoleLv = function(self)
  if self.m_nodeRoot and not self.m_nodeRoot.isnil and self.m_nodeRoot:get_activeInHierarchy() and self.m_CurFabao then
    local classId = self.m_CurFabao.classId
    local nextRoleLevel = FabaoUtils.GetNextLevelUpHeroLevel(classId)
    Toast(string.format(textRes.Fabao[114], nextRoleLevel))
  end
end
FabaoSJSubNode.Commit()
return FabaoSJSubNode

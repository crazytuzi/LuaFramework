local Lplus = require("Lplus")
local FabaoSubNodeBase = require("Main.Fabao.ui.FabaoSubNodeBase")
local ECPanelBase = require("GUI.ECPanelBase")
local FabaoUtils = require("Main.Fabao.FabaoUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local SkillUtility = require("Main.Skill.SkillUtility")
local ECUIModel = require("Model.ECUIModel")
local FabaoModule = Lplus.ForwardDeclare("FabaoModule")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local OneClickStarUpEasy = require("Main.Fabao.OneClickStarUpEasy")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local FabaoConst = require("netio.protocol.mzm.gsp.fabao.FaBaoConst")
local GUIUtils = require("GUI.GUIUtils")
local FabaoSXSubNode = Lplus.Extend(FabaoSubNodeBase, "FabaoSXSubNode")
local def = FabaoSXSubNode.define
def.field("table").m_UIObjs = nil
def.field(ECUIModel).m_UIModel = nil
def.field(ECUIModel).m_UIModel2 = nil
def.field("boolean").m_IsWaitingYuanBaoPrice = false
def.field("boolean").m_NeedYuanBaoReplace = false
def.field("table").m_YuanBaoPriceMap = nil
def.field("number").m_NeedYuanBaoNum = 0
def.override(ECPanelBase, "userdata").Init = function(self, base, nodeRoot)
  FabaoSubNodeBase.Init(self, base, nodeRoot)
end
def.override().OnShow = function(self)
  warn("shengxing  sub node on show ~~~~~~~~~~~~ ")
  self:InitData()
  self:InitUI()
  self:Update()
end
def.override().OnHide = function(self)
  self:DestroyModel()
  self.m_UIObjs = nil
  self.m_IsWaitingYuanBaoPrice = false
  self.m_NeedYuanBaoReplace = false
  self.m_YuanBaoPriceMap = nil
  self.m_NeedYuanBaoNum = 0
end
def.override().Update = function(self)
  self:UpdateUI()
end
def.method().InitUI = function(self)
  if nil == self.m_UIObjs then
    self.m_UIObjs = {}
  end
  self.m_UIObjs.FullRankRoot = self.m_nodeRoot:FindDirect("SXFull")
  self.m_UIObjs.CurrentGroup = self.m_nodeRoot:FindDirect("Group_CurrentEquip")
  self.m_UIObjs.PreViewGroup = self.m_nodeRoot:FindDirect("Group_PreviewEquip")
  self.m_UIObjs.NeedItemGroup = self.m_nodeRoot:FindDirect("Img_BgItem")
  self.m_UIObjs.SliderGroup = self.m_nodeRoot:FindDirect("Group_Slide")
  self.m_UIObjs.SXBtn = self.m_nodeRoot:FindDirect("Btn_SX")
  self.m_UIObjs.PreViewBtn = self.m_nodeRoot:FindDirect("Btn_Preview")
  self.m_UIObjs.TipBtn = self.m_nodeRoot:FindDirect("Btn_Tip")
  self.m_UIObjs.AddBtn = self.m_nodeRoot:FindDirect("Btn_Add")
  self.m_UIObjs.OneClick = self.m_nodeRoot:FindDirect("Btn_StarUp")
  self.m_UIObjs.NeedItemGroup:FindDirect("Btn_UseGold"):GetComponent("UIToggle").value = false
end
def.method().DestroyModel = function(self)
  if self.m_UIModel then
    self.m_UIModel:Destroy()
    self.m_UIModel = nil
  end
  if self.m_UIModel2 then
    self.m_UIModel2:Destroy()
    self.m_UIModel2 = nil
  end
end
def.method().InitData = function(self)
  self.m_UIObjs = {}
  self.m_IsWaitingYuanBaoPrice = false
  self.m_NeedYuanBaoReplace = false
  self.m_YuanBaoPriceMap = nil
  self.m_NeedYuanBaoNum = 0
end
def.method("boolean").ShowMaxRankView = function(self, isMax)
  self.m_UIObjs.FullRankRoot:SetActive(isMax)
  self.m_UIObjs.CurrentGroup:SetActive(not isMax)
  self.m_UIObjs.PreViewGroup:SetActive(not isMax)
  self.m_UIObjs.NeedItemGroup:SetActive(not isMax)
  self.m_UIObjs.SliderGroup:SetActive(not isMax)
  self.m_UIObjs.SXBtn:SetActive(not isMax)
  self.m_UIObjs.PreViewBtn:SetActive(not isMax)
  self.m_UIObjs.TipBtn:SetActive(not isMax)
  self.m_UIObjs.AddBtn:SetActive(not isMax)
end
def.method().UpdateMaxRankView = function(self)
  local curFabao = self.m_CurFabao
  if nil == curFabao then
    return
  end
  local fabaoItemInfo = FabaoModule.GetFabaoItemInfo(curFabao.key, curFabao.fabaoType)
  local fabaoBase = ItemUtils.GetFabaoItem(fabaoItemInfo.id)
  local fabaoItemBase = ItemUtils.GetItemBase(fabaoItemInfo.id)
  local nameLabel = self.m_UIObjs.FullRankRoot:FindDirect("Img_SX_BgFabao/Label_FabaoName")
  nameLabel:GetComponent("UILabel"):set_text(fabaoItemBase.name)
  local CurrentGroup = self.m_UIObjs.FullRankRoot:FindDirect("Img_SX_BgFabao/Group_Current")
  local attrNum = {}
  local attrName = {}
  attrNum[1] = CurrentGroup:FindDirect("Label_QL_AttributeNum1_1")
  attrNum[2] = CurrentGroup:FindDirect("Label_QL_AttributeNum2_1")
  attrNum[3] = CurrentGroup:FindDirect("Label_QL_AttributeNum3_1")
  attrName[1] = CurrentGroup:FindDirect("Label1")
  attrName[2] = CurrentGroup:FindDirect("Label2")
  attrName[3] = CurrentGroup:FindDirect("Label3")
  local fabaoLevel = fabaoItemInfo.extraMap[ItemXStoreType.FABAO_CUR_LV]
  local attrId = fabaoBase.attrId
  local proCfg = FabaoUtils.GetFabaoAttrTypeAndValue(attrId, fabaoLevel)
  for i = 1, 3 do
    local pro = proCfg[i]
    if pro and 0 ~= pro.proType then
      attrName[i]:SetActive(true)
      attrNum[i]:SetActive(true)
      local proName = FabaoUtils.GetFabaoProName(pro.proType)
      local proNum = pro.proValue
      attrName[i]:GetComponent("UILabel"):set_text(proName)
      attrNum[i]:GetComponent("UILabel"):set_text("+" .. tostring(proNum))
    else
      attrName[i]:SetActive(false)
      attrNum[i]:SetActive(false)
    end
  end
  local SkillBg = CurrentGroup:FindDirect("Img_SkillBg")
  local skillTexture = SkillBg:FindDirect("Img_SkillIcon"):GetComponent("UITexture")
  local skillId = fabaoItemInfo.extraMap[ItemXStoreType.FABAO_OWN_SKILL_ID]
  if skillId then
    local skillCfg = SkillUtility.GetSkillCfg(skillId)
    local skillIconId = skillCfg.iconId
    GUIUtils.FillIcon(skillTexture, skillIconId)
  else
    skillTexture.mainTexture = nil
  end
  local modelRoot = self.m_UIObjs.FullRankRoot:FindDirect("Img_SX_BgFabao/Icon_BgEquip/Icon_Equip")
  self:UpdateFabaoModel(modelRoot, false)
end
def.method().UpdateUI = function(self)
  local curFabao = self.m_CurFabao
  if nil == curFabao then
    return
  end
  local FabaoItemInfo = FabaoModule.GetFabaoItemInfo(curFabao.key, curFabao.fabaoType)
  local isMaxRank = FabaoUtils.IsMaxRankFabao(FabaoItemInfo.id)
  warn("rank max info ~~~~~~ ", curFabao.key, curFabao.fabaoType, FabaoItemInfo.id, isMaxRank)
  if isMaxRank then
    self:ShowMaxRankView(true)
    self:UpdateMaxRankView()
    return
  end
  self:ShowMaxRankView(false)
  self:UpdateAttrView()
  self:UpdateSkillView()
  self:UpdateButtomView()
  local modelRoot1 = self.m_UIObjs.CurrentGroup:FindDirect("Icon_Equip")
  local modelRoot2 = self.m_UIObjs.PreViewGroup:FindDirect("Icon_Equip")
  self:UpdateFabaoModel(modelRoot1, false)
  self:UpdateFabaoModel(modelRoot2, true)
  local open = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_FABAO_AUTO_RANK)
  if open then
    self.m_UIObjs.OneClick:SetActive(true)
  else
    self.m_UIObjs.OneClick:SetActive(false)
  end
end
def.method().UpdateAttrView = function(self)
  local curFabao = self.m_CurFabao
  if nil == curFabao then
    return
  end
  local CurrentGroup = self.m_UIObjs.CurrentGroup
  local PreViewGroup = self.m_UIObjs.PreViewGroup
  local currentNameLabel = CurrentGroup:FindDirect("Label_Name")
  local previewNameLabel = PreViewGroup:FindDirect("Label_Name")
  local fabaoItemInfo = FabaoModule.GetFabaoItemInfo(curFabao.key, curFabao.fabaoType)
  local curFabaoId = fabaoItemInfo.id
  local curFabaoItemBase = ItemUtils.GetItemBase(curFabaoId)
  local curFabaoBase = ItemUtils.GetFabaoItem(curFabaoId)
  local nextFabaoId = FabaoUtils.GetNextRankFabaoId(fabaoItemInfo.id)
  local nextFabaoBase = require("Main.Item.ItemUtils").GetFabaoItem(nextFabaoId)
  local nextFabaoItemBase = ItemUtils.GetItemBase(nextFabaoId)
  local curFabaoLevel = fabaoItemInfo.extraMap[ItemXStoreType.FABAO_CUR_LV]
  currentNameLabel:GetComponent("UILabel"):set_text(curFabaoItemBase.name)
  previewNameLabel:GetComponent("UILabel"):set_text(nextFabaoItemBase.name)
  local curProCfg = FabaoUtils.GetFabaoAttrTypeAndValue(curFabaoBase.attrId, curFabaoLevel)
  local nextProCfg = FabaoUtils.GetFabaoAttrTypeAndValue(nextFabaoBase.attrId, curFabaoLevel)
  local curAttrLabel = {}
  local nextAttrLabel = {}
  curAttrLabel[1] = CurrentGroup:FindDirect("Label_AttributeNumber1")
  curAttrLabel[2] = CurrentGroup:FindDirect("Label_AttributeNumber2")
  curAttrLabel[3] = CurrentGroup:FindDirect("Label_AttributeNumber3")
  nextAttrLabel[1] = PreViewGroup:FindDirect("Label_AttributeNumber1")
  nextAttrLabel[2] = PreViewGroup:FindDirect("Label_AttributeNumber2")
  nextAttrLabel[3] = PreViewGroup:FindDirect("Label_AttributeNumber3")
  for i = 1, 3 do
    if curProCfg[i] and 0 ~= curProCfg[i].proType then
      curAttrLabel[i]:SetActive(true)
      local attrStr = FabaoUtils.GetFabaoProName(curProCfg[i].proType) .. string.format(" +%d", curProCfg[i].proValue)
      curAttrLabel[i]:GetComponent("UILabel"):set_text(attrStr)
    else
      curAttrLabel[i]:SetActive(false)
    end
    if nextProCfg[i] and 0 ~= nextProCfg[i].proType then
      nextAttrLabel[i]:SetActive(true)
      local attrStr = FabaoUtils.GetFabaoProName(nextProCfg[i].proType) .. string.format(" +%d", nextProCfg[i].proValue)
      nextAttrLabel[i]:GetComponent("UILabel"):set_text(attrStr)
    else
      nextAttrLabel[i]:SetActive(false)
    end
  end
  local proInstruction1 = curFabaoBase.proInstruction
  local proInstruction2 = nextFabaoBase.proInstruction
  local alglorithmLabel1 = CurrentGroup:FindDirect("Label_Algorithm_1"):GetComponent("UILabel")
  local alglorithmLabel2 = PreViewGroup:FindDirect("Label_Algorithm_2"):GetComponent("UILabel")
  alglorithmLabel1:set_text(proInstruction1)
  alglorithmLabel2:set_text(proInstruction2)
end
def.method().UpdateSkillView = function(self)
  if nil == self.m_CurFabao then
    return
  end
  local fabaoItemInfo = FabaoModule.GetFabaoItemInfo(self.m_CurFabao.key, self.m_CurFabao.fabaoType)
  local curFabaoSkillId = fabaoItemInfo.extraMap[ItemXStoreType.FABAO_OWN_SKILL_ID]
  local nextRankSkillId = FabaoUtils.GetFabaoNextRankSkillId(curFabaoSkillId)
  warn("nextSkill is ~~~~~ ", nextRankSkillId)
  if 0 == nextRankSkillId then
    nextRankSkillId = curFabaoSkillId
  end
  local currentSkillBg = self.m_nodeRoot:FindDirect("Group_CurrentEquip/Img_BgSkill")
  local currentSkillTexture = currentSkillBg:FindDirect("Icon_Skill")
  local nextSkillTexture1 = self.m_nodeRoot:FindDirect("Group_PreviewEquip/Img_BgSkill1/Icon_Skill")
  local nextSkillTexture2 = self.m_nodeRoot:FindDirect("Group_PreviewEquip/Img_BgSkill2/Icon_Skill")
  local curSkillCfg = SkillUtility.GetSkillCfg(curFabaoSkillId)
  if curSkillCfg then
    local skillIconId = curSkillCfg.iconId
    GUIUtils.FillIcon(currentSkillTexture:GetComponent("UITexture"), skillIconId)
  end
  local nextRankSkillCfg = SkillUtility.GetSkillCfg(nextRankSkillId)
  if nextRankSkillCfg then
    local nextSkillIconId = nextRankSkillCfg.iconId
    GUIUtils.FillIcon(nextSkillTexture1:GetComponent("UITexture"), nextSkillIconId)
  end
  local rankSkillId = fabaoItemInfo.extraMap[ItemXStoreType.FABAO_RANK_RANDOM_SKILL_ID]
  if rankSkillId and 0 ~= rankSkillId then
    local rankSkillCfg = SkillUtility.GetSkillCfg(rankSkillId)
    if rankSkillCfg then
      local rankSkillIconId = rankSkillCfg.iconId
      nextSkillTexture2:SetActive(true)
      GUIUtils.FillIcon(nextSkillTexture2:GetComponent("UITexture"), rankSkillIconId)
    else
      nextSkillTexture2:SetActive(false)
      nextSkillTexture2:GetComponent("UITexture").mainTexture = nil
    end
  else
    nextSkillTexture2:GetComponent("UITexture").mainTexture = nil
  end
end
def.method().UpdateButtomView = function(self)
  if nil == self.m_CurFabao then
    return
  end
  local fabaoItemInfo = FabaoModule.GetFabaoItemInfo(self.m_CurFabao.key, self.m_CurFabao.fabaoType)
  local fabaoBase = ItemUtils.GetFabaoItem(fabaoItemInfo.id)
  local fabaoItemBase = ItemUtils.GetItemBase(fabaoItemInfo.id)
  local curRankExp = fabaoItemInfo.extraMap[ItemXStoreType.FABAO_CUR_RANK_EXP]
  local needRankExp = FabaoUtils.GetRankNeedScore(fabaoBase.rankId)
  warn("cur rank exp ~~~~~~ ", curRankExp, needRankExp)
  local rankSkillId = fabaoItemInfo.extraMap[ItemXStoreType.FABAO_RANK_RANDOM_SKILL_ID]
  if curRankExp >= needRankExp or rankSkillId and rankSkillId > 0 then
    self.m_UIObjs.NeedItemGroup:SetActive(true)
    self.m_UIObjs.SXBtn:SetActive(true)
    self.m_UIObjs.SliderGroup:SetActive(false)
    self.m_UIObjs.AddBtn:SetActive(false)
    if rankSkillId and 0 ~= rankSkillId then
      self.m_UIObjs.SXBtn:FindDirect("Img_Red"):SetActive(true)
    else
      self.m_UIObjs.SXBtn:FindDirect("Img_Red"):SetActive(false)
    end
    local needItemId, needItemNum = FabaoUtils.GetFabaoRankUpNeedItemInfo(fabaoBase.rankId)
    local haveItemNum = require("Main.Item.ItemModule").Instance():GetItemCountById(needItemId)
    local needItemBase = ItemUtils.GetItemBase(needItemId)
    local needItemName = needItemBase.name
    local needItemIconId = needItemBase.icon
    local itemTexture = self.m_UIObjs.NeedItemGroup:FindDirect("Icon_Item")
    local nameLabel = self.m_UIObjs.NeedItemGroup:FindDirect("Label_Name")
    local numLabel = self.m_UIObjs.NeedItemGroup:FindDirect("Label_Num")
    nameLabel:GetComponent("UILabel"):set_text(needItemName)
    numLabel:GetComponent("UILabel"):set_text(string.format("%d/%d", needItemNum, haveItemNum))
    if needItemNum <= haveItemNum then
      numLabel:GetComponent("UILabel"):set_textColor(Color.green)
    else
      numLabel:GetComponent("UILabel"):set_textColor(Color.red)
    end
    GUIUtils.FillIcon(itemTexture:GetComponent("UITexture"), needItemIconId)
  else
    self.m_UIObjs.NeedItemGroup:SetActive(false)
    self.m_UIObjs.SliderGroup:SetActive(true)
    self.m_UIObjs.SXBtn:SetActive(false)
    self.m_UIObjs.AddBtn:SetActive(true)
    local toggleBtn = self.m_UIObjs.NeedItemGroup:FindDirect("Btn_UseGold")
    toggleBtn:GetComponent("UIToggle").value = false
    self.m_IsWaitingYuanBaoPrice = false
    self.m_NeedYuanBaoReplace = false
    self.m_NeedYuanBaoNum = 0
    self.m_YuanBaoPriceMap = nil
    local uiSlider = self.m_UIObjs.SliderGroup:FindDirect("Img_Bg"):GetComponent("UISlider")
    local rankLabel = self.m_UIObjs.SliderGroup:FindDirect("Label_ExpNum")
    uiSlider.value = curRankExp / needRankExp
    local rankStr = string.format("%d/%d", curRankExp, needRankExp)
    rankLabel:GetComponent("UILabel"):set_text(rankStr)
  end
  self:UpdateBtnState()
end
def.method().UpdateBtnState = function(self)
  local toggleBtn = self.m_nodeRoot:FindDirect("Img_BgItem/Btn_UseGold")
  local uiToggle = toggleBtn:GetComponent("UIToggle")
  local SXBtnLabel = self.m_nodeRoot:FindDirect("Btn_SX/Label_SX")
  local yuanbaoGroup = self.m_nodeRoot:FindDirect("Btn_SX/Group_Yuanbao")
  local fabaoItemInfo = FabaoModule.GetFabaoItemInfo(self.m_CurFabao.key, self.m_CurFabao.fabaoType)
  local fabaoBase = ItemUtils.GetFabaoItem(fabaoItemInfo.id)
  local needItemId, needItemNum = FabaoUtils.GetFabaoRankUpNeedItemInfo(fabaoBase.rankId)
  local haveItemNum = require("Main.Item.ItemModule").Instance():GetItemCountById(needItemId)
  local curValue = uiToggle.value
  if curValue and self.m_NeedYuanBaoReplace and self.m_YuanBaoPriceMap and self.m_YuanBaoPriceMap[needItemId] then
    if needItemNum <= haveItemNum then
      uiToggle.value = false
      yuanbaoGroup:SetActive(false)
      SXBtnLabel:SetActive(true)
      self.m_IsWaitingYuanBaoPrice = false
      self.m_NeedYuanBaoReplace = false
      self.m_YuanBaoPriceMap = nil
      self.m_NeedYuanBaoNum = 0
      return
    end
    yuanbaoGroup:SetActive(true)
    SXBtnLabel:SetActive(false)
    local yuanbaoLabel = yuanbaoGroup:FindDirect("Label_Money")
    local price = self.m_YuanBaoPriceMap[needItemId]
    self.m_NeedYuanBaoNum = price * (needItemNum - haveItemNum)
    yuanbaoLabel:GetComponent("UILabel"):set_text(self.m_NeedYuanBaoNum)
  else
    uiToggle.value = false
    yuanbaoGroup:SetActive(false)
    SXBtnLabel:SetActive(true)
    self.m_IsWaitingYuanBaoPrice = false
    self.m_NeedYuanBaoReplace = false
    self.m_YuanBaoPriceMap = nil
    self.m_NeedYuanBaoNum = 0
  end
end
def.method("userdata", "boolean").UpdateFabaoModel = function(self, modelRoot, isPreView)
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
  local nextFabaoId = FabaoUtils.GetNextRankFabaoId(fabaoItemInfo.id)
  local modelId = 0
  local fabaoId = 0
  if not isPreView then
    modelId = fabaoBase.modelId
    fabaoId = fabaoItemInfo.id
  else
    local nextFabaoBase = require("Main.Item.ItemUtils").GetFabaoItem(nextFabaoId)
    modelId = nextFabaoBase.modelId
    fabaoId = nextFabaoId
  end
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
    uiModel:SetPos(0, 0)
    uiModelComponent.modelGameObject = uiModel.m_model
    local color = FabaoUtils.GetFabaoModelColor(fabaoId)
    if color then
      local render = uiModel.m_model:GetComponentInChildren("SkinnedMeshRenderer")
      render.material:SetColor("_Tint", color)
    end
  end
  if not isPreView then
    local function loadCallback(ret)
      if nil == self.m_UIModel or nil == self.m_UIModel.m_model then
        return
      end
      SetModelStatus(self.m_UIModel)
    end
    if self.m_UIModel then
      self.m_UIModel:Destroy()
      self.m_UIModel = nil
    end
    self.m_UIModel = ECUIModel.new(modelId)
    self.m_UIModel.m_bUncache = true
    self.m_UIModel:LoadUIModel(modelPath, loadCallback)
  else
    local function loadCallback(ret)
      if nil == self.m_UIModel2 or nil == self.m_UIModel2.m_model then
        return
      end
      SetModelStatus(self.m_UIModel2)
    end
    if self.m_UIModel2 then
      self.m_UIModel2:Destroy()
      self.m_UIModel2 = nil
    end
    self.m_UIModel2 = ECUIModel.new(modelId)
    self.m_UIModel2.m_bUncache = true
    self.m_UIModel2:LoadUIModel(modelPath, loadCallback)
  end
end
def.method("userdata", "string", "number").ShowGetItemTips = function(self, obj, comName, itemid)
  local position = obj.position
  local screenPosition = WorldPosToScreen(position.x, position.y)
  local sprite = obj:GetComponent(comName)
  local width = sprite:get_width()
  local height = sprite:get_height()
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  ItemTipsMgr.Instance():ShowBasicTips(itemid, screenPosition.x, screenPosition.y, width, height, 0, true)
end
def.override("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if "Btn_UseGold" == id then
    self:OnClickYuanBaoReplace(clickObj)
  elseif "Btn_SX" == id then
    self:OnClickRankUp(clickObj)
  elseif "Btn_Add" == id then
    self:OnClickAddRankExp()
  elseif "Img_BgItem" == id then
    local FabaoItemInfo = FabaoModule.GetFabaoItemInfo(self.m_CurFabao.key, self.m_CurFabao.fabaoType)
    local fabaoBase = ItemUtils.GetFabaoItem(FabaoItemInfo.id)
    local needItemId, needItemNum = FabaoUtils.GetFabaoRankUpNeedItemInfo(fabaoBase.rankId)
    self:ShowGetItemTips(clickObj, "UISprite", needItemId)
  elseif string.find(id, "Img_BgSkill") then
    self:ShowSkillTip(clickObj)
  elseif "Img_SkillBg" == id then
    self:ShowSkillTip(clickObj)
  elseif "Btn_Preview" == id then
    self:OnClickShowPreViewTip(clickObj)
  elseif "Btn_Tip" == id then
    local hoverTipId = FabaoUtils.GetFabaoRankUpHoverTipId()
    GUIUtils.ShowHoverTip(hoverTipId, 0, 0)
  elseif "Btn_StarUp" == id and self.m_CurFabao ~= nil then
    local FabaoItemInfo = FabaoModule.GetFabaoItemInfo(self.m_CurFabao.key, self.m_CurFabao.fabaoType)
    local nextFabaoId = FabaoUtils.GetNextRankFabaoId(FabaoItemInfo.id)
    local cfg = OneClickStarUpEasy.GetOneClickCfg(nextFabaoId)
    if cfg then
      local OneKeyStarUpDlg = require("Main.Fabao.ui.OneClickStarUpDlg")
      local fabaoItemInfo = FabaoModule.GetFabaoItemInfo(self.m_CurFabao.key, self.m_CurFabao.fabaoType)
      OneKeyStarUpDlg.Instance():ShowPanel(fabaoItemInfo, self.m_CurFabao.key, self.m_CurFabao.equiped)
    else
      local fabaoBase = ItemUtils.GetFabaoItem(FabaoItemInfo.id)
      Toast(string.format(textRes.Fabao[142], fabaoBase.rank))
    end
  end
end
def.method("userdata").OnClickShowPreViewTip = function(self, clickObj)
  local fabaoItemInfo = FabaoModule.GetFabaoItemInfo(self.m_CurFabao.key, self.m_CurFabao.fabaoType)
  local fabaoId = fabaoItemInfo.id
  local nextRankFabaoId = FabaoUtils.GetNextRankFabaoId(fabaoId)
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  ItemTipsMgr.Instance():ShowFabaoSpecialTip(nextRankFabaoId, true, 0, 0, 0, 0, 0, false)
end
def.method("userdata").ShowSkillTip = function(self, clickObj)
  local fabaoItemInfo = FabaoModule.GetFabaoItemInfo(self.m_CurFabao.key, self.m_CurFabao.fabaoType)
  local skillId = 0
  local name = clickObj.name
  if name == "Img_BgSkill2" then
    local rankSkillId = fabaoItemInfo.extraMap[ItemXStoreType.FABAO_RANK_RANDOM_SKILL_ID]
    if rankSkillId and 0 ~= rankSkillId then
      skillId = rankSkillId
    else
      Toast(textRes.Fabao[97])
      return
    end
  elseif "Img_BgSkill" == name or "Img_SkillBg" == name then
    skillId = fabaoItemInfo.extraMap[ItemXStoreType.FABAO_OWN_SKILL_ID]
  elseif "Img_BgSkill1" == name then
    local curSkillId = fabaoItemInfo.extraMap[ItemXStoreType.FABAO_OWN_SKILL_ID]
    skillId = FabaoUtils.GetFabaoNextRankSkillId(curSkillId)
  end
  if skillId and 0 ~= skillId then
    require("Main.Skill.SkillTipMgr").Instance():ShowTipByIdEx(skillId, clickObj, 0)
  end
end
def.method("userdata").OnClickRankUp = function(self, clickObj)
  local curFabao = self.m_CurFabao
  if nil == curFabao then
    warn("~~~~~~cur fabao is nil ~~~~~~ ")
    return
  end
  if _G.CheckCrossServerAndToast() then
    return
  end
  local FabaoItemInfo = FabaoModule.GetFabaoItemInfo(curFabao.key, curFabao.fabaoType)
  local rankSkillId = FabaoItemInfo.extraMap[ItemXStoreType.FABAO_RANK_RANDOM_SKILL_ID]
  if nil ~= rankSkillId and 0 ~= rankSkillId then
    Toast(textRes.Fabao[87])
    local params = {}
    params.StarUpInfo = {}
    params.StarUpInfo.skillId1 = FabaoItemInfo.extraMap[ItemXStoreType.FABAO_NEXT_RANK_SKILL_ID] or FabaoItemInfo.extraMap[ItemXStoreType.FABAO_OWN_SKILL_ID]
    params.StarUpInfo.skillId2 = rankSkillId
    params.StarUpInfo.fabaoId1 = FabaoItemInfo.id
    if not FabaoItemInfo.extraMap[ItemXStoreType.FABAO_AUTO_RANKUP_TO] or not (0 < FabaoItemInfo.extraMap[ItemXStoreType.FABAO_AUTO_RANKUP_TO]) or not FabaoItemInfo.extraMap[ItemXStoreType.FABAO_AUTO_RANKUP_TO] then
    end
    params.StarUpInfo.fabaoId2 = FabaoUtils.GetNextRankFabaoId(FabaoItemInfo.id)
    params.StarUpInfo.fabaoLevel = FabaoItemInfo.extraMap[ItemXStoreType.FABAO_CUR_LV]
    params.StarUpInfo.fabaouuid = FabaoItemInfo.uuid[1]
    params.StarUpInfo.equiped = curFabao.equiped and 1 or 2
    local FabaoCommonPanel = require("Main.Fabao.ui.FabaoCommonPanel")
    FabaoCommonPanel.Instance():ShowPanel(FabaoCommonPanel.TypeDefine.FabaoStarUp, params)
    return
  end
  local fabaoBase = ItemUtils.GetFabaoItem(FabaoItemInfo.id)
  local needItemId, needItemNum = FabaoUtils.GetFabaoRankUpNeedItemInfo(fabaoBase.rankId)
  local haveItemNum = require("Main.Item.ItemModule").Instance():GetItemCountById(needItemId)
  local equiped = FabaoConst.EQUIPED
  if not self.m_CurFabao.equiped then
    equiped = FabaoConst.UNEQUIPED
  end
  local fabaouuid = FabaoItemInfo.uuid[1]
  if needItemNum > haveItemNum then
    if self.m_NeedYuanBaoReplace then
      local allYuanbao = require("Main.Item.ItemModule").Instance():GetAllYuanBao()
      if allYuanbao:lt(self.m_NeedYuanBaoNum) then
        Toast(textRes.Common[15])
        return
      end
      FabaoModule.RequestFabaoRankUp(equiped, fabaouuid, self.m_NeedYuanBaoNum)
    else
      self:ShowGetItemTips(clickObj, "UISprite", needItemId)
    end
  else
    FabaoModule.RequestFabaoRankUp(equiped, fabaouuid, 0)
  end
end
def.method().OnClickAddRankExp = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local fabaoItemInfo = FabaoModule.GetFabaoItemInfo(self.m_CurFabao.key, self.m_CurFabao.fabaoType)
  local fabaoBase = ItemUtils.GetFabaoItem(fabaoItemInfo.id)
  local function addRankExp(itemId, isAll)
    if nil == itemId then
      warn("add rankExp itemId error ~~~~")
      return false
    else
      local selectItemBase = ItemUtils.GetItemBase(itemId)
      if nil == selectItemBase then
        return false
      end
      if selectItemBase.itemType == ItemType.FABAO_ITEM then
        local selectFabaoBase = ItemUtils.GetFabaoItem(itemId)
        if nil == selectFabaoBase then
          return false
        end
        local selectFabaoRank = selectFabaoBase.rank
        local curFabaoRank = fabaoBase.rank
        if selectFabaoRank > curFabaoRank then
          Toast(textRes.Fabao[132])
          return false
        end
      end
      local ItemModule = require("Main.Item.ItemModule")
      local itemKey = -1
      local itemInfo
      local items = ItemModule.Instance():GetItemsByBagId(ItemModule.FABAOBAG)
      for k, v in pairs(items) do
        local id = v.id
        local uuid = v.uuid[1]
        local curFabaoUuid = fabaoItemInfo.uuid[1]
        if id == itemId and not curFabaoUuid:eq(uuid) then
          itemKey = k
          itemInfo = v
          break
        end
      end
      if -1 ~= itemKey and nil ~= itemInfo then
        local fabaouuid = fabaoItemInfo.uuid[1]
        local equiped = FabaoConst.EQUIPED
        if not self.m_CurFabao.equiped then
          equiped = FabaoConst.UNEQUIPED
        end
        local uuid = itemInfo.uuid[1]
        if fabaoItemInfo.uuid[1]:eq(uuid) then
          Toast(textRes.Fabao[96])
          return false
        end
        local useCount = 1
        if isAll then
          useCount = -1
        end
        FabaoModule.RequestAddRankExp(equiped, fabaouuid, itemKey, useCount)
        return true
      else
        Toast(textRes.Fabao[96])
        return false
      end
    end
  end
  local canUseIds = {}
  local fabaoIds = ItemUtils.GetItemTypeRefIdList(ItemType.FABAO_ITEM)
  if fabaoIds then
    for k, v in pairs(fabaoIds) do
      local fabaoItemBase = ItemUtils.GetFabaoItem(v)
      if fabaoItemBase.fabaoType == fabaoBase.fabaoType then
        if fabaoItemBase.rank > 1 then
          local itemCount = require("Main.Item.ItemModule").Instance():GetItemCountById(v)
          if itemCount > 0 then
            table.insert(canUseIds, v)
          end
        else
          table.insert(canUseIds, v)
        end
      end
    end
  end
  local fragmentIds = ItemUtils.GetItemTypeRefIdList(ItemType.FABAO_FRAG_ITEM)
  if fragmentIds then
    for k, v in pairs(fragmentIds) do
      local fragmentItemBase = ItemUtils.GetFabaoFragmentItem(v)
      if fragmentItemBase.fabaoType == fabaoBase.fabaoType then
        table.insert(canUseIds, v)
      end
    end
  end
  local CommonItemUsePanel = require("Main.Wing.ui.CommonItemUse")
  CommonItemUsePanel.ShowCommonUseByItemIdWithBagId(textRes.Fabao[91], canUseIds, addRankExp, require("Main.Item.ItemModule").FABAOBAG)
end
def.method("userdata").OnClickYuanBaoReplace = function(self, clickObj)
  local uiToggle = clickObj:GetComponent("UIToggle")
  local curValue = uiToggle.value
  local fabaoItemInfo = FabaoModule.GetFabaoItemInfo(self.m_CurFabao.key, self.m_CurFabao.fabaoType)
  local fabaoBase = ItemUtils.GetFabaoItem(fabaoItemInfo.id)
  if curValue then
    local needItemId = 0
    local needItemNum = 0
    needItemId, needItemNum = FabaoUtils.GetFabaoRankUpNeedItemInfo(fabaoBase.rankId)
    local haveItemNum = require("Main.Item.ItemModule").Instance():GetItemCountById(needItemId)
    if needItemNum <= haveItemNum then
      uiToggle.value = false
      local needItemBase = require("Main.Item.ItemUtils").GetItemBase(needItemId)
      local needItemName = needItemBase.name
      Toast(string.format(textRes.Fabao[86], needItemName))
      self.m_IsWaitingYuanBaoPrice = false
      self.m_NeedYuanBaoReplace = false
      self.m_YuanBaoPriceMap = nil
      self.m_NeedYuanBaoNum = 0
      self:UpdateBtnState()
      return
    else
      self.m_IsWaitingYuanBaoPrice = true
      self.m_NeedYuanBaoNum = 0
      self.m_NeedYuanBaoReplace = false
      self.m_YuanBaoPriceMap = nil
      local p = require("netio.protocol.mzm.gsp.item.CReqItemYuanbaoPriceWithId").new(self.m_CurFabao.id, {needItemId})
      gmodule.network.sendProtocol(p)
    end
  else
    self.m_IsWaitingYuanBaoPrice = false
    self.m_NeedYuanBaoReplace = false
    self.m_YuanBaoPriceMap = nil
    self.m_NeedYuanBaoNum = 0
    self:UpdateBtnState()
  end
end
def.method("number", "table").OnYuanBaoPriceRes = function(self, uid, itemid2yuanbao)
  if self.m_nodeRoot and not self.m_nodeRoot.isnil then
    if self.m_IsWaitingYuanBaoPrice then
      self.m_IsWaitingYuanBaoPrice = false
      local curFabaoId = self.m_CurFabao.id
      warn("OnYuanBaoPriceRes ", curFabaoId, uid)
      if curFabaoId == uid then
        local fabaoItemInfo = FabaoModule.GetFabaoItemInfo(self.m_CurFabao.key, self.m_CurFabao.fabaoType)
        local fabaoBase = ItemUtils.GetFabaoItem(fabaoItemInfo.id)
        local needItemId, needItemNum = FabaoUtils.GetFabaoRankUpNeedItemInfo(fabaoBase.rankId)
        local haveItemNum = require("Main.Item.ItemModule").Instance():GetItemCountById(needItemId)
        local price = itemid2yuanbao[needItemId]
        if price then
          if nil == self.m_YuanBaoPriceMap then
            self.m_YuanBaoPriceMap = {}
          end
          self.m_YuanBaoPriceMap[needItemId] = price
          if needItemNum > haveItemNum then
            self.m_NeedYuanBaoReplace = true
            self.m_NeedYuanBaoNum = price * (needItemNum - haveItemNum)
            self:UpdateBtnState()
            return
          end
        end
      end
      self.m_NeedYuanBaoReplace = false
      self.m_YuanBaoPriceMap = nil
      self.m_NeedYuanBaoNum = 0
      self:UpdateBtnState()
    else
      self.m_NeedYuanBaoReplace = false
      self.m_YuanBaoPriceMap = nil
      self.m_NeedYuanBaoNum = 0
      self:UpdateBtnState()
    end
  end
end
FabaoSXSubNode.Commit()
return FabaoSXSubNode

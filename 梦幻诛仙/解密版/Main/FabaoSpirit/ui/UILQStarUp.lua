local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UILQStarUp = Lplus.Extend(ECPanelBase, "UILQStarUp")
local instance
local def = UILQStarUp.define
local GUIUtils = require("GUI.GUIUtils")
local FabaoSpiritUtils = require("Main.FabaoSpirit.FabaoSpiritUtils")
local FabaoSpiritProtocols = require("Main.FabaoSpirit.FabaoSpiritProtocols")
local FabaoSpiritModule = require("Main.FabaoSpirit.FabaoSpiritModule")
local FabaoSpiritInterface = require("Main.FabaoSpirit.FabaoSpiritInterface")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
def.field("table")._uiModelCur = nil
def.field("table")._uiModeNext = nil
def.field("table")._uiGOs = nil
def.field("table")._uiStatus = nil
def.field("table")._curLQInfo = nil
def.field("table")._curEffects = nil
def.field("table")._nxtEffects = nil
local const = constant.CFabaoArtifactConsts
def.static("=>", UILQStarUp).Instance = function()
  if instance == nil then
    instance = UILQStarUp()
  end
  return instance
end
def.override().OnCreate = function(self)
  self._uiStatus = {}
  self:InitUI()
end
def.method().InitUI = function(self)
  Event.RegisterEvent(ModuleId.FABAO_SPIRIT, gmodule.notifyId.FabaoSpirit.LQInfoChange, UILQStarUp.OnLQInfoChange)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, UILQStarUp.OnItemChange, self)
  self._uiGOs = self._uiGOs or {}
  self._uiGOs.groupCur = self.m_panel:FindDirect("Img_0/Group_Current")
  self._uiGOs.groupNext = self.m_panel:FindDirect("Img_0/Group_Next")
  self._uiGOs.groupBottom = self.m_panel:FindDirect("Img_0/Group_Bottom")
  self._curEffects = {}
  self._nxtEffects = {}
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.FABAO_SPIRIT, gmodule.notifyId.FabaoSpirit.LQInfoChange, UILQStarUp.OnLQInfoChange)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, UILQStarUp.OnItemChange)
  local comUIModel = self._uiGOs.groupCur:FindDirect("Model_Current"):GetComponent("UIModel")
  FabaoSpiritInterface._rmvModelEffects(self._curEffects)
  FabaoSpiritInterface._rmvModelEffects(self._nxtEffects)
  if self._uiModelCur ~= nil then
    comUIModel.modelGameObject = nil
    self._uiModelCur:Destroy()
    self._uiModelCur = nil
  end
  if self._uiModeNext ~= nil then
    comUIModel = self._uiGOs.groupNext:FindDirect("Model_Next"):GetComponent("UIModel")
    comUIModel.modelGameObject = nil
    self._uiModeNext:Destroy()
    self._uiModeNext = nil
  end
  self._uiStatus = nil
  self._uiGOs = nil
  self._curEffects = nil
  self._nxtEffects = nil
end
def.override("boolean").OnShow = function(self, bShow)
  if bShow then
    self:UpdateUI()
  end
end
def.method("table").ShowPanel = function(self, curLQInfo)
  self._curLQInfo = curLQInfo
  if self:IsLoaded() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_LQ_STARUP, 1)
  self:SetModal(true)
end
def.method().HidePanel = function(self)
  self:DestroyPanel()
end
def.method().UpdateUI = function(self)
  local LQClsCfg = FabaoSpiritUtils.GetLQClsCfgByClsId(self._curLQInfo.class_id)
  if #LQClsCfg.arrCfgId <= self._curLQInfo.level then
    Toast(textRes.FabaoSpirit[15])
    self:HidePanel()
    return
  end
  local nxtBasicCfg = FabaoSpiritUtils.GetFabaoLQCfg(LQClsCfg.arrCfgId[self._curLQInfo.level + 1])
  self:UpdateUICurrent(LQClsCfg)
  self:UpdateUINext(LQClsCfg)
end
def.method("table").UpdateUICurrent = function(self, LQClsCfg)
  local cfgId = LQClsCfg.arrCfgId[self._curLQInfo.level]
  local curBasicCfg = FabaoSpiritUtils.GetFabaoLQCfg(cfgId)
  local propCfg = FabaoSpiritUtils.GetFabaoLQPropCfgById(cfgId)
  local arrCurProps = self:GetCurInitPropVals(propCfg)
  local ctrlRoot = self._uiGOs.groupCur
  local lblName = ctrlRoot:FindDirect("Label_Name")
  local uiModelCur = ctrlRoot:FindDirect("Model_Current")
  local lblSkill = ctrlRoot:FindDirect("Group_Info/Label_Skill")
  local lblHtmlSkill = lblSkill:FindDirect("Html_CurText")
  GUIUtils.SetText(lblName, curBasicCfg.name)
  local skillCfg = FabaoSpiritUtils.GetSkillCfgById(curBasicCfg.skillId)
  lblHtmlSkill:GetComponent("NGUIHTML"):ForceHtmlText(textRes.FabaoSpirit[16]:format(skillCfg and skillCfg.name or ""))
  GUIUtils.SetText(lblSkill, textRes.FabaoSpirit[3])
  lblSkill:SetActive(skillCfg ~= nil)
  self._uiStatus.selCurSkillId = curBasicCfg.skillId
  local ctrlScrollView = ctrlRoot:FindDirect("Group_Info/Group_Attribute/Scroll View")
  local ctrlUIList = ctrlScrollView:FindDirect("List_Attribute")
  local ctrlAttrList = GUIUtils.InitUIList(ctrlUIList, #arrCurProps)
  for i = 1, #ctrlAttrList do
    local ctrlattr = ctrlAttrList[i]
    local attr = arrCurProps[i]
    self:FillAttrInfo(ctrlattr, attr, i)
  end
  self:UpdateUIModel(uiModelCur, curBasicCfg.modelId, 1, curBasicCfg.boneEffectId)
  self:UpdateUIBottom(LQClsCfg, self._curLQInfo)
end
def.method("table").UpdateUINext = function(self, LQClsCfg)
  local cfgId = LQClsCfg.arrCfgId[self._curLQInfo.level + 1]
  local nxtBasicCfg = FabaoSpiritUtils.GetFabaoLQCfg(cfgId)
  local propCfg = FabaoSpiritUtils.GetFabaoLQPropCfgById(cfgId)
  local arrNxtProps = self:GetCurInitPropVals(propCfg)
  local ctrlRoot = self._uiGOs.groupNext
  local lblName = ctrlRoot:FindDirect("Label_Name")
  local uiModelNxt = ctrlRoot:FindDirect("Model_Next")
  GUIUtils.SetText(lblName, nxtBasicCfg.name)
  local ctrlScrollView = ctrlRoot:FindDirect("Group_Info/Group_Attribute/Scroll View")
  local ctrlUIList = ctrlScrollView:FindDirect("List_Attribute")
  local ctrlAttrList = GUIUtils.InitUIList(ctrlUIList, #propCfg.arrPropValues)
  for i = 1, #ctrlAttrList do
    local ctrlattr = ctrlAttrList[i]
    local attr = arrNxtProps[i]
    self:FillAttrInfo(ctrlattr, attr, i)
  end
  local lblSkill = ctrlRoot:FindDirect("Group_Info/Label_Skill")
  local lblHtmlSkill = lblSkill:FindDirect("Html_NextText")
  local skillCfg = FabaoSpiritUtils.GetSkillCfgById(nxtBasicCfg.skillId)
  GUIUtils.SetText(lblSkill, textRes.FabaoSpirit[3])
  lblSkill:SetActive(skillCfg ~= nil)
  self._uiStatus.selNxtSkillId = nxtBasicCfg.skillId
  lblHtmlSkill:GetComponent("NGUIHTML"):ForceHtmlText(textRes.FabaoSpirit[16]:format(skillCfg and skillCfg.name or ""))
  self:UpdateUIModel(uiModelNxt, nxtBasicCfg.modelId, 2, nxtBasicCfg.boneEffectId)
end
def.method("userdata", "table", "number").FillAttrInfo = function(self, ctrl, attrInfo, idx)
  local lblName = ctrl:FindDirect("Label_AttributeName_" .. idx)
  local lblVal = ctrl:FindDirect("Label_AttributeNumber_" .. idx)
  local imgCanUpgrade = ctrl:FindDirect("Img_ArrowGreen_" .. idx)
  if attrInfo.propType <= 0 or 0 >= attrInfo.dstVal then
    lblName:SetActive(false)
    lblVal:SetActive(false)
    imgCanUpgrade:SetActive(false)
    return
  end
  GUIUtils.SetText(lblName, FabaoSpiritUtils.GetFabaoSpiritProName(attrInfo.propType))
  GUIUtils.SetText(lblVal, textRes.FabaoSpirit[4]:format(attrInfo.initVal, attrInfo.dstVal or 0))
end
def.method("table", "=>", "table").GetCurInitPropVals = function(self, propCfg)
  local arrCurProps = {}
  for i = 1, #propCfg.arrPropValues do
    local propCfg = propCfg.arrPropValues[i]
    local prop = {}
    prop.propType = propCfg.propType
    prop.initVal = self._curLQInfo.properties[propCfg.propType]
    if prop.initVal == nil then
      prop.initVal = propCfg.initVal
    end
    prop.dstVal = propCfg.dstVal
    table.insert(arrCurProps, prop)
  end
  return arrCurProps
end
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local ItemModule = require("Main.Item.ItemModule")
def.method("table", "table").UpdateUIBottom = function(self, clsCfg, ownLQInfo)
  local ctrlRoot = self._uiGOs.groupBottom
  local lblName = ctrlRoot:FindDirect("Img_BgItem/Label_Name")
  local iconItem = ctrlRoot:FindDirect("Img_BgItem/Icon_Item")
  local lblNum = ctrlRoot:FindDirect("Img_BgItem/Label_Num")
  local items = ItemModule.Instance():GetItemsByItemType(ItemModule.BAG, ItemType.FABAO_ARTIFACT_ITEM)
  local expCfgInfos = self:CaculateUpgradeVal(ownLQInfo.class_id, items)
  local itemNum = expCfgInfos.count
  expCfgInfos.arrExp = clsCfg.arrExp
  self._uiStatus.expCfgInfos = expCfgInfos
  self._uiStatus.selItemId = items[1] and items[1].id or 0
  GUIUtils.SetText(lblNum, itemNum)
  local clsCfg = FabaoSpiritUtils.GetLQClsCfgByClsId(ownLQInfo.class_id)
  local cfgId = self:GetLQCfgIdByClsCfg(ownLQInfo, clsCfg)
  local basicCfg = FabaoSpiritUtils.GetFabaoLQCfg(cfgId)
  GUIUtils.SetText(lblName, basicCfg.name)
  GUIUtils.SetTexture(iconItem, basicCfg.icon)
  local lblExp = ctrlRoot:FindDirect("Group_Slide/Label_ExpNum")
  local comSlider = ctrlRoot:FindDirect("Group_Slide/Img_Bg"):GetComponent("UISlider")
  local curExp = ownLQInfo.upgrade_exp - clsCfg.arrExp[ownLQInfo.level]
  warn("ownLQInfo.upgrade_exp", ownLQInfo.upgrade_exp, "clsCfg.arrExp[ownLQInfo.level]", clsCfg.arrExp[ownLQInfo.level], " curExp", curExp, "clsId", ownLQInfo.class_id)
  local totalNeedExp = clsCfg.arrExp[ownLQInfo.level + 1] - clsCfg.arrExp[ownLQInfo.level]
  GUIUtils.SetText(lblExp, textRes.FabaoSpirit[4]:format(curExp, totalNeedExp))
  comSlider.value = curExp / totalNeedExp
end
def.method("table", "table", "=>", "number").GetLQCfgIdByClsCfg = function(self, ownLQInfo, LQClsCfg)
  if LQClsCfg == nil then
    return 0
  end
  local lv = 1
  if #LQClsCfg.arrCfgId ~= 1 then
    lv = ownLQInfo.level
  end
  return LQClsCfg.arrCfgId[lv]
end
def.method("number", "table", "=>", "table").CaculateUpgradeVal = function(self, curClsId, items)
  if items == nil then
    return nil
  end
  local retData = {}
  local count, totalExp = 0, 0
  local maxLv = 0
  local setItemId = {}
  retData.itemList = {}
  for _, item in pairs(items) do
    local LQCfg = FabaoSpiritInterface.GetClsCfgByItemId(item.id)
    if LQCfg ~= nil then
      local LQBasicCfg = LQCfg.LQBasicCfg
      local LQClsCfg = LQCfg.clsCfg
      if LQClsCfg.classId == curClsId and 0 < #LQClsCfg.arrExp then
        local data = {}
        data.level = LQBasicCfg.level
        data.itemId = item.id
        data.cfgId = LQBasicCfg.id
        data.expVal = LQBasicCfg.provideExp
        if maxLv < data.level then
          maxLv = data.level
        end
        totalExp = totalExp + data.expVal
        table.insert(retData.itemList, data)
        setItemId[item.id] = 1
      end
      table.sort(retData.itemList, function(a, b)
        return a.level < b.level
      end)
    end
  end
  retData.items = {}
  for itemId, _ in pairs(setItemId) do
    local items = ItemModule.Instance():GetItemsByItemID(ItemModule.BAG, itemId)
    for itemKey, item in pairs(items) do
      local sItem = {}
      sItem.id = item.id
      sItem.number = item.number
      count = count + sItem.number
      if retData.items[sItem.id] ~= nil then
        retData.items[sItem.id].number = retData.items[sItem.id].number + sItem.number
      else
        retData.items[sItem.id] = sItem
      end
    end
  end
  retData.count = count
  retData.totalExp = totalExp
  retData.maxLv = maxLv
  return retData
end
local ECUIModel = require("Model.ECUIModel")
def.method("userdata", "number", "number", "number").UpdateUIModel = function(self, ctrlUIModel, model_id, uimodelIdx, effectId)
  local comUIModel = ctrlUIModel:GetComponent("UIModel")
  local modelPath, modelColor = _G.GetModelPath(model_id)
  if modelPath == nil or modelPath == "" then
    return
  end
  local objUImodel = self._uiModelCur
  if uimodelIdx == 2 then
    objUImodel = self._uiModeNext
    FabaoSpiritInterface._rmvModelEffects(self._nxtEffects)
  else
    FabaoSpiritInterface._rmvModelEffects(self._curEffects)
  end
  if objUImodel then
    objUImodel:Destroy()
  end
  local function fun_afterload()
    comUIModel.modelGameObject = objUImodel.m_model
    if uimodelIdx == 1 then
      self._curEffects = {}
      FabaoSpiritInterface._addBoneEffect(effectId, objUImodel.m_model, self._curEffects)
    elseif uimodelIdx == 2 then
      self._nxtEffects = {}
      FabaoSpiritInterface._addBoneEffect(effectId, objUImodel.m_model, self._nxtEffects)
    end
    if comUIModel.mCanOverflow ~= nil then
      comUIModel.mCanOverflow = true
      local cam = comUIModel:get_modelCamera()
      cam:set_orthographic(true)
    end
  end
  objUImodel = ECUIModel.new(model_id)
  objUImodel.m_bUncache = true
  if uimodelIdx == 1 then
    self._uiModelCur = objUImodel
  elseif uimodelIdx == 2 then
    self._uiModeNext = objUImodel
  end
  objUImodel:LoadUIModel(modelPath, function(ret)
    if not objUImodel or not objUImodel.m_model or objUImodel.m_model.isnil then
      return
    end
    fun_afterload()
  end)
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn(">>>starup ", id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Tip" then
    GUIUtils.ShowHoverTip(const.HOVER_TIP_ID2, 0, 0)
  elseif id == "Btn_GZ" then
    self:OnClickBtnInject()
  elseif id == "Html_CurText" then
    require("Main.Skill.SkillTipMgr").Instance():ShowTipByIdEx(self._uiStatus.selCurSkillId or 0, clickObj, 0)
  elseif id == "Html_NextText" then
    require("Main.Skill.SkillTipMgr").Instance():ShowTipByIdEx(self._uiStatus.selNxtSkillId or 0, clickObj, 0)
  elseif id == "Img_BgItem" then
    local position = clickObj:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local sprite = clickObj:GetComponent("UISprite")
    local disCfg = FabaoSpiritUtils.GetFabaoLQDisplayCfgById(self._curLQInfo.class_id)
    if disCfg ~= nil then
      ItemTipsMgr.Instance():ShowBasicTips(disCfg.displayItemId or 0, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, true)
    end
  end
end
def.method().OnClickBtnInject = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  if self._uiStatus.expCfgInfos == nil or self._uiStatus.expCfgInfos.count == nil or self._uiStatus.expCfgInfos.count == 0 then
    Toast(textRes.FabaoSpirit[17])
    return
  end
  local arrExp = self._uiStatus.expCfgInfos.arrExp
  if #arrExp <= self._curLQInfo.level then
    Toast(textRes.FabaoSpirit[29])
    return
  end
  local content = ""
  local expItems = self._uiStatus.expCfgInfos.itemList
  local items = self._uiStatus.expCfgInfos.items
  local curLv = self._curLQInfo.level
  local needExp = arrExp[curLv + 1] - self._curLQInfo.upgrade_exp
  local curExp = 0
  local curNeepExp = needExp
  local preItemId = 0
  for i = 1, #expItems do
    local expItem = expItems[i]
    if expItem.itemId ~= preItemId then
      preItemId = expItem.itemId
      local itemNum = items[expItem.itemId].number or 0
      local roundNeedNum = math.floor(curNeepExp / expItem.expVal)
      if curNeepExp % expItem.expVal ~= 0 then
        roundNeedNum = roundNeedNum + 1
      end
      itemNum = math.min(itemNum, roundNeedNum)
      curNeepExp = needExp - itemNum * expItem.expVal
      curExp = curExp + expItem.expVal * itemNum
      if needExp <= curExp then
        break
      end
    end
  end
  local iCanReachLv = 0
  for i = curLv, #arrExp do
    if curExp + self._curLQInfo.upgrade_exp >= arrExp[i] then
      iCanReachLv = i
    else
      break
    end
  end
  if iCanReachLv > self._curLQInfo.level then
    content = textRes.FabaoSpirit[26]:format(iCanReachLv)
  else
    content = textRes.FabaoSpirit[27]:format(curExp)
  end
  if iCanReachLv > self._curLQInfo.level then
    CommonConfirmDlg.ShowConfirm(textRes.FabaoSpirit[22], content, function(select)
      if select == 1 then
        FabaoSpiritProtocols.SendUpgradeLQReq(self._curLQInfo.class_id)
      end
    end, nil)
  else
    CommonConfirmDlg.ShowConfirm(textRes.FabaoSpirit[22], content, function(select)
      if select == 1 then
        FabaoSpiritProtocols.SendUpgradeLQReq(self._curLQInfo.class_id)
      end
    end, nil)
  end
end
def.static("table", "table").OnLQInfoChange = function(p, c)
  local self = UILQStarUp.Instance()
  local clsId = self._curLQInfo.class_id
  self._curLQInfo = FabaoSpiritModule.GetOwnedLQInfos()[clsId]
  self._curLQInfo.class_id = clsId
  self:UpdateUI()
end
def.method("table").OnItemChange = function(self, p)
  local LQClsCfg = FabaoSpiritUtils.GetLQClsCfgByClsId(self._curLQInfo.class_id)
  self:UpdateUIBottom(LQClsCfg, self._curLQInfo)
end
return UILQStarUp.Commit()

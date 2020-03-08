local Lplus = require("Lplus")
local FabaoTabNode = require("Main.Fabao.ui.FabaoTabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local FabaoSpiritNode = Lplus.Extend(FabaoTabNode, "FabaoSpiritNode")
local instance
local def = FabaoSpiritNode.define
local FabaoSpiritModule = require("Main.FabaoSpirit.FabaoSpiritModule")
local FabaoSpiritProtocols = require("Main.FabaoSpirit.FabaoSpiritProtocols")
local FabaoSpiritInterface = require("Main.FabaoSpirit.FabaoSpiritInterface")
local GUIUtils = require("GUI.GUIUtils")
local FabaoSpiritUtils = require("Main.FabaoSpirit.FabaoSpiritUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
def.field("table")._uiGOs = nil
def.field("table")._status = nil
def.field("table")._tblPropSel = nil
def.field("table")._arrOwnedLQ = nil
def.field("table")._uiModel = nil
def.field("table")._effects = nil
def.field("number")._selLQClsId = 0
def.field("number")._selectType = 0
def.field("number")._YBPrice = 0
def.field("boolean")._bIsWaittingYuanBaoPrice = false
local ENUM_FIRST_SELECTTYPE = {NO_EXPIRED = 1, TIME_LIMIT = 2}
local const = constant.CFabaoArtifactConsts
def.static("=>", FabaoSpiritNode).Instance = function()
  if instance == nil then
    instance = FabaoSpiritNode()
  end
  return instance
end
def.static("number").SetSelectClsId = function(clsId)
  local self = FabaoSpiritNode.Instance()
  self._selLQClsId = clsId
end
def.static("number").SetFirstSelectType = function(selType)
  local self = FabaoSpiritNode.Instance()
  self._selectType = selType
end
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  FabaoTabNode.Init(self, base, node)
end
def.override().OnShow = function(self)
  instance = self
  Event.RegisterEvent(ModuleId.FABAO_SPIRIT, gmodule.notifyId.FabaoSpirit.EquipedLQChange, FabaoSpiritNode.OnEquipedLQChange)
  Event.RegisterEvent(ModuleId.FABAO_SPIRIT, gmodule.notifyId.FabaoSpirit.OwndLQChange, FabaoSpiritNode.OnOwndLQChange)
  Event.RegisterEvent(ModuleId.FABAO_SPIRIT, gmodule.notifyId.FabaoSpirit.LQInfoChange, FabaoSpiritNode.OnLQInfoChange)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, FabaoSpiritNode.OnItemChange, self)
  Event.RegisterEventWithContext(ModuleId.FABAO_SPIRIT, gmodule.notifyId.FabaoSpirit.LQPropInfoChange, FabaoSpiritNode.OnLQPropInfoChange, self)
  self:InitUI()
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.FABAO_SPIRIT, gmodule.notifyId.FabaoSpirit.EquipedLQChange, FabaoSpiritNode.OnEquipedLQChange)
  Event.UnregisterEvent(ModuleId.FABAO_SPIRIT, gmodule.notifyId.FabaoSpirit.OwndLQChange, FabaoSpiritNode.OnOwndLQChange)
  Event.UnregisterEvent(ModuleId.FABAO_SPIRIT, gmodule.notifyId.FabaoSpirit.LQInfoChange, FabaoSpiritNode.OnLQInfoChange)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, FabaoSpiritNode.OnItemChange)
  Event.UnregisterEvent(ModuleId.FABAO_SPIRIT, gmodule.notifyId.FabaoSpirit.LQPropInfoChange, FabaoSpiritNode.OnLQPropInfoChange)
  self._uiGOs = nil
  FabaoSpiritInterface._rmvModelEffects(self._effects)
  if self._uiModel ~= nil then
    self._uiModel:Destroy()
    self._uiModel = nil
  end
  if self._status ~= nil and self._status.CDTimer ~= nil and self._status.CDTimer ~= 0 then
    _G.GameUtil.RemoveGlobalTimer(self._status.CDTimer)
    self._status.CDTimer = 0
  end
  self._status = nil
  self._tblPropSel = nil
  self._selectType = 0
  self._effects = nil
  self._YBPrice = 0
  self._bIsWaittingYuanBaoPrice = false
end
def.override("=>", "boolean").HasSubNode = function(self)
  return false
end
def.method().InitUI = function(self)
  self._uiGOs = self._uiGOs or {}
  self._effects = {}
  self._tblPropSel = {}
  self._uiGOs.getItemGroup = self.m_node:FindDirect("Group_None")
  self._uiGOs.groupLeft = self.m_node:FindDirect("Group_Left")
  self._uiGOs.groupRight = self.m_node:FindDirect("Group_Right")
  self:UpdateOwnedLQList()
  self:UpdateUI()
end
def.method().UpdateUI = function(self)
  local bShowEmpty = #self._arrOwnedLQ == 0
  self:SwithToEmptyUI(bShowEmpty)
  if not bShowEmpty then
    self:UpdateLeftList()
    if self._status.selectIdx ~= nil or self._status.selectIdx ~= 0 then
      self:OnSelectLQ(self._status.selectIdx)
    else
      self:OnSelectLQ(1)
    end
  else
    FabaoSpiritModule.SetRetPtActive(false)
  end
end
def.method("boolean").SwithToEmptyUI = function(self, bShow)
  self._uiGOs.getItemGroup:SetActive(bShow)
  self._uiGOs.groupLeft:SetActive(not bShow)
  self._uiGOs.groupRight:SetActive(not bShow)
end
def.method().UpdateLeftList = function(self)
  local ownedLQNum = FabaoSpiritModule.CountOwnedLQ()
  if ownedLQNum == 0 then
    self:SwithToEmptyUI(true)
    return
  end
  local ctrlScrollView = self._uiGOs.groupLeft:FindDirect("Group_List/Scroll View_List")
  local ctrlUIList = ctrlScrollView:FindDirect("Grid_List")
  local ctrlLQList = GUIUtils.InitUIList(ctrlUIList, ownedLQNum)
  local ownedLQList = self._arrOwnedLQ
  self._status = self._status or {}
  self._status.selectAttrIdx = 1
  self:UpdateImproveInfo(self._status.selectAttrIdx, true)
  self._status.selectIdx = self._status.selectIdx or 1
  local equipedClsId = FabaoSpiritModule.GetEquipedLQClsId()
  for i = 1, #ctrlLQList do
    local ctrlLQItm = ctrlLQList[i]
    local owndLQ = ownedLQList[i]
    local LQInfo = {}
    LQInfo.bEquiped = owndLQ.class_id == equipedClsId
    local LQClsCfg = FabaoSpiritUtils.GetLQClsCfgByClsId(owndLQ.class_id)
    self._tblPropSel[owndLQ.class_id] = self._tblPropSel[owndLQ.class_id] or 1
    local lv = 1
    if #LQClsCfg.arrCfgId ~= 1 then
      lv = owndLQ.level
    end
    local basicCfg = FabaoSpiritUtils.GetFabaoLQCfg(LQClsCfg.arrCfgId[lv])
    local LQItemId = LQClsCfg.arrCfgId[lv]
    LQInfo.name = basicCfg.name
    LQInfo.level = owndLQ.level
    LQInfo.icon = basicCfg.icon
    LQInfo.expire_time = owndLQ.expire_time
    LQInfo.tgNew = owndLQ.tgNew ~= nil and owndLQ.tgNew == true
    LQInfo.clsId = owndLQ.class_id
    LQInfo.LQItemId = LQItemId
    if self._selLQClsId ~= 0 and self._selLQClsId == owndLQ.class_id then
      self._status.selectIdx = i
    elseif self._selectType ~= 0 and self._selectType == ENUM_FIRST_SELECTTYPE.NO_EXPIRED and owndLQ.expire_time == 0 then
      self._status.selectIdx = i
    end
    if self._status.selectIdx == i then
      FabaoSpiritModule.SetTagNew(LQInfo.clsId, false)
      self._arrOwnedLQ[i].tgNew = false
      LQInfo.tgNew = false
    end
    self:FillLQItemInfo(ctrlLQItm, LQInfo, i)
  end
  local comScrollView = ctrlScrollView:GetComponent("UIScrollView")
  if #ctrlLQList > 0 then
    do
      local selectIdx = self._status.selectIdx
      local ctrl = ctrlLQList[selectIdx]
      ctrl:GetComponent("UIToggle").value = true
      GameUtil.AddGlobalTimer(0.1, true, function()
        if _G.IsNil(ctrlScrollView) then
          return
        end
        comScrollView:DragToMakeVisible(ctrl.transform, 1280)
      end)
    end
  end
end
def.method("userdata", "table", "number").FillLQItemInfo = function(self, ctrl, LQInfo, idx)
  local lblName = ctrl:FindDirect("Label_Name_" .. idx)
  local imgWear = ctrl:FindDirect("Img_Wear_" .. idx)
  local imgLimit = ctrl:FindDirect("Img_Limit_" .. idx)
  local itemIcon = ctrl:FindDirect("Group_Icon_" .. idx .. "/Icon_Equip01_" .. idx)
  local lblLv = ctrl:FindDirect("Label_Level_" .. idx)
  local imgRedPt = ctrl:FindDirect("Img_Red_" .. idx)
  local imgLvUp = ctrl:FindDirect("Img_CanUp_" .. idx)
  local bgFrame = ctrl:FindDirect("Group_Icon_" .. idx .. "/Icon_BgEquip01_" .. idx)
  GUIUtils.SetText(lblName, LQInfo.name)
  imgWear:SetActive(LQInfo.bEquiped)
  GUIUtils.SetText(lblLv, textRes.FabaoSpirit[1]:format(LQInfo.level))
  imgLimit:SetActive(LQInfo.expire_time ~= 0)
  GUIUtils.SetTexture(itemIcon, LQInfo.icon)
  imgRedPt:SetActive(LQInfo.tgNew)
  local bCanLvUp = FabaoSpiritModule.CanFabaoSpiritLevelUp(LQInfo.clsId)
  imgLvUp:SetActive(bCanLvUp)
  local itemId = FabaoSpiritUtils.GetItemIdByCfgId(LQInfo.LQItemId)
  GUIUtils.SetSprite(bgFrame, ItemUtils.GetItemFrame({id = itemId}, ItemUtils.GetItemBase(itemId)))
end
def.method().UpdateRightUI = function(self)
  local arrLQList = self._arrOwnedLQ
  if self._status.selectIdx > #arrLQList then
    self._status.selectIdx = 1
  end
  local selectIdx = self._status.selectIdx
  local group_top = self._uiGOs.groupRight:FindDirect("Group_Top")
  local lblName = group_top:FindDirect("Img_BgName/Label_Name")
  local imgRedPt = group_top:FindDirect("Btn_UpStar/Img_ArrowGreen")
  local imgUpArrow = group_top:FindDirect("Btn_UpStar/Img_Red")
  local LQClsCfg = FabaoSpiritUtils.GetLQClsCfgByClsId(arrLQList[selectIdx].class_id)
  self._status.selLQClsCfg = LQClsCfg
  local ownLQInfo = arrLQList[selectIdx]
  local btnStarUp = group_top:FindDirect("Btn_UpStar")
  local arrProps = {}
  for _, v in pairs(ownLQInfo.properties or {}) do
    table.insert(arrProps, v)
  end
  self._status.selCanLvUp = not (ownLQInfo.level >= #LQClsCfg.arrCfgId) and ownLQInfo.expire_time == 0 and not (#arrProps <= 0)
  self._status.selOwnLQInfo = ownLQInfo
  local cfgId = self:GetLQCfgIdByClsCfg(ownLQInfo, LQClsCfg)
  local basicCfg = FabaoSpiritUtils.GetFabaoLQCfg(cfgId)
  self._status.selLQBasicCfg = basicCfg
  GUIUtils.SetText(lblName, basicCfg.name)
  local bCanLvUp = FabaoSpiritModule.CanFabaoSpiritLevelUp(basicCfg.classId)
  imgRedPt:SetActive(bCanLvUp)
  imgUpArrow:SetActive(bCanLvUp)
  local comToggle = group_top:FindDirect("Toggle_Use"):GetComponent("UIToggle")
  comToggle.value = ownLQInfo.class_id == FabaoSpiritModule.GetEquipedLQClsId()
  local group_center = self._uiGOs.groupRight:FindDirect("Group_Center")
  local lblSkill = group_center:FindDirect("Group_Skill/Label_Name")
  local skillCfg = FabaoSpiritUtils.GetSkillCfgById(basicCfg.skillId)
  group_center:FindDirect("Group_Skill"):SetActive(skillCfg ~= nil)
  if skillCfg ~= nil then
    local strHtml = string.format("<a href='LQSkill' id=Label_Name><u><font size=20 color=#16811B>%s</font></u></a>", skillCfg.name)
    lblSkill:GetComponent("NGUIHTML"):ForceHtmlText(strHtml)
  end
  local group_attr = self._uiGOs.groupRight:FindDirect("Group_Attribute")
  local ctrlScrollView = group_attr:FindDirect("Scroll View")
  local ctrlUIList = ctrlScrollView:FindDirect("List_Attribute")
  local propCfg = FabaoSpiritUtils.GetFabaoLQPropCfgById(cfgId)
  local improveCfg
  if propCfg.improveCfgId ~= 0 then
    improveCfg = FabaoSpiritUtils.GetFabaoLQImproveCfgById(propCfg.improveCfgId)
  end
  self._status.selPropCfg = propCfg
  group_attr:SetActive(propCfg ~= nil)
  local lblNoProp = group_attr:FindDirect("Label_Tips")
  local propNum = #(propCfg and propCfg.arrPropValues or {})
  if #arrProps <= 0 then
    ctrlScrollView:SetActive(false)
    lblNoProp:SetActive(true)
    GUIUtils.SetText(lblNoProp, textRes.FabaoSpirit[30])
  else
    lblNoProp:SetActive(false)
    ctrlScrollView:SetActive(true)
    local ctrlAttrList = GUIUtils.InitUIList(ctrlUIList, propNum)
    for i = 1, #(propCfg.arrPropValues or {}) do
      local propType = propCfg.arrPropValues[i].propType
      local attrInfo = {}
      attrInfo.curVal = ownLQInfo.properties[propType]
      attrInfo.cfgVal = propCfg.arrPropValues[i]
      if attrInfo.curVal == nil then
        ctrlAttrList[i]:SetActive(false)
      else
        self:FillUIAttr(ctrlAttrList[i], attrInfo, i, improveCfg ~= nil)
      end
    end
  end
  local groupTime = self._uiGOs.groupRight:FindDirect("Group_Time")
  groupTime:SetActive(improveCfg == nil)
  local lblTime = groupTime:FindDirect("Label_Time")
  self:CountDownExpireTime(ownLQInfo.expire_time, lblTime)
  self:SetUIModel(basicCfg.modelId, basicCfg.boneEffectId)
  self:UpdateUIBottom()
end
def.method("userdata", "table", "number", "boolean").FillUIAttr = function(self, ctrl, attrInfo, idx, bShowToggle)
  local ctrlSlider = ctrl:FindDirect("Slider_Attribute1_" .. idx)
  local lblAttrState = ctrlSlider:FindDirect("Label_AttributeSlider1_" .. idx)
  local lblAttrName = ctrlSlider:FindDirect("Img_Attribute1_" .. idx .. "/Label_Attribute1_" .. idx)
  local lblIncrease = ctrlSlider:FindDirect("Img_BgIncrease1_" .. idx .. "/Label_Increase1_" .. idx)
  local comToggle = ctrl:GetComponent("UIToggle")
  comToggle.enabled = bShowToggle
  local ctrlToggle = ctrl:FindDirect("Img_SelectAttribute1_" .. idx)
  local ctrlToggleBg = ctrl:FindDirect("Sprite_" .. idx)
  ctrlToggle:SetActive(bShowToggle)
  ctrlToggleBg:SetActive(bShowToggle)
  comToggle.value = idx == self._status.selectAttrIdx
  local comProgres = ctrl:FindDirect("Slider_Attribute1_" .. idx):GetComponent("UIProgressBar")
  GUIUtils.SetText(lblAttrState, ("%d/%d"):format(attrInfo.curVal, attrInfo.cfgVal.dstVal))
  GUIUtils.SetText(lblAttrName, FabaoSpiritUtils.GetFabaoSpiritProName(attrInfo.cfgVal.propType))
  lblIncrease:SetActive(false)
  comProgres.value = attrInfo.curVal / attrInfo.cfgVal.dstVal
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
def.method().UpdateOwnedLQList = function(self)
  self._arrOwnedLQ = FabaoSpiritModule.GetOwnedLQInfosList()
end
def.method().UpdateUIBottom = function(self)
  local group_bottom = self._uiGOs.groupRight:FindDirect("Group_Bottom")
  local propCfg = self:GetCurPropCfg()
  local selectPropIdx = self._status.selectAttrIdx
  if propCfg == nil or selectPropIdx == 0 then
    group_bottom:SetActive(false)
    return
  else
    group_bottom:SetActive(true)
  end
  local texIcon = group_bottom:FindDirect("Img_BgItem/Icon_Item")
  local lblNum = group_bottom:FindDirect("Img_BgItem/Label_Num")
  local lblName = group_bottom:FindDirect("Img_BgItem/Label_Name")
  local improveCfg
  if propCfg.improveCfgId ~= 0 then
    improveCfg = FabaoSpiritUtils.GetFabaoLQImproveCfgById(propCfg.improveCfgId)
  end
  group_bottom:SetActive(improveCfg ~= nil)
  if improveCfg == nil then
    return
  end
  for i = 1, #improveCfg.arrPropValues do
    if improveCfg.arrPropValues[i].propType == propCfg.arrPropValues[selectPropIdx].propType then
      selectPropIdx = i
      break
    end
  end
  improveCfg = improveCfg.arrPropValues[selectPropIdx]
  self._status.selImproveCfg = improveCfg
  if improveCfg ~= nil then
    local itemFilterId = improveCfg.itemFilterId
    self._status.selFilterItemId = itemFilterId
    local itemFilterCfg = ItemUtils.GetItemFilterCfg(itemFilterId)
    local itemBaseCfg = itemFilterCfg
    local itemId = itemFilterCfg.id
    local ownedNum = FabaoSpiritInterface.GetItemsNumByFilterId(itemFilterId)
    GUIUtils.SetText(lblNum, ("%d/%d"):format(improveCfg.itemNum, ownedNum))
    local comLblNum = lblNum:GetComponent("UILabel")
    if ownedNum < improveCfg.itemNum then
      comLblNum:set_textColor(_G.Color.red)
    else
      comLblNum:set_textColor(_G.Color.Color(0, 1, 0, 1))
    end
    self._status.ownedItemNum = ownedNum
    self._status.needItemNum = improveCfg.itemNum
    texIcon:SetActive(itemBaseCfg ~= nil)
    lblName:SetActive(itemBaseCfg ~= nil)
    if itemBaseCfg ~= nil then
      GUIUtils.SetTexture(texIcon, itemBaseCfg.icon)
      GUIUtils.SetText(lblName, itemBaseCfg.name)
    end
  end
end
def.method("number", "userdata").CountDownExpireTime = function(self, endTimetamp, lbl)
  self._status.CDTimer = self._status.CDTimer or 0
  if endTimetamp == 0 then
    lbl:SetActive(false)
    _G.GameUtil.RemoveGlobalTimer(self._status.CDTimer)
    self._status.CDTimer = 0
    return
  end
  lbl:SetActive(true)
  local nowSec = _G.GetServerTime()
  local leftTime = endTimetamp - nowSec
  _G.GameUtil.RemoveGlobalTimer(self._status.CDTimer)
  local function innerFun()
    local textRes = textRes.FabaoSpirit
    if leftTime >= 86400 then
      local day = math.floor(leftTime / 86400)
      local hour = math.floor(leftTime % 86400 / 3600)
      GUIUtils.SetText(lbl, textRes[6]:format(day, textRes[7], hour, textRes[8]))
    elseif leftTime >= 3600 then
      local hour = math.floor(leftTime / 3600)
      local min = math.floor(leftTime % 3600 / 60)
      GUIUtils.SetText(lbl, textRes[6]:format(hour, textRes[8], min, textRes[9]))
    elseif leftTime >= 60 then
      local min = math.floor(leftTime / 60)
      local sec = math.floor(leftTime % 60)
      GUIUtils.SetText(lbl, textRes[6]:format(min, textRes[9], sec, textRes[10]))
    else
      GUIUtils.SetText(lbl, textRes[11]:format(leftTime, textRes[10]))
    end
  end
  innerFun()
  self._status.CDTimer = _G.GameUtil.AddGlobalTimer(1, false, function()
    leftTime = leftTime - 1
    if leftTime <= 0 then
      FabaoSpiritModule.RmvLQByClsId(self._arrOwnedLQ[self._status.selectIdx].class_id)
      _G.GameUtil.RemoveGlobalTimer(self._status.CDTimer)
      self._status.CDTimer = 0
      return
    end
    innerFun()
  end)
end
def.override("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Tip" then
    GUIUtils.ShowHoverTip(const.HOVER_TIP_ID1, 0, 0)
  elseif id == "Btn_TuJian" or id == "Btn_Get" then
    self:OnClickBtnTujian()
  elseif id == "Btn_Add" then
    self:OnClickBtnImprove()
  elseif id == "Btn_UpStar" then
    if _G.CheckCrossServerAndToast() then
      return
    end
    self:OnClickBtnStarUp()
  elseif id == "Btn_AllInfo" then
    self:OnClickBtnPreview()
  elseif id == "Label_Name" then
    local skillId = self._status.selLQBasicCfg and self._status.selLQBasicCfg.skillId or 0
    require("Main.Skill.SkillTipMgr").Instance():ShowTipByIdEx(skillId, clickObj, 0)
  elseif id == "Img_BgItem" then
    local position = clickObj:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local sprite = clickObj:GetComponent("UISprite")
    ItemTipsMgr.Instance():ShowItemFilterTips(self._status.selFilterItemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, true)
  elseif id == "Toggle_Use" then
    if clickObj:GetComponent("UIToggle").value == true then
      local clsId = self._arrOwnedLQ[self._status.selectIdx].class_id
      FabaoSpiritProtocols.SendEquipLQReq(clsId)
    else
      FabaoSpiritProtocols.SendUnEquipLQReq()
    end
  elseif string.find(id, "Group_ListItem1_%d") then
    local idx = tonumber(string.sub(id, #"Group_ListItem1_" + 1, #id))
    if self._status.selectIdx ~= idx then
      self:OnSelectLQ(idx)
    end
  elseif string.find(id, "Img_BgAttribute_") then
    local idx = tonumber(string.sub(id, #"Img_BgAttribute_" + 1, #id))
    if clickObj:GetComponent("UIToggle").value == false then
      self._status.selectAttrIdx = 0
      self._status.selImproveCfg = nil
      self:UpdateImproveInfo(self._status.selectAttrIdx, true)
    elseif self._status.selectAttrIdx ~= idx then
      local owndLQInfo = self._arrOwnedLQ[self._status.selectIdx]
      self._tblPropSel[owndLQInfo.class_id] = idx
      self._status.selectAttrIdx = idx
      self:UpdateImproveInfo(self._status.selectAttrIdx, true)
      self:UpdateUIBottom()
    end
  elseif id == "Btn_UseGold" and self:IsUseYuanBao() then
    CommonConfirmDlg.ShowConfirm(textRes.FabaoSpirit[22], textRes.FabaoSpirit[35], function(select)
      if select == 1 then
        local improveCfg = self._status.selImproveCfg
        if improveCfg == nil then
          return
        end
        local itemFilterId = improveCfg.itemFilterId
        local ownedNum, itemId = FabaoSpiritInterface.GetItemsNumByFilterId(itemFilterId)
        self:ToggleUseYB(true, itemId)
      else
        self:ToggleUseYB(false, 0)
      end
    end, nil)
  end
  self._selectType = 0
  self._selLQClsId = 0
end
def.method().OnClickBtnTujian = function(self)
  require("Main.FabaoSpirit.ui.UIFabaoLQTujian").ShowUI()
end
local MallUtility = require("Main.Mall.MallUtility")
def.method().OnClickBtnImprove = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  if self:TryQuickImprove() then
    return
  end
  local attrIdx = self._status.selectAttrIdx
  if attrIdx == 0 then
    Toast(textRes.FabaoSpirit[14])
    return
  end
  local ownLQInfo = self._status.selOwnLQInfo
  local LQClsCfg = self._status.selLQClsCfg
  local LQCfgId = self:GetLQCfgIdByClsCfg(ownLQInfo, LQClsCfg)
  if #LQClsCfg.arrCfgId == 0 then
    Toast(textRes.FabaoSpirit[12])
    return
  end
  local propCfg = self._status.selPropCfg
  local cfgProp = propCfg.arrPropValues[attrIdx]
  if ownLQInfo.properties[cfgProp.propType] >= cfgProp.dstVal then
    Toast(textRes.FabaoSpirit[13])
    return
  end
  local improveCfg = self._status.selImproveCfg
  if improveCfg == nil then
    Toast(textRes.FabaoSpirit[14])
    return
  end
  local itemFilterId = improveCfg.itemFilterId
  local ownedNum, itemId = FabaoSpiritInterface.GetItemsNumByFilterId(itemFilterId)
  local ownedYuanBao = ItemModule.Instance():GetAllYuanBao() or Int64.new(0)
  if ownedNum < improveCfg.itemNum then
    if not self:IsUseYuanBao() then
      CommonConfirmDlg.ShowConfirm(textRes.FabaoSpirit[22], textRes.FabaoSpirit[37], function(select)
        if select == 1 then
          self:ToggleUseYB(true, itemId)
        else
          self:ToggleUseYB(false, 0)
        end
      end, nil)
      return
    else
      if self._bIsWaittingYuanBaoPrice then
        warn("Querying item yuanbao price ...")
        return
      end
      local price = self._YBPrice
      local needNum = improveCfg.itemNum - ownedNum
      local needYB = needNum * price
      self._status.costYB = needYB
      if Int64.lt(ownedYuanBao, needYB) then
        _G.GotoBuyYuanbao()
      else
        FabaoSpiritProtocols.SendImproveLQReq(ownLQInfo.class_id, cfgProp.propType, true, ownedYuanBao)
      end
      return
    end
  else
    self._status.costYB = 0
    FabaoSpiritProtocols.SendImproveLQReq(ownLQInfo.class_id, cfgProp.propType, false, ownedYuanBao)
  end
end
def.method("boolean", "number").ToggleUseYB = function(self, bUesYB, itemId)
  local comToggle = self._uiGOs.groupRight:FindDirect("Group_Bottom/Btn_UseGold"):GetComponent("UIToggle")
  comToggle.value = bUesYB
  if bUesYB then
    self._bIsWaittingYuanBaoPrice = true
    self._YBPrice = 0
    require("Main.Item.ItemConsumeHelper").Instance():GetItemYuanBaoPrice(itemId, function(price)
      self._bIsWaittingYuanBaoPrice = false
      self._YBPrice = price
    end)
  else
    self._bIsWaittingYuanBaoPrice = false
    self._YBPrice = 0
  end
end
def.method("=>", "boolean").IsUseYuanBao = function(self)
  local comToggle = self._uiGOs.groupRight:FindDirect("Group_Bottom/Btn_UseGold"):GetComponent("UIToggle")
  return comToggle.value
end
def.method().OnClickBtnStarUp = function(self)
  if self._status.selCanLvUp ~= nil and not self._status.selCanLvUp then
    Toast(textRes.FabaoSpirit[12])
    return
  end
  local ownLQInfo = self._arrOwnedLQ[self._status.selectIdx]
  if ownLQInfo ~= nil then
    require("Main.FabaoSpirit.ui.UILQStarUp").Instance():ShowPanel(ownLQInfo)
  end
end
def.method().OnClickBtnPreview = function(self)
  if self._arrOwnedLQ == nil or #self._arrOwnedLQ == 0 then
    return
  end
  require("Main.FabaoSpirit.ui.UIPreview").Instance():ShowPanel()
end
def.method("number").OnSelectLQ = function(self, idx)
  self._status.selectIdx = idx
  local owndLQInfo = self._arrOwnedLQ[self._status.selectIdx]
  self._status.selectAttrIdx = self._tblPropSel[owndLQInfo.class_id]
  self:UpdateImproveInfo(self._status.selectAttrIdx, true)
  self:UpdateRightUI()
end
local ECUIModel = require("Model.ECUIModel")
def.method("number", "number").SetUIModel = function(self, model_id, effectId)
  local comUIModel = self._uiGOs.groupRight:FindDirect("Group_Center/Model_LQ"):GetComponent("UIModel")
  local modelPath, modelColor = _G.GetModelPath(model_id)
  if modelPath == nil or modelPath == "" then
    return
  end
  FabaoSpiritInterface._rmvModelEffects(self._effects)
  if self._uiModel then
    self._uiModel:Destroy()
  end
  local function fun_afterload()
    comUIModel.modelGameObject = self._uiModel.m_model
    self._effects = {}
    FabaoSpiritInterface._addBoneEffect(effectId, self._uiModel.m_model, self._effects)
    if comUIModel.mCanOverflow ~= nil then
      comUIModel.mCanOverflow = true
      local cam = comUIModel:get_modelCamera()
      cam:set_orthographic(true)
    end
  end
  self._uiModel = ECUIModel.new(model_id)
  self._uiModel.m_bUncache = true
  self._uiModel:LoadUIModel(modelPath, function(ret)
    if not self._uiModel or not self._uiModel.m_model or self._uiModel.m_model.isnil then
      return
    end
    fun_afterload()
  end)
end
def.method("=>", "table").GetCurPropCfg = function(self)
  local ownLQInfo = self._arrOwnedLQ[self._status.selectIdx]
  local LQClsCfg = FabaoSpiritUtils.GetLQClsCfgByClsId(ownLQInfo.class_id)
  local cfgId = self:GetLQCfgIdByClsCfg(ownLQInfo, LQClsCfg)
  local propCfg = FabaoSpiritUtils.GetFabaoLQPropCfgById(cfgId)
  return propCfg
end
def.static("table", "table").OnEquipedLQChange = function(p, c)
  local self = FabaoSpiritNode.Instance()
  self:UpdateLeftList()
end
def.static("table", "table").OnOwndLQChange = function(p, c)
  local self = FabaoSpiritNode.Instance()
  self:UpdateOwnedLQList()
  self:UpdateUI()
end
def.static("table", "table").OnLQInfoChange = function(p, c)
  local self = FabaoSpiritNode.Instance()
  self:UpdateOwnedLQList()
  if p == nil or not p.bUpdateList then
    self:UpdateRightUI()
  else
    self:UpdateLeftList()
    self:UpdateRightUI()
  end
  self:UpdateUIBottom()
end
def.method("table").OnItemChange = function(self, p)
  if self._status == nil then
    return
  end
  self:UpdateUIBottom()
end
def.static("table", "table").OnLQPropInfoChange = function(self, p)
  self:UpdateOwnedLQList()
  self:UpdateRightUI()
  self:UpdateUIBottom()
  if not p.bQuick then
    if self._status ~= nil and self._status.costYB ~= nil and self._status.costYB > 0 then
      Toast(textRes.FabaoSpirit[36]:format(self._status.costYB, FabaoSpiritUtils.GetFabaoSpiritProName(p.propType), p.improveProp))
    else
      Toast(textRes.FabaoSpirit[19]:format(FabaoSpiritUtils.GetFabaoSpiritProName(p.propType), p.improveProp))
    end
  end
end
local IMPROVE_SUCC_THRE = 2
def.field("number")._improvedAttrIdx = 0
def.field("number")._improvedCount = 0
def.method("table").OnSImproveLQSuccess = function(self, p)
  if self.isShow then
    self:UpdateImproveInfo(self._status.selectAttrIdx, false)
  end
end
def.method("number", "boolean").UpdateImproveInfo = function(self, idx, bClear)
  if bClear then
    self._improvedAttrIdx = idx
    self._improvedCount = 0
  elseif idx == self._improvedAttrIdx then
    self._improvedCount = self._improvedCount + 1
  else
    self._improvedAttrIdx = idx
    self._improvedCount = 1
  end
end
def.method("=>", "boolean").TryQuickImprove = function(self)
  if self._improvedCount < IMPROVE_SUCC_THRE then
    return false
  else
    self._improvedCount = 0
  end
  local attrIdx = self._status.selectAttrIdx
  if attrIdx == 0 then
    return false
  end
  local ownLQInfo = self._status.selOwnLQInfo
  local propCfg = self._status.selPropCfg
  local cfgProp = propCfg and propCfg.arrPropValues[attrIdx]
  if nil == ownLQInfo or nil == cfgProp or 0 > self._status.selFilterItemId or ownLQInfo.properties[cfgProp.propType] >= cfgProp.dstVal then
    return false
  end
  local QuickImprovePanel = require("Main.FabaoSpirit.ui.QuickImprovePanel")
  QuickImprovePanel.ShowPanel(ownLQInfo, attrIdx)
  return true
end
return FabaoSpiritNode.Commit()

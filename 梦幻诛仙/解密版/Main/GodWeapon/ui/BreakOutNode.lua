local Lplus = require("Lplus")
local GodWeaponTabNode = require("Main.GodWeapon.ui.GodWeaponTabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local BreakOutData = require("Main.GodWeapon.BreakOut.data.BreakOutData")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local BreakOutUtils = require("Main.GodWeapon.BreakOut.BreakOutUtils")
local EasyBasicItemTip = require("Main.Common.EasyBasicItemTip")
local EquipUtils = require("Main.Equip.EquipUtils")
local EquipModule = Lplus.ForwardDeclare("EquipModule")
local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
local ItemModule = require("Main.Item.ItemModule")
local BreakOutProtocols = require("Main.GodWeapon.BreakOut.BreakOutProtocols")
local CurrencyFactory = require("Main.Currency.CurrencyFactory")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local GUIFxMan = require("Fx.GUIFxMan")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemAccessMgr = require("Main.Item.ItemAccessMgr")
local BreakOutNode = Lplus.Extend(GodWeaponTabNode, "BreakOutNode")
local def = BreakOutNode.define
local instance
def.static("=>", BreakOutNode).Instance = function()
  if instance == nil then
    instance = BreakOutNode()
  end
  return instance
end
def.const("number").DEFAULT_SELECT_IDX = 1
def.field("table")._uiObjs = nil
def.field(EasyBasicItemTip).itemTipHelper = nil
def.const("number").BREAK_OUT_INTERVAL = 0.8
def.field("table")._equipList = nil
def.field("number")._selectIndex = 0
def.field("table")._selectEquipInfo = nil
def.field("table")._selectEquipCostList = nil
def.field("boolean")._bStageUp = false
def.field("number")._curImproveCostYB = 0
def.field("number")._disableTimerId = 0
def.const("number").STAGE_UP_EFFECT_DURATION = 5
def.const("number").LEVEL_UP_EFFECT_DURATION = 5
def.field("number")._effectTimerID = 0
def.field("number")._curEffectId = 0
def.field("userdata")._curEffectObj = nil
def.override().OnShow = function(self)
  GUIUtils.SetActive(self.m_node, false)
  GameUtil.AddGlobalTimer(0.01, true, function()
    self:DoShow()
  end)
end
def.method().DoShow = function(self)
  self:InitUI()
  self:_HandleEventListeners(true)
  self:_UpdateUI()
end
def.method().InitUI = function(self)
  self.itemTipHelper = EasyBasicItemTip()
  self._uiObjs = {}
  self._uiObjs.Group_NoData = self.m_panel:FindDirect("Img_Bg/Group_NoData")
  self._uiObjs.Label_Nodata = self._uiObjs.Group_NoData:FindDirect("Img_Talk/Label")
  self._uiObjs.Group_EquipList = self.m_panel:FindDirect("Img_Bg/Group_EquipList")
  self._uiObjs.Group_TP = self.m_panel:FindDirect("Img_Bg/Group_TP")
  self._uiObjs.TabImg_Red = self.m_panel:FindDirect("Img_Bg/Tap_TP/Img_Red")
  self._uiObjs.Group_Title = self._uiObjs.Group_TP:FindDirect("Group_Title")
  self._uiObjs.Label_Equip_Name = self._uiObjs.Group_Title:FindDirect("GW_Name/Label_GWName")
  self._uiObjs.Label_Stage = self._uiObjs.Group_Title:FindDirect("GW_State/Label_StateNum")
  self._uiObjs.Label_Lv = self._uiObjs.Group_Title:FindDirect("GW_Lv/Label_LvNum")
  self._uiObjs.Group_Center = self._uiObjs.Group_TP:FindDirect("Group_Center")
  self._uiObjs.Icon_Frame = self._uiObjs.Group_Center:FindDirect("Group_GW/Icon_GWEquip")
  self._uiObjs.Icon_Equip = self._uiObjs.Group_Center:FindDirect("Group_GW/Icon_Equip")
  self._uiObjs.Group_Term = self._uiObjs.Group_Center:FindDirect("Group_Term")
  self._uiObjs.Label_PlayerLvNum = self._uiObjs.Group_Term:FindDirect("GW_PlayerLv/Label_PlayerLvNum")
  self._uiObjs.Label_ServerLvNum = self._uiObjs.Group_Term:FindDirect("GW_ServerLv/Label_ServerLvNum")
  self._uiObjs.Group_Cost_Items = self._uiObjs.Group_Center:FindDirect("Group_Cost")
  self._uiObjs.costScrollView = self._uiObjs.Group_Cost_Items:FindDirect("ScrollView_Cost"):GetComponent("UIScrollView")
  self._uiObjs.CostList_Item = self._uiObjs.Group_Cost_Items:FindDirect("ScrollView_Cost/List_Item")
  self._uiObjs.costUIList = self._uiObjs.CostList_Item:GetComponent("UIList")
  self._uiObjs.Group_Attr = self._uiObjs.Group_Center:FindDirect("Group_Att")
  self._uiObjs.AttCur_1 = self._uiObjs.Group_Attr:FindDirect("List_Cur/AttCur_1")
  self._uiObjs.AttCur_2 = self._uiObjs.Group_Attr:FindDirect("List_Cur/AttCur_2")
  self._uiObjs.Label_Level_CurAttName1 = self._uiObjs.Group_Attr:FindDirect("List_Cur/AttCur_1/Label_AttName")
  self._uiObjs.Label_Level_CurAttName2 = self._uiObjs.Group_Attr:FindDirect("List_Cur/AttCur_2/Label_AttName")
  self._uiObjs.Label_Level_CurAttNum1 = self._uiObjs.Group_Attr:FindDirect("List_Cur/AttCur_1/Label_AttNum")
  self._uiObjs.Label_Level_CurAttNum2 = self._uiObjs.Group_Attr:FindDirect("List_Cur/AttCur_2/Label_AttNum")
  self._uiObjs.AttChange_1 = self._uiObjs.Group_Attr:FindDirect("List_Change/AttChange_1")
  self._uiObjs.AttChange_2 = self._uiObjs.Group_Attr:FindDirect("List_Change/AttChange_2")
  self._uiObjs.Label_Level_NextAttName1 = self._uiObjs.Group_Attr:FindDirect("List_Change/AttChange_1/Label_AttName")
  self._uiObjs.Label_Level_NextAttName2 = self._uiObjs.Group_Attr:FindDirect("List_Change/AttChange_2/Label_AttName")
  self._uiObjs.Label_Level_NextAttNum1 = self._uiObjs.Group_Attr:FindDirect("List_Change/AttChange_1/Label_AttNum")
  self._uiObjs.Label_Level_NextAttNum2 = self._uiObjs.Group_Attr:FindDirect("List_Change/AttChange_2/Label_AttNum")
  self._uiObjs.Label_Level_AttUpNum1 = self._uiObjs.Group_Attr:FindDirect("List_Change/AttChange_1/Label_AttUpNum")
  self._uiObjs.Label_Level_AttUpNum2 = self._uiObjs.Group_Attr:FindDirect("List_Change/AttChange_2/Label_AttUpNum")
  self._uiObjs.Group_Break = self._uiObjs.Group_Center:FindDirect("Group_Break")
  self._uiObjs.Label_Stage_CurAttNum1 = self._uiObjs.Group_Break:FindDirect("List_Cur/Group_CurLabel_1/Label_AttNum")
  self._uiObjs.Label_Stage_CurAttNum2 = self._uiObjs.Group_Break:FindDirect("List_Cur/Group_CurLabel_2/Label_AttNum")
  self._uiObjs.Label_Stage_CurAttNum3 = self._uiObjs.Group_Break:FindDirect("List_Cur/Group_CurLabel_3/Label_AttNum")
  self._uiObjs.Label_Stage_NextAttNum1 = self._uiObjs.Group_Break:FindDirect("List_Change/List_ChangeLabel_1/Label_AttNum")
  self._uiObjs.Label_Stage_NextAttNum2 = self._uiObjs.Group_Break:FindDirect("List_Change/List_ChangeLabel_2/Label_AttNum")
  self._uiObjs.Label_Stage_NextAttNum3 = self._uiObjs.Group_Break:FindDirect("List_Change/List_ChangeLabel_3/Label_AttNum")
  self._uiObjs.Group_Bottom = self._uiObjs.Group_TP:FindDirect("Group_Bottom")
  self._uiObjs.Group_CostMoney = self._uiObjs.Group_Bottom:FindDirect("Group_CostMoney")
  self._uiObjs.Label_UseMoneyNum = self._uiObjs.Group_Bottom:FindDirect("Group_CostMoney/Img_BgUseMoney/Label_UseMoneyNum")
  self._uiObjs.Img_UseMoneyIcon = self._uiObjs.Group_Bottom:FindDirect("Group_CostMoney/Img_BgUseMoney/Img_UseMoneyIcon")
  self._uiObjs.Label_HaveMoneyNum = self._uiObjs.Group_Bottom:FindDirect("Group_CostMoney/Img_BgHaveMoney/Label_HaveMoneyNum")
  self._uiObjs.Img_HaveMoneyIcon = self._uiObjs.Group_Bottom:FindDirect("Group_CostMoney/Img_BgHaveMoney/Img_HaveMoneyIcon")
  self._uiObjs.Group_Make = self._uiObjs.Group_Bottom:FindDirect("Group_Make")
  self._uiObjs.Btn_Make = self._uiObjs.Group_Make:FindDirect("Btn_Make")
  self._uiObjs.Btn_YuanbaoUse = self._uiObjs.Group_Make:FindDirect("Btn_YuanbaoUse")
  self._uiObjs.uiToggle_UseYB = self._uiObjs.Btn_YuanbaoUse:GetComponent("UIToggle")
  self._uiObjs.Label_Make = self._uiObjs.Group_Make:FindDirect("Btn_Make/Label_Make")
  self._uiObjs.Img_Red = self._uiObjs.Group_Make:FindDirect("Btn_Make/Img_Red")
  self._uiObjs.Group_Need = self._uiObjs.Group_Make:FindDirect("Btn_Make/Group_Need")
  self._uiObjs.Label_Cost = self._uiObjs.Group_Need:FindDirect("Label_Num")
  GUIUtils.SetText(self._uiObjs.Label_Cost, "")
  GUIUtils.EnableButton(self._uiObjs.Btn_Make, true)
  self._uiObjs.effectRoot = self._uiObjs.Group_TP:FindDirect("Fx")
  self._uiObjs.uiParticle = self._uiObjs.effectRoot:GetComponent("UIParticle")
  self._uiObjs.Group_Limit = self._uiObjs.Group_TP:FindDirect("Group_Limit")
  self._uiObjs.Group_Title_Max = self._uiObjs.Group_Limit:FindDirect("Group_Title")
  self._uiObjs.Label_Equip_Name_Max = self._uiObjs.Group_Title_Max:FindDirect("GW_Name/Label_GWName")
  self._uiObjs.Label_Stage_Max = self._uiObjs.Group_Title_Max:FindDirect("GW_State/Label_StateNum")
  self._uiObjs.Label_Lv_Max = self._uiObjs.Group_Title_Max:FindDirect("GW_Lv/Label_LvNum")
  self._uiObjs.Icon_Frame_Max = self._uiObjs.Group_Limit:FindDirect("Img_BgPreview/Icon_Bg")
  self._uiObjs.Icon_Equip_Max = self._uiObjs.Group_Limit:FindDirect("Img_BgPreview/Icon_Bg/Icon_Equip")
  self._uiObjs.Group_Level_Attr_Max = self._uiObjs.Group_Limit:FindDirect("Img_BgPreview/List_Change")
  self._uiObjs.Label_Level_CurAttName1_Max = self._uiObjs.Group_Level_Attr_Max:FindDirect("AttChange_1/Label_AttName")
  self._uiObjs.Label_Level_CurAttName2_Max = self._uiObjs.Group_Level_Attr_Max:FindDirect("AttChange_2/Label_AttName")
  self._uiObjs.Label_Level_CurAttNum1_Max = self._uiObjs.Group_Level_Attr_Max:FindDirect("AttChange_1/Label_AttNum")
  self._uiObjs.Label_Level_CurAttNum2_Max = self._uiObjs.Group_Level_Attr_Max:FindDirect("AttChange_2/Label_AttNum")
  self._uiObjs.Group_Stage_Attr_Max = self._uiObjs.Group_Limit:FindDirect("Img_BgPreview/List_Cur")
  self._uiObjs.Label_Stage_CurAttNum1_Max = self._uiObjs.Group_Stage_Attr_Max:FindDirect("Group_CurLabel_1/Label_AttNum")
  self._uiObjs.Label_Stage_CurAttNum2_Max = self._uiObjs.Group_Stage_Attr_Max:FindDirect("Group_CurLabel_2/Label_AttNum")
  self._uiObjs.Label_Stage_CurAttNum3_Max = self._uiObjs.Group_Stage_Attr_Max:FindDirect("Group_CurLabel_3/Label_AttNum")
end
def.method()._UpdateUI = function(self)
  local preSelectItemUuid = self._selectEquipInfo and self._selectEquipInfo.uuid or nil
  self:UpdateEquipBag()
  if preSelectItemUuid then
    self.m_base:SelectEquipByUuid(preSelectItemUuid)
  else
    self.m_base:SelectEquipByIdx(BreakOutNode.DEFAULT_SELECT_IDX)
  end
end
def.method().UpdateEquipBag = function(self)
  self._equipList = BreakOutData.Instance():GetBreakOutEquips()
  if self._equipList and #self._equipList > 0 then
    GUIUtils.SetActive(self._uiObjs.Group_EquipList, true)
    GUIUtils.SetActive(self._uiObjs.Group_TP, true)
    GUIUtils.SetActive(self._uiObjs.Group_NoData, false)
    self.m_base:ShowEquipList(self._equipList)
  else
    GUIUtils.SetActive(self._uiObjs.Group_EquipList, false)
    GUIUtils.SetActive(self._uiObjs.Group_TP, false)
    GUIUtils.SetActive(self._uiObjs.Group_NoData, true)
  end
end
def.method("number", "table").UpdateSelectedEquip = function(self, index, equipInfo)
  self._selectIndex = index
  self._selectEquipInfo = equipInfo
  self._selectEquipCostList = nil
  if equipInfo then
    if BreakOutUtils.ReachGodWeaponLimit(equipInfo) then
      GUIUtils.SetActive(self._uiObjs.Group_Limit, true)
      GUIUtils.SetActive(self._uiObjs.Group_Title, false)
      GUIUtils.SetActive(self._uiObjs.Group_Center, false)
      GUIUtils.SetActive(self._uiObjs.Group_Bottom, false)
      self:UpdateEquipMaxStageInfo(equipInfo)
    else
      GUIUtils.SetActive(self._uiObjs.Group_Limit, false)
      GUIUtils.SetActive(self._uiObjs.Group_Title, true)
      GUIUtils.SetActive(self._uiObjs.Group_Center, true)
      GUIUtils.SetActive(self._uiObjs.Group_Bottom, true)
      self:UpdateEquipPromoteInfo(equipInfo)
      self:UpdateSelectEquipReddot()
      self:UpdateBreakOutTabReddot()
    end
  else
    warn("[ERROR][BreakOutNode:UpdateSelectedEquip] equipInfo nil at index:", index)
  end
end
def.method("table").UpdateEquipMaxStageInfo = function(self, equipInfo)
  if equipInfo then
    warn("[BreakOutNode:UpdateEquipMaxStageInfo] show Selected Equip with max stage.")
    local godWeaponStage = equipInfo.godWeaponStage and equipInfo.godWeaponStage or 0
    local godWeaponLevel = equipInfo.godWeaponLevel and equipInfo.godWeaponLevel or 0
    local curStageCfg = BreakOutData.Instance():GetStageCfg(godWeaponStage)
    if nil == curStageCfg then
      warn("[ERROR][BreakOutNode:UpdateEquipMaxStageInfo] curStageCfg nil for stage:", godWeaponStage)
      return
    end
    local curLevelCfg = BreakOutData.Instance():GetLevelCfg(equipInfo.wearPos, godWeaponLevel)
    if nil == curLevelCfg then
      warn("[ERROR][BreakOutNode:UpdateEquipMaxStageInfo] curLevelCfg nil for wearPos, godWeaponLevel:", equipInfo.wearPos, godWeaponLevel)
      return
    end
    GUIUtils.SetText(self._uiObjs.Label_Equip_Name_Max, equipInfo.realName)
    GUIUtils.SetText(self._uiObjs.Label_Stage_Max, string.format(textRes.GodWeapon.BreakOut.GODWEAPON_STAGE, godWeaponStage))
    GUIUtils.SetText(self._uiObjs.Label_Lv_Max, string.format(textRes.GodWeapon.BreakOut.GODWEAPON_LEVEL, godWeaponLevel))
    GUIUtils.SetSprite(self._uiObjs.Icon_Frame_Max, equipInfo.frameName)
    GUIUtils.FillIcon(self._uiObjs.Icon_Equip_Max:GetComponent("UITexture"), equipInfo.icon)
    GUIUtils.SetText(self._uiObjs.Label_Stage_CurAttNum1_Max, BreakOutData.Instance():GetStageMaxLevel(equipInfo.godWeaponStage))
    GUIUtils.SetText(self._uiObjs.Label_Stage_CurAttNum2_Max, curStageCfg.gemSlotNum)
    GUIUtils.SetText(self._uiObjs.Label_Stage_CurAttNum3_Max, curStageCfg.maxGemLevel)
    local attrAType = EquipUtils.GetAttrAById(equipInfo.id)
    local attrBType = EquipUtils.GetAttrBById(equipInfo.id)
    warn("[BreakOutNode:UpdateEquipMaxStageInfo] attrAType, attrBType:", attrAType, attrBType)
    if attrAType and attrAType > 0 then
      GUIUtils.SetActive(self._uiObjs.Label_Level_CurAttName1_Max, true)
      GUIUtils.SetActive(self._uiObjs.Label_Level_CurAttNum1_Max, true)
      local attrAName = EquipModule.GetAttriName(attrAType)
      local curAAttr = curLevelCfg.improveCfgs[attrAType]
      if not curAAttr or not curAAttr then
        curAAttr = 0
      end
      GUIUtils.SetText(self._uiObjs.Label_Level_CurAttName1_Max, attrAName)
      GUIUtils.SetText(self._uiObjs.Label_Level_CurAttNum1_Max, "+" .. curAAttr)
    else
      GUIUtils.SetActive(self._uiObjs.Label_Level_CurAttName1_Max, false)
      GUIUtils.SetActive(self._uiObjs.Label_Level_CurAttNum1_Max, false)
    end
    if attrBType and attrBType > 0 then
      GUIUtils.SetActive(self._uiObjs.Label_Level_CurAttName2_Max, true)
      GUIUtils.SetActive(self._uiObjs.Label_Level_CurAttNum2_Max, true)
      local attrBName = EquipModule.GetAttriName(attrBType)
      local curBAttr = curLevelCfg.improveCfgs[attrBType]
      if not curBAttr or not curBAttr then
        curBAttr = 0
      end
      GUIUtils.SetText(self._uiObjs.Label_Level_CurAttName2_Max, attrBName)
      GUIUtils.SetText(self._uiObjs.Label_Level_CurAttNum2_Max, "+" .. curBAttr)
    else
      GUIUtils.SetActive(self._uiObjs.Label_Level_CurAttName2_Max, false)
      GUIUtils.SetActive(self._uiObjs.Label_Level_CurAttNum2_Max, false)
    end
  else
    warn("[ERROR][BreakOutNode:UpdateEquipMaxStageInfo] equipInfo nil!")
  end
end
def.method("table").UpdateEquipPromoteInfo = function(self, equipInfo)
  if nil == equipInfo then
    warn("[ERROR][BreakOutNode:UpdateEquipPromoteInfo] equipInfo nil!")
    return
  end
  self._bStageUp = BreakOutUtils.ShallEquipStageUp(equipInfo)
  local godWeaponStage = equipInfo.godWeaponStage and equipInfo.godWeaponStage or 0
  local godWeaponLevel = equipInfo.godWeaponLevel and equipInfo.godWeaponLevel or 0
  local nextStageCfg, nextLevelCfg
  if self._bStageUp then
    nextStageCfg = BreakOutData.Instance():GetStageCfg(godWeaponStage + 1)
  else
    nextLevelCfg = BreakOutData.Instance():GetLevelCfg(equipInfo.wearPos, godWeaponLevel + 1)
  end
  if self._bStageUp and nil == nextStageCfg or not self._bStageUp and nil == nextLevelCfg then
    GUIUtils.SetActive(self._uiObjs.Group_Term, false)
    GUIUtils.SetActive(self._uiObjs.Group_Cost_Items, false)
    GUIUtils.SetActive(self._uiObjs.Group_Attr, false)
    GUIUtils.SetActive(self._uiObjs.Group_Break, false)
    GUIUtils.SetActive(self._uiObjs.Group_Bottom, false)
    return
  end
  GUIUtils.SetText(self._uiObjs.Label_Equip_Name, equipInfo.realName)
  GUIUtils.SetText(self._uiObjs.Label_Stage, string.format(textRes.GodWeapon.BreakOut.GODWEAPON_STAGE, godWeaponStage))
  GUIUtils.SetText(self._uiObjs.Label_Lv, string.format(textRes.GodWeapon.BreakOut.GODWEAPON_LEVEL, godWeaponLevel))
  GUIUtils.SetSprite(self._uiObjs.Icon_Frame, equipInfo.frameName)
  GUIUtils.FillIcon(self._uiObjs.Icon_Equip:GetComponent("UITexture"), equipInfo.icon)
  if self._bStageUp then
    GUIUtils.SetActive(self._uiObjs.Group_Term, true)
    GUIUtils.SetText(self._uiObjs.Label_PlayerLvNum, string.format(textRes.GodWeapon.BreakOut.GODWEAPON_LEVEL, nextStageCfg.requiredRoleLevel))
    GUIUtils.SetText(self._uiObjs.Label_ServerLvNum, string.format(textRes.GodWeapon.BreakOut.GODWEAPON_LEVEL, nextStageCfg.requiredServerLevel))
  else
    GUIUtils.SetActive(self._uiObjs.Group_Term, false)
  end
  self._selectEquipCostList = nil
  local consumedItemMap
  if self._bStageUp then
    self._selectEquipCostList = nextStageCfg.costItems
    consumedItemMap = equipInfo.stageUpCostMap
  elseif nextLevelCfg then
    self._selectEquipCostList = nextLevelCfg.costItems
    consumedItemMap = equipInfo.levelUpCostMap
  end
  self:ClearRequestList()
  if self._selectEquipCostList and 0 < #self._selectEquipCostList then
    GUIUtils.SetActive(self._uiObjs.Group_Cost_Items, true)
    self._uiObjs.costUIList.itemCount = #self._selectEquipCostList
    self._uiObjs.costUIList:Resize()
    self._uiObjs.costUIList:Reposition()
    for index, item in ipairs(self._selectEquipCostList) do
      local curConsumeNum = consumedItemMap and consumedItemMap[item.id] or 0
      self:SetListCostItemInfo(index, item, curConsumeNum)
    end
    self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
  else
    GUIUtils.SetActive(self._uiObjs.Group_Cost_Items, false)
  end
  if self._bStageUp then
    GUIUtils.SetActive(self._uiObjs.Group_Attr, false)
    GUIUtils.SetActive(self._uiObjs.Group_Break, true)
    local curStageCfg = BreakOutData.Instance():GetStageCfg(equipInfo.godWeaponStage)
    GUIUtils.SetText(self._uiObjs.Label_Stage_CurAttNum1, curStageCfg and BreakOutData.Instance():GetStageMaxLevel(equipInfo.godWeaponStage) or 0)
    GUIUtils.SetText(self._uiObjs.Label_Stage_CurAttNum2, curStageCfg and curStageCfg.gemSlotNum or 0)
    GUIUtils.SetText(self._uiObjs.Label_Stage_CurAttNum3, curStageCfg and curStageCfg.maxGemLevel or 0)
    GUIUtils.SetText(self._uiObjs.Label_Stage_NextAttNum1, BreakOutData.Instance():GetStageMaxLevel(equipInfo.godWeaponStage + 1))
    GUIUtils.SetText(self._uiObjs.Label_Stage_NextAttNum2, nextStageCfg.gemSlotNum)
    GUIUtils.SetText(self._uiObjs.Label_Stage_NextAttNum3, nextStageCfg.maxGemLevel)
  else
    GUIUtils.SetActive(self._uiObjs.Group_Attr, true)
    GUIUtils.SetActive(self._uiObjs.Group_Break, false)
    local curLevelCfg = BreakOutData.Instance():GetLevelCfg(equipInfo.wearPos, equipInfo.godWeaponLevel)
    local attrAType = EquipUtils.GetAttrAById(equipInfo.id)
    local attrBType = EquipUtils.GetAttrBById(equipInfo.id)
    local attrAName = EquipModule.GetAttriName(attrAType)
    local attrBName = EquipModule.GetAttriName(attrBType)
    local curAAttr = 0
    if attrAType and attrAType > 0 then
      GUIUtils.SetActive(self._uiObjs.AttCur_1, true)
      if curLevelCfg then
        curAAttr = curLevelCfg.improveCfgs[attrAType]
        if not curAAttr or not curAAttr then
          curAAttr = 0
        end
      end
      GUIUtils.SetText(self._uiObjs.Label_Level_CurAttName1, attrAName)
      GUIUtils.SetText(self._uiObjs.Label_Level_CurAttNum1, "+" .. curAAttr)
    else
      GUIUtils.SetActive(self._uiObjs.AttCur_1, false)
    end
    local curBAttr = 0
    if attrBType and attrBType > 0 then
      GUIUtils.SetActive(self._uiObjs.AttCur_2, true)
      if curLevelCfg then
        curBAttr = curLevelCfg.improveCfgs[attrBType]
        if not curBAttr or not curBAttr then
          curBAttr = 0
        end
      end
      GUIUtils.SetText(self._uiObjs.Label_Level_CurAttName2, attrBName)
      GUIUtils.SetText(self._uiObjs.Label_Level_CurAttNum2, "+" .. curBAttr)
    else
      GUIUtils.SetActive(self._uiObjs.AttCur_2, false)
    end
    local nextAAttr = 0
    if attrAType and attrAType > 0 then
      GUIUtils.SetActive(self._uiObjs.AttChange_1, true)
      if nextLevelCfg then
        nextAAttr = nextLevelCfg.improveCfgs[attrAType]
        if not nextAAttr or not nextAAttr then
          nextAAttr = 0
        end
      end
      GUIUtils.SetText(self._uiObjs.Label_Level_NextAttName1, attrAName)
      GUIUtils.SetText(self._uiObjs.Label_Level_NextAttNum1, nextAAttr > 0 and "+" .. nextAAttr or "-")
      GUIUtils.SetText(self._uiObjs.Label_Level_AttUpNum1, math.max(0, nextAAttr - curAAttr))
    else
      GUIUtils.SetActive(self._uiObjs.AttChange_1, false)
    end
    local nextBAttr = 0
    if attrBType and attrBType > 0 and nextLevelCfg then
      GUIUtils.SetActive(self._uiObjs.AttChange_2, true)
      if nextLevelCfg then
        nextBAttr = nextLevelCfg.improveCfgs[attrBType]
        if not nextBAttr or not nextBAttr then
          nextBAttr = 0
        end
      end
      GUIUtils.SetText(self._uiObjs.Label_Level_NextAttName2, attrBName)
      GUIUtils.SetText(self._uiObjs.Label_Level_NextAttNum2, nextBAttr > 0 and "+" .. nextBAttr or "-")
      GUIUtils.SetText(self._uiObjs.Label_Level_AttUpNum2, math.max(0, nextBAttr - curBAttr))
    else
      GUIUtils.SetActive(self._uiObjs.AttChange_2, false)
    end
  end
  self:UpdateCostCurrency()
  self:UpdateAutoBuyToggle()
end
def.method().UpdateCostCurrency = function(self)
  if self._bStageUp then
    local nextStageCfg = self._selectEquipInfo and BreakOutData.Instance():GetStageCfg(self._selectEquipInfo.godWeaponStage + 1) or nil
    if nextStageCfg then
      GUIUtils.SetActive(self._uiObjs.Group_CostMoney, true)
      local needCurrencyNum = nextStageCfg.requiredCurrencyNum
      if needCurrencyNum == nil then
        needCurrencyNum = 0
      end
      local moneyData = CurrencyFactory.Create(nextStageCfg.requiredCurrencyType)
      local haveCurrencyNum = moneyData:GetHaveNum()
      GUIUtils.SetTextAndColor(self._uiObjs.Label_UseMoneyNum, needCurrencyNum, haveCurrencyNum:lt(needCurrencyNum) and Color.red or Color.white)
      GUIUtils.SetText(self._uiObjs.Label_HaveMoneyNum, Int64.tostring(haveCurrencyNum))
      local currencySprite = moneyData:GetSpriteName()
      GUIUtils.SetSprite(self._uiObjs.Img_UseMoneyIcon, currencySprite)
      GUIUtils.SetSprite(self._uiObjs.Img_HaveMoneyIcon, currencySprite)
    else
      GUIUtils.SetActive(self._uiObjs.Group_CostMoney, false)
    end
  else
    local nextLevelCfg = self._selectEquipInfo and BreakOutData.Instance():GetLevelCfg(self._selectEquipInfo.wearPos, self._selectEquipInfo.godWeaponLevel + 1) or nil
    if nextLevelCfg then
      GUIUtils.SetActive(self._uiObjs.Group_CostMoney, true)
      local needCurrencyNum = nextLevelCfg.requiredCurrencyNum
      if needCurrencyNum == nil then
        needCurrencyNum = 0
      end
      local moneyData = CurrencyFactory.Create(nextLevelCfg.requiredCurrencyType)
      local haveCurrencyNum = moneyData:GetHaveNum()
      GUIUtils.SetTextAndColor(self._uiObjs.Label_UseMoneyNum, needCurrencyNum, haveCurrencyNum:lt(needCurrencyNum) and Color.red or Color.white)
      GUIUtils.SetText(self._uiObjs.Label_HaveMoneyNum, Int64.tostring(haveCurrencyNum))
      local currencySprite = moneyData:GetSpriteName()
      GUIUtils.SetSprite(self._uiObjs.Img_HaveMoneyIcon, currencySprite)
      GUIUtils.SetSprite(self._uiObjs.Img_UseMoneyIcon, currencySprite)
    else
      GUIUtils.SetActive(self._uiObjs.Group_CostMoney, false)
    end
  end
end
def.method().UpdateAutoBuyToggle = function(self)
  GUIUtils.SetActive(self._uiObjs.Btn_YuanbaoUse, false)
  if self._bStageUp then
    GUIUtils.SetActive(self._uiObjs.Group_Need, false)
    GUIUtils.SetActive(self._uiObjs.Label_Make, true)
    GUIUtils.SetText(self._uiObjs.Label_Make, textRes.GodWeapon.BreakOut.WEAPON_BREAK_OUT)
  else
    GUIUtils.SetActive(self._uiObjs.Group_Need, false)
    GUIUtils.SetActive(self._uiObjs.Label_Make, true)
    GUIUtils.SetText(self._uiObjs.Label_Make, textRes.GodWeapon.BreakOut.WEAPON_LEVEL_UP)
  end
end
def.method("number", "table", "number").SetListCostItemInfo = function(self, index, item, curConsumeNum)
  if nil == item then
    warn("[ERROR][BreakOutNode:SetListCostItemInfo] item nil at index:", index)
    return
  end
  local itemBase = ItemUtils.GetItemBase(item.id)
  if nil == itemBase then
    warn("[ERROR][BreakOutData:SetListCostItemInfo] itemBase nil for itemid:", item.id)
  end
  local listItem = self._uiObjs.CostList_Item:FindDirect("Item_" .. index)
  if nil == listItem then
    warn("[ERROR][BreakOutNode:SetListCostItemInfo] listItem nil at index:", index)
    return
  end
  local Icon_Item_Frame = listItem:FindDirect("Icon_GWEquip_" .. index)
  GUIUtils.SetSprite(Icon_Item_Frame, string.format("Cell_%02d", itemBase.namecolor))
  local Icon_Item_Icon = listItem:FindDirect("Icon_Equip_" .. index)
  GUIUtils.FillIcon(Icon_Item_Icon:GetComponent("UITexture"), itemBase.icon)
  local Label_HaveNum = listItem:FindDirect("Label_" .. index)
  local ItemModule = require("Main.Item.ItemModule")
  local haveCount = ItemModule.Instance():GetItemCountById(item.id)
  if haveCount and haveCount > 0 then
    GUIUtils.SetText(Label_HaveNum, haveCount)
  else
    GUIUtils.SetText(Label_HaveNum, "")
  end
  local Slider_Pro = listItem:FindDirect("Slider_Pro_" .. index)
  local Label_Slider = Slider_Pro:FindDirect("Label_Slider_" .. index)
  local progress = math.min(curConsumeNum / item.num, 1)
  GUIUtils.SetProgress(Slider_Pro, GUIUtils.COTYPE.SLIDER, progress)
  GUIUtils.SetText(Label_Slider, curConsumeNum .. "/" .. item.num)
end
def.method().UpdateAllReddots = function(self)
  self.m_base:UpdateEquipListReddots()
  self:UpdateSelectEquipReddot()
  self:UpdateBreakOutTabReddot()
end
def.method().UpdateSelectEquipReddot = function(self)
  if self._bStageUp then
    GUIUtils.SetActive(self._uiObjs.Img_Red, BreakOutUtils.IsEquipReadyForStageUp(self._selectEquipInfo))
  else
    GUIUtils.SetActive(self._uiObjs.Img_Red, BreakOutUtils.IsEquipReadyForLevelUp(self._selectEquipInfo))
  end
end
def.method().UpdateBreakOutTabReddot = function(self)
  local bReddot = false
  if self._equipList and #self._equipList > 0 then
    for index, equipInfo in ipairs(self._equipList) do
      local checkReddotFunc = require("Main.GodWeapon.BreakOutMgr").CheckEquipBreakOutReddot
      if checkReddotFunc(equipInfo) then
        bReddot = true
        break
      end
    end
  end
  GUIUtils.SetActive(self._uiObjs.TabImg_Red, bReddot)
end
def.override().OnHide = function(self)
  self:_HandleEventListeners(false)
  self:Reset()
end
def.method().Reset = function(self)
  if self._uiObjs == nil then
    return
  end
  GUIUtils.SetActive(self._uiObjs.Group_EquipList, false)
  GUIUtils.SetActive(self._uiObjs.Group_TP, false)
  GUIUtils.SetActive(self._uiObjs.Group_NoData, false)
  self:_DestroyEffect()
  self:_ResetEffectTimer()
  self:_ResetDisableTimer()
  self.itemTipHelper = nil
  self._uiObjs = {}
  self._equipList = nil
  self._selectIndex = 0
  self._selectEquipInfo = nil
  self._selectEquipCostList = nil
  self._bStageUp = false
  self._curImproveCostYB = 0
end
def.method().ClearRequestList = function(self)
  self._uiObjs.costUIList.itemCount = 0
  self._uiObjs.costUIList:Resize()
  self._uiObjs.costUIList:Reposition()
end
def.method()._ResetDisableTimer = function(self)
  if self._disableTimerId > 0 then
    GameUtil.RemoveGlobalTimer(self._disableTimerId)
    self._disableTimerId = 0
  end
end
def.method("number", "number", "userdata")._PlayEffect = function(self, effectid, duration, parent)
  warn("[BreakOutNode:_PlayEffect] _PlayEffect!")
  if self._curEffectId > 0 then
    self:_ResetEffectTimer()
    self:_DestroyEffect()
  end
  self._curEffectId = effectid
  local effectCfg = GetEffectRes(self._curEffectId)
  if effectCfg then
    self._curEffectObj = GUIFxMan.Instance():PlayAsChild(parent, effectCfg.path, 0, 0, -1, false)
    self._uiObjs.uiParticle:set_modelGameObject(self._curEffectObj)
    self._effectTimerID = GameUtil.AddGlobalTimer(duration, true, function()
      self:_OnPlayEffectFinish()
    end)
  else
    warn("[ERROR][BreakOutNode:_PlayEffect] effectCfg nil for id:", effectid)
    self:_ResetEffectTimer()
    self:_DestroyEffect()
  end
end
def.method()._OnPlayEffectFinish = function(self)
  warn("[BreakOutNode:_OnPlayEffectFinish] _OnPlayEffectFinish!")
  self:_DestroyEffect()
  self:_ResetEffectTimer()
end
def.method()._ResetEffectTimer = function(self)
  if self._effectTimerID > 0 then
    GameUtil.RemoveGlobalTimer(self._effectTimerID)
    self._effectTimerID = 0
  end
end
def.method()._DestroyEffect = function(self)
  self._curEffectId = 0
  if self._uiObjs.uiParticle then
    self._uiObjs.uiParticle:set_modelGameObject(nil)
  end
  if self._curEffectObj then
    GUIFxMan.Instance():RemoveFx(self._curEffectObj)
    self._curEffectObj = nil
  end
end
def.override("number", "userdata", "table").OnEquipSelected = function(self, idx, clickObj, equipInfo)
  warn("[BreakOutNode:OnEquipSelected] OnEquipSelected:", idx)
  self:UpdateSelectedEquip(idx, equipInfo)
end
def.override("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_YuanbaoUse" then
    self:OnBtn_YuanbaoUse(id)
  elseif id == "Btn_Make" then
    self:OnBtn_Make(id)
  elseif id == "Btn_Add" then
    self:OnBtn_Add(id)
  elseif id == "Btn_Help" then
    self:OnBtn_Help(id)
  elseif id == "Icon_GWEquip" then
    self:OnSelectEquipClick(clickObj)
  elseif id == "Icon_Bg" then
    self:OnSelectEquipClick(clickObj)
  elseif id == "Btn_MakeOrg" then
    self:OnBtn_MakeOrgClick(clickObj)
  elseif id == "Btn_MakeHigher" then
    self:OnBtn_MakeHigherClick(clickObj)
  elseif string.find(id, "Icon_GWEquip_") then
    self:_OnCostItemClicked(clickObj)
  end
end
def.method("string").OnBtn_YuanbaoUse = function(self, id)
  self:UpdateAutoBuyToggle()
end
def.method("string").OnBtn_Make = function(self, id)
  if self._selectEquipInfo then
    if self._bStageUp then
      self:OnStageUpClicked(id)
    else
      self:OnLevelUpClicked(id)
    end
  else
    Toast(textRes.GodWeapon.BreakOut.STAGE_UP_FAIL_NO_SELECTION)
  end
end
def.method().DoClickBtn_Make = function(self)
  self:_ResetDisableTimer()
  GUIUtils.EnableButton(self._uiObjs.Btn_Make, false)
  self._disableTimerId = GameUtil.AddGlobalTimer(BreakOutNode.BREAK_OUT_INTERVAL, true, function()
    GUIUtils.EnableButton(self._uiObjs.Btn_Make, true)
  end)
end
def.method("string").OnStageUpClicked = function(self, id)
  if BreakOutUtils.CanEquipStageUp(self._selectEquipInfo, true) then
    do
      local nextStageCfg = BreakOutData.Instance():GetStageCfg(self._selectEquipInfo.godWeaponStage + 1)
      local function DoStageUp()
        self:DoClickBtn_Make()
        local bUseYB = self._uiObjs.uiToggle_UseYB.value
        local costYB
        if bUseYB then
          costYB = Int64.new(self._curImproveCostYB)
        else
          costYB = Int64.new(0)
        end
        local moneyData = CurrencyFactory.Create(nextStageCfg.requiredCurrencyType)
        local haveCurrencyNum = moneyData:GetHaveNum()
        BreakOutProtocols.SendCImproveStage(self._selectEquipInfo.bagId, self._selectEquipInfo.key, bUseYB, costYB, haveCurrencyNum)
      end
      local function CheckStageUpAutoBuy()
        if self._uiObjs.uiToggle_UseYB.value and self._curImproveCostYB and self._curImproveCostYB > 0 then
          CommonConfirmDlg.ShowConfirm(textRes.GodWeapon.BreakOut.STAGE_UP_CONFIRM_TITLE, string.format(textRes.GodWeapon.BreakOut.STAGE_UP_CONFIRM_CONTENT_USEYB, self._curImproveCostYB), function(id, tag)
            if id == 1 then
              local curYB = ItemModule.Instance():GetAllYuanBao()
              local costYB = Int64.new(self._curImproveCostYB)
              if Int64.lt(curYB, costYB) then
                _G.GotoBuyYuanbao()
              else
                DoStageUp()
              end
            end
          end, nil)
        else
          DoStageUp()
        end
      end
      if nextStageCfg.stage == 1 and self:_HaveSameGodWeapon(self._selectEquipInfo.id, self._selectEquipInfo.uuid) then
        CommonConfirmDlg.ShowConfirm(textRes.GodWeapon.BreakOut.STAGE_UP_CONFIRM_TITLE, textRes.GodWeapon.BreakOut.STAGE_UP_CONFIRM_CONTENT_DUPLICATE, function(id, tag)
          if id == 1 then
            CheckStageUpAutoBuy()
          end
        end, nil)
      else
        CheckStageUpAutoBuy()
      end
    end
  end
end
def.method("table", "=>", "boolean")._CheckRealStageUp = function(self, equipInfo)
  if equipInfo == nil then
    warn("[ERROR][BreakOutNode:_CheckRealStageUp] return false! equipInfo nil.")
    return false
  end
  local nextStageCfg = BreakOutData.Instance():GetStageCfg(equipInfo.godWeaponStage + 1)
  if nil == nextStageCfg then
    warn("[ERROR][BreakOutNode:_CheckRealStageUp] nextStageCfg nil for stage:", equipInfo.godWeaponStage + 1)
    return false
  end
  local moneyData = CurrencyFactory.Create(nextStageCfg.requiredCurrencyType)
  local haveCurrencyNum = moneyData:GetHaveNum()
  local needCurrencyNum = nextStageCfg.requiredCurrencyNum
  if haveCurrencyNum:lt(needCurrencyNum) then
    warn("[BreakOutNode:_CheckRealStageUp] return false! haveCurrencyNum:lt(needCurrencyNum).")
    return false
  end
  if self._uiObjs.uiToggle_UseYB.value then
    warn("[BreakOutNode:_CheckRealStageUp] return true! AUTO BUY.")
    return true
  else
    local costItemList = nextStageCfg.costItems
    local consumedItemMap = equipInfo.stageUpCostMap
    local bCostItemsEnough = self:_CheckCostItemsEnough(costItemList, consumedItemMap)
    warn("[BreakOutNode:_CheckRealStageUp] return bCostItemsEnough:", bCostItemsEnough)
    return bCostItemsEnough
  end
end
def.method("table", "table", "=>", "boolean")._CheckCostItemsEnough = function(self, costItemList, consumedItemMap)
  local result = true
  if costItemList and #costItemList > 0 then
    for index, item in ipairs(costItemList) do
      local haveCount = ItemModule.Instance():GetItemCountById(item.id)
      local curConsumeNum = consumedItemMap and consumedItemMap[item.id] or 0
      local lackCount = math.max(0, item.num - curConsumeNum)
      if lackCount > 0 and haveCount < lackCount then
        result = false
        break
      end
    end
  end
  return result
end
def.method("number", "userdata", "=>", "boolean")._HaveSameGodWeapon = function(self, itemid, uuid)
  local result = false
  if self._equipList and #self._equipList > 0 then
    for index, equipInfo in ipairs(self._equipList) do
      if itemid == equipInfo.id and not Int64.eq(uuid, equipInfo.uuid) then
        result = true
        break
      end
    end
  end
  return result
end
def.method("string").OnLevelUpClicked = function(self, id)
  if BreakOutUtils.CanEquipLevelUp(self._selectEquipInfo, true) then
    do
      local nextLevelCfg = BreakOutData.Instance():GetLevelCfg(self._selectEquipInfo.wearPos, self._selectEquipInfo.godWeaponLevel + 1)
      local function DoLevelUp()
        self:DoClickBtn_Make()
        local bUseYB = self._uiObjs.uiToggle_UseYB.value
        local costYB
        if bUseYB then
          costYB = Int64.new(self._curImproveCostYB)
        else
          costYB = Int64.new(0)
        end
        local moneyData = CurrencyFactory.Create(nextLevelCfg.requiredCurrencyType)
        local haveCurrencyNum = moneyData:GetHaveNum()
        BreakOutProtocols.SendCImproveLevel(self._selectEquipInfo.bagId, self._selectEquipInfo.key, bUseYB, costYB, haveCurrencyNum)
      end
      if self._uiObjs.uiToggle_UseYB.value and self._curImproveCostYB and self._curImproveCostYB > 0 then
        CommonConfirmDlg.ShowConfirm(textRes.GodWeapon.BreakOut.LEVEL_UP_CONFIRM_TITLE, string.format(textRes.GodWeapon.BreakOut.LEVEL_UP_CONFIRM_CONTENT_USEYB, self._curImproveCostYB), function(id, tag)
          if id == 1 then
            local curYB = ItemModule.Instance():GetAllYuanBao()
            local costYB = Int64.new(self._curImproveCostYB)
            if Int64.lt(curYB, costYB) then
              _G.GotoBuyYuanbao()
            else
              DoLevelUp()
            end
          end
        end, nil)
      else
        DoLevelUp()
      end
    end
  end
end
def.method("table", "=>", "boolean")._CheckRealLevelUp = function(self, equipInfo)
  if equipInfo == nil then
    warn("[ERROR][BreakOutNode:_CheckRealLevelUp] return false! equipInfo nil.")
    return false
  end
  local nextLevelCfg = BreakOutData.Instance():GetLevelCfg(equipInfo.wearPos, equipInfo.godWeaponLevel + 1)
  if nil == nextLevelCfg then
    warn("[ERROR][BreakOutNode:_CheckRealLevelUp] nextLevelCfg nil for wearPos&level:", equipInfo.wearPos, equipInfo.godWeaponLevel + 1)
    return false
  end
  local moneyData = CurrencyFactory.Create(nextLevelCfg.requiredCurrencyType)
  local haveCurrencyNum = moneyData:GetHaveNum()
  local needCurrencyNum = nextLevelCfg.requiredCurrencyNum
  if haveCurrencyNum:lt(needCurrencyNum) then
    warn("[BreakOutNode:_CheckRealLevelUp] return false! haveCurrencyNum:lt(needCurrencyNum).")
    return false
  end
  if self._uiObjs.uiToggle_UseYB.value then
    warn("[BreakOutNode:_CheckRealLevelUp] return true! AUTO BUY.")
    return true
  else
    local costItemList = nextLevelCfg.costItems
    local consumedItemMap = equipInfo.levelUpCostMap
    local bCostItemsEnough = self:_CheckCostItemsEnough(costItemList, consumedItemMap)
    warn("[BreakOutNode:_CheckRealLevelUp] return bCostItemsEnough:", bCostItemsEnough)
    return bCostItemsEnough
  end
end
def.method("string").OnBtn_Add = function(self, id)
  if self._selectEquipInfo then
    if self._bStageUp then
      local nextStageCfg = BreakOutData.Instance():GetStageCfg(self._selectEquipInfo.godWeaponStage + 1)
      if nextStageCfg then
        local costType = nextStageCfg.requiredCurrencyType
        BreakOutUtils.GoToBuyCurrency(costType, false)
      else
        warn("[BreakOutNode:OnBtn_Add] stageCfg nil for stage:", self._selectEquipInfo.godWeaponStage + 1)
      end
    else
      local nextLevelCfg = BreakOutData.Instance():GetLevelCfg(self._selectEquipInfo.wearPos, self._selectEquipInfo.godWeaponLevel + 1)
      if nextLevelCfg then
        local costType = nextLevelCfg.requiredCurrencyType
        BreakOutUtils.GoToBuyCurrency(costType, false)
      else
        warn("[BreakOutNode:OnBtn_Add] LevelCfg nil for type&level:", self._selectEquipInfo.wearPos, self._selectEquipInfo.godWeaponLevel + 1)
      end
    end
  else
    Toast(textRes.GodWeapon.BreakOut.STAGE_UP_FAIL_NO_SELECTION)
  end
end
def.method("string").OnBtn_Help = function(self, id)
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(constant.CSuperEquipmentConsts.SUPER_EQUIPMENT_HOVER_TIP_ID)
  local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
  CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = 0, y = 0})
end
def.method("userdata").OnSelectEquipClick = function(self, clickObj)
  local position = clickObj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = clickObj:GetComponent("UISprite")
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(self._selectEquipInfo.bagId, self._selectEquipInfo.key)
  ItemTipsMgr.Instance():ShowTips(item, self._selectEquipInfo.bagId, self._selectEquipInfo.key, 0, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), -1)
end
def.method("userdata")._OnCostItemClicked = function(self, clickObj)
  local id = clickObj.name
  local costItemPrefix = "Icon_GWEquip_"
  local index = tonumber(string.sub(id, string.len(costItemPrefix) + 1))
  local selectCostItem = self._selectEquipCostList[index]
  if selectCostItem then
    local itemId = selectCostItem.id
    local btnGo = clickObj
    local position = btnGo.position
    local screenPos = WorldPosToScreen(position.x, position.y)
    local widget = btnGo:GetComponent("UIWidget")
    ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x, screenPos.y, widget.width, widget.height, 0, true)
  end
end
def.method("userdata").OnBtn_MakeOrgClick = function(self, clickObj)
  local EquipMainPanel = require("Main.Equip.ui.EquipSocialPanel")
  EquipMainPanel.ShowSocialPanel(EquipMainPanel.StateConst.EquipMake)
end
def.method("userdata").OnBtn_MakeHigherClick = function(self, clickObj)
  local EquipMainPanel = require("Main.Equip.ui.EquipSocialPanel")
  EquipMainPanel.ShowSocialPanel(EquipMainPanel.StateConst.EquipStren)
end
def.method("boolean")._HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
    eventFunc(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, BreakOutNode.OnBagInfoSynchronized)
    eventFunc(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, BreakOutNode.OnCurrencyChange)
    eventFunc(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, BreakOutNode.OnCurrencyChange)
    eventFunc(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldIngotChanged, BreakOutNode.OnCurrencyChange)
    eventFunc(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_AwardChanged, BreakOutNode.OnCurrencyChange)
    eventFunc(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, BreakOutNode.OnCurrencyChange)
    eventFunc(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.GOD_WEAPON_BREAK_OUT_SUCC, BreakOutNode.OnImproveStageSucc)
    eventFunc(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.GOD_WEAPON_LEVEL_UP_SUCC, BreakOutNode.OnImproveLevelSucc)
    eventFunc(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.GOD_WEAPON_BREAK_OUT_FAIL, BreakOutNode.OnImproveStageFail)
    eventFunc(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.GOD_WEAPON_LEVEL_UP_FAIL, BreakOutNode.OnImproveLevelFail)
  end
end
def.static("table", "table").OnBagInfoSynchronized = function(params, context)
  warn("[BreakOutNode:OnBagInfoSynchronized] _UpdateUI.")
  local self = instance
  self:_UpdateUI()
  self:UpdateAllReddots()
end
def.static("table", "table").OnCurrencyChange = function(params, context)
  warn("[BreakOutNode:OnCurrencyChange] UpdateCostCurrency.")
  local self = instance
  self:UpdateCostCurrency()
  self:UpdateAllReddots()
end
def.static("table", "table").OnImproveStageSucc = function(params, context)
  warn("[BreakOutNode:OnImproveStageSucc] _UpdateUI.")
  local self = instance
  self:_UpdateUI()
  if params and params.bImproved then
    self:_PlayEffect(constant.CSuperEquipmentConsts.IMPROVE_STAGE_SFX_ID, BreakOutNode.STAGE_UP_EFFECT_DURATION, self._uiObjs.effectRoot)
  end
end
def.static("table", "table").OnImproveLevelSucc = function(params, context)
  warn("[BreakOutNode:OnImproveLevelSucc] _UpdateUI.")
  local self = instance
  self:_UpdateUI()
  if params and params.bImproved then
    self:_PlayEffect(constant.CSuperEquipmentConsts.IMPROVE_LEVEL_SFX_ID, BreakOutNode.LEVEL_UP_EFFECT_DURATION, self._uiObjs.effectRoot)
  end
end
def.static("table", "table").OnImproveStageFail = function(params, context)
  warn("[BreakOutNode:OnImproveStageFail] UpdateAutoBuyToggle.")
  local self = instance
  local SImproveSuperEquipmentStageFail = require("netio.protocol.mzm.gsp.superequipment.SImproveSuperEquipmentStageFail")
  if SImproveSuperEquipmentStageFail.NO_MATERIAL == params.reason then
  elseif SImproveSuperEquipmentStageFail.INSUFFICIENT_YUANBAO == params.reason then
    _G.GotoBuyYuanbao()
  elseif SImproveSuperEquipmentStageFail.INSUFFICIENT_CURRENCY == params.reason then
    local nextStageCfg = BreakOutData.Instance():GetStageCfg(self._selectEquipInfo.godWeaponStage + 1)
    if nextStageCfg then
      local costType = nextStageCfg.requiredCurrencyType
      BreakOutUtils.GoToBuyCurrency(costType, true)
    else
      warn("[BreakOutNode:OnImproveStageFail] stageCfg nil for stage:", self._selectEquipInfo.godWeaponStage + 1)
    end
  elseif SImproveSuperEquipmentStageFail.YUANBAO_MISMATCH == params.reason then
    BreakOutNode.Instance():UpdateAutoBuyToggle()
  elseif SImproveSuperEquipmentStageFail.CURRENCY_MISMATCH == params.reason then
    BreakOutNode.Instance():UpdateAutoBuyToggle()
  end
end
def.static("table", "table").OnImproveLevelFail = function(params, context)
  warn("[BreakOutNode:OnImproveLevelFail] OnImproveLevelFail.")
  local self = instance
  local SImproveSuperEquipmentLevelFail = require("netio.protocol.mzm.gsp.superequipment.SImproveSuperEquipmentLevelFail")
  if SImproveSuperEquipmentLevelFail.NO_MATERIAL == params.reason then
  elseif SImproveSuperEquipmentLevelFail.INSUFFICIENT_YUANBAO == params.reason then
    _G.GotoBuyYuanbao()
  elseif SImproveSuperEquipmentLevelFail.INSUFFICIENT_CURRENCY == params.reason then
    local nextLevelCfg = BreakOutData.Instance():GetLevelCfg(self._selectEquipInfo.wearPos, self._selectEquipInfo.godWeaponLevel + 1)
    if nextLevelCfg then
      local costType = nextLevelCfg.requiredCurrencyType
      BreakOutUtils.GoToBuyCurrency(costType, true)
    else
      warn("[BreakOutNode:OnImproveLevelFail] stageCfg nil for stage:", self._selectEquipInfo.godWeaponStage + 1)
    end
  elseif SImproveSuperEquipmentLevelFail.YUANBAO_MISMATCH == params.reason then
    BreakOutNode.Instance():UpdateAutoBuyToggle()
  elseif SImproveSuperEquipmentLevelFail.CURRENCY_MISMATCH == params.reason then
    BreakOutNode.Instance():UpdateAutoBuyToggle()
  end
end
return BreakOutNode.Commit()

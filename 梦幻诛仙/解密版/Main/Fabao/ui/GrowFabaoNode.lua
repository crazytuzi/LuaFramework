local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local MallModule = require("Main.Mall.MallModule")
local MallPanel = require("Main.Mall.ui.MallPanel")
local FabaoMgr = require("Main.Fabao.FabaoMgr")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local SkillTipMgr = require("Main.Skill.SkillTipMgr")
local FabaoUtils = require("Main.Fabao.FabaoUtils")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local FabaoPanelNodeBase = require("Main.Fabao.ui.FabaoPanelNodeBase")
local GrowFabaoNode = Lplus.Extend(FabaoPanelNodeBase, "GrowFabaoNode")
local def = GrowFabaoNode.define
def.field("number").m_CurLv = 0
def.field("number").m_CurExp = 0
def.field("number").m_NextExp = 0
def.field("number").m_NeedMoney = 0
def.field("number").m_ItemNum = 0
def.field("number").m_CostItemNum = 0
def.field("number").m_CostItemID = 0
def.field("number").m_Rank = 0
def.field("number").m_SkillCount = 0
def.field("number").m_HoleCount = 0
def.field("table").m_SkillInfo = nil
def.field("table").m_DynamicData = nil
def.field("userdata").m_Money = nil
local instance
def.static("=>", GrowFabaoNode).Instance = function()
  if not instance then
    instance = GrowFabaoNode()
  end
  return instance
end
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  FabaoPanelNodeBase.Init(self, base, node)
end
def.override().OnShow = function(self)
  self:Update()
  Event.RegisterEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.RANKUP_SUCCESS, GrowFabaoNode.OnRankUpSuccess)
end
def.override().OnHide = function(self)
  self:Clear()
  Event.UnregisterEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.RANKUP_SUCCESS, GrowFabaoNode.OnRankUpSuccess)
end
def.override().InitUI = function(self)
  FabaoPanelNodeBase.InitUI(self)
  self.m_UIGO = {}
  self.m_UIGO.Img_BgItem = self.m_node:FindDirect("Group_Bottom/Img_BgItem")
  self.m_UIGO.Item_Name = self.m_node:FindDirect("Group_Basic/Group_Name/Label_Name")
  self.m_UIGO.Label_LvNum = self.m_node:FindDirect("Group_Basic/Group_Lv/Label_LvNum")
  self.m_UIGO.Label_ExpNum = self.m_node:FindDirect("Group_Top/Group_Slide/Label_ExpNum")
  self.m_UIGO.Img_Bg = self.m_node:FindDirect("Group_Top/Group_Slide/Img_Bg")
  self.m_UIGO.Label_Tips = self.m_node:FindDirect("Group_Top/Label_Tips")
  self.m_UIGO.List_Star1 = self.m_node:FindDirect("Group_Jie1/Group_Star/List_Star")
  self.m_UIGO.Label_KongNum1 = self.m_node:FindDirect("Group_Jie1/Label_KongNum")
  self.m_UIGO.Group_Skill1 = self.m_node:FindDirect("Group_Jie1/Group_Skill1")
  self.m_UIGO.List_Star2 = self.m_node:FindDirect("Group_Jie2/Group_Star/List_Star")
  self.m_UIGO.Label_KongNum2 = self.m_node:FindDirect("Group_Jie2/Label_KongNum")
  self.m_UIGO.Label_Max = self.m_node:FindDirect("Group_Jie2/Label_Max")
  self.m_UIGO.Label_Tips2 = self.m_node:FindDirect("Group_Jie2/Label_Tips")
  self.m_UIGO.Group_Skill2 = self.m_node:FindDirect("Group_Jie2/Group_Skill2")
  self.m_UIGO.Group_Top = self.m_node:FindDirect("Group_Top")
  self.m_UIGO.Group_Bottom = self.m_node:FindDirect("Group_Bottom")
  self.m_UIGO.Label_Max1 = self.m_node:FindDirect("Label_Max1")
  self.m_UIGO.NeedMoney = self.m_node:FindDirect("Group_Bottom/Img_BgUse/Label_Num")
  self.m_UIGO.Money = self.m_node:FindDirect("Group_Bottom/Img_BgHave/Label_Num")
  self.m_UIGO.Item_Num = self.m_node:FindDirect("Group_Bottom/Img_BgItem/Label_Num")
  self.m_UIGO.Label_Name = self.m_node:FindDirect("Group_Bottom/Img_BgItem/Label_Name")
  self.m_UIGO.Icon_Item = self.m_node:FindDirect("Group_Bottom/Img_BgItem/Icon_Item")
  self.m_UIGO.Btn_Advance = self.m_node:FindDirect("Group_Bottom/Btn_Advance")
  self.m_UIGO.Icon_Equip01 = self.m_node:FindDirect("Group_Basic/Group_Icon/Icon_Equip01")
end
def.override().Clear = function(self)
  self.m_CurExp = 0
  self.m_NextExp = 0
  self.m_CurLv = 0
  self.m_NeedMoney = 0
  self.m_CostItemNum = 0
  self.m_CostItemID = 0
  self.m_Rank = 0
  self.m_SkillCount = 0
  self.m_HoleCount = 0
  self.m_DynamicData = nil
  self.m_SkillInfo = nil
  self.m_Money = nil
  FabaoPanelNodeBase.Clear(self)
end
def.method().Advance = function(self)
  local function toRealAdvance(extraParams)
    local isNeedYuanBao = false
    if extraParams and extraParams.isNeedYuanBao then
      isNeedYuanBao = extraParams.isNeedYuanBao
    end
    local allYuanBao = ItemModule.Instance():GetAllYuanBao()
    local needYuanBao = 0
    if isNeedYuanBao and extraParams.yuanbaoNum then
      needYuanBao = extraParams.yuanbaoNum
      if allYuanBao:lt(needYuanBao) then
        Toast(textRes.Common[15])
        return
      end
    end
    local level = self.m_DynamicData.extraMap[ItemXStoreType.FABAO_CUR_LV]
    local param = {}
    param.bagid = self.m_Item.bagType
    param.fabaoid = self.m_DynamicData.itemKey
    param.needYuanBaoNum = needYuanBao
    FabaoMgr.Advance(param)
  end
  if self.m_Money:lt(self.m_NeedMoney) then
    Toast(textRes.Fabao[16])
    FabaoMgr.OpenMoneyPanel()
  elseif self.m_ItemNum < self.m_CostItemNum then
    local function callback(select)
      if select > 0 then
        toRealAdvance({isNeedYuanBao = true, yuanbaoNum = select})
      else
        toRealAdvance({isNeedYuanBao = false, yuanbaoNum = 0})
      end
    end
    local ItemConsumeHelper = require("Main.Item.ItemConsumeHelper")
    ItemConsumeHelper.Instance():ShowItemConsume(textRes.Fabao[69], textRes.Fabao[70], self.m_CostItemID, self.m_CostItemNum, callback)
  else
    toRealAdvance({isNeedYuanBao = false, yuanbaoNum = 0})
  end
end
def.method().Enhance = function(self)
  if self.m_Rank == FabaoMgr.MAXRANK then
    Toast(textRes.Fabao[24])
    return
  elseif self.m_CurLv == FabaoMgr.MAXLEVEL then
    Toast(textRes.Fabao[43])
    return
  end
  Event.DispatchEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.BTN_ENHANCE_CLICK, {
    self.m_Item
  })
end
def.override("string").onClick = function(self, id)
  if id == "Btn_Advance" then
    self:Advance()
  elseif id == "Btn_Enhance" then
    self:Enhance()
  elseif id == "Btn_CZ_Add" then
    FabaoMgr.OpenMoneyPanel()
  elseif id == "Img_BgItem" then
    local btnGO = self.m_UIGO[id]
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(self.m_CostItemID, btnGO, -1, true)
  elseif id == "Img_Tips" then
    local tipContent = textRes.Fabao[38]
    local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
    CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = 50, y = 75})
  elseif id:find("Img_BgSkill") == 1 then
    local index = tonumber(id:sub(-1, -1))
    local skillInfo = self.m_SkillInfo[index]
    local btnGO = self.m_UIGO[id]
    if not skillInfo or not btnGO then
      return
    end
    local cfg = skillInfo.cfg
    if not cfg then
      return
    end
    SkillTipMgr.Instance():ShowTipByIdEx(cfg.id, btnGO, 0)
  end
end
def.method().OnClickNeedYuanBaoReplace = function(self)
  local toggleBtn = self.m_UIGO.useGold
  if toggleBtn and not toggleBtn.isnil then
    do
      local uiToggle = toggleBtn:GetComponent("UIToggle")
      local curValue = uiToggle.value
      if curValue then
        local needItemId = self.m_CostItemID
        local needItemNum = self.m_CostItemNum
        local haveItemNum = ItemModule.Instance():GetItemCountById(needItemId)
        if needItemNum <= haveItemNum then
          Toast(textRes.Fabao[67])
          uiToggle.value = false
          self:UpdateAdvanceBtnState()
          return
        end
        local function callback(select, tag)
          if 0 == select then
            uiToggle.value = false
          elseif 1 == select then
            uiToggle.value = true
          end
          self:UpdateAdvanceBtnState()
        end
        CommonConfirmDlg.ShowConfirm(textRes.Fabao[69], textRes.Fabao[68], callback, nil)
      else
        self:UpdateAdvanceBtnState()
      end
    end
  end
end
def.method().UpdateAdvanceBtnState = function(self)
  local toggleBtn = self.m_UIGO.useGold
  local uiToggle = toggleBtn:GetComponent("UIToggle")
  local curValue = uiToggle.value
  if curValue then
    local needItemId = self.m_CostItemID
    local needItemNum = self.m_CostItemNum
    local haveItemNum = ItemModule.Instance():GetItemCountById(needItemId)
    if needItemNum <= haveItemNum then
      self.m_UIGO.Advance_BtnLabel:SetActive(true)
      self.m_UIGO.yuanbao_Group:SetActive(false)
      uiToggle.value = false
      return
    end
    local needItemPrice = FabaoUtils.GetFabaoGrowItemPrice(needItemId)
    local needYuanBao = needItemPrice * (needItemNum - haveItemNum)
    self.m_UIGO.Advance_BtnLabel:SetActive(false)
    self.m_UIGO.yuanbao_Group:SetActive(true)
    local uiLabel = self.m_UIGO.yuanbao_Group:FindDirect("Label_Money"):GetComponent("UILabel")
    uiLabel:set_text(tostring(needYuanBao))
  else
    self.m_UIGO.Advance_BtnLabel:SetActive(true)
    self.m_UIGO.yuanbao_Group:SetActive(false)
  end
end
def.method("boolean").ResetToggleState = function(self, stateValue)
  local toggleBtn = self.m_node:FindDirect("Btn_UseGold")
  local uiToggle = toggleBtn:GetComponent("UIToggle")
  uiToggle.value = stateValue
end
def.override("=>", "boolean").IsUnlock = function(self)
  return true
end
def.override().UpdateMoney = function(self)
  self:UpdateMoneyData()
  self:UpdateBottomView()
end
def.static("table", "table").OnRankUpSuccess = function(params)
  local fxMan = require("Fx.GUIFxMan").Instance()
  local go = instance.m_node:FindDirect("Group_Jie1")
  if go and not go.isnil then
    fxMan:PlayAsChild(go, RESPATH.PANEL_FABAO_CZL_EFFECT, 0, 0, -1, false)
  end
  go = instance.m_node:FindDirect("Group_Jie2")
  if go and not go.isnil then
    fxMan:PlayAsChild(go, RESPATH.PANEL_FABAO_CZR_EFFECT, 0, 0, -1, false)
  end
  if _G.PlayerIsInFight() then
    Toast(textRes.Fabao[56])
  end
end
def.override("table").UpdateItem = function(self, item)
  FabaoPanelNodeBase.UpdateItem(self, item)
  self.m_CostItemID = self.m_Item.data.templateData.data.daemonId
end
def.method().UpdateData = function(self)
  if not self.m_Item then
    return
  end
  self.m_DynamicData = ItemModule.Instance():GetItemByBagIdAndItemKey(self.m_Item.bagType, self.m_Item.data.dynamicData.itemKey)
  self:UpdateFabaoExpAndItemData()
  self:UpdateMoneyData()
end
def.method().UpdateMoneyData = function(self)
  self.m_Money = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
end
def.method().UpdateFabaoExpAndItemData = function(self)
  if not self.m_Item then
    return
  end
  local rankId = self.m_Item.data.templateData.data.rankId
  local rank = self.m_DynamicData.extraMap[ItemXStoreType.FABAO_CUR_RANK]
  local rankCfg = FabaoMgr.GetFabaoRankCfg(rankId, rank)
  rank = rank + 1
  local levelId = self.m_Item.data.templateData.data.levelId
  local level = self.m_DynamicData.extraMap[ItemXStoreType.FABAO_CUR_LV]
  local levelCfg = FabaoMgr.GetFabaoLevelCfg(levelId, level)
  self.m_NextExp = levelCfg.needExp
  self.m_NeedMoney = rankCfg.needSilver
  self.m_CostItemNum = rankCfg.needItemCount
  self.m_ItemNum = FabaoMgr.GetItemFromBag(self.m_CostItemID)
  self.m_Rank = rank
  self.m_HoleCount = self.m_DynamicData.extraMap[ItemXStoreType.FABAO_HOLE_COUNT]
  self.m_SkillCount = self.m_DynamicData.extraMap[ItemXStoreType.FABAO_SKILL_COUNT]
  self.m_CurLv = level
  self.m_CurExp = self.m_DynamicData.extraMap[ItemXStoreType.FABAO_CUR_EXP]
  self.m_SkillInfo = {}
  local skillIDEnum = {
    ItemXStoreType.FABAO_SKILL_ID_1,
    ItemXStoreType.FABAO_SKILL_ID_2,
    ItemXStoreType.FABAO_SKILL_ID_3
  }
  local skillValueEnum = {
    ItemXStoreType.FABAO_SKILL_VALUE_1,
    ItemXStoreType.FABAO_SKILL_VALUE_2,
    ItemXStoreType.FABAO_SKILL_VALUE_3
  }
  for i = 1, self.m_SkillCount do
    local id = self.m_DynamicData.extraMap[skillIDEnum[i]]
    local value = self.m_DynamicData.extraMap[skillValueEnum[i]]
    self.m_SkillInfo[i] = {}
    self.m_SkillInfo[i].value = value
    self.m_SkillInfo[i].cfg = FabaoMgr.GetFabaoEffectSkillCfg(id, value)
  end
end
def.method().UpdateTopView = function(self)
  if not self.m_Item then
    return
  end
  local topGO = self.m_UIGO.Group_Top
  local nameGO = self.m_UIGO.Item_Name
  local lvGO = self.m_UIGO.Label_LvNum
  local labelGO = self.m_UIGO.Label_ExpNum
  local sliderGO = self.m_UIGO.Img_Bg
  local tipsGO = self.m_UIGO.Label_Tips
  local iconGO = self.m_UIGO.Icon_Equip01
  local rankLevels = FabaoMgr.GetFabaoAllRankLevel()
  local curExp = self.m_Rank == FabaoMgr.MAXRANK and self.m_NextExp or self.m_CurExp
  local tipDesc = self.m_Rank == FabaoMgr.MAXRANK and textRes.Fabao[24] or textRes.Fabao[18]:format(rankLevels[1], rankLevels[2], rankLevels[3], rankLevels[4])
  local progressDes = ("%d/%d"):format(curExp, self.m_NextExp)
  if self.m_CurLv == FabaoMgr.MAXLEVEL then
    progressDes = textRes.Fabao[60]
    curExp = self.m_NextExp
  end
  GUIUtils.SetActive(topGO, not FabaoUtils.CanFabaoAdvance(self.m_DynamicData) and self.m_Rank ~= FabaoMgr.MAXRANK)
  GUIUtils.SetText(nameGO, self.m_Item.data.templateData.baseData.name)
  GUIUtils.SetText(lvGO, self.m_CurLv)
  GUIUtils.SetText(labelGO, progressDes)
  GUIUtils.SetProgress(sliderGO, GUIUtils.COTYPE.SLIDER, curExp / self.m_NextExp)
  GUIUtils.SetText(tipsGO, tipDesc)
  GUIUtils.SetTexture(iconGO, self.m_Item.data.templateData.baseData.icon)
end
def.method().UpdateMiddleView = function(self)
  if not self.m_Item then
    return
  end
  local rank = self.m_Rank
  local holeCount = self.m_HoleCount
  local skillCount = self.m_SkillCount
  local title = FabaoMgr.GetFabaoSkillDesc()
  local groupStarGO = self.m_UIGO.List_Star1
  local holeNumGO = self.m_UIGO.Label_KongNum1
  local groupSkillGO = self.m_UIGO.Group_Skill1
  GUIUtils.InitUIList(groupStarGO, rank)
  GUIUtils.Reposition(groupStarGO, GUIUtils.COTYPE.LIST, 0)
  GUIUtils.SetText(holeNumGO, tostring(holeCount))
  local listItems = GUIUtils.InitUIList(groupSkillGO, skillCount)
  self.m_base.m_msgHandler:Touch(groupSkillGO)
  for i = 1, skillCount do
    local itemGO = listItems[i]
    local labelGO = itemGO:FindDirect(("Label_Skill_%d"):format(i))
    self.m_UIGO[itemGO.name] = itemGO
    local color = FabaoUtils.GetSkillDescColor(self.m_SkillInfo[i].value)
    GUIUtils.SetTextAndColor(labelGO, self.m_SkillInfo[i].cfg.name, color)
  end
  GUIUtils.Reposition(groupSkillGO, GUIUtils.COTYPE.LIST, 0)
  local groupStarGO = self.m_UIGO.List_Star2
  local holeNumGO = self.m_UIGO.Label_KongNum2
  local labelMaxGO = self.m_UIGO.Label_Max
  local labelTipsGO = self.m_UIGO.Label_Tips2
  local groupSkillGO = self.m_UIGO.Group_Skill2
  GUIUtils.SetActive(groupStarGO, rank < FabaoMgr.MAXRANK)
  GUIUtils.InitUIList(groupStarGO, rank < FabaoMgr.MAXRANK and rank + 1 or FabaoMgr.MAXRANK)
  GUIUtils.Reposition(groupStarGO, GUIUtils.COTYPE.LIST, 0)
  GUIUtils.SetActive(labelMaxGO, rank == FabaoMgr.MAXRANK)
  GUIUtils.SetActive(labelTipsGO, rank > FabaoMgr.MINRANK and rank < FabaoMgr.MAXRANK)
  GUIUtils.SetText(holeNumGO, tostring(rank < FabaoMgr.MAXRANK and holeCount + 1 or holeCount))
  GUIUtils.SetText(labelTipsGO, textRes.Fabao[23])
  local itemNum = rank == FabaoMgr.MINRANK and skillCount + 1 or skillCount
  local listItems = GUIUtils.InitUIList(groupSkillGO, itemNum)
  self.m_base.m_msgHandler:Touch(groupSkillGO)
  for i = 1, itemNum do
    local itemGO = listItems[i]
    local labelGO = itemGO:FindDirect(("Label_Skill_%d"):format(i))
    local desc = ""
    local color = Color.white
    if i < itemNum then
      desc = self.m_SkillInfo[i].cfg.name
      self.m_UIGO[itemGO.name] = itemGO
      color = FabaoUtils.GetSkillDescColor(self.m_SkillInfo[i].value)
    elseif rank == FabaoMgr.MINRANK then
      desc = textRes.Fabao[22]
      color = Color.Color(0.30980392156862746, 0.18823529411764706, 0.09411764705882353)
    else
      desc = self.m_SkillInfo[i].cfg.name
      color = FabaoUtils.GetSkillDescColor(self.m_SkillInfo[i].value)
      self.m_UIGO[itemGO.name] = itemGO
    end
    GUIUtils.SetTextAndColor(labelGO, desc, color)
  end
  GUIUtils.Reposition(groupSkillGO, GUIUtils.COTYPE.LIST, 0)
end
def.method().UpdateBottomView = function(self)
  if not self.m_Item then
    return
  end
  local groupBottomGO = self.m_UIGO.Group_Bottom
  local labelGO = self.m_UIGO.Label_Max1
  local needMoneyGO = self.m_UIGO.NeedMoney
  local moneyGO = self.m_UIGO.Money
  local numGO = self.m_UIGO.Item_Num
  local nameGO = self.m_UIGO.Label_Name
  local iconGO = self.m_UIGO.Icon_Item
  local btnGO = self.m_UIGO.Btn_Advance
  local itemGO = self.m_UIGO.Img_BgItem
  local color = Color.white
  if self.m_Money:lt(self.m_NeedMoney) then
    color = Color.red
  end
  local itemBase = ItemUtils.GetItemBase(self.m_CostItemID)
  GUIUtils.SetActive(labelGO, self.m_Rank == FabaoMgr.MAXRANK)
  GUIUtils.SetActive(groupBottomGO, FabaoUtils.CanFabaoAdvance(self.m_DynamicData) and self.m_Rank ~= FabaoMgr.MAXRANK)
  GUIUtils.SetTextAndColor(needMoneyGO, tostring(self.m_NeedMoney), color)
  GUIUtils.SetText(moneyGO, Int64.tostring(self.m_Money))
  GUIUtils.SetTextAndColor(numGO, ("%d/%d"):format(self.m_ItemNum, self.m_CostItemNum), self.m_ItemNum >= self.m_CostItemNum and Color.green or Color.red)
  GUIUtils.SetText(nameGO, itemBase.name)
  GUIUtils.SetTexture(iconGO, itemBase.icon)
end
def.method().Update = function(self)
  if not self.m_panel or not self.m_panel.activeSelf then
    return
  end
  self:UpdateData()
  self:UpdateTopView()
  self:UpdateMiddleView()
  self:UpdateBottomView()
end
def.method().OnClickLeftFaBaoItem = function(self)
end
return GrowFabaoNode.Commit()

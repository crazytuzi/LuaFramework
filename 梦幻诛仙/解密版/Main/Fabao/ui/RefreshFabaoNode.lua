local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ECLuaString = require("Utility.ECFilter")
local SkillTipMgr = require("Main.Skill.SkillTipMgr")
local TipsHelper = require("Main.Common.TipsHelper")
local ItemModule = require("Main.Item.ItemModule")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemUtils = require("Main.Item.ItemUtils")
local MallModule = require("Main.Mall.MallModule")
local MallPanel = require("Main.Mall.ui.MallPanel")
local FabaoMgr = require("Main.Fabao.FabaoMgr")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local FabaoPanelNodeBase = require("Main.Fabao.ui.FabaoPanelNodeBase")
local EquipModule = require("Main.Equip.EquipModule")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local RefreshFabaoNode = Lplus.Extend(FabaoPanelNodeBase, "RefreshFabaoNode")
local def = RefreshFabaoNode.define
def.field("number").m_CostItemID = 0
def.field("number").m_CostItemNum = 0
def.field("number").m_ItemNum = 0
def.field("number").m_NeedMoney = 0
def.field("number").m_SkillCount = 0
def.field("table").m_AttriDesc = nil
def.field("table").m_SkillInfo = nil
def.field("table").m_DynamicData = nil
def.field("userdata").m_Money = nil
local instance
def.static("=>", RefreshFabaoNode).Instance = function()
  if not instance then
    instance = RefreshFabaoNode()
  end
  return instance
end
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  FabaoPanelNodeBase.Init(self, base, node)
end
def.override().OnShow = function(self)
  self:Update()
  Event.RegisterEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.WASH_SUCCESS, RefreshFabaoNode.OnRefreshSuccess)
end
def.override().OnHide = function(self)
  self:ResetToggleState(false)
  self:Clear()
  Event.UnregisterEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.WASH_SUCCESS, RefreshFabaoNode.OnRefreshSuccess)
end
def.override().InitUI = function(self)
  FabaoPanelNodeBase.InitUI(self)
  self.m_UIGO = {}
  self.m_UIGO.Img_BgItem = self.m_node:FindDirect("Group_Bottom/Img_BgItem")
  self.m_UIGO.Btn_DZ_Make = self.m_node:FindDirect("Group_Make/Btn_DZ_Make")
  self.m_UIGO.Icon_Equip = self.m_node:FindDirect("Group_Left/Img_BgEquip/Icon_Equip")
  self.m_UIGO.Label_LvNum = self.m_node:FindDirect("Group_Left/Group_Lv/Label_LvNum")
  self.m_UIGO.List_Star = self.m_node:FindDirect("Group_Left/Group_Star/List_Star")
  self.m_UIGO.Label_Tips = self.m_node:FindDirect("Group_Left/Img_BgTips/Label_Tips")
  self.m_UIGO.Group_Skill = self.m_node:FindDirect("Group_Right/Group_Skill")
  self.m_UIGO.Icon_Item = self.m_node:FindDirect("Group_Bottom/Img_BgItem/Icon_Item")
  self.m_UIGO.Label_Num = self.m_node:FindDirect("Group_Bottom/Img_BgItem/Label_Num")
  self.m_UIGO.Label_Name = self.m_node:FindDirect("Group_Bottom/Img_BgItem/Label_Name")
  self.m_UIGO.NeedSilverGO = self.m_node:FindDirect("Group_Bottom/Img_BgUse/Label_Num")
  self.m_UIGO.SilverGO = self.m_node:FindDirect("Group_Bottom/Img_BgHave/Label_Num")
  self.m_UIGO.Btn_XL = self.m_node:FindDirect("Group_Bottom/Btn_XL")
  self.m_UIGO.XLBtn_Label = self.m_node:FindDirect("Group_Bottom/Btn_XL/Label_XL")
  self.m_UIGO.yuanbao_Group = self.m_node:FindDirect("Group_Bottom/Btn_XL/Group_Yuanbao")
end
def.method().Detaile = function(self)
  Event.DispatchEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.BTN_PREVIEW_CLICK, {
    id = self.m_Item.data.dynamicData.id
  })
end
def.method().RefreshItem = function(self)
  local function realtoRefreshFabao(extraParams)
    local function checkYuanBaoEnough()
      local haveItemNum = ItemModule.Instance():GetItemCountById(self.m_CostItemID)
      local allYuanBao = ItemModule.Instance():GetAllYuanBao()
      local needYuanbao = require("Main.Fabao.FabaoUtils").GetFabaoRefreshItemPrice(self.m_CostItemID) * (self.m_CostItemNum - haveItemNum)
      if allYuanBao:lt(needYuanbao) then
        return false
      else
        return true
      end
    end
    local isNeedYuanBao = false
    if extraParams and extraParams.isNeedYuanBao then
      isNeedYuanBao = extraParams.isNeedYuanBao
    end
    CommonConfirmDlg.ShowConfirmCoundDown(textRes.Fabao[62], textRes.Fabao[63], "", "", 0, 0, function(selection, tag)
      if selection == 1 then
        local btnGO = self.m_UIGO.Btn_XL
        local item = self.m_Item
        if item then
          local needYuanBaoNum = 0
          if isNeedYuanBao then
            local haveItemNum = ItemModule.Instance():GetItemCountById(self.m_CostItemID)
            needYuanBaoNum = require("Main.Fabao.FabaoUtils").GetFabaoRefreshItemPrice(self.m_CostItemID) * (self.m_CostItemNum - haveItemNum)
            if not checkYuanBaoEnough() then
              Toast(textRes.Common[15])
              return
            end
          end
          FabaoMgr.RefreshItem(item.bagType, item.data.dynamicData.itemKey, needYuanBaoNum)
          GUIUtils.CoolDownButton(btnGO, 1)
        end
      end
    end, nil)
  end
  if self.m_Money:lt(self.m_NeedMoney) then
    FabaoMgr.OpenMoneyPanel()
  elseif self.m_ItemNum < self.m_CostItemNum then
    local toggelBtn = self.m_node:FindDirect("Group_Bottom/Img_BgItem/Btn_UseGold")
    local uiToggle = toggelBtn:GetComponent("UIToggle")
    if not uiToggle.value then
      uiToggle.value = true
      self:OnClickYuanbaoReplace()
    else
      realtoRefreshFabao({isNeedYuanBao = true})
    end
  else
    realtoRefreshFabao({isNeedYuanBao = false})
  end
end
def.method("boolean").ResetToggleState = function(self, stateValue)
  local toggelBtn = self.m_node:FindDirect("Group_Bottom/Img_BgItem/Btn_UseGold")
  local uiToggle = toggelBtn:GetComponent("UIToggle")
  uiToggle.value = stateValue
end
def.method().OnClickYuanbaoReplace = function(self)
  local toggelBtn = self.m_node:FindDirect("Group_Bottom/Img_BgItem/Btn_UseGold")
  local uiToggle = toggelBtn:GetComponent("UIToggle")
  local curValue = uiToggle.value
  if curValue then
    local haveItemNum = ItemModule.Instance():GetItemCountById(self.m_CostItemID)
    if haveItemNum >= self.m_CostItemNum then
      uiToggle.value = false
      Toast(textRes.Fabao[67])
      self:UpdateRefreshBtnState()
      return
    end
    local function callback(select, tag)
      if 0 == select then
        uiToggle.value = false
      elseif 1 == select then
        uiToggle.value = true
      end
      self:UpdateRefreshBtnState()
    end
    local needYuanbaoNum = require("Main.Fabao.FabaoUtils").GetFabaoRefreshItemPrice(self.m_CostItemID) * (self.m_CostItemNum - haveItemNum)
    CommonConfirmDlg.ShowConfirm(textRes.Fabao[62], textRes.Fabao[66], callback, nil)
  else
    self:UpdateRefreshBtnState()
  end
end
def.method().UpdateRefreshBtnState = function(self)
  local toggelBtn = self.m_node:FindDirect("Group_Bottom/Img_BgItem/Btn_UseGold")
  local uiToggle = toggelBtn:GetComponent("UIToggle")
  local curValue = uiToggle.value
  if curValue then
    local needItemId = self.m_CostItemID
    local needItemNum = self.m_CostItemNum
    local haveItemNum = ItemModule.Instance():GetItemCountById(needItemId)
    if needItemNum <= haveItemNum then
      uiToggle.value = false
      self.m_UIGO.XLBtn_Label:SetActive(true)
      self.m_UIGO.yuanbao_Group:SetActive(false)
      return
    end
    self.m_UIGO.XLBtn_Label:SetActive(false)
    self.m_UIGO.yuanbao_Group:SetActive(true)
    warn("price is : ", require("Main.Fabao.FabaoUtils").GetFabaoRefreshItemPrice(self.m_CostItemID))
    local needYuanBao = require("Main.Fabao.FabaoUtils").GetFabaoRefreshItemPrice(self.m_CostItemID) * (needItemNum - haveItemNum)
    local uiLabel = self.m_UIGO.yuanbao_Group:FindDirect("Label_Money"):GetComponent("UILabel")
    uiLabel:set_text(tostring(needYuanBao))
  else
    self.m_UIGO.XLBtn_Label:SetActive(true)
    self.m_UIGO.yuanbao_Group:SetActive(false)
  end
end
def.override("string").onClick = function(self, id)
  if id == "Btn_Xiang" then
    self:Detaile()
  elseif id == "Btn_XL" then
    self:RefreshItem()
  elseif id == "Btn_UseGold" then
    self:OnClickYuanbaoReplace()
  elseif id == "Btn_XL_Add" then
    FabaoMgr.OpenMoneyPanel()
  elseif id == "Img_BgItem" then
    local btnGO = self.m_UIGO[id]
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(self.m_CostItemID, btnGO, -1, true)
  elseif id == "Btn_Tip" then
    local tipContent = textRes.Fabao[65]
    local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
    CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = 50, y = 75})
  elseif id:find("Img_BgSkill1_") == 1 then
    local _, lastIndex = id:find("Img_BgSkill1_")
    local index = tonumber(id:sub(lastIndex + 1, id:len()))
    local skillInfo = self.m_SkillInfo[index]
    local btnGO = self.m_UIGO[id]
    if not skillInfo or not skillInfo.cfg or not btnGO then
      return
    end
    SkillTipMgr.Instance():ShowTipByIdEx(skillInfo.cfg.id, btnGO, 0)
  end
end
def.override().Clear = function(self)
  self.m_CostItemID = 0
  self.m_CostItemNum = 0
  self.m_ItemNum = 0
  self.m_NeedMoney = 0
  self.m_Money = nil
  self.m_AttriDesc = nil
  self.m_SkillInfo = nil
  self.m_DynamicData = nil
  FabaoPanelNodeBase.Clear(self)
end
def.override("=>", "boolean").IsUnlock = function(self)
  return true
end
def.override().UpdateMoney = function(self)
  self:UpdateMoneyData()
  self:UpdateBottomView()
end
def.static("table", "table").OnRefreshSuccess = function(params)
  Toast(textRes.Fabao[17])
  local go = instance.m_UIGO.Group_Skill
  if not go or go.isnil then
    return
  end
  for i = 0, go.childCount - 1 do
    local child = go:GetChild(i)
    if child.activeSelf then
      require("Fx.GUIFxMan").Instance():PlayAsChild(child, RESPATH.PANEL_FABAO_XL_EFFECT, 0, 0, -1, false)
    end
  end
  if _G.PlayerIsInFight() then
    Toast(textRes.Fabao[56])
  end
end
def.override("table").UpdateItem = function(self, item)
  FabaoPanelNodeBase.UpdateItem(self, item)
  self.m_CostItemID = FabaoMgr.GetFabaoConstant("FABAO_WASH_ITEM")
end
def.method().UpdateData = function(self)
  if not self.m_Item then
    return
  end
  self.m_DynamicData = ItemModule.Instance():GetItemByBagIdAndItemKey(self.m_Item.bagType, self.m_Item.data.dynamicData.itemKey)
  self:UpdataItemData()
  self:UpdateAttributeAndSkillData()
  self:UpdateMoneyData()
end
def.method().UpdateMoneyData = function(self)
  self.m_Money = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
end
def.method().UpdataItemData = function(self)
  if not self.m_Item then
    return
  end
  local levelId = self.m_Item.data.templateData.data.levelId
  local level = self.m_DynamicData.extraMap[ItemXStoreType.FABAO_CUR_LV]
  local levelCfg = FabaoMgr.GetFabaoLevelCfg(levelId, level)
  local rankId = self.m_Item.data.templateData.data.rankId
  local rank = self.m_DynamicData.extraMap[ItemXStoreType.FABAO_CUR_RANK]
  local rankCfg = FabaoMgr.GetFabaoRankCfg(rankId, rank)
  self.m_ItemNum = FabaoMgr.GetItemFromBag(self.m_CostItemID)
  self.m_CostItemNum = rankCfg.washNeedItemCount
  self.m_NeedMoney = levelCfg.washNeedSilver
end
def.method().UpdateAttributeAndSkillData = function(self)
  if not self.m_Item then
    return
  end
  local dynamicData = self.m_DynamicData
  local level = dynamicData.extraMap[ItemXStoreType.FABAO_CUR_LV]
  self.m_AttriDesc = {}
  self.m_SkillInfo = {}
  self.m_SkillCount = dynamicData.extraMap[ItemXStoreType.FABAO_SKILL_COUNT]
  local atrriTypeEnum = {
    ItemXStoreType.FABAO_EQUIP_ATTRI_A_TYPE,
    ItemXStoreType.FABAO_EQUIP_ATTRI_B_TYPE
  }
  for i = 1, 2 do
    local attriID = dynamicData.extraMap[atrriTypeEnum[i]]
    local attriCfg = FabaoMgr.GetFabaoAttributeCfg(attriID)
    local attriName = EquipModule.GetAttriName(attriCfg.attrId)
    local attriInitValue = attriCfg.initValue
    local attriAddValue = attriCfg.addValue
    self.m_AttriDesc[i] = {
      name = attriName,
      value1 = attriInitValue,
      value2 = attriAddValue * level
    }
  end
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
    local id = dynamicData.extraMap[skillIDEnum[i]]
    local value = dynamicData.extraMap[skillValueEnum[i]]
    self.m_SkillInfo[i] = {}
    self.m_SkillInfo[i].value = value + 1
    self.m_SkillInfo[i].cfg = FabaoMgr.GetFabaoEffectSkillCfg(id, value)
  end
end
def.method().UpdateUpLeftView = function(self)
  if not self.m_Item then
    return
  end
  local iconGO = self.m_UIGO.Icon_Equip
  local levelGO = self.m_UIGO.Label_LvNum
  local groupStarGO = self.m_UIGO.List_Star
  local labelTipsGO = self.m_UIGO.Label_Tips
  local icon = self.m_Item.data.templateData.baseData.icon
  local level = self.m_DynamicData.extraMap[ItemXStoreType.FABAO_CUR_LV]
  local starLevel = self.m_DynamicData.extraMap[ItemXStoreType.FABAO_CUR_RANK] + 1
  local tipId = FabaoMgr.GetFabaoConstant("FABAO_DESC_TIPS")
  local tipContent = TipsHelper.GetHoverTip(tipId)
  GUIUtils.SetTexture(iconGO, icon)
  GUIUtils.SetStarView(groupStarGO, starLevel)
  GUIUtils.SetText(levelGO, level)
  GUIUtils.SetText(labelTipsGO, tipContent)
  GUIUtils.Reposition(groupStarGO, GUIUtils.COTYPE.LIST, 0)
end
def.method().UpdateUpRightView = function(self)
  if not self.m_Item then
    return
  end
  for i = 1, 2 do
    local labelGO = self.m_node:FindDirect(("Group_Right/Group_Attribute/Group_Attribute%d/Label_Name"):format(i))
    local labelGO1 = self.m_node:FindDirect(("Group_Right/Group_Attribute/Group_Attribute%d/Label_Num1"):format(i))
    local labelGO2 = self.m_node:FindDirect(("Group_Right/Group_Attribute/Group_Attribute%d/Label_Num2"):format(i))
    local attrInfo = self.m_AttriDesc[i]
    GUIUtils.SetText(labelGO, attrInfo.name)
    GUIUtils.SetText(labelGO1, ("+ %d"):format(attrInfo.value1))
    GUIUtils.SetActive(labelGO2, attrInfo.value2 > 0)
    GUIUtils.SetTextAndColor(labelGO2, ("(+ %d)"):format(attrInfo.value2), Color.Color(0.00392156862745098, 0.7019607843137254, 0.3568627450980392))
  end
  local groupSkillGO = self.m_UIGO.Group_Skill
  local listItems = GUIUtils.InitUIList(groupSkillGO, self.m_SkillCount)
  self.m_base.m_msgHandler:Touch(groupSkillGO)
  for i = 1, self.m_SkillCount do
    local itemGO = listItems[i]
    local labelGO = itemGO:FindDirect(("Label_SkillLv_%d"):format(i))
    local iconGO = itemGO:FindDirect(("Icon_Skill_%d"):format(i))
    local name = self.m_SkillInfo[i].cfg.name
    local len = ECLuaString.Len(name)
    GUIUtils.SetText(labelGO, ECLuaString.SubStr(name, 3, len))
    GUIUtils.SetTexture(iconGO, self.m_SkillInfo[i].cfg.icon)
    self.m_UIGO[("Img_BgSkill1_%d"):format(i)] = itemGO
  end
  GUIUtils.Reposition(groupSkillGO, GUIUtils.COTYPE.LIST, 0)
end
def.method().UpdateBottomView = function(self)
  if not self.m_Item then
    return
  end
  local iconGO = self.m_UIGO.Icon_Item
  local labelNumGO = self.m_UIGO.Label_Num
  local labelNameGO = self.m_UIGO.Label_Name
  local itemBase = ItemUtils.GetItemBase(self.m_CostItemID)
  GUIUtils.SetTexture(iconGO, itemBase.icon)
  GUIUtils.SetTextAndColor(labelNumGO, ("%d/%d"):format(self.m_ItemNum, self.m_CostItemNum), self.m_ItemNum >= self.m_CostItemNum and Color.green or Color.red)
  GUIUtils.SetText(labelNameGO, itemBase.name)
  labelNumGO = self.m_UIGO.NeedSilverGO
  local color = Color.white
  if self.m_Money:lt(self.m_NeedMoney) then
    color = Color.red
  end
  GUIUtils.SetTextAndColor(labelNumGO, tostring(self.m_NeedMoney), color)
  labelNumGO = self.m_UIGO.SilverGO
  GUIUtils.SetText(labelNumGO, Int64.tostring(self.m_Money))
end
def.method().Update = function(self)
  self:UpdateData()
  self:UpdateUpLeftView()
  self:UpdateUpRightView()
  self:UpdateBottomView()
  self:UpdateRefreshBtnState()
end
def.method().OnClickLeftFaBaoItem = function(self)
  local toggelBtn = self.m_node:FindDirect("Group_Bottom/Img_BgItem/Btn_UseGold")
  local uiToggle = toggelBtn:GetComponent("UIToggle")
  local curValue = uiToggle.value
  if curValue then
    uiToggle.value = false
  end
  self:UpdateRefreshBtnState()
end
return RefreshFabaoNode.Commit()

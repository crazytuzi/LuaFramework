local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local EquipEffectResetPanel = Lplus.Extend(ECPanelBase, "EquipEffectResetPanel")
local Vector3 = require("Types.Vector3").Vector3
local GUIUtils = require("GUI.GUIUtils")
local EquipStrenTransData = require("Main.Equip.EquipStrenTransData")
local ItemModule = require("Main.Item.ItemModule")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local SkillUtility = require("Main.Skill.SkillUtility")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local EquipUtils = require("Main.Equip.EquipUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemData = require("Main.Item.ItemData")
local def = EquipEffectResetPanel.define
def.field("table").selectedEquip = nil
def.field("number").selectedIdx = 1
def.field("number").useYuanbaoNum = 0
def.field("number").bagId = 0
def.field("number").bagKey = 0
def.field("string").replaceTips = ""
local instance
def.static("=>", EquipEffectResetPanel).Instance = function()
  if instance == nil then
    instance = EquipEffectResetPanel()
    instance:Init()
    instance.m_TrigGC = true
    instance.m_TryIncLoadSpeed = true
  end
  return instance
end
def.method().Init = function(self)
end
def.method("number", "number").ShowPanelToEquip = function(self, bagId, key)
  self.bagId = bagId
  self.bagKey = key
  self:ShowPanel()
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  if IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_EQUIP_SKILL_REFRESH) then
    self:SetModal(true)
    self:CreatePanel(RESPATH.PREFAB_EQUIP_EFFECT_REMAKE, 1)
  else
    self.bagId = 0
    self.bagKey = 0
    Toast(textRes.Equip[212])
  end
end
def.override().OnCreate = function(self)
  local Group_Equip = self.m_panel:FindDirect("Img_BgEquip/Img_CZ_BgCompare/Img_CZ_Bg01/Group_Equip")
  Group_Equip:FindDirect("Btn_CZ_Cost"):SetActive(false)
  local Btn_CZ_Make = self.m_panel:FindDirect("Img_BgEquip/Btn_CZ_Make")
  local Label_DZ_Make = Btn_CZ_Make:FindDirect("Label_DZ_Make")
  local Group_MoneyMake = Btn_CZ_Make:FindDirect("Group_MoneyMake")
  Label_DZ_Make:SetActive(true)
  Group_MoneyMake:SetActive(false)
end
def.override().OnDestroy = function(self)
end
def.override("boolean").OnShow = function(self, show)
  if show then
    local equipList = EquipStrenTransData.Instance():InitEffectEquips()
    if self.bagId ~= 0 and key ~= 0 then
      for i, v in ipairs(equipList) do
        if v.bagId == self.bagId and v.key == self.bagKey then
          self.selectedIdx = i
        end
      end
    end
    self:setEquipList()
    self:setSelectedEquip(self.selectedIdx)
  else
    self.bagId = 0
    self.bagKey = 0
    self.replaceTips = ""
  end
end
def.method().Hide = function(self)
  self.useYuanbaoNum = 0
  self.selectedIdx = 1
  self:DestroyPanel()
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  warn("--------onClickObj:", id)
  local strs = string.split(id, "_")
  if id == "Btn_Close" then
    self:Hide()
  elseif id == "Btn_CZ_Add" then
    if self.selectedEquip == nil then
      return
    end
    local refreshCfg = EquipUtils.GetEquipSkillRefreshCfg(self.selectedEquip.useLevel)
    _G.GoToBuyCurrency(refreshCfg.moneyType, false)
  elseif id == "Btn_CZ_Cost" then
  elseif id == "Icon_BgEquip" then
    if nil == self.selectedEquip then
      return
    end
    local position = clickobj:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local sprite = clickobj:GetComponent("UISprite")
    local item = ItemModule.Instance():GetItemByBagIdAndItemKey(self.selectedEquip.bagId, self.selectedEquip.key)
    ItemTipsMgr.Instance():ShowTips(item, 0, 0, 0, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), -1)
  elseif id == "Img_BgEquipMakeItem" then
    local _, _, itemId = self:getCostItemNum()
    if itemId > 0 then
      self:ShowTips(itemId, clickobj)
    end
  elseif id == "Btn_CZ_Make" then
    if self.selectedEquip == nil then
      return
    end
    if IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_EQUIP_SKILL_REFRESH) then
      self:clickResetEffect(clickobj)
    else
      Toast(textRes.Equip[212])
    end
  elseif id == "Btn_CZ_Replace" then
    if self.selectedEquip == nil then
      return
    end
    if IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_EQUIP_SKILL_REFRESH) then
      local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
      local equipItem = ItemModule.Instance():GetItemByBagIdAndItemKey(self.selectedEquip.bagId, self.selectedEquip.key)
      local equipSkillId = equipItem.extraMap[ItemXStoreType.EQUIP_SKILL]
      local tempSkillId = equipItem.extraMap[ItemXStoreType.EQUIP_SKILL_TEMP]
      if equipSkillId and tempSkillId then
        do
          local skillCfg1 = SkillUtility.GetSkillCfg(equipSkillId)
          local skillCfg2 = SkillUtility.GetSkillCfg(tempSkillId)
          local function callback(tag)
            if tag == 1 then
              self.replaceTips = string.format(textRes.Equip[215], skillCfg1.name, skillCfg2.name)
              local p = require("netio.protocol.mzm.gsp.item.CReplaceEquipSkillReq").new(self.selectedEquip.bagId, self.selectedEquip.key, self.selectedEquip.id)
              gmodule.network.sendProtocol(p)
            end
          end
          local content = string.format(textRes.Equip[213], skillCfg2.name, skillCfg1.name)
          CommonConfirmDlg.ShowConfirm("", content, callback, nil)
        end
      end
    else
      Toast(textRes.Equip[212])
    end
  elseif strs[1] == "Img" and strs[2] == "BgEquip01" then
    local idx = tonumber(strs[3])
    if idx then
      self.selectedIdx = idx
      self:setSelectedEquip(idx)
    end
  end
end
def.method("userdata").clickResetEffect = function(self, obj)
  if self.selectedEquip == nil then
    return
  end
  local ownNum, needNum, itemId = self:getCostItemNum()
  if needNum <= ownNum and itemId > 0 then
    local refreshCfg = EquipUtils.GetEquipSkillRefreshCfg(self.selectedEquip.useLevel)
    local ownSilver = self:GetCostMoney(refreshCfg.moneyType)
    if Int64.ToNumber(ownSilver) >= refreshCfg.needMoneyNum then
      local p = require("netio.protocol.mzm.gsp.item.CEquipSkillRefreshReq").new(self.selectedEquip.bagId, self.selectedEquip.key, self.selectedEquip.id)
      gmodule.network.sendProtocol(p)
    else
      _G.GoToBuyCurrency(refreshCfg.moneyType, true)
    end
  elseif itemId > 0 then
    local itemBase = ItemUtils.GetItemBase(itemId)
    if itemBase then
      Toast(string.format(textRes.Equip[202], itemBase.name))
    end
    self:ShowTips(itemId, obj)
  end
end
def.method("number", "userdata").ShowTips = function(self, itemId, clickobj)
  local position = clickobj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local com = clickobj:GetComponent("UIWidget")
  if com == nil then
    return
  end
  ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x, screenPos.y, com:get_width(), com:get_height(), 0, true)
end
def.method().setEquipList = function(self)
  local effectEquips = EquipStrenTransData.Instance():GetEffectEquips()
  local Grid_Equip = self.m_panel:FindDirect("Img_BgEquip/EquipList/Scroll View_EquipList/Grid_EquipList")
  local uiList = Grid_Equip:GetComponent("UIList")
  uiList:set_itemCount(#effectEquips)
  uiList:Resize()
  if #effectEquips < 1 then
    self:setEmptyEquipInfo()
  end
  for i, v in ipairs(effectEquips) do
    local Img_BgEquip01 = Grid_Equip:FindDirect("Img_BgEquip01_" .. i)
    local levelLabel = Img_BgEquip01:FindDirect(string.format("Label_EquipLv01_%d", i))
    local typeLabel = Img_BgEquip01:FindDirect(string.format("Label_EquipType01_%d", i))
    local activeLabel = Img_BgEquip01:FindDirect(string.format("Lable_Active_%d", i))
    local strLv = v.useLevel .. textRes.Equip[30]
    levelLabel:GetComponent("UILabel"):set_text(strLv)
    typeLabel:GetComponent("UILabel"):set_text(v.typeName)
    Img_BgEquip01:FindDirect(string.format("Label_EquipName01_%d", i)):GetComponent("UILabel"):set_text(v.name)
    local equipIcon = Img_BgEquip01:FindDirect(string.format("Icon_Equip01_%d", i))
    equipIcon:SetActive(true)
    local equipIconTex = equipIcon:GetComponent("UITexture")
    GUIUtils.FillIcon(equipIconTex, v.iconId)
    local equipBgIcon = Img_BgEquip01:FindDirect(string.format("Icon_BgEquip01_%d", i))
    equipBgIcon:SetActive(true)
    equipBgIcon:GetComponent("UISprite"):set_spriteName(string.format("Cell_%02d", v.namecolor))
    Img_BgEquip01:FindDirect(string.format("Img_EquipMark01_%d", i)):SetActive(v.bEquiped)
    Img_BgEquip01:GetComponent("UIToggle"):set_isChecked(self.selectedIdx == i)
  end
end
def.method().setEmptyEquipInfo = function(self)
  local Group_Equip = self.m_panel:FindDirect("Img_BgEquip/Img_CZ_BgCompare/Img_CZ_Bg01/Group_Equip")
  Group_Equip:FindDirect("Img_BgEquipMakeItem"):SetActive(false)
  Group_Equip:FindDirect("Btn_CZ_Cost"):SetActive(false)
  local Img_CZ_Bg02 = self.m_panel:FindDirect("Img_BgEquip/Img_CZ_BgCompare/Img_CZ_Bg02")
  Img_CZ_Bg02:FindDirect("Group_Note_CurEff"):SetActive(false)
  Img_CZ_Bg02:FindDirect("Group_Note_ReplaceEff"):SetActive(false)
  local Img_CZ_BgHaveMoney = self.m_panel:FindDirect("Img_BgEquip/Img_CZ_BgHaveMoney")
  Img_CZ_BgHaveMoney:FindDirect("Label_DZ_HaveMoneyNum"):GetComponent("UILabel"):set_text("")
  local Img_CZ_BgUseMoney = self.m_panel:FindDirect("Img_BgEquip/Img_CZ_BgUseMoney")
  Img_CZ_BgUseMoney:FindDirect("Label_DZ_UseMoneyNum"):GetComponent("UILabel"):set_text("")
  local Label_Title_CurName = Img_CZ_Bg02:FindDirect("Label_Title_CurName")
  local Label_Title_ReplaceName = Img_CZ_Bg02:FindDirect("Label_Title_ReplaceName")
  Label_Title_CurName:GetComponent("UILabel"):set_text("")
  Label_Title_ReplaceName:GetComponent("UILabel"):set_text("")
end
def.method("number").setSelectedEquip = function(self, idx)
  local effectEquips = EquipStrenTransData.Instance():GetEffectEquips()
  self.selectedEquip = effectEquips[idx]
  self:setSelectedEquipInfo()
end
def.method().setSelectedEquipInfo = function(self)
  if self.selectedEquip == nil then
    return
  end
  local equipInfo = self.selectedEquip
  local Group_Equip = self.m_panel:FindDirect("Img_BgEquip/Img_CZ_BgCompare/Img_CZ_Bg01/Group_Equip")
  local Icon_BgEquip = Group_Equip:FindDirect("Icon_BgEquip")
  local Icon_Equip = Icon_BgEquip:FindDirect("Icon_EquipMakeItem")
  local Icon_Bg = Icon_BgEquip:FindDirect("Img_Bg")
  local equipIconTex = Icon_Equip:GetComponent("UITexture")
  GUIUtils.FillIcon(equipIconTex, equipInfo.iconId)
  Icon_Bg:GetComponent("UISprite"):set_spriteName(string.format("Cell_%02d", equipInfo.namecolor))
  local Img_BgEquipMakeItem = Group_Equip:FindDirect("Img_BgEquipMakeItem")
  local Icon_EquipMakeItem = Img_BgEquipMakeItem:FindDirect("Icon_EquipMakeItem")
  local Label_EquipMakeItem = Img_BgEquipMakeItem:FindDirect("Label_EquipMakeItem")
  local Label_EquipMakeName = Img_BgEquipMakeItem:FindDirect("Label_EquipMakeName")
  local ownNum, needNum, itemId = self:getCostItemNum()
  if itemId > 0 then
    local icon_texture = Icon_EquipMakeItem:GetComponent("UITexture")
    local itemBase = ItemUtils.GetItemBase(itemId)
    GUIUtils.FillIcon(icon_texture, itemBase.icon)
    Label_EquipMakeName:GetComponent("UILabel"):set_text(itemBase.name)
    Label_EquipMakeItem:GetComponent("UILabel"):set_text(ownNum .. "/" .. needNum)
    if needNum <= ownNum then
      Label_EquipMakeItem:GetComponent("UILabel"):set_textColor(Color.green)
    else
      Label_EquipMakeItem:GetComponent("UILabel"):set_textColor(Color.red)
    end
  end
  local Img_CZ_Bg02 = self.m_panel:FindDirect("Img_BgEquip/Img_CZ_BgCompare/Img_CZ_Bg02")
  local Label_Title_CurName = Img_CZ_Bg02:FindDirect("Label_Title_CurName")
  local Drag_Tips_CurEff = Img_CZ_Bg02:FindDirect("Group_Note_CurEff/Scrollview_Note/Drag_Tips_CurEff")
  local Label_Title_ReplaceName = Img_CZ_Bg02:FindDirect("Label_Title_ReplaceName")
  local Drag_Tips_ReplaceEff = Img_CZ_Bg02:FindDirect("Group_Note_ReplaceEff/Scrollview_Note/Drag_Tips_ReplaceEff")
  local equipItem = ItemModule.Instance():GetItemByBagIdAndItemKey(equipInfo.bagId, equipInfo.key)
  local equipSkillId = equipItem.extraMap[ItemXStoreType.EQUIP_SKILL]
  if equipSkillId and equipSkillId > 0 then
    local skillCfg = SkillUtility.GetSkillCfg(equipSkillId)
    Label_Title_CurName:GetComponent("UILabel"):set_text(skillCfg.name)
    Drag_Tips_CurEff:GetComponent("UILabel"):set_text(skillCfg.description)
  else
    Label_Title_CurName:GetComponent("UILabel"):set_text("")
    Drag_Tips_CurEff:GetComponent("UILabel"):set_text("")
  end
  local tempSkillId = equipItem.extraMap[ItemXStoreType.EQUIP_SKILL_TEMP]
  local Btn_CZ_Replace = self.m_panel:FindDirect("Img_BgEquip/Btn_CZ_Replace")
  if tempSkillId and tempSkillId > 0 then
    local skillCfg = SkillUtility.GetSkillCfg(tempSkillId)
    Label_Title_ReplaceName:GetComponent("UILabel"):set_text(skillCfg.name)
    Drag_Tips_ReplaceEff:GetComponent("UILabel"):set_text(skillCfg.description)
    Btn_CZ_Replace:GetComponent("UIButton"):set_isEnabled(true)
  else
    Label_Title_ReplaceName:GetComponent("UILabel"):set_text("")
    Drag_Tips_ReplaceEff:GetComponent("UILabel"):set_text(textRes.Equip[211])
    Btn_CZ_Replace:GetComponent("UIButton"):set_isEnabled(false)
  end
  self:setMoneyInfo()
end
def.method("=>", "number", "number", "number").getCostItemNum = function(self)
  if self.selectedEquip then
    local refreshCfg = EquipUtils.GetEquipSkillRefreshCfg(self.selectedEquip.useLevel)
    if refreshCfg then
      local mainItemId = refreshCfg.needMainItemId
      local ViceItemId = refreshCfg.needViceItemId
      local mainItemNum = ItemModule.Instance():GetItemCountById(mainItemId)
      local viceItemNum = ItemModule.Instance():GetItemCountById(ViceItemId)
      return mainItemNum + viceItemNum, refreshCfg.needItemNum, mainItemId
    end
  end
  return 0, 0, 0
end
def.method().updateResetBtn = function(self)
end
def.method().setMoneyInfo = function(self)
  local refreshCfg = EquipUtils.GetEquipSkillRefreshCfg(self.selectedEquip.useLevel)
  local ownSilver = self:GetCostMoney(refreshCfg.moneyType)
  local Img_CZ_BgHaveMoney = self.m_panel:FindDirect("Img_BgEquip/Img_CZ_BgHaveMoney")
  Img_CZ_BgHaveMoney:FindDirect("Label_DZ_HaveMoneyNum"):GetComponent("UILabel"):set_text(Int64.ToNumber(ownSilver))
  local Img_CZ_BgUseMoney = self.m_panel:FindDirect("Img_BgEquip/Img_CZ_BgUseMoney")
  Img_CZ_BgUseMoney:FindDirect("Label_DZ_UseMoneyNum"):GetComponent("UILabel"):set_text(refreshCfg.needMoneyNum)
end
def.method("number", "=>", "userdata").GetCostMoney = function(self, curType)
  local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
  local haveNum = Int64.new(0)
  if curType == MoneyType.YUANBAO then
    haveNum = ItemModule.Instance():GetAllYuanBao()
  elseif curType == MoneyType.GOLD then
    haveNum = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
    warn("HasGold", haveNum)
  elseif curType == MoneyType.SILVER then
    haveNum = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
  elseif curType == MoneyType.GANGCONTRIBUTE then
    local GangModule = require("Main.Gang.GangModule")
    local bHasGang = GangModule.Instance():HasGang()
    if bHasGang == false then
    else
      local bangGong = GangModule.Instance():GetHeroCurBanggong()
      haveNum = Int64.new(bangGong)
    end
  end
  return haveNum
end
def.method("number").UpdateYuanbaoPrice = function(self, uid, id2yuanbao)
  if not self.m_panel or not self.selectedEquip or self.selectedEquip.id == uid then
  end
end
return EquipEffectResetPanel.Commit()

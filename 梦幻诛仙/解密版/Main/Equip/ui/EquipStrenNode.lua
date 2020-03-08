local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local EquipStrenNode = Lplus.Extend(TabNode, "EquipStrenNode")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local LuckStonePanel = require("Main.Equip.ui.LuckStonePanel")
local def = EquipStrenNode.define
local EquipStrenTransData = require("Main.Equip.EquipStrenTransData")
local ItemModule = require("Main.Item.ItemModule")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local EquipUtils = require("Main.Equip.EquipUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local EquipModule = Lplus.ForwardDeclare("EquipModule")
local EquipSocialPanel = Lplus.ForwardDeclare("EquipSocialPanel")
local QiLinMode = require("netio/protocol/mzm/gsp/item/QiLinMode")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
def.field("table")._equipStrenSelected = nil
def.field("number").selectStrenEquipKey = -1
def.field("number").selectStrenEquipPos = 0
def.field("number").selectLuckFuItemId = 0
def.field("number").selectStoneItemId = 0
def.field("number").curSelectedItemIdx = 1
def.field("number").mSaveNeedYuanBaoNum = 0
def.field("number").saveUseItemNum = 0
def.field("number").lastStrenLv = 0
def.field("number").saveAddScore = 0
def.field("number").useYuanbaoQilinNum = 0
def.field("boolean").isShowConfirm = false
def.field("number").mSelectLuckFuNum = 0
def.field("boolean").mAutoUseYuanBao = false
def.field("boolean").mIsWaitingYuanBaoPrice = false
def.field("boolean").mNeedYuanBaoReplaceQiLin = false
def.field("boolean").mNeedYuanBaoReplaceZhenLin = false
def.field("number").mNeedYuanBaoNum = 0
def.field("table").mYuanBaoPriceMap = nil
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
  self:GetZhenAndLuckItemId()
end
def.method().GetZhenAndLuckItemId = function(self)
  self.selectStoneItemId = EquipUtils.GetZhenLingStoneItemId()
  self.selectLuckFuItemId = EquipUtils.GetLuckStoneItemId()
end
def.method("number", "number").SetEquipStrenKeyAndPos = function(self, key, pos)
  self.selectStrenEquipKey = key
  self.selectStrenEquipPos = pos
end
def.method("number").UpdateStrenLevelLabel = function(self, strenLevel)
  local strenLevelStr = "+" .. strenLevel
  local strenLabel = self.m_node:FindDirect("Img_QL_BgEquipMake/Label_RecentNum"):GetComponent("UILabel")
  strenLabel.text = strenLevelStr
end
def.method().FillStrenExplain = function(self)
  local previewGrid = self.m_node:FindDirect("Img_QL_BgEquipPreview")
  local Label_Tips = previewGrid:FindDirect("Group_Tips/Label_Tips"):GetComponent("UILabel")
  Label_Tips:set_text(textRes.Equip[60])
end
def.method("boolean").ShowEquipEmpty = function(self, isEmpty)
  local ctrObjs = {}
  ctrObjs[1] = self.m_node:FindDirect("Img_QL_BgEquipPreview/Label_QL_EquipScore")
  ctrObjs[2] = self.m_node:FindDirect("Img_QL_BgEquipPreview/Group_Current/Label_QL_AttributeNum1_1")
  ctrObjs[3] = self.m_node:FindDirect("Img_QL_BgEquipPreview/Group_Current/Label_QL_AttributeNum2_1")
  ctrObjs[4] = self.m_node:FindDirect("Img_QL_BgEquipPreview/Group_Current/Label1")
  ctrObjs[5] = self.m_node:FindDirect("Img_QL_BgEquipPreview/Group_Current/Label2")
  ctrObjs[6] = self.m_node:FindDirect("Img_QL_BgEquipPreview/Group_Next/Label_QL_EquipPreviewAttributeNum1_1")
  ctrObjs[7] = self.m_node:FindDirect("Img_QL_BgEquipPreview/Group_Next/Label_QL_EquipPreviewAttributeNum2_1")
  ctrObjs[8] = self.m_node:FindDirect("Img_QL_BgEquipPreview/Group_Next/Label_QL_EquipPreviewAttributeNum1_2")
  ctrObjs[9] = self.m_node:FindDirect("Img_QL_BgEquipPreview/Group_Next/Label_QL_EquipPreviewAttributeNum2_2")
  ctrObjs[10] = self.m_node:FindDirect("Img_QL_BgEquipPreview/Group_Next/Img_QL_EquipPreview1")
  ctrObjs[11] = self.m_node:FindDirect("Img_QL_BgEquipPreview/Group_Next/Img_QL_EquipPreview2")
  ctrObjs[12] = self.m_node:FindDirect("Img_QL_BgEquipPreview/Group_Next/Label1")
  ctrObjs[13] = self.m_node:FindDirect("Img_QL_BgEquipPreview/Group_Next/Label2")
  ctrObjs[14] = self.m_node:FindDirect("Img_QL_BgEquipMake/Label_RecentNum")
  ctrObjs[15] = self.m_node:FindDirect("Img_QL_BgEquipMake/Img_QL_BgSuccess/Label_Preview")
  ctrObjs[16] = self.m_node:FindDirect("Img_QL_BgEquipMake/Group_QL_Item")
  ctrObjs[17] = self.m_node:FindDirect("Img_QL_BgEquipMake/Img_QL_BgSuccess/Btn_Advance")
  ctrObjs[18] = self.m_node:FindDirect("Img_QL_BgEquipMake/Img_QL_BgSuccess/Label_QL_BgSuccess")
  ctrObjs[19] = self.m_node:FindDirect("Img_QL_BgEquipMake/Img_QL_BgMax")
  ctrObjs[20] = self.m_node:FindDirect("Img_QL_BgEquipPreview/Group_Current/Label_QL_AttributeNum1_2")
  ctrObjs[21] = self.m_node:FindDirect("Img_QL_BgEquipPreview/Group_Current/Label_QL_AttributeNum2_2")
  ctrObjs[22] = self.m_node:FindDirect("Img_QL_BgEquipPreview/Group_Current/Img_QL_1")
  ctrObjs[23] = self.m_node:FindDirect("Img_QL_BgEquipPreview/Group_Current/Img_QL_2")
  ctrObjs[24] = self.m_node:FindDirect("Img_QL_BgEquipMake/Img_QL_BgHaveMoney/Label_QL_HaveMoneyNum")
  ctrObjs[25] = self.m_node:FindDirect("Img_QL_BgEquipMake/Img_QL_BgUseMoney/Label_QL_UseMoneyNum")
  ctrObjs[26] = self.m_node:FindDirect("Img_QL_BgEquipMake/Img_QL_BgSuccess/Label_QL_SuccessAdd")
  ctrObjs[27] = self.m_node:FindDirect("Btn_YuanbaoUse")
  ctrObjs[28] = self.m_node:FindDirect("Btn_Mode")
  ctrObjs[29] = self.m_node:FindDirect("Btn_Save_YuanbaoUse")
  ctrObjs[30] = self.m_node:FindDirect("Img_QL_BgEquipMake")
  for i = 1, #ctrObjs do
    ctrObjs[i]:SetActive(not isEmpty)
  end
  if isEmpty then
    local BgSprite = self.m_node:FindDirect("Img_QL_BgEquipPreview/Icon_BgEquip")
    local uiSprite = BgSprite:GetComponent("UISprite")
    local uiTexture = BgSprite:FindDirect("Icon_Equip"):GetComponent("UITexture")
    uiSprite:set_spriteName("Cell_00")
    uiTexture.mainTexture = nil
    local btnYuanBaoGroup = self.m_node:FindDirect("Img_QL_BgEquipMake/Btn_QL_Make/Group_MoneyMake")
    local btnLabel = self.m_node:FindDirect("Img_QL_BgEquipMake/Btn_QL_Make/Label_QL_Make")
    btnYuanBaoGroup:SetActive(false)
    btnLabel:SetActive(true)
  end
end
def.method().FillEquipStrenFrame = function(self)
  self:FillStrenExplain()
  local equip = self._equipStrenSelected
  if equip == nil then
    return
  end
  local strenLevel = EquipUtils.GetEquipStrenLevel(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
  local maxStrenLevel = EquipUtils.GetQiLingMaxLevel(self._equipStrenSelected.useLevel)
  if strenLevel >= 50 then
    self:ShowStrenMaxView(true)
    self:FillMaxLevelView()
    return
  end
  self:ShowStrenMaxView(false)
  local btnToggle = self.m_node:FindDirect("Img_QL_BgEquipMake/Group_QL_Item/Img_QL_BgEquipMakeItem02/Btn_QL_Use"):GetComponent("UIToggle")
  btnToggle.value = false
  self:UpdateEquipAttrView()
  self:UpdateQiLingItemView()
  self:UpdateEquipStrenNeedItem(strenLevel)
  self:UpdateEquipStrenSilver()
  self:UpdateYuanBaoToggleState(true)
  self:UpdateQiLingBtn()
  self:UpdateQiLingFailedView(false, strenLevel)
  self:UpdateQiLingItemGrid(strenLevel)
  self:CheckQilingMaxView(strenLevel)
  local qilingBtn = self.m_node:FindDirect("Img_QL_BgEquipMake/Btn_QL_Make"):GetComponent("UIButton")
  qilingBtn:set_isEnabled(true)
end
def.method("boolean").ShowStrenMaxView = function(self, isMax)
  self.m_node:FindDirect("Img_QL_BgEquipPreview"):SetActive(not isMax)
  self.m_node:FindDirect("Img_QL_BgEquipMake"):SetActive(not isMax)
  self.m_node:FindDirect("QLFull"):SetActive(isMax)
end
def.method("boolean").UpdateYuanBaoToggleState = function(self, isReset)
  local yuanbaoToggle = self.m_node:FindDirect("Btn_YuanbaoUse"):GetComponent("UIToggle")
  if isReset then
    yuanbaoToggle.value = false
    self.mNeedYuanBaoReplaceZhenLin = false
    self.mNeedYuanBaoReplaceQiLin = false
    self.mIsWaitingYuanBaoPrice = false
    self.mYuanBaoPriceMap = nil
  elseif yuanbaoToggle.value then
    if self:CanUseYuanBao() then
    else
      yuanbaoToggle.value = false
      self.mIsWaitingYuanBaoPrice = false
      self.mNeedYuanBaoNum = 0
      self.mYuanBaoPriceMap = nil
    end
  else
    yuanbaoToggle.value = false
    self.mIsWaitingYuanBaoPrice = false
    self.mNeedYuanBaoNum = 0
    self.mYuanBaoPriceMap = nil
  end
end
def.method().UpdateQiLingItemView = function(self)
  local i = 1
  local itemId = EquipUtils.GetEquipStrenNeedItemId()
  local itemBase = ItemUtils.GetItemBase(itemId)
  local equipItemGrid = self.m_node:FindDirect("Img_QL_BgEquipMake")
  equipItemGrid:FindDirect(string.format("Group_QL_Item/Img_QL_BgEquipMakeItem0%d/Label_QL_EquipMakeName0%d", i, i)):GetComponent("UILabel"):set_text(itemBase.name)
  local item1 = equipItemGrid:FindDirect(string.format("Group_QL_Item/Img_QL_BgEquipMakeItem0%d", i))
  local icon = item1:FindDirect(string.format("Icon_QL_EquipMakeItem0%d", i))
  icon:SetActive(true)
  local iconTex = icon:GetComponent("UITexture")
  GUIUtils.FillIcon(iconTex, itemBase.icon)
end
def.method().FillMaxLevelView = function(self)
  if nil == self._equipStrenSelected then
    return
  end
  local qilingFullBg = self.m_node:FindDirect("QLFull/Img_QL_BgEquipPreview")
  local itemBgSprite = qilingFullBg:FindDirect("Icon_BgEquip"):GetComponent("UISprite")
  local texture = qilingFullBg:FindDirect("Icon_BgEquip/Icon_Equip"):GetComponent("UITexture")
  local scoreLabel = qilingFullBg:FindDirect("Label_QL_EquipScore"):GetComponent("UILabel")
  itemBgSprite:set_spriteName(string.format("Cell_%02d", self._equipStrenSelected.namecolor))
  GUIUtils.FillIcon(texture, self._equipStrenSelected.iconId)
  local equipItem = ItemModule.Instance():GetItemByBagIdAndItemKey(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
  local score = EquipUtils.CalcEpuipScoreUtil(equipItem)
  scoreLabel:set_text(string.format(textRes.Equip[41], score))
  local attrNameLabel1 = qilingFullBg:FindDirect("Group_Current/Label1"):GetComponent("UILabel")
  local attrNameLabel2 = qilingFullBg:FindDirect("Group_Current/Label2"):GetComponent("UILabel")
  local attrNumLabel1 = qilingFullBg:FindDirect("Group_Current/Label_QL_AttributeNum1_1"):GetComponent("UILabel")
  local attrNumLabel2 = qilingFullBg:FindDirect("Group_Current/Label_QL_AttributeNum2_1"):GetComponent("UILabel")
  local str1Id = EquipUtils.GetAttrAById(self._equipStrenSelected.id)
  local str2Id = EquipUtils.GetAttrBById(self._equipStrenSelected.id)
  local str1 = EquipModule.GetAttriName(str1Id)
  local str2 = EquipModule.GetAttriName(str2Id)
  local valAttriA = EquipModule.GetAttriValue(equipItem.id, ItemXStoreType.ATTRI_A, equipItem.extraMap[ItemXStoreType.ATTRI_A])
  local valAttriB = EquipModule.GetAttriValue(equipItem.id, ItemXStoreType.ATTRI_B, equipItem.extraMap[ItemXStoreType.ATTRI_B])
  local strenLevel = EquipUtils.GetEquipStrenLevel(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
  local tbl = EquipUtils.GetEquipStrenPreviewInfo(self._equipStrenSelected.qilinTypeid, strenLevel, valAttriA, valAttriB)
  if str1Id ~= 0 then
    attrNameLabel1:set_text(str1)
    attrNumLabel1:set_text(tbl[1].attri1)
  else
    attrNumLabel1:set_text("")
    attrNumLabel1:set_text("")
  end
  if str2Id ~= 0 then
    attrNameLabel2:set_text(str2)
    attrNumLabel2:set_text(tbl[1].attri2)
  else
    attrNameLabel2:set_text("")
    attrNumLabel2:set_text("")
  end
end
def.method().UpdateEquipAttrView = function(self)
  local strenLevel = EquipUtils.GetEquipStrenLevel(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
  local equipItem = ItemModule.Instance():GetItemByBagIdAndItemKey(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
  local score = EquipUtils.CalcEpuipScoreUtil(equipItem)
  self:UpdateStrenLevelLabel(strenLevel)
  local previewGrid = self.m_node:FindDirect("Img_QL_BgEquipPreview")
  local BgSprite = previewGrid:FindDirect("Icon_BgEquip"):GetComponent("UISprite")
  GUIUtils.SetSprite(BgSprite, ItemUtils.GetItemFrame(self._equipStrenSelected, nil))
  local Icon_Equip = previewGrid:FindDirect("Icon_BgEquip/Icon_Equip"):GetComponent("UITexture")
  GUIUtils.FillIcon(Icon_Equip, self._equipStrenSelected.iconId)
  previewGrid:FindDirect("Label_QL_EquipScore"):GetComponent("UILabel"):set_text(string.format(textRes.Equip[41], score))
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local str1Id = EquipUtils.GetAttrAById(self._equipStrenSelected.id)
  local str2Id = EquipUtils.GetAttrBById(self._equipStrenSelected.id)
  local str1 = EquipModule.GetAttriName(str1Id)
  local str2 = EquipModule.GetAttriName(str2Id)
  previewGrid:FindDirect("Group_Next/Label1"):GetComponent("UILabel"):set_text(str1)
  previewGrid:FindDirect("Group_Next/Label2"):GetComponent("UILabel"):set_text(str2)
  previewGrid:FindDirect("Group_Current/Label1"):GetComponent("UILabel"):set_text(str1)
  previewGrid:FindDirect("Group_Current/Label2"):GetComponent("UILabel"):set_text(str2)
  local valAttriA = EquipModule.GetAttriValue(equipItem.id, ItemXStoreType.ATTRI_A, equipItem.extraMap[ItemXStoreType.ATTRI_A])
  local valAttriB = EquipModule.GetAttriValue(equipItem.id, ItemXStoreType.ATTRI_B, equipItem.extraMap[ItemXStoreType.ATTRI_B])
  self:UpdateEquipStrenPreview(strenLevel, valAttriA, valAttriB)
end
def.static("number", "table").EquipBindCallback = function(i, tag)
  if 1 == i then
    local dlg = tag.id
    dlg:RealEquipPlay()
  elseif 0 == i then
    return
  end
end
def.method().RealEquipPlay = function(self)
  if self.m_node:get_activeInHierarchy() then
    self:RealStrenEquip()
  end
end
def.method().RealStrenEquip = function(self)
  local strenItemId = EquipUtils.GetEquipStrenNeedItemId()
  local zhenlingItemId = EquipUtils.GetZhenLingStoneItemId()
  local luckItemId = EquipUtils.GetLuckStoneItemId()
  local strenLevel = EquipUtils.GetEquipStrenLevel(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
  local zhenlingStrenLevel = EquipUtils.GetZhenLingStrenLevel()
  local yuanbaoToggle = self.m_node:FindDirect("Btn_YuanbaoUse"):GetComponent("UIToggle")
  local function toEquipQiLing(extraParams)
    local bUseZhenLingStone = 0
    if extraParams and extraParams.useZhenLinStone then
      bUseZhenLingStone = extraParams.useZhenLinStone
    end
    local yuanbaoQiLing = 0
    local yuanbaoZhenLing = 0
    local yuanbaoLuckStone = 0
    if yuanbaoToggle.value and self._equipStrenSelected.needItemNum > ItemModule.Instance():GetItemCountById(strenItemId) then
      yuanbaoQiLing = 1
    end
    if bUseZhenLingStone > 0 and yuanbaoToggle.value and self._equipStrenSelected.stoneItem > ItemModule.Instance():GetItemCountById(zhenlingItemId) then
      yuanbaoZhenLing = 1
    end
    local useLuckStone = 0
    if 0 < self.mSelectLuckFuNum then
      useLuckStone = 1
    end
    if yuanbaoToggle.value and self.mSelectLuckFuNum > ItemModule.Instance():GetItemCountById(luckItemId) then
      yuanbaoLuckStone = 1
    end
    if 0 < self.mNeedYuanBaoNum and yuanbaoToggle.value then
      local yuanbaoInWallet = ItemModule.Instance():GetAllYuanBao()
      if yuanbaoInWallet:lt(self.mNeedYuanBaoNum) then
        _G.GotoBuyYuanbao()
        return
      end
    end
    local function callback(id)
      if id == 1 then
        local p = require("netio.protocol.mzm.gsp.item.CEquipQiLin").new(self._equipStrenSelected.bagId, self._equipStrenSelected.key, yuanbaoQiLing, bUseZhenLingStone, yuanbaoZhenLing, useLuckStone, self.mSelectLuckFuNum, yuanbaoLuckStone, self.mNeedYuanBaoNum, ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER), EquipUtils.GetEquipStrenLevel(self._equipStrenSelected.bagId, self._equipStrenSelected.key))
        gmodule.network.sendProtocol(p)
        local equipItemGrid = self.m_node:FindDirect("Img_QL_BgEquipMake")
        local obj = equipItemGrid:FindDirect("Btn_QL_Make"):GetComponent("UIButton")
        obj:set_isEnabled(false)
        EquipSocialPanel.Instance():DelayCheckBtnEnableState(equipItemGrid:FindDirect("Btn_QL_Make"))
      end
    end
    local curScore = EquipUtils.GetAccumulateQilinEquipScore(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
    if curScore > 0 and IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_QILIN_ACCUMULATION_MODE) then
      CommonConfirmDlg.ShowConfirm("", textRes.Equip[206], callback, nil)
    else
      callback(1)
    end
  end
  if self.selectStoneItemId ~= 0 then
    local useBtn = self.m_node:FindDirect("Img_QL_BgEquipMake/Group_QL_Item/Img_QL_BgEquipMakeItem02/Btn_QL_Use")
    local stoneToggle = useBtn:GetComponent("UIToggle")
    if strenLevel >= zhenlingStrenLevel and stoneToggle.value then
      toEquipQiLing({useZhenLinStone = 1})
    else
      local curStrenLevel = EquipUtils.GetEquipStrenLevel(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
      local extraRate = self:CalcExtraRate()
      local rate = EquipUtils.GetSuccessRate(self.selectLuckFuItemId, curStrenLevel) * self.mSelectLuckFuNum + self._equipStrenSelected.sucRate
      local base = EquipUtils.GetJiGaoMax()
      if curStrenLevel >= 4 and base > rate + extraRate then
        local function callback(select, tag)
          if 1 == select then
            toEquipQiLing({useZhenLinStone = 0})
          end
        end
        CommonConfirmDlg.ShowConfirm("", textRes.Equip[112], callback, nil)
      else
        toEquipQiLing({useZhenLinStone = 0})
      end
    end
  else
    toEquipQiLing({useZhenLinStone = 0})
  end
end
def.method("boolean", "number").UpdateQiLingFailedView = function(self, isUse, strenLevel)
  local equipItemGrid = self.m_node:FindDirect("Img_QL_BgEquipMake")
  local labelObj = equipItemGrid:FindDirect("Img_QL_BgSuccess/Label_Preview")
  if strenLevel < 4 then
    labelObj:SetActive(false)
    return
  end
  labelObj:SetActive(true)
  local preLabel = labelObj:GetComponent("UILabel")
  if isUse == true then
    preLabel.text = textRes.Equip[66]
  else
    local previewLevel = 0
    if 0 < strenLevel - 1 then
      previewLevel = strenLevel - 1
    end
    preLabel.text = string.format(textRes.Equip[64], previewLevel)
  end
end
def.method("number", "number", "table").UpdateEquipStrenFrame = function(self, strenLevel, bSuccess, newItemInfo)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  if bSuccess == 1 then
    local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
    if PlayerIsInFight() and self._equipStrenSelected.bagId == BagInfo.EQUIPBAG then
      Toast(textRes.Equip[95])
    else
      Toast(textRes.Equip[85])
    end
  else
    Toast(textRes.Equip[86])
  end
  local fxObj = self.m_node:FindDirect("Img_QL_BgEquipMake/Label_RecentNum")
  if bSuccess == 0 then
    require("Fx.GUIFxMan").Instance():PlayAsChild(fxObj, RESPATH.TREN_FAILED_EFFECT, -55, 10, -1, false)
  else
    require("Fx.GUIFxMan").Instance():PlayAsChild(fxObj, RESPATH.TREN_SUCCESSFUL_EFFECT, -55, 10, -1, false)
  end
  local maxStrenLevel = EquipUtils.GetQiLingMaxLevel(self._equipStrenSelected.useLevel)
  if strenLevel >= 50 then
    self:ShowStrenMaxView(true)
    self:FillMaxLevelView()
    return
  end
  local previewGrid = self.m_node:FindDirect("Img_QL_BgEquipPreview")
  self:UpdateStrenLevelLabel(strenLevel)
  local btnToggle = self.m_node:FindDirect("Img_QL_BgEquipMake/Group_QL_Item/Img_QL_BgEquipMakeItem02/Btn_QL_Use"):GetComponent("UIToggle")
  self:UpdateQiLingFailedView(btnToggle.value, strenLevel)
  local numObj = previewGrid:FindDirect("Label_QL_EquipPreviewLv")
  require("Fx.GUIFxMan").Instance():PlayAsChild(numObj, RESPATH.EQUIP_STREN_LEVEL_LIGHT_EFFECT, 0, 0, -1, false)
  local equipItem = ItemModule.Instance():GetItemByBagIdAndItemKey(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
  local score = EquipUtils.CalcEpuipScoreUtil(equipItem)
  previewGrid:FindDirect("Label_QL_EquipScore"):GetComponent("UILabel"):set_text(string.format(textRes.Equip[41], score))
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local valAttriA = EquipModule.GetAttriValue(equipItem.id, ItemXStoreType.ATTRI_A, equipItem.extraMap[ItemXStoreType.ATTRI_A])
  local valAttriB = EquipModule.GetAttriValue(equipItem.id, ItemXStoreType.ATTRI_B, equipItem.extraMap[ItemXStoreType.ATTRI_B])
  self:UpdateEquipStrenPreview(strenLevel, valAttriA, valAttriB)
  self:ReSetLockStoneInfo()
  self:UpdateBtnState()
  self:UpdateLuckFuInfo()
  self:UpdateQiLingItemGrid(strenLevel)
  self:CheckQilingMaxView(strenLevel)
end
def.method("number", "table").UpdateAccumutionEquipStrenFrame = function(self, strenLevel, newItemInfo)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  warn("-------lastStrenLv:", strenLevel, self.lastStrenLv)
  local maxStrenLevel = EquipUtils.GetQiLingMaxLevel(self._equipStrenSelected.useLevel)
  if strenLevel > self.lastStrenLv then
    local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
    if PlayerIsInFight() and self._equipStrenSelected.bagId == BagInfo.EQUIPBAG then
      Toast(textRes.Equip[95])
    else
      Toast(textRes.Equip[85])
    end
    local fxObj = self.m_node:FindDirect("Img_QL_BgEquipMake/Label_RecentNum")
    require("Fx.GUIFxMan").Instance():PlayAsChild(fxObj, RESPATH.TREN_SUCCESSFUL_EFFECT, -55, 10, -1, false)
    if strenLevel < 50 then
      local Btn_Save_YuanbaoUse = self.m_node:FindDirect("Btn_Save_YuanbaoUse")
      local uiToggle = Btn_Save_YuanbaoUse:GetComponent("UIToggle")
      if uiToggle.value then
        local itemIdList = {}
        local qilingCfg = EquipUtils.GetQiLinAccumulateModeCfg(strenLevel + 1)
        for i, v in ipairs(qilingCfg.qilingItems) do
          table.insert(itemIdList, v.itemId)
        end
        local p = require("netio.protocol.mzm.gsp.item.CReqItemYuanbaoPriceWithId").new(self._equipStrenSelected.id, itemIdList)
        gmodule.network.sendProtocol(p)
      end
    end
  else
    Toast(string.format(textRes.Equip[208], self.saveAddScore))
  end
  if strenLevel >= 50 then
    self:ShowStrenMaxView(true)
    self:FillMaxLevelView()
    return
  end
  self:UpdateStrenLevelLabel(strenLevel)
  local previewGrid = self.m_node:FindDirect("Img_QL_BgEquipPreview")
  local equipItem = ItemModule.Instance():GetItemByBagIdAndItemKey(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
  local score = EquipUtils.CalcEpuipScoreUtil(equipItem)
  previewGrid:FindDirect("Label_QL_EquipScore"):GetComponent("UILabel"):set_text(string.format(textRes.Equip[41], score))
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local valAttriA = EquipModule.GetAttriValue(equipItem.id, ItemXStoreType.ATTRI_A, equipItem.extraMap[ItemXStoreType.ATTRI_A])
  local valAttriB = EquipModule.GetAttriValue(equipItem.id, ItemXStoreType.ATTRI_B, equipItem.extraMap[ItemXStoreType.ATTRI_B])
  self:UpdateEquipStrenPreview(strenLevel, valAttriA, valAttriB)
  self:SetSaveEquipInfo()
end
def.method().UpdateBtnState = function(self)
  GameUtil.AddGlobalTimer(0.8, true, function()
    if self.m_panel == nil or self.m_panel.isnil then
      return
    end
    local equipItemGrid = self.m_node:FindDirect("Img_QL_BgEquipMake")
    local obj = equipItemGrid:FindDirect("Btn_QL_Make"):GetComponent("UIButton")
    obj:set_isEnabled(true)
    if self.mSelectLuckFuNum > 0 or self.mAutoUseYuanBao == true then
      self.mSelectLuckFuNum = 0
      self.mAutoUseYuanBao = false
      self:UpdateQiLingBtn()
      self:UpdateLuckFuInfo()
    end
  end)
end
def.method("number", "number", "number").UpdateEquipStrenPreview = function(self, strenLevel, attri1, attri2)
  local tbl = EquipUtils.GetEquipStrenPreviewInfo(self._equipStrenSelected.qilinTypeid, strenLevel, attri1, attri2)
  local previewGrid = self.m_node:FindDirect("Img_QL_BgEquipPreview")
  local str1Id = EquipUtils.GetAttrAById(self._equipStrenSelected.id)
  local str2Id = EquipUtils.GetAttrBById(self._equipStrenSelected.id)
  previewGrid:FindDirect("Group_Current"):SetActive(true)
  if 0 == str1Id then
    previewGrid:FindDirect("Group_Current/Label_QL_AttributeNum1_1"):GetComponent("UILabel"):set_text("")
    previewGrid:FindDirect("Group_Current/Label_QL_AttributeNum1_2"):GetComponent("UILabel"):set_text("")
  else
    previewGrid:FindDirect("Group_Current/Label_QL_AttributeNum1_1"):GetComponent("UILabel"):set_text(tbl[1].attri1)
    previewGrid:FindDirect("Group_Current/Label_QL_AttributeNum1_2"):GetComponent("UILabel"):set_text(tbl[1].dValue1)
  end
  if 0 == str2Id then
    previewGrid:FindDirect("Group_Current/Label_QL_AttributeNum2_1"):GetComponent("UILabel"):set_text("")
    previewGrid:FindDirect("Group_Current/Label_QL_AttributeNum2_2"):GetComponent("UILabel"):set_text("")
  else
    previewGrid:FindDirect("Group_Current/Label_QL_AttributeNum2_1"):GetComponent("UILabel"):set_text(tbl[1].attri2)
    previewGrid:FindDirect("Group_Current/Label_QL_AttributeNum2_2"):GetComponent("UILabel"):set_text(tbl[1].dValue2)
  end
  previewGrid:FindDirect("Group_Current/Label_QL_AttributeNum1_2"):SetActive(false)
  previewGrid:FindDirect("Group_Current/Label_QL_AttributeNum2_2"):SetActive(false)
  previewGrid:FindDirect("Group_Current/Img_QL_1"):SetActive(false)
  previewGrid:FindDirect("Group_Current/Img_QL_2"):SetActive(false)
  local qilingMax = EquipUtils.GetQiLingMaxLevel(self._equipStrenSelected.useLevel)
  local qiLingPreView = previewGrid:FindDirect("Group_Next")
  if strenLevel >= 50 then
    qiLingPreView:SetActive(false)
    return
  end
  local nextStrenLevel = strenLevel + 1
  local tb2 = EquipUtils.GetEquipStrenPreviewInfo(self._equipStrenSelected.qilinTypeid, nextStrenLevel, attri1, attri2)
  qiLingPreView:SetActive(true)
  if 0 == str1Id then
    qiLingPreView:FindDirect("Label_QL_EquipPreviewAttributeNum1_1"):GetComponent("UILabel"):set_text("")
    qiLingPreView:FindDirect("Label_QL_EquipPreviewAttributeNum1_2"):GetComponent("UILabel"):set_text("")
    qiLingPreView:FindDirect("Img_QL_EquipPreview1"):SetActive(false)
  else
    qiLingPreView:FindDirect("Label_QL_EquipPreviewAttributeNum1_1"):GetComponent("UILabel").text = tb2[1].attri1
    qiLingPreView:FindDirect("Label_QL_EquipPreviewAttributeNum1_2"):GetComponent("UILabel").text = tbl[1].dValue1
    qiLingPreView:FindDirect("Img_QL_EquipPreview1"):SetActive(true)
  end
  if 0 == str2Id then
    qiLingPreView:FindDirect("Label_QL_EquipPreviewAttributeNum2_1"):GetComponent("UILabel"):set_text("")
    qiLingPreView:FindDirect("Label_QL_EquipPreviewAttributeNum2_1/Label"):SetActive(false)
    qiLingPreView:FindDirect("Label_QL_EquipPreviewAttributeNum2_2"):GetComponent("UILabel"):set_text("")
    qiLingPreView:FindDirect("Img_QL_EquipPreview2"):SetActive(false)
  else
    qiLingPreView:FindDirect("Label_QL_EquipPreviewAttributeNum2_1"):GetComponent("UILabel").text = tb2[1].attri2
    qiLingPreView:FindDirect("Label_QL_EquipPreviewAttributeNum2_1/Label"):SetActive(true)
    qiLingPreView:FindDirect("Label_QL_EquipPreviewAttributeNum2_2"):GetComponent("UILabel").text = tbl[1].dValue2
    qiLingPreView:FindDirect("Img_QL_EquipPreview2"):SetActive(true)
  end
end
def.method("number").UpdateEquipStrenNeedItem = function(self, strenLevel)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  if nil == self._equipStrenSelected then
    return
  end
  if strenLevel ~= EquipUtils.GetEquipStrenLevel(self._equipStrenSelected.bagId, self._equipStrenSelected.key) then
    strenLevel = EquipUtils.GetEquipStrenLevel(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
  end
  local maxStrenLevel = EquipUtils.GetQiLingMaxLevel(self._equipStrenSelected.useLevel)
  if strenLevel >= 50 then
    return
  end
  if EquipModule.Instance().curQiLinMode == QiLinMode.ACCUMULATION_MODE then
    self:SetSaveEquipInfo()
    return
  end
  local strengthItemNum, stoneItem, strengthMoney, rate, canUseLuckStone = EquipUtils.GetEquipStrenNeedItemInfoAfterSuccess(self._equipStrenSelected.qilinTypeid, strenLevel + 1)
  self._equipStrenSelected.needItemNum = strengthItemNum
  self._equipStrenSelected.stoneItem = stoneItem
  self._equipStrenSelected.needCooperNum = strengthMoney
  self._equipStrenSelected.sucRate = rate
  self._equipStrenSelected.canUseLuckStone = canUseLuckStone
  local tbl = {}
  table.insert(tbl, {
    id = EquipUtils.GetEquipStrenNeedItemId(),
    num = strengthItemNum
  })
  local equipItemGrid = self.m_node:FindDirect("Img_QL_BgEquipMake")
  local equipItem = ItemModule.Instance():GetItemByBagIdAndItemKey(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
  local score = EquipUtils.CalcEpuipScoreUtil(equipItem)
  local previewGrid = self.m_node:FindDirect("Img_QL_BgEquipPreview")
  previewGrid:FindDirect("Label_QL_EquipScore"):GetComponent("UILabel"):set_text(string.format(textRes.Equip[41], score))
  local i = 1
  local itemId = EquipUtils.GetEquipStrenNeedItemId()
  local have = ItemModule.Instance():GetItemCountById(itemId)
  local needAndHave = have .. "/" .. strengthItemNum
  local item = equipItemGrid:FindDirect(string.format("Group_QL_Item/Img_QL_BgEquipMakeItem0%d", i))
  item:FindDirect(string.format("Label_QL_EquipMakeItem0%d", i)):GetComponent("UILabel"):set_text(needAndHave)
  local textColor = Color.green
  if strengthItemNum > have then
    textColor = Color.red
  end
  item:FindDirect(string.format("Label_QL_EquipMakeItem0%d", i)):GetComponent("UILabel"):set_textColor(textColor)
  self:UpdateLuckFuInfo()
  self:UpdateStoneInfo()
  self:UpdateYuanBaoToggleState(false)
  self:UpdateQiLingBtn()
end
def.method().UpdateEquipStrenSilver = function(self)
  if nil == self._equipStrenSelected then
    return
  end
  local strenLevel = EquipUtils.GetEquipStrenLevel(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
  local maxStrenLevel = EquipUtils.GetQiLingMaxLevel(self._equipStrenSelected.useLevel)
  if strenLevel >= 50 then
    return
  end
  local equipItemGrid = self.m_node:FindDirect("Img_QL_BgEquipMake")
  local haveSilverLabel = equipItemGrid:FindDirect("Img_QL_BgHaveMoney/Label_QL_HaveMoneyNum"):GetComponent("UILabel")
  local needSlverLabel = equipItemGrid:FindDirect("Img_QL_BgUseMoney/Label_QL_UseMoneyNum"):GetComponent("UILabel")
  local curStrenLevel = EquipUtils.GetEquipStrenLevel(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
  local strenInfoCfg = EquipUtils.GetStrenInfoCfg(self._equipStrenSelected.qilinTypeid, curStrenLevel)
  local needSilverNum = strenInfoCfg.needSilverNum
  if needSilverNum == nil then
    needSilverNum = 0
  end
  local haveSilverNum = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
  if haveSilverNum:lt(needSilverNum) then
    needSlverLabel.textColor = Color.red
  else
    needSlverLabel.textColor = Color.Color(0.30980392156862746, 0.18823529411764706, 0.09411764705882353, 1)
  end
  haveSilverLabel:set_text(Int64.tostring(haveSilverNum))
  needSlverLabel:set_text(needSilverNum)
end
def.method("number").UpdateQiLingItemGrid = function(self, strenLevel)
  local ItemGrid = self.m_node:FindDirect("Img_QL_BgEquipMake/Group_QL_Item")
  local qilingItem = ItemGrid:FindDirect("Img_QL_BgEquipMakeItem01")
  local zhenlingItem = ItemGrid:FindDirect("Img_QL_BgEquipMakeItem02")
  local luckstoneItem = ItemGrid:FindDirect("Img_QL_BgEquipMakeItem03")
  qilingItem:SetActive(true)
  local zhenglingStrenLevel = EquipUtils.GetZhenLingStrenLevel()
  if strenLevel >= zhenglingStrenLevel then
    zhenlingItem:SetActive(true)
  else
    zhenlingItem:SetActive(false)
  end
  local _, _, _, _, canUseLuckStone = EquipUtils.GetEquipStrenNeedItemInfoAfterSuccess(self._equipStrenSelected.qilinTypeid, strenLevel + 1)
  if canUseLuckStone then
    luckstoneItem:SetActive(true)
  else
    luckstoneItem:SetActive(false)
  end
  local grid = ItemGrid:GetComponent("UIGrid")
  GameUtil.AddGlobalLateTimer(0, true, function()
    grid:Reposition()
  end)
end
def.static("number", "table").StoneNotEnoughCallback = function(i, tag)
  if 1 == i then
    local dlg = tag.id
    dlg:RealStrenEquip()
  elseif 0 == i then
    return
  end
end
def.method().OnEquipStrenBtnClick = function(self)
  if nil == self._equipStrenSelected then
    return
  end
  local equip = ItemModule.Instance():GetItemByBagIdAndItemKey(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
  if nil == equip then
    return
  end
  if ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER):lt(self._equipStrenSelected.needCooperNum) == true then
    Toast(textRes.Equip[98])
    GoToBuySilver(false)
    return
  end
  local strenItemId = EquipUtils.GetEquipStrenNeedItemId()
  local zhenlingItemId = EquipUtils.GetZhenLingStoneItemId()
  local luckItemId = EquipUtils.GetLuckStoneItemId()
  local yuanbaoToggle = self.m_node:FindDirect("Btn_YuanbaoUse"):GetComponent("UIToggle")
  local equipItemGrid = self.m_node:FindDirect("Img_QL_BgEquipMake")
  local itemId = EquipUtils.GetEquipStrenNeedItemId()
  local clickobj = equipItemGrid:FindDirect("Btn_QL_Make")
  if self._equipStrenSelected.needItemNum > ItemModule.Instance():GetItemCountById(strenItemId) and not yuanbaoToggle.value then
    self:ShowTips(itemId, clickobj)
    Toast(textRes.Equip[106])
    return
  end
  local zhenlingBtnToggle = self.m_node:FindDirect("Img_QL_BgEquipMake/Group_QL_Item/Img_QL_BgEquipMakeItem02/Btn_QL_Use"):GetComponent("UIToggle")
  local zhenlingCurValue = zhenlingBtnToggle.value
  local strenLevel = EquipUtils.GetEquipStrenLevel(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
  local zhenlingStrenLevel = EquipUtils.GetZhenLingStrenLevel()
  if strenLevel >= zhenlingStrenLevel and zhenlingCurValue and self._equipStrenSelected.stoneItem > ItemModule.Instance():GetItemCountById(zhenlingItemId) and not yuanbaoToggle.value then
    self:ShowTips(zhenlingItemId, clickobj)
    Toast(textRes.Equip[67])
    return
  end
  local _, _, _, _, canUseLuckStone = EquipUtils.GetEquipStrenNeedItemInfoAfterSuccess(self._equipStrenSelected.qilinTypeid, strenLevel + 1)
  if canUseLuckStone and self.mSelectLuckFuNum > ItemModule.Instance():GetItemCountById(luckItemId) and not yuanbaoToggle.value then
    self:ShowTips(luckItemId, clickobj)
    Toast(textRes.Equip[128])
    return
  end
  local flag = equip.flag
  if require("netio.protocol.mzm.gsp.item.ItemInfo").BIND ~= flag then
    local tag = {id = self}
    local content = textRes.Equip[11] .. textRes.Equip[20] .. textRes.Equip[11] .. textRes.Equip[9]
    CommonConfirmDlg.ShowConfirm(textRes.Equip[29], content, EquipStrenNode.EquipBindCallback, tag)
    return
  else
    self:RealStrenEquip()
  end
end
def.method("number").OnEquipListClick = function(self, index)
  self.curSelectedItemIdx = 1
  self.saveUseItemNum = 0
  self.useYuanbaoQilinNum = 0
  self.mAutoUseYuanBao = false
  self.mSelectLuckFuNum = 0
  self.mIsWaitingYuanBaoPrice = false
  self.mNeedYuanBaoReplaceQiLin = false
  self.mNeedYuanBaoReplaceZhenLin = false
  self.mNeedYuanBaoNum = 0
  self.mYuanBaoPriceMap = nil
  self.mSaveNeedYuanBaoNum = 0
  self.isShowConfirm = false
  local equipStrenTransList = EquipStrenTransData.Instance():GetStrenEquips()
  if #equipStrenTransList < 1 then
    self:ShowStrenMaxView(false)
    self:ShowEquipEmpty(true)
    return
  else
    self:ShowEquipEmpty(false)
  end
  local equip = equipStrenTransList[index]
  self._equipStrenSelected = equip
  self:SwitchQiLingMode()
end
def.override().OnShow = function(self)
  if self.selectStrenEquipKey == -1 and self.selectStrenEquipPos == 0 then
    self:OnEquipListClick(1)
    EquipSocialPanel.Instance():SelectFromEquipStrenTrans(1)
  else
    do
      local equipStrenTransList = EquipStrenTransData.Instance():GetStrenEquips()
      local selectIndex = 1
      for k, v in pairs(equipStrenTransList) do
        if self.selectStrenEquipKey == v.key and v.bagId == self.selectStrenEquipPos then
          selectIndex = k
        end
      end
      self:OnEquipListClick(selectIndex)
      EquipSocialPanel.Instance():SelectFromEquipStrenTrans(selectIndex)
      self.selectStrenEquipKey = -1
      self.selectStrenEquipPos = 0
      local gridTemplate = self.m_panel:FindDirect("Img_BgEquip/EquipList/Scroll View_EquipList/Grid_EquipList")
      local str = string.format("Img_BgEquip01_%d", selectIndex)
      local list = gridTemplate:GetComponent("UIList"):get_children()
      local eqpUI
      for i = 1, #list do
        eqpUI = list[i]
        if eqpUI.name == str then
          eqpUI:GetComponent("UIToggle"):set_isChecked(true)
        else
          eqpUI:GetComponent("UIToggle"):set_isChecked(false)
        end
      end
      if selectIndex > 4 then
        GameUtil.AddGlobalTimer(0.1, true, function()
          if self.m_panel and false == self.m_panel.isnil then
            local uiScrollView = self.m_panel:FindDirect("Img_BgEquip/EquipList/Scroll View_EquipList"):GetComponent("UIScrollView")
            uiScrollView:DragToMakeVisible(eqpUI.transform, 8)
          end
        end)
      end
    end
  end
end
def.override().OnHide = function(self)
end
def.method("userdata").OnEquipStrenNeedItemClick = function(self, clickobj)
  local id = clickobj.name
  local indexStr = string.sub(id, string.len("Img_QL_BgEquipMakeItem0") + 1)
  local index = tonumber(indexStr)
  local itemId = 0
  if index == 1 then
    itemId = EquipUtils.GetEquipStrenNeedItemId()
  end
  self:ShowTips(itemId, clickobj)
end
def.method("number", "userdata").ShowTips = function(self, itemId, clickobj)
  local position = clickobj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = clickobj:GetComponent("UISprite")
  ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, true)
end
def.method("number", "userdata", "string").ShowTipsEx = function(self, itemId, obj, componentName)
  local position = obj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local com = obj:GetComponent(componentName)
  if com == nil then
    return
  end
  ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x, screenPos.y, com:get_width(), com:get_height(), 0, true)
end
def.method("number").CheckQilingMaxView = function(self, strenLevel)
  local useLevel = self._equipStrenSelected.useLevel
  local qilingMax = EquipUtils.GetQiLingMaxLevel(useLevel)
  local MaxLabel = self.m_node:FindDirect("Img_QL_BgEquipMake/Img_QL_BgMax")
  local LabelTitle = self.m_node:FindDirect("Img_QL_BgEquipMake/Img_QL_BgSuccess")
  local GroupNext = self.m_node:FindDirect("Img_QL_BgEquipPreview/Group_Next")
  if strenLevel >= 50 then
    LabelTitle:SetActive(false)
    MaxLabel:SetActive(true)
    GroupNext:SetActive(false)
  else
    LabelTitle:SetActive(true)
    MaxLabel:SetActive(false)
    GroupNext:SetActive(true)
  end
end
def.method("=>", "number").CalcExtraRate = function(self)
  if nil == self._equipStrenSelected then
    return 0
  end
  local ItemModule = require("Main.Item.ItemModule")
  local bagId = ItemModule.BAG
  if self._equipStrenSelected.bEquiped then
    bagId = ItemModule.EQUIPBAG
  end
  local extraScore = EquipModule.GetQiLingAddRate(self._equipStrenSelected.uuid, bagId)
  local strenLevel = EquipUtils.GetEquipStrenLevel(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
  local extraRate = EquipUtils.GetStrenScore2Rate(self._equipStrenSelected.qilinTypeid, strenLevel + 1, extraScore)
  local fashionRate = EquipModule.GetStrenExtraAddRate()
  return extraRate + fashionRate
end
def.method().UpdateLuckFuInfo = function(self)
  local i = 3
  local equipItemGrid = self.m_node:FindDirect("Img_QL_BgEquipMake")
  local Label_QL_EquipMakeName = equipItemGrid:FindDirect(string.format("Group_QL_Item/Img_QL_BgEquipMakeItem0%d/Label_QL_EquipMakeName0%d", i, i)):GetComponent("UILabel")
  local item = equipItemGrid:FindDirect(string.format("Group_QL_Item/Img_QL_BgEquipMakeItem0%d", i))
  local info = item:FindDirect("itemInfo")
  local luckItemBase = ItemUtils.GetItemBase(self.selectLuckFuItemId)
  info:SetActive(true)
  local Icon_QL_EquipMakeItem = info:FindDirect(string.format("Icon_QL_EquipMakeItem0%d", i)):GetComponent("UITexture")
  local Label_QL_EquipMakeItem = info:FindDirect(string.format("Label_QL_EquipMakeItem0%d", i)):GetComponent("UILabel")
  local ReduceImg = info:FindDirect("Btn_QL_Reduce03")
  GUIUtils.FillIcon(Icon_QL_EquipMakeItem, luckItemBase.icon)
  Label_QL_EquipMakeName:set_text(luckItemBase.name)
  local have = ItemModule.Instance():GetItemCountById(self.selectLuckFuItemId)
  local needAndHave = have .. "/" .. self.mSelectLuckFuNum
  Label_QL_EquipMakeItem:set_text(needAndHave)
  local textColor = Color.green
  if have < self.mSelectLuckFuNum then
    textColor = Color.red
  end
  Label_QL_EquipMakeItem:set_textColor(textColor)
  if self.mSelectLuckFuNum > 0 then
    ReduceImg:SetActive(true)
  else
    ReduceImg:SetActive(false)
  end
  local equipItemGrid = self.m_node:FindDirect("Img_QL_BgEquipMake")
  local Label_QL_BgSuccess = equipItemGrid:FindDirect("Img_QL_BgSuccess/Label_QL_BgSuccess"):GetComponent("UILabel")
  local extraRateLabel = equipItemGrid:FindDirect("Img_QL_BgSuccess/Label_QL_SuccessAdd"):GetComponent("UILabel")
  local extraRate = self:CalcExtraRate()
  local strenLevel = EquipUtils.GetEquipStrenLevel(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
  local rate = EquipUtils.GetSuccessRate(self.selectLuckFuItemId, strenLevel) * self.mSelectLuckFuNum + self._equipStrenSelected.sucRate
  local base = EquipUtils.GetJiGaoMax()
  if base < rate + extraRate then
    extraRate = base - rate
  end
  if rate > base then
    rate = base
  end
  if rate >= EquipUtils.GetJiGaoMin() and rate <= EquipUtils.GetJiGaoMax() then
    Label_QL_BgSuccess.text = string.format("[00aa00]%.2f[-]", rate / base * 100) .. string.format("[00aa00]%s[-]", "%")
  elseif rate >= EquipUtils.GetJiaoGaoMin() and rate <= EquipUtils.GetJiaoGaoMax() then
    Label_QL_BgSuccess.text = string.format("[0000aa]%.2f[-]", rate / base * 100) .. string.format("[0000aa]%s[-]", "%")
  elseif rate >= EquipUtils.GetYiBanMin() and rate <= EquipUtils.GetYiBanMax() then
    Label_QL_BgSuccess.text = string.format("[ff6100]%.2f[-]", rate / base * 100) .. string.format("[ff6100]%s[-]", "%")
  elseif rate >= EquipUtils.GetJiaoDiMin() and rate <= EquipUtils.GetJiaoDiMax() then
    Label_QL_BgSuccess.text = string.format("[aa00aa]%.2f[-]", rate / base * 100) .. string.format("[aa00aa]%s[-]", "%")
  elseif rate >= EquipUtils.GetJiDiMin() and rate <= EquipUtils.GetJiDiMax() then
    Label_QL_BgSuccess.text = string.format("[aa0000]%.2f[-]", rate / base * 100) .. string.format("[aa0000]%s[-]", "%")
  end
  if extraRate <= 0 then
    extraRateLabel:set_text("")
  else
    extraRateLabel:set_text(string.format("[4b5cc4] +%.2f[-]", extraRate / base * 100) .. string.format("[4b5cc4]%s[-]", "%"))
  end
end
def.static("table", "number").AddLuckyCallback = function(tag, itemId)
  local self = tag.id
  self.selectLuckFuItemId = itemId
  self:UpdateLuckFuInfo()
end
def.method().OnEquipStrenLuckyFuClick = function(self)
  local EquipStrenItemChoosePanel = require("Main.Equip.ui.EquipStrenItemChoosePanel")
  local tag = {}
  tag.id = self
  EquipStrenItemChoosePanel.Instance():ShowPanel(EquipStrenItemChoosePanel.Type.LuckyFu, EquipStrenNode.AddLuckyCallback, tag)
end
def.method().UpdateStoneInfo = function(self)
  local i = 2
  local equipItemGrid = self.m_node:FindDirect("Img_QL_BgEquipMake")
  local Label_QL_EquipMakeName = equipItemGrid:FindDirect(string.format("Group_QL_Item/Img_QL_BgEquipMakeItem0%d/Label_QL_EquipMakeName0%d", i, i)):GetComponent("UILabel")
  local item = equipItemGrid:FindDirect(string.format("Group_QL_Item/Img_QL_BgEquipMakeItem0%d", i))
  local empty = item:FindDirect("Img_QL_Empty")
  local info = item:FindDirect("itemInfo")
  local reducuBtn = info:FindDirect("Btn_QL_Reduce02")
  reducuBtn:SetActive(false)
  local zhenlingItemBase = ItemUtils.GetItemBase(self.selectStoneItemId)
  Label_QL_EquipMakeName.text = zhenlingItemBase.name
  if self.selectStoneItemId ~= 0 then
    local have = ItemModule.Instance():GetItemCountById(self.selectStoneItemId)
    empty:SetActive(false)
    info:SetActive(true)
    local Icon_QL_EquipMakeItem = info:FindDirect(string.format("Icon_QL_EquipMakeItem0%d", i)):GetComponent("UITexture")
    local Label_QL_EquipMakeItem = info:FindDirect(string.format("Label_QL_EquipMakeItem0%d", i)):GetComponent("UILabel")
    GUIUtils.FillIcon(Icon_QL_EquipMakeItem, zhenlingItemBase.icon)
    local needAndHave = have .. "/" .. self._equipStrenSelected.stoneItem
    info:FindDirect(string.format("Label_QL_EquipMakeItem0%d", i)):GetComponent("UILabel"):set_text(needAndHave)
    local Btn_use = self.m_node:FindDirect("Img_QL_BgEquipMake/Group_QL_Item/Img_QL_BgEquipMakeItem02/Btn_QL_Use")
    local zhenlingLock = self.m_node:FindDirect("Img_QL_BgEquipMake/Group_QL_Item/Img_QL_BgEquipMakeItem02/Img_Lock")
    local textColor = Color.green
    if have < self._equipStrenSelected.stoneItem then
      textColor = Color.red
    end
    info:FindDirect(string.format("Label_QL_EquipMakeItem0%d", i)):GetComponent("UILabel"):set_textColor(textColor)
    if Btn_use:GetComponent("UIToggle").value then
      zhenlingLock:SetActive(false)
    else
      zhenlingLock:SetActive(true)
    end
  else
    empty:SetActive(true)
    info:SetActive(false)
  end
end
def.method("number").SetLuckStoneNumber = function(self, num)
  self.mSelectLuckFuNum = num
end
def.method("number").UnSelectStrenItemClick = function(self, index)
  if 3 == index then
    self.mSelectLuckFuNum = 0
    self.mAutoUseYuanBao = false
    self:UpdateLuckFuInfo()
    self:UpdateQiLingBtn()
    local strenLevel = EquipUtils.GetEquipStrenLevel(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
    local btnToggle = self.m_node:FindDirect("Img_QL_BgEquipMake/Group_QL_Item/Img_QL_BgEquipMakeItem02/Btn_QL_Use"):GetComponent("UIToggle")
    self:UpdateQiLingFailedView(btnToggle.value, strenLevel)
  end
end
def.method("number", "table").OnAskQiLingItemsYuanBaoPrice = function(self, uid, itemid2yuanbao)
  warn("OnAskQiLingItemsYuanBaoPrice ~~~~~~~~~~~~~~~~~~~", uid)
  if self.m_node and not self.m_node.isnil then
    if EquipModule.Instance().curQiLinMode == QiLinMode.ACCUMULATION_MODE then
      if uid == self._equipStrenSelected.id then
        do
          local strenLevel = EquipUtils.GetEquipStrenLevel(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
          local qilingCfg = EquipUtils.GetQiLinAccumulateModeCfg(strenLevel + 1)
          if qilingCfg then
            do
              local bestIdx = self:GetCostPerformanceBestIdx(itemid2yuanbao)
              if bestIdx == self.curSelectedItemIdx then
                local itemInfo = qilingCfg.qilingItems[self.curSelectedItemIdx]
                if itemInfo then
                  self.mSaveNeedYuanBaoNum = itemid2yuanbao[itemInfo.itemId] or 0
                  self:UpdateSaveQiLinBtn()
                end
              else
                do
                  local itemInfo = qilingCfg.qilingItems[bestIdx]
                  local itemBase = ItemUtils.GetItemBase(itemInfo.itemId)
                  local str = string.format(textRes.Equip[219], itemBase.name)
                  local function callback(id)
                    if id == 1 then
                      local Img_QL_BgEquipMake = self.m_node:FindDirect("Img_QL_BgEquipMake")
                      local Group_QL_Save_Item = Img_QL_BgEquipMake:FindDirect("Group_QL_Save_Item")
                      local Bg_Equip = Group_QL_Save_Item:FindDirect("Img_QL_Save_BgEquipMakeItem0" .. bestIdx)
                      self:onClickObj(Bg_Equip)
                      local toggle = Bg_Equip:GetComponent("UIToggle")
                      toggle.value = true
                      local haveItemNum = ItemModule.Instance():GetItemCountById(itemInfo.itemId)
                      if haveItemNum <= 0 then
                        local Btn_Save_YuanbaoUse = self.m_node:FindDirect("Btn_Save_YuanbaoUse")
                        local uiToggle = Btn_Save_YuanbaoUse:GetComponent("UIToggle")
                        uiToggle.value = true
                        local itemInfo = qilingCfg.qilingItems[bestIdx]
                        if itemInfo then
                          self.mSaveNeedYuanBaoNum = itemid2yuanbao[itemInfo.itemId] or 0
                        end
                      end
                      self:UpdateSaveQiLinBtn()
                    else
                      local itemInfo = qilingCfg.qilingItems[self.curSelectedItemIdx]
                      if itemInfo then
                        self.mSaveNeedYuanBaoNum = itemid2yuanbao[itemInfo.itemId] or 0
                        self:UpdateSaveQiLinBtn()
                      end
                    end
                  end
                  CommonConfirmDlg.ShowConfirm("", str, callback, {})
                end
              end
            end
          end
        end
      end
      return
    end
    if self.mIsWaitingYuanBaoPrice then
      self.mIsWaitingYuanBaoPrice = false
      if uid == self._equipStrenSelected.id and itemid2yuanbao then
        if nil == self.mYuanBaoPriceMap then
          self.mYuanBaoPriceMap = {}
        end
        for k, v in pairs(itemid2yuanbao) do
          self.mYuanBaoPriceMap[k] = v
        end
      end
      self:UpdateQiLingBtn()
    end
  end
end
def.method().UpdateUseYuanBaoNum = function(self)
  local yuanbaoNum = 0
  local qilingItemId = EquipUtils.GetEquipStrenNeedItemId()
  local zhenlingItemId = EquipUtils.GetZhenLingStoneItemId()
  local luckstoneItemId = EquipUtils.GetLuckStoneItemId()
  local haveItemNum = 0
  local needItemNum = 0
  local uiToggle = self.m_node:FindDirect("Btn_YuanbaoUse"):GetComponent("UIToggle")
  local curValue = uiToggle.value
  local strenLevel = EquipUtils.GetEquipStrenLevel(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
  local zhenlingStrenLevel = EquipUtils.GetZhenLingStrenLevel()
  local _, _, _, _, canUseLuckStone = EquipUtils.GetEquipStrenNeedItemInfoAfterSuccess(self._equipStrenSelected.qilinTypeid, strenLevel + 1)
  if curValue and self.mYuanBaoPriceMap and self.mYuanBaoPriceMap[qilingItemId] then
    haveItemNum = ItemModule.Instance():GetItemCountById(qilingItemId)
    needItemNum = self._equipStrenSelected.needItemNum
    if haveItemNum < needItemNum then
      yuanbaoNum = yuanbaoNum + (needItemNum - haveItemNum) * self.mYuanBaoPriceMap[qilingItemId]
    end
  end
  local zhenlingBtnToggle = self.m_node:FindDirect("Img_QL_BgEquipMake/Group_QL_Item/Img_QL_BgEquipMakeItem02/Btn_QL_Use"):GetComponent("UIToggle")
  local zhenlingCurValue = zhenlingBtnToggle.value
  if curValue and strenLevel >= zhenlingStrenLevel and zhenlingCurValue and self.mYuanBaoPriceMap and self.mYuanBaoPriceMap[zhenlingItemId] then
    haveItemNum = ItemModule.Instance():GetItemCountById(zhenlingItemId)
    needItemNum = self._equipStrenSelected.stoneItem
    if haveItemNum < needItemNum then
      yuanbaoNum = yuanbaoNum + (needItemNum - haveItemNum) * self.mYuanBaoPriceMap[zhenlingItemId]
    end
  end
  haveItemNum = ItemModule.Instance():GetItemCountById(luckstoneItemId)
  needItemNum = self.mSelectLuckFuNum
  if curValue and haveItemNum < needItemNum and canUseLuckStone and self.mYuanBaoPriceMap and self.mYuanBaoPriceMap[luckstoneItemId] then
    yuanbaoNum = yuanbaoNum + (needItemNum - haveItemNum) * self.mYuanBaoPriceMap[luckstoneItemId]
  end
  self.mNeedYuanBaoNum = yuanbaoNum
end
def.method("=>", "boolean").CanUseYuanBao = function(self)
  local qilingItemId = EquipUtils.GetEquipStrenNeedItemId()
  local zhenlingItemId = EquipUtils.GetZhenLingStoneItemId()
  local luckstoneItemId = EquipUtils.GetLuckStoneItemId()
  if nil == self._equipStrenSelected then
    return false
  end
  if self._equipStrenSelected.needItemNum > ItemModule.Instance():GetItemCountById(qilingItemId) then
    return true
  end
  local strenLevel = EquipUtils.GetEquipStrenLevel(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
  local zhenlingStrenLevel = EquipUtils.GetZhenLingStrenLevel()
  local _, _, _, _, canUseLuckStone = EquipUtils.GetEquipStrenNeedItemInfoAfterSuccess(self._equipStrenSelected.qilinTypeid, strenLevel + 1)
  local zhenlingBtnToggle = self.m_node:FindDirect("Img_QL_BgEquipMake/Group_QL_Item/Img_QL_BgEquipMakeItem02/Btn_QL_Use"):GetComponent("UIToggle")
  local zhenlingCurValue = zhenlingBtnToggle.value
  if strenLevel >= zhenlingStrenLevel and zhenlingCurValue and self._equipStrenSelected.stoneItem > ItemModule.Instance():GetItemCountById(zhenlingItemId) then
    return true
  end
  if canUseLuckStone and self.mSelectLuckFuNum > ItemModule.Instance():GetItemCountById(luckstoneItemId) then
    return true
  end
  return false
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if id == "Btn_QL_Add" then
    GoToBuySilver(false)
  elseif id == "Btn_QL_Make" then
    self:OnEquipStrenBtnClick()
  elseif id == "Img_QL_BgEquipMakeItem01" then
    self:OnEquipStrenNeedItemClick(clickobj)
  elseif id == "Img_QL_BgEquipMakeItem02" then
    self:ShowTipsEx(self.selectStoneItemId, clickobj, "UIWidget")
  elseif id == "Img_QL_BgEquipMakeItem03" then
    local luckItemId = EquipUtils.GetLuckStoneItemId()
    self:ShowTipsEx(luckItemId, clickobj, "UIWidget")
  elseif id == "Icon_BgEquip" then
    if nil == self._equipStrenSelected then
      return
    end
    local position = clickobj:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local sprite = clickobj:GetComponent("UISprite")
    local item = ItemModule.Instance():GetItemByBagIdAndItemKey(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
    ItemTipsMgr.Instance():ShowTips(item, 0, 0, 0, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), -1)
  elseif string.sub(id, 1, #"Btn_QL_Reduce0") == "Btn_QL_Reduce0" then
    local index = tonumber(string.sub(id, #"Btn_QL_Reduce0" + 1, -1))
    self:UnSelectStrenItemClick(index)
  elseif id == "Btn_UseLucky" then
    self:OnClick2OpenLuckStonePanel()
  elseif id == "Btn_QL_Tips" then
    local tipId = 701609500
    local tipStr = require("Main.Common.TipsHelper").GetHoverTip(tipId)
    local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
    CommonUITipsDlg.Instance():ShowDlg(tipStr, {x = 0, y = 0})
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.PANELNAME, {
      self.m_node.name
    })
  elseif id == "Btn_QL_Use" then
    self:OnClickToUseZhengLinItem()
  elseif id == "Btn_YuanbaoUse" then
    self:OnClickUseYuanbaoBtn()
  elseif id == "Btn_Mode" then
    do
      local equipModule = EquipModule.Instance()
      local function callback(tag)
        if tag == 1 then
          if equipModule.curQiLinMode == QiLinMode.RISK_MODE then
            local p = require("netio.protocol.mzm.gsp.item.CSetQilinModeReq").new(QiLinMode.ACCUMULATION_MODE)
            gmodule.network.sendProtocol(p)
          else
            local p = require("netio.protocol.mzm.gsp.item.CSetQilinModeReq").new(QiLinMode.RISK_MODE)
            gmodule.network.sendProtocol(p)
          end
        end
      end
      if equipModule.curQiLinMode == QiLinMode.ACCUMULATION_MODE then
        CommonConfirmDlg.ShowConfirm("", textRes.Equip[132], callback, nil)
      else
        CommonConfirmDlg.ShowConfirm("", textRes.Equip[131], callback, nil)
      end
    end
  elseif id == "Btn_Save_YuanbaoUse" then
    self:ClickSaveUseYuanbao()
  elseif id == "Btn_QL_Save_Make" then
    self:ClickSaveQilin(clickobj)
  elseif id == "Btn_Save_Help" then
    local tipId = 701609924
    local tipStr = require("Main.Common.TipsHelper").GetHoverTip(tipId)
    local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
    CommonUITipsDlg.Instance():ShowDlg(tipStr, {x = 0, y = 0})
  elseif string.sub(id, 1, #"Img_QL_Save_BgEquipMakeItem0") == "Img_QL_Save_BgEquipMakeItem0" then
    local idx = tonumber(string.sub(id, #"Img_QL_Save_BgEquipMakeItem0" + 1, -1))
    if idx then
      self.curSelectedItemIdx = idx
      self.saveUseItemNum = 0
      self.useYuanbaoQilinNum = 0
      self.mSaveNeedYuanBaoNum = 0
      self:UpdateSaveQiLinBtn()
      self:SetCostItemName()
    end
  elseif string.sub(id, 1, #"Icon_QL_EquipMakeItem0") == "Icon_QL_EquipMakeItem0" then
    local idx = tonumber(string.sub(id, #"Icon_QL_EquipMakeItem0" + 1, -1))
    if idx then
      if self._equipStrenSelected == nil then
        warn("!!!!!!equipStrenSelected is nil")
        return
      end
      local strenLevel = EquipUtils.GetEquipStrenLevel(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
      local qilingCfg = EquipUtils.GetQiLinAccumulateModeCfg(strenLevel + 1)
      if qilingCfg then
        local itemInfo = qilingCfg.qilingItems[idx]
        if itemInfo then
          self:ShowTipsEx(itemInfo.itemId, clickobj, "UIWidget")
        end
      end
    end
  end
end
def.method().OnClickUseYuanbaoBtn = function(self)
  local qlItemId = EquipUtils.GetEquipStrenNeedItemId()
  local zlItemId = EquipUtils.GetZhenLingStoneItemId()
  local luckItemId = EquipUtils.GetLuckStoneItemId()
  local uiToggle = self.m_node:FindDirect("Btn_YuanbaoUse"):GetComponent("UIToggle")
  local curValue = uiToggle.value
  if curValue then
    local canUseYuanbao = self:CanUseYuanBao()
    if canUseYuanbao then
      uiToggle.value = true
      self.mIsWaitingYuanBaoPrice = true
      local p = require("netio.protocol.mzm.gsp.item.CReqItemYuanbaoPriceWithId").new(self._equipStrenSelected.id, {
        qlItemId,
        zlItemId,
        luckItemId
      })
      gmodule.network.sendProtocol(p)
    else
      uiToggle.value = false
      self.mIsWaitingYuanBaoPrice = false
      self.mNeedYuanBaoNum = 0
      self.mYuanBaoPriceMap = nil
      self:UpdateQiLingBtn()
      Toast(textRes.Equip[127])
    end
  else
    self.mIsWaitingYuanBaoPrice = false
    self.mNeedYuanBaoNum = 0
    self.mYuanBaoPriceMap = nil
    self:UpdateQiLingBtn()
  end
end
def.method("userdata", "number").OnClickYuanBaoReplace = function(self, toggleBtn, targetItemId)
  local uiToggle = toggleBtn:GetComponent("UIToggle")
  local curValue = uiToggle.value
  local isQiLing = false
  if targetItemId == EquipUtils.GetEquipStrenNeedItemId() then
    isQiLing = true
  elseif targetItemId == EquipUtils.GetZhenLingStoneItemId() then
    isQiLing = false
  end
  if curValue then
    local haveItemNum = ItemModule.Instance():GetItemCountById(targetItemId)
    local needItemNum = 0
    if isQiLing then
      needItemNum = self._equipStrenSelected.needItemNum
    else
      needItemNum = self._equipStrenSelected.stoneItem
    end
    local itemBase = ItemUtils.GetItemBase(targetItemId)
    if haveItemNum >= needItemNum then
      local str = string.format(textRes.Equip[114], itemBase.name)
      Toast(str)
      uiToggle.value = false
      if self.mYuanBaoPriceMap then
        self.mYuanBaoPriceMap[targetItemId] = nil
      end
      if isQiLing then
        self.mNeedYuanBaoReplaceQiLin = false
      else
        self.mNeedYuanBaoReplaceZhenLin = false
      end
      self:UpdateQiLingBtn()
      return
    end
    local function callback(select, tag)
      if 1 == select then
        self.mIsWaitingYuanBaoPrice = true
        local p = require("netio.protocol.mzm.gsp.item.CReqItemYuanbaoPriceWithId").new(self._equipStrenSelected.id, {targetItemId})
        gmodule.network.sendProtocol(p)
      else
        uiToggle.value = false
      end
    end
    local desc = string.format(textRes.Equip[115], itemBase.name)
    CommonConfirmDlg.ShowConfirm("", desc, callback, nil)
  else
    self.mIsWaitingYuanBaoPrice = false
    if self.mYuanBaoPriceMap then
      self.mYuanBaoPriceMap[targetItemId] = nil
    end
    if isQiLing then
      self.mNeedYuanBaoReplaceQiLin = false
    else
      self.mNeedYuanBaoReplaceZhenLin = false
    end
    self:UpdateQiLingBtn()
  end
end
def.method().OnClick2OpenLuckStonePanel = function(self)
  local qilinglevel = EquipUtils.GetEquipStrenLevel(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
  local qilingMax = EquipUtils.GetQiLingMaxLevel(self._equipStrenSelected.useLevel)
  if qilinglevel >= 50 then
    Toast(textRes.Equip[84])
    return
  end
  local function useCallBack(useluckNum)
    self.mSelectLuckFuNum = useluckNum
    self:CheckZhenlinToggleState()
    self:UpdateYuanBaoToggleState(false)
    self:UpdateQiLingBtn()
    self:UpdateLuckFuInfo()
  end
  local extraRate = self:CalcExtraRate()
  LuckStonePanel.Instance():ShowPanel({
    curUsedNum = self.mSelectLuckFuNum,
    curEquip = self._equipStrenSelected,
    extraRate = extraRate
  }, useCallBack)
end
def.method().ReSetLockStoneInfo = function(self)
  self.mAutoUseYuanBao = false
  self.mSelectLuckFuNum = 0
  self:UpdateQiLingBtn()
end
def.method("boolean").UpdateTiShengLuckBtn = function(self, canUseLuckStone)
  local strenLevel = EquipUtils.GetEquipStrenLevel(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
  local tishengBtn = self.m_node:FindDirect("Img_QL_BgEquipMake/Img_QL_BgSuccess/Btn_Advance")
  if not canUseLuckStone then
    tishengBtn:SetActive(false)
  else
    tishengBtn:SetActive(true)
  end
end
def.method("=>", "boolean").CheckZhenlinToggleState = function(self)
  local curLuckStoneNum = self.mSelectLuckFuNum
  local canUse = true
  local extraRate = self:CalcExtraRate()
  local strenLevel = EquipUtils.GetEquipStrenLevel(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
  local lastQilinRate = self._equipStrenSelected.sucRate + extraRate + EquipUtils.GetSuccessRate(self.selectLuckFuItemId, strenLevel) * curLuckStoneNum
  local baseRate = EquipUtils.GetJiGaoMax()
  local btnToggle = self.m_node:FindDirect("Img_QL_BgEquipMake/Group_QL_Item/Img_QL_BgEquipMakeItem02/Btn_QL_Use"):GetComponent("UIToggle")
  if lastQilinRate >= baseRate then
    btnToggle.value = false
    canUse = false
  end
  local zhenlingLock = self.m_node:FindDirect("Img_QL_BgEquipMake/Group_QL_Item/Img_QL_BgEquipMakeItem02/Img_Lock")
  if btnToggle.value then
    zhenlingLock:SetActive(false)
  else
    zhenlingLock:SetActive(true)
  end
  return canUse
end
def.method().UpdateQiLingBtn = function(self)
  local moneyMake = self.m_node:FindDirect("Img_QL_BgEquipMake/Btn_QL_Make/Group_MoneyMake")
  local Ql_Btn = self.m_node:FindDirect("Img_QL_BgEquipMake/Btn_QL_Make/Label_QL_Make")
  local uiToggle = self.m_node:FindDirect("Btn_YuanbaoUse"):GetComponent("UIToggle")
  self:UpdateYuanBaoToggleState(false)
  self:UpdateUseYuanBaoNum()
  if self.mNeedYuanBaoNum > 0 and uiToggle.value then
    Ql_Btn:SetActive(false)
    moneyMake:SetActive(true)
    local moneyLabel = moneyMake:FindDirect("Label_DZ_MoneyMake"):GetComponent("UILabel")
    moneyLabel:set_text(self.mNeedYuanBaoNum)
  else
    uiToggle.value = false
    self.mNeedYuanBaoNum = 0
    Ql_Btn:SetActive(true)
    moneyMake:SetActive(false)
  end
end
def.method().OnClickToUseZhengLinItem = function(self)
  if nil == self._equipStrenSelected then
    return
  end
  local zhenLingItemId = EquipUtils.GetZhenLingStoneItemId()
  local needZhenlingNum = self._equipStrenSelected.stoneItem
  local haveZhenLingNum = ItemModule.Instance():GetItemCountById(zhenLingItemId)
  local strenLevel = EquipUtils.GetEquipStrenLevel(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
  local zhenlingStrenLevel = EquipUtils.GetZhenLingStrenLevel()
  local btnToggle = self.m_node:FindDirect("Img_QL_BgEquipMake/Group_QL_Item/Img_QL_BgEquipMakeItem02/Btn_QL_Use"):GetComponent("UIToggle")
  local curValue = btnToggle.value
  if strenLevel < zhenlingStrenLevel then
    btnToggle.value = false
    Toast(string.format(textRes.Equip[65], zhenlingStrenLevel))
    return
  end
  local lockView = self.m_node:FindDirect("Img_QL_BgEquipMake/Group_QL_Item/Img_QL_BgEquipMakeItem02/Img_Lock")
  if curValue then
    if not self:CheckZhenlinToggleState() then
      btnToggle.value = false
      Toast(textRes.Equip[97])
      self:UpdateQiLingFailedView(btnToggle.value, strenLevel)
      return
    end
    lockView:SetActive(false)
  else
    lockView:SetActive(true)
  end
  self:UpdateQiLingFailedView(btnToggle.value, strenLevel)
  self:UpdateYuanBaoToggleState(false)
  self:UpdateQiLingBtn()
end
def.method().UpdateZhenLingView = function(self)
end
def.method().OnRefreshView = function(self)
end
def.method("table", "=>", "number").GetCostPerformanceBestIdx = function(self, itemid2yuanbao)
  local strenLevel = EquipUtils.GetEquipStrenLevel(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
  local qilingCfg = EquipUtils.GetQiLinAccumulateModeCfg(strenLevel + 1)
  local itemInfo = qilingCfg.qilingItems[self.curSelectedItemIdx]
  local bestIdx = self.curSelectedItemIdx
  local costPerformance = itemInfo.itemAddScore / itemid2yuanbao[itemInfo.itemId]
  for i, v in ipairs(qilingCfg.qilingItems) do
    local price = itemid2yuanbao[v.itemId]
    if price then
      local costP = v.itemAddScore / price
      local useNum = EquipUtils.GetAccumulateQiLinItemUseNum(self._equipStrenSelected.bagId, self._equipStrenSelected.key, v.itemId)
      if useNum < v.itemNum and costPerformance < costP then
        costPerformance = costP
        bestIdx = i
      end
    end
  end
  return bestIdx
end
def.method().ClickSaveUseYuanbao = function(self)
  if EquipModule.Instance().curQiLinMode == QiLinMode.ACCUMULATION_MODE then
    local Btn_Save_YuanbaoUse = self.m_node:FindDirect("Btn_Save_YuanbaoUse")
    local uiToggle = Btn_Save_YuanbaoUse:GetComponent("UIToggle")
    local curValue = uiToggle.value
    if curValue then
      local strenLevel = EquipUtils.GetEquipStrenLevel(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
      local qilingCfg = EquipUtils.GetQiLinAccumulateModeCfg(strenLevel + 1)
      local itemInfo = qilingCfg.qilingItems[self.curSelectedItemIdx]
      if itemInfo then
        local haveItemNum = ItemModule.Instance():GetItemCountById(itemInfo.itemId)
        if haveItemNum > 0 then
          uiToggle.value = false
          Toast(textRes.Equip[127])
          self:UpdateSaveQiLinBtn()
        else
          local itemIdList = {}
          for i, v in ipairs(qilingCfg.qilingItems) do
            table.insert(itemIdList, v.itemId)
          end
          local p = require("netio.protocol.mzm.gsp.item.CReqItemYuanbaoPriceWithId").new(self._equipStrenSelected.id, itemIdList)
          gmodule.network.sendProtocol(p)
        end
      end
    else
      self:UpdateSaveQiLinBtn()
    end
    return
  end
end
def.method().UpdateSaveQiLinBtn = function(self)
  local Btn_Save_YuanbaoUse = self.m_node:FindDirect("Btn_Save_YuanbaoUse")
  local uiToggle = Btn_Save_YuanbaoUse:GetComponent("UIToggle")
  local Btn_QL_Save_Make = self.m_node:FindDirect("Img_QL_BgEquipMake/Btn_QL_Save_Make")
  local Label_QL_Make = Btn_QL_Save_Make:FindDirect("Label_QL_Make")
  local Group_MoneyMake = Btn_QL_Save_Make:FindDirect("Group_MoneyMake")
  if uiToggle.value and self.mSaveNeedYuanBaoNum > 0 then
    Label_QL_Make:SetActive(false)
    Group_MoneyMake:SetActive(true)
    uiToggle.value = true
    local Label_DZ_MoneyMake = Group_MoneyMake:FindDirect("Label_DZ_MoneyMake")
    Label_DZ_MoneyMake:GetComponent("UILabel"):set_text(self.mSaveNeedYuanBaoNum)
  else
    uiToggle.value = false
    self.mSaveNeedYuanBaoNum = 0
    Label_QL_Make:SetActive(true)
    Group_MoneyMake:SetActive(false)
  end
end
def.method("userdata").ClickSaveQilin = function(self, clickobj)
  if self._equipStrenSelected == nil then
    return
  end
  local equip = ItemModule.Instance():GetItemByBagIdAndItemKey(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
  if equip == nil then
    return
  end
  local function startSaveQiLing(id)
    if id == 1 then
      do
        local strenLevel = EquipUtils.GetEquipStrenLevel(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
        local qilingCfg = EquipUtils.GetQiLinAccumulateModeCfg(strenLevel + 1)
        local itemInfo = qilingCfg.qilingItems[self.curSelectedItemIdx]
        if itemInfo == nil then
          warn("-------no Accumulation qilin indx:", self.curSelectedItemIdx)
          return
        end
        local useNum = EquipUtils.GetAccumulateQiLinItemUseNum(self._equipStrenSelected.bagId, self._equipStrenSelected.key, itemInfo.itemId)
        if useNum >= itemInfo.itemNum then
          Toast(textRes.Equip[203])
          return
        end
        local Btn_Save_YuanbaoUse = self.m_node:FindDirect("Btn_Save_YuanbaoUse")
        local uiToggle = Btn_Save_YuanbaoUse:GetComponent("UIToggle")
        local itemBase = ItemUtils.GetItemBase(itemInfo.itemId)
        if uiToggle.value then
          do
            local allYuanBao = ItemModule.Instance():GetAllYuanBao()
            local ownYuanbao = Int64.ToNumber(allYuanBao)
            if ownYuanbao >= self.mSaveNeedYuanBaoNum then
              self.lastStrenLv = strenLevel
              do
                local num = 1
                local function yuanbaoCallback(id)
                  if id == 1 then
                    self.saveAddScore = itemInfo.itemAddScore * num
                    local p = require("netio.protocol.mzm.gsp.item.CEquipQiLinUseYuanbaoReq").new(self._equipStrenSelected.bagId, self._equipStrenSelected.key, itemInfo.itemId, num, self.mSaveNeedYuanBaoNum, allYuanBao)
                    gmodule.network.sendProtocol(p)
                  end
                end
                if self.useYuanbaoQilinNum >= 3 then
                  local curScore = EquipUtils.GetAccumulateQilinEquipScore(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
                  local useNum = EquipUtils.GetAccumulateQiLinItemUseNum(self._equipStrenSelected.bagId, self._equipStrenSelected.key, itemInfo.itemId)
                  local lefeUseNum = itemInfo.itemNum - useNum
                  local leftScore = qilingCfg.needScore - curScore
                  local levelUpNum = math.ceil(leftScore / itemInfo.itemAddScore)
                  local buyNum = math.floor(ownYuanbao / self.mSaveNeedYuanBaoNum)
                  num = math.min(lefeUseNum, levelUpNum, buyNum)
                  warn("-----yuanbaoqiling ----:", num, lefeUseNum, levelUpNum, buyNum)
                  if num > 1 then
                    local content = string.format(textRes.Equip[209], self.mSaveNeedYuanBaoNum * num, num, itemBase.name)
                    CommonConfirmDlg.ShowConfirm("", content, yuanbaoCallback, nil)
                    self.useYuanbaoQilinNum = 0
                  else
                    yuanbaoCallback(1)
                  end
                else
                  self.useYuanbaoQilinNum = self.useYuanbaoQilinNum + 1
                  yuanbaoCallback(1)
                end
              end
            else
              _G.GotoBuyYuanbao()
            end
          end
        else
          if self.isShowConfirm then
            warn("!!!!!! can not use item , please wait")
            return
          end
          local haveItemNum = ItemModule.Instance():GetItemCountById(itemInfo.itemId)
          if haveItemNum > 0 then
            do
              local costNum = 1
              local function callback(id)
                self.isShowConfirm = false
                if id == 1 then
                  self.lastStrenLv = strenLevel
                  self.saveAddScore = itemInfo.itemAddScore * costNum
                  local p = require("netio.protocol.mzm.gsp.item.CEquipQiLinUseItemReq").new(self._equipStrenSelected.bagId, self._equipStrenSelected.key, itemInfo.itemId, costNum)
                  gmodule.network.sendProtocol(p)
                end
              end
              if 3 <= self.saveUseItemNum then
                local curScore = EquipUtils.GetAccumulateQilinEquipScore(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
                local leftScore = qilingCfg.needScore - curScore
                local levelUpNum = math.ceil(leftScore / itemInfo.itemAddScore)
                costNum = math.min(haveItemNum, levelUpNum, itemInfo.itemNum - useNum)
                warn("------all userNum:", haveItemNum, itemInfo.itemNum - useNum, levelUpNum, costNum)
                CommonConfirmDlg.ShowConfirm("", textRes.Equip[207], callback, nil)
                self.saveUseItemNum = 0
                self.isShowConfirm = true
              else
                self.saveUseItemNum = self.saveUseItemNum + 1
                callback(1)
              end
            end
          else
            self:ShowTips(itemInfo.itemId, clickobj)
            Toast(string.format(textRes.Equip[202], itemBase.name))
          end
        end
      end
    end
  end
  local flag = equip.flag
  if require("netio.protocol.mzm.gsp.item.ItemInfo").BIND ~= flag then
    local tag = {id = self}
    local content = textRes.Equip[11] .. textRes.Equip[20] .. textRes.Equip[11] .. textRes.Equip[9]
    CommonConfirmDlg.ShowConfirm(textRes.Equip[29], content, startSaveQiLing, tag)
  else
    startSaveQiLing(1)
  end
end
def.method().SwitchQiLingMode = function(self)
  if self._equipStrenSelected == nil then
    return
  end
  local Img_QL_BgEquipMake = self.m_node:FindDirect("Img_QL_BgEquipMake")
  local Img_QL_BgHaveMoney = Img_QL_BgEquipMake:FindDirect("Img_QL_BgHaveMoney")
  local Img_QL_BgUseMoney = Img_QL_BgEquipMake:FindDirect("Img_QL_BgUseMoney")
  local Img_QL_BgSuccess = Img_QL_BgEquipMake:FindDirect("Img_QL_BgSuccess")
  local Group_QL_Item = Img_QL_BgEquipMake:FindDirect("Group_QL_Item")
  local Btn_QL_Add = Img_QL_BgEquipMake:FindDirect("Btn_QL_Add")
  local Btn_QL_Tips = self.m_node:FindDirect("Img_QL_BgEquipPreview/Btn_QL_Tips")
  local Btn_YuanbaoUse = self.m_node:FindDirect("Btn_YuanbaoUse")
  local Btn_QL_Make = Img_QL_BgEquipMake:FindDirect("Btn_QL_Make")
  local Group_QL_Save_Item = Img_QL_BgEquipMake:FindDirect("Group_QL_Save_Item")
  local Img_QL_Save_BgSuccess = Img_QL_BgEquipMake:FindDirect("Img_QL_Save_BgSuccess")
  local Slider_QL_Save_Points = Img_QL_BgEquipMake:FindDirect("Slider_QL_Save_Points")
  local Label_QL_Save_Tips = Img_QL_BgEquipMake:FindDirect("Label_QL_Save_Tips")
  local Btn_Save_YuanbaoUse = self.m_node:FindDirect("Btn_Save_YuanbaoUse")
  local Btn_QL_Save_Make = Img_QL_BgEquipMake:FindDirect("Btn_QL_Save_Make")
  local Btn_Mode = self.m_node:FindDirect("Btn_Mode")
  local Label_Adv = self.m_node:FindDirect("Btn_Mode/Label_Adv")
  local Label_Save = self.m_node:FindDirect("Btn_Mode/Label_Save")
  local equipModule = EquipModule.Instance()
  if IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_QILIN_ACCUMULATION_MODE) then
    Btn_Mode:SetActive(true)
  else
    Btn_Mode:SetActive(false)
    equipModule.curQiLinMode = QiLinMode.RISK_MODE
  end
  if equipModule.curQiLinMode == QiLinMode.ACCUMULATION_MODE then
    Label_Adv:SetActive(false)
    Label_Save:SetActive(true)
    Img_QL_BgHaveMoney:SetActive(false)
    Img_QL_BgUseMoney:SetActive(false)
    Img_QL_BgSuccess:SetActive(false)
    Group_QL_Item:SetActive(false)
    Btn_QL_Add:SetActive(false)
    Btn_QL_Tips:SetActive(false)
    Btn_YuanbaoUse:SetActive(false)
    Btn_QL_Make:SetActive(false)
    Group_QL_Save_Item:SetActive(true)
    Img_QL_Save_BgSuccess:SetActive(true)
    Slider_QL_Save_Points:SetActive(true)
    Label_QL_Save_Tips:SetActive(true)
    Btn_Save_YuanbaoUse:SetActive(true)
    Btn_QL_Save_Make:SetActive(true)
    self.mSaveNeedYuanBaoNum = 0
    self:SetSaveEquipInfo()
    self:UpdateSaveQiLinBtn()
  else
    Label_Adv:SetActive(true)
    Label_Save:SetActive(false)
    Img_QL_BgHaveMoney:SetActive(true)
    Img_QL_BgUseMoney:SetActive(true)
    Img_QL_BgSuccess:SetActive(true)
    Group_QL_Item:SetActive(true)
    Btn_QL_Add:SetActive(true)
    Btn_QL_Tips:SetActive(true)
    Btn_YuanbaoUse:SetActive(true)
    Btn_QL_Make:SetActive(true)
    Group_QL_Save_Item:SetActive(false)
    Img_QL_Save_BgSuccess:SetActive(false)
    Slider_QL_Save_Points:SetActive(false)
    Label_QL_Save_Tips:SetActive(false)
    Btn_Save_YuanbaoUse:SetActive(false)
    Btn_QL_Save_Make:SetActive(false)
    self:FillEquipStrenFrame()
  end
end
def.method().SetSaveEquipInfo = function(self)
  if self._equipStrenSelected == nil then
    warn("!!!!!!equipStrenSelected is nil")
    return
  end
  self:UpdateEquipAttrView()
  local strenLevel = EquipUtils.GetEquipStrenLevel(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
  local maxStrenLevel = EquipUtils.GetQiLingMaxLevel(self._equipStrenSelected.useLevel)
  if strenLevel >= 50 then
    self:ShowStrenMaxView(true)
    self:FillMaxLevelView()
    return
  end
  self:ShowStrenMaxView(false)
  local qilingCfg = EquipUtils.GetQiLinAccumulateModeCfg(strenLevel + 1)
  if qilingCfg == nil then
    return
  end
  local equipItem = ItemModule.Instance():GetItemByBagIdAndItemKey(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
  local curScore = EquipUtils.GetAccumulateQilinEquipScore(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
  local needScore = qilingCfg.needScore
  local Img_QL_BgEquipMake = self.m_node:FindDirect("Img_QL_BgEquipMake")
  local Slider_QL_Save_Points = Img_QL_BgEquipMake:FindDirect("Slider_QL_Save_Points")
  local Label_Slider = Slider_QL_Save_Points:FindDirect("Label_Slider")
  Label_Slider:GetComponent("UILabel"):set_text(curScore .. "/" .. needScore)
  Slider_QL_Save_Points:GetComponent("UISlider").value = curScore / needScore
  local Group_QL_Save_Item = Img_QL_BgEquipMake:FindDirect("Group_QL_Save_Item")
  for i = 1, 3 do
    local Bg_Equip = Group_QL_Save_Item:FindDirect("Img_QL_Save_BgEquipMakeItem0" .. i)
    local itemInfo = qilingCfg.qilingItems[i]
    local toggle = Bg_Equip:GetComponent("UIToggle")
    if i == self.curSelectedItemIdx then
      toggle.value = true
    else
      toggle.value = false
    end
    if itemInfo then
      Bg_Equip:SetActive(true)
      local itemBase = ItemUtils.GetItemBase(itemInfo.itemId)
      local Icon_Item = Bg_Equip:FindDirect("Icon_QL_EquipMakeItem0" .. i)
      local Icon_Texture = Icon_Item:GetComponent("UITexture")
      GUIUtils.FillIcon(Icon_Texture, itemBase.icon)
      local haveItemNum = ItemModule.Instance():GetItemCountById(itemInfo.itemId)
      local Label_Item = Bg_Equip:FindDirect("Label_QL_EquipMakeItem0" .. i)
      Label_Item:GetComponent("UILabel"):set_text(haveItemNum)
      local point = itemInfo.itemAddScore
      local Label_ItemName = Bg_Equip:FindDirect("Label_QL_EquipMakeName0" .. i)
      Label_ItemName:GetComponent("UILabel"):set_text(itemBase.name .. string.format(textRes.Equip[200], point))
      local Label_Point = Bg_Equip:FindDirect("Label_QL_EquipMakePoints0" .. i)
      Label_Point:GetComponent("UILabel"):set_text("")
      local useNum = EquipUtils.GetAccumulateQiLinItemUseNum(self._equipStrenSelected.bagId, self._equipStrenSelected.key, itemInfo.itemId)
      local leftNum = itemInfo.itemNum - useNum
      local Label_Left = Bg_Equip:FindDirect("Label_QL_EquipMakeRestNum0" .. i)
      Label_Left:GetComponent("UILabel"):set_text(string.format(textRes.Equip[201], leftNum))
    else
      Bg_Equip:SetActive(false)
    end
  end
  local grid = Group_QL_Save_Item:GetComponent("UIGrid")
  GameUtil.AddGlobalLateTimer(0, true, function()
    grid:Reposition()
  end)
  self:SetCostItemName()
end
def.method().SetCostItemName = function(self)
  if self._equipStrenSelected == nil then
    return
  end
  local strenLevel = EquipUtils.GetEquipStrenLevel(self._equipStrenSelected.bagId, self._equipStrenSelected.key)
  local qilingCfg = EquipUtils.GetQiLinAccumulateModeCfg(strenLevel + 1)
  if qilingCfg == nil then
    return
  end
  local itemInfo = qilingCfg.qilingItems[self.curSelectedItemIdx]
  if itemInfo then
    local itemBase = ItemUtils.GetItemBase(itemInfo.itemId)
    local Img_QL_BgEquipMake = self.m_node:FindDirect("Img_QL_BgEquipMake")
    local Label_QL_BgSuccess = Img_QL_BgEquipMake:FindDirect("Img_QL_Save_BgSuccess/Label_QL_BgSuccess")
    Label_QL_BgSuccess:GetComponent("UILabel"):set_text(itemBase.name)
  end
end
EquipStrenNode.Commit()
return EquipStrenNode

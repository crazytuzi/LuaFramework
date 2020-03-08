local Lplus = require("Lplus")
local GodWeaponTabNode = require("Main.GodWeapon.ui.GodWeaponTabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local JewelNode = Lplus.Extend(GodWeaponTabNode, "JewelNode")
local def = JewelNode.define
local instance
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local JewelUtils = require("Main.GodWeapon.Jewel.JewelUtils")
local JewelMgr = require("Main.GodWeapon.JewelMgr")
local JewelData = require("Main.GodWeapon.Jewel.data.JewelData")
local BreakOutData = require("Main.GodWeapon.BreakOut.data.BreakOutData")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local JewelProtocols = require("Main.GodWeapon.Jewel.JewelProtocols")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local txtConst = textRes.GodWeapon.Jewel
def.field("table")._uiGOs = nil
def.field("table")._uiStatus = nil
def.field("table")._equilList = nil
def.field("table")._tblJewel = nil
def.field("table")._slotItem = nil
def.field("table")._arrOpendStage = nil
def.field("boolean")._bFirstShow = true
def.const("number").MAX_EMBEDED_NUM = 4
def.static("=>", JewelNode).Instance = function()
  if instance == nil then
    instance = JewelNode()
  end
  return instance
end
def.override().OnShow = function(self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_GodWeapon_Bag_Change, JewelNode.OnJewelBagChange, self)
  self:InitUI()
end
def.method().InitUI = function(self)
  self._uiGOs = {}
  self._uiStatus = {}
  self._uiStatus.Ocp = 0
  self._uiStatus.selEquip = 1
  self._uiStatus.selSlotIdx = 0
  self._uiStatus.selEmbedSlotIdx = 0
  self._uiStatus.opendSlotNum = 0
  self._uiGOs.groupJewel = self.m_panel:FindDirect("Img_Bg/Group_BS/Group_Baoshi")
  self._uiGOs.ImgEquipment = self.m_panel:FindDirect("Img_Bg/Group_BS/Img_BgEquip")
  self._uiGOs.groupEquipments = self.m_panel:FindDirect("Img_Bg/Group_EquipList")
  self._uiGOs.groupJewelList = self.m_panel:FindDirect("Img_Bg/Group_EquipList/Group_LongJingList")
  self._uiGOs.lblNodata = self.m_panel:FindDirect("Img_Bg/Group_NoData/Img_Talk/Label_Ex")
  local btnBagLbl = self.m_panel:FindDirect("Img_Bg/Group_BS/Btn_SelfBS/Label")
  GUIUtils.SetText(btnBagLbl, txtConst[22])
  self._uiGOs.groupJewelList:SetActive(false)
  self:UpdateUI()
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_GodWeapon_Bag_Change, JewelNode.OnJewelBagChange)
  if self._uiGOs ~= nil and not self._uiGOs.groupEquipments.isnil then
    self:OnBtnBackClick()
    self._uiGOs.lblNodata:SetActive(false)
  end
  self._uiStatus = nil
  self._uiGOs = nil
  self._equilList = nil
  self._tblJewel = nil
  self._slotItem = nil
  self._arrOpendStage = nil
  self._bFirstShow = true
end
def.method().UpdateUI = function(self)
  local myEquipList = JewelMgr.GetData():GetHeroGodWeapons() or {}
  self._equilList = myEquipList
  local groupBs = self.m_panel:FindDirect("Img_Bg/Group_BS")
  local groupNoData = self.m_panel:FindDirect("Img_Bg/Group_NoData")
  self:_getArrStages()
  local bHasNoEquips = self._equilList == nil or #self._equilList < 1
  if bHasNoEquips then
    self._uiGOs.lblNodata:SetActive(true)
    GUIUtils.SetText(self._uiGOs.lblNodata, txtConst[33]:format(self._arrOpendStage[1]))
  end
  groupNoData:SetActive(bHasNoEquips)
  groupBs:SetActive(not bHasNoEquips)
  if bHasNoEquips then
    return
  end
  if self._uiGOs.groupJewelList:get_activeSelf() then
    self:Update2EmbedJewelList()
  else
    self:UpdateUILeftList()
  end
  self:UpdateUIRight()
end
def.method().UpdateUILeftList = function(self)
  self._uiStatus.selEquip = self._uiStatus.selEquip or 1
  local myEquipList = self._equilList
  self.m_base:ShowEquipList(myEquipList)
  if #myEquipList > 0 then
    self.m_base:SelectEquipByIdx(self._uiStatus.selEquip)
  end
end
def.method()._getArrStages = function(self)
  if self._arrOpendStage == nil then
    self._arrOpendStage = {}
    local stagesCfg = BreakOutData.Instance():_GetStageCfgs()
    local arrStage = {}
    for iStage, stageCfg in pairs(stagesCfg) do
      table.insert(arrStage, stageCfg)
    end
    table.sort(arrStage, function(a, b)
      return a.stage < b.stage
    end)
    if arrStage[1].gemSlotNum > 0 then
      table.insert(self._arrOpendStage, 1)
    end
    for i = 2, #arrStage do
      local stageCfg = arrStage[i]
      if stageCfg.gemSlotNum ~= 0 and arrStage[i - 1].gemSlotNum ~= stageCfg.gemSlotNum then
        if #self._arrOpendStage > JewelNode.MAX_EMBEDED_NUM then
          break
        else
          table.insert(self._arrOpendStage, i)
        end
      end
    end
    for i = #self._arrOpendStage + 1, JewelNode.MAX_EMBEDED_NUM do
      table.insert(self._arrOpendStage, i)
    end
  end
end
def.method().UpdateUIRight = function(self)
  local selEquip = self._uiStatus.selEquip or 1
  local ctrlEquipRoot = self._uiGOs.ImgEquipment
  local icon = ctrlEquipRoot:FindDirect("Icon_Equip")
  local selEquipInfo = self._equilList and self._equilList[selEquip] or nil
  if selEquipInfo ~= nil then
    GUIUtils.SetTexture(icon, selEquipInfo.icon)
  else
    GUIUtils.SetTexture(icon, 0)
  end
  self:_getArrStages()
  local stageCfg
  stageCfg = BreakOutData.Instance():GetStageCfg(selEquipInfo and selEquipInfo.godWeaponStage or 1)
  self._uiStatus.stageCfg = stageCfg
  local openedSlotNum = 0
  if stageCfg ~= nil then
    openedSlotNum = stageCfg.gemSlotNum
  end
  local breakOutData = require("Main.GodWeapon.BreakOut.data.BreakOutData").Instance()
  for i = 1, JewelNode.MAX_EMBEDED_NUM do
    local ctrlSlot = self._uiGOs.groupJewel:FindDirect("Img_BgBs" .. i)
    local ctrlJewelRoot = ctrlSlot:GetChild(0)
    local ctrlLockRoot = ctrlSlot:FindDirect("State2lock")
    local ctrlToEmbedRoot = ctrlSlot:FindDirect("State3WaitEquip")
    local imgGreenUp = ctrlSlot:FindDirect("Img_ArrowGreen")
    local openedStage = self._arrOpendStage[i]
    if openedStage <= stageCfg.stage then
      openedSlotNum = openedSlotNum + 1
      local jewelId = (not selEquipInfo.jewelMap[i] or not selEquipInfo.jewelMap[i].jewelCfgId) and 0
      local bEmbed = false
      if jewelId > 0 then
        bEmbed = true
      end
      ctrlLockRoot:SetActive(false)
      ctrlJewelRoot:SetActive(bEmbed)
      ctrlToEmbedRoot:SetActive(not bEmbed)
      local numJewleToEmbed = #(JewelMgr.GetData():GetBagJewelsByEquipType(selEquipInfo.wearPos) or {})
      imgGreenUp:SetActive(not bEmbed and numJewleToEmbed > 0)
      if bEmbed then
        local jewelBasic = JewelUtils.GetJewelItemByItemId(jewelId, false)
        local itemBase = ItemUtils.GetItemBase(jewelId)
        local imgLvUp = ctrlJewelRoot:FindDirect("Img_UpRedDot")
        local lblName = ctrlJewelRoot:FindDirect("Label_NameBS")
        local lblProp = ctrlJewelRoot:FindDirect("Label_AbilityBS")
        local bCanLvUp = JewelMgr.CanJewelLvUp(selEquipInfo, i)
        imgLvUp:SetActive(bCanLvUp and jewelBasic.level < stageCfg.maxGemLevel)
        lblName:SetActive(true)
        GUIUtils.SetText(lblName, itemBase.name)
        GUIUtils.SetTexture(ctrlJewelRoot, itemBase.icon)
        local bHasProp = 0 < #jewelBasic.arrProps
        if bHasProp then
          local propKey = JewelUtils.GetKeyByPrpArrTbl(jewelBasic.arrProps)
          local propName = JewelUtils.GetUniqNameByPropKey(propKey)
          GUIUtils.SetText(lblProp, propName)
        end
        ctrlJewelRoot.name = "State1Bs_" .. i .. "_" .. jewelId
      end
    else
      imgGreenUp:SetActive(false)
      ctrlLockRoot:SetActive(true)
      local lblCondi = ctrlLockRoot:FindDirect("Label")
      GUIUtils.SetText(lblCondi, txtConst[1]:format(openedStage))
      ctrlToEmbedRoot:SetActive(false)
      ctrlJewelRoot:SetActive(false)
    end
  end
  self._uiStatus.openedSlotNum = openedSlotNum
end
def.method("=>", "table").GetJewelsByEquipType = function(self)
  local equipInfo
  if self._equilList and self._uiStatus.selEquip > 0 then
    equipInfo = self._equilList[self._uiStatus.selEquip]
  end
  if equipInfo ~= nil then
    local oneLvJewels = JewelUtils.GetJewelsBasicCfgByEquipType(equipInfo.wearPos, 1)
    local tblJewels = {}
    for _, jewel in ipairs(oneLvJewels) do
      tblJewels[jewel.type] = tblJewels[jewel.type] or {}
      table.insert(tblJewels[jewel.type], jewel)
    end
    local ownJewels = JewelMgr.GetData():GetBagJewelsByEquipType(equipInfo.wearPos) or {}
    local breakOutData = require("Main.GodWeapon.BreakOut.data.BreakOutData").Instance()
    local stageCfg = breakOutData:GetStageCfg(equipInfo.godWeaponStage and equipInfo.godWeaponStage or 1)
    for _, item in ipairs(ownJewels) do
      if tblJewels[equipInfo.wearPos] ~= nil and item.level <= stageCfg.maxGemLevel then
        table.insert(tblJewels[equipInfo.wearPos], item)
      end
    end
    return tblJewels
  end
  return {}
end
def.method("boolean", "table").ShowUIJewelsList = function(self, bShow, tblJewels)
  local ctrlRoot = self._uiGOs.groupJewelList
  local lblListTitle = self._uiGOs.groupEquipments:FindDirect("Img_TBg/Label")
  self._uiGOs.groupEquipments:FindDirect("Group_EquipList"):SetActive(not bShow)
  if not bShow then
    ctrlRoot:SetActive(false)
    GUIUtils.SetText(lblListTitle, txtConst[21])
    return
  end
  local equipInfo = self._equilList[self._uiStatus.selEquip]
  GUIUtils.SetText(lblListTitle, equipInfo and textRes.Item[equipInfo.wearPos + 10000] or "")
  ctrlRoot:SetActive(true)
  local ctrlScrollView = ctrlRoot:FindDirect("Group_List/Scroll View")
  local ctrlUIList = ctrlScrollView:FindDirect("Table_BugList")
  self._uiGOs.ctrlUIList = ctrlUIList
  local typeNum = 0
  local arrJewelTypes = {}
  local tmpMapJewels = {}
  for _, jewelItem in pairs(tblJewels[equipInfo.wearPos]) do
    tmpMapJewels[jewelItem.typeId] = tmpMapJewels[jewelItem.typeId] or {}
    table.insert(tmpMapJewels[jewelItem.typeId], jewelItem)
  end
  for typeId, jewelList in pairs(tmpMapJewels) do
    table.sort(jewelList, function(a, b)
      if a.level < b.level then
        return true
      else
        return false
      end
    end)
    table.insert(arrJewelTypes, jewelList)
  end
  table.sort(arrJewelTypes, function(a, b)
    if a[1].typeId < b[1].typeId then
      return true
    else
      return false
    end
  end)
  typeNum = #arrJewelTypes
  self._uiStatus.arrJewelTypes = arrJewelTypes
  local ctrlJewelTypeList = GUIUtils.InitUIList(ctrlUIList, typeNum)
  for i = 1, typeNum do
    local ctrl = ctrlJewelTypeList[i]
    local typeTitleObj = ctrl:FindDirect("Img_BgBuyList_" .. i)
    local lblTypeName = typeTitleObj:FindDirect("Label_" .. i)
    local jewels = arrJewelTypes[i] or {}
    local itemBase = ItemUtils.GetItemBase(jewels[1].itemId)
    GUIUtils.SetText(lblTypeName, itemBase and string.gsub(itemBase.name, "%d+...", "") or "")
    local numJewels = #jewels
    local ctrlJUIList = ctrl:FindDirect("tween_" .. i)
    ctrlJUIList:SetActive(true)
    local ctrlJewelList = GUIUtils.InitUIList(ctrlJUIList, numJewels)
    for j = 1, #ctrlJewelList do
      local jewel = jewels[j]
      local ctrlJewel = ctrlJewelList[j]
      if j == 1 then
        self:FillFirstJewelInfo(ctrlJewel, jewel.itemId, i)
      else
        self:FillJewelItemInfo(ctrlJewel, jewel, i, j)
      end
    end
    typeTitleObj:GetComponent("UIPlayTween").enabled = false
    if self._bFirstShow then
      ctrlJUIList:SetActive(false)
    end
  end
  self._bFirstShow = false
  GUIUtils.Reposition(ctrlUIList, "UIList", 0.01)
end
def.method("userdata", "number", "number").FillFirstJewelInfo = function(self, ctrl, itemId, idx)
  local lblName = ctrl:FindDirect("Label_Name_" .. idx .. "_1")
  local lblProp = ctrl:FindDirect("Label_Attribute_" .. idx .. "_1")
  local iconRoot = ctrl:FindDirect("Group_Icon_" .. idx .. "_1")
  local lblNum = iconRoot:FindDirect("Icon_BgEquip01_" .. idx .. "_1/Label_" .. idx .. "_1")
  local imgAdd = iconRoot:GetChild(2)
  local icon = iconRoot:GetChild(0)
  imgAdd.name = "Img_Add_" .. itemId
  GUIUtils.SetText(lblName, txtConst[20])
  GUIUtils.SetText(lblProp, "")
  icon:SetActive(false)
  imgAdd:SetActive(true)
  lblNum:SetActive(false)
end
def.method("userdata", "table", "number", "number").FillJewelItemInfo = function(self, ctrl, jewelItem, i, j)
  local lblName = ctrl:FindDirect("Label_Name_" .. i .. "_" .. j)
  local lblProp = ctrl:FindDirect("Label_Attribute_" .. i .. "_" .. j)
  local iconRoot = ctrl:FindDirect("Group_Icon_" .. i .. "_" .. j)
  local lblNum = iconRoot:FindDirect("Icon_BgEquip01_" .. i .. "_" .. j .. "/Label_" .. i .. "_" .. j)
  local imgAdd = iconRoot:GetChild(2)
  local icon = iconRoot:GetChild(0)
  imgAdd:SetActive(false)
  icon:SetActive(true)
  lblNum:SetActive(true)
  local itemBase = ItemUtils.GetItemBase(jewelItem.itemId)
  local jewelItemCfg = JewelUtils.GetJewelItemByItemId(jewelItem.itemId, false)
  if itemBase and jewelItem then
    GUIUtils.SetText(lblName, itemBase.name)
    local propKey = JewelUtils.GetKeyByPrpArrTbl(jewelItemCfg.arrProps)
    local propName = JewelUtils.GetUniqNameByPropKey(propKey)
    GUIUtils.SetText(lblProp, propName)
    GUIUtils.SetTexture(icon, itemBase.icon)
    GUIUtils.SetText(lblNum, jewelItem.number or "")
  else
    warn("[FillJewelItemInfo error, itemBase]", itemBase, " jewelItem", jewelItemCfg)
    GUIUtils.SetText(lblName, "")
    GUIUtils.SetText(lblProp, "")
    GUIUtils.SetTexture(icon, 0)
  end
end
def.override("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_HelpInfor" then
    GUIUtils.ShowHoverTip(constant.CSuperEquipmentConsts.GEM_HOVER_TIP_ID, 0, 0)
  elseif id == "Btn_SelfBS" then
    self:OnClickBtnOpenBag()
  elseif id == "State3WaitEquip" then
    local parantName = clickObj.parent.name
    local slotIdx = tonumber(string.sub(parantName, #"Img_BgBs" + 1))
    warn("slotIdx", slotIdx)
    self:OnClickSlot(slotIdx)
  elseif id == "Btn_Back" then
    self:OnBtnBackClick()
  elseif id == "Img_BgEquip" then
    self:ShowEquipTips(clickObj)
  elseif string.find(id, "Img_Add_") then
    local strs = string.split(id, "_")
    local itemId = tonumber(strs[3])
    self:ShowBasicTips(itemId, clickObj)
  elseif string.find(id, "Group_LJItem_") then
    local strs = string.split(id, "_")
    local i, j = tonumber(strs[3]), tonumber(strs[4])
    warn("i", i, j)
    if j > 1 then
      self:OnMountItemClick(i, j)
    end
  elseif string.find(id, "State1Bs_") then
    local strs = string.split(id, "_")
    local slotIdx = tonumber(strs[2])
    self._uiStatus.selEmbedSlotIdx = slotIdx
    local itemId = tonumber(strs[3] or 0)
    if itemId > 0 then
      self:ShowMountTips(clickObj, itemId)
      self:OnClickSlot(slotIdx)
    end
  elseif id == "Btn_MakeOrg" then
    self:OnBtn_MakeOrgClick(clickObj)
  elseif id == "Btn_MakeHigher" then
    self:OnBtn_MakeHigherClick(clickObj)
  elseif string.find(id, "Img_BgBuyList_") then
    self:OnClickStretchJewelList(clickObj)
  end
end
def.override("number", "userdata", "table").OnEquipSelected = function(self, idx, clickObj, equipInfo)
  self._bFirstShow = true
  if self._uiStatus.selEquip == idx then
    return
  end
  self._uiStatus.selEquip = idx
  self:UpdateUIRight()
end
def.method().OnClickBtnOpenBag = function(self)
  local selEquipInfo = self:GetSelEquipInfo()
  local occupId = _G.GetHeroProp().occupation
  local jewelTypeId = JewelUtils.GetDefaultShowJewelType(occupId, selEquipInfo.wearPos)
  local matchJewels = JewelUtils.GetJewelsBasicCfgByEquipType(selEquipInfo.wearPos, 1)
  local mathedJewel
  for i = 1, #matchJewels do
    if matchJewels[i].typeId == jewelTypeId then
      mathedJewel = matchJewels[i]
    end
  end
  local uiJewelBag = require("Main.GodWeapon.ui.UIJewelBag").Instance()
  if mathedJewel == nil then
    uiJewelBag:ShowPanel()
  else
    local params = {
      itemId = mathedJewel.itemId
    }
    uiJewelBag:ShowWithParams(params)
  end
end
def.method("number").OnClickSlot = function(self, idx)
  if self._uiStatus.selSlotIdx == idx then
    return
  end
  self._uiStatus.selSlotIdx = idx
  local tbl = self:GetJewelsByEquipType()
  self._tblJewel = tbl
  self:ShowUIJewelsList(true, tbl)
end
def.method().OnBtnBackClick = function(self)
  self._uiGOs.groupEquipments:FindDirect("Group_EquipList"):SetActive(true)
  self._uiGOs.groupJewelList:SetActive(false)
  self._uiStatus.selSlotIdx = 0
  self._tblJewel = nil
  local lblName = self._uiGOs.groupEquipments:FindDirect("Img_TBg/Label")
  GUIUtils.SetText(lblName, txtConst[21])
end
def.method("number", "number").OnMountItemClick = function(self, i, j)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local selEquipInfo = self:GetSelEquipInfo()
  local slotIdx = self._uiStatus.selSlotIdx
  if selEquipInfo ~= nil and self._tblJewel ~= nil then
    if slotIdx > 0 then
      do
        local jewelItem = self._uiStatus.arrJewelTypes[i][j]
        local wearJewel = selEquipInfo.jewelMap[slotIdx]
        self._uiStatus.wearJewel = wearJewel
        if wearJewel == nil then
          JewelProtocols.CSendMountJewelReq(selEquipInfo.bagId, selEquipInfo.key, slotIdx, jewelItem.itemId)
        else
          local selJewelBasic = JewelUtils.GetJewelItemByItemId(jewelItem.itemId, false)
          local wearJewelBasic = JewelUtils.GetJewelItemByItemId(wearJewel.jewelCfgId, false)
          if selJewelBasic.level < wearJewelBasic.level then
            local strContent = txtConst[44]
            CommonConfirmDlg.ShowConfirm(txtConst[43], strContent, function(select)
              if select == 1 then
                JewelProtocols.CSendMountJewelReq(selEquipInfo.bagId, selEquipInfo.key, slotIdx, jewelItem.itemId)
              end
            end, nil)
          else
            JewelProtocols.CSendMountJewelReq(selEquipInfo.bagId, selEquipInfo.key, slotIdx, jewelItem.itemId)
          end
        end
      end
    else
      Toast(txtConst[15])
    end
  end
end
def.method("number", "userdata").ShowBasicTips = function(self, itemId, clickObj)
  if itemId > 0 then
    local position = clickObj.position
    local screenPos = WorldPosToScreen(position.x, position.y)
    local sprite = clickObj:GetComponent("UISprite")
    local width = sprite:get_width()
    local height = sprite:get_height()
    ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x, screenPos.y, width, height, 0, true)
  end
end
def.method("userdata", "number").ShowMountTips = function(self, clickObj, itemId)
  local selEquipInfo = self:GetSelEquipInfo()
  if selEquipInfo ~= nil then
    local position = clickObj.position
    local screenPos = WorldPosToScreen(position.x, position.y)
    local sprite = clickObj:GetComponent("UIWidget")
    local width = sprite:get_width()
    local height = sprite:get_height()
    local item = {
      extraMap = {},
      slot = self._uiStatus.slotIdx,
      id = itemId,
      itemKey = selEquipInfo.key,
      bagId = selEquipInfo.bagId
    }
    self._slotItem = item
    ItemTipsMgr.Instance():ShowGodWeaponJewelTips(item, false, screenPos.x, screenPos.y, width, height, 0, false)
  else
    self._slotItem = nil
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
def.method("userdata").OnClickStretchJewelList = function(self, clickObj)
  local strs = string.split(clickObj.name, "_")
  local index = tonumber(strs[3])
  local subListView = clickObj.parent:FindDirect(string.format("tween_%d", index))
  if subListView and not subListView.isnil then
    if subListView:get_activeInHierarchy() then
      subListView:SetActive(false)
    else
      subListView:SetActive(true)
    end
  end
  GUIUtils.Reposition(self._uiGOs.ctrlUIList, "UIList", 0.01)
end
def.method("userdata").ShowEquipTips = function(self, clickObj)
  local selEquipInfo = self:GetSelEquipInfo()
  if selEquipInfo ~= nil then
    local position = clickObj:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local sprite = clickObj:GetComponent("UISprite")
    local item = ItemModule.Instance():GetItemByBagIdAndItemKey(selEquipInfo.bagId, selEquipInfo.key)
    ItemTipsMgr.Instance():ShowTips(item, 0, 0, 0, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), -1)
  end
end
def.method("=>", "table").GetSelEquipInfo = function(self)
  return self._equilList and self._equilList[self._uiStatus.selEquip] or nil
end
def.method("=>", "table").GetSelEquipStageCfg = function(self)
  return self._uiStatus.stageCfg
end
def.method("=>", "number").GetCurSelSlot = function(self)
  return self._uiStatus.selEmbedSlotIdx
end
def.method("=>", "table").GetSlotItem = function(self)
  return self._slotItem
end
def.method().Update2EmbedJewelList = function(self)
  local tbl = self:GetJewelsByEquipType()
  self._tblJewel = tbl
  self:ShowUIJewelsList(true, tbl)
end
def.method("table").OnMountChange = function(self, p)
end
def.method("table").OnJewelLevelChange = function(self, p)
  self._equilList = JewelMgr.GetData():GetHeroGodWeapons() or {}
  self:UpdateUIRight()
end
def.method("table").OnJewelBagChange = function(self, p)
  if self._uiStatus.wearJewel ~= nil then
    Toast(txtConst[45])
  end
  self._uiStatus.wearJewel = nil
  self._equilList = JewelMgr.GetData():GetHeroGodWeapons() or {}
  local selEquipInfo = self:GetSelEquipInfo()
  if selEquipInfo == nil then
    return
  end
  if self._uiGOs.groupJewelList:get_activeSelf() and self.m_base:IsShow() then
    local curSlotIdx = self._uiStatus.selSlotIdx
    if curSlotIdx == 0 then
      return
    end
    self:OnBtnBackClick()
  end
  self:UpdateUIRight()
  self.m_base._equipList = self._equilList
  self.m_base:UpdateEquipListReddots()
end
return JewelNode.Commit()

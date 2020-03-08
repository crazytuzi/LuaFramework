local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local EquipUtils = require("Main.Equip.EquipUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local TabNode = require("GUI.TabNode")
local EquipStrenTransData = require("Main.Equip.EquipStrenTransData")
local EquipModule = Lplus.ForwardDeclare("EquipModule")
local ItemConsumeDlg = require("Main.Item.ui.ItemConsumeDlg")
local EquipSocialPanel = Lplus.ForwardDeclare("EquipSocialPanel")
local CommonConfirm = require("GUI.CommonConfirmDlg")
local EquipXiHunNode = Lplus.Extend(TabNode, "EquipXiHunNode")
local def = EquipXiHunNode.define
def.field("table").mCurSelectEquip = nil
def.field("boolean").mIsWaitingYuanBaoPrice = false
def.field("boolean").mNeedReplaceByYuanBao = false
def.field("table").mYuanBaoMap = nil
def.field("number").mNeedYuanBaoNum = 0
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
  self.mCurSelectEquip = {}
end
def.override().OnShow = function(self)
  self:OnEquipListClick(1)
  EquipSocialPanel.Instance():SelectFromEquipStrenTrans(1)
end
def.method("number").OnEquipListClick = function(self, index)
  self.mIsWaitingYuanBaoPrice = false
  self.mNeedYuanBaoNum = 0
  self.mNeedReplaceByYuanBao = false
  self.mYuanBaoMap = nil
  self:FillEquipXiHunLeftFrame(index)
end
def.method("number").FillEquipXiHunLeftFrame = function(self, index)
  local equipStrenTransList = EquipStrenTransData.Instance():GetTransEquips()
  self.mCurSelectEquip = equipStrenTransList[index]
  if self.mCurSelectEquip == nil then
    return
  end
  local leftBg = self.m_node:FindDirect("Img_XH_BgCompare/Img_XH_Bg01")
  local baseinfoView = leftBg:FindDirect("Img_BgEquip")
  local equipIcon = baseinfoView:FindDirect("Icon_Equip"):GetComponent("UITexture")
  local equipBgSprite = baseinfoView:FindDirect("Icon_BgEquip"):GetComponent("UISprite")
  local equipName = baseinfoView:FindDirect("Label_EquipName"):GetComponent("UILabel")
  local equipScore = baseinfoView:FindDirect("Label_EquipScore"):GetComponent("UILabel")
  GUIUtils.FillIcon(equipIcon, self.mCurSelectEquip.iconId)
  equipName.text = ItemUtils.GetItemName(self.mCurSelectEquip, nil)
  GUIUtils.SetSprite(equipBgSprite, ItemUtils.GetItemFrame(self.mCurSelectEquip, nil))
  local equipItem = ItemModule.Instance():GetItemByBagIdAndItemKey(self.mCurSelectEquip.bagId, self.mCurSelectEquip.key)
  local score = EquipUtils.CalcEpuipScoreUtil(equipItem)
  equipScore.text = string.format(textRes.Equip[41], score)
  local attrtb = {}
  for k, v in pairs(equipItem.exproList) do
    if 0 == v.proType or 0 == v.proValue then
      table.insert(attrtb, {
        itemId = equipItem.id,
        isEmpty = true
      })
    else
      local str = EquipModule.GetProRandomName(v.proType)
      local pro = EquipModule.GetProTypeID(v.proType)
      local val, realVal, floatValue = EquipModule.GetProRealValue(v.proType, v.proValue)
      local isRecommend = EquipUtils.IsRecommendProType(v.proType, self.mCurSelectEquip.id)
      table.insert(attrtb, {
        itemId = equipItem.id,
        isEmpty = false,
        name = str,
        value = val,
        pro = pro,
        realVal = realVal,
        floatVal = floatValue,
        isLock = v.islock,
        proValue = v.proValue,
        isRecommend = isRecommend
      })
    end
  end
  self:UpdateHunListView(attrtb)
  self:FillEquipXiHunRightFrame(equipItem.extraProps)
  self:UpdateNeedItemView()
  local toggleBtn = self.m_node:FindDirect("Img_BgEquipMake/Img_MakeItem/Btn_UseGold")
  toggleBtn:GetComponent("UIToggle").value = false
  self:UpdateXiHunBtnState()
  self.m_node:FindDirect("Img_BgEquipMake/Btn_XH_Make"):GetComponent("UIButton"):set_isEnabled(true)
end
def.method().OnRefreshView = function(self)
  if self.m_panel ~= nil and false == self.m_panel.isnil then
    self:UpdateHunInfoView()
  end
end
def.method().UpdateHunInfoView = function(self)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  local leftBg = self.m_node:FindDirect("Img_XH_BgCompare/Img_XH_Bg01")
  local baseinfoView = leftBg:FindDirect("Img_BgEquip")
  local equipIcon = baseinfoView:FindDirect("Icon_Equip"):GetComponent("UITexture")
  local equipName = baseinfoView:FindDirect("Label_EquipName"):GetComponent("UILabel")
  local equipBgSprite = baseinfoView:FindDirect("Icon_BgEquip"):GetComponent("UISprite")
  local equipScore = baseinfoView:FindDirect("Label_EquipScore"):GetComponent("UILabel")
  GUIUtils.FillIcon(equipIcon, self.mCurSelectEquip.iconId)
  equipName.text = ItemUtils.GetItemName(self.mCurSelectEquip, nil)
  equipBgSprite:set_spriteName(ItemUtils.GetItemFrame(self.mCurSelectEquip, nil))
  local equipItem = ItemModule.Instance():GetItemByBagIdAndItemKey(self.mCurSelectEquip.bagId, self.mCurSelectEquip.key)
  local score = EquipUtils.CalcEpuipScoreUtil(equipItem)
  equipScore.text = string.format(textRes.Equip[41], score)
  local attrtb = {}
  for k, v in pairs(equipItem.exproList) do
    if 0 == v.proType or 0 == v.proValue then
      table.insert(attrtb, {
        itemId = equipItem.id,
        isEmpty = true
      })
    else
      local str = EquipModule.GetProRandomName(v.proType)
      local pro = EquipModule.GetProTypeID(v.proType)
      local val, realVal, floatValue = EquipModule.GetProRealValue(v.proType, v.proValue)
      local isRecommend = EquipUtils.IsRecommendProType(v.proType, self.mCurSelectEquip.id)
      table.insert(attrtb, {
        itemId = equipItem.id,
        isEmpty = false,
        name = str,
        value = val,
        pro = pro,
        realVal = realVal,
        floatVal = floatValue,
        isLock = v.islock,
        proValue = v.proValue,
        isRecommend = isRecommend
      })
    end
  end
  self:UpdateHunListView(attrtb)
  self:FillEquipXiHunRightFrame(equipItem.extraProps)
  self:UpdateNeedItemView()
end
def.method("number", "userdata", "boolean", "boolean").FillItemSprite = function(self, index, itemObj, isLock, isRecommend)
  local lockTexture = itemObj:FindDirect(string.format("Img_LockSelect_%d", index))
  local unlockTexture = itemObj:FindDirect(string.format("Img_Lock_%d", index))
  local tuijianSprite = itemObj:FindDirect(string.format("Img_Useful_%d", index))
  if isRecommend then
    tuijianSprite:SetActive(true)
  else
    tuijianSprite:SetActive(false)
  end
  if isLock then
    lockTexture:SetActive(true)
  else
    lockTexture:SetActive(false)
  end
end
def.method("table").UpdateHunListView = function(self, attrtb)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  local leftBg = self.m_node:FindDirect("Img_XH_BgCompare/Img_XH_Bg01")
  local ListView = leftBg:FindDirect("Grid_Attribute01")
  local hunNum = #attrtb
  local items = GUIUtils.InitUIList(ListView, hunNum)
  for i = 1, hunNum do
    local item = items[i]
    local attrLabel = item:FindDirect(string.format("Label_Attribute_%d", i))
    if not attrtb[i].isEmpty then
      self:SetEmptyHunItemView(item, i, false)
      local color = EquipUtils.GetProColorEx(attrtb[i].itemId, attrtb[i].pro, attrtb[i].floatVal, attrtb[i].proValue)
      local typeInfo = "[" .. color .. "]" .. attrtb[i].name .. ": +" .. attrtb[i].value
      attrLabel:GetComponent("UILabel").text = typeInfo
      local islock = attrtb[i].isLock == 1
      self:FillItemSprite(i, item, islock, attrtb[i].isRecommend)
    else
      self:SetEmptyHunItemView(item, i, true)
    end
  end
  GUIUtils.Reposition(ListView, "UIList", 0)
  self.m_base.m_msgHandler:Touch(ListView)
end
def.method("userdata", "number", "boolean").SetEmptyHunItemView = function(self, itemObj, index, isEmpty)
  if itemObj and not itemObj.isnil then
    local attrLabel = itemObj:FindDirect(string.format("Label_Attribute_%d", index))
    local usefulSprite = itemObj:FindDirect(string.format("Img_Useful_%d", index))
    local lockLabel = itemObj:FindDirect(string.format("Label_%d", index))
    local lockSprite = itemObj:FindDirect(string.format("Img_Lock_%d", index))
    local lockTexture = itemObj:FindDirect(string.format("Img_LockSelect_%d", index))
    if isEmpty then
      attrLabel:GetComponent("UILabel"):set_text(textRes.Equip[116])
      usefulSprite:SetActive(false)
      lockLabel:SetActive(false)
      lockSprite:SetActive(false)
      lockTexture:SetActive(false)
    else
      lockLabel:SetActive(true)
      lockSprite:SetActive(true)
    end
  end
end
def.method("table").PlayFxOnHunListView = function(self, hunIndexTable)
  local leftBg = self.m_node:FindDirect("Img_XH_BgCompare/Img_XH_Bg01")
  local ListView = leftBg:FindDirect("Grid_Attribute01")
  for k, v in pairs(hunIndexTable) do
    local fxObj = ListView:FindDirect(string.format("Btn_XH_Lock1_01_%d", v))
    require("Fx.GUIFxMan").Instance():PlayAsChild(fxObj, RESPATH.EQUIP_TRANS_RIGHT_EFFECT, 50, 0, -1, false)
  end
end
def.method("table").FillEquipXiHunRightFrame = function(self, extraProps)
  local rightBg = self.m_node:FindDirect("Img_XH_BgCompare/Img_XH_Bg02")
  local emptyView = rightBg:FindDirect("Group_EquipEmpty")
  local equipView = rightBg:FindDirect("Group_EquipInfo")
  local replaceBtn = self.m_node:FindDirect("Img_BgEquipMake/Btn_XH_Replace")
  local isEmpty = self:CheckPropsEmpty(extraProps)
  if isEmpty then
    replaceBtn:SetActive(false)
    equipView:SetActive(false)
    emptyView:SetActive(true)
    local tipLabel = emptyView:FindDirect("Label_FH_Tips"):GetComponent("UILabel")
    tipLabel.text = textRes.Equip[72]
  else
    replaceBtn:SetActive(true)
    equipView:SetActive(true)
    emptyView:SetActive(false)
    local headView = rightBg:FindDirect("Group_EquipInfo/Img_BgEquip")
    local uitexture = headView:FindDirect("Icon_Equip"):GetComponent("UITexture")
    GUIUtils.FillIcon(uitexture, self.mCurSelectEquip.iconId)
    local nameLabel = headView:FindDirect("Label_EquipName"):GetComponent("UILabel")
    nameLabel.text = ItemUtils.GetItemName(self.mCurSelectEquip, nil)
    local equipBgSprite = headView:FindDirect("Icon_BgEquip"):GetComponent("UISprite")
    equipBgSprite:set_spriteName(ItemUtils.GetItemFrame(self.mCurSelectEquip, nil))
    local scoreLabel = headView:FindDirect("Label_FH_EquipScore"):GetComponent("UILabel")
    local equipItem = ItemModule.Instance():GetItemByBagIdAndItemKey(self.mCurSelectEquip.bagId, self.mCurSelectEquip.key)
    local score = EquipUtils.CalcEpuipScoreUtilEx(equipItem, extraProps)
    scoreLabel.text = string.format(textRes.Equip[41], score)
    local xiHuntb = {}
    for k, v in pairs(extraProps) do
      local str = EquipModule.GetProRandomName(extraProps[k].proType)
      local pro = EquipModule.GetProTypeID(extraProps[k].proType)
      local val, realVal, floatValue = EquipModule.GetProRealValue(extraProps[k].proType, extraProps[k].proValue)
      local isRecommend = EquipUtils.IsRecommendProType(extraProps[k].proType, self.mCurSelectEquip.id)
      table.insert(xiHuntb, {
        itemId = equipItem.id,
        name = str,
        value = val,
        pro = pro,
        realVal = realVal,
        floatVal = floatValue,
        isLock = v.islock,
        proValue = extraProps[k].proValue,
        isRecommend = isRecommend
      })
    end
    local rightListView = equipView:FindDirect("Grid_FH_AttributeRight")
    self:UpdateRightXiHunListView(rightListView, xiHuntb)
  end
end
def.method("userdata", "table").UpdateRightXiHunListView = function(self, listView, attrtb)
  local num = #attrtb
  if num == 0 or listView == nil then
    return
  end
  local items = GUIUtils.InitUIList(listView, num)
  for i = 1, num do
    local item = items[i]
    local attrLabel = item:FindDirect(string.format("Label_Attribute_%d", i))
    local color = EquipUtils.GetProColorEx(attrtb[i].itemId, attrtb[i].pro, attrtb[i].floatVal, attrtb[i].proValue)
    local typeInfo = "[" .. color .. "]" .. attrtb[i].name .. ": +" .. attrtb[i].value
    attrLabel:GetComponent("UILabel").text = typeInfo
    local islock = attrtb[i].isLock == 1
    local isRecommend = attrtb[i].isRecommend
    self:FillItemSprite(i, item, islock, isRecommend)
  end
  self.m_base.m_msgHandler:Touch(listView)
  GUIUtils.Reposition(ListView, "UIList", 0)
end
def.method().UpdateNeedItemView = function(self)
  local xihunItemId, xihunItemNum = EquipUtils.GetXiHunStoneItemId(self.mCurSelectEquip.useLevel)
  local haveItemNum = ItemModule.Instance():GetItemCountById(xihunItemId)
  local itembase = ItemUtils.GetItemBase(xihunItemId)
  local IconBg = self.m_node:FindDirect("Img_BgEquipMake")
  local texture = IconBg:FindDirect("Img_MakeItem/Icon_FH_EquipMakeItem01"):GetComponent("UITexture")
  GUIUtils.FillIcon(texture, itembase.icon)
  local nameLabel = IconBg:FindDirect("Label_Name"):GetComponent("UILabel")
  nameLabel.text = itembase.name
  local haveAndUse = IconBg:FindDirect("Img_MakeItem/Label_FH_EquipMakeItem01"):GetComponent("UILabel")
  haveAndUse.text = tostring(haveItemNum) .. "/" .. tostring(xihunItemNum)
  local textColor = Color.green
  if xihunItemNum > haveItemNum then
    textColor = Color.red
  end
  haveAndUse:set_textColor(textColor)
end
def.override("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if string.find(id, "Btn_XH_Lock1_01_") then
    local strs = string.split(id, "01_")
    local index = tonumber(strs[2])
    self:OnClickSuoHunBtn(index, obj)
  elseif id == "Btn_XH_Make" then
    self:OnClickXiHunBtn(obj)
  elseif id == "Btn_XH_Replace" then
    self:OnClickReplaceHun()
  elseif id == "Img_MakeItem" then
    local xihunItemId, xihunItemNum = EquipUtils.GetXiHunStoneItemId(self.mCurSelectEquip.useLevel)
    self:ShowGetItemTips(obj, "UISprite", xihunItemId)
  elseif id == "Btn_UseGold" then
    self:OnClickNeedYuanBaoReplace()
  elseif id == "Btn_Preview" then
    self:OnClickEquipPreView(obj)
  end
end
def.method("userdata").OnClickEquipPreView = function(self, clickObj)
  local source = clickObj
  local position = source:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = source:GetComponent("UISprite")
  local equipId = self.mCurSelectEquip.id
  EquipUtils.ShowEquipDetailsDlg(equipId, screenPos.x, screenPos.y + 360, sprite:get_width(), sprite:get_height())
end
def.method().OnClickNeedYuanBaoReplace = function(self)
  local toggleBtn = self.m_node:FindDirect("Img_BgEquipMake/Img_MakeItem/Btn_UseGold")
  if toggleBtn and not toggleBtn.isnil then
    do
      local uiToggle = toggleBtn:GetComponent("UIToggle")
      local curValue = uiToggle.value
      if curValue then
        do
          local xihunItemId, xihunItemNum = EquipUtils.GetXiHunStoneItemId(self.mCurSelectEquip.useLevel)
          local haveItemNum = ItemModule.Instance():GetItemCountById(xihunItemId)
          if xihunItemNum <= haveItemNum then
            uiToggle.value = false
            Toast(textRes.Equip[110])
            self:UpdateXiHunBtnState()
            return
          end
          local function callback(select, tag)
            if 1 == select then
              uiToggle.value = true
              self.mIsWaitingYuanBaoPrice = true
              self.mNeedYuanBaoNum = 0
              self.mNeedReplaceByYuanBao = false
              self.mYuanBaoMap = nil
              local p = require("netio.protocol.mzm.gsp.item.CReqItemYuanbaoPriceWithId").new(self.mCurSelectEquip.id, {xihunItemId})
              gmodule.network.sendProtocol(p)
            else
              uiToggle.value = false
              self.mIsWaitingYuanBaoPrice = false
              self.mNeedYuanBaoNum = 0
              self.mNeedReplaceByYuanBao = false
              self.mYuanBaoMap = nil
              self:UpdateXiHunBtnState()
            end
          end
          CommonConfirm.ShowConfirm("", textRes.Equip[111], callback, nil)
        end
      else
        self.mIsWaitingYuanBaoPrice = false
        self.mNeedYuanBaoNum = 0
        self.mNeedReplaceByYuanBao = false
        self.mYuanBaoMap = nil
        self:UpdateXiHunBtnState()
      end
    end
  end
end
def.method().UpdateXiHunBtnState = function(self)
  local toggleBtn = self.m_node:FindDirect("Img_BgEquipMake/Img_MakeItem/Btn_UseGold")
  local uiToggle = toggleBtn:GetComponent("UIToggle")
  local curValue = uiToggle.value
  local yuanbaoGroup = self.m_node:FindDirect("Img_BgEquipMake/Btn_XH_Make/Group_Yuanbao")
  local btnLabel = self.m_node:FindDirect("Img_BgEquipMake/Btn_XH_Make/Label_Make")
  local xihunItemId, xihunItemNum = EquipUtils.GetXiHunStoneItemId(self.mCurSelectEquip.useLevel)
  local haveItemNum = ItemModule.Instance():GetItemCountById(xihunItemId)
  if curValue and self.mNeedReplaceByYuanBao and self.mYuanBaoMap and self.mYuanBaoMap[xihunItemId] then
    if xihunItemNum <= haveItemNum then
      uiToggle.value = false
      yuanbaoGroup:SetActive(false)
      btnLabel:SetActive(true)
      self.mIsWaitingYuanBaoPrice = false
      self.mNeedYuanBaoNum = 0
      self.mNeedReplaceByYuanBao = false
      self.mYuanBaoMap = nil
      return
    end
    yuanbaoGroup:SetActive(true)
    btnLabel:SetActive(false)
    local uiLabel = yuanbaoGroup:FindDirect("Label_Money"):GetComponent("UILabel")
    local itemPrice = self.mYuanBaoMap[xihunItemId]
    local needYuanBaoNum = itemPrice * (xihunItemNum - haveItemNum)
    self.mNeedYuanBaoNum = needYuanBaoNum
    uiLabel:set_text(tostring(needYuanBaoNum))
  else
    yuanbaoGroup:SetActive(false)
    btnLabel:SetActive(true)
    self.mIsWaitingYuanBaoPrice = false
    self.mNeedYuanBaoNum = 0
    self.mNeedReplaceByYuanBao = false
    self.mYuanBaoMap = nil
  end
end
def.method("number", "table").OnAskItemsYuanBaoPrice = function(self, id, itemId2yuanbao)
  if self.m_node and not self.m_node.isnil and self.mIsWaitingYuanBaoPrice then
    self.mIsWaitingYuanBaoPrice = false
    if self.mCurSelectEquip.id == id then
      local xihunItemId, xihunItemNum = EquipUtils.GetXiHunStoneItemId(self.mCurSelectEquip.useLevel)
      local haveItemNum = ItemModule.Instance():GetItemCountById(xihunItemId)
      local itemPrice = itemId2yuanbao[xihunItemId]
      if itemPrice then
        self.mNeedReplaceByYuanBao = true
        if nil == self.mYuanBaoMap then
          self.mYuanBaoMap = {}
        end
        self.mYuanBaoMap[xihunItemId] = itemPrice
        if xihunItemNum > haveItemNum then
          self.mNeedYuanBaoNum = itemPrice * (xihunItemNum - haveItemNum)
        else
          self.mNeedYuanBaoNum = 0
        end
        self:UpdateXiHunBtnState()
      end
    end
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
def.method("number", "userdata").OnClickSuoHunBtn = function(self, index, obj)
  local equipItem = ItemModule.Instance():GetItemByBagIdAndItemKey(self.mCurSelectEquip.bagId, self.mCurSelectEquip.key)
  local exproList = equipItem.exproList
  local expro = exproList[index]
  if expro.islock == 1 then
    local title = textRes.Equip[75]
    local content = textRes.Equip[76]
    local function callback(id, tag)
      if id == 1 then
        self:RealtoUnlockHun(index)
      end
    end
    CommonConfirm.ShowConfirm(title, content, callback, nil)
  else
    if 0 == expro.proType or 0 == expro.proValue then
      return
    end
    local suoHunNum = self:GetCurSuoHunNum(exproList)
    if suoHunNum == #exproList - 1 then
      Toast(textRes.Equip[80])
      return
    end
    local suoHunCfg = EquipUtils.GetSuoHunItemIdAndNum(self.mCurSelectEquip.useLevel)
    local curcfg = suoHunCfg[suoHunNum + 1]
    local suohunItemId = curcfg.itemId
    local suohunItemNum = curcfg.itemNum
    local haveNum = ItemModule.Instance():GetItemCountById(suohunItemId)
    local itembase = ItemUtils.GetItemBase(suohunItemId)
    local function lockhunCallback(yuanbao, extInfo)
      self:RealToSuoHun(yuanbao, index)
    end
    local ItemYuanBaoTipPanel = require("Main.Item.ui.ItemYuanBaoTipPanel")
    ItemYuanBaoTipPanel.Instance():ShowItemYuanBaoPanel(textRes.Equip[73], textRes.Equip[113], suohunItemId, suohunItemNum, lockhunCallback, nil)
  end
end
def.method("number", "number").RealToSuoHun = function(self, yuanbao, hunIndex)
  local useYuanBao = 0
  if yuanbao > 0 then
    useYuanBao = 1
  else
    if yuanbao == -1 then
      return
    else
    end
  end
  local equipItem = ItemModule.Instance():GetItemByBagIdAndItemKey(self.mCurSelectEquip.bagId, self.mCurSelectEquip.key)
  local CLockHunReq = require("netio.protocol.mzm.gsp.item.CLockHunReq")
  local p = CLockHunReq.new(self.mCurSelectEquip.bagId, equipItem.uuid[1], hunIndex, useYuanBao)
  gmodule.network.sendProtocol(p)
end
def.method("number").RealtoUnlockHun = function(self, index)
  local equipItem = ItemModule.Instance():GetItemByBagIdAndItemKey(self.mCurSelectEquip.bagId, self.mCurSelectEquip.key)
  local CUnLockHunReq = require("netio.protocol.mzm.gsp.item.CUnLockHunReq")
  local p = CUnLockHunReq.new(self.mCurSelectEquip.bagId, equipItem.uuid[1], index)
  gmodule.network.sendProtocol(p)
end
def.method("userdata").OnClickXiHunBtn = function(self, obj)
  local xihunItemId, xihunItemNum = EquipUtils.GetXiHunStoneItemId(self.mCurSelectEquip.useLevel)
  local haveItemNum = ItemModule.Instance():GetItemCountById(xihunItemId)
  if xihunItemNum > haveItemNum then
    do
      local toggleBtn = self.m_node:FindDirect("Img_BgEquipMake/Img_MakeItem/Btn_UseGold")
      local uiToggle = toggleBtn:GetComponent("UIToggle")
      local curValue = uiToggle.value
      if not curValue then
        uiToggle.value = true
        self:OnClickNeedYuanBaoReplace()
        return
      end
    end
  else
  end
  local useYuanBao = 0
  if self.mNeedReplaceByYuanBao then
    useYuanBao = 1
  end
  local allYuanBao = ItemModule.Instance():GetAllYuanBao()
  local needYuanBaoNum = self.mNeedYuanBaoNum
  if 1 == useYuanBao and allYuanBao:lt(needYuanBaoNum) then
    Toast(textRes.Common[15])
    return
  end
  local equipItem = ItemModule.Instance():GetItemByBagIdAndItemKey(self.mCurSelectEquip.bagId, self.mCurSelectEquip.key)
  local function RealToRefresh()
    local uuid = equipItem.uuid[1]
    local CXiHun = require("netio.protocol.mzm.gsp.item.CRefreshHunReq")
    local p = CXiHun.new(self.mCurSelectEquip.bagId, uuid, useYuanBao, allYuanBao, needYuanBaoNum)
    gmodule.network.sendProtocol(p)
    local Btn = self.m_node:FindDirect("Img_BgEquipMake/Btn_XH_Make")
    Btn:GetComponent("UIButton"):set_isEnabled(false)
    GameUtil.AddGlobalLateTimer(0.3, true, function()
      if Btn and not Btn.isnil then
        Btn:GetComponent("UIButton"):set_isEnabled(true)
      end
    end)
  end
  local extraProps = equipItem.extraProps
  if extraProps then
    if EquipUtils.HasRecommendPurpleOrOrangeHun(self.mCurSelectEquip.id, equipItem, extraProps) then
      local function callback(select, tag)
        if 1 == select then
          RealToRefresh()
        end
      end
      CommonConfirm.ShowConfirm("", textRes.Equip[117], callback, nil)
    else
      RealToRefresh()
    end
  else
    RealToRefresh()
  end
end
def.method().OnClickReplaceHun = function(self)
  local equipItem = ItemModule.Instance():GetItemByBagIdAndItemKey(self.mCurSelectEquip.bagId, self.mCurSelectEquip.key)
  local extraProps = equipItem.extraProps
  if self:CheckPropsEmpty(extraProps) then
    Toast(textRes.Equip[89])
    return
  end
  local equipItem = ItemModule.Instance():GetItemByBagIdAndItemKey(self.mCurSelectEquip.bagId, self.mCurSelectEquip.key)
  local function RealToReplace()
    local CReplaceHun = require("netio.protocol.mzm.gsp.item.CConfirmRefreshHunReq")
    local uuid = equipItem.uuid[1]
    local p = CReplaceHun.new(self.mCurSelectEquip.bagId, uuid, 1)
    gmodule.network.sendProtocol(p)
  end
  if EquipUtils.HasRecommendPurpleOrOrangeHun(self.mCurSelectEquip.id, equipItem, equipItem.exproList) then
    local function callback(select, tag)
      if 1 == select then
        RealToReplace()
      end
    end
    CommonConfirm.ShowConfirm("", textRes.Equip[118], callback, nil)
  else
    RealToReplace()
  end
end
def.method("number", "userdata", "number").onLockHunSuccess = function(self, bagid, uuid, hunIndex)
  Toast(textRes.Equip[87])
  self:UpdateLockInfo(bagid, uuid, hunIndex, true)
end
def.method("number", "userdata", "number", "number").onLockHunFailed = function(self, bagid, uuid, hunIndex, retcode)
  warn("onLockHunFailed~~~~~", bagid, uuid, hunIndex, retcode)
  Toast(textRes.Equip[77])
end
def.method("number", "userdata", "number").OnUnLockHunSuccess = function(self, bagid, uuid, hunIndex)
  warn("OnUnLockHunSuccess~~~", bagid, uuid, hunIndex)
  Toast(textRes.Equip[90])
  self:UpdateLockInfo(bagid, uuid, hunIndex, false)
end
def.method("number", "userdata", "number", "number").OnUnLockHunFailed = function(self, bagid, uuid, hunIndex, retcode)
  warn("OnUnLockHunFailed~~~", bagid, uuid, hunIndex, retcode)
  Toast(textRes.Equip[78])
end
def.method("number", "userdata", "table").onRefreshHunSuccess = function(self, bagid, uuid, extraProps)
  local ItemData = require("Main.Item.ItemData").Instance()
  local items = ItemData:GetBag(bagid)
  for k, v in pairs(items) do
    if uuid:eq(v.uuid[1]) then
      v.extraProps = extraProps
      break
    end
  end
  self:UpdateHunInfoView()
end
def.method("number", "userdata", "number").onRefreshHunFailed = function(self, bagid, uuid, retcode)
  warn("onRefreshHunFailed~~~~~~")
end
def.method("number", "userdata", "number").onReplaceHunSuccess = function(self, bagid, uuid, isReplace)
  local ItemData = require("Main.Item.ItemData").Instance()
  local items = ItemData:GetBag(bagid)
  local fxtb = {}
  for k, v in pairs(items) do
    if uuid:eq(v.uuid[1]) then
      local exproList = v.exproList
      local extraProps = v.extraProps
      if self:CheckPropsEmpty(extraProps) then
        return
      end
      for k2, v2 in pairs(extraProps) do
        if exproList[k2].islock == 0 then
          exproList[k2].proType = v2.proType
          exproList[k2].proValue = v2.proValue
          exproList[k2].islock = v2.islock
          table.insert(fxtb, k2)
        end
      end
      v.extraProps = {}
      break
    end
  end
  self:PlayFxOnHunListView(fxtb)
  GameUtil.AddGlobalLateTimer(0.3, true, function()
    if self.m_node and not self.m_node.isnil then
      self:UpdateHunInfoView()
    end
  end)
  local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
  if PlayerIsInFight() and self.mCurSelectEquip.bagId == BagInfo.EQUIPBAG then
    Toast(textRes.Equip[93])
  end
end
def.method("number", "number", "number", "userdata").onReplaceHunFailed = function(self, retcode, bagid, isReplace, uuid)
  warn("onReplaceHunFailed~~~", retcode, bagid, isReplace, uuid)
end
def.method().OnBagInfoChange = function(self)
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if self.m_node and not self.m_node.isnil then
      self:UpdateNeedItemView()
      self:UpdateXiHunBtnState()
    end
  end)
end
def.method("number", "userdata", "number", "boolean").UpdateLockInfo = function(self, bagid, uuid, hunIndex, islock)
  local ItemData = require("Main.Item.ItemData").Instance()
  local items = ItemData:GetBag(bagid)
  for k, v in pairs(items) do
    if uuid:eq(v.uuid[1]) then
      local exproList = v.exproList
      if islock then
        exproList[hunIndex].islock = 1
        break
      end
      exproList[hunIndex].islock = 0
      break
    end
  end
  self:UpdateHunLockState()
end
def.method().UpdateHunLockState = function(self)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  local leftBg = self.m_node:FindDirect("Img_XH_BgCompare/Img_XH_Bg01")
  local ListView = leftBg:FindDirect("Grid_Attribute01")
  local items = ListView:GetComponent("UIList").children
  local equipItem = ItemModule.Instance():GetItemByBagIdAndItemKey(self.mCurSelectEquip.bagId, self.mCurSelectEquip.key)
  local exproList = equipItem.exproList
  if #items ~= #exproList then
    return
  end
  for i = 1, #items do
    local item = items[i]
    local islock = exproList[i].islock == 1
    local isRecommend = EquipUtils.IsRecommendProType(exproList[i].proType, self.mCurSelectEquip.id)
    self:FillItemSprite(i, item, islock, isRecommend)
  end
end
def.method("table", "=>", "number").GetCurSuoHunNum = function(self, exproList)
  local suoNum = 0
  if exproList == nil then
    return suoNum
  end
  for k, v in pairs(exproList) do
    if v.islock == 1 then
      suoNum = suoNum + 1
    end
  end
  return suoNum
end
def.method("table", "=>", "boolean").CheckPropsEmpty = function(self, extraProps)
  if extraProps == nil then
    return true
  end
  local num = 0
  for k, v in pairs(extraProps) do
    num = num + 1
  end
  return num < 1
end
EquipXiHunNode.Commit()
return EquipXiHunNode

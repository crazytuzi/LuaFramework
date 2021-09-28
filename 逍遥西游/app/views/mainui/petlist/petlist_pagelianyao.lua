CPetList_PageLianYao = class(".CPetList_PageLianYao", CcsSubView)
function CPetList_PageLianYao:ctor(petId, petlistObj)
  CPetList_PageLianYao.super.ctor(self, "views/pet_list_lianyao_new.json")
  clickArea_check.extend(self)
  local btnBatchListener = {
    btn_confirm = {
      listener = handler(self, self.OnBtn_Confirm),
      variName = "btn_confirm"
    },
    btn_help = {
      listener = handler(self, self.OnBtn_Help),
      variName = "btn_help"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_PetId = nil
  self.m_PetlistObj = petlistObj
  self.m_SelectLYSView = nil
  self.m_SelectLYSID = nil
  self.m_SelectLYSImg = nil
  self.m_AddLianYaoAddAttr = {}
  self.btn_lyspos = self:getNode("btn_lyspos")
  self:click_check_withObj(self.btn_lyspos, function()
    self:OnBtn_SelectLYS()
  end, function(check)
    self:OnClickItemPos(self.btn_lyspos, check)
  end)
  self.m_AddIcon = display.newSprite("views/rolelist/equipcanadd.png")
  self.btn_lyspos:addNode(self.m_AddIcon, 1)
  self.m_AddIcon:setPosition(ccp(20, 20))
  self:LoadPet(petId)
  self:SetAttrTips()
  self:ListenMessage(MsgID_PlayerInfo)
end
function CPetList_PageLianYao:OnClickItemPos(obj, check)
  if check then
    obj:setScale(1.05)
  else
    obj:setScale(1)
  end
end
function CPetList_PageLianYao:SetAttrTips()
  self:attrclick_check_withWidgetObj(self:getNode("txt_lys2"), PROPERTY_PDEFEND)
  self:attrclick_check_withWidgetObj(self:getNode("lys_add_1"), PROPERTY_PDEFEND, self:getNode("txt_lys2"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_lys6"), PROPERTY_KFENG)
  self:attrclick_check_withWidgetObj(self:getNode("lys_add_5"), PROPERTY_KFENG, self:getNode("txt_lys6"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_lys4"), PROPERTY_KSHUI)
  self:attrclick_check_withWidgetObj(self:getNode("lys_add_3"), PROPERTY_KSHUI, self:getNode("txt_lys4"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_lys3"), PROPERTY_KHUO)
  self:attrclick_check_withWidgetObj(self:getNode("lys_add_2"), PROPERTY_KHUO, self:getNode("txt_lys3"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_lys5"), PROPERTY_KLEI)
  self:attrclick_check_withWidgetObj(self:getNode("lys_add_4"), PROPERTY_KLEI, self:getNode("txt_lys5"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_lys7"), PROPERTY_KHUNLUAN)
  self:attrclick_check_withWidgetObj(self:getNode("lys_add_6"), PROPERTY_KHUNLUAN, self:getNode("txt_lys7"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_lys9"), PROPERTY_KZHONGDU)
  self:attrclick_check_withWidgetObj(self:getNode("lys_add_8"), PROPERTY_KZHONGDU, self:getNode("txt_lys9"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_lys8"), PROPERTY_KHUNSHUI)
  self:attrclick_check_withWidgetObj(self:getNode("lys_add_7"), PROPERTY_KHUNSHUI, self:getNode("txt_lys8"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_lys10"), PROPERTY_KFENGYIN)
  self:attrclick_check_withWidgetObj(self:getNode("lys_add_9"), PROPERTY_KFENGYIN, self:getNode("txt_lys10"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_lys12"), PROPERTY_KZHENSHE)
  self:attrclick_check_withWidgetObj(self:getNode("lys_add_11"), PROPERTY_KZHENSHE, self:getNode("txt_lys12"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_lys13"), PROPERTY_KZHENSHE)
  self:attrclick_check_withWidgetObj(self:getNode("lys_add_12"), PROPERTY_KZHENSHE, self:getNode("txt_lys13"))
end
function CPetList_PageLianYao:LoadPet(petId)
  if self.m_PetId == petId then
    return
  end
  self.m_PetId = petId
  self.m_PetIns = g_LocalPlayer:getObjById(self.m_PetId)
  self:UpdateSelectLYSView()
end
function CPetList_PageLianYao:UpdateSelectLYSView(itemId)
  local itemIns = g_LocalPlayer:GetOneItem(itemId)
  local itemType
  if itemIns ~= nil then
    itemType = itemIns:getTypeId()
  end
  if itemId ~= nil and self.m_PetIns then
    local zs = self.m_PetIns:getProperty(PROPERTY_ZHUANSHENG)
    local maxTimes = CalculatePetLianYaoLimit(zs)
    local curTimes = self.m_PetIns:getProperty(PROPERTY_LIANYAO_NUM)
    if itemType == ITEM_DEF_STUFF_WLD then
      if curTimes == 0 then
        ShowNotifyTips(string.format("没有炼妖效果无法使用%s", data_getItemName(ITEM_DEF_STUFF_WLD)))
        self:UpdateSelectLYSView()
        return
      end
    elseif maxTimes <= curTimes then
      ShowNotifyTips("炼妖次数已达上限")
      self:UpdateSelectLYSView()
      return
    end
  end
  self.m_SelectLYSID = itemId
  if self.m_SelectLYSView then
    self.m_SelectLYSView:SetUsedLYS(itemId, 1)
  end
  if self.m_SelectLYSImg then
    self.m_SelectLYSImg:removeFromParent()
    self.m_SelectLYSImg = nil
  end
  if itemIns ~= nil then
    local pos = self:getNode("btn_lyspos")
    local itemShapeId = data_getItemShapeID(itemIns:getTypeId())
    local path = data_getItemPathByShape(itemShapeId)
    local icon = display.newSprite(path)
    pos:addNode(icon, 10)
    self.m_SelectLYSImg = icon
    self.m_AddIcon:setVisible(false)
  else
    self.m_AddIcon:setVisible(true)
  end
  self.m_canLianYao = false
  self.m_notLianYaoTips = {}
  if self.m_PetIns then
    local zs = self.m_PetIns:getProperty(PROPERTY_ZHUANSHENG)
    local maxTimes = CalculatePetLianYaoLimit(zs)
    local curTimes = self.m_PetIns:getProperty(PROPERTY_LIANYAO_NUM)
    if itemIns ~= nil then
      if itemType == ITEM_DEF_STUFF_WLD then
        self:getNode("txt_lys_num"):setText(string.format("%d/%d", 0, maxTimes))
      else
        self:getNode("txt_lys_num"):setText(string.format("%d/%d", curTimes, maxTimes))
      end
    else
      self:getNode("txt_lys_num"):setText(string.format("%d/%d", curTimes, maxTimes))
    end
    for i = 1, 12 do
      local obj = self:getNode(string.format("lys_value_%d", i))
      if obj then
        obj:setVisible(false)
      end
    end
    for i, proName in ipairs({
      PROPERTY_PDEFEND,
      PROPERTY_KHUO,
      PROPERTY_KSHUI,
      PROPERTY_KLEI,
      PROPERTY_KFENG,
      PROPERTY_KHUNLUAN,
      PROPERTY_KHUNSHUI,
      PROPERTY_KZHONGDU,
      PROPERTY_KFENGYIN,
      PROPERTY_KZHENSHE,
      PROPERTY_KYIWANG,
      PROPERTY_KAIHAO
    }) do
      local value = self.m_PetIns:GetRandomKangByName(proName) + self.m_PetIns:getProperty(PET_LIANHUA_KANG_DICT[proName])
      value = math.min(MAX_KANG_PET_NOMANAGE_VALUE, value)
      local lysAddObj = self:getNode(string.format("lys_add_%d", i))
      if lysAddObj then
        lysAddObj:setText(Value2Str(value * 100, 0))
        if itemType == ITEM_DEF_STUFF_WLD then
          local delKxValue = value - self.m_PetIns:GetRandomKangByName(proName)
          if delKxValue > 0 then
            self:getNode(string.format("lys_value_%d", i)):setVisible(true)
            self:getNode(string.format("lys_value_%d", i)):setText(string.format("-%s", Value2Str(delKxValue * 100, 0)))
            self:getNode(string.format("lys_value_%d", i)):setColor(VIEW_DEF_WARNING_COLOR)
          end
        end
      end
    end
    if itemIns ~= nil and itemType ~= ITEM_DEF_STUFF_WLD then
      local kangxingList = itemIns:getProperty(ITEM_PRO_LIANYAOSHI_KX)
      local kangxingValueList = itemIns:getProperty(ITEM_PRO_LIANYAOSHI_KXV)
      local itemName = itemIns:getProperty(ITEM_PRO_NAME)
      for i, kx in pairs(kangxingList) do
        local proName = LIANYAOSHI_KANGPRO[kx]
        local value = self.m_PetIns:GetRandomKangByName(proName) + self.m_PetIns:getProperty(PET_LIANHUA_KANG_DICT[proName])
        value = math.min(MAX_KANG_PET_NOMANAGE_VALUE, value)
        local index = LIANYAOSHI_SHOWList[proName]
        local kxValue = (kangxingValueList[i] or 0) / 100
        kxValue = math.min(kxValue, MAX_KANG_PET_NOMANAGE_VALUE - value)
        if index ~= nil then
          self:getNode(string.format("lys_value_%d", index)):setVisible(true)
          self:getNode(string.format("lys_value_%d", index)):setText(string.format("+%s", Value2Str(kxValue * 100, 0)))
          self:getNode(string.format("lys_value_%d", index)):setColor(VIEW_DEF_PGREEN_COLOR)
        end
        if kxValue > 0 then
          self.m_canLianYao = true
        end
        local kxName = LIANYAOSHI_KANGNAME[kx]
        self.m_notLianYaoTips[#self.m_notLianYaoTips + 1] = string.format("#<Y>%s#已达炼妖上限75%%，无法继续对其使用#<Y>%s#", kxName, itemName)
      end
    end
  end
end
function CPetList_PageLianYao:CloseSelectLYS()
  if self.m_SelectLYSView then
    self.m_SelectLYSView:CloseSelf()
    self.m_SelectLYSView = nil
  end
end
function CPetList_PageLianYao:OnBtn_SelectLYS(btnObj, touchType)
  local itemIds = g_LocalPlayer:GetItemTypeList(ITEM_LARGE_TYPE_LIANYAOSHI)
  if #itemIds == 0 then
    ShowNotifyTips("没有炼妖石")
    return
  end
  if self.m_SelectLYSView == nil then
    self.m_SelectLYSView = CSelectLYSList.new({
      closeListener = handler(self, self.CloseSelectLYS),
      selectFunc = handler(self, self.UpdateSelectLYSView),
      enableTouchDetect = true
    })
    self.m_PetlistObj:addSubView({
      subView = self.m_SelectLYSView,
      zOrder = 9999
    })
    local x, y = self.m_PetlistObj.pic_probg:getPosition()
    local bSize = self.m_SelectLYSView:getBoxSize()
    self.m_SelectLYSView:setPosition(ccp(x - bSize.width, y - bSize.height / 2))
    self.m_SelectLYSView:SetUsedLYS(self.m_SelectLYSID, 1)
  else
    self:UpdateSelectLYSView()
  end
end
function CPetList_PageLianYao:OnBtn_Confirm(obj, t)
  local curTime = cc.net.SocketTCP.getTime()
  if self.m_LastClickTime ~= nil and curTime - self.m_LastClickTime < 0.25 then
    return
  end
  self.m_LastClickTime = curTime
  local itemId = self.m_SelectLYSID
  local petId = self.m_PetIns:getObjId()
  if itemId == nil then
    ShowNotifyTips("请选择炼妖石")
    return
  end
  self:OnLianYao(itemId)
  self:CloseSelectLYS()
end
function CPetList_PageLianYao:OnLianYao(itemId)
  local itemIns = g_LocalPlayer:GetOneItem(itemId)
  if itemIns == nil then
    return
  end
  local itemType = itemIns:getTypeId()
  local zs = self.m_PetIns:getProperty(PROPERTY_ZHUANSHENG)
  local maxTimes = CalculatePetLianYaoLimit(zs)
  local curTimes = self.m_PetIns:getProperty(PROPERTY_LIANYAO_NUM)
  local roleId = self.m_PetIns:getObjId()
  if itemType == ITEM_DEF_STUFF_WLD then
    netsend.netbaseptc.setLianYaoPet(roleId, itemId)
    ShowWarningInWar()
  elseif maxTimes <= curTimes then
    ShowNotifyTips("炼妖次数已达上限")
  elseif self.m_canLianYao == true then
    self:RecordLianYaoItemAddAttr(itemId)
    netsend.netbaseptc.setLianYaoPet(roleId, itemId)
    ShowWarningInWar()
  else
    for _, tip in pairs(self.m_notLianYaoTips) do
      ShowNotifyTips(tip)
    end
  end
end
function CPetList_PageLianYao:RecordLianYaoItemAddAttr(itemId)
  local itemObj = g_LocalPlayer:GetOneItem(itemId)
  if itemObj == nil then
    return nil
  end
  local attrList = {}
  local itemType = itemObj:getType()
  if itemType == ITEM_LARGE_TYPE_LIANYAOSHI then
    if itemObj:getTypeId() == ITEM_DEF_STUFF_WLD then
      return nil
    end
    local kangxingList = itemObj:getProperty(ITEM_PRO_LIANYAOSHI_KX)
    local kangxingValueList = itemObj:getProperty(ITEM_PRO_LIANYAOSHI_KXV)
    for i, kx in pairs(kangxingList) do
      local proName = LIANYAOSHI_KANGPRO[kx]
      local value = self.m_PetIns:GetRandomKangByName(proName) + self.m_PetIns:getProperty(PET_LIANHUA_KANG_DICT[proName])
      value = math.min(MAX_KANG_PET_NOMANAGE_VALUE, value)
      local kxName = LIANYAOSHI_KANGNAME[kx]
      local kxValue = (kangxingValueList[i] or 0) / 100
      kxValue = math.min(kxValue, MAX_KANG_PET_NOMANAGE_VALUE - value)
      if kxValue > 0 then
        attrList[#attrList + 1] = string.format("#<Y>%s+%s%%#", kxName, Value2Str(kxValue * 100, 1))
      end
    end
  end
  self.m_AddLianYaoAddAttr[self.m_PetId] = attrList
end
function CPetList_PageLianYao:CheckLianYaoAddAttr(petId)
  local attrList = self.m_AddLianYaoAddAttr[petId]
  if attrList ~= nil then
    for _, msg in pairs(attrList) do
      ShowNotifyTips(msg)
    end
    self.m_AddLianYaoAddAttr[petId] = nil
  end
end
function CPetList_PageLianYao:OnBtn_Help(obj, t)
  getCurSceneView():addSubView({
    subView = CPetLianYaoHelp.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
function CPetList_PageLianYao:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_PetUpdate then
    local d = arg[1]
    if d.petId == self.m_PetId then
      self:UpdateSelectLYSView()
    end
  elseif msgSID == MsgID_LianYaoSuccess then
    local param = arg[1]
    self:CheckLianYaoAddAttr(param.petId)
  end
end
function CPetList_PageLianYao:Clear()
  self.m_PetlistObj = nil
end
CPetLianYaoHelp = class("CPetLianYaoHelp", CcsSubView)
function CPetLianYaoHelp:ctor()
  CPetLianYaoHelp.super.ctor(self, "views/pet_list_lianyao_tip.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
end
function CPetLianYaoHelp:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end

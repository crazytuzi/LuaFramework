CPetList_PageXiChong = class(".CPetList_PageXiChong", CcsSubView)
function CPetList_PageXiChong:ctor(petId, petlistObj, pagePotential)
  CPetList_PageXiChong.super.ctor(self, "views/pet_list_xichong.json")
  local btnBatchListener = {
    btn_ok = {
      listener = handler(self, self.OnBtn_Confirm),
      variName = "btn_ok"
    },
    btn_help = {
      listener = handler(self, self.OnBtn_Help),
      variName = "btn_help"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  clickArea_check.extend(self)
  self.m_PetId = nil
  self.m_PetlistObj = petlistObj
  self.m_BasePagePotential = pagePotential
  self.m_ItemTypeId = ITEM_DEF_OTHER_GJJLL
  self.m_XiNeedNum = 1
  local itembg = self:getNode("itembg")
  itembg:setVisible(false)
  local parent = itembg:getParent()
  local z = itembg:getZOrder()
  local x, y = itembg:getPosition()
  local size = itembg:getContentSize()
  local itemIcon = createClickItem({
    itemID = self.m_ItemTypeId,
    num = 0,
    LongPressTime = 0.1,
    clickListener = nil,
    LongPressListener = nil,
    LongPressEndListner = nil,
    clickDel = nil,
    noBgFlag = false
  })
  parent:addChild(itemIcon, z)
  itemIcon:setPosition(ccp(x - size.width / 2, y - size.height / 2))
  local itemname = self:getNode("itemname")
  local name = data_getItemName(self.m_ItemTypeId)
  itemname:setText(name)
  self:LoadPet(petId)
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_ItemInfo)
end
function CPetList_PageXiChong:LoadPet(petId)
  if self.m_PetId == petId then
    return
  end
  self.m_PetId = petId
  self.m_PetIns = g_LocalPlayer:getObjById(self.m_PetId)
  local petTypeId = self.m_PetIns:getTypeId()
  local petData = data_Pet[petTypeId] or {}
  self.m_Max_BaseCZL = math.floor((petData.GROWUP or 0) * 1.02 * 1000 + 1.0E-8) / 1000
  self.m_Max_QX = math.floor((petData.HP or 0) * 1.2 + 1.0E-8)
  self.m_Max_FL = math.floor((petData.MP or 0) * 1.2 + 1.0E-8)
  self.m_Max_GJ = math.floor((petData.AP or 0) * 1.2 + 1.0E-8)
  self.m_Max_SD = math.floor((petData.SP or 0) * 1.2 + 1.0E-8)
  self.m_BaseCZl = 0
  self.m_QX = 0
  self.m_FL = 0
  self.m_GJ = 0
  self.m_SD = 0
  local lTypeId = self.m_PetIns:getTypeId()
  local data = data_Pet[lTypeId] or {}
  self.m_XiNeedNum = data.XICOST or 1
  self:SetItemNum()
  self:SetPageAttr(false)
  self:SetPageKang()
end
function CPetList_PageXiChong:SetPageAttr(compare)
  self.m_BaseCZl = self:setAttrValue("text_czl", PROPERTY_RANDOM_GROWUP, self.m_Max_BaseCZL, self.m_BaseCZl, compare, true)
  self.m_QX = self:setAttrValue("text_qx", PROPERTY_RANDOM_HPBASE, self.m_Max_QX, self.m_QX, compare, false)
  self.m_FL = self:setAttrValue("text_fl", PROPERTY_RANDOM_MPBASE, self.m_Max_FL, self.m_FL, compare, false)
  self.m_GJ = self:setAttrValue("text_gj", PROPERTY_RANDOM_APBASE, self.m_Max_GJ, self.m_GJ, compare, false)
  self.m_SD = self:setAttrValue("text_sd", PROPERTY_RANDOM_SPBASE, self.m_Max_SD, self.m_SD, compare, false)
end
function CPetList_PageXiChong:SetPageKang()
  local petType = self.m_PetIns:getProperty(PROPERTY_PETTYPE)
  local kangProTable = self.m_PetIns:getRandomKang()
  local index = 1
  if kangProTable[PROPERTY_PDEFEND] ~= nil then
    local tempText = ""
    if Def_Pro_ValueType[PROPERTY_PDEFEND] == Pro_Value_PERCENT_TYPE then
      tempText = string.format("%s%s%%", Def_Pro_Name[PROPERTY_PDEFEND] or "", Value2Str(math.abs(kangProTable[PROPERTY_PDEFEND]) * 100, 1))
    else
      tempText = string.format("%s%d", Def_Pro_Name[PROPERTY_PDEFEND] or "", math.floor(math.abs(kangProTable[PROPERTY_PDEFEND])))
    end
    local text = self:getNode("kang_1")
    text:setText(tempText)
    self:attrclick_check_withWidgetObj(self:getNode("kangtext_1"), PROPERTY_PDEFEND)
    self:attrclick_check_withWidgetObj(text, PROPERTY_PDEFEND, self:getNode("kangtext_1"))
    index = index + 1
  end
  for _, proShowTable in ipairs(Def_KangViewShowSeq) do
    if index > 2 then
      break
    end
    for _, proName in ipairs(proShowTable.pro) do
      if proName ~= PROPERTY_PDEFEND and kangProTable[proName] ~= nil then
        local tempText = ""
        if Def_Pro_ValueType[proName] == Pro_Value_PERCENT_TYPE then
          tempText = string.format("%s%s%%", Def_Pro_Name[proName] or "", Value2Str(math.abs(kangProTable[proName]) * 100, 1))
        else
          tempText = string.format("%s%d", Def_Pro_Name[proName] or "", math.floor(math.abs(kangProTable[proName])))
        end
        local text = self:getNode(string.format("kang_%d", index))
        text:setText(tempText)
        self:attrclick_check_withWidgetObj(self:getNode(string.format("kangtext_%d", index)), proName)
        self:attrclick_check_withWidgetObj(text, proName, self:getNode(string.format("kangtext_%d", index)))
        index = index + 1
        if index > 2 then
          break
        end
      end
    end
  end
end
function CPetList_PageXiChong:setAttrValue(txtname, propertyname, maxValue, oldValue, compare, isfloat)
  local value = self.m_PetIns:getProperty(propertyname)
  if compare then
    if maxValue <= 0 then
      self.m_BasePagePotential:hideTipTxt(txtname)
    elseif maxValue <= value then
      self.m_BasePagePotential:showTipTxt(txtname, "最高", VIEW_DEF_PGREEN_COLOR)
    else
      local dnum = value - oldValue
      if isfloat then
        if dnum >= 0.001 then
          self.m_BasePagePotential:showTipTxt("text_czl", string.format("+%s", Value2Str(dnum, 3)), VIEW_DEF_PGREEN_COLOR)
        elseif dnum <= -0.001 then
          self.m_BasePagePotential:showTipTxt("text_czl", string.format("%s", Value2Str(dnum, 3)), VIEW_DEF_WARNING_COLOR)
        else
          self.m_BasePagePotential:hideTipTxt(txtname)
        end
      elseif dnum > 0 then
        self.m_BasePagePotential:showTipTxt(txtname, string.format("+%d", dnum), VIEW_DEF_PGREEN_COLOR)
      elseif dnum < 0 then
        self.m_BasePagePotential:showTipTxt(txtname, tostring(dnum), VIEW_DEF_WARNING_COLOR)
      else
        self.m_BasePagePotential:hideTipTxt(txtname)
      end
    end
  end
  return value
end
function CPetList_PageXiChong:SetItemNum()
  local num = g_LocalPlayer:GetItemNum(self.m_ItemTypeId)
  local txt_itemnum = self:getNode("txt_itemnum")
  txt_itemnum:setText(string.format("%d/%d", num, self.m_XiNeedNum))
  if num < self.m_XiNeedNum then
    txt_itemnum:setColor(VIEW_DEF_WARNING_COLOR)
  else
    txt_itemnum:setColor(VIEW_DEF_PGREEN_COLOR)
  end
end
function CPetList_PageXiChong:OnBtn_Confirm(obj, t)
  local curTime = cc.net.SocketTCP.getTime()
  if self.m_LastClickTime ~= nil then
    local delTime = 1
    if delTime > curTime - self.m_LastClickTime then
      return
    end
  end
  self.m_LastClickTime = curTime
  self.m_PetlistObj:OnBtn_Potential()
  local roleId = self.m_PetIns:getObjId()
  netsend.netitem.requestBuyAndUseItem(self.m_ItemTypeId, roleId, self.m_XiNeedNum)
end
function CPetList_PageXiChong:OnBtn_Help(obj, t)
  getCurSceneView():addSubView({
    subView = CPetXiHelp.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
function CPetList_PageXiChong:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_ItemInfo_AddItem then
    local lType = arg[3]
    if lType == self.m_ItemTypeId then
      self:SetItemNum()
    end
  elseif msgSID == MsgID_ItemInfo_DelItem then
    local lType = arg[2]
    if lType == self.m_ItemTypeId then
      self:SetItemNum()
    end
  elseif msgSID == MsgID_ItemInfo_ChangeItemNum then
    local lType = arg[3]
    if lType == self.m_ItemTypeId then
      self:SetItemNum()
    end
  elseif msgSID == MsgID_PetUpdate then
    local data = arg[1]
    if data.petId == self.m_PetIns:getObjId() then
      local proTable = data.pro
      for _, xiPro in pairs({
        PROPERTY_RANDOM_GROWUP,
        PROPERTY_RANDOM_HPBASE,
        PROPERTY_RANDOM_MPBASE,
        PROPERTY_RANDOM_APBASE,
        PROPERTY_RANDOM_SPBASE
      }) do
        if proTable[xiPro] ~= nil then
          local act1 = CCDelayTime:create(0.01)
          local act2 = CCCallFunc:create(function()
            self:SetPageAttr(true)
          end)
          self:runAction(transition.sequence({act1, act2}))
          break
        end
      end
    end
  elseif msgSID == MsgID_PetRandomKangUpdate then
    local data = arg[1]
    if data.petId == self.m_PetIns:getObjId() then
      self:SetPageKang()
    end
  end
end
function CPetList_PageXiChong:Clear()
  self.m_PetlistObj = nil
  self.m_BasePagePotential = nil
end
CPetXiHelp = class("CPetXiHelp", CcsSubView)
function CPetXiHelp:ctor()
  CPetXiHelp.super.ctor(self, "views/jinluilutip.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
end
function CPetXiHelp:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end

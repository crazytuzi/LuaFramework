CPetList_BasePotential = class(".CPetList_BasePotential", CcsSubView)
function CPetList_BasePotential:ctor(petId)
  CPetList_BasePotential.super.ctor(self, "views/pet_list_potential.json")
  local btnBatchListener = {
    btn_useCZD = {
      listener = handler(self, self.OnBtn_USE_CZD),
      variName = "btn_useCZD"
    },
    btn_addHJD = {
      listener = handler(self, self.OnBtn_USE_HJD),
      variName = "btn_addHJD"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  local size = self.btn_useCZD:getContentSize()
  self:adjustClickSize(self.btn_useCZD, size.width + 30, size.height + 30, true)
  local size = self.btn_addHJD:getContentSize()
  self:adjustClickSize(self.btn_addHJD, size.width + 30, size.height + 30, true)
  self.m_PetId = nil
  self.txt_pro_czl = self:getNode("txt_pro_czl")
  self.pro_pro_czl = self:getNode("pro_pro_czl")
  self.txt_pro_qx = self:getNode("txt_pro_qx")
  self.pro_pro_qx = self:getNode("pro_pro_qx")
  self.txt_pro_fl = self:getNode("txt_pro_fl")
  self.pro_pro_fl = self:getNode("pro_pro_fl")
  self.txt_pro_gj = self:getNode("txt_pro_gj")
  self.pro_pro_gj = self:getNode("pro_pro_gj")
  self.txt_pro_sd = self:getNode("txt_pro_sd")
  self.pro_pro_sd = self:getNode("pro_pro_sd")
  self.layer_compare = self:getNode("layer_compare")
  self:LoadPet(petId)
  self:SetAttrTips()
  self:ListenMessage(MsgID_PlayerInfo)
end
function CPetList_BasePotential:SetAttrTips()
  clickArea_check.extend(self)
  self:attrclick_check_withWidgetObj(self:getNode("txt_czl"), PROPERTY_GROWUP)
  self:attrclick_check_withWidgetObj(self:getNode("pic_probg_czl"), PROPERTY_GROWUP, self:getNode("txt_czl"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_qx"), PROPERTY_RANDOM_HPBASE)
  self:attrclick_check_withWidgetObj(self:getNode("pic_probg_qx"), PROPERTY_RANDOM_HPBASE, self:getNode("txt_qx"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_fl"), PROPERTY_RANDOM_MPBASE)
  self:attrclick_check_withWidgetObj(self:getNode("pic_probg_fl"), PROPERTY_RANDOM_MPBASE, self:getNode("txt_fl"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_gj"), PROPERTY_RANDOM_APBASE)
  self:attrclick_check_withWidgetObj(self:getNode("pic_probg_gj"), PROPERTY_RANDOM_APBASE, self:getNode("txt_gj"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_sd"), PROPERTY_RANDOM_SPBASE)
  self:attrclick_check_withWidgetObj(self:getNode("pic_probg_sd"), PROPERTY_RANDOM_SPBASE, self:getNode("txt_sd"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_czd"), "itemczd")
  self:attrclick_check_withWidgetObj(self:getNode("pic_probg_czd"), "itemczd", self:getNode("txt_czd"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_hj"), "itemhjd", nil, handler(self, self.getPetInsLevel))
  self:attrclick_check_withWidgetObj(self:getNode("pic_probg_hj"), "itemhjd", self:getNode("txt_hj"), handler(self, self.getPetInsLevel))
end
function CPetList_BasePotential:getPetInsLevel()
  if self.m_PetIns == nil then
    return nil
  end
  return self.m_PetIns:getTypeId()
end
function CPetList_BasePotential:LoadPet(petId)
  if self.m_PetId == petId then
    return
  end
  self.m_PetId = petId
  self.m_PetIns = g_LocalPlayer:getObjById(self.m_PetId)
  self:SetBasePotential()
end
function CPetList_BasePotential:SetBasePotential()
  local petTypeId = self.m_PetIns:getTypeId()
  local petData = data_Pet[petTypeId] or {}
  if petData == nil then
    return
  end
  local czl = self.m_PetIns:getProperty(PROPERTY_GROWUP)
  local addCzl = self.m_PetIns:getProperty(PROPERTY_ZHUANSHENG) * 0.1 + self.m_PetIns:getProperty(PROPERTY_LONGGU_NUM) * 0.01
  local hjNum = self.m_PetIns:getProperty(PROPERTY_HUAJING_NUM)
  if hjNum == 1 then
    addCzl = addCzl + data_Variables.SS_HuaJing1_AddCZL or 0.05
  elseif hjNum == 2 then
    addCzl = addCzl + (data_Variables.SS_HuaJing1_AddCZL or 0.05) + (data_Variables.SS_HuaJing2_AddCZL or 0.1)
  elseif hjNum == 3 then
    addCzl = addCzl + (data_Variables.SS_HuaJing1_AddCZL or 0.05) + (data_Variables.SS_HuaJing2_AddCZL or 0.1)
  end
  local hlNum = self.m_PetIns:getProperty(PROPERTY_HUALING_NUM)
  for huaLingIndex = 1, LINGSHOU_HUALING_MAX_NUM do
    if huaLingIndex <= hlNum then
      addCzl = addCzl + data_LingShouHuaLing[huaLingIndex].addCZL
    end
  end
  local czl_max = petData.GROWUP * 1.02 + addCzl
  local czl_min = petData.GROWUP * 0.98 + addCzl
  self.txt_pro_czl:setText(string.format("%s/%s", Value2Str(czl, 3), Value2Str(czl_max, 3)))
  if czl_max ~= czl_min then
    self.pro_pro_czl:setPercent(math.max(math.min((czl - czl_min) / (czl_max - czl_min) * 100, 100), 0))
  else
    self.pro_pro_czl:setPercent(100)
  end
  czl_max = math.floor(czl_max * 1000) / 1000
  if czl >= czl_max and czl > 0 then
    self:showTipTxt("text_czl", "最高", VIEW_DEF_PGREEN_COLOR)
  else
    self:hideTipTxt("text_czl")
  end
  local addqx = self.m_PetIns:getProperty(PROPERTY_LONGGU_ADDHP) + self.m_PetIns:getProperty(PROPERTY_HUAJING_ADDHP)
  local qx = self.m_PetIns:getProperty(PROPERTY_RANDOM_HPBASE) + addqx
  local qx_max = math.floor(petData.HP * 1.2 + 1.0E-8 + addqx)
  local qx_min = math.floor(petData.HP * 0.8 + 1.0E-8 + addqx)
  self.txt_pro_qx:setText(string.format("%d/%d", qx, qx_max))
  if qx_max ~= qx_min then
    self.pro_pro_qx:setPercent(math.min((qx - qx_min) / (qx_max - qx_min) * 100, 100))
  else
    self.pro_pro_qx:setPercent(100)
  end
  if qx >= qx_max and addqx < qx then
    self:showTipTxt("text_qx", "最高", VIEW_DEF_PGREEN_COLOR)
  else
    self:hideTipTxt("text_qx")
  end
  local addfl = self.m_PetIns:getProperty(PROPERTY_LONGGU_ADDMP) + self.m_PetIns:getProperty(PROPERTY_HUAJING_ADDMP)
  local fl = self.m_PetIns:getProperty(PROPERTY_RANDOM_MPBASE) + addfl
  local fl_max = math.floor(petData.MP * 1.2 + 1.0E-8 + addfl)
  local fl_min = math.floor(petData.MP * 0.8 + 1.0E-8 + addfl)
  self.txt_pro_fl:setText(string.format("%d/%d", fl, fl_max))
  if fl_max ~= fl_min then
    self.pro_pro_fl:setPercent(math.min((fl - fl_min) / (fl_max - fl_min) * 100, 100))
  else
    self.pro_pro_fl:setPercent(100)
  end
  if fl >= fl_max and addfl < fl then
    self:showTipTxt("text_fl", "最高", VIEW_DEF_PGREEN_COLOR)
  else
    self:hideTipTxt("text_fl")
  end
  local addgj = self.m_PetIns:getProperty(PROPERTY_LONGGU_ADDAP) + self.m_PetIns:getProperty(PROPERTY_HUAJING_ADDAP)
  local gj = self.m_PetIns:getProperty(PROPERTY_RANDOM_APBASE) + addgj
  local gj_max = math.floor(petData.AP * 1.2 + 1.0E-8 + addgj)
  local gj_min = math.floor(petData.AP * 0.8 + 1.0E-8 + addgj)
  self.txt_pro_gj:setText(string.format("%d/%d", gj, gj_max))
  if gj_max ~= gj_min then
    self.pro_pro_gj:setPercent(math.min((gj - gj_min) / (gj_max - gj_min) * 100, 100))
  else
    self.pro_pro_gj:setPercent(100)
  end
  if gj >= gj_max and addgj < gj then
    self:showTipTxt("text_gj", "最高", VIEW_DEF_PGREEN_COLOR)
  else
    self:hideTipTxt("text_gj")
  end
  local addsd = self.m_PetIns:getProperty(PROPERTY_LONGGU_ADDSP) + self.m_PetIns:getProperty(PROPERTY_HUAJING_ADDSP)
  local sd = self.m_PetIns:getProperty(PROPERTY_RANDOM_SPBASE) + addsd
  local sd_max = math.floor(petData.SP * 1.2 + 1.0E-8 + addsd)
  local sd_min = math.floor(petData.SP * 0.8 + 1.0E-8 + addsd)
  self.txt_pro_sd:setText(string.format("%d/%d", sd, sd_max))
  if sd_max ~= sd_min then
    self.pro_pro_sd:setPercent(math.min((sd - sd_min) / (sd_max - sd_min) * 100, 100))
  else
    self.pro_pro_sd:setPercent(100)
  end
  if sd > 0 then
    if sd >= sd_max and addsd < sd then
      self:showTipTxt("text_sd", "最高", VIEW_DEF_PGREEN_COLOR)
    else
      self:hideTipTxt("text_sd")
    end
  elseif sd <= sd_max and addsd > sd then
    self:showTipTxt("text_sd", "最高", VIEW_DEF_PGREEN_COLOR)
  else
    self:hideTipTxt("text_sd")
  end
  self:SetCZD_And_HJD_And_HLW()
end
function CPetList_BasePotential:showTipTxt(txtname, txtvalue, txtcolor)
  local txt_2 = self:getNode(string.format("%s_%d", txtname, 2))
  txt_2:setVisible(true)
  txt_2:setText(txtvalue)
  txt_2:setColor(txtcolor)
end
function CPetList_BasePotential:hideTipTxt(txtname)
  local txt_2 = self:getNode(string.format("%s_%d", txtname, 2))
  txt_2:setVisible(false)
end
function CPetList_BasePotential:SetCZD_And_HJD_And_HLW()
  if self.m_PetIns == nil then
    return
  end
  if data_getPetTypeIsCanHuaLing(self.m_PetIns:getTypeId()) == false and data_getPetTypeIsCanHuaJing(self.m_PetIns:getTypeId()) == false then
    self:getNode("txt_hj"):setVisible(false)
    self:getNode("pic_probg_hj"):setVisible(false)
    self:getNode("txt_hj"):setTouchEnabled(false)
    self:getNode("pic_probg_hj"):setTouchEnabled(false)
    self:getNode("txt_pro_hj"):setVisible(false)
    self.btn_addHJD:setVisible(false)
    self.btn_addHJD:setTouchEnabled(false)
  else
    self:getNode("txt_hj"):setVisible(true)
    self:getNode("pic_probg_hj"):setVisible(true)
    self:getNode("txt_hj"):setTouchEnabled(true)
    self:getNode("pic_probg_hj"):setTouchEnabled(true)
    self:getNode("txt_pro_hj"):setVisible(true)
    self.btn_addHJD:setVisible(true)
    self.btn_addHJD:setTouchEnabled(true)
  end
  local czdNum = self.m_PetIns:getProperty(PROPERTY_LONGGU_NUM)
  self:getNode("txt_pro_czd"):setText(string.format("%d/3", czdNum))
  if data_getPetTypeIsCanHuaLing(self.m_PetIns:getTypeId()) then
    self:getNode("txt_hj"):setText("化灵")
    local hlNum = self.m_PetIns:getProperty(PROPERTY_HUALING_NUM)
    self:getNode("txt_pro_hj"):setText(string.format("%d/%d", hlNum, LINGSHOU_HUALING_MAX_NUM))
  else
    self:getNode("txt_hj"):setText("化境")
    local hjNum = self.m_PetIns:getProperty(PROPERTY_HUAJING_NUM)
    self:getNode("txt_pro_hj"):setText(string.format("%d/3", hjNum))
  end
end
function CPetList_BasePotential:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_PetUpdate then
    local d = arg[1]
    if d.petId == self.m_PetId then
      self:SetBasePotential()
    end
  end
end
function CPetList_BasePotential:OnBtn_USE_CZD(obj, objType)
  if self.m_PetIns:getProperty(PROPERTY_LONGGU_NUM) >= 3 then
    ShowNotifyTips("每个宠物最多只能使用3个成长丹")
    return
  end
  local function useFunc()
    netsend.netitem.requestUseItemByGold(ITEM_DEF_OTHER_LZG, 1, self.m_PetId)
  end
  local dlg = CPetUseItemView.new(self.m_PetId, ITEM_DEF_OTHER_LZG, 1, useFunc)
  getCurSceneView():addSubView({
    subView = dlg,
    zOrder = MainUISceneZOrder.menuView
  })
end
function CPetList_BasePotential:OnBtn_USE_HJD(obj, objType)
  if data_getPetTypeIsCanHuaLing(self.m_PetIns:getTypeId()) == false and data_getPetTypeIsCanHuaJing(self.m_PetIns:getTypeId()) == false then
    return
  end
  if data_getPetTypeIsCanHuaJing(self.m_PetIns:getTypeId()) then
    local hjNum = self.m_PetIns:getProperty(PROPERTY_HUAJING_NUM)
    local tempData = data_ShenShouHuaJing[hjNum + 1]
    local needLv = tempData.needLv
    local needZs = tempData.needZs
    local alwaysJudgeLvFlag = tempData.AlwaysJudgeLvFlag
    local curZs = self.m_PetIns:getProperty(PROPERTY_ZHUANSHENG)
    local curLv = self.m_PetIns:getProperty(PROPERTY_ROLELEVEL)
    local canHJFlag = data_judgeFuncOpen(curZs, curLv, needZs, needLv, alwaysJudgeLvFlag)
    if hjNum == 0 then
      if not canHJFlag then
        ShowNotifyTips(tempData.tip or "")
        return
      end
    elseif hjNum == 1 then
      if not canHJFlag then
        ShowNotifyTips(tempData.tip or "")
        return
      end
    elseif hjNum == 2 then
      if not canHJFlag then
        ShowNotifyTips(tempData.tip or "")
        return
      end
    elseif hjNum == 3 and not canHJFlag then
      ShowNotifyTips(tempData.tip or "")
      return
    end
    local dlg = CShenShouHuajing.new(self.m_PetId)
    getCurSceneView():addSubView({
      subView = dlg,
      zOrder = MainUISceneZOrder.menuView
    })
  elseif data_getPetTypeIsCanHuaLing(self.m_PetIns:getTypeId()) then
    local hlNum = self.m_PetIns:getProperty(PROPERTY_HUALING_NUM)
    if hlNum >= LINGSHOU_HUALING_MAX_NUM then
      ShowNotifyTips("灵兽最多化灵9次")
      return
    end
    local tempData = data_LingShouHuaLing[hlNum + 1]
    local needLv = tempData.needLv
    local needZs = tempData.needZs
    local alwaysJudgeLvFlag = tempData.AlwaysJudgeLvFlag
    local curZs = self.m_PetIns:getProperty(PROPERTY_ZHUANSHENG)
    local curLv = self.m_PetIns:getProperty(PROPERTY_ROLELEVEL)
    local canHLFlag = data_judgeFuncOpen(curZs, curLv, needZs, needLv, alwaysJudgeLvFlag)
    if not canHLFlag then
      ShowNotifyTips(tempData.tip or "")
      return
    end
    local dlg = CLingShouHualing.new(self.m_PetId)
    getCurSceneView():addSubView({
      subView = dlg,
      zOrder = MainUISceneZOrder.menuView
    })
  end
end
function CPetList_BasePotential:Clear()
  self.m_PetIns = nil
end
CPetUseItemView = class(".CPetUseItemView", CcsSubView)
function CPetUseItemView:ctor(petId, itemTypeId, num, confirmFunc)
  CPetUseItemView.super.ctor(self, "views/petlist_useitem.json", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_cancel = {
      listener = handler(self, self.OnBtn_Cancel),
      variName = "btn_cancel"
    },
    btn_confirm = {
      listener = handler(self, self.OnBtn_Confirm),
      variName = "btn_confirm"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_PetId = petId
  self.m_ItemTypeId = itemTypeId
  self.m_NeedNum = num
  self.m_ConfirmFunc = confirmFunc
  local itemPj = data_getItemPinjie(self.m_ItemTypeId)
  local textColor = NameColor_Item[itemPj] or NameColor_Item[0]
  local itemName = data_getItemName(itemTypeId)
  self:getNode("title"):setText(itemName)
  self:getNode("title"):setColor(textColor)
  local iconpos = self:getNode("iconpos")
  iconpos:setVisible(false)
  local p = iconpos:getParent()
  local x, y = iconpos:getPosition()
  local itemIcon = createClickItem({
    itemID = itemTypeId,
    clickListener = handler(self, self.OnClickItem),
    num = num,
    numType = 1
  })
  p:addChild(itemIcon)
  itemIcon:setPosition(ccp(x, y))
  self.m_ItemIcon = itemIcon
  local tip = self:getNode("tip")
  tip:setVisible(false)
  local p = tip:getParent()
  local size = tip:getContentSize()
  local x, y = tip:getPosition()
  local tipBox = CRichText.new({
    width = size.width,
    color = ccc3(255, 255, 255),
    fontSize = 20
  })
  p:addChild(tipBox)
  local petIns = g_LocalPlayer:getObjById(self.m_PetId)
  local petName = petIns:getProperty(PROPERTY_NAME)
  local zs = petIns:getProperty(PROPERTY_ZHUANSHENG)
  local namecolor = NameColor_Pet[zs] or ccc3(255, 255, 255)
  local text = string.format("你确定要对#<r:%d,g:%d,b:%d>%s#使用吗？", namecolor.r, namecolor.g, namecolor.b, petName)
  tipBox:addRichText(text)
  local tipBoxSize = tipBox:getRealRichTextSize()
  tipBox:setPosition(ccp(x, y + size.height - tipBoxSize.height))
  self:ListenMessage(MsgID_MoveScene)
  self:ListenMessage(MsgID_ItemInfo)
end
function CPetUseItemView:OnClickItem()
  self.m_PopItemDetail = CEquipDetail.new(nil, {
    closeListener = handler(self, self.CloseItemDetail),
    itemType = self.m_ItemTypeId
  })
  getCurSceneView():addSubView({
    subView = self.m_PopItemDetail,
    zOrder = MainUISceneZOrder.menuView
  })
  self.m_PopItemDetail:ShowCloseBtn()
  local size = self.m_PopItemDetail:getBoxSize()
  self.m_PopItemDetail:setPosition(ccp(display.width / 2 - size.width / 2, display.height / 2 - size.height / 2))
end
function CPetUseItemView:OnBtn_Close()
  self:CloseSelf()
end
function CPetUseItemView:OnBtn_Cancel()
  self:CloseSelf()
end
function CPetUseItemView:OnBtn_Confirm()
  if self.m_ConfirmFunc then
    self.m_ConfirmFunc()
  end
  self:CloseSelf()
end
function CPetUseItemView:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_ItemSource_Jump then
    self:CloseItemDetail()
    self:CloseSelf()
    if g_PetListDlg then
      g_PetListDlg:CloseSelf()
    end
  elseif msgSID == MsgID_ItemInfo_AddItem then
    if self.m_ItemTypeId == arg[3] then
      self:updateItemNum()
    end
  elseif msgSID == MsgID_ItemInfo_DelItem then
    if self.m_ItemTypeId == arg[2] then
      self:updateItemNum()
    end
  elseif msgSID == MsgID_ItemInfo_ChangeItemNum and self.m_ItemTypeId == arg[3] then
    self:updateItemNum()
  end
end
function CPetUseItemView:updateItemNum()
  local myNum = g_LocalPlayer:GetItemNum(self.m_ItemTypeId)
  self.m_ItemIcon._numLabel:setString(string.format("%d/%d", myNum, self.m_NeedNum))
  if myNum < self.m_NeedNum then
    self.m_ItemIcon._numLabel:setColor(ccc3(255, 0, 0))
  else
    self.m_ItemIcon._numLabel:setColor(ccc3(0, 255, 0))
  end
  AutoLimitObjSize(self.m_ItemIcon._numLabel, 70)
end
function CPetUseItemView:CloseItemDetail()
  if self.m_PopItemDetail then
    self.m_PopItemDetail:CloseSelf()
    self.m_PopItemDetail = nil
  end
end
function CPetUseItemView:Clear()
  self:CloseItemDetail()
end
CShenShouHuajing = class(".CShenShouHuajing", CcsSubView)
function CShenShouHuajing:ctor(petId)
  CShenShouHuajing.super.ctor(self, "views/petlist_shenshouhuajing.json", {isAutoCenter = true, opacityBg = 100})
  self.m_PetId = petId
  self.m_PetIns = g_LocalPlayer:getObjById(self.m_PetId)
  self.m_HjNum = self.m_PetIns:getProperty(PROPERTY_HUAJING_NUM)
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_confirm = {
      listener = handler(self, self.OnBtn_Confirm),
      variName = "btn_confirm"
    },
    btn_qx = {
      listener = handler(self, self.OnBtn_SelectQX),
      variName = "btn_qx"
    },
    btn_fl = {
      listener = handler(self, self.OnBtn_SelectFL),
      variName = "btn_fl"
    },
    btn_gj = {
      listener = handler(self, self.OnBtn_SelectGJ),
      variName = "btn_gj"
    },
    btn_sd = {
      listener = handler(self, self.OnBtn_SelectSD),
      variName = "btn_sd"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:SetTextData()
  self:SetBtnData()
end
function CShenShouHuajing:SetTextData()
  local tempData = data_ShenShouHuaJing[self.m_HjNum + 1]
  local conditionText = ""
  local needLv = tempData.needLv or 0
  local needZs = tempData.needZs or 0
  local needHJD = tempData.needHJD or 0
  if self.m_HjNum == 0 then
    local hjGrowup = data_Variables.SS_HuaJing1_AddCZL or 0.05
    conditionText = string.format("一次化境:神兽要求达到%d转%d级,消耗%d颗化境丹\n效果:神兽成长率增加%s", needZs, needLv, needHJD, tostring(hjGrowup))
    conditionText = string.format("%s\n\n#<IRP,CTP>下一次化境提示:#\n", conditionText)
    local new_tempData = data_ShenShouHuaJing[2]
    local new_needLv = new_tempData.needLv or 0
    local new_needZs = new_tempData.needZs or 0
    local new_needHJD = new_tempData.needHJD or 0
    local new_hjGrowup = data_Variables.SS_HuaJing2_AddCZL or 0.1
    conditionText = string.format("%s二次化境:神兽要求达到%d转%d级,消耗%d颗化境丹\n效果:神兽成长率增加%s", conditionText, new_needZs, new_needLv, new_needHJD, tostring(new_hjGrowup))
  elseif self.m_HjNum == 1 then
    local hjGrowup = data_Variables.SS_HuaJing2_AddCZL or 0.1
    conditionText = string.format("二次化境:神兽要求达到%d转%d级,消耗%d颗化境丹\n效果:神兽成长率增加%s", needZs, needLv, needHJD, tostring(hjGrowup))
    conditionText = string.format("%s\n\n#<IRP,CTP>下一次化境提示:#\n", conditionText)
    local new_tempData = data_ShenShouHuaJing[3]
    local new_needLv = new_tempData.needLv or 0
    local new_needZs = new_tempData.needZs or 0
    local new_needHJD = new_tempData.needHJD or 0
    local new_tempAddNum = data_Variables.SS_HuaJing3_AddProNum or 60
    conditionText = string.format("%s三次化境:神兽要求达到%d转%d级,消耗%d颗化境丹\n效果:选择一项初值+%d点", conditionText, new_needZs, new_needLv, new_needHJD, new_tempAddNum)
  elseif self.m_HjNum == 2 then
    local tempAddNum = data_Variables.SS_HuaJing3_AddProNum or 60
    conditionText = string.format("三次化境:神兽要求达到%d转%d级,消耗%d颗化境丹\n效果:选择一项初值+%d点", needZs, needLv, needHJD, tempAddNum)
  elseif self.m_HjNum == 3 then
    conditionText = string.format("转换初值:消耗%d颗化境丹\n效果:转换第三次化境的初值", needHJD)
  end
  local tipsText = ""
  if self.m_HjNum == 2 then
    tipsText = "#<IRP>#如对当前初值不满意,可进行初值转换"
  elseif self.m_HjNum == 3 then
    tipsText = "#<IRP>#如对当前初值不满意,可进行初值转换"
  end
  local cBox = self:getNode("condition_box")
  local size = cBox:getContentSize()
  if self.m_ConditionText == nil then
    self.m_ConditionText = CRichText.new({
      width = size.width,
      fontSize = 20,
      color = ccc3(255, 255, 255),
      align = CRichText_AlignType_Left
    })
    self:addChild(self.m_ConditionText)
  else
    self.m_ConditionText:clearAll()
  end
  self.m_ConditionText:addRichText(conditionText)
  local h = self.m_ConditionText:getContentSize().height
  local x, y = cBox:getPosition()
  self.m_ConditionText:setPosition(ccp(x, y + (size.height - h)))
  local tBox = self:getNode("tips_box")
  local size = tBox:getContentSize()
  if self.m_TipsText == nil then
    self.m_TipsText = CRichText.new({
      width = size.width,
      fontSize = 17,
      color = ccc3(94, 211, 207),
      align = CRichText_AlignType_Left
    })
    self:addChild(self.m_TipsText)
  else
    self.m_TipsText:clearAll()
  end
  self.m_TipsText:addRichText(tipsText)
  local h = self.m_TipsText:getContentSize().height
  local x, y = tBox:getPosition()
  self.m_TipsText:setPosition(ccp(x, y + (size.height - h) / 2))
end
function CShenShouHuajing:SetBtnData()
  local showBtnFlag = false
  if self.m_HjNum == 2 then
    showBtnFlag = true
    self.btn_confirm:setTitleText("我要化境")
  elseif self.m_HjNum == 3 then
    showBtnFlag = true
    self.btn_confirm:setTitleText("转换初值")
  else
    showBtnFlag = false
    self.btn_confirm:setTitleText("我要化境")
  end
  self:SelectOneBtn()
  for _, str in pairs({
    "qx",
    "fl",
    "gj",
    "sd"
  }) do
    self:getNode(string.format("txt_%s", str)):setVisible(showBtnFlag)
    self:getNode(string.format("btn_%s", str)):setEnabled(showBtnFlag)
  end
end
function CShenShouHuajing:SelectOneBtn(str)
  if str == nil then
    local hjAddProNum = self.m_PetIns:getProperty(PROPERTY_HUAJING_ADDPRONUM)
    if hjAddProNum == SHENSHOU_HUAJING3_ADDHP_INDEX then
      str = "qx"
    elseif hjAddProNum == SHENSHOU_HUAJING3_ADDMP_INDEX then
      str = "fl"
    elseif hjAddProNum == SHENSHOU_HUAJING3_ADDAP_INDEX then
      str = "gj"
    elseif hjAddProNum == SHENSHOU_HUAJING3_ADDSP_INDEX then
      str = "sd"
    end
  end
  for _, tempStr in pairs({
    "qx",
    "fl",
    "gj",
    "sd"
  }) do
    local tempBtn = self:getNode(string.format("btn_%s", tempStr))
    if tempBtn and tempBtn._SelectFlag then
      tempBtn._SelectFlag:removeFromParent()
      tempBtn._SelectFlag = nil
    end
    if tempBtn and tempStr == str then
      local tempSprite = display.newSprite("views/common/btn/selected.png")
      tempSprite:setAnchorPoint(ccp(0.3, 0.3))
      tempBtn:addNode(tempSprite, 1)
      tempBtn._SelectFlag = tempSprite
    end
  end
  if str == nil then
    self.m_SelectAddProIndex = nil
  else
    local tempStr = {
      qx = SHENSHOU_HUAJING3_ADDHP_INDEX,
      fl = SHENSHOU_HUAJING3_ADDMP_INDEX,
      gj = SHENSHOU_HUAJING3_ADDAP_INDEX,
      sd = SHENSHOU_HUAJING3_ADDSP_INDEX
    }
    self.m_SelectAddProIndex = tempStr[str]
  end
end
function CShenShouHuajing:OnBtn_SelectQX()
  self:SelectOneBtn("qx")
end
function CShenShouHuajing:OnBtn_SelectFL()
  self:SelectOneBtn("fl")
end
function CShenShouHuajing:OnBtn_SelectGJ()
  self:SelectOneBtn("gj")
end
function CShenShouHuajing:OnBtn_SelectSD()
  self:SelectOneBtn("sd")
end
function CShenShouHuajing:OnBtn_Close()
  self:CloseSelf()
end
function CShenShouHuajing:OnBtn_Confirm()
  local tempData = data_ShenShouHuaJing[self.m_HjNum + 1]
  local hjAddProNum = self.m_PetIns:getProperty(PROPERTY_HUAJING_ADDPRONUM)
  local needHJD = tempData.needHJD or 0
  if self.m_HjNum == 0 then
    local function useFunc()
      netsend.netbaseptc.requestShenShouHuaJing(self.m_PetId, 1)
    end
    local dlg = CPetUseItemView.new(self.m_PetId, ITEM_DEF_OTHER_HJD, needHJD, useFunc)
    getCurSceneView():addSubView({
      subView = dlg,
      zOrder = MainUISceneZOrder.menuView
    })
    self:CloseSelf()
    return
  elseif self.m_HjNum == 1 then
    local function useFunc()
      netsend.netbaseptc.requestShenShouHuaJing(self.m_PetId, 2)
    end
    local dlg = CPetUseItemView.new(self.m_PetId, ITEM_DEF_OTHER_HJD, needHJD, useFunc)
    getCurSceneView():addSubView({
      subView = dlg,
      zOrder = MainUISceneZOrder.menuView
    })
    self:CloseSelf()
    return
  elseif self.m_HjNum == 2 then
    if self.m_SelectAddProIndex == nil then
      ShowNotifyTips("请选择一项要增加的初值")
      return
    end
    local function useFunc()
      netsend.netbaseptc.requestShenShouHuaJing(self.m_PetId, 3, self.m_SelectAddProIndex)
    end
    local dlg = CPetUseItemView.new(self.m_PetId, ITEM_DEF_OTHER_HJD, needHJD, useFunc)
    getCurSceneView():addSubView({
      subView = dlg,
      zOrder = MainUISceneZOrder.menuView
    })
    self:CloseSelf()
    return
  elseif self.m_HjNum == 3 then
    if self.m_SelectAddProIndex == nil then
      ShowNotifyTips("请选择需要转换的新初值")
      return
    end
    if self.m_SelectAddProIndex == hjAddProNum then
      ShowNotifyTips("初值没有改变,无需转换")
      return
    end
    local function useFunc()
      netsend.netbaseptc.requestSetShenShouHJCZ(self.m_PetId, self.m_SelectAddProIndex)
    end
    local dlg = CPetUseItemView.new(self.m_PetId, ITEM_DEF_OTHER_HJD, needHJD, useFunc)
    getCurSceneView():addSubView({
      subView = dlg,
      zOrder = MainUISceneZOrder.menuView
    })
    self:CloseSelf()
    return
  end
end
function CShenShouHuajing:Clear()
end
CLingShouHualing = class(".CLingShouHualing", CcsSubView)
function CLingShouHualing:ctor(petId)
  CLingShouHualing.super.ctor(self, "views/petlist_lingshouhualing.json", {isAutoCenter = true, opacityBg = 100})
  self.m_PetId = petId
  self.m_PetIns = g_LocalPlayer:getObjById(self.m_PetId)
  self.m_HlNum = self.m_PetIns:getProperty(PROPERTY_HUALING_NUM)
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_confirm = {
      listener = handler(self, self.OnBtn_Confirm),
      variName = "btn_confirm"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:SetTextData()
end
function CLingShouHualing:SetTextData()
  local tempData = data_LingShouHuaLing[self.m_HlNum + 1]
  local conditionText = ""
  local needLv = tempData.needLv or 0
  local needZs = tempData.needZs or 0
  local needHLW = tempData.needHLW or 0
  local addCZL = tempData.addCZL or 0
  local tempDict = {
    "一",
    "二",
    "三",
    "四",
    "五",
    "六",
    "七",
    "八",
    "九"
  }
  if self.m_HlNum + 1 >= LINGSHOU_HUALING_MAX_NUM then
    conditionText = string.format("%s次化灵:灵兽要求达到%d转%d级,消耗%d颗化灵丸\n效果:灵兽成长率增加%s", tempDict[self.m_HlNum + 1], needZs, needLv, needHLW, tostring(addCZL))
  else
    conditionText = string.format("%s次化灵:灵兽要求达到%d转%d级,消耗%d颗化灵丸\n效果:灵兽成长率增加%s", tempDict[self.m_HlNum + 1], needZs, needLv, needHLW, tostring(addCZL))
    conditionText = string.format("%s\n\n#<IRP,CTP>下一次化灵提示:#\n", conditionText)
    local new_tempData = data_LingShouHuaLing[self.m_HlNum + 2]
    local new_needLv = new_tempData.needLv or 0
    local new_needZs = new_tempData.needZs or 0
    local new_needHLW = new_tempData.needHLW or 0
    local new_addCZL = new_tempData.addCZL or 0
    conditionText = string.format("%s%s次化灵:灵兽要求达到%d转%d级,消耗%d颗化灵丸\n效果:灵兽成长率增加%s", conditionText, tempDict[self.m_HlNum + 2], new_needZs, new_needLv, new_needHLW, tostring(new_addCZL))
  end
  local cBox = self:getNode("condition_box")
  local size = cBox:getContentSize()
  if self.m_ConditionText == nil then
    self.m_ConditionText = CRichText.new({
      width = size.width,
      fontSize = 20,
      color = ccc3(255, 255, 255),
      align = CRichText_AlignType_Left
    })
    self:addChild(self.m_ConditionText)
  else
    self.m_ConditionText:clearAll()
  end
  self.m_ConditionText:addRichText(conditionText)
  local h = self.m_ConditionText:getContentSize().height
  local x, y = cBox:getPosition()
  self.m_ConditionText:setPosition(ccp(x, y + (size.height - h)))
end
function CLingShouHualing:OnBtn_Close()
  self:CloseSelf()
end
function CLingShouHualing:OnBtn_Confirm()
  if self.m_HlNum >= LINGSHOU_HUALING_MAX_NUM then
    ShowNotifyTips("灵兽最多化灵9次")
    return
  end
  local tempData = data_LingShouHuaLing[self.m_HlNum + 1]
  local needHLW = tempData.needHLW or 0
  local function useFunc()
    netsend.netbaseptc.requestLingShouHuaLing(self.m_PetId)
  end
  local dlg = CPetUseItemView.new(self.m_PetId, ITEM_DEF_OTHER_HUALINGWAN, needHLW, useFunc)
  getCurSceneView():addSubView({
    subView = dlg,
    zOrder = MainUISceneZOrder.menuView
  })
  self:CloseSelf()
  return
end
function CLingShouHualing:Clear()
end

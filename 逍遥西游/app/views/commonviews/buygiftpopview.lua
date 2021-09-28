POP_Show_DASHU = 1
POP_Show_ZHUBO = 2
POP_Show_CUXIAO = 3
POP_Show_CHONGZHIFANLI = 4
POP_Show_PAIMAITSSS = 5
POP_Show_XIAOFEIFANLI = 6
POP_Show_XIANQISUIPIAN = 7
POP_Weekly_Shop_Item1 = 12
POP_Weekly_Shop_Item2 = 13
POP_Weekly_Shop_Item3 = 14
WEEKLY_SHOP_ITEM_LIST = {
  POP_Weekly_Shop_Item1,
  POP_Weekly_Shop_Item2,
  POP_Weekly_Shop_Item3
}
POP_BUY_VIEW_BTN_NAME_DICT = {
  "神\n兽\n倒\n拍",
  "充\n值\n返\n利",
  "消\n费\n返\n利",
  "送\n神\n兽\n蛋",
  "赞\n助\n游\n戏"
}
POP_BUY_VIEW_BTN_INDEX_DICT = {
  POP_Show_PAIMAITSSS,
  POP_Show_CHONGZHIFANLI,
  POP_Show_XIAOFEIFANLI,
  POP_Show_XIANQISUIPIAN,
  POP_Show_CUXIAO
}
function GetPopBuyViewBtnData()
  local pmssFlag = false
  local czflFlag = false
  local xfflFlag = false
  local spzsFlag = false
  local bztmFlag = false
  if g_LocalPlayer then
    pmssFlag = g_LocalPlayer:JudgeCanGetPaiMaiShenShou()
    czflFlag = g_LocalPlayer:JudgeCanGetChongZhiFanli()
    xfflFlag = g_LocalPlayer:JudgeCanGetXiaoFeiFanLi()
    spzsFlag = g_LocalPlayer:JudgeCanGetXianQiSuiPian()
    bztmFlag = g_LocalPlayer:JudgeCanGetBenZhouTeMai()
  end
  local flagDict = {
    pmssFlag,
    czflFlag,
    xfflFlag,
    spzsFlag,
    bztmFlag
  }
  local btnNameDict = POP_BUY_VIEW_BTN_NAME_DICT
  local buyGiftDict = POP_BUY_VIEW_BTN_INDEX_DICT
  local openIndexList
  for i = 1, 5 do
    if flagDict[i] then
      if openIndexList == nil then
        openIndexList = {}
      end
      openIndexList[#openIndexList + 1] = i
      if #openIndexList >= 3 then
        break
      end
    end
  end
  return openIndexList, btnNameDict, buyGiftDict
end
function ChangeTextIntoVerticalText(inputText)
  local outputText = ""
  if inputText == nil or inputText == "" or type(inputText) ~= "string" then
    return outputText
  end
  local len = string.len(inputText)
  for i = 1, len do
    local char = string.byte(inputText, i)
    if i == 1 then
      outputText = outputText .. string.sub(inputText, i, i)
    elseif char < 128 then
      outputText = outputText .. "\n"
      outputText = outputText .. string.sub(inputText, i, i)
    elseif char >= 192 then
      outputText = outputText .. "\n"
      outputText = outputText .. string.sub(inputText, i, i)
    else
      outputText = outputText .. string.sub(inputText, i, i)
    end
  end
  return outputText
end
function ShowPopBuyGiftPopView(popType)
  if popType == POP_Show_DASHU then
    local popView = CBuyDaShuGiftPopView.new()
    getCurSceneView():addSubView({
      subView = popView,
      zOrder = MainUISceneZOrder.menuView
    })
  elseif popType == POP_Show_ZHUBO then
    local popView = CZhuBoZhaoMuPopView.new()
    getCurSceneView():addSubView({
      subView = popView,
      zOrder = MainUISceneZOrder.menuView
    })
  elseif popType == POP_Show_CUXIAO then
    local popView = CBuyCuXiaoGiftPopView.new()
    getCurSceneView():addSubView({
      subView = popView,
      zOrder = MainUISceneZOrder.menuView
    })
  elseif popType == POP_Show_CHONGZHIFANLI then
    local popView = CBuyCZFLGiftPopView.new()
    getCurSceneView():addSubView({
      subView = popView,
      zOrder = MainUISceneZOrder.menuView
    })
  elseif popType == POP_Show_PAIMAITSSS then
    local popView = CBuyPaiMaiShenShouPopView.new()
    getCurSceneView():addSubView({
      subView = popView,
      zOrder = MainUISceneZOrder.menuView
    })
  elseif popType == POP_Show_XIAOFEIFANLI then
    local popView = CBuyXFFLGiftPopView.new()
    getCurSceneView():addSubView({
      subView = popView,
      zOrder = MainUISceneZOrder.menuView
    })
  elseif popType == POP_Show_XIANQISUIPIAN then
    local popView = CBuyXianQiSuiPianPopView.new()
    getCurSceneView():addSubView({
      subView = popView,
      zOrder = MainUISceneZOrder.menuView
    })
  end
end
CBuyCZFLGiftPopView = class("CBuyCZFLGiftPopView", CcsSubView)
function CBuyCZFLGiftPopView:ctor()
  self.m_BuyGiftType = POP_Show_CHONGZHIFANLI
  local jsonPath = "views/buy_chongzhifanli.json"
  local btnBatchListener = {
    btn_chongzhi = {
      listener = handler(self, self.OnBtn_ChongZhi),
      variName = "btn_chongzhi"
    },
    btn_table1 = {
      listener = handler(self, self.OnBtn_Table1),
      variName = "btn_table1"
    },
    btn_table2 = {
      listener = handler(self, self.OnBtn_Table2),
      variName = "btn_table2"
    },
    btn_table3 = {
      listener = handler(self, self.OnBtn_Table3),
      variName = "btn_table3"
    },
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "m_Btn_Close",
      param = {3}
    }
  }
  CBuyCZFLGiftPopView.super.ctor(self, jsonPath, {isAutoCenter = true, opacityBg = 100})
  self:addBatchBtnListener(btnBatchListener)
  self:SetViewData()
  self:SetTabBtn()
  self:ListenMessage(MsgID_ChongZhi)
end
function CBuyCZFLGiftPopView:SetViewData()
  local dataText = ""
  local inTimeFlag = false
  if g_LocalPlayer then
    inTimeFlag = g_LocalPlayer:JudgeCanGetChongZhiFanli()
  end
  if inTimeFlag then
    local startTime, endTime = g_LocalPlayer:getMoMoChongZhiFanliTime()
    local startTimeTable = os.date("*t", checkint(startTime))
    local endTimeTable = os.date("*t", checkint(endTime))
    dataText = string.format("%d月%d日-%d月%d日", startTimeTable.month, startTimeTable.day, endTimeTable.month, endTimeTable.day)
  end
  self:getNode("txt_date"):setText(dataText)
  local x, y = self:getNode("txt_box"):getPosition()
  local size = self:getNode("txt_box"):getContentSize()
  local parent = self:getNode("txt_box"):getParent()
  if self.m_Tips == nil then
    self.m_Tips = CRichText.new({
      width = size.width,
      fontSize = 24,
      color = ccc3(62, 9, 9),
      align = CRichText_AlignType_Left
    })
    parent:addChild(self.m_Tips)
  else
    self.m_Tips:clearAll()
  end
  local txtStr = "活动期间，充值购买任何数额的元宝。系统将立刻通过邮件额外赠送10%的元宝。返利金额详情可查看邮件公告。本次充值返利活动，不包含月卡与特卖商品。"
  self.m_Tips:addRichText(txtStr)
  local h = self.m_Tips:getContentSize().height
  self.m_Tips:setPosition(ccp(x, y + size.height - h))
end
function CBuyCZFLGiftPopView:SetTabBtn()
  self:addBtnSigleSelectGroup({
    {
      self.btn_table1,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_table2,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_table3,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    }
  })
  local openIndexList, btnNameDict, buyGiftDict = GetPopBuyViewBtnData()
  for i = 1, 3 do
    local btn = self:getNode(string.format("btn_table%d", i))
    btn:setEnabled(false)
    btn:setTouchEnabled(false)
  end
  if openIndexList == nil or #openIndexList == 1 then
    self:getNode("msg_layer"):setEnabled(false)
    self:getNode("msg_layer"):setTouchEnabled(false)
  else
    for i, j in ipairs(openIndexList) do
      local btn = self:getNode(string.format("btn_table%d", i))
      btn:setEnabled(true)
      btn:setTouchEnabled(true)
      btn:setTitleText(btnNameDict[j])
      if self.m_BuyGiftType == buyGiftDict[j] then
        self:setGroupBtnSelected(btn)
      end
    end
  end
end
function CBuyCZFLGiftPopView:OnBtn_ChongZhi(obj, t)
  self:CloseSelf()
  ShowRechargeView({resType = RESTYPE_GOLD})
end
function CBuyCZFLGiftPopView:OnBtn_Close(obj, t)
  self:CloseSelf()
end
function CBuyCZFLGiftPopView:OnClickTableBtn(index)
  local openIndexList, _, buyGiftDict = GetPopBuyViewBtnData()
  if openIndexList == nil then
    return
  end
  if openIndexList[index] ~= nil then
    self:CloseSelf()
    ShowPopBuyGiftPopView(buyGiftDict[openIndexList[index]])
  end
end
function CBuyCZFLGiftPopView:OnBtn_Table1(obj, t)
  self:OnClickTableBtn(1)
end
function CBuyCZFLGiftPopView:OnBtn_Table2(obj, t)
  self:OnClickTableBtn(2)
end
function CBuyCZFLGiftPopView:OnBtn_Table3(obj, t)
  self:OnClickTableBtn(3)
end
function CBuyCZFLGiftPopView:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_ChongZhi_ItemListUpdate or msgSID == MsgID_MAIL_ChongZhiFanli_Update or msgSID == MsgID_PaiMaiShenShouUpdate or msgSID == MsgID_MAIL_XiaoFeiFanli_Update or msgSID == MsgID_XianQiSuiPian_Update then
    if g_LocalPlayer and g_LocalPlayer:JudgeCanGetChongZhiFanli() then
      self:CloseSelf()
      ShowPopBuyGiftPopView(self.m_BuyGiftType)
    else
      self:CloseSelf()
    end
  end
end
function CBuyCZFLGiftPopView:Clear()
  netsend.netnotify.closeBuyGiftPopView(self.m_BuyGiftType)
end
CBuyCuXiaoGiftPopView = class("CBuyCuXiaoGiftPopView", CcsSubView)
function CBuyCuXiaoGiftPopView:ctor()
  self.m_BuyGiftType = POP_Show_CUXIAO
  local jsonPath = "views/buy_cuxiao_gift.json"
  local btnBatchListener = {
    btn_buy1 = {
      listener = handler(self, self.OnBtn_Buy1),
      variName = "m_Btn_Buy1"
    },
    btn_buy2 = {
      listener = handler(self, self.OnBtn_Buy2),
      variName = "m_Btn_Buy2"
    },
    btn_table1 = {
      listener = handler(self, self.OnBtn_Table1),
      variName = "btn_table1"
    },
    btn_table2 = {
      listener = handler(self, self.OnBtn_Table2),
      variName = "btn_table2"
    },
    btn_table3 = {
      listener = handler(self, self.OnBtn_Table3),
      variName = "btn_table3"
    },
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "m_Btn_Close",
      param = {3}
    }
  }
  if #WEEKLY_SHOP_ITEM_LIST == 3 then
    jsonPath = "views/buy_cuxiao_gift_3.json"
    btnBatchListener = {
      btn_buy1 = {
        listener = handler(self, self.OnBtn_Buy1),
        variName = "m_Btn_Buy1"
      },
      btn_buy2 = {
        listener = handler(self, self.OnBtn_Buy2),
        variName = "m_Btn_Buy2"
      },
      btn_buy3 = {
        listener = handler(self, self.OnBtn_Buy3),
        variName = "m_Btn_Buy3"
      },
      btn_table1 = {
        listener = handler(self, self.OnBtn_Table1),
        variName = "btn_table1"
      },
      btn_table2 = {
        listener = handler(self, self.OnBtn_Table2),
        variName = "btn_table2"
      },
      btn_table3 = {
        listener = handler(self, self.OnBtn_Table3),
        variName = "btn_table3"
      },
      btn_close = {
        listener = handler(self, self.OnBtn_Close),
        variName = "m_Btn_Close",
        param = {3}
      }
    }
  end
  CBuyCuXiaoGiftPopView.super.ctor(self, jsonPath, {isAutoCenter = true, opacityBg = 100})
  self:addBatchBtnListener(btnBatchListener)
  self:SetItemData()
  self:SetTabBtn()
  clickArea_check.extend(self)
  self:ListenMessage(MsgID_ChongZhi)
end
function CBuyCuXiaoGiftPopView:SetTabBtn()
  self:addBtnSigleSelectGroup({
    {
      self.btn_table1,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_table2,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_table3,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    }
  })
  local openIndexList, btnNameDict, buyGiftDict = GetPopBuyViewBtnData()
  for i = 1, 3 do
    local btn = self:getNode(string.format("btn_table%d", i))
    btn:setEnabled(false)
    btn:setTouchEnabled(false)
  end
  if openIndexList == nil or #openIndexList == 1 then
    self:getNode("msg_layer"):setEnabled(false)
    self:getNode("msg_layer"):setTouchEnabled(false)
  else
    for i, j in ipairs(openIndexList) do
      local btn = self:getNode(string.format("btn_table%d", i))
      btn:setEnabled(true)
      btn:setTouchEnabled(true)
      btn:setTitleText(btnNameDict[j])
      if self.m_BuyGiftType == buyGiftDict[j] then
        self:setGroupBtnSelected(btn)
      end
    end
  end
end
function CBuyCuXiaoGiftPopView:SetItemData()
  local dateText = data_Shop_ChongZhi[POP_Weekly_Shop_Item1].clientDate or ""
  self:getNode("txt_date"):setText(dateText)
  for i, chargeNum in ipairs(WEEKLY_SHOP_ITEM_LIST) do
    local tempData = data_Shop_ChongZhi[chargeNum]
    local itemID = tempData.giftitem
    local itemNum = tempData.gitemnum
    local itemName = ""
    if tempData.pettype > 0 then
      itemName = data_getPetName(tempData.pettype)
    else
      itemName = data_getItemName(itemID)
    end
    local nameTextObj = self:getNode(string.format("item_name%d", i))
    nameTextObj:setText(ChangeTextIntoVerticalText(itemName))
    local x, y = nameTextObj:getPosition()
    local size = nameTextObj:getContentSize()
    nameTextObj:setPosition(ccp(x - 20, y))
    nameTextObj:getParent():reorderChild(nameTextObj, 999)
    self:getNode(string.format("kuohao%d_1", i)):setPosition(ccp(x - 23, y + size.height / 2 + 10))
    self:getNode(string.format("kuohao%d_2", i)):setPosition(ccp(x - 23, y - size.height / 2 - 10))
    local daZheIndex = tempData.dazheIndex
    if daZheIndex ~= nil and daZheIndex ~= 0 then
      local daZheImg = display.newSprite(string.format("views/pic/pic_dazhe%d.png", daZheIndex))
      self:addNode(daZheImg, 999)
      local bgx, bgy = self:getNode(string.format("bg_item_%d", i)):getPosition()
      local bgSize = self:getNode(string.format("bg_item_%d", i)):getContentSize()
      daZheImg:setPosition(ccp(bgx + bgSize.width / 2, bgy + bgSize.height - 25))
    end
    if tempData.pettype > 0 then
      self:SetPetShape(tempData.pettype, self:getNode(string.format("box%d", i)))
      self:getNode(string.format("item_num%d", i)):setVisible(false)
      self:getNode(string.format("bg_item_num_%d", i)):setVisible(false)
    else
      local path = data_getItemPathByShape(data_getItemShapeID(itemID))
      self:getNode(string.format("item_num%d", i)):setText(string.format("%d", itemNum))
      local pos = self:getNode(string.format("box%d", i))
      pos:getParent():reorderChild(pos, 99999)
      local s = pos:getContentSize()
      local icon = createClickItem({
        itemID = itemID,
        autoSize = nil,
        num = 0,
        LongPressTime = nil,
        clickListener = nil,
        LongPressListener = nil,
        LongPressEndListner = nil,
        clickDel = nil,
        noBgFlag = true
      })
      pos:addChild(icon, 10)
    end
    if g_LocalPlayer and g_LocalPlayer:JudgeCanBuyGift(chargeNum) == false then
      local img = display.newSprite("views/pic/pic_sellout.png")
      self:addNode(img, 999)
      local x, y = self:getNode(string.format("icon%d", i)):getPosition()
      img:setPosition(ccp(x + 30, y - 10))
    else
      local dt = 0.5
      local act1 = CCScaleTo:create(dt, 1.05)
      local act2 = CCScaleTo:create(dt, 1)
      self[string.format("m_Btn_Buy%d", i)]:runAction(CCRepeatForever:create(transition.sequence({act1, act2})))
    end
  end
end
function CBuyCuXiaoGiftPopView:SetPetShape(petId, pos)
  local shape = data_getRoleShape(petId)
  local x, y = pos:getPosition()
  local size = pos:getContentSize()
  local roleParent = pos:getParent()
  local z = pos:getZOrder()
  local delX = size.width / 2 + 10
  local path = data_getWarBodyPngPathByShape(shape, DIRECTIOIN_RIGHTDOWN)
  addDynamicLoadTexture(path, function(handlerName, texture)
    if self.__isExist then
      local offx, offy = 0, 0
      local roleShapeObj, offx, offy = createWarBodyByShape(shape, DIRECTIOIN_RIGHTDOWN)
      roleShapeObj:playAniWithName("guard_4", -1)
      roleParent:addNode(roleShapeObj, z + 1)
      roleShapeObj:setPosition(x + delX + offx, y + offy)
      roleShapeObj:setOpacity(0)
      roleShapeObj:runAction(CCFadeIn:create(0.3))
      self:addclickAniForPetAni(roleShapeObj, pos, delX, 0)
    end
  end)
  local lightRing = CreateSeqAnimation("xiyou/ani/role_aureole.plist", -1, nil, nil, nil, 6)
  roleParent:addNode(lightRing, z)
  lightRing:setPosition(x + delX + AUREOLE_OFF_X, y + AUREOLE_OFF_Y)
  local shadow = display.newSprite("")
  roleParent:addNode(shadow, z)
  shadow:setPosition(x + delX, y)
end
function CBuyCuXiaoGiftPopView:OnBtn_Buy1(obj, t)
  local chargeNum = POP_Weekly_Shop_Item1
  if g_LocalPlayer and g_LocalPlayer:JudgeCanBuyGift(chargeNum) == false then
    ShowNotifyTips("商品仅限购一次")
    return
  end
  local rmb = data_Shop_ChongZhi[chargeNum].rmb
  local numLimit = data_Shop_ChongZhi[chargeNum].numLimit
  local tempView = CPopWarning.new({
    title = "赞助温馨提示",
    text = "为保证服务能长久运营更新，喜欢此游戏朋友，欢迎赞助我们，共创经典回合，宝典赞助分为三个档10,100,1000，赞助成功之后宝典自动到账，出现到账延迟问题，请联系客服解决",
    cancelFunc = nil,
    confirmFunc = function()
      g_ChannelMgr:startPay(rmb, chargeNum)
      self:CloseSelf()
    end,
    confirmText = "下一步",
    align = CRichText_AlignType_Left
  })
  tempView:ShowCloseBtn(false)
end
function CBuyCuXiaoGiftPopView:OnBtn_Buy2(obj, t)
  local chargeNum = POP_Weekly_Shop_Item2
  if g_LocalPlayer and g_LocalPlayer:JudgeCanBuyGift(chargeNum) == false then
    ShowNotifyTips("商品仅限购一次")
    return
  end
  local rmb = data_Shop_ChongZhi[chargeNum].rmb
  local numLimit = data_Shop_ChongZhi[chargeNum].numLimit
  local tempView = CPopWarning.new({
    title = "赞助温馨提示",
    text = "为保证服务能长久运营更新，喜欢此游戏朋友，欢迎赞助我们，共创经典回合，宝典赞助分为三个档10,100,1000，赞助成功之后宝典自动到账，出现到账延迟问题，请联系客服解决",
    cancelFunc = nil,
    confirmFunc = function()
      g_ChannelMgr:startPay(rmb, chargeNum)
      self:CloseSelf()
    end,
    confirmText = "下一步",
    align = CRichText_AlignType_Left
  })
  tempView:ShowCloseBtn(false)
end
function CBuyCuXiaoGiftPopView:OnBtn_Buy3(obj, t)
  local chargeNum = POP_Weekly_Shop_Item3
  if g_LocalPlayer and g_LocalPlayer:JudgeCanBuyGift(chargeNum) == false then
    ShowNotifyTips("商品仅限购一次")
    return
  end
  local rmb = data_Shop_ChongZhi[chargeNum].rmb
  local numLimit = data_Shop_ChongZhi[chargeNum].numLimit
  local tempView = CPopWarning.new({
    title = "赞助温馨提示",
    text = "为保证服务能长久运营更新，喜欢此游戏朋友，欢迎赞助我们，共创经典回合，宝典赞助分为三个档10,100,1000，赞助成功之后宝典自动到账，出现到账延迟问题，请联系客服解决",
    cancelFunc = nil,
    confirmFunc = function()
      g_ChannelMgr:startPay(rmb, chargeNum)
      self:CloseSelf()
    end,
    confirmText = "下一步",
    align = CRichText_AlignType_Left
  })
  tempView:ShowCloseBtn(false)
end
function CBuyCuXiaoGiftPopView:OnBtn_Close(obj, t)
  self:CloseSelf()
end
function CBuyCuXiaoGiftPopView:OnClickTableBtn(index)
  local openIndexList, _, buyGiftDict = GetPopBuyViewBtnData()
  if openIndexList == nil then
    return
  end
  if openIndexList[index] ~= nil then
    self:CloseSelf()
    ShowPopBuyGiftPopView(buyGiftDict[openIndexList[index]])
  end
end
function CBuyCuXiaoGiftPopView:OnBtn_Table1(obj, t)
  self:OnClickTableBtn(1)
end
function CBuyCuXiaoGiftPopView:OnBtn_Table2(obj, t)
  self:OnClickTableBtn(2)
end
function CBuyCuXiaoGiftPopView:OnBtn_Table3(obj, t)
  self:OnClickTableBtn(3)
end
function CBuyCuXiaoGiftPopView:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_ChongZhi_ItemListUpdate or msgSID == MsgID_MAIL_ChongZhiFanli_Update or msgSID == MsgID_PaiMaiShenShouUpdate or msgSID == MsgID_MAIL_XiaoFeiFanli_Update or msgSID == MsgID_XianQiSuiPian_Update then
    if g_LocalPlayer and g_LocalPlayer:JudgeCanGetBenZhouTeMai() then
      self:CloseSelf()
      ShowPopBuyGiftPopView(self.m_BuyGiftType)
    else
      self:CloseSelf()
    end
  end
end
function CBuyCuXiaoGiftPopView:Clear()
  netsend.netnotify.closeBuyGiftPopView(self.m_BuyGiftType)
end
CZhuBoZhaoMuPopView = class("CZhuBoZhaoMuPopView", CcsSubView)
function CZhuBoZhaoMuPopView:ctor()
  self.m_BuyGiftType = POP_Show_ZHUBO
  CZhuBoZhaoMuPopView.super.ctor(self, "views/buy_zbzm_gift.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "m_Btn_Close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
end
function CZhuBoZhaoMuPopView:OnBtn_Close(obj, t)
  self:CloseSelf()
end
function CZhuBoZhaoMuPopView:Clear()
  netsend.netnotify.closeBuyGiftPopView(self.m_BuyGiftType)
end
CBuyDaShuGiftPopView = class("CBuyDaShuGiftPopView", CcsSubView)
function CBuyDaShuGiftPopView:ctor()
  self.m_BuyGiftType = POP_Show_DASHU
  CBuyDaShuGiftPopView.super.ctor(self, "views/buy_dashu_gift.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_buy = {
      listener = handler(self, self.OnBtn_Buy),
      variName = "m_Btn_Buy"
    },
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "m_Btn_Close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  local dt = 0.5
  local act1 = CCScaleTo:create(dt, 1.05)
  local act2 = CCScaleTo:create(dt, 1)
  self.m_Btn_Buy:runAction(CCRepeatForever:create(transition.sequence({act1, act2})))
end
function CBuyDaShuGiftPopView:OnBtn_Buy(obj, t)
  local chargeNum = POP_Weekly_Shop_Item1
  local rmb = data_Shop_ChongZhi[chargeNum].rmb
  local numLimit = data_Shop_ChongZhi[chargeNum].numLimit
  local tempView = CPopWarning.new({
    title = "提示",
    text = "本活动礼包仅限购买1次，由于可能会出现到账延迟，请勿重复购买。如果重复购买，则会直接获得3000元宝，并额外赠送1500元宝。",
    cancelFunc = nil,
    confirmFunc = function()
      g_ChannelMgr:startPay(rmb, chargeNum)
      self:CloseSelf()
    end,
    confirmText = "下一步",
    align = CRichText_AlignType_Left
  })
  tempView:ShowCloseBtn(false)
end
function CBuyDaShuGiftPopView:OnBtn_Close(obj, t)
  self:CloseSelf()
end
function CBuyDaShuGiftPopView:Clear()
  netsend.netnotify.closeBuyGiftPopView(self.m_BuyGiftType)
end
CBuyPaiMaiShenShouPopView = class("CBuyPaiMaiShenShouPopView", CcsSubView)
function CBuyPaiMaiShenShouPopView:ctor()
  self.m_BuyGiftType = POP_Show_PAIMAITSSS
  local jsonPath = "views/buy_paimaishenshou.json"
  local btnBatchListener = {
    btn_buy1 = {
      listener = handler(self, self.OnBtn_Buy1),
      variName = "m_Btn_Buy1"
    },
    btn_buy2 = {
      listener = handler(self, self.OnBtn_Buy2),
      variName = "m_Btn_Buy2"
    },
    btn_table1 = {
      listener = handler(self, self.OnBtn_Table1),
      variName = "btn_table1"
    },
    btn_table2 = {
      listener = handler(self, self.OnBtn_Table2),
      variName = "btn_table2"
    },
    btn_table3 = {
      listener = handler(self, self.OnBtn_Table3),
      variName = "btn_table3"
    },
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "m_Btn_Close",
      param = {3}
    }
  }
  CBuyPaiMaiShenShouPopView.super.ctor(self, jsonPath, {isAutoCenter = true, opacityBg = 100})
  self:addBatchBtnListener(btnBatchListener)
  self:SetShenShouData()
  self:SetTabBtn()
  clickArea_check.extend(self)
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_ChongZhi)
end
function CBuyPaiMaiShenShouPopView:SetTabBtn()
  self:addBtnSigleSelectGroup({
    {
      self.btn_table1,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_table2,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_table3,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    }
  })
  local openIndexList, btnNameDict, buyGiftDict = GetPopBuyViewBtnData()
  for i = 1, 3 do
    local btn = self:getNode(string.format("btn_table%d", i))
    btn:setEnabled(false)
    btn:setTouchEnabled(false)
  end
  if openIndexList == nil or #openIndexList == 1 then
    self:getNode("msg_layer"):setEnabled(false)
    self:getNode("msg_layer"):setTouchEnabled(false)
  else
    for i, j in ipairs(openIndexList) do
      local btn = self:getNode(string.format("btn_table%d", i))
      btn:setEnabled(true)
      btn:setTouchEnabled(true)
      btn:setTitleText(btnNameDict[j])
      if self.m_BuyGiftType == buyGiftDict[j] then
        self:setGroupBtnSelected(btn)
      end
    end
  end
end
function CBuyPaiMaiShenShouPopView:SetShenShouData()
  local dataText = ""
  local inTimeFlag = false
  if g_LocalPlayer then
    inTimeFlag = g_LocalPlayer:JudgeCanGetPaiMaiShenShou()
  end
  if inTimeFlag then
    local startTime, endTime = g_LocalPlayer:getPaiMaiShenShouTime()
    local startTimeTable = os.date("*t", checkint(startTime))
    local endTimeTable = os.date("*t", checkint(endTime))
    dataText = string.format("%d月%d日-%d月%d日", startTimeTable.month, startTimeTable.day, endTimeTable.month, endTimeTable.day)
  end
  self:getNode("txt_date"):setText(dataText)
  local ssData = g_LocalPlayer:getPaiMaiShenShouData()
  for i, petData in pairs(ssData) do
    local petType = petData.i_pet
    local ssName = data_getPetName(petType)
    local nameTextObj = self:getNode(string.format("item_name%d", i))
    nameTextObj:setText(ChangeTextIntoVerticalText(ssName))
    local x, y = nameTextObj:getPosition()
    local size = nameTextObj:getContentSize()
    nameTextObj:setPosition(ccp(x - 20, y))
    nameTextObj:getParent():reorderChild(nameTextObj, 999)
    self:getNode(string.format("kuohao%d_1", i)):setPosition(ccp(x - 23, y + size.height / 2 + 10))
    self:getNode(string.format("kuohao%d_2", i)):setPosition(ccp(x - 23, y - size.height / 2 - 10))
    self:SetPetShape(petType, self:getNode(string.format("box%d", i)))
    self:getNode(string.format("item_num%d", i)):setVisible(false)
    self:getNode(string.format("bg_item_num_%d", i)):setVisible(false)
    if petData.i_s == 1 then
      local img = display.newSprite("views/pic/pic_sellout.png")
      self:addNode(img, 999)
      local x, y = self:getNode(string.format("icon%d", i)):getPosition()
      img:setPosition(ccp(x + 30, y - 10))
      self[string.format("m_Btn_Buy%d", i)]:setEnabled(false)
      self[string.format("m_Btn_Buy%d", i)]:setTouchEnabled(false)
      self[string.format("m_Btn_Buy%d", i)]:setVisible(false)
    else
      local bgx, bgy = self:getNode(string.format("bg_item_%d", i)):getPosition()
      local bgSize = self:getNode(string.format("bg_item_%d", i)):getContentSize()
      local priceText = CRichText.new({
        width = bgSize.width,
        font = KANG_TTF_FONT,
        fontSize = 22,
        color = ccc3(185, 44, 12)
      })
      self:addChild(priceText, 10)
      priceText:addRichText(string.format("当前价:%d#<IR2>#", petData.i_pr))
      priceText:setPosition(ccp(bgx + 20, bgy + bgSize.height - 40))
      local dt = 0.5
      local act1 = CCScaleTo:create(dt, 1.05)
      local act2 = CCScaleTo:create(dt, 1)
      self[string.format("m_Btn_Buy%d", i)]:runAction(CCRepeatForever:create(transition.sequence({act1, act2})))
    end
  end
  local x, y = self:getNode("tips_box"):getPosition()
  local tipsSize = self:getNode("tips_box"):getContentSize()
  local tipsText = "#<IRP>#每天21:00拍卖的价格会下降#<r:255,g:66,b:0>3000#元宝。\n#<IRP>#特殊神兽#<r:255,g:66,b:0>只能#通过倒拍活动获得，每次活动服务器只投放2只特殊神兽。"
  self.m_TipsText = CRichText.new({
    width = tipsSize.width,
    font = KANG_TTF_FONT,
    fontSize = 18,
    color = ccc3(242, 203, 128)
  })
  self:addChild(self.m_TipsText, 10)
  self.m_TipsText:addRichText(tipsText)
  local myTipsSize = self.m_TipsText:getContentSize()
  self.m_TipsText:setPosition(ccp(x, y + tipsSize.height - myTipsSize.height))
end
function CBuyPaiMaiShenShouPopView:SetPetShape(petId, pos)
  local shape = data_getRoleShape(petId)
  local x, y = pos:getPosition()
  local size = pos:getContentSize()
  local roleParent = pos:getParent()
  local z = pos:getZOrder()
  local delX = size.width / 2 + 10
  local path = data_getWarBodyPngPathByShape(shape, DIRECTIOIN_RIGHTDOWN)
  addDynamicLoadTexture(path, function(handlerName, texture)
    if self.__isExist then
      local offx, offy = 0, 0
      local roleShapeObj, offx, offy = createWarBodyByShape(shape, DIRECTIOIN_RIGHTDOWN)
      roleShapeObj:playAniWithName("guard_4", -1)
      roleParent:addNode(roleShapeObj, z + 1)
      roleShapeObj:setPosition(x + delX + offx, y + offy)
      roleShapeObj:setOpacity(0)
      roleShapeObj:runAction(CCFadeIn:create(0.3))
      self:addclickAniForPetAni(roleShapeObj, pos, delX, 0)
    end
  end)
  local lightRing = CreateSeqAnimation("xiyou/ani/role_aureole.plist", -1, nil, nil, nil, 6)
  roleParent:addNode(lightRing, z)
  lightRing:setPosition(x + delX + AUREOLE_OFF_X, y + AUREOLE_OFF_Y)
  local shadow = display.newSprite("xiyou/pic/pic_shapeShadow.png")
  roleParent:addNode(shadow, z)
  shadow:setPosition(x + delX, y)
end
function CBuyPaiMaiShenShouPopView:OnClickTableBtn(index)
  local openIndexList, _, buyGiftDict = GetPopBuyViewBtnData()
  if openIndexList == nil then
    return
  end
  if openIndexList[index] ~= nil then
    self:CloseSelf()
    ShowPopBuyGiftPopView(buyGiftDict[openIndexList[index]])
  end
end
function CBuyPaiMaiShenShouPopView:BuyShenShou(index)
  local ssIndex = index
  if g_LocalPlayer == nil then
    return
  end
  local ssData = g_LocalPlayer:getPaiMaiShenShouData()
  local petData = ssData[ssIndex]
  if petData == nil then
    return
  end
  if petData.i_s == 1 then
    return
  end
  if petData.i_pr == nil then
    return
  end
  if petData.i_pet == nil then
    return
  end
  local petType = petData.i_pet
  local ssName = data_getPetName(petType)
  local color = NameColor_Pet[0]
  local tempView = CPopWarning.new({
    title = "提示",
    text = string.format("是否花费%d#<IR2>#\n购买#<r:%d,g:%d,b:%d>%s#?", petData.i_pr, color.r, color.g, color.b, ssName),
    cancelFunc = nil,
    confirmFunc = function()
      if g_LocalPlayer:getGold() < petData.i_pr then
        ShowNotifyTips("元宝不足")
        self:CloseSelf()
        ShowRechargeView()
        return
      end
      netsend.netshop.SendPaiMaiShenShou(ssIndex)
    end,
    align = CRichText_AlignType_Center
  })
  tempView:ShowCloseBtn(false)
end
function CBuyPaiMaiShenShouPopView:OnBtn_Buy1(obj, t)
  local ssIndex = 1
  self:BuyShenShou(ssIndex)
end
function CBuyPaiMaiShenShouPopView:OnBtn_Buy2(obj, t)
  local ssIndex = 2
  self:BuyShenShou(ssIndex)
end
function CBuyPaiMaiShenShouPopView:OnBtn_Close(obj, t)
  self:CloseSelf()
end
function CBuyPaiMaiShenShouPopView:OnBtn_Table1(obj, t)
  self:OnClickTableBtn(1)
end
function CBuyPaiMaiShenShouPopView:OnBtn_Table2(obj, t)
  self:OnClickTableBtn(2)
end
function CBuyPaiMaiShenShouPopView:OnBtn_Table3(obj, t)
  self:OnClickTableBtn(3)
end
function CBuyPaiMaiShenShouPopView:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_ChongZhi_ItemListUpdate or msgSID == MsgID_MAIL_ChongZhiFanli_Update or msgSID == MsgID_PaiMaiShenShouUpdate or msgSID == MsgID_MAIL_XiaoFeiFanli_Update or msgSID == MsgID_XianQiSuiPian_Update then
    if g_LocalPlayer and g_LocalPlayer:JudgeCanGetPaiMaiShenShou() then
      self:CloseSelf()
      ShowPopBuyGiftPopView(self.m_BuyGiftType)
    else
      self:CloseSelf()
    end
  elseif msgSID == MsgID_MoneyUpdate then
  end
end
function CBuyPaiMaiShenShouPopView:Clear()
  netsend.netnotify.closeBuyGiftPopView(self.m_BuyGiftType)
end
CBuyXFFLGiftPopView = class("CBuyXFFLGiftPopView", CcsSubView)
function CBuyXFFLGiftPopView:ctor()
  self.m_BuyGiftType = POP_Show_XIAOFEIFANLI
  local jsonPath = "views/buy_xiaofeifanli.json"
  local btnBatchListener = {
    btn_chongzhi = {
      listener = handler(self, self.OnBtn_ChongZhi),
      variName = "btn_chongzhi"
    },
    btn_table1 = {
      listener = handler(self, self.OnBtn_Table1),
      variName = "btn_table1"
    },
    btn_table2 = {
      listener = handler(self, self.OnBtn_Table2),
      variName = "btn_table2"
    },
    btn_table3 = {
      listener = handler(self, self.OnBtn_Table3),
      variName = "btn_table3"
    },
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "m_Btn_Close",
      param = {3}
    }
  }
  CBuyXFFLGiftPopView.super.ctor(self, jsonPath, {isAutoCenter = true, opacityBg = 100})
  self:addBatchBtnListener(btnBatchListener)
  self:SetViewData()
  self:SetXFFLData()
  self:SetTabBtn()
  self:ListenMessage(MsgID_ChongZhi)
  netsend.netactivity.openGuoQingXFFLView()
  self.m_SetTimeTimer = scheduler.scheduleGlobal(function()
    if self.SetXFFLData then
      self:SetXFFLData()
    end
  end, 1)
end
function CBuyXFFLGiftPopView:SetXFFLData()
  self:getNode("text_usegold"):setText("")
  self:getNode("text_addgold"):setText("")
  self:getNode("text_time"):setText("离活动结束:")
  local inTimeFlag = false
  if g_LocalPlayer then
    inTimeFlag = g_LocalPlayer:JudgeCanGetXiaoFeiFanLi()
  end
  if inTimeFlag == false then
    self:CloseSelf()
    return
  end
  local _, endTime = g_LocalPlayer:getXiaoFeiFanLiTime()
  local curTime = g_DataMgr:getServerTime()
  local restTime = endTime - curTime
  local restStr = ""
  local d = math.floor(restTime / 3600 / 24)
  local h = math.floor(restTime / 3600 % 24)
  local m = math.floor(restTime % 3600 / 60)
  local s = math.floor(restTime % 60)
  if d > 0 then
    restStr = string.format("%s%d天", restStr, d)
  end
  if h > 0 then
    restStr = string.format("%s%d小时", restStr, h)
  end
  if m > 0 then
    restStr = string.format("%s%d分", restStr, m)
  end
  if s > 0 then
    restStr = string.format("%s%d秒", restStr, s)
  end
  local num1, num2 = g_LocalPlayer:getXiaoFeiFanLiData()
  local useGoldNum = num1 or 0
  local addGoldNum = num2 or 0
  self:getNode("text_usegold"):setText(string.format("%d", useGoldNum))
  self:getNode("text_addgold"):setText(string.format("%d", addGoldNum))
  self:getNode("text_time"):setText(string.format("离活动结束:%s", restStr))
  if self.m_ShowGoldNumFlag ~= true then
    self:getNode("text_usegold"):setText("")
    self:getNode("text_addgold"):setText("")
    self:getNode("text_time"):setText("离活动结束")
  end
end
function CBuyXFFLGiftPopView:SetViewData()
  local dataText = ""
  local inTimeFlag = false
  if g_LocalPlayer then
    inTimeFlag = g_LocalPlayer:JudgeCanGetXiaoFeiFanLi()
  end
  if inTimeFlag then
    local startTime, endTime = g_LocalPlayer:getXiaoFeiFanLiTime()
    local startTimeTable = os.date("*t", checkint(startTime))
    local endTimeTable = os.date("*t", checkint(endTime))
    dataText = string.format("%d月%d日-%d月%d日", startTimeTable.month, startTimeTable.day, endTimeTable.month, endTimeTable.day)
  end
  self:getNode("txt_date"):setText(dataText)
  local x, y = self:getNode("txt_box"):getPosition()
  local size = self:getNode("txt_box"):getContentSize()
  local parent = self:getNode("txt_box"):getParent()
  if self.m_Tips == nil then
    self.m_Tips = CRichText.new({
      width = size.width + 10,
      fontSize = 22,
      color = ccc3(62, 9, 9),
      align = CRichText_AlignType_Left
    })
    parent:addChild(self.m_Tips)
  else
    self.m_Tips:clearAll()
  end
  local txtStr = "活动规则:\n活动期间角色消耗元宝总数，活动结束后按照10%的比例通过邮件形式返还。不足1元宝的按1元宝计算。"
  self.m_Tips:addRichText(txtStr)
  local h = self.m_Tips:getContentSize().height
  self.m_Tips:setPosition(ccp(x, y + size.height - h))
  for i, name in pairs({
    "box_usegold",
    "box_addgold"
  }) do
    local x, y = self:getNode(name):getPosition()
    local z = self:getNode(name):getZOrder()
    local size = self:getNode(name):getSize()
    local img = display.newSprite(data_getResPathByResID(RESTYPE_GOLD))
    img:setAnchorPoint(ccp(0.5, 0.5))
    img:setScale(size.width / img:getContentSize().width)
    img:setPosition(ccp(x + size.width / 2, y + size.height / 2))
    self:addNode(img, z)
  end
  self:getNode("text_usegold"):setText("")
  self:getNode("text_addgold"):setText("")
  self:getNode("text_time"):setText("离活动结束")
end
function CBuyXFFLGiftPopView:SetTabBtn()
  self:addBtnSigleSelectGroup({
    {
      self.btn_table1,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_table2,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_table3,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    }
  })
  local openIndexList, btnNameDict, buyGiftDict = GetPopBuyViewBtnData()
  for i = 1, 3 do
    local btn = self:getNode(string.format("btn_table%d", i))
    btn:setEnabled(false)
    btn:setTouchEnabled(false)
  end
  if openIndexList == nil or #openIndexList == 1 then
    self:getNode("msg_layer"):setEnabled(false)
    self:getNode("msg_layer"):setTouchEnabled(false)
  else
    for i, j in ipairs(openIndexList) do
      local btn = self:getNode(string.format("btn_table%d", i))
      btn:setEnabled(true)
      btn:setTouchEnabled(true)
      btn:setTitleText(btnNameDict[j])
      if self.m_BuyGiftType == buyGiftDict[j] then
        self:setGroupBtnSelected(btn)
      end
    end
  end
end
function CBuyXFFLGiftPopView:OnBtn_ChongZhi(obj, t)
  self:CloseSelf()
  ShowRechargeView({resType = RESTYPE_GOLD})
end
function CBuyXFFLGiftPopView:OnBtn_Close(obj, t)
  self:CloseSelf()
end
function CBuyXFFLGiftPopView:OnClickTableBtn(index)
  local openIndexList, _, buyGiftDict = GetPopBuyViewBtnData()
  if openIndexList == nil then
    return
  end
  if openIndexList[index] ~= nil then
    self:CloseSelf()
    ShowPopBuyGiftPopView(buyGiftDict[openIndexList[index]])
  end
end
function CBuyXFFLGiftPopView:OnBtn_Table1(obj, t)
  self:OnClickTableBtn(1)
end
function CBuyXFFLGiftPopView:OnBtn_Table2(obj, t)
  self:OnClickTableBtn(2)
end
function CBuyXFFLGiftPopView:OnBtn_Table3(obj, t)
  self:OnClickTableBtn(3)
end
function CBuyXFFLGiftPopView:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_MAIL_XiaoFeiFanli_Update then
    self.m_ShowGoldNumFlag = true
  end
end
function CBuyXFFLGiftPopView:Clear()
  netsend.netnotify.closeBuyGiftPopView(self.m_BuyGiftType)
  if self.m_SetTimeTimer then
    scheduler.unscheduleGlobal(self.m_SetTimeTimer)
    self.m_SetTimeTimer = nil
  end
end
CBuyXianQiSuiPianPopView = class("CBuyXianQiSuiPianPopView", CcsSubView)
function CBuyXianQiSuiPianPopView:ctor()
  self.m_BuyGiftType = POP_Show_XIANQISUIPIAN
  local jsonPath = "views/buy_songsuipian.json"
  local btnBatchListener = {
    btn_get = {
      listener = handler(self, self.OnBtn_GetSuiPian),
      variName = "btn_get"
    },
    btn_table1 = {
      listener = handler(self, self.OnBtn_Table1),
      variName = "btn_table1"
    },
    btn_table2 = {
      listener = handler(self, self.OnBtn_Table2),
      variName = "btn_table2"
    },
    btn_table3 = {
      listener = handler(self, self.OnBtn_Table3),
      variName = "btn_table3"
    },
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "m_Btn_Close",
      param = {3}
    }
  }
  CBuyXianQiSuiPianPopView.super.ctor(self, jsonPath, {isAutoCenter = true, opacityBg = 100})
  self:addBatchBtnListener(btnBatchListener)
  self:SetViewData()
  self:SetTabBtn()
  self:ListenMessage(MsgID_ChongZhi)
  self:ListenMessage(MsgID_PlayerInfo)
  netsend.netactivity.openGuoQingSuiPianView()
end
function CBuyXianQiSuiPianPopView:SetViewData()
  local dataText = ""
  local inTimeFlag = false
  if g_LocalPlayer then
    inTimeFlag = g_LocalPlayer:JudgeCanGetXianQiSuiPian()
  end
  if inTimeFlag then
    local startTime, endTime = g_LocalPlayer:getXiaoFeiFanLiTime()
    local startTimeTable = os.date("*t", checkint(startTime))
    local endTimeTable = os.date("*t", checkint(endTime))
    dataText = string.format("%d月%d日-%d月%d日", startTimeTable.month, startTimeTable.day, endTimeTable.month, endTimeTable.day)
  end
  self:getNode("txt_date"):setText(dataText)
  self:SetTipsData()
  local pos = self:getNode("item_box")
  pos:getParent():reorderChild(pos, 99999)
  local s = pos:getContentSize()
  local icon = createClickItem({
    itemID = 76604,
    autoSize = nil,
    num = 0,
    LongPressTime = nil,
    clickListener = nil,
    LongPressListener = nil,
    LongPressEndListner = nil,
    clickDel = nil,
    noBgFlag = false
  })
  pos:addChild(icon, 10)
end
function CBuyXianQiSuiPianPopView:SetTipsData()
  local x, y = self:getNode("txt_box"):getPosition()
  local size = self:getNode("txt_box"):getContentSize()
  local parent = self:getNode("txt_box"):getParent()
  if self.m_Tips == nil then
    self.m_Tips = CRichText.new({
      width = size.width,
      fontSize = 22,
      color = ccc3(62, 9, 9),
      align = CRichText_AlignType_Left
    })
    parent:addChild(self.m_Tips)
  else
    self.m_Tips:clearAll()
  end
  local txtStr = string.format("活动范围:全区组\n活动期间玩家每天完成以下所有日常活动后，赠送顶级宠物蛋*1\n%s", activity.guoqingMgr:getPlayerGetXQSPText())
  self.m_Tips:addRichText(txtStr)
  local h = self.m_Tips:getContentSize().height
  self.m_Tips:setPosition(ccp(x, y + size.height - h))
end
function CBuyXianQiSuiPianPopView:SetTabBtn()
  self:addBtnSigleSelectGroup({
    {
      self.btn_table1,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_table2,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_table3,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    }
  })
  local openIndexList, btnNameDict, buyGiftDict = GetPopBuyViewBtnData()
  for i = 1, 3 do
    local btn = self:getNode(string.format("btn_table%d", i))
    btn:setEnabled(false)
    btn:setTouchEnabled(false)
  end
  if openIndexList == nil or #openIndexList == 1 then
    self:getNode("msg_layer"):setEnabled(false)
    self:getNode("msg_layer"):setTouchEnabled(false)
  else
    for i, j in ipairs(openIndexList) do
      local btn = self:getNode(string.format("btn_table%d", i))
      btn:setEnabled(true)
      btn:setTouchEnabled(true)
      btn:setTitleText(btnNameDict[j])
      if self.m_BuyGiftType == buyGiftDict[j] then
        self:setGroupBtnSelected(btn)
      end
    end
  end
end
function CBuyXianQiSuiPianPopView:OnBtn_GetSuiPian(obj, t)
  netsend.netactivity.getGuoQingSuiPian()
end
function CBuyXianQiSuiPianPopView:OnBtn_Close(obj, t)
  self:CloseSelf()
end
function CBuyXianQiSuiPianPopView:OnClickTableBtn(index)
  local openIndexList, _, buyGiftDict = GetPopBuyViewBtnData()
  if openIndexList == nil then
    return
  end
  if openIndexList[index] ~= nil then
    self:CloseSelf()
    ShowPopBuyGiftPopView(buyGiftDict[openIndexList[index]])
  end
end
function CBuyXianQiSuiPianPopView:OnBtn_Table1(obj, t)
  self:OnClickTableBtn(1)
end
function CBuyXianQiSuiPianPopView:OnBtn_Table2(obj, t)
  self:OnClickTableBtn(2)
end
function CBuyXianQiSuiPianPopView:OnBtn_Table3(obj, t)
  self:OnClickTableBtn(3)
end
function CBuyXianQiSuiPianPopView:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_ServerDailyClean then
    self:CloseSelf()
    return
  end
  if msgSID == MsgID_ChongZhi_ItemListUpdate or msgSID == MsgID_MAIL_ChongZhiFanli_Update or msgSID == MsgID_PaiMaiShenShouUpdate or msgSID == MsgID_MAIL_XiaoFeiFanli_Update then
    if g_LocalPlayer and g_LocalPlayer:JudgeCanGetXianQiSuiPian() then
      self:CloseSelf()
      ShowPopBuyGiftPopView(self.m_BuyGiftType)
    else
      self:CloseSelf()
    end
  elseif msgSID == MsgID_XianQiSuiPian_Update then
    if g_LocalPlayer and g_LocalPlayer:JudgeCanGetXianQiSuiPian() then
      self:SetTipsData()
    else
      self:CloseSelf()
    end
  end
end
function CBuyXianQiSuiPianPopView:Clear()
  netsend.netnotify.closeBuyGiftPopView(self.m_BuyGiftType)
end

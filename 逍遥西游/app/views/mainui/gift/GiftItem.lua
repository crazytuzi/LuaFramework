CGiftItem = class("CGiftItem", CcsSubView)
function CGiftItem:ctor(giftId, listObj, rewardData)
  CGiftItem.super.ctor(self, "views/gift_item.csb")
  local btnBatchListener = {
    btn_recive = {
      listener = handler(self, self.OnBtn_Recive),
      variName = "btn_recive"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.bg = self:getNode("bg")
  self.m_GiftId = giftId
  self.m_ListObj = listObj
  self.m_RewardData = rewardData
  if self.m_GiftId == Gift_OnLine_ID then
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.frameUpdate))
    self:scheduleUpdate()
  end
  self:SetData()
  self:SetDataEx()
  self:SetDataAward()
end
function CGiftItem:SetData()
  local picPath = "views/gift/pic_gift_libao.png"
  if self.m_GiftId == Gift_OnLine_ID then
    picPath = "views/gift/pic_gift.png"
  elseif self.m_GiftId == Gift_Login_ID then
    picPath = "views/gift/pic_gift.png"
  elseif self.m_GiftId == Gift_LevelUp_ID then
    picPath = "views/gift/pic_gift2.png"
  elseif self.m_GiftId == Gift_SignUp_ID then
    picPath = "views/gift/pic_signin.png"
  elseif self.m_GiftId == Gift_NewTermCheckIn_ID then
    picPath = "views/gift/pic_newterm_signin.png"
  elseif self.m_GiftId == Gift_GuoQingCheckIn_ID then
    picPath = "views/gift/pic_newterm_signin.png"
  end
  local tempPic = display.newSprite(picPath)
  self:addNode(tempPic, 1000)
  local x, y = self:getNode("box_pic"):getPosition()
  tempPic:setAnchorPoint(ccp(0, 0))
  tempPic:setPosition(ccp(x, y))
  if self.m_GiftId == Gift_OnLine_ID then
    self:getNode("title"):setText("在线奖励")
  elseif self.m_GiftId == Gift_Login_ID then
    self:getNode("title"):setText("新手礼包")
  elseif self.m_GiftId == Gift_LevelUp_ID then
    self:getNode("title"):setText("冲级礼包")
  elseif self.m_GiftId == Gift_SignUp_ID then
    self:getNode("title"):setText("签到有奖")
  elseif self.m_GiftId == Gift_GetInput_ID then
    self:getNode("title"):setText("礼包码兑换")
  elseif self.m_GiftId == Gift_Festival_ID then
    self:getNode("title"):setText("节日礼物")
  elseif self.m_GiftId == Gift_NewTermCheckIn_ID then
    self:getNode("title"):setText("新学期签到")
  elseif self.m_GiftId == Gift_GuoQingCheckIn_ID then
    self:getNode("title"):setText("国庆签到")
  elseif self.m_RewardData ~= nil then
    self:getNode("title"):setText(self.m_RewardData.name or "礼包")
  else
    local tempName = data_getGiftOfIdentifyName(self.m_GiftId)
    self:getNode("title"):setText(tempName)
  end
  if self.m_GiftId == Gift_OnLine_ID then
    self.m_CdLastShowTime = -1
    local nextCmpTime = gift.online:getNextCmpTime()
    local svrTime = g_DataMgr:getServerTime()
    self.m_CdTime = nextCmpTime - svrTime
    if nextCmpTime < 0 or svrTime < 0 then
      self:getNode("txt1"):setEnabled(false)
    else
      self:getNode("txt1"):setEnabled(true)
      self:reflushOnlineRewardTime()
    end
  elseif self.m_GiftId == Gift_LevelUp_ID then
    local rewardId = gift.levelup:getRewardId()
    local zs, lv, rewardList = gift.levelup:getData()
    self:getNode("txt1"):setText(string.format("目标:%d转%d级", zs, lv))
    self:getNode("txt1"):setColor(ccc3(255, 255, 255))
  elseif self.m_GiftId == Gift_Login_ID then
    self:getNode("txt1"):setText("祝君游戏愉快")
  else
    self:getNode("txt1"):setVisible(false)
  end
  if self.m_GiftId == Gift_SignUp_ID then
    local svrTime = g_DataMgr:getServerTime()
    if svrTime == nil or svrTime <= 0 then
      svrTime = os.time()
    end
    local month = os.date("%m", svrTime)
    local monthStr = Month_Chinese[checkint(month)]
    self:getNode("txt2"):setText(string.format("%s月签到有奖", monthStr))
  elseif self.m_GiftId == Gift_NewTermCheckIn_ID then
    local startTime, endTime = gift.newTermCheckIn:getNewTermCheckInTimeData()
    local startTimeTable = os.date("*t", checkint(startTime))
    local endTimeTable = os.date("*t", checkint(endTime))
    self:getNode("txt2"):setText(string.format("%d月%d日-%d月%d日新学期签到有奖", startTimeTable.month, startTimeTable.day, endTimeTable.month, endTimeTable.day))
  elseif self.m_GiftId == Gift_GuoQingCheckIn_ID then
    local startTime, endTime = gift.guoQingCheckIn:getGuoQingCheckInTimeData()
    local startTimeTable = os.date("*t", checkint(startTime))
    local endTimeTable = os.date("*t", checkint(endTime))
    self:getNode("txt2"):setText(string.format("%d月%d日-%d月%d日国庆签到有奖", startTimeTable.month, startTimeTable.day, endTimeTable.month, endTimeTable.day))
  elseif self.m_GiftId == Gift_GetInput_ID then
    self:getNode("txt2"):setText("输入礼包码后兑换礼包")
  elseif self.m_GiftId == Gift_Festival_ID then
    local fData = data_GiftOfFestival[fId] or {}
    local fId = gift.festival:getFestivalId()
    local fText = fData.name or "礼物"
    self:getNode("txt2"):setText(string.format("领取%s礼物", fText))
  else
    self:getNode("txt2"):setVisible(false)
  end
  if self.m_GiftId == Gift_SignUp_ID then
    self.btn_recive:setTitleText("签到")
  elseif self.m_GiftId == Gift_NewTermCheckIn_ID then
    self.btn_recive:setTitleText("签到")
  elseif self.m_GiftId == Gift_GuoQingCheckIn_ID then
    self.btn_recive:setTitleText("签到")
  else
    self.btn_recive:setTitleText("领取")
  end
end
function CGiftItem:SetDataEx()
  if self.m_GiftId == Gift_OnLine_ID then
    local nextCmpTime = gift.online:getNextCmpTime()
    local svrTime = g_DataMgr:getServerTime()
    if nextCmpTime < 0 or svrTime < 0 then
      self.btn_recive:setEnabled(false)
    end
  elseif self.m_GiftId == Gift_Login_ID then
    self.btn_recive:setEnabled(gift.levelup:CanGetLoginReward())
  elseif self.m_GiftId == Gift_LevelUp_ID then
    self.btn_recive:setEnabled(gift.levelup:CanGetLevelupReward())
  elseif self.m_GiftId == Gift_SignUp_ID then
    self:SetRedIconBtn(gift.checkin:CanTodayCheckIn())
  elseif self.m_GiftId == Gift_NewTermCheckIn_ID then
    self:SetRedIconBtn(gift.newTermCheckIn:IsCanNewTermCheckInToday())
  elseif self.m_GiftId == Gift_GuoQingCheckIn_ID then
    self:SetRedIconBtn(gift.guoQingCheckIn:IsCanGuoQingCheckInToday())
  end
end
function CGiftItem:SetDataAward()
  local rewardList = {}
  local Pet = {}
  if self.m_GiftId == Gift_Festival_ID then
    return
  elseif self.m_GiftId == Gift_OnLine_ID then
    rewardList = gift.online:getReward()
  elseif self.m_GiftId == Gift_LevelUp_ID then
    _, _, rewardList = gift.levelup:getData()
  elseif self.m_GiftId == Gift_Login_ID then
    _, _, rewardList, Pet = gift.levelup:getLoginData()
  elseif self.m_RewardData ~= nil then
    rewardList = self.m_RewardData.rewardList or {}
  else
    rewardList = data_getGiftOfIdentifyReward(self.m_GiftId)
  end
  if #Pet ~= 0 then
    self:createPetReward(Pet)
  end
  if #rewardList ~= 0 then
    self:createReward(rewardList)
  end
end
function CGiftItem:createPetReward(Pet)
  local zOrder1 = 10000
  local rewardItem = {}
  local x, _ = self:getNode("title"):getPosition()
  local _, y = self:getNode("box_pic"):getPosition()
  local scale = 0.65
  for i, petId in ipairs(Pet) do
    do
      local item = createClickPetHead({
        roleTypeId = petId,
        autoSize = nil,
        clickListener = function()
          local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Zhaohuanshou)
          if openFlag == false then
            ShowNotifyTips(tips)
            return
          end
          local tempView = CPetList.new(PetShow_InitShow_TuJianView, nil, nil, petId)
          getCurSceneView():addSubView({
            subView = tempView,
            zOrder = MainUISceneZOrder.menuView
          })
        end,
        noBgFlag = nil,
        offx = nil,
        offy = nil,
        clickDel = nil,
        LongPressTime = 0,
        LongPressListener = nil,
        LongPressEndListner = nil
      })
      if item then
        item:setScale(scale)
        self:addChild(item, zOrder1)
        item:setPosition(ccp(x, y))
        local s = item:getSize()
        x = x + s.width * scale + 10
        rewardItem[#rewardItem + 1] = item
      end
    end
  end
end
function CGiftItem:createReward(rewardList)
  local zOrder = 10000
  local rewardItem = {}
  local x, _ = self:getNode("title"):getPosition()
  local _, y = self:getNode("box_pic"):getPosition()
  local scale = 0.65
  for i, rewardInfo in ipairs(rewardList) do
    local t = rewardInfo[1]
    local num = rewardInfo[2]
    local item
    if num and num > 0 then
      if t == RESTYPE_GOLD then
        item = createClickResItem({
          resID = RESTYPE_GOLD,
          num = num,
          autoSize = nil,
          clickListener = nil,
          clickDel = nil,
          noBgFlag = nil,
          LongPressTime = 0.2,
          LongPressListener = nil,
          LongPressEndListner = nil
        })
      elseif t == RESTYPE_COIN then
        item = createClickResItem({
          resID = RESTYPE_COIN,
          num = num,
          autoSize = nil,
          clickListener = nil,
          clickDel = nil,
          noBgFlag = nil,
          LongPressTime = 0.2,
          LongPressListener = nil,
          LongPressEndListner = nil
        })
      elseif t == RESTYPE_SILVER then
        item = createClickResItem({
          resID = RESTYPE_SILVER,
          num = num,
          autoSize = nil,
          clickListener = nil,
          clickDel = nil,
          noBgFlag = nil,
          LongPressTime = 0.2,
          LongPressListener = nil,
          LongPressEndListner = nil
        })
      elseif t == RESTYPE_EXP then
        item = createClickResItem({
          resID = RESTYPE_EXP,
          num = num,
          autoSize = nil,
          clickListener = nil,
          clickDel = nil,
          noBgFlag = nil,
          LongPressTime = 0.2,
          LongPressListener = nil,
          LongPressEndListner = nil
        })
      elseif t == RESTYPE_HUOLI then
        item = createClickResItem({
          resID = RESTYPE_HUOLI,
          num = num,
          autoSize = nil,
          clickListener = nil,
          clickDel = nil,
          noBgFlag = nil,
          LongPressTime = 0.2,
          LongPressListener = nil,
          LongPressEndListner = nil
        })
      else
        item = createClickItem({
          itemID = t,
          autoSize = nil,
          num = num,
          LongPressTime = 0.2,
          clickListener = nil,
          LongPressListener = nil,
          LongPressEndListner = nil,
          clickDel = nil,
          noBgFlag = nil
        })
      end
      if item then
        item:setScale(scale)
        self:addChild(item, zOrder)
        item:setPosition(ccp(x, y))
        local s = item:getSize()
        x = x + s.width * scale + 10
        rewardItem[#rewardItem + 1] = item
      end
    end
  end
  return rewardItem
end
function CGiftItem:reflushOnlineRewardTime()
  if self.m_CdTime <= 0 then
    self:getNode("txt1"):setEnabled(false)
  else
    local ct = checkint(self.m_CdTime)
    if ct ~= self.m_CdLastShowTime then
      self.m_CdLastShowTime = ct
      local h, m, s = getHMSWithSeconds(ct)
      if h > 0 then
        self:getNode("txt1"):setText(string.format("%02d:%02d:%02d", h, m, s))
      else
        self:getNode("txt1"):setText(string.format("%02d:%02d", m, s))
      end
    end
  end
end
function CGiftItem:frameUpdate(dt)
  if self.m_GiftId ~= Gift_OnLine_ID then
    return
  end
  self:OnlineRewardUpdate(dt)
end
function CGiftItem:OnlineRewardUpdate(dt)
  if self.m_CdTime >= 0 then
    self.m_CdTime = self.m_CdTime - dt
    self:reflushOnlineRewardTime()
  end
end
function CGiftItem:setTouchStatus(isTouch)
end
function CGiftItem:SetRedIconBtn(flag)
  local btn = self.btn_recive
  if flag then
    if btn.redIcon == nil then
      local redIcon = display.newSprite("views/pic/pic_tipnew.png")
      btn:addNode(redIcon, 0)
      redIcon:setPosition(ccp(60, 20))
      btn.redIcon = redIcon
    end
  elseif btn.redIcon then
    btn.redIcon:removeFromParent()
    btn.redIcon = nil
  end
end
function CGiftItem:OnBtn_Recive(btnObj, touchType)
  if self.m_GiftId == Gift_Festival_ID then
    do
      local canJumpFlagTips = ""
      if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
        canJumpFlagTips = "你正在进行婚礼巡游,无法进行此项操作"
      end
      if g_WarScene then
        if g_WarScene and g_WarScene:getIsWatching() then
          canJumpFlagTips = "观战中,不能跳转"
        end
        if g_WarScene and g_WarScene:getIsReview() then
          canJumpFlagTips = "回放中,不能跳转"
        end
        if JudgeIsInWar() then
          canJumpFlagTips = "战斗中,不能跳转"
        end
      end
      if canJumpFlagTips ~= "" then
        ShowNotifyTips(canJumpFlagTips)
        return
      end
      if g_HuodongView then
        g_HuodongView:CloseSelf()
      end
      local npcId = 95117
      g_MapMgr:AutoRouteToNpc(npcId, function(isSucceed)
        if isSucceed and CMainUIScene.Ins then
          CMainUIScene.Ins:ShowNormalNpcViewById(npcId)
        end
      end)
    end
  elseif self.m_GiftId == Gift_OnLine_ID then
    print("在线奖励")
    netsend.netgift.reqGetOnlineReward()
  elseif self.m_GiftId == Gift_LevelUp_ID then
    print("冲级奖励")
    netsend.netgift.reqGetLevelupReward()
  elseif self.m_GiftId == Gift_Login_ID then
    print("上线奖励")
    netsend.netgift.reqGetLoginGift()
  elseif self.m_GiftId == Gift_SignUp_ID then
    print("签到")
    g_HuodongView:HideSelf()
    netsend.netgift.reqReflush()
    local callback = function()
      if g_HuodongView then
        g_HuodongView:ShowSelf()
      end
    end
    getCurSceneView():addSubView({
      subView = GiftRewardOfCheckin.new(callback),
      zOrder = MainUISceneZOrder.menuView
    })
  elseif self.m_GiftId == Gift_NewTermCheckIn_ID then
    print("新学期签到")
    g_HuodongView:HideSelf()
    local callback = function()
      if g_HuodongView then
        g_HuodongView:ShowSelf()
      end
    end
    getCurSceneView():addSubView({
      subView = CNewTermCheckInView.new(callback),
      zOrder = MainUISceneZOrder.menuView
    })
  elseif self.m_GiftId == Gift_GuoQingCheckIn_ID then
    print("国庆签到")
    g_HuodongView:HideSelf()
    local callback = function()
      if g_HuodongView then
        g_HuodongView:ShowSelf()
      end
    end
    getCurSceneView():addSubView({
      subView = CGuoQingCheckInView.new(callback),
      zOrder = MainUISceneZOrder.menuView
    })
  elseif self.m_GiftId == Gift_GetInput_ID then
    ShowInputCodeView()
  else
    ShowInputCodeView(self.m_GiftId)
  end
end
function CGiftItem:Touched()
end
function CGiftItem:Clear()
  self.m_ListObj = nil
end

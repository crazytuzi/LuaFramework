EventItem = class("EventItem", CcsSubView)
function EventItem:ctor(eventId, listObj)
  EventItem.super.ctor(self, "views/event_item.csb")
  local btnBatchListener = {
    btn_recive = {
      listener = handler(self, self.OnBtn_Recive),
      variName = "btn_recive"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_EventId = eventId
  self.m_ListObj = listObj
  self.bg = self:getNode("bg")
  self.m_ActionBg = self.bg
  self.title1 = self:getNode("title1")
  self.title2 = self:getNode("title2")
  self.reward = self:getNode("reward")
  self.times = self:getNode("times")
  local tempData = data_DailyHuodongAward[self.m_EventId] or {}
  local lv = g_LocalPlayer:getObjProperty(1, PROPERTY_ROLELEVEL)
  local zs = g_LocalPlayer:getObjProperty(1, PROPERTY_ZHUANSHENG)
  local needZs, needLv, alwaysJudgeLvFlag = tempData.OpenZs, tempData.OpenLv, tempData.AlwaysJudgeLvFlag
  local openEventFlag = data_judgeFuncOpen(zs, lv, needZs, needLv, alwaysJudgeLvFlag)
  local data = data_DailyHuodongAward[eventId]
  local events = activity.event:getAllEvent()
  local proData = events[eventId] or {}
  self.m_State = proData.state or 1
  self.m_Progress = proData.progress or 0
  if eventId == 10012 then
    local timeStr = ""
    if self.m_State == activity.event.Status_CanRecive or self.m_State == activity.event.Status_HadRecive then
      local endTimePoint = activity.event:getYueKaEndTime()
      if endTimePoint ~= 0 then
        local restTime = endTimePoint - g_DataMgr:getServerTime()
        if restTime > 0 then
          local dayNum = math.ceil(restTime / 3600 / 24)
          if dayNum > 0 then
            timeStr = string.format("(有效期:%d天)", dayNum)
          end
        end
      end
    end
    self.title1:setText(data.TypeName .. timeStr)
  else
    self.title1:setText(data.TypeName)
  end
  self.title2:setText(data.Title)
  local icon = display.newSprite(data.Icon)
  self.bg:getParent():addNode(icon, 10)
  local x, y = self.bg:getPosition()
  local x1, y1 = self.title1:getPosition()
  local s1 = self.bg:getSize()
  icon:setPosition(ccp((x - s1.width / 2 + x1) / 2, y))
  if self.m_State == activity.event.Status_CanRecive then
    self.btn_recive:setEnabled(false)
    self.times:setText("")
    local bgNew = display.newSprite("views/common/bg/bg1024.png")
    self.bg:getParent():addNode(bgNew, 1)
    local x, y = self.bg:getPosition()
    bgNew:setPosition(ccp(x, y))
    self.m_ActionBg = bgNew
    self.bg:setEnabled(false)
  else
    self:getNode("pic_canRecive"):setEnabled(false)
    if eventId == 10001 or eventId == 10002 then
      self.btn_recive:setEnabled(false)
      self.times:setText("时间未到")
    else
      if data.Condition == nil or #data.Condition == 1 and data.Condition[1] == 0 then
        self.times:setText("")
      else
        self.times:setText(string.format("%d/%d", self.m_Progress, data.Condition[1]))
      end
      self.btn_recive:setTitleText("前往")
    end
  end
  if openEventFlag == false then
    local openLv = tempData.OpenLv or 0
    self.times:setText(string.format("%d级开启", openLv))
    self.btn_recive:setEnabled(false)
  end
  if self.m_EventId == 11007 then
    self.btn_recive:setEnabled(false)
  end
  local awardList = activity.event:getEventReward(self.m_EventId)
  if openEventFlag == false then
    awardList = {}
  end
  local noRewardFlag = true
  local ox, oy = self.reward:getPosition()
  local size = self.reward:getSize()
  local parent = self.reward:getParent()
  ox = ox + size.width + 20
  for i, d in ipairs(awardList) do
    local objId = d[1]
    local num = d[2]
    local path
    if objId < 1000 then
      path = data_getResPathByResID(objId)
    else
      local itemShape = data_getItemShapeID(objId)
      path = data_getItemPathByShape(itemShape)
    end
    if path then
      noRewardFlag = false
      local icon = display.newSprite(path)
      local size = icon:getContentSize()
      local sh = 36 / size.height
      local s = 36 / size.width
      if sh < s then
        s = sh
      end
      if s > 1 then
        s = 1
      end
      icon:setScale(s)
      local width = s * size.width
      parent:addNode(icon, 10)
      icon:setPosition(ccp(ox + width / 2, oy))
      local numTxt = ui.newTTFLabel({
        text = string.format("x%d", num),
        font = KANG_TTF_FONT,
        size = 25,
        color = ccc3(224, 85, 44)
      })
      parent:addNode(numTxt, 10)
      local sizeTxt = numTxt:getContentSize()
      numTxt:setPosition(ccp(ox + width + sizeTxt.width / 2, oy))
      ox = ox + width + sizeTxt.width + 20
    end
  end
  if noRewardFlag then
    self.reward:setVisible(false)
  else
    self.reward:setVisible(true)
  end
  self:SetDataEx()
end
function EventItem:SetDataEx()
  if g_CMainMenuHandler and g_CMainMenuHandler:JudgeEventNeedRemind(self.m_EventId) then
    self:SetRedIconBtn(true)
    g_CMainMenuHandler:SetEventHasShowRemind(self.m_EventId)
  end
end
function EventItem:HasCheckEvent()
  if g_CMainMenuHandler and g_CMainMenuHandler:JudgeEventNeedRemind(self.m_EventId) then
    g_CMainMenuHandler:SetEventRemind(self.m_EventId)
  end
end
function EventItem:SetRedIconBtn(flag)
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
function EventItem:setTouchStatus(isTouch)
  self.m_ActionBg:stopAllActions()
  if isTouch then
    self.m_ActionBg:setScaleX(0.96)
    self.m_ActionBg:setScaleY(0.96)
  else
    self.m_ActionBg:setScaleX(1)
    self.m_ActionBg:setScaleY(1)
    self.m_ActionBg:runAction(transition.sequence({
      CCScaleTo:create(0.1, 1, 1),
      CCScaleTo:create(0.1, 1, 1)
    }))
  end
end
function EventItem:OnBtn_Recive(btnObj, touchType)
  print("EventItem:OnBtn_Recive")
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
  if self.m_State ~= activity.event.Status_CanRecive then
    if self.m_EventId == 10003 then
      if canJumpFlagTips ~= "" then
        ShowNotifyTips(canJumpFlagTips)
        return
      end
      Shimen.GotoShimenNpc()
    elseif self.m_EventId == 10006 then
      if canJumpFlagTips ~= "" then
        ShowNotifyTips(canJumpFlagTips)
        return
      end
      ZhuaGui.GotoNpc()
    elseif self.m_EventId == 10007 then
      if canJumpFlagTips ~= "" then
        ShowNotifyTips(canJumpFlagTips)
        return
      end
      activity.tianting:GotoNpc()
    elseif self.m_EventId == 10008 then
      if canJumpFlagTips ~= "" then
        ShowNotifyTips(canJumpFlagTips)
        return
      end
      activity.dayanta:GotoNpc()
    elseif self.m_EventId == 10009 then
      getCurSceneView():addSubView({
        subView = CSkillShow.new(),
        zOrder = MainUISceneZOrder.menuView
      })
    elseif self.m_EventId == 10010 then
      ShowBattlePvpDlg()
    elseif self.m_EventId == 10011 then
    elseif self.m_EventId == 10012 then
      ShowRechargeView()
    elseif self.m_EventId == 10013 then
      self:HasCheckEvent()
      if canJumpFlagTips ~= "" then
        ShowNotifyTips(canJumpFlagTips)
        return
      end
      activity.keju:GotoNpc()
    elseif self.m_EventId == 10014 then
      if canJumpFlagTips ~= "" then
        ShowNotifyTips(canJumpFlagTips)
        return
      end
      GuiWang.GotoNpc()
    elseif self.m_EventId == 10015 then
      if canJumpFlagTips ~= "" then
        ShowNotifyTips(canJumpFlagTips)
        return
      end
      local tInfo = data_WorldMapTeleporter[118]
      local len = #tInfo.toPos
      local pos = tInfo.toPos[math.random(1, len)]
      g_MapMgr:AutoRoute(tInfo.tomap, {
        pos[1],
        pos[2]
      })
    elseif self.m_EventId == 10016 then
      if canJumpFlagTips ~= "" then
        ShowNotifyTips(canJumpFlagTips)
        return
      end
      local ttime = SanJieLiLian.getCircle()
      if ttime == nil or ttime <= 0 or ttime >= SanJieLiLian.Limei_Times or ttime == 1 and SanJieLiLian.missionId_ == -1 or SanJieLiLian.missionId_ == SanJieLiLian.AcceptMissionId then
        SanJieLiLian.GotoSanJieLiLianNpc()
      elseif SanJieLiLian.isMissionId(SanJieLiLian.missionId_) then
        g_MissionMgr:TraceMission(SanJieLiLian.missionId_)
      end
    elseif self.m_EventId == 10017 then
      if canJumpFlagTips ~= "" then
        ShowNotifyTips(canJumpFlagTips)
        return
      end
      local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_DoubleExp)
      if openFlag == false then
        if noOpenType == OPEN_FUNC_Type_Gray then
          ShowNotifyTips(tips)
        end
        return
      end
      local teamerFlag = g_LocalPlayer:getNormalTeamer()
      if teamerFlag ~= true and g_LocalPlayer:getGuajiState() ~= GUAJI_STATE_OFF then
        TellSerToStopGuaji()
        return
      end
      ShowGuajiMenu()
    elseif self.m_EventId == 10018 then
      if canJumpFlagTips ~= "" then
        ShowNotifyTips(canJumpFlagTips)
        return
      end
      local npcId = data_Mission_Activity[DaTingCangBaoTu_MissionId].startNpc
      if CDaTingCangBaoTu.taskid == nil then
        g_MapMgr:AutoRouteToNpc(npcId, function(isSucceed)
          if isSucceed and CMainUIScene.Ins then
            CDaTingCangBaoTu.requestBaoTuMission()
          end
        end)
      else
        CDaTingCangBaoTu.TraceMission()
      end
    elseif self.m_EventId == 10019 then
      if canJumpFlagTips ~= "" then
        ShowNotifyTips(canJumpFlagTips)
        return
      end
      local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_SanJieLiLian)
      if openFlag == false then
        ShowNotifyTips(tips)
        return
      else
        do
          local npcId = 90016
          g_MapMgr:AutoRouteToNpc(npcId, function(isSucceed)
            if isSucceed and CMainUIScene.Ins then
              CMainUIScene.Ins:ShowNormalNpcViewById(npcId)
            end
          end)
        end
      end
    elseif self.m_EventId == 10020 then
      if canJumpFlagTips ~= "" then
        ShowNotifyTips(canJumpFlagTips)
        return
      end
      local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_BangPai)
      if openFlag == false then
        ShowNotifyTips(tips)
        return
      else
        do
          local npcId = NPC_BangPaiShangRen_ID
          g_MapMgr:AutoRouteToNpc(npcId, function(isSucceed)
            if isSucceed and CMainUIScene.Ins then
              CMainUIScene.Ins:ShowNormalNpcViewById(npcId)
            end
          end)
        end
      end
    elseif self.m_EventId == 10021 then
      if canJumpFlagTips ~= "" then
        ShowNotifyTips(canJumpFlagTips)
        return
      end
      local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_BangPai)
      if openFlag == false then
        ShowNotifyTips(tips)
        return
      else
        do
          local npcId = NPC_BangPaiShiYe_ID
          g_MapMgr:AutoRouteToNpc(npcId, function(isSucceed)
            if isSucceed and CMainUIScene.Ins then
              CMainUIScene.Ins:ShowNormalNpcViewById(npcId)
            end
          end)
        end
      end
    elseif self.m_EventId == 11001 then
      self:HasCheckEvent()
      if canJumpFlagTips ~= "" then
        ShowNotifyTips(canJumpFlagTips)
        return
      end
      do
        local npcId = 90015
        g_MapMgr:AutoRouteToNpc(npcId, function(isSucceed)
          if isSucceed and CMainUIScene.Ins then
            CMainUIScene.Ins:ShowNormalNpcViewById(npcId)
          end
        end)
      end
    elseif self.m_EventId == 11002 then
      self:HasCheckEvent()
      if canJumpFlagTips ~= "" then
        ShowNotifyTips(canJumpFlagTips)
        return
      end
      local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_TTHJ)
      if openFlag == false then
        ShowNotifyTips(tips)
        return
      else
        g_MapMgr:AutoRouteToNpc(NPC_HuangChengShouJiang_ID, function(isSucceed)
          if isSucceed then
            ShowTTHJView()
          end
        end)
      end
    elseif self.m_EventId == 11003 then
      self:HasCheckEvent()
      if canJumpFlagTips ~= "" then
        ShowNotifyTips(canJumpFlagTips)
        return
      end
      do
        local npcId = 90926
        g_MapMgr:AutoRouteToNpc(npcId, function(isSucceed)
          if isSucceed and CMainUIScene.Ins then
            CMainUIScene.Ins:ShowNormalNpcViewById(npcId)
          end
        end)
      end
    elseif self.m_EventId == 11004 then
      self:HasCheckEvent()
      if canJumpFlagTips ~= "" then
        ShowNotifyTips(canJumpFlagTips)
        return
      end
      do
        local npcId = 90015
        g_MapMgr:AutoRouteToNpc(npcId, function(isSucceed)
          if isSucceed and CMainUIScene.Ins then
            CMainUIScene.Ins:ShowNormalNpcViewById(npcId)
          end
        end)
      end
    elseif self.m_EventId == 11006 then
      self:HasCheckEvent()
      if canJumpFlagTips ~= "" then
        ShowNotifyTips(canJumpFlagTips)
        return
      end
      do
        local npcId = 90015
        g_MapMgr:AutoRouteToNpc(npcId, function(isSucceed)
          if isSucceed and CMainUIScene.Ins then
            CMainUIScene.Ins:ShowNormalNpcViewById(npcId)
          end
        end)
      end
    elseif self.m_EventId == 11008 then
      self:HasCheckEvent()
      if canJumpFlagTips ~= "" then
        ShowNotifyTips(canJumpFlagTips)
        return
      end
      local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_TianDiQiShu)
      if openFlag == false then
        ShowNotifyTips(tips)
        return
      else
        do
          local npcId = NPC_TianShuLaoRen_ID
          g_MapMgr:AutoRouteToNpc(npcId, function(isSucceed)
            if isSucceed and CMainUIScene.Ins then
              CMainUIScene.Ins:ShowNormalNpcViewById(npcId)
            end
          end)
        end
      end
    elseif self.m_EventId == 10022 then
      self:HasCheckEvent()
      if canJumpFlagTips ~= "" then
        ShowNotifyTips(canJumpFlagTips)
        return
      end
      XiuLuo.GotoNpc()
    elseif self.m_EventId == 12001 then
      if canJumpFlagTips ~= "" then
        ShowNotifyTips(canJumpFlagTips)
        return
      end
      do
        local npcId = 95118
        g_MapMgr:AutoRouteToNpc(npcId, function(isSucceed)
          if isSucceed and CMainUIScene.Ins then
            CMainUIScene.Ins:ShowNormalNpcViewById(npcId)
          end
        end)
      end
    elseif self.m_EventId == 12002 then
      if canJumpFlagTips ~= "" then
        ShowNotifyTips(canJumpFlagTips)
        return
      end
      do
        local npcId = NPC_ChangEXianZi_ID
        g_MapMgr:AutoRouteToNpc(npcId, function(isSucceed)
          if isSucceed and CMainUIScene.Ins then
            CMainUIScene.Ins:ShowNormalNpcViewById(npcId)
          end
        end)
      end
    end
    if self.m_ListObj and self.m_ListObj.parent ~= nil then
      self.m_ListObj.parent:CloseSelf()
    end
  else
    activity.event:reqReciveAward(self.m_EventId)
  end
end
function EventItem:Touched()
  if self.m_State == activity.event.Status_CanRecive then
    activity.event:reqReciveAward(self.m_EventId)
  end
end
function EventItem:Clear()
  self.m_ListObj = nil
end

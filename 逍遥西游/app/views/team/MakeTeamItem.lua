local CTeamItemBase = class("CTeamItemBase", CcsSubView)
function CTeamItemBase:ctor(pid, clickHeadListener, jsonPath)
  CTeamItemBase.super.ctor(self, jsonPath)
  self.m_ClickHeadListener = clickHeadListener
  self.headpos = self:getNode("headpos")
  self.txt_name = self:getNode("txt_name")
  self.txt_zs = self:getNode("txt_zs")
  self.txt_lv = self:getNode("txt_lv")
  self.txt_lv_title = self:getNode("txt_lv_title")
  self.headpos:setVisible(false)
  self:setBaseInfo(pid)
end
function CTeamItemBase:setBaseInfo(pid)
  self.m_PlayerId = pid
  local role = g_TeamMgr:getPlayerMainHero(pid)
  if role == nil then
    print("************************ CTeamItemBase error: role == nil ", pid)
    self.txt_name:setText("----")
    self.txt_zs:setText("-")
    self.txt_lv:setText("-")
    if self.m_HeadIcon ~= nil then
      self.m_HeadIcon:removeFromParentAndCleanup(true)
      self.m_HeadIcon = nil
    end
    return
  end
  local touchEnabled = true
  if self.m_HeadIcon ~= nil then
    touchEnabled = self.m_HeadIcon:isTouchEnabled()
    self.m_HeadIcon:removeFromParentAndCleanup(true)
    self.m_HeadIcon = nil
  end
  local headParent = self.headpos:getParent()
  local hx, hy = self.headpos:getPosition()
  local zOrder = self.headpos:getZOrder()
  local headIcon = createClickHead({
    roleTypeId = role:getTypeId(),
    autoSize = nil,
    clickListener = handler(self, self.OnClickHead),
    noBgFlag = nil,
    offx = nil,
    offy = nil,
    clickDel = nil,
    LongPressTime = nil,
    LongPressListener = nil,
    LongPressEndListner = nil
  })
  headParent:addChild(headIcon, zOrder)
  headIcon:setPosition(ccp(hx, hy + 7))
  headIcon:setTouchEnabled(touchEnabled)
  self.m_HeadIcon = headIcon
  local zs = role:getProperty(PROPERTY_ZHUANSHENG)
  self.txt_zs:setText(tostring(zs))
  local name = role:getProperty(PROPERTY_NAME)
  self.txt_name:setText(name)
  local nameColor = NameColor_MainHero[zs]
  if nameColor then
    self.txt_name:setColor(nameColor)
  end
  local lv = role:getProperty(PROPERTY_ROLELEVEL)
  self.txt_lv:setText(tostring(lv))
  local x, y = self.txt_lv:getPosition()
  local size = self.txt_lv:getContentSize()
  self.txt_lv_title:setPosition(ccp(x + size.width + 4, y))
end
function CTeamItemBase:SetRace()
  local role = g_TeamMgr:getPlayerMainHero(self.m_PlayerId)
  if role == nil then
    return
  end
  self.txt_race = self:getNode("txt_race")
  local race = role:getProperty(PROPERTY_RACE)
  if race ~= nil then
    local raceTxt = RACENAME_DICT[race] or ""
    self.txt_race:setText(raceTxt)
  else
    self.txt_race:setText("-族")
  end
end
function CTeamItemBase:SetAddIcon()
  local addIcon = display.newSprite("views/common/btn/btn_add.png")
  self.m_HeadIcon:addNode(addIcon)
  addIcon:setPosition(20, 20)
end
function CTeamItemBase:getPlayerId()
  return self.m_PlayerId
end
function CTeamItemBase:OnClickHead()
  print("OnClickHead:", self.m_PlayerId)
  if self.m_ClickHeadListener then
    self.m_ClickHeadListener(self.m_PlayerId)
  end
end
function CTeamItemBase:Clear()
  if self.m_ClickHeadListener then
    self.m_ClickHeadListener = nil
  end
end
CMyTeamItem = class("CMyTeamItem", CTeamItemBase)
function CMyTeamItem:ctor(teamId, pid, isLocal, moreListener)
  CMyTeamItem.super.ctor(self, pid, nil, "views/myteam_item.json")
  local btnBatchListener = {
    btn_more = {
      listener = handler(self, self.Btn_More),
      variName = "btn_more"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_TeamId = teamId
  self.m_MoreListener = moreListener
  self.bg = self:getNode("bg")
  self.pic_captain = self:getNode("pic_captain")
  self.pic_leave = self:getNode("pic_leave")
  self.pic_outline = self:getNode("pic_outline")
  if isLocal then
    self.btn_more:setEnabled(false)
  end
  self.m_HeadIcon:setTouchEnabled(false)
  local role = g_TeamMgr:getPlayerMainHero(pid)
  if role == nil then
    return
  end
  local isCaptain = role:getProperty(PROPERTY_ISCAPTAIN)
  self:SetIsCaptain(isCaptain)
  self:SetRace()
  local teamState = role:getProperty(PROPERTY_TEAMSTATE)
  self:SetTeamState(teamState)
  local online = role:getProperty(PROPERTY_TEAMSTATUS)
  self:SetTeamOnline(online)
  self:ListenMessage(MsgID_Team)
  self:ListenMessage(MsgID_OtherPlayer)
end
function CMyTeamItem:SetIsCaptain(isCaptain)
  self.m_IsCaptain = isCaptain
  if isCaptain == TEAMCAPTAIN_YES and not self.pic_outline:isVisible() then
    self.pic_captain:setVisible(true)
  else
    self.pic_captain:setVisible(false)
  end
end
function CMyTeamItem:SetTeamState(teamState)
  self.m_TeamState = teamState
  if teamState == TEAMSTATE_LEAVE and not self.pic_outline:isVisible() then
    self.pic_leave:setVisible(true)
  else
    self.pic_leave:setVisible(false)
  end
end
function CMyTeamItem:SetTeamOnline(online)
  if online == TEAMSTATUS_ONLINE then
    self.pic_outline:setVisible(false)
  else
    self.pic_outline:setVisible(true)
  end
  self:SetIsCaptain(self.m_IsCaptain)
  self:SetTeamState(self.m_TeamState)
end
function CMyTeamItem:Btn_More(obj, t)
  print("-->>>Btn_More")
  if self.m_MoreListener then
    local x, y = self.btn_more:getPosition()
    local wPos = self.btn_more:getParent():convertToWorldSpace(ccp(x, y))
    self.m_MoreListener(self.m_PlayerId, wPos)
  end
end
function CMyTeamItem:OnMessage(msgSID, ...)
  if self.m_UINode == nil then
    return
  end
  local arg = {
    ...
  }
  if msgSID == MsgID_Team_TeamState then
    local pid = arg[2]
    if pid == self.m_PlayerId then
      local teamState = arg[3]
      self:SetTeamState(teamState)
    end
  elseif msgSID == MsgID_Team_PlayerOnline then
    local pid = arg[2]
    if pid == self.m_PlayerId then
      local online = arg[3]
      self:SetTeamOnline(online)
    end
  elseif msgSID == MsgID_Team_SetCaptain then
    local pid = arg[2]
    if pid == self.m_PlayerId then
      local isCaptain = arg[3]
      self:SetIsCaptain(isCaptain)
    end
  elseif msgSID == MsgID_OtherPlayer_UpdatePlayer then
    local pid = arg[1]
    if pid == self.m_PlayerId then
      self:setBaseInfo(self.m_PlayerId)
      self:SetRace()
    end
  end
end
function CMyTeamItem:Clear()
  CMyTeamItem.super.Clear(self)
  self.m_MoreListener = nil
end
CJoinPlayerItem = class("CJoinPlayerItem", CTeamItemBase)
function CJoinPlayerItem:ctor(pid, clickHeadListener)
  CJoinPlayerItem.super.ctor(self, pid, clickHeadListener, "views/noteam_item.json")
  local btnBatchListener = {
    btn_delete = {
      listener = handler(self, self.OnBtn_Delete),
      variName = "btn_delete"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:SetRace()
  self:SetAddIcon()
end
function CJoinPlayerItem:OnBtn_Delete()
  netsend.netteam.deleteJoinRequest(self.m_PlayerId)
end
CTeamCaptainItem = class("CTeamCaptainItem", CcsSubView)
function CTeamCaptainItem:ctor(teamId, info, clickHeadListener, delayDelListener)
  CTeamCaptainItem.super.ctor(self, "views/teamcaptain_item.json")
  local btnBatchListener = {
    btn_join = {
      listener = handler(self, self.OnClickHead),
      variName = "btn_join"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_TeamId = teamId
  self.m_ClickHeadListener = clickHeadListener
  self.m_DelayDelListener = delayDelListener
  self.m_TargetId = info.i_target
  self.m_Num = info.i_num
  self.m_Time = info.i_time
  self.m_Name = info.i_cname
  self.m_Zhuan = info.i_czs
  self.m_TeamLevel = info.i_clevel
  self.m_TaskId = info.i_tid
  self.m_IsEffectItem = true
  self.m_Info = info
  self:SetHead(info.i_typeid)
  self:SetCaptainName()
  self:SetTargetAndNum(self.m_TargetId, self.m_Num)
  self:SetTeamLevel()
  self:ListenMessage(MsgID_Team)
end
function CTeamCaptainItem:SetHead(lTypeId)
  if self.m_HeadIcon ~= nil then
    self.m_HeadIcon:removeFromParentAndCleanup(true)
    self.m_HeadIcon = nil
  end
  self.headpos = self:getNode("headpos")
  self.headpos:setVisible(false)
  local headParent = self.headpos:getParent()
  local hx, hy = self.headpos:getPosition()
  local zOrder = self.headpos:getZOrder()
  local size = self.headpos:getContentSize()
  local headIcon = createWidgetFrameHeadIconByRoleTypeID(lTypeId)
  headParent:addChild(headIcon, zOrder)
  headIcon:setPosition(ccp(hx + size.width / 2, hy + size.height / 2))
  self.m_HeadIcon = headIcon
end
function CTeamCaptainItem:SetCaptainName()
  self.txt_name = self:getNode("txt_name")
  self.txt_name:setText(self.m_Name)
  local nameColor = NameColor_MainHero[self.m_Zhuan]
  if nameColor then
    self.txt_name:setColor(nameColor)
  end
end
function CTeamCaptainItem:SetTargetAndNum(target, num)
  local maxNum = GetTeamPlayerNumLimit(target)
  local desc = data_getPromulgateDesc(target)
  self.txt_target = self:getNode("txt_target")
  self.txt_target:setText(desc)
  self.pro = self:getNode("pro")
  self.pro:setText(string.format("(%d/%d)", num, maxNum))
  self.bar = self:getNode("bar")
  self.bar:setPercent(math.ceil(num / maxNum * 100))
  self.txt_teamlevel = self:getNode("txt_teamlevel")
  local x, y = self.txt_target:getPosition()
  local size = self.txt_target:getContentSize()
  self.txt_teamlevel:setPosition(ccp(x + size.width + 10, y))
end
function CTeamCaptainItem:SetTeamLevel()
  self.txt_teamlevel = self:getNode("txt_teamlevel")
  if self.m_TargetId == PromulgateTeamTarget_BangPai then
    local helpFlag = true
    if self.m_TaskId == nil then
      self.txt_teamlevel:setText("")
      helpFlag = false
    elseif self.m_TaskId == 1 then
      self.txt_teamlevel:setText("宝图怪物")
    elseif self.m_TaskId >= 2 and self.m_TaskId <= 7 then
      self.txt_teamlevel:setText("历练怪物")
    elseif self.m_TaskId == 8 then
      self.txt_teamlevel:setText("帮派暗战")
    elseif self.m_TaskId == 9 then
      self.txt_teamlevel:setText("帮派除奸")
    else
      local taskName = data_getMainMissionName(self.m_TaskId)
      self.txt_teamlevel:setText(taskName)
    end
    if helpFlag then
      self.txt_target:setText("帮派求助")
    end
  elseif self.m_TargetId == PromulgateTeamTarget_ZXJQ then
    if self.m_TaskId ~= nil then
      local taskName = data_getMainMissionName(self.m_TaskId)
      self.txt_teamlevel:setText(taskName)
    else
      self.txt_teamlevel:setText("")
    end
  else
    local level = self.m_TeamLevel
    local lv = math.floor(level / 10) * 10 + math.ceil(math.max(level % 10 - 4, 0) / 10) * 10
    local minLv = math.max(lv - 20, 0)
    local maxLv = math.min(lv + 20, 180)
    local info = data_getPromulgateInfo(self.m_TargetId)
    if info and minLv < info.level then
      minLv = info.level
      if maxLv < minLv then
        maxLv = minLv
      end
    end
    self.txt_teamlevel:setText(string.format("%d~%d级队伍", minLv, maxLv))
  end
  local x, y = self.txt_target:getPosition()
  local size = self.txt_target:getContentSize()
  self.txt_teamlevel:setPosition(ccp(x + size.width + 10, y))
end
function CTeamCaptainItem:OnClickHead()
  if self.m_Num >= GetTeamPlayerNumLimit(self.m_TargetId) then
    ShowNotifyTips("该队伍人数已满", true)
    return
  end
  if not self.m_IsEffectItem then
    return
  end
  if self.m_ClickHeadListener then
    self.m_ClickHeadListener(self.m_TeamId, self.m_Name)
  end
end
function CTeamCaptainItem:getTeamId()
  return self.m_TeamId
end
function CTeamCaptainItem:getInfo()
  return self.m_Info
end
function CTeamCaptainItem:getIsEffect()
  return self.m_IsEffectItem
end
function CTeamCaptainItem:getTime()
  return self.m_Time
end
function CTeamCaptainItem:OnMessage(msgSID, ...)
  if self.m_UINode == nil then
    return
  end
  local arg = {
    ...
  }
  if msgSID == MsgID_Team_UpdatePromulgateTeam then
    local teamId = arg[1]
    local info = arg[2]
    if teamId == self.m_TeamId then
      if info.i_num ~= nil then
        self.m_Num = info.i_num
        self:SetTargetAndNum(self.m_TargetId, self.m_Num)
      end
      if info.i_target ~= nil then
        self.m_TargetId = info.i_target
        self:SetTargetAndNum(self.m_TargetId, self.m_Num)
        self:SetTeamLevel()
      end
      if info.i_tid ~= nil then
        self.m_TaskId = info.i_tid
        self:SetTeamLevel()
      end
      if info.i_typeid ~= nil then
        self:SetHead(info.i_typeid)
      end
      if info.i_cname ~= nil then
        self.m_Name = info.i_cname
        self:SetCaptainName()
      end
      if info.i_czs ~= nil then
        self.m_Zhuan = info.i_czs
        self:SetCaptainName()
      end
      if info.i_clevel ~= nil then
        self.m_TeamLevel = info.i_clevel
        self:SetTeamLevel()
      end
    end
  elseif msgSID == MsgID_Team_DelayDelPromulgateTeam then
    local teamId = arg[1]
    if teamId == self.m_TeamId and self.m_IsEffectItem then
      self.m_IsEffectItem = false
      local act1 = CCDelayTime:create(1)
      local act2 = CCCallFunc:create(function()
        if self.m_DelayDelListener then
          self.m_DelayDelListener(self)
        end
      end)
      self:runAction(transition.sequence({act1, act2}))
    end
  elseif msgSID == MsgID_Team_PromulgateEffectTeam then
    local teamId = arg[1]
    if teamId == self.m_TeamId and not self.m_IsEffectItem then
      self.m_IsEffectItem = true
      self:stopAllActions()
    end
  end
end
function CTeamCaptainItem:Clear()
  self.m_ClickHeadListener = nil
  self.m_DelayDelListener = nil
end
CTeamTargetItem = class("CTeamTargetItem", CcsSubView)
function CTeamTargetItem:ctor(tid, info, selListener)
  CTeamTargetItem.super.ctor(self, "views/teamtarget.json")
  local btnBatchListener = {
    btn_select = {
      listener = handler(self, self.Btn_Select),
      variName = "btn_select"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_TargetId = tid
  self.m_Zhuan = info.rebirth
  self.m_Level = info.level
  self.m_SelListener = selListener
  self.m_IsSelected = false
  self.icon_sel = self:getNode("icon_sel")
  self.level = self:getNode("level")
  self.title = self:getNode("title")
  self:SetSelected(false)
  self.title:setText(info.desc)
  if self.m_Level > 0 or self.m_Zhuan > 0 then
    self.level:setText(string.format("要求:%d转%d级", self.m_Zhuan, self.m_Level))
    self.level:setVisible(true)
  else
    self.level:setVisible(false)
  end
  self:SetIsMatchingTarget()
  self:ListenMessage(MsgID_Team)
end
function CTeamTargetItem:getTargetId()
  return self.m_TargetId
end
function CTeamTargetItem:getZhuan()
  return self.m_Zhuan
end
function CTeamTargetItem:getLevel()
  return self.m_Level
end
function CTeamTargetItem:getSelected()
  return self.m_IsSelected
end
function CTeamTargetItem:SetSelected(iSel)
  self.m_IsSelected = iSel
  self.icon_sel:setVisible(iSel)
end
function CTeamTargetItem:SetSelectBtnIsEnabled(enabled)
  self.btn_select:setTouchEnabled(enabled)
end
function CTeamTargetItem:Btn_Select(obj, t)
  if self.m_SelListener then
    self.m_SelListener(self.m_TargetId, self.m_Zhuan, self.m_Level)
  end
end
function CTeamTargetItem:SetIsCurrTarget(isCurr)
  if isCurr then
    if self.m_CurrTxt == nil then
      local parent = self.title:getParent()
      local x, y = self.title:getPosition()
      local z = self.title:getZOrder()
      local size = self.title:getContentSize()
      local ft = self.title:getFontName()
      self.m_CurrTxt = ui.newTTFLabel({
        text = "(当前)",
        fontSize = 22,
        font = ft,
        color = ccc3(255, 255, 255)
      })
      parent:addNode(self.m_CurrTxt, z)
      self.m_CurrTxt:setAnchorPoint(ccp(0, 0.5))
      self.m_CurrTxt:setPosition(x + size.width, y)
    else
      self.m_CurrTxt:setVisible(true)
    end
  elseif self.m_CurrTxt then
    self.m_CurrTxt:setVisible(false)
  end
end
function CTeamTargetItem:SetIsMatchingTarget()
  local matchFlag = g_TeamMgr:GetIsAutoMatching()
  local matchTarget = g_TeamMgr:GetIsAutoMatchingTarget()
  if matchFlag == 1 or matchFlag == true then
    if g_TeamMgr:getLocalPlayerTeamId() == 0 then
      if matchTarget == self.m_TargetId then
        self:ShowIsMatchingTarget(true)
      else
        self:ShowIsMatchingTarget(false)
      end
    else
      self:ShowIsMatchingTarget(false)
    end
  else
    self:ShowIsMatchingTarget(false)
  end
end
function CTeamTargetItem:ShowIsMatchingTarget(flag)
  local txt_macthing = self:getNode("txt_macthing")
  if flag then
    txt_macthing:setVisible(true)
    local _, y = txt_macthing:getPosition()
    local x, _ = self.title:getPosition()
    local tSize = self.title:getContentSize()
    txt_macthing:setPosition(ccp(x + tSize.width, y))
  else
    txt_macthing:setVisible(false)
  end
end
function CTeamTargetItem:OnMessage(msgSID, ...)
  if self.m_UINode == nil then
    return
  end
  if msgSID == MsgID_Team_IsAutoMatching then
    self:SetIsMatchingTarget()
  end
end
function CTeamTargetItem:Clear()
  self.m_SelListener = nil
end
CPlayerInfoOfTeam = class("CPlayerInfoOfTeam", CPlayerInfoOfMap)
function CPlayerInfoOfTeam:ctor(pid, closeListener)
  CPlayerInfoOfTeam.super.ctor(self, pid)
  self.m_CloseListener = closeListener
  local arrow = display.newSprite("views/pic/pic_arrow_left.png")
  self:addNode(arrow, 999)
  local bsize = self:getContentSize()
  arrow:setPosition(ccp(bsize.width + 5, bsize.height / 2))
  arrow:setRotation(180)
  self.m_Arrrow = arrow
end
function CPlayerInfoOfTeam:Clear()
  CPlayerInfoOfTeam.super.Clear(self)
  if self.m_CloseListener ~= nil then
    self.m_CloseListener()
    self.m_CloseListener = nil
  end
end

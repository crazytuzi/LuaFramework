CSocialityTeamItem = class("CSocialityTeamItem", CcsSubView)
function CSocialityTeamItem:ctor(teamId, info, clickJoinListener, delayDelListener)
  CSocialityTeamItem.super.ctor(self, "views/promulgateitem.json")
  local btnBatchListener = {
    btn_join = {
      listener = handler(self, self.Btn_Join),
      variName = "btn_join"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_TeamId = teamId
  self.m_ClickJoinListener = clickJoinListener
  self.m_DelayDelListener = delayDelListener
  self.m_Num = info.i_num
  self.m_Time = info.i_time
  self.m_Name = info.i_cname
  self.m_TargetId = info.i_target
  self.m_TeamLevel = info.i_clevel
  self.m_Zhuan = info.i_czs
  self.m_TaskId = info.i_tid
  self.m_IsEffectItem = true
  self.headbg = self:getNode("headbg")
  self.txt_name = self:getNode("txt_name")
  self.txt_teamname = self:getNode("txt_teamname")
  self.txt_num = self:getNode("txt_num")
  self.bar = self:getNode("bar")
  self.txt_level = self:getNode("txt_level")
  self.txt_teamlevel = self:getNode("txt_teamlevel")
  self.txt_time = self:getNode("txt_time")
  self:SetHead(info.i_typeid)
  self:SetCaptainName()
  self:SetTarget()
  self:SetNum(info.i_num)
  self:SetCaptainZSAndLv()
  self:SetTeamLevel()
  self:SetTime(self.m_Time)
  self:startTimer()
  self:ListenMessage(MsgID_Team)
end
function CSocialityTeamItem:SetHead(lTypeId)
  if self.m_HeadIcon ~= nil then
    self.m_HeadIcon:removeFromParentAndCleanup(true)
    self.m_HeadIcon = nil
  end
  local headParent = self.headbg:getParent()
  local hx, hy = self.headbg:getPosition()
  local zOrder = self.headbg:getZOrder()
  local s = self.headbg:getScale()
  local headIcon = createHeadIconByRoleTypeID(lTypeId)
  headParent:addNode(headIcon, zOrder)
  headIcon:setScale(s)
  headIcon:setPosition(ccp(hx, hy + 7 * s))
  self.m_HeadIcon = headIcon
end
function CSocialityTeamItem:SetCaptainName()
  self.txt_name:setText(self.m_Name)
  self:setRoleLevelPos()
end
function CSocialityTeamItem:SetTarget()
  local desc = data_getPromulgateDesc(self.m_TargetId)
  self.txt_teamname:setText(desc)
  self:setTeamLevelPos()
end
function CSocialityTeamItem:SetNum(num)
  local maxNum = GetTeamPlayerNumLimit(self.m_TargetId)
  self.txt_num:setText(string.format("%d/%d", num, maxNum))
  self.bar:setPercent(math.ceil(num / maxNum * 100))
end
function CSocialityTeamItem:SetCaptainZSAndLv()
  self.txt_level:setText(string.format("%d转%d级", self.m_Zhuan, self.m_TeamLevel))
  self:setRoleLevelPos()
end
function CSocialityTeamItem:SetTeamLevel()
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
      self.txt_teamname:setText("帮派求助")
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
    self.txt_teamlevel:setText(string.format("%d~%d级", minLv, maxLv))
  end
  self:setTeamLevelPos()
end
function CSocialityTeamItem:setTeamLevelPos()
  local x, y = self.txt_teamname:getPosition()
  local size = self.txt_teamname:getContentSize()
  self.txt_teamlevel:setPosition(ccp(x + size.width + 5, y))
end
function CSocialityTeamItem:setRoleLevelPos()
  local x, y = self.txt_name:getPosition()
  local size = self.txt_name:getContentSize()
  self.txt_level:setPosition(ccp(x + size.width + 15, y))
end
function CSocialityTeamItem:SetTime(ltime)
  local curTime = g_DataMgr:getServerTime()
  local delTime = curTime - ltime
  if delTime < 60 then
    self.txt_time:setText("刚刚")
  elseif delTime < 3600 then
    self.txt_time:setText(string.format("%d分钟前", math.floor(delTime / 60)))
  else
    self.txt_time:setText(string.format("%d小时前", math.floor(delTime / 3600)))
  end
end
function CSocialityTeamItem:UpdateTime()
  self:SetTime(self.m_Time)
end
function CSocialityTeamItem:getTeamId()
  return self.m_TeamId
end
function CSocialityTeamItem:getIsEffect()
  return self.m_IsEffectItem
end
function CSocialityTeamItem:getTime()
  return self.m_Time
end
function CSocialityTeamItem:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_Team_UpdatePromulgateTeam then
    local teamId = arg[1]
    local info = arg[2]
    if teamId == self.m_TeamId then
      if info.i_num ~= nil then
        self.m_Num = info.i_num
        self:SetNum(info.i_num)
      end
      if info.i_target ~= nil then
        self.m_TargetId = info.i_target
        self:SetTarget()
        self:SetTeamLevel()
        self:SetNum(self.m_Num)
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
      if info.i_clevel ~= nil then
        self.m_TeamLevel = info.i_clevel
        self:SetTeamLevel()
        self:SetCaptainZSAndLv()
      end
      if info.i_time ~= nil then
        self.m_Time = info.i_time
        self:SetTime(self.m_Time)
      end
      if info.i_czs ~= nil then
        self.m_Zhuan = info.i_czs
        self:SetCaptainZSAndLv()
        self:SetCaptainName()
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
function CSocialityTeamItem:startTimer()
  self:stopAllActions()
  local dt = math.random(400, 600) / 100
  local act1 = CCDelayTime:create(dt)
  local act2 = CCCallFunc:create(function()
    self:UpdateTime()
  end)
  self:runAction(CCRepeatForever:create(transition.sequence({act1, act2})))
end
function CSocialityTeamItem:stopTimer()
  self:stopAllActions()
end
function CSocialityTeamItem:Btn_Join(obj, t)
  if self.m_Num >= GetTeamPlayerNumLimit(self.m_TargetId) then
    ShowNotifyTips("该队伍人数已满", true)
    return
  end
  if not self.m_IsEffectItem then
    return
  end
  if self.m_ClickJoinListener then
    self.m_ClickJoinListener(self.m_TeamId, self.m_Name)
  end
end
function CSocialityTeamItem:Clear()
  self.m_ClickJoinListener = nil
  self.m_DelayDelListener = nil
end

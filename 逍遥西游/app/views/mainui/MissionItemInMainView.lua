CMissionItemInMainView = class("CMissionItemInMainView", function()
  local widget = Widget:create()
  widget:setAnchorPoint(ccp(0, 0))
  widget:ignoreContentAdaptWithSize(false)
  return widget
end)
local _CountDownTimeType_ZhuaGui = 1
local _CountDownTimeType_GuiWang = 2
local _CountDownTimeType_Totem = 3
local _CountDownTimeType_TaskToken = 4
local _CountDownTimeType_BangPaiChuMo = 5
local _CountDownTimeType_ShoujiZhufu = 6
local _CountDownTimeType_XiuLuo = 7
local _MinHeight = 72
function CMissionItemInMainView:ctor(width, missionId)
  self.m_MissionId = missionId
  if self.m_MissionId ~= -1 then
    self.m_MissionKind = getMissionKind(missionId)
  else
    self.m_MissionKind = MissionKind_Main
  end
  self.m_IsLoadFailed = nil
  self:setTouchEnabled(true)
  local function listener(event)
    local name = event.name
    if name == "cleanup" then
      self:Clear()
    elseif name == "enter" then
      self:onEnterEvent()
    end
  end
  local handle = self:addNodeEventListener(cc.NODE_EVENT, listener)
  self.m_Width = width - 10
  local bgPath = "views/mainviews/pic_mission_item_bg.png"
  self.m_BgSize = CCSize(276, 75)
  self.m_BgPic = display.newScale9Sprite(bgPath, 0, 0, self.m_BgSize)
  self:addNode(self.m_BgPic, 1)
  self.m_WarTipsPic = nil
  self.m_TxtX = 10
  self.m_MissionNameTxtX = self.m_TxtX
  self.m_NameTxt = RichText.new({
    width = width - self.m_TxtX * 2,
    verticalSpace = 0,
    color = ccc3(1, 228, 185),
    font = FONT_NAME_MISSION,
    fontSize = 18
  })
  self:addChild(self.m_NameTxt, 2)
  self.m_DesTxt = RichText.new({
    width = width - self.m_TxtX * 2,
    verticalSpace = 0,
    color = ccc3(255, 255, 255),
    font = FONT_NAME_MISSION,
    fontSize = 18
  })
  self:addChild(self.m_DesTxt, 2)
  self.m_Name = nil
  self.m_Des = nil
  self.m_CountDownType = nil
  self.m_CountDownTxt = nil
  self.m_CountDownLeaveTime = -1
  self.m_CompleteAni = nil
  self.m_IsComplete = false
  self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.frameUpdate))
end
function CMissionItemInMainView:getMissionId()
  return self.m_MissionId
end
function CMissionItemInMainView:reFresh()
  if self.m_MissionId ~= -1 then
    return self:reFresh_Normal()
  else
    return self:reFresh_NoMain()
  end
end
function CMissionItemInMainView:reFresh_NoMain()
  if self.m_Name == nil then
    self.m_NameTxt:clearAll()
    self.m_NameTxt:addRichText("[主线]提升等级")
    self.m_Name = "[主线]提升等级"
  end
  local dst = g_MissionMgr:getNeedUpgradeStr() or ""
  if self.m_Des ~= dst then
    self.m_DesTxt:clearAll()
    self.m_DesTxt:addRichText(dst)
    self.m_Des = dst
  end
  if self.m_WarTipsPic then
    self.m_WarTipsPic:removeSelf()
    self.m_WarTipsPic = nil
  end
  local txtSpace = 2
  local bgSpace = 2
  local desSize = self.m_DesTxt:getRichTextSize()
  local nameSize = self.m_NameTxt:getRichTextSize()
  local totalHeight = desSize.height + nameSize.height + bgSpace + txtSpace
  if totalHeight < _MinHeight then
    totalHeight = _MinHeight
  end
  local oldSize = self.m_BgPic:getContentSize()
  if oldSize.width ~= self.m_Width or oldSize.height ~= totalHeight then
    local s = cc.Size(self.m_Width, totalHeight)
    self:setSize(s)
    self.m_BgPic:setContentSize(cc.Size(self.m_Width, totalHeight - bgSpace))
    self.m_BgPic:setPosition(ccp(s.width / 2, s.height / 2))
  end
  local th_left = totalHeight - txtSpace / 2
  local sp_h = (th_left - desSize.height - nameSize.height) / 3
  local des_y = txtSpace / 2 + sp_h
  self.m_DesTxt:setPosition(ccp(self.m_TxtX, des_y))
  self.m_NameTxt:setPosition(ccp(self.m_MissionNameTxtX, des_y + sp_h + desSize.height))
  if self.m_WarTipsPic then
    local s1 = self.m_WarTipsPic:getContentSize()
    self.m_WarTipsPic:setPosition(ccp(s1.width / 2 - 1, totalHeight - s1.height / 2))
    self.m_NameTxt:setPosition(ccp(self.m_MissionNameTxtX + 10, des_y + sp_h + desSize.height))
  end
  return true
end
function CMissionItemInMainView:reFresh_Normal()
  local dataTable = g_MissionMgr:getMissionData(self.m_MissionId)
  if dataTable == nil then
    printLog("ERROR", "任务数据出错[%d]", self.m_MissionId)
    self.m_IsLoadFailed = true
    return false
  end
  local dstDes, needWar, dst = g_MissionMgr:getMissionShowParam(self.m_MissionId)
  if dstDes == nil then
    return false
  end
  if self.m_Des ~= dstDes and dstDes then
    self.m_DesTxt:clearAll()
    if self.m_MissionId == Business_MissionId then
      if BangPaiPaoShang.target ~= nil then
        local progress_ = string.format("筹集银两#<Y>(%d/%s)# ", BangPaiPaoShang.local_progess, tostring(BangPaiPaoShang.target))
        dstDes = progress_
      else
        return
      end
    end
    if self.m_MissionId == DaTingCangBaoTu_MissionId and CDaTingCangBaoTu.taskid ~= nil then
      local monsterName, mapName = CDaTingCangBaoTu.getMosterNameAndLoc()
      local des = string.format("前往#<Y>%s#战胜#<Y>%s#", mapName, monsterName)
      dstDes = des
    end
    self.m_DesTxt:addRichText(dstDes)
    self.m_Des = dstDes
  end
  if needWar then
    if self.m_WarTipsPic == nil then
      local warTipsPath = "views/mainviews/pic_mission_wartips_left.png"
      local warTipsPic = display.newSprite(warTipsPath)
      self:addNode(warTipsPic, 10)
      self.m_WarTipsPic = warTipsPic
    end
  elseif self.m_WarTipsPic then
    self.m_WarTipsPic:removeSelf()
    self.m_WarTipsPic = nil
  end
  local timeEnd
  if self.m_MissionId == ZhuaGui_MissionId then
    if g_LocalPlayer._zg_taskId > 0 then
      timeEnd = g_LocalPlayer._zg_endTime
      self.m_CountDownType = _CountDownTimeType_ZhuaGui
    end
  elseif self.m_MissionId == BangPaiChuMo_MissionId then
    if 0 <= BangPaiChuMo.taskid_ then
      if BangPaiChuMo.state_ == 1 then
        timeEnd = BangPaiChuMo.endTime
        self.m_CountDownType = _CountDownTimeType_BangPaiChuMo
      else
        timeEnd = nil
        if self.m_CountDownTxt then
          self.m_CountDownTxt:removeFromParent()
          self.m_CountDownTxt = nil
        end
      end
    end
  elseif self.m_MissionId == GuiWang_MissionId then
    if 0 < g_LocalPlayer._gw_taskId then
      timeEnd = g_LocalPlayer._gw_endTime
      self.m_CountDownType = _CountDownTimeType_GuiWang
    end
  elseif self.m_MissionId == Totem_MissionId then
    if 0 < g_LocalPlayer._bptotem_taskId then
      timeEnd = g_LocalPlayer._bptotem_endTime
      self.m_CountDownType = _CountDownTimeType_Totem
    end
  elseif self.m_MissionId == TaskToken_MuJi_MissionId or self.m_MissionId == TaskToken_AnZhan_MissionId or self.m_MissionId == TaskToken_ChuMo_MissionId then
    if g_LocalPlayer._bptoken_taskId[self.m_MissionId] == true then
      timeEnd = g_LocalPlayer._bptoken_endTime[self.m_MissionId]
      self.m_CountDownType = _CountDownTimeType_TaskToken
    end
  elseif self.m_MissionId == ShoujiZhufu_MissionId then
    if g_HunyinMgr then
      timeEnd = g_HunyinMgr:getZhufuEndTime()
      self.m_CountDownType = _CountDownTimeType_ShoujiZhufu
    end
  elseif self.m_MissionId == XiuLuo_MissionId and 0 < g_LocalPlayer._xl_taskId then
    timeEnd = g_LocalPlayer._xl_endTime
    self.m_CountDownType = _CountDownTimeType_XiuLuo
  end
  if timeEnd ~= nil then
    if self.m_CountDownTxt == nil then
      self:initCountDownTime()
    end
    self.m_CountDownLeaveTime = timeEnd - g_DataMgr:getServerTime()
    if 0 > self.m_CountDownLeaveTime then
      self.m_CountDownLeaveTime = 0
    end
    self:flushCountDownTime()
  end
  local finished, param, complete = g_MissionMgr:getMissionProgress(self.m_MissionId)
  print("判断是否完成 =============》  ", self.m_MissionId, finished, param, complete)
  if BangPaiPaoShang.taskid ~= nil and self.m_MissionId == Business_MissionId then
    if BangPaiPaoShang.progress >= BangPaiPaoShang.target then
      finished = 1
      complete = true
    else
      complete = false
    end
  end
  local finishTxtAdd
  local dataTable = g_MissionMgr:getMissionData(self.m_MissionId)
  local dst = g_MissionMgr:getDstData(dataTable, finished)
  if complete then
    if self.m_CompleteAni == nil then
      self:createCompleteAni()
    end
    self.m_CompleteAni:setVisible(true)
    finishTxtAdd = "(完成)"
  elseif dst.type == MissionType_UseObjInMap then
    if self.m_CompleteAni == nil then
      self:createCompleteAni()
    end
    finishTxtAdd = "(完成)"
    self.m_CompleteAni:setVisible(true)
  elseif self.m_CompleteAni then
    self.m_CompleteAni:setVisible(false)
  end
  self.m_IsComplete = complete or false
  local kindName = g_MissionMgr:getMissionKindName(self.m_MissionId, self.m_MissionKind)
  local missionName = g_MissionMgr:convertMissionName(dataTable.mnName, self.m_MissionId)
  local name
  if self.m_MissionId == DaTingCangBaoTu_MissionId then
    kindName = "宝图"
    missionName = "宝图战斗"
  end
  if finishTxtAdd then
    name = string.format("[%s]%s#<g:255>%s#", tostring(kindName), tostring(missionName), tostring(finishTxtAdd))
  else
    name = string.format("[%s]%s", tostring(kindName), tostring(missionName))
  end
  if self.m_Name ~= name then
    self.m_NameTxt:clearAll()
    self.m_NameTxt:addRichText(name)
    self.m_Name = name
  end
  local txtSpace = 2
  local bgSpace = 2
  local desSize = self.m_DesTxt:getRichTextSize()
  local nameSize = self.m_NameTxt:getRichTextSize()
  local totalHeight = desSize.height + nameSize.height + bgSpace + txtSpace
  print("--->> totalHeight:", totalHeight)
  local cdtHeight = 0
  if timeEnd ~= nil then
    cdtHeight = self.m_CountDownTxt:getRichTextSize().height
    totalHeight = totalHeight + cdtHeight
    self.m_CountDownTxt:setPosition(ccp(self.m_TxtX, txtSpace / 2))
  end
  if totalHeight < _MinHeight then
    totalHeight = _MinHeight
  end
  local oldSize = self.m_BgPic:getContentSize()
  if oldSize.width ~= self.m_Width or oldSize.height ~= totalHeight then
    local s = cc.Size(self.m_Width, totalHeight)
    local bgSize = cc.Size(self.m_Width, totalHeight - bgSpace)
    local bgPos = ccp(s.width / 2, s.height / 2)
    self:setSize(s)
    self.m_BgPic:setContentSize(bgSize)
    self.m_BgPic:setPosition(bgPos)
    if self.m_CompleteAni then
      self.m_CompleteAni:setContentSize(bgSize)
      self.m_CompleteAni:setPosition(bgPos)
    end
  end
  local th_left = totalHeight - cdtHeight - txtSpace / 2
  local sp_h = (th_left - desSize.height - nameSize.height) / 3
  local des_y = txtSpace / 2 + cdtHeight + sp_h
  self.m_DesTxt:setPosition(ccp(self.m_TxtX, des_y))
  self.m_NameTxt:setPosition(ccp(self.m_MissionNameTxtX, des_y + sp_h + desSize.height))
  if self.m_WarTipsPic then
    local s1 = self.m_WarTipsPic:getContentSize()
    self.m_WarTipsPic:setPosition(ccp(s1.width / 2 - 1, totalHeight - s1.height / 2))
    self.m_NameTxt:setPosition(ccp(self.m_MissionNameTxtX + 10, des_y + sp_h + desSize.height))
  end
  return true
end
function CMissionItemInMainView:createCompleteAni()
  if self.m_CompleteAni == nil then
    local size = self.m_BgPic:getContentSize()
    self.m_CompleteAni = display.newScale9Sprite("views/mainviews/pic_mission_item_bg_cmp.png", 0, 0, size)
    self:addNode(self.m_CompleteAni, 2)
    local x, y = self.m_BgPic:getPosition()
    self.m_CompleteAni:setPosition(x, y)
  end
end
function CMissionItemInMainView:onEnterEvent()
  if g_MissionMgr then
    g_MissionMgr:registerClassObj(self, self.__cname, self.m_MissionId)
  end
  if self.m_CountDownTxt ~= nil then
    self:scheduleUpdate()
  end
end
function CMissionItemInMainView:Clear()
  if g_MissionMgr then
    g_MissionMgr:unRegisterClassObj(self, self.__cname, self.m_MissionId)
  end
end
function CMissionItemInMainView:setTouchStatus(isTouch)
  if self.m_CompleteAni == nil then
    self:createCompleteAni()
  end
  for i, bgNode in pairs({
    self.m_BgPic,
    self.m_CompleteAni
  }) do
    bgNode:stopAllActions()
    if isTouch then
      bgNode:setScaleX(0.96)
      bgNode:setScaleY(0.96)
      if bgNode == self.m_CompleteAni then
        bgNode:setVisible(true)
      end
    else
      bgNode:setScaleX(1)
      bgNode:setScaleY(1)
      if bgNode == self.m_CompleteAni then
        bgNode:runAction(transition.sequence({
          CCScaleTo:create(0.1, 1, 1),
          CCCallFunc:create(function()
            local missionPro = g_MissionMgr:getMissionProgress(self.m_MissionId)
            local dataTable = g_MissionMgr:getMissionData(self.m_MissionId)
            local dst = g_MissionMgr:getDstData(dataTable, missionPro)
            if dst.type == MissionType_UseObjInMap then
              bgNode:setVisible(true)
            else
              bgNode:setVisible(self.m_IsComplete)
            end
          end)
        }))
      else
        bgNode:runAction(transition.sequence({
          CCScaleTo:create(0.1, 1, 1)
        }))
      end
    end
  end
end
function CMissionItemInMainView:frameUpdate(dt)
  if self.m_CountDownLeaveTime >= 0 then
    self.m_CountDownLeaveTime = self.m_CountDownLeaveTime - dt
    self:flushCountDownTime()
  end
end
function CMissionItemInMainView:initCountDownTime()
  local fntColor = VIEW_DEF_WARNING_COLOR
  if self.m_CountDownType == _CountDownTimeType_TaskToken then
    fntColor = VIEW_DEF_NORMAL_COLOR
  end
  self.m_CountDownTxt = RichText.new({
    width = self.m_Width - self.m_TxtX + 5,
    verticalSpace = 0,
    color = fntColor,
    font = KANG_TTF_FONT,
    fontSize = 18
  })
  self:addChild(self.m_CountDownTxt, 2)
end
function CMissionItemInMainView:flushCountDownTime()
  if self.m_CountDownLeaveTime >= 0 then
    local t = math.floor(self.m_CountDownLeaveTime)
    if self.m_LastShowLeaveTime ~= t then
      self.m_LastShowLeaveTime = t
      self.m_CountDownTxt:clearAll()
      if self.m_CountDownType == _CountDownTimeType_TaskToken then
        local m = math.ceil(self.m_LastShowLeaveTime / 60)
        m = math.max(m, 1)
        self.m_CountDownTxt:addRichText(string.format("双倍奖励剩余:%d分钟", m))
      else
        local h, m, s = getHMSWithSeconds(self.m_LastShowLeaveTime)
        if h < 0 then
          h = 0
        end
        if m < 0 then
          m = 0
        end
        if s < 0 then
          s = 0
        end
        if h <= 0 then
          self.m_CountDownTxt:addRichText(string.format("剩余%02d分%02d秒", m, s))
        else
          self.m_CountDownTxt:addRichText(string.format("剩余%02d时%02d分%02d秒", h, m, s))
        end
      end
    end
  end
  if self.m_CountDownLeaveTime <= 0 then
    local dt
    if self.m_CountDownType == _CountDownTimeType_ZhuaGui then
      dt = ZhuaGui.detectEndTime(true)
    elseif self.m_CountDownType == _CountDownTimeType_GuiWang then
      dt = GuiWang.detectEndTime(true)
    elseif self.m_CountDownType == _CountDownTimeType_Totem then
      dt = BangPaiTotem.detectEndTime(true)
    elseif self.m_CountDownType == _CountDownTimeType_TaskToken then
      dt = BangPaiRenWuLing.detectEndTime(self.m_MissionId, true)
    elseif self.m_CountDownType == _CountDownTimeType_BangPaiChuMo then
      dt = BangPaiChuMo.detectEndTime(true)
    elseif self.m_CountDownType == _CountDownTimeType_ShoujiZhufu then
      if g_HunyinMgr then
        g_HunyinMgr:zhufuMissionOutTime()
      end
    elseif self.m_CountDownType == _CountDownTimeType_XiuLuo then
      dt = XiuLuo.detectEndTime(true)
    end
    if dt ~= nil then
      self.m_CountDownLeaveTime = dt
    end
  end
end

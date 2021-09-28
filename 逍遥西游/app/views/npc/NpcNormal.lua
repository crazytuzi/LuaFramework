FunctionItem = class("FunctionItem", function()
  local item = Widget:create()
  return item
end)
function FunctionItem:ctor(name, data, type, iconPath)
  local btnPath = "views/npc/btn_npc01.png"
  local btnObj = display.newSprite(btnPath)
  local size = btnObj:getContentSize()
  btnObj:setPosition(ccp(size.width / 2, size.height / 2))
  self.m_BtnSprite = btnObj
  self:setAnchorPoint(ccp(0, 0))
  self:ignoreContentAdaptWithSize(false)
  self:setSize(CCSize(size.width, size.height + 5))
  self:addNode(btnObj, 1)
  self:setTouchEnabled(true)
  self.m_Data = data
  self.m_DataType = type
  local dx_icon = 15
  local dx_name = 50
  local maxWidthForIcon = 40
  if iconPath ~= nil then
    local icon = display.newSprite(iconPath)
    if icon then
      self:addNode(icon, 2)
      local iconSize = icon:getContentSize()
      local s = maxWidthForIcon / iconSize.width
      if s > 1 then
        s = 1
      end
      icon:setPosition(ccp(dx_icon + s * iconSize.width / 2, size.height / 2))
    end
  end
  local nameTxt = ui.newTTFLabel({
    text = name,
    font = KANG_TTF_FONT,
    color = ccc3(255, 255, 255),
    size = 23
  })
  self:addNode(nameTxt, 2)
  local txtSize = nameTxt:getContentSize()
  nameTxt:setPosition(ccp(txtSize.width / 2 + dx_name, size.height / 2))
  self:setNodeEventEnabled(true)
  if g_MissionMgr then
    g_MissionMgr:registerClassObj(self, self.__cname, self.m_Data)
  end
end
function FunctionItem:getDataAndType()
  return self.m_Data, self.m_DataType
end
function FunctionItem:setItemTouchedStatus(isTouched)
  local s = 1
  if isTouched then
    s = 0.95
  end
  self.m_BtnSprite:setScale(s)
end
function FunctionItem:onCleanup()
  if g_MissionMgr then
    g_MissionMgr:unRegisterClassObj(self, self.__cname, self.m_Data)
  end
end
CNpcNormal = class("CNpcNormal", CNpcViewBase)
function CNpcNormal:ctor(npcId)
  CNpcNormal.super.ctor(self, npcId, nil, "views/npc_normal.json")
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:adjustClickSize(self.btn_close, 85, 85)
  local pic_bg = self:getNode("pic_bg")
  local size = pic_bg:getContentSize()
  self:setPosition(ccp(15, (display.height - size.height) / 2))
  self:enableCloseWhenTouchOutsideBySize(pic_bg:getCascadeBoundingBox())
  self.m_NpcId = npcId
  self.m_NpcData = data_NpcInfo[npcId]
  if self.m_NpcData == nil then
    printLog("ERROR", "找不到NPC[%d]", npcId)
    self:CloseSelf()
    return
  end
  self.m_TouchStartItem = nil
  self.btn_list = self:getNode("btn_list")
  local size = self.btn_list:getSize()
  self.m_listWidth = size.width
  self.m_listHeight = size.height
  self.btn_list:addTouchItemListenerListView(handler(self, self.ListSelector), handler(self, self.ListEventListener))
  self:ListenMessage(MsgID_ItemInfo)
  self:ListenMessage(MsgID_BP)
  self:ListenMessage(MsgID_Mission)
  self:ListenMessage(MsgID_DaYanTa)
  self:ListenMessage(MsgID_Activity)
  self:ListenMessage(MsgID_MapScene)
  self:getNode("txt_name"):setText(self.m_NpcData.name)
  self:setHead(self.m_NpcData.shape)
  self:TalkRubbish()
  self:LoadFunction()
  if g_CMainMenuHandler then
    local eventId = 11002
    if self.m_NpcId == NPC_HuangChengShouJiang_ID and g_CMainMenuHandler:JudgeEventNeedRemind(eventId) then
      g_CMainMenuHandler:SetEventRemind(eventId)
    end
    local eventId = 11003
    if self.m_NpcId == 90926 and g_CMainMenuHandler:JudgeEventNeedRemind(eventId) then
      g_CMainMenuHandler:SetEventRemind(eventId)
    end
  end
end
function CNpcNormal:TalkRubbish()
  local str = self:getSpecialRubisshTalk()
  if str == nil then
    local talkId = self.m_NpcData.talkid
    local talkStrTable = data_NpcRubbish[talkId] or {}
    local l = #talkStrTable
    if l <= 0 then
      return
    end
    str = talkStrTable[math.random(1, l)]
  end
  local str_chuyao = ""
  if str and self.m_NpcId == activity.dayanta.StartNpcId then
    if activity.dayanta.todayCicle == nil then
      activity.dayanta.todayCicle = 0
    end
    local ExchangeTimes = activity.dayanta:getExchangeTimes() or 0
    local MaxExchangeTimes = activity.dayanta:getMaxExchangeTimes()
    str_chuyao = string.format("除妖奖章可兑换次数%d/%d", ExchangeTimes, MaxExchangeTimes)
    local strPart2 = string.format("%d/%d", activity.dayanta.todayCicle, activity.dayanta.TodayLimit)
    str = "大雁塔封妖完成次数" .. strPart2
  elseif str and self.m_NpcId == NPC_CHENXIAOJIN_ID then
    local times = activity.tjbx:getExchangeSilverBoxTimes()
    local maxTimes = activity.tjbx:getExchangeSilverBoxMaxTimes()
    str = string.format("%s %d/%d", str, times, maxTimes)
  end
  print("====>> str:\n", str)
  local layer_des = self:getNode("layer_des")
  layer_des:setEnabled(false)
  local size = layer_des:getSize()
  self.m_txt = RichText.new({
    width = size.width,
    verticalSpace = 1,
    color = ccc3(78, 47, 20),
    font = KANG_TTF_FONT,
    fontSize = 18
  })
  self.m_txt:addRichText(str)
  self.m_txt:newLine()
  self.m_txt:addRichText(str_chuyao)
  self:addChild(self.m_txt, 11)
  local txtSize = self.m_txt:getRichTextSize()
  local x, y = layer_des:getPosition()
  print("====x, y =", x, y)
  self.m_txt:setPosition(ccp(x, y + size.height / 2 - txtSize.height / 2))
end
function CNpcNormal:getSpecialRubisshTalk()
  if self.m_NpcId == activity.tianting.startNpc then
    local cur = activity.tianting:getTodayFinishedTimes()
    local sum = activity.tianting:getDaylyNum()
    return string.format("天庭除妖已完成次数:%d/%d", cur, sum)
  end
  return nil
end
function CNpcNormal:LoadFunction()
  function getMissionIconWithType(statusType)
    if statusType == MapRoleStatus_TaskCanCommit then
      return "xiyou/ani/eff_can_commit.png"
    elseif statusType == MapRoleStatus_TaskNotComplete then
      return "xiyou/ani/eff_not_complete.png"
    else
      return "xiyou/ani/eff_can_accept.png"
    end
  end
  function getMissionIcon(missionId)
    local statusType = g_MissionMgr:getMissionStatusWithNpcByMissionId(missionId)
    return getMissionIconWithType(statusType)
  end
  self.m_Functions = self.m_NpcData.npctypes or {}
  local num = 0
  local itemSize
  local options = g_MissionMgr:getNpcMissionOption(self.m_NpcId)
  if options then
    for idx, data in ipairs(options) do
      local txt, missionId = unpack(data)
      local kindName = g_MissionMgr:getMissionKindName(missionId)
      local mmissionKind = getMissionKind(missionId)
      if mmissionKind == MissionKind_SanJieLiLian then
        txt = string.format("%s", txt)
      elseif missionId == TBSJ_MissionId then
        txt = string.format("%s", txt)
      else
        txt = string.format("[%s]%s", kindName, txt)
      end
      if missionId == TBSJ_MissionId then
        local item = FunctionItem.new(txt, missionId, 1)
        self.btn_list:pushBackCustomItem(item)
        itemSize = item:getSize()
        num = num + 1
      elseif missionId ~= DaTingCangBaoTu_MissionId then
        local item = FunctionItem.new(txt, missionId, 1, getMissionIcon(missionId))
        self.btn_list:pushBackCustomItem(item)
        itemSize = item:getSize()
        num = num + 1
      end
    end
  end
  local shimenNpcId = g_LocalPlayer:getShimenNpcId()
  print("===>self.m_NpcId, shimenNpcId", self.m_NpcId, shimenNpcId)
  if shimenNpcId == self.m_NpcId and g_LocalPlayer:isNpcOptionUnlock(1031) == true then
    print("当前师门")
    if Shimen.isAccepted() == false then
      if Shimen.isTimesLevel() == true then
        local t = Shimen.today_times + 1
        local name = string.format("领取师门任务(%d/%d)", t, Shimen.Limei_Times)
        local item = FunctionItem.new(name, 1031, 2, getMissionIconWithType(MapRoleStatus_TaskCanAccept))
        self.btn_list:pushBackCustomItem(item)
        itemSize = item:getSize()
        num = num + 1
      end
    else
      local item = FunctionItem.new("[师门]交付任务", 1032, 2, getMissionIconWithType(Shimen.getAcceptedStatus()))
      self.btn_list:pushBackCustomItem(item)
      itemSize = item:getSize()
      num = num + 1
    end
  end
  if shimenNpcId == self.m_NpcId and g_LocalPlayer:isNpcOptionUnlock(1087) == true then
    local funcData = data_NpcTypeInfo[1087]
    local item = FunctionItem.new(funcData.name, 1087, 2)
    self.btn_list:pushBackCustomItem(item)
    itemSize = item:getSize()
    num = num + 1
  end
  if self.m_NpcId == SanJieLiLian.MissionNPCId then
    local statetype
    print(" ===============>>>>>>>  SanJieLiLian.today_times   ", SanJieLiLian.today_times)
    if SanJieLiLian.isAccepted() == false and g_LocalPlayer:isNpcOptionUnlock(1044) == true and SanJieLiLian.today_times and 1 > SanJieLiLian.today_times then
      statetype = getMissionIconWithType(MapRoleStatus_TaskCanAccept)
    end
    local title = "领取三界历练任务"
    local item = FunctionItem.new(title, 1044, 2, statetype)
    self.btn_list:pushBackCustomItem(item)
    itemSize = item:getSize()
    num = num + 1
  end
  local paoshangNpcId = 90020
  if paoshangNpcId == self.m_NpcId then
    if BangPaiPaoShang.isCanAccetp() == true and BangPaiPaoShang.taskid == nil then
      local name = string.format("[帮派]跑商")
      local item
      if BangPaiPaoShang.isReachNeedLevel() and g_BpMgr:localPlayerHasBangPai() and 1 < g_BpMgr:getPaoShangTimes() and 0 < BangPaiPaoShang.todayTimes then
        item = FunctionItem.new(name, 1059, 2, getMissionIconWithType(MapRoleStatus_TaskCanAccept))
      else
        item = FunctionItem.new(name, 1059, 2)
      end
      self.btn_list:pushBackCustomItem(item)
      itemSize = item:getSize()
      num = num + 1
    else
      local item = FunctionItem.new("[跑商]交付任务", 1060, 2, getMissionIconWithType(BangPaiPaoShang.getAcceptedStatus(self.m_NpcId)))
      self.btn_list:pushBackCustomItem(item)
      itemSize = item:getSize()
      num = num + 1
    end
  end
  if (self.m_NpcId == 90021 or self.m_NpcId == 90022 or self.m_NpcId == 90941 or self.m_NpcId == 90931) and BangPaiPaoShang.goods then
    local goodsPriceList = {}
    for npcid, val in pairs(BangPaiPaoShang.goods) do
      npcid = tonumber(npcid)
      if npcid == self.m_NpcId then
        goodsPriceList = val
      end
    end
    if goodsPriceList ~= nil and BangPaiPaoShang.taskid ~= nil then
      self.m_itemCnt = 0
      for item, price in pairs(goodsPriceList) do
        self.m_itemCnt = self.m_itemCnt + 1
        item = tonumber(item)
        local name_item = data_Org_PaoShangTask[item].Name
        if item == 1 and price then
          local name = string.format("%s 收购价格:%d", name_item, price)
          self.item_1 = FunctionItem.new(name, 1062, 3)
          self.btn_list:pushBackCustomItem(self.item_1)
          itemSize = self.item_1:getSize()
        elseif item == 2 and price then
          local name = string.format("%s 收购价格:%d", name_item, price)
          self.item_2 = FunctionItem.new(name, 1063, 3)
          self.btn_list:pushBackCustomItem(self.item_2)
          itemSize = self.item_2:getSize()
        elseif item == 3 and price then
          local name = string.format("%s 收购价格:%d", name_item, price)
          self.item_3 = FunctionItem.new(name, 1064, 3)
          self.btn_list:pushBackCustomItem(self.item_3)
          itemSize = self.item_3:getSize()
        end
        num = num + 1
      end
    end
  end
  local CangBaoTuNPC = data_Mission_Activity[50004].startNpc
  if self.m_NpcId == CangBaoTuNPC and CDaTingCangBaoTu.isCanAcceptMission() == true and CDaTingCangBaoTu.taskid == nil and CDaTingCangBaoTu.cnt < DaTingCangBaoTu_MaxCircle then
    local name = string.format("打听藏宝图")
    local item = FunctionItem.new(name, 1076, 2, getMissionIconWithType(MapRoleStatus_TaskCanAccept))
    self.btn_list:pushBackCustomItem(item)
    g_MissionMgr:flushMissionStatusForNpc()
    itemSize = item:getSize()
    num = num + 1
  end
  if self.m_NpcId == 90019 then
    if g_BpMgr:getOpenChuMoFlag() == true or BangPaiChuMo.getMissionState() == 1 or BangPaiChuMo.getMissionState() == 2 then
      if BangPaiChuMo.getIsAccepted() == false then
        local name = "[帮派]除奸"
        local m_iconPath
        print("  帮派除奸   ====== 》 ", BangPaiChuMo.getCanAcceptChuMo())
        if BangPaiChuMo.getCanAcceptChuMo() then
          m_iconPath = getMissionIconWithType(MapRoleStatus_TaskCanAccept)
        end
        local item = FunctionItem.new(name, 1057, 2, m_iconPath)
        self.btn_list:pushBackCustomItem(item)
        itemSize = item:getSize()
        num = num + 1
      else
        local m_icon = BangPaiChuMo.getAcceptedStatus()
        if m_icon ~= nil then
          m_icon = getMissionIconWithType(m_icon)
        end
        local item = FunctionItem.new("[帮派]除奸", 1058, 2, m_icon)
        self.btn_list:pushBackCustomItem(item)
        itemSize = item:getSize()
        num = num + 1
      end
      local item = FunctionItem.new("帮派求助", 1084, 2, nil)
      self.btn_list:pushBackCustomItem(item)
    end
    if g_BpMgr:getOpenAnZhanFlag() == true or BangPaiAnZhan.getMissionState() == 1 or BangPaiAnZhan.getMissionState() == 2 then
      if BangPaiAnZhan.getIsAccepted() == false then
        local name = "[帮派]暗战"
        local m_iconPath
        if BangPaiAnZhan.getCanAcceptAnZhan() then
          m_iconPath = getMissionIconWithType(MapRoleStatus_TaskCanAccept)
        end
        local item = FunctionItem.new(name, 1065, 2, m_iconPath)
        self.btn_list:pushBackCustomItem(item)
        itemSize = item:getSize()
        num = num + 1
      else
        local m_icon = BangPaiAnZhan.getAcceptedStatus()
        if m_icon ~= nil then
          m_icon = getMissionIconWithType(m_icon)
        end
        local item = FunctionItem.new("[帮派]暗战", 1066, 2, m_icon)
        self.btn_list:pushBackCustomItem(item)
        itemSize = item:getSize()
        num = num + 1
      end
      local item = FunctionItem.new("帮派求助", 1085, 2, nil)
      self.btn_list:pushBackCustomItem(item)
    end
  end
  local myZs = g_LocalPlayer:getObjProperty(1, PROPERTY_ZHUANSHENG)
  local myLv = g_LocalPlayer:getObjProperty(1, PROPERTY_ROLELEVEL)
  local tbsjFlag, yzddFlag, xzscFlag, ltzbFlag = activity.event:getTodayEvent_TBSJ_YZDD()
  for i, funcId in ipairs(self.m_Functions) do
    if funcId == 1047 and g_BpMgr:getOpenChuMoFlag() ~= true and (BangPaiAnZhan.getMissionState() ~= 1 or BangPaiAnZhan.getMissionState() ~= 2) or funcId == 1046 and g_BpMgr:getOpenAnZhanFlag() ~= true and (BangPaiChuMo.getMissionState() ~= 1 or BangPaiChuMo.getMissionState() ~= 2) then
      print(" *****************   BangPaiAnZhan.getMissionState(   ) ", BangPaiAnZhan.getMissionState())
      print(" *****************  BangPaiChuMo.getMissionState(   ) ", BangPaiChuMo.getMissionState())
    else
      local funcData = data_NpcTypeInfo[funcId]
      if self:canFunctionLoad(funcId, funcData) then
        local zs = funcData.zs or 0
        local lv = funcData.lv or 0
        local alwaysJudgeLvFlag = funcData.AlwaysJudgeLvFlag or 0
        if data_judgeFuncOpen(myZs, myLv, zs, lv, alwaysJudgeLvFlag) then
          local item
          if funcId == 1026 then
            local packageNum = g_LocalPlayer:GetItemNum(ITEM_DEF_STUFF_CYJZ)
            local needNum = 5
            local name = string.format("%s(%d/%d)", funcData.name, packageNum, needNum)
            item = FunctionItem.new(name, funcId, 3)
          elseif funcId == 1078 then
            local packageNum = g_LocalPlayer:GetItemNum(ITEM_DEF_OTHER_BTCJ)
            local needNum = data_Variables.ChangeGJCBTNeedBTCJNum
            local name = string.format("%s(%d/%d)", funcData.name, packageNum, needNum)
            item = FunctionItem.new(name, funcId, 3)
          elseif funcId == 1082 then
            local name = "下次节日日期"
            if gift.festival:getFestivalId() then
              name = "领取节日礼物"
            end
            item = FunctionItem.new(name, funcId, 2)
          elseif funcId == 1115 then
            local events = activity.event:getAllEvent()
            local canProtectChangEFlag = false
            for eventId, proData in pairs(events) do
              if eventId == 12002 then
                local statu = proData.state
                if statu ~= activity.event.Status_HadRecive then
                  canProtectChangEFlag = true
                  break
                end
              end
            end
            if canProtectChangEFlag == true then
              item = FunctionItem.new(funcData.name, funcId, 2)
            end
          elseif funcData.type == 2 then
            print("----->>> type == 2")
            local isNeedShow, resetName = DetectNpcOptionNeedShow(funcId, self.m_NpcId)
            if isNeedShow == true then
              if resetName == nil then
                resetName = funcData.name
              end
              item = FunctionItem.new(funcData.name, funcId, 2)
            end
          else
            item = FunctionItem.new(funcData.name, funcId, 2)
          end
          if item ~= nil then
            if funcId == 1025 then
              self.btn_list:insertCustomItem(item, 0)
            elseif funcId == 1053 and ltzbFlag == true or funcId == 1081 and yzddFlag == true or funcId == 1089 and xzscFlag == true or funcId == 1079 and tbsjFlag == true then
              self.btn_list:insertCustomItem(item, 0)
            else
              self.btn_list:pushBackCustomItem(item)
            end
            itemSize = item:getSize()
            num = num + 1
          end
        end
      end
    end
  end
  local items = self:getMissionWhichIsDoing()
  if #items > 0 then
    for i, name in ipairs(items) do
      local item = FunctionItem.new(name, 1070, 2, getMissionIconWithType(MapRoleStatus_TaskNotComplete))
      self.btn_list:pushBackCustomItem(item)
      itemSize = item:getSize()
      num = num + 1
    end
  end
  if num == 1 then
    local dh = itemSize.height / 2
    self.btn_list:setSize(CCSize(self.m_listWidth, self.m_listHeight - dh))
  end
  self.btn_list:sizeChangedForShowMoreTips()
end
function CNpcNormal:getMissionWhichIsDoing()
  local items = {}
  local function _add(name)
    if name then
      items[#items + 1] = name
    end
  end
  if g_LocalPlayer == nil then
    return items
  end
  if ZhuaGui.isNpc(self.m_NpcId) and g_LocalPlayer._zg_taskId ~= 0 and g_LocalPlayer._zg_state == 1 then
    _add(g_MissionMgr:getMissionName(ZhuaGui_MissionId))
  end
  if GuiWang.isNpc(self.m_NpcId) and g_LocalPlayer._gw_taskId ~= 0 and g_LocalPlayer._gw_state == 1 then
    _add(g_MissionMgr:getMissionName(GuiWang_MissionId))
  end
  if XiuLuo.isNpc(self.m_NpcId) and g_LocalPlayer._xl_taskId ~= 0 and g_LocalPlayer._xl_state == 1 then
    _add(g_MissionMgr:getMissionName(XiuLuo_MissionId))
  end
  return items
end
function CNpcNormal:canFunctionLoad(funcId, funcData)
  if funcData == nil then
    return false
  end
  if funcId == 1026 then
    return activity.dayanta:canShowNpcExchange()
  end
  return true
end
function CNpcNormal:setHead(shapeId)
  local layer_head = self:getNode("layer_head")
  local x, y = layer_head:getPosition()
  local size = layer_head:getContentSize()
  layer_head:setEnabled(false)
  local pngPath = data_getBigHeadPathByShape(shapeId)
  local sharedFileUtils = CCFileUtils:sharedFileUtils()
  if sharedFileUtils:isFileExist(sharedFileUtils:fullPathForFilename(pngPath)) == false then
    pngPath = "xiyou/head/head11001_big.png"
  end
  local headImg = display.newSprite(pngPath)
  headImg:setAnchorPoint(ccp(0.5, 0))
  self:addNode(headImg, 20)
  headImg:setPosition(ccp(x + size.width / 2, y))
end
function CNpcNormal:ListSelector(item, index, listObj)
  soundManager.playSound("xiyou/sound/clickbutton_1.wav")
  self:FuncClick(item, index)
end
function CNpcNormal:ListEventListener(item, index, listObj, status)
  if status == LISTVIEW_ONSELECTEDITEM_START then
    item:setItemTouchedStatus(true)
    self.m_TouchStartItem = item
  elseif status == LISTVIEW_ONSELECTEDITEM_END and self.m_TouchStartItem then
    item:setItemTouchedStatus(false)
    self.m_TouchStartItem = nil
  end
end
function CNpcNormal:FuncClick(item, index)
  local data, t = item:getDataAndType()
  if t == 1 then
    g_MissionMgr:MissionOptionTouched(data, self.m_NpcId, self)
  elseif t == 2 then
    local isClose = NpcFuncStart(data, self.m_NpcId)
    if isClose then
      scheduler.performWithDelayGlobal(function()
        self:CloseSelf()
      end, 0.01)
    end
  elseif t == 3 then
    NpcFuncStart(data, self.m_NpcId)
  end
end
function CNpcNormal:OnMessage(msgSID, ...)
  if msgSID == MsgID_ItemInfo_AddItem or msgSID == MsgID_ItemInfo_DelItem or msgSID == MsgID_ItemInfo_ChangeItemNum then
    self.btn_list:removeAllItems()
    self:LoadFunction()
  elseif msgSID == MsgID_BP_PaoShang_DelItem then
    if BangPaiPaoShang.m_itemId ~= nil then
      self:RemoveItem(BangPaiPaoShang.m_itemId)
      BangPaiPaoShang.m_itemId = nil
      BangPaiPaoShang.m_npciId = nil
    end
    if self.m_itemCnt <= 0 then
      self:CloseSelf()
    end
  elseif msgSID == MsgID_Mission_NpcView then
    self.btn_list:removeAllItems()
    self:LoadFunction()
  elseif msgSID == MsgID_DaYanTa_ExChangeTime or msgSID == MsgID_Activity_TiantingExpUpdate then
    if self.m_txt then
      self.m_txt:removeAllChildren()
    end
    self:TalkRubbish()
  elseif msgSID == MsgID_MapScene_ChangedMap then
    self:CloseSelf()
  end
end
function CNpcNormal:RemoveItem(item)
  if item == 1 then
    self.item_1:removeSelf()
    self.m_itemCnt = self.m_itemCnt - 1
    self.item_1 = nil
  elseif item == 2 then
    self.item_2:removeSelf()
    self.m_itemCnt = self.m_itemCnt - 1
    self.item_2 = nil
  elseif item == 3 then
    self.item_3:removeSelf()
    self.m_itemCnt = self.m_itemCnt - 1
    self.item_3 = nil
  end
end
function CNpcNormal:OnBtn_Close(obj, t)
  self:CloseSelf()
end
function CNpcNormal:Clear()
  self.m_txt = nil
  CNpcNormal.super.Clear(self)
end

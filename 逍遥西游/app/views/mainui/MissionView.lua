CMissionView = class("CMissionView", CcsSubView)
function CMissionView:ctor()
  CMissionView.super.ctor(self, "views/mission_view.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_curMission = {
      listener = handler(self, self.OnBtn_ShowCurMission),
      variName = "btn_curMission"
    },
    btn_canAcceptMission = {
      listener = handler(self, self.OnBtn_ShowCanAcceptMission),
      variName = "btn_canAcceptMission"
    },
    btn_toAcceptMission = {
      listener = handler(self, self.OnBtn_ToAcceptMission),
      variName = "btn_toAcceptMission"
    },
    btn_giveUpMission = {
      listener = handler(self, self.OnBtn_GiveUpMission),
      variName = "btn_giveUpMission"
    },
    btn_traceMission = {
      listener = handler(self, self.OnBtn_TraceMission),
      variName = "btn_traceMission"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:addBtnSigleSelectGroup({
    {
      self.btn_curMission,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_canAcceptMission,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    }
  })
  self.btn_curMission:setTitleText("当\n前\n任\n务")
  self.btn_canAcceptMission:setTitleText("可\n接\n任\n务")
  self.layer_pos_title = self:getNode("layer_pos_title")
  self.layer_pos_award = self:getNode("layer_pos_award")
  self.list_cur = self:getNode("list_cur")
  self.list_accept = self:getNode("list_accept")
  self.pic_rightBg = self:getNode("pic_rightBg")
  self.pic_bg = self:getNode("pic_bg")
  self.pic_title_bg1 = self:getNode("pic_title_bg1")
  self.pic_title_bg2 = self:getNode("pic_title_bg2")
  self.title_p1 = self:getNode("title_p1")
  self.title_p2 = self:getNode("title_p2")
  self.layer_pos_title:setEnabled(false)
  self.layer_pos_award:setEnabled(false)
  self.m_CurShowType = nil
  self.m_CurShowMissionId = nil
  self.m_CurShowMissionItem = nil
  self.m_CurChoosedMissionId = nil
  self.m_NeedUpgradeItem = nil
  local rBgX, rBgy = self.pic_rightBg:getPosition()
  local titleX, titleY = self.layer_pos_title:getPosition()
  local s = self.pic_rightBg:getSize()
  local txtW = rBgX + s.width / 2 - titleX - 30
  self.m_MissionTitleTxt = CRichText.new({
    width = txtW,
    verticalSpace = 0,
    font = KANG_TTF_FONT,
    fontSize = 25,
    color = ccc3(58, 34, 5)
  })
  self.pic_bg:addChild(self.m_MissionTitleTxt, 20)
  self.m_MissionTitleTxt:setPosition(ccp(titleX, titleY))
  self.m_MissionDstTxt = CRichText.new({
    width = txtW,
    verticalSpace = 0,
    font = KANG_TTF_FONT,
    fontSize = 20,
    color = ccc3(217, 120, 10)
  })
  self.pic_bg:addChild(self.m_MissionDstTxt, 20)
  local titleBgX, titleBgY = self.pic_title_bg1:getPosition()
  local titleBgSize = self.pic_title_bg1:getSize()
  self.m_MissionDstTxt_PosBase = {
    titleX,
    titleBgY - titleBgSize.height / 2 - 1
  }
  self.m_MissionDstTxt:setPosition(ccp(titleX, self.m_MissionDstTxt_PosBase[2]))
  self.m_MissionDesTxt = CRichText.new({
    width = txtW,
    verticalSpace = 0,
    font = KANG_TTF_FONT,
    fontSize = 20,
    color = ccc3(255, 255, 255)
  })
  self.pic_bg:addChild(self.m_MissionDesTxt, 20)
  local awardTitleX, awardTitleY = self.layer_pos_award:getPosition()
  self.m_MissionAwardTitleTxt = CRichText.new({
    width = txtW,
    verticalSpace = 0,
    font = KANG_TTF_FONT,
    fontSize = 25,
    color = ccc3(58, 34, 5)
  })
  self.pic_bg:addChild(self.m_MissionAwardTitleTxt, 20)
  self.m_MissionAwardTitleTxt:setPosition(ccp(awardTitleX, awardTitleY))
  self.m_MissionAwardTitleTxt:addRichText("[任务奖励]")
  self.m_AwardItems = {}
  local titleBg1X, titleBg1Y = self.pic_title_bg2:getPosition()
  local titleBg1Size = self.pic_title_bg2:getSize()
  self.m_AwardItems_BasePos = {
    titleX,
    titleBg1Y - titleBg1Size.height / 2 - 1
  }
  self:setShowMissionInfo(nil)
  self.list_cur:addTouchItemListenerListView(handler(self, self.ChooseItem_CurMission), handler(self, self.ListEventListener))
  self.list_accept:addTouchItemListenerListView(handler(self, self.ChooseItem_AcceptMission), handler(self, self.ListEventListener))
  self:InitMissionData()
  self:LoadMissionListTitle(self.list_cur, self.m_CurMission)
  self:LoadMissionListTitle(self.list_accept, self.m_canAcceptMission)
  self:SwitchMissionType(1)
  self:ListenMessage(MsgID_Mission)
end
function CMissionView:InitMissionData()
  self.m_CurMission = {}
  self.m_CurMission.cur = {-1, -1}
  local missionData = {}
  self.m_CurMission.data = missionData
  self.m_MissionTypeGroup = {
    [MissionKind_Main] = MissionKind_Main,
    [MissionKind_Branch] = MissionKind_Branch,
    [MissionKind_Shilian] = MissionKind_Branch,
    [MissionKind_Jingying] = MissionKind_Branch
  }
  for i, k in ipairs(Mission_Recommend_Kinds) do
    self.m_MissionTypeGroup[k] = Mission_Recommend
  end
  local adviceMission = {}
  missionData[1] = adviceMission
  adviceMission.type = Mission_Recommend
  adviceMission.title = {
    "推荐任务",
    nil
  }
  adviceMission.missionId = {}
  local mainMission = {}
  missionData[2] = mainMission
  mainMission.type = MissionKind_Main
  mainMission.title = {
    "主线任务",
    nil
  }
  local missionIdData_Main = {}
  mainMission.missionId = missionIdData_Main
  local branchMission = {}
  missionData[3] = branchMission
  branchMission.type = MissionKind_Branch
  branchMission.title = {
    "支线任务",
    nil
  }
  local missionIdData_Branch = {}
  branchMission.missionId = missionIdData_Branch
  local missionDataTable = {
    [MissionKind_Main] = missionIdData_Main,
    [MissionKind_Branch] = missionIdData_Branch,
    [MissionKind_Jingying] = missionIdData_Branch,
    [MissionKind_Shilian] = missionIdData_Branch,
    [MissionKind_Activity] = adviceMission.missionId,
    [MissionKind_Shimen] = adviceMission.missionId,
    [MissionKind_Guide] = adviceMission.missionId,
    [MissionKind_SanJieLiLian] = adviceMission.missionId,
    [MissionKind_Faction] = adviceMission.missionId,
    [MissionKind_Jiehun] = adviceMission.missionId,
    [MissionKind_Jieqi] = adviceMission.missionId
  }
  local ids = g_MissionMgr:getCanTraceMission() or {}
  for i, mId in ipairs(ids) do
    local missionPro = g_MissionMgr:getMissionProgress(mId)
    local dataTable, missionKind = g_MissionMgr:getMissionData(mId)
    local dst = g_MissionMgr:getDstData(dataTable, missionPro)
    local missionIdData = missionDataTable[missionKind]
    missionIdData[#missionIdData + 1] = {
      mId,
      missionPro,
      dataTable,
      dst
    }
  end
  self.m_canAcceptMission = {}
  self.m_canAcceptMission.cur = {-1, -1}
  self.m_canAcceptMission.data = {}
  local adviceMission = {}
  self.m_canAcceptMission.data[1] = adviceMission
  adviceMission.type = Mission_Recommend
  adviceMission.title = {
    "推荐任务",
    nil
  }
  adviceMission.missionId = {}
  local branchMission = {}
  self.m_canAcceptMission.data[2] = branchMission
  branchMission.type = MissionKind_Branch
  branchMission.title = {
    "支线任务",
    nil
  }
  local missionIdData_Branch = {}
  branchMission.missionId = missionIdData_Branch
  self:ReflushAcceptData()
end
function CMissionView:ReflushAcceptData()
  local missionDataTable = {
    [MissionKind_Branch] = self.m_canAcceptMission.data[2].missionId,
    [MissionKind_Jingying] = self.m_canAcceptMission.data[2].missionId,
    [MissionKind_Shilian] = self.m_canAcceptMission.data[2].missionId,
    [MissionKind_Activity] = self.m_canAcceptMission.data[1].missionId,
    [MissionKind_Shimen] = self.m_canAcceptMission.data[1].missionId,
    [MissionKind_Guide] = self.m_canAcceptMission.data[1].missionId,
    [MissionKind_SanJieLiLian] = self.m_canAcceptMission.data[1].missionId,
    [MissionKind_Faction] = self.m_canAcceptMission.data[1].missionId
  }
  local hasBp = g_BpMgr:localPlayerHasBangPai()
  local ids = g_MissionMgr:getCanAcceptMission() or {}
  for i, mId in ipairs(ids) do
    if mId == Totem_MissionId then
    else
      local dataTable, missionKind = g_MissionMgr:getMissionData(mId)
      if not hasBp and missionKind == MissionKind_Faction then
      else
        print(mId, missionKind, dataTable)
        local missionIdData = missionDataTable[missionKind]
        local hasAdded = false
        for i, v in ipairs(missionIdData) do
          if v[1] == mId then
            hasAdded = true
            break
          end
        end
        if hasAdded == false then
          local missionPro = g_MissionMgr:getMissionProgress(mId)
          local dst = g_MissionMgr:getDstData(dataTable, missionPro)
          missionIdData[#missionIdData + 1] = {
            mId,
            missionPro,
            dataTable,
            dst
          }
        end
      end
    end
  end
end
function CMissionView:ChooseItem_CurMission(item, index, listObj)
  soundManager.playSound("xiyou/sound/clickbutton_1.wav")
  self:ChoosedItem(item, index, self.list_cur, self.m_CurMission)
end
function CMissionView:ChooseItem_AcceptMission(item, index, listObj)
  soundManager.playSound("xiyou/sound/clickbutton_1.wav")
  self:ChoosedItem(item, index, self.list_accept, self.m_canAcceptMission)
end
function CMissionView:ChoosedItem(item, index, listIns, missionData)
  local itemType, idxInData, extParam = item:getItemData()
  if itemType == 1 then
    local curShow = missionData.cur
    if curShow[1] == idxInData then
      self:CloseMissionType(idxInData, listIns, missionData)
    else
      self:ReLoadMissionType(idxInData, listIns, missionData)
    end
  elseif itemType == 2 then
    print("==>> 点击任务 ")
    local allMissions = missionData.data[extParam]
    if allMissions == nil then
      print("allMissions == nil")
      return
    end
    local mData = allMissions.missionId[idxInData]
    if mData == nil then
      print("mData == nil")
      return
    end
    local missionId, pro, dataTable, dstData, item1 = unpack(mData, 1, 5)
    self:setShowMissionInfo(missionId, pro, dataTable, dstData, item1)
  elseif itemType == 3 then
    print("== 点击提示")
    self:ShowNeedUpgradeInfo(item)
  end
end
function CMissionView:ShowNeedUpgradeInfo(item)
  if item == nil then
    item = self.m_NeedUpgradeItem
  end
  if item == nil then
    self:setMissionItemSelected(false)
    self:setMissionInfoShow(false)
    return
  end
  self:setMissionItemSelected(item)
  self.m_CurShowMissionId = nil
  self:setMissionInfoShow(true)
  self:setMissionTitle("[主线]提升等级")
  local dst = g_MissionMgr:getNeedUpgradeStr()
  self:setMissionDst(dst)
  self.m_MissionDesTxt:clearAll()
  self.m_MissionDesTxt:addRichText("主线暂且告一段落，阁下努力升级吧！")
  self.btn_toAcceptMission:setEnabled(false)
  self.btn_giveUpMission:setEnabled(false)
  self.btn_traceMission:setEnabled(false)
  self:ShowAwardObjs(nil)
end
function CMissionView:setMissionItemSelected(item)
  print("====>>>>> setMissionItemSelected:", tostring(self.m_CurShowMissionItem), tostring(item))
  if self.m_CurShowMissionItem == item then
    print("1111 ====>>>>> setMissionItemSelected")
    return false
  end
  if self.m_CurShowMissionItem then
    self.m_CurShowMissionItem:setItemChoosed(false)
  end
  if item then
    item:setItemChoosed(true)
  end
  self.m_CurShowMissionItem = item
end
function CMissionView:ListEventListener(item, index, listObj, status)
  if status == LISTVIEW_ONSELECTEDITEM_START then
    if item then
      item:setTouchStatus(true)
      self.m_TouchStartItem = item
    end
  elseif status == LISTVIEW_ONSELECTEDITEM_END then
    if self.m_TouchStartItem then
      self.m_TouchStartItem:setTouchStatus(false)
      self.m_TouchStartItem = nil
    end
    if item then
      item:setTouchStatus(false)
    end
  end
end
function CMissionView:LoadMissionListTitle(listIns, missionData)
  print("======>>> LoadMissionListTitle:", listIns, missionData)
  for i, data in ipairs(missionData.data) do
    local titleData = data.title
    if titleData and titleData and #titleData >= 1 then
      local item = MissionViewItem.new(titleData[1], 1, i)
      listIns:pushBackCustomItem(item)
      titleData[2] = item
    end
  end
end
function CMissionView:ReLoadMissionType(itemIdx, listIns, missionData)
  local curShow = missionData.cur
  print("==>> ReLoadMissionType:", curShow[1], itemIdx)
  if curShow[1] == itemIdx then
    return false
  end
  self:CloseMissionType(curShow[1], listIns, missionData)
  local newShowData = missionData.data[itemIdx]
  local tileItem = newShowData.title[2]
  local idx = listIns:getIndex(tileItem)
  print("==> 1 idx:", idx, tileItem)
  if newShowData and tileItem then
    local len = #newShowData.missionId
    if len > 0 then
      for i, childMissionData in ipairs(newShowData.missionId) do
        local mnName = childMissionData[3].mnName
        local missionKind = getMissionKind(childMissionData[1])
        if missionKind == MissionKind_Shimen then
          mnName = "师门任务"
        end
        local item = MissionViewItem.new(mnName, 2, i, itemIdx)
        idx = idx + 1
        print("==> idx:", idx)
        listIns:insertCustomItem(item, idx)
        childMissionData[5] = item
      end
    elseif newShowData.type == MissionKind_Main then
      local item = MissionViewItem.new("提升等级", 3, 0, itemIdx)
      idx = idx + 1
      listIns:insertCustomItem(item, idx)
      self.m_NeedUpgradeItem = item
    end
  end
  curShow[1] = itemIdx
  self:ReShowDefaultMission(itemIdx, listIns, missionData)
  listIns:ListViewScrollToIndex_Vertical(itemIdx, 0.3)
  return true
end
function CMissionView:CloseMissionType(itemIdx, listIns, missionData)
  self:setMissionItemSelected(nil)
  local oldShowData = missionData.data[itemIdx]
  if oldShowData then
    for i, missionData in ipairs(oldShowData.missionId) do
      local item = missionData[5]
      if item then
        if self.m_CurShowMissionItem == item then
          self.m_CurShowMissionItem = nil
        end
        local idx = listIns:getIndex(item)
        listIns:removeItem(idx)
        missionData[5] = nil
      end
    end
    if oldShowData.type == MissionKind_Main and self.m_NeedUpgradeItem then
      local idx = listIns:getIndex(self.m_NeedUpgradeItem)
      listIns:removeItem(idx)
      self.m_NeedUpgradeItem = nil
    end
  end
  local curShow = missionData.cur
  curShow[1] = -1
end
function CMissionView:setShowMissionInfo(missionId, pro, dataTable, dstData, item)
  print("==>>> missionId, pro, dataTable, dstData:", missionId, pro, dataTable, dstData, tostring(item))
  self:setMissionItemSelected(item)
  if missionId == nil then
    self:setMissionInfoShow(false)
    self:ShowAwardObjs(nil)
    self.m_CurShowMissionId = nil
  else
    if self.m_CurShowMissionId == missionId then
      return
    end
    self.m_CurShowMissionId = missionId
    self:setMissionInfoShow(true)
    local mnName = dataTable.mnName
    local missionKind = getMissionKind(missionId)
    if missionKind == MissionKind_Shimen then
      mnName = "师门任务"
    end
    local missionName = g_MissionMgr:convertMissionName(mnName, missionId, nil, true)
    self:setMissionTitle(missionName)
    if self.m_CurShowMissionId == Shimen.AcceptMissionId or self.m_CurShowMissionId == ZhuaGui_MissionId or self.m_CurShowMissionId == XiuLuo_MissionId then
      self:setMissionDst(nil)
    else
      local dstDes
      if pro == MissionPro_NotAccept then
        dstDes = dataTable.acceptDes
      else
        dstDes = dstData.des
      end
      if self.m_CurShowMissionId == Business_MissionId and BangPaiPaoShang.taskid ~= nil then
        dstDes = string.format("筹集帮派资金#<Y>(%d/%d)两#", BangPaiPaoShang.progress, BangPaiPaoShang.target)
      end
      if self.m_CurShowMissionId == DaTingCangBaoTu_MissionId then
        if CDaTingCangBaoTu.taskid ~= nil and CDaTingCangBaoTu.war_data_id ~= nil then
          local monsterName, mapName = CDaTingCangBaoTu.getMosterNameAndLoc()
          dstDes = string.format("战胜#<Y>%s#", monsterName)
        end
      elseif missionId == TBSJ_MissionId then
        dstDes = activity.tbsj:GetTBSJMissionViewTarget()
      end
      self:setMissionDst(dstDes)
    end
    if dataTable.missionDes ~= nil and dataTable.missionDes ~= "None" then
      local sdec = SanJieLiLian.MissionDec[missionId]
      if SanJieLiLian.isMissionId(missionId) and sdec ~= nil then
        self:setMissionDes(sdec)
      elseif missionId == DaTingCangBaoTu_MissionId then
        local monsterName, mapName = CDaTingCangBaoTu.getMosterNameAndLoc()
        local Dec = ""
        if CDaTingCangBaoTu.taskid == nil or monsterName == nil then
          Dec = data_Mission_Activity[DaTingCangBaoTu_MissionId].missionDes
        else
          Dec = string.format("听说#<Y>%s#在#<Y>%s#出现，少侠不妨前去探查一番", monsterName, mapName)
        end
        self:setMissionDes(Dec)
      else
        self:setMissionDes(dataTable.missionDes)
      end
    else
      self:setMissionDes("")
    end
    if missionId == TBSJ_MissionId then
      local Dec = activity.tbsj:GetTBSJMissionViewDes()
      self:setMissionDes(Dec)
    end
    local missionKind = getMissionKind(missionId)
    if self.m_CurShowType == 1 and missionKind ~= MissionKind_Shimen and dataTable.startNpc == 0 and self.m_CurShowMissionId ~= Totem_MissionId then
      self.btn_giveUpMission:setEnabled(false)
    end
    if missionId == TBSJ_MissionId then
      self.btn_giveUpMission:setEnabled(false)
    end
    if SanJieLiLian.isMissionId(missionId) then
      self.btn_giveUpMission:setEnabled(not SanJieLiLian.getcircleState())
    end
    if missionKind == MissionKind_Jiehun or missionKind == MissionKind_Jieqi then
      self.btn_giveUpMission:setEnabled(true)
    end
    local awardData
    if self.m_CurShowMissionId == ZhuaGui_MissionId then
      if g_LocalPlayer._zg_taskId ~= 0 then
        local lv = g_LocalPlayer._zg_monsterLv
        local c = ZhuaGui.getCircel()
        local awardPer = 0.1
        local exp = data_TaskExpCatchGhost[lv] or {}
        exp = exp.BaseExp or 0
        exp = math.floor(exp / 7)
        print("exp==>:", lv, c, exp)
        awardData = {
          {RESTYPE_EXP, exp}
        }
      end
    elseif self.m_CurShowMissionId == GuiWang_MissionId then
      if g_LocalPlayer._gw_taskId ~= 0 then
        local lv = g_LocalPlayer._gw_monsterLv
        local c = GuiWang.getCircel()
        local awardPer = 0.1
        local exp = data_TaskExpGhostKing[lv] or {}
        exp = exp.BaseExp or 0
        exp = math.floor(exp / GuiWang_MaxCircle)
        awardData = {
          {RESTYPE_EXP}
        }
      end
    elseif self.m_CurShowMissionId == XiuLuo_MissionId then
      if g_LocalPlayer._xl_taskId ~= 0 then
        local lv = g_LocalPlayer._xl_monsterLv
        local c = XiuLuo.getCircel() or 1
        local awardPer = 0.1
        local exp = data_TaskExpXiuLuo[lv] or {}
        exp = exp.BaseExp or 0
        exp = math.floor(exp / XiuLuo_MaxCircle)
        print("exp==>:", lv, c, exp)
        awardData = {
          {RESTYPE_EXP, exp}
        }
      end
    else
      if g_MissionMgr:isDayantaExchangeMissionId(missionId) then
        activity.dayanta:flushDayantaExchangeExp(missionId)
      end
      awardData = g_MissionMgr:packAwardData(dataTable)
    end
    self:ShowAwardObjs(awardData)
  end
end
function CMissionView:setMissionInfoShow(isShow)
  print("==>> setMissionInfoShow:", isShow)
  self.pic_title_bg1:setEnabled(isShow)
  self.pic_title_bg2:setEnabled(isShow)
  self.m_MissionTitleTxt:setEnabled(isShow)
  self.m_MissionDstTxt:setEnabled(isShow)
  self.m_MissionDesTxt:setEnabled(isShow)
  self.m_MissionAwardTitleTxt:setEnabled(isShow)
  if self.m_CurShowType == 1 then
    self.btn_toAcceptMission:setEnabled(false)
    self.btn_giveUpMission:setEnabled(isShow)
    self.btn_traceMission:setEnabled(isShow)
    if isShow and self.m_CurShowMissionId then
      local missionKind = getMissionKind(self.m_CurShowMissionId)
      print("==>>missionKind:", missionKind)
      if missionKind == nil or missionKind == MissionKind_Main then
        self.btn_giveUpMission:setEnabled(false)
      end
    end
  else
    self.btn_toAcceptMission:setEnabled(isShow)
    self.btn_giveUpMission:setEnabled(false)
    self.btn_traceMission:setEnabled(false)
  end
end
function CMissionView:setMissionTitle(title)
  self.m_MissionTitleTxt:clearAll()
  self.m_MissionTitleTxt:addRichText(title)
end
function CMissionView:setMissionDst(dst)
  print("CMissionView:setMissionDst:", dst)
  if dst ~= nil and string.len(dst) > 0 and dst ~= "None" then
    self.m_MissionDstTxt:setEnabled(true)
    self.m_MissionDstTxt:clearAll()
    self.m_MissionDstTxt:addRichText("目标:" .. dst)
    local s = self.m_MissionDstTxt:getRichTextSize()
    self.m_MissionDstTxt:setPosition(ccp(self.m_MissionDstTxt_PosBase[1], self.m_MissionDstTxt_PosBase[2] - s.height))
  else
    self.m_MissionDstTxt:setEnabled(false)
    print("==>>self.m_MissionDstTxt:setEnabled:false")
  end
end
function CMissionView:setMissionDes(des)
  self.m_MissionDesTxt:clearAll()
  self.m_MissionDesTxt:addRichText(des)
  local s = self.m_MissionDesTxt:getRichTextSize()
  local dstX, dstY = self.m_MissionDstTxt:getPosition()
  self.m_MissionDesTxt:setPosition(ccp(dstX, dstY - s.height))
end
function CMissionView:ShowAwardObjs(awardData)
  if #self.m_AwardItems > 0 then
    for i, item in ipairs(self.m_AwardItems) do
      item:removeSelf()
    end
    self.m_AwardItems = {}
  end
  if awardData and #awardData > 0 then
    local curX, curY = self.m_AwardItems_BasePos[1], self.m_AwardItems_BasePos[2]
    local idx = 1
    for i, awardDataItem in ipairs(awardData) do
      local t = awardDataItem[1]
      local num = awardDataItem[2]
      local item
      if awardDataItem[3] ~= true and num ~= nil then
        if t == RESTYPE_GOLD then
          item = createClickResItem({
            resID = RESTYPE_GOLD,
            num = num,
            autoSize = nil,
            clickListener = nil,
            clickDel = nil,
            noBgFlag = nil,
            LongPressTime = nil,
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
            LongPressTime = nil,
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
            LongPressTime = nil,
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
            LongPressTime = nil,
            LongPressListener = nil,
            LongPressEndListner = nil
          })
        else
          local objId, num
          for k, v in pairs(awardDataItem) do
            objId = k
            num = v
            break
          end
          if objId and num then
            item = createClickItem({
              itemID = objId,
              autoSize = nil,
              num = num,
              LongPressTime = nil,
              clickListener = nil,
              LongPressListener = nil,
              LongPressEndListner = nil,
              clickDel = nil,
              noBgFlag = nil
            })
          end
        end
      end
      if item then
        self.pic_bg:addChild(item)
        self.m_AwardItems[idx] = item
        idx = idx + 1
        local size = item:getSize()
        item:setPosition(ccp(curX, curY - size.height))
        if idx % 5 == 0 then
          curY = curY - size.height - 5
          curX = self.m_AwardItems_BasePos[1]
        else
          curX = curX + size.width + 20
        end
      end
    end
  end
end
function CMissionView:SwitchMissionType(t)
  if self.m_CurShowType == t then
    return
  end
  self:setMissionItemSelected(nil)
  if t == 2 then
    self.title_p1:setText("可接")
    self.title_p2:setText("任务")
  else
    self.title_p1:setText("当前")
    self.title_p2:setText("任务")
  end
  self.m_CurShowType = t
  local isShowCur = t == 1
  self.list_cur:setEnabled(isShowCur)
  self.list_accept:setEnabled(not isShowCur)
  if t == 1 then
    self:CloseMissionType(self.m_canAcceptMission.cur[1], self.list_accept, self.m_canAcceptMission)
    self:ReShowDefaultMissionType(self.list_cur, self.m_CurMission, true)
  else
    self:CloseMissionType(self.m_CurMission.cur[1], self.list_cur, self.m_CurMission)
    self:ReShowDefaultMissionType(self.list_accept, self.m_canAcceptMission, true)
  end
end
function CMissionView:ReShowDefaultMissionType(listIns, missionData, isClearCurShow)
  print("===>> ReShowDefaultMissionType:", listIns, missionData, isClearCurShow)
  if isClearCurShow then
    self:setShowMissionInfo(nil)
  end
  local curShow = missionData.cur
  local itemIdx = curShow[1]
  if itemIdx == nil or itemIdx == -1 then
    if self.m_CurShowType == 1 then
      itemIdx = 1
    else
      itemIdx = 1
    end
  end
  local data = missionData.data or {}
  local l = #data
  print("=>itemIdx:", itemIdx)
  while true do
    if data[itemIdx + 1] == nil then
      print("=+>data[itemIdx + 1] ")
      break
    end
    local ids = data[itemIdx].missionId
    if ids == nil or #ids > 0 then
      break
    end
    itemIdx = itemIdx + 1
  end
  if false ~= self:ReLoadMissionType(itemIdx, listIns, missionData) then
    self:ReShowDefaultMission(itemIdx, listIns, missionData)
  end
end
function CMissionView:ReShowDefaultMission(itemIdx, listIns, missionData)
  local allMissions = missionData.data[itemIdx]
  if allMissions == nil then
    print("allMissions == nil")
    return
  end
  local mData = allMissions.missionId[1]
  if mData == nil then
    print("任务列表为空:", allMissions.type, MissionKind_Main)
    print("===>> self.m_NeedUpgradeItem:", self.m_NeedUpgradeItem)
    if allMissions.type == MissionKind_Main and self.m_NeedUpgradeItem then
      self:ShowNeedUpgradeInfo(self.m_NeedUpgradeItem)
    end
    return
  end
  local missionId, pro, dataTable, dstData, item = unpack(mData, 1, 5)
  self:setShowMissionInfo(missionId, pro, dataTable, dstData, item)
end
function CMissionView:OnBtn_ShowCurMission(btnObj, touchType)
  print(" -->>> OnBtn_ShowCurMission ")
  self:SwitchMissionType(1)
end
function CMissionView:OnBtn_ShowCanAcceptMission(btnObj, touchType)
  print(" -->>> OnBtn_ShowCanAcceptMission ")
  self:SwitchMissionType(2)
end
function CMissionView:DelMission(missionId)
  local missionKind = getMissionKind(missionId)
  local curKindIdx = 1
  for idx, allMissionData in pairs(self.m_CurMission.data) do
    print("==>> ", allMissionData.type, missionKind)
    if allMissionData.type == self.m_MissionTypeGroup[missionKind] then
      print("\t--->>==")
      for i, missionData in ipairs(allMissionData.missionId) do
        print("\t\t-->>", missionData[1], missionId)
        if missionData[1] == missionId then
          local item = missionData[5]
          if item then
            if self.m_CurShowMissionItem == item then
              self:setMissionItemSelected(nil)
            end
            self.list_cur:removeItem(self.list_cur:getIndex(item))
          end
          print("-->> Del")
          table.remove(allMissionData.missionId, i)
          break
        end
      end
      curKindIdx = idx
      break
    end
  end
  self:setShowMissionInfo(nil)
  self:ReShowDefaultMission(curKindIdx, self.list_cur, self.m_CurMission)
  self:ReflushAcceptData()
end
function CMissionView:Clear()
  self.m_CurMission = {}
  self.m_canAcceptMission = {}
  self.m_CurShowMissionItem = nil
  self.m_NeedUpgradeItem = nil
end
function CMissionView:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_Mission_MissionDel then
    local missionId = arg[1]
    if missionId then
      print("==>> 任务被删除成功:", missionId)
      self:DelMission(missionId)
    end
  elseif msgSID == MsgID_Mission_Common and arg[1] ~= nil then
    self:ReflushAcceptData()
  end
end
function CMissionView:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function CMissionView:OnBtn_ToAcceptMission(btnObj, touchType)
  print(" -->>> OnBtn_ToAcceptMission ")
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  if g_WarScene and g_WarScene:getIsWatching() then
    ShowNotifyTips("观战中，不能前往")
    return
  end
  if g_WarScene and g_WarScene:getIsReview() then
    ShowNotifyTips("回放中，不能前往")
    return
  end
  if JudgeIsInWar() then
    ShowNotifyTips("战斗中，不能前往")
    return
  end
  if self.m_CurShowMissionId then
    self:CloseSelf()
    g_MissionMgr:TraceMission(self.m_CurShowMissionId)
  end
end
function CMissionView:OnBtn_GiveUpMission(btnObj, touchType)
  print(" -->>> OnBtn_GiveUpMission ")
  if self.m_CurShowMissionId == nil then
    return
  end
  function nomalCommimt(callback)
    local dlg = CPopWarning.new({
      title = "提示",
      text = "你确定要放弃任务吗？",
      align = CRichText_AlignType_Center,
      confirmFunc = function()
        if callback ~= nil then
          callback()
        end
      end,
      cancelText = "取消",
      confirmText = "确定"
    })
    dlg:ShowCloseBtn(false)
  end
  print("点击了  放弃按钮    ", self.m_CurShowMissionId)
  local missionKind = getMissionKind(self.m_CurShowMissionId)
  if missionKind == MissionKind_Shimen then
    local dlg = CPopWarning.new({
      title = "提示",
      text = "放弃本次师门任务后需要等待5分钟才能重新领取，你确定要放弃任务吗？",
      align = CRichText_AlignType_Left,
      confirmFunc = function()
        Shimen.reqGiveup()
      end,
      cancelText = "取消",
      confirmText = "确定"
    })
    dlg:ShowCloseBtn(false)
  elseif g_MissionMgr:isTiantingMissionId(self.m_CurShowMissionId) then
    nomalCommimt(function()
      activity.tianting:touchExitButton()
      self:CloseSelf()
    end)
  elseif SanJieLiLian.isMissionId(self.m_CurShowMissionId) then
    local dlg = CPopWarning.new({
      title = "提示",
      text = "你确定要放弃任务么？放弃任务后，本周内再次开启三界历练任务需要消耗5000#<IR7>#。",
      align = CRichText_AlignType_Left,
      confirmFunc = function()
        SanJieLiLian.reqGiveup()
      end,
      cancelText = "取消",
      confirmText = "确定"
    })
    dlg:ShowCloseBtn(false)
  elseif missionKind == MissionKind_Faction then
    if self.m_CurShowMissionId == Business_MissionId then
      local dlg = CPopWarning.new({
        title = "提示",
        text = "放弃本次跑商任务将不返还押金100#<IR7>#,你确定要放弃任务么？",
        align = CRichText_AlignType_Left,
        confirmFunc = function()
          BangPaiPaoShang.reqGiveup()
        end,
        cancelText = "取消",
        confirmText = "确定"
      })
      dlg:ShowCloseBtn(false)
    elseif self.m_CurShowMissionId == BangPaiChuMo_MissionId then
      nomalCommimt(function()
        BangPaiChuMo.reqGaveUp()
      end)
    elseif self.m_CurShowMissionId == BangPaiAnZhan_MissionId then
      print("放弃了 帮派暗战任务 ********  self.m_CurShowMissionId")
      nomalCommimt(function()
        BangPaiAnZhan.reqGaveUp()
      end)
    elseif self.m_CurShowMissionId == Totem_MissionId then
      nomalCommimt(function()
        BangPaiTotem.giveTotemTask()
      end)
    end
  elseif missionKind == MissionKind_Activity and self.m_CurShowMissionId == DaTingCangBaoTu_MissionId then
    nomalCommimt(function()
      CDaTingCangBaoTu.reqGiveup()
    end)
  elseif missionKind == MissionKind_Jiehun then
    if g_HunyinMgr then
      g_HunyinMgr:showGiveupWarningView()
    end
  elseif missionKind == MissionKind_Jieqi then
    if g_JieqiMgr then
      g_JieqiMgr:showGiveupWarningView()
    end
  elseif self.m_CurShowMissionId == ZhuaGui_MissionId then
    nomalCommimt(function()
      ZhuaGui.GiveUpMission()
    end)
  elseif self.m_CurShowMissionId == GuiWang_MissionId then
    nomalCommimt(function()
      GuiWang.GiveUpMission()
    end)
  elseif self.m_CurShowMissionId == ExchangeMissionId then
    nomalCommimt(function()
      activity.dayanta:reqGiveUp()
    end)
  elseif self.m_CurShowMissionId == XiuLuo_MissionId then
    nomalCommimt(function()
      XiuLuo.GiveUpMission()
    end)
  else
    local missionKind = getMissionKind(self.m_CurShowMissionId)
    print("==>>missionKind:", missionKind)
    if missionKind == nil or missionKind == MissionKind_Main then
      return
    end
    nomalCommimt(function()
      netsend.netmission.reqGiveup(self.m_CurShowMissionId)
    end)
  end
  self:CloseMissionType(1, self.list_cur, self.m_CurMission)
end
function CMissionView:OnBtn_TraceMission(btnObj, touchType)
  print(" -->>> OnBtn_TraceMission ")
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  if g_WarScene and g_WarScene:getIsWatching() then
    ShowNotifyTips("观战中，不能传送")
    return
  end
  if g_WarScene and g_WarScene:getIsReview() then
    ShowNotifyTips("回放中，不能传送")
    return
  end
  if JudgeIsInWar() then
    ShowNotifyTips("战斗中，不能传送")
    return
  end
  if self.m_CurShowMissionId then
    self:CloseSelf()
    g_MissionMgr:TraceMission(self.m_CurShowMissionId)
  end
end

BP_PLACE_LEADER = 1
BP_PLACE_FULEADER = 2
BP_PLACE_XUETU = 9
local BpMgr = class(".BpMgr", nil)
function BpMgr:ctor()
  self.m_LocalBpId = 0
  self.m_BpWarJoinTip = 0
  self.m_BpMemerSortType = {0, false}
  self:resetBpData()
  self.m_OtherPlayerBangPaiName = {}
end
function BpMgr:_cdTimeControl(attr, cdTime)
  local currTime = cc.net.SocketTCP.getTime()
  local lastTime = self[string.format("_lasttime_%s", attr)]
  if lastTime ~= nil and cdTime > currTime - lastTime then
    return false
  end
  self[string.format("_lasttime_%s", attr)] = currTime
  return true
end
function BpMgr:_cdTimeTableControl(attr, key, cdTime)
  local currTime = cc.net.SocketTCP.getTime()
  local tb = self[string.format("_lasttime_%s", attr)]
  if tb == nil then
    tb = {}
    self[string.format("_lasttime_%s", attr)] = tb
  end
  local lastTime = tb[key]
  if lastTime ~= nil and cdTime > currTime - lastTime then
    return false
  end
  tb[key] = currTime
  return true
end
function BpMgr:resetBpData()
  self.m_LocalBpName = ""
  self.m_LocalBpPlace = 0
  self.m_LocalBpBanSpeak = 0
  self.m_LocalBpOffer = 0
  self.m_LocalBpConstruct = 0
  self.m_LocalBpTotalConstruct = 0
  self.m_MainTotem = nil
  self.m_FuTotem = nil
  self.m_BpLevel = 1
  self.m_BpMoney = 0
  self.m_PaoShangTimes = 0
  self.m_ToTemInfo = nil
  self.m_PvpRank = 0
  self.m_AchFlag = 1
  self.m_BpMemberList = {}
  self.m_BpMemberExist = {}
  self.m_NewBpJoinRequest = false
  self.m_HasBpListCache = false
end
function BpMgr:localPlayerHasBangPai()
  return self.m_LocalBpId ~= 0
end
function BpMgr:getLocalPlayerBpId()
  return self.m_LocalBpId
end
function BpMgr:getLocalBpPlace()
  return self.m_LocalBpPlace
end
function BpMgr:getLocalPlayerIsLeader()
  return self.m_LocalBpPlace == BP_PLACE_LEADER
end
function BpMgr:getLocalBpName()
  return self.m_LocalBpName
end
function BpMgr:getLocalPlayerOffer()
  return self.m_LocalBpOffer
end
function BpMgr:getMainTotem()
  return self.m_MainTotem
end
function BpMgr:getFuTotem()
  return self.m_FuTotem
end
function BpMgr:getTotemKang(totemId)
  if totemId == self.m_MainTotem then
    return CalculateMainTotemKang(totemId, self.m_LocalBpOffer)
  elseif totemId == self.m_FuTotem then
    return CalculateFuTotemKang(totemId, self.m_LocalBpOffer)
  else
    return BangPaiTotem_2_Kang_New[totemId], 0
  end
end
function BpMgr:getBpLevel()
  return self.m_BpLevel
end
function BpMgr:getBpMoney()
  return self.m_BpMoney
end
function BpMgr:getPaoShangTimes()
  return self.m_PaoShangTimes
end
function BpMgr:getToTemInfo()
  return self.m_ToTemInfo
end
function BpMgr:getLocalBpConstruct()
  return self.m_LocalBpConstruct
end
function BpMgr:getLocalBpTotalConstruct()
  return self.m_LocalBpTotalConstruct
end
function BpMgr:getPvpRank()
  return self.m_PvpRank
end
function BpMgr:getAchFlag()
  return self.m_AchFlag
end
function BpMgr:getBpMemberList()
  return self.m_BpMemberList
end
function BpMgr:getNewBpJoinRequest()
  return self.m_NewBpJoinRequest
end
function BpMgr:getHasBpListCache()
  return self.m_HasBpListCache
end
function BpMgr:getBpNewTip()
  return self.m_NewBpJoinRequest or self.m_BpWarJoinTip == 1
end
function BpMgr:getBpNewBpWarTip()
  return self.m_BpWarJoinTip == 1
end
function BpMgr:SetLocalBpInfo(info)
  local bpId = info.i_bpid
  if bpId == nil then
    return
  end
  if bpId == 0 then
    self.m_LocalBpId = bpId
    self:resetBpData()
    local mainHero = g_LocalPlayer:getMainHero()
    if mainHero then
      mainHero:setProperty(PROPERTY_BPID, 0)
      mainHero:setProperty(PROPERTY_BPNAME, "")
      mainHero:setProperty(PROPERTY_BPJOB, 0)
      mainHero:CalculateProperty()
    end
    if info.i_leftoffer ~= nil then
      g_LocalPlayer:setBpConstruct(info.i_leftoffer)
    end
    if info.i_achievepoint ~= nil then
      g_LocalPlayer:setArch(info.i_achievepoint)
    end
    SendMessage(MsgID_BP_LocalInfo, info)
    SendMessage(MsgID_LocalBpAndJob, g_LocalPlayer:getPlayerId(), self.m_LocalBpName, self.m_LocalBpPlace)
    BangPaiRenWuLing.clearAllTask()
  else
    if self.m_LocalBpId ~= 0 and self.m_LocalBpId ~= bpId then
      print("--->>本地缓存旧数据错误", self.m_LocalBpId, bpId)
      self:resetBpData()
      SendMessage(MsgID_BP_OldInfoIsInvalid)
    end
    self.m_LocalBpId = bpId
    local mainHero = g_LocalPlayer:getMainHero()
    local needCalculateKang = false
    if mainHero then
      mainHero:setProperty(PROPERTY_BPID, bpId)
    end
    if info.s_bpname ~= nil then
      self.m_LocalBpName = info.s_bpname
      if mainHero then
        mainHero:setProperty(PROPERTY_BPNAME, info.s_bpname)
      end
    end
    if info.i_place ~= nil then
      self.m_LocalBpPlace = info.i_place
      if mainHero then
        mainHero:setProperty(PROPERTY_BPJOB, info.i_place)
      end
    end
    if info.i_banspeak ~= nil then
      self.m_LocalBpBanSpeak = info.i_banspeak
    end
    if info.i_offer ~= nil then
      self.m_LocalBpOffer = info.i_offer
      needCalculateKang = true
    end
    if info.i_leftoffer ~= nil then
      g_LocalPlayer:setBpConstruct(info.i_leftoffer)
    end
    if info.i_achievepoint ~= nil then
      g_LocalPlayer:setArch(info.i_achievepoint)
    end
    if info.c ~= nil then
      self.m_LocalBpConstruct = info.c
    end
    if info.tc ~= nil then
      self.m_LocalBpTotalConstruct = info.tc
    end
    if info.i_maintotem ~= nil then
      self.m_MainTotem = info.i_maintotem
      needCalculateKang = true
    end
    if info.i_futotem ~= nil then
      self.m_FuTotem = info.i_futotem
      needCalculateKang = true
    end
    if info.i_achflag ~= nil then
      self.m_AchFlag = info.i_achflag
    end
    if needCalculateKang and mainHero then
      mainHero:CalculateProperty()
    end
    SendMessage(MsgID_BP_LocalInfo, info)
    SendMessage(MsgID_LocalBpAndJob, g_LocalPlayer:getPlayerId(), self.m_LocalBpName, self.m_LocalBpPlace)
  end
end
function BpMgr:SetBpList(bpList)
  SendMessage(MsgID_BP_BpList, bpList)
end
function BpMgr:SetBpTenet(bpId, tenet)
  SendMessage(MsgID_BP_Tenet, bpId, tenet)
end
function BpMgr:SetBpAmount(bpNum)
  SendMessage(MsgID_BP_Num, bpNum)
end
function BpMgr:SetBpDetail(info)
  if info.i_bplevel ~= nil then
    self.m_BpLevel = info.i_bplevel
  end
  if info.i_money ~= nil then
    self.m_BpMoney = info.i_money
  end
  if info.i_pvp ~= nil then
    self.m_PvpRank = info.i_pvp
  end
  SendMessage(MsgID_BP_Detail, info)
end
function BpMgr:SetBpMemberList(infoList, flag)
  if flag == 1 then
    self.m_BpMemberExist = {}
    self.m_BpMemberList = {}
    SendMessage(MsgID_BP_ClearMemberList)
  end
  local localPlayerId = g_LocalPlayer:getPlayerId()
  for _, pInfo in pairs(infoList) do
    if self.m_BpMemberExist[pInfo.pid] == nil then
      self.m_BpMemberExist[pInfo.pid] = true
      self.m_BpMemberList[#self.m_BpMemberList + 1] = pInfo
      if pInfo.jid ~= nil and pInfo.pid ~= localPlayerId then
        local mapViewIns = g_MapMgr:getMapViewIns()
        if mapViewIns then
          mapViewIns:PlayerChangBpName(pInfo.pid, self.m_LocalBpName, pInfo.jid)
        end
      end
    else
      print("====>>>帮派成员信息收到重复数据111")
    end
  end
  if flag == 2 then
    table.sort(self.m_BpMemberList, handler(self, self._BpMemberSortFunc))
    SendMessage(MsgID_BP_MemberList)
    self.m_HasBpListCache = true
  end
end
function BpMgr:setBpMemerSortType(sortType, reverseFlag)
  local needSort = false
  if self.m_BpMemerSortType[1] ~= sortType or self.m_BpMemerSortType[2] ~= reverseFlag then
    needSort = true
  end
  self.m_BpMemerSortType = {sortType, reverseFlag}
  if needSort then
    table.sort(self.m_BpMemberList, handler(self, self._BpMemberSortFunc))
  end
end
function BpMgr:getBpMemberSortType()
  return unpack(self.m_BpMemerSortType, 1, 2)
end
function BpMgr:_BpMemberSortFunc(dataA, dataB)
  if dataA == nil or dataB == nil then
    return false
  end
  local placeA = dataA.jid
  local placeB = dataB.jid
  local zsA = dataA.zs
  local zsB = dataB.zs
  local lvA = dataA.lv
  local lvB = dataB.lv
  local statusA = dataA.st
  local statusB = dataB.st
  local sortType, reverseFlag = unpack(self.m_BpMemerSortType, 1, 2)
  if sortType == 1 then
    if placeA ~= placeB then
      if reverseFlag then
        return placeA > placeB
      else
        return placeA < placeB
      end
    end
  elseif sortType == 2 then
    if zsA ~= zsB then
      if reverseFlag then
        return zsA < zsB
      else
        return zsA > zsB
      end
    elseif lvA ~= lvB then
      if reverseFlag then
        return lvA < lvB
      else
        return lvA > lvB
      end
    end
  elseif sortType == 3 then
    local pvpA = dataA.tc
    local pvpB = dataB.tc
    if pvpA ~= pvpB then
      if reverseFlag then
        return pvpA > pvpB
      else
        return pvpA < pvpB
      end
    end
  elseif statusA < 0 and statusB >= 0 then
    return not reverseFlag
  elseif statusA >= 0 and statusB < 0 then
    return reverseFlag
  elseif statusA >= 0 and statusB >= 0 and statusA ~= statusB then
    if reverseFlag then
      return statusA < statusB
    else
      return statusA > statusB
    end
  end
  if dataA.pid == g_LocalPlayer:getPlayerId() then
    return true
  elseif dataB.pid == g_LocalPlayer:getPlayerId() then
    return false
  end
  if statusA < 0 and statusB >= 0 then
    return true
  elseif statusA >= 0 and statusB < 0 then
    return false
  elseif statusA >= 0 and statusB >= 0 and statusA ~= statusB then
    return statusA > statusB
  elseif placeA ~= placeB then
    return placeA < placeB
  else
    if zsA ~= zsB then
      return zsA > zsB
    elseif lvA ~= lvB then
      return lvA > lvB
    end
    local timeA = dataA.t
    local timeB = dataB.t
    if timeA ~= timeB then
      return timeA < timeB
    else
      return dataA.pid < dataB.pid
    end
  end
end
function BpMgr:SetBpRequestList(info)
  SendMessage(MsgID_BP_RequestList, info)
end
function BpMgr:DeleteBpRequest(pid)
  SendMessage(MsgID_BP_DeleteRequest, pid)
end
function BpMgr:SetBpRequestNum(num)
  SendMessage(MsgID_BP_RquestNum, num)
end
function BpMgr:SetBanwordTime(pid, resttime)
  SendMessage(MsgID_BP_BanWordTime, pid, resttime)
end
function BpMgr:UpdateBpMemberInfo(pid, pInfo)
  if self.m_HasBpListCache ~= true then
    print("---->>>如果本地没有缓存信息，则不用理会中途发过来的更新信息", pid)
    return
  end
  local localPlayerId = g_LocalPlayer:getPlayerId()
  if pInfo.jid ~= nil and pid ~= localPlayerId then
    local mapViewIns = g_MapMgr:getMapViewIns()
    if mapViewIns then
      mapViewIns:PlayerChangBpName(pid, self.m_LocalBpName, pInfo.jid)
    end
  end
  if self.m_BpMemberExist[pid] ~= nil then
    local oldIdx, newIdx
    for i, info in pairs(self.m_BpMemberList) do
      if info.pid == pid then
        for k, v in pairs(pInfo) do
          info[k] = v
        end
        oldIdx = i
        break
      end
    end
    table.sort(self.m_BpMemberList, handler(self, self._BpMemberSortFunc))
    for i, info in pairs(self.m_BpMemberList) do
      if info.pid == pid then
        newIdx = i
        break
      end
    end
    if oldIdx ~= nil and newIdx ~= nil and oldIdx ~= newIdx then
      SendMessage(MsgID_BP_ChangeMemberPos, pid, self.m_BpMemberList[newIdx], oldIdx, newIdx)
    end
    SendMessage(MsgID_BP_UpdateMemberInfo, pid, pInfo)
  elseif pInfo.new ~= nil and pInfo.new ~= 0 then
    local index = -1
    for i, info in pairs(self.m_BpMemberList) do
      if self:_BpMemberSortFunc(pInfo, info) then
        index = i
        table.insert(self.m_BpMemberList, i, pInfo)
        break
      end
    end
    if index == -1 then
      self.m_BpMemberList[#self.m_BpMemberList + 1] = pInfo
      index = #self.m_BpMemberList
    end
    self.m_BpMemberExist[pid] = true
    SendMessage(MsgID_BP_AddNewMemberInfo, pid, pInfo, index)
  end
end
function BpMgr:SetBpPlaceNumInfo(info)
  SendMessage(MsgID_BP_PlaceNumInfo, info)
end
function BpMgr:SetBpNotice(noticeList)
  SendMessage(MsgID_BP_Notice, noticeList)
end
function BpMgr:DeleteNotice(noticeId)
  SendMessage(MsgID_BP_DeleteNotice, noticeId)
end
function BpMgr:DeleteBpMember(pid)
  for index, info in pairs(self.m_BpMemberList) do
    if pid == info.pid then
      table.remove(self.m_BpMemberList, index)
      self.m_BpMemberExist[pid] = nil
      SendMessage(MsgID_BP_DeleteBpMember, pid)
      break
    end
  end
  local localPlayerId = g_LocalPlayer:getPlayerId()
  local mapViewIns = g_MapMgr:getMapViewIns()
  if mapViewIns and pid ~= localPlayerId then
    mapViewIns:PlayerChangBpName(pid, "", 0)
  end
end
function BpMgr:SetBpTotemInfo(bpId, totemInfo)
  if self.m_LocalBpId ~= bpId then
    return
  end
  self.m_ToTemInfo = totemInfo
  SendMessage(MsgID_BP_TotemInfo, totemInfo)
end
function BpMgr:SetTodayUnlockTotemTimes(times)
  SendMessage(MsgID_BP_UnlockTotemTimes, times)
end
function BpMgr:SetTodayPaoShangTimes(times)
  self.m_PaoShangTimes = times
  SendMessage(MsgID_BP_PaoShang, times)
end
function BpMgr:SetAllFuLeaderInfo(info)
  ShowBpTuiWeiRangXian(info)
end
function BpMgr:setBPHuoDongFlag(flags)
  flags = flags or {}
  self.chumo = flags.chumo or false
  self.anzhan = flags.anzhan or false
end
function BpMgr:getOpenChuMoFlag()
  if self.chumo ~= true then
    self.chumo = false
  end
  return self.chumo
end
function BpMgr:getOpenAnZhanFlag()
  if self.anzhan ~= true then
    self.anzhan = false
  end
  return self.anzhan
end
function BpMgr:NewBpJoinRequest(flag)
  if g_BpRequestList ~= nil then
    flag = false
  end
  self.m_NewBpJoinRequest = flag
  SendMessage(MsgID_BP_NewBpJoinRequest, flag)
end
function BpMgr:rejectBpLeader(pid, pname)
  local msg = string.format("副帮主#<Y>%s#发起了罢免帮主的投票#<G,M:%d,F:22>[查看]#", pname, CRichText_MessageType_BpVote)
  SendMessage(MsgID_Message_BangPaiTip, msg)
end
function BpMgr:rejectBpLeaderProgress(num, need)
  local msg = string.format("罢免帮主当前投票数#<Y>(%d/%d)#(达到%d票即可投票成功)#<G,M:%d,F:22>[查看]#", num, need, need, CRichText_MessageType_BpVote)
  SendMessage(MsgID_Message_BangPaiTip, msg)
end
function BpMgr:setBangPaiCacheData(pid, bpName)
  if pid ~= nil and bpName ~= nil and string.len(bpName) > 0 then
    self.m_OtherPlayerBangPaiName[pid] = bpName
  end
end
function BpMgr:getPlayerBangPaiName(pid)
  return self.m_OtherPlayerBangPaiName[pid]
end
function BpMgr:bpWarJoinTip(flag)
  self.m_BpWarJoinTip = flag
  SendMessage(MsgID_BP_BpWarJoinTip, flag)
end
function BpMgr:send_getTotalBpListInfo(i_index)
  if self:_cdTimeControl("getTotalBpListInfo", 0.5) then
    netsend.netbangpai.getTotalBpListInfo(i_index)
  end
end
function BpMgr:send_getBpTenet(bpId)
  if self:_cdTimeTableControl("getBpTenet", bpId, 1) then
    netsend.netbangpai.getBpTenet(bpId)
  end
end
function BpMgr:send_requestJoinBp(bpId)
  if self:_cdTimeTableControl("requestJoinBp", bpId, 1) then
    netsend.netbangpai.requestJoinBp(bpId)
  end
end
function BpMgr:send_requestJoinAllBp()
  if self:_cdTimeControl("requestJoinAllBp", 1) then
    netsend.netbangpai.requestJoinAllBp()
  end
end
function BpMgr:send_requestTotalBpAmount()
  if self:_cdTimeControl("requestTotalBpAmount", 1) then
    netsend.netbangpai.requestTotalBpAmount()
  end
end
function BpMgr:send_createNewBp(bpname, tenet)
  if self:_cdTimeControl("createNewBp", 1) then
    netsend.netbangpai.createNewBp(bpname, tenet)
  end
end
function BpMgr:send_requestBpBaseInfo()
  netsend.netbangpai.requestBpBaseInfo()
end
function BpMgr:send_getBpMemberInfo()
  netsend.netbangpai.getBpMemberInfo()
end
function BpMgr:send_getBpRequestAmount()
  netsend.netbangpai.getBpRequestAmount()
end
function BpMgr:send_banWordOfPlayer(pid)
  if self:_cdTimeTableControl("banWordOfPlayer", pid, 1) then
    netsend.netbangpai.banWordOfPlayer(pid)
  end
end
function BpMgr:send_cancelBanWordOfPlayer(pid)
  if self:_cdTimeTableControl("cancelBanWordOfPlayer", pid, 1) then
    netsend.netbangpai.cancelBanWordOfPlayer(pid)
  end
end
function BpMgr:send_getBanWordTime(pid)
  netsend.netbangpai.getBanWordTime(pid)
end
function BpMgr:send_kickOutBpMember(pid)
  netsend.netbangpai.kickOutBpMember(pid)
end
function BpMgr:send_getBpPlaceNumInfo()
  netsend.netbangpai.getBpPlaceNumInfo()
end
function BpMgr:send_quitBangPai()
  if self:_cdTimeControl("quitBangPai", 1) then
    netsend.netbangpai.quitBangPai()
  end
end
function BpMgr:send_setBangPaiPlace(i_pid, i_place)
  if self:_cdTimeControl("setBangPaiPlace", 0.5) then
    netsend.netbangpai.setBangPaiPlace(i_pid, i_place)
  end
end
function BpMgr:send_getBpRequestListInfo(i_index)
  netsend.netbangpai.getBpRequestListInfo(i_index)
end
function BpMgr:send_clearBpRequest()
  if self:_cdTimeControl("clearBpRequest", 1) then
    netsend.netbangpai.clearBpRequest()
  end
end
function BpMgr:send_agreeBpJoinRequest(pid)
  if self:_cdTimeTableControl("agreeBpJoinRequest", pid, 1) then
    netsend.netbangpai.agreeBpJoinRequest(pid)
  end
end
function BpMgr:send_contributeOffer(num)
  if self:_cdTimeControl("contributeOffer", 1) then
    netsend.netbangpai.contributeOffer(num)
    ShowWarningInWar()
  end
end
function BpMgr:send_getAllBpNotice()
  netsend.netbangpai.getAllBpNotice()
end
function BpMgr:send_publishBpNotice(noticeId, notice)
  netsend.netbangpai.publishBpNotice(noticeId, notice)
end
function BpMgr:send_deleteBpNotice(noticeId)
  netsend.netbangpai.deleteBpNotice(noticeId)
end
function BpMgr:send_setMyMainOrFuTotem(flag, totemId)
  if self:_cdTimeControl("setMyMainOrFuTotem", 0.5) then
    netsend.netbangpai.setMyMainOrFuTotem(flag, totemId)
    ShowWarningInWar()
  end
end
function BpMgr:send_getBpTotemInfo()
  netsend.netbangpai.getBpTotemInfo()
end
function BpMgr:send_getTodayBpUnlockTotemTimes()
  if self:_cdTimeControl("getTodayBpUnlockTotemTimes", 1) then
    netsend.netbangpai.getTodayBpUnlockTotemTimes()
  end
end
function BpMgr:send_getTodayBpPaoShangTimes()
  if self:_cdTimeControl("getTodayBpPaoShangTimes", 1) then
    netsend.netbangpai.getTodayBpPaoShangTimes()
  end
end
function BpMgr:send_editBpTenet(tenet)
  netsend.netbangpai.editBpTenet(tenet)
end
function BpMgr:send_publishTaskToken(tokenType)
  netsend.netbangpai.publishTaskToken(tokenType)
end
function BpMgr:send_changeBpLeader(pid)
  netsend.netbangpai.changeBpLeader(pid)
end
function BpMgr:send_getAllFuLeaders()
  if self:_cdTimeControl("getAllFuLeaders", 1) then
    netsend.netbangpai.getAllFuLeaders()
  end
end
function BpMgr:send_getBpAchievePoint()
  if self:_cdTimeControl("getBpAchievePoint", 1) then
    netsend.netbangpai.getBpAchievePoint()
  end
end
function BpMgr:send_closeBpInfoDlg()
  netsend.netbangpai.closeBpInfoDlg()
end
function BpMgr:Clear()
end
g_BpMgr = BpMgr.new()
gamereset.registerResetFunc(function()
  if g_BpMgr then
    g_BpMgr:Clear()
  end
  g_BpMgr = BpMgr.new()
end)

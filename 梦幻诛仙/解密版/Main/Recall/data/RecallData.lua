local Lplus = require("Lplus")
local AfkFriendInfo = require("Main.Recall.data.AfkFriendInfo")
local RecallHeroFriendInfo = require("Main.Recall.data.RecallHeroFriendInfo")
local BindedFriendActiveInfo = require("Main.Recall.data.BindedFriendActiveInfo")
local BindedRecalledFriendInfo = require("Main.Recall.data.BindedRecalledFriendInfo")
local RecallUtils = require("Main.Recall.RecallUtils")
local RecallData = Lplus.Class("RecallData")
local def = RecallData.define
local _instance
def.static("=>", RecallData).Instance = function()
  if _instance == nil then
    _instance = RecallData()
  end
  return _instance
end
def.field("table")._activeAwardCfg = nil
local UPDATE_INTERVAL = 1
def.field("number")._timerID = 0
def.field("table")._afkFriendList = nil
def.field("number")._lastRecallTime = 0
def.field("number")._todayRecallCount = 0
def.const("table").RecallAfkType = {
  CanRecall = 1,
  AlreadyRecall = 2,
  CanNotRecall = 3,
  CanBeRecall = 4
}
def.field("boolean")._b1stReturnLogin = false
def.field("number")._heroReturnTime = 0
def.field("boolean")._bInBindTime = false
def.field("table")._recallHeroFriendList = nil
def.field("table")._heroBindActiveInfo = nil
def.field("table")._bindFriendActiveList = nil
def.field("table")._bindedRecalledFriendList = nil
def.field("table")._rebateInfo = nil
def.method().Init = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self._activeAwardCfg = nil
  self:_ClearTimer()
  self._afkFriendList = nil
  self._lastRecallTime = 0
  self._todayRecallCount = 0
  self._b1stReturnLogin = false
  self._heroReturnTime = 0
  self._bInBindTime = false
  self._recallHeroFriendList = nil
  self._heroBindActiveInfo = nil
  self._bindFriendActiveList = nil
  self._bindedRecalledFriendList = nil
  self._rebateInfo = nil
end
def.method()._Update = function(self)
  local bAfkEvent = false
  if self._afkFriendList and #self._afkFriendList > 0 then
    for _, afkFriendInfo in ipairs(self._afkFriendList) do
      if afkFriendInfo:CheckAfkPeriodOver() then
        bAfkEvent = true
      end
    end
    if bAfkEvent then
      Event.DispatchEvent(ModuleId.RECALL, gmodule.notifyId.Recall.RECALL_AFK_INFO_CHANGE, nil)
    end
  end
  if self._bInBindTime then
    self._bInBindTime = 0 < self:GetLeftBindTime()
    if not self._bInBindTime then
      Event.DispatchEvent(ModuleId.RECALL, gmodule.notifyId.Recall.HERO_RETURN_INFO_CHANGE, nil)
    end
  end
end
def.method()._ClearTimer = function(self)
  if self._timerID > 0 then
    GameUtil.RemoveGlobalTimer(self._timerID)
    self._timerID = 0
  end
end
def.method()._LoadActiveAwardCfg = function(self)
  warn("[RecallData:_LoadActiveAwardCfg] start Load ActiveAwardCfg!")
  self._activeAwardCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_RECAll_ACTIVE_AWARD_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local awardCfg = {}
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    awardCfg.dayIndex = DynamicRecord.GetIntValue(entry, "dayIndex")
    awardCfg.recallAward = DynamicRecord.GetIntValue(entry, "recallAward")
    awardCfg.backAward = DynamicRecord.GetIntValue(entry, "backAward")
    self._activeAwardCfg[awardCfg.dayIndex] = awardCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table")._GetActiveAwardCfgs = function(self)
  if nil == self._activeAwardCfg then
    self:_LoadActiveAwardCfg()
  end
  return self._activeAwardCfg
end
def.method("number", "=>", "table").GetActiveAwardCfg = function(self, dayIdx)
  return self:_GetActiveAwardCfgs()[dayIdx]
end
def.method("=>", "number").GetMaxBindActiveDay = function(self)
  local activeAwardCfgs = self:_GetActiveAwardCfgs()
  return activeAwardCfgs and #activeAwardCfgs or 0
end
def.method("table").OnSyncRecallLossInfo = function(self, p)
  self._afkFriendList = {}
  if p.loss_infos and #p.loss_infos > 0 then
    for _, lossRoleInfo in ipairs(p.loss_infos) do
      local afkFriendInfo = AfkFriendInfo.New(lossRoleInfo)
      table.insert(self._afkFriendList, afkFriendInfo)
    end
  end
  self:_SortAfkFriendList()
  self._lastRecallTime = p.update_time
  self._todayRecallCount = p.today_num
  Event.DispatchEvent(ModuleId.RECALL, gmodule.notifyId.Recall.RECALL_AFK_INFO_CHANGE, nil)
end
def.method("table").OnSRecallFriendSuccess = function(self, p)
  local bEvent = false
  local afkFriendInfo = self:GetAfkFriendInfoByOpenId(p.open_id)
  if afkFriendInfo then
    afkFriendInfo:OnHeroRecallSuccess(p.invite_time)
    self:_SortAfkFriendList()
    bEvent = true
  end
  self._lastRecallTime = p.invite_time
  if RecallUtils.IsSameDay(_G.GetServerTime(), p.invite_time) then
    self._todayRecallCount = self._todayRecallCount + 1
    bEvent = true
  else
    warn("[RecallData:OnSRecallFriendSuccess] don't add recall count, not same day:", _G.GetServerTime(), p.invite_time)
  end
  if bEvent then
    Event.DispatchEvent(ModuleId.RECALL, gmodule.notifyId.Recall.RECALL_AFK_INFO_CHANGE, nil)
  end
end
def.method("=>", "table").GetAfkFriendList = function(self)
  return self._afkFriendList
end
def.method("=>", "number").GetAfkFriendCount = function(self)
  return self._afkFriendList and #self._afkFriendList or 0
end
def.method()._SortAfkFriendList = function(self)
  if self:GetAfkFriendCount() > 0 then
    table.sort(self._afkFriendList, function(a, b)
      if a == nil then
        return true
      elseif b == nil then
        return false
      else
        local canRecallA = self:CanRecallAfkFriend(a)
        local canRecallB = self:CanRecallAfkFriend(b)
        if canRecallA ~= canRecallB then
          return canRecallA
        elseif a:GetFightPower() ~= b:GetFightPower() then
          return a:GetFightPower() > b:GetFightPower()
        elseif a:GetLastLoginTime() ~= b:GetLastLoginTime() then
          return a:GetLastLoginTime() > b:GetLastLoginTime()
        else
          return Int64.lt(a:GetRoleId(), b:GetRoleId())
        end
      end
    end)
  end
end
def.method("table", "=>", "table").FilterAfkFriendList = function(self, filterOptions)
  local result = {}
  if self:GetAfkFriendCount() > 0 then
    if nil == filterOptions or #filterOptions <= 0 then
      result = self._afkFriendList
    else
      for _, afkFriendInfo in ipairs(self._afkFriendList) do
        local bSatisfy = false
        for _, filter in ipairs(filterOptions) do
          if filter == RecallData.RecallAfkType.CanRecall then
            if self:CanRecallAfkFriend(afkFriendInfo) then
              bSatisfy = true
              break
            end
          elseif filter == RecallData.RecallAfkType.AlreadyRecall then
            if not afkFriendInfo:IsHeroRecallPeriodOver() then
              bSatisfy = true
              break
            end
          elseif filter == RecallData.RecallAfkType.CanNotRecall then
            if not self:CanRecallAfkFriend(afkFriendInfo) then
              bSatisfy = true
              break
            end
          elseif filter == RecallData.RecallAfkType.CanBeRecall and afkFriendInfo:CanBeRecalled() then
            bSatisfy = true
            break
          end
        end
        if bSatisfy then
          table.insert(result, afkFriendInfo)
        end
      end
    end
  end
  return result
end
def.method("table", "=>", "boolean").CanRecallAfkFriend = function(self, afkFriendInfo)
  if nil == afkFriendInfo then
    return false
  end
  local result = false
  if not self:ReachDayRecallLimit() then
    result = afkFriendInfo:CanBeRecalled()
  end
  return result
end
def.method("=>", "boolean").ReachDayRecallLimit = function(self)
  local result = false
  local maxRecallCountPerDay = RecallUtils.GetConst("MAX_RECALL_TIMES_EVERY_DAY")
  if maxRecallCountPerDay <= self:GetTodayRecallCount() then
    result = true
  end
  return result
end
def.method("=>", "boolean").HaveCanRecallAfkFriend = function(self)
  local result = false
  local recallRoleList = self:FilterAfkFriendList({
    RecallData.RecallAfkType.CanRecall
  })
  if recallRoleList and #recallRoleList > 0 then
    result = true
  end
  return result
end
def.method("userdata", "=>", "table").GetAfkFriendInfoByOpenId = function(self, openId)
  local result
  if openId and self:GetAfkFriendCount() > 0 then
    for _, afkFriendInfo in ipairs(self._afkFriendList) do
      if afkFriendInfo:IsOpenIdEq(openId) then
        result = afkFriendInfo
        break
      end
    end
  end
  return result
end
def.method("userdata").DeleteAfkFriendInfoByOpenId = function(self, openId)
  local index = 0
  if openId and 0 < self:GetAfkFriendCount() then
    for idx, afkFriendInfo in ipairs(self._afkFriendList) do
      if afkFriendInfo:IsOpenIdEq(openId) then
        index = idx
        break
      end
    end
  end
  if index > 0 then
    table.remove(self._afkFriendList, index)
    Event.DispatchEvent(ModuleId.RECALL, gmodule.notifyId.Recall.RECALL_AFK_INFO_CHANGE, nil)
  end
end
def.method("=>", "number").GetLastRecallTime = function(self)
  return self._lastRecallTime
end
def.method("=>", "number").GetTodayRecallCount = function(self)
  return self._todayRecallCount
end
def.method("table").OnSyncUserBackInfo = function(self, p)
  self._b1stReturnLogin = p.first == 1
  self._heroReturnTime = p.back_time
  self._bInBindTime = self:GetLeftBindTime() > 0
  self._recallHeroFriendList = {}
  if p.recall_friends and 0 < #p.recall_friends then
    for _, friendInfo in ipairs(p.recall_friends) do
      local recallHeroFriendInfo = RecallHeroFriendInfo.New(friendInfo)
      table.insert(self._recallHeroFriendList, recallHeroFriendInfo)
    end
  end
  self:_SortRecallHeroFriendList()
  Event.DispatchEvent(ModuleId.RECALL, gmodule.notifyId.Recall.HERO_RETURN_INFO_CHANGE, nil)
end
def.method("=>", "table").GetRecallHeroFriendList = function(self)
  return self._recallHeroFriendList
end
def.method("=>", "number").GetRecallHeroFriendCount = function(self)
  return self._recallHeroFriendList and #self._recallHeroFriendList or 0
end
def.method()._SortRecallHeroFriendList = function(self)
  if self:GetRecallHeroFriendCount() > 0 then
    table.sort(self._recallHeroFriendList, function(a, b)
      if a == nil then
        return true
      elseif b == nil then
        return false
      else
        local bHasBindA = a:HasBinded()
        local bHasBindB = b:HasBinded()
        if bHasBindA ~= bHasBindB then
          return not bHasBindA
        elseif a:GetRecallCount() ~= b:GetRecallCount() then
          return a:GetRecallCount() > b:GetRecallCount()
        elseif a:GetFightPower() ~= b:GetFightPower() then
          return a:GetFightPower() > b:GetFightPower()
        else
          return Int64.lt(a:GetRoleId(), b:GetRoleId())
        end
      end
    end)
  end
end
def.method("=>", "number").GetHeroReturnTime = function(self)
  return self._heroReturnTime or 0
end
def.method("=>", "boolean").IsFirstReturnLogin = function(self)
  return self._b1stReturnLogin
end
def.method("=>", "table").GetUnbindedRecallHeroFriendList = function(self)
  local result = {}
  if self:GetRecallHeroFriendCount() > 0 then
    for idx, recallHeroFriendInfo in ipairs(self._recallHeroFriendList) do
      if not recallHeroFriendInfo:HasBinded() then
        table.insert(result, recallHeroFriendInfo)
      end
    end
  end
  return result
end
def.method("=>", "number").GetUnbindedRecallHeroFriendCount = function(self)
  local unbindFriendList = self:GetUnbindedRecallHeroFriendList()
  local unbindRecallerCount = unbindFriendList and #unbindFriendList or 0
  return unbindRecallerCount
end
def.method("userdata", "=>", "table").GetRecallHeroFriendInfoByOpenId = function(self, openId)
  local result
  if openId and self:GetRecallHeroFriendCount() > 0 then
    for idx, recallHeroFriendInfo in ipairs(self._recallHeroFriendList) do
      if recallHeroFriendInfo:IsOpenIdEq(openId) then
        result = recallHeroFriendInfo
        break
      end
    end
  end
  return result
end
def.method("userdata", "=>", "table").DeleteRecallHeroFriendInfoByOpenId = function(self, openId)
  local result
  local index = 0
  if openId and 0 < self:GetRecallHeroFriendCount() then
    for idx, recallHeroFriendInfo in ipairs(self._recallHeroFriendList) do
      if recallHeroFriendInfo:IsOpenIdEq(openId) then
        result = recallHeroFriendInfo
        index = idx
        break
      end
    end
  end
  if index > 0 then
    table.remove(self._recallHeroFriendList, index)
    Event.DispatchEvent(ModuleId.RECALL, gmodule.notifyId.Recall.HERO_RETURN_INFO_CHANGE, nil)
  end
  return result
end
def.method().ClearHeroReturnInfo = function(self)
  self._b1stReturnLogin = false
  self._heroReturnTime = 0
  self._bInBindTime = false
  self:ClearRecallHeroFriendList()
end
def.method().ClearRecallHeroFriendList = function(self)
  if self:GetRecallHeroFriendCount() > 0 then
    self._recallHeroFriendList = {}
    Event.DispatchEvent(ModuleId.RECALL, gmodule.notifyId.Recall.HERO_RETURN_INFO_CHANGE, nil)
  end
end
def.method("=>", "number").GetLeftBindTime = function(self)
  local pastTime = _G.GetServerTime() - self:GetHeroReturnTime()
  local BindInterval = RecallUtils.GetConst("BIND_PERIOD_IN_HOUR") * 3600
  if pastTime >= BindInterval then
    return 0
  else
    return BindInterval - pastTime
  end
end
def.method("=>", "boolean").CanBindRecallFriend = function(self)
  local unbindRecallerCount = self:GetUnbindedRecallHeroFriendCount()
  local bindedRecallerCount = self:GetRecallHeroFriendCount() - unbindRecallerCount
  local maxBindRecallerCount = RecallUtils.GetConst("BIND_FRIEND_NUM")
  return unbindRecallerCount > 0 and bindedRecallerCount < maxBindRecallerCount and 0 < self:GetLeftBindTime()
end
def.method("table").OnSyncBindVitalityInfo = function(self, p)
  self._bindFriendActiveList = {}
  self._heroBindActiveInfo = BindedFriendActiveInfo.New(p.vitality_info, false)
  if p.recall_bind_infos and #p.recall_bind_infos > 0 then
    for _, friendInfo in ipairs(p.recall_bind_infos) do
      local bindByFriendActiveInfo = BindedFriendActiveInfo.New(friendInfo, false)
      table.insert(self._bindFriendActiveList, bindByFriendActiveInfo)
    end
  end
  if p.back_bind_infos and 0 < #p.back_bind_infos then
    for _, friendInfo in ipairs(p.back_bind_infos) do
      local bindByHeroActiveInfo = BindedFriendActiveInfo.New(friendInfo, true)
      table.insert(self._bindFriendActiveList, bindByHeroActiveInfo)
    end
  end
  self:_SortBindedFriendActiveList()
  Event.DispatchEvent(ModuleId.RECALL, gmodule.notifyId.Recall.BINDED_FRIEND_ACTIVE_CHANGE, nil)
end
def.method()._SortBindedFriendActiveList = function(self)
  if self:GetBindedFriendActiveCount() > 0 then
    table.sort(self._bindFriendActiveList, function(a, b)
      if a == nil then
        return true
      elseif b == nil then
        return false
      else
        local bCanFetchA = a:CanFetchAward()
        local bCanFetchB = b:CanFetchAward()
        if bCanFetchA ~= bCanFetchB then
          return bCanFetchA
        else
          local bFetchedA = a:IsAwardFetched()
          local bFetchedB = b:IsAwardFetched()
          if bFetchedA ~= bFetchedB then
            return not bFetchedA
          elseif a:GetBindTime() ~= b:GetBindTime() then
            return a:GetBindTime() > b:GetBindTime()
          elseif a:GetFightPower() ~= b:GetFightPower() then
            return a:GetFightPower() > b:GetFightPower()
          else
            return Int64.lt(a:GetRoleId(), b:GetRoleId())
          end
        end
      end
    end)
  end
end
def.method("table").OnAddBindVitalityInfo = function(self, p)
  if nil == self._bindFriendActiveList then
    self._bindFriendActiveList = {}
  end
  if p.vitality_info then
    self._heroBindActiveInfo = BindedFriendActiveInfo.New(p.vitality_info, false)
  end
  if p.recall_bind_infos and #p.recall_bind_infos > 0 then
    for _, friendInfo in ipairs(p.recall_bind_infos) do
      self:DeleteFriendActiveInfoByOpenId(friendInfo.user_info.openid, false)
      local bindByFriendActiveInfo = BindedFriendActiveInfo.New(friendInfo, true)
      table.insert(self._bindFriendActiveList, bindByFriendActiveInfo)
    end
  end
  if p.back_bind_infos and 0 < #p.back_bind_infos then
    for _, friendInfo in ipairs(p.back_bind_infos) do
      self:DeleteFriendActiveInfoByOpenId(friendInfo.user_info.openid, false)
      local bindByHeroActiveInfo = BindedFriendActiveInfo.New(friendInfo, false)
      table.insert(self._bindFriendActiveList, bindByHeroActiveInfo)
    end
  end
  self:_SortBindedFriendActiveList()
  Event.DispatchEvent(ModuleId.RECALL, gmodule.notifyId.Recall.BINDED_FRIEND_ACTIVE_CHANGE, nil)
  self:UpdateReturnedBindedFriendList(p.recall_bind_infos, false, true)
end
def.method("table").OnSGetBindRewardSuccess = function(self, p)
  local bindFriendActiveInfo = self:GetFriendActiveInfoByOpenId(p.open_id)
  if bindFriendActiveInfo and RecallUtils.IsSameDay(p.reward_time, bindFriendActiveInfo:GetUpdateTime()) then
    bindFriendActiveInfo:SetAwardFetched(true)
    Event.DispatchEvent(ModuleId.RECALL, gmodule.notifyId.Recall.BINDED_FRIEND_ACTIVE_CHANGE, nil)
  end
end
def.method("=>", "table").GetBindedFriendActiveList = function(self)
  return self._bindFriendActiveList
end
def.method("=>", "number").GetBindedFriendActiveCount = function(self)
  return self._bindFriendActiveList and #self._bindFriendActiveList or 0
end
def.method("userdata", "=>", "table").GetFriendActiveInfoByOpenId = function(self, openId)
  local result
  if openId and self:GetBindedFriendActiveCount() > 0 then
    for _, friendActiveInfo in ipairs(self._bindFriendActiveList) do
      if friendActiveInfo:IsOpenIdEq(openId) then
        result = friendActiveInfo
        break
      end
    end
  end
  return result
end
def.method("userdata", "boolean", "=>", "table").DeleteFriendActiveInfoByOpenId = function(self, openId, bEvent)
  local result
  local index = 0
  if openId and 0 < self:GetBindedFriendActiveCount() then
    for idx, bindedFriendInfo in ipairs(self._bindFriendActiveList) do
      if bindedFriendInfo:IsOpenIdEq(openId) then
        result = bindedFriendInfo
        index = idx
        break
      end
    end
  end
  if index > 0 then
    table.remove(self._bindFriendActiveList, index)
    if bEvent then
      Event.DispatchEvent(ModuleId.RECALL, gmodule.notifyId.Recall.BINDED_FRIEND_ACTIVE_CHANGE, nil)
    end
  end
  return result
end
def.method("=>", "table").GetHeroActiveInfo = function(self)
  return self._heroBindActiveInfo
end
def.method("=>", "boolean").HaveUnfetchedActiveAward = function(self)
  local result = false
  local bindedFriendList = self:GetBindedFriendActiveList()
  if bindedFriendList and #bindedFriendList > 0 then
    for _, friendActiveInfo in ipairs(bindedFriendList) do
      if friendActiveInfo:CanFetchAward() then
        result = true
        break
      end
    end
  end
  return result
end
def.method("table").OnSyncBackFriendBindInfo = function(self, p)
  self:UpdateReturnedBindedFriendList(p.back_friends, true, false)
  self:UpdateRebateInfo(p.rebate_info, false)
  Event.DispatchEvent(ModuleId.RECALL, gmodule.notifyId.Recall.BINDED_FRIEND_REBATE_CHANGE, nil)
end
def.method("table", "boolean", "boolean").UpdateReturnedBindedFriendList = function(self, friends, bIsInit, bEvent)
  if nil == self._bindedRecalledFriendList or bIsInit then
    self._bindedRecalledFriendList = {}
  end
  if friends and #friends > 0 then
    for _, friendInfo in ipairs(friends) do
      if not bIsInit then
        self:DeleteBindedRecalledFriendByOpenId(friendInfo.user_info.openid, false)
      end
      local bindedRecalledFriendInfo = BindedRecalledFriendInfo.New(friendInfo)
      table.insert(self._bindedRecalledFriendList, bindedRecalledFriendInfo)
    end
    self:_SortBindedRecalledFriendList()
    if bEvent then
      Event.DispatchEvent(ModuleId.RECALL, gmodule.notifyId.Recall.BINDED_FRIEND_REBATE_CHANGE, nil)
    end
  end
end
def.method("table", "boolean").UpdateRebateInfo = function(self, rebateInfo, bEvent)
  if rebateInfo then
    self._rebateInfo = rebateInfo
    if bEvent then
      Event.DispatchEvent(ModuleId.RECALL, gmodule.notifyId.Recall.BINDED_FRIEND_REBATE_CHANGE, nil)
    end
  end
end
def.method("table").OnSGetRecallRebateInfoSuccess = function(self, p)
  self:UpdateRebateInfo(p.rebate_info, true)
end
def.method("table").OnSGetRecallRebateSuccess = function(self, p)
  if RecallUtils.IsSameDay(p.rebate_info.receive_time, _G.GetServerTime()) then
    self:UpdateRebateInfo(p.rebate_info, true)
  end
end
def.method()._SortBindedRecalledFriendList = function(self)
  if self:GetBindedRecalledFriendCount() > 0 then
    table.sort(self._bindedRecalledFriendList, function(a, b)
      if a == nil then
        return true
      elseif b == nil then
        return false
      elseif a:GetBindTime() ~= b:GetBindTime() then
        return a:GetBindTime() < b:GetBindTime()
      else
        return a:GetOpenIdString() < b:GetOpenIdString()
      end
    end)
  end
end
def.method("=>", "table").GetBindedRecalledFriendList = function(self)
  return self._bindedRecalledFriendList
end
def.method("=>", "number").GetBindedRecalledFriendCount = function(self)
  return self._bindedRecalledFriendList and #self._bindedRecalledFriendList or 0
end
def.method("userdata", "boolean", "=>", "table").DeleteBindedRecalledFriendByOpenId = function(self, openId, bEvent)
  local result
  local index = 0
  if openId and 0 < self:GetBindedRecalledFriendCount() then
    for idx, bindedFriendInfo in ipairs(self._bindedRecalledFriendList) do
      if bindedFriendInfo:IsOpenIdEq(openId) then
        result = bindedFriendInfo
        index = idx
        break
      end
    end
  end
  if index > 0 then
    table.remove(self._bindedRecalledFriendList, index)
    if bEvent then
      Event.DispatchEvent(ModuleId.RECALL, gmodule.notifyId.Recall.BINDED_FRIEND_REBATE_CHANGE, nil)
    end
  end
  return result
end
def.method("=>", "number").GetTotalRestRebateNum = function(self)
  return self._rebateInfo and self._rebateInfo.total_num or 0
end
def.method("=>", "number").GetFetchRebateTime = function(self)
  return self._rebateInfo and self._rebateInfo.receive_time or 0
end
def.method("=>", "number").GetTodayFetchedRebateNum = function(self)
  return self._rebateInfo and self._rebateInfo.receive_num or 0
end
def.method("=>", "number").GetTodayLeftRebateNum = function(self)
  local MaxRebatePerDay = RecallUtils.GetConst("YUAN_BAO_DRAW")
  local todayLeft = math.max(0, MaxRebatePerDay - self:GetTodayFetchedRebateNum())
  return math.min(todayLeft, self:GetTotalRestRebateNum())
end
def.method().OnEnterWorld = function(self)
  self._timerID = GameUtil.AddGlobalTimer(UPDATE_INTERVAL, false, function()
    self:_Update()
  end)
end
def.method().OnLeaveWorld = function(self)
  self:_Reset()
end
def.method().OnNewDay = function(self)
  local RecallProtocols = require("Main.Recall.RecallProtocols")
  if not RecallUtils.IsSameDay(_G.GetServerTime(), self._lastRecallTime) then
    self._todayRecallCount = 0
    Event.DispatchEvent(ModuleId.RECALL, gmodule.notifyId.Recall.RECALL_AFK_INFO_CHANGE, nil)
  end
  if self._heroBindActiveInfo and 0 < self:GetBindedFriendActiveCount() then
    RecallProtocols.SendCGetBindVitalityInfoReq()
  end
  if self._rebateInfo and self:GetBindedRecalledFriendCount() then
    RecallProtocols.SendCGetRecallRebateInfoReq()
  end
end
RecallData.Commit()
return RecallData

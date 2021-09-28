local BaitanDataMgr = class("BaitanDataMgr")
function BaitanDataMgr:ctor()
  self.m_BaseData = {}
  self.m_BaitanTimeData = {}
  self.m_GoodsData = {}
  self.m_Players = {}
  self.m_RedIconForMarket = false
  self.m_IsSellingFlag = false
end
function BaitanDataMgr:SetIsSellingFlag(flag)
  self.m_IsSellingFlag = flag
  SendMessage(MsgID_Stall_UpdateIsSellingFlag)
end
function BaitanDataMgr:GetIsSellingFlag(flag)
  return self.m_IsSellingFlag
end
function BaitanDataMgr:SetBaseData(baseData)
  for k, v in pairs(baseData) do
    self.m_BaseData[k] = v
  end
  SendMessage(MsgID_Stall_UpdateBaseData)
end
function BaitanDataMgr:GetBaseData()
  return self.m_BaseData
end
function BaitanDataMgr:SetBaitanTime(leftTime, curTime)
  self.m_BaitanTimeData.leftTime = leftTime
  self.m_BaitanTimeData.curTime = curTime
  SendMessage(MsgID_Stall_UpdateBaitanTimeData)
end
function BaitanDataMgr:GetBaitanTime()
  return self.m_BaitanTimeData
end
function BaitanDataMgr:SetRedIconFlag(flag)
  self.m_RedIconForMarket = flag
  SendMessage(MsgID_Stall_GoodsChange)
end
function BaitanDataMgr:GetRedIconFlag()
  return self.m_RedIconForMarket
end
function BaitanDataMgr:UpdateRedIconFlag()
  local isChange = false
  if self.m_GoodsData[0] ~= nil and self.m_GoodsData[0].goodsDataDict ~= nil then
    for _, data_ in pairs(self.m_GoodsData[0].goodsDataDict) do
      if data_.s ~= 1 or data_.num == 0 then
        isChange = true
        break
      elseif 0 < data_.num and 0 < data_.son then
        isChange = true
        break
      end
    end
  end
  self:SetRedIconFlag(isChange)
end
function BaitanDataMgr:SetOneDirGoods(dirKey, goodsList)
  print("BaitanDataMgr:SetOneDirGoods")
  if self.m_GoodsData[dirKey] ~= nil then
    local delGoodsIDList = DeepCopyTable(self.m_GoodsData[dirKey].goodsDataDict)
    if delGoodsIDList ~= nil then
      for delGoodID, _ in ipairs(delGoodsIDList) do
        self:DelOneGood(delGoodID)
      end
    end
  end
  self.m_GoodsData[dirKey] = {dirKey = dirKey}
  for _, oneGoodData in pairs(goodsList) do
    self:NewOneGood(dirKey, oneGoodData)
  end
  SendMessage(MsgID_Stall_GetOneDirData, {dirKey = dirKey})
end
function BaitanDataMgr:GetGoodsData(dirKey)
  if self.m_GoodsData[dirKey] ~= nil then
    if self.m_GoodsData[dirKey].goodsDataDict ~= nil then
      return self.m_GoodsData[dirKey].goodsDataDict
    else
      return {}
    end
  else
    return {}
  end
end
function BaitanDataMgr:GetLeaftTimeorCurTime(dirKey)
  if self.m_GoodsData[dirKey] ~= nil then
    return self.m_GoodsData[dirKey]
  end
end
function BaitanDataMgr:NewOneGood(dirKey, goodData)
  print("BaitanDataMgr:NewOneGood")
  if self.m_GoodsData[dirKey] == nil then
    print("没有对应的dirKey", dirKey)
    return
  end
  if self.m_GoodsData[dirKey].goodsDataDict == nil then
    self.m_GoodsData[dirKey].goodsDataDict = {}
  end
  local goodId = goodData.id
  local ispet = goodData.ispet
  local num = goodData.num
  local son = goodData.son
  local s = goodData.s
  local p = goodData.p
  local pid = goodData.pid
  local objData = goodData.obj or {}
  if goodId == nil then
    print("goodId为空")
    return
  end
  local goodRDict = {
    goodId = goodId,
    ispet = ispet,
    num = num,
    son = son,
    s = s,
    p = p,
    pid = pid
  }
  self.m_GoodsData[dirKey].goodsDataDict[goodId] = goodRDict
  local player = self:getPlayer(pid)
  if player == nil then
    player = self:CreatePlayer(pid)
  end
  if ispet == 0 then
    player:SetOneItem(goodId, objData.i_sid, objData)
  elseif ispet == 1 then
    local pet = player:getObjById(objData.i_pid)
    if pet then
      player:setSvrproToPet(pet, objData)
    else
      local newPetFlag = false
      player:newPetWithServerPro(goodId, objData.i_type, objData, newPetFlag)
    end
  end
  self:UpdateRedIconFlag()
end
function BaitanDataMgr:UpdateOneGood(goodData)
  print("BaitanDataMgr:UpdateOneGood")
  local goodId = goodData.id
  local ispet = goodData.ispet
  local num = goodData.num
  local son = goodData.son
  local s = goodData.s
  local p = goodData.p
  local pid = goodData.pid
  local objData = goodData.obj or {}
  if goodId == nil then
    print("goodId为空,不能UpdateOneGood")
    return
  end
  local dirKey = self:_getDirKeyBygoodID(goodId) or 0
  if dirKey == nil then
    print("dirKey为空,不能UpdateOneGood")
    return
  end
  if self.m_GoodsData[dirKey] == nil then
    print("self.m_GoodsData[dirKey]为空,不能UpdateOneGood")
    return
  end
  local goodRDict = {
    goodId = goodId,
    ispet = ispet,
    num = num,
    son = son,
    s = s,
    p = p,
    pid = pid
  }
  if self.m_GoodsData[dirKey].goodsDataDict == nil then
    self.m_GoodsData[dirKey].goodsDataDict = {}
  end
  if self.m_GoodsData[dirKey].goodsDataDict[goodId] == nil then
    self.m_GoodsData[dirKey].goodsDataDict[goodId] = {}
  end
  for k, v in pairs(goodRDict) do
    self.m_GoodsData[dirKey].goodsDataDict[goodId][k] = v
  end
  local pid = self.m_GoodsData[dirKey].goodsDataDict[goodId].pid
  local ispet = self.m_GoodsData[dirKey].goodsDataDict[goodId].ispet
  local player = self:getPlayer(pid)
  if player == nil then
    print("找不到对应的player,不能UpdateOneGood")
    return
  end
  if ispet == 0 then
    local itemObj = player:GetOneItem(goodId)
    if itemObj == nil then
      print("找不到对应的itemObj,不能UpdateOneGood")
      return
    else
      player:SetOneItem(goodId, objData.i_sid, objData)
    end
  elseif ispet == 1 then
    local pet = player:getObjById(goodId)
    if pet then
      player:setSvrproToPet(pet, objData)
    else
      print("找不到对应的pet,不能UpdateOneGood")
      return
    end
  end
  self:UpdateRedIconFlag()
  local gitem = g_BaitanDataMgr:GetOneGood(goodId)
  if g_MissionMgr and gitem then
    g_MissionMgr:objectNumChanged(gitem:getTypeId())
  end
  SendMessage(MsgID_Stall_UpdateOneGood, {goodId = goodId, dirKey = dirKey})
end
function BaitanDataMgr:DelOneGood(goodId)
  print("BaitanDataMgr:DelOneGood", goodId)
  local dirKey = self:_getDirKeyBygoodID(goodId)
  if dirKey == nil then
    print("dirKey为空,不能DelOneGood")
    return
  end
  if self.m_GoodsData[dirKey].goodsDataDict[goodId] == nil then
    print("goodsDataDict里面数据为空,不能DelOneGood")
    return
  end
  local pid = self.m_GoodsData[dirKey].goodsDataDict[goodId].pid
  local ispet = self.m_GoodsData[dirKey].goodsDataDict[goodId].ispet
  self.m_GoodsData[dirKey].goodsDataDict[goodId] = nil
  local player = self:getPlayer(pid)
  if player == nil then
    print("找不到对应的player,不能DelOneGood")
    return
  end
  if ispet == 0 then
    player:DelOneItem(goodId)
  elseif ispet == 1 then
    player:DeleteRole(goodId)
  end
  self:UpdateRedIconFlag()
  SendMessage(MsgID_Stall_DelOneGood, {dirKey = dirKey, goodId = goodId})
end
function BaitanDataMgr:GetOneGood(goodID)
  print("BaitanDataMgr:GetOneGood", goodID)
  local dirKey = self:_getDirKeyBygoodID(goodID) or 0
  if dirKey == nil then
    print("dirKey为空,不能GetOneGood")
    return nil
  end
  if self.m_GoodsData[dirKey].goodsDataDict[goodID] == nil then
    print("goodsDataDict里面数据为空,不能GetOneGood")
    return nil
  end
  local pid = self.m_GoodsData[dirKey].goodsDataDict[goodID].pid
  local ispet = self.m_GoodsData[dirKey].goodsDataDict[goodID].ispet
  local player = self:getPlayer(pid)
  if player == nil then
    print("找不到对应的player,不能GetOneGood")
    return nil
  end
  if ispet == 0 then
    return player:GetOneItem(goodID)
  elseif ispet == 1 then
    return player:getObjById(goodID)
  end
end
function BaitanDataMgr:GetOneGoodSellingData(goodID)
  print("BaitanDataMgr:GetOneGoodSellingData", goodID)
  local dirKey = self:_getDirKeyBygoodID(goodID) or 0
  if dirKey == nil then
    print("dirKey为空,不能GetOneGoodSellingData")
    return nil
  end
  if self.m_GoodsData[dirKey].goodsDataDict[goodID] == nil then
    print("goodsDataDict里面数据为空,不能GetOneGoodSellingData")
    return nil
  end
  return self.m_GoodsData[dirKey].goodsDataDict[goodID]
end
function BaitanDataMgr:_getDirKeyBygoodID(goodID)
  local dirKey
  for tDirKey, goodsData in pairs(self.m_GoodsData) do
    local goodsDataDict = goodsData.goodsDataDict
    if goodsDataDict ~= nil then
      for tGoodId, _ in pairs(goodsDataDict) do
        if tGoodId == goodID then
          dirKey = tDirKey
          break
        end
      end
    end
  end
  return dirKey
end
function BaitanDataMgr:CreatePlayer(pId)
  local player = Player.new(pId)
  PackageExtend.extend(player)
  self.m_Players[pId] = player
  return player
end
function BaitanDataMgr:getPlayer(pId)
  if pId then
    return self.m_Players[pId]
  end
  return nil
end
function BaitanDataMgr:getAllPlayers()
  return self.m_Players
end
function BaitanDataMgr:delPlayer(pId)
  local player = self.m_Players[pId]
  if player then
    if player.DelTiliTimer then
      player:DelTiliTimer()
    end
    if player.DelBoxTimer then
      player:DelBoxTimer()
    end
    if player.DelFuWenTimer then
      player:DelFuWenTimer()
    end
    if player.DelChengweiUpdateTimer then
      player:DelChengweiUpdateTimer()
    end
    self.m_Players[pId] = nil
    return true
  end
  return false
end
function BaitanDataMgr:ClearAllPlayer()
  local allPlayerID = {}
  for pid, _ in pairs(self.m_Players) do
    allPlayerID[#allPlayerID + 1] = pid
  end
  for _, pid in pairs(allPlayerID) do
    self:delPlayer(pid)
  end
end
function BaitanDataMgr:Clear()
  self:ClearAllPlayer()
  self.m_GoodsData = {}
  self.m_BaseData = {}
end
g_BaitanDataMgr = BaitanDataMgr.new()
gamereset.registerResetFunc(function()
  if g_BaitanDataMgr then
    g_BaitanDataMgr:Clear()
    g_BaitanDataMgr = nil
  end
  g_BaitanDataMgr = BaitanDataMgr.new()
end)

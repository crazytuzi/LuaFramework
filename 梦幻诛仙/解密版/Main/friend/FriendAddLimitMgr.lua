local Lplus = require("Lplus")
local FriendAddLimitMgr = Lplus.Class("FriendAddLimitMgr")
local def = FriendAddLimitMgr.define
def.field("table").m_RefuseInfo = nil
def.field("boolean").m_IsLoaded = false
def.field("userdata").m_MyRoleId = nil
def.const("string").FILE_PATH = "friendaddlimit"
def.const("string").TABLE_NAME = "refusetable"
local instance
def.static("=>", FriendAddLimitMgr).Instance = function()
  if nil == instance then
    instance = FriendAddLimitMgr()
    instance.m_RefuseInfo = nil
    instance.m_IsLoaded = false
    instance.m_MyRoleId = nil
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, FriendAddLimitMgr.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, FriendAddLimitMgr.OnLeaveWorld)
end
def.static("=>", "number").GetRefuseLimitNum = function()
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FRIEND_CONST_CFG, "refuseRecordNum")
  if nil == record then
    Debug.LogWarning("refuseRecordNum is nil ...... ")
    return 5
  end
  return record:GetIntValue("value") or 5
end
def.static("=>", "number").GetLimitValidDays = function()
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FRIEND_CONST_CFG, "refuseRecordDayNum")
  if nil == record then
    Debug.LogWarning("refuseRecordDayNum is nil ...... ")
    return 1
  end
  return record:GetIntValue("value") or 1
end
def.static("table", "table").OnEnterWorld = function(p1, p2)
  local self = FriendAddLimitMgr.Instance()
  self.m_MyRoleId = GetMyRoleID()
  if not self.m_IsLoaded then
    self:LoadInfo()
    self.m_IsLoaded = true
  end
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  local self = FriendAddLimitMgr.Instance()
  self:SaveInfo()
  self.m_RefuseInfo = nil
  self.m_IsLoaded = false
  self.m_MyRoleId = nil
end
def.method().LoadInfo = function(self)
  if nil == self.m_MyRoleId then
    return
  end
  local roleString = self.m_MyRoleId:tostring()
  local savepath = string.format("%s/%s/%s.lua", Application.persistentDataPath, FriendAddLimitMgr.FILE_PATH, roleString)
  local chunk, err = loadfile(savepath)
  if chunk then
    local tb = chunk()
    if not tb then
      Debug.LogWarning("Get Refuse Info Table Failed ...... ")
      self.m_RefuseInfo = nil
      return
    end
    self.m_RefuseInfo = tb
  else
    Debug.LogWarning("Load Refuse Info File Failed ...... ")
    self.m_RefuseInfo = nil
    return
  end
end
def.method().SaveInfo = function(self)
  if nil == self.m_RefuseInfo then
    return
  end
  local roleString = self.m_MyRoleId:tostring()
  local savepath = string.format("%s/%s/%s.lua", Application.persistentDataPath, FriendAddLimitMgr.FILE_PATH, roleString)
  GameUtil.CreateDirectoryForFile(savepath)
  require("Main.Common.LuaTableWriter").SaveTable(FriendAddLimitMgr.TABLE_NAME, savepath, self.m_RefuseInfo)
end
def.method("userdata", "string").OnRefuseAddFriend = function(self, refuseRoleId, refuseRoleName)
  if nil == refuseRoleId then
    return
  end
  if "" == refuseRoleName then
    return
  end
  local refuseString = refuseRoleId:tostring()
  local nowTime = GetServerTime()
  if nil == self.m_RefuseInfo then
    self.m_RefuseInfo = {}
  end
  if nil == self.m_RefuseInfo[refuseString] then
    self.m_RefuseInfo[refuseString] = {}
    self.m_RefuseInfo[refuseString].refuseNum = 1
    self.m_RefuseInfo[refuseString].lastTime = GetServerTime()
  else
    local lastTime = self.m_RefuseInfo[refuseString].lastTime
    if self:IsInLimitDay(nowTime, lastTime) then
      self.m_RefuseInfo[refuseString].refuseNum = self.m_RefuseInfo[refuseString].refuseNum + 1
      local limitRefuseNum = FriendAddLimitMgr.GetRefuseLimitNum()
      if limitRefuseNum <= self.m_RefuseInfo[refuseString].refuseNum then
        self:AddShield(refuseRoleId, refuseRoleName)
      end
    else
      self.m_RefuseInfo[refuseString].refuseNum = 1
      self.m_RefuseInfo[refuseString].lastTime = GetServerTime()
    end
  end
end
def.method("userdata", "string").AddShield = function(self, refuseRoleId, refuseRoleName)
  if nil == refuseRoleId then
    return
  end
  if "" == refuseRoleName then
    return
  end
  local FriendShieldShow = require("Main.friend.ui.FriendShieldShow")
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  local title = textRes.Friend[47]
  local content = string.format(textRes.Friend[48], refuseRoleName)
  local function callback(select, tag)
    if 1 == select then
      self:RemoveRefuseOne(refuseRoleId)
      FriendShieldShow.AddShield(refuseRoleId)
    end
  end
  CommonConfirmDlg.ShowConfirm(title, content, callback, nil)
end
def.method("userdata").RemoveRefuseOne = function(self, refuseRoleId)
  if nil == refuseRoleId then
    return
  end
  if nil == self.m_RefuseInfo then
    return
  end
  local refuseString = refuseRoleId:tostring()
  if self.m_RefuseInfo[refuseString] then
    self.m_RefuseInfo[refuseString] = nil
  end
end
def.method("number", "number", "=>", "boolean").IsInSameDay = function(self, nowTime, lastTime)
  local now = os.date("*t", nowTime)
  local last = os.date("*t", lastTime)
  if nil == now or nil == last then
    return false
  end
  if now.year == last.year and now.month == last.month and now.day == last.day then
    return true
  else
    return false
  end
end
def.method("number", "number", "=>", "boolean").IsInLimitDay = function(self, nowTime, lastTime)
  local validLimitDay = FriendAddLimitMgr.GetLimitValidDays()
  local timeInterval = math.abs(nowTime - lastTime)
  local limitInterval = validLimitDay * 24 * 3600
  return timeInterval <= limitInterval
end
def.method().printInfo = function(self)
  if self.m_RefuseInfo then
    for k, v in pairs(self.m_RefuseInfo) do
      warn("******* FriendAddLimitMgr ********* ", k, " ", v)
      if v then
        for k1, v1 in pairs(v) do
          warn("*********** FriendAddLimitMgr DetailInfo ************ ", k1, " ", v1)
        end
      end
    end
  else
    warn("******** the refuse info is nil ********")
  end
end
FriendAddLimitMgr.Commit()
return FriendAddLimitMgr

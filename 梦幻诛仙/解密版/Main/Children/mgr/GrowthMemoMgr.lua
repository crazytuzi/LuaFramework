local Lplus = require("Lplus")
local GrowthMemoMgr = Lplus.Class("GrowthMemoMgr")
local GrowthMemo = require("Main.Children.data.GrowthMemo")
local MemoUnitFactory = require("Main.Children.memo_unit.MemoUnitFactory")
local def = GrowthMemoMgr.define
def.const("number").MEMO_ALIVE_SECONDS = 10
def.const("number").MAX_CAHCE_MEMO_NUM = 1
local instance
def.static("=>", GrowthMemoMgr).Instance = function()
  if instance == nil then
    instance = GrowthMemoMgr()
  end
  return instance
end
def.field("table").m_cachedMemos = nil
def.field("table").m_callbacks = nil
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SGetChildGrowthDiaryInfo", GrowthMemoMgr.OnSGetChildGrowthDiaryInfo)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, GrowthMemoMgr.OnLeaveWorld)
end
def.method("userdata", "function").GetGrowthMemoAsync = function(self, childId, callback)
  local memo = self:GetGrowthMemoFromCache(childId)
  if memo and not self:IsMemoExpire(memo) then
    _G.SafeCallback(callback, memo)
    return
  end
  self:CGetChildGrowthDiary(childId)
  self.m_callbacks = self.m_callbacks or {}
  self.m_callbacks[tostring(childId)] = self.m_callbacks[tostring(childId)] or {}
  table.insert(self.m_callbacks[tostring(childId)], callback)
end
def.method("userdata", "=>", "table").GetGrowthMemoFromCache = function(self, childId)
  if self.m_cachedMemos == nil then
    return nil
  end
  return self.m_cachedMemos[tostring(childId)]
end
def.method(GrowthMemo, "=>", "boolean").IsMemoExpire = function(self, memo)
  local lastModifyTime = memo:GetLastModifyTime()
  local curTime = _G.GetServerTime()
  local duration = (curTime - lastModifyTime):ToNumber()
  if math.abs(duration) > GrowthMemoMgr.MEMO_ALIVE_SECONDS then
    return true
  else
    return false
  end
end
def.method("table", "=>", GrowthMemo).CreateMemoFromProtocol = function(self, p)
  local childId = p.child_id
  local memo = GrowthMemo.new(childId)
  if p.own_role_name then
    local ownerName = _G.GetStringFromOcts(p.own_role_name) or "nil"
    local owner = GrowthMemo.ChildOwner.new(nil, ownerName)
    memo:AddChildOwner(owner)
  end
  if p.another_parent_name then
    local ownerName = _G.GetStringFromOcts(p.another_parent_name)
    if ownerName then
      local owner = GrowthMemo.ChildOwner.new(nil, ownerName)
      memo:AddChildOwner(owner)
    end
  end
  local serverTime = _G.GetServerTime()
  local function conv2sec(time)
    local serverTimeScale = 10 * serverTime
    if time:gt(serverTimeScale) then
      print("wowowo")
      return time / 1000
    else
      return time
    end
  end
  memo:SetBirthTime(conv2sec(p.give_birth_time))
  memo:SetEnterChildhoodTime(conv2sec(p.child_hood_begin_time))
  memo:SetEnterAdultTime(conv2sec(p.adult_begin_time))
  for i, v in ipairs(p.growth_diary) do
    local growth_time = conv2sec(v.growth_time)
    local memoUnit = MemoUnitFactory.Create(v.grow_type, growth_time, v)
    memo:AppendMemoUnit(memoUnit)
  end
  memo:UpdateModifyTime()
  self:CacheMemo(memo)
  return memo
end
def.method(GrowthMemo).CacheMemo = function(self, memo)
  local childId = memo:GetChildId()
  self.m_cachedMemos = self.m_cachedMemos or {}
  self.m_cachedMemos[tostring(childId)] = memo
  if #self.m_cachedMemos > GrowthMemoMgr.MAX_CAHCE_MEMO_NUM then
    local removedKey, oldestTime
    for k, v in pairs(self.m_cachedMemos) do
      local lastModifyTime = v:GetLastModifyTime()
      if oldestTime == nil or oldestTime > lastModifyTime then
        removedKey = k
        oldestTime = lastModifyTime
      end
    end
    if removedKey then
      self.m_cachedMemos[removedKey] = nil
    end
  end
end
def.method().Clear = function(self)
  self.m_cachedMemos = nil
  self.m_callbacks = nil
end
def.method("userdata").CGetChildGrowthDiary = function(self, childId)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.children.CGetChildGrowthDiary").new(childId))
end
def.static("table").OnSGetChildGrowthDiaryInfo = function(p)
  local self = instance
  if self.m_callbacks == nil then
    return
  end
  local callbacks = self.m_callbacks[tostring(p.child_id)]
  if callbacks == nil then
    return
  end
  local memo = self:CreateMemoFromProtocol(p)
  for i, v in ipairs(callbacks) do
    SafeCallback(v, memo)
  end
end
def.static("table", "table").OnLeaveWorld = function(...)
  instance:Clear()
end
return GrowthMemoMgr.Commit()

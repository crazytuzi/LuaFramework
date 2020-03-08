local MODULE_NAME = (...)
local Lplus = require("Lplus")
local SocialSpaceFocusMan = Lplus.Class(MODULE_NAME)
local def = SocialSpaceFocusMan.define
local ECSocialSpaceMan = Lplus.ForwardDeclare("ECSocialSpaceMan")
local ECSpaceMsgs = require("Main.SocialSpace.ECSpaceMsgs")
def.const("number").INIT_FOCUS_LIST_TRY_TIMES = 3
def.field(ECSocialSpaceMan).m_spaceMan = nil
def.field("table").m_focusRoles = nil
local instance
def.static("=>", SocialSpaceFocusMan).Instance = function()
  if instance == nil then
    instance = SocialSpaceFocusMan()
  end
  return instance
end
def.method(ECSocialSpaceMan).Init = function(self, spaceMan)
  self.m_spaceMan = spaceMan
  if gmodule.moduleMgr:GetModule(ModuleId.SOCIAL_SPACE):IsFocusOpen() then
    self:InitFocusList()
  end
end
def.method().Clear = function(self)
  self.m_spaceMan = nil
  self.m_focusRoles = nil
end
def.method().InitFocusList = function(self)
  if self:HasFocusListInited() then
    return
  end
  local function getFocusList(leftTryTimes)
    if leftTryTimes <= 0 then
      return
    end
    self:ReqHostFocusList(function(focusList)
      if focusList == nil then
        getFocusList(leftTryTimes - 1)
      end
    end)
  end
  getFocusList(SocialSpaceFocusMan.INIT_FOCUS_LIST_TRY_TIMES)
end
def.method("=>", "boolean").HasFocusListInited = function(self)
  return self.m_focusRoles ~= nil
end
def.method("userdata", "=>", "boolean").HasFocusOnRole = function(self, roleId)
  if not self:HasFocusListInited() then
    error("Space focus list not inited yet.", 2)
  end
  local focusRoleInfo = self.m_focusRoles[tostring(roleId)]
  if focusRoleInfo == nil then
    return false
  end
  return focusRoleInfo:HasStatus(ECSpaceMsgs.FocusStatus.ACTIVE)
end
def.method("function").AsyncGetActiveFocusList = function(self, callback)
  if self:HasFocusListInited() then
    local activeFocusList = self:GetActiveFocusList()
    _G.SafeCallback(callback, activeFocusList)
    return
  end
  self:ReqHostFocusList(function(focusList)
    local activeFocusList
    if focusList then
      activeFocusList = self:GetActiveFocusList()
    end
    _G.SafeCallback(callback, activeFocusList)
  end)
end
def.method("=>", "table").GetActiveFocusList = function(self)
  if self.m_focusRoles == nil then
    return nil
  end
  local activeFocusList = {}
  for roleId, focusRoleInfo in pairs(self.m_focusRoles) do
    if focusRoleInfo:HasStatus(ECSpaceMsgs.FocusStatus.ACTIVE) then
      table.insert(activeFocusList, focusRoleInfo)
    end
  end
  table.sort(activeFocusList, function(lhs, rhs)
    return lhs.lastUpdateTime > rhs.lastUpdateTime
  end)
  return activeFocusList
end
def.method("function").ReqHostFocusList = function(self, callback)
  local roleId = self.m_spaceMan:GetHostRoleId()
  self.m_spaceMan:Req_GetFocusList(roleId, function(focusList)
    if focusList then
      self.m_focusRoles = {}
      for i, v in ipairs(focusList) do
        self.m_focusRoles[tostring(v.roleId)] = v
      end
      Event.DispatchEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.FocusListInited, nil)
    end
    _G.SafeCallback(callback, focusList)
  end, false)
end
def.method("userdata").ReqAddFocusOnRole = function(self, roleId)
  self.m_spaceMan:Req_AddFocus(roleId, function(data)
    if data.retcode == 0 then
      self:AddActiveFocusOnRole(roleId)
      Toast(textRes.SocialSpace[115])
      Event.DispatchEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.FocusListChanged, nil)
    end
  end)
end
def.method("userdata").ReqDelFocusOnRole = function(self, roleId)
  self.m_spaceMan:Req_DelFocus(roleId, function(data)
    if data.retcode == 0 then
      self:RemoveActiveFocusOnRole(roleId)
      Toast(textRes.SocialSpace[116])
      Event.DispatchEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.FocusListChanged, nil)
    end
  end)
end
def.method("userdata").ReqChangeFocusOnRole = function(self, roleId)
  if self:HasFocusOnRole(roleId) then
    self:ReqDelFocusOnRole(roleId)
  else
    self:ReqAddFocusOnRole(roleId)
  end
end
def.method("userdata").AddActiveFocusOnRole = function(self, roleId)
  self.m_focusRoles = self.m_focusRoles or {}
  local strRoleId = tostring(roleId)
  local focusRoleInfo = self.m_focusRoles[strRoleId]
  if focusRoleInfo == nil then
    focusRoleInfo = ECSpaceMsgs.ECFocusRoleInfo()
    focusRoleInfo.roleId = roleId
    local curTime = _G.GetServerTime()
    focusRoleInfo.createTime = curTime
    focusRoleInfo.lastUpdateTime = curTime
  end
  focusRoleInfo:AddStatus(ECSpaceMsgs.FocusStatus.ACTIVE)
  self.m_focusRoles[strRoleId] = focusRoleInfo
end
def.method("userdata").RemoveActiveFocusOnRole = function(self, roleId)
  if self.m_focusRoles == nil then
    return
  end
  local strRoleId = tostring(roleId)
  local focusRoleInfo = self.m_focusRoles[strRoleId]
  if focusRoleInfo == nil then
    return
  end
  focusRoleInfo:RemoveStatus(ECSpaceMsgs.FocusStatus.ACTIVE)
  if not focusRoleInfo:HasAnyStatus() then
    self.m_focusRoles[strRoleId] = nil
  end
end
return SocialSpaceFocusMan.Commit()

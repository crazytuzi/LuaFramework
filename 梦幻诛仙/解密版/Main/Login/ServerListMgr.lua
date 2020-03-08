local Lplus = require("Lplus")
local ServerListMgr = Lplus.Class("ServerListMgr")
local LoginModule = Lplus.ForwardDeclare("LoginModule")
local LoginUtility = require("Main.Login.LoginUtility")
local SLAXML = require("Utility.SLAXML.slaxdom")
local MathHelper = require("Common.MathHelper")
local Json = require("Utility.json")
local def = ServerListMgr.define
ServerListMgr.ServerState = {
  Smooth = 1,
  Busy = 2,
  Congestion = 3,
  Fix = 4
}
def.field("table").serverList = nil
def.field("table").serverNoIndexs = nil
def.field("table").servers = nil
def.field("table").roleLists = nil
local instance
def.static("=>", ServerListMgr).Instance = function()
  if instance == nil then
    instance = ServerListMgr()
  end
  return instance
end
def.method("=>", "table").GetServerList = function(self)
  return self.serverList
end
def.method().Clear = function(self)
  self.servers = nil
  self.serverList = nil
  self.serverNoIndexs = nil
end
def.method("number", "=>", "table").GetValidServerCfg = function(self, zoneid)
  if self.serverList and self.serverNoIndexs then
    local index = self.serverNoIndexs[zoneid]
    if index then
      return self.serverList.list[index]
    end
  end
  return nil
end
def.method("number", "=>", "table").GetServerCfg = function(self, zoneid)
  local validCfg = self:GetValidServerCfg(zoneid)
  if validCfg then
    return validCfg
  end
  if self.servers == nil then
    return nil
  end
  return self.servers[zoneid]
end
def.method("=>", "table").GetSelectedServerCfg = function(self)
  local selectedServerNo = LoginModule.Instance().selectedServerNo
  if selectedServerNo ~= 0 then
    return self:GetValidServerCfg(selectedServerNo)
  else
    return self:LoadHistorySelectedServerCfg()
  end
end
def.method("=>", "table").LoadHistorySelectedServerCfg = function(self)
  local loginHistory = LoginUtility.Instance():GetUserLoginHistory(LoginModule.Instance().userName)
  local serverCfg
  if loginHistory then
    for i, v in ipairs(loginHistory) do
      serverCfg = self:GetValidServerCfg(v.serverId)
      if serverCfg then
        LoginModule.Instance().selectedServerNo = serverCfg.no
        break
      end
    end
  end
  return serverCfg
end
def.method().RefreshServerList = function(self)
  self:DownloadServerList(nil)
end
def.method("function").DownloadServerList = function(self, callback)
  local function onCallback(params)
    if callback then
      callback(params)
    end
    Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.SERVER_LIST_UPDATE, nil)
  end
  local function processServerListXml(xmlContent)
    self.serverList = self:BuildServerList(xmlContent)
    self:BuildServerNoIndexs()
    onCallback(self.serverList)
    if #self.serverList.list == 0 then
      Toast(textRes.Login[56])
    end
  end
  local xmlContent = ""
  local SERVER_LIST_CACHE_PATH = GameUtil.GetAssetsPath() .. "/UserData/serverlistcache.xml"
  if #xmlContent == 0 then
    xmlContent = GameUtil.GetServerListUrl() or ""
    if #xmlContent ~= 0 then
      WriteToFile(SERVER_LIST_CACHE_PATH, xmlContent)
    end
  end
  if #xmlContent == 0 then
    xmlContent = ReadFromFile(SERVER_LIST_CACHE_PATH) or ""
  end
  if #xmlContent ~= 0 then
    processServerListXml(xmlContent)
  else
    onCallback(nil)
  end
end
def.method().BuildServerNoIndexs = function(self)
  if self.serverList == nil then
    return
  end
  self.serverNoIndexs = {}
  local list = {}
  for i, server in ipairs(self.serverList.list) do
    if self.serverNoIndexs[server.no] == nil then
      table.insert(list, server)
      self.serverNoIndexs[server.no] = #list
    else
      warn(string.format("zoneid %s is duplicated, serverName = %s", server.zoneid, server.name))
    end
  end
  self.serverList.list = list
end
def.method("number", "=>", "table").GetRecommendServers = function(self, recommendNum)
  local recommendList = {}
  if self.serverList == nil or #self.serverList.list == 0 then
    return recommendList
  end
  local indexs = {}
  local sum = 0
  for i, v in ipairs(self.serverList.list) do
    if 0 < v.recommendweight then
      sum = sum + v.recommendweight
      table.insert(indexs, {
        i = i,
        v = v.recommendweight,
        sum = sum
      })
    end
  end
  if sum == 0 then
    local sortedServer = {}
    for i, server in ipairs(self.serverList.list) do
      sortedServer[i] = server
      sortedServer[i].index = i
    end
    table.sort(sortedServer, function(left, right)
      if left.recommendweight < right.recommendweight then
        return false
      elseif left.recommendweight > right.recommendweight then
        return true
      else
        return left.index > right.index
      end
    end)
    for i = 1, recommendNum do
      local server = sortedServer[i]
      if server == nil then
        break
      end
      table.insert(recommendList, server)
    end
  else
    local recommendIndexs = {}
    while recommendNum > #recommendIndexs and sum > 0 do
      local val = math.random(sum)
      local index = MathHelper.lower_bound(indexs, {sum = val}, function(left, right)
        return left.sum < right.sum
      end)
      local rs = indexs[index]
      table.insert(recommendIndexs, rs.i)
      for i = index + 1, #indexs do
        indexs[i].sum = indexs[i].sum - rs.v
      end
      table.remove(indexs, index)
      sum = sum - rs.v
    end
    for i, index in ipairs(recommendIndexs) do
      local server = self.serverList.list[index]
      table.insert(recommendList, server)
    end
  end
  return recommendList
end
def.method("=>", "table").GetAllRecommendServers = function(self)
  local recommendList = {}
  for i, v in ipairs(self.serverList.list) do
    if v.recommendweight > 0 then
      recommendList[#recommendList + 1] = v
    end
  end
  table.sort(recommendList, function(l, r)
    return l.recommendweight > r.recommendweight
  end)
  return recommendList
end
def.method("string", "=>", "table").BuildServerList = function(self, xmlStr)
  local mzserverList = {
    list = {}
  }
  local serverList = self:ParseAndFilterServerList(xmlStr)
  for iZone, zoneInfo in ipairs(serverList) do
    for iServer, serverInfo in ipairs(zoneInfo) do
      serverInfo.tabname = zoneInfo.zoneName
      table.insert(mzserverList.list, serverInfo)
    end
  end
  return mzserverList
end
def.method("table", "=>", "table").AdaptServerInfo = function(self, serverInfo)
  local server = serverInfo
  server.no = tonumber(server.zoneid)
  server.address = server.ip
  server.recommendweight = server.recommendweight or 0
  local portSplite = string.find(serverInfo.port, ",")
  if portSplite then
    server.beginPort = tonumber(string.sub(serverInfo.port, 1, portSplite - 1))
    server.endPort = tonumber(string.sub(serverInfo.port, portSplite + 1, -1))
  else
    server.beginPort = tonumber(serverInfo.port)
    server.endPort = server.beginPort
  end
  server.state = serverInfo.status or ServerListMgr.ServerState.Busy
  if server.closed then
    server.state = ServerListMgr.ServerState.Fix
  end
  return server
end
def.method("string", "=>", "table").ParseAndFilterServerList = function(self, content)
  local configs = {}
  local function addServerInfo(zoneName, config)
    local zoneConfig
    for i, zone in ipairs(configs) do
      if zone.zoneName == zoneName then
        zoneConfig = zone
      end
    end
    if not zoneConfig then
      zoneConfig = {zoneName = zoneName, recommend = false}
      table.insert(configs, zoneConfig)
    end
    local index = #zoneConfig + 1
    zoneConfig[index] = config
  end
  local isTrue = function(attr)
    if not attr then
      return false
    end
    return attr and attr == "true"
  end
  local getNumber = function(attr)
    if attr then
      return tonumber(attr)
    end
    return 0
  end
  self.servers = {}
  local serverIndex = 0
  local doc = SLAXML:dom(content)
  for i, servergroup in ipairs(doc.root.el) do
    if servergroup.name == "servergroup" then
      local visible = ServerListMgr.FilterServer(servergroup)
      for j, server in ipairs(servergroup.el) do
        if server.name == "server" then
          local serverConfig = {
            name = server.attr.name,
            ip = server.attr.address,
            port = server.attr.port,
            zoneid = tonumber(server.attr.zoneid),
            hidden = isTrue(server.attr.hidden),
            closed = isTrue(server.attr.closed),
            notice = server.attr.notice,
            recommendweight = getNumber(server.attr.recommendweight),
            recommend = false,
            evaluation = isTrue(server.attr.evaluation),
            preview = isTrue(server.attr.preview),
            guest = isTrue(server.attr.guest),
            status = getNumber(server.attr.status),
            accountwithzoneid = isTrue(servergroup.attr.accountwithzoneid),
            is_center = tonumber(server.attr.is_center or "0") ~= 0,
            center_zoneid = tonumber(server.attr.center_zoneid or "0"),
            newserver = isTrue(server.attr.newserver)
          }
          if serverConfig.hidden ~= true and visible then
            addServerInfo(servergroup.attr.name, serverConfig)
          end
          local adaptedServerCfg = self:AdaptServerInfo(serverConfig)
          self.servers[adaptedServerCfg.zoneid] = adaptedServerCfg
        end
      end
    end
  end
  return configs
end
local HasFlag = function(str, flag)
  local ret = flag == "" or str == flag or str:find("^" .. flag .. "[%,%s]+") or str:find("[%,%s]+" .. flag .. "[%,%s]+") or str:find("[%,%s]+" .. flag .. "$")
  return not not ret
end
def.static("=>", "string").CurrentOS = function()
  local LoginModule = require("Main.Login.LoginModule")
  local platform = LoginModule.Instance():GetLoginPlatform()
  if platform == 0 then
    return "pc"
  elseif platform == 1 then
    return "ios"
  elseif platform == 2 then
    return "android"
  else
    return "unknown"
  end
end
def.static("=>", "string").CurrentAuth = function()
  if ClientCfg.GetSDKType() == ClientCfg.SDKTYPE.MSDK then
    local ECMSDK = require("ProxySDK.ECMSDK")
    if LoginPlatform == MSDK_LOGIN_PLATFORM.QQ then
      return "qq"
    elseif LoginPlatform == MSDK_LOGIN_PLATFORM.WX then
      return "wechat"
    elseif LoginPlatform == MSDK_LOGIN_PLATFORM.GUEST then
      return "guest"
    end
  end
  return "auany"
end
def.static("=>", "boolean").IsEvaluationVersion = function()
  return GameUtil.IsEvaluation()
end
def.static("table", "=>", "boolean").FilterServer = function(servergroupXml)
  local matchChannel, matchNoChannel
  if ClientCfg.GetSDKType() ~= ClientCfg.SDKTYPE.MSDK then
    local ECMSDK = require("ProxySDK.ECMSDK")
    if servergroupXml.attr.channel then
      matchChannel = HasFlag(servergroupXml.attr.channel, ECMSDK.GetChannelID())
    elseif servergroupXml.attr.nochannel then
      matchNoChannel = not HasFlag(servergroupXml.attr.nochannel, ECMSDK.GetChannelID())
    end
  end
  local matchEvaluation
  if servergroupXml.attr.evaluation and servergroupXml.attr.evaluation == "true" then
    matchEvaluation = true
  else
    matchEvaluation = false
  end
  local matchOS = HasFlag(servergroupXml.attr.os, ServerListMgr.CurrentOS())
  local matchAuth = HasFlag(servergroupXml.attr.auth, ServerListMgr.CurrentAuth())
  if ServerListMgr.IsEvaluationVersion() then
    return matchOS and matchAuth and matchChannel ~= false and matchNoChannel ~= false and matchEvaluation == true
  else
    return matchOS and matchAuth and matchChannel ~= false and matchNoChannel ~= false and matchEvaluation ~= true
  end
end
def.method("=>", "boolean").FetchHostRoleList = function(self)
  local openid = gmodule.moduleMgr:GetModule(ModuleId.LOGIN).userName
  if self.roleLists and self.roleLists[openid] then
    print(string.format("already fetch openid=%s rolelist", openid))
    return false
  end
  self:FetchRoleList(openid)
  return true
end
def.method("string").FetchRoleList = function(self, openid)
  local role_list_service = _G.GetDirVersionService("get_role_list")
  if role_list_service == nil then
    warn("_G.GetVersionService(\"get_role_list\") return nil")
    return
  end
  local rawopenid = string.gsub(openid, "(.*)%$%w+", "%1")
  local url = string.format("%s?openid=%s", role_list_service, rawopenid)
  url = _G.NormalizeHttpURL(url)
  local roleListCachePath = GameUtil.GetAssetsPath() .. "/UserData/rolelistcache.json"
  print("downLoadUrl", url)
  GameUtil.downLoadUrl(url, roleListCachePath, function(success, url, filename, bytes)
    if not success then
      return
    end
    local content = bytes.string
    local rolelistData = Json.decode(content)
    if rolelistData.ret ~= 0 then
      warn(rolelistData.msg)
      return
    end
    local userName = LoginModule.Instance().userName
    if userName ~= openid then
      warn(string.format("onDownLoadUrl %s, %s ~= %s", url, userName, openid))
      return
    end
    self.roleLists = self.roleLists or {}
    self.roleLists[userName] = rolelistData.data
    local localHistory = LoginUtility.Instance():GetUserLoginHistory(userName) or {}
    local localHistoryMap = {}
    for i, v in ipairs(localHistory) do
      localHistoryMap[v.serverId] = {
        order = i,
        roleList = v.roleList
      }
    end
    local zoneidMap = {}
    for i, v in ipairs(rolelistData.data) do
      zoneidMap[v.zoneid] = v.zoneid
      do
        local serverId = v.zoneid
        local localRoleList = localHistoryMap[serverId] and localHistoryMap[serverId].roleList or {}
        local sortMap = {}
        for i, v in ipairs(localRoleList) do
          local roleid = v.roleid
          if type(v.roleid) == "string" then
            roleid = Int64.ParseString(v.roleid)
          end
          sortMap[tostring(roleid)] = i
        end
        local simpleRoleList = {}
        for i, role in ipairs(v.rolelist) do
          local simpleRole = {}
          simpleRole.roleid = Int64.new(role.roleid)
          simpleRole.basic = {}
          simpleRole.basic.occupation = role.occupation
          simpleRole.basic.gender = role.gender
          simpleRole.basic.name = role.name
          simpleRole.basic.level = role.level
          local localRoleIdx = sortMap[tostring(simpleRole.roleid)]
          if role.avatarid then
            simpleRole.avatarId = role.avatarid
          elseif localRoleIdx then
            simpleRole.avatarId = localRoleList[localRoleIdx].avatarId
          end
          if role.avatar_frameid then
            simpleRole.avatarFrameId = role.avatar_frameid
          elseif localRoleIdx then
            simpleRole.avatarFrameId = localRoleList[localRoleIdx].avatarFrameId
          end
          simpleRoleList[#simpleRoleList + 1] = simpleRole
        end
        table.sort(simpleRoleList, function(l, r)
          local lsort = sortMap[tostring(l.roleid)] or math.huge
          local rsort = sortMap[tostring(r.roleid)] or math.huge
          return lsort < rsort
        end)
        LoginUtility.Instance():AddLoginHistoryEx(userName, serverId, simpleRoleList, {updateOrder = false})
      end
    end
    Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ROLE_LIST_UPDATE, {
      self.roleLists
    })
  end)
end
ServerListMgr.Commit()
return ServerListMgr

local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ChooseServerPanel = Lplus.Extend(ECPanelBase, "ChooseServerPanel")
local def = ChooseServerPanel.define
local instance
local loginModule = gmodule.moduleMgr:GetModule(ModuleId.LOGIN)
local LoginUtility = require("Main.Login.LoginUtility")
local ServerListMgr = require("Main.Login.ServerListMgr")
local EC = require("Types.Vector3")
local ECGame = require("Main.ECGame")
local Vector3 = EC.Vector3
local GUIUtils = require("GUI.GUIUtils")
local AvatarInterface = require("Main.Avatar.AvatarInterface")
local NOT_SET = 0
def.const("number").TOP_SERVER_MAX_LIMITE = 2
def.field("table")._topServerConfigList = nil
def.field("table")._tabLists = nil
def.field("table")._serverConfigList = nil
def.field("number")._currentPage = NOT_SET
def.field("number")._totalPage = NOT_SET
def.field("number")._timerId = 0
def.field("boolean")._logging = false
def.const("table").ServerStateIcon = {
  New = "Img_New",
  Hot = "Img_Hot",
  Fix = "Img_Fix",
  Smooth = "Img_LiuChang",
  Busy = "Img_busy",
  Congestion = "Img_Hot",
  None = nil
}
local ServerState = ServerListMgr.ServerState
def.field("table").lastServerInfo = nil
local SERVER_NUM_PER_PAGE
local lastUpdateTime = 0
def.static("=>", ChooseServerPanel).Instance = function()
  if instance == nil then
    instance = ChooseServerPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
  self:PrepareHostRoleList()
  self:CreatePanel(RESPATH.PREFAB_LOGIN_CHOOSE_SEVER_PANEL_RES, 1)
  self:SetModal(true)
  require("Main.ECGame").Instance():SetGameState(_G.GameState.ChooseServer)
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_SERVER_SUCCESS, ChooseServerPanel.OnLoginServerSuccess)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.RESET_UI, ChooseServerPanel.OnResetUI)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.SERVER_LIST_UPDATE, ChooseServerPanel.OnServerListUpdate)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ROLE_LIST_UPDATE, ChooseServerPanel.OnServerListUpdate)
  self:Fill()
  ECGame.Instance():StartRefreshDirTimer()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_SERVER_SUCCESS, ChooseServerPanel.OnLoginServerSuccess)
  Event.UnregisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.RESET_UI, ChooseServerPanel.OnResetUI)
  Event.UnregisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.SERVER_LIST_UPDATE, ChooseServerPanel.OnServerListUpdate)
  Event.UnregisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ROLE_LIST_UPDATE, ChooseServerPanel.OnServerListUpdate)
  if self._timerId ~= 0 then
    GameUtil.RemoveGlobalTimer(self._timerId)
    self._timerId = 0
  end
  require("GUI.WaitingTip").HideTip()
  self._topServerConfigList = nil
  self._serverConfigList = nil
  self._currentPage = NOT_SET
  self._logging = false
  self._tabLists = nil
end
def.override("=>", "boolean").OnMoveBackward = function(self)
  self:HidePanel()
  require("Main.Login.ui.LoginMainPanel").Instance():ShowPanel()
  return true
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:HidePanel()
    require("Main.Login.ui.LoginMainPanel").Instance():ShowPanel()
  elseif string.sub(id, 1, 5) == "item_" then
    local index = tonumber(string.sub(id, 6, -1))
    self:OnPageChange(index)
  elseif string.sub(id, 1, 10) == "topServer_" then
    local index = tonumber(string.sub(id, 11, -1))
    self:OnTopServerSelected(index)
  elseif string.sub(id, 1, 13) == "Img_BgServer_" then
    local index = tonumber(string.sub(id, 14, -1))
    self:OnServerSelected(index)
  end
end
def.method("string", "boolean").onToggle = function(self, id, isActive)
end
def.method().HidePanel = function(self)
  self:DestroyPanel()
end
def.method().Fill = function(self)
  self:UpdateUI(true)
end
def.method("boolean").UpdateUI = function(self, reset)
  self:DivideServerListGroup()
  self:UpdateTopServer()
  self:UpdateSideMenu(reset)
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method().UpdateTopServer = function(self)
  local _remove = true
  if _remove then
    return
  end
  self:LoadServerConfigList()
  local label_recent
  local newSprite = self.m_panel:FindDirect("Img_Bg0/Img_BgTop/Sprite")
  if newSprite then
    label_recent = newSprite:FindDirect("Label_Recent"):GetComponent("UILabel")
  else
    label_recent = self.m_panel:FindDirect("Img_Bg0/Img_BgTop/Label_Recent"):GetComponent("UILabel")
  end
  local loginHistory = LoginUtility.Instance():GetUserLoginHistory(loginModule.userName)
  local serverList
  if loginHistory ~= nil then
    label_recent.text = textRes.Login[17]
    serverList = loginHistory
  else
    label_recent.text = textRes.Login[18]
    serverList = self:GetRecommendServerList()
  end
  local existedServerList = {}
  for i, server in ipairs(serverList) do
    local no = server.no
    if server.serverId ~= nil then
      no = server.serverId
    end
    local serverCfg = ServerListMgr.Instance():GetValidServerCfg(no)
    if serverCfg ~= nil then
      table.insert(existedServerList, serverCfg)
    end
  end
  serverList = existedServerList
  local list_top = self.m_panel:FindDirect("Img_Bg0/Img_BgTop/List_Top"):GetComponent("UIList")
  local serverCount = math.min(#serverList, ChooseServerPanel.TOP_SERVER_MAX_LIMITE)
  list_top.itemCount = serverCount
  list_top:Resize()
  local listItems = list_top.children
  self._topServerConfigList = {}
  for i = 1, serverCount do
    local server = serverList[i]
    local no = server.no
    if server.serverId ~= nil then
      no = server.serverId
    end
    local item = listItems[i]
    if item.name == "_hidden_" .. i then
      item.name = "topServer_" .. i
    end
    local serverCfg = ServerListMgr.Instance():GetValidServerCfg(no)
    local label_name = item:FindDirect("Label_Recent_" .. i):GetComponent("UILabel")
    label_name.text = self:GetServerTitle(serverCfg.no, serverCfg.name)
    local Img_Sign = item:FindDirect("Img_Sign_" .. i)
    local Img_BgGray = item:FindDirect("Img_BgGray_" .. i)
    if serverCfg.state == ServerState.Fix then
      Img_BgGray:SetActive(true)
    else
      Img_BgGray:SetActive(false)
    end
    self:SetServerState(Img_Sign, serverCfg)
    table.insert(self._topServerConfigList, serverCfg)
  end
end
def.method("=>", "table").GetRecommendServerList = function(self)
  return ServerListMgr.Instance():GetRecommendServers(ChooseServerPanel.TOP_SERVER_MAX_LIMITE)
end
def.method("boolean").UpdateSideMenu = function(self, reset)
  local bgObj = self.m_panel:FindDirect("Img_Bg0")
  self._totalPage = #self._tabLists
  local list_sideMenu = bgObj:FindDirect("Img_BgTab/Scroll View_Tab/List_Tab"):GetComponent("UIList")
  list_sideMenu.itemCount = self._totalPage
  list_sideMenu:Resize()
  local listItems = list_sideMenu.children
  for i, tabList in ipairs(self._tabLists) do
    local item = listItems[i]
    local label_tabName = item:FindDirect("Label_Tab"):GetComponent("UILabel")
    label_tabName.text = tabList.name
  end
  if self._totalPage > 0 then
    if reset then
      GUIUtils.Toggle(listItems[1], true)
      self:OnPageChange(1)
    else
      self:UpdateServerList()
    end
  else
    self:UpdateServerList()
  end
end
def.method().DivideServerListGroup = function(self)
  local serverList = ServerListMgr.Instance():GetServerList().list
  local tabLists = {}
  local needRoleListGroup = true
  if needRoleListGroup then
    local tabList = {
      name = textRes.Login[17],
      order = -200
    }
    local loginHistory = LoginUtility.Instance():GetUserLoginHistory(loginModule.userName)
    local sortMap = {}
    if loginHistory then
      for i, v in ipairs(loginHistory) do
        local zoneId = v.serverId
        local serverCfg = ServerListMgr.Instance():GetValidServerCfg(zoneId)
        if serverCfg and v.roleList and #v.roleList > 0 then
          table.insert(tabList, 1, serverCfg)
        end
      end
    end
    if #tabList > 0 then
      table.insert(tabLists, tabList)
    end
  end
  local recommendServers = ServerListMgr.Instance():GetAllRecommendServers()
  if recommendServers then
    local tabList = {
      name = textRes.Login[18],
      order = -100
    }
    for i = #recommendServers, 1, -1 do
      tabList[#tabList + 1] = recommendServers[i]
    end
    if #tabList > 0 then
      table.insert(tabLists, tabList)
    end
  end
  local tabNameMapIndex = {}
  local autoTabNameServerCount = 0
  local SERVER_NUM_PER_PAGE = LoginUtility.GetServerCfgConsts("SEVER_GROUP_NUM")
  local BIG_ORDER = 100000
  local function genTabName(tabname)
    if tabname ~= "" then
      return tabname
    end
    autoTabNameServerCount = autoTabNameServerCount + 1
    local autoTabIndex = math.floor((autoTabNameServerCount - 1) / SERVER_NUM_PER_PAGE) + 1
    local startNo = (autoTabIndex - 1) * SERVER_NUM_PER_PAGE + 1
    local endNo = autoTabIndex * SERVER_NUM_PER_PAGE
    local tabname = string.format(textRes.Login[55], startNo, endNo)
    return tabname
  end
  local function getTabList(i, tabname)
    local tabname = tabname or ""
    local isAutoTabName = tabname == "" and true or false
    tabname = genTabName(tabname)
    local index = tabNameMapIndex[tabname]
    if index then
      return tabLists[index]
    else
      index = #tabLists + 1
      local order = i
      if isAutoTabName then
        order = BIG_ORDER - order
      end
      tabLists[index] = {name = tabname, order = order}
      tabNameMapIndex[tabname] = index
      return tabLists[index]
    end
  end
  for i, server in ipairs(serverList) do
    local tabList = getTabList(i, server.tabname)
    table.insert(tabList, server)
  end
  table.sort(tabLists, function(left, right)
    return left.order < right.order
  end)
  self._tabLists = tabLists
end
def.method().LoadServerConfigList = function(self)
  self._serverConfigList = ServerListMgr.Instance():GetServerList()
  if self._serverConfigList == nil then
    warn("Missing server config")
    return
  end
end
def.method("number").OnPageChange = function(self, index)
  if self._currentPage ~= index then
    self._currentPage = index
    self:UpdateServerList()
  end
  local bgObj = self.m_panel:FindDirect("Img_Bg0")
  local uiScrollView = bgObj:FindDirect("Img_BgServer/Scroll View_Server"):GetComponent("UIScrollView")
  uiScrollView:ResetPosition()
end
def.method().UpdateServerList = function(self)
  local bgObj = self.m_panel:FindDirect("Img_Bg0")
  local grid_serverList = bgObj:FindDirect("Img_BgServer/Scroll View_Server/Grid_Server"):GetComponent("UIGrid")
  local template = grid_serverList.gameObject:FindDirect("Img_BgServer01")
  if template then
    template.name = "Img_BgServer_0"
    template:SetActive(false)
  else
    template = grid_serverList.gameObject:FindDirect("Img_BgServer_0")
  end
  local tabList = self._tabLists[self._currentPage] or {}
  local serverNum = #tabList
  local serverCfg
  for i = serverNum, 1, -1 do
    serverCfg = tabList[i]
    local index = serverNum - i + 1
    self:AddServerItem(index, serverCfg, template)
  end
  local rootObj = grid_serverList.gameObject
  self:DestroyUnusedServerItem(rootObj, serverNum + 1)
  self.m_msgHandler:Touch(rootObj)
end
def.method("number", "table", "userdata").AddServerItem = function(self, index, serverCfg, template)
  local gridObj = template.transform.parent.gameObject
  local gridComponent = gridObj:GetComponent("UIGrid")
  local newItem = gridObj:FindDirect("Img_BgServer_" .. index)
  if newItem == nil then
    newItem = GameObject.Instantiate(template)
    newItem.name = "Img_BgServer_" .. index
    newItem:SetActive(true)
    gridComponent:AddChild(newItem.transform)
    newItem:set_localScale(Vector3.new(1, 1, 1))
  end
  local label_name = newItem:FindDirect("Label_Recent"):GetComponent("UILabel")
  label_name.text = self:GetServerTitle(serverCfg.no, serverCfg.name)
  local Img_BgGray = newItem:FindDirect("Img_BgGray")
  if serverCfg.state == ServerState.Fix then
    Img_BgGray:SetActive(true)
  else
    Img_BgGray:SetActive(false)
  end
  self:SetServerState(newItem, serverCfg)
  local Group_One = newItem:FindDirect("Group_One")
  local rolelist = LoginUtility.GetRoleListCfg(loginModule.userName, serverCfg.no)
  if rolelist and #rolelist > 0 then
    GUIUtils.SetActive(Group_One, true)
    self:SetRoleListInfo(Group_One, rolelist)
  else
    GUIUtils.SetActive(Group_One, false)
  end
end
def.method("userdata", "table").SetRoleListInfo = function(self, go, rolelist)
  local Img_Member1 = go:FindDirect("Img_Member1")
  local role = rolelist[1]
  for i = 2, #rolelist do
    local v = rolelist[i]
    if v.basic.level > role.basic.level then
      role = v
    end
  end
  local Label_Lv = Img_Member1:FindDirect("Label_Lv")
  local Img_IconHead = Img_Member1:FindDirect("Img_IconHead")
  GUIUtils.SetText(Label_Lv, role.basic.level)
  local avatarId = role.avatarId or AvatarInterface.Instance():getDefaultAvatarId(role.basic.occupation, role.basic.gender)
  local avatarFrameId = role.avatarFrameId or 0
  _G.SetAvatarIcon(Img_IconHead, avatarId, avatarFrameId)
  local uiSprite = Img_Member1:GetComponent("UISprite")
  if uiSprite then
    uiSprite.enabled = false
  end
end
def.method("userdata", "number").DestroyUnusedServerItem = function(self, rootObj, startPos)
  local uiGrid = rootObj:GetComponent("UIGrid")
  local count = uiGrid:GetChildListCount()
  for i = startPos, count do
    local item = rootObj:FindDirect("Img_BgServer_" .. i)
    if item and not item.isnil then
      item:Destroy()
    end
  end
end
def.method("userdata", "table").SetServerState = function(self, go, serverCfg)
  local Img_New = go:FindDirect("Img_New")
  local Img_Sign = go:FindDirect("Img_Sign")
  GUIUtils.SetActive(Img_New, serverCfg.newserver)
  local state = serverCfg.state
  if state == ServerState.Congestion then
    GUIUtils.SetSprite(Img_Sign, ChooseServerPanel.ServerStateIcon.Congestion)
  elseif state == ServerState.Busy then
    GUIUtils.SetSprite(Img_Sign, ChooseServerPanel.ServerStateIcon.Busy)
  elseif state == ServerState.Smooth then
    GUIUtils.SetSprite(Img_Sign, ChooseServerPanel.ServerStateIcon.Smooth)
  elseif state == ServerState.Fix then
    GUIUtils.SetSprite(Img_Sign, ChooseServerPanel.ServerStateIcon.Fix)
  else
    GUIUtils.SetSprite(Img_Sign, ChooseServerPanel.ServerStateIcon.None)
  end
end
def.method("number").OnTopServerSelected = function(self, index)
  local success = loginModule:SDKLoginDone()
  if not success then
    return
  end
  if self._logging then
    return
  end
  local serverInfo = self._topServerConfigList[index]
  self:SetServerInfo(serverInfo)
  self:LoginServer()
end
def.method("number").OnServerSelected = function(self, index)
  local success = loginModule:SDKLoginDone()
  if not success then
    return
  end
  if self._logging then
    return
  end
  local tabList = self._tabLists[self._currentPage]
  local serverInfo = tabList[#tabList - index + 1]
  self:SetServerInfo(serverInfo)
  self:LoginServer()
end
def.method("table").SetServerInfo = function(self, serverCfg)
  if serverCfg == nil then
    warn("SetServerInfo takes wrong.")
    return
  end
  self.lastServerInfo = {}
  self.lastServerInfo.selectedServerNo = loginModule.selectedServerNo
  self.lastServerInfo.serverIp = loginModule.serverIp
  self.lastServerInfo.serverPort = loginModule.serverPort
  self.lastServerInfo.lastLoginRoleId = loginModule.lastLoginRoleId
  loginModule.selectedServerNo = serverCfg.no
  loginModule.serverIp = serverCfg.address
  loginModule.serverPort = tostring(math.random(serverCfg.beginPort, serverCfg.endPort))
  loginModule.lastLoginRoleId = LoginUtility.GetServerLastLoginRoleId(loginModule.userName, serverCfg.no)
end
def.method().LoginServer = function(self)
  gmodule.network.disConnect()
  local success = loginModule:LoginServer()
  if success then
    require("GUI.WaitingTip").ShowTip(textRes.Login[23])
  end
end
def.static("table", "table").OnLoginServerSuccess = function(params, context)
  local self = instance
  self:HidePanel()
end
def.static("table", "table").OnResetUI = function()
  require("GUI.WaitingTip").HideTip()
end
def.static("table", "table").OnServerListUpdate = function()
  local self = instance
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  self:UpdateUI(false)
end
def.method().RollbackServreInfo = function(self)
  if self.lastServerInfo == nil then
    return
  end
  loginModule.selectedServerNo = self.lastServerInfo.selectedServerNo
  loginModule.serverIp = self.lastServerInfo.serverIp
  loginModule.serverPort = self.lastServerInfo.serverPort
  loginModule.lastLoginRoleId = self.lastServerInfo.lastLoginRoleId
end
def.method("number", "string", "=>", "string").GetServerTitle = function(self, no, name)
  local needNo = false
  local title = name
  if needNo then
    title = string.format(textRes.Login[19], no, title)
  end
  return title
end
def.method().DownloadServerList = function(self)
  lastUpdateTime = os.time()
  ServerListMgr.Instance():DownloadServerList(function(ret)
    if self.m_panel == nil or self.m_panel.isnil then
      return
    end
    if ret ~= nil then
      self:UpdateUI(false)
    end
  end)
end
def.method().PrepareHostRoleList = function(self)
  ServerListMgr.Instance():FetchHostRoleList()
end
return ChooseServerPanel.Commit()

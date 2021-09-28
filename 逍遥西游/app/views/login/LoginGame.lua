LoginGame = class("LoginGame", CcsSceneView)
LoginGame.Ins = nil
function LoginGame:ctor()
  LoginGame.Ins = self
  LoginGame.super.ctor(self, "views/login.csb")
  local btnBatchListener = {
    btn_startGame = {
      listener = handler(self, self.Btn_StartGame),
      variName = "btn_startGame"
    },
    btn_login_mm = {
      listener = handler(self, self.Btn_LoginChannel),
      variName = "btn_login_mm"
    },
    btn_logout = {
      listener = handler(self, self.Btn_Logout),
      variName = "btn_logout"
    },
    txt_chooseSer = {
      listener = handler(self, self.Btn_ChooseServer),
      variName = "txt_chooseSer"
    },
    txt_back = {
      listener = handler(self, self.Btn_CloseChoose),
      variName = "txt_back"
    },
    btn_mv_play = {
      listener = handler(self, self.Btn_PlayMv),
      variName = "btn_mv_play"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_IsOnlyShowChannel = true
  local btn_start_txt = display.newSprite("views/common/btn/btntxt_enter.png")
  self.btn_startGame:addNode(btn_start_txt)
  btn_start_txt:setPosition(ccp(-3, 20))
  local btn_login_txt = display.newSprite("views/common/btn/btntxt_enter.png")
  self.btn_login_mm:addNode(btn_login_txt)
  btn_login_txt:setPosition(ccp(-3, 20))
  self.pic_bg_center = self:getNode("pic_bg_center")
  self.pic_logo = self:getNode("pic_logo")
  self.layer_curServer = self:getNode("layer_curServer")
  self.txt_corpright = self:getNode("txt_corpright")
  self.txt_version = self:getNode("txt_version")
  self.pic_bg_server = self:getNode("pic_bg_server")
  self.txt_allServer = self:getNode("txt_allServer")
  self.txt_last = self:getNode("txt_last")
  self.m_SerList = self:getNode("list_server")
  self.m_ListItemNodes = {}
  self.layer_curServer:setEnabled(false)
  self.btn_mv_play:setEnabled(false)
  local cgsize = self.btn_mv_play:getContentSize()
  self.txt_cg = CCLabelTTF:create("开场动画", KANG_TTF_FONT, 16)
  self.txt_cg:setAnchorPoint(ccp(1, 0.5))
  self.btn_mv_play:addNode(self.txt_cg)
  self.txt_cg:setPosition(ccp(-8 - cgsize.width / 2, 0))
  self.pic_bg = self:getNode("pic_bg")
  local size = self.pic_bg:getContentSize()
  if size.width < display.width or size.height < display.height then
    self:getNode("pic_bg"):setSize(CCSize(display.width, display.height))
  end
  soundManager.playLoginMusic()
  if false then
    do
      local function clickListener()
        print("-->>:", clickListener)
        require("app.views.commonviews.ShowMomoTest")
        self:getUINode():addChild(ShowMomoTest.new(), 99999)
      end
      local clickObj = TestcreateTxtClickObj(self:getUINode(), 100, 100, "测试陌陌", clickListener, ccc3(255, 0, 0), 255, 99)
    end
  end
  self.m_IsChannelLoginSucceed = false
  self.m_IsShowChooseServerList = false
  self.m_IsLoginSucceed = false
  self.m_IsConnectToDataServer = false
  self:flushObjShow()
  self.m_LastLoginServerId = getLastLoginServerId()
  self.m_LastLoginServerItem = nil
  self.m_LastLoginServerItem = nil
  local ver = g_gameUpdate:getVersion()
  if ver then
    self.txt_version:setText("版本:" .. ver)
  else
    self.txt_version:setEnabled(false)
  end
  self:getNode("txt_corpright"):setVisible(false)
  self:InitServerChoose()
  self:ListenMessage(MsgID_Connect)
  resetLogoSpriteWithSpriteNode(self.pic_logo)
end
function LoginGame:onEnterEvent()
  print("-->> LoginGame:onEnterEvent getCurSceneView():", getCurSceneView())
  self:ConnectDataServer()
end
function LoginGame:ShowLoginNotice(issue, title, notice)
  ShowLoginNoticeInLoginDlg(issue, title, notice)
end
function LoginGame:startAutoLogin()
  print([[

----------------------------
 startAutoLogin]])
  self:ShowWaitingView()
  self.m_IsChannelLoginSucceed = false
  if g_ChannelMgr:Login() == false then
    self:HideWaitingView()
  end
  print("\n")
end
function LoginGame:setShowSerList(isShow)
end
function LoginGame:SetIpAndPort(ip, port, name)
  self.m_Ip = ip
  self.m_Port = port
  if self.m_Ip == nil or self.m_Port == nil then
    self:getNode("ipTxt"):setText("请选择服务器")
  elseif name ~= nil then
    self:getNode("ipTxt"):setText(name)
  else
    self:getNode("ipTxt"):setText("")
  end
end
function LoginGame:onSelected(item, index, listObj)
  print("LoginGame:onSelected(item, index, listObj)", item, index, listObj)
  local tempItem = item.m_UIViewParent
  local ip = tempItem:getIp()
  local port = tempItem:getPort()
  local name = tempItem:getName()
  self:SetIpAndPort(ip, port, name)
end
function LoginGame:OnMessage(msgSID, ...)
  print("\t LoginGame:OnMessage:", msgSID)
  if msgSID == MSGID_Channel_LoginSucceed then
    self.m_IsChannelLoginSucceed = true
    self:LoginChannelSucceed()
  elseif msgSID == MSGID_Channel_LoginCannel or msgSID == MSGID_Channel_LoginFailed then
    print("\t\t MSGID_Channel_LoginCannel ")
    if self.m_IsChannelLoginSucceed == false then
      self:HideWaitingView()
      self.m_IsShowChooseServerList = false
    end
  elseif msgSID == MSGID_Channel_LogoutSucceed then
    scheduler.performWithDelayGlobal(function()
      self:LogoutGame()
    end, 0.01)
  elseif msgSID == MsgID_DataServer_ConnSucceed then
    print("\n 链接数据中心成功， \n")
    self.m_IsConnectToDataServer = true
    if self.m_IsChannelLoginSucceed == true then
      self:_loginToDataServer()
    elseif device.platform == "ios" then
      self:startAutoLogin()
    elseif device.platform == "android" then
      local channelNotAutoLog = {yiwan = 1}
      if g_ChannelMgr and g_ChannelMgr.m_firstLog == true and channelNotAutoLog[g_ChannelMgr:getChannelLabel()] == 1 then
      else
        if g_ChannelMgr then
          g_ChannelMgr.m_firstLog = true
        end
        self:startAutoLogin()
      end
    end
  elseif msgSID == MsgID_DataServer_ConnFailed then
    print("\t\t MsgID_DataServer_ConnFailed, 链接数据中心失败. ")
    self.m_IsConnectToDataServer = false
  elseif msgSID == MsgID_DataServer_ConnLost then
    print("\t\t MsgID_DataServer_ConnLost ")
    self.m_IsConnectToDataServer = false
  elseif msgSID == MsgID_LoginResult then
    print("\t\t MsgID_LoginResult ")
    local arg = {
      ...
    }
    if arg[1] == LOGIN_SUCCEED then
      print("----------------------- 登录数据中心成功 -------------------")
      self.m_IsLoginSucceed = true
    else
      print("----------------------- 登录数据中心失败 -------------------")
      self.m_IsLoginSucceed = false
      self:HideWaitingView()
    end
  elseif msgSID == MsgID_DataServer_SendServerList then
    self:HideWaitingView()
    self:setLastLoginServerItem()
    self:createServerChooseList()
  elseif msgSID == MsgID_HadGetServerList then
    self:createServerChooseList()
    self:flushLastLoginServerItem()
  end
  self:flushObjShow()
end
function LoginGame:AutoReConnect(...)
  self:ConnectDataServer()
end
function LoginGame:ConnectDataServer()
  print([[


------------------------>ConnectDataServer:]])
  if not g_NetConnectMgr:isNetWorkAvailable() then
    g_NetConnectMgr:networkIsNotAvailable(true, function()
      self:ConnectDataServer()
    end)
    return
  end
  self:ShowWaitingView()
  g_NetConnectMgr:ConnectDataServer()
end
function LoginGame:LoginChannelSucceed()
  print("-------- LoginChannelSucceed ----------")
  g_DataMgr:setLoginWithChannel()
  g_NetConnectMgr:TryConnectDataServer(function(isSucceed)
    if isSucceed then
      self:_loginToDataServer()
    else
      g_NetConnectMgr:ConnectDataServer()
    end
  end)
end
function LoginGame:_loginToDataServer()
  self:ShowWaitingView()
  g_DataMgr:StartLoginDataServer()
end
function LoginGame:LogoutGame()
  if self.m_IsChannelLoginSucceed then
    g_ChannelMgr:Logout()
  end
  self.m_IsChannelLoginSucceed = false
  self.m_IsLoginSucceed = false
  self:flushObjShow()
  self:ConnectDataServer()
end
function LoginGame:Clear()
  self.m_LastLoginServerItem = nil
  self.m_ListItemNodes = {}
  if LoginGame.Ins == self then
    LoginGame.Ins = nil
  end
end
function LoginGame:flushObjShow()
  self.btn_mv_play:setEnabled(not self.m_IsShowChooseServerList and self.m_IsLoginSucceed and self.m_IsConnectToDataServer and SyNative.canPlayMovie() ~= false)
  self.btn_startGame:setEnabled(not self.m_IsShowChooseServerList and self.m_IsLoginSucceed and self.m_IsConnectToDataServer)
  self.btn_logout:setEnabled(not self.m_IsShowChooseServerList and self.m_IsLoginSucceed and self.m_IsConnectToDataServer)
  self.btn_login_mm:setEnabled(not self.m_IsShowChooseServerList and not self.m_IsLoginSucceed and self.m_IsConnectToDataServer)
  self.txt_chooseSer:setEnabled(not self.m_IsShowChooseServerList and self.m_IsLoginSucceed and self.m_IsConnectToDataServer)
  self.pic_bg_center:setEnabled(not self.m_IsShowChooseServerList and self.m_IsLoginSucceed and self.m_IsConnectToDataServer)
  self.pic_logo:setEnabled(not self.m_IsShowChooseServerList)
  self.txt_corpright:setEnabled(not self.m_IsShowChooseServerList)
  self.txt_version:setEnabled(not self.m_IsShowChooseServerList)
  self:setShowLastLoginServerItem(self.m_IsLoginSucceed)
  self.pic_bg_server:setEnabled(self.m_IsShowChooseServerList and self.m_IsConnectToDataServer)
  self:flushShowServerChoose()
  self:flushLastLoginServerItem()
end
function LoginGame:setLastLoginServerItem(serverId)
  print("-->> setLastLoginServerItem:", serverId)
  print("-->> self.m_LastLoginServerId:", self.m_LastLoginServerId, type(self.m_LastLoginServerId))
  local serList, ids = g_DataMgr:getServerList()
  local def_serverId
  for id_, data in pairs(serList) do
    if data.def ~= nil then
      def_serverId = id_
    end
  end
  print("-->> def_serverId:", def_serverId)
  if serverId ~= nil then
    self.m_LastLoginServerId = serverId
  elseif def_serverId ~= nil and self.m_LastLoginServerId == nil then
    self.m_LastLoginServerId = def_serverId
  end
  print("-->>Set self.m_LastLoginServerId:", self.m_LastLoginServerId, type(self.m_LastLoginServerId))
  if (self.m_LastLoginServerId == nil or serList[self.m_LastLoginServerId] == nil) and ids then
    self.m_LastLoginServerId = ids[#ids]
  end
  self:flushLastLoginServerItem()
end
function LoginGame:flushLastLoginServerItem()
  local serList = g_DataMgr:getServerList() or {}
  local serData = serList[self.m_LastLoginServerId]
  if serData == nil then
    if self.m_LastLoginServerItem then
      self.m_LastLoginServerItem:setEnabled(false)
    end
    if self.m_LastLoginServerItem_Temp then
      self.m_LastLoginServerItem_Temp:setEnabled(false)
    end
  else
    if self.m_LastLoginServerItem == nil then
      local item = ServerItemCur.new(self.m_LastLoginServerId, nil, true)
      item:ShowPicbgLine(false)
      self:getUINode():addChild(item:getUINode(), 90)
      local x, y = self.layer_curServer:getPosition()
      local size = item:getSize()
      item:setPosition(ccp(x - size.width / 2, y))
      self.m_LastLoginServerItem = item
    else
      self.m_LastLoginServerItem:setServerId(self.m_LastLoginServerId)
    end
    if self.m_LastLoginServerItem_Temp == nil then
      local item = ServerItemCur.new(self.m_LastLoginServerId, nil, false)
      item:ShowPicbgLine(false)
      self:getUINode():addChild(item:getUINode(), 90)
      local x, y = self.layer_curServer:getPosition()
      local size = item:getSize()
      item:setPosition(ccp(x - size.width / 2, y))
      self.m_LastLoginServerItem_Temp = item
    else
      self.m_LastLoginServerItem_Temp:setServerId(self.m_LastLoginServerId)
    end
    local flag = self.pic_bg_server:isEnabled()
    self.m_LastLoginServerItem_Temp:setEnabled(flag)
    self.m_LastLoginServerItem:setEnabled(not flag)
  end
end
function LoginGame:setShowLastLoginServerItem(isShow)
  if self.m_LastLoginServerItem then
    self.m_LastLoginServerItem:setVisible(isShow)
  end
  if self.m_LastLoginServerItem_Temp then
    self.m_LastLoginServerItem_Temp:setVisible(isShow)
  end
end
function LoginGame:InitServerChoose()
  self.m_IsCreateServerList = false
end
function LoginGame:flushShowServerChoose()
  if self.m_IsShowChooseServerList == true and self.m_IsCreateServerList ~= true then
    self:createServerChooseList()
  end
end
function LoginGame:createServerChooseList()
  local serList, ids = g_DataMgr:getServerList()
  local listSize = self.m_SerList:getInnerContainerSize()
  for i, v in ipairs(self.m_ListItemNodes) do
    self.m_SerList:removeChild(v, true)
  end
  self.m_ListItemNodes = {}
  local itemSize
  local evenMask = #ids % 2
  for i = 1, #ids do
    local serverId = ids[i]
    local item = ServerItem.new(serverId, handler(self, self.ServerItemChoosed), false)
    self.m_SerList:addChild(item:getUINode())
    self.m_ListItemNodes[#self.m_ListItemNodes + 1] = item:getUINode()
    if itemSize == nil then
      itemSize = item:getSize()
    end
    local x, y
    if evenMask == i % 2 then
      x = listSize.width / 2 - itemSize.width
    else
      x = listSize.width / 2
    end
    if evenMask == 0 then
      y = itemSize.height * math.floor((i - 1) / 2)
    else
      y = itemSize.height * math.floor(i / 2)
    end
    item:setPosition(ccp(x, y))
  end
  if itemSize == nil then
    itemSize = CCSize(0, 0)
  end
  local itemHeight = itemSize.height * (math.floor((#ids - 1) / 2) + 1)
  if itemHeight > listSize.height then
    self.m_SerList:setInnerContainerSize(CCSize(listSize.width, itemHeight))
  end
  self.m_IsCreateServerList = true
end
function LoginGame:ServerItemChoosed(itemObj, serverId)
  print("LoginGame:ServerItemChoosed:", itemObj, serverId)
  self:setLastLoginServerItem(serverId)
  self:Btn_CloseChoose()
end
function LoginGame:LoginFailed()
  self:LogoutGame()
  self:ConnectDataServer()
end
function LoginGame:Btn_StartGame(obj, t)
  print("==>>LoginGame:Btn_StartGame")
  if self.m_LastLoginServerId == nil then
    ShowNotifyTips("请先选择服务器")
    return
  end
  if g_DataMgr:LoginToServer(self.m_LastLoginServerId) == false then
  end
end
function LoginGame:Btn_LoginChannel(obj, t)
  print("==>>LoginGame:Btn_LoginChannel")
  if channel.useNomogeAccount then
    self:_ShowLoginNmg()
  else
    self:ShowWaitingView()
    self.m_IsChannelLoginSucceed = false
    g_ChannelMgr:Login()
  end
end
function LoginGame:_ShowLoginNmg()
  self:addSubView({
    subView = LoginNmg.new(self),
    zOrder = 99
  })
end
function LoginGame:Btn_Logout(obj, t)
  print("==>>LoginGame:Btn_Logout")
  local function comfirm()
    self:LogoutGame()
  end
  local dlg = dlgChangeAccount.new(comfirm)
  getCurSceneView():addSubView({
    subView = dlg,
    zOrder = MainUISceneZOrder.menuView
  })
end
function LoginGame:Btn_ChooseServer(obj, t)
  print("==>>LoginGame:Btn_ChooseServer")
  self.m_IsShowChooseServerList = true
  self:flushObjShow()
end
function LoginGame:Btn_PlayMv()
  SyNative.playeMovie("res/xiyou/video/xiyou_cg.mp4", function()
  end, true)
end
function LoginGame:Btn_CloseChoose(obj, t)
  print("==>>LoginGame:Btn_CloseChoose")
  self.m_IsShowChooseServerList = false
  self:flushObjShow()
end
dlgChangeAccount = class("dlgChangeAccount", CcsSubView)
function dlgChangeAccount:ctor(okListener, refuseListener)
  dlgChangeAccount.super.ctor(self, "views/changeacount.json", {
    isAutoCenter = true,
    opacityBg = 0,
    clickOutSideToClose = false
  })
  local btnBatchListener = {
    btn_cancel = {
      listener = handler(self, self.Btn_Cancel),
      variName = "btn_cancel"
    },
    btn_ok = {
      listener = handler(self, self.Btn_Ok),
      variName = "btn_ok"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.okListener = okListener
  self.refuseListener = refuseListener
end
function dlgChangeAccount:onEnterEvent()
  self:setVisible(true)
  self.bg = self:getNode("bg")
  local x, y = self.bg:getPosition()
  self.bg:setPosition(ccp(x, y + 100))
  local act1 = CCMoveTo:create(0.3, ccp(x, y))
  self.bg:runAction(CCEaseOut:create(act1, 3))
end
function dlgChangeAccount:Btn_Cancel()
  if self.refuseListener then
    self.refuseListener()
  end
  self:CloseSelf()
end
function dlgChangeAccount:Btn_Ok()
  if self.okListener then
    self.okListener()
  end
  self:CloseSelf()
end
function dlgChangeAccount:Clear()
  self.okListener = nil
  self.refuseListener = nil
end

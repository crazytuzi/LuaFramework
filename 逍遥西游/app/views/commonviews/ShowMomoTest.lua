ShowMomoTest = class("ShowMomoTest", function()
  local widget = Widget:create()
  widget:setAnchorPoint(ccp(0, 0))
  widget:ignoreContentAdaptWithSize(false)
  return widget
end)
function ShowMomoTest:ctor()
  self:setNodeEventEnabled(true)
  self:setTouchEnabled(true)
  self:setSize(CCSize(display.width, display.height))
  local layerC = display.newColorLayer(ccc4(255, 255, 255, 255))
  self:addNode(layerC)
  local btn_x = display.width - 150
  local btn_y = display.height - 30
  local dy = 50
  local dx = 220
  local vLineNum = 10
  local warColor = ccc3(255, 255, 0)
  for i, v in ipairs({
    {
      "btn_quit",
      "退 出",
      handler(self, self.Quit)
    },
    {
      "btn_check",
      "检测登录",
      handler(self, self.CheckLogin)
    },
    {
      "btn_login",
      "登 录",
      handler(self, self.Login)
    },
    {
      "btn_logout",
      "登 出",
      handler(self, self.Logout)
    },
    {
      "btn_setGameServer",
      "设游戏服",
      handler(self, self.setGameServer)
    },
    {
      "btn_showLogo",
      "显示LOGO",
      handler(self, self.showLogo)
    },
    {
      "btn_hideLogo",
      "隐藏LOGO",
      handler(self, self.hideLogo)
    },
    {
      "btn_showPersonalCenter",
      "显示个人中心",
      handler(self, self.showPersonalCenter)
    },
    {
      "btn_getMyPersonalInfo",
      "自己个人信息",
      handler(self, self.getMyPersonalInfo)
    },
    {
      "btn_getMyPersonalInfo",
      "显示资料页面",
      handler(self, self.launchToUserProfile)
    },
    {
      "btn_getOtherPersonalInfo",
      "获取他人信息",
      handler(self, self.getOtherPersonalInfo)
    },
    {
      "btn_getOtherPersonalInfo",
      "FAQ",
      handler(self, self.showFAQView)
    },
    {
      "btn_getOtherPersonalInfo",
      "陌陌吧",
      handler(self, self.showTieba)
    },
    {
      "btn_getOtherPersonalInfo",
      "获取好友",
      handler(self, self.getFriendList)
    },
    {
      "btn_test",
      "测 试",
      handler(self, self.Test)
    },
    {
      "btn_test",
      "语音初始化",
      handler(self, self.InitVoice)
    },
    {
      "btn_test",
      "开始录音",
      handler(self, self.StratRecord)
    },
    {
      "btn_test",
      "结束录音",
      handler(self, self.EndRecord)
    },
    {
      "btn_test",
      "取消录音",
      handler(self, self.CancelRecord)
    },
    {
      "btn_test",
      "百度识别测试",
      handler(self, self.BaiduRecognize)
    },
    {
      "btn_test",
      "渠道:渠道初始化",
      handler(self, self.ChannelInit)
    },
    {
      "btn_test",
      "渠道:是否登录",
      handler(self, self.ChannelIsLogin)
    },
    {
      "btn_test",
      "渠道:登录测试",
      handler(self, self.ChannelLogin)
    },
    {
      "btn_test",
      "渠道:设置服务器",
      handler(self, self.ChannelSetGameServer)
    },
    {
      "btn_test",
      "渠道:发送特殊数据",
      handler(self, self.ChannelSendRoleData)
    },
    {
      "btn_test",
      "渠道:显示悬浮",
      handler(self, self.ChannelShowToolbar)
    },
    {
      "btn_test",
      "渠道:隐藏悬浮",
      handler(self, self.ChannelHideToolbar)
    },
    {
      "btn_test",
      "渠道:个人中心",
      handler(self, self.ChannelEnterPersonCenter)
    },
    {
      "btn_test",
      "渠道:退出登录",
      handler(self, self.ChannelLogout)
    },
    {
      "btn_test",
      "渠道:显示FAQ",
      handler(self, self.ChannelShowFAQView)
    },
    {
      "btn_test",
      "渠道:进入论坛贴吧",
      handler(self, self.ChannelEnterForumOrTieba)
    },
    {
      "btn_test",
      "渠道:获取好友列表",
      handler(self, self.ChannelGetFriendList)
    },
    {
      "btn_test",
      "渠道:增加好友",
      handler(self, self.ChannelAddFriend)
    },
    {
      "btn_test",
      "渠道:分享",
      handler(self, self.ChannelShareToUser)
    },
    {
      "btn_test",
      "渠道:支付",
      handler(self, self.ChannelPay)
    },
    {
      "btn_test",
      "安卓本地推送",
      handler(self, self.AndroidLocalNotification)
    }
  }) do
    local hNum = checkint(math.floor((i - 1) / vLineNum))
    local vNum = i - hNum * vLineNum
    local clickObj = TestcreateTxtClickObj(self, btn_x - hNum * dx, btn_y - vNum * dy, v[2], v[3], v[4], v[5])
    if v[1] and clickObj then
      self[v[1]] = clickObj
    end
  end
end
function ShowMomoTest:CheckLogin()
  local isLogin = g_MomoMgr:getCacheAuthInfo()
  print("g_MomoMgr:getCacheAuthInfo():", g_MomoMgr:getCacheAuthInfo())
end
function ShowMomoTest:Login()
  print("g_MomoMgr:login():", g_MomoMgr:login())
end
function ShowMomoTest:Logout()
  print("g_MomoMgr:Logout():", g_MomoMgr:logout())
end
function ShowMomoTest:setGameServer()
  print("g_MomoMgr:setGameServer():", g_MomoMgr:setGameServer("ios_1"))
end
function ShowMomoTest:Quit()
  self:removeSelf()
end
function ShowMomoTest:showLogo()
  print("g_MomoMgr:showLogo():", g_MomoMgr:setShowMomoLogo(true, MDKLogoPlaceLeftUpper))
end
function ShowMomoTest:hideLogo()
  print("g_MomoMgr:hideLogo():", g_MomoMgr:setShowMomoLogo(false))
end
function ShowMomoTest:showPersonalCenter()
  print("g_MomoMgr:showPersonalCenter():", g_MomoMgr:showPersonalCenter())
end
function ShowMomoTest:getMyPersonalInfo()
  print("g_MomoMgr:getMyPersonalInfo():", g_MomoMgr:getPersonalInfo())
end
function ShowMomoTest:launchToUserProfile()
  print("g_MomoMgr:launchToUserProfile():", g_MomoMgr:launchToUserProfile("TzdTUS9sMHl0MnozUFdjQlZSYlUyZz09"))
end
function ShowMomoTest:getOtherPersonalInfo()
  print("g_MomoMgr:getOtherPersonalInfo():", g_MomoMgr:getPersonalInfo("TzdTUS9sMHl0MnozUFdjQlZSYlUyZz09"))
end
function ShowMomoTest:showFAQView()
  print("g_MomoMgr:showFAQView():", g_MomoMgr:showFAQView())
end
function ShowMomoTest:showTieba()
  print("g_MomoMgr:launchToTieba():", g_MomoMgr:launchToTieba())
end
function ShowMomoTest:getFriendList()
  print("g_MomoMgr:getFriendList():", g_MomoMgr:getFriendList())
end
function ShowMomoTest:Test()
  local fileName = "test.jpg"
  local fileURL = "http://192.168.1.102/album/3A/37/3A37B17B-78D0-16F5-6F0A-543BC1D49E63_L.jpg"
  g_HeadImgRequest:reqHeadImg(fileName, fileURL, function(isSucceed, filePath, fileName_)
    print(" 11 --->> isSucceed, filePath, fileName_:", isSucceed, filePath, fileName_)
    g_HeadImgRequest:reqHeadImg(fileName, fileURL, function(isSucceed, filePath, fileName_)
      print("22 --->> isSucceed, filePath, fileName_:", isSucceed, filePath, fileName_)
    end)
  end)
end
function ShowMomoTest:InitVoice()
  print("ShowMomoTest:InitVoice")
  g_VoiceMgr:InitSDK()
end
function ShowMomoTest:StratRecord()
  print("ShowMomoTest:StratRecord")
  local callback = function(typ, param)
    print("--->> callback:", typ)
    dump(param, "param")
    if typ == 0 then
      local resultStr = param.result
      local pcmString = g_VoiceMgr:getLastRecordData()
      AwardPrompt.addPrompt(resultStr)
      g_VoiceMgr:playPCMString(pcmString)
    elseif typ == 1 then
      print("开始说话")
    elseif typ == 3 then
      AwardPrompt.addPrompt("说话时间过短!")
    elseif typ == 4 then
      AwardPrompt.addPrompt("TOKEN ERROR!")
    elseif typ == 5 then
      local v = param.v
    elseif typ == 6 then
      AwardPrompt.addPrompt(string.format("音量过低,不识别"))
    elseif typ == 7 then
      AwardPrompt.addPrompt(string.format("手动取消识别"))
    elseif typ ~= -1 and typ ~= 8 then
      AwardPrompt.addPrompt(string.format("识别失败!typ = %d", typ))
    end
  end
  g_VoiceMgr:startRecognize(callback)
end
function ShowMomoTest:EndRecord()
  print("ShowMomoTest:EndRecord")
  VoiceInter.stopRecord()
end
function ShowMomoTest:CancelRecord()
  print("ShowMomoTest:CancelRecord")
  VoiceInter.cancelRecord()
end
function ShowMomoTest:BaiduRecognize()
  AwardPrompt.addPrompt("test")
end
function ShowMomoTest:ChannelInit()
  print("g_ChannelMgr:Init-->")
  g_ChannelMgr:Init(function()
    print("--->> init callback")
  end)
end
function ShowMomoTest:ChannelIsLogin()
  print("g_ChannelMgr:isLogined():", g_ChannelMgr:isLogined())
end
function ShowMomoTest:ChannelLogin()
  g_ChannelMgr:Login()
end
function ShowMomoTest:ChannelSetGameServer()
  g_ChannelMgr:setGameServer({
    serverId = "ios_1",
    serverName = "一生所爱",
    roleId = "1",
    roleName = "name"
  })
end
function ShowMomoTest:ChannelSendRoleData()
  g_ChannelMgr:sendRoleInfoAfterLogin({
    roleId = "1",
    roleName = "name",
    roleLv = 99,
    serverId = 1,
    serverName = "一生所爱"
  })
end
function ShowMomoTest:ChannelShowToolbar()
  g_ChannelMgr:showToolBar(ChannelToolBarPlace.kToolBarTopLeft)
end
function ShowMomoTest:ChannelHideToolbar()
  g_ChannelMgr:hideToolBar()
end
function ShowMomoTest:ChannelEnterPersonCenter()
  g_ChannelMgr:enterPersonCenter()
end
function ShowMomoTest:ChannelLogout()
  g_ChannelMgr:Logout()
end
function ShowMomoTest:ChannelShowFAQView()
  g_ChannelMgr:showFAQView()
end
function ShowMomoTest:ChannelEnterForumOrTieba()
  g_ChannelMgr:enterForumOrTieba()
end
function ShowMomoTest:ChannelGetFriendList()
  g_ChannelMgr:getFriendList(function(isSucceed, list)
    print("=============== 获取好友列表回调 ==================")
    print("isSucceed, list:", isSucceed, list)
    dump(list, "好友")
  end)
end
function ShowMomoTest:ChannelAddFriend()
  local userId = "Q2hBUEp5YVN6dlVHOS8vQ28yWkxsUT09"
  local reason = "测试，啦啦啦啦啦"
  g_ChannelMgr:addFriend(userId, function(isSucceed, errorCode, errorMsg)
    print("=============== 增加好友列表回调 ==================")
    print("isSucceed, errorCode, errorMsg:", isSucceed, errorCode, errorMsg)
  end, {reason = reason})
end
function ShowMomoTest:ChannelShareToUser()
  local userId = "Q2hBUEp5YVN6dlVHOS8vQ28yWkxsUT09"
  local contend = "测试，啦啦啦啦啦"
  g_ChannelMgr:shareToUser(userId, function(isSucceed, errorCode, errorMsg)
    print("=============== 分享结果回调 ==================")
    print("isSucceed, errorCode, errorMsg:", isSucceed, errorCode, errorMsg)
  end, contend, {shareType = 1})
end
function ShowMomoTest:ChannelPay()
  if false then
    local channelInterIns = g_ChannelMgr.m_channelInter
    channelInterIns:reqAllProducts()
    return
  end
  local payParam = {
    amount = 300,
    customInfo = string.format("gf=%s#kid=%s#rid=%s#gid=%s", "xiyou", "ios_1", 100002, 1),
    dataId = 2,
    serverId = "ios_1",
    serverName = "servername",
    roleId = 100002,
    roleName = "roleName",
    roleLv = 70
  }
  dump(payParam, "payParam")
  local channelInterIns = g_ChannelMgr.m_channelInter
  channelInterIns:startPay(payParam)
end
function ShowMomoTest:AndroidLocalNotification()
  local name = "test1"
  local msg = "这个测试本地推送1"
  local repeatType = 0
  local time = os.time() + 50
  SyNative.createLocalNotification(name, msg, repeatType, time, badgeNumParam)
end
local MomoTestScene = class("MomoTestScene", CcsSceneView)
function MomoTestScene:ctor()
  MomoTestScene.super.ctor(self, "Widget")
  self:getUINode():addChild(ShowMomoTest.new(), 99999)
end
function ShowMomoTestScene(...)
  MomoTestScene.new():Show()
end

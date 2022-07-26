require"Lang"
TestLogin = {}

function TestLogin.init()
  local ip_Panel = ccui.Helper:seekNodeByName(TestLogin.Widget, "ip_panel")
  local port_Panel = ccui.Helper:seekNodeByName(TestLogin.Widget, "port_panel")
  local account_Panel = ccui.Helper:seekNodeByName(TestLogin.Widget, "account_panel")

  local ip_editBox = cc.EditBox:create(ip_Panel:getContentSize(), cc.Scale9Sprite:create("image/dl_1.png"))
  ip_editBox:setAnchorPoint(cc.p(0, 0))
  ip_editBox:setFontColor(cc.c3b(255, 0, 0))
  ip_editBox:setPlaceHolder(Lang.test_login1)
  ip_Panel:addChild(ip_editBox)

  local port_editBox = cc.EditBox:create(port_Panel:getContentSize(), cc.Scale9Sprite:create("image/dl_1.png"))
  port_editBox:setAnchorPoint(cc.p(0, 0))
  port_editBox:setFontColor(cc.c3b(255, 0, 0))
  port_editBox:setPlaceHolder(Lang.test_login2)
  port_Panel:addChild(port_editBox)

  local account_editBox = cc.EditBox:create(account_Panel:getContentSize(), cc.Scale9Sprite:create("image/dl_1.png"))
  account_editBox:setAnchorPoint(cc.p(0, 0))
  account_editBox:setFontColor(cc.c3b(255, 0, 0))
  account_editBox:setPlaceHolder(Lang.test_login3)
  account_Panel:addChild(account_editBox)
  local ip=cc.UserDefault:getInstance():getStringForKey("ip")
  local port=cc.UserDefault:getInstance():getStringForKey("port")
  local account=cc.UserDefault:getInstance():getStringForKey("account")

  if ip ~= "" and port ~= "" and account ~= "" then
    ip_editBox:setText(ip)
    port_editBox:setText(port)
    account_editBox:setText(account)
  end

  local login_btn = ccui.Helper:seekNodeByName(TestLogin.Widget, "login_btn")
  login_btn:setPressedActionEnabled(true)
  local function loginEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
      AudioEngine.playEffect("sound/button.mp3")
      if string.len(ip_editBox:getText()) > 0 and string.len(port_editBox:getText()) > 0 and string.len(account_editBox:getText()) > 0 then
        cc.UserDefault:getInstance():setStringForKey("ip",ip_editBox:getText())
        cc.UserDefault:getInstance():setStringForKey("port",port_editBox:getText())
        cc.UserDefault:getInstance():setStringForKey("account",account_editBox:getText())
        net.connect(ip_editBox:getText(), tonumber(port_editBox:getText()), account_editBox:getText(),nil)
      else
        if string.len(ip_editBox:getText()) == 0 then
          UIManager.showToast(Lang.test_login4)
        elseif string.len(port_editBox:getText()) == 0 then
          UIManager.showToast(Lang.test_login5)
        else
          UIManager.showToast(Lang.test_login6)
        end
      end
    end
  end
  login_btn:addTouchEventListener(loginEvent)

  require "svnversion"
  local versionLabel = ccui.Text:create()
  versionLabel:setString("version:" .. SVN_VERSION)
  versionLabel:setFontSize(23)
  versionLabel:setTextColor(cc.c4b(255, 255, 255, 255))
  versionLabel:setPosition(cc.p(UIManager.screenSize.width / 2, versionLabel:getContentSize().height))
  TestLogin.Widget:addChild(versionLabel)
  AudioEngine.playMusic("sound/login.mp3", true)
end

function TestLogin.setup()
 --  local function callBackFunc( ... )
 --    UIGuidePeople.addGuideUI(TestLogin,ccui.Helper:seekNodeByName(TestLogin.Widget, "login_btn"),0,callBackFunc)
 --  end
	-- UIGuidePeople.addGuideUI(TestLogin,ccui.Helper:seekNodeByName(TestLogin.Widget, "login_btn"),0,callBackFunc)
end

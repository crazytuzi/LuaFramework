
local QUIDialog = import(".QUIDialog")
local QUIDialogGameLogin = class("QUIDialogGameLogin", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUserData = import("...utils.QUserData")

function QUIDialogGameLogin:ctor(options)
    local ccbFile = "ccb/Dialog_GameLogin.ccbi"
    local callBacks = {
        {ccbCallbackName = "onLogin", callback = handler(self, QUIDialogGameLogin.onLogin)},
        {ccbCallbackName = "onRemember", callback = handler(self, QUIDialogGameLogin.onRemember)},
        {ccbCallbackName = "onWaiwang", callback = handler(self, QUIDialogGameLogin.onWaiwang)},
        {ccbCallbackName = "onPullDown", callback = handler(self, QUIDialogGameLogin.onPullDown)},
        {ccbCallbackName = "onRegister", callback = handler(self, QUIDialogGameLogin.onRegister)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogGameLogin.onClose)},
    }
    QUIDialogGameLogin.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = false
    self._ccbOwner.btn_logingame:setEnabled(false)
    self._ccbOwner.btn_logingame:setHighlighted(true)
    self._ccbOwner.btn_reg:setHighlighted(false)
    self._ud = app:getUserData()
    self._remember = false
    
    q.setButtonEnableShadow(self._ccbOwner.btn_close)
    q.setButtonEnableShadow(self._ccbOwner.btn_denglu)
    q.setButtonEnableShadow(self._ccbOwner.btn_down)
    --账号框
    self._edit1 = ui.newEditBox({
        image = "ui/none.png",
        listener = QUIDialogGameLogin.onEdit,
        size = CCSize(414, 42)})
    self._edit1:setFont(global.font_name, 26)
    self._edit1:setReturnType(kKeyboardReturnTypeDone)
    --密码框
    self._edit2 = ui.newEditBox({
        image = "ui/none.png",
        listener = QUIDialogGameLogin.onEdit,
        size = CCSize(464, 42)})
    self._edit2:setFont(global.font_name, 26)
    self._edit2:setInputFlag(kEditBoxInputFlagPassword)
    self._edit2:setReturnType(kKeyboardReturnTypeGo)
    self._edit1:setPositionX(5)
    self._edit2:setPositionX(27)
    self._edit2:setPositionY(-2)
    self._ccbOwner.node_account:addChild(self._edit1)
    self._ccbOwner.node_pass1:addChild(self._edit2)

    if options then
        self:setAccount(options.acc)
        self._remember = options.rem
    end

    
    local account = self._ud:getValueForKey(QUserData.USER_NAME)
    local accounts = {account}
    self._accounts = accounts
    self._edits = {}
    self.node_account = CCNode:create()
    self._ccbOwner.node_account:addChild(self.node_account)
    local starty = self._ccbOwner.node_account:getPositionY() + 142
    --设置下拉框记录的帐号
    for i = 1, #accounts
    do
        local str = accounts[i]
        self._edits[i] = CCLayerColor:create(ccc4(50, 0, 0, 128 + i *10), 414, 48)
        self._edits[i]:setAnchorPoint(ccp(0.5,0.5))
        self._edits[i]:setPositionX(-202)
       
        self._edits[i]:setTouchEnabled(true)
        self._edits[i]:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
        self._edits[i]:setTouchSwallowEnabled(true)
        self._edits[i]:addNodeEventListener(cc.NODE_TOUCH_EVENT, function()
                self._edit1:setText(self._accounts[i])
                self.node_account:setVisible(false)
            end)

        self._edits[i].label = CCLabelTTF:create()
        self._edits[i].label:setString(str)
        self._edits[i].label:setColor(ccc3(84,36,6))
        self._edits[i].label:setFontSize(30)
        self._edits[i].label:setPositionX(150)
        self._edits[i].label:setPositionY(24)

        self.node_account:addChild(self._edits[i])
        self._edits[i]:addChild(self._edits[i].label)

        self._edits[i]:setPositionY(starty - (i)*48 - 26)
        self._edits[i]:setZOrder(10)
    end
    self.node_account:setVisible(false)

    -- self._ccbOwner.node_root:setTouchEnabled(true)
    -- self._ccbOwner.node_root:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    -- self._ccbOwner.node_root:setTouchSwallowEnabled(true)
    -- self._ccbOwner.node_root:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QUIDialogGameLogin.onTouchRoot))

    self._ccbOwner.node_rem:setTouchEnabled(true)
    self._ccbOwner.node_rem:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    self._ccbOwner.node_rem:setTouchSwallowEnabled(true)
    self._ccbOwner.node_rem:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QUIDialogGameLogin.onTouchRem))
    if self._remember == true then
        self._ccbOwner.btn_rem:setHighlighted(true)
    else
        self._ccbOwner.btn_rem:setHighlighted(false)
    end

    if self._ud:getValueForKey(QUserData.WAIWANG_LOGIN) == QUserData.STRING_TRUE then
        local acc = self._ud:getValueForKey(QUserData.USER_NAME)
        local pass = self._ud:getValueForKey(QUserData.PASSWORD)
        self._edit1:setText(acc)
        self._edit2:setText(pass)
        self:onWaiwang()
    end
end

function QUIDialogGameLogin:onTouchRem(event)
    if event.name == "began" then
        self._remember = not self._remember
        if self._remember == true then
            self._ccbOwner.btn_rem:setHighlighted(true)
        else
            self._ccbOwner.btn_rem:setHighlighted(false)
        end
        return true
    end
end

function QUIDialogGameLogin:onTouchRoot(event)
    if event.name == "began" then
    
        return true
    end
end

function QUIDialogGameLogin:setAccount(str)
    self._edit1:setText(str)
end

function QUIDialogGameLogin:onEdit(editbox)
    --self._edit1:setText(editbox:getText())
    --self.node_account:setVisible(false)
    --printInfo("%s", editbox:getText())
end

function QUIDialogGameLogin:viewDidAppear()
    QUIDialogGameLogin.super.viewDidAppear(self)
    self._remoteProxy = cc.EventProxy.new(remote)
end

function QUIDialogGameLogin:viewWillDisappear()
    QUIDialogGameLogin.super.viewWillDisappear(self)
    self._remoteProxy:removeAllEventListeners()
    -- self._ccbOwner.node_rem:removeAllEventListeners()
    -- for _,value in pairs(self._edits) do
    --     value:removeAllEventListeners()
    -- end
end

function QUIDialogGameLogin:onEvent(event)
    if event == nil or event.name == nil then
        return
    end
end

function QUIDialogGameLogin:onRegister()
    app.sound:playSound("common_menu")
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
    return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRegister"})
end

function QUIDialogGameLogin:onClose()
    app.sound:playSound("common_small")
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
    return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogEnterGame"})
end

function QUIDialogGameLogin:onRemember()
    app.sound:playSound("common_small")
    self._remember = not self._remember
    if self._remember == true then
        self._ccbOwner.btn_rem:setHighlighted(true)
    else
        self._ccbOwner.btn_rem:setHighlighted(false)
    end
end

function QUIDialogGameLogin:onWaiwang( ... )
    app.sound:playSound("common_small")
    self._waiwang = not self._waiwang
    if self._waiwang == true then
        self._ccbOwner.btn_waiwang:setHighlighted(true)
        self._ccbOwner.tf_account:setString("账号")
        self._ccbOwner.tf_pwd:setString("服务器")
        self._ccbOwner.node_jizhumima:setVisible(false)
    else
        self._ccbOwner.btn_waiwang:setHighlighted(false)
        self._ccbOwner.tf_account:setString("账号")
        self._ccbOwner.tf_pwd:setString("密码")
        self._ccbOwner.node_jizhumima:setVisible(true)
    end
end

function QUIDialogGameLogin:onPullDown()
    self.node_account:setVisible(true)
end

function QUIDialogGameLogin:onLogin()
    app.sound:playSound("common_small")
    local acc = self._edit1:getText()
    local pass = self._edit2:getText()
    if #acc == 0 then
        app.tip:floatTip("账号不能为空!")
        return 
    end
    if #pass == 0 and not self._waiwang then
        app.tip:floatTip("密码不能为空!")
        return 
    end
    if not self._waiwang then
        pass = crypto.md5(pass)
        if self._remember == true then
            self._ud:setValueForKey(QUserData.USER_NAME, acc)
            app:getUserOperateRecord():resetRecord()
            self._ud:setValueForKey(QUserData.PASSWORD, pass)
            self._ud:setValueForKey(QUserData.AUTO_LOGIN, QUserData.STRING_TRUE)
            self._ud:setValueForKey(QUserData.WAIWANG_LOGIN, QUserData.STRING_FALSE)
        else
            self._ud:setValueForKey(QUserData.AUTO_LOGIN, QUserData.STRING_FALSE)
            self._ud:setValueForKey(QUserData.WAIWANG_LOGIN, QUserData.STRING_FALSE)
        end
        app:_login(acc, pass)
        app:getNavigationManager():getController(app.mainUILayer):setDialogOptions({acc = acc})
    else
        local loginStr = string.split(acc, "|")
        if #loginStr ~= 3 then
            app.tip:floatTip("必须包含用户ID，游戏区ID，渠道ID，并以‘ | ’分割")
            return
        end
        acc = loginStr[1]
        pass = loginStr[2]
        local channel = loginStr[3]
        self._ud:setValueForKey(QUserData.USER_NAME, acc.."|"..pass.."|"..channel)
        app:getUserOperateRecord():resetRecord()
        self._ud:setValueForKey(QUserData.PASSWORD, "")
        self._ud:setValueForKey(QUserData.AUTO_LOGIN, QUserData.STRING_FALSE)
        self._ud:setValueForKey(QUserData.WAIWANG_LOGIN, QUserData.STRING_TRUE)
        QUICK_LOGIN.isQuick = true
        QUICK_LOGIN.osdkUserId = acc
        QUICK_LOGIN.gameArea = pass
        QUICK_LOGIN.channel = channel
        QUICK_LOGIN.deviceId = 88888888
        SERVER_URL = "222.50.52.51:9228"

        local serverInfo = {}
        serverInfo.serverId = "localhost"
        remote.selectServerInfo = serverInfo

        app:loginByQuickUser()
    end
end

return QUIDialogGameLogin
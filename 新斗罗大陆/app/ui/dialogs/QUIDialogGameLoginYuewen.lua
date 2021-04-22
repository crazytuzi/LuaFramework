
local QUIDialog = import(".QUIDialog")
local QUIDialogGameLoginYuewen = class("QUIDialogGameLoginYuewen", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUserData = import("...utils.QUserData")

function QUIDialogGameLoginYuewen:ctor(options)
    local ccbFile = "ccb/Dialog_GameLogin_Yuewen.ccbi"
    local callBacks = {
        {ccbCallbackName = "onLogin", callback = handler(self, QUIDialogGameLoginYuewen.onLogin)},
        {ccbCallbackName = "onRemember", callback = handler(self, QUIDialogGameLoginYuewen.onRemember)},
        {ccbCallbackName = "onWaiwang", callback = handler(self, QUIDialogGameLoginYuewen.onWaiwang)},
        {ccbCallbackName = "onPullDown", callback = handler(self, QUIDialogGameLoginYuewen.onPullDown)},
        {ccbCallbackName = "onRegister", callback = handler(self, QUIDialogGameLoginYuewen.onRegister)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogGameLoginYuewen.onClose)},
        {ccbCallbackName = "onGetValidate", callback = handler(self, QUIDialogGameLoginYuewen.onGetValidate)},
    }
    QUIDialogGameLoginYuewen.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = false
    self._remember = false
    

    --账号框
    self._edit1 = ui.newEditBox({
        image = "ui/none.png",
        listener = QUIDialogGameLoginYuewen.onEdit,
        size = CCSize(320, 48)})
    self._edit1:setReturnType(kKeyboardReturnTypeDone)
    self._edit1:setFont(global.font_name, 26)
    --密码框
    self._edit2 = ui.newEditBox({
        image = "ui/none.png",
        listener = QUIDialogGameLoginYuewen.onEdit,
        size = CCSize(370, 48)})
    self._edit2:setInputFlag(kEditBoxInputFlagPassword)
    self._edit2:setReturnType(kKeyboardReturnTypeGo)
    self._edit2:setFont(global.font_name, 26)
    --验证码框
    self._edit3 = ui.newEditBox({
        image = "ui/none.png",
        listener = QUIDialogGameLoginYuewen.onEdit,
        size = CCSize(320, 48)})
    self._edit3:setInputFlag(kKeyboardReturnTypeDone)
    self._edit3:setFont(global.font_name, 26)
    
    self._edit1:setPositionX(-25)
    self._ccbOwner.node_account:addChild(self._edit1)
    self._ccbOwner.node_pass1:addChild(self._edit2)
    self._ccbOwner.node_validate:addChild(self._edit3)
    self._ccbOwner.node_denglu:setVisible(false)
    self._validateOriginalTexture = self._ccbOwner.sprite_validate:getTexture()
    self._validateOriginalTexture:retain()

    self.module = options.module
end

function QUIDialogGameLoginYuewen:displayValidateCode(validateCodeFilePath)
    self._ccbOwner.node_denglu:setVisible(true)
    self._ccbOwner.sprite_validate:setTexture(self._validateOriginalTexture)
    CCTextureCache:sharedTextureCache():removeUnusedTextures()
    self._ccbOwner.sprite_validate:setTexture(CCTextureCache:sharedTextureCache():addImage(validateCodeFilePath))
end

function QUIDialogGameLoginYuewen:onGetValidate(event)
    local phoneNumber = self._edit1:getText()
    local password = self._edit2:getText()
    if #phoneNumber == 0 or #password == 0 then
        CCMessageBox("", "请输入用户名和密码")
        return
    end
    self.module.onGetValidate(phoneNumber, password)
end

function QUIDialogGameLoginYuewen:onLogin()
    local validateCode = self._edit3:getText()
    if #validateCode == 0 then
        CCMessageBox("", "请输入验证码")
        return
    end
    self.module.onLogin(validateCode)
end

function QUIDialogGameLoginYuewen:onClose()
    app.sound:playSound("common_small")
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogGameLoginYuewen:onTouchRem(event)

end

function QUIDialogGameLoginYuewen:onTouchRoot(event)

end

function QUIDialogGameLoginYuewen:setAccount(str)

end

function QUIDialogGameLoginYuewen:onEdit(editbox)

end

function QUIDialogGameLoginYuewen:viewDidAppear()
    QUIDialogGameLoginYuewen.super.viewDidAppear(self)
end

function QUIDialogGameLoginYuewen:viewWillDisappear()
    QUIDialogGameLoginYuewen.super.viewWillDisappear(self)

    self.module.onClose()
    self._validateOriginalTexture:release()
    self.module = nil
    self._validateOriginalTexture = nil
end

function QUIDialogGameLoginYuewen:onEvent(event)

end

function QUIDialogGameLoginYuewen:onRegister()

end

function QUIDialogGameLoginYuewen:onRemember()

end

function QUIDialogGameLoginYuewen:onWaiwang( ... )

end

function QUIDialogGameLoginYuewen:onPullDown()

end

return QUIDialogGameLoginYuewen
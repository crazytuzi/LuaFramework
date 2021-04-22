--
-- Kumo.Wang
-- zhangbichen主题曲活动——暂停界面
--

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogZhangbichenMusicGamePause = class("QUIDialogZhangbichenMusicGamePause", QUIDialog)

function QUIDialogZhangbichenMusicGamePause:ctor(options) 
 	local ccbFile = "ccb/Dialog_Music_Game_Pause.ccbi"
	local callBacks = {
	    {ccbCallbackName = "onAbort", callback = handler(self, self._onAbort)},
        {ccbCallbackName = "onContinue", callback = handler(self, self._onContinue)},
	    {ccbCallbackName = "onRestart", callback = handler(self, self._onRestart)},
	}
	QUIDialogZhangbichenMusicGamePause.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = false
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if page then
        if page.setAllUIVisible then page:setAllUIVisible(false) end
        if page.setScalingVisible then page:setScalingVisible(false) end
        if page.topBar then page.topBar:hideAll() end
        if page.setBackBtnVisible then page:setBackBtnVisible(false) end
        if page.setHomeBtnVisible then page:setHomeBtnVisible(false) end
    end
	self._ccbOwner.frame_tf_title:setString("演出暂停")
    
    q.setButtonEnableShadow(self._ccbOwner.btn_restart)
    q.setButtonEnableShadow(self._ccbOwner.btn_abort)
    q.setButtonEnableShadow(self._ccbOwner.btn_continue)
    q.setButtonEnableShadow(self._ccbOwner.btn_close)

    self._chooseType = 1 -- 1，继续游戏；2，放弃关卡；3，重新开始

	if options then
		self._callback = options.callback
	end
end

function QUIDialogZhangbichenMusicGamePause:viewAnimationInHandler()
end

function QUIDialogZhangbichenMusicGamePause:viewDidAppear()
    QUIDialogZhangbichenMusicGamePause.super.viewDidAppear(self)
end

function QUIDialogZhangbichenMusicGamePause:viewAnimationOutHandler()
	self:popSelf()

	if self._callback then
		self._callback(self._chooseType)
	end
end

function QUIDialogZhangbichenMusicGamePause:viewWillDisappear()
    QUIDialogZhangbichenMusicGamePause.super.viewWillDisappear(self)
end

-- function QUIDialogZhangbichenMusicGamePause:_backClickHandler()
--     self:_onContinue()
-- end

function QUIDialogZhangbichenMusicGamePause:_onRestart(e)
    -- 重新开始
    app.sound:playSound("common_small")
    self._chooseType = 3
    self:playEffectOut()
end

function QUIDialogZhangbichenMusicGamePause:_onAbort(e)
    -- 放弃关卡
    app.sound:playSound("common_small")
    self._chooseType = 2
    self:playEffectOut()
end

function QUIDialogZhangbichenMusicGamePause:_onContinue(e)
    -- 继续游戏
    if e then
        app.sound:playSound("common_small")
    end
    self._chooseType = 1
    self:playEffectOut()
end

return QUIDialogZhangbichenMusicGamePause
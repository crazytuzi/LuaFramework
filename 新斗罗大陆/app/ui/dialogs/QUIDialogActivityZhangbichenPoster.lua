--
-- Kumo.Wang
-- zhangbichen主题曲正式活动的弹脸
--

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogActivityZhangbichenPoster = class("QUIDialogActivityZhangbichenPoster", QUIDialog)

function QUIDialogActivityZhangbichenPoster:ctor(options)
	local ccbFile = "ccb/Dialog_Zhangbichen_Formal_Poster.ccbi"
    local callBacks = {}
    QUIDialogActivityZhangbichenPoster.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callback = options.callback
    end
    self._isEnd = false
    self._timeScheduler = scheduler.performWithDelayGlobal(function()
            self._isEnd = true
        end, 1.5)
    
    remote.user.needShowThemeFormalPicture = false
end

function QUIDialogActivityZhangbichenPoster:viewDidAppear()
	QUIDialogActivityZhangbichenPoster.super.viewDidAppear(self)
end

function QUIDialogActivityZhangbichenPoster:viewWillDisappear()
  	QUIDialogActivityZhangbichenPoster.super.viewWillDisappear(self)
end


function QUIDialogActivityZhangbichenPoster:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogActivityZhangbichenPoster:_onTriggerClose()
    if self._isEnd == false then 
        return 
    end
	self:playEffectOut()
end

function QUIDialogActivityZhangbichenPoster:viewAnimationOutHandler()
	local callback = self._callback

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogActivityZhangbichenPoster

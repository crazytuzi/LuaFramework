

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogFullScreenIntroDialog = class("QUIDialogFullScreenIntroDialog", QUIDialog)


function QUIDialogFullScreenIntroDialog:ctor(options)
	local ccbFile = "ccb/Dialog_FullScreen_Intro.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }

    QUIDialogFullScreenIntroDialog.super.ctor(self, ccbFile, callBacks, options)
	--self._isTouchSwallow = false
	if options.callback then
		self._callback = options.callback
	end

    self.isAnimation = true

end


function QUIDialogFullScreenIntroDialog:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogFullScreenIntroDialog:_onTriggerClose()
  	app.sound:playSound("common_close")
	if self._callback then
		self._callback()
	end
	self:playEffectOut()   	
end


function QUIDialogFullScreenIntroDialog:_onTriggerToSet()
	if self._callback then
		self._callback()
	end
	self:playEffectOut()  
end

return QUIDialogFullScreenIntroDialog

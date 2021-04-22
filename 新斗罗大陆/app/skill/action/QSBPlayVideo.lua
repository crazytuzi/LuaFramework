local QSBAction = import(".QSBAction")
local QSBPlayVideo = class("QSBPlayVideo", QSBAction)

function QSBPlayVideo:_execute(dt)
	if self._isExecuting == true then
		return
	end

	if IsServerSide then
		self:finished()
		return
	end

	app.scene:playSkillVideo(self._options.image, self._options.video, handler(self, self.finished))

    self._isExecuting = true
end

function QSBPlayVideo:_onCancel()
	self:_onRevert()
end

function QSBPlayVideo:_onRevert()

end

return QSBPlayVideo
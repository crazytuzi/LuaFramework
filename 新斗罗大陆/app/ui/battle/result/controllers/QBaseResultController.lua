local QBaseResultController = class("QBaseResultController")

function QBaseResultController:ctor(options)
	self._isMoveEnd = false
end

function QBaseResultController:requestResult(isWin)
	-- body
end

function QBaseResultController:onMoveCompleted()
	self._isMoveEnd = true
	self:checkEnd()
end

function QBaseResultController:setResponse(data)
	self.response = data
	self:checkEnd()
end

--通讯出错
function QBaseResultController:requestFail(data)
	local scene = self:getScene()
	scene:requestFail(data)
end

function QBaseResultController:checkEnd()
	if self._isMoveEnd == true and self.response ~= nil then
		self:fightEndHandler()
	end
end

function QBaseResultController:fightEndHandler()
	
end

function QBaseResultController:getCallTbl()
	local scene = self:getScene()
	local tbl = {}
	tbl.onChoose = handler(scene, scene._checkTeamUp)
	tbl.onRestart = handler(scene, scene._onRestart)
	tbl.onNext = handler(scene, scene._onNext)
	return tbl
end

function QBaseResultController:getLoseCallTbl()
	local scene = self:getScene()
	local tbl = {}
	tbl.onChoose = handler(scene, scene._onAbort)
	tbl.onRestart = handler(scene, scene._onRestart)
	tbl.onNext = handler(scene, scene._onNext)
	return tbl
end

function QBaseResultController:getSilvesCallTbl()
	local scene = self:getScene()
	local tbl = {}
	tbl.onNext = handler(scene, scene._onAbort)
	tbl.onRestart = handler(scene, scene._onRestart)
	return tbl
end

function QBaseResultController:getScene()
	return CCDirector:sharedDirector():getRunningScene()
end

function QBaseResultController:removeAll()
	
end

return QBaseResultController
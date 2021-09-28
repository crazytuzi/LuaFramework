--TrivialBook.lua
--简单副本

TrivialBook = class(CopyBook)



function TrivialBook:__init()
	self._callFriendMon = 0
	self._currCircle = 1
end

function TrivialBook:setStartTime()
	self._startTime = os.time()
end


function TrivialBook:doReward(newTime)

end


function TrivialBook:clearBook()
	local currInstId = self:getCurrInsId()				--当前副本ID

	local roleID = self._playerID
	local player = g_entityMgr:getPlayer(self._playerID)		--单人副本记录的玩家ID
	local copyPlayer = g_copyMgr:getCopyPlayer(self._playerID)	--玩家的副本数据
	if copyPlayer and player and copyPlayer:getCurCopyInstID() == currInstId then
		--用完要清空
		g_copyMgr:dealExitCopy(player, copyPlayer)
		g_copySystem:fireMessage(COPY_CS_EXITCOPY, roleID, EVENT_COPY_SETS, COPY_MSG_EXITCOPY, 0)
	else
		print("TrivialBook:clearBook, invalid _playerID")
		g_copyMgr:releaseCopy(currInstId, self:getPrototype():getCopyType())
	end
end
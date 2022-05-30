local GameModel = {}

local socket = require "socket"


GameModel.friendActive = 0

GameModel.deltaTime = 0 --每次心跳尝试更新本地时间与服务器时间的差值


function GameModel.updateData(rtnObjData)
	-- dump(rtnObjData, "心跳数据", 8)
	
	if rtnObjData ~= nil then
		
		if rtnObjData.serverTime ~= nil then
			--这个是毫秒

			local serverTime = rtnObjData.serverTime/1000
			GameModel.deltaTime = serverTime - GameModel.getLocalTimeInSec()
		end
		
		if rtnObjData.friend  ~= nil and GameModel.friendActive ~= rtnObjData.friend then
			GameModel.friendActive = rtnObjData.friend
			PostNotice(NoticeKey.UP_FRIEND_ICON_ACT)
		end
		
		if rtnObjData.applyNum ~= nil then
			game.player:setGuildApplyNum(rtnObjData.applyNum)
			PostNotice(NoticeKey.CHECK_GUILD_APPLY_NUM)
			PostNotice(NoticeKey.CHECK_IS_SHOW_APPLY_NOTICE)
		end
	end
	
end

function GameModel.refreshNotice()
	PostNotice(NoticeKey.UP_FRIEND_ICON_ACT)
end

function GameModel.isFriendActive()
	if GameModel.friendActive == 1 then
		return true
	else
		return false
	end
end

function GameModel.getLocalTimeInSec()
	-- exp: 1421305828.5676 单位为秒,毫秒为小数位
	local curTimeInSec = socket:gettime()
	return curTimeInSec
end


function GameModel.getServerTimeInSec()
	return GameModel.getLocalTimeInSec() + GameModel.deltaTime
end

function GameModel.getRestTimeInSec(endTime)
	--传入活动截止时间，返回剩余时间

	--单位为秒
	return endTime - GameModel.getServerTimeInSec()
end

function GameModel.getRestTimeInMS(endTimeInMS)
	--这个传入的时间为毫秒
	return GameModel.getRestTimeInSec(endTimeInMS/1000)
end


return GameModel
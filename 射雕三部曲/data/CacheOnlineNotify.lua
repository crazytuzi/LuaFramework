--[[
	文件名: CacheOnlineNotify.lua
	描述: 上线通知缓存数据
	创建人: heguanghui
	创建时间: 2017.09.5
--]]

-- 上线通知数据说明
--[[
    本地缓存的上线通知数据格式为：
    {
		[playerId] = {  -- 一个游戏账号保存的上线通知列表
	        "01e122a1-f678-4477-86c5-ca9c7cd24ebb",	-- 玩家ID
	        "01e122a1-f678-4477-86c5-ca9c7cd24ebb"
			...
	    }

	    ....
    }    
]]

local CacheOnlineNotify = class("CacheOnlineNotify", {})

--[[
]]
function CacheOnlineNotify:ctor()
    self.mOnlineNotifyData = LocalData:getOnlineNotifyData()
end

-- 添加上线通知玩家
--[[
-- 参数
	onlinePlayerId: 玩家的playerId
]]
function CacheOnlineNotify:addOnlineNotify(onlinePlayerId)
	if not onlinePlayerId then
		return 
	end

	local playerId = PlayerAttrObj:getPlayerInfo().PlayerId
	self.mOnlineNotifyData = self.mOnlineNotifyData or {}
	self.mOnlineNotifyData[playerId] = self.mOnlineNotifyData[playerId] or {}
	local foundOld = false
	for _, item in pairs(self.mOnlineNotifyData[playerId]) do
		if item == onlinePlayerId then
			foundOld = true
			break
		end
	end
	if not foundOld then
		table.insert(self.mOnlineNotifyData[playerId], onlinePlayerId)
		ui.showFlashView(TR("已加入上线通知"))
	end
	LocalData:saveOnlineNotifyData(self.mOnlineNotifyData)
end

-- 删除上线通知玩家
--[[
-- 参数
	onlinePlayerId: 需要移除的上线通知玩家Id
]]
function CacheOnlineNotify:deleteOnlineNotify(onlinePlayerId)
	local playerId = PlayerAttrObj:getPlayerInfo().PlayerId

	for index, item in pairs(self.mOnlineNotifyData and self.mOnlineNotifyData[playerId] or {}) do
		if item == onlinePlayerId then
			table.remove(self.mOnlineNotifyData[playerId], index)
			LocalData:saveOnlineNotifyData(self.mOnlineNotifyData)
			ui.showFlashView(TR("已从上线通知移除"))
			break
		end
	end
end

-- 判断一个玩家是否在上线通知中
--[[
-- 参数
	onlinePlayerId: 玩家Id
-- 返回值
	如果是上线通知玩家返回true，否则返回false
]]
function CacheOnlineNotify:isOnlineNotifyPlayer(onlinePlayerId)
	local playerId = PlayerAttrObj:getPlayerInfo().PlayerId

	for _, item in pairs(self.mOnlineNotifyData and self.mOnlineNotifyData[playerId] or {}) do
		if item == onlinePlayerId then
			return true
		end
	end
	return false
end

-- 获取上线通知玩家列表
function CacheOnlineNotify:getOnlineNotifyList()
	local playerId = PlayerAttrObj:getPlayerInfo().PlayerId

	return self.mOnlineNotifyData[playerId] or {}
end

return CacheOnlineNotify


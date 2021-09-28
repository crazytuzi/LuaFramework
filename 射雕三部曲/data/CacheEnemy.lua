--[[
	文件名: CacheEnemy.lua
	描述: 黑名单缓存数据
	创建人: liaoyuangang
	创建时间: 2017.03.15
--]]

-- 黑名单数据说明
--[[
    本地缓存的黑名单数据格式为：
    {
		[playerId] = {  -- 一个游戏账号保存的黑名单列表
	        { -- 单个黑名单玩家信息
			    Id = "01e122a1-f678-4477-86c5-ca9c7cd24ebb",  -- 被列为黑名单的玩家实体Id
			    ServerGroupId = 20008,  -- 所在服务器组Id
			    ServerName = "开发测试服", -- 服务器名
			    ExtendInfo = { -- 额外信息
			    	-- 额外信息的版本号
				    Version = 1,

				    -- 玩家信息
				    Name = "lyg101",
				    HeadImageId = 12010002,
				    FashionModelId = 0,
				    FAP = 129966,
				    Lv = 51,
				    Vip = 15,
				    PVPInterLv = 0,
				    DesignationId = 0,

				    -- 公会信息
				    GuildId = "b369dd2e-83fc-4345-a516-92afaf0f3de7",
					GuildName = "lyg101",  -- 所在公会名称
				    UnionPostId = 34001001,
			    }
			}
			...
	    }

	    ....
    }    
]]

local CacheEnemy = class("CacheEnemy", {})

--[[
]]
function CacheEnemy:ctor()
    self.mEnemyData = LocalData:getEnemyData()
end

-- 添加黑名单玩家
--[[
-- 参数
	enemyPlayerInfo: 聊天服务器返回的聊天信息中的玩家信息，详细数据结构参考文件头处的注释
]]
function CacheEnemy:addEnemy(enemyPlayerInfo)
	if not enemyPlayerInfo then
		return 
	end

	local playerId = PlayerAttrObj:getPlayerInfo().PlayerId
	self.mEnemyData = self.mEnemyData or {}
	self.mEnemyData[playerId] = self.mEnemyData[playerId] or {}
	local foundOld = false
	for index, item in pairs(self.mEnemyData[playerId]) do
		if item.Id == enemyPlayerInfo.Id then
			self.mEnemyData[playerId][index] = enemyPlayerInfo
			foundOld = true
			break
		end
	end
	if not foundOld then
		table.insert(self.mEnemyData[playerId], enemyPlayerInfo)
		ui.showFlashView(TR("已加入黑名单"))
	end
	
	LocalData:saveEnemyData(self.mEnemyData)
end

-- 删除黑名单玩家
--[[
-- 参数
	enemyPlayerId: 需要移除的黑名单玩家Id
]]
function CacheEnemy:deleteEnemy(enemyPlayerId)
	local playerId = PlayerAttrObj:getPlayerInfo().PlayerId

	for index, item in pairs(self.mEnemyData and self.mEnemyData[playerId] or {}) do
		if item.Id == enemyPlayerId then
			table.remove(self.mEnemyData[playerId], index)
			LocalData:saveEnemyData(self.mEnemyData)
			ui.showFlashView(TR("已从黑名单移除"))
			break
		end
	end
end

-- 判断一个玩家是否在黑名单中
--[[
-- 参数
	enemyPlayerId: 玩家Id
-- 返回值
	如果是黑名单玩家返回true，否则返回false
]]
function CacheEnemy:isEnemyPlayer(enemyPlayerId)
	local playerId = PlayerAttrObj:getPlayerInfo().PlayerId

	for _, item in pairs(self.mEnemyData and self.mEnemyData[playerId] or {}) do
		if item.Id == enemyPlayerId then
			return true
		end
	end
	return false
end

-- 获取黑名单玩家列表
function CacheEnemy:getEnemyList()
	local playerId = PlayerAttrObj:getPlayerInfo().PlayerId

	return self.mEnemyData[playerId] or {}
end

return CacheEnemy


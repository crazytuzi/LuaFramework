--[[
文件名: CacheAutoFight.lua
描述: 自动战斗缓存数据
创建人: liaoyuangang
创建时间: 2016.06.10
--]]

local CacheAutoFight = class("CacheBag", {})

--[[
]]
function CacheAutoFight:ctor()
    -- 更新自动战斗信息时的玩家信息
    self.mPlayerInfo = {}
    -- 挑战失败节点信息
    self.mFailedNodes = {}
    -- 当前自动战斗的章节模型Id
    self.mChapterId = 11
    -- 当前自动战斗的节点模型Id
    self.mNodeId = 1111
    -- 当前是否是自动推图
    self.mIsAutoFight = false
end

-- 重置战斗失败的节点信息
--[[
-- 参数
	isForce: 是否强制清除
]]
function CacheAutoFight:resetFailedNode(isForce)
	local oldInfo = self.mPlayerInfo
	local currInfo = PlayerAttrObj:getPlayerInfo()
	if not isForce and oldInfo.PlayerId == currInfo.PlayerId and  -- 登陆玩家没有改变
		oldInfo.Lv == currInfo.Lv then   -- 玩家等级没有改变
		-- 同一个玩家等级没有变是，需要根据战力变化觉得是否挑战之前失败的节点
		local oldFAP = oldInfo.FAP or 0
		local upFAP = currInfo.FAP - oldFAP
		if upFAP < 10000 and oldFAP ~= 0 and (upFAP * 100 / oldFAP) < 20 then
			return
		end
	end

	self.mFailedNodes = {}
	-- 更新重置信息时的玩家信息
	oldInfo.PlayerId = currInfo.PlayerId
	oldInfo.Lv = currInfo.Lv
	oldInfo.FAP = currInfo.FAP
end

-- 设置挑战失败的节点
function CacheAutoFight:setFailedNode(failedNodeId)
	self.mFailedNodes[failedNodeId] = true
end

-- 设置当前挑战的节点
--[[
-- 参数
	chapterModelId: 章节模型Id
	nodeModelId: 节点模型Id
]]
function CacheAutoFight:setCurrNode(chapterModelId, nodeModelId)
	-- Todo
end

-- 获取下一个自动挑战的节点
--[[
-- 参数
	callback: 返回结果的回调函数, callback(chapterId, nodeId, starLv)
]]
function CacheAutoFight:getNextNode(callback)
	-- 检查是否需要重置战斗失败的节点信息
	self:resetFailedNode()

	BattleObj:getAllChapterInfo(function(chapterList)
		local chapterIdList = table.keys(chapterList)

		local nodeDataList = {}
		-- 整理所有可以挑战的节点
		for chapterId, chapterItem in pairs(chapterList) do
			for nodeId, nodeItem in pairs(chapterItem.NodeList or {}) do
				if not self.mFailedNodes[nodeId] and nodeItem.StarCount < 3 then -- 最高三星
					local nodeModel = BattleNodeModel.items[nodeId]
					-- 该节点没有到达最高星数，因为有些节点的最高星数是 1星和2星
					if nodeItem.StarCount < nodeModel.starCount then  
						local tempItem = {
							chapterId = chapterId,
							nodeData = nodeItem,
						}
						table.insert(nodeDataList, tempItem)
					end
				end
			end
		end
		table.sort(nodeDataList, function(item1, item2)
			-- 优先挑战低章节中的节点
			if item1.chapterId ~= item2.chapterId then
				return item1.chapterId < item2.chapterId
			end

			-- 在同一章中，优先挑战星数低的节点
			if item1.nodeData.StarCount ~= item2.nodeData.StarCount then
				return item1.nodeData.StarCount < item2.nodeData.StarCount
			end

			-- 在同一章中，星数相同，优先挑战前面的节点
			return item1.nodeData.NodeModelId < item2.nodeData.NodeModelId
		end)
		-- dump(nodeDataList, "CacheAutoFight:getNextNode NodeList:")

		if next(nodeDataList) then
			local item = nodeDataList[1]
			callback(item.chapterId, item.nodeData.NodeModelId, item.nodeData.StarCount + 1)
			return 
		end

		callback()
	end)
end

-- 设置当前自动推图的状态
function CacheAutoFight:setAutoFight(isAutoFight)
	self.mIsAutoFight = isAutoFight
end

-- 获取当前自动推图的状态
function CacheAutoFight:getAutoFight()
	return self.mIsAutoFight
end

return CacheAutoFight


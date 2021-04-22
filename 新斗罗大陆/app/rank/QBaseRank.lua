--
-- Author: Qinyuanji
-- Date: 2015-01-15 
-- This class is the base dialog for Rank detailed list

local QBaseRank = class("QBaseRank")
local QUIWidgetBaseRank = import("..ui.widgets.rank.QUIWidgetBaseRank")
local QUIViewController = import("..ui.QUIViewController")

QBaseRank.REFRESH_HOUR = 9

function QBaseRank:ctor(options)
	self._lastRefreshHour = tonumber(q.date("%H"))

	self._list = {}
	self._conifg = {}
	if options then
		self._config = options.config
	end
end

function QBaseRank:needsUpdate( ... )
	return true
end

function QBaseRank:update(success)
	if success ~= nil then
		self._lastRefreshHour = tonumber(q.date("%H"))
		success()
	end
end

function QBaseRank:getList( ... )
	return self._list
end

function QBaseRank:getMyInfo( ... )
	return self._myInfo
end

function QBaseRank:getRefreshHour( ... )
	return remote.user.c_systemRefreshTime
end

function QBaseRank:getEmptyTips()
	return "ui/GloryArena2.plist/r_xuweiyidaijingqiqidai.png"
end

function QBaseRank:getMaskContentSize()
	return CCSize(724, 510)
end

function QBaseRank:getRankItem()
	return QUIWidgetBaseRank.new()
end

function QBaseRank:renderItem(item, index)
	-- body
end

function QBaseRank:getSelfItem()
	return nil
end

function QBaseRank:getEmptySprite(index)
	if index == nil then 
		index = 1
	end
	local node = CCNode:create()
	local paths = QResPath("rank_empty_tips")
	print("paths index = "..index)
	printTable(paths)
	local sp1 = CCSprite:createWithSpriteFrame(QSpriteFrameByPath(paths[1]))
	sp1:setPosition(ccp(0, 0))
	node:addChild(sp1)
	return node
end

function QBaseRank:setTips(node)
	node:setString("虚位以待，敬请期待！")
end

function QBaseRank:registerClick(listView)
	-- body
end

--查询个人信息通过排行接口
function QBaseRank:queryFighterWithRank(userId, options)
	app:getClient():topRankUserRequest(userId, function(data)
		local fighter = data.rankingFighter
		options.fighter = fighter
 		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
    		options = options}, {isPopCurrentDialog = false})
	end)
end

--查询个人信息通过竞技场接口
function QBaseRank:queryFighterWithArena(userId, options)
	app:getClient():arenaQueryFighterRequest(userId, function(data)
		local fighter = data.arenaResponse.fighter
		options.fighter =fighter
		options.specialValue1 = fighter.victory
 		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
    		options = options}, {isPopCurrentDialog = false})
	end)
end

--查询军团信息接口
function QBaseRank:queryUnionWithRank(sid, options)
	remote.union:unionGetRequest(sid, function(data)
		options.info = data.consortia
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogUnionPrompt",
    		options = options}, {isPopCurrentDialog = false})
	end)
end

function QBaseRank:checkRedTips()
	return false
end

return QBaseRank

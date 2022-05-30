local RESULT_ZORDER = 3000
local LEVELUP_ZORDER = 3001

local BattleScene = class("BattleScene", function ()
	return display.newScene("BattleScene")
end)

function BattleScene:sendReq(curWave)
	dump("curWave" .. curWave)
	RequestHelper.sendNormalBattle({
	id = self.levelID,
	type = self.gradeID,
	errback = function (data)
		self:sendReq(0)
	end,
	callback = function (data)
		dump("normal zhandou ")
		-- 副本副本 战斗胜利则扣除体力，战斗失败则不扣除体力
		local atkDatas = data["2"][1].d
		local atkData = atkDatas[#atkDatas]
		local win = atkData.win
		if win ~= nil and win == 1 then
			game.player:setStrength(game.player.m_strength - self.needPower)
		end
		self.battleLayer:battleCallBack(data)
		MapModel:setCurSmallMapData(self.levelID, self.gradeID)
	end
	})
end

function BattleScene:result(data)
	self.battleData = data["2"][1]
	local submapID = game.player.m_cur_normal_fuben_ID --获取当前副本ID
	local atkData = self.battleData.d[#self.battleData.d]
	local win = atkData.win
	self.rewardItem = data["3"]
	self.rewardCoin = data["4"]
	local beforeLevel, curlevel, curExp
	local function checkExp(data)
		beforeLevel = game.player.getLevel()
		curlevel = data["5"] or beforeLevel
		curExp = data["6"] or 0
		local data_level_level = require("data.data_level_level")
		game.player:updateMainMenu({
		lv = curlevel,
		exp = curExp,
		maxExp = data_level_level[curlevel].exp
		})
	end
	checkExp(data)
	local data_battle_battle = require("data.data_battle_battle")
	local data_field_field = require("data.data_field_field")
	local resultLayer = require("game.Battle.BattleResult").new({
	win = win,
	rewardItem = self.rewardItem,
	rewardCoin = self.rewardCoin,
	levelName = data_battle_battle[self.levelID].name,
	gradeID = self.gradeID,
	star = self.star,
	maxStar = data_battle_battle[self.levelID].star,
	jumpFunc = function ()
	end,
	curLv = curlevel,
	befLv = beforeLevel
	})
	resultLayer:setJumpFunc(function ()
		local submapID = game.player.m_cur_normal_fuben_ID
		local clickedBigMapId = data_field_field[submapID].world
		local function _callback(errorCode, mapData)
			local bgName = "bigmap_1"
			if errorCode == "" then
				local isOpenNewBigmap = false
				if game.player:getBattleData().cur_bigMapId ~= 0 and MapModel.bigMap > game.player:getBattleData().cur_bigMapId then
					isOpenNewBigmap = true
				end
				game.player:setBattleData({
				cur_bigMapId = MapModel.bigMap,
				new_subMapId = MapModel.subMap,
				isOpenNewBigmap = isOpenNewBigmap
				})
				local battleData = game.player:getBattleData()
				if battleData.isOpenNewBigmap and battleData.cur_bigMapId == id then
					MapModel:setCurrentBigMapID(0)
				end
				local isRefresh = false
				if MapModel.level ~= game.player.m_maxLevel then
					isRefresh = true
				end
				game.player.m_maxLevel = MapModel.level
				GameStateManager:ChangeState(GAME_STATE.STATE_SUBMAP, {
				submapID = submapID,
				subMap = mapData.subMapStar,
				isRefresh = isRefresh
				})
			else
				CCMessageBox(errorCode, "server data error")
			end
		end
		MapModel:requestMapData(clickedBigMapId, _callback)
	end)
	self:addChild(resultLayer, RESULT_ZORDER)
	self:checkIsLevelup({
	beforeLevel = beforeLevel,
	curlevel = curlevel,
	curExp = curExp
	})
end

function BattleScene:checkIsLevelup(param)
	local beforeLevel = param.beforeLevel
	local curlevel = param.curlevel
	if beforeLevel < curlevel then
		local curExp = param.curExp
		local curNail = game.player:getNaili()
		self:addChild(UIManager:getLayer("game.LevelUp.LevelUpLayer", nil,{
		level = beforeLevel,
		uplevel = curlevel,
		naili = curNail,
		curExp = curExp
		}), LEVELUP_ZORDER)
	end
end

function BattleScene:releaseUI()
	display.removeSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")
	display.removeSpriteFramesWithFile("bigmap/bigmap.plist", "bigmap/bigmap.png")
	display.removeSpriteFramesWithFile("ui/rank_list.plist", "ui/rank_list.png")
	display.removeSpriteFramesWithFile("ui/ui_bottom_layer.plist", "ui/ui_bottom_layer.pvr.ccz")
	display.removeSpriteFrameByImageName("ui/ui_bigmap_cloud.png")
	display.removeSpriteFrameByImageName("ui/rank_list.png")
	display.removeSpriteFrameByImageName("ui/ui_bottom_layer.pvr.ccz")
end

function BattleScene:ctor(levelID, gradeID, star, needPower, isPassed)
	self:releaseUI()
	printf(" remove BattleScene ui")
	ResMgr.showTextureCache()
	collectgarbage("collect")
	game.runningScene = self
	display.addSpriteFramesWithFile("ui/ui_battle.plist", "ui/ui_battle.png")
	self.levelID = levelID
	self.gradeID = gradeID
	self.star = star
	self.needPower = needPower or 0
	self.isPassed = isPassed or false
	function self.reqFunc(curWave)
		self:sendReq(curWave)
	end
	function self.resultFunc(data)
		self:result(data)
	end
	local initData = {
	fubenType = NORMAL_FUBEN,
	fubenId = self.levelID,
	reqFunc = self.reqFunc,
	resultFunc = self.resultFunc,
	star = star,
	isPassed = self.isPassed
	}
	self.battleLayer = UIManager:getLayer("game.Battle.BattleLayer_sy", nil, initData)
	self:addChild(self.battleLayer)
	self.battleLayer:initTimeScale()
	self.battleLayer.isInitTimeScale = true
	self.battleLayer:initMyselfGroupCard()
	self.battleLayer:sendBattleReq()
end

function BattleScene:onExit()
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return BattleScene
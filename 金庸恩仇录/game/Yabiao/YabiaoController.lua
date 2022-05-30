local data_config_yabiao_config_yabiao = require("data.data_config_yabiao_config_yabiao")

local YabiaoController = class("YabiaoController", function()
	return display.newNode()
end)

function YabiaoController:ctor(param)
	--self:setNodeEventEnabled(true)
	param.mainscene:addChild(self)
	self:init(param)
end

function YabiaoController:init(param)
	self.mainMap = param.map
	self.instance = param.mainscene
	self.scroll = param.scroll
	self.repairReQestGroups = {}
	RegNotice(self, function()
		if BeingRemoveId == game.player.m_playerID then
			if self._isSpeedUp == true then
				self:_hasComplete(self.coinData)
			else
				self:_runCarComplete()
			end
		else
			self:_getExtraData()
		end
	end,
	NoticeKey.Yabiao_repair_enemy)
	
	RegNotice(self, function()
		self:_startRunCar()
	end,
	NoticeKey.Yabiao_run_car)
	
	local function func()
		self:initEnemyCars()
		self:initMyCards()
		self:initExtraData()
		if game.player._yaBiaoCollTime ~= 0 then
			self:refreshCountDown(game.player._yaBiaoCollTime)
		end
	end
	self:_getBaseData(func)
	local function repairFuc()
		self:_repaireLogic()
	end
	self._scheduler = require("framework.scheduler")
	self._schedule = self._scheduler.scheduleGlobal(repairFuc, 1, false)
end

function YabiaoController:_repaireLogic()
	local function initData(data)
		for k, v in pairs(data) do
			local temp = {
			types = v.quality,
			name = v.name,
			level = v.lv,
			roleId = v.roleId,
			time = v.arriveTime,
			totalTime = self.totalTime,
			dartkey = v.dartkey
			}
			local instance = require("game.Yabiao.YabiaoItemView").new(temp)
			self.mainMap:addChild(instance)
			table.insert(self._enemyExtra, instance)
		end
	end
	
	for k, v in pairs(self.repairReQestGroups) do
		RequestHelper.yaBiaoSystem.refreshSigleEnemy({
		repairIds = v,
		callback = function(data)
			dump(data)
			initData(data)
		end
		})
		table.remove(self.repairReQestGroups, k)
		--dump("pop")
		break
	end
end

function YabiaoController:_hasComplete(data)
	self:addChild(require("game.Yabiao.YabiaoCompletePopup").new({
	itemData = data,
	confirmFunc = function()
		self.instance.yabiaoBtn:replaceNormalButton("#yabiao_btn.png")
		self.selfState = 1
		if self._hero then
			for k, v in pairs(self._hero) do
				if v and v.removeSelf then
					v:removeSelf()
					self._hero = {}
				end
			end
		end
	end
	}))
	self._isSpeedUp = false
end

function YabiaoController:initEnemyCars()
	if self._enemy then
		for k, v in pairs(self._enemy) do
			if v and v.removeSelf then
				v:removeSelf()
			end
		end
	end
	if self._enemyExtra then
		for k, v in pairs(self._enemyExtra) do
			if v and v.removeSelf then
				v:removeSelf()
			end
		end
	end
	self._enemy = {}
	self._enemyExtra = {}
	for k, v in pairs(self.enemyData) do
		local temp = {
		types = v.quality,
		name = v.name,
		level = v.lv,
		roleId = v.roleId,
		time = v.arriveTime,
		totalTime = self.totalTime,
		dartkey = v.dartkey
		}
		local instance = require("game.Yabiao.YabiaoItemView").new(temp)
		self.mainMap:addChild(instance)
		table.insert(self._enemy, instance)
	end
end

function YabiaoController:initExtraData()
	if self.selfState == 1 then
		self.instance.yabiaoBtn:replaceNormalButton("#yabiao_btn.png")
	else
		self.instance.yabiaoBtn:replaceNormalButton("#yabiao_jiasu_btn.png")
		if self.selfState == 3 then
			self:_hasComplete(self.coinData)
		end
	end
	
	
	self.instance.yabiaoBtn:setTouchHandle(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		if self.selfState == 1 then
			self.instance:addChild(require("game.Yabiao.YabiaoSelectView").new())
		elseif self.selfState == 2 then
			local function func()
				self._isSpeedUp = true
				self:_speedUpComplete()
				game.player:setGold(game.player:getGold() - data_config_yabiao_config_yabiao[17].value)
				PostNotice(NoticeKey.CommonUpdate_Label_Gold)
			end
			self.instance:addChild(require("game.Yabiao.YabiaoSpeedUpCommitPopup").new({
			cost = data_config_yabiao_config_yabiao[17].value,
			disStr = common:getLanguageString("@lijiwcyb"),
			confirmFunc = func
			}))
		end
	end)
	
	self.instance.shuaxinBtn:setTouchHandle(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		if game.player._yaBiaoCollTime ~= 0 then
			show_tip_label(common:getLanguageString("@shuaxinsjwd"))
			return
		end
		local function refresh()
			initTimeGroup()
			self:initEnemyCars()
			self:refreshCountDown(coutDownTime)
		end
		self:_refreshData(refresh)
	end)
end

function YabiaoController:refreshCountDown(time)
	self.instance.shuaxinBtn:setTouchEnabled(false)
	game.player._yaBiaoCollTime = time
	self.instance.shuaxinBtn:replaceNormalButton("#count_down_btn.png")
	
	local countDownLabel = ui.newTTFLabel({
	text = format_time(time),
	size = 25,
	align = ui.TEXT_ALIGN_CENTER,
	color = FONT_COLOR.WHITE,
	font = FONTS_NAME.font_fzcy
	})
	countDownLabel:setPosition(cc.p(self.instance.shuaxinBtn:getContentSize().width / 2, self.instance.shuaxinBtn:getContentSize().height / 2))
	countDownLabel:setAnchorPoint(cc.p(0.5, 0.5))
	self.instance.shuaxinBtn:bgAddChild(countDownLabel)
	local function countDown()
		countDownLabel:setString(format_time(game.player._yaBiaoCollTime))
		if game.player._yaBiaoCollTime == 0 then
			self._schedulerCountDown.unscheduleGlobal(self._schedules)
			self.instance.shuaxinBtn:replaceNormalButton("#shuaxin_btn.png")
			self.instance.shuaxinBtn:bgClear()
			self.instance.shuaxinBtn:setTouchEnabled(true)
		else
			self.instance.shuaxinBtn:setTouchEnabled(false)
		end
	end
	self._schedulerCountDown = require("framework.scheduler")
	self._schedules = self._schedulerCountDown.scheduleGlobal(countDown, 1, false)
end

function YabiaoController:initMyCards()
	self._hero = {}
	local v = self.heroData
	if v == nil or not v.name then
		return
	end
	local v = self.heroData
	local temp = {
	types = v.quality,
	name = v.name,
	level = v.lv,
	time = v.arriveTime,
	roleId = v.roleId,
	totalTime = self.totalTime,
	dartkey = v.dartkey,
	mid = true
	}
	self.selfState = 2
	local instance = require("game.Yabiao.YabiaoItemView").new(temp)
	self.mainMap:addChild(instance)
	table.insert(self._hero, instance)
	
	self.instance.yabiaoBtn:replaceNormalButton("#yabiao_jiasu_btn.png")
	local action
	if instance:getPositionY() > 1600 - mapMaxDistance then
		action = transition.sequence({
		CCMoveTo:create(1, cc.p(self.mainMap:getPositionX(), mapMaxDistance - 1600 + 10)),
		CCCallFunc:create(function()
			self.scroll:setTouchEnabled(true)
		end)
		})
	else
		action = transition.sequence({
		CCMoveTo:create(1, cc.p(self.mainMap:getPositionX(), 0 - instance:getY() + 10)),
		CCCallFunc:create(function()
			self.scroll:setTouchEnabled(true)
		end)
		})
	end
	self.scroll:setTouchEnabled(false)
	self.mainMap:runAction(action)
end

function YabiaoController:clearTimer()
	if self._enemy then
		for k, v in pairs(self._enemy) do
			if v and v.removeSelf then
				v:removeSelf()
			end
		end
	end
	if self._enemyExtra then
		for k, v in pairs(self._enemyExtra) do
			if v and v.removeSelf then
				v:removeSelf()
			end
		end
	end
	if self._hero then
		for k, v in pairs(self._hero) do
			if v and v.removeSelf then
				v:removeSelf()
			end
		end
	end
	self._enemy = {}
	self._enemyExtra = {}
	self._hero = {}
	UnRegNotice(self, NoticeKey.Yabiao_repair_enemy)
	UnRegNotice(self, NoticeKey.Yabiao_run_car)
	if self._schedules then
		self._schedulerCountDown.unscheduleGlobal(self._schedules)
	end
	if self._schedule then
		self._scheduler.unscheduleGlobal(self._schedule)
	end
end

function YabiaoController:_startRunCar()
	self._hero = {}
	local temp = {
	types = selfCarInfo.types,
	name = selfCarInfo.name,
	level = selfCarInfo.level,
	roleId = selfCarInfo.roleId,
	dartkey = selfCarInfo.dartkey,
	time = self.totalTime * 60,
	totalTime = self.totalTime,
	mid = true
	}
	self.selfState = 2
	local instance = require("game.Yabiao.YabiaoItemView").new(temp)
	self.mainMap:addChild(instance)
	table.insert(self._hero, instance)
	self.instance.yabiaoBtn:replaceNormalButton("#yabiao_jiasu_btn.png")
	self.mainMap:setPositionY(10 - instance:getY())
	if self.mainMap:getPositionY() < -mapMaxDistance then
		self.mainMap:setPositionY(mapMaxDistance - 1600 + 10)
	else
		self.mainMap:setPositionY(0 - instance:getY() + 10)
	end
end

function YabiaoController:_getBaseData(func)
	local function initData(data)
		self.enemyData = {}
		for k, v in pairs(data.otherDartCar) do
			table.insert(self.enemyData, v)
		end
		self.totalTime = data.lastTime
		self.selfState = data.selfState
		self.heroData = data.selfDartCar
		self.coinData = data.getCoin
		game.player._yaBiaoCollTime = data.refreshTime
		func()
	end
	RequestHelper.yaBiaoSystem.getBaseInfo({
	callback = function(data)
		dump(data)
		initData(data)
	end
	})
end

function YabiaoController:_getExtraData()
	self.repairReQestGroups[#self.repairReQestGroups + 1] = BeingRemoveId
	dump(BeingRemoveId)
end

function YabiaoController:_speedUpComplete()
	local function initData(data)
		self.rewords = data
		for k, v in pairs(self._hero) do
			v._time = 0
			v:removeSelf()
			self._hero = {}
		end
		game.player._yaBiaoCollTime = game.player._yaBiaoCollTime or 1
		self:_hasComplete(data)
	end
	RequestHelper.yaBiaoSystem.beginRunWithSpeedUp({
	callback = function(data)
		dump(data)
		initData(data)
	end
	})
end

function YabiaoController:_runCarComplete()
	local function initData(data)
		self.rewords = data
		self:_hasComplete(data)
	end
	RequestHelper.yaBiaoSystem.getRewords({
	callback = function(data)
		dump(data)
		initData(data)
	end
	})
end

function YabiaoController:_refreshData(func)
	local function initData(data)
		self.enemyData = {}
		for k, v in pairs(data) do
			table.insert(self.enemyData, v)
		end
		func()
	end
	RequestHelper.yaBiaoSystem.refreshAllEnemy({
	callback = function(data)
		dump(data)
		initData(data)
	end
	})
end

function YabiaoController:onEnter()
	
end

function YabiaoController:onExit()
	
end

return YabiaoController
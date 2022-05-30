require("game.GameConst")
local MAX_ZORDER = 11113

local YaBiaoResult = class("YaBiaoResult", function(data)
	return require("utility.ShadeLayer").new()
end)

function YaBiaoResult:createTreasure(lostDebris, data)
	display.addSpriteFramesWithFile("ui/ui_duobao.plist", "ui/ui_duobao.png")
end

function YaBiaoResult:initWin(data)
	local proxy = CCBProxy:create()
	local node = CCBuilderReaderLoad("huodong/yabiao_win.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	local effWin = ResMgr.createArma({
	resType = ResMgr.UI_EFFECT,
	armaName = "zhandoushengli",
	isRetain = true
	})
	effWin:setPosition(self._rootnode.tag_title_anim:getContentSize().width / 2, self._rootnode.tag_title_anim:getContentSize().height)
	self._rootnode.tag_title_anim:addChild(effWin)
	local effTextWin = ResMgr.createArma({
	resType = ResMgr.UI_EFFECT,
	armaName = "zhandoushengli_zi",
	isRetain = true
	})
	effTextWin:setPosition(self._rootnode.tag_title_anim:getContentSize().width / 2, self._rootnode.tag_title_anim:getContentSize().height)
	self._rootnode.tag_title_anim:addChild(effTextWin)
	self._rootnode.confirmBtn:setEnabled(true)
	self:createTreasure(false, data)
end

function YaBiaoResult:initLost(data)
	local proxy = CCBProxy:create()
	local node = CCBuilderReaderLoad("huodong/yabiao_lost.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	local zhenrongBtn = self._rootnode.zhenrongBtn
	zhenrongBtn:setVisible(false)
	
	self._rootnode.wujiangBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameStateManager:ChangeState(GAME_STATE.STATE_XIAKE)
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.zhuangbeiBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameStateManager:ChangeState(GAME_STATE.STATE_EQUIPMENT)
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.goZhenrongBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameStateManager:ChangeState(GAME_STATE.STATE_ZHENRONG)
	end,
	CCControlEventTouchUpInside)
	
	
	self._rootnode.heroRewardBtn:addHandleOfControlEvent(function(sender, eventName)
		GameStateManager:ChangeState(GAME_STATE.STATE_JIANGHULU)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end,
	CCControlEventTouchUpInside)
	
	
	self._rootnode.zhenqiBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameStateManager:ChangeState(GAME_STATE.STATE_JINGYUAN)
	end,
	CCControlEventTouchUpInside)
	
end

function YaBiaoResult:ctor(param)
	local data = param.data
	self._rootnode = {}
	self._tabIndex = param.tabindex
	self._extraMsg = param.extraMsg
	local result = data["1"][1]
	local coinAry = data["3"]
	if result == 1 then
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_shengli))
		self:initWin(data)
	elseif result == 2 then
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_shibai))
		self:initLost(data)
	else
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_shibai))
		self:initLost(data)
	end
	
	self._rootnode.confirmBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameStateManager:ChangeState(GAME_STATE.STATE_YABIAO_SCENE)
	end,
	CCControlEventTouchUpInside)
	
	for _, v in ipairs(coinAry) do
		if v.id == 13 then
			self._rootnode.yinbiLbl:setString("+" .. tostring(v.n))
		elseif v.id == 5 then
		elseif v.id == 6 then
			self._rootnode.expLbl:setString("+" .. tostring(v.n))
		end
	end
	local cellDatas = {}
	for k, v in pairs(coinAry) do
		local temp = {}
		temp.id = v.id
		temp.num = v.num
		temp.type = v.type
		temp.iconType = ResMgr.getResType(v.type)
		temp.name = require("data.data_item_item")[v.id].name
		table.insert(cellDatas, temp)
		if v.id == 1 then
			game.player:setGold(game.player:getGold() + v.num)
		elseif v.id == 2 then
			game.player:setSilver(game.player:getSilver() + v.num)
		end
	end
	if result == 1 then
		local boardWidth = self._rootnode.listView:getContentSize().width
		local boardHeight = self._rootnode.listView:getContentSize().height * 0.97
		local function createFunc(index)
			local item = require("game.nbactivity.TanBao.JifenRewordItem").new()
			return item:create({
			id = index,
			itemData = cellDatas[index + 1],
			viewSize = cc.size(boardWidth, boardHeight)
			})
		end
		local function refreshFunc(cell, index)
			cell:refresh({
			index = index,
			itemData = cellDatas[index + 1]
			})
		end
		local cellContentSize = require("game.nbactivity.TanBao.JifenRewordItem").new():getContentSize()
		self.ListTable = require("utility.TableViewExt").new({
		size = cc.size(boardWidth, boardHeight),
		createFunc = createFunc,
		refreshFunc = refreshFunc,
		cellNum = #cellDatas,
		cellSize = cellContentSize
		})
		self.ListTable:setPosition(0, self._rootnode.listView:getContentSize().height * 0.015)
		self._rootnode.listView:addChild(self.ListTable)
	else
		self._rootnode.battle_value_right:setString(tostring(data["extra-enemy"].attack))
		self._rootnode.battle_value_left:setString(tostring(game.player:getBattlePoint()))
		self._rootnode.nailiLbl:setString("-2")
		self._rootnode.player_name_right:setString(data["extra-enemy"].name)
		self._rootnode.player_name_left:setString(game.player:getPlayerName())
		
		local replayBtn = self._rootnode.replayBtn
		replayBtn:addHandleOfControlEvent(function(sender, eventName)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			replayBtn:setEnabled(false)
			local function closeFunc(node)
				replayBtn:setEnabled(true)
				node:removeSelf()
			end
			self:addChild(require("game.Duobao.DuobaoBattleReplayLayer").new(data, closeFunc), MAX_ZORDER)
		end,
		CCControlEventTouchUpInside)
	end
end

function YaBiaoResult:onExit(...)
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
	display.removeSpriteFramesWithFile("ui/ui_duobao.plist", "ui/ui_duobao.png")
end

return YaBiaoResult
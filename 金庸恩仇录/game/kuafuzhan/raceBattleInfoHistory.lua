--跨服战16强比赛记录界面
local kuafuMsg = {
getBattleInfoShow = function(param)
	local _callback = param.callback
	local msg = {
	m = "cross",
	a = "crossBattleInfoShow",
	id = param.id,
	round = param.round,
	index = param.index
	}
	RequestHelper.request(msg, _callback, param.errback)
end
}
local raceTitle = {
[1] = common:getLanguageString("@raceType3"),
[2] = common:getLanguageString("@raceType2"),
[4] = common:getLanguageString("@raceType1", 8, 4),
[8] = common:getLanguageString("@raceType1", 16, 8)
}
local raceTypeTitle = {
[0] = common:getLanguageString("@KnockoutMatch"),
[1] = common:getLanguageString("@MasterHero"),
[2] = common:getLanguageString("@NameDynamic")
}
local viewType = 0

local battleInfoItem = class("battleInfoItem", function()
	return CCTableViewCell:new()
end)

function battleInfoItem:getContentSize()
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("kuafu/comp_retro_item.ccbi", proxy, rootnode)
	local contentSize = node:getContentSize()
	self:addChild(node)
	node:removeSelf()
	return contentSize
end

function battleInfoItem:create(param)
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("kuafu/comp_retro_item.ccbi", proxy, self._rootnode)
	local contentSize = node:getContentSize()
	node:setPosition(contentSize.width * 0.5, contentSize.height)
	self:addChild(node, 0)
	self._rootnode.view_btn:addHandleOfControlEvent(function(sender, eventName)
		dump("duang! duang! duang!")
		kuafuMsg.getBattleInfoShow({
		id = self.battleInfo.id,
		callback = function(data)
			local battleData = {}
			battleData["1"] = {}
			battleData["1"][1] = 1
			battleData["2"] = {}
			battleData["2"][1] = data
			for i = 1, 2 do
				local heroData = battleData["2"][1].d[1]["f" .. i]
				for _, hero in pairs(heroData) do
					if hero.id == 1 or hero.id == 2 then
						hero.name = self.battleInfo.userInfo[i].name
						break
					end
				end
			end
			local scene = require("game.kuafuzhan.xuanbaBattleScene").new({
			beRace = true,
			data = battleData,
			heroName = self.battleInfo.userInfo[1].name,
			heroCombat = self.battleInfo.userInfo[1].point,
			enemyName = self.battleInfo.userInfo[2].name,
			enemyCombat = self.battleInfo.userInfo[2].point
			})
			push_scene(scene)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		end
		})
	end,
	CCControlEventTouchUpInside)
	
	self.bgSize = self._rootnode.player_bg_1:getContentSize()
	self:refresh(param.battleInfo)
	for key = 1, 2 do
		setTTFLabelOutline({
		label = self._rootnode["player_name_" .. key]
		})
		setTTFLabelOutline({
		label = self._rootnode["player_server_" .. key]
		})
	end
	return self
end

function battleInfoItem:refresh(battleInfo)
	self.battleInfo = battleInfo
	local pngPath = "ui/ui_CommonResouces/"
	for i = 1, 2 do
		local resultPath, bgPath
		if i == battleInfo.win then
			resultPath = pngPath .. "ui_victory.png"
			bgPath = "ui/ui_9Sprite/ui_sh_bg_4.png"
		else
			resultPath = pngPath .. "ui_defeated.png"
			bgPath = "ui/ui_9Sprite/ui_sh_bg_29.png"
		end
		self._rootnode["player_result_" .. i]:setDisplayFrame(display.newSprite(resultPath):getDisplayFrame())
		self._rootnode["player_bg_" .. i]:setSpriteFrame(display.newSprite(bgPath):getDisplayFrame())
		self._rootnode["player_bg_" .. i]:setContentSize(self.bgSize)
	end
	for key, user in pairs(battleInfo.userInfo) do
		self._rootnode["player_name_" .. key]:setString(user.name)
		self._rootnode["player_server_" .. key]:setString(user.serverName)
		ResMgr.refreshIcon({
		id = user.res[1].resId,
		itemBg = self._rootnode["player_icon_" .. key],
		resType = ResMgr.HERO,
		cls = user.res[1].cls
		})
	end
	local text
	if battleInfo.userInfo[1].viewType and 1 <= battleInfo.userInfo[1].viewType then
		text = raceTypeTitle[battleInfo.userInfo[1].viewType] .. raceTitle[battleInfo.popNum]
	elseif battleInfo.popNum == 16 then
		text = raceTypeTitle[1] .. raceTypeTitle[0]
	elseif battleInfo.popNum == 32 then
		text = raceTypeTitle[2] .. raceTypeTitle[0]
	end
	self._rootnode.race_level:setString(text .. " " .. common:getLanguageString("@TheCTime", battleInfo.times or 1))
end

local raceBattleInfoHistory = class("raceBattleInfoHistory", function(param)
	return require("utility.ShadeLayer").new()
end)

function raceBattleInfoHistory:ctor(param)
	self._userInfo = param.userInfo
	self._battleInfoList = param.battleInfoList
	self._title = param.title or ""
	local rootProxy = CCBProxy:create()
	self._rootnode = {}
	local rootnode = CCBuilderReaderLoad("kuafu/comp_retro_Msgbox.ccbi", rootProxy, self._rootnode)
	self:addChild(rootnode, 1)
	rootnode:setPosition(display.cx, display.cy)
	self._rootnode.comp_title:setString(self._title)
	self._rootnode.closeBtn:addHandleOfControlEvent(function(sender, eventName)
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	local boardWidth = self._rootnode.retro_layer:getContentSize().width
	local boardHeight = self._rootnode.retro_layer:getContentSize().height
	local listViewSize = cc.size(boardWidth, boardHeight)
	local itemSize = battleInfoItem.new():getContentSize()
	local function createFunc(index)
		index = index + 1
		return battleInfoItem.new():create({
		battleInfo = self._battleInfoList[index]
		})
	end
	
	local function refreshFunc(cell, index)
		index = index + 1
		cell:refresh(self._battleInfoList[index])
	end
	
	self.rankListTableView = require("utility.TableViewExt").new({
	size = listViewSize,
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #self._battleInfoList,
	cellSize = itemSize
	})
	self._rootnode.retro_layer:addChild(self.rankListTableView)
end

return raceBattleInfoHistory
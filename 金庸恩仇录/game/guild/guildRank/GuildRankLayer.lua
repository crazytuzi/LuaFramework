local NORMAL_FONT_SIZE = 22

local GuildRankLayer = class("GuildRankLayer", function()
	return require("utility.ShadeLayer").new()
end)

function GuildRankLayer:getRankData()
	RequestHelper.Guild.rank({
	callback = function(data)
		dump(data)
		if data.err ~= "" then
			dump(data.err)
		else
			self:initData(data.rtnObj)
		end
	end
	})
end

function GuildRankLayer:initData(rtnObj)
	local mysumAttack = rtnObj.mysumAttack
	local myrank = rtnObj.myrank
	local isInUnion = rtnObj.isInUnion
	local rankData = rtnObj.unionList
	local mysumAttackStr, myrankStr
	if isInUnion == 1 then
		myrankStr = common:getLanguageString("@NoGuild")
		mysumAttackStr = common:getLanguageString("@NotHave")
	elseif isInUnion == 0 then
		myrankStr = myrank
		mysumAttackStr = mysumAttack
	end
	
	local myRankLbl = ui.newTTFLabelWithShadow({
	text = tostring(myrankStr),
	size = NORMAL_FONT_SIZE,
	color = cc.c3b(78, 255, 0),
	shadowColor = FONT_COLOR.BLACK,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT
	})
	ResMgr.replaceKeyLableEx(myRankLbl, self._rootnode, "my_rank_lbl", 0, 0)
	myRankLbl:align(display.LEFT_CENTER)
	
	local powerLbl = ui.newTTFLabelWithShadow({
	text = tostring(mysumAttackStr),
	size = NORMAL_FONT_SIZE,
	color = cc.c3b(78, 255, 0),
	shadowColor = FONT_COLOR.BLACK,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT
	})
	ResMgr.replaceKeyLableEx(powerLbl, self._rootnode, "my_power_lbl", 0, 0)
	powerLbl:align(display.LEFT_CENTER)
	
	local viewSize = self._rootnode.listView:getContentSize()
	local function createFunc(index)
		local item = require("game.guild.guildRank.GuildRankItem").new()
		return item:create({
		id = index + 1,
		viewSize = viewSize,
		itemData = rankData[index + 1]
		})
	end
	local function refreshFunc(cell, index)
		cell:refresh({
		id = index + 1,
		itemData = rankData[index + 1]
		})
	end
	local cellContentSize = require("game.guild.guildRank.GuildRankItem").new():getContentSize()
	self._rootnode.listView:removeAllChildren()
	local listTable = require("utility.TableViewExt").new({
	size = viewSize,
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #rankData,
	cellSize = cellContentSize
	})
	listTable:setPosition(0, 0)
	self._rootnode.listView:addChild(listTable)
end

function GuildRankLayer:ctor()
	self._rootnode = {}
	local proxy = CCBProxy:create()
	local node = CCBuilderReaderLoad("guild/guild_rank_layer.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	self._rootnode.closeBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	self:getRankData()
end

return GuildRankLayer
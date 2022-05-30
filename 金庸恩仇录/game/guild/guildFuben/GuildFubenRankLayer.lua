local data_ui_ui = require("data.data_ui_ui")

local GuildFubenRankLayer = class("GuildFubenRankLayer", function()
	return require("utility.ShadeLayer").new()
end)

function GuildFubenRankLayer:ctor(param)
	self:setNodeEventEnabled(true)
	local hurtList = param.hurtList
	local confirmFunc = param.confirmFunc
	self._rootnode = {}
	local proxy = CCBProxy:create()
	local node = CCBuilderReaderLoad("huodong/worldBoss_rank_layer.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	self._rootnode.top_msg_lbl:setString(data_ui_ui[11].content)
	self._rootnode.closeBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		if confirmFunc ~= nil then
			confirmFunc()
		end
		self:removeFromParentAndCleanup(true)
	end,
	CCControlEventTouchUpInside)
	
	self:initData(hurtList)
	dump(self._rankData)
	self:createListView()
end

function GuildFubenRankLayer:initData(topPlayers)
	local rankData = topPlayers or {}
	local needAdd = false
	if #rankData < 3 then
		needAdd = true
	end
	local getIsHasAdd = function(index, indexList)
		local bHas = false
		for i, v in ipairs(indexList) do
			if v == index then
				bHas = true
				break
			end
		end
		return bHas
	end
	local SORT_TYPE = {
	hurt = 0,
	attack = 1,
	level = 2,
	time = 3
	}
	self._rankData = {}
	local indexList = {}
	local function getItemByType(sortType, fromList, bIsRise)
		local toNum = -1
		local toList = {}
		local function getCurByType(v)
			local cur
			if sortType == SORT_TYPE.hurt then
				cur = v.attackHp
			elseif sortType == SORT_TYPE.attack then
				cur = rankData[v].attackNum
			elseif sortType == SORT_TYPE.level then
				cur = rankData[v].roleLevel
			elseif sortType == SORT_TYPE.time then
				cur = rankData[v].createTime
			end
			return cur
		end
		for i, v in ipairs(fromList) do
			local cur = getCurByType(v)
			local idx = i
			if sortType ~= SORT_TYPE.hurt then
				idx = v
			end
			if getIsHasAdd(idx, indexList) == false then
				if bIsRise == true then
					if toNum < cur then
						toNum = cur
					end
				else
					if toNum == -1 then
						toNum = cur
					end
					if cur < toNum then
						toNum = cur
					end
				end
			end
		end
		for i, v in ipairs(fromList) do
			local cur = getCurByType(v)
			local idx = i
			if sortType ~= SORT_TYPE.hurt then
				idx = v
			end
			if getIsHasAdd(idx, indexList) == false and cur == toNum then
				if sortType == SORT_TYPE.hurt then
					table.insert(toList, idx)
				else
					table.insert(toList, idx)
				end
			end
		end
		return toList
	end
	
	local function addToList(index)
		if index ~= -1 and getIsHasAdd(index, indexList) == false then
			local itemData = rankData[index]
			itemData.rank = #self._rankData + 1
			itemData.guildName = game.player:getGuildInfo().m_name
			table.insert(indexList, index)
			table.insert(self._rankData, itemData)
		end
	end
	
	for _, _ in ipairs(rankData) do
		local hurtList = getItemByType(SORT_TYPE.hurt, rankData, true)
		for _, _ in ipairs(hurtList) do
			local attackList = getItemByType(SORT_TYPE.attack, hurtList, false)
			for _, _ in ipairs(attackList) do
				local levelList = getItemByType(SORT_TYPE.level, attackList, true)
				for _, _ in ipairs(levelList) do
					local createTimeList = getItemByType(SORT_TYPE.time, levelList, false)
					for _, v in ipairs(createTimeList) do
						addToList(v)
					end
				end
			end
		end
	end
	if needAdd == true then
		for i = #self._rankData + 1, 3 do
			table.insert(self._rankData, {
			isTrueData = false,
			rank = i,
			acc = "",
			name = common:getLanguageString("@NotHave"),
			roleLevel = 0,
			attackHp = 0,
			attackNum = 0,
			createTime = 0
			})
		end
	end
end

function GuildFubenRankLayer:createListView()
	local viewSize = self._rootnode.listView:getContentSize()
	local fileName = "game.guild.guildFuben.GuildFubenRankItem"
	local function createFunc(index)
		local item = require(fileName).new()
		return item:create({
		viewSize = viewSize,
		itemData = self._rankData[index + 1],
		checkFunc = function(cell)
			local index = cell:getIdx() + 1
			self:checkZhenrong(index)
		end
		})
	end
	local function refreshFunc(cell, index)
		cell:refresh(self._rankData[index + 1])
	end
	local cellContentSize = require(fileName).new():getContentSize()
	self._rootnode.listView:removeAllChildren()
	local listTable = require("utility.TableViewExt").new({
	size = viewSize,
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #self._rankData,
	cellSize = cellContentSize
	})
	listTable:setPosition(0, 0)
	self._rootnode.listView:addChild(listTable)
end

function GuildFubenRankLayer:checkZhenrong(index)
	if ENABLE_ZHENRONG then
		local layer = require("game.form.EnemyFormLayer").new(1, self._rankData[index].acc)
		layer:setPosition(0, 0)
		self:addChild(layer, 10000)
	else
		show_tip_label(data_error_error[2800001].prompt)
	end
end

function GuildFubenRankLayer:onExit()
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return GuildFubenRankLayer
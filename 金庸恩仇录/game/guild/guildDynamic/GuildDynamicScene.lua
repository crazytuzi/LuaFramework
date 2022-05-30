local data_union_dongtai_union_dongtai = require("data.data_union_dongtai_union_dongtai")
local MAX_ZORDER = 100

local BaseScene = require("game.guild.utility.GuildBaseScene")
local GuildDynamicScene = class("GuildDynamicScene", BaseScene)

function GuildDynamicScene:ctor(data)
	game.runningScene = self
	
	local bottomFile = "guild/guild_bottom_frame_normal.ccbi"
	local jopType = game.player:getGuildMgr():getGuildInfo().m_jopType
	if jopType ~= GUILD_JOB_TYPE.normal then
		bottomFile = "guild/guild_bottom_frame.ccbi"
	end
	GuildDynamicScene.super.ctor(self, {
	contentFile = "guild/guild_list_bg.ccbi",
	topFile = "guild/guild_guildDynamic_up_tab.ccbi",
	bottomFile = bottomFile,
	adjustSize = cc.size(0, -50)
	})
	
	local _bg = display.newSprite("ui_common/common_bg.png")
	local _bgW = display.width
	local _bgH = display.height - self._rootnode.bottomMenuNode:getContentSize().height - self._rootnode.topFrameNode:getContentSize().height
	_bg:setPosition(_bgW / 2, _bgH / 2 + self._rootnode.bottomMenuNode:getContentSize().height)
	_bg:setScaleX(_bgW / _bg:getContentSize().width)
	_bg:setScaleY(_bgH / _bg:getContentSize().height)
	self:addChild(_bg, 0)
	self._rootnode.tag_search_node:setVisible(false)
	self._rootnode.tag_verify_node:setVisible(false)
	self._rootnode.tab1:selected()
	
	self._rootnode.backBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameStateManager:ChangeState(GAME_STATE.STATE_GUILD)
	end,
	CCControlEventTouchUpInside)
	
	self._bHasShowFormLayer = false
	local dynamicListData = self:createListData(data.rtnObj.dynamicList)
	self:createDynamicListView(dynamicListData)
end

function GuildDynamicScene:createListData(dynamicList)
	local listData = {}
	for i, v in ipairs(dynamicList) do
		local itemData = v
		itemData.timeStr = os.date("%y-%m-%d     %H:%M:%S", v.createTime / 1000)
		local infoData = data_union_dongtai_union_dongtai[itemData.id]
		ResMgr.showAlert(infoData, common:getLanguageString("@SeverIdError") .. itemData.id)
		local content = infoData.content
		for i = 1, infoData.param_num do
			local param = v.desList[i]
			ResMgr.showAlert(param, common:getLanguageString("@ServerDesListError") .. tostring(#v.desList) .. common:getLanguageString("@ServerDesListError_Attr") .. tostring(infoData.param_num))
		end
		if infoData.param_num == 1 then
			content = string.format(content, tostring(v.desList[1]))
		elseif infoData.param_num == 2 then
			content = string.format(content, tostring(v.desList[1]), tostring(v.desList[2]))
		elseif infoData.param_num == 3 then
			content = string.format(content, tostring(v.desList[1]), tostring(v.desList[2]), tostring(v.desList[3]))
		elseif infoData.param_num == 4 then
			content = string.format(content, tostring(v.desList[1]), tostring(v.desList[2]), tostring(v.desList[3]), tostring(v.desList[4]))
		elseif infoData.param_num == 5 then
			content = string.format(content, tostring(v.desList[1]), tostring(v.desList[2]), tostring(v.desList[3]), tostring(v.desList[4]), tostring(v.desList[5]))
		elseif infoData.param_num == 6 then
			content = string.format(content, tostring(v.desList[1]), tostring(v.desList[2]), tostring(v.desList[3]), tostring(v.desList[4]), tostring(v.desList[5]), tostring(v.desList[6]))
		elseif infoData.param_num == 7 then
			content = string.format(content, tostring(v.desList[1]), tostring(v.desList[2]), tostring(v.desList[3]), tostring(v.desList[4]), tostring(v.desList[5]), tostring(v.desList[6]), tostring(v.desList[7]))
		end
		itemData.content = content
		itemData.touchType = infoData.touchType
		table.insert(listData, itemData)
	end
	return listData
end

function GuildDynamicScene:createDynamicListView(listData)
	if self._listViewTable ~= nil then
		self._listViewTable:removeFromParentAndCleanup(true)
		self._listViewTable = nil
	end
	local listViewSize = self._rootnode.listView:getContentSize()
	local function createFunc(index)
		local item = require("game.guild.guildDynamic.GuildDynamicItem").new()
		return item:create({
		itemData = listData[index + 1],
		viewSize = listViewSize
		})
	end
	
	local function refreshFunc(cell, index)
		cell:refresh(listData[index + 1])
	end
	
	local cellContentSize = require("game.guild.guildDynamic.GuildDynamicItem").new():getContentSize()
	self._listViewTable = require("utility.TableViewExt").new({
	size = listViewSize,
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #listData,
	cellSize = cellContentSize,
	touchFunc = function(cell, x, y)
		local idx = cell:getIdx() + 1
		local itemData = listData[idx]
		if itemData.touchType == nil or itemData.touchType ~= 1 then
			local roleAcc = itemData.roleAcc
			if game.player:checkIsSelfByAcc(roleAcc) == false and self._bHasShowFormLayer == false then
				local icon = cell:getPlayerIcon()
				local pos = icon:convertToNodeSpace(cc.p(x, y))
				if cc.rectContainsPoint(cc.rect(0, 0, icon:getContentSize().width, icon:getContentSize().height), pos) then
					self._bHasShowFormLayer = true
					local layer = require("game.form.EnemyFormLayer").new(1, roleAcc, function()
						self._bHasShowFormLayer = false
					end)
					layer:setPosition(0, 0)
					game.runningScene:addChild(layer, MAX_ZORDER)
				end
			end
		end
	end
	})
	self._rootnode.listView:addChild(self._listViewTable)
end

return GuildDynamicScene
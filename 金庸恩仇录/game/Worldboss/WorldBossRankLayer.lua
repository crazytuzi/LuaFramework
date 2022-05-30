local data_ui_ui = require("data.data_ui_ui")
local REFRESH_TIME = 5

local WorldBossRankLayer = class("WorldBossRankLayer", function()
	return require("utility.ShadeLayer").new()
end)

function WorldBossRankLayer:getRankData()
	RequestHelper.worldBoss.rank({
	callback = function(data)
		if data["0"] ~= "" then
			CCMessageBox(data["0"], "Error")
		else
			self:initData(data)
			self._time = REFRESH_TIME
		end
	end
	})
end

function WorldBossRankLayer:initData(data)
	self._rankData = data["1"]
	local curNum = #self._rankData
	if self._rankData ~= nil and curNum < 10 then
		for i = curNum + 1, 10 do
			table.insert(self._rankData, {
			isTrueData = false,
			rank = i,
			acc = "",
			name = common:getLanguageString("@NotHave"),
			hurt = 0,
			lv = 0
			})
		end
	end
	local viewSize = self._rootnode.listView:getContentSize()
	local function createFunc(index)
		local item = require("game.Worldboss.WorldBossRankItem").new()
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
	local cellContentSize = require("game.Worldboss.WorldBossRankItem").new():getContentSize()
	self._rootnode.listView:removeAllChildren()
	self._listTable = require("utility.TableViewExt").new({
	size = viewSize,
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #self._rankData,
	cellSize = cellContentSize
	})
	self._listTable:setPosition(0, 0)
	self._rootnode.listView:addChild(self._listTable)
end

function WorldBossRankLayer:ctor()
	self:setNodeEventEnabled(true)
	self._time = -1
	self._rootnode = {}
	local proxy = CCBProxy:create()
	local node = CCBuilderReaderLoad("huodong/worldBoss_rank_layer.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	self._rootnode.top_msg_lbl:setString(data_ui_ui[1].content)
	
	self._rootnode.closeBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:removeFromParentAndCleanup(true)
	end,
	CCControlEventTouchUpInside)
	
	self:getRankData()
end

function WorldBossRankLayer:checkZhenrong(index)
	if ENABLE_ZHENRONG then
		local layer = require("game.form.EnemyFormLayer").new(1, self._rankData[index].acc)
		layer:setPosition(0, 0)
		self:addChild(layer, 10000)
	else
		show_tip_label(data_error_error[2800001].prompt)
	end
end

function WorldBossRankLayer:onExit()
end

return WorldBossRankLayer
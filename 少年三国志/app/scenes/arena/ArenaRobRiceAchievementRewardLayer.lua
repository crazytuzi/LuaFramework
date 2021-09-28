-- 夺粮战排行奖励（第二版）

local ArenaRobRiceAchievementRewardLayer = class("ArenaRobRiceAchievementRewardLayer", UFCCSModelLayer)

local Cell = require "app.scenes.arena.ArenaRobRiceAchievementRewardCell"
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
require ("app.cfg.rice_achievement")

function ArenaRobRiceAchievementRewardLayer.show( ... )
	local layer = ArenaRobRiceAchievementRewardLayer.new("ui_layout/arena_RobRiceAchievementRewardLayer.json", Colors.modelColor, ...)
	uf_sceneManager:getCurScene():addChild(layer)
end

function ArenaRobRiceAchievementRewardLayer:ctor(json, color, ... )
	self.super.ctor(self, json, color)

	self._listView = nil
end

function ArenaRobRiceAchievementRewardLayer:onLayerEnter(  )
	self:showAtCenter(true)
	self:closeAtReturn(true)
	EffectSingleMoving.run(self, "smoving_bounce")

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ROB_RICE_GET_RICE_ACHIEVEMENT, self._onRewards, self)

	self:getLabelByName("Label_Rice_Tag"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Rice_Amount"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Rice_Amount"):setText(G_Me.arenaRobRiceData:getTotalRice())

	self:registerBtnClickEvent("Button_Close_Bottom", function ( ... )
		self:animationToClose()
	end)
	self:registerBtnClickEvent("Button_Close_Top", function ( ... )
		self:animationToClose()
	end)

	self:_initListView()
end

function ArenaRobRiceAchievementRewardLayer:_initListView(  )
	if not self._listView then
		local panel = self:getPanelByName("Panel_ListView")
		self._listView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
		self._listView:setCreateCellHandler(function ( list, index )
			local cell = Cell.new()
			return cell
		end)
		self._listView:setUpdateCellHandler(function ( list, index, cell )
			local achievementInfo = rice_achievement.get(index + 1)
			local achievementState = G_Me.arenaRobRiceData:getAchievementStateList()[index + 1]
			if achievementInfo then
				cell:updateCell(achievementInfo, achievementState, function (  )
					G_HandlersManager.arenaHandler:sendGetRiceAchievement(index + 1)
				end)
			end
		end)

		self._listView:initChildWithDataLength(rice_achievement.getLength())
	end 

	self._listView:scrollToTopLeftCellIndex(self:_getScrollIdx(), 0, 0, function ( ... )	end)
end

function ArenaRobRiceAchievementRewardLayer:onLayerExit(  )
	uf_eventManager:removeListenerWithTarget(self)
end

-- 成就奖励
function ArenaRobRiceAchievementRewardLayer:_onRewards( data )
	if data.ret == 1 then

		local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(data.rewards)
    	uf_notifyLayer:getModelNode():addChild(_layer, 1000)

    	
    	G_Me.arenaRobRiceData:setAchievementId(data.achievement_id)
    else 
    	G_MovingTip:showMovingTip(G_lang:get("LANG_ROB_RICE_MISS_ACHIEVEMENT_TIPS"))
    end   

    self._listView:reloadWithLength(rice_achievement.getLength()) 
    self._listView:scrollToTopLeftCellIndex(self:_getScrollIdx(), 0, 0, function ( ... )	end)
end

-- 可以领取获未达成的成就索引
function ArenaRobRiceAchievementRewardLayer:_getScrollIdx( ... )
	local idx = 0

	local list = G_Me.arenaRobRiceData:getAchievementStateList()
	for i = 1, #list do
		if list[i].state == 2 then
			idx = i - 1
			break
		end
		if list[i].state == 0 then
			idx = i - 1
			break
		end
	end

	return idx
end

return ArenaRobRiceAchievementRewardLayer
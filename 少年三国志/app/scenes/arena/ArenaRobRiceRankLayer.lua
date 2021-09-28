-- 争粮战排行榜

local ArenaRobRiceRankLayer = class("ArenaRobRiceRankLayer", UFCCSModelLayer)

require("app.cfg.rice_prize_info")

local RiceRankItem = require("app.scenes.arena.ArenaRobRiceRankCell")
local AwardRankItem = require("app.scenes.arena.ArenaRobRiceAwardCell")

function ArenaRobRiceRankLayer.create( ... )
	return ArenaRobRiceRankLayer.new("ui_layout/arena_RobRiceRankingLayer.json", Colors.modelColor, ...)
end

function ArenaRobRiceRankLayer:ctor( json, color, ... )
	-- ArenaRobRiceRankLayer.super.ctor(self)
	self.super.ctor(self, json, color)

	self._riceRankListVew = nil
	self._awardRankListView = nil

	self._myRank = G_Me.arenaRobRiceData:getRiceRank()
	if self._myRank <= 0 then
		self._myRank = 201
	end
end


function ArenaRobRiceRankLayer:onLayerEnter( ... )
	-- body
	self:showAtCenter(true)
	self:closeAtReturn(true)

	require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")

	self:registerBtnClickEvent("Button_Close", function ( ... )
		self:_onCloseBtnClicked()
	end)
	self:registerBtnClickEvent("Button_Ok", function ( ... )
		self:_onCloseBtnClicked()
	end)

	self:getLabelByName("Label_myrankTag"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_myrank"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_myrank_Next"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_myrankTag_Next"):createStroke(Colors.strokeBrown, 1)

	self:_initRiceRankListView()
	self:_initAwardRankListView()

	self._tabs = require("app.common.tools.Tabs").new(2, self,self._checkedCallBack, self._uncheckedCallBack) 
    self._tabs:add("CheckBox_Rice", self._riceRankListVew, "Label_CB_Rice_Text")
    self._tabs:add("CheckBox_Award", self._awardRankListView, "Label_CB_Award_Text")
    
    self._tabs:checked("CheckBox_Rice")

    self:_initRankAwardTips()

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ROB_RICE_RANK_LIST, self._initRiceRankListView, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ARENA_USER_INFO, self._onGetUserInfo, self)

    G_HandlersManager.arenaHandler:sendGetRiceRankList()

end

-- 最下面的排行奖励提示
function ArenaRobRiceRankLayer:_initRankAwardTips( ... )
    local lowestRank = rice_prize_info.get(rice_prize_info.getLength()).lower_rank 
	local myRankLabel = self:getLabelByName("Label_myrank")
	myRankLabel:setText(self._myRank)

	local prizeInfoTemp = rice_prize_info.get(1)
	local prizeItemTemp1 = G_Goods.convert(prizeInfoTemp.type_1, prizeInfoTemp.value_1)
	local prizeItemTemp2 = G_Goods.convert(prizeInfoTemp.type_2, prizeInfoTemp.value_2)
	-- local prizeItemTemp3 = G_Goods.convert(prizeInfoTemp.type_3, prizeInfoTemp.value_3)

    if self._myRank > lowestRank then
    	self:showWidgetByName("Panel_award", false)
    	self:showWidgetByName("Label_noAwardTips", true)
    end

    local targetRank = lowestRank
    local currentAwardInfo = nil
    local targetAwardInfo = nil
    for i = 1, rice_prize_info.getLength() do
    	local prizeInfo = rice_prize_info.get(i)
    	if self._myRank >= prizeInfo.upper_rank and self._myRank <= prizeInfo.lower_rank then
    		targetRank = prizeInfo.upper_rank - 1
    		currentAwardInfo = prizeInfo
    		if targetRank > 0 then
    			targetAwardInfo = rice_prize_info.get(i-1)
    		end
    		break
    	end
    end

    if currentAwardInfo == nil then
    	self:showWidgetByName("Panel_Award_Tips_Current", false)
    	self:showWidgetByName("Label_No_Award_Tips", true)

    	local targetRankLabel = self:getLabelByName("Label_myrank_Next")
    	targetRankLabel:setText(200)

    	-- TODO:
    	targetAwardInfo = rice_prize_info.get(rice_prize_info.getLength())

    	self:getLabelByName("Label_Award_1_Next"):setText(targetAwardInfo.size_1)
    	self:getLabelByName("Label_Award_2_Next"):setText(targetAwardInfo.size_2)
    	-- self:getLabelByName("Label_Award_3_Next"):setText(targetAwardInfo.size_3)

    elseif targetRank > 0 then
    	local targetRankLabel = self:getLabelByName("Label_myrank_Next")
    	targetRankLabel:setText(targetRank)

    	self:getLabelByName("Label_Award_1"):setText(currentAwardInfo.size_1)
    	self:getLabelByName("Label_Award_2"):setText(currentAwardInfo.size_2)
    	-- self:getLabelByName("Label_Award_3"):setText(currentAwardInfo.size_3)

    	self:getLabelByName("Label_Award_1_Next"):setText(targetAwardInfo.size_1)
    	self:getLabelByName("Label_Award_2_Next"):setText(targetAwardInfo.size_2)
    	-- self:getLabelByName("Label_Award_3_Next"):setText(targetAwardInfo.size_3)

    else
    	-- 已经是第一名
    	self:showWidgetByName("Panel_Award_Tips_Next", false)

    	self:getLabelByName("Label_Award_1"):setText(currentAwardInfo.size_1)
    	self:getLabelByName("Label_Award_2"):setText(currentAwardInfo.size_2)
    	-- self:getLabelByName("Label_Award_3"):setText(currentAwardInfo.size_3)
    	-- self:showWidgetByName("Label_Award_2_Next", false)
    	-- self:showWidgetByName("Label_Award_3_Next", false)
    end
end

function ArenaRobRiceRankLayer:_initRiceRankListView( ... )
	if self._riceRankListVew ~= nil then
		return
	end

	self._rankList = G_Me.arenaRobRiceData:getRankList()
	if #self._rankList == 0 then
		return
	end

	local panel = self:getPanelByName("Panel_Rice_Rank_List")
	self._riceRankListVew = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
	self._riceRankListVew:setCreateCellHandler(function ( list, index )
		local item = RiceRankItem.new()
		return item
	end)
	self._riceRankListVew:setUpdateCellHandler(function ( list, index, cell )
		local user = self._rankList[index + 1]

		cell:updateCell(user, function ( ... )
			G_HandlersManager.arenaHandler:sendCheckUserInfo(self._rankList[index + 1].user_id)
		end)
	end)

	self._riceRankListVew:initChildWithDataLength(#self._rankList)
end

function ArenaRobRiceRankLayer:_initAwardRankListView( ... )
	if self._awardRankListView ~= nil then
		return
	end

	local panel = self:getPanelByName("Panel_Award_Rank_List")
	self._awardRankListView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
	self._awardRankListView:setCreateCellHandler(function ( list, index )
		local item = AwardRankItem.new()
		return item
	end)
	self._awardRankListView:setUpdateCellHandler(function ( list, index, cell )
		cell:updateCell(rice_prize_info.get(index + 1))
	end)

	self._awardRankListView:initChildWithDataLength(rice_prize_info.getLength())
end

function ArenaRobRiceRankLayer:_onGetUserInfo(data)
	if data.ret == 1 then
		if data.user == nil or data.user.knights == nil or #data.user.knights == 0 then
			G_MovingTip:showMovingTip(G_lang:get("LANG_SERVER_DATA_EXCEPTION"))
			return
		end
		local layer = require("app.scenes.arena.ArenaZhenrong").create(data.user)
		uf_notifyLayer:getModelNode():addChild(layer)
	end
end


function ArenaRobRiceRankLayer:_checkedCallBack(btnName)
	__Log("tab btnName: %s", btnName)
end

function ArenaRobRiceRankLayer:_onCloseBtnClicked( ... )
	self:animationToClose()
end

function ArenaRobRiceRankLayer:onLayerExit(  )
	uf_eventManager:removeListenerWithTarget(self)
end

return ArenaRobRiceRankLayer
-- 开服七日战力排行榜

local ActivitySevenDayFightValueRank = class("ActivitySevenDayFightValueRank", UFCCSNormalLayer)

local ActivitySevenDayFightValueRankAwardCell = require("app.scenes.activity.ActivitySevenDayFightValueRankAwardCell")

-- 奖励物品的数量
ActivitySevenDayFightValueRank.AWARD_NUM = 4
-- 需要显示的上榜玩家数量
ActivitySevenDayFightValueRank.SHOW_TOP_RANKS_NUM = 6
-- 1 表示有排名奖励并且尚未领取
ActivitySevenDayFightValueRank.HAS_AWARD_TO_GET = 1	

function ActivitySevenDayFightValueRank.create( ... )
	local layer = ActivitySevenDayFightValueRank.new("ui_layout/activity_SevenDaysFightValueRankLayer.json", nil, ...)
	return layer
end

function ActivitySevenDayFightValueRank:ctor( json, func, ... )
	-- 各个排名档次的奖励数据
	self._listData = nil
	-- 奖励预览列表
	self._listView = nil

	-- 当前是否处于领奖阶段
	--（从开服到开服第7天的24点为排行榜争夺时间，界面显示奖励预览）
	--（开服第八天0点到第14天24时为领奖时间，进前50则有奖励，领完则活动结束，入口消失；否则连领奖界面都看不到???）
	self._isAwardTime = false

	-- 战力榜前六名玩家的信息
	self._compRankInfoList = nil
	-- 领奖阶段我自己的排名信息
	self._myCompInfo = nil

	-- 奖励预览阶段的计时器
	self._timerHandler = nil
	-- 领奖阶段的计时器
	self._timerHandlerBeforeAward = nil

	self._countDownLabel = nil

	-- 竞争结束时间
	self._compEndTime = G_Me.activityData.sevenDayFightValueRank:getCompEndTime()
	-- 领奖结束时间
	self._awardCloseTime = G_Me.activityData.sevenDayFightValueRank:getAwardCloseTime()

	self.super.ctor(self, json)
end

function ActivitySevenDayFightValueRank:onLayerEnter( ... )
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SEVEN_DAY_FIGHT_VALUE_RANK_COMP_INFO, self._recvCompInfo, self)

	local compLeftSecond = G_ServerTime:getLeftSeconds(self._compEndTime)
	if compLeftSecond > 0 then
		self._isAwardTime = false
	end

	local awardLeftTime = G_ServerTime:getLeftSeconds(self._awardCloseTime)
	if compLeftSecond <= 0 and awardLeftTime > 0 then
		self._isAwardTime = true
	end

	if not self._isAwardTime then
		self:_initBeforeAwardTime()
	else
		self:_initInAwardTime()
	end

	__Log("[ActivitySevenDayFightValueRank:onLayerEnter]")
end

--------------------------------------------排名争夺阶段-----------------------------------------

-- 初始化还处于竞争状态的界面
function ActivitySevenDayFightValueRank:_initBeforeAwardTime( ... )
	self:adapterWidgetHeight("Panel_Bottom","","",400,0)
	self:showWidgetByName("Panel_In_Compitition", true)
	self:showWidgetByName("Panel_After_Compitition", false)

	self:getLabelByName("Label_End_Time_Tag"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Preview_Txt"):createStroke(Colors.strokeBrown, 2)
	self._endTimeLabel = self:getLabelByName("Label_End_Time")
	self._endTimeLabel:createStroke(Colors.strokeBrown, 1)	
	local compEndTimeFormated = G_ServerTime:getDateFormat(self._compEndTime) 
	self._endTimeLabel:setText(compEndTimeFormated)
	self:getLabelByName("Label_Info"):setText(G_lang:get("LANG_ACTIVITY_FIGHT_VALUE_RANK_TIPS", {time = compEndTimeFormated}))

	self:_initListData()
	self:_initListView()

	if not self._timerHandlerBeforeAward then
		self._timerHandlerBeforeAward = G_GlobalFunc.addTimer(5, function()
			self:_checkAwardTimeCome()	         
		end)
	end
end

function ActivitySevenDayFightValueRank:_initListData(  )
	self._listData = G_Me.activityData.sevenDayFightValueRank:getAwardPreviewData()
end

function ActivitySevenDayFightValueRank:_initListView(  )
	if not self._listView then
		self._listView = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_Listview"), LISTVIEW_DIR_VERTICAL)
		self._listView:setSpaceBorder(0, 50)
		self._listView:setCreateCellHandler(function ( list, index )
			return ActivitySevenDayFightValueRankAwardCell.new()
		end)
		self._listView:setUpdateCellHandler(function ( list, index, cell )
			cell:update(self._listData[index + 1])
		end)
		self._listView:initChildWithDataLength(#self._listData)
	else
		self._listView:refreshAllCell()
	end
end

-- 检测是否到领奖时间了
function ActivitySevenDayFightValueRank:_checkAwardTimeCome(  )
	local compLeftSecond = G_ServerTime:getLeftSeconds(self._compEndTime)
	__Log("[ActivitySevenDayFightValueRank:_checkAwardTimeCome] compLeftSecond: " .. compLeftSecond)
	if compLeftSecond <= 0 and self._isAwardTime == false then
		G_HandlersManager.activityHandler:sendGetSevenDayCompInfo()	
		self._isAwardTime = true	
	end
end

-- TODO:数据有异常的情况
function ActivitySevenDayFightValueRank:_recvCompInfo( data )
	__Log("[ActivitySevenDayFightValueRank:_recvCompInfo]")
	local myCompInfo = G_Me.activityData.sevenDayFightValueRank:getMyCompInfo()
	-- 活动结束时如果获得了排名奖励，则显示领奖界面，否则不做任何操作
	if myCompInfo then
		self:_initInAwardTime()
	end
end

--------------------------------------------领奖阶段-----------------------------------------

-- 初始化领奖阶段的界面
function ActivitySevenDayFightValueRank:_initInAwardTime(  )
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SEVEN_DAY_FIGHT_VALUE_RANK_GET_AWARD, self._recvRankAwards, self)

	self._compRankInfoList = G_Me.activityData.sevenDayFightValueRank:getCompRankInfo()
	self._myCompInfo = G_Me.activityData.sevenDayFightValueRank:getMyCompInfo()

	self:showWidgetByName("Panel_In_Compitition", false)
	self:showWidgetByName("Panel_After_Compitition", true)

	local myRankInfoLabel = self:getLabelByName("Label_Rank_Info")
	myRankInfoLabel:createStroke(Colors.strokeBrown, 1)
	
	-- 我的排名信息
	if self._myCompInfo then
		myRankInfoLabel:setText(G_lang:get("LANG_ACTIVITY_FIGHT_VALUE_RANK_MY_RANK_INFO", {num = self._myCompInfo.rank}))
	else
		myRankInfoLabel:setText("")	
	end
	-- 领奖结束倒计时
	self:getLabelByName("Label_Count_Down_Tag"):createStroke(Colors.strokeBrown, 1)
	self._countDownLabel = self:getLabelByName("Label_Count_Down")
	self._countDownLabel:createStroke(Colors.strokeBrown, 1)
	local leftSecond = G_ServerTime:getLeftSeconds(self._awardCloseTime)
	if leftSecond > 0 then
		self:_setCountDownLabel()
	end

	-- 排名前六的玩家
	if self._compRankInfoList then
		for i = 1, ActivitySevenDayFightValueRank.SHOW_TOP_RANKS_NUM do
			self:getLabelByName("Label_Rank_Txt_" .. i):createStroke(Colors.strokeBrown, 1)
			local name = self:getLabelByName("Label_Name_" .. i)
			name:createStroke(Colors.strokeBrown, 1)
			if self._compRankInfoList[i] then
				name:setText(self._compRankInfoList[i].name)
			end
		end
	end

	self:_initMyAward()	

	if not self._timerHandler then
		self._timerHandler = G_GlobalFunc.addTimer(1, function()
	        self:_updateCountDownTime()       
		end)
	end
end

-- 玩家自己可以获得的奖品
function ActivitySevenDayFightValueRank:_initMyAward(  )
	local myAward = G_Me.activityData.sevenDayFightValueRank:getMyAwards()
	if myAward then
		for i=1, ActivitySevenDayFightValueRank.AWARD_NUM do
			local itemInfo = G_Goods.convert(myAward["type_" .. i], myAward["value_" .. i])

			local itemIconImage = self:getImageViewByName("Image_Item_Icon_" .. i)
			itemIconImage:loadTexture(itemInfo.icon)

			local itemBorderImage = self:getImageViewByName("Image_Item_Border_" .. i)
			itemBorderImage:loadTexture(G_Path.getEquipColorImage(itemInfo.quality, itemInfo.type))

			local itemNumLabel = self:getLabelByName("Label_Num_" .. i)
			itemNumLabel:createStroke(Colors.strokeBrown, 1)
			itemNumLabel:setText("x" .. G_GlobalFunc.ConvertNumToCharacter(myAward["size_" .. i]))	

			-- 点击弹出道具信息
			self:registerWidgetClickEvent("Image_Item_Icon_" .. i, function()
				if type(itemInfo.type) == "number" and type(itemInfo.value) == "number" then
		    		require("app.scenes.common.dropinfo.DropInfo").show(itemInfo.type, itemInfo.value)
				end
			end)
		end
		-- 领奖按钮
		self:registerBtnClickEvent("Button_Get_Award", function (  )
			if G_Me.activityData.sevenDayFightValueRank:getMyAwardsFlag() == ActivitySevenDayFightValueRank.HAS_AWARD_TO_GET then 
				G_HandlersManager.activityHandler:sendGetSevenDayAward()
			else
				G_MovingTip:showMovingTip(G_lang:get("LANG_REBEL_BOSS_AWARD_HAS_CLAIMED"))
			end
		end)	

		if G_Me.activityData.sevenDayFightValueRank:getMyAwardsFlag() ~= ActivitySevenDayFightValueRank.HAS_AWARD_TO_GET then
			self:showWidgetByName("Image_Already_Get", true)
    		self:showWidgetByName("Button_Get_Award", false)
		end
	end
end

function ActivitySevenDayFightValueRank:_updateCountDownTime(  )
	local leftSecond = G_ServerTime:getLeftSeconds(self._awardCloseTime)

	if leftSecond > 0 then
	    self:_setCountDownLabel()
	else
		-- 超时
		self:showWidgetByName("Button_Get_Award", false)
		self._countDownLabel:setText(G_lang:get("LANG_TRIGRAMS_END"))
    end
end

function ActivitySevenDayFightValueRank:_setCountDownLabel(  )
	local time = G_ServerTime:getLeftSecondsStringWithDays(self._awardCloseTime)
    -- local day, hour, minute, second = G_ServerTime:getLeftTimeParts(self._awardCloseTime)
    -- if day > 0 then
    -- 	time = day .. G_lang:get("LANG_CROSS_WAR_CD_DAY")
    -- elseif hour > 0 then
    -- 	time = hour .. G_lang:get("LANG_CROSS_WAR_CD_HOUR") .. minute .. G_lang:get("LANG_CROSS_WAR_CD_MINUTE") .. second .. G_lang:get("LANG_CROSS_WAR_CD_SECOND")
    -- elseif minute > 0 then
    -- 	time = minute .. G_lang:get("LANG_CROSS_WAR_CD_MINUTE") .. second .. G_lang:get("LANG_CROSS_WAR_CD_SECOND")
    -- elseif second > 0 then
    -- 	time = second .. G_lang:get("LANG_CROSS_WAR_CD_SECOND")
    -- end
    self._countDownLabel:setText(time)
end

function ActivitySevenDayFightValueRank:_recvRankAwards( awards )
	local layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(awards)
    uf_sceneManager:getCurScene():addChild(layer)
    self:showWidgetByName("Image_Already_Get", true)
    self:showWidgetByName("Button_Get_Award", false)
end

function ActivitySevenDayFightValueRank:onLayerExit( ... )
	if self._timerHandler then
		GlobalFunc.removeTimer(self._timerHandler)
		self._timerHandler = nil
	end
	if self._timerHandlerBeforeAward then
		GlobalFunc.removeTimer(self._timerHandlerBeforeAward)
		self._timerHandlerBeforeAward = nil
	end
end

return ActivitySevenDayFightValueRank
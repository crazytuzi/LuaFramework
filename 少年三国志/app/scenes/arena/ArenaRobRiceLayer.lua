-- 竞技场争粮战

local ArenaRobRiceLayer = class("ArenaRobRiceLayer", UFCCSNormalLayer)

require ("app.cfg.rice_time_info")

function ArenaRobRiceLayer.create( ... )
	return ArenaRobRiceLayer.new("ui_layout/arena_RobRiceLayer.json")
end

function ArenaRobRiceLayer:ctor( ... )
	ArenaRobRiceLayer.super.ctor(self)

	self._rankBoardDeltaPosX = 375
	self._isRankBoradShow = false

	-- 暴击数量
	self._crit = 0

	-- self._gameTime = 0
	-- 当前被抢夺玩家
	self._robUserInfo = nil

	self._endTime = G_Me.arenaRobRiceData:getRobEndTime()
	self._prizeEndTime = G_Me.arenaRobRiceData:getPrizeEndTime()

	G_Me.arenaRobRiceData:resetOldRivalsInfo()

	self:_createStrokes()
	self:_createAfterWarStrokes()
	self:getLabelByName("Label_Rice_Amount"):setText("0")
	self:getLabelByName("Label_Rice_Amount_After_War"):setText("0")
	self:getLabelByName("Label_Rank"):setText(G_lang:get("LANG_ROB_RICE_NO_RANK"))
	self:getLabelByName("Label_Rank_After_War"):setText(G_lang:get("LANG_ROB_RICE_NO_RANK"))
	self:getLabelByName("Label_Current_Lose_Rice"):setText("0")
	self:_addBackgroundEffect()

	-- 先把对手数据显示清空
	for i=1, 4 do
		self:getLabelByName("Label_Opp_Name_" .. i):setText("")
		self:getLabelByName("Label_Fight_Value_" .. i):setText("")
		self:getLabelByName("Label_Opp_Rice_Amount_" .. i):setText("")
		self:getButtonByName("Button_Opp_" .. i):setOpacity(0)
	end
end

function ArenaRobRiceLayer:onLayerEnter( ... )
	self:_initLayer()	
end

function ArenaRobRiceLayer:_initLayer( ... )
	self._refershCD = 0

	self:registerBtnClickEvent("Button_Back", function ( ... )
		self:_onBackBtnClicked()
	end)
	self:registerBtnClickEvent("Button_Help", function ( ... )
		self:_onHelpClicked()
	end)
	self:registerBtnClickEvent("Button_Achievement_Award", function ( ... )
		self:_onAchievementClicked()
	end)
	self:registerBtnClickEvent("Button_Rank_List", function ( ... )
		self:_onRankListBtnClicked()
	end)

	self:registerBtnClickEvent("Button_My_Rice_Repo", function ( ... )
		self:_onMyRepoClicked()
	end)

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ROB_RICE_RANK_LIST, self._onUpdateRankPanel, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ROB_RICE_GET_RICE_ACHIEVEMENT, self._onRewards, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ROB_RICE_GET_RANK_AWARD, self._onRankRewards, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ROB_RICE_FLUSH_USER_RANK, self._onMyRankChanged, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ROB_RICT_NOT_ATTENT, self._onNotAttend, self)
	
	self:_onCrit()

	local leftWarTime = G_ServerTime:getLeftSeconds(self._endTime)
	local leftPrizeTime = G_ServerTime:getLeftSeconds(self._prizeEndTime)

	self._isAfterWar = false

	if leftWarTime <= 0 then
		-- if leftPrizeTime > 0 then
			self:showWidgetByName("Panel_In_War", false)
			self:showWidgetByName("Panel_After_War", true)
			self:showWidgetByName("Panel_My_Info_In_War", false)
			self:showWidgetByName("Panel_My_Info_After_War", true)

			self:_initAfterWarPanel()

			self._isAfterWar = true
		-- end
	else
		self:_initInWarPanel()
	end

	self:_shouldShowTimeLabels()
end

-- 争粮战正在进行中
function ArenaRobRiceLayer:_initInWarPanel( ... )
	-- 活动结束倒计时
	self._robLeftTimeLabel = self:getLabelByName("Label_End_Time")
	self:_initRobLeftTimeLabel()
	self:_initRobRecoverTimeLabel()

	self:showWidgetByName("Label_Cd", false)

	self:_onUpdateUserRice()
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ROB_RICE_UPDATE_USER_RICE, self._onUpdateUserRice, self)
	G_HandlersManager.arenaHandler:sendGetUserRice()
	self:_shouldShowRevengeTips()

 	for i = 1, 4 do
		self:registerBtnClickEvent("Button_Opp_" .. i, handler(self, self._onOppBtnClicked))
	end

	self:registerBtnClickEvent("Button_Real_Time_Rank", function ( ... )
		self:_onRealTimeRankClicked()
	end)

	self:registerBtnClickEvent("Button_Refresh_Opp", function ( ... )
		self:_onRefreshOppsClicked()
	end)

	self:registerBtnClickEvent("Button_Lineup", function ( ... )
		self:_onLineupClicked()
	end)

	self:registerBtnClickEvent("Button_Buy_Attack_Ticket", function ( ... )
		self:_onBuyAttackTickets()
	end)	

	-- 实时玩家排行
	if self._rankBoard == nil then
		self._rankBoard = self:getPanelByName("Panel_Real_Time_Rank")
		self._rankBoard:setPositionX(self._rankBoard:getPositionX() - self._rankBoardDeltaPosX)
		-- 清空默认数据显示
		for i=1, 5 do
			self:getLabelByName("Label_Name_" .. i):setText("")
			self:getLabelByName("Label_Rice_Amount_" .. i):setText("")
			self:getLabelByName("Label_Rank_Panel_Tag_" .. i):setVisible(false)
		end
		self:_showRankBoard()
		self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(5.0), CCCallFunc:create(function ( ... )
			self:_hideRankBoard()
		end)))
	end

	self:showWidgetByName("Image_Time_Recover_Bg", true)

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ROB_RICE_ROB_RICE, self._onRobRice, self)

	self._timer = G_GlobalFunc.addTimer(1, function ( ... )
		if self and self._countDown then 
			self:_countDown()
		end

		-- 刷新CD
		if self._refershCD > 1 then
            self._refershCD = self._refershCD -1 
            self:showWidgetByName("Label_Cd",true)
            self:showWidgetByName("Image_Refresh_Opp",false)
            self:getLabelByName("Label_Cd"):setText(string.format("00:00:0%d",self._refershCD))
            self:getButtonByName("Button_Refresh_Opp"):setEnabled(false)
        else
            self:showWidgetByName("Label_Cd",false)
            self:showWidgetByName("Image_Refresh_Opp",true)
            self:getButtonByName("Button_Refresh_Opp"):setEnabled(true)
        end
	end)
end

-- 争粮战结束后的领奖阶段
function ArenaRobRiceLayer:_initAfterWarPanel( ... )
	-- 需要拉取一下排行
	G_HandlersManager.arenaHandler:sendGetUserRice()
	G_HandlersManager.arenaHandler:sendGetRiceRankList()
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ROB_RICE_UPDATE_USER_RICE, self._onUpdateUserRice, self)

	self._prizeLeftTimeLabel = self:getLabelByName("Label_End_Time_After_War")
	self._prizeLeftTimeLabel:setText("")
	self:showWidgetByName("Image_After_War", true)
	self:showWidgetByName("Image_Bg", false)

	-- 清空默认字符
	for i=1, 3 do 
		self:getLabelByName("Label_After_War_Name_" .. i):setText("")
		self:getLabelByName("Label_Rice_" .. i):setText("")	
	end

	-- 美眉添加呼吸动作
	local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
	local imageMeiMei = self:getImageViewByName("Image_Mei_Mei")
    EffectSingleMoving.run(imageMeiMei, "smoving_idle", nil, {}, 1+ math.floor(math.random()*30))

	local rank = G_Me.arenaRobRiceData:getRiceRank()

	if rank == 0 then
		self:showWidgetByName("Label_Award_Info_Not_Attend", false)
		self:showWidgetByName("Label_Award_Info_No_Award", true)
		self:getLabelByName("Label_Award_Info_No_Award"):createStroke(Colors.strokeBrown, 1)
		self:showWidgetByName("Label_Award_Info", false)
		self:showWidgetByName("Button_Get", false)
	elseif rank > 0 and rank <= 200 then
		self:showWidgetByName("Label_Award_Info_Not_Attend", false)
		if G_Me.arenaRobRiceData:getRankAward() == 0 then
			self:showWidgetByName("Button_Get", true)
			self:showWidgetByName("Image_Already_Got", false)
		else
			self:showWidgetByName("Button_Get", false)
			self:showWidgetByName("Image_Already_Got", true)
		end
	else 
		-- 未参与
		self:showWidgetByName("Label_Award_Info", false)
		self:showWidgetByName("Label_Award_Info_Not_Attend", true)
		self:getLabelByName("Label_Award_Info_Not_Attend"):createStroke(Colors.strokeBrown, 1)
		self:showWidgetByName("Button_Get", false)
		self:getLabelByName("Label_Rice_Amount_After_War"):setText(0)
	end

	self:registerBtnClickEvent("Button_Get", function ( ... )
		local leftPrizeTime = G_ServerTime:getLeftSeconds(self._prizeEndTime)
		if leftPrizeTime >= 0 then
			require("app.scenes.arena.ArenaRobGetRankAwardLayer").show()
		else
			G_MovingTip:showMovingTip(G_lang:get("LANG_ROB_RICE_AWARD_TIME_OUT"))
		end
	end)

	self._afterWarTimer = G_GlobalFunc.addTimer(1, function ( ... )
		if self and self._countDownAfterWar then 
			self:_countDownAfterWar()
		end
	end)
end

-- In war 阶段界面的描边
function ArenaRobRiceLayer:_createStrokes( ... )
	self:getLabelByName("Label_End_Time_Tag"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_End_Time"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Rank_Tag"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Rank"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Rice_Tag"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Rice_Amount"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Current_Lose_Tag_1"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Current_Lose_Tag_2"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Current_Lose_Rice"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Opp_Name_1"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Fight_Value_1"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Opp_Rice_Amount_1"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Opp_Name_2"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Fight_Value_2"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Opp_Rice_Amount_2"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Opp_Name_3"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Fight_Value_3"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Opp_Rice_Amount_3"):createStroke(Colors.strokeBrown, 1)	
	self:getLabelByName("Label_Opp_Name_4"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Fight_Value_4"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Opp_Rice_Amount_4"):createStroke(Colors.strokeBrown, 1)	
	self:getLabelByName("Label_Attack_Times_Tag"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Attack_Times"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Recover_Time"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Recover_Time_Tag"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Recover_Time_Tag_2"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Cd"):createStroke(Colors.strokeBrown, 1)

	for i = 1, 4 do
		self:getLabelByName("Label_Opp_Rice_Amount_Tagpre_" .. i):createStroke(Colors.strokeBrown, 1)
		self:getLabelByName("Label_Opp_Rice_Amount_Tagpost_" .. i):createStroke(Colors.strokeBrown, 1)
	end

	for i = 1, 5 do
		self:getLabelByName("Label_Rank_Panel_Tag_" .. i):createStroke(Colors.strokeBrown, 1)
		self:getLabelByName("Label_Name_" .. i):createStroke(Colors.strokeBrown, 1)
		self:getLabelByName("Label_Rice_Amount_" .. i):createStroke(Colors.strokeBrown, 1)
	end
end

-- 领奖时间界面中的描边
function ArenaRobRiceLayer:_createAfterWarStrokes( ... )
	self:getLabelByName("Label_End_Time_Tag_After_War"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_End_Time_After_War"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Rank_Tag_After_War"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Rank_After_War"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Rice_Tag_After_War"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Rice_Amount_After_War"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Award_Info"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_After_War_Name_1"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_After_War_Name_2"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_After_War_Name_3"):createStroke(Colors.strokeBrown, 1)	
end

-- 添加地图特效
function ArenaRobRiceLayer:_addBackgroundEffect(  )
	local tParent = self:getImageViewByName("Image_Bg")
	local EffectNode = require "app.common.effects.EffectNode"
	local eff = tParent:getNodeByTag(33)
	if not eff and require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
		eff = EffectNode.new("effect_xstiaozhan", function(event, frameIndex) end)
		eff:play()
		local tSize = tParent:getContentSize()
		eff:setPosition(ccp(0, 0))
		eff:setScale(1/tParent:getScale())
		tParent:addNode(eff, 1, 33)
	end
end

-- 刷新弹出的排行榜
function ArenaRobRiceLayer:_onUpdateRankPanel( ... )
	local rankList = G_Me.arenaRobRiceData:getRankList()

	if #rankList < 1 then return end

	for i = 1, 5 do
		self:getLabelByName("Label_Rank_Panel_Tag_" .. i):setVisible(true)
	end

	for i=1, math.min(5, #rankList) do
		self:getLabelByName("Label_Name_" .. i):setText(rankList[i].name)
		local knight = knight_info.get(rankList[i].base_id)
		-- self:getLabelByName("Label_Name_" .. i):setColor(Colors.qualityColors[knight.quality])
		self:getLabelByName("Label_Rice_Amount_" .. i):setText(G_lang:get("LANG_ROB_RICE_RICE", {num = rankList[i].rice}))
		self:getLabelByName("Label_Rice_Amount_" .. i):setVisible(true)
	end

	if #rankList < 5 then
		for i = (#rankList + 1), 5 do 
			self:getLabelByName("Label_Name_" .. i):setText(G_lang:get("LANG_ROB_RICE_WAIT_RANK"))
			self:getLabelByName("Label_Rice_Amount_" .. i):setVisible(false)
		end
	end

	if self._isAfterWar then
		-- 活动结束更新领奖界面排行榜
		for i=1, math.min(3, #rankList) do 
			self:getLabelByName("Label_After_War_Name_" .. i):setText(rankList[i].name)
			local knight = knight_info.get(rankList[i].base_id)
			self:getLabelByName("Label_After_War_Name_" .. i):setColor(Colors.qualityColors[knight.quality])
			self:getLabelByName("Label_Rice_" .. i):setText(rankList[i].rice)	
		end
		if #rankList < 3 then
			for i = (#rankList + 1), 3 do
				self:getLabelByName("Label_After_War_Name_" .. i):setText(G_lang:get("LANG_ROB_RICE_WAIT_RANK"))
				self:getLabelByName("Label_Rice_" .. i):setText(0)
			end
		end
	end

	local myRiceRank = G_Me.arenaRobRiceData:getRiceRank()
	if myRiceRank == 0 then
		self:getLabelByName("Label_Rank"):setText(G_lang:get("LANG_ROB_RICE_NO_RANK"))
		self:getLabelByName("Label_Rank_After_War"):setText(G_lang:get("LANG_ROB_RICE_NO_RANK"))
	else		
		self:getLabelByName("Label_Rank"):setText(myRiceRank)
		self:getLabelByName("Label_Rank_After_War"):setText(myRiceRank)
	end
end

-- 收到网络返回，更新显示
function ArenaRobRiceLayer:_onUpdateUserRice(  )
	if G_Me.arenaRobRiceData:hasRivalsChanged() then
		self:_updateOppInfo()
	end

	local myRiceRank = G_Me.arenaRobRiceData:getRiceRank()
	local myTotalRice = G_Me.arenaRobRiceData:getTotalRice()

	if myRiceRank == 0 then
		self:getLabelByName("Label_Rank"):setText(G_lang:get("LANG_ROB_RICE_NO_RANK"))
		self:getLabelByName("Label_Rank_After_War"):setText(G_lang:get("LANG_ROB_RICE_NO_RANK"))
	else		
		self:getLabelByName("Label_Rank"):setText(myRiceRank)
		self:getLabelByName("Label_Rank_After_War"):setText(myRiceRank)
	end
	-- self:getLabelByName("Label_Rice_Amount"):setText(myTotalRice)	
	self:_updateRiceAmount()
	self:getLabelByName("Label_Attack_Times"):setText(G_Me.arenaRobRiceData:getRobToken())
	-- local currLoseRiceLabel = self:getLabelByName("Label_Current_Lose_Rice")
	-- currLoseRiceLabel:setText(math.floor(G_Me.arenaRobRiceData:getInitRice() * 0.15))
	-- self:getLabelByName("Label_Current_Lose_Tag_2"):setPositionX(currLoseRiceLabel:getPositionX() + currLoseRiceLabel:getContentSize().width)
	self:_updateCurrentLostRiceAmount()

	self:getLabelByName("Label_Rice_Amount_After_War"):setText(G_Me.arenaRobRiceData:getTotalRice())

	self:_checkAchievement()

	-- 领奖阶段
	if self._isAfterWar then
		self:showWidgetByName("Label_Award_Info_Not_Attend", false)
		self:showWidgetByName("Label_Award_Info_No_Award", false)
		self:showWidgetByName("Label_Award_Info", false)
		-- __Log("----------------rank------------%d", myRiceRank)
		if myRiceRank == 0 then
			self:showWidgetByName("Label_Award_Info_No_Award", true)
			local txt = G_lang:get("LANG_ROB_RICE_RANK_AWARD_TIPS_2", {rice = myTotalRice})
			self:getLabelByName("Label_Award_Info_No_Award"):setText(txt)
		elseif myRiceRank > 0 and myRiceRank <= 200 then 
			self:showWidgetByName("Label_Award_Info", true)
			self:getLabelByName("Label_Award_Info"):setText(G_lang:get("LANG_ROB_RICE_RANK_AWARD_TIPS_1", {rice = myTotalRice, rank = myRiceRank}))
			if G_Me.arenaRobRiceData:getRankAward() == 0 then
				self:showWidgetByName("Button_Get", true)
				self:showWidgetByName("Image_Already_Got", false)
			else
				self:showWidgetByName("Button_Get", false)
				self:showWidgetByName("Image_Already_Got", true)
			end			
		end		
	end

	-- uf_eventManager:removeListenerWithEvent(self, G_EVENTMSGID.EVENT_ROB_RICE_UPDATE_USER_RICE)
end

function ArenaRobRiceLayer:_updateOppInfo(  )
	local oppList = G_Me.arenaRobRiceData:getOppList()
	if not oppList or #oppList <= 0 then return end
	local len = #oppList
	if #oppList > 4 then
		len = 4
	end
	local EffectNode = require "app.common.effects.EffectNode"

	for i = 1, tonumber(len) do	
		local btn = self:getButtonByName("Button_Opp_" .. i)
		btn:setTouchEnabled(false)
		btn:setOpacity(0)
		local panleEffect = self:getPanelByName("Panel_Opp_Effect_" .. i)
		local appearEffect = panleEffect:getNodeByTag(33)
		if appearEffect == nil then
			appearEffect = EffectNode.new("effect_card_show", function(event)
								if event == "show" then
									btn:runAction(CCFadeIn:create(0.5))
	        	            	elseif event == "finish" then
	            	            	appearEffect:stop()
	            	            	btn:setOpacity(255)
	            	            	btn:setTouchEnabled(true)
	                	        	G_Me.arenaRobRiceData:updateOldRivalsInfo()
	                    		end
	                		end)
			appearEffect:setTag(33)
			appearEffect:setScale(0.8)
			self:getPanelByName("Panel_Opp_Effect_" .. i):addNode(appearEffect)
		end
		appearEffect:setVisible(true)
		appearEffect:play()

		local baseId = oppList[i].baseId
		local knight = knight_info.get(baseId)		
		self:getLabelByName("Label_Opp_Name_" .. i):setText(oppList[i].name)		
		self:getLabelByName("Label_Opp_Name_" .. i):setColor(Colors.qualityColors[knight.quality])
		self:getLabelByName("Label_Fight_Value_" .. i):setText(G_lang:get("LANG_ROB_RICE_FIGHT_VAULE", {num = GlobalFunc.ConvertNumToCharacter(oppList[i].fightValue)}))
		local oppRiceLabel = self:getLabelByName("Label_Opp_Rice_Amount_" .. i)
		oppRiceLabel:setText(tostring(math.floor(oppList[i].initRice * 0.15)))
		local oppRiceLabelPostTag = self:getLabelByName("Label_Opp_Rice_Amount_Tagpost_" .. i)
		oppRiceLabelPostTag:setPositionX(oppRiceLabel:getPositionX() + oppRiceLabel:getContentSize().width)

		-- 同军团
		if G_Me.legionData._corpDetail and G_Me.legionData._corpDetail.id == oppList[i].corpId and oppList[i].corpId ~= 0 then
			self:showWidgetByName("Image_Corp_" .. i, true)
		else 
			self:showWidgetByName("Image_Corp_" .. i, false)
		end

		-- 根据粮草数量显示不同的粮仓图片
		local btn = self:getButtonByName("Button_Opp_" .. i)
		local totalRice = oppList[i].initRice + oppList[i].growthRice
		if totalRice <= 10000 then
			btn:loadTextureNormal("ui/arena/liangcang_1.png")
		elseif totalRice > 10000 and totalRice <= 20000 then
			btn:loadTextureNormal("ui/arena/liangcang_2.png")
		else
			btn:loadTextureNormal("ui/arena/liangcang_3.png")
		end
	end
end

-- 更新总粮草数的显示
function ArenaRobRiceLayer:_updateRiceAmount()
	local riceAmountLabel = self:getLabelByName("Label_Rice_Amount")
	local oldRice = G_Me.arenaRobRiceData:getOldTotalRice()
	local newRice = G_Me.arenaRobRiceData:getTotalRice()

	if oldRice == newRice or oldRice == 0 then 
		riceAmountLabel:setText(tostring(newRice))
		return
	end

	local addTipsLabel = self:getLabelByName("Label_Total_Add")
	self:_runNumGrowupAnim(addTipsLabel, riceAmountLabel, newRice, oldRice, function (  )
		G_Me.arenaRobRiceData:setOldGrowthRice(G_Me.arenaRobRiceData:getGrowthRice())
	end)
end

-- 更新被抢夺会损失粮草数
function ArenaRobRiceLayer:_updateCurrentLostRiceAmount()
	local label = self:getLabelByName("Label_Current_Lose_Rice")
	local oldRice = math.floor(G_Me.arenaRobRiceData:getOldInitRice() * 0.15)
	local newRice = math.floor(G_Me.arenaRobRiceData:getInitRice() * 0.15)
	if oldRice == newRice or oldRice == 0 then 
		label:setText(tostring(newRice))
	    self:getLabelByName("Label_Current_Lose_Tag_2"):setPositionX(label:getPositionX() + label:getContentSize().width)
		return
	end

	local addTipsLabel = self:getLabelByName("Label_Lose_Add")
	self:_runNumGrowupAnim(addTipsLabel, label, newRice, oldRice, function ()
		self:getLabelByName("Label_Current_Lose_Tag_2"):setPositionX(label:getPositionX() + label:getContentSize().width)
		G_Me.arenaRobRiceData:setOldInitRice(G_Me.arenaRobRiceData:getInitRice())
	end)
end

function ArenaRobRiceLayer:_runNumGrowupAnim( labelAdd, labelNum, newNum, oldNum, callback )	
	if newNum > oldNum then
		labelAdd:setText("+" .. tostring(newNum - oldNum))
	else
		labelAdd:setText(tostring(newNum - oldNum))
	end
	local arr = CCArray:create()
    arr:addObject(CCShow:create())
    arr:addObject(CCCallFunc:create(function()
        local _time = 0.5
        local growupNumber = CCNumberGrowupAction:create(oldNum, newNum, _time, function ( number )
                        labelNum:setText(tostring(number))
                        if callback then
                        	callback()
                        end
                    end)
        local actionScale = CCSequence:createWithTwoActions(CCScaleTo:create(_time/2, 2), CCScaleTo:create(_time/2, 1))
        local action = CCSpawn:createWithTwoActions(growupNumber, actionScale)
		labelNum:runAction(action)
	end))
    arr:addObject(CCDelayTime:create(1))
    arr:addObject(CCHide:create())
    labelAdd:runAction(CCSequence:create(arr))
end

function ArenaRobRiceLayer:_onMyRankChanged( ... )
	if G_Me.arenaRobRiceData:getRiceRank() then
		self:getLabelByName("Label_Rank"):setText(G_lang:get("LANG_ROB_RICE_NO_RANK"))
	else
		self:getLabelByName("Label_Rank"):setText(G_Me.arenaRobRiceData:getRiceRank())
	end
end

-- 是否有复仇的红点
function ArenaRobRiceLayer:_shouldShowRevengeTips( ... )
	-- 拉取复仇对象数据用于显示我的粮仓红点提示
	-- __Log("-----------G_Me.arenaRobRiceData:getRevengeToken()---------%d", G_Me.arenaRobRiceData:getRevengeToken())
	if G_Me.arenaRobRiceData:hasEnemyToRevenge() and G_Me.arenaRobRiceData:getRevengeToken() > 0 then
		self:showWidgetByName("Image_Repo_Tips", true)
	elseif (not self._isAfterWar) then
		self:showWidgetByName("Image_Repo_Tips", false)
		uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ROB_RICE_GET_RICE_ENEMY, self._onGetRiceEnemies, self)
		G_HandlersManager.arenaHandler:sendGetRiceEnemyInfo()
	else
		self:showWidgetByName("Image_Repo_Tips", false)
	end
end

-- 收到网络返回仇人数据
function ArenaRobRiceLayer:_onGetRiceEnemies( ... )
	if G_Me.arenaRobRiceData:hasEnemyToRevenge() and G_Me.arenaRobRiceData:getRevengeToken() > 0 then
		self:showWidgetByName("Image_Repo_Tips", true)
	else
		self:showWidgetByName("Image_Repo_Tips", false)
	end
end

-- 收到争夺粮草协议的返回
function ArenaRobRiceLayer:_onRobRice( data )
	if data.ret == 1 then 
        local callback = function(result)
            if not self or (G_SceneObserver:getSceneName() ~= "ArenaScene" and G_SceneObserver:getSceneName() ~= "RobRiceBattleScene") then
                __Log("已经不在这场景了")
                return
            end
            if not data then
                return
            end
            if data.battle_report.is_win == true then
                if self and self._challengeSuccess ~= nil then
                    self:_challengeSuccess(data,result)
                end
            else
                if self and self._challengeFailed ~= nil then
                    self:_challengeFailed(data,result)
                end
            end
        end
        G_Loading:showLoading(function ( ... )
            --创建战斗场景
            if data == nil then 
                return
            end
            if not self then
                return
            end

            local enemy = {}

            self.scene = require("app.scenes.arena.RobRiceBattleScene"):new(data.battle_report, enemy, callback)
            self.scene.__EFFECT_FINISH_CALLBACK__ = self.__EFFECT_FINISH_CALLBACK__
            uf_sceneManager:pushScene(self.scene)
        end, 
        function ( ... )
            if self.scene ~= nil then
                self.scene:play()
            end
            --开始播放战斗
        end)
    else
        self:setTouchEnabled(true)
    end  
end

--挑战成功
function ArenaRobRiceLayer:_challengeSuccess(data,result)
    -- self:setTouchEnabled(false)
    local challageCallback = function()
        if not self or (G_SceneObserver:getSceneName() ~= "ArenaScene" and G_SceneObserver:getSceneName() ~= "RobRiceBattleScene") then
            __Log("已经不在这场景了")
            return
        end
        if not data then
            return
        end

        self._crit = data.rob_crit_rice
        uf_sceneManager:popScene()        
    end

    local __shengwang = 0

    for i,v in ipairs(data.rewards) do         
        if v.type == G_Goods.TYPE_SHENGWANG then
            __shengwang = v.size
        end
    end

    local FightEnd = require("app.scenes.common.fightend.FightEnd")
    local picks = nil

    __Log("显示FightEnd.show")
    FightEnd.show(FightEnd.TYPE_ROB_RICE,true,
        {       
        	robrice_win = data.rob_init_rice,    
            rice=data.rob_growth_rice,
            foster_pill=data.rewards[2].size,
            rice_prestige=__shengwang,
            awards=data.rewards, 
            opponent = self._robUserInfo          
        },
        challageCallback,result)
end

--挑战失败
function ArenaRobRiceLayer:_challengeFailed(data,result)
    self:setTouchEnabled(true)
    
    local __shengwang = 0
    for i,v in ipairs(data.rewards) do 
        if v.type == G_Goods.TYPE_SHENGWANG then
            __shengwang = v.size
        end
    end

    local FightEnd = require("app.scenes.common.fightend.FightEnd")
    FightEnd.show(FightEnd.TYPE_ROB_RICE,false,
        {
        rice_prestige=__shengwang,
        awards=data.rewards
        },
        function()  
            if not self or (G_SceneObserver:getSceneName() ~= "ArenaScene" and G_SceneObserver:getSceneName() ~= "RobRiceBattleScene") then
                __Log("已经不在这场景了")
                return
            end
           
            uf_sceneManager:popScene()
        end,result)

end
------------------------------------------FIGHT END---------------------------------
-- 这一轮没有参加抢夺
function ArenaRobRiceLayer:_onNotAttend(  )
	self:showWidgetByName("Label_Award_Info", false)
	self:showWidgetByName("Label_Award_Info_No_Award", false)
	self:showWidgetByName("Label_Award_Info_Not_Attend", true)
	self:getLabelByName("Label_Rice_Amount_After_War"):setText(0)
	self:getLabelByName("Label_Award_Info_Not_Attend"):createStroke(Colors.strokeBrown, 1)
end

-- 检查是否达到成就
function ArenaRobRiceLayer:_checkAchievement(  )
	if G_Me.arenaRobRiceData:hasAchievementToRecieve() then
		self:showWidgetByName("Image_Tips_Point", true)
	else
		self:showWidgetByName("Image_Tips_Point", false)
	end
end

-- 成就奖励
function ArenaRobRiceLayer:_onRewards( data )
	if data.ret == 1 then
		self:showWidgetByName("Image_Tips_Point", false)

		local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(data.rewards)
    	uf_notifyLayer:getModelNode():addChild(_layer, 1000)

    	G_Me.arenaRobRiceData:setAchievementId(data.achievement_id)
    	self:_checkAchievement()
    else 
    	self:showWidgetByName("Image_Tips_Point", false)
    	G_MovingTip:showMovingTip(G_lang:get("LANG_ROB_RICE_MISS_ACHIEVEMENT_TIPS"))
    end    
end

-- 排行奖励
function ArenaRobRiceLayer:_onRankRewards( data )
	if data.ret == 1 then
		local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(data.rewards)
	    uf_notifyLayer:getModelNode():addChild(_layer,1000)

	    self:showWidgetByName("Image_Already_Got", true)
	    self:showWidgetByName("Button_Get", false)
	    G_Me.arenaRobRiceData:setRankAward(1)
	end
end

-- 暴击提示
function ArenaRobRiceLayer:_onCrit()
	if self._crit > 0 then
		require("app.scenes.arena.ArenaRobRiceCritPopupLayer").show(self._crit)
		self._crit = 0
	end
end

function ArenaRobRiceLayer:_onOppBtnClicked( widget )

	if G_Me.arenaRobRiceData:getRobToken() <= 0 then
		self:_onBuyAttackTickets()
		return
	end	

	local btnName = widget:getName()
	local idx = string.sub(btnName, string.len(btnName), string.len(btnName))
	-- __Log(idx)
	local oppInfo = G_Me.arenaRobRiceData:getOppInfo(tonumber(idx))
	if oppInfo then
		if G_Me.legionData._corpDetail and G_Me.legionData._corpDetail.id == oppInfo.corpId and oppInfo.corpId ~= 0 then
			local str = G_lang:get("LANG_ROB_RICE_SAME_CORP_NOTICE")
		    MessageBoxEx.showYesNoMessage(
		        nil,
		        str,
		        false,
		        function()
		            local userId = oppInfo.userId
					if G_Me.arenaRobRiceData:getRobToken() > 0 then
						uf_eventManager:removeListenerWithEvent(self, G_EVENTMSGID.EVENT_ROB_RICE_UPDATE_USER_RICE)
					end
					G_HandlersManager.arenaHandler:sendRobRice(userId)
					self._robUserInfo = oppInfo
		        end,
		        nil, 
		        nil,
		        MessageBoxEx.OKNOButton.OKNOBtn_Default)
		else 
			local userId = oppInfo.userId
			if G_Me.arenaRobRiceData:getRobToken() > 0 then
				uf_eventManager:removeListenerWithEvent(self, G_EVENTMSGID.EVENT_ROB_RICE_UPDATE_USER_RICE)
			end
			G_HandlersManager.arenaHandler:sendRobRice(userId)
			self._robUserInfo = oppInfo
		end		
	end
end

function ArenaRobRiceLayer:_onRankListBtnClicked( ... )
	local layer = require("app.scenes.arena.ArenaRobRiceRankLayer").create()
    uf_sceneManager:getCurScene():addChild(layer)
end

function ArenaRobRiceLayer:_onMyRepoClicked( ... )
	if self._isAfterWar then
		G_MovingTip:showMovingTip(G_lang:get("LANG_ROB_RICE_ACTIVITY_OVER"))
		return
	end

	local layer = require("app.scenes.arena.ArenaRobRiceMyRepoLayer").create(function ( ... )
		self:_shouldShowRevengeTips()
	end)
	uf_sceneManager:getCurScene():addChild(layer)
end

function ArenaRobRiceLayer:_onRefreshOppsClicked( ... )
	
	-- self._gameTime = 0
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ROB_RICE_UPDATE_USER_RICE, self._onUpdateUserRice, self)
	G_HandlersManager.arenaHandler:sendFlushRiceRivals()
	self._refershCD = 6
end

function ArenaRobRiceLayer:_onLineupClicked(  )
	require("app.scenes.hero.HerobuZhengLayer").showBuZhengLayer()
end

function ArenaRobRiceLayer:_onRealTimeRankClicked( ... )
	if self._isRankBoradShow then
		self:_hideRankBoard()
	else
		self:_showRankBoard()
	end
end

function ArenaRobRiceLayer:_onAchievementClicked(  )
	require("app.scenes.arena.ArenaRobRiceAchievementRewardLayer").show()
end

function ArenaRobRiceLayer:_hideRankBoard( ... )
	if self._isRankBoradShow == false then return end

	self._isRankBoradShow = false
	local move = CCMoveBy:create(0.2, ccp(-self._rankBoardDeltaPosX, 0))
	self._rankBoard:runAction(move)
end

function ArenaRobRiceLayer:_showRankBoard( ... )
	if self._isRankBoradShow == true then return end

	G_HandlersManager.arenaHandler:sendGetRiceRankList()

	self._isRankBoradShow = true
	local move = CCMoveBy:create(0.2, ccp(self._rankBoardDeltaPosX, 0))
	self._rankBoard:runAction(move)
end

function ArenaRobRiceLayer:_onBuyAttackTickets( ... )
	if G_Me.arenaRobRiceData:getTokenRemainBuyTimes(0) > 0 then
		require("app.scenes.arena.ArenaRobBuyPanel").show(0)
	else
		local myVip = G_Me.userData.vip
		if myVip >= 12 then
			G_MovingTip:showMovingTip(G_lang:get("LANG_ROB_RICE_BUY_HIT_MAX"))
		else
			G_GlobalFunc.showVipNeedDialog(require("app.const.VipConst").ROBRICE)		
		end
	end
end

function ArenaRobRiceLayer:_onBackBtnClicked( ... )
	uf_sceneManager:replaceScene(require("app.scenes.arena.ArenaScene").new())
end

function ArenaRobRiceLayer:_onHelpClicked( ... )
	require("app.scenes.common.CommonHelpLayer").show(
		{
			{title = G_lang:get("LANG_ROB_RICE_HELP_TITLE_1"), content = G_lang:get("LANG_ROB_RICE_HELP_CONTENT_1")},
			{title = G_lang:get("LANG_ROB_RICE_HELP_TITLE_2"), content = G_lang:get("LANG_ROB_RICE_HELP_CONTENT_2")},
			{title = G_lang:get("LANG_ROB_RICE_HELP_TITLE_3"), content = G_lang:get("LANG_ROB_RICE_HELP_CONTENT_3")}
		})
end

-- 一进界面就判断是否需要显示时间
function ArenaRobRiceLayer:_shouldShowTimeLabels( ... )
	-- 活动倒计时
	local day, hour, min, sec = G_ServerTime:getLeftTimeParts(self._prizeEndTime)
	self:getLabelByName("Label_End_Time_After_War"):setText(self:_getLeftTimeString(day, hour, min, sec))

	-- 恢复倒计时
	local currRobToken = G_Me.arenaRobRiceData:getRobToken()

	local basicFigureInfo = basic_figure_info.get(5)
	-- 服务器返回时时间戳是增长到最大值所需要的时间
	local recoverTime = G_Me.arenaRobRiceData:getRobTokenRefreshTime() - (basicFigureInfo.time_limit - currRobToken) * basicFigureInfo.unit_time + basicFigureInfo.unit_time

	local leftTimeString = G_ServerTime:getLeftSecondsString(recoverTime)
	if leftTimeString ~= "-" and currRobToken < basicFigureInfo.time_limit then
		local day, hour, min, sec = G_ServerTime:getLeftTimeParts(recoverTime)
		leftTimeString = G_lang:get("LANG_ROB_RICE_FORMAT_TIME_1", {minute = min, second = sec})
		self:getLabelByName("Label_Recover_Time"):setText(leftTimeString)
	else
		self:showWidgetByName("Image_Time_Recover_Bg", false)
	end

	local leftWarTime = G_ServerTime:getLeftSeconds(self._endTime)
	self:showWidgetByName("Image_Time_Recover_Bg", leftWarTime > 0)

end

-- 进界面时就先计算一下活动结束时间，并显示
function ArenaRobRiceLayer:_initRobLeftTimeLabel(  )
	local basicFigureInfo = basic_figure_info.get(5)
	local day, hour, min, sec = G_ServerTime:getLeftTimeParts(self._endTime)
	self._robLeftTimeLabel:setText(self:_getLeftTimeString(day, hour, min, sec))
end

-- 进界面时先计算挑战次数恢复时间，并显示
function ArenaRobRiceLayer:_initRobRecoverTimeLabel(  )
	local basicFigureInfo = basic_figure_info.get(5)
	local recoverTime = G_Me.arenaRobRiceData:getRobTokenRefreshTime() + basicFigureInfo.unit_time
	local day, hour, min, sec = G_ServerTime:getLeftTimeParts(recoverTime)
	if min == 0 then min = 59 end
	if sec == 0 then sec = 59 end
	leftTimeString = G_lang:get("LANG_ROB_RICE_FORMAT_TIME_1", {minute = min, second = sec})
	local recoverTimeLabel = self:getLabelByName("Label_Recover_Time")
	recoverTimeLabel:setText(leftTimeString)
	-- 调整后面文字的位置
	local recoverTimeTag2 = self:getLabelByName("Label_Recover_Time_Tag_2")
	recoverTimeTag2:setPositionX(recoverTimeLabel:getPositionX() + recoverTimeLabel:getContentSize().width + 5)
end

function ArenaRobRiceLayer:_countDown( ... )
	local basicFigureInfo = basic_figure_info.get(5)

	local day, hour, min, sec = G_ServerTime:getLeftTimeParts(self._endTime)	

	self._robLeftTimeLabel:setText(self:_getLeftTimeString(day, hour, min, sec))

	local currRobToken = G_Me.arenaRobRiceData:getRobToken()

	-- 服务器返回时时间戳是增长满所需要的时间
	local recoverTime = G_Me.arenaRobRiceData:getRobTokenRefreshTime() + basicFigureInfo.unit_time

	local leftTimeString = G_ServerTime:getLeftSecondsString(recoverTime)

	-- __Log("=========leftTimeString %s==========", leftTimeString)
	local day, hour, min, sec = G_ServerTime:getLeftTimeParts(recoverTime)

	if (leftTimeString == "-" or (min == 0 and sec == 0)) and  G_NetworkManager:isConnected() then
		G_Me.arenaRobRiceData:setRobTokenRefreshTime(G_ServerTime:getTime() + basicFigureInfo.unit_time)
		G_Me.arenaRobRiceData:setRobToken(currRobToken + basicFigureInfo.unit_recover)

		self:getLabelByName("Label_Attack_Times"):setText(G_Me.arenaRobRiceData:getRobToken())
	else 
		local day, hour, min, sec = G_ServerTime:getLeftTimeParts(recoverTime)
		leftTimeString = G_lang:get("LANG_ROB_RICE_FORMAT_TIME_1", {minute = min, second = sec})

		local recoverTimeLabel = self:getLabelByName("Label_Recover_Time")
		recoverTimeLabel:setText(leftTimeString)
		-- 调整后面文字的位置
		local recoverTimeTag2 = self:getLabelByName("Label_Recover_Time_Tag_2")
		recoverTimeTag2:setPositionX(recoverTimeLabel:getPositionX() + recoverTimeLabel:getContentSize().width + 5)

	end

	-- 隔一段时间刷新自己粮草等信息，否则玩家粮草被抢了不能尽快知道
	-- self._gameTime = self._gameTime + 1
	-- if (not self._isAfterWar) and self._gameTime % 5 == 0 then
	-- 	if not G_NetworkManager:isConnected() then
 --            return
 --        end
		-- G_HandlersManager.arenaHandler:sendGetUserRice()
	-- end

	-- if (not self._isAfterWar) and self._gameTime % 8 == 0 then
	-- 	if not G_NetworkManager:isConnected() then
 --            return
 --        end
	-- 	self:_onUpdateUserRice()
	-- end

end

function ArenaRobRiceLayer:_countDownAfterWar( ... )
	local day, hour, min, sec = G_ServerTime:getLeftTimeParts(self._prizeEndTime)
	self._prizeLeftTimeLabel:setText(self:_getLeftTimeString(day, hour, min, sec))
end

function ArenaRobRiceLayer:_getLeftTimeString( day, hour, min, sec )	
	local timeLeft = ""
	if day > 0 then
		timeLeft = timeLeft .. G_lang:get("LANG_ROB_RICE_FORMAT_TIME_2", {day = day, hour = hour, minute = min, second = sec})
	elseif hour > 0 then
		timeLeft = timeLeft .. G_lang:get("LANG_ROB_RICE_FORMAT_TIME_3", {hour = hour, minute = min, second = sec})
	elseif min > 0 then
		timeLeft = timeLeft .. G_lang:get("LANG_ROB_RICE_FORMAT_TIME_4", {minute = min, second = sec})
	elseif sec > 0 then
		timeLeft = timeLeft .. G_lang:get("LANG_ROB_RICE_FORMAT_TIME_5", {second = sec})
	else
		timeLeft = G_lang:get("LANG_ROB_RICE_ACTIVITY_OVER")
		if not self._isAfterWar then
			self:_initLayer()
		end		
	end

	return timeLeft
end

function ArenaRobRiceLayer:onLayerExit( ... )
	uf_eventManager:removeListenerWithTarget(self)
	if self._timer then
		GlobalFunc.removeTimer(self._timer)
		self._timer = nil
   	end
	if self._afterWarTimer then
		GlobalFunc.removeTimer(self._afterWarTimer)
		self._afterWarTimer = nil
   	end 
end

return ArenaRobRiceLayer
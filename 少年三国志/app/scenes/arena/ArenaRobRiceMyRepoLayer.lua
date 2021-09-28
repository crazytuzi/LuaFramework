-- 我的粮仓界面

local ArenaRobRiceMyRepoLayer = class("ArenaRobRiceMyRepoLayer", UFCCSModelLayer)

require("app.cfg.rice_achievement")
require("app.cfg.basic_figure_info")
local EffectNode = require "app.common.effects.EffectNode"

function ArenaRobRiceMyRepoLayer.create( callback, ... )
	return ArenaRobRiceMyRepoLayer.new("ui_layout/arena_RobRiceMyRepoLayer.json", Colors.modelColor, callback, ...)
end

function ArenaRobRiceMyRepoLayer:ctor( json, color, callback, ... )
	self.super.ctor(self, json, color, ...)

	-- 次回调用于处理粮仓红点
	self._callback = callback
	-- 小助手
	self._knight = nil
end

function ArenaRobRiceMyRepoLayer:onLayerEnter( ... )
	self:showAtCenter(true)
	self:closeAtReturn(true)

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ROB_RICE_GET_RICE_ENEMY, self._initEnemiesList, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ROB_RICE_BUY_RICE_TOKEN, self._onBuyToken, self)
	G_HandlersManager.arenaHandler:sendGetRiceEnemyInfo()

	require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")

	self:registerBtnClickEvent("Button_Close", function ( ... )
		self:animationToClose()
	end)

	self:registerBtnClickEvent("Button_Rob_Review", function ( ... )
		local layer = require("app.scenes.arena.ArenaRobReviewLayer").create()
		uf_sceneManager:getCurScene():addChild(layer)
	end)

	self:registerBtnClickEvent("Button_Buy_Revenge", function ( ... )
		self:_onBuyRevengeClicked()
	end)

	local buttonNext = self:getButtonByName("Button_Next")
	buttonNext:setRotationY(180)

	self:_initTimeLabel()

	self:_createStrokes()
	-- self:_initPageView()
	self:_initMyRiceData(false)

	self:_initEnemiesList()
	-- 在这个界面点击仇人复仇后如果有暴击需要在这里处理
	self:_onCrit()

	self._refreshTimeCount = 0

	self._timer = G_GlobalFunc.addTimer(1, function ( ... )
		self:_countDown()
	end)
end

function ArenaRobRiceMyRepoLayer:_initMyRiceData( isGrowth )
	-- 流动粮草
	if not isGrowth then
		self:getLabelByName("Label_Fixed_Rice"):setText(G_Me.arenaRobRiceData:getGrowthRice())
	else
		self:_updateGrowthRiceLabel()
	end
	-- 固定粮草
	self:getLabelByName("Label_Variable_Rice"):setText(G_Me.arenaRobRiceData:getInitRice())
	self:getLabelByName("Label_Revenge_Times"):setText(G_Me.arenaRobRiceData:getRevengeToken())
end

function ArenaRobRiceMyRepoLayer:_createStrokes( ... )
	self:getLabelByName("Label_Variable_Rice_Tag"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Variable_Rice"):createStroke(Colors.strokeBrown, 1)

	self:getLabelByName("Label_Fixed_Rice_Tag"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Fixed_Rice"):createStroke(Colors.strokeBrown, 1)

	self:getLabelByName("Label_Time_Tag_1"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Time"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Time_Tag_2"):createStroke(Colors.strokeBrown, 1)

	self:getLabelByName("Label_Buy_Revenge_Tag"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Revenge_Times"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Tips"):createStroke(Colors.strokeBrown, 1)
end

function ArenaRobRiceMyRepoLayer:_initPageView( ... )
	self:showWidgetByName("Panel_No_Revenge", false)
	self:showWidgetByName("Panel_Pageview", true)
	self:showWidgetByName("Label_Tips", true)
	local pageViewItem = require("app.scenes.arena.ArenaRobPageViewItem")
	local panel = self:getPanelByName("Panel_Pageview")
	self._pageView = CCSNewPageViewEx:createWithLayout(panel)
	self._pageView:setPageCreateHandler(function ( page, index )
		return pageViewItem.new()
	end)
	self._pageView:setPageTurnHandler(function ( page, index, cell )
	end)
	self._pageView:setPageUpdateHandler(function ( page, index, cell )
		local _t = {
            self._enemiesList[index*3+1],
            self._enemiesList[index*3+2],
            self._enemiesList[index*3+3],
        }
        cell:update(self, _t)
	end)
	self._pageView:showPageWithCount(math.ceil(#self._enemiesList / 3))
end

function ArenaRobRiceMyRepoLayer:_initEnemiesList( ... )
	self:_initMyRiceData(false)
	self._enemiesList = G_Me.arenaRobRiceData:getEnemiesToRevenge()
	if (self._enemiesList == nil or #self._enemiesList == 0) then
	
		self:showWidgetByName("Panel_No_Revenge", true)
		self:showWidgetByName("Panel_Pageview", false)
		self:showWidgetByName("Label_Tips", false)

		if self._knight == nil then
		 	local GlobalConst = require("app.const.GlobalConst")
		 	self._knight = knight_info.get(GlobalConst.CAI_WEN_JI_ID)
	        if self._knight then
	            local heroPanel = self:getPanelByName("Panel_Assits")
	            local KnightPic = require("app.scenes.common.KnightPic")
	            KnightPic.createKnightPic( self._knight.res_id, heroPanel, "caiwenji",true )
	            heroPanel:setScale(0.5)
	            if self._smovingEffect == nil then
	                local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
	                self._smovingEffect = EffectSingleMoving.run(heroPanel, "smoving_idle", nil, {})
	            end
	        end
        end

	    local lackRice = G_Me.arenaRobRiceData:getLackRiceToNextAchievement()
		if lackRice >= 0 then
			self:getLabelByName("Label_Achievement_Tips"):setText(G_lang:get("LANG_ROB_RICE_NO_ATTACK_TIPS", {num = lackRice}))
		else			
			self:getLabelByName("Label_Achievement_Tips"):setText(G_lang:get("LANG_ROB_RICE_NO_ATTACK_TIPS_1"))			
		end
	else
		self:_initPageView()
	end
	
	local totalRice = G_Me.arenaRobRiceData:getTotalRice()
	-- 根据粮草数量的不同显示粮仓个数
	if totalRice <= 10000 then
		self:showWidgetByName("Image_Repo_1", false)
		self:showWidgetByName("Image_Repo_3", false)
	elseif totalRice > 10000 and totalRice <= 30000 then
		self:showWidgetByName("Image_Repo_2", false)
	end

	for i = 1, 3 do
		local repoImage = self:getImageViewByName("Image_Repo_" .. i)
		if repoImage:isVisible() then 
			local effectRice = repoImage:getNodeByTag(33)
			if effectRice == nil then
				effectRice = EffectNode.new("effect_rice", function ( event, frameIndex )	end)
				effectRice:setPosition(ccp(-8, 90))
				repoImage:addNode(effectRice, 1, 33)
				effectRice:play()
			end
		end
	end

end

function ArenaRobRiceMyRepoLayer:onLayerExit( ... )
	uf_eventManager:removeListenerWithTarget(self)
	if self._timer then
		GlobalFunc.removeTimer(self._timer)
		self._timer = nil
	end

	-- 处理争粮战主界面红点
	if self._callback then
		self._callback()
	end

end

-- 一开始就来计算出倒计时的值
function ArenaRobRiceMyRepoLayer:_initTimeLabel(  )
	local basicFigureInfo = basic_figure_info.get(4)

	local recoverTime = G_Me.arenaRobRiceData:getRiceRefreshTime() + basicFigureInfo.unit_time
	local leftTimeString = G_ServerTime:getLeftSecondsString(recoverTime)
	local day, hour, min, sec = G_ServerTime:getLeftTimeParts(recoverTime)

	if leftTimeString == "-" or (min == 0 and sec == 0) then
		leftTimeString = G_lang:get("LANG_ROB_RICE_FORMAT_TIME_4", {minute = min, second = sec})
		self:getLabelByName("Label_Time"):setText("")
	else
		local day, hour, min, sec = G_ServerTime:getLeftTimeParts(recoverTime)
		leftTimeString = G_lang:get("LANG_ROB_RICE_FORMAT_TIME_4", {minute = min, second = sec})
		self:getLabelByName("Label_Time"):setText(leftTimeString)
	end
end

function ArenaRobRiceMyRepoLayer:_countDown( ... )
	local basicFigureInfo = basic_figure_info.get(4)

	local recoverTime = G_Me.arenaRobRiceData:getRiceRefreshTime() + basicFigureInfo.unit_time
	local leftTimeString = G_ServerTime:getLeftSecondsString(recoverTime)
	local day, hour, min, sec = G_ServerTime:getLeftTimeParts(recoverTime)
	if leftTimeString == "-" or (min == 0 and sec == 0) then
		-- 先本地更新数据
		G_Me.arenaRobRiceData:setRiceRefreshTime(G_ServerTime:getTime() + basicFigureInfo.unit_time)
		G_Me.arenaRobRiceData:setGrowthRice(G_Me.arenaRobRiceData:getGrowthRice() + basicFigureInfo.unit_recover)
		self:_initMyRiceData(true)
		self:_initEnemiesList()
	else
		local day, hour, min, sec = G_ServerTime:getLeftTimeParts(recoverTime)
		leftTimeString = G_lang:get("LANG_ROB_RICE_FORMAT_TIME_4", {minute = min, second = sec})

		local timeLabel = self:getLabelByName("Label_Time")
		timeLabel:setText(leftTimeString)
		-- 调整后面文字的位置
		local timeTag2 = self:getLabelByName("Label_Time_Tag_2")
		timeTag2:setPositionX(timeLabel:getPositionX() + timeLabel:getContentSize().width + 5)
	end

	self._refreshTimeCount = self._refreshTimeCount + 1
	if self._refreshTimeCount % 30 == 0 then
		self:_refreshEnemiesData()
	end
end

-- 流动粮草增长的动画
function ArenaRobRiceMyRepoLayer:_updateGrowthRiceLabel(  )
	local addTipsLabel = self:getLabelByName("Label_Add")
	local arr = CCArray:create()
    arr:addObject(CCShow:create())
    arr:addObject(CCCallFunc:create(function()
        local label = self:getLabelByName("Label_Fixed_Rice")
		local basicFigureInfo = basic_figure_info.get(4)
		local oldNum = G_Me.arenaRobRiceData:getGrowthRice() - basicFigureInfo.unit_recover
		local newNum = G_Me.arenaRobRiceData:getGrowthRice()

		local _time = 0.5
		local growupNumber = CCNumberGrowupAction:create(oldNum, newNum, _time, function ( number )
	                        label:setText(tostring(number))
	                    end)
        local actionScale = CCSequence:createWithTwoActions(CCScaleTo:create(_time/2, 2), CCScaleTo:create(_time/2, 1))
        local action = CCSpawn:createWithTwoActions(growupNumber, actionScale)
		label:runAction(action)
	end))
    arr:addObject(CCDelayTime:create(1))
    arr:addObject(CCHide:create())
    addTipsLabel:runAction(CCSequence:create(arr))
end

function ArenaRobRiceMyRepoLayer:_onBuyRevengeClicked( ... )
	if G_Me.arenaRobRiceData:getTokenRemainBuyTimes(1) > 0 then
		require("app.scenes.arena.ArenaRobBuyPanel").show(1)
	else
		local myVip = G_Me.userData.vip
		if myVip >= 12 then
			G_MovingTip:showMovingTip(G_lang:get("LANG_ROB_RICE_BUY_HIT_MAX"))
		else
			G_GlobalFunc.showVipNeedDialog(require("app.const.VipConst").ROBRICEREVENGE)
		
		end
	end
end


function ArenaRobRiceMyRepoLayer:_onBuyToken( data )
	if data.ret == 1 then
		-- 更新复仇令牌数值
		self:getLabelByName("Label_Revenge_Times"):setText(G_Me.arenaRobRiceData:getRevengeToken())
	end
end


-- 每隔一段时间刷新仇人粮仓相关数据
function ArenaRobRiceMyRepoLayer:_refreshEnemiesData( ... )
	if not G_NetworkManager:isConnected() then
        return
    end
	G_HandlersManager.arenaHandler:sendGetRiceEnemyInfo()
end

function ArenaRobRiceMyRepoLayer:_onCrit(  )
	local critRice = G_Me.arenaRobRiceData:getCritRice()
    if critRice > 0 then
        require("app.scenes.arena.ArenaRobRiceCritPopupLayer").show(critRice)
        G_Me.arenaRobRiceData:setCritRice(0)
    end
end

return ArenaRobRiceMyRepoLayer
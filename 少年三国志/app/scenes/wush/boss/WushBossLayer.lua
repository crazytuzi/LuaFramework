-- 三国无双精英boss

local WushBossLayer = class("WushBossLayer", UFCCSModelLayer)

-- boss icon间隔
WushBossLayer.BossIconOffset = 120
-- 需要显示几个尚未解锁的boss
WushBossLayer.ShowLockedBossNum = 3
-- 处于最边上的boss与边界的距离调整参数
WushBossLayer.ScrollBorderAdjust = 0
-- 截断区域宽度
WushBossLayer.ScrollCutWidth = 20

local BossIconItem = require("app.scenes.wush.boss.WushBossIconItem")
local knightPic = require("app.scenes.common.KnightPic")
require("app.cfg.dead_battle_boss_info")
require("app.cfg.dead_battle_boss_number_info")

function WushBossLayer.show( ... )
	local layer = require("app.scenes.wush.boss.WushBossLayer").new("ui_layout/wush_BossLayer.json", Colors.modelColor, ...)
	uf_sceneManager:getCurScene():addChild(layer)
end

function WushBossLayer:ctor( json, color, ... )
	self.super.ctor(self, json, color, ...)

	self._scrollView = nil
	self._bossIconBtns = {}
    self._bossPanel = nil
    self._bossImageView = nil
    self._smovingEffect = nil
    self._challengedBossId = 0

	self:_createStrokes()
    self:_clearWidgetsDefaultData()
    self:_initStaticWidgets()
end

function WushBossLayer:_createStrokes(  )
	-- self:getLabelByName("Label_First_Win_Tag"):createStroke(Colors.strokeBrown, 1)
	-- self:getLabelByName("Label_First_Win_Num"):createStroke(Colors.strokeBrown, 1)
	-- self:getLabelByName("Label_Drop_Tag"):createStroke(Colors.strokeBrown, 1)
	-- self:getLabelByName("Label_Challenge_Times_Tag"):createStroke(Colors.strokeBrown, 1)
	-- self:getLabelByName("Label_Challenge_Times"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Drop_Num"):createStroke(Colors.uiColors.BROWN, 1)
    self:getLabelByName("Label_Desc"):createStroke(Colors.strokeBrown, 1)
end

-- 清除控件上默认的显示
function WushBossLayer:_clearWidgetsDefaultData(  )
    self:getLabelByName("Label_Challenge_Times"):setText("")
    self:getLabelByName("Label_Drop_Num"):setText("")
    self:getLabelByName("Label_Desc"):setText("")
    self:getLabelByName("Label_First_Win_Num"):setText("")
end

-- 初始化不随boss不同而改变的UI控件
function WushBossLayer:_initStaticWidgets(  )
    self:registerBtnClickEvent("Button_Buy_Times", function (  )
        self:_onBossBuyChallengeTimesBtnClicked()
    end)

    self:registerBtnClickEvent("Button_Lineup", function (  )
        require("app.scenes.hero.HerobuZhengLayer").showBuZhengLayer()
    end)

    self:registerBtnClickEvent("Button_Close", function (  )
        self:animationToClose()
    end)
end

-- 初始化每关boss概况icon的scrollview
function WushBossLayer:_initScrollView(  )

	if self._scrollView == nil then
		self._scrollView = self:getScrollViewByName("ScrollView_Boss_Icon")
	end
	self._scrollView:removeAllChildrenWithCleanup(true)

    local firstId = G_Me.wushData:getBossFirstId()
    local activeId = G_Me.wushData:getBossActiveId()
    local showBossNum = 4
    if firstId == activeId then
        showBossNum = math.min(activeId + WushBossLayer.ShowLockedBossNum, dead_battle_boss_info.getLength())
    else
        showBossNum = math.min(firstId + 1 + WushBossLayer.ShowLockedBossNum, dead_battle_boss_info.getLength())
    end

	for i = 1, showBossNum do

		self._bossIconBtns[i] = BossIconItem.new(i)
		self._bossIconBtns[i]:setPosition(ccp(WushBossLayer.BossIconOffset * (i - 1) + WushBossLayer.ScrollBorderAdjust, -1))
		self._scrollView:addChild(self._bossIconBtns[i])

		self:registerBtnClickEvent(self._bossIconBtns[i]:getBtnName(), function ( widget )
            __Log("----------boss idx %d", i)
            self:_adjustBossIconPos(i)

            local activeId = G_Me.wushData:getBossActiveId() 
            local firstId = G_Me.wushData:getBossFirstId()

            if i > firstId + 1 then
                if i > activeId then
                    local bossInfo = dead_battle_boss_info.get(i)
                    G_MovingTip:showMovingTip(G_lang:get("LANG_WUSH_BOSS_LOCKED", {num = bossInfo.front_floor}))
                else
                    local preBoss = dead_battle_boss_info.get(i - 1)
                    if preBoss then
                        G_MovingTip:showMovingTip(G_lang:get("LANG_WUSH_BOSS_OPEN_AFTER_MONSTER", {name = preBoss.monster_name}))
                    end
                end
            elseif i == (firstId + 1) and firstId == activeId then
                local bossInfo = dead_battle_boss_info.get(i)
                G_MovingTip:showMovingTip(G_lang:get("LANG_WUSH_BOSS_LOCKED", {num = bossInfo.front_floor}))
            else
                self:_updateBossDetail(i)
            end
		end)
	end

    local index = 1 --math.max(G_Me.wushData:getBossFirstId(), 1)
    if self._challengedBossId ~= 0 then 
        -- 没有已解锁但尚未首胜的boss，则停留下上一次攻打过的boss上
        index = self._challengedBossId
    else 
        if G_Me.wushData:getBossActiveId() > G_Me.wushData:getBossFirstId() then
            index = G_Me.wushData:getBossFirstId() + 1
        else 
            index = math.max(G_Me.wushData:getBossFirstId(), 1)
        end
    end
	self:_updateBossDetail(index)

    local innerContainerWidth = WushBossLayer.BossIconOffset * showBossNum + WushBossLayer.ScrollBorderAdjust * 2
    self._scrollView:setInnerContainerSize(CCSizeMake(innerContainerWidth, 150))

    --滑动区域宽度
    local scrollAreaWidth = innerContainerWidth - self._scrollView:getSize().width
    -- __Log("innerContainerWidth %d", innerContainerWidth)
    -- __Log("self._scrollView:getSize().width %d", self._scrollView:getSize().width)
    local percent = (self._bossIconBtns[index]:getPositionX() - WushBossLayer.ScrollBorderAdjust) / scrollAreaWidth * 100
    self._scrollView:jumpToPercentHorizontal(percent)

end

-- 如果被点击的boss icon恰好有一部分处于不可见状态则需要微调一下
function WushBossLayer:_adjustBossIconPos( index )
    --按钮的宽度
    local buttonWidth = self._bossIconBtns[index]:getContentSize().width
    local innerContainer = self._scrollView:getInnerContainer()
    --计算选中按钮的位置是否超出了
    local position = innerContainer:convertToWorldSpace(ccp(self._bossIconBtns[index]:getPosition()))
    --滑动区域宽度
    local scrollAreaWidth = innerContainer:getContentSize().width - self._scrollView:getContentSize().width
    -- __Log("---------------position.x %d", position.x)
    if position.x < buttonWidth/2 + WushBossLayer.ScrollCutWidth then
        --需要位移
        local percent = self._bossIconBtns[index]:getPositionX()/scrollAreaWidth
        self._scrollView:scrollToPercentHorizontal(percent*100,0.3,false)
        --因为position是世界坐标
    elseif math.abs(position.x) > self._scrollView:getContentSize().width + self._scrollView:getPositionX() - buttonWidth/2 then
        --需要位移
        local percent = (math.abs(self._bossIconBtns[index]:getPositionX())-self._scrollView:getContentSize().width + buttonWidth)/scrollAreaWidth
        self._scrollView:scrollToPercentHorizontal(percent*100,0.3,false)
    end
end

-- 刷新每关boss相关的详细情况
function WushBossLayer:_updateBossDetail( bossIdx )
	
	self:registerBtnClickEvent("Button_Challenge", function (  )
		self:_onBossChallengeBtnClicked(bossIdx)
	end)

    if self._bossPanel == nil then
        self._bossPanel = self:getPanelByName("Panel_Boss")
        self._bossPanel:setScale(0.9)
    else
        self._bossPanel:removeAllChildrenWithCleanup(true)
    end

	local bossInfo = dead_battle_boss_info.get(bossIdx)
	if bossInfo then
        -- 是否已领取过首胜奖励
        self:showWidgetByName("Image_Already_Got_Reward", bossIdx <= G_Me.wushData:getBossFirstId())

        local itemFirstWin = G_Goods.convert(bossInfo.first_type, bossInfo.first_value)
        self:getImageViewByName("Image_First_Win_Icon"):loadTexture(itemFirstWin.icon_mini, UI_TEX_TYPE_PLIST)
        self:getLabelByName("Label_First_Win_Num"):setText(bossInfo.first_size)

		local item1 = G_Goods.convert(bossInfo.type_1, bossInfo.value_1)

		self:getImageViewByName("Image_Border_1"):loadTexture(G_Path.getEquipColorImage(item1.quality, G_Goods.TYPE_ITEM))
		-- self:getImageViewByName("Image_Bg_1"):loadTexture(G_Path.getEquipIconBack(item1.quality))
		self:getImageViewByName("Image_Drop_1"):loadTexture(item1.icon)
        self:getLabelByName("Label_Desc"):setText(bossInfo.monster_name)

		self:registerWidgetClickEvent("Image_Drop_1", function (  )
			require("app.scenes.common.dropinfo.DropInfo").show(item1.type, item1.value) 
		end)

        if bossInfo.min_size_1 ~= bossInfo.max_size_1 then
		    self:getLabelByName("Label_Drop_Num"):setText("x" .. bossInfo.min_size_1 .. "~x" .. bossInfo.max_size_1)
        else
            self:getLabelByName("Label_Drop_Num"):setText("x" .. bossInfo.min_size_1)
        end

        if bossInfo.type_1 == G_Goods.TYPE_MONEY then
            if bossInfo.min_size_1 >= 10000 then
                self:getLabelByName("Label_Drop_Num"):setText("x" .. bossInfo.min_size_1 / 10000 .. G_lang:get("LANG_WAN"))
            end
        end

        self._knightImageView = knightPic.createKnightPic(bossInfo.monster_image, self._bossPanel, "boss" .. bossInfo.id, true)
	end

    for i, v in ipairs(self._bossIconBtns) do
        v:updateSelectedBg(false)
    end
    self._bossIconBtns[bossIdx]:updateSelectedBg(true)
	
    self:_updateChallengeTimes()
end

-- 刷新挑战次数的显示
function WushBossLayer:_updateChallengeTimes(  )
    -- 当前拥有的挑战次数
    local curChallengeTimes = G_Me.wushData:getCurBossChallengeTimes()
	self:getLabelByName("Label_Challenge_Times"):setText(tostring(curChallengeTimes))
end

function WushBossLayer:onLayerLoad(  )
    G_Me.wushData:setIsInWushBossLayer(true)
end

function WushBossLayer:onLayerEnter( ... )
    self:registerKeypadEvent(true)

	self:closeAtReturn(true)
	self:showAtCenter(true)
    if self._challengedBossId <= 0 then
        require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
    end

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_WUSH_BOSS_INFO, self._onBossInfo, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_WUSH_BOSS_CHALLENGE, self._onBossChallenge, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_WUSH_BOSS_BUY, self._onBossBuy, self)

    G_HandlersManager.wushHandler:sendWushBossInfo()
end

-- boss关卡信息协议回调
function WushBossLayer:_onBossInfo( data )
	self:_initScrollView()

    -- 判断是否弹出首胜提示
    if (G_Me.wushData:getBossFirstId() - G_Me.wushData:getBossOldFirstId() == 1) then
        -- 先隐藏该boss已领取标志
        self:showWidgetByName("Image_Already_Got_Reward", false)
        self:_setGrayBossImage()
        require("app.scenes.wush.boss.WushBossFirstWinLayer").show(function (  )
            self:showWidgetByName("Image_Already_Got_Reward", true)
            self:_playUnlockEffect()
        end)
    end
end

-- 播放解锁特效之前把boss置灰
function WushBossLayer:_setGrayBossImage(  )
    if G_Me.wushData:getBossFirstId() + 1 <= G_Me.wushData:getBossActiveId() then
        local bossIconItem = self._bossIconBtns[G_Me.wushData:getBossFirstId() + 1]
        if bossIconItem then
            bossIconItem:setGrayBossImage(true)
        end           
    end
end

function WushBossLayer:_playUnlockEffect(  )
    if G_Me.wushData:getBossFirstId() + 1 <= G_Me.wushData:getBossActiveId() then
        local bossIconItem = self._bossIconBtns[G_Me.wushData:getBossFirstId() + 1]
            if bossIconItem then
                self:callAfterFrameCount(5, function ( ... )
                bossIconItem:playUnlockEffect()
            end)            
        end
    end
end

function WushBossLayer:_onBossChallengeBtnClicked( bossIdx )
    local curChallengeTimes = G_Me.wushData:getCurBossChallengeTimes()

    if curChallengeTimes > 0 then
        self._challengedBossId = bossIdx
        G_HandlersManager.wushHandler:sendWushBossChallenge(bossIdx)
    else
        self:_onBossBuyChallengeTimesBtnClicked()
    end
end

-- 点击购买次数
function WushBossLayer:_onBossBuyChallengeTimesBtnClicked(  )
    -- 已经购买的次数
    local buyTimes = G_Me.wushData:getBossBuyChallengeTimes()
    local buyInfo = dead_battle_boss_number_info.get(buyTimes + 1)
    -- dump(buyInfo)
    if buyInfo == nil then
        -- VIP最高的人用完了所有的购买次数
        G_MovingTip:showMovingTip(G_lang:get("LANG_WUSH_BOSS_NO_BUY_TIMES"))
    else
        local myVip = G_Me.userData.vip
        local vipRequired = buyInfo.vip_level
        if myVip >= vipRequired then
            -- 可以继续购买
            local price = buyInfo.cost
            -- 最多可以购买的次数
            local maxTimes = self:_getMaxBuyTimes(myVip)

            local leftTimes = maxTimes - buyTimes
            if leftTimes > 0 then
                if price <= G_Me.userData.gold then
                    local box = require("app.scenes.tower.TowerSystemMessageBox")
                    box.showMessage(box.TypeWushBoss,
                                price, 
                                leftTimes,
                                self._onBuyConfirm,
                                self._onBuyCancel, 
                                self)
                else
                    require("app.scenes.shop.GoldNotEnoughDialog").show()
                end
            else
                -- VIP最高的人用完了所有的购买次数
                G_MovingTip:showMovingTip(G_lang:get("LANG_WUSH_BOSS_NO_BUY_TIMES"))   
            end
        else
            -- VIP等级不够了
            local nextMaxTimes = self:_getMaxBuyTimes(myVip + 1)
            self:_showVipNeedDialog(myVip + 1, nextMaxTimes)
        end
    end
end

-- 根据VIP等级返回最大购买次数
function WushBossLayer:_getMaxBuyTimes( vip )
    local maxTimes = 0
    for i = 1, dead_battle_boss_number_info.getLength() do
        local buyInfoTemp = dead_battle_boss_number_info.get(i)
        if vip < buyInfoTemp.vip_level then
            break
        end
        maxTimes = buyInfoTemp.num
    end
    return maxTimes
end

function WushBossLayer:_showVipNeedDialog( nextVip, nextTimes )
    local str = G_lang:get("LANG_MSGBOX_VIPLEVEL26", {vip_level=nextVip,times=nextTimes})
    MessageBoxEx.showYesNoMessage(
        nil,
        str,
        false,
        function()
            require("app.scenes.shop.recharge.RechargeLayer").show()  
        end,
        nil, 
        nil,
        MessageBoxEx.OKNOButton.OKNOBtn_Vip)
end

-- 购买挑战次数成功的回调
function WushBossLayer:_onBossBuy( data )
    if data.ret == 1 then
        self:_updateChallengeTimes()
        G_MovingTip:showMovingTip(G_lang:get("LANG_WUSH_BOSS_BUY_SUCCEED"))
    else
        G_MovingTip:showMovingTip(G_lang:get("LANG_WUSH_BOSS_BUY_FAILED"))
    end
end

function WushBossLayer:_onBuyConfirm(  )
    G_HandlersManager.wushHandler:sendWushBossBuy()
end

function WushBossLayer:_onBuyCancel(  )
    -- body
end

-- 挑战协议回调
function WushBossLayer:_onBossChallenge( data )
	if data.ret == 1 then 
        local callback = function(result)
            if not self or (G_SceneObserver:getSceneName() ~= "WushScene" and G_SceneObserver:getSceneName() ~= "WushBossBattleScene") then
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

            local isFirstChallenge = (self._challengedBossId == (G_Me.wushData:getBossFirstId() + 1))

            local enemy = {}
            self.scene = require("app.scenes.wush.boss.WushBossBattleScene").new(data.battle_report, enemy, callback, isFirstChallenge)
            self.scene.__EFFECT_FINISH_CALLBACK__ = self.__EFFECT_FINISH_CALLBACK__
            uf_sceneManager:pushScene(self.scene)
        end, 
        function ( ... )
            if self.scene ~= nil then
                self.scene:play()
            end
        end)
    else
        self:setTouchEnabled(true)
    end
end


--挑战成功
function WushBossLayer:_challengeSuccess(data, result)
    -- self:setTouchEnabled(false)
    local challageCallback = function()
        if not self or (G_SceneObserver:getSceneName() ~= "WushScene" and G_SceneObserver:getSceneName() ~= "WushBossBattleScene") then
            __Log("已经不在这场景了")
            return
        end
        if not data then
            return
        end

        uf_sceneManager:popScene()        
    end

    -- 此处很蛋疼，showvaluelayer self._value只能是数字。。。
    local awardTable = {}
    local jinglianshiNum = 0
    local yinliangNum = 0
    local jipinjinglianshiNum = 0
    local hongsezhuangbeijinghuaNum = 0
    local shizhuangjinghuaNum = 0

    for i, v in ipairs(data.award) do
        if v.type == G_Goods.TYPE_MONEY then
            yinliangNum = v.size
            awardTable = {wush_boss_yinliang = yinliangNum}
        elseif v.type == G_Goods.TYPE_ITEM then
            if v.value == 13 then
                -- 极品精炼石
                jipinjinglianshiNum = v.size
                awardTable = {wush_boss_jipinjinglianshi = jipinjinglianshiNum}
            elseif v.value == 18 then
                -- 宝物精炼石
                jinglianshiNum = v.size
                awardTable = {wush_boss_baowujinglianshi = jinglianshiNum}
            elseif v.value == 45 then
                -- 时装精华
                shizhuangjinghuaNum = v.size
                awardTable = {wush_boss_shizhuangjinghua = shizhuangjinghuaNum}
            elseif v.value == 81 then
                -- 红色装备精华
                hongsezhuangbeijinghuaNum = v.size
                awardTable = {wush_boss_hongsezhuangbeijinghua = hongsezhuangbeijinghuaNum}
            end
        end

    end

    local FightEnd = require("app.scenes.common.fightend.FightEnd")
    local picks = nil

    __Log("显示FightEnd.show")
    FightEnd.show(FightEnd.TYPE_WUSH_BOSS, true,
        awardTable,
        challageCallback,result)
end

--挑战失败
function WushBossLayer:_challengeFailed(data, result)
    self:setTouchEnabled(true)
    
    local __shengwang = 0
    for i,v in ipairs(data.award) do 
        if v.type == G_Goods.TYPE_SHENGWANG then
            __shengwang = v.size
        end
    end

    local FightEnd = require("app.scenes.common.fightend.FightEnd")
    FightEnd.show(FightEnd.TYPE_WUSH_BOSS, false,
        {
        rice_prestige=__shengwang,
        award = data.award
        },
        function()  
            if not self or (G_SceneObserver:getSceneName() ~= "WushScene" and G_SceneObserver:getSceneName() ~= "WushBossBattleScene") then
                __Log("已经不在这场景了")
                return
            end
           
            uf_sceneManager:popScene()
        end,result)

end

function WushBossLayer:onLayerExit( ... )

end

function WushBossLayer:onLayerUnload( ... )
    G_Me.wushData:setIsInWushBossLayer(false)
end


return WushBossLayer
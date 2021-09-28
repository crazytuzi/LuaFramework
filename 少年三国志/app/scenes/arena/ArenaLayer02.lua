local ArenaLayer = class("ArenaLayer",UFCCSNormalLayer)
local ArenaScrollView = require("app.scenes.arena.ArenaScrollView")
local AwardConst = require("app.const.AwardConst")
require("app.const.ShopType")
function ArenaLayer.create(scenePack, ...)
    return ArenaLayer.new("ui_layout/arena_ArenaLayer.json", nil, scenePack, ...)
end

function ArenaLayer:ctor(jsonFile, fun, scenePack, ...)
    self._mScrollView = nil
    self.super.ctor(self,...)
    self._toChallengeRank = 0
    self._userList = {}
    self._me = {}
    self:_initEvent()
    self:_initWidget()
    self:_createStrokes()
    
    G_GlobalFunc.savePack(self, scenePack)
end

function ArenaLayer:setChallengeRank(_rank)
    self._toChallengeRank = _rank
end

--区分是否是手动滑动,还是自动
function ArenaLayer:isAutoScroll()
    return self._toChallengeRank > 0 
end

-- 根据实际排名，计算在竞技场中的位置
function ArenaLayer:getRankInUserList(real_rank)
    for i,v in ipairs(self._userList) do
        if real_rank == v.rank then
            return i
        end
    end
    return -1
end

function ArenaLayer:__prepareDataForGuide__( ... )

    if self._mScrollView == nil then
        return CCRectMake(0,0,0,0)
    end
    return self._mScrollView:getKnightRectForNewGuide()
end

function ArenaLayer:_initWidget()
    --我的排名
    self._myRankLabel = self:getLabelBMFontByName("BitmapLabel_myrank")
    --前三名显示
    self._myRankImage = self:getImageViewByName("Image_myRank")


    self._shengwangAwardLabel = self:getLabelByName("Label_rankAwardShengwang")
    self._moneyAwardLabel = self:getLabelByName("Label_rankAwardMoney")
    self._xilianAwardLabel = self:getLabelByName("Label_rankAwardXilian")
    self._currentShengWangLabel = self:getLabelByName("Label_myShengWang")

    -- 排名奖励提示
    self._rankAwardTipsLable = self:getLabelByName("Label_Rank_Award_Tips")


    --做嵌入动画
    self:showWidgetByName("Panel_award",false)
    self:showWidgetByName("Button_paihang",false)
    self:showWidgetByName("Button_shop",false)
    -- 布阵按钮入场动画
    self:showWidgetByName("Button_Buzhen", false)
    -- 争粮战按钮
    -- TODO:等级限制
    self:showWidgetByName("Button_Rob_Rice", false)
end

function ArenaLayer:_createStrokes()
    self:getLabelByName("Label_myRankTag"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_rankAwardTag"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_awardTime"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_myShengWangTag"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_challengeTips"):createStroke(Colors.strokeBrown,1)
    self._xilianAwardLabel:createStroke(Colors.strokeBrown,1)
    self._currentShengWangLabel:createStroke(Colors.strokeBrown,1)
    self._moneyAwardLabel:createStroke(Colors.strokeBrown,1)
    self._shengwangAwardLabel:createStroke(Colors.strokeBrown,1)

    -- 排名奖励提示
    self._rankAwardTipsLable:createStroke(Colors.strokeBrown, 1)

    --新手光环经验
    self:getLabelByName("Label_rookieInfo"):createStroke(Colors.strokeBrown,1)

end

function ArenaLayer:onLayerEnter()
    --判断是否是新手引导，则进制滑动
    if  G_GuideMgr and G_GuideMgr:isCurrentGuiding() then
        self:getScrollViewByName("ScrollView_arena"):setScrollEnable(false)
    else
        self:getScrollViewByName("ScrollView_arena"):setScrollEnable(true)
    end

    --每次进场景刷新下当前声望
    self._currentShengWangLabel:setText(G_GlobalFunc.ConvertNumToCharacter(G_Me.userData.prestige))

    -- self:_playAnimation()
    if self._mScrollView ~= nil then
        self._mScrollView:setInnerContainerPositionY(self._scrollViewPosY)
    end
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ARENA_LIST, self._getArenaInfo, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ARENA_CHALLENGE, self._getChallenge, self) 
    --显示商店的tips
    self:showWidgetByName("Image_shopTips",G_Me.shopData:checkAwardTipsByType(SCORE_TYPE.JING_JI_CHANG))

    --新手光环经验
    self:getLabelByName("Label_rookieInfo"):setText(
        G_Me.rookieBuffData:checkInBuff() and G_lang:get("LANG_ROOKIE_BUFF_PERIOD") or "")

    -- 竞技场挑战失败后需要加上计时器
    if self._mScrollView then
        self._mScrollView:addTimer()
    end

end

function ArenaLayer:onLayerLoad(...)
    self:registerKeypadEvent(true)
end

function ArenaLayer:getChallengeLocalRankDiff()
    local myIndex = self:getRankInUserList(self._me.rank)
    local challengeIndex =self:getRankInUserList(self._toChallengeRank)
    return math.abs(myIndex - challengeIndex)
end

function ArenaLayer:onLayerExit()
    --做嵌入动画
    -- self:showWidgetByName("Panel_award",false)
    -- self:showWidgetByName("Button_paihang",false)
    -- self:showWidgetByName("Button_shop",false)
    --我了个去，切换出去，切换回来，scrollview位置变动了
    self._scrollViewPosY = self._mScrollView:getInnerContainerPositionY()
    uf_eventManager:removeListenerWithTarget(self)

    self._mScrollView:removeTimer()
end

function ArenaLayer:_initEvent()
    self:registerBtnClickEvent("Button_back",function()
       self:onBackKeyEvent()
    end)
    self:registerBtnClickEvent("Button_paihang",function()
        local layer = require("app.scenes.arena.ArenaRankingListLayer").create(self._me.rank)
        uf_sceneManager:getCurScene():addChild(layer)
    end)
    self:registerBtnClickEvent("Button_shop",function()
        uf_sceneManager:pushScene(require("app.scenes.shop.score.ShopScoreScene").new(SCORE_TYPE.JING_JI_CHANG))
    end)
    -- 布阵按钮
    self:registerBtnClickEvent("Button_Buzhen", function ( ... )
        require("app.scenes.hero.HerobuZhengLayer").showBuZhengLayer()
    end)
    -- 争粮战按钮
    self:registerBtnClickEvent("Button_Rob_Rice", function ( ... )

        -- local scene = require("app.scenes.arena.ArenaRobRiceScene").new()
        -- uf_sceneManager:replaceScene(scene)

        -- return

        -- require("app.cfg.rice_time_info")

        -- local dateObj = G_ServerTime:getDateObject()
        -- self._secTillNow = dateObj.hour * 3600 + dateObj.min * 60 + dateObj.sec
        -- __Log("secTillNow = %d", self._secTillNow)

        -- -- 根据表中时间算出活动结束的时间戳
        -- self._endTime = G_ServerTime:getTime() - self._secTillNow  + rice_time_info.get(dateObj.wday).end_time
        -- __Log("end time = %d", self._endTime)
        -- local startTime = rice_time_info.get(dateObj.wday).start_time
        -- local prizeEnd = rice_time_info.get(dateObj.wday).prize_end
        local FunctionLevelConst = require("app.const.FunctionLevelConst")
        if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.ROB_RICE) then -- G_Me.userData.level < 65
            -- do nothing
        elseif G_Me.arenaRobRiceData:isRobRiceOpen() then
            local scene = require("app.scenes.arena.ArenaRobRiceScene").new()
            uf_sceneManager:replaceScene(scene)
        else
            local timeInfo = G_Me.arenaRobRiceData:getOpenTimeInfo()
            G_MovingTip:showMovingTip(G_lang:get("LANG_ROB_RICE_OPEN_TIPS", {time1 = G_ServerTime:secondToString(timeInfo.start_time), time2 = G_ServerTime:secondToString(timeInfo.end_time)}))
        end


    end)
end


--进行排序
function ArenaLayer:sortUserList()
    local sortFunc = function(a,b)
        return a.rank < b.rank
    end
    table.sort(self._userList, sortFunc)
end
-------------------------------START --------------------------------------------
function ArenaLayer:_getArenaInfo(data)
    if data.ret == 1 then
        G_SoundManager:playSound(require("app.const.SoundConst").GameSound.ARENA_SCROLL)
        --设置可以滑动
        self._userList = {}
        for i,v in ipairs(data.to_challenge_list)do
            self._userList[#self._userList+1] = v
        end
        self._me.name = G_Me.userData.name
        self._me.user_id = data.user_id
        self._me.level = G_Me.userData.level
        self._me.rank = data.rank
        
        self._me.max_rank = data.max_rank
        local base_id = G_Me.bagData.knightsData:getBaseIdByKnightId(G_Me.formationData:getMainKnightId())
        self._me.base_id = base_id
        self:_updateMe()
        if #self._userList ~= 0 then
            self:sortUserList()
        end
        if self._userList ~= nil  and #self._userList > 0 and self._mScrollView ~= nil then
            local myLocalRank = self:getRankInUserList(self._me.rank)
            if self._userList ~= nil and myLocalRank > 0 then
                self._mScrollView:update(self._userList,myLocalRank)
            else
                G_MovingTip:showMovingTip(G_lang:get("LANG_SERVER_DATA_EXCEPTION"))
                self:setTouchEnabled(false)
            end
        end
    else
        self:setTouchEnabled(true)
    end  
    --显示商店的tips
    self:showWidgetByName("Image_shopTips",G_Me.shopData:checkAwardTipsByType(SCORE_TYPE.JING_JI_CHANG))
end

--获取挑战信息
--[[
    result 为 战斗评级图片    
]]
function ArenaLayer:_getChallenge(data)
    if data.ret == 1 then 
        local callback = function(result)
            if not self or (G_SceneObserver:getSceneName() ~= "ArenaScene" and G_SceneObserver:getSceneName() ~= "ArenaBattleScene") then
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
            if not self or not self.getRankInUserList then
                return
            end

            local userIndex = self:getRankInUserList(self._toChallengeRank)
            if userIndex == -1 then
                return
            end
            local challageUser = self._userList[userIndex]

            if rawget(data,"to_challenge_user") then
                challageUser = data.to_challenge_user
            end
            
            if not challageUser then
                return
            end
            local enemy = {
                id = challageUser.base_id,
                name = challageUser.name,
                power = challageUser.fight_value,
            }

            self.scene = require("app.scenes.arena.ArenaBattleScene"):new(data.battle_report,enemy,callback)
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
function ArenaLayer:_challengeSuccess(data,result)
    self:setTouchEnabled(false)
    local challageCallback = function()
        --暂时跳过突破奖励
        if not self or (G_SceneObserver:getSceneName() ~= "ArenaScene" and G_SceneObserver:getSceneName() ~= "ArenaBattleScene") then
            __Log("已经不在这场景了")
            return
        end
        if not data then
            return
        end
        if  rawget(data, "break_record") and (not G_GuideMgr or not G_GuideMgr:isCurrentGuiding()) then 
            local old_rank = data.break_record.old_rank
            local new_rank = data.break_record.new_rank
            local break_rewards = data.break_record.break_rewards
            --排名4000名以内才有奖励
            if old_rank > new_rank and new_rank <= 4000 then
                local callback = function() 
                    if not self or (not self._onChallengeSuccessHandler) or (G_SceneObserver:getSceneName() ~= "ArenaScene" and G_SceneObserver:getSceneName() ~= "ArenaBattleScene") then
                        __Log("已经不在这场景了")
                        return
                    end
                    self:_onChallengeSuccessHandler()
                end 
                local layer = require("app.scenes.arena.BreakAwardLayer").create(new_rank,old_rank,break_rewards[1].size,callback )
                uf_notifyLayer:getModelNode():addChild(layer)
            else
                if not self or (not self._onChallengeSuccessHandler) then
                    return
                end
                self:_onChallengeSuccessHandler()
            end
        else 
            if not self or (not self._onChallengeSuccessHandler) then
                return
            end
            self:_onChallengeSuccessHandler()
        end
        uf_sceneManager:popScene()
    end
    local __awardMoney = 0
    local __awardExp = 0
    local __shengwang = 0

    for i,v in ipairs(data.rewards) do 
        if v.type == G_Goods.TYPE_MONEY then
            __awardMoney = v.size
        elseif v.type == G_Goods.TYPE_EXP then
            __awardExp = v.size
        elseif v.type == G_Goods.TYPE_SHENGWANG then
            __shengwang = v.size
        end
    end

    local FightEnd = require("app.scenes.common.fightend.FightEnd")
    local picks = nil
    
    if rawget(data, "turnover_rewards")  then
        picks= data.turnover_rewards.rewards
    end

    __Log("显示FightEnd.show")
    FightEnd.show(FightEnd.TYPE_ARENA,true,
        {
            old_rank = self._me.rank,
            new_rank = self._toChallengeRank,
            exp=__awardExp,
            money=__awardMoney,
            prestige=__shengwang,
            awards=data.rewards,
            picks= picks,
            opponent = data.to_challenge_user
        },
        challageCallback,result)
end

function ArenaLayer:_onChallengeSuccessHandler()
    self:setTouchEnabled(false)
    if not self or (not self._me) or (G_SceneObserver:getSceneName() ~= "ArenaScene" and G_SceneObserver:getSceneName() ~= "ArenaBattleScene") then
        __Log("已经不在这场景了")
        return
    end
    --排名在挑战者之前,不做任何处理
    if self._me.rank < self._toChallengeRank then
        self:setTouchEnabled(true)
        return
    else
        local myIndex = self:getRankInUserList(self._me.rank)
        local challengeIndex =self:getRankInUserList(self._toChallengeRank)
        local tmp =self._userList[myIndex]
        self._userList[myIndex] = self._userList[challengeIndex]
        self._userList[challengeIndex] = tmp
        
        --名次交换
        self._mScrollView:playEffect(myIndex,challengeIndex)
        --先播放特效

    end
    if self and self.setChallengeRank then
        self:setChallengeRank(-1)
    end
end


--挑战失败
function ArenaLayer:_challengeFailed(data,result)
    self:setTouchEnabled(true)
    local __awardMoney = 0
    local __awardExp = 0
    local __shengwang = 0

    for i,v in ipairs(data.rewards) do 
        if v.type == G_Goods.TYPE_MONEY then
            __awardMoney = v.size
        elseif v.type == G_Goods.TYPE_EXP then
            __awardExp = v.size
        elseif v.type == G_Goods.TYPE_SHENGWANG then
            __shengwang = v.size
        end
    end

    local FightEnd = require("app.scenes.common.fightend.FightEnd")
    FightEnd.show(FightEnd.TYPE_ARENA,false,
        {exp=__awardExp,
        money=__awardMoney,
        prestige=__shengwang,
        awards=data.rewards},
        function()  
            if not self or (G_SceneObserver:getSceneName() ~= "ArenaScene" and G_SceneObserver:getSceneName() ~= "ArenaBattleScene") then
                __Log("已经不在这场景了")
                return
            end

            local myIndex = self:getRankInUserList(self._me.rank)
            local challengeIndex =self:getRankInUserList(self._toChallengeRank)
            self._mScrollView:playLoseEffect(myIndex, challengeIndex)

            self:setChallengeRank(-1)
            uf_sceneManager:popScene()
        end,result)

end
------------------------------------------END---------------------------------

function ArenaLayer:playAnimation()
    self:showWidgetByName("Panel_award",true)
    self:showWidgetByName("Button_paihang",true)
    self:showWidgetByName("Button_shop",true)
    self:showWidgetByName("Button_Buzhen", true)
    

    local widgets = {
                    self:getWidgetByName("Panel_award"),
                    self:getWidgetByName("Button_paihang"), 
                    self:getWidgetByName("Button_shop"),
                    self:getWidgetByName("Button_Buzhen")
                }

    local FunctionLevelConst = require("app.const.FunctionLevelConst")
    -- TODO:配表
    if G_moduleUnlock:canPreviewModule(FunctionLevelConst.ROB_RICE) and G_Me.arenaRobRiceData:willOpenToday() then
        self:showWidgetByName("Button_Rob_Rice", true)
        table.insert(widgets, self:getWidgetByName("Button_Rob_Rice"))
    end

    if (not G_GuideMgr or not G_GuideMgr:isCurrentGuiding()) then
        G_GlobalFunc.flyIntoScreenLR( widgets ,
            false, 0.2, 5, 100,function( )
            end)
    end
end

function ArenaLayer:setScrollViewEnable(enable)
    self._mScrollView:setScrollEnable(enable)
end

function ArenaLayer:_updateMe()
    -- self._myRankLabel:setText(G_lang:get("LANG_ARENA_RANKING",{rank=self._me.rank}))
    local goods01 = AwardConst.getAwardGoods01(self._me.rank)
    local goods02 = AwardConst.getAwardGoods02(self._me.rank)
    local goods03 = AwardConst.getAwardGoods03(self._me.rank)
    if goods01 ~= nil then
        self._shengwangAwardLabel:setText(goods01.size)
    else
        self._shengwangAwardLabel:setText(0)
    end
    if goods02 ~= nil then
        self._moneyAwardLabel:setText(G_GlobalFunc.ConvertNumToCharacter3(goods02.size))
    else
        self._moneyAwardLabel:setText(0)
    end 
    if goods03 ~= nil then
        self._xilianAwardLabel:setText(goods03.size)
    else
        self._xilianAwardLabel:setText(0)
    end 

    -- 根据玩家历史最好排行来判断是否需要显示奖励提示
    if self._me.max_rank > 3500 then
        -- 先隐藏奖励具体信息相关控件
        self:showWidgetByName("Label_rankAwardTag", false)
        self:showWidgetByName("ImageView_760", false)
        self:showWidgetByName("ImageView_778", false)
        self:showWidgetByName("ImageView_778_0", false)
        self:showWidgetByName("Label_awardTime", false)
        self._shengwangAwardLabel:setVisible(false)
        self._moneyAwardLabel:setVisible(false)
        self._xilianAwardLabel:setVisible(false)
        -- 显示3500名之外玩家的文字提示
        self._rankAwardTipsLable:setVisible(true)
    else
        self:showWidgetByName("Label_rankAwardTag", true)
        self:showWidgetByName("ImageView_760", true)
        self:showWidgetByName("ImageView_778", true)
        self:showWidgetByName("ImageView_778_0", true)
        self:showWidgetByName("Label_awardTime", true)
        self._shengwangAwardLabel:setVisible(true)
        self._moneyAwardLabel:setVisible(true)
        self._xilianAwardLabel:setVisible(true)
        -- 隐藏3500名之外玩家的文字提示
        self._rankAwardTipsLable:setVisible(false)
    end

    if self._me.max_rank > 4000 then
        self._rankAwardTipsLable:setText(G_lang:get("LANG_RANK_ABOVE_4000_AWARD_TIP"))
    elseif self._me.max_rank > 3500 and self._me.max_rank <= 4000 then
        self._rankAwardTipsLable:setText(G_lang:get("LANG_RANK_ABOVE_3500_AWARD_TIP"))        
    end

    --新手光环经验
    self:getLabelByName("Label_rookieInfo"):setText(
        G_Me.rookieBuffData:checkInBuff() and G_lang:get("LANG_ROOKIE_BUFF_PERIOD") or "")

    self._currentShengWangLabel:setText(G_GlobalFunc.ConvertNumToCharacter(G_Me.userData.prestige))


    if self._me.rank <= 3 then
        local rankImages = {
            "ui/text/txt/phb_1st.png",
            "ui/text/txt/phb_2st.png",
            "ui/text/txt/phb_3st.png",
        }
        self._myRankImage:setVisible(true)
        self._myRankLabel:setVisible(false)
        self._myRankImage:loadTexture(rankImages[self._me.rank],UI_TEX_TYPE_LOCAL)
    else
        self._myRankImage:setVisible(false)
        self._myRankLabel:setVisible(true)
        self._myRankLabel:setText(self._me.rank)
    end
end

function ArenaLayer:getMyRank()
    if not self._me then
        return -1
    end
    return self._me.rank or -1
end

function ArenaLayer:getTrashDialogRank( ... )
    return self._mScrollView:getTrashDialogRank()
end

function ArenaLayer:flushDown()
    local myLocalIndex = self:getRankInUserList(self._me.rank)
    local challengeLocalIndex = self:getRankInUserList(self._toChallengeRank)
    self._mScrollView:scrollToIndex(myLocalIndex)
end

function ArenaLayer:adapterLayer()
    if self._mScrollView == nil then
        local size = CCDirector:sharedDirector():getWinSize()
        local scrollView = self:getScrollViewByName("ScrollView_arena")
        scrollView:setContentSize(CCSize(size.width,size.height))
        self._mScrollView = ArenaScrollView.new(scrollView,listData,self)
        self:setTouchEnabled(false)
        G_HandlersManager.arenaHandler:sendGetArenaInfo()
    end
end

function ArenaLayer:onBackKeyEvent(...)
     local packScene = G_GlobalFunc.createPackScene(self)
     if not packScene then 
        packScene = require("app.scenes.mainscene.PlayingScene").new()
     end
    uf_sceneManager:replaceScene(packScene)
    return true
end
return ArenaLayer


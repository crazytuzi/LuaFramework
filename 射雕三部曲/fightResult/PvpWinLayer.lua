--[[
    文件名: PvpWinLayer.lua
	描述: Pvp 战斗胜利结算页面
	创建人: suntao
	创建时间: 2016.06.20
-- ]]

local PvpWinLayer = class("PvpWinLayer", function(params)
	local parent = display.newLayer()
	-- 屏蔽下层点击事件
    ui.registerSwallowTouch({node = parent})
	return parent
end)

-- 构造函数
--[[
-- 参数 params 中的各项为
	{
		battleType = ModuleSub.eBattleNormal, -- 战役类型, 在 EnumsConfig.lua 文件的 ModuleSub中定义
		result = nil,  -- 服务端返回的结果
		myInfo = {}, -- 我方信息， 默认为nil
		enemyInfo = {}, -- 对方信息， 默认为nil
	}
]]
function PvpWinLayer:ctor(params)
	params = params or {}
	self.mBattleType = params.battleType
	self.mBattleResult = params.result
	self.mMyInfo = params.myInfo
	self.mEnemyInfo = params.enemyInfo
    self.mParams = params

	-- 创建标准容器
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    local bgSprite = ui.newSprite("zdjs_01.png")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite, -10)

    -- 显示背景图
    local bgEffect = ui.newEffect({
        parent = self.mParentLayer,
        effectName = "effect_ui_zhandoushengli_tw",
        position = cc.p(320, 514),
        animation = "zhandoushenglipvp",
        loop = false,
        endRelease = true,
        completeListener = function()
            ui.newEffect({
                parent = self.mParentLayer,
                zorder = -1,
                effectName = "effect_ui_zhandoushengli_tw",
                animation = "zhandoushenglixunhuanpvp",
                position = cc.p(320, 514),
                loop = true,
                endRelease = false,
            })
        end,
    })

    -- bgEffect:addAnimation(0, "zhandoushenglixunhuan", true)
    -- bgEffect:setToSetupPose()

    -- local tmpSprite = ui.newScale9Sprite("zdjs_05.png", cc.size(640, 450))
    -- tmpSprite:setAnchorPoint(0.5, 1)
    -- tmpSprite:setPosition(320, 696.29)
    -- self.mParentLayer:addChild(tmpSprite)

	-- 初始化页面控件
	self:initUI()
end

-- 初始化页面控件
function PvpWinLayer:initUI()
	-- 战斗胜利的文字、背光、刀 等动画效果
	-- local effectNode = ResultUtility.createWinAnimation()
 --    effectNode:setAnchorPoint(cc.p(0.5, 1))
 --    effectNode:setPosition(320, 1136)
 --    self.mParentLayer:addChild(effectNode, 1)
 --    self.mEffectNode = effectNode

    -- 关闭按钮
    self.mCloseBtn = ui.newButton({
    	normalImage = "c_33.png",
    	text = TR("确定"),
    	textColor = Enums.Color.eWhite,
    	clickAction = function()
            if self.mChoiceNode_ and not self.mChoiceNode_.choiceStatus() then
                ui.showFlashView(TR("请先选择一个战利品"))
                return
            end
    		-- 删除战斗页面
    		LayerManager.removeTopLayer(true)
    	end,
    })
    self.mCloseBtn:setPosition(320, 140)
    self.mParentLayer:addChild(self.mCloseBtn)

    -- 战斗回放按钮
    self.mReplayBtn = ui.newButton({
        normalImage = "c_33.png",
        text = TR("战斗详情"),
        clickAction = function()
            self:replay()
        end
    })
    self.mReplayBtn:setPosition(320, 140)
    self.mReplayBtn:setVisible(false)
    self.mParentLayer:addChild(self.mReplayBtn)

    -- 战斗统计按钮
    local statistsBtn = ui.newButton({
        normalImage = "zdjs_45.png",
        clickAction = function ()
            local fightInfo = self.mBattleResult.FightInfo or self.mBattleResult.Result or self.mBattleResult
            if type(fightInfo) == type("") then
                fightInfo = cjson.decode(fightInfo)
            end
            LayerManager.addLayer({name = "fightResult.DlgStatistDamageLayer", data = {statData = fightInfo.StatistsData}, cleanUp = false})
        end,
    })
    statistsBtn:setPosition(575, 800)
    self.mParentLayer:addChild(statistsBtn)

    -- 创建各个模块Pvp战斗胜利差异部分的控件
    if self.mBattleType == ModuleSub.eChallengeGrab then
    	-- 锻造挖矿
        local layout, choiceNode_ = ResultUtility.createUi(self, {"VsInfo", "PlayerAttrDrop", "PlayerExpProgress", "TreasureLootTips", "Choice"})
        local offsetY = - 50
        local x, y = layout:getPosition()
        layout:setPosition(x, y + offsetY)
		self.mChoiceNode_ = choiceNode_
    elseif self.mBattleType == ModuleSub.ePVPInter then
    	local layout = self:createPvpInterUI()
        layout:setAnchorPoint(cc.p(0.5, 1))
        layout:setPosition(320, 836)
        self.mParentLayer:addChild(layout, 1)

        -- 掉落
        local height
        if self.mBattleResult.BaseGetGameResourceList then
            height = 500
        else
            height = 460
        end
        ResultUtility.createUi(self, {height, "Drop"})
        -- 创建境界变化前后信息
        ResultUtility.createStateChange(self, self.mBattleResult.PVPinterFightLog)
        self.mCloseBtn:setPosition(440, 140)
        self.mReplayBtn:setVisible(true)
        self.mReplayBtn:setPosition(200, 140)
    elseif self.mBattleType == ModuleSub.eTeambattle then
        -- 镇守襄阳
        local layout, choiceNode_ = ResultUtility.createUi(
            self,
            {90, "Tips", "Drop"},
            {Tips = TR("")}
        )
        local offsetY = - 100
        local x, y = layout:getPosition()
        layout:setPosition(x, y + offsetY)
        -- local x, y = self.mEffectNode:getPosition()
        -- self.mEffectNode:setPosition(x, y + offsetY)
    elseif self.mBattleType == ModuleSub.eQuickExpMeetCompare then
        --猎魔
        local layout, choiceNode_ = ResultUtility.createUi(self, {"VsInfo", "Drop"})
        local offsetY = -100
        local x, y = layout:getPosition()
        layout:setPosition(x, y + offsetY)
        -- local x, y = self.mEffectNode:getPosition()
        -- self.mEffectNode:setPosition(x, y + offsetY)
    elseif self.mBattleType == ModuleSub.eExpedition then
        -- 组队副本
        local VITNum = PlayerAttrObj:getPlayerAttrByName("VIT")
        local text

        local px = 0
        if self.mBattleResult.ContinueFightInfo then
            text = TR("     已完成连战次数%d/%d，剩余体力%d\n战斗胜利，获得奖励如下（%s奖励+%d%%%s）:",
                self.mBattleResult.ContinueFightInfo.BattleCount, self.mBattleResult.ContinueFightInfo.NeedBattleCount,
                VITNum, "#56c636", self.mBattleResult.ResourceAdd or 0, Enums.Color.eNormalWhiteH)
        else
            text = TR("获得奖励如下（%s奖励+%d%%%s）:", "#56c636", self.mBattleResult.ResourceAdd or 0,
                Enums.Color.eNormalWhiteH)
            px = 330
        end

        local layout, choiceNode_ = ResultUtility.createUi(
            self,
            {90, "Tips", "Drop", "Background"},
            {Tips = text}
        )
        layout:setPosition(320, 750-px)

        if self.mBattleResult.ContinueFightInfo then
            -- 剩余连战次数
            local num = self.mBattleResult.ContinueFightInfo.NeedBattleCount - self.mBattleResult.ContinueFightInfo.BattleCount
            if num > 0 then
                self.mCloseBtn:setTitleText(TR("中止连战"))
                self.mCloseBtn:setClickAction(function()
                    self:requestContinueFight(0, 2)
                    -- 删除战斗页面
                    LayerManager.removeTopLayer(true)
                end)
            end

            -- 倒计时
            local timeout = 5
            -- 玩家状态(0：战斗结束，玩家还未准备下一场战斗；1：玩家已准备下一场战斗)
            local playerType = 0

            local timeLabel = ui.newLabel({
                text = "",
                size = 26,
                color = Enums.Color.eNormalWhite,
                outlineColor = Enums.Color.eBlack,
            })
            timeLabel:setPosition(320, 260)
            self.mParentLayer:addChild(timeLabel)
            self.mTimeLabel = timeLabel

            if num > 0 then
                Utility.schedule(timeLabel, function()
                    if timeout > 0 then
                        -- self.mCloseBtn:setEnabled(true)
                        timeout = timeout - 1

                        local text = playerType == 0 and TR("%d秒后进入下一场战斗", timeout) or TR("战斗准备中...%d秒", timeout)
                        timeLabel:setString(text)
                    end

                    if timeout == 0 then

                        if playerType == 0 then
                            self.mCloseBtn:setEnabled(false)
                            timeout = 15
                            -- 战斗就绪
                            self:requestContinueFight(num, 3)
                        else
                            -- 请求队伍状态
                            -- self:requestGetState(self.mBattleResult.NodeInfo.NodeModelId)
                            timeLabel:stopAllActions()

                            self.mCloseBtn:setTitleText(TR("退 出"))
                            self.mCloseBtn:setClickAction(function()
                                LayerManager.removeTopLayer(true)
                            end)
                            self.mCloseBtn:setEnabled(true)
                        end
                        local text = TR("战斗准备中...%d秒", timeout)
                        timeLabel:setString(text)
                        -- 设置玩家状态
                        playerType = 1
                    end
                end, 1)
            else
                timeLabel:setString(TR("连战已完成"))
            end  
            self.mCloseBtn:setPosition(320, 180)  
        else -- 当不是连战的时候 需要显示胜利回放
            local leftPosX, rightPosx = 160, 480
            for i=1,2 do
                -- 1代表左边是我方队友
                local image = i==1 and "zdjs_17.png" or "zdjs_16.png"  
                local posX = i==1 and leftPosX or rightPosx
                local IconSprite = ui.newSprite(image)
                IconSprite:setPosition(posX, 730)
                self.mParentLayer:addChild(IconSprite) 
            end

            -- 添加三对hero头像
            local nodeModelInfo = ExpeditionNodeModel.items[self.mParams.result.NodeInfo.NodeModelId]
            local enemyModelIdList = string.split(nodeModelInfo.heroModelID, "|")
            for i = 1, #self.mParams.myInfo do
                local posY = 660 - (i-1)*120
                -- 我方头像
                local myHeroCard = CardNode.createCardNode({
                    modelId = self.mParams.myInfo[i].HeadImageId,
                    fashionModelID = self.mParams.myInfo[i].FashionModelId,
                    IllusionModelId = self.mParams.myInfo[i].IllusionModelId,
                    resourceTypeSub = ResourcetypeSub.eHero,
                    allowClick = false,
                    cardShowAttrs = {
                        CardShowAttr.eBorder,
                    }
                })
                myHeroCard:setScale(0.95)
                myHeroCard:setPosition(leftPosX, posY)
                myHeroCard:setCardName(string.format(self.mParams.myInfo[i].Name))
                self.mParentLayer:addChild(myHeroCard)

                -- 敌方头像
                local enemyModelId = tonumber(string.split(enemyModelIdList[i], ",")[2])
                local enemyHeroCard = CardNode.createCardNode({
                    modelId = enemyModelId,
                    resourceTypeSub = ResourcetypeSub.eHero,
                    allowClick = false,
                    cardShowAttrs = {
                        CardShowAttr.eBorder,
                        CardShowAttr.eName
                    }
                })
                enemyHeroCard:setScale(0.95)
                enemyHeroCard:setPosition(rightPosx, posY)
                self.mParentLayer:addChild(enemyHeroCard)

                -- 查看战报按钮
                local battleBtn = ui.newButton({
                    normalImage = "zdjs_15.png",
                    position = cc.p(320, posY),
                    clickAction = function()
                        self:replayExpedition(i)
                    end
                })
                self.mParentLayer:addChild(battleBtn) 

                -- 添加胜负标签  
                local myIsWinImage = self.mParams.result.FightResults[i].IsWin and "zdjs_14.png" or "zdjs_13.png" 
                local enemyIsWinImage = self.mParams.result.FightResults[i].IsWin and "zdjs_13.png" or "zdjs_14.png" 
                local myIswinSprite = ui.newSprite(myIsWinImage)
                myIswinSprite:setPosition(23, 77)
                myHeroCard:addChild(myIswinSprite)

                local enemyIsWinSprite = ui.newSprite(enemyIsWinImage)
                enemyIsWinSprite:setPosition(23, 77)
                enemyHeroCard:addChild(enemyIsWinSprite)
            end  
            self.mCloseBtn:setClickAction(function()
                local layerName = LayerManager.getTopCleanLayerName()
                if layerName == "ComBattle.BattleLayer" then -- 回放特殊处理
                    LayerManager.deleteStackItem("challenge.ExpediMapLayer")
                end
                LayerManager.removeTopLayer(true)
            end)
            self.mCloseBtn:setPosition(320, 90)     
        end

        -- 注册战斗开始事件
        Notification:registerAutoObserver(self.mParentLayer, function()
            self:requestGetFightResult(self.mBattleResult.NodeInfo.NodeModelId)
        end, EventsName.eExpeditionFightResultPrefix)

        -- 注册连战请求事件
        Notification:registerAutoObserver(self.mParentLayer, function(node, data)
            for _, item in ipairs(data.readyInfoDetils) do
                if item.ReadyStatus == 2 then
                    self.mTimeLabel:stopAllActions()

                    -- 删除战斗页面
                    LayerManager.removeTopLayer(true)

                    ui.showFlashView(TR("连战被中止"))
                end
            end
        end, EventsName.eSureStartFight)
    elseif self.mBattleType == ModuleSub.eShengyuanWars then  
        local vsNode = ResultUtility.createVsInfo({
            myInfo = self.mMyInfo,
            otherInfo = self.mEnemyInfo,
            viewSize = cc.size(640, 100),
            bgImg = "",
            bgIsScale9 = true,
        })
        vsNode:setAnchorPoint(cc.p(0.5, 1))
        vsNode:setPosition(320, 650)
        self.mParentLayer:addChild(vsNode) 
        self.mCloseBtn:setPosition(320, 340)
        self.mReplayBtn:setVisible(false)
    elseif self.mBattleType == ModuleSub.eGuildBattle then
        if self.mBattleResult.GetStar then
            -- 星星文字列表
            local showTextList = {
                TR("消灭敌方主角"),
                TR("消灭敌方任意三人"),
                TR("全灭敌方"),
            }
            -- 星星是否亮判断
            local starCodeList = {
                "IsDiedMainHero",
                "IsDiedThree",
                "IsDiedAll",
            }
            local height = 720
            -- 星数评价
            local titileSprite = ui.newSprite("bpz_29.png")
            titileSprite:setPosition(320, height)
            self.mParentLayer:addChild(titileSprite)

            height = height - 40
            for i, text in ipairs(showTextList) do
                local starImage = "c_102.png"
                if self.mBattleResult[starCodeList[i]] or self.mBattleResult[starCodeList[3]] then
                    starImage = "c_75.png"
                end
                local starSprite = ui.newSprite(starImage)
                starSprite:setPosition(285+(i-1)*35, height)
                self.mParentLayer:addChild(starSprite)

                local starBgSize = cc.size(500, 45)
                local starBg = ui.newScale9Sprite("zdjs_06.png", starBgSize)
                starBg:setPosition(320, height-50-(i-1)*60)
                self.mParentLayer:addChild(starBg)

                local starLabel = ui.newLabel({
                        text = TR("{%s}   "..text, starImage),
                        color = Enums.Color.eWhite,
                        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
                        size = 20,
                    })
                starLabel:setAnchorPoint(cc.p(0, 0.5))
                starLabel:setPosition(starBgSize.width*0.3, starBgSize.height*0.5)
                starBg:addChild(starLabel)
            end

            height = height - 230
            -- 胜利奖励
            local winSprite = ui.newSprite("bpz_30.png")
            winSprite:setPosition(320, height)
            self.mParentLayer:addChild(winSprite)

            height = height - 70
            -- 帮派武技卡牌
            local card = CardNode.createCardNode({
                    resourceTypeSub = ResourcetypeSub.eGuildGongfuCoin,
                    num = self.mBattleResult.GetScore or 0,
                })
            card:setPosition(320, height)
            self.mParentLayer:addChild(card)

            height = height - 90
            -- 获得积分
            local scoreLabel = ui.newLabel({
                    text = TR("获得积分: %s", Utility.numberWithUnit(self.mBattleResult.GetScore or 0)),
                    color = Enums.Color.eWhite,
                    size = 20,
                })
            scoreLabel:setAnchorPoint(cc.p(0.5, 0.5))
            scoreLabel:setPosition(320, height)
            self.mParentLayer:addChild(scoreLabel)

            self.mReplayBtn:setVisible(true)
            self.mCloseBtn:setPosition(425, 220)
            self.mReplayBtn:setPosition(215, 220)
        else
            local vsNode = ResultUtility.createVsInfo({
                myInfo = self.mMyInfo,
                otherInfo = self.mEnemyInfo,
                viewSize = cc.size(640, 100),
                bgImg = "",
                bgIsScale9 = true,
            })
            vsNode:setAnchorPoint(cc.p(0.5, 1))
            vsNode:setPosition(320, 600)
            self.mParentLayer:addChild(vsNode)

            self.mReplayBtn:setVisible(true)
            self.mCloseBtn:setPosition(425, 220)
            self.mReplayBtn:setPosition(215, 220)
        end
    elseif self.mBattleType == Enums.ClientModuld.eStudy then
        self:createStudyUI()
    elseif self.mBattleType == ModuleSub.eSectPalace then
    	if self.mBattleResult.BaseGetGameResourceList then
	    	ResultUtility.createUi(self, {100, "Drop"})
    	end
    else
        -- 苍茫榜、序列争霸等
        local data = {}
        if self.mBattleType == ModuleSub.eChallengeWrestle then
            -- 序列争霸
            data.PlayerAttrDrop = {
                [1] = {
                    Name = TR("积分"),
                    Num = self.mBattleResult.AddIntegral
                }
            }
        end
    	local layout, choiceNode_ = ResultUtility.createUi(
            self,
            {"VsInfo", "PlayerAttrDrop", "PlayerExpProgress", "CommonTips", "Choice"},
            data,
            function ()
                --[[--------新手引导--------]]--
                local _, _, eventID = Guide.manager:getGuideInfo()
                print("ResultUtility.createUi callback", eventID)
                if eventID == 11605 or eventID == 117502 then
                    self:executeGuide()
                end
            end
        )
        local offsetY = - 50
        local x, y = layout:getPosition()
        layout:setPosition(x, y + offsetY)
        self.mChoiceNode_ = choiceNode_
    end

    if not self.mChoiceNode_ then
        self.mChoiceNode_ = {choiceStatus = function() return true end}
    end
end

-- 个人pvp战特殊控件
function PvpWinLayer:createPvpInterUI()
    local info = self.mBattleResult.PVPinterFightLog

    local Width = 640
    local Height = 420
    -- 容器
    local parent = ccui.Layout:create()
    parent:setContentSize(Width, Height)

    local x = 170
    local y = Height - 110

    -- 我方
    local sprite = ui.newSprite("zdjs_17.png")
    sprite:setPosition(x, y)
    parent:addChild(sprite)
    -- 我方头像
    local myHeroCard = CardNode.createCardNode({
        modelId = self.mMyInfo.HeadImageId,
        fashionModelID = self.mMyInfo.FashionModelId,
        IllusionModelId = self.mMyInfo.IllusionModelId,
        resourceTypeSub = ResourcetypeSub.eHero,
        cardShowAttrs = {
            CardShowAttr.eBorder,
        },
        allowClick = false,
    })
    myHeroCard:setPosition(x, y - 70)
    myHeroCard:setCardName(self.mMyInfo.PlayerName, Utility.getQualityByModelId(self.mMyInfo.HeadImageId))
    parent:addChild(myHeroCard)
    -- 添加胜负标签 
    local myIsWinImage = self.mBattleResult.IsWin and "zdjs_14.png" or "zdjs_13.png" 
    local myIswinSprite = ui.newSprite(myIsWinImage)
    myIswinSprite:setPosition(23, 77)
    myHeroCard:addChild(myIswinSprite)

    -- 对战精灵
    local vsSprite = ui.newSprite("zdfb_24.png")
    vsSprite:setPosition(320, y - 70)
    parent:addChild(vsSprite)

    -- 敌方
    x = Width - x
    local sprite = ui.newSprite("zdjs_16.png")
    sprite:setPosition(x, y)
    parent:addChild(sprite)
    -- 敌方头像
    local enemyHeroCard = CardNode.createCardNode({
        modelId = self.mEnemyInfo.HeroModelId or self.mEnemyInfo.TargetHeadImageId,
        IllusionModelId = self.mEnemyInfo.IllusionModelId,
        resourceTypeSub = ResourcetypeSub.eHero,
        cardShowAttrs = {
            CardShowAttr.eBorder,
        },
        allowClick = false,
    })
    enemyHeroCard:setPosition(x, y - 70)
    enemyHeroCard:setCardName(self.mEnemyInfo.Name or self.mEnemyInfo.TargetName, 
        Utility.getQualityByModelId(self.mEnemyInfo.HeroModelId or self.mEnemyInfo.TargetHeadImageId))
    parent:addChild(enemyHeroCard)

    -- 添加胜负标签  
    local enemyIsWinImage = self.mBattleResult.IsWin and "zdjs_13.png" or "zdjs_14.png" 
    local enemyIsWinSprite = ui.newSprite(enemyIsWinImage)
    enemyIsWinSprite:setPosition(23, 77)
    enemyHeroCard:addChild(enemyIsWinSprite)

    return parent
end

-- 切磋
function PvpWinLayer:createStudyUI()
    local layout = ResultUtility.createUi(self, {"PlayerExpProgress", "VsInfo",})
    local layoutx, layouty = layout:getPosition()
    layout:setPosition(layoutx, layouty - 100)

    local Width = 640
    local Height = 420
    -- 容器
    local parent = ccui.Layout:create()
    parent:setContentSize(Width, Height)
    parent:setPosition(-320, -550)
    layout:addChild(parent)

    local x = 170
    local y = Height - 110

    -- 我方
    local sprite = ui.newSprite("zdjs_17.png")
    sprite:setPosition(x, y)
    parent:addChild(sprite)
    -- 我方头像
    local myHeroCard = CardNode.createCardNode({
        modelId = self.mMyInfo.HeadImageId,
        fashionModelID = self.mMyInfo.FashionModelId,
        IllusionModelId = self.mMyInfo.IllusionModelId,
        resourceTypeSub = ResourcetypeSub.eHero,
        cardShowAttrs = {
            CardShowAttr.eBorder,
        },
        allowClick = false,
    })
    myHeroCard:setPosition(x, y - 70)
    myHeroCard:setCardName(self.mMyInfo.PlayerName, Utility.getQualityByModelId(self.mMyInfo.HeadImageId))
    parent:addChild(myHeroCard)
    -- 添加胜负标签 
    local myIsWinImage = self.mBattleResult.IsWin and "zdjs_14.png" or "zdjs_13.png" 
    local myIswinSprite = ui.newSprite(myIsWinImage)
    myIswinSprite:setPosition(23, 77)
    myHeroCard:addChild(myIswinSprite)

    -- 回放按钮
    local replayBtn = ui.newButton({
            normalImage = "zdjs_15.png",
            clickAction = function ()
                self:replay()
            end,
        })
    replayBtn:setPosition(320, y - 70)
    parent:addChild(replayBtn)

    -- 敌方
    x = Width - x
    local sprite = ui.newSprite("zdjs_16.png")
    sprite:setPosition(x, y)
    parent:addChild(sprite)
    -- 敌方头像
    local enemyHeroCard = CardNode.createCardNode({
        modelId = self.mEnemyInfo.HeadImageId,
        resourceTypeSub = ResourcetypeSub.eHero,
        cardShowAttrs = {
            CardShowAttr.eBorder,
        },
        allowClick = false,
    })
    enemyHeroCard:setPosition(x, y - 70)
    enemyHeroCard:setCardName(self.mEnemyInfo.PlayerName, Utility.getQualityByModelId(self.mEnemyInfo.HeadImageId))
    parent:addChild(enemyHeroCard)

    -- 添加胜负标签  
    local enemyIsWinImage = self.mBattleResult.IsWin and "zdjs_13.png" or "zdjs_14.png" 
    local enemyIsWinSprite = ui.newSprite(enemyIsWinImage)
    enemyIsWinSprite:setPosition(23, 77)
    enemyHeroCard:addChild(enemyIsWinSprite)
end

-- 重播
function PvpWinLayer:replay()
    local params = self.mParams

    local layerName = LayerManager.layerStack[table.getn(LayerManager.layerStack) - 1].name
    if layerName == "challenge.PvpInterFightLayer" then
        LayerManager.deleteStackItem("challenge.PvpInterFightLayer")
    end

    -- 战斗页面控制信息
    local controlParams = Utility.getBattleControl(params.battleType)
    local fightInfo = params.result.FightInfo or params.result.Result or params.result
    if type(fightInfo) == type("") then
        fightInfo = cjson.decode(fightInfo)
    end
    -- 调用战斗页面
    LayerManager.addLayer({
        name = "ComBattle.BattleLayer",
        data = {
            data = fightInfo,
            skip = controlParams.skip,
            trustee = controlParams.trustee,
            skill = controlParams.skill,
            map = Utility.getBattleBgFile(params.battleType),
            callback = function(retData)
                PvpResult.showPvpResultLayer(
                    params.battleType,
                    params.result,
                    params.myInfo,
                    params.enemyInfo
                )

                if controlParams.trustee and controlParams.trustee.changeTrusteeState then
                    controlParams.trustee.changeTrusteeState(retData.trustee)
                end
            end
        },
    })
end

-- 挑战六大派 重播战报入口
function PvpWinLayer:replayExpedition(index)
    local params = self.mParams

    -- 战斗页面控制信息
    local controlParams = Utility.getBattleControl(ModuleSub.eChallengeGrab) -- 用神兵锻造的规则
    -- 调用战斗页面
    LayerManager.addLayer({
        name = "ComBattle.BattleLayer",
        data = {
            data = params.result.FightInfo[index],
            skip = controlParams.skip,
            trustee = controlParams.trustee,
            skill = controlParams.skill,
            map = Utility.getBattleBgFile(ModuleSub.eChallengeGrab),
            callback = function(retData)
                PvpResult.showPvpResultLayer(
                    params.battleType,
                    params.result,
                    params.myInfo,
                    params.enemyInfo or nil
                )

                if controlParams.trustee and controlParams.trustee.changeTrusteeState then
                    controlParams.trustee.changeTrusteeState(retData.trustee)
                end
            end
        },
    })
end

---------网络---------
-- 新组队副本连战请求
function PvpWinLayer:requestContinueFight(count, fightType)
    HttpClient:request({
        moduleName = "ExpeditionNode",
        methodName = "ContinueFight",
        svrMethodData = {count, fightType},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
        end
    })
end

-- 请求远征连战战斗数据
function PvpWinLayer:requestGetFightResult(nodeId)
    local isUseDouble = LocalData:getGameDataValue("IsUseDouble")
    HttpClient:request({
        moduleName = "ExpeditionNode",
        methodName = "GetFightResult",
        svrMethodData = {nodeId, isUseDouble},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            local battleCount = nil
            if response.Value.ContinueFightInfo then
                battleCount = response.Value.ContinueFightInfo.BattleCount
            end
            LayerManager.addLayer({
                name = "challenge.ExpediMapLayer",
                data = {fightInfo = response.Value, memberList = self.mMyInfo, fightCount = battleCount},
                cleanUp = true,
            })
        end
    })
end

-- 获取游戏状态
function PvpWinLayer:requestGetState(nodeId)
    HttpClient:request({
        moduleName = "ExpeditionNode",
        methodName = "GetState",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            if response.Value.IsExistFightResult then
                self:requestGetFightResult(nodeId)
            else
                LayerManager.removeTopLayer(true)
            end
        end
    })
end

----------------- 新手引导 -------------------
function PvpWinLayer:onEnterTransitionFinish()
    self:executeGuide()
end

-- 执行新手引导
function PvpWinLayer:executeGuide()
    Guide.helper:executeGuide({
        -- 翻牌
        [11604] = {clickNode = self.mChoiceNode_.mClickNode_},
        -- 华山论剑，点击确定
        [11605] = {clickNode = self.mCloseBtn},
        -- 武林大会，翻牌
        [117501] = {clickNode = self.mChoiceNode_.mClickNode_},
        -- 武林大会，点击确定
        [117502] = {clickNode = self.mCloseBtn},
        -- 襄阳，战斗关闭
        [1190304] = {clickNode = self.mCloseBtn},
    })
end

return PvpWinLayer

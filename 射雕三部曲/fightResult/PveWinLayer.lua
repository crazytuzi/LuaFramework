--[[
    文件名: PveWinLayer.lua
	描述: Pve 战斗胜利结算页面
	创建人: liaoyuangang
	创建时间: 2016.06.10
-- ]]

local PveWinLayer = class("PveWinLayer", function(params)
    return display.newLayer()
end)

--[[
-- 参数 params 中的各项为
	{
		battleType = ModuleSub.eBattleNormal, -- 战役类型, 在 EnumsConfig.lua 文件的 ModuleSub中定义
		starCount = 0, -- 星数
		result = nil,  -- 服务端返回的结果
		myInfo = {}, -- 我方信息， 默认为nil
		enemyInfo = {}, -- 对方信息， 默认为nil
	}
]]
function PveWinLayer:ctor(params)
	params = params or {}
	self.mBattleType = params.battleType
	self.mStarCount = params.starCount
	self.mBattleResult = params.result
	self.mMyInfo = params.myInfo
	self.mEnemyInfo = params.enemyInfo
	self.mExtraData = params.extraData or {}

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

	-- 初始化页面控件
	self:initUI()
end

-- 初始化页面控件
function PveWinLayer:initUI()
	local onlyOver = false
	if self.mBattleType == ModuleSub.eXXBZ or self.mBattleType == ModuleSub.eBattleBoss then
		onlyOver = true
	end

    -- 显示背景图
    local bgSprite = ui.newSprite("zdjs_01.png")
    bgSprite:setPosition(cc.p(320, 568))
    self.mParentLayer:addChild(bgSprite, -10)

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

    -- local tmpSprite = ui.newScale9Sprite("zdjs_05.png", cc.size(640, 350))
    -- tmpSprite:setAnchorPoint(0.5, 1)
    -- tmpSprite:setPosition(320, 696.29)
    -- self.mParentLayer:addChild(tmpSprite)

    -- 关闭按钮
    self.mCloseBtn = ui.newButton({
    	normalImage = "c_33.png",
    	text = TR("关闭"),
    	clickAction = function ()
    		-- 如果是普通副本，关闭页面后停止自动战斗
            if self.mBattleType == ModuleSub.eBattleNormal then
                -- AutoFightObj:setAutoFight(false)

                local guideID, ordinal, eventID = Guide.manager:getGuideInfo()
                if eventID then
                    if eventID == 1020005--主引导:第一个节点结算
                    or eventID == 10202 -- 主引导:第二个节点结算
                    or eventID == 10212 -- 主引导:第三个节点结算
                    or eventID == 10214 -- 主引导:第四个节点结算
                    or eventID == 10216 -- 主引导:第五个节点结算
                    or eventID == 10306 -- 主引导:第二章节第一结点
                    or eventID == 104   -- 主引导:第二章节第二结点
                    or eventID == 104071-- 主引导:第二章节第三结点
                    or eventID == 104081-- 主引导:第二章节第四结点
                    then
                        Guide.manager:removeGuideLayer()
                        Guide.manager:nextStep(eventID, eventID == 104081) -- 主引导结束需要保存
                        -- 第二章第一个节点和第二个节点，直接跳转到阵容界面
                        if eventID == 10306 or eventID == 104 then
                            LayerManager.showSubModule(ModuleSub.eFormation)
                            return
                        elseif eventID == 10202 then
                            LayerManager.showSubModule(ModuleSub.eStore)
                            return
                        end
                    end
                    AutoFightObj:setAutoFight(false)
                else
                    local nextChapterId = BattleObj:getTriggerNewChapterId()
                    -- local nextChapterId = 27
                    if nextChapterId then
                        BattleObj:clearTriggerNewChapterId()
                        local chatpterData
                        if AutoFightObj:getAutoFight() then
                            chatpterData = {
                                    subPageType = ModuleSub.eBattleNormal,
                                    subPageData = nil
                                }
                        else
                            chatpterData = {
                                subPageType = ModuleSub.eBattleNormal,
                                subPageData = {
                                    [ModuleSub.eBattleNormal] = {nextChapterId = nextChapterId},
                                }
                            }
                        end
                        LayerManager.addLayer({
                            name = "battle.BattleMainLayer",
                            data = chatpterData,
                            cleanUp = true,
                        })
                        AutoFightObj:setAutoFight(false)
                        return
                    end
                end
            end

    		-- 删除战斗页面
    		LayerManager.removeTopLayer(true)
    	end,
    })
    self.mCloseBtn:setPosition(320, 200)
    self.mParentLayer:addChild(self.mCloseBtn)

    -- -- 战斗统计按钮
    -- local statistsBtn = ui.newButton({
    --     normalImage = "zdjs_45.png",
    --     clickAction = function ()
    --         LayerManager.addLayer({name = "fightResult.DlgStatistDamageLayer", cleanUp = false})
    --     end,
    -- })
    -- statistsBtn:setPosition(575, 800)
    -- self.mParentLayer:addChild(statistsBtn)

    -- 创建各个模块Pve战斗胜利差异部分的控件
    if self.mBattleType == ModuleSub.eBattleNormal then         -- 江湖
        --[[
        local _, _, eventID = Guide.manager:getGuideInfo()
        local recordStep = {
            [112] = 17, -- 挑战副本第一个节点后，箭头指向结算界面的确定按钮
            [122] = 29,
            [127] = 37,
            [1365]= 51,
        }
        if (recordStep[eventID]) then
            Guide.manager:saveGuideStep(Guide.config.recordID, recordStep[eventID], nil, true)
        end --]]
        self:createBattleNormalUI()
    elseif self.mBattleType == ModuleSub.eBattleElite then      -- 武林谱
        self:createBattleEliteUI()
    elseif self.mBattleType == ModuleSub.eBattleBoss then       -- 行侠仗义
        self:createBattleBossUI()
    elseif self.mBattleType == ModuleSub.eXXBZ then             -- 暂时没用（黑风神宫、上古福地，心魔宫）
        self:createXXBZUI()
    elseif self.mBattleType == ModuleSub.eTeambattle then       -- 据守襄阳（六道天轮）
        self:createTeambattleUI()
    elseif self.mBattleType == ModuleSub.eXrxs then             -- 江湖悬赏（血刃悬赏）
    	self:createChallengeGGZJUI()
    elseif self.mBattleType == ModuleSub.ePracticeBloodyDemonDomain then    -- 比武招亲（神装塔）
    	self:createPracticeBloodyDemonDomainUI()
    elseif self.mBattleType == ModuleSub.eQuickExpMeetChallenge then -- (闯荡奇遇)主宰挑战
        self:createBattleBossUI()
    elseif self.mBattleType == ModuleSub.eSectTask then -- 门派战斗任务
        self:createSectTaskUI()
    elseif self.mBattleType == ModuleSub.eZhenshouLaoyu then    -- 珍兽牢狱
        self:createEtlyUI()
    end
end

----------------------------------------------------------------------------------------------------

-- 普通副本（江湖）
function PveWinLayer:createBattleNormalUI()
	-- 掉落数据
	local dropList = Utility.analysisGameDrop(self.mBattleResult.BaseGetGameResourceList)
    local resTypeList = {ResourcetypeSub.eGold, ResourcetypeSub.eEXP, ResourcetypeSub.eHeroExp}
	local attrList, addExp = Utility.splitDropPlayerAttr(dropList, resTypeList)

    -- 玩家属性背景
    local attrBgSprite = ui.newSprite("zdjs_06.png")
    attrBgSprite:setPosition(cc.p(320, 640))
    self.mParentLayer:addChild(attrBgSprite)

	-- 创建掉落的玩家属性显示
	local attrNode = ResultUtility.createPlayerAttr(attrList)
	attrNode:setAnchorPoint(cc.p(0.5, 0.5))
	attrNode:setPosition(320, 640)
	self.mParentLayer:addChild(attrNode)

	-- 创建经验进度条
	local expNode = ResultUtility.createExpProg(addExp)
    expNode:setAnchorPoint(cc.p(0.5, 0.5))
    expNode:setPosition(320, 730)
    self.mParentLayer:addChild(expNode)

    -- 掉落物品显示
    if #dropList > 0 then
	    local dropNode = ui.createCardList({
	    	maxViewWidth = 620,
	        space = 20,
	        cardDataList = dropList,
	        allowClick = false, --是否可点击, 默认为false
	        needAction = true, -- 是否需要动画显示列表, 默认为false
	        needArrows = true, -- 当需要滑动显示时是否需要左右箭头, 默认为false
	    })
	    dropNode:setAnchorPoint(cc.p(0.5, 1))
	    dropNode:setPosition(320, 550)
	    self.mParentLayer:addChild(dropNode)
    else
    	local dropHintLabel = ui.newLabel({
    		text = TR("本次无物品掉落"),
    		color = Enums.Color.eYellow,
    		align = cc.TEXT_ALIGNMENT_CENTER,
            size = 25,
    	})
    	dropHintLabel:setAnchorPoint(cc.p(0.5, 0.5))
    	dropHintLabel:setPosition(320, 500)
    	self.mParentLayer:addChild(dropHintLabel)
    end

    -- 如果自动推图已经开启
    if ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eBattleAutomatic, false) then
	    ResultUtility.createAutoFightViews(self)
    end
end

-- 精英副本（武林谱）
function PveWinLayer:createBattleEliteUI()
	-- 掉落数据
	local dropList = Utility.analysisGameDrop(self.mBattleResult.BaseGetGameResourceList)
    local resTypeList = {ResourcetypeSub.eGold, ResourcetypeSub.eDiamond, ResourcetypeSub.eHeroExp}
	local attrList, addExp = Utility.splitDropPlayerAttr(dropList, resTypeList)

    -- 玩家属性背景
    local attrBgSprite = ui.newSprite("zdjs_06.png")
    attrBgSprite:setPosition(cc.p(320, 640))
    self.mParentLayer:addChild(attrBgSprite)

	-- 创建掉落的玩家属性显示
	local attrNode = ResultUtility.createPlayerAttr(attrList)
	attrNode:setAnchorPoint(cc.p(0.5, 0.5))
	attrNode:setPosition(320, 640)
	self.mParentLayer:addChild(attrNode)

    -- 掉落物品显示
    if #dropList > 0 then
	    local dropNode = ui.createCardList({
	    	maxViewWidth = 620,
	        space = 20,
	        cardDataList = dropList,
	        allowClick = false, --是否可点击, 默认为false
	        needAction = true, -- 是否需要动画显示列表, 默认为false
	        needArrows = true, -- 当需要滑动显示时是否需要左右箭头, 默认为false
	    })
	    dropNode:setAnchorPoint(cc.p(0.5, 1))
	    dropNode:setPosition(320, 550)
	    self.mParentLayer:addChild(dropNode)
    else
    	local dropHintLabel = ui.newLabel({
    		text = TR("本次无物品掉落"),
    		color = Enums.Color.eYellow,
    		align = cc.TEXT_ALIGNMENT_CENTER,
            size = 25,
    	})
    	dropHintLabel:setAnchorPoint(cc.p(0.5, 0.5))
    	dropHintLabel:setPosition(320, 500)
    	self.mParentLayer:addChild(dropHintLabel)
    end
    local str
    if self.mBattleResult.StarCount == 0 then
        str = TR("通关评价：存活1人达成1星")
    else
        str = TR("通关评价：存活%s人达成%s星", self.mBattleResult.StarCount, self.mBattleResult.StarCount)
    end

    local tipLabel = ui.newLabel({
        text = str,
        size = 24,
        outlineColor = Enums.Color.eBlack, 
        })
    tipLabel:setPosition(320, 580)
    self.mParentLayer:addChild(tipLabel)

end

-- 妖王（行侠仗义）
function PveWinLayer:createBattleBossUI()
	-- 掉落数据
	local dropList = Utility.analysisGameDrop(self.mBattleResult.BaseGetGameResourceList)
    local resTypeList = {ResourcetypeSub.eGold, ResourcetypeSub.eEXP, ResourcetypeSub.eHeroExp}
	local attrList = Utility.splitDropPlayerAttr(dropList, resTypeList)

    -- 玩家属性背景
    local attrBgSprite = ui.newSprite("zdjs_06.png")
    attrBgSprite:setPosition(cc.p(320, 640))
    self.mParentLayer:addChild(attrBgSprite)

	-- 创建掉落的玩家属性显示
	local attrNode = ResultUtility.createPlayerAttr(attrList)
	attrNode:setAnchorPoint(cc.p(0.5, 0.5))
	attrNode:setPosition(320, 640)
	self.mParentLayer:addChild(attrNode)

    -- 条件
    if self.mBattleResult.HurtValue then
        local label = ui.newLabel({
            text = TR("本次挑战造成的伤害：%s%d", Enums.Color.eYellowH, self.mBattleResult.HurtValue),
            color = Enums.Color.eWhite,
            x = 320,
            y = 745,
        })
        self.mParentLayer:addChild(label)
    end

    -- 提示
    if self.mBattleResult.SingleJiFen then
            local label = ui.newLabel({
            text = TR("获得%s%d%s积分", Enums.Color.eYellowH, self.mBattleResult.SingleJiFen, Enums.Color.eWhiteH),
            color = Enums.Color.eWhite,
            size = 26,
            x = 320,
            y = 700,
        })
        self.mParentLayer:addChild(label)
    end

	-- 显示获得奖励
    if #dropList > 0 then
	   local dropNode = ui.createCardList({
        	maxViewWidth = 620,
            space = 20,
            cardDataList = dropList,
            allowClick = false,
            needAction = true,
            needArrows = true,
        })
        dropNode:setAnchorPoint(cc.p(0.5, 1))
        dropNode:setPosition(320, 550)
        self.mParentLayer:addChild(dropNode)
    else
        local noneLabel = ui.newLabel({
            text = TR("本次挑战未获得物品"),
            color = Enums.Color.eWhite,
            size = 26,
            x = 320,
            y = 500,
        })
        self.mParentLayer:addChild(noneLabel)
    end
end

-- 门派战斗任务
function PveWinLayer:createSectTaskUI()
    local taskModel = SectTaskWeightRelation.items[self.mExtraData[1]]

    local tipSprite = ui.newSprite("mp_48.png")
    tipSprite:setPosition(320, 580)
    self.mParentLayer:addChild(tipSprite)

    local taskLable = ui.newLabel({
        text = TR("      恭喜少侠\n已击败%s", taskModel.picName),
        size = 24,
        outlineColor = Enums.Color.eBlack,
        })
    taskLable:setPosition(413, 183)
    tipSprite:addChild(taskLable)

end

-- 上古福地
function PveWinLayer:createXXBZUI()
	-- 标题
	local label = ui.newLabel({
        text = TR("本次挑战造成的伤害："),
        color = Enums.Color.eWhite,
        size = 26,
        x = 320,
        y = 805,
    })
    self.mParentLayer:addChild(label)

    -- 条件
	local label = ui.newLabel({
        text = TR("%d", self.mExtraData.damage),
        color = Enums.Color.eYellow,
        x = 320,
        y = 770,
    })
    self.mParentLayer:addChild(label)

    -- 提示
	local label = ui.newLabel({
        text = TR("恭喜获得以下奖励"),
        color = Enums.Color.eWhite,
        siez = 26,
        x = 320,
        y = 630,
    })
    self.mParentLayer:addChild(label)

	-- 显示获得奖励
    local dropNode = ui.createCardList({
    	maxViewWidth = 620,
        space = 20,
        cardDataList = Utility.analysisGameDrop(self.mBattleResult.BaseGetGameResourceList),
        allowClick = false,
        needAction = true,
        needArrows = true,
    })
    dropNode:setAnchorPoint(cc.p(0.5, 1))
    dropNode:setPosition(320, 590)
    self.mParentLayer:addChild(dropNode)
end

-- 据守襄阳
function PveWinLayer:createTeambattleUI()
end

-- 江湖悬赏
function PveWinLayer:createChallengeGGZJUI()
	-- 显示对阵双方的战力信息
	local vsNode = ResultUtility.createVsInfo({
		myInfo = self.mMyInfo,
		otherInfo = self.mEnemyInfo,
		viewSize = cc.size(640, 100),
		bgImg = "",
		bgIsScale9 = true,
	})
	vsNode:setAnchorPoint(cc.p(0.5, 1))
	vsNode:setPosition(320, 760)
	self.mParentLayer:addChild(vsNode)

	-- 创建打开宝箱的特效
	self.mCloseBtn:setVisible(false)
	local openBoxNode = ResultUtility.createOpenBox(true, function()
		self.mCloseBtn:setVisible(true)

		-- 提示
		local label = ui.newLabel({
            text = TR("恭喜获得奖励"),
            color = Enums.Color.eWhite,
            siez = 26,
            x = 320,
            y = 590,
        })
        self.mParentLayer:addChild(label)

		-- 显示获得奖励
        local dropNode = ui.createCardList({
	    	maxViewWidth = 620,
	        space = 20,
	        cardDataList = Utility.analysisGameDrop(self.mBattleResult.BaseGetGameResourceList),
	        allowClick = false,
	        needAction = true,
	        needArrows = true,
	    })
	    dropNode:setAnchorPoint(cc.p(0.5, 1))
	    dropNode:setPosition(320, 550)
	    self.mParentLayer:addChild(dropNode)
	end)
	openBoxNode:setAnchorPoint(cc.p(0.5, 0.5))
	openBoxNode:setPosition(320, 550)
	self.mParentLayer:addChild(openBoxNode)
end

-- 比武招亲
function PveWinLayer:createPracticeBloodyDemonDomainUI()
    -- 标题
    local label = ui.newLabel({
        text = TR("通关评价"),
        color = Enums.Color.eYellow,
        size = 26,
        x = 320,
        y = 720,
    })
    self.mParentLayer:addChild(label)

    -- 条件
    local label = ui.newLabel({
        text = TR("恭喜达成通关条件 : %s", self.mExtraData.condition or ""),
        color = Enums.Color.eWhite,
        x = 320,
        y = 690,
    })
    self.mParentLayer:addChild(label)


    -- 分解当前关卡条件
    local strType = BddNodeModel.items[self.mExtraData.NodeId].starTypeStr
    local strInfo = string.splitBySep(strType, ",")
    --条件容器
    local typeInfo = {}
    for k, v in ipairs(strInfo) do
        v = string.splitBySep(v, "|")
        table.insert(typeInfo, v)
    end
    --胜利通关条件
    table.insert(typeInfo, 1, {1, 1})

    --分解服务器返回的关卡通关条件
    local starData = self.mBattleResult.StarTypeStr
    starData = string.splitBySep(starData, ",")
    --条件
    local starInfo = {}
    for k, v in ipairs(starData) do
        v = string.splitBySep(v, "|")
        table.insert(starInfo, v)
    end

    --创建条件
    local conditionY = 610
    for _, v in ipairs(typeInfo) do
        --层
        local layout = ccui.Layout:create()
        layout:setPosition(210, conditionY)
        self.mParentLayer:addChild(layout)
        --描述
        local text = ""
        if v[1] == 1 then
            text = BddClearanceModel.items[tonumber(v[1])].description
        elseif tonumber(v[1]) == 2 then
            text = string.format(BddClearanceModel.items[tonumber(v[1])].description, tostring(v[2].."%"))
        else
            text = string.format(BddClearanceModel.items[tonumber(v[1])].description, tostring(v[2]))
        end
        local desLabel = ui.newLabel({
            text = text,
            size = 19,
            align = ui.TEXT_ALIGN_LEFT,
            dimensions = cc.size(300, 40)
        })
        desLabel:setAnchorPoint(cc.p(0, 0.5))
        layout:setContentSize(390, 50)
        desLabel:setPosition(50, layout:getContentSize().height - 15)
        layout:addChild(desLabel)

        --星星
        local starSprite = ui.newSprite("c_75.png")
        layout:addChild(starSprite)
        starSprite:setPosition(30, layout:getContentSize().height - 15)

        --星星是否需要置灰 表中的配置与服务器的返回进行比较
        local isGray = true
        for k1, v1 in ipairs(starInfo) do
            if v1[1] == v[1] and v1[2] == v[2] then
                isGray = false
                break
            end
        end
        if v[1] == 1 then
            isGray = false
        end
        starSprite:setGray(isGray)

        conditionY = conditionY - 35
    end

    -- 显示获得奖励
    local dropList = Utility.analysisGameDrop(self.mBattleResult.BaseGetGameResourceList)
    if next(dropList) == nil then
        local label = ui.newLabel({
            text = TR("无战利品"),
            color = Enums.Color.eYellow,
            size = 26,
            x = 320,
            y = 470,
        })
        self.mParentLayer:addChild(label)
    else
        local dropNode = ui.createCardList({
            maxViewWidth = 620,
            space = 20,
            cardDataList = dropList,
            allowClick = false,
            needAction = true,
            needArrows = true,
        })
        dropNode:setAnchorPoint(cc.p(0.5, 1))
        dropNode:setPosition(320, 510)
        self.mParentLayer:addChild(dropNode)
    end
end

-- 珍兽牢狱
function PveWinLayer:createEtlyUI()
    -- 掉落数据
    local dropList = Utility.analysisGameDrop(self.mBattleResult.BaseGetGameResourceList)
    local resTypeList = {ResourcetypeSub.eGold, ResourcetypeSub.eEXP, ResourcetypeSub.eHeroExp}
    local attrList, addExp = Utility.splitDropPlayerAttr(dropList, resTypeList)

    -- 创建经验进度条
    local expNode = ResultUtility.createExpProg(addExp)
    expNode:setAnchorPoint(cc.p(0.5, 0.5))
    expNode:setPosition(320, 730)
    self.mParentLayer:addChild(expNode)

    -- 创建通关评价
    if self.mBattleResult.StarNum and self.mBattleResult.RemainNum then
        local tipLabel = ui.newLabel({
            text = TR("通关评价：存活%s人达成%s星", self.mBattleResult.RemainNum, self.mBattleResult.StarNum),
            size = 24,
            outlineColor = Enums.Color.eBlack, 
            })
        tipLabel:setPosition(320, 600)
        self.mParentLayer:addChild(tipLabel)
    end

    -- 掉落物品显示
    if #dropList > 0 then
        local dropNode = ui.createCardList({
            maxViewWidth = 620,
            space = 20,
            cardDataList = dropList,
            allowClick = false, --是否可点击, 默认为false
            needAction = true, -- 是否需要动画显示列表, 默认为false
            needArrows = true, -- 当需要滑动显示时是否需要左右箭头, 默认为false
        })
        dropNode:setAnchorPoint(cc.p(0.5, 1))
        dropNode:setPosition(320, 550)
        self.mParentLayer:addChild(dropNode)
    else
        local dropHintLabel = ui.newLabel({
            text = TR("本次无物品掉落"),
            color = Enums.Color.eYellow,
            align = cc.TEXT_ALIGNMENT_CENTER,
            size = 25,
        })
        dropHintLabel:setAnchorPoint(cc.p(0.5, 0.5))
        dropHintLabel:setPosition(320, 500)
        self.mParentLayer:addChild(dropHintLabel)
    end
end

--------------------- 新手引导 ---------------------
function PveWinLayer:onEnterTransitionFinish()
    self:executeGuide()
end

-- 在checkPve中会提示升级界面，升级关闭时会再次调用executeGuide，所以需要静音
--levelMute: 为true时表示需要静音(1030501回调时可能传入其它参数)
function PveWinLayer:executeGuide(levelMute)
    local guideParams = {clickNode = self.mCloseBtn, mute = (levelMute == true)}
    Guide.helper:executeGuide({
        [1020005]  = guideParams,
        [10202]  = guideParams,
        [10212]  = guideParams,
        [10214]  = guideParams,
        [10216] = guideParams,
        [1030501] = {nextStep = handler(self, self.executeGuide)},
        [10306] = guideParams,
        [104] = guideParams,
        [104071] = guideParams,
        [104081] = guideParams,
        -- 武林谱
        [10803] = guideParams,
        -- 比武招亲，点击关闭
        [115104] = guideParams,
        -- 大侠之路
        [9005] = {clickNode = ChatBtnLayer.roadBtn},
    })
end


return PveWinLayer

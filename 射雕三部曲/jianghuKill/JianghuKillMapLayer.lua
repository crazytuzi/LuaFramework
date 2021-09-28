--[[
    文件名: JianghuKillMapLayer.lua
    描述: 江湖杀地图界面
    创建人: lengjiazhi
    创建时间: 2018.07.31
-- ]]
local JianghuKillMapLayer = class("JianghuKillMapLayer", function(params)
	return display.newLayer()
end)

function JianghuKillMapLayer:ctor(params)
    self.mRefreshTime = 1
    self.mOldBuyTimes = 0   -- 已购买次数
    self.mPlayerHandleData = {}

	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	self.mRefreshLayer = ui.newStdLayer()
	self:addChild(self.mRefreshLayer)

    self.mShowingId = nil

	self:initUI()
end

function JianghuKillMapLayer:initUI()
    -- 屏蔽下层点击事件
    ui.registerSwallowTouch({
        node = self.mParentLayer,
        allowTouch = false,
        beganEvent = function() 
            if self.mCityView then
                self.mCityView:removeFromParent()
                self.mCityView = nil
            end
            self.mShowingId = nil
            return true
        end
    })

	--关闭按钮
    local cancelBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(600, 1000),
        clickAction = function ()
            LayerManager.removeLayer(self)
        end
    })
    self.mRefreshLayer:addChild(cancelBtn, 1)

    --按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        position = cc.p(45, 1000),
        clickAction = function()
            MsgBoxLayer.addRuleHintLayer(TR("规则"), {
                    TR("1.62级开启江湖杀。"),
                    TR("2.开启时间：周五、周六的10：00至21:59:59，一周为一个赛季，周五22：00至周六10:00为休息时间，所有玩家在江湖杀中不能进行任何行动。"),
                    TR("3.江湖杀为武林盟与浑天教俩个势力间的大型跨服竞技玩法，玩家代表各自势力争夺并领悟散落在众多门派中的天机残页，最终领悟天机残页最多的势力获得胜利。"),
                    TR("4.挑战、防守、完成势力任务和职业任务都可以获得荣誉点，最终会根据玩家本赛季获得的荣誉点对每个职业进行排名并发放排行奖励，每个职业的排行榜是相互独立的。小提示：选择人数较少的职业，获得更高排名的机会更大哦~"),
                    TR("5.赛季开始后不能更换职业和势力。"),
                    TR("6.赛季开始时，所有玩家都在各自的势力总部，武林盟的势力总部是桃花岛，浑天教总部是明教。"),
                    TR("7.江湖杀中玩家可以进行四种操作："),
                    TR("①　驻守：可在自己所属势力进行驻守，如果被击败则回到势力总部。"),
                    TR("②　挑战：可以对敌方势力门派内驻守的玩家进行挑战，击败最后一个驻守玩家即可占领该门派。"),
                    TR("③　移动：只能移动到相邻门派，并且不能从敌方门派移动到另一个敌方门派。"),
                    TR("④　领悟：可以去己方势力门派领悟天机残页，个人领悟的页数会累计到势力总页数。"),
                    TR("8.江湖杀中每个人都有四种状态："),
                    TR("①　精神：如果精神被耗尽则回到势力总部；"),
                    TR("②　功力：发起挑战时需要消耗；"),
                    TR("③　粮草：在门派间移动时需要消耗；"),
                    TR("④　悟性：领悟天机残页时需要消耗。"),
                },
                cc.size(590, 840))
        end,
    })
    self.mRefreshLayer:addChild(ruleBtn, 1)

    --背景图
    local topbgSprite = ui.newScale9Sprite("c_01.png", cc.size(640, 121))
    topbgSprite:setPosition(320, 1136)
    topbgSprite:setAnchorPoint(0.5, 1)
    self.mRefreshLayer:addChild(topbgSprite)

    --头像
    local headImageId = PlayerAttrObj:getPlayerAttrByName("HeadImageId")
    local headNode = CardNode.createCardNode({
    	resourceTypeSub = Utility.getTypeByModelId(headImageId),
    	modelId = headImageId,
        allowClick = false,
    	cardShowAttrs = {CardShowAttr.eBorder}
    	})
    headNode:setPosition(55, 68)
    topbgSprite:addChild(headNode)

    local blackBg = ui.newScale9Sprite("jhs_10.png", cc.size(240, 70))
    blackBg:setAnchorPoint(0, 0.5)
    blackBg:setPosition(80, 80)
    topbgSprite:addChild(blackBg, -1)

    --阵营等级
    local campLvLabel = ui.newLabel({
    	text = TR("武林盟精锐1级"),
    	color = cc.c3b(0xfe, 0xf1, 0xca),
    	outlineColor = cc.c3b(0x54, 0x26, 0x15),
    	})
    campLvLabel:setAnchorPoint(0, 0.5)
    campLvLabel:setPosition(145, 95)
    topbgSprite:addChild(campLvLabel)
    self.mCampLvLabel = campLvLabel
    --阵营图标
    local campTipPic = ui.newSprite("jhs_112.png")
    campTipPic:setPosition(122, 95)
    topbgSprite:addChild(campTipPic)
    self.mCampTipPic = campTipPic

    --职业等级
    local jobLvLabel = ui.newLabel({
    	text = TR("刺客1级"),
    	color = cc.c3b(0xfe, 0xfe, 0xf9),
    	outlineColor = cc.c3b(0x54, 0x26, 0x15),
    	size = 20,
    	})
    jobLvLabel:setAnchorPoint(0, 0.5)
    jobLvLabel:setPosition(145, 65)
    topbgSprite:addChild(jobLvLabel)
    self.mJobLvLabel = jobLvLabel
    --职业图标
    local jobTipPic = ui.newSprite("jhs_32.png")
    jobTipPic:setPosition(122, 65)
    topbgSprite:addChild(jobTipPic)
    jobTipPic:setScale(0.8)
    self.mJobTipPic = jobTipPic

    -- 战报按钮
    local reportBtn = ui.newButton({
        normalImage = "tb_121.png",
        clickAction = function()
            print("战报按钮")
            LayerManager.addLayer({
                    name = "jianghuKill.jianghuKillReportLayer",
                    cleanUp = false,
                })
            
        end
        })
    reportBtn:setPosition(320, 68)
    topbgSprite:addChild(reportBtn)

    --阵营任务按钮
    local campTaskBtn = ui.newButton({
		normalImage = "jhs_111.png",
		clickAction = function()
			print("阵营任务按钮")
            LayerManager.addLayer({
                    name = "jianghuKill.JianghuKillTaskLayer",
                    data = {
                        taskType = 1,
                    },
                    cleanUp = false,
                })
            
		end
		})
	campTaskBtn:setPosition(410, 68)
	topbgSprite:addChild(campTaskBtn)
    -- 添加小红点
    local function dealRedDotVisible(redDotSprite)
        redDotSprite:setVisible(RedDotInfoObj:isValid(ModuleSub.eJiangHuKillForce))
    end
    ui.createAutoBubble({parent = campTaskBtn,
        eventName = RedDotInfoObj:getEvents(ModuleSub.eJiangHuKillForce),
        refreshFunc = dealRedDotVisible})

    --职业任务按钮
	local jobBtn = ui.newButton({
		normalImage = "jhs_109.png",
		clickAction = function()
			print("职业任务按钮")
            LayerManager.addLayer({
                    name = "jianghuKill.JianghuKillTaskLayer",
                    data = {
                        taskType = 2,
                    },
                    cleanUp = false,
                })
		end
		})
	jobBtn:setPosition(500, 68)
	topbgSprite:addChild(jobBtn)
    -- 添加小红点
    local function dealRedDotVisible(redDotSprite)
        redDotSprite:setVisible(RedDotInfoObj:isValid(ModuleSub.eJiangHuKillJob))
    end
    ui.createAutoBubble({parent = jobBtn,
        eventName = RedDotInfoObj:getEvents(ModuleSub.eJiangHuKillJob),
        refreshFunc = dealRedDotVisible})

    --商店按钮
	local storeBtn = ui.newButton({
		normalImage = "jhs_110.png",
		clickAction = function()
			print("商店按钮")
            LayerManager.addLayer({name = "jianghuKill.JianghuKillShopLayer", cleanUp = false})
		end
		})
	storeBtn:setPosition(590, 68)
	topbgSprite:addChild(storeBtn)

    --回城重新刷新所有数据按钮
    local backHomeBtn = ui.newButton({
        normalImage = "jhs_118.png",
        clickAction = function()
            local homeID = self.mIsWLM and 31 or 1
            if self.mCurNodeId == homeID then
                ui.showFlashView(TR("你已经在势力总部了"))
                return
            end
            MsgBoxLayer.addOKLayer(
                TR("是否确认回到势力总部？"), 
                TR("回城"), 
                {
                    {
                        normalImage = "c_28.png",
                        text = TR("确定"),
                        clickAction = function(layer)
                            self:requestBackToHome()
                            LayerManager.removeLayer(layer)
                        end,
                    },
            },{})
        end
        })
    backHomeBtn:setPosition(580, 60)
    self.mRefreshLayer:addChild(backHomeBtn)

    local myPosBtn = ui.newButton({
        normalImage = "jhs_119.png",
        -- text = TR("我的位置"),
        clickAction = function()
            if self.mStatus == Enums.JHKPlayerStatus.eMoving then
                return
            end
            self:scorllToItem(self.mCurNodeId)
        end
    })
    myPosBtn:setPosition(490, 60)
    self.mRefreshLayer:addChild(myPosBtn)

	-- self:createPlayerInfo()
    self:createMap()
end

--创建顶部显示
function JianghuKillMapLayer:createTopView()
	local barBgSprite = ui.newSprite("jhs_03.png")
	barBgSprite:setPosition(320, 955)
	self.mRefreshLayer:addChild(barBgSprite)

	local campSpriteA = ui.newSprite("jhs_13.png")
	self.mRefreshLayer:addChild(campSpriteA)
	local campSpriteB = ui.newSprite("jhs_12.png")
	self.mRefreshLayer:addChild(campSpriteB)
	local off = self.mIsWLM and -1 or 1
	campSpriteA:setPosition(320 + off * 150, 990)
	campSpriteB:setPosition(320 + (-off) * 150, 990)

	local vsSprite = ui.newSprite("jhs_09.png")
	vsSprite:setPosition(320, 1000)
	self.mRefreshLayer:addChild(vsSprite)

	local tempId = 1
	local checkRankBtn = ui.newButton({
		normalImage = "jhs_07.png",
		clickAction = function ()
			LayerManager.addLayer({name = "jianghuKill.JianghuKillRankLayer", data = {jobId = self.mJobId}, cleanUp = false})
		end
		})
	checkRankBtn:setPosition(320, 918)
	self.mRefreshLayer:addChild(checkRankBtn, -1)

    local campLvLabel = ui.newLabel({
    	text = TR("查看排行"),
    	color = Enums.Color.eNormalWhite,
    	outlineColor = cc.c3b(0x54, 0x26, 0x15),
    	size = 20,
    	})
    campLvLabel:setPosition(320, 923)
    self.mRefreshLayer:addChild(campLvLabel)

    local scoreBGL = ui.newSprite("jhs_08.png")
    scoreBGL:setAnchorPoint(0, 0.5)
    scoreBGL:setPosition(270, 928)
    scoreBGL:setRotation(180)
    self.mRefreshLayer:addChild(scoreBGL, -2)

    local scoreBGR = ui.newSprite("jhs_08.png")
    scoreBGR:setAnchorPoint(0, 0.5)
    scoreBGR:setPosition(370, 928)
    self.mRefreshLayer:addChild(scoreBGR, -2)

    --己方势力分数
    local scoreLabelSelf = ui.newLabel({
    	text = 200,
    	size = 18,
    	color = Enums.Color.eNormalWhite,
    	outlineColor = Enums.Color.eOutlineColor,
    	})
    scoreLabelSelf:setAnchorPoint(1, 0.5)
    scoreLabelSelf:setPosition(260, 928)
    self.mRefreshLayer:addChild(scoreLabelSelf)
    self.mScoreLabelSelf = scoreLabelSelf

    --敌方势力分数
    local scoreLabelEnemy = ui.newLabel({
    	text = 200,
    	size = 18,
    	color = Enums.Color.eNormalWhite,
    	outlineColor = Enums.Color.eOutlineColor,
    	})
    scoreLabelEnemy:setAnchorPoint(0, 0.5)
    scoreLabelEnemy:setPosition(380, 928)
    self.mRefreshLayer:addChild(scoreLabelEnemy)
    self.mScoreLabelEnemy = scoreLabelEnemy

    --分数进度条
    local barBgPic = self.mIsWLM and "jhs_04.png" or "jhs_05.png"
    local barPic = self.mIsWLM and "jhs_05.png" or "jhs_04.png"
    local scoreBar = require("common.ProgressBar"):create({
        bgImage = barBgPic,
        barImage = barPic,
        currValue = 50,
        maxValue = 100,
    })
    scoreBar:setPosition(320, 953)
    self.mRefreshLayer:addChild(scoreBar)
    self.mScoreBar = scoreBar

    local barSize = scoreBar:getContentSize()

    --进度条上的黄色标识
    local posX = (50/100) * barSize.width
    local tipSprite = ui.newSprite("jhs_06.png")
    tipSprite:setAnchorPoint(0.5, 0.5)
    tipSprite:setPosition(posX, 7.5)
    scoreBar:addChild(tipSprite)
    self.mBarTipSprite = tipSprite

    --组队按钮
    local teamBtn = ui.newButton({
        normalImage = "jhs_29.png",
        clickAction = function()
            LayerManager.addLayer({name = "jianghuKill.JianghuKillTeamLayer", data = {currentNodeId = self.mCurNodeId or 1}, cleanUp = false,})
        end
        })
    teamBtn:setScale(0.7)
    teamBtn:setPosition(580, 150)
    self.mRefreshLayer:addChild(teamBtn)
    self.mTeamBtn = teamBtn

    local higherNode = cc.Node:create()
    higherNode:setContentSize(26, 26)
    higherNode:setPosition(240, 990)
    higherNode:setAnchorPoint(0.5, 0.5)
    self.mRefreshLayer:addChild(higherNode)

    -- local higherEff = ui.newEffect({
    --     parent = higherNode,
    --     effectName = "effect_ui_jianghusha_buff",
    --     animation = "2",
    --     position = cc.p(13, 13),
    --     loop = true,
    -- })

    local higherBtn = ui.newButton({
        normalImage = "c_83.png",
        size = cc.size(26, 26),
        clickAction = function()
            local touchLayer = ui.newStdLayer()
            self:addChild(touchLayer, 10000)

            ui.registerSwallowTouch({
                node = touchLayer,
                allowTouch = true,
                endedEvent = function(touch, event)
                    touchLayer:removeFromParent()
                    touchLayer = nil
                end
            })
            local posOff = self.mBuffTag and 240 or 400
            local bgSprite = ui.newSprite("zr_53.png")
            bgSprite:setAnchorPoint(1, 1)
            bgSprite:setPosition(posOff-13, 1003)
            touchLayer:addChild(bgSprite)

            local tipSprite = ui.newSprite("jhs_136.png")
            tipSprite:setPosition(40, 204)
            bgSprite:addChild(tipSprite)

            local tipLabel = ui.newLabel({
                text = TR("势不可挡"),
                color = cc.c3b(208, 123, 0),
            })
            tipLabel:setPosition(120, 204)
            bgSprite:addChild(tipLabel)

            local introLabel = ui.newLabel({
                text = TR("比分领先的势力，全体成员挑战或防守获得荣誉点%s+%s%%", Enums.Color.eGreenH, JianghukillModel.items[1].winAdd/100),
                dimensions = cc.size(170, 0),
                })
            introLabel:setPosition(110, 124)
            bgSprite:addChild(introLabel)

        end
        })
    higherBtn:setPosition(13, 13)
    higherNode:addChild(higherBtn)
    self.mHigherNode = higherNode
end

--滚动
function JianghuKillMapLayer:scorllToItem(id, notNeedDelay)
	local pos = Utility.analysisPoints(JianghukillMapModel.items[id].coordinate)

    local curViewPosition = cc.p((pos.x - 320)/14.20, (2220 - pos.y - 568)/11.1)
    local tempPosX = -pos.x + 320
    local tempPosY = -pos.y + 568

    --根据地图大小设置scrollView的inner位置限制
    --x轴为2040大小，y轴为2220大小
    if tempPosX > 0 then
        tempPosX = 0
    elseif tempPosX < -1400 then
        tempPosX = -1400
    end
    if tempPosY > 0 then
        tempPosY = 0
    elseif tempPosY < -1084 then
        tempPosY = -1084
    end
    local targetPos = cc.p(tempPosX, tempPosY)
    local innner = self.mWorldView:getInnerContainer()
    local delayTime = notNeedDelay and 0 or 0.2
    innner:runAction(cc.MoveTo:create(delayTime, targetPos))

    self.mPlayerNode:setPosition(pos.x, pos.y)
end

--创建建筑按钮
function JianghuKillMapLayer:createBuildingBtns()
    self.mCityList = {}
	local Sectconfigs = JianghukillMapModel.items
	for i,v in ipairs(Sectconfigs) do
		local pos = Utility.analysisPoints(v.coordinate)
		local buildBtn = ui.newButton({
			normalImage = "c_83.png",
			size = cc.size(150, 150),
			-- text = tostring(v.ID),
			clickAction = function()
                if self.mShowingId and self.mShowingId == v.ID then
                    self.mShowingId = nil
                    return
                end

                self:requestGetNodeInfo(v.ID)
			end
			})
		buildBtn:setAnchorPoint(0.5, 0.5)
		buildBtn:setPosition(pos)
		self.mMapBg:addChild(buildBtn)

        --节点名字背景板
        local nameBgSprite = ui.newSprite("jhs_57.png")
        nameBgSprite:setPosition(0, 100)
        buildBtn:addChild(nameBgSprite)
        local bgSize = nameBgSprite:getContentSize()
        --节点名字
        local nameLabel = ui.newLabel({
            text = v.name,
            dimensions = cc.size(24, 0),
            color = Enums.Color.eBlack,
            size = 26,
            })
        nameLabel:setPosition(bgSize.width/2, 80)
        nameBgSprite:addChild(nameLabel)
        buildBtn.nameBgSprite = nameBgSprite

        --锁标识
        local lockPic = ui.newSprite("jhs_107.png")
        lockPic:setPosition(75, 75)
        buildBtn:addChild(lockPic, -1)
        buildBtn.lockPic = lockPic

        --保护时间Node
        local protectNode = cc.Node:create()
        protectNode:setPosition(0,0)
        buildBtn:addChild(protectNode)
        buildBtn.protectNode = protectNode

        local protectLabel = ui.newLabel({
            text = TR("保护中：00：00"),
            outlineColor = Enums.Color.eOutlineColor,
            color = Enums.Color.eRed,
            size = 18,
            })
        protectLabel:setPosition(80, 150)
        protectNode:addChild(protectLabel)
        protectNode.protectLabel = protectLabel
        --保护中特效
        local protectEff = ui.newEffect({
            parent = protectLabel,
            effectName = "effect_ui_baohuzhong",
            position = cc.p(75, -70),
            loop = true,
        })


        --交叉刀特效    
        if v.ID ~= 31 and v.ID ~= 1 then
            local fightEff = ui.newEffect({
                    parent = buildBtn,
                    effectName = "effect_ui_jiaochadao",
                    position = cc.p(90, 100),
                    scale = 0.7,
                    loop = true,
                })
            buildBtn.fightEff = fightEff
        end

        table.insert(self.mCityList, buildBtn)
	end
end

--创建地图
function JianghuKillMapLayer:createMap()
	-- 创建可拖动背景
    local worldView = ccui.ScrollView:create()
    worldView:setContentSize(cc.size(640, 1136))
    worldView:setPosition(cc.p(0,0))
    worldView:setDirection(ccui.ScrollViewDir.both)
    worldView:setSwallowTouches(false)
    -- worldView:setTouchEnabled(false)
    self.mParentLayer:addChild(worldView)
    self.mWorldView = worldView

    -- 创建背景
	local bgSprite = ui.newSprite("jhs_14.jpg")
	bgSprite:setAnchorPoint(0, 0)
	bgSprite:setPosition(0, 0)
    self.mWorldView:setInnerContainerSize(bgSprite:getContentSize())
    self.mWorldView:addChild(bgSprite, -2)
    self.mMapBg = bgSprite

    -- 创建玩家node
    local playerNode = cc.Node:create()
    playerNode:setAnchorPoint(cc.p(0.5, 0.5))
    playerNode:setContentSize(120, 180)
    self.mMapBg:addChild(playerNode, 10)

    local spineNode = cc.Node:create()
    -- spineNode:setAnchorPoint(cc.p(0.5, 0.5))
    spineNode:setContentSize(120, 180)
    playerNode:addChild(spineNode, 10)

    --正面形象
    -- local playerModelId = FormationObj:getSlotInfoBySlotId(1).ModelId
    -- HeroQimageRelation.items[playerModelId].positivePic
    local positivePic, backPic = QFashionObj:getQFashionByDressType()
    upSpine = ui.newEffect({
        parent = spineNode,
        anchorPoint = cc.p(0.5, 0.5),
        effectName = positivePic,
        position = cc.p(playerNode:getContentSize().width / 2, playerNode:getContentSize().height / 2 - 50),
        loop = true,
        endRelease = true,
        scale = 0.6
    })
    upSpine:setAnimation(0, "daiji", true)
   
    --背面形象
    downSpine = ui.newEffect({
        parent = spineNode,
        anchorPoint = cc.p(0.5, 0.5),
        effectName = backPic,
        position = cc.p(playerNode:getContentSize().width / 2, playerNode:getContentSize().height / 2 - 50),
        loop = true,
        endRelease = true,
        scale = 0.6
    })
    downSpine:setVisible(false)

    local macheNode = cc.Node:create()
    -- macheNode:setAnchorPoint(cc.p(0.5, 0.5))
    macheNode:setContentSize(120, 180)
    playerNode:addChild(macheNode, 10)

     --马车正面
    upMache = ui.newEffect({
        parent = macheNode,
        anchorPoint = cc.p(0.5, 0.5),
        effectName = "hero_mache_z",
        position = cc.p(playerNode:getContentSize().width / 2, playerNode:getContentSize().height / 2 - 50),
        loop = true,
        endRelease = true,
        scale = 0.5
    })
    upMache:setAnimation(0, "daiji", true)

    --马车背面
    downMache = ui.newEffect({
        parent = macheNode,
        anchorPoint = cc.p(0.5, 0.5),
        effectName = "hero_mache_b",
        position = cc.p(playerNode:getContentSize().width / 2, playerNode:getContentSize().height / 2 - 50),
        loop = true,
        endRelease = true,
        scale = 0.5
    })
    downMache:setVisible(false)

    --驻守特效
    occupyEff = ui.newEffect({
        parent = playerNode,
        anchorPoint = cc.p(0.5, 0.5),
        effectName = "effect_ui_zhushouzhong",
        position = cc.p(playerNode:getContentSize().width / 2, playerNode:getContentSize().height / 2 - 50),
        loop = true,
        endRelease = true,
    })
    occupyEff:setVisible(false)

    playerNode.upSpine = upSpine --正面
    playerNode.downSpine = downSpine --背面
    playerNode.changeTag = false --切换动作标识符
    playerNode.spineNode = spineNode --人物控制显示的节点

    playerNode.upMache = upMache   --马车正面
    playerNode.downMache = downMache --马车背面
    playerNode.macheNode = macheNode --马车控制显示的节点
    playerNode.occupyEff = occupyEff --驻守特效

    self.mPlayerNode = playerNode

    self:createBuildingBtns() --创建建筑按钮
end

--注册事件
function JianghuKillMapLayer:registerEvent()
    local tempEventNode = cc.Node:create()
    self.mParentLayer:addChild(tempEventNode)
    --移动开始
    Notification:registerAutoObserver(tempEventNode, function(node, data)
        -- dump(data, "moveinfo")
        self:moveAction(self.mCurNodeId, data.TarNodeId, data.Countdown)
        if self.mCityView then
            self.mCityView:removeFromParent()
            self.mCityView = nil
        end
    end, EventsName.eBeginMove)

    local tempEventNode = cc.Node:create()
    self.mParentLayer:addChild(tempEventNode)
    --移动结束
    Notification:registerAutoObserver(tempEventNode, function(node, data)
        self.mCurNodeId = data.NodeId
        self.mStatus = Enums.JHKPlayerStatus.eNormal
        self.mPlayerNode:stopAllActions()
        self:scorllToItem(data.NodeId)
        self:requestGetNodeInfo(self.mCurNodeId)
        self:refreshInfo()

        self.mPlayerNode.downSpine:setToSetupPose()
        self.mPlayerNode.upSpine:setToSetupPose()
        self.mPlayerNode.downSpine:setAnimation(0, "daiji", true)
        self.mPlayerNode.upSpine:setAnimation(0, "daiji", true)
        self.mPlayerNode.downMache:setAnimation(0, "daiji", true)
        self.mPlayerNode.upMache:setAnimation(0, "daiji", true)

        self.mTeamBtn:setVisible(true)
    end, EventsName.eArriveNode)

    local tempEventNode = cc.Node:create()
    self.mParentLayer:addChild(tempEventNode)
    --节点状态变化
    Notification:registerAutoObserver(tempEventNode, function(node, data)
        if not self.mMapInfo or next(self.mMapInfo) == nil then
            return
        end
        self.mMapInfo[data.NodeId].ProtectTime = data.ProtectTime
        self:refreshNodeInfo(data)
    end, EventsName.eNodeStatusChange)

    --节点内占领信息变化
    local tempEventNode = cc.Node:create()
    self.mParentLayer:addChild(tempEventNode)
    Notification:registerAutoObserver(tempEventNode, function(node, data)
        --当玩家自己死亡时刷新界面
        if data.TargetPlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then
            if data.TargetPlayerSpritNum <= 0 then
                self:requestGetInfoTeamHall(true)
            end
        end    
    end, EventsName.eAttackInfo)

    --加入队伍通知（自己加入）
    local tempEventNode = cc.Node:create()
    self.mParentLayer:addChild(tempEventNode)
    Notification:registerAutoObserver(tempEventNode, function(node, data)
        if data.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then 
            self.mJianghuKillInfo.IfInTeam = true
            self:ifNeedMache()
        end
    end, EventsName.eAddTeam)

    --加入队伍通知(队长批准)
    local tempEventNode = cc.Node:create()
    self.mParentLayer:addChild(tempEventNode)
    Notification:registerAutoObserver(tempEventNode, function(node, data)
        if data.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then 
            self.mJianghuKillInfo.IfInTeam = true
            self:ifNeedMache()
        end
    end, EventsName.eAgreeAddTeam)

    --退出队伍通知
    local tempEventNode = cc.Node:create()
    self.mParentLayer:addChild(tempEventNode)
    Notification:registerAutoObserver(tempEventNode, function(node, data)
        if data.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then 
            self.mJianghuKillInfo.IfInTeam = false
            self:ifNeedMache()
        end
    end, EventsName.eQuitTeam)

    --解散队伍通知
    local tempEventNode = cc.Node:create()
    self.mParentLayer:addChild(tempEventNode)
    Notification:registerAutoObserver(tempEventNode, function(node, data)
        self.mJianghuKillInfo.IfInTeam = false
        self:ifNeedMache()
    end, EventsName.eCancelTeam)

    --踢出队伍通知
    local tempEventNode = cc.Node:create()
    self.mParentLayer:addChild(tempEventNode)
    Notification:registerAutoObserver(tempEventNode, function(node, data)
        if data.DeleteMember == PlayerAttrObj:getPlayerAttrByName("PlayerId") then 
            self.mJianghuKillInfo.IfInTeam = false
            self:ifNeedMache()
        end
    end, EventsName.eDeleteMember)

    --创建队伍通知(前端事件)
    local tempEventNode = cc.Node:create()
    self.mParentLayer:addChild(tempEventNode)
    Notification:registerAutoObserver(tempEventNode, function(node, data)
        self.mJianghuKillInfo.IfInTeam = true
        self:ifNeedMache()
    end, EventsName.eCreateTeam)
end

--创建玩家功能信息
function JianghuKillMapLayer:createPlayerInfo()
    if self.mShowInfoCtrl then
        self.mShowInfoCtrl:removeFromParent()
        self.mShowInfoCtrl = nil
    end

    local showInfoCtrl = ui.newScale9Sprite("jhs_116.png", cc.size(280, 150))
    showInfoCtrl:setAnchorPoint(0, 0.5)
    showInfoCtrl:setPosition(0, 820)
    self.mRefreshLayer:addChild(showInfoCtrl)
    self.mShowInfoCtrl = showInfoCtrl

    self.mIsHideInfo = Player:getGameData("IsHideInfo")

    local hideInfoBtn = ui.newButton({
        normalImage = "jhs_117.png",
        textWidth = 20,
        fontSize = 20,
        text = TR("点击隐藏"),
        clickAction = function(pSender)
            self.mIsHideInfo = not self.mIsHideInfo
            Player:saveGameData("IsHideInfo", self.mIsHideInfo)
            showInfoCtrl:setPositionX(self.mIsHideInfo and -280 or 0)
            pSender:setTitleText(self.mIsHideInfo and TR("点击展开") or TR("点击隐藏"))
        end
    })
    hideInfoBtn:setPosition(300, 88)
    showInfoCtrl:addChild(hideInfoBtn)
    if self.mIsHideInfo == true then
        showInfoCtrl:setPositionX(self.mIsHideInfo and -280 or 0)
        hideInfoBtn:setTitleText(self.mIsHideInfo and TR("点击展开") or TR("点击隐藏"))
    end

	local spritLabel = ui.newLabel({
    	text = TR("精神：%s/%s", 0, 10),
    	size = 22,
    	color = Enums.Color.eNormalWhite,
    	outlineColor = Enums.Color.eOutlineColor,
    	})
    spritLabel:setAnchorPoint(0, 0.5)
    spritLabel:setPosition(15, 120)
    showInfoCtrl:addChild(spritLabel)
    self.mSpritLabel = spritLabel

    local powerLabel = ui.newLabel({
    	text = TR("功力：%s/%s", 0, 10),
    	size = 22,
    	color = Enums.Color.eNormalWhite,
    	outlineColor = Enums.Color.eOutlineColor,
    	})
    powerLabel:setAnchorPoint(0, 0.5)
    powerLabel:setPosition(15, 90)
    showInfoCtrl:addChild(powerLabel)
    self.mPowerLabel = powerLabel

    local forageLabel = ui.newLabel({
    	text = TR("粮草：%s/%s", 0, 300),
    	size = 22,
    	color = Enums.Color.eNormalWhite,
    	outlineColor = Enums.Color.eOutlineColor,
    	})
    forageLabel:setAnchorPoint(0, 0.5)
    forageLabel:setPosition(15, 60)
    showInfoCtrl:addChild(forageLabel)
    self.mForageLabel = forageLabel

    local collectionLabel = ui.newLabel({
    	text = TR("悟性：%s/%s", 0, 10),
    	size = 22,
    	color = Enums.Color.eNormalWhite,
    	outlineColor = Enums.Color.eOutlineColor,
    	})
    collectionLabel:setAnchorPoint(0, 0.5)
    collectionLabel:setPosition(15, 30)
    showInfoCtrl:addChild(collectionLabel)
    self.mCollectionLabel = collectionLabel

    -- 创建购买属性按钮
    local function createBuyAttrBtn(attrType, singleNum, attrName, attrField, maxValue)
        --购买按钮
        local teamBtn = ui.newButton({
            normalImage = "c_21.png",
            clickAction = function()
                if self.mOldBuyTimes >= VipModel.items[PlayerAttrObj:getPlayerAttrByName("Vip")].jianghukillBuyNum then
                    ui.showFlashView(TR("今日购买次数已达上限"))
                    return
                end

                local curAttrValue = self.mPlayerHandleData[attrField]
                if (curAttrValue >= maxValue) or (singleNum+curAttrValue > maxValue) then
                    ui.showFlashView(TR("不能超过上限"))
                    return
                end
                local maxCount = math.floor((maxValue - curAttrValue)/singleNum)
                local maxCount1 = VipModel.items[PlayerAttrObj:getPlayerAttrByName("Vip")].jianghukillBuyNum - self.mOldBuyTimes
                if maxCount1 > 0 then
                    maxCount = maxCount < maxCount1 and maxCount or maxCount1
                end
                MsgBoxLayer.buyJHSCountHintLayer(self.mOldBuyTimes, maxCount, singleNum, attrName, function (buyCount)
                    self:requestBuy(attrType, buyCount, singleNum)
                end)
            end
            })
        teamBtn:setAnchorPoint(cc.p(0, 0.5))
        teamBtn:setScale(0.8)
        showInfoCtrl:addChild(teamBtn)

        return teamBtn
    end
    local jobInfo = JianghukillOccupationalprope.items[self.mJobId][self.mJianghuKillInfo.ProfessionLv]
    -- 粮草购买按钮
    self.mForageBtn = createBuyAttrBtn(1, JianghukillModel.items[1].buyFoodNum, TR("粮草"), "ForageNum", jobInfo.foodLimit)
    -- 精神购买按钮
    self.mSpritBtn = createBuyAttrBtn(2, JianghukillModel.items[1].buySpriteNum, TR("精神"), "SpritNum", jobInfo.spriteLimit)
    -- 功力购买按钮
    self.mPowerBtn = createBuyAttrBtn(3, JianghukillModel.items[1].buyPowerNum, TR("功力"), "PowerNum", jobInfo.powerLimit)
    -- 悟性购买按钮
    self.mCollectionBtn = createBuyAttrBtn(4, JianghukillModel.items[1].buyWuXingNum, TR("悟性"), "CollectionNum", jobInfo.wuXing)
end

--城池信息弹窗
function JianghuKillMapLayer:createCityInfoView(cityId, info)
    if self.mCityView then
        self.mCityView:removeFromParent()
        self.mCityView = nil
    end

    local cityModelInfo = JianghukillMapModel.items[cityId]
    local jhsConfig = JianghukillModel.items[1]
    local belongForce = self.mMapInfo[cityId].CampId

    local pos = Utility.analysisPoints(cityModelInfo.coordinate)
    local tempNode = cc.Node:create()
    tempNode:setPosition(pos)
    self.mMapBg:addChild(tempNode, 11)
    self.mCityView = tempNode

    tempNode:setScale(0.1)
    tempNode:runAction(cc.ScaleTo:create(0.2, 1))

    --判断是否为出生点
    if cityModelInfo.isRebirthPoint then
        local homeID = self.mIsWLM and 31 or 1
        if homeID == cityId then
            local moveBtn = ui.newButton({
                normalImage = "jhs_118.png",
                -- text = TR("回城"),
                clickAction = function()
                    if self.mCurNodeId == homeID then
                        ui.showFlashView(TR("你已经在势力总部了"))
                        return
                    end
                    MsgBoxLayer.addOKLayer(
                        TR("是否确认回到势力总部？"), 
                        TR("回城"), 
                        {
                            {
                                normalImage = "c_28.png",
                                text = TR("确定"),
                                clickAction = function(layer)
                                    self:requestBackToHome()
                                    LayerManager.removeLayer(layer)
                                end,
                            },
                    },{})
                end
                })
            moveBtn:setPosition(60, -40)
            moveBtn:setScale(0.8)
            tempNode:addChild(moveBtn)
        end
    else
        --驻守信息展示
        local belongInfo = ui.newScale9Sprite("jhs_01.png")
        belongInfo:setPosition(100, 70)
        tempNode:addChild(belongInfo)

        local belongLabel = ui.newLabel({
            text = TR("所属：%s", Enums.JHKCampName[belongForce]),
            size = 20,
            })
        belongLabel:setPosition(80, 70)
        belongInfo:addChild(belongLabel)

        local defineLabel = ui.newLabel({
            text = TR("驻守人数：%s/%s", info.OccupyNum, jhsConfig.residentNum*2),
            size = 18,
            })
        defineLabel:setPosition(10, 40)
        defineLabel:setAnchorPoint(0, 0.5)
        belongInfo:addChild(defineLabel)

        local readyLabel = ui.newLabel({
            text = TR("预备驻守：%s/%s", info.PrepareNum, jhsConfig.preResidentNum),
            size = 18,
            })
        readyLabel:setPosition(10, 20)
        readyLabel:setAnchorPoint(0, 0.5)
        belongInfo:addChild(readyLabel)

        --产出展示部分
        local outPutInfo = ui.newScale9Sprite("jhs_02.png")
        outPutInfo:setPosition(100, -20)
        tempNode:addChild(outPutInfo)

        local outputLabel = ui.newLabel({
            text = TR("天机残页：{jhs_124.png}%.1f/%s", info.ResNum < 0 and 0 or info.ResNum, cityModelInfo.resoucePointLimit),
            size = 18,
            outlineColor = Enums.Color.eOutlineColor,
            })
        outputLabel:setPosition(15, 55)
        outputLabel:setAnchorPoint(0, 0.5)
        outPutInfo:addChild(outputLabel)

        local outputLabel = ui.newLabel({
            text = TR("产出速度：{jhs_124.png}%s页/%s秒", info.ResRate*1, info.ResTime),
            size = 18,
            outlineColor = Enums.Color.eOutlineColor,
            })
        outputLabel:setPosition(15, 25)
        outputLabel:setAnchorPoint(0, 0.5)
        outPutInfo:addChild(outputLabel)

        --是否需要显示移动按钮
        local canMove = self:canMove(cityId)

        if canMove then
            local btnPic = belongForce == self.mCampId and "jhs_126.png" or "jhs_125.png"
            local moveBtn = ui.newButton({
                normalImage = btnPic,
                -- text = TR("移动"),
                clickAction = function()
                    if self.mJianghuKillState == Enums.JHKOpenStatus.eRest then
                        ui.showFlashView(TR("休息时间，不能行动"))
                        return
                    end
                    if self.mStatus == Enums.JHKPlayerStatus.eMoving then
                        ui.showFlashView(TR("已经在路上了，请稍等片刻"))
                        return
                    elseif self.mStatus == Enums.JHKPlayerStatus.eOccupy then
                        MsgBoxLayer.addOKLayer(
                            TR("当前正在驻守中，是否离开驻守？"), 
                            TR("移动"), 
                            {
                                {
                                    normalImage = "c_28.png",
                                    text = TR("确定"),
                                    clickAction = function(layer)
                                        self:requestCancelOccupy(cityId)
                                        LayerManager.removeLayer(layer)
                                    end,
                                },
                        },{})
                    else
                        if self.mMapInfo[self.mCurNodeId].CampId == self.mCampId then
                            self:requestMove(cityId)
                        else
                            if self.mMapInfo[cityId].CampId == self.mCampId then
                                self:requestMove(cityId)
                            else
                                ui.showFlashView(TR("不能从敌方门派前往其他敌方门派"))
                            end
                        end
                    end
                end
                })
            moveBtn:setPosition(100, -85)
            -- moveBtn:setScale(0.8)
            tempNode:addChild(moveBtn)
        else
            local lockTipLabel = ui.createLabelWithBg({
                bgFilename = "jhs_130.png",
                bgSize = cc.size(230, 45),
                labelStr = TR("非相邻门派不能前往"),
                fontSize = 22,
                offset = 20,
                offsetY = -4,
                color = Enums.Color.eRed,
            })
            lockTipLabel:setPosition(100, -80)  
            tempNode:addChild(lockTipLabel)

            local lockTipSprite = ui.newSprite("jhs_107.png")
            lockTipSprite:setPosition(-5, 22)
            lockTipLabel:addChild(lockTipSprite)

            tempNode.lockTipLabel = lockTipLabel
        end
    end

    if self.mCurNodeId == cityId then
        if not cityModelInfo.isRebirthPoint and self.mStatus ~= Enums.JHKPlayerStatus.eMoving then
            local moveBtn = ui.newButton({
                normalImage = "c_28.png",
                text = TR("进入"),
                clickAction = function()
                    if self.mJianghuKillState == Enums.JHKOpenStatus.eRest then
                        ui.showFlashView(TR("休息时间，不能行动"))
                        return
                    end
                    LayerManager.addLayer({
                        name = "jianghuKill.JianghuKillCityLayer",
                        data = {
                            nodeModelInfo = cityModelInfo,
                            occupyInfo = info, 
                            campId = self.mMapInfo[cityId].CampId,
                            playerInfo = self.mJianghuKillInfo,
                            refreshData = self.mPlayerHandleData,
                            buyTimes = self.mOldBuyTimes,
                            endTime = self.mEndTime,
                        },
                        cleanUp = true,
                    })
                end
                })
            moveBtn:setPosition(100, -85)
            moveBtn:setScale(0.8)
            tempNode:addChild(moveBtn)
            tempNode.lockTipLabel:setVisible(false)
        end
    end

    self.mShowingId = cityId
end

--刷新职业等级显示
function JianghuKillMapLayer:refreshJobShow()
    local campStr = self.mCampId == 1 and TR("武林盟员") or TR("浑天教徒")
    local campPic = self.mCampId == 1 and "jhs_112.png" or "jhs_113.png"
    local jobPic = {
        [1] = "jhs_32.png",
        [2] = "jhs_30.png",
        [3] = "jhs_33.png",
        [4] = "jhs_31.png",
    }
    --刷新阵营和职业等级
    self.mCampLvLabel:setString(TR("%s%s级", campStr, self.mJianghuKillInfo.CampLv))
    self.mJobLvLabel:setString(TR("%s%s级", JianghukillJobModel.items[self.mJobId].name, self.mJianghuKillInfo.ProfessionLv))
    self.mCampTipPic:setTexture(campPic)
    self.mJobTipPic:setTexture(jobPic[self.mJobId])
end

--刷新界面
function JianghuKillMapLayer:refreshInfo()
    self:refreshJobShow()
    
    --刷新进度条及标识
    self:refreshDataByAuto()

    --刷新城池状态
    local fightNodeList = self:selectFightNode()    

    for i,v in ipairs(self.mCityList) do
        local nodeInfo = self.mMapInfo[i]
        if nodeInfo.CampId == 1 then
            v.nameBgSprite:setTexture("jhs_59.png")
        elseif nodeInfo.CampId == 2 then
            v.nameBgSprite:setTexture("jhs_58.png")
        else    
            v.nameBgSprite:setTexture("jhs_57.png")
        end
        --出生点特殊显示
        if i == 1 then
            v.nameBgSprite:setTexture("jhs_139.png")
        end
        if i == 31 then
            v.nameBgSprite:setTexture("jhs_138.png")
        end
        local canMove = self:canMove(i)
        v.lockPic:setVisible(not canMove)
        if i == self.mCurNodeId then
            v.lockPic:setVisible(false)
        end
        if fightNodeList[i] then
            if nodeInfo.ProtectTime > 0 then
                v.fightEff:setVisible(false)
            else
                v.fightEff:setVisible(true)
            end
        else
            if v.fightEff then
                v.fightEff:setVisible(false)
            end
        end
    end

    --驻守状态判断显示
    self.mPlayerNode.occupyEff:setVisible(self.mStatus == Enums.JHKPlayerStatus.eOccupy)
    self.mPlayerNode.macheNode:setVisible(self.mStatus ~= Enums.JHKPlayerStatus.eOccupy)
    self.mPlayerNode.spineNode:setVisible(self.mStatus ~= Enums.JHKPlayerStatus.eOccupy)
    self:ifNeedMache()
end

--刷新节点状态
function JianghuKillMapLayer:refreshNodeInfo(info)
    self.mMapInfo[info.NodeId].CampId = info.CampId
    if info.CampId == 1 then
        self.mCityList[info.NodeId].nameBgSprite:setTexture("jhs_59.png")
    elseif info.CampId == 2 then
        self.mCityList[info.NodeId].nameBgSprite:setTexture("jhs_58.png")
    else    
        self.mCityList[info.NodeId].nameBgSprite:setTexture("jhs_57.png")
    end
end

--比分变化
function JianghuKillMapLayer:refreshDataByAuto()
    local selfInfo = self.mIsWLM and self.mCampInfo["1"] or self.mCampInfo["2"]
    local enemyInfo = self.mIsWLM and self.mCampInfo["2"] or self.mCampInfo["1"]
    self.mScoreLabelSelf:setString(string.format("{%s}%s", "jhs_124.png", selfInfo.ResourceNum))
    self.mScoreLabelEnemy:setString(string.format("{%s}%s", "jhs_124.png", enemyInfo.ResourceNum))
    if selfInfo.ResourceNum == 0 and enemyInfo.ResourceNum == 0 then
        self.mScoreBar:setMaxValue(100)
        self.mScoreBar:setCurrValue(50)
        self.mHigherNode:setVisible(false)
    else
        local totalScore = selfInfo.ResourceNum + enemyInfo.ResourceNum
        self.mScoreBar:setMaxValue(totalScore)
        self.mScoreBar:setCurrValue(selfInfo.ResourceNum)
        local barSize = self.mScoreBar:getContentSize()
        local posX = (selfInfo.ResourceNum/totalScore) * barSize.width
        self.mBarTipSprite:setPositionX(posX)
        self.mHigherNode:setVisible(true)

        if selfInfo.ResourceNum > enemyInfo.ResourceNum then
            self.mHigherNode:setPositionX(240)
            self.mBuffTag = true
        else
            self.mHigherNode:setPositionX(400)
            self.mBuffTag = false
        end
    end
end

--判断点位是否可以移动
function JianghuKillMapLayer:canMove(targetId)
    local curCanMoveList = JianghukillMapModel.items[self.mCurNodeId].canMoveIDStr
    local tempList = string.splitBySep(curCanMoveList, ",")
    for i,v in ipairs(tempList) do
        if targetId == tonumber(v) then
            return true
        end
    end
    local homeID = self.mIsWLM and 31 or 1
    if targetId == homeID then
        return true
    end
    return false
end

--执行移动动作
function JianghuKillMapLayer:moveAction(nodeIdA, nodeIdB, endTime)
    --驻守状态判断显示
    self.mPlayerNode.occupyEff:setVisible(self.mStatus == Enums.JHKPlayerStatus.eOccupy)
    self.mPlayerNode.macheNode:setVisible(self.mStatus ~= Enums.JHKPlayerStatus.eOccupy)
    self.mPlayerNode.spineNode:setVisible(self.mStatus ~= Enums.JHKPlayerStatus.eOccupy)

    self:ifNeedMache()

    local startPos = Utility.analysisPoints(JianghukillMapModel.items[nodeIdA].coordinate)
    local endPos = Utility.analysisPoints(JianghukillMapModel.items[nodeIdB].coordinate)

    local isUp = (startPos.y - endPos.y) > 0 
    local isLeft = (startPos.x - endPos.x) > 0
    self.mPlayerNode.downSpine:setToSetupPose()
    self.mPlayerNode.upSpine:setToSetupPose()

    if isUp then
        self.mPlayerNode.downSpine:setVisible(false)
        self.mPlayerNode.upSpine:setVisible(true)
        self.mPlayerNode.downMache:setVisible(false)
        self.mPlayerNode.upMache:setVisible(true)
    else
        self.mPlayerNode.downSpine:setVisible(true)
        self.mPlayerNode.upSpine:setVisible(false)
        self.mPlayerNode.downMache:setVisible(true)
        self.mPlayerNode.upMache:setVisible(false)
    end
    self.mPlayerNode.downSpine:setAnimation(0, "zou", true)
    self.mPlayerNode.upSpine:setAnimation(0, "zou", true)
    self.mPlayerNode.downMache:setAnimation(0, "zou", true)
    self.mPlayerNode.upMache:setAnimation(0, "zou", true)

    if isLeft then
        --角色转向
        self.mPlayerNode.upSpine:setRotationSkewY(180)
        self.mPlayerNode.downSpine:setRotationSkewY(180)
        self.mPlayerNode.upMache:setRotationSkewY(0)
        self.mPlayerNode.downMache:setRotationSkewY(180)

    else
        self.mPlayerNode.upSpine:setRotationSkewY(0)
        self.mPlayerNode.downSpine:setRotationSkewY(0)
        self.mPlayerNode.upMache:setRotationSkewY(180)
        self.mPlayerNode.downMache:setRotationSkewY(0)
    end

    -- self.mPlayerNode:setPosition(startPos)

    local move = cc.MoveTo:create(endTime, endPos)
    local moveEnd = cc.CallFunc:create(function()
        self.mPlayerNode.downSpine:setVisible(false)
        self.mPlayerNode.upSpine:setVisible(true)
    end)
    local sq = cc.Sequence:create(move, moveEnd)

    self.mPlayerNode:runAction(sq)
    self.mTeamBtn:setVisible(false)
end

--处理个人信息更新的数据
function JianghuKillMapLayer:handlePlayerData(data, needTimeInit)
    self.mPlayerHandleData.PowerNum = data.PowerNum or 0
    self.mPlayerHandleData.SpritNum = data.SpritNum or 0
    self.mPlayerHandleData.CollectionNum = data.CollectionNum or 0
    self.mPlayerHandleData.ForageNum = data.ForageNum or 0
    self.mPlayerHandleData.CurResNum = data.CurResNum or 0
    if needTimeInit then
        self.mPlayerHandleData.NextSpritTime = data.NextSpritTime or 0
        self.mPlayerHandleData.NextCollectionTime = data.NextCollectionTime or 0
        self.mPlayerHandleData.NextForageTime = data.NextForageTime or 0
        self.mPlayerHandleData.NextPowerTime = data.NextPowerTime or 0
    end
end

--倒计时刷新函数
function JianghuKillMapLayer:UpdateTimeSch()
    self.mRefreshTime = self.mRefreshTime + 1 
    if self.mRefreshTime > 10 then
        self.mRefreshTime = 1
        self:requestGetRefreshData()
    end

    local jobInfo = JianghukillOccupationalprope.items[self.mJobId][self.mJianghuKillInfo.ProfessionLv]
    local isSpriteLess = jobInfo.spriteLimit > self.mPlayerHandleData.SpritNum
    local isPowerLess = jobInfo.powerLimit > self.mPlayerHandleData.PowerNum
    local isForageLess = jobInfo.foodLimit > self.mPlayerHandleData.ForageNum
    local isCollectionLess = jobInfo.wuXing > self.mPlayerHandleData.CollectionNum

    --配置的恢复时间
    local spriteAddTime = jobInfo.spriteRecover
    local powerAddTime = jobInfo.powerRecover
    local forageAddTime = jobInfo.foodRecover
    local collectionAddTime = jobInfo.wuXingTimeRecover

    --精神倒计时
    if isSpriteLess then
        if self.mPlayerHandleData.NextSpritTime < 0 then
            self.mPlayerHandleData.NextSpritTime = spriteAddTime
            self.mPlayerHandleData.SpritNum = self.mPlayerHandleData.SpritNum + 1 
        end
        self.mPlayerHandleData.NextSpritTime = self.mPlayerHandleData.NextSpritTime - 1

        self.mSpritLabel:setString(TR("精神：%s/%s #ffcc00(%s)", self.mPlayerHandleData.SpritNum, jobInfo.spriteLimit, MqTime.formatAsHour(self.mPlayerHandleData.NextSpritTime, {hour = false})))
    else
        self.mSpritLabel:setString(TR("精神：%s/%s", self.mPlayerHandleData.SpritNum, jobInfo.spriteLimit))
    end
    --功力倒计时
    if isPowerLess then
        if self.mPlayerHandleData.NextPowerTime < 0 then
            self.mPlayerHandleData.NextPowerTime = powerAddTime
            self.mPlayerHandleData.PowerNum = self.mPlayerHandleData.PowerNum + 1 
        end
        self.mPlayerHandleData.NextPowerTime = self.mPlayerHandleData.NextPowerTime - 1

        self.mPowerLabel:setString(TR("功力：%s/%s #ffcc00(%s)", self.mPlayerHandleData.PowerNum, jobInfo.powerLimit, MqTime.formatAsHour(self.mPlayerHandleData.NextPowerTime, {hour = false})))
    else
        self.mPowerLabel:setString(TR("功力：%s/%s", self.mPlayerHandleData.PowerNum, jobInfo.powerLimit))
    end
    --粮草倒计时
    if isForageLess then
        if self.mPlayerHandleData.NextForageTime < 0 then
            self.mPlayerHandleData.NextForageTime = forageAddTime
            self.mPlayerHandleData.ForageNum = self.mPlayerHandleData.ForageNum + 1 
        end
        self.mPlayerHandleData.NextForageTime = self.mPlayerHandleData.NextForageTime - 1

        self.mForageLabel:setString(TR("粮草：%s/%s #ffcc00(%s)", self.mPlayerHandleData.ForageNum, jobInfo.foodLimit, MqTime.formatAsHour(self.mPlayerHandleData.NextForageTime, {hour = false})))
    else
        self.mForageLabel:setString(TR("粮草：%s/%s", self.mPlayerHandleData.ForageNum, jobInfo.foodLimit))
    end
    --悟性倒计时
    if isCollectionLess then
        if self.mPlayerHandleData.NextCollectionTime < 0 then
            self.mPlayerHandleData.NextCollectionTime = collectionAddTime
            self.mPlayerHandleData.CollectionNum = self.mPlayerHandleData.CollectionNum + 1 
        end
        self.mPlayerHandleData.NextCollectionTime = self.mPlayerHandleData.NextCollectionTime - 1

        self.mCollectionLabel:setString(TR("悟性：%s/%s#ffcc00(%s)", self.mPlayerHandleData.CollectionNum, jobInfo.wuXing, MqTime.formatAsHour(self.mPlayerHandleData.NextCollectionTime, {hour = false})))
    else
        self.mCollectionLabel:setString(TR("悟性：%s/%s", self.mPlayerHandleData.CollectionNum, jobInfo.wuXing))
    end

    --显示保护中倒计时
    for i,v in ipairs(self.mMapInfo) do
        v.ProtectTime = v.ProtectTime - 1
        local tempBtn = self.mCityList[i]
        if v.ProtectTime > 0 then
            tempBtn.protectNode.protectLabel:setString(TR("保护中：%s",MqTime.formatAsHour(v.ProtectTime)))
            tempBtn.protectNode:setVisible(true)
        else
            tempBtn.protectNode:setVisible(false)
        end
    end

    -- 刷新购买按钮位置
    local x, y = self.mForageLabel:getPosition()
    self.mForageBtn:setPosition(self.mForageLabel:getContentSize().width+20, y)
    local x, y = self.mSpritLabel:getPosition()
    self.mSpritBtn:setPosition(self.mSpritLabel:getContentSize().width+20, y)
    local x, y = self.mPowerLabel:getPosition()
    self.mPowerBtn:setPosition(self.mPowerLabel:getContentSize().width+20, y)
    local x, y = self.mCollectionLabel:getPosition()
    self.mCollectionBtn:setPosition(self.mCollectionLabel:getContentSize().width+20, y)

    local seasonTimeLeft = self.mEndTime - Player:getCurrentTime()
    if seasonTimeLeft <= 0 then
        ui.showFlashView(TR("本赛季结束"))
        LayerManager.removeLayer(self)
    end

end

--持续移动中再进入时恢复移动的效果
function JianghuKillMapLayer:continueMove(starId, targetId, moveTime, moveCoutdown)
    local startPos = Utility.analysisPoints(JianghukillMapModel.items[starId].coordinate)
    local endPos = Utility.analysisPoints(JianghukillMapModel.items[targetId].coordinate)


    local isUp = (startPos.y - endPos.y) > 0 
    local isLeft = (startPos.x - endPos.x) > 0
    local middlePosX = 0
    local middlePosY = 0
    local passedOff = 1-moveCoutdown/moveTime

     if isUp then
        self.mPlayerNode.downSpine:setVisible(false)
        self.mPlayerNode.upSpine:setVisible(true)
        self.mPlayerNode.downMache:setVisible(false)
        self.mPlayerNode.upMache:setVisible(true)

        self.mPlayerNode.upSpine:setAnimation(0, "zou", true)

        middlePosY = startPos.y + (endPos.y - startPos.y) * passedOff
    else
        self.mPlayerNode.downSpine:setVisible(true)
        self.mPlayerNode.upSpine:setVisible(false)
        self.mPlayerNode.downMache:setVisible(true)
        self.mPlayerNode.upMache:setVisible(false)
        self.mPlayerNode.downSpine:setAnimation(0, "zou", true)

        middlePosY = startPos.y - (startPos.y - endPos.y) * passedOff
    end

    if isLeft then
        --角色转向
        self.mPlayerNode.upSpine:setRotationSkewY(180)
        self.mPlayerNode.downSpine:setRotationSkewY(180)
        self.mPlayerNode.upMache:setRotationSkewY(0)
        self.mPlayerNode.downMache:setRotationSkewY(180)
        middlePosX = startPos.x - (startPos.x - endPos.x) * passedOff
    else
        self.mPlayerNode.upSpine:setRotationSkewY(0)
        self.mPlayerNode.downSpine:setRotationSkewY(0)
        self.mPlayerNode.upMache:setRotationSkewY(180)
        self.mPlayerNode.downMache:setRotationSkewY(0)
        middlePosX = startPos.x + (endPos.x - startPos.x) * passedOff
    end

    self.mPlayerNode:setPosition(cc.p(middlePosX, middlePosY))

    local move = cc.MoveTo:create(moveCoutdown, endPos)
    local moveEnd = cc.CallFunc:create(function()
        self.mPlayerNode.downSpine:setVisible(false)
        self.mPlayerNode.upSpine:setVisible(true)
        self.mPlayerNode.downMache:setVisible(false)
        self.mPlayerNode.upMache:setVisible(true)
    end)
    local sq = cc.Sequence:create(move, moveEnd)

    self.mPlayerNode:runAction(sq)
end

--筛选需要显示交叉刀的节点
function JianghuKillMapLayer:selectFightNode()
    local fightList = {}
    local myNodeList = {}

    for i,v in ipairs(self.mMapInfo) do
        if v.CampId == self.mCampId then
            table.insert(myNodeList, v)
        end
        fightList[i] = false
    end

    for i,v in ipairs(myNodeList) do
        local curCanMoveList = JianghukillMapModel.items[v.NodeId].canMoveIDStr
        local tempList = string.splitBySep(curCanMoveList, ",")
        for _, id in ipairs(tempList) do
            fightList[tonumber(id)] = true
        end
    end

    for i,v in ipairs(myNodeList) do
        fightList[v.NodeId] = false
    end
    fightList[1] = false
    fightList[31] = false

    return fightList
end

--是否需要显示马车特效
function JianghuKillMapLayer:ifNeedMache()
    self.mPlayerNode.spineNode:setVisible(not self.mJianghuKillInfo.IfInTeam)
    self.mPlayerNode.macheNode:setVisible(self.mJianghuKillInfo.IfInTeam)
    if self.mStatus == Enums.JHKPlayerStatus.eOccupy then
        self.mPlayerNode.spineNode:setVisible(false)
        self.mPlayerNode.macheNode:setVisible(false)
    end
end

--========================================网络请求===============================================
--选择势力
function JianghuKillMapLayer:requestChooseForce()
    HttpClient:request({
        moduleName = "Jianghukill",
        methodName = "ChooseForce",
        svrMethodData = {1},
        callbackNode = self,
        callback = function(response)
            -- 容错处理
            if response.Status ~= 0 then
                return
            end
            -- dump(response, "势力")
        end
    })
end

--选择职业
function JianghuKillMapLayer:requestChooseJob()
    HttpClient:request({
        moduleName = "Jianghukill",
        methodName = "ChooseJob",
        svrMethodData = {1},
        callbackNode = self,
        callback = function(response)
            -- 容错处理
            if response.Status ~= 0 then
                return
            end
            -- dump(response, "职业")
           
        end
    })
end

--判断是否需要弹选择界面
function JianghuKillMapLayer:onEnter()
    local forceId = PlayerAttrObj:getPlayerAttrByName("JianghuKillForceId")
    local jobId = PlayerAttrObj:getPlayerAttrByName("JianghuKillJobId")
    if forceId == 0 then
        Utility.performWithDelay(self, function()
            LayerManager.addLayer({
                name = "jianghuKill.JianghuKillSelectForceLayer", 
                data = {isRecomReward = true},
                cleanUp = true,
            })
        end, 0.01) --延时保证mapLayer先创建完成
    elseif jobId == 0 then
        LayerManager.addLayer({
            name = "jianghuKill.JianghuKillSeleJobLayer",
            data = {
                callback = handler(self, self.requestGetInfoTeamHall),
                isFirst = true,
            },
            cleanUp = false,
        })
    end    

    if forceId ~= 0 and jobId ~= 0 then
        self:requestGetInfoTeamHall()
    end
    self:registerEvent()      --注册事件
end

--获取信息
function JianghuKillMapLayer:requestGetInfoTeamHall(needNodeRef)
    HttpClient:request({
        moduleName = "JianghuKillTeamHall",
        methodName = "GetAllData",
        -- svrMethodData = {1},
        callbackNode = self,
        callback = function(response)
            -- dump(response.Value, "基本信息")
        
            -- 容错处理
            if response.Status ~= 0 then
                return
            end

            self.mJianghuKillState = response.Value.JianghuKillState
            
            -- 休战
            if self.mJianghuKillState == Enums.JHKOpenStatus.eClose then
                LayerManager.addLayer({name = "jianghuKill.JianghuKillEndLayer", data = {
                        forceId = response.Value.Data.PlayerData.CampId,
                        forceLv = response.Value.Data.PlayerData.CampLv,
                        jobId = response.Value.Data.PlayerData.Profession,
                        jobLv = response.Value.Data.PlayerData.ProfessionLv,
                        isCanReceive = not response.Value.Sign,
                        openTime = response.Value.JianghuKillNextOpenTime,
                    }})
                return
            end

            self.mMapInfo = response.Value.Data.MapData
            table.sort(self.mMapInfo, function (a, b)
                if a.NodeId ~= b.NodeId then
                    return a.NodeId < b.NodeId
                end
            end)
            self.mJianghuKillInfo = response.Value.Data.PlayerData
            self.mCampInfo = response.Value.Data.CampData

            --判断玩家势力武林盟为true 浑天教为false
            self.mIsWLM = self.mJianghuKillInfo.CampId == 1

            self.mCurNodeId = self.mJianghuKillInfo.CurNodeId --当前节点
            self.mStatus = self.mJianghuKillInfo.Status       --当前人物状态
            self.mJobId = self.mJianghuKillInfo.Profession    --职业id
            self.mCampId = self.mJianghuKillInfo.CampId       --阵营id
            self.mOldBuyTimes = response.Value.BuyTimes       --已购买次数
            self.mEndTime = response.Value.EndTime --赛季结束时间

            self:handlePlayerData(self.mJianghuKillInfo, true)

            self:createTopView()
            self:scorllToItem(self.mCurNodeId, true)

            self:refreshInfo()
            self:refreshDataByAuto()
            self:ifNeedMache()

            if needNodeRef then
                self:requestGetNodeInfo(self.mCurNodeId)
            else
                if self.mStatus == Enums.JHKPlayerStatus.eMoving then
                    self:continueMove(self.mCurNodeId, self.mJianghuKillInfo.TarNodeId, self.mJianghuKillInfo.MoveTime, self.mJianghuKillInfo.MoveCoutdown)
                end
            end

            if self.mRefreshSch then
                self.mParentLayer:stopAllActions()
                self.mRefreshSch = nil
            end

            self.mRefreshSch = Utility.schedule(self.mParentLayer, function()
                self:UpdateTimeSch()
            end, 1)

            -- 创建玩家属性信息
            self:createPlayerInfo()
        end
    })
end

--移动
function JianghuKillMapLayer:requestMove(targetId)
    HttpClient:request({
        moduleName = "JianghuKillTeamHall",
        methodName = "Move",
        svrMethodData = {targetId},
        callbackNode = self,
        callback = function(response)
            -- dump(response, "移动")
        
            -- 容错处理
            if response.Status ~= 0 then
                return
            end
            self.mStatus = Enums.JHKPlayerStatus.eMoving
           
        end
    })
end

--获取信息
function JianghuKillMapLayer:requestGetNodeInfo(nodeId)
    HttpClient:request({
        moduleName = "JianghuKillTeamHall",
        methodName = "GetNodeInfo",
        svrMethodData = {nodeId},
        needWait = false,
        callbackNode = self,
        callback = function(response)
            -- 容错处理
            if response.Status ~= 0 then
                return
            end
            -- dump(response, "GetNodeInfo")
            self:createCityInfoView(nodeId, response.Value)
        end
    })
end

--获取刷新信息
function JianghuKillMapLayer:requestGetRefreshData()
    HttpClient:request({
        moduleName = "JianghuKillTeamHall",
        methodName = "GetRefreshData",
        svrMethodData = {},
        needWait = false,
        callbackNode = self,
        callback = function(response)
            -- 容错处理
            if response.Status ~= 0 then
                return
            end
            -- dump(response, "GetRefreshData")
            self:handlePlayerData(response.Value)
            self.mCampInfo = response.Value.CampData
            self.mRefreshTime = 1
            self:refreshDataByAuto()
        end
    })
end

--直接回城
function JianghuKillMapLayer:requestBackToHome()
    if self.mStatus == Enums.JHKPlayerStatus.eMoving then
        ui.showFlashView(TR("已经在路上了，请稍等片刻"))
        return
    elseif self.mStatus == Enums.JHKPlayerStatus.eOccupy then
        ui.showFlashView(TR("请先离开驻守"))
        return
    end
    HttpClient:request({
        moduleName = "JianghuKillTeamHall",
        methodName = "BackToHome",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            -- 容错处理
            if response.Status ~= 0 then
                return
            end
            -- dump(response, "BackToHome")
            --回城重新刷新所有数据
            self:requestGetInfoTeamHall(true)
        end
    })
end

--取消驻守(用于直接离开节点)
function JianghuKillMapLayer:requestCancelOccupy(targetId)
    HttpClient:request({
        moduleName = "JianghuKillTeamHall",
        methodName = "CancelOccupy",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            
            if response.Status ~= 0 then
                return
            end
            self.mStatus = Enums.JHKPlayerStatus.eNormal
            self.mJianghuKillInfo.Status = Enums.JHKPlayerStatus.eNormal

            --驻守状态判断显示
            self.mPlayerNode.occupyEff:setVisible(self.mStatus == Enums.JHKPlayerStatus.eOccupy)
            self.mPlayerNode.macheNode:setVisible(self.mStatus ~= Enums.JHKPlayerStatus.eOccupy)
            self.mPlayerNode.spineNode:setVisible(self.mStatus ~= Enums.JHKPlayerStatus.eOccupy)

            self:ifNeedMache()

            self:requestMove(targetId)
        end
    })
end

-- 购买属性
function JianghuKillMapLayer:requestBuy(buyType, buyCount, singleNum)
    HttpClient:request({
        moduleName = "JianghuKillTeamHall",
        methodName = "Buy",
        svrMethodData = {buyType, buyCount},
        callbackNode = self,
        callback = function(response)
            if response.Status ~= 0 then
                return
            end
            self.mOldBuyTimes = response.Value.BuyTimes

            -- 粮草
            if buyType == 1 then
                self.mPlayerHandleData.ForageNum = self.mPlayerHandleData.ForageNum + buyCount*singleNum
            -- 精神
            elseif buyType == 2 then
                self.mPlayerHandleData.SpritNum = self.mPlayerHandleData.SpritNum + buyCount*singleNum
            -- 功力
            elseif buyType == 3 then
                self.mPlayerHandleData.PowerNum = self.mPlayerHandleData.PowerNum + buyCount*singleNum
            -- 悟性
            elseif buyType == 4 then
                self.mPlayerHandleData.CollectionNum = self.mPlayerHandleData.CollectionNum + buyCount*singleNum
            end
        end
    })
end

return JianghuKillMapLayer
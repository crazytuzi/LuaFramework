--[[
    文件名: JianghuKillCityLayer.lua
    描述: 江湖杀内城界面
    创建人: lengjiazhi
    创建时间: 2018.09.03
-- ]]
local JianghuKillCityLayer = class("JianghuKillCityLayer", function(params)
	return display.newLayer()
end)

--[[
	参数：
	nodeModelInfo: 节点表信息
	occupyInfo : 占领信息
	campId: 节点所属势力
	playerInfo: 玩家信息
	refreshData: 刷新用的玩家信息
    buyTimes: 已购买次数
    endTime: 赛季结束时间
--]]

local BelongPicList = {
	[0] = "jhs_108.png",
	[1] = "jhs_20.png",
	[2] = "jhs_35.png",
}

function JianghuKillCityLayer:ctor(params)
	self.mNodeModelInfo = params.nodeModelInfo
	self.mOccupyInfo = params.occupyInfo
	self.mCampId = params.campId
	self.mPlayerInfo = params.playerInfo
	self.mPlayerStatus = self.mPlayerInfo.Status
	self.mPlayerCampId = self.mPlayerInfo.CampId
	self.mRefreshData = params.refreshData
	self.mIsEnemyNode = self.mPlayerInfo.CampId ~= self.mCampId
	self.mTipCountNum = 0 --文本信息计数
	self.mCurResNum = self.mRefreshData.CurResNum
    self.mOldBuyTimes = params.buyTimes
    self.mEndTime = params.endTime
    self.mNeedDelayPost = false --是否需要延时操作，等待聊天推送数据

	-- 屏蔽下层点击事件
    ui.registerSwallowTouch({node = self})

	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	--已经被占领的显示界面
	self.mNormalViewLayer = ui.newStdLayer()
	self:addChild(self.mNormalViewLayer)
	self.mNormalViewLayer:setVisible(false)

	--中立状态的显示界面
	self.mNpcViewLayer = ui.newStdLayer()
	self:addChild(self.mNpcViewLayer)
	self.mNpcViewLayer:setVisible(false)

	self:initUI()
    self:requestGetNodeInfo()
end

function JianghuKillCityLayer:initUI()

	local bgSprite = ui.newSprite("zdcj_09.jpg")
	-- bgSprite:setAnchorPoint(0.5, 0)
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	--关闭按钮
    local cancelBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(580, 1065),
        clickAction = function ()
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(cancelBtn, 1)

    --规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        position = cc.p(60, 1065),
        clickAction = function ()
            MsgBoxLayer.addTabTextLayer(TR("规则"),{
                    {
                        tabName = TR("挑战"),
                        list = {
                            TR("1.除刺客以外的职业，点击下方的“挑战”按钮即可按照规则对随机驻守玩家发动挑战。"),
                            TR("2.随机选取目标优先级：豪杰>前排>后排，即有豪杰在场时，会优先选取豪杰为挑战目标，然后再优先选取前排玩家，最后才会选择后排玩家。"),
                            TR("3.刺客职业直接点击驻守玩家头像即可发动挑战，并且有机会发动刺客职业技能--突袭，发动成功后，可以直接挑战指定的玩家，并且有攻击加成，如果没有发动突袭，则仍然按照规则随机选取目标。"),
                            TR("4.击败门派内的最后一个门派或者守卫，即为占领该门派，该门派会变成占领者的势力，并且有5分钟保护时间，保护时间内敌方势力不能对该门派发起挑战。"),
                        },
                    },
                    {
                        tabName = TR("驻守"),
                        list = {
                            TR("1.当门派属于己方势力时，点击驻守即可按照规则加入驻守阵容。"),
                            TR("2.驻守布阵规则：门派驻守阵容为前排5人，后排5人，点击驻守后，书生职业会优先上阵后排，其他职业优先上阵前排。"),
                            TR("3.预备驻守：当驻守阵容已满10人时，驻守按钮变成“预备驻守”，点击预备驻守即可加入预备驻守队列，当驻守阵容中有玩家被击败或者离开驻守时，会按照驻守布阵规则，自动将预备驻守队列中的玩家上阵到驻守阵容中。"),
                            TR("4.当驻守阵容中有书生时，会提升该门派天机残页的产量，每有1个书生，产量提升20%，最多提升100%。"),
                            TR("5.最后一个驻守玩家离开驻守门派时，如果门派在保护时间内，门派所属势力不会变化，但是如果门派不在保护时间内，门派会变成中立，并且会有5分钟保护时间。"),
                            TR("6.如果保护时间过后门派仍然没有玩家驻守，则门派会立即变成中立，没有保护时间。"),
                        },
                    },
                })
        end
    })
    self.mParentLayer:addChild(ruleBtn, 1)

    --节点信息板
    local nodeInfoBg = ui.newScale9Sprite("jhs_21.png", cc.size(450, 150))
    nodeInfoBg:setPosition(210, 985)
    nodeInfoBg:setAnchorPoint(0.5, 1)
    self.mParentLayer:addChild(nodeInfoBg)
    self.mNodeInfoBg = nodeInfoBg

    local resLeftLabel = ui.newLabel({
        text = TR("天机残页：{jhs_124.png}%s/%s", 0, self.mNodeModelInfo.resoucePointLimit),
        outlineColor = Enums.Color.eOutlineColor,
        })
    resLeftLabel:setPosition(40, 945)
    resLeftLabel:setAnchorPoint(0, 0.5)
    self.mParentLayer:addChild(resLeftLabel)
    self.mResLeftLabel = resLeftLabel

    local speedLabel = ui.newLabel({
        text = TR("残页产出速度：{jhs_124.png}1页/%s秒", 10),
        outlineColor = Enums.Color.eOutlineColor,
        })
    speedLabel:setPosition(40, 905)
    speedLabel:setAnchorPoint(0, 0.5)
    self.mParentLayer:addChild(speedLabel)
    self.mSpeedLabel = speedLabel

    local protectLabel = ui.newLabel({
        text = TR("保护中：00：00"),
        color = Enums.Color.eRed,
        outlineColor = Enums.Color.eOutlineColor,
        })
    protectLabel:setPosition(40, 1000)
    protectLabel:setAnchorPoint(0, 0.5)
    self.mParentLayer:addChild(protectLabel)
    protectLabel:setVisible(false)
    self.mProtectLabel = protectLabel
end

--注册事件
function JianghuKillCityLayer:registerEvent()
    --节点信息变化
	local tempEventNode = cc.Node:create()
	self.mParentLayer:addChild(tempEventNode)
    Notification:registerAutoObserver(tempEventNode, function(node, data)
        -- dump(data, "NodeStatusChange")
        if data.NodeId == self.mNodeModelInfo.ID then
            self.mCampId = data.CampId
            self.mProtectTime = data.ProtectTime
            self:createProtectView()
            self:refreshNodeInfo()
        end
    end, EventsName.eNodeStatusChange)

    --节点内占领信息变化
    local tempEventNode = cc.Node:create()
	self.mParentLayer:addChild(tempEventNode)
    Notification:registerAutoObserver(tempEventNode, function(node, data)
        -- 玩家精神为空才回家
        if data.TargetPlayerSpritNum <= 0 then
            self:refreshListView(3, data)
        end
        --当玩家自己死亡时刷新界面
        if data.TargetPlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then
            if data.TargetPlayerSpritNum <= 0 then
                LayerManager.removeLayer(self)
            end
        end   
    end, EventsName.eAttackInfo)

    --驻守推送
    local tempEventNode = cc.Node:create()
	self.mParentLayer:addChild(tempEventNode)
    Notification:registerAutoObserver(tempEventNode, function(node, data)
        -- dump(data, "OccupyInfo")
        if data.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then
            self.mNeedDelayPost = false
        end

        self:refreshListView(1, data)
    end, EventsName.eOccupyInfo)

    --取消驻守推送
    local tempEventNode = cc.Node:create()
	self.mParentLayer:addChild(tempEventNode)
    Notification:registerAutoObserver(tempEventNode, function(node, data)
        -- dump(data, "CancelOccupyInfo")
        if data.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then
            self.mNeedDelayPost = false
        end

        self:refreshListView(2, data)
    end, EventsName.eCancelOccupyInfo)

    --移动开始推送
    local tempEventNode = cc.Node:create()
    self.mParentLayer:addChild(tempEventNode)
    Notification:registerAutoObserver(tempEventNode, function(node, data)
        LayerManager.removeLayer(self)
    end, EventsName.eBeginMove)
end

--创建通用显示
function JianghuKillCityLayer:createNormalView()
	self.mNormalViewLayer:removeAllChildren()
	self.mNodeInfoBg:setContentSize(450, 150)

    --节点归属信息
    local belongSprite = ui.newSprite(BelongPicList[self.mCampId])
    belongSprite:setPosition(320, 1065)
    self.mNormalViewLayer:addChild(belongSprite)
    self.mBelongSprite = belongSprite

    --节点名字
    local belongLabel = ui.newLabel({
        text = self.mNodeModelInfo.name,
        size = 24,
        color = Enums.Color.eBlack,
        })
    belongLabel:setPosition(180, 55)
    belongSprite:addChild(belongLabel)

	--下方底板
	local bottomBgSprite = ui.newSprite("jhs_24.png")
	bottomBgSprite:setAnchorPoint(0.5, 0)
	bottomBgSprite:setPosition(320, 0)
	self.mNormalViewLayer:addChild(bottomBgSprite)

	--消息底板
    local msgBgSprite = ui.newScale9Sprite("jhs_25.png", cc.size(570, 160))
    msgBgSprite:setPosition(320, 240)
    self.mNormalViewLayer:addChild(msgBgSprite)

    --组队按钮
    local teamBtn = ui.newButton({
    	normalImage = "jhs_29.png",
    	clickAction = function()
    		LayerManager.addLayer({name = "jianghuKill.JianghuKillTeamLayer", data = {currentNodeId = self.mNodeModelInfo.ID or 1}, cleanUp = false,})
    	end
    	})
	teamBtn:setPosition(553, 98)
    self.mNormalViewLayer:addChild(teamBtn)

    --采集按钮
    local collectBtn = ui.newButton({
    	normalImage = "jhs_28.png",
    	clickAction = function()
    		self:requestCollect()
    	end
    	})
	collectBtn:setPosition(95, 98)
    self.mNormalViewLayer:addChild(collectBtn)
    self.mCollectBtn = collectBtn

    --主要操作按钮
    local handleBtn = ui.newButton({
    	normalImage = "jhs_23.png",
    	text = TR("驻  守"),
    	outlineColor = Enums.Color.eOutlineColor,
        titlePosRateX = 0.55,
    	clickAction = function()
    		-- self:requestOccupyNode()
    		-- self:requestCancelOccupy()
    	end
    	})
	handleBtn:setPosition(320, 77)
    self.mNormalViewLayer:addChild(handleBtn)
    self.mHandleBtn = handleBtn

    local prepareLabel = ui.newLabel({
        text = TR("预备驻守玩家：%s/%s", self.mPrepareNum or 0, JianghukillModel.items[1].preResidentNum),
        outlineColor = Enums.Color.eOutlineColor,
        -- size = 18,
        })
    prepareLabel:setPosition(40, 865)
    prepareLabel:setAnchorPoint(0, 0.5)
    self.mNormalViewLayer:addChild(prepareLabel)
    self.mPrepareLabel = prepareLabel

    local tipLabel = ui.newLabel({
        text = TR("*每有1位书生驻守，残页产出速度+20%，最多+100%"),
        color = Enums.Color.eYellow,
        -- outlineColor = Enums.Color.eOutlineColor,
        size = 20,
        })
    tipLabel:setPosition(40, 825)
    tipLabel:setAnchorPoint(0, 0.5)
    self.mNormalViewLayer:addChild(tipLabel)
    -- self.mtipLabel = tipLabel

    -- local prepareBtn = ui.newButton({
    -- 	text = TR("查看列表"),
    -- 	normalImage = "c_28.png",
    -- 	clickAction = function()
    -- 		self:createListPop()
    -- 	end
    -- 	})
    -- prepareBtn:setPosition(360, 35)
    -- prepareBtn:setScale(0.7)
    -- self.mNodeInfoBg:addChild(prepareBtn)

    local collectNumLabel = ui.newLabel({
        text = TR("悟性：%s/%s", 0, 10),
        color = Enums.Color.eBlack,
        size = 20,
        })
    collectNumLabel:setPosition(40, 25)
    collectNumLabel:setAnchorPoint(0, 0.5)
    self.mNormalViewLayer:addChild(collectNumLabel)
    self.mCollectNumLabel = collectNumLabel

    local fightNumLabel = ui.newLabel({
        text = TR("精神：%s/%s", 0, 10),
        color = Enums.Color.eBlack,
        size = 20,
        })
    fightNumLabel:setPosition(320, 25)
    self.mNormalViewLayer:addChild(fightNumLabel)
    self.mFightNumLabel = fightNumLabel

    local jobInfo = JianghukillOccupationalprope.items[self.mPlayerInfo.Profession][self.mPlayerInfo.ProfessionLv]

    -- 悟性购买按钮
    self.mCollectionBtn = self:createBuyAttrBtn(4, JianghukillModel.items[1].buyWuXingNum, TR("悟性"), "mCollectionNum", jobInfo.wuXing)
    self.mCollectionBtn:setAnchorPoint(cc.p(0, 0.5))
    self.mCollectionBtn:setScale(0.8)
    self.mCollectionBtn:setPosition(160, 25)
    self.mNormalViewLayer:addChild(self.mCollectionBtn)

    if self.mIsEnemyNode then   -- 功力
        self.mPowerBtn = self:createBuyAttrBtn(3, JianghukillModel.items[1].buyPowerNum, TR("功力"), "mPowerNum", jobInfo.powerLimit)
        self.mPowerBtn:setAnchorPoint(cc.p(0, 0.5))
        self.mPowerBtn:setScale(0.8)
        self.mPowerBtn:setPosition(390, 25)
        self.mNormalViewLayer:addChild(self.mPowerBtn)
    else                        -- 精神
        self.mSpritBtn = self:createBuyAttrBtn(2, JianghukillModel.items[1].buySpriteNum, TR("精神"), "mSpritNum", jobInfo.spriteLimit)
        self.mSpritBtn:setAnchorPoint(cc.p(0, 0.5))
        self.mSpritBtn:setScale(0.8)
        self.mSpritBtn:setPosition(390, 25)
        self.mNormalViewLayer:addChild(self.mSpritBtn)
    end

    -- 后排列表
    local behindListView = ccui.ListView:create()
    behindListView:setDirection(ccui.ScrollViewDir.horizontal)
    behindListView:setBounceEnabled(true)
    behindListView:setContentSize(cc.size(600, 160))
    behindListView:setItemsMargin(5)
    behindListView:setAnchorPoint(cc.p(0.5, 1))
    behindListView:setPosition(320, 735)
    behindListView:setTouchEnabled(false)
    self.mNormalViewLayer:addChild(behindListView)
    self.mBehindListView = behindListView

    -- 前排列表
    local frontListView = ccui.ListView:create()
    frontListView:setDirection(ccui.ScrollViewDir.horizontal)
    frontListView:setBounceEnabled(true)
    frontListView:setContentSize(cc.size(600, 160))
    frontListView:setItemsMargin(5)
    frontListView:setAnchorPoint(cc.p(0.5, 1))
    frontListView:setPosition(320, 505)
    frontListView:setTouchEnabled(false)
    self.mNormalViewLayer:addChild(frontListView)
    self.mFrontListView = frontListView

    -- 文本显示列表
    local tipLableListView = ccui.ListView:create()
    tipLableListView:setDirection(ccui.ScrollViewDir.vertical)
    tipLableListView:setBounceEnabled(true)
    tipLableListView:setContentSize(cc.size(550, 140))
    tipLableListView:setAnchorPoint(cc.p(0.5, 1))
    tipLableListView:setPosition(320, 308)
    self.mNormalViewLayer:addChild(tipLableListView)
    self.mTipLableListView = tipLableListView

    self:refreshInfo()
end

--创建中立弹窗
function JianghuKillCityLayer:createNpcView()
	self.mNpcViewLayer:removeAllChildren()

	local nodeNpcInfo = JianghukillNpcModel.items[self.mNodeModelInfo.ID]
	self.mNodeInfoBg:setContentSize(450, 120)


    --节点归属信息
    local belongSprite = ui.newSprite(BelongPicList[self.mCampId])
    belongSprite:setPosition(320, 1065)
    self.mNpcViewLayer:addChild(belongSprite)
    self.mBelongSprite = belongSprite

    --节点名字
    local belongLabel = ui.newLabel({
        text = self.mNodeModelInfo.name,
        size = 24,
        color = Enums.Color.eBlack,
        })
    belongLabel:setPosition(165, 55)
    belongSprite:addChild(belongLabel)

	--下方底板
	local bottomBgSprite = ui.newSprite("jhs_81.png")
	bottomBgSprite:setPosition(320, 500)
	self.mNpcViewLayer:addChild(bottomBgSprite)

	 --组队按钮
    local teamBtn = ui.newButton({
    	normalImage = "jhs_29.png",
    	clickAction = function()
    		LayerManager.addLayer({name = "jianghuKill.JianghuKillTeamLayer", data = {currentNodeId = self.mNodeModelInfo.ID or 1}, cleanUp = false,})
    	end
    	})
	teamBtn:setPosition(553, 98)
    self.mNpcViewLayer:addChild(teamBtn)

	local heroFigure = Figure.newHero({
        heroModelID = nodeNpcInfo[1].heroModelID,
        parent = bottomBgSprite,
        position = cc.p(200, 105),
        scale = 0.4,
        needAction = false,
    })

    local enemyNameLabel = ui.newLabel({
        text = nodeNpcInfo[1].npcName,
        size = 30,
        color = Enums.Color.eBlack,
        -- outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        })
    enemyNameLabel:setPosition(470, 560)
    bottomBgSprite:addChild(enemyNameLabel)


    local npcFap = 0
    for i,v in ipairs(nodeNpcInfo) do
    	npcFap = npcFap + v.FAP
    end
    local fapBgSprite = ui.newSprite("jhs_82.png")
    fapBgSprite:setPosition(470, 480)
    bottomBgSprite:addChild(fapBgSprite)

    local fapLabel = ui.newNumberLabel({
	 	text = Utility.numberWithUnit(npcFap),
        imgFile = "jhs_85.png", -- 数字图片名
        charCount = 12, 
	})
	fapLabel:setAnchorPoint(0, 0.5)
	fapLabel:setPosition(60, 25)
	fapBgSprite:addChild(fapLabel)

    --布阵按钮
    local campBtn = ui.newButton({
        normalImage = "jhs_83.png",
        clickAction = function(layer)
            -- LayerManager.removeLayer(layer)
            LayerManager.addLayer({
                name = "team.CampLayer",
                cleanUp = false,
            })
        end
        })
    campBtn:setPosition(470, 360)
    bottomBgSprite:addChild(campBtn)

    --挑战按钮
    local fightBtn = ui.newButton({
    	text = TR("开始挑战"),
    	normalImage = "c_28.png",
    	clickAction = function()
    		self:requestAttackNode(EMPTY_ENTITY_ID)
    	end
    	})
    fightBtn:setPosition(470, 220)
    bottomBgSprite:addChild(fightBtn)

    --放弃按钮
    local cancleBtn = ui.newButton({
    	text = TR("放 弃"),
    	normalImage = "c_28.png",
    	clickAction = function()
            LayerManager.removeLayer(self)
    	end
    	})
    cancleBtn:setPosition(470, 120)
    bottomBgSprite:addChild(cancleBtn)

    local tipLable = ui.createLabelWithBg({
    	bgFilename = "c_25.png",
        bgSize = cc.size(420, 50),
        labelStr = TR("击败门派守卫后，即可占领该门派"),
        -- fontSize = nil,     
        outlineColor = Enums.Color.eOutlineColor,
        alignType = ui.TEXT_ALIGN_CENTER,
    	})
    tipLable:setPosition(320, 125)
    self.mNpcViewLayer:addChild(tipLable)


    local fightNumLabel = ui.newLabel({
        text = TR("功力：%s/%s", 0, 10),
        color = Enums.Color.eBlack,
        size = 20,
        })
    fightNumLabel:setPosition(470, 170)
    bottomBgSprite:addChild(fightNumLabel)
    self.mFightNumLabel = fightNumLabel

    -- 功力购买按钮
    local jobInfo = JianghukillOccupationalprope.items[self.mPlayerInfo.Profession][self.mPlayerInfo.ProfessionLv]
    local powerBuyBtn = self:createBuyAttrBtn(3, JianghukillModel.items[1].buyPowerNum, TR("功力"), "mPowerNum", jobInfo.powerLimit)
    powerBuyBtn:setAnchorPoint(cc.p(0, 0.5))
    powerBuyBtn:setScale(0.8)
    powerBuyBtn:setPosition(530, 170)
    bottomBgSprite:addChild(powerBuyBtn)
end

--占领信息改变刷新
function JianghuKillCityLayer:refreshNodeInfo()

	if self.mCampId == Enums.JHKCampType.eZhongli then
    	self:createNpcView()
    	self.mNormalViewLayer:setVisible(false)
    	self.mNpcViewLayer:setVisible(true)
        self.mSpeedLabel:setString(TR("残页产出速度：{jhs_124.png}%s页/%s秒", self.mResRate, self.mResTime))
    else
        self.mIsEnemyNode = self.mCampId ~= self.mPlayerCampId
    	self:createNormalView()
    	self.mNormalViewLayer:setVisible(true)
    	self.mNpcViewLayer:setVisible(false)
    	
    	self:refeshView()
    	self.mCollectBtn:setEnabled(not self.mIsEnemyNode)
    end
    -- self.mSpeedLabel:setString(TR("残页产出速度：{jhs_124.png}%s页/%s秒", self.mResRate*1, self.mResTime))
    
    -- self.mBelongSprite:setTexture(BelongPicList[self.mCampId])
end

--节点内信息改变刷新
function JianghuKillCityLayer:refeshView()
	if self.mIsEnemyNode then
		self.mHandleBtn:setTitleText(TR("进  攻"))
        self.mHandleBtn:loadTextures("jhs_120.png", "jhs_120.png")
    	self.mHandleBtn:setClickAction(function()
    		if self.mPlayerInfo.Profession == 2 then
                MsgBoxLayer.addOKLayer(
                    TR("刺客请直接点击头像选择想挑战的玩家，发动突袭即可挑战该玩家，如果未发动突袭则随机选择目标"), 
                    TR("提示"), 
                    {
                        {
                            normalImage = "c_28.png",
                            text = TR("确定"),
                            clickAction = function(layer)
                                LayerManager.removeLayer(layer)
                            end,
                        },
                },{})
    			return
    		end
    		self:requestAttackNode(EMPTY_ENTITY_ID)
    	end)
	else
		if self.mPlayerStatus == Enums.JHKPlayerStatus.eOccupy then
	    	self.mHandleBtn:setTitleText(TR("取消驻守"))
	    	self.mHandleBtn:setClickAction(function()
                if self.mNeedDelayPost then
                    return
                else
                    self.mNeedDelayPost = true
                end

	    		self:requestCancelOccupy()
	    	end)
	    else
	    	self.mHandleBtn:setTitleText(TR("驻  守"))
            self.mHandleBtn:loadTextures("jhs_23.png", "jhs_23.png")
	    	self.mHandleBtn:setClickAction(function()
                if self.mNeedDelayPost then
                    return
                else
                    self.mNeedDelayPost = true
                end
	    		self:requestOccupyNode()
	    	end)
	    end
	end
    self.mFrontListView:removeAllChildren()
    self.mBehindListView:removeAllChildren()
    for i,v in ipairs(self.mPrelistInfo) do
    	self.mFrontListView:pushBackCustomItem(self:createHeadItem(v))
    end

    for i,v in ipairs(self.mSuflistInfo) do
    	self.mBehindListView:pushBackCustomItem(self:createHeadItem(v))
    end
    self:refreshSpeed()
end

--刷新文本框文字
function JianghuKillCityLayer:pushbackLabelbottom(tempStr)
	local layout = ccui.Layout:create()
	layout:setContentSize(540, 35)

	local label = ui.newLabel({
		text = tempStr,
		color = Enums.Color.eBlack,	
		size = 20,
	})
	label:setAnchorPoint(0, 0.5)
	label:setPosition(5, 20)
	layout:addChild(label)

	self.mTipLableListView:pushBackCustomItem(layout)
	self.mTipCountNum = self.mTipCountNum + 1

	ui.setListviewItemShow(self.mTipLableListView, self.mTipCountNum)
end

--队列推送刷新
function JianghuKillCityLayer:refreshListView(refreshType, info)
    if not self.mTipLableListView then --判断是否存在信息框，不存在则忽略队列信息
        return
    end
    self.mPrepareNum = info.PrepareNum
    self.mPrepareLabel:setString(TR("预备驻守玩家：%s/%s", info.PrepareNum, JianghukillModel.items[1].preResidentNum))

	if refreshType == 1 then --加入驻守
		if info.ListEnum == 1 then --前排
            local isExist = false   -- 是否已在队伍中
            for _, heroInfo in pairs(self.mPrelistInfo) do
                if heroInfo.PlayerId == info.PlayerId then
                    isExist = true
                    break
                end
            end
            if not isExist then
    			table.insert(self.mPrelistInfo, info)
            end
		elseif info.ListEnum == 2 then --后排
            local isExist = false   -- 是否已在队伍中
            for _, heroInfo in pairs(self.mSuflistInfo) do
                if heroInfo.PlayerId == info.PlayerId then
                    isExist = true
                    break
                end
            end
            if not isExist then
                table.insert(self.mSuflistInfo, info)
            end
		end
		local tempStr = TR("%s加入了驻守", info.Name)
		-- self:pushbackLabelbottom(tempStr)
	elseif refreshType == 2 then --离开驻守
		--手动删除队列里面的人	
		if info.ListEnum == 1 then --前排
			for i,v in ipairs(self.mPrelistInfo) do
				if v.PlayerId == info.PlayerId then
					table.remove(self.mPrelistInfo, i)
				end
			end
		elseif info.ListEnum == 2 then --后排
			for i,v in ipairs(self.mSuflistInfo) do
				if v.PlayerId == info.PlayerId then
					table.remove(self.mSuflistInfo, i)
				end
			end
		end
		local tempStr = TR("%s离开了驻守", info.Name)
		-- self:pushbackLabelbottom(tempStr)
	elseif refreshType == 3 then --战斗改变队列
		local tempStr
		if info.IsWin then
			--手动删除队列里面的人
			for i,v in ipairs(self.mPrelistInfo) do
				if v.PlayerId == info.TargetPlayerId then
					table.remove(self.mPrelistInfo, i)
				end
			end
			for i,v in ipairs(self.mSuflistInfo) do
				if v.PlayerId == info.TargetPlayerId then
					table.remove(self.mSuflistInfo, i)
				end
			end
			tempStr = TR("%s 挑战了 %s，挑战成功", info.PlayerName, info.TargetPlayerName)
		else
			tempStr = TR("%s 挑战了 %s， 挑战失败", info.PlayerName, info.TargetPlayerName)
            if info.TargetPlayerSpritNum <= 0 then
                    --手动删除队列里面的人
                for i,v in ipairs(self.mPrelistInfo) do
                    if v.PlayerId == info.TargetPlayerId then
                        table.remove(self.mPrelistInfo, i)
                    end
                end
                for i,v in ipairs(self.mSuflistInfo) do
                    if v.PlayerId == info.TargetPlayerId then
                        table.remove(self.mSuflistInfo, i)
                    end
                end
            end
		end
		self:pushbackLabelbottom(tempStr)
	end

    self.mFrontListView:removeAllChildren()
    self.mBehindListView:removeAllChildren()
    for i,v in ipairs(self.mPrelistInfo) do
    	self.mFrontListView:pushBackCustomItem(self:createHeadItem(v))
    end

    for i,v in ipairs(self.mSuflistInfo) do
    	self.mBehindListView:pushBackCustomItem(self:createHeadItem(v))
    end
    self:refreshSpeed()
end

--根据书生计算产出速度加成
function JianghuKillCityLayer:refreshSpeed()
	local tempNum = 0
 	for i,v in ipairs(self.mPrelistInfo) do
 		if v.Profession == 3 then
 			tempNum = tempNum + 1
 		end
    end

    for i,v in ipairs(self.mSuflistInfo) do
    	if v.Profession == 3 then
 			tempNum = tempNum + 1
 		end
    end
    local add = tempNum*0.2 >= 1 and 1 or tempNum*0.2 
    local speed = self.mNodeModelInfo.onceResidentOutputNum
    if add > 0 then
        self.mSpeedLabel:setString(TR("残页产出速度：{jhs_124.png}%s页/%s秒#93f0a2(书生+%s%%)", speed * (add+1), self.mResTime, add*100))
    else
        self.mSpeedLabel:setString(TR("残页产出速度：{jhs_124.png}%s页/%s秒", speed * (add+1), self.mResTime))
    end
end


--创建头像item
function JianghuKillCityLayer:createHeadItem(info)
	local layout = ccui.Layout:create()
	layout:setContentSize(116, 160)

	local headCard = CardNode.createCardNode({
        resourceTypeSub = Utility.getTypeByModelId(info.HeadImageId),
        modelId = info.HeadImageId,
        cardShowAttrs = {CardShowAttr.eBorder},
        onClickCallback = function()
        	-- print("详情")
        	if self.mPlayerInfo.Profession == 2 and self.mIsEnemyNode then
        		self:requestAttackNode(info.PlayerId)
        	end
        end
    })
    headCard:setPosition(58, 110)
    layout:addChild(headCard)

    local borderSprite = ui.newSprite("jhs_22.png")
    borderSprite:setPosition(58, 110)
    layout:addChild(borderSprite)

    local jobSprite = ui.newSprite(Utility.getJHKJobPic(info.Profession))
    jobSprite:setPosition(58, 65)
    jobSprite:setScale(0.7)
    layout:addChild(jobSprite)

    local nameLabel = ui.newLabel({
    	text = info.Name,
    	color = Enums.Color.eBlack,
    	size = 18,
    	})
    nameLabel:setPosition(58, 30)
    layout:addChild(nameLabel)

    local fapLabel = ui.newLabel({
    	text = Utility.numberWithUnit(info.Fap), 
    	color = Enums.Color.eBlack,
    	size = 18,
    	})
    fapLabel:setPosition(58, 10)
    layout:addChild(fapLabel)

	return layout
end

--创建查看队列弹窗
function JianghuKillCityLayer:createListPop()
	--弹窗
    local popLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(580, 580),
        title = TR("查看列表"),
        closeAction = function(pSender)
            LayerManager.removeLayer(pSender)
        end,
    })
    self:addChild(popLayer)
    self.mPopLayer = popLayer
    self.mPopBgSprite = popLayer.mBgSprite

    local ruleLabel1 = ui.newLabel({
    	text = TR("书生优先填充后排，豪杰优先填充前排"),
    	color = Enums.Color.eBlack,
    	size = 20,
    	})
    -- ruleLabel1:setAnchorPoint(0, 0.5)
    ruleLabel1:setPosition(290, 500)
    self.mPopBgSprite:addChild(ruleLabel1)

    -- 列表
    local prepareListView = ccui.ListView:create()
    prepareListView:setDirection(ccui.ScrollViewDir.vertical)
    prepareListView:setBounceEnabled(true)
    prepareListView:setContentSize(cc.size(540, 450))
    prepareListView:setItemsMargin(5)
    prepareListView:setAnchorPoint(cc.p(0.5, 1))
    prepareListView:setPosition(290, 480)
    prepareListView:setTouchEnabled(false)
    self.mPopBgSprite:addChild(prepareListView)

    local tipPics = {
	    [1] = "jhs_76.png",
	    [2] = "jhs_77.png",
	    [3] = "jhs_78.png",
	}
    local function createItem(index)
    	local layout = ccui.Layout:create()
    	layout:setContentSize(524, 140)

    	local tipSprite = ui.newSprite(tipPics[index])
    	tipSprite:setPosition(30, 65)
    	layout:addChild(tipSprite)

    	local grayBg = ui.newScale9Sprite("c_17.png", cc.size(470, 140))
    	grayBg:setPosition(290, 65)
    	layout:addChild(grayBg)

    	local tempListView = ccui.ListView:create()
	    tempListView:setDirection(ccui.ScrollViewDir.horizontal)
	    tempListView:setBounceEnabled(true)
	    tempListView:setContentSize(cc.size(460, 110))
	    tempListView:setItemsMargin(5)
	    tempListView:setAnchorPoint(cc.p(0.5, 1))
	    tempListView:setPosition(290, 115)
	    -- tempListView:setTouchEnabled(false)
	    layout:addChild(tempListView)

	    return layout
    end

    for i = 1, 3 do
    	prepareListView:pushBackCustomItem(createItem(i))
    end
end

--刷新界面显示
function JianghuKillCityLayer:refreshInfo()
	--刷新4条个人信息
    local jobInfo = JianghukillOccupationalprope.items[self.mPlayerInfo.Profession][self.mPlayerInfo.ProfessionLv]

    -- self.mResLeftLabel:setString(TR("天机残页：%s/%s", self.mCurResNum, self.mNodeModelInfo.resoucePointLimit))

    if self.mCampId ~= Enums.JHKCampType.eZhongli then
	    if self.mIsEnemyNode then
	    	self.mFightNumLabel:setString(TR("功力：%s/%s", self.mPowerNum, jobInfo.powerLimit))
	    else
	    	self.mFightNumLabel:setString(TR("精神：%s/%s", self.mSpritNum, jobInfo.spriteLimit))
	    end
	    self.mCollectNumLabel:setString(TR("悟性：%s/%s", self.mCollectionNum, jobInfo.wuXing))
    else
        self.mFightNumLabel:setString(TR("功力：%s/%s", self.mPowerNum, jobInfo.powerLimit))    
	end
end

-- 创建购买属性按钮
function JianghuKillCityLayer:createBuyAttrBtn(attrType, singleNum, attrName, attrField, maxValue)
    --购买按钮
    local teamBtn = ui.newButton({
        normalImage = "c_21.png",
        clickAction = function()
            if self.mOldBuyTimes >= VipModel.items[PlayerAttrObj:getPlayerAttrByName("Vip")].jianghukillBuyNum then
                ui.showFlashView(TR("今日购买次数已达上限"))
                return
            end
            local curAttrValue = self[attrField]
            if (curAttrValue >= maxValue) or (singleNum+curAttrValue > maxValue) then
                ui.showFlashView(TR("不能超过上限"))
                return
            end
            local maxCount = maxValue - curAttrValue
            local maxCount1 = VipModel.items[PlayerAttrObj:getPlayerAttrByName("Vip")].jianghukillBuyNum - self.mOldBuyTimes
            if maxCount1 > 0 then
                maxCount = maxCount < maxCount1 and maxCount or maxCount1
            end
            MsgBoxLayer.buyJHSCountHintLayer(self.mOldBuyTimes, maxCount, singleNum, attrName, function (buyCount)
                self:requestBuy(attrType, buyCount, singleNum)
            end)
        end
    })

    return teamBtn
end

--添加保护中倒计时
function JianghuKillCityLayer:createProtectView()
	--保护时间
	self.mProtectLabel:setVisible(true)
	local timeLeft = self.mProtectTime
	local protectSch 
	protectSch = Utility.schedule(self.mProtectLabel, function()
		timeLeft = timeLeft - 1
		if timeLeft > 0 then
    		self.mProtectLabel:setString(TR("保护中：%s", MqTime.formatAsHour(timeLeft)))
		else
			self.mProtectLabel:setVisible(false)
			self.mProtectLabel:stopAllActions()
			protectSch = nil
		end
    end, 1)
end

--刷新天机残页倒计时
function JianghuKillCityLayer:updateTime()
	if self.mCurResNum < self.mNodeModelInfo.resoucePointLimit then
		self.mNextOutputTime = self.mNextOutputTime - 1
    	self.mResLeftLabel:setString(TR("天机残页：{jhs_124.png}%.1f/%s(%s)", self.mCurResNum < 0 and 0 or self.mCurResNum, self.mNodeModelInfo.resoucePointLimit, MqTime.formatAsHour(self.mNextOutputTime)))
		if self.mNextOutputTime <= 0 then
			self.mCurResNum = self.mCurResNum + 1
			self.mNextOutputTime = self.mNodeModelInfo.residentOutputTime
		end
	else
    	self.mResLeftLabel:setString(TR("天机残页：{jhs_124.png}%.1f/%s", self.mCurResNum < 0 and 0 or self.mCurResNum, self.mNodeModelInfo.resoucePointLimit))
	end		

    local seasonTimeLeft = self.mEndTime - Player:getCurrentTime()
    if seasonTimeLeft <= 0 then
        ui.showFlashView(TR("本赛季结束"))
        LayerManager.removeLayer(self)
    end
end

--=================================网络请求====================================
--获取信息
function JianghuKillCityLayer:requestGetNodeInfo()
    HttpClient:request({
        moduleName = "JianghuKillTeamHall",
        methodName = "GetOccupyInfo",
        svrMethodData = {self.mNodeModelInfo.ID},
        callbackNode = self,
        callback = function(response)
            -- 容错处理
            if response.Status ~= 0 then
                return
            end
            -- dump(response, "GetOccupyInfo")
           	self.mPrelistInfo = response.Value.PrelistInfo--前排
           	self.mSuflistInfo = response.Value.SuflistInfo--后排
           	self.mPrepareNum = response.Value.PrepareNum --预备数量
           	self.mProtectTime = response.Value.ProtectTime --保护时间
           	self.mNextOutputTime = response.Value.NextOutputTime --下次产出时间倒计时
            self.mResTime = response.Value.ResTime --产出秒数
            self.mResRate = response.Value.ResRate --产出速度加成倍数
            
            self:registerEvent()
 			self:refreshNodeInfo()

 			--定时刷新机制
 			self.mRefreshTime = 10
            self.mRefreshSch = Utility.schedule(self.mParentLayer, function()
                self.mRefreshTime = self.mRefreshTime +1 
                if self.mRefreshTime > 10 then
                    self.mRefreshTime = 1
                    self:requestGetRefreshData()
                end
                self:updateTime()
            end, 1)

            if self.mProtectTime > 0 then
            	self:createProtectView()
            end
        end
    })
end

--挑战
function JianghuKillCityLayer:requestAttackNode(guid)
	if self.mPowerNum <= 0 then
		ui.showFlashView(TR("功力不足"))
		return
	end

    HttpClient:request({
        moduleName = "JianghuKillTeamHall",
        methodName = "AttackNode",
        svrMethodData = {guid},
        callbackNode = self,
        callback = function(response)
            -- 容错处理
            if response.Status ~= 0 then
                return
            end

            -- 刺客职业提示突袭失败
            if response.Value.Data.CikeRadio > 0 then
                ui.showFlashView(TR("突袭成功"))
            elseif Utility.isEntityId(guid) and PlayerAttrObj:getPlayerAttrByName("JianghuKillJobId") == 2 then
                ui.showFlashView(TR("突袭失败"))
            end
       		LayerManager.addLayer({
       			name = "jianghuKill.jianghuKillFight",
       			data = {
	       			fightInfo = response.Value.Data.CalcRequest,
	       			playerInfo = response.Value.Data.PlayerInfo, 
	       			targetInfo = response.Value.Data.TargetInfo,
	       			isWin = response.Value.Data.IsWin,
	       			jobId = self.mPlayerInfo.Profession,
                    cikeRadio = response.Value.Data.CikeRadio,
                    atkRadio = response.Value.Data.AtkRadio,
                    defRadio = response.Value.Data.DefRadio,
                    honorCoin = response.Value.HonorCoin,
                    defAtkRadio = response.Value.Data.DefendAtkRadio,
                    teamAtkRadio = response.Value.Data.TeamAtkRadio,
                    defTeamAtkRadio = response.Value.Data.DefendTeamAtkRadio
       			},
       			cleanUp = false,
   			})
   			self.mPowerNum = response.Value.Data.PlayerInfo.PowerNum
            self:refreshInfo()
        end
    })
end

--驻守
function JianghuKillCityLayer:requestOccupyNode()
    if self.mSpritNum <= 0 then
        ui.showFlashView(TR("精神不足"))
        return
    end
    HttpClient:request({
        moduleName = "JianghuKillTeamHall",
        methodName = "OccupyNode",
        svrMethodData = {self.mNodeModelInfo.ID},
        callbackNode = self,
        callback = function(response)
            -- dump(response, "OccupyNode")
            -- 容错处理
            if response.Status ~= 0 then
                self.mNeedDelayPost = false
                return
            end

           	self.mPlayerStatus = Enums.JHKPlayerStatus.eOccupy
           	self:refeshView()
        end
    })
end

--取消驻守
function JianghuKillCityLayer:requestCancelOccupy()
    HttpClient:request({
        moduleName = "JianghuKillTeamHall",
        methodName = "CancelOccupy",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            -- dump(response, "CancelOccupy")
            -- 容错处理
            if response.Status ~= 0 then
                self.mNeedDelayPost = false
                return
            end
           	self.mPlayerStatus = Enums.JHKPlayerStatus.eNormal
           	self:refeshView()
        end
    })
end

--采集
function JianghuKillCityLayer:requestCollect()
	if self.mCollectionNum <= 0 then
		ui.showFlashView(TR("悟性不足"))
		return
	end
	HttpClient:request({
        moduleName = "JianghuKillTeamHall",
        methodName = "Collect",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            -- dump(response, "Collect")
            -- 容错处理
            if response.Status ~= 0 then
                return
            end
            ui.showFlashView(TR("获得%s天机残页", response.Value.CollectionResNum))
            self.mCurResNum = self.mCurResNum - response.Value.CollectionResNum
            self.mCollectionNum = response.Value.CollectionNum

            self:refreshInfo()

            -- 播放特效
            ui.newEffect({
                    parent = self.mNormalViewLayer,
                    effectName = "effect_ui_lingwu",
                    loop = false,
                    position = cc.p(95, 98),
                })
        end
    })
end

--获取刷新信息
function JianghuKillCityLayer:requestGetRefreshData()
    HttpClient:request({
        moduleName = "JianghuKillTeamHall",
        methodName = "GetRefreshData",
        svrMethodData = {},
        callbackNode = self,
        needWait = false,
        callback = function(response)
            -- 容错处理
            if response.Status ~= 0 then
                return
            end
            -- dump(response, "GetRefreshData")

            self.mPowerNum = response.Value.PowerNum or 0
		    self.mSpritNum = response.Value.SpritNum or 0
		    self.mCollectionNum = response.Value.CollectionNum or 0
		    self.mForageNum = response.Value.ForageNum or 0
		    self.mCurResNum = response.Value.CurResNum or 0

            self:refreshInfo()
        end
    })
end

-- 购买属性
function JianghuKillCityLayer:requestBuy(buyType, buyCount, singleNum)
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
                self.mForageNum = self.mForageNum + buyCount*singleNum
            -- 精神
            elseif buyType == 2 then
                self.mSpritNum = self.mSpritNum + buyCount*singleNum
            -- 功力
            elseif buyType == 3 then
                self.mPowerNum = self.mPowerNum + buyCount*singleNum
            -- 悟性
            elseif buyType == 4 then
                self.mCollectionNum = self.mCollectionNum + buyCount*singleNum
            end
            self:refreshInfo()
        end
    })
end

return JianghuKillCityLayer
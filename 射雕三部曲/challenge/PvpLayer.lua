--[[
    文件名：PvpLayer.lua
    描述：竞技场主页面
    创建人：suntao
    修改人：chenqiang
    创建时间：2016.6.22
-- ]]

local PvpLayer = class("PvpLayer",function()
    return display.newLayer()
end)

-- 构造函数
--[[
-- params结构：
	{
		data  		服务器PVP模块 GetPVPInfo 方法返回的数据结构，如果为nil则需本页面自行获取
		extraGetGameResource    	排名提示可能产生的额外掉落
		isFirstIn   控制是否显示阶段页面的参数true为显示
		gotoRank	是否进入排行页面
	}
--]]
function PvpLayer:ctor(params)
	-- 参数
	self.mGotoRank = params.gotoRank or false
	self.mIsFirstIn = params.isFirstIn or false
	-- 数据
	self.mData = params.data
	self.mExtraGetGameResource = params.extraGetGameResource

	self.mBackgrounds = {}	
	self.mPlayerList = {}
	self.mSelfIndex = nil

	-- 控件
	self.mRankInfoLayout = nil
	self.mStepInfoLayout = nil
	self.mPlayerListView = nil


	-- 创建层
    self:createLayer()

    if not self.mData then
	    -- 获取数据
	    self:requestGetPVPInfo()
	else
		self.mData.FightInfo = nil
		self:showInfo()

        -- 执行新手引导
        self:executeGuide()
	end
end
--跳转到阶段展示页面
function PvpLayer:showStepView(isActive)
	LayerManager.addLayer({
			name = "challenge.PvpRankStepLayer",
            data = {step = self.mData.HistoryMaxStep, isFirst = isActive and true or false},
            cleanUp = false,
		})
end

-- 初始化界面
function PvpLayer:createLayer()
    -- 创建标准容器
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 远景
    -- local sprite = ui.newSprite("smb_10.jpg")
    -- sprite:setPosition(320, 568)
    -- self.mParentLayer:addChild(sprite, Enums.ZOrderType.eDefault - 2)

    -- 可滑动背景
    -- self.mBackgrounds = {}
    -- self:addBackground({"hslj_30.jpg", "hslj_29.jpg", "hslj_29.jpg"}, 1)
    self:createMap()
    -- 创建固定光柱
    -- local sprite = ui.newSprite("smb_04.png")
    -- sprite:setPosition(200, 568)
    -- self.mParentLayer:addChild(sprite, Enums.ZOrderType.eDefault - 2)

    self:initUI()
end

local Item = {
	width = 600,
	height = 300,
}

function PvpLayer:createMap()
	if next(self.mBackgrounds) ~= nil then
		self.mMapLayout:removeFromParent()
		self.mMapLayout = nil
		self.mBackgrounds = {}
	end

	-- 可滑动背景
    self.mBackgrounds = {}
    self:addBackground({"hslj_30.jpg", "hslj_29.jpg", "hslj_29.jpg"}, 1)
end

-- 创建UI
function PvpLayer:initUI()
    -- 创建顶部资源栏和底部导航栏
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.eChallenge,
        topInfos = {
            ResourcetypeSub.eSTA,
            ResourcetypeSub.eDiamond,
            ResourcetypeSub.ePVPCoin,
        }
    })
    self:addChild(topResource, Enums.ZOrderType.eDefault + 4)

    local x = 585
    local y = 1040
    -- 创建退出按钮
    local backBtn = ui.newButton({
        normalImage = "c_29.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(x , y),
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(backBtn, Enums.ZOrderType.eDefault + 5)
    self.mCloseBtn = backBtn

    -- 排行按钮
    y = y - 100
    local RankBtn = ui.newButton({
        normalImage = "tb_16.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(x, y),
        clickAction = function()
            self:gotoRank()
        end
    })
    self.mParentLayer:addChild(RankBtn)

    -- 兑换按钮
    y = y - 100
    local exchangeBtn = ui.newButton({
        normalImage = "tb_27.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(x, y),
        clickAction = function()
            LayerManager.addLayer({
                name = "challenge.PvpCoinStoreLayer",
                data = {tag = 1, pvpInfo = self.mData},
                cleanUp = false,
            })
        end
    })

    self.mParentLayer:addChild(exchangeBtn)
    -- 保存按钮，引导使用
    self.exchangeBtn = exchangeBtn

    -- 小红点逻辑
    local function dealRedDotVisible(retDotSprite)
    	local redData = RedDotInfoObj:isValid(ModuleSub.ePVPShop)
		retDotSprite:setVisible(redData)
    end
    ui.createAutoBubble({parent = exchangeBtn, eventName = RedDotInfoObj:getEvents(ModuleSub.ePVPShop), refreshFunc = dealRedDotVisible})

    -- 布阵按钮
    y = y - 100
    local campBtn = ui.newButton({
        normalImage = "tb_11.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(x, y),
        clickAction = function()
            LayerManager.addLayer({
            	name = "team.CampLayer",
            	cleanUp = false,
            })
        end
    })

    self.mParentLayer:addChild(campBtn)

    y = y - 100
    local showStepBtn = ui.newButton({
        normalImage = "tb_126.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(x, y),
        clickAction = function()
            self:showStepView(false)
        end
    })
    self.mParentLayer:addChild(showStepBtn)

    -- 规则查看按钮
    y = y - 100
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(60, 1040),
        clickAction = function()
            local rulesData = {
            	[1] = TR("1.挑战华山论剑需要消耗气力"),
                [2] = TR("2.%d到%d级的玩家处于云台峰",ModuleSubModel.items[ModuleSub.eChallengeArena].openLv,
                	PvpStepRelation.items[2].needLv - 1),
                [3] = TR("  %d到%d级的玩家处于玉女峰", PvpStepRelation.items[2].needLv,
                	PvpStepRelation.items[3].needLv - 1),
                [4] = TR("  %d到%d级的玩家处于莲花峰", PvpStepRelation.items[3].needLv,
                	PvpStepRelation.items[4].needLv - 1),
                [5] = TR("  %d到%d级的玩家处于朝阳峰", PvpStepRelation.items[4].needLv,
                	PvpStepRelation.items[5].needLv - 1),
                [6] = TR("  %d到%d级的玩家处于落雁峰", PvpStepRelation.items[5].needLv,
                	PvpStepRelation.items[6].needLv - 1),
               	[7] =  TR(" %d级及以上的玩家处于华山之巅", PvpStepRelation.items[6].needLv),
                [8] = TR("3.玩家等级达到段位对应等级后，自动进入该段位，同时可在奖励兑换里领取相应的奖励"),
                [9] = TR("4.每日22:00结算豪侠榜段位奖励"),
                [10] = TR("5.挑战玉女峰及以上段位的玩家时，阵容至少需要上阵4个侠客"),
            }
            MsgBoxLayer.addRuleHintLayer(TR("规则提示"), rulesData)
        end
    })
    self.mParentLayer:addChild(ruleBtn)

    -- 加成
    local attrLabel = ConfigFunc:getMonthAddAttrStr(false)
    if attrLabel then
        attrLabel:setPosition(530, 220)
        self.mParentLayer:addChild(attrLabel)
    end
end

--- ===================== 信息显示 ========================
-- 显示所有信息
function PvpLayer:showInfo()
	-- 显示当前排名信息
	self:showRankInfo()

	-- 显示奖励信息
	-- self:showStepInfo()

	-- 显示玩家列表
	self:showPlayerList()

	-- 跳转
	if self.mGotoRank then
		self:gotoRank()
		self.mGotoRank = false
	end

	-- 显示首次排名奖励(新手引导时不显示)
    local _, _, eventID = Guide.manager:getGuideInfo()
    if eventID ~= 11607 then
	   self:showFirstReward()
    end
	if self.mIsFirstIn then
		self:showStepView(true)
		self.mIsFirstIn = false
	end
end

-- 显示当前排名信息
function PvpLayer:showRankInfo()
	-- 移除
	if self.mRankInfoLayout then
		self.mRankInfoLayout:removeFromParent()
	end

	local layout = cc.Node:create()
	layout:setPosition(530, 300)
	self.mParentLayer:addChild(layout)
	self.mRankInfoLayout = layout

	local bgSpriteTop = ui.newSprite("hslj_27.png")
	bgSpriteTop:setPosition(0, 220)
	bgSpriteTop:setScale(0.6)
	layout:addChild(bgSpriteTop)
	local myRankBg = ui.newScale9Sprite("dz_15.png",cc.size(180, 32))
	myRankBg:setPosition(0, 220)
	layout:addChild(myRankBg)

	local bgSpriteMid = ui.newScale9Sprite("hslj_26.png",cc.size(348, 330))
	bgSpriteMid:setPosition(0, 120)
	bgSpriteMid:setScale(0.6)
	layout:addChild(bgSpriteMid, -1)

	local bgSpriteBot = ui.newScale9Sprite("hslj_28.png", cc.size(348, 182))
	bgSpriteBot:setPosition(0, -10)
	bgSpriteBot:setScale(0.6)
	layout:addChild(bgSpriteBot)

	local myRankLabel = ui.newLabel({
		text = TR("我的排名: %d", self.mData.Rank),
		color = Enums.Color.eWhite,
		size = 18,
		outlineColor = Enums.Color.eBlack,
		outlineSize = 2,
		})
	myRankLabel:setPosition(0, 220)
	layout:addChild(myRankLabel)

	local stepLabel = ui.newLabel({
		text = TR("豪侠榜阶数: %s%d", "#9a3126", self.mData.HistoryMaxStep),
		color = cc.c3b(0x2b, 0x2a, 0x30),
		size = 20,
	})
	stepLabel:setPosition(0, 190)
	layout:addChild(stepLabel)

	local HisMaxLabel = ui.newLabel({
		text = TR("最高排名: %s%d", "#9a3126", self.mData.HistoryMaxRank),
		color = cc.c3b(0x2b, 0x2a, 0x30),
		size = 20,
	})
	HisMaxLabel:setPosition(0, 160)
	layout:addChild(HisMaxLabel)

	local lineSprite = ui.newSprite("hslj_21.png")
	lineSprite:setPosition(0, 145)
	layout:addChild(lineSprite)

	local castLabel = ui.newLabel({
		text = TR("单次消耗气力%s%d%s点", "#9a3126", 2, "#2b2a30"),
		color = cc.c3b(0x2b, 0x2a, 0x30),
		size = 20,
	})
	castLabel:setPosition(0, 130)
	layout:addChild(castLabel)

	local timeLabel = ui.newLabel({
		text = TR("%s结算奖励", os.date("%H:%M", self.mData.RewardTimeStart)),
		color = cc.c3b(0x2b, 0x2a, 0x30),
		size = 20,
	})
	timeLabel:setPosition(0, 105)
	layout:addChild(timeLabel)

	local tempStep = math.min(self.mData.HistoryMaxStep, PvpRankRewardRelation.items_count)
	local tempRank = math.min(self.mData.Rank, #PvpRankRewardRelation.items[tempStep])
	local reward = PvpRankRewardRelation.items[tempStep][tempRank]
	local playerLv = PlayerAttrObj:getPlayerInfo().Lv
	local rewardLabel = ui.newLabel({
		text = string.format("{%s}%d {%s}%s",
			Utility.getDaibiImage(ResourcetypeSub.ePVPCoin),
			Utility.numberWithUnit(reward.PVPCoin or 0),
			Utility.getDaibiImage(ResourcetypeSub.eGold),
			Utility.numberWithUnit(reward.rawGold * playerLv or 0)
		),
		color = cc.c3b(0x9a, 0x31, 0x26),
		size = 20,
	})
	rewardLabel:setPosition(0, 65)
	layout:addChild(rewardLabel)

	if self.mData.HistoryMaxStep < PvpRankRewardRelation.items_count then
		local rankRewardLabel = ui.newLabel({
			text = TR("排名达到第一或"),
			color = cc.c3b(0x2b, 0x2a, 0x30),
			size = 20,
		})
		rankRewardLabel:setPosition(0, 20)
		layout:addChild(rankRewardLabel)

		local lvRewardLabel = ui.newLabel({
			text = TR("等级达到%d可获得", PvpStepRelation.items[self.mData.HistoryMaxStep + 1].needLv),
			color = cc.c3b(0x2b, 0x2a, 0x30),
			size = 20,
		})
		lvRewardLabel:setPosition(0, -5)
		layout:addChild(lvRewardLabel)
	else
		local rankRewardLabel = ui.newLabel({
			text = TR("排名达到第一可获得"),	
			color = cc.c3b(0x2b, 0x2a, 0x30),
			size = 20,
		})
		rankRewardLabel:setPosition(0, 20)
		layout:addChild(rankRewardLabel)
	end

 	local bottomRank = #PvpRankFirstRewardRelation.items[self.mData.HistoryMaxStep]  --当前阶数最低奖励名次
    local rank = self.mData.HistoryMaxRank
    if self.mData.Rank >= bottomRank then  --排行超过最低奖励排名
        rank = bottomRank
    end

    local bottomRankData = Utility.analysisStrResList(PvpRankFirstRewardRelation.items[self.mData.HistoryMaxStep][rank].firstReward)
    local topRankData = Utility.analysisStrResList(PvpRankFirstRewardRelation.items[self.mData.HistoryMaxStep][1].firstReward)
    local num = topRankData[1].num - bottomRankData[1].num
	local daibiLabel = ui.newLabel({
		text = string.format("{%s} %d", Utility.getDaibiImage(bottomRankData[1].resourceTypeSub), num),
		color = cc.c3b(0x9a, 0x31, 0x26),
		size = 20,
	})
	daibiLabel:setPosition(0, -30)
	layout:addChild(daibiLabel)
end
--[[
[1] = cc.p(60,2800),
	[2] = cc.p(40,2550),
	[3] = cc.p(40,2250),
	[4] = cc.p(60,1700),
	[5] = cc.p(40,1450),
	[6] = cc.p(40,1150),
	[7] = cc.p(60,550),
	[8] = cc.p(40,300),
	[9] = cc.p(40,0),
	--]]
local TopCount = 3
local MapHeroPosList = {
	[1] = cc.p(-60,2750),
	[2] = cc.p(40,2500),
	[3] = cc.p(60,2250),
	[4] = cc.p(60,1900),
	[5] = cc.p(60,1680),
	[6] = cc.p(40,1430),
	[7] = cc.p(40,1150),
	[8] = cc.p(60,770),
	[9] = cc.p(40,530),
	[10] = cc.p(40,300),
	[11] = cc.p(40,0),
}

-- local MapHeroPosList = {
-- 	[1] = cc.p(40,0),
-- 	[2] = cc.p(40,300),
-- 	[3] = cc.p(40,530),
-- 	[4] = cc.p(60,770),
-- 	[5] = cc.p(40,1150),
-- 	[6] = cc.p(40,1430),
-- 	[7] = cc.p(60,1680),
-- 	[8] = cc.p(60,1900),
-- 	[9] = cc.p(60,2250),
-- 	[10] = cc.p(40,2500),
-- 	[11] = cc.p(-60,2750),
-- }

--获取玩家Index的接口
function PvpLayer:getPlayerIndex()
	local targetID = 7 -- 最上面能点到的人物ID
	for i,v in ipairs(self.mPlayerList) do
		if v.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then
			break
        elseif Utility.isEntityId(v.PlayerId) then
            targetID = i
		end
	end
	return targetID
end

-- 显示玩家列表
function PvpLayer:showPlayerList()
	if self.mPlayerListView then
		self.mPlayerListView:removeFromParent()
	end
    -- 保存玩家hero
    self.heroNodeList = {}
	self:mergeList()

	-- 内容容器
	local layout = ccui.Layout:create()
	layout:setContentSize(640, 3208)

	local alignRight
	-- 添加玩家
	local count = #self.mPlayerList

	-- -- 倒序
	-- local tempList = {}
	-- for i = #self.mPlayerList, 1, -1 do
	-- 	table.insert(tempList, self.mPlayerList[i])
	-- end

	for i, playerInfo in ipairs(self.mPlayerList) do
		if i%2 == 0 then
			alignRight = false
		else
			alignRight = true
		end
		if next(playerInfo) == nil then
			local yunEffect = self:createEmptyLayout(alignRight, i)
			yunEffect:setPosition(MapHeroPosList[i])
			layout:addChild(yunEffect)
		else
			local tempItem = self:createPlayerInfoLayout(playerInfo, alignRight, playerInfo.Rank <= TopCount, (count - i)*0.11, i)
			tempItem:setPosition(MapHeroPosList[i])
			layout:addChild(tempItem)
		end
	end

	-- 滑动容器
	local size = layout:getContentSize()
	local scrollView = ccui.ScrollView:create()
	scrollView:setContentSize(Item.width, 990)
	scrollView:setInnerContainerSize(cc.size(size.width, size.height))
	scrollView:setDirection(ccui.ScrollViewDir.vertical)
	scrollView:setScrollBarEnabled(false)
	scrollView:setPosition(0, 100)
	scrollView:addChild(layout)
	-- scrollView:setBounceEnabled(true)
	scrollView:getInnerContainer():setPosition(cc.p(0, 0))
	self.mParentLayer:addChild(scrollView, -1)
	self.mPlayerListView = scrollView

	self:scrollToItem(self.mSelfIndex)

	local prePosY = 0
	self.mPlayerListView:addEventListener(function(sender, eventType)
        if eventType == 9 then  --SCROLLING
            local nowPosY = self.mPlayerListView:getInnerContainer():getPositionY()
            -- print(nowPosY, "oooooooocccccccc")
            local moveY = nowPosY - prePosY
            if moveY ~= 0 then
                self:scrollBackgrounds(moveY)
            end

            prePosY = nowPosY
        end
    end)
end

local effectYunList = {
	"yun1",
	"yun2",
	"yun3",
}
-- 创建尾部空位信息
function PvpLayer:createEmptyLayout(alignRight, index)
	local layout = ccui.Layout:create()
	layout:setContentSize(Item.width, Item.height)
	local x = -20
	if alignRight then
		x = 200
	end
	local yunEffect = ui.newEffect({ 
		parent = layout,
        effectName = "effect_ui_huashanyun",
        position = cc.p(x, 85),
        loop = true,
        animation = effectYunList[index - 8],
        async = function ()

        end
        })
	-- yunEffect:setPosition(x, 85)
	-- layout:addChild(yunEffect)

	return layout
end

-- 显示玩家信息
function PvpLayer:createPlayerInfoLayout(playerInfo, alignRight, isTop, delay, index)
	local layout = ccui.Layout:create()
	layout:setContentSize(Item.width, Item.height)

	local x = 100
	local y = 40
	if alignRight then x = 320 end
	-- 英雄
	y = y + 45
	local figure
	local function clickFun()
		MqAudio.playEffect("sound_dianjikaizhan.mp3")
    	self:requestPVPFight(playerInfo)
	end 
    local function asyncExecuteGuide(index)
        -- 人物加载完成，触发新手引导
        local _, _, eventID = Guide.manager:getGuideInfo()
        if eventID == 11603 and index == self:getPlayerIndex() then
            self:executeGuide()
        end
    end
    local createIndex = index -- 创建序号
	if Utility.isEntityId(playerInfo.PlayerId) then
		-- 可用英雄形象
		local heroModelID
		if playerInfo.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then
			heroModelID = PlayerAttrObj:getPlayerInfo().HeadImageId
		else
			-- heroModelID = playerInfo.SlotHeroModelIdList[1].ModelId HeadImageId
			heroModelID = playerInfo.HeadImageId
		end
		local IllusionModelId --幻化将特殊处理如果头像是幻化，改变创建的参数
		if Utility.getTypeByModelId(heroModelID) == ResourcetypeSub.eIllusion then
			IllusionModelId = heroModelID
			heroModelID = 0
		end
		figure = Figure.newHero({
	        parent = layout,
	        heroModelID = heroModelID,
	        fashionModelID = playerInfo.FashionModelId,
	        IllusionModelId = IllusionModelId, 
	        position = cc.p(x, y),
	        scale = 0.175,
	        async = function(figureNode)
                -- 保存形象结点, 引导使用
                self.heroNodeList[createIndex] = figureNode
                asyncExecuteGuide(createIndex)
	        end,
	        needRace = false,
	        buttonAction = function ()
	        	clickFun()
	        end
	    })
	else
		figure = ui.newButton({
			normalImage = "c_36.png",
			clickAction = function ()
				clickFun()
	        end
		})
		figure:setScale(0.5)
		figure:setPosition(x, y + 110)
		layout:addChild(figure)
        -- 保存形象结点, 引导使用
        self.heroNodeList[createIndex] = figure
        asyncExecuteGuide(createIndex)
	end
    -- 文字信息
    local y = y + 85
    local node = self:createPlayerTextLayout(playerInfo, isTop)
    node:setSwallowTouches(false)
    node:setPosition(alignRight and x-285 or x, y)
    layout:addChild(node, 1)

    -- 可挑战标记
    local ifAllowRank = self:ifAllowRank(playerInfo)
    if ifAllowRank then
    	if Utility.isEntityId(playerInfo.PlayerId) and playerInfo.Rank > self.mData.Rank then
    		-- 对排名比自己低的玩家，可以连续战斗5次
    		local button = ui.newButton({
    			normalImage = "c_28.png",
    			text = TR("战5次"),
    			clickAudio = "sound_dianjikaizhan.mp3",
    			anchorPoint = cc.p(0.5, 1),
    			position = cc.p(alignRight and x-120 or x+170, y - 20),
    			clickAction = function()
    				self:requestPVPConFight(playerInfo)
    			end
    		})
    		layout:addChild(button, 1)
    	end

    	-- 可以挑战玩家的标识
    	-- local sprite = ui.newSprite("")
	    -- sprite:setPosition(alignRight and x+60 or x-55, 150)
	    -- layout:addChild(sprite, 1)
	end


	return layout
end
local rankPic = {
	"hslj_23.png",
	"hslj_22.png",
	"hslj_24.png"
}
-- 显示玩家文字信息
--[[
	params:
		playerInfo:玩家的信息
		isTop:是否为前3名
]]
function PvpLayer:createPlayerTextLayout(playerInfo, isTop)
	-- 父容器
	local layout = ui.newButton({
		normalImage = "",
		clickAction = function ()
			-- MqAudio.playEffect("sound_dianjikaizhan.mp3")
			-- self:requestPVPFight(playerInfo)
		end,
		size = cc.size(260, 92),
		anchorPoint = cc.p(0, 0),
	})


	-- 是否是自己
	local isSelf = playerInfo.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId")

	-- 背景
	local sprite = ui.newScale9Sprite(isSelf and "hslj_04.png" or "hslj_05.png", cc.size(210, 89))
	sprite:setAnchorPoint(1, 0.5)
	sprite:setPosition(260, 30)
	layout:addChild(sprite)

	-- 首次排名奖励
    local bottomRank = #PvpRankFirstRewardRelation.items[self.mData.HistoryMaxStep]  --当前阶数最低奖励名次
    local rank = self.mData.HistoryMaxRank
    if rank >= bottomRank then  --排行超过最大奖励排名
        rank = bottomRank
    end
    local targetRank = playerInfo.Rank
    if targetRank >= bottomRank then  --排行超过最大奖励排名
        targetRank = bottomRank
    end


    local bottomRankData = Utility.analysisStrResList(PvpRankFirstRewardRelation.items[self.mData.HistoryMaxStep][rank].firstReward)
    local topRankData = Utility.analysisStrResList(PvpRankFirstRewardRelation.items[self.mData.HistoryMaxStep][targetRank].firstReward)
    local daibiNum = topRankData[1].num - bottomRankData[1].num

    if daibiNum > 0 then
		local daibiSpriteLabel = ui.newLabel({
	    	text = TR("奖励:{%s}%s", Utility.getDaibiImage(ResourcetypeSub.eDiamond), daibiNum),
	    	color = cc.c3b(0xd3, 0xdd, 0xe4),
	    	size = 23,
	    	})
	    daibiSpriteLabel:setPosition(150, -10)
		daibiSpriteLabel:setScale(0.8)
	    layout:addChild(daibiSpriteLabel, 1)

	    sprite:setContentSize(210, 110)
	end

	-- 排名
	if playerInfo.Rank <= 3 then
		local rankLabel = ui.newSprite(rankPic[playerInfo.Rank])
		rankLabel:setPosition(160, (daibiNum > 0 and 65 or 55))
		layout:addChild(rankLabel)
	else
		local rankLabel = ui.newLabel({
			text = TR("排行: %d", playerInfo.Rank),
			color = (isSelf and cc.c3b(0x4b, 0x16, 0x30) or cc.c3b(0xd3, 0xdd, 0xe4)),
			size = 20,
			anchorPoint = cc.p(0.5, 0.5),
			x = 160,
			y = (daibiNum > 0 and 65 or 55),
		})
		layout:addChild(rankLabel)
	end

	if Utility.isEntityId(playerInfo.PlayerId) then
		-- 名望称号
		local titleNode = ui.createTitleNode(playerInfo.TitleId)
		if (titleNode ~= nil) then
			titleNode:setPosition(155, ((playerInfo.Rank <= 3) and 110 or 90))
			layout:addChild(titleNode)
		end
		
		-- 姓名等级
		local label = ui.newLabel({
			text = TR("等级%s:%s", playerInfo.Lv, playerInfo.Name),
			color = (isSelf and cc.c3b(0xff, 0xe6, 0x94) or cc.c3b(0xd3, 0xdd, 0xe4)),
			anchorPoint = cc.p(0.5, 0.5),
			size = 20,
			x = 160,
			y = (daibiNum > 0 and 30 or 30),
		})
		layout:addChild(label)

		-- 战力
		local label = ui.newLabel({
			text = string.format("{%s}%s","c_127.png", Utility.numberFapWithUnit(playerInfo.FAP)),
			color = (isSelf and cc.c3b(0xff, 0xe6, 0x94) or cc.c3b(0xd3, 0xdd, 0xe4)),
			anchorPoint = cc.p(0.5, 0.5),
			size = 23,
			x = 150,
			y = (daibiNum > 0 and 10 or 5),
		})
		label:setScale(0.8)
		layout:addChild(label)
	else
		-- 空位
		local label = ui.newLabel({
			text = TR("虚位以待"),
			color = cc.c3b(0xd3, 0xdd, 0xe4),
			size = 22,
			anchorPoint = cc.p(0.5, 0.5),
			x = 155,
			y = (daibiNum > 0 and 25 or 25),
		})
		layout:addChild(label)
	end
	
	return layout
end

-- 显示首次排名奖励
function PvpLayer:showFirstReward()
	local hasExtra = self.mExtraGetGameResource and table.nums(self.mExtraGetGameResource) ~= 0
	local hasBase = self.mBaseGetGameResourceList and table.nums(self.mBaseGetGameResourceList) ~= 0
	if hasExtra or hasBase then
        local text = TR("排名提升！恭喜你获得以下奖励：")
        if hasBase then text = TR("阶数提升！恭喜你获得以下奖励：") end
        Utility.performWithDelay(self.mParentLayer, function ()
            local noticeLayer = MsgBoxLayer.addGameDropLayer(
            	self.mBaseGetGameResourceList,
            	self.mExtraGetGameResource,
            	text,
            	TR("提示"),
                {{text = TR("确定"), clickAction = function(layerObj, btnObj)
                    LayerManager.removeLayer(layerObj)
                end},}
            )
            self.mExtraGetGameResource = nil
            self.mBaseGetGameResourceList = nil
            -- 保存首次奖励
            self.firstOkButton = noticeLayer:getBottomBtns()[1]
        end, 0.03)
    end
end

--- ===================== 操作相关 ========================
--
function PvpLayer:scrollToItem(index)
	if not self.mPlayerListView then
		return
 	end

	--
	local viewLength = self.mPlayerListView:getContentSize().height
	local totalLength = self.mPlayerListView:getInnerContainerSize().height
	local bottomLength = viewLength / 2
	local topLength = totalLength - bottomLength

	-- 计算位置
	local count = #self.mPlayerList - index + 1.7
	local length = Item.height * count
	if length < bottomLength then length = bottomLength end
	if length > topLength then length = topLength end

	-- 滑动英雄列表
	local percent = 100 - 100 * (length - bottomLength) / (totalLength - viewLength)
	self.mPlayerListView:scrollToPercentVertical(percent, 1.5 ,true)
end

--- ===================== 背景相关 ========================
-- 添加背景
local ViewHeight = 1136
function PvpLayer:addBackground(imgList, factor)
	-- 创建背景
	local layout = require("challenge.LieanerLayout").new()
	layout:setAnchorPoint(0.5, 0)
	layout:setPosition(320, 0)
	self.mMapLayout = layout

	for i, imgName in ipairs(imgList) do
		layout:addItem({node = ui.newSprite(imgName),})
	end

	-- 添加辅助变量
	layout.factor = factor
	self:caculateVariable(layout)

	-- 保存
	self.mParentLayer:addChild(layout, Enums.ZOrderType.eDefault - 2)
	table.insert(self.mBackgrounds, layout)
end

-- 计算辅助量
function PvpLayer:caculateVariable(layout)
	local x, y = layout:getPosition()
	-- 计算辅助变量
	layout.bottom = y
	layout.top = y + layout.mVariableLength
	local configs = layout:getItems()
	local count = #configs
	layout.uponBottom = layout.bottom -- 暂定
	layout.underTop = layout.top -- 暂定
end

-- 滑动所有背景
function PvpLayer:scrollBackgrounds(offset)
	for i, layout in ipairs(self.mBackgrounds) do
		self:scrollBackground(layout, offset / layout.factor)
	end
end

-- 滑动某个背景组
function PvpLayer:scrollBackground(layout, offset)
	local x, y = layout:getPosition()
	y = y + offset
	layout:setPosition(x, y)

	-- 辅助变量修正
	layout.bottom = layout.bottom + offset
	layout.top = layout.top + offset
	layout.uponBottom = layout.uponBottom + offset
	layout.underTop = layout.underTop + offset

	-- 判断是否循环
	-- local configs = layout:getItems()
	-- local count = #configs
	-- local fixY = 0
	-- if offset > 0 then
	-- 	-- 上滑
	-- 	if layout.uponBottom > 0 or layout.bottom > 0 then
	-- 		fixY = -configs[1].node:getContentSize().height
	-- 		layout:moveItem(1, count)
	-- 	end
	-- else
	-- 	-- 下滑
	-- 	if layout.underTop < ViewHeight or layout.top < ViewHeight then
	-- 		fixY = configs[count].node:getContentSize().height
	-- 		layout:moveItem(1, count)
	-- 	end
	-- end

	-- y = y + fixY
	-- layout:setPosition(x, y)
	self:caculateVariable(layout)
end

--- ===================== 数据相关 ========================
-- 修正列表顺序
function PvpLayer:sortList(list)
	table.sort(list, function (a, b)
		return a.Rank < b.Rank
	end)
end

-- 整合列表
function PvpLayer:mergeList()
	self.mPlayerList = {}

	-- 合并
	for i=1, TopCount do
		table.insert(self.mPlayerList, self.mData.TopRankList[i])
	end
	for i, playerInfo in ipairs(self.mData.RankList) do
		if playerInfo.Rank > TopCount then
			table.insert(self.mPlayerList, playerInfo)
		end
	end
	-- dump(self.mPlayerList, "mPlayerListmPlayerList")
	if #self.mPlayerList > 11 then
		for i =  #self.mPlayerList, 12 , -1 do
			table.remove(self.mPlayerList, i)
		end
	end
	if #self.mPlayerList < 11 then
		for i = #self.mPlayerList+1, 11 do
			table.insert(self.mPlayerList, {})
		end
	end

	local haveSelf = false
	local selfInfo
	for i, playerInfo in ipairs(self.mData.RankList) do
		if playerInfo.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then
			selfInfo = playerInfo
		end
	end
	for i, playerInfo in ipairs(self.mPlayerList) do
		if playerInfo.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then
			haveSelf = true
			break
		end
	end
	if not haveSelf then
		table.remove(self.mPlayerList, #self.mPlayerList)
		table.insert(self.mPlayerList, selfInfo)
	end

	-- 找自己
	for i, playerInfo in ipairs(self.mPlayerList) do
		if playerInfo.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then
			self.mSelfIndex = i
			return
		end
	end

	if not self.mSelfIndex then
		self.mSelfIndex = #self.mPlayerList
	end
end

-- 判断是否可以挑战
function PvpLayer:ifAllowRank(playerInfo)
	-- 是自己
	if playerInfo.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then
		return false, TR("无法挑战自己")
	end

	-- 比自己排名低的空位
	if not Utility.isEntityId(playerInfo.PlayerId) and playerInfo.Rank > self.mData.Rank then
		return false, TR("无法挑战排名低的空位")
	end

	-- 是否在挑战列表中
	for key, value in ipairs(self.mData.RankList) do
		if playerInfo.PlayerId ==  value.PlayerId and playerInfo.Rank ==  value.Rank then
			return true
		end
	end


	return false, TR("当前排名无法挑战该玩家")
end

-- 数据恢复的保存
function PvpLayer:getRestoreData()
	return {
		gotoRank = self.mGotoRank,
		data = self.mData,
		isFirstIn = self.mIsFirstIn,
		extraGetGameResource = self.mExtraGetGameResource,
	}
end

--- ===================== 请求服务器 ========================
-- 跳转
function PvpLayer:gotoRank()
	LayerManager.addLayer({
        name = "challenge.PvpRankLayer",
        data = {pvpInfo = self.mData, parent = self},
        cleanUp = false,
    })
end

--- ===================== 请求服务器 ========================
-- PVP信息
function PvpLayer:requestGetPVPInfo()
	HttpClient:request({
    	moduleName = "PVP",
    	methodName = "GetPVPInfo",
    	callback = function(response)
    	    if response.Status ~= 0 then 
    	    	return 
    	    	LayerManager.removeLayer(self)
    	    end

	        self.mData = response.Value
	        self.mBaseGetGameResourceList = response.Value.BaseGetGameResourceList
	        self:showInfo()

            -- 执行新手引导
            self:executeGuide()
    	end
	})
end

-- 挑战请求
function PvpLayer:requestPVPFight(playerInfo)
	-- 判断排名能否挑战
	local ifAllowRank, text = self:ifAllowRank(playerInfo)
	if not ifAllowRank then
		ui.showFlashView(text)
		return
	end
	
	-- 检查气力
	if not Utility.isResourceEnough(ResourcetypeSub.eSTA, 2, true) then
        -- 引导时如遇气力不足，则停止引导
        local _, _, eventID = Guide.manager:getGuideInfo()
        if eventID == 11603 then
            Guide.helper:guideError(eventID, -1)
        end
        return
    end
    -- dump(playerInfo)
	HttpClient:request({
    	moduleName = "PVP",
    	methodName = "PVPFight",
        guideInfo = Guide.helper:tryGetGuideSaveInfo(11603),
    	svrMethodData = {playerInfo.PlayerId, playerInfo.Rank},
    	callback = function(response)
            local _, _, eventID = Guide.manager:getGuideInfo()
    	    if response.Status ~= 0 then 
                -- 如挑战失败，则跳过引导
                if eventID == 11603 then
                    Guide.helper:guideError(eventID, -1)
                end
                return 
            end
            --[[--------新手引导--------]]--
            if eventID == 11603 then
                Guide.manager:removeGuideLayer()
                Guide.manager:nextStep(eventID)
            end

    	    -- 保存额外掉落
    	    self.mExtraGetGameResource = response.Value.ExtraGetGameResource

    	    -- 之前阶数
    	    local oldStep = self.mData.HistoryMaxStep
    	    if not response.Value.RankList then
    	    	-- 没有新玩家列表
    	    	response.Value.RankList = self.mData.RankList

    	    	local oldRank = self.mData.Rank
    	    	local newRank = response.Value.Rank
    	    	if newRank ~= oldRank then
    	    		-- 修正对手Rank
    	    		playerInfo.Rank = oldRank
    	    		-- 修正自己Rank
    	    		self.mPlayerList[self.mSelfIndex].Rank = newRank
    	    	end

    	    	-- 修正顺序
    	    	self:sortList(response.Value.RankList)
    	    end
    	    table.merge(self.mData, response.Value)

    	    if not Utility.isEntityId(playerInfo.PlayerId) then
    	    	ui.showFlashView(TR("成功抢到空位：运气也是实力的一部分！"))
    	    	self:createMap()
    	    	self:showInfo()
    	    	return
    	    end

    	    --如果进阶
    	    if oldStep ~= response.Value.HistoryMaxStep then
    	    	self.mData = nil
    	    end

	        -- 进入战斗页面
            local value = response.Value
            -- 战斗页面控制信息
            local controlParams = Utility.getBattleControl(ModuleSub.eChallengeArena)
            -- 调用战斗页面
            LayerManager.addLayer({
                name = "ComBattle.BattleLayer",
                data = {
                    data = value.FightInfo,
                    skip = controlParams.skip,
                    trustee = controlParams.trustee,
                    skill = controlParams.skill,
                    map = Utility.getBattleBgFile(ModuleSub.eChallengeArena),
                    callback = function(retData)
                        PvpResult.showPvpResultLayer(
                            ModuleSub.eChallengeArena,
                            value,
                            {
                                PlayerName = PlayerAttrObj:getPlayerAttrByName("PlayerName"),
                                FAP = PlayerAttrObj:getPlayerAttrByName("FAP"),
                            },
                            {
                                PlayerName = playerInfo.Name,
                                FAP = playerInfo.FAP,
                                PlayerId = playerInfo.PlayerId,
                            }
                        )

                        if controlParams.trustee and controlParams.trustee.changeTrusteeState then
                            controlParams.trustee.changeTrusteeState(retData.trustee)
                        end
                    end
                },
            })
    	end
	})
end

-- 连战请求
function PvpLayer:requestPVPConFight(playerInfo)
	-- 检测气力值可连战的次数
	if not Utility.isResourceEnough(ResourcetypeSub.eSTA, 10, true) then
		return
	end
	-- local count = math.floor(PlayerAttrObj:getPlayerAttr(ResourcetypeSub.eSTA) / 2)
	-- if count > 5 then
	-- 	count = 5
	-- else
	-- 	MsgBoxLayer.addGetStaOrVitHintLayer(ResourcetypeSub.eSTA, 2)
 --        return
	-- end

	local count = 5
	HttpClient:request({
		moduleName = "PVP",
		methodName = "PVPConFight",
		svrMethodData = {playerInfo.PlayerId, playerInfo.Rank, count},
		callback = function(response)
			if not response or response.Status ~= 0 then
				return
			end

			LayerManager.addLayer({
                name = "challenge.PvpConFightResultLayer",
                data = {
                    data = response.Value,
                },
                cleanUp = false,
            })
		end
	})
end

-- ========================== 新手引导 ===========================
-- 执行新手引导
function PvpLayer:executeGuide()
    local _, _, eventID = Guide.manager:getGuideInfo()
    if eventID == 11603 then
        Guide.manager:showGuideLayer({})
        local selfId = self:getPlayerIndex()
        if self.heroNodeList[selfId] then
            Utility.performWithDelay(self.mParentLayer, function()
                self.mPlayerListView:setTouchEnabled(false)
                -- 指向挑战的人物
                Guide.helper:executeGuide({
                    [11603] = {clickNode = self.heroNodeList[selfId].button, hintPos = cc.p(display.cx, 240 * Adapter.MinScale)},
                })
            end, 0.45)
        end
    else
        Guide.helper:executeGuide({
            -- 指向兑换
            [11607] = {clickNode = self.exchangeBtn},
        })
    end
end

return PvpLayer

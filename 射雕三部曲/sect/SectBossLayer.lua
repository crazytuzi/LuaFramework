--[[
    文件名：SectBossLayer.lua
    文件描述：门派boss主界面
    创建人：lengjiazhi
    创建时间：2017.11.17
]]
local SectBossLayer = class("SectBossLayer",function()
    return display.newLayer()
end)

function SectBossLayer:ctor()
	self.mSelectTag = 1
	self.mFightType = 1
	self.mDirection = true --游标方向， true为向右，false为向左
    self.mPopScreenList = {}
    self.mPopIndex = 1
    self.mOhterPlayerList = {}
    self.mIsFighting = false
    self.mNewPlayerInfo = {}
    self.mPlayerIndex = 1
    self.mSpaceTime = 5

	self:initUI()
end

function SectBossLayer:initUI()
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	local bgSprite = ui.newSprite("mjrq_15.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

   	-- 创建顶部资源栏和底部导航栏
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        -- currentLayerType = Enums.MainNav.eChallenge,
        topInfos = {
            ResourcetypeSub.eSTA,
            ResourcetypeSub.eDiamond,
            ResourcetypeSub.eGold
        }
    })
    self:addChild(topResource, 4)

	--关闭按钮
    local cancelBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(600, 1050),
        clickAction = function ()
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(cancelBtn, 1)

    -- 设置规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        -- anchorPoint = cc.p(0.5, 1),
        position = cc.p(500, 1050),
        clickAction = function()
            MsgBoxLayer.addRuleHintLayer(TR("规则"),
            {
                [1] = TR("1.魔教入侵玩法每天中午12点开启，达到48级的玩家即可参与。"),
                [2] = TR("2.魔教会随机出现在八大门派的探索地图中，请前往寻找并击退。"),
                [3] = TR("3.出击时，三角标记越靠近中心光点区域，伤害加成越高。"),
                [4] = TR("4.魔教被击退后或逃跑后，将通过领奖中心发放个人和帮派伤害的排行奖励。"),
                [5] = TR("5.魔教被击退后，会掉落稀有物品，所有玩家都可在拍卖行竞拍这些物品。"),
                [6] = TR("6.拍卖行将在魔教被击退后的5分钟内开启。"),
                [7] = TR("7.如果魔教在12:30之前未被击退则会逃跑，不会掉落稀有物品。"),
            })
        end})
    self.mParentLayer:addChild(ruleBtn, 1)

    self:requestGetBossInfo()
    self:createTopView()
end

--创建顶部按钮
function SectBossLayer:createTopView()
	local underBg = ui.newScale9Sprite("dz_01.png", cc.size(640, 173))
	underBg:setPosition(320, 1075)
	self.mParentLayer:addChild(underBg)

	--排行奖励
	local rankRewardBtn = ui.newButton({
		normalImage = "mjrq_16.png",
		clickAction = function ()
			LayerManager.addLayer({
                    name = "sect.SectBossRankLayer",
                    cleanUp = false,
                })
		end
		})
	rankRewardBtn:setPosition(55, 1040)
	self.mParentLayer:addChild(rankRewardBtn)

	--掉落预览
	local dropViewBtn = ui.newButton({
		normalImage = "mjrq_22.png",
		clickAction = function ()
            self:showRewardLayer(self.mWorldBossModelID)
		end
		})
	dropViewBtn:setPosition(160, 1040)
	self.mParentLayer:addChild(dropViewBtn)

end

--====================================排行榜相关=====================================
--排行榜
function SectBossLayer:createRankView()
    -- 排行榜背景
    local rankListBgSize = cc.size(640, 420)
    local rankListBgSprite = ui.newScale9Sprite("wldh_01.png", rankListBgSize)
    rankListBgSprite:setAnchorPoint(cc.p(0.5, 1))
    rankListBgSprite:setPosition(320, 520)
    self.mParentLayer:addChild(rankListBgSprite)

    local titleSprite = ui.newSprite("mjrq_23.png")
    titleSprite:setPosition(320, 390)
    rankListBgSprite:addChild(titleSprite)

        -- 创建listView父对象
    local tempListView = ccui.ListView:create()
    tempListView:setDirection(ccui.ScrollViewDir.vertical)
    tempListView:setBounceEnabled(true)
    tempListView:setContentSize(cc.size(580, 200))
    tempListView:setTouchEnabled(false)
    tempListView:setGravity(ccui.ListViewGravity.centerVertical)
    tempListView:setItemsMargin(0)
    tempListView:setAnchorPoint(cc.p(0.5, 1))
    tempListView:setPosition(cc.p(rankListBgSize.width * 0.5, rankListBgSize.height * 0.76))
    tempListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    rankListBgSprite:addChild(tempListView)
    self.mTempListView = tempListView

    local tabInfo = {
    	{
	    	text = TR("个人"),
	        tag = 1,
    	},
    	{
	    	text = TR("帮派"),
	        tag = 2,
    	},
	}

	local tabLayer = ui.newTabLayer({
        btnInfos = tabInfo,
        isVert = false,
        space = 5,
        needLine = true,
        viewSize = cc.size(580, 80),
        btnSize = cc.size(100, 45),
        defaultSelectTag = defaultTag,
        allowChangeCallback = function (btnTag)
            return true
        end,
        onSelectChange = function (selectBtnTag)
            self.mSelectTag = selectBtnTag
            self:refreshRankList(self.mSelectTag)
        end
    })
    tabLayer:setAnchorPoint(cc.p(0.5, 0))
    tabLayer:setPosition(cc.p(rankListBgSize.width * 0.5, rankListBgSize.height * 0.78))
    rankListBgSprite:addChild(tabLayer, 1)

    local fightBossBtn = ui.newButton({
    	text = TR("出击"),
    	normalImage = "c_28.png",
    	size = cc.size(100, 45),
    	clickAction = function(pSender)
            -- pSender:setEnabled(false)
    		self:fightBossCallback()
    	end
    	})
    fightBossBtn:setPosition(320, 45)
    rankListBgSprite:addChild(fightBossBtn)
    self.mFightBossBtn = fightBossBtn
end

--创建个人排行条目
function SectBossLayer:createItemCellPerson(data)
	local tempSize = cc.size(580, 40)
	local layout = ccui.Layout:create()
	layout:setContentSize(tempSize)

	if data.Rank%2 == 1 then
		local tempBg = ui.newScale9Sprite("wldh_02.png", cc.size(550, 40))
        tempBg:setAnchorPoint(cc.p(0.5, 0.5))
        tempBg:setPosition(cc.p(tempSize.width * 0.5, tempSize.height * 0.5))
        layout:addChild(tempBg)
    end
    local textColor = self:getLabelColor(data.Rank)

    -- 排名
    local rankLabel = ui.newLabel({
        text = data.Rank,
        color = textColor,
        align = ui.TEXT_ALILGN_CENTER,
    })
    rankLabel:setAnchorPoint(cc.p(0.5, 0.5))
    rankLabel:setPosition(cc.p(40, tempSize.height * 0.5))
    layout:addChild(rankLabel)

    -- 前三名显示圆圈
    if data.Rank <= 3 then
        local picName = nil
        if data.Rank == 1 then
            picName = "c_44.png"
        elseif data.Rank == 2 then
            picName = "c_45.png"
        elseif  data.Rank == 3 then
            picName = "c_46.png"
        end

        local spr = ui.newSprite(picName)
        spr:setAnchorPoint(cc.p(0.5, 0.5))
        spr:setPosition(rankLabel:getPosition())
        layout:addChild(spr)
        spr:setScale(0.6)
    end

    -- 名字、积分
    local nameLabel = ui.newLabel({
        text = data.PlayerName,
        color = textColor,
    })
    nameLabel:setAnchorPoint(cc.p(0, 0.5))
    nameLabel:setPosition(cc.p(80, tempSize.height * 0.5))
    layout:addChild(nameLabel)

    local scoreLabel = ui.newLabel({
        text = TR("伤害:%s", Utility.numberWithUnit(data.Harm)),
        color = textColor,
    })
    scoreLabel:setAnchorPoint(cc.p(0, 0.5))
    scoreLabel:setPosition(cc.p(240, tempSize.height * 0.5))
    layout:addChild(scoreLabel)

    -- 帮派
    local tempName = (data.GuildName == "" or data.GuildName == nil) and TR("暂无帮派") or data.GuildName
    local guildNameLabel = ui.newLabel({
        text = tempName,
        color = textColor,
    })
    guildNameLabel:setAnchorPoint(cc.p(0.5, 0.5))
    guildNameLabel:setPosition(cc.p(460, tempSize.height * 0.5))
    layout:addChild(guildNameLabel)

	return layout
end

--创建帮派排行条目
function SectBossLayer:createItemCellGuild(data)
	local tempSize = cc.size(580, 40)
	local layout = ccui.Layout:create()
	layout:setContentSize(tempSize)

	if data.Rank%2 == 1 then
		local tempBg = ui.newScale9Sprite("wldh_02.png", cc.size(550, 40))
        tempBg:setAnchorPoint(cc.p(0.5, 0.5))
        tempBg:setPosition(cc.p(tempSize.width * 0.5, tempSize.height * 0.5))
        layout:addChild(tempBg)
    end
    local textColor = self:getLabelColor(data.Rank)

    -- 排名
    local rankLabel = ui.newLabel({
        text = data.Rank,
        color = textColor,
        align = ui.TEXT_ALILGN_CENTER,
    })
    rankLabel:setAnchorPoint(cc.p(0.5, 0.5))
    rankLabel:setPosition(cc.p(40, tempSize.height * 0.5))
    layout:addChild(rankLabel)

    -- 前三名显示圆圈
    if data.Rank <= 3 then
        local picName = nil
        if data.Rank == 1 then
            picName = "c_44.png"
        elseif data.Rank == 2 then
            picName = "c_45.png"
        elseif  data.Rank == 3 then
            picName = "c_46.png"
        end

        local spr = ui.newSprite(picName)
        spr:setAnchorPoint(cc.p(0.5, 0.5))
        spr:setPosition(rankLabel:getPosition())
        layout:addChild(spr)
        spr:setScale(0.6)
    end

    -- 等级
    local lvLabel = ui.newLabel({
        text = TR("等级:%s", data.Lv),
        color = textColor,
    })
    lvLabel:setPosition(cc.p(105, tempSize.height * 0.5))
    layout:addChild(lvLabel)

    -- 帮派名字
    local tempName = data.GuildName == "" and TR("暂无帮派") or data.GuildName
    local nameLabel = ui.newLabel({
        text = tempName,
        color = textColor,
    })
    nameLabel:setAnchorPoint(cc.p(0.5, 0.5))
    nameLabel:setPosition(cc.p(265, tempSize.height * 0.5))
    layout:addChild(nameLabel)

    -- 积分
    local scoreLabel = ui.newLabel({
        text = TR("伤害:%s", Utility.numberWithUnit(data.Harm)),
        color = textColor,
    })
    scoreLabel:setAnchorPoint(cc.p(0, 0.5))
    scoreLabel:setPosition(cc.p(400, tempSize.height * 0.5))
    layout:addChild(scoreLabel)

	return layout
end

--切换
function SectBossLayer:refreshRankList(tag)
	self.mTempListView:removeAllChildren()
	if self.mMyInfoView then
		self.mMyInfoView:removeFromParent()
		self.mMyInfoView = nil
	end
	if tag == 1 then
		for i,v in ipairs(self.mPersonalRankList) do
			self.mTempListView:pushBackCustomItem(self:createItemCellPerson(v))
		end
		self.mMyInfoView = self:createplayerItem()
		self.mMyInfoView:setPosition(320, 190)
		self.mParentLayer:addChild(self.mMyInfoView)
	elseif tag == 2 then
		for i,v in ipairs(self.mGuildRankList) do
			self.mTempListView:pushBackCustomItem(self:createItemCellGuild(v))
		end
		self.mMyInfoView = self:createplayerGuildItem()
		self.mMyInfoView:setPosition(320, 190)
		self.mParentLayer:addChild(self.mMyInfoView)
	end
end

--创建特殊条目(个人)
function SectBossLayer:createplayerItem()
	local tempSize = cc.size(580, 40)
	local layout = ccui.Layout:create()
	layout:setAnchorPoint(0.5, 0.5)
	layout:setContentSize(tempSize)

	local textColor = cc.c3b(0x46, 0x22, 0x0d)
	-- 排名
    local rankLabel = ui.newLabel({
        text = TR("我的排名：%s", self.mPlayerRank == 0 and TR("未上榜") or self.mPlayerRank),
        color = textColor,
        align = ui.TEXT_ALILGN_CENTER,
    })
    rankLabel:setAnchorPoint(cc.p(0, 0.5))
    rankLabel:setPosition(cc.p(35, tempSize.height * 0.5))
    layout:addChild(rankLabel)

    local scoreLabel = ui.newLabel({
        text = TR("伤害:%s", Utility.numberWithUnit(self.mPlayerHarm)),
        color = textColor,
    })
    scoreLabel:setAnchorPoint(cc.p(0, 0.5))
    scoreLabel:setPosition(cc.p(240, tempSize.height * 0.5))
    layout:addChild(scoreLabel)

    -- 帮派
    local guildInfo = GuildObj:getGuildInfo()

    local tempName = (guildInfo.Id == EMPTY_ENTITY_ID) and TR("暂无帮派") or guildInfo.Name
    local guildNameLabel = ui.newLabel({
        text = tempName,
        color = textColor,
    })
    guildNameLabel:setAnchorPoint(cc.p(0.5, 0.5))
    guildNameLabel:setPosition(cc.p(460, tempSize.height * 0.5))
    layout:addChild(guildNameLabel)

    return layout
end

--创建特殊条目(帮派)
function SectBossLayer:createplayerGuildItem()
    local guildInfo = GuildObj:getGuildInfo()
	local tempSize = cc.size(580, 40)
	local layout = ccui.Layout:create()
	layout:setAnchorPoint(0.5, 0.5)
	layout:setContentSize(tempSize)

	if guildInfo.Id == EMPTY_ENTITY_ID then
		tipLabel = ui.newLabel({
			text = TR("暂未加入帮派，请先加入帮派"),
			color = cc.c3b(0x46, 0x22, 0x0d),
			})
		tipLabel:setAnchorPoint(0.5, 0.5)
		tipLabel:setPosition(cc.p(290, tempSize.height * 0.5))
		layout:addChild(tipLabel)

		return layout
	end

	local textColor = cc.c3b(0x46, 0x22, 0x0d)
	-- 排名
    local rankLabel = ui.newLabel({
        text = TR("我的帮派排名：%s", self.mGuildRank == 0 and TR("未上榜") or self.mGuildRank),
        color = textColor,
        align = ui.TEXT_ALILGN_CENTER,
    })
    rankLabel:setAnchorPoint(cc.p(0.5, 0.5))
    rankLabel:setPosition(cc.p(140, tempSize.height * 0.5))
    layout:addChild(rankLabel)

    local scoreLabel = ui.newLabel({
        text = TR("伤害:%s", Utility.numberWithUnit(self.mGuildHarm)),
        color = textColor,
    })
    scoreLabel:setAnchorPoint(cc.p(0, 0.5))
    scoreLabel:setPosition(cc.p(350, tempSize.height * 0.5))
    layout:addChild(scoreLabel)

    return layout
end

--颜色
function SectBossLayer:getLabelColor(index)
    local color = nil
	if index == 1 then
        color = cc.c3b(0xff, 0xa2, 0x00)
    elseif index == 2 then
        color = cc.c3b(0x4a, 0x82, 0xa6)
    elseif index == 3 then
        color = cc.c3b(0xcd, 0x69, 0x42)
    elseif index == 0 then
        color = cc.c3b(0x42, 0x88, 0x1F)
    else
        color = cc.c3b(0x46, 0x22, 0x0d)
    end
    return color
end

--==============================战斗区域 ==============================
--创建boss
function SectBossLayer:createBoss()
	local bossInfo = WorldbossModel.items[self.mWorldBossModelID]

	--正面形象
    local bossFigure = ui.newEffect({
        parent = self.mParentLayer,
        anchorPoint = cc.p(0.5, 0.5),
        effectName = bossInfo.qpic,
        position = cc.p(485, 620),
        loop = true,
        endRelease = true,
        scale = 1.2
    })
    bossFigure:setRotationSkewY(180)
    bossFigure:setAnimation(0, "daiji", true)
    self.mBossFigure = bossFigure

    local underSprite = ui.newSprite("cdjh_13.png")
    underSprite:setPosition(0, -10)
    bossFigure:addChild(underSprite, -1)

    local nameLabel = ui.newLabel({
    	text = TR("%s 等级:%s", bossInfo.name, self.mBossLv),
    	size = 20,
    	outlineColor = Enums.Color.eOutlineColor,
    	})
    nameLabel:setPosition(320, 975)
    self.mParentLayer:addChild(nameLabel)

    local bossHpBar = require("common.ProgressBar"):create({
        bgImage = "zd_10.png",
        barImage = "zd_11.png",
        currValue = self.mBossCurrentHP,
        maxValue = self.mBossTotalHP,
        needLabel = true,
        percentView = false,
        size = 20,
        color = Enums.Color.eNormalWhite,
    })
    bossHpBar:setPosition(320, 943)
    self.mParentLayer:addChild(bossHpBar)
    local pos = cc.p(bossHpBar.mProgressLabel:getPosition())
    bossHpBar.mProgressLabel:setPosition(pos.x, pos.y + 5)
    self.mBossHpBar = bossHpBar

    -- 注册boss血量改变事件
    Notification:registerAutoObserver(self.mParentLayer, function(node, data)
        dump(data, "bossHPChanged")
        self.mBossHpBar:setCurrValue(data)
        if data <= 0 then
            self:bossDeath()
        end
    end, EventsName.eBossHpChanged)

    local timeLabel = ui.newLabel({
    	text = "00:00:00",
    	outlineColor = Enums.Color.eBlack,
    	size = 22,
    	})
    timeLabel:setPosition(567, 978)
    self.mParentLayer:addChild(timeLabel)
    self.mTimeLabel = timeLabel

    -- 刷新时间，开始倒计时
    if self.mSchelTime then
        self:stopAction(self.mSchelTime)
        self.mSchelTime = nil
    end
    self:updateTime()
    self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)


    --光条图片
    local lightLineSprite = ui.newSprite("mjrq_09.png")
    lightLineSprite:setPosition(320, 943)
    self.mParentLayer:addChild(lightLineSprite)

    --光条特效
    local lightLine = ui.newEffect({
    	parent = self.mParentLayer,
        anchorPoint = cc.p(0.5, 0.5),
        effectName = "effect_ui_guangtiao",
        animation = "guangtiao",
        position = cc.p(320, 931),
        loop = true,
        endRelease = true,
    	})

    local lightLineLizi = ui.newEffect({
    	parent = self.mParentLayer,
        anchorPoint = cc.p(0.5, 0.5),
        effectName = "effect_ui_guangtiao",
        animation = "tiaolizi",
        position = cc.p(320, 931),
        loop = true,
        endRelease = true,
    	})

    --游标箭头
    local arrow = ui.newSprite("mjrq_10.png")
    arrow:setPosition(320, 915)
    self.mParentLayer:addChild(arrow)
    self.mArrow = arrow

    self:createSchedule()
end

--玩家站位
local playerPos = {
	[1] = cc.p(80, 700),
	[2] = cc.p(75, 555),
	[3] = cc.p(185, 760),
	[4] = cc.p(200, 530),
	[5] = cc.p(260, 670),
}
--创建玩家形象
function SectBossLayer:createPlayers()
    if next(self.mOhterPlayerList) ~= nil then
        for i,v in ipairs(self.mOhterPlayerList) do
            v:stopAllActions()
            v:removeFromParent()
            v = nil
        end
    end
    self.mOhterPlayerList = {}

    local num = #self.mOtherPlayerInfo >= 4 and 4 or #self.mOtherPlayerInfo
	for i = 1, num do --取4个随机人物
	    local positivePic = QFashionObj:getQFashionLargePic(self.mOtherPlayerInfo[i].LeaderModelId)
		local playerFigure = ui.newEffect({
	        parent = self.mParentLayer,
	        anchorPoint = cc.p(0.5, 0.5),
	        effectName = positivePic,
	        position = playerPos[i],
	        loop = true,
	        endRelease = true,
	        scale = 0.7
	    })
	    playerFigure:setAnimation(0, "daiji", true)

	    local nameLabel = ui.newLabel({
	    	text = self.mOtherPlayerInfo[i].PlayerName,
	    	size = 24,
	    	outlineColor = Enums.Color.eBlack,
	    	})
	    nameLabel:setPosition(0, 200)
	    playerFigure:addChild(nameLabel)

	    local underSprite = ui.newSprite("cdjh_13.png")
	    underSprite:setPosition(0, -10)
	    playerFigure:addChild(underSprite, -1)

        table.insert(self.mOhterPlayerList, playerFigure)
	end
end

--创建自己
function SectBossLayer:createSelfView()
    local playerInfo = HeroObj:getMainHero()
    -- HeroQimageRelation.items[playerInfo.ModelId].positivePic
    local positivePic, backPic = QFashionObj:getQFashionByDressType()
    local myselfFigure = ui.newEffect({
            parent = self.mParentLayer,
            anchorPoint = cc.p(0.5, 0.5),
            effectName = positivePic,
            position = playerPos[5],
            loop = true,
            endRelease = true,
            scale = 0.7
        })
    myselfFigure:setAnimation(0, "daiji", true)

    local myNameLabel = ui.newLabel({
            text = PlayerAttrObj:getPlayerAttrByName("PlayerName"),
            size = 24,
            outlineColor = Enums.Color.eBlack,
            })
    myNameLabel:setPosition(0, 200)
    myselfFigure:addChild(myNameLabel)

    local myUnderSprite = ui.newSprite("cdjh_13.png")
    myUnderSprite:setPosition(0, -10)
    myselfFigure:addChild(myUnderSprite, -1)

    self.mMyselfFigure = myselfFigure
end

-- 更新时间
function SectBossLayer:updateTime()
    local timeLeft = self.mBossEndTime - Player:getCurrentTime()
    if timeLeft > 0 then
        self.mTimeLabel:setString(TR(MqTime.formatAsDay(timeLeft)))
    else
        self.mTimeLabel:setString(TR("00:00:00"))

        -- 停止倒计时
        if self.mSchelTime then
            self:stopAction(self.mSchelTime)
            self.mSchelTime = nil
        end

        LayerManager.removeLayer(self)
    end
end

--定时器
function SectBossLayer:createSchedule()
    local freshTime = 0
    local popTime = 2
    local fightTime = 0
    local bossAttackTime = 0
    self.mParentLayer:scheduleUpdate(function(dt)
    	local offsetX = 15
    	local pos = cc.p(self.mArrow:getPosition())
    	local newPosX
    	if self.mDirection then
    		newPosX = pos.x + offsetX
    		if newPosX >= 505 then -- 数值是根据图片设置的
    			self.mDirection = false
    		end
    	else
    		newPosX = pos.x - offsetX
    		if newPosX <= 138 then
    			self.mDirection = true
    		end
    	end
    	self.mArrow:setPosition(newPosX, pos.y)

        freshTime = freshTime + dt
        if freshTime >= 30 then
            freshTime = 0
            self:requestGetBossInfoForRefresh()
        end

        popTime = popTime + dt
        if popTime >= 2 then
            popTime = 0
            if next(self.mPopScreenList) ~= nil then
                if self.mPopIndex > #self.mPopScreenList then
                    self.mPopIndex = 1
                end
                self:createPopWord()
                self.mPopIndex = self.mPopIndex + 1
            end
        end

        fightTime = fightTime + dt
        if fightTime >= self.mSpaceTime then
            fightTime = 0
            if self.mPlayerIndex > #self.mOhterPlayerList then
                self:playerInfoChange()
                self.mPlayerIndex = 1
            end
            self:otherPlayerAttack()
            self.mPlayerIndex = self.mPlayerIndex + 1
        end

        bossAttackTime = bossAttackTime + dt
        if bossAttackTime >= 15 then
            self:bossAttack()
            bossAttackTime = 0
        end
    end)
end

--攻击回调
function SectBossLayer:fightBossCallback()
	local curPos = cc.p(self.mArrow:getPosition())
	if curPos.x >= 310 and curPos.x <= 330 then
		self.mFightType = 1
	elseif curPos.x >= 238 and curPos.x < 310 or curPos.x > 330 and curPos.x <= 405 then
		self.mFightType = 2
	else
		self.mFightType = 3
	end
    ui.newEffect({
        parent = self.mParentLayer,
        anchorPoint = cc.p(0.5, 0.5),
        effectName = "effect_ui_guangtiao",
        animation = "kuo",
        position = curPos,
        loop = false,
        endRelease = true,
        completeListener = function()
            ui.newEffect({
                parent = self.mParentLayer,
                anchorPoint = cc.p(0.5, 0.5),
                effectName = "effect_ui_guangtiao",
                animation = "kuo",
                position = curPos,
                loop = false,
                endRelease = true,
            })
        end
        })
	self:requestFightWorldBoss()
end

--战斗动作
function SectBossLayer:fightAction(node, isSelf)
    self.mIsFighting = true
    local targetPos = cc.p(405, 648)
    local startPos = cc.p(node:getPosition())
    local move = cc.MoveTo:create(0.1, targetPos)
    local pic
    if self.mFightType == 1 then
        pic = "mjrq_07.png"
    elseif self.mFightType == 2 then
        pic = "mjrq_06.png"
    elseif self.mFightType == 3 then
        pic = "mjrq_05.png"
    end

    local createFightTpye = cc.CallFunc:create(function()
        self.mHurtNode = cc.Node:create()
        self.mHurtNode:setPosition(470, 800)
        self.mParentLayer:addChild(self.mHurtNode, 10)

        local fightSprite = ui.newSprite(pic)
        fightSprite:setPosition(30, 50)
        self.mHurtNode:addChild(fightSprite)

        local hurtNumLabel = ui.newNumberLabel({
            text = self.mHurtNum,
            imgFile = "mjrq_08.png", -- 数字图片名
        })
        hurtNumLabel:setPosition(30, 0)
        self.mHurtNode:addChild(hurtNumLabel)

        local action = cc.Sequence:create({
            cc.ScaleTo:create(0.1, 1.2), 
            cc.ScaleTo:create(0.05, 1),
            cc.MoveBy:create(0.1, cc.p(0, 50))
            })
        self.mHurtNode:runAction(action)
    end)

    local callback = cc.CallFunc:create(function()
        node:setToSetupPose()
        SkeletonAnimation.action({
        skeleton = node,
        action = "pugong",
        loop = false,
        completeListener = function()
                local moveback = cc.MoveTo:create(0.3, startPos)
                local deleteFightType = cc.CallFunc:create(function()
                    self.mHurtNode:removeFromParent()
                    self.mHurtNode = nil
                end)
                if isSelf then
                    node:runAction(cc.Sequence:create(moveback, deleteFightType))
                else
                    node:runAction(moveback)
                end
                node:setToSetupPose()
                node:setAnimation(0, "daiji", true)
            end
        })
        self.mBossFigure:setToSetupPose()
            SkeletonAnimation.action({
            skeleton = self.mBossFigure,
            action = "aida",
            loop = false,
            completeListener = function()
                self.mBossFigure:setAnimation(0, "daiji", true)
            end
        })
        MqAudio.playEffect("shouji_Q.mp3")
        self.mIsFighting = false
    end)
    local sq
    if isSelf then
        sq = cc.Sequence:create(move, createFightTpye, callback)
    else
        sq = cc.Sequence:create(move, callback)
    end
    node:runAction(sq)
end

-- 更换按钮cd计时
function SectBossLayer:updateFightCD(lastTime, delayTime)
    if self.mRefreshCDBtn then
        self.mRefreshCDBtn:removeFromParent()
        self.mRefreshCDBtn = nil
    end
    local refreshCDBtn = ui.newButton({
        text = TR("消除冷却"),
        size = cc.size(100, 45),
        fontSize = 18,
        normalImage = "c_28.png",
        clickAction = function(pSender)
            if not Utility.isResourceEnough(ResourcetypeSub.eDiamond, 20) then
                return
            end
            self:requestResetFightCD()
        end
        })
    refreshCDBtn:setPosition(435, 145)
    self.mParentLayer:addChild(refreshCDBtn)
    self.mRefreshCDBtn = refreshCDBtn
    refreshCDBtn:setVisible(false)

    local priceLabel = ui.createLabelWithBg({
            bgFilename = "c_17.png",
            bgSize = cc.size(80, 35),
            labelStr = string.format("{%s}20", Utility.getDaibiImage(ResourcetypeSub.eDiamond)),
            fontSize = 20,
            outlineColor = Enums.Color.eOutlineColor,
            alignType = ui.TEXT_ALIGN_CENTER,    --  label X 方向与背景图的对齐方式(可选参数)，默认为左对齐(ui.TEXT_ALIGN_LEFT)
        })
    priceLabel:setPosition(135, 22.5)
    refreshCDBtn:addChild(priceLabel, -1)

    self.mFightBossBtn:setEnabled(false)
    local timer = lastTime - Player:getCurrentTime() + 1
    local tempTime = delayTime
    self.mChangeCdScheId = Utility.schedule(self.mFightBossBtn,
        function()
            timer = timer - 1
            self.mFightBossBtn:setTitleText(string.format("%s(s)", timer))
            if tempTime then
                tempTime = tempTime + 1
                if tempTime >= 3 then
                    refreshCDBtn:setVisible(true)
                end
            else
                refreshCDBtn:setVisible(true)
            end
            if timer <= 0 then
                self.mFightBossBtn:stopAction(self.mChangeCdScheId)
                self.mChangeCdScheId = nil
                refreshCDBtn:setVisible(false)
                self.mFightBossBtn:setTitleText(TR("出击"))

                self.mFightBossBtn:setEnabled(true)
            end
        end,
        1
    )
end

local randPic = {
    [1] = "mjrq_04.png",
    [2] = "mjrq_03.png",
    [3] = "mjrq_01.png",
    [4] = "mjrq_02.png",
} 
--弹幕
function SectBossLayer:createPopWord()
    local posR = math.random(570, 870)
    local pos = cc.p(640, posR)
    local popInfo = self.mPopScreenList[self.mPopIndex]
    local popLabel = ui.createLabelWithBg({
            bgFilename = popInfo.Rank <= 3 and randPic[popInfo.Rank] or randPic[4],
            labelStr = TR("%s 造成了%s%s%s伤害", popInfo.PlayerName, Enums.Color.eRedH, Utility.numberWithUnit(popInfo.Harm), Enums.Color.eNormalWhiteH),
            outlineColor = Enums.Color.eBlack,
            alignType = ui.TEXT_ALIGN_CENTER,
        })
    popLabel:setPosition(pos)
    self.mParentLayer:addChild(popLabel, 1)

    local move = cc.MoveBy:create(5 , cc.p(-640, 0))
    local removeFun = cc.CallFunc:create(function()
        popLabel:removeFromParent()
        popLabel = nil
    end)
    popLabel:runAction(cc.Sequence:create(move, removeFun))
end

--boss攻击
function SectBossLayer:bossAttack()
    self.mBossFigure:setToSetupPose()
    SkeletonAnimation.action({
    skeleton = self.mBossFigure,
    action = "nuji",
    loop = false,
    completeListener = function()
        self.mBossFigure:setAnimation(0, "daiji", true)
    end
    })
    local info = WorldbossModel.items[self.mWorldBossModelID].sound
    MqAudio.playEffect(info..".mp3")
end

--其他玩家攻击
function SectBossLayer:otherPlayerAttack()
    local node = self.mOhterPlayerList[self.mPlayerIndex]
    self.mSpaceTime = math.random(2, 5)
    if not tolua.isnull(node) then
        self:fightAction(node, false)
    end
end
--特殊刷新其他玩家
function SectBossLayer:playerInfoChange()
    if next(self.mNewPlayerInfo) ~= nil then
        self.mOtherPlayerInfo = self.mNewPlayerInfo
        self:createPlayers()
    end
end
--boss死亡的回调
function SectBossLayer:bossDeath()
    local deathTipSprite = ui.createLabelWithBg({
        bgFilename = "c_157.png",
        bgSize = cc.size(150, 60),       -- 背景图显示大小，默认为图片大小
        labelStr = TR("已击杀"),
        fontSize = 26,     -- 字体大小(可选参数), 默认为24
        outlineColor = nil, -- 显示字符串的描边颜色
        alignType = ui.TEXT_ALIGN_CENTER, 
        })
    deathTipSprite:setPosition(500, 700)
    deathTipSprite:setRotation(-30)
    self.mParentLayer:addChild(deathTipSprite)

    self.mParentLayer:unscheduleUpdate()
    self.mFightBossBtn:setEnabled(false)
    if self.mRefreshCDBtn then
        self.mRefreshCDBtn:setVisible(false)
    end
    if self.mChangeCdScheId then
        self.mFightBossBtn:stopAction(self.mChangeCdScheId)
        self.mChangeCdScheId = nil
    end
    --清除所有气泡
    RedDotInfoObj:setSocketRedDotInfo({[tostring(ModuleSub.eWorldBoss)] = {Default=false}})

    LayerManager.addLayer({
        name = "sect.SectBossRankLayer",
        cleanUp = false,
        })
end

function SectBossLayer:onExit()
    self.mParentLayer:unscheduleUpdate()
    self:requestQuitGlobalWorld()
end
--=============================================网络请求===============================
--请求信息
function SectBossLayer:requestGetBossInfo()
    HttpClient:request({
        moduleName = "WorldBossInfo",
        methodName = "GetWorldBossInfo",
        svrMethodData = {},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            -- dump(response)

            self.mPersonalRankList = response.Value.PersonalRankList
            self.mGuildRankList = response.Value.GuildRankList
            self.mPlayerRank = response.Value.PlayerRank
            self.mGuildRank = response.Value.GuildRank
            self.mPlayerHarm = response.Value.PlayerHarm
            self.mGuildHarm = response.Value.GuildHarm

            self.mWorldBossModelID = response.Value.WorldBossModelID
            self.mBossTotalHP = response.Value.BossTotalHP
            self.mBossCurrentHP = response.Value.BossCurrentHP
            self.mBossEndTime = response.Value.BossEndTime
            self.mBossLv = response.Value.Lv

            self.mOtherPlayerInfo = response.Value.OtherPlayerInfo
            table.insertto(self.mPopScreenList, response.Value.PopScreen.ScreenList)

            self.mNextChallengeTime = response.Value.NextChallengeTime
            if self.mBossCurrentHP <= 0 then
                ui.showFlashView(TR("魔教已被击退"))
                LayerManager.removeLayer(self)
            end
            if tolua.isnull(self) then
                return
            end
    		self:createRankView()
    		self:createBoss()
    		self:createPlayers()
            self:createSelfView()
            self:updateFightCD(self.mNextChallengeTime)
        end
    })
end

--请求攻击
function SectBossLayer:requestFightWorldBoss()
    HttpClient:request({
        moduleName = "WorldBossInfo",
        methodName = "FightWorldBoss",
        svrMethodData = {self.mFightType},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            self.mNextChallengeTime = response.Value.NextChallengeTime

            self.mPersonalRankList = response.Value.PersonalRankList
            self.mGuildRankList = response.Value.GuildRankList
            self.mPlayerRank = response.Value.PlayerRank
            self.mGuildRank = response.Value.GuildRank
            self.mPlayerHarm = response.Value.PlayerHarm
            self.mGuildHarm = response.Value.GuildHarm
            self.mHurtNum = response.Value.HurtNum

            self:refreshRankList(self.mSelectTag)

            self:updateFightCD(self.mNextChallengeTime, 0)
            self:fightAction(self.mMyselfFigure, true)

            -- dump(response.Value.NextChallengeTime)
        end
    })
end

--清除冷却cd
function SectBossLayer:requestResetFightCD()
    HttpClient:request({
        moduleName = "WorldBossInfo",
        methodName = "ResetFightCD",
        svrMethodData = {},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            self.mNextChallengeTime = response.Value.NextChallengeTime
            self.mRefreshCDBtn:setEnabled(false)
            
            Utility.performWithDelay(self, function ()
                self.mFightBossBtn:stopAction(self.mChangeCdScheId)
                self.mChangeCdScheId = nil
                self:updateFightCD(self.mNextChallengeTime)
            end, 0.3)

            -- dump(response.Value.NextChallengeTime)
        end
    })
end

--请求信息
function SectBossLayer:requestGetBossInfoForRefresh()
    HttpClient:request({
        moduleName = "WorldBossInfo",
        methodName = "GetWorldBossInfo",
        svrMethodData = {},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            self.mPersonalRankList = response.Value.PersonalRankList
            self.mGuildRankList = response.Value.GuildRankList
            self.mPlayerRank = response.Value.PlayerRank
            self.mGuildRank = response.Value.GuildRank
            self.mPlayerHarm = response.Value.PlayerHarm
            self.mGuildHarm = response.Value.GuildHarm

            -- self.mOtherPlayerInfo = response.Value.OtherPlayerInfo
            self.mNewPlayerInfo = response.Value.OtherPlayerInfo
            table.insertto(self.mPopScreenList, response.Value.PopScreen.ScreenList)

            self.mNextChallengeTime = response.Value.NextChallengeTime
            self:refreshRankList(self.mSelectTag)
            -- self:createPlayers()
            -- self:updateFightCD(self.mNextChallengeTime)
        end
    })
end

--退出世界boss
function SectBossLayer:requestQuitGlobalWorld()
    HttpClient:request({
        moduleName = "WorldBossInfo",
        methodName = "QuitGlobalWorld",
        svrMethodData = {},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
        end
    })
end

----------------------------------------------------------------------------------------------------
function SectBossLayer:showRewardLayer(bossId)
    local function msgDiyFunction(layer, layerBgSprite, layerSize)
        local bossInfo = WorldbossModel.items[bossId]
        -- 显示提示语
        local noticeLabel = ui.newLabel({
            text = TR("击杀 #D17B00%s%s 有几率掉落以下物品\n掉落物品要通过拍卖行竞拍获得", bossInfo.name, Enums.Color.eNormalWhiteH),
            size = 26,
            color = Enums.Color.eNormalWhite,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            dimensions = cc.size(469, 74),
            align = cc.TEXT_ALIGNMENT_CENTER,
            x = 302,
            y = 473,
        })
        layerBgSprite:addChild(noticeLabel)

        -- 黑色背景框
        local blackSize = cc.size(524, 324)
        local blackBg = ui.newScale9Sprite("c_38.png", blackSize)
        blackBg:setAnchorPoint(0.5, 0)
        blackBg:setPosition(layerSize.width/2, 100)
        layerBgSprite:addChild(blackBg)

        -- 计算掉落的内容
        local dropList = {}
        local shopGroup = AuctionShop.items[bossInfo.killedMeetRewardId]
        for _,v in ipairs(shopGroup) do
            table.insert(dropList, Utility.analysisStrResList(v.auctionGoods)[1])
        end
        -- dump(dropList, "dropList")
        table.sort( dropList, function (a, b)
            local qA = Utility.getQualityByModelId(a.modelId, a.resourceTypeSub)
            local qB = Utility.getQualityByModelId(b.modelId, b.resourceTypeSub)
            if qA ~= qB then
                return qA > qB
            end
            return a.modelId < b.modelId
        end )
        -- 创建滑动框
        local totalHeight = 142 * math.ceil(#dropList / 4)
        local worldView = ccui.ScrollView:create()
        worldView:setContentSize(cc.size(497, 299))
        worldView:setPosition(cc.p(12, 12))
        worldView:setDirection(ccui.ScrollViewDir.vertical)
        worldView:setInnerContainerSize(cc.size(497, totalHeight))
        blackBg:addChild(worldView)

        -- 显示掉落内容
        for i,v in ipairs(dropList) do
            local tempCard = CardNode.createCardNode({
                resourceTypeSub = v.resourceTypeSub,
                modelId = v.modelId,
                num = v.num,
                cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum, CardShowAttr.eName},
            })
            tempCard:setPosition(cc.p(((i - 1) % 4) * 125 + 63, totalHeight - math.floor((i - 1) / 4) * 142 - 60))
            worldView:addChild(tempCard)
        end
    end
    MsgBoxLayer.addDIYLayer({
        bgSize=cc.size(605, 597), 
        title=TR("掉落预览"), 
        closeBtnInfo={}, 
        DIYUiCallback = msgDiyFunction, 
        notNeedBlack=true
    })
end

return SectBossLayer
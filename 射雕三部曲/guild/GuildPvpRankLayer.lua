--[[
    文件名：GuildPvpRankLayer.lua
    描述：帮派战排行页面
    创建人：lengjiazhi
    创建时间：2018.1.9
--]]

local GuildPvpRankLayer = class("GuildPvpRankLayer", function(params)
    return display.newLayer()
end)

local pageTag = {
	person = 1,
	guild = 2,
	total = 3,
}

function GuildPvpRankLayer:ctor()
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	self.mRefreshLayer = ui.newStdLayer()
	self:addChild(self.mRefreshLayer)

	self.mSelectTag = 1
    self.mEndTime = nil
	self:initUI()
end

function GuildPvpRankLayer:initUI()
	local bgSprite = ui.newSprite("c_34.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	--返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(595, 1050),
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mCloseBtn = closeBtn
    self.mParentLayer:addChild(closeBtn, 10)

      -- 创建底部导航和顶部玩家信息部分
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)

 	-- 下方列表控件
    local tempListView = ccui.ListView:create()
    tempListView:setDirection(ccui.ScrollViewDir.vertical)
    tempListView:setBounceEnabled(true)
    tempListView:setContentSize(cc.size(640, 710))
    -- tempListView:setItemsMargin(5)
    tempListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    tempListView:setAnchorPoint(cc.p(0.5, 0))
    tempListView:setPosition(320, 154)
    self.mParentLayer:addChild(tempListView, 1000)
    self.mListView = tempListView

    self:createTabLayer()
end

--创建页签
function GuildPvpRankLayer:createTabLayer()
	local buttonInfos = {
		[1] = {
			tag = pageTag.person,
			text = TR("个人榜"),
        	fontSize = 20,
		},	
		[2] = {
			tag = pageTag.guild,
			text = TR("帮派榜"),
        	fontSize = 20,

		},
		[3] = {
			tag = pageTag.total,
			text = TR("帮派榜"),
        	fontSize = 20,
		},
	}

    local tabLayer = ui.newTabLayer({
        btnInfos = buttonInfos,
        viewSize = cc.size(640, 80),
        isVert = false,
        -- btnSize = cc.size(130, 65),
        space = 14,
        needLine = false,
        defaultSelectTag = 1,
        lightedImage = "c_50.png",
        normalImage = "c_51.png",
        allowChangeCallback = function(btnTag)
            return true
        end,
        onSelectChange = function(selectBtnTag)
        	self.mSelectTag = selectBtnTag
			self:requestGetInfo(selectBtnTag)
        end
    })
    tabLayer:setAnchorPoint(cc.p(0.5, 0))
    tabLayer:setPosition(320, 1005)
    self.mParentLayer:addChild(tabLayer)
    local tabBtns = tabLayer:getTabBtns()
    for i,v in ipairs(tabBtns) do
    	if v.tag == 3 then
    		local titleSprite = ui.newSprite("bpz_38.png")
    		titleSprite:setPosition(15, 45)
    		v:addChild(titleSprite)
    	else
    		local titleSprite = ui.newSprite("bpz_39.png")
    		titleSprite:setPosition(15, 45)
    		v:addChild(titleSprite)
    	end
    end

    --下方底板
    local underBgSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 1020))
    underBgSprite:setAnchorPoint(0.5, 0)
    underBgSprite:setPosition(320, 0)
    self.mParentLayer:addChild(underBgSprite)

    --灰色底板
    local grayBgSprite = ui.newScale9Sprite("c_17.png", cc.size(620, 720))
    grayBgSprite:setAnchorPoint(0.5, 0)
    grayBgSprite:setPosition(320, 150)
    self.mParentLayer:addChild(grayBgSprite)

    --排名信息背景板
    local rankBgSprite = ui.newScale9Sprite("c_25.png", cc.size(630, 50))
    rankBgSprite:setPosition(320, 120)
    self.mParentLayer:addChild(rankBgSprite)

    --倒计时背景板
    local rankBgSprite = ui.newScale9Sprite("c_25.png", cc.size(420, 50))
    rankBgSprite:setPosition(320, 960)
    self.mParentLayer:addChild(rankBgSprite)

    --空排行榜提示
    local emptySprite = ui.createEmptyHint(TR("暂无排行榜数据"))
    emptySprite:setPosition(320, 568)
    self.mParentLayer:addChild(emptySprite)
    self.mEmptySprite = emptySprite
    emptySprite:setVisible(false)

    --提示文字
    local tipLabel = ui.newLabel({
    	text = TR("            赛季结束发放帮派排行奖励\n只有个人积分大于300的玩家才能获得奖励"),
    	color = cc.c3b(0x46, 0x22, 0x0d),
    	size = 20,
    	})
    tipLabel:setPosition(320, 830)
    self.mParentLayer:addChild(tipLabel, 999)
    self.mTipLabel = tipLabel
    self.mTipLabel:setVisible(false)

    --倒计时
    local timeLabel = ui.newLabel({
        text = TR("赛季倒计时：%s%s", Enums.Color.eGoldH, "00:00:00"),
        outlineColor = Enums.Color.eOutlineColor,
        size = 22,
        })
    timeLabel:setPosition(320, 960)
    self.mParentLayer:addChild(timeLabel)
    self.mTimeLabel = timeLabel
end

--刷新下方显示
function GuildPvpRankLayer:refreshPages(tag)
	self.mRefreshLayer:removeAllChildren()
	local tempStr
	local rewardInfo
	if tag == pageTag.person then
		tempStr = TR("个人")
		rewardInfo = GuildbattleRankPersonRelation.items
	elseif tag == pageTag.guild then
		tempStr = TR("帮派")
		rewardInfo = GuildbattleRankGuildRelation.items
		
	elseif tag == pageTag.total then
		tempStr = TR("帮派")
		rewardInfo = GuildbattleRankWorldguildRelation.items
		
	end

	local changeBtn = {
		[1] = {
			tag = 4,
			text = TR("%s排行", tempStr),
			titlePosRateY = 0.5,
		},
		[2] = {
			tag = 5,
			text = TR("%s奖励", tempStr),
			titlePosRateY = 0.5,
		},	
	}

	local tabLayer = ui.newTabLayer({
        btnInfos = changeBtn,
        viewSize = cc.size(640, 80),
        isVert = false,
        btnSize = cc.size(161, 61),
        space = 100,
        needLine = false,
        defaultSelectTag = 4,
        lightedImage = "c_169.png",
        normalImage = "c_169.png",
        allowChangeCallback = function(btnTag)
            return true
        end,
        onSelectChange = function(selectBtnTag)
        	if selectBtnTag == 4 then
        		self:refreshRankList(self.mRankInfo)
        	else
        		self:refreshRewardList(rewardInfo)
        	end
        end
    })
    tabLayer:setAnchorPoint(cc.p(0, 0.5))
    tabLayer:setPosition(90, 905)
    self.mRefreshLayer:addChild(tabLayer)

    local curRankLabel = ui.newLabel({
    	text = TR("当前排名：%s%s", Enums.Color.eGoldH, self.mSelfRank.Rank == 0 and TR("未上榜") or self.mSelfRank.Rank),
    	outlineColor = Enums.Color.eOutlineColor,
    	})
    curRankLabel:setAnchorPoint(0, 0.5)
    curRankLabel:setPosition(80, 120)
    self.mRefreshLayer:addChild(curRankLabel)

    local curScoreLabel = ui.newLabel({
    	text = TR("积分：%s%s", Enums.Color.eGoldH, self.mSelfRank.Score),
    	outlineColor = Enums.Color.eOutlineColor,
    	})
    curScoreLabel:setAnchorPoint(0, 0.5)
    curScoreLabel:setPosition(380, 120)
    self.mRefreshLayer:addChild(curScoreLabel)
end

--二级页签刷新-排行
function GuildPvpRankLayer:refreshRankList(rankInfo)
	self.mListView:removeAllItems()
    self.mTipLabel:setVisible(false)
	self.mListView:setContentSize(640, 710)


	if self.mSelectTag ~= pageTag.person then
		self.mListView:setContentSize(640, 645)
    	self.mTipLabel:setVisible(true)
	end

	if next(rankInfo) == nil then
		self.mEmptySprite:setVisible(true)
	else
		self.mEmptySprite:setVisible(false)
	end

	for i,v in ipairs(rankInfo) do
		local layout = ccui.Layout:create()
		layout:setContentSize(600, 140)

		local bgSprite = ui.newScale9Sprite("c_18.png", cc.size(600, 136))
		bgSprite:setPosition(300, 70)
		layout:addChild(bgSprite)

		 -- 前三名显示圆圈
        if v.Rank <= 3 then
            local picName = nil
            if v.Rank == 1 then
                picName = "c_44.png"
            elseif v.Rank == 2 then
                picName = "c_45.png"
            elseif  v.Rank == 3 then
                picName = "c_46.png"
            end

            local spr = ui.newSprite(picName)
            spr:setAnchorPoint(cc.p(0.5, 0.5))
            spr:setPosition(65, 70)
            layout:addChild(spr)
            -- spr:setScale(0.6)
        else
            local rankNumLabel = ui.createSpriteAndLabel({
                imgName = "c_47.png",
                -- scale9Size = cc.size(69, 69),
                labelStr = v.Rank,
                fontColor = Enums.Color.eNormalWhite,
                -- outlineColor = Enums.Color.eOutlineColor,
                fontSize = 20
            })
            rankNumLabel:setPosition(cc.p(65, 70))
            layout:addChild(rankNumLabel)
        end

        if self.mSelectTag == pageTag.person then
        	-- 玩家头像
		    local header = CardNode.createCardNode({
		        resourceTypeSub = ResourcetypeSub.eHero,
		        fashionModelID = v.FashionModelId,
                IllusionModelId = v.IllusionModelId,
		        modelId = v.HeadImageId,
		        pvpInterLv = v.DesignationId,
		        cardShowAttrs = {CardShowAttr.eBorder},
		        allowClick = false,
		    })
		    header:setPosition(180, 70)
		    layout:addChild(header)

            local headImageId = v.HeadImageId
            if HeroFashionRelation.items[v.HeadImageId] then
                headImageId = HeroFashionRelation.items[v.HeadImageId].modelId
            end
    		local tempModel = HeroModel.items[headImageId] or IllusionModel.items[headImageId]

    		--名字
		    local nameLabel = ui.newLabel({
		        text = v.Name,
		        color = Utility.getQualityColor(tempModel.quality, 1),
		        outlineColor = cc.c3b(0x6b, 0x48, 0x2b), 
		        outlineSize = 2,
		        size = 24
		    })
		    nameLabel:setAnchorPoint(cc.p(0, 0.5))
		    nameLabel:setPosition(250, 95)
		    layout:addChild(nameLabel)

            -- vip等级
            local vipNode = ui.createVipNode(v.Vip)
            vipNode:setPosition(250+nameLabel:getContentSize().width + 5, 95)
            layout:addChild(vipNode)


	        -- 战斗力
		    local fapLabel = ui.newLabel({
		        text = TR("#46220d战斗力: #d17b00%s", Utility.numberFapWithUnit(v.Fap)),
		        size = 22
		    })
		    fapLabel:setAnchorPoint(cc.p(0, 1))
		    fapLabel:setPosition(250, 50)
		    layout:addChild(fapLabel)

	        -- 积分
		    local integralLabel = ui.newLabel({
		        text = TR("#46220d积分: #249029%s", v.Score),
		        size = 22
		    })
		    integralLabel:setAnchorPoint(cc.p(0, 1))
		    integralLabel:setPosition(420, 50)
		    layout:addChild(integralLabel)

        else
        	-- 帮派名字
		    local guideNameLabel = ui.newLabel({
		    	text = TR("%s", v.Name),
		        color = cc.c3b(0x46, 0x22, 0x0d),
		        size = 24,
		    })
		    guideNameLabel:setAnchorPoint(cc.p(0, 0.5))
		    guideNameLabel:setPosition(120, 100)
		    layout:addChild(guideNameLabel)

	        -- 积分、威望等级
		    local integralLabel = ui.newLabel({
		    	text = TR("积分：#249029%s", v.Score),
		        color = cc.c3b(0x46, 0x22, 0x0d),

			})
			integralLabel:setAnchorPoint(cc.p(0, 0.5))
			integralLabel:setPosition(cc.p(120, 40))
			layout:addChild(integralLabel)

            --区服信息
            local lvLabel = ui.newLabel({
                text = TR("等级：#ff974a%s 级", v.Lv),
                color = cc.c3b(0x46, 0x22, 0x0d),
                size = 24,
            })
            lvLabel:setAnchorPoint(cc.p(0, 0.5))
            lvLabel:setPosition(320, 40)
            layout:addChild(lvLabel)

            if self.mSelectTag == pageTag.total then
                --区服信息
                local zoneLabel = ui.newLabel({
                    text = TR("区服：#249029%s", v.ServerName),
                    color = cc.c3b(0x46, 0x22, 0x0d),
                    size = 24,
                })
                zoneLabel:setAnchorPoint(cc.p(0, 0.5))
                zoneLabel:setPosition(320, 100)
                layout:addChild(zoneLabel)
            end
        end

		self.mListView:pushBackCustomItem(layout)
	end
end

--二级页签刷新-奖励
function GuildPvpRankLayer:refreshRewardList(rewardInfo)
	self.mListView:removeAllItems()
	self.mEmptySprite:setVisible(false)
	self.mListView:setContentSize(640, 710)
    self.mTipLabel:setVisible(false)

	--处理表数据
	local reward = {}
	for k,v in pairs(rewardInfo) do
		for n,m in pairs(v) do
			table.insert(reward, m)
		end
	end
	table.sort(reward, function (a, b)
		if a.rankMin < b.rankMin then
			return true
		end
	end)
	for i,v in ipairs(reward) do
		local layout = ccui.Layout:create()
		layout:setContentSize(600, 140)

		local bgSprite = ui.newScale9Sprite("c_18.png", cc.size(600, 140))
		bgSprite:setPosition(300, 70)
		layout:addChild(bgSprite)


         -- 前三名显示圆圈
        if v.rankMin <= 3 then
            local picName = nil
            if v.rankMin == 1 then
                picName = "c_44.png"
            elseif v.rankMin == 2 then
                picName = "c_45.png"
            elseif  v.rankMin == 3 then
                picName = "c_46.png"
            end

            local spr = ui.newSprite(picName)
            spr:setAnchorPoint(cc.p(0.5, 0.5))
            spr:setPosition(65, 70)
            layout:addChild(spr)
            -- spr:setScale(0.6)
        else
            local rankNumLabel = ui.createSpriteAndLabel({
                imgName = "c_47.png",
                labelStr = string.format("%s~%s",v.rankMin, v.rankMax),
                fontColor = Enums.Color.eNormalWhite,
                fontSize = 20
            })
            rankNumLabel:setPosition(cc.p(65, 70))
            layout:addChild(rankNumLabel)
        end

        local tempRewardList = Utility.analysisStrResList(v.reward)

        --奖励列表
        local rewardList = ui.createCardList({
            maxViewWidth = 470,
            viewHeight = 120,
            space = 10,
            cardDataList = tempRewardList,
            allowClick = true, 
            isSwallow = false,
        })
        rewardList:setAnchorPoint(cc.p(0, 0.5))
        rewardList:setPosition(120, 70)
        layout:addChild(rewardList)

		self.mListView:pushBackCustomItem(layout)
	end
end

-- 更新时间
function GuildPvpRankLayer:updateTime()
    local timeLeft = self.mEndTime - Player:getCurrentTime()
    if timeLeft > 0 then
        self.mTimeLabel:setString(TR("赛季倒计时：%s%s", Enums.Color.eGoldH, MqTime.formatAsDay(timeLeft)))
        --print("更新时间")
    else
        self.mTimeLabel:setString(TR("赛季倒计时：%s%s", Enums.Color.eGoldH, "00:00:00"))

        -- 停止倒计时
        if self.mSchelTime then
            self:stopAction(self.mSchelTime)
            self.mSchelTime = nil
        end

        LayerManager.addLayer({
            name = "guild.GuildHomeLayer",
            })
    end
end

--========================================网络请求========================================
--请求排行信息
function GuildPvpRankLayer:requestGetInfo(tag)
    HttpClient:request({
        moduleName = "GuildbattleInfo",
        methodName = "GetRank",
        svrMethodData = {tag},
        callbackNode = self,
        callback = function (data)
            -- dump(data, "asdasd")
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            self.mRankInfo = data.Value.RankInfo
            self.mSelfRank = data.Value.SelfRank
        	self:refreshPages(tag)

            if not self.mEndTime then
                self.mEndTime = data.Value.EndTime
                -- 刷新时间，开始倒计时
                if self.mSchelTime then
                    self:stopAction(self.mSchelTime)
                    self.mSchelTime = nil
                end
                self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)
            end
        end
    })
end

return GuildPvpRankLayer

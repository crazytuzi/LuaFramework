--[[
	文件名：TeambattleMakeTeamLayer.lua
	描述：守卫襄阳界面
	创建人：yanxingrui
	创建时间： 2016.7.19
--]]
local TeambattleMakeTeamLayer = class("TeambattleMakeTeamLayer", function (params)
	return display.newLayer()
end)

-- 英雄对应位置
local heroPosition = {
    cc.p(320, 225),--前
    cc.p(540, 350),--中
    cc.p(100, 450)--后
}

local layoutWidth = 180
local layoutHeight = 270

function TeambattleMakeTeamLayer:ctor(params)
    self.mTeamInfo = params.teamInfo
    self.mNodeId = params.nodeId
	self.mdiffTag = params.diffTag

    ui.registerSwallowTouch({node = self})
    -- 战斗可否跳过
    self.FightSkep = false

	-- 发言的索引
	self.mChatIndex = 0

    -- 刷新标志
    self.mRefreshFlag = 5
    -- 聊天冷却时间标记
    self.choseRemainTime = 0
    -- 全服邀请冷却时间标记
    self.remainTime = 0
    -- 英雄剪影
    self.mHerobtns = {}
    -- 己方队伍3个节点
    self.mLayouts = {}
    -- 己方队伍战斗顺序
    self.mOrder = {}
	--存储人数
	self.mTotalMan = params.totalMan or 1
    for index, value in ipairs(self.mTeamInfo) do
        self.mOrder[value.FightOrder] = value
    end
    if params.crusadeInfo ~= nil and next(params.crusadeInfo) then
        for k, info in ipairs(params.crusadeInfo) do
            if info and next(info) then
                for _, v in ipairs(info) do
                    if v.NodeModelID == self.mNodeId and v.SuccessFightCount > 0 then
                        self.FightSkep = true
                        break
                    end
                end
            end
        end
    end
    -- 该页面的Parent
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 队伍信息layer
    self.mTeamLayer = display.newLayer()
    self.mParentLayer:addChild(self.mTeamLayer, 5)
    self.mTeamLayer:setLocalZOrder(5)

    -- 初始化页面控件
    self:initUI()

	-- 刷新队伍
    self:refreshTeamView()

    -- 定时器
    Utility.schedule(self, self.upTime, 1.0)
end

-- 定时函数
function TeambattleMakeTeamLayer:upTime()
    self.mRefreshFlag = self.mRefreshFlag - 1
    self.choseRemainTime = self.choseRemainTime - 1

    if self.mRefreshFlag <= 0 then
        self.mRefreshFlag = 2
        -- 获取组队信息
        self:getMyTeamInfo()
    end

    if not tolua.isnull(self.mChatBtn) then
        if self.choseRemainTime <= 0 then
            self.mChatBtn:setEnabled(true)
            -- 按钮改字
            self.mChatBtn:setTitleText(TR("发送"))
        else
            self.mChatBtn:setEnabled(false)
            -- 按钮改字
            self.mChatBtn:setTitleText(string.format("%s".."s", self.choseRemainTime))
        end
    end
end

-- 初始化页面控件
function TeambattleMakeTeamLayer:initUI()
    local node = TeambattleNodeModel.items[self.mNodeId]
    -- 背景
    local bgSprite = ui.newSprite("jsxy_05.jpg")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)

    -- 添加自删除事件
    bgSprite:registerScriptHandler(function(eventType)
        if eventType == "exit" and not self.mDisableAutoExit then
            --dump(self.mTeamInfo, "www")
            if self:isMeLeader() then
                -- print("dismissTeam")
                -- self:dismissTeam()
            else
                self:exitTeam()
            end
        elseif "enterTransitionFinish" == eventType and self.onEnterTransitionFinish then
            self:onEnterTransitionFinish()
            return
        end
    end)

    -- 推荐战力
    local faPSize = cc.size(438, 46)
    local FAPSprite = ui.newScale9Sprite("c_25.png", faPSize)
    FAPSprite:setPosition(320, 1050)
    self.mParentLayer:addChild(FAPSprite, 100)

	--难度标示
	local diffLabel = ui.newLabel({
		text = TR("关卡难度：#adff64%s", node.name),
		color = cc.c3b(0xff, 0xf6, 0xe6),
		outlineColor = cc.c3b(0x36, 0x24, 0x15),
		font = _FONT_PANGWA,
		outlineSize = 2,
		size = 24
	})
	diffLabel:setPosition(320, 1000)
	self.mParentLayer:addChild(diffLabel)


    -- 战力颜色
    local fapColor = "#adff64"
    if PlayerAttrObj:getPlayerAttrByName("FAP") < node.proposeFAP then
        fapColor = Enums.Color.eRedH
    end
    local recommendLabel = ui.newLabel({
        text = TR("推荐战力：%s个人战力达到%s%s", "#adff64", fapColor, Utility.numberFapWithUnit(node.proposeFAP)),
        color = cc.c3b(0xff, 0xf6, 0xe6),
        outlineColor = cc.c3b(0x36, 0x24, 0x15),
        font = _FONT_PANGWA,
        outlineSize = 2,
        size = 24
    })
    recommendLabel:setPosition(faPSize.width/2, faPSize.height/2-1)
    FAPSprite:addChild(recommendLabel)

    local tipText = ui.newLabel({
        size = 22,
        text = TR("拖动人物调整出战顺序"),
        font = _FONT_PANGWA,
        outlineColor = cc.c3b(0x21, 0x1b, 0x1b)
    })
    tipText:setPosition(320, 125)
    self.mParentLayer:addChild(tipText)

    -- 发送信息
    local sendMessageBtn = ui.newButton({
        normalImage = "tb_32.png",
        clickAction = function()
            self:choseSendMessage()
        end
    })
    sendMessageBtn:setPosition(60, 850)
    self.mParentLayer:addChild(sendMessageBtn)

    -- 如果自己是队长  则添加自动匹配和邀请组队按钮
    if self:isMeLeader() then
        -- 自动匹配按钮
        self.mPiPeiBtn = ui.newButton({
            text = TR("自动匹配"),
            normalImage = "c_28.png",
            outlineColor = cc.c3b(0x8e, 0x4f, 0x09),
            clickAction = function()
                self:fightForMatch()
            end
        })
        self.mPiPeiBtn:setPosition(320, 175)
        self.mParentLayer:addChild(self.mPiPeiBtn, 100)

        self.mYaoqingBtn = ui.newButton({
            normalImage = "tb_150.png",
            selectImage = "tb_150.png",
            clickAction = function(state)
                self:inviteAllClickAction()
            end
        })
        self.mYaoqingBtn:setPosition(60, 970)
        self.mParentLayer:addChild(self.mYaoqingBtn)

		--创建倒计时label
		self.sdTime = 15
		self.mTimeLabel = ui.newLabel({
			text = TR("%s", MqTime.formatAsDay(self.sdTime)),
			size = 20,
			color = Enums.Color.eNormalWhite,
			outlineColor = Enums.Color.eBlack,
			outlineSize = 1,
			anchorPoint = cc.p(0.5, 0),
		})
		self.mTimeLabel:setPosition(cc.p(self.mYaoqingBtn:getContentSize().width / 2, -25))
		self.mYaoqingBtn:addChild(self.mTimeLabel)
		self.mTimeLabel:setVisible(false)
    end

    -- 退出按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        position = Enums.StardardRootPos.eCloseBtn,
        clickAction = function(pSender)
            self:exitTeam()
        end
    })
    self.mParentLayer:addChild(self.mCloseBtn)

    -- 创建顶部资源
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {
            {
                resourceTypeSub = ResourcetypeSub.eFunctionProps,
                modelId = 16050023
            },
            ResourcetypeSub.eGold,
            ResourcetypeSub.eDiamond}
    })
    self:addChild(topResource)
end

-- 刷新队伍
function TeambattleMakeTeamLayer:refreshTeamView(ptype)
    self.mHerobtns = {}  -- 初始化

    if self.mTeamLayer then
        self.mTeamLayer:removeAllChildren()
    end

    -- 创建英雄
    self.mHeroes = {}
    self.mLayouts = {}
    -- 注册拖拽事件
    self.mFormationConfig = heroPosition
    self.mItems = self.mLayouts

    local currIndex = 0
    for k = 1, 3 do
        local info = self.mOrder[k]
        if info then
            if ptype == "pipei2" then
                if info.PlayerId ~= PlayerAttrObj:getPlayerAttrByName("PlayerId") then
                    currIndex = currIndex + 1
                    if currIndex == 2 then
                        print(heroPosition[info.FightOrder].x + 10,
                                heroPosition[info.FightOrder].y)
                        self.herobtn = ui.newButton({
                            normalImage = "c_36.png",
                            scale = 0.5,
                            position = cc.p(heroPosition[info.FightOrder].x, heroPosition[info.FightOrder].y + 140),
                            clickAction = function()
                            end
                        })
                        self.mTeamLayer:addChild(self.herobtn)

                        local actionArray = {}
                        table.insert(actionArray, cc.CallFunc:create(function()
                            local waitSprite = ui.newSprite("jsxy_23.png")
                            waitSprite:setPosition(cc.p(heroPosition[info.FightOrder].x, heroPosition[info.FightOrder].y + 140))
                            self.mTeamLayer:addChild(waitSprite)

                        --等待中动画
                        local a = cc.Animation:create()
                        a:addSpriteFrameWithFile("jsxy_23.png")
                        a:addSpriteFrameWithFile("jsxy_24.png")
                        a:addSpriteFrameWithFile("jsxy_25.png")

                        a:setDelayPerUnit(0.5)
                        local ani = cc.Animate:create(a)
                            waitSprite:runAction(cc.RepeatForever:create(ani))
                        end))
						table.insert(actionArray, cc.DelayTime:create(3))
                        table.insert(actionArray, cc.CallFunc:create(function()
                            self.herobtn:removeFromParent()
                            self:refreshTeamView()
                            -- 邀请界面自动战斗回来，执行新手引导
                            self:executeGuide()
                        end))
                        self:runAction(cc.Sequence:create(actionArray))
                    else
                        self:createAHero(info, info.FightOrder, "pipei2")
                    end
                else
                    self:createAHero(info, info.FightOrder)
                end
            else
                self:createAHero(info, info.FightOrder)
            end
        else
            local layout = ccui.Layout:create()
            layout:setContentSize(cc.size(layoutWidth, layoutHeight))
            layout:setAnchorPoint(cc.p(0.5, 0))
            layout:setPosition(heroPosition[k].x, heroPosition[k].y)
            self.mTeamLayer:addChild(layout)
            self.mLayouts[k] = layout
            layout.index = k
            self:registerDragTouch(layout, self.mTeamLayer)

            selBtn = ui.newButton({
                normalImage = "jsxy_06.png",
                position = cc.p(layoutWidth / 2, layoutHeight/2),
                -- scale = 0.5,
                clickAction = function()
                end
            })
            -- 图片浮动效果
            -- local moveAction1 = cc.MoveTo:create(1.3, cc.p(layoutWidth / 2, layoutHeight/2 + 10))
            -- local moveAction2 = cc.MoveTo:create(1.3, cc.p(layoutWidth / 2, layoutHeight/2 + 5))
            -- local moveAction3 = cc.MoveTo:create(1.3, cc.p(layoutWidth / 2, layoutHeight/2))
            -- selBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(
            --     cc.EaseSineIn:create(moveAction2),
            --     cc.EaseSineOut:create(moveAction1),
            --     cc.EaseSineIn:create(moveAction2),
            --     cc.EaseSineOut:create(moveAction3)
            -- )))

            table.insert(self.mHerobtns, selBtn)
            -- selBtn:setEnabled(false)
            layout:addChild(selBtn)
            --layout.click = function ()
            selBtn:setClickAction(function ()
                if self:isMeLeader() then
                    -- 邀请组队界面
                    LayerManager.addLayer({
                        name = "teambattle.TeambattleChooseTeamMateLayer",

                        data = {
                            copyID = self.mNodeId,
                            callback = function()
                                if self.remainTime > 0 then
                                    ui.showFlashView(TR("全服邀请冷却中"))
                                else
                                    self:inviteAllClickAction()
                                end
                            end,
                            callback2 = function()
                                self:fightForMatch()
                            end,
                        },
                        cleanUp = false,
                    })
                end
            end)

            if self:isMeLeader() then
                -- 邀请图片
                -- local yqSprite = ui.newSprite("ldtl_01.png")
                -- yqSprite:setPosition(165, 200)
                -- selBtn.yqSprite = yqSprite
                -- selBtn:addChild(yqSprite)
            else
                selBtn:setEnabled(false)
            end
        end
    end
    if self:isTeamOk() and self.mPiPeiBtn then
        if ptype == "pipei2" then
            self.mPiPeiBtn:setVisible(false)
        else
            self.mPiPeiBtn:setVisible(false)
            -- self.mSuperPiPeiBtn:setVisible(false)
            if self.mKaiZhanBtn ~= nil then
                self.mKaiZhanBtn:removeFromParent()
                self.mKaiZhanBtn = nil
            end
            self.mKaiZhanBtn = ui.newButton({
                text = TR("开始战斗"),
                normalImage = "c_28.png",
                position = cc.p(320, 172),
                outlineColor = cc.c3b(0x8e, 0x4f, 0x09),
                clickAction = function()
                    self:requestFight()
                end
            })
            self.mParentLayer:addChild(self.mKaiZhanBtn)
        end
    else
        if self:isMeLeader() then
            self.mPiPeiBtn:setVisible(true)
        end

        if self.mKaiZhanBtn ~= nil then
            self.mKaiZhanBtn:removeFromParent()
            self.mKaiZhanBtn = nil
        end
    end
end

-- 添加人物模型，区服，名字，战力标签
function TeambattleMakeTeamLayer:createAHero(info, k, ptype)
    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(layoutWidth, layoutHeight))
    layout:setAnchorPoint(cc.p(0.5, 0))
    layout:setPosition(heroPosition[k])
    self.mTeamLayer:addChild(layout,4)
    self.mLayouts[k] = layout

    layout.index = k
    self:registerDragTouch(layout, self.mTeamLayer)


	local fashionModel
	local figureName
    local heroView
    if ptype == "pipei2" then
		if info.FashionModelId ~= 0 then
			fashionModel = FashionModel.items[info.FashionModelId]
			figureName = fashionModel.actionPic
			heroView = Figure.newHero({
				fashionModelID = info.FashionModelId,
                IllusionModelId = info.IllusionModelId,
				figureName = fashionModel.actionPic,
				position = cc.p(layoutWidth / 2, 0),
				scale = 0.3,
				buttonAction = function()
					ui.showFlashView(TR("对不起,请等待匹配完成"))
				end
			})
		else
			heroView = Figure.newHero({
				heroModelID = info.HeadImageId,
				fashionModelID = info.FashionModelId,
                IllusionModelId = info.IllusionModelId,
				position = cc.p(layoutWidth / 2, 0),
				buttonAction = function()
				end
			})
		end
        layout:addChild(heroView)
    else
		if info.FashionModelId ~= 0 then
			fashionModel = FashionModel.items[info.FashionModelId]
			figureName = fashionModel.actionPic
			heroView = Figure.newHero({
				fashionModelID = info.FashionModelId,
                IllusionModelId = info.IllusionModelId,
				figureName = fashionModel.actionPic,
				position = cc.p(layoutWidth / 2, 0),
				scale = 0.3,
				buttonAction = function()
				end
			})
		else
			heroView = Figure.newHero({
				heroModelID = info.HeadImageId,
				fashionModelID = info.FashionModelId,
                IllusionModelId = info.IllusionModelId,
				position = cc.p(layoutWidth / 2, 0),
				buttonAction = function()
				end
			})
		end
        layout:addChild(heroView)
        -- 图片浮动效果
        -- local moveAction1 = cc.MoveTo:create(1.3, cc.p(layoutWidth / 2, 10))
        -- local moveAction2 = cc.MoveTo:create(1.3, cc.p(layoutWidth / 2, 5))
        -- local moveAction3 = cc.MoveTo:create(1.3, cc.p(layoutWidth / 2, 0))
        -- heroView:runAction(cc.RepeatForever:create(cc.Sequence:create(
        --     cc.EaseSineIn:create(moveAction2),
        --     cc.EaseSineOut:create(moveAction1),
        --     cc.EaseSineIn:create(moveAction2),
        --     cc.EaseSineOut:create(moveAction3)
        -- )))

		--人物满了
        if #self.mLayouts == #self.mOrder then
            if self.mRefreshTime then
                local actionArray = {}
                table.insert(actionArray, cc.DelayTime:create(self.mRefreshTime))
                table.insert(actionArray, cc.CallFunc:create(function()
                    self.mRefreshFlag = 5
                    if self.mSwallowLayer then
                        self.mSwallowLayer:removeFromParent()
                        self.mSwallowLayer = nil
                    end
                end))
                self:runAction(cc.Sequence:create(actionArray))
                self.mRefreshTime = nil
            end
        end
    end

    -- 如果是队长 给其他队员加一个剔除按钮
    if self:isMeLeader() then
        if info.PlayerId ~= PlayerAttrObj:getPlayerAttrByName("PlayerId") then
            -- 踢出图片
            local tcBtn = ui.newButton({
                normalImage = "jsxy_07.png",
                text = TR("踢出"),
                clickAction = function()
                    self:kickOutTeam(info.PlayerId)
                end
            })
            tcBtn:setScale(6)
            tcBtn:setPosition(cc.p(layoutWidth / 2, -85))
            heroView:addChild(tcBtn)
        end
    end

    if k == 1 then
        --前军
        local frontSprite = ui.createLabelWithBg({
            bgFilename = "jsxy_08.png",
            labelStr = TR("前\n军"),
            fontSize = 24,
            color = Enums.Color.eBlack,
            alignType = ui.TEXT_ALIGN_CENTER,
            offsetY = -5,
        })
        frontSprite:setPosition(layoutWidth - 160, layoutHeight/2)
        layout:addChild(frontSprite)
        heroView:setScale(0.15)
    end
    if k == 2 then
        --中军
        local frontSprite = ui.createLabelWithBg({
            bgFilename = "jsxy_08.png",
            labelStr = TR("中\n军"),
            fontSize = 24,
            color = Enums.Color.eBlack,
            alignType = ui.TEXT_ALIGN_CENTER,
            offsetY = -5,
        })
        frontSprite:setPosition(layoutWidth - 20, layoutHeight/2)
        frontSprite:setScale(0.9)
        layout:addChild(frontSprite)
        heroView:setScale(0.15)
    end
    if k == 3 then
        --后军
        local frontSprite = ui.createLabelWithBg({
            bgFilename = "jsxy_08.png",
            labelStr = TR("后\n军"),
            fontSize = 24,
            color = Enums.Color.eBlack,
            alignType = ui.TEXT_ALIGN_CENTER,
            offsetY = -5,
        })
        frontSprite:setPosition(layoutWidth - 160, layoutHeight/2)
        frontSprite:setScale(0.8)
        layout:addChild(frontSprite)
        heroView:setScale(0.15)
    end

    -- 名字标签
    if info.IsLeader ~= true  then
        local nameLabel = ui.createLabelWithBg({
            bgFilename = "c_25.png",
            bgSize = cc.size(316, 50),
            fontSize = 20,
            fontName = _FONT_PANGWA,
            labelStr = TR("等级%d %s",info.Lv, info.Name),
            color = cc.c3b(0xff, 0xf6,0xe6),
            outlineColor = cc.c3b(0x35, 0x22,0x14),
            outlineSize = 2,
            alignType = ui.TEXT_ALIGN_CENTER,
        })
        nameLabel:setPosition(layoutWidth / 2, 230)
        layout:addChild(nameLabel)
    else
        local nameLabel = ui.createLabelWithBg({
            bgFilename = "c_25.png",
            bgSize = cc.size(356, 50),
            fontSize = 20,
            fontName = _FONT_PANGWA,
            labelStr = TR("{jsxy_09.png}等级%d %s",info.Lv, info.Name),
            color = cc.c3b(0xff, 0xf6,0xe6),
            outlineColor = cc.c3b(0x35, 0x22,0x14),
            outlineSize = 2,
            alignType = ui.TEXT_ALIGN_CENTER,
        })
        nameLabel:setPosition(layoutWidth / 2, 230)
        layout:addChild(nameLabel)
    end

    -- 战力标签
    local fapLabel = ui.newLabel({
        text = TR("战力 %s", Utility.numberFapWithUnit(info.FAP)),
        size = 20,
        color = cc.c3b(0xff, 0xe6,0xd3),
        outlineColor = cc.c3b(0x3c, 0x00,0x00),
        outlineSize = 2,
        font = _FONT_PANGWA,
    })
    fapLabel:setPosition(layoutWidth / 2, 260)
    layout:addChild(fapLabel)
    if info.FightAdd ~= 0 then
		fapLabel:setString(TR("战力 %s%+d%%", Utility.numberFapWithUnit(info.FAP or 0), info.FightAdd))
    end

    if k == 3 then
        if self.mWaitSprite then
            self.mWaitSprite:removeFromParent()
            self.mWaitSprite = nil
        end
    end
end

-- 发送消息给别的玩家看
function TeambattleMakeTeamLayer:choseSendMessage()
	self.mChatIndex = 0

	local messageLayer = display.newLayer(cc.c4b(0, 0, 0, 100))
    messageLayer:setContentSize(cc.size(640, 1136))
    messageLayer:setPosition(display.cx, display.cy)
    messageLayer:setIgnoreAnchorPointForPosition(false)
    messageLayer:setAnchorPoint(cc.p(0.5, 0.5))
    messageLayer:setScale(Adapter.MinScale)
	self:addChild(messageLayer)

	-- 屏蔽下层点击事件
	ui.registerSwallowTouch({node = messageLayer})

    local bgSprite = ui.newScale9Sprite("c_30.png", cc.size(572, 738))
    bgSprite:setPosition(320, 568)
    messageLayer:addChild(bgSprite)

    local titleLabel = ui.newLabel({
        text = TR("我要发言"),
        size = Enums.Fontsize.eTitleDefault,
        color = Enums.Color.eNormalWhite,
        outlineColor = Enums.Color.eOutlineColor,
    })
	titleLabel:setPosition(320, 905)
	messageLayer:addChild(titleLabel)

    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(575, 905),
        clickAction = function(pSender)
            LayerManager.removeLayer(messageLayer)
        end
	})
	messageLayer:addChild(closeBtn)

	-- 创建ListView列表
    local listView = ccui.ListView:create()
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(false)
    listView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    listView:setItemsMargin(8)
    listView:setAnchorPoint(cc.p(0, 1))
    listView:setContentSize(cc.size(545, 580))
    listView:setPosition(50, 870)
    messageLayer:addChild(listView)

    local btns = {}
    for index = 1, #TeambattleChatRelation.items do
        local layout = ccui.Layout:create()
        layout:setContentSize(cc.size(543, 56))
        local textBtn = ui.newButton({
            normalImage = "c_25.png",
    		lightedImage = "c_25.png",
    		disabledImage = "c_103.png",
			size = cc.size(400, 54),
    		text = string.format("%s%s", Enums.Color.eNormalBlueH, TeambattleChatRelation.items[index].chat),
            clickAction = function()
                if self.mChatIndex ~= 0 then
                    if self.mChatIndex == index then
                        return
                    end
                    btns[self.mChatIndex]:setEnabled(true)
                end
                btns[index]:setEnabled(false)
                self.mChatIndex = index
            end
        })
        textBtn:setPosition(271, 28)
        layout:addChild(textBtn)
        listView:pushBackCustomItem(layout)

    	table.insert(btns, textBtn)
    end

    self.mChatBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("发送"),
        clickAction = function()
            if self.mChatIndex ~= 0 then
                self:sendMessage(self.mChatIndex)
                messageLayer:removeFromParent()
                self:showChat({{Name = PlayerAttrObj:getPlayerAttrByName("PlayerName"),
                    Id = self.mChatIndex}})
            else
                ui.showFlashView(TR("请选择聊天话语"))
            end
        end
    })
    self.mChatBtn:setPosition(470, 260)
    messageLayer:addChild(self.mChatBtn)

    if self.choseRemainTime <= 0 then
        self.mChatBtn:setEnabled(true)
        -- 按钮改字
        self.mChatBtn:setTitleText(TR("发 送"))
    else
        self.mChatBtn:setEnabled(false)
        -- 按钮改字
        self.mChatBtn:setTitleText(self.choseRemainTime)
    end

    local cancelBtn = ui.newButton({
        normalImage = "c_33.png",
        text = TR("取消"),
        clickAction = function()
            LayerManager.removeLayer(messageLayer)
        end
    })
   	cancelBtn:setPosition(170, 260)
    messageLayer:addChild(cancelBtn)
end

-- 展示人物说话消息
function TeambattleMakeTeamLayer:showChat(data)
    self.mItems[1]:setLocalZOrder(3)
    self.mItems[2]:setLocalZOrder(2)
    self.mItems[3]:setLocalZOrder(1)
    --dump(data, "聊天信息")
    local actionArray = {}
    local chatBoxes = {}
    local chatBoxPos = {
        [1] = {pos = cc.p(220, 320), labelOffset = cc.p(47, 85), flippedX = true},
        [2] = {pos = cc.p(-50, 320), labelOffset = cc.p(20, 85), flippedX = false},
        [3] = {pos = cc.p(280, 240), labelOffset = cc.p(47, 85), flippedX = true}
    }
    table.insert(actionArray, cc.CallFunc:create(function()
        for k, v in ipairs(data) do
            for _, team in ipairs(self.mTeamInfo) do
                if v.Name == team.Name then
                    local chatBox = ui.newSprite("bsxy_03.png")
                    chatBox:setFlippedX(chatBoxPos[team.FightOrder].flippedX)
                    self.mLayouts[team.FightOrder]:addChild(chatBox)
                    self.mLayouts[team.FightOrder]:setLocalZOrder(4)
                    local chattext = ui.newLabel({
                        text = TeambattleChatRelation.items[v.Id].chat,
                        size = 24,
                        color = Enums.Color.eWhite,
                        dimensions = cc.size(chatBox:getContentSize().width - 60 , 0),
                        anchorPoint = cc.p(0, 1),
                    })
                    chattext:setPosition(chatBoxPos[team.FightOrder].labelOffset)
                    chatBox:setPosition(chatBoxPos[team.FightOrder].pos)
                    chatBox:addChild(chattext)
                    table.insert(chatBoxes, chatBox)
                end
            end
        end
    end))
    table.insert(actionArray, cc.DelayTime:create(3.5))
    table.insert(actionArray, cc.CallFunc:create(function()
        for k, chatBox in ipairs(chatBoxes) do
            if chatBox and not tolua.isnull(chatBox) then
                chatBox:setVisible(false)
            end
        end
    end))
    self:runAction(cc.Sequence:create(actionArray))
end

-- 辅助函数：判断自己是否是队长
function TeambattleMakeTeamLayer:isMeLeader()
    local isMeLeader = false

    for k, v in pairs(self.mTeamInfo) do
        if v.IsLeader == true then
            if v.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then
                isMeLeader = true
            else
                isMeLeader = false
            end
        end
    end

    return isMeLeader
end

-- 辅助函数：对比前后数据 判断是否需要刷新
function TeambattleMakeTeamLayer:isNeedRefresh(data)
    local flag = false

    local p1 = EMPTY_ENTITY_ID
    local p2 = EMPTY_ENTITY_ID
    local p3 = EMPTY_ENTITY_ID
    local b1 = EMPTY_ENTITY_ID
    local b2 = EMPTY_ENTITY_ID
    local b3 = EMPTY_ENTITY_ID

    local op1 = EMPTY_ENTITY_ID
    local op2 = EMPTY_ENTITY_ID
    local op3 = EMPTY_ENTITY_ID
    local ob1 = EMPTY_ENTITY_ID
    local ob2 = EMPTY_ENTITY_ID
    local ob3 = EMPTY_ENTITY_ID


    if data.TeamsInfo[1] then
        p1 = data.TeamsInfo[1].PlayerId
        op1 = data.TeamsInfo[1].FightOrder
    end

    if data.TeamsInfo[2] then
        p2 = data.TeamsInfo[2].PlayerId
        op2 = data.TeamsInfo[2].FightOrder
    end

    if data.TeamsInfo[3] then
        p3 = data.TeamsInfo[3].PlayerId
        op3 = data.TeamsInfo[3].FightOrder
    end

    if self.mTeamInfo[1] then
        b1 = self.mTeamInfo[1].PlayerId
        ob1 = self.mTeamInfo[1].FightOrder
    end

    if self.mTeamInfo[2] then
        b2 = self.mTeamInfo[2].PlayerId
        ob2 = self.mTeamInfo[2].FightOrder
    end

    if self.mTeamInfo[3] then
        b3 = self.mTeamInfo[3].PlayerId
        ob3 = self.mTeamInfo[3].FightOrder
    end

    if p1 == b1 and p2 == b2 and p3 == b3 and
        op1 == ob1 and op2 == ob2 and op3 == ob3 then
        flag = false
    else
        flag = true
    end

    return flag
end

-- 辅助函数: 求空位个数(data)
function TeambattleMakeTeamLayer:kongNum(TeamInfo)
    local kongNum = 0

    local p1 = EMPTY_ENTITY_ID
    local p2 = EMPTY_ENTITY_ID
    local p3 = EMPTY_ENTITY_ID

    if TeamInfo[1] then
        p1 = TeamInfo[1].PlayerId
    end

    if TeamInfo[2] then
        p2 = TeamInfo[2].PlayerId
    end

    if TeamInfo[3] then
        p3 = TeamInfo[3].PlayerId
    end

    if p1 == EMPTY_ENTITY_ID then
        kongNum = kongNum + 1
    end

    if p2 == EMPTY_ENTITY_ID then
        kongNum = kongNum + 1
    end

    if p3 == EMPTY_ENTITY_ID then
        kongNum = kongNum + 1
    end

    return kongNum
end

-- 辅助函数：判断队伍是否组好(无空位)
function TeambattleMakeTeamLayer:isTeamOk()
    local teamflag = true

    local p1 = EMPTY_ENTITY_ID
    local p2 = EMPTY_ENTITY_ID
    local p3 = EMPTY_ENTITY_ID

    if self.mTeamInfo[1] then
        p1 = self.mTeamInfo[1].PlayerId
    end

    if self.mTeamInfo[2] then
        p2 = self.mTeamInfo[2].PlayerId
    end

    if self.mTeamInfo[3] then
        p3 = self.mTeamInfo[3].PlayerId
    end

    if p1 ~= EMPTY_ENTITY_ID and p2 ~= EMPTY_ENTITY_ID and p3 ~= EMPTY_ENTITY_ID then
        teamflag = true
    else
        teamflag = false
    end

    return teamflag
end

--- ==================== 触摸相关 =======================
-- 为拖动注册触摸事件
function TeambattleMakeTeamLayer:registerDragTouch(node, parent)
    local posOffset = {}
    node:addTouchEventListener(function(sender, eventType)
        if PlayerAttrObj:getPlayerAttrByName("PlayerId") ~= self.mTeamInfo[1].PlayerId then
            return
        end
        local index = node.index

        if eventType == ccui.TouchEventType.moved then
            -- 正在拖动
            local touchPos = sender:getTouchMovePosition()
            touchPos = parent:convertToNodeSpace(touchPos)
            node:setPosition(touchPos.x - posOffset.x, touchPos.y - posOffset.y)
        elseif eventType == ccui.TouchEventType.began then
            -- 开始拖动
            -- 设置标志 防止页面被刷新删除
            self.mRefreshFlag = 99999

            local touchPos = sender:getTouchBeganPosition()
            touchPos = parent:convertToNodeSpace(touchPos)
            posOffset.x = touchPos.x - self.mFormationConfig[index].x
            posOffset.y = touchPos.y - self.mFormationConfig[index].y
            node:setLocalZOrder(4)
        else
            -- 拖动结束
            self.mRefreshFlag = 5
            for k, item in ipairs(self.mItems) do
                item:runAction(cc.MoveTo:create(0.3, heroPosition[k]))
            end

            local touchPos = sender:getTouchEndPosition()
            touchPos = parent:convertToNodeSpace(touchPos)

            local x = touchPos.x - posOffset.x - self.mFormationConfig[index].x
            local y = touchPos.y - posOffset.y - self.mFormationConfig[index].y
            local square = x*x + y*y

            local index1 = index
            local index2 = index
            local y = 0

            if square > 8100 then
                -- 生成中心点
                local centerPos = {
                    x = touchPos.x - posOffset.x,
                    y = touchPos.y - posOffset.y + layoutHeight/2,
                }
                -- 判断当前阵型中的位置
                for i, config in ipairs(self.mFormationConfig) do
                    if i ~= index then
                        local boundingBox = self.mItems[i]:getBoundingBox()
                        if cc.rectContainsPoint(boundingBox, centerPos) then
                            -- 进行交换
                            index2 = i
                            local info = self.mOrder[index]
                            self.mOrder[index] = self.mOrder[index2]
                            self.mOrder[index2] = info
                            self:requestChangeFightOrder(self.mOrder[1] and self.mOrder[1].PlayerId or EMPTY_ENTITY_ID,
                                self.mOrder[2] and self.mOrder[2].PlayerId or EMPTY_ENTITY_ID,
                                self.mOrder[3] and self.mOrder[3].PlayerId or EMPTY_ENTITY_ID)

                            return
                        end
                    end
                end
            elseif node.click and square < 36 then
                node.click(posOffset)
            end


            self.mItems[1]:setLocalZOrder(3)
            self.mItems[2]:setLocalZOrder(2)
            self.mItems[3]:setLocalZOrder(1)
            -- self.mItems[index1]:setLocalZOrder(2)
            -- self.mItems[index2]:setLocalZOrder(2)
        end
    end)
    node:setTouchEnabled(true)
end

-----------------------网络请求------------------
-- 获取自己的组队信息
function TeambattleMakeTeamLayer:getMyTeamInfo()
    HttpClient:request({
        moduleName = "TeambattleInfo",
        methodName = "GetMyTeamInfo",
        svrMethodData = {},
        callbackNode = self,
        needWait = false,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            if response.Value.IsInTeam == false then
                --ui.showFlashView(TR("你已经不在队伍中"))
                if self then
                    LayerManager.removeLayer(self)
                end
                return
            end

            if response.Value.TeamsInfo ~= nil then
                if self:isNeedRefresh(response.Value) then
					-- 队伍信息
				 local manNum = #response.Value.TeamsInfo
				 if self.mTotalMan > manNum then
					ui.showFlashView(TR("成员退出"))
				elseif self.mTotalMan < manNum then
					 MqAudio.playEffect("duiyou_join.mp3")
					 ui.showFlashView(TR("有新成员加入"))
				 end
				 self.mTotalMan = manNum
                 self.mTeamInfo = response.Value.TeamsInfo
                 self.mOrder = {}
                 for index, value in ipairs(self.mTeamInfo) do
                     self.mOrder[value.FightOrder] = value
                 end
                 -- 刷新队伍
                 self:refreshTeamView()
                 end
            end

            -- 消息
            if response.Value.Message ~= nil then
                self:showChat(response.Value.Message)
            end

            -- 开战信息
            if response.Value.FightInfo ~= nil then
                self.mDisableAutoExit = true
                local control = Utility.getBattleControl(ModuleSub.eTeambattle, self.FightSkep)
                LayerManager.addLayer({
                    name = "ComBattle.BattleLayer",
                    data = {
                        data = response.Value.FightInfo,
                        skip = control.skip,
                        trustee = control.trustee,
                        skill = control.skill,
                        map = Utility.getBattleBgFile(ModuleSub.eTeambattle),
                        callback = function(result)
                            PvpResult.showPvpResultLayer(ModuleSub.eTeambattle, response.Value)

                            if control.trustee and control.trustee.changeTrusteeState then
                                control.trustee.changeTrusteeState(result.trustee)
                            end
                        end

                    }
                })
            end

            self.mRefreshFlag = 5
        end
    })
end

-- 退出队伍
function TeambattleMakeTeamLayer:exitTeam()
    HttpClient:request({
        moduleName = "TeambattleInfo",
        methodName = "ExitTeam",
        svrMethodData = {},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            self.mDisableAutoExit = true
            ui.showFlashView(TR("退出队伍"))
            LayerManager.deleteStackItem("teambattle.TeambattleMakeTeamLayer")
        end
    })
end

-- 发送消息让其他玩家看到
function TeambattleMakeTeamLayer:sendMessage(id)
    HttpClient:request({
        moduleName = "TeambattleInfo",
        methodName = "SendMsg",
        svrMethodData = {id},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            self.mRefreshFlag = 0 -- 刷新页面
            self.choseRemainTime = 10 -- 发言CD
        end
    })
end

-- 全服邀请
function TeambattleMakeTeamLayer:inviteAllClickAction()
    if #self.mTeamInfo == #self.mLayouts then
        ui.showFlashView(TR("当前队伍已满员，无法继续组队"))
        return
    end

    HttpClient:request({
        moduleName = "TeambattleInfo",
        methodName = "InviteAll",
        svrMethodData = {self.mNodeId},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
			--全服邀请倒计时（15s）
			self.remainTime = 10
			self.mTimeLabel:setVisible(true)
			self.mYaoqingBtn:setEnabled(false)
			Utility.schedule(
				self.mTimeLabel,
				function()
					self.sdTime = self.sdTime - 1
					self.mTimeLabel:setString(TR("%s", MqTime.formatAsDay(self.sdTime)))
					if self.sdTime <= 0 then
						self.mTimeLabel:setVisible(false)
						self.mYaoqingBtn:setEnabled(true)
						self.sdTime = 15
						self.mTimeLabel:stopAllActions()
						self.remainTime = 0
					end
				end,
				1
			)
            ui.showFlashView(TR("已发送组队邀请！"))
        end
    })
end

-- 自动匹配
function TeambattleMakeTeamLayer:fightForMatch()
    HttpClient:request({
        moduleName = "TeambattleInfo",
        methodName = "FightForMatch",
        svrMethodData = {self.mNodeId},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            self.mRefreshFlag = 100 -- 暂停刷新页面

            if #response.Value.TeamsInfo < 3 then
                ui.showFlashView(TR("匹配失败"))
                -- self:dismissTeam()
            end

            -- 添加屏蔽层，此时不能拖动和点击其他按钮
            self.mSwallowLayer = ui.createSwallowLayer()
            self.mRefreshTime = (#self.mLayouts - #self.mOrder) / 3
            self.mParentLayer:addChild(self.mSwallowLayer, 19)
            if self:isNeedRefresh(response.Value) then
                local kongNum = self:kongNum(self.mTeamInfo)
                local actionArray = {}
                table.insert(actionArray, cc.CallFunc:create(function()
                    --隐藏 解散和匹配 按钮
                    self.mPiPeiBtn:setVisible(false)
                    if self.mWaitSprite then
                        self.mWaitSprite:removeFromParent()
                        self.mWaitSprite = nil
                    end
                    --创建 匹配中... 动画
                    self.mWaitSprite = ui.newSprite("jsxy_26.png")
                    self.mWaitSprite:setPosition(cc.p(320, 200))
                    self.mParentLayer:addChild(self.mWaitSprite)
                    local a = cc.Animation:create()
                    a:addSpriteFrameWithFile("jsxy_26.png")
                    a:addSpriteFrameWithFile("jsxy_27.png")
                    a:addSpriteFrameWithFile("jsxy_28.png")
                    a:setDelayPerUnit(0.5)
                    local ani = cc.Animate:create(a)
                    self.mWaitSprite:runAction(cc.RepeatForever:create(ani))
                    --隐藏邀请按钮
                    for k, v in ipairs(self.mHerobtns) do
                        v:setVisible(false)
                        v:setClickAction(function() end)
                    end

                    for i = 1,#self.mLayouts do
                        if not self.mOrder[i] then
                            local hero = ui.newButton({
                                normalImage = "c_36.png",
                                scale = 0.5,
                            })
                            hero:setPosition(heroPosition[i].x,
                                heroPosition[i].y + 140)
                            self.mTeamLayer:addChild(hero)

                            local waitSprite = ui.newSprite("jsxy_23.png")
                            waitSprite:setPosition(heroPosition[i].x,heroPosition[i].y + 140)
                            self.mTeamLayer:addChild(waitSprite)

                            --动画
                            local a = cc.Animation:create()
                            a:addSpriteFrameWithFile("jsxy_23.png")
                            a:addSpriteFrameWithFile("jsxy_24.png")
                            a:addSpriteFrameWithFile("jsxy_25.png")

                            a:setDelayPerUnit(0.5)
                            local ani = cc.Animate:create(a)

                            waitSprite:runAction(cc.RepeatForever:create(ani))
                        end
                    end
                end))
                table.insert(actionArray, cc.DelayTime:create(3))
                table.insert(actionArray, cc.CallFunc:create(function()
                    self.mTeamInfo = response.Value.TeamsInfo
                    self.mOrder = {}
                    for index, value in ipairs(self.mTeamInfo) do
                        self.mOrder[value.FightOrder] = value
                    end
					self.mTotalMan = kongNum
                    if kongNum == 2 then
                        -- 刷新队伍
                        self:refreshTeamView("pipei2")
                    else
                        -- 刷新队伍
                        self:refreshTeamView()
                    end
                end))
                self:runAction(cc.Sequence:create(actionArray))
            end
        end
    })
end

-- 组队踢人
function TeambattleMakeTeamLayer:kickOutTeam(playerId)
    HttpClient:request({
        moduleName = "TeambattleInfo",
        methodName = "KickOutTeam",
        svrMethodData = {playerId},
        callbackNode = self,
        callback = function(response)
            if response.Status == 0 then
                self:getMyTeamInfo()
            elseif response.Status == -7122 then
                ui.showFlashView(TR("该玩家已经退出队伍"))
                self:getMyTeamInfo()
            end
        end
    })
end

-- 组队开战
function TeambattleMakeTeamLayer:requestFight()
    -- 设置标志 防止页面被刷新删除
    self.mRefreshFlag = 99999

    HttpClient:request({
        moduleName = "TeambattleInfo",
        methodName = "Fight",
        svrMethodData = {},
        guideInfo = Guide.helper:tryGetGuideSaveInfo(11903031),
        callbackNode = self,
        callback = function(response)
            if response.Status == 0 then
                --[[--------新手引导--------]]--
                local _, _, eventID = Guide.manager:getGuideInfo()
                if eventID == 11903031 then
                    Guide.manager:removeGuideLayer()
                    Guide.manager:nextStep(eventID)
                end

                local control = Utility.getBattleControl(ModuleSub.eTeambattle, self.FightSkep)
                LayerManager.addLayer({
                    name = "ComBattle.BattleLayer",
                    data = {
                        data = response.Value.FightInfo,
                        skip = control.skip,
                        trustee = control.trustee,
                        skill = control.skill,
                        map = Utility.getBattleBgFile(ModuleSub.eTeambattle),
                        callback = function(result)
                            PvpResult.showPvpResultLayer(ModuleSub.eTeambattle, response.Value)

                            if control.trustee and control.trustee.changeTrusteeState then
                                control.trustee.changeTrusteeState(result.trustee)
                            end
                        end
                    }
                })
            elseif response.Status == -7121 then
                ui.showFlashView(TR("有玩家退出了当前队伍"))
                self:getMyTeamInfo()
            end
        end
    })
end

-- 修改队伍战斗序列
function TeambattleMakeTeamLayer:requestChangeFightOrder(id1, id2, id3)
    HttpClient:request({
        moduleName = "TeambattleInfo",
        methodName = "ChangeFightOrder",
        svrMethodData = {id1, id2, id3},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

			self.mTotalMan = #response.Value.TeamsInfo

            self:getMyTeamInfo()
        end
    })
end

----[[---------------------新手引导---------------------]]--
function TeambattleMakeTeamLayer:onEnterTransitionFinish()
    self:executeGuide()
end

-- 执行新手引导
function TeambattleMakeTeamLayer:executeGuide()
    local _, _, eventID = Guide.manager:getGuideInfo()
    if eventID == 1190302 and not next(self.mHerobtns) then
        -- 如已经邀请到人之后，自动跳到后面步骤
        Guide.manager:nextStep(eventID)
        Guide.manager:nextStep(1190303)
    end
    Guide.helper:executeGuide({
        -- 点击邀请
        [1190302] = {clickNode = self.mHerobtns[1]},
        -- 开始战斗
        [11903031] = {clickNode = self.mKaiZhanBtn},
    })
end

return TeambattleMakeTeamLayer

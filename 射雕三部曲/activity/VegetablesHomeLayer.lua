--[[
	文件名:VegetablesHomeLayer.lua
	描述：种菜首页
	创建人：heguanghui
    创建时间：2018.03.23
--]]

local VegetablesHomeLayer = class("VegetablesHomeLayer", function(params)
    return display.newLayer()
end)

-- 九块地的位置配置
local VegetPosConfig = {
    [1] = {orderId = 1, pos = cc.p(400, 125)},
    [2] = {orderId = 2, pos = cc.p(170, 180)},
    [3] = {orderId = 3, pos = cc.p(270, 330)},
    [4] = {orderId = 4, pos = cc.p(380, 480)},
    [5] = {orderId = 5, pos = cc.p(180, 535)},  
    [6] = {orderId = 6, pos = cc.p(410, 640)},     
    [7] = {orderId = 7, pos = cc.p(240, 700)},
    [8] = {orderId = 8, pos = cc.p(340, 760)},
    [9] = {orderId = 9, pos = cc.p(85, 690)},
}

--[[
-- 参数 params 中各项为：
	{
	}
]]
function VegetablesHomeLayer:ctor(params)
	-- 屏蔽下层事件
	ui.registerSwallowTouch({node = self})

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer) 

	-- 初始化页面控件
	self:initUI()
end

function VegetablesHomeLayer:onEnterTransitionFinish()
	local activityInfo = ActivityObj:getActivityItem(ModuleSub.eTimedvegetables)[1]
	if activityInfo and Player:getCurrentTime() > activityInfo.EndDate then
		LayerManager.removeLayer(self)
		-- 打开排行榜
		self:openRankShow(true)
	else
	    self:requestGetInfo(PlayerAttrObj:getPlayerAttrByName("PlayerId"))
	end
end

function VegetablesHomeLayer:openRankShow(isCleanUp)
	LayerManager.addLayer({
        name = "activity.CommonActivityRankLayer",
        data = {
                moduleName = "TimedVegetablesInfo",
                methodNameRank = "GetRankInfo",
                methodNameReward = "GetRankReward",
                scoreName = TR("剑意"),
            },
        cleanUp = isCleanUp,
    })
end

-- 初始化页面控件
function VegetablesHomeLayer:initUI()
	-- 背景图片
	local bgSprite = ui.newSprite("qqnc_47.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

    -- 创建顶部资源栏和底部导航栏
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {
            ResourcetypeSub.eVIT,
            ResourcetypeSub.eDiamond,
            ResourcetypeSub.eGold
        }
    })
    self:addChild(topResource)
	
	-- 关闭按钮
	self.mCloseBtn = ui.newButton({
		normalImage = "c_29.png",
		clickAction = function()
			LayerManager.removeLayer(self)
		end
	})
	self.mCloseBtn:setPosition(Enums.StardardRootPos.eCloseBtn)
	self.mParentLayer:addChild(self.mCloseBtn)


	-- 规则
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(40, 1045),
        clickAction = function()
            MsgBoxLayer.addRuleHintLayer(TR("规则"),
            {
                TR("1.活动开始时拥有6个已经开凿的剑冢，剩余3块剑冢通过花费元宝开凿，分别为1000，2000,3000元宝，开凿以后只限于本次活动使用。"),
                TR("2.招募铁匠和神匠为你修复剑冢中残剑，修复以后会获得残剑和成品剑以及额外的礼包道具。"),
                TR("3.每日可以帮好友招募铁匠，每次帮助好友招募铁匠可以减少1小时修复时间。"),
                TR("4.每日可以帮好友招募10位铁匠，每位好友可以帮忙雇佣铁匠一次，最多帮忙雇佣铁匠30次。"),
                TR("5.使用神匠招募令可以招募神匠为你修复残剑，神匠可以减少2小时修复时间。"),
                TR("6.修复需要矿石，活动结束后，仓库中的所有东西都会清空。"),
                TR("7.50级以上的玩家才能帮好友招募铁匠，50级以下只能自己招募，每个剑冢每次只能招募2次铁匠，神匠不受限制。"),
                TR("8.点击加号招募铁匠和神匠，点击气泡开始修复和收取。"),
                TR("9.可以抢夺好友修复完成的残剑。"),
                TR("10.出售残剑和剑都能获得剑意。"),
                TR("11.剑意用于独孤剑冢排行，可以获得丰厚的排行榜奖励。"),
                TR("12.残剑=1剑意，青钢剑=5剑意，紫薇软剑=10剑意，玄铁重剑=50剑意，木剑=100剑意。"),
                TR("13.每日抢夺次数上限为100次，当日抢夺100次后无法继续抢夺。"),
                TR("14.残剑存量超过10W，显示单位上升为万但数量依旧会增长。"),
        	})
        end})
    self.mParentLayer:addChild(ruleBtn)

    -- 公告牌
    local messageBtn = ui.newButton({
        normalImage = "qqnc_44.png",
        position = cc.p(555, 480),
        clickAction = function()
        	LayerManager.addLayer({
                name = "activity.VegetablesLogLayer",
                data = {playerId = self.mGuidId},
                cleanUp = false,
                zOrder = Enums.ZOrderType.ePopLayer
            })
        end
    })
    self.mParentLayer:addChild(messageBtn)

    -- 商店
    local shopBtn = ui.newButton({
        normalImage = "qqnc_49.png",
        position = cc.p(572, 376),
        clickAction = function()
            LayerManager.addLayer({
                name = "activity.VegetableShopLayer",
                cleanUp = false,
            })
        end
    })
    self.mParentLayer:addChild(shopBtn)

    -- 排行
    local rankBtn = ui.newButton({
        normalImage = "qqnc_55.png",
        position = cc.p(572, 276),
        clickAction = function()
            self:openRankShow(false)
        end
    })
    self.mParentLayer:addChild(rankBtn)

    -- 仓库
    local bagBtn = ui.newButton({
        normalImage = "qqnc_54.png",
        position = cc.p(572, 178),
        clickAction = function()
            LayerManager.addLayer({
                name = "activity.VegetableBagLayer",
                data = {scoreLabel = self.scoreLabel},
                cleanUp = false,
                })
        end
    })
    self.mParentLayer:addChild(bagBtn)

    -- 我的积分
	local scoreBgSprite = ui.newSprite("qqnc_32.png")
	scoreBgSprite:setPosition(572, 113)
	self.mParentLayer:addChild(scoreBgSprite)
    local scoreLabel = ui.newLabel({
            text = TR("我的剑意:%d", 0),
            size = 18,
        })
    scoreLabel:setPosition(73, 18)
    scoreBgSprite:addChild(scoreLabel)
    self.scoreLabel = scoreLabel

    -- 好友
    local friendBtn = ui.newButton({
        normalImage = "qqnc_33.png",
        position = cc.p(640, 800),
        anchorPoint = cc.p(1.0, 0.5),
        clickAction = function()
        	self:popFriendLayer()
        end
    })
    self.mParentLayer:addChild(friendBtn, 10)
    self.friendBtn = friendBtn

    -- 一键按钮菜单
    local onekeyMenuBtn = ui.newButton({
        normalImage = "jrhd_129.png",
        position = cc.p(640, 660),
        anchorPoint = cc.p(1.0, 0.5),
        clickAction = function()
            self:popMenuLayer()
        end
    })
    self.mParentLayer:addChild(onekeyMenuBtn, 10)
    self.onekeyMenuBtn = onekeyMenuBtn
    -- 好友上小红点
    local subKeyId = "ExtendInfo"
    local function dealRedDotVisible(redDotSprite)
        local redDotData = RedDotInfoObj:isValid(ModuleSub.eTimedvegetables, subKeyId)
        redDotSprite:setVisible(redDotData)
    end
    ui.createAutoBubble({refreshFunc = dealRedDotVisible, parent = friendBtn,
        eventName = RedDotInfoObj:getEvents(ModuleSub.eTimedvegetables, subKeyId)})

    -- 返还菜园
    local backBtn = ui.newButton({
        normalImage = "qqnc_48.png",
        position = cc.p(640, 600),
        anchorPoint = cc.p(1.0, 0.5),
        clickAction = function()
            self:requestGetInfo(PlayerAttrObj:getPlayerAttrByName("PlayerId"))
        end
    })
    self.mParentLayer:addChild(backBtn, 1)
    self.backBtn = backBtn

    -- 活动倒计时
    local timeNode = ui.createSpriteAndLabel({
        imgName = "c_25.png",
        scale9Size = cc.size(320, 54),
        labelStr = "",
        fontColor = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        outlineSize = 2,
    })
    timeNode:setAnchorPoint(cc.p(0.5, 0.5))
    timeNode:setPosition(160, 950)
    self.mParentLayer:addChild(timeNode)
    self.mTimeNode = timeNode

    -- 今日施肥次数
    local fertNumLabel = ui.newLabel({
        text = "",
        size = 22,
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
    })
    fertNumLabel:setAnchorPoint(cc.p(0.5, 0.5))
    fertNumLabel:setPosition(160, 910)
    self.mParentLayer:addChild(fertNumLabel)
    self.mFertNumLabel = fertNumLabel

    -- 显示xx人的菜园
    self.mPlayerNameLabel = ui.newLabel({
            text = "",
            size = 24,
            outlineColor = Enums.Color.eOutlineColor,
        })
    self.mPlayerNameLabel:setAnchorPoint(cc.p(1, 0))
    self.mPlayerNameLabel:setPosition(600, 880)
    self.mParentLayer:addChild(self.mPlayerNameLabel)
end

-- 处理好友弹出框
function VegetablesHomeLayer:popFriendLayer()
    -- 已创建好友弹出
    if self.mFriendLayer and not tolua.isnull(self.mFriendLayer) then
        -- 播放动画成功
        self.mFriendLayer.showAction()
    -- 未创建好友弹出
    else
        -- 创建好友弹窗
        self.mFriendLayer = self:createFriendLayer()
        self:addChild(self.mFriendLayer, 100) -- 创建到最上层
        -- 播放弹出动画
        self.mFriendLayer.showAction()
    end
end

-- 处理一键按钮菜单弹出框
function VegetablesHomeLayer:popMenuLayer()
    -- 已创建好友弹出
    if self.mMenuLayer and not tolua.isnull(self.mMenuLayer) then
        -- 播放动画成功
        self.mMenuLayer.showAction()
    -- 未创建好友弹出
    else
        -- 创建好友弹窗
        self.mMenuLayer = self:createMenuLayer()
        self:addChild(self.mMenuLayer, 100) -- 创建到最上层
        -- 播放弹出动画
        self.mMenuLayer.showAction()
    end
end

function VegetablesHomeLayer:createMenuLayer()
    local layer = ui.newStdLayer()

    -- 背景
    local bgPosX = 640
    local listBg = ui.newSprite("jrhd_130.png")
    listBg:setAnchorPoint(cc.p(1, 0.5))
    listBg:setPosition(bgPosX+listBg:getContentSize().width, 560)
    layer:addChild(listBg)

    local bgSize = listBg:getContentSize()

    -- 按钮列表
    local btnList = {
        -- 一键播种
        {
            normalImage = "jrhd_132.png",
            position = cc.p(bgSize.width*0.5, 270),
            clickAction = function ()
                self:requestOneKeySeed()
            end,
        },
        -- 一键施肥
        {
            normalImage = "jrhd_133.png",
            position = cc.p(bgSize.width*0.5, 170),
            clickAction = function ()
                self:requestOneKeyFertilize()
            end,
        },
        -- 一键收获
        {
            normalImage = "jrhd_131.png",
            position = cc.p(bgSize.width*0.5, 70),
            clickAction = function ()
                self:requestOneKeyHarvest()
            end,
        },
    }
    for _, btnInfo in pairs(btnList) do
        local tempBtn = ui.newButton(btnInfo)
        listBg:addChild(tempBtn)
    end

    -- 弹出／收回(isShow是否显示)
    local function action(isShow)
        -- 正在移动不创建新动作
        if self.isMoving then return false end

        -- 是否显示
        self.isMenuShow = isShow ~= nil and isShow or (not self.isMenuShow)

        local width = listBg:getContentSize().width
        local curX, curY = listBg:getPosition()
        local btnX, btnY = self.onekeyMenuBtn:getPosition()
        local nextX = self.isMenuShow and bgPosX or (bgPosX + width)
        local btnNextX = self.isMenuShow and (btnX - width) or (btnX + width)
        -- 移动
        local move = cc.MoveTo:create(0.15, cc.p(nextX, curY))
        local btnMove = cc.MoveTo:create(0.15, cc.p(btnNextX, btnY))

        local completeAction = cc.CallFunc:create(function ()
            self.isMoving = false

            -- 删除层
            if not self.isMenuShow then
                self.isMenuShow = false
                layer:removeFromParent()
                self.mMenuLayer = nil
            end
        end)

        -- 是否正在移动
        self.isMoving = true
        listBg:runAction(cc.Sequence:create(move, completeAction))
        self.onekeyMenuBtn:runAction(btnMove)

        return true
    end
    layer.showAction = action

    -- 注册触摸边界外也可关闭弹窗
    ui.registerSwallowTouch({
            node = layer,
            allowTouch = true,
            beganEvent = function(touch, event)
                return true
            end,
            endedEvent = function(touch, event)
                -- 关闭弹窗
                if not ui.touchInNode(touch, listBg) then
                    layer.showAction(false)
                end
            end,
        })

    return layer
end

function VegetablesHomeLayer:createFriendLayer()
    local layer = ui.newStdLayer()

    -- 背景
    local bgPosX = 640
    local listBg = ui.newSprite("qqnc_35.png")
    listBg:setAnchorPoint(cc.p(1, 0.5))
    listBg:setPosition(bgPosX+listBg:getContentSize().width, 600)
    layer:addChild(listBg)

    -- 列表
    local listBgSize = listBg:getContentSize()
    local friendListView = ccui.ListView:create()
    friendListView:setDirection(ccui.ScrollViewDir.vertical)
    friendListView:setContentSize(cc.size(listBgSize.width-5, listBgSize.height-100))
    friendListView:setGravity(ccui.ListViewGravity.centerVertical)
    friendListView:setAnchorPoint(cc.p(0.5, 1))
    friendListView:setBounceEnabled(true)
    friendListView:setPosition(cc.p(listBgSize.width*0.5+5, listBgSize.height-10))
    listBg:addChild(friendListView)

    -- 分割线
    local lineSprite = ui.newSprite("qqnc_41.png")
    lineSprite:setPosition(cc.p(listBgSize.width*0.5, 75))
    listBg:addChild(lineSprite)

    -- 一键领取
    local getBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("一键招募"),
            clickAction = function ()
                self:requestGetBatchFertilizer()
            end
        })
    getBtn:setPosition(75, 40)
    getBtn:setScale(0.8)
    listBg:addChild(getBtn)
    -- 一键领取上小红点
    local subKeyId = "ExtendInfo"
    local function dealRedDotVisible(redDotSprite)
        local redDotData = RedDotInfoObj:isValid(ModuleSub.eTimedvegetables, subKeyId)
        redDotSprite:setVisible(redDotData)
    end
    ui.createAutoBubble({refreshFunc = dealRedDotVisible, parent = getBtn,
        eventName = RedDotInfoObj:getEvents(ModuleSub.eTimedvegetables, subKeyId)})

    -- 一键赠送
    local sendBtn = ui.newButton({
            normalImage = "c_33.png",
            text = TR("一键雇佣"),
            clickAction = function ()
                self:requestBatchSendFriend()
            end
        })
    sendBtn:setPosition(180, 40)
    sendBtn:setScale(0.8)
    listBg:addChild(sendBtn)

    -- 刷新列表
    layer.refreshFriendList = function(friendList)
        -- 创建列表项
        local function createCell(itemData)
            local cellSize = cc.size(230, 152)
            local layout = ccui.Layout:create()
            layout:setContentSize(cellSize)

            -- 背景
            local bgSprite = ui.newScale9Sprite("qqnc_34.png", cellSize)
            bgSprite:setPosition(cellSize.width*0.5, cellSize.height*0.5)
            layout:addChild(bgSprite)

            -- 头像
            local headCard = CardNode.createCardNode({
                resourceTypeSub = ResourcetypeSub.eHero,
                modelId = itemData.HeadImageId,
                fashionModelID = itemData.FashionModelId,
                cardShowAttrs = {CardShowAttr.eBorder},
                allowClick = false,
            })
            headCard:setScale(0.8)
            headCard:setPosition(50, 100)
            layout:addChild(headCard)
            -- 名字
            local nameLabel = ui.newLabel({
                text = itemData.Name,
                color = Enums.Color.eBlack,
                anchorPoint = cc.p(0, 1),
                size = 20,
                x = 100,
                y = cellSize.height - 15,
            })
            layout:addChild(nameLabel)
            -- 等级
            local LvLable = ui.newLabel({
                    text = TR("等级: %s%d","#20781b",itemData.Lv),
                    color = Enums.Color.eBlack,
                    anchorPoint = cc.p(0, 1),
                    size = 18,
                    x = 100,
                    y = cellSize.height - 40,
                })
            layout:addChild(LvLable)
            -- 肥料领取
            if itemData.IfCanReceive == 1 then
                local friendGetBtn = ui.newButton({
                        normalImage = "qqnc_84.png",
                        clickAction = function ()
                            self:requestGetFertilizer(itemData.PlayerId)
                        end,
                    })
                friendGetBtn:setPosition(110, 75)
                layout:addChild(friendGetBtn)

                -- 显示提示文字
                local getLabel = ui.newLabel({
                        text = TR("可招募"),
                        color = cc.c3b(0x46, 0x22, 0x0d),
                        size = 20,
                    })
                getLabel:setAnchorPoint(cc.p(0, 0.5))
                getLabel:setPosition(130, 75)
                layout:addChild(getLabel)
            end
            -- 进入菜园
            local enterBtn = ui.newButton({
                    normalImage = "c_28.png",
                    text = TR("进入剑冢"),
                    clickAction = function ()
                        self.mFriendLayer.showAction(false)
                        self:requestGetInfo(itemData.PlayerId, itemData.Name)
                    end
                })
            enterBtn:setPosition(65, 30)
            enterBtn:setScale(0.8)
            layout:addChild(enterBtn)
            -- 送肥料
            if itemData.CanSendSTA then
                local sendFriendBtn = ui.newButton({
                        normalImage = "c_33.png",
                        text = TR("帮忙雇佣"),
                        clickAction = function ()
                            -- body
                            self:requestSendFriend(itemData.PlayerId)
                        end
                    })
                sendFriendBtn:setPosition(175, 30)
                sendFriendBtn:setScale(0.8)
                layout:addChild(sendFriendBtn)
            else
                local alreadyLearnLabel = ui.createSpriteAndLabel({
                        imgName = "c_156.png",
                        labelStr = TR("已雇佣"),
                        fontSize = 24,
                    })
                alreadyLearnLabel:setPosition(175, 30)
                layout:addChild(alreadyLearnLabel)
            end

            -- 是否有成熟的蔬菜可偷取
            if itemData.CanSteal then
                local canStealSprite = ui.newSprite("qqnc_45.png")
                canStealSprite:setPosition(30, 130)
                layout:addChild(canStealSprite)
            end

            return layout
        end

        -- 可以一键领取
        local canOneKeyGet = false
        -- 可以一键赠送
        local canOneKeySend = false

        -- 清空列表
        friendListView:removeAllChildren()
        if self.emptyHint and not tolua.isnull(self.emptyHint) then
            self.emptyHint:removeFromParent()
            self.emptyHint = nil
        end

        -- 填充列表
        if friendList and next(friendList) then
            for _, friendInfo in pairs(friendList or {}) do
                local item = createCell(friendInfo)
                friendListView:pushBackCustomItem(item)

                -- 可一键领取
                if friendInfo.IfCanReceive == 1 then
                    canOneKeyGet = true
                end

                -- 可一键赠送
                if friendInfo.CanSendSTA then
                    canOneKeySend = true
                end
            end
        else
            self.emptyHint = ui.createEmptyHint(TR("您还没有好友"))
            self.emptyHint:setPosition(listBgSize.width*0.5, listBgSize.height*0.5)
            self.emptyHint:setScale(0.5)
            listBg:addChild(self.emptyHint)
        end

        getBtn:setEnabled(canOneKeyGet)
        getBtn:setTitleText(canOneKeyGet and TR("一键领取") or TR("暂无铁匠"))
        sendBtn:setEnabled(canOneKeySend)
        sendBtn:setTitleText(canOneKeySend and TR("一键雇佣") or TR("已雇佣"))
    end

    -- 刷新列表
    self:requestFriendList(function(data)
        layer.refreshFriendList(data.Value.Info)
    end)

    -- 弹出／收回(isShow是否显示)
    local function action(isShow)
        -- 正在移动不创建新动作
        if self.isMoving then return false end

        -- 是否显示
        self.isFriendShow = isShow ~= nil and isShow or (not self.isFriendShow)

        local width = listBg:getContentSize().width
        local curX, curY = listBg:getPosition()
        local btnX, btnY = self.friendBtn:getPosition()
        local nextX = self.isFriendShow and bgPosX or (bgPosX + width)
        local btnNextX = self.isFriendShow and (btnX - width) or (btnX + width)
        -- 移动
        local move = cc.MoveTo:create(0.15, cc.p(nextX, curY))
        local btnMove = cc.MoveTo:create(0.15, cc.p(btnNextX, btnY))

        local completeAction = cc.CallFunc:create(function ()
            self.isMoving = false

            -- 删除层
            if not self.isFriendShow then
                self.isFriendShow = false
                layer:removeFromParent()
                self.mFriendLayer = nil
            end
        end)

        -- 是否正在移动
        self.isMoving = true
        listBg:runAction(cc.Sequence:create(move, completeAction))
        self.friendBtn:runAction(btnMove)

        return true
    end
    layer.showAction = action

    -- 注册触摸边界外也可关闭弹窗
    ui.registerSwallowTouch({
            node = layer,
            allowTouch = true,
            beganEvent = function(touch, event)
                return true
            end,
            endedEvent = function(touch, event)
                -- 关闭弹窗
                if not ui.touchInNode(touch, listBg) then
                    layer.showAction(false)
                end
            end,
        })

    return layer
end

-- 刷新时间、施肥次数、积分
function VegetablesHomeLayer:refreshMyInfo()
    if self.mFertNumLabel then 
        self.mFertNumLabel:setString(TR("今日剩余铁匠雇佣次数:%d", self.mSelfData.FertilizableNum or 0))
    end 
    if self.scoreLabel then 
        self.scoreLabel:setString(TR("我的剑意:%d", self.mSelfData.IntegralNum or 0))
    end 
    -- 刷新时间标签，开始倒计时
    if self.mSchelTime then
        self:stopAction(self.mSchelTime)
        self.mSchelTime = nil
    end
    self:updateTime()
    self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)
end

-- 活动倒计时
function VegetablesHomeLayer:updateTime()
    local timeLeft = self.mEndTime - Player:getCurrentTime()
    if timeLeft > 0 then
        self.mTimeNode:setString(TR("活动倒计时:%s%s", "#f8ea3a", MqTime.formatAsDay(timeLeft)))
    else
        self.mTimeNode:setString(TR("活动倒计时:%s00:00:00", "#f8ea3a"))
        -- 停止倒计时
        if self.mSchelTime then
            self:stopAction(self.mSchelTime)
            self.mSchelTime = nil
        end
        LayerManager.removeLayer(self)
    end
end

-- 刷新土地相关
function VegetablesHomeLayer:creatVegetabelsLand()
    -- 清空土地
    if self.mVegetLandNode and next(self.mVegetLandNode) then
        for _, node in pairs(self.mVegetLandNode) do
            if node and not tolua.isnull(node) then
                node:removeFromParent()
            end
        end
    end
    -- 9快土地Node
    self.mVegetLandNode = {}
 
    -- 分别创建9块土地
    for i,v in ipairs(VegetPosConfig) do
        self:createOneVeget(v.orderId)
    end
end

-- 获取一块地的对应图片
--[[
    posId       地的位置id(1-9)
    statusId    地的状态（1:未开凿 2:已凿开 3:可收取）
]]
function VegetablesHomeLayer:getOneVegetPic(posId, statusId)
    local VegetPicList = {
        {
            "qqnc_74.png",
            "qqnc_56.png",
            "qqnc_65.png",
        },
        {
            "qqnc_75.png",
            "qqnc_57.png",
            "qqnc_66.png",
        },
        {
            "qqnc_76.png",
            "qqnc_58.png",
            "qqnc_67.png",
        },
        {
            "qqnc_77.png",
            "qqnc_59.png",
            "qqnc_68.png",
        },
        {
            "qqnc_78.png",
            "qqnc_60.png",
            "qqnc_69.png",
        },
        {
            "qqnc_79.png",
            "qqnc_61.png",
            "qqnc_70.png",
        },
        {
            "qqnc_80.png",
            "qqnc_62.png",
            "qqnc_71.png",
        },
        {
            "qqnc_81.png",
            "qqnc_63.png",
            "qqnc_72.png",
        },

        {
            "qqnc_82.png",
            "qqnc_64.png",
            "qqnc_73.png",
        },
    }

    return VegetPicList[posId][statusId]
end

-- 创建一块土地当面的相关信息
function VegetablesHomeLayer:createOneVeget(orderId)
    -- 获取土地信息
    local vegetInfo = self:getCurrentVegetInfo(orderId)

    -- 清空当前土地上的东西
    if not tolua.isnull(self.mVegetLandNode[orderId]) then
        self.mVegetLandNode[orderId]:removeFromParent()
        self.mVegetLandNode[orderId] = nil
    end 
    local image = self:getOneVegetPic(orderId, next(vegetInfo) == nil and 1 or 2)
    local vegetNode = ui.newSprite(image)
    vegetNode:setScale(0.8)
    vegetNode:setAnchorPoint(0.5, 0)
    vegetNode:setPosition(VegetPosConfig[orderId].pos)
    self.mParentLayer:addChild(vegetNode, 10-orderId)
    self.mVegetLandNode[orderId] = vegetNode

    local vegetNode = self.mVegetLandNode[orderId]
    local vegetNodeSize = vegetNode:getContentSize()
    
    -- 如果没有土地信息（需要开垦）
    if next(vegetInfo) == nil then 
        -- 开垦
        local developBtn = ui.newButton({
            normalImage = "qqnc_52.png",
            clickAction = function()
                -- 判断上一块土地是否已经解锁
                if (orderId-1) > 0 then 
                    local vegetInfo = self:getCurrentVegetInfo((orderId-1))
                    if next(vegetInfo) == nil then 
                        ui.showFlashView({text = TR("需要先开凿上一块剑冢！")})
                        return
                    else 
                        -- 弹出开垦弹窗
                        self:unlockLandMsgBoxLayer(orderId)
                    end 
                end 
            end
        })
        developBtn:setAnchorPoint(cc.p(0.5, 0))
        developBtn:setScale(0.8)
        developBtn:setPosition(vegetNodeSize.width/2, vegetNodeSize.height/2)
        vegetNode:addChild(developBtn)
        developBtn:setVisible(self.mMySelf)
        return
    end

    ------------------------ 已经开垦了土地
    -- 播种
    if vegetInfo.SeedID == 0 then 
        local seedBtn = ui.newButton({
            normalImage = "qqnc_46.png",
            clickAction = function()
                LayerManager.addLayer({
                    name = "activity.VegetablesSeedSelLayer",
                    data = {landId = vegetInfo.Id, callback = function (data)
                        -- 修改菜园数据
                        self:modifyVegetInfo(data.Value.VegetablesLandInfo or {})
                    end},
                    cleanUp = false
                })
            end
        })
        seedBtn:setPosition(vegetNodeSize.width/2+10, vegetNodeSize.height/2+50)
        vegetNode:addChild(seedBtn)
        seedBtn:setScale(0.9)
        seedBtn:setVisible(self.mMySelf)
        return
    end 

    -- 显示植物图片、名字、进度条、时间
    self:showOnePlantInfo(orderId, vegetInfo.EndTime, vegetInfo.SeedID)

    -- 如果成熟时间大于当前时间（说明还没有成熟需要施肥）
    if vegetInfo.EndTime > Player:getCurrentTime() then  
        -- 施肥
        local ordinaryBtn = ui.newButton({
            normalImage = "gd_27.png",
            clickAction = function()
                -- 选择施肥弹窗
                self:applyFertilizerSelectLayer(vegetInfo.Id)
            end
        })
        ordinaryBtn:setPosition(vegetNodeSize.width/2+10, vegetNodeSize.height/2+23)
        vegetNode:addChild(ordinaryBtn)
        ordinaryBtn:setScale(1.2)
        return
    end  

    -- 摘取按钮
    local pickBtn = ui.newButton({
        normalImage = "qqnc_51.png",
        clickAction = function()
            if self.mMySelf then 
                -- 摘取
                self:requestHarvest(vegetInfo.Id)
            else 
                -- 偷取
                self:requestSteal(vegetInfo.Id)
            end 
        end
    })
    pickBtn:setPosition(vegetNodeSize.width/2+25, vegetNodeSize.height/2+30)
    vegetNode:addChild(pickBtn)
    pickBtn:setScale(0.8)

    -- 如果不是自己（判断是否显示偷取按钮）
    if not self.mMySelf then
        pickBtn:setVisible(vegetInfo.CanSteal)
    end 
end

-- 显示一株植物的名字倒计时等东西
function VegetablesHomeLayer:showOnePlantInfo(orderId, endTime, seedID)
    local vegetNode = self.mVegetLandNode[orderId]
    local vegetNodeSize = vegetNode:getContentSize() 
    -- 植物的当前状态图片
    local vegetImage = self:getVegetImageByTimeAndID(endTime, orderId)
    vegetNode:setTexture(vegetImage)

    -- 根据种子ID获取成熟之后的ID
    local dropResource = VegetablesOutputRelation.items[seedID][1].dropResource
    local plantModelId = Utility.analysisStrResList(dropResource)[1].modelId
    -- 名字
    local quality = Utility.getQualityByModelId(ResourcetypeSub.eVegetable, plantModelId)
    local plantName = Utility.getGoodsName(ResourcetypeSub.eVegetable, plantModelId)
    local plantColor = Utility.getQualityColor(quality, 1)
    local nameLable = ui.newLabel({
        text = plantName,
        size = 16,
        color = plantColor,
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
    })
    nameLable:setScale(1.2)
    nameLable:setAnchorPoint(cc.p(0.5, 0.5))
    nameLable:setPosition(vegetNodeSize.width/2, -7)
    vegetNode:addChild(nameLable)

    -- 进度条
    local currTime = Player:getCurrentTime() - (endTime - VegetablesConfig.items[1].matureNeedTime)
    local timeBar = require("common.ProgressBar"):create({
        bgImage = "zd_01.png",   -- 背景图片
        barImage = "zd_02.png",  -- 进度图片
        currValue = currTime,  -- 当前进度
        maxValue = VegetablesConfig.items[1].matureNeedTime, -- 最大值
    })
    timeBar:setScale(1.2)
    timeBar:setPosition(vegetNodeSize.width/2, 10)
    vegetNode:addChild(timeBar)

    -- 如果已经成熟就不显示倒计时
    if (endTime - Player:getCurrentTime()) <= 0 then 
        return
    end 
    -- 倒计时
    local timeLable = ui.newLabel({
        text = MqTime.formatAsDay(endTime - Player:getCurrentTime()),
        size = 16,
        color = plantColor,
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
    })
    timeLable:setScale(1.2)
    timeLable:setAnchorPoint(cc.p(0.5, 0.5))
    timeLable:setPosition(vegetNodeSize.width/2, -25)
    vegetNode:addChild(timeLable)
    Utility.schedule(timeLable, function ()
        local timeLeft = endTime - Player:getCurrentTime()
        if timeLeft > 0 then
            timeLable:setString(string.format("%s", MqTime.formatAsDay(timeLeft)))
        else 
            self:requestGetInfo(self.mGuidId)
        end 
    end, 1.0)
end

-----------------------辅助函数----------------
-- 根据orderId获取土地信息
function VegetablesHomeLayer:getCurrentVegetInfo(orderId)
    local vegetInfo = {}
    for k,v in pairs(self.mVegetabelsLandList) do
        if v.OrderId == orderId then 
            vegetInfo = clone(v)
            break
        end 
    end

    return vegetInfo
end

-- 根据成熟时间和种子获取当前植物图片状态
function VegetablesHomeLayer:getVegetImageByTimeAndID(endTime, orderId)
    local timeLeft = endTime - Player:getCurrentTime()
    local matureOneTime = (VegetablesConfig.items[1].matureNeedTime)/4
    local image = self:getOneVegetPic(orderId, 2)
    if timeLeft <= matureOneTime then 
        image = self:getOneVegetPic(orderId, 3)
    elseif timeLeft > matureOneTime and timeLeft <= matureOneTime*2 then 
        image = self:getOneVegetPic(orderId, 2)
    elseif timeLeft > matureOneTime*2 and timeLeft <= matureOneTime*3 then 
        image = self:getOneVegetPic(orderId, 2)
    elseif timeLeft > matureOneTime*3 and timeLeft <= matureOneTime*4 then 
        image = self:getOneVegetPic(orderId, 2)
    end 

    return image
end

-- 修改土地信息（self.mVegetabelsLandList）
function VegetablesHomeLayer:modifyVegetInfo(vegetInfo)
    if next(vegetInfo) == nil or vegetInfo.OrderId <= 0 then 
        return
    end 
    self.mVegetabelsLandList[vegetInfo.OrderId] = {}
    self.mVegetabelsLandList[vegetInfo.OrderId] = vegetInfo

    -- 重新创建修改数据的这块土地
    self:createOneVeget(vegetInfo.OrderId)
end

-- 开垦弹窗
function VegetablesHomeLayer:unlockLandMsgBoxLayer(orderId)
    local resetUseItem = VegetablesConfig.items[1].unlockConsum
    local resdata = Utility.analysisStrResList(resetUseItem)
    local tempItem = resdata[1]
    local conNum = (orderId-6)*tempItem.num
    hintStr = TR("是否花费%s%d%s%s，开凿当前剑冢？", Enums.Color.eGreenH, conNum, Utility.getGoodsName(tempItem.resourceTypeSub, tempItem.modelId), "#ffffff")

    --提示框
    local okBtnInfo = {
        text = TR("确定"),
        clickAction = function(layerObj, btnObj)
            if not Utility.isResourceEnough(ResourcetypeSub.eDiamond, conNum) then
                return
            end
            self:requestUnlockLand()
            LayerManager.removeLayer(layerObj)
        end
    }
    local cencelInfo = {
        text = TR("取消"),
        clickAction = function(layerObj, btnObj)
            LayerManager.removeLayer(layerObj)
        end
    }
    MsgBoxLayer.addOKLayer(hintStr, TR("提示"), {okBtnInfo, cencelInfo})
end

-- 选择施肥弹窗
function VegetablesHomeLayer:applyFertilizerSelectLayer(vegetGuid)
    local function DIYFunction(layerObj, layerBg, layerBgSize)
        -- 黑色背景框
        local blackSize = cc.size(layerBgSize.width*0.9, (layerBgSize.height-100))
        local blackBg = ui.newScale9Sprite("c_17.png", blackSize)
        blackBg:setAnchorPoint(0.5, 0)
        blackBg:setPosition(layerBgSize.width/2, 30)
        layerBg:addChild(blackBg)

        -- 普通施肥
        local ordinaryBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("铁匠"),
            clickAction = function()
                if self.mSelfData.FertilizableNum <= 0 then 
                    ui.showFlashView({text = TR("没有铁匠招募令，无法雇佣铁匠！")})
                else 
                    self:requestApplyFertilizer(vegetGuid, true)
                end 
                LayerManager.removeLayer(layerObj)
            end
        })
        ordinaryBtn:setPosition(self.mMySelf and layerBgSize.width*0.3 or layerBgSize.width*0.5, 90)
        layerBg:addChild(ordinaryBtn)

        -- 普通施肥次数
        local ordinaryNode, ordinaryrLabel = ui.createSpriteAndLabel({
            imgName = "qqnc_83.png",
            labelStr = self.mSelfData.FertilizableNum,
            fontSize = 18,
            fontColor = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            outlineSize = 2,
        })
        ordinaryNode:setAnchorPoint(cc.p(0.5, 0.5))
        ordinaryrLabel:setPosition(ordinaryNode:getContentSize().width/2,15)
        ordinaryNode:setPosition(self.mMySelf and layerBgSize.width*0.3 or layerBgSize.width*0.5, 180)
        layerBg:addChild(ordinaryNode)

        -- 高级施肥
        local seniorGoodsId = VegetablesConfig.items[1].highLvFertilizerID
        local seniorBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("神匠"),
            clickAction = function()
                if self.mSelfData.SeniorFertilizerNum <= 0 then 
                    ui.showFlashView({text = TR("没有神匠招募令，无法雇佣神匠！")})
                else 
                    self:requestApplyFertilizer(vegetGuid, false)
                end 
                LayerManager.removeLayer(layerObj)
            end
        })
        seniorBtn:setPosition(layerBgSize.width*0.7, 90)
        layerBg:addChild(seniorBtn)
        -- 高级施肥查看其它玩家不显示
        seniorBtn:setVisible(self.mMySelf)

        -- 高级施肥次数
        local seniorGood = CardNode.createCardNode({
            resourceTypeSub = ResourcetypeSub.eVegetable,
            modelId = seniorGoodsId,
            num = self.mSelfData.SeniorFertilizerNum,
            allowClick = false,
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum},
        })
        seniorGood:setAnchorPoint(0.5, 0.5)
        seniorGood:setPosition(layerBgSize.width*0.7, 180)
        layerBg:addChild(seniorGood)
        -- 高级施肥查看其它玩家不显示
        seniorGood:setVisible(self.mMySelf)
    end

    MsgBoxLayer.addDIYLayer({
        bgSize = cc.size(572, 330),
        title = TR("选择铁匠"),
        closeBtnInfo = {},
        btnInfos = {},
        notNeedBlack = true,
        DIYUiCallback = DIYFunction
    })
end

-------------------------网络接口----------------
-- 请求自己可好友的菜园
function VegetablesHomeLayer:requestGetInfo(guidId, playName)
    -- 是否是自己
    self.mMySelf = guidId == PlayerAttrObj:getPlayerAttrByName("PlayerId")
    -- 保存当前是谁的菜园（用于植物时间到之后需要重新获取数据）
    self.mGuidId = guidId
    -- 重新清空菜园数据
    self.mVegetabelsLandList = {}
    -- 获取菜园数据
    HttpClient:request({
        moduleName = "TimedVegetablesInfo", 
        methodName = "GetInfo",
        svrMethodData = {guidId},
        callbackNode = self,
        callback = function (data)
            -- 判断返回数据
            if not data or data.Status ~= 0 then
                return
            end
            for k,v in pairs(data.Value.VegetablesLandList or {}) do
                self.mVegetabelsLandList[v.OrderId] = {}
                self.mVegetabelsLandList[v.OrderId] = clone(v)
            end
            self.mEndTime = data.Value.EndTime
            -- 创建9块土地
            self:creatVegetabelsLand()

            if self.mMySelf then 
                self.mSelfData = data.Value.SelfData or {}
                -- 刷新倒计时、积分、施肥次数。。。
                self:refreshMyInfo()
            end

            -- 显示／隐藏返还菜园按钮
            self.backBtn:setVisible(not self.mMySelf)
            self.onekeyMenuBtn:setVisible(self.mMySelf)

            -- 显示菜园玩家名
            self.mPlayerNameLabel:setString(TR("#b3ff80%s#ffa5a6的剑冢", playName and playName or ""))
            self.mPlayerNameLabel:setVisible(not self.mMySelf)
        end
    })
end

-- 开垦菜园
function VegetablesHomeLayer:requestUnlockLand()
    HttpClient:request({
        moduleName = "TimedVegetablesInfo", 
        methodName = "UnlockLand",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
            -- 判断返回数据
            if not data or data.Status ~= 0 then
                return
            end

            ui.showFlashView({text = TR("剑冢开凿成功！")})
            -- 修改当前土地的信息
            self:modifyVegetInfo(data.Value.VegetablesLandInfo)
        end
    })
end

-- 施肥
--[[
    vegetGuid:菜地ID
    isOrdinary:施肥是否是普通施肥
]]
function VegetablesHomeLayer:requestApplyFertilizer(vegetGuid, isOrdinary)
    HttpClient:request({
        moduleName = "TimedVegetablesInfo", 
        methodName = "ApplyFertilizer",
        svrMethodData = {vegetGuid, isOrdinary},
        callbackNode = self,
        callback = function (data)
            -- 判断返回数据
            if not data or data.Status ~= 0 then
                return
            end
            ui.showFlashView({text = TR("雇佣成功！")})
            -- 修改当前土地的相关信息
            self:modifyVegetInfo(data.Value.VegetablesLandInfo)

            self.mSelfData = data.Value.SelfData or {}
            -- 刷新倒计时、积分、施肥次数。。。
            self:refreshMyInfo()
        end
    })
end

-- 摘取
--[[
    vegetGuid:菜地ID
]]
function VegetablesHomeLayer:requestHarvest(vegetGuid)
    HttpClient:request({
        moduleName = "TimedVegetablesInfo", 
        methodName = "Harvest",
        svrMethodData = {vegetGuid},
        callbackNode = self,
        callback = function (data)
            -- 判断返回数据
            if not data or data.Status ~= 0 then
                return
            end

            -- 显示领取到的奖励
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)

            -- 修改当前土地的相关信息
            self:modifyVegetInfo(data.Value.VegetablesLandInfo)
        end
    })
end

-- 偷取取
--[[
    vegetGuid:菜地ID
]]
function VegetablesHomeLayer:requestSteal(vegetGuid)
    HttpClient:request({
        moduleName = "TimedVegetablesInfo", 
        methodName = "Steal",
        svrMethodData = {vegetGuid},
        callbackNode = self,
        callback = function (data)
            -- 判断返回数据
            if not data or data.Status ~= 0 then
                return
            end

            -- 显示领取到的奖励
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)

            -- 修改当前土地的相关信息
            self:modifyVegetInfo(data.Value.VegetablesLandInfo)
        end
    })
end

-- 获取好友列表信息
--[[
    callback:  回调
]]
function VegetablesHomeLayer:requestFriendList(callback)
    HttpClient:request({
        moduleName = "TimedVegetablesInfo", 
        methodName = "GetFriendList",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
            -- 判断返回数据
            if not data or data.Status ~= 0 then
                return
            end
            -- 肥料可领取剩余次数
            self.mCanGetCount = data.Value.Count

            if callback then
                callback(data)
            end
        end
    })
end

-- 送肥料
--[[
    friendPlayerId:  好友id
]]
function VegetablesHomeLayer:requestSendFriend(friendPlayerId)
    HttpClient:request({
        moduleName = "TimedVegetablesInfo", 
        methodName = "SendFriend",
        svrMethodData = {friendPlayerId},
        callbackNode = self,
        callback = function (data)
            -- 判断返回数据
            if not data or data.Status ~= 0 then
                return
            end
            -- 肥料可领取剩余次数
            self.mCanGetCount = data.Value.Count

            -- 刷新列表
            if self.mFriendLayer and not tolua.isnull(self.mFriendLayer) then
                self.mFriendLayer.refreshFriendList(data.Value.Info)
            end
        end
    })
end

-- 批量送肥料
function VegetablesHomeLayer:requestBatchSendFriend()
    HttpClient:request({
        moduleName = "TimedVegetablesInfo", 
        methodName = "BatchSendFriend",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
            -- 判断返回数据
            if not data or data.Status ~= 0 then
                return
            end
            -- 肥料可领取剩余次数
            self.mCanGetCount = data.Value.Count

            -- 刷新列表
            if self.mFriendLayer and not tolua.isnull(self.mFriendLayer) then
                self.mFriendLayer.refreshFriendList(data.Value.Info)
            end
        end
    })
end

-- 领取肥料
--[[
    friendPlayerId:  好友id
]]
function VegetablesHomeLayer:requestGetFertilizer(friendPlayerId)
    if self.mCanGetCount and self.mCanGetCount <= 0 then
        ui.showFlashView(TR("今日铁匠招募已达上限"))
        return
    end

    HttpClient:request({
        moduleName = "TimedVegetablesInfo", 
        methodName = "ReceiveFriend",
        svrMethodData = {friendPlayerId},
        callbackNode = self,
        callback = function (data)
            -- 判断返回数据
            if not data or data.Status ~= 0 then
                return
            end
            -- 肥料可领取剩余次数
            self.mCanGetCount = data.Value.Count

            -- 刷新列表
            if self.mFriendLayer and not tolua.isnull(self.mFriendLayer) then
                self.mFriendLayer.refreshFriendList(data.Value.Info)
            end
            -- 提示
            ui.showFlashView(TR("招募成功"))
            -- 刷新今日剩余施肥次数
            self.mFertNumLabel:setString(TR("今日剩余铁匠招募次数:%d", data.Value.Num or 0))
            self.mSelfData.FertilizableNum = data.Value.Num or 0
        end
    })
end

-- 批量领取肥料
function VegetablesHomeLayer:requestGetBatchFertilizer()
    if self.mCanGetCount and self.mCanGetCount <= 0 then
        ui.showFlashView(TR("今日铁匠招募已达上限"))
        return
    end

    HttpClient:request({
        moduleName = "TimedVegetablesInfo", 
        methodName = "BatchReceive",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
            -- 判断返回数据
            if not data or data.Status ~= 0 then
                return
            end
            -- 肥料可领取剩余次数
            self.mCanGetCount = data.Value.Count

            -- 刷新列表
            if self.mFriendLayer and not tolua.isnull(self.mFriendLayer) then
                self.mFriendLayer.refreshFriendList(data.Value.Info)
            end
            -- 提示
            ui.showFlashView(TR("招募成功"))
            -- 刷新今日剩余施肥次数
            self.mFertNumLabel:setString(TR("今日剩余雇佣次数:%d", data.Value.Num or 0))
            self.mSelfData.FertilizableNum = data.Value.Num or 0
        end
    })
end

-- 一键种菜
function VegetablesHomeLayer:requestOneKeySeed()
    HttpClient:request({
        moduleName = "TimedVegetablesInfo", 
        methodName = "SeedOneKey",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
            -- 判断返回数据
            if not data or data.Status ~= 0 then
                return
            end

            for k,v in pairs(data.Value.VegetablesLandList or {}) do
                self.mVegetabelsLandList[v.OrderId] = {}
                self.mVegetabelsLandList[v.OrderId] = clone(v)
            end
            -- 创建9块土地
            self:creatVegetabelsLand()
        end
    })
end

-- 一键施肥
function VegetablesHomeLayer:requestOneKeyFertilize()
    HttpClient:request({
        moduleName = "TimedVegetablesInfo", 
        methodName = "FertilizeOneKey",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
            -- 判断返回数据
            if not data or data.Status ~= 0 then
                return
            end

            for k,v in pairs(data.Value.VegetablesLandList or {}) do
                self.mVegetabelsLandList[v.OrderId] = {}
                self.mVegetabelsLandList[v.OrderId] = clone(v)
            end
            -- 创建9块土地
            self:creatVegetabelsLand()

            if self.mMySelf then 
                self.mSelfData = data.Value.SelfData or {}
                -- 刷新倒计时、积分、施肥次数。。。
                self:refreshMyInfo()
            end
        end
    })
end

-- 一键收获
function VegetablesHomeLayer:requestOneKeyHarvest()
    HttpClient:request({
        moduleName = "TimedVegetablesInfo", 
        methodName = "HarvestOneKey",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
            -- 判断返回数据
            if not data or data.Status ~= 0 then
                return
            end

            -- 显示领取到的奖励
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)

            for k,v in pairs(data.Value.VegetablesLandList or {}) do
                self.mVegetabelsLandList[v.OrderId] = {}
                self.mVegetabelsLandList[v.OrderId] = clone(v)
            end
            -- 创建9块土地
            self:creatVegetabelsLand()
        end
    })
end

return VegetablesHomeLayer
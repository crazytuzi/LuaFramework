--[[
    文件名：ExpediTeamLayer.lua
    文件描述：副本组队界面
    创建人：chenzhong
    创建时间：2017.07.10
]]
local ExpediTeamLayer = class("ExpediTeamLayer", function()
    return display.newLayer()
end)

--[[
-- 参数
    nodeInfo: 副本信息
    teamInfo: 队伍信息
    isDoubleActivity: 是否有翻倍活动
]]
function ExpediTeamLayer:ctor(params)
    ChatBtnLayer:clearBtn()
    PlayerAttrObj:changeAttr({
        isExpedTeam = true
    })
    self.mNodeInfo = params.nodeInfo                -- 副本信息
    self.mTeamInfo = params.teamInfo                -- 队伍信息
    self.mMemberList = self.mTeamInfo.Member                -- 队伍成员列表
    self.mNodeId = self.mNodeInfo.NodeModelId or 1111       -- 副本节点ID
    self.mIsUseDouble = self:getIsUseDouble() -- 默认是否使用真气翻倍令牌
    self.mIsPass = self.mNodeInfo.IsPass
    self.mIsSalesActivity = params.isDoubleActivity or false               -- 是否有真气翻倍活动
    -- 是否是队长
    self.mPlayerId = PlayerAttrObj:getPlayerAttrByName("PlayerId")
    self.mIsLeader = self.mPlayerId == self.mTeamInfo.LeaderId
    if (params.autoWar and params.autoWar == 1 and self.mIsLeader) then  -- 如果战斗失败一场之后 退出来就不会自动开战了 
        self.mAutoWar = false 
        -- 此时需要刷新自动开战
        self:refreshAutoFight()
    else 
        self.mAutoWar =  true -- 自动开战（进来默认为true）
    end     
    self.mIsGuaJi = true
    -- 全服邀请冷却时间
    self.mCDTime = 0
    -- 挑战一次消耗的体力
    self.mUseVitNum = ExpeditionMapModel.items[1].challengeUse
    -- 邀请豪侠一次消耗元宝数
    self.mUseInfo = Utility.analysisStrResList(ExpeditionConfig.items[1].strongInviteNeed)
    --一个队伍最多认识
    self.mMemberNum = 3
    -- 玩家的准备信息
    self.readyList = {}

    -- UI父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 初始化UI
    self:initUI()

    -- 创建队伍宣言
    self:createTeamNotice()

    -- 底部按钮
    self:createBottomBtns()

    -- 创建三个敌人
    self:creatEnemy()

    -- 放三个伙伴的头像
    local viewLayout = ccui.ScrollView:create()
    viewLayout:setDirection(ccui.ScrollViewDir.vertical)
    viewLayout:setContentSize(cc.size(640, 277))
    viewLayout:setAnchorPoint(cc.p(0.5, 0.5))
    viewLayout:setPosition(320, 475)
    self.mParentLayer:addChild(viewLayout)
    self.mViewLayout = viewLayout
    -- 己方伙伴儿
    self:createPartner()

    -- 显示概率掉落物品
    self:showReward()

    if self.mIsLeader then
        -- 一键匹配和组队邀请按钮
        self:addInvitationBtn()

        -- 显示可以拖动调整位置
        self:tipLabel()
    end

    -- 从战斗返回组队界面，请求最新的队伍信息
    self:requestGetTeamInfo()
    -- 是否有双倍活动
    self:requestGetTimedActivityInfo()

    -- 注册队伍信息变化事件
    Notification:registerAutoObserver(self.mParentLayer, function(node, data)
        -- print("111111")
        -- dump(data,"eExpeditionPrefix")
        -- 开始挂机
        if data.GuajiStatus then 
            self:getGuaJiInfo()
        else 
            self:requestGetTeamInfo(true)
        end     
    end, EventsName.eExpeditionPrefix)
    -- 注册战斗开始事件
    Notification:registerAutoObserver(self.mParentLayer, function()
        -- print("2222222")
        self:requestGetFightResult(self.mMemberList)
    end, EventsName.eExpeditionFightResultPrefix)

    -- 注册连战请求事件（玩家准备状态）
    Notification:registerAutoObserver(self.mParentLayer, function(node, data)
        -- print("55555555")
        self.readyList = {}
        self.readyList = data.readyInfoDetils or {}
        -- 重新获取成员数据
        self:requestGetTeamInfo()
        -- self:createPartner()
    end, EventsName.eSureStartFight)
end

--显示聊天按钮
function ExpediTeamLayer:onExit()
    ChatBtnLayer:create()
end

-- 初始化UI
function ExpediTeamLayer:initUI()
    -- 背景
    local bgSprite = ui.newSprite("zdfb_25.jpg")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)
    self.mBgSprite = bgSprite

    -- 返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(604, 1050),
        clickAction = function()
            -- 解散队伍
            self:requestExitTeam(PlayerAttrObj:getPlayerAttrByName("PlayerId"))
        end
    })
    bgSprite:addChild(closeBtn,1)

    -- 显示当前副本名字
    local nameBg = ui.newSprite("zdfb_10.png")
    nameBg:setPosition(320, 1050)
    bgSprite:addChild(nameBg)
    local nameBgSize = nameBg:getContentSize()
    local nameLabel = ui.newLabel({
        text = string.format("%s", ExpeditionNodeModel.items[self.mNodeId].name),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 24,
    })
    nameLabel:setPosition(nameBgSize.width/2, nameBgSize.height/2)
    nameBg:addChild(nameLabel)

    -- 添加对决图片
    local pkSprite = ui.newSprite("zdfb_24.png")
    pkSprite:setPosition(320, 625)
    bgSprite:addChild(pkSprite)

    -- 我要发言按钮
    local sendMessageBtn = ui.newButton({
        normalImage = "tb_32.png",
        clickAction = function()
            if not ModuleInfoObj:moduleIsOpen(ModuleSub.eChat, true) then
                return
            end
            LayerManager.addLayer({
                name = "Chat.ChatLayer",
                data = {chatChanne = Enums.ChatChanne.eTeam},
                cleanUp = false,
            })
        end
    })
    sendMessageBtn:setPosition(60, 928)
    sendMessageBtn:setScale(0.9)
    bgSprite:addChild(sendMessageBtn)
    -- 聊天按钮添加小红点
    local function dealRedDotVisible(redDotSprite)
        redDotSprite:setVisible(ChatMng:getUnreadCount(Enums.ChatChanne.eTeam) > 0)
        if ChatMng:getUnreadCount(Enums.ChatChanne.eTeam) > 0 then
            local lastData = ChatMng:getLastRecData()
            self:requestGetTeamInfo(false)
            self:showChat(lastData)
        end

    end
    local eventNames = {EventsName.eChatUnreadPrefix .. tostring(Enums.ChatChanne.eTeam), EventsName.eChatNewMsg}
    ui.createAutoBubble({parent = sendMessageBtn, eventName = eventNames, refreshFunc = dealRedDotVisible})

    -- 修改次数
    local changCountBtn = ui.newButton({
        normalImage = "tb_206.png",
        clickAction = function()
            self:changFightCount()
        end
    })
    changCountBtn:setPosition(160, 928)
    changCountBtn:setScale(0.9)
    bgSprite:addChild(changCountBtn)
    changCountBtn:setVisible(self.mIsLeader)

    -- 创建底部导航和顶部玩家信息部分
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.eChallenge,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)

    -- 添加一个奖励加成的显示
    local rewardLabelBg = ui.newSprite("zdfb_28.png")
    rewardLabelBg:setAnchorPoint(0, 0.5)
    rewardLabelBg:setPosition(450, 625)
    bgSprite:addChild(rewardLabelBg)
    self.rewardAddLabel = ui.newLabel({
        text = string.format("+%s%%", 0),
        size = 28,
        color = cc.c3b(0xff, 0xf3, 0xc9),
        outlineColor = cc.c3b(0x8a, 0x35, 0x0e),
        outlineSize = 2,
    })
    self.rewardAddLabel:setAnchorPoint(0, 0.5)
    self.rewardAddLabel:setPosition(120, 27)
    rewardLabelBg:addChild(self.rewardAddLabel)

    local doubleUum = GoodsObj:getCountByModelId(16050265)
    local isUseBox
    isUseBox = ui.newCheckbox({
        normalImage = "c_60.png",
        selectImage = "c_61.png",
        text = TR("真气翻倍令"),
        isRevert = true,
        outlineColor = Enums.Color.eBlack,
        callback = function(isSelect)
            if self.mIsSalesActivity then
                ui.showFlashView({text = TR("双倍活动开启期间无法使用双倍令!")})
                isUseBox:setCheckState(not isSelect)
                return
            elseif doubleUum <= 0 then 
                ui.showFlashView({text = TR("真气翻倍令不足，可通过每日任务获得！")})
                isUseBox:setCheckState(not isSelect)
                return
            end     
            self.mIsUseDouble = isSelect
            self:setIsUseDouble(self.mIsUseDouble)
        end
    })
    isUseBox:setAnchorPoint(cc.p(0, 0.5))
    isUseBox:setPosition(10, 650)
    self.mIsUseBox = isUseBox
    self.mParentLayer:addChild(isUseBox)
    -- 是否使用真气翻倍令
    if doubleUum <= 0 or self.mIsSalesActivity then
        self.mIsUseDouble = false
    end
    self:setIsUseDouble(self.mIsUseDouble)

    -- 剩余多少个翻倍令
    local doubleNumLabel = ui.newLabel({
        text = TR("剩余: #77fb5e%s个", doubleUum),
        size = 22,
        outlineColor = cc.c3b(0x59, 0x28, 0x17),
        outlineSize = 2,
    })
    doubleNumLabel:setAnchorPoint(0, 0.5)
    doubleNumLabel:setPosition(10, 610)
    self.mParentLayer:addChild(doubleNumLabel)
end

-- 获取真气翻倍令是否选中
function ExpediTeamLayer:getIsUseDouble()
    if LocalData:getGameDataValue("IsUseDouble") ~= nil then
        return LocalData:getGameDataValue("IsUseDouble")
    end

    return true
end

-- 设置真气翻倍令是否选中
function ExpediTeamLayer:setIsUseDouble(isUse)
    LocalData:saveGameDataValue("IsUseDouble", isUse)
    if self.mIsUseBox then
        self.mIsUseBox:setCheckState(isUse)
    end
    -- 通知服务端是否使用了双倍令牌
    self:requestIsUseDouble()
end

--展示发言泡泡给玩家看
function ExpediTeamLayer:showChat(data)
    data = data or {}
    if not data then
        return
    end
    local actionArray = {}
    local chatBoxes = {}
    local chatBoxPos = {
        [1] = {pos = cc.p(200, 620), labelOffset = cc.p(20, 47), flippedX = false},
        [2] = {pos = cc.p(420, 620), labelOffset = cc.p(20, 47), flippedX = false},
        [3] = {pos = cc.p(400, 620), labelOffset = cc.p(20, 47), flippedX = true}
    }
    table.insert(actionArray, cc.CallFunc:create(function()
        for key, team in ipairs(self.mTeamInfo.Member) do
            if not  data.FromPlayer.ExtendInfo then
               return
            end
            if data.FromPlayer.ExtendInfo.Name == team.Name then
                local tempStr = data.Message
                if string.utf8len(data.Message) > 20  then
                    tempStr = string.utf8sub(tempStr, 1, 20).."..."
                end
                tempStr = ChatMng:faceStrUnpack(tempStr)

                local chatBox = ui.newSprite("zf_07.png")
                self.mParentLayer:addChild(chatBox)
                local chattext = ui.newLabel({
                    text = tempStr,
                    size = 20,
                    color = cc.c3b(0x46, 0x22, 0x0d),
                    dimensions = cc.size(chatBox:getContentSize().width - 40 , 0),
                    anchorPoint = cc.p(0, 0.5),
                })
                chattext:setImageElementScale(0.3)
                chattext:setPosition(chatBoxPos[team.PosId].labelOffset)
                chatBox:setPosition(chatBoxPos[team.PosId].pos)
                chatBox:addChild(chattext)
                chatBox:setFlippedX(chatBoxPos[team.PosId].flippedX)
                table.insert(chatBoxes, chatBox)
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

-- 创建按钮（挑战  解散）
function ExpediTeamLayer:createBottomBtns()
    local btnInfos = {
        {   -- 一键匹配
            normalImage = "c_28.png",
            text = self.mIsLeader and TR("一键匹配") or TR("退出队伍"),
            clickAction = function()
                if self.mIsLeader then 
                    self:requestAutoMatch()
                else 
                    self:requestExitTeam(PlayerAttrObj:getPlayerAttrByName("PlayerId"))
                end     
            end
        }
    }

    if self.mIsLeader then
        -- 如果是队长添加开始战斗按钮
        local starBtn = {
            normalImage = "c_28.png",
            text = TR("开始战斗"),
            tag = 1,
            clickAction = function(startObj)
                if self.mTipSprite then 
                    self.mTipSprite:stopAllActions()
                    self.mTipSprite:removeFromParent()
                    self.mTipSprite = nil
                end 
                -- 如果挂机就不调用战斗
                if self.mIsGuaJi then 
                    self:startGuaJi()
                    return
                end 

                -- 发起连战
                self:requestContinueFight(self.mTeamInfo.NeedBattleCount, 0, startObj)
            end
        }
        table.insert(btnInfos, starBtn)
    end

    for index, btnInfo in ipairs(btnInfos) do
        local startPosX, space = self.mIsLeader and 200 or 320, 200
        local tempBtn = ui.newButton(btnInfo)
        tempBtn:setPosition(startPosX + (index - 1) * space, self.mIsLeader and 140 or 160)
        self.mParentLayer:addChild(tempBtn)

        if btnInfo.tag and btnInfo.tag == 1 then -- 开始战斗按钮后面需要
            self.mStarBtn = tempBtn
        end     
    end
end

-- 创建三个敌人的头像
function ExpediTeamLayer:creatEnemy( )
    -- 不添加到layer算出每个英雄之间的间距
    local enemyBg = ui.newSprite("zdfb_09.png")
    local enemySize = enemyBg:getContentSize()
    local px = (640 - 3*enemySize.width)/4

    -- 创建一个node
    local parentSize = cc.size(640, enemySize.height)
    local enemyNode = cc.Node:create()
    enemyNode:setIgnoreAnchorPointForPosition(false) --忽略锚点
    enemyNode:setAnchorPoint(0.5, 0.5)
    enemyNode:setContentSize(parentSize)
    enemyNode:setPosition(320, 820)
    self.mParentLayer:addChild(enemyNode)

    -- 该关卡的镇守者名单
    local enemyList = string.split(ExpeditionNodeModel.items[self.mNodeId].heroModelID, "|")
    for i, v in ipairs(enemyList) do
        -- 添加对决图片
        local enemyBg = ui.newScale9Sprite("c_83.png", enemySize)
        enemyBg:setAnchorPoint(cc.p(0, 0.5))
        enemyBg:setPosition(px + (i-1)*(px+enemySize.width), parentSize.height/2)
        enemyNode:addChild(enemyBg)
        -- NPCID
        local enemyModelId = tonumber(string.split(v, ",")[2])
        -- -- 显示名字战力的背景
        local nameFapZone = ui.newLabel({
            text = TR("%s\n#ffffff战力%s", Utility.getGoodsName(ResourcetypeSub.eHero, enemyModelId), Utility.numberFapWithUnit(self.mNodeInfo.NodeFap[i])),
            size = 20,
            outlineColor = cc.c3b(0x37, 0x30, 0x2c),
            outlineSize = 2,
            align = cc.TEXT_ALIGNMENT_CENTER,
            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
        })
        nameFapZone:setPosition(enemySize.width/2, 65)
        nameFapZone:setAnchorPoint(0.5, 1)
        enemyBg:addChild(nameFapZone, 1)

        -- 显示人物头像
        local heroHead = Figure.newHero({
            heroModelID = enemyModelId,
            position = cc.p(enemySize.width/2, 20),
            scale = 0.13
        })
        enemyBg:addChild(heroHead)
    end
end

-- 控件位置的相关变量
local columnMaxCount = 3
local rowCount = 1
local heroWidth, heroHeight = 207, 277
local originalPosX, originalPosY = 110, 130
local deltaX, deltaY = 210, 220
-- 创建三个伙伴儿
function ExpediTeamLayer:createPartner()
    self.mViewLayout:removeAllChildren()
    -- 队员位置
    self.mMemberPos = {}
    -- 队员节点
    self.mMemberLayout = {}
    self.mHeroNodes = {}

    -- 重新组装队伍成员列表，以PosId为key
    local tempList = {}
    for _, item in ipairs(self.mMemberList) do
        tempList[item.PosId] = item
    end
    self.mMemberList = tempList

    for i = 1, 3 do
        local memberPos = {}
        -- 框架位置
        memberPos.x = originalPosX + deltaX * math.mod(i-1, columnMaxCount)
        memberPos.y = originalPosY - deltaY * math.floor((i-1) / columnMaxCount)
        -- 创建空框架
        local itemLayout = ccui.Layout:create()
        itemLayout:setContentSize(cc.size(heroWidth, heroHeight))
        itemLayout:setAnchorPoint(cc.p(0.5, 0.5))
        itemLayout:setPosition(memberPos)
        self.mViewLayout:addChild(itemLayout)
        -- 保存队员的信息
        self.mMemberLayout[i] = itemLayout
        self.mMemberPos[i] = memberPos

        -- 创建单个成员信息
        local hero = self:createMemberItem(i)
        if hero then
            self.mViewLayout:addChild(hero)
            self.mHeroNodes[i] = hero
            hero.teamIndex = i

            -- 注册事件
            if self.mIsLeader then
                self:registerDragTouch(hero, self.mViewLayout)
            end
        end
    end

    -- 队伍是否已满之后才可以换位置
    for _, item in ipairs(self.mHeroNodes) do
        if self.mIsLeader and #self.mMemberList == columnMaxCount then
            item:setTouchEnabled(true)
        else
            item:setTouchEnabled(false)
        end
    end

    -- 刷新宣言
    self:refreshTeamNotice(self.mTeamInfo.Slogan)

    -- 刷新奖励加成信息
    self:refreshReward()

    -- 判断是否需要自动开始战斗
    if self.mAutoWar and self.mIsLeader then 
        self:autoFight()
    end     
end

-- 展示掉落物品
function ExpediTeamLayer:showReward()
    -- 背景
    local rewardBg = ui.newSprite("zdfb_11.png")
    rewardBg:setPosition(320, 275)
    self.mParentLayer:addChild(rewardBg)

    -- 掉落的物品列表
    local rewardList = Utility.analysisStrResList(ExpeditionNodeModel.items[self.mNodeId].fightRewards)
    local rewardListView = ui.createCardList({
        maxViewWidth = 340,
        space = 10,
        cardDataList = rewardList,
        allowClick = true,
        cardShape = Enums.CardShape.eSquare
    })
    rewardListView:setAnchorPoint(cc.p(0, 0.5))
    rewardListView:setPosition(110, rewardBg:getContentSize().height/2)
    rewardBg:addChild(rewardListView)
    rewardListView:setScale(0.8)

    -- 如果不是队长 需要在掉落物品背景上展示连战次数
    if not self.mIsLeader then
        local figtBg = ui.newSprite("zdfb_15.png")
        figtBg:setPosition(500, rewardBg:getContentSize().height/2)
        rewardBg:addChild(figtBg)
        local figtNum = ui.newLabel({
            text = TR("连战:%s次", self.mTeamInfo.NeedBattleCount),
            size = 22,
            color = Enums.Color.eNormalWhite,
            outlineColor = Enums.Color.eBlack,
        })
        figtNum:setPosition(50, 40)
        figtNum:setRotation(-18)
        figtBg:addChild(figtNum)
        self.mFightNum1 = figtNum
    end
end

-- 助阵豪侠和组队邀请按钮
function ExpediTeamLayer:addInvitationBtn()
    local btnInfos = {
        {   -- 助阵豪侠
            normalImage = "tb_184.png",
            tag = 2,
            clickAction = function()
                -- self:requestAutoMatch()
                self:getHighFapNpc()
            end
        },
        {   -- 组队邀请
            normalImage = "tb_33.png",
            tag = 1,
            clickAction = function()
                if #self.mMemberList >= 3 then
                    ui.showFlashView(TR("当前队伍已满员，无法继续组队"))
                    return
                end
                if self.mCDTime > 0 then
                    ui.showFlashView(TR("全服邀请冷却中"))
                    return
                end

                self:requestInviteAllServerPlayer()
            end
        }
    }

    for index, btnInfo in ipairs(btnInfos) do
        local startPosX, space = 450, 110
        local tempBtn = ui.newButton(btnInfo)
        tempBtn:setPosition(startPosX + (index - 1) * space, 270)
        self.mParentLayer:addChild(tempBtn, 1)

        -- 全服邀请按钮后面需要用到
        if btnInfo.tag == 1 then
            self.mInvitationBtn = tempBtn
        elseif btnInfo.tag == 2 then 
            self.mHighNPCBtn = tempBtn    
        end
    end

    -- 倒计时
    self.mTimeLabel = ui.newLabel({
        text = TR("%s秒", 0),
        size = 20,
        color = cc.c3b(0x50, 0xec, 0xff),
        outlineColor = cc.c3b(0x21, 0x21, 0x21),
        outlineSize = 2,
    })
    self.mTimeLabel:setPosition(cc.p(self.mInvitationBtn:getContentSize().width / 2, self.mInvitationBtn:getContentSize().height/2))
    self.mInvitationBtn:addChild(self.mTimeLabel)
    self.mTimeLabel:setVisible(false)
end

-- 获取高战力助阵豪侠
function ExpediTeamLayer:getHighFapNpc()
    -- 获取当前节点助阵豪侠战力
    local highFap = 0
    local highImageId = headImageId
    for k,v in pairs(ExpeditionPlayerPreviewRelation.items) do
        if v.nodeModelID == self.mNodeId then 
            highFap = v.FAP
            highImageId = v.headImageId
        end     
    end
    local btnlist = {
        {
            text = TR("邀请"),
            position = cc.p(286, 60),
            normalImage = "c_28.png",
            clickAction = function (layerObj)
                if Utility.isResourceEnough(self.mUseInfo[1].resourceTypeSub, self.mTeamInfo.NeedBattleCount*self.mUseInfo[1].num) then
                    self:requestAutoMatch(self.mTeamInfo.NeedBattleCount)
                    LayerManager.removeLayer(layerObj)
                end     
            end
        }
    }

    -- 佣兵令不足时提示DIY函数
    local function DIYMsgBoxFunc(layerObj, layerBgSprite, bgSize)
        -- 添加背景
        local heroBg = ui.newScale9Sprite("c_65.png", cc.size(450, 140))
        heroBg:setPosition(bgSize.width/2, bgSize.height/2+40)
        layerBgSprite:addChild(heroBg)

        -- NPC头像
        local npcHead = CardNode.createCardNode({
            resourceTypeSub = ResourcetypeSub.eHero,
            modelId = highImageId,
            cardShowAttrs = {CardShowAttr.eBorder},
            onClickCallback = function ()end
        })
        npcHead:setAnchorPoint(0, 0.5)
        npcHead:setPosition(20, 70)
        heroBg:addChild(npcHead)
        -- 统一用红色头像匡
        npcHead:setCardBorder(18)
        -- 头像上面显示助阵标签
        local titleBg = ui.newSprite("c_57.png")
        titleBg:setAnchorPoint(cc.p(0, 1))
        titleBg:setScale(0.7)
        titleBg:setPosition(cc.p(0, 95))
        npcHead:addChild(titleBg)
        local font = ui.newLabel({
            text = TR("助 阵"),
            size = 21,
        })
        font:setPosition(cc.p(25, 50))
        titleBg:addChild(font)
        font:setRotation(-45)
        titleBg:setVisible(not isNoTitle)
        local nameLabel = ui.newLabel({
            text = TR("助阵豪侠"),
            size = 22,
            color = cc.c3b(0x44, 0x1f, 0x0a),
            align = cc.TEXT_ALIGNMENT_CENTER,
            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
        })
        nameLabel:setAnchorPoint(0, 0.5)
        nameLabel:setPosition(150, 100)
        heroBg:addChild(nameLabel)
        local fapLabel = ui.newLabel({
            text = TR("战力: #d17b00%s", Utility.numberFapWithUnit(highFap)),
            size = 20,
            color = cc.c3b(0x44, 0x1f, 0x0a),
            align = cc.TEXT_ALIGNMENT_CENTER,
            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
        })
        fapLabel:setAnchorPoint(0, 0.5)
        fapLabel:setPosition(150, 70)
        heroBg:addChild(fapLabel)
        local introLabel = ui.newLabel({
            text = TR("邀请助阵豪侠无奖励加成"),
            size = 20,
            color = cc.c3b(0x44, 0x1f, 0x0a),
            align = cc.TEXT_ALIGNMENT_CENTER,
            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
        })
        introLabel:setAnchorPoint(0, 0.5)
        introLabel:setPosition(150, 40)
        heroBg:addChild(introLabel)

        -- 元宝消耗
        local dimIntro = ui.newLabel({
            text = TR("连战%s次花费", self.mTeamInfo.NeedBattleCount),
            size = 22,
            color = cc.c3b(0x44, 0x1f, 0x0a),
            align = cc.TEXT_ALIGNMENT_CENTER,
            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
        })
        dimIntro:setAnchorPoint(0, 0.5)
        dimIntro:setPosition(150, 120)
        layerBgSprite:addChild(dimIntro)

        local tempSprite = ui.newSprite("c_23.png")
        tempSprite:setPosition(dimIntro:getContentSize().width + 160, 120)
        tempSprite:setAnchorPoint(0, 0.5)
        layerBgSprite:addChild(tempSprite)
        -- 物品图片标识
        local tempStr = Utility.getDaibiImage(self.mUseInfo[1].resourceTypeSub)
        local daibiSprite = ui.newSprite(tempStr)
        daibiSprite:setAnchorPoint(cc.p(1, 0.5))
        daibiSprite:setPosition(30, tempSprite:getContentSize().height / 2)
        tempSprite:addChild(daibiSprite)
        -- 物品数量的label
        local tempLabel = ui.newLabel({
            text = self.mTeamInfo.NeedBattleCount*self.mUseInfo[1].num,
            size = 18,
            color = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        })
        tempLabel:setAnchorPoint(cc.p(0, 0.5))
        tempLabel:setPosition(30, tempSprite:getContentSize().height / 2)
        tempSprite:addChild(tempLabel)
    end
    -- 豪侠助阵的弹窗
    MsgBoxLayer.addDIYLayer({
        title = TR("豪侠邀请"),
        notNeedBlack = true,
        bgSize = cc.size(572, 382),
        btnInfos = btnlist,
        closeBtnInfo = {},
        DIYUiCallback = DIYMsgBoxFunc
    })
end

-- 创建单个队员信息
function ExpediTeamLayer:createMemberItem(index)
    local playerInfo = self.mMemberList[index]
    local pos = self.mMemberPos[index]

    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(heroWidth, heroHeight))
    layout:setAnchorPoint(cc.p(0.5, 0.5))
    layout:setPosition(pos.x, pos.y)

    -- 底板
    local bgSprite = ui.newScale9Sprite("c_83.png", cc.size(heroWidth,heroHeight))
    bgSprite:setAnchorPoint(cc.p(0.5, 0.5))
    bgSprite:setPosition(heroWidth / 2, heroHeight / 2+10)
    layout:addChild(bgSprite)

    -- 玩家名称、战力、服务器等信息
    if not playerInfo then
        -- 灰色底板
        local addBtn = ui.newButton({
            normalImage = "c_22.png",
            anchorPoint = cc.p(0.5, 0.5),
            position = cc.p(heroWidth/2, heroHeight/2),
            clickAction = function()
                if self.mIsLeader then
                    -- 邀请组队界面
                    LayerManager.addLayer({
                        name = "teambattle.TeambattleChooseTeamMateLayer",
                        data = {
                            copyID = self.mNodeId,
                            teamID = self.mTeamInfo.TeamId,
                            callback = function()
                                if self.mCDTime > 0 then
                                    ui.showFlashView(TR("全服邀请冷却中"))
                                else
                                    self:requestInviteAllServerPlayer()
                                end
                            end,
                            callback2 = function()
                                self:requestAutoMatch()
                            end,
                            moduleName = ModuleSub.eExpedition,
                        },
                        cleanUp = false,
                    })
                else
                    ui.showFlashView(TR("你不是队长，不能邀请好友"))
                end
            end
        })
        bgSprite:addChild(addBtn)
    else
        -- 显示名字战力的背景
        local nameFapBg = ui.newScale9Sprite("c_83.png", cc.size(heroWidth,heroHeight))
        nameFapBg:setAnchorPoint(cc.p(0.5, 0))
        nameFapBg:setPosition(heroWidth/2, 0)
        bgSprite:addChild(nameFapBg, 1)

        -- 根据是否显示加成调整位置
        local px = 0--playerInfo.RelationAdd == 0 and 0 or -5

        local nameFapZone = ui.newLabel({
            text = TR("%s\n#ffffff%s\n战力%s", playerInfo.Name, playerInfo.ServerName, Utility.numberFapWithUnit(playerInfo.FAP)),
            size = 20,
            -- color = Utility.getQualityColor(tempModel.quality, 1),
            outlineColor = cc.c3b(0x37, 0x30, 0x2c),
            outlineSize = 2,
            align = cc.TEXT_ALIGNMENT_CENTER,
            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
        })
        nameFapZone:setPosition(heroWidth/2+px, 85)
        nameFapZone:setAnchorPoint(0.5, 1)
        nameFapBg:addChild(nameFapZone)

        -- 显示人物头像
        local heroHead = Figure.newHero({
            heroModelID = playerInfo.HeroModelId,
            fashionModelID = playerInfo.FashionModelId,
            IllusionModelId = playerInfo.IllusionModelId,
            position = cc.p(heroWidth/2, 20),
            scale = 0.15
        })
        bgSprite:addChild(heroHead)

        if self.mIsLeader then
            -- 踢人按钮
            local tempBtn = ui.newButton({
                normalImage = "zdfb_19.png",
                clickAction = function()
                    self:requestExitTeam(playerInfo.PlayerId, true)
                end
            })
            tempBtn:setPosition(heroWidth-40, heroHeight-65)
            nameFapBg:addChild(tempBtn, 2)
            -- 会长自己没有踢出按钮
            tempBtn:setVisible(self.mTeamInfo.LeaderId ~= playerInfo.PlayerId)
        end

        -- 准备按钮
        local readyBtn = ui.newButton({
            normalImage = "zdfb_20.png",
            clickAction = function()
                self:requestContinueFight(self.mTeamInfo.NeedBattleCount, self.mIsLeader and 0 or 1)
            end
        })
        readyBtn:setPosition(heroWidth-40, heroHeight-65)
        nameFapBg:addChild(readyBtn)
        -- 会长自己没有准备按钮
        readyBtn:setVisible(self.mTeamInfo.LeaderId ~= playerInfo.PlayerId and playerInfo.PlayerId == self.mPlayerId)

        -- 队伍成员的属性
        layout.Id = playerInfo.PlayerId
        layout.posId = playerInfo.PosId
        layout.sprite = posSprite

        -- 玩家的准备情况(self.readyList是聊天推送过来的和点击准备按钮的时候返回过来的 但是一键匹配的机器人准备状态直接放回到memer里面的)
        local isReady = false
        for i,v in ipairs(self.readyList) do
            if v.PlayerId == playerInfo.PlayerId and v.ReadyStatus == 1 then
                isReady = true
            end
        end
        if playerInfo.ReadyStatus and playerInfo.ReadyStatus == 1 then
            isReady = true
        end
        if isReady then
            -- 添加准备好标志
            local readySprite = ui.newSprite("zdfb_16.png")
            readySprite:setAnchorPoint(cc.p(0.5, 0.5))
            readySprite:setPosition(heroWidth/2, heroHeight/2-20)
            readySprite:setRotation(30)
            nameFapBg:addChild(readySprite, 2)
            readySprite:setVisible(playerInfo.PlayerId ~= self.mTeamInfo.LeaderId)
            readyBtn:setVisible(false)
        end
    end

    return layout
end

function ExpediTeamLayer:tipLabel()
    -- 提示语
    local tipsLabel = ui.newLabel({
        text = TR("拖动可调整出战顺序"),
        size = 22,
        color = Enums.Color.eNormalWhite,
        outlineColor = Enums.Color.eBlack,
    })
    tipsLabel:setPosition(180, 190)
    self.mParentLayer:addChild(tipsLabel, 1)

    -- 选择私密还是公开
    local checkBox = ui.newCheckbox({
        normalImage = "c_60.png",
        selectImage = "c_61.png",
        text = TR("自动开战"),
        outlineColor = Enums.Color.eBlack,
        callback = function(isSelect)
            self.mAutoWar = isSelect
            if self.mTipSprite then 
                self.mTipSprite:stopAllActions()
                self.mTipSprite:removeFromParent()
                self.mTipSprite = nil
            end   

            if isSelect then   
                self:autoFight()
            end  

            -- 请求服务器 刷新自动开战
            self:refreshAutoFight()   
        end
    })
    checkBox:setAnchorPoint(cc.p(0, 0.5))
    checkBox:setPosition(300, 190)
    checkBox:setCheckState(self.mAutoWar)
    self.mParentLayer:addChild(checkBox)

    -- -- 连战次数
    local figtBg = ui.newSprite("zdfb_15.png")
    figtBg:setPosition(550, 140)
    self.mParentLayer:addChild(figtBg)
    figtBg:setScale(0.85)
    local figtNum = ui.newLabel({
        text = TR("连战:%s次", self.mTeamInfo.NeedBattleCount),
        size = 22,
        color = Enums.Color.eNormalWhite,
        outlineColor = Enums.Color.eBlack,
    })
    figtNum:setPosition(50, 40)
    figtNum:setRotation(-18)
    figtBg:addChild(figtNum)
    self.mFightNum = figtNum

    -- 是否自动挂机
    local guaJiBox = ui.newCheckbox({
        normalImage = "c_60.png",
        selectImage = "c_61.png",
        text = TR("挂机模式"),
        outlineColor = Enums.Color.eBlack,
        callback = function(isGuaJi)
            if not self.mIsPass then
                self.mGuaJiBox:setCheckState(false)
                ui.showFlashView(TR("请先通关该关卡才能挂机"))
                return
            end
            -- 请求服务器 刷新挂机
            self:refreshGuaJi(isGuaJi)   
        end
    })
    guaJiBox:setAnchorPoint(cc.p(0, 0.5))
    guaJiBox:setPosition(450, 190)
    guaJiBox:setCheckState(self.mIsGuaJi)
    self.mParentLayer:addChild(guaJiBox)
    self.mGuaJiBox = guaJiBox
end

-- 创建队伍宣言
function ExpediTeamLayer:createTeamNotice()
    -- 宣言背景
    local bgSprite = ui.newScale9Sprite("xshd_27.png",cc.size(550, 45))
    bgSprite:setPosition(300, 995)
    self.mParentLayer:addChild(bgSprite)
    local tempSize = bgSprite:getContentSize()
    -- 喇叭
    local tempSprite = ui.newSprite("zdfb_14.png")
    tempSprite:setPosition(30, tempSize.height / 2)
    bgSprite:addChild(tempSprite)
    -- 编辑按钮
    local tempBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("修 改"),
        clickAction = function()
            self:editNotice()
        end
    })
    tempBtn:setScale(0.79)
    tempBtn:setAnchorPoint(cc.p(0, 0.5))
    tempBtn:setPosition(tempSize.width - 70, tempSize.height / 2)
    bgSprite:addChild(tempBtn)
    tempBtn:setVisible(self.mIsLeader)
    -- 宣言文本
    local tempLabel = ui.newLabel({
        text = TR("队伍目标: %s，快来加入吧", ExpeditionNodeModel.items[self.mNodeId].name),
        size = 22,
        color = Enums.Color.eNormalWhite,
        outlineColor = Enums.Color.eBlack,
    })
    tempLabel:setAnchorPoint(cc.p(0, 0.5))
    tempLabel:setPosition(60, tempSize.height / 2)
    bgSprite:addChild(tempLabel)
    self.mNoticeLabel = tempLabel
end

-- 编辑队伍宣言
function ExpediTeamLayer:editNotice()
    local function DIYFunction(layerObj, bgSprite, bgSize)
        local editBox = ui.newEditBox({
            image = "c_17.png",
            size  = cc.size(500, 180),
            maxLength = 20,
            multiLines = true,
            fontColor = Enums.Color.eNormalWhite,
            placeHolder = TR("请输入文本"),
            placeColor = Enums.Color.eNormalWhite,
            fontSize = 24,
        })
        editBox:setPlaceholderFontSize(24)
        editBox:setText(self.mNoticeLabel:getString())
        editBox:setAnchorPoint(cc.p(0.5, 1))
        editBox:setPosition(bgSize.width / 2, bgSize.height - 70)
        bgSprite:addChild(editBox)
        layerObj.editBox = editBox
    end
    local btnInfos = {
        {
            normalImage = "c_28.png",
            text = TR("确定"),
            clickAction = function(layerObj, btnObj)
                local text = layerObj.editBox:getText()
                if text == "" then
                    ui.showFlashView(TR("输入内容不能为空"))
                    return
                end

                -- 如果宣言里面有空格 需要用空字符串处理掉
                local textString = string.gsub(text, "\n", "")

                self:requestChangeSlogan(textString)
                LayerManager.removeLayer(layerObj)
            end
        },
        {
            normalImage = "c_28.png",
            text = TR("取消"),
        }
    }
    MsgBoxLayer.addDIYLayer({
        title = TR("编辑宣言"),
        btnInfos = btnInfos,
        closeBtnInfo = {},
        notNeedBlack = true,
        DIYUiCallback = DIYFunction,
    })
end

-- 刷新队伍宣言
function ExpediTeamLayer:refreshTeamNotice(text)
    if not text then
        text = ""
    end

    local labelStr
    if string.utf8len(text) > 20 then
        labelStr = string.utf8sub(text, 1, 20)
    else
        labelStr = text
    end
    self.mNoticeLabel:setString(labelStr)
end

--辅助函数（查看有几人）
function ExpediTeamLayer:getPersonNum()
    if next(self.mMemberList) == nil then 
        return 0
    end 
    -- dump(self.mMemberList,"self.mMemberList")    
    local num = 0
    for i,v in pairs(self.mMemberList) do
        if v.PlayerId ~= EMPTY_ENTITY_ID then
            num = num + 1
        end
    end

    return num
end

function ExpediTeamLayer:autoFight()
    if next(self.mMemberList) == nil then 
        return
    end 

    if self.mTipSprite then
        return
    end 
        
    -- dump(self.mMemberList,"self.mMemberList")    
    local num = 0
    for i,v in pairs(self.mMemberList) do
        if  v.PlayerId ~= PlayerAttrObj:getPlayerAttrByName("PlayerId") and  v.ReadyStatus and v.ReadyStatus == 1 then
            num = num + 1
        end
    end

    if num == 2 then --需要开始自动战斗
        -- 如果挂机就不调用战斗
        if self.mIsGuaJi then 
            self:startGuaJi()
        else 
            self:requestContinueFight(self.mTeamInfo.NeedBattleCount, 0, self.mStarBtn)    
        end 
    end     
end

--刷新奖励加成
function ExpediTeamLayer:refreshReward()
    if next(self.mMemberList) == nil then 
        return
    end 
    -- dump(self.mMemberList,"self.mMemberList")    
    local num = 0
    local isHighNPC = false 
    local highFap = 0
    for k,v in pairs(ExpeditionPlayerPreviewRelation.items) do
        if v.nodeModelID == self.mNodeId then 
            highFap = v.FAP
        end     
    end
    for i,v in pairs(self.mMemberList) do
        if v.RelationAdd and v.PlayerId ~= PlayerAttrObj:getPlayerAttrByName("PlayerId") then
            num = num + v.RelationAdd
        end

        if v.FAP == highFap then -- 战力一模一样 表示是助阵豪侠
            isHighNPC = true
        end    
    end
    self.rewardAddLabel:setString(string.format("+%s%%", num))  

    if self.mHighNPCBtn then -- 豪侠邀请按钮
        self.mHighNPCBtn:setEnabled( not isHighNPC and not (self:getPersonNum() == 3))
    end  

    -- 队长创建的显示次数Label
    if self.mFightNum then
        -- dump(self.mTeamInfo.NeedBattleCount,"NeedBattleCount") 
        self.mFightNum:setString(TR("连战:%s次", self.mTeamInfo.NeedBattleCount))   
    end  
    -- 非队长创建的显示次数Label
    if self.mFightNum1 then 
        -- dump(self.mTeamInfo.NeedBattleCount,"NeedBattleCount") 
        self.mFightNum1:setString(TR("连战:%s次", self.mTeamInfo.NeedBattleCount))
    end        
end

-- 修改次数
function ExpediTeamLayer:changFightCount()
    local currSelCount = self.mTeamInfo.NeedBattleCount
    local battleList = {}
    local cellBtnList = {}
    for _, item in pairs(ExpeditionNodeModel.items) do
        table.insert(battleList, {
            Id = item.ID,
            name = item.name,
        })
    end
    table.sort(battleList, function(item1, item2)
        return item1.Id < item2.Id
    end)

    -- 由于可能纯在弹窗上加弹窗 这里直接先自己创建弹窗背景
    local bgSize = cc.size(542, 420)
    local bgSprite = ui.newScale9Sprite("c_30.png", bgSize)
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)
    ui.registerSwallowTouch({node = bgSprite})
    local mTitleNode = ui.newLabel({
        text = TR("挑战次数"),
        size = Enums.Fontsize.eTitleDefault,
        color = cc.c3b(0xff, 0xee, 0xd0),
        outlineColor = cc.c3b(0x3a, 0x24, 0x18),
    })
    mTitleNode:setAnchorPoint(cc.p(0.5, 0.5))
    mTitleNode:setPosition(cc.p(bgSize.width / 2, bgSize.height - 36))
    bgSprite:addChild(mTitleNode)
    -- 返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(bgSize.width - 38, bgSize.height - 35),
        clickAction = function()
            bgSprite:removeFromParent()
        end
    })
    bgSprite:addChild(closeBtn)

    -- 背景
    local viewSize = cc.size(480, 320)
    local tempSprite = ui.newScale9Sprite("c_17.png", viewSize)
    tempSprite:setAnchorPoint(cc.p(0.5, 1))
    tempSprite:setPosition(bgSize.width / 2, bgSize.height - 70)
    bgSprite:addChild(tempSprite)

    local size = tempSprite:getContentSize()
    local cellSize = cc.size(480, 50)
    local item = {}
    for index, v in pairs(battleList) do
        if v.Id == self.mNodeId then 
            item = v
            break
        end 
    end         
    -- 子项背景
    local cellBtn = ui.newButton({
        normalImage = "zdfb_12.png",
        lightedImage = "zdfb_12.png",
        disabledImage = "gd_10.png",
        size = cc.size(cellSize.width - 40, cellSize.height),
        position = cc.p(cellSize.width / 2, viewSize.height - 50),
        clickAction = function()
        end
    })
    tempSprite:addChild(cellBtn)
    cellBtn:setBright(false)

    -- 在按钮上加字
    local btnLabel = ui.newLabel({
        text = item.name,
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 24,
    })
    btnLabel:setPosition(cellBtn:getContentSize().width/2, cellSize.height / 2)
    cellBtn:addChild(btnLabel)

    -- 选择挑战次数
    local tipLabel = ui.newLabel({
        text = TR("请选择挑战次数"),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 24,
    })
    tipLabel:setAnchorPoint(0, 0.5)
    tipLabel:setPosition(50, 230)
    bgSprite:addChild(tipLabel)

    -- 消耗体力的显示
    local colorStr = "#FF4A46"
    if currSelCount*self.mUseVitNum <= PlayerAttrObj:getPlayerAttr(ResourcetypeSub.eVIT) then 
        colorStr = "#249029"
    end     
    local cusVitLabel = ui.newLabel({
        text = TR("消耗体力:%s%s#46220d/%s", colorStr, currSelCount*self.mUseVitNum, PlayerAttrObj:getPlayerAttr(ResourcetypeSub.eVIT)),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 24,
    })
    cusVitLabel:setAnchorPoint(0, 0.5)
    cusVitLabel:setPosition(250, 230)
    bgSprite:addChild(cusVitLabel)

    -- 数量选择控件
    local tempView = require("common.SelectCountView"):create({
        currSelCount = currSelCount,
        maxCount = currSelCount,   --次数只能降不能加
        viewSize = cc.size(500, 80),
        changeCallback = function(count)
            currSelCount = count
            local colorStr = "#FF4A46"
            if currSelCount*self.mUseVitNum <= PlayerAttrObj:getPlayerAttr(ResourcetypeSub.eVIT) then 
                colorStr = "#249029"
            end 
            cusVitLabel:setString(TR("消耗体力:%s%s#46220d/%s", colorStr, currSelCount*self.mUseVitNum, PlayerAttrObj:getPlayerAttr(ResourcetypeSub.eVIT)))
        end
    })
    tempView:setPosition(bgSize.width / 2, 170)
    bgSprite:addChild(tempView)
    tempView.mSelCountLabel:setColor(cc.c3b(0x46, 0x22, 0x0d))

        -- 确定按钮
    local toBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("确 定"),
        position = cc.p(bgSize.width/2, 95),
        clickAction = function()
            -- 确定时先判断体力是否足够
            local vitNum = currSelCount*self.mUseVitNum
            if  vitNum > PlayerAttrObj:getPlayerAttr(ResourcetypeSub.eVIT) then 
                MsgBoxLayer.addGetStaOrVitHintLayer(ResourcetypeSub.eVIT, vitNum, function(layerObj, btnObj)
                    local colorStr = "#FF4A46"
                    if currSelCount*self.mUseVitNum <= PlayerAttrObj:getPlayerAttr(ResourcetypeSub.eVIT) then 
                        colorStr = "#249029"
                    end 
                    cusVitLabel:setString(TR("消耗体力:%s%s#46220d/%s", colorStr, currSelCount*self.mUseVitNum, PlayerAttrObj:getPlayerAttr(ResourcetypeSub.eVIT)))
                    LayerManager.removeLayer(layerObj) 
                end)
                return
            end  

            -- 调用修改次数接口
            self:requestChangeFightNum(currSelCount)

            --关闭当前弹窗
            bgSprite:removeFromParent()
        end
    })
    bgSprite:addChild(toBtn)
end

--=======================触摸事件相关==============================
--[[
    描述: 注册触摸拖动事件
    params:
        node:注册事件的节点
        parent:该节点的父节点
--]]
function ExpediTeamLayer:registerDragTouch(node, parent)
    node:setTouchEnabled(true)
    local posOffset = {}

    node:addTouchEventListener(function(sender, eventType)
        local index = node.teamIndex

        if eventType == ccui.TouchEventType.moved then
            --正在拖动
            local touchPos = sender:getTouchMovePosition()
            touchPos = parent:convertToNodeSpace(touchPos)
            node:setPosition(touchPos.x - posOffset.x, touchPos.y - posOffset.y)
        elseif eventType == ccui.TouchEventType.began then
            -- 开始拖动
            local touchPos = sender:getTouchBeganPosition()
            touchPos = parent:convertToNodeSpace(touchPos)
            posOffset.x = touchPos.x - self.mMemberPos[index].x
            posOffset.y = touchPos.y - self.mMemberPos[index].y

            node:setLocalZOrder(rowCount + 1)
        else
            -- 拖动结束
            local touchPos = sender:getTouchEndPosition()
            touchPos = parent:convertToNodeSpace(touchPos)
            -- 生成英雄中心点
            local heroCenterPos = {
                x = touchPos.x - posOffset.x,
                y = touchPos.y - posOffset.y,
            }
            -- 判断当前阵型中的位置
            for i, config in ipairs(self.mMemberPos) do
                local boundingBox = self.mMemberLayout[i]:getBoundingBox()
                if cc.rectContainsPoint(boundingBox, heroCenterPos) then
                    -- 进行交换
                    if self:exchangeFormation(index, i) then
                        return
                    else
                        break
                    end
                end
            end
            self:moveTo(node, self.mMemberPos[index].x, self.mMemberPos[index].y)
            node:setLocalZOrder(rowCount)
        end
    end)
end

-- 位置交换
--[[
    描述：位置交换
    params
        index1:交换位置的第一个英雄的下标
        index2:交换位置的第二个英雄的下标
--]]
function ExpediTeamLayer:exchangeFormation(index1, index2)
    if index1 == index2 then return false end

    local node1 = self.mHeroNodes[index1]
    local node2 = self.mHeroNodes[index2]
    local nodePosId1 = node1.posId
    local nodePosId2 = node2.posId

    -- 请求交换位置
    self:requestChangeFightOrder(node1.Id, node2.posId)

    -- 当可以进行交换时
    if node1 then
        self:moveTo(node1,self.mMemberPos[index2].x, self.mMemberPos[index2].y)
        node1:setLocalZOrder(rowCount)
        node1.teamIndex = index2
        node1.posId = nodePosId2
    end
    if node2 then
        self:moveTo(node2, self.mMemberPos[index1].x, self.mMemberPos[index1].y)
        node2:setLocalZOrder(rowCount)
        node2.teamIndex = index1
        node2.posId = nodePosId1
    end

    self.mHeroNodes[index2] = node1
    self.mHeroNodes[index1] = node2

    return true
end

-- 移动动画
function ExpediTeamLayer:moveTo(node, x, y)
    local moveAction = cc.MoveTo:create(0.2, cc.p(x, y))
    node:runAction(cc.EaseBackOut:create(moveAction))
end

----------------------------------------
--解散队伍
--[[
-- 参数：
    playerId: 玩家Id
    isExit: 是否是踢人出队伍
]]
function ExpediTeamLayer:requestExitTeam(playerId, isExit)
    HttpClient:request({
        moduleName = "ExpeditionNode",
        methodName = "ExitTeam",
        svrMethodData = {playerId},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            if not isExit then
                ui.showFlashView(TR("退出队伍"))
                LayerManager.removeLayer(self)
                PlayerAttrObj:changeAttr({
                    isExpedTeam = false
                })
                -- PlayerAttrObj:changeAttr({
                --     isUseDouble = false
                -- })
                return
            end
            -- dump(response.Value.TeamInfo,"response.Value.TeamInfo")
            self.mTeamInfo = response.Value.TeamInfo
            self.mMemberList = self.mTeamInfo and self.mTeamInfo.Member or {}

            -- 踢人后需要将玩家的准备信息列表置空
            self.readyList = {}

            -- 刷新队伍信息
            self:createPartner()
        end
    })
end

-- 调整队伍的成员位置
--[[
-- 参数：
    playerId: 人物Id
    posId: 位置Id
]]
function ExpediTeamLayer:requestChangeFightOrder(playerId, posId)
    HttpClient:request({
        moduleName = "ExpeditionNode",
        methodName = "ChangeFightOrder",
        svrMethodData = {playerId, posId},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            -- 队伍数据
            self.mTeamInfo = response.Value.TeamInfo
            self.mMemberList = self.mTeamInfo and self.mTeamInfo.Member or {}
        end
    })
end

-- 一键匹配
function ExpediTeamLayer:requestAutoMatch(figtNum)
    if not figtNum or figtNum == 0 then 
        local totalNum = self:getPersonNum()
        if totalNum < 2 then 
            ui.showFlashView(TR("至少需要两人在队伍中才能一键匹配"))
            return
        end 
    end       
      
    HttpClient:request({
        moduleName = "ExpeditionNode",
        methodName = "AutoMatch",
        svrMethodData = {self.mTeamInfo.TeamId, self.mNodeId, figtNum or 0},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            -- dump(response,"response")
            self.mTeamInfo = response.Value.TeamInfo
            self.mMemberList = self.mTeamInfo and self.mTeamInfo.Member or {}

            -- 刷新队伍
            self:createPartner()
        end
    })
end

-- 全服邀请
function ExpediTeamLayer:requestInviteAllServerPlayer()
    HttpClient:request({
        moduleName = "ExpeditionNode",
        methodName = "InviteAllServerPlayer",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            -- 修改全服邀请冷却时间
            self.mCDTime = 15

            Utility.schedule(self, function()
                if self.mCDTime > 0 then
                    self.mCDTime = self.mCDTime - 1
                    self.mTimeLabel:setVisible(true)
                    self.mInvitationBtn:setEnabled(false)
                    self.mTimeLabel:setString(TR("%s秒", self.mCDTime))
                end
                if self.mCDTime <= 0 then
                    self:stopAllActions()
                    self.mCDTime = 0
                    self.mTimeLabel:setVisible(false)
                    self.mInvitationBtn:setEnabled(true)
                end
            end, 1)

            ui.showFlashView(TR("已发送组队邀请！"))
        end
    })
end

-- 修改宣言
function ExpediTeamLayer:requestChangeSlogan(text)
    HttpClient:request({
        moduleName = "ExpeditionNode",
        methodName = "ChangeSlogan",
        svrMethodData = {text},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            self.mTeamInfo = response.Value.TeamInfo
            -- 刷新宣言
            self:refreshTeamNotice(text)
        end
    })
end

--获取当前节点副本队伍信息
    --isFlash:是否是聊天推送过来提示人物的信息变化的
function ExpediTeamLayer:requestGetTeamInfo(isFlash)
    HttpClient:request({
        moduleName = "ExpeditionNode",
        methodName = "GetExpeditionTeamInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            -- 判断返回数据
            if not response or response.Status ~= 0 then
                return
            end

            self.readyList = {}
            -- 更上次比较人数的变化情况（response.Value.TeamInfo存在就表示不是解散队伍）
            if response.Value.TeamInfo and isFlash and #self.mMemberList < #response.Value.TeamInfo.Member then
                MqAudio.playEffect("duiyou_join.mp3")
                ui.showFlashView(TR("有新成员加入"))
            elseif response.Value.TeamInfo and isFlash and #self.mMemberList > #response.Value.TeamInfo.Member then
                -- 有成员退出
                if not self.mTipSprite then -- 如果有倒计时 有队员退出就不显示飘窗
                    ui.showFlashView(TR("有队友退出队伍"))
                end     
            end
            -- 队伍数据
            self.mTeamInfo = response.Value.TeamInfo
            self.mMemberList = self.mTeamInfo and self.mTeamInfo.Member or {}
            -- 是否挂机
            self.mIsGuaJi = self.mTeamInfo and self.mTeamInfo.IsGuaji or false
            if self.mGuaJiBox then 
                self.mGuaJiBox:setCheckState(self.mIsGuaJi)
            end     
            -- 跳转界面
            if not self.mTeamInfo then
                ui.showFlashView(TR("组队已结束"))
                LayerManager.removeLayer(self)
                PlayerAttrObj:changeAttr({
                    isExpedTeam = false
                })
                -- PlayerAttrObj:changeAttr({
                --     isUseDouble = false
                -- })
                return
            end

            -- 刷新队伍信息
            if self.mTipSprite then -- 如果在倒计时就不刷新好友列表
                return
            end     
            self:createPartner()
        end,
    })
end

-- 请求战斗数据
function ExpediTeamLayer:requestGetFightResult(memberList)
    HttpClient:request({
        moduleName = "ExpeditionNode",
        methodName = "GetFightResult",
        svrMethodData = {self.mNodeId, self.mIsUseDouble},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            -- dump(self.mNodeInfo, "ppp")
            -- dump(self.mMemberList, "aaa")
            -- dump(response.Value.MemberInfo,"response")
            local battleCount = nil
            if response.Value.ContinueFightInfo then
                battleCount = response.Value.ContinueFightInfo.BattleCount
            end

            -- 判断是够是主角 如果不是默认12010001
            local MemberInfo = clone(response.Value.MemberInfo)
            for i,v in ipairs(MemberInfo) do
                if v.HeadImageId and HeroModel.items[v.HeadImageId] and HeroModel.items[v.HeadImageId].specialType == Enums.HeroType.eMainHero then 
                    v.HeroModelId = v.HeadImageId
                else 
                    v.HeroModelId = 12010001
                end     
            end

            -- 倒计时5秒进入战场
            local tipImage = {"zdfb_35.png", "zdfb_36.png", "zdfb_37.png", "zdfb_38.png", "zdfb_39.png", 
                "zdfb_40.png", "zdfb_41.png", "zdfb_42.png", "zdfb_43.png", "zdfb_44.png"}

            self.mTipSprite = ui.newSprite(tipImage[5])
            self.mTipSprite:setPosition(320, 628)
            self.mParentLayer:addChild(self.mTipSprite)
            local timeSeconds = 5    
            Utility.schedule(self.mTipSprite, function()
                if timeSeconds > 0 then
                    self.mTipSprite:setTexture(tipImage[timeSeconds])

                    -- 倒计时五秒的时候屏蔽不能点击页面
                    local newlayer = ui.newStdLayer()
                    self.mParentLayer:addChild(newlayer, 101)
                    ui.registerSwallowTouch({node = newlayer})
                else 
                    self.mTipSprite:stopAllActions()
                    self.mTipSprite:removeFromParent()
                    self.mTipSprite = nil

                    LayerManager.addLayer({
                        name = "challenge.ExpediMapLayer",
                        data = {fightInfo = response.Value, memberList = MemberInfo, fightCount = battleCount},
                        cleanUp = true,
                        zOrder = Enums.ZOrderType.eDefault
                    })
                end
                timeSeconds = timeSeconds - 1
            end, 1)    
        end
    })
end

-- 发起连战
--[[
    count:连战次数(战斗的剩余次数)
    fightType:操作类型(0:队长发起连战请求,1:队友接收连战,2:队友拒绝连战,3:继续战斗(不分队长和队员))
    startObj:开始战斗按钮
]]
function ExpediTeamLayer:requestContinueFight(count, fightType, startObj)
    HttpClient:request({
        moduleName = "ExpeditionNode",
        methodName = "ContinueFight",
        svrMethodData = {count, fightType},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                if response.Status == -1119 then
                    -- 加入时先判断体力是否足够
                    local vitNum = count*self.mUseVitNum
                    if  vitNum > PlayerAttrObj:getPlayerAttr(ResourcetypeSub.eVIT) then
                        -- 如果是队长请求连战出现体力不足， 需要显示倒计时30秒体力不足解散队伍的信息
                        if fightType == 0 then 
                            self.mExitTeamLabel = ui.newLabel({
                                text = TR("30秒后体力不足房间会自动解散，请购买体力\n房间解散倒计时:%s秒", 30),
                                size = 22,
                                -- color = cc.c3b(0xff, 0xf3, 0xc9),
                                outlineColor = cc.c3b(0x37, 0x30, 0x2c),
                                outlineSize = 2,
                                align = cc.TEXT_ALIGNMENT_CENTER,
                            })
                            self.mExitTeamLabel:setPosition(350, 928)
                            self.mParentLayer:addChild(self.mExitTeamLabel)

                            -- 有30秒购买体力的时间
                            local timeSeconds = 30  
                            Utility.schedule(self.mExitTeamLabel, function()
                                if timeSeconds > 0 then
                                    self.mExitTeamLabel:setString(TR("30秒后体力不足房间会自动解散，请购买体力\n房间解散倒计时:%s秒", timeSeconds))
                                else 
                                    self.mExitTeamLabel:stopAllActions()
                                    -- 解散队伍
                                    self:requestExitTeam(PlayerAttrObj:getPlayerAttrByName("PlayerId"))
                                end
                                timeSeconds = timeSeconds - 1
                            end, 1)

                            -- 弹出体力不足的时候需要回调函数
                            MsgBoxLayer.addGetStaOrVitHintLayer(ResourcetypeSub.eVIT, vitNum, function(layerObj, btnObj)
                                -- 关闭体力充值页面之后，判断体力是否足够 如果足够了 需要开始战斗
                                local vitNum = count*self.mUseVitNum
                                if  vitNum <= PlayerAttrObj:getPlayerAttr(ResourcetypeSub.eVIT) then
                                    self.mExitTeamLabel:stopAllActions()
                                    self:requestContinueFight(self.mTeamInfo.NeedBattleCount, 0, self.mStarBtn)
                                end     
                                LayerManager.removeLayer(layerObj) 
                            end)
                        else
                            MsgBoxLayer.addGetStaOrVitHintLayer(ResourcetypeSub.eVIT, vitNum)
                        end     
                    end
                end
                return
            end
            -- dump(response, response)
            -- 已就绪的列表
            self.readyList = response.Value.readyInfoDetils

            -- self:createPartner()
            if fightType == 1 then
                self:requestGetTeamInfo()
            end
            if startObj then
                startObj:setEnabled(false)
            end

            -- 如果是队长成功发起开战 此时不能点击屏幕
            if fightType == 0 then
                local newlayer = ui.newStdLayer()
                self.mParentLayer:addChild(newlayer, 102)
                ui.registerSwallowTouch({node = newlayer})
            end     
        end
    })
end

-- 刷新自动开战
function ExpediTeamLayer:refreshAutoFight()
    HttpClient:request({
        moduleName = "ExpeditionNode",
        methodName = "ChangeIfAutoReady",
        svrMethodData = {self.mAutoWar},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
        end
    })
end

-- 通知服务端是否使用了双倍令
function ExpediTeamLayer:requestIsUseDouble()
    HttpClient:request({
        moduleName = "ExpeditionNode",
        methodName = "ChangeUseDouble",
        svrMethodData = {self.mIsUseDouble},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
        end
    })
end

-- 刷新是否挂机
function ExpediTeamLayer:refreshGuaJi(isGuaJi)
    HttpClient:request({
        moduleName = "ExpeditionNode",
        methodName = "ChangeGuajiStatus",
        svrMethodData = {isGuaJi},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                if self.mGuaJiBox then 
                    self.mGuaJiBox:setCheckState(not isGuaJi)
                    self.mIsGuaJi = not isGuaJi
                end
                return
            end

            if self.mGuaJiBox then 
                self.mGuaJiBox:setCheckState(isGuaJi)
                self.mIsGuaJi = isGuaJi
            end
        end
    })
end

-- 队长通知开始挂机
function ExpediTeamLayer:startGuaJi()
    HttpClient:request({
        moduleName = "ExpeditionNode",
        methodName = "StartGuaji",
        svrMethodData = {self.mNodeId},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
        end
    })
end

-- 挂机后获取挂机相关信息
function ExpediTeamLayer:getGuaJiInfo()
    HttpClient:request({
        moduleName = "ExpeditionNode",
        methodName = "Guaji",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            -- 此时队伍已经不存在
            PlayerAttrObj:changeAttr({
                isExpedTeam = false
            })
            -- 下次进来不能使用双倍令
            -- PlayerAttrObj:changeAttr({
            --     isUseDouble = false
            -- })
            -- 回到挑战打开光明顶模块
            LayerManager.addLayer({
                name = "challenge.ChallengeLayer",
                data = {autoOpenModule = ModuleSub.eExpedition}
            })
        end
    })
end

-- 修改次数
function ExpediTeamLayer:requestChangeFightNum(currSelCount)
    HttpClient:request({
        moduleName = "ExpeditionNode",
        methodName = "ChangeNeedBattleCount",
        svrMethodData = {currSelCount},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            -- 队伍数据
            self.mTeamInfo = response.Value.TeamInfo
            self.mMemberList = self.mTeamInfo and self.mTeamInfo.Member or {}

            -- 刷新队伍信息
            self:createPartner()
        end
    })
end

-- 请求服务器，获取所有已开启的福利多多活动的信息
function ExpediTeamLayer:requestGetTimedActivityInfo()
    HttpClient:request({
        moduleName = "TimedInfo",
        methodName = "GetTimedActivityInfo",
        callbackNode = self,
        callback = function (data)
            -- dump(data, "requestGetTimedActivityInfo")
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            for i,v in ipairs( data.Value.TimedActivityList) do
                if v.ActivityEnumId == TimedActivity.eSalesRebornCoin then -- 有真气翻倍活动
                    self.mIsSalesActivity = true
                    self.mIsUseDouble = false
                    self:setIsUseDouble(self.mIsUseDouble)
                    break
                end
            end
        end
    })
end

return ExpediTeamLayer

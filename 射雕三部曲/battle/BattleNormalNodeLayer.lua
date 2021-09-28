--[[
    文件名: BattleNormalNodeLayer.lua
    描述: 普通副本节点页面
    创建人: heguanghui
    创建时间: 2017.04.20
--]]

local BattleNormalNodeLayer = class("BattleNormalNodeLayer", function(params)
    return display.newLayer()
end)

--[[
-- 参数 params 中的各个字段为
    {
        chapterId:  需要进入章节的章节模型Id
        nodeId:     要跳转的节点.有该参数时直接弹出出战窗
    }
]]
function BattleNormalNodeLayer:ctor(params)
    params = params or {}
    -- 需要进入章节的章节模型Id
    self.mChapterId = params.chapterId or nil
    self.mNodeId = params.nodeId or nil

    -- 战役信息
    self.mBattleInfo = {}
    -- 章节列表数据
    self.mChapterList = {}
    -- 章节Id列表
    self.mChapterIdList = {}
    -- 所有章节的节点模型Id列表
    self.mAllNodeIdList = {}
    -- 章节Id列表的显示大小
    self.mChapterViewSize = cc.size(620, 120)
    -- 章节Id列表每个cell的大小
    self.mChapterViewCellSize = cc.size(self.mChapterViewSize.width / 4, self.mChapterViewSize.height)

    -- 该页面操作按钮列表
    self.mOptBtnList = {}

    -- 节点场景列表的Parent
    self.mNodeParent = ui.newStdLayer()
    self:addChild(self.mNodeParent)

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 结点人物列表
    self.nodeHeroList = {}
    -- 初始化页面控件
    self:initUI()

    -- 最底部导航按钮页面(因为底部导航按钮应该显示在最上面，所以需要最后 addChild)
    self.mCommonLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = false,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eDiamond, ResourcetypeSub.eGold},
        currentLayerType = Enums.MainNav.eBattle,
    })
    self:addChild(self.mCommonLayer)

    -- 关闭按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mCloseBtn:setPosition(Enums.StardardRootPos.eCloseBtn)
    self.mParentLayer:addChild(self.mCloseBtn)

    -- 刷新任务提示
    local function refreshRoadFunc()
        if (self.roadOfHeroSprite ~= nil) then
            self.roadOfHeroSprite:removeFromParent()
            self.roadOfHeroSprite = nil
        end

        -- 读取大侠之路的数据
        local currId, currState, _ = RoadOfHeroObj:getCurrTask()
        local taskConfig = MaintaskNodeRelation.items[currId]
        if (taskConfig == nil) or (taskConfig.maintaskID ~= 1) or (currState ~= 1) then
            return
        end

        -- 添加任务提示
        for _,v in pairs(self.mAllNodeInfoList or {}) do
            if (v.nodeModel.ID == taskConfig.condition) then
                self.roadOfHeroSprite = ui.createFloatSprite("dxzl_02.png", cc.p(v.heroPos.x, v.heroPos.y + 200))
                self.worldView:addChild(self.roadOfHeroSprite, 101)
                break
            end
        end
    end
    refreshRoadFunc()
    Notification:registerAutoObserver(self.mCloseBtn, refreshRoadFunc, {EventsName.eRoadOfHeroStateChanged})
end

-- 获取恢复数据
function BattleNormalNodeLayer:getRestoreData()
    local retData = {
        chapterId = self.mChapterId
    }

    return retData
end

-- 初始化页面控件
function BattleNormalNodeLayer:initUI()
    -- 获取章节列表数据
    BattleObj:getAllChapterInfo(function(chapterList)  -- 获取
        -- 获取战役信息
        self.mBattleInfo = BattleObj:getBattleInfo() or {}
        -- 如果没有传入章Id，默认为开启的最大章节
        local curMaxCId = self.mBattleInfo.MaxChapterId or 11
        if not self.mChapterId then
            self.mChapterId = curMaxCId
        end
        if self.mNodeId then
            Utility.performWithDelay(self, function()
                LayerManager.addLayer({
                    name = "battle.NormalNodePopLayer",
                    cleanUp = false,
                    data = {
                        chapterModelId = self.mChapterId,
                        nodeModelId = self.mNodeId,
                        fightCallback = function(chapterModelId, nodeModelId, starLv)
                            AutoFightObj:setAutoFight(false)
                            BattleObj:requestFightInfo(chapterModelId, nodeModelId, starLv)
                        end,
                    }
                })
            end, 0.01)
        end

        if self.mChapterId == curMaxCId then
            -- 如果是当前战斗章节，默认为开启的最大节点
            if not self.mNodeId then
                self.mNodeId = self.mBattleInfo.MaxNodeId or 1111
            end
        else
            -- 如果是曾经打过的章节，默认为当前章节的最大节点
            if not self.mNodeId then
                local nodeList = BattleObj:getAllNodeIdList()
                local maxNodeId = 1111
                for k,v in pairs(nodeList[self.mChapterId]) do
                    if v > maxNodeId then
                        maxNodeId = v
                    end
                end
                self.mNodeId = maxNodeId
            end
        end
        -- 创建滑动地图和结点数据
        local baseChapterInfo = self:createScrollBgAndData()
        -- 创建节点场景列表
        self.mAllNodeInfoList = {}
        for i,v in ipairs(self.mAllNodeIdList) do
            self:createOneNode(i, v)
        end

        local chapterInfo = chapterList[self.mChapterId]
        -- 添加标题的显示
        local tempNode = ui.createSpriteAndLabel({
            imgName = "c_25.png",
            scale9Size = cc.size(300, 54),
            labelStr = TR("第%d章  %s", self.mChapterId - 10, baseChapterInfo.name),
            fontColor = Enums.Color.eNormalWhite,
            fontSize = 25,
            outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
            outlineSize = 2,
        })
        tempNode:setPosition(320, 1042)
        self.mNodeParent:addChild(tempNode)

        -- 创建页面跳转操作按钮
        self:createOptBtn()
        -- 创建星级宝箱
        self:createStarBox(chapterInfo, baseChapterInfo)

        -- self:createRoadBox(self.worldView, self.mChapterId)
        -- 刷新宝箱状态
        self:refreshStarBox()

        -- Utility.performWithDelay(self, function()
        --     -- 自动设置当前节点位置
        --     local nodeCount = table.nums(BattleObj:getAllNodeIdList()[self.mChapterId])
        --     local curIndex = MqMath.modEx(self.mNodeId, nodeCount) / nodeCount
        --     local maxOffset = (-self.maxWorldHeight + 1136)
        --     self.worldView:setInnerContainerPosition(cc.p(0, 0))
        -- end, 0)
        
        -- 执行新手引导
        self:executeGuide()
    end)
end

-- 创建收缩展开部分按钮
function BattleNormalNodeLayer:createOptBtn()
    -- 添加旋转背景
    self.rotateBgSprite = ui.newSprite("fb_19.png")
    self.rotateBgSprite:setAnchorPoint(cc.p(0.5, 1.0))
    self.rotateBgSprite:setPosition(62, 1088)
    self.rotateBgSprite:setVisible(false)
    self.mNodeParent:addChild(self.rotateBgSprite)
    -- 添加功能按钮
    local btnInfos = {
        -- 挂机
        {normalImage = "tb_115.png", moduleId = ModuleSub.eBattleAutomatic,
        clickAction = function ()
            if not ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eBattleAutomatic, true) then
                return
            end
            LayerManager.addLayer({
                name = "battle.AutoFightLayer",
                cleanUp = false,
            })
        end},
         -- 阵容
        {normalImage = "tb_148.png", 
        clickAction = function ()
            LayerManager.addLayer({name = "team.TeamLayer",})
        end},
        -- 拼酒
        {normalImage = "tb_45.png", moduleId = ModuleSub.ePracticeLightenStar,
        clickAction = function ()
            if not ModuleInfoObj:moduleIsOpen(ModuleSub.ePracticeLightenStar, true) then
                return
            end
            LayerManager.addLayer({name ="practice.LightenStarLayer",})
        end},
        -- 闯荡江湖
        {normalImage = "tb_149.png", moduleId = ModuleSub.eQuickExp,
        clickAction = function ()
            if not ModuleInfoObj:moduleIsOpen(ModuleSub.eQuickExp, true) then
                return
            end
            LayerManager.addLayer({name = "quickExp.QuickExpLayer",})
        end},

    }
    -- 添加旋转
    local rotateBtn
    rotateBtn = ui.newButton({normalImage = "fb_21.png",
        position = cc.p(62, 1038),
        clickAction = function ()
            local bgVisibed = self.rotateBgSprite:isVisible()
            if bgVisibed then
                local actList = {
                    cc.ScaleTo:create(0.25, 0.2),
                    cc.Hide:create(),
                }
                self.rotateBgSprite:runAction(cc.Sequence:create(actList))
                -- 按钮设置为+号
                rotateBtn:loadTextureNormal("fb_21.png")
            else
                self.rotateBgSprite:setScale(0.2)
                local actList = {
                    cc.Show:create(),
                    cc.ScaleTo:create(0.25, 1.0),
                }
                self.rotateBgSprite:runAction(cc.Sequence:create(actList))
                -- 按钮设置为x号
                rotateBtn:loadTextureNormal("fb_22.png")
            end
        end}
    )
    self.mNodeParent:addChild(rotateBtn)
    -- 默认为打开样式
    rotateBtn.mClickAction()
    -- 加号添加小红点
    local function dealRedDotVisible(redDotSprite)
        local redDotData = RedDotInfoObj:isValid(Enums.ClientRedDot.eBattleNormalMore)
        redDotSprite:setVisible(redDotData)
    end
    -- 小红点处理
    ui.createAutoBubble({refreshFunc = dealRedDotVisible, eventName = RedDotInfoObj:getEvents(Enums.ClientRedDot.eBattleNormalMore), parent = rotateBtn})

    -- 添加功能按钮
    for i, btnInfo in ipairs(btnInfos) do
        -- 没有模块Id 或 该模块已开启
        if not btnInfo.moduleId or ModuleInfoObj:moduleIsOpenInServer(btnInfo.moduleId) then
            local tempBtn = ui.newButton(btnInfo)
            tempBtn:setPosition(52, 415 - 90 * i)
            self.rotateBgSprite:addChild(tempBtn)
            if btnInfo.moduleId then
                self.mOptBtnList[btnInfo.moduleId] = tempBtn
            end
            -- 小红点逻辑
            if btnInfo.moduleId then
                local function dealRedDotVisible(redDotSprite)
                    local redDotData = RedDotInfoObj:isValid(btnInfo.moduleId)
                    redDotSprite:setVisible(redDotData)
                end
                -- 小红点处理
                ui.createAutoBubble({refreshFunc = dealRedDotVisible, eventName = RedDotInfoObj:getEvents(btnInfo.moduleId), parent = tempBtn})
            end

            -- 挂机按钮加特效
            if btnInfo.moduleId and btnInfo.moduleId == ModuleSub.eBattleAutomatic then
                ui.newEffect({
                    parent = tempBtn,
                    effectName = "effect_ui_guajitubiao",
                    position = cc.p(tempBtn:getContentSize().width / 2, tempBtn:getContentSize().height / 2),
                    loop = true,
                    endRelease = true
                })
            end
        end
    end
end

-- 创建滑动背景和数据
function BattleNormalNodeLayer:createScrollBgAndData()
    local baseChapterInfo = BattleChapterModel.items[self.mChapterId]
    -- 整理节点模型Id
    for i=11,20 do
        local itemData = BattleNodeModel.items[self.mChapterId * 100 +i]
        if itemData then
            table.insert(self.mAllNodeIdList, itemData)
        else
            break
        end
    end
    
    -- 创建可拖动背景
    local worldView = ccui.ScrollView:create()
    worldView:setContentSize(cc.size(640, 1136))
    worldView:setPosition(cc.p(0,0))
    worldView:setDirection(ccui.ScrollViewDir.vertical)
    worldView:setBounceEnabled(false)
    self.worldView = worldView
    self.mNodeParent:addChild(worldView)

    -- 读取最低点的Y坐标，计算和地图高度的偏移
    local minPosY = 2840
    for i,v in ipairs(self.mAllNodeIdList) do
        local tmpPosY = 2840 - Utility.analysisPoints(v.points).y
        if (minPosY > tmpPosY) then
            minPosY = tmpPosY
        end
    end
    self.mOffsetWithMinPosY = minPosY - 200
    -- 添加背景图片
    local modelBgImage = baseChapterInfo.bgPic
    local modelImageList = string.split(modelBgImage, ",")
    local startBgY = -minPosY + 200
    for i,v in ipairs(modelImageList) do
        local bgSprite = ui.newSprite(v .. ".jpg")
        bgSprite:setAnchorPoint(cc.p(0, 0))
        bgSprite:setPosition(cc.p(0, startBgY))
        worldView:addChild(bgSprite)
        startBgY = startBgY + bgSprite:getContentSize().height
    end

    

    self.offsetPosX = 75 -- 节点相对美术坐标的偏移
    self.maxWorldHeight = 2840 - minPosY + 200-- 最大地图高度 （330偏移量为调整效果所加）
    worldView:setInnerContainerSize(cc.size(640, self.maxWorldHeight))
    self.worldView = worldView
    
    return baseChapterInfo
end

-- 创建一个节点
function BattleNormalNodeLayer:createOneNode(index, nodeModel)
    local function heroClickAction()
        local nodeModelId = nodeModel.ID
        if nodeModelId > self.mBattleInfo.MaxNodeId then -- 不可挑战的节点
            ui.showFlashView(TR("该关卡还未开启"))
            return
        end

        --- 新手引导逻辑
        local guideID, ordinal, eventID = Guide.manager:getGuideInfo()
        if table.indexof(Guide.config.battleEvent, eventID) then
            AutoFightObj:setAutoFight(false)
            local recordInfo = Guide.manager:makeExtentionData(guideID, ordinal + 1)

            BattleObj:requestFightInfo(self.mChapterId, nodeModelId, 1, recordInfo, nil, function(response)
                if not response or response.Status ~= 0 then  -- 请求失败了
                    return
                end
                Guide.manager:removeGuideLayer()
            end)
        else
            LayerManager.addLayer({
                name = "battle.NormalNodePopLayer",
                cleanUp = false,
                data = {
                    chapterModelId = self.mChapterId,
                    nodeModelId = nodeModelId,
                    fightCallback = function(chapterModelId, nodeModelId, starLv)
                        AutoFightObj:setAutoFight(false)
                        BattleObj:requestFightInfo(chapterModelId, nodeModelId, starLv)
                    end,
                }
            })
        end
    end
    -- -- 节点的坐标
    -- local retNodePos = Utility.analysisPoints(nodeModel.points)
    -- -- 创建人物
    -- local heroPos = cc.p(retNodePos.x + self.offsetPosX, (2840-retNodePos.y) - self.mOffsetWithMinPosY)
    -- local  nodeModelId = nodeModel.ID
    -- Figure.newHero({
    --     parent = self.worldView,
    --     heroModelID = tonumber(nodeModel.pic),
    --     position = heroPos,
    --     scale = 0.14,
    --     buttonAction = heroClickAction,
    --     async = function(figureNode)
    --         -- 保存人物按钮，新手引导使用
    --         self.nodeHeroList[nodeModelId] = figureNode

    --         -- 有动画，所以延迟
    --         Utility.performWithDelay(self.mParentLayer, function ()
    --             self:executeGuideAfterHero(nodeModelId)
    --         end, 0.45)
    --     end,
    -- })

    -- -- 创建人物名背景
    -- local nameBgPos = cc.p(heroPos.x - 55, heroPos.y + 150)
    -- local nameBgSprite = ui.newSprite("fb_16.png")
    -- nameBgSprite:setPosition(nameBgPos)
    -- self.worldView:addChild(nameBgSprite, 1)

    -- -- 显示节点编号
    -- local strNodeKey = nodeModel.ID - math.floor(nodeModel.ID/100)*100 - 10
    -- if (strNodeKey == 10) then
    --     strNodeKey = ":"      -- ASCII码表里，'9'的后面是':'，所以这里要替换显示
    -- end
    -- local nodeKeyLabel = ui.newNumberLabel({
    --     text = strNodeKey, 
    --     imgFile = "fb_41.png",
    --     charCount = 10,
    --     startChar = 49,
    -- })
    -- nodeKeyLabel:setPosition(23, 120)
    -- nameBgSprite:addChild(nodeKeyLabel)

    -- -- 显示对应侠客名字
    -- local nameLabel = ui.newLabel({
    --     text = nodeModel.name,
    --     size = 20,
    --     color = cc.c3b(0xFF, 0xF4, 0xE8),
    --     outlineColor = cc.c3b(0x02, 0x02, 0x02),
    --     outlineSize = 2,
    --     dimensions = cc.size(24, 0),
    --     align = cc.TEXT_ALIGNMENT_CENTER,
    --     valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP
    -- })
    -- nameLabel:setAnchorPoint(cc.p(0.5, 1))
    -- nameLabel:setLineSpacing(-5)
    -- nameLabel:setPosition(23, 90)
    -- nameBgSprite:addChild(nameLabel)

    -- -- 显示星级
    -- local nodeInfo = BattleObj:getNodeInfo(self.mChapterId, nodeModel.ID)
    -- local openStar = nodeInfo and nodeInfo.StarCount or 0
    -- local starMax = nodeModel.starCount or 0
    -- for i=1, starMax do
    --     local starSprite = ui.newSprite((openStar < i) and "c_106.png" or "c_105.png")
    --     starSprite:setPosition(cc.p(-15, 120 - i * 40))
    --     nameBgSprite:addChild(starSprite)
    -- end
   
    -- -- 当前战斗的节点
    -- if nodeModel.ID == self.mBattleInfo.MaxNodeId then
    --     -- 交叉刀
    --     ui.newEffect({
    --         parent = self.worldView,
    --         effectName = "effect_ui_jiaochadao",
    --         position = cc.p(nameBgPos.x + 60, nameBgPos.y + 80),
    --         zorder = 100,
    --         loop = true,
    --         scale = 0.75,
    --         endRelease = true,
    --     })
    --     -- 脚底特效
    --     ui.newEffect({
    --         parent = self.worldView,
    --         effectName = "effect_ui_renwuguangquan",
    --         animation = "guangquan",
    --         position = heroPos,
    --         loop = true,
    --         endRelease = true,
    --     })
    --     -- 身上特效
    --     ui.newEffect({
    --         parent = self.worldView,
    --         effectName = "effect_ui_renwuguangquan",
    --         animation = "guangxian",
    --         position = heroPos,
    --         zorder = 100,
    --         loop = true,
    --         endRelease = true,
    --     })

    --     local tempOff = -16
    --     for i = 1, index do
    --         tempOff = tempOff + 4
    --     end
    --     if nodeModel.ID == 1115 then
    --         self.worldView:scrollToPercentVertical(0, 1, true)         
    --     else
    --         self.worldView:scrollToPercentVertical((100 - heroPos.y/self.maxWorldHeight * 100 - tempOff), 1, true)
    --     end
    -- end
    local retNodePos = Utility.analysisPoints(nodeModel.points)
    local heroPos = cc.p(retNodePos.x + self.offsetPosX, (2840-retNodePos.y) - self.mOffsetWithMinPosY)
    self.mAllNodeInfoList[index] = {nodeModel = nodeModel, heroPos = heroPos}

    -- -- 创建节点布局
    self:createNodeLayout(index, nodeModel, heroClickAction)
end

-- 创建节点布局
function BattleNormalNodeLayer:createNodeLayout(index, nodeModel, callback)
    -- 节点的坐标
    local retNodePos = Utility.analysisPoints(nodeModel.points)
    local heroPos = cc.p(retNodePos.x + self.offsetPosX, (2840-retNodePos.y) - self.mOffsetWithMinPosY)
    local posY = heroPos.y

    -- 创建底部圆圈
    local circleSprite = ui.newSprite(nodeModel.fightNumMax <= 10 and "xjd_05.png" or "xjd_04.png")
    circleSprite:setPosition(heroPos)
    self.worldView:addChild(circleSprite)

    -- 精英
    if nodeModel.fightNumMax <= 10 then
        -- 创建任务头像卡牌
        local headCard = CardNode.createCardNode({
                resourceTypeSub = ResourcetypeSub.eHero,
                modelId = tonumber(nodeModel.pic),
                cardShowAttrs = {CardShowAttr.eBorder},
                allowClick = false,
            })
        headCard:setPosition(heroPos.x, heroPos.y+70)
        self.worldView:addChild(headCard)

        -- 创建图片框架
        local headBgBtn = ui.newButton({
            normalImage = nodeModel.fightNumMax <= 5 and "xjd_02.png" or "xjd_01.png",
            clickAction = function ()
                if callback then
                    callback()
                end
            end,
        })
        headBgBtn:setAnchorPoint(cc.p(0.5, 0))
        headBgBtn:setPosition(heroPos)
        self.worldView:addChild(headBgBtn)

        -- 保存人物按钮，新手引导使用
        self.nodeHeroList[nodeModel.ID] = headBgBtn

        posY = posY + headBgBtn:getContentSize().height
    -- 普通
    else
        local changeBtn = ui.newButton({
                normalImage = "xjd_03.png",
                clickAction = function ()
                    if callback then
                        callback()
                    end
                end,
            })
        changeBtn:setAnchorPoint(cc.p(0.5, 0))
        changeBtn:setPosition(heroPos)
        self.worldView:addChild(changeBtn)
        -- 保存人物按钮，新手引导使用
        self.nodeHeroList[nodeModel.ID] = changeBtn

        posY = posY + changeBtn:getContentSize().height
    end

    -- 精英显示名字
    if nodeModel.fightNumMax <= 10 then
        -- 节点名字
        local nameLabel = ui.newLabel({
                text = nodeModel.name,
                color = cc.c3b(0xcc, 0xfe, 0xff),
                outlineColor = cc.c3b(0x0f, 0x6b, 0xa0),
                size = 20,
            })
        nameLabel:setAnchorPoint(cc.p(0.5, 0))
        nameLabel:setPosition(heroPos.x, posY)
        self.worldView:addChild(nameLabel)

        posY = posY + nameLabel:getContentSize().height
    end

    -- 显示星星
    posY = posY + 5
    local nodeInfo = BattleObj:getNodeInfo(self.mChapterId, nodeModel.ID)
    local openStar = nodeInfo and nodeInfo.StarCount or 0
    local starMax = nodeModel.starCount or 0
    local starSize = ui.getImageSize("c_75.png")
    local starBg = ui.newScale9Sprite("c_83.png", cc.size(starMax*starSize.width, starSize.height))
    starBg:setAnchorPoint(cc.p(0.5, 0))
    starBg:setPosition(heroPos.x, posY)
    self.worldView:addChild(starBg)
    for i=1, starMax do
        local starSprite = ui.newSprite((openStar < i) and "c_106.png" or "c_105.png")
        starSprite:setAnchorPoint(cc.p(0, 0))
        starSprite:setPosition(cc.p((i-1)*starSize.width, 0))
        starBg:addChild(starSprite)
    end
    posY = posY + starSize.height

    -- 当前战斗的节点
    if nodeModel.ID == self.mBattleInfo.MaxNodeId then
        -- -- 交叉刀
        -- ui.newEffect({
        --     parent = self.worldView,
        --     effectName = "effect_ui_jiaochadao",
        --     position = cc.p(heroPos.x, posY),
        --     zorder = 100,
        --     loop = true,
        --     scale = 0.75,
        --     endRelease = true,
        -- })

        -- 箭头
        ui.newEffect({
            parent = self.worldView,
            effectName = "effect_ui_xinjiantou",
            position = cc.p(heroPos.x, posY+50),
            zorder = 100,
            loop = true,
            endRelease = true,
        })

        local tempOff = -16
        for i = 1, index do
            tempOff = tempOff + 4
        end
        if nodeModel.ID == 1115 then
            self.worldView:scrollToPercentVertical(0, 1, true)         
        else
            self.worldView:scrollToPercentVertical((100 - heroPos.y/self.maxWorldHeight * 100 - tempOff), 1, true)
        end
    end

    -- 新手引导,有动画，所以延迟
    Utility.performWithDelay(self.mParentLayer, function ()
        self:executeGuideAfterHero(nodeModel.ID)
    end, 0.8)
end

-- 创建当前章节的星级宝箱
function BattleNormalNodeLayer:createStarBox(chapterInfo, baseChapterInfo)
    -- 宝箱的背景
    local boxBgSprite = ui.newSprite("fb_20.png")
    boxBgSprite:setAnchorPoint(cc.p(0, 0))
    self.mNodeParent:addChild(boxBgSprite)

    -- 宝箱进度条
    local boxBar = require("common.ProgressBar"):create({
        bgImage = "fb_17.png",
        barImage = "fb_18.png",
        --contentSize = cc.size(236, 27),
        currValue = chapterInfo.StarCount,
        maxValue = baseChapterInfo.starCount,
    })
    boxBar:setPosition(320, 33)
    boxBgSprite:addChild(boxBar)

    local openStars = {baseChapterInfo.boxANeedStar, baseChapterInfo.boxBNeedStar, baseChapterInfo.boxCNeedStar}
    local boxShowCount = 0
    for i,v in ipairs(openStars) do
        if v > 0 then
            boxShowCount = boxShowCount + 1
        end
    end
    self.barBoxBtns = {}
    self.barBoxEffects = {}
    -- 宝箱特效列表
    local boxEffectList = {
        [1] = "effect_yinbaoxiang",
        [2] = "effect_jingbaoxiang",
        [3] = "effect_jipingbaoxiang"
    }
    for i=1, boxShowCount do
        local xPos = 193 + (i - 1) * 193
        if i == 1 then
            xPos = 571*(baseChapterInfo.boxANeedStar / baseChapterInfo.starCount)
        elseif i == 2 then
            xPos = 571*(baseChapterInfo.boxBNeedStar / baseChapterInfo.starCount)
        else
            xPos = 571*(baseChapterInfo.boxCNeedStar / baseChapterInfo.starCount)
        end
        if baseChapterInfo.boxBNeedStar <= 0 then
            xPos = 571
        elseif baseChapterInfo.boxCNeedStar <=0 then
            xPos = (i==2) and 571 or 378
            xPos = (i==1) and 303 or 571
        end

        -- 创建宝箱可领取特效
        local effectName = boxEffectList[i]
        if i > 3 then effectName = boxEffectList[3] end
        local boxReceiveEffect = ui.newEffect({
                parent = boxBgSprite,
                effectName = boxEffectList[i],
                position = cc.p(xPos, 35),
                scale = 0.2,
                loop = true,
            })
        boxReceiveEffect:setAnimation(0, "kaiqi", true)
        boxReceiveEffect:setVisible(false)

        -- 创建宝箱按钮
        local boxBtn = ui.newButton({
            normalImage = "tb_69.png",
            size = cc.size(90, 90),
            position = cc.p(xPos, 35),
            clickAction = function()
                local boxData = BattleObj:getBoxData(self.mChapterId, true, false)
                local item = boxData.StarBox[i]
                if not item.ifDraw then
                    if item.starCount >= item.needStar then
                        -- 请求打开宝箱
                        BattleObj:requestDrawBox(self.mChapterId, item.boxId, function(response)
                            if not response or response.Status ~= 0 then
                                return
                            end
                            -- 打开宝箱音效
                            MqAudio.playEffect("sound_kaibaoxiang.mp3")
                            -- 打开宝箱特效
                            -- local boxReceiveEffect = self.barBoxEffects[i]
                            -- -- boxReceiveEffect:setAnimation(0, "kaiqi", false)
                            -- SkeletonAnimation.action({
                            --         skeleton = boxReceiveEffect,
                            --         action = "kaiqi",
                            --         loop = false,
                            --         endListener = function()
                                            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList, true)
                            --         end,
                            --     })
                            -- 延时打开特效
                            -- Utility.performWithDelay(self.mParentLayer, function()
                                -- ui.newEffect({
                                --         parent = boxBgSprite,
                                --         effectName = "effect_ui_xiangzitexiao",
                                --         animation = "kaiqi",
                                --         position = cc.p(xPos, 35+30),
                                --         scale = 0.35,
                                --         loop = false,
                                --         endRelease = true,
                                --         endListener = function()
                                            -- boxReceiveEffect:setVisible(false)
                                            self:refreshStarBox()
                                            self:executeGuide()
                                    --     end,
                                    -- })
                            -- end,0.5)
                        end)
                    else
                        local tempConfig = BattleChapterBoxRelation.items[item.boxId]
                        if tempConfig then
                            local hintStr = TR("获得相应烧刀子酒可以领取以下奖励")
                            local previewList = Utility.analysisStrResList(tempConfig.outputResource)

                            -- 超级QQ会员有元宝加成
                            if PlayerAttrObj:getPlayerAttrByName("LoginType") == 2 then
                                for _, resInfo in pairs(previewList) do
                                    if resInfo.resourceTypeSub == ResourcetypeSub.eDiamond then
                                        resInfo.num = resInfo.num + math.floor(resInfo.num*0.2)
                                        break
                                    end
                                end
                            end
                            
                            MsgBoxLayer.addPreviewDropLayer(previewList, hintStr, TR("奖励预览"))
                        end
                    end
                end
            end
        })
        boxBgSprite:addChild(boxBtn)
        -- 星级label
        local boxLabel = ui.newLabel({
            text = string.format("%d/%d", chapterInfo.StarCount, openStars[i]),
            size = 18,
            color = Enums.Color.eNormalWhite,
            outlineColor = cc.c3b(0x20, 0x20, 0x20),
            outlineSize = 2,
        })
        boxLabel:setPosition(42, 85)
        boxBtn:addChild(boxLabel)
        table.insert(self.barBoxBtns, boxBtn)
        table.insert(self.barBoxEffects, boxReceiveEffect)
    end
end

-- 创建路边宝箱
function BattleNormalNodeLayer:createRoadBox(parent, chapterId)
    local boxData = BattleObj:getBoxData(chapterId, false, true)
    local boxNodeList = {}
    self.RoadBoxEffect = {}
    for i, boxInfo in pairs(boxData.RoadBox) do
        if boxInfo.status ~= Enums.RewardStatus.eHadDraw then
            local tempBtn = ui.newButton({
                normalImage = "tb_69.png",
                size = cc.size(90, 90),
                clickAction = function(btnObj)
                    if boxInfo.status == Enums.RewardStatus.eAllowDraw then
                        BattleObj:requestDrawRoadBox(chapterId, boxInfo.boxId, function(response)
                            if not response or response.Status ~= 0 then
                                return
                            end
                            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList, true)

                            self:executeGuide()
                        end)
                    else
                        local tempConfig = BattleRoadBoxRelation.items[boxInfo.boxId]
                        if tempConfig then
                            local hintStr = TR("通过前面的关卡可以领取以下奖励")
                            local previewList = Utility.analysisStrResList(tempConfig.outputResource)
                            MsgBoxLayer.addPreviewDropLayer(previewList, hintStr, TR("奖励预览"))
                        end
                    end
                end
            })
            local nodeModelId = BattleRoadBoxRelation.items[boxInfo.boxId].needNodeModelID
            local pos = BattleNodeModel.items[nodeModelId].points
            pos = Utility.analysisPoints(pos)
            local tempSize = tempBtn:getContentSize()
            tempBtn:setPosition(pos.x + tempSize.width, pos.y - 10)
            parent:addChild(tempBtn, 1) -- 宝箱比其它元素的层级高一点
            tempBtn:setScale(0.8)
            --
            boxNodeList[boxInfo.index] = tempBtn
            --
            if boxInfo.status == Enums.RewardStatus.eAllowDraw then
                local boxReceiveEffect = ui.newEffect({
                        parent = parent,
                        effectName = "effect_yinbaoxiang",
                        animation = "kaiqi",
                        position = cc.p(pos.x + tempSize.width, pos.y - 10),
                        scale = 0.2,
                        loop = true,
                    })
                tempBtn:loadTextures("c_83.png", "c_83.png")
                if not self.mRoadBox_ then
                    self.mRoadBox_ = tempBtn
                end
                self.RoadBoxEffect[i] = boxReceiveEffect
            end
        end
    end

    -- 注册宝箱信息改变的事件通知
    local function dealRoadBoxStatus()
        local boxData = BattleObj:getBoxData(chapterId, false, true)
        for k,v in pairs(self.RoadBoxEffect) do
            v:removeFromParent()
        end
        self.RoadBoxEffect = {}
        for i, boxInfo in pairs(boxData.RoadBox) do
            local tempBtn = boxNodeList[boxInfo.index]
            if not tolua.isnull(tempBtn) then
                -- 判断宝箱是否需要隐藏掉（如果宝箱所在掉位置正好在当前可以挑战的节点上，则需要隐藏）
                local roadBoxRel = BattleRoadBoxRelation.items[boxInfo.boxId]
                if roadBoxRel.needNodeModelID == self.mBattleInfo.MaxNodeId then
                    tempBtn:setVisible(roadBoxRel.needNodeModelID ~= self.mBattleInfo.MaxNodeId)
                end

                if boxInfo.status == Enums.RewardStatus.eAllowDraw then  -- 可以领取
                    local posx,posy = tempBtn:getPosition()
                    local boxReceiveEffect = ui.newEffect({
                        parent = parent,
                        effectName = "effect_yinbaoxiang",
                        animation = "kaiqi",
                        position = cc.p(posx,posy),
                        scale = 0.2,
                        loop = true,
                    })
                    self.RoadBoxEffect[i] = boxReceiveEffect
                elseif boxInfo.status == Enums.RewardStatus.eHadDraw then  -- 已领取了
                    tempBtn:setVisible(false)
                end
            end
        end
    end
    Notification:registerAutoObserver(parent, dealRoadBoxStatus, EventsName.eBattleChapterPrefix .. tostring(chapterId))
    dealRoadBoxStatus()
end

-- 刷新星数宝箱信息
function BattleNormalNodeLayer:refreshStarBox()
    local boxImage = {"tb_69.png", "tb_71.png", "tb_75.png"}
    local openImage = {"tb_70.png", "tb_72.png", "tb_76.png"}
    local boxData = BattleObj:getBoxData(self.mChapterId, true, false)

    for i,v in ipairs(boxData.StarBox) do
        local curBoxBtn = self.barBoxBtns[i]
        if curBoxBtn.flashNode then
            curBoxBtn:stopAllActions()
            curBoxBtn.flashNode:removeFromParent()
            curBoxBtn.flashNode = nil
        end
    end

    for index, item in ipairs(boxData.StarBox) do
        local curBoxBtn = self.barBoxBtns[index]
        if item.ifDraw then
            curBoxBtn:loadTextures(openImage[index], openImage[index])
            -- 还没有满足条件
            if not tolua.isnull(curBoxBtn.flashNode) then
                curBoxBtn:stopAllActions()
                curBoxBtn.flashNode:removeFromParent()
                curBoxBtn.flashNode = nil
            end
        else
            curBoxBtn:loadTextures(boxImage[index], boxImage[index])
            if item.starCount >= item.needStar then
                -- 特效
                -- local boxEffect = self.barBoxEffects[index]
                -- boxEffect:setVisible(true)
                -- 按钮
                local size = curBoxBtn:getContentSize()
                -- curBoxBtn:loadTextures("c_83.png", "c_83.png")
                ui.setWaveAnimation(curBoxBtn) -- 可以领取
                
            end
        end
    end
end

-- ====================== 请求服务器相关函数(需要调用 CacheBattle 中相关的函数) =========================
-- todo

-- ========================== 新手引导 ===========================

function BattleNormalNodeLayer:executeGuide()
    local _, _, eventID = Guide.manager:getGuideInfo()
    Guide.manager:showChapterGuide(self.mChapterId, function(isShow)
        if eventID == 1381 then
            -- 检查是否触发了第一次限时任务
            Guide.manager.__battleNormalLayer = self
            LayerManager.addLayer({
                name = "home.TimeLimitTheBountyLayer",
                cleanUp = false
            })
        else
            if table.indexof(Guide.config.battleEvent, eventID) then
                -- 屏蔽界面操作，npc加载回调中触发引导
                Guide.manager:showGuideLayer({})
                -- 执行新手引导时需要屏蔽拖动
                self.worldView:setTouchEnabled(false)
            else
                Guide.helper:executeGuide({
                    -- 添加第一个主将"洪凌波"
                    [1020001] = {nextStep = function(eventID, isGot)
                        if isGot then
                            Guide.manager:nextStep(1020001)
                        end
                        self:executeGuide()
                    end},
                    -- "洪凌波"加入队伍
                    [1020003] = {nextStep = function ()
                        -- 触发下一步引导
                        self:executeGuideAfterHero(self.mNodeId)
                    end},
                    -- 返回到章节
                    [10217] = {clickNode = self.mCloseBtn},
                })
            end
        end
    end)
end

-- npc加载完成之后触发某些引导
function BattleNormalNodeLayer:executeGuideAfterHero(nodeId)
    if nodeId == self.mNodeId then
        local _, _, eventID = Guide.manager:getGuideInfo()
        local girlPos = nil
        if eventID == 10215 then
            girlPos = cc.p(display.cx, display.cy)
        elseif eventID == 10408 then
            girlPos = cc.p(display.cx, 420 * Adapter.MinScale)
        end
        -- 触发战斗结点引导
        if table.indexof(Guide.config.battleEvent, eventID) then
            Guide.helper:executeGuide({
                [eventID] = {clickNode = self.nodeHeroList[self.mNodeId], hintPos = girlPos},
            })
        end
    end
end

return BattleNormalNodeLayer

--[[
    文件名：ExpediNodeLayer.lua
    描述：  组队副本难度选择
    创建人： heguanghui
    创建时间：2017.9.1
-- ]]

local ExpediNodeLayer = class("ExpediNodeLayer", function(params)
    return display.newLayer()
end)

--[[
    params:
        mapType     地图类型（1：六大派 2：明教总坛）
        nodeInfo    节点数据
        isGuaji     是否在挂机
        nodeList    节点列表数据
]]

-- 初始化
function ExpediNodeLayer:ctor(params)
    self.mMapType = params.mapType or 1
    self.nodeInfo = params.nodeInfo
    self.nodeInfoList = params.nodeList
    self.mIsGuaJi = params.isGuaji
    self.mConfigInfo = self:getConfigInfo()
    -- 页面元素父节点
    self.mParentLayer = cc.Node:create()
    self:addChild(self.mParentLayer)

    -- 创建基础UI
    self:initUI()
end

function ExpediNodeLayer:getConfigInfo()
    local configList = {
        [1] = {         -- 六大派
            buildInfo = {
                {btnImage = "gmd_08.png", dtyImage = "c_159.png", bId = 1111, pos = cc.p(202, 235), titlePos = cc.p(123, 230), name = TR("华山派")}, 
                {btnImage = "gmd_09.png", dtyImage = "c_86.png", bId = 1112, pos = cc.p(533, 369), titlePos = cc.p(462, 305), name = TR("崆峒派")}, 
                {btnImage = "gmd_07.png", dtyImage = "c_87.png", bId = 1113, pos = cc.p(106, 485), titlePos = cc.p(201, 471), name = TR("昆仑派")}, 
                {btnImage = "gmd_06.png", dtyImage = "c_160.png", bId = 1114, pos = cc.p(540, 576), titlePos = cc.p(584, 639), name = TR("峨眉派")}, 
                {btnImage = "gmd_05.png", dtyImage = "c_89.png", bId = 1115, pos = cc.p(284, 667), titlePos = cc.p(349, 727), name = TR("武当派")}, 
                {btnImage = "gmd_04.png", dtyImage = "c_90.png", bId = 1116, pos = cc.p(194, 837), titlePos = cc.p(120, 857), name = TR("少林寺")},
            },
            bgSprite = "gmd_03.jpg",
            isBoss = true,
        },
        [2] = {         -- 明教总坛
            buildInfo = {
                {btnImage = "gmd_19.png", dtyImage = "c_160.png", bId = 2111, pos = cc.p(346, 326), titlePos = cc.p(396, 326), name = TR("明教山门")}, 
                {btnImage = "gmd_18.png", dtyImage = "c_90.png", bId = 2112, pos = cc.p(170, 524), titlePos = cc.p(100, 524), name = TR("藏经阁")}, 
                {btnImage = "gmd_17.png", dtyImage = "c_89.png", bId = 2113, pos = cc.p(520, 680), titlePos = cc.p(440, 685), name = TR("明教祭坛")}, 
                {btnImage = "gmd_16.png", dtyImage = "c_87.png", bId = 2114, pos = cc.p(275, 855), titlePos = cc.p(195, 855), name = TR("明教大殿")}, 
            },
            bgSprite = "mp_127.jpg",
            isBoss = false,
        },
    }

    return configList[self.mMapType]
end

-- ui
function ExpediNodeLayer:initUI()
    -- 背景
    local bgSprite = ui.newSprite(self.mConfigInfo.bgSprite)
    bgSprite:setPosition(cc.p(320, 568))
    self.mParentLayer:addChild(bgSprite)
    -- logo
    local logoSprite = ui.newSprite("gmd_02.png")
    logoSprite:setPosition(320, 1039)
    self.mParentLayer:addChild(logoSprite)

    -- 标题
    local titleNode = ui.createSpriteAndLabel({
        imgName = "c_25.png",
        labelStr = TR("难度选择"),
        fontColor = cc.c3b(0xff, 0xff, 0xff),
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
    })
    titleNode:setPosition(cc.p(320, 970))
    self.mParentLayer:addChild(titleNode)

    -- 创建建筑按钮
    self.buildBtnList = {}
    for _,building in ipairs(self.mConfigInfo.buildInfo) do
        local iconBtn = ui.newButton({normalImage = building.btnImage,
            position = building.pos,
            clickAction = function ()
                if building.bId > self.nodeInfo.CurrentNodeId then
                    local needLv = ExpeditionNodeModel.items[building.bId].needLV
                    ui.showFlashView(TR("等级达到%d级且通关上一难度开启", needLv))
                    return 
                end

                -- 正在挂机
                if self.mIsGuaJi then 
                    LayerManager.addLayer({
                        name = "challenge.ExpediGuaJiPopLayaer",
                        data = {callback = function ( ... )
                            self:getIsGuaJiInfo()
                        end},
                        cleanUp = false,
                    })
                    return 
                end 
                -- 选择难度关卡
                local difficultID = building.bId % 100  -- 同一个门派余数都一样
                self:selecDifficultPopLayer(difficultID)
            end
            })
        self.mParentLayer:addChild(iconBtn)
        self.buildBtnList[building.bId] = iconBtn
        --显示难度名
        local nameBgSprite = ui.newScale9Sprite("gmd_01.png", cc.size(50, 200))
        nameBgSprite:setPosition(building.titlePos)
        self.mParentLayer:addChild(nameBgSprite)
        local nameBgSize = nameBgSprite:getContentSize()
        local titleLabel = ui.newLabel({
            text = building.name,
            color = cc.c3b(0x3b, 0x23, 0x23),
            dimensions = cc.size(20, 0),
        })
        titleLabel:setPosition(cc.p(nameBgSize.width/2, nameBgSize.height/2 + 12))
        nameBgSprite:addChild(titleLabel)
        -- 难度图
        -- local dtySprite = ui.newSprite(building.dtyImage)
        -- dtySprite:setPosition(cc.p(30, 168))
        -- dtySprite:setScale(0.6)
        -- nameBgSprite:addChild(dtySprite)

        -- 保存dty相关的描述
        iconBtn.dtyList = {nameBgSprite, dtySprite}
    end

    if self.mConfigInfo.isBoss then
        -- 创建boss节点
        self.mBossNode = self:createBossNode()
        self.mBossNode:setPosition(cc.p(284, 667))
        self.mParentLayer:addChild(self.mBossNode)
        -- 创建boss移动
        self:createBossPath()
    end

    Utility.performWithDelay(self, function ()
        self:refreshOpenStatus()
    end, 0.002)
end

-- 创建boss成昆的人物节点
function ExpediNodeLayer:createBossNode()
    -- boss节点
    local bossNode = cc.Node:create()
    bossNode:setAnchorPoint(cc.p(0.5, 0))

    -- boss人物模型
    local heroFigure = ui.newEffect({
            parent = bossNode,
            effectName = "hero_chengkun",
            animation = "zou",
            position = cc.p(0, 0),
            scale = 0.08,
            loop = true,
        })
    bossNode.heroFigure = heroFigure

    -- 延时等待加载出来，获取模型大小
    Utility.performWithDelay(bossNode, function ()
        -- 模型大小
        local figureSize = heroFigure:getBoundingBox()
        bossNode:setContentSize(figureSize)
        -- 创建透明按钮，让boss可点击
        ui.newButton({
            normalImage = "c_83.png",
            size = cc.size(figureSize.width, figureSize.height+45),
            anchorPoint = cc.p(0.5, 0),
            position = cc.p(figureSize.width*0.5, 0),
            clickAction = function ()
                local chengkunId = 1217 -- 成昆简单id
                local chengkunInfo = ExpeditionNodeModel.items[chengkunId]
                local name = ExpeditionNodeModel.items[chengkunInfo.needNodeModelID].name
                if chengkunId > self.nodeInfo.CurrentNodeId then
                    ui.showFlashView(TR("等级达到%d级且通关%s开启", chengkunInfo.needLV, name))
                    return
                end

                -- 正在挂机
                if self.mIsGuaJi then 
                    LayerManager.addLayer({
                        name = "challenge.ExpediGuaJiPopLayaer",
                        data = {callback = function ( ... )
                            self:getIsGuaJiInfo()
                        end},
                        cleanUp = false,
                    })
                    return 
                end 

                -- 弹窗
                self:createBossBox()
            end,
        }):addTo(bossNode)
        -- 重设人物模型位置
        heroFigure:setAnchorPoint(cc.p(0.5, 0))
        heroFigure:setPosition(figureSize.width*0.5, 0)
        -- 创建脚底阴影
        local shadeSprite = ui.newSprite("ef_c_67.png")
        shadeSprite:setPosition(figureSize.width*0.5, 0)
        shadeSprite:setScale(0.25)
        bossNode:addChild(shadeSprite, -1)
        -- 头顶boss图片
        local bossSprite = ui.newSprite("gmd_13.png")
        bossSprite:setPosition(figureSize.width*0.5, figureSize.height+10)
        bossNode:addChild(bossSprite)
        -- 头顶开启图片
        local openSprite = ui.newSprite("gmd_15.png")
        openSprite:setPosition(figureSize.width*0.5, figureSize.height+30)
        bossNode:addChild(openSprite)
        bossNode.openSprite = openSprite
    end, 0.001)

    return bossNode
end

-- 创建boss弹窗
function ExpediNodeLayer:createBossBox()
    local function createBoxUI(parent, bgSprite, bgSize)
        -- 文本
        local textLabel = ui.newLabel({
                text = TR("发现boss成昆，击败成昆在原有奖励的基础上有概率获得光明顶密藏，可开出以下奖励，成昆功夫极为高深，建议组队挑战:"),
                color = cc.c3b(0x46, 0x22, 0x0d),
                size = 20,
                anchorPoint = cc.p(0.5, 1),
                dimensions = cc.size(bgSize.width*0.8, 0),
                align = ui.TEXT_ALIGN_CENTER,
            })
        textLabel:setPosition(bgSize.width*0.5, bgSize.height-70)
        bgSprite:addChild(textLabel)
        -- 黑背景
        local blackSprite = ui.newScale9Sprite("c_17.png", cc.size(474, 151))
        blackSprite:setPosition(bgSize.width*0.5, bgSize.height*0.58)
        bgSprite:addChild(blackSprite)
        -- 奖励图
        local rewardSprite = ui.newSprite("gmd_14.png")
        rewardSprite:setAnchorPoint(cc.p(0, 0.5))
        rewardSprite:setPosition(23, bgSize.height*0.365)
        bgSprite:addChild(rewardSprite)
        -- 奖励列表(16020167是GoodsModel表中光明顶秘藏的id)
        local rewardListData = GoodsOutputRelation.items[16020167]
        local rewardList = {}
        for _, info in pairs(rewardListData or {}) do
            local cardInfo = {}
            cardInfo.resourceTypeSub = info.outputTypeID
            cardInfo.modelId = info.outputModelID
            cardInfo.num = info.outputNum

            table.insert(rewardList, cardInfo)
        end
        local rewardShow = ui.createCardList({
                maxViewWidth = bgSize.width*0.9,
                cardDataList = rewardList,
            })
        rewardShow:setAnchorPoint(cc.p(0.5, 0.5))
        rewardShow:setPosition(bgSize.width*0.5, 95)
        bgSprite:addChild(rewardShow)

        -- listView
        local listView = ccui.ListView:create()
        listView:setDirection(ccui.ScrollViewDir.vertical)
        listView:setContentSize(cc.size(474, 151))
        listView:setAnchorPoint(cc.p(0.5, 0.5))
        listView:setPosition(bgSize.width*0.5, bgSize.height*0.58)
        listView:setBounceEnabled(true)
        bgSprite:addChild(listView)
        -- 关卡列表
        local guanqiaList = {
            1217,   -- 成昆简单
            1317,   -- 成昆困难
        }

        for _, Id in ipairs(guanqiaList) do
            local cellSize = cc.size(480, 70)
            local layout = ccui.Layout:create()
            layout:setContentSize(cellSize)

            -- 子项背景
            local cellBtn = ui.newButton({
                normalImage = "gd_10.png",
                lightedImage = "gd_10.png",
                disabledImage = "zdfb_12.png",
                size = cc.size(420, 50),
                position = cc.p(cellSize.width / 2, cellSize.height / 2),
                clickAction = function()
                    local itemInfo = ExpeditionNodeModel.items[Id]
                    if Id > self.nodeInfo.CurrentNodeId then
                        -- 找出上一关的难度ID
                        local upDifficuleID = ExpeditionNodeModel.items[Id].needNodeModelID
                        local needLv = ExpeditionNodeModel.items[Id].needLV
                        local name = ExpeditionNodeModel.items[upDifficuleID].name
                        ui.showFlashView(TR("等级达到%d级且通关%s开启", needLv, name))
                        return
                    end

                    local isPass = false
                    for _, nodeInfo in pairs(self.nodeInfoList) do
                        if nodeInfo.NodeModelId == Id then
                            isPass = nodeInfo.IsPass
                            break
                        end
                    end

                    -- 进入创建队伍主页面
                    LayerManager.addLayer({
                        name = "challenge.ExpediHomeLayer",
                        data = {nodeId = Id, maxNodeId = self.nodeInfo.CurrentNodeId, isPass = isPass},
                    })
                end
            })
            layout:addChild(cellBtn)

            -- 屏蔽第二层以及之后的节点
            if Id > self.nodeInfo.CurrentNodeId then
                cellBtn:setBright(false)
                local tempLabel = ui.newSprite("c_35.png")
                tempLabel:setPosition(cellBtn:getContentSize().width * 0.25, cellBtn:getContentSize().height / 2)
                cellBtn:addChild(tempLabel)
            end
            -- 在按钮上加字
            local btnLabel = ui.newLabel({
                text = ExpeditionNodeModel.items[Id].name,
                color = Enums.Color.eNormalWhite,
                outlineColor = cc.c3b(0x46, 0x22, 0x0d),
                size = 24,
            })
            btnLabel:setPosition(cellBtn:getContentSize().width/2, cellBtn:getContentSize().height / 2)
            cellBtn:addChild(btnLabel)
            listView:pushBackCustomItem(layout)
        end

    end

    LayerManager.addLayer({
            name = "commonLayer.MsgBoxLayer",
            data = {
                bgSize = cc.size(560, 520),
                title = TR("成昆老贼，哪里跑！"),
                notNeedBlack = true,
                btnInfos = {},
                closeBtnInfo = {},
                DIYUiCallback = createBoxUI,
            },
            cleanUp = false,
        })
end

-- 创建boss移动路线
function ExpediNodeLayer:createBossPath()
    -- 路线节点
    local stepList = {
        cc.p(260, 233),
        cc.p(472, 330),
        cc.p(214, 464),
        cc.p(521, 489),
        cc.p(477, 565),
        cc.p(357, 625),
        cc.p(317, 694),
        cc.p(218, 738),
        cc.p(243, 766),
    }

    -- 路线节点不能小于2个
    if #stepList < 2 then return end

    -- 随机起点
    local startIndex = math.random(#stepList)
    self.mBossNode:setPosition(stepList[startIndex])

    -- 行走方向（上下）,默认向上
    local walkDir = 1   -- 1：上，-1：下
    -- 移动速度
    local walkSpeed = 50

    -- 移动一步
    local function moveStep()
        -- 下个移动节点索引
        if startIndex <= 1 then
            walkDir = 1     -- 改为向上
        elseif startIndex >= #stepList then
            walkDir = -1    -- 改为向下
        end
        startIndex = startIndex + walkDir
        -- boss模型方向(boss模型默认是向右)
        local nextPos = stepList[startIndex]
        local bossX, bossY = self.mBossNode:getPosition()
        self.mBossNode.heroFigure:setRotationSkewY(nextPos.x > bossX and 0 or 180)
        -- 计算需要时间
        local distance = cc.pGetLength(cc.pSub(nextPos, cc.p(bossX, bossY)))
        local walkTime = distance/walkSpeed

        local moveAction = cc.MoveTo:create(walkTime, stepList[startIndex])
        self.mBossNode:runAction(moveAction)

        return walkTime
    end

    -- 计时
    local function createSchedule()
        local time = 0
        self:scheduleUpdate(function(dt)
            if time <= 0 then
                local walkTime = moveStep()
                time = walkTime
            else
                time = time - dt
            end
        end)
    end

    -- 开始走路
    createSchedule()
end

-- 显示已开启状态
function ExpediNodeLayer:refreshOpenStatus()
    for bId,btn in pairs(self.buildBtnList) do
        local btnSize = btn:getContentSize()
        if self.nodeInfo.CurrentNodeId >= bId then
            -- 显示已开启
            local statePos = cc.p(btnSize.width/2, btnSize.height/2 - 40)
            local stateBgSprite = ui.newSprite("c_157.png")
            stateBgSprite:setPosition(statePos)
            btn:addChild(stateBgSprite)
            local stateLabel = ui.newLabel({
                text = TR("已开启"),
                color = Enums.Color.eNormalWhite,
            })
            stateLabel:setPosition(statePos)
            btn:addChild(stateLabel)
        else
            local stateBgSprite = ui.newSprite("gmd_10.png")
            stateBgSprite:setPosition(cc.p(btnSize.width/2, btnSize.height/2))
            btn:addChild(stateBgSprite)
            -- 名字，旗子等置灰
            for _,item in ipairs(btn.dtyList) do
                item:setGray(true)
            end
        end
    end

    -- 刷新boss成昆开启状态
    if self.mBossNode and not tolua.isnull(self.mBossNode) then
        -- 1217是ExpeditionNodeModel表中成昆简单关卡的id
        self.mBossNode.openSprite:setVisible(1217 <= self.nodeInfo.CurrentNodeId)
    end
end

-- 选择难度弹窗
    --difficultID:门派关卡ID的余数
function ExpediNodeLayer:selecDifficultPopLayer(difficultID)
    local battleList = {}
    for _, item in pairs(ExpeditionNodeModel.items) do
        if math.floor(item.ID/1000) == self.mMapType and item.ID%100 == difficultID then
            table.insert(battleList, {
                Id = item.ID,
                name = item.name,
            })
        end   
    end
    table.sort(battleList, function(item1, item2)
        return item1.Id < item2.Id
    end)


    local function DIYFunction(layerObj, bgSprite, bgSize)
        local viewSize = cc.size(480, 250)
        -- 背景
        local tempSprite = ui.newScale9Sprite("c_17.png", viewSize)
        tempSprite:setAnchorPoint(cc.p(0.5, 1))
        tempSprite:setPosition(bgSize.width / 2, bgSize.height - 70)
        bgSprite:addChild(tempSprite)

        local size = tempSprite:getContentSize()
        local cellSize = cc.size(480, 50)

        -- listView
        local listView = ccui.ListView:create()
        listView:setDirection(ccui.ScrollViewDir.vertical)
        listView:setContentSize(cc.size(viewSize.width, viewSize.height - 20))
        listView:setAnchorPoint(cc.p(0.5, 0))
        listView:setPosition(size.width / 2, 5)
        listView:setItemsMargin(10)
        listView:setBounceEnabled(true)
        tempSprite:addChild(listView)

        for index, item in pairs(battleList) do
            local layout = ccui.Layout:create()
            layout:setContentSize(cellSize)

            -- 子项背景
            local cellBtn = ui.newButton({
                normalImage = "gd_10.png",
                lightedImage = "gd_10.png",
                disabledImage = "zdfb_12.png",
                size = cc.size(cellSize.width - 60, cellSize.height),
                position = cc.p(cellSize.width / 2, cellSize.height / 2),
                clickAction = function()
                    if item.Id > self.nodeInfo.CurrentNodeId then
                        -- 找出上一关的难度ID
                        local upDifficuleID = 0
                        local allList = {}
                        for k,v in pairs(ExpeditionNodeModel.items) do
                            table.insert(allList, {
                                ID = v.ID,
                            })
                        end
                        table.sort(allList, function(item1, item2)
                            return item1.ID < item2.ID
                        end)
                        for _, v in ipairs(allList) do
                            if v.ID >= item.Id then 
                                break
                            else 
                                upDifficuleID = v.ID    
                            end 
                        end
                        local needLv = ExpeditionNodeModel.items[item.Id].needLV
                        local name = ExpeditionNodeModel.items[upDifficuleID].name
                        ui.showFlashView(TR("等级达到%d级且通关%s开启", needLv, name))
                        return
                    end

                    local isPass = false
                    for _, nodeInfo in pairs(self.nodeInfoList) do
                        if nodeInfo.NodeModelId == item.Id then
                            isPass = nodeInfo.IsPass
                            break
                        end
                    end
                    -- 进入创建队伍主页面
                    LayerManager.addLayer({
                        name = "challenge.ExpediHomeLayer",
                        data = {nodeId = item.Id, maxNodeId = self.nodeInfo.CurrentNodeId, isPass = isPass},
                    })
                end
            })
            layout:addChild(cellBtn)

            -- 屏蔽第二层以及之后的节点
            if item.Id > self.nodeInfo.CurrentNodeId then
                cellBtn:setBright(false)
                local tempLabel = ui.newSprite("c_35.png")
                tempLabel:setPosition(cellBtn:getContentSize().width * 0.25, cellBtn:getContentSize().height / 2)
                cellBtn:addChild(tempLabel)
            end
            -- 在按钮上加字
            local btnLabel = ui.newLabel({
                text = item.name,
                color = Enums.Color.eNormalWhite,
                outlineColor = cc.c3b(0x46, 0x22, 0x0d),
                size = 24,
            })
            btnLabel:setPosition(cellBtn:getContentSize().width/2, cellSize.height / 2)
            cellBtn:addChild(btnLabel)
            listView:pushBackCustomItem(layout)
        end
    end

    MsgBoxLayer.addDIYLayer({
        bgSize = cc.size(542, 350),
        title = TR("难度选择"),
        notNeedBlack = true,
        btnInfos = {},
        closeBtnInfo = {},
        DIYUiCallback = DIYFunction,
    })
end

---------------------------------------------
function ExpediNodeLayer:getIsGuaJiInfo()
    HttpClient:request({
        moduleName = "ExpeditionNode",
        methodName = "AllChapterInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            -- dump(response,"response")
            local data = response.Value
            -- 如果在挂机
            self.mIsGuaJi = data.GuajiInfo and data.GuajiInfo.IsGuaji or false
            if self.mIsGuaJi then 
                LayerManager.addLayer({
                    name = "challenge.ExpediGuaJiPopLayaer",
                    data = {callback = function ( ... )
                        self:getIsGuaJiInfo()
                    end},
                    cleanUp = false,
                })
            end 
        end
    })
end

return ExpediNodeLayer
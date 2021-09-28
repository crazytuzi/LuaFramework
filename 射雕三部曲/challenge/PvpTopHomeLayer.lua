--[[
    文件名：PvpTopHomeLayer
    描述：武林盟主分组战
    创建人：peiyaoqiang
    创建时间：2017.11.1
-- ]]
local PvpTopHomeLayer = class("PvpTopHomeLayer", function(params)
    return display.newLayer()
end)

----------------------------------------------------------------------------------------------------

--初始化页面
--[[
	params:
    Table params:
--]]
function PvpTopHomeLayer:ctor(params)
    params = params or {}
    -- 屏蔽下层事件
    ui.registerSwallowTouch({node = self})

    -- 读取参数
    self.curGroup = 0                   -- 当前分组
    self.curTurn = 1                    -- 当前轮次
    self.alreadyGuessed = false         -- 玩家已经下注竞猜
    self.alreadyTurn = 1                -- 已经结束或即将开始的轮次
    if (params.alreadyTurn ~= nil) then
        self.alreadyTurn = params.alreadyTurn
    end

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 顶部资源栏和底部导航栏
    local commonLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.eChallenge,
        topInfos = {
            ResourcetypeSub.eDiamond,
            ResourcetypeSub.eGold,
            ResourcetypeSub.eSTA,
        }
    })
    self:addChild(commonLayer)

    -- 初始化UI
    self:initUi()
    self:requestGetReport(params.group or 0, params.turn or 0)
end

function PvpTopHomeLayer:initUi()
    local bgSprite = ui.newSprite("wlmz_31.jpg")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)

    -- 底部背景
    local bottomBgSprite = ui.newScale9Sprite("c_65.png", cc.size(628, 110))
    bottomBgSprite:setAnchorPoint(cc.p(0.5, 0))
    bottomBgSprite:setPosition(320, 110)
    self.mParentLayer:addChild(bottomBgSprite, 2)
    self.bottomBgSprite = bottomBgSprite

    -- 返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    closeBtn:setPosition(Enums.StardardRootPos.eCloseBtn)
    self.mParentLayer:addChild(closeBtn, 3)

    -- 查看战绩和下注等功能按钮
    local buttonItems = {
        {             -- 我的战绩
            image = "tb_200.png", 
            xPos = 120, 
            callback = function ()
                LayerManager.addLayer({name="challenge.DlgMyFightLogLayer", data={}, cleanUp = false})
            end
        },
        {             -- 我的下注
            image = "tb_202.png", 
            xPos = 220, 
            callback = function ()
                LayerManager.addLayer({name="challenge.DlgGuessLogLayer", data={}, cleanUp = false})
            end
        },
        {             -- 冠军奖励
            image = "tb_201.png", 
            xPos = 320, 
            callback = function ()
                LayerManager.addLayer({name = "challenge.PvpTopRankLayer", data = {}, cleanUp = false})
            end
        },
        {   -- 规则
            image = "tb_127.png",
            xPos = 420,
            callback = function()
                MsgBoxLayer.addRuleHintLayer(TR("规则"), {
                    [1] = TR("1.一个赛季分为初赛、争霸赛2个阶段，一周为一个赛季"),
                    [2] = TR("2.每周周一0点至周日凌晨5点为初赛阶段，周日18:30点开始决赛，同时各位大侠可以给中意的强者下注"),
                    [3] = TR("3.初赛分为初入江湖，小有名气，名动一方，天下闻名，一代宗师，登峰造极，6个段位，登峰造极前128名进入武林神话段位，参加争霸赛"),
                    [4] = TR("4.初赛规则与武林争霸规则一致"),
                    [5] = TR("5.在争霸赛开始时，进入争霸赛的玩家会随机分成4个组进入战斗"),
                    [6] = TR("6.争霸赛分为16强赛、8强赛、4强赛、半决赛、决赛5个比赛阶段"),
                    [7] = TR("7.每场比赛的规则会根据比赛阶段进行变化（16强赛一局定胜负，8强赛三局两胜，4强赛三局两胜，半决赛三局两胜，决赛五局三胜)"),
                    [8] = TR("8.每个比赛阶段前都会开启【竞猜】\n每场比赛的阶段竞猜时间：\n    16强赛：每周日18:30-19：00\n    8强赛：每周日19:00-19:30\n    4强赛：每周日19:30-20:00\n    半决赛：每周日20:00-20:30\n    决赛：每周日20:30-21:00"),
                    [9] = TR("9.每个比赛阶段只能为1名玩家进行【下注】"),
                    [10] = TR("10.竞猜成功将获得酬金与本金返还，竞猜失败则无法获得酬金并且不返还本金"),
                    [11] = TR("11.本轮争霸赛结束后按照排行榜发放奖励，并可在次日对武林盟主进行膜拜，并开启下一轮比赛"),
                    [12] = TR("12.每位玩家可对【武林盟主】进行膜拜，每日只能进行1次膜拜"),
                    [13] = TR("13.每周将清空争霸赛的积分和信息，每两周将清空初赛的积分和信息"),
                    [14] = TR("14.每周参与竞猜，竞猜正确可以领取竞猜宝箱。"),
                })
            end
        },
        {   -- 竞猜宝箱
            image = "tb_281.png",
            xPos = 520,
            redDotModuleId = 6500,  -- 小红点ID
            callback = function()
               LayerManager.addLayer({name="challenge.DlgGuessBoxLayer", data={}, cleanUp = false})
            end
        }

    }
    for _,v in pairs(buttonItems) do
        local button = ui.newButton({
            normalImage = v.image,
            anchorPoint = cc.p(0.5, 0),
            position = cc.p(v.xPos, 230),
            clickAction = v.callback,
        })
        self.mParentLayer:addChild(button, 2)

        -- 处理小红点
        if (v.redDotModuleId ~= nil) and (v.redDotModuleId > 0) then
            ui.createAutoBubble({
                parent = button, 
                eventName = RedDotInfoObj:getEvents(v.redDotModuleId), 
                refreshFunc = function (redDotSprite)
                    redDotSprite:setVisible(RedDotInfoObj:isValid(v.redDotModuleId))
                end})
        end
    end

    -- 创建Tab
    local tabItems = {
        {tag = 1, text = TR("东邪")},
        {tag = 2, text = TR("西毒")},
        {tag = 3, text = TR("南帝")},
        {tag = 4, text = TR("北丐")}
    }
    local tabView = ui.newTabLayer({
        btnInfos = tabItems,
        btnSize = cc.size(122, 56), 
        defaultSelectTag = self.curGroup,
        -- needLine = false,
        onSelectChange = function(tag)
            if (self.curGroup ~= tag) then
                self:requestGetReport(tag, 0)
            end
        end,
    })
    tabView:setAnchorPoint(cc.p(0, 0))
    tabView:setPosition(cc.p(0, 980))
    self.mParentLayer:addChild(tabView)
    self.tabView = tabView

    -- Tab数据内容Layer，便于刷新
    local tmpLayer = cc.LayerColor:create(cc.c4b(255, 0, 0, 0))
    tmpLayer:setContentSize(cc.size(640, 650))
    tmpLayer:setIgnoreAnchorPointForPosition(false)
    tmpLayer:setAnchorPoint(cc.p(0.5, 1))
    tmpLayer:setPosition(cc.p(320, 960))
    self.mParentLayer:addChild(tmpLayer, 2)
    self.tabLayer = tmpLayer
    self.tabSize = tmpLayer:getContentSize()

    -- 显示战报轮次按钮
    self:showTableButtons()
end

-- 刷新分组显示
function PvpTopHomeLayer:refreshTabLayer()
    self.tabLayer:removeAllChildren()

    -- 显示倒计时
    self:showRemainTimer()

    -- 读取一些属性
    local showData = self:analyzeData()
    local dataCount = table.maxn(showData)
    local pageCount, pageCurr = math.ceil(dataCount/4), 1
    local btnLeft, btnRight, tableSliderView = nil, nil, nil

    -- 显示拖动按钮
    if (pageCount > 1) then
        btnLeft = ui.newSprite("c_43.png")
        btnRight = ui.newSprite("c_43.png")
        btnLeft:setPosition(20, self.tabSize.height / 2)
        btnRight:setPosition(self.tabSize.width - 20, self.tabSize.height / 2)
        btnLeft:setRotation(90)
        btnRight:setRotation(270)
        btnLeft:setVisible(false)
        btnRight:setVisible(true)
        self.tabLayer:addChild(btnLeft, 1)
        self.tabLayer:addChild(btnRight, 1)
    end

    -- 显示对阵列表
    local mCellSize = self.tabSize
    local mSliderView = ui.newSliderTableView({
        width = mCellSize.width,
        height = mCellSize.height,
        isVertical = false,
        selItemOnMiddle = true,
        itemCountOfSlider = function(sliderView)
            return pageCount
        end,
        itemSizeOfSlider = function(sliderView)
            return mCellSize.width, mCellSize.height
        end,
        sliderItemAtIndex = function(sliderView, itemNode, index)
            if (dataCount == 1) then        -- 1组（决赛）
                self:drawCounterpartTableFor2(itemNode, mCellSize, showData)
            elseif (dataCount == 2) then    -- 2组（半决赛）
                self:drawCounterpartTableFor4(itemNode, mCellSize, showData)
            else                            -- 多组（淘汰赛）
                local tmpShowData = {}
                local beginIdx = index * 4 + 1
                for i,v in ipairs(showData) do
                    if (i >= beginIdx) and (i < (beginIdx + 4)) then
                        table.insert(tmpShowData, v)
                    end
                end
                self:drawCounterpartTableFor8(itemNode, mCellSize, tmpShowData)
            end
        end,
        selectItemChanged = function(sliderView, selectIndex)
            if (pageCount == 1) or (btnLeft == nil) or (btnRight == nil) then
                return
            end
            pageCurr = selectIndex + 1
            if (pageCurr == 1) then
                btnLeft:setVisible(false)
                btnRight:setVisible(true)
            elseif (pageCurr == pageCount) then
                btnLeft:setVisible(true)
                btnRight:setVisible(false)
            else
                btnLeft:setVisible(true)
                btnRight:setVisible(true)
            end
        end
    })
    mSliderView:setTouchEnabled(pageCount > 1)
    mSliderView:setAnchorPoint(cc.p(0.5, 0.5))
    mSliderView:setPosition(self.tabSize.width / 2, self.tabSize.height / 2)
    self.tabLayer:addChild(mSliderView)
end

-- 获取恢复数据
function PvpTopHomeLayer:getRestoreData()
    -- 返回当前显示的组
    return {
        group = self.curGroup,
        turn = self.curTurn,
        alreadyTurn = self.alreadyTurn,
    }
end

----------------------------------------------------------------------------------------------------

-- 辅助函数：显示下注倒计时
function PvpTopHomeLayer:showRemainTimer()
    -- 判断当前时间
    local function addTimeLabel(string)
        local label = ui.newLabel({
            text = string,
            x = self.tabSize.width * 0.5, 
            y = self.tabSize.height - 10,
        })
        self.tabLayer:addChild(label)
        return label
    end

    local times = os.date("*t", Player:getCurrentTime())
    if (times.wday == 1) then   -- 周日，老外的wday第1天从周日开始
        local formatTime = times.hour * 100 + times.min     -- 为了便于比较，将时间处理一下
        if (formatTime < 1830) then
            -- 18:30前显示固定提示语
            addTimeLabel(TR("比赛准备中，将于18:30开始下注竞猜"))
        elseif (formatTime >= 1830) and (formatTime < 2100) then
            -- 18:30-21:00之间显示倒计时
            local nCreateTime = self.infoData.CreateTime or 0
            if (nCreateTime <= Player:getCurrentTime()) then
                return
            end
            local timeLabel = addTimeLabel("")
            timeLabel:setLocalZOrder(1)

            local function valueActionUpdate(dt)
                local lastTime = nCreateTime - Player:getCurrentTime()
                if (lastTime <= 0) then
                    self.timeLabel:stopAllActions()
                    self:reloadData(0)
                else
                    timeLabel:setString(TR("开战倒计时 %s%s", "#9BFF6A", MqTime.formatAsHour(lastTime)))
                end
            end
            Utility.schedule(timeLabel, valueActionUpdate, 0.5)
            self.timeLabel = timeLabel
        end
    end
end

-- 辅助函数：显示查看对阵的按钮列表
function PvpTopHomeLayer:showTableButtons()
    local bottomBgHeight = self.bottomBgSprite:getContentSize().height
    local buttonNodeList, currButtonTag = {}, 0
    local tagStrConfig = {
        [1] = {guessTime = "18:30", time = "19:00", name = TR("16强赛")},
        [2] = {guessTime = "19:00", time = "19:30", name = TR("8强赛")},
        [3] = {guessTime = "19:30", time = "20:00", name = TR("4强赛")},
        [4] = {guessTime = "20:00", time = "20:30", name = TR("半决赛")},
        [5] = {guessTime = "20:30", time = "21:00", name = TR("决赛")},
    }
    for i,v in ipairs(tagStrConfig) do
        local xPos = (i - 1) * (100 + 32)

        -- 创建按钮
        local button = ui.newButton({
            normalImage = "wlmz_18.png",
            position = cc.p(xPos + 50, bottomBgHeight/2),
            clickAction = function()
                self.bottomBgSprite:selectItem(i)
            end,
        })
        button:setTag(i)
        self.bottomBgSprite:addChild(button)
        table.insert(buttonNodeList, button)

        -- 添加标题
        local buttonSize = button:getContentSize()
        local nameLabel = ui.newLabel({
            text = v.name,
            color = cc.c3b(0x46, 0x22, 0x0d),
            x = buttonSize.width * 0.5, 
            y = buttonSize.height * 0.6,
        })
        local timeLabel = ui.newLabel({
            text = v.time,
            color = cc.c3b(0x46, 0x22, 0x0d),
            x = buttonSize.width * 0.5, 
            y = buttonSize.height * 0.4,
        })
        button:addChild(nameLabel)
        button:addChild(timeLabel)

        -- 添加箭头
        if (i < 5) then
            local arrowSprite = ui.newSprite("c_66.png")
            arrowSprite:setPosition(xPos + 116, bottomBgHeight/2)
            self.bottomBgSprite:addChild(arrowSprite)
        end
    end

    -- 对外公开的选择接口
    self.bottomBgSprite.selectItem = function(target, tag)
        if (currButtonTag == tag) then
            return
        end

        -- 判断选中的比赛是否开始
        if (tag > self.alreadyTurn) then
            local tagItem = tagStrConfig[tag]
            ui.showFlashView(TR("%s将在%s后开启下注", tagItem.name, tagItem.guessTime))
            return
        end

        -- 刷新按钮选中状态
        for _,v in pairs(buttonNodeList) do
            if (v:getTag() == tag) then
                v:loadTextures("wlmz_19.png", "wlmz_19.png")
            else
                v:loadTextures("wlmz_18.png", "wlmz_18.png")
            end
        end

        -- 执行回调
        self:requestGetReport(self.curGroup, tag)
        currButtonTag = tag
    end
    self.bottomBgSprite:selectItem(self.curTurn)
end

----------------------------------------------------------------------------------------------------

-- 辅助函数：绘制2人对阵表
function PvpTopHomeLayer:drawCounterpartTableFor2(parent, parentSize, playerList)
    -- 绘制人物
    local function drawOneHero(playerItem, posX, isWin)
        -- 台子
        local heroBg = ui.newSprite("wlmz_29.png")
        heroBg:setPosition(posX, 100)
        heroBg:setScale(0.8)
        parent:addChild(heroBg)
        -- 显示人物
        local heroNode = Figure.newHero({
            heroModelID = playerItem.HeadImageId,
            fashionModelID = playerItem.FashionModelId,
            IllusionModelId = playerItem.IllusionModelId,
            scale = 0.25,
            shadow = false,
        })
        heroNode:setPosition(posX, 150)
        parent:addChild(heroNode)
        
        -- 显示战力
        local FAPBgSprite = ui.newFAPView(playerItem.Fap)
        FAPBgSprite:setPosition(posX + 20, 610)
        parent:addChild(FAPBgSprite)

        -- 玩家名字
        local nameLabel = ui.createLabelWithBg({
            bgFilename = "c_25.png",
            labelStr = playerItem.Name,
            outlineColor = Enums.Color.eOutlineColor,
            alignType = ui.TEXT_ALIGN_CENTER,
        })
        nameLabel:setPosition(posX, 60)
        parent:addChild(nameLabel)

        -- 所在区服
        local zoneLabel = ui.newLabel({
            text = "[" .. playerItem.Zone .. "]",
            size = 22,
            color = Enums.Color.eWhite,
            x = posX, 
            y = 105,
        })
        parent:addChild(zoneLabel)
        
        -- 显示胜负
        if (isWin ~= nil) then
            local winImg = (isWin == true) and "wlmz_26.png" or "wlmz_27.png"
            local winSprite = ui.newSprite(winImg)
            winSprite:setAnchorPoint(cc.p(0.5, 0))
            winSprite:setPosition(posX, 500)
            parent:addChild(winSprite)
        end
    end
    local v = playerList[1]
    local attWin, defWin = nil, nil
    if (v.AttackerWin ~= nil) then
        attWin = v.AttackerWin
        defWin = (not v.AttackerWin)
    end
    local attackerItem = {HeadImageId = v.AttackerHeadImageId, FashionModelId = v.AttackerFashionModelId, PlayerId = v.AttackerId, Fap = v.AttackerFAP, Name = v.AttackerName, Zone = v.AttackerZone}
    local defenderItem = {HeadImageId = v.DefenderHeadImageId, FashionModelId = v.DefenderFashionModelId, PlayerId = v.DefenderId, Fap = v.DefenderFAP, Name = v.DefenderName, Zone = v.DefenderZone}
    drawOneHero(attackerItem, parentSize.width * 0.23, attWin)
    drawOneHero(defenderItem, parentSize.width * 0.77, defWin)

    -- 显示箭头
    local arrowSprite = ui.newSprite("zdjs_07.png")
    arrowSprite:setPosition(parentSize.width * 0.5, parentSize.height * 0.5)
    parent:addChild(arrowSprite)

    -- 显示下注或查看按钮
    local buttonImg = (v.AttackerWin == nil) and "c_162.png" or "c_79.png"
    local buttonNode = ui.newButton({
        normalImage = buttonImg,
        position = cc.p(parentSize.width * 0.5, 90),
        clickAction = function ()
            self:battleExtraButtonAction(attackerItem, defenderItem, (v.AttackerWin == nil))
        end,
    })
    if (v.AttackerWin == nil) then
        buttonNode:setEnabled((not self.alreadyGuessed))
    end
    parent:addChild(buttonNode, 1)
end

-- 辅助函数：绘制4人对阵表
function PvpTopHomeLayer:drawCounterpartTableFor4(parent, parentSize, playerList)
    local tableBackSprite = ui.newSprite("wlmz_17.png")
    local tableBackSize = tableBackSprite:getContentSize()
    tableBackSprite:setPosition(parentSize.width * 0.5, parentSize.height * 0.5)
    parent:addChild(tableBackSprite)

    -- 显示箭头
    local arrowSprite = ui.newSprite("zdjs_07.png")
    arrowSprite:setPosition(tableBackSize.width * 0.5, tableBackSize.height * 0.5)
    tableBackSprite:addChild(arrowSprite)

    -- 节点位置配置
    local posList = {
        [1] = {
            attack = cc.p(-40, tableBackSize.height - 5),
            defense = cc.p(-40, 7),
            extra = cc.p(75, tableBackSize.height * 0.5),
        },
        [2] = {
            attack = cc.p(tableBackSize.width + 40, tableBackSize.height - 5),
            defense = cc.p(tableBackSize.width + 40, 7),
            extra = cc.p(tableBackSize.width - 75, tableBackSize.height * 0.5),
        },
    }
    self:drawCounterpartTableHeaders(tableBackSprite, playerList, posList)
end

-- 辅助函数：绘制8人对阵表
function PvpTopHomeLayer:drawCounterpartTableFor8(parent, parentSize, playerList)
    local tableBackSprite = ui.newSprite("wlmz_16.png")
    local tableBackSize = tableBackSprite:getContentSize()
    tableBackSprite:setPosition(parentSize.width * 0.5, parentSize.height * 0.5)
    parent:addChild(tableBackSprite)
    
    -- 显示箭头
    local arrowSprite = ui.newSprite("zdjs_07.png")
    arrowSprite:setPosition(tableBackSize.width * 0.5, tableBackSize.height * 0.5)
    tableBackSprite:addChild(arrowSprite)

    -- 节点位置配置
    local posList = {
        [1] = {
            attack = cc.p(-40, tableBackSize.height - 5),
            defense = cc.p(-40, 323),
            extra = cc.p(120, 400),
        },
        [2] = {
            attack = cc.p(-40, 158),
            defense = cc.p(-40, 7),
            extra = cc.p(120, 80),
        },
        [3] = {
            attack = cc.p(tableBackSize.width + 40, tableBackSize.height - 5),
            defense = cc.p(tableBackSize.width + 40, 323),
            extra = cc.p(tableBackSize.width - 120, 400),
        },
        [4] = {
            attack = cc.p(tableBackSize.width + 40, 158),
            defense = cc.p(tableBackSize.width + 40, 7),
            extra = cc.p(tableBackSize.width - 120, 80),
        },
    }
    self:drawCounterpartTableHeaders(tableBackSprite, playerList, posList)
end

-- 辅助函数：绘制对阵表的头像
function PvpTopHomeLayer:drawCounterpartTableHeaders(parent, playerList, posList)
    local function showHeaderNode(playerItem, pos, isWin)
        local headerBgSprite = ui.newSprite("wlmz_20.png")
        local headerBgSize = headerBgSprite:getContentSize()
        headerBgSprite:setPosition(pos)
        parent:addChild(headerBgSprite)

        -- 头像
        local headerNode = require("common.CardNode").new({allowClick = false,})
        headerNode:setHero({ModelId = playerItem.HeadImageId, FashionModelID = playerItem.FashionModelId, IllusionModelId = playerItem.IllusionModelId}, {CardShowAttr.eBorder})
        headerNode:setPosition(headerBgSize.width * 0.5, headerBgSize.height * 0.6)
        headerBgSprite:addChild(headerNode)

        -- 显示名字
        local nameLabel = ui.newLabel({
            text = playerItem.Name,
            size = 20,
            color = cc.c3b(0x46, 0x22, 0x0d),
            x = headerBgSize.width * 0.5, 
            y = 22,
        })
        headerBgSprite:addChild(nameLabel)

        -- 显示胜负
        if (isWin ~= nil) then
            local winImg = (isWin == true) and "zdjs_14.png" or "zdjs_13.png"
            local winSprite = ui.newSprite(winImg)
            winSprite:setPosition(headerBgSize.width - 12, headerBgSize.height - 12)
            headerBgSprite:addChild(winSprite)
        end
    end

    for i,v in ipairs(playerList) do
        local iPos = posList[i]
        local attWin, defWin = nil, nil
        if (v.AttackerWin ~= nil) then
            attWin = v.AttackerWin
            defWin = (not v.AttackerWin)
        end
        local attackerItem = {HeadImageId = v.AttackerHeadImageId, FashionModelId = v.AttackerFashionModelId, PlayerId = v.AttackerId, Fap = v.AttackerFAP, Name = v.AttackerName, Zone = v.AttackerZone}
        local defenderItem = {HeadImageId = v.DefenderHeadImageId, FashionModelId = v.DefenderFashionModelId, PlayerId = v.DefenderId, Fap = v.DefenderFAP, Name = v.DefenderName, Zone = v.DefenderZone}
        showHeaderNode(attackerItem, iPos.attack, attWin)
        showHeaderNode(defenderItem, iPos.defense, defWin)

        -- 显示下注或查看按钮
        local buttonImg = (v.AttackerWin == nil) and "c_162.png" or "c_79.png"
        local buttonNode = ui.newButton({
            normalImage = buttonImg,
            position = iPos.extra,
            clickAction = function ()
                self:battleExtraButtonAction(attackerItem, defenderItem, (v.AttackerWin == nil))
            end,
        })
        if (v.AttackerWin == nil) then
            buttonNode:setEnabled((not self.alreadyGuessed))
        end
        parent:addChild(buttonNode)
    end
end


----------------------------------------------------------------------------------------------------
-- 部分辅助接口

-- 重新加载数据
function PvpTopHomeLayer:reloadData(newTurn)
    -- 删除之前的倒计时
    if self.timeLabel ~= nil then
        self.timeLabel:removeFromParent()
        self.timeLabel = nil
    end

    -- 重新请求数据
    local tmpGroup, tmpTurn = self.curGroup, (newTurn or self.curTurn)
    self.curGroup, self.curTurn = 0, 0
    self:requestGetReport(tmpGroup, tmpTurn)
end

-- 解析数据
function PvpTopHomeLayer:analyzeData()
    --（合并相同数据，胜负记录都放到 WinReports 里面， AttackerWin 表示最终结果）
    local tmpData, showData = {}, {}
    for _,v in ipairs(self.reportData) do
        if (tmpData[v.AttackerId] == nil) then
            tmpData[v.AttackerId] = {
                AttackerFAP = v.AttackerFAP, AttackerFashionModelId = v.AttackerFashionModelId, AttackerHeadImageId = v.AttackerHeadImageId, AttackerId = v.AttackerId, AttackerName = v.AttackerName, AttackerZone = v.AttackerZone,
                DefenderFAP = v.DefenderFAP, DefenderFashionModelId = v.DefenderFashionModelId, DefenderHeadImageId = v.DefenderHeadImageId, DefenderId = v.DefenderId, DefenderName = v.DefenderName, DefenderZone = v.DefenderZone,
                WinReports = {}, AttackerWin = nil,
            }
        end
        if (v.IsWin ~= nil) then
            table.insert(tmpData[v.AttackerId].WinReports, v.IsWin)
        end
    end
    for _,v in pairs(tmpData) do
        local item = clone(v)
        local winNum, loseNum = 0, 0
        for _,winFlag in ipairs(v.WinReports) do
            if (winFlag == false) or (winFlag == 0) then
                loseNum = loseNum + 1
            else
                winNum = winNum + 1
            end
        end
        if (winNum ~= 0) or (loseNum ~= 0) then
            item.AttackerWin = (winNum > loseNum)
        end
        table.insert(showData, item)
    end
    return showData
end

-- 辅助函数：比赛处理按钮响应事件（查看或下注）
function PvpTopHomeLayer:battleExtraButtonAction(attackerItem, defenderItem, isGuess)
    if (isGuess == true) then
        -- 下注
        local upParams = {playerLeft = attackerItem, playerRight = defenderItem, currTurn = self.curTurn, callback = function (playerItem, byte)
                self:requestBet(byte, playerItem)
            end}
        LayerManager.addLayer({name="challenge.DlgGuessPopLayer", data=upParams, cleanUp=false})
    else
        -- 查看
        local tmpList = {}
        for _,v in ipairs(self.reportData) do
            if (v.AttackerId == attackerItem.PlayerId) and (v.DefenderId == defenderItem.PlayerId) then
                table.insert(tmpList, v)
            end
        end
        LayerManager.addLayer({name="challenge.DlgLookReportLayer", data=tmpList, cleanUp=false})
    end
end

----------------------------------------------------------------------------------------------------
-- 网络请求相关接口

-- 请求战报数据
function PvpTopHomeLayer:requestGetReport(nGroup, nTurn)
    if (self.curGroup == nGroup) and (self.curTurn == nTurn) then
        return
    end

    -- 获取战报信息
    HttpClient:request({
        moduleName = "PVPinterTop",
        methodName = "GetBattleReport",
        svrMethodData = {nGroup, nTurn},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            local data = response.Value
            self.infoData = clone(data)
            self.reportData = clone(data.BattleReport) or {}

            -- 是否已下注
            if (data.IsBet ~= nil) then
                self.alreadyGuessed = data.IsBet
            end
            
            -- 修改当前分组和轮次
            self.curGroup = nGroup
            self.curTurn = nTurn
            if (data.GroupNum) and (data.GroupNum > 0) then
                self.curGroup = data.GroupNum
            end
            if (data.TurnCount) and (data.TurnCount > 0) then
                self.curTurn = data.TurnCount
                if (nTurn == 0) then -- 参数传0返回当前所在的轮次
                    self.alreadyTurn = data.TurnCount
                end
                self.bottomBgSprite:selectItem(self.curTurn)
            end
            
            -- 自动切换到当前分组
            self.tabView:activeTabBtnByTag(self.curGroup)
            self:refreshTabLayer()
        end
    })
end

-- 请求下注
function PvpTopHomeLayer:requestBet(byte, playerId)
    HttpClient:request({
        moduleName = "PVPinterTop",
        methodName = "Bet",
        svrMethodData = {byte, playerId},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            self:reloadData()
        end
    })
end

return PvpTopHomeLayer
--[[
    文件名：SectTaskLayer.lua
    文件描述：门派任务界面及其功能
    创建人：lichunsheng
    创建时间：2018.08.25
]]


local SectTaskLayer = class("SectTaskLayer", function()
    return display.newLayer()
end)

--[[
]]
function SectTaskLayer:ctor()
    --self:requestUpdateTask()
    --主界面服务器数据传递
    self.mSectInfoData = params or {}
    --表数据
    self.mSectNpcData = clone(SectNpcModel.items) or {}
    --门派ID
    self.mSectId = SectObj:getPlayerSectInfo().SectId or 1
    --长老信息
    self.mTaskData = {}
    --任务表数据
     self.mOpenTaskData = clone(SectTaskWeightRelation.items) or {}
     --师傅卡片表
     self.mChainTable = {}
     --剧情展示的tag
     self.mTalkIndex = 1
     --主角图片
     self.mManSprite = nil
     --师傅图片
     self.mMasterSprite = nil
     --师徒奖励按钮
     self.mRewardBtnTable = {}
     self.mHasAcpRewardId = ""
    --创建层
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    --界面
    self:requestGetSectTaskInfo()
end

--界面初始化
function SectTaskLayer:initUI()
    --创建背景
    self.mBgSprite = ui.newSprite("bp_12.jpg")
    self.mBgSprite:setPosition(cc.p(320, 568))
    self.mParentLayer:addChild(self.mBgSprite)

    --创建人物卡片背景选项卡
    local btnInfo = {}
    --师傅表格数据排序
    local tempList = {}
    for index, item in pairs(self.mSectNpcData) do
        table.insert(tempList, item)
    end
    table.sort(tempList, function(items1, items2)
        return items1.npcNum < items2.npcNum
    end)

    for index, items in pairs(tempList) do
        if items.sectModelID == self.mSectId then
            table.insert(btnInfo, {
                tag = items.ID,
                titlePosRateY = 0.15,
                text = items.name or "",
                fontSize = 24,
                outlineSize = 2,
                customNormalTextcolor = Enums.Color.eWhite,
                customLightedTextcolor = cc.c3b(0xff, 0xdd, 0xae),
                curstomNormalOutlineColor = Enums.Color.eBlack,
                curstomLightedOutlineColor = cc.c3b(0xa3, 0x30, 0x2e),
            })
        end
    end

    --创建底层背景
    local underSize = cc.size(636, 500)
    local underBgSprite = ui.newScale9Sprite("mp_23.png", underSize)
    underBgSprite:setAnchorPoint(cc.p(0.5, 0))
    underBgSprite:setPosition(cc.p(320, 0))
    self.mParentLayer:addChild(underBgSprite, 100)

    --创建名字
    local titleSprite = ui.newSprite("mp_11.png")
    titleSprite:setPosition(cc.p(underSize.width / 2, underSize.height - 15))
    self.mParentLayer:addChild(titleSprite, 101)

    --创建底部说明Label
    local infoLabel = ui.newLabel({
        text = TR("{c_63.png}  接受了本门派任务后，当天不能接受其他门派的任务"),
        size = 20,
        color = cc.c3b(0x59, 0x28, 0x17),
        x = underSize.width / 2,
        y = underSize.height - 60,
        anchorPoint = cc.p(0.5, 0.5),
    })
    self.mParentLayer:addChild(infoLabel, 101)

    --创建底部背景层
    self.mUnderSprite = ui.newScale9Sprite("c_24.png", cc.size(550, 400))
    self.mUnderSprite:setAnchorPoint(cc.p(0.5, 0))
    self.mUnderSprite:setPosition(cc.p(320, 20))
    self.mParentLayer:addChild(self.mUnderSprite, 102)

    --创建师傅奖励按钮
    for key, value in pairs(btnInfo) do
        local rewardBtn = ui.newButton({
            normalImage = "mp_13.png",
            position = cc.p(60, 900),
            clickAction = function ()
                self:RewardUI()
            end
        })
        self.mParentLayer:addChild(rewardBtn)
        rewardBtn:setVisible(false)
        self.mRewardBtnTable[value.tag] = rewardBtn

    end

    --师徒奖励的小红点
    for i, info in ipairs(btnInfo) do
        local currentTag = info.tag
        local function dealRedDotVisible(redDotSprite)
            redDotSprite:setVisible(RedDotInfoObj:isValid(ModuleSub.eSectTarget, "Teacher"..currentTag))
        end
        ui.createAutoBubble({parent = self.mRewardBtnTable[currentTag],
            eventName = RedDotInfoObj:getEvents(ModuleSub.eSectTarget, "Teacher"..currentTag),
            refreshFunc = dealRedDotVisible})
    end

    --师傅选项label
    self.mTabLine =  ui.newTabLayer({
        normalImage = "mp_09.png",
        lightedImage = "mp_10.png",
        btnInfos = btnInfo,
        viewSize = cc.size(640, 204),
        space = 10,
        btnSize = cc.size(144, 204),
        needLine = false,
        allowChangeCallback = function(btnTag)
            return true
        end,
        onSelectChange = function(selectBtnTag)
            self.mMasterId = selectBtnTag or 101
            --刷新人物
            self:refreshMaster(self.mMasterId)
            self.mSectMan:setGray(true)
            self:createIsOpenLayer()
            for k,v in pairs(self.mRewardBtnTable) do
                if k == self.mMasterId then
                    v:setVisible(true)
                else
                    v:setVisible(false)
                end
            end
        end,

    })
    self.mTabLine:setAnchorPoint(cc.p(0.5, 1))
    self.mTabLine:setPosition(cc.p(320, 1136))
    self.mParentLayer:addChild(self.mTabLine)

    -- 添加头像小红点
    for i, info in ipairs(btnInfo) do
        local currentTag = info.tag
        local function dealRedDotVisible(redDotSprite)
            redDotSprite:setVisible(RedDotInfoObj:isValid(ModuleSub.eSectTask, "Teacher" .. currentTag))
        end
        ui.createAutoBubble({parent = self.mTabLine:getTabBtnByTag(currentTag),
            eventName = RedDotInfoObj:getEvents(ModuleSub.eSectTask, "Teacher" .. currentTag),
            refreshFunc = dealRedDotVisible})
    end

    --创建师傅cardNode
    self:createTopTable()

    --创建返回按钮
    local backBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(590, 900),
        clickAction = function ()
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(backBtn)

    --优先跳转到有未完成人物的NPC界面（数据）
    local doingTaskTable = {}
    for index, items in pairs(self.mTaskData.TasksInfo) do
        table.insert(doingTaskTable, items)
    end

    table.sort(doingTaskTable, function(items1, items2)
        return items1.NpcId < items2.NpcId
    end)

    --根据任务情况来显示选项卡(优先显示有未完成任务的NPC， 不包括剧情任务)
    local isDoing = false--是否有进行中的任务
    for index, items in pairs(doingTaskTable) do
        if not items.IsDone then
            isDoing = true
            self.mMasterId = items.NpcId
            self:refreshLayer()
            break
        end
    end

    --假如没有进行中的任务则优先跳转到有可接受任务的界面(就是一顿捶)
    if not isDoing then
        local tab = {}
        for index, items in pairs(self.mTaskData.NpcInfo) do
            local ret = {}
            ret.masterId = tonumber(index)
            ret.npcData = items
            table.insert(tab, ret)
        end

        table.sort(tab, function(item1, item2)
            return item1.masterId < item2.masterId
        end)

        table.sort(self.mTaskData.WillReceiveTaskNpc, function(item1, item2)
            return item1 < item2
        end)

        for key, value in pairs(self.mTaskData.WillReceiveTaskNpc) do
            if math.floor(value / 100) == self.mSectId then
                self.mMasterId = value
                self:refreshLayer()
            end
            break
        end
   end
end


--刷新界面函数整合
function SectTaskLayer:refreshLayer()
    for index, items in pairs(self.mRewardBtnTable) do
        if index == self.mMasterId then
            items:setVisible(true)
        else
            items:setVisible(false)
        end
    end
    self.mTabLine:activeTabBtnByTag(self.mMasterId)
    self:refreshMaster(self.mMasterId)
    self:createIsOpenLayer()
end

--创建顶部的师傅按钮
--[[
    params:是不是第一次进来
]]
function SectTaskLayer:createTopTable()
    --获取所有切换按钮
    local btnTable = self.mTabLine:getTabBtns() or {}
    --创建任务卡片
    for index, items in pairs(btnTable) do
        local manId = index or 101
        local tempCard = CardNode.createCardNode({
            extraImgName = self.mSectNpcData[manId].minPic..".png",
            imgName = "c_09.png",
            cardShowAttrs = {CardShowAttr.eBorder}
        })
        tempCard:setPosition(cc.p(items:getContentSize().width / 2, items:getContentSize().height / 2))
        items:addChild(tempCard)
        tempCard:setSwallowTouches(false)
        tempCard:setTouchEnabled(false)

        --如果没有解锁放置锁链
        local chainSprite = ui.newSprite("bsxy_14.png")
        chainSprite:setPosition(cc.p(items:getContentSize().width / 2, items:getContentSize().height / 2))
        items:addChild(chainSprite)
        tempCard:setGray(true)
        self.mChainTable[index] = chainSprite

        --如果解锁  就不现实锁链
        --local haveChain = self.mTaskData.NpcInfo[tostring(manId)].LockStatus
        local hadLoacked = self.mTaskData.NpcInfo[tostring(manId)].LockStatus
        local haveJuqingTask = false
        for index, items in pairs(self.mTaskData.TasksInfo) do
            if items.NpcId == manId and items.IsStory then
               haveJuqingTask = true
            end
        end

        if hadLoacked or haveJuqingTask then
            self.mChainTable[index]:setVisible(false)
        end
    end
end


--更具开启和未开启，创建相应的界面
function SectTaskLayer:createIsOpenLayer()
    local hadLoacked = self.mTaskData.NpcInfo[tostring(self.mMasterId)].LockStatus
    local haveChain = false
    for index, items in pairs(self.mTaskData.TasksInfo) do
        if items.NpcId == self.mMasterId and items.IsStory then
           haveChain = true
        end
    end
    if hadLoacked or haveChain then
        self:refreshList(false)
    elseif not isOpen then--未解锁
        self:createOpenLayer()
    end
end

--没有解锁师门创建解锁界面
function SectTaskLayer:createOpenLayer()
    self.mUnderSprite:removeAllChildren(true)
    self.mListView = nil
    --声望是否达到
    local isLimit = self.mSectNpcData[self.mMasterId].needRankMin
    local rankName = SectRankModel.items[isLimit].name or ""
    --创建感叹号
    local mark = ui.newSprite("c_63.png")
    mark:setPosition(cc.p(130, 250))
    self.mUnderSprite:addChild(mark)
    --未解锁 则看是否能够解锁师门任务，并创建解锁时的人物场景
    local shengwangLabel = ui.newLabel({
        text = TR("解锁需要%s", rankName),
        size = 30,
        color = cc.c3b(0x52, 0x1a, 0x1a),
        x = 285,
        y = 250,
        anchorPoint = cc.p(0.5, 0.5),
    })
    self.mUnderSprite:addChild(shengwangLabel)

    --创建解锁按钮（声望是否达到解锁要求）
    local openBtn = ui.newButton({
        normalImage = "c_33.png",
        text = TR("解锁"),
        position = cc.p(275, 100),
        clickAction = function ()
            self.mTalkIndex = 1
            self:openPlotTask()
        end
    })
    self.mUnderSprite:addChild(openBtn)


    local canOpen = isLimit >= SectObj:getSectRank()
    if canOpen then
        shengwangLabel:setString(TR("完成解锁任务后，师傅每日会发布门派任务。"))
        shengwangLabel:setFontSize(24)
        openBtn.mTitleLabel:setString(TR("开始任务"))
        mark:setVisible(false)
    else
        openBtn:setEnabled(false)
    end
end

--刷新底部任务了列表
--[[
    isAct：控制接受任务不刷新
]]
function SectTaskLayer:refreshList(isAct)
    local hadLoacked = self.mTaskData.NpcInfo[tostring(self.mMasterId)].LockStatus
    local haveChain = false
    for index, items in pairs(self.mTaskData.TasksInfo) do
        if items.NpcId == self.mMasterId and items.IsStory then
           haveChain = true
        end
    end
    if hadLoacked or haveChain then
        self.mSectMan:setGray(false)
    end
    if not isAct then
        self:masterTalk(self.mMasterId)
    end

    self.mUnderSprite:removeAllChildren(true)
    self.mListView = nil
    --创建LISTVIEW
    if not self.mListView then
        self.mListView = ccui.ListView:create()
        self.mListView:setItemsMargin(5)
        self.mListView:setDirection(ccui.ScrollViewDir.vertical)
        self.mListView:setBounceEnabled(true)
        self.mListView:setContentSize(cc.size(550, 370))
        self.mListView:setAnchorPoint(cc.p(0.5, 0.5))
        self.mListView:setPosition(275, 200)
        self.mListView:setChildrenActionType(0)
        self.mUnderSprite:addChild(self.mListView)
    end

    --对任务数据根据任务类型排序(如果上次接受的任务没有完成则只会接受的任务仍然存在)
    local allTasksInfo = clone(self.mTaskData.NpcInfo[tostring(self.mMasterId)].NpcTasks) or {}
    dump(self.mTaskData.NpcInfo, "刷新数据：")

    for index, items in pairs(self.mTaskData.TasksInfo) do
        if items.NpcId == self.mMasterId  then
            table.insert(allTasksInfo, tonumber(index))
        end
    end

    local tab = {}
    for index, items in pairs(allTasksInfo) do
        tab[items] = index
    end


    local npcTasksInfo = {}
    for index, items in pairs(tab) do
        table.insert(npcTasksInfo, index)
    end

    --排序，始终让战斗任务在第一位

    table.sort(npcTasksInfo, function(items1, items2)
        return self.mOpenTaskData[items1].taskType < self.mOpenTaskData[items2].taskType
    end)

    if self.mListView then
        self.mListView:removeAllItems()
        for index, items in pairs(npcTasksInfo) do
            local cellData = self.mOpenTaskData[items] or {}
            local node = self:addItems(cellData, items)
            self.mListView:pushBackCustomItem(node)
        end
    end
end

--添加任务Node
--[[
    params说明：
        cellData：每一条任务数据
        taskId:任务Id
]]
function SectTaskLayer:addItems(cellData, taskId)
    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(550, 120))

    --创建items背景
    local itemsBg = ui.newScale9Sprite("c_155.png", cc.size(520, 120))
    itemsBg:setAnchorPoint(cc.p(0.5, 0))
    itemsBg:setPosition(cc.p(275, 0))
    layout:addChild(itemsBg)

    --创建卡牌
    local taskImage = self.mOpenTaskData[taskId].npcPic..".png" or ""
    local cardNode = CardNode.createCardNode({
        extraImgName = taskImage,
        imgName = "c_10.png",
        cardShowAttrs = {CardShowAttr.eBorder}
    })
    cardNode:setPosition(cc.p(60, 60))
    itemsBg:addChild(cardNode)

    --创建完成xxx的任务lvLabel
    local taskNameBg = ui.newScale9Sprite("bsxy_02.png", cc.size(170, 35))
    taskNameBg:setAnchorPoint(cc.p(0, 0.5))
    taskNameBg:setPosition(cc.p(115, 100))
    itemsBg:addChild(taskNameBg)

    local heroName = self.mSectNpcData[self.mMasterId].name
    local text = heroName.."-"..cellData.taskName

    local taskNameLabel = ui.newLabel({
        text = text or "",
        size = 20,
        color = cc.c3b(0x52, 0x1a, 0x1a),
        x = 5,
        y = taskNameBg:getContentSize().height / 2,
    })
    taskNameLabel:setAnchorPoint(cc.p(0, 0.5))
    taskNameBg:addChild(taskNameLabel)

    --创任务内容label
    --已完成的进度
    local hadPro = 0
    if self.mTaskData.TasksInfo[tostring(taskId)] then
        hadPro = self.mTaskData.TasksInfo[tostring(taskId)].Progress
    end
    --完成任务需要的进度
    local needPro = 0
    --难度
    local star = 0
    local taskType = self.mOpenTaskData[taskId].taskType or 1
    --判断任务类型，取不同表中数据
    if taskType == 1 then
        needPro = SectTaskBattleModel.items[taskId].fightNum or 0
        star = SectTaskBattleModel.items[taskId].star or 0
    elseif taskType == 2 then
        needPro = SectTaskCollectionModel.items[taskId].needNum or 0
        star = SectTaskCollectionModel.items[taskId].star or 0
    elseif taskType == 3 then
        needPro = 1
        star = SectTaskFindModel.items[taskId][1].star or 0
    end

    local TasksInfoLabel = ui.newLabel({
        --text = cellData.intro or "",
        text = TR("%s： %s", cellData.taskAims, hadPro.."/"..needPro),
        size = 18,
        color = cc.c3b(0xdd, 0x4a, 0x1c),
        x = 120,
        y = 43,
        anchorPoint = cc.p(0, 0.5),
    })
    itemsBg:addChild(TasksInfoLabel)


    --创建奖励获取label
    local rewardLabel = ui.newLabel({
        text = TR("#592817奖励：#249027%s#592817声望", self.mOpenTaskData[taskId].sectCoin or 0),
        size = 18,
        x = 120,
        y = 15,
        anchorPoint = cc.p(0, 0.5),
    })
    itemsBg:addChild(rewardLabel)

    --创建星星
    local starNode = ui.newStarLevel(star, "c_75.png", nil, nil, "c_75.png")
    starNode:setAnchorPoint(cc.p(0, 0.5))
    starNode:setPosition(cc.p(120, 70))
    itemsBg:addChild(starNode)
    starNode:setScale(0.7)
    --刷新任务所需消耗
    local refreshConfig = clone(SectConfig.items)
    local refreshRes = Utility.analysisStrResList(refreshConfig[1].refreshNeed or {})

    --添加刷新按钮
    local refreshBtn = ui.newButton({
        normalImage = "c_33.png",
        text = TR("刷新"),
        position = cc.p(450, 90),
        clickAction = function ()
            --刷新任务
            if Utility.isResourceEnough(ResourcetypeSub.eDiamond, refreshRes[1].num or 0) then
                for index, items in pairs(self.mTaskData.TasksInfo) do
                    if tonumber(index) == taskId then
                        local msgBox = MsgBoxLayer.addOKLayer(
                            TR("刷新将会自动放弃当前任务，是否继续？"),
                            TR("提示"),
                            {{
                                text = TR("确定"),
                                position = cc.p(150, 60),
                                clickAction = function(layerObj)
                                    self:requestReceiveTask(taskId, 1)
                                    LayerManager.removeLayer(layerObj)
                                end
                            }},
                            {
                                text = TR("取消"),
                                normalImage = "c_28.png",
                                position = cc.p(420, 60),
                                clickAction = function (layerObj)
                                    LayerManager.removeLayer(layerObj)
                                end
                            }
                        )

                        return
                    end
                end
                --判断任务是否为5星任务
                if star >= 5 then
                    local msgBox = MsgBoxLayer.addOKLayer(
                        TR("当前任务为高等级任务，是否确认刷新？"),
                        TR("提示"),
                        {{
                            text = TR("确定"),
                            position = cc.p(150, 60),
                            clickAction = function(layerObj)
                                self:requestRefreshTask(taskId)
                                LayerManager.removeLayer(layerObj)
                            end
                        }},
                        {
                            text = TR("取消"),
                            normalImage = "c_28.png",
                            position = cc.p(420, 60),
                            clickAction = function (layerObj)
                                LayerManager.removeLayer(layerObj)
                            end
                        }
                    )
                else
                    self:requestRefreshTask(taskId)
                end
            end
        end
    })
    itemsBg:addChild(refreshBtn)
    refreshBtn:setScale(0.8)
    refreshBtn.mTitleLabel:setPosition(cc.p(30, 0))


    local isChangeSect = SectObj:isChangeSect()
    if isChangeSect then
        refreshBtn:setVisible(false)
    end

    for insex, items in pairs(self.mTaskData.TasksInfo) do
        if next(items) and tonumber(insex) == taskId and items.IsDone then
            refreshBtn:setVisible(false)
       end
    end

    --创建刷新消耗
    local costImage = Utility.getDaibiImage(refreshRes[1].resourceTypeSub, refreshRes[1].modelId)
    local costLable = ui.newLabel({
        text = TR("{%s}%s", costImage, refreshRes[1].num or 20),
        size = 20,
        color = Enums.Color.eBlack,
        x = 2,
        y = 25,
        anchorPoint = cc.p(0, 0.5),
    })
    refreshBtn:addChild(costLable)



    --创建接受按钮
    local acceptBtn = ui.newButton({
        text = TR("接受"),
        normalImage = "c_28.png",
        position = cc.p(450, 30),
        clickAction = function ()
            MqAudio.playEffect("jieshourenwu.mp3", false)
            self:requestReceiveTask(taskId, 0)
        end
    })
    itemsBg:addChild(acceptBtn)
    acceptBtn:setScale(0.8)

    --判断任务是否已经接受
    for index, items in pairs(self.mTaskData.TasksInfo or {}) do
        if tonumber(index) == taskId then
            acceptBtn.mTitleLabel:setString(TR("前 往"))
             acceptBtn:loadTextures("c_95.png", "c_95.png")
            acceptBtn.mClickAction = function()
                LayerManager.addLayer({
                    name = "sect.SectBigMapLayer",
                    data = {
                        searchingId = taskId
                    }
                })
            end
            break
        end
    end

    --判断该任务是否完成
    for insex, items in pairs(self.mTaskData.TasksInfo) do
        if next(items) and tonumber(insex) == taskId and items.IsDone then
           acceptBtn:setEnabled(false)
           acceptBtn:setVisible(false)
           local hasDone = ui.newSprite("c_156.png")
           hasDone:setPosition(cc.p(450, 50))
           itemsBg:addChild(hasDone)

           local hasDoneLabel = ui.newLabel({
               text = TR("已完成"),
               size = 20,
               color = Enums.Color.eWhite,
               outlineColor = Enums.Color.eBlack,
               outlineSize = 1,
               x = ui.getImageSize("c_156.png").width / 2,
               y = ui.getImageSize("c_156.png").height / 2,
               anchorPoint = cc.p(0.5, 0.5),
           })
           hasDone:addChild(hasDoneLabel)
       end
    end

    --判断任务是否已经达成
    return layout
end

--刷新人物函数
function SectTaskLayer:refreshMaster(index)
    if not tolua.isnull(self.mSectMan) then
        self.mSectMan:removeFromParent(true)
        self.mSectMan = nil
    end
    self.mSectMan = ui.newSprite(self.mSectNpcData[index].pic..".png")
    self.mSectMan:setPosition(cc.p(320, 568))
    self.mBgSprite:addChild(self.mSectMan)
    --self.mSectMan:setGray(true)
end

--师傅奖励界面展示
function SectTaskLayer:RewardUI()
    --SectTargetModel.items[1010050].taskNum

    -- 规则窗体的 DIY 函数
    local function DIYFuncion(layer, layerBgSprite, layerSize)
        -- 黑色背景框
        self.mTargetListSize = layerSize
        local blackSize = cc.size(layerSize.width * 0.9, (layerSize.height - 100))
        local blackBg = ui.newScale9Sprite("c_17.png", blackSize)
        blackBg:setAnchorPoint(0.5, 0)
        blackBg:setPosition(layerSize.width / 2, 30)
        layerBgSprite:addChild(blackBg)

        -- 滑动控件
        local listSize = cc.size(layerSize.width * 0.9, (layerSize.height - 130))
        if  tolua.isnull(self.mTargertlistView) then
            self.mTargertlistView = ccui.ListView:create()
            self.mTargertlistView:setContentSize(listSize)
            self.mTargertlistView:setItemsMargin(5)
            self.mTargertlistView:setDirection(ccui.ListViewDirection.vertical)
            self.mTargertlistView:setBounceEnabled(true)
            self.mTargertlistView:setAnchorPoint(cc.p(0.5, 0.5))
            self.mTargertlistView:setPosition(layerSize.width / 2, layerSize.height * 0.46)
            layerBgSprite:addChild(self.mTargertlistView)
        end


        local targetData = clone(SectTargetModel.items) or {}


        local curNpcTaskData = {}
        for index, items in pairs(targetData) do
            if items.npcID == self.mMasterId then
                table.insert(curNpcTaskData, items)
            end
        end

        table.sort(curNpcTaskData, function(items1, items2)
            return  items1.taskNum < items2.taskNum
        end)

        self:refreshTargetList(curNpcTaskData)

    end

    local tempData = {
        bgSize = cc.size(630, 550),
        title = TR("师徒奖励"),
        closeBtnInfo = {},
        btnInfos = {},
        DIYUiCallback = DIYFuncion,
        notNeedBlack = true,
    }

    return LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        data = tempData,
        cleanUp = false,
    })
end

--刷新listVaiew
function SectTaskLayer:refreshTargetList(data)
    if not tolua.isnull(self.mTargertlistView) then
        self.mTargertlistView:removeAllItems()
    end
    for index, items in pairs(data) do
        local  hasCompleteCount = self.mTaskData.NpcInfo[tostring(items.npcID)].TaskFinishNum
        local layout = self:addShituItems(items, hasCompleteCount)
        self.mTargertlistView:pushBackCustomItem(layout)
    end
end


--添加师徒奖励的items信息
--[[
    params说明：
        cellData：每一个layout需要的数据
        hasCompleteCount：已完成的次数
]]
function SectTaskLayer:addShituItems(cellData, hasCompleteCount)
    --创建layout
    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(self.mTargetListSize.width * 0.9, 100))

    --创建layout背景
    local itemsBg = ui.newScale9Sprite("c_18.png", cc.size(self.mTargetListSize.width * 0.85, 100))
    itemsBg:setAnchorPoint(cc.p(0, 0.5))
    itemsBg:setPosition(20, 50)
    layout:addChild(itemsBg)

    --创建完成xxx的任务lvLabel（完成次数TODO）
    local manTaskLabel = ui.newLabel({
        text = TR("#d17b00完成%s处任务：%s/%s", self.mSectNpcData[cellData.npcID].name or "", hasCompleteCount, cellData.taskNum or 0),
        size = 22,
        color = cc.c3b(0x52, 0x1a, 0x1a),
        x = 20,
        y = itemsBg:getContentSize().height - 15,
        anchorPoint = cc.p(0, 0.5),
    })
    itemsBg:addChild(manTaskLabel)

    --创建奖励获取label
    local rewardLabel2 = ui.newLabel({
        text = TR("#592817声望#249027 +%s", cellData.rewardCoinNum),
        size = 22,
        x = 20,
        y = itemsBg:getContentSize().height - 50,
        anchorPoint = cc.p(0, 0.5),
    })
    itemsBg:addChild(rewardLabel2)

    --是否达成
    local isReach = hasCompleteCount >= cellData.taskNum and true or false
    --创建未完成标示（假如未达成）
    if not isReach then
        local isCompleteSprite = ui.newSprite("mp_08.png")
        isCompleteSprite:setPosition(cc.p(itemsBg:getContentSize().width - 60, itemsBg:getContentSize().height / 2))
        itemsBg:addChild(isCompleteSprite)
    else
        local reachBtn = ui.newButton({
            text = TR("领 取"),
            normalImage = "c_28.png",
            clickAction = function ()
                print("领取成就奖励")
                self:requestDrawSectTarget(cellData)
            end
        })
        reachBtn:setPosition(cc.p(itemsBg:getContentSize().width - 80, itemsBg:getContentSize().height / 2))
        itemsBg:addChild(reachBtn)
        if self.mHasAcpRewardId ~= "" then
            local function analyRewardList(attrListStr)
                local ret = {}
                if type(attrListStr) == "string" then
                    local itemList = string.split(attrListStr, ",")
                    for index, item in pairs(itemList) do
                            table.insert(ret, item)
                    end
                end
                return ret
            end

            local idList = analyRewardList(self.mHasAcpRewardId)
            for k, v in pairs(idList) do
                if tonumber(v) == cellData.ID then
                    reachBtn:setVisible(false)
                    local hasDone = ui.newSprite("c_156.png")
                    hasDone:setPosition(cc.p(450, 50))
                    itemsBg:addChild(hasDone)
                    local hasDoneLabel = ui.newLabel({
                        text = TR("已领取"),
                        size = 20,
                        color = Enums.Color.eWhite,
                        outlineColor = Enums.Color.eBlack,
                        outlineSize = 1,
                        x = ui.getImageSize("c_156.png").width / 2,
                        y = ui.getImageSize("c_156.png").height / 2,
                        anchorPoint = cc.p(0.5, 0.5),
                    })
                    hasDone:setPosition(cc.p(itemsBg:getContentSize().width - 80, itemsBg:getContentSize().height / 2))
                    hasDone:addChild(hasDoneLabel)
                end
            end
        end
        for key, value in pairs(self.mTaskData.NpcInfo[tostring(self.mMasterId)].RewardBoxIds) do
            if value == cellData.ID then
                reachBtn:setVisible(false)
                local hasDone = ui.newSprite("c_156.png")
                hasDone:setPosition(cc.p(450, 50))
                itemsBg:addChild(hasDone)
                local hasDoneLabel = ui.newLabel({
                    text = TR("已领取"),
                    size = 20,
                    color = Enums.Color.eWhite,
                    outlineColor = Enums.Color.eBlack,
                    outlineSize = 1,
                    x = ui.getImageSize("c_156.png").width / 2,
                    y = ui.getImageSize("c_156.png").height / 2,
                    anchorPoint = cc.p(0.5, 0.5),
                })
                hasDone:setPosition(cc.p(itemsBg:getContentSize().width - 80, itemsBg:getContentSize().height / 2))
                hasDone:addChild(hasDoneLabel)
            end
        end

    end



    return layout
end

--开启师傅时，出现的剧情
function SectTaskLayer:openPlotTask()
    self.mTaskInfo = {}
    --剧情表格数据
    for index, items in pairs(SectNpcUnlockModel.items[self.mMasterId] or {}) do
        self.mTaskInfo[index] = items
    end
    self.mTalkLayer = self:createDialogLayer(true)
     self.mTalkLayer:setContentSize(cc.size(640, 1136))
     self.mTalkLayer:setPosition(display.cx, display.cy)
     self.mTalkLayer:setIgnoreAnchorPointForPosition(false)
     self.mTalkLayer:setAnchorPoint(cc.p(0.5, 0.5))
     self.mTalkLayer:setScale(Adapter.MinScale)
    self:addChild(self.mTalkLayer, 103)
end

--根据对话数据创建人物模型
 function SectTaskLayer:createDialogLayer(noMusic)
     local bgLayer = display.newLayer(cc.c4b(0, 0, 0, 150))

     --屏蔽剧情的下层点击事件
     ui.registerSwallowTouch({node = bgLayer})

     -- 对话框底图大小
     local bgFrameSize = cc.size(640, 300)
     self.mBaseLayout = ccui.Layout:create()
     self.mBaseLayout:setContentSize(bgFrameSize)
     self.mBaseLayout:setAnchorPoint(cc.p(0.5, 0))
     self.mBaseLayout:setPosition(cc.p(320, 0))
     bgLayer:addChild(self.mBaseLayout)
     self.mBaseLayout:setTouchEnabled(true)


     --把节点绑定点击事件
     self.mBaseLayout:addTouchEventListener(function(pSender, eventType)
         if eventType == ccui.TouchEventType.ended then
             self.mTalkIndex = self.mTalkIndex + 1
             self:changeTalkInfo()
         end
     end)

     -- 对话人物模型ID
     local heroModelId = FormationObj:getSlotInfoBySlotId(1).ModelId
     local heroModelSprite = nil
     local fashionId = PlayerAttrObj:getPlayerAttrByName("FashionModelId")
     if fashionId ~= 0 then
        heroModelSprite = FashionModel.items[fashionId].staticPic..".png" or ""
     else
        heroModelSprite = Utility.getHeroStaticPic(heroModelId) or ""
     end

     self.mManSprite = ui.newSprite(heroModelSprite)
     self.mManSprite:setAnchorPoint(cc.p(0.5, 0))
     self.mManSprite:setPosition(cc.p(-200, 100))
     self.mBaseLayout:addChild(self.mManSprite)
     self.mManSprite:setScale(0.5)
     self.mManSprite:setColor(cc.c3b(50, 50, 50))

     --对话师傅模型
     local leftOrRight = self.mTaskInfo[self.mTalkIndex].leftOrRight
     local masterSprite = nil
     if leftOrRight == 1 then
         masterSprite = self.mTaskInfo[self.mTalkIndex + 1] and self.mTaskInfo[self.mTalkIndex + 1].staticPic ~= "" and self.mTaskInfo[self.mTalkIndex + 1].staticPic..".png" or nil
     else
         masterSprite = self.mTaskInfo[self.mTalkIndex] and self.mTaskInfo[self.mTalkIndex].staticPic ~= "" and self.mTaskInfo[self.mTalkIndex ].staticPic..".png" or nil
     end
     if masterSprite then
         self.mMasterSprite = ui.newSprite(masterSprite)
         self.mMasterSprite:setAnchorPoint(cc.p(0.5, 0))
         self.mMasterSprite:setPosition(cc.p(750, 100))
         self.mBaseLayout:addChild(self.mMasterSprite)
         self.mMasterSprite:setScale(0.5)
         self.mMasterSprite:setColor(cc.c3b(50, 50, 50))
         self.mMasterSprite:setRotationSkewY(180)
     end

     -- 对话框底图
     local bgFrame = ui.newScale9Sprite("xsyd_06.png", cc.size(640, 300))
     bgFrame:setPosition(bgFrameSize.width / 2, bgFrameSize.height / 2)
     self.mBaseLayout:addChild(bgFrame)

     -- 小三角
     local sprite = ui.newSprite("c_43.png")
     sprite:setPosition(bgFrameSize.width / 2, 20)
     self.mBaseLayout:addChild(sprite)

     -- 对话内容
     self.mDialogLabel = ui.newLabel{
         text       = TR(""),
         font       = _FONT_PANGWA,
         size       = 24,
         color      = Enums.Color.eWhite,
         align      = cc.TEXT_ALIGNMENT_LEFT,
         valign     = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
         dimensions = cc.size(bgFrameSize.width - 40, bgFrameSize.height - 20),
     }
     self.mDialogLabel:align(display.LEFT_TOP, 30, bgFrameSize.height - 120)
     self.mBaseLayout:addChild(self.mDialogLabel)

     -- 角色名
     local manName = PlayerAttrObj:getPlayerAttrByName("PlayerName")
     self.mHeroNameLabel = ui.newLabel{
         text  = manName,
         color = cc.c3b(0xff, 0xdd, 0xae),
         size  = 24,
     }
     self.mHeroNameLabel:setAnchorPoint(cc.p(0, 0.5))
     self.mHeroNameLabel:align(display.CENTER, 150, 220)
     self.mBaseLayout:addChild(self.mHeroNameLabel)

     --师傅的名字
     local heroName = self.mSectNpcData[self.mMasterId].name
     self.mMasterNameLabel = ui.newLabel{
         text  = heroName,
         color = cc.c3b(0xff, 0xdd, 0xae),
         size  = 24,
     }
     self.mMasterNameLabel:setAnchorPoint(cc.p(1, 0.5))
     self.mMasterNameLabel:align(display.CENTER, 500, 220)
     self.mBaseLayout:addChild(self.mMasterNameLabel)


     self:changeTalkInfo()

     return bgLayer
 end


 --变换对话框的内容
 --[[
    params说明：
        leftOrRight：谁先说话（1自己，0师傅）
 ]]
 function SectTaskLayer:changeTalkInfo()

         if self.mTalkIndex > table.nums(self.mTaskInfo) then
             self.mBaseLayout:setEnabled(false)
             self.mTalkLayer:runAction(cc.Sequence:create(
                                            cc.CallFunc:create(function()
                                                if not tolua.isnull(self.mManSprite) then
                                                    self.mManSprite:runAction(cc.MoveTo:create(0.3, cc.p(-200, 100)))
                                                end
                                            end),
                                            cc.CallFunc:create(function()
                                                if not tolua.isnull(self.mMasterSprite) then
                                                    self.mMasterSprite:runAction(cc.MoveTo:create(0.3, cc.p(700, 100)))
                                                end
                                            end),
                                            cc.DelayTime:create(0.5),
                                            cc.CallFunc:create(function()
                                                self.mTalkLayer:removeFromParent(true)
                                                self.mTalkLayer = nil
                                            end)
                                      ))
             --发送解锁消息并刷新ListView
             self:requestUnLockSect(self.mMasterId)
             return
         end
     --计算位置
     --判断是那个npc先说话（1自己，0师傅）
     local director = self.mTaskInfo[self.mTalkIndex].leftOrRight

     if director == 1 then
         if self.mManSprite then
             self.mManSprite:runAction(cc.Spawn:create(
                                        cc.MoveTo:create(0.5, cc.p(100, 100)),
                                          cc.ScaleTo:create(0.5, 0.6),
                                          cc.CallFunc:create(function()
                                              self:changeManSpriteAction(self.mManSprite, self.mMasterSprite)
                                          end)))
         end

     else
         if self.mMasterSprite then
             local masterSprite = nil
             local heroName = nil
             if director == 1 then
                 masterSprite = self.mTaskInfo[self.mTalkIndex + 1] and self.mTaskInfo[self.mTalkIndex + 1].staticPic ~= "" and self.mTaskInfo[self.mTalkIndex + 1].staticPic..".png" or nil
                 heroName = self.mTaskInfo[self.mTalkIndex + 1] and self.mTaskInfo[self.mTalkIndex + 1].name ~= "" and self.mTaskInfo[self.mTalkIndex + 1].name or nil
             else
                 masterSprite = self.mTaskInfo[self.mTalkIndex] and self.mTaskInfo[self.mTalkIndex].staticPic ~= "" and self.mTaskInfo[self.mTalkIndex ].staticPic..".png" or nil
                 heroName = self.mTaskInfo[self.mTalkIndex + 1] and self.mTaskInfo[self.mTalkIndex].name ~= "" and self.mTaskInfo[self.mTalkIndex].name or nil
             end
             self.mMasterSprite:setTexture(masterSprite)
             self.mMasterNameLabel:setString(heroName)

             self.mMasterSprite:runAction(cc.Spawn:create(
                                                cc.MoveTo:create(0.5, cc.p(550, 100)),
                                                cc.ScaleTo:create(0.5, 0.6),
                                                cc.CallFunc:create(function()
                                                    self:changeManSpriteAction(self.mMasterSprite, self.mManSprite)
                                           end)))
         end
     end
     --对话内容
     self.mDialogLabel:setString(self.mTaskInfo[self.mTalkIndex].npcSpeak)
    --  if not noMusic then
    --      -- 播放音效
    --  end
 end

 --切换人物图片的动作
 function SectTaskLayer:changeManSpriteAction(sprite1, sprite2)
     if not tolua.isnull(sprite1) then
         sprite1:setColor(cc.c3b(255, 255, 255))
     end

     if not tolua.isnull(sprite2) then
         sprite2:setColor(cc.c3b(50, 50, 50))
         sprite2:runAction(cc.ScaleTo:create(0.3, 0.5))
     end

 end

 --师傅阐话
 --[[
    params说明：
     masterId:师傅Id
 ]]
 function SectTaskLayer:masterTalk(masterId)
     --解析数据
    local function analysisStrList(attrListStr)
        local ret = {}
        if type(attrListStr) == "string" then
            local itemList = string.split(attrListStr, "||")
            for index, item in pairs(itemList) do
                table.insert(ret, item)
            end
        end
        return ret
    end

     --配置表对话数据
     local talkData = analysisStrList(self.mSectNpcData[masterId].npcSpeak)
     --说话的背景
     local bgSize = ui.getImageSize("mp_90.png")
     local talkBg = ui.newSprite("mp_90.png")
     talkBg:setPosition(cc.p(self.mSectMan:getContentSize().width - 200, self.mSectMan:getContentSize().height - 150))
     self.mSectMan:addChild(talkBg)

     --说话的内容
     local random = math.random(1, #talkData)
     local text = talkData[random] or ""

     local talkLabel = ui.newLabel({
         text = text,
         size = 20,
         color = Enums.Color.eWhite,
         x = bgSize.width / 2,
         y = bgSize.height / 2 + 10,
         anchorPoint = cc.p(0.5, 0.5),
         dimensions = cc.size(185, 85),
     })
     talkBg:addChild(talkLabel)

     talkBg:runAction(cc.Sequence:create(
                                         cc.DelayTime:create(4),
                                         cc.CallFunc:create(function()
                                             talkBg:removeFromParent(true)
                                         end)
                                        ))
 end

--播放接受任务时的音效
function SectTaskLayer:taskMusic(taskId)
    local taskType = self.mOpenTaskData[taskId].taskType or 1
    local musicName = ""
    if taskType == 1 then
        musicName = "chuangdang_hit02.mp3"
    elseif taskType == 2 then
        musicName = "caiji.mp3"
    elseif taskType == 3 then
        musicName = "jieshourenwu.mp3"
    end
    MqAudio.playEffect(musicName, false)
end

--=============网络相关=================
--获取八大门派人物信息
function SectTaskLayer:requestGetSectTaskInfo()
    HttpClient:request({
        moduleName = "SectTask",
        methodName = "GetSectTaskInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            dump(response.Value, "门派任务：")
            --NPC的数据
            self.mTaskData.NpcInfo =  response.Value.NpcInfo or {}
            --玩家已经接受的任务，（均为正在进行中）
            self.mTaskData.TasksInfo = response.Value.TasksInfo or {}
            --玩家可接受的任务，（均为未接受进行中）
            self.mTaskData.WillReceiveTaskNpc = response.Value.WillReceiveTaskNpc or {}
            self:initUI()
        end
    })
end

--解锁长老的信息
--[[
    id:长老id
]]
function SectTaskLayer:requestUnLockSect(id)
    SectObj:unLockTeacher(id, function (response)
        --NPC的数据
        self.mTaskData.NpcInfo =  response.Value.NpcInfo or {}
        --玩家已经接受的任务，（均为正在进行中）
        self.mTaskData.TasksInfo = response.Value.TasksInfo or {}
        --任务飘窗
        local taskId = 0
        for index, items in pairs(self.mTaskData.TasksInfo)do
            if items.NpcId == self.mMasterId then
                taskId = tonumber(index)
            end
        end
        MqAudio.playEffect("jieshourenwu.mp3", false)
        local text = TR("开始 %s-%s 任务", self.mSectNpcData[self.mMasterId].name or "", self.mOpenTaskData[taskId].taskName or "")
        --接受任务成功（飘窗）
        ui.showFlashView({
             image = "mp_45.png",
             text = text,
             scale9Size = cc.size(362, 340),
             alignType = ui.TEXT_VALIGN_CENTER,
             pos = cc.p(ui.getImageSize("mp_45.png").width / 2, 60)
         })

        self:refreshList(false)
        if self.mChainTable[self.mMasterId] then
            self.mChainTable[self.mMasterId]:setVisible(false)
        end
    end)
end

--刷新任务接口
--[[
    参数说明：
        Int32:长老Id
        Int32:原任务Id
]]
function SectTaskLayer:requestRefreshTask(taskId)
    HttpClient:request({
        moduleName = "SectTask",
        methodName = "RefreshTask",
        svrMethodData = {self.mMasterId, taskId},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            dump(response.Value, "刷新之后的数据：")
            self.mTaskData.NpcInfo = response.Value.NpcInfo or {}
            self:refreshList(true)
        end
    })

end

--[[
    参数说明：
        taskId:原任务Id
        type:接受或者放弃（0接受1放弃）
        masterId:师傅ID
]]
--接受任务接口
function SectTaskLayer:requestReceiveTask(taskId, type)
    SectObj:requestGetTask(taskId, type, function(response)
        dump(response, "接受或者放弃任务：")
        local text = TR("开始 %s-%s 任务", self.mSectNpcData[self.mMasterId].name or "", self.mOpenTaskData[taskId].taskName or "")
        --接受任务成功（飘窗）
        if type == 0 then
            ui.showFlashView({
                 image = "mp_45.png",
                 text = text,
                 scale9Size = cc.size(362, 340),
                 alignType = ui.TEXT_VALIGN_CENTER,
                 pos = cc.p(ui.getImageSize("mp_45.png").width / 2, 60)
             })
        end

        --刷新ListView
        --NPC的数据
        self.mTaskData.NpcInfo =  response.Value.NpcInfo or {}
        --玩家已经接受的任务，（均为正在进行中）
        self.mTaskData.TasksInfo = response.Value.TasksInfo or {}
        self:refreshList(true)
     end)
end

--更新任务进度
--[[
    参数说明：
        taskId:任务Id
        taskCount:任务次数
]]
function SectTaskLayer:requestUpdateTask(taskId, taskCount)
    HttpClient:request({
        moduleName = "SectInfo",
        methodName = "AddSectCoinTest",
        svrMethodData = {1, 100000},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
        end
    })
end

--任务完成接口
--[[
  params说明：
    taskId：任务ID
]]
function SectTaskLayer:requestTaskFinish(taskId)
    HttpClient:request({
        moduleName = "SectTask",
        methodName = "TaskFinish",
        svrMethodData = {taskId},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
        end
    })
end

--领取成就奖励
--[[
    TargetId：成就Id
]]
function SectTaskLayer:requestDrawSectTarget(TargetData)
    SectObj:requestDrawSectTarget(TargetData.ID, function(response)
        self.mHasAcpRewardId = response.Value.DrawSectTargetIds or {}

        local targetData = clone(SectTargetModel.items) or {}
        local curNpcTaskData = {}
        for index, items in pairs(targetData) do
            if items.npcID == self.mMasterId then
                table.insert(curNpcTaskData, items)
            end
        end

        table.sort(curNpcTaskData, function(items1, items2)
            return  items1.taskNum < items2.taskNum
        end)

        self:refreshTargetList(curNpcTaskData)
    end)
end

return SectTaskLayer

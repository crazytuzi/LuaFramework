--[[
    文件名：JianghuKillMyTeamLayer.lua
    描述：江湖杀我的队伍页面
    创建人：chenzhong
    创建时间：2018.9.20
--]]
local JianghuKillMyTeamLayer = class("JianghuKillMyTeamLayer", function(params)
    return display.newLayer()
end)

-- 一个队伍的最大人数
local teamNum = 6

-- 构造函数
--[[
    params:
        currentNodeId :当前节点ID
--]]
function JianghuKillMyTeamLayer:ctor(params)
    -- package.loaded["jianghuKill.JianghuKillMyTeamLayer"] = nil
    -- 当前节点Id
    self.mCurrentNodeId = params.currentNodeId or 1
    -- 创建队伍时 是否需要队长同意
    self.mIsAgreed = true
    -- 组队目的类型(1进攻， 2驻守/采集)
    self.mTeamType = 1
    -- 自己是否是队长
    self.mIsLeader = false
    -- 队伍信息
    self.mTeamInfo = {}

    -- 子页面控件的父对象
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
    -- 按钮相关控件
    self.mBottomLayer = ui.newStdLayer()
    self:addChild(self.mBottomLayer)
    -- checkBox控件Layer
    self.mCheckBoxLayer = ui.newStdLayer()
    self:addChild(self.mCheckBoxLayer)
    -- 中间队伍页面控件的父对象
    self.mMidTeamLayer = ui.newStdLayer()
    self:addChild(self.mMidTeamLayer)

    -- 初始化UI
    self:initUI()

    -- 有队员退出队伍
    Notification:registerAutoObserver(self.mParentLayer, function(node, data)
        -- 移除队员
        for i,v in ipairs(self.mTeamInfo) do
            if v.PlayerId == data.PlayerId then 
                table.remove(self.mTeamInfo, i)
            end 
        end
        self:refreshTeamList()
    end, EventsName.eQuitTeam)

    -- 有成员加入队伍（不需要队长同意自动加入队伍）
    Notification:registerAutoObserver(self.mParentLayer, function(node, data)
        -- 将信息加入到列表
        local isExist = false   -- 是否已在队伍中
        for _, heroInfo in pairs(self.mTeamInfo) do
            if heroInfo.PlayerId == data.PlayerId then
                isExist = true
                break
            end
        end
        if not isExist then
            table.insert(self.mTeamInfo, data)
        end
        self:refreshTeamList()
    end, EventsName.eAddTeam)

    -- 有成员加入队伍（创建队伍时队长需要同意之后的加入）
    Notification:registerAutoObserver(self.mParentLayer, function(node, data)
        -- 将信息加入到列表
        local isExist = false   -- 是否已在队伍中
        for _, heroInfo in pairs(self.mTeamInfo) do
            if heroInfo.PlayerId == data.PlayerId then
                isExist = true
                break
            end
        end
        if not isExist then
            table.insert(self.mTeamInfo, data)
        end
        self:refreshTeamList()
    end, EventsName.eAgreeAddTeam)

    -- 队长转让通知
    Notification:registerAutoObserver(self.mParentLayer, function(node, data)
        -- 重新获取队伍信息
        self:requestGetTeamInfo()
    end, EventsName.eReplaceLeader)

    -- 踢人通知
    Notification:registerAutoObserver(self.mParentLayer, function(node, data)
        -- 重新获取队伍信息
        self:requestGetTeamInfo()
    end, EventsName.eDeleteMember)

    -- 准备通知
    Notification:registerAutoObserver(self.mParentLayer, function(node, data)
        -- 如果是自己，在请求接口的时候已经刷新页面了 不需要重复刷新
        if data.PlayerId ~= PlayerAttrObj:getPlayerAttrByName("PlayerId") then
            for i,v in ipairs(self.mTeamInfo) do
                if v.PlayerId == data.PlayerId then 
                    v.IsPrepare = true
                    break
                end 
            end
            -- 加载队伍页面
            self:refreshMidTeamInfo()
        end
    end, EventsName.ePrepareTeam)

    -- 取消准备通知
    Notification:registerAutoObserver(self.mParentLayer, function(node, data)
        -- 如果是自己，在请求接口的时候已经刷新页面了 不需要重复刷新
        if data.PlayerId ~= PlayerAttrObj:getPlayerAttrByName("PlayerId") then
            for i,v in ipairs(self.mTeamInfo) do
                if v.PlayerId == data.PlayerId then 
                    v.IsPrepare = false
                    break
                end 
            end
            -- 加载队伍页面
            self:refreshMidTeamInfo()
        end 
    end, EventsName.eCancelPrepareTeam)

    -- 队长解散队伍
    Notification:registerAutoObserver(self.mParentLayer, function(node, data)
        self.mTeamInfo = {}
        self.mTeamType = 1
        self.mIsAgreed = true
        -- 添加没有在队伍中时的页面
        self:addNotInTeamUI()
        -- 添加选择box
        self:addCheckBoxUI()
    end, EventsName.eCancelTeam)

     --移动开始
    Notification:registerAutoObserver(self.mParentLayer, function(node, data)
        self.mIsMoving = true
    end, EventsName.eBeginMove)

    --移动结束
    Notification:registerAutoObserver(self.mParentLayer, function(node, data)
        self.mIsMoving = false
    end, EventsName.eArriveNode)
end

function JianghuKillMyTeamLayer:initUI()
    -- 灰色背景
    local graySprite = ui.newScale9Sprite("jhs_41.png", cc.size(560, 580))
    graySprite:setAnchorPoint(cc.p(0.5, 1))
    graySprite:setPosition(320, 910)
    self.mParentLayer:addChild(graySprite)

    -- 获取队伍信息
    self:requestGetTeamInfo()
end

-- 刷新中间队伍信息
function JianghuKillMyTeamLayer:refreshMidTeamInfo( )
    self.mMidTeamLayer:removeAllChildren()
     -- 加载下方按钮
    if self.mIsLeader then 
        self:addLeaderBtn()
    else 
        self:addMemberBtn()
    end 

    -- 添加提醒描述
    local teamLabel = ui.newLabel({text = TR("队长为镖师时，其他队员不消耗粮草，并且享受队长的加速增益"), size = 20, color = cc.c3b(0x46, 0x22, 0x0d), dimensions = cc.size(500, 0)})
    teamLabel:setAnchorPoint(0, 0.5)
    teamLabel:setPosition(60, 370)
    teamLabel:setVerticalSpace(10)
    self.mMidTeamLayer:addChild(teamLabel)

    -- 当前属性加成
    self.mCurAttrLabel = ui.newLabel({text = TR("当前攻击加成: +0%"), size = 20, color = cc.c3b(0x46, 0x22, 0x0d)})
    self.mCurAttrLabel:setAnchorPoint(0, 0.5)
    self.mCurAttrLabel:setPosition(60, 425)
    self.mMidTeamLayer:addChild(self.mCurAttrLabel)

    -- 添加人员信息
    self.mTeamListView = ccui.ListView:create()
    self.mTeamListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mTeamListView:setBounceEnabled(true)
    self.mTeamListView:setContentSize(cc.size(560, 450))
    self.mTeamListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mTeamListView:setAnchorPoint(cc.p(0.5, 1))
    self.mTeamListView:setPosition(320, 900)
    self.mMidTeamLayer:addChild(self.mTeamListView)

    -- 刷新队伍信息
    self:refreshTeamList()
end

-- 人员列表
function JianghuKillMyTeamLayer:refreshTeamList()
    if tolua.isnull(self.mTeamListView) then 
        return
    end 
    self.mTeamListView:removeAllItems()

    local function lineList(index)
        local layout = ccui.Layout:create()
        layout:setContentSize(560, 150)

        -- 两个hero
        for i=1, 2 do
            -- 获取当前hero的数据
            local oneHeroData = self.mTeamInfo[(index-1)*2 + i]
            -- 添加heroItem
            local oneHeroItem = self:addOneHeroItem(oneHeroData)
            oneHeroItem:setPosition(cc.p((i==1 and 140 or 420), 75))
            layout:addChild(oneHeroItem)
        end

        return layout
    end

    -- 一行有两个人
    local colNum = math.ceil(teamNum/2)
    for i = 1, colNum do
        self.mTeamListView:pushBackCustomItem(lineList(i))
    end

    -- 根据当前队伍人数刷新属性加成
    local attrDep = 5
    self.mCurAttrLabel:setString(TR("当前攻击加成: +%s%%", (#self.mTeamInfo-1)*attrDep))
end

-- 添加一个heroItem
function JianghuKillMyTeamLayer:addOneHeroItem(heroData)
    -- 说明是空的位置
    if not heroData then 
        local oneItemBg = ui.newButton({
            normalImage = "jhs_65.png",
            clickAction = function()
               print("点击邀请")
               self:invitePopLayer()
            end,
        })
        return oneItemBg
    end 

    local oneItemBg = ui.newSprite("jhs_61.png")
    local itemBgSize = oneItemBg:getContentSize()

    -- 显示人物头像
    local heroHead = Figure.newHero({
        heroModelID = heroData.HeadImageId,
        position = cc.p(70, 10),
        scale = 0.1
    })
    oneItemBg:addChild(heroHead)

    -- 显示战力
    local fapLabelWithBg = ui.createLabelWithBg({
        bgFilename = "jhs_63.png",
        labelStr = Utility.numberWithUnit(heroData.Fap),
        fontSize = 20,
        -- color = cc.c3b(0xff, 0xe3, 0x80),
        outlineColor = cc.c3b(0x00, 0x00, 0x00),
        offset = 45,
    })
    fapLabelWithBg:setPosition(210, 30)
    oneItemBg:addChild(fapLabelWithBg)

    -- 显示名字
    local nameLabel = ui.newLabel({text = heroData.PlayerName, size = 20, color = cc.c3b(0xFF, 0x66, 0xF3), outlineColor = cc.c3b(0x00, 0x00, 0x00),})
    nameLabel:setPosition(190, 70)
    oneItemBg:addChild(nameLabel)

    -- 显示职业图标
    local jobSprite = ui.newSprite(Utility.getJHKJobPic(heroData.Profession))
    jobSprite:setScale(0.8)
    jobSprite:setPosition(160, 115)
    oneItemBg:addChild(jobSprite)

    -- 判断是否是队长（队长会有一个队长的队伍标志）
    if heroData.IsLeader then 
        local leaderSprite = ui.newSprite("jhs_62.png")
        leaderSprite:setPosition(230, 115)
        oneItemBg:addChild(leaderSprite)
    end 

    --透明按钮
    local pureBtn = ui.newButton({
        normalImage = "c_83.png",
        size = cc.size(itemBgSize.width, itemBgSize.height),
        clickAction = function()
            -- 如果自己是队长，而且当前这个hero不是队长，需要展示是否转正队长弹窗
            if self.mIsLeader and not heroData.IsLeader then 
                self:tranLeaderAndKickOutMsg(oneItemBg, heroData)
            else
                if not tolua.isnull(self.mKickPopMsg) then 
                    self.mKickPopMsg:removeFromParent()
                    self.mKickPopMsg = nil
                end 
            end 
        end
    })
    pureBtn:setSwallowTouches(false)
    pureBtn:setPosition(itemBgSize.width/2, itemBgSize.height/2)
    oneItemBg:addChild(pureBtn)

    -- 是否已经准备(队长不用显示)
    if heroData.IsPrepare and not heroData.IsLeader then 
        -- 添加准备好标志
        local readySprite = ui.newSprite("zdfb_16.png")
        readySprite:setPosition(70, 75)
        oneItemBg:addChild(readySprite)
    end 

    return oneItemBg
end

-- 添加发布邀请、解散队伍、退出队伍按钮(队长界面需要)
function JianghuKillMyTeamLayer:addLeaderBtn()
    local btnInfos = {
        {   -- 发布邀请
            normalImage = "c_28.png",
            text = TR("发布邀请"),
            position = cc.p(200, 170),
            clickAction = function()
               self:invitePopLayer()
            end
        },
        {   -- 解散队伍
            normalImage = "c_28.png",
            text = TR("解散队伍"),
            position = cc.p(440, 170),
            clickAction = function()
                self:requestCancelTeam()
            end
        },
    }

    for index, btnInfo in ipairs(btnInfos) do
        local tempBtn = ui.newButton(btnInfo)
        self.mBottomLayer:addChild(tempBtn)
    end
end

-- 添加准备按钮、退出队伍按钮(成员界面需要)
function JianghuKillMyTeamLayer:addMemberBtn()
    -- 判断是准备按钮还是取消准备
    local isPrepare = false
    for i,v in ipairs(self.mTeamInfo) do
        if v.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then 
            isPrepare = v.IsPrepare
            break
        end 
    end
    local btnInfos = {
        {   -- 发布邀请
            normalImage = "c_28.png",
            text = isPrepare and TR("取消准备") or TR("准 备"),
            position = cc.p(200, 170),
            clickAction = function()
                if isPrepare then 
                    self:requestCancelReady()
                else 
                    self:requestReady()
                end 
            end
        },
        {   -- 退出队伍
            normalImage = "c_28.png",
            text = TR("退出队伍"),
            position = cc.p(440, 170),
            clickAction = function()
                self:requestQuitTeam()
            end
        }
    }

    for index, btnInfo in ipairs(btnInfos) do
        local tempBtn = ui.newButton(btnInfo)
        self.mBottomLayer:addChild(tempBtn)
    end
end

-- 添加勾选相关的UI
function JianghuKillMyTeamLayer:addCheckBoxUI()
    self.mCheckBoxLayer:removeAllChildren()
    -- 放队伍目标的checkBox
    self.mTargetBoxList = {}

    -- 一个描述文字
    local introLabel = ui.newLabel({text = TR("队伍目标:"), size = 20, color = cc.c3b(0x46, 0x22, 0x0d)})
    introLabel:setPosition(100, 290)
    self.mCheckBoxLayer:addChild(introLabel)
    local checkBoxInfos = {
        {   -- 进攻
            normalImage = "c_60.png",
            selectImage = "c_61.png",
            text = TR("进攻"),
            fontSize = 18,
            isRevert = false,
            selectType = 1,  -- 用于区分是否为队伍目标
            textColor = cc.c3b(0x46, 0x22, 0x0d),
            btnPos = cc.p(200, 290),
            callback = function (isSelect)
                if isSelect then 
                    self.mTeamType = 1 
                else 
                    self.mTeamType = 2 
                end 
                for i,v in ipairs(self.mTargetBoxList) do
                    v:setCheckState(self.mTeamType == v.selectType)
                end
            end
        },
        {   -- 驻守/采集
            normalImage = "c_60.png",
            selectImage = "c_61.png",
            text = TR("驻守/采集"),
            fontSize = 18,
            isRevert = false,
            selectType = 2, -- 用于区分是否为队伍目标
            textColor = cc.c3b(0x46, 0x22, 0x0d),
            btnPos = cc.p(340, 290),
            callback = function (isSelect)
                if isSelect then 
                    self.mTeamType = 2 
                else 
                    self.mTeamType = 1 
                end 
                for i,v in ipairs(self.mTargetBoxList) do
                    v:setCheckState(self.mTeamType == v.selectType)
                end
            end
        },
        {   -- 发布邀请
            normalImage = "c_60.png",
            selectImage = "c_61.png",
            text = TR("申请入队免通知"),
            fontSize = 18,
            isRevert = false,
            textColor = cc.c3b(0x46, 0x22, 0x0d),
            btnPos = cc.p(140, 240),
            callback = function (isSelect)
                self.mIsAgreed = isSelect
            end
        },
    }
    for index, checkBoxInfo in ipairs(checkBoxInfos) do
        local checkBox = ui.newCheckbox(checkBoxInfo)
        checkBox:setPosition(checkBoxInfo.btnPos)
        self.mCheckBoxLayer:addChild(checkBox)

        -- 说明是队伍目标的选择框
        if checkBoxInfo.selectType and checkBoxInfo.selectType > 0 then 
            table.insert(self.mTargetBoxList, checkBox)
            checkBox:setCheckState(self.mTeamType == checkBoxInfo.selectType)
            checkBox.selectType = checkBoxInfo.selectType
        else 
            checkBox:setCheckState(self.mIsAgreed)
        end 

        -- 如果此时有队伍信息（不能更改）
        if next(self.mTeamInfo) ~= nil then 
            local checkSize = checkBox:getContentSize()
            --透明按钮
            local pureBtn = ui.newButton({
                normalImage = "c_83.png",
                size = cc.size(checkSize.width, checkSize.height),
                clickAction = function()
                    ui.showFlashView(TR(TR("只有创建队伍的时候才能更改！")))
                end
            })
            pureBtn:setPosition(checkSize.width/2, checkSize.height/2)
            checkBox:addChild(pureBtn)
        end 
    end
end

-- 添加没有在队伍中时的页面
function JianghuKillMyTeamLayer:addNotInTeamUI()
    self.mMidTeamLayer:removeAllChildren()
    self.mBottomLayer:removeAllChildren()
    -- 描述文字
    local remindLabel = ui.newLabel({text = TR("掌门，还没有队伍，快去创建队伍\n \n (组队出发可获得属性加成)"), align = cc.TEXT_ALIGNMENT_CENTER, valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER, size = 22, color = cc.c3b(0x46, 0x22, 0x0d)})
    remindLabel:setPosition(320, 690)
    self.mMidTeamLayer:addChild(remindLabel)
    local btnInfos = {
        {   -- 创建队伍
            normalImage = "c_28.png",
            text = TR("创建队伍"),
            position = cc.p(320, 580),
            clickAction = function()
                -- 创建队伍
                self:requestCreateTeam()
            end
        },
        -- {   -- 快速加入
        --     normalImage = "c_28.png",
        --     text = TR("快速加入"),
        --     position = cc.p(420, 580),
        --     clickAction = function()
        --         -- 快速加入
        --     end
        -- },
    }

    for index, btnInfo in ipairs(btnInfos) do
        local tempBtn = ui.newButton(btnInfo)
        self.mMidTeamLayer:addChild(tempBtn)
    end
end

-- 发布邀请弹窗
function JianghuKillMyTeamLayer:invitePopLayer()
    self.mJobCheckBoxList = {}
    -- DIY函数
    local function DIYLayer(layer, layerBgSprite, layerSize)
        local labelInfos = {
            {text = TR("请选择你要去的门派"), labelPos = cc.p(layerSize.width/2, 450), color = cc.c3b(0x46, 0x22, 0x0d), size = 20,},
            {text = TR("请选择你需要招募的职业"), labelPos = cc.p(layerSize.width/2, 350), color = cc.c3b(0x46, 0x22, 0x0d), size = 20,},
            {text = TR("只有和你在同一地点的玩家才能收到组队邀请"), labelPos = cc.p(layerSize.width/2, 200), color = cc.c3b(0x46, 0x22, 0x0d), size = 20,},
        }
        for index, labelInfo in ipairs(labelInfos) do
            local tempLable = ui.newLabel(labelInfo)
            tempLable:setPosition(labelInfo.labelPos)
            layerBgSprite:addChild(tempLable)
        end

        -- 添加四中职业
        local jobList = {[1] = {jobName = TR("豪杰")}, [2] = {jobName = TR("刺客")}, [3] = {jobName = TR("书生")}, [4] = {jobName = TR("镖师")},}
        for i, info in ipairs(jobList) do
            local checkBox = ui.newCheckbox({normalImage = "c_60.png", selectImage = "c_61.png", text = info.jobName, fontSize = 18, isRevert = false, textColor = cc.c3b(0x46, 0x22, 0x0d),})
            checkBox:setAnchorPoint(0, 0.5)
            checkBox:setPosition(cc.p(70+(i-1)*120, 280))
            layerBgSprite:addChild(checkBox)
            table.insert(self.mJobCheckBoxList, checkBox)
        end

        -- 根据当前节点获取可以移动到的点
        local canMoveBtnList = {}
        local curCanMoveList = JianghukillMapModel.items[self.mCurrentNodeId].canMoveIDStr
        local tempList = string.splitBySep(curCanMoveList, ",")
        -- 把自己也加进去(放在第一个)
        table.insert(tempList, 1, self.mCurrentNodeId)
        for i, v in ipairs(tempList) do
            local nodeName = tonumber(v)==self.mCurrentNodeId and TR("当前门派") or JianghukillMapModel.items[tonumber(v)].name
            local nodeBtn = ui.newButton({ 
                normalImage = "jhs_69.png", text = nodeName,
                fontSize = 22, textColor = cc.c3b(0xfd, 0xf4, 0xe8), outlineSize = 0,
                position = cc.p(layerSize.width/2-25, 390-(i*35)),
                clickAction = function()
                    for i,v in ipairs(canMoveBtnList) do
                        v:setVisible(not v:isVisible())
                    end
                    self.showNameBtn:setTitleText(nodeName)
                    self.showNameBtn.tag = tonumber(v)
                end
            })
            layerBgSprite:addChild(nodeBtn)
            nodeBtn:setVisible(false)
            table.insert(canMoveBtnList, nodeBtn)
        end
        local selectBtn = ui.newButton({ 
            normalImage = "jhs_68.png",
            position = cc.p(layerSize.width/2+65, 400),
            clickAction = function()
                for i,v in ipairs(canMoveBtnList) do
                    v:setVisible(not v:isVisible())
                end
            end
        })
        layerBgSprite:addChild(selectBtn)
        self.showNameBtn = ui.newButton({ 
            normalImage = "jhs_69.png", text = TR("当前门派"),
            fontSize = 22, textColor = cc.c3b(0xfd, 0xf4, 0xe8), outlineSize = 0,
            position = cc.p(layerSize.width/2-25, 400),
            clickAction = function()
                for i,v in ipairs(canMoveBtnList) do
                    v:setVisible(not v:isVisible())
                end
            end
        })
        self.showNameBtn.tag = self.mCurrentNodeId
        self.showNameBtn:setPressedActionEnabled(false)
        layerBgSprite:addChild(self.showNameBtn)
    end
    local btnInfos = {
        {
            text = TR("确认发布"), position = cc.p(286, 90),
            clickAction = function(layerObj, btnObj)
                -- 发布消息通知
                -- print("发布消息通知")
                if not self.mIsLeader then
                    ui.showFlashView(TR("只有队长才能发布招募信息"))
                    return
                end
                self:requestInvite(self:makeUpMsgStr())
                LayerManager.removeLayer(layerObj)
            end
        },
    }
    local tempData = {title = TR("发布招募"), msgText = "", bgSize = cc.size(572, 580), notNeedBlack = true, btnInfos = btnInfos, closeBtnInfo = {}, DIYUiCallback = DIYLayer,}
    return LayerManager.addLayer({name = "commonLayer.MsgBoxLayer", data = tempData, cleanUp = false,})
end

--组装邀请发布的字符串
function JianghuKillMyTeamLayer:makeUpMsgStr()
    local selectList = {}

    local aimStr = self.mTeamType == 1 and TR("进攻") or TR("驻守/采集")
    local nodeName = self.showNameBtn.tag==self.mCurrentNodeId and TR("当前门派") or JianghukillMapModel.items[self.showNameBtn.tag].name
    
    
    local leaderInfo 
    for i,v in ipairs(self.mTeamInfo) do
        if v.IsLeader then
            leaderInfo = v
        end
    end

    local tempStr = TR("%s(%s)【队伍目标：%s】正在招募：",leaderInfo.PlayerName, JianghukillJobModel.items[leaderInfo.Profession].name, nodeName)

    for i,v in ipairs(self.mJobCheckBoxList) do
        local isSelected = v:getCheckState()
        if isSelected then
            table.insert(selectList, i)
        end
    end
    if #selectList <=0 then
        tempStr = tempStr .. TR("所有职业")
    else
        for i,v in ipairs(selectList) do
            tempStr = tempStr .. TR("%s职业 ",JianghukillJobModel.items[v].name)
        end
    end
    -- dump(tempStr, "opopopop")
    return tempStr
end

-- 是否转让队长、踢人的小弹窗
function JianghuKillMyTeamLayer:tranLeaderAndKickOutMsg(parent, heroData)
    if not tolua.isnull(self.mKickPopMsg) then 
        self.mKickPopMsg:removeFromParent()
        self.mKickPopMsg = nil
    end  

    self.mKickPopMsg = ui.newSprite("jhs_64.png")    
    self.mKickPopMsg:setPosition(190, 85)
    parent:addChild(self.mKickPopMsg)

    local btnInfos = {
        {   -- 发布邀请
            normalImage = "c_28.png",
            text = TR("转让队长"),
            position = cc.p(110, 100),
            clickAction = function()
               self:requestReplaceLeader(heroData.PlayerId or heroData.AddPlayerId) -- 可能是加入进来的玩家用add区分
            end
        },
        {   -- 退出队伍
            normalImage = "c_95.png",
            text = TR("请离队伍"),
            position = cc.p(110, 45),
            clickAction = function()
                self:requestKickOut(heroData.PlayerId or heroData.AddPlayerId)
            end
        }
    }

    for index, btnInfo in ipairs(btnInfos) do
        local tempBtn = ui.newButton(btnInfo)
        self.mKickPopMsg:addChild(tempBtn)
    end
end

-------------------------------------------------------------
-- 创建队伍
function JianghuKillMyTeamLayer:requestCreateTeam()
    HttpClient:request({
        moduleName = "JianghuKillTeamHall",
        methodName = "CreateTeam",
        svrMethodData = {self.mCurrentNodeId, self.mTeamType, not self.mIsAgreed},
        callbackNode = self,
        callback = function(response)
            -- 容错处理
            if response.Status ~= 0 then
                return
            end
            -- dump(response, "创建队伍信息")
            -- 自己创建队伍自己就是队长
            self.mIsLeader = true
            -- 队伍信息
            self.mTeamInfo = response.Value.TeamInfo.PlayersInfo or {}
            self.mTeamType = response.Value.TeamInfo.Goal or 1
            self.mIsAgreed = not response.Value.TeamInfo.IsAgree
            -- 队伍ID
            self.mTeamID = response.Value.TeamId

            -- 加载队伍页面
            self:refreshMidTeamInfo()
            -- 添加选择box
            self:addCheckBoxUI()

            Notification:postNotification(EventsName.eCreateTeam)
        end
    })
end

-- 退出队伍（成员调用）
function JianghuKillMyTeamLayer:requestQuitTeam()
    HttpClient:request({
        moduleName = "JianghuKillTeamHall",
        methodName = "QuitTeam",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            -- 容错处理
            if response.Status ~= 0 then
                return
            end
            -- dump(response, "退出通知消息")
            self.mTeamInfo = {}
            self.mTeamType = 1
            self.mIsAgreed = true
            -- 添加没有在队伍中时的页面
            self:addNotInTeamUI()
            -- 添加选择box
            self:addCheckBoxUI()
        end
    })
end

-- 取消队伍（队长调用）
function JianghuKillMyTeamLayer:requestCancelTeam()
    HttpClient:request({
        moduleName = "JianghuKillTeamHall",
        methodName = "CancelTeam",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            -- 容错处理
            if response.Status ~= 0 then
                return
            end
            -- dump(response, "取消通知消息")
            self.mTeamInfo = {}
            self.mTeamType = 1
            self.mIsAgreed = true
            -- 添加没有在队伍中时的页面
            self:addNotInTeamUI()
            -- 添加选择box
            self:addCheckBoxUI()
        end
    })
end

-- 转让队长
function JianghuKillMyTeamLayer:requestReplaceLeader(playerId)
    HttpClient:request({
        moduleName = "JianghuKillTeamHall",
        methodName = "ReplaceLeader",
        svrMethodData = {playerId},
        callbackNode = self,
        callback = function(response)
            -- 容错处理
            if response.Status ~= 0 then
                return
            end
            -- 去掉checkbox相关UI
            self.mCheckBoxLayer:removeAllChildren()
            -- 重新获取队伍信息
            self:requestGetTeamInfo()
        end
    })
end

-- 踢人
function JianghuKillMyTeamLayer:requestKickOut(playerId)
    HttpClient:request({
        moduleName = "JianghuKillTeamHall",
        methodName = "DeleteMember",
        svrMethodData = {playerId},
        callbackNode = self,
        callback = function(response)
            -- 容错处理
            if response.Status ~= 0 then
                return
            end
            ui.showFlashView(TR(TR("踢人成功！")))
            -- 移除队员
            for i,v in ipairs(self.mTeamInfo) do
                if v.PlayerId == playerId then 
                    table.remove(self.mTeamInfo, i)
                end 
            end
            self:refreshTeamList()
        end
    })
end

-- 准备（成员调用）
function JianghuKillMyTeamLayer:requestReady()
    HttpClient:request({
        moduleName = "JianghuKillTeamHall",
        methodName = "Prepare",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            -- 容错处理
            if response.Status ~= 0 then
                return
            end
            -- dump(response, "准备通知消息")
            -- 修改自己的准备状态
            for i,v in ipairs(self.mTeamInfo) do
                if v.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then 
                    v.IsPrepare = true
                    break
                end 
            end
            -- 加载队伍页面
            self:refreshMidTeamInfo()
        end
    })
end

-- 取消准备（成员调用）
function JianghuKillMyTeamLayer:requestCancelReady()
    if self.mIsMoving then
        ui.showFlashView(TR("移动中不能取消准备"))
        return
    end

    HttpClient:request({
        moduleName = "JianghuKillTeamHall",
        methodName = "CancelPrepare",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            -- 容错处理
            if response.Status ~= 0 then
                return
            end
            -- dump(response, "取消准备通知消息")
            -- 修改自己的准备状态
            for i,v in ipairs(self.mTeamInfo) do
                if v.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then 
                    v.IsPrepare = false
                    break
                end 
            end
            -- 加载队伍页面
            self:refreshMidTeamInfo()
        end
    })
end

-- 获取队伍信息
function JianghuKillMyTeamLayer:requestGetTeamInfo()
    -- 重置是否是队长
    self.mIsLeader = false
    HttpClient:request({
        moduleName = "JianghuKillTeamHall",
        methodName = "GetTeamInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            -- 容错处理
            if response.Status ~= 0 then
                if response.Status == -14400 or response.Status == -14418 then -- 队伍不存在
                    self.mTeamInfo = {}
                    self.mTeamType = 1
                    self.mIsAgreed = true
                    -- 添加没有在队伍中时的页面
                    self:addNotInTeamUI()
                    -- 添加勾选相关的UI
                    self:addCheckBoxUI()
                end
                return
            end
            -- 队伍信息
            -- dump(response, "获取队伍信息")
            -- 队伍信息
            self.mTeamInfo = response.Value.TeamInfo.PlayersInfo or {}
            self.mTeamType = response.Value.TeamInfo.Goal or 1
            self.mIsAgreed = not response.Value.TeamInfo.IsAgree
            -- 队伍ID
            self.mTeamID = response.Value.TeamId
            -- 判断是否为队长
            for i,v in ipairs(self.mTeamInfo) do
                if v.IsLeader and v.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then 
                    self.mIsLeader = true
                    break
                end 
            end
            -- 如果不是队长不显示
            if self.mIsLeader then 
                -- 添加勾选相关的UI
                self:addCheckBoxUI()
            end 

            -- 加载队伍页面
            self:refreshMidTeamInfo()
        end
    })
end

--获取刷新信息
function JianghuKillMyTeamLayer:requestInvite(tempStr)
    HttpClient:request({
        moduleName = "JianghuKillTeamHall",
        methodName = "Invite",
        svrMethodData = {tempStr},
        callbackNode = self,
        callback = function(response)
            -- dump(response, "ssdasda")
        
            -- 容错处理
            if response.Status ~= 0 then
                return
            end
            ui.showFlashView(TR("发布邀请成功"))
        end
    })
end

return JianghuKillMyTeamLayer

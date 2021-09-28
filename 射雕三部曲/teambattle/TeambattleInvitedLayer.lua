
--[[
    文件名：TeambattleInvitedLayer.lua
    描述：   西漠接受组队邀请
    创建人：  wusonglin
    创建时间：2016.8.1
-- ]]

local TeambattleInvitedLayer = class("TeambattleInvitedLayer", function(params)
    return display.newLayer(cc.c4b(0, 0, 0, 100))
end)

-- 定义组队类型枚举
local TeamType = {
    eTeamNone   = 0, -- 路人
    eTeamGuild  = 1, -- 同一帮派
    eTeamFriend = 2, -- 好友
}

-- 定义页签枚举
local TableLayerType = {
    eTableTeam = 1,
    eTableHelp = 2,
}

--[[
-- 参数 params 中各项为：
    {
        dataList -- 传入的列表数据
    }
]]
function TeambattleInvitedLayer:ctor(params)
	-- 初始化数据
    self.mDataList = params.dataList
    -- 解析数据
    self:AnalysisData()

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 初始页签选择
    self.mSubPageType = 1
    self:initUI()
end

-- 解析传进来的参数
function TeambattleInvitedLayer:AnalysisData()
    self.mTeamList = {} -- 组队
    self.mHelpList = {} -- 助阵
    for i, v in ipairs(self.mDataList) do
        if v.IsDateOut == 0 or v.IsDateOut == false then
            local value = clone(v)
            -- 判断类型
            if v.IsFriend then
                value.type = TeamType.eTeamFriend
            elseif v.IsInSameGuild then
                value.type = TeamType.eTeamGuild
            else
                value.type = TeamType.eTeamNone
            end
            -- 存入数据
            if value.IsTeambattleHelp then
                table.insert(self.mHelpList, value)
            else
                table.insert(self.mTeamList, value)
            end
        end
    end
end

function TeambattleInvitedLayer:initUI()
    -- 屏蔽下层事件
    ui.registerSwallowTouch({node = self})
    -- 背景
    self.mBgSprite = ui.newScale9Sprite("c_30.png", cc.size(572, 908))
    self.mBgSprite:setPosition(cc.p(320, 568))
    self.mParentLayer:addChild(self.mBgSprite)
    local bgSize = self.mBgSprite:getContentSize()

    local title = ui.newLabel({
        size = 30,
        text = TR("组队邀请"),
        color = cc.c3b(0xff, 0xee, 0xdD),
        outlineColor = cc.c3b(0x3f, 0x27,0x1f),
        outlineSize = 1,
        })
    title:setAnchorPoint(cc.p(0.5, 1.0))
    title:setPosition(cc.p(bgSize.width / 2 , bgSize.height - 20))
    self.mBgSprite:addChild(title)

    -- 返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        anchorPoint = cc.p(1, 1),
        position = cc.p(bgSize.width, bgSize.height + 10),
        clickAction = function()
            LayerManager.removeLayer(self)
        end,
    })
    self.mBgSprite:addChild(closeBtn)

    local font = ui.newLabel({text = TR("好友或帮派成员组队有战力加成")})
    font:setPosition(cc.p(bgSize.width / 2 , 45))
    self.mBgSprite:addChild(font)

    -- 标签信息
    local tabItems = {}
    if next(self.mTeamList) ~= nil then
        tabItems[1] = {
            tag  = TableLayerType.eTableTeam,
            text = TR("组队"),
            outlineColor = cc.c3b(0x8a, 0x3f, 0x35),
            outlineSize = 1,
        }
    end
    if next(self.mHelpList) ~= nil then
        index = #tabItems + 1
        tabItems[index] = {
            tag  = TableLayerType.eTableHelp,
            text = TR("助阵"),
            outlineColor = cc.c3b(0x8a, 0x3f, 0x35),
            outlineSize = 1,
        }
    end
    -- tableView信息
    local tableViewInfo = {
        btnInfos = tabItems,
        viewSize = cc.size(530, 80),
        space = 0,
        allowChangeCallback = function(btnTag)
            return true
        end,
        onSelectChange = function(selectBtnTag)
            if self.mSubPageType == selectBtnTag then
                return
            else
                self.mSubPageType = selectBtnTag
                self:selecteCellButton()
            end
        end
    }

    --创建滚动层背景
    self.mViewBg = ui.newScale9Sprite("c_38.png", cc.size(520, 750))
    self.mViewBg:setAnchorPoint(cc.p(0.5, 1))
    self.mViewBg:setPosition(cc.p(self.mBgSprite:getContentSize().width / 2, self.mBgSprite:getContentSize().height - 130))
    self.mBgSprite:addChild(self.mViewBg)

    --创建滚动层
    self.mTableView = ui.newTabLayer(tableViewInfo)
    self.mTableView:setAnchorPoint(cc.p(0.5, 1.0))
    self.mTableView:setPosition(cc.p(bgSize.width / 2, bgSize.height - 10 - 40))
    self.mBgSprite:addChild(self.mTableView)

    -- 初始化
    self:selecteCellButton()
end

function TeambattleInvitedLayer:selecteCellButton()

    local list = self.mSubPageType == 1 and self.mTeamList or self.mHelpList

    if self.mListView ~= nil then
        self.mListView:removeFromParent()
        self.mListView = nil
    end

    -- 创建listView
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true) -- 设置弹力
    self.mListView:setContentSize(cc.size(500, 720))
    self.mListView:setGravity(ccui.ListViewGravity.centerVertical) -- 设置重力
    self.mListView:setItemsMargin(5.0) -- 改变两个cell之间的边界
    self.mListView:setAnchorPoint(cc.p(0.5, 1))
    self.mListView:setPosition(cc.p(self.mViewBg:getContentSize().width / 2, self.mViewBg:getContentSize().height - 15))
    self.mViewBg:addChild(self.mListView)

    -- 向listView添加数据
    table.sort(list, function(a, b)
        return a.type > b.type
    end)
    for i, v in ipairs(list) do
        self.mListView:pushBackCustomItem(self:createHeadView(i, v, self.mSubPageType))
    end
end

-- 创建cell
function TeambattleInvitedLayer:createHeadView(index, data, tag)
     -- 创建custom_item
    local custom_item = ccui.Layout:create()
    local width = 500
    local height = 120
    custom_item:setContentSize(cc.size(width, height))

    -- 创建cell
    local cellSprite = ui.newScale9Sprite("c_18.png", cc.size(width, height))
    cellSprite:setPosition(cc.p(width / 2, height / 2))
    local cellSize = cellSprite:getContentSize()
    custom_item:addChild(cellSprite)

    -- 设置头像
    local header = CardNode.createCardNode({
        resourceTypeSub = ResourcetypeSub.eHero,
        modelId = data.HeadImageId,
        fashionModelID = data.FashionModelId,
        cardShowAttrs = {
            CardShowAttr.eBorder,
            CardShowAttr.eAddMark,
            CardShowAttr.eSynthetic,
        },
        onClickCallback = function () end,  -- 屏蔽点击事件
    })
    header:setAnchorPoint(cc.p(0, 0.5))
    header:setPosition(cc.p(20, height / 2))
    custom_item:addChild(header)

    -- 标签
    local imageName = data.type == TeamType.eTeamGuild and "c_58.png" or "c_57.png"
    local titleBg = ui.newSprite(imageName)
    titleBg:setAnchorPoint(cc.p(0, 1))
    titleBg:setScale(0.75)
    titleBg:setPosition(cc.p(25, cellSize.height - 15))
    custom_item:addChild(titleBg)

    local titleFont
    local isNoTitle = false
    if data.type == TeamType.eTeamGuild then
        titleFont = TR("帮 派")--c_58
    elseif data.type == TeamType.eTeamFriend then
        titleFont = TR("好 友")
    elseif data.type == TeamType.eTeamNone then
        isNoTitle = true
    end

    local font = ui.newLabel({
        text = titleFont or "",
        size = 21,
    })
    font:setPosition(cc.p(25, 50))
    titleBg:addChild(font)
    font:setRotation(-45)
    titleBg:setVisible(not isNoTitle)

    -- 名字
    local lvLabel = ui.newLabel({
        text = string.format("%s", data.Name),
        size = 24,
        color = Enums.Color.eBlack,
    })
    lvLabel:setPosition(cc.p(140, 90))
    lvLabel:setAnchorPoint(cc.p(0, 0.5))
    custom_item:addChild(lvLabel)

    -- 战斗力
    local fapLabel = ui.newLabel({
        text  = TR("战斗力: "),
        size = 22,
        color = Enums.Color.eBlack,
    })
    fapLabel:setPosition(cc.p(140, 60))
    fapLabel:setAnchorPoint(cc.p(0, 0.5))
    custom_item:addChild(fapLabel)

    local fightLabel = ui.newLabel({
        text  = TR("%s", Utility.numberFapWithUnit(data.FAP)),
        size = 22,
        color = cc.c3b(0xd1, 0x7b,0x00),
    })
    fightLabel:setPosition(cc.p(230, 60))
    fightLabel:setAnchorPoint(cc.p(0, 0.5))
    custom_item:addChild(fightLabel)

    -- 目标
    local mapId = math.floor(data.NodeModelId/100)
    local difficult, difficultName = data.NodeModelId%10, TR("%s(普通)", "#2d6a9e")
    local targetName = TeambattleMapModel.items[1][mapId] and TeambattleMapModel.items[1][mapId].nodeName
    if difficult == 2 then
        difficultName = TR("%s(困难)", "#2d6a9e")
    elseif difficult == 3 then
        difficultName = TR("%s(噩梦)", "#2d6a9e")
    elseif difficult == 4 then
        difficultName = TR("%s(地狱)", "#2d6a9e")
    end
    local temptargetName = ""
    if mapId == 11 then
        temptargetName = TR("白虎")
    elseif mapId == 12 then
        temptargetName = TR("玄武")
    elseif mapId == 13 then
        temptargetName = TR("青龙")
    elseif mapId == 14 then
        temptargetName = TR("朱雀")
    elseif mapId == 15 then
        temptargetName = TR("蒙古军先锋")
    elseif mapId == 16 then
        temptargetName = TR("蒙古军大营")
    end

    local targetLabel = ui.newLabel({
        text = TR("目标: %s%s", temptargetName, difficultName),
        color = Enums.Color.eBlack,
    })
    targetLabel:setPosition(cc.p(140, 30))
    targetLabel:setAnchorPoint(cc.p(0, 0.5))
    custom_item:addChild(targetLabel)

    -- 按钮
    local button = ui.newButton({
        normalImage = "c_28.png",
        text = (tag == TableLayerType.eTableTeam) and TR("加入") or TR("助阵"),
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(430, 60),
        outlineColor = cc.c3b(0x8e, 0x4f, 0x09),
        clickAction = function(pSender)
            self:requestInterTeam(data.NodeModelId, data.TeamId, tag, pSender)
        end,
    })
    custom_item:addChild(button)

    return custom_item
end

-------[[----------网络----------]]----------
function TeambattleInvitedLayer:requestInterTeam(nodeModelId, teamId, tag, btnObj)
    HttpClient:request({
        moduleName = "TeambattleInfo",
        methodName = "InterTeam",
        svrMethodData = {nodeModelId, teamId},
        callback = function(data)
            -- 判断返回数据
            if data.Status ~= 0 then
                return
            end
            local dataInfo = data.Value
            if tag == TableLayerType.eTableTeam then

                -- 去开打
                LayerManager.addLayer({
                    name ="teambattle.TeambattleHomeLayer",
                    data = {nodeId = nodeModelId},
                    cleanUp = true,
                })

            elseif tag == TableLayerType.eTableHelp then
                btnObj:setEnabled(false)
                ui.showFlashView(TR("助阵成功"))
            end
        end,
    })
end


return TeambattleInvitedLayer

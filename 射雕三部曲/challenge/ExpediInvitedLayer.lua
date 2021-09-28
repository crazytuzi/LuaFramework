--[[
    文件名：ExpediInvitedLayer.lua
    描述：   组队邀请页面
    创建人：  chenzhong
    创建时间：2017.7.17
-- ]]

local ExpediInvitedLayer = class("ExpediInvitedLayer", function(params)
    return display.newLayer(cc.c4b(0, 0, 0, 100))
end)

-- 定义组队类型枚举
local TeamType = {
    eTeamNone   = 0, -- 路人
    eTeamGuild  = 1, -- 同一公会
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
function ExpediInvitedLayer:ctor(params)
    -- dump(params, "ggg")
    -- 初始化数据
    self.mDataList = params.dataList

    -- 将邀请好友的信息置空
    -- 必须放在CommonLayer之前，因为CommonLayer会引起MainNavLayer重新创建，引起ExpediInvitedLayer再次被创建
    PlayerAttrObj:changeAttr({ExpedInvitData = {}})

    -- 屏蔽下层事件
    ui.registerSwallowTouch({node = self})

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 初始页签选择
    self.mSubPageType = 1

    -- 创建底部导航和顶部玩家信息部分
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eGDDHCoin, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)

    self:initUI()

    self:requestGetTimedActivityInfo()
end

-- 解析传进来的参数
function ExpediInvitedLayer:AnalysisData()
    self.mTeamList = {} -- 组队
    for i, v in ipairs(self.mDataList) do
        table.insert(self.mTeamList, v)
    end
end

function ExpediInvitedLayer:initUI()
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

    local font = ui.newLabel({text = TR("#46220d好友或帮派成员组队有奖励加成")})
    font:setPosition(cc.p(bgSize.width / 2 , 810))
    self.mBgSprite:addChild(font)

    --创建滚动层背景
    self.mViewBg = ui.newScale9Sprite("c_38.png", cc.size(520, 750))
    self.mViewBg:setAnchorPoint(cc.p(0.5, 1))
    self.mViewBg:setPosition(cc.p(self.mBgSprite:getContentSize().width / 2, self.mBgSprite:getContentSize().height - 130))
    self.mBgSprite:addChild(self.mViewBg)

    -- 初始化
    self:selecteCellButton()
end

function ExpediInvitedLayer:selecteCellButton()
    local list = {}
    list[1] = self.mDataList

    if self.mListView ~= nil then
        self.mListView:removeFromParent()
        self.mListView = nil
    end

    -- 创建listView
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true) -- 设置弹力
    self.mListView:setContentSize(cc.size(520, 680))
    self.mListView:setGravity(ccui.ListViewGravity.centerVertical) -- 设置重力
    self.mListView:setItemsMargin(5.0) -- 改变两个cell之间的边界
    self.mListView:setAnchorPoint(cc.p(0.5, 1))
    self.mListView:setPosition(cc.p(self.mBgSprite:getContentSize().width / 2, self.mBgSprite:getContentSize().height - 150))
    self.mBgSprite:addChild(self.mListView)

    -- 向listView添加数据
    for i, v in ipairs(list) do
        self.mListView:pushBackCustomItem(self:createHeadView(i, v))
    end
end

-- 创建cell
function ExpediInvitedLayer:createHeadView(index, data)
     -- 创建custom_item
     local custom_item = ccui.Layout:create()
    local width = 520
    local height = 140
    custom_item:setContentSize(cc.size(width, height))

    -- 创建cell
    local cellSprite = ui.newScale9Sprite("c_18.png", cc.size(width-40, height))
    cellSprite:setPosition(cc.p(width / 2, height / 2))
    local cellSize = cellSprite:getContentSize()
    custom_item:addChild(cellSprite)

    -- 设置头像
    local header = CardNode.createCardNode({
        resourceTypeSub = ResourcetypeSub.eHero,
        modelId = data.HeadImageId,
        pvpInterLv = data.DesignationId,
        fashionModelID = data.FashionModelId,
        cardShowAttrs = {
            CardShowAttr.eBorder,
            CardShowAttr.eAddMark,
            CardShowAttr.eSynthetic,
        },
        onClickCallback = function () end,  -- 屏蔽点击事件
    })
    header:setAnchorPoint(cc.p(0, 0.5))
    header:setPosition(cc.p(30, height / 2))
    custom_item:addChild(header)

    -- 名字
    local lvLabel = ui.newLabel({
        text = TR("%s", data.PlayerName),
        color = Utility.getQualityColor(Utility.getQualityByModelId(data.HeadImageId), 1),
    })
    lvLabel:setPosition(cc.p(140, 110))
    lvLabel:setAnchorPoint(cc.p(0, 0.5))
    custom_item:addChild(lvLabel)

    -- 战斗力
    local fapLabel = ui.newLabel({
        text = TR("战斗力: %s", Utility.numberFapWithUnit(data.FAP or 0)),
        color = Enums.Color.eBlack,
    })
    fapLabel:setPosition(cc.p(140, 80))
    fapLabel:setAnchorPoint(cc.p(0, 0.5))
    custom_item:addChild(fapLabel)

    -- 服务器
    local ServerNameLabel = ui.newLabel({
        text = TR("服务器: %s", data.ServerName),
        color = Enums.Color.eBlack,
    })
    ServerNameLabel:setPosition(cc.p(140, 50))
    ServerNameLabel:setAnchorPoint(cc.p(0, 0.5))
    custom_item:addChild(ServerNameLabel)

    -- 目标
    local ServerNameLabel = ui.newLabel({
        text = TR("目标: %s", ExpeditionNodeModel.items[data.NodeId].name),
        color = Enums.Color.eBlack,
    })
    ServerNameLabel:setPosition(cc.p(140, 20))
    ServerNameLabel:setAnchorPoint(cc.p(0, 0.5))
    custom_item:addChild(ServerNameLabel)

    -- 按钮
    local button = ui.newButton({
        normalImage = "c_28.png",
        text = TR("加入"),
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(430, 65),
        clickAction = function(pSender)
            self:requestInterTeam(data.TeamId, data.NodeId)    
        end,
    })
    button:setScale(0.85)
    custom_item:addChild(button)

    return custom_item
end

-------[[----------网络----------]]----------
function ExpediInvitedLayer:requestInterTeam(teamId, NodeId)
    HttpClient:request({
        moduleName = "TeamHall",
        methodName = "EnterTeam",
        svrMethodData = {teamId, NodeId, true},
        callback = function(data)
            -- 判断返回数据
            if not data or data.Status ~= 0 then
                return
            end

            local data = data.Value
            LayerManager.addLayer({
                name = "challenge.ExpediTeamLayer",
                data = {nodeInfo = data.NodeInfo, teamInfo = data.TeamInfo, isDoubleActivity = self.mIsSalesActivity},
            })
        end,
    })
end

-- 请求服务器，获取所有已开启的福利多多活动的信息
function ExpediInvitedLayer:requestGetTimedActivityInfo()
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
                    break
                end
            end
        end
    })
end

return ExpediInvitedLayer
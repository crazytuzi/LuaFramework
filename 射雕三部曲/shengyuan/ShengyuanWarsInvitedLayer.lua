--[[
    文件名：ShengyuanWarsInvitedLayer.lua
    描述：   决战桃花岛收到好友的邀请页面
    创建人：  chenzhong
    创建时间：2017.9.2
-- ]]

local ShengyuanWarsInvitedLayer = class("ShengyuanWarsInvitedLayer", function(params)
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

require("shengyuan.ShengyuanWarsStatusHelper")
require("shengyuan.ShengyuanWarsHelper")
require("shengyuan.ShengyuanWarsUiHelper")

--[[
-- 参数 params 中各项为：
    {
        dataList -- 传入的列表数据
    }
]]
function ShengyuanWarsInvitedLayer:ctor(params)
    --dump(params, "ggg")
    -- 初始化数据
    self.mDataList = params.dataList

    -- 屏蔽下层事件
    ui.registerSwallowTouch({node = self})

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 将邀请好友的信息置空
    -- 必须放在CommonLayer之前，因为CommonLayer会引起MainNavLayer重新创建，引起ExpediInvitedLayer再次被创建
    PlayerAttrObj:changeAttr({
        ShengyuanWarsInvitData = {}
    })
    Notification:postNotification(EventsName.eShengyuanWarsInvite)

    -- 初始页签选择
    self.mSubPageType = 1

    -- 创建底部导航和顶部玩家信息部分
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eGDDHCoin, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)

    
    -- 初始化页面
    self:initUI()

    -- 获取邀请数据
    self:getIntivtInfo(self.mDataList)
end

-- 解析传进来的参数
function ShengyuanWarsInvitedLayer:AnalysisData()
    self.mTeamList = {} -- 组队
    for i, v in ipairs(self.mDataList) do
        table.insert(self.mTeamList, v)
    end
end

function ShengyuanWarsInvitedLayer:initUI()
    -- 背景
    self.mBgSprite = ui.newScale9Sprite("c_30.png", cc.size(572, 908))
    self.mBgSprite:setPosition(cc.p(320, 568))
    self.mParentLayer:addChild(self.mBgSprite)
    local bgSize = self.mBgSprite:getContentSize()

    local title = ui.newLabel({
        size = 30,
        text = TR("桃花岛队伍邀请"),
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

    --创建滚动层背景
    self.mViewBg = ui.newScale9Sprite("c_38.png", cc.size(520, 800))
    self.mViewBg:setAnchorPoint(cc.p(0.5, 1))
    self.mViewBg:setPosition(cc.p(self.mBgSprite:getContentSize().width / 2, self.mBgSprite:getContentSize().height - 80))
    self.mBgSprite:addChild(self.mViewBg)

    -- 初始化
    -- self:selecteCellButton()
end

function ShengyuanWarsInvitedLayer:selecteCellButton()
    -- 创建listView
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true) -- 设置弹力
    self.mListView:setContentSize(cc.size(520, 730))
    self.mListView:setGravity(ccui.ListViewGravity.centerVertical) -- 设置重力
    self.mListView:setItemsMargin(5.0) -- 改变两个cell之间的边界
    self.mListView:setAnchorPoint(cc.p(0.5, 1))
    self.mListView:setPosition(cc.p(self.mBgSprite:getContentSize().width / 2, self.mBgSprite:getContentSize().height - 100))
    self.mBgSprite:addChild(self.mListView)

    -- 向listView添加数据
    for i, v in ipairs(self.mInviteData) do
        self.mListView:pushBackCustomItem(self:createHeadView(i, v))
    end
end

-- 创建cell
function ShengyuanWarsInvitedLayer:createHeadView(index, data)
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
        fashionModelID = data.FashionModelId,
        IllusionModelId = data.IllusionModelId,
        cardShowAttrs = {
            CardShowAttr.eBorder,
            CardShowAttr.eAddMark,
            CardShowAttr.eSynthetic,
        },
    })
    header:setAnchorPoint(cc.p(0, 0.5))
    header:setPosition(cc.p(30, height / 2))
    custom_item:addChild(header)

    -- 名字
    local lvLabel = ui.newLabel({
        text = TR("%s", data.Name),
        color = Utility.getQualityColor(Utility.getQualityByModelId(data.HeadImageId), 1),
    })
    lvLabel:setPosition(cc.p(140, 100))
    lvLabel:setAnchorPoint(cc.p(0, 0.5))
    custom_item:addChild(lvLabel)

    -- 战斗力
    local fapLabel = ui.newLabel({
        text = TR("战斗力: %s", Utility.numberFapWithUnit(data.Fap or 0)),
        color = Enums.Color.eBlack,
    })
    fapLabel:setPosition(cc.p(140, 50))
    fapLabel:setAnchorPoint(cc.p(0, 0.5))
    custom_item:addChild(fapLabel)

    -- 按钮
    local button = ui.newButton({
        normalImage = "c_28.png",
        text = TR("加入"),
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(430, 65),
        clickAction = function(pSender)
            self:requestInterTeam(data.TeamId)    
        end,
    })
    button:setScale(0.85)
    custom_item:addChild(button)

    return custom_item
end

-------[[----------网络----------]]----------
function ShengyuanWarsInvitedLayer:requestInterTeam(teamId)
    HttpClient:request({
        moduleName = "ShengyuanTeam",
        methodName = "EnterTeam",
        svrMethodData = {teamId},
        callback = function(data)
            -- 判断返回数据
            if not data or data.Status ~= 0 then
                return
            end

            -- 修改缓存
            ShengyuanWarsStatusHelper:setGodDomainLeaderId(data.Value.LeaderId)
            ShengyuanWarsStatusHelper:setGodDomainTeamState(1)

            LayerManager.addLayer({
                name = "shengyuan.ShengyuanWarsTeamLayer",
                data = {},
            })
        end,
    })
end

-- 获取邀请信息
function ShengyuanWarsInvitedLayer:getIntivtInfo(teamId)
    HttpClient:request({
        moduleName = "ShengyuanTeam",
        methodName = "GetInviteInfo",
        svrMethodData = {teamId},
        callbackNode = self,
        callback = function(data)
            -- 判断返回数据
            if not data or data.Status ~= 0 then
                return
            end

            self.mInviteData = data.Value.InviteInfo

            self:selecteCellButton()
        end,
    })
end

return ShengyuanWarsInvitedLayer
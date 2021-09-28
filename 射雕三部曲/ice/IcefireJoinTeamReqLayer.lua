--[[
    文件名：IcefireJoinTeamReqLayer.lua
    描述：   冰火岛请求加入页面
    创建人：  chenzhong
    创建时间：2017.9.2
-- ]]

local IcefireJoinTeamReqLayer = class("IcefireJoinTeamReqLayer", function(params)
    return display.newLayer(cc.c4b(0, 0, 0, 100))
end)

require("ice.IcefireHelper")

function IcefireJoinTeamReqLayer:ctor(params)
    -- 屏蔽下层事件
    ui.registerSwallowTouch({node = self})

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
    
    -- 初始化页面
    self:initUI()

    -- 注册刷新请求列表事件
    Notification:registerAutoObserver(self, function ()
        self:refreshReqList()
    end, {IcefireHelper.Events.eReqJoinTeam})
end

function IcefireJoinTeamReqLayer:initUI()
    -- 背景
    self.mBgSprite = ui.newScale9Sprite("c_30.png", cc.size(630, 908))
    self.mBgSprite:setPosition(cc.p(320, 568))
    self.mParentLayer:addChild(self.mBgSprite)
    local bgSize = self.mBgSprite:getContentSize()

    local title = ui.newLabel({
        size = 30,
        text = TR("冰火岛加入队伍请求"),
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
    local listBg = ui.newScale9Sprite("c_38.png", cc.size(580, 800))
    listBg:setAnchorPoint(cc.p(0.5, 1))
    listBg:setPosition(cc.p(self.mBgSprite:getContentSize().width / 2, self.mBgSprite:getContentSize().height - 70))
    self.mBgSprite:addChild(listBg)
    -- 创建listView
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true) -- 设置弹力
    self.mListView:setContentSize(cc.size(560, 730))
    self.mListView:setGravity(ccui.ListViewGravity.centerVertical) -- 设置重力
    self.mListView:setItemsMargin(5.0) -- 改变两个cell之间的边界
    self.mListView:setAnchorPoint(cc.p(0.5, 1))
    self.mListView:setPosition(cc.p(self.mBgSprite:getContentSize().width / 2, self.mBgSprite:getContentSize().height - 90))
    self.mBgSprite:addChild(self.mListView)

    self:refreshReqList()
end

function IcefireJoinTeamReqLayer:refreshReqList()
    self.mListView:removeAllChildren()
    if self.mEmptyHint then
        self.mEmptyHint:removeFromParent()
        self.mEmptyHint = nil
    end

    if next(IcefireHelper.joinTeamReqList) then
        for _, reqInfo in pairs(clone(IcefireHelper.joinTeamReqList)) do
            local playerInfo = IcefireHelper:getPlayerData(reqInfo.PlayerId)
            if playerInfo then
                local item = self:createHeadView(playerInfo)
                self.mListView:pushBackCustomItem(item)
            end
        end
    else
        self.mEmptyHint = ui.createEmptyHint(TR("暂无加入队伍申请"))
        self.mEmptyHint:setPosition(self.mBgSprite:getContentSize().width*0.5, self.mBgSprite:getContentSize().height*0.5)
        self.mBgSprite:addChild(self.mEmptyHint)
    end
end

-- 创建cell
function IcefireJoinTeamReqLayer:createHeadView(data)
     -- 创建custom_item
     local custom_item = ccui.Layout:create()
    local width = 560
    local height = 170
    custom_item:setContentSize(cc.size(width, height))

    -- 创建cell
    local cellSprite = ui.newScale9Sprite("c_18.png", cc.size(width, height))
    cellSprite:setPosition(cc.p(width / 2, height / 2))
    local cellSize = cellSprite:getContentSize()
    custom_item:addChild(cellSprite)

    -- 创建玩家头像
    local headCard = CardNode.createCardNode({
        resourceTypeSub = ResourcetypeSub.eHero,
        modelId = data.HeadImageId,
        cardShowAttrs = {CardShowAttr.eBorder},
        allowClick = false,
    })
    headCard:setPosition(cellSize.width*0.11, cellSize.height*0.7)
    cellSprite:addChild(headCard)
    -- 玩家姓名
    local playerName = ui.newLabel({
            text = TR("姓名: %s", data.Name),
            color = cc.c3b(0x46, 0x22, 0x0d),
            size = 24,
        })
    playerName:setAnchorPoint(cc.p(0, 0))
    playerName:setPosition(cellSize.width*0.22, cellSize.height*0.75)
    cellSprite:addChild(playerName)
    -- 等级
    local playerLv = ui.newLabel({
        text = TR("等级: %s%d", "#d17b00", data.Lv),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 24,
    })
    playerLv:setAnchorPoint(cc.p(0, 0))
    playerLv:setPosition(cellSize.width*0.22, cellSize.height*0.5)
    cellSprite:addChild(playerLv)
    -- 战力
    local FAPStr = Utility.numberFapWithUnit(data.Fap)
    local playerFap = ui.newLabel({
        text = TR("战斗力: %s%s", "#20781b", FAPStr),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 24,
    })
    playerFap:setAnchorPoint(cc.p(0, 0))
    playerFap:setPosition(cellSize.width*0.55, cellSize.height*0.75)
    cellSprite:addChild(playerFap)
    -- 区服
    local playerGuild = ui.newLabel({
        text = TR("区服: %s%s", "#d17b00", data.Zone),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 24,
    })
    playerGuild:setAnchorPoint(cc.p(0, 0))
    playerGuild:setPosition(cellSize.width*0.55, cellSize.height*0.5)
    cellSprite:addChild(playerGuild)

    -- 同意
    local agreeBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("同意"),
        clickAction = function ( ... )
            IcefireHelper:agreeJoinTeam(data.PlayerId, true)
            -- 删除该条申请
            IcefireHelper.joinTeamReqList[data.PlayerId] = nil
            -- 刷新
            self:refreshReqList()
        end
    })
    agreeBtn:setPosition(cellSize.width*0.3, cellSize.height*0.25)
    cellSprite:addChild(agreeBtn)
    -- 拒绝
    local refuseBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("拒绝"),
        clickAction = function ( ... )
            IcefireHelper:agreeJoinTeam(data.PlayerId, false)
            -- 删除该条申请
            IcefireHelper.joinTeamReqList[data.PlayerId] = nil
            -- 刷新
            self:refreshReqList()
        end
    })
    refuseBtn:setPosition(cellSize.width*0.7, cellSize.height*0.25)
    cellSprite:addChild(refuseBtn)

    return custom_item
end

return IcefireJoinTeamReqLayer
--[[
    文件名：FriendGetSTALayer.lua
    描述：领取气力
    创建人：chenzhong
    创建时间：2016.6.15
    修改人：wukun
    修改时间：2016.08.30
-- ]]

local FriendGetSTALayer = class("FriendGetSTALayer", function(params)
    return display.newLayer()
end)

--[[
-- 参数 params ：
    -- 无参数
]]
function FriendGetSTALayer:ctor()
    self.getSTAList = {}
    -- 初始化页面
    self:initUI()
    -- 初始化数据
    self:requestGetFriendList()             --获取玩家好友信息列表
    self:requestGetRecommendFriendList()    --获取玩家(可领取)气力消息列表
end

-- 初始化页面控件
function FriendGetSTALayer:initUI()
    -- 领取并回赠
    self.oneKeyGetSTABtn = ui.newButton({
            normalImage = "c_28.png",
            position = cc.p(560, 145),
            text = TR("一键领取"),
            clickAction = function ()
                if #self.getSTAList == 0 then
                    ui.showFlashView(TR("没有可领取的气力"))
                else
                    self:requestBatchReceiveAndSendSTA()
                end
            end
        })
    self.oneKeyGetSTABtn:setScale(0.8)
    self:addChild(self.oneKeyGetSTABtn)
    
    --黑色小背景
    local underBgSprite = ui.newScale9Sprite("c_17.png", cc.size(90, 30))
    underBgSprite:setPosition(410, 145)
    self:addChild(underBgSprite)
    -- 好友数量Label
    local friendLabel = ui.newLabel({
        text = TR("好友数量:"),
        size = 20,
        color = cc.c3b(0x46, 0x22, 0x0d),
        })
    friendLabel:setPosition(310, 145)
    self:addChild(friendLabel)

    self.friendNumber = ui.createSpriteAndLabel({
        scale9Size = cc.size(89, 36),
        labelStr = "",
    })
    self.friendNumber:setPosition(410, 145)
    self:addChild(self.friendNumber)
    
    --黑色小背景
    local underBgSprite = ui.newScale9Sprite("c_17.png", cc.size(90, 30))
    underBgSprite:setPosition(200, 145)
    self:addChild(underBgSprite)
    -- 今日剩余次数Label
    local remainTimesLabel = ui.newLabel({
        text = TR("今日剩余次数:"),
        size = 20,
        color = cc.c3b(0x46, 0x22, 0x0d),
        })
    remainTimesLabel:setPosition(80, 145)
    self:addChild(remainTimesLabel)

    self.remainTimes = ui.createSpriteAndLabel({
        scale9Size = cc.size(89, 36),
        labelStr = "",
    })
    self.remainTimes:setPosition(200, 145)
    self:addChild(self.remainTimes)

    -- 创建显示可领取气力的好友的listView
    self.listView = ccui.ListView:create()
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setContentSize(cc.size(604, 750))
    self.listView:setGravity(ccui.ListViewGravity.centerVertical) 
    self.listView:setAnchorPoint(cc.p(0.5, 1))
    self.listView:setBounceEnabled(true)
    self.listView:setPosition(cc.p(320, 950))
    self:addChild(self.listView)
end

-- 刷新数据
function FriendGetSTALayer:refreshLayer()
    -- 刷新今日剩余次数
    self.remainTimes:setString(string.format("%d/%d", self.getSTAMessages.STADrawLeftCount, StaConfig.items[1].friendGetMax))
    -- 刷新好友数量
    local friendCount = table.maxn(self.friendList)
    local currLv = PlayerAttrObj:getPlayerAttrByName("Lv")
    self.friendNumber:setString(string.format("%d/%d", friendCount, PlayerLvRelation.items[currLv].friendMax))

    -- 清空原来的列表
    if self.listView then
        self.listView:removeAllItems()
    end
    -- 刷新可领取气力的好友的listView
    if self.getSTAList and #self.getSTAList > 0 then 
        for i, v in ipairs(self.getSTAList) do
            self.listView:pushBackCustomItem(self:createHeadView(i))
        end
    end    
end

-- 添加可领取气力的好友的listView
function FriendGetSTALayer:createHeadView(index)
    -- 创建layout
    local customItem = ccui.Layout:create()
    customItem:setContentSize(cc.size(604, 130))

    local cellBg = ui.newScale9Sprite("c_18.png", cc.size(594,125))
    cellBg:setPosition(302, 62.5)
    customItem:addChild(cellBg)

    -- 头像
    local friendData = self.getSTAList[index]
    local headSprite = CardNode.createCardNode({
        resourceTypeSub = ResourcetypeSub.eHero,
        modelId = friendData.HeadImageId,
        fashionModelID = friendData.FashionModelId,
        IllusionModelId = friendData.IllusionModelId,
        pvpInterLv = friendData.DesignationId,
        cardShowAttrs = {CardShowAttr.eBorder},
        onClickCallback = function()
            Utility.showPlayerTeam(friendData.PlayerId)
            local tempStr = "more.FriendLayer"
            local tempData = LayerManager.getRestoreData(tempStr)
            if tempData then
                tempData.pageType = Enums.FriendPageType.eGetSTA
                LayerManager.setRestoreData(tempStr, tempData)
            end
        end
    })
    headSprite:setPosition(cc.p(60, 62.5))
    cellBg:addChild(headSprite)

    -- 名字
    local nameLabel = ui.newLabel({
        text = string.format("%s",friendData.PlayerName),
        size = 20,
        color = Enums.Color.eBlack
    })
    nameLabel:setAnchorPoint(cc.p(0, 0.5))
    nameLabel:setPosition(130, 85)
    cellBg:addChild(nameLabel)

    -- 战斗力
    local valueView = Utility.numberFapWithUnit(friendData.FAP)
    local fapLabel = ui.newLabel({
        text = TR("战斗力:"),
        size = 20,
        color = Enums.Color.eBlack
    })
    fapLabel:setAnchorPoint(cc.p(0, 0.5))
    fapLabel:setPosition(130, 55)
    local valueLabel = ui.newLabel({
        text = string.format("%s",valueView),
        size = 20,
        color = Enums.Color.eNormalYellow
    })
    valueLabel:setAnchorPoint(cc.p(0, 0.5))
    valueLabel:setPosition(200, 55)
    cellBg:addChild(fapLabel)
    cellBg:addChild(valueLabel)

    --VIP等级
    local vipNode = ui.createVipNode(friendData.Vip)
    vipNode:setPosition(130, 28)
    cellBg:addChild(vipNode)

    -- 领取
    local getButton = ui.newButton({
        normalImage = "c_28.png",
        position = cc.p(520, 55),
        text = TR("领取"),
        clickAction = function (pSender)
            self:requestReceiveFriendSTA(self.getSTAList[index].PlayerId)
        end
    })
    cellBg:addChild(getButton)

    return customItem
end

-------------------网络相关-------------
-- 获取玩家(可领取)气力消息列表
function FriendGetSTALayer:requestGetRecommendFriendList()
    HttpClient:request({
        moduleName = "FriendMessage",
        methodName = "GetFriendSTAMessages",
        svrMethodData = {},
        callbackNode = self,
        callback = function (response)
            if not response or response.Status ~= 0 then
                return
            end
            self.getSTAMessages = response.Value
            self.getSTAList = self.getSTAMessages.STAData or {}
            if #self.getSTAList == 0 then
                local sp = ui.createEmptyHint(TR("没有可领取的气力！"))
                sp:setPosition(320, 568)
                self:addChild(sp)
            end
            self:refreshLayer()
        end
    })
end

-- 领取好友气力 (单个)
function FriendGetSTALayer:requestReceiveFriendSTA(Id)
    HttpClient:request({
        moduleName = "FriendMessage",
        methodName = "ReceiveFriendSTA",
        svrMethodData = {Id},
        callbackNode = self,
        callback = function (response)
            if not response or response.Status ~= 0 then
                return
            end
            ui.showFlashView(TR("领取气力成功"))
            -- 重新获取数据刷新列表
            self:requestGetRecommendFriendList()
        end
    })
end

-- 批量领取并回赠气力
function FriendGetSTALayer:requestBatchReceiveAndSendSTA( )
    HttpClient:request({
        moduleName = "FriendMessage",
        methodName = "BatchReceiveAndSendSTA",
        svrMethodData = {},
        callbackNode = self,
        callback = function (response)
            if not response or response.Status ~= 0 then
                return
            end
            ui.showFlashView(TR("成功领取并回赠气力"))
            self.remainTimes:setString(string.format("%d/%d", response.Value.STADrawLeftCount, StaConfig.items[1].friendGetMax))
            -- 重新获取数据刷新列表
            self:requestGetRecommendFriendList()
        end
    })
end

-- 获取玩家好友信息列表
function FriendGetSTALayer:requestGetFriendList()
    FriendObj:requestGetFriendList(function(friendList)
        self.friendList = friendList
    end)
end

return FriendGetSTALayer
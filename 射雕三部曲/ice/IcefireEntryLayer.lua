--[[
    文件名：IcefireEntryLayer.lua
    描述：冰火岛入口
    创建人：yanghongsheng
    创建时间： 2019.07.17
--]]

require("ice.IcefireHelper")

local IcefireEntryLayer = class("IcefireEntryLayer", function(params)
    return display.newLayer()
end)

function IcefireEntryLayer:ctor(params)
    -- 弹窗
    local parentLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(570, 569),
        title = TR("探秘冰火岛"),
    })
    self:addChild(parentLayer)

    -- 保存弹框控件信息
    self.mBgSprite = parentLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

    -- 创建页面控件
    self:initUI()

    self:requestInfo()
end


function IcefireEntryLayer:initUI()
    -- 提示文字
    local hintLabel = ui.newLabel({
        text = TR("据江湖上传来的可靠消息情报，神秘莫测的冰火岛上突然出现大量宝石，据传宝石可以为装备提升不少的属性，因此引来了各方势力的暗中角力，一起潜入冰火岛一探究竟吧!"),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 20,
        dimensions = cc.size(self.mBgSize.width-80, 0),
    })
    hintLabel:setAnchorPoint(cc.p(0.5, 1))
    hintLabel:setPosition(self.mBgSize.width*0.5, self.mBgSize.height-70)
    self.mBgSprite:addChild(hintLabel)
    -- 黑背景
    local blackSize = cc.size(self.mBgSize.width-80, 190)
    local blackBg = ui.newScale9Sprite("c_17.png", blackSize)
    blackBg:setAnchorPoint(cc.p(0.5, 1))
    blackBg:setPosition(self.mBgSize.width*0.5, self.mBgSize.height-165)
    self.mBgSprite:addChild(blackBg)
    -- 频道列表
    self.mChannelListView = ccui.ListView:create()
    self.mChannelListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mChannelListView:setBounceEnabled(true)
    self.mChannelListView:setContentSize(cc.size(blackSize.width, blackSize.height-20))
    self.mChannelListView:setItemsMargin(5)
    self.mChannelListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    self.mChannelListView:setAnchorPoint(cc.p(0.5, 0.5))
    self.mChannelListView:setPosition(blackSize.width*0.5, blackSize.height*0.5)
    blackBg:addChild(self.mChannelListView)
    -- 今日掉落预览
    local tempBgSize = cc.size(260, 50)
    local tempBgSprite = ui.newScale9Sprite("c_25.png", tempBgSize)
    tempBgSprite:setPosition(115, 185)
    self.mBgSprite:addChild(tempBgSprite)

    local tempLabel = ui.newLabel({
        text = TR("掉落预览"),
        outlineColor = cc.c3b(0x6e, 0x3c, 0x05),
    })
    tempLabel:setPosition(tempBgSize.width*0.5, tempBgSize.height*0.5)
    tempBgSprite:addChild(tempLabel)
    -- 掉落预览列表
    self.mDropRewardList = ui.createCardList({
        maxViewWidth = self.mBgSize.width-80,
        cardDataList  = {},
        space = -10,
    })
    self.mDropRewardList:setAnchorPoint(cc.p(0.5, 0.5))
    self.mDropRewardList:setPosition(self.mBgSize.width*0.5, 90)
    self.mBgSprite:addChild(self.mDropRewardList)
    -- 冰火岛商店
    local shopBtn = ui.newButton({
        normalImage = "bhd_8.png",
        text = TR("商店"),
        clickAction = function ( ... )
            LayerManager.addLayer({name = "ice.IcefireShopLayer", cleanUp = false})
        end
    })
    shopBtn:setPosition(470, 185)
    self.mBgSprite:addChild(shopBtn)
    --规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        position = cc.p(40, self.mBgSize.height-35),
        clickAction = function ()
            MsgBoxLayer.addRuleHintLayer("规则",
            {
                TR("1.每天可消耗神行值进入冰火岛中探索。"),
                TR("2.击败冰火岛中的守卫和护法可获得宝石奖励，护法获得高级奖励概率更高。"),
                TR("3.冰火岛之中可以与全服玩家组队一同探索。"),
                TR("4.每次发起攻击消耗20点神行值。"),
            })
        end
    })
    self.mBgSprite:addChild(ruleBtn)
end

-- 刷新频道列表
function IcefireEntryLayer:refreshChannelList()
    self.mChannelListView:removeAllChildren()

    for _, channelInfo in ipairs(self.mChannelList) do
        local itemSize = cc.size(self.mChannelListView:getContentSize().width, 80)
        local itemLayout = ccui.Layout:create()
        itemLayout:setContentSize(itemSize)
        self.mChannelListView:pushBackCustomItem(itemLayout)
        -- 选择频道按钮
        local bgBtn = ui.newButton({
            normalImage = "c_65.png",
            size = cc.size(490, 65),
            clickAction = function ()
                if channelInfo.OnlineNum >= IcefireConfig.items[1].channelMaxNum then
                    ui.showFlashView(TR("频道人数已满"))
                    return
                end
                self:requestChooseChannel(channelInfo.ChannelId)
            end
        })
        bgBtn:setPosition(itemSize.width*0.5, itemSize.height*0.5)
        itemLayout:addChild(bgBtn)

        local nameLabel = ui.newLabel({
            text = TR("线路：#37ff40%s", channelInfo.ChannelId),
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        })
        nameLabel:setPosition(itemSize.width*0.5, itemSize.height*0.5)
        itemLayout:addChild(nameLabel)

        -- 流畅/爆满
        local tagPic = IcefireConfig.items[1].channelMaxNum*0.8 < channelInfo.OnlineNum and "bhd_6.png" or "bhd_7.png"
        local tagSprite = ui.newSprite(tagPic)
        tagSprite:setPosition(itemSize.width-30, itemSize.height-30)
        itemLayout:addChild(tagSprite)
    end
end

-- 刷新界面
function IcefireEntryLayer:refreshUI()
    self:refreshChannelList()
    self.mDropRewardList.refreshList(self.getDropRewardList())
end

function IcefireEntryLayer.getDropRewardList()
    local rewardList = {}
    for _, bossInfo in pairs(IcefireBossModel.items) do
        local resList = Utility.analysisStrResList(bossInfo.reward)
        for _, resInfo in pairs(resList) do
            rewardList[resInfo.resourceTypeSub..resInfo.modelId] = {resourceTypeSub = resInfo.resourceTypeSub, modelId = resInfo.modelId}
        end
    end
    for _, dropList in pairs(IcefireBossDropRelation.items) do
        for _, dropInfo in pairs(dropList) do
            rewardList[dropInfo.typeID..dropInfo.modelID] = {resourceTypeSub = dropInfo.typeID, modelId = dropInfo.modelID}
        end
    end

    local tempList = table.values(rewardList)
    -- 排序
    table.sort(tempList, function (resInfo1, resInfo2)
        -- 类型
        if resInfo1.resourceTypeSub ~= resInfo2.resourceTypeSub then
            return resInfo1.resourceTypeSub < resInfo2.resourceTypeSub
        end
        -- 品质
        local quality1 = Utility.getQualityByModelId(resInfo1.modelId, resInfo1.resourceTypeSub)
        local quality2 = Utility.getQualityByModelId(resInfo2.modelId, resInfo2.resourceTypeSub)
        if quality1 ~= quality2 then
            return quality1 > quality2
        end

        return resInfo1.modelId < resInfo2.modelId
    end)

    return tempList
end

--=========================服务器相关============================
-- 请求数据
function IcefireEntryLayer:requestInfo()
    HttpClient:request({
        moduleName = "IcefireTeamHall",
        methodName = "GetAllData",
        svrMethodData = {},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
            -- dump(response.Value)
            -- 设置服务器ip
            IcefireHelper:setUrl(response.Value.Data.SocketServerCenterAddress)

            self.mChannelList = response.Value.Data.ChannelData
            -- 频道排序
            table.sort(self.mChannelList, function (channelInfo1, channelInfo2)
                if channelInfo1.OnlineNum ~= channelInfo2.OnlineNum then
                    return channelInfo1.OnlineNum < channelInfo2.OnlineNum
                end

                return channelInfo1.ChannelId < channelInfo2.ChannelId
            end)

            self:refreshUI()

            -- 建立连接
            IcefireHelper:connect()
        end
    })
    
end

-- 选择频道
function IcefireEntryLayer:requestChooseChannel(channelId)
    HttpClient:request({
        moduleName = "IcefireTeamHall",
        methodName = "ChooseChannel",
        svrMethodData = {channelId},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
            dump(response.Value, "选择频道")
            -- 设置玩家信息
            IcefireHelper:setOwnPlayerInfo(response.Value.Data.PlayerInfo)
            -- 设置玩家列表信息
            IcefireHelper:setPlayerListInfo(response.Value.Data.ChannelPlayer)
            -- 设置boss信息
            IcefireHelper:setBossListInfo(response.Value.Data.ChannelBossData)

            -- 跳转地图页面
            LayerManager.addLayer({name = "ice.IcefireMapLayer"})
        end
    })
    
end

return IcefireEntryLayer
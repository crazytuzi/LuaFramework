--[[
	文件名：GGZJCompensationLayer.lua
	描述：血刃悬赏悬赏奖励页面 (GGZJ--->过关斩将)
	创建人：liucunxin
	创建时间：2016.12.17
--]]

local GGZJCompensationLayer = class("GGZJCompensationLayer", function(params)
    return display.newLayer()
end)

require("Config.XrxsSupplyBaseModel")

-- 构造函数
--[[
	params:
	-- 必传参数
		parent 				-- 页面父对象
		playerInfo  				-- 传入数据（暂定）
--]]

function GGZJCompensationLayer:ctor(params)
    -- 奖励ID列表
    self.mRewardList = {}
	self.mPlayerInfo = params.playerInfo
    self:initUI()
end

-- 初始化界面
function GGZJCompensationLayer:initUI()
    -- 创建该页面的父节点
    -- 添加弹出框层
    local bgSpriteWidth = 573
    local bgSpriteHeight = 780
    local parentLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(573, 730),
        title = TR("领取奖励"),
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(parentLayer)

    self:requestBujiInfo(parentLayer)
end

-- 悬赏奖励页面
function GGZJCompensationLayer:createCompensationLayer(parent)
    -- 页面背景
    local bgSprite = parent.mBgSprite
    local bgSize = bgSprite:getContentSize()

    -- 子父背景
    local subBgSprite = ui.newScale9Sprite("c_17.png", cc.size(506, 496))
    subBgSprite:setAnchorPoint(cc.p(0.5, 0.5))
    subBgSprite:setPosition(cc.p(bgSize.width * 0.5 ,bgSize.height * 0.5))
    bgSprite:addChild(subBgSprite)

    -- 当前赏金点背景
    local preAccessSprite = ui.newSprite("tjl_16.png")
    preAccessSprite:setPosition(cc.p(bgSize.width * 0.07 ,bgSize.height * 0.88))
    preAccessSprite:setAnchorPoint(cc.p(0, 0.5))
    bgSprite:addChild(preAccessSprite)

    -- “当前赏金点”标签
    self.mPreAccessLabel = ui.newLabel({
        text = TR("当前赏金点: #d17b00{%s} %s", "c_75.png", self.mPlayerInfo.SupplyStar),
        color = Enums.Color.eBlack,
        size = 22
    })
    self.mPreAccessLabel:setAnchorPoint(cc.p(0, 0.5))
    self.mPreAccessLabel:setPosition(cc.p(preAccessSprite:getContentSize().width * 0.015, preAccessSprite:getContentSize().height * 0.5))
    preAccessSprite:addChild(self.mPreAccessLabel)

    -- 创建listview
    local rewardList = ccui.ListView:create()
    rewardList:setDirection(ccui.ScrollViewDir.vertical)
    rewardList:setBounceEnabled(true)
    rewardList:setContentSize(cc.size(subBgSprite:getContentSize().width * 0.95, subBgSprite:getContentSize().height * 0.99))
    rewardList:setTouchEnabled(false)
    rewardList:setGravity(ccui.ListViewGravity.centerVertical)
    rewardList:setItemsMargin(10)
    rewardList:setAnchorPoint(cc.p(0.5, 1))
    rewardList:setPosition(cc.p(subBgSprite:getContentSize().width * 0.5, subBgSprite:getContentSize().height * 0.99))
    rewardList:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    subBgSprite:addChild(rewardList)

    -- 创建条目子背景
    local tempSize = {
        width = 476,
        height = 150
    }

    -- 创建奖励对象
    local function createItem(parent, pos, starNum)
        -- 父节点
        local tempNode = cc.Node:create()
        tempNode:setPosition(pos)
        parent:addChild(tempNode)
        self.mRewardList[starNum] = {}
        self.mRewardList[starNum].parent = tempNode

        -- 奖励图标
        local List = Utility.analysisStrResList(self.mBujiInfo[starNum].RewardResource)

        local tempCard = CardNode.createCardNode({
                resourceTypeSub = List[1].resourceTypeSub,
                modelId = List[1].modelId,
                num = List[1].num,
                cardShowAttrs = {
                    CardShowAttr.eBorder,
                    CardShowAttr.eNum
                },
                onClickCallback = function(pSender)
                    if not self.mBujiInfo[starNum].IsReward then
                        self:getReward(starNum)
                        if pSender.flashNode then
                            pSender:stopAllActions()
                            pSender.flashNode:removeFromParent()
                            pSender.flashNode = nil
                            pSender:setRotation(0)
                        end
                    end
                end
        })
        -- tempCard:setCardData(List)
        tempCard:setAnchorPoint(cc.p(0.5, 0.5))
        tempCard:setPosition(cc.p(0, 20))
        -- tempCard:setGray(self.mBujiInfo[starNum].IsReward)
        tempNode:addChild(tempCard)
        self.mRewardList[starNum].cardList = tempCard

        local needStarNum = XrxsSupplyBaseModel.items[starNum].needIntegral
        if needStarNum <= self.mPlayerInfo.SupplyStar and not self.mBujiInfo[starNum].IsReward then
            ui.setWaveAnimation(tempCard)
        end

        -- 奖励标签
        local tempLabel = ui.newLabel({
            text = TR("{%s} %s", "c_75.png", needStarNum),
            align = TEXT_ALIGN_CENTER,
            color = Enums.Color.eBlack,
            size = 22
        })
        tempLabel:setAnchorPoint(cc.p(0.5, 0.5))
        tempLabel:setPosition(cc.p(0, -45))
        tempNode:addChild(tempLabel)

        -- 已领取图片
        local tempGetPic = ui.newSprite("jc_21.png")
        tempGetPic:setPosition(cc.p(0, 15))
        tempGetPic:setVisible(self.mBujiInfo[starNum].IsReward)
        tempNode:addChild(tempGetPic)

        function tempNode.setRewardStatus(display)
            tempGetPic:setVisible(display)
            -- tempCard:setCardData({
            --     resourceTypeSub = List[1].resourceTypeSub,
            --     modelId = List[1].modelId,
            --     num = List[1].num,
            --     cardShowAttrs = {
            --         CardShowAttr.eBorder,
            --         CardShowAttr.eNum
            --     },
            --     onClickCallback = function()
            --         if not status then
            --             self:getReward(starNum)
            --         end
            --     end
            -- })
            -- tempCard:setGray(status)
        end
    end

    -- 创建条目背景以及奖励实例图片
    for i = 1, 3 do
        local customCell = ccui.Layout:create()
        customCell:setContentSize(cc.size(tempSize.width, tempSize.height))
        local subParent = ui.newScale9Sprite("c_18.png", cc.size(tempSize.width, tempSize.height))
        subParent:setAnchorPoint(cc.p(0.5, 0))
        subParent:setPosition(cc.p(subBgSprite:getContentSize().width * 0.5 - 15, -10))
        customCell:addChild(subParent)
        rewardList:pushBackCustomItem(customCell)
        for j = 1, 3 do
            createItem(subParent, cc.p(90 + (j - 1) * 160, subParent:getContentSize().height * 0.47), (i - 1) * 3 + j)
        end
    end

    -- 计算奖励否领取完
    local tempNotification = true
    local maxRewardNum = nil
    for index, item in ipairs(self.mBujiInfo) do 
        if not item.IsReward then
            tempNotification = false
            maxRewardNum = index
            break
        end
    end

    -- 刷新按钮
    self.mRefreshBtn = ui.newButton({
        normalImage = "c_33.png",
        text = TR("刷新"),
        -- scale = 0.8,
        clickAction = function ()
            -- 免费刷新
            if self.mPlayerInfo.SupplyRefreshCount <= 0 then
                self:requestRefreshBuji()
                return
            end
            
            if Utility.getOwnedGoodsCount(ResourcetypeSub.eDiamond) >= Utility.analysisStrResList(XrxsConfig.items[1].supplyRefreshUse)[1].num then
                -- if self.mPlayerInfo.SupplyRefreshCount <= 0 then
                --     self:requestRefreshBuji()
                -- else
                    -- ui.showFlashView({text = TR("花费%s%s刷新补给", Utility.analysisStrResList(XrxsConfig.items[1].supplyRefreshUse)[1].num, 
                    --     Utility.getGoodsName(ResourcetypeSub.eDiamond))})
                self:requestRefreshBuji()
                -- end
            else
                MsgBoxLayer.addGetDiamondHintLayer()
                -- ui.showFlashView({text = TR("%s不足", Utility.getGoodsName(ResourcetypeSub.eDiamond))})
            end
        end
    })
    self.mRefreshBtn:setAnchorPoint(cc.p(0.5, 0))
    self.mRefreshBtn:setPosition(cc.p(bgSize.width * 0.28, 35))
    -- 奖励领取完了不显示此按钮
    self.mRefreshBtn:setVisible(not tempNotification)
    bgSprite:addChild(self.mRefreshBtn)

    -- 提示“本次刷新免费”
    self.mNoticeLabel = ui.newLabel({
        text = TR("本次免费"),
        color = cc.c3b(0x8f, 0x52, 0x2f),
    })
    self.mNoticeLabel:setAnchorPoint(cc.p(0.5, 0))
    self.mNoticeLabel:setPosition(cc.p(self.mRefreshBtn:getContentSize().width * 0.5, self.mRefreshBtn:getContentSize().height))
    self.mNoticeLabel:setVisible(self.mPlayerInfo.SupplyRefreshCount <= 0)
    self.mRefreshBtn:addChild(self.mNoticeLabel)

    -- 钻石消耗提示
    local tempDiamondCost = Utility.analysisStrResList(XrxsConfig.items[1].supplyRefreshUse)[1].num
    local tempColor = PlayerAttrObj:getPlayerAttr(ResourcetypeSub.eDiamond) >= tempDiamondCost and "#8f522f" or Enums.Color.eRedH
    self.mRefreshMention = ui.newLabel({
        text = string.format("{%s} %s%s", 
            Utility.getResTypeSubImage(ResourcetypeSub.eDiamond),
            tempColor, 
            tempDiamondCost)
    })
    self.mRefreshMention:setAnchorPoint(cc.p(0.5, 0))
    self.mRefreshMention:setPosition(cc.p(self.mRefreshBtn:getContentSize().width * 0.5, self.mRefreshBtn:getContentSize().height))
    self.mRefreshMention:setVisible(self.mPlayerInfo.SupplyRefreshCount > 0)
    self.mRefreshBtn:addChild(self.mRefreshMention)

    -- 领取按钮
    local rewardBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("一键领取"),
        clickAction = function(pSender)
            -- -- 计算奖励否领取完
            -- local notification = true
            -- local rewardIndex = 0
            -- for index, item in ipairs(self.mBujiInfo) do 
            --     if not item.IsReward then
            --         rewardIndex = index
            --         notification = false
            --         break
            --     end
            -- end

            -- if notification then
            --     ui.showFlashView(TR("已领取完所有奖励！！！"))
            --     -- self:setResetBtn(true)
            -- else
            --     self:getReward(rewardIndex)
            -- end
            self:getRewardOneKey()
        end
    })
    rewardBtn:setAnchorPoint(cc.p(0.5, 0))
    rewardBtn:setPosition(cc.p(bgSize.width * 0.73, 35))
    -- 奖励领取完了不显示此按钮
    rewardBtn:setVisible(not tempNotification)
    if not tempNotification and maxRewardNum then
        local needStar = XrxsSupplyBaseModel.items[maxRewardNum].needIntegral
        if self.mPlayerInfo.SupplyStar < needStar then
            rewardBtn:setEnabled(false)
        end
    end
    bgSprite:addChild(rewardBtn)
    -- rewardBtn:setScale(0.9)
    self.mRewardBtn = rewardBtn

    -- 领取按钮注册小红点
    local redDotModuleList = {
        {
            moduleId = ModuleSub.eXrxsSupply,
            btn = rewardBtn,
        },
    }

    for index, item in pairs(redDotModuleList) do
        local function dealRedDotVisible(redDotSprite) 
            local redDotData = RedDotInfoObj:isValid(item.moduleId)
            redDotSprite:setVisible(redDotData)
        end
        ui.createAutoBubble({refreshFunc = dealRedDotVisible, eventName = RedDotInfoObj:getEvents(item.moduleId), parent = item.btn})
    end

    -- 重置按钮
    -- self.mResetBtn = ui.newButton({
    --     normalImage = "c_28.png",
    --     position = cc.p(bgSize.width * 0.5 - 10, 55),
    --     text = TR("重置奖励"),
    --     clickAction = function()
    --         -- 请求服务器重置奖励
    --         self:requestRefreshBuji()
    --     end
    -- })

    -- -- 奖励领取完了才显示此按钮
    -- self.mResetBtn:setVisible(tempNotification)
    -- bgSprite:addChild(self.mResetBtn)
end

-- 设置重置按钮
function GGZJCompensationLayer:setResetBtn(disPlayResetBtn)
    self.mRefreshBtn:setVisible(not disPlayResetBtn)
    self.mRewardBtn:setVisible(not disPlayResetBtn)
    -- self.mResetBtn:setVisible(disPlayResetBtn)
end

function GGZJCompensationLayer:requestBujiInfo(parent)
    HttpClient:request({
        moduleName = "XrxsInfo",
        methodName = "GetBujiInfo",
        callback = function(response)
            if response.Value == nil or response.Status ~= 0 then
                ui.showFlashView(TR("刷新补给信息失败！！！"))
                return 
            end
            self.mBujiInfo = response.Value.NodeInfo
            self.mPlayerInfo.SupplyRefreshCount = response.Value.SupplyRefreshCount
            self:createCompensationLayer(parent)

             -- 计算奖励状态
            local notification = true
            for index, item in ipairs(self.mBujiInfo) do 
                if not item.IsReward then
                    notification = false
                    break
                end
            end

            -- 重置奖励状态
            self:setResetBtn(notification)
            if notification then
                self:requestRefreshBuji()
            end
        end
    })
end

-- 请求服务器领取补给奖励
function GGZJCompensationLayer:getReward(starIndex)
    if not self.mBujiInfo.IsReward then
        if self.mPlayerInfo.SupplyStar >= XrxsSupplyBaseModel.items[starIndex].needIntegral then
            HttpClient:request({
                moduleName = "XrxsInfo",
                methodName = "RewadBuji",
                svrMethodData = {starIndex},
                callback = function(response)
                    if response.Value == nil or response.Status ~= 0 then
                        return 
                    end
                    self.mBujiInfo = response.Value.NodeInfo
                    self.mPlayerInfo.SupplyStar = response.Value.Info.SupplyStar
                    self.mRewardList[starIndex].parent.setRewardStatus(response.Value.NodeInfo[starIndex].IsReward)

                    -- 刷新可用星数
                    self.mPreAccessLabel:setString(TR("当前赏金点: #d17b00{%s} %s", "c_75.png", self.mPlayerInfo.SupplyStar))
                    ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)

                    -- 计算奖励状态
                    local notification = true
                    for index, item in ipairs(self.mBujiInfo) do 
                        if not item.IsReward then
                            notification = false
                            break
                        end
                    end

                    -- 重置奖励状态
                    self:setResetBtn(notification)
                    if notification then
                        self:requestRefreshBuji()
                    end
                end
            })
        else
            ui.showFlashView({
            text = TR("所需赏金点不足！！！")
        })
        end
    else
        ui.showFlashView({
            text = TR("已经领取过该奖励！！！")
        })
    end
end

-- 请求服务器一键领取补给奖励
function GGZJCompensationLayer:getRewardOneKey()
    HttpClient:request({
        moduleName = "XrxsInfo",
        methodName = "RewadAllBuji",
        svrMethodData = {},
        callback = function(response)
            if response.Value == nil or response.Status ~= 0 then
                return 
            end

            self.mBujiInfo = response.Value.NodeInfo
            self.mPlayerInfo.SupplyStar = response.Value.Info.SupplyStar
            -- self.mRewardList[starIndex].parent.setRewardStatus(response.Value.NodeInfo[starIndex].IsReward)
            
            for i,v in ipairs(self.mRewardList) do
                v.parent.setRewardStatus(response.Value.NodeInfo[i].IsReward)
                if not tolua.isnull(v.cardList.flashNode) then
                    v.cardList:stopAllActions()
                    v.cardList.flashNode:removeFromParent()
                    v.cardList.flashNode = nil
                    v.cardList:setRotation(0)
                end
            end
            -- 刷新可用星数
            self.mPreAccessLabel:setString(TR("当前赏金点: #d17b00{%s} %s", "c_75.png", self.mPlayerInfo.SupplyStar))
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)

            -- 计算奖励状态
            local notification = true
            local maxRewardNum = nil
            for index, item in ipairs(self.mBujiInfo) do 
                if not item.IsReward then
                    notification = false
                    maxRewardNum = index
                    break
                end
            end
            if not notification and maxRewardNum then
                local needStar = XrxsSupplyBaseModel.items[maxRewardNum].needIntegral
                if self.mPlayerInfo.SupplyStar < needStar then
                    self.mRewardBtn:setEnabled(false)
                end
            end

            -- 重置奖励状态
            self:setResetBtn(notification)
            if notification then
                self:requestRefreshBuji()
            end
        end
    })

end

-- 请求服务器刷新补给奖励
function GGZJCompensationLayer:requestRefreshBuji()
    HttpClient:request({
        moduleName = "XrxsInfo",
        methodName = "RefreshBuji",
        callback = function(response)
            if response.Value == nil or response.Status ~= 0 then
                return 
            end

            for i,v in ipairs(self.mBujiInfo) do
                if not tolua.isnull(self.mRewardList[i].cardList.flashNode) then
                    self.mRewardList[i].cardList:stopAllActions()
                    self.mRewardList[i].cardList.flashNode:removeFromParent()
                    self.mRewardList[i].cardList.flashNode = nil
                    self.mRewardList[i].cardList:setRotation(0)
                end
            end
            self.mBujiInfo = response.Value.NodeInfo
            self.mPlayerInfo = response.Value.Info
            self.mRefreshMention:setVisible(self.mPlayerInfo.SupplyRefreshCount > 0)
            self.mNoticeLabel:setVisible(self.mPlayerInfo.SupplyRefreshCount <= 0)
            for i, v in ipairs(self.mBujiInfo) do
                local reward = Utility.analysisStrResList(v.RewardResource)[1]
                self.mRewardList[i].cardList:setCardData({
                    resourceTypeSub = reward.resourceTypeSub,
                    modelId = reward.modelId,
                    num = reward.num,
                    cardShowAttrs = {
                        CardShowAttr.eBorder,
                        CardShowAttr.eNum
                    },
                    onClickCallback = function(pSender)
                        if not self.mBujiInfo[i].IsReward then
                            self:getReward(i)
                            if pSender.flashNode then
                                pSender:stopAllActions()
                                pSender.flashNode:removeFromParent()
                                pSender.flashNode = nil
                                pSender:setRotation(0)
                            end
                        end
                    end

                })

                local needStarNum = XrxsSupplyBaseModel.items[i].needIntegral
                if needStarNum <= self.mPlayerInfo.SupplyStar and not self.mBujiInfo[i].IsReward then
                    ui.setWaveAnimation(self.mRewardList[i].cardList)
                end
                -- self.mRewardList[i].cardList:setGray(self.mBujiInfo[i].IsReward)
            end

            -- 刷新赏金点显示
            self.mPreAccessLabel:setString(TR("当前赏金点: #d17b00{%s} %s", "c_75.png", self.mPlayerInfo.SupplyStar))

            -- 刷新钻石颜色
            local tempDiamondCost = Utility.analysisStrResList(XrxsConfig.items[1].supplyRefreshUse)[1].num
            local tempColor = PlayerAttrObj:getPlayerAttr(ResourcetypeSub.eDiamond) >= tempDiamondCost and Enums.Color.eBlackH or Enums.Color.eRedH
            self.mRefreshMention:setString(string.format("{%s} %s%s", 
                    Utility.getResTypeSubImage(ResourcetypeSub.eDiamond),
                    tempColor, 
                    tempDiamondCost)
            )

            -- 刷新领取状态
            for index, item in pairs(self.mRewardList) do 
                item.parent.setRewardStatus(self.mBujiInfo[index].IsReward)
            end

            -- 计算奖励状态
            local notification = true
            for index, item in ipairs(self.mBujiInfo) do 
                if not item.IsReward then
                    notification = false
                    break
                end
            end

            -- 重置奖励状态
            self:setResetBtn(notification)
        end
    })
end

return GGZJCompensationLayer
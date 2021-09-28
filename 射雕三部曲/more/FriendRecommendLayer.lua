--[[
    文件名：FriendRecommendLayer.lua
    描述：推荐好友
    创建人：cchenzhong
    创建时间：2016.6.15
    修改人：wukun
    修改时间：2016.08.30
-- ]]

local FriendRecommendLayer = class("FriendRecommendLayer", function(params)
    return display.newLayer()
end)

--[[
    参数 params ：无参数
]]
function FriendRecommendLayer:ctor()
    -- 初始化页面
    self:initUI()
    -- 初始化数据(获取推荐好友玩家信息列表)
    self:requestGetRecommendFriendList()
end

-- 初始化页面控件
function FriendRecommendLayer:initUI()
    -- 输入框
    local editBox = ui.newEditBox({
        image = "c_17.png",
        size = cc.size(300, 35),
        color = Enums.Color.ePurple,
    })
    editBox:setPlaceHolder(TR("请输入好友的名字"))
    editBox:setAnchorPoint(cc.p(0, 0.5))
    editBox:setPosition(cc.p(50, 910))
    self:addChild(editBox)

    -- 搜索
    local searchButton = ui.newButton({
        normalImage = "c_28.png",
        position = cc.p(545, 910),
        text = TR("搜索"),
        clickAction = function ()
            local name = editBox:getText()
            self:requestPlayerSearch(name)
        end
    })
    self:addChild(searchButton)

    -- 更换
    local changeButton = ui.newButton({
            normalImage = "c_28.png",
            position = cc.p(220 , 140),
            text = TR("更 换"),
            clickAction = function (pSender)
               self:requestGetRecommendFriendList()
            end
        })
    self:addChild(changeButton)

    -- 全部结交
    local wholeButton = ui.newButton({
            normalImage = "c_28.png",
            position = cc.p(430, 140),
            text = TR("全部结交"),
            clickAction = function (pSender)
                local list = {}
                for _, v in ipairs(self.recommendFriendList) do
                    table.insert(list, v.PlayerId)
                end
                if next(list) ~= nil then
                   self:requestBatchFriendApply(list)
                else
                    ui.showFlashView(TR("当前没有可以结交的好友"))
                end
            end
        })
    self:addChild(wholeButton)

    -- 创建推荐好友的listView
    self.listView = ccui.ListView:create()
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setContentSize(cc.size(604, 680))
    self.listView:setGravity(ccui.ListViewGravity.centerVertical) 
    self.listView:setAnchorPoint(cc.p(0.5, 1))
    self.listView:setBounceEnabled(true)
    self.listView:setPosition(cc.p(320, 870))
    self:addChild(self.listView)
end

-- 刷新数据
function FriendRecommendLayer:refreshLayer( )
    if self.listView then
        self.listView:removeAllItems()
    end
    -- 刷新ListView
    for i, v in ipairs(self.recommendFriendList) do
        self.listView:pushBackCustomItem(self:createHeadView(i, v))
    end
end

-- 添加推荐好友cell
function FriendRecommendLayer:createHeadView(index)
    -- 创建layout
    local customItem = ccui.Layout:create()
    customItem:setContentSize(cc.size(604, 130))

    local cellBg = ui.newScale9Sprite("c_18.png", cc.size(594,125))
    cellBg:setPosition(302, 65)
    customItem:addChild(cellBg)

    -- 头像
    local friendData = self.recommendFriendList[index]
    local headSprite = CardNode.createCardNode({
        resourceTypeSub = ResourcetypeSub.eHero,
        modelId = friendData.HeadImageId > 0 and friendData.HeadImageId or 12010001, 
        fashionModelID = friendData.FashionModelId,
        IllusionModelId = friendData.IllusionModelId,
        pvpInterLv = friendData.DesignationId,
        cardShowAttrs = {CardShowAttr.eBorder},
        onClickCallback = function()
            Utility.showPlayerTeam(friendData.PlayerId)
            local tempStr = "more.FriendLayer"
            local tempData = LayerManager.getRestoreData(tempStr) or {}
            tempData.pageType = Enums.FriendPageType.eRecommend
            LayerManager.setRestoreData(tempStr, tempData)
        end
    })
    headSprite:setPosition(cc.p(60, 60))
    cellBg:addChild(headSprite)

    -- 名字
    local nameLabel = ui.newLabel({
        text = friendData.Name,
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
        text = valueView,
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

    -- 结交
    local makeButton = ui.newButton({
            normalImage = "c_28.png",
            position = cc.p(525, 58),
            text = TR("结交"),
            clickAction = function (pSender)
                local btnInfos = {
                    {
                        text = TR("发送"),
                        clickAction = function(layerObj, btnObj)
                            -- 获取发送的内容
                            local message = self.mEditBox:getText()
                            self:requestFriendApply(friendData.PlayerId, message)
                        end,
                    },
                    {
                        text = TR("关闭"),
                        clickAction = function(layerObj, btnObj)
                            LayerManager.removeLayer(self.frilayer)
                        end,
                    },
                }
                local tempData = {
                    bgSize = cc.size(600, 500),
                    title = TR("好友请求"),
                    msgText = "",
                    closeBtnInfo = {},
                    btnInfos = btnInfos,
                    notNeedBlack = true,
                    DIYUiCallback = function(layer, layerBgSprite, layerBgSize)
                        -- 发送内容给xxx(名字)
                        local sendLabel = ui.newLabel({
                            text = TR("发送给%s的请求:", friendData.Name),
                            color = Enums.Color.eBlack
                        })
                        sendLabel:setAnchorPoint(cc.p(0, 0.5))
                        sendLabel:setPosition(30, 418)
                        layerBgSprite:addChild(sendLabel)

                        -- 输入框
                        self.mEditBox = ui.newEditBox({
                            image = "c_17.png",
                            size = cc.size(520, 295),
                            fontSize = 30 * Adapter.MinScale,
                            fontColor = Enums.Color.eNormalWhite,
                            multiLines = true,
                        })
                        self.mEditBox:setText(TR("久仰大侠，愿能与大侠结为好友，共闯江湖！"))
                        self.mEditBox:setPlaceholderFontSize(30)
                        self.mEditBox:setPosition(cc.p(297, 251))
                        layerBgSprite:addChild(self.mEditBox)
                    end,
                }
                self.frilayer = LayerManager.addLayer({
                    name = "commonLayer.MsgBoxLayer",
                    data = tempData,
                    cleanUp = false,
                })
            end
        })
    cellBg:addChild(makeButton)
    return customItem
end

-----------------网络相关--------------
-- 获取推荐好友玩家信息列表
function FriendRecommendLayer:requestGetRecommendFriendList()
    HttpClient:request({
        moduleName = "Friend",
        methodName = "GetRecommendFriendList",
        svrMethodData = {9},
        callbackNode = self,
        callback = function (response)
            if not response or response.Status ~= 0 then
                return
            end
            -- 玩家好友列表
            self.recommendFriendList = response.Value
            self:refreshLayer()
        end
    })
end

-- 玩家搜索
function FriendRecommendLayer:requestPlayerSearch(name)
    HttpClient:request({
        moduleName = "Friend",
        methodName = "PlayerSearch",
        svrMethodData = {name},
        callbackNode = self,
        callback = function (response)
            if not response or response.Status ~= 0 then
                return
            end
            -- 玩家好友列表
            if #response.Value > 0 then 
                self.recommendFriendList = response.Value
                self:refreshLayer()
            else     
                ui.showFlashView(TR("没搜索到相关好友"))
            end
        end
    })
end

-- 批量申请好友
function FriendRecommendLayer:requestBatchFriendApply(list)
    HttpClient:request({
        moduleName = "FriendMessage",
        methodName = "BatchFriendApply",
        svrMethodData = {list},
        callbackNode = self,
        callback = function (response)
            if not response or response.Status ~= 0 then
                return
            end
            ui.showFlashView(TR("批量发送好友请求成功"))
            -- 重新获取数据刷新列表
            self:requestGetRecommendFriendList()
        end
    })
end

-- 申请好友
--[[
    message  申请好友发送的消息内容
]]
function FriendRecommendLayer:requestFriendApply(playerId, message)
     HttpClient:request({
        moduleName = "FriendMessage",
        methodName = "FriendApply",
        svrMethodData = {playerId, message},
        callbackNode = self,
        callback = function (response)
            if not response or response.Status ~= 0 then
                return
            end
            ui.showFlashView(TR("发送好友请求成功"))
            -- 离开该页面
            LayerManager.removeLayer(self.frilayer)
        end
    })
end

return FriendRecommendLayer
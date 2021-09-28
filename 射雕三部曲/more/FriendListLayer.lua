--[[
    文件名：FriendListLayer.lua
    描述：好友列表
    创建人：chenzhong
    创建时间：2016.6.15
    修改人：wukun
    时间：2016.08.30
-- ]]

local FriendListLayer = class("FriendListLayer", function(params)
    return display.newLayer()
end)

function FriendListLayer:ctor()
    -- 初始化控件
    self:initUI()
    -- 初始化数据（从服务器获取玩家好友信息列表）
    self:requestGetFriendList()
end

-- 初始化页面控件
function FriendListLayer:initUI()
    -- 好友数量Label

    local numberBgSprite = ui.newScale9Sprite("gd_15.png", cc.size(137, 30))
    numberBgSprite:setPosition(205, 145)
    self:addChild(numberBgSprite)


    local friendLabel = ui.newLabel({
        text = TR("好友数量: "),
        color = cc.c3b(0x46, 0x22, 0x0d),
        })
    friendLabel:setPosition(80, 145)
    self:addChild(friendLabel)

    self.friendNumber = ui.newLabel({
        --scale9Size = cc.size(89, 36),
        text = "",
    })
    self.friendNumber:setPosition(195, 145)
    self:addChild(self.friendNumber)

    -- 一键赠送
    self.getButton = ui.newButton({
        normalImage = "c_28.png",
        position = cc.p(520, 145),
        text = TR("一键赠送"),
        clickAction = function (pSender)
        end
    })
    self:addChild(self.getButton)

    -- 创建显示好友的listView
    self.listView = ccui.ListView:create()
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setContentSize(cc.size(606, 765))
    self.listView:setGravity(ccui.ListViewGravity.centerVertical)
    self.listView:setAnchorPoint(cc.p(0.5, 1))
    self.listView:setBounceEnabled(true)
    self.listView:setPosition(cc.p(320, 950))
    self:addChild(self.listView)
end

-- 刷新数据
function FriendListLayer:refreshLayer()
    -- 清空原来的列表
    if self.listView then
        self.listView:removeAllItems()
    end
    -- 刷新好友数量
    local currLv = PlayerAttrObj:getPlayerAttrByName("Lv")
    local friendCount = table.maxn(self.friendList)
    self.friendNumber:setString(TR("%d/%d", friendCount, PlayerLvRelation.items[currLv].friendMax))

    -- 刷新好友列表
    -- 添加客服
    --self.listView:pushBacklayout(self:GMHeadView())
    -- 是否可以一键赠送
    local canOneKey = false
    -- 好友排序（按离线时间排序）
    table.sort(self.friendList, function (friendData1, friendData2)
    	return friendData1.OutTime < friendData2.OutTime
    end)
    -- 添加好友数据
    for i, v in ipairs(self.friendList) do
        if v.CanSendSTA then canOneKey = true end
        self.listView:pushBackCustomItem(self:createFriendView(i, v))
    end

    -- 刷新一键赠送
    self.getButton:setClickAction(function()
         if next(self.friendList) ~= nil then
            --批量赠送所有好友气力
            self:requestBatchSendFriendSTA()
        else
            ui.showFlashView(TR("您当前没有好友"))
        end
    end)
    self.getButton:setEnabled(canOneKey)
end

-- 添加客服cell
function FriendListLayer:GMHeadView()
    -- 创建layout
    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(584, 130))

    local cellBg = ui.newScale9Sprite("c_18.png", cc.size(584,120))
    cellBg:setPosition(302, 60)
    layout:addChild(cellBg)

    -- 头像
    local headSprite1 = ui.newSprite("c_07.png")
    headSprite1:setPosition(60, 55)
    cellBg:addChild(headSprite1)

    local headSprite2 = ui.newSprite("hy_04.png")
    headSprite2:setPosition(60, 55)
    cellBg:addChild(headSprite2)

    -- 名字
    local nameSprite = ui.newSprite("hy_1.png")
    nameSprite:setAnchorPoint(cc.p(0, 0.5))
    nameSprite:setPosition(130, 75)
    cellBg:addChild(nameSprite)

    -- 工作时间
    local workTimeLabel = ui.newLabel({
        text = TR("工作时间: 10:00-18:00"),
        size = 20,
        color = Enums.Color.eBlack,
    })
    workTimeLabel:setAnchorPoint(cc.p(0, 0.5))
    workTimeLabel:setPosition(cc.p(130 , 35))
    cellBg:addChild(workTimeLabel)

    -- 联系
    local communicationButton = ui.newButton({
        normalImage = "c_28.png",
        position = cc.p(510, 60),
        text = TR("联系"),
        clickAction = function (pSender)
            local btnInfos = {
                {
                    text = TR("BUG解答"),
                    position = cc.p(85, 50),
                    clickAction = function(layerObj, btnObj)
                        ui.showFlashView(TR("暂未开放"))
                    end,
                },
                {
                    text = TR("投诉建议"),
                    position = cc.p(261, 50),
                    clickAction = function(layerObj, btnObj)
                        ui.showFlashView(TR("暂未开放"))
                    end,
                },
                {
                    text = TR("帮助"),
                    position = cc.p(435, 50),
                    clickAction = function(layerObj, btnObj)
                        --LayerManager.addLayer({
                        --    name = "more.StrategyLayer",
                        --    cleanUp = false,
                        --})
                        ui.showFlashView(TR("暂未开放"))
                    end,
                },
            }
            local tempData = {
                bgSize = cc.size(520, 400),
                title = TR("客服好友"),
                msgText = "",
                closeBtnInfo = {},
                btnInfos = btnInfos,
                DIYUiCallback = function(layer, layerBgSprite, layerBgSize)
                    -- 头像
                    local headSprite1 = ui.newSprite("c_07.png")
                    headSprite1:setPosition(260, 200 + 35)
                    layerBgSprite:addChild(headSprite1)

                    local headSprite2 = ui.newSprite("hy_04.png")
                    headSprite2:setPosition(260, 200 + 35)
                    layerBgSprite:addChild(headSprite2)

                    -- 名字
                    local nameSprite = ui.newSprite("hy_1.png")
                    nameSprite:setPosition(260, 200 - 35)
                    layerBgSprite:addChild(nameSprite)
                end,
            }
            local tempMsgBox = LayerManager.addLayer({
                name = "commonLayer.MsgBoxLayer",
                data = tempData,
                cleanUp = false,
            })
            for k,v in pairs(tempMsgBox.mBottomBtns) do
                v:setScale(0.9)
            end
        end
    })
    cellBg:addChild(communicationButton)
    return layout
end

-- 添加好友cell
function FriendListLayer:createFriendView(index)
    -- 创建layout
    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(584, 126))

    local cellBg = ui.newScale9Sprite("c_18.png", cc.size(584,120))
    cellBg:setPosition(302, 63)
    layout:addChild(cellBg)

    -- 头像
    local friendData = self.friendList[index]
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
            local tempData = LayerManager.getRestoreData(tempStr) or {}
            tempData.pageType = Enums.FriendPageType.eList
            LayerManager.setRestoreData(tempStr, tempData)
        end
    })
    headSprite:setPosition(cc.p(60, 60))
    cellBg:addChild(headSprite)


    --状态
    if friendData.IsActive == true then
        local stateSprite = ui.newSprite("c_42.png")
        stateSprite:setPosition(450, 75)
        stateSprite:setAnchorPoint(cc.p(0, 0.5))
        cellBg:addChild(stateSprite)
    else
        local tempStr = string.utf8sub(MqTime.toDownFormat(friendData.OutTime), 1, -2)
        local stateValueLabel = ui.newLabel({
            text = TR("【离线%s】", tempStr),
            size = 20,
            x = 450,
            y = 75,
            color = Enums.Color.eRed,
        })
        stateValueLabel:setAnchorPoint(cc.p(0, 0.5))
        cellBg:addChild(stateValueLabel)
    end

    -- 名字
    local nameLabel = ui.newLabel({
        text = friendData.Name,
        size = 24,
        color = Enums.Color.eBlack
    })
    nameLabel:setAnchorPoint(cc.p(0, 0.5))
    nameLabel:setPosition(130, 85)
    cellBg:addChild(nameLabel)

    -- 战斗力
    local valueView = Utility.numberFapWithUnit(friendData.FAP)
    local valueLabel = ui.newLabel({
        text = TR("%s战力:%s%s", "#46220d", "#d17b00", valueView),
        size = 24,
    })
    valueLabel:setAnchorPoint(cc.p(0, 0.5))
    valueLabel:setPosition(130, 28)
    cellBg:addChild(valueLabel)

    -- 等级
    local vipView = friendData.Lv
    local vipLabel = ui.newLabel({
        text = TR("等级:%s",vipView),
        size = 24,
        color = Enums.Color.eBlack
    })
    vipLabel:setAnchorPoint(cc.p(0, 0.5))
    vipLabel:setPosition(130, 55)
    cellBg:addChild(vipLabel)

    --VIP等级
    local vipNode = ui.createVipNode(friendData.Vip)
    vipNode:setPosition(230, 58)
    cellBg:addChild(vipNode)

    -- 上线通知
    local friendPlayerId = friendData.PlayerId
    local checkBox = ui.newCheckbox({
            normalImage = "c_60.png",
            selectImage = "c_61.png",
            imageScale = 1.5,
            text = TR("上线通知"),
            textColor = cc.c3b(0x46, 0x22, 0x0d),
            callback = function(isSelect)
                if isSelect then
                    OnlineNotifyObj:addOnlineNotify(friendPlayerId)
                else
                    OnlineNotifyObj:deleteOnlineNotify(friendPlayerId)
                end
            end
        })
    checkBox:setAnchorPoint(cc.p(0, 0.5))
    checkBox:setPosition(320, 35)
    checkBox:setCheckState(OnlineNotifyObj:isOnlineNotifyPlayer(friendPlayerId))
    layout:addChild(checkBox)

    --操作按钮
    local initRotation = 0

    layout.sjxBtn = ui.newButton({
        normalImage = "c_43.png",
        position = cc.p(525, 40),
        clickAction = function (pSender)
            -- 先删除并且纪录位置
            local scrollPos = self.listView:getInnerContainerPosition()
            if self.isExpanded then
                self.listView:removeItem(self.expandIndex + 1)
            end

            local index = self.listView:getIndex(layout)

            if self.expandIndex == index then
                self.isExpanded = false--如果刷新了滑动列表贼不需要删除插入项，反之删除
                self.expandIndex = nil--上一次选择的的items的tag值
            else
                self.listView:insertCustomItem(self:createCell(self.friendList[index + 1]), index + 1)
                self.expandIndex = index
                self.isExpanded = true

                --如果在最后一个,滑动到底部
                if listIndex == table.nums(self.listView:getItems()) - 1 then
                    self.listView:jumpToBottom()
                end

            end

            -- -- 重新设置，需要延时才有效果
            Utility.performWithDelay(self, function()
                self.listView:setInnerContainerPosition(scrollPos)
            end,0.1)
        end
    })
    layout:addChild(layout.sjxBtn)
    
    --QQ登录特殊标识
    if PlayerAttrObj:getPlayerAttrByName("LoginType") == 1 or PlayerAttrObj:getPlayerAttrByName("LoginType") == 2 then
        if friendData.LoginType == 1 or friendData.LoginType == 2 then
            local qqSprite = ui.newSprite("qq_08.png")
            qqSprite:setPosition(400, 85)
            layout:addChild(qqSprite)
        end
    end

    return layout
end

--创建展开cell
--[[
    params:
    table playerdata:
    {
        Id:玩家Id
        Name:玩家名称
        Lv:玩家等级
        PostId:权限Id
    }
]]
function FriendListLayer:createCell(playerdata)
    --容器
    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(584, 100))

    local backImageSprite = ui.newScale9Sprite("bp_22.png", cc.size(584, 100))
    backImageSprite:setPosition(cc.p(300, 55))
    layout:addChild(backImageSprite)

    local btnData = {
    	[1] = {
            text = TR("送气力"),
            normalImage = "c_28.png",
            position = cc.p(100, 50),
            isNeed = true,
            clickAction = function (pSender)
                HttpClient:request({
                    moduleName = "FriendMessage",
                    methodName = "SendFriendSTA",
                    svrMethodData = {playerdata.PlayerId},
                    callbackNode = self,
                    callback = function (response)
                        if not response or response.Status ~= 0 then
                            return
                        end
                        self.isExpanded = false
                        self.expandIndex = nil
                        -- 显示飘窗
                        ui.showFlashView(TR("赠送气力成功"))
                        -- 重新获取数据并刷新列表
                        self:requestGetFriendList()
                    end
                })
            end
    	},
        [2] = {
            text = TR("看阵容"),
            normalImage = "c_28.png",
            position = cc.p(290, 50),
            isNeed = true,
            clickAction = function(pSender)
                Utility.showPlayerTeam(playerdata.PlayerId)
            end,
        },
        [3] = {
            text = TR("删好友"),
            normalImage = "c_28.png",
            position = cc.p(484, 50),
            isNeed = true,
            clickAction = function(pSender)
                self.isExpanded = false
                self.expandIndex = nil
                -- 删除好友后重新刷新好友列表
                MsgBoxLayer.addOKLayer(
                    TR("是否确认删除好友?"),
                    TR("提示"),
                    {{
                        text = TR("确定"),
                        textColor = Enums.Color.eWhite,
                        clickAction = function(layerObj, btnObj)
                            self:requestDeleteFriend(playerdata.PlayerId)
                            layerObj:removeFromParent(true)
                        end
                    }},
                    {}
                )
            end,
        },
	}
    
    if PlayerAttrObj:getPlayerAttrByName("LoginType") == 1 or PlayerAttrObj:getPlayerAttrByName("LoginType") == 2 then
        if playerdata.LoginType == 1 or playerdata.LoginType == 2 then
            table.insert(btnData, {
                text = TR("+QQ好友"),
                normalImage = "c_33.png",
                position = cc.p(484, 50),
                isNeed = true,
                clickAction = function(pSender)
                    local name = PlayerAttrObj:getPlayerAttrByName("PlayerName")
                    local tempLabel = TR("大侠你好，我是你在《射雕三部曲》手游中的好友：%s", name) --验证消息
                    local tempMessage = TR("射雕三部曲~%s", playerdata.Name)                            --备注信息
                    IPlatform:getInstance():invoke("AddQQFriend", cjson.encode({openId = playerdata.OpenId, label = tempMessage, message = tempLabel}), function() end)
                end,
            })
            for i,v in ipairs(btnData) do
                v.position = cc.p(80 + (i - 1) * 140, 50)
            end
        end 
    end

	local posxI = 1 --用于计算位置的一个变量
	for i,v in ipairs(btnData) do
		local useBtn = ui.newButton(v)
		backImageSprite:addChild(useBtn)
	end

    return layout
end

function FriendListLayer:leaveMessage(index)
    local btnInfos = {
                {
                    text = TR("发送"),
                    clickAction = function(layerObj, btnObj)
                        -- 获取发送的内容
                        local message = self.mEditBox:getText()
                        if message ~= "" then
                            -- 发送消息
                            self:requestSendFriendMessage(self.friendList[index].PlayerId, message)
                            self.mEditBox:setText("")
                        else
                            ui.showFlashView(TR("输入内容为空"))
                        end
                    end,
                },
                {
                    text = TR("关闭"),
                    clickAction = function(layerObj, btnObj)
                        LayerManager.removeLayer(self.messagelayer)
                    end,
                },
            }
            local tempData = {
                bgSize = cc.size(600, 500),
                title = TR("好友留言"),
                msgText = "",
                closeBtnInfo = {},
                btnInfos = btnInfos,
                notNeedBlack = true,
                DIYUiCallback = function(layer, layerBgSprite, layerBgSize)
                    --发送内容给xxx(名字)
                    local sendLabel = ui.newLabel({
                        text = TR("发送给%s的留言:", self.friendList[index].Name),
                        color = Enums.Color.eBlack
                    })
                    sendLabel:setAnchorPoint(cc.p(0, 0.5))
                    sendLabel:setPosition(30, 418)
                    layerBgSprite:addChild(sendLabel)

                    -- 输入框
                    self.mEditBox = ui.newEditBox({
                        image = "c_17.png",
                        size = cc.size(530, 295),
                        fontSize = 30 * Adapter.MinScale,
                        multiLines = true,
                        fontColor = Enums.Color.eBlack,
                    })
                    self.mEditBox:setPlaceHolder(TR("请在这里输入内容"))
                    self.mEditBox:setPlaceholderFontSize(30)
                    self.mEditBox:setPosition(cc.p(297, 251))
                    layerBgSprite:addChild(self.mEditBox)
                end,
            }
            self.messagelayer = LayerManager.addLayer({
                name = "commonLayer.MsgBoxLayer",
                data = tempData,
                cleanUp = false,
            })
end

--------------------网络相关-----------------
-- 获取玩家好友信息列表
function FriendListLayer:requestGetFriendList()
    FriendObj:requestGetFriendList(function(friendList)
        self.friendList = friendList
        self:refreshLayer()
    end)
end

-- 重新获取数据并刷新列表
function FriendListLayer:requestFriendList()
    FriendObj:clearFriendList()
    FriendObj:requestGetFriendList(function(friendList)
        self.friendList = friendList
        self:refreshLayer()
    end)
end

-- 批量赠送所有好友气力
function FriendListLayer:requestBatchSendFriendSTA()
    HttpClient:request({
        moduleName = "FriendMessage",
        methodName = "BatchSendFriendSTA",
        svrMethodData = {},
        callbackNode = self,
        callback = function (response)
            if not response or response.Status ~= 0 then
                return
            end
            ui.showFlashView(TR("一键赠送成功"))
            -- 重新获取数据并刷新列表
            self:requestFriendList()
        end
    })
end

-- 删除好友
function FriendListLayer:requestDeleteFriend(playerId)
    FriendObj:requestDeleteFriend(playerId, function(response)
        ui.showFlashView(TR("删除好友成功"))
        LayerManager.removeLayer(self.commlayer)
        self:requestGetFriendList()
    end)
end

-- 发送好友留言
--[[
    playerId   玩家ID
    message    留言的内容
]]
function FriendListLayer:requestSendFriendMessage(playerId, message)
    HttpClient:request({
        moduleName = "FriendMessage",
        methodName = "SendFriendMessage",
        svrMethodData = {playerId, message},
        callback = function (response)
            --dump(response, "res")
            if not response or response.Status ~= 0 then
                return
            end
            ui.showFlashView(TR("发送消息成功"))
            --离开该页面
            --LayerManager.removeLayer(self)
        end
    })
end

return FriendListLayer

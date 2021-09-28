
--[[
    文件名: ChatBtnLayer.lua
    描述: 聊天按钮
    创建人: 何光辉
    创建时间: 2017.08.15
-- ]]

ChatBtnLayer = {channe = Enums.ChatChanne.eWorld, bubbleVisble = true}

function ChatBtnLayer:create()
    if ChatBtnLayer.btnParentNode then
        return
    end

    -- 当前主场景
    local mainScene = LayerManager.getMainScene()
    local parent = ui.newStdLayer()
    mainScene:addChild(parent, Enums.ZOrderType.eChat)
    -- 添加Node
    local btnParentNode = ui.newButton({
        normalImage = "c_83.png",
    })
    btnParentNode:setPosition(cc.p(50, 210))
    parent:addChild(btnParentNode)

    -- 创建大侠之路按钮
    local roadBtn = ui.newButton({
        normalImage = "dxzl_01.png",
    })
    roadBtn:setPosition(cc.p(0, 46))
    roadBtn:setVisible(false)
    btnParentNode:addChild(roadBtn)

    -- 创建大侠之路的提示特效
    ui.newEffect({
        parent = roadBtn,
        effectName = "effect_ui_xinshouyindao",
        animation  = "dianji",
        position = cc.p(roadBtn:getContentSize().width*0.5, roadBtn:getContentSize().height*0.5),
        loop = true,
    })

    -- 创建大侠之路直接跳转按钮
    local roadGoBtn = ui.newButton({
        normalImage = "dxzl_07.png",
        size = cc.size(200, 100),
        clickAction = function ()
            if not ModuleInfoObj:moduleIsOpen(ModuleSub.eMainTask, true) then
                return
            end

            -- 引导时也不可点击
            local _, _, eventID = Guide.manager:getGuideInfo()
            if eventID then return end

            -- 战斗中不可跳转
            if LayerManager.getTopCleanLayerName() == "ComBattle.BattleLayer" then
                return
            end

            local currId, currState, _ = RoadOfHeroObj:getCurrTask()
            if currState == 2 then
                RoadOfHeroObj:getReward()
            else
                require("dailytask.RoadOfHeroLayer").gotoTaskClick()
            end
        end
    })
    roadGoBtn:setAnchorPoint(cc.p(0, 0.5))
    roadGoBtn:setPosition(cc.p(50, 46))
    -- roadGoBtn:setVisible(false)
    btnParentNode:addChild(roadGoBtn)
    -- 创建大侠之路任务描述label
    local roadDescLabel = ui.newLabel({
            text = "",
            color = Enums.Color.eWhite,
            size = 18,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            dimensions = cc.size(roadGoBtn:getContentSize().width-30, 0),
            align = cc.TEXT_ALIGNMENT_CENTER,
        })
    roadGoBtn:getExtendNode2():addChild(roadDescLabel)
    -- 创建控制跳转按钮显示隐藏的按钮
    local roadGoBtnSize = roadGoBtn:getContentSize()
    local roadGoBtnPos = cc.p(roadGoBtn:getPosition())
    local staticIsRoadGoVisible = LocalData:getGameDataValue("IsRoadGoVisible")
    if staticIsRoadGoVisible == nil then
        LocalData:saveGameDataValue("IsRoadGoVisible", true)
    end
    local isRoadGoVisible = ModuleInfoObj:moduleIsOpen(ModuleSub.eMainTask, false) and LocalData:getGameDataValue("IsRoadGoVisible")
    local arrowBtn = ui.newButton({
            normalImage = "dxzl_08.png",
            clickAction = function (pSender)
                if not ModuleInfoObj:moduleIsOpen(ModuleSub.eMainTask, true) then
                    return
                end

                -- 引导时也不可点击
                local _, _, eventID = Guide.manager:getGuideInfo()
                if eventID and eventID ~= 9001 then return end

                isRoadGoVisible = not isRoadGoVisible
                LocalData:saveGameDataValue("IsRoadGoVisible", isRoadGoVisible)
                local scale = nil
                pSender:setVisible(false)
                if isRoadGoVisible then
                    scale = cc.Sequence:create({
                        cc.ScaleTo:create(0.2, 1),
                        cc.CallFunc:create(function(node)
                            pSender:setVisible(true)
                            pSender:setRotation(0)
                            pSender:setPosition(roadGoBtnSize.width+roadGoBtnPos.x+10, roadGoBtnPos.y)
                        end),
                    })
                else
                    scale = cc.Sequence:create({
                        cc.ScaleTo:create(0.2, 0),
                        cc.CallFunc:create(function(node)
                            pSender:setVisible(true)
                            pSender:setRotation(180)
                            pSender:setPosition(roadGoBtnPos.x+10, roadGoBtnPos.y)
                        end),
                    })
                end
                roadGoBtn:runAction(scale)
            end
        })
    arrowBtn:setScale(1.5)
    btnParentNode:addChild(arrowBtn)
    if isRoadGoVisible then
        roadGoBtn:setScale(1)
        arrowBtn:setRotation(0)
        arrowBtn:setPosition(roadGoBtnSize.width+roadGoBtnPos.x+10, roadGoBtnPos.y)
    else
        roadGoBtn:setScale(0)
        arrowBtn:setRotation(180)
        arrowBtn:setPosition(roadGoBtnPos.x+10, roadGoBtnPos.y)
    end
    
    -- 创建聊天按钮
    local chatBtn = ui.newButton({
        normalImage = "tb_10.png",
    })
    chatBtn:setPosition(cc.p(0, -46))
    btnParentNode:addChild(chatBtn)

    -- 添加消息通知处理
    local function refreshRoadBtn()
        -- 模块未开启
        if not ModuleInfoObj:moduleIsOpen(ModuleSub.eMainTask, false) then
            roadBtn:setVisible(false)
            roadGoBtn:setVisible(false)
            arrowBtn:setVisible(false)
            return
        else
            roadBtn:setVisible(true)
            roadGoBtn:setVisible(true)
            arrowBtn:setVisible(true)
        end
        -- 任务是已全部完成
        local currId, currState, _ = RoadOfHeroObj:getCurrTask()
        local taskConfig = MaintaskNodeRelation.items[currId]
        if (taskConfig == nil) then
            roadBtn:setVisible(false)
            roadGoBtn:setVisible(false)
            arrowBtn:setVisible(false)
            return
        end

        -- 刷新任务状态图标
        roadBtn:setVisible(true)
        if (roadBtn.stateSprite ~= nil) then
            roadBtn.stateSprite:removeFromParent()
            roadBtn.stateSprite = nil
        end
        local roadBtnSize = roadBtn:getContentSize()
        local tmpImg = (currState == 1) and "dxzl_04.png" or "dxzl_03.png"
        local tmpSprite = ui.newSprite(tmpImg)
        roadBtn:setScale(0.865)
        tmpSprite:setPosition(roadBtnSize.width - 30, roadBtnSize.height - 30)
        roadBtn:addChild(tmpSprite, 1)
        roadBtn.stateSprite = tmpSprite
        ui.setWaveAnimation(tmpSprite, 15, false)

        local taskIntro, taskReward = require("dailytask.RoadOfHeroLayer").getTaskIntro()
        roadDescLabel:setString(taskIntro.."\n#ffe748"..taskReward)
    end
    refreshRoadBtn() -- 必须先执行一次，因为在初始进入游戏后就会刷新一次任务状态，比这里早
    -- 注册大侠之路状态变化刷新显示
    Notification:registerAutoObserver(roadBtn, refreshRoadBtn, {EventsName.eRoadOfHeroStateChanged})
    -- 注册等级变化到开启时显示出大侠之路
    Notification:registerAutoObserver(arrowBtn, function ()
        local openLv = ModuleSubModel.items[ModuleSub.eMainTask].openLv
        if not isRoadGoVisible and ModuleInfoObj:moduleIsOpen(ModuleSub.eMainTask, false) and openLv == PlayerAttrObj:getPlayerAttrByName("Lv") then
            refreshRoadBtn()
            arrowBtn.mClickAction(arrowBtn)
        end
    end, {EventsName.eLvChanged})

    -- 添加聊天mini框并默认隐藏
    self:addNewMsgSprite(chatBtn)

    -- 未读消息小红点注册事件
    local function dealRedDotVisible(redDotSprite)
        redDotSprite:setVisible(RedDotInfoObj:isValid(ModuleSub.eChat))
    end
    ui.createAutoBubble({parent = chatBtn, eventName = RedDotInfoObj:getEvents(ModuleSub.eChat), refreshFunc = dealRedDotVisible})

    -- 限制按钮区域不能超出屏幕
    local btnSize = roadBtn:getContentSize()
    local clipSize = cc.size(btnSize.width, btnSize.height * 2)
    local exceeding = function(pos)
        local halfWidth, halfHeight = clipSize.width / 2, clipSize.height / 2
        local maxPosY = 1136 - halfHeight + (roadBtn:isVisible() and 30 or 120)
        local minPos, maxPos = cc.p(halfWidth, halfHeight), cc.p(640 - halfWidth + 15, maxPosY)
        return cc.pGetClampPoint(pos, minPos, maxPos)
    end
    -- 按钮拖动事件
    local function touchEventAction(touchBtn, touchAction)
        local  beginPos,lastMovePos
        touchBtn:addTouchEventListener(function (pSender, eventType )
            if eventType == ccui.TouchEventType.began then -- 开始拖动
                beginPos = parent:convertToNodeSpace(pSender:getTouchBeganPosition())
                lastMovePos = beginPos
            elseif eventType == ccui.TouchEventType.moved then
                -- 计算相对偏移量
                local touchPos = parent:convertToNodeSpace(pSender:getTouchMovePosition())
                local addBtnPos = cc.pAdd(cc.p(btnParentNode:getPosition()), cc.pSub(touchPos, lastMovePos))
                btnParentNode:setPosition(exceeding(addBtnPos))
                -- 保存上次的移动位置
                lastMovePos = touchPos
            elseif eventType == ccui.TouchEventType.ended then
                local endPos = parent:convertToNodeSpace(pSender:getTouchEndPosition())
                local distance = math.sqrt(math.pow(endPos.x - beginPos.x, 2) + math.pow(endPos.y - beginPos.y, 2))
                if distance < (5 * Adapter.MinScale) then
                    -- 点击事件回调
                    touchAction()
                end
            end
        end)
    end
    touchEventAction(chatBtn, function ()
        if PlayerAttrObj:getPlayerInfo().Lv < 9 then
            return
        end
    
        -- 引导时，不可点击
        local _, _, eventID = Guide.manager:getGuideInfo()
        if not eventID then
            local tempData = {chatChanne = ChatBtnLayer.channe,}
            local layerName = LayerManager.getTopCleanLayerName()
            -- 部分界面直接进入聊天，不加入栈，避免切换界面时被自动删除
            if ChatForbidCleanUpList[layerName] then
                local mainScene = LayerManager.getMainScene()
                local tempLayer = require("Chat.ChatLayer").new(tempData)
                mainScene:addChild(tempLayer, Enums.ZOrderType.eChat)
            else
                local channeList = {
                    Enums.ChatChanne.eWorld,
                    Enums.ChatChanne.eUnion,
                    Enums.ChatChanne.ePrivate,
                    Enums.ChatChanne.eTeam,
                    Enums.ChatChanne.eGuide,
                }
                local defaultChanne = Enums.ChatChanne.eWorld
                for _, channe in ipairs(channeList) do
                    local tempCount = ChatMng:getUnreadCount(channe)
                    if tempCount > 0 then
                        defaultChanne = channe
                        break
                    end
                end
                ChatMng:getUnreadCount(key)
                LayerManager.addLayer({
                    name = "Chat.ChatLayer",
                    cleanUp = false,
                    data = {chatChanne = defaultChanne,},
                })
            end
        end
    end)
    touchEventAction(roadBtn, function ()
        if not ModuleInfoObj:moduleIsOpen(ModuleSub.eMainTask, true) then
            return
        end
        -- 更新引导步骤
        local _, _, eventID = Guide.manager:getGuideInfo()
        if eventID == 9002 or eventID == 9005 then
            Guide.manager:removeGuideLayer()
            Guide.manager:nextStep(eventID)
        -- 其他引导时不相应
        elseif eventID then
            return
        end
        LayerManager.addLayer({name = "dailytask.RoadOfHeroLayer", cleanUp = false, zOrder = Enums.ZOrderType.eChat})
    end)
    ChatBtnLayer.btnParentNode = btnParentNode
    -- 保存按钮，引导使用
    ChatBtnLayer.roadBtn = roadBtn
    
    touchEventAction(roadGoBtn, function ()
        if not ModuleInfoObj:moduleIsOpen(ModuleSub.eMainTask, true) then
            return
        end

        -- 引导时也不可点击
        local _, _, eventID = Guide.manager:getGuideInfo()
        if eventID then
        	isRoadGoVisible = false
        	roadGoBtn:setScale(0)
	        arrowBtn:setRotation(180)
	        arrowBtn:setPosition(roadGoBtnPos.x+10, roadGoBtnPos.y)
        	return
        end

        -- 战斗中不可跳转
        if LayerManager.getTopCleanLayerName() == "ComBattle.BattleLayer" then
        	ui.showFlashView(TR("请先退出战斗界面"))
            return
        end
        -- 冰火岛不可跳转
        if LayerManager.getTopCleanLayerName() == "ice.IcefireMapLayer" then
            return
        end

        local currId, currState, _ = RoadOfHeroObj:getCurrTask()
        if currState == 2 then
            RoadOfHeroObj:getReward()
        else
            require("dailytask.RoadOfHeroLayer").gotoTaskClick()
        end
    end)
end

--设置当前频道
function ChatBtnLayer:setChatChanne(channe)
    ChatBtnLayer.channe = channe
end

--设置聊天按钮是否显示
function ChatBtnLayer:setChatVisible(visible)
    if ChatBtnLayer.btnParentNode then
        ChatBtnLayer.btnParentNode:setVisible(visible)
    end
end

--清空聊天按钮
function ChatBtnLayer:clearBtn()
    if ChatBtnLayer.btnParentNode then
        ChatBtnLayer.btnParentNode:removeFromParent()
        ChatBtnLayer.btnParentNode = nil
    end
end

-- 是否是黑名单玩家的消息
function ChatBtnLayer:isEnemyMsg(msgItem)
    local channelType = msgItem and msgItem.ChannelType
    local playerId = msgItem and msgItem.FromPlayer and msgItem.FromPlayer.Id
    if not playerId then
        return
    end

    return EnemyObj:isEnemyPlayer(playerId)
end

--添加气泡弹框
function ChatBtnLayer:addNewMsgSprite(chatBtn)
    local btnSize = chatBtn:getContentSize()
    local bgSprite = ui.newSprite("lt_45.png")
    bgSprite:setVisible(false)
    chatBtn:addChild(bgSprite)

    -- 添加显示内容
    local msgSize = bgSprite:getContentSize()
    local msgLabel = ui.newLabel({
        text = TR("[系统]:欢迎来到金庸武侠世界,快和好友一起闯荡江湖吧!"),
        dimensions = cc.size(msgSize.width - 30, msgSize.height)
    })
    msgLabel:setPosition((msgSize.width + 11) / 2, msgSize.height / 2)
    msgLabel:setImageElementScale(0.3)
    bgSprite:addChild(msgLabel)

    -- 注册新消息
    Notification:registerAutoObserver(bgSprite, function()
        local lastMsg = ChatMng:getLastRecData()
        if not next(lastMsg) then
            return 
        end

        -- 仅本服或帮派聊天时显示内容
        if (lastMsg.ChannelType == Enums.ChatChanne.eWorld or lastMsg.ChannelType == Enums.ChatChanne.eUnion) and
            not self:isEnemyMsg(lastMsg) then
            bgSprite:stopAllActions()
            -- 消息内容
            local msgStr = lastMsg.Message
            local tempLen = msgStr:len()
            if msgStr:byte(tempLen) == string.byte('#') then
                msgStr = msgStr:sub(1, tempLen - 1)
            end
            -- 显示文本
            local tempStr = string.format("[%s]%s:%s",
                Enums.ChatChanneName[lastMsg.ChannelType],
                lastMsg.FromPlayer and lastMsg.FromPlayer.ExtendInfo and lastMsg.FromPlayer.ExtendInfo.Name or "",
                msgStr)
            if string.utf8len(tempStr) > 28 then
                tempStr = string.utf8sub(tempStr, 1, 28) .. "..."
            end
            -- unpack放后面执行，避免判断长度时将表情{bq_x.png}截断
            tempStr = ChatMng:faceStrUnpack(tempStr)
            msgLabel:setString(tempStr)

            -- 设置label显示位置
            if (chatBtn:getPosition() + msgSize.width) > 640 then
                bgSprite:setPosition(0, btnSize.height / 2)
                bgSprite:setAnchorPoint(cc.p(1, 0.5))
                bgSprite:setFlippedX(true)
            else
                bgSprite:setPosition(btnSize.width, btnSize.height / 2)
                bgSprite:setAnchorPoint(cc.p(0, 0.5))
                bgSprite:setFlippedX(false)
            end
            bgSprite:runAction(cc.Sequence:create({cc.Show:create(), cc.DelayTime:create(3.5), cc.Hide:create()}))
        end
    end, EventsName.eChatNewMsg)
end

ActionManager = { }

--- 获取卡牌动画
-- @animationFiles : 卡牌字典表中的字段
-- @actionIndex : 卡牌动画的索引
function ActionManager.getCardAnimation(animationFiles, actionIndex)
    local cardActionPath = "ani/card_action/"
    local animation_Name = nil
    animation_Name = utils.stringSplit(animationFiles, ".ExportJson")[1]
    cardActionPath = cardActionPath .. animation_Name .. "/"
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(cardActionPath .. animationFiles);
    if animation_Name == nil then
        cclog("@@@@@========= LUA ERROR: 动画文件有问题！！！！=========@@@@@")
        return
    end
     cclog("animation_Name==="..animation_Name)
    local animation = ccs.Armature:create(animation_Name)
   
    if actionIndex == nil then
        actionIndex = 1
    end
    animation:getAnimation():play(animation_Name .. "_" .. actionIndex)
    -- local function onMovementEvent(armature, movementType, movementID)
    -- end
    -- animation:getAnimation():setMovementEventCallFunc(onMovementEvent)
    return animation, animation_Name
end

function ActionManager.getCardBreatheAnimation(imagePath, actionIndex)
    local animation, animation_Name = ActionManager.getCardAnimation("card_action_tong.ExportJson", actionIndex)
    animation:getBone("gu"):addDisplay(ccs.Skin:create(imagePath), 0)
    return animation, animation_Name
end

--- 获取UI中的动画对象
-- @uiAnimId : UI动画ID
-- @callbackFunc : 回调函数
--notEnabledTrue : 不恢复操作
function ActionManager.getUIAnimation(uiAnimId, callbackFunc, resManageByUser , notEnabledTrue )
    local childs = UIManager.uiLayer:getChildren()
    if uiAnimId ~= 11--[[ 战斗胜利动画 ]] then
        for key, obj in pairs(childs) do
            if not tolua.isnull(obj) then
                obj:setEnabled(false)
            end
        end
    end
    local animPath = "ani/ui_anim/ui_anim" .. uiAnimId .. "/"
    if not resManageByUser then
        ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath .. "ui_anim" .. uiAnimId .. ".ExportJson")
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath .. "ui_anim" .. uiAnimId .. ".ExportJson")
    end
    local animation = ccs.Armature:create("ui_anim" .. uiAnimId)
    if uiAnimId ~= 10--[[ 恭喜招募得卡牌动画-- ]]and uiAnimId ~= 15--[[ 强化成功动画-- ]] and uiAnimId ~= 51--[[猎魂效果]] then
--        animation:getAnimation():play("ui_anim" .. uiAnimId)
        animation:getAnimation():playWithIndex(0)
    end
    local function onMovementEvent(armature, movementType, movementID)
        if movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete then
            armature:getAnimation():stop()
            if (uiAnimId == 10 and not UIGuidePeople.guideFlag) or uiAnimId == 12--[[ 战斗失败动画-- ]]or uiAnimId == 21--[[ 新副本关卡出现动画-- ]]or uiAnimId == 27--[[ 招募10连抽动画 ]]or uiAnimId == 33--[[ 加载中动画 ]] then
                for key, obj in pairs(childs) do
                    if not tolua.isnull(obj) then
                        obj:setEnabled(true)
                    end
                end
            elseif uiAnimId == 2--[[ 卡牌升级动画 ]]or uiAnimId == 11--[[ 战斗胜利动画 ]]or uiAnimId == 1--[[ 升级动画-- ]]or(uiAnimId == 10 and UIGuidePeople.guideFlag) then
            else
                UIManager.gameLayer:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),
                cc.CallFunc:create( function() if armature:getParent() then armature:removeFromParent() end if not notEnabledTrue then for key, obj in pairs(childs) do if not tolua.isnull(obj) then obj:setEnabled(true) end end end end)))
            end
            if not resManageByUser then
                ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath .. "ui_anim" .. uiAnimId .. ".ExportJson")
                ccs.ArmatureDataManager:getInstance():removeArmatureData(movementID)
            end
            if callbackFunc then
                callbackFunc(armature)
            end
        end
    end
    animation:getAnimation():setMovementEventCallFunc(onMovementEvent)
    return animation
end

--- 获取ui特效的动画对象 不停止 不移除 不禁使能
-- @uiAnimId : UI动画ID
-- @callbackFunc : 回调函数
function ActionManager.getEffectAnimation(uiAnimId, callbackFunc, animIndex)
    local animPath = "ani/ui_anim/ui_anim" .. uiAnimId .. "/"
    ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath .. "ui_anim" .. uiAnimId .. ".ExportJson")
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath .. "ui_anim" .. uiAnimId .. ".ExportJson")
    local animation = ccs.Armature:create("ui_anim" .. uiAnimId)
    -- animation:getAnimation():play("ui_anim" .. uiAnimId)
    if animIndex then
        animation:getAnimation():playWithIndex(animIndex)
    else
        animation:getAnimation():playWithIndex(0)
    end
    local function onMovementEvent(armature, movementType, movementID)
        if movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete then
            ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath .. "ui_anim" .. uiAnimId .. ".ExportJson")
            ccs.ArmatureDataManager:getInstance():removeArmatureData(movementID)
            if callbackFunc then
                callbackFunc(armature)
            end
        end
    end
    animation:getAnimation():setMovementEventCallFunc(onMovementEvent)
    return animation
end

--- UI界面过渡动作，公告，战队信息从上向下滑入，主菜单从下向上滑入，这里锚点都是左下角
function ActionManager.UIScreen_SplashAction()
    if UINotice.Widget and UIMenu.Widget then
        local UITeamInfo_flag = nil
        local childs = UIManager.uiLayer:getChildren()
        for key, obj in pairs(childs) do
            if not tolua.isnull(obj) then
                obj:setEnabled(false)
            end
            if obj == UITeamInfo.Widget then
                UITeamInfo_flag = true
            end
        end
        local actionTime = 0.25

        -- local UITeamInfo_flag = nil
        -- local childs = UIManager.uiLayer:getChildren()
        -- for key, _widget in pairs(childs) do
        -- 	if _widget == UITeamInfo.Widget then
        -- 		UITeamInfo_flag = true
        -- 		break
        -- 	end
        -- end

        if UITeamInfo_flag then
            if UINotice.Widget:getParent() then
                UINotice.Widget:setPositionY(UINotice.Widget:getPositionY() +(UINotice.Widget:getContentSize().height + UITeamInfo.Widget:getContentSize().height) / 2)
            end
            if UITeamInfo.Widget:getParent() then
                UITeamInfo.Widget:setPositionY(UINotice.Widget:getPositionY() - UITeamInfo.Widget:getContentSize().height)
            end
        else
            if UINotice.Widget:getParent() then
                UINotice.Widget:setPositionY(UINotice.Widget:getPositionY() + UINotice.Widget:getContentSize().height / 2)
            end
        end

        if UITeamInfo_flag then
            if UITeamInfo.Widget:getParent() then
                UITeamInfo.Widget:runAction(cc.Sequence:create(cc.MoveBy:create(actionTime, cc.p(0, -(UINotice.Widget:getContentSize().height + UITeamInfo.Widget:getContentSize().height) / 2))))
            end
            if UINotice.Widget:getParent() then
                UINotice.Widget:runAction(cc.Sequence:create(cc.MoveBy:create(actionTime, cc.p(0, -(UINotice.Widget:getContentSize().height + UITeamInfo.Widget:getContentSize().height) / 2))))
            end
        else
            if UINotice.Widget:getParent() then
                UINotice.Widget:runAction(cc.Sequence:create(cc.MoveBy:create(actionTime, cc.p(0, - UINotice.Widget:getContentSize().height / 2))))
            end
        end
        if UIMenu.Widget:getParent() then
            UIMenu.Widget:setPositionY(UIMenu.Widget:getPositionY() - UIMenu.Widget:getContentSize().height / 2)
            UIMenu.Widget:runAction(cc.Sequence:create(cc.MoveBy:create(actionTime, cc.p(0, UIMenu.Widget:getContentSize().height / 2)),
            cc.CallFunc:create( function()
                for key, obj in pairs(childs) do
                    if not tolua.isnull(obj) then
                        obj:setEnabled(true)
                    end
                end
            end )))
        else
            for key, obj in pairs(childs) do
                if not tolua.isnull(obj) then
                    obj:setEnabled(true)
                end
            end
        end

    end
end

--- 弹出框过渡动作,从小到大，再缩小
function ActionManager.PopUpWindow_SplashAction(rootWidget, scaleTo)
    if rootWidget then
        rootWidget:setScale(0.1)
        if UIGuidePeople.guideStep or UIGuidePeople.levelStep then
            local function callFunc()
                UIGuidePeople.addGuideWidget()
            end
            rootWidget:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.1), cc.ScaleTo:create(0.06, scaleTo and scaleTo or dp.DIALOG_SCALE), cc.CallFunc:create(callFunc)))
        else
            rootWidget:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.1), cc.ScaleTo:create(0.06, scaleTo and scaleTo or dp.DIALOG_SCALE)))
        end

    end
end

--- 商店入场动作
-- @uiWidget : 界面的Widget对象
function ActionManager.Shop_SplashAction(uiWidget)
    if uiWidget == nil then
        return
    end
    local rootPanel = ccui.Helper:seekNodeByName(uiWidget, "image_basemap")
    local left = rootPanel:getChildByName("image_recruit_silver")
    -- 白银招募
    -- local middle = rootPanel:getChildByName("image_recruit_gold")
    local right = rootPanel:getChildByName("image_recruit_jewel")
    -- 黄金招募

    local function setItem(item)
        item:stopAllActions()
        item:setOpacity(0)
        local _items = item:getChildren()
        if _items then
            for i, obj in pairs(_items) do
                setItem(obj)
            end
        end
    end
    setItem(left)
    setItem(right)

    if not ActionManager.leftPosX then
        ActionManager.leftPosX = left:getPositionX()
    end

    if not ActionManager.rightPosX then
        ActionManager.rightPosX = right:getPositionX()
    end

    -- 左右各露一半在屏幕外，淡入移动到指定的位置
    local leftPosX = ActionManager.leftPosX
    local rightPosX = ActionManager.rightPosX
    left:setPositionX(0)
    right:setPositionX(UIManager.screenSize.width)

    local function itemFadeAction(item)
        if item ~= left and item ~= right then
            item:runAction(cc.Sequence:create(cc.FadeTo:create(0.3, 255)))
        end
        local _items = item:getChildren()
        if _items then
            for i, obj in pairs(_items) do
                itemFadeAction(obj)
            end
        end
    end

    local function runAction()
        left:runAction(cc.Sequence:create(cc.Spawn:create(cc.MoveTo:create(0.3, cc.p(leftPosX, left:getPositionY())), cc.FadeTo:create(0.3, 255)), cc.CallFunc:create(itemFadeAction)))
        right:runAction(cc.Sequence:create(cc.Spawn:create(cc.MoveTo:create(0.3, cc.p(rightPosX, right:getPositionY())), cc.FadeTo:create(0.3, 255)), cc.CallFunc:create(itemFadeAction)))
    end
    rootPanel:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create(runAction)))
end

--- 滚动层载入动作
-- @uiScrollView : 滚动层UI对象
-- @isInvertedOrder : 是否倒序
function ActionManager.ScrollView_SplashAction(uiScrollView, isInvertedOrder, jumpByUser)
    if uiScrollView == nil then
        return
    end
    if ActionManager.svScheduleId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(ActionManager.svScheduleId)
    end
    AudioEngine.playEffect("sound/scroll.mp3")
    uiScrollView:setEnabled(false)
    uiScrollView:stopAllActions()
    if not jumpByUser then
        uiScrollView:jumpToTop()
    end
    -- local widgets = UIManager.uiLayer:getChildren()
    -- for key, obj in pairs(widgets) do
    -- 	if tolua.type(obj) ~= "ccs.Armature" and not tolua.isnull(obj) then
    -- 		obj:setEnabled(false)
    -- 	end
    -- end
    local childs = uiScrollView:getChildren()

    local function compareFunc(obj1, obj2)
        return obj1:getPositionY() < obj2:getPositionY()
    end
    utils.quickSort(childs, compareFunc)

    local uiSVItems = { }
    local time = 0.2

    local innerContainerY = uiScrollView:getInnerContainer():getPositionY()
    local scrollViewSize = uiScrollView:getContentSize()

    local start = 1
    for i = start, #childs do
        local obj = childs[i]
        local top = obj:getTopBoundary() + innerContainerY
        local bottom = obj:getBottomBoundary() + innerContainerY
        if bottom < scrollViewSize.height and top > 0 then
            start = i
            break
        end
    end

    local final = #childs
    for i = final, start, -1 do
        local obj = childs[i]
        local top = obj:getTopBoundary() + innerContainerY
        local bottom = obj:getBottomBoundary() + innerContainerY
        if bottom < scrollViewSize.height and top > 0 then
            final = i
            break
        end
    end

    local tempI = final
    for i = start, final do
        if isInvertedOrder then
            childs[tempI]:setPositionX(scrollViewSize.width + childs[tempI]:getPositionX())
            uiSVItems[#uiSVItems + 1] = childs[tempI]
            tempI = tempI - 1
        else
            childs[i]:setPositionX(scrollViewSize.width + childs[i]:getPositionX())
            uiSVItems[#uiSVItems + 1] = childs[i]
        end
    end

    local curIndex = 1
    local function runAction()
        local obj = uiSVItems[curIndex]
        if not tolua.isnull(obj) and obj:getParent() and obj:getAnchorPoint() then
            curIndex = curIndex + 1
            local action
            local apX, apY = obj:getAnchorPoint().x, obj:getAnchorPoint().y
            if apX == 0 and(apY == 0 or apY == 0.5 or apY == 1) then
                action = cc.MoveTo:create(time, cc.p((uiScrollView:getContentSize().width - obj:getContentSize().width) / 2, obj:getPositionY()))
            elseif apX == 0.5 and apY == 0.5 then
                action = cc.MoveTo:create(time, cc.p(uiScrollView:getContentSize().width / 2, obj:getPositionY()))
            end
            if action then
                local nextAction = cc.Sequence:create(cc.DelayTime:create(time / 2), cc.CallFunc:create(runAction))
                obj:runAction(cc.Spawn:create(action, nextAction))
            end
        else
            -- for key, widgetObj in pairs(widgets) do
            -- 	if tolua.type(widgetObj) ~= "ccs.Armature" and not tolua.isnull(widgetObj) then
            -- 		widgetObj:setEnabled(true)
            -- 	end
            -- end
            uiScrollView:setEnabled(true)
        end
    end
    -- runAction()
    uiScrollView:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(runAction)))
    ActionManager.svScheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc( function(dt)
        if not tolua.isnull(uiScrollView) and uiScrollView:getParent() and uiScrollView:getReferenceCount() == 1 then
            -- local widgets = UIManager.uiLayer:getChildren()
            -- for key, widgetObj in pairs(widgets) do
            -- 	if tolua.type(widgetObj) ~= "ccs.Armature" and not tolua.isnull(widgetObj) then
            -- 		widgetObj:setEnabled(true)
            -- 	end
            -- end
            -- uiScrollView:setEnabled(true)
            if ActionManager.svScheduleId then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(ActionManager.svScheduleId)
                ActionManager.svScheduleId = nil
            end
        end
    end , 0, false)
end

function ActionManager.setSoulEffectAction(soulId , icon )
    if icon:getChildByName( "effect" ) then
        icon:removeChildByName( "effect" )
    end
    if soulId >= 9 and soulId <= 10 then
        -- 神佑斗魂
        local effect = ccui.ImageView:create()
        effect:setTouchEnabled(false)
        local img = ""
        if soulId == 9 then
            img = "particle/soul/dh_sy_jin0.png"
        elseif soulId == 10 then
            img = "particle/soul/dh_sy_zi0.png"
        elseif soulId == 11 then
            img = "particle/soul/dh_sy_lan0.png"
        elseif soulId == 12 then
            img = "particle/soul/dh_sy_lv0.png"
        end
        effect:loadTexture(img)
        effect:setPosition(icon:getContentSize().width / 2, icon:getContentSize().height / 2)
        effect:setName( "effect" )
        icon:addChild(effect , 1 )
       -- effect:runAction(cc.RepeatForever:create( cc.Sequence:create(  cc.ScaleTo:create(0.2, 0.1) , cc.ScaleTo:create(0.2, 1) ) ))
       -- effect:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.05, 30)))
    elseif soulId >= 13 and soulId <= 14 then
        -- 厄运斗魂
        local effect = ccui.ImageView:create()
        effect:setTouchEnabled(false)
        local img = ""
        if soulId == 13 then
            img = "particle/soul/dh_ey_jin0.png"
        elseif soulId == 14 then
            img = "particle/soul/dh_ey_zi0.png"
        elseif soulId == 15 then
            img = "particle/soul/dh_ey_lan0.png"
        elseif soulId == 16 then
            img = "particle/soul/dh_ey_lv0.png"
        end
        effect:loadTexture(img)
        effect:setPosition(icon:getContentSize().width / 2, icon:getContentSize().height / 2)
        effect:setName( "effect" )
        icon:addChild(effect , 1 )
        effect:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.05, 30)))
    elseif soulId >= 21 and soulId <= 22 then
        -- 圣光斗魂
        local effect = ccui.ImageView:create()
        effect:setTouchEnabled(false)
        local img = ""
        if soulId == 21 then
            img = "particle/soul/dh_sg_jin0.png"
        elseif soulId == 22 then
            img = "particle/soul/dh_sg_zi0.png"
        elseif soulId == 23 then
            img = "particle/soul/dh_sg_lan0.png"
        elseif soulId == 24 then
            img = "particle/soul/dh_sg_lv0.png"
        end
        effect:loadTexture(img)
        effect:setPosition(icon:getContentSize().width / 2, icon:getContentSize().height / 2)
        effect:setName( "effect" )
        icon:addChild(effect , 1 )
        effect:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.05, 30)))
    elseif soulId >= 33 and soulId <= 34 then
        -- 物防斗魂
        local effect = ccui.ImageView:create()
        effect:setTouchEnabled(false)
        local img = ""
        if soulId == 33 then
            img = "particle/soul/dh_wf_jin0.png"
        elseif soulId == 34 then
            img = "particle/soul/dh_wf_zi0.png"
        elseif soulId == 35 then
            img = "particle/soul/dh_wf_lan0.png"
        elseif soulId == 36 then
            img = "particle/soul/dh_wf_lv0.png"
        end
        effect:loadTexture(img)
        effect:setPosition(icon:getContentSize().width / 2, icon:getContentSize().height / 2)
        effect:setName( "effect" )
        icon:addChild(effect , 1 )
        effect:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.05, 30)))
    end
end
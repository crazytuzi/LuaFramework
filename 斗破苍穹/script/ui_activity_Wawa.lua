require"Lang"
UIActivityWawa = {}
--最大层数
UIActivityWawa.MAX_COUNT = 5

local DictActivity = nil
local _curOpeningLayerIndex = 1
local _curShowLayerIndex = 1

function UIActivityWawa.onActivity(_params)
    DictActivity = _params
end

local function getAnimation(_playIndex, _callbackFunc)
    local uiAnimId = 71
    local animPath = "ani/ui_anim/ui_anim" .. uiAnimId .. "/"
    ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath .. "ui_anim" .. uiAnimId .. ".ExportJson")
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath .. "ui_anim" .. uiAnimId .. ".ExportJson")
    local animation = ccs.Armature:create("ui_anim" .. uiAnimId)
    animation:getAnimation():playWithIndex(_playIndex)
    animation:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2))
    animation:getAnimation():setMovementEventCallFunc(function(armature, movementType, movementID)
        if movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete then
            if _callbackFunc then
                _callbackFunc()
            end
        end
    end)
    return animation
end

local function getAnimLayout(_isTouchEnabled, _things, _flag)
    local uiLayout = ccui.Layout:create()
    uiLayout:setContentSize(UIManager.screenSize)
    uiLayout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    uiLayout:setBackGroundColor(cc.c3b(0, 0, 0))
    uiLayout:setBackGroundColorOpacity(0)
    uiLayout:setTouchEnabled(_isTouchEnabled)

    if _things then
        local itemProps = utils.getItemProp(_things)
        if itemProps then
            local uiFrame = ccui.ImageView:create(itemProps.frameIcon)
            uiFrame:setName("uiItemFrame")
            local uiIcon = ccui.ImageView:create(itemProps.smallIcon)
            uiIcon:setPosition(cc.p(uiFrame:getContentSize().width / 2, uiFrame:getContentSize().height / 2))
            uiFrame:addChild(uiIcon)
            local uiName = ccui.Text:create()
            uiName:setString(itemProps.name .. "x" .. itemProps.count)
            uiName:setTextColor(itemProps.qualityColor)
            uiName:setFontName(dp.FONT)
            uiName:setFontSize(25)
            uiName:setAnchorPoint(cc.p(0.5, 1))
            uiName:setPosition(cc.p(uiFrame:getContentSize().width / 2, -5))
            uiFrame:addChild(uiName)
            uiFrame:setPosition(cc.p(uiLayout:getContentSize().width / 2, uiLayout:getContentSize().height / 2 + 130))
            uiFrame:setLocalZOrder(1)
            uiLayout:addChild(uiFrame)
            utils.showThingsInfo(uiIcon, itemProps.tableTypeId, itemProps.tableFieldId)
            if _flag then
                uiFrame:setVisible(false)
                uiFrame:setScale(0)
                uiFrame:setPositionY(uiLayout:getContentSize().height / 2)
            end
        end
    end

    return uiLayout
end

local function cleanAnimLayout()
    for i = 1, UIActivityWawa.MAX_COUNT do
        local animLayout = UIActivityWawa.Widget:getChildByName("animLayout_"..i)
        if animLayout then
            animLayout:removeFromParent()
        end
    end
end

function UIActivityWawa.init()
    local image_basemap = UIActivityWawa.Widget:getChildByName("image_basemap")
    local btn_help = image_basemap:getChildByName("btn_help")
    local btn_preview = image_basemap:getChildByName("btn_preview")
    local btn_open = image_basemap:getChildByName("btn_open")
    local btn_continue = image_basemap:getChildByName("btn_continue")
    local btn_go = image_basemap:getChildByName("btn_go")
    local arrowLeft = image_basemap:getChildByName("image_arrow_l")
    local arrowRight = image_basemap:getChildByName("image_arrow_r")
    arrowLeft:setTouchEnabled(true)
    arrowRight:setTouchEnabled(true)
    btn_help:setPressedActionEnabled(true)
    btn_preview:setPressedActionEnabled(true)
    btn_open:setPressedActionEnabled(true)
    btn_continue:setPressedActionEnabled(true)
    btn_go:setPressedActionEnabled(true)
    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_help then
                UIAllianceHelp.show( { type = 27 , titleName = Lang.ui_activity_Wawa1 } )
            elseif sender == btn_preview then
                UIActivityWawaPreview.show()
            elseif sender == btn_open or sender == btn_continue then
                if sender == btn_open and UIActivityWawa.Widget:getChildByName("image_close"):isVisible() then
                    if utils.getThingCount(StaticThing.thing179) >= 1 then
                        UIManager.showLoading()
	                    netSendPackage({header=StaticMsgRule.resetFoolBox, msgdata={}}, function(_msgData)
                            UIActivityWawa.setup()
                        end)
                    else
                        UIManager.showToast(DictThing[tostring(StaticThing.thing179)].name .. Lang.ui_activity_Wawa2)
                    end
                    return
                end
                UIManager.showLoading()
	            netSendPackage({header=StaticMsgRule.openFoolBoxReward, msgdata={}}, function(_msgData)
                    local curAnimLayout = UIActivityWawa.Widget:getChildByName("animLayout_".._curOpeningLayerIndex)
                    if curAnimLayout then
                        curAnimLayout:setVisible(false)
                    end
                    btn_open:setVisible(false)
                    btn_continue:setVisible(false)
                    btn_go:setVisible(false)
                    if _msgData.msgdata.int.xiaochou == 1 then --0:未出现，1:出现小丑
                        local animLayout = getAnimLayout(true)
                        local anim = getAnimation(3, function()
                            animLayout:removeFromParent()
                            UIActivityWawa.setup()
                            UIManager.showToast(Lang.ui_activity_Wawa3)
                        end)
                        anim:getAnimation():setFrameEventCallFunc(function(bone, evt, originFrameIndex, currentFrameIndex)
                            if evt == "showXiaochou" then
                                AudioEngine.playEffect("sound/activity_wawa_xiaochou.mp3")
                            end
                        end)
                        if _curOpeningLayerIndex == 2 or _curOpeningLayerIndex == 4 then
                            anim:getBone("h1"):addDisplay(ccs.Skin:create("ani/ui_anim/ui_anim71/ui_anim71_04.png"), 0)
                            anim:getBone("h2"):addDisplay(ccs.Skin:create("ani/ui_anim/ui_anim71/ui_anim71_03.png"), 0)
                        end
                        animLayout:addChild(anim)
                        UIManager.uiLayer:addChild(animLayout, 9999)
                    else
                        local animLayout = getAnimLayout(true, _msgData.msgdata.string.reward, true)
                        local anim = getAnimation(1, function()
                            if _curOpeningLayerIndex == 5 then
                                animLayout:removeFromParent()
                                UIActivityWawa.setup()
                                UIManager.showToast(Lang.ui_activity_Wawa4)
                            else
                                animLayout:runAction(cc.Sequence:create(cc.MoveBy:create(0.3, cc.p(-UIManager.screenSize.width,0)), cc.CallFunc:create(function()
                                    animLayout:removeFromParent()
                                    local _enterAnimLayout = getAnimLayout(true)
                                    local _enterAnim = getAnimation(2, function()
                                        UIActivityWawa.setup(function()
                                            _enterAnimLayout:removeFromParent()
                                        end)
                                    end)
                                    if _curOpeningLayerIndex + 1 == 2 or _curOpeningLayerIndex + 1 == 4 then
                                        _enterAnim:getBone("h1"):addDisplay(ccs.Skin:create("ani/ui_anim/ui_anim71/ui_anim71_04.png"), 0)
                                        _enterAnim:getBone("h2"):addDisplay(ccs.Skin:create("ani/ui_anim/ui_anim71/ui_anim71_03.png"), 0)
                                    end
                                    _enterAnim:setScale(1 - (_curOpeningLayerIndex) * 0.1)
                                    _enterAnimLayout:addChild(_enterAnim)
                                    UIManager.uiLayer:addChild(_enterAnimLayout, 9999)
                                end)))
                            end
                        end)
                        if _curOpeningLayerIndex == 2 or _curOpeningLayerIndex == 4 then
                            anim:getBone("h1"):addDisplay(ccs.Skin:create("ani/ui_anim/ui_anim71/ui_anim71_04.png"), 0)
                            anim:getBone("h2"):addDisplay(ccs.Skin:create("ani/ui_anim/ui_anim71/ui_anim71_03.png"), 0)
                        end
                        anim:getAnimation():setFrameEventCallFunc(function(bone, evt, originFrameIndex, currentFrameIndex)
                            if evt == "showItem" then
                                local uiItemFrame = animLayout:getChildByName("uiItemFrame")
                                if uiItemFrame then
                                    uiItemFrame:setVisible(true)
                                    uiItemFrame:runAction(cc.Sequence:create( cc.Spawn:create( cc.ScaleTo:create(0.05, 1), cc.MoveBy:create(0.05, cc.p(0, 130)) ) ))
                                end
                            end
                        end)
                        animLayout:addChild(anim)
                        UIManager.uiLayer:addChild(animLayout, 9999)
                    end
                end)
            elseif sender == btn_go then
                UIManager.showLoading()
	            netSendPackage({header=StaticMsgRule.drawFoolBoxReardEnd, msgdata={}}, function(_msgData)
                    UIActivityWawa.setup()
                    UIManager.showToast(Lang.ui_activity_Wawa5)
                end)
            elseif sender == arrowLeft then
                if _curShowLayerIndex > 1 then
                    _curShowLayerIndex = _curShowLayerIndex - 1
                    for i = 1, _curOpeningLayerIndex do
                        local animLayout = UIActivityWawa.Widget:getChildByName("animLayout_"..i)
                        if animLayout then
                            animLayout:runAction(cc.Sequence:create(cc.MoveBy:create(0.3, cc.p(UIManager.screenSize.width,0)), cc.CallFunc:create(function()
                                arrowRight:setVisible(true)
                                if _curShowLayerIndex == 1 then
                                    arrowLeft:setVisible(false)
                                end
                                image_basemap:getChildByName("btn_continue"):setVisible(false)
                                image_basemap:getChildByName("btn_go"):setVisible(false)
                            end)))
                        end
                    end
                end
            elseif sender == arrowRight then
                if _curShowLayerIndex < _curOpeningLayerIndex then
                    _curShowLayerIndex = _curShowLayerIndex + 1
                    for i = 1, _curOpeningLayerIndex do
                        local animLayout = UIActivityWawa.Widget:getChildByName("animLayout_"..i)
                        if animLayout then
                            animLayout:runAction(cc.Sequence:create(cc.MoveBy:create(0.3, cc.p(-UIManager.screenSize.width,0)), cc.CallFunc:create(function()
                                arrowLeft:setVisible(true)
                                if _curShowLayerIndex == _curOpeningLayerIndex then
                                    arrowRight:setVisible(false)
                                    image_basemap:getChildByName("btn_continue"):setVisible(true)
                                    image_basemap:getChildByName("btn_go"):setVisible(true)
                                end
                            end)))
                        end
                    end
                end
            end
        end
    end
    btn_help:addTouchEventListener(onButtonEvent)
    btn_preview:addTouchEventListener(onButtonEvent)
    btn_open:addTouchEventListener(onButtonEvent)
    btn_continue:addTouchEventListener(onButtonEvent)
    btn_go:addTouchEventListener(onButtonEvent)
    arrowLeft:addTouchEventListener(onButtonEvent)
    arrowRight:addTouchEventListener(onButtonEvent)
end

function UIActivityWawa.setup(_netCallback)
    local image_basemap = UIActivityWawa.Widget:getChildByName("image_basemap")
    local btn_open = image_basemap:getChildByName("btn_open")
    btn_open:setTitleText(Lang.ui_activity_Wawa6)
    local image_ticket = image_basemap:getChildByName("image_ticket")
    image_ticket:setVisible(false)
    local endImage = UIActivityWawa.Widget:getChildByName("image_close")
    endImage:setLocalZOrder(1001)
    endImage:setVisible(false)

    UIManager.showLoading()
    cleanAnimLayout()
	netSendPackage({header=StaticMsgRule.openFoolBoxPanel, msgdata={}}, function(_msgData)
        local _activityIsEnd = (_msgData.msgdata.int.foolEnd == 1) and true or false --0:未结束，1:已结束
        if _activityIsEnd then --活动已结束
            endImage:setVisible(true)
            image_ticket:setVisible(true)
            btn_open:setVisible(true)
            btn_open:setTitleText(Lang.ui_activity_Wawa7)
            image_basemap:getChildByName("btn_continue"):setVisible(false)
            image_basemap:getChildByName("btn_go"):setVisible(false)
            image_basemap:getChildByName("image_arrow_l"):setVisible(false)
            image_basemap:getChildByName("image_arrow_r"):setVisible(false)
            _curOpeningLayerIndex = UIActivityWawa.MAX_COUNT
            _curShowLayerIndex = _curOpeningLayerIndex
            local anim = getAnimation(0)
            anim:getAnimation():gotoAndPause(0)
            local animLayout = getAnimLayout(false)
            animLayout:setName("animLayout_".._curOpeningLayerIndex)
            animLayout:addChild(anim)
            UIActivityWawa.Widget:addChild(animLayout, 100)
        else
            _curOpeningLayerIndex = _msgData.msgdata.int.roleLayer + 1
            _curShowLayerIndex = _curOpeningLayerIndex
            if _curOpeningLayerIndex > 1 then
                btn_open:setVisible(false)
                image_basemap:getChildByName("btn_continue"):setVisible(true)
                image_basemap:getChildByName("btn_go"):setVisible(true)
                image_basemap:getChildByName("image_arrow_l"):setVisible(true)
                image_basemap:getChildByName("image_arrow_r"):setVisible(false)

                local _posXIndex = _curOpeningLayerIndex - 1
                for i = 1, _curOpeningLayerIndex - 1 do
                    local anim = getAnimation(1)
                    if i == 2 or i == 4 then
                        anim:getBone("h1"):addDisplay(ccs.Skin:create("ani/ui_anim/ui_anim71/ui_anim71_04.png"), 0)
                        anim:getBone("h2"):addDisplay(ccs.Skin:create("ani/ui_anim/ui_anim71/ui_anim71_03.png"), 0)
                    end
                    anim:getAnimation():gotoAndPause(179)
                    local animLayout = getAnimLayout(false, _msgData.msgdata.string["layer"..i])
                    animLayout:setName("animLayout_"..i)
                    animLayout:addChild(anim)
                    animLayout:setPositionX(-_posXIndex * UIManager.screenSize.width)
                    UIActivityWawa.Widget:addChild(animLayout, 100)
                    _posXIndex = _posXIndex - 1
                end
            else
                btn_open:setVisible(true)
                image_basemap:getChildByName("btn_continue"):setVisible(false)
                image_basemap:getChildByName("btn_go"):setVisible(false)
                image_basemap:getChildByName("image_arrow_l"):setVisible(false)
                image_basemap:getChildByName("image_arrow_r"):setVisible(false)
            end
            local anim = getAnimation(0)
            if _curOpeningLayerIndex == 2 or _curOpeningLayerIndex == 4 then
                anim:getBone("h1"):addDisplay(ccs.Skin:create("ani/ui_anim/ui_anim71/ui_anim71_04.png"), 0)
                anim:getBone("h2"):addDisplay(ccs.Skin:create("ani/ui_anim/ui_anim71/ui_anim71_03.png"), 0)
            end
            local animLayout = getAnimLayout(false)
            anim:setScale(1 - (_curOpeningLayerIndex - 1) * 0.1)
            animLayout:addChild(anim)
            animLayout:setName("animLayout_".._curOpeningLayerIndex)
            UIActivityWawa.Widget:addChild(animLayout, 100)
        end
        if _netCallback then
            _netCallback()
        end
    end, _netCallback)
    
    local ui_timeLabel = image_basemap:getChildByName("text_time")
    if DictActivity and DictActivity.string["4"] ~= "" and DictActivity.string["5"] ~= "" then
        local _startTime = utils.changeTimeFormat(DictActivity.string["4"])
		local _endTime = utils.changeTimeFormat(DictActivity.string["5"])
        ui_timeLabel:setString(string.format(Lang.ui_activity_Wawa8, _startTime[2],_startTime[3],_startTime[5],_endTime[2],_endTime[3],_endTime[5]))
    else
        ui_timeLabel:setString("")
    end
end

function UIActivityWawa.free()
    DictActivity = nil
    cleanAnimLayout()
end

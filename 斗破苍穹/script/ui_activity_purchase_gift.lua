require"Lang"
UIActivityPurchaseGift = {}

local DictActivity = nil
local _countdownTime = 0
local ui_thingItems = {}
local _myOpenValue = 0
local _isGetState = 0 --领奖状态
local _isOpenBox = false --是否打开箱子

local function countDowun()
    _countdownTime = _countdownTime - 1
    if _countdownTime < 0 then
        _countdownTime = 0
    end
    if UIActivityPurchaseGift.Widget then
        local day = math.floor(_countdownTime / 3600 / 24) --天
	    local hour = math.floor(_countdownTime / 3600 % 24) --小时
	    local minute = math.floor(_countdownTime / 60 % 60) --分
	    local second = math.floor(_countdownTime % 60) --秒
        local image_basemap = UIActivityPurchaseGift.Widget:getChildByName("image_basemap")
        local image_title = image_basemap:getChildByName("image_title")
        local ui_countdownText = image_title:getChildByName("text_countdown")
        ui_countdownText:setString(string.format(Lang.ui_activity_purchase_gift1, day, hour, minute, second))
    end
end

local function setUIData(_msgData)
    --全服拥有开启度|打开箱子的开启度|我的开启度|领奖状态0-未领取，1已领取
    local uiData = utils.stringSplit(_msgData.msgdata.string["1"], "|")

    --箱子里的物品
    local thingsData = utils.stringSplit(_msgData.msgdata.string["2"], ";")

    local image_basemap = UIActivityPurchaseGift.Widget:getChildByName("image_basemap")
    local image_box_info = image_basemap:getChildByName("image_box_info")
    local ui_boxImage = image_basemap:getChildByName("image_box")
    local btn_go = image_box_info:getChildByName("btn_go")
    local btn_get = image_box_info:getChildByName("btn_get")
    local btn_go_big = image_box_info:getChildByName("btn_go_big")
    _myOpenValue = tonumber(uiData[3])
    _isGetState = tonumber(uiData[4])
    image_box_info:getChildByName("text_me"):setString(Lang.ui_activity_purchase_gift2 .. _myOpenValue)
    image_box_info:getChildByName("text_need"):setString(string.format(Lang.ui_activity_purchase_gift3, tonumber(uiData[1]), tonumber(uiData[2])))
    ui_boxImage:loadTexture("ui/tg_box.png")
    ui_boxImage:setTouchEnabled(true)
    btn_get:setTitleText(Lang.ui_activity_purchase_gift4)
    btn_get:setBright(true)
    if _isGetState == 1 or _isOpenBox then
        if _isGetState == 1 then
            btn_get:setTitleText(Lang.ui_activity_purchase_gift5)
            btn_get:setBright(false)
        end
        ui_boxImage:setTouchEnabled(false)
        ui_boxImage:loadTexture("ui/tg_box_k.png")
        btn_go:setVisible(true)
        btn_get:setVisible(true)
        btn_go_big:setVisible(false)
    else
        --[[
        ui_boxImage:runAction(cc.RepeatForever:create(cc.Sequence:create(
    --        cc.Spawn:create(  ),
--            cc.DelayTime:create(3),
            cc.RotateTo:create(0.1, 5),
            cc.RotateTo:create(0.1, -5),
            cc.RotateTo:create(0.1, 5),
            cc.RotateTo:create(0.1, -5),
            cc.RotateTo:create(0.1, 5),
            cc.RotateTo:create(0.1, -5),
            cc.RotateTo:create(0.1, 0)
        )))
        --]]
    end
    ui_boxImage:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if tonumber(uiData[1]) >= tonumber(uiData[2]) then
                ui_boxImage:setTouchEnabled(false)
                local boxAnim = ActionManager.getUIAnimation(64, function(animation)
                    ui_boxImage:loadTexture("ui/tg_box_k.png")
                    ui_boxImage:setVisible(true)
                    btn_go:setVisible(true)
                    btn_get:setVisible(true)
                    btn_go_big:setVisible(false)
                    for key, obj in pairs(ui_thingItems) do
                        obj:setVisible(true)
                    end
                end)
                boxAnim:setLocalZOrder(999999)
                boxAnim:setPosition(cc.p(ui_boxImage:getPositionX() - 20, ui_boxImage:getPositionY() + 20))
                image_basemap:addChild(boxAnim)
                ui_boxImage:setVisible(false)
                local function onFrameEvent(bone, evt, originFrameIndex, currentFrameIndex)
                    if evt == "open_event" then
                        ui_boxImage:stopAllActions()
                        ui_boxImage:setRotation(0)
                        ui_boxImage:loadTexture("ui/tg_box_k.png")
                        ui_boxImage:setVisible(true)
                    end
                end
                boxAnim:getAnimation():setFrameEventCallFunc(onFrameEvent)
                _isOpenBox = true
            else
                UIManager.showToast(Lang.ui_activity_purchase_gift6)
            end
        end
    end)
    for key, obj in pairs(ui_thingItems) do
        if thingsData[key] then
            local itemProps = utils.getItemProp(thingsData[key])
            local ui_thingName = obj:getChildByName("text_good")
            local ui_thingIcon = obj:getChildByName("image_good")
            local ui_thingCount = obj:getChildByName("text_number")
            if itemProps.frameIcon then
                obj:loadTexture(itemProps.frameIcon)
            end
            if itemProps.smallIcon then
                ui_thingIcon:loadTexture(itemProps.smallIcon)
                utils.showThingsInfo(ui_thingIcon, itemProps.tableTypeId, itemProps.tableFieldId)
            end
            if itemProps.name then
                ui_thingName:setString(itemProps.name)
            end
            if itemProps.count then
                ui_thingCount:setString("×" .. itemProps.count)
            end
        end
        if _isGetState == 1 or _isOpenBox then
            obj:setVisible(true)
        end
    end
    if _isGetState ~= 1 and not _isOpenBox and tonumber(uiData[1]) >= tonumber(uiData[2]) then
        ui_boxImage:releaseUpEvent()
    end
end

function UIActivityPurchaseGift.onActivity(_params)
    DictActivity = _params
end

function UIActivityPurchaseGift.init()
    local image_basemap = UIActivityPurchaseGift.Widget:getChildByName("image_basemap")
    local image_box_info = image_basemap:getChildByName("image_box_info")
    local btn_go = image_box_info:getChildByName("btn_go")
    local btn_get = image_box_info:getChildByName("btn_get")
    local btn_go_big = image_box_info:getChildByName("btn_go_big")
    btn_go:setPressedActionEnabled(true)
    btn_get:setPressedActionEnabled(true)
    btn_go_big:setPressedActionEnabled(true)
    local function onBtnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_go or sender == btn_go_big then
                if DictActivity and DictActivity.uiTitle then
                    local childs = DictActivity.uiTitle:getChildren()
                    if childs[1] then
                        childs[1]:releaseUpEvent()
                    end
                end
            elseif sender == btn_get then
                if _isGetState == 0 then
                    if _myOpenValue >= DictSysConfig[tostring(StaticSysConfig.getGroupBoxThingScore)].value then
                        UIManager.showLoading()
                        netSendPackage({ header = StaticMsgRule.getGroupBoxReward, msgdata = {}}, function(_msgData)
                            UIManager.showToast(Lang.ui_activity_purchase_gift7)
                            UIActivityPurchaseGift.setup()
                        end)
                    else
                        UIManager.showToast(Lang.ui_activity_purchase_gift8)
                    end
                end
            end
        end
    end
    btn_go:addTouchEventListener(onBtnEvent)
    btn_get:addTouchEventListener(onBtnEvent)
    btn_go_big:addTouchEventListener(onBtnEvent)
    
    for i = 1, 4 do
        ui_thingItems[i] = image_basemap:getChildByName("image_frame_good" .. i)
    end
end

function UIActivityPurchaseGift.setup()
    UIManager.showLoading()
    netSendPackage({ header = StaticMsgRule.intoGroupGift, msgdata = { }}, function(_msgData)
        setUIData(_msgData)
    end)

    local image_basemap = UIActivityPurchaseGift.Widget:getChildByName("image_basemap")
    local image_title = image_basemap:getChildByName("image_title")
    local text_countdown = image_title:getChildByName("text_countdown")
    if DictActivity and DictActivity.time.startTime and DictActivity.time.endTime then
        dp.addTimerListener(countDowun)
        _countdownTime = utils.GetTimeByDate(DictActivity.time.endTime) - utils.getCurrentTime()
    else
        text_countdown:setString("")
    end
    local image_box_info = image_basemap:getChildByName("image_box_info")
    local btn_go = image_box_info:getChildByName("btn_go")
    local btn_get = image_box_info:getChildByName("btn_get")
    local btn_go_big = image_box_info:getChildByName("btn_go_big")
    local image_box = image_basemap:getChildByName("image_box")
    image_box:loadTexture("ui/tg_box.png")
    image_box:setTouchEnabled(false)
    image_box:stopAllActions()
    image_box:setRotation(0)
    for key, obj in pairs(ui_thingItems) do
        obj:setVisible(false)
    end
    btn_go:setVisible(false)
    btn_get:setVisible(false)
    btn_go_big:setVisible(true)
end

function UIActivityPurchaseGift.free()
    DictActivity = nil
    _countdownTime = 0
    _myOpenValue = 0
    _isGetState = 0
    dp.removeTimerListener(countDowun)
end

function UIActivityPurchaseGift.resetData()
    _isOpenBox = false
end

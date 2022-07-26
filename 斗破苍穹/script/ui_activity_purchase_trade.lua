require"Lang"
UIActivityPurchaseTrade = {}

local DictActivity = nil
local _countdownTime = 0

local function countDowun()
    _countdownTime = _countdownTime - 1
    if _countdownTime < 0 then
        _countdownTime = 0
    end
    if UIActivityPurchaseTrade.Widget then
        local day = math.floor(_countdownTime / 3600 / 24) --天
	    local hour = math.floor(_countdownTime / 3600 % 24) --小时
	    local minute = math.floor(_countdownTime / 60 % 60) --分
	    local second = math.floor(_countdownTime % 60) --秒
        local image_basemap = UIActivityPurchaseTrade.Widget:getChildByName("image_basemap")
        local ui_countdownText = image_basemap:getChildByName("text_countdown")
        ui_countdownText:setString(string.format(Lang.ui_activity_purchase_trade1, day, hour, minute, second))
    end
end

local function setUIData(_msgData)
    --全服已购数量
    local buyCount = _msgData.msgdata.int["1"]

    --折扣信息字典表
    local loadindBarData = utils.stringSplit(_msgData.msgdata.string["2"], "/")

    --物品价格[物品ID|原价|折扣价]
    local thingPriceData = utils.stringSplit(_msgData.msgdata.string["3"], "|")

    --已购和返利[已购个数|可返元宝数|拥有元宝数]
    local moneyData = utils.stringSplit(_msgData.msgdata.string["4"], "|")

    local image_basemap = UIActivityPurchaseTrade.Widget:getChildByName("image_basemap")
    local ui_text_buy_number = image_basemap:getChildByName("text_buy_number")
--    local ui_text_buy = image_basemap:getChildByName("text_buy")
--    local _spaceChars = ""
--    for i = 1, string.len(tostring(buyCount)) do
--        _spaceChars = _spaceChars .. " "
--    end
--    ui_text_buy:setString(string.format("全服已购：%s个", _spaceChars))
    ui_text_buy_number:setString(tostring(buyCount))

    local image_loading = image_basemap:getChildByName("image_loading")
    local ui_loadingBar = image_loading:getChildByName("bar_loading")
    local ui_points = {
        image_loading:getChildByName("image_nine"),
        image_loading:getChildByName("image_eight"),
        image_loading:getChildByName("image_seven"),
        image_loading:getChildByName("image_six"),
    }
    --id|starNum|endNum|discount
    local _loadingBarMaxValue = tonumber(utils.stringSplit(loadindBarData[#loadindBarData], "|")[3])
    ui_loadingBar:setPercent(utils.getPercent(buyCount, _loadingBarMaxValue))
    for key, obj in pairs(ui_points) do
        if loadindBarData[key] then
            local _tempData = utils.stringSplit(loadindBarData[key], "|")
            local _percent = utils.getPercent(tonumber(_tempData[2]), _loadingBarMaxValue) / 100
            local _posX = ui_loadingBar:getContentSize().width * _percent + (ui_loadingBar:getPositionX() - ui_loadingBar:getContentSize().width / 2)
            obj:setPositionX(_posX - obj:getContentSize().width / 2)
            ccui.Helper:seekNodeByName(obj, "text_number"):setString(_tempData[2])
            ccui.Helper:seekNodeByName(obj, "text_discount"):setString((tonumber(_tempData[4]) * 10) .. Lang.ui_activity_purchase_trade2)
            obj:setVisible(true)
        else
            obj:setVisible(false)
        end
    end

    local image_di_system = image_basemap:getChildByName("image_di_system")
    local ui_thingIcon = image_di_system:getChildByName("image_box")
    local image_di_price = image_di_system:getChildByName("image_di_price")
    local ui_oldPrice = image_di_price:getChildByName("image_gold_yuan"):getChildByName("text_gold_number")
    local ui_nowPrice = image_di_price:getChildByName("image_gold_xian"):getChildByName("text_gold_number")
    local ui_thingDesc = image_di_system:getChildByName("image_di_info"):getChildByName("text_info")
    local btn_buy = image_di_price:getChildByName("btn_exchange")
    local ui_buyed = image_di_system:getChildByName("text_buy")
    local ui_backMoney = image_di_system:getChildByName("image_gold_back"):getChildByName("text_number")
    local ui_haveMoney = image_di_system:getChildByName("image_gold_have"):getChildByName("text_number")
    local dictThingData = DictThing[thingPriceData[1]]
    if dictThingData then
        ui_thingIcon:loadTexture("image/" .. DictUI[tostring(dictThingData.bigUiId)].fileName)
        ui_thingDesc:setString(dictThingData.description)
    end
    ui_oldPrice:setString(thingPriceData[2])
    ui_nowPrice:setString(thingPriceData[3])
    ui_buyed:setString(Lang.ui_activity_purchase_trade3 .. moneyData[1])
    ui_backMoney:setString(moneyData[2])
    ui_haveMoney:setString(moneyData[3])
    btn_buy:setPressedActionEnabled(true)
    btn_buy:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if _countdownTime > 0 then
                if tonumber(ui_haveMoney:getString()) >= tonumber(ui_nowPrice:getString()) then
                    if dictThingData then
                        UISellProp.setData({thingData=dictThingData, price=tonumber(thingPriceData[2])}, UIActivityPurchaseTrade, function()
                            UIManager.showToast(Lang.ui_activity_purchase_trade4)
                            local _pos = ui_thingIcon:getParent():convertToWorldSpace(cc.p(ui_thingIcon:getPositionX(), ui_thingIcon:getPositionY()))
                            local _curBarPosX = (ui_loadingBar:getPercent() / 100 * ui_loadingBar:getContentSize().width) - (ui_loadingBar:getContentSize().width / 2)
                            local _loadingBarPos = ui_loadingBar:getParent():convertToWorldSpace(cc.p(ui_loadingBar:getPositionX() + _curBarPosX, ui_loadingBar:getPositionY()))
                            local effect = cc.ParticleSystemQuad:create("particle/star/ui_anim60_lizi02.plist")
				            effect:setPosition(cc.p(_pos.x, _pos.y))
                            effect:runAction(cc.Sequence:create(cc.MoveTo:create(0.8, _loadingBarPos), cc.CallFunc:create(function()
                                if effect then
                                    effect:removeFromParent()
                                end
                                UIActivityPurchaseTrade.setup()
                            end)))
				            UIActivityPurchaseTrade.Widget:addChild(effect, 100)
                        end)
                        UIManager.pushScene("ui_sell_prop")
                    end
                else
                    UIManager.showToast(Lang.ui_activity_purchase_trade5)
                end
            else
                UIManager.showToast(Lang.ui_activity_purchase_trade6)
            end
        end
    end)
end

function UIActivityPurchaseTrade.onActivity(_params)
    DictActivity = _params
end

function UIActivityPurchaseTrade.init()
    local image_basemap = UIActivityPurchaseTrade.Widget:getChildByName("image_basemap")
    local btn_rank = image_basemap:getChildByName("btn_rank")
    local btn_help = image_basemap:getChildByName("btn_help")
    btn_rank:setPressedActionEnabled(true)
    btn_help:setPressedActionEnabled(true)
    local function onBtnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_rank then
                UIActivityPurchaseRank.show()
            elseif sender == btn_help then
                UIAllianceHelp.show({titleName=Lang.ui_activity_purchase_trade7,type=16})
            end
        end
    end
    btn_rank:addTouchEventListener(onBtnEvent)
    btn_help:addTouchEventListener(onBtnEvent)
end

function UIActivityPurchaseTrade.setup()
    UIManager.showLoading()
    netSendPackage({ header = StaticMsgRule.intoGroup, msgdata = { }}, function(_msgData)
        setUIData(_msgData)
    end)

    local image_basemap = UIActivityPurchaseTrade.Widget:getChildByName("image_basemap")
    local ui_timeText = image_basemap:getChildByName("text_time")
    local text_countdown = image_basemap:getChildByName("text_countdown")
    if DictActivity and DictActivity.time.startTime and DictActivity.time.endTime then
        dp.addTimerListener(countDowun)
        local _startTime = utils.changeTimeFormat(DictActivity.time.startTime)
		local _endTime = utils.changeTimeFormat(DictActivity.time.endTime)
        ui_timeText:setString(string.format(Lang.ui_activity_purchase_trade8, _startTime[2],_startTime[3],_startTime[5],_endTime[2],_endTime[3],_endTime[5]))
        _countdownTime = utils.GetTimeByDate(DictActivity.time.endTime) - utils.getCurrentTime()
    else
        ui_timeText:setString(Lang.ui_activity_purchase_trade9)
        text_countdown:setString("")
    end
end

function UIActivityPurchaseTrade.free()
    DictActivity = nil
    _countdownTime = 0
    dp.removeTimerListener(countDowun)
end

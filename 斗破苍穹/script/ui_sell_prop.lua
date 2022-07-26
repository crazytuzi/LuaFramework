require"Lang"
UISellProp = { }

local ui_selectedNum = nil -- 需要卖出的数量
local ui_predictMoney = nil -- 预计获得金钱数
local _uiItem = nil
local _thingInstData = nil -- 物品实例数据
local _haveNum = nil -- 拥有数量
local _unitPrice = nil -- 单价
local _callbackFunc = nil

local function netCallbackFunc(data)
    AudioEngine.playEffect("sound/gold.mp3")
    local code = tonumber(data.header)
    if code == StaticMsgRule.fightSoulBuySilver then
        UIManager.showToast(Lang.ui_sell_prop1)
        if _uiItem == UISoulGet then
            UIManager.flushWidget(UISoulGet)
        end
    elseif code == StaticMsgRule.sell then
        UIManager.showToast(Lang.ui_sell_prop2 .. ui_predictMoney:getString() .. Lang.ui_sell_prop3)
        if _uiItem == UIBag then
            UIManager.flushWidget(UIBag)
            UIManager.flushWidget(UITeamInfo)
        elseif _uiItem == UIBagEquipmentSell then
            UIManager.flushWidget(UITeamInfo)
            UIManager.flushWidget(UIBagEquipmentSell)
        elseif _uiItem == UIBagWingSell then
            UIManager.flushWidget(UIBagWingSell)
            UIManager.flushWidget(UIBagWing)
        elseif _uiItem == UISoulGet then
            UIManager.flushWidget(UISoulGet)
        end
        UIManager.flushWidget(UISellProp)
    elseif code == StaticMsgRule.deletePillRecipe then
        UIManager.flushWidget(UIDanFang)
        UIManager.showToast(Lang.ui_sell_prop4 .. ui_predictMoney:getString() .. Lang.ui_sell_prop5)
    elseif code == StaticMsgRule.deletePill or code == StaticMsgRule.deletePillThing then
        UIManager.flushWidget(UIDanYao)
        UIManager.showToast(Lang.ui_sell_prop6 .. ui_predictMoney:getString() .. Lang.ui_sell_prop7)
    elseif code == StaticMsgRule.buy then
        if _callbackFunc then
            _callbackFunc()
        else
            if DictThing[tostring(_thingInstData.int["thingId"])].bagTypeId == 1 then
                UIShop.isFlush = true
                UIShop.getShopList(1)
            elseif DictThing[tostring(_thingInstData.int["thingId"])].bagTypeId == 2 then
                UIManager.flushWidget(UIShop)
            end
            UIManager.showToast(Lang.ui_sell_prop8)
            if DictThing[tostring(_thingInstData.int["thingId"])].name == Lang.ui_sell_prop9 then
                -- 加统计消耗
                cclog("统计至尊宝盒")
                local item = { Lang.ui_sell_prop10, tonumber(ui_selectedNum:getString()), tonumber(DictThing[tostring(_thingInstData.int["thingId"])].buyGold) }
                SDK.tdDoOnPurchase(item)
            end
        end
    elseif code == StaticMsgRule.thingUse then
        local _dictThingId = _thingInstData.int["3"]
        local usePrompt = ""
        if StaticThing.energyPill == _dictThingId then
            usePrompt = "+" .. ui_predictMoney:getString() .. Lang.ui_sell_prop11
        elseif StaticThing.vigorPill == _dictThingId then
            usePrompt = "+" .. ui_predictMoney:getString() .. Lang.ui_sell_prop12
        elseif StaticThing.silverNote5000 == _dictThingId or StaticThing.silverNote10000 == _dictThingId then
            usePrompt = "+" .. ui_predictMoney:getString() .. Lang.ui_sell_prop13
        end
        UIManager.showToast(usePrompt)
        UIManager.flushWidget(UIBag)
        UIManager.flushWidget(UITeamInfo)
    elseif code == StaticMsgRule.arenaConvert then
        UIManager.showToast(Lang.ui_sell_prop14)
        UIArena.refreshExchangeList()
    elseif code == StaticMsgRule.overflowExchange then
        UIManager.showToast(Lang.ui_sell_prop15)
        UIManager.flushWidget(UIActivityNormalExchange)
        if UIActivityTime.Widget and UIActivityTime.Widget:getParent() then
            UIActivityTime.refreshMoney()
        end
    elseif code == StaticMsgRule.overflowExchangeTwo then
        UIManager.showToast(Lang.ui_sell_prop16)
        UIManager.flushWidget(UIActivityNormalExchangeTwo)
        if UIActivityTime.Widget and UIActivityTime.Widget:getParent() then
            UIActivityTime.refreshMoney()
        end
    elseif code == StaticMsgRule.store then
        UIManager.showToast(Lang.ui_sell_prop17)
        UIManager.flushWidget(UITowerShop)
    elseif code == StaticMsgRule.exchangeBossShop then
        if _callbackFunc then
            _callbackFunc(tonumber(ui_selectedNum:getString()))
        end
    elseif code == StaticMsgRule.buyGroupBox then
        if _callbackFunc then
            _callbackFunc()
        end
    elseif code == StaticMsgRule.challengeBuy then
        UIManager.showToast(Lang.ui_sell_prop18)
        if _callbackFunc then
            _callbackFunc( data )
        end
    end
    UIManager.popScene()
end

local function sendData()
    local sendData = nil
    if _uiItem == UIDanFang then
        sendData = {
            header = StaticMsgRule.deletePillRecipe,
            msgdata =
            {
                int =
                {
                    instPlayerPillRecipeId = _thingInstData.int["1"],
                    num = tonumber(ui_selectedNum:getString())
                }
            }
        }
    elseif _uiItem == UIDanYao then
        if _uiItem.getShowType() == _uiItem.ShowType.ShowDanYao then
            sendData = {
                header = StaticMsgRule.deletePill,
                msgdata =
                {
                    int =
                    {
                        instPlayerPillId = _thingInstData.int["1"],
                        num = tonumber(ui_selectedNum:getString())
                    }
                }
            }
        elseif _uiItem.getShowType() == _uiItem.ShowType.ShowYaoCai then
            sendData = {
                header = StaticMsgRule.deletePillThing,
                msgdata =
                {
                    int =
                    {
                        instPlayerPillThingId = _thingInstData.int["1"],
                        num = tonumber(ui_selectedNum:getString())
                    }
                }
            }
        end
    elseif _uiItem == UIBag then
        sendData = {
            header = StaticMsgRule.sell,
            msgdata =
            {
                int =
                {
                    buyNum = tonumber(ui_selectedNum:getString()),
                    type = 1,
                },
                string =
                {
                    sellIds = _thingInstData.int["1"],
                }
            }
        }
    elseif _uiItem == UIBagWingSell then
        sendData = {
            header = StaticMsgRule.sell,
            msgdata =
            {
                int =
                {
                    buyNum = tonumber(ui_selectedNum:getString()),
                    type = 1,
                },
                string =
                {
                    sellIds = _thingInstData.int["1"],
                }
            }
        }
    elseif _uiItem == "UIBagUse" then
        sendData = {
            header = StaticMsgRule.thingUse,
            msgdata =
            {
                int =
                {
                    instPlayerThingId = _thingInstData.int["1"],
                    num = tonumber(ui_selectedNum:getString()),
                }
            }
        }
    elseif _uiItem == UIBagEquipmentSell then
        sendData = {
            header = StaticMsgRule.sell,
            msgdata =
            {
                int =
                {
                    buyNum = tonumber(ui_selectedNum:getString()),
                    type = 3,
                },
                string =
                {
                    sellIds = _thingInstData.int["1"],
                }
            }
        }
    elseif _uiItem == UIShop then
        sendData = {
            header = StaticMsgRule.buy,
            msgdata =
            {
                int =
                {
                    thingId = _thingInstData.int["thingId"],
                    type = DictThing[tostring(_thingInstData.int["thingId"])].bagTypeId,
                    num = tonumber(ui_selectedNum:getString()),
                }
            }
        }
    elseif _uiItem == UIArena then
        sendData = {
            header = StaticMsgRule.arenaConvert,
            msgdata =
            {
                int =
                {
                    instPlayerArenaId = net.InstPlayerArena.int["1"],
                    -- 玩家竞技场实例Id
                    arenaConvertId = _thingInstData.id,
                    -- 竞技场兑换字典Id
                    convertNum = tonumber(ui_selectedNum:getString())-- 兑换次数
                }
            }
        }
    elseif _uiItem == UIActivityNormalExchange then
        sendData = { header = StaticMsgRule.overflowExchange, msgdata = { int = { id = _thingInstData.id, count = tonumber(ui_selectedNum:getString()) } } }
    elseif _uiItem == UIActivityNormalExchangeTwo then
        sendData = { header = StaticMsgRule.overflowExchangeTwo, msgdata = { int = { id = _thingInstData.id, count = tonumber(ui_selectedNum:getString()) } } }
    elseif _uiItem == UITowerShop then
        sendData = {
            header = StaticMsgRule.store,
            msgdata =
            {
                int =
                {
                    instPlayerPagodaId = net.InstPlayerPagoda.int["1"],
                    dictPagodaStoreId = _thingInstData.id,
                    num = tonumber(ui_selectedNum:getString())-- 兑换次数
                }
            }
        }
    elseif _uiItem == UISoulGet then
        if _thingInstData.type == 1 then
            sendData = {
                header = StaticMsgRule.fightSoulBuySilver,
                msgdata =
                {
                    int =
                    {
                        num = tonumber(ui_selectedNum:getString())-- 兑换次数
                    }
                }
            }
        elseif _thingInstData.type == 2 then
            sendData = {
                header = StaticMsgRule.sell,
                msgdata =
                {
                    int =
                    {
                        buyNum = tonumber(ui_selectedNum:getString()),
                        type = 1,
                    },
                    string =
                    {
                        sellIds = _thingInstData.thingsId,
                    }
                }
            }
        end
    elseif _uiItem == UIBossShop then
        sendData = {
            header = StaticMsgRule.exchangeBossShop,
            msgdata =
            {
                int =
                {
                    bossShopId = _thingInstData.id,
                    num = tonumber(ui_selectedNum:getString())-- 兑换次数
                }
            }
        }
    elseif _uiItem == UIActivityPurchaseTrade then
        sendData = {
            header = StaticMsgRule.buyGroupBox,
            msgdata =
            {
                int =
                {
                    num = tonumber(ui_selectedNum:getString())-- 购买次数
                }
            }
        }
    elseif _uiItem == UIActivityGoddess then
        sendData = {
            header = StaticMsgRule.buy,
            msgdata =
            {
                int =
                {
                    thingId = _thingInstData.thingId,
                    type = DictThing[tostring(_thingInstData.thingId)].bagTypeId,
                    num = tonumber(ui_selectedNum:getString()),
                }
            }
        }
    elseif _uiItem == UIGame or _uiItem == UIGameChallenge then
        sendData = {
            header = StaticMsgRule.challengeBuy , 
            msgdata = {
                int = {
                    count = tonumber(ui_selectedNum:getString())-- 购买次数
                }
            }
        }
    end
    UIManager.showLoading()
    netSendPackage(sendData, netCallbackFunc)
end

function UISellProp.init()
    local btn_close = ccui.Helper:seekNodeByName(UISellProp.Widget, "btn_close")
    local ui_image_base_sell = ccui.Helper:seekNodeByName(UISellProp.Widget, "image_base_sell")
    local ui_sub10 = ccui.Helper:seekNodeByName(ui_image_base_sell, "btn_cut_ten")
    local ui_sub = ccui.Helper:seekNodeByName(ui_image_base_sell, "btn_cut")
    local ui_add10 = ccui.Helper:seekNodeByName(ui_image_base_sell, "btn_add_ten")
    local ui_add = ccui.Helper:seekNodeByName(ui_image_base_sell, "btn_add")
    ui_selectedNum = ccui.Helper:seekNodeByName(ui_image_base_sell, "text_number")
    local ui_image_base_earnings = ccui.Helper:seekNodeByName(UISellProp.Widget, "image_base_earnings_info")
    ui_predictMoney = ccui.Helper:seekNodeByName(ui_image_base_earnings, "text_number_predict")
    local btn_sure = ccui.Helper:seekNodeByName(UISellProp.Widget, "btn_sure")
    local btn_undo = ccui.Helper:seekNodeByName(UISellProp.Widget, "btn_undo")

    btn_close:setPressedActionEnabled(true)
    btn_sure:setPressedActionEnabled(true)
    btn_undo:setPressedActionEnabled(true)
    ui_sub10:setPressedActionEnabled(true)
    ui_sub:setPressedActionEnabled(true)
    ui_add10:setPressedActionEnabled(true)
    ui_add:setPressedActionEnabled(true)
    local function btnTouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioEngine.playEffect("sound/button.mp3")
            if sender == btn_close or sender == btn_undo then
                UIManager.popScene()
            elseif sender == btn_sure then
                if tonumber(ui_selectedNum:getString()) > 0 then
                    if _uiItem == UIShop or _uiItem == UIActivityPurchaseTrade then
                        if net.InstPlayer.int["5"] >= tonumber(ui_predictMoney:getString()) then
                            sendData()
                        else
                            UIManager.showToast(Lang.ui_sell_prop19)
                        end
                    elseif _uiItem == UIArena then
                        if net.InstPlayer.int["39"] >= tonumber(ui_predictMoney:getString()) then
                            sendData()
                        else
                            UIManager.showToast(Lang.ui_sell_prop20)
                        end
                    elseif _uiItem == UITowerShop then
                        if net.InstPlayer.int["21"] >= tonumber(ui_selectedNum:getString()) * _unitPrice then
                            sendData()
                        else
                            UIManager.showToast(Lang.ui_sell_prop21)
                        end
                    elseif _uiItem == UIBossShop then
                        if _thingInstData.bossIntergral >= tonumber(ui_selectedNum:getString()) * _unitPrice then
                            sendData()
                        else
                            UIManager.showToast(Lang.ui_sell_prop22)
                        end
                    else
                        sendData()
                    end
                else
                    if _uiItem == UIShop or _uiItem == UIActivityPurchaseTrade then
                        UIManager.showToast(Lang.ui_sell_prop23)
                    elseif _uiItem == UIArena or _uiItem == UIActivityNormalExchange or  _uiItem == UIActivityNormalExchangeTwo then
                        UIManager.showToast(Lang.ui_sell_prop24)
                    elseif _uiItem == "UIBagUse" then
                        UIManager.showToast(Lang.ui_sell_prop25)
                    elseif _uiItem == UITowerShop then
                        UIManager.showToast(Lang.ui_sell_prop26)
                    elseif _uiItem == UISoulGet then
                        if _thingInstData.type == 1 then
                            UIManager.showToast(Lang.ui_sell_prop27)
                        else
                            UIManager.showToast(Lang.ui_sell_prop28)
                        end
                    elseif _uiItem == UIBossShop then
                        UIManager.showToast(Lang.ui_sell_prop29)
                    elseif _uiItem == UIActivityGoddess then
                        UIManager.showToast(Lang.ui_sell_prop30)
                    elseif _uiItem == UIGame or _uiItem == UIGameChallenge then
                        UIManager.showToast(Lang.ui_sell_prop31)
                    else
                        UIManager.showToast(Lang.ui_sell_prop32)
                    end
                end
            end
        end
    end
    btn_close:addTouchEventListener(btnTouchEvent)
    btn_sure:addTouchEventListener(btnTouchEvent)
    btn_undo:addTouchEventListener(btnTouchEvent)

    local function addOrcutEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local number = tonumber(ui_selectedNum:getString())
            local canBuyNum = math.floor(net.InstPlayer.int["5"] / _unitPrice)
            if _uiItem == UIShop or _uiItem == UIActivityPurchaseTrade then
                canBuyNum = math.floor(net.InstPlayer.int["5"] / math.round(_unitPrice * UIShop.disCount))
            end
            if sender == ui_sub10 then
                if number >= 10 then
                    number = number - 10
                elseif number > 1 and number < 10 then
                    number = 1
                end
            elseif sender == ui_sub then
                if number > 0 then
                    number = number - 1
                end
            elseif sender == ui_add10 then
                if _uiItem == UIShop or _uiItem == UIActivityPurchaseTrade then
                    if _thingInstData.int and _thingInstData.int["canBuyNum"] ~= nil and _thingInstData.int["canBuyNum"] ~= -1 then
                        if number + 10 <= _thingInstData.int["canBuyNum"] then
                            number = number + 10
                        elseif number > _thingInstData.int["canBuyNum"] -10 and number < _thingInstData.int["canBuyNum"] then
                            number = _thingInstData.int["canBuyNum"]
                        else
                            UIManager.showToast(Lang.ui_sell_prop33 .. _thingInstData.int["canBuyNum"] .. Lang.ui_sell_prop34)
                        end
                    else
                        if number + 10 <= canBuyNum then
                            number = number + 10
                        elseif number > canBuyNum - 10 and number < canBuyNum then
                            number = canBuyNum
                        else
                            UIManager.showToast(Lang.ui_sell_prop35)
                        end
                    end
                elseif _uiItem == UIArena or _uiItem == UIActivityNormalExchange  or _uiItem == UIActivityNormalExchangeTwo then
                    if number + 10 <= _thingInstData.convertNum then
                        number = number + 10
                    elseif number > _thingInstData.convertNum - 10 and number < _thingInstData.convertNum then
                        number = _thingInstData.convertNum
                    elseif _uiItem == UIActivityNormalExchange  or _uiItem == UIActivityNormalExchangeTwo then
                        UIManager.showToast(Lang.ui_sell_prop36 .. _thingInstData.convertNum .. Lang.ui_sell_prop37)
                    else
                        UIManager.showToast(Lang.ui_sell_prop38 .. _thingInstData.convertNum .. Lang.ui_sell_prop39)
                    end
                elseif _uiItem == UITowerShop then
                    if number <= math.floor(net.InstPlayer.int["21"] / _unitPrice) -10 then
                        number = number + 10
                    elseif number < math.floor(net.InstPlayer.int["21"] / _unitPrice) then
                        number = math.floor(net.InstPlayer.int["21"] / _unitPrice)
                    else
                        UIManager.showToast(Lang.ui_sell_prop40)
                    end
                elseif _uiItem == UISoulGet then
                    if _thingInstData.type == 1 then
                        if number < _thingInstData.num - 10 then
                            number = number + 10
                        elseif number < _thingInstData.num then
                            number = _thingInstData.num
                        else
                            UIManager.showToast(Lang.ui_sell_prop41)
                        end
                    elseif _thingInstData.type == 2 then
                        if number < _thingInstData.num - 10 then
                            number = number + 10
                        elseif number < _thingInstData.num then
                            number = _thingInstData.num
                        end
                    end
                elseif _uiItem == UIBossShop then
                    if number <= math.floor(_thingInstData.bossIntergral / _unitPrice) -10 then
                        number = number + 10
                    elseif number < math.floor(_thingInstData.bossIntergral / _unitPrice) then
                        number = math.floor(_thingInstData.bossIntergral / _unitPrice)
                    else
                        UIManager.showToast(Lang.ui_sell_prop42)
                    end
                elseif _uiItem == UIActivityGoddess then
                    number = number + 10
                elseif _uiItem == UIGame or _uiItem == UIGameChallenge then
                    if number <= _haveNum - 10 then
                        number = number + 10
                    elseif number > _haveNum - 10 and number < _haveNum then
                        number = _haveNum
                    else
                        UIManager.showToast(Lang.ui_sell_prop43)
                    end
                else
                    if number <= _haveNum - 10 then
                        number = number + 10
                    elseif number > _haveNum - 10 and number < _haveNum then
                        number = _haveNum
                    else
                        UIManager.showToast(Lang.ui_sell_prop44)
                    end
                end
            elseif sender == ui_add then
                if _uiItem == UIShop or _uiItem == UIActivityPurchaseTrade then
                    if _thingInstData.int and _thingInstData.int["canBuyNum"] ~= nil and _thingInstData.int["canBuyNum"] ~= -1 then
                        if number < _thingInstData.int["canBuyNum"] then
                            number = number + 1
                        else
                            UIManager.showToast(Lang.ui_sell_prop45 .. _thingInstData.int["canBuyNum"] .. Lang.ui_sell_prop46)
                        end
                    else
                        if number < canBuyNum then
                            number = number + 1
                        else
                            UIManager.showToast(Lang.ui_sell_prop47)
                        end
                    end
                elseif _uiItem == UIArena or _uiItem == UIActivityNormalExchange  or _uiItem == UIActivityNormalExchangeTwo then
                    if number < _thingInstData.convertNum then
                        number = number + 1
                    else
                        UIManager.showToast(Lang.ui_sell_prop48 .. _thingInstData.convertNum .. Lang.ui_sell_prop49)
                    end
                elseif _uiItem == UITowerShop then
                    if number < math.floor(net.InstPlayer.int["21"] / _unitPrice) then
                        number = number + 1
                    else
                        UIManager.showToast(Lang.ui_sell_prop50)
                    end
                elseif _uiItem == UISoulGet then
                    if _thingInstData.type == 1 then
                        if number < _thingInstData.num then
                            number = number + 1
                        else
                            UIManager.showToast(Lang.ui_sell_prop51)
                        end
                    elseif _thingInstData.type == 2 then
                        if number < _thingInstData.num then
                            number = number + 1
                        end
                    end
                elseif _uiItem == UIBossShop then
                    if number < math.floor(_thingInstData.bossIntergral / _unitPrice) then
                        number = number + 1
                    else
                        UIManager.showToast(Lang.ui_sell_prop52)
                    end
                elseif _uiItem == UIActivityGoddess then
                    number = number + 1
                elseif _uiItem == UIGame or _uiItem == UIGameChallenge then
                    if number < _haveNum then
                        number = number + 1
                    else
                        UIManager.showToast(Lang.ui_sell_prop53)
                    end
                else
                    if number < _haveNum then
                        number = number + 1
                    else
                        UIManager.showToast(Lang.ui_sell_prop54)
                    end
                end
            end
            ui_selectedNum:setString(tostring(number))
            if _uiItem == UIShop and(_thingInstData.int["thingId"] == StaticThing.vigorPill or _thingInstData.int["thingId"] == StaticThing.energyPill) then
                local _buyPrice = 0
                local _todayBuyNum = _thingInstData.int["todayBuyNum"] + number
                local _extend = utils.stringSplit(DictThingExtend[tostring(_thingInstData.int["thingId"])].extend, ";")
                for _i = _thingInstData.int["todayBuyNum"] + 1, _todayBuyNum do
                    for _k, _o in pairs(_extend) do
                        local _tempO = utils.stringSplit(_o, "_")
                        if _i >= tonumber(_tempO[1]) and _i <= tonumber(_tempO[2]) then
                            _buyPrice = _buyPrice + tonumber(_tempO[3])
                            break
                        end
                    end
                end
                ui_predictMoney:setString(tostring(math.round(_buyPrice * UIShop.disCount)))
            elseif _uiItem == UISoulGet and _thingInstData.type == 1 then
                local ui_textHint = ccui.Helper:seekNodeByName(UISellProp.Widget, "text_hint")
                ui_textHint:setString(Lang.ui_sell_prop55 .. number * DictSysConfig[tostring(StaticSysConfig.silverNoteToCopper)].value .. Lang.ui_sell_prop56)
                ui_predictMoney:setString(tostring(number * _unitPrice))
            elseif _uiItem == UIShop then
                ui_predictMoney:setString(tostring(math.round(number * _unitPrice * UIShop.disCount)))
            elseif _uiItem == UIGame or _uiItem == UIGameChallenge then
                local pri = 0
                for i = 1 , number do
                    pri = pri + DictChallengeBuyPrice[ tostring( 10 - _haveNum + i ) ].price
                end
                ui_predictMoney:setString(tostring(pri))
            else
                ui_predictMoney:setString(tostring(number * _unitPrice))
            end
        end
    end
    ui_sub10:addTouchEventListener(addOrcutEvent)
    ui_sub:addTouchEventListener(addOrcutEvent)
    ui_add10:addTouchEventListener(addOrcutEvent)
    ui_add:addTouchEventListener(addOrcutEvent)
end

function UISellProp.setup()
    UISellProp.Widget:setEnabled(true)
    local ui_imageIcon = ccui.Helper:seekNodeByName(UISellProp.Widget, "image_get")
    local ui_moneyTotalText = ccui.Helper:seekNodeByName(UISellProp.Widget, "text_get_predict")
    local ui_image_hint = ccui.Helper:seekNodeByName(UISellProp.Widget, "image_base_hint_price")
    local ui_title = ccui.Helper:seekNodeByName(UISellProp.Widget, "text_sell")
    local ui_haveNum = ccui.Helper:seekNodeByName(UISellProp.Widget, "text_have_number")
    local ui_textHint = ccui.Helper:seekNodeByName(UISellProp.Widget, "text_hint")
    ui_selectedNum:setString("1")
    if _thingInstData then
        if _uiItem == UIDanFang or _uiItem == UIDanYao then
            local dictData = nil
            if _uiItem == UIDanFang then
                ui_title:setString(Lang.ui_sell_prop57)
                dictData = DictPillRecipe[tostring(_thingInstData.int["3"])]
            elseif _uiItem == UIDanYao then
                if _uiItem.getShowType() == _uiItem.ShowType.ShowDanYao then
                    ui_title:setString(Lang.ui_sell_prop58)
                    dictData = DictPill[tostring(_thingInstData.int["3"])]
                elseif _uiItem.getShowType() == _uiItem.ShowType.ShowYaoCai then
                    ui_title:setString(Lang.ui_sell_prop59)
                    dictData = DictPillThing[tostring(_thingInstData.int["3"])]
                end
            end
            ui_imageIcon:loadTexture("ui/yin.png")
            _haveNum = _thingInstData.int["4"]
            ui_haveNum:setVisible(true)
            ui_haveNum:setString(Lang.ui_sell_prop60 .. _haveNum)
            ui_moneyTotalText:setString(Lang.ui_sell_prop61)
            ui_textHint:setString(string.format(Lang.ui_sell_prop62, dictData.name))
            _unitPrice = dictData.sellCopper
            ui_image_hint:setVisible(false)
        elseif _uiItem == UIBag or _uiItem == UIBagEquipmentSell then
            if _uiItem == UIBag then
                ui_title:setString(Lang.ui_sell_prop63)
            else
                ui_title:setString(Lang.ui_sell_prop64)
            end
            ui_imageIcon:loadTexture("ui/yin.png")
            _haveNum = _thingInstData.int["5"]
            if _thingInstData.int["3"] == StaticThing.goldBox then
                _haveNum = _haveNum + _thingInstData.int["4"]
            end
            ui_haveNum:setVisible(true)
            ui_haveNum:setString(Lang.ui_sell_prop65 .. _haveNum)
            ui_moneyTotalText:setString(Lang.ui_sell_prop66)
            ui_textHint:setString(string.format(Lang.ui_sell_prop67, DictThing[tostring(_thingInstData.int["3"])].name))
            _unitPrice = DictThing[tostring(_thingInstData.int["3"])].sellCopper
            ui_image_hint:setVisible(false)
        elseif _uiItem == UIBagWingSell then
            ui_title:setString(Lang.ui_sell_prop68)
            ui_imageIcon:loadTexture("ui/yin.png")
            _haveNum = _thingInstData.int["5"]
            ui_haveNum:setVisible(true)
            ui_haveNum:setString(Lang.ui_sell_prop69 .. _haveNum)
            ui_moneyTotalText:setString(Lang.ui_sell_prop70)
            ui_textHint:setString(string.format(Lang.ui_sell_prop71, DictThing[tostring(_thingInstData.int["3"])].name))
            _unitPrice = DictThing[tostring(_thingInstData.int["3"])].sellCopper
        elseif _uiItem == "UIBagUse" then
            --- 背包物品的使用
            ui_title:setString(Lang.ui_sell_prop72)
            local _dictThingId = _thingInstData.int["3"]
            if StaticThing.energyPill == _dictThingId then
                _unitPrice = DictSysConfig[tostring(StaticSysConfig.energyPillEnergy)].value
                ui_imageIcon:loadTexture("ui/zd_tili.png")
            elseif StaticThing.vigorPill == _dictThingId then
                _unitPrice = DictSysConfig[tostring(StaticSysConfig.vigorPillVigor)].value
                ui_imageIcon:loadTexture("ui/zd_naili.png")
            elseif StaticThing.silverNote10000 == _dictThingId then
                _unitPrice = DictThing[tostring(_dictThingId)].sellCopper
                ui_imageIcon:loadTexture("ui/yin.png")
            elseif StaticThing.silverNote5000 == _dictThingId then
                _unitPrice = DictThing[tostring(_dictThingId)].sellCopper
                ui_imageIcon:loadTexture("ui/yin.png")
            end
            _haveNum = _thingInstData.int["5"]
            ui_haveNum:setVisible(true)
            ui_haveNum:setString(Lang.ui_sell_prop73 .. _haveNum)
            ui_moneyTotalText:setString(Lang.ui_sell_prop74)
            ui_textHint:setString(string.format(Lang.ui_sell_prop75, DictThing[tostring(_dictThingId)].name))
            ui_image_hint:setVisible(false)
        elseif _uiItem == UIShop then
            ui_haveNum:setVisible(false)
            ui_moneyTotalText:setString(Lang.ui_sell_prop76)
            if _thingInstData.int["thingId"] == StaticThing.vigorPill or _thingInstData.int["thingId"] == StaticThing.energyPill then
                local _todayBuyPrice = 0
                local _todayBuyNum = _thingInstData.int["todayBuyNum"] + 1
                local _extend = utils.stringSplit(DictThingExtend[tostring(_thingInstData.int["thingId"])].extend, ";")
                for _k, _o in pairs(_extend) do
                    local _tempO = utils.stringSplit(_o, "_")
                    if _todayBuyNum >= tonumber(_tempO[1]) and _todayBuyNum <= tonumber(_tempO[2]) then
                        _todayBuyPrice = tonumber(_tempO[3])
                        break
                    end
                end
                _unitPrice = _todayBuyPrice
            else
                _unitPrice = _thingInstData.int["price"]
            end
            ui_imageIcon:loadTexture("ui/jin.png")
            ui_textHint:setString(string.format(Lang.ui_sell_prop77, DictThing[tostring(_thingInstData.int["thingId"])].name))
            if DictThing[tostring(_thingInstData.int["thingId"])].bagTypeId == 1 and DictThing[tostring(_thingInstData.int["thingId"])].thingTypeId ~= 3 then
                ui_title:setString(Lang.ui_sell_prop78)
                if _thingInstData.int["thingId"] == StaticThing.energyPill or _thingInstData.int["thingId"] == StaticThing.vigorPill then
                    ui_image_hint:setVisible(true)
                end
            elseif DictThing[tostring(_thingInstData.int["thingId"])].bagTypeId == 2 and DictThing[tostring(_thingInstData.int["thingId"])].thingTypeId ~= 3 then
                ui_title:setString(Lang.ui_sell_prop79)
                ui_image_hint:setVisible(false)
            end
        elseif _uiItem == UIArena then
            local itemName = ""
            if _thingInstData.tableTypeId == StaticTableType.DictPill then
                local dictPill = DictPill[tostring(_thingInstData.tableFieldId)]
                itemName = dictPill.name
            elseif _thingInstData.tableTypeId == StaticTableType.DictThing then
                local dictThing = DictThing[tostring(_thingInstData.tableFieldId)]
                itemName = dictThing.name
            elseif _thingInstData.tableTypeId == StaticTableType.DictEquipment then
                local dictEquipment = DictEquipment[tostring(_thingInstData.tableFieldId)]
                itemName = dictEquipment.name
            elseif _thingInstData.tableTypeId == StaticTableType.DictCard then
                local dictCard = DictCard[tostring(_thingInstData.tableFieldId)]
                itemName = dictCard.name
            elseif _thingInstData.tableTypeId == StaticTableType.DictCardSoul then
                local dictCardSoul = DictCardSoul[tostring(_thingInstData.tableFieldId)]
                itemName = dictCardSoul.name
            elseif _thingInstData.tableTypeId == StaticTableType.DictChip then
                local dictChip = DictChip[tostring(_thingInstData.tableFieldId)]
                itemName = dictChip.name
            end
            _haveNum = 0
            if net.InstPlayer then
                _haveNum = net.InstPlayer.int["39"]
            end
            ui_title:setString(Lang.ui_sell_prop80)
            ui_imageIcon:loadTexture("ui/weiwang.png")
            ui_haveNum:setVisible(false)
            ui_moneyTotalText:setString(Lang.ui_sell_prop81)
            ui_textHint:setString(string.format(Lang.ui_sell_prop82, itemName))
            _unitPrice = _thingInstData.prestige
        elseif _uiItem == UIActivityNormalExchange or _uiItem == UIActivityNormalExchangeTwo  then
            local itemProp = utils.getItemProp(_thingInstData.thing)
            local itemName = itemProp.name
            _haveNum = 0
            ui_title:setString(Lang.ui_sell_prop83)
            ui_imageIcon:setVisible(false)
            ui_haveNum:setVisible(false)
            ui_moneyTotalText:setVisible(false)
            ui_textHint:setString(string.format(Lang.ui_sell_prop84, itemName))
            _unitPrice = 1
        elseif _uiItem == UITowerShop then
            local itemThing = utils.getItemProp(_thingInstData.tableTypeId, _thingInstData.tableFieldId)
            ui_title:setString(Lang.ui_sell_prop85)
            ui_imageIcon:loadTexture("ui/small_xiuwei.png")
            ui_haveNum:setVisible(false)
            ui_moneyTotalText:setString(Lang.ui_sell_prop86)
            ui_textHint:setString(string.format(Lang.ui_sell_prop87, itemThing.name))
            _unitPrice = _thingInstData.culture
        elseif _uiItem == UISoulGet then
            local image_hint = ccui.Helper:seekNodeByName(UISellProp.Widget, "image_base_hint")
            image_hint:setPosition(cc.p(image_hint:getPositionX() + 110, image_hint:getPositionY()))
            ui_textHint:setAnchorPoint(cc.p(0.5, 0.5))
            ui_textHint:setPosition(cc.p(ui_textHint:getPositionX() + 165, ui_textHint:getPositionY()))
            if _thingInstData.type == 1 then
                ui_title:setString(Lang.ui_sell_prop88)
                ui_textHint:setString(Lang.ui_sell_prop89 .. tonumber(ui_selectedNum:getString()) * DictSysConfig[tostring(StaticSysConfig.silverNoteToCopper)].value .. Lang.ui_sell_prop90)
                ui_imageIcon:loadTexture("ui/jin.png")
                ui_haveNum:setVisible(false)
                ui_moneyTotalText:setString(Lang.ui_sell_prop91)
                _unitPrice = math.round(DictThing[tostring(StaticThing.silverNote10000)].buyGold * UIShop.disCount)
            elseif _thingInstData.type == 2 then
                ui_title:setString(Lang.ui_sell_prop92)
                ui_textHint:setString(Lang.ui_sell_prop93)
                ui_imageIcon:loadTexture("ui/yin.png")
                ui_haveNum:setVisible(false)
                ui_moneyTotalText:setString(Lang.ui_sell_prop94)
                _unitPrice = DictSysConfig[tostring(StaticSysConfig.silverNoteToCopper)].value
            end
        elseif _uiItem == UIBossShop then
            local _thingsData = utils.stringSplit(_thingInstData.things, "_")
            local itemThing = utils.getItemProp(tonumber(_thingsData[1]), tonumber(_thingsData[2]))
            ui_title:setString(Lang.ui_sell_prop95)
            ui_imageIcon:loadTexture("ui/boss_integral.png")
            ui_haveNum:setVisible(false)
            ui_moneyTotalText:setString(Lang.ui_sell_prop96)
            ui_textHint:setString(string.format(Lang.ui_sell_prop97, itemThing.name))
            _unitPrice = _thingInstData.needbossIntegral
        elseif _uiItem == UIActivityPurchaseTrade then
            ui_title:setString(Lang.ui_sell_prop98)
            ui_haveNum:setVisible(false)
            ui_moneyTotalText:setString(Lang.ui_sell_prop99)
            _unitPrice = _thingInstData.price
            ui_imageIcon:loadTexture("ui/jin.png")
            ui_textHint:setString(string.format(Lang.ui_sell_prop100, _thingInstData.thingData.name))
        elseif _uiItem == UIActivityGoddess then
            ui_title:setString(Lang.ui_sell_prop101)
            ui_haveNum:setVisible(false)
            ui_moneyTotalText:setString(Lang.ui_sell_prop102)
            _unitPrice = _thingInstData.price
            ui_imageIcon:loadTexture("ui/jin.png")
            ui_textHint:setString(string.format(Lang.ui_sell_prop103, _thingInstData.name))
        elseif _uiItem == UIGame or _uiItem == UIGameChallenge then
            if _uiItem == UIGame then 
                ui_title:setString(Lang.ui_sell_prop104)
            else
                ui_title:setString(Lang.ui_sell_prop105)
            end
            ui_haveNum:setVisible(false)
            ui_moneyTotalText:setString(Lang.ui_sell_prop106)
            _unitPrice = _thingInstData.price
            ui_imageIcon:loadTexture("ui/jin.png")
            
            _haveNum = _thingInstData.haveNum
            ui_textHint:setString(Lang.ui_sell_prop107 .. _haveNum .. Lang.ui_sell_prop108)
        end
    end
    if _uiItem == UIShop then
        ui_predictMoney:setString(math.round(tonumber(ui_selectedNum:getString()) * _unitPrice * UIShop.disCount))
    else
        ui_predictMoney:setString(tonumber(ui_selectedNum:getString()) * _unitPrice)
    end
end

function UISellProp.setData(thingInstData, uiItem, callbackFunc)
    _thingInstData = thingInstData
    _uiItem = uiItem
    _callbackFunc = callbackFunc
end

function UISellProp.free()
    _uiItem = nil
    _thingInstData = nil
    _haveNum = nil
    _unitPrice = nil
    _callbackFunc = nil
end

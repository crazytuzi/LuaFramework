require"Lang"
UIAllianceNjsf = {}

local userData = nil

local ui_items = nil
local ui_rings = nil

local function refreshMoeny()
    local image_basemap = UIAllianceNjsf.Widget:getChildByName("image_basemap")
    local image_di_info = image_basemap:getChildByName("image_di_info")
    local ui_silver = ccui.Helper:seekNodeByName(image_di_info, "text_silver_number")
    local ui_gold = ccui.Helper:seekNodeByName(image_di_info, "text_gold_number")
    local ui_fightValue = ccui.Helper:seekNodeByName(image_di_info, "label_fight")
    ui_fightValue:setString(tostring(utils.getFightValue()))
	ui_gold:setString(tostring(net.InstPlayer.int["5"]))
	ui_silver:setString(net.InstPlayer.string["6"])
end

local function palyGetThingAnimation(_thingData)
    local uiLayout = ccui.Layout:create()
    uiLayout:setContentSize(UIManager.screenSize)
    uiLayout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    uiLayout:setBackGroundColor(cc.c3b(0, 0, 0))
    uiLayout:setBackGroundColorOpacity(180)
    uiLayout:setTouchEnabled(true)
    uiLayout:retain()

    local _boxAnim = ActionManager.getEffectAnimation(63, function(armature)
        armature:getAnimation():stop()
    end , 1)
    _boxAnim:setLocalZOrder(4)
    _boxAnim:setPosition(cc.p(uiLayout:getContentSize().width / 2, uiLayout:getContentSize().height / 2))
    if _thingData.bigIcon then
        _boxAnim:getBone("guge2"):addDisplay(ccs.Skin:create(_thingData.bigIcon), 0)
    elseif _thingData.smallIcon then
        _boxAnim:getBone("guge2"):addDisplay(ccs.Skin:create(_thingData.smallIcon), 0)
    end
    if _thingData.name then
        local _name = ccui.Text:create()
        _name:setFontName(dp.FONT)
        _name:setString(_thingData.name)
        _name:setFontSize(30)
        _name:setTextColor(cc.c4b(255, 255, 255, 255))
        _boxAnim:getBone("guge1"):addDisplay(_name, 0)
    end
    uiLayout:addChild(_boxAnim)
    UIManager.uiLayer:addChild(uiLayout, 10000)

    uiLayout:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            UIManager.uiLayer:removeChild(uiLayout, true)
            cc.release(uiLayout)
        end
    end)
end

local function playAction(_callFunc)
    local dialog = ccui.Layout:create()
    dialog:setContentSize(UIManager.screenSize)
    dialog:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    dialog:setBackGroundColor(cc.c3b(0, 0, 0))
    dialog:setBackGroundColorOpacity(0)
    dialog:setTouchEnabled(true)
    UIManager.uiLayer:addChild(dialog, 10000)

    local ringsPos = {}
    for key, obj in pairs(ui_rings) do
        ringsPos[key] = cc.p(obj:getPosition())
        obj:setPosition(cc.p(-200, 800))
        obj:setVisible(true)
    end
    
    local runActionItem = nil
    local runActionRing = nil
    local runActionRing1 = nil
    local runActionRing2 = nil
    for key, obj in pairs(ui_rings) do
        if key == #ui_rings then
            obj:runAction(cc.Sequence:create( cc.DelayTime:create(tonumber("0."..key)), cc.MoveTo:create(0.3, cc.p(ringsPos[key].x, ringsPos[key].y + 50)), cc.CallFunc:create(function()
                runActionItem()
            end) ))
        else
            obj:runAction(cc.Sequence:create( cc.DelayTime:create(tonumber("0."..key)), cc.MoveTo:create(0.3, cc.p(ringsPos[key].x, ringsPos[key].y + 50)) ))
        end
    end

    runActionItem = function()
        for key, obj in pairs(ui_items) do
            if key == #ui_items then
                obj:runAction(cc.Sequence:create( cc.ScaleTo:create(0.5, 0) ))
                ui_rings[key]:runAction(cc.Sequence:create( cc.MoveBy:create(0.5, cc.p(0, -50)), cc.CallFunc:create(function()
                    runActionRing()
                end) ))
            else
                obj:runAction(cc.Sequence:create( cc.ScaleTo:create(0.5, 0) ))
                ui_rings[key]:runAction(cc.Sequence:create( cc.MoveBy:create(0.5, cc.p(0, -50)) ))
            end
        end
    end
    
    runActionRing = function()
        local arrayPos = {
            cc.p(ui_rings[1]:getPosition()),
            cc.p(ui_rings[2]:getPosition()),
            cc.p(ui_rings[3]:getPosition()),
            cc.p(ui_rings[6]:getPosition()),
            cc.p(ui_rings[9]:getPosition()),
            cc.p(ui_rings[8]:getPosition()),
            cc.p(ui_rings[7]:getPosition()),
            cc.p(ui_rings[4]:getPosition()),
        }
        local _index = 0
        for key, obj in pairs(ui_rings) do
            if key ~= 5 then
                _index = _index + 1
                local array = {}

                for i = _index, #arrayPos do
                    array[#array + 1] = arrayPos[i]
                end
                for i = 1, _index - 1 do
                    array[#array + 1] = arrayPos[i]
                end
                array[#array + 1] = arrayPos[_index]

                if key == #ui_rings then
                    obj:runAction(cc.Sequence:create( cc.CatmullRomTo:create(1, array), cc.CallFunc:create(function()
                        runActionRing1()
                    end) ))
                else
                    obj:runAction(cc.Sequence:create( cc.CatmullRomTo:create(1, array) ))
                end
            end
        end
    end
        
    runActionRing1 = function()
        for key, obj in pairs(ui_rings) do
            if key ~= 5 then
                local _position = cc.p(ui_rings[5]:getPosition())
                if key == #ui_rings then
                    obj:runAction(cc.Sequence:create( cc.MoveTo:create(0.3, _position), cc.CallFunc:create(function()
                        runActionRing2()
                    end) ))
                else
                    obj:runAction(cc.Sequence:create( cc.MoveTo:create(0.3, _position) ))
                end
            end
        end
    end

    runActionRing2 = function()
        for key, obj in pairs(ui_rings) do
            if key == #ui_rings then
                obj:runAction(cc.Sequence:create( cc.MoveTo:create(0.3, ringsPos[key]), cc.CallFunc:create(function()
                    UIManager.uiLayer:removeChild(dialog, true)
                    if _callFunc then
                        _callFunc()
                    end
                end) ))
            else
                obj:runAction(cc.Sequence:create( cc.MoveTo:create(0.3, ringsPos[key]) ))
            end
        end
    end
end

function UIAllianceNjsf.init()
    local image_basemap = UIAllianceNjsf.Widget:getChildByName("image_basemap")
    local btn_back = image_basemap:getChildByName("btn_back")
    local btn_help = image_basemap:getChildByName("btn_help")
    local btn_begin = image_basemap:getChildByName("btn_begin")
    btn_back:setPressedActionEnabled(true)
    btn_help:setPressedActionEnabled(true)
    btn_begin:setPressedActionEnabled(true)
    local onButtonEvent = function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_back then
                UIAllianceActivity.show(userData)
            elseif sender == btn_help then
                UIAllianceHelp.show( { type = 32 , titleName = Lang.ui_alliance_njsf1 } )
            elseif sender == btn_begin then
                if sender:getTitleText() == Lang.ui_alliance_njsf2 then
                    UIManager.showLoading()
                    netSendPackage( {
                        header = StaticMsgRule.startNaJie, msgdata = {}
                    } , function(_msgData)
                        playAction(function()
--                            sender:setTitleText("重置")
--                            sender:setBright(false)
                            UIAllianceNjsf.setup()
                        end)
                    end)
                elseif sender:getTitleText() == Lang.ui_alliance_njsf3 and sender:isBright() then
                    UIManager.showLoading()
                    netSendPackage( {
                        header = StaticMsgRule.resetNaJie, msgdata = {}
                    } , function(_msgData)
                        UIAllianceNjsf.setup()
                    end)
                end
            end
        end
    end
    btn_back:addTouchEventListener(onButtonEvent)
    btn_help:addTouchEventListener(onButtonEvent)
    btn_begin:addTouchEventListener(onButtonEvent)

    ui_items = {}
    ui_rings = {}
    for i = 1, 9 do
       ui_items[i] = image_basemap:getChildByName("image_frame_good" .. i)
       ui_rings[i] = image_basemap:getChildByName("image_ring" .. i)
    end
end

function UIAllianceNjsf.setup()
    refreshMoeny()
--    cclog("@@@@@@------------>> " .. userData.allianceLevel)

    local image_basemap = UIAllianceNjsf.Widget:getChildByName("image_basemap")

    local ui_todayCount = image_basemap:getChildByName("text_number")
    local btn_begin = image_basemap:getChildByName("btn_begin")
    local image_gold = image_basemap:getChildByName("image_gold")
    local ui_textHint = image_basemap:getChildByName("text_hint")

    --default
    ui_todayCount:setString(Lang.ui_alliance_njsf4)
    btn_begin:setTitleText(Lang.ui_alliance_njsf5)
    btn_begin:setBright(true)
    image_gold:setVisible(false)
    ui_textHint:setVisible(true)
    for key, obj in pairs(ui_items) do
        obj:setVisible(false)
        obj:setScale(1)
        obj:getChildByName("image_good"):removeAllChildren()
        obj:getChildByName("image_good"):setTouchEnabled(false)
        obj:getChildByName("image_title"):setVisible(false)
    end
    for key, obj in pairs(ui_rings) do
        obj:setTouchEnabled(false)
        obj:setVisible(true)
    end

    UIManager.showLoading()
    netSendPackage( {
        header = StaticMsgRule.openNaJiePanel, msgdata = {}
    } , function(_msgData)
        local _things = utils.stringSplit(_msgData.msgdata.string.things, ";")
        local _openThings = utils.stringSplit(_msgData.msgdata.string.openThing, ";")
        local _curUseCount = _msgData.msgdata.int.curTurn --已使用次数
        local _maxCount = _msgData.msgdata.int.maxTurn --最大次数
        local _isStart = _msgData.msgdata.int.isStart --是否已经点击了开始  0未  1是
        ui_todayCount:setString(string.format(Lang.ui_alliance_njsf6, _maxCount - _curUseCount, _maxCount))
        if #_openThings > 0 then
            local _gold = (#_openThings == #_things) and 0 or DictSysConfig[tostring(StaticSysConfig[string.format("NaJie_%dGold", #_openThings + 1)])].value
            image_gold:getChildByName("text_cost"):setString("×" .. _gold)
            image_gold:setVisible(true)
            ui_textHint:setVisible(false)
            btn_begin:setTitleText(Lang.ui_alliance_njsf7)
            btn_begin:setBright(true)
            for key, obj in pairs(_openThings) do
                local _tempData = utils.stringSplit(obj, ",")
                local _index = tonumber(_tempData[1])
                local _itemThing = _tempData[2]
                local itemProps = utils.getItemProp(_itemThing)
                if itemProps then
                    if itemProps.frameIcon then
                        ui_items[_index]:loadTexture(itemProps.frameIcon)
                    end
                    if itemProps.smallIcon then
                        ui_items[_index]:getChildByName("image_good"):loadTexture(itemProps.smallIcon)
                        utils.showThingsInfo(ui_items[_index]:getChildByName("image_good"), itemProps.tableTypeId, itemProps.tableFieldId)
                        if itemProps.tableTypeId == StaticTableType.DictCardSoul then
                            utils.addFrameParticle( ui_items[_index]:getChildByName("image_good") , true )
                        end
                    end
                    if itemProps.name then
                        ui_items[_index]:getChildByName("text_name"):setString(itemProps.name)
                    end
                    ui_items[key]:getChildByName("image_title"):setVisible(false)
                    if itemProps.flagIcon then
                        ui_items[_index]:getChildByName("image_title"):setVisible(true)
                        ui_items[_index]:getChildByName("image_title"):loadTexture(itemProps.flagIcon)
                    end
                    if itemProps.count then
                        ui_items[_index]:getChildByName("text_number"):setString("×" .. itemProps.count)
                    end
                end
                ui_items[_index]:setVisible(true)
                ui_rings[_index]:setVisible(false)
            end
        else
            image_gold:setVisible(false)
            ui_textHint:setVisible(true)
            if _isStart == 0 then
                btn_begin:setTitleText(Lang.ui_alliance_njsf8)
                btn_begin:setBright(true)
                for key, obj in pairs(ui_items) do
                    if _things and _things[key] then
                        local itemProps = utils.getItemProp(_things[key])
                        if itemProps then
                            if itemProps.frameIcon then
                                obj:loadTexture(itemProps.frameIcon)
                            end
                            if itemProps.smallIcon then
                                obj:getChildByName("image_good"):loadTexture(itemProps.smallIcon)
                                utils.showThingsInfo(obj:getChildByName("image_good"), itemProps.tableTypeId, itemProps.tableFieldId)
                                if itemProps.tableTypeId == StaticTableType.DictCardSoul then
                                    utils.addFrameParticle( obj:getChildByName("image_good") , true )
                                end
                            end
                            if itemProps.name then
                                obj:getChildByName("text_name"):setString(itemProps.name)
                            end
                            obj:getChildByName("image_title"):setVisible(false)
                            if itemProps.flagIcon then
                                obj:getChildByName("image_title"):setVisible(true)
                                obj:getChildByName("image_title"):loadTexture(itemProps.flagIcon)
                            end
                            if itemProps.count then
                                obj:getChildByName("text_number"):setString("×" .. itemProps.count)
                            end
                        end
                        obj:setVisible(true)
                        ui_rings[key]:setVisible(false)
                    end
                end
            else
                btn_begin:setTitleText(Lang.ui_alliance_njsf9)
                btn_begin:setBright(false)
            end
        end
        if btn_begin:getTitleText() == Lang.ui_alliance_njsf10 then
            local _openCount = #_openThings
            local _isTouchRing = false
            for key, obj in pairs(ui_rings) do
                obj:setTouchEnabled(true)
                obj:addTouchEventListener(function(sender, eventType)
                    if eventType == ccui.TouchEventType.ended then
                        if _isTouchRing then
                            return
                        end
                        _isTouchRing = true
                        UIManager.showLoading()
                        netSendPackage( {
                            header = StaticMsgRule.clickNaJieReward, msgdata = { int = { position = key } }
                        } , function(_messageData)
			                _isTouchRing = false
                            local otherDay = _messageData.msgdata.int.otherDay
                            if otherDay then
                                utils.showSureDialog(Lang.ui_alliance_njsf11, function()
                                    UIManager.showLoading()
                                    netSendPackage( {
                                        header = StaticMsgRule.resetNaJie, msgdata = {}
                                    } , function(_messageData)
                                        UIAllianceNjsf.setup()
                                    end)
                                end)
                            else
                                UIManager.showToast(Lang.ui_alliance_njsf12)
                                local itemProps = utils.getItemProp(_messageData.msgdata.string.things)
                                if itemProps then
                                    if _messageData.msgdata.int.teshu == 1 then
                                        palyGetThingAnimation(itemProps)
                                    end
                                    if itemProps.frameIcon then
                                        ui_items[key]:loadTexture(itemProps.frameIcon)
                                    end
                                    if itemProps.smallIcon then
                                        ui_items[key]:getChildByName("image_good"):loadTexture(itemProps.smallIcon)
                                        utils.showThingsInfo(ui_items[key]:getChildByName("image_good"), itemProps.tableTypeId, itemProps.tableFieldId)
                                        if itemProps.tableTypeId == StaticTableType.DictCardSoul then
                                            utils.addFrameParticle( ui_items[key]:getChildByName("image_good") , true )
                                        end
                                    end
                                    if itemProps.name then
                                        ui_items[key]:getChildByName("text_name"):setString(itemProps.name)
                                    end
                                    ui_items[key]:getChildByName("image_title"):setVisible(false)
                                    if itemProps.flagIcon then
                                        ui_items[key]:getChildByName("image_title"):setVisible(true)
                                        ui_items[key]:getChildByName("image_title"):loadTexture(itemProps.flagIcon)
                                    end
                                    if itemProps.count then
                                        ui_items[key]:getChildByName("text_number"):setString("×" .. itemProps.count)
                                    end
                                end
                                obj:setVisible(false)
                                ui_items[key]:setScale(1)
                                ui_items[key]:setVisible(true)
                                btn_begin:setBright(true)
                                _openCount = _openCount + 1
                                local _gold = (_openCount >= #_things) and 0 or DictSysConfig[tostring(StaticSysConfig[string.format("NaJie_%dGold", _openCount + 1)])].value
                                image_gold:getChildByName("text_cost"):setString("×" .. _gold)
                                image_gold:setVisible(true)
                                ui_textHint:setVisible(false)
                                refreshMoeny()
                            end
                        end, function() _isTouchRing = false end)
                    end
                end)
            end
        end
    end)
end

function UIAllianceNjsf.free()

end

function UIAllianceNjsf.show(_tableParams)
    userData = _tableParams
    UIManager.showWidget("ui_alliance_njsf")
end

return UIAllianceNjsf

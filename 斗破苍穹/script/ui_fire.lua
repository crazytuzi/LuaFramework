require"Lang"
UIFire = { }

local BUTTON_TEXT_1 = Lang.ui_fire1
local BUTTON_TEXT_2 = Lang.ui_fire2

local ui_scrollView = nil
local ui_svItem = nil
local ui_cardScrollView = nil
local ui_cardSVItem = nil

local _fireAnimaction = nil
local _curFireData = nil
local _curShowFireIndex = nil
local _currentTimer = 0
local _isPlayerAnimation = nil
local _formationData = nil

local function playFireAnimation(actionIndex, _fireIcon, _fireImagePath)
    if not _fireAnimaction then
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("ani/ui_anim/ui_anim50/ui_anim50.ExportJson")
        _fireAnimaction = ccs.Armature:create("ui_anim50")
        _fireIcon:setVisible(false)
        _fireIcon:getParent():addChild(_fireAnimaction)
        _fireAnimaction:setPosition(_fireIcon:getPosition())
    end
    _fireAnimaction:getBone("fire" .. actionIndex):addDisplay(ccs.Skin:create(_fireImagePath), 0)
    _fireAnimaction:getAnimation():play("fire" .. actionIndex)
end

local function setScrollViewFocus(isJumpTo, _curShowIndex)
    local childs = ui_scrollView:getChildren()
    for key, obj in pairs(childs) do
        local ui_focus = obj:getChildByName("image_choose")
        if _curShowIndex == key then
            ui_focus:setVisible(true)

            local contaniner = ui_scrollView:getInnerContainer()
            local w =(contaniner:getContentSize().width - ui_scrollView:getContentSize().width)
            local dt
            if w == 0 then
                dt = 0
            else
                dt =(obj:getPositionX() + obj:getContentSize().width - ui_scrollView:getContentSize().width) / w
                if dt < 0 then
                    dt = 0
                end
            end
            if isJumpTo then
                ui_scrollView:jumpToPercentHorizontal(dt * 100)
            else
                ui_scrollView:scrollToPercentHorizontal(dt * 100, 0.5, true)
            end
        else
            ui_focus:setVisible(false)
        end
    end
end

local function layoutScrollView(_scrllView, _svItem, _initItemFunc, _data, _spaceW)
    if _svItem:getReferenceCount() == 1 then
        _svItem:retain()
    end
    _scrllView:removeAllChildren()
    _scrllView:jumpToLeft()
    local innerWidth = 0
    for key, obj in pairs(_data) do
        local scrollViewItem = _svItem:clone()
        _initItemFunc(scrollViewItem, obj)
        _scrllView:addChild(scrollViewItem)
        innerWidth = innerWidth + scrollViewItem:getContentSize().width + _spaceW
    end
    innerWidth = innerWidth + _spaceW
    if innerWidth < _scrllView:getContentSize().width then
        innerWidth = _scrllView:getContentSize().width
    end
    _scrllView:setInnerContainerSize(cc.size(innerWidth, _scrllView:getContentSize().height))
    local childs = _scrllView:getChildren()
    local prevChild = nil
    for i = 1, #childs do
        local _anchorPoint = childs[i]:getAnchorPoint()
        if prevChild then
            if _anchorPoint.x == 0.5 and _anchorPoint.y == 0.5 then
                childs[i]:setPosition(cc.p(prevChild:getRightBoundary() + childs[i]:getContentSize().width / 2 + _spaceW, _scrllView:getContentSize().height / 2))
            else
                childs[i]:setPosition(cc.p(prevChild:getRightBoundary() + _spaceW,(_scrllView:getContentSize().height - childs[i]:getContentSize().height) / 2))
            end
        else
            if _anchorPoint.x == 0.5 and _anchorPoint.y == 0.5 then
                childs[i]:setPosition(cc.p(childs[i]:getContentSize().width / 2 + _spaceW, _scrllView:getContentSize().height / 2))
            else
                childs[i]:setPosition(cc.p(_spaceW,(_scrllView:getContentSize().height - childs[i]:getContentSize().height) / 2))
            end
        end
        prevChild = childs[i]
    end
end

local function setFireLoadingBarUI(_curFireHP, _fireHPMax)
    local image_basemap = UIFire.Widget:getChildByName("image_basemap")
    local ui_fireLoadingBarPanel = image_basemap:getChildByName("image_loading")
    local ui_fireLoadingBar = ui_fireLoadingBarPanel:getChildByName("bar_loading")
    local ui_fireLoadingBarState = ui_fireLoadingBar:getChildByName("image_state")
    local ui_fireCurHp = ui_fireLoadingBarPanel:getChildByName("text_number")
    ui_fireLoadingBar:setPercent(utils.getPercent(_curFireHP, _fireHPMax))
    ui_fireCurHp:setString(string.format(Lang.ui_fire3, _curFireHP, _fireHPMax))
    local barParticle = ui_fireLoadingBar:getChildByName("barParticle")
    if barParticle == nil then
        barParticle = cc.ParticleSystemQuad:create("particle/ui_fire_effect01.plist")
        barParticle:setPositionType(cc.POSITION_TYPE_GROUPED)
        barParticle:setName("barParticle")
        ui_fireLoadingBar:addChild(barParticle)
    end
    ui_fireLoadingBarState:setPositionX(ui_fireLoadingBar:getContentSize().width *(ui_fireLoadingBar:getPercent() / 100))
    barParticle:setPosition(cc.p(ui_fireLoadingBarState:getPositionX(), ui_fireLoadingBar:getContentSize().height / 2 - 8))
    local _color = cc.c4b(0, 255, 0, 255)
    if ui_fireLoadingBar:getPercent() >= 33 and ui_fireLoadingBar:getPercent() < 33 * 2 then
        _color = cc.c4b(255, 0, 255, 255)
    elseif ui_fireLoadingBar:getPercent() >= 33 * 2 then
        _color = cc.c4b(255, 0, 0, 255)
    end
    barParticle:setStartColor(_color)
    ui_fireLoadingBarState:setColor(_color)
    if (ui_fireLoadingBar:getPercent() >= 0 and ui_fireLoadingBar:getPercent() <= 5) or ui_fireLoadingBar:getPercent() >= 96 then
        barParticle:setVisible(false)
        ui_fireLoadingBarState:setVisible(false)
    else
        barParticle:setVisible(true)
        ui_fireLoadingBarState:setVisible(true)
    end
end

local function doTimer()
    _currentTimer = _currentTimer - 1
    if _currentTimer < 0 then
        _currentTimer = 0
    end
    local image_basemap = UIFire.Widget:getChildByName("image_basemap")
    if image_basemap then
        local ui_fireLoadingBarPanel = image_basemap:getChildByName("image_loading")
        local ui_fireTimer = ui_fireLoadingBarPanel:getChildByName("text_time")
        if ui_fireTimer:isVisible() then
            local _hour = math.floor(_currentTimer / 3600)
            -- 小时
            local _minute = math.floor(_currentTimer % 3600 / 60)
            -- 分
            local _second = math.floor(_currentTimer % 60)
            -- 秒
            ui_fireTimer:setString(string.format("%02d:%02d:%02d", _hour, _minute, _second))
        end
    end
end

local function setFireUI(_data)
    if _data then
        local _cardList = { }
        if _data.InstPlayerYFire then
            _cardList = utils.stringSplit(_data.InstPlayerYFire.string["8"], ";")
            -- 卡牌实例ID_位置
        end
        for _keyFormation, _objFormation in pairs(_formationData) do
            _formationData[_keyFormation].isActivity = 0
            for _key, _obj in pairs(_cardList) do
                if tonumber(utils.stringSplit(_obj, "_")[1]) == _objFormation.formation.int["3"] then
                    _formationData[_keyFormation].isActivity = 1
                    break
                end
            end
        end
        utils.quickSort(_formationData, function(obj1, obj2) if obj1.isActivity < obj2.isActivity then return true end end)
        layoutScrollView(ui_cardScrollView, ui_cardSVItem, function(_item, _data)
            --            local dictCardId = net.InstPlayerCard[(utils.stringSplit(_data, "_")[1])].int["3"]
            local dictCardId = net.InstPlayerCard[tostring(_data.formation.int["3"])].int["3"]
            local isAwake = tonumber(net.InstPlayerCard[tostring(_data.formation.int["3"])].int["18"])
            local _cardIconPath = "image/" .. DictUI[tostring(DictCard[tostring(dictCardId)].smallUiId)].fileName
            if isAwake == 1 then
                _cardIconPath = "image/" .. DictUI[tostring(DictCard[tostring(dictCardId)].awakeSmallUiId)].fileName
            end
            local ui_cardFrame = _item:getChildByName("btn_base_warrior")
            local ui_cardIcon = _item:getChildByName("image_warrior")
            ui_cardIcon:loadTexture(_cardIconPath)
            if _data.isActivity == 0 then
                utils.GrayWidget(ui_cardFrame, true)
                utils.GrayWidget(ui_cardIcon, true)
            end
        end , _formationData, 15)
        local image_basemap = UIFire.Widget:getChildByName("image_basemap")
        local ui_fireIcon = image_basemap:getChildByName("image_fire")
        local ui_fireName = image_basemap:getChildByName("text_name")
        local ui_fireRank = image_basemap:getChildByName("text_rank")
        local ui_fireExuberant = image_basemap:getChildByName("text_exuberant")
        local ui_fireRage = image_basemap:getChildByName("text_wild")
        local ui_fireLoadingBarPanel = image_basemap:getChildByName("image_loading")
        local ui_fireExuberantStateImage = ui_fireLoadingBarPanel:getChildByName("image_wangsheng")
        local ui_fireRagStateImage = ui_fireLoadingBarPanel:getChildByName("image_kuangbao")
        local ui_fireTimer = ui_fireLoadingBarPanel:getChildByName("text_time")
        local ui_fireTimerDesc = ui_fireLoadingBarPanel:getChildByName("text_after")
        local btn_equipment = image_basemap:getChildByName("btn_equipment")
        local _fireImagePath = "image/fireImage/" .. DictUI[tostring(_data.DictYFire.bigUiId)].fileName
        playFireAnimation(_data.DictYFire.rank, ui_fireIcon, _fireImagePath)
        ui_fireIcon:loadTexture(_fireImagePath)
        ui_fireName:setString(_data.DictYFire.name)
        ui_fireRank:setString(Lang.ui_fire4 .. _data.DictYFire.rank)
        ui_fireExuberant:setString(_data.DictYFire.exuberantDesc)
        ui_fireRage:setString(_data.DictYFire.rageDesc)
        ui_fireTimer:setVisible(false)
        ui_fireTimerDesc:setVisible(false)
        btn_equipment:setTitleText(BUTTON_TEXT_1)

        local _curFireHP = 0
        -- 当前异火的火灵值
        local _fireState = 0
        if _data.InstPlayerYFire then
            --            _fireState = _data.InstPlayerYFire.int["4"] --0.未激活 1.旺盛  2.狂暴
            --            _curFireHP = _data.InstPlayerYFire.int["6"]
            _fireState, _curFireHP = utils.getEquipFireState(_data.InstPlayerYFire.int["1"])
        end
        if _fireState == 0 then
            -- 未激活状态
            ui_fireExuberant:setTextColor(cc.c4b(127, 127, 127, 255))
            ui_fireRage:setTextColor(cc.c4b(127, 127, 127, 255))
            utils.GrayWidget(ui_fireExuberantStateImage, true)
            utils.GrayWidget(ui_fireRagStateImage, true)
        elseif _fireState == 1 then
            -- 激活状态（旺盛）
            ui_fireExuberant:setTextColor(cc.c4b(7, 184, 7, 255))
            ui_fireRage:setTextColor(cc.c4b(127, 127, 127, 255))
            utils.GrayWidget(ui_fireExuberantStateImage, false)
            utils.GrayWidget(ui_fireRagStateImage, true)
            btn_equipment:setTitleText(BUTTON_TEXT_2)
        elseif _fireState == 2 then
            -- 激活状态（狂暴）
            ui_fireExuberant:setTextColor(cc.c4b(127, 127, 127, 255))
            ui_fireRage:setTextColor(cc.c4b(237, 116, 116, 255))
            utils.GrayWidget(ui_fireExuberantStateImage, true)
            utils.GrayWidget(ui_fireRagStateImage, false)
            btn_equipment:setTitleText(BUTTON_TEXT_2)
            if _data.InstPlayerYFire.int["7"] > 0 and #_cardList > 0 then
                _currentTimer = math.floor(_curFireHP /(_data.InstPlayerYFire.int["7"] * #_cardList) * 60)
                if _currentTimer > 1 then
                    ui_fireTimer:setVisible(true)
                    ui_fireTimerDesc:setVisible(true)
                end
            end
        end

        setFireLoadingBarUI(_curFireHP, _data.DictYFire.hpMax)
        _cardList = nil

        local _curCount = 0
        if _data.InstPlayerYFire then
            _curCount = _data.InstPlayerYFire.int["9"]
        end
        local btn_30 = image_basemap:getChildByName("btn_base_fire1")
        btn_30:getChildByName("image_fire"):loadTexture("image/fireImage/" .. DictUI[tostring(_data.DictYFire.smallUiId)].fileName)
        btn_30:getChildByName("text_number"):setString("×" .. _curCount)
        btn_30:getChildByName("text_hint"):setString(Lang.ui_fire5 .. _data.DictYFire.cureVar)

        _curFireData = _data
    end
end

local function netCallbackFunc(_msgData)
    local code = tonumber(_msgData.header)
    if code == StaticMsgRule.activeYFire or code == StaticMsgRule.cureYFire then
        local refreshUI = function()
            UIFire.setup(_curShowFireIndex)
        end
        if code == StaticMsgRule.activeYFire then
            local animation = ActionManager.getUIAnimation(52, function(armature)
                refreshUI()
            end )
            animation:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2 + 120))
            UIFire.Widget:addChild(animation, 10000)
        elseif code == StaticMsgRule.cureYFire then
            if _isPlayerAnimation then
                local animation = ActionManager.getUIAnimation(53, function(armature)
                    refreshUI()
                end )
                animation:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 4))
                UIFire.Widget:addChild(animation, 10000)
                _isPlayerAnimation = nil
            else
                refreshUI()
            end
        end

    end
end

local function checkFireStone()
    UIManager.showLoading()
    local data = {
        header = StaticMsgRule.getStoreData,
        msgdata =
        {
            int =
            {
                type = 1,
            },
        }
    }
    netSendPackage(data, function(_msgData)
        local _shopData = _msgData.msgdata.message
        if _shopData then
            for key, obj in pairs(_shopData) do
                if obj.int["thingId"] == StaticThing.thing304 then
                    if obj.int["canBuyNum"] ~= nil and obj.int["canBuyNum"] == 0 then
                        ---  -1表示可以无限购买
                        UIManager.showToast(Lang.ui_fire6)
                    elseif obj.int["isBuy"] ~= nil and obj.int["isBuy"] == 1 then
                        -- 已购买 不能买了
                        UIManager.showToast(Lang.ui_fire7)
                    else
                        UISellProp.setData(obj, UIShop, function()
                            UIManager.showToast(Lang.ui_fire8)
                            UIFire.setup(_curShowFireIndex)
                        end )
                        UIManager.pushScene("ui_sell_prop")
                    end
                    break
                end
            end
        end
        _shopData = nil
    end )
    data = nil
end

local function initLineupData()
    local formation1, formation2 = { }, { }
    for key, obj in pairs(net.InstPlayerFormation) do
        if obj.int["4"] == 1 then
            -- 主力
            formation1[#formation1 + 1] = obj
        elseif obj.int["4"] == 2 then
            -- 替补
            formation2[#formation2 + 1] = obj
        end
    end
    local function compareFunc(obj1, obj2)
        if obj1.int["1"] > obj2.int["1"] then
            return true
        end
        return false
    end
    utils.quickSort(formation1, compareFunc)
    utils.quickSort(formation2, compareFunc)
    _formationData = { }
    for key = 1, #formation1 + #formation2 do
        if formation1[key] then
            _formationData[key] = { isActivity = 0, formation = formation1[key] }
        elseif formation2[key - #formation1] then
            _formationData[key] = { isActivity = 0, formation = formation2[key - #formation1] }
        end
    end
    formation1 = nil
    formation2 = nil
end

function UIFire.init()
    local image_basemap = UIFire.Widget:getChildByName("image_basemap")
    local btn_back = image_basemap:getChildByName("btn_back")
    local btn_help = image_basemap:getChildByName("btn_help")
    local btn_equipment = image_basemap:getChildByName("btn_equipment")
    local btn_secret = image_basemap:getChildByName("btn_fire_base")
    local btn_r = image_basemap:getChildByName("btn_l")
    local btn_l = image_basemap:getChildByName("btn_r")
    btn_back:setPressedActionEnabled(true)
    btn_help:setPressedActionEnabled(true)
    btn_equipment:setPressedActionEnabled(true)
    btn_secret:setPressedActionEnabled(true)
    btn_r:setPressedActionEnabled(true)
    btn_l:setPressedActionEnabled(true)
--   if IOS_PREVIEW then
--        btn_secret:hide()
--    end
    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_back then
                UIMenu.onHomepage()
            elseif sender == btn_help then
                UIAllianceHelp.show( { type = 9, titleName = Lang.ui_fire9 })
            elseif sender == btn_l then
                cclog("--------------->>>> 左")
            elseif sender == btn_r then
                cclog("--------------->>>> 右")
            elseif sender == btn_equipment then
                if btn_equipment:getTitleText() == BUTTON_TEXT_1 then
                    if not _curFireData then return end
                    local _curCount = 0
                    if _curFireData.InstPlayerYFire then
                        _curCount = _curFireData.InstPlayerYFire.int["9"]
                    end
                    if _curCount >= _curFireData.DictYFire.chipMax then
                        UIManager.showLoading()
                        local _msgData = {
                            header = StaticMsgRule.activeYFire,
                            msgdata =
                            {
                                int = { fireId = _curFireData.DictYFire.id }
                            }
                        }
                        netSendPackage(_msgData, netCallbackFunc)
                    else
                        UIManager.showToast(Lang.ui_fire10)
                    end
                elseif btn_equipment:getTitleText() == BUTTON_TEXT_2 then
                    if _curFireData and _curFireData.InstPlayerYFire and _curFireData.InstPlayerYFire.int["4"] == 2 then
                        UIFireAdd.show( { fireData = _curFireData, showFireIndex = _curShowFireIndex })
                    else
                        UIManager.showToast(Lang.ui_fire11)
                    end
                end
            elseif sender == btn_secret then
                --UIManager.showToast("可以得到异火火种的秘境，暂未开启，敬请期待！")
                UIManager.hideWidget("ui_team_info")
                UIManager.hideWidget("ui_menu")
                UIManager.showWidget("ui_fire_base")
            end
        end
    end
    btn_back:addTouchEventListener(onButtonEvent)
    btn_help:addTouchEventListener(onButtonEvent)
    btn_equipment:addTouchEventListener(onButtonEvent)
    btn_secret:addTouchEventListener(onButtonEvent)
    btn_r:addTouchEventListener(onButtonEvent)
    btn_l:addTouchEventListener(onButtonEvent)

    local _isCanEat = false
    local _curFireHPValue = 0
    local _useThingNums = 0
    local _curFlagTime = 0
    local _schedulerId = nil
    local _curUIThingItem = nil
    local _curThingNums = 0
    local btn_30 = image_basemap:getChildByName("btn_base_fire1")
    local btn_60 = image_basemap:getChildByName("btn_base_fire2")

    local function addFireExp(dt)
        if os.time() - _curFlagTime >= 1 and _curThingNums > 0 then
            _useThingNums = _useThingNums + 1
            local _hp = _curFireHPValue
            if _curUIThingItem == btn_30 then
                _hp = _curFireHPValue + _curFireData.DictYFire.cureVar * _useThingNums
            elseif _curUIThingItem == btn_60 then
                _hp = _curFireHPValue + DictSysConfig[tostring(StaticSysConfig.fireCureVar)].value * _useThingNums
            end
            _curUIThingItem:getChildByName("text_number"):setString("×" .. _curThingNums - _useThingNums)
            setFireLoadingBarUI(_hp, _curFireData.DictYFire.hpMax)
            if _hp < _curFireData.DictYFire.hpMax then
                if _useThingNums == _curThingNums then
                    if _schedulerId then
                        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_schedulerId)
                        _schedulerId = nil
                    end
                    if _curUIThingItem == btn_30 then
                        UIManager.showToast(Lang.ui_fire12)
                    elseif _curUIThingItem == btn_60 then
                        UIManager.showToast(DictYFireChip[tostring(_curFireData.DictYFire.id)].name .. Lang.ui_fire13)
                    end
                end
            else
                if _schedulerId then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_schedulerId)
                    _schedulerId = nil
                end
                UIManager.showToast(Lang.ui_fire14)
                if _curFireData.InstPlayerYFire and _curFireData.InstPlayerYFire.int["4"] == 1 then
                    _isPlayerAnimation = true
                end
            end
        end
    end

    local function onSetFireValueEvent(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            _isCanEat = false
            if not _curFireData then return end
            if _curFireData.InstPlayerYFire and _curFireData.InstPlayerYFire.int["4"] ~= 0 then
                if sender == btn_30 then
                    _curThingNums = _curFireData.InstPlayerYFire.int["9"]
                elseif sender == btn_60 then
                    _curThingNums = utils.getThingCount(StaticThing.thing304)
                end
                if sender == btn_30 and _curThingNums <= 0 then
                    UIManager.showToast(Lang.ui_fire15)
                    return
                elseif sender == btn_60 and _curThingNums <= 0 then
                    checkFireStone()
                    --                    UIManager.showToast("火灵石不足！")
                    return
                end
                local ui_fireLoadingBarPanel = image_basemap:getChildByName("image_loading")
                local ui_fireCurHp = ui_fireLoadingBarPanel:getChildByName("text_number")
                local _tempStr = utils.stringSplit(ui_fireCurHp:getString(), "：")[2]
                _curFireHPValue = tonumber(utils.stringSplit(_tempStr, "/")[1])
                if _curFireHPValue >= _curFireData.DictYFire.hpMax then
                    UIManager.showToast(Lang.ui_fire16)
                    return
                end
                _isCanEat = true
                _curUIThingItem = sender
                _useThingNums = 0
                _curFlagTime = os.time()
                if _schedulerId then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_schedulerId)
                    _schedulerId = nil
                end
                local childs = ui_scrollView:getChildren()
                ui_scrollView:setTouchEnabled( false )
                for key, iconItem in pairs(childs) do
                    iconItem:setTouchEnabled( false )
                end
                _schedulerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(addFireExp, 0.01, false)
            end
        elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
           -- ui_scrollView:setTouchEnabled( true )
            local childs = ui_scrollView:getChildren()
            ui_scrollView:setTouchEnabled( true )
            for key, iconItem in pairs(childs) do
                iconItem:setTouchEnabled( true )
            end
            local sendAddFireData = function()
                if _useThingNums > 0 then
                    UIManager.showLoading()
                    local _msgData = {
                        header = StaticMsgRule.cureYFire,
                        msgdata =
                        {
                            int =
                            {
                                fireId = _curFireData.DictYFire.id,
                                type = ((sender == btn_30) and 0 or 1),
                                count = _useThingNums
                            }
                        }
                    }
                    netSendPackage(_msgData, netCallbackFunc)
                end
            end

            if _isCanEat then
                if _schedulerId then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_schedulerId)
                    _schedulerId = nil
                end
                if os.time() - _curFlagTime > 0 then
                    sendAddFireData()
                else
                    _curFlagTime = 0
                    addFireExp()
                    sendAddFireData()
                end
            end

        end
    end
    btn_30:addTouchEventListener(onSetFireValueEvent)
    btn_60:addTouchEventListener(onSetFireValueEvent)

    ui_scrollView = image_basemap:getChildByName("image_base_title"):getChildByName("view_fire")
    ui_svItem = ui_scrollView:getChildByName("btn_base_fire"):clone()
    ui_cardScrollView = image_basemap:getChildByName("view_warrior")
    ui_cardSVItem = ui_cardScrollView:getChildByName("panel_warrior"):clone()
end

local function getInstPlayerYFire(_fireId)
    if net.InstPlayerYFire then
        for key, obj in pairs(net.InstPlayerYFire) do
            if obj.int["3"] == _fireId then
                return obj
            end
        end
    end
end

function UIFire.setup(_k)
    dp.addTimerListener(doTimer)
    local fireData = { }
    for key, obj in pairs(DictYFire) do
        fireData[#fireData + 1] = {
            DictYFire = obj,
            InstPlayerYFire = getInstPlayerYFire(obj.id)
        }
    end
    utils.quickSort(fireData, function(obj1, obj2) if obj1.DictYFire.rank < obj2.DictYFire.rank then return true end end)
    layoutScrollView(ui_scrollView, ui_svItem, function(_item, _data)
        local ui_fireIcon = _item:getChildByName("image_fire")
        local ui_fireFlag = _item:getChildByName("image_title")
        local ui_fireState = _item:getChildByName("image_state")
        local ui_fireNumPanel = _item:getChildByName("image_namber")
        local ui_fireNum = ui_fireNumPanel:getChildByName("text_number")
        ui_fireIcon:loadTexture("image/fireImage/" .. DictUI[tostring(_data.DictYFire.smallUiId)].fileName)
        if _data.InstPlayerYFire then
            --            local _fireState = _data.InstPlayerYFire.int["4"] --0.未激活 1.旺盛  2.狂暴
            local _fireState = utils.getEquipFireState(_data.InstPlayerYFire.int["1"])
            if _fireState == 0 then
                ui_fireFlag:setVisible(true)
                ui_fireState:setVisible(false)
                ui_fireNumPanel:setVisible(true)
                ui_fireNum:setString(_data.InstPlayerYFire.int["9"] .. "/" .. _data.DictYFire.chipMax)
            else
                ui_fireFlag:setVisible(false)
                ui_fireState:setVisible(true)
                ui_fireNumPanel:setVisible(false)
                if _fireState == 1 then
                    ui_fireState:loadTexture("ui/fire_low.png")
                elseif _fireState == 2 then
                    ui_fireState:loadTexture("ui/fire_high.png")
                end
            end
        else
            ui_fireFlag:setVisible(true)
            ui_fireState:setVisible(false)
            ui_fireNumPanel:setVisible(true)
            ui_fireNum:setString("0/" .. _data.DictYFire.chipMax)
        end
    end , fireData, 5)

    initLineupData()

    local image_basemap = UIFire.Widget:getChildByName("image_basemap")
    local btn_60 = image_basemap:getChildByName("btn_base_fire2")
    btn_60:getChildByName("text_number"):setString("×" .. utils.getThingCount(StaticThing.thing304))
    btn_60:getChildByName("text_hint"):setString(Lang.ui_fire17 .. DictSysConfig[tostring(StaticSysConfig.fireCureVar)].value)

    local childs = ui_scrollView:getChildren()
    for key, iconItem in pairs(childs) do
        iconItem:addTouchEventListener( function(sender, eventType)
            if eventType == ccui.TouchEventType.ended and _curShowFireIndex ~= key then
                setScrollViewFocus(nil, key)
                setFireUI(fireData[key])
                _curShowFireIndex = key
            end
        end )
    end
    local _index = _curShowFireIndex and _curShowFireIndex or 1
    if _k then
        _index = _k
        _curShowFireIndex = nil
    end
    if childs and childs[_index] then
        childs[_index]:releaseUpEvent()
    end
end

function UIFire.show(_tableParams)
    UIManager.showLoading()
    local _msgData = {
        header = StaticMsgRule.enterYFire,
        msgdata = { }
    }
    netSendPackage(_msgData, function(_msgData)
        -- [//////////////// 更新异火数据 //////////////////]
        UIManager.hideWidget("ui_team_info")
        UIManager.showWidget("ui_fire")
        if _tableParams and _tableParams.showIndex then
            UIFire.setup(_tableParams.showIndex)
        end
    end )
    _msgData = nil
end

function UIFire.free()
    dp.removeTimerListener(doTimer)
    if _fireAnimaction and _fireAnimaction:getParent() then
        _fireAnimaction:removeFromParent()
        ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("ani/ui_anim/ui_anim50/ui_anim50.ExportJson")
        _fireAnimaction = nil
    end
    _curFireData = nil
    _curShowFireIndex = nil
    _currentTimer = 0
    _isPlayerAnimation = nil
    _formationData = nil
end

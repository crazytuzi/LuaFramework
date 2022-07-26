require"Lang"
UIAllianceEscort = {}

local CAR_POSITION = {
    { 
        { w = 1, t = "8~15", p = cc.p(208,813) }, { w = 1, t = "15~22", p = cc.p(193,778) }, { w = "1,2", t = "22~8", p = cc.p(172,759) },
        { w = 2, t = "8~15", p = cc.p(143,746) }, { w = 2, t = "15~22", p = cc.p(131,708) }, { w = "2,3", t = "22~8", p = cc.p(113,679) },
        { w = 3, t = "8~15", p = cc.p(124,647) }, { w = 3, t = "15~22", p = cc.p(146,630) }, { w = "3,4", t = "22~8", p = cc.p(155,590) },
        { w = 4, t = "8~15", p = cc.p(151,553) }, { w = 4, t = "15~22", p = cc.p(144,546) },
    },
    { 
        { w = 1, t = "8~15", p = cc.p(258,686) }, { w = 1, t = "15~22", p = cc.p(247,661) }, { w = "1,2", t = "22~8", p = cc.p(228,629) },
        { w = 2, t = "8~15", p = cc.p(233,596) }, { w = 2, t = "15~22", p = cc.p(250,564) }, { w = "2,3", t = "22~8", p = cc.p(245,523) },
        { w = 3, t = "8~15", p = cc.p(224,493) }, { w = 3, t = "15~22", p = cc.p(206,469) }, { w = "3,4", t = "22~8", p = cc.p(203,443) },
        { w = 4, t = "8~15", p = cc.p(215,394) }, { w = 4, t = "15~22", p = cc.p(200,339) },
    },
    { 
        { w = 1, t = "8~15", p = cc.p(376,736) }, { w = 1, t = "15~22", p = cc.p(387,714) }, { w = "1,2", t = "22~8", p = cc.p(401,681) },
        { w = 2, t = "8~15", p = cc.p(400,650) }, { w = 2, t = "15~22", p = cc.p(387,621) }, { w = "2,3", t = "22~8", p = cc.p(367,600) },
        { w = 3, t = "8~15", p = cc.p(358,545) }, { w = 3, t = "15~22", p = cc.p(371,515) }, { w = "3,4", t = "22~8", p = cc.p(376,417) },
        { w = 4, t = "8~15", p = cc.p(451,388) }, { w = 4, t = "15~22", p = cc.p(452,343) },
    },
    { 
        { w = 1, t = "8~15", p = cc.p(423,819) }, { w = 1, t = "15~22", p = cc.p(436,794) }, { w = "1,2", t = "22~8", p = cc.p(466,807) },
        { w = 2, t = "8~15", p = cc.p(481,825) }, { w = 2, t = "15~22", p = cc.p(504,836) }, { w = "2,3", t = "22~8", p = cc.p(531,830) },
        { w = 3, t = "8~15", p = cc.p(555,785) }, { w = 3, t = "15~22", p = cc.p(560,751) }, { w = "3,4", t = "22~8", p = cc.p(556,717) },
        { w = 4, t = "8~15", p = cc.p(506,675) }, { w = 4, t = "15~22", p = cc.p(490,568) },
    }
}
local DIALOG_TYPE_TQQD = "tqqd" --偷窃/抢夺弹框
local DIALOG_TYPE_QDCG = "qdcg" --抢夺成功弹框
local DIALOG_TYPE_QDSB = "qdsb" --抢夺失败弹框
local DIALOG_TYPE_TQCG = "tqcg" --偷窃成功弹框
local DIALOG_TYPE_HWXX = "hwxx" --护卫信息弹框
local DIALOG_TYPE_ZSCG = "zscg" --装死成功弹框
local DIALOG_TYPE_XQZ  = "xqz"  --悄悄行窃中/装死中弹框
local DIALOG_TYPE_QZZD = "qzzd" --强制进入战斗弹框
local DIALOG_TYPE_SSHB = "sshb" --抢夺后的护卫信息弹框

local showDialog
local countdownTimeFunc

local _serverMsgDat = nil
local userData = nil
local ui_carItem = nil
local ui_allianceItem = nil
local _countdownTime = 0
local _isShowDialog = false

local _escortDynaTempData = {{},{},{}}

local function refershEscortDyna(_isAction)
    if _isShowDialog then
        return
    end
    local dynaData = {}
    if net.InstUnionLootDyna then
        for key, obj in pairs(net.InstUnionLootDyna) do
            dynaData[#dynaData + 1] = obj
        end
        utils.quickSort(dynaData, function(obj1, obj2) if obj1.int["1"] < obj2.int["1"] then return true end end)
    end
    local image_basemap = UIAllianceEscort.Widget:getChildByName("image_basemap")
    local panel_info = image_basemap:getChildByName("image_di_info"):getChildByName("panel_info")
    local setLabelDyna = function()
        for i = 1, #_escortDynaTempData do
            local ui_dynaLabel = panel_info:getChildByName("text_info" .. i)
            local _tempDynaData = dynaData[i]
            for elementIndex = 0, #_escortDynaTempData[i] - 1 do
                ui_dynaLabel:removeElement(0)
            end
            local _tempTable = {}
            if _tempDynaData then
                ui_dynaLabel:insertElement(ccui.RichElementText:create(1, cc.c3b(255,255,255), 255, _tempDynaData.string["3"] .. "   ", dp.FONT, 18), 0)
                _tempTable[#_tempTable + 1] = _tempDynaData.string["3"] .. "   "
                local richText = utils.richTextFormat(_tempDynaData.string["2"])
                for key, obj in pairs(richText) do
		            ui_dynaLabel:insertElement(ccui.RichElementText:create(key+1, obj.color, 255, obj.text, dp.FONT, 18), key)
                    _tempTable[#_tempTable + 1] = obj.text
	            end
            end
            _escortDynaTempData[i] = _tempTable
            _tempTable = nil
        end
    end
    if _isAction then
        local _labelString = ""
        local _dataString = ""
        for i = 1, 3 do
            for _, _obj in pairs(_escortDynaTempData[i]) do
                _labelString = _labelString .. _obj
            end
            if dynaData[i] then
                _dataString = _dataString .. dynaData[i].string["3"] .. "   "
                for _, _str in pairs(utils.richTextFormat(dynaData[i].string["2"])) do
                    _dataString = _dataString .. _str.text
                end
            end
        end
        if _labelString ~= _dataString then
            panel_info:runAction(cc.Sequence:create(cc.MoveBy:create(0.5, cc.p(0, -51)), cc.CallFunc:create(function()
                setLabelDyna()
                panel_info:setPositionY(0)
                UIAllianceEscort.setup(true)
            end)))
        end
    else
        setLabelDyna()
    end
end

local function initUI(_msgData)
    local image_basemap = UIAllianceEscort.Widget:getChildByName("image_basemap")
    local todayCount = _msgData.msgdata.int["1"] --今日剩余下手次数
    local stealMill = _msgData.msgdata.int["2"] --偷窃倒计时(毫秒) 0-表示没有倒计时
    local allianceInfo = _msgData.msgdata.string["3"] --联盟信息：InstUnionLoot的Id|联盟实例ID|联盟状态(0-未解散 1-已解散)|联盟名字|联盟旗帜Id|马车上的金条数/
    if net.InstUnionLootDyna == nil and _msgData.msgdata.message and _msgData.msgdata.message.InstUnionLootDyna then
        net.InstUnionLootDyna = _msgData.msgdata.message.InstUnionLootDyna.message
        refershEscortDyna()
    end
    local alliandeData = utils.stringSplit(allianceInfo, "/")
    if stealMill > 0 then
        _countdownTime = math.ceil(stealMill / 1000)
        dp.addTimerListener(countdownTimeFunc)
    end
    local totalCount = DictSysConfig[tostring(StaticSysConfig.unionLootMaxStealTimes)].value --每日总次数
    for key, obj in pairs(DictUnionLootStealTimes) do
        if userData.allianceLevel == obj.unionLevel then
            totalCount = obj.stealTimes
            break
        end
    end
    local image_di_hint = image_basemap:getChildByName("image_di_hint")
    local ui_activityTime = image_di_hint:getChildByName("text_time")
    ui_activityTime:setString(Lang.ui_alliance_escort1)
    local ui_textCount = image_di_hint:getChildByName("text_number")
    ui_textCount:setString(string.format(Lang.ui_alliance_escort2, todayCount, totalCount))

    local _isActivityEnd = true --活动是否结束（主要看当前马车的金条数）
    local _isCurUnion = false --当前账号是否属于当前四个联盟
    for key, item in pairs(ui_carItem) do
        local ui_allianceName = ui_allianceItem[key]:getChildByName("text_name")
        local ui_allianceFlag = ui_allianceItem[key]:getChildByName("image_flag")
        local image_wheel = item:getChildByName("image_wheel")
        local image_frame_good = item:getChildByName("image_frame_good")
        --default
        ui_allianceName:setString("???")
        ui_allianceFlag:loadTexture("image/" .. DictUI[tostring(DictUnionFlag["1"].smallUiId)].fileName)
        item:setTouchEnabled(false)
        image_wheel:setTouchEnabled(false)
        image_frame_good:setTouchEnabled(false)

        if alliandeData[key] then
            local _tempData = utils.stringSplit(alliandeData[key], "|")
            local _instUnionLootId = tonumber(_tempData[1]) --InstUnionLoot的Id
            local _instUnionId = tonumber(_tempData[2]) --联盟实例ID
            local _unionState = tonumber(_tempData[3]) --联盟状态(0-未解散 1-已解散)
            local _unionName = _tempData[4] --联盟名字
            local _unionFlagId = tonumber(_tempData[5]) --联盟旗帜Id
            local _carGoldCount = tonumber(_tempData[6]) --马车上的金条数
            if _unionState == 1 then
                _carGoldCount = 0
            end

            if net.InstUnionMember.int["2"] == _instUnionId then
                _isCurUnion = true
            end
            ui_allianceName:setString(_unionName)
            ui_allianceFlag:loadTexture("image/" .. DictUI[tostring(DictUnionFlag[tostring(_unionFlagId)].smallUiId)].fileName)
            local ui_goldCount = ccui.Helper:seekNodeByName(item, "text_price")
            ui_goldCount:setString(tostring(_carGoldCount))
            --当前金条存量百分比值
            local _curGoldPer = _carGoldCount / DictUnionLootConfig["1"].initGoldBarNum
            if _curGoldPer <= DictSysConfig[tostring(StaticSysConfig.unionLootNoLootPer)].value then
                ui_goldCount:setTextColor(cc.c3b(255, 0, 0))
            else
                ui_goldCount:setTextColor(cc.c3b(0, 255, 252))
                _isActivityEnd = false
            end
            image_wheel:setTouchEnabled(true)
            image_wheel:addTouchEventListener(function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    item:releaseUpEvent()
                end
            end)
            image_frame_good:setTouchEnabled(true)
            image_frame_good:addTouchEventListener(function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    item:releaseUpEvent()
                end
            end)
            item:setTouchEnabled(true)
            item:addTouchEventListener(function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    if _isActivityEnd then
                        UIManager.showToast(Lang.ui_alliance_escort3)
                        return
                    elseif todayCount <= 0 then
                        UIManager.showToast(Lang.ui_alliance_escort4)
                        return
                    elseif _unionState == 1 then
                        UIManager.showToast(Lang.ui_alliance_escort5)
                        return
                    elseif net.InstUnionMember.int["2"] == _instUnionId then
--                            UIManager.showToast("不能抢夺自己的联盟马车")
                        return
                    elseif _curGoldPer <= DictSysConfig[tostring(StaticSysConfig.unionLootNoLootPer)].value then
                        UIManager.showToast(Lang.ui_alliance_escort6)
                        return
                    end
                    local _tqBtnDesc, _qdBtnDesc, _zsBtnDesc = nil, nil, nil
                    for _i, _obj in pairs(DictUnionLootPer) do
                        if _curGoldPer > _obj.goldBarStartPer and _curGoldPer <= _obj.goldBarEndPer then
                            local btnDesc = utils.stringSplit(_obj.description, "_")
                            _tqBtnDesc = btnDesc[1]
                            _qdBtnDesc = btnDesc[2]
                            _zsBtnDesc = btnDesc[3]
                            break
                        end
                    end
                    local _xqzFlag = Lang.ui_alliance_escort7
                    local _zszFlag = Lang.ui_alliance_escort8
                    local pushDialog = nil
                    pushDialog = function(_dialogType, _dataInfo, _showFlag)
                        local _dialogParams = {
                            unionName = _unionName,
                            goldCount = _carGoldCount,
                            todayCount = todayCount,
                            totalCount = totalCount,
                            playerInfo = _dataInfo,
                            showFlag = _showFlag,
                            leftDesc = "",
                            rightDesc = "",
                            leftBtnCallback = nil,
                            rightBtnCallback = nil,
                            isCurUnion = _isCurUnion
                        }
                        if _dialogType == DIALOG_TYPE_TQQD then
                            _dialogParams.leftDesc = _tqBtnDesc
                            _dialogParams.rightDesc = _qdBtnDesc
                            _dialogParams.countdownTime = _countdownTime
                            --偷窃按钮回调方法
                            _dialogParams.leftBtnCallback = function(closeDialog)
                                if _countdownTime > 0 then
                                    UIManager.showToast(Lang.ui_alliance_escort9)
                                    return
                                end
                                UIManager.showLoading()
                                netSendPackage( {
                                    header = StaticMsgRule.unionLootSteal,
                                    msgdata = { int = { instUnionLootId = _instUnionLootId } }
                                } , function(_messageData)
                                    closeDialog()
                                    --护卫信息  格式：玩家Id|头像Id|名字|等级|战力
                                    local _hwInfo = _messageData.msgdata.string["1"]
                                    pushDialog(DIALOG_TYPE_XQZ, _hwInfo, _xqzFlag)
                                end )
                            end
                            --抢夺按钮回调方法
                            _dialogParams.rightBtnCallback = function(closeDialog)
                                UIManager.showLoading()
                                netSendPackage( {
                                    header = StaticMsgRule.unionLootFightData,
                                    msgdata = { int = { instUnionLootId = _instUnionLootId } }
                                } , function(_messageData)
                                    pvp.loadGameData(_messageData)
                                    closeDialog()
                                    --护卫信息  格式：玩家Id|头像Id|名字|等级|战力
                                    local _hwInfo = _messageData.msgdata.string["1"]
                                    pushDialog(DIALOG_TYPE_SSHB, _hwInfo)
                                end )
                            end
                        elseif _dialogType == DIALOG_TYPE_SSHB then
                            --抢夺后护卫信息战斗按钮回调方法
                            _dialogParams.callbackFunc = function()
                                utils.sendFightData(true, dp.FightType.FIGHT_ESCORT, function(isWin)
                                    UIManager.showLoading()
                                    netSendPackage( {
                                        header = StaticMsgRule.unionLootResult,
                                        msgdata = { int = { fightResult = isWin } } --0-战斗失败  1-战斗胜利
                                    } , function(_resultData)
                                        if isWin == 1 then
                                            pushDialog(DIALOG_TYPE_QDCG, _resultData.msgdata.string["1"])
                                        else
                                            pushDialog(DIALOG_TYPE_QDSB)
                                        end
                                    end, function() UIManager.showScreen("ui_notice", "ui_alliance_activity") end )
                                end)
                                UIFightMain.loading()
                            end
                        elseif _dialogType == DIALOG_TYPE_XQZ then
                            --行窃中/装死中的回调方法
                            _dialogParams.callbackFunc = function()
                                if _showFlag == _xqzFlag then
                                    if _dataInfo then
                                        pushDialog(DIALOG_TYPE_HWXX, _dataInfo)
                                    else
                                        pushDialog(DIALOG_TYPE_TQCG)
                                    end
                                elseif _showFlag == _zszFlag then
                                    local _tempData = utils.stringSplit(_dataInfo, "_")
                                    if tonumber(_tempData[1]) == 1 then
                                        pushDialog(DIALOG_TYPE_ZSCG)
                                    elseif tonumber(_tempData[1]) == 0 then
                                        pushDialog(DIALOG_TYPE_QZZD, _tempData[2])
                                    end
                                end
                            end
                        elseif _dialogType == DIALOG_TYPE_HWXX then
                            _dialogParams.leftDesc = _zsBtnDesc
                            --装死按钮回调方法
                            _dialogParams.leftBtnCallback = function(callbackParams)
                                UIManager.showLoading()
                                netSendPackage( {
                                    header = StaticMsgRule.unionLootDead,
                                    msgdata = { int = { instUnionLootId = _instUnionLootId } }
                                } , function(_messageData)
                                    local _hwInfo = "1_" .. callbackParams
                                    if _messageData.msgdata.message and _messageData.msgdata.message.InstPlayer then
                                        _hwInfo = "0_" .. callbackParams
                                        pvp.loadGameData(_messageData)
                                    end
                                    UIManager.popScene()
                                    pushDialog(DIALOG_TYPE_XQZ, _hwInfo, _zszFlag)
                                end )
                            end
                            --死战按钮回调方法
                            _dialogParams.rightBtnCallback = function()
                                UIManager.showLoading()
                                netSendPackage( {
                                    header = StaticMsgRule.unionLootTough,
                                    msgdata = { int = { instUnionLootId = _instUnionLootId } }
                                } , function(_messageData)
                                    pvp.loadGameData(_messageData)
                                    UIManager.popScene()
                                    utils.sendFightData(true, dp.FightType.FIGHT_ESCORT, function(isWin)
                                        UIManager.showLoading()
                                        netSendPackage( {
                                            header = StaticMsgRule.unionLootToughFightRet,
                                            msgdata = { int = { fightResult = isWin } } --0-战斗失败  1-战斗胜利
                                        } , function(_resultData)
                                            if isWin == 1 then
                                                pushDialog(DIALOG_TYPE_QDCG, _resultData.msgdata.string["1"])
                                            else
                                                pushDialog(DIALOG_TYPE_QDSB)
                                            end
                                        end, function() UIManager.showScreen("ui_notice", "ui_alliance_activity") end )
                                    end)
                                    UIFightMain.loading()
                                end )
                            end
                        elseif _dialogType == DIALOG_TYPE_QZZD then
                            --强制进入战斗弹框的回调方法
                            _dialogParams.callbackFunc = function()
                                utils.sendFightData(nil, dp.FightType.FIGHT_ESCORT, function(isWin)
                                    UIManager.showLoading()
                                    netSendPackage( {
                                        header = StaticMsgRule.unionLootToughFightRet,
                                        msgdata = { int = { fightResult = isWin } } --0-战斗失败  1-战斗胜利
                                    } , function(_resultData)
                                        if isWin == 1 then
                                            pushDialog(DIALOG_TYPE_QDCG, _resultData.msgdata.string["1"])
                                        else
                                            pushDialog(DIALOG_TYPE_QDSB)
                                        end
                                    end, function() UIManager.showScreen("ui_notice", "ui_alliance_activity") end )
                                end)
                                UIFightMain.loading()
                            end
                        end
                        showDialog(_dialogType, _dialogParams)
                        if _dialogType == DIALOG_TYPE_QDCG or _dialogType == DIALOG_TYPE_QDSB or _dialogType == DIALOG_TYPE_TQCG or _dialogType == DIALOG_TYPE_ZSCG then
                            _isShowDialog = false
                        end
                    end
                    pushDialog(DIALOG_TYPE_TQQD)
                        
                end
            end)
        end
    end
end

function UIAllianceEscort.init()
    local image_basemap = UIAllianceEscort.Widget:getChildByName("image_basemap")
    local btn_back = image_basemap:getChildByName("btn_back")
    local btn_help = image_basemap:getChildByName("btn_help")
    local btn_rank = image_basemap:getChildByName("btn_rank")
    local panel_info = image_basemap:getChildByName("image_di_info"):getChildByName("panel_info")
    btn_back:setPressedActionEnabled(true)
    btn_help:setPressedActionEnabled(true)
    btn_rank:setPressedActionEnabled(true)
    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_back then
                UIAllianceActivity.show(userData)
            elseif sender == btn_help then
                UIAllianceHelp.show( { type = 23 , titleName = Lang.ui_alliance_escort10 } )
            elseif sender == btn_rank then
                UIAllianceEscortRank.show()
            elseif sender == panel_info then
                UIAllianceEscortDynamic.show()
            end
        end
    end
    btn_back:addTouchEventListener(onButtonEvent)
    btn_help:addTouchEventListener(onButtonEvent)
    btn_rank:addTouchEventListener(onButtonEvent)
    panel_info:addTouchEventListener(onButtonEvent)

    ui_carItem = {}
    for i = 1, #CAR_POSITION do
        ui_carItem[i] = image_basemap:getChildByName("image_escort" .. i)
        local image_wheel = ui_carItem[i]:getChildByName("image_wheel")
        image_wheel:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.RotateBy:create(1.5, 360))))
        local particle = cc.ParticleSystemQuad:create("particle/ui_anim70_1_1.plist")
        particle:setPosition(cc.p(ui_carItem[i]:getContentSize().width / 2, ui_carItem[i]:getContentSize().height * 0.7))
        particle:setScale(0.8)
        ui_carItem[i]:addChild(particle)
    end
    ui_allianceItem = {
        image_basemap:getChildByName("image_name2"),
        image_basemap:getChildByName("image_name4"),
        image_basemap:getChildByName("image_name5"),
        image_basemap:getChildByName("image_name3"),
    }
    for i = 1, #_escortDynaTempData do
        local ui_richText = ccui.RichText:create()
	    ui_richText:setName("text_info" .. i)
	    ui_richText:setPosition(cc.p(panel_info:getContentSize().width / 2, panel_info:getContentSize().height - (i - 1) * 50 - 50 / 2))
	    ui_richText:ignoreContentAdaptWithSize(false)
	    ui_richText:setContentSize(cc.size(panel_info:getContentSize().width, 50))
        panel_info:addChild(ui_richText)
    end
end

countdownTimeFunc = function()
    _countdownTime = _countdownTime - 1
    if _countdownTime < 0 then
        _countdownTime = 0
        dp.removeTimerListener(countdownTimeFunc)
    end
end

function UIAllianceEscort.setup(_LoadingFlag)
    local _curTime = utils.getCurrentTime()
    local _date = os.date("*t", _curTime)
    for key, item in pairs(ui_carItem) do
        item:setTouchEnabled(false)
        item:getChildByName("image_frame_good"):setTouchEnabled(false)
        item:getChildByName("image_wheel"):setTouchEnabled(false)
        local _cardPoint = nil
        for _k, _o in pairs(CAR_POSITION[key]) do
            if type(_o.w) == "string" then
                local _tempW = utils.stringSplit(_o.w, ",")
                local _tempT = utils.stringSplit(_o.t, "~")
                if _date.wday == tonumber(_tempW[1]) + 1 then
                    if _date.hour >= tonumber(_tempT[1]) then
                        _cardPoint = _o.p
                        break
                    end
                elseif _date.wday == tonumber(_tempW[2]) + 1 then
                    if _date.hour < tonumber(_tempT[2]) then
                        _cardPoint = _o.p
                        break
                    end
                end
            elseif type(_o.w) == "number" and _date.wday == _o.w + 1 then
                local _tempT = utils.stringSplit(_o.t, "~")
                if _date.hour >= tonumber(_tempT[1]) and _date.hour < tonumber(_tempT[2]) then
                    _cardPoint = _o.p
                    break
                end
            end
        end
        item:setPosition(_cardPoint and _cardPoint or CAR_POSITION[key][#CAR_POSITION[key]].p)
    end
    refershEscortDyna()
    if _serverMsgDat then
        initUI(_serverMsgDat)
        _serverMsgDat = nil
    else
        if _LoadingFlag == nil then
            UIManager.showLoading()
        end
        netSendPackage( {
            header = StaticMsgRule.intoUnionLoot, msgdata = {}
        } , function(_msgData)
            initUI(_msgData)
        end)
    end

    ---[[//每5秒刷新金条数(大壮要求)
    local _flagTimer = os.time()
    local image_basemap = UIAllianceEscort.Widget:getChildByName("image_basemap")
    image_basemap:scheduleUpdateWithPriorityLua(function(dt)
        if os.time() - _flagTimer >= 5 and netIsConnected() then
            _flagTimer = os.time()
            netSendPackage( {
                header = StaticMsgRule.intoUnionLoot, msgdata = {}
            } , function(_messageData)
                local alliandeData = utils.stringSplit(_messageData.msgdata.string["3"], "/")
                for key, item in pairs(ui_carItem) do
                    if alliandeData[key] then
                        local _tempData = utils.stringSplit(alliandeData[key], "|")
                        local _carGoldCount = tonumber(_tempData[6]) --马车上的金条数
                        local ui_goldCount = ccui.Helper:seekNodeByName(item, "text_price")
                        ui_goldCount:setString(tostring(_carGoldCount))
                    end
                end
            end)
        end
    end, 0)
    --//]]
end

function UIAllianceEscort.updateEscortDyna()
    if UIAllianceEscort.Widget and UIAllianceEscort.Widget:getParent() then
        refershEscortDyna(true)
    end
end

function UIAllianceEscort.free()
    local image_basemap = UIAllianceEscort.Widget:getChildByName("image_basemap")
    image_basemap:unscheduleUpdate()
    dp.removeTimerListener(countdownTimeFunc)
    _countdownTime = 0
    _serverMsgDat = nil
    _isShowDialog = false
end

function UIAllianceEscort.show(_tableParams)
    UIManager.showLoading()
    netSendPackage( {
        header = StaticMsgRule.intoUnionLoot, msgdata = {}
    } , function(_msgData)
        _serverMsgDat = _msgData
        userData = _tableParams
        UIManager.showWidget("ui_alliance_escort")
    end)
end

showDialog = function(_dialogType, _tableParams)
    _isShowDialog = true
    local class = require("ui_alliance_escort_" .. _dialogType)
    if type(class) == "table" and class.show then
        class.show(_tableParams)
    end
end

return UIAllianceEscort

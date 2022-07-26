require"Lang"
UIAllianceBoss = {}

local BOSS_MAX_BLOOD = 50000000

local _countdownStart = 0
local _countdownEnd = 0
local _countdownRebirth = 0
local _currentBossId = nil
local isAutoFight = false
local isEnterFight = false
local isJoinAllianceBoss = false

local _bossStartTimer, _bossEndTimer = nil, nil

local ui_normalPanel = nil
local ui_rankPanel = nil
local ui_fightPanel = nil
local ui_fightEndPanel = nil

local onEnterFight = nil
local netCallbackFunc = nil

local function getTimer(curTime, hour, minute)
    local _date = os.date("*t", curTime)
    _date.hour = hour
    if minute then
        _date.min = minute
    else
        _date.min = 0
    end
    _date.sec = 0
    return os.time(_date)
end

local function refreshMoney()
    local image_basemap = UIAllianceBoss.Widget:getChildByName("image_basemap")
    local image_bian = image_basemap:getChildByName("image_bian")
    local ui_fightValue = ccui.Helper:seekNodeByName(image_bian, "label_fight")
    local ui_gold = ccui.Helper:seekNodeByName(image_bian, "text_gold_number")
    local ui_money = ccui.Helper:seekNodeByName(image_bian, "text_silver_number")
    ui_fightValue:setString(tostring(utils.getFightValue()))
	ui_gold:setString(tostring(net.InstPlayer.int["5"]))
	ui_money:setString(net.InstPlayer.string["6"])
end

local function countDownFunc()
    _countdownStart = _countdownStart - 1
    if _countdownStart < 0 then
        _countdownStart = 0
    end
    if ui_normalPanel:isVisible() then
        local hour = math.floor(_countdownStart / 3600 % 24)
        local minute = math.floor(_countdownStart / 60 % 60)
        local second = math.floor(_countdownStart % 60)
        local ui_startCountDown = ccui.Helper:seekNodeByName(ui_normalPanel, "text_countdown")
        ui_startCountDown:setString(string.format(Lang.ui_alliance_boss1, hour, minute, second))
        if _countdownStart == 0 then
            ui_normalPanel:setVisible(true)
            ui_rankPanel:setVisible(false)
            ui_fightPanel:setVisible(false)
            ui_fightEndPanel:setVisible(false)
            ui_normalPanel:getParent():getChildByName("btn_challenge"):setVisible(true)
        end
    end

    _countdownEnd = _countdownEnd - 1
    if _countdownEnd < 0 then
        _countdownEnd = 0
    end
    if ui_fightPanel:isVisible() then
        local hour = math.floor(_countdownEnd / 3600 % 24)
        local minute = math.floor(_countdownEnd / 60 % 60)
        local second = math.floor(_countdownEnd % 60)
        local ui_endCountDown = ui_fightPanel:getChildByName("text_time")
        ui_endCountDown:setString(string.format(Lang.ui_alliance_boss2, hour, minute, second))
        if _countdownEnd == 0 then
            cclog("------------>>> 联盟BOSS已结束！")
            UIAllianceBoss.setup(true)
        end
    end

    _countdownRebirth = _countdownRebirth - 1
    if _countdownRebirth < 0 then
        _countdownRebirth = 0
    end
    if ui_fightPanel:isVisible() then
        local minute = math.floor(_countdownRebirth / 60 % 60)
        local second = math.floor(_countdownRebirth % 60)
        local btn_onFight = ui_fightPanel:getChildByName("btn_challenge")
        local ui_rebirthCountDown = btn_onFight:getChildByName("text_time")
        ui_rebirthCountDown:setString(string.format(Lang.ui_alliance_boss3, minute, second))
        if _countdownRebirth == 0 then
            ui_rebirthCountDown:setVisible(false)
            btn_onFight:setTitleText(Lang.ui_alliance_boss4)
            if isAutoFight and (not isEnterFight) then
                onEnterFight()
            end
        end
    end
end

local function cleanCardPanel()
    local cardPanel = ccui.Helper:seekNodeByName(UIAllianceBoss.Widget, "Panel_card")
    local childs = cardPanel:getChildren()
    for key, obj in pairs(childs) do
        if obj and obj:getTag() < 0 then
            obj:removeFromParent()
        end
    end
end

local function initBossCardUI(_bossIndex, _bossName)
    if _currentBossId ~= _bossIndex then
        _currentBossId = _bossIndex
        local bossData = CustomDictAllianceBoss[_bossIndex]
        
        if bossData then
            local cardPanel = ccui.Helper:seekNodeByName(UIAllianceBoss.Widget, "Panel_card")
            local cardNamePanel = ccui.Helper:seekNodeByName(UIAllianceBoss.Widget, "image_name")
            local ui_cardName = cardNamePanel:getChildByName("text_name")
--            local ui_cardLevel = cardNamePanel:getChildByName("text_lv")
            local ui_cardDesc = cardNamePanel:getChildByName("text_property")
--            ui_cardLevel:setString("LV." .. BOSS_SHOW_LEVEL)
            ui_cardDesc:setString(bossData.desc)
            local cardData = DictCard[tostring(bossData.cardId)]
            if _bossName and _bossName ~= "" then
                ui_cardName:setString(_bossName)
            else
                ui_cardName:setString(cardData.name)
            end
            if cardPanel:getChildByName("ui_bossCardAnimation") then
                cardPanel:getChildByName("ui_bossCardAnimation"):removeFromParent()
            end
            if ui_fightEndPanel:getChildByName("image_kill"):isVisible() then
                local cardImage = ccui.ImageView:create()
                cardImage:loadTexture("image/" .. DictUI[tostring(cardData.bigUiId)].fileName)
                cardImage:setPosition(cc.p(cardPanel:getContentSize().width / 2, cardPanel:getContentSize().height / 2 - 40))
                cardPanel:addChild(cardImage, 0, 1)
                cardImage:setScale(1.2)
                utils.GrayWidget(cardImage, true)
                cardImage:setName("ui_bossCardAnimation")
            else
                if cardData.animationFiles and string.len(cardData.animationFiles) > 0 then 
                    local cardAnim, cardAnimName = ActionManager.getCardAnimation(cardData.animationFiles, 1)
                    cardAnim:setPosition(cc.p(cardPanel:getContentSize().width / 2 - 40, cardPanel:getContentSize().height / 2 - 40 + 20))
                    cardPanel:addChild(cardAnim, 0, 1)
                    cardAnim:setScale(1.25)
                    cardAnim:setName("ui_bossCardAnimation")
                else
                    local cardAnim, cardAnimName = ActionManager.getCardBreatheAnimation("image/" .. DictUI[tostring(cardData.bigUiId)].fileName)
                    cardAnim:setPosition(cc.p(cardPanel:getContentSize().width / 2, cardPanel:getContentSize().height / 2 - 40))
                    cardPanel:addChild(cardAnim, 0, 1)
                    cardAnim:setScale(1.2)
                    cardAnim:setName("ui_bossCardAnimation")
                end
            end
--            ui_normalPanel:getChildByName("text_name"):setString(cardData.name)
        end
    end
end

local function onFightDoneDialog(_hurtValue, _callbackFunc)
    local toast_bg = cc.Scale9Sprite:create("ui/quality_middle.png")
    toast_bg:setAnchorPoint(cc.p(0.5, 0.5))
    toast_bg:setPreferredSize(cc.size(474, 105))
    toast_bg:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2))
    local description = ccui.Text:create()
    description:setFontSize(35)
    description:setFontName(dp.FONT)
    description:setTextColor(cc.c3b(255, 255, 0))
    description:setString(Lang.ui_alliance_boss5 .. _hurtValue)
    description:setPosition(cc.p(toast_bg:getPreferredSize().width / 2, toast_bg:getPreferredSize().height / 2))
    toast_bg:addChild(description)
    UIManager.uiLayer:addChild(toast_bg, 1000)
    toast_bg:retain()
    local hideToast = function()
        if toast_bg then
            UIManager.uiLayer:removeChild(toast_bg, true)
            cc.release(toast_bg)
        end
        if _callbackFunc then
            _callbackFunc()
        end
    end
    toast_bg:runAction(cc.Sequence:create(cc.MoveBy:create(0.3, cc.p(0, 80)), cc.DelayTime:create(0.8), cc.MoveBy:create(0.3, cc.p(0, 120)), cc.CallFunc:create(hideToast)))
end

netCallbackFunc = function(_msgData)
    local code = tonumber(_msgData.header)
    if code == StaticMsgRule.clickUnionBossBtn then
        local btn_challenge = ccui.Helper:seekNodeByName(UIAllianceBoss.Widget, "btn_challenge")
        local _curTime = utils.getCurrentTime()
        if _curTime >= _bossStartTimer then
            if _curTime >= _bossStartTimer and _curTime < _bossEndTimer then
                _countdownStart = 0
                _countdownEnd = _bossEndTimer - _curTime
                ui_normalPanel:setVisible(true)
                ui_rankPanel:setVisible(false)
                ui_fightPanel:setVisible(false)
                ui_fightEndPanel:setVisible(false)
                btn_challenge:setVisible(true)
            else
                _countdownStart = 24 * 60 * 60 - _curTime + _bossStartTimer
                _countdownEnd = 0
                ui_normalPanel:setVisible(false)
                ui_rankPanel:setVisible(true)
                ui_fightPanel:setVisible(false)
                ui_fightEndPanel:setVisible(true)
                btn_challenge:setVisible(false)
            end
        else
            _countdownStart = _bossStartTimer - _curTime
            _countdownEnd = 0
            ui_normalPanel:setVisible(true)
            ui_rankPanel:setVisible(true)
            ui_fightPanel:setVisible(false)
            ui_fightEndPanel:setVisible(false)
            btn_challenge:setVisible(false)
        end
        if ui_fightPanel:isVisible() then
            if net.InstPlayer.int["19"] >= DictSysConfig[tostring(StaticSysConfig.worldBossPcVip)].value then
                local btn_autoFight = ui_fightPanel:getChildByName("btn_auto")
                btn_autoFight:setBright(not isAutoFight)
            end
        end
        local allianceBossState = nil
        if _msgData.msgdata.int and _msgData.msgdata.int.unionBossState then
            allianceBossState = _msgData.msgdata.int.unionBossState
        end
        if allianceBossState == 0 then --活动结束或BOSS已死
            _countdownStart = 24 * 60 * 60 - _curTime + _bossStartTimer
            ui_normalPanel:setVisible(false)
            ui_rankPanel:setVisible(true)
            ui_fightPanel:setVisible(false)
            ui_fightEndPanel:setVisible(true)
            ccui.Helper:seekNodeByName(UIAllianceBoss.Widget, "btn_challenge"):setVisible(false)
            local hitState = _msgData.msgdata.int.hitState --击杀状态 0-未击杀 1-击杀
            ui_fightEndPanel:getChildByName("image_kill"):setVisible((hitState == 1) and true or false)
            local drawState = _msgData.msgdata.int.drawState -- 0-未参与,1-可领取,2-已领取
            local text_hint = ui_fightEndPanel:getChildByName("image_di_award"):getChildByName("text_hint")
            text_hint:setVisible(false)
            local btn_get = ccui.Helper:seekNodeByName(ui_fightEndPanel, "btn_get")
            btn_get:setVisible(true)
            if drawState == 1 then
                btn_get:setTitleText(Lang.ui_alliance_boss6)
                btn_get:setBright(true)
            elseif drawState == 2 then
                btn_get:setTitleText(Lang.ui_alliance_boss7)
                btn_get:setBright(false)
            else
                btn_get:setVisible(false)
                text_hint:setVisible(true)
            end
            local things = utils.stringSplit(_msgData.msgdata.string.drawReard, ";")
            for i = 1, 3 do
                local ui_frame = ccui.Helper:seekNodeByName(ui_fightEndPanel, "image_frame_good"..i)
                if drawState ~= 0 and things and things[i] then
                    local ui_icon = ui_frame:getChildByName("image_good")
                    local ui_name = ui_icon:getChildByName("text_name")
                    local ui_count = ccui.Helper:seekNodeByName(ui_frame, "text_number")
                    local itemProps = utils.getItemProp(things[i])
                    ui_frame:loadTexture(itemProps.frameIcon)
                    ui_icon:loadTexture(itemProps.smallIcon)
                    ui_name:setString(itemProps.name)
                    ui_count:setString(itemProps.count)
                    ui_frame:setVisible(true)
                else
                    ui_frame:setVisible(false)
                end
            end
        elseif allianceBossState == -1 then --活动未开始
        else --活动已开始
        end
        initBossCardUI(_msgData.msgdata.int.bossId, _msgData.msgdata.string.bossName)
        ccui.Helper:seekNodeByName(ui_rankPanel, "text_name1"):setString(_msgData.msgdata.string.firstName == "" and Lang.ui_alliance_boss8 or _msgData.msgdata.string.firstName)
        ccui.Helper:seekNodeByName(ui_rankPanel, "text_name2"):setString(_msgData.msgdata.string.twoName == "" and Lang.ui_alliance_boss9 or _msgData.msgdata.string.twoName)
        ccui.Helper:seekNodeByName(ui_rankPanel, "text_name3"):setString(_msgData.msgdata.string.threeName == "" and Lang.ui_alliance_boss10 or _msgData.msgdata.string.threeName)
        ccui.Helper:seekNodeByName(ui_rankPanel, "text_kill"):setString(Lang.ui_alliance_boss11..(_msgData.msgdata.string.hitName == "" and Lang.ui_alliance_boss12 or _msgData.msgdata.string.hitName))
    elseif code == StaticMsgRule.joinUnionBoss then
        local allianceBossState = _msgData.msgdata.int.unionBossState
        if allianceBossState == 0 then
            UIAllianceBoss.setup()
            UIManager.showToast(Lang.ui_alliance_boss13)
            return
        end
        isJoinAllianceBoss = true
        _countdownEnd = _bossEndTimer - utils.getCurrentTime()
        BOSS_MAX_BLOOD = _msgData.msgdata.long.maxBlood
        local _curBossBlood = _msgData.msgdata.long.remainBlood
        local ui_bossBloodBar = ccui.Helper:seekNodeByName(ui_fightPanel, "bar_blood")
        ui_bossBloodBar:setPercent(utils.getPercent(_curBossBlood, BOSS_MAX_BLOOD))
        ui_bossBloodBar:getChildByName("text_blood"):setString(_curBossBlood .. "/" .. BOSS_MAX_BLOOD)
        ui_bossBloodBar:getChildByName("text_blood_0"):setString(_curBossBlood .. "/" .. BOSS_MAX_BLOOD)
        local ui_curRank = ui_fightPanel:getChildByName("text_ranking")
        ui_curRank:setString(Lang.ui_alliance_boss14 .. _msgData.msgdata.int.rank)
        local ui_attackCount = ui_fightPanel:getChildByName("text_number_attack")
        ui_attackCount:setString(string.format(Lang.ui_alliance_boss15, _msgData.msgdata.int.fightNum))
        local ui_totalHurt = ui_fightPanel:getChildByName("text_hurt_all")
        ui_totalHurt:setString(Lang.ui_alliance_boss16 .. _msgData.msgdata.long.allHurt)
        ui_normalPanel:setVisible(false)
        ui_rankPanel:setVisible(false)
        ui_fightPanel:setVisible(true)
        ui_fightEndPanel:setVisible(false)
        ccui.Helper:seekNodeByName(UIAllianceBoss.Widget, "btn_challenge"):setVisible(false)

        local btn_autoFight = ui_fightPanel:getChildByName("btn_auto")
        local btn_rebirth = ui_fightPanel:getChildByName("btn_rebirth")
        local btn_onFight = ui_fightPanel:getChildByName("btn_challenge")
        local rebirthCount = _msgData.msgdata.int.lifeNum --已购买重生次数
        local _rebirthMoney = 0
        if rebirthCount + 1 == 1 then
            _rebirthMoney = DictSysConfig[tostring(StaticSysConfig.oneLiveGoldNum)].value
        elseif rebirthCount + 1 == 2 then
            _rebirthMoney = DictSysConfig[tostring(StaticSysConfig.twoLiveGoldNum)].value
        elseif rebirthCount + 1 == 3 then
            _rebirthMoney = DictSysConfig[tostring(StaticSysConfig.threeLiveGoldNum)].value
        end
        ccui.Helper:seekNodeByName(btn_rebirth, "text_rebirth"):setString(Lang.ui_alliance_boss17 .. _rebirthMoney)
        btn_rebirth:getChildByName("text_hint_revive"):setString(string.format(Lang.ui_alliance_boss18, 3 - rebirthCount))
        _countdownRebirth = _msgData.msgdata.long.time / 1000
        if _countdownRebirth <= 0 then
            btn_onFight:setTitleText(Lang.ui_alliance_boss19)
            btn_onFight:getChildByName("text_time"):setVisible(false)
        else
            btn_onFight:setTitleText("")
            btn_onFight:getChildByName("text_time"):setVisible(true)
        end
        if ui_fightPanel:isVisible() then
            if net.InstPlayer.int["19"] >= DictSysConfig[tostring(StaticSysConfig.worldBossPcVip)].value then
                btn_autoFight:setBright(not isAutoFight)
            end
        end

        btn_autoFight:setPressedActionEnabled(true)
        btn_rebirth:setPressedActionEnabled(true)
        btn_onFight:setPressedActionEnabled(true)
        local _buttonClickFlag = nil
        local onBtnEvent = function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if sender == btn_autoFight then
                    local _vipLv = DictSysConfig[tostring(StaticSysConfig.worldBossPcVip)].value
                    if net.InstPlayer.int["19"] >= _vipLv then
                        isAutoFight = not isAutoFight
                        btn_autoFight:setBright(not isAutoFight)
                        if isAutoFight and _countdownRebirth == 0 and btn_onFight:getTitleText() == Lang.ui_alliance_boss20 then
                            onEnterFight()
                        end
                    else
                        UIManager.showToast(Lang.ui_alliance_boss21 .. _vipLv)
                    end
                elseif sender == btn_rebirth then
                    if _buttonClickFlag and os.time() - _buttonClickFlag <= 1 then
                        return
                    end
                    _buttonClickFlag = os.time()
                    if rebirthCount == 3 then
                        UIManager.showToast(Lang.ui_alliance_boss22)
                        return
                    end
                    if _countdownRebirth > 0 then
                        UIManager.showLoading()
                        netSendPackage( { header = StaticMsgRule.rebirthUnionBoss, msgdata = { } }, netCallbackFunc)
                    else
                        UIManager.showToast(Lang.ui_alliance_boss23)
                    end
                elseif sender == btn_onFight then
                    if _countdownRebirth <= 0 then
                        if not isEnterFight then
                            onEnterFight()
                        end
                    else
                        UIManager.showToast(Lang.ui_alliance_boss24)
                    end
                end
            end
        end
        btn_autoFight:addTouchEventListener(onBtnEvent)
        btn_rebirth:addTouchEventListener(onBtnEvent)
        btn_onFight:addTouchEventListener(onBtnEvent)
    elseif code == StaticMsgRule.rebirthUnionBoss then
        local allianceBossState = _msgData.msgdata.int.unionBossState
        if allianceBossState == 0 then
            UIAllianceBoss.setup()
            UIManager.showToast(Lang.ui_alliance_boss25)
            return
        end
        local btn_rebirth = ui_fightPanel:getChildByName("btn_rebirth")
        local rebirthCount = _msgData.msgdata.int.buyNum --已购买重生次数
        local _rebirthMoney = 0
        if rebirthCount + 1 == 1 then
            _rebirthMoney = DictSysConfig[tostring(StaticSysConfig.oneLiveGoldNum)].value
        elseif rebirthCount + 1 == 2 then
            _rebirthMoney = DictSysConfig[tostring(StaticSysConfig.twoLiveGoldNum)].value
        elseif rebirthCount + 1 == 3 then
            _rebirthMoney = DictSysConfig[tostring(StaticSysConfig.threeLiveGoldNum)].value
        end
        ccui.Helper:seekNodeByName(btn_rebirth, "text_rebirth"):setString(Lang.ui_alliance_boss26 .. _rebirthMoney)
        btn_rebirth:getChildByName("text_hint_revive"):setString(string.format(Lang.ui_alliance_boss27, 3 - rebirthCount))
        _countdownRebirth = 0
        refreshMoney()
    end
end

onEnterFight = function()
    local function callBackFunc(bossOnceHurtValue)
        local closeCallback = function()
            UIManager.showScreen("ui_notice", "ui_alliance_boss")
            local _curTime = utils.getCurrentTime()
            if _curTime < _bossEndTimer then
                ui_normalPanel:setVisible(false)
                ui_rankPanel:setVisible(false)
                ui_fightPanel:setVisible(true)
                ui_fightEndPanel:setVisible(false)
                ccui.Helper:seekNodeByName(UIAllianceBoss.Widget, "btn_challenge"):setVisible(false)
                netSendPackage( { header = StaticMsgRule.joinUnionBoss, msgdata = { } }, netCallbackFunc)
            else
                UIManager.showToast(Lang.ui_alliance_boss28)
            end
            isEnterFight = false
        end
        onFightDoneDialog(bossOnceHurtValue, closeCallback)
--        UIBossHint.show({hurt = bossOnceHurtValue, attackCount = 5, isAuto = isAutoFight, callbackFunc = closeCallback})
    end
    local function fightDataCallback(isWin, fightIndex, bigRound, myDeaths, hpPercent, hurtValue, isSkipFight, fightersHP)
        --        _bossOnceHurtValue = math.floor(bossOnceHurtValue *(1 + encryptedTable._curHurtAdd / 100))
        UIManager.showLoading()
        netSendPackage( { header = StaticMsgRule.fightUnionBoss, msgdata = { int = { bossOnceHurt = hurtValue } } }, function(_msgData)
            local allianceBossState = _msgData.msgdata.int.unionBossState
            if allianceBossState == 0 then
                UIManager.showToast(Lang.ui_alliance_boss29)
                UIAllianceBoss.setup()
                isEnterFight = false
            else
                UIFightMain.loading()
            end
        end)
    end
    isEnterFight = true
    utils.sendFightData(CustomDictAllianceBoss[_currentBossId], dp.FightType.FIGHT_BOSS, callBackFunc, fightDataCallback)
end

function UIAllianceBoss.init()
    local image_basemap = UIAllianceBoss.Widget:getChildByName("image_basemap")

    ui_normalPanel = image_basemap:getChildByName("image_time")
    ui_rankPanel = image_basemap:getChildByName("image_di_info")
    ui_fightPanel = image_basemap:getChildByName("image_di_fight")
    ui_fightEndPanel = image_basemap:getChildByName("image_di_end")

    local btn_award = image_basemap:getChildByName("btn_award")
    local btn_hurt = image_basemap:getChildByName("btn_hurt")
    local btn_back = image_basemap:getChildByName("btn_back")
    local btn_embattle = image_basemap:getChildByName("btn_embattle")
    local btn_challenge = image_basemap:getChildByName("btn_challenge")
    local btn_get = ccui.Helper:seekNodeByName(ui_fightEndPanel, "btn_get")
    btn_award:setPressedActionEnabled(true)
    btn_hurt:setPressedActionEnabled(true)
    btn_back:setPressedActionEnabled(true)
    btn_embattle:setPressedActionEnabled(true)
    btn_challenge:setPressedActionEnabled(true)
    btn_get:setPressedActionEnabled(true)
    local onButtonEvent = function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_back then
                UIAlliance.show()
                isAutoFight = false
                isEnterFight = false
            elseif sender == btn_embattle then
                UIManager.pushScene("ui_lineup_embattle")
            elseif sender == btn_award then
                UIManager.showLoading()
                netSendPackage( { header = StaticMsgRule.unionBossReward, msgdata = { } }, function(_msgData)
                    UIBossPreview.reward = _msgData.msgdata.string.reward
                    UIManager.pushScene("ui_boss_preview")
                end)
            elseif sender == btn_hurt then
                UIManager.showLoading()
                netSendPackage( { header = StaticMsgRule.openUnionBossRank, msgdata = { } }, function(_msgData)
                    local _tempData = _msgData.msgdata.message and _msgData.msgdata.message or {}
                    local _playerRankingData = {}
                    for key, obj in pairs(_tempData) do
                        _playerRankingData[#_playerRankingData + 1] = obj
                    end
                    utils.quickSort(_playerRankingData, function(obj1, obj2) if obj1.int["1"] > obj2.int["1"] then return true end return false end)
                    UIBossRanking.setData(_playerRankingData)
                    UIManager.pushScene("ui_boss_ranking")
                end)
            elseif sender == btn_challenge then
                local _curTime = utils.getCurrentTime()
                if _curTime < _bossEndTimer then
                    UIManager.showLoading()
                    netSendPackage( { header = StaticMsgRule.joinUnionBoss, msgdata = { } }, netCallbackFunc)
                else
                    UIManager.showToast(Lang.ui_alliance_boss30)
                end
            elseif sender == btn_get and btn_get:isBright() then
                UIManager.showLoading()
                netSendPackage( { header = StaticMsgRule.drawUnionBossRankReward, msgdata = { } }, function(_msgData)
                    utils.showGetThings(_msgData.msgdata.string.things)
                    btn_get:setTitleText(Lang.ui_alliance_boss31)
                    btn_get:setBright(false)
                    refreshMoney()
                end)
            end
        end
    end
    btn_award:addTouchEventListener(onButtonEvent)
    btn_hurt:addTouchEventListener(onButtonEvent)
    btn_back:addTouchEventListener(onButtonEvent)
    btn_embattle:addTouchEventListener(onButtonEvent)
    btn_challenge:addTouchEventListener(onButtonEvent)
    btn_get:addTouchEventListener(onButtonEvent)
end

function UIAllianceBoss.setup(_notShowLoading)
    refreshMoney()

    local image_basemap = UIAllianceBoss.Widget:getChildByName("image_basemap")
    local btn_challenge = image_basemap:getChildByName("btn_challenge")
    ui_fightEndPanel:getChildByName("image_kill"):setVisible(false)
    ui_fightEndPanel:getChildByName("image_di_award"):getChildByName("text_hint"):setVisible(false)
    ccui.Helper:seekNodeByName(ui_rankPanel, "text_name1"):setString(Lang.ui_alliance_boss32)
    ccui.Helper:seekNodeByName(ui_rankPanel, "text_name2"):setString(Lang.ui_alliance_boss33)
    ccui.Helper:seekNodeByName(ui_rankPanel, "text_name3"):setString(Lang.ui_alliance_boss34)
    ccui.Helper:seekNodeByName(ui_rankPanel, "text_kill"):setString(Lang.ui_alliance_boss35)
    ui_normalPanel:setVisible(true)
    ui_rankPanel:setVisible(false)
    ui_fightPanel:setVisible(false)
    ui_fightEndPanel:setVisible(false)
    btn_challenge:setVisible(false)

    local _curTime = utils.getCurrentTime()
    -- (世界BOSS开始时间)每天中午12:30开启
    _bossStartTimer = getTimer(_curTime, 12, 30)
    -- (世界BOSS结束时间)每天中午13:00结束
    _bossEndTimer = getTimer(_curTime, 13)

    dp.addTimerListener(countDownFunc)
    cleanCardPanel()
    if not _notShowLoading then
        UIManager.showLoading()
    end
    netSendPackage( { header = StaticMsgRule.clickUnionBossBtn, msgdata = { } }, netCallbackFunc)
end

function UIAllianceBoss.free()
    UIManager.showLoading()
    if isJoinAllianceBoss then
        netSendPackage( { header = StaticMsgRule.exitUnionBoss, msgdata = { } })
    end
    isJoinAllianceBoss = false
    dp.removeTimerListener(countDownFunc)
    _countdownStart = 0
    _countdownEnd = 0
    _countdownRebirth = 0
    if not isEnterFight then
        isAutoFight = false
    end
    isEnterFight = false
    cleanCardPanel()
end

function UIAllianceBoss.pushData(_msgData)
    cclog("--------->>>  联盟BOSS同步数据！")
    if _msgData and _msgData.msgdata and _msgData.msgdata.int and _msgData.msgdata.int.unionBossBlood then
        local _curBossBlood = _msgData.msgdata.long.unionBossBlood
        if _curBossBlood < 0 then
            _curBossBlood = 0
        end
        local ui_bossBloodBar = ccui.Helper:seekNodeByName(ui_fightPanel, "bar_blood")
        ui_bossBloodBar:setPercent(utils.getPercent(_curBossBlood, BOSS_MAX_BLOOD))
        ui_bossBloodBar:getChildByName("text_blood"):setString(_curBossBlood .. "/" .. BOSS_MAX_BLOOD)
        ui_bossBloodBar:getChildByName("text_blood_0"):setString(_curBossBlood .. "/" .. BOSS_MAX_BLOOD)
        if _curBossBlood == 0 then
            netSendPackage( { header = StaticMsgRule.exitUnionBoss, msgdata = { } }, function(_msgData)
                UIAllianceBoss.setup()
                isJoinAllianceBoss = false
            end)
        end
    end

    if _msgData and _msgData.msgdata and _msgData.msgdata.message and _msgData.msgdata.message.randomFightBossPlayer then
        if _msgData.msgdata.message.randomFightBossPlayer.message then
            local randomPlayerData = _msgData.msgdata.message.randomFightBossPlayer.message

            local key = 1
            local function effectAction()
                local obj = randomPlayerData[tostring(key)]
                if obj then
                    -- for key, obj in pairs(randomPlayerData) do
                    cclog("------>>> 名称：" .. obj.string["1"] .. ", 伤害血量：" .. obj.int["2"])
                    -- 数字宽高定义
                    local damage = obj.int["2"]
                    local w1, h1 = 40, 55
                    local w2, h2 = 40, 55
                    -- 切割位置定义createDigit
                    local y, w, h = 0, 0, 0
                    y, w, h = h1, w2, h2
                    local function createDigit(n)
                        return cc.Sprite:create("image/fight_damage.png", cc.rect(n * w, y, w, h))
                    end
                    local bloodNode = cc.Node:create()
                    local digitNode = nil
                    local offsetOfX = 0
                    repeat
                        local nnn
                        damage, nnn = math.modf(damage / 10)
                        digitNode = createDigit(nnn * 10)
                        digitNode:setScale(0.8)
                        offsetOfX = offsetOfX - digitNode:getBoundingBox().width
                        digitNode:setPosition(offsetOfX, 0)
                        digitNode:setAnchorPoint(0, 0)
                        bloodNode:addChild(digitNode, 1, 1)
                    until damage == 0
                    -- 减号
                    digitNode = createDigit(10)
                    offsetOfX = offsetOfX - digitNode:getContentSize().width
                    digitNode:setPosition(offsetOfX, 0)
                    digitNode:setAnchorPoint(0, 0)
                    bloodNode:addChild(digitNode, 1, 2)

                    local totalWidth = - offsetOfX
                    local totalHeight = digitNode:getContentSize().height
                    -- 坐标修正
                    local children = bloodNode:getChildren()
                    for i = 1, #children do
                        local x, y = children[i]:getPosition()
                        x = x + totalWidth / 2
                        y = y - totalHeight / 2
                        children[i]:setPosition(x, y)
                    end
                    -- 名称
                    local playerName = ccui.Text:create()
                    playerName:setString(obj.string["1"])
                    playerName:setFontSize(40)
                    playerName:setFontName(dp.FONT)
                    playerName:enableOutline(cc.c4b(0, 0, 0, 255), 3)
                    playerName:setPosition(bloodNode:getContentSize().width / 2, bloodNode:getContentSize().height / 2 - playerName:getContentSize().height / 2 - 30)
                    playerName:setTextColor(cc.c4b(0xFF, 0x00, 0x00, 0xFF))
                    bloodNode:addChild(playerName, 1, 3)

                    local cardPanel = ccui.Helper:seekNodeByName(UIAllianceBoss.Widget, "Panel_card")
                    local effectRectW = bloodNode:getContentSize().width
                    local effectRectH = bloodNode:getContentSize().height
                    posX = utils.random(bloodNode:getContentSize().width + 100, cardPanel:getContentSize().width - bloodNode:getContentSize().width - 100)
                    posY = utils.random(bloodNode:getContentSize().height, cardPanel:getContentSize().height - bloodNode:getContentSize().height - 100)
                    -- 动画设计
                    posY = posY + 90
                    bloodNode:setScale(1.3)
                    bloodNode:runAction(
                    cc.Sequence:create(
                    cc.Spawn:create(
                    cc.ScaleTo:create(0.27, 1.8),
                    cc.MoveBy:create(0.27, cc.p(0, 30))
                    ),
                    cc.ScaleTo:create(0.18, 0.9),
                    cc.DelayTime:create(0.5),
                    cc.ScaleTo:create(0.18, 0),
                    cc.CallFunc:create( function()
                        if bloodNode then
                            bloodNode:removeFromParent()
                            effectAction()
                        end
                    end )
                    )
                    )
                    bloodNode:setPosition(posX, posY)
                    bloodNode:setAnchorPoint(0, 0)
                    cardPanel:addChild(bloodNode, 100)
                    -- end
                    key = key + 1
                else
                    key = 1
                end
            end
            effectAction()
        end
    end

end

function UIAllianceBoss.updateTimer(interval)
    if _countdownStart then
        _countdownStart = _countdownStart - interval
        if _countdownStart < 0 then
            _countdownStart = 0
        end
    end
    if _countdownEnd then
        _countdownEnd = _countdownEnd - interval
        if _countdownEnd < 0 then
            _countdownEnd = 0
        end
    end
    if _countdownRebirth then
        _countdownRebirth = _countdownRebirth - interval
        if _countdownRebirth < 0 then
            _countdownRebirth = 0
        end
    end
end

function UIAllianceBoss.show()
    UIManager.showWidget("ui_alliance_boss")
end

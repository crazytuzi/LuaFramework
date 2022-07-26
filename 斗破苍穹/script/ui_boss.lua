require"Lang"
UIBoss = { }

local ui_gold = nil
local ui_money = nil
local ui_kill = nil
local ui_normalPanel = nil
local ui_fightPanel = nil
local ui_countdownText = nil

local _bossStartTimer, _bossEndTimer

local _bossIntergral = 0
local _countdownTimes = 0
local _countdownTimerId = nil
local _bossEndCountdown = 0
local _bossEndCountdownId = nil
local _rebirthCountDown = 0
local _rebirthCountDownId = nil
local _isShowRanking = false
local worldBossIsOpen = false
local isJoinWorldBoss = false
local isCanChallenge = true
local isAutoFight = false
local isEnterFight = false
local encryptedTable = require("EncryptLuaTable").new()
local _playerRankingData = nil
local _currentBossId = nil
local _bossCardAnimation = nil
local _bossOnceHurtValue = 0
local _moneyAddNum = 0 -- 银币鼓舞次数
local _goldAddNum = 0 -- 金币鼓舞次数
local labelFight = nil
local _boxAnimation = nil

local BOSS_SHOW_LEVEL = 200 --世界BOSS的显示等级
local WORLD_BOSS_TOTAL_BLOOD = 50000000
local initWorldBoss
local onEnterFight

UIBoss.isShowImageHint = true

local function bossEndCountdown(dt)
    _bossEndCountdown = _bossEndCountdown - 1
    if _bossEndCountdown <= 0 then
        _bossEndCountdown = 0
        if _bossEndCountdownId then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_bossEndCountdownId)
        end
        _bossEndCountdownId = nil
        worldBossIsOpen = false
        cclog("------------->>>  世界BOSS已经结束了！")
--        initWorldBoss()
        UIBoss.setup()
    end
    local day = math.floor(_bossEndCountdown / 3600 / 24);
    -- 天
    local hour = math.floor(_bossEndCountdown / 3600 % 24)
    -- 小时
    local minute = math.floor(_bossEndCountdown / 60 % 60)
    -- 分
    local second = math.floor(_bossEndCountdown % 60)
    -- 秒
    -- 时间
    ui_fightPanel:getChildByName("text_time"):setString(string.format(Lang.ui_boss1, hour, minute, second))
end

local function rebirthCountDown(dt)
    _rebirthCountDown = _rebirthCountDown - 1
    local btn_challenge = ui_fightPanel:getChildByName("btn_challenge")
    local _challengeTime = btn_challenge:getChildByName("text_time")
    btn_challenge:setTitleText("")
    _challengeTime:setVisible(true)
    if _rebirthCountDown <= 0 then
        _rebirthCountDown = 0
        if _rebirthCountDownId then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_rebirthCountDownId)
        end
        _rebirthCountDownId = nil
        btn_challenge:setTitleText(Lang.ui_boss2)
        _challengeTime:setVisible(false)
        isCanChallenge = true
        if isAutoFight then
            onEnterFight()
        end
    end
    local day = math.floor(_rebirthCountDown / 3600 / 24);
    -- 天
    local hour = math.floor(_rebirthCountDown / 3600 % 24)
    -- 小时
    local minute = math.floor(_rebirthCountDown / 60 % 60)
    -- 分
    local second = math.floor(_rebirthCountDown % 60)
    -- 秒
    _challengeTime:setString(string.format(Lang.ui_boss3, minute, second))
end

local function countDown(dt)
    _countdownTimes = _countdownTimes - 1
    if _countdownTimes <= 0 then
        _countdownTimes = 0
        if _countdownTimerId then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_countdownTimerId)
        end
        _countdownTimerId = nil
        cclog("-------->>  世界BOSS已经开始了！")
        ui_normalPanel:getChildByName("btn_challenge"):setVisible(true)
        ui_normalPanel:getChildByName("image_di"):setVisible(false)
    end
    local day = math.floor(_countdownTimes / 3600 / 24);
    -- 天
    local hour = math.floor(_countdownTimes / 3600 % 24)
    -- 小时
    local minute = math.floor(_countdownTimes / 60 % 60)
    -- 分
    local second = math.floor(_countdownTimes % 60)
    -- 秒
    -- 时间
    if ui_countdownText then
        ui_countdownText:setString(string.format(Lang.ui_boss4, hour, minute, second))
    end
end

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

local function initBossCardUI(_bossIndex)
    if _currentBossId ~= _bossIndex then
        _currentBossId = _bossIndex
        local bossData = CustomDictWorldBoss[_bossIndex]
        
        if bossData then
            local cardPanel = ccui.Helper:seekNodeByName(UIBoss.Widget, "Panel_card")
            local cardNamePanel = ccui.Helper:seekNodeByName(UIBoss.Widget, "image_name")
            local ui_cardName = cardNamePanel:getChildByName("text_name")
            local ui_cardLevel = cardNamePanel:getChildByName("text_lv")
            local ui_cardDesc = cardNamePanel:getChildByName("text_property")
            ui_cardLevel:setString("LV." .. BOSS_SHOW_LEVEL)
            ui_cardDesc:setString(bossData.desc)
            local cardData = DictCard[tostring(bossData.cardId)]--杰克
            ui_cardName:setString(cardData.name)
            if _bossCardAnimation then
                _bossCardAnimation:removeFromParent()
                _bossCardAnimation = nil
            end
            if ui_kill:isVisible() then
                local cardImage = ccui.ImageView:create()
                cardImage:loadTexture("image/" .. DictUI[tostring(cardData.bigUiId)].fileName)
                cardImage:setPosition(cc.p(cardPanel:getContentSize().width / 2, cardPanel:getContentSize().height / 2 - 40))
                cardPanel:addChild(cardImage, 0, 1)
                cardImage:setScale(1.2)
                utils.GrayWidget(cardImage, true)
                _bossCardAnimation = cardImage
            else
                if cardData.animationFiles and string.len(cardData.animationFiles) > 0 then 
                    local cardAnim, cardAnimName = ActionManager.getCardAnimation(cardData.animationFiles, 1)
                    cardAnim:setPosition(cc.p(cardPanel:getContentSize().width / 2 - 40, cardPanel:getContentSize().height / 2 - 40 + 20))
                    cardPanel:addChild(cardAnim, 0, 1)
                    cardAnim:setScale(1.25)
                    _bossCardAnimation = cardAnim
                else
                    local cardAnim, cardAnimName = ActionManager.getCardBreatheAnimation("image/" .. DictUI[tostring(cardData.bigUiId)].fileName)
                    cardAnim:setPosition(cc.p(cardPanel:getContentSize().width / 2, cardPanel:getContentSize().height / 2 - 40))
                    cardPanel:addChild(cardAnim, 0, 1)
                    if cardData.id== 2002 then
                        cardAnim:setScale( 0.92 )
                    else
                        cardAnim:setScale(1.2)
                    end
                    _bossCardAnimation = cardAnim
                end
            end
            ui_normalPanel:getChildByName("text_name"):setString(cardData.name)
        end
    end
end

local function initPrevRankingData(_uiPanel)
    ccui.Helper:seekNodeByName(_uiPanel, "text_name1"):setString(Lang.ui_boss5)
    ccui.Helper:seekNodeByName(_uiPanel, "text_name2"):setString(Lang.ui_boss6)
    ccui.Helper:seekNodeByName(_uiPanel, "text_name3"):setString(Lang.ui_boss7)
    ccui.Helper:seekNodeByName(_uiPanel, "text_kill"):setString(Lang.ui_boss8)
    if _playerRankingData then
        local _textIndex = 1
        for key, obj in pairs(_playerRankingData) do
            if obj.int["1"] == 0 then
                ccui.Helper:seekNodeByName(_uiPanel, "text_kill"):setString(Lang.ui_boss9 .. obj.string["3"])
            else
                ccui.Helper:seekNodeByName(_uiPanel, "text_name" .. _textIndex):setString(obj.string["3"])
                _textIndex = _textIndex + 1
            end
            if _textIndex > 3 then
                break
            end
        end
    end
end

local function setFightPanelUI(_visible)
    ui_fightPanel:getChildByName("text_ranking"):setVisible(_visible)
    ui_fightPanel:getChildByName("text_number_attack"):setVisible(_visible)
    ui_fightPanel:getChildByName("text_hurt_all"):setVisible(_visible)
    ui_fightPanel:getChildByName("btn_auto"):setVisible(_visible)
    ui_fightPanel:getChildByName("btn_rebirth"):setVisible(_visible)
    ui_fightPanel:getChildByName("btn_challenge"):setVisible(_visible)
    ui_fightPanel:getChildByName("image_blood"):setVisible(_visible)
    ui_fightPanel:getChildByName("text_time"):setVisible(_visible)
    ui_fightPanel:getChildByName("text_hint"):setVisible(_visible)
    ui_fightPanel:getChildByName("text_hint_revive"):setVisible(_visible)
    ui_fightPanel:getChildByName("text_hint_award"):setVisible(true)
    ui_fightPanel:getChildByName("image_di"):setVisible(not _visible)
    ui_fightPanel:getChildByName("text_end_desc"):setVisible(not _visible)

    local image_box = ui_fightPanel:getChildByName("image_box")
    image_box:setOpacity(0)
    if _boxAnimation == nil then
        _boxAnimation = ActionManager.getEffectAnimation(37)
        _boxAnimation:setPosition(cc.p(image_box:getPositionX(), image_box:getPositionY()))
        image_box:getParent():addChild(_boxAnimation)
        _boxAnimation:setScale(1.2)
        _boxAnimation:getAnimation():playWithIndex(1)
    end
end

local function checkBox(_boxState)
    local _isShowBox = false
    local _curTime = utils.getCurrentTime()
    if _curTime >= _bossStartTimer then
        _isShowBox = true
        initPrevRankingData(ui_fightPanel)
        ui_normalPanel:setVisible(false)
        ui_fightPanel:setVisible(true)
        setFightPanelUI(false)
        local image_box = ui_fightPanel:getChildByName("image_box")
        image_box:setTouchEnabled(false)
        if _boxAnimation then
            if _boxState == 0 then
                _boxAnimation:getAnimation():playWithIndex(1)
            elseif _boxState == 1 then
                _boxAnimation:getAnimation():playWithIndex(0)
            elseif _boxState == 2 then
                _boxAnimation:getAnimation():playWithIndex(2)
            end
            image_box:setTouchEnabled(true)
            image_box:addTouchEventListener(function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    if _boxState == 0 then
                        UIManager.showToast(Lang.ui_boss10)
                    elseif _boxState == 1 then
                        UIManager.showLoading()
                        netSendPackage({header = StaticMsgRule.openBossBigBox, msgdata = { }}, function(_msgData)
                            UIBossAward.show({msgData = _msgData})
                            _boxAnimation:getAnimation():playWithIndex(2)
                            _boxState = 2
                        end)
                    elseif _boxState == 2 then
                        UIManager.showToast(Lang.ui_boss11)
                    end
                end
            end)
        end
    end
end

initWorldBoss = function()
    worldBossIsOpen = false
    if _bossEndCountdownId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_bossEndCountdownId)
    end
    _bossEndCountdownId = nil
    if _rebirthCountDownId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_rebirthCountDownId)
    end
    if _playerRankingData then
       initPrevRankingData(ui_normalPanel)
    end
    ui_normalPanel:setVisible(true)
    ui_fightPanel:setVisible(false)
    setFightPanelUI(true)
    ui_normalPanel:getChildByName("btn_challenge"):setVisible(false)
    ui_normalPanel:getChildByName("image_di"):setVisible(true)
    local _curTime = utils.getCurrentTime()
    if _countdownTimerId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_countdownTimerId)
    end
    if _curTime > _bossStartTimer then
        _countdownTimes = 24 * 60 * 60 - _curTime + _bossStartTimer
        _countdownTimerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(countDown, 1, false)
    elseif _curTime < _bossStartTimer then
        _countdownTimes = _bossStartTimer - _curTime
        _countdownTimerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(countDown, 1, false)
    end

    local cardPanel = ccui.Helper:seekNodeByName(UIBoss.Widget, "Panel_card")
    local childs = cardPanel:getChildren()
    for key, obj in pairs(childs) do
        if obj and obj:getTag() < 0 then
            obj:removeFromParent()
        end
    end
end

local function netCallbackFunc(data)
    local code = tonumber(data.header)
    if code == StaticMsgRule.clickWorldBossBtn then
        
        local worldBossState = nil
        if data.msgdata.int and data.msgdata.int.worldBossState then
            worldBossState = data.msgdata.int.worldBossState
        end
        if data.msgdata.int.bossIntergral then
            _bossIntergral = data.msgdata.int.bossIntergral
            UIBoss.refreshIntegral()
        end
        if data.msgdata.message and data.msgdata.message.rank and data.msgdata.message.rank.message then
            local _tempData = data.msgdata.message.rank.message
            _playerRankingData = nil
            for key, obj in pairs(_tempData) do
                if _playerRankingData == nil then
                    _playerRankingData = { }
                end
                _playerRankingData[#_playerRankingData + 1] = obj
            end
            utils.quickSort(_playerRankingData, function(obj1, obj2) if obj1.int["1"] > obj2.int["1"] then return true end return false end)
            if not worldBossIsOpen then
                initPrevRankingData(ui_normalPanel)
            end
        end
        local _bigBoxState = 0
        if data.msgdata.int and data.msgdata.int.bigBoxState then
            _bigBoxState = data.msgdata.int.bigBoxState --0:关闭，1:可领取，2:已领取
        end
        local _isShowHitState = nil
        if worldBossState == 0 then
            initWorldBoss()
            local _curTime = utils.getCurrentTime()
            if _curTime > _bossStartTimer then
                checkBox(_bigBoxState)
                _isShowHitState = true
            end
        else
            local _curTime = utils.getCurrentTime()
            if _curTime >= _bossEndTimer then
                checkBox(_bigBoxState)
                _isShowHitState = true
            end
        end
        if _isShowHitState then
            _currentBossId = nil
            if data.msgdata.int.hitState == 0 then --击杀状态 0-未击杀 1-击杀
                ui_kill:setVisible(false)
            elseif data.msgdata.int.hitState == 1 then
                ui_kill:setVisible(true)
--                ui_kill:setTag(1)
            end
        end
        initBossCardUI(data.msgdata.int.bossId)

        if data.msgdata.string.reward then
            UIBossPreview.reward = data.msgdata.string.reward
        end
        if _isShowRanking then
            _isShowRanking = false
            UIBossRanking.setData(_playerRankingData)
            UIManager.pushScene("ui_boss_ranking")
        end
    elseif code == StaticMsgRule.joinWorldBoss then
        if data.msgdata.int and data.msgdata.int.worldBossState then
            local worldBossState = data.msgdata.int.worldBossState
            if worldBossState == 0 then
                UIBoss.setup()
                return
            end
        end
        isJoinWorldBoss = true
        _bossEndCountdown = _bossEndTimer - utils.getCurrentTime()
        _bossEndCountdownId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(bossEndCountdown, 1, false)
        ui_normalPanel:setVisible(false)
        ui_fightPanel:setVisible(true)
        setFightPanelUI(true)
        if data.msgdata.message and data.msgdata.message.playerMsg then
            local initData = data.msgdata.message.playerMsg
            ui_fightPanel:getChildByName("text_number_attack"):setString(string.format(Lang.ui_boss12, initData.int["1"]))
            ui_fightPanel:getChildByName("text_hurt_all"):setString(string.format(Lang.ui_boss13, initData.int["2"]))
            _moneyAddNum = initData.int["3"]
            _goldAddNum = initData.int["4"]
            local _hurtAdd =(_moneyAddNum + _goldAddNum) * DictSysConfig[tostring(StaticSysConfig.worldBossInspire)].value
            encryptedTable._curHurtAdd =(_hurtAdd > 100 and 100 or _hurtAdd)
            local btn_rebirth = ui_fightPanel:getChildByName("btn_rebirth")
            local _rebirthMoney = 0
            if initData.int["5"] + 1 == 1 then
                _rebirthMoney = DictSysConfig[tostring(StaticSysConfig.oneLiveGoldNum)].value
            elseif initData.int["5"] + 1 == 2 then
                _rebirthMoney = DictSysConfig[tostring(StaticSysConfig.twoLiveGoldNum)].value
            elseif initData.int["5"] + 1 == 3 then
                _rebirthMoney = DictSysConfig[tostring(StaticSysConfig.threeLiveGoldNum)].value
            end
            ccui.Helper:seekNodeByName(btn_rebirth, "text_rebirth"):setString(Lang.ui_boss14 .._rebirthMoney)
            ui_fightPanel:getChildByName("text_hint_revive"):setString(string.format(Lang.ui_boss15, 3 - initData.int["5"]))
            _rebirthCountDown = initData.long["6"] / 1000
            if _rebirthCountDown > 0 then
                isCanChallenge = false
                if _rebirthCountDownId == nil then
                    _rebirthCountDownId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(rebirthCountDown, 1, false)
                end
            end
            ui_fightPanel:getChildByName("text_ranking"):setString(Lang.ui_boss16 .. initData.int["7"])
            local bossCurBlood = initData.long["8"]
            local bossBloodBar = ui_fightPanel:getChildByName("image_blood"):getChildByName("bar_blood")
            bossBloodBar:setPercent(bossCurBlood / WORLD_BOSS_TOTAL_BLOOD * 100)
            bossBloodBar:getChildByName("text_blood"):setString(bossCurBlood .. "/" .. WORLD_BOSS_TOTAL_BLOOD)
            bossBloodBar:getChildByName("text_blood_0"):setString(bossCurBlood .. "/" .. WORLD_BOSS_TOTAL_BLOOD)
        end
    elseif code == StaticMsgRule.fightWorldBoss then
        local worldBossState = nil
        if data.msgdata.int and data.msgdata.int.worldBossState then
            worldBossState = data.msgdata.int.worldBossState
        end
        local _attackCount = 0
        local initData = nil
        if data.msgdata.message and data.msgdata.message.playerMsg then
            initData = data.msgdata.message.playerMsg
            _attackCount = initData.int["1"]
        end
        if worldBossState ~= 0 and initData then
            ui_fightPanel:getChildByName("text_number_attack"):setString(string.format(Lang.ui_boss17, initData.int["1"]))
            ui_fightPanel:getChildByName("text_hurt_all"):setString(string.format(Lang.ui_boss18, initData.int["2"]))
            _rebirthCountDown = initData.long["6"] / 1000
            if _rebirthCountDown > 0 then
                isCanChallenge = false
                if _rebirthCountDownId then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_rebirthCountDownId)
                end
                _rebirthCountDownId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(rebirthCountDown, 1, false)
            end
            ui_fightPanel:getChildByName("text_ranking"):setString(Lang.ui_boss19 .. initData.int["7"])
        end
        local closeCallback = function()
            UIManager.showScreen("ui_notice", "ui_boss", "ui_menu")
            if worldBossState == 0 then
--                initWorldBoss()
--                UIBoss.setup()
--                -- UIManager.showToast("世界BOSS已经死了！")
                return
            end
            local _curTime = utils.getCurrentTime()
            if _curTime < _bossEndTimer then
                netSendPackage( { header = StaticMsgRule.joinWorldBoss, msgdata = { } }, netCallbackFunc)
            else
                UIManager.showToast(Lang.ui_boss20)
            end
        end
        UIBossHint.show({hurt = _bossOnceHurtValue, attackCount = _attackCount, isAuto = isAutoFight, callbackFunc = closeCallback})
    elseif code == StaticMsgRule.rebirthWorldBoss then
        local worldBossState = nil
        if data.msgdata.int and data.msgdata.int.worldBossState then
            worldBossState = data.msgdata.int.worldBossState
        end
        if worldBossState == 0 then
            initWorldBoss()
            UIManager.showToast(Lang.ui_boss21)
            return
        end
        if data.msgdata.message and data.msgdata.message.playerMsg then
            local initData = data.msgdata.message.playerMsg
            _rebirthCountDown = initData.int["6"] / 1000
            local btn_rebirth = ui_fightPanel:getChildByName("btn_rebirth")
            local _rebirthMoney = 0
            if initData.int["5"] + 1 == 1 then
                _rebirthMoney = DictSysConfig[tostring(StaticSysConfig.oneLiveGoldNum)].value
            elseif initData.int["5"] + 1 == 2 then
                _rebirthMoney = DictSysConfig[tostring(StaticSysConfig.twoLiveGoldNum)].value
            elseif initData.int["5"] + 1 == 3 then
                _rebirthMoney = DictSysConfig[tostring(StaticSysConfig.threeLiveGoldNum)].value
            end
            ccui.Helper:seekNodeByName(btn_rebirth, "text_rebirth"):setString(Lang.ui_boss22 .._rebirthMoney)
            ui_fightPanel:getChildByName("text_hint_revive"):setString(string.format(Lang.ui_boss23, 3 - initData.int["5"]))
        end
        ui_gold:setString(tostring(net.InstPlayer.int["5"]))
        ui_money:setString(net.InstPlayer.string["6"])
    end
end

onEnterFight = function()
    local _messageData = nil
    local function callBackFunc(bossOnceHurtValue)
        if _messageData then
            netCallbackFunc(_messageData)
        end
    end
    local function fightDataCallback(isWin, fightIndex, bigRound, myDeaths, hpPercent, hurtValue, isSkipFight, fightersHP)
        --        _bossOnceHurtValue = math.floor(bossOnceHurtValue *(1 + encryptedTable._curHurtAdd / 100))
        _bossOnceHurtValue = hurtValue
        UIManager.showLoading()
        netSendPackage( { header = StaticMsgRule.fightWorldBoss, msgdata = { int = { bossOnceHurt = _bossOnceHurtValue }, string = { coredata = utils.fightVerifyData() } } }, function(_msgData)
            local worldBossState = nil
            if _msgData.msgdata.int and _msgData.msgdata.int.worldBossState then
                worldBossState = _msgData.msgdata.int.worldBossState
            end
            local attackCount = nil
            if _msgData.msgdata.message and _msgData.msgdata.message.playerMsg then
                attackCount = _msgData.msgdata.message.playerMsg.int["1"]
            end
            if worldBossState == 0 and attackCount == nil then
                UIManager.showToast(Lang.ui_boss24)
                UIBoss.setup()
            else
                _messageData = _msgData
                isEnterFight = true
                UIFightMain.loading()
            end
        end)
    end
    
    utils.sendFightData(CustomDictWorldBoss[_currentBossId], dp.FightType.FIGHT_BOSS, callBackFunc, fightDataCallback)
--    isEnterFight = true
--    UIFightMain.loading()
end

function UIBoss.refreshIntegral(_integral)
    if _integral then
        _bossIntergral = _integral
    end
    if ui_integral then
        ui_integral:setString(_bossIntergral)
    end
end

function UIBoss.init()
    local image_base_title = ccui.Helper:seekNodeByName(UIBoss.Widget, "image_base_title")
    ui_gold = ccui.Helper:seekNodeByName(image_base_title, "text_gold_number")
    ui_money = ccui.Helper:seekNodeByName(image_base_title, "text_silver_number")
    ui_integral = image_base_title:getChildByName("image_integral"):getChildByName("text_number")
    labelFight = ccui.Helper:seekNodeByName(image_base_title, "label_fight")
    UIBoss.refreshIntegral()

    ui_normalPanel = ccui.Helper:seekNodeByName(UIBoss.Widget, "image_time")
    ui_fightPanel = ccui.Helper:seekNodeByName(UIBoss.Widget, "image_basedi_info")
    ui_kill = ccui.Helper:seekNodeByName(UIBoss.Widget, "image_kill")
    ui_countdownText = ccui.Helper:seekNodeByName(ui_normalPanel, "text_countdown")
    ui_countdownText:setString(string.format(Lang.ui_boss25, 0, 0, 0))

    local btn_embattle = ccui.Helper:seekNodeByName(UIBoss.Widget, "btn_embattle")
    local btn_back = ccui.Helper:seekNodeByName(UIBoss.Widget, "btn_back")
    local btn_award = ccui.Helper:seekNodeByName(UIBoss.Widget, "btn_award")
    local btn_hurt = ccui.Helper:seekNodeByName(UIBoss.Widget, "btn_hurt")
    local btn_shop = ccui.Helper:seekNodeByName(UIBoss.Widget, "btn_shop")
    local btn_challenge = ui_normalPanel:getChildByName("btn_challenge")
    local btn_auto = ui_fightPanel:getChildByName("btn_auto") -- 自动挑战按钮
    local btn_rebirth = ui_fightPanel:getChildByName("btn_rebirth") -- 重生按钮
    local btn_challenge2 = ui_fightPanel:getChildByName("btn_challenge")

    btn_embattle:setPressedActionEnabled(true)
    btn_back:setPressedActionEnabled(true)
    btn_award:setPressedActionEnabled(true)
    btn_hurt:setPressedActionEnabled(true)
    btn_shop:setPressedActionEnabled(true)
    btn_challenge:setPressedActionEnabled(true)
    btn_auto:setPressedActionEnabled(true)
    btn_rebirth:setPressedActionEnabled(true)
    btn_challenge2:setPressedActionEnabled(true)
    local _buttonClickFlag = nil
    local function onTouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_back then
                -- UIMenu.onActivity()
                UIMenu.onHomepage()
            elseif sender == btn_embattle then
                if net.InstPlayer.int["4"] >= DictFunctionOpen[ tostring( StaticFunctionOpen.partner ) ].level then
			        UIManager.pushScene("ui_lineup_embattle")
                else
                    UIManager.pushScene("ui_lineup_embattle_old")
                end
            elseif sender == btn_award then
                UIManager.pushScene("ui_boss_preview")
            elseif sender == btn_hurt then
                -- if _playerRankingData == nil or worldBossIsOpen then
                UIManager.showLoading()
                netSendPackage( { header = StaticMsgRule.clickWorldBossBtn, msgdata = { } }, netCallbackFunc)
                _isShowRanking = true
                -- else
                -- UIBossRanking.setData(_playerRankingData)
                -- UIManager.pushScene("ui_boss_ranking")
                -- end
            elseif sender == btn_shop then
                UIBossShop.show({bossIntergral=_bossIntergral})
            elseif sender == btn_challenge then
                local _curTime = utils.getCurrentTime()
                if _curTime < _bossEndTimer then
                    UIManager.showLoading()
                    netSendPackage( { header = StaticMsgRule.joinWorldBoss, msgdata = { } }, netCallbackFunc)
                else
                    UIManager.showToast(Lang.ui_boss26)
                end
            elseif sender == btn_auto then
                local _vipLv = DictSysConfig[tostring(StaticSysConfig.worldBossPcVip)].value
                if net.InstPlayer.int["19"] >= _vipLv then
                    cclog("------------>> 自动挑战")
                    isAutoFight = not isAutoFight
                    btn_auto:setBright(not isAutoFight)
                    if isAutoFight and _rebirthCountDown == 0 and btn_challenge2:getTitleText() == Lang.ui_boss27 then
                        onEnterFight()
                    end
                else
                    UIManager.showToast(Lang.ui_boss28 .. _vipLv)
                end
            elseif sender == btn_rebirth then
                if _buttonClickFlag and os.time() - _buttonClickFlag <= 1 then
                    return
                end
                _buttonClickFlag = os.time()
                if _rebirthCountDownId then
                    UIManager.showLoading()
                    netSendPackage( { header = StaticMsgRule.rebirthWorldBoss, msgdata = { } }, netCallbackFunc)
                else
                    UIManager.showToast(Lang.ui_boss29)
                end
            elseif sender == btn_challenge2 then
                if isCanChallenge then
                    onEnterFight()
                else
                    UIManager.showToast(Lang.ui_boss30)
                end
            end
        end
    end
    btn_embattle:addTouchEventListener(onTouchEvent)
    btn_back:addTouchEventListener(onTouchEvent)
    btn_award:addTouchEventListener(onTouchEvent)
    btn_hurt:addTouchEventListener(onTouchEvent)
    btn_shop:addTouchEventListener(onTouchEvent)
    btn_challenge:addTouchEventListener(onTouchEvent)
    btn_auto:addTouchEventListener(onTouchEvent)
    btn_rebirth:addTouchEventListener(onTouchEvent)
    btn_challenge2:addTouchEventListener(onTouchEvent)

    ccui.Helper:seekNodeByName(ui_normalPanel, "text_name1"):setString(Lang.ui_boss31)
    ccui.Helper:seekNodeByName(ui_normalPanel, "text_name2"):setString(Lang.ui_boss32)
    ccui.Helper:seekNodeByName(ui_normalPanel, "text_name3"):setString(Lang.ui_boss33)
    ccui.Helper:seekNodeByName(ui_normalPanel, "text_kill"):setString(Lang.ui_boss34)
end

function UIBoss.setup()
    ui_gold:setString(tostring(net.InstPlayer.int["5"]))
    ui_money:setString(net.InstPlayer.string["6"])
    ui_kill:setVisible(false)
    ui_normalPanel:setVisible(true)
    ui_fightPanel:setVisible(false)
    ui_normalPanel:getChildByName("btn_challenge"):setVisible(false)
    ui_normalPanel:getChildByName("image_di"):setVisible(true)
    ui_fightPanel:getChildByName("btn_challenge"):setTitleText(Lang.ui_boss35)
    ui_fightPanel:getChildByName("btn_challenge"):getChildByName("text_time"):setVisible(false)

    local _curTime = utils.getCurrentTime()
    -- (世界BOSS开始时间)每晚21:00开启
    _bossStartTimer = getTimer(_curTime, DictSysConfig[tostring(StaticSysConfig.worldBossStartTime)].value)
    -- (世界BOSS结束时间)每晚21:30结束
    _bossEndTimer = getTimer(_curTime, DictSysConfig[tostring(StaticSysConfig.worldBossStartTime)].value, DictSysConfig[tostring(StaticSysConfig.worldBossLongTime)].value)

    worldBossIsOpen = false
    if _countdownTimerId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_countdownTimerId)
    end
    if _curTime >= _bossStartTimer then
        if _curTime >= _bossStartTimer and _curTime < _bossEndTimer then
            cclog("-------->>  世界BOSS已经开始了！")
            if not ui_countdownText or tolua.isnull(ui_countdownText) then
                ui_countdownText = ccui.Helper:seekNodeByName(UIBoss.Widget, "text_countdown")
            end
            ui_countdownText:setString(string.format(Lang.ui_boss36, 0, 0, 0))
            _countdownTimes = 0
            ui_normalPanel:getChildByName("btn_challenge"):setVisible(true)
            ui_normalPanel:getChildByName("image_di"):setVisible(false)
            worldBossIsOpen = true
        else
            _countdownTimes = 24 * 60 * 60 - _curTime + _bossStartTimer
            _countdownTimerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(countDown, 1, false)
        end
    elseif _curTime < _bossStartTimer then
        _countdownTimes = _bossStartTimer - _curTime
        _countdownTimerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(countDown, 1, false)
    end

    -- if worldBossIsOpen or _playerRankingData == nil then
    UIManager.showLoading()
    netSendPackage( { header = StaticMsgRule.clickWorldBossBtn, msgdata = { } }, netCallbackFunc)
    -- else
    -- initPrevRankingData(ui_normalPanel)
    -- end

    if net.InstPlayer.int["19"] >= DictSysConfig[tostring(StaticSysConfig.worldBossPcVip)].value then
        local btn_auto = ui_fightPanel:getChildByName("btn_auto")
        if btn_auto:isVisible() then
            -- btn_auto:setBright(true)
            btn_auto:setBright(not isAutoFight)
        end
    end
    if _curTime >= _bossStartTimer and _curTime < _bossEndTimer then
        UIBoss.isShowImageHint = false
    end
    -- ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_dogfight"):getChildByName("image_hint"):setVisible(false)
    if labelFight then
        labelFight:setString(tostring(utils.getFightValue()))
    end
end

function UIBoss.free()
    if isJoinWorldBoss then
        netSendPackage( { header = StaticMsgRule.exitWorldBoss, msgdata = { } })
    end
    isJoinWorldBoss = false
    if _countdownTimerId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_countdownTimerId)
    end
    _countdownTimerId = nil

    if _bossEndCountdownId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_bossEndCountdownId)
    end
    _bossEndCountdownId = nil

    _isShowRanking = false
    if not isEnterFight then
        isAutoFight = false
    end
    isEnterFight = false

    local cardPanel = ccui.Helper:seekNodeByName(UIBoss.Widget, "Panel_card")
    local childs = cardPanel:getChildren()
    for key, obj in pairs(childs) do
        if obj and obj:getTag() < 0 then
            obj:removeFromParent()
        end
    end
end

function UIBoss.updateTimer(interval)
    if _countdownTimes then
        _countdownTimes = _countdownTimes - interval
        if _countdownTimes < 0 then
            _countdownTimes = 0
        end
    end
    if _bossEndCountdown then
        _bossEndCountdown = _bossEndCountdown - interval
        if _bossEndCountdown < 0 then
            _bossEndCountdown = 0
        end
    end
    if _rebirthCountDown then
        _rebirthCountDown = _rebirthCountDown - interval
        if _rebirthCountDown < 0 then
            _rebirthCountDown = 0
        end
    end
end

function UIBoss.pushData(data)
    cclog("--------->>>  世界BOSS同步数据！")
    if data and data.msgdata and data.msgdata.long and data.msgdata.long.worldBossBlood then
        if data.msgdata.long.initWorldBossBlood then
            WORLD_BOSS_TOTAL_BLOOD = data.msgdata.long.initWorldBossBlood
        end
        local bossCurBlood = data.msgdata.long.worldBossBlood
        if bossCurBlood <= 0 then
            bossCurBlood = 0
        end
        local bossBloodBar = ui_fightPanel:getChildByName("image_blood"):getChildByName("bar_blood")
        bossBloodBar:setPercent(bossCurBlood / WORLD_BOSS_TOTAL_BLOOD * 100)
        bossBloodBar:getChildByName("text_blood"):setString(bossCurBlood .. "/" .. WORLD_BOSS_TOTAL_BLOOD)
        bossBloodBar:getChildByName("text_blood_0"):setString(bossCurBlood .. "/" .. WORLD_BOSS_TOTAL_BLOOD)
        if bossCurBlood == 0 then
            initWorldBoss()
        end
    end
    if data and data.msgdata and data.msgdata.message and data.msgdata.message.randomFightBossPlayer then
        if data.msgdata.message.randomFightBossPlayer.message then
            local randomPlayerData = data.msgdata.message.randomFightBossPlayer.message

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

                    local cardPanel = ccui.Helper:seekNodeByName(UIBoss.Widget, "Panel_card")
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

function UIBoss.checkImageHint()
    local result = false
    local _curTime = utils.getCurrentTime()
    _bossStartTimer = getTimer(_curTime, DictSysConfig[tostring(StaticSysConfig.worldBossStartTime)].value)
    -- (世界BOSS开始时间)每晚21:00开启
    _bossEndTimer = getTimer(_curTime, DictSysConfig[tostring(StaticSysConfig.worldBossStartTime)].value, DictSysConfig[tostring(StaticSysConfig.worldBossLongTime)].value)
    -- (世界BOSS结束时间)每晚21:30结束
    if _curTime >= _bossStartTimer and _curTime < _bossEndTimer and net.InstPlayer.int["4"] >= DictFunctionOpen[tostring(StaticFunctionOpen.worldBoss)].level and UIBoss.isShowImageHint then
        result = true
    end
    return result
end

require"Lang"
UIArena = { }

UIArena.isFromMain = false -- 标记是否是从首页过来，以判断返回键返回到哪里
local ui_teamFight = nil -- 战力
local ui_teamGold = nil -- 元宝
local ui_teamMoney = nil -- 银币
local btn_Challenge = nil -- 竞技按钮
local btn_Ranking = nil -- 排行按钮
local btn_Exchange = nil -- 兑换按钮
local ui_textRanking = nil
local ui_textWeiwang = nil
local ui_imageWeiwang = nil
local ui_textWeiwangNum = nil
local ui_textChallengeNum = nil
local ui_imageStamina = nil
local ui_textWait = nil
local ui_textWaitTime = nil
local image_weiwangExchange = nil -- 威望兑换
local ui_awardTime = nil

local ui_scrollView = nil
local sv_item1, sv_item2 = nil, nil
local selfItem, enemyItem

local _listData = nil
local _prevLabelBtn = nil
local _currentRanking = 0 -- 当前排名
local _currentPrestige = 0 -- 当前威望

local _awardTimerId = nil
local _awardTime = 0

local TEST_playerName = nil
local TEST_playerId = nil
local TEST_rank = nil
local TEST_warWin = nil
local TEST_playerCardId = nil

local TEXT_3 = Lang.ui_arena1
local TEXT_4 = Lang.ui_arena2
local TEXT_5 = Lang.ui_arena3

local initScrollView
local netCallbackFunc

local _fightType = nil
local _fightTimes = nil

local _fightAllTimes = 5

local function awardCountDown(dt)
    _awardTime = _awardTime - 1
    if _awardTime <= 0 then
        _awardTime = 0
        if _awardTimerId then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_awardTimerId)
        end
        _awardTimerId = nil
    end
    local day = math.floor(_awardTime / 3600 / 24);
    -- 天
    local hour = math.floor(_awardTime / 3600 % 24)
    -- 小时
    local minute = math.floor(_awardTime / 60 % 60)
    -- 分
    local second = math.floor(_awardTime % 60)
    -- 秒
    -- 时间
    if _prevLabelBtn == btn_Ranking then
        if ui_textWaitTime then
            ui_textWaitTime:setString(string.format("%02d:%02d:%02d", hour, minute, second))
        end
    else
        if ui_awardTime then
            ui_awardTime:setString(string.format("%02d:%02d:%02d", hour, minute, second))
        end
    end
end

local function startAwardTimer(_time)
    if _awardTimerId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_awardTimerId)
        _awardTimerId = nil
    end
    _awardTime = _time
    _awardTimerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(awardCountDown, 1, false)
end

function UIArena.updateRanking()
    local dialog = ccui.Layout:create()
    dialog:setContentSize(UIManager.screenSize)
    -- dialog:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    -- dialog:setBackGroundColor(cc.c3b(0, 0, 0))
    -- dialog:setBackGroundColorOpacity(130)
    dialog:setTouchEnabled(true)
    dialog:retain()
    local bg_image = cc.Scale9Sprite:create("ui/dialog_bg.png")
    bg_image:setAnchorPoint(cc.p(0.5, 0.5))
    bg_image:setPreferredSize(cc.size(450, 300))
    bg_image:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2))
    dialog:addChild(bg_image)
    local bgSize = bg_image:getPreferredSize()

    local msgLabel = ccui.Text:create()
    msgLabel:setString(Lang.ui_arena4)
    msgLabel:setFontName(dp.FONT)
    msgLabel:setTextAreaSize(cc.size(325, 200))
    msgLabel:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    msgLabel:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    msgLabel:setFontSize(23)
    msgLabel:setTextColor(cc.c4b(255, 255, 255, 255))
    msgLabel:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.7))
    bg_image:addChild(msgLabel)

    local sureBtn = ccui.Button:create("ui/tk_btn01.png", "ui/tk_btn01.png")
    sureBtn:setTitleText(Lang.ui_arena5)
    sureBtn:setTitleFontName(dp.FONT)
    sureBtn:setTitleColor(cc.c3b(51, 25, 4))
    sureBtn:setTitleFontSize(23)
    sureBtn:setPressedActionEnabled(true)
    sureBtn:setTouchEnabled(true)
    sureBtn:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.25))
    bg_image:addChild(sureBtn)
    local function btnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            UIManager.uiLayer:removeChild(dialog, true)
            cc.release(dialog)
            UIArena.setup()
        end
    end
    sureBtn:addTouchEventListener(btnEvent)
    UIManager.uiLayer:addChild(dialog, 10000)
end
local _msg = nil
function UIArena.onEnter()
    print("_msg : ", _msg)
    if _msg and type(_msg) == "table" then
        UIManager.pushScene("ui_arena_history")
        UIArenaHistory.refreshUILabel(_msg[1], _msg[2])
    end
end

function UIArena.showToast(msg)
    _msg = nil
    if type(msg) == "table" then
        _msg = msg
    else
        local toast_bg = cc.Scale9Sprite:create("ui/dialog_bg.png")
        toast_bg:setAnchorPoint(cc.p(0.5, 0.5))
        toast_bg:setPreferredSize(cc.size(500, 120))
        toast_bg:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2))
        local bgSize = toast_bg:getPreferredSize()
        local text = ccui.Text:create()
        text:setFontName(dp.FONT)
        text:setString(msg)
        text:setFontSize(20)
        text:setTextColor(cc.c4b(255, 255, 255, 255))
        text:setTextAreaSize(bgSize)
        text:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        text:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        text:setPosition(cc.p(bgSize.width / 2, bgSize.height / 2))
        toast_bg:addChild(text)
        UIManager.gameScene:addChild(toast_bg, 100)
        local function hideToast()
            if toast_bg then
                UIManager.gameScene:removeChild(toast_bg, true)
            end
        end
        toast_bg:runAction(cc.Sequence:create(cc.MoveBy:create(0.3, cc.p(0, 30)), cc.DelayTime:create(3), cc.CallFunc:create(hideToast)))
    end
end

local function initArenaData()
    if net.InstPlayerArena then
        _currentRanking = net.InstPlayerArena.int["3"]
        _currentPrestige = net.InstPlayer.int["39"]
        ui_textRanking:setString(TEXT_5 .. _currentRanking)
        ui_imageStamina:getChildByName("text_enargy"):setString(net.InstPlayer.int["10"] .. "/" .. net.InstPlayer.int["11"])
        ui_textWeiwangNum:setString(tostring(_currentPrestige))
        image_weiwangExchange:getChildByName("text_weiwang_number"):setString(tostring(_currentPrestige))
    end
end

local function netErrorCallBack(pack)
    if UIArenaFight.Widget and UIArenaFight.Widget:getParent() then
        UIArenaFight.reset()
    end
end

function netCallbackFunc(data)
    local code = tonumber(data.header)
    if code == StaticMsgRule.arena or code == StaticMsgRule.arenaList then
        if code == StaticMsgRule.arena then
            initArenaData()
        end
        if data.msgdata.message then
            _listData = { }
            for key, obj in pairs(data.msgdata.message) do
                _listData[#_listData + 1] = obj
            end
            utils.quickSort(_listData, function(obj1, obj2) if obj1.int["1"] > obj2.int["1"] then return true end return false end)
        end
        initScrollView()
    elseif code == StaticMsgRule.enemyPlayerInfo then
        pvp.loadGameData(data)
        UIManager.pushScene("ui_arena_check")
    elseif code == StaticMsgRule.arenaWar then
        pvp.loadGameData(data)
        cclog("------------>>> 进入战斗界面 ！！！！！！！！")
        local function callBackFunc(isWin)
            TEST_warWin = isWin
            UIManager.showLoading()
            netSendPackage( { header = StaticMsgRule.arenaWarWin, msgdata = { int = { playerId = TEST_playerId, rank = TEST_rank, warWin = TEST_warWin }, string = { coredata = GlobalLastFightCheckData } } }, netCallbackFunc)
        end
        local function callBackFunc1(isWin)
            _fightTimes = _fightTimes + 1
            if UIArenaFight.Widget and UIArenaFight.Widget:getParent() then
            else
                UIArenaFight.setData( { name = TEST_playerName, cardId = TEST_playerCardId , allTimes = _fightAllTimes })
                UIManager.pushScene("ui_arena_fight")
            end
            if isWin then
                TEST_warWin = 1
            else
                TEST_warWin = 0
            end
            UIManager.showLoading()
            netSendPackage( { header = StaticMsgRule.arenaWarWin, msgdata = { int = { playerId = TEST_playerId, rank = TEST_rank, warWin = TEST_warWin }, string = { coredata = utils.fightVerifyData() } } }, netCallbackFunc, netErrorCallBack)
        end
        if _fightType == 2 then
            utils.sendFightData(nil, dp.FightType.FIGHT_ARENA, nil, callBackFunc1)
        elseif _fightType == 1 then
            utils.sendFightData(nil, dp.FightType.FIGHT_ARENA, callBackFunc)
            UIFightMain.loading()
        end
    elseif code == StaticMsgRule.arenaWarWin then
        UITeam.checkRecoverState()
        cclog("------------->>>  战斗胜利失败界面！！！！！！")
        local _flag = data.msgdata.int["1"]
        -- 0:不提示, 1:提示
        local _thingArray = data.msgdata.string["2"]
        --   cclog( " _fightType : ".._fightType.."  ".._currentRanking.."  ".._thingArray )
        if _fightType == 1 then
            UILootFight.setParam(dp.FightType.FIGHT_ARENA, { TEST_warWin, TEST_playerName, _flag, _thingArray, TEST_rank, _currentPrestige, _currentRanking, TEST_playerCardId })
            UIManager.pushScene("ui_loot_fight")
            if _flag ~= 1 then
                initArenaData()
            end
        elseif _fightType == 2 then
            UIManager.hideLoading()
            UIArenaFight.addItem( { TEST_warWin, TEST_playerName, _flag, _thingArray, TEST_rank, _currentPrestige, _currentRanking, TEST_playerCardId })
            if _fightTimes < _fightAllTimes then
                --   print( "sfsfs  : " .. TEST_warWin )
                if TEST_warWin == 1 and TEST_rank < _currentRanking then
                    --   cclog("333333333333333333")
                    TEST_rank, _currentRanking = _currentRanking, TEST_rank
                end
                UIArena.Widget:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create(
                function()
                    --   UIManager.showLoading()
                    netSendPackage( { header = StaticMsgRule.arenaWar, msgdata = { int = { playerId = TEST_playerId, rank = TEST_rank } } }, netCallbackFunc, netErrorCallBack)
                end
                )))
                if _flag ~= 1 then
                    initArenaData()
                end
            end
        end
    end
end

--- 连战菜单
local function showMenu( item , _cardData , instPlayerId , playerName , rank )
    local dialog = ccui.Layout:create()
    dialog:setContentSize(UIManager.screenSize)
    dialog:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    dialog:setBackGroundColor(cc.c3b(0, 0, 0))
    dialog:setBackGroundColorOpacity(130)
    dialog:setTouchEnabled(true)
    dialog:retain()
    local bg_image = cc.Scale9Sprite:create("ui/dialog_bg.png")
    bg_image:setAnchorPoint(cc.p(0.5, 0.5))
    bg_image:setPreferredSize(cc.size(331, 413))
    bg_image:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2))
    dialog:addChild(bg_image)
    local bgSize = bg_image:getPreferredSize()

    local image_di_l = ccui.ImageView:create()
    image_di_l:loadTexture("ui/lm_ditiao.png")
    image_di_l:setScaleX( -1 )
    image_di_l:setPosition( cc.p( 57 , 405 ) )
    bg_image:addChild(image_di_l)

    local image_di_r = ccui.ImageView:create()
    image_di_r:loadTexture("ui/lm_ditiao.png")
    image_di_r:setPosition( cc.p( 279 , 405 ) )
    bg_image:addChild(image_di_r)

    local _fontSize, _fontColor = 25, cc.c3b(255, 255, 255)
    local title = ccui.Text:create()
    title:setString(Lang.ui_arena6)
    title:setFontName(dp.FONT)
    title:setFontSize(30)
    title:enableGlow( cc.c3b(51 , 25 , 4 ) )
    title:setTextColor(cc.c3b(255, 255, 0))
    title:setPosition(cc.p(168, 407))
    bg_image:addChild(title)

    local cancelBtn = ccui.Button:create("ui/btn_x.png", "ui/btn_x.png")
    cancelBtn:setPressedActionEnabled(true)
    cancelBtn:setTouchEnabled(true)
    cancelBtn:setPosition(cc.p( 312 , 432 ) )
    bg_image:addChild(cancelBtn)

    local sureBtn = ccui.Button:create("ui/tk_btn_big_yellow.png", "ui/tk_btn_big_yellow.png")
    sureBtn:setTitleText(Lang.ui_arena7)
    sureBtn:setTitleFontName(dp.FONT)
    sureBtn:setTitleColor(cc.c3b(255, 255, 255))
    sureBtn:setTitleFontSize(35)
    sureBtn:setPressedActionEnabled(true)
    sureBtn:setTouchEnabled(true)
    sureBtn:setPosition(cc.p(165 , 311))
    bg_image:addChild(sureBtn)

    local sureBtn1 = ccui.Button:create("ui/tk_btn_big_yellow.png", "ui/tk_btn_big_yellow.png")
    sureBtn1:setTitleText(Lang.ui_arena8)
    sureBtn1:setTitleFontName(dp.FONT)
    sureBtn1:setTitleColor(cc.c3b(255, 255, 255))
    sureBtn1:setTitleFontSize(35)
    sureBtn1:setPressedActionEnabled(true)
    sureBtn1:setTouchEnabled(true)
    sureBtn1:setPosition(cc.p(165 , 207))
    bg_image:addChild(sureBtn1)

    local sureBtn2 = ccui.Button:create("ui/tk_btn_big_yellow.png", "ui/tk_btn_big_yellow.png")
    sureBtn2:setTitleText(Lang.ui_arena9)
    sureBtn2:setTitleFontName(dp.FONT)
    sureBtn2:setTitleColor(cc.c3b(255, 255, 255))
    sureBtn2:setTitleFontSize(35)
    sureBtn2:setPressedActionEnabled(true)
    sureBtn2:setTouchEnabled(true)
    sureBtn2:setPosition(cc.p(165 , 102))
    bg_image:addChild(sureBtn2)

    if net.InstPlayer.int["19"] < 3 then
        utils.GrayWidget( sureBtn , true )
    end
    if net.InstPlayer.int["19"] < 5 then
        utils.GrayWidget( sureBtn1 , true )
    end
    if net.InstPlayer.int["19"] < 10 then
        utils.GrayWidget( sureBtn2 , true )
    end
    
    local function fightTen( btnIndex )
        _fightAllTimes = 5 * btnIndex
        if net.InstPlayer.int["10"] < DictSysConfig[tostring(StaticSysConfig.lootVigor)].value * _fightAllTimes then
            -- UIManager.showToast("耐力不足！")
            utils.checkPlayerVigor()
            return
        else
            UIManager.uiLayer:removeChild(dialog, true)
            cc.release(dialog)
        end

        UIArenaHistory.enemyItem = item:clone()
        UIArenaHistory.enemyItem:retain()
        if net.InstPlayer.int["1"] == instPlayerId then
            UIManager.showToast(Lang.ui_arena10)
            return
        end
        
        _fightType = 2
        _fightTimes = 0
        TEST_playerName = playerName
        TEST_playerId = instPlayerId
        TEST_rank = rank
        if _cardData[1] then
            TEST_playerCardId = utils.stringSplit(_cardData[1], "_")[1]
        end
        UIManager.showLoading()
        netSendPackage( { header = StaticMsgRule.arenaWar, msgdata = { int = { playerId = instPlayerId, rank = rank } } }, netCallbackFunc)
    end
    
    local function btnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioEngine.playEffect("sound/button.mp3")
            
            if sender == sureBtn then
                if net.InstPlayer.int["19"] < 3 then
                    UIManager.showToast(Lang.ui_arena11)
                    return
                end
                fightTen( 1 )
            elseif sender == sureBtn1 then
                if net.InstPlayer.int["19"] < 5 then
                    UIManager.showToast(Lang.ui_arena12)
                    return
                end
                fightTen( 2 )
            elseif sender == sureBtn2 then
                if net.InstPlayer.int["19"] < 10 then
                    UIManager.showToast(Lang.ui_arena13)
                    return
                end
                fightTen( 3 )
            elseif sender == cancelBtn then
                UIManager.uiLayer:removeChild(dialog, true)
                cc.release(dialog)
            end
        end
    end
    sureBtn:addTouchEventListener(btnEvent)
    sureBtn1:addTouchEventListener(btnEvent)
    sureBtn2:addTouchEventListener(btnEvent)
    cancelBtn:addTouchEventListener(btnEvent)

    bg_image:setScale(0.1)
    UIManager.uiLayer:addChild(dialog, 10000)
    bg_image:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.1), cc.ScaleTo:create(0.06, 1)))
end

local function setScrollViewItem1(item, data)
    local rank = data.int["1"]
    -- 排名
    local instPlayerId = data.int["2"]
    -- 玩家实例ID
    local playerLv = data.int["3"]
    -- 玩家等级
    local playerName = data.string["4"]
    -- 玩家名字
    local cards = data.string["5"]
    -- 卡牌
    local gold = data.int["6"]
    -- 获得元宝
    local prestige = data.int["7"]
    -- 获得威望

    local item_image_lv = item:getChildByName("image_lv")
    local item_lv = item_image_lv:getChildByName("text_lv")
    local item_name = item_image_lv:getChildByName("text_player_name")
    local item_ranking = item:getChildByName("label_ranking")
    local item_btn = item:getChildByName("btn_challenge")
    local btn_ten = item:getChildByName("btn_ten")
    local item_baseCard = item:getChildByName("image_base_card")
    local item_gold = ccui.Helper:seekNodeByName(item, "text_gold_number")
    local item_prestige = ccui.Helper:seekNodeByName(item, "text_weiwang")
    local item_countdown = item:getChildByName("text_countdown")
    local item_countdownTime = item_countdown:getChildByName("text_countdown_time")

    item_lv:setString(playerLv .. Lang.ui_arena14)
    item_name:setString(playerName)
    item_ranking:setString(tostring(rank))
    item_gold:setString(tostring(gold))
    item_prestige:setString(tostring(prestige))
    local _cardData = utils.stringSplit(cards, ";")

    for i = 1, 4 do
        local cardFrame = item_baseCard:getChildByName("image_frame_card" .. i)
        if _cardData[i] then
            local _tempCardData = utils.stringSplit(_cardData[i], "_")
            local cardIcon = cardFrame:getChildByName("image_card" .. i)
            cardFrame:loadTexture(utils.getQualityImage(dp.Quality.card, _tempCardData[2], dp.QualityImageType.small))
            local isAwake = _tempCardData[3]
            cardIcon:loadTexture("image/" .. DictUI[tostring(isAwake == "1" and DictCard[tostring(_tempCardData[1])].awakeSmallUiId or DictCard[tostring(_tempCardData[1])].smallUiId)].fileName)

        else
            cardFrame:setVisible(false)
        end
    end

    if _prevLabelBtn == btn_Challenge and net.InstPlayer.int["1"] == instPlayerId then
        ui_awardTime = item_countdownTime
        item_lv:setTextColor(cc.c4b(0, 255, 234, 255))
        item_name:setTextColor(cc.c4b(255, 240, 136, 255))
        item_gold:setTextColor(cc.c4b(255, 255, 0, 255))
        item_prestige:setTextColor(cc.c4b(255, 255, 0, 255))
        ccui.Helper:seekNodeByName(item, "text_award"):setTextColor(cc.c4b(0, 0, 0, 255))
        item_image_lv:loadTexture("ui/jjc_di04.png")
        item_baseCard:loadTexture("ui/jjc_di03.png")
        item_ranking:setFntFile("ui/jjc_zi01.fnt")
        item_ranking:setString(tostring(rank))
        if rank >= 1000 then
            item_ranking:setScale(0.7)
        else
            item_ranking:setScale(1)
        end
        item:loadTexture("ui/jjc_di01.png")
        item_btn:setTouchEnabled(false)
        item_btn:setVisible(false)
        btn_ten:setVisible(false)
        item_countdown:setVisible(true)
        if not tolua.isnull(UIArenaHistory.selfItem) then
            -- UIArenaHistory.selfItem:removeFromParent()
            UIArenaHistory.selfItem:release()
            UIArenaHistory.selfItem = nil
        end
        UIArenaHistory.selfItem = item:clone()
        UIArenaHistory.selfItem:retain()
    else
        if _prevLabelBtn == btn_Challenge then
            item_btn:loadTextures("ui/yh_sq_btn01.png", "ui/yh_sq_btn01.png")
            item_btn:setTitleText(Lang.ui_arena15)
            btn_ten:setVisible(true)
            btn_ten:setTitleText(Lang.ui_arena16)
            if net.InstPlayer.int["4"] < 20 or net.InstPlayer.int["19"] < 3 then
                utils.GrayWidget( btn_ten , true )
            else
                utils.GrayWidget( btn_ten , false )
            end
        elseif _prevLabelBtn == btn_Ranking then
            item_btn:loadTextures("ui/tk_btn01.png", "ui/tk_btn01.png")
            item_btn:setTitleText(Lang.ui_arena17)
            btn_ten:setVisible(false)
        end
        local function onItemBtnEvent(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if _prevLabelBtn == btn_Challenge then
                    AudioEngine.playEffect("sound/fight.mp3")
                    if net.InstPlayer.int["1"] == instPlayerId then
                        UIManager.showToast(Lang.ui_arena18)
                        return
                    end
                    if sender == item_btn then
                        UIArenaHistory.enemyItem = item:clone()
                        UIArenaHistory.enemyItem:retain()
                        -- UIManager.pushScene("ui_arena_history")
                        if net.InstPlayer.int["10"] < DictSysConfig[tostring(StaticSysConfig.lootVigor)].value then
                            -- UIManager.showToast("耐力不足！")
                            utils.checkPlayerVigor()
                            return
                        end
                        _fightType = 1
                        TEST_playerName = playerName
                        TEST_playerId = instPlayerId
                        TEST_rank = rank
                        if _cardData[1] then
                            TEST_playerCardId = utils.stringSplit(_cardData[1], "_")[1]
                        end
                        UIManager.showLoading()
                        netSendPackage( { header = StaticMsgRule.arenaWar, msgdata = { int = { playerId = instPlayerId, rank = rank } } }, netCallbackFunc)
                    elseif sender == btn_ten then

                        if net.InstPlayer.int["4"] < 20 then
                            UIManager.showToast(Lang.ui_arena19)
                            return
                        end
                        if net.InstPlayer.int["19"] < 3 then
                            UIManager.showToast(Lang.ui_arena20)
                            return
                        end
                        showMenu( item , _cardData , instPlayerId , playerName , rank )
                    end
                elseif _prevLabelBtn == btn_Ranking then
                    UIManager.showLoading()
                    UIArenaCheck.playerId = instPlayerId
                    netSendPackage( { header = StaticMsgRule.enemyPlayerInfo, msgdata = { int = { playerId = instPlayerId } } }, netCallbackFunc)
                end
            end
        end
        item_btn:setPressedActionEnabled(true)
        item_btn:addTouchEventListener(onItemBtnEvent)
        btn_ten:setPressedActionEnabled(true)
        btn_ten:addTouchEventListener(onItemBtnEvent)
    end
end

local function setScrollViewItem2(item, data)
    local item_name = ccui.Helper:seekNodeByName(item, "text_name_prop")
    local item_exchangeNum = ccui.Helper:seekNodeByName(item, "text_quota")
    local item_frame = ccui.Helper:seekNodeByName(item, "image_frame_prop")
    local item_icon = item_frame:getChildByName("image_prop")
    local item_type = item_frame:getChildByName("image_hun")
    local item_describe = ccui.Helper:seekNodeByName(item, "text_prop_describe")
    local item_prestige = ccui.Helper:seekNodeByName(item, "text_weiwang")
    local item_btn = item:getChildByName("btn_buy")
    item_type:setVisible(false)

    if data.tableTypeId == StaticTableType.DictPill then
        local dictPill = DictPill[tostring(data.tableFieldId)]
        item_name:setString(dictPill.name)
        item_describe:setString(dictPill.description)
        item_frame:loadTexture("ui/quality_small_purple.png")
        item_icon:loadTexture("image/" .. DictUI[tostring(dictPill.smallUiId)].fileName)
    elseif data.tableTypeId == StaticTableType.DictThing then
        local dictThing = DictThing[tostring(data.tableFieldId)]
        item_name:setString(dictThing.name)
        item_describe:setString(dictThing.description)
        item_icon:loadTexture(utils.getThingImage(data.tableFieldId, false))
        if dictThing.id >= 200 and dictThing.id < 300 then
            item_type:setVisible(true)
            item_type:loadTexture("ui/suipian.png")
            local tempData = DictEquipment[tostring(dictThing.equipmentId)]
            item_frame:loadTexture(utils.getQualityImage(dp.Quality.equip, tempData.equipQualityId, dp.QualityImageType.small))
        end
    elseif data.tableTypeId == StaticTableType.DictPlayerBaseProp then
        local dictPlayerBaseProp = DictPlayerBaseProp[tostring(data.tableFieldId)]
        item_name:setString(dictPlayerBaseProp.name)
        item_describe:setString(dictPlayerBaseProp.description)
        item_icon:loadTexture("image/" .. DictUI[tostring(dictPlayerBaseProp.smallUiId)].fileName)
    elseif data.tableTypeId == StaticTableType.DictEquipment then
        local dictEquipment = DictEquipment[tostring(data.tableFieldId)]
        item_name:setString(dictEquipment.name)
        item_describe:setString(dictEquipment.description)
        item_frame:loadTexture(utils.getQualityImage(dp.Quality.equip, dictEquipment.equipQualityId, dp.QualityImageType.small))
        item_icon:loadTexture("image/" .. DictUI[tostring(dictEquipment.smallUiId)].fileName)
    elseif data.tableTypeId == StaticTableType.DictCard then
        local dictCard = DictCard[tostring(data.tableFieldId)]
        item_name:setString(dictCard.name)
        item_describe:setString(dictCard.description)
        item_frame:loadTexture(utils.getQualityImage(dp.Quality.card, dictCard.qualityId, dp.QualityImageType.small))
        item_icon:loadTexture("image/" .. DictUI[tostring(dictCard.smallUiId)].fileName)
    elseif data.tableTypeId == StaticTableType.DictCardSoul then
        item_type:setVisible(true)
        item_type:loadTexture("ui/hun.png")
        local dictCardSoul = DictCardSoul[tostring(data.tableFieldId)]
        item_name:setString(dictCardSoul.name)
        item_describe:setString(dictCardSoul.description)
        local dictCard = DictCard[tostring(dictCardSoul.cardId)]
        item_frame:loadTexture(utils.getQualityImage(dp.Quality.card, dictCard.qualityId, dp.QualityImageType.small))
        item_icon:loadTexture("image/" .. DictUI[tostring(dictCard.smallUiId)].fileName)
    elseif data.tableTypeId == StaticTableType.DictChip then
        item_type:setVisible(true)
        item_type:loadTexture("ui/suipian.png")
        local dictChip = DictChip[tostring(data.tableFieldId)]
        item_name:setString(dictChip.name)
        item_describe:setString(dictChip.description)
        item_icon:loadTexture("image/" .. DictUI[tostring(DictMagic[tostring(dictChip.skillOrKungFuId)].smallUiId)].fileName)
    end
    item_name:setString(item_name:getString() .. "x" .. data.value)
    item_icon:setPosition(cc.p(item_frame:getContentSize().width / 2, item_frame:getContentSize().height / 2))

    -- zy 竞技场兑换  查看详细
    utils.showThingsInfo(item_icon, data.tableTypeId, data.tableFieldId)

    local _exchangeNum, _tempExchangeData = data.convertNum, { }
    for _dataK, _dataO in pairs(data) do
        _tempExchangeData[_dataK] = _dataO
    end
    if net.InstPlayerArenaConvert then
        for ipacKey, ipacObj in pairs(net.InstPlayerArenaConvert) do
            if data.id == ipacObj.int["3"] then
                _exchangeNum = data.convertNum - ipacObj.int["4"]
                _tempExchangeData.convertNum = _exchangeNum
                break
            end
        end
    end
    if data.convertType == 1 then
        item_exchangeNum:setString(Lang.ui_arena21 .. data.convertNum .. Lang.ui_arena22)
    else
        item_exchangeNum:setString(Lang.ui_arena23 .. _exchangeNum .. Lang.ui_arena24)
    end
    item_prestige:setString(tostring(data.prestige))

    local function onItemBtnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if data.convertType == 1 and _exchangeNum == 0 then
                UIManager.showToast(Lang.ui_arena25)
            elseif data.convertType == 2 and _exchangeNum == 0 then
                UIManager.showToast(Lang.ui_arena26)
            else
                UISellProp.setData(_tempExchangeData, UIArena)
                UIManager.pushScene("ui_sell_prop")
            end
        end
    end
    if (data.convertType == 1 and _exchangeNum == 0) or(data.convertType == 2 and _exchangeNum == 0) then
        item_btn:setBright(false)
    end

    item_btn:setPressedActionEnabled(true)
    item_btn:addTouchEventListener(onItemBtnEvent)
end

function initScrollView()
    ui_awardTime = nil
    if sv_item1:getReferenceCount() == 1 then
        sv_item1:retain()
    end
    if sv_item2:getReferenceCount() == 1 then
        sv_item2:retain()
    end
    ui_scrollView:removeAllChildren()

    local innerHeight, space = 0, 10
    for key, obj in pairs(_listData) do
        local scrollViewItem = nil
        if _prevLabelBtn == btn_Exchange then
            scrollViewItem = sv_item2:clone()
            setScrollViewItem2(scrollViewItem, obj)
        else
            scrollViewItem = sv_item1:clone()
            setScrollViewItem1(scrollViewItem, obj)
        end
        ui_scrollView:addChild(scrollViewItem)
        innerHeight = innerHeight + scrollViewItem:getContentSize().height + space
    end

    innerHeight = innerHeight + space
    if innerHeight < ui_scrollView:getContentSize().height then
        innerHeight = ui_scrollView:getContentSize().height
    end
    ui_scrollView:setInnerContainerSize(cc.size(ui_scrollView:getContentSize().width, innerHeight))
    local childs = ui_scrollView:getChildren()
    local prevChild = nil
    for i = 1, #childs do
        if i == 1 then
            childs[i]:setPosition(cc.p(ui_scrollView:getContentSize().width / 2, ui_scrollView:getInnerContainerSize().height - childs[i]:getContentSize().height / 2 - space))
        else
            childs[i]:setPosition(cc.p(ui_scrollView:getContentSize().width / 2, prevChild:getBottomBoundary() - childs[i]:getContentSize().height / 2 - space))
        end
        prevChild = childs[i]
    end
    if not UIArena.isFlush then
        ActionManager.ScrollView_SplashAction(ui_scrollView)
    end
end

local function setTopButtonLabel(sender)
    if _prevLabelBtn ~= sender then
        _prevLabelBtn = sender
        btn_Challenge:loadTextureNormal("ui/yh_btn01.png")
        btn_Challenge:getChildByName("text_label_name"):setTextColor(cc.c4b(255, 255, 255, 255))
        btn_Ranking:loadTextureNormal("ui/yh_btn01.png")
        btn_Ranking:getChildByName("text_label_name"):setTextColor(cc.c4b(255, 255, 255, 255))
        btn_Exchange:loadTextureNormal("ui/yh_btn01.png")
        btn_Exchange:getChildByName("text_label_name"):setTextColor(cc.c4b(255, 255, 255, 255))
        sender:loadTextureNormal("ui/yh_btn02.png")
        sender:getChildByName("text_label_name"):setTextColor(cc.c4b(51, 25, 4, 255))
        local function setChallengeText(enabled)
            ui_textRanking:setVisible(enabled)
            ui_textWeiwang:setVisible(enabled)
            ui_imageWeiwang:setVisible(enabled)
            ui_textWeiwangNum:setVisible(enabled)
            ui_textChallengeNum:setVisible(enabled)
            ui_textWait:setVisible(enabled)
            ui_textWaitTime:setVisible(enabled)
            ui_imageStamina:setVisible(enabled)
            image_weiwangExchange:setVisible(not enabled)
            if sender == btn_Challenge then
                ui_textWait:setVisible(not enabled)
                ui_textWaitTime:setVisible(not enabled)
            elseif sender == btn_Ranking then
                ui_imageStamina:setVisible(not enabled)
            end
        end
        if sender == btn_Challenge then
            setChallengeText(true)
            ui_textChallengeNum:setString(TEXT_3)
            -- ui_textWaitTime:setPositionX(ui_textWait:getRightBoundary())
        elseif sender == btn_Ranking then
            setChallengeText(true)
            ui_textChallengeNum:setString(TEXT_3)
            ui_textWait:setString(TEXT_4)
            ui_textWaitTime:setPositionX(ui_textWait:getRightBoundary())
        elseif sender == btn_Exchange then
            setChallengeText(false)
        end
        _listData = { }
        if sender == btn_Exchange then
            -- _listData = DictArenaConvert
            for key, obj in pairs(DictArenaConvert) do
                _listData[#_listData + 1] = obj
            end
            utils.quickSort(_listData, function(obj1, obj2) if obj1.rank > obj2.rank then return true end end)
            initScrollView()
        else
            UIManager.showLoading()
            initScrollView()
            if sender == btn_Challenge then
                netSendPackage( { header = StaticMsgRule.arena, msgdata = { } }, netCallbackFunc)
            elseif sender == btn_Ranking then
                netSendPackage( { header = StaticMsgRule.arenaList, msgdata = { } }, netCallbackFunc)
            end
        end
    end
end

function UIArena.init()
    local image_base_title = ccui.Helper:seekNodeByName(UIArena.Widget, "image_base_title")
    ui_teamFight = ccui.Helper:seekNodeByName(image_base_title, "label_fight")
    ui_teamGold = ccui.Helper:seekNodeByName(image_base_title, "text_gold_number")
    ui_teamMoney = ccui.Helper:seekNodeByName(image_base_title, "text_silver_number")
    btn_Challenge = ccui.Helper:seekNodeByName(image_base_title, "btn_challenge")
    btn_Ranking = ccui.Helper:seekNodeByName(image_base_title, "btn_ranking")
    btn_Exchange = ccui.Helper:seekNodeByName(image_base_title, "btn_exchange")

    ui_textRanking = image_base_title:getChildByName("text_ranking")
    ui_textWeiwang = image_base_title:getChildByName("text_weiwang")
    ui_imageWeiwang = image_base_title:getChildByName("image_weiwang")
    ui_textWeiwangNum = image_base_title:getChildByName("text_weiwang_number")
    ui_textChallengeNum = image_base_title:getChildByName("text_challenge_number")
    ui_imageStamina = image_base_title:getChildByName("image_stamina")
    ui_textWait = image_base_title:getChildByName("text_wait")
    ui_textWaitTime = image_base_title:getChildByName("text_wait_time")
    image_weiwangExchange = image_base_title:getChildByName("image_weiwang_exchange")

    local btn_embattle = image_base_title:getChildByName("btn_embattle")
    local btn_back = image_base_title:getChildByName("btn_back")
    -- 返回按钮
    btn_back:setPressedActionEnabled(true)
    local function onBtnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_back then
                if UIArena.isFromMain then
                    UIArena.isFromMain = false
                    UIMenu.onHomepage()
                else
                    -- UIMenu.onActivity()
                    UIMenu.onHomepage()
                end
            elseif sender == btn_embattle then
                if net.InstPlayer.int["4"] >= DictFunctionOpen[ tostring( StaticFunctionOpen.partner ) ].level then
                    UIManager.pushScene("ui_lineup_embattle")
                else
                    UIManager.pushScene("ui_lineup_embattle_old")
                end
            else
                setTopButtonLabel(sender)
            end
        end
    end
    btn_back:addTouchEventListener(onBtnEvent)
    btn_embattle:addTouchEventListener(onBtnEvent)
    btn_Challenge:addTouchEventListener(onBtnEvent)
    btn_Ranking:addTouchEventListener(onBtnEvent)
    btn_Exchange:addTouchEventListener(onBtnEvent)

    ui_scrollView = ccui.Helper:seekNodeByName(UIArena.Widget, "view_list")
    sv_item1 = ui_scrollView:getChildByName("image_base_player"):clone()
    sv_item2 = ui_scrollView:getChildByName("image_base_prop"):clone()
end

local function getFlagTime()
    local _curTime = utils.getCurrentTime()
    local _date = os.date("*t", _curTime)
    local function isleapyear(y)
        return(y % 4 == 0 and y % 100 or y % 400 == 0)
    end
    local md = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    if isleapyear(_date.year) then
        md[2] = 29
    end
    local newYear, newMonth, newDay = _date.year, _date.month, _date.day + 1
    if newDay > md[newMonth] then
        newMonth = newMonth + 1
        newDay = 1
        if newMonth > #md then
            newMonth = 1
            newYear = newYear + 1
        end
    end
    local newHour = DictSysConfig[tostring(StaticSysConfig.arenaAwardTime)].value
    return os.time( { year = newYear, month = newMonth, day = newDay, hour = newHour, min = 0, sec = 0 })
end

function UIArena.setup()
    ui_awardTime = nil
    _prevLabelBtn = nil
    if sv_item1:getReferenceCount() == 1 then
        sv_item1:retain()
    end
    if sv_item2:getReferenceCount() == 1 then
        sv_item2:retain()
    end
    ui_scrollView:removeAllChildren()

    ui_teamFight:setString(tostring(utils.getFightValue()))
    ui_teamGold:setString(tostring(net.InstPlayer.int["5"]))
    ui_teamMoney:setString(net.InstPlayer.string["6"])

    local _time = 0
    local _flagTime = getFlagTime()
    local _curTime = utils.getCurrentTime()
    if _curTime > _flagTime then
        _time = 24 * 60 * 60 - _curTime + _flagTime
    elseif _curTime < _flagTime then
        _time = _flagTime - _curTime
    end
    startAwardTimer(_time)

    initArenaData()
    if UIArena.showExchangeFirst then   
        UIArena.showExchangeFirst = nil
        setTopButtonLabel(btn_Exchange)
    else
        setTopButtonLabel(btn_Challenge)
    end
end

function UIArena.flushVigor()
    ui_teamFight:setString(tostring(utils.getFightValue()))
    ui_teamGold:setString(tostring(net.InstPlayer.int["5"]))
    ui_teamMoney:setString(net.InstPlayer.string["6"])
    initArenaData()
end

function UIArena.refreshExchangeList()
    _prevLabelBtn = nil
    if sv_item1:getReferenceCount() == 1 then
        sv_item1:retain()
    end
    if sv_item2:getReferenceCount() == 1 then
        sv_item2:retain()
    end
    UIArena.isFlush = true
    ui_scrollView:removeAllChildren()
    initArenaData()
    setTopButtonLabel(btn_Exchange)
end

function UIArena.free()
    _prevLabelBtn = nil
    _awardTime = 0
    _msg = nil
    --  _fightType = nil
    _fightTimes = nil
end

function UIArena.updateTimer(interval)
    if _awardTime then
        _awardTime = _awardTime - interval
        if _awardTime < 0 then
            _awardTime = 0
        end
    end
end

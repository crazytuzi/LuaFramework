require"Lang"
UILootFight = { }
local screenHeight = cc.Director:getInstance():getVisibleSize().height
local animalHeight = 0 
if screenHeight == 1136 then
    animalHeight = 920
elseif screenHeight == 960 then
    animalHeight = 840
end
local btn_again = nil -- 再抢一次按钮
local btn_report = nil -- 发送胜利战报按钮
local btn_sure = nil -- 确定按钮
local btn_replay = nil -- 重播按钮


local _fightType = nil -- 战斗类型
local _customParam = nil -- 自定义参数

local DropThing = { }
local param = nil
local ui_frameChoose = { }
UILootFight.replay = false

local function buttonEnabled(Enable)
    btn_replay:setEnabled(Enable)
    btn_replay:setBright(Enable)
    btn_sure:setEnabled(Enable)
    btn_sure:setBright(Enable)
    btn_report:setVisible(Enable)
    btn_again:setEnabled(Enable)
    btn_again:setBright(Enable)
end

-- flag 1 胜利 2 失败
local function addAnimal(flag)
    local armature = nil
    if flag == 1 then
        local function FrameEventCallFunc(bone, eventName, originFrameIndex, currentFrameIndex)
            if eventName == "guang" then
                cc.SpriteFrameCache:getInstance():addSpriteFrames("ani/ui_anim/ui_anim10/ui_anim10.md")
                local image = ccui.ImageView:create("shop_07.png", ccui.TextureResType.plistType)
                image:setPosition(cc.p(325, animalHeight + 10))
                image:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, 180)))
                image:setScale(2.5)
                UILootFight.Widget:addChild(image, 0, 101)
                UILootFight.Widget:getChildByName("image_basemap"):setEnabled(true)
            end
        end
        armature = ActionManager.getUIAnimation(11)
        armature:getAnimation():setFrameEventCallFunc(FrameEventCallFunc)
        armature:setPosition(cc.p(320, animalHeight))
    else
        armature = ActionManager.getUIAnimation(12)
        armature:setPosition(cc.p(320, animalHeight + 10))
    end
    UILootFight.Widget:addChild(armature, 100, 100)
end

function UILootFight.init()
    btn_sure = ccui.Helper:seekNodeByName(UILootFight.Widget, "btn_sure")
    btn_replay = ccui.Helper:seekNodeByName(UILootFight.Widget, "btn_rerun")
    btn_again = ccui.Helper:seekNodeByName(UILootFight.Widget, "btn_again")
    btn_report = ccui.Helper:seekNodeByName(UILootFight.Widget, "btn_report")
    local ui_image_recruit = ccui.Helper:seekNodeByName(UILootFight.Widget, "image_recruit")
    local ui_image_card = ccui.Helper:seekNodeByName(UILootFight.Widget, "image_card")
    local ui_image_equipment = ccui.Helper:seekNodeByName(UILootFight.Widget, "image_equipment")
    local ui_image_lineup = ccui.Helper:seekNodeByName(UILootFight.Widget, "image_lineup")
    local ui_selectedFrame = ccui.Helper:seekNodeByName(UILootFight.Widget,"image_selected_frame")
    utils.addParticleEffect(ui_selectedFrame, true, {anchorSize = 16, offset = 10})
    for i = 1, 3 do
        ui_frameChoose[i] = ccui.Helper:seekNodeByName(UILootFight.Widget, "image_good" .. i)
        ui_frameChoose[i]:setTouchEnabled(true)
    end
    btn_sure:setPressedActionEnabled(true)
    btn_replay:setPressedActionEnabled(true)
    btn_again:setPressedActionEnabled(true)
    btn_report:setPressedActionEnabled(true)
    local function onBtnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_again then
                if _fightType ~= dp.FightType.FIGHT_ARENA and next(DropThing) and StaticTableType.DictChip == DropThing[1][1] and tonumber(DropThing[1][2]) == tonumber(UILootChoose.warParam[2]) then
                    UIManager.showToast(Lang.ui_loot_fight1)
                    return
                end
                if net.InstPlayer.int["10"] >= DictSysConfig[tostring(StaticSysConfig.lootVigor)].value then
                    UIManager.popScene()
                    UILootChoose.warParam[5] = function()
                        if _customParam and _customParam[2] ~= nil then
                            UILoot.isFlush = true
                            UIManager.showScreen("ui_notice", "ui_loot", "ui_menu")
                        else
                            UIManager.showScreen("ui_notice", "ui_loot_choose", "ui_menu")
                        end
                    end
                    UILootChoose.sendlootWarData(UILootChoose.warParam)
                else
                    -- UIManager.showToast("耐力不足")
                    utils.checkPlayerVigor()
                end
            elseif sender == btn_sure then
                if _fightType == dp.FightType.FIGHT_ARENA then
                    local isWin = _customParam[1]
                    -- 0-失败 1-胜利
                    local _flag = _customParam[3]
                    -- 0:不提示, 1:提示
                    local _rank = _customParam[5]
                    -- 排名
                    local _weiwang = net.InstPlayer.int["39"] - _customParam[6]
                    -- 获得威望
                    local _selfRank = _customParam[7]
                    -- 自己的排名
                    if _flag == 1 then
                        UIArena.updateRanking()
                    elseif isWin == 1 then
                        UIArena.free()
                        ------######为了测试调用
                        UIArena.setup()
                        if _rank >= _selfRank then
                            UIArena.showToast(Lang.ui_loot_fight2 .. _weiwang .. Lang.ui_loot_fight3)
                        else
                            -- UIArena.showToast("您的排名上升至".._rank.."名！\n获得".._weiwang.."威望。")
                            UIArena.showToast( { _rank, _weiwang })
                        end
                    elseif isWin == 0 then
                        UIArena.showToast(Lang.ui_loot_fight4 .. _weiwang .. Lang.ui_loot_fight5)
                    end
                    UIManager.showScreen("ui_notice", "ui_arena", "ui_menu")
                else
                    if _customParam and _customParam[2] ~= nil then
                        UILoot.isFlush = true
                        UIManager.showScreen("ui_notice", "ui_loot", "ui_menu")
                    else
                        UIManager.showScreen("ui_notice", "ui_loot_choose", "ui_menu")
                    end
                end
                AudioEngine.playMusic("sound/bg_music.mp3", true)
            elseif sender == btn_replay then
                --- 重播 暂时不做
                UIManager.showToast(Lang.ui_loot_fight6)
                -- 			UILootFight.replay =true
                -- 			UIManager.popScene()
                -- 			Fight.doFight()
            elseif sender == btn_report then
                --- 发送胜利战报 暂时不做
                UIManager.showToast(Lang.ui_loot_fight7)
            elseif sender == ui_image_recruit then
                -- 强者修炼
                local openLv = DictFunctionOpen[tostring(StaticFunctionOpen.state)].level
                if net.InstPlayer.int["4"] < openLv then
                    UIManager.showToast(Lang.ui_loot_fight8 .. openLv .. Lang.ui_loot_fight9)
                else
                    UIManager.showScreen("ui_notice", "ui_lineup", "ui_menu")
                    AudioEngine.playMusic("sound/bg_music.mp3", true)
                end
            elseif sender == ui_image_lineup then
                -- 调整阵容
                if _fightType == dp.FightType.FIGHT_ARENA then
                    UIManager.showScreen("ui_notice", "ui_arena", "ui_menu")
                else
                    UIManager.showScreen("ui_notice", "ui_loot_choose", "ui_menu")
                end
                if net.InstPlayer.int["4"] >= DictFunctionOpen[ tostring( StaticFunctionOpen.partner ) ].level then
                    UIManager.pushScene("ui_lineup_embattle")
                else
                    UIManager.pushScene("ui_lineup_embattle_old")
                end
                AudioEngine.playMusic("sound/bg_music.mp3", true)
            elseif sender == ui_image_card then
                -- 强者升级
                UIManager.showScreen("ui_notice", "ui_team_info", "ui_bag_card", "ui_menu")
                AudioEngine.playMusic("sound/bg_music.mp3", true)
            elseif sender == ui_image_equipment then
                -- 装备强化
                UIManager.showScreen("ui_notice", "ui_team_info", "ui_bag_equipment", "ui_menu")
                AudioEngine.playMusic("sound/bg_music.mp3", true)
            else
                local _tempI = 1
                local ui_selectedFrame = ccui.Helper:seekNodeByName(UILootFight.Widget, "image_selected_frame")
                for key, obj in pairs(ui_frameChoose) do
                    obj:stopAllActions()
                    obj:setVisible(false)
                    ui_selectedFrame:setVisible(true)
                    local image_frame = ccui.Helper:seekNodeByName(UILootFight.Widget, "image_frame_good" .. key)
                    local ui_image_shadow = ccui.Helper:seekNodeByName(UILootFight.Widget, "image_good" .. key .. "_shadow")
                    ui_image_shadow:setVisible(false)
                    image_frame:setVisible(true)
                    local _tableTypeId, _tableFieldId = nil, nil
                    if sender == obj then
                        ui_selectedFrame:setPosition(image_frame:getPosition())
                        _tableTypeId, _tableFieldId = DropThing[1][1], DropThing[1][2]
                    else
                        _tempI = _tempI + 1
                        _tableTypeId, _tableFieldId = DropThing[_tempI][1], DropThing[_tempI][2]
                    end
                    local thingName, thingIcon = utils.getDropThing(_tableTypeId, _tableFieldId)
                    image_frame:getChildByName("image_good"):loadTexture(thingIcon)
                    image_frame:getChildByName("text_name"):setString(thingName)
                    utils.addBorderImage(_tableTypeId, _tableFieldId, image_frame)
                end
                buttonEnabled(true)
                UIGuidePeople.isGuide(btn_sure, UILootFight)
            end
        end
    end
    btn_sure:addTouchEventListener(onBtnEvent)
    btn_replay:addTouchEventListener(onBtnEvent)
    btn_again:addTouchEventListener(onBtnEvent)
    btn_report:addTouchEventListener(onBtnEvent)
    ui_image_recruit:addTouchEventListener(onBtnEvent)
    ui_image_lineup:addTouchEventListener(onBtnEvent)
    ui_image_card:addTouchEventListener(onBtnEvent)
    ui_image_equipment:addTouchEventListener(onBtnEvent)
    for key, obj in pairs(ui_frameChoose) do
        obj:addTouchEventListener(onBtnEvent)
    end
end

function UILootFight.setup()
    local ui_frame_player = ccui.Helper:seekNodeByName(UILootFight.Widget, "image_frame_player")
    local ui_frame_player_rival = ccui.Helper:seekNodeByName(UILootFight.Widget, "image_frame_player_rival")
    local ui_selfName = ui_frame_player:getChildByName("image_base_name"):getChildByName("text_name")
    local ui_selfIcon = ui_frame_player:getChildByName("image_player")
    local ui_selfFight = ui_frame_player:getChildByName("image_fight"):getChildByName("label_fight")
    local ui_playerName = ui_frame_player_rival:getChildByName("image_base_name_rival"):getChildByName("text_name_rival")
    local ui_playerIcon = ui_frame_player_rival:getChildByName("image_player")
    local ui_playerFight = ui_frame_player_rival:getChildByName("image_fight"):getChildByName("label_fight")
    local ui_hint = UILootFight.Widget:getChildByName("image_basemap"):getChildByName("text_hint")
    local ui_base_get = ccui.Helper:seekNodeByName(UILootFight.Widget, "image_base_get")
    local ui_silver = ui_base_get:getChildByName("text_silver")
    local ui_exp = ui_base_get:getChildByName("text_exp")
    local ui_endurance = ui_base_get:getChildByName("text_endurance")
    local ui_base_win = ccui.Helper:seekNodeByName(UILootFight.Widget, "image_base_win")
    local ui_base_fail = ccui.Helper:seekNodeByName(UILootFight.Widget, "image_base_fail")
    local ui_selectedFrame = ccui.Helper:seekNodeByName(UILootFight.Widget, "image_selected_frame")

    ui_selectedFrame:setVisible(false)
    DropThing = { }
    ui_selfFight:setString(utils.getFightValue())
    ui_selfName:setString(net.InstPlayer.string["3"])
    local dictCard = DictCard[tostring(net.InstPlayer.int["32"])]
    if dictCard then
        ui_selfIcon:loadTexture("image/" .. DictUI[tostring(dictCard.smallUiId)].fileName)
    end
    if not UILootFight.replay then
        for i = 1, 3 do
            local ui_image_shadow = ccui.Helper:seekNodeByName(UILootFight.Widget, "image_good" .. i .. "_shadow")
            ui_frameChoose[i]:setVisible(true)
            ui_image_shadow:setVisible(true)
            local t = math.random(10, 14) / 100
            ui_frameChoose[i]:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.RotateTo:create(t, 5), cc.RotateBy:create(t, -5))))
            ccui.Helper:seekNodeByName(UILootFight.Widget, "image_frame_good" .. i):setVisible(false)
        end
    end
    if _fightType == dp.FightType.FIGHT_ARENA then
        local isWin = _customParam[1]
        -- 0-失败 1-胜利
        local playerName = _customParam[2]
        -- 挑战玩家名称
        local _flag = _customParam[3]
        -- 0:不提示, 1:提示
        local thingArray = _customParam[4]
        local cardId = _customParam[8]
        if cardId then
            local dictCard = DictCard[tostring(cardId)]
            if dictCard then
                ui_playerIcon:loadTexture("image/" .. DictUI[tostring(dictCard.smallUiId)].fileName)
            end
        end
        ui_playerFight:setString(pvp.getFightValue())
        ui_hint:setVisible(true)
        local _weiwangValue = 0
        if isWin == 1 then
            ui_hint:setString(Lang.ui_loot_fight10)
            addAnimal(1)
            ui_base_fail:setVisible(false)
            ui_base_win:setVisible(true)
            if UILootFight.replay == false then
                buttonEnabled(false)
            end
            _weiwangValue = net.InstPlayer.int["39"] - _customParam[6]
        else
            addAnimal(2)
            ui_hint:setString(Lang.ui_loot_fight11)
            ui_base_fail:setVisible(true)
            ui_base_win:setVisible(false)
            buttonEnabled(true)
            _weiwangValue = net.InstPlayer.int["39"] - _customParam[6]
        end
        btn_again:setVisible(false)
        ui_endurance:setVisible(false)

        local _dlpData = DictLevelProp[tostring(net.InstPlayer.int["4"])]
        ui_exp:setString(Lang.ui_loot_fight12 .. _weiwangValue)
        ui_silver:setString(Lang.ui_loot_fight13 .. _dlpData.duelFleetCopper)

        ui_playerName:setString(playerName)
        if thingArray then
            local things = utils.stringSplit(thingArray, ";")
            for _key, _obj in pairs(things) do
                DropThing[_key] = utils.stringSplit(_obj, "_")
            end
        else
            buttonEnabled(true)
            UIManager.showToast(Lang.ui_loot_fight14)
        end
    else
        if UIGuidePeople.guideStep then
            UIGuidePeople.isGuide(ui_frameChoose[2], UILootFight)
        end
        if _fightType == dp.FightType.FIGHT_CHIP.NPC then
            ui_playerFight:setString("0")
        elseif _fightType == dp.FightType.FIGHT_CHIP.PC then
            ui_playerFight:setString(pvp.getFightValue())
        end
        ui_playerName:setString(UILootChoose.enemyInfo[1])
        local dictCard = DictCard[tostring(UILootChoose.enemyInfo[2])]
        if dictCard then
            ui_playerIcon:loadTexture("image/" .. DictUI[tostring(dictCard.smallUiId)].fileName)
        end
        local InstPlayerNowLevel = net.InstPlayer.int["4"]
        local exp = DictLevelProp[tostring(InstPlayerNowLevel)].lootFleetExp
        local copper = DictLevelProp[tostring(InstPlayerNowLevel)].lootFleetCopper
        ui_endurance:setString(Lang.ui_loot_fight15 .. DictSysConfig[tostring(StaticSysConfig.lootVigor)].value)
        -- 	ui_exp:setString("EXP：+" .. exp)
        ui_exp:setString("")
        ui_silver:setString(Lang.ui_loot_fight16 .. copper)
        if _customParam ~= nil then
            if not UILootFight.replay then
                buttonEnabled(false)
                --- 选东西前不能点
            end
            ui_base_fail:setVisible(false)
            ui_base_win:setVisible(true)
            addAnimal(1)
            if _customParam[2] ~= nil then
                -- 抢到碎片
                btn_again:setVisible(false)
                local chipName = DictChip[tostring(_customParam[2])].name
                ui_hint:setVisible(true)
                ui_hint:setString(Lang.ui_loot_fight17 .. chipName)
            else
                -- 未抢到碎片
                ui_hint:setVisible(false)
                btn_again:setVisible(true)
            end
            local things = utils.stringSplit(_customParam[1], ";")
            for _key, _obj in pairs(things) do
                table.insert(DropThing, utils.stringSplit(_obj, "_"))
            end
        else
            ui_hint:setVisible(false)
            ui_base_fail:setVisible(true)
            ui_base_win:setVisible(false)
            buttonEnabled(true)
            btn_again:setVisible(true)
            addAnimal(2)
        end
    end
end

function UILootFight.free()
    if UILootFight.Widget:getChildByTag(100) then
        UILootFight.Widget:removeChildByTag(100)
    end
    if UILootFight.Widget:getChildByTag(101) then
        UILootFight.Widget:removeChildByTag(101)
    end
end

-- @fightType : 战斗类型
-- @param : 自定义参数(格式由调用方自己定义)
function UILootFight.setParam(fightType, param)
    _fightType = fightType
    _customParam = param
end


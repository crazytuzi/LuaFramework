require"Lang"
local MINE_IMAGES = { "ui/ore_4.png", "ui/ore_3.png", "ui/ore_2.png", "ui/ore_1.png" }
local WEATHER_IMAGES = { "ui/ore_sunny.png", "ui/ore_cloud.png", "ui/ore_wind.png", "ui/ore_rain.png", "ui/ore_snow.png" }

local ANI_FOCUS = "ani/ui_anim/ui_anim45/ui_anim45.ExportJson"
local ANI_FOCUS_NAME = "ui_anim45"

local ANI_SEARCH = "ani/ui_anim/ui_anim46/ui_anim46.ExportJson"
local ANI_SEARCH_NAME = "ui_anim46"

UIOre = {
    MINE_NAMES = { Lang.ui_ore1, Lang.ui_ore2, Lang.ui_ore3, Lang.ui_ore4 },
    WEATHER_NAMES = { Lang.ui_ore5, Lang.ui_ore6, Lang.ui_ore7, Lang.ui_ore8, Lang.ui_ore9 },
    MINE_OP_OCCUPY = 0,
    MINE_OP_ASSIST = 1,
    minePageIndex = 1,
    minePageCount = 0,
    curMinePageIndices = { },
    produceSpeed = nil,
    specialRewardOccupyTime = nil,
    specialRewardAssistTime = nil,
    occupyCost = 0,
    asssitCost = 0,
    assistAddPercent = 0,
    weather = 3,
    weatherAddPercent = nil,
    activityTimes = { 8 * 3600, 14 * 3600, 20 * 3600, 2 * 3600 },
    mineId = nil,
    mineType = nil,
    mineOp = nil,
    getRewardType = 0,
    mines = nil,
    minePositions = nil,
    needRefreshMine = nil,
    refreshMineScheduleId = nil,
    open = false,
}

local _mineType = nil
local _btn_number = nil
local _aKeySearchMineResponse = nil
local _turnPage = nil
local _showMineInfoIndex = nil

local ui = UIOre

local function setScrollViewItem(btn_number, numberStr)
    local number = tonumber(numberStr)
    btn_number:setTitleText(numberStr)
    local selected = ui.minePageIndex == number
    btn_number:loadTextureNormal(selected and "ui/btn_ore_yes.png" or "ui/btn_ore_no.png")
    btn_number:setTitleColor(selected and cc.c3b(0x33, 0x19, 0x04) or cc.c3b(0xFF, 0xE7, 0xBF))
    btn_number:addTouchEventListener( function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            audio.playSound("sound/button.mp3")
            if not ui.open then return end
            _turnPage = true
            ui.sendPacket { header = StaticMsgRule.refreshMineZone, msgdata = { int = { pageIndex = number } } }
        end
    end )
end

local function refreshMine(mine)
    mine = mine or "0|0|0|0"
    mine = utils.stringSplit(mine, "|")

    ui.mineId = tonumber(mine[1])
    ui.mineType = tonumber(mine[2])
    ui.mineOp = tonumber(mine[3])
    ui.getRewardType = tonumber(mine[4])

    local btn_none = ccui.Helper:seekNodeByName(ui.Widget, "btn_none")
    if ui.mineId == 0 then
        btn_none:loadTextureNormal("ui/ore_none.png")
        btn_none:getChildByName("text_time"):hide()
        btn_none:getChildByName("image_name"):hide()
    else
        btn_none:loadTextureNormal(MINE_IMAGES[ui.mineType + 1])
        btn_none:getChildByName("text_time"):show()
        btn_none:getChildByName("image_name"):show()
    end
end

local function refreshMines(mines)
    mines = mines or ""

    local image_basemap = ccui.Helper:seekNodeByName(ui.Widget, "image_basemap")

    if type(mines) == "table" then
        ui.mines = mines
    else
        mines = utils.stringSplit(mines, "/")
        ui.mines = { }
        for i, mine in ipairs(mines) do
            local singleMine = utils.stringSplit(mine, "|")

            if singleMine[8] then
                singleMine[8] = utils.stringSplit(singleMine[8], ";")[1]
            end

            if singleMine[14] then
                singleMine[14] = utils.stringSplit(singleMine[14], ";")[1]
            end

            local aMine = {
                mineId = tonumber(singleMine[1] or 0),
                mineType = tonumber(singleMine[2] or 0),
                minerId = tonumber(singleMine[3] or 0),
                level = singleMine[4] or "",
                name = singleMine[5] or "",
                alliance = singleMine[6] or "",
                startTime = tonumber(singleMine[7] or 0),
                reward = singleMine[8] or "",
                rewardPlayerId = tonumber(singleMine[9] or 0),
                assistant =
                {
                    id = tonumber(singleMine[10] or 0),
                    level = singleMine[11] or "",
                    name = singleMine[12] or "",
                    startTime = tonumber(singleMine[13] or 0),
                    reward = singleMine[14] or "",
                    rewardPlayerId = tonumber(singleMine[15] or 0),
                }
            }
            table.insert(ui.mines, aMine)
        end
    end
    local focusAni = image_basemap:getChildByName("focusAni")
    if focusAni then focusAni:hide() end

    math.randomseed(20151014 + ui.minePageIndex)

    for i = 1, math.huge do
        local image_ore = image_basemap:getChildByName("image_ore" .. i)
        if not image_ore then break end
        local mine = ui.mines[i]
        if mine then
            image_ore:show()
            image_ore:loadTexture(MINE_IMAGES[mine.mineType + 1])
            local distance = 8
            local angle
            if i == 1 or i == 6 then
                angle = math.random(270, 450)
            elseif i == 4 then
                angle = math.random(90, 270)
            else
                angle = math.random(0, 360)
            end
            local offsetX = distance * math.cos(math.rad(angle))
            local offsetY = distance * math.sin(math.rad(angle))
            local position = ui.minePositions[i]
            image_ore:setPosition(position.x + offsetX, position.y + offsetY)

            if mine.mineType ~= 0 then
                local image_helper = image_ore:getChildByName("image_helper1")
                local image_add = image_ore:getChildByName("image_add")
                if mine.assistant.id == 0 then
                    image_helper:hide()
                    image_add:hide()
                else
                    image_helper:show()
                    image_add:show():getChildByName("text_add"):setString(string.format("+%d%%", ui.assistAddPercent))
                end

                local image_award_ore = image_ore:getChildByName("image_award_ore")
                if mine.rewardPlayerId ~= 0 or(mine.startTime ~= 0 and mine.startTime + ui.specialRewardOccupyTime - utils.getCurrentTime() <= 0) then
                    image_award_ore:hide()
                    image_award_ore:unscheduleUpdate()
                else
                    image_award_ore:show()
                    local itemProp = utils.getItemProp(mine.reward)
                    utils.addBorderImage(itemProp.tableTypeId, itemProp.tableFieldId, image_award_ore)
                    image_award_ore:getChildByName("image_award"):loadTexture(itemProp.smallIcon)
                    local image_base_number = image_award_ore:getChildByName("image_base_number")
                    if itemProp.count > 1 then
                        image_base_number:show():getChildByName("text_number"):setString(tostring(itemProp.count))
                    else
                        image_base_number:hide()
                    end
                    utils.showThingsInfo(image_award_ore, itemProp.tableTypeId, itemProp.tableFieldId)

                    local text_time = ccui.Helper:seekNodeByName(image_award_ore, "text_time")
                    if mine.minerId == 0 then
                        image_award_ore:unscheduleUpdate()
                        text_time:getParent():hide()
                    else
                        text_time:getParent():show()
                        image_award_ore:scheduleUpdate( function(dt)
                            local countdown = math.min(ui.specialRewardOccupyTime, mine.startTime + ui.specialRewardOccupyTime - utils.getCurrentTime())
                            if countdown <= 0 then
                                image_award_ore:unscheduleUpdate()
                                text_time:setString("00:00:00")
                                ui.needRefreshMine = true
                            else
                                countdown = string.format("%02d:%02d:%02d", math.floor(countdown / 3600), math.floor(countdown / 60) % 60, countdown % 60)
                                text_time:setString(countdown)
                            end
                        end )
                    end
                end
            end

            local image_open = image_ore:getChildByName("image_open")
            local text_name = image_ore:getChildByName("text_name")
            local text_lv = image_ore:getChildByName("text_lv")
            local text_alliance = image_ore:getChildByName("text_alliance")
            local image_alliance_di = image_ore:getChildByName("image_alliance_di")
            if mine.minerId ~= 0 then
                image_open:hide()
                text_name:show():setString(mine.name)
                text_lv:show():setString("LV." .. mine.level)
                if string.len(mine.alliance) > 0 then
                    text_alliance:show():setString(Lang.ui_ore10 .. mine.alliance .. "】")
                    local size = text_alliance:getContentSize()
                    size.width = size.width + 17
                    size.height = 30
                    image_alliance_di:show():setContentSize(size)
                else
                    text_alliance:hide()
                    image_alliance_di:hide()
                end
            else
                image_open:show()
                text_name:hide()
                text_lv:hide()
                text_alliance:hide()
                image_alliance_di:hide()
            end

            if mine.mineId == ui.mineId or mine.assistant.id == net.InstPlayer.int["1"] then
                if not focusAni then
                    focusAni = ccs.Armature:create(ANI_FOCUS_NAME)
                    focusAni:setName("focusAni")
                    focusAni:getAnimation():playWithIndex(0, -1, 1)
                    image_basemap:addChild(focusAni)
                end
                local x, y = image_ore:getPosition()
                focusAni:show():setPosition(x, y - image_ore:getContentSize().height / 2 + image_ore:getChildByName("image_open"):getPositionY())
            end
        else
            image_ore:hide()
        end
    end
end

local function getWeatherEffect(weather)
    if weather == 1 then
        -- 晴天
        local sprite = cc.Sprite:create("image/qing.png")
        sprite:setTag(weather)
        local size = sprite:getContentSize()
        sprite:setAnchorPoint(180 / size.width, 234 / size.height)
        sprite:setScale(1.5)
        sprite:setPosition(0, 0)
        sprite:runAction(cc.RepeatForever:create(cc.RotateBy:create(30, 360)))
        return sprite
    elseif weather == 2 then
        -- 多云
        local cloudW = 500
        local cloudH = 328
        local maxY = 1050 - cloudH / 2.0
        local minY = 177
        local function getParam()
            local y = math.random(minY, maxY)
            local actionTime =(y - minY) /(maxY - minY) *(45 - 20) + 20
            return y, actionTime
        end
        local function callBack(actionBody)
            actionBody:stopAllActions()
            local callBackY, callBackTime = getParam()
            actionBody:setPosition(- cloudW / 2, callBackY)
            local action = cc.Sequence:create(
            cc.DelayTime:create(math.random(1, 3)),
            cc.MoveBy:create(callBackTime, cc.p(display.width + cloudW, 0)),
            cc.CallFunc:create(callBack)
            )
            actionBody:runAction(action)
        end
        local function createAction(delayTime, time)
            local action = cc.Sequence:create(
            cc.DelayTime:create(delayTime),
            cc.MoveBy:create(time, cc.p(display.width + cloudW, 0)),
            cc.CallFunc:create(callBack)
            )
            return action
        end

        local cloudLayer = cc.Layer:create()
        cloudLayer:setTag(weather)
        cloudLayer:setContentSize(display.size)
        cloudLayer:setPositionY(- display.height)

        local cloudTable = {
            cloud1 = cc.Sprite:create("image/ui_home_cloud.png"),
            cloud2 = cc.Sprite:create("image/ui_home_cloud.png"),
            cloud3 = cc.Sprite:create("image/ui_home_cloud.png")
        }
        local cloudY1, time1 = getParam()
        cloudTable.cloud1:setPosition(cc.p(- cloudW / 2, cloudY1))
        cloudTable.cloud1:runAction(createAction(0, time1))
        cloudLayer:addChild(cloudTable.cloud1)
        local cloudY2, time2 = getParam()
        cloudTable.cloud2:setPosition(cc.p(- cloudW / 2, cloudY2))
        cloudTable.cloud2:runAction(createAction(1, time2))
        cloudLayer:addChild(cloudTable.cloud2)
        local cloudY3, time3 = getParam()
        cloudTable.cloud3:setPosition(cc.p(- cloudW / 2, cloudY3))
        cloudTable.cloud3:runAction(createAction(2, time3))
        cloudLayer:addChild(cloudTable.cloud3)
        return cloudLayer
    elseif weather == 4 then
        -- 小雨
        local emitter = cc.ParticleRain:createWithTotalParticles(200)
        emitter:setTag(weather)
        emitter:setPosition(display.width / 2, 0)
        emitter:setEmissionRate(emitter:getTotalParticles() / emitter:getLife())
        emitter:setSpeed(350)
        emitter:setGravity(cc.p(0, -100))
        emitter:setStartSize(20)
        emitter:setTexture(cc.Director:getInstance():getTextureCache():addImage("image/rain.png"))
        return emitter
    elseif weather == 5 then
        -- 小雪
        local emitter = cc.ParticleSnow:createWithTotalParticles(200)
        emitter:setTag(weather)
        emitter:setPosition(display.width / 2, 0)
        emitter:setLife(8)
        emitter:setLifeVar(2)

        -- gravity
        emitter:setGravity(cc.p(0, -8))

        emitter:setStartSize(20)

        -- speed of particles
        emitter:setSpeed(130)
        emitter:setSpeedVar(30)

        local startColor = emitter:getStartColor()
        startColor.r = 0.9
        startColor.g = 0.9
        startColor.b = 0.9
        emitter:setStartColor(startColor)

        local startColorVar = emitter:getStartColorVar()
        startColorVar.b = 0.1
        emitter:setStartColorVar(startColorVar)

        emitter:setEmissionRate(emitter:getTotalParticles() / emitter:getLife())
        emitter:setTexture(cc.Director:getInstance():getTextureCache():addImage("image/snow.png"))
        return emitter
    end
end

local function refreshMinePage(weather, pageIndex, mine, mines)
    ui.needRefreshMine = nil
    weather = weather or 3
    pageIndex = pageIndex or 1

    local image_common = ccui.Helper:seekNodeByName(ui.Widget, "image_conmon")
    local weatherAddPercent =(ui.weatherAddPercent and ui.weatherAddPercent[weather]) or 0
    image_common:loadTexture(weatherAddPercent >= 0 and "ui/btn_ore_green.png" or "ui/btn_ore_red.png")
    local addStr = weatherAddPercent > 0 and string.format(Lang.ui_ore11, weatherAddPercent) or(weatherAddPercent == 0 and Lang.ui_ore12 or string.format(Lang.ui_ore13, - weatherAddPercent))
    image_common:getChildByName("text_common"):setString(string.format(Lang.ui_ore14, addStr))
    local image_arrow = image_common:getChildByName("image_arrow")
    if weatherAddPercent == 0 then
        image_arrow:hide()
    else
        image_arrow:show():loadTexture(weatherAddPercent > 0 and "ui/ore_gjian.png" or "ui/ore_rjian.png")
    end

    local image_weather = ccui.Helper:seekNodeByName(ui.Widget, "image_weather")
    image_weather:loadTexture(WEATHER_IMAGES[weather])

    local updateScrollView = false

    local view_ore = ccui.Helper:seekNodeByName(ui.Widget, "view_ore")
    local curMinePageIndices = ui.curMinePageIndices
    if #curMinePageIndices ~= ui.minePageCount then
        while #curMinePageIndices > ui.minePageCount do
            curMinePageIndices[#curMinePageIndices] = nil
        end
        while #curMinePageIndices < ui.minePageCount do
            curMinePageIndices[#curMinePageIndices + 1] = tostring(#curMinePageIndices + 1)
        end
        updateScrollView = true
    end

    if pageIndex ~= ui.minePageIndex then
        ui.minePageIndex = pageIndex
        updateScrollView = true
    end

    if updateScrollView then
        view_ore:removeAllChildren()
        if _turnPage then
            UIOre.isFlush = true
            _turnPage = nil
        end
        utils.updateHorzontalScrollView(UIOre, view_ore, _btn_number, curMinePageIndices, setScrollViewItem, { leftSpace = 8.5, rightSpace = 8.5, space = 34.5, setTag = true, jumpTo = pageIndex - 2 })
    end

    refreshMine(mine)
    refreshMines(mines)

    if ui.weather ~= weather then
        ui.weather = weather

        local image_ore6 = ccui.Helper:seekNodeByName(ui.Widget, "image_ore6")
        local image_basemap = ccui.Helper:seekNodeByName(ui.Widget, "image_basemap")

        local mapCover = image_basemap:getProtectedChildByTag(100)
        if not mapCover then
            mapCover = ccui.ImageView:create()
            image_basemap:addProtectedChild(mapCover, 0, 100)
            mapCover:setAnchorPoint(display.LEFT_BOTTOM)
        end

        mapCover:hide()
        if weather == 5 then
            mapCover:show():loadTexture("ui/map_snow.png")
            mapCover:setPositionY(25)
        end

        local node = image_ore6:getChildByName("weather")
        if not node then
            node = cc.Node:create()
            node:setName("weather")
            image_ore6:addChild(node)
        end
        if weather >= 1 and weather <= 5 and weather ~= 3 then
            local size = image_ore6:getContentSize()
            node:show():setPosition(- image_ore6:getPositionX() + size.width / 2, display.height - image_ore6:getPositionY() + size.height / 2)
            for i = 1, 5 do
                local effect = node:getChildByTag(i)
                if effect then
                    effect:setVisible(i == weather)
                    if i == weather and weather == 1 then
                        effect:stopAllActions()
                        effect:setRotation(0)
                        effect:runAction(cc.RepeatForever:create(cc.RotateBy:create(30, 360)))
                    end
                elseif i == weather then
                    effect = getWeatherEffect(weather)
                    if effect then node:addChild(effect) end
                end
            end
        else
            node:hide()
        end
    end
end

function ui.refreshCurPageMine(pack)
    local msgdata = pack.msgdata
    if msgdata.int.weather and msgdata.int.pageIndex and msgdata.string.mine and msgdata.string.mines then
        refreshMinePage(msgdata.int.weather, msgdata.int.pageIndex, msgdata.string.mine, msgdata.string.mines)
        UIManager.flushWidget(UIOreInfo)
    end
end

local function showImageHint(pageIndex)
    local image_hint = ccui.Helper:seekNodeByName(ui.Widget, "image_hint")
    local text_ore_number = image_hint:getChildByName("text_ore_number")

    text_ore_number:setString(string.format(Lang.ui_ore15, pageIndex))

    image_hint:show()
    image_hint:setOpacity(0)
    image_hint:stopAllActions()
    image_hint:runAction(cc.Sequence:create(cc.FadeIn:create(1), cc.FadeOut:create(1), cc.CallFunc:create( function() image_hint:hide() end)))
end

local function enterMineZone(msgdata)
    ui.activityTimes = { msgdata.int.activityStartTime, msgdata.int.activityEndTime, msgdata.int.activityStartTime2, msgdata.int.activityEndTime2 }
    ui.minePageCount = msgdata.int.minePageCount
    ui.specialRewardOccupyTime = msgdata.int.specialRewardOccupyTime
    ui.specialRewardAssistTime = msgdata.int.specialRewardAssistTime

    if msgdata.string.produceSpeed then
        local produceSpeed = utils.stringSplit(msgdata.string.produceSpeed, "/")
        for i = 1, #produceSpeed do
            local ps = utils.stringSplit(produceSpeed[i], "|")
            for j = 1, #ps do
                ps[j] = tonumber(ps[j])
            end
            produceSpeed[i] = ps
        end
        ui.produceSpeed = produceSpeed
    end

    if msgdata.string.weatherAddPercent then
        local weatherAddPercent = utils.stringSplit(msgdata.string.weatherAddPercent, "|")
        for i = 1, #weatherAddPercent do
            weatherAddPercent[i] = tonumber(weatherAddPercent[i])
        end
        ui.weatherAddPercent = weatherAddPercent
    end
    ui.assistAddPercent = msgdata.int.assistAddPercent
    refreshMinePage(msgdata.int.weather, msgdata.int.pageIndex, msgdata.string.mine, msgdata.string.mines)
    ui.open = true
end

function ui.jumpToMine(msgdata, mineId)
    ui.isFlush = true
    UIManager.showScreen("ui_notice", "ui_ore")
    if msgdata then
        enterMineZone(msgdata)
    end

    for i, mine in ipairs(ui.mines) do
        if mine.mineId == mineId then
            UIOreInfo.setMine(mine)
            UIManager.pushScene("ui_ore_info")
            UIOreInfo.warParam = nil
            break
        end
    end
end

function ui.showFightResult(uiItem, resultCode, msgdata)
    local isWin = resultCode > 0
    local info
    if resultCode == 1 then
        info = Lang.ui_ore16
    elseif resultCode == 0 then
        info = Lang.ui_ore17
    else
        info = Lang.ui_ore18
    end
    local animationId = isWin and 11 or 12
    local armature = ActionManager.getUIAnimation(animationId)
    if isWin then
        armature:getBone("zhan"):addDisplay(ccs.Skin:createWithSpriteFrameName("win_qiangkuang01.png"), 0)
        armature:getBone("dou"):addDisplay(ccs.Skin:createWithSpriteFrameName("win_qiangkuang02.png"), 0)
    else
        armature:getBone("zhandoushibai"):addDisplay(ccs.Skin:createWithSpriteFrameName("loser_qiangkuang.png"), 0)
    end
    UITowerWinSmall.show( {
        isWin = isWin,
        fightType = dp.FightType.FIGHT_MINE,
        animation = armature,
        info = info,
        callbackfunc = function()
            audio.playMusic("sound/bg_music.mp3", true)
            if armature and armature:getParent() then armature:removeFromParent() end
            UITeam.checkRecoverState()
            if uiItem == UIActivityEmail and not isWin then
                UIManager.showScreen("ui_notice", "ui_menu")
                UIActivityPanel.scrollByName("mail", "mail")
                UIManager.showWidget("ui_activity_panel")
            else
                ui.isFlush = true
                UIManager.showScreen("ui_notice", "ui_ore")
                if msgdata then
                    enterMineZone(msgdata)
                end

                if uiItem == UIOreInfo then
                    UIManager.pushScene("ui_ore_info")
                    UIOreInfo.warParam = nil
                elseif uiItem == UIOreEmail then
                    UIManager.pushScene("ui_ore_email")
                end
            end
        end
    } )
end

local function netErrorCallbackFunc(pack)
    local code = tonumber(pack.header)
    local msgdata = pack.msgdata

    if msgdata.int.activityStartTime and msgdata.int.activityEndTime and msgdata.int.activityStartTime and msgdata.int.activityEndTime then
        ui.activityTimes = { msgdata.int.activityStartTime, msgdata.int.activityEndTime, msgdata.int.activityStartTime2, msgdata.int.activityEndTime2 }
        UIManager.pushScene("ui_ore_hint")
    end

    if code == StaticMsgRule.enterMineZone then
        ui.minePageIndex = 1
        ui.minePageCount = 6
        refreshMinePage()
        UIGuidePeople.isGuide(nil, UIOre)
    elseif code == StaticMsgRule.aKeySearchMine then
        _aKeySearchMineResponse = 0
    end

    if msgdata.int.weather and msgdata.int.pageIndex and msgdata.string.mine and msgdata.string.mines then
        refreshMinePage(msgdata.int.weather, msgdata.int.pageIndex, msgdata.string.mine, msgdata.string.mines)
    end
end

local function netCallbackFunc(pack)
    local code = tonumber(pack.header)
    local msgdata = pack.msgdata
    if code == StaticMsgRule.enterMineZone then
        enterMineZone(msgdata)
        UIGuidePeople.isGuide(nil, UIOre)
    elseif code == StaticMsgRule.refreshMineZone or code == StaticMsgRule.searchMine then
        refreshMinePage(msgdata.int.weather, msgdata.int.pageIndex, msgdata.string.mine, msgdata.string.mines)
        if _showMineInfoIndex then
            UIOreInfo.setMine(ui.mines[_showMineInfoIndex])
            _showMineInfoIndex = nil
            UIManager.pushScene("ui_ore_info")
        else
            showImageHint(msgdata.int.pageIndex)
        end
    elseif code == StaticMsgRule.aKeySearchMine then
        _aKeySearchMineResponse = 1
        refreshMinePage(msgdata.int.weather, msgdata.int.pageIndex, msgdata.string.mine, msgdata.string.mines)
    end
end

local function sendPacket(pack)
    UIManager.showLoading()
    netSendPackage(pack, netCallbackFunc, netErrorCallbackFunc)
end

ui.sendPacket = sendPacket

local function aKeySearchMine(mineType)
    _mineType = mineType
    netSendPackage( { header = StaticMsgRule.aKeySearchMine, msgdata = { int = { type = _mineType } } }, netCallbackFunc, netErrorCallbackFunc)

    local image_basemap = ccui.Helper:seekNodeByName(ui.Widget, "image_basemap")
    local layout = ccui.Layout:create()
    layout:setContentSize(display.size)
    layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    layout:setBackGroundColor(cc.c3b(0, 0, 0))
    layout:setBackGroundColorOpacity(255)
    layout:setTouchEnabled(true)
    image_basemap:addChild(layout, 3)

    local armature = ccs.Armature:create(ANI_SEARCH_NAME)
    layout:addChild(armature)
    armature:setPosition(display.cx, display.cy)
    armature:getAnimation():playWithIndex(0)
    local function onMovementEvent(armature, movementType, movementID)
        if movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete then
            armature:getAnimation():stop()
            UIManager.gameLayer:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),
            cc.CallFunc:create( function()
                layout:removeFromParent()
                if _aKeySearchMineResponse then
                    if _aKeySearchMineResponse == 0 then
                        -- UIManager.showToast("当前没有空的" .. ui.MINE_NAMES[_mineType + 1])
                    else
                        UIManager.showToast(Lang.ui_ore19 .. ui.MINE_NAMES[_mineType + 1] .. Lang.ui_ore20)
                    end
                    _mineType = nil
                    _aKeySearchMineResponse = nil
                end
            end )))
        end
    end
    armature:getAnimation():setMovementEventCallFunc(onMovementEvent)
    local function onFrameEvent(bone, evt, originFrameIndex, currentFrameIndex)
        if evt == "find_end" then
            if not _aKeySearchMineResponse then
                armature:getAnimation():gotoAndPlay(24)
            else
                layout:runAction(cc.FadeOut:create(0.5))
            end
        end
    end
    armature:getAnimation():setFrameEventCallFunc(onFrameEvent)
end

function ui.init()
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(ANI_FOCUS)
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(ANI_SEARCH)

    local btn_help = ccui.Helper:seekNodeByName(ui.Widget, "btn_help")
    local btn_none = ccui.Helper:seekNodeByName(ui.Widget, "btn_none")
    local btn_find = ccui.Helper:seekNodeByName(ui.Widget, "btn_find")
    local btn_email = ccui.Helper:seekNodeByName(ui.Widget, "btn_email")
    local btn_back = ccui.Helper:seekNodeByName(ui.Widget, "btn_back")
    local btn_arrow_l = ccui.Helper:seekNodeByName(ui.Widget, "btn_arrow_l")
    local btn_arrow_r = ccui.Helper:seekNodeByName(ui.Widget, "btn_arrow_r")
    local image_choose = ccui.Helper:seekNodeByName(ui.Widget, "image_choose")
    local image_basemap = ccui.Helper:seekNodeByName(ui.Widget, "image_basemap")
    local image_hint = image_basemap:getChildByName("image_hint")
    local panel = image_basemap:getChildByName("panel")

    local children = image_basemap:getChildren()
    for i, child in ipairs(children) do
        child:setLocalZOrder(child:getLocalZOrder() + 1)
    end

    image_hint:hide()
    image_choose:hide()
    panel:hide()

    for i = 1, math.huge do
        local image_ore = image_choose:getChildByName("image_ore_" .. i)
        if not image_ore then break end
        image_ore:addTouchEventListener( function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                audio.playSound("sound/button.mp3")
                if not ui.open then return end
                aKeySearchMine(i)
                image_choose:hide()
                panel:hide()
            end
        end )
    end

    panel:addTouchEventListener( function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            image_choose:hide()
            panel:hide()
        end
    end )

    local view_ore = ccui.Helper:seekNodeByName(ui.Widget, "view_ore")
    _btn_number = view_ore:getChildByName("btn_number")
    _btn_number:setScale9Enabled(false)
    _btn_number:ignoreContentAdaptWithSize(true)
    _btn_number:retain()

    ui.minePositions = { }
    for i = 1, math.huge do
        local image_ore = image_basemap:getChildByName("image_ore" .. i)
        if not image_ore then break end
        image_ore:ignoreContentAdaptWithSize(true)
        image_ore:addTouchEventListener( function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                audio.playSound("sound/button.mp3")
                if not ui.open then return end
                _showMineInfoIndex = i
                sendPacket { header = StaticMsgRule.refreshMineZone, msgdata = { int = { pageIndex = ui.minePageIndex } } }
            end
        end )
        local x, y = image_ore:getPosition()
        table.insert(ui.minePositions, { x = x, y = y })
    end

    local function touchevent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            audio.playSound("sound/button.mp3")

            if sender == btn_help then
                UIAllianceHelp.show( { titleName = Lang.ui_ore21, type = 6 })

                local text_ore = ccui.Helper:seekNodeByName(UIAllianceHelp.Widget, "text_ore")
                text_ore:setString(string.format(text_ore:getString(), ui.assistAddPercent))
            elseif sender == btn_arrow_l then
                local curPageIndex = ui.minePageIndex
                if curPageIndex > 1 then
                    sendPacket { header = StaticMsgRule.refreshMineZone, msgdata = { int = { pageIndex = curPageIndex - 1 } } }
                end
            elseif sender == btn_arrow_r then
                local curPageIndex = ui.minePageIndex
                if curPageIndex < ui.minePageCount then
                    sendPacket { header = StaticMsgRule.refreshMineZone, msgdata = { int = { pageIndex = curPageIndex + 1 } } }
                end
            elseif sender == btn_back then
                local view_ore = ccui.Helper:seekNodeByName(ui.Widget, "view_ore")
                view_ore:removeAllChildren()
                if _btn_number and _btn_number:getReferenceCount() >= 1 then
                    _btn_number:release()
                    _btn_number = nil
                end
                ccs.ArmatureDataManager:getInstance():removeArmatureData(ANI_FOCUS)
                ccs.ArmatureDataManager:getInstance():removeArmatureData(ANI_SEARCH)
                -- UIMenu.onActivity()
                UIMenu.onHomepage()
                WidgetManager.delete(UIOre)
            elseif ui.open then
                if sender == btn_none then
                    if ui.mineId and ui.mineId ~= 0 then
                        sendPacket { header = StaticMsgRule.searchMine, msgdata = { int = { mineId = ui.mineId } } }
                    end
                elseif sender == btn_find then
                    image_choose:show()
                    panel:show()
                elseif sender == btn_email then
                    ui.yj = nil
                    btn_email:removeChildByTag(100)
                    UIManager.pushScene("ui_ore_email")
                end
            end
        end
    end

    btn_help:addTouchEventListener(touchevent)
    btn_back:addTouchEventListener(touchevent)
    btn_none:addTouchEventListener(touchevent)
    btn_find:addTouchEventListener(touchevent)
    btn_email:addTouchEventListener(touchevent)
    btn_arrow_l:addTouchEventListener(touchevent)
    btn_arrow_r:addTouchEventListener(touchevent)
end

function ui.getCountdownTime()
    local curTime = utils.getCurrentTime()
    local t = os.date("*t", curTime)
    curTime = t.hour * 3600 + t.min * 60 + t.sec
    local countdown = 0

    local function getCountdown(startTime, endTime)
        if startTime <= endTime then
            if curTime >= startTime and curTime <= endTime then
                countdown = endTime - curTime
            end
        else
            if curTime >= startTime and curTime <= 24 * 3600 then
                countdown = 24 * 3600 - curTime + endTime
            elseif curTime <= endTime then
                countdown = endTime - curTime
            end
        end
    end

    getCountdown(ui.activityTimes[1], ui.activityTimes[2])
    getCountdown(ui.activityTimes[3], ui.activityTimes[4])
    return countdown
end

function ui.setup()
    ui.open = false
    local text_gold_number = ccui.Helper:seekNodeByName(ui.Widget, "text_gold_number")
    local text_silver_number = ccui.Helper:seekNodeByName(ui.Widget, "text_silver_number")
    local text_endurance_number = ccui.Helper:seekNodeByName(ui.Widget, "text_endurance_number")
    local label_fight = ccui.Helper:seekNodeByName(ui.Widget, "label_fight")
    local text_time = ccui.Helper:seekNodeByName(ui.Widget, "btn_none"):getChildByName("text_time")
    local btn_email = ccui.Helper:seekNodeByName(ui.Widget, "btn_email")

    utils.addImageHint(ui.yj == 1, btn_email, 100, 15, 15)
    local image_hint = btn_email:getChildByTag(100)
    if image_hint then image_hint:setName("withscale") end

    text_gold_number:getParent():getParent():scheduleUpdate( function()
        text_gold_number:setString(tostring(net.InstPlayer.int["5"]))
        text_silver_number:setString(net.InstPlayer.string["6"])
        text_endurance_number:setString(string.format("%d/%d", net.InstPlayer.int["10"], net.InstPlayer.int["11"]))
        local isTimeVisible = text_time:isVisible()
        local hasUIOreInfo = UIOreInfo.Widget and UIOreInfo.Widget:getParent()

        if ui.needRefreshMine and not ui.refreshMineScheduleId then
            ui.refreshMineScheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc( function(dt)
                ui.sendPacket { header = StaticMsgRule.refreshMineZone, msgdata = { int = { pageIndex = ui.minePageIndex } } }
            end , 5, false)
        elseif ui.refreshMineScheduleId then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(ui.refreshMineScheduleId)
            ui.refreshMineScheduleId = nil
        end

        if ui.open and(isTimeVisible or hasUIOreInfo) then
            local countdown = ui.getCountdownTime()
            countdown = string.format("%02d:%02d:%02d", math.floor(countdown / 3600), math.floor(countdown / 60) % 60, countdown % 60)
            if isTimeVisible then
                text_time:setString(countdown)
            end
            if hasUIOreInfo then
                local text_time = ccui.Helper:seekNodeByName(UIOreInfo.Widget, "text_time")
                text_time:setString(countdown)
            end
        end
    end )
    label_fight:setString(tostring(utils.getFightValue()))
    if ui.isFlush then
        ui.isFlush = nil
        ui.open = true
    else
        sendPacket { header = StaticMsgRule.enterMineZone, msgdata = { } }
    end
end

function ui.free()
    ui.mineId = nil
    ui.mines = nil
    ui.minePageIndex = 1
    ui.open = nil
    ui.needRefreshMine = nil
    ui.weather = 3
    ui.curMinePageIndices = { }
    if ui.refreshMineScheduleId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(ui.refreshMineScheduleId)
        ui.refreshMineScheduleId = nil
    end
end

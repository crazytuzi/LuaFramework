require"Lang"
UIGuideInfo = { }
local taskStory = nil
local changePeople = { }
local changeScene = nil
local curData = { }
local index = 1
local state = nil
local callBack = nil
local ui_cardIconAnim, _cardIconAnimName = { }, { }
local isPlay = false
local handle = nil
local isOver = false -- 判断字体是否打印完

local function cleanCardAnim()
    for key = 1, 3 do
        if ui_cardIconAnim[key] and _cardIconAnimName[key] then
            ui_cardIconAnim[key]:getAnimation():stop()
            ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("ani/card_action/" .. _cardIconAnimName[key] .. "/" .. _cardIconAnimName[key] .. ".ExportJson")
            ccs.ArmatureDataManager:getInstance():removeArmatureData(ui_cardIconAnim[key]:getAnimation():getCurrentMovementID())
            ui_cardIconAnim[key]:removeFromParent()
            ui_cardIconAnim[key] = nil
            _cardIconAnimName[key] = nil
        end
    end
end

local function checkDialogText()
    if taskStory[state][index] ~= nil then
        local text = taskStory[state][index].dialog
        if text and utils.utf8len(text) > 50 then
            taskStory[state][index].dialog = utils.UTF8StrSub(text, 1, 50)
            local dialog = utils.UTF8StrSub(text, 50)
            table.insert(taskStory[state], index + 1, { })
            taskStory[state][index + 1].data = taskStory[state][index].data
            taskStory[state][index + 1].dir = taskStory[state][index].dir
            taskStory[state][index + 1].dialog = dialog
        end
    end
end

local function printText(dialogue, ui_Item)
    local i = 0
    local text = ""
    local len = utils.utf8len(dialogue)
    local function talkFunc()
        i = i + 1
        if i <= len then
            local str = utils.getUTF8Str(dialogue, i)
            text = text .. str
            ui_Item:setString(text)
            ui_Item:runAction(cc.Sequence:create(cc.DelayTime:create(0.05), cc.CallFunc:create(talkFunc)))
        else
            isOver = true
        end
    end
    if dialogue then
        isOver = false
        ui_Item:runAction(cc.Sequence:create(cc.DelayTime:create(0.4), cc.CallFunc:create(talkFunc)))
    else
        isOver = true
        ui_Item:setString("")
    end
end

function UIGuideInfo.init()
    local ui_image_base_talk = ccui.Helper:seekNodeByName(UIGuideInfo.Widget, "image_base_talk")
    local btn_jump = ccui.Helper:seekNodeByName(UIGuideInfo.Widget, "btn_jump")
    btn_jump:setPressedActionEnabled(true)
    local function TouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if state == "begin" or state == "ended" then
                if sender == btn_jump then
                    while taskStory[state][index] do
                        index = index + 1
                    end
                    cleanCardAnim()
                    UIGuideInfo.setup()
                elseif sender == ui_image_base_talk then
                    if not isOver then
                        ccui.Helper:seekNodeByName(UIGuideInfo.Widget, "text_talk"):stopAllActions()
                        ccui.Helper:seekNodeByName(UIGuideInfo.Widget, "text_talk_aside"):stopAllActions()
                        local dialogue = taskStory[state][index].dialog
                        local talk = taskStory[state][index].talk
                        if dialogue then
                            ccui.Helper:seekNodeByName(UIGuideInfo.Widget, "text_talk"):setString(dialogue)
                        end
                        if talk then
                            ccui.Helper:seekNodeByName(UIGuideInfo.Widget, "text_talk_aside"):setString(talk)
                        end
                        isOver = true
                    else
                        index = index + 1
                        -- checkDialogText()
                        cleanCardAnim()
                        UIGuideInfo.setup()
                    end
                end
            end

        end
    end
    ui_image_base_talk:addTouchEventListener(TouchEvent)
    btn_jump:addTouchEventListener(TouchEvent)
end

function UIGuideInfo.setup()
    local ui_image_basemap = ccui.Helper:seekNodeByName(UIGuideInfo.Widget, "image_basemap")
    local ui_image_base_talk = ccui.Helper:seekNodeByName(UIGuideInfo.Widget, "image_base_talk")
    local ui_talk = ui_image_base_talk:getChildByName("text_talk")
    local ui_name = ui_image_base_talk:getChildByName("text_name")
    local ui_talk_aside = ui_image_base_talk:getChildByName("text_talk_aside")
    local ui_image_head = ui_image_base_talk:getChildByName("image_head")
    ui_image_head:setVisible(false)
    local ui_image_card = { }
    for key = 1, 3 do
        ui_image_card[key] = ccui.Helper:seekNodeByName(UIGuideInfo.Widget, "image_card" .. key)
    end
    ui_talk:setString("")
    ui_name:setString("")
    ui_talk_aside:setString("")
    if taskStory and taskStory[state][index] ~= nil then
        if isPlay then
            local name = nil
            local dialogue = taskStory[state][index].dialog
            local effect = taskStory[state][index].effect
            local _data = taskStory[state][index].data
            local dir = taskStory[state][index].dir
            local scene = taskStory[state][index].scene
            local talk = taskStory[state][index].talk
            if talk then
                for key = 1, 3 do
                    ui_image_card[key]:setVisible(false)
                end
            end
            if dir == 3 then
                -- 一人
                ui_image_card[3]:setVisible(true)
                ui_image_card[1]:setVisible(false)
                ui_image_card[2]:setVisible(false)
                if not curData[3] then
                    curData[2] = nil
                    curData[1] = nil
                    changePeople[3] = true
                end
            else
                --- 双人
                ui_image_card[1]:setVisible(curData[1] and true or false)
                ui_image_card[2]:setVisible(curData[2] and true or false)
                ui_image_card[3]:setVisible(false)
                if not curData[1] and not curData[2] then
                    curData[3] = nil
                    changePeople[1] = true
                    changePeople[2] = true
                end
            end
            for key, obj in pairs(curData) do
                changePeople[key] =(key == dir and _data ~= obj)
                if key == 3 and(_data == "7_88" or(obj == "7_88" and taskStory[state][index - 2] and _data == taskStory[state][index - 2].data)) then
                    changePeople[key] = false
                end
                if scene then
                    obj = nil
                end
            end
            if dir ~= nil then
                curData[dir] = _data
            end
            changeScene =(scene and index ~= 1)
            if handle then
                AudioEngine.stopEffect(handle)
            end


            local function PlayScene()
                -----------换人------------
                if _data then
                    for key, obj in pairs(curData) do
                        if not obj then
                            ui_image_card[key]:setVisible(false)
                            return
                        end
                        ui_image_card[key]:setVisible(true)
                        local dictData = nil
                        local table_str = utils.stringSplit(obj, "_")
                        local tableTypeId, tableFieldId = table_str[1], table_str[2]
                        if tonumber(tableTypeId) == StaticTableType.DictPill then
                            -- 丹药字典表
                            dictData = DictPill[tostring(tableFieldId)]
                        elseif tonumber(tableTypeId) == StaticTableType.DictCard then
                            dictData = DictCard[tostring(tableFieldId)]
                        elseif tonumber(tableTypeId) == StaticTableType.DictEquipment then
                            dictData = DictEquipment[tostring(tableFieldId)]
                        else
                            dictData = DictPillRecipe[tostring(tableFieldId)]
                        end
                        if key == dir and tonumber(tableTypeId) == StaticTableType.DictCard then
                            name = dictData.name
                            ui_image_head:setVisible(true)
                            ui_image_head:loadTexture("image/" .. DictUI[tostring(dictData.smallUiId)].fileName)
                        end
                        if (key == 3 and dictData.name == Lang.ui_guide_info1 and index ~= 1) then
                            if changeScene then
                                ui_image_card[key]:setVisible(false)
                            else
                                local _data = taskStory[state][index - 1].data
                                if _data then
                                    local table_str = utils.stringSplit(_data, "_")
                                    if tonumber(table_str[1]) == StaticTableType.DictCard then
                                        local _dictData = DictCard[tostring(table_str[2])]

                                        ui_image_card[key]:setVisible(false)
                                        if _dictData.animationFiles and string.len(_dictData.animationFiles) > 0 then
                                            ui_cardIconAnim[key], _cardIconAnimName[key] = ActionManager.getCardAnimation(_dictData.animationFiles)
                                        else
                                            ui_cardIconAnim[key], _cardIconAnimName[key] = ActionManager.getCardBreatheAnimation("image/" .. DictUI[tostring(_dictData.bigUiId)].fileName)
                                        end
                                        local pos = cc.p(ui_image_card[key]:getPosition())
                                        ui_image_basemap:addChild(ui_cardIconAnim[key])
                                        ui_cardIconAnim[key]:setPosition(cc.p(pos.x, ui_image_basemap:getContentSize().height / 2 - 35))
                                    end
                                else
                                    ui_image_card[key]:setVisible(false)
                                end
                            end
                            break
                        end

                        ui_image_card[key]:setVisible(false)
                        if dictData.animationFiles and string.len(dictData.animationFiles) > 0 then
                            ui_cardIconAnim[key], _cardIconAnimName[key] = ActionManager.getCardAnimation(dictData.animationFiles)
                        else
                            ui_cardIconAnim[key], _cardIconAnimName[key] = ActionManager.getCardBreatheAnimation("image/" .. DictUI[tostring(dictData.bigUiId)].fileName)
                        end
                        local pos = cc.p(ui_image_card[key]:getPosition())
                        if not(key == 3 and dictData.name == Lang.ui_guide_info2 and index == 1) then
                            ui_image_basemap:addChild(ui_cardIconAnim[key])
                        end
                        if key ~= 3 then
                            ui_cardIconAnim[key]:setScale(0.88)
                            ui_cardIconAnim[key]:setPosition(cc.p(pos.x, ui_image_basemap:getContentSize().height / 2 - 55))
                        else
                            ui_cardIconAnim[key]:setPosition(cc.p(pos.x, ui_image_basemap:getContentSize().height / 2 - 35))
                        end
                        if changePeople[key] then
                            ui_cardIconAnim[key]:setOpacity(0)
                            local colorValue =(dir == key) and 255 or 125
                            ui_cardIconAnim[key]:setColor(cc.c3b(colorValue, colorValue, colorValue))
                            ui_cardIconAnim[key]:runAction(cc.FadeIn:create(1))
                        else
                            local colorValue =(dir ~= key) and 125 or 255
                            ui_cardIconAnim[key]:runAction(cc.TintTo:create(0.5, colorValue, colorValue, colorValue))
                        end

                    end

                else
                    local param = FightTaskInfo.getCurrentInfo()
                    if param then
                        if param.chapterId == 1 and param.barrierId == 2 and index == 13 then
                            ui_image_card[3]:loadTexture("image/fightTaskImage/xs.png")
                            ui_image_card[3]:setVisible(true)
                            ui_image_card[3]:setOpacity(0)
                            ui_image_card[3]:runAction(cc.FadeIn:create(1))
                        end
                    end
                end

                ------打字----------------
                ui_talk:setTextColor(cc.c4b(255, 255, name == Lang.ui_guide_info3 and 0 or 255, 255))
                ui_name:setString(name or "")
                ui_talk:stopAllActions()
                if dialogue then
                    printText(dialogue, ui_talk)
                end
                if talk then
                    isOver = false
                    ui_image_basemap:runAction(cc.Sequence:create(cc.TintTo:create(0.2, 125, 125, 125), cc.CallFunc:create( function()
                        printText(talk, ui_talk_aside)
                    end )))
                else
                    ui_image_basemap:runAction(cc.TintTo:create(0.2, 255, 255, 255))
                end
                if effect then
                    handle = AudioEngine.playEffect("sound/" .. effect)
                end
            end
            -----更换场景-----------
            if changeScene then
                local subHeight = 0
                local t = 0.01
                local function changeFunc(sender, table)
                    if table[1] == 1 then
                        subHeight = subHeight + 10
                        sender:setTextureRect(cc.rect(0, subHeight, sender:getContentSize().width, sender:getContentSize().height -(subHeight * 2)))
                        if subHeight < sender:getContentSize().height / 2 then
                            sender:runAction(cc.Sequence:create(cc.DelayTime:create(t), cc.CallFunc:create(changeFunc, { 1 })))
                        else
                            --- 切换到另一场景
                            if scene then
                                sender:setVisible(true)
                                sender:loadTexture(string.format("image/fightTaskImage/%s", scene))
                            else
                                sender:setVisible(false)
                            end
                            sender:runAction(cc.Sequence:create(cc.DelayTime:create(t), cc.CallFunc:create(changeFunc, { 2 })))
                        end
                    else
                        subHeight = subHeight - 10
                        sender:setTextureRect(cc.rect(0, subHeight, sender:getContentSize().width, sender:getContentSize().height -(subHeight * 2)))
                        if subHeight ~= 0 then
                            sender:runAction(cc.Sequence:create(cc.DelayTime:create(t), cc.CallFunc:create(changeFunc, { 2 })))
                        else
                            --- 切换完场景
                            ui_image_base_talk:setEnabled(true)
                            PlayScene()
                        end
                    end
                end

                for key = 1, 3 do
                    ui_image_card[key]:setVisible(false)
                end
                ui_image_base_talk:setEnabled(false)
                ui_image_basemap:runAction(cc.Sequence:create(cc.DelayTime:create(t), cc.CallFunc:create(changeFunc, { 1 })))
            else
                PlayScene()
            end
        end
    else
        UIManager.popScene()
        if state == "begin" or state == "ended" then
            if state == "begin" and callBack ~= nil then
                callBack()
                callBack = nil
            elseif state == "ended" then
                UIFightTask.stopTaskAni = nil
                UIManager.flushWidget(UIFightTask)
                -----关卡引导入口--------------
                UIGuidePeople.checkTaskGuide()
                UIFightTask.showPosterDialog()
            end
            taskStory[state].flag = true
            taskStory = nil
            state = nil
        end
    end
end

function UIGuideInfo.PlayStory(_taskStory, _index, _state, _callBack)
    taskStory = _taskStory
    index = _index
    state = _state
    callBack = _callBack
    local function MyCallBack()
        local ui_image_basemap = ccui.Helper:seekNodeByName(UIGuideInfo.Widget, "image_basemap")
        ui_image_basemap:setOpacity(0)
        local scene = taskStory[state][index].scene
        if scene then
            ui_image_basemap:loadTexture(string.format("image/fightTaskImage/%s", scene))
        else
            ui_image_basemap:loadTexture("image/fightTaskImage/dh_cj01.png")
        end
        for key = 1, 3 do
            ccui.Helper:seekNodeByName(UIGuideInfo.Widget, "image_card" .. key):setVisible(false)
        end

        local function ActionCallBack()
            -- checkDialogText()
            isPlay = true
            cleanCardAnim()
            UIGuideInfo.setup()
        end
        local action = cc.Sequence:create(cc.FadeIn:create(0.6), cc.CallFunc:create(ActionCallBack))
        ui_image_basemap:runAction(action)
    end
    UIManager.pushScene("ui_guide_info", true)
    MyCallBack()
end

function UIGuideInfo.free(...)
    cleanCardAnim()
    index = 1
    curData = { }
    changePeople = { }
    changeScene = nil
    isPlay = false
    if handle then
        AudioEngine.stopEffect(handle)
        handle = nil
    end
end

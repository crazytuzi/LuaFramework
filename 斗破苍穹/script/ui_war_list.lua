require"Lang"
UIWarList = {
    SHOW_TYPE = { report = 0, reward = 1 },
    NAMES = { Lang.ui_war_list1, Lang.ui_war_list2, Lang.ui_war_list3, Lang.ui_war_list4, Lang.ui_war_list5, Lang.ui_war_list6 },
    RANKNAMES = { Lang.ui_war_list7, Lang.ui_war_list8, Lang.ui_war_list9, Lang.ui_war_list10, Lang.ui_war_list11 }
}

local ui = UIWarList

local reportViewItem = nil
local rewardViewItem = nil

function ui.init()
    local btn_close = ccui.Helper:seekNodeByName(ui.Widget, "btn_close")
    local btn_eight = ccui.Helper:seekNodeByName(ui.Widget, "btn_eight")
    local btn_four = ccui.Helper:seekNodeByName(ui.Widget, "btn_four")
    local btn_two = ccui.Helper:seekNodeByName(ui.Widget, "btn_two")
    local btn_two_0 = ccui.Helper:seekNodeByName(ui.Widget, "btn_two_0")

    local buttons = { btn_eight, btn_four, btn_two, btn_two_0 }

    reportViewItem = ccui.Helper:seekNodeByName(ui.Widget, "image_info")
    reportViewItem:retain()

    local indexNames = { "①", "②", "③", "④" }

    for i, name in ipairs(UIWar.BATTLE_FIELD_NAMES) do
        local text_battlefield = reportViewItem:getChildByName("text_battlefield" .. i)
        text_battlefield:setString(indexNames[i] .. " " .. name)
    end

    rewardViewItem = ccui.Helper:seekNodeByName(ui.Widget, "image_reward")
    rewardViewItem:retain()

    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            audio.playSound("sound/button.mp3")
            if sender == btn_close then
                UIManager.popScene()
            elseif not ui.selectIndex or sender ~= buttons[ui.selectIndex] then
                for i, button in ipairs(buttons) do
                    if button == sender then
                        button:loadTextureNormal("ui/yh_btn02.png")
                        button:getChildren()[1]:setTextColor(cc.c3b(0x33, 0x19, 0x04))
                        if ui.selectIndex ~= i then
                            ui.selectIndex = i
                            ui.setup(i)
                        end
                    else
                        button:loadTextureNormal("ui/yh_btn01.png")
                        button:getChildren()[1]:setTextColor(display.COLOR_WHITE)
                    end
                end
            end
        end
    end

    btn_close:addTouchEventListener(onButtonEvent)
    btn_eight:addTouchEventListener(onButtonEvent)
    btn_four:addTouchEventListener(onButtonEvent)
    btn_two:addTouchEventListener(onButtonEvent)
    btn_two_0:addTouchEventListener(onButtonEvent)
end

local function setReportViewItem(item, data)
    local sides = { "blue", "red" }

    for i, side in ipairs(sides) do
        local text_name = item:getChildByName("text_name_" .. side)
        local text_number = item:getChildByName("text_number_" .. side)

        local visible = data[i].allianceName ~= ""
        local points = 0
        for k = 1, 4 do
            local text_integral = item:getChildByName("text_integral" .. k .. "_" .. side)
            text_integral:setVisible(visible)
            if visible then
                text_integral:setString(i == 1 and tostring(data[i].points[k]) or string.format(" :  %d", data[i].points[k]))
                points = points + data[i].points[k]
            end
        end

        text_name:setVisible(visible)
        text_number:setVisible(visible)
        if visible then
            text_name:setString(data[i].allianceName)
            text_number:setString(Lang.ui_war_list12 .. points)
        end
    end

    local text_title = item:getChildByName("text_title")
    local text_mvp = item:getChildByName("text_mvp")
    if string.len(data[1].mvp) > 0 then
        text_title:setString(data[1].mvp)
        text_title:setTextColor(cc.c3b(0x00, 0xF5, 0xFF))
        text_mvp:setTextColor(cc.c3b(0x00, 0xF5, 0xFF))
    else
        text_title:setString(data[2].mvp)
        text_title:setTextColor(cc.c3b(0xFF, 0x0B, 0x00))
        text_mvp:setTextColor(cc.c3b(0xFF, 0x0B, 0x00))
    end
end

local function setRewardViewItem(item, data)
    local name
    if type(data) == "table" then
        name = data.name or ""
        data = utils.stringSplit(data.reward or "", ";")
    else
        name = ui.NAMES[item:getTag()] or ""
        data = utils.stringSplit(data or "", ";")
    end

    local text_title = item:getChildByName("image_base_hint"):getChildByName("text_title")
    text_title:setString(name)

    for i = 1, 4 do
        local image_frame_good = item:getChildByName("image_frame_good" .. i)
        if data[i] then
            image_frame_good:show()
            local itemProp = utils.getItemProp(data[i])

            local image_good = image_frame_good:getChildByName("image_good")
            local text_name = image_frame_good:getChildByName("text_name")
            local text_number = image_frame_good:getChildByName("image_base_number"):getChildByName("text_number")

            text_number:setString(itemProp.count)
            text_name:setString(itemProp.name)
            utils.addBorderImage(itemProp.tableTypeId, itemProp.tableFieldId, image_frame_good)
            image_good:loadTexture(itemProp.smallIcon)
            utils.showThingsInfo(image_frame_good, itemProp.tableTypeId, itemProp.tableFieldId)
        else
            image_frame_good:hide()
        end
    end
end

function ui.setup(index)
    local view_card = ccui.Helper:seekNodeByName(ui.Widget, "view_card")
    view_card:removeAllChildren()
    if ui.showType == ui.SHOW_TYPE.report then
        utils.updateScrollView(ui, view_card, reportViewItem, ui.report[index or 1], setReportViewItem, { space = 4 })
    elseif ui.showType == ui.SHOW_TYPE.reward then
        utils.updateScrollView(ui, view_card, rewardViewItem, ui.reward[index or 1], setRewardViewItem, { setTag = true })
    end
end

function ui.showReport()
    ui.showType = ui.SHOW_TYPE.report
    UIManager.pushScene("ui_war_list")
    local btn_two_0 = ccui.Helper:seekNodeByName(ui.Widget, "btn_two_0"):show()
    local btn_two = ccui.Helper:seekNodeByName(ui.Widget, "btn_two")
    btn_two:getChildren()[1]:setString(Lang.ui_war_list13)
end

function ui.showReward()
    ui.showType = ui.SHOW_TYPE.reward
    UIManager.pushScene("ui_war_list")
    local btn_two_0 = ccui.Helper:seekNodeByName(ui.Widget, "btn_two_0"):hide()
    local btn_two = ccui.Helper:seekNodeByName(ui.Widget, "btn_two")
    btn_two:getChildren()[1]:setString(Lang.ui_war_list14)
end

function ui.free()
    if reportViewItem and reportViewItem:getReferenceCount() >= 1 then
        reportViewItem:release()
        reportViewItem = nil
    end
    if rewardViewItem and rewardViewItem:getReferenceCount() >= 1 then
        rewardViewItem:release()
        rewardViewItem = nil
    end
    ui.showType = nil
    ui.selectIndex = nil
end

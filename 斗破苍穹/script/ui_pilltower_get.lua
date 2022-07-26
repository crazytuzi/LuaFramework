require"Lang"
UIPilltowerGet = {}

local userData = nil

function UIPilltowerGet.init()
    local image_basemap = UIPilltowerGet.Widget:getChildByName("image_basemap")
    local btn_sure = image_basemap:getChildByName("btn_sure")
    btn_sure:setPressedActionEnabled(true)
    btn_sure:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            UIManager.popScene()
            if userData.callback then
                userData.callback()
            end
        end
    end)
end

function UIPilltowerGet.setup()
    local image_basemap = UIPilltowerGet.Widget:getChildByName("image_basemap")
    local title = image_basemap:getChildByName("text_get")
    if userData.pointId == 0 then
        title:setString(Lang.ui_pilltower_get1)
    else
        title:setString(string.format(Lang.ui_pilltower_get2, userData.pointId))
    end
    local _things = utils.stringSplit(userData.things, ";")
    for i = 1, 3 do
        local item_frame = image_basemap:getChildByName("image_frame_good"..i)
        if _things[i] then
            local itemProps = utils.getItemProp(_things[i])
            local item_icon = item_frame:getChildByName("image_good")
            local item_flag = item_icon:getChildByName("image_type")
            local item_nums = item_frame:getChildByName("num")
            local item_name = ccui.Helper:seekNodeByName(item_frame, "text_name")
            if itemProps.frameIcon then
                item_frame:loadTexture(itemProps.frameIcon)
            end
            if itemProps.smallIcon then
                item_icon:loadTexture(itemProps.smallIcon)
            end
            if itemProps.name then
                item_name:setString(itemProps.name)
            end
            if itemProps.flagIcon then
                item_flag:loadTexture(itemProps.flagIcon)
                item_flag:setVisible(true)
            else
                item_flag:setVisible(false)
            end
            if itemProps.count > 1 then
                item_nums:setVisible(true)
                item_nums:setString("x"..itemProps.count)
            else
                item_nums:setVisible(false)
            end
        else
            item_frame:setVisible(false)
        end
    end
end

function UIPilltowerGet.free()
    userData = nil
end

function UIPilltowerGet.show(_tableParams)
    userData = _tableParams
    UIManager.pushScene("ui_pilltower_get")
end

require"Lang"
UIBossPreview = { }

local ui_svItem = nil

local function setScrollViewItem(item, data)
    data = utils.stringSplit(data, "|")

    local image_base_ranking = item:getChildByName("image_base_ranking")
    local text_ranking = image_base_ranking:getChildByName("text_ranking")

    image_base_ranking:loadTexture("ui/lj_hd.png")
    text_ranking:setString(string.format(Lang.ui_boss_preview1, data[2]))
    if data[2] ~= data[1] then
        text_ranking:setString(string.format(Lang.ui_boss_preview2, data[2], data[1]))
    elseif data[2] == "0" then
        text_ranking:setString(Lang.ui_boss_preview3)
        image_base_ranking:loadTexture("ui/ld_tmd.png")
    end

    local things = utils.stringSplit(data[3] or "", ";")
    local children = item:getChildren()

    for i = 2, #children do
        local child = children[i]
        if things[i - 1] then
            child:show()
            local itemProp = utils.getItemProp(things[i - 1])
            local childs = child:getChildren()
            utils.addBorderImage(itemProp.tableTypeId, itemProp.tableFieldId, child)
            childs[1]:loadTexture(itemProp.smallIcon)
            childs[2]:setString(string.format("%s×%d", itemProp.name, itemProp.count))
            utils.showThingsInfo(child, itemProp.tableTypeId, itemProp.tableFieldId)
        else
            child:hide()
        end
    end
end

function UIBossPreview.init()
    local btn_close = ccui.Helper:seekNodeByName(UIBossPreview.Widget, "btn_close")
    local btn_sure = ccui.Helper:seekNodeByName(UIBossPreview.Widget, "btn_sure")
    btn_close:setPressedActionEnabled(true)
    btn_sure:setPressedActionEnabled(true)
    local function onTouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioEngine.playEffect("sound/button.mp3")
            if sender == btn_close or sender == btn_sure then
                UIManager.popScene()
            end
        end
    end
    btn_close:addTouchEventListener(onTouchEvent)
    btn_sure:addTouchEventListener(onTouchEvent)

    local scrollView = ccui.Helper:seekNodeByName(UIBossPreview.Widget, "view_ranking")
    ui_svItem = scrollView:getChildByName("image_ranking"):clone()
    ui_svItem:retain()
end

function UIBossPreview.setup()
    local reward = UIBossPreview.reward or ""
    reward = utils.stringSplit(reward, "/")

    local scrollView = ccui.Helper:seekNodeByName(UIBossPreview.Widget, "view_ranking")
    scrollView:removeAllChildren()
    utils.updateScrollView(UIBossPreview, scrollView, ui_svItem, reward, setScrollViewItem, { space = 10 })
end

function UIBossPreview.free()
    local scrollView = ccui.Helper:seekNodeByName(UIBossPreview.Widget, "view_ranking")
    scrollView:removeAllChildren()
    if ui_svItem and ui_svItem:getReferenceCount() >= 1 then
        ui_svItem:release()
        ui_svItem = nil
    end
end

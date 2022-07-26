require"Lang"
UIActivityTower = { }

local scrollView = nil
local sv_item = nil

local ui_fight = nil
local ui_gold = nil
local ui_money = nil

local _activitys = {
    { name = "ui_tower_test", openLv = DictFunctionOpen[tostring(StaticFunctionOpen.tower)].level },
    { name = "ui_loot", openLv = DictFunctionOpen[tostring(StaticFunctionOpen.skillChipMerge)].level },
    { name = "ui_arena", openLv = DictFunctionOpen[tostring(StaticFunctionOpen.area)].level },
    { name = "ui_ore", openLv = DictFunctionOpen[tostring(StaticFunctionOpen.mine)].level },
    { name = "ui_pilltower", openLv = DictFunctionOpen[tostring(StaticFunctionOpen.danta)].level },
    { name = "ui_boss", openLv = DictFunctionOpen[tostring(StaticFunctionOpen.worldBoss)].level },
    { name = "ui_game", openLv = DictFunctionOpen[tostring(StaticFunctionOpen.pk3v3)].level },
}

function UIActivityTower.checkOpenLv(name)
    for key, obj in pairs(_activitys) do
        if obj.name == name then
            return obj.openLv
        end
    end
end

function UIActivityTower.init()
    local ui_image_base_title = ccui.Helper:seekNodeByName(UIActivityTower.Widget, "image_base_title")
    ui_fight = ccui.Helper:seekNodeByName(ui_image_base_title, "label_fight")
    ui_gold = ccui.Helper:seekNodeByName(ui_image_base_title, "text_gold_number")
    ui_money = ccui.Helper:seekNodeByName(ui_image_base_title, "text_silver_number")

    scrollView = ccui.Helper:seekNodeByName(UIActivityTower.Widget, "view_activity")
    sv_item = scrollView:getChildByName("image_tower"):clone()
end

function UIActivityTower.setup()
    ui_fight:setString(tostring(utils.getFightValue()))
    ui_gold:setString(tostring(net.InstPlayer.int["5"]))
    ui_money:setString(net.InstPlayer.string["6"])
    if sv_item:getReferenceCount() == 1 then
        sv_item:retain()
    end
    scrollView:removeAllChildren()
    local innerHeight, space = 0, 20
    for key, obj in pairs(_activitys) do
        local scrollViewItem = sv_item:clone()
        local function scrollViewItemEvent(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if net.InstPlayer.int["4"] < obj.openLv then
                    UIManager.showToast(Lang.ui_activity_tower1 .. obj.openLv .. Lang.ui_activity_tower2)
                    return
                end
                if obj.name == "ui_loot" then
                    local lootOpen = false
                    if net.InstPlayerBarrier then
                        for key, obj in pairs(net.InstPlayerBarrier) do
                            if obj.int["3"] == 20 then
                                -- 17关开启
                                lootOpen = true
                                break;
                            end
                        end
                    end
                    if lootOpen then
                        UILoot.show(1, 1)
                    else
                        UIManager.showToast(Lang.ui_activity_tower3)
                        return
                    end
                elseif obj.name == "ui_ore" or obj.name == "ui_game" then
                    UIManager.hideWidget("ui_menu")
                    UIManager.showWidget(obj.name)
                else
                    UIManager.showWidget(obj.name)
                end
            end
        end
        scrollViewItem:loadTexture("ui/" .. obj.name .. ".png")
        scrollViewItem:addTouchEventListener(scrollViewItemEvent)
        scrollView:addChild(scrollViewItem)
        innerHeight = innerHeight + scrollViewItem:getContentSize().height + space
        if obj.name == "ui_tower_test" and net.InstPlayer.int["4"] >= obj.openLv then
            utils.addImageHint(UITowerTest.checkImageHint(), scrollViewItem, 100, 20, 10)
        end
        if obj.name == "ui_boss" and net.InstPlayer.int["4"] >= obj.openLv then
            utils.addImageHint(UIBoss.checkImageHint(), scrollViewItem, 100, 20, 10)
        end
        if obj.name == "ui_pilltower" and net.InstPlayer.int["4"] >= obj.openLv then
            utils.addImageHint(UIPilltower.checkImageHint(), scrollViewItem, 100, 20, 10)
        end
    end

    if innerHeight < scrollView:getContentSize().height then
        innerHeight = scrollView:getContentSize().height
    end
    scrollView:setInnerContainerSize(cc.size(scrollView:getContentSize().width, innerHeight))
    local childs = scrollView:getChildren()
    local prevChild = nil
    for i = 1, #childs do
        if i == 1 then
            childs[i]:setPosition(cc.p(scrollView:getContentSize().width / 2, scrollView:getInnerContainerSize().height - childs[i]:getContentSize().height / 2 - space))
        else
            childs[i]:setPosition(cc.p(scrollView:getContentSize().width / 2, prevChild:getBottomBoundary() - childs[i]:getContentSize().height / 2 - space))
        end
        prevChild = childs[i]
    end

    local innerHeight = scrollView:getInnerContainerSize().height
    local max = innerHeight - scrollView:getContentSize().height
    for i, child in ipairs(childs) do
        local thumb =(i - 1) *(child:getContentSize().height + 20)
        local percent = 100 * math.min(1, math.max(0, thumb / max))

        if _activitys[i].name == "ui_tower_test" and UIGuidePeople.levelStep == guideInfo["28_1"].step then
            scrollView:jumpToPercentVertical(percent)
            UIGuidePeople.isGuide(child, UIActivityTower)
            break
        elseif _activitys[i].name == "ui_loot" and UIGuidePeople.guideStep then
            scrollView:jumpToPercentVertical(percent)
            UIGuidePeople.isGuide(child, UIActivityTower)
            break
        elseif _activitys[i].name == "ui_arena" and UIGuidePeople.levelStep == guideInfo["11_1"].step then
            scrollView:jumpToPercentVertical(percent)
            UIGuidePeople.isGuide(child, UIActivityTower)
            break
        elseif _activitys[i].name == "ui_pilltower" and UIGuidePeople.levelStep == guideInfo["32_1"].step then
            scrollView:jumpToPercentVertical(percent)
            UIGuidePeople.isGuide(child, UIActivityTower)
            break
        elseif _activitys[i].name == "ui_ore" and UIGuidePeople.levelStep == guideInfo["22_1"].step then
            scrollView:jumpToPercentVertical(percent)
            UIGuidePeople.isGuide(child, UIActivityTower)
            break
        end
    end

    if not UIGuidePeople.guideFlag then
        ActionManager.ScrollView_SplashAction(scrollView)
    end
    UIMenu.showTowerHint()
end

require"Lang"
UIFightUpgrade={}
function UIFightUpgrade.init()
    local btn_sure = ccui.Helper:seekNodeByName(UIFightUpgrade.Widget, "btn_sure")
    local btn_athletics = ccui.Helper:seekNodeByName(UIFightUpgrade.Widget, "image_jjc") --- 竞技
    local btn_treasure = ccui.Helper:seekNodeByName(UIFightUpgrade.Widget, "image_loot") ---夺宝
    local function TouchEvent(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioEngine.playEffect("sound/button.mp3")
            if sender == btn_athletics then 
                UIManager.showScreen("ui_notice","ui_activity_tower", "ui_menu")
            elseif sender == btn_treasure then 
                UIManager.showScreen("ui_notice","ui_activity_tower", "ui_menu")
            elseif sender == btn_sure then 
                UIManager.popScene()
            end
        end
    end
    btn_sure:setPressedActionEnabled(true)
    btn_sure:addTouchEventListener(TouchEvent)
    btn_athletics:addTouchEventListener(TouchEvent)
    btn_treasure:addTouchEventListener(TouchEvent)
end



local function showToast(msg)
    local toast_bg = ccui.ImageView:create()
    toast_bg:loadTexture("image/toast_bg.png")
    toast_bg:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2))
    local text = ccui.Text:create()
    text:setFontName(dp.FONT)
    text:setString(msg)
    text:setFontSize(40)
    text:setTextColor(cc.c4b(255, 0, 0, 255))
    text:setPosition(cc.p(toast_bg:getContentSize().width / 2, toast_bg:getContentSize().height / 2))
    toast_bg:addChild(text)
    UIManager.gameLayer:addChild(toast_bg, 100)
    toast_bg:retain()
    local function hideToast()
        if toast_bg then
            UIManager.gameLayer:removeChild(toast_bg, true)
            cc.release(toast_bg)
        end
    end
    toast_bg:runAction(cc.Sequence:create(cc.MoveBy:create(0.3, cc.p(0, 60)), cc.DelayTime:create(1),cc.MoveBy:create(0.3, cc.p(0, 60)),cc.CallFunc:create(hideToast)))
end

function UIFightUpgrade.setup()
    local ui_nowLevel = ccui.Helper:seekNodeByName(UIFightUpgrade.Widget, "label_lv_before")
    local ui_nextLevel = ccui.Helper:seekNodeByName(UIFightUpgrade.Widget, "label_lv_after")
    local ui_label_power_before = ccui.Helper:seekNodeByName(UIFightUpgrade.Widget, "label_power_before")
    local ui_label_power_after = ccui.Helper:seekNodeByName(UIFightUpgrade.Widget, "label_power_after")
    local ui_label_inlay_before = ccui.Helper:seekNodeByName(UIFightUpgrade.Widget, "label_population_before")
    local ui_label_inlay_after = ccui.Helper:seekNodeByName(UIFightUpgrade.Widget, "label_population_after")
    local ui_label_stamina_before = ccui.Helper:seekNodeByName(UIFightUpgrade.Widget, "label_stamina_before")
    local ui_label_stamina_after = ccui.Helper:seekNodeByName(UIFightUpgrade.Widget, "label_stamina_after")
    ui_nowLevel:setString(tostring(utils.beforeLevel))
    ui_nextLevel:setString(tostring(net.InstPlayer.int["4"]))
    local nowLevelInlay = DictLevelProp[tostring(utils.beforeLevel)].inTeamCard
    local nextLevelInlay = DictLevelProp[tostring(net.InstPlayer.int["4"])].inTeamCard
    local silver_number = DictLevelProp[tostring(net.InstPlayer.int["4"])].copper
    local gold_number = DictLevelProp[tostring(net.InstPlayer.int["4"])].gold
    local after_energy = net.InstPlayer.int["8"]
    local before_energy = after_energy - DictLevelProp[tostring(net.InstPlayer.int["4"])].energy
    local after_vigor = net.InstPlayer.int["10"]
    local before_vigor =after_vigor - DictLevelProp[tostring(net.InstPlayer.int["4"])].vigor
    ui_label_inlay_before:setString(nowLevelInlay)
    ui_label_inlay_after:setString(nextLevelInlay)
    if nextLevelInlay > nowLevelInlay then 
        showToast(Lang.ui_fight_upgrade1)
    end
    ui_label_power_before:setString(before_energy)
    ui_label_power_after:setString(after_energy)
    ui_label_stamina_before:setString(before_vigor)
    ui_label_stamina_after:setString(after_vigor)
    local btn_athletics = ccui.Helper:seekNodeByName(UIFightUpgrade.Widget, "image_jjc") --- 竞技
    local btn_treasure = ccui.Helper:seekNodeByName(UIFightUpgrade.Widget, "image_loot") ---夺宝
    local btn_sure = ccui.Helper:seekNodeByName(UIFightUpgrade.Widget, "btn_sure")
    if UIGuidePeople.guideStep or UIGuidePeople.levelStep then 
        btn_athletics:setEnabled(false)
        btn_treasure:setEnabled(false)
        btn_sure:setEnabled(false)
        local btn_sure = ccui.Helper:seekNodeByName(UIFightUpgrade.Widget, "btn_sure")
        UIGuidePeople.addGuideUI(UIFightUpgrade,btn_sure,0)
    else 
        btn_athletics:setEnabled(true)
        btn_treasure:setEnabled(true)
        btn_sure:setEnabled(true)
    end
end

function UIFightUpgrade.onEnter()
    if UIFightWin.Widget then 
        local btn_sure = ccui.Helper:seekNodeByName(UIFightWin.Widget, "btn_sure")
        local btn_again = ccui.Helper:seekNodeByName(UIFightWin.Widget, "btn_again")
        utils.GrayWidget(btn_sure,false)
        utils.GrayWidget(btn_again,false)
    end
end

function UIFightUpgrade.free()
    if UIFightWin.Widget then 
        if (UIGuidePeople.guideStep or UIGuidePeople.levelStep) and UIFightWin.Widget:getParent() then 
            local btn_sure = ccui.Helper:seekNodeByName(UIFightWin.Widget, "btn_sure")
            UIGuidePeople.addGuideUI(UIFightWin,btn_sure,0)
        else 
            UIFightWin.Widget:setEnabled(true)
        end
    end
    if UIFightClearing.Widget and UIFightClearing.Widget:getParent() then 
        UIFightClearing.Widget:setEnabled(true)
        if utils.LevelUpgrade then 
            UIFightClearing.LevelUpgrade = true
        end
    end
    utils.LevelUpgrade =false
end

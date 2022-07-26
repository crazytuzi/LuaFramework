require"Lang"
UITowerWinSmall = { }

local isPass = false -- 是否通过

function UITowerWinSmall.init()
    local image_basemap = UITowerWinSmall.Widget:getChildByName("image_basemap")
    local btn_sure = image_basemap:getChildByName("btn_sure")
    btn_sure:setPressedActionEnabled(true)
    btn_sure:addTouchEventListener( function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local userData = UITowerWinSmall.userData
            if userData.fightType == dp.FightType.FIGHT_PILL_TOWER then
                if sender:getTitleText() == Lang.ui_tower_win_small1 then
                    -- UIManager.showScreen("ui_notice", "ui_activity_tower", "ui_menu")
                    UIManager.showScreen("ui_notice","ui_team_info", "ui_homepage","ui_menu")
                    -- UIMenu.onHomepage()
                else
                    UIManager.showScreen("ui_notice", "ui_pilltower", "ui_menu")
                end
                --  if userData.isWin then
                --      UIManager.showScreen("ui_notice", "ui_pilltower", "ui_menu")
                --  else
                --      UIManager.showScreen("ui_notice", "ui_activity_tower", "ui_menu")
                --  end
            elseif userData.fightType == dp.FightType.FIGHT_MINE or userData.fightType == dp.FightType.FIGHT_UNION_REPLAY then
                userData.callbackfunc()
            else
                local dictPagodaStoreyData = DictPagodaStorey[tostring(userData[1])]
                -- 塔层字典数据
                local pagodaFormationData = DictPagodaFormation[tostring(dictPagodaStoreyData.pagodaFormationId)]
                -- 塔阵字典数据
                if userData[1] ~= pagodaFormationData.pagodaStorey6 then
                    UITowerTest.isWin(isPass)
                end
                UIManager.showScreen("ui_notice", "ui_tower_test", "ui_menu")
            end
        end
    end )
end

function UITowerWinSmall.setup()
    local image_basemap = UITowerWinSmall.Widget:getChildByName("image_basemap")
    local image_base_name = image_basemap:getChildByName("image_base_name")
    local ui_titleName = ccui.Helper:seekNodeByName(image_base_name, "text_fight_name")
    local ui_moneyNum = ccui.Helper:seekNodeByName(image_basemap, "text_silver_number")
    -- 银币
    local ui_fireNum = ccui.Helper:seekNodeByName(image_basemap, "text_fire_number")
    -- 火能
    local ui_fighterNum = ccui.Helper:seekNodeByName(image_base_name, "label_zhan")
    -- 战力
    ui_fighterNum:setString(utils.getFightValue())
    -- 战力
    
    local userData = UITowerWinSmall.userData
    if userData.fightType == dp.FightType.FIGHT_PILL_TOWER then
        if not userData.isWin then
            utils.GrayWidget(image_basemap:getChildByName("image_basedi"), true)
        end
        ui_moneyNum:getParent():setVisible(false)
        ui_fireNum:getParent():setVisible(false)
        local armature = ActionManager.getUIAnimation(userData.isWin and 11 or 12)
        armature:setPosition(cc.p(320, 760))
        UITowerWinSmall.Widget:addChild(armature, 100, 100)
        ui_titleName:setString(Lang.ui_tower_win_small2 .. userData.curFightPoint .. Lang.ui_tower_win_small3)
        local image_get_di = image_basemap:getChildByName("image_get_di")
        image_get_di:setVisible(true)
        local item_frame = image_get_di:getChildByName("image_frame_good")
        local ui_textHint = image_get_di:getChildByName("text_hint")
        if userData.awardThings and userData.awardThings ~= "" then
        elseif userData.awardThings == "" then
        end
        if userData.isWin then
            if userData.awardThings == nil or userData.awardThings == "" then
                item_frame:setVisible(false)
                ui_textHint:setString(Lang.ui_tower_win_small4)
            else
                ui_textHint:setVisible(false)
                local itemProps = utils.getItemProp(userData.awardThings)
                if itemProps.frameIcon then
                    item_frame:loadTexture(itemProps.frameIcon)
                end
                if itemProps.smallIcon then
                    item_frame:getChildByName("image_good"):loadTexture(itemProps.smallIcon)
                end
                if itemProps.name then
                    item_frame:getChildByName("text_name"):setString(itemProps.name)
                end
                item_frame:getChildByName("text_number"):setString("×" .. itemProps.count)
                item_frame:setVisible(true)
            end
        else
            item_frame:setVisible(false)
            local btn_sure = image_basemap:getChildByName("btn_sure")
            if UIPilltower.UserData.challengeNums == 0 then
                btn_sure:setTitleText(Lang.ui_tower_win_small5)
                ui_textHint:setString(Lang.ui_tower_win_small6)
            else
                btn_sure:setTitleText(Lang.ui_tower_win_small7)
                ui_textHint:setString(Lang.ui_tower_win_small8)
            end
        end
    elseif userData.fightType == dp.FightType.FIGHT_MINE or userData.fightType == dp.FightType.FIGHT_UNION_REPLAY then
        if not userData.isWin then
            utils.GrayWidget(image_basemap:getChildByName("image_basedi"), true)
        end
        image_base_name:hide()
        image_basemap:getChildByName("image_base_silver"):hide()
        image_basemap:getChildByName("image_base_fire"):hide()
        image_basemap:getChildByName("image_get_di"):hide()
        image_basemap:getChildByName("text_info"):show():setString(userData.info)
        image_basemap:addChild(userData.animation)
        userData.animation:setPosition(image_basemap:getContentSize().width / 2, image_basemap:getContentSize().height)
    else
        local _dictId = userData[1]
        -- 塔层字典ID
        local _victoryValue = userData[2]
        -- 通关条件值
        local _thingId = userData[3]
        -- 神秘层掉落表的Id(DictPagodaDrop)
        local dictPagodaStoreyData = DictPagodaStorey[tostring(userData[1])]
        -- 塔层字典数据
        local pagodaFormationData = DictPagodaFormation[tostring(dictPagodaStoreyData.pagodaFormationId)]
        -- 塔阵字典数据

        ui_moneyNum:getParent():setVisible(true)
        ui_fireNum:getParent():setVisible(true)
        ui_moneyNum:setString("x" .. dictPagodaStoreyData.copper)
        -- 银币
        ui_fireNum:setString("x" .. dictPagodaStoreyData.culture)
        -- 火能

        local armature = ActionManager.getUIAnimation(11)
        armature:setPosition(cc.p(320, 760))
        UITowerWinSmall.Widget:addChild(armature, 100, 100)

        if _dictId == pagodaFormationData.pagodaStorey6 then
            ui_titleName:setString(Lang.ui_tower_win_small9)
        else
            ui_titleName:setString(Lang.ui_tower_win_small10 .. _dictId .. Lang.ui_tower_win_small11)
        end
        isPass = false
        if _dictId == pagodaFormationData.pagodaStorey6 then
            if _thingId then
                -- initScrollView(_thingId, true)
            end
        else
            if dictPagodaStoreyData.victoryMeans == 1 then
                -- 战斗回合数不超过
                if _victoryValue <= dictPagodaStoreyData.victoryValue then
                    isPass = true
                end
            elseif dictPagodaStoreyData.victoryMeans == 2 then
                -- 死亡卡牌数不超过
                if _victoryValue <= dictPagodaStoreyData.victoryValue then
                    isPass = true
                end
            elseif dictPagodaStoreyData.victoryMeans == 3 then
                -- 战斗结束后血量不少于%
                if _victoryValue >= dictPagodaStoreyData.victoryValue then
                    isPass = true
                end
            elseif dictPagodaStoreyData.victoryMeans == 4 then
                -- 消灭全部敌人
                if _victoryValue == 0 then
                    isPass = true
                end
            end

            if isPass then
                if _dictId == pagodaFormationData.pagodaStorey5 then
                    -- initScrollView(pagodaFormationData.reward)
                end
                -- UIManager.showToast("通过~")
            else
                -- UIManager.showToast("未通过~")
            end
        end
    end
end

function UITowerWinSmall.setParam(param)
    UITowerWinSmall.userData = param
end

function UITowerWinSmall.free()
    UITowerWinSmall.userData = nil
end

function UITowerWinSmall.show(_tableParams)
    UITowerWinSmall.userData = _tableParams
    UIManager.pushScene("ui_tower_win_small")
end

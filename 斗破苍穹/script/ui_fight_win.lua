require"Lang"
UIFightWin = { }

local scrollView = nil
local ui_expBar = nil
local sv_item = nil
local _fightType = nil -- 战斗类型
UIFightWin._customParam = nil -- 自定义参数

local function setScrollViewItem(item, obj)
    local thingIcon = item:getChildByName("image_good")
    local thingName = thingIcon:getChildByName("text_name")
    local thingCount = ccui.Helper:seekNodeByName(item, "text_number")
    local name, icon = utils.getDropThing(obj.tableTypeId, obj.tableFieldId)
    thingName:setString(name)
    thingIcon:loadTexture(icon)
    if tonumber(obj.tableTypeId) ~= StaticTableType.DictCard then
        thingCount:setString(tostring(obj.num * obj.value))
    else
        thingCount:setString(tostring(obj.num))
    end
    utils.addBorderImage(obj.tableTypeId, obj.tableFieldId, item)
end

--- 此处提示拍卖场弹框---
function UIFightWin.pushMiteerHint()
    --[[
    for key, obj in pairs(net.SysActivity) do
		if obj.string["9"] == "auctionShop" then
			if net.InstActivity then
		        for _key,_obj  in pairs(net.InstActivity) do
		            if obj.int["1"] == _obj.int["3"] then
		                if  _obj.int["5"] ~= 1 then --白金
				          local serverTime =utils.getCurrentTime()
				          local starTime =utils.GetTimeByDate(_obj.string["4"])
				          local auctionShopTime = DictSysConfig[tostring(StaticSysConfig.auctionShopTime)].value --- 拍卖行有效时间
				          local endTime = starTime +auctionShopTime*3600
				          if serverTime < endTime and serverTime > starTime then
				          	if starTime ~= UIActivityMiteerHint.oldStarTime then
				          		UIActivityMiteerHint.oldStarTime = starTime
				          		UIManager.pushScene("ui_acticity_miteer_hint")
				          		return true
				          	end
				  		  end
		                end
		            end
		        end
	    	end
		end
    end
    --]]
    return false
end

----------显示意外获得界面--------------
local function showAccidentScene()
    local _customParam = UIFightWin._customParam
    if _customParam and(_customParam[2].int["2"] ~= nil or _customParam[2].string["2"] ~= nil) then
        if _customParam[2].int["2"] ~= nil then
            UIFightGetAccident.setParam(UIFightWin, _customParam[2].int["2"])
        elseif _customParam[2].string["2"] ~= nil then
            UIFightGetAccident.setParam(UIFightWin, _customParam[2].string["2"])
        end
        UIManager.pushScene("ui_fight_get_accident")
    end
end

-------确定按钮事件--------------
local function okBtnEvent()
    local _customParam = UIFightWin._customParam
    if _fightType == dp.FightType.FIGHT_TASK.COMMON then
        local taskStory = FightTaskInfo.getData(_customParam[1].chapterId, _customParam[1].barrierId)
        if taskStory and taskStory["middle"] and taskStory["middle"].flag == nil then
            taskStory["middle"].flag = true
        end
        UIFightTask.stopTaskAni = true
        UIManager.showScreen("ui_fight_task")
        if taskStory and taskStory["ended"] and taskStory["ended"].flag == nil then
            local function PlayStory()
                UIGuideInfo.PlayStory(taskStory, 1, "ended")
            end
            if (_customParam[2].int["2"] ~= nil or _customParam[2].string["2"] ~= nil) then
                UIFightGetAccident.setCallFunc(PlayStory)
                showAccidentScene()
            else
                PlayStory()
            end
        else
            local function flushFightTask()
                UIFightTask.stopTaskAni = nil
                UIManager.flushWidget(UIFightTask)
                UIGuidePeople.checkTaskGuide()
                UIFightTask.showPosterDialog()
            end
            if (_customParam[2].int["2"] ~= nil or _customParam[2].string["2"] ~= nil) then
                UIFightGetAccident.setCallFunc(flushFightTask)
                showAccidentScene()
            else
                flushFightTask()
            end
        end
    elseif _fightType == dp.FightType.FIGHT_TASK.ELITE then
        UIFight.setFlag(1)
        UIManager.showScreen("ui_notice", "ui_team_info", "ui_fight", "ui_menu")
        UIGuidePeople.checkLevelGuide()
        if UIFightPreView.wingTo then
            UIManager.showWidget("ui_notice", "ui_lineup")
            UIManager.showWidget("ui_menu")
            UILineup.toWingInfo()
        end
    elseif _fightType == dp.FightType.FIGHT_TASK.ACTIVITY then
        UIFight.setFlag(3)
        UIManager.showScreen("ui_notice", "ui_team_info", "ui_fight", "ui_menu")
        UIGuidePeople.checkLevelGuide()
        if UIFightActivityChoose.wingTo then
            UIManager.showWidget("ui_notice", "ui_lineup")
            UIManager.showWidget("ui_menu")
            UILineup.toWingInfo()
        end
    elseif _fightType == dp.FightType.FIGHT_WING then
        UIFight.setFlag(1,2)
        UIManager.showScreen("ui_notice", "ui_team_info", "ui_bag_wing", "ui_menu")
        -- UIGuidePeople.checkLevelGuide()
        -- if UIFightActivityChoose.wingTo then
        --     UIManager.showWidget("ui_notice", "ui_lineup")
        --     UIManager.showWidget("ui_menu")
        --     UILineup.toWingInfo()
        -- end
    end
end

------再战一次----------------
local function againFightEvent()
    local _customParam = UIFightWin._customParam
    if _fightType == dp.FightType.FIGHT_TASK.COMMON then
        ----判断卡牌背包------------
        local cardGrid = DictBagType[tostring(StaticBag_Type.card)].bagUpLimit
        if net.InstPlayerBagExpand then
            for key, obj in pairs(net.InstPlayerBagExpand) do
                if obj.int["3"] == StaticBag_Type.card then
                    cardGrid = obj.int["4"] + DictBagType[tostring(obj.int["3"])].bagUpLimit
                end
            end
        end
        local cardNumber = utils.getDictTableNum(net.InstPlayerCard)
        ----判断装备背包------------
        local equipGrid = DictBagType[tostring(StaticBag_Type.equip)].bagUpLimit
        if net.InstPlayerBagExpand then
            for key, obj in pairs(net.InstPlayerBagExpand) do
                if obj.int["3"] == StaticBag_Type.equip then
                    equipGrid = obj.int["4"] + DictBagType[tostring(obj.int["3"])].bagUpLimit
                end
            end
        end
        local equipNumber = utils.getDictTableNum(net.InstPlayerEquip)
        if cardNumber >= cardGrid then
            UIManager.showToast(Lang.ui_fight_win1)
            return
        elseif equipNumber >= equipGrid then
            UIManager.showToast(Lang.ui_fight_win2)
            return
        end
        local taskStory = FightTaskInfo.getData(_customParam[1].chapterId, _customParam[1].barrierId)
        if taskStory and taskStory["middle"] and taskStory["middle"].flag == nil then
            taskStory["middle"].flag = true
        end
        local barrierId = _customParam[1].barrierId
        local energy = DictBarrier[tostring(barrierId)].energy
        local barrierAllTimes = DictBarrier[tostring(barrierId)].fightNum
        local barrierTimes = 0
        if net.InstPlayerBarrier then
            for key, obj in pairs(net.InstPlayerBarrier) do
                if obj.int["3"] == barrierId then
                    barrierTimes = obj.int["4"]
                end
            end
        end
        if barrierTimes >= barrierAllTimes then
            UIManager.showToast(Lang.ui_fight_win3)
            return
        else
            if net.InstPlayer.int["8"] < energy then
                UIFightTaskChoose.checkPlayerEnergy()
                return
            end
        end
    elseif _fightType == dp.FightType.FIGHT_TASK.ELITE or _fightType == dp.FightType.FIGHT_WING then
        local eliteBarrierNum = 0
        if net.InstPlayerChapterType then
            for key, obj in pairs(net.InstPlayerChapterType) do
                if UIFight.selectedPickFlag == 2 then
                    if obj.int["3"] == 4 and obj.int["4"] then
                        eliteBarrierNum = obj.int["4"]
                    end
                else
                    if obj.int["3"] == 2 and obj.int["4"] then
                        eliteBarrierNum = obj.int["4"]
                    end
                end
            end
        end
        local EliteBarrierTimes = DictSysConfig[tostring(StaticSysConfig.chapterEliteNum)].value - eliteBarrierNum
        if EliteBarrierTimes == 0 then
            UIManager.showToast(Lang.ui_fight_win4)
            return
        end
    elseif _fightType == dp.FightType.FIGHT_TASK.ACTIVITY then
        local DictChapterObj = DictChapter[tostring(_customParam[1].chapterId)]
        local haveBarrierNum = 0
        local activityBarrierTimes = 0
        if net.InstPlayerChapter then
            for key, ActivityObj in pairs(net.InstPlayerChapter) do
                if ActivityObj.int["3"] == DictChapterObj.id then
                    haveBarrierNum = ActivityObj.int["4"]
                end
            end
        end
        activityBarrierTimes = DictChapterObj.fightNum - haveBarrierNum
        local VipNum = net.InstPlayer.int["19"]
        if VipNum >= 0 then
            local VipTime1 = 0
            if DictChapterObj.id == DictSysConfig[tostring(StaticSysConfig.slbz)].value then
                VipTime1 = DictVIP[tostring(VipNum + 1)].silverActivityChapterBuyTimes
            elseif DictChapterObj.id == DictSysConfig[tostring(StaticSysConfig.tsxc)].value then
                VipTime1 = DictVIP[tostring(VipNum + 1)].talentActivityChapterBuyTimes
            elseif DictChapterObj.id == DictSysConfig[tostring(StaticSysConfig.yhgt)].value then
                VipTime1 = DictVIP[tostring(VipNum + 1)].expActivityChapterBuyTimes
            elseif DictChapterObj.id == DictSysConfig[tostring(StaticSysConfig.wysm)].value then
                VipTime1 = DictVIP[tostring(VipNum + 1)].soulActivityChapterBuyTimes
            elseif DictChapterObj.id == DictSysConfig[tostring(StaticSysConfig.shcx)].value then
                VipTime1 = DictVIP[tostring(VipNum + 1)].wingChapterNum
            elseif DictChapterObj.id == DictSysConfig[tostring(StaticSysConfig.jxcl)].value then
                VipTime1 = DictVIP[tostring(VipNum + 1)].awareChapterNum
            end
            activityBarrierTimes = activityBarrierTimes + VipTime1
        end
        if activityBarrierTimes <= 0 then
            UIManager.showToast(Lang.ui_fight_win5)
            return
        end
    end
    UIManager.popScene()
    Fight.doFree()
    utils.sendFightData(_customParam[1], _fightType)
    UIFightMain.setup()
end

function UIFightWin.init()
    scrollView = ccui.Helper:seekNodeByName(UIFightWin.Widget, "view_get_good")
    sv_item = scrollView:getChildByName("image_frame_good"):clone()
    if sv_item:getReferenceCount() == 1 then
        sv_item:retain()
    end
    local btn_sure = ccui.Helper:seekNodeByName(UIFightWin.Widget, "btn_sure")
    local btn_again = ccui.Helper:seekNodeByName(UIFightWin.Widget, "btn_again")
    btn_sure:setPressedActionEnabled(true)
    btn_again:setPressedActionEnabled(true)
    local function btnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioEngine.playEffect("sound/button.mp3")
            if sender == btn_sure then
                UIManager.popScene()
                okBtnEvent()
            elseif sender == btn_again then
                againFightEvent()
            end
        end
    end
    btn_sure:addTouchEventListener(btnEvent)
    btn_again:addTouchEventListener(btnEvent)
end

function UIFightWin.setup()
    -- UIGuidePeople.guideStep = guideInfo["20B1"].step
    -- UIGuidePeople.newBarrier = true

    local _customParam = UIFightWin._customParam
    scrollView:removeAllChildren()
    local ui_image_base_di = ccui.Helper:seekNodeByName(UIFightWin.Widget, "image_shadow")
    -- 游戏币
    local ui_money = ccui.Helper:seekNodeByName(ui_image_base_di, "text_silver_number")
    local text_silver = ccui.Helper:seekNodeByName(ui_image_base_di, "text_silver")
    local image_sliver = ccui.Helper:seekNodeByName(ui_image_base_di, "image_sliver")
    -- 获得经验
    local ui_exp = ccui.Helper:seekNodeByName(ui_image_base_di, "text_exp_number")
    local ui_image_lv = ccui.Helper:seekNodeByName(ui_image_base_di, "image_lv")
    -- 等级
    local ui_level = ui_image_lv:getChildByName("label_lv")
    -- 经验条
    ui_expBar = ccui.Helper:seekNodeByName(ui_image_lv, "bar_lv")
    -- 当前战力
    local ui_curFight = ccui.Helper:seekNodeByName(ui_image_base_di, "label_zhan")
    -- 第几层
    local ui_fightName = ccui.Helper:seekNodeByName(UIFightWin.Widget, "text_fight_name")
    ui_curFight:setString(utils.getFightValue())
    local InstPlayerNowLevel = net.InstPlayer.int["4"]
    local nowExp = net.InstPlayer.int["7"]
    local ExpNowLevelValue = 0
    ui_level:setString(tostring(InstPlayerNowLevel))
    if DictLevelProp[tostring(InstPlayerNowLevel)] ~= nil then
        ExpNowLevelValue = DictLevelProp[tostring(InstPlayerNowLevel)].fleetExp
    end
    local number = 0
    local _number = nowExp / ExpNowLevelValue * 100
    if _number > 100 then
        number = 100
    else
        number = _number
    end
    -------进度条动画--------------
    local Percent = 0
    ui_expBar:setPercent(Percent)
    local function startPercentAnimal()
        if Percent < number then
            Percent = Percent + 1
            ui_expBar:setPercent(Percent)
            performWithDelay(ui_expBar, startPercentAnimal, 0.6 / number)
        end
    end
    startPercentAnimal()

    if _fightType == dp.FightType.FIGHT_TASK.ELITE or _fightType == dp.FightType.FIGHT_WING then
        text_silver:setTextColor(cc.c3b(231, 129, 231))
        text_silver:setString(Lang.ui_fight_win6)
        image_sliver:loadTexture("ui/small_hunyuan.png")
    else
        text_silver:setTextColor(cc.c3b(0xB0, 0xC4, 0xDE))
        text_silver:setString(Lang.ui_fight_win7)
        image_sliver:loadTexture("ui/yin.png")
    end

    if _fightType == dp.FightType.FIGHT_TASK.COMMON or _fightType == dp.FightType.FIGHT_TASK.ELITE or _fightType == dp.FightType.FIGHT_TASK.ACTIVITY or _fightType == dp.FightType.FIGHT_WING then
        local DictBarrierLevelId = _customParam[1].barrierLevelId
        local barrierId = DictBarrierLevel[tostring(DictBarrierLevelId)].barrierId
        local fightName = DictBarrier[tostring(barrierId)].name
        local culture = DictBarrierLevel[tostring(DictBarrierLevelId)].culture
        local copper = DictBarrierLevel[tostring(DictBarrierLevelId)].copper
        local barrierLevel = _customParam[1].levelId or DictBarrierLevel[tostring(DictBarrierLevelId)].level
        local soulSourceCount = 0
        ui_fightName:setString(fightName)

        local maxBarrierLevel = DictBarrierLevel[tostring(DictBarrierLevelId)].level
        if _fightType == dp.FightType.FIGHT_TASK.COMMON then
            ui_exp:setString(_customParam[2].int["3"])
        elseif _fightType == dp.FightType.FIGHT_TASK.ELITE or _fightType == dp.FightType.FIGHT_WING then
            if UIFight.selectedPickFlag == 2 then
                ui_exp:setString("0")
            else
                if utils.LevelUpgrade == true then
                    ui_exp:setString(DictLevelProp[tostring(utils.beforeLevel)].oneEliteWarExp)
                else
                    ui_exp:setString(DictLevelProp[tostring(InstPlayerNowLevel)].oneEliteWarExp)
                end
            end
        else
            ui_exp:setString("0")
        end
        local image_star = { }
        image_star[1] = ccui.Helper:seekNodeByName(UIFightWin.Widget, "image_star1")
        image_star[2] = ccui.Helper:seekNodeByName(UIFightWin.Widget, "image_star2")
        image_star[3] = ccui.Helper:seekNodeByName(UIFightWin.Widget, "image_star3")
        image_star[4] = ccui.Helper:seekNodeByName(UIFightWin.Widget, "image_star3_0")
        for i = 1, 4 do
            if i <= barrierLevel then
                image_star[i]:setVisible(false)
                image_star[i]:loadTexture(i == 4 and "ui/fight_win.png" or "ui/fb_xing.png")
            else
                image_star[i]:setVisible(true)
                image_star[i]:loadTexture(i == 4 and "ui/fight_win_h.png" or "ui/fb_xing1.png")
            end
            if i > maxBarrierLevel then
                image_star[i]:setVisible(false)
            end
        end
        ----星星的动画----------------
        local j = 0
        local function startAnimal()
            if j < barrierLevel then
                j = j + 1
                image_star[j]:setVisible(true)
                image_star[j]:setScale(6)
                image_star[j]:runAction(cc.Sequence:create(cc.ScaleTo:create(j == 4 and 0.2 or 0.4, 1), cc.CallFunc:create(startAnimal)))
            end
        end
        startAnimal()
        --- 掉落的物品--------------------
        local dropData = { }
        if _customParam[2] then
            local dropIds = { }
            if _customParam[2].string["1"] then
                dropIds = utils.stringSplit(_customParam[2].string["1"], ";")
                -- 副本获得掉落字典表ID
            end
            if _fightType == dp.FightType.FIGHT_TASK.COMMON then
                if _customParam[2].string["4"] then
                    local specialDropIds = utils.stringSplit(_customParam[2].string["4"], ";")
                    for key ,value in pairs( specialDropIds  ) do
                           table.insert( dropIds , value )
                    end
                end
            elseif _fightType == dp.FightType.FIGHT_TASK.ACTIVITY then
                if _customParam[2].string["2"] then
                    local specialDropIds = utils.stringSplit(_customParam[2].string["2"], ";")
                    for key ,value in pairs( specialDropIds  ) do
                           table.insert( dropIds , value )
                    end
                end
            end
            for key, id in pairs(dropIds) do
                local data = utils.stringSplit(id, "_")
                local flag = false
                if next(dropData) then
                    for _key, _obj in pairs(dropData) do
                        if _obj.id == id then
                            flag = true
                            _obj.num = _obj.num + 1
                        end
                    end
                end
                if flag == false then
                    local _data = { }
                    _data.id = id
                    _data.tableTypeId = data[1]
                    _data.tableFieldId = data[2]
                    _data.value = data[3]
                    _data.num = 1
                    table.insert(dropData, _data)
                end
            end

            if _fightType == dp.FightType.FIGHT_TASK.ELITE or _fightType == dp.FightType.FIGHT_WING then
                local key1, key2 = tostring(StaticTableType.DictThing), tostring(StaticThing.soulSource)

                for i, obj in ipairs(dropData) do
                    if obj.tableTypeId == key1 and obj.tableFieldId == key2 then
                        soulSourceCount = tonumber(obj.value) * obj.num
                        table.remove(dropData, i)
                        break
                    end
                end
            end

            for key, obj in pairs(dropData) do
                local scrollViewItem = sv_item:clone()
                scrollView:addChild(scrollViewItem)
                setScrollViewItem(scrollViewItem, obj)
            end
        end

        if _fightType == dp.FightType.FIGHT_TASK.ELITE or _fightType == dp.FightType.FIGHT_WING then
            ui_money:setString(tostring(soulSourceCount))
        else
            ui_money:setString(tostring(copper))
        end
    end

    local innerHeight, space, _col = 0, 0, 4
    local childs = scrollView:getChildren()
    if #childs < _col then
        innerHeight = sv_item:getContentSize().height + sv_item:getChildByName("image_good"):getChildByName("text_name"):getContentSize().height + space
    elseif #childs % _col == 0 then
        innerHeight =(#childs / _col) *(sv_item:getContentSize().height + sv_item:getChildByName("image_good"):getChildByName("text_name"):getContentSize().height + space) + space
    else
        innerHeight = math.ceil(#childs / _col) *(sv_item:getContentSize().height + sv_item:getChildByName("image_good"):getChildByName("text_name"):getContentSize().height + space) + space
    end
    if innerHeight < scrollView:getContentSize().height then
        innerHeight = scrollView:getContentSize().height
    end
    scrollView:setInnerContainerSize(cc.size(scrollView:getContentSize().width, innerHeight))

    local prevChild = nil
    local _tempI, x, y = 1, 0, 0
    for i = 1, #childs do
        x = _tempI *(scrollView:getContentSize().width / _col) -(scrollView:getContentSize().width / _col) / 2
        _tempI = _tempI + 1
        if i < _col then
            y = scrollView:getInnerContainerSize().height - childs[i]:getContentSize().height / 2 - space
            prevChild = childs[i]
            childs[i]:setPosition(cc.p(x, y))
        elseif i % _col == 0 then
            childs[i]:setPosition(cc.p(x, y))
            y = prevChild:getBottomBoundary() - prevChild:getChildByName("image_good"):getChildByName("text_name"):getContentSize().height - childs[i]:getContentSize().height / 2 - space
            _tempI = 1
            prevChild = childs[i]
        else
            y = prevChild:getBottomBoundary() - prevChild:getChildByName("image_good"):getChildByName("text_name"):getContentSize().height - childs[i]:getContentSize().height / 2 - space
            childs[i]:setPosition(cc.p(x, y))
        end
    end
    local btn_sure = ccui.Helper:seekNodeByName(UIFightWin.Widget, "btn_sure")
    local btn_again = ccui.Helper:seekNodeByName(UIFightWin.Widget, "btn_again")
    if not utils.LevelUpgrade then
        utils.GrayWidget(btn_sure, false)
        utils.GrayWidget(btn_again, false)
        if UIGuidePeople.guideStep or UIGuidePeople.levelStep then
            UIFightWin.Widget:setEnabled(false)
            UIGuidePeople.addGuideUI(UIFightWin, btn_sure, 0)
        else
            UIFightWin.Widget:setEnabled(true)
        end
    else
        UIFightWin.Widget:setEnabled(false)
        utils.GrayWidget(btn_sure, true)
        utils.GrayWidget(btn_again, true)
    end
end

-- @fightType : 战斗类型
-- @param : 自定义参数(格式由调用方自己定义)
function UIFightWin.setParam(fightType, param)
    _fightType = fightType
    UIFightWin._customParam = param
end

function UIFightWin.onEnter(...)
    AudioEngine.playEffect("sound/win.mp3")
    ----胜利界面的宝箱动画-------
    local animalLayer = ccui.Helper:seekNodeByName(UIFightWin.Widget, "animalLayer")
    local function FrameEventCallFunc(bone, eventName, originFrameIndex, currentFrameIndex)
        if eventName == "guang" then
            cc.SpriteFrameCache:getInstance():addSpriteFrames("ani/ui_anim/ui_anim10/ui_anim10.md")
            local image = ccui.ImageView:create("shop_07.png", ccui.TextureResType.plistType)
            image:setPosition(cc.p(325, 953))
            image:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, 180)))
            image:setScale(2.5)
            UIFightWin.Widget:addChild(image, 0, 100)
        end
    end

    local armature = ActionManager.getUIAnimation(11)
    armature:getAnimation():setFrameEventCallFunc(FrameEventCallFunc)
    armature:setPosition(cc.p(320, 465))
    animalLayer:addChild(armature)
    if utils.LevelUpgrade == true then
        local visibleSize = cc.Director:getInstance():getVisibleSize()
        local function FrameEventCallFunc(bone, eventName, originFrameIndex, currentFrameIndex)
            if eventName == "level" then
                UIManager.pushScene("ui_fight_upgrade")
            end
        end
        local function callbackFunc(armature)
            if armature:getParent() then armature:removeFromParent() end
            if not UIGuidePeople.guideStep and not UIGuidePeople.levelStep then
                local childs = UIManager.uiLayer:getChildren()
                for key, obj in pairs(childs) do
                    obj:setEnabled(true)
                end
            end
        end
        local armature = ActionManager.getUIAnimation(1, callbackFunc)
        armature:getAnimation():setSpeedScale(0.8)
        armature:getAnimation():setFrameEventCallFunc(FrameEventCallFunc)
        armature:setPosition(visibleSize.width / 2, visibleSize.height / 2);
        UIFightWin.Widget:addChild(armature, 100)
    end
end

function UIFightWin.free()
    if sv_item and sv_item:getReferenceCount() >= 1 then
        sv_item:release()
        sv_item = nil
    end
    if scrollView then
        scrollView:removeAllChildren()
        scrollView = nil
    end
    ui_expBar:stopAllActions()
    local animalLayer = ccui.Helper:seekNodeByName(UIFightWin.Widget, "animalLayer")
    animalLayer:removeAllChildren()
    if UIFightWin.Widget:getChildByTag(100) ~= nil then
        UIFightWin.Widget:removeChildByTag(100)
    end
end

require"Lang"
UIMenu = {
    Logined = nil,
}
-- xzli todo
local function getShopRecruitInfoFunc(pack)
    UIShop.setRecruitData(pack)
    UIShop.reset(1)
    UIManager.hideWidget("ui_activity_panel")
    UIManager.hideWidget("ui_activity_time")
    UIManager.hideWidget("ui_team_info")
    UIManager.hideWidget("ui_activity_purchase_manager")
    UIManager.showWidget("ui_notice", "ui_shop", "ui_menu")
    UIMenu.showMenuDot(pack)
end

function UIMenu.showMenuDot(_pack)
    local pack = nil
    if _pack.msgdata then
        pack = _pack.msgdata.message
    else
        -- 从shop界面返回
        pack = _pack
    end
    local recruitFreeTime = pack["1"].int["2"]
    local recruitTokenData = nil
    local recruitTokenNum = 0
    if net.InstPlayerThing then
        for key, obj in pairs(net.InstPlayerThing) do
            if StaticThing.recruitSign == obj.int["3"] then
                recruitTokenData = obj
            end
        end
    end
    if recruitTokenData ~= nil then
        recruitTokenNum = recruitTokenData.int["5"]
    end
    local ui_dot = ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_shop"):getChildByName("image_hint")
    --- 招募次数不为0 招募时间不为-1 或者招募令不为0
    if (pack["1"].long["1"] == 0 and recruitFreeTime ~= 0) or recruitTokenNum > 0 then
        ui_dot:setVisible(true)
    else
        ui_dot:setVisible(false)
    end

    if UIShop.Widget then
        if recruitTokenNum > 0 or(pack["1"].long["1"] == 0 and recruitFreeTime ~= 0) then
            ccui.Helper:seekNodeByName(UIShop.Widget, "image_hint"):setVisible(true)
        else
            ccui.Helper:seekNodeByName(UIShop.Widget, "image_hint"):setVisible(false)
        end
        if pack["3"].long["1"] == 0 then
            ccui.Helper:seekNodeByName(UIShop.Widget, "image_hint_1"):setVisible(true)
        else
            ccui.Helper:seekNodeByName(UIShop.Widget, "image_hint_1"):setVisible(false)
        end
    end
    UIGuidePeople.isGuide(nil, UIMenu)
end

function UIMenu.getShopRecruitInfo(flag)
    if not flag then
        UIManager.showLoading()
    end
    local data = {
        header = StaticMsgRule.getRecruitInfo,
    }
    if flag then
        if not UIMenu.Logined then
            UIMenu.Logined = true
            netSendPackage(data, UIMenu.showMenuDot)
        end
    else
        netSendPackage(data, getShopRecruitInfoFunc)
    end
end

local function fightPromptDialog(bagType)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local bg_image = cc.Scale9Sprite:create("ui/dialog_bg.png")
    bg_image:setAnchorPoint(cc.p(0.5, 0.5))
    bg_image:setPreferredSize(cc.size(600, 300))
    bg_image:setPosition(cc.p(visibleSize.width / 2, visibleSize.height / 2))
    local bgSize = bg_image:getPreferredSize()
    bg_image:retain()
    local title = ccui.Text:create()
    title:setString(Lang.ui_menu1)
    title:setFontName(dp.FONT)
    title:setFontSize(35)
    title:setTextColor(cc.c4b(255, 255, 0, 255))
    title:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.85))
    bg_image:addChild(title, 3)
    local msgLabel = cc.Label:create()
    msgLabel:setSystemFontName(dp.FONT)
    local hint = nil
    if bagType == StaticBag_Type.card then
        hint = Lang.ui_menu2
    elseif bagType == StaticBag_Type.equip then
        hint = Lang.ui_menu3
    end
    msgLabel:setString(hint)
    msgLabel:setWidth(bgSize.width * 0.85)
    msgLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    msgLabel:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    msgLabel:setSystemFontSize(26)
    msgLabel:setTextColor(cc.c4b(255, 255, 255, 255))
    msgLabel:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.6))
    bg_image:addChild(msgLabel, 3)

    local closeBtn = ccui.Button:create("ui/btn_x.png", "ui/btn_x.png")
    closeBtn:setPressedActionEnabled(true)
    closeBtn:setTouchEnabled(true)
    closeBtn:setPosition(cc.p(bgSize.width - closeBtn:getContentSize().width * 0.3, bgSize.height - closeBtn:getContentSize().height * 0.3))
    bg_image:addChild(closeBtn, 3)
    local leftBtn = ccui.Button:create("ui/tk_btn01.png", "ui/tk_btn01.png")
    leftBtn:setTitleText(Lang.ui_menu4)
    leftBtn:setTitleFontName(dp.FONT)
    leftBtn:setTitleFontSize(25)
    leftBtn:setPressedActionEnabled(true)
    leftBtn:setTouchEnabled(true)
    leftBtn:setPosition(cc.p(bgSize.width / 4 - 20, bgSize.height * 0.25))
    bg_image:addChild(leftBtn, 3)
    local openLv = DictFunctionOpen[tostring(StaticFunctionOpen.resolve)].level
    local middleBtn = nil
    if bagType == StaticBag_Type.card then
        middleBtn = ccui.Button:create("ui/tk_btn01.png", "ui/tk_btn01.png")
        middleBtn:setTitleText(Lang.ui_menu5)
        middleBtn:setTitleFontName(dp.FONT)
        middleBtn:setTitleFontSize(25)
        middleBtn:setPressedActionEnabled(true)
        middleBtn:setTouchEnabled(true)
        middleBtn:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.25))
        bg_image:addChild(middleBtn, 3)
    elseif bagType == StaticBag_Type.equip and net.InstPlayer.int["4"] >= openLv then
        middleBtn = ccui.Button:create("ui/tk_btn01.png", "ui/tk_btn01.png")
        middleBtn:setTitleText(Lang.ui_menu6)
        middleBtn:setTitleFontName(dp.FONT)
        middleBtn:setTitleFontSize(25)
        middleBtn:setPressedActionEnabled(true)
        middleBtn:setTouchEnabled(true)
        middleBtn:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.25))
        bg_image:addChild(middleBtn, 3)
    end
    local rightBtn = ccui.Button:create("ui/tk_btn01.png", "ui/tk_btn01.png")
    rightBtn:setTitleText(Lang.ui_menu7)
    rightBtn:setTitleFontName(dp.FONT)
    rightBtn:setTitleFontSize(25)
    rightBtn:setPressedActionEnabled(true)
    rightBtn:setTouchEnabled(true)
    rightBtn:setPosition(cc.p(bgSize.width / 4 * 3 + 20, bgSize.height * 0.25))
    bg_image:addChild(rightBtn, 3)
    local childs = UIManager.uiLayer:getChildren()
    local function btnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            UIManager.uiLayer:removeChild(bg_image, true)
            cc.release(bg_image)
            if sender == leftBtn or sender == middleBtn then
                if bagType == StaticBag_Type.card then
                    UIBagCard.setFlag(1)
                    if UIBagCard.Widget and UIBagCard.Widget:getParent() then
                        UIManager.flushWidget(UIBagCard)
                    else
                        UIManager.showWidget("ui_notice", "ui_team_info", "ui_bag_card")
                    end
                elseif bagType == StaticBag_Type.equip then
                    if sender == leftBtn then
                        UIBagEquipment.setFlag(1)
                        if UIBagEquipment.Widget and UIBagEquipment.Widget:getParent() then
                            UIManager.flushWidget(UIBagEquipment)
                        else
                            UIManager.showWidget("ui_notice", "ui_team_info", "ui_bag_equipment")
                        end
                    elseif sender == middleBtn then
                        UIManager.hideWidget("ui_team_info")
                        UIResolve.setOperateType(nil)
                        if UIResolve.Widget and UIResolve.Widget:getParent() then
                            UIManager.flushWidget(UIResolve)
                        else
                            UIManager.showWidget("ui_notice", "ui_resolve")
                        end
                    end
                end
            elseif sender == rightBtn then
                if bagType == StaticBag_Type.card then
                    UIBagCardSell.setOperateType(UIBagCardSell.OperateType.CardSell)
                    UIManager.pushScene("ui_bag_card_sell")
                elseif bagType == StaticBag_Type.equip then
                    UIBagEquipmentSell.setOperateType(UIBagEquipmentSell.OperateType.SellEquip)
                    UIManager.pushScene("ui_bag_equipment_sell")
                end
            end
            for i = 1, #childs do
                if not tolua.isnull(childs[i]) then
                    childs[i]:setEnabled(true)
                end
            end
        end
    end
    closeBtn:addTouchEventListener(btnEvent)
    leftBtn:addTouchEventListener(btnEvent)
    if bagType == StaticBag_Type.card or(bagType == StaticBag_Type.equip and net.InstPlayer.int["4"] >= openLv) then
        middleBtn:addTouchEventListener(btnEvent)
    end
    rightBtn:addTouchEventListener(btnEvent)
    UIManager.uiLayer:addChild(bg_image, 10000)
    for i = 1, #childs do
        if childs[i] ~= bg_image then
            childs[i]:setEnabled(false)
        end
    end
end
-- xzli todo
--- 进入首页
function UIMenu.onHomepage()
    UIManager.showWidget("ui_notice", "ui_team_info", "ui_homepage", "ui_menu")
    UIHomePage.hideMore()
end

--- 进入阵容
function UIMenu.onLineup()
    UIManager.hideWidget("ui_team_info")
    UIManager.hideWidget("ui_activity_time")
    UIManager.hideWidget("ui_activity_panel")
    UIManager.hideWidget("ui_activity_purchase_manager")
    UILineup.friendState = 0
    UIManager.showWidget("ui_notice", "ui_lineup", "ui_menu")
    UIHomePage.hideMore()
end


-- 推出聊天界面
function UIMenu.onTalk()
    -- body
    UIManager.pushScene("ui_talk")
end

function UIMenu.onTask()
    -- body
    -- local signInOpen = false
    -- if net.InstPlayerBarrier then
    --     for key, obj in pairs(net.InstPlayerBarrier) do
    --         if obj.int["5"] == 3 and obj.int["3"] == 25 then
    --             --- 第三章节最后一个关卡打完才开启
    --             signInOpen = true
    --         end
    --     end
    -- end
    -- if signInOpen then
    -- else
        
    -- end
    UIManager.pushScene("ui_task_day")

end

--- 进入副本
function UIMenu.onFight(flag)
    if UIFight.Widget and UIFight.Widget:getParent() then
        return
    end
    flag =(flag and flag or 2)
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
    if cardNumber >= cardGrid and not UIGuidePeople.guideFlag then
        fightPromptDialog(StaticBag_Type.card)
    elseif equipNumber >= equipGrid and not UIGuidePeople.guideFlag then
        fightPromptDialog(StaticBag_Type.equip)
    else
        UIFight.setFlag(flag)
        UIManager.showWidget("ui_notice", "ui_team_info", "ui_fight", "ui_menu")
    end
    UIHomePage.hideMore()
end

function UIMenu.hideAll()
    UIManager.hideWidget("ui_team_info")
    UIManager.hideWidget("ui_activity_time")
    UIManager.hideWidget("ui_activity_panel")
    UIManager.hideWidget("ui_activity_purchase_manager")
    UIManager.hideWidget("ui_menu")
end

--- 进入活动
function UIMenu.onActivity()
    UIManager.hideWidget("ui_team_info")
    UIManager.hideWidget("ui_activity_time")
    UIManager.hideWidget("ui_activity_panel")
    UIManager.hideWidget("ui_activity_purchase_manager")
    UIManager.showWidget("ui_notice", "ui_activity_tower", "ui_menu")
    UIHomePage.hideMore()
end

--- 进入背包
function UIMenu.onBag()
    UIBag.reset()
    UIManager.showWidget("ui_notice", "ui_team_info", "ui_bag", "ui_menu")
    UIHomePage.hideMore()
end

--- 进入商店
function UIMenu.onShop()
    if not UIShop.Widget or not UIShop.Widget:getParent() then
        UIMenu.getShopRecruitInfo()
    end
    UIHomePage.hideMore()
end

function UIMenu.init()
    local btn_home = ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_home")
    -- 首页
    local btn_troops = ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_troops")
    -- 阵容
    local btn_copy = ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_property")
    -- 副本
    local btn_dogfight = ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_dogfight")
    -- 活动
    local btn_bag = ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_bag")
    -- 背包
    local btn_shop = ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_shop")
    -- 商店

    local function onBtnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioEngine.playEffect("sound/menu.mp3")
            local _func = nil
            if sender == btn_home then
                _func = UIMenu.onHomepage
                -- 			UIMenu.onHomepage()
            elseif sender == btn_troops then
                _func = UIMenu.onLineup
                -- 			UIMenu.onLineup()
            elseif sender == btn_copy then
                -- _func = UIMenu.onFight
                -- xzli did it
                _func = UIMenu.onTalk()
                -- 			UIMenu.onFight(2)
            elseif sender == btn_dogfight then
                -- _func = UIMenu.onActivity
                --xzli.did it
                _func = UIMenu.onTask()
                -- 			UIMenu.onActivity()
            elseif sender == btn_bag then
                _func = UIMenu.onBag
                -- 			UIMenu.onBag()
            elseif sender == btn_shop then
                _func = UIMenu.onShop
                -- 			UIMenu.onShop()
            end
            if _func then
                if not UIPilltower.exitWaring(_func) then
                    _func()
                    if UIGuidePeople.nextCheckLevelGuide then
                        UIGuidePeople.levelStep = UIGuidePeople.nextCheckLevelGuide
                        UIGuidePeople.checkLevelGuide()
                        UIGuidePeople.nextCheckLevelGuide = nil
                    end
                end
            end
        end
    end
    btn_home:addTouchEventListener(onBtnEvent)
    btn_troops:addTouchEventListener(onBtnEvent)
    btn_copy:addTouchEventListener(onBtnEvent)
    btn_dogfight:addTouchEventListener(onBtnEvent)
    btn_bag:addTouchEventListener(onBtnEvent)
    btn_shop:addTouchEventListener(onBtnEvent)
end
-- 废弃
function UIMenu.showUIFightDot()
    --[[
    local state = nil
    if net.InstPlayerChapter then
        for key, obj in pairs(net.InstPlayerChapter) do
            local boxThing = { }
            local barrierNum = obj.int["5"]
            local chapterId = obj.int["3"]
            local type = DictChapter[tostring(chapterId)].type
            if type == 1 then
                local getThingTable = { }
                local star = { }
                for _key, _obj in pairs(DictBarrier) do
                    if _obj.chapterId == chapterId and _obj.welfareBox ~= "" then
                        table.insert(boxThing, _obj)
                    end
                end
                for _key, _obj in pairs(boxThing) do
                    if net.InstPlayerBarrier then
                        for _, obj1 in pairs(net.InstPlayerBarrier) do
                            if obj1.int["5"] == chapterId and obj1.int["3"] == _obj.id then
                                if obj1.int["9"] == 1 then
                                    state = true
                                    break
                                end
                            end
                        end
                    end
                    if state then
                        break
                    end
                end
                if state then
                    break
                end
                star[1] = DictChapter[tostring(chapterId)].starOne
                star[2] = DictChapter[tostring(chapterId)].starTwo
                star[3] = DictChapter[tostring(chapterId)].starThree
                if obj.string ~= nil then
                    if obj.string["7"] then
                        getThingTable = utils.stringSplit(obj.string["7"], ";")
                    end
                end
                local num = 0
                for _, _obj in pairs(star) do
                    if _obj ~= 0 then
                        num = num + 1
                    end
                end
                if star[3] ~= 0 and barrierNum >= star[3] and #getThingTable < num then
                    state = true
                elseif star[2] ~= 0 and barrierNum >= star[2] and #getThingTable < num - 1 then
                    state = true
                elseif star[1] ~= 0 and barrierNum >= star[1] and #getThingTable < num - 2 then
                    state = true
                end
                if state then
                    break
                end
            end
        end
    end
    local stateOne, stateThree = UIFight.checkImageHint()
    if state or stateOne or stateThree then
        ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_property"):getChildByName("image_hint"):setVisible(true)
    else
        ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_property"):getChildByName("image_hint"):setVisible(false)
    end
    ]]
end
-- 废弃
local function showBossHint()
    --[[
    if UIBoss.checkImageHint() then
        ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_dogfight"):getChildByName("image_hint"):setVisible(true)
    else
        ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_dogfight"):getChildByName("image_hint"):setVisible(false)
    end
    ]]
end

--新增
function UIMenu.showTalkHint()
    --
    if UITalk.unionF or UITalk.userF then
        ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_property"):getChildByName("image_hint"):setVisible(true)
    else
        ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_property"):getChildByName("image_hint"):setVisible(false)
    end
end

function UIMenu.showTaskHint()
    -- body
     ------每日任务------------------------------
    local signInOpen = false
    if net.InstPlayerBarrier then
        for key, obj in pairs(net.InstPlayerBarrier) do
            if obj.int["5"] == 3 and obj.int["3"] == 25 then
                --- 第三章节最后一个关卡打完才开启
                signInOpen = true
            end
        end
    end
    if net.InstPlayerDailyTask and signInOpen then
        local level = net.InstPlayer.int["4"]
        local flag = false
        for key, obj in pairs(net.InstPlayerDailyTask) do
            if obj.int["3"] < 1000 then
                local dictObj = DictDailyTask[tostring(obj.int["3"])]
                local taskLevel = 0
                if dictObj.functionOpenId == 40 then
                    taskLevel = 40
                else
                    taskLevel = DictFunctionOpen[tostring(dictObj.functionOpenId)].level
                end
                local totalTimes = dictObj.times
                local rewardTimes = obj.int["4"]
                if level >= taskLevel and obj.int["5"] == 0 and rewardTimes >= totalTimes then
                    flag = true
                end
            end
        end
        if flag then
            ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_dogfight"):getChildByName("image_hint"):setVisible(true)
        else
            ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_dogfight"):getChildByName("image_hint"):setVisible(false)
        end
    end
end

function UIMenu.showLineupHint()
    local _isVisibleHint = false

    if net.InstPlayerLineup then

        local InstPlayerLineup = { }
        for key, obj in pairs(net.InstPlayerLineup) do
            local formationId = obj.int["3"]
            local equipTypeId = obj.int["4"]
            if InstPlayerLineup[formationId] == nil then
                InstPlayerLineup[formationId] = { }
            end
            InstPlayerLineup[formationId][equipTypeId] = obj
        end

        for key, obj in pairs(net.InstPlayerFormation) do
            if obj.int["4"] == 1 or obj.int["4"] == 2 then
                local formationId = obj.int["1"]
                if InstPlayerLineup[formationId] then
                    -- // [武器槽]
                    if InstPlayerLineup[formationId][StaticEquip_Type.equip] then
                        local iplObj = InstPlayerLineup[formationId][StaticEquip_Type.equip]
                        if UILineup.isHint(iplObj.int["4"], iplObj.int["5"]) then
                            _isVisibleHint = true
                            break
                        end
                    elseif UILineup.isHint(StaticEquip_Type.equip) then
                        _isVisibleHint = true
                        break
                    end
                    -- // [护甲槽]
                    if InstPlayerLineup[formationId][StaticEquip_Type.outerwear] then
                        local iplObj = InstPlayerLineup[formationId][StaticEquip_Type.outerwear]
                        if UILineup.isHint(iplObj.int["4"], iplObj.int["5"]) then
                            _isVisibleHint = true
                            break
                        end
                    elseif UILineup.isHint(StaticEquip_Type.outerwear) then
                        _isVisibleHint = true
                        break
                    end
                    -- // [头盔槽]
                    if InstPlayerLineup[formationId][StaticEquip_Type.pants] then
                        local iplObj = InstPlayerLineup[formationId][StaticEquip_Type.pants]
                        if UILineup.isHint(iplObj.int["4"], iplObj.int["5"]) then
                            _isVisibleHint = true
                            break
                        end
                    elseif UILineup.isHint(StaticEquip_Type.pants) then
                        _isVisibleHint = true
                        break
                    end
                    -- // [饰品槽]
                    if InstPlayerLineup[formationId][StaticEquip_Type.necklace] then
                        local iplObj = InstPlayerLineup[formationId][StaticEquip_Type.necklace]
                        if UILineup.isHint(iplObj.int["4"], iplObj.int["5"]) then
                            _isVisibleHint = true
                            break
                        end
                    elseif UILineup.isHint(StaticEquip_Type.necklace) then
                        _isVisibleHint = true
                        break
                    end

                elseif UILineup.isHint(StaticEquip_Type.equip) or UILineup.isHint(StaticEquip_Type.outerwear) or
                    UILineup.isHint(StaticEquip_Type.pants) or UILineup.isHint(StaticEquip_Type.necklace) then
                    _isVisibleHint = true
                    break
                end
            end
        end
    elseif UILineup.isHint(StaticEquip_Type.equip) or UILineup.isHint(StaticEquip_Type.outerwear) or
        UILineup.isHint(StaticEquip_Type.pants) or UILineup.isHint(StaticEquip_Type.necklace) then
        _isVisibleHint = true
    end
    if not _isVisibleHint then
        if net.InstPlayerMagic then
            local InstPlayerMagic = { }
            for key, obj in pairs(net.InstPlayerMagic) do
                local instCardId = obj.int["8"]
                if instCardId > 0 then
                    local magicType = obj.int["4"]
                    if InstPlayerMagic[instCardId] == nil then
                        InstPlayerMagic[instCardId] = { }
                    end
                    InstPlayerMagic[instCardId][magicType] = obj
                end
            end
            for key, obj in pairs(net.InstPlayerFormation) do
                if obj.int["4"] == 1 or obj.int["4"] == 2 then
                    local instCardId = obj.int["3"]
                    if InstPlayerMagic[instCardId] then
                        -- // [法宝槽]
                        if InstPlayerMagic[instCardId][dp.MagicType.treasure] then
                            local ipmObj = InstPlayerMagic[instCardId][dp.MagicType.treasure]
                            if UILineup.isMagicHint(ipmObj.int["4"], ipmObj.int["1"]) then
                                _isVisibleHint = true
                                break
                            end
                        elseif UILineup.isMagicHint(dp.MagicType.treasure) then
                            _isVisibleHint = true
                            break
                        end
                        -- // [功法槽]
                        if InstPlayerMagic[instCardId][dp.MagicType.gongfa] then
                            local ipmObj = InstPlayerMagic[instCardId][dp.MagicType.gongfa]
                            if UILineup.isMagicHint(ipmObj.int["4"], ipmObj.int["1"]) then
                                _isVisibleHint = true
                                break
                            end
                        elseif UILineup.isMagicHint(dp.MagicType.gongfa) then
                            _isVisibleHint = true
                            break
                        end
                    elseif UILineup.isMagicHint(dp.MagicType.treasure) or UILineup.isMagicHint(dp.MagicType.gongfa) then
                        _isVisibleHint = true
                        break
                    end
                end
            end
        elseif UILineup.isMagicHint(dp.MagicType.treasure) or UILineup.isMagicHint(dp.MagicType.gongfa) then
            _isVisibleHint = true
        end
    end
    if UILineup.checkImageHint() then
        _isVisibleHint = true
    end
    if ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_troops") then
        ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_troops"):getChildByName("image_hint"):setVisible(_isVisibleHint)
    end
end 

function UIMenu.showTowerHint()
    if net.InstPlayer.int["4"] >= UIActivityTower.checkOpenLv("ui_tower_test") then
        if UITowerTest.checkImageHint() then
            ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_dogfight"):getChildByName("image_hint"):setVisible(true)
        else
            ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_dogfight"):getChildByName("image_hint"):setVisible(false)
        end
    end
end

function UIMenu.showPilltowerHint()
    local ui_hint = ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_dogfight"):getChildByName("image_hint")
    if (not ui_hint:isVisible()) and net.InstPlayer.int["4"] >= DictFunctionOpen[tostring(StaticFunctionOpen.danta)].level then
        ui_hint:setVisible(false)
        if UIPilltower.checkImageHint() then
            ui_hint:setVisible(true)
        end
    end
end

function UIMenu.refreshIcon()
    -- 折扣处理
    local btn_shop = ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_shop")
    -- 商店
    local image_title = btn_shop:getChildByName("image_title")
    if UIShop.disCount < 1 then
        image_title:setVisible(true)
        if UIShop.disCount ~= 0.5 then
            image_title:getChildByName("Text_1"):setString((UIShop.disCount * 10) .. Lang.ui_menu8)
        end
    else
        image_title:setVisible(false)
    end
end

function UIMenu.setup()
    UIGuidePeople.isGuide(nil, UIMenu)
    UIMenu.showLineupHint()
    -- ***********修行红点处理***********
    local ui_hint = ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_dogfight"):getChildByName("image_hint")
    ui_hint:setVisible(false)
    for i = 1, 3 do
        if i == 1 then
            UIMenu.showTowerHint()
        elseif i == 2 then
            -- showBossHint()
        elseif i == 3 then
            UIMenu.showPilltowerHint()
        end
        if ui_hint:isVisible() then
            break
        end
    end
    if UIMenu.hint_pilltower == nil then
        UIPilltower.checkImageHint()
    end
    -- ***********修行红点处理***********
    if not UIGuidePeople.guideFlag then
        UIMenu.getShopRecruitInfo(1)
    end
    UIMenu.showUIFightDot()
    -- xzli add
    UIMenu.showTalkHint()
    UIMenu.showTaskHint()

    UIMenu.refreshIcon()

end



function UIMenu.cleanHintData()
    UIMenu.hint_pilltower = nil
end

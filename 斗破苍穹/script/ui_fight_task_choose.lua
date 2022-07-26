require"Lang"
UIFightTaskChoose = {
    reset = false,
}
local objData = nil
local RequstBarrierLevelId = nil  --- 当前请求的战斗
local btnOne = nil
local btnTen = nil
local barrierLevelId = nil
local barrierAllTimes = nil --- 战斗总次数
local barrierTimes = 0  --- 已挑战次数
local InstbarrierId = nil
local coldMoney = 0  -- 冷却所花的钱
local ResetBarrierTimes = 0  -- 副本重置次数
local ResetBarrierMoney = 0  -- 重置挑战次数所花的钱
local ui_image_basemap = nil
local maxChapterTypeObj = nil
local energy = 0
local buyEnergyNum = 0
local energyPillPrice = 0
local OPENAKEYFIGHTLEVEL = DictFunctionOpen[tostring(StaticFunctionOpen.continuFight)].level -- 一键战斗开启等级

local TIP_COLOR = cc.c3b(255, 255, 0)

local function netCallbackFunc(pack)
    if tonumber(pack.header) == StaticMsgRule.aKeyCommonWar then
        UITeam.checkRecoverState()
        UIManager.flushWidget(UIFightTask)
        UIManager.flushWidget(UIFightTaskChoose)
        local param = { }
        table.insert(param, RequstBarrierLevelId)
        table.insert(param, pack.msgdata)
        UIFightClearing.setParam(param)
        UIManager.pushScene("ui_fight_clearing")
        UIFightTaskChoose.reset = false
    elseif tonumber(pack.header) == StaticMsgRule.resetFightNum then
        UIFightTaskChoose.setup()
    elseif tonumber(pack.header) == StaticMsgRule.thingUse or tonumber(pack.header) == StaticMsgRule.goldEnergyOrVigor then
        if tonumber(pack.header) == StaticMsgRule.thingUse then
            UIManager.showToast(Lang.ui_fight_task_choose1 .. DictSysConfig[tostring(StaticSysConfig.energyPillEnergy)].value .. Lang.ui_fight_task_choose2)
        else
            local widget = UIFightTaskChoose.BuyEneryDialog.Widget
            if widget then
                local text_energypill = ccui.Helper:seekNodeByName(widget, "text_energypill")
                local sprite = cc.Sprite:create("image/+1.png")
                local size = text_energypill:getContentSize()
                sprite:setPosition(size.width / 2, size.height / 2)
                sprite:setScale(20 / sprite:getContentSize().height)
                sprite:setOpacity(150)
                text_energypill:addChild(sprite)

                local rightHint = ccui.Helper:seekNodeByName(widget, "rightHint")
                rightHint:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1.2), cc.ScaleTo:create(0.1, 1)))

                local scaleAction = cc.ScaleTo:create(1 / 6, 1.0)
                local alphaAction = cc.Sequence:create(cc.FadeIn:create(5 / 60), cc.DelayTime:create(1 / 6), cc.FadeOut:create(15 / 60))
                local moveAction = cc.EaseCubicActionInOut:create(cc.MoveBy:create(30 / 60, cc.p(0, 127)))
                moveAction = cc.Sequence:create(moveAction, cc.RemoveSelf:create())
                sprite:runAction(cc.Spawn:create(scaleAction, alphaAction, moveAction))
            end
        end

        local bar_strength = ccui.Helper:seekNodeByName(UIFightTask.Widget, "bar_strength")
        bar_strength:setPercent(utils.getPercent(net.InstPlayer.int["8"], net.InstPlayer.int["9"]))
        bar_strength:getChildByName("text_strength"):setString(net.InstPlayer.int["8"] .. "/" .. net.InstPlayer.int["9"])
        if tonumber(pack.header) == StaticMsgRule.goldEnergyOrVigor then
            UIShop.getShopList(1, nil)
        end
        UIFightTaskChoose.checkPlayerEnergy()
    end
end

local function sendFightTenRequest(_barrierId, _barrierLevelId, _fightNum)
    local sendData = {
        header = StaticMsgRule.aKeyCommonWar,
        msgdata =
        {
            int =
            {
                instPlayerBarrierId = _barrierId,
                barrierLevelId = _barrierLevelId,
                fightNum = _fightNum
            },
            string =
            {
                coredata = utils.fightVerifyData()-- 此处不可以欲计算
            }
        }
    }
    RequstBarrierLevelId = _barrierLevelId
    UIManager.showLoading()
    netSendPackage(sendData, netCallbackFunc)
end

--- 重置关卡挑战次数
local function sendResetBarrierTimeRequest()
    local sendData = {
        header = StaticMsgRule.resetFightNum,
        msgdata =
        {
            int =
            {
                instPlayerBarrierId = objData.int["1"],
            }
        }
    }
    UIManager.showLoading()
    netSendPackage(sendData, netCallbackFunc)
end

UIFightTaskChoose.BuyEneryDialog = { }

local function showBuyEnergyDialog()
    UIFightTaskChoose.BuyEneryDialog.init()
    UIFightTaskChoose.BuyEneryDialog.setup()
end

function UIFightTaskChoose.BuyEneryDialog.init()
    if UIFightTaskChoose.BuyEneryDialog.Widget then return end
    local vipNum = net.InstPlayer.int["19"]

    local ui_middle = ccui.Layout:create()
    ui_middle:setContentSize(display.size)
    ui_middle:setTouchEnabled(true)
    ui_middle:retain()

    local bg_image = cc.Scale9Sprite:create("ui/dialog_bg.png")
    ui_middle:addChild(bg_image)
    bg_image:setAnchorPoint(cc.p(0.5, 0.5))
    bg_image:setPreferredSize(cc.size(500, 500))
    bg_image:setPosition(display.size.width / 2, display.size.height / 2)
    local bgSize = bg_image:getPreferredSize()

    local title = ccui.Text:create()
    title:setString(Lang.ui_fight_task_choose3)
    title:setFontName(dp.FONT)
    title:setFontSize(35)
    title:setTextColor(cc.c4b(255, 255, 0, 255))
    title:setPosition(cc.p(bgSize.width / 2, bgSize.height - title:getContentSize().height - 15))
    bg_image:addChild(title, 3)

    local msgLabel = ccui.Text:create()
    msgLabel:setString(Lang.ui_fight_task_choose4)
    msgLabel:setTextAreaSize(cc.size(425, 500))
    msgLabel:setFontName(dp.FONT)
    msgLabel:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    msgLabel:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    msgLabel:setFontSize(26)
    msgLabel:setPosition(cc.p(bgSize.width / 2, bgSize.height - title:getContentSize().height * 3.5))
    bg_image:addChild(msgLabel, 3)

    local node = cc.Node:create()
    local image_di = ccui.ImageView:create("ui/quality_small_blue.png")
    local image = ccui.ImageView:create("image/poster_item_small_tilidan.png")
    local description = ccui.Text:create()
    description:setName("text_energypill")
    description:setFontSize(20)
    description:setFontName(dp.FONT)
    description:setAnchorPoint(cc.p(0.5, 1))
    description:setTextColor(TIP_COLOR)
    image:setPosition(cc.p(image_di:getContentSize().width / 2, image_di:getContentSize().height / 2))
    image_di:addChild(image)
    image_di:setPosition(cc.p(0, 0))
    description:setPosition(cc.p(0, - image_di:getContentSize().height / 2 - 5))
    node:addChild(image_di)
    node:addChild(description)
    description:setString(Lang.ui_fight_task_choose5 .. DictSysConfig[tostring(StaticSysConfig.energyPillEnergy)].value)
    node:setPosition(cc.p(bgSize.width / 2, msgLabel:getPositionY() -95))
    bg_image:addChild(node, 3)

    local closeBtn = ccui.Button:create("ui/btn_x.png", "ui/btn_x.png")
    closeBtn:setPressedActionEnabled(true)
    closeBtn:setPosition(cc.p(bgSize.width - closeBtn:getContentSize().width / 2, bgSize.height - closeBtn:getContentSize().height / 2))
    bg_image:addChild(closeBtn, 3)

    closeBtn:addTouchEventListener( function(sender, eventType)
        if sender == closeBtn then
            bg_image:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 0.1), cc.CallFunc:create( function()
                UIManager.uiLayer:removeChild(ui_middle, true)
                cc.release(ui_middle)
                UIFightTaskChoose.BuyEneryDialog.Widget = nil
            end )))
        end
    end
    )

    local sureBtn = ccui.Button:create("ui/yh_sq_btn01.png", "ui/yh_sq_btn01.png")
    sureBtn:setName("sureBtn")
    sureBtn:setPressedActionEnabled(true)
    local withscale = ccui.RichText:create()
    withscale:setName("withscale")
    withscale:pushBackElement(ccui.RichElementText:create(1, display.COLOR_WHITE, 255, Lang.ui_fight_task_choose6, dp.FONT, 25))
    withscale:pushBackElement(ccui.RichElementImage:create(2, display.COLOR_WHITE, 255, "ui/jin.png"))
    withscale:pushBackElement(ccui.RichElementText:create(3, display.COLOR_WHITE, 255, "×10", dp.FONT, 25))
    withscale:setPosition(sureBtn:getContentSize().width / 2, sureBtn:getContentSize().height / 2)
    sureBtn:addChild(withscale)
    sureBtn:setPosition(cc.p(bgSize.width / 4, bgSize.height * 0.2))
    bg_image:addChild(sureBtn, 3)

    local leftHint = ccui.RichText:create()
    leftHint:setName("leftHint")
    leftHint:pushBackElement(ccui.RichElementText:create(1, display.COLOR_WHITE, 255, Lang.ui_fight_task_choose7, dp.FONT, 20))
    leftHint:pushBackElement(ccui.RichElementText:create(2, TIP_COLOR, 255, "0", dp.FONT, 20))
    leftHint:pushBackElement(ccui.RichElementText:create(3, display.COLOR_WHITE, 255, Lang.ui_fight_task_choose8, dp.FONT, 20))
    leftHint:setPosition(cc.p(bgSize.width / 4, bgSize.height * 0.1))
    bg_image:addChild(leftHint, 3)

    local useBtn = ccui.Button:create("ui/tk_btn01.png", "ui/tk_btn01.png")
    useBtn:setName("useBtn")
    useBtn:setTitleText(Lang.ui_fight_task_choose9)
    useBtn:setTitleFontName(dp.FONT)
    useBtn:setTitleFontSize(25)
    useBtn:setPressedActionEnabled(true)
    useBtn:setPosition(cc.p(bgSize.width / 4 * 3, bgSize.height * 0.2))
    bg_image:addChild(useBtn, 3)

    local rightHint = ccui.RichText:create()
    rightHint:setName("rightHint")
    rightHint:pushBackElement(ccui.RichElementText:create(1, display.COLOR_WHITE, 255, Lang.ui_fight_task_choose10, dp.FONT, 20))
    rightHint:pushBackElement(ccui.RichElementText:create(2, TIP_COLOR, 255, "0", dp.FONT, 20))
    rightHint:pushBackElement(ccui.RichElementText:create(3, display.COLOR_WHITE, 255, Lang.ui_fight_task_choose11, dp.FONT, 20))
    rightHint:setPosition(cc.p(bgSize.width / 4 * 3, bgSize.height * 0.1))
    bg_image:addChild(rightHint, 3)

    UIManager.uiLayer:addChild(ui_middle, 20000)
    ActionManager.PopUpWindow_SplashAction(bg_image)
    UIFightTaskChoose.BuyEneryDialog.Widget = ui_middle
end

function UIFightTaskChoose.BuyEneryDialog.setup()
    if not UIFightTaskChoose.BuyEneryDialog.Widget then return end

    local widget = UIFightTaskChoose.BuyEneryDialog.Widget

    local number = 0
    local instThingId = nil
    if net.InstPlayerThing then
        for key, obj in pairs(net.InstPlayerThing) do
            if StaticThing.energyPill == obj.int["3"] then
                number = obj.int["5"]
                instThingId = obj.int["1"]
            end
        end
    end

    local withscale = ccui.Helper:seekNodeByName(widget, "withscale")
    local leftHint = ccui.Helper:seekNodeByName(widget, "leftHint")
    local rightHint = ccui.Helper:seekNodeByName(widget, "rightHint")
    local sureBtn = ccui.Helper:seekNodeByName(widget, "sureBtn")
    local useBtn = ccui.Helper:seekNodeByName(widget, "useBtn")

    withscale:removeElement(2)
    withscale:pushBackElement(ccui.RichElementText:create(3, display.COLOR_WHITE, 255, "×" .. energyPillPrice, dp.FONT, 25))
    leftHint:removeElement(1)
    leftHint:insertElement(ccui.RichElementText:create(2, TIP_COLOR, 255, tostring(math.max(0, buyEnergyNum)), dp.FONT, 20), 1)
    rightHint:removeElement(1)
    rightHint:insertElement(ccui.RichElementText:create(2, TIP_COLOR, 255, tostring(number), dp.FONT, 20), 1)

    local function sendUseData(_instPlayerThingId)
        local sendData = {
            header = StaticMsgRule.thingUse,
            msgdata =
            {
                int =
                {
                    instPlayerThingId = _instPlayerThingId,
                    num = 1,
                }
            }
        }
        UIManager.showLoading()
        netSendPackage(sendData, netCallbackFunc)
    end
    local function sendGoldData()
        local sendData = {
            header = StaticMsgRule.goldEnergyOrVigor,
            msgdata =
            {
                int =
                {
                    type = 1,
                }
            }
        }
        UIManager.showLoading()
        netSendPackage(sendData, netCallbackFunc)
    end

    local function btnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == sureBtn then
                if 0 < buyEnergyNum then
                    sendGoldData()
                end
            elseif sender == useBtn then
                if number > 0 then
                    sendUseData(instThingId)
                end
            end
        end
    end
    sureBtn:addTouchEventListener(btnEvent)
    useBtn:addTouchEventListener(btnEvent)
    if number <= 0 then
        utils.GrayWidget(useBtn, true)
        useBtn:setEnabled(false)
    else
        utils.GrayWidget(useBtn, false)
        useBtn:setEnabled(true)
    end
    if energyPillPrice > net.InstPlayer.int["5"] or buyEnergyNum <= 0 then
        utils.GrayWidget(sureBtn, true)
        sureBtn:setEnabled(false)
    else
        utils.GrayWidget(sureBtn, false)
        sureBtn:setEnabled(true)
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
    title:setString(Lang.ui_fight_task_choose12)
    title:setFontName(dp.FONT)
    title:setFontSize(35)
    title:setTextColor(cc.c4b(255, 255, 0, 255))
    title:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.85))
    bg_image:addChild(title, 3)
    local msgLabel = cc.Label:create()
    msgLabel:setSystemFontName(dp.FONT)
    local hint = nil
    if bagType == StaticBag_Type.card then
        hint = Lang.ui_fight_task_choose13
    elseif bagType == StaticBag_Type.equip then
        hint = Lang.ui_fight_task_choose14
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
    leftBtn:setTitleText(Lang.ui_fight_task_choose15)
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
        middleBtn:setTitleText(Lang.ui_fight_task_choose16)
        middleBtn:setTitleFontName(dp.FONT)
        middleBtn:setTitleFontSize(25)
        middleBtn:setPressedActionEnabled(true)
        middleBtn:setTouchEnabled(true)
        middleBtn:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.25))
        bg_image:addChild(middleBtn, 3)
    elseif bagType == StaticBag_Type.equip and net.InstPlayer.int["4"] >= openLv then
        middleBtn = ccui.Button:create("ui/tk_btn01.png", "ui/tk_btn01.png")
        middleBtn:setTitleText(Lang.ui_fight_task_choose17)
        middleBtn:setTitleFontName(dp.FONT)
        middleBtn:setTitleFontSize(25)
        middleBtn:setPressedActionEnabled(true)
        middleBtn:setTouchEnabled(true)
        middleBtn:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.25))
        bg_image:addChild(middleBtn, 3)
    end
    local rightBtn = ccui.Button:create("ui/tk_btn01.png", "ui/tk_btn01.png")
    rightBtn:setTitleText(Lang.ui_fight_task_choose18)
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
                UIFightTask.setBasemapPercent(nil)
                if bagType == StaticBag_Type.card then
                    UIBagCard.setFlag(1)
                    UIManager.showScreen("ui_notice", "ui_team_info", "ui_bag_card", "ui_menu")
                elseif bagType == StaticBag_Type.equip then
                    if sender == leftBtn then
                        UIBagEquipment.setFlag(1)
                        UIManager.showScreen("ui_notice", "ui_team_info", "ui_bag_equipment", "ui_menu")
                    elseif sender == middleBtn then
                        UIManager.showScreen("ui_notice", "ui_resolve", "ui_menu")
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

local function checkBag()
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
        UIManager.popScene()
        fightPromptDialog(StaticBag_Type.card)
        return true
    elseif equipNumber >= equipGrid then
        UIManager.popScene()
        fightPromptDialog(StaticBag_Type.equip)
        return true
    end
end

local function getShopFunc(pack)
    local propThing = pack.msgdata.message
    if propThing then
        for key, obj in pairs(propThing) do
            local tableFieldId = obj.int["thingId"]
            if tableFieldId == StaticThing.energyPill then
                -- energyPillPrice = obj.int["price"]
                -- buyEnergyNum = obj.int["canBuyNum"]

                buyEnergyNum = obj.int["canBuyNum"]
                local _todayBuyPrice = 0
                --   buyVigorNum = _obj.int["todayBuyNum"]
                local _todayBuyNum = obj.int["todayBuyNum"] + 1
                local _extend = utils.stringSplit(DictThingExtend[tostring(tableFieldId)].extend, ";")
                for _k, _o in pairs(_extend) do
                    local _tempO = utils.stringSplit(_o, "_")
                    if _todayBuyNum >= tonumber(_tempO[1]) and _todayBuyNum <= tonumber(_tempO[2]) then
                        energyPillPrice = math.round(tonumber(_tempO[3]) * UIShop.disCount)
                        break
                    end
                end

                break
            end
        end
    end
    showBuyEnergyDialog()
end

function UIFightTaskChoose.checkPlayerEnergy()
    UIManager.showLoading()
    local data = {
        header = StaticMsgRule.getStoreData,
        msgdata =
        {
            int =
            {
                type = 1,
            },
        }
    }
    netSendPackage(data, getShopFunc)
end

local function getBlankNode(width)
    local node = cc.Node:create()
    node:setContentSize(width, 5)
    return node
end

local function showResetBarrierTimesDialog()
    local VipNum = net.InstPlayer.int["19"]
    local resetEnabled = DictVIP[tostring(VipNum + 1)].isResetGenerBarrier
    if resetEnabled == 0 then
        UIManager.showToast(Lang.ui_fight_task_choose19)
        return
    end
    local chapterResetCount = DictVIP[tostring(VipNum + 1)].chapterResetCount
    if ResetBarrierTimes >= chapterResetCount then
        local params = { Lang.ui_fight_task_choose20 }

        local vipLevel = nil
        for i = VipNum + 1, math.huge do
            local vip = DictVIP[tostring(i)]
            if not vip then break end
            if vip.chapterResetCount > chapterResetCount then
                vipLevel = i
                break
            end
        end

        if vipLevel then
            params[#params + 1] = string.format(Lang.ui_fight_task_choose21, vipLevel - 1, DictVIP[tostring(vipLevel)].chapterResetCount)
        end

        UIHintBuy.show(UIHintBuy.MONEY_TYPE_RECHARGE, params)
    else
        local ui_middle = ccui.Layout:create()
        ui_middle:setContentSize(display.size)
        ui_middle:setTouchEnabled(true)
        ui_middle:retain()

        local bg_image = cc.Scale9Sprite:create("ui/dialog_bg.png")
        ui_middle:addChild(bg_image)
        bg_image:setAnchorPoint(cc.p(0.5, 0.5))
        bg_image:setPreferredSize(cc.size(500, 350))
        bg_image:setPosition(display.size.width / 2, display.size.height / 2)
        local bgSize = bg_image:getPreferredSize()

        local title = ccui.Text:create()
        title:setString(Lang.ui_fight_task_choose22)
        title:setFontSize(35)
        title:setFontName(dp.FONT)
        title:setTextColor(cc.c4b(255, 255, 0, 255))
        title:setPosition(cc.p(bgSize.width / 2, bgSize.height - 45))
        bg_image:addChild(title)

        local msgRichText = ccui.RichText:create()
        msgRichText:setContentSize(cc.size(425, 300))
        msgRichText:pushBackElement(ccui.RichElementText:create(1, display.COLOR_WHITE, 255, Lang.ui_fight_task_choose23, dp.FONT, 26))
        msgRichText:pushBackElement(ccui.RichElementCustomNode:create(2, display.COLOR_WHITE, 255, getBlankNode(5)))
        msgRichText:pushBackElement(ccui.RichElementImage:create(3, display.COLOR_WHITE, 255, "ui/jin.png"))
        msgRichText:pushBackElement(ccui.RichElementText:create(4, cc.c3b(255, 255, 0), 255, "×" .. ResetBarrierMoney, dp.FONT, 26))
        msgRichText:pushBackElement(ccui.RichElementText:create(5, display.COLOR_WHITE, 255, Lang.ui_fight_task_choose24, dp.FONT, 26))
        msgRichText:setPosition(cc.p(bgSize.width / 2, bgSize.height - 120))
        bg_image:addChild(msgRichText)

        local msgLabel = ccui.Text:create()
        msgLabel:setString(string.format(Lang.ui_fight_task_choose25, chapterResetCount - ResetBarrierTimes))
        msgLabel:setFontName(dp.FONT)
        msgLabel:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        msgLabel:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        msgLabel:setFontSize(26)
        msgLabel:setTextColor(TIP_COLOR)
        msgLabel:setPosition(cc.p(bgSize.width / 2, 75 + 75))
        bg_image:addChild(msgLabel)

        local sureBtn = ccui.Button:create("ui/tk_btn01.png", "ui/tk_btn01.png")
        sureBtn:setTitleText(Lang.ui_fight_task_choose26)
        sureBtn:setTitleFontName(dp.FONT)
        sureBtn:setTitleColor(cc.c3b(255, 255, 255))
        sureBtn:setTitleFontSize(25)
        sureBtn:setPressedActionEnabled(true)
        sureBtn:setTouchEnabled(true)
        sureBtn:setPosition(bgSize.width / 4 * 3, 75)
        bg_image:addChild(sureBtn)

        local closeBtn = ccui.Button:create("ui/btn_x.png", "ui/btn_x.png")
        closeBtn:setPressedActionEnabled(true)
        closeBtn:setTouchEnabled(true)
        closeBtn:setPosition(cc.p(bgSize.width - closeBtn:getContentSize().width * 0.5, bgSize.height - closeBtn:getContentSize().height * 0.5))
        bg_image:addChild(closeBtn, 2)

        local cancelBtn = ccui.Button:create("ui/tk_btn_purple.png", "ui/tk_btn_purple.png")
        cancelBtn:setTitleText(Lang.ui_fight_task_choose27)
        cancelBtn:setTitleFontName(dp.FONT)
        cancelBtn:setTitleColor(cc.c3b(255, 255, 255))
        cancelBtn:setTitleFontSize(25)
        cancelBtn:setPressedActionEnabled(true)
        cancelBtn:setTouchEnabled(true)
        cancelBtn:setPosition(cc.p(bgSize.width / 4, 75))
        bg_image:addChild(cancelBtn)

        local function closeDialog()
            UIManager.uiLayer:removeChild(ui_middle, true)
            cc.release(ui_middle)
        end
        local function btnEvent(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                AudioEngine.playEffect("sound/button.mp3")
                if sender == sureBtn then
                    sendResetBarrierTimeRequest()
                end

                bg_image:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 0.1), cc.CallFunc:create(closeDialog)))
            end
        end

        sureBtn:addTouchEventListener(btnEvent)
        closeBtn:addTouchEventListener(btnEvent)
        cancelBtn:addTouchEventListener(btnEvent)

        UIManager.uiLayer:addChild(ui_middle, 20000)
        ActionManager.PopUpWindow_SplashAction(bg_image)
    end
end

function UIFightTaskChoose.init()
    local btn_close = ccui.Helper:seekNodeByName(UIFightTaskChoose.Widget, "btn_close")
    local btn_embattle = ccui.Helper:seekNodeByName(UIFightTaskChoose.Widget, "btn_embattle")
    local btn_help = ccui.Helper:seekNodeByName(UIFightTaskChoose.Widget, "btn_help")
    btn_close:setPressedActionEnabled(true)
    btn_embattle:setPressedActionEnabled(true)
    btn_help:setPressedActionEnabled(true)
    ui_image_basemap = ccui.Helper:seekNodeByName(UIFightTaskChoose.Widget, "image_basemap")
    btnOne = ui_image_basemap:getChildByName("btn_fight")
    btnTen = ui_image_basemap:getChildByName("btn_fight_ten")
    btnOne:setPressedActionEnabled(true)
    btnTen:setPressedActionEnabled(true)
    local function TouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close then
                AudioEngine.playEffect("sound/button.mp3")
                UIManager.popScene()
            elseif sender == btn_help then
                AudioEngine.playEffect("sound/button.mp3")
                UIFightTaskHelp.show(barrierLevelId)
            elseif sender == btn_embattle then
                AudioEngine.playEffect("sound/button.mp3")
                if net.InstPlayer.int["4"] >= DictFunctionOpen[ tostring( StaticFunctionOpen.partner ) ].level then
                    UIManager.pushScene("ui_lineup_embattle")
                else
                    UIManager.pushScene("ui_lineup_embattle_old")
                end
            elseif sender == btnOne then
                AudioEngine.playEffect("sound/fight.mp3")
                utils.LevelUpgrade = false
                if barrierTimes >= barrierAllTimes then
                    showResetBarrierTimesDialog()
                else
                    if checkBag() then
                        return
                    end

                    if net.InstPlayer.int["8"] < energy then
                        UIFightTaskChoose.checkPlayerEnergy()
                        return
                    end
                    -----进入战斗---------------
                    UIManager.popScene()
                    local barrierId = nil
                    local chapterId = nil
                    if objData.name then
                        barrierId = objData.id
                        chapterId = objData.chapterId
                    else
                        barrierId = objData.int["3"]
                        chapterId = DictBarrier[tostring(objData.int["3"])].chapterId
                    end
                    local param = { }
                    param.barrierLevelId = barrierLevelId
                    param.chapterId = chapterId
                    param.barrierId = barrierId
                    if objData.name and FightTaskData.FightData[chapterId] and FightTaskData.FightData[chapterId][barrierId] then
                        FightTaskData.FightData[chapterId][barrierId].record = nil
                        UIFightMain.setData(FightTaskData.FightData[chapterId][barrierId], param, dp.FightType.FIGHT_TASK.COMMON)
                        UIFightMain.loading()
                    else
                        utils.sendFightData(param, dp.FightType.FIGHT_TASK.COMMON)
                        UIFightMain.loading()
                        if barrierId == 9 then
                            UIFightTask.setShowPoster(true, barrierId)
                        end
                    end
                end
            else
                AudioEngine.playEffect("sound/fight.mp3")
                utils.LevelUpgrade = false
                local levelFlag = DictBarrierLevel[tostring(barrierLevelId)].level
                levelFlag = math.min(levelFlag, 3)
                if not objData.int or levelFlag > objData.int["6"] then
                    UIManager.showToast(string.format(Lang.ui_fight_task_choose28, levelFlag))
                    return
                end

                local VipNum = net.InstPlayer.int["19"]
                local fightEnabled = DictVIP[tostring(VipNum + 1)].isContinuFight
                if net.InstPlayer.int["4"] < OPENAKEYFIGHTLEVEL and fightEnabled == 0 then
                    UIManager.showToast(Lang.ui_fight_task_choose29 .. OPENAKEYFIGHTLEVEL .. Lang.ui_fight_task_choose30)
                    return
                end

                if checkBag() then
                    return
                end
                if barrierTimes < barrierAllTimes then
                    --- 10次战斗  不足十次按不足算
                    if barrierAllTimes - barrierTimes >= 10 then
                        if net.InstPlayer.int["8"] < energy * 10 then
                            UIFightTaskChoose.checkPlayerEnergy()
                            return
                        end
                        sendFightTenRequest(InstbarrierId, barrierLevelId, 10)
                    else
                        if net.InstPlayer.int["8"] < energy *(barrierAllTimes - barrierTimes) then
                            UIFightTaskChoose.checkPlayerEnergy()
                            return
                        end
                        sendFightTenRequest(InstbarrierId, barrierLevelId, barrierAllTimes - barrierTimes)
                    end
                else
                    showResetBarrierTimesDialog()
                end
            end
        end
    end
    btnOne:addTouchEventListener(TouchEvent)
    btnTen:addTouchEventListener(TouchEvent)
    btn_close:addTouchEventListener(TouchEvent)
    btn_help:addTouchEventListener(TouchEvent)
    btn_embattle:addTouchEventListener(TouchEvent)
end

function UIFightTaskChoose.setup()
    UIFightTaskChoose.Widget:setEnabled(true)

    if net.InstPlayerChapterType then
        for key, obj in pairs(net.InstPlayerChapterType) do
            if obj.int["3"] == 1 then
                maxChapterTypeObj = obj
            end
        end
    end
    if maxChapterTypeObj ~= nil then
        local coldNum = 0
        if maxChapterTypeObj.int["6"] ~= nil then
            coldNum = maxChapterTypeObj.int["6"]
        end
        local baseMoney = DictSysConfig[tostring(StaticSysConfig.chapterAKeyGold)].value
        local oneAddMoney = DictSysConfig[tostring(StaticSysConfig.chapterAKeyGoldAdd)].value
        coldMoney = baseMoney + coldNum * oneAddMoney
        -----元宝封顶----
        if coldMoney > DictSysConfig[tostring(StaticSysConfig.chapterBuyMaxGold)].value then
            coldMoney = DictSysConfig[tostring(StaticSysConfig.chapterBuyMaxGold)].value
        end
    end
    local image_task_star = { }

    local ui_name = ui_image_basemap:getChildByName("text_name")
    local ui_image = ui_image_basemap:getChildByName("image_boss")
    local ui_text_challenge_number = ui_image_basemap:getChildByName("text_challenge_number")
    local ui_text_cost_power = ui_image_basemap:getChildByName("text_cost_power")
    local ui_image_di_good = ui_image_basemap:getChildByName("image_di_good")
    image_task_star[1] = ui_image_basemap:getChildByName("image_task_star1")
    image_task_star[2] = ui_image_basemap:getChildByName("image_task_star2")
    image_task_star[3] = ui_image_basemap:getChildByName("image_task_star3")
    local image_task_all = ui_image_basemap:getChildByName("image_task_all")

    local barrierId = nil
    local barrierLevel = nil
    barrierTimes = nil
    if objData.name ~= nil then
        --- 最后一条实例数据
        barrierId = objData.id
        barrierLevel = 0
        barrierTimes = 0
    else
        barrierId = objData.int["3"]
        barrierLevel = objData.int["6"]
        barrierTimes = objData.int["4"]
        InstbarrierId = objData.int["1"]
        local resetTime = 0
        if objData.int["7"] ~= nil then
            resetTime = objData.int["7"]
        end
        ResetBarrierTimes = resetTime
        local baseMoney = DictSysConfig[tostring(StaticSysConfig.chapterAKeyGold)].value
        local oneAddMoney = DictSysConfig[tostring(StaticSysConfig.chapterAKeyGoldAdd)].value
        ResetBarrierMoney = baseMoney + resetTime * oneAddMoney
        -----元宝封顶----
        if ResetBarrierMoney > DictSysConfig[tostring(StaticSysConfig.chapterBuyMaxGold)].value then
            ResetBarrierMoney = DictSysConfig[tostring(StaticSysConfig.chapterBuyMaxGold)].value
        end
    end
    energy = DictBarrier[tostring(barrierId)].energy
    barrierAllTimes = DictBarrier[tostring(barrierId)].fightNum
    local cardId = DictBarrier[tostring(barrierId)].cardId
    local bigUiId = DictCard[tostring(cardId)].bigUiId
    local imageName = DictUI[tostring(bigUiId)].fileName
    local name = DictBarrier[tostring(barrierId)].name
    ui_name:setString(name)
    ui_image:loadTexture("image/" .. imageName)
    ui_text_cost_power:setString(Lang.ui_fight_task_choose31 .. energy)
    ui_text_challenge_number:setString(Lang.ui_fight_task_choose32 .. barrierTimes .. "/" .. barrierAllTimes)
    local maxBarrierLevel = { level = 0 }
    for key, obj in pairs(DictBarrierLevel) do
        if obj.barrierId == barrierId then
            if obj.level > maxBarrierLevel.level then
                maxBarrierLevel = obj
            end
        end
    end
    for i = 1, 3 do
        if i <= maxBarrierLevel.level then
            image_task_star[i]:setVisible(true)
        else
            image_task_star[i]:setVisible(false)
        end
        utils.GrayWidget(image_task_star[i], i > barrierLevel)
    end

    image_task_all:setVisible(maxBarrierLevel.level == 4)
    image_task_all:loadTexture("ui/" ..(barrierLevel == maxBarrierLevel.level and "fight_win.png" or "fight_win_h.png"))

    if barrierAllTimes - barrierTimes < 10 then
        if barrierAllTimes - barrierTimes > 0 then
            btnTen:setTitleText(string.format(Lang.ui_fight_task_choose33, barrierAllTimes - barrierTimes))
        else
            btnTen:setTitleText(Lang.ui_fight_task_choose34)
        end
    else
        btnTen:setTitleText(string.format(Lang.ui_fight_task_choose35, 10))
    end

    local exp = DictLevelProp[tostring(net.InstPlayer.int["4"])].oneWarExp
    local image_get_di = ccui.Helper:seekNodeByName(UIFightTaskChoose.Widget, "image_get_di")

    local text_money = image_get_di:getChildByName("image_yin"):getChildByName("text_number")
    local text_exp = image_get_di:getChildByName("image_exp"):getChildByName("text_number")
    text_money:setString(maxBarrierLevel.copper)
    text_exp:setString(exp)
    barrierLevelId = maxBarrierLevel.id
    local dropThing = { }
    local function showDropInfo()
    ----------------掉落物品显示------------
        
        local things = DictBarrier[tostring(barrierId)].things
        local thingsTable = utils.stringSplit(things, ";")
        for key, obj in pairs(thingsTable) do
            dropThing[#dropThing + 1] = utils.stringSplit(obj, "_")
        end
        for i = 1, 6 do
            local ui_image_good = ui_image_di_good:getChildByName("image_frame_good" .. i)
            if i > #dropThing then
                ui_image_good:setVisible(false)
            else
                ui_image_good:setVisible(true)
                local ui_image = ui_image_good:getChildByName("image_good")
                local ui_name = ui_image:getChildByName("text_good_name")
                local tableTypeId, tableFieldId, thingNum = dropThing[i][1], dropThing[i][2], dropThing[i][3]
                local name, Icon = utils.getDropThing(tableTypeId, tableFieldId)
                ui_name:setString(name)
                ui_image:loadTexture(Icon)
                utils.addBorderImage(tableTypeId, tableFieldId, ui_image_good)
            end
        end
        local sdropThing = utils.stringSplit( sDropThing , ";" )
        for i = 1, 2 do
            local image_frame_good = ui_image_di_good:getChildByName("image_frame_good" .. ( 6+i) )
            if i > #sdropThing then
                image_frame_good:setVisible(false)
            else
                image_frame_good:setVisible(true)
            end
        end
    end
    --主线副本特殊物品掉落预览-----
     if DictBarrier[tostring(barrierId)].type == 3 and tonumber(barrierId) ~= 1  then
        local chapterId = 0
        if objData.name then
             chapterId = objData.chapterId
        else
             chapterId = DictBarrier[tostring(objData.int["3"])].chapterId
        end
        UIManager.showLoading()
        netSendPackage( { header = StaticMsgRule.sendActivityDrop , msgdata = { int = { chapterId  = tonumber( chapterId )} } } , function( pack )
            local POSITION = {
                { 69 , 174 } ,
                { 167 , 174 } ,
                { 265 , 174 } ,
                { 69 , 68 } ,
                { 167 , 68 } ,
                { 265 , 68 } ,
            }
            showDropInfo()
          local sDropThing = pack.msgdata.string[ "1" ]
          if sDropThing then
            local length = #dropThing
             local sdropThing = utils.stringSplit( sDropThing , ";" )
 
                for i = 1, 2 do
                    local image_frame_good = ui_image_di_good:getChildByName("image_frame_good" .. ( 6+i) )
                    if i > #sdropThing then
                        image_frame_good:setVisible(false)
                    else
                        image_frame_good:setVisible(true)
                        local ui_image = image_frame_good:getChildByName("image_good")
                        local ui_name = ui_image:getChildByName("text_good_name")
                        local thingInfo = utils.stringSplit( sdropThing[i] , "_" )
                        local tableTypeId, tableFieldId, thingNum = thingInfo[1], thingInfo[2], thingInfo[3]
                        local name, Icon = utils.getDropThing(tableTypeId, tableFieldId)
                        ui_name:setString(name)
                        ui_image:loadTexture(Icon)
                       -- utils.addBorderImage(tableTypeId, tableFieldId, image_frame_good)
                       image_frame_good:setPosition( cc.p( POSITION[ length + i ][ 1 ] , POSITION[ length + i ][ 2 ] ) )
                    end
                end

   
          end
        end)
    else
        showDropInfo()
    end

  
    UIGuidePeople.isGuide(nil, UIFightTaskChoose)
end

function UIFightTaskChoose.setData(_data)
    objData = _data
end

-----到达24点复位-----------
function UIFightTaskChoose.ResetData()
    if objData ~= nil and objData.name == nil then
        objData.int["4"] = 0
        objData.int["7"] = 0
    end
    UIFightTaskChoose.reset = true
    if maxChapterTypeObj ~= nil then
        maxChapterTypeObj.int["6"] = 0
    end
end

function UIFightTaskChoose.free()
end

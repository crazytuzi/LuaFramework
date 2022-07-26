require"Lang"
UIAwardSign = {
    todayRechargeGold = 0
}
local scrollView = nil
local listItem = nil
local signFlag = 1
local signType = {
    common = 1,
    luxury = 2
}
UIAwardSign.DictActivitySignIn1 = { }
UIAwardSign.DictActivitySignIn2 = { }

local function CallbackFunc(pack)
    if pack.header == StaticMsgRule.initSignIn then
        if pack.msgdata.message.DictActivitySignIn1.message then
            UIAwardSign.DictActivitySignIn1 = pack.msgdata.message.DictActivitySignIn1.message
        end
        if pack.msgdata.message.DictActivitySignIn2.message then
            UIAwardSign.DictActivitySignIn2 = pack.msgdata.message.DictActivitySignIn2.message
        end
        if UIAwardSign.Widget and UIAwardSign.Widget:getParent() then
            UIAwardSign.setup()
        end
    else
        if pack.header == StaticMsgRule.signIn then
            UIGuidePeople.isGuide(nil, UIAwardSign)
        end
        UIManager.flushWidget(UIHomePage)
        UIManager.flushWidget(UITeamInfo)
        UIAwardSign.showThings = pack.header == StaticMsgRule.signIn or StaticMsgRule.twoSignIn
        UIManager.flushWidget(UIAwardSign)
    end
end

local function sendSignData(_dictActivitySignInId)
    local sendData = {
        header = StaticMsgRule.signIn,
        msgdata =
        {
            int =
            {
                dictActivitySignInId = _dictActivitySignInId
            }
        }
    }
    UIManager.showLoading()
    netSendPackage(sendData, CallbackFunc)
end

local function sendSignVipData(_instActivitySignInId)
    local sendData = {
        header = StaticMsgRule.twoSignIn,
        msgdata =
        {
            int =
            {
                instActivitySignInId = _instActivitySignInId
            }
        }
    }
    UIManager.showLoading()
    netSendPackage(sendData, CallbackFunc)
end

local function initNetData()
    UIManager.showLoading()
    local sendData = {
        header = StaticMsgRule.initSignIn,
    }
    netSendPackage(sendData, CallbackFunc)
end

local function setScrollViewItem(Item, obj)
    local ui_day = ccui.Helper:seekNodeByName(Item, "label_day")
    local ui_day = ccui.Helper:seekNodeByName(Item, "label_day")
    ui_day:setString((obj.int["3"] -1) % 30 + 1)
    local btn_challenge = Item:getChildByName("btn_challenge")
    btn_challenge:setPressedActionEnabled(true)
    local instData = nil
    if net.InstActivitySignIn then
        for key, _obj in pairs(net.InstActivitySignIn) do
            if signFlag == _obj.int["3"] then
                instData = _obj
            end
        end
    end
    local _type = 1
    --- 1 领取 2 领过的 3 未达成的 4 vip签到
    local tableTime = nil
    if instData then
        tableTime = utils.changeTimeFormat(instData.string["8"])
        -- updateTime
    end
    if instData then
        if obj.int["3"] < instData.int["4"] then
            -- 领过的
            _type = 2
            btn_challenge:setTitleText(Lang.ui_award_sign1)
            btn_challenge:setEnabled(false)
            utils.GrayWidget(btn_challenge, true)
        elseif obj.int["3"] == instData.int["4"] + 1 and tonumber(tableTime[3]) ~= tonumber(dp.loginDay) then
            _type = 1
            btn_challenge:setTitleText(Lang.ui_award_sign2)
            btn_challenge:setEnabled(true)
            utils.GrayWidget(btn_challenge, false)
        elseif obj.int["3"] == instData.int["4"] then
            if UIAwardSign.showThings then
                utils.showGetThings(obj.string["5"])
                UIAwardSign.showThings = false
            end
            if instData.int["5"] == 1 and obj.int["6"] ~= 0 and tonumber(tableTime[3]) == tonumber(dp.loginDay) then
                _type = 4
                btn_challenge:setTitleText(Lang.ui_award_sign3)
                btn_challenge:setEnabled(true)
                utils.GrayWidget(btn_challenge, false)
            else
                _type = 2
                btn_challenge:setTitleText(Lang.ui_award_sign4)
                btn_challenge:setEnabled(false)
                utils.GrayWidget(btn_challenge, true)
            end
        else
            _type = 3
            btn_challenge:setTitleText(Lang.ui_award_sign5)
            btn_challenge:setEnabled(false)
            utils.GrayWidget(btn_challenge, true)
        end
    else
        if obj.int["3"] == 1 then
            _type = 1
            btn_challenge:setTitleText(Lang.ui_award_sign6)
            btn_challenge:setEnabled(true)
            utils.GrayWidget(btn_challenge, false)
            UIGuidePeople.isGuide(btn_challenge, UIAwardSign)
        else
            _type = 3
            btn_challenge:setTitleText(Lang.ui_award_sign7)
            btn_challenge:setEnabled(false)
            utils.GrayWidget(btn_challenge, true)
        end
    end
    local function jumpCharge()
        utils.checkGOLD(1)
    end

    local function btnTouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_challenge then
                if _type == 1 then
                    if signFlag == signType.luxury then
                        if UIAwardSign.todayRechargeGold < DictSysConfig[tostring(StaticSysConfig.signInCondition)].value then
                            UIManager.showToast(Lang.ui_award_sign8)
                            return
                        end
                    end
                    sendSignData(obj.int["1"])
                elseif _type == 4 then
                    if net.InstPlayer.int["19"] < obj.int["6"] then
                        utils.PromptDialog(jumpCharge, Lang.ui_award_sign9 .. obj.int["6"] .. Lang.ui_award_sign10)
                    else
                        sendSignVipData(obj.int["1"])
                    end
                end
            end
        end
    end
    btn_challenge:addTouchEventListener(btnTouchEvent)
    local awardData = utils.stringSplit(obj.string["5"], ";")
    local image_frame_good = { }
    for i = 1, 2 do
        image_frame_good[i] = ccui.Helper:seekNodeByName(Item, "image_frame_good" .. i)
    end
    if awardData and next(awardData) then
        for i = 1, 2 do
            if i > #awardData then
                image_frame_good[i]:setVisible(false)
            else
                image_frame_good[i]:setVisible(true)
            end
        end
        for i, obj in pairs(awardData) do
            if i > 2 then
                break
            end
            local _awardTableData = utils.stringSplit(obj, "_")
            local name, icon = utils.getDropThing(_awardTableData[1], _awardTableData[2])
            local thingIcon = image_frame_good[i]:getChildByName("image_good")
            local thingCount = image_frame_good[i]:getChildByName("text_price")
            local tableTypeId, tableFieldId, value = _awardTableData[1], _awardTableData[2], _awardTableData[3]
            thingIcon:loadTexture(icon)
            thingCount:setString("×" .. value)
            utils.addBorderImage(tableTypeId, tableFieldId, image_frame_good[i])
            utils.showThingsInfo(image_frame_good[i], tableTypeId, tableFieldId)
            if signFlag == signType.luxury then
                utils.addThingParticle(obj, thingIcon, true)
            end
        end
    else
        UIManager.showToast(Lang.ui_award_sign11)
    end
end

local function selectedBtnChange(flag)
    local btn_common = ccui.Helper:seekNodeByName(UIAwardSign.Widget, "btn_luxury")
    local btn_luxury = ccui.Helper:seekNodeByName(UIAwardSign.Widget, "btn_common")
    local ui_image_hint = ccui.Helper:seekNodeByName(UIAwardSign.Widget, "image_hint")
    local btn_prize_all = ccui.Helper:seekNodeByName(UIAwardSign.Widget, "btn_prize_all")
    if flag == signType.common then
        btn_prize_all:setVisible(true)
        ui_image_hint:setVisible(false)
        btn_common:loadTextureNormal("ui/yh_btn02.png")
        btn_common:getChildByName("text_prop"):setTextColor(cc.c4b(51, 25, 4, 255))
        btn_luxury:loadTextureNormal("ui/yh_btn01.png")
        btn_luxury:getChildByName("text_gem"):setTextColor(cc.c4b(255, 255, 255, 255))
    elseif flag == signType.luxury then
        btn_prize_all:setVisible(false)
        ui_image_hint:setVisible(true)
        btn_luxury:loadTextureNormal("ui/yh_btn02.png")
        btn_luxury:getChildByName("text_gem"):setTextColor(cc.c4b(51, 25, 4, 255))
        btn_common:loadTextureNormal("ui/yh_btn01.png")
        btn_common:getChildByName("text_prop"):setTextColor(cc.c4b(255, 255, 255, 255))
    end
end

local function expalain()
    local childs = UIManager.uiLayer:getChildren()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local bg_image = cc.Scale9Sprite:create("ui/dialog_bg.png")
    bg_image:setAnchorPoint(cc.p(0.5, 0.5))
    bg_image:setPreferredSize(cc.size(480, 300))
    bg_image:setPosition(cc.p(visibleSize.width / 2, visibleSize.height / 2 - 30))
    bg_image:retain()
    local bgSize = bg_image:getPreferredSize()
    local title = ccui.Text:create()
    title:setString(Lang.ui_award_sign12)
    title:setFontSize(35)
    title:setAnchorPoint(cc.p(0, 0.5))
    title:setFontName(dp.FONT)
    title:setTextColor(cc.c4b(255, 255, 0, 255))
    title:setPosition(cc.p(30, bgSize.height - 50))
    bg_image:addChild(title)
    local but_ok = ccui.Button:create("ui/tk_btn01.png")
    local description = ccui.Text:create()
    description:setFontSize(20)
    description:setFontName(dp.FONT)
    description:setAnchorPoint(cc.p(0.5, 0.5))
    description:setTextAreaSize(cc.size(430, 300))
    description:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    description:setString(Lang.ui_award_sign13)
    description:setPosition(cc.p(bg_image:getPreferredSize().width / 2, bg_image:getPreferredSize().height / 2 + 10))
    but_ok:setPosition(cc.p(bg_image:getPreferredSize().width / 2, but_ok:getContentSize().height / 2 + 20))
    bg_image:addChild(but_ok, 3)
    bg_image:addChild(description, 3)
    local function btnTouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            UIAwardSign.Widget:removeChildByTag(101)
            cc.release(bg_image)
            for i = 1, #childs do
                childs[i]:setEnabled(true)
            end
        end
    end
    but_ok:setTitleColor(cc.c3b(255, 255, 255))
    but_ok:setTitleFontSize(25)
    but_ok:setTitleText(Lang.ui_award_sign14)
    but_ok:setTitleFontName(dp.FONT)
    but_ok:addTouchEventListener(btnTouchEvent)
    UIAwardSign.Widget:addChild(bg_image, 100, 101)
    for i = 1, #childs do
        if childs[i] ~= bg_image then
            childs[i]:setEnabled(false)
        end
    end
end

function UIAwardSign.init()
    UIAwardSign.showThings = false
    local btn_close = ccui.Helper:seekNodeByName(UIAwardSign.Widget, "btn_close")
    local btn_common = ccui.Helper:seekNodeByName(UIAwardSign.Widget, "btn_luxury")
    local btn_luxury = ccui.Helper:seekNodeByName(UIAwardSign.Widget, "btn_common")
    local btn_prize_all = ccui.Helper:seekNodeByName(UIAwardSign.Widget, "btn_prize_all")
    btn_close:setPressedActionEnabled(true)
    btn_luxury:setPressedActionEnabled(true)
    btn_common:setPressedActionEnabled(true)
    btn_prize_all:setPressedActionEnabled(true)

    local function btnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioEngine.playEffect("sound/button.mp3")
            if sender == btn_common then
                if signFlag == signType.common then
                    return
                end
                signFlag = signType.common
                UIAwardSign.setup()
            elseif sender == btn_luxury then
                if signFlag == signType.luxury then
                    return
                end
                local function chargeCallBack(pack)
                    if pack.msgdata.int and pack.msgdata.int["1"] then
                        UIAwardSign.todayRechargeGold = pack.msgdata.int["1"]
                    else
                        return
                    end
                    signFlag = signType.luxury
                    UIAwardSign.setup()
                end
                if UIAwardSign.todayRechargeGold >= DictSysConfig[tostring(StaticSysConfig.signInCondition)].value then
                    signFlag = signType.luxury
                    UIAwardSign.setup()
                else
                    utils.checkGOLD(4, chargeCallBack)
                end
            elseif sender == btn_close then
                UIManager.popScene()
            elseif sender == btn_prize_all then
                expalain()
            end
        end
    end
    btn_luxury:addTouchEventListener(btnEvent)
    btn_common:addTouchEventListener(btnEvent)
    btn_close:addTouchEventListener(btnEvent)
    btn_prize_all:addTouchEventListener(btnEvent)
    scrollView = ccui.Helper:seekNodeByName(UIAwardSign.Widget, "view_award_lv")
    --  滚动层
    listItem = scrollView:getChildByName("image_base_lv")
    listItem:removeFromParent()
end

function UIAwardSign.setup()
    if listItem:getReferenceCount() == 1 then
        listItem:retain()
    end
    scrollView:removeAllChildren()
    if not signFlag then
        signFlag = signType.common
    end
    selectedBtnChange(signFlag)
    local _date = os.date("*t", utils.getCurrentTime())
    local ui_hint = ccui.Helper:seekNodeByName(UIAwardSign.Widget, "text_hint_center")
    ui_hint:setString(string.format(Lang.ui_award_sign15, _date.month))
    ui_hint:setVisible(signFlag == signType.common)
    local signThing = { }
    local _thing = nil
    if signFlag == signType.common and next(UIAwardSign.DictActivitySignIn1) then
        _thing = UIAwardSign.DictActivitySignIn1
    elseif signFlag == signType.luxury and next(UIAwardSign.DictActivitySignIn2) then
        _thing = UIAwardSign.DictActivitySignIn2
    else
        initNetData()
        return
    end
    if _thing then
        for key, obj in pairs(_thing) do
            table.insert(signThing, obj)
        end
        local function compare(value1, value2)
            return value1.int["3"] > value2.int["3"]
        end
        utils.quickSort(signThing, compare)
    end
    if next(signThing) then
        UIAwardSign.needSignDay = nil
        local instData = nil
        if net.InstActivitySignIn then
            for key, _obj in pairs(net.InstActivitySignIn) do
                if signFlag == _obj.int["3"] then
                    instData = _obj
                end
            end
        end
        if instData then
            local tableTime = utils.changeTimeFormat(instData.string["8"])
            for i, obj in ipairs(signThing) do
                if obj.int["3"] < instData.int["4"] then
                    -- 领过的
                    UIAwardSign.needSignDay = obj.int["3"]
                elseif obj.int["3"] == instData.int["4"] + 1 and tonumber(tableTime[3]) ~= tonumber(dp.loginDay) then
                    UIAwardSign.needSignDay = obj.int["3"]
                elseif obj.int["3"] == instData.int["4"] then
                    UIAwardSign.needSignDay = obj.int["3"]
                end
            end
        end
        UIAwardSign.needSignDay = UIAwardSign.needSignDay or 1
        if signFlag == signType.luxury and next(UIAwardSign.DictActivitySignIn2) then
            UIAwardSign.needSignDay = ( ( UIAwardSign.needSignDay - 1 ) % #signThing ) + 1
        end

        utils.updateScrollView(UIAwardSign, scrollView, listItem, signThing, setScrollViewItem, { jumpTo = UIAwardSign.needSignDay })
    end
    UIAwardSign.showThings = false
end

function UIAwardSign.free()
    scrollView:removeAllChildren()
    signFlag = nil
    if not tolua.isnull(listItem) and listItem:getReferenceCount() >= 1 then
        listItem:release()
        listItem = nil
    end
    UIGuidePeople.isGuide(nil, UIAwardSign)
    UIAwardSign.showThings = false
end

require"Lang"
UIAwardGift = { }
UIAwardGift.OperateType = {
    sign = 1,
    lv = 2,
    gift = 3,
    prize = 4,
}
local awardName = { Lang.ui_award_gift1, Lang.ui_award_gift2, Lang.ui_award_gift3, Lang.ui_award_gift4 }
local _operateType = nil
local image_base_gift = nil
local image_base_gift_center = nil
local _awardData = nil

local function CallbackFunc(pack)
    UIManager.flushWidget(UIAwardGift)
    UIManager.flushWidget(UITeamInfo)
    UIManager.flushWidget(UIHomePage)
    UIAwardGet.setOperateType(UIAwardGet.operateType.award, _awardData)
    UIManager.pushScene("ui_award_get")
end

--- 开服礼包领取奖励------
local function sendOpenServiceBagData(_dictID)
    local InstData = nil
    for key, obj in pairs(net.InstActivityOpenServiceBag) do
        InstData = obj
    end
    local sendData = {
        header = StaticMsgRule.openServiceBag,
        msgdata =
        {
            int =
            {
                instActivityOpenServiceBagId = InstData.int["1"],
                dictActivityOpenServiceBagId = _dictID
            },
        }
    }
    UIManager.showLoading()
    netSendPackage(sendData, CallbackFunc)
end

--- 等级礼包领取奖励------
local function sendlevelBagData(_dictID)
    local sendData = nil
    if UIGuidePeople.guideStep == "7B3" then
        sendData = {
            header = StaticMsgRule.levelBag,
            msgdata =
            {
                int =
                {
                    dictActivityLevelBagId = _dictID
                },
                string =
                {
                    step = "7B4"
                }
            }
        }
    else
        sendData = {
            header = StaticMsgRule.levelBag,
            msgdata =
            {
                int =
                {
                    dictActivityLevelBagId = _dictID
                },
            }
        }
    end
    UIManager.showLoading()
    netSendPackage(sendData, CallbackFunc)
end

--- 领奖中心数据------
local function sendAwardData(_instPlayerAwardId)
    local sendData = {
        header = StaticMsgRule.award,
        msgdata =
        {
            int =
            {
                instPlayerAwardId = _instPlayerAwardId
            }
        }
    }
    UIManager.showLoading()
    netSendPackage(sendData, CallbackFunc)
end

local function sendAllAwardData()
    local sendData = {
        header = StaticMsgRule.aKeyAward,
    }
    UIManager.showLoading()
    netSendPackage(sendData, CallbackFunc)
end

local function setScrollViewItem(_Item, _obj)
    local awardData = nil
    local btn_prize = _Item:getChildByName("btn_prize")
    btn_prize:setPressedActionEnabled(true)
    local function btnTouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_prize then
                if _operateType == UIAwardGift.OperateType.gift then
                    -- 开服礼包
                    _awardData = awardData
                    sendOpenServiceBagData(_obj.id)
                elseif _operateType == UIAwardGift.OperateType.lv then
                    -- 等级礼包
                    _awardData = awardData
                    sendlevelBagData(_obj.id)
                elseif _operateType == UIAwardGift.OperateType.prize then
                    _awardData = awardData
                    sendAwardData(_obj.int["1"])
                end

            end
        end
    end
    btn_prize:addTouchEventListener(btnTouchEvent)
    local ui_text_lv = ccui.Helper:seekNodeByName(_Item, "text_lv")
    local ui_text_begin = ccui.Helper:seekNodeByName(_Item, "text_begin")
    local ui_text_award_time = _Item:getChildByName("text_award_time")
    local image_frame_good = { }
    for i = 1, 3 do
        image_frame_good[i] = ccui.Helper:seekNodeByName(_Item, "image_frame_good" .. i)
    end

    if _operateType == UIAwardGift.OperateType.lv then
        -- 等级礼包
        ui_text_lv:setVisible(true)
        ui_text_begin:setVisible(false)
        ui_text_lv:getChildByName("text_lv_number"):setString(_obj.id)
        if _obj.things then
            awardData = utils.stringSplit(_obj.things, ";")
        else
            cclog("缺少数据")
        end
        local getDatas = nil
        if net.InstActivityLevelBag then
            local InstData = nil
            for key, obj in pairs(net.InstActivityLevelBag) do
                InstData = obj
            end
            getDatas = utils.stringSplit(InstData.string["3"], ";")
            --- 已经领取
        end
        local flag = false
        if getDatas ~= nil then
            for key, obj in pairs(getDatas) do
                if tonumber(obj) == _obj.id then
                    flag = true
                    break
                end
            end
        end
        local InstLevel = net.InstPlayer.int["4"]
        if flag then
            btn_prize:setVisible(false)
            if not _Item:getChildByName("ylq") then
                local ylqImage = ccui.ImageView:create("ui/rw_ylq.png")
                ylqImage:setName("ylq")
                _Item:addChild(ylqImage)
                ylqImage:setPosition(cc.p(btn_prize:getPosition()))
            else
                _Item:getChildByName("ylq"):setVisible(true)
            end
        else
            btn_prize:setVisible(true)
            if InstLevel < _obj.id then
                btn_prize:setEnabled(false)
                utils.GrayWidget(btn_prize, true)
                if _Item:getChildByName("ylq") then
                    _Item:getChildByName("ylq"):setVisible(false)
                end
            else
                btn_prize:setEnabled(true)
                utils.GrayWidget(btn_prize, false)
                if _Item:getChildByName("ylq") then
                    _Item:getChildByName("ylq"):setVisible(false)
                end
            end
        end
        if _obj.id == 5 and UIGuidePeople.guideStep == "7B2" then
            UIGuidePeople.isGuide(btn_prize, UIAwardGift)
        elseif _obj.id == 10 and UIGuidePeople.levelStep == "10_2" then
            UIGuidePeople.isGuide(btn_prize, UIAwardGift)
        end
    elseif _operateType == UIAwardGift.OperateType.gift then
        -- 开服礼包
        ui_text_begin:setVisible(true)
        ui_text_lv:setVisible(false)
        ui_text_begin:setString(Lang.ui_award_gift5)
        ui_text_begin:getChildByName("text_begin_number"):setString(_obj.id)
        if _obj.things then
            awardData = utils.stringSplit(string.gsub(_obj.things, dp.isNewServer() and "^[^|]+|" or "|[^|]+$", ""), ";")
        else
            cclog("缺少数据")
        end
        local InstData = nil
        for key, obj in pairs(net.InstActivityOpenServiceBag) do
            InstData = obj
        end
        local getDatas = utils.stringSplit(InstData.string["5"], ";")
        --- 已经领取
        local notGetDatas = utils.stringSplit(InstData.string["4"], ";")
        -- 未领取
        local flag_1, flag_2 = false, false
        for key, obj in pairs(getDatas) do
            if tonumber(obj) == _obj.id then
                flag_1 = true
                break
            end
        end
        for key, obj in pairs(notGetDatas) do
            if tonumber(obj) == _obj.id then
                flag_2 = true
                break
            end
        end
        if flag_2 and not flag_1 then
            --- 未领取
            btn_prize:setVisible(true)
            btn_prize:setEnabled(true)
            utils.GrayWidget(btn_prize, false)
            if _Item:getChildByName("ylq") then
                _Item:getChildByName("ylq"):setVisible(false)
            end
        elseif flag_1 and not flag_2 then
            --- 已领取
            btn_prize:setVisible(false)
            if not _Item:getChildByName("ylq") then
                local ylqImage = ccui.ImageView:create("ui/rw_ylq.png")
                ylqImage:setName("ylq")
                _Item:addChild(ylqImage)
                ylqImage:setPosition(cc.p(btn_prize:getPosition()))
            else
                _Item:getChildByName("ylq"):setVisible(true)
            end
        elseif not flag_1 and not flag_2 then
            btn_prize:setVisible(true)
            btn_prize:setEnabled(false)
            utils.GrayWidget(btn_prize, true)
            if _Item:getChildByName("ylq") then
                _Item:getChildByName("ylq"):setVisible(false)
            end
        else
            cclog("服务器出错")
        end
    elseif _operateType == UIAwardGift.OperateType.prize then
        -- 领奖中心
        if _obj.string["4"] ~= "" then
            awardData = utils.stringSplit(_obj.string["4"], ";")
        else
            cclog("缺少奖励物品数据！")
        end
        ui_text_lv:setString(awardName[_obj.int["3"]])
        _Item:getChildByName("text_award_ad"):setString(_obj.string["6"])
        local _operTime = _obj.string["5"]
        if _operTime == nil or _operTime == "" then
            _operTime = _obj.string["8"]
        end
        local time_tab = utils.changeTimeFormat(_operTime)
        ui_text_award_time:setString(string.format(Lang.ui_award_gift6, time_tab[2], time_tab[3], time_tab[5]))
        if _obj.int["5"] == 1 then
            btn_prize:setVisible(false)
            if not _Item:getChildByName("ylq") then
                local ylqImage = ccui.ImageView:create("ui/rw_ylq.png")
                ylqImage:setName("ylq")
                _Item:addChild(ylqImage)
                ylqImage:setPosition(cc.p(btn_prize:getPosition()))
            else
                _Item:getChildByName("ylq"):setVisible(true)
            end
        else
            btn_prize:setVisible(true)
            if _Item:getChildByName("ylq") then
                _Item:getChildByName("ylq"):setVisible(false)
            end
        end
    end
    if awardData and next(awardData) then
        for i = 1, 3 do
            if i > #awardData then
                image_frame_good[i]:setVisible(false)
            else
                image_frame_good[i]:setVisible(true)
            end
        end
        for i, obj in pairs(awardData) do
            if i > 3 then
                break
            end
            local _awardTableData = utils.stringSplit(obj, "_")
            local name, icon = utils.getDropThing(_awardTableData[1], _awardTableData[2])
            local thingIcon = image_frame_good[i]:getChildByName("image_good")
            local thingName = image_frame_good[i]:getChildByName("text_name")
            local thingCount = ccui.Helper:seekNodeByName(image_frame_good[i], "text_number")
            local tableTypeId, tableFieldId, value = _awardTableData[1], _awardTableData[2], _awardTableData[3]
            thingName:setString(name)
            thingIcon:loadTexture(icon)
            thingCount:setString(tostring(value))
            utils.addBorderImage(tableTypeId, tableFieldId, image_frame_good[i])
            utils.showThingsInfo(thingIcon, tableTypeId, tableFieldId)
        end
    else
        UIManager.showToast(Lang.ui_award_gift7)
    end
end

function UIAwardGift.init(...)
    local btn_close = ccui.Helper:seekNodeByName(UIAwardGift.Widget, "btn_close")
    local btn_prize_all = ccui.Helper:seekNodeByName(UIAwardGift.Widget, "btn_prize_all")
    btn_close:setPressedActionEnabled(true)
    btn_prize_all:setPressedActionEnabled(true)
    local function btnTouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioEngine.playEffect("sound/button.mp3")
            if sender == btn_close then
                UIManager.popScene()
            elseif sender == btn_prize_all then
                -- 全部领取
                local things = nil
                for key, obj in pairs(net.InstPlayerAward) do
                    if things ~= nil then
                        things = things .. ";" .. obj.string["4"]
                    else
                        things = obj.string["4"]
                    end
                end
                if things ~= nil then
                    local dropData = utils.stringSplit(things, ";")
                    _awardData = { }
                    for key, obj in pairs(dropData) do
                        local data = utils.stringSplit(obj, "_")
                        local flag = false
                        if next(_awardData) then
                            for _key, _obj in pairs(_awardData) do
                                local _data = utils.stringSplit(_obj, "_")
                                if _data[1] == data[1] and _data[2] == data[2] then
                                    flag = true
                                    _awardData[_key] = _data[1] .. "_" .. _data[2] .. "_" ..(_data[3] + data[3])
                                end
                            end
                        end
                        if flag == false then
                            table.insert(_awardData, obj)
                        end
                    end
                    sendAllAwardData()
                end
            end
        end
    end
    btn_close:addTouchEventListener(btnTouchEvent)
    btn_prize_all:addTouchEventListener(btnTouchEvent)
    local scrollView = ccui.Helper:seekNodeByName(UIAwardGift.Widget, "view_award_lv")
    --  滚动层
    image_base_gift = scrollView:getChildByName("image_base_gift")
    image_base_gift_center = scrollView:getChildByName("image_base_gift_center")
    image_base_gift:removeFromParent()
    image_base_gift_center:removeFromParent()
end

function UIAwardGift.setup(...)
    if image_base_gift:getReferenceCount() == 1 then
        image_base_gift:retain()
    end
    if image_base_gift_center:getReferenceCount() == 1 then
        image_base_gift_center:retain()
    end
    local scrollView = ccui.Helper:seekNodeByName(UIAwardGift.Widget, "view_award_lv")
    scrollView:removeAllChildren()
    local ui_image_hint_begin = ccui.Helper:seekNodeByName(UIAwardGift.Widget, "text_hint_begin")
    local ui_text_hint_center = ccui.Helper:seekNodeByName(UIAwardGift.Widget, "text_hint_center")
    local ui_image_award_title = ccui.Helper:seekNodeByName(UIAwardGift.Widget, "image_award_title")
    if _operateType == UIAwardGift.OperateType.lv then
        -- 等级礼包
        ccui.Helper:seekNodeByName(UIAwardGift.Widget, "btn_prize_all"):setVisible(false)
        ui_image_award_title:loadTexture("ui/award_lv.png")
        ui_image_hint_begin:setVisible(false)
        ui_text_hint_center:setVisible(false)
        local ThingData = { }
        for key, obj in pairs(DictActivityLevelBag) do
            table.insert(ThingData, obj)
        end
        utils.quickSort(ThingData, function(value1, value2)
            return value1.id > value2.id
        end )
        utils.updateView(UIAwardGift, scrollView, image_base_gift, ThingData, setScrollViewItem)
    elseif _operateType == UIAwardGift.OperateType.gift then
        -- 开服礼包
        ccui.Helper:seekNodeByName(UIAwardGift.Widget, "btn_prize_all"):setVisible(false)
        ui_image_award_title:loadTexture("ui/award_begin.png")
        ui_image_hint_begin:setVisible(true)
        local _cardName = ""
        local _things = utils.stringSplit(string.gsub(DictActivityOpenServiceBag["7"].things, dp.isNewServer() and "^[^|]+|" or "|[^|]+$", ""), ";")
        if _things then
            local _cardId = utils.stringSplit(_things[#_things], "_")[2]
            _cardName = DictCard[_cardId].name
            _things = nil
        end
        ui_image_hint_begin:setString(Lang.ui_award_gift8 .. _cardName)
        ui_text_hint_center:setVisible(false)
        local ThingData = { }
        for key, obj in pairs(DictActivityOpenServiceBag) do
            table.insert(ThingData, obj)
        end
        utils.quickSort(ThingData, function(value1, value2)
            return value1.id > value2.id
        end )
        utils.updateView(UIAwardGift, scrollView, image_base_gift, ThingData, setScrollViewItem)
    elseif _operateType == UIAwardGift.OperateType.prize then
        -- 领奖中心
        local btn_prize_all = ccui.Helper:seekNodeByName(UIAwardGift.Widget, "btn_prize_all")
        btn_prize_all:setVisible(true)
        ui_image_award_title:loadTexture("ui/award_centre.png")
        ui_image_hint_begin:setVisible(false)
        ui_text_hint_center:setVisible(true)
        local awardNumber = 0
        if net.InstPlayerAward then
            local ThingData = { }
            for key, obj in pairs(net.InstPlayerAward) do
                awardNumber = awardNumber + 1
                table.insert(ThingData, obj)
            end
            ui_text_hint_center:getChildByName("text_award_number"):setString(Lang.ui_award_gift9 .. awardNumber)
            if awardNumber ~= 0 then
                btn_prize_all:setEnabled(true)
                utils.GrayWidget(btn_prize_all, false)
            else
                btn_prize_all:setEnabled(false)
                utils.GrayWidget(btn_prize_all, true)
            end
            utils.quickSort(ThingData, function(value1, value2)
                return utils.GetTimeByDate(value1.string["5"]) < utils.GetTimeByDate(value2.string["5"])
            end )
            utils.updateView(UIAwardGift, scrollView, image_base_gift_center, ThingData, setScrollViewItem)
        end
    end
end

function UIAwardGift.free()
    _operateType = nil
    _awardData = nil
    if not tolua.isnull(image_base_gift) and image_base_gift:getReferenceCount() >= 1 then
        image_base_gift:release()
        image_base_gift = nil
    end
    if not tolua.isnull(image_base_gift_center) and image_base_gift_center:getReferenceCount() >= 1 then
        image_base_gift_center:release()
        image_base_gift_center = nil
    end
    UIGuidePeople.isGuide(nil, UIAwardGift)
end

function UIAwardGift.setOperateType(operateType)
    _operateType = operateType
    UIManager.pushScene("ui_award_gift")
end

require"Lang"
UIActivityMiteer = { }
local instActivityObj = nil
local btn_vip = nil
local openEnabled = nil -- 是否开业
local countDownTimeOn = nil
local ui_timeTextOn = nil
local countDownTimeDown = nil
local ui_timeTextDown = nil
local ScheduleId = nil
local ui_timeTextOn_di = nil
local image_frame_good = nil
local ui_goodInfo = nil
local ui_imageYafei = nil
local hunyuanNumber = nil

-- flag 1 成为白金 2 分解 3 充值
function UIActivityMiteer.PromptDialog(info, flag)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local bg_image = cc.Scale9Sprite:create("ui/dialog_bg.png")
    bg_image:retain()
    bg_image:setAnchorPoint(cc.p(0.5, 0.5))
    bg_image:setPreferredSize(cc.size(500, 300))
    bg_image:setPosition(cc.p(visibleSize.width / 2, visibleSize.height / 2))
    local bgSize = bg_image:getPreferredSize()

    local title = ccui.Text:create()
    title:setString(Lang.ui_activity_miteer1)
    title:setFontName(dp.FONT)
    title:setFontSize(35)
    title:setTextColor(cc.c4b(255, 255, 0, 255))
    title:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.85))
    bg_image:addChild(title, 3)
    local msgLabel = ccui.Text:create()
    msgLabel:setString(info)
    msgLabel:setFontName(dp.FONT)
    msgLabel:setTextAreaSize(cc.size(425, 300))
    msgLabel:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    msgLabel:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    msgLabel:setFontSize(26)
    msgLabel:setTextColor(cc.c4b(255, 255, 255, 255))
    msgLabel:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.6))
    bg_image:addChild(msgLabel, 3)

    local closeBtn = ccui.Button:create("ui/btn_x.png", "ui/btn_x.png")
    closeBtn:setPressedActionEnabled(true)
    closeBtn:setTouchEnabled(true)
    closeBtn:setPosition(cc.p(bgSize.width - closeBtn:getContentSize().width * 0.3, bgSize.height - closeBtn:getContentSize().height * 0.3))
    bg_image:addChild(closeBtn, 3)
    local sureBtn = ccui.Button:create("ui/tk_btn01.png", "ui/tk_btn01.png")
    sureBtn:setTitleText(Lang.ui_activity_miteer2)
    sureBtn:setTitleFontName(dp.FONT)
    sureBtn:setTitleFontSize(25)
    sureBtn:setPressedActionEnabled(true)
    sureBtn:setTouchEnabled(true)
    sureBtn:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.25))
    bg_image:addChild(sureBtn, 3)

    local childs = UIManager.uiLayer:getChildren()
    local function btnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == sureBtn then
                if flag == 2 then
                    --- 分解
                    UIManager.hideWidget("ui_activity_panel")
                    UIManager.showWidget("ui_resolve")
                elseif flag == 3 then
                    --- 充值
                    UIManager.hideWidget("ui_activity_panel")
                    UIManager.showWidget("ui_shop")
                end
            end
            UIManager.uiLayer:removeChild(bg_image, true)
            cc.release(bg_image)
            for i = 1, #childs do
                childs[i]:setEnabled(true)
            end
        end
    end
    sureBtn:addTouchEventListener(btnEvent)
    closeBtn:addTouchEventListener(btnEvent)
    UIManager.uiLayer:addChild(bg_image, 10000)
    for i = 1, #childs do
        if childs[i]:getTag() ~= bg_image then
            childs[i]:setEnabled(false)
        end
    end
end

local function netCallbackFunc(pack)
    if tonumber(pack.header) == StaticMsgRule.updateAuctionOrHjy then
        UIActivityMiteer.setup()
    elseif tonumber(pack.header) == StaticMsgRule.platinumVIP then
        UIActivityMiteer.setup()
        UIActivityMiteer.PromptDialog(Lang.ui_activity_miteer3, 1)
    end
end
-- 1-拍卖行刷新物品 2-黑角域增加刷新次数 3-黑角域刷新物品

local function sendRefreshData()
    local sendData = {
        header = StaticMsgRule.updateAuctionOrHjy,
        msgdata =
        {
            int =
            {
                type = 1,
                instActivityId = instActivityObj.int["1"]
            }
        }
    }
    netSendPackage(sendData, netCallbackFunc)
end

local function sendVipData()
    local _instActivityId = 0
    if instActivityObj ~= nil then
        _instActivityId = instActivityObj.int["1"]
    end
    local sendData = {
        header = StaticMsgRule.platinumVIP,
        msgdata =
        {
            int =
            {
                instActivityId = _instActivityId
            }
        }
    }
    UIManager.showLoading()
    netSendPackage(sendData, netCallbackFunc)
end

local function sendConvertData(_instAuctionShopId, getGoods)
    local sendData = {
        header = StaticMsgRule.convertGoods,
        msgdata =
        {
            int =
            {
                type = 1,
                instAuctionShopId = _instAuctionShopId
            }
        }
    }
    UIManager.showLoading()
    netSendPackage(sendData, function(pack)
        UIActivityMiteer.setup()
        if getGoods then utils.showGetThings(getGoods) end
    end )
end

-----非白金贵宾才会执行此方法------
local function stopSchedule()
    if ScheduleId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(ScheduleId)
        ScheduleId = nil
        countDownTimeOn = 0
        openEnabled = false
        ccui.Helper:seekNodeByName(UIActivityMiteer.Widget, "image_yafei_closed"):setVisible(true)
        ui_imageYafei.frame:setVisible(false)
        ui_goodInfo.frame:setVisible(false)
        ccui.Helper:seekNodeByName(UIActivityMiteer.Widget, "image_hunyuan"):setVisible(false)
        ui_timeTextOn_di:setVisible(false)
        ccui.Helper:seekNodeByName(UIActivityMiteer.Widget, "btn_refresh"):setVisible(false)
        btn_vip:setPositionX(UIActivityMiteer.Widget:getContentSize().width / 2)
        for i = 1, 8 do
            image_frame_good[i]:setPosition(cc.p(image_frame_good[i].x, image_frame_good[i].y))
        end
        ccui.Helper:seekNodeByName(UIActivityMiteer.Widget, "image_foreshow"):setVisible(true)
    end
end

local function updateTime()
    if ui_timeTextOn_di:isVisible() then
        if countDownTimeOn ~= 0 then
            countDownTimeOn = countDownTimeOn - 1
            local hour = math.floor(countDownTimeOn / 3600)
            local min = math.floor(countDownTimeOn % 3600 / 60)
            local sec = countDownTimeOn % 60
            ui_timeTextOn:setString(string.format("%02d:%02d:%02d", hour, min, sec))
        else
            openEnabled = false
            stopSchedule()
        end
    end
    if ui_timeTextDown:isVisible() then
        if countDownTimeDown ~= 0 then
            countDownTimeDown = countDownTimeDown - 1
            local hour = math.floor(countDownTimeDown / 3600)
            local min = math.floor(countDownTimeDown % 3600 / 60)
            local sec = countDownTimeDown % 60
            ui_timeTextDown:setString(string.format(Lang.ui_activity_miteer4, hour, min, sec))
        else
            if ScheduleId then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(ScheduleId)
            end
            -----刷新------------
            sendRefreshData()
        end
    end

end

local function goodInfoAction(flag, obj)
    for i = 1, 8 do
        image_frame_good[i]:setEnabled(false)
    end
    local function setVisible()
        if flag == "right" then
            ui_imageYafei.frame:setVisible(false)
            if obj.int["8"] == 1 then
                local image_over = ui_goodInfo.frame:getChildByName("image_over")
                image_over:setScale(3)
                image_over:setVisible(true)
                image_over:runAction(cc.ScaleTo:create(0.2, 1))
                ui_goodInfo.frame:getChildByName("btn_exchange"):setVisible(false)
            else
                ui_goodInfo.frame:getChildByName("btn_exchange"):setVisible(true)
            end
        elseif flag == "left" then
            ui_goodInfo.frame:setVisible(false)
        end
        for i = 1, 8 do
            image_frame_good[i]:setEnabled(true)
        end
    end
    if flag == "right" then
        ui_goodInfo.frame:setVisible(true)
        ui_goodInfo.frame:setPosition(cc.p(UIActivityMiteer.Widget:getContentSize().width + ui_goodInfo.frame:getContentSize().width, ui_goodInfo.y))
        ui_goodInfo.frame:runAction(cc.MoveTo:create(0.5, cc.p(ui_goodInfo.x, ui_goodInfo.y)))
        ui_imageYafei.frame:runAction(cc.Sequence:create(cc.MoveTo:create(0.5, cc.p(ui_imageYafei.x - UIActivityMiteer.Widget:getContentSize().width, ui_imageYafei.y)), cc.CallFunc:create(setVisible)))
    elseif flag == "left" then
        ui_imageYafei.frame:setVisible(true)
        ui_imageYafei.frame:setPosition(cc.p(ui_imageYafei.x - UIActivityMiteer.Widget:getContentSize().width, ui_imageYafei.y))
        ui_imageYafei.frame:runAction(cc.MoveTo:create(0.5, cc.p(ui_imageYafei.x, ui_imageYafei.y)))
        ui_goodInfo.frame:runAction(cc.Sequence:create(cc.MoveTo:create(0.5, cc.p(UIActivityMiteer.Widget:getContentSize().width + ui_goodInfo.frame:getContentSize().width, ui_goodInfo.y)), cc.CallFunc:create(setVisible)))
    end
end
local function show(Enable, param)
    if Enable then
        local tableTypeId = param.tableTypeId
        local tableFieldId = param.tableFieldId
        local value = param.value
        local name, icon, _description = utils.getDropThing(tableTypeId, tableFieldId)
        local visibleSize = cc.Director:getInstance():getVisibleSize()
        local bg_image = cc.Scale9Sprite:create("ui/dialog_bg.png")
        bg_image:setAnchorPoint(cc.p(0.5, 0.5))
        bg_image:setPreferredSize(cc.size(350, 150))
        local bg_image_x = visibleSize.width / 2
        if param.Pos.x - bg_image:getPreferredSize().width / 2 < 0 then
            bg_image_x = bg_image:getPreferredSize().width / 2
        elseif param.Pos.x + bg_image:getPreferredSize().width / 2 > visibleSize.width then
            bg_image_x = visibleSize.width - bg_image:getPreferredSize().width / 2
        else
            bg_image_x = param.Pos.x
        end
        bg_image:setPosition(cc.p(bg_image_x, param.Pos.y + bg_image:getPreferredSize().height))
        local node = cc.Node:create()
        local image_di = ccui.ImageView:create("ui/quality_small_purple.png")
        local image = ccui.ImageView:create(icon)
        image:setPosition(cc.p(image_di:getContentSize().width / 2, image_di:getContentSize().height / 2))
        image_di:addChild(image)
        image_di:setPosition(cc.p(20, 20))
        image_di:setScale(0.7)
        local description = ccui.Text:create()
        description:setFontSize(20)
        description:setFontName(dp.FONT)
        description:setAnchorPoint(cc.p(0, 0.5))
        description:setString(_description)
        description:setTextAreaSize(cc.size(bg_image:getPreferredSize().width - image_di:getContentSize().width - 40, description:getContentSize().height * 2))
        description:setPosition(cc.p(cc.p(image_di:getPosition()).x + image_di:getContentSize().width / 2, 30))
        local text_num = ccui.Text:create()
        text_num:setFontSize(20)
        text_num:setFontName(dp.FONT)
        text_num:setAnchorPoint(cc.p(0, 0.5))
        text_num:setString(string.format(Lang.ui_activity_miteer5, value))
        text_num:setPosition(cc.p(cc.p(image_di:getPosition()).x + image_di:getContentSize().width / 2, -30))
        utils.addBorderImage(tableTypeId, tableFieldId, image_di)
        node:addChild(image_di)
        node:addChild(description)
        node:addChild(text_num)
        node:setPosition(cc.p(image_di:getContentSize().width / 2, bg_image:getPreferredSize().height / 2))
        bg_image:addChild(node, 3)
        UIActivityMiteer.Widget:addChild(bg_image, 100, 100)
    else
        if UIActivityMiteer.Widget:getChildByTag(100) then
            UIActivityMiteer.Widget:removeChildByTag(100)
        end
    end
end
local function setItemView(Item, obj)
    local tableTypeId, tableFieldId, value = nil
    if openEnabled then
        tableTypeId = obj.int["3"]
        tableFieldId = obj.int["4"]
        value = obj.int["5"]
    else
        tableTypeId = obj.tableTypeId
        tableFieldId = obj.tableFieldId
        value = obj.value
    end
    local function TouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local function setGoodInfo(_obj)
                local image_over = ui_goodInfo.frame:getChildByName("image_over")
                local image_good = ui_goodInfo.frame:getChildByName("image_good")
                local text_good_describe = ui_goodInfo.frame:getChildByName("text_good_describe")
                local btn_exchange = ui_goodInfo.frame:getChildByName("btn_exchange")
                image_good:setTouchEnabled(true)
                btn_exchange:setPressedActionEnabled(true)

                local function btnTouchEvent(sender, eventType)
                    if eventType == ccui.TouchEventType.ended then
                        --- 物品详情
                        if sender == image_good then
                            if tonumber(tableTypeId) == StaticTableType.DictCard then
                                -- 卡牌字典表
                                UICardInfo.setDictCardId(tableFieldId)
                                UIManager.pushScene("ui_card_info")
                            elseif tonumber(tableTypeId) == StaticTableType.DictEquipment then
                                -- 装备字典表
                                UIEquipmentInfo.setDictEquipId(tableFieldId)
                                UIManager.pushScene("ui_equipment_info")
                            else
                                local param = { }
                                param.tableTypeId = tableTypeId
                                param.tableFieldId = tableFieldId
                                param.value = value
                                UIFightGetAccident.setParam(UIActivityMiteer, param)
                                UIManager.pushScene("ui_fight_get_accident")
                            end
                        elseif sender == btn_exchange then
                            ---------兑换------------------
                            if obj.int["6"] == 2 then
                                -- 出售类型
                                if hunyuanNumber < obj.int["7"] then
                                    UIActivityMiteer.PromptDialog(Lang.ui_activity_miteer6, 2)
                                    return
                                end
                            elseif obj.int["6"] == 1 then
                                if net.InstPlayer.int["5"] < obj.int["7"] then
                                    UIManager.showToast(Lang.ui_activity_miteer7)
                                    return
                                end
                            end
                            sendConvertData(obj.int["1"], string.format("%d_%d_%d", tableTypeId, tableFieldId, value))
                        end
                    end
                end
                image_good:addTouchEventListener(btnTouchEvent)
                btn_exchange:addTouchEventListener(btnTouchEvent)
                local thingName, thingIcon, description = utils.getDropThing(tableTypeId, tableFieldId, "big")
                image_good:loadTexture(thingIcon)
                text_good_describe:setString(description)

                image_over:setVisible(false)

            end

            if openEnabled then
                setGoodInfo(obj)
                goodInfoAction(sender.flag, obj)
                if sender.flag == "right" then
                    sender.flag = "left"
                else
                    sender.flag = "right"
                end
                for i = 1, 8 do
                    if image_frame_good[i] ~= sender then
                        image_frame_good[i].flag = "right"
                    end
                end
            else
                ----未开业得情况下显示信息---
                -- if tonumber(tableTypeId) == StaticTableType.DictCard then --卡牌字典表
                --       UICardInfo.setDictCardId(tableFieldId)
                --       UIManager.pushScene("ui_card_info")
                -- elseif tonumber(tableTypeId) == StaticTableType.DictEquipment then --装备字典表
                --       UIEquipmentInfo.setDictEquipId(tableFieldId)
                --       UIManager.pushScene("ui_equipment_info")
                -- else
                --     show(false)
                -- end
                show(false)
                local param = { }
                param.tableTypeId = tableTypeId
                param.tableFieldId = tableFieldId
                param.value = value
                param.Pos = sender:getWorldPosition()
                show(true, param)
            end
        end
    end
    Item:setEnabled(true)
    Item:setTouchEnabled(true)
    Item:addTouchEventListener(TouchEvent)

    local ui_image_good = Item:getChildByName("image_good")
    local ui_text_name = Item:getChildByName("text_name")
    local ui_base_number = Item:getChildByName("image_base_number")
    if value ~= 1 then
        ui_base_number:setVisible(true)
    else
        ui_base_number:setVisible(false)
    end
    local ui_number = ui_base_number:getChildByName("text_number")
    local thingName, thingIcon = utils.getDropThing(tableTypeId, tableFieldId)
    utils.addBorderImage(tableTypeId, tableFieldId, Item)
    local ui_image_price = Item:getChildByName("image_price")
    if openEnabled then
        ui_image_price:setVisible(true)
        ui_text_name:setVisible(false)
        if obj.int["6"] == 1 then
            -- 出售类型
            ui_image_price:loadTexture("ui/jin.png")
        elseif obj.int["6"] == 2 then
            ui_image_price:loadTexture("ui/small_hunyuan.png")
        end
        ui_image_price:getChildByName("text_price"):setString("×" .. obj.int["7"])
        --- 价格
    else
        ui_image_price:setVisible(false)
        ui_text_name:setVisible(true)
    end
    ui_image_good:loadTexture(thingIcon)
    ui_text_name:setString(thingName)
    ui_number:setString(value)
    if openEnabled then
        if obj.int["8"] == 1 then
            utils.GrayWidget(ui_image_good, true)
        elseif obj.int["8"] == 0 then
            utils.GrayWidget(ui_image_good, false)
        end
    else
        utils.GrayWidget(ui_image_good, false)
    end
end

function UIActivityMiteer.init()
    btn_vip = ccui.Helper:seekNodeByName(UIActivityMiteer.Widget, "btn_vip")
    local btn_refresh = ccui.Helper:seekNodeByName(UIActivityMiteer.Widget, "btn_refresh")
    btn_vip:setPressedActionEnabled(true)
    btn_refresh:setPressedActionEnabled(true)
    local function btnTouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if UIActivityMiteer.Widget:getChildByTag(100) then
                UIActivityMiteer.Widget:removeChildByTag(100)
                return
            end
            if sender == btn_vip then
                local VipNum = net.InstPlayer.int["19"]
                local upSilverEnabled = DictVIP[tostring(VipNum + 1)].isUpSilverVip
                local openVipNum = 100
                for key, obj in pairs(DictVIP) do
                    if obj.isUpSilverVip == 1 then
                        if openVipNum > tonumber(obj.level) then
                            openVipNum = tonumber(obj.level)
                        end
                    end
                end
                if upSilverEnabled == 0 then
                    UIManager.showToast(Lang.ui_activity_miteer8 .. openVipNum .. Lang.ui_activity_miteer9)
                    return
                end
                sendVipData()
            elseif sender == btn_refresh then
                if ScheduleId then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(ScheduleId)
                end
                sendRefreshData()
            end
        end
    end
    btn_vip:addTouchEventListener(btnTouchEvent)
    btn_refresh:addTouchEventListener(btnTouchEvent)
    UIActivityMiteer.Widget:addTouchEventListener(btnTouchEvent)
    ui_goodInfo = { }
    ui_imageYafei = { }
    image_frame_good = { }
    ui_goodInfo.frame = ccui.Helper:seekNodeByName(UIActivityMiteer.Widget, "image_base_good_info")
    ui_goodInfo.x, ui_goodInfo.y = ui_goodInfo.frame:getPosition()
    ui_imageYafei.frame = ccui.Helper:seekNodeByName(UIActivityMiteer.Widget, "image_yafei_open")
    ui_imageYafei.x, ui_imageYafei.y = ui_imageYafei.frame:getPosition()
    for i = 1, 8 do
        image_frame_good[i] = ccui.Helper:seekNodeByName(UIActivityMiteer.Widget, "image_frame_good" .. i)
        image_frame_good[i].x, image_frame_good[i].y = image_frame_good[i]:getPosition()
    end
end

function UIActivityMiteer.setup()
    if ScheduleId ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(ScheduleId)
    end
    openEnabled = false
    ui_timeTextOn = ccui.Helper:seekNodeByName(UIActivityMiteer.Widget, "text_time")
    ui_timeTextDown = ccui.Helper:seekNodeByName(UIActivityMiteer.Widget, "text_bulletincd")
    ui_timeTextOn_di = ccui.Helper:seekNodeByName(UIActivityMiteer.Widget, "image_base_di")
    if net.InstActivity then
        for key, obj in pairs(net.InstActivity) do
            if net.SysActivity[tostring(obj.int["3"])].string["9"] == "auctionShop" then
                instActivityObj = obj
                break
            end
        end
    end
    if instActivityObj then
        local isForever = instActivityObj.int["5"]
        --- 是否成为白金贵宾
        if isForever == 1 then
            btn_vip:setVisible(false)
            openEnabled = true
            ccui.Helper:seekNodeByName(UIActivityMiteer.Widget, "image_yafei_closed"):setVisible(false)
            ui_imageYafei.frame:setVisible(true)
            ui_imageYafei.frame:setPosition(cc.p(ui_imageYafei.x, ui_imageYafei.y))
            ui_goodInfo.frame:setVisible(false)
            ccui.Helper:seekNodeByName(UIActivityMiteer.Widget, "image_hunyuan"):setVisible(true)
            ui_timeTextOn_di:setVisible(false)
            ccui.Helper:seekNodeByName(UIActivityMiteer.Widget, "btn_refresh"):setVisible(true)
            ccui.Helper:seekNodeByName(UIActivityMiteer.Widget, "image_foreshow"):setVisible(false)
            openEnabled = true
            -----显示魂源
            local ui_hunyuan = ccui.Helper:seekNodeByName(UIActivityMiteer.Widget, "image_hunyuan")
            hunyuanNumber = 0
            if net.InstPlayerThing then
                for _key, _obj in pairs(net.InstPlayerThing) do
                    if _obj.int["3"] == StaticThing.soulSource then
                        hunyuanNumber = _obj.int["5"]
                    end
                end
            end
            ui_hunyuan:getChildByName("text_hunyuan_number"):setString(hunyuanNumber)
            -------------------显示上新倒计时----------------------------
            local serverTime = utils.GetTimeByDate(net.serverLoginTime)
            local starTime = utils.GetTimeByDate(instActivityObj.string["4"])
            local subtime = os.time() - net.LoginTime
            --- 从登录到切换到该界面已经过去的时间
            local currentTime = serverTime + subtime
            local auctionShopResetTime = DictSysConfig[tostring(StaticSysConfig.auctionShopResetTime)].value
            --- 拍卖行有效时间
            countDownTimeDown = auctionShopResetTime * 3600 - math.abs(currentTime - starTime) %(auctionShopResetTime * 3600)
            if countDownTimeDown ~= 0 then
                local hour = math.floor(countDownTimeDown / 3600)
                local min = math.floor(countDownTimeDown % 3600 / 60)
                local sec = countDownTimeDown % 60

                ui_timeTextDown:setVisible(true)
                ui_timeTextDown:setString(string.format(Lang.ui_activity_miteer10, hour, min, sec))
                ScheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateTime, 1, false)
            end
            ---------------------------------------------------------------
            for i = 1, 8 do
                image_frame_good[i]:setPosition(cc.p(image_frame_good[i].x, image_frame_good[i].y + 20))
            end
        else
            ui_timeTextDown:setVisible(false)
            btn_vip:setVisible(true)
            local serverTime = utils.getCurrentTime()
            local starTime = utils.GetTimeByDate(instActivityObj.string["4"])
            local auctionShopTime = DictSysConfig[tostring(StaticSysConfig.auctionShopTime)].value
            --- 拍卖行有效时间
            local endTime = starTime + auctionShopTime * 3600
            if serverTime > endTime or serverTime < starTime then
                -- 休业中
                ccui.Helper:seekNodeByName(UIActivityMiteer.Widget, "image_yafei_closed"):setVisible(true)
                ui_imageYafei.frame:setVisible(false)
                ui_goodInfo.frame:setVisible(false)
                ccui.Helper:seekNodeByName(UIActivityMiteer.Widget, "image_hunyuan"):setVisible(false)
                ui_timeTextOn_di:setVisible(false)
                ccui.Helper:seekNodeByName(UIActivityMiteer.Widget, "btn_refresh"):setVisible(false)
                openEnabled = false
                btn_vip:setPositionX(UIActivityMiteer.Widget:getContentSize().width / 2)
                for i = 1, 8 do
                    image_frame_good[i]:setPosition(cc.p(image_frame_good[i].x, image_frame_good[i].y))
                end
                ccui.Helper:seekNodeByName(UIActivityMiteer.Widget, "image_foreshow"):setVisible(true)
            else
                --- 开业中
                ccui.Helper:seekNodeByName(UIActivityMiteer.Widget, "image_yafei_closed"):setVisible(false)
                ui_imageYafei.frame:setVisible(true)
                ui_imageYafei.frame:setPosition(cc.p(ui_imageYafei.x, ui_imageYafei.y))
                ui_goodInfo.frame:setVisible(false)
                ccui.Helper:seekNodeByName(UIActivityMiteer.Widget, "image_hunyuan"):setVisible(true)
                ui_timeTextOn_di:setVisible(true)
                ccui.Helper:seekNodeByName(UIActivityMiteer.Widget, "btn_refresh"):setVisible(true)
                ccui.Helper:seekNodeByName(UIActivityMiteer.Widget, "image_foreshow"):setVisible(false)
                btn_vip:setPositionX(UIActivityMiteer.Widget:getContentSize().width / 3)
                openEnabled = true
                -----显示魂源
                local ui_hunyuan = ccui.Helper:seekNodeByName(UIActivityMiteer.Widget, "image_hunyuan")
                hunyuanNumber = 0
                for key, obj in pairs(DictThing) do
                    if obj.sname == "soulSource" then
                        if net.InstPlayerThing then
                            for _key, _obj in pairs(net.InstPlayerThing) do
                                if _obj.int["3"] == obj.id then
                                    hunyuanNumber = _obj.int["5"]
                                end
                            end
                        end
                    end
                end
                ui_hunyuan:getChildByName("text_hunyuan_number"):setString(hunyuanNumber)
                -------------------显示结束倒计时----------------------------
                countDownTimeOn = endTime - serverTime
                if countDownTimeOn ~= 0 then
                    local hour = math.floor(countDownTimeOn / 3600)
                    local min = math.floor(countDownTimeOn % 3600 / 60)
                    local sec = countDownTimeOn % 60

                    ui_timeTextOn:setString(string.format("%02d:%02d:%02d", hour, min, sec))
                    ScheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateTime, 1, false)
                end
                ---------------------------------------------------------------
                for i = 1, 8 do
                    image_frame_good[i]:setPosition(cc.p(image_frame_good[i].x, image_frame_good[i].y + 20))
                end

            end
        end

    else
        openEnabled = false
        ui_timeTextDown:setVisible(false)
        ccui.Helper:seekNodeByName(UIActivityMiteer.Widget, "image_yafei_closed"):setVisible(true)
        ui_imageYafei.frame:setVisible(false)
        ui_goodInfo.frame:setVisible(false)
        ccui.Helper:seekNodeByName(UIActivityMiteer.Widget, "image_hunyuan"):setVisible(false)
        ui_timeTextOn_di:setVisible(false)
        ccui.Helper:seekNodeByName(UIActivityMiteer.Widget, "btn_refresh"):setVisible(false)
        btn_vip:setPositionX(UIActivityMiteer.Widget:getContentSize().width / 2)
        for i = 1, 8 do
            image_frame_good[i]:setPosition(cc.p(image_frame_good[i].x, image_frame_good[i].y))
        end
        ccui.Helper:seekNodeByName(UIActivityMiteer.Widget, "image_foreshow"):setVisible(true)
    end

    for i = 1, 8 do
        image_frame_good[i].flag = "right"
    end
    if openEnabled then
        if net.InstAuctionShop then
            local i = 1
            for key, obj in pairs(net.InstAuctionShop) do
                setItemView(image_frame_good[tonumber(i)], obj)
                i = i + 1
            end
        end
    else
        for i = 1, 8 do
            setItemView(image_frame_good[tonumber(i)], DictAuctionShop[tostring(i)])
        end
    end

end

function UIActivityMiteer.free()
    instActivityObj = nil
    if UIActivityMiteer.Widget:getChildByTag(100) then
        UIActivityMiteer.Widget:removeChildByTag(100)
    end
end

function UIActivityMiteer.setTimeInterval(intervalTime)
    if countDownTimeOn then
        local countDownTime1 = countDownTimeOn - intervalTime
        if countDownTime1 > 0 then
            countDownTimeOn = countDownTime1
        else
            countDownTimeOn = 0
        end
    end

    if countDownTimeDown then
        local countDownTime2 = countDownTimeDown - intervalTime
        if countDownTime2 > 0 then
            countDownTimeDown = countDownTime2
        else
            -----刷新------------
            if ScheduleId then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(ScheduleId)
            end
            sendRefreshData()
        end
    end
end

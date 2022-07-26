require"Lang"
UIActivityLimit = {}

function UIActivityLimit.init()
    local image_basemap = UIActivityLimit.Widget:getChildByName("image_basemap")
    local btn_closed = image_basemap:getChildByName("btn_closed")
    btn_closed:setPressedActionEnabled(true)
    btn_closed:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            UIManager.popScene()
        end
    end)
end

function UIActivityLimit.setup()
    --id | 活动类型(1-任意金额,2-单笔充值,3-累计充值) | 道具信息 | 开始时间 | 结束时间 | 充值金额数 | 状态(0-不可领取,1-可领取,2-已领取) 
    local tempData = utils.stringSplit(UIHomePage.actLimitRecInfo, "|")

    local image_basemap = UIActivityLimit.Widget:getChildByName("image_basemap")
    local text_any = image_basemap:getChildByName("text_any")
    local image_any = image_basemap:getChildByName("image_any")
    local text_only = image_basemap:getChildByName("text_only")
    local label_only = image_basemap:getChildByName("label_only")
    local text_total = image_basemap:getChildByName("text_total")
    local label_total = image_basemap:getChildByName("label_total")
    local btn_recharge = image_basemap:getChildByName("btn_recharge")

    text_any:setVisible(false)
    image_any:setVisible(false)
    text_only:setVisible(false)
    label_only:setVisible(false)
    text_total:setVisible(false)
    label_total:setVisible(false)
    if tonumber(tempData[2]) == 1 then
        text_any:setVisible(true)
        image_any:setVisible(true)
    elseif tonumber(tempData[2]) == 2 then
        text_only:setVisible(true)
        label_only:setVisible(true)
        label_only:setString(tonumber(tempData[6]))
    elseif tonumber(tempData[2]) == 3 then
        text_total:setVisible(true)
        label_total:setVisible(true)
        label_total:setString(tonumber(tempData[6]))
    end

    local thingDatas = utils.stringSplit(tempData[3], ";")
    for i = 1, 4 do
        local ui_frame = image_basemap:getChildByName("image_frame_good" .. i)
        if thingDatas[i] then
            local itemProps = utils.getItemProp(thingDatas[i])
            if itemProps then
                local ui_icon = ui_frame:getChildByName("image_good")
                local ui_name = ui_frame:getChildByName("text_name")
                local ui_count = ccui.Helper:seekNodeByName(ui_frame, "text_number")
                if itemProps.frameIcon then
                    ui_frame:loadTexture(itemProps.frameIcon)
                end
                if itemProps.smallIcon then
                    ui_icon:loadTexture(itemProps.smallIcon)
                    utils.showThingsInfo(ui_icon, itemProps.tableTypeId, itemProps.tableFieldId)
                end
                if itemProps.name then
                    ui_name:setString(itemProps.name)
                end
                if itemProps.qualityColor then
                    ui_name:setTextColor(itemProps.qualityColor)
                end
                if itemProps.count then
                    ui_count:setString(tostring(itemProps.count))
                end
                if itemProps.flagIcon then
                    local ui_flagIcon = ccui.ImageView:create(itemProps.flagIcon)
                    ui_flagIcon:setName("image_good_flag")
                    ui_flagIcon:setAnchorPoint(cc.p(0.2, 0.8))
                    ui_flagIcon:setPosition(cc.p(0, ui_frame:getContentSize().height))
                    ui_frame:addChild(ui_flagIcon)
                end
            end
        else
            ui_frame:setVisible(false)
        end
    end
    thingDatas = nil

    if tonumber(tempData[7]) == 0 then
        btn_recharge:setTitleText(Lang.ui_activity_limit1)
    elseif tonumber(tempData[7]) == 1 then
        btn_recharge:setTitleText(Lang.ui_activity_limit2)
    elseif tonumber(tempData[7]) == 2 then
        btn_recharge:setTouchEnabled(false)
        btn_recharge:setTitleText(Lang.ui_activity_limit3)
        btn_recharge:setBright(false)
    end

    btn_recharge:setPressedActionEnabled(true)
    btn_recharge:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if tonumber(tempData[7]) == 0 then
                utils.checkGOLD(1)
            elseif tonumber(tempData[7]) == 1 then
                UIManager.showLoading()
	            netSendPackage({header=StaticMsgRule.getActLimitRecharge, msgdata={ int = { actId = tonumber(tempData[1]) } }}, function(_msgData)
                    utils.showGetThings(tempData[3])
                    UIHomePage.actLimitRecInfo = string.sub(UIHomePage.actLimitRecInfo, 1, string.len(UIHomePage.actLimitRecInfo) - 1) .. "2"
                    UIActivityLimit.setup()
                    UIHomePage.setBtnLimitPoint(false)
                end)
            end
        end
    end)

    local ui_timeLabel = image_basemap:getChildByName("text_time")
    local _startTime = utils.changeTimeFormat(tempData[4])
	local _endTime = utils.changeTimeFormat(tempData[5])
    ui_timeLabel:setString(string.format(Lang.ui_activity_limit4, _startTime[2],_startTime[3],_startTime[5],_endTime[2],_endTime[3],_endTime[5]))
end

function UIActivityLimit.show()
    UIManager.pushScene("ui_activity_limit")
end

function UIActivityLimit.free()

end

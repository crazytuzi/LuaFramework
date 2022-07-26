require"Lang"
UIActivityOne = {
    preViewThing = {}
}

local DictActivity = nil

local _countdownTime = 0

local textItem = {}

local textNum = 0

local function countDowun()
    _countdownTime = _countdownTime - 1
    if _countdownTime < 0 then
        _countdownTime = 0
    end
    local day = math.floor(_countdownTime / 3600 / 24) --天
	local hour = math.floor(_countdownTime / 3600 % 24) --小时
	local minute = math.floor(_countdownTime / 60 % 60) --分
	local second = math.floor(_countdownTime % 60) --秒
    local image_basemap = UIActivityOne.Widget:getChildByName("image_basemap")
    local ui_countTimeLabel = image_basemap:getChildByName("text_time_count")
    if day > 0 then
        ui_countTimeLabel:setString(string.format(Lang.ui_activity_one1, day, hour, minute, second))
    else
        ui_countTimeLabel:setString(string.format(Lang.ui_activity_one2, hour, minute, second))
    end
end

function UIActivityOne.onActivity(_params)
    DictActivity = _params
end

local function itemAction()
  textItem[1]:stopAllActions()
  textItem[1]:setString("")
  local ui_panel = UIActivityOne.Widget:getChildByName("ui_top"):getChildByName("panel")
  local time = 12*(ui_panel:getContentSize().width + textItem[1]:getContentSize().width)/ui_panel:getContentSize().width

  local action2 = cc.MoveBy:create(time, cc.p(-ui_panel:getContentSize().width, 0))
  if UIActivityOne.preViewThing[1] then
    local rewardList = utils.stringSplit(utils.stringSplit(UIActivityOne.preViewThing[1],"#")[2],"|")
    if not rewardList[textNum] then
        textNum = 1
    end
    if rewardList[textNum] then
        rewardListTab = utils.stringSplit(rewardList[textNum],"__")
        local itemThing = utils.getItemProp(rewardListTab[4])
        if itemThing.name then
            local thingName = itemThing.name
            local thingNum = itemThing.count
            rewardStr = Lang.ui_activity_one3 .. rewardListTab[3] .. Lang.ui_activity_one4 .. rewardListTab[1] .. Lang.ui_activity_one5 .. rewardListTab[2] .. Lang.ui_activity_one6 .. thingName .. "×" .. thingNum
        else
            rewardStr = Lang.ui_activity_one7 .. rewardListTab[3] .. Lang.ui_activity_one8 .. rewardListTab[1] .. Lang.ui_activity_one9 .. rewardListTab[2] .. Lang.ui_activity_one10
        end
        textItem[1]:setString(rewardStr)
    else
        textItem[1]:setString("")
    end
        
  else
    textItem[1]:setString("")
  end
  textItem[1]:runAction(action2)
  local ui_panel = UIActivityOne.Widget:getChildByName("ui_top"):getChildByName("panel")
  -- textItem[1]:setPosition(cc.p(600,15))
  textItem[1]:setPosition(cc.p(ui_panel:getContentSize().width,15))
  -- local movedWidth  = 600
  local movedWidth = -ui_panel:getContentSize().width-textItem[1]:getContentSize().width
  textItem[1]:runAction(cc.Sequence:create(cc.MoveBy:create(time, cc.p(movedWidth,0)),cc.CallFunc:create(itemAction)))
  textNum = textNum + 1

end

function UIActivityOne.init()
    local image_basemap = UIActivityOne.Widget:getChildByName("image_basemap")
    local btn_help = image_basemap:getChildByName("btn_help")
    local btn_preview = image_basemap:getChildByName("btn_preview")
    local btn_change = image_basemap:getChildByName("btn_change")
    btn_help:setPressedActionEnabled(true)
    btn_preview:setPressedActionEnabled(true)
    btn_change:setPressedActionEnabled(true)
    local onBtnEvent = function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_help then
                UIAllianceHelp.show( { type = 33 , titleName = Lang.ui_activity_one11 } )
            elseif sender == btn_preview then
                UIActivityOnePreview.show()
            elseif sender == btn_change then
                UIActivityOneShop.show()
            end
        end
    end
    btn_help:addTouchEventListener(onBtnEvent)
    btn_preview:addTouchEventListener(onBtnEvent)
    btn_change:addTouchEventListener(onBtnEvent)

    local ui_panel = UIActivityOne.Widget:getChildByName("ui_top"):getChildByName("panel")
	textItem[1] = ccui.Text:create()
	textItem[1]:setAnchorPoint(cc.p(0, 0.5))
	textItem[1]:setFontSize(20)
	textItem[1]:setFontName(dp.FONT)
    textItem[1]:setPosition(cc.p(10,15))
	ui_panel:removeChild(textItem[1])
    ui_panel:addChild(textItem[1])
    itemAction()
end

function UIActivityOne.setup()
    local image_basemap = UIActivityOne.Widget:getChildByName("image_basemap")
    local ui_upTimeLabel = image_basemap:getChildByName("text_time")
    local ui_endImage = image_basemap:getChildByName("Image_3")
    local ui_frame = image_basemap:getChildByName("image_frame_good")
    local ui_icon = ui_frame:getChildByName("image_good")
    local ui_name = ui_frame:getChildByName("text_name")
    local ui_bar = image_basemap:getChildByName("image_loading"):getChildByName("bar_loading")
    local ui_barText = image_basemap:getChildByName("image_loading"):getChildByName("text_number")
    local btn_buy = image_basemap:getChildByName("btn_buy")
    local ui_preJF = image_basemap:getChildByName("text_points")

    btn_buy:setPressedActionEnabled(true)
    ui_endImage:setVisible(false)

    UIManager.showLoading()
    local rewardList = ""
    netSendPackage( {
        header = StaticMsgRule.openOneGoldShopPanel, msgdata = {}
    } , function(_msgData)
        local _thing = _msgData.msgdata.string.thing --道具
        local _curJindu = _msgData.msgdata.int.curJindu --当前进度
        local _num = _msgData.msgdata.int.num --数量
        local _up = _msgData.msgdata.int.up --0上架(9点之前),1下架,nil第二天
        local _upJiFen = _msgData.msgdata.int.upJiFen --上一轮转化的积分
        local _time = _msgData.msgdata.int.time --上架或下架时间点
        local _jindu = _msgData.msgdata.int.jindu --该道具的积分
        local _maxJF = _jindu * _num
        local itemProp = utils.getItemProp(_thing)
        rewardList = _msgData.msgdata.string.rewardList
        UIActivityOne.preViewThing[1] = rewardList

        if itemProp then
            if itemProp.frameIcon then
                ui_frame:loadTexture(itemProp.frameIcon)
            end
            if itemProp.smallIcon then
                ui_icon:loadTexture(itemProp.smallIcon)
                utils.showThingsInfo(ui_icon, itemProp.tableTypeId, itemProp.tableFieldId)
                utils.addFrameParticle( ui_icon , true )
            end
            if itemProp.name then
                ui_name:setString(itemProp.name .. Lang.ui_activity_one12 .. _num .. Lang.ui_activity_one13)
            end
        end
        ui_bar:setPercent(utils.getPercent(_curJindu, _maxJF))
        ui_barText:setString(_curJindu .. "/" .. _maxJF)
        if _up == 0 then
            ui_preJF:setString(Lang.ui_activity_one14)
        else
            ui_preJF:setString(string.format(Lang.ui_activity_one15, _upJiFen, _upJiFen))
        end
        if _up then
            local _startTime = utils.changeTimeFormat(DictActivity.string["4"])
            ui_upTimeLabel:setString(string.format(Lang.ui_activity_one16, (_up == 0) and Lang.ui_activity_one17 or Lang.ui_activity_one18, _startTime[2],_startTime[3], _time))
            ui_upTimeLabel:setVisible(true)
            if _curJindu >= _maxJF or _up == 0 then
                btn_buy:setBright(false)
				if _curJindu >= _maxJF then
					ui_endImage:setVisible(true)
				end
            else
                btn_buy:setBright(true)
                btn_buy:addTouchEventListener(function(sender, eventType)
                    if eventType == ccui.TouchEventType.ended and btn_buy:isBright() then
                        local _canBuyCount = _jindu - _upJiFen
                        if _jindu - _upJiFen > _maxJF - _curJindu then
                            _canBuyCount = _maxJF - _curJindu
                        end
                        UIActivityOneUse.show({buyCount = _canBuyCount})
                    end
                end)
            end
        else
            ui_endImage:setVisible(true)
            ui_upTimeLabel:setVisible(false)
            btn_buy:setBright(false)
            ui_preJF:setString(Lang.ui_activity_one19)
        end
    end )

    local ui_timeLabel = image_basemap:getChildByName("text_time_open")
    if DictActivity and DictActivity.string["4"] ~= "" and DictActivity.string["5"] ~= "" then
        local _startTime = utils.changeTimeFormat(DictActivity.string["4"])
		local _endTime = utils.changeTimeFormat(DictActivity.string["5"])
        ui_timeLabel:setString(string.format(Lang.ui_activity_one20, _startTime[2],_startTime[3],_startTime[5],_endTime[2],_endTime[3],_endTime[5]))
        _countdownTime = utils.GetTimeByDate(DictActivity.string["5"]) - utils.getCurrentTime()
        dp.addTimerListener(countDowun)
    else
        ui_timeLabel:setString("")
    end


end

function UIActivityOne.free()
    dp.removeTimerListener(countDowun)
    DictActivity = nil
    _countdownTime = 0
end

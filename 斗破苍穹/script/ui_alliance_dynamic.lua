require"Lang"
UIAllianceDynamic = {}

local ui_scrollView = nil
local _prevTabButton = nil

local DynamicData = nil

local function cleanScrollView()
    if ui_scrollView then
        ui_scrollView:removeAllChildren()
    end
end

local function getDynamicItem()
	local layout = ccui.Layout:create()
	layout:setContentSize(cc.size(UIManager.screenSize.width, 90))
	local ui_timeLabel = ccui.Text:create()
	ui_timeLabel:setName("ui_timeLabel")
	ui_timeLabel:setFontName(dp.FONT)
	ui_timeLabel:setFontSize(23)
	ui_timeLabel:setTextColor(cc.c3b(255, 255, 255))
	ui_timeLabel:setPosition(cc.p(82, 59))
	layout:addChild(ui_timeLabel)
	local ui_richText = ccui.RichText:create()
	ui_richText:setName("ui_richText")
	ui_richText:setPosition(cc.p(400, 40))
	ui_richText:ignoreContentAdaptWithSize(false)
	ui_richText:setContentSize(cc.size(440, 70))
	layout:addChild(ui_richText)
    ui_timeLabel:setPositionY(ui_richText:getContentSize().height / 2)
	return layout
end

local function layoutScrollView(_listData, _initItemFunc)
	local SCROLLVIEW_ITEM_SPACE = 0
	cleanScrollView()
	ui_scrollView:jumpToTop()
	local _innerHeight = 0
    if _listData == nil then
        _listData = {}
    end
	for key, obj in pairs(_listData) do
		local scrollViewItem = getDynamicItem()
		_initItemFunc(scrollViewItem, obj)
		ui_scrollView:addChild(scrollViewItem)
		_innerHeight = _innerHeight + scrollViewItem:getContentSize().height + SCROLLVIEW_ITEM_SPACE
	end
	_innerHeight = _innerHeight + SCROLLVIEW_ITEM_SPACE
	if _innerHeight < ui_scrollView:getContentSize().height then
		_innerHeight = ui_scrollView:getContentSize().height
	end
	ui_scrollView:setInnerContainerSize(cc.size(ui_scrollView:getContentSize().width, _innerHeight))
	local childs = ui_scrollView:getChildren()
	local prevChild = nil
	for i = 1, #childs do
		local apX, apY = childs[i]:getAnchorPoint().x, childs[i]:getAnchorPoint().y
		if i == 1 then
			if apX == 0.5 and apY == 0.5 then
				childs[i]:setPosition(ui_scrollView:getContentSize().width / 2, ui_scrollView:getInnerContainerSize().height - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
			elseif apX == 0 and apY == 0 then
				childs[i]:setPosition((ui_scrollView:getContentSize().width - childs[i]:getContentSize().width) / 2, ui_scrollView:getInnerContainerSize().height - childs[i]:getContentSize().height - SCROLLVIEW_ITEM_SPACE)
			end
		else
			if apX == 0.5 and apY == 0.5 then
				childs[i]:setPosition(ui_scrollView:getContentSize().width / 2, prevChild:getBottomBoundary() - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
			elseif apX == 0 and apY == 0 then
				childs[i]:setPosition((ui_scrollView:getContentSize().width - childs[i]:getContentSize().width) / 2, prevChild:getBottomBoundary() - childs[i]:getContentSize().height - SCROLLVIEW_ITEM_SPACE)
			end
		end
		prevChild = childs[i]
	end
	ActionManager.ScrollView_SplashAction(ui_scrollView)
end

local getDynamicData = function(strDynamic)
    local _tempTable = {}
    if strDynamic then
        local data = utils.stringSplit(strDynamic, "/")
        for key, obj in pairs(data) do
            local _tempData = utils.stringSplit(obj, "|")
            _tempTable[#_tempTable + 1] = {
                instUnionId = tonumber(_tempData[1]),
                instPlayerId = tonumber(_tempData[2]),

                --动态类型  1-个人 2-联盟
                dynamicType = tonumber(_tempData[3]),

                --动作类型 1-进入联盟 2-退出联盟 3-被踢出联盟 4-被群主任命 5-联盟捐献 6-个人联盟秘境（我带别人玩，名字为被带人名字） 7-个人秘境（被别人玩，名字为带我玩的名字）
                actionType = tonumber(_tempData[4]),

                --主角名字
                actorName = _tempData[5],

                value1 = _tempData[6],
                value2 = _tempData[7],
                value3 = _tempData[8],
                insertTime = _tempData[9],
            }
            _tempData = nil
        end
        -- @动态列表排序规则
		utils.quickSort(_tempTable, function(obj1, obj2) if utils.GetTimeByDate(obj1.insertTime) < utils.GetTimeByDate(obj2.insertTime) then return true end end)
    end
    return _tempTable
end

local function getDynamicTextString(_data)
    --1-进入联盟 2-退出联盟 3-被踢出联盟 4-被群主任命 5-联盟捐献 6-个人联盟秘境（我带别人玩，名字为被带人名字） 7-个人秘境（被别人玩，名字为带我玩的名字）
    local _msgContent = ""
	if _data.actionType == 1 then -- @进入联盟
		_msgContent = Lang.ui_alliance_dynamic1.._data.actorName..Lang.ui_alliance_dynamic2
	elseif _data.actionType == 2 or _data.actionType == 3 then -- @退出联盟  or @被踢出联盟
		_msgContent = Lang.ui_alliance_dynamic3.._data.actorName..Lang.ui_alliance_dynamic4
	elseif _data.actionType == 4 then -- @被任命
        _msgContent = "<color=0,255,0>".._data.actorName..Lang.ui_alliance_dynamic5..DictUnionGrade[_data.value1].name.."</color><color=255,217,0>！</color>"
    elseif _data.actionType == 5 then -- @联盟捐献
        _msgContent = "<color=0,255,0>".._data.actorName..Lang.ui_alliance_dynamic6.._data.value1..Lang.ui_alliance_dynamic7
    elseif _data.actionType == 6 or _data.actionType == 7 then -- @个人联盟秘境（我带别人玩 or 别人带我玩）
        if _data.actorName == net.InstPlayer.string["3"] then
            _msgContent = Lang.ui_alliance_dynamic8
        elseif _data.actionType == 6 then
            _msgContent =Lang.ui_alliance_dynamic9.. "<color=0,255,0>".._data.actorName..Lang.ui_alliance_dynamic10
        else
            _msgContent = "<color=0,255,0>".._data.actorName..Lang.ui_alliance_dynamic11
        end
	end
    return _msgContent
end

local function setDynamicListItem(_item, _data)
    local richText = utils.richTextFormat(getDynamicTextString(_data))
	local ui_timeLabel = _item:getChildByName("ui_timeLabel")
	local _times = utils.changeTimeFormat(_data.insertTime)
	ui_timeLabel:setString(string.format("[%02d-%02d %02d:%02d]", _times[2], _times[3], _times[5], _times[6]))
	local ui_richText = _item:getChildByName("ui_richText")
	for key, obj in pairs(richText) do
		ui_richText:pushBackElement(ccui.RichElementText:create(key, obj.color, 255, obj.text, ui_timeLabel:getFontName(), ui_timeLabel:getFontSize()))
	end
end

local function netCallbackFunc(_msgData)
    local code = tonumber(_msgData.header)
    if code == StaticMsgRule.unionDynamic then
        DynamicData = {
            persion = getDynamicData(_msgData.msgdata.string.persion),
            union = getDynamicData(_msgData.msgdata.string.union)
        }
        local image_basemap = UIAllianceDynamic.Widget:getChildByName("image_basemap")
        local btn_me = image_basemap:getChildByName("btn_me")
        btn_me:releaseUpEvent()
        UIAlliance.setDynamicHint(false, _msgData.msgdata.string.persion)
        
        --[[
        local _messageList = {}
		if _msgData.msgdata.message.unionDynamic and _msgData.msgdata.message.unionDynamic.message then
			for key, obj in pairs(_msgData.msgdata.message.unionDynamic.message) do
				local _msgContent = ""
				if obj.int["4"] == 0 then --添加
					_msgContent = Lang.ui_alliance_dynamic12..obj.string["3"]..Lang.ui_alliance_dynamic13
				elseif obj.int["4"] == -1 then --踢出
					_msgContent = Lang.ui_alliance_dynamic14..obj.string["3"]..Lang.ui_alliance_dynamic15
				elseif obj.int["4"] == -2 then --退出
					_msgContent = Lang.ui_alliance_dynamic16..obj.string["3"]..Lang.ui_alliance_dynamic17
				else
					local unionBuildData = DictUnionBuild[tostring(obj.int["4"])]
					_msgContent = Lang.ui_alliance_dynamic18..obj.string["3"].."</color><color=255,217,0>"..unionBuildData.description..Lang.ui_alliance_dynamic19..unionBuildData.plan..Lang.ui_alliance_dynamic20..unionBuildData.exp..Lang.ui_alliance_dynamic21
				end
				_messageList[#_messageList + 1] = { time = obj.string["6"], richText = utils.richTextFormat(_msgContent) }
			end
            -- @动态列表排序规则
			utils.quickSort(_messageList, function(obj1, obj2) if utils.GetTimeByDate(obj1.time) < utils.GetTimeByDate(obj2.time) then return true end end)
		end
		layoutScrollView(_messageList, setDynamicListItem)
        _messageList = nil
        --]]
    end
end

function UIAllianceDynamic.init()
    local image_basemap = UIAllianceDynamic.Widget:getChildByName("image_basemap")
    local btn_back = image_basemap:getChildByName("btn_back")
    local btn_me = image_basemap:getChildByName("btn_me")
    local btn_alliance = image_basemap:getChildByName("btn_alliance")
    btn_back:setPressedActionEnabled(true)
    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_back then
                UIAlliance.show()
            elseif sender == btn_me then
                if _prevTabButton == sender then
                    return
                end
                _prevTabButton = sender
                btn_me:loadTextures("ui/yh_btn02.png", "ui/yh_btn02.png")
                btn_me:getChildByName("text_me"):setTextColor(cc.c4b(51, 25, 4, 255))
                btn_alliance:getChildByName("text_alliance"):setTextColor(cc.c4b(255, 255, 255, 255))
				btn_alliance:loadTextures("ui/yh_btn01.png", "ui/yh_btn02.png")
                if DynamicData then
                    layoutScrollView(DynamicData.persion, setDynamicListItem)
                end
            elseif sender == btn_alliance then
                if _prevTabButton == sender then
                    return
                end
                _prevTabButton = sender
                btn_alliance:loadTextures("ui/yh_btn02.png", "ui/yh_btn02.png")
                btn_alliance:getChildByName("text_alliance"):setTextColor(cc.c4b(51, 25, 4, 255))
                btn_me:getChildByName("text_me"):setTextColor(cc.c4b(255, 255, 255, 255))
				btn_me:loadTextures("ui/yh_btn01.png", "ui/yh_btn02.png")
                if DynamicData then
                    layoutScrollView(DynamicData.union, setDynamicListItem)
                end
            end
        end
    end
    btn_back:addTouchEventListener(onButtonEvent)
    btn_me:addTouchEventListener(onButtonEvent)
    btn_alliance:addTouchEventListener(onButtonEvent)

    ui_scrollView = image_basemap:getChildByName("view_situation")
end

function UIAllianceDynamic.setup()
    UIManager.showLoading()
    netSendPackage( {
        header = StaticMsgRule.unionDynamic,
        msgdata = { int = { instUnionMemberId = net.InstUnionMember.int["1"], type = 2 } }
    } , netCallbackFunc)
end

function UIAllianceDynamic.show()
    UIManager.showWidget("ui_alliance_dynamic")
end

function UIAllianceDynamic.free()
    cleanScrollView()
    _prevTabButton = nil
    DynamicData = nil
end

function UIAllianceDynamic.getDynamicStrings(_strDynamic)
    local tempStrings = {}
    local _tempData = getDynamicData(_strDynamic)
    for key, obj in pairs(_tempData) do
        tempStrings[#tempStrings + 1] = getDynamicTextString(obj)
    end
    return tempStrings
end

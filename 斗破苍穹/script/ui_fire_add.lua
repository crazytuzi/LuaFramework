require"Lang"
UIFireAdd = {}

local userData = nil
local ui_scrollView = nil
local ui_svItem = nil

local _curShowIndex = nil
local _curEquipFirePos = nil

local function cleanScrollView(_isRelease)
    if _isRelease then
        if ui_svItem and ui_svItem:getReferenceCount() >= 1 then
            ui_svItem:release()
            ui_svItem = nil
        end
        if ui_scrollView then
            ui_scrollView:removeAllChildren()
            ui_scrollView = nil
        end
    else
        if ui_svItem:getReferenceCount() == 1 then
            ui_svItem:retain()
        end
        ui_scrollView:removeAllChildren()
    end
end

local function layoutScrollView(_listData, _initItemFunc)
    cleanScrollView()
    ui_scrollView:jumpToLeft()
    local innerWidth, _spaceW = 0, 5
    for key, obj in pairs(_listData) do
        local scrollViewItem = ui_svItem:clone()
        _initItemFunc(scrollViewItem, obj)
        ui_scrollView:addChild(scrollViewItem)
        innerWidth = innerWidth + scrollViewItem:getContentSize().width + _spaceW
    end
    innerWidth = innerWidth + _spaceW
    if innerWidth < ui_scrollView:getContentSize().width then
        innerWidth = ui_scrollView:getContentSize().width
    end
    ui_scrollView:setInnerContainerSize(cc.size(innerWidth, ui_scrollView:getContentSize().height))
    local childs = ui_scrollView:getChildren()
    local prevChild = nil
    for i = 1, #childs do
        local _anchorPoint = childs[i]:getAnchorPoint()
        if prevChild then
            childs[i]:setPosition(cc.p(prevChild:getRightBoundary() + childs[i]:getContentSize().width / 2 + _spaceW, ui_scrollView:getContentSize().height / 2))
        else
            childs[i]:setPosition(cc.p(childs[i]:getContentSize().width / 2 + _spaceW, ui_scrollView:getContentSize().height / 2))
        end
        prevChild = childs[i]
    end
end

local function setScrollViewFocus(isJumpTo, _curIndex)
	local childs = ui_scrollView:getChildren()
	for key, obj in pairs(childs) do
		local ui_focus = obj:getChildByName("image_choose")
		if _curIndex == key then
			ui_focus:setVisible(true)
			
			local contaniner = ui_scrollView:getInnerContainer()
			local w = (contaniner:getContentSize().width - ui_scrollView:getContentSize().width)
			local dt
			if w == 0 then
				dt = 0
			else
				dt = (obj:getPositionX() + obj:getContentSize().width - ui_scrollView:getContentSize().width) / w
				if dt < 0 then
					dt = 0
				end
			end
			if isJumpTo then
				ui_scrollView:jumpToPercentHorizontal(dt * 100)
			else
				ui_scrollView:scrollToPercentHorizontal(dt * 100, 0.5, true)
			end
		else
			ui_focus:setVisible(false)
		end
	end
end

local function netCallbackFunc(_msgData)
    local code = tonumber(_msgData.header)
    if code == StaticMsgRule.equipYFire then
        UIFireAdd.setup(_curShowIndex)
        UIFire.setup(userData.showFireIndex)
        if _curEquipFirePos then
            local animation = ActionManager.getUIAnimation(54, function(armature)
                _curEquipFirePos = nil
            end)
            animation:setPosition(_curEquipFirePos)
		    UIFireAdd.Widget:addChild(animation, 10000)
        end
    end
end

local function setFireUI(_cardInstId)
    if userData == nil and net.InstPlayerCard[tostring(_cardInstId)] == nil then
        return
    end
    local image_basemap = UIFireAdd.Widget:getChildByName("image_basemap")
    local image_base = image_basemap:getChildByName("image_base")
    local ui_fireTitleName = ccui.Helper:seekNodeByName(image_base, "text_fight_name")
    local fireUI = {}
    for i, obj in pairs(dp.FireEquipGrid) do
        fireUI[i] = {
            ui_fireIcon = image_base:getChildByName("image_fire"..i),
            ui_fireState = image_base:getChildByName("image_kuang"..i):getChildByName("image_state"),
            ui_fireText = image_base:getChildByName("text_info"..i)
        }
    end
    ui_fireTitleName:setString(Lang.ui_fire_add1 .. userData.fireData.DictYFire.name)

    local _equipFireInstData = utils.getEquipFireInstData(_cardInstId)
    local instCardData = net.InstPlayerCard[tostring(_cardInstId)] --卡牌实例数据
	local qualityId = instCardData.int["4"] --品阶ID
	local starLevelId = instCardData.int["5"] --星级ID
    for key, objUI in pairs(fireUI) do
        fireUI[key].ui_fireIcon:setTouchEnabled(false)
        local _gridState = 0 --0.上锁, 1.开启
        if qualityId >= dp.FireEquipGrid[key].qualityId then
            if qualityId == dp.FireEquipGrid[key].qualityId then
                if starLevelId >= dp.FireEquipGrid[key].starLevelId then
                    _gridState = 1
                end
            else
                _gridState = 1
            end
        end
        if _gridState == 0 then
            fireUI[key].ui_fireIcon:loadTexture("ui/mg_suo.png")
            fireUI[key].ui_fireState:setVisible(false)
            fireUI[key].ui_fireText:setTextColor(cc.c4b(255, 255, 255, 255))
            local _openText = ""
            --/////////// 暂时写死，最大开放到红品5阶 ////////////
            if DictQuality[tostring(dp.FireEquipGrid[key].qualityId)] == nil then
                _openText = Lang.ui_fire_add2 .. DictStarLevel[tostring(dp.FireEquipGrid[key].starLevelId)].name
            else
                _openText = DictQuality[tostring(dp.FireEquipGrid[key].qualityId)].name .. DictStarLevel[tostring(dp.FireEquipGrid[key].starLevelId)].name
            end
            --/////////// 暂时写死，最大开放到红品5阶 ////////////
            fireUI[key].ui_fireText:setString(_openText .. Lang.ui_fire_add3)
            fireUI[key].ui_fireText:setVisible(true)
        elseif _gridState == 1 then
            fireUI[key].ui_fireIcon:loadTexture("ui/frame_tianjia.png")
            fireUI[key].ui_fireState:setVisible(false)
            fireUI[key].ui_fireText:setVisible(false)
            fireUI[key].ui_fireIcon:setTouchEnabled(true)
        end
        local InstPlayerYFire = _equipFireInstData[key]
        if InstPlayerYFire then
            local _dictYFireData = DictYFire[tostring(InstPlayerYFire.int["3"])]
            fireUI[key].ui_fireIcon:loadTexture("image/fireImage/" .. DictUI[tostring(_dictYFireData.smallUiId)].fileName)
            if InstPlayerYFire.int["4"] == 1 then
                fireUI[key].ui_fireState:loadTexture("ui/fire_low.png")
            elseif InstPlayerYFire.int["4"] == 2  then
                fireUI[key].ui_fireState:loadTexture("ui/fire_high.png")
            end
            if _gridState ~= 1 then
                fireUI[key].ui_fireText:setTextColor(cc.c4b(255, 0, 0, 255))
                fireUI[key].ui_fireText:setString(Lang.ui_fire_add4)
                fireUI[key].ui_fireIcon:setTouchEnabled(false)
            else
                fireUI[key].ui_fireText:setTextColor(cc.c4b(255, 255, 0, 255))
                fireUI[key].ui_fireText:setString(_dictYFireData.name)
                fireUI[key].ui_fireIcon:setTouchEnabled(true)
            end
            fireUI[key].ui_fireState:setVisible(true)
            fireUI[key].ui_fireText:setVisible(true)
        end
        fireUI[key].ui_fireIcon:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if userData.fireData.InstPlayerYFire then
                    local _fireState = utils.getEquipFireState(userData.fireData.InstPlayerYFire.int["1"])
                    if _fireState ~= 2 then
                        UIManager.showToast(Lang.ui_fire_add5)
                        return
                    end
                end
                for _i, _obj in pairs(_equipFireInstData) do
                    if _obj.int["3"] == userData.fireData.DictYFire.id then
                        UIManager.showToast(Lang.ui_fire_add6)
                        return
                    end
                end
                _curEquipFirePos = sender:getParent():convertToWorldSpace(cc.p(sender:getPositionX(), sender:getPositionY()))
                UIManager.showLoading()
                local _msgData = {
                    header = StaticMsgRule.equipYFire,
                    msgdata = {
                        int = {
                            fireId = userData.fireData.DictYFire.id,
                            cardId = _cardInstId,
                            posIndex = key
                        }
                    }
                }
                netSendPackage(_msgData, netCallbackFunc)
            end
        end)
    end

    for key, obj in pairs(CustomDictYFireProp) do
        local ui_propItem = image_base:getChildByName("image_change" .. key)
        local ui_titleName = ccui.Helper:seekNodeByName(ui_propItem, "text_name")
        local ui_quality = ui_propItem:getChildByName("text_quality")
        local ui_fireNum = ui_propItem:getChildByName("text_number")
        local ui_propInfo = ui_propItem:getChildByName("text_info")
        ui_titleName:setString(obj.name)
        local _openText = ""
        --/////////// 暂时写死，最大开放到红品5阶 ////////////
        if DictQuality[tostring(obj.qualityId)] == nil then
            _openText = Lang.ui_fire_add7 .. DictStarLevel[tostring(obj.starLevelId)].name
        else
            _openText = DictQuality[tostring(obj.qualityId)].name .. DictStarLevel[tostring(obj.starLevelId)].name
        end
        --/////////// 暂时写死，最大开放到红品5阶 ////////////
        ui_quality:setString(_openText)
        ui_fireNum:setString(string.format(Lang.ui_fire_add8, obj.equipFireCount))
        ui_quality:setTextColor(cc.c3b(255, 0, 0, 255))
        ui_fireNum:setTextColor(cc.c3b(255, 0, 0, 255))
        local _condition = 0 --0.未达成, 1.达成
        if qualityId >= obj.qualityId then
            if qualityId == obj.qualityId then
                if starLevelId >= obj.starLevelId then
                    _condition = 1
                end
            else
                _condition = 1
            end
        end
        if _condition == 1 then
            ui_quality:setTextColor(cc.c3b(0, 111, 21, 255))
        end
        if #_equipFireInstData >= obj.equipFireCount then
            ui_fireNum:setTextColor(cc.c3b(0, 111, 21, 255))
        end
        if _condition == 1 and #_equipFireInstData >= obj.equipFireCount then
            utils.GrayWidget(ui_titleName:getParent(), false)
            ui_propInfo:setTextColor(cc.c4b(51, 25, 4, 255))
        else
            utils.GrayWidget(ui_titleName:getParent(), true)
            ui_propInfo:setTextColor(cc.c4b(125, 122, 121, 255))
        end

        local fightPropId = utils.stringSplit(obj.fightPropId, ";")
        local fightPropValue = utils.stringSplit(obj.fightPropValue, ";")
        local _texts = {}
        for _k, _o in pairs(fightPropId) do
            if tonumber(_o) == StaticFightProp.blood then
                _texts[#_texts + 1] = DictFightProp[_o].name .. Lang.ui_fire_add9 .. fightPropValue[_k] .. "%"
            else
                if tonumber(_o) == StaticFightProp.wDefense or tonumber(_o) == StaticFightProp.fDefense then
                    _texts[#_texts + 1] = DictFightProp[_o].name .. Lang.ui_fire_add10 .. fightPropValue[_k] .. "%"
                end
            end
        end
        local _stringText = ""
        for _i, _t in pairs(_texts) do
            if _i == #_texts then
                _stringText = _stringText .. _t
            else
                _stringText = _stringText .. _t .. "，"
            end
        end
        ui_propInfo:setString(_stringText)
    end
end

function UIFireAdd.init()
    local image_basemap = UIFireAdd.Widget:getChildByName("image_basemap")
    local image_base = image_basemap:getChildByName("image_base")
    local text_title = image_basemap:getChildByName("text_title")
    local btn_close = image_basemap:getChildByName("btn_close")
    local btn_l = ccui.Helper:seekNodeByName(image_base, "btn_r")
    local btn_r = ccui.Helper:seekNodeByName(image_base, "btn_l")
    local btn_exit = image_basemap:getChildByName("btn_out")
    btn_close:setPressedActionEnabled(true)
    btn_l:setPressedActionEnabled(true)
    btn_r:setPressedActionEnabled(true)
    btn_exit:setPressedActionEnabled(true)
    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close or sender == btn_exit then
                UIManager.popScene()
            elseif sender == btn_l or sender == btn_r then
                local childs = ui_scrollView:getChildren()
                local _index = _curShowIndex and _curShowIndex or 1
                if sender == btn_l then
                    _index = _curShowIndex - 1
                elseif sender == btn_r then
                    _index = _curShowIndex + 1
                end
                if _index <= 0 then
                    _index = 1
                elseif _index > #childs then
                    _index = #childs
                end
	            for key, iconItem in pairs(childs) do
                    if key == _index then
                        iconItem:releaseUpEvent()
                        break
                    end
                end
            end
        end
    end
    btn_close:addTouchEventListener(onButtonEvent)
    btn_l:addTouchEventListener(onButtonEvent)
    btn_r:addTouchEventListener(onButtonEvent)
    btn_exit:addTouchEventListener(onButtonEvent)
    
    ui_scrollView = ccui.Helper:seekNodeByName(image_base, "view_warrior")
    ui_svItem = ui_scrollView:getChildByName("btn_base_warrior"):clone()

    text_title:setString(Lang.ui_fire_add11 .. (userData and userData.fireData.DictYFire.name or Lang.ui_fire_add12))
end

function UIFireAdd.setup(_k)
    local formation1, formation2 = {}, {}
	for key, obj in pairs(net.InstPlayerFormation) do
		if obj.int["4"] == 1 then	--主力
			formation1[#formation1 + 1] = obj
		elseif obj.int["4"] == 2 then --替补
			formation2[#formation2 + 1] = obj
		end
	end
	local function compareFunc(obj1, obj2)
		if obj1.int["1"] > obj2.int["1"] then
			return true
		end
		return false
	end
	utils.quickSort(formation1, compareFunc)
	utils.quickSort(formation2, compareFunc)
    local _listData = {}
    for key = 1, #formation1 + #formation2 do
		if formation1[key] then
			_listData[key] = formation1[key]
		elseif formation2[key - #formation1] then
			_listData[key] = formation2[key - #formation1]
		end
    end
    layoutScrollView(_listData, function(_item, _data)
        local instCardId = _data.int["3"] --卡牌实例ID
		local type = _data.int["4"] --阵型类型 1:主力,2:替补
		local dictCardId = _data.int["6"] --卡牌字典ID
		local instCardData = net.InstPlayerCard[tostring(instCardId)] --卡牌实例数据
		local dictCardData = DictCard[tostring(dictCardId)] --卡牌字典数据
		local qualityId = instCardData.int["4"] --品阶ID
        local ui_cardIcon = _item:getChildByName("image_warrior")
        local ui_cardFocus = _item:getChildByName("image_choose")
        local ui_bench = _item:getChildByName("image_title")
        local qualityImage = utils.getQualityImage(dp.Quality.card, qualityId, dp.QualityImageType.small)
        _item:loadTextures(qualityImage, qualityImage)
        local isAwake = tonumber(instCardData.int["18"])
        if isAwake == 1 then
            ui_cardIcon:loadTexture("image/" .. DictUI[tostring(dictCardData.awakeSmallUiId)].fileName)
        else
            ui_cardIcon:loadTexture("image/" .. DictUI[tostring(dictCardData.smallUiId)].fileName)
        end
        if type == 2 then
			ui_bench:setVisible(true)
		else
			ui_bench:setVisible(false)
		end
        ui_cardFocus:setVisible(false)
        _item:setTag(instCardId)
    end)
    
    local childs = ui_scrollView:getChildren()
	for key, iconItem in pairs(childs) do
        iconItem:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended and _curShowIndex ~= key then
                setScrollViewFocus(nil, key)
                setFireUI(iconItem:getTag())
                _curShowIndex = key
            end
        end)
    end
    local _index = _curShowIndex and _curShowIndex or 1
    if _k then
        _index = _k
        _curShowIndex = nil
    end
    if childs and childs[_index] then
        childs[_index]:releaseUpEvent()
    end
end

function UIFireAdd.free()
    cleanScrollView(true)
    _curShowIndex = nil
    userData = nil
    _curEquipFirePos = nil
end

function UIFireAdd.show(_tableParams)
    userData = _tableParams
    UIManager.pushScene("ui_fire_add")
end

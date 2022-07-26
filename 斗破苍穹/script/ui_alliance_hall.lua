require"Lang"
UIAllianceHall = {}

--单个材料最大捐献数量
local MAX_COUNT = 999

local ui_items = nil

local function refershBuildTemp()
    local image_basemap = UIAllianceHall.Widget:getChildByName("image_basemap")
    local image_di_l = image_basemap:getChildByName("image_di_l")
    local ui_allianceBuildTemp = image_di_l:getChildByName("text_build_add")
    local _buildTemp = 0
    for key, item in pairs(ui_items) do
        local _id = item:getTag()
        local _selectCount = item:getChildByName("image_base_number"):getChildByName("text_number")
        local _count = _selectCount:getString()
        if tonumber(_count) > 0 then
            _buildTemp = _buildTemp + (DictUnionMaterial[tostring(_id)].unionBuilder * _count)
        end
    end
    ui_allianceBuildTemp:setString("")
    if _buildTemp > 0 then
        ui_allianceBuildTemp:setString("+" .. _buildTemp)
    end
end

local function initAllianceInfo(_msgData)
    local image_basemap = UIAllianceHall.Widget:getChildByName("image_basemap")
    local image_di_l = image_basemap:getChildByName("image_di_l")
    local ui_allianceIcon = image_di_l:getChildByName("image_equipment")
    local ui_allianceName = image_di_l:getChildByName("text_name")
    local ui_allianceLevel = image_di_l:getChildByName("text_lv")
    local ui_allianceMember = image_di_l:getChildByName("text_member")
    local ui_allianceBuild = image_di_l:getChildByName("text_build")
    local ui_allianceBuildTemp = image_di_l:getChildByName("text_build_add")
    local ui_allianceBuildNeed = image_di_l:getChildByName("text_need")
    local ui_maxLevel = image_di_l:getChildByName("text_need_max")

    --defalut
    ui_allianceName:setString("???")
    ui_allianceLevel:setString(Lang.ui_alliance_hall1)
    ui_allianceMember:setString(Lang.ui_alliance_hall2)
    ui_allianceBuild:setString(Lang.ui_alliance_hall3)
    ui_allianceBuildTemp:setString("")
    ui_allianceBuildNeed:setVisible(true)
    ui_allianceBuildNeed:setString(Lang.ui_alliance_hall4)
    ui_maxLevel:setVisible(false)
    for key, obj in pairs(ui_items) do
        local _count = obj:getChildByName("image_frame_good"):getChildByName("text_good")
        _count:setTag(0)
        _count:setString(Lang.ui_alliance_hall5)
        local _selectCount = obj:getChildByName("image_base_number"):getChildByName("text_number")
        _selectCount:setString("0")
    end

    local unionDetail = UIAlliance.getUnionDetail(_msgData)
    if unionDetail then
        ui_allianceName:setString(unionDetail.name)
        ui_allianceLevel:setString(Lang.ui_alliance_hall6 .. unionDetail.level)
        ui_allianceMember:setString(string.format(Lang.ui_alliance_hall7, unionDetail.curMemberCount, unionDetail.maxMemberCount))
        ui_allianceBuild:setString(Lang.ui_alliance_hall8 .. unionDetail.exp)
        if DictUnionLevelPriv[tostring(unionDetail.level)] then
            if DictUnionLevelPriv[tostring(unionDetail.level)].exp == 0 then
                ui_maxLevel:setVisible(true)
                ui_allianceBuildNeed:setVisible(false)
                cclog("-------------己经最大等级---------")
            else
                ui_allianceBuildNeed:setString(Lang.ui_alliance_hall9 .. DictUnionLevelPriv[tostring(unionDetail.level)].exp)
            end
        end
        local materials = utils.stringSplit(unionDetail.materials, ";")
        for key, obj in pairs(materials) do
            local tempData = utils.stringSplit(obj, "_")
            local _id = tonumber(tempData[1])
            local _count = tonumber(tempData[2])
            local dictData = DictUnionMaterial[tostring(_id)]
            local item = ui_items[tonumber(key)]
            if item then
                item:setTag(dictData.id)
                local _frame = item:getChildByName("image_frame_good")
                local _icon = _frame:getChildByName("image_good")
                local _textCount = _frame:getChildByName("text_good")
                local _selectCount = item:getChildByName("image_base_number"):getChildByName("text_number")
                _icon:loadTexture("image/" .. DictUI[tostring(dictData.smallUiId)].fileName)
                utils.showThingsInfo(_icon, StaticTableType.DictUnionMaterial, dictData.id)
                _textCount:setTag(_count)
                _textCount:setString(Lang.ui_alliance_hall10 .. _count)
                local btn_add = item:getChildByName("btn_add")
                local btn_add_ten = item:getChildByName("btn_add_ten")
                local btn_cut = item:getChildByName("btn_cut")
                local btn_cut_ten = item:getChildByName("btn_cut_ten")

                local _schedulerId, _isLongPressed = nil, false
                local stopScheduler = function()
                    if _schedulerId then
						cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_schedulerId)
					end
                    _schedulerId = nil
                end
                local onTouchEventEnd = function(sender)
                    local _curSelectedCount = tonumber(_selectCount:getString())
                    if sender == btn_add then
                        _curSelectedCount = _curSelectedCount + 1
                        if _count < _curSelectedCount or _curSelectedCount > MAX_COUNT then
                            _curSelectedCount = _curSelectedCount - 1
                            UIManager.showToast(_curSelectedCount >= MAX_COUNT and Lang.ui_alliance_hall11 or Lang.ui_alliance_hall12)
                            stopScheduler()
                        end
                    elseif sender == btn_add_ten then
                        _curSelectedCount = _curSelectedCount + 10
                        if _count < _curSelectedCount or _curSelectedCount > MAX_COUNT then
                            if _curSelectedCount > MAX_COUNT then
                                _curSelectedCount = MAX_COUNT
                                UIManager.showToast(Lang.ui_alliance_hall13)
                            else
                                _curSelectedCount = _count
                                UIManager.showToast(Lang.ui_alliance_hall14)
                            end
                            stopScheduler()
                        end
                    elseif sender == btn_cut then
                        _curSelectedCount = _curSelectedCount - 1
                        if _curSelectedCount <= 0 then
                            _curSelectedCount = 0
                            stopScheduler()
                        end
                    elseif sender == btn_cut_ten then
                        _curSelectedCount = _curSelectedCount - 10
                        if _curSelectedCount <= 0 then
                            _curSelectedCount = 0
                            stopScheduler()
                        end
                    end
                    _textCount:setString(Lang.ui_alliance_hall15 .. _count - _curSelectedCount)
                    _selectCount:setString(tostring(_curSelectedCount))
                    refershBuildTemp()
                end
                
                local function onButtonEvent(sender, eventType)
                    if eventType == ccui.TouchEventType.began then
                        stopScheduler()
                        _isLongPressed = false
                        local _curTimer = os.clock()
					    _schedulerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
                            if not _isLongPressed and os.clock() - _curTimer >= 0.5 then
                                _isLongPressed = true
                            end
                            if _isLongPressed then
                                onTouchEventEnd(sender)
                            end
                        end, 0.1, false)
                    elseif eventType == ccui.TouchEventType.canceled then
                        stopScheduler()
                    elseif eventType == ccui.TouchEventType.ended then
                        stopScheduler()
                        if _isLongPressed then
                            return
                        end
                        onTouchEventEnd(sender)
                    end
                end
                btn_add:addTouchEventListener(onButtonEvent)
                btn_add_ten:addTouchEventListener(onButtonEvent)
                btn_cut:addTouchEventListener(onButtonEvent)
                btn_cut_ten:addTouchEventListener(onButtonEvent)
            end
        end
    end
end

local function netCallbackFunc(_msgData)
    local code = tonumber(_msgData.header)
	if code == StaticMsgRule.unionDetail then
		initAllianceInfo(_msgData)
    end
end

function UIAllianceHall.init()
    local image_basemap = UIAllianceHall.Widget:getChildByName("image_basemap")
    local btn_back = image_basemap:getChildByName("btn_back")
    local image_di_dowm = image_basemap:getChildByName("image_di_dowm")
    local btn_all = image_di_dowm:getChildByName("btn_all")
    local btn_donate = image_di_dowm:getChildByName("btn_donate")
    btn_back:setPressedActionEnabled(true)
    btn_all:setPressedActionEnabled(true)
    btn_donate:setPressedActionEnabled(true)
    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_back then
                UIAlliance.show()
            elseif sender == btn_all then
                for key, item in pairs(ui_items) do
                    local _textCount = item:getChildByName("image_frame_good"):getChildByName("text_good")
                    local _selectCount = item:getChildByName("image_base_number"):getChildByName("text_number")
                    local _selectedCount = (_textCount:getTag() > MAX_COUNT) and MAX_COUNT or _textCount:getTag()
                    _textCount:setString(Lang.ui_alliance_hall16 .. (_textCount:getTag() - _selectedCount))
                    _selectCount:setString(tostring(_selectedCount))
                end
                refershBuildTemp()
            elseif sender == btn_donate then
                local _paramStr = ""
                local _getUnionBuilder, _getUnionOffer = 0, 0
                for key, item in pairs(ui_items) do
                    local _id = item:getTag()
                    local _selectCount = item:getChildByName("image_base_number"):getChildByName("text_number")
                    local _count = _selectCount:getString()
                    if tonumber(_count) > 0 then
                        _paramStr = _paramStr .. (_id .. "_" .. _count .. ";")
                        _getUnionBuilder = _getUnionBuilder + DictUnionMaterial[tostring(_id)].unionBuilder * tonumber(_count)
                        _getUnionOffer = _getUnionOffer + DictUnionMaterial[tostring(_id)].unionOffer * tonumber(_count)
                    end
                end
                local strLastChar = string.sub(_paramStr, string.len(_paramStr), string.len(_paramStr))
                if strLastChar == ";" then
                    _paramStr = string.sub(_paramStr, 1, string.len(_paramStr) - 1)
                end
                if _paramStr == "" then
                    UIManager.showToast(Lang.ui_alliance_hall17)
                else
                    UIManager.showLoading()
                    netSendPackage( {
                        header = StaticMsgRule.unionHallDonate,
                        msgdata = { string = { materials = _paramStr }, int = { type = 1 } }
                    } , function(_msgData)
                        if _msgData.msgdata.int["1"] == 1 then
                            UIAlliance.showDialog(Lang.ui_alliance_hall18, function()
                                UIManager.showLoading()
                                netSendPackage( {
                                    header = StaticMsgRule.unionHallDonate,
                                    msgdata = { string = { materials = _paramStr }, int = { type = 2 } }
                                } , function(_messageData)
                                    UIManager.showToast(string.format(Lang.ui_alliance_hall19, _getUnionOffer))
                                    UIAllianceHall.setup()
                                end)
                            end)
                        else
                            UIManager.showToast(string.format(Lang.ui_alliance_hall20, _getUnionBuilder, _getUnionOffer))
                            UIAllianceHall.setup()
                        end
                    end)
                end
            end
        end
    end
    btn_back:addTouchEventListener(onButtonEvent)
    btn_all:addTouchEventListener(onButtonEvent)
    btn_donate:addTouchEventListener(onButtonEvent)

    ui_items = {
        image_basemap:getChildByName("image_di_tree"),
        image_basemap:getChildByName("image_di_stone"),
        image_basemap:getChildByName("image_di_iron"),
        image_basemap:getChildByName("image_di_gold")
    }
    for key, obj in pairs(DictUnionMaterial) do
        local item = ui_items[tonumber(key)]
        if item then
            local _frame = item:getChildByName("image_frame_good")
            local _icon = _frame:getChildByName("image_good")
            _icon:loadTexture("image/" .. DictUI[tostring(obj.smallUiId)].fileName)
            utils.showThingsInfo(_icon, StaticTableType.DictUnionMaterial, obj.id)
            local btn_add = item:getChildByName("btn_add")
            local btn_add_ten = item:getChildByName("btn_add_ten")
            local btn_cut = item:getChildByName("btn_cut")
            local btn_cut_ten = item:getChildByName("btn_cut_ten")
            btn_add:setPressedActionEnabled(true)
            btn_add_ten:setPressedActionEnabled(true)
            btn_cut:setPressedActionEnabled(true)
            btn_cut_ten:setPressedActionEnabled(true)
        end
    end
end

function UIAllianceHall.setup()
    UIManager.showLoading()
    netSendPackage( {
        header = StaticMsgRule.unionDetail,
        msgdata = { int = { instUnionMemberId = net.InstUnionMember.int["1"] } }
    } , netCallbackFunc)
end

function UIAllianceHall.show()
    UIManager.showWidget("ui_alliance_hall")
end

function UIAllianceHall.free()

end

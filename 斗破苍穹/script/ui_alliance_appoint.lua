require"Lang"
UIAllianceAppoint = {}

--联盟职位ID（对应UI顺序）
local DictUnionGradeID = {3,5,4,2,1}

local userData = nil

local function netCallbackFunc(_msgData)
    local code = tonumber(_msgData.header)
    if code == StaticMsgRule.appointUnion then
        UIManager.popScene()
        UIAllianceMember.setup()
    end
end

function UIAllianceAppoint.init()
    local image_basemap = UIAllianceAppoint.Widget:getChildByName("image_basemap")
    local btn_closed = image_basemap:getChildByName("btn_closed")
    local btn_sure = image_basemap:getChildByName("btn_sure")
    btn_closed:setPressedActionEnabled(true)
    btn_sure:setPressedActionEnabled(true)
    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_closed then
                UIManager.popScene()
            elseif sender == btn_sure then
                local _selectedGradeId = nil
                for key, id in pairs(DictUnionGradeID) do
                    local ui_checkbox = image_basemap:getChildByName("checkbox_practice" .. key)
                    if ui_checkbox:isVisible() and ui_checkbox:isSelected() then
                        _selectedGradeId = id
                        break
                    end
                end
                if _selectedGradeId then
                    local sendPackage = function()
                        UIManager.showLoading()
                        netSendPackage( {
                            header = StaticMsgRule.appointUnion,
                            msgdata =
                            { int = { instUnionMemberId = userData.instUnionMemberId, unionGradeId = _selectedGradeId } }
                        } , netCallbackFunc)
                    end
                    if _selectedGradeId == 1 then
                        UIAlliance.showDialog(Lang.ui_alliance_appoint1 .. userData.playerName .. Lang.ui_alliance_appoint2, function()
                            sendPackage()
                        end )
                    elseif _selectedGradeId == 2 then
                        UIAlliance.showDialog(Lang.ui_alliance_appoint3 .. userData.playerName .. Lang.ui_alliance_appoint4, function()
                            sendPackage()
                        end )
                    else
                        sendPackage()
                    end
                else
                    UIManager.showToast(Lang.ui_alliance_appoint5)
                end
            end
        end
    end
    btn_closed:addTouchEventListener(onButtonEvent)
    btn_sure:addTouchEventListener(onButtonEvent)
end

function UIAllianceAppoint.setup()
    local image_basemap = UIAllianceAppoint.Widget:getChildByName("image_basemap")
    local text_hint = image_basemap:getChildByName("text_hint")
    text_hint:setString(string.format(Lang.ui_alliance_appoint6, userData.playerName))

    local selfGradeId = net.InstUnionMember.int["4"]
    local grades = DictUnionLevelPriv[tostring(userData.unionDetail.level)].grade
    local tempData = utils.stringSplit(grades, ";")
    local ui_checkboxs = {}
    for key, id in pairs(DictUnionGradeID) do
        local ui_checkbox = image_basemap:getChildByName("checkbox_practice" .. key)
        ui_checkboxs[key] = ui_checkbox
        if selfGradeId == 2 and (id == 1 or id == 2) then --副盟主
            ui_checkbox:setVisible(false)
        else
            local _curCount = (userData.memberCounts[id] and userData.memberCounts[id] or 0)
            local _count = 0
            if id ~= 3 then
                for _k, _data in pairs(tempData) do
                    local _tempData = utils.stringSplit(_data, "_")
                    if tonumber(_tempData[1]) == id then
                        _count = tonumber(_tempData[2])
                        break
                    end
                end
                ui_checkbox:getChildByName("text_practice"):setString(string.format("%s（%d/%d）", DictUnionGrade[tostring(id)].name, _curCount, _count))
            end
            ui_checkbox:addEventListener(function(sender, eventType)
                if eventType == ccui.CheckBoxEventType.selected then
                    for _i, _item in pairs(ui_checkboxs) do
                        _item:setSelected(false)
                    end
                    if id ~= 1 and id ~= 3 and _curCount >= _count then
                        UIManager.showToast(string.format(Lang.ui_alliance_appoint7, DictUnionGrade[tostring(id)].name))
                        return
                    end
                    sender:setSelected(true)
                elseif eventType == ccui.CheckBoxEventType.unselected then
                end
            end)
        end
    end
end

function UIAllianceAppoint.show(_tableParams)
    userData = _tableParams
    UIManager.pushScene("ui_alliance_appoint")
end

function UIAllianceAppoint.free()
    userData = nil
end

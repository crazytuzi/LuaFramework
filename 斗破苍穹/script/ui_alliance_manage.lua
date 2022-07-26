require"Lang"
UIAllianceManage = {}

local userData = nil
local unionDetail = nil

local function initAllianceInfo(_msgData)
    local image_basemap = UIAllianceManage.Widget:getChildByName("image_basemap")
    local image_di_l = image_basemap:getChildByName("image_di_l")
    local ui_allianceIcon = image_di_l:getChildByName("image_equipment")
    local ui_allianceName = image_di_l:getChildByName("text_name")
    local ui_allianceLevel = image_di_l:getChildByName("text_lv")
    local ui_allianceMember = image_di_l:getChildByName("text_member")
    local ui_allianceLeader = image_di_l:getChildByName("text_leader")

    --更换旗帜
    local btn_change = image_basemap:getChildByName("btn_change")

    --申请审核
    local btn_examine = image_basemap:getChildByName("btn_examine")

    --解散联盟
    local btn_out = image_basemap:getChildByName("btn_out")

    local image_notice = image_basemap:getChildByName("image_notice")
    local ui_textNotice = image_notice:getChildByName("text_notice")
    local btn_changeNotice = image_notice:getChildByName("btn_change")

    local image_hint = image_basemap:getChildByName("image_hint")
    local ui_textHint = image_hint:getChildByName("text_hint")
    local btn_changeHint = image_hint:getChildByName("btn_change")

    --defalut
    ui_allianceIcon:loadTexture("image/" .. DictUI[tostring(DictUnionFlag["1"].bigUiId)].fileName)
    ui_allianceName:setString("???")
    ui_allianceLevel:setString(Lang.ui_alliance_manage1)
    ui_allianceMember:setString(Lang.ui_alliance_manage2)
    ui_allianceLeader:setString(Lang.ui_alliance_manage3)
    btn_change:setVisible(false)
    btn_examine:setVisible(false)
    btn_out:setVisible(false)
    ui_textNotice:setString("")
    btn_changeNotice:setVisible(false)
    ui_textHint:setString("")
    btn_changeHint:setVisible(false)
    unionDetail = nil

    unionDetail = UIAlliance.getUnionDetail(_msgData)
    if unionDetail then
        ui_allianceIcon:loadTexture("image/" .. DictUI[tostring(DictUnionFlag[tostring(unionDetail.iconId)].bigUiId)].fileName)
        ui_allianceName:setString(unionDetail.name)
        ui_allianceLevel:setString(Lang.ui_alliance_manage4 .. unionDetail.level)
        ui_allianceMember:setString(string.format(Lang.ui_alliance_manage5, unionDetail.curMemberCount, unionDetail.maxMemberCount))
        ui_allianceLeader:setString(Lang.ui_alliance_manage6 .. unionDetail.leaderName)
        ui_textNotice:setString(unionDetail.notice)
        ui_textHint:setString(unionDetail.manifesto)
        local selfGradeId = net.InstUnionMember.int["4"]
	    if selfGradeId == 1 or selfGradeId == 2 then
            btn_change:setVisible(true)
            btn_examine:setVisible(true)
            if selfGradeId == 1 then
                btn_out:setVisible(true)
            end
            btn_changeNotice:setVisible(true)
            btn_changeHint:setVisible(true)
        end
    end
end

local function netCallbackFunc(_msgData)
    local code = tonumber(_msgData.header)
	if code == StaticMsgRule.unionDetail then
		initAllianceInfo(_msgData)
    elseif code == StaticMsgRule.writeUnion then
        UIAllianceManage.setup()
    elseif code == StaticMsgRule.dissolveUnion then
        UIManager.showToast(Lang.ui_alliance_manage7)
		UIMenu.onHomepage()
    end
end

function UIAllianceManage.init()
    local image_basemap = UIAllianceManage.Widget:getChildByName("image_basemap")
    local btn_back = image_basemap:getChildByName("btn_back")

    --更换旗帜
    local btn_change = image_basemap:getChildByName("btn_change")

    --申请审核
    local btn_examine = image_basemap:getChildByName("btn_examine")

    --解散联盟
    local btn_out = image_basemap:getChildByName("btn_out")

    local image_notice = image_basemap:getChildByName("image_notice")
    local text_notice = image_notice:getChildByName("text_notice")
    local btn_changeNotice = image_notice:getChildByName("btn_change")

    local image_hint = image_basemap:getChildByName("image_hint")
    local text_hint = image_hint:getChildByName("text_hint")
    local btn_changeHint = image_hint:getChildByName("btn_change")

    btn_back:setPressedActionEnabled(true)
    btn_change:setPressedActionEnabled(true)
    btn_examine:setPressedActionEnabled(true)
    btn_out:setPressedActionEnabled(true)
    btn_changeNotice:setPressedActionEnabled(true)
    btn_changeHint:setPressedActionEnabled(true)
    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_back then
                UIAlliance.show()
            elseif sender == btn_change then
                UIAllianceManageChange.show({ allianceIconId = unionDetail.iconId })
            elseif sender == btn_examine then
                if unionDetail then
                    UIAllianceApply.show({ currentCount = unionDetail.curMemberCount, totalCount = unionDetail.maxMemberCount })
                end
            elseif sender == btn_out then
                local _memberCount = unionDetail and unionDetail.curMemberCount or 0
                if _memberCount >= 5 then
					UIManager.showToast(Lang.ui_alliance_manage8)
				else
					UIAlliance.showDialog(Lang.ui_alliance_manage9, function()
						UIManager.showLoading()
						netSendPackage({header = StaticMsgRule.dissolveUnion, msgdata = {int={instUnionMemberId=net.InstUnionMember.int["1"]}}}, netCallbackFunc)
					end)
				end
            elseif sender == btn_changeNotice then
                UIAllianceHint.show({title=Lang.ui_alliance_manage10,desc=text_notice:getString(),callbackFunc=netCallbackFunc})
            elseif sender == btn_changeHint then
                UIAllianceHint.show({title=Lang.ui_alliance_manage11,desc=text_hint:getString(),callbackFunc=netCallbackFunc})
            end
        end
    end
    btn_back:addTouchEventListener(onButtonEvent)
    btn_change:addTouchEventListener(onButtonEvent)
    btn_examine:addTouchEventListener(onButtonEvent)
    btn_out:addTouchEventListener(onButtonEvent)
    btn_changeNotice:addTouchEventListener(onButtonEvent)
    btn_changeHint:addTouchEventListener(onButtonEvent)
end

function UIAllianceManage.setup()
    UIManager.showLoading()
    netSendPackage( {
        header = StaticMsgRule.unionDetail,
        msgdata = { int = { instUnionMemberId = net.InstUnionMember.int["1"] } }
    } , netCallbackFunc)

    local image_basemap = UIAllianceManage.Widget:getChildByName("image_basemap")
    local btn_examine = image_basemap:getChildByName("btn_examine")
    local image_hint = btn_examine:getChildByName("image_hint")
    image_hint:setVisible(false)
    local selfGradeId = net.InstUnionMember.int["4"]
    if selfGradeId == 1 or selfGradeId == 2 then
        netSendPackage( { header = StaticMsgRule.obtainApply, msgdata = { int = { instUnionMemberId = net.InstUnionMember.int["1"] } } }, function(_msgData)
            -- //审核状态 0-关闭  1-开启
            local _applyState = _msgData.msgdata.int["1"]
            if _applyState == 1 then
                local unionApply = _msgData.msgdata.message.unionApply
		        if unionApply and unionApply.message then
                    local applyLists = {}
			        for key, obj in pairs(unionApply.message) do
				        applyLists[#applyLists + 1] = obj
			        end
                    if #applyLists > 0 then
                        image_hint:setVisible(true)
                    end
		        end
            end
        end )
    end
end

function UIAllianceManage.show(_tableParams)
    userData = _tableParams
    UIManager.showWidget("ui_alliance_manage")
end

function UIAllianceManage.free()
    userData = nil
    unionDetail = nil
end

require"Lang"

require"SDK"

UIName = {}

local ui_nameLabel = nil
local ui_editBox = nil

local function ADPromotion()
	if device.platform == "ios" then
		local di = SDK.getDeviceInfo()

        local channel_tag = "yiyou"
        if di.packageName == "com.y2game.doupocangqiong" then
            channel_tag = "iosy2game"
        elseif di.packageName == "com.dpdl.20161009.zy" then
            channel_tag = "iosy2gamenew"
        end
        cclog("10012 建角色-------------------")
		local http = cc.XMLHttpRequest:new()
		http.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
		local url = "http://ad.huayigame.com/10012?event_tag=CREATE_ROLE&channel_tag=" .. channel_tag .. "&app_id=" .. di.appId .. "&idfa=" .. di.idfa .. "&device_mac=" .. di.macAddr .. "&key_1=user_id&value_1=" .. SDK.getUserId() .. "&device_ua=" .. di.ua .. "&device_os=" .. di.systemName .. "&device_os_version=" .. di.systemVersion
		url = url:gsub(" ","%%20") -- only convert " " to "%20"
		http:open("GET",url)
		http:registerScriptHandler(function() http = nil end)
		http:send()
	end
end

local function netCallbackFunc(data)
    SDK.firstCreate = 1
	local code = tonumber(data.header)
	if code == StaticMsgRule.randomName then
		if ui_nameLabel then
			ui_nameLabel:setString(data.msgdata.string["1"])
		end
		if ui_editBox then
			ui_editBox:setText(data.msgdata.string["1"])
		end
	elseif code == StaticMsgRule.giveName then
        local role = dp.getUserData() --zhenyi  建角统计
		SDK.notifyTDCreateRole({roleName = ui_editBox:getText() , roleId = role.roleId , serverId = role.serverId })
        SDK.reYunOnRegister({roleId = tostring(role.roleId) })
		ADPromotion()
		net.loadGameData(data)
		UIGuidePeople.setGuide()
	end
end

function UIName.init()
	ui_nameLabel = ccui.Helper:seekNodeByName(UIName.Widget, "text_name")
	local btn_randomName = ccui.Helper:seekNodeByName(UIName.Widget, "btn_random")
	local btn_enter = ccui.Helper:seekNodeByName(UIName.Widget, "btn_found")

	ui_editBox = cc.EditBox:create(ui_nameLabel:getContentSize(), cc.Scale9Sprite:create())
  ui_editBox:setAnchorPoint(ui_nameLabel:getAnchorPoint())
  ui_editBox:setPosition(ui_nameLabel:getPosition())
  ui_editBox:setFont(dp.FONT, 25)
  ui_editBox:setFontColor(cc.c3b(255, 255, 255))
  ui_editBox:setPlaceHolder(Lang.ui_name1)
  ui_editBox:setMaxLength(8)
  ui_nameLabel:getParent():addChild(ui_editBox, -1)
  if UIName.defaultName then
  	ui_editBox:setText(UIName.defaultName)
  	ui_nameLabel:setString(UIName.defaultName)
	end

	ui_editBox:registerScriptEditBoxHandler(function(eventType, sender)
        local isIOS = device.platform == "ios"
		if eventType == "return" then
			ui_nameLabel:setString(ui_editBox:getText())
        elseif eventType == "began" then
            if isIOS then ui_nameLabel:setVisible(false) end
        elseif eventType == "ended" then
            if isIOS then ui_nameLabel:setVisible(true) end
		end
	end)

	btn_randomName:setPressedActionEnabled(true)
	btn_enter:setPressedActionEnabled(true)
	local function onBtnEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == btn_randomName then
				UIManager.showLoading()
				netSendPackage({header = StaticMsgRule.randomName,msgdata = {}}, netCallbackFunc)
			elseif sender == btn_enter then
				local _strName = ui_nameLabel:getString()
				if string.len(_strName) > 0 then
					local sendData = {
						header = StaticMsgRule.giveName,
						msgdata = {
							string = {
								name = _strName
							}
						}
					}
					UIManager.showLoading()
					netSendPackage(sendData, netCallbackFunc)
				else
					UIManager.showToast(Lang.ui_name2)
				end
			end
		end
	end
	btn_randomName:addTouchEventListener(onBtnEvent)
	btn_enter:addTouchEventListener(onBtnEvent)
end

function UIName.setup()

end

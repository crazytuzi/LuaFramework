local ContainerPray = {}

local var = {}
local despTable ={
	[1] = 	"<font color=#E7BA52 size=18>膜拜城主说明：</font>",
	[2] =	"<font color=#f1e8d0>1.活动开启后可进行膜拜/鄙视城主,每人每天最多可膜拜/鄙视10次</font>",
    [3] =	"<font color=#f1e8d0>2.刷新奖励后再进行膜拜可获得更多奖励,刷新失败不掉倍率</font>",
    [4] =	"<font color=#f1e8d0>3.活动期间内在土城安全区每5秒获得一次经验奖励,等级越高经验越多</font>",
}

function ContainerPray.initView(extend)
	var = {
		xmlPanel,
		expTimes,
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerPray.uif")
	if var.xmlPanel then
		GameUtilSenior.asyncload(var.xmlPanel, "panelbg", "ui/image/war_city_pray_bg.jpg");
		local btns = {"btn_bishi","btn_mobai","btn_fresh","btn_ten","btn_cityking_stamp","btn_dailyaward"}
		local ckick = function(sender,eventType)
			local name = sender:getName()
			if name =="btn_bishi" then
				GameSocket:PushLuaTable("npc.statue.onPanelData",GameUtilSenior.encode({cmd = "bishi"}))
			elseif name =="btn_mobai" then
				GameSocket:PushLuaTable("npc.statue.onPanelData",GameUtilSenior.encode({cmd = "mobai"}))
			elseif name =="btn_fresh" then
				GameSocket:PushLuaTable("npc.statue.onPanelData",GameUtilSenior.encode({cmd = "freshexp"}))
			elseif name =="btn_ten" then
				if var.expTimes == 4 then
					GameSocket:alertLocalMsg("已刷新至最高倍率", "alert")
				else
					GameSocket:dispatchEvent({
						name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", 
						lblConfirm = "将要消耗100元宝刷新至顶级奖励", 
						btnConfirm = "购买一次",
						btnCancel = "取消",
						checkBox = "tentimescheckbox",
						confirmCallBack = function ()
							GameSocket:PushLuaTable("npc.statue.onPanelData",GameUtilSenior.encode({cmd = "ten"}))
						end
					})
				end
			elseif name =="btn_cityking_stamp" then
				if eventType == ccui.TouchEventType.began then
					GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_TIPS, str = "kingcity", })
				elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled  then
					GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HIDE_TIPS, str = "kingcity", }) 
				end
			elseif name =="btn_dailyaward" then
				GameSocket:PushLuaTable("npc.statue.onPanelData",GameUtilSenior.encode({cmd = "getdailyaward"}))
			end
		end
		for k,v in pairs(btns) do
			local btn = var.xmlPanel:getWidgetByName(v):setTouchEnabled(true)
			if v == "btn_cityking_stamp" then
				btn:addTouchEventListener(ckick)
			else
				btn:addClickEventListener(ckick)
			end
		end
		local btn_info = var.xmlPanel:getWidgetByName("btn_info")
		btn_info:setTouchEnabled(true)
		btn_info:addTouchEventListener(function (pSender, touchType)
			if touchType == ccui.TouchEventType.began then
				btn_info:setScale(0.88, 0.88)
				local mParam = {
					name = GameMessageCode.EVENT_PANEL_ON_ALERT,
					panel = "tips", 
					infoTable = despTable,
					visible = true,
				}
				GameSocket:dispatchEvent(mParam)
			elseif touchType == ccui.TouchEventType.ended or touchType == ccui.TouchEventType.canceled then	
				btn_info:setScale(1, 1)
				GDivDialog.handleAlertClose()
			end
		end)
		for i=1,4 do
			var.xmlPanel:getWidgetByName("btn_times"..i):setEnabled(false)
		end
		var.xmlPanel:getWidgetByName("bar"):setLabelVisible(false):setPercent(0, 100)
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerPray.handlePanelData)
		return var.xmlPanel
	end
end

function ContainerPray.handlePanelData(event)
	if event.type ~= "ContainerPray" then return end
	local data = GameUtilSenior.decode(event.data)
	if data.cmd == "worshipPanel" then
		ContainerPray.freshPanel(data)
	end
end

function ContainerPray.freshPanel(data)
	var.expTimes = data.expTimes or 0
	local percent = data.percent or 0
	local btn_times
	for i=1,4 do
		btn_times = var.xmlPanel:getWidgetByName("btn_times"..i)
		btn_times:setEnabled(i<=var.expTimes)
		var.xmlPanel:getWidgetByName("lblexp"..i):setString("经验:"..data.expAward[i].exp)
	end
	var.xmlPanel:getWidgetByName("bar"):setPercent(percent, 100)
	var.xmlPanel:getWidgetByName("lbl_city_name"):setString(data.name or "无"):setLocalZOrder(10)
	var.xmlPanel:getWidgetByName("lbl_time"):setString(data.activity_time)
	var.xmlPanel:getWidgetByName("lbl_needcoin"):setString(data.needcoin)
	var.xmlPanel:getWidgetByName("lbl_left_times"):setString(data.worshipTimes or 10)
	ContainerPray.updateInnerLooks(data)
	local btn_dailyaward = var.xmlPanel:getWidgetByName("btn_dailyaward")
	if data.name == GameCharacter._mainAvatar:NetAttr(GameConst.net_name) then
		btn_dailyaward:show()
	else
		btn_dailyaward:hide()
	end
	btn_dailyaward:setEnabled(data.awardget==0)

	ContainerPray.showEffectSprite(var.xmlPanel:getWidgetByName("btn_bishi"),65300,data.showEffect)
	ContainerPray.showEffectSprite(var.xmlPanel:getWidgetByName("btn_mobai"),65300,data.showEffect)
end

function ContainerPray.showEffectSprite(widget,resid,visible)
	local pSize = widget:getContentSize()
	local effectSprite = widget:getChildByName("effectSprite")
	if not effectSprite then
		effectSprite = cc.Sprite:create()
			:align(display.CENTER, 0.5 * pSize.width, 0.5 * pSize.height)
			:addTo(widget)
			:setName("effectSprite")
	end
	effectSprite:stopAllActions():hide()
	local animate = cc.AnimManager:getInstance():getPlistAnimate(4, resid, 4, 5,false,false,0,function(animate,shouldDownload)
							if animate and visible then
								effectSprite:show():runAction(cca.repeatForever(animate))
							end
							if shouldDownload==true then
								effectSprite:release()
							end
						end,
						function(animate)
							effectSprite:retain()
						end)
	
end

function ContainerPray.updateInnerLooks(data)
	-- data = {
	-- 	cloth = 11116021,
	-- 	weapon = 11116011,
	-- 	wing = 69010,
	-- 	name = "adsf"
	-- }
	local isking = false
	local cloth = checknumber(data.cloth)
	local weapon = checknumber(data.weapon)
	local wing = checknumber(data.wing)
	local gender = checknumber(data.gender)
	if cloth>0 or weapon>0 or wing>0 or gender>0 then
		isking = true
		var.xmlPanel:getWidgetByName("readyfornull"):setVisible(false)
	else
		var.xmlPanel:getWidgetByName("readyfornull"):setVisible(true)
	end

	local img_role = var.xmlPanel:getWidgetByName("panelbg"):getChildByName("img_role")
	local img_wing = var.xmlPanel:getWidgetByName("panelbg"):getChildByName("img_wing")
	local img_weapon = var.xmlPanel:getWidgetByName("panelbg"):getChildByName("img_weapon")
	local femaleCloth = var.xmlPanel:getWidgetByName("panelbg"):getChildByName("femaleCloth")
	local femaleWeapon = var.xmlPanel:getWidgetByName("panelbg"):getChildByName("femaleWeapon")
	--设置翅膀内观
	if not img_wing then
		img_wing = cc.Sprite:create()
		img_wing:addTo(var.xmlPanel:getWidgetByName("panelbg")):align(display.CENTER, 468, 490):setName("img_wing")
	end
	if wing>0 then
		local filepath = string.format("image/fly/%d.png",wing+1000)
		asyncload_callback(filepath, img_wing, function(filepath, texture)
			img_wing:setVisible(true)
			img_wing:setTexture(filepath)--:setFlippedX(false)
		end)
	else
		img_wing:setTexture("null")
		img_wing:setVisible(false)
		img_wing.curwingId=nil
	end
	--设置衣服内观
	if not img_role then
		img_role = cc.Sprite:create()
		img_role:addTo(var.xmlPanel:getWidgetByName("panelbg")):align(display.CENTER, 552, 490):setName("img_role"):setLocalZOrder(0)
	end
	if not femaleCloth then
		femaleCloth = cc.Sprite:create()
		femaleCloth:addTo(var.xmlPanel:getWidgetByName("panelbg")):align(display.CENTER, 352, 490):setName("femaleCloth"):setLocalZOrder(0)
	end
	if not isking then
		local filepath = string.format("image/dress/%d.png",11116021)
		asyncload_callback(filepath, img_role, function(filepath, texture)
			img_role:setTexture(filepath)--:setFlippedX(true)
			img_role:setPositionX(552):show()
		end)
		local filepath2 = string.format("image/dress/%d.png",11116091)
		asyncload_callback(filepath2, femaleCloth, function(filepath2, texture)
			femaleCloth:setTexture(filepath2)
			femaleCloth:show()
		end)
	else
		if cloth==0 then 
			cloth = (gender==200 or gender =="male") and  10000000 or 10000001 
		else
			local itemdef = GameSocket:getItemDefByID(cloth)
			if itemdef then
				cloth = itemdef.mIconID
			end
		end
		if cloth>0 then
			local filepath = string.format("image/dress/%d.png",cloth)
			img_role:setPositionX(468)
			asyncload_callback(filepath, img_role, function(filepath, texture)
				img_role:setTexture(filepath)--:setFlippedX(false)
			end)
			if femaleCloth then
				femaleCloth:hide()
			end
		end
	end
	
    --设置武器内观
	if not img_weapon then
		img_weapon = cc.Sprite:create()
		img_weapon:addTo(var.xmlPanel:getWidgetByName("panelbg")):align(display.CENTER, 452, 490):setName("img_weapon"):setLocalZOrder(0)
	end
	if isking then
		if weapon>0 then
			local weaponDef = GameSocket:getItemDefByID(weapon)
			local filepath = string.format("image/arm/%d.png",weaponDef.mIconID)
			asyncload_callback(filepath, img_weapon, function(filepath, texture)
				img_weapon:setVisible(true)
				img_weapon:setTexture(filepath)--:setFlippedX(false)
			end)
		else
			img_weapon:setTexture("null")
		end
		img_weapon:setPositionX(468)
		if femaleWeapon then femaleWeapon:hide() end
	else
		if not femaleWeapon then
			femaleWeapon = cc.Sprite:create()
			femaleWeapon:addTo(var.xmlPanel:getWidgetByName("panelbg")):align(display.CENTER, 352, 490):setName("femaleWeapon"):setLocalZOrder(0)
		end
		local weaponDef = GameSocket:getItemDefByID(11115011)
		local filepath = string.format("image/arm/%d.png",weaponDef.mIconID)
		asyncload_callback(filepath, femaleWeapon, function(filepath, texture)
			femaleWeapon:setTexture(filepath)
			femaleWeapon:setVisible(true)
		end)
		local filepath2 = string.format("image/arm/%d.png",weaponDef.mIconID)
		asyncload_callback(filepath2, img_weapon, function(filepath2, texture)
			img_weapon:setVisible(true)
			img_weapon:setTexture(filepath2)--:setFlippedX(true)
			img_weapon:setPositionX(552)
		end)
	end
end

function ContainerPray.onPanelOpen(extend)
	GameSocket:PushLuaTable("npc.statue.onPanelData",GameUtilSenior.encode({cmd = "worshipPanel"}))

end

function ContainerPray.onPanelClose()

end

return ContainerPray
local ContainerWarCity = {}
local var = {}
local despTable ={
		"<font color=#E7BA52 size=18>皇城战说明：</font>",
		"<font color=#b2a58b>1.开服<font color=#30ff00>第4天</font>,自动开启<font color=#30ff00>首次</font>皇城战</font>",
		"<font color=#b2a58b>2.合服<font color=#30ff00>第3、5天</font>,自动开启皇城战</font>",
	    "<font color=#b2a58b>3.<font color=#30ff00>任意</font>帮会会长申请皇城战后，<font color=#30ff00>所有</font><br>帮会均可参战</font>",
	    "<font color=#b2a58b>4.申请皇城战需消耗:<font color=#ff3e3e>1个攻城号角</font>，申请成功后，次日开启皇城战</font>",
	    "<font color=#b2a58b>5.<font color=#30ff00>摧毁雕像后</font>才能进入皇宫，<font color=#30ff00>21:00</font>活动结束时，占领皇宫的帮会获胜</font>",
}

function ContainerWarCity.initView(extend)
	var = {
		xmlPanel,
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerWarCity.uif")
	if var.xmlPanel then
		
		--var.xmlPanel = var.xmlPanel:getWidgetByName("all_panel_bg")
		
		GameUtilSenior.asyncload(var.xmlPanel, "panelbg", "ui/image/war_city.jpg")
		var.xmlPanel:getWidgetByName("btn_go_city"):addClickEventListener(function( sender )
			GameSocket:PushLuaTable("npc.huangcheng.onPanelData",GameUtilSenior.encode({cmd = "deliver"}))
			GameSocket:dispatchEvent({name=GameMessageCode.EVENT_CLOSE_PANEL,str="extend_kingWar"})
		end)
		var.xmlPanel:getWidgetByName("lbl_open_time"):setString("")

		--local btn_info = var.xmlPanel:getWidgetByName("Text_21")
		--var.xmlPanel:getWidgetByName("btn_info")
		--btn_info:setTouchEnabled(true)
		--btn_info:addTouchEventListener(function (pSender, touchType)
		--	if touchType == ccui.TouchEventType.began then
		--		--btn_info:setScale(0.88, 0.88)
		--		local mParam = {
		--		name = GameMessageCode.EVENT_PANEL_ON_ALERT,
		--		panel = "tips",
		--		infoTable = despTable,
		--		visible = true,
		--		}
		--		GameSocket:dispatchEvent(mParam)
		--	elseif touchType == ccui.TouchEventType.ended or touchType == ccui.TouchEventType.canceled then
		--		btn_info:setScale(1, 1)
		--		GDivDialog.handleAlertClose()
		--	end
		--end)

		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerWarCity.handlePanelData)
			
		ContainerWarCity.updateGameMoney()
		var.xmlPanel:getWidgetByName("box_tab"):setSelectedTab(1)
		var.xmlPanel:getWidgetByName("box_tab"):addTabEventListener(pushTabButtons)
		
		return var.xmlPanel
	end
end

function pushTabButtons(sender)
	local opened, level, funcName
	opened = true
	local tag = sender:getTag()
	if tag == 2 then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="main_guild"})
	end
end

--金币刷新函数
function ContainerWarCity:updateGameMoney()
	local panel = var.xmlPanel
	if panel then
		local mainrole = GameSocket.mCharacter
		local moneyLabel = {
			{name="big_title_yb_text",btn="big_title_yb_btn",	pre=GameConst.str_vcoin,	value =	mainrole.mVCoin or 0	,	icon = "icon_coin"},
			{name="big_title_hmb_text",btn="big_title_hmb_btn",	pre=GameConst.str_vcoinb,	value =	mainrole.mVCoinBind or 0,	icon = "icon_coin_bind"},
			{name="big_title_jb_text",btn="big_title_jb_btn",	pre=GameConst.str_money,	value =	mainrole.mGameMoney or 0,	icon = "icon_money"},
			{name="lblBMoney",	pre=GameConst.str_moneyb,	value =	mainrole.mGameMoneyBind or 0,	icon = "icon_money"},
		}
		--建临时表遍历设属性
		for _,v in ipairs(moneyLabel) do
			if panel:getWidgetByName(v.name) then
				panel:getWidgetByName(v.name):setString(v.value)
				panel:getWidgetByName(v.btn):addClickEventListener( function (sender)
					GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="panel_charge"})
				end)
			end
		end
	end
end


function ContainerWarCity.handlePanelData(event)
	if event.type ~= "ContainerWarCity" then return end
	local data = GameUtilSenior.decode(event.data)
	if data.cmd == "panel" then
		ContainerWarCity.freshPanel(data)
	end
end

function ContainerWarCity.onPanelOpen(extend)
	GameSocket:PushLuaTable("npc.huangcheng.onPanelData",GameUtilSenior.encode({cmd = "cityPanel"}))
end

function ContainerWarCity.freshPanel(data)
	var.xmlPanel:getWidgetByName("lbl_open_time"):setString(data.openTime)
	var.xmlPanel:getWidgetByName("lbl_guild_name"):setString(data.guildName):setLocalZOrder(10)

	if GameUtilSenior.isTable(data.kingInfo) then
		ContainerWarCity.updateInnerLooks(data.kingInfo[1] ,1)
	else
		ContainerWarCity.updateInnerLooks({} ,1)
	end
	if GameUtilSenior.isTable(data.ViceAdminInfo) then
		ContainerWarCity.updateInnerLooks(data.ViceAdminInfo[1],2)
	else
		ContainerWarCity.updateInnerLooks({},2)
	end
	local ViceInfo = data.ViceInfo or {}
	for i=1,3 do
		ContainerWarCity.updateInnerLooks(ViceInfo[i],i+2)
	end
end

function ContainerWarCity.updateInnerLooks(data,index)
	local posY = {455,393,393,340,340}
	data = data or {}

	local cloth = checknumber(data.cloth)
	local weapon = checknumber(data.weapon)
	local wing = checknumber(data.wing)
	local gender = checknumber(data.gender) --GameCharacter._mainAvatar:NetAttr(GameConst.net_gender)
	local name = data.name
	local isExist = false
	if cloth>0 or weapon>0 or wing>0 or gender>0 then
		isExist = true
	end

	local widget = var.xmlPanel:getWidgetByName("innerlooks_"..index)
	local lbl = var.xmlPanel:getWidgetByName("img_xuweiyidai_"..index)
	local txtName = var.xmlPanel:getWidgetByName("lbl_name"..index)
	if data.name then
		lbl:hide()
		txtName:setString(data.name)
	else
		lbl:show()
		txtName:setString()
	end
	local img_role = widget:getChildByName("img_role")
	local img_wing = widget:getChildByName("img_wing")
	local img_weapon = widget:getChildByName("img_weapon")
	--设置翅膀内观
	if not img_wing then
		img_wing = cc.Sprite:create()
		img_wing:addTo(widget):align(display.CENTER, 0, 0):setName("img_wing")
	end
	if isExist and wing>0 then
		local filepath = string.format("image/fly/%d.png",wing+1000)
		asyncload_callback(filepath, img_wing, function(filepath, texture)
			img_wing:setVisible(true)
			img_wing:setTexture(filepath)
		end)
	else
		img_wing:setTexture("null")
		img_wing:setVisible(false)
	end
	--设置衣服内观
	if not img_role then
		img_role = cc.Sprite:create()
		img_role:addTo(widget):align(display.CENTER, 0, 32):setName("img_role"):setLocalZOrder(0)
	end
	if not isExist then
		local luoti= (gender==200 or gender =="male") and  10000000 or 10000001
		local filepath = "image/dress/"..luoti..".png"
		asyncload_callback(filepath, img_role, function(filepath, texture)
			img_role:setTexture("null")
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
			local filepath = "image/dress/"..cloth..".png"
			asyncload_callback(filepath, img_role, function(filepath, texture)
				img_role:setTexture(filepath)
			end)
		end
	end

    --设置武器内观
	if not img_weapon then
		img_weapon = cc.Sprite:create()
		img_weapon:addTo(widget):align(display.CENTER, 0, 32):setName("img_weapon"):setLocalZOrder(0)
	end
	-- local weapon = GameCharacter._mainAvatar:NetAttr(GameConst.net_weapon)
	if isExist and weapon>0 then
		local weaponDef = GameSocket:getItemDefByID(weapon)
		if weapon~=widget.curWeaponId then
			local filepath = "image/arm/"..weaponDef.mIconID..".png"
			asyncload_callback(filepath, img_weapon, function(filepath, texture)
				img_weapon:setVisible(true)
				img_weapon:setTexture(filepath)
			end)
			widget.curWeaponId=weapon
		end
	else
		img_weapon:setTexture("null")
		img_weapon:setVisible(false)
		widget.curWeaponId=nil
	end
end

function ContainerWarCity.onPanelClose()

end

return ContainerWarCity
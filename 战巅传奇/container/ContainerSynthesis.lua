local ContainerSynthesis = {}
local var = {}
local equipTypeDesp = {
	[11] = {desp = "任意<font color=#ffff00>1级</font>新八格装备，可用来合成<font color=#00ff00>2级</font>新八格装备",level = "--"},
	[12] = {desp = "任意<font color=#ffff00>2级</font>新八格装备，可用来合成<font color=#00ff00>3级</font>新八格装备",level = "--"},
	[13] = {desp = "任意<font color=#ffff00>3级</font>新八格装备，可用来合成<font color=#00ff00>4级</font>新八格装备",level = "--"},
	[14] = {desp = "任意<font color=#ffff00>4级</font>新八格装备，可用来合成<font color=#00ff00>5级</font>新八格装备",level = "--"},
	[15] = {desp = "任意<font color=#ffff00>5级</font>新八格装备，可用来合成<font color=#00ff00>6级</font>新八格装备",level = "--"},
	[16] = {desp = "任意<font color=#ffff00>6级</font>新八格装备，可用来合成<font color=#00ff00>7级</font>新八格装备",level = "--"},
	[17] = {desp = "任意<font color=#ffff00>7级</font>新八格装备，可用来合成<font color=#00ff00>8级</font>新八格装备",level = "--"},
	[18] = {desp = "任意<font color=#ffff00>8级</font>新八格装备，可用来合成<font color=#00ff00>9级</font>新八格装备",level = "--"},
	[19] = {desp = "任意<font color=#ffff00>9级</font>新八格装备，可用来合成<font color=#00ff00>10级</font>新八格装备",level = "--"},
	[20] = {desp = "任意<font color=#ffff00>10级</font>新八格装备，可用来合成<font color=#00ff00>11级</font>新八格装备",level = "--"},
	[21] = {desp = "任意<font color=#ffff00>11级</font>新八格装备，可用来合成<font color=#00ff00>12级</font>新八格装备",level = "--"},
	[22] = {desp = "任意<font color=#ffff00>12级</font>新八格装备，可用来合成<font color=#00ff00>13级</font>新八格装备",level = "--"},
	[23] = {desp = "任意<font color=#ffff00>13级</font>新八格装备，可用来合成<font color=#00ff00>14级</font>新八格装备",level = "--"},
	[24] = {desp = "任意<font color=#ffff00>14级</font>新八格装备，可用来合成<font color=#00ff00>15级</font>新八格装备",level = "--"},
	[25] = {desp = "任意<font color=#ffff00>15级</font>新八格装备，可用来合成<font color=#00ff00>16级</font>新八格装备",level = "--"},
	[26] = {desp = "任意<font color=#ffff00>16级</font>新八格装备，可用来合成<font color=#00ff00>17级</font>新八格装备",level = "--"},
	[27] = {desp = "任意<font color=#ffff00>17级</font>新八格装备，可用来合成<font color=#00ff00>18级</font>新八格装备",level = "--"},
	[28] = {desp = "任意<font color=#ffff00>18级</font>新八格装备，可用来合成<font color=#00ff00>19级</font>新八格装备",level = "--"},
	[29] = {desp = "任意<font color=#ffff00>19级</font>新八格装备，可用来合成<font color=#00ff00>20级</font>新八格装备",level = "--"},

}

local equip_info = {
		{pos = GameConst.ITEM_WEAPON_POSITION},
		{pos = GameConst.ITEM_CLOTH_POSITION},
		{pos = GameConst.ITEM_GLOVE1_POSITION},
		{pos = GameConst.ITEM_RING1_POSITION},
		{pos = GameConst.ITEM_BOOT_POSITION},

		{pos = GameConst.ITEM_HAT_POSITION},
		{pos = GameConst.ITEM_NICKLACE_POSITION},
		{pos = GameConst.ITEM_GLOVE2_POSITION},
		{pos = GameConst.ITEM_RING2_POSITION},
		{pos = GameConst.ITEM_BELT_POSITION},
}

function ContainerSynthesis.initView( extend )
	var = {
		xmlPanel,
		tabIndex = 1,
		pageIndex = 1,
		curItemIdx =1,
		tablistv,
	}

	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerSynthesis.uif");
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerSynthesis.handlePanelData)

		var.tablistv = var.xmlPanel:getWidgetByName("tablistv"):setFontSize(16)
		var.tablistv:hideTab({2,3})
		var.tablistv:addTabEventListener(ContainerSynthesis.pressTabV)
		GameUtilSenior.asyncload(var.xmlPanel, "img_inner_bg", "ui/image/img_compose_bg.jpg")
		var.xmlPanel:getWidgetByName("Image_25"):hide()

		return var.xmlPanel
	end
end

function ContainerSynthesis.pressTabV(sender)
	var.tabIndex = sender:getTag()
	var.pageIndex = 1
	ContainerSynthesis.initTabView()
end

function ContainerSynthesis.onPanelOpen()
	var.tablistv:setSelectedTab(1)
end

function ContainerSynthesis.handlePanelData(event)
	if event.type ~= "ContainerSynthesis" then return end
	local data = GameUtilSenior.decode(event.data)
	if data.cmd == "getComposeData" then
		if data.leftData then
			ContainerSynthesis.updateLeftView(data.leftData)
		end
		if data.rightData then
			ContainerSynthesis.updateRightView(data.rightData,data.notice)
			ContainerSynthesis.showHeCheng(data.rightData)
		end
		if data.serverDay then
			if data.serverDay>=7 then--前7天不显示
				var.tablistv:hideTab({3})
			else
				var.tablistv:hideTab({2,3})
			end
			--不需要,暂时隐藏
			var.tablistv:hideTab({2,3})
		end
	end
end

function ContainerSynthesis.initTabView(tab)
	GameSocket:PushLuaTable("gui.ContainerSynthesis.handlePanelData",GameUtilSenior.encode({actionid = "reqTabView",tab = var.tabIndex,page = var.pageIndex}))
end

function ContainerSynthesis.clickbtnhecheng( sender )
	GameSocket:PushLuaTable("gui.ContainerSynthesis.handlePanelData",GameUtilSenior.encode({actionid = "startCom",id = sender.id,tab = var.tabIndex,page = var.pageIndex}))
end

function ContainerSynthesis.updateRightView(data,notice)
	--local listhecheng = var.xmlPanel:getWidgetByName("listhecheng"):setSliderVisible(false)
	--listhecheng:reloadData(#data, function ( subItem )
	--	local d = data[subItem.tag]
	--	local btn_hecheng = subItem:getWidgetByName("btn_hecheng")
	--	btn_hecheng.id = d.id
	--	btn_hecheng:addClickEventListener(ContainerSynthesis.clickbtnhecheng)
	--	local lbl_beishu = subItem:getChildByName("lbl_beishu")
	--	if not lbl_beishu then
	--		lbl_beishu = display.newBMFontLabel({font = "image/typeface/hecheng.fnt",})
	--		:setName("lbl_beishu")
	--		:align(display.CENTER, 220, 65)
	--		:addTo(subItem)
	--	end
	--	lbl_beishu:setString(d.needNum)
	--	local x = string.find(d.info,"X")
	--	subItem:getWidgetByName("model_lbl1"):setString(string.sub(d.info,1,x-1))
	--	subItem:getWidgetByName("model_lbl2"):setString(d.num):setColor(d.num>=d.needNum and GameBaseLogic.getColor(0x00ff00) or GameBaseLogic.getColor(0xff0000))
	--	local itemDef = GameSocket:getItemDefByID(d.typeId)
	--	if itemDef then
	--		subItem:getWidgetByName("model_lbl3"):setString(itemDef.mName)
	--	end
	--	subItem:getWidgetByName("model_icon1"):loadTexture("image/icon/12110091.png")
	--	
	--	-- GUIItem.getItem({
	--	-- 	parent = subItem:getWidgetByName("model_icon1"),
	--	-- 	typeId = 12110091,
	--	-- 	num = 1,
	--	-- })
	--	GUIItem.getItem({
	--		parent = subItem:getWidgetByName("model_icon2"),
	--		typeId = d.typeId,
	--		num = 1,
	--		compare = true
	--	})
	--	local tipsdata = {
	--		name = string.sub(d.info,1,x-1),
	--		level = equipTypeDesp[var.equipType].level,
	--		desp = equipTypeDesp[var.equipType].desp,
	--		icon = "image/icon/12110091.png",
	--	}
	--	if string.find(tipsdata.desp,"%%") then
	--		local pos1 = string.find(d.info,"转")
	--		local pos2 = string.find(d.info,"级")
	--		local equipstr
	--		if pos1 then
	--			equipstr = string.sub(d.info,1,pos1+2)
	--		elseif pos2 then
	--			equipstr = string.sub(d.info,1,pos2+2)
	--		end
	--		tipsdata.level = equipstr
	--		tipsdata.desp  = string.format(tipsdata.desp,equipstr,itemDef and itemDef.mNeedZsLevel.."转" or equipTypeDesp[var.equipType].tar)	
	--	end
	--	subItem:getWidgetByName("model_icon1"):setTouchEnabled(true):addTouchEventListener(function(sender,eventType)
	--		if eventType == ccui.TouchEventType.began then
	--			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_TIPS, str = "compose", tipsdata = tipsdata})
	--		-- elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled  then
	--		-- 	GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HIDE_TIPS, str = "compose", })
	--		end
	--	end)
	--end,0,false)

	
	for i=1,#data do
		local d = data[i]
		local itemDef = GameSocket:getItemDefByID(d.typeId)
		if itemDef then
			if d.has==1 then
				if ContainerSynthesis.is_chuandai( d.typeId ) then
					var.xmlPanel:getWidgetByName("Image_2"):getChildByName("item"..i):getChildByName("item_tip"):setString("(已穿戴)"):show()
				else
					var.xmlPanel:getWidgetByName("Image_2"):getChildByName("item"..i):getChildByName("item_tip"):setString("(已拥有)"):show()
				end
			else
				var.xmlPanel:getWidgetByName("Image_2"):getChildByName("item"..i):getChildByName("item_tip"):setString(""):hide()
			end
			var.xmlPanel:getWidgetByName("Image_2"):getChildByName("item"..i):getChildByName("item_name"):setString(itemDef.mName):setColor(GameBaseLogic.getItemColor(itemDef.mEquipLevel))
		end
		GUIItem.getItem({
			parent = var.xmlPanel:getWidgetByName("Image_2"):getChildByName("item"..i):getChildByName("item_icon1"),
			typeId = d.typeId,
			num = 1
		})
		var.xmlPanel:getWidgetByName("Image_2"):getChildByName("item"..i):getChildByName("item_icon1"):setTouchEnabled(true):addTouchEventListener(function(sender,eventType)
			
		end)
		var.xmlPanel:getWidgetByName("Image_2"):getChildByName("item"..i):getChildByName("item_icon1"):addClickEventListener(function(sender,eventType)
			var.click_index = i
			ContainerSynthesis.showHeCheng(data)
		end)
	end

	var.xmlPanel:getWidgetByName("img_mask"):setVisible(notice and true or false):setOpacity(200):setTouchEnabled(true)
	var.xmlPanel:getWidgetByName("lbl_5z"):setString(notice or "")
end



function ContainerSynthesis.is_chuandai( id )
	for j=1,#equip_info do
		if GameSocket.mItems[equip_info[j].pos] and GameSocket.mItems[equip_info[j].pos].mTypeID==id then
			return true
		end
	end
	return false
end

function ContainerSynthesis.showHeCheng(data)
	d=data[var.click_index]
	if not d then return end
	local hechengpanel = var.xmlPanel:getWidgetByName("Image_25")

	GUIItem.getItem({
			parent = hechengpanel:getChildByName("item_now"):getChildByName("item_icon1"),
			typeId = 12110091
		})
	hechengpanel:getChildByName("item_now"):getChildByName("item_num_tip"):setString(d.num.."/"..d.needNum)

	

	local x = string.find(d.info,"X")
	local tipsdata = {
		name = string.sub(d.info,1,x-1),
		level = equipTypeDesp[var.equipType].level,
		desp = equipTypeDesp[var.equipType].desp,
		icon = "image/icon/12110091.png",
	}
	local itemDef1 = GameSocket:getItemDefByID(12110091)
	if itemDef1 then
		hechengpanel:getChildByName("item_now"):getChildByName("item_name"):setString(string.sub(d.info,1,x-1)):setColor(GameBaseLogic.getItemColor(itemDef1.mEquipLevel))
	end
	
	if string.find(tipsdata.desp,"%%") then
		local pos1 = string.find(d.info,"转")
		local pos2 = string.find(d.info,"级")
		local equipstr
		if pos1 then
			equipstr = string.sub(d.info,1,pos1+2)
		elseif pos2 then
			equipstr = string.sub(d.info,1,pos2+2)
		end
		tipsdata.level = equipstr
		tipsdata.desp  = string.format(tipsdata.desp,equipstr,itemDef and itemDef.mNeedZsLevel.."转" or equipTypeDesp[var.equipType].tar)	
	end
	hechengpanel:getChildByName("item_now"):getChildByName("item_icon1"):setTouchEnabled(true):addTouchEventListener(function(sender,eventType)
		if eventType == ccui.TouchEventType.began then
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_TIPS, str = "compose", tipsdata = tipsdata})
		end
	end)


	hechengpanel:getChildByName("item_next"):getChildByName("Image_46"):setScale(0.82)
	GUIItem.getItem({
			parent = hechengpanel:getChildByName("item_next"):getChildByName("item_icon1"),
			typeId = d.typeId
		})
	local itemDef = GameSocket:getItemDefByID(d.typeId)
	if itemDef then
		hechengpanel:getChildByName("item_next"):getChildByName("item_name"):setString(itemDef.mName):setColor(GameBaseLogic.getItemColor(itemDef.mEquipLevel))
	end

	local btn_hecheng = hechengpanel:getChildByName("Button_hecheng")
	btn_hecheng.id = d.id
	btn_hecheng:addClickEventListener(ContainerSynthesis.clickbtnhecheng)
	hechengpanel:show()
end

function ContainerSynthesis.updateLeftView(data)

	local tabhecheng = var.xmlPanel:getWidgetByName("tabhecheng"):setSliderVisible(false)
	tabhecheng.selItem = nil
	local function clickSubitem(sender)
		var.click_index = 0
		if tabhecheng.selItem then
			tabhecheng.selItem:getWidgetByName("model_sel"):hide()
		end
		tabhecheng.selItem = sender
		var.pageIndex = sender.tag
		var.equipType = data[sender.tag].equipType
		sender:getWidgetByName("model_sel"):show()
		GameSocket:PushLuaTable("gui.ContainerSynthesis.handlePanelData",GameUtilSenior.encode({actionid = "reqPageData",tab = var.tabIndex,page = var.pageIndex}))
		var.xmlPanel:getWidgetByName("Image_25"):hide()
	end
	tabhecheng:reloadData(#data, function ( subItem )
		local d = data[subItem.tag]
		subItem:getWidgetByName("model_lvstr"):setString(d.str)

		local model_icon = subItem:getWidgetByName("model_icon"):setTouchEnabled(false)
		-- model_icon:loadTextureNormal("image/icon/"..data[subItem.tag][2][1].typeId..".png")
		--model_icon:loadTextureNormal("image/icon/"..d.typeId..".png")
		
		local path = "image/icon/"..d.typeId..".png"
		asyncload_callback(path, model_icon, function(path, texture)
			model_icon:loadTexture(path)
		end)
		
		subItem:getWidgetByName("model_sel"):hide()
		subItem:setTouchEnabled(true)
		subItem:addClickEventListener(clickSubitem)
		if subItem.tag == var.pageIndex then
			clickSubitem(subItem)
		end
	end,0,false)
end

function ContainerSynthesis.onPanelClose()
	
end

return ContainerSynthesis
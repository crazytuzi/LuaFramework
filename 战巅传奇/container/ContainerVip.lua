local ContainerVip = {}
local var = {}
function ContainerVip.initView(extend)
	var = {
		xmlPanel,
		loadingbar,
		tabList,
		list_vipinfo,
		list_award,
		curSelect,
		curSelectIdx = 0,
		isGot,
		myVipLv = 0,
		vipData = {},
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerVip.uif")
	if var.xmlPanel then
		--GameUtilSenior.asyncload(var.xmlPanel, "img_inner_bg", "ui/image/vip_bg.jpg")
		var.loadingbar = var.xmlPanel:getWidgetByName("loadingbar");
		var.loadingbar:getLabel():setPositionY(0):enableOutline(GameBaseLogic.getColor("000000"),1):setTextColor(GameBaseLogic.getColor(0xfff4e1)):setFontSize(15)
		var.tabList = var.xmlPanel:getWidgetByName("tabList");
		var.list_vipinfo = var.xmlPanel:getWidgetByName("list_vipinfo");
		var.list_award = var.xmlPanel:getWidgetByName("list_award");

		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerVip.handlePanelData)
			GUIAnalysis.attachEffect(var.xmlPanel:getWidgetByName("btn_charge"),"outline(7c2b03,1)")
		    var.xmlPanel:getWidgetByName("btn_charge"):addClickEventListener(function(sender)
			GameSocket:PushLuaTable("server.showChongzhi", "")
		end)
		    --GUIAnalysis.attachEffect(var.xmlPanel:getWidgetByName("btn_get"),"outline(076900,1)")
		var.xmlPanel:getWidgetByName("btn_get"):addClickEventListener(function(sender)
			if var.isGot == 1 then
				GameSocket:alertLocalMsg("您已领取过该奖励！", "alert")
			elseif var.loadingbar:getPercent()==0 then
				GameSocket:alertLocalMsg("您的充值额度不足！", "alert")
			else
				GameSocket:PushLuaTable("gui.ContainerVip.onPanelData", GameUtilSenior.encode({actionid = "getAward",vip = var.curSelectIdx}))
			end
		end)
		--GUIAnalysis.attachEffect(var.xmlPanel:getWidgetByName("btn_buff"),"outline(076900,1)")
		var.xmlPanel:getWidgetByName("btn_buff"):addClickEventListener(function(sender)
			GameSocket:PushLuaTable("gui.ContainerVip.onPanelData", GameUtilSenior.encode({actionid = "getBuff"}))
		end)
		
		ContainerVip.updateGameMoney()
		var.xmlPanel:getWidgetByName("box_tab"):setSelectedTab(3)
		var.xmlPanel:getWidgetByName("box_tab"):addTabEventListener(ContainerVip.pushTabButtons)
		
		return var.xmlPanel
	end
end


function ContainerVip.pushTabButtons(sender)
	local opened, level, funcName
	opened = true
	local tag = sender:getTag()
	if tag == 1 then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="extend_store"})
	end
	if tag == 3 then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="panel_vip"})
	end
end


--金币刷新函数
function ContainerVip.updateGameMoney()
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

function ContainerVip.onPanelOpen()
	var.xmlPanel:getWidgetByName("btn_buff"):hide()
	GameSocket:PushLuaTable("gui.ContainerVip.onPanelData", GameUtilSenior.encode({actionid = "fresh",}))
end

function ContainerVip.handlePanelData(event)
	if event.type ~= "ContainerVip" then return end
	local result = GameUtilSenior.decode(event.data)
	if result.cmd == "fresh" then
		ContainerVip.freshPanel( result )
	elseif result.cmd == "vipinfo" then
		ContainerVip.freshVipInfo(result)
	end
end

function ContainerVip.updateItem(subItem,d)
	local btnMode = subItem:getWidgetByName("btnMode")
	btnMode.vip = d.lv
	GUIAnalysis.attachEffect(btnMode,"outline(0e0600,1)")
	btnMode:addClickEventListener(ContainerVip.clickTab)
	btnMode:setTouchEnabled(true):setTouchSwallowEnabled(false)--:setTitleText(d.name)
	local res = "menu_"..d.lv..".png"
	if d.lv == var.curSelectIdx then
		res = "menu_sel_"..d.lv..".png"
		if var.curSelect ~= btnMode then
			ContainerVip.clickTab(btnMode)
		end
		var.curSelect = btnMode
	end
	btnMode:loadTextures(res,res,res,ccui.TextureResType.plistType)
	GUIFocusDot.addRedPointToTarget(btnMode)
	btnMode:getWidgetByName("redPoint"):setVisible(d.redPoint)

end

function ContainerVip.freshPanel( result )
	local vipLv = result.vipLv
	var.myVipLv = vipLv
	--[[
	if not var.lbl_level then
		var.lbl_level = display.newBMFontLabel({font = "image/typeface/num_23.fnt",fontSize = 22})
		:addTo(var.xmlPanel)
		:align(display.CENTER, 160, 480)
		:setName("lbl_level")
		--:setColor(GameBaseLogic.getColor(0x000000))
		--var.lbl_level:setFontSizeObj(22)
	end
	var.lbl_level:setString(vipLv)
	]]--
	print(vipLv)
	var.xmlPanel:getWidgetByName("img_vipdj_info"):loadTexture("current_v"..vipLv..".png",ccui.TextureResType.plistType)
	var.vipData = result.vipData
	var.curSelectIdx = vipLv+1
	var.curSelectIdx = GameUtilSenior.bound(1, var.curSelectIdx, #var.vipData)

	vipLv = GameUtilSenior.bound(0, vipLv, #var.vipData)
	local subItemModel = var.xmlPanel:getWidgetByName("render")
	var.tabList:removeAllItems()
	for i=1,#var.vipData do
		local subItem = subItemModel:clone():show()
 		ContainerVip.updateItem(subItem,var.vipData[i])
		var.tabList:pushBackCustomItem(subItem)
	end
	var.tabList:jumpToPercentVertical(100*vipLv/#var.vipData)

end

function ContainerVip.clickTab(sender)
	if GameUtilSenior.isObjectExist(var.curSelect) then
		local res = "menu_"..var.curSelect.vip..".png"
		var.curSelect:loadTextures(res,res,res,ccui.TextureResType.plistType)
	end
	res = "menu_sel_"..sender.vip..".png"
	sender:loadTextures(res,res,res,ccui.TextureResType.plistType)
	var.curSelect = sender
	var.curSelectIdx = sender.vip
	var.xmlPanel:getWidgetByName("lblviplibao"):setString(string.format("VIP%d尊享礼包",sender.vip))
	GameSocket:PushLuaTable("gui.ContainerVip.onPanelData", GameUtilSenior.encode({actionid = "vipinfo",vip = sender.vip}))
end

function ContainerVip.freshVipInfo(result)
	local btn_buff = var.xmlPanel:getWidgetByName("btn_buff")
	btn_buff:setVisible(result.showBuff)
	if result.showBuff and not btn_buff:getWidgetByName("img_bln") then
		GameUtilSenior.addHaloToButton(btn_buff, "btn_normal_light3")
	end

	var.isGot = result.isGot

	local data= result.vipInfoData
	var.list_vipinfo:reloadData(#data, function(subItem)
		local richLabel = subItem:getWidgetByName("richLabel")
		if not richLabel then
			richLabel = GUIRichLabel.new({size = cc.size(subItem:getContentSize().width, 18), fontSize = 18, space=0,name = "richLabel"})
			richLabel:addTo(subItem):setPosition(cc.p(0,0))
		end
		richLabel:setRichLabel("<font color=#FDDFAE>"..data[subItem.tag].."</font>")

		local lblvipinfo = subItem:getWidgetByName("lblvipinfo")
		lblvipinfo:setString("")
	end, 0, false)
	var.loadingbar:setPercent(result.vipExp,result.vipMax)

	local award = result.vipAward
	var.list_award:reloadData(#award, function(subItem)
		subItem:getWidgetByName("awardicon"):removeChildByName("item_icon")
		GUIItem.getItem({
			parent = subItem:getWidgetByName("awardicon"),
			typeId = award[subItem.tag].id,
			num = award[subItem.tag].num,
		})
	end, 0, false)
	local btn_get = var.xmlPanel:getWidgetByName("btn_get")
	if var.isGot==0 then
		btn_get:setVisible(#award>0)--:setTitleText("领取奖励"):loadTextures("common_big_recharge_big.png","common_big_recharge_big.png","common_big_recharge_big.png", ccui.TextureResType.plistType)
	else
		--btn_get:loadTextures("img_yilingqu1", "img_yilingqu1","",ccui.TextureResType.plistType):setTitleText("")
		btn_get:setVisible(false)
	end
	var.xmlPanel:getWidgetByName("lblviplibao"):setVisible(#award>0)

	for k,v in pairs(result.redPoints) do
		if var.vipData[k] then
			var.vipData[k].redPoint = v
			ContainerVip.updateItem(var.tabList:getItem(k-1),var.vipData[k])
		end
	end
	if result.btnGetShow then
		GameUtilSenior.addHaloToButton(btn_get, "btn_normal_light3",false,154,41)
	elseif btn_get:getWidgetByName("img_bln") then
		btn_get:removeChildByName("img_bln")
	end
end

function ContainerVip.onPanelClose()

end

return ContainerVip
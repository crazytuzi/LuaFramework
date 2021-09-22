local ContainerStove = class("ContainerStove")

local var ={}
local color = {GameBaseLogic.getColor(0xEF2F00),GameBaseLogic.getColor(0x30ff00)}
local equipPos = {
	GameConst.ITEM_JADE_PENDANT_POSITION,
	GameConst.ITEM_SHIELD_POSITION,
	GameConst.ITEM_DRAGON_HEART_POSITION,
	GameConst.ITEM_WOLFANG_POSITION,
	0,
	--新增
	GameConst.ITEM_FASHION_WING_SHOUSHI2,
	GameConst.ITEM_BAODING_POSITION,
	GameConst.ITEM_FASHION_WING_POSITION,
	GameConst.ITEM_FASHION_WEAPON_POSITION,
	
}
local label = {"玉佩","护盾","龙心","狼牙","","左手","秒杀","剑饰","护甲"};

local lblhint = {
	[1] = {
		"<font color=#E7BA52 size=18>玉佩说明</font>",
		'1.	玉佩可以极大增加生命上限。',
		'2.	玉佩碎片可以通过参加活动、击杀BOSS、回收装备等方式获得。',
		'3.	玉佩不能被强化和注灵。',
	},
	[2] = { 
		"<font color=#E7BA52 size=18>护盾说明</font>",
		'1.	护盾可以极大增加防御力。',
		'2.	护盾碎片可以通过任务活动、击杀BOSS、等方式获得。',
		'3.	护盾不能被强化和注灵。'
	},
	[3] = {  
		"<font color=#E7BA52 size=18>龙心说明</font>",
		'1.	龙心可以极大增加攻击能力。',
		'2.	龙心碎片可以通过参加活动、击杀BOSS、商城购买等方式获得。',
		'3.	龙心不能被强化和注灵。'
	},
	[4] = { 
		"<font color=#E7BA52 size=18>狼牙说明</font>",
		'1.	狼牙可以极大增加暴击率和暴击力。',
		'2.	狼牙碎片可以通过参加活动，探宝积分兑换等方式获得。',
		'3.	狼牙不能被强化和注灵。'
	},
}

function ContainerStove.initView(event)
	var = {
		xmlPanel,
		tp = 1,
		panelData,
		progressBar,
		labBar,
		tabv,
		curId = 0,
		nextId = 0,
		shopshow = false,
		tabName = {
			"btnYupei","btnHudun","btnLongxin","btnLangya"
		},
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerStove.uif")
	if var.xmlPanel then

		var.xmlPanel:getWidgetByName("btn_upgrade"):setTitleText("");
		var.xmlPanel:getWidgetByName("Image_3"):setScale(0.88)
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerStove.handlePanelData)
			:addEventListener(GameMessageCode.EVENT_NOTIFY_GETITEMDESP, ContainerStove.getItemDesp)

		var.tabv = var.xmlPanel:getWidgetByName("tabList")
		var.tabv:getParent():setLocalZOrder(10)
		var.tabv:addTabEventListener(ContainerStove.pushBtns)
		var.tabv:hide()
		var.xmlPanel:getWidgetByName("shopcontainer"):setPosition(cc.p(3,0)):hide()
		var.xmlPanel:getWidgetByName("LayerShop"):setPosition(cc.p(168,-550+38))
		ContainerStove.initPageFurnace()

		GameUtilSenior.asyncload(var.xmlPanel, "shop_bg", "ui/image/img_furnace_buy_bg.png")
		
		ContainerStove:updateGameMoney(var.xmlPanel)
		
		return var.xmlPanel
	end
end


--金币刷新函数
function ContainerStove:updateGameMoney(panel)
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

function ContainerStove.onPanelOpen(event)
	print("event.tab",event.tab)
	if event.tab and equipPos[event.tab] then
		var.tp = event.tab
	end
	var.tabv:setSelectedTab(var.tp);
end

function ContainerStove.initPageFurnace()
	local btns = {
		{name = "btn_upgrade" ,	func=ContainerStove.pushBtns,	visible = true},
		{name = "Button_jihuo" ,func=ContainerStove.pushBtns,	visible = false},
		{name = "btn_hint" ,	func=ContainerStove.pushBtns, touchType = "touch",visible = true},
		{name = "btn_buy" ,		func=ContainerStove.pushBtns,	visible = false},
		{name = "btn_charge" ,	func=ContainerStove.pushBtns, visible = true},
	}
	for k,v in pairs(btns) do
		local btn = var.xmlPanel:getWidgetByName(v.name)
		if btn then
			if v.touchType then
				btn:addTouchEventListener(v.func)
			else
				btn:addClickEventListener(v.func)
			end
			btn:setVisible(v.visible)
			if v.color then
				btn:setTitleColor(GameBaseLogic.getColor(v.color))
			end
		end
	end
end

function ContainerStove.pushBtns(sender,eventType)
	local name = sender:getName()
	if string.find(name,"tab") then
		var.tp = tonumber(string.sub(name,-1))
		var.xmlPanel:getWidgetByName("shopcontainer"):setVisible(var.tp>2)
		var.xmlPanel:getWidgetByName("LayerShop"):setPositionY(-550+38)
		var.shopshow = false
		GameSocket:PushLuaTable("gui.ContainerStove.onPanelData", GameUtilSenior.encode({actionid = "fresh",tab = var.tp}))
		-- var.xmlPanel:getWidgetByName("ListView"):setVisible(var.tp<=2 or not var.shopshow)
	elseif name=="btn_upgrade" or name == "Button_jihuo" then
		GameSocket:PushLuaTable("gui.ContainerStove.onPanelData", GameUtilSenior.encode({actionid = "upgrade",param={var.tp}}))
	elseif name=="btn_hint" then
		if eventType == ccui.TouchEventType.began then
			GameSocket:dispatchEvent({
				name = GameMessageCode.EVENT_PANEL_ON_ALERT, panel = "tips", visible = true, infoTable = lblhint[var.tp],
			})
		elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled  then
			GameSocket:dispatchEvent({
				name = GameMessageCode.EVENT_PANEL_ON_ALERT, panel = "all", visible = false })
		end
	elseif name=="btn_buy" then
		sender:setTouchEnabled(false)
		local LayerShop = var.xmlPanel:getWidgetByName("LayerShop")
		LayerShop:stopAllActions()
		LayerShop:runAction(cca.seq({
			cca.moveTo(0.3, LayerShop:getPositionX(), var.shopshow and 38-550 or 0),
			cca.callFunc(function(target)
				sender:setTouchEnabled(true)
				-- var.xmlPanel:getWidgetByName("ListView"):setVisible(var.shopshow)
				var.shopshow = not var.shopshow;
		    end)
			}
		))
	elseif name=="btn_charge" then
		GameSocket:PushLuaTable("server.showChongzhi", GameUtilSenior.encode({}))		
	end
end

function ContainerStove.handlePanelData(event)
	if event.type == "ContainerStove" then
		var.panelData = GameUtilSenior.decode(event.data)
		if var.panelData.cmd =="fresh" then
			print(var)
			var.tabv:show()
			var.tabv:hideTab(var.panelData.openFunc)
			ContainerStove.freshLabelAndIcon()
		end
	end
end

function ContainerStove.freshLabelAndIcon()
	if equipPos[var.tp] and var.panelData then
		local data = var.panelData
		var.curId = data.curId
		var.nextId = data.nextId
		-- print("nextIDs---------",GameUtilSenior.encode(var.curId))
		-- print("typeIDs---------",GameUtilSenior.encode(var.nextId))
		local needNum = data.needNum
		local vcoin = data.vcoin
		local gamemoney = data.gamemoney
		local stonePool = data.stonePool
		local longxinShop = data.longxinShop
		local langyaShop = data.langyaShop
		local ids = data.ids
		local col = nil

		ContainerStove.freshTableView(ids,var.curId)
		if var.tp ==4 then
			ContainerStove.freshShopLayer(langyaShop)
		elseif var.tp == 3 then
			ContainerStove.freshShopLayer(longxinShop)
		end
		if var.curId == 0 then
			var.xmlPanel:getWidgetByName("nextSprit"):hide()
			var.xmlPanel:getWidgetByName("Image_3"):hide()
			var.xmlPanel:getWidgetByName("btn_upgrade"):hide()
			var.xmlPanel:getWidgetByName("Button_jihuo"):show()
			var.xmlPanel:getWidgetByName("curAttr"):hide()
			var.xmlPanel:getWidgetByName("nextAttr"):hide()
		else
			var.xmlPanel:getWidgetByName("nextSprit"):show()
			var.xmlPanel:getWidgetByName("Image_3"):show()
			var.xmlPanel:getWidgetByName("btn_upgrade"):show()
			var.xmlPanel:getWidgetByName("Button_jihuo"):hide()
			var.xmlPanel:getWidgetByName("curAttr"):show()
			var.xmlPanel:getWidgetByName("nextAttr"):show()
			ContainerStove.resetSprit(var.nextId>10000 and var.nextId or var.curId,data.up)
		end
		data.up = false
		
		var.xmlPanel:getWidgetByName("lblcoin"):setString(GameSocket.mCharacter.mVCoin or 0)
		var.xmlPanel:getWidgetByName("lblbindcoin"):setString(GameSocket.mCharacter.mVCoinBind or 0)

		local btnUpgrade = var.xmlPanel:getWidgetByName("btn_upgrade")
		if needNum and stonePool and stonePool>=needNum  then
			col = color[2] -- 碎片足量
			btnUpgrade.enough = true
		else
			col = color[1]
			btnUpgrade.enough = false
		end

		local proStr = var.xmlPanel:getWidgetByName("tab"..var.tp):getWidgetByName("lblTitle"):getString();
		proStr = ""
		var.xmlPanel:getWidgetByName("lblusepiece"):setString("消耗"..proStr.."元宝:")
		var.xmlPanel:getWidgetByName("lblhaspiece"):setString("消耗"..proStr.."游龙币:")
		var.xmlPanel:getWidgetByName("text_yulan"):setString(label[var.tp].."预览")
		--var.xmlPanel:getWidgetByName("img_fu_yulan"):loadTexture("img_view_"..var.tp,ccui.TextureResType.plistType)

		var.xmlPanel:getWidgetByName("usepiece"):setString(vcoin)
		var.xmlPanel:getWidgetByName("haspiece"):setString(gamemoney)
		--var.xmlPanel:getWidgetByName("usepiece"):setColor(col)
		--var.xmlPanel:getWidgetByName("haspiece"):setColor(col)
		var.xmlPanel:getWidgetByName("img_arrow"):setVisible(var.nextId>0 and var.curId ~= 0)

		if var.curId==0 then
			btnUpgrade:setTitleText("领取")
		else
			if var.nextId>0 then
				btnUpgrade:setTitleText("升级")
			else
				btnUpgrade:setTitleText("已满级")
			end
		end
		if data.breath then
			GameUtilSenior.addHaloToButton(btnUpgrade, "btn_normal_light3")
		elseif btnUpgrade:getWidgetByName("img_bln") then
			btnUpgrade:removeChildByName("img_bln")
		end
		ContainerStove.updateCurrentAttr()
		ContainerStove.updateNextAttr()
	end
end

function ContainerStove.updateCurrentAttr()
	local lblpool = {}
	local nItem = GameSocket:getNetItem(equipPos[var.tp])

	if nItem then
		local itemdef = GameSocket:getItemDefByID(nItem.mTypeID)
		if itemdef then
			if var.tp ==1 then
				table.insert(lblpool,{"生命：",itemdef.mMaxHp})
			elseif var.tp ==2 then
				table.insert(lblpool,{"物防：",itemdef.mAC.."-"..itemdef.mACMax})
				table.insert(lblpool,{"魔防：",itemdef.mMAC.."-"..itemdef.mMACMax})
			elseif var.tp ==3 then
				table.insert(lblpool,{"物攻：",itemdef.mDC.."-"..itemdef.mDCMax})
				table.insert(lblpool,{"魔攻：",itemdef.mMC.."-"..itemdef.mMCMax})
				table.insert(lblpool,{"道攻：",itemdef.mSC.."-"..itemdef.mSCMax})
			elseif var.tp ==4 then
				table.insert(lblpool,{"暴击力：",itemdef.mBaojiPres})
				table.insert(lblpool,{"暴击率：",string.format("%.02f%%",itemdef.mBaojiProb/100)})
			end
			for i=1,3 do
				if i<= #lblpool then
					var.xmlPanel:getWidgetByName("lblcurattr"..i):setString(lblpool[i][1])
					var.xmlPanel:getWidgetByName("curattr"..i):setString(lblpool[i][2])
				end
				var.xmlPanel:getWidgetByName("lblcurattr"..i):setVisible(i<= #lblpool):setPositionX(var.tp ~=3 and 80 or 60)
				var.xmlPanel:getWidgetByName("curattr"..i):setVisible(i<= #lblpool):setPositionX(var.tp ~=3 and 80 or 60)
			end
		end
	else
		for i=1,3 do
			var.xmlPanel:getWidgetByName("lblcurattr"..i):setString("")
			var.xmlPanel:getWidgetByName("curattr"..i):setString("")
		end
	end
end

function ContainerStove.updateNextAttr()
	local lblpool = {};
	if var.nextId>0 then
		local itemdef = GameSocket:getItemDefByID(var.nextId)
		if itemdef then
			if var.tp ==1 then
				table.insert(lblpool,{"生命：",itemdef.mMaxHp})
			elseif var.tp ==2 then
				table.insert(lblpool,{"物防：",itemdef.mAC.."-"..itemdef.mACMax})
				table.insert(lblpool,{"魔防：",itemdef.mMAC.."-"..itemdef.mMACMax})
			elseif var.tp ==3 then
				table.insert(lblpool,{"物攻：",itemdef.mDC.."-"..itemdef.mDCMax})
				table.insert(lblpool,{"魔攻：",itemdef.mMC.."-"..itemdef.mMCMax})
				table.insert(lblpool,{"道攻：",itemdef.mSC.."-"..itemdef.mSCMax})
			elseif var.tp ==4 then
				table.insert(lblpool,{"暴击力：",itemdef.mBaojiPres})
				table.insert(lblpool,{"暴击率：",string.format("%.02f%%",itemdef.mBaojiProb/100)})
			end
			for i=1,3 do
				if i<= #lblpool then
					var.xmlPanel:getWidgetByName("lblnextattr"..i):setString(lblpool[i][1])
					var.xmlPanel:getWidgetByName("nextattr"..i):setString(lblpool[i][2])
				end
				var.xmlPanel:getWidgetByName("lblnextattr"..i):setVisible(i<= #lblpool):setPositionX(var.tp ~=3 and 80 or 60)
				var.xmlPanel:getWidgetByName("nextattr"..i):setVisible(i<= #lblpool):setPositionX(var.tp ~=3 and 80 or 60)
			end
		end
	else
		for i=1,3 do
			var.xmlPanel:getWidgetByName("lblnextattr"..i):setString("")
			var.xmlPanel:getWidgetByName("nextattr"..i):setString("")
		end
	end
end

function ContainerStove.getItemDesp(event)
	if not var.panelData then return end
	if event and event.type_id then
		if event.type_id == var.curId then
			ContainerStove.updateCurrentAttr()
		elseif event.type_id == var.nextId then
			ContainerStove.updateNextAttr()
		end
	end
end

function ContainerStove.freshTableView(data,curid)
	local tableview = var.xmlPanel:getWidgetByName("ListView"):setSliderVisible(false)
	tableview:reloadData(#data, function(subItem)
		local t = data[subItem.tag];
		GUIItem.getItem({
			parent=subItem:getWidgetByName("modelimg"),
			typeId=t.id
		})

		
		local def = GameSocket:getItemDefByID(t.id)
		if def and def.mEquipLevel then
			local modelname = subItem:getWidgetByName("modelname")
			modelname:setColor(GameBaseLogic.getItemColor(def.mEquipLevel)):setString(def.mName)
		end
		-- modelname:setColor(curid~=t.id and GameBaseLogic.getColor(0x00bbff) or GameBaseLogic.getColor(0xef6b00))
		subItem:getWidgetByName("modelget"):setVisible(curid>=t.id)
	end,nil,false)
end

function ContainerStove.freshShopLayer(data)

	local listshop = var.xmlPanel:getWidgetByName("listshop"):setSliderVisible(false)
	local clickTime = 0
	listshop:reloadData(#data, function(subItem)
		local t = data[subItem.tag];
		GUIItem.getItem({
			parent = subItem:getWidgetByName("modelimg"),
			typeId = t.id,
		})
		local modelname = subItem:getWidgetByName("modelname")
		modelname:setString(t.name)
		subItem:getWidgetByName("modellblcoin"):setString(t.money)
		local modelbtnbuy = subItem:getWidgetByName("modelbtnbuy")
		modelbtnbuy.storeId = t.storeId
		GUIAnalysis.attachEffect(modelbtnbuy,"outline(0e0600,1)")

		subItem:getWidgetByName("modelbtnbuy"):addClickEventListener(function( sender )
			if GameBaseLogic.getTime() - clickTime > 250 then
				GameSocket:PushLuaTable("gui.ContainerStove.onPanelData", GameUtilSenior.encode({actionid = "buy",param={var.tp,sender.storeId}}))
				clickTime = GameBaseLogic.getTime()
			end
		end)

		local resource = {"coin","coin_bind","vcoin","vcoin_bind"}
		local res = resource[t.MoneyKind-99]
		subItem:getWidgetByName("modelcoin"):loadTexture(res,ccui.TextureResType.plistType)
	end,nil,false)
end

--刷新动画对象
function ContainerStove.resetSprit(typeId,up)
	local nextSprit = var.xmlPanel:getWidgetByName("nextSprit")
	if up then
		local fireworks = cc.Sprite:create():addTo(var.xmlPanel):pos(317.7, 365.38)
		local animate = cc.AnimManager:getInstance():getPlistAnimate(4,50024,4,4,false,false,0,function(animate,shouldDownload)
							-- print(animate:getAnimation():setDelayPerUnit(36/40))
							fireworks:runAction(cca.seq({
								cca.rep(animate, 1),
								cca.cb(function ()
									GUIItem.getItem({
										parent = nextSprit,
										typeId = typeId
									})
								end),
								cca.removeSelf()
							}))
							if shouldDownload==true then
								fireworks:release()
							end
						end,
						function(animate)
							fireworks:retain()
						end)
		
		GUIItem.getItem({
			parent = nextSprit,
			typeId = typeId
		})
	else
		GUIItem.getItem({
			parent = nextSprit,
			typeId = typeId
		})
	end
end

function ContainerStove.onPanelClose()
	var.tp = 1
	var.panelData = nil
	for i=1,3 do
		var.xmlPanel:getWidgetByName("lblcurattr"..i):setString("")
		var.xmlPanel:getWidgetByName("curattr"..i):setString("")
		var.xmlPanel:getWidgetByName("lblnextattr"..i):setString("")
		var.xmlPanel:getWidgetByName("nextattr"..i):setString("")
	end
	if var.tabv then var.tabv:hide() end
end

return ContainerStove
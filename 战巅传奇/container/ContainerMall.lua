local ContainerMall = {}
local var = {}
local res = {"coin","coin_bind","vcoin","vcoin_bind"}

function ContainerMall.initView(extend)
	var = {
		xmlPanel,
		defaultTab = 1,
		curTabIndex = 0,
		tabName = {
			"tab_1","tab_2","tab_3","tab_4"
		},
		curItemData = {}
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerMall.uif")
	if var.xmlPanel then
		--var.xmlPanel:getWidgetByName("store_bg"):loadTexture("ui/image/mall_bg.png")
		var.listShop = var.xmlPanel:getChildByName("listShop")
		var.listShop:setLocalZOrder(3)
		--for i,v in ipairs(var.tabName) do
		--	GUIFocusPoint.addUIPoint(var.xmlPanel:getWidgetByName(var.tabName[i]),function ( sender )
		--		ContainerMall.selectTabIndex( i )
		--	end)
		--end
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerMall.handlePanelData)
			:addEventListener(GameMessageCode.EVENT_GAME_MONEY_CHANGE, ContainerMall.updateGameMoney)
		ContainerMall.updateGameMoney()
		--GUIFocusPoint.addUIPoint(var.xmlPanel:getWidgetByName("btn_charge"),function ( sender )
		--	GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "panel_charge"})
		--end)
		
		var.xmlPanel:getWidgetByName("box_tab"):setSelectedTab(1)
		var.xmlPanel:getWidgetByName("box_tab"):addTabEventListener(ContainerMall.pushTabButtons)
		
		return var.xmlPanel
	end
end

function ContainerMall.onPanelOpen(extend)
	ContainerMall.selectTabIndex( var.defaultTab )
	if extend and extend.tab and GameUtilSenior.isNumber(extend.tab) then
		var.xmlPanel:getWidgetByName("box_tab"):setSelectedTab(extend.tab)
	end
end


function ContainerMall.pushTabButtons(sender)
	local opened, level, funcName
	opened = true
	local tag = sender:getTag()
	if tag==5 then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="panel_charge"})
	else
		ContainerMall.selectTabIndex( tag )
	end
end

--金币刷新函数
function ContainerMall:updateGameMoney()
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


function ContainerMall.selectTabIndex( index )
	if var.curTabIndex == index then return end
	var.curTabIndex = index
	--for i,v in ipairs(var.tabName) do
	--	if i == var.curTabIndex then
	--		var.xmlPanel:getWidgetByName(var.tabName[i]):setBrightStyle(1)
	--		var.xmlPanel:getWidgetByName(var.tabName[i]):getChildByName("txtName"):setColor(GameBaseLogic.getColor(0xfddfae))
	--	else
	--		var.xmlPanel:getWidgetByName(var.tabName[i]):getChildByName("txtName"):setColor(GameBaseLogic.getColor(0xc3ad88))
	--		var.xmlPanel:getWidgetByName(var.tabName[i]):setBrightStyle(0)
	--	end
	--end
	GameSocket:PushLuaTable("gui.ContainerMall.onPanelData", GameUtilSenior.encode({actionid = "fresh",tab = var.curTabIndex}))
end
function ContainerMall.handlePanelData(event)
	if event.type ~= "ContainerMall" then return end
	local result = GameUtilSenior.decode(event.data)
	if result.cmd == "fresh" then
		ContainerMall.freshPanel( result )
	end
end
function ContainerMall.freshPanel(result)
	local data = result.storeData
	table.sort(data,function(a,b)
		return a.position < b.position
	end)
	var.curItemData = data
	var.listShop:reloadData(#data, ContainerMall.updateListShop,nil,false)
end
function ContainerMall.updateListShop( subItem )
	local d = var.curItemData[subItem.tag]
	if d then
		subItem:getWidgetByName("lblname"):setString(d.name):enableOutline(cc.c4b(0, 0, 0, 255),1)
		subItem:getWidgetByName("lblcoin"):setString(d.money)
		subItem:getWidgetByName("coin"):loadTexture(res[d.MoneyKind-99],ccui.TextureResType.plistType)
		if d.maxCount>0 then
			subItem:getWidgetByName("zhekou"):show()
			subItem:getWidgetByName("tag"):show()
		else
			subItem:getWidgetByName("zhekou"):hide()
			subItem:getWidgetByName("tag"):hide()
		end
		GUIItem.getItem({
			parent = subItem:getWidgetByName("icon"),
			typeId = d.itemBaseId,
			num = d.itemNum,
			bind = 2-d.bind,
		})
		local btn_buy = subItem:getWidgetByName("btn_buy"):setTitleColor(GameBaseLogic.getColor(0xffe08b))
		btn_buy:getTitleRenderer():enableOutline(GameBaseLogic.getColor4(0x000000), 1)
		btn_buy.data = d
		btn_buy:addClickEventListener(ContainerMall.clickBuy)
	end
end
--金币刷新函数
function ContainerMall.updateGameMoney1(event)
	if var.xmlPanel then
		local mainrole = GameSocket.mCharacter
		local moneyLabel = {
			{name="lblVcoin",	value =	mainrole.mVCoin or 0	,	},
			{name="lblBVcoin",	value =	mainrole.mVCoinBind or 0,	},
			{name="lblMoney",	value =	mainrole.mGameMoney or 0,	},
			{name="lblBMoney",	value =	mainrole.mGameMoneyBind or 0,},
		}
		--建临时表遍历设属性
		--for _,v in ipairs(moneyLabel) do
		--	var.xmlPanel:getWidgetByName(v.name):setString(v.value)
		--end
	end
end



local MoneyKind = {
	[100] = {name = "元宝",		value = "mGameMoney" },
	[101] = {name = "绑定元宝",	value = "mGameMoneyBind" },
	[102] = {name = "钻石",		value = "mVCoin" },
	[103] = {name = "绑定钻石",	value = "mVCoinBind" },
}
function ContainerMall.clickBuy(sender)
	local data = sender.data
	if data.MoneyKind ~=101 and data.MoneyKind ~=103 and GameSocket.mCharacter[MoneyKind[data.MoneyKind].value]  < data.money or 
		data.MoneyKind ==101 and GameSocket.mCharacter["mGameMoney"] + GameSocket.mCharacter["mGameMoneyBind"]< data.money or 
		data.MoneyKind ==103 and GameSocket.mCharacter["mVCoin"] + GameSocket.mCharacter["mVCoinBind"]< data.money
	 then
		if data.MoneyKind == 102 then
			GameSocket:PushLuaTable("server.showChongzhi","check")
		else
			GameSocket:alertLocalMsg(MoneyKind[data.MoneyKind].name.."不足", "alert")
		end
	else
		local param = {
			name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm",
			lblConfirm = string.format("你确定要花费%d%s购买%s？",data.money,MoneyKind[data.MoneyKind].name,data.name), 
			btnConfirm = "确定", btnCancel = "取消",
			confirmCallBack = function ()
				GameSocket:PushLuaTable("gui.ContainerMall.onPanelData", GameUtilSenior.encode({actionid = "buy",id = data.id,tab = var.curTabIndex}))
			end,
			checkBox = "storeNotShowAgain"
		}
		GameSocket:dispatchEvent(param)
	end
end

function ContainerMall.onPanelClose()
	-- if GameUtilSenior.isObjectExist(var.tabList) then
	-- 	var.tabList:setSelectedTab(var.defaultTab)
	-- end
end

return ContainerMall
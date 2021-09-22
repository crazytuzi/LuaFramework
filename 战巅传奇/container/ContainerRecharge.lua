local ContainerRecharge = {}
local var ={}
local Data = {
	-- ["ios"] = {
	-- 	{ id="100006",  num = 6, 		vcoin = 600,		res="icon_01",			},
	-- 	{ id="100030",  num = 30, 	vcoin = 3000,	res="icon_02",			},
	-- 	{ id="100050",  num = 50, 	vcoin = 5000,	res="icon_03",			},
	-- 	{ id="100098",  num = 98, 	vcoin = 9800,	res="icon_04",			},
	-- 	{ id="100198",  num = 198, 	vcoin = 19800,	res="icon_05",	},
	-- 	{ id="100328",  num = 328, 	vcoin = 32800,	res="icon_06",	},
	-- 	{ id="100648",  num = 648, 	vcoin = 64800,	res="icon_07",		},
	-- 	{ id="101998",  num = 1998, 	vcoin = 199800,	res="icon_08",		},
	-- },
	-- ["android"] = {
	-- 	{ id="100006",  num = 6, 		vcoin = 600,		res="icon_01",			},
	-- 	{ id="100030",  num = 30, 	vcoin = 3000,	res="icon_02",			},
	-- 	{ id="100050",  num = 50, 	vcoin = 5000,	res="icon_03",			},
	-- 	{ id="100098",  num = 98, 	vcoin = 9800,	res="icon_04",			},
	-- 	{ id="100198",  num = 198, 	vcoin = 19800,	res="icon_05",	},
	-- 	{ id="100328",  num = 328, 	vcoin = 32800,	res="icon_06",	},
	-- 	{ id="100648",  num = 648, 	vcoin = 64800,	res="icon_07",		},
	-- 	{ id="102000",  num = 2000, 	vcoin = 200000,	res="icon_08",		},
	-- 	{ id="105000",  num = 5000, 	vcoin = 500000,	res="icon_09",		},
	-- }
}

function ContainerRecharge.initView(extend)
	var = {
		xmlPanel,
		defaultTab = 1,
		chargeList,
		vipLevel,
		limit6Charge= false,
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerRecharge.uif")
	if var.xmlPanel then
		GameUtilSenior.asyncload(var.xmlPanel, "panel_bg", "ui/image/img_panel_bg_cz.png")

		var.chargeList = var.xmlPanel:getWidgetByName("chargeList");
		--var.vipLevel = var.xmlPanel:getWidgetByName("rmb")
		--var.xmlPanel:getWidgetByName("img_vcoin_all"):setScale(0.8)
		--var.xmlPanel:getWidgetByName("img_kuang"):setScale(0.8)
		ContainerRecharge:updateGameMoney()
		--var.xmlPanel:getWidgetByName("panel_bg"):setLocalZOrder(12)
		--var.xmlPanel:getWidgetByName("panel_close"):setLocalZOrder(14):setScale(0.8)
		
		-- var.xmlPanel:getWidgetByName("btn_check"):addClickEventListener(function(sender)
		-- 	GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str = "panel_vip", from = "panel_charge"})
		-- end)
		-- if not var.vipLevel then
		-- 	var.vipLevel = display.newBMFontLabel({font = "image/typeface/num_41.fnt",})
		-- 	:addTo(var.xmlPanel)
		-- 	:align(display.CENTER, 290, 528)
		-- 	:setName("vipLevel")
		-- 	:setString(0)
		-- end
		-- var.xmlPanel:getWidgetByName("loadingbar"):setTextColor(GameBaseLogic.getColor(0xffecdf)):enableOutline(GameBaseLogic.getColor("000000"),1):setFontSize(16)
		

		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerRecharge.handlePanelData)
			:addEventListener(GameMessageCode.EVENT_GAME_MONEY_CHANGE, ContainerRecharge.updateGameMoney)
			
		ContainerRecharge.updateGameMoney()
		var.xmlPanel:getWidgetByName("box_tab"):setSelectedTab(2)
		var.xmlPanel:getWidgetByName("box_tab"):addTabEventListener(ContainerRecharge.pushTabButtons)
		
		--未开启VIP的话隐藏VIP
		local opened, level, funcName = GameSocket:checkFuncOpenedByID(20271)
		if not opened then
			var.xmlPanel:getWidgetByName("box_tab"):hideTab(3)
		end

		return var.xmlPanel
	end
end


function ContainerRecharge.pushTabButtons(sender)
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
function ContainerRecharge:updateGameMoney()
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

function ContainerRecharge.onPanelOpen()
	ContainerRecharge.freshList()
	GameSocket:PushLuaTable("gui.ContainerRecharge.onPanelData", GameUtilSenior.encode({
		actionid = "fresh", 
		sys = device.platform,
		platformId = GameCCBridge.getPlatformId()
	}))
end

function ContainerRecharge:updateGameMoney1(event)
	if var.xmlPanel then
		local mainrole = GameSocket.mCharacter
		local moneyLabel = {
			{name="lblVcoin",	pre=GameConst.str_vcoin,	value =	mainrole.mVCoinBind or 0	},
			--{name="lblBVcoin",	pre=GameConst.str_vcoinb,	value =	mainrole.mVCoinBind or 0},
			--{name="lblMoney",	pre=GameConst.str_money,	value =	mainrole.mGameMoney or 0},
			--{name="lblBMoney",	pre=GameConst.str_moneyb,	value =	mainrole.mGameMoneyBind or 0},
		}
		--建临时表遍历设属性
		for _,v in ipairs(moneyLabel) do
			var.xmlPanel:getWidgetByName(v.name):setString(v.value)
		end
	end
end

function ContainerRecharge.handlePanelData(event)
	if event.type ~= "ContainerRecharge" then return end
	local result = GameUtilSenior.decode(event.data)
	if result.cmd == "fresh" then

		--if var.vipLevel then
			--var.vipLevel:setString(result.vipLv)
		--end
		--var.xmlPanel:getWidgetByName("lblChargeInfo"):setString(result.chargeInfo)
		--var.xmlPanel:getWidgetByName("loadingbar"):setPercent(result.vipExp, result.vipMax)
		if result.data then
			ContainerRecharge.freshList(result.data)
		end
		var.limit6Charge = result.limit6Charge
	end
end

function ContainerRecharge.freshList(data)
	if not data then
		data = Data["android"]
		if device.platform == "ios" then
			data = Data["ios"]
		end
	end
	if not data then return end
	var.chargeList:reloadData(#data,function(subItem)
		local d = data[subItem.tag]
		-- local rmb2 = subItem:getChildByName("rmb2")
		-- if not rmb2 then
		-- 	rmb2 = display.newBMFontLabel({font = "image/typeface/vipcharge.fnt",})
		-- 	:addTo(subItem)
		-- 	:align(display.CENTER, 85, 23)
		-- 	:setName("rmb2")
		-- end
		-- rmb2:setString(""..d.num)
		subItem:getChildByName("vcoin"):setString(d.vcoin)
		if GameCCBridge.getPlatformId() == GameCCBridge.PLATFORM_GOOGLE_ID then
			subItem:getChildByName("rmb2"):setString("支付")
		else
			subItem:getChildByName("rmb2"):setString("支付"..d.num.."元")
		end
		subItem:getWidgetByName("icon"):loadTexture(d.res,ccui.TextureResType.plistType)--:setPosition(cc.p(93.99,102.00))--:setContentSize(cc.size(175,200)):setScale9Enabled(true)
		if d.res == "icon_04" then
			--subItem:getWidgetByName("icon"):setPositionY(130)
		else
			--subItem:getWidgetByName("icon"):setPositionY(102)
		end
		subItem:getWidgetByName("btn_charge"):setTag(d.num):setContentSize(cc.size(122,43)):setScale9Enabled(true)
		subItem:getWidgetByName("btn_charge"):addClickEventListener(function(sender)
			if var.limit6Charge and d.num == 6 and (PLATFORM_APP_STORE or PLATFORM_APP_LINYOU or PLATFORM_APP_DAZHAN) then
				return GameSocket:alertLocalMsg("每日只能充值6元档1次", "alert")
			end
			local money = sender:getTag()
			if money then
				GameCCBridge.doSdkPay(d.vcoin, money, 1)--三个字段都必须是数字，，后期还需要再把其他数据传上去
			end
		end)
	end)

end

function ContainerRecharge.onPanelClose()
	
end

return ContainerRecharge
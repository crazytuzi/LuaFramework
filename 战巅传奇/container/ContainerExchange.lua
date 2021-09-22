local ContainerExchange = {}
local var = {}

function ContainerExchange.initView(event)
	var = {
		xmlPanel,
		listBag,
		tradeNum = 0,
		sure = 0,
		closeEnabled = true,
		needClose = false,
		Image_HighLight,
		Image_HighLight_2,
	}

	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerExchange.uif") --cc.XmlLayout:widgetFromXml("ui/layout/ContainerExchange/ContainerExchange.xml")
	if var.xmlPanel then
		-- var.xmlPanel:getWidgetByName("img_border"):loadTexture("img_bg", ccui.TextureResType.plistType)
		-- var.xmlPanel:getWidgetByName("img_bg"):loadTexture("img_panel_bg2", ccui.TextureResType.plistType)

		GameBaseLogic.panelTradeOpen =true
		var.Image_HighLight = var.xmlPanel:getWidgetByName("Image_HighLight"):setVisible(false)
		var.Image_HighLight_2 = var.xmlPanel:getWidgetByName("Image_HighLight_2"):setVisible(false)
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_TRADE_MONEYCHANGE,ContainerExchange.updateMoney)
			:addEventListener(GameMessageCode.EVENT_TRADE_ITEMCHANGE,ContainerExchange.updateItem)
			:addEventListener(GameMessageCode.EVENT_SET_TARGET,ContainerExchange.setTargetInfo)

		-- 交易对象
		-- var.xmlPanel:getWidgetByName("label_trade_object")
		-- 	:setString(GameSocket.mTradeInfo.mTradeTarget.."("..GameSocket.mTradeInfo.mTradeDesLevel..")")

		-- 显示自己的元宝
		-- var.xmlPanel:getWidgetByName("mVcoin"):setString(GameSocket.mCharacter.mVCoin)	
		
		ContainerExchange.updateGameMoney()
		var.xmlPanel:getWidgetByName("box_tab"):setSelectedTab(1)
		var.xmlPanel:getWidgetByName("box_tab"):addTabEventListener(ContainerExchange.pushTabButtons)
		
		return var.xmlPanel

	end
end

function ContainerExchange.pushTabButtons(sender)
	local opened, level, funcName
	opened = true
	local tag = sender:getTag()
	--if tag == 2 then
	GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="main_friend",tab=tag})
	--end
end

--金币刷新函数
function ContainerExchange:updateGameMoney()
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


function ContainerExchange.onPanelOpen(event)

	local btnTradeName = {"btnConfirm","btnCancel"}
	var.xmlPanel:getWidgetByName("my_vcoin"):setString(GameSocket.mCharacter.mVCoin)
	var.xmlPanel:getWidgetByName("my_money"):setString(GameSocket.mCharacter.mGameMoney)
	local function pushTradeButton(pSender)
		local btnName = pSender:getName()
		if btnName == "btnConfirm" then
			if var.sure == 0 then
				GameSocket:TradeSubmit()
				--var.xmlPanel:getWidgetByName("btnSure"):setBrightStyle(1)
				var.Image_HighLight:setVisible(true)
				var.xmlPanel:getWidgetByName("btnConfirm"):setTitleText("已确认")
			end
		elseif btnName == "btnCancel" then

			local mParam = {
			name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", lblConfirm = "是否取消交易？",
			btnConfirm = "是", btnCancel = "否",
			confirmCallBack = function ()
				--GameSocket:PushLuaTable("gui.ContainerVip.onPanelData",GameUtilSenior.encode({actionid = "fly",param = {"v001",97+math.random(-1,1),147+math.random(-1,1)}}))
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL, str="panel_trade"})
				--GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL, str = "menu_bag"})
			end
		}
		GameSocket:dispatchEvent(mParam)
			--GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL, str="panel_trade"})
		-- elseif btnName == "btnSure" then
		-- 	if var.sure == 0 then
		-- 		var.sure = 1 - var.sure
		-- 		GameSocket:TradeSubmit()
		-- 	end
		-- 	pSender:setBrightStyle(var.sure)
		elseif btnName == "btnRecord" then
			ContainerExchange.showTradeRecord()
		end
	end

	for i,v in ipairs(btnTradeName) do
		local btnTrade = var.xmlPanel:getWidgetByName(v):setTouchEnabled(true)
		GUIFocusPoint.addUIPoint(btnTrade, pushTradeButton)
	end

	local function onEdit(event, editbox)
		print("--",event)
		if event == "began" then
				-- 保持面板不被关闭
			var.closeEnabled = false
			-- var.xmlPanel:performWithDelay(function ()
			-- 	var.closeEnabled = true
			-- end, 0.5)
	    elseif event == "return" then
			if editbox.tag == 1 then
				local vcoin_num = tonumber(editbox:getText())
				local mVCoin = GameSocket.mCharacter.mVCoin
				if vcoin_num and vcoin_num > 0 and GameSocket.mTradeInfo.mTradeDesSubmit == 0 then
					local vcoinnum = vcoin_num - GameSocket.mTradeInfo.mTradeVcoin
					if vcoinnum > 0 and vcoinnum <= mVCoin then
						GameSocket:TradeAddVcoin(vcoinnum)

						--ContainerExchange.updateMoney()
					else
						if vcoinnum > mVCoin then
							GameSocket:alertLocalMsg("您的元宝不足！","alert")
						end
						ContainerExchange.updateMoney()
						
					end
				else
					editbox:setString(GameSocket.mTradeInfo.mTradeVcoin)
				end
			end
			var.closeEnabled = true
			if var.needClose then GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL, str = "panel_trade"}) end
	    end
	end	

	local labelInfo = var.xmlPanel:getWidgetByName("self_vcoin_bg")
	local sizeC = labelInfo:getContentSize()
	var.editbox = GameUtilSenior.newEditBox({
		image = "image/icon/null.png",
		size = sizeC,
		listener = onEdit,
		color = cc.c4b(169, 169, 169,255),
		x = 0,
		y = 0,
		fontSize = 20,
		inputMode = cc.EDITBOX_INPUT_MODE_NUMERIC,
	})
	var.editbox.tag=1
	var.editbox:addTo(labelInfo,2)
	:align(display.BOTTOM_LEFT,0,0)

	var.listBag = var.xmlPanel:getWidgetByName("list_bag")
	local result={}
	for i=0,74 do
		local netItem = GameSocket:getNetItem(i)
		if netItem then 
			if bit.band(netItem.mItemFlags, GameConst.ITEM_FLAG_BIND) > 0 then
				-- itemIcon:getWidgetByName("img_bind_mark"):show()
			else
				-- itemIcon:getWidgetByName("img_bind_mark"):hide()
				table.insert(result,netItem)
			end
		end
	end

	var.listBag:reloadData(75,function (subItem)
		local id = subItem.tag 
		if result[id] then 
			local param = {
				tipsType = GameConst.TIPS_TYPE.TRADE,
				parent = subItem,
				typeId = result[id].mTypeID,
				num= result[id].mNumber,
				pos = result[id].position,
				--iconType = GameConst.ICONTYPE.DEPOT,----单击
				--titleText = GameConst.str_put_in,
				customCallFunc = function ()
				--print(",,,,,,,,",var.tradeNum)
					if var.tradeNum < 5 then
						GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SET_TARGET,pos = result[id].position})
					end
				end
			}
			GUIItem.getItem(param)
		else
			GUIItem.getItem({parent = subItem})
		end
	end)
	
	local function onEdit2(event, editbox2)
		print("--",event)
		if event == "began" then
				-- 保持面板不被关闭
			var.closeEnabled = false
			-- var.xmlPanel:performWithDelay(function ()
			-- 	var.closeEnabled = true
			-- end, 0.5)
	    elseif event == "return" then
			if editbox2.tag == 1 then
				local money_num = tonumber(editbox2:getText())
				local mmoney =  GameSocket.mCharacter.mGameMoney
				if money_num and money_num > 0 and GameSocket.mTradeInfo.mTradeDesSubmit == 0 then
					local m_money = money_num - GameSocket.mTradeInfo.mTradeGameMoney
					if m_money > 0 and m_money <= mmoney then
						--GameSocket:TradeAddVcoin(vcoinnum)
						GameSocket:TradeAddGameMoney(m_money)
						--ContainerExchange.updateMoney()
					else
						if money_num > mmoney then
							GameSocket:alertLocalMsg("您的金币不足！","alert")
						end
						ContainerExchange.updateMoney()
					end
				else
					editbox2:setString(GameSocket.mTradeInfo.mTradeVcoin)
				end
			end
			var.closeEnabled = true
			if var.needClose then GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL, str = "panel_trade"}) end
	    end
	 --    var.xmlPanel:getWidgetByName("my_vcoin"):setString(GameSocket.mCharacter.mVCoin)
		-- var.xmlPanel:getWidgetByName("my_money"):setString(GameSocket.mCharacter.mGameMoney)
	end	
	local labelInfo2 = var.xmlPanel:getWidgetByName("self_money_bg")
	
	local sizeC2 = labelInfo2:getContentSize()
	var.editbox2 = GameUtilSenior.newEditBox({
		image = "image/icon/null.png",
		size = sizeC2,
		listener = onEdit2,
		color = cc.c4b(169, 169, 169,255),
		x = 0,
		y = 0,
		fontSize = 20,
		inputMode = cc.EDITBOX_INPUT_MODE_NUMERIC,
	})
	var.editbox2.tag=1
	var.editbox2:addTo(labelInfo2,2)
	:align(display.BOTTOM_LEFT,0,0)
	
	---------------交易记录-------------
	ContainerExchange.getLocalRecord()
	ContainerExchange.updateItem()
	ContainerExchange.setPanelText()

end

function ContainerExchange.setPanelText()
	local labelTable = {
		{name = "title_other_trade", 	wType="label",		text =  GameSocket.mTradeInfo.mTradeTarget},
		{name = "title_self_trade", 	wType="label",		text = GameBaseLogic.chrName},
		--{name = "title_my_bag", 		wType="label",		text = GameConst.str_my_bag},
		--{name = "yes_label", 			wType="label",		text = GameConst.str_unconfirmed},
		--{name = "lblTitleConfirm",		wType="label",		text = GameConst.str_confirm},
	--	{name = "btnRecord",			wType="button",		text = GameConst.str_trade_record},
		{name = "btnConfirm",			wType="button",		text = "确认"},
		{name = "btnCancel",			wType="button",		text = GameConst.str_cancel},
	}
	for _,v in ipairs(labelTable) do
		if v.wType == "label" then
			var.xmlPanel:getWidgetByName(v.name):setString(v.text)
			-- if v.name = "title_other_trade" then 
			-- 	var.xmlPanel:getWidgetByName(v.name):setString(v.text)
			-- end
		elseif v.wType == "button" then
			var.xmlPanel:getWidgetByName(v.name):setTitleText(v.text)
		end
	end
end

function ContainerExchange.onPanelClose()

--print("0000000000000")
	GameBaseLogic.panelTradeOpen = false
	GameSocket:storeTradeRecord()
	--if GameSocket.mTradeInfo.mTradeResult ~= 1 then
	GameSocket:CloseTrade()
	--end
	local param = {
		name = GameMessageCode.EVENT_PANEL_ON_ALERT, panel = "hint", visible = false,
	}
	GameSocket:dispatchEvent(param)
end


function ContainerExchange.updateMoney(event)
	if GameSocket.mTradeInfo.mTradeDesSubmit == 1 then
		--var.xmlPanel:getWidgetByName("yes_label"):setString(GameConst.str_confirmed)
		--var.xmlPanel:getWidgetByName("yes_label"):setColor(display.COLOR_GREEN)
		var.Image_HighLight_2:setVisible(true)
	end
	-- print(GameSocket.mTradeInfo.mTradeVcoin,GameSocket.mTradeInfo.mTradeGameMoney)
	if var.editbox then
		var.editbox:setText(GameSocket.mTradeInfo.mTradeVcoin)
	end
	if var.editbox2 then
		var.editbox2:setText(GameSocket.mTradeInfo.mTradeGameMoney)
	end
	var.xmlPanel:getWidgetByName("my_vcoin"):setString(GameSocket.mCharacter.mVCoin)
	var.xmlPanel:getWidgetByName("my_money"):setString(GameSocket.mCharacter.mGameMoney)

	var.xmlPanel:getWidgetByName("other_vcoin"):setString(GameSocket.mTradeInfo.mTradeDesVcoin)
	var.xmlPanel:getWidgetByName("other_money"):setString(GameSocket.mTradeInfo.mTradeDesGameMoney)
end

function ContainerExchange.updateItem(event)
	local function updateOtherList(item)
		local i = item.tag - 1
		local items = GameSocket.mDesTradeItems[i]
		if items then
			local tmpDef = GameSocket:getItemDefByID(items.mTypeID)
			item:getWidgetByName("lbl_name_other"):setString(tmpDef.mName)
			local params={
				parent		=item:getWidgetByName("other_item"):loadTexture("common_big_right_gezi.png",ccui.TextureResType.plistType), 
				typeId		=items.mTypeID,
				mZLevel 	= items.mZLevel,
				mLevel		=items.mLevel, 
				num			=items.mNumber
			}
			GUIItem.getItem(params)
		else
			item:getWidgetByName("lbl_name_other"):setString("")
			GUIItem.getItem({
				parent		=item:getWidgetByName("other_item"):loadTexture("common_big_right_gezi.png",ccui.TextureResType.plistType)
				})
		end
	end
	local otherList = var.xmlPanel:getWidgetByName("other_list")
	otherList:reloadData(5,updateOtherList)

	local function updateSelfList(item)
		var.tradeNum = #GameSocket.mThisChangeItems + 1
		-- if GameSocket.mThisChangeItems[item.tag] then
		-- 	GameSocket.mThisChangeItems[item.tag] = false
		local nItem = GameSocket.mThisTradeItems[item.tag - 1]
		if nItem then
			local tmpDef = GameSocket:getItemDefByID(nItem.mTypeID)
			item:getWidgetByName("lbl_name_self"):setString(tmpDef.mName)
			GUIItem.getItem({
				parent	=	item:getWidgetByName("self_item"), 
				typeId	=	nItem.mTypeID,
				iconType =  GameConst.ICONTYPE.DEPOT,----单击
				mZLevel = 	nItem.mZLevel,
				mLevel	=	nItem.mLevel, 
				num		=	nItem.mNumber
			})
		else
			item:getWidgetByName("lbl_name_self"):setString("")
			GUIItem.getItem({
				parent	=	item:getWidgetByName("self_item"):loadTexture("common_big_right_gezi.png",ccui.TextureResType.plistType)
			})
		end
	end
	local selfList = var.xmlPanel:getWidgetByName("self_list")
	selfList:reloadData(5,updateSelfList)
end

function ContainerExchange.setTargetInfo(event)
	local pos = event.pos
	local item = GameSocket:getNetItem(pos)
	if item then
		GameSocket:TradeAddItem(pos,item.mTypeID,0,0)
	end
end

function ContainerExchange.showTradeRecord()

	local recordMsg = {}

	local param = {
		name = GameMessageCode.EVENT_PANEL_ON_ALERT, panel = "hint", visible = true,
		lblAlert1 = GameConst.str_trade_record, 
		lblAlert2 = GameSocket.mTradeLocalRecord,
		alertTitle = GameConst.str_close,
	}
	GameSocket:dispatchEvent(param)
end

function ContainerExchange.getLocalRecord()
	if #GameSocket.mTradeLocalRecord <= 0 then
		-- local mainGhost = cc.NetClient:getInstance():getMainGhost()
		local content = cc.UserDefault:getInstance():getStringForKey("tradeRecord","")
		if content and content ~= "" then
			local tempjson=cc.DataBase64:DecodeData(content)
			GameSocket.mTradeLocalRecord=GameUtilSenior.decode(tempjson)
		end
	end
end

function ContainerExchange.checkPanelClose()
	var.needClose = true
	return var.closeEnabled
end

return ContainerExchange
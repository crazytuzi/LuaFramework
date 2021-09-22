local ContainerBag = class("ContainerBag")

--背包按钮表，按钮名做key,normalTitle按钮常态文本，selectTitle按钮选中态文本
local bagButtons = {
	--["btnTidy"] 	= {normalTitle = GameConst.str_tidy},
	--["btnHuiShou"] 	= {normalTitle = GameConst.str_huishou},
	--["btnShangDian"] 	= {normalTitle = GameConst.str_sssd},
	["btnTidy"] 	= {normalTitle = ""},
	["btnHuiShou"] 	= {normalTitle = ""},
	["btnShangDian"] 	= {normalTitle = ""},
	["cangku"] 	= {normalTitle = ""},
	["btnAutoHuiShou"] 	= {normalTitle = ""},
	["btnAllMoney"] =  {normalTitle = ""},
}

--背包状态
local OPERATE = {
	DROP = "btnDrop",
	DESTORY = "btnDestory",
}

local var = {}
--局部变量表
--初始化面板
local resource = {"coin","coin_bind","vcoin","vcoin_bind"}

function ContainerBag.initView(event)
	var = {
		xmlPanel,
		isSplit = false,
		selectPos,
		operateName,
		curBagNum=0,--背包新增格子数
		xmlShop=nil,
		xmlOpenGe=nil,
		shopData={},
		geNum=1,--默认开启1个
		mark=nil,
		geCount=0,
		curWeaponId=nil,
		curClothId=nil,
		totalTime =0,
		timeTable = {},

		mShowMainEquips = true,

		isPanelOpened = false,
		layerShop= nil,
		endPlay = false
	}
	print("zzzzzzzzzzzzzzzzzzzzinitView:1")
	--初始化局部变量,变量遵循驼峰命名
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerBag.uif")
	-- --读取界面文件,返回根节点

	print("zzzzzzzzzzzzzzzzzzzzinitView:2")
	if var.xmlPanel then
		--判断xml读取成功
		------------------------------------------------------
		--遍历bagButtons表设置背包按钮
		var.xmlPanel:getWidgetByName("box_tab"):setSelectedTab(1)
		var.xmlPanel:getWidgetByName("box_tab"):addTabEventListener(ContainerBag.pushTabButtons)
		print("zzzzzzzzzzzzzzzzzzzzinitView:3")
		
		var.layerShop = var.xmlPanel:getWidgetByName("layerShop")
		var.LayerListBg = var.xmlPanel:getWidgetByName("LayerListBg")
		for k,v in pairs(bagButtons) do
			local btnBag = var.xmlPanel:getWidgetByName(k)
			if btnBag then
				btnBag:setTitleText(v.normalTitle)
				GUIFocusPoint.addUIPoint(btnBag, ContainerBag.pushBagButton)
			end
			if event.btn == k then
				ContainerBag.pushBagButton(btnBag)
			end
		end
		-- GUIFocusPoint.addUIPoint(var.xmlPanel:getWidgetByName("btnClose"),ContainerBag.pushBagButton)
		GUIFocusPoint.addUIPoint(var.xmlPanel:getWidgetByName("btnClose1"),ContainerBag.pushBagButton)
		
		------------------------------------------------------
		--此处处理面板打开后固定信息的刷新,设置事件监听,设置按钮回调等操作
		--初始化背包列表
		ContainerBag.freshBagList()
		--打开面板后手动刷新金币状态
		ContainerBag:updateGameMoney()
		--人物形象
		--ContainerBag.updateInnerLooks()
		--ContainerBag:updateGameMoneySelf(var.xmlPanel)


		--监听金币变化事件,事件会触发刷新函数
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_GAME_MONEY_CHANGE, ContainerBag.updateGameMoney)
			--:addEventListener(GameMessageCode.EVENT_AVATAR_CHANGE, ContainerBag.updateInnerLooks)
			:addEventListener(GameMessageCode.EVENT_SOLT_CHANGE, ContainerBag.addCellUpdate)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerBag.handlePanelData)
			:addEventListener(GameMessageCode.EVENT_POWER_CHANGE, ContainerBag.handlePowerChange)
			:addEventListener(GameMessageCode.EVENT_FRESH_ITEM_PANEL, ContainerBag.onFreshItemPanel)
		------------------------------------------------------
		return var.xmlPanel
	end
end

function ContainerBag.pushTabButtons(sender)
	local opened, level, funcName
	opened = true
	local tag = sender:getTag()
	print("zzzzzzzzzzzzzzzzzzzzpushTabButtons:00")
	if tag == 2 then
		print("zzzzzzzzzzzzzzzzzzzzpushTabButtons:2")
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="panel_depot"})
	elseif tag == 3 then
		print("zzzzzzzzzzzzzzzzzzzzpushTabButtons:3")
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="menu_recycle"})
	end
end


function ContainerBag.updateInnerLooks()
	-- if not var.panelShow then return end

	local img_role = var.xmlPanel:getChildByName("img_role")
	local img_wing = var.xmlPanel:getChildByName("img_wing")
	local img_weapon = var.xmlPanel:getChildByName("img_weapon")

	--设置翅膀内观
	if not img_wing then
		img_wing = cc.Sprite:create()
		img_wing:addTo(var.xmlPanel):align(display.CENTER, 306, 370):setName("img_wing")
	end
	-- local weaponDef = GameSocket:getItemDefByPos(GameConst.ITEM_WEAPON_POSITION)
	local wing = GameCharacter._mainAvatar:NetAttr(GameConst.net_wing)
	if wing then
		if wing~=var.curwingId then
			local filepath = "image/fly/"..wing..".png"
			asyncload_callback(filepath, img_wing, function(filepath, texture)
				img_wing:setVisible(true)
				img_wing:setTexture(filepath)
			end)
			var.curwingId=wing
		end
	else
		img_wing:setTexture(nil)
		img_wing:setVisible(false)
		var.curwingId=nil
	end
	--设置衣服内观
	if not img_role then
		img_role = cc.Sprite:create()
		img_role:addTo(var.xmlPanel):align(display.CENTER, 200, 445):setName("img_role")
	end
	local clothDef,clothId
	local isFashion = false

	local fashion = GameCharacter._mainAvatar:NetAttr(GameConst.net_fashion)
	local cloth = GameCharacter._mainAvatar:NetAttr(GameConst.net_cloth)
	print("cloth",cloth)
	print("fashion",fashion)
	if fashion >0 then
		clothId = fashion
		isFashion = true
	else
		clothDef = GameSocket:getItemDefByPos(GameConst.ITEM_CLOTH_POSITION)
		--print(GameUtilSenior.encode(clothDef))
		if clothDef then
			clothId = clothDef.mResMale
		else 
			clothId = cloth
		end
	end
	if not clothId then
		local gender = GameCharacter._mainAvatar:NetAttr(GameConst.net_gender)
		local luoti= gender==200 and  10000000 or 10000001
		clothId = luoti
	end
	if clothId~=img_role.curClothId then
		
		local maxPicID = 0
		for i=0,100,1 do
			local filepath = string.format("image/%s/%d%02d.png",isFashion and "fdress" or "dress",clothId,i)
			if not cc.FileUtils:getInstance():isFileExist(filepath) then
				break
			else
				maxPicID = i
			end
		end
				
		local startNum = 0
		local function startShowBg()
		
			local filepath = string.format("image/%s/%d%02d.png",isFashion and "fdress" or "dress",clothId,startNum)
			asyncload_callback(filepath, img_role, function(filepath, texture)
				img_role:setTexture(filepath)
			end)
			
			startNum= startNum+1
			if startNum ==maxPicID+1 then
				startNum =0
			end
		end
		var.xmlPanel:stopAllActions()
		var.xmlPanel:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowBg)}),tonumber(maxPicID+1)))
		
		img_role.curClothId = clothId
	end

	--设置武器内观
	if not img_weapon then
		img_weapon = cc.Sprite:create()
		img_weapon:addTo(var.xmlPanel):setAnchorPoint(cc.p(0.52,0.3)):setPosition(195, 370):setName("img_weapon")
	end
	-- local weapon = GameCharacter._mainAvatar:NetAttr(GameConst.net_weapon)
	local weaponDef = GameSocket:getItemDefByPos(GameConst.ITEM_WEAPON_POSITION)
	if not isFashion and weaponDef then
		if weaponDef.mResMale~=var.curWeaponId then
		
			
			
			local maxPicID = 0
			for i=0,100,1 do
				local filepath = string.format("image/arm/%d%02d.png",weaponDef.mResMale,i)
				if not cc.FileUtils:getInstance():isFileExist(filepath) then
					break
				else
					maxPicID = i
				end
			end
					
			local startNum = 0
			local function startShowBg()
								
				local filepath = string.format("image/arm/%d%02d.png",weaponDef.mResMale,startNum)
				asyncload_callback(filepath, img_weapon, function(filepath, texture)
					img_weapon:setVisible(true)
					img_weapon:setTexture(filepath)
				end)
				
				startNum= startNum+1
				if startNum ==maxPicID+1 then
					startNum =0
				end
			end
			img_weapon:stopAllActions()
			img_weapon:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowBg)}),tonumber(maxPicID+1)))
			
			
			
			var.curWeaponId=weaponDef.mResMale
		end
	else
		img_weapon:stopAllActions()
		img_weapon:setTexture(nil)
		img_weapon:setVisible(false)
		var.curWeaponId=nil
	end
end

function ContainerBag.onPanelOpen()
	var.isPanelOpened = true
	ContainerBag.freshBagList()
	--打开背包时请求当前格子开放的CD时间
	-- GameSocket:PushLuaTable("gui.ContainerBag.handlePanelData",GameUtilSenior.encode({actionid = "reqGeOpenNeedTime"}))
	-- ContainerBag.initOpenGe()
end

function ContainerBag.onFreshItemPanel(event)
	--print("/////////////////ContainerBag.onFreshItemPanel/////////////////", event.flag)
	if var.isPanelOpened and event.flag == 0 then
		ContainerBag.freshBagList()
	end
end

function ContainerBag.handlePowerChange(event)
	-- var.powerNum:setString(GameSocket.mCharacter.mFightPoint)
end

function ContainerBag.handlePanelData(event)
	if event.type == "ContainerBag" then
		local data = GameUtilSenior.decode(event.data)
		if not data then return end
		if data.cmd=="startOpenGeZi" then
			GameSocket:AddBagSlot()
		elseif data.cmd=="senderShopData" then
			var.shopData = data.data
			ContainerBag.initShop()
		elseif data.cmd == "curBagNum" then
			-- var.geCount = data.lefttime
			-- var.totalTime = data.totalTime
			-- var.timeTable = data.timeTable
			-- local list = var.xmlPanel:getWidgetByName("listBag")
			-- for i=data.bagnum-data.opennum+1,data.bagnum+1 do
			-- 	local cell = list:getModelByIndex(i)
			-- 	if cell then
			-- 		ContainerBag.cdRun(cell,var.geCount,var.totalTime)
			-- 	end
			-- end
			-- ContainerBag.updateOpenCount(var.geCount)
		end
	end
end

--背包格子开启成功后刷新列表
function ContainerBag.addCellUpdate(event)
	-- ContainerBag.freshBagList()
end

--初始化背包列表
function ContainerBag.freshBagList()
	--获取列表容器
	local list = var.xmlPanel:getWidgetByName("listBag")--:setSliderVisible(false)
	list:reloadData(GameConst.ITEM_BAG_MAX, ContainerBag.updateBagListByItem,nil,false)
end

--复用列表会根据当前显示范围传来容器,请求对此容器填充内容
function ContainerBag.updateBagListByItem(subItem)
	local itemPos = subItem.tag -1
	if subItem:getWidgetByName("mark") then
		subItem:removeChildByName("mark")
	end

	--背包锁设置
	subItem:getWidgetByName("black"):hide()
	-- if subItem.tag<=GameConst.ITEM_BAG_SIZE+GameSocket.mBagSlotAdd then
	-- 	if var.geCount>0 and var.totalTime>0 then
	-- 		ContainerBag.cdRun(subItem,0,0)
	-- 	end
	-- elseif subItem.tag==(GameConst.ITEM_BAG_SIZE+GameSocket.mBagSlotAdd+1) then
	-- 	if var.geCount>0 and var.totalTime>0 then
	-- 		ContainerBag.updateOpenCount(var.geCount)
	-- 		ContainerBag.cdRun(subItem,var.geCount,var.totalTime)
	-- 	end
	-- else
	-- 	ContainerBag.cdRun(subItem,var.geCount,var.totalTime)
	-- end

	-- subItem:getWidgetByName("cell_no_open"):setVisible(subItem.tag>(GameConst.ITEM_BAG_SIZE+GameSocket.mBagSlotAdd+1))
	-- subItem:getWidgetByName("cellbg"):setTouchEnabled(subItem.tag>=(GameConst.ITEM_BAG_SIZE+GameSocket.mBagSlotAdd+1))
	--给每个物品框填充内容
	local param = {
		parent = subItem,
		pos = itemPos,
		iconType = GameConst.ICONTYPE.BAG,
		tipsType = GameConst.TIPS_TYPE.BAG,
		tipsPos	= cc.p(display.cx-var.xmlPanel:getContentSize().width/2+25, display.cy-var.xmlPanel:getContentSize().height/2+2),
		tipsAnchor = cc.p(0,0),
		hitTest = function(sender)
		    return GameUtilSenior.hitTest(var.xmlPanel:getWidgetByName("listBag"), sender);
		end,
		compare = true
	}
	GUIItem.getItem(param)
end

--金币刷新函数
function ContainerBag:updateGameMoney(event)
	if var.xmlPanel then
		local mainrole = GameSocket.mCharacter
		local moneyLabel = {
			{name="lblVcoin",	pre=GameConst.str_vcoin,	value =	mainrole.mVCoin or 0	,	icon = "icon_coin"},
			{name="lblBVcoin",	pre=GameConst.str_vcoinb,	value =	mainrole.mVCoinBind or 0,	icon = "icon_coin_bind"},
			{name="lblMoney",	pre=GameConst.str_money,	value =	mainrole.mGameMoney or 0,	icon = "icon_money"},
			{name="lblBMoney",	pre=GameConst.str_moneyb,	value =	mainrole.mGameMoneyBind or 0,	icon = "icon_money"},
		}
		--建临时表遍历设属性
		for _,v in ipairs(moneyLabel) do
			if var.xmlPanel:getWidgetByName(v.name) then
				var.xmlPanel:getWidgetByName(v.name):setString(v.value)
			end
		end
	end
end


--金币刷新函数
function ContainerBag:updateGameMoneySelf(panel)
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

function ContainerBag.TidyCallBack(sender)
	sender:setTitleText(GameConst.str_tidy)
	sender:setTitleText("")
end
function ContainerBag.openHuiShou()
	GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "menu_recycle"})
end
function ContainerBag.openShop()
	local posx = var.LayerListBg:getPositionX()
	local posy = var.LayerListBg:getPositionY()
	local move = 200
	if var.layerShop:isVisible() then
		posx = posx + 200
	else
		posx = posx - 200
		GameSocket:PushLuaTable("gui.ContainerBag.handlePanelData",GameUtilSenior.encode({actionid = "reqShopData"}))
	end
	if not var.endPlay then
		var.endPlay = true
		if not var.layerShop:isVisible() then
			var.LayerListBg:runAction(cc.Sequence:create(
			cca.moveTo(10/30,posx,posy),
			cc.CallFunc:create(function ( ... )
					var.layerShop:show()
					var.layerShop:setOpacity(0)
					var.layerShop:runAction(cc.Sequence:create(
						cca.fadeIn(0.3),
						cc.CallFunc:create(function ( ... )
							var.endPlay = false
						end)
						))
			end)
			))
		else
			var.layerShop:runAction(cc.Sequence:create(
				cc.CallFunc:create(function ( ... )
					var.layerShop:hide()
					var.LayerListBg:runAction(cc.Sequence:create(
						cca.moveTo(10/30,posx,posy),
						cc.CallFunc:create(function ( ... )
							var.endPlay = false
						end)
						))
				end)
				))
		end
	end
end
function ContainerBag.pushBagButton(pSender)
	local btnName = pSender:getName()
	if btnName == "btnTidy" then
		GameSocket:SortItem(0)
		pSender:stopAllActions()
		GameUtilSenior.setCountDown(pSender,GameConst.BagTidyIntrval,1,ContainerBag.TidyCallBack)
	elseif btnName == "btnShangDian" or btnName == "btnClose1" then
		ContainerBag.openShop()
		return
	elseif btnName == "cangku" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="panel_depot"})
	elseif btnName == "btnAllMoney" then
		GameSocket:NpcTalk(1000017,"100")
		return
	elseif btnName == "btnAutoHuiShou" then
		GameSocket:PushLuaTable("gui.ContainerBag.handlePanelData",GameUtilSenior.encode({actionid = "autoHuiShou"}))
		return
	elseif btnName == "btnHuiShou" then
		--if GameUtilSenior.isObjectExist(var.xmlShop) then
		--	var.xmlShop:hide()
		--end
		--local mParam = {
		--	name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", lblConfirm = "是否传送到回收使者？",
		--	btnConfirm = "是", btnCancel = "否",
		--	confirmCallBack = function ()
		--		GameSocket:PushLuaTable("gui.ContainerBag.handlePanelData",GameUtilSenior.encode({actionid = "flyHuiShou",}))
		--		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL, str = "menu_bag"})
		--	end
		--}
		--GameSocket:dispatchEvent(mParam)
		--print("open huishou panel")
		ContainerBag.openHuiShou()
		--GameSocket:PushLuaTable("gui.ContainerBag.handlePanelData",GameUtilSenior.encode({actionid = "openAutoHuiShou",}))
		--GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL, str = "menu_bag"})
		return
	elseif btnName == "btnClose" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL, str = "menu_bag"})
		return
	end
	if btnName ~= "btnTidy" then 
		if var.operateName ~= btnName then
			var.operateName = btnName
			if bagButtons[btnName].selectTitle then 
				pSender:setTitleText(bagButtons[btnName].selectTitle) 
			end
		end
	end
end

--面板关闭通知函数
function ContainerBag.onPanelClose()
	if GameUtilSenior.isObjectExist(var.xmlShop) then
		var.xmlShop:hide()
	end
	-- if GameUtilSenior.isObjectExist(var.xmlOpenGe) then
	-- 	var.xmlOpenGe:hide()
	-- end
	
	-- if GameUtilSenior.isObjectExist(var.xmlPanel) then
	-- 	var.xmlPanel:getWidgetByName("listBag"):reloadData(0, ContainerBag.updateBagListByItem,nil,false)
	-- end
	var.isPanelOpened = false
end
-----------------------------------------------------随身商店-----------------------------------------------------------
function ContainerBag.initShop()
	-- var.shopData
	-- if not var.xmlShop then
	-- 	var.xmlShop = GUIAnalysis.load("ui/layout/ContainerBag_shop.uif")
	-- 		:setTouchEnabled(true)
	-- 		:addTo(var.xmlPanel):align(display.CENTER, 236, 282) :hide():setLocalZOrder(5) 
	-- end
	-- var.xmlShop:setVisible(not var.xmlShop:isVisible())
	local listShop = var.xmlPanel:getWidgetByName("listShop"):setSliderVisible(false)
	listShop:reloadData(#var.shopData,ContainerBag.updateShop,nil,false)
	-- var.xmlShop:getWidgetByName("btnback"):addClickEventListener(function ( s )
	-- 	var.xmlShop:hide()
	-- end)
end

function ContainerBag.updateShop(item)
	local itemData = var.shopData[item.tag]
	item:getWidgetByName("labName"):setString(itemData.name)
	item:getWidgetByName("labPrice"):setString(itemData.money)
	local res = resource[itemData.MoneyKind-99]
	item:getWidgetByName("vcoin"):loadTexture(res,ccui.TextureResType.plistType)
	GUIItem.getItem({parent=item:getWidgetByName("icon") , typeId=itemData.id,num = itemData.num})
	local function prsBtnItem(sender)
		GameSocket:PushLuaTable("gui.ContainerBag.handlePanelData",GameUtilSenior.encode({actionid = "shopBuy",params={storeId=sender.storeId}}))
	end 
	local btnBuy = item:getWidgetByName("btnBuy")
	if not btnBuy and item.preTag then
		btnBuy = item:getWidgetByName("btnBuy"..item.preTag)
	end
	btnBuy:setName("btnBuy"..item.tag)
	item.preTag = item.tag

	btnBuy.storeId = itemData.storeId
	GUIAnalysis.attachEffect(btnBuy,"outline(076900,1)")
	GUIFocusPoint.addUIPoint(btnBuy , prsBtnItem)
	-- item:getWidgetByName("renderBg"):setVisible(item.tag<1)
end

-----------------------------------------------------开背包格子-----------------------------------------------------------
-- function ContainerBag.initOpenGe()
-- 	if not var.xmlOpenGe then
-- 		var.xmlOpenGe = GUIAnalysis.load("ui/layout/ContainerBag_open.uif")
-- 			:addTo(var.xmlPanel)
-- 			:align(display.CENTER, 422, 593/2)
-- 			:setLocalZOrder(6)
-- 		var.xmlOpenGe:getWidgetByName("imgOpenBg"):setTouchEnabled(true)
-- 		GameUtilSenior.asyncload(var.xmlOpenGe, "openbg", "ui/image/prompt_bg.png")
-- 		ContainerBag.initBtnClick()
-- 	end
-- 	var.xmlOpenGe:hide()
-- end

-- function ContainerBag.initBtnClick()
-- 	local btnArr = {"btnLeft","btnRight","btnOk","btnNo","imgBg"}
-- 	local function prsBtnClick(sender)
-- 		local btnName = sender:getName()
-- 		if btnName=="btnLeft" then
-- 			if var.geNum>1 then  var.geNum=var.geNum-1 end
-- 			ContainerBag.freshNeedVcoin(var.geNum)
-- 			var.xmlOpenGe:getWidgetByName("labOpenNum"):setString(var.geNum)
-- 		elseif btnName=="btnRight" then
-- 			if var.geNum<(GameConst.ITEM_BAG_MAX - GameConst.ITEM_BAG_SIZE-GameSocket.mBagSlotAdd) then  var.geNum=var.geNum+1 end
-- 			var.xmlOpenGe:getWidgetByName("labOpenNum"):setString(var.geNum)
-- 			ContainerBag.freshNeedVcoin(var.geNum)
-- 		elseif btnName=="btnOk" then
-- 			GameSocket:PushLuaTable("gui.ContainerBag.handlePanelData",GameUtilSenior.encode({actionid = "openBagGe",param = {var.geNum}}))
-- 			var.xmlOpenGe:hide()
-- 		elseif btnName=="btnNo" or btnName=="imgBg" then
-- 			var.xmlOpenGe:hide()
-- 		end
-- 	end
-- 	for i=1,#btnArr do
-- 		local btn = var.xmlOpenGe:getWidgetByName(btnArr[i])
-- 		btn:setTouchEnabled(true)
-- 		GUIFocusPoint.addUIPoint(btn,prsBtnClick)
-- 	end
-- end

-- --倒计时设置
-- function ContainerBag.freshNeedVcoin(num)
-- 	local needVcoin = 0
-- 	if var.timeTable then
-- 		num = GameUtilSenior.bound(1, num, #var.timeTable)
-- 		for i=1,num do
-- 			needVcoin = needVcoin + var.timeTable[i].needVcoin;
-- 		end		
-- 		local labNeedDesp = var.xmlOpenGe:getWidgetByName("labNeedDesp")
-- 		labNeedDesp:setTextAreaSize(cc.size(300,60))
-- 		labNeedDesp:ignoreContentAdaptWithSize(false)
-- 		labNeedDesp:setString("所需在线时长："..GameUtilSenior.setTimeFormat(needVcoin*60*1000,2).."\n需要【"..needVcoin.."】元宝，立即开启")
-- 	end
-- end

-- function ContainerBag.updateOpenCount(etime)
-- 	local time = etime or 1
-- 	if var.xmlOpenGe then
-- 		ContainerBag.freshNeedVcoin(1)
-- 		local labCount = var.xmlOpenGe:getWidgetByName("labCount")
-- 		labCount:stopAllActions()
-- 		labCount:runAction(cca.repeatForever(cca.seq({cca.delay(1), cca.callFunc(function (target)
-- 			time = time - 1
-- 			var.geCount = time
-- 			if time and time >= 0 then
-- 				labCount:setString("当前倒计时："..GameUtilSenior.setTimeFormat(time*1000,2))
-- 			else
-- 				labCount:stopAllActions()
-- 			end
-- 		end)})))
-- 	end
-- end

--解锁的CD动画
-- function ContainerBag.cdRun(target,time,totalTime)
-- 	local function prsBtnClick(sender)
-- 		local list = var.xmlPanel:getWidgetByName("listBag")
-- 		if GameUtilSenior.hitTest(list, sender) then 
-- 			if var.xmlOpenGe then
-- 				var.xmlOpenGe:setVisible(not var.xmlOpenGe:isVisible())
-- 			end
-- 		end
-- 	end
-- 	local function skillCoolDownCallBack(amark)
-- 		amark:setVisible(false)
-- 		if target.label then 
-- 			target.label:removeFromParentAndCleanup();
-- 			target.label = nil
-- 		end
-- 	end
-- 	if var.xmlOpenGe then var.xmlOpenGe:hide() end
-- 	if target.tag >= (GameConst.ITEM_BAG_SIZE+GameSocket.mBagSlotAdd+1) then
-- 		GUIFocusPoint.addUIPoint(target:getWidgetByName("cellbg"),prsBtnClick)
-- 		target:getWidgetByName("cellbg"):setTouchEnabled(true):setSwallowTouches(false)
-- 	end
-- 	if target.tag == (GameConst.ITEM_BAG_SIZE+GameSocket.mBagSlotAdd+1) and time>0 and totalTime>0 then
-- 		local mark = target:getWidgetByName("cellbg"):getChildByName("mark")
-- 		if not mark then
-- 			mark = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName("img_cell_black"))
-- 			:align(display.CENTER, 38, 38)
-- 			:setScaleX(-1)
-- 			:addTo(target:getWidgetByName("cellbg"),100)
-- 			:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
-- 			:setName("mark")
-- 		end
-- 		mark:stopAllActions()
-- 		mark:runAction(cc.Sequence:create(cc.ProgressFromTo:create(time,(time/totalTime)*100,0),cc.CallFunc:create(skillCoolDownCallBack)))
-- 		if not target.label then
-- 			target.label = GameUtilSenior.newUILabel({text = "开启",mName = "kaiqi"})
-- 			target.label:addTo(target):setPosition(cc.p(38,38))
-- 		end
-- 	else
-- 		if target:getWidgetByName("cellbg"):getChildByName("mark") then
-- 			target:getWidgetByName("cellbg"):removeChildByName("mark")
-- 		end
-- 		if target:getWidgetByName("kaiqi") then 
-- 			target:getWidgetByName("cellbg"):setTouchEnabled(false)
-- 			target:getWidgetByName("kaiqi"):removeFromParentAndCleanup();
-- 			target.label = nil
-- 		end
-- 	end
-- 	target:getWidgetByName("cell_no_open"):setVisible(target.tag>(GameConst.ITEM_BAG_SIZE+GameSocket.mBagSlotAdd)+1)
-- end

return ContainerBag
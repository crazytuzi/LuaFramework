local ContainerDiamond = {}
-- 装备各部件
local equip_info = {
	{pos = GameConst.ITEM_WEAPON_POSITION,	etype = GameConst.EQUIP_TAG.WEAPON},
	{pos = GameConst.ITEM_HAT_POSITION,		etype = GameConst.EQUIP_TAG.HAT},
	{pos = GameConst.ITEM_GLOVE1_POSITION,	etype = GameConst.EQUIP_TAG.GLOVE},
	{pos = GameConst.ITEM_RING1_POSITION,	etype = GameConst.EQUIP_TAG.RING},
	{pos = GameConst.ITEM_BELT_POSITION,	etype = GameConst.EQUIP_TAG.BELT},

	{pos = GameConst.ITEM_CLOTH_POSITION,	etype = GameConst.EQUIP_TAG.CLOTH},
	{pos = GameConst.ITEM_NICKLACE_POSITION,etype = GameConst.EQUIP_TAG.NECKLACE},
	{pos = GameConst.ITEM_GLOVE2_POSITION,	etype = GameConst.EQUIP_TAG.GLOVE},
	{pos = GameConst.ITEM_RING2_POSITION,	etype = GameConst.EQUIP_TAG.RING},
	{pos = GameConst.ITEM_BOOT_POSITION,	etype = GameConst.EQUIP_TAG.BOOT},
}

local var = {}
local tableShop = {
	[1]={id=25010001,name="攻击宝石",vcion=100},
	[2]={id=25020001,name="物防宝石",vcion=100},
	[3]={id=25030001,name="魔防宝石",vcion=100},
	[4]={id=25040001,name="生命宝石",vcion=100},
	[5]={id=25050001,name="魔法宝石",vcion=100},

}

-- local gemData = {17022,17020,17032,17044,17056,17057}
local gemData = {17022,17020,17032,0,17056,17057}
function ContainerDiamond.initView()
	var = {
		xmlPanel,
		selectImg,
		selectPos,
		curIndex,

		listShop,
		xmlAlertBuy,
		geNum = 1, --需要购买宝石数量
		price,

		btnCheckBool=false,	--升级宝石 材料不足是否元宝代替
		gemTable,
		needGemNum, 	--当宝石不够的时候需要购买多少个一级宝石
	}

	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerDiamond.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerDiamond.handlePanelData)
			-- :addEventListener(GameMessageCode.EVENT_QIANGHUA_CHANGE_VALUE, PanelQiangHua.updateAllAct)--总属性改变


		var.selectImg = var.xmlPanel:getWidgetByName("selectImg")
		var.selectImg:hide():setTouchEnabled(false)
		var.xmlPanel:getWidgetByName("imgMask"):setVisible(false)
		var.xmlPanel:getWidgetByName("upGemPanel"):setVisible(false)
		return var.xmlPanel
	end
end

function ContainerDiamond.onPanelOpen(params)
	ContainerDiamond.refreshPanel()
	ContainerDiamond.initButton()

	ContainerDiamond.upData();

	-- ContainerDiamond.updateGemInfo(gemData)
end

function ContainerDiamond.refreshPanel()
	for i = 1, 10 do
		local equip_block = var.xmlPanel:getWidgetByName("equip_"..i)
		equip_block:setTouchEnabled(true)
		equip_block.index=i
		equip_block.pos=equip_info[i].pos
		-- if i==5 or i==10 then
		-- 	equip_block:setScale(0.37):setTouchEnabled(true)
		-- 	var.xmlPanel:getWidgetByName("img_quality"..i):setScale(0.88)
		-- else
		-- 	equip_block:setScale(0.4):setTouchEnabled(true)
		-- end
		GUIFocusPoint.addUIPoint(equip_block , ContainerDiamond.selectedEquipItem)
		-- var.xmlPanel:getWidgetByName("imgJin"..i):setVisible(false)
		if not var.curIndex and i==1 then 
			ContainerDiamond.selectedEquipItem(equip_block)
		end
	end
	
	-- var.xmlPanel:getWidgetByName("btnJinJie"):setVisible(false)
end

function ContainerDiamond.initButton()
	
	local btns = {
		-- 主界面
		"uplevel2","uplevel3","uplevel4","uplevel5","uplevel6","btnGemDesp",
		-- 升级界面
		"btnUp","btnGuanBi"
	}
	for k,v in pairs(btns) do
		local pageButton = var.xmlPanel:getWidgetByName(v)
		if string.sub(v,0,string.len(v)-1) == "uplevel" then
			pageButton:setVisible(false)
		end
		
		GUIFocusPoint.addUIPoint(pageButton, ContainerDiamond.pushButtonsOfPage)
	end
end

-- 装备格子点击事件
function ContainerDiamond.selectedEquipItem(selectedImg)
	var.selectPos=selectedImg.pos
	var.curIndex=selectedImg.index

	var.selectImg:setPosition(selectedImg:getPositionX(),selectedImg:getPositionY()+3):show()

	GameSocket:PushLuaTable("gui.ContainerDiamond.handlePanelData",GameUtilSenior.encode({actionid = "itemPos",params = {pos=var.selectPos,index=var.curIndex}}))
	-- GameSocket:PushLuaTable("gui.PanelQiangHua.handlePanelData",GameUtilSenior.encode({actionid = "reqCurEquipGem",params = {index=var.curIndex}}))
end

function ContainerDiamond.pushButtonsOfPage(pSender)
	if pSender:getName() == "uplevel2" or pSender:getName() == "uplevel3" or pSender:getName() == "uplevel4" or pSender:getName() == "uplevel5" or pSender:getName() == "uplevel6" then
		ContainerDiamond.showUpGemPanel(pSender)
	elseif pSender:getName() == "btnGemDesp" then 	--属性查阅
		-- local mParam = {
		-- 	name = GameMessageCode.EVENT_PANEL_ON_ALERT, str = "confirm", lblConfirm = GameConst.str_has_upgraded_recycle,
		-- 	confirmCallBack = function ()
				
				
		-- 	end
		-- }
		-- GameSocket:dispatchEvent(mParam)
	elseif pSender:getName() == "btnUp" then
		
	elseif pSender:getName() == "btnGuanBi" then
		var.xmlPanel:getWidgetByName("upGemPanel"):setVisible(false)
		var.xmlPanel:getWidgetByName("imgMask"):setVisible(false)
	end
end

function ContainerDiamond.handlePanelData(event)
	local data=GameUtilSenior.decode(event.data)
	if event.type == "curItemNeed" then

	elseif event.type=="insertsucceed" then
		-- print(">>>>>>>>服务器返回数据",GameUtilSenior.encode(event.data))
		ContainerDiamond.updateGemInfo(data)
		ContainerDiamond.upData()
		-- local data = GameUtilSenior.decode(event.data)
		-- if data.cmd =="" then
		-- elseif event.type=="insertsucceed" then
			
			-- PanelQiangHua.updateComSucceed()

		-- elseif data.cmd=="" then
		-- elseif data.cmd=="" then
		-- end
	end
end


--更新选中装备的宝石信息
function ContainerDiamond.updateGemInfo(data)


	for i=1,#data do
		-- if i<=var.openNum then
			-- local imgLock = var.xmlPanel:getWidgetByName("imgLock"..i)
			-- local labGem = var.xmlPanel:getWidgetByName("labGem"..i)
			local item = var.xmlPanel:getWidgetByName("gem"..i)
			local param={}
			if data[i]>0 then
				param={
					iconType = GameConst.ICONTYPE.DEPOT,
					parent=item,
					typeId=data[i],
					doubleCall=function()
					 	GameSocket:PushLuaTable("gui.ContainerDiamond.handlePanelData",GameUtilSenior.encode({actionid = "gemRemove",params = {index=var.curIndex,kongIndex=i}}))
					 	item:getWidgetByName("item_icon"):removeFromParent()
					end

				}
				
				GUIItem.getItem(param)
				if i>1 and ContainerDiamond.selectGemValue(data[i],"gemLevel") < 12 then
					var.xmlPanel:getWidgetByName("uplevel"..i):setVisible(true)
				elseif i>1  then
					var.xmlPanel:getWidgetByName("uplevel"..i):setVisible(false)
				end
				-- local tmpDef = GameSocket:getItemDefByID(data[i])
				-- if tmpDef then
				-- 	labGem:setString(tmpDef.mName)
				-- 	print(">>>>道具名", tmpDef.mName)
				-- end
				-- imgLock:setOpacity(0)
				-- imgLock.state="item"
				-- imgLock.type=PanelQiangHua.getGemType(data[i])
			else
				GUIItem.getItem({parent=item})
				if i>1 then
					var.xmlPanel:getWidgetByName("uplevel"..i):setVisible(false)
				end

				-- labGem:setString("添加宝石")
				-- imgLock:loadTexture("img_add_gem",ccui.TextureResType.plistType):setOpacity(255)
				-- imgLock.state="additem"
			end
		-- end
	end
end

---------------------------------------------------------- 升级宝石
function ContainerDiamond.showUpGemPanel(sender)
	var.needGemNum = 0
	local str = sender:getName()
	local index = string.sub(str,string.len(str),-1)
	
	local equip = var.xmlPanel:getWidgetByName("gem"..index)
	local item = equip:getWidgetByName("item_icon")
	
	local upGemPanel = var.xmlPanel:getWidgetByName("upGemPanel")
	upGemPanel:setVisible(not upGemPanel:isVisible()):setTouchEnabled(true):setPosition(cc.p(450,250))
	var.xmlPanel:getWidgetByName("imgMask"):setVisible(upGemPanel:isVisible()):setContentSize(cc.size(900, 500)):setPosition(cc.p(0,0))
	:setTouchEnabled(true)

	local item1 = var.xmlPanel:getWidgetByName("item_1")
	local item2 = var.xmlPanel:getWidgetByName("item_2")

	param1 = {
		parent = item1,
		typeId = item.typeId
	}
	GUIItem.getItem(param1)
	param2 = {
		parent = item2,
		typeId = item.typeId+1
	}
	GUIItem.getItem(param2)

	--因为不能时时获取到物品，设置名字有误，去掉
	-- local itemDef = GameSocket:getItemDefByID(tonumber(item.typeId)+1)
	-- if itemDef then
		local labUpName = var.xmlPanel:getWidgetByName("labUpName"):setString("")
	-- end
	local richtext = upGemPanel:getWidgetByName("richWidget")
	if not richtext then
		local width = upGemPanel:getContentSize().width
		richtext=GUIRichLabel.new({size=cc.size(width/2, 0), space=3, name="richWidget"})
		richtext:addTo(upGemPanel):pos(150,385)
	end
	local gemNum = ContainerDiamond.getGemUpNum(item.typeId)
	local gemLevel = ContainerDiamond.selectGemValue(item.typeId,"gemLevel")
	local text = nil
	if gemNum >= 3 then
		text = "<font color=#FFA500>需要个数：</font><font color=#00ff00>3/"..gemNum.."</font>"
	else
		text = "<font color=#FFA500>需要个数：</font><font color=#ff0000>3/"..gemNum.."</font>"
		-- if gemLevel == 1 then
		-- 	var.needGemNum = (3-gemNum)
		-- else
		-- 	var.needGemNum = (3-gemNum)*(3^gemLevel)
		-- end
		var.needGemNum = (3-gemNum)*(gemLevel>1 and 3^gemLevel or 1)
	end
	-- print("需要一级宝石个数>>>>",var.needGemNum)
	text = "请使用牛币升级"
	richtext:setRichLabel(text)
	richtext:pos((upGemPanel:getContentSize().width-richtext:getContentSize().width/2)/2,385)

	-- local labNeedVcion = var.xmlPanel:getWidgetByName("labNeedVcion"):setString("需要元宝:0")
	if upGemPanel:isVisible() then
		ContainerDiamond.setGemUpBuy()
		local btnCheck = var.xmlPanel:getWidgetByName("btnCheck")
		btnCheck:addClickEventListener(function (sender)
			var.btnCheckBool =  not var.btnCheckBool 
			btnCheck:loadTextureNormal( (var.btnCheckBool and "btn_checkbox_sel") or "btn_checkbox", ccui.TextureResType.plistType)
			ContainerDiamond.setGemUpBuy()
		end)
	end
end

function ContainerDiamond.setGemUpBuy()
	local labNeedVcion = var.xmlPanel:getWidgetByName("labNeedVcion")
	if not var.btnCheckBool then 	--不使用元宝购买
		labNeedVcion:setString("需要元宝:0")
	else 	--材料不足元宝购买
		labNeedVcion:setString("需要元宝:"..var.needGemNum*100)
	end
end

function ContainerDiamond.getGemUpNum(typeid)
	local num = 1
	for i=1,#var.gemTable do
		if var.gemTable[i].mTypeID == typeid then
			num=num+1
		end 
	end

	return num
end

--[[
	传入宝石id，根据类型获取相应参数
	type = "kongIndex" 返回孔参数
	type = "gemLevel" 返回该类型宝石等级
]]
function ContainerDiamond.selectGemValue(typeid,type)
	local kongIndex=0
	local gemLevel=0
	-- if typeid >= 17017 and typeid <= 17019 then
	if typeid == 25060001 or typeid == 25070001  or typeid == 25080001 then 
		kongIndex = 1
	elseif typeid >= 25010001 and typeid <= 25010015 then
		kongIndex = 2
		gemLevel = typeid - 25010000
	elseif typeid >= 25020001 and typeid <= 25020015 then
		kongIndex = 6
		gemLevel = typeid - 25020000
	elseif typeid >= 25030001 and typeid <= 25030015 then
		kongIndex = 5
		gemLevel = typeid - 25030000
	elseif typeid >= 25040001 and typeid <= 25040015 then
		kongIndex = 3
		gemLevel = typeid - 25040000
	elseif typeid >= 25050001 and typeid <= 25050015 then
		kongIndex = 4
		gemLevel = typeid - 25050000
	end
	if type == "gemLevel" then
		return gemLevel
	elseif type == "kongIndex" then
		return kongIndex
	end
end
---------------------------------------------------------------------------------

---------------------------加载背包宝石  商店宝石-------------------------------------
-- 加载已获取的宝石 和商店宝石
function ContainerDiamond.upData()
	var.gemTable=nil
	var.gemTable=GameBaseLogic.getTypeGems(1)

	local listBag = var.xmlPanel:getWidgetByName("listBag")
	listBag:reloadData(32,ContainerDiamond.updateBagList)

	local listShop = var.xmlPanel:getWidgetByName("listShop")
	listShop:reloadData(#tableShop,ContainerDiamond.updateShopList)

end

-- 宝石背包数据
function ContainerDiamond.updateBagList(items)
	local index = -999
	local typeId = -999
	local itemDef
	if var.gemTable[items.tag] then
		index = var.gemTable[items.tag].position
		typeId = var.gemTable[items.tag].mTypeID
		itemDef = GameSocket:getItemDefByID(typeId)
	end
	local param = {
		iconType = GameConst.ICONTYPE.DEPOT,
		parent = items,
		pos = index,
		noTips = true,
		callBack = function()
				-- 显示tips
				-- local nItem = GameSocket:getNetItem(var.huishouTable[npos])
				
				if itemDef then
					GameSocket:dispatchEvent({
					name		= GameMessageCode.EVENT_HANDLE_TIPS, 
					itemPos		= index, 
					typeId		= typeId,
					-- mLevel		= itemDef.mNeedParam,
					-- mZLevel		= itemDef.mNeedZsLevel,
					-- iconType    = itemIcon.iconType,
					visible		= true,
					})
				end
				
			end,
		doubleCall = function()
			if itemDef then
				ContainerDiamond.addGem(var.gemTable[items.tag])
				items:getWidgetByName("item_icon"):removeFromParent()
			end
		end
	}
	GUIItem.getItem(param)
	
end

-- 双击背包宝石镶嵌
function ContainerDiamond.addGem(sender)
	local result = {}
	-- local kongIndex = ContainerDiamond.selectKongIndex(sender.mTypeID)
	local kongIndex = ContainerDiamond.selectGemValue(sender.mTypeID,"kongIndex")
	if kongIndex then
		result.pos = sender.position
		result.index = var.curIndex
		result.typeId = sender.mTypeID
		result.kongIndex = kongIndex
		GameSocket:PushLuaTable("gui.ContainerDiamond.handlePanelData",GameUtilSenior.encode({actionid = "insertGem",params = result}))
	end
end

-- function ContainerDiamond.selectKongIndex(typeId)
-- 	local kongIndex = nil
-- 	if typeId >=17020 and typeId <= 17031 then
-- 		kongIndex = 1
-- 	elseif typeId >=17032 and typeId <= 17043 then
-- 		kongIndex = 2
-- 	elseif typeId >=17044 and typeId <= 17055 then
-- 		kongIndex =6
-- 	end
-- 	return kongIndex 	
-- end
-- 宝石商店数据
function ContainerDiamond.updateShopList(sender)
	local idx = sender.tag
	local itemData = tableShop[idx]

	sender:getWidgetByName("labName"):setString(itemData.name)
	sender:getWidgetByName("labPrice"):setString("元宝:"..itemData.vcion)
	local awardItem=sender:getWidgetByName("icon")
	local param={
		-- iconType = GameConst.ICONTYPE.DEPOT,
		parent = awardItem,
		noTips = true,
		typeId = itemData.id,
		callBack = function()
			-- tips显示
			GameSocket:dispatchEvent({
			name		= itemData.name, 
			-- itemPos		= equipTable[pos], 
			typeId		= itemData.id,
			-- mLevel		= itemDef.mNeedParam,
			-- mZLevel		= itemDef.mNeedZsLevel,
			-- iconType    = itemIcon.iconType,
			visible		= true,
			})
		end,
	}
	GUIItem.getItem(param)

	local btnBuy = sender:getWidgetByName("btnBuy")
	btnBuy.index = idx
	GUIFocusPoint.addUIPoint(btnBuy , ContainerDiamond.openAlertBuy)
	-- local function btnBuyClick(item)
	-- 	var.alertBuy = GUIAnalysis.load("ui/layout/AlertBuy.uif")
	-- 	-- :align(display.CENTER, display.cx, display.cy)
	-- 	:addTo(var.xmlPanel)
	-- 	-- local param = {
	-- 	-- 	name = GameMessageCode.EVENT_PANEL_ON_ALERT, panel = "buy", visible = true,
	-- 	-- 	num = 1,
	-- 	-- 	-- type_id = sender.type_id,
	-- 	-- 	-- base = sender.price,
	-- 	-- 	-- maxNum = math.floor( GameSocket.mCharacter[moneyLabel[var.pageIndex].value] /sender.price),
	-- 	-- 	-- confirmTitle = "购买",
	-- 	-- 	-- confirmCallBack = function (mNum)
	-- 	-- 		-- GameSocket:NpcBuy(tag, mNum)
	-- 	-- 		-- GameCCBridge.callPlatformFunc({func="onEvent", eventId="shangcheng", data={name=GameSocket:getItemDefByID(sender.type_id).mName,num=mNum}})
	-- 	-- 	-- end
	-- 	-- }
	-- 	-- GameSocket:dispatchEvent(param)
	-- end
	
end
-- 点击购买 弹出购买面板
function ContainerDiamond.openAlertBuy(item)
	if not var.xmlAlertBuy then
		var.xmlAlertBuy = GUIAnalysis.load("ui/layout/ContainerDiamond_AlertBuy.uif")
				:align(display.CENTER,450,250):addTo(var.xmlPanel)
				:show()
		var.xmlAlertBuy:getWidgetByName("confirmBg"):setTouchEnabled(true)
	else
		var.xmlAlertBuy:show()
	end
	if var.xmlAlertBuy then
		local itemData = tableShop[item.index]
		var.geNum = 1
		var.price = itemData.vcion
		var.xmlAlertBuy:getWidgetByName("lableName"):setString(itemData.name)
		var.xmlAlertBuy:getWidgetByName("lablePrice"):setString(itemData.vcion.."元宝")
		var.xmlAlertBuy:getWidgetByName("text_buyNum"):setString(var.geNum)
		var.xmlAlertBuy:getWidgetByName("text_needMoney"):setString(var.geNum*var.price)
		local awardItem = var.xmlAlertBuy:getWidgetByName("icon")
		param = {
		parent = awardItem,
		typeId = itemData.id,
		visible = true,
		}
		GUIItem.getItem(param)
	end
	ContainerDiamond.initAlertBuyClick()
end
-- btnSub,btnAdd,btnMax,btnCommit,btnCancel,confirmBg,imgBg
function ContainerDiamond.initAlertBuyClick()
	local btnArr = {"btnSub","btnAdd","btnMax","btnCommit","btnCancel","layer_close","imgBg"}
	local vcion = GameSocket.mCharacter.mVCoin
	local function prsBtnClick(sender)
		local btnName = sender:getName()
		-- if btnName=="btnLeft" then
		-- 	if var.geNum>1 then  var.geNum=var.geNum-1 end
		-- 	var.xmlOpenGe:getWidgetByName("labOpenNum"):setString(var.geNum)
		-- elseif btnName=="btnRight" then
		-- 	if var.geNum<(75-GameConst.ITEM_BAG_SIZE-GameSocket.mBagSlotAdd) then  var.geNum=var.geNum+1 end
		-- 	var.xmlOpenGe:getWidgetByName("labOpenNum"):setString(var.geNum)
		-- elseif btnName=="btnOk" then
		
		-- elseif btnName=="btnNo" or btnName=="imgBg" then
		-- 	var.xmlOpenGe:hide()
		-- end
		if btnName == "btnSub" then
			if var.geNum>1 then  var.geNum=var.geNum-1 end
			var.xmlAlertBuy:getWidgetByName("text_buyNum"):setString(var.geNum)
			var.xmlAlertBuy:getWidgetByName("text_needMoney"):setString(var.geNum*var.price)
			
		elseif btnName == "btnAdd" then
			-- if var.geNum<(75-GameConst.ITEM_BAG_SIZE-GameSocket.mBagSlotAdd) then 
			if var.geNum < 999 then
				if vcion - var.geNum*var.price > var.price then  
					var.geNum = var.geNum+1 
				end
			end
			var.xmlAlertBuy:getWidgetByName("text_buyNum"):setString(var.geNum)
			var.xmlAlertBuy:getWidgetByName("text_needMoney"):setString(var.geNum*var.price)
		elseif btnName == "btnMax" then
			if vcion - var.geNum*var.price > var.price then
				var.geNum = math.floor(vcion/var.price)
				if var.geNum >= 999 then 
					var.geNum = 999
				end
			end
			var.xmlAlertBuy:getWidgetByName("text_buyNum"):setString(var.geNum)
			var.xmlAlertBuy:getWidgetByName("text_needMoney"):setString(var.geNum*var.price)
		elseif btnName == "btnCommit" then
		elseif btnName == "btnCancel" or btnName == "imgBg" or btnName == "layer_close" then
			var.xmlAlertBuy:hide()
		-- elseif btnName == "" then
		-- elseif btnName == "" then

		end

	end
	for i=1,#btnArr do
		local btn = var.xmlAlertBuy:getWidgetByName(btnArr[i])
		btn:setTouchEnabled(true)
		GUIFocusPoint.addUIPoint(btn,prsBtnClick)
	end
end
------------------------------------------------------------------------------------------------


return ContainerDiamond
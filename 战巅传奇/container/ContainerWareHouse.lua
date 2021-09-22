local ContainerWareHouse = {}

--局部变量表
local var = {}

local btnSortItem = {
	--["btnSortBag"] 				= {normalTitle = GameConst.str_tidy,},
	["btnSortBag"] 				= {normalTitle = "",},
	--["btnSortDepot"]			= {normalTitle = GameConst.str_tidy,},
	["btnSortDepot"]			= {normalTitle = "",},
	--["btnGetAll"]			    = {normalTitle = GameConst.str_getall,},
	["btnGetAll"]			    = {normalTitle = "",},
	-- ["btnBatchItemsToBag"]		= {normalTitle = GameConst.str_take_out, 	selectTitle = GameConst.str_take_out_canceled,},
	-- ["btnBatchItemsToDepot"]	= {normalTitle = GameConst.str_put_in, 		selectTitle = GameConst.str_put_in_canceled,},
	-- ["btnKz"]			        = {normalTitle = GameConst.str_kz,},
}
local itemsChangeTab = {
	["Depot"]	= {name = "仓库",	xmlPanel = "listDepot", begin = GameConst.ITEM_DEPOT_BEGIN,	titleText = GameConst.str_take_out,	iconType = GameConst.ICONTYPE.DEPOT,},
	["Bag"]		= {name = "包裹",	xmlPanel = "listBag",	begin = GameConst.ITEM_BAG_BEGIN,	titleText = GameConst.str_put_in,	iconType = GameConst.ICONTYPE.DEPOT,},
}

--初始化面板
function ContainerWareHouse.initView()
--初始化局部变量,变量遵循驼峰命名
	var = {
		xmlPanel,
		xmlTipsBag,
		xmlTipsDepot,
		sortType=nil,
	}
	--读取界面xml文件,返回根节点
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerWareHouse.uif") -- cc.XmlLayout:widgetFromXml("ui/layout/ContainerWareHouse/ContainerWareHouse.xml")
	--如果取控件成功
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerWareHouse.handlePanelData)
			-- :addEventListener(GameMessageCode.EVENT_SOLT_CHANGE, ContainerWareHouse.initList)
			:addEventListener(GameMessageCode.EVENT_FRESH_ITEM_PANEL, ContainerWareHouse.initList)
		-- GameUtilSenior.asyncload(var.xmlPanel, "imgBg", "ui/image/img_depot_bg.jpg")
		--按钮调用函数
		local function pushBagButton(pSender)
			local btnName = pSender:getName()
			if btnName == "btnSortBag" then
				--向服务器发送请求,参数“0”整理背包，“1”整理仓库
				var.sortType=0
				GameSocket:SortItem(0)
			elseif btnName == "btnSortDepot" then
				var.sortType=1
				GameSocket:SortItem(1)
			elseif btnName == "btnKz" then
				if (GameConst.ITEM_DEPOT_SIZE +GameSocket.mDepotSlotAdd)>=60 then
					GameSocket:alertLocalMsg("已达当前仓库上线60！", "alert")
				else
					GameSocket:PushLuaTable("gui.ContainerBag.handlePanelData",GameUtilSenior.encode({actionid = "reqOpenDepotGe"}))
				end
			elseif btnName == "btnGetAll" then--全部取出
				ContainerWareHouse.getDepotAll()
			end
		end
		--取按钮控件
		for k, v in pairs(btnSortItem) do
			local btnSort = var.xmlPanel:getWidgetByName(k)
			btnSort:setTitleText(v.normalTitle)
			GUIFocusPoint.addUIPoint(btnSort, pushBagButton)
		end
		
		ContainerWareHouse:updateGameMoney(var.xmlPanel)
		var.xmlPanel:getWidgetByName("box_tab"):setSelectedTab(2)
		var.xmlPanel:getWidgetByName("box_tab"):addTabEventListener(ContainerWareHouse.pushTabButtons)
		
		return var.xmlPanel
	end
end

function ContainerWareHouse.pushTabButtons(sender)
	local opened, level, funcName
	opened = true
	local tag = sender:getTag()
	if tag == 1 then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="menu_bag"})
	elseif tag == 3 then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="menu_recycle"})
	end
end


--金币刷新函数
function ContainerWareHouse:updateGameMoney(event)
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


function ContainerWareHouse.onPanelOpen()
	--初始化背包和仓库列表
	-- ContainerWareHouse.initList()
	var.xmlPanel:getWidgetByName("listDepot"):setSliderVisible(false)
		:reloadData(math.ceil((GameConst.ITEM_DEPOT_SIZE +GameSocket.mDepotSlotAdd)/5)*5,function (subItem)	ContainerWareHouse.updateListByItem(subItem,"Depot") end)
	var.xmlPanel:getWidgetByName("listBag"):setSliderVisible(false)
		:reloadData(GameConst.ITEM_BAG_SIZE + GameSocket.mBagSlotAdd,function (subItem)	ContainerWareHouse.updateListByItem(subItem,"Bag") end)
end

--面板关闭通知函数
function ContainerWareHouse.onPanelClose()
	
end

function ContainerWareHouse.handlePanelData(event)
	if event.type == "ContainerWareHouse" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="openDepotGeZi" then
			GameSocket:AddDepotSlot()
		end
	end
end

--初始化背包、仓库列表
function ContainerWareHouse.initList()
	--获取列表容器
	if var.sortType and var.sortType==1 then
		var.xmlPanel:getWidgetByName("listDepot"):setSliderVisible(false)
			:reloadData(math.ceil((GameConst.ITEM_DEPOT_SIZE +GameSocket.mDepotSlotAdd)/5)*5,function (subItem)	ContainerWareHouse.updateListByItem(subItem,"Depot") end)
	end
	if var.sortType and var.sortType==0 then
		var.xmlPanel:getWidgetByName("listBag"):setSliderVisible(false)
			:reloadData(GameConst.ITEM_BAG_SIZE + GameSocket.mBagSlotAdd,function (subItem)	ContainerWareHouse.updateListByItem(subItem,"Bag") end)
	end
end

--复用列表会根据当前显示范围传来容器,请求对此容器填充内容
function ContainerWareHouse.updateListByItem(subItem,style)
	local index = subItem.tag -1 + itemsChangeTab[style].begin
	local maxNum = 0
	if style=="Depot" then maxNum=GameConst.ITEM_DEPOT_SIZE +GameSocket.mDepotSlotAdd end
	-- if style=="Bag"   then maxNum=GameConst.ITEM_BAG_SIZE + GameSocket.mBagSlotAdd end
	if style=="Bag"   then maxNum=GameConst.ITEM_BAG_SIZE + GameSocket.mBagSlotAdd end
	if subItem.tag > maxNum  then
		subItem:hide()
	else
		subItem:show()
		local paramBag = {
			--物品框容器
			parent = subItem,
			--物品逻辑位置
			pos = index ,
			--传入Tips按钮名
			titleText = itemsChangeTab[style].titleText,
			-- iconType = itemsChangeTab[style].iconType,
			tipsType = GameConst.TIPS_TYPE.DEPOT,
			--传入Tips的位置
			tipsPos = cc.p(display.cx*(style == "Bag" and 0.91 or 1.44), display.height*0.47),
			--物品框点击回调
			callBack = function ()
				--获取物品信息
				-- local netItem = GameSocket:getNetItem(index)
				-- if not netItem then return end
				--调用函数进行物品存入
				-- ContainerWareHouse.showItemExchange({pos = index},style == "Bag" and "Depot" or "Bag")
			end,
			doubleCall = function ()
				local netItem = GameSocket:getNetItem(index)
				if not netItem then return end
				ContainerWareHouse.showItemExchange({pos = index},style == "Bag" and "Depot" or "Bag")
			end,
		}
		GUIItem.getItem(paramBag)
	end
end

--物品存入取出
function ContainerWareHouse.showItemExchange(event,style)
	local number = 40
	if style == "Depot" then
		number = GameConst.ITEM_DEPOT_SIZE + GameSocket.mDepotSlotAdd
	elseif style =="Bag" then
		number = GameConst.ITEM_BAG_SIZE + GameSocket.mBagSlotAdd
	end
	for i = 0, number-1 do
		if not GameSocket:getNetItem(i + itemsChangeTab[style].begin) then
			if GameSocket:getNetItem(event.pos) then
				GameSocket:ItemPositionExchange(event.pos, i + itemsChangeTab[style].begin)
				return
			end
		end
	end
	if style == "Depot" then
		GameSocket:alertLocalMsg(itemsChangeTab[style].name.."空间不足")
	end
end

--全部取出
function ContainerWareHouse.getDepotAll()
	local left_packnum = GameSocket:getLeftBagNum()
	if left_packnum > 0 then
		local textInfo=nil
		local index = 0
		for i=0,39 do
			local netItem = GameSocket:getNetItem(1000+i)
			if netItem then
				GameSocket:UndressItem(1000+i)
				index = index + 1
			end
			if index >= left_packnum then
				GameSocket:alertLocalMsg("已成功提取"..index.."个，背包已满无法继续提取！","alert")
				return
			else
				if index == 0 then
					textInfo = "仓库内没有物品可以提取！"
				else
					textInfo = "已成功提取仓库内所有物品！"
				end
			end
		end
	else
		textInfo = "背包已满无法提取！"
	end
	if textInfo then
		GameSocket:alertLocalMsg(textInfo,"alert")
	end
end


return ContainerWareHouse
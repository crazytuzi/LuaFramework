local ContainerConsignment = {}
local var = {}
local pageKeys = {
	"buy", "sale", "shelf",
}

local consignHint = {
	["buy"] = {
		title = "购买说明",
		tips = {
			"<font color=#18d129 size=18>购买说明</font>",
			'1．每次公共购买，卖家需要支付5% 的交易税，不足1元宝按1元宝计算， 最大为200元宝',
			'2．使用搜索栏或者筛选条件可以快速找到想要的物品',
		}
		
	},
	["sale"] = {
		title = "寄售说明",
		tips = {
			"<font color=#18d129 size=18>寄售说明</font>",
			'1．绑定物品无法出售',
			'2．出售物品需要按照时间扣除相应的手续费，出售时间越长，手续费也越多',
		}
	},
	["shelf"] = {
		title = "货架说明",
		tips = {
			"<font color=#18d129 size=18>货架说明</font>",
			'1．自己出售的所有物品都在我的货架中展示',
			'2．下架可以取消正在出售中的物品，下架物品可以自动进入到背包内',
			'3．手动下架物品，手续费不退还',
			'4．剩余寄售时间为0时，玩家可以从我的货架中取出',
		}
	}
}

local MAX_PRICE = 2000000000 --"寄售行上架元宝总价上限"
local MAXSELLNUM= 100000--"寄售行上架物品数量上限"
local MIN_PRICE=  1--"寄售行上架物品最低单价（元宝）"
local CONSIGNMEMT_PAGE_SIZE = 5 --每页数量
local DEFAULT_SALE_TIME = 12  --默认销售时间
local function checkData(param)
	if not (param.mType and param.mType == var.buyFilterType)then
		return false
	end
	if not (param.job and param.job == 0 or param.job == var.buyFilterJob) then
		return false
	end
	if not (param.condition and param.condition == var.buyLevelLimit) then
		return false
	end
	return true
end

local function formatTime(second)
	local cal_time = second
	local hour = math.floor(cal_time/(60*60))
	cal_time = cal_time%(60*60)
	local minute = math.floor(cal_time/60)
	cal_time = cal_time%60
	return hour.."小时"..minute.."分钟"
end

local function hideAllPages()
	local pageName
	for i,v in ipairs(pageKeys) do
		pageName = "xmlPage"..string.ucfirst(v)
		if var[pageName] then
			var[pageName]:hide()
		end
	end
end
 -- page变量，初始化函数，刷新函数使用字符窜拼接
local function showPanelPage(key)
	if not (key and table.indexof(pageKeys, key))then return end
	hideAllPages()
	local pageName = "xmlPage"..string.ucfirst(key)
	local initFunc = "initPage"..string.ucfirst(key)
	local openFunc = "openPage"..string.ucfirst(key)
	if not var[pageName] and ContainerConsignment[initFunc] then
		ContainerConsignment[initFunc]()
	end
	if var[pageName] then
		if ContainerConsignment[openFunc] then
			ContainerConsignment[openFunc]()
			var.xmlPanel:getWidgetByName("btn_consign_tips").key = key
			var.xmlPanel:getWidgetByName("lbl_consign_tips"):setString(consignHint[key].title)--:setColor(GameBaseLogic.getColor(#18d129))
		end
		var[pageName]:show()
	end
end

local function pushTabButtons(sender)
	-- hideAllPages()
	local tag = sender:getTag()
	if pageKeys[tag] then
		showPanelPage(pageKeys[tag])
	end
end

local function handlePanelData(event)
	if event.type=="ContainerConsignmentRedPoint" then 
		local data=GameUtilSenior.decode(event.data)
		var.consignredpoint=data.visible
		ContainerConsignment.updateRedPoint()
		--print("0000000000000000000000000")
	end
end

---------------------------------------以上为内部函数---------------------------------------
function ContainerConsignment.initView(event)
	var = {
		boxTab,
		xmlPanel,
		panelBg,

		xmlPageBuy,
		xmlPageSale,
		xmlPageShelf,
		-- 寄售相关
		sellPrice,
		sellNum,
		sellPos,
		sellTime,
		inputNumBlock,
		inputPriceBlock,
		maxSellNum,

		canConsignItems = {},
		
		--购买相关
		buyFilterType,
		buyFilterJob,
		buyLevelLimit,
		buyFilterKey = "",

		showFilterLv,
		buyItemSeedId,
		mSelectedItemIndex,

		buyBeginIndex,
		buyConsignItems,

		-- shelfBeginIndex,
		shelfConsignItems,
		consignredpoint,
	}

	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerConsignment.uif")

	if var.xmlPanel then
		
		var.xmlPanel:getWidgetByName("lbl_consign_tips"):setString("寄售说明")
		local btnConsignTips = var.xmlPanel:getWidgetByName("btn_consign_tips"):addTouchEventListener(function (pSender, touchType)
			if touchType == ccui.TouchEventType.began then
				GameSocket:dispatchEvent({
					name = GameMessageCode.EVENT_PANEL_ON_ALERT, panel = "tips", visible = true, infoTable = consignHint[pSender.key].tips,
				})
			elseif touchType == ccui.TouchEventType.ended or touchType == ccui.TouchEventType.canceled  then
				GameSocket:dispatchEvent({
					name = GameMessageCode.EVENT_PANEL_ON_ALERT, panel = "all", visible = false })
			end
		end)

		var.panelBg = var.xmlPanel:getWidgetByName("panel_bg")
		var.boxTab = var.xmlPanel:getWidgetByName("box_tab")
		var.boxTab:addTabEventListener(pushTabButtons)

		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, handlePanelData)
		return var.xmlPanel
	end
end

function ContainerConsignment.onPanelOpen(extend)
	if extend and extend.tab then
		if extend.tab == 1 then
			var.boxTab:setSelectedTab(1)
		else
			var.boxTab:setSelectedTab(2)
		end
		if extend.tab == 3 then
			showPanelPage("shelf")
		end
	else
		var.boxTab:setSelectedTab(1)
	end

	GameSocket:PushLuaTable("gui.moduleRedPoint.handlePanelData",GameUtilSenior.encode({actionid = "ConsignRedPoint",params = {}}))	
end

function ContainerConsignment.onPanelClose()
	
end

function ContainerConsignment.updateRedPoint()
	if var.xmlPageSale then
			--print("0000000000000000000000000",var.consignredpoint)
		local btnMyShelf = var.xmlPageSale:getWidgetByName("btn_my_shelf")
		if  var.consignredpoint then 
			GUIFocusDot.addRedPointToTarget(btnMyShelf)
		else
			-- if btnMyShelf:getWidgetByName("redPoint") then 
			-- 	btnMyShelf:getWidgetByName("redPoint"):setVisible(false)
			-- end
			btnMyShelf:removeChildByName("redPoint")
		end
	end

	if var.xmlPageShelf then
		local btnGetVcoin = var.xmlPageShelf:getWidgetByName("btn_get_vcoin")
		if  var.consignredpoint then 
			GameUtilSenior.addHaloToButton(btnGetVcoin, "btn_normal_light.png")------呼吸灯
		else
			btnGetVcoin:removeChildByName("img_bln")
		end
	end
end

--------------------------------------购买--------------------------------------
local filterButtons = {
	["btn_filter_all"] 		= {mType = 0}, 
	["btn_filter_equip"]	= {mType = 1}, 
	["btn_filter_drug"] 	= {mType = 2}, 
	["btn_filter_material"] = {mType = 3}, 
	["btn_filter_other"] 	= {mType = 4},
}

local filterLevelButtons = {
	["btn_filter_level1"] = {mLvType = 1,mName = "100阶以下"},
	["btn_filter_level2"] = {mLvType = 2,mName = "110阶以下"},
	["btn_filter_level3"] = {mLvType = 3,mName = "120阶以下"},
	["btn_filter_level4"] = {mLvType = 4,mName = "130阶以下"},
	["btn_filter_level5"] = {mLvType = 5,mName = "140阶以下"},
	["btn_filter_level6"] = {mLvType = 6,mName = "150阶以下"},
	["btn_filter_level7"] = {mLvType = 7,mName = "160阶以下"},
	["btn_filter_level8"] = {mLvType = 8,mName = "170阶以下"},
	["btn_filter_level9"] = {mLvType = 9,mName = "180阶以下"},
	["btn_filter_level10"] = {mLvType = 0,mName = "全部等级"},
}

local pageBuyButton = {
	"btn_pull_down", "btn_only_career", "btn_clean_search", "btn_search", "btn_buy", "btn_sell", "pre_btn", "next_btn"
}

local function reqConsignItemList()
	-- 	int type; // 0:全部 1:装备 2:药品 3:材料 4:其他 5:自己
	-- 	int begin_index; // 开始查找索引
	-- 	int job; // 职业
	-- 	int condition; // 等级条件 0 全部 1:0-80 2:80-2转 3:2转以上
	local param = {
		type = var.buyFilterType,
		index = var.buyBeginIndex, 
		job = var.buyFilterJob,
		level = var.buyLevelLimit,
		filter = var.buyFilterKey
	}

	GameSocket:reqConsignableItems(param)
end

local function resetBuyParam()
	var.buyItemSeedId = -1
	var.buyBeginIndex = 0
	var.mSelectedItemIndex = -1
	-- var.buyConsignItems = {}

	-- var.xmlPageBuy:getWidgetByName("list_buy"):removeAllData()
	reqConsignItemList()
end

local function updateButtonCareer()
	var.xmlPageBuy:getWidgetByName("btn_only_career"):setBrightStyle((var.buyFilterJob == 0) and ccui.BrightStyle.normal or ccui.BrightStyle.highlight)
	resetBuyParam()
	-- reqConsignItemList()
end

local function pushFilterButton(sender)
	var.buyBeginIndex = 0
	
	local btnName = sender:getName()
	local btnFilter
	for k,v in pairs(filterButtons) do
		var.xmlPageBuy:getWidgetByName(k):setBrightStyle(ccui.BrightStyle.normal)
	end
	if filterButtons[btnName] then
		var.buyFilterType = filterButtons[btnName].mType
		sender:setBrightStyle(ccui.BrightStyle.highlight)
	end
	resetBuyParam()
	-- reqConsignItemList()
end

local function initBuyFilterKey()
	var.buyFilterKey = ""
	var.xmlPageBuy:getWidgetByName("edit_filter_key"):setText(var.buyFilterKey)
end

local function updateSelectedConsignItem(visible)
	local listBuy = var.xmlPageBuy:getWidgetByName("list_buy")
	if not listBuy then return end
	if not var.mSelectedItemIndex then return end
	local item = listBuy:getModelByIndex(var.mSelectedItemIndex)
	if not item then return end
	item:getChildByName("img_selected_box"):setVisible(visible)
end

function ContainerConsignment.openPageBuy()
	var.xmlPanel:getWidgetByName("lbl_consign_tips"):setString("寄售说明")
	pushFilterButton(var.xmlPageBuy:getWidgetByName("btn_filter_all"))
end

function ContainerConsignment.initPageBuy()
	var.buyBeginIndex = 0
	
	local function handleFilterLevelVisible()
		local btnPullDown = var.xmlPageBuy:getWidgetByName("btn_pull_down")
		var.xmlPageBuy:getWidgetByName("box_filter_level"):setVisible(var.showFilterLv)
		-- btnPullDown:setRotation(var.showFilterLv and 180 or 0)
		if var.showFilterLv then
			btnPullDown:loadTextures("btn_pull_up", "btn_pull_up", "", ccui.TextureResType.plistType)
		else
			btnPullDown:loadTextures("btn_pull_down", "btn_pull_down", "", ccui.TextureResType.plistType)
		end
	end

	local function pushFilterLevel(sender)
		local btnName = sender:getName()
		if filterLevelButtons[btnName] then
			var.xmlPageBuy:getWidgetByName("lbl_filter_level_value"):setString(filterLevelButtons[btnName].mName)
			var.buyLevelLimit = filterLevelButtons[btnName].mLvType
			var.showFilterLv = false
			handleFilterLevelVisible()
			resetBuyParam()
			-- reqConsignItemList()
		end
	end

	local function pushPageBuyButton(sender)
		local btnName = sender:getName()
		if btnName == "btn_pull_down" then
			var.showFilterLv = not var.showFilterLv
			handleFilterLevelVisible()
		elseif btnName == "btn_only_career" then
			if var.buyFilterJob == 0 then
				var.buyFilterJob = GameCharacter._mainAvatar:NetAttr(GameConst.net_job)
			else
				var.buyFilterJob = 0
			end
			updateButtonCareer()
		elseif btnName == "btn_clean_search" then
			initBuyFilterKey()
		elseif btnName == "btn_search" then
			reqConsignItemList()
		elseif btnName == "pre_btn" then
			var.buyBeginIndex = var.buyBeginIndex - CONSIGNMEMT_PAGE_SIZE
			if var.buyBeginIndex<0 then
				var.buyBeginIndex = 0
			end
			reqConsignItemList()
		elseif btnName == "next_btn" then
			var.buyBeginIndex = var.buyBeginIndex + CONSIGNMEMT_PAGE_SIZE
			reqConsignItemList()
		elseif btnName == "btn_sell" then
			showPanelPage("sale")
		elseif btnName == "btn_buy" then
			--print("buyConsignItems", var.buyItemSeedId)
			if var.buyItemSeedId >= 0 then
				local mParam = {
					name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", lblConfirm = "购买需要充值金额达到500元,否则无法购买，是否继续？",
					btnConfirm = "是", btnCancel = "否",
					confirmCallBack = function ()
						GameSocket:reqBuyConsignItem({
							mSeedId = var.buyItemSeedId
						})
					end
				}
				GameSocket:dispatchEvent(mParam)
			else
				GameSocket:alertLocalMsg("请先选择购买物品!", "alert")
			end
		end
	end

	local consignItem

	local function pushBuyItem(item)
		-- print("//////////////pushBuyItem/////////////", item.index)
		consignItem = var.buyConsignItems[item.index]
		var.buyItemSeedId = consignItem.mSeedId
		if var.mSelectedItemIndex then
			updateSelectedConsignItem(false)
		end
		var.mSelectedItemIndex = item.index

		updateSelectedConsignItem(true)

		--显示tips
		if not consignItem then return end
		-- print("on Click ConsignItem item", consignItem.mTypeID, consignItem.mLevel, consignItem.mZLevel)
		GameSocket:dispatchEvent({
			name		= GameMessageCode.EVENT_HANDLE_TIPS, 
			-- itemPos		= itemIcon.itemPos, 
			typeId		= consignItem.mTypeID,
			mLevel		= consignItem.mLevel,
			mZLevel		= consignItem.mZLevel,
			-- iconType    = itemIcon.iconType,
			-- tipsType	= itemIcon.tipsType,
			-- customCallFunc = itemIcon.customCallFunc,
			-- destoryCallFunc = itemIcon.destoryCallFunc,
			visible		= true,
			-- compare		= itemIcon.compare,
			-- enmuPos 	= itemIcon.enmuPos,
			-- enmuItemType = itemIcon.enmuItemType,
		})
	end

	local index, imgItemBg
	
	local function updateBuyItem(item)
		index = item.tag
		consignItem = var.buyConsignItems[index]
		if not consignItem then return end
		imgItemBg = item:getWidgetByName("img_item_bg")
		local lblItemName = item:getWidgetByName("lbl_item_name")
		local param = {
			parent = imgItemBg,
			iconType = GameConst.ICONTYPE.DEPOT,
			typeId = consignItem.mTypeID,
			mLevel = consignItem.mLevel,
			mZLevel= consignItem.mZLevel,
			updateDesp = function (itemdef)
				-- print("///////////updateBuyItem//////////", itemdef.mName)
				lblItemName:setString(itemdef.mName)
			end
		}
		
		GUIItem.getItem(param)
		imgItemBg:setTouchEnabled(false)

		item:getWidgetByName("lbl_item_num"):setString(consignItem.mNumber)
		item:getWidgetByName("lbl_item_price"):setString(consignItem.mPrice)
		item:getWidgetByName("lbl_time_remain"):setString(formatTime(consignItem.mTimeLeft))

		item.index = index
		item:setTouchEnabled(true)
		item:getChildByName("img_selected_box"):setVisible(item.index == var.mSelectedItemIndex)

		GUIFocusPoint.addUIPoint(item, pushBuyItem)
	end

	local function updateListBuy()
		local listBuy = var.xmlPageBuy:getWidgetByName("list_buy")
		listBuy:reloadData(#var.buyConsignItems, updateBuyItem)
	end

	local function onConsignData(event)
		local param = event.param
		-- print('////////////onConsignData buy//////////////', param.mType, param.condition, param.job);
		if param and checkData(param) and param.mType < 5 then
			local items = param.items
			var.buyConsignItems = {}
			-- print("onConsignData", var.buyBeginIndex, #items, param.endIndex)
			if GameUtilSenior.isTable(items) then
				for i,v in ipairs(items) do
					table.insert(var.buyConsignItems, v)
				end
				-- var.buyBeginIndex = param.endIndex
			end
			--updateListBuy()
			
			if #var.buyConsignItems>0 or var.buyBeginIndex<1 then
				updateListBuy()
			else
				var.buyBeginIndex = var.buyBeginIndex - CONSIGNMEMT_PAGE_SIZE
			end
		end
	end

	local function onBuyConsignResult(event)
		var.buyBeginIndex = 0
		reqConsignItemList()
	end

	var.xmlPageBuy = GUIAnalysis.load("ui/layout/ContainerConsignment_buy.uif")
	if var.xmlPageBuy then
		GameUtilSenior.asyncload(var.xmlPageBuy, "page_buy_bg", "")
		var.xmlPageBuy:getWidgetByName("page_buy_bg"):setTouchEnabled(true):setSwallowTouches(true)
		var.xmlPageBuy:align(display.LEFT_BOTTOM, 10, 10):addTo(var.panelBg)

		local btnPageBuy
		for _,v in ipairs(pageBuyButton) do
			btnPageBuy = var.xmlPageBuy:getWidgetByName(v)
			if btnPageBuy then
				GUIFocusPoint.addUIPoint(btnPageBuy, pushPageBuyButton)
			end
		end

		for k,v in pairs(filterLevelButtons) do
			btnPageBuy = var.xmlPageBuy:getWidgetByName(k)
			if btnPageBuy then
				GUIFocusPoint.addUIPoint(btnPageBuy, pushFilterLevel)
			end
		end

		for k,v in pairs(filterButtons) do
			btnPageBuy = var.xmlPageBuy:getWidgetByName(k)
			if btnPageBuy then
				GUIFocusPoint.addUIPoint(btnPageBuy, pushFilterButton)
			end
		end

		local boxFilterLevel = var.xmlPageBuy:getWidgetByName("box_filter_level"):setTouchEnabled(true)
		boxFilterLevel:addClickEventListener(function ()
			var.showFilterLv = false
			handleFilterLevelVisible()
		end)

		local lblFilterKey = var.xmlPageBuy:getWidgetByName("lbl_filter_key"):hide()
		local imgEditboxKey = var.xmlPageBuy:getWidgetByName("img_editbox_key")

		local function endCallFunc(inputText)
			if inputText then
				var.buyFilterKey = inputText
				var.xmlPageBuy:getWidgetByName("edit_filter_key"):setText(var.buyFilterKey)
			end
			-- print("endCallFunc", inputText)
		end

		local param = {
			bindLabel = lblFilterKey,
			parent = imgEditboxKey,
			color = 0xFFCC00,
			fontSize = 20,
			-- inputMode = cc.EDITBOX_INPUT_MODE_ANY,
			endCallFunc = endCallFunc,
		}
		-- print("//////////////////////////////////onInitPageBuy", lblFilterKey, imgEditboxKey)
		local editBoxFilterKey = GameUtilSenior.newCustomEditBox(param)
		editBoxFilterKey:setName("edit_filter_key")

		var.buyItemSeedId = -1
		var.mSelectedItemIndex = -1
		var.buyFilterType = 0
		var.buyFilterJob = 0
		var.showFilterLv = false
		var.buyBeginIndex = 0

		var.buyLevelLimit = 0

		handleFilterLevelVisible()
		cc.EventProxy.new(GameSocket, var.xmlPageBuy)
			:addEventListener(GameMessageCode.EVENT_CONSIGN_LIST, onConsignData)
			:addEventListener(GameMessageCode.EVENT_CONSIGN_BUY_RESULT, onBuyConsignResult)
	end
end
--------------------------------------出售--------------------------------------

local consignTime = {
	["btn_sell_1"] = 12,
	["btn_sell_2"] = 24,
	["btn_sell_3"] = 48,
}

local buttonOnSale = {
	"btn_add_consign", "btn_reset", "btn_my_shelf"
}
local function updateSaleNumAndPrice()
	local totalPrice = var.sellNum * var.sellPrice

	var.xmlPageSale:getWidgetByName("edit_sell_price"):setText(var.sellPrice)
	var.xmlPageSale:getWidgetByName("edit_sell_num"):setString(var.sellNum)
	var.xmlPageSale:getWidgetByName("lbl_total_price"):setString(totalPrice.." 充值点")
end

local function updateSaleItem(pos)
	var.sellPrice = 0
	var.maxSellNum = 0
	var.sellPos = -999
	var.sellTime = DEFAULT_SALE_TIME

	local btnSellTime
	for k,v in pairs(consignTime) do
		btnSellTime = var.xmlPageSale:getWidgetByName(k)
		-- print("pushSellTimeButton", k, btnSellTime)
		if btnSellTime then
			btnSellTime:setBrightStyle(ccui.BrightStyle.normal)
		end
	end

	local netItem = GameSocket:getNetItem(pos) 
	local itemDef

	if netItem then
		var.sellPos = pos
		itemDef = GameSocket:getItemDefByID(netItem.mTypeID)
		var.maxSellNum = netItem.mNumber
	end
	
	local lblItemName = var.xmlPageSale:getWidgetByName("lbl_item_name")
	local imgItemIcon = var.xmlPageSale:getWidgetByName("img_item_icon")
	if itemDef then
		var.sellNum = 1
		lblItemName:setString(itemDef.mName)
		local path = "image/icon/"..itemDef.mIconID..".png"
		asyncload_callback(path, imgItemIcon, function(path, texture)
			imgItemIcon:loadTexture(path)
		end)
	else
		var.sellNum = 0
		lblItemName:setString("")
		imgItemIcon:loadTexture("null", ccui.TextureResType.plistType)
	end
	updateSaleNumAndPrice()
end

local function updateBagItem(item)
		local index = item.tag
		local itemPos = var.canConsignItems[index]
		local param = {
			tipsType = GameConst.TIPS_TYPE.CONSIGN,
			parent = item,
			pos = itemPos,
			customCallFunc = function()
				print("callBack", itemPos)
				updateSaleItem(itemPos)
			end,
		}
		GUIItem.getItem(param)
	end

function ContainerConsignment.openPageSale()
	updateSaleItem()
	ContainerConsignment.updateRedPoint()
	var.canConsignItems = {}

	local netItem
	for pos = GameConst.ITEM_BAG_BEGIN, GameConst.ITEM_BAG_BEGIN + GameConst.ITEM_BAG_SIZE + GameSocket.mBagSlotAdd - 1 do
		netItem = GameSocket:getNetItem(pos)
		if netItem and not (bit.band(netItem.mItemFlags, GameConst.ITEM_FLAG_BIND) > 0)then
			table.insert(var.canConsignItems, pos)
		end
	end
	var.xmlPageSale:getWidgetByName("list_bag"):reloadData(GameConst.ITEM_BAG_MAX, updateBagItem,nil,false)
end

function ContainerConsignment.initPageSale()

	-- local function initBagList()
		--获取列表容器
		-- local listBag = var.xmlPageSale:getWidgetByName("list_bag"):setSliderVisible(false)
		-- listBag:reloadData(GameConst.ITEM_BAG_MAX, updateBagItem,nil,false)
	-- end

	-- 鉴于价格输入框和文本输入框功能类似，增加统一创建函数
	local function createEditBox(parent, bindLabel, endCallFunc)
		local inputText
		local function onEdit(event,editBox)
			-- print("onEdit///////////////", event, editBox:getText())
			if event == "began" then
				-- bindLabel:hide()
				-- editBox:setText("")
			elseif event == "changed" then

			elseif event == "ended" then
			elseif event == "return" then
				inputText = editBox:getText()
				if inputText ~= "" then
					-- editBox:setText("")
					endCallFunc(inputText)
				end
				-- bindLabel:show()
			end
		end

		local pSize = parent:getContentSize()

		local numInput = GameUtilSenior.newEditBox({
			name = "numInput",
			image = "#null",
			size = pSize,
			listener = onEdit,
			color = GameBaseLogic.getColor(0xFDDFAE),
			x = 0,
			y = 0,
			fontSize = 20,
			inputMode = cc.EDITBOX_INPUT_MODE_NUMERIC
		})

		numInput:align(display.BOTTOM_LEFT,30,0)
			:setPlaceHolder("")
			:addTo(parent)
			:setText("")

		local inputBlock = ccui.Widget:create()
			:setContentSize(pSize)
			:align(display.LEFT_BOTTOM, 30, 0)
			:addTo(parent)
		inputBlock:setSwallowTouches(true)

		numInput.block = inputBlock

		return numInput
	end

	local function initEditBox()
		local parent = var.xmlPageSale:getWidgetByName("img_input_price_bg")
		local lblSellPrice = var.xmlPageSale:getWidgetByName("lbl_sell_price"):hide()

		local editBox = createEditBox(parent, lblSellPrice, function (inputText)
			if inputText and tonumber(inputText) then
				if tonumber(inputText) > MAX_PRICE then
					GameSocket:alertLocalMsg("出售单价不可高于"..MAX_PRICE.."!", "alert")
					inputText = MAX_PRICE
				end
				if tonumber(inputText) < MIN_PRICE then
					GameSocket:alertLocalMsg("出售单价不可低于"..MIN_PRICE.."!", "alert")
					inputText = MIN_PRICE
				end
				var.sellPrice = math.ceil(tonumber(inputText))
				updateSaleNumAndPrice()
			end
		end)

		if editBox then
			editBox:setName("edit_sell_price")
			var.inputPriceBlock = editBox.block
		end

		parent = var.xmlPageSale:getWidgetByName("img_input_num_bg")
		local lblSellNum = var.xmlPageSale:getWidgetByName("lbl_sell_num"):hide()

		editBox = createEditBox(parent, lblSellNum, function (inputText)
			if inputText and tonumber(inputText) then
				if tonumber(inputText) > MAXSELLNUM then
					GameSocket:alertLocalMsg("超出最大寄售数量!", "alert")
					inputText = MAXSELLNUM
				elseif tonumber(inputText) < 1 then
					GameSocket:alertLocalMsg("低于最小寄售数量!", "alert")
					inputText = 1
				elseif tonumber(inputText) > var.maxSellNum then
					GameSocket:alertLocalMsg("超出最大寄售数量!", "alert")
					inputText = var.maxSellNum
				end
				var.sellNum = math.ceil(tonumber(inputText))
				updateSaleNumAndPrice()
			end
		end)

		if editBox then
			editBox:setName("edit_sell_num")
			var.inputNumBlock = editBox.block

			GUIFocusPoint.addUIPoint(var.xmlPageSale:getWidgetByName("btn_input_num"), function (pSender)
				if editBox then 
					editBox:touchDownAction(editBox, ccui.TouchEventType.ended)
				end
			end)
		end
	end

	local function pushSellTimeButton(sender)
		local btnName = sender:getName()
		local btnSellTime
		for k,v in pairs(consignTime) do
			btnSellTime = var.xmlPageSale:getWidgetByName(k)
			-- print("pushSellTimeButton", k, btnSellTime)
			if btnSellTime then
				btnSellTime:setBrightStyle(k == btnName and ccui.BrightStyle.highlight or ccui.BrightStyle.normal)
			end
		end

		if consignTime[btnName] then
			local totalPrice = var.sellNum * var.sellPrice
			var.sellTime = consignTime[btnName]
			if var.sellTime==12  then
				var.xmlPageSale:getWidgetByName("lbl_procedure_fee"):setString("寄售行12小时手续费金币数")		
			elseif var.sellTime==24  then
				var.xmlPageSale:getWidgetByName("lbl_procedure_fee"):setString("寄售行24小时手续费金币数")	
			elseif var.sellTime==48  then
				var.xmlPageSale:getWidgetByName("lbl_procedure_fee"):setString("寄售行48小时手续费金币数")	
			end
		end
	end

	local function pushPageSaleButton(sender)
		local btnName = sender:getName()
		if btnName == "btn_add_consign" then
			if (not var.sellPos) or var.sellPos < 0 then
				return GameSocket:alertLocalMsg("请选择寄售物品", "alert")
			end
			if (not var.sellPrice) or var.sellPrice < 1 then
				return GameSocket:alertLocalMsg("请输入出售单价", "alert")
			end
			if (not var.sellTime) or var.sellTime < 1 then
				return GameSocket:alertLocalMsg("请选择寄售时间", "alert")
			end
			if (not var.sellNum) or var.sellNum < 1 then
				return GameSocket:alertLocalMsg("请选择寄售数量", "alert")
			end
			if var.sellPos >= 0 and var.sellTime > 0 and var.sellNum > 0 then
				GameSocket:consignItem({pos = var.sellPos, num = var.sellNum, price = var.sellPrice, time = var.sellTime})
			end
			updateSaleItem()
		elseif btnName == "btn_reset" then
			updateSaleItem()
		elseif btnName == "btn_my_shelf" then
			showPanelPage("shelf")
		end
	end

	-- -1:无此物品 0:成功 1:手续费不够 2:绑定物品不可寄售
	local function onConsignResult(event)
		if event and event.ret then
			if event.ret == -1 then
				GameSocket:alertLocalMsg("数量不足", "alert")
			elseif event.ret == 0 then
				GameSocket:alertLocalMsg("寄售成功", "alert")
			elseif event.ret == 1 then
				GameSocket:alertLocalMsg("手续费不够", "alert")
			elseif event.ret == 2 then
				GameSocket:alertLocalMsg("绑定物品不可寄售", "alert")
			elseif event.ret == 4 then
				GameSocket:alertLocalMsg("充值未满500元，无法出售", "alert")
			end
		end
	end

	local function updateGameMoney()
		if var.xmlPageSale then
			local mainrole = GameSocket.mCharacter
			local moneyLabel = {
				{name="lbl_vcoin_num",	value =	mainrole.mVCoin or 0	,	},
				{name="lbl_game_money",	value =	mainrole.mGameMoney or 0,	},
			}

			--建临时表遍历设属性
			for _,v in ipairs(moneyLabel) do
				var.xmlPageSale:getWidgetByName(v.name):setString(v.value)
			end
		end
	end

	var.xmlPageSale = GUIAnalysis.load("ui/layout/ContainerConsignment_sale.uif")
	if var.xmlPageSale then
		GameUtilSenior.asyncload(var.xmlPageSale, "page_sale_bg", "")
		var.xmlPageSale:align(display.LEFT_BOTTOM, 10, 10):addTo(var.panelBg)

		local btnPagSale
		for _,v in ipairs(buttonOnSale) do
			btnPagSale = var.xmlPanel:getWidgetByName(v)
			if btnPagSale then
				GUIFocusPoint.addUIPoint(btnPagSale, pushPageSaleButton)
			end
		end
		
		
		for k,v in pairs(consignTime) do
			btnPagSale = var.xmlPageSale:getWidgetByName(k)
			if btnPagSale then
				btnPagSale:getTitleRenderer():setAdditionalKerning(0)
				GUIFocusPoint.addUIPoint(btnPagSale, pushSellTimeButton)
			end
		end

		--var.xmlPageSale:getWidgetByName("btn_input_num")--:setSwallowTouches(false)

		local lblVcoinNum = var.xmlPageSale:getWidgetByName("lbl_vcoin_num")
		local lblGameMoney = var.xmlPageSale:getWidgetByName("lbl_game_money")
		var.xmlPageSale:getWidgetByName("list_bag"):setSliderVisible(false)
		updateGameMoney()
		
		var.sellPrice = 0
		var.maxSellNum = 0
		var.sellPos = -999
		var.sellTime = DEFAULT_SALE_TIME

		initEditBox()
		-- initBagList()
		updateSaleItem()

		-- GameSocket:consignItem({pos = 1, num = 1, price = 20, time = 12})
		cc.EventProxy.new(GameSocket, var.xmlPageSale)
			:addEventListener(GameMessageCode.EVENT_CONSIGN_RESULT, onConsignResult)
			:addEventListener(GameMessageCode.EVENT_GAME_MONEY_CHANGE, updateGameMoney)
	end
end
--------------------------------------货架--------------------------------------

local function reqConsignShelf()
	local param = {
		type = 5,
		index = var.buyBeginIndex, 
		job = 0,
		level = 0,
		filter = "",
	}
	GameSocket:reqConsignableItems(param)
end

function ContainerConsignment.openPageShelf()
	reqConsignShelf()
	ContainerConsignment.updateRedPoint()
end

function ContainerConsignment.initPageShelf()
	local shelfItem
	
	var.buyBeginIndex = 0

	-- 请求下架
	local function pushOffShelfButton(sender)
		shelfItem = var.shelfConsignItems[sender.index]
		-- print("reqTakeBackConsignableItem", shelfItem.mSeedId)
		if shelfItem.mTimeLeft<=0 then
			GameSocket:reqTakeBackConsignableItem({mSeedId = shelfItem.mSeedId})
		else
			local mParam = {
				name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", lblConfirm = "下架手续费不退，是否继续？",
				btnConfirm = "是", btnCancel = "否",
				confirmCallBack = function ()
					GameSocket:reqTakeBackConsignableItem({mSeedId = shelfItem.mSeedId})
				end
			}
			GameSocket:dispatchEvent(mParam)
		end
	end

	local index, imgItemBg, btnOffShelf, timeRemian
	
	local function updateShelfItem(item)
		index = item.tag
		shelfItem = var.shelfConsignItems[index]
		imgItemBg = item:getWidgetByName("img_item_bg")
		local lblItemName = item:getWidgetByName("lbl_item_name")
		local param = {
			parent = imgItemBg,
			iconType = GameConst.ICONTYPE.DEPOT,
			typeId = shelfItem.mTypeID,
			mLevel = shelfItem.mLevel,
			mZLevel= shelfItem.mZLevel,
			updateDesp = function (itemdef)
				-- print("///////////updateShelfItem//////////", itemdef.mName)
				lblItemName:setString(itemdef.mName)
			end
			-- doubleCall = function ()
			-- 	-- convertGuildItem(item.tag)
			-- end
		}
		GUIItem.getItem(param)

		item:getWidgetByName("lbl_item_num"):setString(shelfItem.mNumber)
		item:getWidgetByName("lbl_item_price"):setString(shelfItem.mPrice)
		timeRemian = shelfItem.mTimeLeft > 0 and shelfItem.mTimeLeft or 0
		item:getWidgetByName("lbl_time_remain"):setString(formatTime(timeRemian))
			
		btnOffShelf = item:getWidgetByName("btn_off_shelf")
		btnOffShelf.index = index
		GUIFocusPoint.addUIPoint(btnOffShelf, pushOffShelfButton)
	end

	local function updateListShelf()
		local listShelf = var.xmlPageShelf:getWidgetByName("list_shelf")
		listShelf:reloadData(#var.shelfConsignItems, updateShelfItem)
	end

	local function onConsignData(event)
		local param = event.param
		-- print("onConsignData///////////////", param.mType, param.job, param.condition)
		if param and param.job == 0 and param.condition == 0 and param.mType == 5 then
			local items = param.items
			var.shelfConsignItems = {}
			if GameUtilSenior.isTable(items) then
				for i,v in ipairs(items) do
					table.insert(var.shelfConsignItems, v)
				end
			end
			--updateListShelf()
			
			if #var.shelfConsignItems>0 or var.buyBeginIndex<1 then
				updateListShelf()
			else
				var.buyBeginIndex = var.buyBeginIndex - CONSIGNMEMT_PAGE_SIZE
			end
		end
	end

	local function onTakeBackConsignItem(event)
		print("//////////////////////", event.ret, event.mSeedId)
		reqConsignShelf()
	end

	local function onTakeBackConsignVcoin(event)
		print("//////////////////////", event.ret)
	end

	var.xmlPageShelf = GUIAnalysis.load("ui/layout/ContainerConsignment_shelf.uif")
	if var.xmlPageShelf then
		GameUtilSenior.asyncload(var.xmlPageShelf, "page_shelf_bg", "")
		var.xmlPageShelf:align(display.LEFT_BOTTOM, 10, 10):addTo(var.panelBg)

		local btnBackSale = var.xmlPageShelf:getWidgetByName("btn_back_sale")
		GUIFocusPoint.addUIPoint(btnBackSale, function (sender)
			showPanelPage("sale")
		end)
		
		GUIFocusPoint.addUIPoint(var.xmlPageShelf:getWidgetByName("btn_back_buy"), function (sender)
			showPanelPage("buy")
		end)

		local btnGetVcoin = var.xmlPageShelf:getWidgetByName("btn_get_vcoin")
		

		GUIFocusPoint.addUIPoint(btnGetVcoin, function (sender)
			local mParam = {
				name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", lblConfirm = "交易行充值点收益只计入充值点余额，不计入每日充值点收入，不可用于领取每日充值，继续提取？",
				btnConfirm = "是", btnCancel = "否",
				confirmCallBack = function ()
					GameSocket:reqTakeBackVcoin()
					GameSocket:alertLocalMsg("提取完成!", "alert")
				end
			}
			GameSocket:dispatchEvent(mParam)
		end)
		
		
		GUIFocusPoint.addUIPoint(var.xmlPageShelf:getWidgetByName("pre_btn"), function (sender)
			var.buyBeginIndex = var.buyBeginIndex - CONSIGNMEMT_PAGE_SIZE
			if var.buyBeginIndex<0 then
				var.buyBeginIndex = 0
			end
			reqConsignShelf()
		end)
		
		GUIFocusPoint.addUIPoint(var.xmlPageShelf:getWidgetByName("next_btn"), function (sender)
			var.buyBeginIndex = var.buyBeginIndex + CONSIGNMEMT_PAGE_SIZE
			reqConsignShelf()
		end)

		-- updateListShelf()
		cc.EventProxy.new(GameSocket, var.xmlPageShelf)
			:addEventListener(GameMessageCode.EVENT_CONSIGN_LIST, onConsignData)
			:addEventListener(GameMessageCode.EVENT_TAKE_CONSIGN_RESULT, onTakeBackConsignItem)
			:addEventListener(GameMessageCode.EVENT_TAKE_VCOIN_RESULT, onTakeBackConsignVcoin)

	end
end

return ContainerConsignment
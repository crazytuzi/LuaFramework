local GUIItemUsage={}
local var = {}

local autoUseTime = 7; -- 推送展示时间

local ACTION = {
	SCHEDULER = 100,
}

--是否新手期
local function checkNewPeriod()
	if GameCharacter._mainAvatar then
		if GameCharacter._mainAvatar:NetAttr(GameConst.net_level) <= 80 and GameCharacter._mainAvatar:NetAttr(GameConst.net_zslevel) == 0 then
			return true
		end
	end
	return false
end

local function checkStopAutoClean()
	if (#var.betterItems + #var.fakeShowItems) <= 1 and var.uiBetterItem:getActionByTag(ACTION.SCHEDULER) then
		var.uiBetterItem:stopAllActions()
	end
end

--每秒检测是否更好物品
local function checkAutoCleanItem()
	--遍历var.betterItems
	--print("/////////////////////////checkAutoCleanItem///////////////////////")
	local showItem, clean
	local curTime = os.time()
	local isNewPeriod = checkNewPeriod()

	for i = #var.betterItems, 1, -1 do
		showItem = var.betterItems[i]
		if showItem.startTime + autoUseTime <= curTime then
			if showItem.mTypeID and GameBaseLogic.IsEquipment(showItem.mTypeID) then--and isNewPeriod then
				GameSocket:BagUseItem(showItem.itemPos, showItem.mTypeID, 1)
				local itemDef = GameSocket:getItemDefByID(showItem.mTypeID)
				GameSocket:alertLocalMsg("已自动穿戴更强装备："..itemDef.mName, "alert")
			end
			var.betterItems[i] = "remove"
		else
			break;
		end
	end
	table.removebyvalue(var.betterItems, "remove", true)

	for i = #var.fakeShowItems, 1, -1 do
		showItem = var.fakeShowItems[i]
		if showItem.startTime + autoUseTime <= curTime then
			var.fakeShowItems[i] = "remove"
		else
			break;
		end
	end
	table.removebyvalue(var.fakeShowItems, "remove", true)

	checkStopAutoClean()
end

-- 推送不自动使用

-- 清理过期信息，返回是否清理第一项
local function cleanBetterItems()
	-- print("cleanBetterItems11111", GameUtilSenior.encode(var.betterItems))
	local netItem, clean, cleanFirst
	for i,v in ipairs(var.betterItems) do
		netItem = GameSocket:getNetItem(v.itemPos)
		if not netItem then -- 物品不存在
			--print(0000000011111)
			var.betterItems[i] = "remove"
			clean = true
		elseif netItem.mTypeID ~= v.mTypeID then -- 物品改变
			--print(0000000022222)
			var.betterItems[i] = "remove"
			clean = true
		elseif GameBaseLogic.IsEquipment(v.mTypeID) and not GameSocket:check_better_item(v.itemPos) then -- 不再是更好的装备
			-- print(3333333333333)
			var.betterItems[i] = "remove"
			clean = true
		end
		if i == 1 and clean then
			cleanFirst = true
		end
	end
	-- print("cleanBetterItems2222222", GameUtilSenior.encode(var.betterItems))
	if clean then
		table.removebyvalue(var.betterItems, "remove", true)
		checkStopAutoClean()
	end
	-- print("cleanBetterItems333333333", GameUtilSenior.encode(var.betterItems))
	return cleanFirst
end

-- 按钮回调
local function pushUseItemButton(pSender)
	-- print("//////////////////pushUseItemButton//////////////////", pSender.itemPos, pSender.mTypeID)
	if pSender.itemPos and pSender.mTypeID then
		local  num = 1
		local netItem = GameSocket:getNetItem(pSender.itemPos)
		if netItem then
			num = netItem.mNumber
		end

		GameSocket:BagUseItem(pSender.itemPos, pSender.mTypeID, num)
			local itemDef = GameSocket:getItemDefByID(pSender.mTypeID)
			GameSocket:alertLocalMsg("已自动穿戴更强装备："..itemDef.mName, "alert")
		table.remove(var.betterItems, 1)
		GUIItemUsage.showBoxBetterItem(6)
	elseif pSender.mTypeID then
		pSender.mTypeID = nil
		table.remove(var.fakeShowItems, 1)
		GUIItemUsage.showBoxBetterItem(1)
	end
end

--清理过期显示
local function cleanOverDueItem(pSender)
	-- if pSender.itemPos and pSender.mTypeID then
	-- 	table.remove(var.betterItems, 1)
	-- elseif pSender.mTypeID then
	-- 	table.remove(var.fakeShowItems, 1)
	-- end
	checkAutoCleanItem()
	pSender.mTypeID = nil
	pSender.itemPos = nil
	GUIItemUsage.showBoxBetterItem(2)
end

local function buildEquipAttr(itemDef)
	local attrs = {}
	local mJob =  GameCharacter._mainAvatar:NetAttr(GameConst.net_job)
	if mJob == GameConst.JOB_ZS and itemDef.mDCMax > 0 then
		table.insert(attrs, {pre = "物理攻击：", value = itemDef.mDC.."-"..itemDef.mDCMax})
	elseif mJob == GameConst.JOB_FS and itemDef.mMCMax > 0 then
		table.insert(attrs, {pre = "魔法攻击：", value = itemDef.mMC.."-"..itemDef.mMCMax})
	elseif mJob == GameConst.JOB_DS and itemDef.mSCMax > 0 then
		table.insert(attrs, {pre = "道术攻击：", value = itemDef.mSC.."-"..itemDef.mSCMax})
	end
	if itemDef.mACMax > 0 then
		table.insert(attrs, {pre = "物理防御：", value = itemDef.mAC.."-"..itemDef.mACMax})
	end
	if itemDef.mMACMax > 0 then
		table.insert(attrs, {pre = "魔法防御：", value = itemDef.mMAC.."-"..itemDef.mMACMax})
	end
	if itemDef.mMACMax > 0 then
		table.insert(attrs, {pre = "魔法防御：", value = itemDef.mMAC.."-"..itemDef.mMACMax})
	end
	if itemDef.mMaxHp > 0 then
		table.insert(attrs, {pre = "生命上限：", value = "+"..itemDef.mMaxHp})
	end
	return attrs
end

-- 更好装备属性
local function updateEquipAttr(itemDef)
	var.boxEquipAttr:show()
	local lblAttrPre, lblAttr, imgAttrUpFlag
	local attrs = buildEquipAttr(itemDef)
	for i=1,3 do
		lblAttrPre = var.boxBetterItem:getWidgetByName("lbl_attr_pre_"..i):hide():setString("")
		lblAttr = var.boxBetterItem:getWidgetByName("lbl_attr_"..i):hide():setString("")
		if attrs[i] then
			lblAttrPre:setString(attrs[i].pre):show()
			lblAttr:setString(attrs[i].value):show()
			imgAttrUpFlag = lblAttr:getChildByName("img_attr_up_flag")
			imgAttrUpFlag:setPositionX(lblAttr:getContentSize().width + 12)
		end
	end
end

-- 特殊道具描述
local function updatePropDesp(itemDef)
	var.boxPropDesp:show()
	local lblPropDesp = var.boxBetterItem:getWidgetByName("lbl_prop_desp"):setString("")
	local pSize = lblPropDesp:getContentSize()
	local richDesp = lblPropDesp:getChildByName("richDesp")
	if not richDesp then
		richDesp = GUIRichLabel.new({size = cc.size(pSize.width, pSize.height), space=0,name = "richDesp"})
		richDesp:align(display.LEFT_TOP, 0, pSize.height):addTo(lblPropDesp)
	end
	richDesp:setRichLabel("<font color=#B2A58B>"..itemDef.mDesp.."</font>", "tips_desp", 16)
end

local function showBoxBetterItem(tag)
	-- 刷新前先重置
	--print("//////////////showBoxBetterItem/////////////////", tag, GameUtilSenior.encode(var.betterItems))
	-- checkAutoCleanItem()
	
	var.boxBetterItem:hide()
	local btnUseItem = var.boxBetterItem:getWidgetByName("btn_use_item")
	btnUseItem.itemPos = nil
	btnUseItem.mTypeID = nil
	-- btnUseItem.num = nil

	local itemPos, mTypeID, startTime--, num
	if var.fakeShowItems and #var.fakeShowItems > 0 then
		--print("/////////////var.fakeShowItems/////////////", GameUtilSenior.encode(var.fakeShowItems))
		mTypeID = var.fakeShowItems[1].mTypeID
		startTime = var.fakeShowItems[1].startTime
	elseif var.betterItems and #var.betterItems > 0 then
		--print(111111)
		local showItem = var.betterItems[1] -- 队列的首个物品
		if not showItem then return end
		--print(2222222)
		itemPos = showItem.itemPos
		mTypeID = showItem.mTypeID
		startTime = showItem.startTime
		local netItem = GameSocket:getNetItem(itemPos)
		if not (netItem and netItem.mTypeID == mTypeID) then -- 物品队列错误，需要清理
			cleanBetterItems()
			--print(33333333333)
			return
		end
		-- num = netItem.mNumber
	else
		--print(444444444)
		return
	end

	
	local itemDef = GameSocket:getItemDefByID(mTypeID)
	if not itemDef then return end  -- 没有物品描述信息，不刷新
		--print(5555555555555)
	-- print(4444444)
	var.boxBetterItem:show()
	local imgBetterItemTitle = var.boxBetterItem:getWidgetByName("img_better_item_title")
	var.boxEquipAttr:hide()
	var.boxPropDesp:hide()
	var.boxBetterItem:getWidgetByName("lbl_item_name"):setString(itemDef.mName)
	local imgIconBg = var.boxBetterItem:getWidgetByName("img_icon_bg")

	local param = {
		parent=imgIconBg,
		typeId=mTypeID,
		iconType = GameConst.ICONTYPE.NOTIP,
		num=1
	}
	if itemPos then
		param = {
			parent=imgIconBg,
			pos = itemPos,
			iconType = GameConst.ICONTYPE.NOTIP,
		}
	end

	GUIItem.getItem(param)

	if GameBaseLogic.isEquipMent(itemDef.SubType) then -- 装备
		imgBetterItemTitle:loadTexture("img_title_better_equip", ccui.TextureResType.plistType)
		var.boxBetterItem:getWidgetByName("btn_use_item"):setTitleText("装备")
		updateEquipAttr(itemDef)
	else -- 道具
		imgBetterItemTitle:loadTexture("img_title_special_item", ccui.TextureResType.plistType)
		var.boxBetterItem:getWidgetByName("btn_use_item"):setTitleText("使用")
		updatePropDesp(itemDef)
	end

	-- 7秒延时
	btnUseItem.itemPos = itemPos
	btnUseItem.mTypeID = mTypeID
	-- btnUseItem.num = num
	var.boxBetterItem:stopAllActions()

	local actionTime = startTime + autoUseTime - os.time()
	if actionTime > 0 then
		var.boxBetterItem:runAction(cca.seq({
			cca.delay(actionTime),
			cca.cb(function ()
				-- print("////////////autoUseItem//////////////")
				cleanOverDueItem(btnUseItem)
			end)
		}))
	else
		cleanOverDueItem(btnUseItem)
	end
end

local function handleBetterItem(event)
	-- print("////////////////////////handleBetterItem////////////////////////", event.itemPos, event.mTypeID);
	if event then
		if event.itemPos then -- 真提示
			--这里是不对比，直接使用
			local itemDef = GameSocket:getItemDefByID(event.mTypeID)
			if GameBaseLogic.isEquipMent(itemDef.SubType) then
				GameSocket:BagUseItem(event.itemPos, event.mTypeID, 1)
				GameSocket:alertLocalMsg("已自动穿戴更强装备："..itemDef.mName, "alert")
			end
			--自动穿戴结束
			--table.insert(var.betterItems, 1, {itemPos = event.itemPos, mTypeID = event.mTypeID, startTime = os.time()})
			showBoxBetterItem(3)
		elseif event.mTypeID then -- 假提示
			table.insert(var.fakeShowItems, 1, {mTypeID = event.mTypeID, startTime = os.time()})
			showBoxBetterItem(4)
		end
		if (#var.betterItems + #var.fakeShowItems) > 1 then
			local actionScheduler = var.uiBetterItem:getActionByTag(ACTION.SCHEDULER)
			if not actionScheduler then
				--print("////////////////***************************************actionScheduler****************************//////////////////")
				actionScheduler = cca.repeatForever(cca.seq({cca.delay(1), cca.callFunc(checkAutoCleanItem)}))
				actionScheduler:setTag(ACTION.SCHEDULER)
				var.uiBetterItem:runAction(actionScheduler)
			end
		end
	end
end

-- itemchange的时候清理
local function handleItemChange(event)
	local cleanFirst = cleanBetterItems()
	if cleanFirst then showBoxBetterItem(5) end
	-- print("GUIItemUsage handleItemChange", GameUtilSenior.encode(var.betterItems))
end


-- 方便调用
GUIItemUsage.showBoxBetterItem = showBoxBetterItem

function GUIItemUsage.init(scene)
	var = {
		uiBetterItem,
		boxBetterItem,
		boxEquipAttr,
		boxPropDesp,

		tipsType = nil, -- "equip" or "prop"
		betterItems = {}, -- 提示物品列表

		uiNewSkill,

		fakeShowItems = {}, -- 假提示物品
	}

	if scene then
		var.uiBetterItem = GUIAnalysis.load("ui/layout/GUIItemBetterCompare.uif")
		if var.uiBetterItem then
			var.uiBetterItem:align(display.LEFT_BOTTOM, 0, 0):addTo(scene, 305)
			var.boxBetterItem = var.uiBetterItem:getWidgetByName("box_better_item"):setTouchEnabled(true):hide()
			var.boxEquipAttr = var.boxBetterItem:getWidgetByName("box_equip_attr"):hide()
			var.boxPropDesp = var.boxBetterItem:getWidgetByName("box_prop_desp"):hide()

			-- GameUtilSenior.asyncload(var.uiBetterItem, "img_better_item_bg", "ui/image/img_better_item_bg.png")

			local btnUseItem = var.boxBetterItem:getWidgetByName("btn_use_item")
			GUIFocusPoint.addUIPoint(btnUseItem, pushUseItemButton)

			cc.EventProxy.new(GameSocket, var.uiBetterItem)
				:addEventListener(GameMessageCode.EVENT_BETTER_ITEM, handleBetterItem)
				:addEventListener(GameMessageCode.EVENT_ITEM_CHANGE, handleItemChange)
		end
	end
end

return GUIItemUsage
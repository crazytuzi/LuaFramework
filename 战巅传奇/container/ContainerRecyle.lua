local ContainerRecyle ={}
local var={}
local despTable ={
	[1] = 	"<font color=#E7BA52 size=18>回收说明：</font>",
	[2] =	"<font color=#f1e8d0>1、开服7天内,可回收强化8级以下装备,获得海量经验,玉佩碎片和绑定金币</font>",
    [3] =	"<font color=#f1e8d0>2、开服8天起，可回收强化8级以下装备，1转装备，获得海量经验，玉佩碎片和绑定金币</font>",
    [4] =	"<font color=#f1e8d0>3、开服15天起，可回收强化9级以下装备，2转装备，获得海量经验，玉佩碎片和绑定金币</font>",
}


function ContainerRecyle.initView(event)
	var={
		xmlPanel,
		huishouTable,
		isRecycle = false,
		isInputQiangHua = false,
		isInputJob = true,
		zhuangbeiTable,
		clickHuiShou=false,
	}
	print("zzzzzzzzzzzzzzzzzzzzinitView:1")
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerRecyle.uif")
	print("zzzzzzzzzzzzzzzzzzzzinitView:2")
	if var.xmlPanel then
		print("zzzzzzzzzzzzzzzzzzzzinitView:3")
		var.huishouTable = {}
		var.zhuangbeiTable = {} 

		if event.mParam then
			local guideLv = event.mParam.guideLv
			if guideLv then
				var.xmlPanel:runAction(
					cca.seq({
						cca.delay(0.2),
						cca.cb(function ()
							GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_GUIDE, lv = guideLv })
						end)}
					)
				)
			end
		end
		-- ContainerRecyle.setPanelText()
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			-- :addEventListener(GameMessageCode.EVENT_ITEM_CHANGE, ContainerRecyle.initPageHuishou)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, function (event)
				if event.type == "ContainerRecyle" then
					local data = GameUtilSenior.decode(event.data)
					var.huishouTable = {}
					if data and data.cmd=="recycleExp" and data.exp>0 then
						ContainerRecyle.showExpEffect(data.exp)
					end
				end
			end)
			:addEventListener(GameMessageCode.EVENT_FRESH_ITEM_PANEL, ContainerRecyle.onFreshItemPanel)
			-- ContainerRecyle.successAnimate()
			-- ContainerRecyle.successAnimate2()
			var.xmlPanel:getWidgetByName("boxEffect"):setPosition(422,300):setVisible(false)


			var.expNum = ccui.TextAtlas:create("0123456789", "image/typeface/num_8.png", 27, 32, "0")
				:addTo(var.xmlPanel:getWidgetByName("boxEffect"))
				:align(display.CENTER, 100,20)
				:setString(0)
				
		
		ContainerRecyle:updateGameMoney(var.xmlPanel)
		---var.xmlPanel:getWidgetByName("box_tab"):setSelectedTab(3)
		--var.xmlPanel:getWidgetByName("box_tab"):addTabEventListener(ContainerRecyle.pushTabButtons)
		
		return var.xmlPanel
	end
end


function ContainerRecyle.pushTabButtons(sender)
	local opened, level, funcName
	opened = true
	local tag = sender:getTag()
	if tag == 1 then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="menu_bag"})
	elseif tag == 2 then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="panel_depot"})
	end
end

--金币刷新函数
function ContainerRecyle:updateGameMoney(event)
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


function ContainerRecyle.onPanelOpen()
	ContainerRecyle.initButton()
	ContainerRecyle.initTab()
	-- ContainerRecyle.initPageHuishou()
	var.isRecycle = false
	var.isInputJob = true
	var.xmlPanel:getWidgetByName("ck_job"):setVisible(var.isInputJob)
	
end

function ContainerRecyle.onFreshItemPanel(event)
	-- print("/////////////////ContainerRecyle.onFreshItemPanel/////////////////", event.flag)
	if event.flag == 0 then
		-- local list		= var.xmlPanel:getWidgetByName("list_huishou"):setSliderVisible(false)
		-- local huishouNum = ContainerRecyle.getListNum(var.huishouTable, 4)

		-- -- var.xmlPanel:getWidgetByName("lblAddedNum"):setString("已添加"..#var.huishouTable.."件装备")
		-- list:reloadData(huishouNum,ContainerRecyle.updateHuishouList)
		ContainerRecyle.initPageHuishou()
	end
end

-- 初始化按钮 添加点击
function ContainerRecyle.initButton()
	local btns = {"btn_add","btn_huishou","btnDesp"}
	for k,v in pairs(btns) do
		local pageButton = var.xmlPanel:getWidgetByName(v):setTouchEnabled(true)
		GUIFocusPoint.addUIPoint(pageButton, ContainerRecyle.pushButtonsOfPageHuishou)
	end

	local btnQiangHua = var.xmlPanel:getWidgetByName("checkbox_qianghua"):setTouchEnabled(false)
	local ck_qh = var.xmlPanel:getWidgetByName("ck_qh"):setTouchEnabled(false):setVisible(false)
	local layout_qh = var.xmlPanel:getWidgetByName("layout_qh")
	layout_qh:setTouchEnabled(true)
	layout_qh:addClickEventListener(function (sender)
		-- 是否投入已强化装备
		var.isInputQiangHua = not var.isInputQiangHua
		ck_qh:setVisible(var.isInputQiangHua)
		-- btnQiangHua:loadTextureNormal( (var.isInputQiangHua and "btn_checkbox_sel") or "btn_checkbox", ccui.TextureResType.plistType)
		if not var.isInputQiangHua then
			if #var.huishouTable > 0 then
				for i=#var.huishouTable,1,-1 do
					local nItem = GameSocket:getNetItem(var.huishouTable[i])
					if nItem then
						local itemDef = GameSocket:getItemDefByID(nItem.mTypeID)
						if nItem.mLevel > 0 then
							table.removebyvalue(var.huishouTable,var.huishouTable[i])
						end

					end
				end
				ContainerRecyle.initPageHuishou()
			end
		end

	end)
	
	local btnJob = var.xmlPanel:getWidgetByName("checkbox_job"):setTouchEnabled(false)
	local ck_job = var.xmlPanel:getWidgetByName("ck_job"):setTouchEnabled(false):setVisible(false)
	local layout_job = var.xmlPanel:getWidgetByName("layout_job")	
	layout_job:setTouchEnabled(true)
	layout_job:addClickEventListener(function (sender)
			-- 是否投入本职业装备
			var.isInputJob = not var.isInputJob
			ck_job:setVisible(var.isInputJob)
			-- btnJob:loadTextureNormal( (var.isInputJob and "btn_checkbox_sel") or "btn_checkbox", ccui.TextureResType.plistType)
			if not var.isInputJob then
				if #var.huishouTable > 0 then
					for i=#var.huishouTable,1,-1 do
						local nItem = GameSocket:getNetItem(var.huishouTable[i])
						if nItem then
							local itemDef = GameSocket:getItemDefByID(nItem.mTypeID)
							if itemDef.mJob == GameCharacter._mainAvatar:NetAttr(GameConst.net_job) then
								table.removebyvalue(var.huishouTable,var.huishouTable[i])
							end

						end
					end
					ContainerRecyle.initPageHuishou()
				end
			end
		end)

	local btnDesp = var.xmlPanel:getWidgetByName("btnDesp")
	btnDesp:setTouchEnabled(true)
	btnDesp:addTouchEventListener(function (pSender, touchType)
		if touchType == ccui.TouchEventType.began then
			btnDesp:setScale(0.88, 0.88)
			ContainerRecyle.recycleDesp()
		elseif touchType == ccui.TouchEventType.ended or touchType == ccui.TouchEventType.canceled then	
			btnDesp:setScale(1, 1)
			GDivDialog.handleAlertClose()
		end
	end)
end
-- 初始化页签
function ContainerRecyle.initTab()
	local severDay = GameSocket.severDay+1
	--local tabArr = {"01-05阶","06-10阶","11-15阶","16-20阶","神器装备","倍攻装备","普通特殊","星座","图腾"}
	local tabArr = {"全部"}
	local function updateTabList(item)
		local tab = item:getWidgetByName("btnMode")
		local idx = item.tag
		if idx == var.curSelectIndex and GameUtilSenior.isObjectExist(var.curTab) then
			tab:setBrightStyle(1)--:setTitleColor(cc.c3b(210, 180, 140))
			tab:setScale(1, 1)
			var.curTab = tab
		else
			tab:setBrightStyle(0)--:setTitleColor(cc.c3b(115, 95, 85))
			tab:setScale(1, 1)
		end

		tab:setTitleText(tabArr[idx]):setSwallowTouches(false)
		tab.index = idx;
		GUIAnalysis.attachEffect(tab,"outline(0e0600,1)")
		GUIFocusPoint.addUIPoint(tab,ContainerRecyle.changeTab)
		-- 第一次设置按钮给初始化
		if var.curSelectIndex == nil and item.tag==1 then
			ContainerRecyle.changeTab(tab)
		end
		--if severDay>=8 then
		--	tab:setVisible(true)
		--end
		-- if severDay>=7 and severDay<14 and item.tag>=7 then
		-- 	tab:setVisible(false)
		-- end
		--if severDay<=7 and item.tag>=6 then
		--	tab:setVisible(false)
		--end
	end
	local tabList = var.xmlPanel:getWidgetByName("tabList")
	tabList:reloadData(#tabArr,updateTabList)
	-- :setTouchEnabled(true)
	tabList:setSliderVisible(false)
	tabList:setTouchEnabled(true)
	-- tabList.tableview:setTouchEnabled(true)
end

function ContainerRecyle.changeTab(sender)
	if var.curTab then
		var.curTab:setBrightStyle(0)--:setTitleColor(cc.c3b(115, 95, 85))
		var.curTab:setScale(1, 1)
	end
	sender:setBrightStyle(1)--:setTitleColor(cc.c3b(210, 180, 140))
	sender:setScale(1, 1)
	if #var.huishouTable > 0 then 	--每次切换标签清空回收站
		var.huishouTable = {}
		-- print("11111111")
		var.xmlPanel:getWidgetByName("list_huishou"):reloadData(ContainerRecyle.getListNum( var.huishouTable, 5 ),ContainerRecyle.updateHuishouList)
	end
	var.curTab = sender
	var.curSelectIndex = sender.index
	ContainerRecyle.initPageHuishou()
end

function ContainerRecyle.setPanelText()
	-- local labelTable = {
	-- 	["label_exp_text"]  = {wType="label",		text = GameConst.str_canget_exp},
	-- 	["label_coin_text"] = {wType="label",		text = GameConst.str_canget_money},
	-- 	["label_bvcoin_text"]={wType="label",		text = GameConst.str_canget_bvcoin},
	-- 	["label_zsjy_text"] = {wType="label",		text = GameConst.str_canget_zsjy},
	-- 	["btn_huishou"] 	= {wType="button",		text = GameConst.str_onekey_recycle},
	-- 	["btn_add"] 		= {wType="button",		text = GameConst.str_onekey_add},
	-- }

	-- for k,v in pairs(labelTable) do
	-- 	if v.wType == "label" then
	-- 		var.xmlPanel:getWidgetByName(k):setString(v.text)
	-- 	elseif v.wType == "button" then
	-- 		var.xmlPanel:getWidgetByName(k):setTitleText(v.text)
	-- 	end
	-- end
end

function ContainerRecyle.pushButtonsOfPageHuishou(pSender)
	if pSender:getName() == "btn_huishou" then
		if var.huishouTable then
			local param = {
				actionid = "huishou",
				param = var.huishouTable,
			}
			local isUpgraded = false
			for k,v in pairs(var.huishouTable) do
				local nItem = GameSocket:getNetItem(v)
				if nItem then
					if nItem.mLevel>0 or nItem.mZLevel>0 then
						isUpgraded = true
						break
					end
				end
			end
			if isUpgraded then
				local mParam = {
					name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", lblConfirm = GameConst.str_has_upgraded_recycle,
					confirmCallBack = function ()
						ContainerRecyle.handleRecycleAction(function ()
							GameSocket.mSortFlag = 0
							GameSocket:PushLuaTable("gui.PanelUpgrade.onPanelData", GameUtilSenior.encode(param))
							-- var.huishouTable = {}
							var.isRecycle = false
						
						end)
						
					end
				}
				GameSocket:dispatchEvent(mParam)
			else
				if #var.huishouTable>0 then
					local mParam = {
						name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", lblConfirm = "是否确认本次回收？",
						confirmCallBack = function ()
							ContainerRecyle.handleRecycleAction(function ()
								GameSocket.mSortFlag = 0
								GameSocket:PushLuaTable("gui.PanelUpgrade.onPanelData", GameUtilSenior.encode(param))
								-- var.huishouTable = {}
								var.isRecycle = false
								var.clickHuiShou=true
							end)
							
						end
					}
					GameSocket:dispatchEvent(mParam)
				end
			end
		end
	elseif pSender:getName() == "btn_add" then
		if var.curTab then
			ContainerRecyle.changeTab(var.curTab)
		end
		var.huishouTable = ContainerRecyle.selectHuiShouTable()
		ContainerRecyle.setLabelWillGeted()
		ContainerRecyle.initPageHuishou()
	-- elseif pSender:getName() == "btnDesp" then
	-- 	ContainerRecyle.recycleDesp()
	-- elseif pSender:getName() == "btnGuanBi" or pSender:getName() == "imgMask" then
	-- 	var.xmlPanel:getWidgetByName("despBg"):setVisible(false)
	-- 	var.xmlPanel:getWidgetByName("imgMask"):setVisible(false)
	end
end

function ContainerRecyle.selectHuiShouTable()
		local equipTable = {}
		local nItem = nil
		local itemDef = nil

		local selectTable = ContainerRecyle.getEquipTableWithoutAdded()
		if var.isInputJob and var.isInputQiangHua then 	--如果都勾选，则投入所有可投入
			var.huishouTable = {}
			for i=1,#selectTable do
				if not GameSocket:check_better_item(selectTable[i],true) then
					table.insert(equipTable,#equipTable+1, selectTable[i])
				end
			end
		elseif not var.isInputJob and not var.isInputQiangHua then 	--都不勾选

			-- var.huishouTable = {}
			if #var.huishouTable > 0 then
				equipTable = var.huishouTable
				selectTable = var.zhuangbeiTable
			end
			for i=0,#selectTable do
				nItem = GameSocket:getNetItem(selectTable[i])
				if nItem then
					itemDef = GameSocket:getItemDefByID(nItem.mTypeID)
					-- if itemDef.mJob ~= GameCharacter._mainAvatar:NetAttr(GameConst.net_job) then
					if nItem.mLevel < 1 and itemDef.mJob ~= GameCharacter._mainAvatar:NetAttr(GameConst.net_job) and not GameSocket:check_better_item(selectTable[i]) then
						table.insert(equipTable,#equipTable+1, selectTable[i])
					-- else
					-- 	table.removebyvalue(equipTable,equipTable[i])
					end

				end
			end

		elseif var.isInputJob then 	--只勾选本职
			-- var.huishouTable = {}
			if #var.huishouTable > 0 then
				equipTable = var.huishouTable
				selectTable = var.zhuangbeiTable
			end
			for i=0,#selectTable do
				nItem = GameSocket:getNetItem(selectTable[i])
				if nItem then
					itemDef = GameSocket:getItemDefByID(nItem.mTypeID)
					-- if itemDef.mJob ~= GameCharacter._mainAvatar:NetAttr(GameConst.net_job) then
					if nItem.mLevel < 1 and not GameSocket:check_better_item(selectTable[i],true) then
						table.insert(equipTable,#equipTable+1, selectTable[i])
					end
				end
			end
		elseif var.isInputQiangHua then 	--只勾选强化
			-- var.huishouTable = {}
			if #var.huishouTable > 0 then
				equipTable = var.huishouTable
				selectTable = var.zhuangbeiTable
			end
			for i=0,#selectTable do
				nItem = GameSocket:getNetItem(selectTable[i])
				if nItem then
					itemDef = GameSocket:getItemDefByID(nItem.mTypeID)
					-- if itemDef.mJob ~= GameCharacter._mainAvatar:NetAttr(GameConst.net_job) then
					if itemDef.mJob ~= GameCharacter._mainAvatar:NetAttr(GameConst.net_job) and not GameSocket:check_better_item(selectTable[i],true) then
						table.insert(equipTable,#equipTable+1, selectTable[i])
					end
				end
			end
		end
	return equipTable
end

--获取当前开区天数能回收的最高转生等级
-- nItem 可获得强化等级
-- itemDef 可获得穿戴等级 和转身等级
function ContainerRecyle.getCanZsMax(nItem, itemDef)
	if not nItem or not itemDef then return end
	local severDay = GameSocket.severDay+1 --开区第一天GameSocket.severDay=0
	local zMax = false
	if severDay>=8 then 	--14天后
		-- 最高收强9 转2
		if nItem.mLevel < 10 and itemDef.mNeedZsLevel < 3 then
			zMax = true
		end
		-- zMax=20
	elseif severDay>=8 then 	--7天后	
		if nItem.mLevel < 8 and itemDef.mNeedZsLevel < 2 then
			zMax = true
		end
		-- zMax=8
	elseif severDay<=7 then 	--前7天
		if nItem.mLevel < 8 and itemDef.mNeedZsLevel == 0 and itemDef.mNeedParam <= 90 then
			zMax = true
		end
		-- zMax=4
	end
	return zMax
end

function ContainerRecyle.getEquipTableWithoutAdded()
	local equipTable ={}
	for i=0,(GameConst.ITEM_BAG_SIZE+GameSocket.mBagSlotAdd) do
		local nItem = GameSocket:getNetItem(i)
		if nItem then
			local itemDef = GameSocket:getItemDefByID(nItem.mTypeID)--and GameBaseLogic.IsEquipment(nItem.mTypeID)
			
			if itemDef then
			
				if var.curSelectIndex == 1 then 	--杂品回收
					--if itemDef.mEquipGroup==3001 then  --S以下
					if itemDef.mEquipType>0 then  --只有装备能放进去
						table.insert(equipTable,#equipTable+1, i)
					end
					--end
				elseif var.curSelectIndex == 2 then
					if itemDef.mEquipGroup==3002 then  --SSR以下
						table.insert(equipTable,#equipTable+1, i)
					end
				elseif var.curSelectIndex == 3 then
					if itemDef.mEquipGroup==3003 then  --宝石
						table.insert(equipTable,#equipTable+1, i)
					end
				elseif var.curSelectIndex == 4 then
					if itemDef.mEquipGroup==3004 then  --特殊
						table.insert(equipTable,#equipTable+1, i)
					end
				elseif var.curSelectIndex == 5 then
					if itemDef.mEquipGroup==4001 then  --特殊
						table.insert(equipTable,#equipTable+1, i)
					end
				elseif var.curSelectIndex == 6 then
					if itemDef.mEquipGroup==5001 then  --特殊
						table.insert(equipTable,#equipTable+1, i)
					end
				elseif var.curSelectIndex == 7 then
					if itemDef.mEquipGroup==8000 then  --特殊
						table.insert(equipTable,#equipTable+1, i)
					end
				elseif var.curSelectIndex == 8 then
					if itemDef.mEquipGroup==8001 then  --特殊
						table.insert(equipTable,#equipTable+1, i)
					end
				elseif var.curSelectIndex == 9 then
					if itemDef.mEquipGroup==9000 then  --特殊
						table.insert(equipTable,#equipTable+1, i)
					end
				end
			end
				
			--if not table.keyof(var.huishouTable,i) and ContainerRecyle.getCanZsMax(nItem,itemDef) and itemDef.mEquipGroup>0 then 	--过滤开服时间限制回收 和 垃圾站
			--	if var.curSelectIndex == 1 then 	--全部回收
			--		if itemDef.mEquipGroup <= 1001 and nItem.mLevel <= 8  and itemDef.mEquipType<11 then --itemDef.mEquipType>=11属于副装
			--			table.insert(equipTable,#equipTable+1, i)
			--		end
			--	elseif var.curSelectIndex == 2 then 	--杂品回收
			--		if itemDef.mEquipGroup == 1001 then
			--			table.insert(equipTable,#equipTable+1, i)
			--		end
			--	elseif var.curSelectIndex == 3 then 	--70级回收
			--		if itemDef.mNeedZsLevel == 0 and itemDef.mNeedParam <= 70 and itemDef.mEquipGroup <= 7 and nItem.mLevel <= 8 then
			--			table.insert(equipTable,#equipTable+1, i)
			--		end
			--	elseif var.curSelectIndex == 4 then 	--80级回收
			--		if itemDef.mNeedZsLevel == 0 and itemDef.mNeedParam > 79 and itemDef.mNeedParam < 90 and itemDef.mEquipGroup == 8 and nItem.mLevel <= 8 then
			--			table.insert(equipTable,#equipTable+1, i)
			--		end
			--	elseif var.curSelectIndex == 5 then 	--90级回收
			--		if itemDef.mNeedZsLevel == 0 and itemDef.mNeedParam > 89 and itemDef.mNeedParam < 100 and itemDef.mEquipGroup == 9 and nItem.mLevel <= 8 then
			--			table.insert(equipTable,#equipTable+1, i)
			--		end
			--	elseif var.curSelectIndex == 6 then 	--1转回收
			--		if itemDef.mNeedZsLevel == 1 and itemDef.mEquipGroup ==  10 and nItem.mLevel <= 8 then
			--			table.insert(equipTable,#equipTable+1, i)
			--		end
			--	elseif var.curSelectIndex == 7 then 	--2转回收
			--		if itemDef.mNeedZsLevel == 2 and itemDef.mEquipGroup == 11 and nItem.mLevel <= 9 then
			--			table.insert(equipTable,#equipTable+1, i)
			--		end			
			--	end
			--end
			var.zhuangbeiTable = equipTable
			-- if GameBaseLogic.IsEquipment(nItem.mTypeID)  and itemDef.mNeedZsLevel<=ContainerRecyle.getCanZsMax() and GameBaseLogic.checkRecycle(nItem.mTypeID) and not table.keyof(var.huishouTable,i) 
			-- 	 and not ContainerRecyle.checkEquipRule(i,"list") then
			-- if isInputJob == (itemDef.mJob == GameCharacter._mainAvatar:NetAttr(GameConst.net_job)) then
				-- table.insert(equipTable,#equipTable+1, i)
			-- end

		end
	end
	return equipTable
end

function ContainerRecyle.initPageHuishou()
	
	local list_zb = var.xmlPanel:getWidgetByName("list_zb"):setSliderVisible(false)
	local equipTable = ContainerRecyle.getEquipTableWithoutAdded()

	local listNum = ContainerRecyle.getListNum( equipTable, 5)
	list_zb:reloadData(0,function(items) ContainerRecyle.updateHuishouEquipList(items,equipTable) end)
	list_zb:reloadData(listNum,function(items) ContainerRecyle.updateHuishouEquipList(items,equipTable) end)

	local list		= var.xmlPanel:getWidgetByName("list_huishou"):setSliderVisible(false)
	local huishouNum = ContainerRecyle.getListNum(var.huishouTable, 5)

	-- var.xmlPanel:getWidgetByName("lblAddedNum"):setString("已添加"..#var.huishouTable.."件装备")
	-- print("000000000")
	list:reloadData(huishouNum,ContainerRecyle.updateHuishouList)
	
end

-- function ContainerRecyle.initPage()
-- 	local list		= var.xmlPanel:getWidgetByName("list_huishou")
-- 	local huishouNum = ContainerRecyle.getListNum(var.huishouTable)

-- 	-- var.xmlPanel:getWidgetByName("lblAddedNum"):setString("已添加"..#var.huishouTable.."件装备")
-- 	list:reloadData(huishouNum,ContainerRecyle.updateHuishouList)	
-- end

--背包中物品显示
function ContainerRecyle.updateHuishouEquipList(subItem,equipTable)
	local pos = subItem.tag

	if equipTable[pos] then
		local param = {
			iconType = GameConst.ICONTYPE.DEPOT,
			parent = subItem,
			pos = equipTable[pos],
			titleText = GameConst.str_put_in,

			callBack = function()
				--防止面板关闭，tips没有关闭后导致的bug
				-- if GameUtilSenior.isObjectExist(var.xmlPanel) then
				-- 	ContainerRecyle.updateEquipUpgrade(equipTable[pos])
				-- end

				-- tips显示
				local nItem = GameSocket:getNetItem(equipTable[pos])
				local itemDef = GameSocket:getItemDefByID(nItem.mTypeID)
				GameSocket:dispatchEvent({
				name		= GameMessageCode.EVENT_HANDLE_TIPS, 
				itemPos		= equipTable[pos], 
				typeId		= itemDef.mTypeID,
				-- mLevel		= itemDef.mNeedParam,
				-- mZLevel		= itemDef.mNeedZsLevel,
				-- iconType    = itemIcon.iconType,
				visible		= true,
				})
			end,
			doubleCall = function ()
			-- print("双击回调")
				if GameUtilSenior.isObjectExist(var.xmlPanel) then
					ContainerRecyle.updateEquipUpgrade(equipTable[pos])
				end
			end
		}
		GUIItem.getItem(param)
	else
		if subItem:getWidgetByName("item_icon") then
			subItem:getWidgetByName("item_icon"):removeFromParent()
		end
	end

end

function ContainerRecyle.updateEquipUpgrade(npos)
	-- local nItem = GameSocket:getNetItem(npos)
	-- if nItem and GameBaseLogic.checkRecycle(nItem.mTypeID) then
	-- 	if not table.keyof(var.huishouTable,npos) then
	-- 		table.insert(var.huishouTable,#var.huishouTable+1,npos)
	-- 		ContainerRecyle.setLabelWillGeted()
	-- 	end
		
	-- 	-- var.xmlPanel:getWidgetByName("lblAddedNum"):setString("已添加"..#var.huishouTable.."件装备")
	-- 	var.xmlPanel:getWidgetByName("list_huishou"):reloadData(ContainerRecyle.getListNum( var.huishouTable,4 ),ContainerRecyle.updateHuishouList)
	-- 	ContainerRecyle.initPageHuishou()
	-- end
	local nItem = GameSocket:getNetItem(npos)
	local itemDef = GameSocket:getItemDefByID(nItem.mTypeID)
	if nItem then
		if not var.isInputQiangHua then 	--判断不可投强化
			if not var.isInputJob then 	--如果成立 不可投强化和本职
				if itemDef.mJob ~= GameCharacter._mainAvatar:NetAttr(GameConst.net_job) and nItem.mLevel < 1 then
					table.insert(var.huishouTable,#var.huishouTable+1,npos)
				end
			else 	--否则 不可投强化 但可投本职
				if nItem.mLevel < 1 then
					table.insert(var.huishouTable,#var.huishouTable+1,npos)
				end
			end
		elseif not var.isInputJob then 	--判断不可投本职
			if not var.isInputQiangHua then 	--如果成立 不可投强化和本职
				if itemDef.mJob ~= GameCharacter._mainAvatar:NetAttr(GameConst.net_job) and nItem.mLevel < 1 then
					table.insert(var.huishouTable,#var.huishouTable+1,npos)
				end
			else 	--否则 不可投本职 但可投强化
				if itemDef.mJob ~= GameCharacter._mainAvatar:NetAttr(GameConst.net_job) then
					table.insert(var.huishouTable,#var.huishouTable+1,npos)
				end
			end
		else 	--所有都可以投
			table.insert(var.huishouTable,#var.huishouTable+1,npos)
		end
		ContainerRecyle.initPageHuishou()
	end
end

--爆炸特效
function ContainerRecyle.successAnimate(subItem)
	local fireworks = cc.Sprite:create():addTo(subItem):pos(40,40)
	local animate = cc.AnimManager:getInstance():getPlistAnimate(4,6521200,4,3,false,false,0,function(animate,shouldDownload)
							if animate then
								fireworks:runAction(cca.seq({
									cca.rep(animate,2),
									cca.removeSelf(),
									cca.cb(function ()

									end),
								}))
							end
							if shouldDownload==true then
								fireworks:release()
							end
						end,
						function(animate)
							fireworks:retain()
						end)
end

--经验特效
function ContainerRecyle.successAnimate2()
	local boxEffect = var.xmlPanel:getWidgetByName("imgEff")
	local fireworks = cc.Sprite:create():addTo(boxEffect):pos(30,-25)
	local animate = cc.AnimManager:getInstance():getPlistAnimate(4,6521100,4,3,false,false,0,function(animate,shouldDownload)
							if animate then
								fireworks:runAction(cca.seq({
									cca.rep(animate,5),
									cca.removeSelf(),
									cca.cb(function ()

									end),
								}))
							end
							if shouldDownload==true then
								fireworks:release()
							end
						end,
						function(animate)
							fireworks:retain()
						end)
end

--飞走特效
function ContainerRecyle.successAnimate3()
	local fireworks = cc.Sprite:create():addTo(var.xmlPanel):pos(422,350)
	local animate = cc.AnimManager:getInstance():getPlistAnimate(4,6521000,4,3,false,false,0,function(animate,shouldDownload)
							if animate then
								fireworks:runAction(cca.seq({
									cca.rep(animate,10),
									cca.removeSelf(),
									cca.cb(function ()

									end),
								}))
							end
							if shouldDownload==true then
								fireworks:release()
							end
						end,
						function(animate)
							fireworks:retain()
						end)
	return fireworks
end

function ContainerRecyle.showExpEffect(exp)
	local boxEffect = var.xmlPanel:getWidgetByName("boxEffect"):setPosition(422,300):setVisible(true)
	var.expNum:setString(exp):setVisible(false)

	local numArrs = {}
	local length = string.len(tostring(exp))
	for i=length,1,-1 do
		local curNum = string.sub(tostring(exp),i,i)
		if curNum=="" then curNum="0" end
		table.insert(numArrs,curNum)
	end
	-- print(length,"==============",exp,GameUtilSenior.encode(numArrs))

	for i=1,10 do
		local numImg = var.xmlPanel:getWidgetByName("num"..i)
		if i<=length then
			numImg:setVisible(true)
		else
			numImg:setVisible(false)
		end
	end
	var.xmlPanel:getWidgetByName("numBox"):setPositionX(102-(10-length)*10)

	local index = 1
	--数字翻滚
	local function numRoll(numImg)
		local time=0
		numImg:runAction(cca.repeatForever(cca.seq({cca.delay(0.015), cca.callFunc(function ()
			time = time+1
			numImg:loadTexture("rExp"..time..".png", ccui.TextureResType.plistType)
			if time>9 then
				numImg:loadTexture("rExp"..numArrs[index]..".png", ccui.TextureResType.plistType)
				numImg:stopAllActions()
				index=index+1
				if index<=length then
					local numImg = var.xmlPanel:getWidgetByName("num"..index)
					numRoll(numImg)
				end
			end
		end)})))
	end

	local function moveAct3()
		local target = ContainerRecyle.successAnimate3()
		target:runAction(cca.seq({
			-- cca.delay(0.5), 
			cca.moveTo(0.6, 422, -50),
			cca.cb(function ()
				target:stopAllActions()
				target:setVisible(false)
				var.expNum:setString(0)
				GameSocket:PushLuaTable("gui.PanelUpgrade.onPanelData", GameUtilSenior.encode({actionid = "actStop",}))
			end),
		}))
	end

	local function moveAct2(target)
		target:runAction(cca.seq({
			cca.delay(2.5), 
			cca.cb(function() 
				target:stopAllActions()
				target:setVisible(false)
				moveAct3(target) 
			end),
		}))
	end

	local function moveAct(target)
		target:setVisible(true)
		ContainerRecyle.successAnimate2()
		target:runAction(cca.seq({
			cca.moveTo(0.2, 422, 350),
			cca.cb(function ()
				target:stopAllActions()
				moveAct2(target)
				local numImg = var.xmlPanel:getWidgetByName("num1")
				numRoll(numImg)
			end),
		}))
	end
	moveAct(boxEffect)
	for i=1,10 do
		var.xmlPanel:getWidgetByName("num"..i):loadTexture("rExp0.png", ccui.TextureResType.plistType)
	end
end

--回收站物品显示
function ContainerRecyle.updateHuishouList(subItem)
	local npos = subItem.tag 
	if var.huishouTable[npos] then
		local param = {
			parent = subItem,
			pos = var.huishouTable[npos],
			iconType = GameConst.ICONTYPE.DEPOT,
			titleText = GameConst.str_take_out,
			callBack = function()
				-- --防止面板关闭，tips没有关闭后导致的bug
				-- if GameUtilSenior.isObjectExist(var.xmlPanel) then
				-- 	subItem:getWidgetByName("item_icon"):removeFromParent()
				-- 	table.removebyvalue(var.huishouTable,var.huishouTable[npos])

				-- 	ContainerRecyle.setLabelWillGeted()
				-- 	-- var.xmlPanel:getWidgetByName("lblAddedNum"):setString("已添加"..#var.huishouTable.."件装备")
				-- 	var.xmlPanel:getWidgetByName("list_huishou"):reloadData(ContainerRecyle.getListNum( var.huishouTable, 4 ),ContainerRecyle.updateHuishouList)
				-- 	ContainerRecyle.initPageHuishou()
				-- end
				
				-- 显示tips
				local nItem = GameSocket:getNetItem(var.huishouTable[npos])
				local itemDef = GameSocket:getItemDefByID(nItem.mTypeID)
				GameSocket:dispatchEvent({
				name		= GameMessageCode.EVENT_HANDLE_TIPS, 
				itemPos		= var.huishouTable[npos], 
				typeId		= itemDef.mTypeID,
				-- mLevel		= itemDef.mNeedParam,
				-- mZLevel		= itemDef.mNeedZsLevel,
				-- iconType    = itemIcon.iconType,
				visible		= true,
				})
			end,
			doubleCall = function()
				--防止面板关闭，tips没有关闭后导致的bug
				if GameUtilSenior.isObjectExist(var.xmlPanel) then
					subItem:getWidgetByName("item_icon"):removeFromParent()
					table.removebyvalue(var.huishouTable,var.huishouTable[npos])

					ContainerRecyle.setLabelWillGeted()
					-- var.xmlPanel:getWidgetByName("lblAddedNum"):setString("已添加"..#var.huishouTable.."件装备")
					-- var.xmlPanel:getWidgetByName("list_huishou"):reloadData(ContainerRecyle.getListNum( var.huishouTable, 4 ),ContainerRecyle.updateHuishouList)
					ContainerRecyle.initPageHuishou()
				end
			end
		}
		GUIItem.getItem(param)
	else
		if subItem:getWidgetByName("item_icon") then
			subItem:getWidgetByName("item_icon"):removeFromParent()
			if var.clickHuiShou==true then
				ContainerRecyle.successAnimate(subItem)
			end
		end
	end
	if npos>=20 then
		var.clickHuiShou=false
	end
end

function ContainerRecyle.getListNum( tb, idx )
	-- return 4*math.ceil((#tb>12 and #tb or 12)/4)
	return idx*math.ceil((#tb>30 and #tb or 30)/idx)
end

function ContainerRecyle.setLabelWillGeted()
-- 	local expall,coin,zsjy,bvcoin = ContainerRecyle.getEquipExpAndCoin(var.huishouTable)
-- 	-- print(expall,coin,zsjy,bvcoin)
-- 	var.xmlPanel:getWidgetByName("label_exp_get"):setString(expall)
-- 	var.xmlPanel:getWidgetByName("label_coin_get"):setString(coin)
-- 	var.xmlPanel:getWidgetByName("label_zsjy_get"):setString(zsjy)
-- 	var.xmlPanel:getWidgetByName("label_bvcoin_get"):setString(bvcoin)

-- 	var.xmlPanel:getWidgetByName("lblAddedNum"):setString("已添加"..#var.huishouTable.."件装备")
end

function ContainerRecyle.getEquipExpAndCoin(posTable)
	local exp,coin,zsjy,bvcoin =0,0,0,0
	for k,v in pairs(posTable) do
		local nItem = GameSocket:getNetItem(v)
		if nItem then
			local itemid = nItem.mTypeID
			if GameBaseLogic.checkRecycle(itemid) then
				exp = exp + (GameBaseLogic.checkRecycle(itemid).jy or 0)
				coin = coin + (GameBaseLogic.checkRecycle(itemid).gold or 0)
				zsjy = zsjy + (GameBaseLogic.checkRecycle(itemid).zsjy or 0)
				bvcoin = bvcoin + (GameBaseLogic.checkRecycle(itemid).bangyuan or 0)
			end
		end
	end
	-- if GameCharacter._mainAvatar:NetAttr(GameConst.net_level)<70 then
	-- 	exp = exp*0.3
	-- end
	exp = exp >= 100000 and math.floor(exp / 10000).."万" or exp
	coin = coin >= 100000 and math.floor(coin / 10000).."万" or coin
	zsjy = zsjy >= 100000 and math.floor(zsjy / 10000).."万" or zsjy
	bvcoin = bvcoin >= 100000 and math.floor(bvcoin / 10000).."万" or bvcoin
	return exp,coin,zsjy,bvcoin
end

function ContainerRecyle.checkEquipRule(pos,rule)
	local useful = true
	local nItem = GameSocket:getNetItem(pos)
	if nItem then
		if nItem.mLevel >0 or nItem.mZLevel > 0 then return true end
		local idf = GameSocket:getItemDefByID(nItem.mTypeID)
		if idf then
			local job = GameCharacter._mainAvatar:NetAttr(GameConst.net_job)
			local level = GameCharacter._mainAvatar:NetAttr(GameConst.net_level)
			local zslevel = GameCharacter._mainAvatar:NetAttr(GameConst.net_zslevel)
			local gender = GameCharacter._mainAvatar:NetAttr(GameConst.net_gender)
			-- print(zslevel,level,idf.mNeedZsLevel,idf.mNeedParam)
			if idf then
				if rule =="list" and (idf.mJob~= job or gender ~= idf.mGender or  idf.mNeedParam < level or idf.mNeedZsLevel < zslevel and idf.mNeedParam < level ) then
					useful = false
				elseif rule =="onekey" and (idf.mJob~= job or idf.mNeedZsLevel <=zslevel and idf.mNeedParam < level) then
					useful = false
				elseif rule =="recy" and (idf.mJob~= job or idf.mNeedParam < level ) then
					useful = false
				end
			end
		end
	end
	return useful
end

function ContainerRecyle.handleRecycleAction(callfunc)
	callfunc()
	
	-- local listRecycle = var.xmlPanel:getWidgetByName("list_huishou")
	-- if listRecycle then
	-- 	local pSize = listRecycle:getContentSize()
	-- 	local rotateRoot = ccui.Widget:create()
	-- 		:setAnchorPoint(listRecycle:getAnchorPoint())
	-- 		:pos(listRecycle:getPosition())
	-- 		:addTo(listRecycle:getParent())
	-- 		:size(pSize)

	-- 	local endPos = cc.p(pSize.width * 0.5, pSize.height * 0.5)

	-- 	local function createPoints(node)
	-- 		local num = 10
	-- 		local startPos = cc.p(node:getPositionX(), node:getPositionY())
	-- 		local radius = cc.pGetDistance(startPos, endPos)
	-- 		local points = {startPos}
	-- 		local dis = cc.pSub(endPos, startPos)
	-- 		for i=1,num do
	-- 			table.insert(points, cc.pRotateByAngle(cc.pAdd(startPos, cc.pMul(dis, (i - 1) / num)), endPos, i * 6.28 / num ))
	-- 		end
	-- 		table.insert(points, endPos)
	-- 		return points
	-- 	end
	-- 	var.isRecycle = true
	-- 	local index = 0
	-- 	if table.getn(var.huishouTable)>0 then
	-- 		for i,v in ipairs(var.huishouTable) do
	-- 			local modelItem = listRecycle:getModelByIndex(i)
	-- 			if modelItem then
	-- 				index = index + 1
	-- 				-- local shake = math.random(500, 1000) / 100
	-- 				local time = math.random(1000, 2000) / 1000
	-- 				local newPos = rotateRoot:convertToNodeSpace(GameUtilSenior.getWidgetCenterPos(modelItem))
	-- 				local showItem = modelItem:clone()
	-- 				showItem:align(display.CENTER, newPos.x, newPos.y):addTo(rotateRoot)
	-- 				showItem:runAction(cca.seq({
	-- 						cca.rep(cca.seq({
	-- 							cca.rotateBy(0.05, -5),
	-- 							cca.rotateBy(0.05, 5),
	-- 						}),5),
	-- 						cca.spawn({
	-- 							cca.splineTo(time, createPoints(showItem), 0),
	-- 							cca.scaleTo(time, 0.01),
	-- 						}),
	-- 						cca.cb(function ()
	-- 							index = index - 1
	-- 							if index == 0 then
	-- 								callfunc()
	-- 								var.huishouTable ={}
	-- 								-- var.xmlPanel:getWidgetByName("label_exp_get"):setString("0")
	-- 								-- var.xmlPanel:getWidgetByName("label_coin_get"):setString("0")
	-- 								-- var.xmlPanel:getWidgetByName("label_zsjy_get"):setString("0")
	-- 								-- var.xmlPanel:getWidgetByName("label_bvcoin_get"):setString("0")
	-- 								GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL, str = "menu_recycle"})
	-- 							end
	-- 						end),
	-- 						cca.removeSelf()
	-- 					})
	-- 				)
	-- 			end
	-- 		end
	-- 		listRecycle:reloadData(0,ContainerRecyle.updateHuishouList)
	-- 	else
	-- 		callfunc()
	-- 	end
	-- end
end

function ContainerRecyle.onPanelClose()
	if var.isRecycle and var.huishouTable then
		local param = {
			actionid = "huishou",
			param = var.huishouTable,
		}
		GameSocket:PushLuaTable("gui.PanelUpgrade.onPanelData", GameUtilSenior.encode(param))
		var.huishouTable = {}
		var.isRecycle = false
	end

	-- 主线假副本后特殊处理
	local tid, ts = GameSocket:checkTaskState(1000)
	-- print("ContainerRecyle.onPanelClose", GameSocket.mTasks[1000].mState, tid, ts);
	if tid == 10034 or tid == 10046 or tid == 10055 then
		if ts == GameConst.TSCOMP then
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CONTINUE_TASK})
		end
	end
	GameSocket.mSortFlag = nil
	GameSocket:PushLuaTable("gui.PanelUpgrade.onPanelData", GameUtilSenior.encode({actionid = "actStop",}))
end

--个人信息是每次推新增的，全服信息是每次推10条，所以更新全服信息时要把list的child全remove
function ContainerRecyle.recycleDesp()
	local mParam = {
	name = GameMessageCode.EVENT_PANEL_ON_ALERT,
	panel = "tips", 
	infoTable = despTable,
	visible = true, 
	}
	GameSocket:dispatchEvent(mParam)

end

return ContainerRecyle
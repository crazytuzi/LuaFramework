local ContainerLottery={}
local var = {}
local LOTTERY_MY_MAX_LENGTH = 30

function ContainerLottery.initView()
	var = {
		xmlPanel,
		myLotteryInfos=nil,
		roleName,
		xmlLottery=nil,
		xmlLotteryBag=nil,
		worldListAction = false,
		serverday=0,
		noShowTip=false,
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerLottery.uif");
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerLottery.handlePanelData)
			:addEventListener(GameMessageCode.EVENT_GAME_MONEY_CHANGE, ContainerLottery.updateGameMoney)
		var.roleName = GameCharacter._mainAvatar:NetAttr(GameConst.net_name)
		var.xmlLottery = var.xmlPanel:getWidgetByName("lotteryBglayer")
		var.xmlPanel:getWidgetByName("bar"):setLabelVisible(false)
		--GameUtilSenior.asyncload(var.xmlPanel, "panelBg", "ui/image/lottery_border.png")
		--GameUtilSenior.asyncload(var.xmlPanel, "lotteryBg", "ui/image/lottery_bg.jpg")
		var.xmlPanel:getWidgetByName("panelBg"):setLocalZOrder(12)
		var.xmlPanel:getWidgetByName("imgTitle"):setLocalZOrder(13)
		var.xmlPanel:getWidgetByName("panel_close"):setLocalZOrder(14)
		ContainerLottery:updateGameMoney()
		ContainerLottery.initTabs()
		ContainerLottery.initBtns()
		ContainerLottery.updateGameMoney()
	end
	return var.xmlPanel
end

function ContainerLottery.onPanelOpen()
	ContainerLottery.updateMyLotteryRecord()
	GameSocket:PushLuaTable("gui.ContainerLottery.handlePanelData",GameUtilSenior.encode({actionid = "reqShowItems",params={}}))
end

function ContainerLottery.onPanelClose()
	
end

--金币刷新函数
--[[
function ContainerLottery.updateGameMoney(event)
	if var.xmlPanel then
		local mainrole = GameSocket.mCharacter
		local moneyLabel = {
			{name="labVcion",	pre=GameConst.str_vcoin,	value =	mainrole.mVCoin or 0	,	icon = "icon_coin"},
			-- {name="lblBVcoin",	pre=GameConst.str_vcoinb,	value =	mainrole.mVCoinBind or 0,	icon = "icon_coin_bind"},
			-- {name="lblMoney",	pre=GameConst.str_money,	value =	mainrole.mGameMoney or 0,	icon = "icon_money"},
			-- {name="lblBMoney",	pre=GameConst.str_moneyb,	value =	mainrole.mGameMoneyBind or 0,	icon = "icon_money"},
		}
		--建临时表遍历设属性
		for _,v in ipairs(moneyLabel) do
			local curNum = tonumber(var.xmlPanel:getWidgetByName(v.name):getString()) or 0
			var.xmlPanel:getWidgetByName(v.name):setString(v.value)
		end
	end
end--]]


--金币刷新函数
function ContainerLottery:updateGameMoney()
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

function ContainerLottery.handlePanelData(event)
	if event.type ~= "ContainerLottery" then return end
	-- print(event.data)
	local data = GameUtilSenior.decode(event.data)
	if data.cmd =="updateLotteryRecord" then
		ContainerLottery.updatePanel(data)
	elseif data.cmd=="updateShowItems" then
		ContainerLottery.updateShowItems(data.dataTable)
		var.serverday=data.serverday
	elseif data.cmd=="updateBoxsState" then--跟新宝箱的显示
		ContainerLottery.updateBoxsState(data)
	elseif data.cmd=="startSort" then	
		GameSocket:SortItem(3)
	elseif data.cmd=="showBoxTips" then
		if var.noShowTip then 
			ContainerLottery.onBoxDesp(data.desp)
		end
	end
end

--初始化页签
function ContainerLottery.initTabs()
	local function pressTabH(sender)
		local tag = sender:getTag()
		if tag==1 then
			var.xmlLottery:show()
			if var.xmlLotteryBag then var.xmlLotteryBag:hide() end
		elseif tag==2 then
			var.xmlLottery:hide()
			ContainerLottery.initLotteryBag()
			GameSocket:SortItem(3)
		end
	end
	var.tablisth = var.xmlPanel:getWidgetByName("box_tab")
	var.tablisth:addTabEventListener(pressTabH)
	var.tablisth:setSelectedTab(1)
	-- var.tablisth:setTabRes("btn_lottery","btn_lottery_sel")
end

--刷新宝箱显示状态
function ContainerLottery.updateBoxsState(data)
	if not data then return end
	local bar = var.xmlPanel:getWidgetByName("bar")
	for i=1,#data.dataTable do
		local itemData = data.dataTable[i]
		local btnBox = var.xmlPanel:getWidgetByName("btnBox"..i)

		bar:setPercent(data.lotteryNum,50):setLabelVisible(false)
		bar:setFontSize(14):enableOutline(GameBaseLogic.getColor(0x000049),1)
		if data.lotteryNum>=itemData.needNum then
			-- btnBox:loadTextures("btn_box_liang", "btn_box_liang", "", ccui.TextureResType.plistType)
			-- btnBox:setTouchEnabled(true)
			if itemData.ling==1 then
				var.xmlPanel:getWidgetByName("imgLing"..i):setVisible(true)
				-- btnBox:setTouchEnabled(false)
				btnBox:removeChildByName("img_bln")
			else
				var.xmlPanel:getWidgetByName("imgLing"..i):setVisible(false)
				GameUtilSenior.addHaloToButton(btnBox, "btn_normal_light10",nil,75,70)
			end
		else
			-- btnBox:setTouchEnabled(false)
			-- btnBox:loadTextures("btn_box_hui", "btn_box_hui", "", ccui.TextureResType.plistType)
		end

	end
end

--刷新展示的道具
function ContainerLottery.updateShowItems(data)
	for i=1,14 do
		local id = data[i]
		if id then
			local awardItem=var.xmlPanel:getWidgetByName("icon"..i)
			local param={parent=awardItem, typeId=id}
			local itemdef = GameSocket.mItemDesp[id]
			local effectID = 65078
			if itemdef then
				if itemdef.mItemBg > 0 then
					effectID = itemdef.mItemBg + effectID - 3
				end
			end
			GUIItem.getItem(param)
			GameUtilSenior.addEffect(awardItem,"spriteEffect",4,effectID,{x = 33 , y = 32})
		end
	end
end

--打开面板刷新个人寻宝记录
function ContainerLottery.updateMyLotteryRecord()
	var.myLotteryInfos = GameSetting.getInfos(var.roleName, "LotteryList")
	if not var.myLotteryInfos then
		var.myLotteryInfos={}
	else
		ContainerLottery.updateContent(var.myLotteryInfos,"myList",300,2,true,18, false)
	end
end

function ContainerLottery.updatePanel(data)
	var.xmlPanel:getWidgetByName("labJiFen"):setString(data.curJiFen)
	if data.curRecord then
		ContainerLottery.getMyGongXunListInfos(data.curRecord)
	end
	if data.curWorldRecord then
		var.worldListAction = true
		ContainerLottery.updateContent(data.curWorldRecord,"worldList",300,2,false,18, var.worldListAction)
		
	end
	ContainerLottery.updateKeyNum(data.keyNum)
end

--刷新寻宝消耗的显示
function ContainerLottery.updateKeyNum(keynum)
	if keynum>=1 then
		var.xmlPanel:getWidgetByName("labNeed1"):setString("宝藏钥匙*1")
	else
		--var.xmlPanel:getWidgetByName("labNeed1"):setString("花200000金币")
		var.xmlPanel:getWidgetByName("labNeed1"):setString("10充值点")
	end
	if keynum>=5 then
		var.xmlPanel:getWidgetByName("labNeed5"):setString("宝藏钥匙*5")
	else
		--var.xmlPanel:getWidgetByName("labNeed5"):setString("花1000000金币")
		var.xmlPanel:getWidgetByName("labNeed5"):setString("50充值点")
	end
	if keynum>=10 then
		var.xmlPanel:getWidgetByName("labNeed10"):setString("宝藏钥匙*10")
	else
		--var.xmlPanel:getWidgetByName("labNeed10"):setString("花2000000金币")
		var.xmlPanel:getWidgetByName("labNeed10"):setString("100充值点")
	end
end

--每来一条记录并删除多余的
function ContainerLottery.getMyGongXunListInfos(lotteryRecord)
	if not var.myLotteryInfos then
		var.myLotteryInfos = GameSetting.getInfos(var.roleName,"LotteryList")
	end
	table.insert(var.myLotteryInfos,lotteryRecord)
	if #var.myLotteryInfos>LOTTERY_MY_MAX_LENGTH then
		table.remove(var.myLotteryInfos,1)
	end
	GameSetting.setInfos(var.roleName,var.myLotteryInfos,"LotteryList")
	ContainerLottery.updateContent({lotteryRecord},"myList",300,2,false,18, true)
end

--个人信息是每次推新增的，全服信息是每次推10条，所以更新全服信息时要把list的child全remove
function ContainerLottery.updateContent(data,curScrollName,listsize,Margin,removeAll,tsize, action)
	local scroll = var.xmlPanel:getWidgetByName(curScrollName):setItemsMargin(Margin or 0):setClippingEnabled(true)
	scroll:setDirection(ccui.ScrollViewDir.vertical)
	scroll:setScrollBarEnabled(false)
	if removeAll then scroll:removeAllChildren() end
	for i=1, #data do
		local richWidget = GUIRichLabel.new({size=cc.size(listsize,20),space=2})
		local textsize = tsize or 18
		-- local tempInfo = GameUtilSenior.encode(data[i])
		richWidget:setRichLabel(data[i],20,textsize)
		richWidget:setVisible(true)
		scroll:pushBackCustomItem(richWidget)
		if #scroll:getItems()>20 then
			scroll:removeItem(0)
		end
	end

	if action then
		scroll:runAction(cc.Sequence:create(
			cc.DelayTime:create(0.1),
			cc.CallFunc:create(function ()
					scroll:scrollToBottom(1,true)
				end)
			)
		)
	else
		scroll:scrollToBottom(0,true)
	end
end


--宝箱操作
local boxArrs = {"btnBox1","btnBox2","btnBox3","btnBox4","btnBox5"}
function ContainerLottery.initBoxs()
	for i=1,#boxArrs do
		local btn = var.xmlPanel:getWidgetByName(boxArrs[i])
		btn.index=i
   		btn:addTouchEventListener(function (pSender, touchType)
			if touchType == ccui.TouchEventType.began then
				var.noShowTip=true
				GameSocket:PushLuaTable("gui.ContainerLottery.handlePanelData",GameUtilSenior.encode({actionid = "reqBoxAward",params={index=pSender.index}}))
			elseif touchType == ccui.TouchEventType.ended or touchType == ccui.TouchEventType.canceled then	
				var.noShowTip=false
				GDivDialog.handleAlertClose()
			end
		end)
	end
end

-----------------------------------------按钮操作-----------------------------------------------
local btnArrs = {"btnLottery1","btnLottery5","btnLottery10","btnDuiHuan","btnChongZhi","btnGetAll","btnTidy","btnHuiShou"}
function ContainerLottery.initBtns()
	local function prsBtnClick(sender)
		local senderName = sender:getName()
		-- print(senderName)
		if senderName=="btnLottery1" then
			GameSocket:PushLuaTable("gui.ContainerLottery.handlePanelData",GameUtilSenior.encode({actionid = "startLottery",params={times=1}}))
		elseif senderName=="btnLottery5" then
			GameSocket:PushLuaTable("gui.ContainerLottery.handlePanelData",GameUtilSenior.encode({actionid = "startLottery",params={times=5}}))
		elseif senderName=="btnLottery10" then
			GameSocket:PushLuaTable("gui.ContainerLottery.handlePanelData",GameUtilSenior.encode({actionid = "startLottery",params={times=10}}))
		elseif senderName=="btnDuiHuan" then
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "main_convert"})
		elseif senderName=="btnChongZhi" then
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "panel_charge"})
		elseif senderName=="btnGetAll" then--寻宝仓库一键提取
			ContainerLottery.onekeyGetAll()
		elseif senderName=="btnTidy" then--寻宝仓库-整理
			GameSocket:SortItem(3)
		-- elseif senderName=="btnBox1" then
		-- 	ContainerLottery.onBoxDesp()
		-- 	GameSocket:PushLuaTable("gui.ContainerLottery.handlePanelData",GameUtilSenior.encode({actionid = "reqBoxAward",params={index=1}}))
		-- elseif senderName=="btnBox2" then
		-- 	GameSocket:PushLuaTable("gui.ContainerLottery.handlePanelData",GameUtilSenior.encode({actionid = "reqBoxAward",params={index=2}}))
		-- elseif senderName=="btnBox3" then
		-- 	GameSocket:PushLuaTable("gui.ContainerLottery.handlePanelData",GameUtilSenior.encode({actionid = "reqBoxAward",params={index=3}}))
		-- elseif senderName=="btnBox4" then
		-- 	GameSocket:PushLuaTable("gui.ContainerLottery.handlePanelData",GameUtilSenior.encode({actionid = "reqBoxAward",params={index=4}}))
		-- elseif senderName=="btnBox5" then
		-- 	GameSocket:PushLuaTable("gui.ContainerLottery.handlePanelData",GameUtilSenior.encode({actionid = "reqBoxAward",params={index=5}}))
		elseif senderName=="btnHuiShou" then
			ContainerLottery.onekeyHuiShou()
		end
	end
	for i=1,#btnArrs do
		local btn = var.xmlPanel:getWidgetByName(btnArrs[i])
		-- print(btn,"=====================")
		if btn then
			GUIFocusPoint.addUIPoint(btn,prsBtnClick)
		end
	end
	ContainerLottery.initBoxs()
end

---------------------------------------------------------寻宝仓库------------------------------------------------------------
function ContainerLottery.initLotteryBag()
	if not var.xmlLotteryBag then
		var.xmlLotteryBag=GUIAnalysis.load("ui/layout/ContainerLottery_bag.uif")
							:addTo(var.xmlPanel)
   							:align(display.CENTER,675,287)
   							:show()
   							:setLocalZOrder(10)
   		--GameUtilSenior.asyncload(var.xmlLotteryBag, "bagBg", "ui/image/panel_lottery_bag.jpg")
   		ContainerLottery.initBtns()
   		if var.serverday>7 then
   			var.xmlLotteryBag:getWidgetByName("btnHuiShou"):setTitleText("回收2转以下装备")
   		-- elseif var.serverday>7 then
   		-- 	var.xmlLotteryBag:getWidgetByName("btnHuiShou"):setTitleText("回收1转以下装备")
   		else
   			var.xmlLotteryBag:getWidgetByName("btnHuiShou"):setTitleText("回收90级以下装备")
   		end
   		var.xmlLotteryBag:getWidgetByName("btnHuiShou"):setTitleText("回收全部装备")
	else
		var.xmlLotteryBag:show()
	end
	ContainerLottery.initBagList()
end

--初始化寻宝背包列表
function ContainerLottery.initBagList(data)

	local function updateList(item)
		local index = item.tag - 1 + 3000
		local param = {
			parent = item,
			pos = index,
			-- titleText = GameConst.str_get_out,
			-- iconType = GameConst.ICONTYPE.TREASURE,
			-- tipsType = GameConst.TIPS_TYPE.TREASURE,
			tipsType = GameConst.TIPS_TYPE.UPGRADE,
			-- callBack = function ()
			-- 	-- GameSocket:UndressItem(index)
			-- end,
			enmuPos = 6,
			customCallFunc = function()
				GameSocket:takeItemFromLottory(index)
			end,
			-- doubleCall = function()
			-- 	GameSocket:takeItemFromLottory(index)
			-- end,
			compare = true
		}
		GUIItem.getItem(param)
	end
	local listBag = var.xmlLotteryBag:getWidgetByName("listBag")
	listBag:reloadData(300,updateList):setSliderVisible(false)
end

--寻宝仓库物品一键提取
function ContainerLottery.onekeyGetAll()
	local bagNum = GameSocket:getLeftBagNum()--背包空余格子数
	local textInfo
	if bagNum > 0 then
		local index = 0
		for i=0,300 do
			local netItem = GameSocket:getNetItem(3000+i)
			if netItem then
				GameSocket:UndressItem(3000+i)
				index = index + 1
			end
			if index >= bagNum then
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

--一键回收转生装备
function ContainerLottery.onekeyHuiShou()
	-- local zLev = 1
	-- if var.serverday>7 then zLev=2 end
	local posTable = {}
	-- for i=0,300 do
	-- 	local nItem = GameSocket:getNetItem(3000+i)
	-- 	if nItem then
	-- 		local itemDef = GameSocket:getItemDefByID(nItem.mTypeID)
	-- 		if itemDef and itemDef.mNeedZsLevel<=zLev and GameBaseLogic.IsEquipment(nItem.mTypeID) and itemDef.mEquipType<11 then
	-- 			table.insert(posTable,#posTable+1,(3000+i))
	-- 		end
	-- 	end
	-- end
	-- if #posTable>0 then
		GameSocket:PushLuaTable("gui.PanelUpgrade.onPanelData", GameUtilSenior.encode({actionid = "lotteryhuishou",param = posTable}))
	-- else
	-- 	GameSocket:alertLocalMsg("宝藏背包无可回收装备！","alert")
	-- end
end

function ContainerLottery.onBoxDesp(desp)
	local mParam = {
		name = GameMessageCode.EVENT_PANEL_ON_ALERT,
		panel = "tips", 
		infoTable = desp,
		visible = true, 
	}
	GameSocket:dispatchEvent(mParam)
end


return ContainerLottery
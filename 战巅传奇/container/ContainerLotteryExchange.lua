local ContainerLotteryExchange={}
local var = {}
local LOTTERY_MY_MAX_LENGTH = 30

function ContainerLotteryExchange.initView()
	var = {
		xmlPanel,
		tablisth
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerLotteryExchange.uif");
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerLotteryExchange.handlePanelData)

		GameUtilSenior.asyncload(var.xmlPanel, "imgBg", "ui/image/panel_lottery_exchangbg.jpg")
		ContainerLotteryExchange.initTabs()
		var.xmlPanel:getWidgetByName("btnLottery"):addClickEventListener(function (sender)
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "extend_lottory"})
		end)
	end
	return var.xmlPanel
end

function ContainerLotteryExchange.onPanelOpen()
	var.tablisth:setSelectedTab(1)
end

function ContainerLotteryExchange.onPanelClose()
	
end

function ContainerLotteryExchange.handlePanelData(event)
	if event.type ~= "ContainerLotteryExchange" then return end
	local data = GameUtilSenior.decode(event.data)
	if data.cmd =="fresh" then
		var.xmlPanel:getWidgetByName("curJiFen"):setString(data.curJiFen)
		ContainerLotteryExchange.initExchangeList(data.exchangeData)
	elseif data.cmd=="updateLotteryRecord" then
		ContainerLotteryExchange.updateContent(data)
	elseif data.cmd=="" then

	elseif data.cmd=="" then	

	end
end

--初始化页签
function ContainerLotteryExchange.initTabs()
	local function pressTabH(sender)
		local tag = sender:getTag()
		GameSocket:PushLuaTable("gui.ContainerLotteryExchange.handlePanelData", GameUtilSenior.encode({actionid = "fresh",tabIdx = tag}))
	end
	var.tablisth = var.xmlPanel:getWidgetByName("box_tab")
	var.tablisth:addTabEventListener(pressTabH)
	-- var.tablisth:setTabRes("btn_lottery","btn_lottery_sel")
end

--刷新兑换列表
function ContainerLotteryExchange.initExchangeList(data)
	if not GameUtilSenior.isTable(data) then return end
	local listExchange = var.xmlPanel:getWidgetByName("listExchange")
	local function updateList(subItem)
		local d = data[subItem.tag]
		subItem:getWidgetByName("labName"):setString(d.name)
		local itemDef = GameSocket:getItemDefByID(d.typeId)
		if itemDef then
			subItem:getWidgetByName("labName"):setColor(GameBaseLogic.getItemColor(itemDef.mEquipLevel))
		end
		subItem:getWidgetByName("needItem"):setString(d.needName):setVisible(d.needId>0)
		subItem:getWidgetByName("img_add"):setVisible(d.needId>0)
		itemDef = GameSocket:getItemDefByID(d.needId)
		if itemDef then
			subItem:getWidgetByName("needItem"):setColor(GameBaseLogic.getItemColor(itemDef.mEquipLevel))
		end
		subItem:getWidgetByName("needJiFen"):setString(string.format("%d积分",d.needScore))
		GUIItem.getItem({
			parent = subItem:getWidgetByName("icon"),
			typeId = d.typeId,
			num = d.itemNum,
			bind = 2-d.bind,
		})
		local btnExchange = subItem:getWidgetByName("btnExchange")
		btnExchange.data = d
		btnExchange:addClickEventListener(ContainerLotteryExchange.clickBuy)
	end
	listExchange:reloadData(#data,updateList):setSliderVisible(false)
end

function ContainerLotteryExchange.clickBuy(sender)
	if GameUtilSenior.hitTest(var.xmlPanel:getWidgetByName("listExchange"), sender) then
		GameSocket:PushLuaTable("gui.ContainerLotteryExchange.handlePanelData", GameUtilSenior.encode({actionid = "buy",id = sender.data.id}))
	end
end

--个人信息是每次推新增的，全服信息是每次推10条，所以更新全服信息时要把list的child全remove
function ContainerLotteryExchange.updateContent(data)
	var.xmlPanel:getWidgetByName("curJiFen"):setString(data.curJiFen)
	
	local scroll = var.xmlPanel:getWidgetByName("exchangeList"):setItemsMargin(2):setClippingEnabled(true)
	scroll:setDirection(ccui.ScrollViewDir.vertical)
	scroll:setScrollBarEnabled(false)
	local listData
	if data.curWorldRecord then
		scroll:removeAllChildren()
		listData = data.curWorldRecord
	elseif data.myRecord then
		listData = {data.myRecord}
	end
	for i=1, #listData do
		local record = listData[i]
		local richWidget = GUIRichLabel.new({size=cc.size(250,20),space=2})
		local richtext = string.format("<font color='#1debde'>%s</font><font color='#9b9079'>兑换:</font><font color='#a77602'><p>##%s##</p></font>",record[1],record[2])
		richWidget:setRichLabel(richtext,"20",20)
		richWidget:setVisible(true)
		scroll:pushBackCustomItem(richWidget)
		if #scroll:getItems()>10 then
			scroll:removeItem(0)
		end
	end

	scroll:runAction(cc.Sequence:create(
		cc.DelayTime:create(0.1),
		cc.CallFunc:create(function ()
				scroll:scrollToBottom(1,true)
			end)
		)
	)
end

return ContainerLotteryExchange
local ContainerEarnMoney = {}
local var = {}

function ContainerEarnMoney.initView()
	var = {
		xmlPanel,
		curXmlTab=nil,
		xmlYaori=nil,
		yrTabData=nil,
		xmlMingyue=nil,
		myTabData=nil,
		xmlXinghui=nil,
		xhTabData=nil,
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerEarnMoney.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket, var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerEarnMoney.handlePanelData)
		ContainerEarnMoney.initTabs()
		return var.xmlPanel
	end
end

function ContainerEarnMoney.initTabs()
	local function pressTabH(sender)
		local tag = sender:getTag()
		if var.curXmlTab then var.curXmlTab:hide() end;
		if tag==1 then
			var.curXmlTab=ContainerEarnMoney.initYr();
		elseif tag==2 then
			var.curXmlTab=ContainerEarnMoney.initMy()
		elseif tag==3 then
			var.curXmlTab=ContainerEarnMoney.initXh()
		end
	end
	var.tablisth = var.xmlPanel:getWidgetByName("box_tab")

	-- for i,v in ipairs(btnTabName) do
	-- 	var.tablisth:getItemByIndex(i):setName(v)
	-- end

	var.tablisth:addTabEventListener(pressTabH)
	var.tablisth:setSelectedTab(1)
	var.tablisth:setScaleEnabled(false)
	--var.tablisth:setTabRes("btn_new21","btn_new21_sel")
	var.tablisth:setTabColor(GameBaseLogic.getColor(0xc3ad88),GameBaseLogic.getColor(0xfddfae))
end
local yr_node = {"lbl_remain","btn_invest1","list_award1",}
function ContainerEarnMoney.initYr()
	if not var.xmlYaori then
		var.xmlYaori=GUIAnalysis.load("ui/layout/ContainerEarnMoney_yr.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
							:align(display.LEFT_BOTTOM,0,0)
							:show();
		ContainerEarnMoney.createUiTable(var.xmlYaori,yr_node);
		var.xmlYaori:getWidgetByName("btn_invest1"):addClickEventListener(function (sender)
			GameSocket:PushLuaTable("gui.ContainerEarnMoney.handlePanelData",GameUtilSenior.encode({actionid="investyr"}))
		end)
	else
		var.xmlYaori:show();
	end
	GameSocket:PushLuaTable("gui.ContainerEarnMoney.handlePanelData", GameUtilSenior.encode({actionid = "initYr"}))
	return var.xmlYaori
end
function ContainerEarnMoney.updateYrTab(data,noReplace,remainnum,investstate)
	var.xmlYaori:getWidgetByName("lbl_remain"):setString(""..remainnum);
	if investstate == 1 then
		var.xmlYaori:getWidgetByName("btn_invest1"):setTouchEnabled(false):setTitleText("已投资");
	else
		var.xmlYaori:getWidgetByName("btn_invest1"):setTouchEnabled(true):setTitleText("投资(剩"..remainnum.."份)");
	end
	if data and GameUtilSenior.isTable(data) then
		var.yrTabData = data.awardlist;
		var.xmlYaori:getWidgetByName("needVcoin"):setText(data.needvcoionStr)
		var.xmlYaori:getWidgetByName("getVcoin"):setText(data.getvcoinStr)
		if not noReplace then
			var.xmlYaori.ui["list_award1"]:reloadData(table.nums(var.yrTabData),function(subItem)
				local index = subItem.tag
				local needData = var.yrTabData[index];
				local levelinfo = ""..needData.needlevel.."级领取";
				if needData.isZs > 0 then
					levelinfo = ""..needData.needlevel.."转领取";
				end 
				subItem:getWidgetByName("lbl_item_name1"):setString(levelinfo)
				if needData.getState == 1 then
					subItem:getWidgetByName("btn_getAward1"):setTitleText("已领取"):setTouchEnabled(false)
				else
					subItem:getWidgetByName("btn_getAward1"):setTitleText(levelinfo):setTouchEnabled(true):addClickEventListener(function (sender)
						GameSocket:PushLuaTable("gui.ContainerEarnMoney.handlePanelData", GameUtilSenior.encode({actionid = "getawardyr",tag = index}))
					end)
				end
				local modelItem = subItem:getWidgetByName("img_item_bg1");
				if needData then
					needData.parent = modelItem;
					GUIItem.getItem(needData);
					modelItem:setSwallowTouches(false)
					modelItem:show();
				else
					modelItem:hide();
				end
			end)
		else
			var.xmlYaori.ui["list_award1"]:updateCellInView()
		end
	end
end
local my_node = {"btn_invest2","list_award2",}
function ContainerEarnMoney.initMy()
	if not var.xmlMingyue then
		var.xmlMingyue=GUIAnalysis.load("ui/layout/ContainerEarnMoney_my.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
							:align(display.LEFT_BOTTOM,0,0)
							:show();
		ContainerEarnMoney.createUiTable(var.xmlMingyue,my_node);
		var.xmlMingyue:getWidgetByName("btn_invest2"):addClickEventListener(function (sender)
			GameSocket:PushLuaTable("gui.ContainerEarnMoney.handlePanelData",GameUtilSenior.encode({actionid="investmy"}))
		end)
	else
		var.xmlMingyue:show();
	end
	GameSocket:PushLuaTable("gui.ContainerEarnMoney.handlePanelData", GameUtilSenior.encode({actionid = "initMy"}))
	return var.xmlMingyue
end
function ContainerEarnMoney.updateMyTab(data,noReplace,remainnum)
	if remainnum > 0 then
		var.xmlMingyue:getWidgetByName("lbl_my_dateno"):setVisible(false):setString("当前投资第"..remainnum.."天");
		var.xmlMingyue:getWidgetByName("btn_invest2"):setTouchEnabled(false):setTitleText("已投资");
	else
		var.xmlMingyue:getWidgetByName("lbl_my_dateno"):setVisible(false)
		var.xmlMingyue:getWidgetByName("btn_invest2"):setTouchEnabled(true):setTitleText("立即投资");
	end
	if data and GameUtilSenior.isTable(data) then
		var.myTabData = data.awardlist;
		var.xmlMingyue:getWidgetByName("needVcoin"):setText(data.needvcoionStr)
		var.xmlMingyue:getWidgetByName("getVcoin"):setText(data.getvcoinStr)
		if not noReplace then
			var.xmlMingyue.ui["list_award2"]:reloadData(table.nums(var.myTabData),function(subItem)
				local index = subItem.tag
				local needData = var.myTabData[index];
				local dayinfo = "第"..needData.needdays.."天领取";
				subItem:getWidgetByName("lbl_item_name2"):setString(dayinfo)
				if needData.getState == 1 then
					subItem:getWidgetByName("btn_getAward2"):setTitleText("已领取"):setTouchEnabled(false)
				else
					subItem:getWidgetByName("btn_getAward2"):setTitleText(dayinfo):setTouchEnabled(true):addClickEventListener(function (sender)
					GameSocket:PushLuaTable("gui.ContainerEarnMoney.handlePanelData", GameUtilSenior.encode({actionid = "getawardmy",tag = index}))
					end)
				end
				local modelItem = subItem:getWidgetByName("img_item_bg2");
				if needData then
					needData.parent = modelItem;
					GUIItem.getItem(needData);
					modelItem:setSwallowTouches(false)
					modelItem:show();
				else
					modelItem:hide();
				end
			end)
		else
			var.xmlMingyue.ui["list_award2"]:updateCellInView()
		end
	end
end
local xh_node = {"btn_invest3","list_award3",}
function ContainerEarnMoney.initXh()
	if not var.xmlXinghui then
		var.xmlXinghui=GUIAnalysis.load("ui/layout/ContainerEarnMoney_xh.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
							:align(display.LEFT_BOTTOM,0,0)
							:show();
		ContainerEarnMoney.createUiTable(var.xmlXinghui,xh_node);
		var.xmlXinghui:getWidgetByName("btn_invest3"):addClickEventListener(function (sender)
			GameSocket:PushLuaTable("gui.ContainerEarnMoney.handlePanelData",GameUtilSenior.encode({actionid="investxh"}))
		end)
	else
		var.xmlXinghui:show();
	end
	GameSocket:PushLuaTable("gui.ContainerEarnMoney.handlePanelData", GameUtilSenior.encode({actionid = "initXh"}))
	return var.xmlXinghui
end
function ContainerEarnMoney.updateXhTab(data,noReplace,remainnum)
	if remainnum > 0 then
		var.xmlXinghui:getWidgetByName("lbl_xh_dateno"):setVisible(false):setString("当前投资第"..remainnum.."天");
		var.xmlXinghui:getWidgetByName("btn_invest3"):setTouchEnabled(false):setTitleText("已投资");
	else
		var.xmlXinghui:getWidgetByName("lbl_xh_dateno"):setVisible(false)
		var.xmlXinghui:getWidgetByName("btn_invest3"):setTouchEnabled(true):setTitleText("立即投资");
	end
	if data and GameUtilSenior.isTable(data) then
		var.xhTabData = data.awardlist;
		var.xmlXinghui:getWidgetByName("needVcoin"):setText(data.needvcoionStr)
		var.xmlXinghui:getWidgetByName("getVcoin"):setText(data.getvcoinStr)
		if not noReplace then
			var.xmlXinghui.ui["list_award3"]:reloadData(table.nums(var.xhTabData),function(subItem)
				local index = subItem.tag
				local needData = var.xhTabData[index];
				local dayinfo = "第"..needData.needdays.."天领取";
				subItem:getWidgetByName("lbl_item_name3"):setString(dayinfo)
				if needData.getState == 1 then
					subItem:getWidgetByName("btn_getAward3"):setTitleText("已领取"):setTouchEnabled(false)
				else
					subItem:getWidgetByName("btn_getAward3"):setTitleText(dayinfo):setTouchEnabled(true):addClickEventListener(function (sender)
						GameSocket:PushLuaTable("gui.ContainerEarnMoney.handlePanelData", GameUtilSenior.encode({actionid = "getawardxh",tag = index}))
					end)
				end
				local modelItem = subItem:getWidgetByName("img_item_bg3");
				if needData then
					needData.parent = modelItem;
					GUIItem.getItem(needData);
					modelItem:setSwallowTouches(false)
					modelItem:show();
				else
					modelItem:hide();
				end
			end)
		else
			var.xmlXinghui.ui["list_award3"]:updateCellInView()
		end
	end
end
function ContainerEarnMoney.createUiTable(parent,array)
	parent.ui = {};
	for _,v in ipairs(array) do
		local node = parent:getWidgetByName(v);
		if node then
			parent.ui[v] = node
		end
	end
	return parent.ui
end
-------------------------------------

function ContainerEarnMoney.onPanelOpen()
	GameSocket:PushLuaTable("gui.ContainerEarnMoney.handlePanelData",GameUtilSenior.encode({actionid = "fresh"}))
end

function ContainerEarnMoney.handlePanelData(event)
	if event.type ~= "ContainerEarnMoney" then return end
	local pdata = GameUtilSenior.decode(event.data)
	--print(pdata.childCmd)
	if pdata.cmd=="yr" then
		if pdata.childCmd=="updateList" then
			ContainerEarnMoney.updateYrTab(pdata.table,pdata.noReplace,pdata.remainnum,pdata.investState);
		end
	elseif pdata.cmd=="my" then
		if pdata.childCmd=="updateList" then
			ContainerEarnMoney.updateMyTab(pdata.table,pdata.noReplace,pdata.buydates);
		end
	elseif pdata.cmd=="xh" then
		if pdata.childCmd=="updateList" then
			ContainerEarnMoney.updateXhTab(pdata.table,pdata.noReplace,pdata.buydates);
		end
	end
	-- if pdata.cmd == "fresh" then
	-- 	ContainerEarnMoney.freshPanel(pdata)
	-- elseif pdata.cmd  =="freshPage" then
	-- 	ContainerEarnMoney.freshPage(pdata)
	-- end
end

function ContainerEarnMoney.getAwardByIndex(sender)
	sender:getVirtualRenderer():setState(sender.bright and 0 or 1)

	GameSocket:PushLuaTable("gui.ContainerEarnMoney.handlePanelData",GameUtilSenior.encode({actionid = "getaward",index = sender.index}))
end

function ContainerEarnMoney.freshPage(svrData)
	
end

function ContainerEarnMoney.freshPanel(svrData)
	
end

function ContainerEarnMoney.onPanelClose()
end

return ContainerEarnMoney

--百服活动

local ContainerMaterial={}
local var = {}

function ContainerMaterial.initView()
	var = {
		xmlPanel,
		tabList,
		tabOnline,
		curSender,--当前页签按钮
		curTab,--当前页签显示的模
		content,
		pageData,
		pageName,	--存储当前属于那个页面 
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerMaterial.uif");

	if var.xmlPanel then
		var.content = var.xmlPanel:getWidgetByName("content")
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerMaterial.handlePanelData)
	end
	return var.xmlPanel
end

function ContainerMaterial.onPanelOpen()
	GameSocket:PushLuaTable("npc.party.cailiao.handlePanelData",GameUtilSenior.encode({actionid = "open_panel"}))
end

function ContainerMaterial.onPanelClose()
	var.content:getWidgetByName("txt_times"):setString("")
	var.content:getWidgetByName("txt_juan"):setString("")
	var.content:getWidgetByName("txt_time"):setString("")
	for i=1,2 do
		local itemIcon = var.content:getWidgetByName("item"..i)
		GUIItem.getItem({parent=itemIcon})
	end
	var.xmlPanel:getChildByName("tabList"):hide()
end

function ContainerMaterial.handlePanelData(event)
	local data=GameUtilSenior.decode(event.data)
	if event.type=="ContainerMaterial" then 
		if data.cmd == "req_open" then--充值宝箱
			ContainerMaterial.initTabList(data.data)
		end
	end
	if event.type=="ContainerMaterial_go" then 
			for i=1,#data.award do
				local itemIcon = var.content:getWidgetByName("item"..i)
				if data.award[i] then
					itemIcon:setVisible(true)
					local param={parent=itemIcon , typeId=data.award[i].id , num = data.award[i].num}
					GUIItem.getItem(param)
				else
					itemIcon:setVisible(false)
				end
			end
			var.content:getWidgetByName("txt_times"):setString(data.times.."次")
			var.content:getWidgetByName("txt_juan"):setString(data.juan)
			var.content:getWidgetByName("txt_time"):setString(data.time.."分钟")
			if GameBaseLogic.GetMainRole():NetAttr(GameConst.net_level)>=data.lv then
				var.content:getWidgetByName("txt_level"):setString(data.lv.."级"):setTextColor(GameBaseLogic.getColor(0x18d129))
			else
				var.content:getWidgetByName("txt_level"):setString(data.lv.."级"):setTextColor(GameBaseLogic.getColor(0xff0000))
			end
			local function prsBtnItem(sender)
				GameSocket:PushLuaTable("npc.party.cailiao.goto",GameUtilSenior.encode({actionid =data.index}))
			end 
			local btnLing = var.content:getWidgetByName("btnLingQu")
			GUIFocusPoint.addUIPoint(btnLing , prsBtnItem)	
	end 
end

--个人副本寻找默认显示页签
function ContainerMaterial.getSelectTab(data)
	if data then
		for i=1,#data do
			local itemData = data[i]
			if itemData.useTimes and itemData.useTimes<itemData.allTimes then
				return i
			end
		end
	end
	return 1
end

--初始化页签
function ContainerMaterial.initTabList(data)
	local nameTable = data
	local function updateTabList(item)
		local btnTab = item:getWidgetByName("btnMode")
		btnTab:setTitleText(nameTable[item.tag].title):getTitleRenderer():enableOutline(cc.c4b(0, 0, 0,255),1)
		btnTab.uif = nameTable[item.tag].uif
		btnTab.index = nameTable[item.tag].index
		--btnTab.name = nameTable[item.tag].name
		btnTab:setTouchEnabled(true):setSwallowTouches(false)
		GUIFocusPoint.addUIPoint(btnTab , ContainerMaterial.changeTab)
		-- if btnTab.name ~= var.pageName then
		-- 	btnTab:setBrightStyle(0):setTitleColor(cc.c3b(241, 232, 208))
		-- else
		-- 	btnTab:setBrightStyle(1):setTitleColor(cc.c3b(241, 232, 208))
		-- end
		--打开面板初始走第一标签，只走一次
		-- if var.pageName ~= nil then return end
		if item.tag==ContainerMaterial.getSelectTab(data) then
			ContainerMaterial.changeTab(btnTab)
		end
	end
	local tabList = var.xmlPanel:getChildByName("tabList"):show()
	tabList:reloadData(#nameTable,updateTabList)
end

--切换页签显示
--local itemTable={10007,10008,10067,10110,10111,10001,10176,19009}
function ContainerMaterial.changeTab(sender)
	var.pageName = sender.index
	--var.pageName = sender.name
	if var.curSender then var.curSender:setBrightStyle(0):setTitleColor(cc.c3b(241, 232, 208)) end
	sender:setBrightStyle(1):setTitleColor(cc.c3b(241, 232, 208))
	var.curSender = sender
	--if var.curTab then var.curTab:setVisible(false) end
	

	GameSocket:PushLuaTable("npc.party.cailiao.show_count", GameUtilSenior.encode({actionid = sender.index,})) 
end



return ContainerMaterial
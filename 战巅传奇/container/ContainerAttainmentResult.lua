local ContainerAttainmentResult = {}
local var = {}

local tabName = {
	"经验加成","攻击加成","功勋加成","在线奖励","其他"
}

function ContainerAttainmentResult.initView()
	var = {
		xmlPanel,
		tab,
	}

	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerAttainmentResult.uif")
	if var.xmlPanel then
		--GameUtilSenior.asyncload(var.xmlPanel, "img_ach_award_bg", "ui/image/img_ach_award_bg.png")
		var.tab = var.xmlPanel:getWidgetByName("tab")
		var.tab._conf.scale = false
		var.tab:setTabRes("tab_v4","tab_v4_sel"):setTabColor(GameBaseLogic.getColor(0xf1e8d0),GameBaseLogic.getColor(0xf1e8d0))
		var.tab:addTabEventListener(ContainerAttainmentResult.pushTabButton)

		local btnClose = GUIMain.m_GDivContainer:addButtonClose(var.xmlPanel:getWidgetByName("panel"))
		if btnClose then
			GUIFocusPoint.addUIPoint(btnClose,	function(pSender)
				var.xmlPanel:hide()
			end)
		end
		var.xmlPanel:getWidgetByName("img_ach_award_bg"):setTouchEnabled(true)
		var.xmlPanel:getWidgetByName("render"):hide()
		var.xmlPanel:getWidgetByName("renderAdd"):hide()
		
		var.xmlPanel:setTouchEnabled(true):setSwallowTouches(true):addClickEventListener(function ()
			var.xmlPanel:hide()
		end)
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerAttainmentResult.handlePanelData)

		return var.xmlPanel
	end
end

function ContainerAttainmentResult.onPanelOpen()
	var.tab:hide()
	GameSocket:PushLuaTable("gui.ContainerAttainment.onPanelData", GameUtilSenior.encode({actionid = "getTabList"}))
end

function ContainerAttainmentResult.pushTabButton(psender)
	GameSocket:PushLuaTable("gui.ContainerAttainment.onPanelData", GameUtilSenior.encode({actionid = "achieveAward",tag = psender:getTag()}))
end

function ContainerAttainmentResult.handlePanelData(event)
	if event.type ~= "ContainerAttainmentResult" then return end
	local serverTable = GameUtilSenior.decode(event.data)
	if serverTable.cmd == "updateAwardList" then
		ContainerAttainmentResult.freshRightList(serverTable.data)
	elseif serverTable.cmd =="getTabList" then
		local hidetabdata = {}
		local showTab
		for k,v in pairs(serverTable.data) do
		 	if not v then
		 		table.insert(hidetabdata,k)
		 	elseif not showTab then
		 		showTab = k
		 	end
		end
		var.tab:show()
		var.tab:hideTab(hidetabdata)
		if showTab then
			var.tab:setSelectedTab(showTab);
		end
	end
end

function ContainerAttainmentResult.clickListItem(sender)
	local listAchieve = var.xmlPanel:getWidgetByName("listAchieve")

	local index = listAchieve:getIndex(sender)
	local nextItem = listAchieve:getItem(index+1)
	local datas = sender.data
	if not nextItem or not nextItem.add then
		local renderAdd = var.xmlPanel:getWidgetByName("renderAdd")
		sender:getWidgetByName("awardbg"):loadTexture("rank_selBorder1_scale3",ccui.TextureResType.plistType)
		for i=1,#datas do
			local d = datas[i]
			local modeladd = renderAdd:clone():show()
			modeladd:getWidgetByName("lblach"):setString(d.name)
			modeladd:getWidgetByName("lblachdesp"):setString(d.desp)
			modeladd.add = true
			
			-- local achievepngs = GameBaseLogic.seekAchievePng(d.name)
			local res =  "ui/image/"..d.huizhang..".png"

			--modeladd:getWidgetByName("achIcon"):loadTexture(res,ccui.TextureResType.localType):setScale(0.3)
			
			asyncload_callback(res, modeladd, function(path, texture)
				modeladd:loadTexture(path):setScale(0.3)
			end)
			-- modeladd:getWidgetByName("img_desp"):loadTexture(GameBaseLogic.seekDespPng(d.desp),ccui.TextureResType.plistType)
			-- modeladd:getWidgetByName("img_desp"):loadTexture("ui/image/"..d.jiangli..".png",ccui.TextureResType.localType)

			listAchieve:insertCustomItem(modeladd,index+i)
		end
	else
		sender:getWidgetByName("awardbg"):loadTexture("rank_border1_scale3",ccui.TextureResType.plistType)
		for i=#datas,1,-1 do
			listAchieve:removeItem(index+i)
		end
	end
end

function ContainerAttainmentResult.freshRightList(data)
	local listAchieve = var.xmlPanel:getWidgetByName("listAchieve")
	listAchieve:removeAllItems()
	local sortdata = {}
	for _,v in pairs(data) do
		sortdata[v.type] = sortdata[v.type] or {}
		table.insert(sortdata[v.type],v)
	end
	if table.nums(sortdata)>0 then
		local render = var.xmlPanel:getWidgetByName("render")
		for _,vd in pairs(sortdata) do
			local model = render:clone():setTouchEnabled(true):show()
			model.data = vd
			model.add = false
			model:addClickEventListener(ContainerAttainmentResult.clickListItem)
			-- model:getWidgetByName("ImgAchieve"):loadTexture(GameBaseLogic.seekDespPng(data[i].desp),ccui.TextureResType.plistType):setVisible(true)
			local desp = vd[1].desp
			local num = 0
			for k,v in pairs(vd) do
				local strn = string.gsub(v.desp,"[^0-9]","")
				num = num + checknumber(strn)
			end
			desp = string.gsub(desp,"%d+",num)
			model:getWidgetByName("lblAchieve"):setString(desp)
			listAchieve:pushBackCustomItem(model)
		end
	end	
end

return ContainerAttainmentResult
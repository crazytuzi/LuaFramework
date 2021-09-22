local ContainerConsolidate = {}
local var = {}
local imgColumn = {"img_strengthen_level","img_strengthen_equip","img_strengthen_power","img_strengthen_material_new"}
function ContainerConsolidate.initView(extend)
	var = {
		xmlPanel,
		defaultTab = 1,
		tabList,
		PageView,
		changeClose,
		dataCount=1,
		curIdx =1,
		pageData,
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerConsolidate.uif")
	if var.xmlPanel then
		--GameUtilSenior.asyncload(var.xmlPanel, "img_inner_bg", "ui/image/img_strengthen_bg.png")

		var.tabList = var.xmlPanel:getWidgetByName("tabList")
			:setTabRes("btn_new21", "btn_new21_sel")
			:setScaleEnabled(false)
			:setTabColor(GameBaseLogic.getColor(0xc3ad88),GameBaseLogic.getColor(0xfddfae))
			:setFontSize(22)
		var.tabList:addTabEventListener(function(sender)
			GameSocket:PushLuaTable("gui.ContainerConsolidate.onPanelData", GameUtilSenior.encode({actionid = "fresh",tab = sender:getTag()}))
		end)
		for i=1,4 do
			var.xmlPanel:getWidgetByName("icon"..i):hide()
		end
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerConsolidate.handlePanelData)

		return var.xmlPanel
	end
end

function ContainerConsolidate.onPanelOpen(extend)
	local tab = var.defaultTab
	if extend.tab then
		tab = extend.tab
	end
	var.tabList:setSelectedTab(tab)
end

function ContainerConsolidate.handlePanelData(event)
	if event.type ~= "ContainerConsolidate" then return end
	local result = GameUtilSenior.decode(event.data)
	if result.cmd == "fresh" then
		ContainerConsolidate.freshPanel(result)
	end
end

function ContainerConsolidate.freshPanel(result)
	if GameUtilSenior.isTable(result.item) then
		for i=1,4 do
			GUIItem.getItem({
				parent = var.xmlPanel:getWidgetByName("icon"..i):show(),
				typeId = result.item[i],
			})
		end
	else
		for i=1,4 do
			var.xmlPanel:getWidgetByName("icon"..i):hide()
		end
	end
	var.xmlPanel:getWidgetByName("img_tab_column"):loadTexture(imgColumn[var.tabList:getCurIndex()], ccui.TextureResType.plistType)
	local recommandList = var.xmlPanel:getWidgetByName("recommandList")
	local function clickLabel(sender)
		GameSocket:PushLuaTable("gui.ContainerConsolidate.onPanelData", GameUtilSenior.encode({
			actionid = "operate",
			tab = var.tabList:getCurIndex(),
			index = sender.index
		}))
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL, str = "extend_strengthen"})

	end
	local function updateList(subItem)
		local index = subItem.tag
		local d = result.panelData[index]
		subItem:getWidgetByName("tujing"):setString("【"..d.name.."】")
		local operate = subItem:getWidgetByName("operate")
		operate:setString(d.operate):setTouchEnabled(true)
		if not operate.index then
			GameUtilSenior.addUnderLine(operate, GameBaseLogic.getColor4f(0x19F319), 1,1)
		end
		operate.index = index
		operate:addClickEventListener(clickLabel)
		if not d.init then
			-- local seq = {}
			for i=1,5 do
				subItem:getWidgetByName("star"..i):loadTexture(i<=d.star and "img_star_stren_light" or "img_star_stren_gray", ccui.TextureResType.plistType) 
				-- table.insert(seq,cca.delay(i*0.02));
				-- table.insert(seq,cc.TargetedAction:create(subItem:getWidgetByName("star"..i),cca.cb(function(target) 
				-- 	target:loadTexture(i<=d.star and "img_star_light" or "img_star_gray", ccui.TextureResType.plistType)  
				-- end)))
			end
			-- subItem:runAction(cca.seq(seq))
			d.init = true
		end

	end
	recommandList:reloadData(#result.panelData,updateList)
end

function ContainerConsolidate.onPanelClose()
	
end

return ContainerConsolidate
local V9_FengShen = {}
local var = {}


local currentDaLuInfoIndex = 0
local currentDaLuInfo = {}

function V9_FengShen.onPanelOpen(event)

end

function V9_FengShen.initView(extend)
	--GameSocket:alertLocalMsg("该功能暂未开放", "alert")
	
	var = {
		items={},
		xmlPanel,
		index=1,
		data="",
		page=1,
		totalPage=1,
		dir=1,
	}
	--var.mapList = extend.result.mapList
	var.xmlPanel = GUIAnalysis.load("ui/layout/V9_FengShen.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V9_FengShen.handlePanelData)

		--var.xmlPanel:getWidgetByName("box_tab"):setTabRes("V9_FengShen_34.png","V9_FengShen_33.png",ccui.TextureResType.plistType)
		
		--V9_FengShen.showTitleAnimation()
		
		var.xmlPanel:getWidgetByName("navi_pre"):addClickEventListener(function ( sender )
			if var.page-1>=1 then
				var.dir=2
				GameSocket:PushLuaTable("gui.V9_FengShen.handlePanelData",GameUtilSenior.encode({actionid = "getMessage",page=var.page-1}))
			end
		end)
		var.xmlPanel:getWidgetByName("navi_next"):addClickEventListener(function ( sender )
			if var.page+1<=var.totalPage then
				var.dir=1
				GameSocket:PushLuaTable("gui.V9_FengShen.handlePanelData",GameUtilSenior.encode({actionid = "getMessage",page=var.page+1}))
			end
		end)
		
		GameSocket:PushLuaTable("gui.V9_FengShen.handlePanelData",GameUtilSenior.encode({actionid = "getMessage",page=0}))
		return var.xmlPanel
	end
	
end

function V9_FengShen.showDescList(data)
	--GameUtilSenior.print_table(data.curAttrList)
	local turnTo = false
	if var.data~=nil and var.data.list~=nil and #var.data.list>0 then
		for i=1,#data.list do
			if var.dir==1 then
				var.data.list[#var.data.list+1] = data.list[i]
			else
				table.insert(var.data.list,i,data.list[i])
			end
		end
		turnTo = true
	else
		var.data=data
	end
	local ListView = var.xmlPanel:getWidgetByName("ListView")
	ListView:reloadData(#var.data.list,V9_FengShen.updateBossName)
	if turnTo then
		if var.dir==2 then
			ListView:setContentOffset({x=-675,y=0})
			ListView:autoMoveToIndex(1)
		else
			ListView:autoMoveToIndex(4)
		end
		local function exitDelay()
			if var.dir==1 then
				for i=1,3 do
					table.remove(var.data.list, 1)
				end
			else
				for i=3,6 do
					table.remove(var.data.list, 4)
				end			
			end
			ListView:reloadData(#var.data.list,V9_FengShen.updateBossName)
		end
		local scene=cc.Director:getInstance():getRunningScene()
		scene:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create(exitDelay)));
	end
	
	
	var.page= data.page
	var.totalPage = data.totalPage
	
end

function V9_FengShen.updateBossName(item)
	local param = {
		parent = item:getWidgetByName("drop_item"),
		typeId = var.data.list[item.tag].dropItem,
		num = 1,
		-- bind = firstAward.bind,
	}
	GUIItem.getItem(param)
	item:getWidgetByName("btn_ts").tag = var.data.list[item.tag].id
	item:getWidgetByName("map_name"):setText(var.data.list[item.tag].name)
	V9_FengShen.updateList( item:getWidgetByName("richDesc"),var.data.list[item.tag].desc )
	item:getWidgetByName("map_level"):loadTexture("no_"..var.data.list[item.tag].mapLevel..".png",ccui.TextureResType.plistType)
	
	
	if not item:getChildByName(var.data.list[item.tag].mapLevel.."_name") then
		local redPoint = ccui.Layout:create()
		redPoint:setName(var.data.list[item.tag].mapLevel.."_name")
		redPoint:setContentSize(cc.size(159,39)):setPosition(28,15):setAnchorPoint(cc.p(0,0))
		redPoint:addTo(item)
	end
	
	item:getWidgetByName("btn_ts")
	:addClickEventListener(function (sender)
		GameSocket:PushLuaTable("gui.V9_FengShen.handlePanelData", GameUtilSenior.encode({actionid = "enter",id=item:getWidgetByName("btn_ts").tag}))
	end)
end

function V9_FengShen.updateList( list,strs )
	local t = {}
	if GameUtilSenior.isString(strs) then
		table.insert(t,strs)
	elseif GameUtilSenior.isTable(strs) then
		t = strs
	end
	list:removeAllItems()
	for i,v in ipairs(t) do
		local richLabel = GUIRichLabel.new({size = cc.size(list:getContentSize().width, 40), space=10,name = "hintMsg"..i})
		richLabel:setRichLabel(v,"panel_npctalk")
		list:pushBackCustomItem(richLabel)
	end
end

function V9_FengShen.handlePanelData(event)
	if event.type == "V9_FengShen" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
			V9_FengShen.showDescList(data)
		end
	end
end


function V9_FengShen.onPanelOpen(extend)
	
end

function V9_FengShen.onPanelClose()

end

return V9_FengShen
local V11_ContainerHeCheng = {}
local var = {}

local currentTitleIndex = 0
local currentIndex = 1

function V11_ContainerHeCheng.initView(extend)
	var = {
		xmlPanel,
		titleList={},
		items={},
		autoVcoin=false,
		autoBuy=true,
	}
	if extend.mParam and extend.mParam.titleList then
		var.titleList = extend.mParam.titleList
	else
		GameSocket:PushLuaTable("gui.V11_ContainerHeCheng.onOpenPanel",GameUtilSenior.encode({actionid = "updateTitleList"}))
	end
	var.xmlPanel = GUIAnalysis.load("ui/layout/V11_ContainerHeCheng.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V11_ContainerHeCheng.handlePanelData)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA,V11_ContainerHeCheng.handlePanelData)
		
		V11_ContainerHeCheng.showTitleAnimation()
		V11_ContainerHeCheng.showRightAnimation()
		
		V11_ContainerHeCheng.showMapList()
		
		var.xmlPanel:getWidgetByName("upgrade"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("gui.V11_ContainerHeCheng.onOpenPanel",GameUtilSenior.encode({actionid = "updateTitle",index=currentTitleIndex,autoVcoin=var.autoVcoin,autoBuy=autoBuy}))
		end)
		
		return var.xmlPanel
	end
end


function V11_ContainerHeCheng.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end

function V11_ContainerHeCheng.showRightAnimation()
		
	local right_tips = var.xmlPanel:getWidgetByName("upgrade_animal")
	local startNum = 132
	local function startShowRightBg()
	
		local filepath = string.format("ContainerTitle_%d.png",startNum)
		right_tips:loadTexture(filepath,ccui.TextureResType.plistType)
		
		startNum= startNum+1
		if startNum ==140 then
			startNum =132
		end
	end
	right_tips:stopAllActions()
	right_tips:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowRightBg)}),tonumber(20)))
		
end

function V11_ContainerHeCheng.showMapList()
	local level = GameCharacter._mainAvatar:NetAttr(GameConst.net_level)
	local zslevel = GameCharacter._mainAvatar:NetAttr(GameConst.net_zslevel)
	
	--local currentIndex = 1
	
	local list_btn = var.xmlPanel:getWidgetByName("list_btn"):setVisible(true)
	list_btn:reloadData(#var.titleList,function( subItem )
		table.insert(var.items,subItem)
		local function  showMapDetail( sender )
			
			for i,v in ipairs(var.items) do
				v:getWidgetByName("title_btn_font"):loadTexture(string.format("ContainerTitle_left_btn_%d_1.png",v.index),ccui.TextureResType.plistType)
				--v:getWidgetByName("title_btn_font"):loadTexturePressed(string.format("ContainerTitle_left_btn_%d_3.png",v.index),ccui.TextureResType.plistType)
				v:getWidgetByName("title_btn"):loadTexture("ContainerTitle_2.png",ccui.TextureResType.plistType)
				v:getWidgetByName("title_btn_animal"):setVisible(false)
			end
			subItem:getWidgetByName("title_btn"):loadTexture("ContainerTitle_3.png",ccui.TextureResType.plistType)
			subItem:getWidgetByName("title_btn_font"):loadTexture(string.format("ContainerTitle_left_btn_%d_2.png",var.titleList[subItem.tag].index),ccui.TextureResType.plistType)
			--subItem:getWidgetByName("title_btn_font"):loadTexturePressed(string.format("ContainerTitle_left_btn_%d_2.png",var.titleList[subItem.tag].index),ccui.TextureResType.plistType)
			subItem:getWidgetByName("title_btn_animal"):setVisible(true)
			
			GameUtilSenior.addEffect(var.xmlPanel:getWidgetByName("lu_anima"),"effectEquip",4,180706,{x=0,y=0},false,true)
			
			--var.xmlPanel:getWidgetByName("descNeed"):setText("进阶材料："..var.titleList[sender.tag].itemneed.."")
			if var.titleList[sender.tag].canUseMoney==2 then
				var.autoVcoin = true
			else
				var.autoVcoin = false
			end
			if var.autoVcoin then
				var.xmlPanel:getWidgetByName("descNeed"):setText("进阶费用："..var.titleList[sender.tag].money.."")
			else
				var.xmlPanel:getWidgetByName("descNeed"):setText("进阶材料："..var.titleList[sender.tag].itemneed.."")
			end
			if var.titleList[sender.tag].canUseMoney==3 then
				var.xmlPanel:getWidgetByName("descNeed"):setText("进阶材料："..var.titleList[sender.tag].itemneed.." 进阶费用："..var.titleList[sender.tag].money.."")
			end
			
			currentTitleIndex = var.titleList[subItem.tag].index
			
			if var.titleList[sender.tag].canUseMoney==2 then
				var.xmlPanel:getWidgetByName("btn_auto_buy"):hide()
				var.xmlPanel:getWidgetByName("lbl_lack_material_tips"):setText("勾选使用钻石升级(优先绑钻)")
				local btnAutoVcoin = var.xmlPanel:getWidgetByName("btn_auto_vcoin"):show():loadTextureNormal( (var.autoVcoin and "btn_checkbox_s_has_bg") or "btn_checkbox", ccui.TextureResType.plistType):setContentSize(cc.size(30,30)):setScale9Enabled(true):setCapInsets(cc.rect(0,0,30,30))
				
				btnAutoVcoin:addClickEventListener(function (csender)
					if var.titleList[sender.tag].canUseMoney==2 then
						return GameSocket:alertLocalMsg("当前物品仅支持钻石升级!", "alert")
					end
					if var.titleList[sender.tag].canUseMoney==0 then
						return GameSocket:alertLocalMsg("当前物品不支持钻石升级!", "alert")
					end
					var.autoVcoin = not var.autoVcoin
					csender:loadTextureNormal( (var.autoVcoin and "btn_checkbox_s_has_bg") or "btn_checkbox", ccui.TextureResType.plistType):setContentSize(cc.size(30,30)):setScale9Enabled(true):setCapInsets(cc.rect(0,0,30,30))
					if var.autoVcoin then
						var.xmlPanel:getWidgetByName("descNeed"):setText("进阶费用："..var.titleList[sender.tag].money.."")
					else
						var.xmlPanel:getWidgetByName("descNeed"):setText("进阶材料："..var.titleList[sender.tag].itemneed.."")
					end
				end)
			else
				var.xmlPanel:getWidgetByName("btn_auto_vcoin"):hide()
				local btnAutoBuy = var.xmlPanel:getWidgetByName("btn_auto_buy"):show():loadTextureNormal( (var.autoBuy and "btn_checkbox_s_has_bg") or "btn_checkbox", ccui.TextureResType.plistType):setContentSize(cc.size(30,30)):setScale9Enabled(true):setCapInsets(cc.rect(0,0,30,30))
				var.xmlPanel:getWidgetByName("lbl_lack_material_tips"):setText("自动从商城购买材料")
				
			end
		end
		
		if not subItem:getChildByName(var.titleList[subItem.tag].index.."_name") then
			local redPoint = ccui.Layout:create()
			redPoint:setName(var.titleList[subItem.tag].index.."_name")
			redPoint:setContentSize(cc.size(159,39)):setPosition(0,0):setAnchorPoint(cc.p(0,0))
			redPoint:addTo(subItem)
		end
		
		subItem:getWidgetByName("title_btn_font"):loadTexture(string.format("ContainerTitle_left_btn_%d_1.png",var.titleList[subItem.tag].index),ccui.TextureResType.plistType)
		subItem:getWidgetByName("title_btn"):loadTexture("ContainerTitle_.png",ccui.TextureResType.plistType)
		--subItem:getWidgetByName("title_btn_font"):loadTexturePressed(string.format("ContainerTitle_left_btn_%d_3.png",var.titleList[subItem.tag].index),ccui.TextureResType.plistType)
		subItem.index = var.titleList[subItem.tag].index
		subItem:setTouchEnabled(true)
		subItem:addClickEventListener(function ( sender )
			currentIndex = sender.tag
			showMapDetail(sender)
		end)
		--GUIFocusPoint.addUIPoint(subItem, showMapDetail)
		
		--动画
		local title_animal = subItem:getWidgetByName("title_btn_animal"):setVisible(false)
		local startNum = 50
		local function startShowTitleBg()
			
			title_animal:loadTexture(string.format("ContainerTitle_%d.png",startNum), ccui.TextureResType.plistType)
			
			startNum= startNum+1
			if startNum ==112 then
				startNum =50
			end
		end
		title_animal:stopAllActions()
		title_animal:runAction(cca.repeatForever(cca.seq({cca.delay(0.01),cca.cb(startShowTitleBg)}),tonumber(63)))
		
		if subItem.tag==currentIndex then
			showMapDetail(subItem)
		end
	end)

end

function V11_ContainerHeCheng.updateList( list,strs )
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


function V11_ContainerHeCheng.handlePanelData(event)
	if event.type == "V11_ContainerHeCheng" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="updateTitleList" then
			var.titleList = data.Data
			V11_ContainerHeCheng.showMapList()
		end
	end
end


function V11_ContainerHeCheng.onPanelOpen(extend)
	--GameSocket:PushLuaTable("npc.v4_ChengHaoXiTong.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end

function V11_ContainerHeCheng.onPanelClose()

end

return V11_ContainerHeCheng
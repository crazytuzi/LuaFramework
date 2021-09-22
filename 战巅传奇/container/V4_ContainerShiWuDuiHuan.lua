local V4_ContainerShiWuDuiHuan = {}
local var = {}


local itemList = {}
local currentItemIndex = 1

function V4_ContainerShiWuDuiHuan.initView(extend)
	var = {
		xmlPanel,
		
	}
	
	var.xmlPanel = GUIAnalysis.load("ui/layout/V4_ContainerShiWuDuiHuan.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V4_ContainerShiWuDuiHuan.handlePanelData)

		
		V4_ContainerShiWuDuiHuan.showTitleAnimation()
		
		--[[
		for i=1,12,1 do
			V4_ContainerShiWuDuiHuan.showIconAnimation(i)
			
			var.xmlPanel:getWidgetByName("btn_bg_"..i):addClickEventListener(function ( sender )
			


			end)
			
		end
		]]
		
		var.xmlPanel:getWidgetByName("next_page_btn"):addClickEventListener(function ( sender )
			if currentItemIndex == 1 then
				var.xmlPanel:getWidgetByName("bg"):loadTexture("panel_swdh_26.png",ccui.TextureResType.plistType)
				var.xmlPanel:getWidgetByName("next_page_btn"):loadTextureNormal("panel_swdh_29.png",ccui.TextureResType.plistType)
				var.xmlPanel:getWidgetByName("next_page_btn"):loadTexturePressed("panel_swdh_30.png",ccui.TextureResType.plistType)
				currentItemIndex = 13
			else
				var.xmlPanel:getWidgetByName("bg"):loadTexture("panel_swdh_25.png",ccui.TextureResType.plistType)
				var.xmlPanel:getWidgetByName("next_page_btn"):loadTextureNormal("panel_swdh_27.png",ccui.TextureResType.plistType)
				var.xmlPanel:getWidgetByName("next_page_btn"):loadTexturePressed("panel_swdh_28.png",ccui.TextureResType.plistType)
				currentItemIndex = 1
			end
			V4_ContainerShiWuDuiHuan.showUI(currentItemIndex)
		end)
					
		return var.xmlPanel
	end
end

function V4_ContainerShiWuDuiHuan.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end


function V4_ContainerShiWuDuiHuan.showIconAnimation(index)
		
	local title_animal = var.xmlPanel:getWidgetByName("btn_bg_"..index)
	local startNum = 1
	local function startShowTitleBg()
	
		local filepath = string.format("panel_swdh_%d.png",30+startNum)
		title_animal:loadTextureNormal(filepath,ccui.TextureResType.plistType)
		title_animal:loadTexturePressed(filepath,ccui.TextureResType.plistType)
		
		startNum= startNum+1
		if startNum ==9 then
			startNum =1
		end
	end
	title_animal:stopAllActions()
	title_animal:runAction(cca.repeatForever(cca.seq({cca.delay(0.3),cca.cb(startShowTitleBg)}),tonumber(8)))
		
end

function V4_ContainerShiWuDuiHuan.showUI(index)
	var.xmlPanel:getWidgetByName("listBag"):reloadData(#itemList,function(subitem)
		subitem:getWidgetByName("pic"):loadTexture("panel_swdh_"..subitem.tag..".png",ccui.TextureResType.plistType)
		subitem:getWidgetByName("font"):setText(itemList[subitem.tag].name..""..itemList[subitem.tag].rmb.."元充值点")
		subitem:setTouchEnabled(true)
		subitem.itemPosition = subitem.tag
		GUIFocusPoint.addUIPoint(subitem, function(pSender)
				local mParam = {
					name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", lblConfirm = "要使用该物品兑换充值点么?",
					btnConfirm = "是", btnCancel = "否",
					confirmCallBack = function ()
						GameSocket:PushLuaTable("gui.ContainerShiWuDuiHuan.handlePanelData",GameUtilSenior.encode({actionid = "exchange",index=pSender.itemPosition}))
					end
				}
				GameSocket:dispatchEvent(mParam)
		end)
	end)
	--[[
	for i=1,12,1 do	
		local filepath = string.format("panel_swdh_%d.png",i+index-1)
		var.xmlPanel:getWidgetByName("btn_"..i):loadTextureNormal(filepath,ccui.TextureResType.plistType)
		var.xmlPanel:getWidgetByName("btn_"..i):loadTexturePressed(filepath,ccui.TextureResType.plistType)
		var.xmlPanel:getWidgetByName("btn_bg_"..i).itemPosition = i+index-1
	end
	]]
end

function V4_ContainerShiWuDuiHuan.handlePanelData(event)
	if event.type == "v4_PanelShiWuDuiHuan" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
			itemList = data.itemList
			V4_ContainerShiWuDuiHuan.showUI(currentItemIndex)
		end
	end
end


function V4_ContainerShiWuDuiHuan.onPanelOpen(extend)
	GameSocket:PushLuaTable("gui.ContainerShiWuDuiHuan.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end

function V4_ContainerShiWuDuiHuan.onPanelClose()

end

return V4_ContainerShiWuDuiHuan
local ContainerRechargeFirst={}
local var = {}

function ContainerRechargeFirst.createUiTable(parent,array)
	parent.ui = {};
	for _,v in ipairs(array) do
		local node = parent:getWidgetByName(v);
		if node then
			parent.ui[v] = node
		end
	end
	return parent.ui
end

local node_tab = {"box_recharge","btn_recharge_receive","node_close","node_effect","model_item_box_1","model_item_box_2","model_item_box_3","model_item_box_4","model_item_box_5","model_item_box_6"}

function ContainerRechargeFirst.initView()
	var = {
		xmlPanel = nil,	
		serverData = nil,
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerRechargeFirst.uif")
	if var.xmlPanel then
		-- GameUtilSenior.asyncload(var.xmlPanel, "box_recharge", "ui/image/recharge_first.png");
		--var.xmlPanel:getWidgetByName("box_recharge"):loadTexture("ui/image/recharge_first.png")
		GameUtilSenior.addEffect(var.xmlPanel,"effectEquip",4,60000,{x=300,y=180},false,true)
		GameUtilSenior.addEffect(var.xmlPanel,"effectShenChong",4,60001,{x=940,y=250},false,true)
		GameUtilSenior.addEffect(var.xmlPanel,"effectVcoin",4,60003,{x=84,y=223},false,true)
		GameUtilSenior.addEffect(var.xmlPanel,"effectShuaiTou",4,60002,{x=-10,y=619},false,true)
		ContainerRechargeFirst.createUiTable(var.xmlPanel,node_tab);
		var.xmlPanel.ui["btn_recharge_receive"]:hide()
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerRechargeFirst.handlePanelData)
	end
	return var.xmlPanel
end

function ContainerRechargeFirst.onPanelOpen()
	GameSocket:PushLuaTable("gui.ContainerRechargeFirst.onPanelData", GameUtilSenior.encode({actionid = "init"}))
end

function ContainerRechargeFirst.onPanelClose()
	
end

function ContainerRechargeFirst.handlePanelData(event)
	if event.type ~= "ContainerRechargeFirst" then return end
	local data = GameUtilSenior.decode(event.data)
	print(event.data)
	if data.cmd =="init" then
		ContainerRechargeFirst.update(data.table)
	end
end

local btn_texture = {
	[-1] = "recharge_first_btn.png",
	[0] = "recharge_first_receive.png",
	[1] = "recharge_first_receive.png"
}

function ContainerRechargeFirst.update(needData)
	if needData and GameUtilSenior.isTable(needData) then
		var.serverData = needData;
		local awardTab = needData.awards;
		local state = needData.state;
		if awardTab then
			for i=1,6 do
				local modelItem = var.xmlPanel.ui["model_item_box_"..i]
				local awardOnce = awardTab[i];
				if awardOnce then
					awardOnce.parent = modelItem;
					GUIItem.getItem(awardOnce);
					modelItem:show();

					--if i==1 or i==2 then
						local lowSprite = cc.Sprite:create()
						lowSprite:setPosition(35,35)
						modelItem:addChild(lowSprite)
						cc.AnimManager:getInstance():getPlistAnimate(4, 73004, 4, 3,false,false,0,function(animate,shouldDownload)
							lowSprite:runAction(cca.repeatForever(animate))
							if shouldDownload==true then
								lowSprite:release()
							end
						end,
						function(animate)
							lowSprite:retain()
						end)
						
					--end

					if awardOnce.effect then
						var.xmlPanel.ui["node_effect"]:removeAllChildren()
						local effectSprite = cc.Sprite:create()
							:setAnchorPoint(cc.p(0.5,0))
							:setPosition(cc.p(-45,-80))
							:addTo(var.xmlPanel.ui["node_effect"]);
						cc.AnimManager:getInstance():getPlistAnimate(4, awardOnce.effect, 4,4,false,false,0,function(animate,shouldDownload)
							effectSprite:runAction(cca.repeatForever(animate))
							if shouldDownload==true then
								effectSprite:release()
							end
						end,
						function(animate)
							effectSprite:retain()
						end)
						-- effectSprite:runAction(cca.repeatForever(animate))
					end
				else
					modelItem:hide();
				end
			end
		end
		if state==0 or state==1 then
			var.xmlPanel.ui["btn_recharge_receive"]:setPosition(541,90)
		end
		var.xmlPanel.ui["btn_recharge_receive"]:setTouchEnabled(state<=0)
			:setBright(state<=0)
			:loadTextureNormal(btn_texture[state],ccui.TextureResType.plistType)
			:loadTexturePressed(btn_texture[state],ccui.TextureResType.plistType)
			:show()
			:addClickEventListener(function ( sender )
				if state ==0 then
					GameSocket:PushLuaTable("gui.ContainerRechargeFirst.onPanelData", GameUtilSenior.encode({actionid = "receive"}))
				elseif state == -1 then
					--GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str = "panel_charge", from = "extend_firstPay"})
					GameCCBridge.doSdkPay(1000*6, 6, 1)
				end
			end)
	end
end

return ContainerRechargeFirst
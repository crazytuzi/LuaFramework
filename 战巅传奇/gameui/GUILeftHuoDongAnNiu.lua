local GUILeftHuoDongAnNiu = {}
local var = {}


local currentDaLuInfoIndex = 0
local currentDaLuInfo = {}


function GUILeftHuoDongAnNiu.init_ui(righttop)

	if not righttop then return end

	var = {
		righttop,
		extend

	}

	GameSocket:PushLuaTable("gui.PanelGem.handlePanelData",GameUtilSenior.encode({actionid = "getServerDay",params = {}}))

	var.righttop = righttop
	righttop:align(display.LEFT_CENTER, -350, 320 )
		
	cc.EventProxy.new(GameSocket,righttop)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, GUILeftHuoDongAnNiu.handlePanelData)
				
	righttop:getWidgetByName("duanzao_btn"):addClickEventListener(function ( sender )
		GameSocket:PushLuaTable("gui.ContainerActivityList.enterMapFromClient",GameUtilSenior.encode({name = var.extend.name}))
	end)
	righttop:getWidgetByName("panel_close"):addClickEventListener(function ( sender )
		GUILeftHuoDongAnNiu.close()
	end)
end

function GUILeftHuoDongAnNiu.show(extend)
	var.extend = extend
	var.righttop:getWidgetByName("activity_name"):setText(extend.name)
	--var.righttop:getWidgetByName("activity_content"):setRichLabel(extend.desc)
	GUILeftHuoDongAnNiu.updateList( var.righttop:getWidgetByName("attr_describe_container"),extend.desc )
	--var.righttop:getWidgetByName("attr_describe_container"):requestDoLayout()
	
	var.righttop:setScale(0.2):setOpacity(0.1)
		
		--var.righttop:align(display.LEFT_CENTER, display.left, 320)
	var.righttop:runAction(
	 	cca.seq({
		
			cca.moveTo(0.2, display.left, 320),
	 		cca.spawn({
	 			cca.scaleTo(0.2, 1.0),
	 			cca.fadeIn(0.2)
	 		})
	 	})
	)
end

function GUILeftHuoDongAnNiu.close()
	var.righttop:runAction(
		cc.Sequence:create(
			cca.spawn(
				{cc.Sequence:create(
					--cc.EaseSineIn:create(cca.scaleTo(0.3,1.5))
					cc.EaseSineOut:create(cca.scaleTo(0.2,0.6))
					--cc.EaseQuarticActionIn:create(cc.ScaleTo:create(0.5, 0.5))
					),
					
					cca.moveTo(0.2,-350,320)
				}
			)
		)
	)
end


function GUILeftHuoDongAnNiu.updateList( list,strs )
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
--[[
function GUILeftHuoDongAnNiu.initView(extend)
	print("GUILeftHuoDongAnNiu")
	var = {
		xmlPanel,
		
	}
	
	var.xmlPanel = GUIAnalysis.load("ui/layout/GUILeftHuoDongAnNiu.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, GUILeftHuoDongAnNiu.handlePanelData)
				
		var.xmlPanel:getWidgetByName("activity_name"):setText(extend.mParam.name)
		var.xmlPanel:getWidgetByName("activity_content"):setRichLabel(extend.mParam.desc)
		var.xmlPanel:getWidgetByName("duanzao_btn"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("gui.ContainerActivityList.enterMapFromClient",GameUtilSenior.encode({name = extend.mParam.name}))
		end)
		
		GUILeftHuoDongAnNiu.showTitleAnimation()
					
		return var.xmlPanel
	end
end
]]

function GUILeftHuoDongAnNiu.showTitleAnimation()
		
--	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	local startNum = 1
	local function startShowTitleBg()
	
--		local filepath = string.format("ui/image/ContainerTitle/new_game_panel_title_%d.png",startNum)
--		asyncload_callback(filepath, title_animal, function(filepath, texture)
--			title_animal:loadTexture(filepath)
--		end)
		
		startNum= startNum+1
		if startNum ==19 then
			startNum =1
		end
	end
--	title_animal:stopAllActions()
--	title_animal:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowTitleBg)}),tonumber(18)))
		
end


function GUILeftHuoDongAnNiu.handlePanelData(event)
	if event.type == "V4_ContainerHuoDongAnNiu" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
		end
	end
end


function GUILeftHuoDongAnNiu.onPanelOpen(extend)
	GameSocket:PushLuaTable("npc.v4_GongChengJiangLi.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end

function GUILeftHuoDongAnNiu.onPanelClose()

end

return GUILeftHuoDongAnNiu
local ContainerFoJing = {}
local var = {}

function ContainerFoJing.initView(extend)
	var = {
		xmlPanel,
		
	}
	
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerFoJing.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerFoJing.handlePanelData)
			
		GameUtilSenior.asyncload(var.xmlPanel, "bg", "ui/image/v4_fojing_bg.png")

		 var.xmlPanel:getWidgetByName("btn_ts"):addClickEventListener(function ( sender )
			GameSocket:PushLuaTable("gui.ContainerFoJing.handlePanelData",GameUtilSenior.encode({actionid = "uplv"}))
		end)
		
		ContainerFoJing.showTitleAnimation()
					
				
		return var.xmlPanel
	end
end

function ContainerFoJing.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
	
end

function ContainerFoJing.showAnimation(jianqiao_level)
		
	local equip_animation = var.xmlPanel:getWidgetByName("equip_animation")
	local startNum = 1
	local function startShowBg()
		
		local filepath = string.format("ui/image/fojing/fojin_%d_%d.png",jianqiao_level,startNum)
		asyncload_callback(filepath, equip_animation, function(filepath, texture)
			equip_animation:loadTexture(filepath)
		end)
			
		startNum= startNum+1
		if startNum ==9 then
			startNum =1
		end
	end
	var.xmlPanel:stopAllActions()
	var.xmlPanel:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowBg)}),tonumber(8)))
		
		
		
end

function ContainerFoJing.handlePanelData(event)
	if event.type == "ContainerFoJing" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
			local level = "零阶段"
			if data.curLevel==1 then
				level = "一阶段"
			end
			if data.curLevel==2 then
				level = "二阶段"
			end
			if data.curLevel==3 then
				level = "三阶段"
			end
			if data.curLevel==4 then
				level = "四阶段"
			end
			if data.curLevel==5 then
				level = "五阶段"
			end
			if data.curLevel==6 then
				level = "六阶段"
			end
			if data.curLevel==7 then
				level = "七阶段"
			end
			if data.curLevel==8 then
				level = "八阶段"
			end
			if data.curLevel==9 then
				level = "九阶段"
			end
			if data.curLevel==10 then
				level = "十阶段"
			end
			var.xmlPanel:getWidgetByName("attr_title"):setString("攻防：+"..data.attr.." 血：+"..data.hp)
			var.xmlPanel:getWidgetByName("prob_title"):setString("成功率："..data.prob.."%")
			var.xmlPanel:getWidgetByName("level_title"):setString("当前阶段："..level)
			var.xmlPanel:getWidgetByName("times_title"):setString("提升次数："..data.curTimes.."次")
			ContainerFoJing.showAnimation(data.curLevel)
		end
	end
end


function ContainerFoJing.onPanelOpen(extend)
		GameSocket:PushLuaTable("gui.ContainerFoJing.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end

function ContainerFoJing.onPanelClose()

end

return ContainerFoJing

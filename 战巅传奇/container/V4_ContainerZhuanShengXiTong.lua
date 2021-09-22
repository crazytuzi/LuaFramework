local V4_ContainerZhuanShengXiTong = {}
local var = {}

local mapList = {}

local currentDaLuInfoIndex = 0
local currentDaLuInfo = {}

function V4_ContainerZhuanShengXiTong.initView(extend)
	var = {
		xmlPanel,
		zsNum,
	}
	
	var.xmlPanel = GUIAnalysis.load("ui/layout/V4_ContainerZhuanShengXiTong.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, V4_ContainerZhuanShengXiTong.handlePanelData)
		
		V4_ContainerZhuanShengXiTong.showTitleAnimation()
		V4_ContainerZhuanShengXiTong.showRightAnimation()
					
		return var.xmlPanel
	end
end

function V4_ContainerZhuanShengXiTong.showUI()
	
	var.xmlPanel:getWidgetByName("dalu1"):addClickEventListener(function ( sender )
		V4_ContainerZhuanShengXiTong.showMapList(1)
	end)
	var.xmlPanel:getWidgetByName("dalu2"):addClickEventListener(function ( sender )
		V4_ContainerZhuanShengXiTong.showMapList(2)
	end)
	var.xmlPanel:getWidgetByName("dalu3"):addClickEventListener(function ( sender )
		V4_ContainerZhuanShengXiTong.showMapList(3)
	end)
	var.xmlPanel:getWidgetByName("dalu4"):addClickEventListener(function ( sender )
		V4_ContainerZhuanShengXiTong.showMapList(4)
	end)
	
	
	var.xmlPanel:getWidgetByName("upgrade"):addClickEventListener(function ( sender )
		GameSocket:PushLuaTable("gui.PanelZhuanSheng.handlePanelData",GameUtilSenior.encode({actionid = "reqZhuanSheng",params={}}))
	end)
	
	
	
	
	var.xmlPanel:getWidgetByName("btn_back"):addClickEventListener(function ( sender )
		V4_ContainerZhuanShengXiTong.showMapHome()
	end)
	
	local level = GameCharacter._mainAvatar:NetAttr(GameConst.net_level)
	local zslevel = GameCharacter._mainAvatar:NetAttr(GameConst.net_zslevel)
	
	for i=1,4,1 do
		if mapList[i].level <= level and mapList[i].zslevel <= zslevel then
			var.xmlPanel:getWidgetByName("dalu"..i):loadTextureNormal("panel_djsj_"..(21+i)..".png",ccui.TextureResType.plistType)
			var.xmlPanel:getWidgetByName("dalu"..i):loadTexturePressed("panel_djsj_"..(29+i)..".png",ccui.TextureResType.plistType)
		end
	end
end

function V4_ContainerZhuanShengXiTong.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end


function V4_ContainerZhuanShengXiTong.showRightAnimation()
		
	local right_tips = var.xmlPanel:getWidgetByName("right_tips")
	local startNum = 1
	local function startShowRightBg()
	
		local filepath = string.format("panel_djsj_%d.png",startNum)
		right_tips:loadTexture(filepath,ccui.TextureResType.plistType)
		
		startNum= startNum+1
		if startNum ==21 then
			startNum =1
		end
	end
	right_tips:stopAllActions()
	right_tips:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowRightBg)}),tonumber(20)))
		
end


function V4_ContainerZhuanShengXiTong.showMapHome()
	local bg = var.xmlPanel:getWidgetByName("bg")
	bg:loadTexture("panel_djsj_21.png",ccui.TextureResType.plistType)
	var.xmlPanel:getWidgetByName("left_panel"):setVisible(true)
	var.xmlPanel:getWidgetByName("right_tips"):setVisible(true)
	var.xmlPanel:getWidgetByName("left_panel_map"):setVisible(false)
	var.xmlPanel:getWidgetByName("list_btn"):setVisible(false)
end

function V4_ContainerZhuanShengXiTong.showMapList(mapindex)
	GameSocket:PushLuaTable("gui.PanelZhuanSheng.handlePanelData",GameUtilSenior.encode({actionid = "reqZsData",params={}}))
	local level = GameCharacter._mainAvatar:NetAttr(GameConst.net_level)
	local zslevel = GameCharacter._mainAvatar:NetAttr(GameConst.net_zslevel)
	if mapList[mapindex].open~=1 then
		GameSocket:alertLocalMsg("该大陆暂未开放!", "alert")
		return
	end
	if mapList[mapindex].level > level or mapList[mapindex].zslevel > zslevel then
		local str = "需要"
		if mapList[mapindex].level>0 then
			str = str.."等级"..mapList[mapindex].level.."级"
		end
		if mapList[mapindex].zslevel>0 then
			str = str.."转升"..mapList[mapindex].zslevel.."级"
		end
		GameSocket:alertLocalMsg(str.."才可进入本大陆！", "alert")
		return
	end
	
	local bg = var.xmlPanel:getWidgetByName("bg")
	bg:loadTexture("panel_zsxt_7.png",ccui.TextureResType.plistType)
	bg:setPosition(80,0)
	var.xmlPanel:getWidgetByName("title_animal"):setPosition(400,420)
	var.xmlPanel:getWidgetByName("panel_close"):setPosition(650,470)
	var.xmlPanel:getWidgetByName("btn_back"):setVisible(false)
	var.xmlPanel:getWidgetByName("left_panel"):setVisible(false)
	var.xmlPanel:getWidgetByName("right_tips"):setVisible(false)
	currentDaLuInfo = mapList[mapindex]
	currentDaLuInfoIndex = mapindex
	var.xmlPanel:getWidgetByName("left_panel_map"):setVisible(true)
	var.xmlPanel:getWidgetByName("bar_hp"):setPercent(5, 30):setFontSize( 12 ):enableOutline(GameBaseLogic.getColor(0x000000),1)
	
	local list_btn = var.xmlPanel:getWidgetByName("list_btn"):setVisible(true)	
	
	V4_ContainerZhuanShengXiTong.showRole()

end

function V4_ContainerZhuanShengXiTong.updateRebornAttr(data)
	var.xmlPanel:getWidgetByName("attr_1"):setRichLabel("<font color='#F663FF' size='14'>攻击倍数："..((data.curData.mBeiShang+10000)/10000).."</font>")
	var.xmlPanel:getWidgetByName("attr_2"):setRichLabel("<font color='#F663FF' size='14'>攻击倍数："..((data.nextData.mBeiShang+10000)/10000).."</font>")
end

function V4_ContainerZhuanShengXiTong.showRole()
	
	local img_role = var.xmlPanel:getWidgetByName("img_role"):setVisible(true)	
	
	local clothDef,clothId
	local isFashion = false

	local fashion = GameCharacter._mainAvatar:NetAttr(GameConst.net_fashion)
	local cloth = GameCharacter._mainAvatar:NetAttr(GameConst.net_cloth)
	print("cloth",cloth)
	print("fashion",fashion)
	if fashion >0 then
		clothId = fashion
		isFashion = true
	else
		clothDef = GameSocket:getItemDefByPos(GameConst.ITEM_CLOTH_POSITION)
		--print(GameUtilSenior.encode(clothDef))
		if clothDef then
			clothId = clothDef.mResMale
		else 
			clothId = cloth
		end
	end
	if not clothId then
		local gender = GameCharacter._mainAvatar:NetAttr(GameConst.net_gender)
		local luoti= gender==200 and  10000000 or 10000001
		clothId = luoti
	end
	if clothId~=img_role.curClothId then
		
		local maxPicID = 0
		for i=0,100,1 do
			local filepath = string.format("image/%s/%d%02d.png",isFashion and "fdress" or "dress",clothId,i)
			if not cc.FileUtils:getInstance():isFileExist(filepath) then
				break
			else
				maxPicID = i
			end
		end
				
		local startNum = 0
		local function startShowBg()
		
			local filepath = string.format("image/%s/%d%02d.png",isFashion and "fdress" or "dress",clothId,startNum)
			asyncload_callback(filepath, img_role, function(filepath, texture)
				img_role:loadTexture(filepath)
			end)
			
			startNum= startNum+1
			if startNum ==maxPicID+1 then
				startNum =0
			end
		end
		var.xmlPanel:stopAllActions()
		var.xmlPanel:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowBg)}),tonumber(maxPicID+1)))
		
		img_role.curClothId = clothId
	end

	--设置武器内观
	local img_weapon = var.xmlPanel:getWidgetByName("img_weapon"):setVisible(true)	
	
	-- local weapon = GameCharacter._mainAvatar:NetAttr(GameConst.net_weapon)
	local weaponDef = GameSocket:getItemDefByPos(GameConst.ITEM_WEAPON_POSITION)
	if not isFashion and weaponDef then
		if weaponDef.mResMale~=var.curWeaponId then
		
			
			
			local maxPicID = 0
			for i=0,100,1 do
				local filepath = string.format("image/arm/%d%02d.png",weaponDef.mResMale,i)
				if not cc.FileUtils:getInstance():isFileExist(filepath) then
					break
				else
					maxPicID = i
				end
			end
					
			local startNum = 0
			local function startShowBg()
								
				local filepath = string.format("image/arm/%d%02d.png",weaponDef.mResMale,startNum)
				asyncload_callback(filepath, img_weapon, function(filepath, texture)
					img_weapon:setVisible(true)
					img_weapon:loadTexture(filepath)
				end)
				
				startNum= startNum+1
				if startNum ==maxPicID+1 then
					startNum =0
				end
			end
			img_weapon:stopAllActions()
			img_weapon:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowBg)}),tonumber(maxPicID+1)))
			
			
			
			var.curWeaponId=weaponDef.mResMale
		end
	else
		img_weapon:stopAllActions()
		img_weapon:setTexture(nil)
		img_weapon:setVisible(false)
		var.curWeaponId=nil
	end
end

function V4_ContainerZhuanShengXiTong.showZsLevel(level)
	if var.zsNum==nil then
		var.zsNum = ccui.TextAtlas:create("0123456789", "image/typeface/num_44.png", 20, 32, "0")
			:addTo(var.xmlPanel:getWidgetByName("left_panel_map"))
			:align(display.LEFT_CENTER, 350,57)
			:setString(level)
	else
		var.zsNum:setString(level)
	end
end

function V4_ContainerZhuanShengXiTong.handlePanelData(event)
	if event.type == "v4_PanelZhuanShengXiTong" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
			mapList = data.mapList
			V4_ContainerZhuanShengXiTong.showUI()
			V4_ContainerZhuanShengXiTong.showZsLevel(data.zsLevel)
		end
	end
	if event.type == "PanelZhuanSheng" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd=="updateZhuanSheng" then
			V4_ContainerZhuanShengXiTong.updateRebornAttr(data)
			V4_ContainerZhuanShengXiTong.showZsLevel(data.curLevel)
		end
	end
end


function V4_ContainerZhuanShengXiTong.onPanelOpen(extend)
	GameSocket:PushLuaTable("npc.v4_ZhuanShengXiTong.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end

function V4_ContainerZhuanShengXiTong.onPanelClose()

end

return V4_ContainerZhuanShengXiTong
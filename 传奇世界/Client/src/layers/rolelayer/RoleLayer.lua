local RoleLayer = class("RoleLayer", function() return  cc.Layer:create() end)

function RoleLayer:ctor(parent)
	local addSprite,addLabel = createSprite,createLabel
	local res_base,res_base_bag = "rolebag/role/","rolebag/bag/"

    local function eventCallback(eventType)
        if eventType == "enter" then 
        	g_EventHandler["equipment"]  = function( ... )
        		self:addEquipments(...)
        	end
	    elseif eventType == "exit" then
	    	g_EventHandler["equipment"] = nil
        end
    end
    self:registerScriptHandler(eventCallback)


	local bg = addSprite(self,"res/common/3.png",cc.p(0,g_scrSize.height/2),cc.p(0.0,0.5))
	bg:setFlippedX(true)
	self.bg_sprite = bg

	local closeFunc = function() 
	   	self:runAction(cc.Sequence:create(cc.MoveTo:create(0.2, cc.p(0,-1*g_scrSize.height)), cc.CallFunc:create(function() removeFromParent(self) end)))	
	end
	addSprite(bg,"res/common/1.png",cc.p(249,647),cc.p(0.5,1.0))

	createTouchItem(bg,"res/common/13.png",cc.p(42,615),closeFunc)

	addSprite(bg,res_base.."2.png",cc.p(249,635),cc.p(0.5,1.0))
	addSprite(bg,res_base.."4.png",cc.p(55,560))
	addSprite(bg,res_base.."3.png",cc.p(249,565))

	self.select_layers = {}
	local createFunc = function(index)
		if index == 1 then 
			return self:addDressLayer()
		else 
			return self:addPropertyLayer()
		end
	end
	local menuFunc = function(tag) 
		self.select_index = tag
		for k,v in pairs(self.select_layers) do
			v:setVisible(tag == k)
		end
		if not self.select_layers[tag] then
			self.select_layers[tag] = createFunc(tag)
		end
	end
	
	local menu_item1 = cc.MenuItemImage:create(res_base.."8.png",res_base.."9.png")
	menu_item1:setPosition(cc.p(42,485))
	addLabel(menu_item1,game.getStrByKey("dress"),cc.p(27,50),nil,22)
	local menu_item2 = cc.MenuItemImage:create(res_base.."8.png",res_base.."9.png")
	menu_item2:setPosition(cc.p(42,382))
	addLabel(menu_item2,game.getStrByKey("property"),cc.p(27,50),nil,22)
	local tab_control = {{menu_item = menu_item1,callback = menuFunc},{menu_item = menu_item2,callback = menuFunc}}
	creatTabControlMenu(bg,tab_control,1)

	local reloadFunc = function()
	
		if G_ROLE_MAIN then
			--addLabel(bg,tostring(G_ROLE_MAIN.base_data.level),cc.p(80,560),cc.p(0.0,0.5),18)
			local level_sprite = MakeNumbers:create("common/number.png",MRoleStruct:getAttr(ROLE_LEVEL),-2)
			level_sprite:setPosition(cc.p(90,560))
			bg:addChild(level_sprite,3)
			level_sprite:setScale(0.7)

			local name_label = addLabel(bg,G_ROLE_MAIN.base_data.name,cc.p(250,558),false,20)
			name_label:setLocalZOrder(10)
			if G_FACTION_INFO and G_FACTION_INFO.facname then
				addLabel(bg,G_FACTION_INFO.facname,cc.p(420,560),false,18,nil,nil,nil,cc.c3b(15,155,10))
			else 
				addLabel(bg,game.getStrByKey("unjoin_side"),cc.p(420,560),false,18,nil,nil,nil,cc.c3b(15,155,10))
			end
		end
		menuFunc(1)
	end
	reloadFunc()
	--performWithDelay(self, reloadFunc, 0.0)	

	self:initTouch() 
	self:setPosition(0,-1*g_scrSize.height)
    self:runAction(cc.MoveTo:create(0.2, cc.p(0,0)))
end
--上装
function RoleLayer:addEquipments(params)
	local node = tolua.cast(self.select_layers[1]:getChildByTag(100+params.index),"cc.Sprite")
    if self.equipments[params.index] then
    	removeFromParent(self.equipments[params.index])
    	self.equipments[params.index] = nil
    end
    if node then 
    	self.equipments[params.index] = createSprite(node,"rolebag/bag/prop/"..params.id..".png",cc.p(31,31))
    end
    local str = "Custom event 1 received, "..params.id.." times"
    log(str)
end
--dress_layer
function RoleLayer:addDressLayer()
	local dress_layer = cc.Layer:create()
	local addSprite,addLabel = createSprite,createLabel
	local res_base,res_base_bag = "rolebag/role/","rolebag/bag/"
	createScale9Sprite(dress_layer,"common/32.png",cc.p(260,542),cc.size(390, 430),cc.p(0.5,1.0))
	addSprite(dress_layer,res_base.."19.png",cc.p(260,368))
	addSprite(dress_layer,res_base.."20.png",cc.p(260,368))

	self.equipments = {}

	local positions = {cc.p(110,465),cc.p(110,390),cc.p(410,465),cc.p(410,390),
				cc.p(110,315),cc.p(410,315),cc.p(110,240),cc.p(410,240),
				cc.p(110,165),cc.p(210,165),cc.p(310,165),cc.p(410,165)	}
	local imgids = {4,5,14,13,6,12,7,7,8,9,10,11}
	for i=1,12 do
		local item = addSprite(dress_layer,res_base..imgids[i]..".jpg",positions[i])
		item:setTag(100+i)
		--在此添加已有装备
		if G_ROLE_MAIN and G_ROLE_MAIN.base_data.equips[i] then
			self.equipments[i] = addSprite(item,"rolebag/bag/prop/"..(40101001)..".png",cc.p(31,31))
		end
	end
	
	local name_menu = createMenuItem(dress_layer,res_base_bag.."14.png",cc.p(110,65),closeFunc)
	addSprite(dress_layer,res_base.."7.png",cc.p(300,65))
	addSprite(dress_layer,res_base.."5.png",cc.p(210,65))
	addSprite(dress_layer,res_base.."6.png",cc.p(410,65))
	self.bg_sprite:addChild(dress_layer)
	return dress_layer
end

function RoleLayer:addPropertyLayer()
	--property_layer
	local property_layer = cc.Layer:create()
	local addSprite,addLabel = createSprite,createLabel
	local res_base,res_base_bag = "rolebag/role/","rolebag/bag/"
	self.bg_sprite:addChild(property_layer)

	local role_date = getConfigItem("config/roleData",MRoleStruct:getAttr(ROLE_LEVEL)+3)

	createScale9Sprite(property_layer,"common/32.png",cc.p(260,542),cc.size(390, 505),cc.p(0.5,1.0))
	addSprite(property_layer,res_base.."10.png",cc.p(270,515))
	addSprite(property_layer,res_base.."11.png",cc.p(270,515))
	addSprite(property_layer,res_base.."10.png",cc.p(270,130))
	addSprite(property_layer,res_base.."12.png",cc.p(270,130))
	local str_t = {}
	str_t[1]= "" .. role_date.q_attack_min .."-".. role_date.q_attack_max
	str_t[2]= "" .. role_date.q_magic_attack_min .."-".. role_date.q_magic_attack_max
	str_t[3]= "" .. role_date.q_dc_attack_min .."-".. role_date.q_dc_attack_max
	str_t[4]= "" .. role_date.q_defense_min .."-".. role_date.q_defense_max
	str_t[5]= "" .. role_date.q_magic_defence_min .."-".. role_date.q_magic_defence_max
	str_t[6]= "" .. role_date.q_hp
	str_t[7]= "" ..  role_date.q_mp
	str_t[8]= "" ..  role_date.q_hit
	str_t[9]= "" ..  role_date.q_dodge
	str_t[10]= "" ..  role_date.q_luck
	str_t[11]= "10%"
	str_t[12]= "100%" 
	str_t[13]= "10" 
	str_t[14]= "10"
	local posx,posy = 200,480
	local str_tab = {"physical_attack","magic_attack","taoism_attack","physical_defense","magic_defense","maximum_life","maximum_magic",
								"hit","side_step","lucky","physical_immunity","magic_immunity","pk_num","honor"}
	for i=1, 14 do
		addLabel(property_layer,game.getStrByKey(str_tab[i]),cc.p(posx,posy),false,20,nil,nil,nil,cc.c3b(166,113,66))
		addLabel(property_layer,str_t[i],cc.p(posx+80,posy),cc.p(0.0,0.5),20)
		posy = posy - 29
		if i == 12 then 
			posy = posy - 40
		end
	end
	return property_layer
end
function RoleLayer:initTouch() 

	local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event)
    	if self.bg_sprite:getContentSize().width >=  touch:getLocation().x then
            self.touch_item = nil
            for i=1,12 do 
            	local node = tolua.cast(self.select_layers[1]:getChildByTag(100+i),"cc.Sprite")
            	local pos = node:convertTouchToNodeSpace(touch)
            	local size = node:getContentSize()
            	local rect = cc.rect(0,0,size.width,size.height)
            	if self.equipments[i] and cc.rectContainsPoint(rect,pos) then
            		self.touch_item = self.equipments[i]
            		log("111111111index"..i)
            	end
            end

            return true
        end
        return false
        end,cc.Handler.EVENT_TOUCH_BEGAN )
    listenner:registerScriptHandler(function(touch, event)
 		if self.touch_item then 
 		 --弹出卸装面板
 		end
        end,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,self)

end

return RoleLayer
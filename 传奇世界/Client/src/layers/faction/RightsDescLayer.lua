local RightsDescLayer = class("RightsDescLayer",function() return cc.Layer:create() end )

function RightsDescLayer:ctor(parent)
	local addSprite = createSprite
	local addLabel = createLabel
	self.getString = game.getStrByKey

	local closeFunc = function() 
	   	self.bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 0), cc.CallFunc:create(function() removeFromParent(self) end)))	
	end

	--local colorLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 150))
    --self:addChild(colorLayer)
    --colorLayer:setPosition(self:convertToNodeSpace(cc.p(-50,0)))

	local bg = addSprite(self,"res/common/3-1.png",cc.p(display.cx,display.cy),cc.p(0.5,0.5))
	self.bg = bg
	--local titleBg = addSprite(bg,"res/common/1.png",cc.p(bg:getContentSize().width/2,bg:getContentSize().height-10),cc.p(0.5,1),nil,1.01)
	createLabel(bg, game.getStrByKey("faction_rights"),cc.p(bg:getContentSize().width/2,bg:getContentSize().height-35), cc.p(0.5,0.5), 22, true)
	local closeBtn = createTouchItem(bg,"res/common/13.png",cc.p(bg:getContentSize().width-35,bg:getContentSize().height-35),closeFunc)
	closeBtn:setScale(0.8)

	local posx,posy = 25,130
	local str_tab = {"job_list","access_list"}
	for i=1,2 do
		createScale9Sprite(bg,"res/common/33.png",cc.p(posx,posy),cc.size(195,295),cc.p(0,0))
		local item = addSprite(bg,"res/common/47.png",cc.p(26+(i-1)*205,420),cc.p(0,1.0))
		addSprite(item,"res/faction/"..(15+i)..".png",cc.p(item:getContentSize().width/2,item:getContentSize().height/2),cc.p(0.5,0.5))
		posx = posx + 205
	end
	local tab_control = {}
	local posx,posy = 210,270
	local str_tab = {"the_leader","deputy_leader","the_hall","lowlife"}
	local menuFunc = function(tag) 
		if (not self.select_index) or self.select_index ~= tag then
			local pos = cc.p(tab_control[tag].menu_item:getPosition())
			if not self.select_item then
				self.select_item = createScale9SpriteMenu(bg,"res/common/scalable/selected.png",cc.size(180,55),pos)
			else 
				self.select_item:setPosition(pos)
			end
		end
		self.select_index = tag
		local tab_faction_rights = require("src/config/FactionRight")

		if self.right_desc then
			for k,v in pairs(self.right_desc) do
				removeFromParent(v)
				v = nil
			end
		end
		self.right_desc = createMultiLineLabel(self.update_node,tab_faction_rights[#tab_faction_rights-tag+1].bnghuizhiquan,cc.p(325,358),cc.p(0.5,1.0),20,nil,nil,nil,MColor.yellow,nil,38)
	end

	posx,posy = 120,348
	for i=1,4 do 
		tab_control[i] = {}
		tab_control[i].menu_item = cc.MenuItemImage:create("res/faction/41.png","res/faction/41.png")
		tab_control[i].menu_item:setPosition(cc.p(posx,posy))
		tab_control[i].callback = menuFunc
		addLabel(tab_control[i].menu_item,game.getStrByKey(str_tab[i]),cc.p(tab_control[i].menu_item:getContentSize().width/2,tab_control[i].menu_item:getContentSize().height/2),nil,22,true,nil,nil,MColor.white)

		posy = posy - 62
	end
	creatTabControlMenu(bg,tab_control,1)
	self.update_node = cc.Node:create()
    bg:addChild(self.update_node,100)
   	self.update_node:setPosition(cc.p(0, 0))
   	--self.right_desc = createMultiLineLabel(self.update_node,nil,cc.p(305,350),cc.p(0.5,1.0),20,nil,nil,nil,MColor.yellow, 30)--addLabel(self.update_node,nil,cc.p(305,350),cc.p(0.5,1.0),18,nil,nil,nil,MColor.yellow)

   	menuFunc(1)
	SwallowTouches(self)
	bg:setScale(0.01)
    bg:runAction(cc.ScaleTo:create(0.2, 1))

    registerOutsideCloseFunc(bg, closeFunc)
end

return RightsDescLayer
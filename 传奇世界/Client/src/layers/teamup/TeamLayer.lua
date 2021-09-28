local TeamLayer = class("TeamLayer",function() return cc.Layer:create() end)

function TeamLayer:ctor(theIndex)
	local bg,closeBtn = createBgSprite(self,nil,nil,true)
	local title = createLabel(bg,game.getStrByKey("make_team"),cc.p(480,595),nil,26,true,nil,nil,MColor.lable_yellow)
	self.select_layers = {}
	local spriteName = {}
	local name = {"team_my","team_near","invite_join","team_quickIn"}
	local layers = {require("src/layers/teamup/TeamUp"),require("src/layers/teamup/nearPlayer"),require("src/layers/teamup/inviteJoin"),require("src/layers/teamup/nearPlayer")}--}
	local tempTitle = 4
	local posx,posy = 925,460	
	local menuFunc = function(tag)
		if self.select_index == tag then
			return
		end
		self.select_index = tag
		if spriteName then
			for k,v in pairs(self.select_layers) do
				if tag == k then
				elseif self.select_layers[k] then
					removeFromParent(self.select_layers[k])
					self.select_layers[k] = nil
					if self.tab_control[k] then
						self.tab_control[k].menu_item:unselected()
					end
				end
			end
			if not self.select_layers[tag] then
				self.select_layers[tag] = layers[tag].new(bg,tag)
				bg:addChild(self.select_layers[tag],125)					
			end
			spriteName[tag]:setColor(MColor.lable_yellow)
			if tag ~= self.tagColor then
				spriteName[self.tagColor]:setColor(MColor.lable_black)
			end
			self.tagColor = tag	
			title:setString(game.getStrByKey(name[tag]))		
		end
	end
	local tab_control = {}
	for i = 1, tempTitle do
		tab_control[i] = {}
		tab_control[i].menu_item = cc.MenuItemImage:create("res/common/TabControl/1.png", "res/common/TabControl/2.png")
		tab_control[i].menu_item:setPosition(cc.p(posx,posy))
		tab_control[i].menu_item:setAnchorPoint(cc.p(0,0.5))
		spriteName[i] = Mnode.createLabel(
		{
			src = tostring(game.getStrByKey(name[i])),
			color = MColor.lable_black,
			size = 22,
		})
		local item_size = tab_control[i].menu_item:getContentSize()
		tab_control[i].menu_item:addChild(spriteName[i])
		if true then
			spriteName[i]:setMaxLineWidth(item_size.width/2)
			spriteName[i]:setLineSpacing(-7)
			spriteName[i]:setPosition(item_size.width/2+5, item_size.height/2)
		else
			spriteName[i]:setPosition(item_size.width/2, item_size.height/2)
		end

		tab_control[i].callback = menuFunc
		posy = posy - 116
	end
	self.tab_control = tab_control
	creatTabControlMenu(bg,tab_control,theIndex or 1,200)
	self.select_index = 0
	self.tagColor = 1
	menuFunc(theIndex or 1)
	self.menuFunc = menuFunc
	SwallowTouches(self)
end

function TeamLayer:changePage(pageNum)
	if pageNum then		
		self.tab_control[self.select_index].menu_item:unselected()
		self.tab_control[pageNum].menu_item:selected()
		self.menuFunc(pageNum)
	end
end

return TeamLayer
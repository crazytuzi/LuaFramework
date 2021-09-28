local gameHelp = class("gameHelp",function() return cc.Layer:create() end)

function gameHelp:ctor( params )
	params = params or {}
	local activityID = params.idx or 1

	local bg = createBgSprite(self)
	self.select_layers = {}
	-- local layers = {require("src/layers/active/aideLayer"),require("src/layers/setting/GameRaidersLayer") , require("src/layers/setting/equipBk") }
	local layers = {require("src/layers/active/aideLayer"),require("src/layers/setting/GameRaidersLayer")  }
	local menuFunc = function(tag)
		if self.select_index == tag then
			return
		end
		self.select_index = tag
		for k,v in pairs(self.select_layers) do
			v:setVisible(tag == k)
		end
		if not self.select_layers[tag] then
			self.select_layers[tag] = layers[tag].new(bg)
			bg:addChild(self.select_layers[tag],125)
		end
	end

	local tab_control = {}
	local posx,posy = 445 + 115 ,605
	-- local str_tab = {"title_strong" , "game_raiders" , "equip_book"}
	local str_tab = {"title_strong" , "game_raiders" }
	for i=1 , #str_tab do
		tab_control[i] = {}
		tab_control[i].menu_item = cc.MenuItemImage:create("res/component/TabControl/1.png","res/component/TabControl/2.png")
		tab_control[i].menu_item:setPosition(cc.p(posx,posy))
		tab_control[i].callback = menuFunc
		createLabel(tab_control[i].menu_item , game.getStrByKey(str_tab[i]) , getCenterPos(tab_control[i].menu_item) , nil , 24,nil,nil,nil,MColor.lable_yellow,i)
		posx = posx + 155
	end
	creatTabControlMenu(bg , tab_control , activityID ,998)
	self.select_index = 0
	menuFunc( activityID )

	SwallowTouches(self)
end

return gameHelp
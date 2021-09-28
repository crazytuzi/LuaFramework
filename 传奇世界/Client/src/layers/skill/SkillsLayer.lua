local SkillsLayer = class("SkillsLayer", function() return cc.Layer:create() end)

function SkillsLayer:ctor(theIndex,jnChoose)
	if G_SKILL_REDCHECK[3] and G_SKILL_REDCHECK[3] >= 1 then
		G_SKILL_REDCHECK[3] = 2
		G_MAINSCENE.red_points:removeRedPoint(4, 2)
	end
	local name = nil
	local layers = nil
	local spriteName = {}
	--local tempTitle = 2
	local posx,posy =600,605
	local jnChoose1 = jnChoose or 1
	self.tagColor = 1
	local bg,closeBtn =  createBgSprite(self,nil,nil,true)
	G_TUTO_NODE:setTouchNode(closeBtn, TOUCH_SKILL_CLOSE)
	self.select_index = 0
	self.select_layers = {}
	self.red = {}
	local lv = MRoleStruct:getAttr(ROLE_LEVEL)
	--G_WING_INFO = {11}
	-- if G_WING_INFO and table.nums(G_WING_INFO) > 0 then
		--posx = 460
		--tempTitle = 3
		--name = {"skill_1","wr_wing_skill","set"}
		layers = {require("src/layers/skill/SkillUpdateLayer"),require("src/layers/skill/wingSkillLayer"),require("src/layers/skill/SkillSet")}
	-- else
		--tempTitle = 2
		--name = {"skill_1","set"}
	-- 	layers = {require("src/layers/skill/SkillUpdateLayer"),require("src/layers/skill/SkillSet")}
	-- end
	local menuFunc = function(tag,jnc)
		if self.select_index == tag then 
			return
		end
		self.select_index = tag
		--if spriteName then
			for k,v in pairs(self.select_layers) do
				if tag == k then
					
				elseif self.select_layers[k] then
					removeFromParent(self.select_layers[k])
					self.select_layers[k] = nil
				end
			end
			if not self.select_layers[tag] then
				self.select_layers[tag] = layers[tag].new(bg,jnc)
				if tag == 1 or tag == 2 then
					performWithDelay(self,function()
						local redSpr = tolua.cast(self.red[tag],"cc.Sprite")
						redSpr:setVisible(false)
					end
					,1.0)
				end
				bg:addChild(self.select_layers[tag],125)
			end
			-- spriteName[tag]:setColor(MColor.lable_yellow)
			-- if tag ~= self.tagColor then
			-- 	spriteName[self.tagColor]:setColor(MColor.lable_black)
			-- end
			-- self.tagColor = tag
		--end
	end
	-- local tab_control = {}
	-- for i=1,tempTitle do 
	-- 	tab_control[i] = {}
	-- 	tab_control[i].menu_item = cc.MenuItemImage:create("res/component/TabControl/1.png","res/component/TabControl/2.png")
	-- 	tab_control[i].menu_item:setPosition(cc.p(posx,posy))
	-- 	spriteName[i] = createLabel(tab_control[i].menu_item,game.getStrByKey(name[i]),cc.p(tab_control[i].menu_item:getContentSize().width/2,tab_control[i].menu_item:getContentSize().height/2),cc.p(0.5,0.5),25,nil,nil,nil,MColor.lable_black,i)
	-- 	tab_control[i].callback = menuFunc
	-- 	posx = posx + 155
	-- end
	-- -- tab_control[3].menu_item:setVisible(false)
	-- self.tab_control = tab_control
	-- creatTabControlMenu(bg,tab_control,theIndex or 1)
	-- menuFunc(theIndex or 1,jnChoose1)
	
	local tab_skill_1 = game.getStrByKey("skill_1")
	local tab_wr_wing_skill = game.getStrByKey("wr_wing_skill")
	local tab_set = game.getStrByKey("set")

	local tabs = {}
	tabs[#tabs+1] = tab_skill_1
	-- if G_WING_INFO and table.nums(G_WING_INFO) > 0 then
		tabs[#tabs+1] = tab_wr_wing_skill
	-- end
	tabs[#tabs+1] = tab_set

	local TabControl = Mnode.createTabControl(
	{
		src = {"res/common/TabControl/1.png", "res/common/TabControl/2.png"},
		size = 22,
		titles = tabs,
		margins = 2,
		ori = "|",
		align = "r",
		side_title = true,
		cb = function(node, tag)
			menuFunc(tag,jnChoose1)
			local title_label = bg:getChildByTag(12580)
			if title_label then title_label:setString(tabs[tag]) end
		end,
		selected = theIndex or 1,
	})

	self.red[1] = createSprite(TabControl:tabAtIdx(1) , "res/component/flag/red.png",cc.p(58,97))
	self.red[1]:setVisible(false)
	self.red[2] = createSprite(TabControl:tabAtIdx(2) , "res/component/flag/red.png",cc.p(58,97))
	self.red[2]:setVisible(false)
	Mnode.addChild(
	{
		parent = bg,
		child = TabControl,
		anchor = cc.p(0, 0.0),
		pos = cc.p(931, 460),
		zOrder = 200,
	})
	SwallowTouches(self)

	-- if G_WING_INFO and table.nums(G_WING_INFO) > 0 then
	-- 	G_TUTO_NODE:setTouchNode(TabControl:tabAtIdx(3), TOUCH_SKILL_SET_TAB)
	-- else
	-- 	G_TUTO_NODE:setTouchNode(TabControl:tabAtIdx(2), TOUCH_SKILL_SET_TAB)
	-- end
	G_TUTO_NODE:setTouchNode(TabControl:tabAtIdx(3), TOUCH_SKILL_SET_TAB)
	self:registerScriptHandler(function(event)
		if event == "enter" then
			G_TUTO_NODE:setShowNode(self, SHOW_SKILL)
			-- if G_MAINSCENE and G_MAINSCENE.red_points then
 		-- 		G_MAINSCENE.red_points:removeRedPoint(4, 2)
   --  		end
		elseif event == "exit" then
		end
	end)
	self:checkRed()
end

function SkillsLayer:checkRed()
	local isRed = false
	local isRed1 = false
	for k,v in pairs(G_SKILL_REDCHECK[1]) do
		if v then
			isRed = true
			break
		end
	end
	for k,v in pairs(G_SKILL_REDCHECK[2]) do
		if v then
			isRed1 = true
			break
		end				
	end		
	self.red[1]:setVisible(isRed)
	self.red[2]:setVisible(isRed1)
end

return SkillsLayer
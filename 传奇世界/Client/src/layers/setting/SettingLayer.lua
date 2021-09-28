local SettingLayer = class("SettingLayer", function() return cc.Layer:create() end)
function SettingLayer:ctor()
	local addSprite = createSprite
	local addLabel = createLabel

	--local msgids = {RELATION_SC_GETRELATIONDATA_RET,RELATION_SC_REMOVERELATION_RET}
	--require("MsgHandler").new(self,msgids)

	local function eventCallback(eventType)
        if eventType == "enter" then
        elseif eventType == "exit" then
            saveGameSettings()   
        end
    end
    self:registerScriptHandler(eventCallback)
	local bg, closeBtn = createBgSprite(self,nil,nil,true)
	G_TUTO_NODE:setTouchNode(closeBtn, TOUCH_SET_CLOSE)
	--createScale9Sprite(bg,"res/common/32.png",cc.p(480,562),cc.size(920,535),cc.p(0.5,1.0))

	self.select_layers = {}
	local layers = {require("src/layers/setting/HangupSetLayer"),require("src/layers/setting/pickupSetLayer"),require("src/layers/setting/fightSetLayer"),require("src/layers/setting/SysSetLayer")}
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

	-- local tab_control = {}
	-- local posx,posy = 330,605
	-- local str_tab = {"addBlood","pickupSet","fightSet","sys_set"}   --"msg_push"}
	-- for i=1,4 do 
	-- 	tab_control[i] = {}
	-- 	tab_control[i].menu_item = cc.MenuItemImage:create("res/component/TabControl/1.png","res/component/TabControl/2.png")
	-- 	tab_control[i].menu_item:setPosition(cc.p(posx,posy))
	-- 	tab_control[i].callback = menuFunc
	-- 	--local sprite = addSprite(tab_control[i].menu_item,"res/layers/setting/"..(29+i)..".png",cc.p(89,22.5))
	-- 	addLabel(tab_control[i].menu_item,game.getStrByKey(str_tab[i]),cc.p(tab_control[i].menu_item:getContentSize().width/2,tab_control[i].menu_item:getContentSize().height/2),nil,24,nil,nil,nil,MColor.lable_yellow,i)
	-- 	--sprite:setTag(i)
	-- 	posx = posx + 155
	-- end
	-- creatTabControlMenu(bg,tab_control,1,200)
	-- self.select_index = 2
	-- menuFunc(1)
	self.select_index = 2
	local tab_addBlood = game.getStrByKey("addBlood")
	local tab_pickupSet = game.getStrByKey("pickupSet")
	local tab_fightSet = game.getStrByKey("fightSet")
	local tab_sys_set = game.getStrByKey("sys_set")

	local tabs = {}
	tabs[#tabs+1] = tab_addBlood
	tabs[#tabs+1] = tab_pickupSet
	tabs[#tabs+1] = tab_fightSet
	tabs[#tabs+1] = tab_sys_set
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
			menuFunc(tag)
			local title_label = bg:getChildByTag(12580)
			if title_label then title_label:setString(tabs[tag]) end
		end,
		selected = 1,
	})

	Mnode.addChild(
	{
		parent = bg,
		child = TabControl,
		anchor = cc.p(0, 0.0),
		pos = cc.p(931, 460),
		zOrder = 200,
	})

	SwallowTouches(self)
	--addSprite(bg,"res/common/split_line.png",cc.p(480,483),nil,999)
	-- local scale_bg = createScale9Sprite(bg,"res/common/scalable/goldCorner.png",cc.p(480,249),cc.size(945,486))
	-- scale_bg:setLocalZOrder(999)
	--self:setPosition(0,-1*g_scrSize.height)
    --self:runAction(cc.MoveTo:create(0.2, cc.p(0,0)))
    
    self:registerScriptHandler(function(event)
		if event == "enter" then
			G_TUTO_NODE:setShowNode(self, SHOW_SET)
		elseif event == "exit" then
		end
	end)
end

function SettingLayer:networkHander(buff,msgid)
	local switch = {
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return SettingLayer
local FactionCreateAndListLayer = class("FactionCreateAndListLayer", function() return cc.Layer:create() end)

local path = "res/faction/"
local pathCommon = "res/common/"

function FactionCreateAndListLayer:ctor()
	local msgids = {FACTION_SC_CREATEFACTION_RET}
	require("src/MsgHandler").new(self, msgids)

	local bg = createBgSprite(self, nil,nil,true)
	self.bg = bg

	local menuFunc = function(tag,sender)
	dump(tag)
		if tag == 1 then
			if self.createLayer then
				self.createLayer:removeFromParent()
				self.createLayer = nil
			end
            --package.loaded["src/layers/faction/FactionListLayer"] = nil
			self.listLayer = require("src/layers/faction/FactionListLayer").new(self, self.bg)
			self.bg:addChild(self.listLayer)
		else
			if self.listLayer then
				self.listLayer:removeFromParent()
				self.listLayer = nil
			end
            --package.loaded["src/layers/faction/FactionCreateLayer"] = nil
			self.createLayer = require("src/layers/faction/FactionCreateLayer").new(self.bg)
			self.bg:addChild(self.createLayer)
		end
	end

	-- local title = {
	-- 				{text=game.getStrByKey("faction_tab_join"), pos=cc.p(600, 605)}, 
	-- 				{text=game.getStrByKey("faction_tab_create"), pos=cc.p(755, 605)},
	-- 			}
	-- local tab_control = {}
	-- for i=1,2 do 
	-- 	tab_control[i] = {}
	-- 	tab_control[i].menu_item = cc.MenuItemImage:create("res/component/TabControl/1.png","res/component/TabControl/2.png")
	-- 	tab_control[i].menu_item:setPosition(title[i].pos)
	-- 	tab_control[i].callback = menuFunc
	-- 	tab_control[i].label = createLabel(tab_control[i].menu_item, title[i].text, getCenterPos(tab_control[i].menu_item), cc.p(0.5, 0.5), 24, true)
	-- 	if i == 1 then
	-- 		G_TUTO_NODE:setTouchNode(tab_control[i].menu_item, TOUCH_FACTION_LIST_TAB)
	-- 	elseif i == 2 then
	-- 		G_TUTO_NODE:setTouchNode(tab_control[i].menu_item, TOUCH_FACTION_CREATE_TAB)
	-- 	end
	-- end                                                          
	-- creatTabControlMenu(bg, tab_control, 1)
	-- menuFunc(1)
	local tab_faction_tab_join = game.getStrByKey("faction_tab_join")
	local tab_faction_tab_create = game.getStrByKey("faction_tab_create")

	local tabs = {}
	tabs[#tabs+1] = tab_faction_tab_join
	tabs[#tabs+1] = tab_faction_tab_create

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
	G_TUTO_NODE:setTouchNode(TabControl:tabAtIdx(1), TOUCH_FACTION_LIST_TAB)
	G_TUTO_NODE:setTouchNode(TabControl:tabAtIdx(2), TOUCH_FACTION_CREATE_TAB)

	Mnode.addChild(
	{
		parent = bg,
		child = TabControl,
		anchor = cc.p(0, 0.0),
		pos = cc.p(931, 460),
		zOrder = 200,
	})
	SwallowTouches(self)

	self:registerScriptHandler(function(event)
        if event == "enter" then  
        	G_TUTO_NODE:setShowNode(self, SHOW_FACTION)
        elseif event == "exit" then
        end
    end)
end

function FactionCreateAndListLayer:networkHander(buff, msgid)
	local switch = {
		[FACTION_SC_CREATEFACTION_RET] = function()    
			log("get FACTION_SC_CREATEFACTION_RET"..msgid)
			
            local t = g_msgHandlerInst:convertBufferToTable("CreateFactionRet", buff)
            local ecode,facname,name,rank,id = t.result,t.facName, t.playername, t.factionRank, t.factionID
			log(""..ecode..facname..name..rank..id)
			G_FACTION_INFO.facname = facname
			G_FACTION_INFO.wangname = name
			G_FACTION_INFO.rank = rank
			G_FACTION_INFO.id = id
			local layer = require("src/layers/faction/FactionLayer").new()
			Manimation:transit(
			{
				ref = G_MAINSCENE.base_node,
				node = layer,
				curve = "-",
				sp = cc.p(display.cx, display.cy),
				zOrder = 200,
				tag = 101+9,
				swallow = true,
			})

            --设置默认公告
            local str = game.getStrByKey("faction_notice_first")	
            g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_EDITCOMMENT, "EditComment", {factionID=G_FACTION_INFO.id,comment=str})
			removeFromParent(self)
		end,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return FactionCreateAndListLayer
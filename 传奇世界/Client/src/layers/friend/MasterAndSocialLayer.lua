local MasterAndSocialLayer = class("MasterAndSocialLayer", function() return cc.Layer:create() end)

local path = "res/faction/"
local pathCommon = "res/common/"

function MasterAndSocialLayer:ctor()
	print(debug.traceback())
	local msgids = {MASTER_SC_PROFESSION_RET}
	require("src/MsgHandler").new(self,msgids)

	--g_msgHandlerInst:sendNetDataByFmtExEx(MASTER_CS_PROFESSION, "i", G_ROLE_MAIN.obj_id)
	local t = {}
	g_msgHandlerInst:sendNetDataByTableExEx(MASTER_CS_PROFESSION, "MasterProfession", t)
	addNetLoading(MASTER_CS_PROFESSION, MASTER_SC_PROFESSION_RET)

	local bg, closeBtn = createBgSprite(self, game.getStrByKey("social_title_master"), nil, true)
	self.bg = bg
	self.level = require("src/layers/role/RoleStruct"):getAttr(ROLE_LEVEL)
	self.masterFlag = 0

	G_TUTO_NODE:setTouchNode(closeBtn, TOUCH_SOCIAL_CLOSE)

	-- local menuFunc = function(tag,sender)
	-- 	if tag == 1 then
	-- 		if self.masterLayer then
	-- 			self.masterLayer:removeFromParent()
	-- 			self.masterLayer = nil
	-- 		end
	-- 		self.socialLayer = require("src/layers/friend/SocialNode").new(self.bg,theIdx)
	-- 		self.bg:addChild(self.socialLayer)
	-- 	else
	-- 		if self.level and self.level < 19 then
	-- 			TIPS({type =1 ,str = game.getStrByKey("master_tip_unavailable")})
	-- 			return true
	-- 		end

	-- 		if self.socialLayer then
	-- 			self.socialLayer:removeFromParent()
	-- 			self.socialLayer = nil
	-- 		end

	-- 		if self.masterFlag == 1 then
	-- 			self.masterLayer = require("src/layers/friend/MasterNode").new(self.bg, self)
	-- 		elseif self.masterFlag == 2 or self.masterFlag == 4 then
	-- 			self.masterLayer = require("src/layers/friend/StudentNode").new(self.bg, self)
	-- 		elseif self.masterFlag == 3 then
	-- 			self.masterLayer = require("src/layers/friend/MasterListNode").new(self.bg)
	-- 		end
			
	-- 		if self.masterLayer then
	-- 			self.bg:addChild(self.masterLayer)
	-- 		end
	-- 	end
	-- end

	-- local title = {
	-- 				{text=game.getStrByKey("social_title_social"), pos=cc.p(600, 605)}, 
	-- 				{text=game.getStrByKey("social_title_master"), pos=cc.p(755, 605)},
	-- 			}
	-- local tab_control = {}
	-- for i=1,2 do 
	-- 	tab_control[i] = {}
	-- 	tab_control[i].menu_item = cc.MenuItemImage:create("res/component/TabControl/1.png","res/component/TabControl/2.png")
	-- 	tab_control[i].menu_item:setPosition(title[i].pos)
	-- 	tab_control[i].callback = menuFunc
	-- 	tab_control[i].label = createLabel(tab_control[i].menu_item, title[i].text, getCenterPos(tab_control[i].menu_item), cc.p(0.5, 0.5), 24, true)
	-- end         

	-- if not (G_MASTER_ON == true) then
	-- 	table.remove(tab_control)
	-- end
	
	-- creatTabControlMenu(bg, tab_control, 1)
	-- menuFunc(1)

	SwallowTouches(self)

	self:registerScriptHandler(function(event)
        if event == "enter" then  
        	
        elseif event == "exit" then
        end
    end)
end

function MasterAndSocialLayer:createLayer()
	if self.masterLayer == nil then
		print("self.masterFlag ===",self.masterFlag )
		if self.masterFlag == 1 then
			self.masterLayer = require("src/layers/friend/MasterNode").new(self.bg, self)
		elseif self.masterFlag == 2 or self.masterFlag == 4 then
			self.masterLayer = require("src/layers/friend/StudentNode").new(self.bg, self)
		elseif self.masterFlag == 3 then
			self.masterLayer = require("src/layers/friend/MasterListNode").new(self.bg)
		end

		if self.masterLayer then
			self.bg:addChild(self.masterLayer)
		end
	end
end

function MasterAndSocialLayer:networkHander(buff,msgid)
	local switch = {
		[MASTER_SC_PROFESSION_RET] = function()    
			log("get MASTER_SC_PROFESSION_RET")
			local t = g_msgHandlerInst:convertBufferToTable("MasterProfessionRet", buff) 
			self.masterFlag = t.nowProfession
			log("self.masterFlag = "..self.masterFlag)
			self:createLayer()
		end,
	
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return MasterAndSocialLayer
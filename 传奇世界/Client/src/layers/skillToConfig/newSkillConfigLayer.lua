local newSkillConfigLayer = class("newSkillConfigLayer", function() return cc.Node:create() end)

local resPath = "res/tuto/images/"

function newSkillConfigLayer:ctor(SkillId)
	AudioEnginer.playEffect("sounds/uiMusic/ui_item.mp3",false)
	local autoActionTime = nil
	if getConfigItemByKey("SkillCfg","skillID",SkillId,"jnfenlie") == 8 then
		autoActionTime = 0
	end
    self.m_autoClose = false;
	local load_data = {}
	local temp = 0
	local Number = 0
	local tempNum = {1,2,3,4,5,6,7,8,9,10,11,12,13}

	local buttonFun = function()
		local msgids = {SKILL_SC_SETSHORTCUTKEY}
		require("src/MsgHandler").new(self,msgids)
		load_data = {}
		temp = 0
		Number = 0
		tempNum = {1,2,3,4,5,6,7,8,9,10,11,12,13}
		for k,v in pairs(G_SKILLPROP_POS) do
			if v[1] == 0 or v[1] == 20 then
			else
				table.insert(load_data,v)
			end
		end
		
		for k,v in pairs(load_data) do
			if v[1] and v[1] < 15 then
				temp = temp + v[1]
			end
			for i=13,1,-1 do
				if i == v[1] then
					tempNum[i] = 0
					break
				end
			end
		end
		-- dump(tempNum)
		for i = 1,13 do
			if tempNum[i] ~= 0 then
				Number = tempNum[i]
				break
			end
		end
		if temp >= 91 then
		 	TIPS( {type = 1 ,str = "^c(yellow)"..game.getStrByKey("noSkillSpace").."^"} )
		 	self.m_autoClose = true
		 	table.remove(G_SETPOSTEMP,1)
    		removeFromParent(self)
    		G_MAINSCENE:setSkill()
		else
			if G_ROLE_MAIN and Number ~= 0 then
				local t = {}
				t.shortcutKey = Number
				t.protoType = 1
				t.protoID = SkillId
				g_msgHandlerInst:sendNetDataByTable(SKILL_CS_SETSHORTCUTKEY, "SkillShortcutKeyProtocol", t )					
			end	
		end
	end
	if autoActionTime and autoActionTime <= 0 then
		buttonFun()
	else
		local bg = createSprite(self, "res/tuto/images/autobg.png", cc.p(display.width-200, display.height/2), cc.p(0.5, 0.5))
		local bg_size = bg:getContentSize()
		local icon = getConfigItemByKey("SkillCfg","skillID",SkillId,"ico") or 1000
		createSprite(bg,"res/skillicon/"..icon..".png",cc.p(bg_size.width/2,bg_size.height-105), cc.p(0.5,0.5),nil,1)
		--配置技能
		local menuItem = createMenuItem(bg, "res/component/button/50.png", cc.p(bg_size.width/2, 70), buttonFun)
		menuItem:setScale(0.95)
		local menu_str = game.getStrByKey("auto_config")
		local menu_lable = addLableToMenuItem(menuItem,menu_str,20,MColor.lable_yellow)
		createTouchItem(bg,"res/component/button/x3.png",cc.p(bg_size.width-25,bg_size.height-25), function()
	        self.m_autoClose = true;
	        table.remove(G_SETPOSTEMP,1)
    		removeFromParent(self)
    		G_MAINSCENE:setSkill()
	        end)
		menuItem:blink()
		
	-- 	menu_lable:setString(menu_str.."("..autoActionTime..")")
	-- 	local function countDownFunc()
	-- 		autoActionTime = autoActionTime - 1
	-- 		if autoActionTime <= 0 then
	--             self.m_autoClose = true;
	-- 			buttonFun()
	-- 		else
	-- 			menu_lable:setString(menu_str.."("..autoActionTime..")")
	-- 		end
	-- 	end
	-- 	startTimerAction(self, 1, true, countDownFunc)
	end

    self:registerScriptHandler(function(event)
		if event == "enter" then
            
		elseif event == "exit" then
			-- 非主动关闭面板 需要再次弹出
            if self.m_autoClose ~= nil and self.m_autoClose == false then
                g_EventHandler["newSkillConfig"] = SkillId;
            end
		end
	end)
end

function newSkillConfigLayer:networkHander(buff,msgid)
	local switch = {
		[SKILL_SC_SETSHORTCUTKEY] = function()       
			local t = g_msgHandlerInst:convertBufferToTable("SkillShortcutRetProtocol", buff)    
			--data = {buff:popChar(),buff:popChar(),buff:popInt()}
			local data = {t.shortcutKey,t.protoType,t.protoID}
			for k,v in pairs(G_SKILLPROP_POS) do
				if v[3] == data[3] then
					v[1] = data[1]
					break
				-- elseif v[1] == data[1] then
				-- 	v[1] = 0
				end				
			end
			local skillName = getConfigItemByKey("SkillCfg","skillID",data[3],"name")
			TIPS( { type = 1 , str = "^c(yellow)["..skillName.."]"..game.getStrByKey("skillCfgSucc").."^" } )
			if G_MAINSCENE then
				G_MAINSCENE.refresh_skill = true
				G_MAINSCENE:reloadSkillConfig()
			end
            
            self.m_autoClose = true;
			table.remove(G_SETPOSTEMP,1)
    		removeFromParent(self)
    		G_MAINSCENE:setSkill()
    		-- checkSkillRed()
		end,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return newSkillConfigLayer
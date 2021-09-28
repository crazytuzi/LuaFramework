-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_escort_action = i3k_class("wnd_escort_action", ui.wnd_base)

function wnd_escort_action:ctor()
	
end


function wnd_escort_action:configure(...)
	
	self.show_btn = self._layout.vars.show_btn 
	self.hide_btn = self._layout.vars.hide_btn 
	self.show_btn:onClick(self,self.onShowBtn)
	self.hide_btn:onClick(self,self.onHideBtn)
	
	self.findRoot = self._layout.vars.findRoot 
	self.findRoot:show()
	self.show_btn:hide()
	
	self.give_up = self._layout.vars.give_up 
	self.give_up:onClick(self,self.giveUpEscort)
	
	self.search_btn = self._layout.vars.search_btn 
	self.search_btn:onClick(self,self.onSearchPath)
	self.help_btn = self._layout.vars.help_btn 
	self.help_btn:onClick(self,self.onForHelp)
	self.help_label = self._layout.vars.help_label 
	self.find_car = self._layout.vars.find_car 
	self.find_car:onClick(self,self.onSearchCar)
	
	self.bloodBar = self._layout.vars.bloodBar
	self.bloodPercent = self._layout.vars.bloodPercent
	self.goodsPercent = self._layout.vars.goodsPercent
end

function wnd_escort_action:onShow()
	local escort_taskId = g_i3k_game_context:GetFactionEscortTaskId()
		
	self:updateShowBtn(escort_taskId ~= 0 and i3k_game_get_map_type() == g_FIELD)
	if 	escort_taskId ~= 0 and i3k_game_get_map_type() == g_FIELD then
		self:ForHelpbtn()
	end
end

function wnd_escort_action:refresh()
	local curHP, maxHP = g_i3k_game_context:getEscortCarblood()
	if curHP and maxHP then
		self:setBlood(curHP, maxHP)
	end
	self:updateGoods()
end 

function wnd_escort_action:onSearchPath(sender)
	local id = g_i3k_game_context:GetFactionEscortPathId()
	if id ~= 0 then
		
		local roleLine = g_i3k_game_context:GetCurrentLine()
		local carLine = g_i3k_game_context:GetEscortCarMapInstance()
		if roleLine ~= 0 and carLine ~= 0 then
			if roleLine ~= carLine then
				local str = string.format("镖车位于%s线，请切换到与镖车相同线", carLine) 
				g_i3k_ui_mgr:PopupTipMessage(str)
				return 
			end
		end 
		
		local end_npcid = i3k_db_escort_path[id].end_npc
		local main_point = g_i3k_db.i3k_db_get_npc_postion_by_npc_point(end_npcid)
		local main_mapID = g_i3k_db.i3k_db_get_npc_map_by_npc_point(end_npcid)
		local hero = i3k_game_get_player_hero()
		local carSpeed = g_i3k_game_context:GetCurCarSpeed()
		g_i3k_game_context:SetTmpCarState(true)
		g_i3k_game_context:SeachPathWithMap(main_mapID, main_point, TASK_CATEGORY_ESCORT, nil, nil, carSpeed)
	end 
end 



function wnd_escort_action:onForHelp(sender)
	local serverTime = i3k_integer(i3k_game_get_time())
	
	local old_time = g_i3k_game_context:GetEscortForHelpTime()
	if 	serverTime - old_time < i3k_db_escort.escort_args.for_help then
		local tmp_str = i3k_get_string(565)
		g_i3k_ui_mgr:PopupTipMessage(tmp_str)
		return 
	end
	
	i3k_sbean.escort_for_help()
end 

function wnd_escort_action:ForHelpbtn()
	self._faction_escort_co = g_i3k_coroutine_mgr:StartCoroutine(function()
		while true do
			g_i3k_coroutine_mgr.WaitForSeconds(0.5) --延时
			local serverTime = i3k_integer(i3k_game_get_time())
		
			local old_time = g_i3k_game_context:GetEscortForHelpTime()
			if 	serverTime - old_time < i3k_db_escort.escort_args.for_help then
				--self.help_btn:disableWithChildren()
				--self.help_label:setText("冷却")
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_EscortAction,"upodateBtnState",true)
			else
				--self.help_btn:enableWithChildren()
				--self.help_label:setText("求援")
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_EscortAction,"upodateBtnState",false)
			end
			
		end
	end)
end 

function wnd_escort_action:upodateBtnState(state)
	if state then
		self.help_btn:disableWithChildren()
		self.help_label:setText("冷 却")
	else
		self.help_btn:enableWithChildren()
		self.help_label:setText("求 援")
	end
end 

function wnd_escort_action:onHide()
	g_i3k_coroutine_mgr:StopCoroutine(self._faction_escort_co)
end 

function wnd_escort_action:onSearchCar(sender)
	local roleLine = g_i3k_game_context:GetCurrentLine()
	local carLine = g_i3k_game_context:GetEscortCarMapInstance()
	local isSameLine = true
	if roleLine ~= 0 and carLine ~= 0 then
		if roleLine ~= carLine then
			isSameLine = false
		end
	end


	local logic	= i3k_game_get_logic()
	local player = logic:GetPlayer()
	local hero = i3k_game_get_player_hero()
	local rolePos = player:GetHeroPos()
	local mapid,pos = g_i3k_game_context:GetEscortCarLocation()
	pos = {x = pos.x/100,y = pos.y/100,z = pos.z/100}
	if not g_i3k_game_context:CaculatorSameMapDistance(mapid, pos) then
		g_i3k_game_context:findPathChangeLine(mapid, pos, carLine)
	else
		if isSameLine then
			g_i3k_ui_mgr:PopupTipMessage("您已在镖车旁")
		else
			g_i3k_game_context:ChangeWorldLine(carLine)
		end
	end
	
end 

function wnd_escort_action:giveUpEscort(sender)
	local fun = (function(ok)
		if ok then
			i3k_sbean.cancel_escort()
		end
	end)
	local desc = i3k_get_string(590)
	g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
	
end 

function wnd_escort_action:onShowBtn(sender)
	self.findRoot:show()
	self.show_btn:hide()
	self.hide_btn:show()
end 

function wnd_escort_action:onHideBtn(sender)
	self.findRoot:hide()
	self.show_btn:show()
	self.hide_btn:hide()
end 

function wnd_escort_action:updateShowBtn(state)
	if state then
		self.show_btn:setVisible(not state)
		self.findRoot:setVisible(state)
		self.hide_btn:setVisible(state)
	else
		self.show_btn:setVisible(state)
		self.findRoot:setVisible(state)
		self.hide_btn:setVisible(state)
	end 
end 

function wnd_escort_action:hideAllLayer()
	self.findRoot:hide()
	self.show_btn:hide()
	self.hide_btn:hide()
end

function wnd_escort_action:setBlood(curHP, maxHP)
	self.bloodBar:setPercent(curHP/maxHP*100)
	self.bloodPercent:setText(string.format("%s%%", math.floor(curHP/maxHP*100)))
end

function wnd_escort_action:updateGoods()
	local taskId = g_i3k_game_context:GetFactionEscortTaskId()
	local time = g_i3k_game_context:getBeRobbedTimes()
	local goods = 100
	if time == 1 then
		goods = i3k_db_escort_task[taskId].frist_rob/100
	elseif time == 2 then
		goods = i3k_db_escort_task[taskId].second_rob/100
	elseif time == 3 then
		goods = i3k_db_escort_task[taskId].third_rob/100
	end
	self.goodsPercent:setText(string.format("物资剩余：%s%%", goods))
end

function wnd_create(layout, ...)
	local wnd = wnd_escort_action.new();
		wnd:create(layout, ...);

	return wnd;
end


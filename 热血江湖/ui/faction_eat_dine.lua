-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_eat_dine = i3k_class("wnd_faction_eat_dine", ui.wnd_base)

local LAYER_BPYXT = "ui/widgets/bpyxt"

local dine_icon = {406,407,408}
--宴席图标
local yanxi_icon = {512,513}

local _id = nil
local _text = nil

function wnd_faction_eat_dine:ctor()
	
	self._id = nil
	self._data = {}
	
	self._timer = nil
end

function wnd_faction_eat_dine:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	local start_btn = self._layout.vars.start_btn 
	start_btn:onTouchEvent(self,self.onStart)
	_text = self._layout.vars.time_value
	self.itemScroll = self._layout.vars.itemScroll 
	self.title_label = self._layout.vars.title_label 
	self.count_label = self._layout.vars.count_label 
	self.value_label = self._layout.vars.value_label
	self.my_label = self._layout.vars.my_label  
	self.my_value = self._layout.vars.my_value 
	self.time_label = self._layout.vars.time_label 
	self.time_value = self._layout.vars.time_value 
	self.physical_label = self._layout.vars.physical_label 
	self.physical_value = self._layout.vars.physical_value 
	self.dine_icon = self._layout.vars.dine_icon 
	
	self.vit_count = self._layout.vars.vit_count 
end

function wnd_faction_eat_dine:onShow()
	self._timer = i3k_game_timer_dine.new()
	self._timer:onTest()
end

function wnd_faction_eat_dine:updateUserVit(count,maxCount)
	self.vit_count:setText(string.format("%s/%s",count,maxCount))
end 

function wnd_faction_eat_dine:updateListData(dine_data,my_id)
	self._data = {}
	
	self.itemScroll:removeAllChildren()
	local count = 0
	for k,v in ipairs(dine_data) do
		count = count + 1
		if count == 1 and not self._id then
			self._id = v.id
			_id = v.id
		end
		local _layer = require(LAYER_BPYXT)()
		local title_label = _layer.vars.title_label 
		local select_icon = _layer.vars.select_icon 
		local dine_name = _layer.vars.dine_name
		local bg = _layer.vars.bg 
		if v.id == self._id then
			select_icon:show()
		else
			select_icon:hide()
		end
		local dineName = i3k_db_faction_dine[v.type].name
		local max_count = i3k_db_faction_dine[v.type].useCount
		local have_time = i3k_db_faction_dine[v.type].dineTime
		local roleName  = v.roleName
		if v.type == 1 then
			--roleName = i3k_get_string(10050,v.roleName)
			--dineName = i3k_get_string(10063,dineName)
			bg:setImage(i3k_db_icons[dine_icon[2]].path)
		elseif v.type == 2 then
			--roleName = i3k_get_string(10020,v.roleName)
			--dineName = i3k_get_string(10062,dineName)
			bg:setImage(i3k_db_icons[dine_icon[1]].path)
		end 
		title_label:setText(roleName)
		dine_name:setText(dineName)
		local have_count = 0
		for a,b in pairs(v.roles) do
			have_count = have_count + 1
		end
		local serverTime = math.modf(i3k_game_get_time())
		
		if have_count >= max_count or serverTime >= v.openTime+have_time then
			--roleName = i3k_get_string(10057,v.roleName)
			--dineName = i3k_get_string(10066,i3k_db_faction_dine[v.type].name)
			title_label:setText(roleName)
			dine_name:setText(dineName)
			bg:setImage(i3k_db_icons[dine_icon[3]].path)
		end
		if v.roles[my_id] then
			bg:setImage(i3k_db_icons[dine_icon[3]].path)
		end
		local select_btn = _layer.vars.select_btn
		select_btn:setTag(v.id)
		select_btn:onTouchEvent(self,self.onSelect)
		self.itemScroll:addItem(_layer)
		self._data[v.id] = select_icon
	end
	self:setDineData()
end


function wnd_faction_eat_dine:onSelect(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		
		self._id = sender:getTag()
		_id = sender:getTag()
		
		for k,v in pairs(self._data) do
			if k == self._id then
				if v then
					v:show()
				end
			else
				if v then
					v:hide()
				end
			end
		end
		
		self:setDineData()
	end
end

function wnd_faction_eat_dine:setDineData()
	local id = self._id
	if not id then
		return 
	end
	local dine_data = g_i3k_game_context:GetDineListData()
	local dineType = 1
	local openTime = 1
	local roleName 
	local roles 
	for k,v in pairs(dine_data) do
		if v.id == id then
			dineType = v.type 
			openTime = v.openTime
			roleName = v.roleName 
			roles = v.roles 
			break
		end
	end
	if dineType == 1 then
		self.dine_icon:setImage(g_i3k_db.i3k_db_get_icon_path(yanxi_icon[2]))
	else
		self.dine_icon:setImage(g_i3k_db.i3k_db_get_icon_path(yanxi_icon[1]))
	end 
	local serverTime = i3k_game_get_time()
	serverTime = i3k_integer(serverTime)
	
	local tmp_str = string.format("%s的%s",roleName,i3k_db_faction_dine[dineType].name)
	self.title_label:setText(tmp_str)
	
	local join_data = g_i3k_game_context:GetDineJoinData() or {}
	local have_count =  0
	for k,v in pairs(join_data) do
		have_count = have_count + v
	end
	local join_count =  0
	for k,v in pairs(roles) do
		join_count = join_count + 1
	end
	local num1 = i3k_db_common.faction.dineCount
	local lastTime = i3k_db_faction_dine[dineType].dineTime
	local have_time = lastTime - (serverTime - openTime)
	if have_time <= 0 then
		have_time = 0
	end
	local power = i3k_db_faction_dine[dineType].physicalCount
	
	self.count_label:setText(i3k_get_string(10018,i3k_db_faction_dine[dineType].name))
	local desc = string.format("%s/%s",join_count,i3k_db_faction_dine[dineType].useCount)
	if join_count>= i3k_db_faction_dine[dineType].useCount then
		desc = i3k_get_string(10064,desc)
	end
	self.value_label:setText(desc)
	self.my_label:setText(i3k_get_string(10021))
	local desc = string.format("%s/%s",have_count,num1)
	if have_count>= num1 then
		desc = i3k_get_string(10064,desc)
	end
	self.my_value:setText(desc)
	self.time_label:setText(i3k_get_string(10022,i3k_db_faction_dine[dineType].name))
	self.time_value:setText(self:getTimeDesc(have_time))
	self.physical_label:setText(i3k_get_string(10023,i3k_db_faction_dine[dineType].name))
	self.physical_value:setText(power)
end


function wnd_faction_eat_dine:onStart(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local _data = g_i3k_game_context:GetDineListData()
		local _type = 1
		for k,v in pairs(_data) do
			if v.id == self._id then
				_type = v.type
				break
			end
		end
		local num1 = i3k_db_common.faction.dineCount
		local join_data = g_i3k_game_context:GetDineJoinData() or {}
		local have_count =  0
		for k,v in pairs(join_data) do
			have_count = have_count + v
		end
		if have_count >= num1 then
			g_i3k_ui_mgr:PopupTipMessage("当天参与宴席次数已满")
			return 
		end
		local data = i3k_sbean.sect_joinbanquet_req .new()
		data.bid = self._id
		i3k_game_send_str_cmd(data,i3k_sbean.sect_joinbanquet_res.getName())
	end
end

function wnd_faction_eat_dine:SetTime()
	local id = _id
	if not id then
		return 
	end
	local dine_data = g_i3k_game_context:GetDineListData()
	local dineType = 1
	local openTime = 1
	for k,v in pairs(dine_data) do
		if v.id == id then
			dineType = v.type
			openTime = v.openTime 
			break
		end
	end
	local serverTime = i3k_game_get_time()
	serverTime = i3k_integer(serverTime)
	local lastTime = i3k_db_faction_dine[dineType].dineTime
	local have_time = lastTime - (serverTime - openTime)
	if have_time <= 0 then
		have_time = 0
	end
	if _text then
		_text:setText(self:getTimeDesc(have_time))
	end
end

function wnd_faction_eat_dine:getTimeDesc(timeCount)
	local h = math.modf(timeCount/3600)
	local m = math.modf((timeCount - h*3600)/60)
	local s = timeCount - h*3600 - m*60
	if string.len(h) == 1 then
		h = string.format("%s%s",0,h)
	end
	if string.len(m) == 1 then
		m = string.format("%s%s",0,m)
	end
	if string.len(s) == 1 then
		s = string.format("%s%s",0,s)
	end
	
	return string.format("%s:%s:%s",h,m,s)
end 

--[[function wnd_faction_eat_dine:onClose(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_FactionEatDine)
	end
end--]]

function wnd_faction_eat_dine:onHide()
	if self._timer then
		self._timer:CancelTimer()
	end
end 

function wnd_faction_eat_dine:refresh(dine_data,my_id)
	self:updateListData(dine_data,my_id)
	self:updateUserVit(g_i3k_game_context:GetVit(),g_i3k_game_context:GetVitMax())
end 

function wnd_create(layout, ...)
	local wnd = wnd_faction_eat_dine.new()
	wnd:create(layout, ...)
	return wnd
end

local TIMER = require("i3k_timer");
i3k_game_timer_dine = i3k_class("i3k_game_timer_dine", TIMER.i3k_timer);

function i3k_game_timer_dine:Do(args)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionEatDine,"SetTime")
end

function i3k_game_timer_dine:onTest()
	local logic = i3k_game_get_logic()
	if logic then
		self._timer = logic:RegisterTimer(i3k_game_timer_dine.new(1000));

	end
end

function i3k_game_timer_dine:CancelTimer()
	local logic = i3k_game_get_logic();
	if logic then
		logic:UnregisterTimer(self._timer);
	end
end

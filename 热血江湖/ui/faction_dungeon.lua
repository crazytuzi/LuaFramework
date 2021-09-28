-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_dungeon = i3k_class("wnd_faction_dungeon", ui.wnd_base)

local LAYER_BFMT = "ui/widgets/bfmt"
local LAYER_BFCHT = "ui/widgets/bfcht"

local single_dungeon = 1 --刷新单人本
local team_dungeon = 2 --刷新团队本

local LAYER_BPFBGR = "ui/widgets/bpfbgr"
local LAYER_BPFBTB = "ui/widgets/bpfbtb"

local LAYER_BPFBT2 = "ui/widgets/bpfbt2"

--帮派副本开启等级
local OPENLVL = i3k_db_common.faction.dunegonOpenLvl

function wnd_faction_dungeon:ctor()
	self._id = nil
	self._data = {}
	self._special = {}

	self._team_id = nil
end

function wnd_faction_dungeon:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	--local record_btn = self._layout.vars.record_btn
	--record_btn:onTouchEvent(self,self.onRecord)
	local rule_btn = self._layout.vars.rule_btn
	rule_btn:onTouchEvent(self,self.onRule)
	--self.vitality_value = self._layout.vars.vitality_value
	--self.my_vitality = self._layout.vars.my_vitality
	--self.dungeon_scroll = self._layout.vars.dungeon_scroll

	--self.lockRoot = self._layout.vars.lockRoot
	--self.lockRoot:hide()
	--self.startRoot = self._layout.vars.startRoot
	--self.dunegon_name = self._layout.vars.dunegon_name
	--self.dungeon_desc = self._layout.vars.dungeon_desc
	--self.plan_bar = self._layout.vars.plan_bar
	--self.plan_value = self._layout.vars.plan_value
	--local reset_btn = self._layout.vars.reset_btn
	--reset_btn:onTouchEvent(self,self.onReset)
	--local start_btn = self._layout.vars.start_btn
	--start_btn:onTouchEvent(self,self.onStart)
	--self.reset_label = self._layout.vars.reset_label
	--self.item_scroll = self._layout.vars.item_scroll
	--self.dungeon_need_lvl = self._layout.vars.dungeon_need_lvl

	--self.activity_btn = self._layout.vars.activity_btn
	--self.activity_btn:onTouchEvent(self,self.onActivityTips)

	self.single_btn = self._layout.vars.single_btn
	self.single_btn:onClick(self,self.onSingleDungeon)
	self.team_btn = self._layout.vars.team_btn
	self.team_btn:onClick(self,self.onTeamDungeon)

	self.new_root = self._layout.vars.new_root

	self._current_dungeon_type = 0
end

function wnd_faction_dungeon:onSingleDungeon(sender)
	self._current_dungeon_type = single_dungeon
	self:destroyTimer()
	local tmp_dungeon = {}
	for k, v in pairs(i3k_db_faction_dungeon) do
		table.insert(tmp_dungeon,v)
	end
	table.sort(tmp_dungeon,function (a,b)
		return a.enterLevel < b.enterLevel
	end)
	local fun = function ()
		local data = i3k_sbean.sectmap_query_req.new()
		if g_i3k_game_context:isSpecialFacionDungeon(tmp_dungeon[1].id) then
			data.mapId = tmp_dungeon[1].specialDungeon
		else
			data.mapId = tmp_dungeon[1].id
		end
		i3k_game_send_str_cmd(data,i3k_sbean.sectmap_query_res.getName())
	end

	local data = i3k_sbean.sectmap_status_req.new()
	data.fun = fun
	i3k_game_send_str_cmd(data,i3k_sbean.sectmap_status_res.getName())
	g_i3k_ui_mgr:CloseUI(eUIID_FactionTeamDungeon)
end

function wnd_faction_dungeon:onTeamDungeon(sender)
	self._current_dungeon_type = team_dungeon
	i3k_sbean.team_dungeon_info()
end

function wnd_faction_dungeon:updateSingleBtnState()
	self.single_btn:stateToPressed()
	self.team_btn:stateToNormal()
end

function wnd_faction_dungeon:updateTeamBtnState()
	self.single_btn:stateToNormal()
	self.team_btn:stateToPressed()
end

function wnd_faction_dungeon:onRule(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:ShowHelp(i3k_get_string(15169))
	end
end

function wnd_faction_dungeon:addNewNode(layer)
	local nodeWidth = self.new_root:getContentSize().width
	local nodeHeight = self.new_root:getContentSize().height
	local old_layer = self.new_root:getAddChild()
	if old_layer[1] then
		self.new_root:removeChild(old_layer[1])
	end
	self.new_root:addChild(layer)
	layer.rootVar:setContentSize(nodeWidth, nodeHeight)
end

function wnd_faction_dungeon:onActivityTips(sender,eventType)
	if eventType == ccui.TouchEventType.began then
		g_i3k_ui_mgr:OpenUI(eUIID_NewTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_NewTips,i3k_get_string(310,i3k_db_common.faction.max_active), self:getBtnPosition())
	else
		if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
			g_i3k_ui_mgr:CloseUI(eUIID_NewTips)
		end
	end
end

function wnd_faction_dungeon:getBtnPosition()
	local btnSize = self.activity_btn:getParent():getContentSize()
	local sectPos = self.activity_btn:getPosition()
	local btnPos = self.activity_btn:getParent():convertToWorldSpace(sectPos)
	return {width = btnSize.width, height = btnSize.height, pos = btnPos}
end

function wnd_faction_dungeon:onShow()

end


function wnd_faction_dungeon:updateDungeonList(dungeon_state,vitality,dayVitality, mapId)
	local _layer = require(LAYER_BPFBGR)()
	local widgets = _layer.vars
	self:addNewNode(_layer)

	self.lockRoot = widgets.lockRoot
	self.startRoot = widgets.startRoot
	self.dunegon_name = widgets.dunegon_name
	self.dungeon_desc = widgets.dungeon_desc
	self.lockRoot:hide()
	self.plan_bar = widgets.plan_bar
	self.plan_value = widgets.plan_value
	widgets.reset_btn:onTouchEvent(self,self.onReset)
	widgets.start_btn:onTouchEvent(self,self.onStart)
	self.reset_label = widgets.reset_label
	self.item_scroll = widgets.item_scroll
	self.dungeon_need_lvl = widgets.dungeon_need_lvl
	self.module = widgets.module
	self.pet_module = widgets.pet_module
	self.name = widgets.name
	self.tile = widgets.tile
	self.activity_btn = widgets.activity_btn
	self.activity_btn:onTouchEvent(self,self.onActivityTips)
	local record_btn = widgets.record_btn
	record_btn:onTouchEvent(self,self.onRecord)
	self:updateSingleBtnState()
	g_i3k_game_context:clsSpecialDungeonID()
	widgets.vitality_value:setText(vitality)
	local _desc = string.format("%s/%s",dayVitality,i3k_db_common.faction.max_active)
	widgets.my_vitality:setText(_desc)
	local tmp_dungeon = {}
	self._special = {}
	for k, v in pairs(i3k_db_faction_dungeon) do
		if v.specialDungeon ~= -1 then
			table.insert(tmp_dungeon,v)
		end
		if v.specialDungeon > 0 then
			self._special[v.specialDungeon] = v.id;
		end
	end
	table.sort(tmp_dungeon,function (a,b)
		return a.enterLevel < b.enterLevel
	end)
	self._data = {}
	g_i3k_game_context:setSpecialDungeonID(self._special)
	widgets.dungeon_scroll:removeAllChildren()
	local count = 0
	for k,v in ipairs(tmp_dungeon) do
		count = count + 1
		if count == 1 and not self._id then
			self._id = v.id
		end
		local _layer = require(LAYER_BFMT)()
		local lock_icon = _layer.vars.lock_icon
		local boos_icon = _layer.vars.boos_icon
		local bg = _layer.vars.bg
		local btn = _layer.vars.btn
		_layer.vars.specialIcon:hide()
		btn:setTag(v.id)
		btn:onTouchEvent(self,self.onSelect)
		boos_icon:setImage(g_i3k_db.i3k_db_get_icon_path(v.previewIcon))
		if v.conditionDungeon ~= -1 then
			if (dungeon_state.apply[v.conditionDungeon] and  dungeon_state.apply[v.conditionDungeon] == 1)  then
				lock_icon:hide()
			else
				bg:disable()
				boos_icon:disableWithChildren()
				lock_icon:show()
			end
		else
			lock_icon:hide()
		end
		if dungeon_state.apply[v.id] then
			if dungeon_state.apply[v.id] == 0 then
			elseif dungeon_state.apply[v.id] == 1 and dungeon_state.open[v.id] and dungeon_state.open[v.id] == 0 then
				bg:disable()
				boos_icon:disableWithChildren()
			end
		end
		if dungeon_state.open[v.id] then
			if dungeon_state.open[v.id] == 1 then
				bg:enable()
				boos_icon:enable()
			elseif dungeon_state.open[v.id] == 0 then
				bg:disable()
				boos_icon:disableWithChildren()
			end
		else
			bg:disable()
			boos_icon:disableWithChildren()
		end
		if v.specialDungeon and v.specialDungeon > 0 then
			if dungeon_state.open[v.specialDungeon] and dungeon_state.open[v.specialDungeon] == 1 then
				_layer.vars.specialIcon:show()
				bg:enable()
				boos_icon:enable()
			end
		end
		local select_icon = _layer.vars.select_icon
		if v.id == self._id then
			select_icon:show()
		else
			select_icon:hide()
		end
		local dungeon_name = _layer.vars.dungeon_name
		local name = i3k_db_dungeon_base[v.id].desc
		dungeon_name:setText(name)
		widgets.dungeon_scroll:addItem(_layer)
		self._data[v.id] = select_icon
	end

	if mapId then -- 此参数如果有，那么就跳转一下
		if i3k_db_faction_dungeon[mapId].specialDungeon == -1 then
			if self._special and self._special[mapId] then
				mapId = self._special[mapId]
			end
		end
		widgets.dungeon_scroll:jumpToChildWithIndex(mapId % 10000)
	end
end

function wnd_faction_dungeon:onSelect(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local id = sender:getTag()
		for k,v in pairs(self._data) do
			if k == id then
				v:show()
			else
				v:hide()
			end
		end
		local data = i3k_sbean.sectmap_query_req.new()
		if g_i3k_game_context:isSpecialFacionDungeon(id) then
			data.mapId = i3k_db_faction_dungeon[id].specialDungeon
		else
			data.mapId = id
		end
		self._id = data.mapId
		i3k_game_send_str_cmd(data,i3k_sbean.sectmap_query_res.getName())
	end
end

function wnd_faction_dungeon:updateDungeonData(dungeon_state,dungeon_data)
	self.module:hide()
	self.tile:hide()
	if self._current_dungeon_type ~= single_dungeon then
		return
	end
	local id = self._id
	for k,v in pairs(self._data) do
		if k == id then
			v:show()
		else
			v:hide()
		end
	end
	local _data = i3k_db_faction_dungeon[id]
	if _data.conditionDungeon ~= -1 then
		if (dungeon_state.apply[_data.conditionDungeon] and  dungeon_state.apply[_data.conditionDungeon] == 0) and
			(dungeon_state.open[_data.conditionDungeon] and  dungeon_state.open[_data.conditionDungeon] == 0) then
			self.lockRoot:show()
			self.startRoot:hide()
		elseif not dungeon_state.apply[_data.conditionDungeon] and not dungeon_state.open[_data.conditionDungeon] then
			self.lockRoot:show()
			self.startRoot:hide()
		elseif (dungeon_state.apply[_data.conditionDungeon] and  dungeon_state.apply[_data.conditionDungeon] == 1) then
			self.startRoot:show()
			self.lockRoot:hide()
		else
			self.lockRoot:show()
			self.startRoot:hide()
		end
	else
		self.startRoot:show()
		self.lockRoot:hide()
	end
	self.dunegon_name:setText(i3k_db_dungeon_base[id].desc)
	self.dungeon_desc:setText(_data.desc)
	self.dungeon_need_lvl:setText(_data.enterLevel)
	local state = g_i3k_game_context:getFacionDungeonState()
	local specialDungeon = i3k_db_faction_dungeon[self._id].specialDungeon;
	local progress = 0
	if g_i3k_game_context:isSpecialFacionDungeon(self._id) and dungeon_data[specialDungeon] then
		progress = dungeon_data[specialDungeon].bossHp
	else
		if dungeon_data[self._id] and dungeon_data[self._id].bossHp then
			progress = dungeon_data[self._id].bossHp
		end
	end
	self.progress = progress
	if progress == -1 or progress == 10000 then
		self.reset_label:setText("开启")
	else
		self.reset_label:setText("重置副本")
	end
	if progress == -1 then
		progress = 0
	end
	local tmp_value = progress/10000
	self.plan_bar:setPercent(tmp_value *100)
	local tmp_str = string.format("%s%%",math.modf(tmp_value *100))
	self.plan_value:setText(tmp_str)


	local matk_value = math.modf(progress/1000)
	self.item_scroll:removeAllChildren()
	local state = g_i3k_game_context:getFacionDungeonState()
	local specialDungeon = i3k_db_faction_dungeon[self._id].specialDungeon;
	if specialDungeon == -1 and state and state.open[self._id] then
		self.module:show()
		local tmp_monsterID = string.format("monsterID%s",1)
		bigBossPos = i3k_db_faction_dungeon[self._id][tmp_monsterID]
		local bigBossID = i3k_db_spawn_point[bigBossPos].monsters[1]
		local cfg = i3k_db_monsters[bigBossID]
		if cfg and cfg.modelID then
			local path = i3k_db_models[cfg.modelID].path
			local uiscale = i3k_db_models[cfg.modelID].uiscale
			self.name:setText(cfg.name);
			self.pet_module:setSprite(path)
			self.pet_module:setSprSize(uiscale)
			self.pet_module:setRotation(2);
			if cfg.modelID then
				if math.random() <= 0.5 then
					self.pet_module:pushActionList("01attack01", 1)
				else
					self.pet_module:pushActionList("02attack02", 1)
				end
				self.pet_module:pushActionList("stand",-1)
				self.pet_module:playActionList()
			end
		end
	else
		self.tile:show()
	end
	for i=1,10 do
		local tmp_blood = string.format("bossBlood%s",i)
		local bossBlood = i3k_db_faction_dungeon[self._id][tmp_blood]
		if bossBlood[1] ~= -1 then
			local is_have_item = false
			local _layer = require(LAYER_BFCHT)()
			local progress_label = _layer.vars.progress_label
			local tmp_str = string.format("%s%%",i*10)
			progress_label:setText(tmp_str)
			for a=1,4 do
				local tmp_bg = string.format("item_bg%s",a)
				local item_bg = _layer.vars[tmp_bg]
				item_bg:hide()
				local tmp_icon = string.format("item_icon%s",a)
				local item_icon = _layer.vars[tmp_icon]
				local tmp_bg = string.format("item_bt%s",a)
				local item_bt = _layer.vars[tmp_bg]
			end
			local _index = #bossBlood
			local _count = 0
			for a=1,_index,2 do
				_count = _count + 1
				local itemid = bossBlood[a]
				local itemCount = bossBlood[a + 1]
				local tmp_bg = string.format("item_bg%s",_count)
				local item_bg = _layer.vars[tmp_bg]
				item_bg:show()
				item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
				if i > matk_value then
					item_bg:disable()
				end
				local tmp_icon = string.format("item_icon%s",_count)
				local item_icon = _layer.vars[tmp_icon]
				item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid,i3k_game_context:IsFemaleRole()))
				if i > matk_value then
					item_icon:disable()
				end
				local tmp_bg = string.format("item_bt%s",_count)
				local item_bt = _layer.vars[tmp_bg]
				item_bt:setTag(itemid)
				item_bt:onTouchEvent(self,self.onItemTips)
				is_have_item = true
			end
			if is_have_item then
				self.item_scroll:addItem(_layer)
			end
		end
	end
end

function wnd_faction_dungeon:onItemTips(sender,eventType)
	--if eventType == ccui.TouchEventType.ended then
		local tag = sender:getTag()
		g_i3k_ui_mgr:ShowCommonItemInfo(tag)
	--end
end

function wnd_faction_dungeon:onReset(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local myPos = g_i3k_game_context:GetSectPosition()
		if not (i3k_db_faction_power[myPos] and i3k_db_faction_power[myPos].factionDungeon == 1) then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(801))
			return
		end
		local data = g_i3k_game_context:GetFactionDungeonData()
		local max_count = i3k_db_faction_dungeon[self._id].resetCount
		local need_count = i3k_db_faction_dungeon[self._id].resetConsume
		if data[self._id] and data[self._id].reset then
			if data[self._id].reset >= max_count then
				g_i3k_ui_mgr:PopupTipMessage("今日重置次数已满")
				return
			end
		end
		local vitality = g_i3k_game_context:GetFactionVitality()
		if vitality < need_count then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(10040,need_count))
			return
		end
		local serverTime = i3k_integer(i3k_game_get_time())
		local start_time = i3k_db_faction_dungeon[self._id].startTime
		local endTime = i3k_db_faction_dungeon[self._id].endTime
		local startTimeStr = i3k_db_faction_dungeon[self._id].startTimeStr
		local endTimeStr = i3k_db_faction_dungeon[self._id].endTimeStr
		if serverTime < g_i3k_get_day_time(start_time) or serverTime > g_i3k_get_day_time(endTime) then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(591,startTimeStr,endTimeStr))
			return
		end
		local descId
		if self.progress ~= -1 and self.progress ~= 10000 then
			descId = 18113
		else
			descId = 18112
		end
		local name = i3k_db_dungeon_base[self._id].desc
		local desc = i3k_get_string(descId,need_count,name)
		local fun1 = (function(ok)
			if ok then
				local data = i3k_sbean.sectmap_open_req.new()
				data.mapId = self._id
				data.isOpen = self.progress == 10000 or self.progress == -1
				if g_i3k_game_context:isSpecialFacionDungeon(self._id) then
					if self._special and self._special[self._id] then
						data.mapId = self._special[self._id];
					end
				end
				i3k_game_send_str_cmd(data,i3k_sbean.sectmap_open_res.getName())
			end
		end)
	
		if g_i3k_game_context:isSpecialFacionDungeon(self._id) then
			local fun = (function(ok)
				if not ok then
					return
				else
					g_i3k_ui_mgr:ShowMessageBox2(desc,fun1)
				end
			end)
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(17107),fun)
			return
		else
			g_i3k_ui_mgr:ShowMessageBox2(desc,fun1)
		end 
	end
end

function wnd_faction_dungeon:onStart(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
		local dungeon_data = g_i3k_game_context:GetFactionDungeonData()
		local progress = 0
		if dungeon_data[self._id] and dungeon_data[self._id].bossHp then
			progress = dungeon_data[self._id].bossHp
		end
		if progress == -1 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(10042))
			return
		end
		local data = i3k_sbean.sectmap_sync_req.new()
		data.mapId = self._id
		i3k_game_send_str_cmd(data,i3k_sbean.sectmap_sync_res.getName())
	end
end

function wnd_faction_dungeon:onRecord(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local data = i3k_sbean.sectmap_rewards_req.new()
		i3k_game_send_str_cmd(data,i3k_sbean.sectmap_rewards_res.getName())
	end
end


function wnd_faction_dungeon:refresh(state,mapId)
	self._current_dungeon_type = state
	if state == single_dungeon then
		self._id = mapId
		self:updateDungeonList(g_i3k_game_context:getFacionDungeonState(),g_i3k_game_context:GetFactionVitality(),g_i3k_game_context:GetFactionDayVitality())
	elseif state == team_dungeon then
		self._team_id = mapId
		self:updateTeamDungeonList(g_i3k_game_context:GetFactionTeamDungeonDetailData(),g_i3k_game_context:GetFactionVitality(),g_i3k_game_context:GetFactionDayVitality())
	end

end

----帮派团队本

function wnd_faction_dungeon:updateTeamBaseData(vitality)
	self.vitality_value:setText(vitality or 0)
end

function wnd_faction_dungeon:getTeamDungeonCfg()
	local tmp_dungeon = {}
	for k, v in pairs(i3k_db_faction_team_dungeon) do
		table.insert(tmp_dungeon,v)
	end
	table.sort(tmp_dungeon,function (a,b)
		return a.roleEnterLvl < b.roleEnterLvl
	end)

	return tmp_dungeon
end

function wnd_faction_dungeon:onTeamActivityTips(sender,eventType)
	if eventType == ccui.TouchEventType.began then
		g_i3k_ui_mgr:OpenUI(eUIID_NewTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_NewTips,i3k_get_string(310,i3k_db_common.faction.max_active), self:getTeamBtnPosition())
	else
		if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
			g_i3k_ui_mgr:CloseUI(eUIID_NewTips)
		end
	end
end

function wnd_faction_dungeon:getTeamBtnPosition()
	local btnSize = self.team_activity_btn:getParent():getContentSize()
	local sectPos = self.team_activity_btn:getPosition()
	local btnPos = self.team_activity_btn:getParent():convertToWorldSpace(sectPos)
	return {width = btnSize.width, height = btnSize.height, pos = btnPos}
end

function wnd_faction_dungeon:updateTeamDungeonList(dungeonData,vitality,dayVitality)
	self:destroyTimer()
	self:updateTeamBtnState()
	local _layer = require(LAYER_BPFBTB)()
	local widgets = _layer.vars
	self:addNewNode(_layer)
	self.dungeon_scroll = widgets.dungeon_scroll
	widgets.dungeon_scroll:removeAllChildren()
	self.drop_items = widgets.drop_items
	self.pass_items = widgets.pass_items
	self.vitality_value = widgets.vitality_value
	self:updateTeamBaseData(vitality)
	self.team_activity_btn = widgets.activity_btn
	self.team_activity_btn:onTouchEvent(self,self.onTeamActivityTips)
	self.enter_btn = widgets.enter_btn
	self.enter_btn:disableWithChildren()
	self.enter_lable = widgets.enter_lable
	--widgets.enter_btn:onClick(self,self.onEnterTeamDUngeon)
	self.enter_lvl = widgets.enter_lvl
	self.bar_root = widgets.bar_root
	self.bar_root:hide()
	self.bar = widgets.bar
	self.desc1 = widgets.desc1
	self.desc2 = widgets.desc2
	self.item_count = widgets.item_count
	self.item_icon  =widgets.item_icon
	self.item_count2 = widgets.item_count2
	self.item_icon2  =widgets.item_icon2
	self.use_root = widgets.use_root
	self.use_root:hide()
	self.have_root = widgets.have_root
	self.have_root:hide()
	widgets.add_coin_btn:onClick(self,self.onAddCoin)
	local serverTime = i3k_game_get_time()
	serverTime = i3k_integer(serverTime)
	for i,v in ipairs(self:getTeamDungeonCfg()) do
		if i == 1 and not self._team_id then
			self._team_id = v.id
		end
		local _layer = require(LAYER_BFMT)()
		local lock_icon = _layer.vars.lock_icon
		local boos_icon = _layer.vars.boos_icon
		local bg = _layer.vars.bg
		local btn = _layer.vars.btn
		local select_icon = _layer.vars.select_icon
		select_icon:hide()
		local dungeon_name = _layer.vars.dungeon_name
		btn:setTag(v.id)
		btn:onClick(self,self.onSelectTeamDungeon)
		dungeon_name:setText(i3k_db_dungeon_base[v.id].desc)
		boos_icon:setImage(g_i3k_db.i3k_db_get_icon_path(v.dungeonIcon))
		_layer.vars.specialIcon:hide()
		widgets.dungeon_scroll:addItem(_layer)
		if v.conditionDungeon ~= -1 then
			if not dungeonData[v.id] then -- 没有开启过
					lock_icon:show()
				if dungeonData[v.conditionDungeon] and dungeonData[v.conditionDungeon].isfinish == 1 then
					lock_icon:hide()
				end

				bg:disable()
				boos_icon:disableWithChildren()
			else --已经开启过
				lock_icon:hide()
				if dungeonData[v.id].lastStartTime > dungeonData[v.id].lastEndTime and (dungeonData[v.id].lastStartTime + v.maxTime) >serverTime then
					bg:enable()
					boos_icon:enable()
				else
					bg:disable()
					boos_icon:disableWithChildren()
				end
			end
		else
			if self:getTeamDungeonState(v.id) then
				bg:enable()
				boos_icon:enable()
			else
				bg:disable()
				boos_icon:disableWithChildren()
			end
			lock_icon:hide()
		end
		if self._team_id == v.id then
			select_icon:show()
			self:updateTeamDropItems(v.dropItems,dungeonData[v.id])
			self:updateTeamPassItems(v.passItems,dungeonData[v.id])
			self:updateTeamDungeonBaseData()
			self:updateTeamDungeonBtn()
			self.enter_lvl:setText(string.format("进入等级：%s级",v.roleEnterLvl))
			self.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.resetConsumeId,i3k_game_context:IsFemaleRole()))
			self.item_count:setText(i3k_get_num_to_show(v.resetConsumeCount))
			self.item_icon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.resetConsumeId,i3k_game_context:IsFemaleRole()))
			self:updateUserCoin(g_i3k_game_context:GetCommonItemCanUseCount(v.resetConsumeId))
			local position = g_i3k_game_context:GetSectPosition()
			if  position == eFactionOwner or position == eFactionSencondOwner  then
				self.use_root:show()
				self.have_root:show()
			end
		end
	end

end

function wnd_faction_dungeon:onAddCoin(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_BuyCoin)
end

function wnd_faction_dungeon:updateUserCoin(count)
	if self._current_dungeon_type == team_dungeon then
		if self.item_count2 then
			self.item_count2:setText(i3k_get_num_to_show(count))
		end
	end
end

function wnd_faction_dungeon:updateTeamDungeonBtn()
	local dungeonData = g_i3k_game_context:GetFactionTeamDungeonDetailData()
	if self:getTeamDungeonState(self._team_id) then
		self.enter_btn:onClick(self,self.onEnterTeamDUngeon)
		self.enter_lable:setText("进入")
	else
		self.enter_btn:onClick(self,self.onOpenTeamDungeon)
		if dungeonData[self._team_id] then
			self.enter_lable:setText("重置")
		else
			self.enter_lable:setText("开启")
		end
	end
end



function wnd_faction_dungeon:getTeamDungeonState(id)
	local dungeonData = g_i3k_game_context:GetFactionTeamDungeonDetailData()
	local serverTime = i3k_game_get_time()
	serverTime = i3k_integer(serverTime)
	if not dungeonData[id] then
		return false
	end
	if dungeonData[id].lastStartTime > dungeonData[id].lastEndTime and
	(dungeonData[id].lastStartTime + i3k_db_faction_team_dungeon[id].maxTime) > serverTime then
		return true
	else
		return false
	end
end

function wnd_faction_dungeon:onSelectTeamDungeon(sender)
	self:destroyTimer()
	local scroll_list = self.dungeon_scroll:getAllChildren()
	self._team_id = sender:getTag()
	for i,v in ipairs(scroll_list) do
		if v.vars.btn:getTag() == sender:getTag() then
			v.vars.select_icon:show()
		else
			v.vars.select_icon:hide()
		end
	end
	local dungeonData = g_i3k_game_context:GetFactionTeamDungeonDetailData()
	self:updateTeamDropItems(i3k_db_faction_team_dungeon[self._team_id].dropItems,dungeonData[self._team_id])
	self:updateTeamPassItems(i3k_db_faction_team_dungeon[self._team_id].passItems,dungeonData[self._team_id])
	local roleEnterLvl = i3k_db_faction_team_dungeon[self._team_id].roleEnterLvl
	self.enter_lvl:setText(string.format("进入等级：%s级",roleEnterLvl))
	self:updateTeamDungeonBaseData()
	self:updateTeamDungeonBtn()
	self.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(i3k_db_faction_team_dungeon[self._team_id].resetConsumeId,i3k_game_context:IsFemaleRole()))
	self.item_icon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(i3k_db_faction_team_dungeon[self._team_id].resetConsumeId,i3k_game_context:IsFemaleRole()))
	self.item_count:setText(i3k_get_num_to_show(i3k_db_faction_team_dungeon[self._team_id].resetConsumeCount))
	local count = g_i3k_game_context:GetCommonItemCanUseCount(i3k_db_faction_team_dungeon[self._team_id].resetConsumeId)
	self:updateUserCoin(count)
	local position = g_i3k_game_context:GetSectPosition()
	if  position == eFactionOwner or position == eFactionSencondOwner  then
		self.use_root:show()
		self.have_root:show()
	end
end

function wnd_faction_dungeon:onOpenTeamDungeon(sender)
	local dungeonOpenRoleLvl = i3k_db_faction_team_dungeon[self._team_id].dungeonOpenRoleLvl
	local dungeonOpenRoleCount = i3k_db_faction_team_dungeon[self._team_id].dungeonOpenRoleCount
	local resetCycle = i3k_db_faction_team_dungeon[self._team_id].resetCycle
	local resetConsumeCount = i3k_db_faction_team_dungeon[self._team_id].resetConsumeCount
	local resetConsumeId = i3k_db_faction_team_dungeon[self._team_id].resetConsumeId

	local have_count = self:getTeamDungeonCurrentOpenRoleCount(dungeonOpenRoleLvl,g_i3k_game_context:GetFactionTeamDungeonMemberLvl())

	if have_count < dungeonOpenRoleCount then
		g_i3k_ui_mgr:PopupTipMessage("当前线上人员不足")
		return
	end
	local dungeonData = g_i3k_game_context:GetFactionTeamDungeonDetailData()
	for k,v in pairs(dungeonData) do
		if self:getTeamDungeonState(k) then
			g_i3k_ui_mgr:PopupTipMessage("同一时间只能开启一个团队副本")
			return
		end
	end

	local serverTime = i3k_game_get_time()
	serverTime = i3k_integer(serverTime)
	if dungeonData[self._team_id] then
		if serverTime < dungeonData[self._team_id].lastEndTime + resetCycle then
			g_i3k_ui_mgr:PopupTipMessage("团队本冷却期间")
			return
		end
	end

	local position = g_i3k_game_context:GetSectPosition()
	if not(i3k_db_faction_power[position] and i3k_db_faction_power[position].factionDungeonReset == 1) then
		g_i3k_ui_mgr:PopupTipMessage("无许可权开启")
		return
	end

	local have_count = g_i3k_game_context:GetCommonItemCanUseCount(resetConsumeId)
	if have_count < resetConsumeCount then
		g_i3k_ui_mgr:PopupTipMessage("货币不足")
		return
	end
	if i3k_game_get_time() - g_i3k_game_context:getlastjointime() < i3k_db_common.faction.team_dungeon_limit then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18175, math.floor(i3k_db_common.faction.team_dungeon_limit/3600)))
		return
	end

	i3k_sbean.open_team_dungeon(self._team_id)
end

function wnd_faction_dungeon:onEnterTeamDUngeon(sender)
	local roleEnterLvl = i3k_db_faction_team_dungeon[self._team_id].roleEnterLvl
	if g_i3k_game_context:GetLevel() < roleEnterLvl then
		g_i3k_ui_mgr:PopupTipMessage(string.format("您不满%s级，不能进入此团队副本",roleEnterLvl))
		return
	end
	local room = g_i3k_game_context:IsInRoom()
	if room then
		g_i3k_ui_mgr:PopupTipMessage("等待其他活动时无法进入帮派团队副本")
		return
	end
	if i3k_game_get_time() - g_i3k_game_context:getlastjointime() < i3k_db_common.faction.team_dungeon_limit then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18111, math.floor(i3k_db_common.faction.team_dungeon_limit/3600)))
		return
	end
	local function func()
		i3k_sbean.enter_team_dungeon(self._team_id)
	end
	g_i3k_game_context:CheckMulHorse(func)
end

function wnd_faction_dungeon:updateTeamDungeonBaseData()
	local openLvl = i3k_db_faction_team_dungeon[self._team_id].dungeonOpenRoleLvl
	local openCount = i3k_db_faction_team_dungeon[self._team_id].dungeonOpenRoleCount
	local conditionDungeon = i3k_db_faction_team_dungeon[self._team_id].conditionDungeon
	local dungeon_data = g_i3k_game_context:GetFactionTeamDungeonDetailData()
	if self:getTeamDungeonState(self._team_id) then
		self.enter_btn:enable()
		if not self._timer then
			self._timer = i3k_game_timer_team_dungeon.new()
			self._timer:onTest()
		end

		self.bar_root:show()
		self.desc1:setText(string.format("距离结束剩余时间"))
		local tmp_str,have_time,max_time = self:getTeamDUngeonLastTimes(dungeon_data[self._team_id].lastStartTime)
		self.desc2:setText(tmp_str)
		self.desc2:show()
		local tmp = have_time/max_time*100
		self.bar:setPercent(tmp)
	else
		self.enter_btn:disableWithChildren()
		self.bar_root:hide()
		self.desc2:hide()
		self.desc1:show()
		if not self._timer then
			self._timer = i3k_game_timer_team_dungeon.new()
			self._timer:onTest()
		end
		if conditionDungeon == -1 or (dungeon_data[conditionDungeon] and dungeon_data[conditionDungeon].isfinish == 1) then
			local is_cool,tmp_str = self:getTeamDungeonCoolTime(self._team_id)
			if is_cool then
				self.desc1:setText(tmp_str)
			else
				local is_open,tmp_str = self:getIsOtherTeamDungeonOpen(self._team_id)
				if is_open then
					self.desc1:setText(tmp_str)
				else
					local is_can,tmp_str = self:getIsCanOpenTeamDUngeon()
					if is_can then
						self.desc1:setText(tmp_str)
					else
						local have_count = self:getTeamDungeonCurrentOpenRoleCount(openLvl,g_i3k_game_context:GetFactionTeamDungeonMemberLvl())
						if have_count >= openCount then
							self.enter_btn:enable()
							self.desc1:setText(string.format("%s团本开启条件已满足",i3k_db_dungeon_base[self._team_id].desc))
							self.desc2:hide()
						else
							self.desc1:show()
							self.desc2:show()
							self.desc1:setText(string.format("开启限制，帮派中具有%s名以上在线的%s级玩家（离线玩家不计数）",openCount,openLvl))
							self.desc2:setText(string.format("(当前%s/%s)",have_count,openCount))
						end
					end
				end
			end
		else
			local tmp_str = string.format("优先通关%s",i3k_db_dungeon_base[conditionDungeon].desc)
			self.desc1:setText(tmp_str)
		end
	end
end

function wnd_faction_dungeon:getTeamDUngeonLastTimes(startTime)
	local serverTime = i3k_game_get_time()
	serverTime = i3k_integer(serverTime)

	local maxTime = i3k_db_faction_team_dungeon[self._team_id].maxTime

	local have_time = startTime+ maxTime - serverTime
	if have_time > 0 then
		local h = math.modf(have_time/(60*60))
		local m = math.modf((have_time - h*60*60)/60)
		if h~= 0 then
			return string.format("(%s小时%s分)",h,m),have_time,maxTime
		else
			if m ~= 0 then
				return string.format("(%s分)",m),have_time,maxTime
			else
				return string.format("(%s秒)",have_time),have_time,maxTime
			end
		end
	else
		self:destroyTimer()
		return string.format("(%s秒)",0),0,maxTime

	end

end

function wnd_faction_dungeon:getTeamDungeonCoolTime(id)
	local resetCycle = i3k_db_faction_team_dungeon[id].resetCycle
	local dungeonData = g_i3k_game_context:GetFactionTeamDungeonDetailData()
	if not dungeonData[id] then
		return false
	end
	local serverTime = i3k_game_get_time()
	serverTime = i3k_integer(serverTime)
	local have_time =  dungeonData[id].lastEndTime + resetCycle - serverTime

	if have_time > 0 then
		local d = math.modf(have_time/(60*60*24))
		local h = math.modf((have_time - (d*(60*60*24)))/(60*60))
		local m = math.modf((have_time - d*60*60*24 - h*60*60)/60)
		if d ~= 0 then
			return true,string.format("重置冷却时间：%s天%s小时%s分钟",d,h,m)
		else
			if h ~= 0 then
				return true,string.format("重置冷却时间：%s小时%s分钟",h,m)
			else
				if m ~= 0 then
					return true,string.format("重置冷却时间：%s分钟",m)
				else
					return true,string.format("重置冷却时间：%s秒",have_time)
				end
			end
		end
	end
	self:destroyTimer()
	return false
end

function wnd_faction_dungeon:getIsOtherTeamDungeonOpen(id)
	local dungeonData = g_i3k_game_context:GetFactionTeamDungeonDetailData()
	for k,v in pairs(dungeonData) do
		if k ~= id then
			if self:getTeamDungeonState(k) then
				return true ,"其他团队副本开启中"
			end
		end
	end
	return false
end

function wnd_faction_dungeon:getIsCanOpenTeamDUngeon()
	local position = g_i3k_game_context:GetSectPosition()
	if not (position == eFactionOwner or position == eFactionSencondOwner ) then
		return true,"团队副本需帮主/副帮主方可开启"
	end
	return false
end

function wnd_faction_dungeon:getTeamDungeonCurrentOpenRoleCount(openLvl,lvls)
	local count = 0
	for i,v in ipairs(lvls) do
		if v >= openLvl then
			count = count + 1
		end
	end
	return count
end


function wnd_faction_dungeon:updateTeamDropItems(items,state)
	self.drop_items:removeAllChildren()

	for i,v in ipairs(items) do
		local _layer = require(LAYER_BPFBT2)()
		local bt = _layer.vars.bt
		local grade_icon = _layer.vars.grade_icon
		local item_icon = _layer.vars.item_icon
		local item_count = _layer.vars.item_count
		item_count:hide()
		local is_select = _layer.vars.is_select

		bt:setTag(v)
		bt:onClick(self,self.onItemTips)

		grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v))
		item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v,i3k_game_context:IsFemaleRole()))
		if not state then
			grade_icon:disableWithChildren()
		end
		self.drop_items:addItem(_layer)
	end

end



function wnd_faction_dungeon:updateTeamPassItems(items,state)
	self.pass_items:removeAllChildren()

	for i=1,#items,2 do
		local _layer = require(LAYER_BPFBT2)()
		local bt = _layer.vars.bt
		local grade_icon = _layer.vars.grade_icon
		local item_icon = _layer.vars.item_icon
		local item_count = _layer.vars.item_count
		item_count:hide()
		local is_select = _layer.vars.is_select

		bt:setTag(items[i])
		bt:onClick(self,self.onItemTips)

		grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(items[i]))
		item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(items[i],i3k_game_context:IsFemaleRole()))
		if not state then
			grade_icon:disableWithChildren()
		end
		self.pass_items:addItem(_layer)
	end
end

function wnd_faction_dungeon:destroyTimer()
	if self._timer then
		self._timer:CancelTimer()
		self._timer = nil
	end
end

function wnd_faction_dungeon:onHide()
	self:destroyTimer()
end



function wnd_create(layout, ...)
	local wnd = wnd_faction_dungeon.new();
		wnd:create(layout, ...);

	return wnd;
end

local TIMER = require("i3k_timer");
i3k_game_timer_team_dungeon = i3k_class("i3k_game_timer_team_dungeon", TIMER.i3k_timer)

function i3k_game_timer_team_dungeon:Do(args)

	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionDungeon,"updateTeamDungeonBaseData")
end

function i3k_game_timer_team_dungeon:onTest()
	local logic = i3k_game_get_logic()
	if logic then
		self._timer = logic:RegisterTimer(i3k_game_timer_team_dungeon.new(1000))
	end
end

function i3k_game_timer_team_dungeon:CancelTimer()
	local logic = i3k_game_get_logic();
	if logic and self._timer then
		logic:UnregisterTimer(self._timer);
	end
end

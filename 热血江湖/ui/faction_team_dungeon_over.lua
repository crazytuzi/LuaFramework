-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_team_dungeon_over = i3k_class("wnd_faction_team_dungeon_over", ui.wnd_base)

local LAYER_BPFBT2 = "ui/widgets/bpfbt2"
local LAYER_BPFBT3 = "ui/widgets/bpfbt3"

function wnd_faction_team_dungeon_over:ctor()
	
end

function wnd_faction_team_dungeon_over:configure(...)
	self.win_icon = self._layout.vars.win_icon 
	self.fail_icon = self._layout.vars.fail_icon 
	self.item_scroll = self._layout.vars.item_scroll 
	self.rank_scroll = self._layout.vars.rank_scroll 
	self.title_lable = self._layout.vars.title_lable 
	self.activity = self._layout.vars.activity 
	self.rank = self._layout.vars.rank 
	self.bar_root = self._layout.vars.bar_root 
	self.bar = self._layout.vars.bar 
	self.bar_label = self._layout.vars.bar_label 
	self.time = self._layout.vars.time 
	self.time:hide()
	self._layout.vars.rank_btn:onClick(self,self.onRank)
	self.exit = self._layout.vars.exit 
	self.exit:onClick(self,self.onExit)
	self.c_sb = self._layout.anis.c_sb
	self.c_sl = self._layout.anis.c_sl
end

function wnd_faction_team_dungeon_over:onShow()
	
end

function wnd_faction_team_dungeon_over:refresh(mapId,state,finishTime,awardActivity,halfTimeActivity,rank,tmp_items,tmp_speed_rank,dungeon_items,dungeon_speed_items,progress)
	--self:updateItems(tmp_items,tmp_speed_rank)
	--self:updateDungeonItems(dungeon_items,dungeon_speed_items)
	--self:updateDetailData(mapId,state,finishTime,awardActivity,halfTimeActivity,rank,progress)
	if state then
		self:successAnimation(mapId,state,finishTime,awardActivity,halfTimeActivity,rank,tmp_items,tmp_speed_rank,dungeon_items,dungeon_speed_items,progress)
	else
		self:failAnimation(mapId,state,finishTime,awardActivity,halfTimeActivity,rank,tmp_items,tmp_speed_rank,dungeon_items,dungeon_speed_items,progress)
	end
end 

function wnd_faction_team_dungeon_over:successAnimation(mapId,state,finishTime,awardActivity,halfTimeActivity,rank,tmp_items,tmp_speed_rank,dungeon_items,dungeon_speed_items,progress)
	self.c_sl.play(function ()
		--self:updateItems(tmp_items,tmp_speed_rank)
		--self:updateDungeonItems(dungeon_items,dungeon_speed_items)
		--self:updateDetailData(mapId,state,finishTime,awardActivity,halfTimeActivity,rank,progress)
	end)
	self:updateItems(tmp_items,tmp_speed_rank)
	self:updateDungeonItems(dungeon_items,dungeon_speed_items)
	self:updateDetailData(mapId,state,finishTime,awardActivity,halfTimeActivity,rank,progress)
end 

function wnd_faction_team_dungeon_over:failAnimation(mapId,state,finishTime,awardActivity,halfTimeActivity,rank,tmp_items,tmp_speed_rank,dungeon_items,dungeon_speed_items,progress)
	self.c_sb.play(function ()
		
	end)
	self:updateItems(tmp_items,tmp_speed_rank)
	self:updateDungeonItems(dungeon_items,dungeon_speed_items)
	self:updateDetailData(mapId,state,finishTime,awardActivity,halfTimeActivity,rank,progress)
end 

function wnd_faction_team_dungeon_over:onRank(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_FactionTeamDungeonDamageRank)
	g_i3k_ui_mgr:RefreshUI(eUIID_FactionTeamDungeonDamageRank,g_i3k_game_context:GetFactionTeamRankData())
	
end 

function wnd_faction_team_dungeon_over:updateDungeonItems(dungeon_items,dungeon_speed_items)

	
	for i,v in ipairs(dungeon_items) do
		local _layer = require(LAYER_BPFBT2)()
		local bt = _layer.vars.bt 
		local grade_icon = _layer.vars.grade_icon 
		local item_icon = _layer.vars.item_icon 
		local item_count = _layer.vars.item_count 
		item_count:setText(string.format("×%s",v.count))
		bt:setTag(v.id)
		bt:onClick(self,self.onItemTips)
		
		grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
		item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id,i3k_game_context:IsFemaleRole()))
		
		self.item_scroll:addItem(_layer)
	end
	
	for i,v in ipairs(dungeon_speed_items) do
		if i == 1 then
			local _layer = require(LAYER_BPFBT3)()
			self.item_scroll:addItem(_layer)
		end 
		local _layer = require(LAYER_BPFBT2)()
		local bt = _layer.vars.bt 
		local grade_icon = _layer.vars.grade_icon 
		local item_icon = _layer.vars.item_icon 
		local item_count = _layer.vars.item_count 
		item_count:setText(string.format("×%s",v.count))
		bt:setTag(v.id)
		bt:onClick(self,self.onItemTips)
		
		grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
		item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id,i3k_game_context:IsFemaleRole()))
		
		self.item_scroll:addItem(_layer)
	end
end 

function wnd_faction_team_dungeon_over:updateItems(items,tmp_speed_rank)
	
	
	for i,v in ipairs(items) do
		local _layer = require(LAYER_BPFBT2)()
		local bt = _layer.vars.bt 
		local grade_icon = _layer.vars.grade_icon 
		local item_icon = _layer.vars.item_icon 
		local item_count = _layer.vars.item_count 
		item_count:setText(string.format("×%s",v.count))
		bt:setTag(v.id)
		bt:onClick(self,self.onItemTips)
		
		grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
		item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id,i3k_game_context:IsFemaleRole()))
		
		self.rank_scroll:addItem(_layer)
	end
	
	for i,v in ipairs(tmp_speed_rank) do
		if i == 1 then
			local _layer = require(LAYER_BPFBT3)()
			self.rank_scroll:addItem(_layer)
		end 
		local _layer = require(LAYER_BPFBT2)()
		local bt = _layer.vars.bt 
		local grade_icon = _layer.vars.grade_icon 
		local item_icon = _layer.vars.item_icon 
		local item_count = _layer.vars.item_count 
		item_count:setText(string.format("×%s",v.count))
		bt:setTag(v.id)
		bt:onClick(self,self.onItemTips)
		
		grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
		item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id,i3k_game_context:IsFemaleRole()))
		
		self.rank_scroll:addItem(_layer)
	end
end 

function wnd_faction_team_dungeon_over:onItemTips(sender,eventType)
	--if eventType == ccui.TouchEventType.ended then
		local tag = sender:getTag()
		g_i3k_ui_mgr:ShowCommonItemInfo(tag)
	--end
end

function wnd_faction_team_dungeon_over:updateDetailData(mapId,state,passTime,count1,count2,rank,progress)
	if state  then
		self.bar_root:hide()
		self.title_lable:setText(self:getPassTime(passTime))
		if count2 ~= 0 then
			self.activity:setText(i3k_get_string(739,count1 + count2,count1,count2))
		else
			self.activity:setText(i3k_get_string(740,count1,count1))
		end
		self.win_icon:show()
		self.fail_icon:hide()
	else 
		self.bar_root:show()
		local tmp = progress/10000*100
		self.bar:setPercent(tmp)
		local tmp_str = string.format("%s%%",math.modf(progress/10000*100))
		self.bar_label:setText(tmp_str)
		self.title_lable:setText("通关进度：")
		self.activity:setText(i3k_get_string(740,count1,count1))
		self.win_icon:hide()
		self.fail_icon:show()
	end
	self.rank:setText(string.format("您在本次团本中获得第%s名，奖励如下（通过信件发放）",rank))
end 

function wnd_faction_team_dungeon_over:getPassTime(passTime)
	local d = math.modf(passTime/(60*60*24))
	local h = math.modf((passTime - (d*(60*60*24)))/(60*60))
	local m = math.modf((passTime - d*60*60*24 - h*60*60)/60)
	if d ~= 0 then
		return string.format("通关时间：%s天%s小时%s分钟",d,h,m)
	else
		if h ~= 0 then
			return string.format("通关时间：%s小时%s分钟",h,m)
		else
			if m ~= 0 then
				return string.format("通关时间：%s分钟",m)
			else
				return string.format("通关时间：%s秒",passTime)
			end
		end 
	end
end 

function wnd_faction_team_dungeon_over:onExit(sender)
	i3k_sbean.mapcopy_leave()
end 

function wnd_create(layout, ...)
	local wnd = wnd_faction_team_dungeon_over.new();
		wnd:create(layout, ...);

	return wnd;
end


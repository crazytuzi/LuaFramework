-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_control_layer = i3k_class("wnd_faction_control_layer", ui.wnd_base)

local LAYER_BPGLT = "ui/widgets/bpglt"
local job_text = {"帮主","副帮主","长老","精英","平民"}
local g_online = 1
local g_active = 2
local g_dungeon = 3

--标题图片 离线，七日，副本
local title_icons = {2561,2562,2563}

function wnd_faction_control_layer:ctor()
	self._list_data = {}
	self._list_type = nil 
end

function wnd_faction_control_layer:configure(...)
	self._layout.vars.close:onClick(self,self.onCloseUI)
	self.titel_icon = self._layout.vars.titel_icon 
	self.online_btn = self._layout.vars.online_btn 
	self.online_btn:onClick(self,self.onLine)
	self.active_btn = self._layout.vars.active_btn 
	self.active_btn:onClick(self,self.onActive)
	self.dungeon_btn = self._layout.vars.dungeon_btn 
	self.dungeon_btn:onClick(self,self.onDungeon)
	
	self.all_btn = {self.online_btn,self.active_btn,self.dungeon_btn}
	self.member_count = self._layout.vars.member_count 
	
	self.scroll = self._layout.vars.scroll 
	
	self.kick_label = self._layout.vars.kick_label
	self.kick_label:hide() 
	
end

function wnd_faction_control_layer:onShow()
	
end

function wnd_faction_control_layer:refresh(allData)
	self:updateTitleIcon(g_online)
	self:updateBtnState(g_online)
	self._list_data = allData
	self:updateList(allData,g_online)
	self:updateNum(g_i3k_game_context:GetFactionLevel(),g_i3k_game_context:GetFactionCurrentMemberCount())
	self:updateKick(g_i3k_game_context:GetFactionLevel())
end 

function wnd_faction_control_layer:updateNum(lvl,num)
	local maxCount = i3k_db_faction_uplvl[lvl].count
	local tmp_str = string.format("%s/%s",num,maxCount)
	self.member_count:setText(tmp_str)

end 

function wnd_faction_control_layer:updateKick(lvl)
	local myPos = g_i3k_game_context:GetSectPosition()
	if i3k_db_faction_power[myPos] and i3k_db_faction_power[myPos].factionKick == 1 then
		local maxCount = i3k_db_faction_uplvl[lvl].kickCount
		local tmp_str = i3k_get_string(800,lvl,maxCount)
		self.kick_label:setText(tmp_str)
		self.kick_label:show()
	end 
end 

function wnd_faction_control_layer:updateTitleIcon(index)
	self.titel_icon:setImage(g_i3k_db.i3k_db_get_icon_path(title_icons[index]))
end 

function wnd_faction_control_layer:allBtnNormal()
	self.online_btn:stateToNormal()
	self.active_btn:stateToNormal()
	self.dungeon_btn:stateToNormal()
end 

function wnd_faction_control_layer:updateBtnState(index)
	self:allBtnNormal()
	self.all_btn[index]:stateToPressed()
end 

function wnd_faction_control_layer:onLine(sender)
	self:updateTitleIcon(g_online)
	self:updateBtnState(g_online)
	self:updateList(self._list_data,g_online)
end 

function wnd_faction_control_layer:onActive(sender)
	self:updateTitleIcon(g_active)
	self:updateBtnState(g_active)
	self:updateList(self._list_data,g_active)
end 

function wnd_faction_control_layer:onDungeon(sender)
	self:updateTitleIcon(g_dungeon)
	self:updateBtnState(g_dungeon)
	self:updateList(self._list_data,g_dungeon)
end 

function wnd_faction_control_layer:sortByOutLineTime(singleData)
		table.sort(singleData, function (a, b)
		return a.lastLogoutTime < b.lastLogoutTime
	end)
end 

function wnd_faction_control_layer:sortByActive(singleData)
		table.sort(singleData, function (a, b)
		return a.stats.weekVitality > b.stats.weekVitality
	end)
end 

function wnd_faction_control_layer:sortByDungeon(singleData)
		table.sort(singleData, function (a, b)
		return a.stats.weekSectMapTime > b.stats.weekSectMapTime
	end)
end 

function wnd_faction_control_layer:updateList(singleData,listType)
	self.scroll:removeAllChildren()
	self._list_type = listType
	if listType == g_online then
		self:sortByOutLineTime(singleData)
	elseif listType == g_active then
		self:sortByActive(singleData)
	elseif listType == g_dungeon then
		self:sortByDungeon(singleData)
	end 
	local chiefId = g_i3k_game_context:GetFactionChiefID()
	local deputy = g_i3k_game_context:GetFactionDeputyID() or {}
	local elder = g_i3k_game_context:GetFactionElderID() or {}
	local elite = g_i3k_game_context:GetFactionEliteID()
	local my_id = g_i3k_game_context:GetRoleId()
	for i,v in ipairs(singleData) do
		local _layer = require(LAYER_BPGLT)()
		local name_label = _layer.vars.name_label 
		local job_icon = _layer.vars.job_icon 
		local power = _layer.vars.power 
		local level_label = _layer.vars.level_label 
		local roleHeadBg = _layer.vars.roleHeadBg 
		local headIcon = _layer.vars.headIcon 
		local globle_btn = _layer.vars.globle_btn 
		local title_str = _layer.vars.title_str 
		local desc = _layer.vars.desc 
		
		local hicon = g_i3k_db.i3k_db_get_head_icon_ex(v.role.headIcon,g_i3k_db.eHeadShapeQuadrate)
		if hicon and hicon > 0 then
			headIcon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon))
		end
		
		name_label:setText(v.role.name)
		
		if v.role.id == chiefId then
			title_str:setText(job_text[eFactionOwner])
			self._chiefId_title = title_str
		elseif deputy[v.role.id] then
			title_str:setText(job_text[eFactionSencondOwner])
		elseif elder[v.role.id] then
			title_str:setText(job_text[eFactionElder])
		elseif elite[v.role.id] then
			title_str:setText(job_text[eFactionElite])
		else
			title_str:setText(job_text[eFactionPeple])
		end
		roleHeadBg:setImage(g_i3k_get_head_bg_path(v.role.bwType, v.role.headBorder))
		
		power:setText(v.role.fightPower)
		level_label:setText(v.role.level)
		job_icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[v.role.type].classImg))
		
		if listType == g_online then
			local tmp_str = self:getUserState(v.lastLogoutTime)
			tmp_str = string.format("离线时间：<c=green>%s</c>",tmp_str)
			desc:setText(tmp_str)
		elseif listType == g_active then
			local tmp_str = string.format("七日活跃：<c=green>%s活跃</c>",v.stats.weekVitality)
			desc:setText(tmp_str)
		elseif listType == g_dungeon then
			local tmp_str = string.format("七日副本挑战次数：<c=green>%s次</c>",v.stats.weekSectMapTime)
			desc:setText(tmp_str)
		end 
		globle_btn:onClick(self,self.onControl1)
		if my_id ~= v.role.id and v.role.id ~= chiefId then
			if deputy[v.role.id] then 
				if  my_id == chiefId  then
					
					globle_btn:onClick(self,self.onControl,{t = v,title_str = title_str})
				end 
			else
				globle_btn:onClick(self,self.onControl,{t = v,title_str = title_str})
			end
		end 
		
		self.scroll:addItem(_layer)
	end
end 

function wnd_faction_control_layer:onControl1(sender,detailData)
	
end 

function wnd_faction_control_layer:onControl(sender,detailData)
	self._job_label = detailData.title_str
	g_i3k_ui_mgr:OpenUI(eUIID_FactionControlMember)
	g_i3k_ui_mgr:RefreshUI(eUIID_FactionControlMember,detailData.t)
end 

function wnd_faction_control_layer:updateMemberJob(pos)
	self._job_label:setText(job_text[pos])
end 

function wnd_faction_control_layer:updateAllList(allData)
	self:updateTitleIcon(self._list_type)
	self:updateBtnState(self._list_type)
	self._list_data = allData
	self:updateList(allData,self._list_type)
	self:updateNum(g_i3k_game_context:GetFactionLevel(),g_i3k_game_context:GetFactionCurrentMemberCount())
end 
 

function wnd_faction_control_layer:getUserState(Timer)
	local serverTime = i3k_game_get_time()
	serverTime = i3k_integer(serverTime)
	if Timer < 0 then
		return "刚刚"
	elseif Timer == 0 then
		return "线上"
	else
		local count =  serverTime - Timer
		if count >= 3600 and count <= 3600 * 24 then
			--local nums = math.modf(count / 3600)
			local desc = "刚刚"
			--desc = string.format(desc,nums)
			return  desc 
		elseif count > 3600 * 24  and count <= 3600* 24 * 7 then 
			local nums = math.modf(count /(3600 * 24))
			local desc = "离线%s天"
			desc = string.format(desc,nums)
			return  desc 
		elseif count > 3600 * 24 *7 then
			return "久未上线"
		elseif count < 3600 then
			--local nums = math.modf(count / 60)
			local desc = "刚刚"
			--desc = string.format(desc,nums)
			return  desc 
		end
	end
end


function wnd_create(layout, ...)
	local wnd = wnd_faction_control_layer.new();
		wnd:create(layout, ...);

	return wnd;
end


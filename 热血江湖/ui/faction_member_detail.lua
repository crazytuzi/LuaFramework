-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_member_detail = i3k_class("wnd_faction_member_detail", ui.wnd_base)

local job_text = {"帮主","副帮主","长老","精英","平民"}

function wnd_faction_member_detail:ctor()
	
end

function wnd_faction_member_detail:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	
	self.head_bg = self._layout.vars.head_bg 
	self.head_icon = self._layout.vars.head_icon 
	self.role_lvl = self._layout.vars.role_lvl 
	self.role_name = self._layout.vars.role_name 
	self.role_power = self._layout.vars.role_power 
	
	self.pos_name = self._layout.vars.pos_name
	self.pos_name:setText("帮派职位：") 
	self.on_line_name = self._layout.vars.on_line_name 
	self.on_line_name:setText("离线时间：")
	self.active_name = self._layout.vars.active_name 
	self.active_name:setText("七日活跃：")
	self.contri_name = self._layout.vars.contri_name 
	self.contri_name:setText("历史贡献：")
	
	self.pos = self._layout.vars.pos 
	self.on_line = self._layout.vars.on_line 
	self.active = self._layout.vars.active 
	self.contri = self._layout.vars.contri 
	
	self.addFriendBtn = self._layout.vars.btn1
	self.descBtn = self._layout.vars.btn2
	
end

function wnd_faction_member_detail:onShow()
	
end

function wnd_faction_member_detail:refresh(detailData)
	self:updateBaseData(detailData.role)
	local chiefId = g_i3k_game_context:GetFactionChiefID()
	local deputy = g_i3k_game_context:GetFactionDeputyID() or {}
	local elder = g_i3k_game_context:GetFactionElderID() or {}
	self:updateFactionData(detailData.stats,detailData.role,chiefId,deputy,elder,detailData.lastLogoutTime)
end 

function wnd_faction_member_detail:updateBaseData(role)
	self.head_bg:setImage(g_i3k_get_head_bg_path(role.bwType, role.headBorder))
	local hicon = g_i3k_db.i3k_db_get_head_icon_ex(role.headIcon,g_i3k_db.eHeadShapeQuadrate)
	if hicon and hicon > 0 then
		self.head_icon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon))
	end
	self.role_lvl:setText(role.level)
	self.role_name:setText(role.name)
	local tmp_str = string.format("战力：%s",role.fightPower)
	self.role_power:setText(tmp_str)
	self.addFriendBtn:onClick(self,self.onAddFriend,role.id)
	self.descBtn:onClick(self,self.onDescBtn,role.id)
end 

function wnd_faction_member_detail:onAddFriend( sender,rid )
	i3k_sbean.addFriend(rid)
	g_i3k_ui_mgr:CloseUI(eUIID_FactionMemberDetail)
end

function wnd_faction_member_detail:onDescBtn( sender,rid )
	i3k_sbean.query_rolefeature(rid)
	g_i3k_ui_mgr:CloseUI(eUIID_FactionMemberDetail)
end

function wnd_faction_member_detail:updateFactionData(stats,role,chiefId,deputy,elder,lastLogoutTime)
	local elite = g_i3k_game_context:GetFactionEliteID()
	if role.id == chiefId then
		self.pos:setText(job_text[eFactionOwner])
	elseif deputy[role.id] then
		self.pos:setText(job_text[eFactionSencondOwner])
	elseif elder[role.id] then
		self.pos:setText(job_text[eFactionElder])
	elseif elite[role.id] then
		self.pos:setText(job_text[eFactionElite])
	else
		self.pos:setText(job_text[eFactionPeple])
	end
	local desc = self:getUserState(lastLogoutTime)
	self.on_line:setText(desc)
	local tmp_str = string.format("%s活跃度",stats.weekVitality)
	self.active:setText(tmp_str)
	local tmp_str = string.format("%s帮贡",stats.contributionTotal)
	self.contri:setText(tmp_str)
end 

function wnd_faction_member_detail:getUserState(Timer)
	local serverTime = i3k_game_get_time()
	serverTime = i3k_integer(serverTime)
	if Timer < 0 then
		return "离线"
	elseif Timer == 0 then
		return "线上"
	else
		local count =  serverTime - Timer
		if count >= 3600 and count <= 3600 * 24 then
			local nums = math.modf(count / 3600)
			local desc = "离线%s小时"
			desc = string.format(desc,nums)
			return  desc 
		elseif count > 3600 * 24  and count <= 3600* 24 * 7 then 
			local nums = math.modf(count /(3600 * 24))
			local desc = "离线%s天"
			desc = string.format(desc,nums)
			return  desc 
		elseif count > 3600 * 24 *7 then
			return "久未上线"
		elseif count < 3600 then
			local nums = math.modf(count / 60)
			local desc = "离线%s分钟"
			desc = string.format(desc,nums)
			return  desc 
		end
	end
end

function wnd_faction_member_detail:updateBtn(btns)
	local vars = self._layout.vars
	vars.btn2:setVisible(false)
	for k,v in ipairs(btns) do
		vars['btn' .. k]:setVisible(true)
		vars['btn' .. k]:onClick(self,v.func)
		vars['btn_desc' .. k]:setText(v.desc)
	end
end

function wnd_faction_member_detail:addBtn(btns)
	local vars = self._layout.vars
	for k,v in ipairs(btns) do
		vars['btn' .. (k + 2)]:setVisible(true)
		vars['btn' .. (k + 2)]:onClick(self,v.func)
		vars['btn_desc' .. (k + 2)]:setText(v.desc)
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_faction_member_detail.new();
		wnd:create(layout, ...);

	return wnd;
end


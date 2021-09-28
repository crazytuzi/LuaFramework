-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_control_member = i3k_class("wnd_faction_control_member", ui.wnd_base)

local job_text = {"帮主","副帮主","长老","精英","平民"}

function wnd_faction_control_member:ctor()
	
end

function wnd_faction_control_member:configure(...)
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
	
	self._all_btn = {
		self._layout.vars.btn1,
		self._layout.vars.btn2,
		self._layout.vars.btn3,
		self._layout.vars.btn4,
		self._layout.vars.btn5,
	}
	self._btn_str = {
		self._layout.vars.btn_desc1,
		self._layout.vars.btn_desc2,
		self._layout.vars.btn_desc3,
		self._layout.vars.btn_desc4,
		self._layout.vars.btn_desc5,
	}
	
end

function wnd_faction_control_member:onShow()
	
end

function wnd_faction_control_member:refresh(detailData)
	self:updateBaseData(detailData.role)
	local chiefId = g_i3k_game_context:GetFactionChiefID()
	local deputy = g_i3k_game_context:GetFactionDeputyID() or {}
	local elder = g_i3k_game_context:GetFactionElderID() or {}
	self:updateFactionData(detailData.stats,detailData.role,chiefId,deputy,elder,detailData.lastLogoutTime)
	self:updateControlBtn(detailData.role.id,detailData.role.name,chiefId,deputy,elder)
end 

function wnd_faction_control_member:updateBaseData(role)
	self.head_bg:setImage(g_i3k_get_head_bg_path(role.bwType, role.headBorder))
	local hicon = g_i3k_db.i3k_db_get_head_icon_ex(role.headIcon,g_i3k_db.eHeadShapeQuadrate)
	if hicon and hicon > 0 then
		self.head_icon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon))
	end
	self.role_lvl:setText(role.level)
	self.role_name:setText(role.name)
	local tmp_str = string.format("战力：%s",role.fightPower)
	self.role_power:setText(tmp_str)
end 

function wnd_faction_control_member:updateFactionData(stats,role,chiefId,deputy,elder,lastLogoutTime)
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

function wnd_faction_control_member:getUserState(Timer)
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

function wnd_faction_control_member:updateControlBtn(roleId,name,chiefId,deputy,elder)
	local my_id = g_i3k_game_context:GetRoleId()
	if my_id == chiefId then 
		self:updateBanZhuBtn(roleId,name,deputy,elder)
	elseif deputy[my_id] then
		self:updateFuBanZhuBtn(roleId,name,deputy,elder)
	end
	
end 

function wnd_faction_control_member:updateBanZhuBtn(roleId,name,deputy,elder)
	local elite = g_i3k_game_context:GetFactionEliteID()
	for i,v in ipairs(self._all_btn) do
		if i== 1 then 
			if deputy[roleId] then
				self._btn_str[i]:setText("转让帮主")
				v:onClick(self,self.onGiveBangZhu,{id = roleId,name = name,pos = 1})
			else 
				self._btn_str[i]:setText("任命副帮主")
				v:onClick(self,self.onGivePos,{id = roleId,name = name,pos = 2})
			end
		elseif i == 2 then
			if deputy[roleId] then
				self._btn_str[i]:setText("降为长老")
				v:onClick(self,self.onGivePos,{id = roleId,name = name,pos = 3})
			elseif elder[roleId] then
				self._btn_str[i]:setText("降为成员")
				v:onClick(self,self.onGivePos,{id = roleId,name = name,pos = 5})
			else
				self._btn_str[i]:setText("任命长老")
				v:onClick(self,self.onGivePos,{id = roleId,name = name,pos = 3})
			end
			
		elseif i == 4 then
			if deputy[roleId]  then
				self._btn_str[i]:setText("降为成员")
				v:onClick(self,self.onGivePos,{id = roleId,name = name,pos = 5})
			elseif elder[roleId] then
				self._btn_str[i]:setText("踢出帮派")
				v:onClick(self,self.onKickOut,{id = roleId,name = name})
			else
				self._btn_str[i]:setText("踢出帮派")
				v:onClick(self,self.onKickOut,{id = roleId,name = name})
			end
		elseif i == 5 then
			if deputy[roleId]  then
				self._btn_str[i]:setText("踢出帮派")
				v:onClick(self,self.onKickOut,{id = roleId,name = name})
			elseif elder[roleId] then
				v:hide()
			else
				v:hide()
			end
		elseif i == 3 then
			if elite[roleId] then
				self._btn_str[i]:setText("降为成员")
				v:onClick(self,self.onGivePos,{id = roleId,name = name,pos = 5})
			elseif deputy[roleId] or elder[roleId] then
				self._btn_str[i]:setText("降为精英")
				v:onClick(self,self.onGivePos,{id = roleId,name = name,pos = 4})
			else
				self._btn_str[i]:setText("任命精英")
				v:onClick(self,self.onGivePos,{id = roleId,name = name,pos = 4})
			end
		end
		
	end
end 

function wnd_faction_control_member:updateFuBanZhuBtn(roleId,name,deputy,elder)
	local elite = g_i3k_game_context:GetFactionEliteID()
	for i,v in ipairs(self._all_btn) do
		if i== 1 then 
			if elder[roleId] then
				self._btn_str[i]:setText("降为成员")
				v:onClick(self,self.onGivePos,{id = roleId,name = name,pos = 4})
			else
				self._btn_str[i]:setText("任命长老")
				v:onClick(self,self.onGivePos,{id = roleId,name = name,pos = 3})
			end
		elseif i == 3 then
			self._btn_str[i]:setText("踢出帮派")
			v:onClick(self,self.onKickOut,{id = roleId,name = name})
		elseif i == 2 then
			if elite[roleId] then
				self._btn_str[i]:setText("降为成员")
				v:onClick(self,self.onGivePos,{id = roleId,name = name,pos = 5})
			elseif elder[roleId] then
				self._btn_str[i]:setText("降为精英")
				v:onClick(self,self.onGivePos,{id = roleId,name = name,pos = 4})
			else
				self._btn_str[i]:setText("任命精英")
				v:onClick(self,self.onGivePos,{id = roleId,name = name,pos = 4})
			end
		else
			v:hide()
		end 
	end
end 

function wnd_faction_control_member:onGiveBangZhu(sender,t)
	
	local fun = (function(ok) 
		if ok then
			i3k_sbean.sect_renming_pos(t.id,t.pos)
		end 
	end)
	local desc = i3k_get_string(10079,t.name)
	g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
	g_i3k_ui_mgr:CloseUI(eUIID_FactionControlMember)
end

function wnd_faction_control_member:onGivePos(sender,t)
	i3k_sbean.sect_renming_pos(t.id,t.pos)
	g_i3k_ui_mgr:CloseUI(eUIID_FactionControlMember)
end 



function wnd_faction_control_member:onKickOut(sender,t)
	
	local role_id = t.id
	if g_i3k_game_context:judgeInFactionFight() and g_i3k_game_context:isInFactionFightGroup(role_id) then
		g_i3k_ui_mgr:PopupTipMessage("当前处于帮派战阶段,操作失败")
		return
	end
	
	local tmp_fun = function ()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionControlLayer,"updateAllList",g_i3k_game_context:GetFactionMemberList())
	end
	
	local fun = (function(ok) 
		if ok then
			local data = i3k_sbean.sect_kick_req.new()
			data.roleId = t.id
			data.fun = tmp_fun
			i3k_game_send_str_cmd(data,i3k_sbean.sect_kick_res.getName())
		end 
	end)
	local desc = i3k_get_string(10075,t.name)
	g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
	g_i3k_ui_mgr:CloseUI(eUIID_FactionControlMember)
end


function wnd_create(layout, ...)
	local wnd = wnd_faction_control_member.new();
		wnd:create(layout, ...);

	return wnd;
end


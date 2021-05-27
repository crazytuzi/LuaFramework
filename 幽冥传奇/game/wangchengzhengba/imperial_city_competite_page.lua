ImperialCityCompetitePage = ImperialCityCompetitePage or BaseClass()


function ImperialCityCompetitePage:__init()
	self.view = nil
	self.role_display_list = {}
	self.role_mode_list = {}
end	

function ImperialCityCompetitePage:__delete()
	self:RemoveEvent()

	for _,v in pairs(self.role_display_list) do
		v:DeleteMe()
	end	
	self.role_display_list = {}

	self.parent = nil
	self.view = nil
end	

--初始化页面接口
function ImperialCityCompetitePage:InitPage(view)
	if not view then ErrorLog("ImperialCityCompetitePage View Does Not Exist. InitPage Failed!!!!!") return end
	--绑定要操作的元素
	self.view = view
	self.parent = view and view.node_t_list.layout_atk_main_wnd
	self:CreateRoleDisplays()

	self:InitEvent()
	
end	

--初始化事件
function ImperialCityCompetitePage:InitEvent()
	if not self.parent then return end

	XUI.AddClickEventListener(self.parent.btn_akt_rule.node, BindTool.Bind(self.OnAtkRule, self), true)
	XUI.AddClickEventListener(self.parent.btn_apply_guild.node, BindTool.Bind(self.OnApplyGuild, self), true)
	XUI.AddClickEventListener(self.parent.btn_go_war_field.node, BindTool.Bind(self.OnGoWarField, self), true)

	self.manager_info_handler = GlobalEventSystem:Bind(GongchengEventType.GONGCHENG_WIN_MANAGER_INFO,BindTool.Bind(self.OnManagerInfoChange,self))
	self.outline_role_vo_handler = GlobalEventSystem:Bind(GongchengEventType.GONGCHENG_ROLE_VO_BACK,BindTool.Bind(self.OnVoInfoChange,self))
end

--移除事件
function ImperialCityCompetitePage:RemoveEvent()
	if self.manager_info_handler then
		GlobalEventSystem:UnBind(self.manager_info_handler)
		self.manager_info_handler = nil
	end	

	if self.outline_role_vo_handler then
		GlobalEventSystem:UnBind(self.outline_role_vo_handler)
		self.outline_role_vo_handler = nil
	end	
end

--创建显示模型
function ImperialCityCompetitePage:CreateRoleDisplays()
	for i = 1, 5 do
		local ph = self.view.ph_list["ph_mod_" .. i]
		local role_display = RoleDisplay.New(self.parent.node, -1, false, false,true, false)
		role_display:SetPosition(ph.x,ph.y)
		self.role_display_list[i] = role_display

		if i == 2 or i == 4 then
			role_display:GetRootNode():setScaleX(-1)
		end	
	end	
end	

function ImperialCityCompetitePage:OnVoInfoChange()
	local temp_vo = nil
	for i = 1 , 5 do --遍历职位
		local manager_info = WangChengZhengBaData.Instance:GetManagerByPos(i)
		if manager_info then --有管理者信息
			if i == 1 then
				local temp_info =  WangChengZhengBaData.Instance:GetDefaultEquipInfo(i)
				temp_vo = {[OBJ_ATTR.ENTITY_MODEL_ID] = temp_info.model * 10 + manager_info.sex,[OBJ_ATTR.ACTOR_WEAPON_APPEARANCE] = temp_info.weapon * 10,[OBJ_ATTR.ACTOR_WING_APPEARANCE] = 0,[OBJ_ATTR.ACTOR_SEX] = 0,[OBJ_ATTR.ACTOR_FOOT_APPEARANCE] = 0}
				self.role_display_list[i]:SetRoleVo(temp_vo)
				--默认
			else	
				local role_vo = WangChengZhengBaData.Instance:GetSbkRoleVoByName(manager_info.role_id)
				if role_vo then
					self.role_display_list[i]:SetRoleVo(role_vo)
				else	
					local temp_info =  WangChengZhengBaData.Instance:GetDefaultEquipInfo(i)
					temp_vo = {[OBJ_ATTR.ENTITY_MODEL_ID] = temp_info.model * 10,[OBJ_ATTR.ACTOR_WEAPON_APPEARANCE] = temp_info.weapon * 10,[OBJ_ATTR.ACTOR_WING_APPEARANCE] = 0,[OBJ_ATTR.ACTOR_SEX] = 0,[OBJ_ATTR.ACTOR_FOOT_APPEARANCE] = 0}
					self.role_display_list[i]:SetRoleVo(temp_vo)
					--默认
				end	
			end
		else
			local temp_info =  WangChengZhengBaData.Instance:GetDefaultEquipInfo(i)
			temp_vo = {[OBJ_ATTR.ENTITY_MODEL_ID] = temp_info.model * 10 ,[OBJ_ATTR.ACTOR_WEAPON_APPEARANCE] = temp_info.weapon * 10,[OBJ_ATTR.ACTOR_WING_APPEARANCE] = 0,[OBJ_ATTR.ACTOR_SEX] = 0,[OBJ_ATTR.ACTOR_FOOT_APPEARANCE] = 0}
			self.role_display_list[i]:SetRoleVo(temp_vo)
			--默认
		end	
	end	
end	

function ImperialCityCompetitePage:OnManagerInfoChange()
	self:UpdateData()
end	

--更新视图界面
function ImperialCityCompetitePage:UpdateData(data)
	self:Clear()
	self:OnVoInfoChange()
	if not self.parent then return end
	self.parent.lbl_guild_name.node:setString(WangChengZhengBaData.Instance:GetWinnerGuildName())
	local list =  WangChengZhengBaData.Instance.sbk_manager_list
	if list then
		for i = 1, #list do
			local info = list[i]
			self.parent["lbl_pos_name_" .. info.pos].node:setString(info.name)
		end
	end
	

	self.view.node_t_list.lbl_open_time.node:setString(WangChengZhengBaData.GetNextOpenTimeDateStr())
end	

function ImperialCityCompetitePage:Clear()
	for i = 1, 5 do
		self.parent["lbl_pos_name_" .. i].node:setString(Language.WangChengZhengBa.NoPost)
	end
end	

function ImperialCityCompetitePage:SetPostModels(vo)

end

function ImperialCityCompetitePage:OnAtkRule()
	self.view:ShowIndex(TabIndex.imperial_city_rules)
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

function ImperialCityCompetitePage:OnApplyGuild()
	self.view:ShowIndex(TabIndex.imperial_city_act_info)
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

function ImperialCityCompetitePage:OnGoWarField()
	Scene.Instance:GetMainRole():LeaveFor(GuildConfig.guildSiegeGotoScenePosition[1],GuildConfig.guildSiegeGotoScenePosition[2],GuildConfig.guildSiegeGotoScenePosition[3])
end
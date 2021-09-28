KfLiujieRewardTip = KfLiujieRewardTip or BaseClass(BaseView)

function KfLiujieRewardTip:__init()
	self.ui_config = {"uis/views/kuafuliujie_prefab", "KuafuLiujieRewardTips"}
	self.item_list = {}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self.title_id = 0
	self.top_title_id = 0
end

local def_prof =
{
	[1] = 4,
	[3] = 3,
	[4] = 2,
	[5] = 1,
	[6] = 3,
}

local def_sex =
{
	[1] = 0,
	[3] = 1,
	[4] = 0,
	[5] = 1,
	[6] = 1,
}

local def_area =   --title id 对应 服务器发的
{
	[1] = 2,	--皇城
	[2] = 1,	--冰雪
	[3] = 3,	--焚炎
	[4] = 4,	--神木
	[5] = 5,	--时沙
	[6] = 6,	--巨石
}

function KfLiujieRewardTip:__delete()
    self.title_id = nil
	self.top_title_id = nil
end

function KfLiujieRewardTip:ReleaseCallBack()
	self.data_list = nil
	for k,v in pairs(self.item_list) do
		if v.item_cell then
			v.item_cell:DeleteMe()
		end
	end

	if self.tips_model then
		self.tips_model:DeleteMe()
		self.tips_model = nil
	end

	self.item_list = {}
	self.show_gray = nil
	self.show_button = nil
	self.img_title = nil
	self.text_cap = nil
	self.display = nil
	self.top_text = nil
	self.is_show_clothers_title = nil
	self.tips_model = nil
	self.is_guild_war = nil
	self.model_cap_text = nil
end

function KfLiujieRewardTip:LoadCallBack()
	self:ListenEvent("CloseView", BindTool.Bind(self.CloseView, self))
	self:ListenEvent("ClickOK", BindTool.Bind(self.ClickOK, self))
	for i = 1, 3 do
		local item_obj = self:FindObj("Item"..i)
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(item_obj)
		self.item_list[i - 1] = {item_obj = item_obj, item_cell = item_cell}
	end
	self.show_gray = self:FindVariable("ShowGray")
	self.show_button = self:FindVariable("ShowButton")
	self.img_title = self:FindVariable("img_title")
	self.text_cap = self:FindVariable("text_cap")
	self.top_text = self:FindVariable("top_text")
	self.is_guild_war = self:FindVariable("Is_Guild_War")
	self.model_cap_text = self:FindVariable("model_cap_text")


	self.is_show_clothers_title = self:FindVariable("is_showclotherstitle")
	self.display = self:FindObj("Display")
	self.tips_model = RoleModel.New("kuafuliujie_tips_panel")
	self.tips_model:SetDisplay(self.display.ui3d_display)
end

function KfLiujieRewardTip:SetData(items, show_gray, ok_callback, show_button, title_id, top_title_id, act_type)
	self.data_list = items
	self.show_gray_data = show_gray
	self.ok_callback = ok_callback
	self.show_button_value = show_button
	self.title_id = title_id
	self.top_title_id = top_title_id
	self.act_type = act_type
end

function KfLiujieRewardTip:CloseView()
	self:Close()
end

function KfLiujieRewardTip:ClickOK()
	if self.ok_callback then
		self.ok_callback()
	end
	-- self:Close()
end

function KfLiujieRewardTip:OpenCallBack()
	self:Flush()
end

function KfLiujieRewardTip:OnFlush()
	if self.data_list ~= nil then
		for k, v in pairs(self.item_list) do
			if self.data_list[k] then
				v.item_cell:SetData(self.data_list[k])
				v.item_obj:SetActive(true)
			else
				v.item_obj:SetActive(false)
			end
		end
		if self.show_button_value == nil then
			self.show_button:SetValue(false)
		else
			self.show_button:SetValue(self.show_button_value)
		end
	end

	if nil ~= self.top_title_id then
		if tonumber(self.top_title_id) then
			if self.top_title_id > 0 then
				local str = Language.RecordRank.NameList[self.top_title_id]
				self.top_text:SetValue(str)
			end
		else
			self.top_text:SetValue(self.top_title_id)
		end
	end

	--设置模型
	if self.act_type == ACTIVITY_TYPE.GUILDBATTLE then
		local reward_mount_id = GuildFightData.Instance:GetRewardMountSpecialId()
		local power_text = ItemData.GetFightPower(reward_mount_id)
		self:SetGuildWarRewardModelRes()
		self.is_guild_war:SetValue(true)
		self.model_cap_text:SetValue(power_text)

		local guild_war_info = GuildFightData.Instance:GetGuildBattleDailyRewardFlag()
		if guild_war_info then
			self.show_gray:SetValue(guild_war_info.had_fetch == 1)
		end
	else
   		self:SetModelRes()
		self.is_guild_war:SetValue(false)
   	end

   	if self.title_id > 0 then
		local bundle, asset = ResPath.GetTitleIcon(self.title_id)
		self.img_title:SetAsset(bundle, asset)

		local title_cfg = TitleData.Instance:GetTitleCfg(self.title_id)
		self.text_cap:SetValue(CommonDataManager.GetCapabilityCalculation(title_cfg))
	end
end

function KfLiujieRewardTip:SetModelRes()
local info = KuafuGuildBattleData.Instance:GetGuildBattleInfo() 
	if info == nil then
		return
	end

	local shizhuangcfg = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto")
	if shizhuangcfg == nil or shizhuangcfg.cfg == nil then
		return
	end
    
    local fashion_cfg = shizhuangcfg.cfg
	local rolezhuansheng_cfg = ConfigManager.Instance:GetAutoConfig("rolezhuansheng_auto")
	if rolezhuansheng_cfg == nil or rolezhuansheng_cfg.job == nil then
		return
	end

    local job_cfg = rolezhuansheng_cfg.job
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()	
    if main_role_vo == nil then
    	return
    end

	local res_index = KuafuGuildBattleData.Instance:GetShowImage(2) or 0
	local get_area_id = def_area[self.top_title_id] or 0		--城市对应相应霸主的信息

	if info.kf_battle_list == nil or info.kf_battle_list[get_area_id] == nil then   --霸主信息
		return
	end

	local data = info.kf_battle_list[get_area_id]
	if data.prof == nil or data.sex == nil or nil == job_cfg or job_cfg[data.prof] == nil then 
		return
	end

	local role_job = job_cfg[data.prof]
	self.tips_model:ResetRotation()
	self.tips_model:ClearModel()
	if data.guild_id == nil then
		return 
	end

	local role_info = data     
	if data.guild_id <= 0 then
		role_info = main_role_vo
	end

	local weapon_id = 0
	local role_res_id = 0
	if get_area_id == 2 then
	    --皇城
		for k, v in pairs(fashion_cfg) do
		 	local role_id  = v["resouce" .. role_info.prof .. role_info.sex]
			if v.index == res_index and nil ~= role_id and v.part_type == 1 then
				role_res_id = role_id
		 	end

            if v.index == res_index and nil ~= role_id and v.part_type == 0 then
		 		weapon_id = role_id
		 	end

		end

		self.is_show_clothers_title:SetValue(true)
	else
		--其他5个城市，有城主
		if data.guild_id > 0  then
			-- 从职业表中拿到角色模型
		    role_res_id = role_job["model" .. role_info.sex]
		     for k, v in pairs(fashion_cfg) do
		     	local temp_weapon_id = v["resouce" .. role_info.prof .. role_info.sex]
				if v.index == res_index and v.part_type == 0 and nil ~= temp_weapon_id then
			 	    weapon_id = temp_weapon_id
				end
			end
		else
			--其他5个城市，无城主
			role_res_id = job_cfg[def_prof[get_area_id]]["model" .. def_sex[get_area_id]]
			for k, v in pairs(fashion_cfg) do
				if v.index == res_index and v.part_type == 0 and v["resouce" .. def_prof[get_area_id] .. def_sex[get_area_id]] then
					weapon_id = v["resouce" .. def_prof[get_area_id] .. def_sex[get_area_id]]
				end
			end
		end

		self.is_show_clothers_title:SetValue(false)
	end

	self.tips_model:SetPanelName("kuafuliujie_tips_panel")
	self.tips_model:SetRoleResid(role_res_id)
	self.tips_model:SetWeaponResid(weapon_id)
end

function KfLiujieRewardTip:SetGuildWarRewardModelRes()
	local now_cfg = GuildFightData.Instance:GetConfig()
	if nil == now_cfg then
		return
	end

	local model_show = now_cfg.other[1].path
	local open_day_list = Split(model_show, ",")
	local bundle, asset = open_day_list[1], open_day_list[2]
	local display_name = "free_gift_panel"

	if string.find(bundle, "mount") ~= nil then
		self.tips_model:SetPanelName("guild_war_tips")
	end
	self.tips_model:SetMainAsset(bundle, asset)
end


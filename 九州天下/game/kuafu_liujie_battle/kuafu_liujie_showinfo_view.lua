KuafuLiuJieShowInfoView = KuafuLiuJieShowInfoView or BaseClass(BaseRender)


function KuafuLiuJieShowInfoView:__init()
	self.show_item = {}
	for i = 1, 6 do
		self.show_item[i] = LiuJieShowItem.New(self:FindObj("show_item" .. i))
		self.show_item[i]:SetIndex(i)
	end
end

function KuafuLiuJieShowInfoView:__delete()
	for k, v in pairs(self.show_item) do
		v:DeleteMe()
	end
	self.show_item = nil
end

function KuafuLiuJieShowInfoView:OnFlush()
	local info = KuafuGuildBattleData.Instance:GetGuildBattleInfo()
	if nil == info or info.kf_battle_list == nil then
		return
	end
	local data_list = info.kf_battle_list
	for i = 1, 6 do
		self.show_item[i]:SetData(data_list[i])
	end
end

local def_prof = 
{
	[1] = 0,	-- 主城
	[2] = 3,
	[3] = 2,
	[4] = 1,
	[5] = 2,
	[6] = 3,
}

local def_sex = 
{
	[1] = 0,	-- 主城
	[2] = 0,
	[3] = 1,
	[4] = 1,
	[5] = 0,
	[6] = 1,
}





LiuJieShowItem = LiuJieShowItem or BaseClass(BaseRender)
function LiuJieShowItem:__init()
	self.display = self:FindObj("Display")
	self.top_text = self:FindVariable("top_text")
	self.title = self:FindObj("Title")

	self.model = RoleModel.New("kaifu_liujie_show_info_view")
	self.model:SetDisplay(self.display.ui3d_display)
end

function LiuJieShowItem:__delete()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	self.ui_title_res = nil
end

function LiuJieShowItem:SetData(data)
	if nil == data then
		return
	end
	self.current_title_id = KuafuGuildBattleData.Instance:GetOwnReward(self.index - 1).title_name
	local role_res_id = 0
	local weapon_id = 0
	local weapon_id2 = 0
	local prof = 0
	local sex = 0
	self.model:ResetRotation()
	local res_index = KuafuGuildBattleData.Instance:GetShowImage(self.index)
	local fashion_cfg = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").cfg
	local job_cfg = ConfigManager.Instance:GetAutoConfig("rolezhuansheng_auto").job
	if data.guild_id > 0 then
		local name = string.format(Language.KuafuGuildBattle.KfGuildServe, COLOR[CAMP_BY_STR[data.guild_id]], data.guild_name, data.server_id, data.guild_tuanzhang_name)
		self.top_text:SetValue(name)
		prof = data.prof ~= 0 and data.prof or def_prof[self.index]
		sex = data.sex ~= 0 and data.sex or def_sex[self.index]
	else
		self.top_text:SetValue(Language.KuafuGuildBattle.KfNoOccupy)
		prof = def_prof[self.index]
		sex = def_sex[self.index]
	end

	for k, v in pairs(fashion_cfg) do
		if res_index == v.index then
			if v.part_type == 0 then
				weapon_id = v["resouce" .. prof .. sex]
				if def_prof[self.index] == 3 then
					local t = Split(weapon_id,",")
					weapon_id = t[1]
					weapon_id2 = t[2]
				end
			else
				role_res_id = v["resouce" .. prof .. sex]
			end
		end
	end
	self.model:SetMainAsset(ResPath.GetRoleModel(role_res_id))
	self.model:SetWeaponResid(weapon_id)
	self.model:SetWeapon2Resid(weapon_id2)

	-- 设置天罡
	local halo_img_id = data.info.appearance.halo_img_id or 0
	local halo_cfg = nil
	-- 特殊天罡1000起
	if halo_img_id > 1000 then
		halo_cfg = HaloData.Instance:GetSpecialImageCfg(halo_img_id - 1000)
	elseif halo_img_id > 0 then
		halo_cfg = HaloData.Instance:GetHaloImageCfg(halo_img_id)
	end
	local halo_res_id = halo_cfg and halo_cfg.res_id or 0
	self.model:SetHaloResid(halo_res_id)

	-- if data.guild_id > 0 then	
	-- 	self.top_text:SetValue(string.format(Language.KuafuGuildBattle.KfGuildShowName,data.guild_name,data.guild_tuanzhang_name .."_s" .. data.server_id))
	-- 	self.model:ClearModel()
	-- 	self.model:SetModelResInfo(data.info)
	-- else
	-- 	self.top_text:SetValue(Language.KuafuGuildBattle.KfGuildShowNoOccupy)
	-- 	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	-- 	local role_job = job_cfg[main_role_vo.prof]
	-- 	for k, v in pairs(fashion_cfg) do
	-- 		if res_index == v.index and v["resouce" .. main_role_vo.prof .. main_role_vo.sex] then
	-- 			if v.part_type == 0 then
	-- 				weapon_id = v["resouce" .. def_prof[self.index] .. def_sex[self.index]]
	-- 				if def_prof[self.index] == 3 then
	-- 					local t = Split(weapon_id,",")
	-- 					weapon_id = t[1]
	-- 					weapon_id2 = t[2]
	-- 				end
	-- 			else
	-- 				role_res_id = v["resouce" .. def_prof[self.index] .. def_sex[self.index]]
	-- 			end
	-- 		end
	-- 	end
	-- 	self.model:SetMainAsset(ResPath.GetRoleModel(role_res_id))
	-- 	self.model:SetWeaponResid(weapon_id)
	-- 	self.model:SetWeapon2Resid(weapon_id2)
	-- end


	if self.ui_title == nil then
		UtilU3d.PrefabLoad("uis/views/player_prefab", "PlayerTitle", function(obj)
			self.ui_title = obj
			-- local canvas = self.root_node:GetComponent(typeof(UnityEngine.Canvas))
			self.ui_title.transform:SetParent(self.title.transform, false)
			self.ui_title_target = self.ui_title.transform:GetComponent(typeof(UIFollowTarget))
			-- self.ui_title_target.Canvas = canvas

			local variable_table = self.ui_title:GetComponent(typeof(UIVariableTable))
			if variable_table then
				self.ui_title_res = variable_table:FindVariable("title_icon")
				self:SetUiTitle(self.ui_title_res)
			end
			self.ui_title:SetActive(true)
		end)
	end
end

function LiuJieShowItem:SetUiTitle(ui_title_res)
	self.ui_title_res = ui_title_res
	self:FlushTitle()
end

function LiuJieShowItem:FlushTitle()
	local bundle, asset = ResPath.GetTitleIcon(self.current_title_id)
	-- self.title_icon:SetAsset(bundle, asset)
	if self.ui_title_res then
		self.ui_title_res:SetAsset(bundle, asset)
	end
end

function LiuJieShowItem:SetIndex(index)
	self.index = index
end

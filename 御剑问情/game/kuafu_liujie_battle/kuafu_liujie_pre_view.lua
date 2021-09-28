KuafuLiujiePreView = KuafuLiujiePreView or BaseClass(BaseView)
function KuafuLiujiePreView:__init()
	self.ui_config = {"uis/views/kuafuliujie_prefab", "KuafuLiujiePreView"}
	self.is_first_open = 1
end

function KuafuLiujiePreView:__delete()

end

function KuafuLiujiePreView:LoadCallBack()
	self.display = self:FindObj("Display")
	self.title = self:FindObj("Title")
	self.text = self:FindVariable("text")

	self:ListenEvent("CloseWindow",BindTool.Bind(self.ClickClose,self))
end

function KuafuLiujiePreView:ReleaseCallBack()
	 if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	self.ui_title_res = nil
	self.ui_title = nil

	self.display = nil 
	self.ui_title_target = nil 
	self.title = nil
	self.text = nil
end

function KuafuLiujiePreView:OpenCallBack()
	self.is_first_open = 0
	RemindManager.Instance:Fire(RemindName.ShowKfBattlePreRemind)
	self:SetModel()
end

function KuafuLiujiePreView:SetModel()
	self.current_title_id = KuafuGuildBattleData.Instance:GetOwnReward(0).title_name
	self.model = RoleModel.New("kuafuliujie_first_panel")
	self.model:SetDisplay(self.display.ui3d_display)
	self.model:ResetRotation()
	local res_index = KuafuGuildBattleData.Instance:GetShowImage(1)
	local fashion_cfg = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").cfg
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local role_res_id = 0
	local weapon_id = 0
	local weapon_id2 = 0
	for k, v in pairs(fashion_cfg) do
		if res_index == v.index and v["resouce" .. main_role_vo.prof .. main_role_vo.sex] then
			if v.part_type == 1 then
				role_res_id = v["resouce" .. main_role_vo.prof .. main_role_vo.sex]
			else
				weapon_id = v["resouce" .. main_role_vo.prof .. main_role_vo.sex]
				if main_role_vo.prof == 3 then
					local t = Split(weapon_id, ",")
					weapon_id = t[1]
					weapon_id2 = t[2] 
				end
			end
		end
	end
	-- print("角色时装" .. role_res_id)
	-- print("第一把武器" .. weapon_id)
	-- print("第二把武器" .. weapon_id2)
	-- print("称号" .. self.current_title_id)
	self.model:SetMainAsset(ResPath.GetRoleModel(role_res_id))
	self.model:SetWeaponResid(weapon_id)
	self.model:SetWeapon2Resid(weapon_id2)
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

	local kuafu_other_cfg = KuafuGuildBattleData.Instance:GetotherCfg()
	if kuafu_other_cfg == nil then
	    return
	end 

	local level_zhuan = PlayerData.GetLevelString(kuafu_other_cfg.level_limit) or "" 
	self.text:SetValue(string.format(Language.KuafuGuildBattle.KfGuildTips, level_zhuan))

end


function KuafuLiujiePreView:SetUiTitle(ui_title_res)
	self.ui_title_res = ui_title_res
	self:FlushTitle()
end

function KuafuLiujiePreView:FlushTitle()
	local bundle, asset = ResPath.GetTitleIcon(self.current_title_id)
	-- self.title_icon:SetAsset(bundle, asset)
	if self.ui_title_res then
		self.ui_title_res:SetAsset(bundle, asset)
	end
end

function KuafuLiujiePreView:ClickClose()
   self:Close()
end
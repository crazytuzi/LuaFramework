MainUIFunctiontrailer = MainUIFunctiontrailer or BaseClass(BaseRender)

local FunTrailerType =
{
	Icon = 0,
	Model = 1,
}

local FunResType =
{
	XIAN_NV = "Goddess",
	MOUNT = "Mount",
	WING = "Wing",
	HALO = "Halo",
	ZHIBAO = "BaoJu",
	SHENGONG = "ZuJi",
	SHENYI = "Shenyi",
	GENERAL = "MingJiang",
	SPIRITHALO = "GoddessNotL",
	FAZHEN = "FaZhen",
}

function MainUIFunctiontrailer:__init()
	self.trailer_icon = self:FindVariable("trailer_icon")
	self.show_icon = self:FindVariable("show_icon")
	self.show_model = self:FindVariable("show_model")
	self.open_desc = self:FindVariable("open_desc")
	self.show_eff = self:FindVariable("ShowEff")
	self.level_text = self:FindVariable("level_text")
	self.show_reward = self:FindVariable("show_reward")
	self.model_display = self:FindObj("model")
	self.mount_model_display = self:FindObj("MountDisplay")
	self.reward_item = ItemCell.New()
	self.reward_item:SetInstanceParent(self:FindObj("RewardItem"))
	self.reward_item:ShowHighLight(false)
	self.reward_item:ListenClick(BindTool.Bind(self.OnClickReward, self))
	self.ani = self:FindObj("model_go").animator
	self.can_reward = false

	self:ListenEvent("trailer_click", BindTool.Bind(self.TrailerClick, self))
	self.scene_load_enter = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER,
		BindTool.Bind(self.FlushRewardItem, self))
	--足迹显示
	-- self.foot_display = self:FindObj("FootDisplay")
	-- local ui_foot = self:FindObj("UI_Foot")
	-- local foot_camera = self:FindObj("FootCamera")
	-- self.foot_parent = {}
	-- for i = 1, 3 do
	-- 	self.foot_parent[i] = self:FindObj("Foot_" .. i)
	-- end
	-- local camera = foot_camera:GetComponent(typeof(UnityEngine.Camera))
	-- self.foot_display.ui3d_display:Display(ui_foot.gameObject, camera)
	-- self.is_foot = self:FindVariable("IsFoot")
end

function MainUIFunctiontrailer:__delete()
	if nil ~= self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
	end

	if self.scene_load_enter then
		GlobalEventSystem:UnBind(self.scene_load_enter)
		self.scene_load_enter = nil
	end
	-- self.foot_display = nil
	-- for i = 1, 3 do
	-- 	self.foot_parent[i] = nil
	-- end
	-- self.is_foot = nil
end

function MainUIFunctiontrailer:FlushView(info)
	
	local scene_type = Scene.Instance:GetSceneType()
	local level = GameVoManager.Instance:GetMainRoleVo().level
	local main_role = Scene.Instance:GetMainRole()
	if info then
		self.can_reward = level >= info.end_level and OpenFunData.Instance:GetTrailerLastRewardId() < info.id
	elseif self.info then
		self.can_reward = level >= self.info.end_level and OpenFunData.Instance:GetTrailerLastRewardId() < self.info.id
	end
	self.show_eff:SetValue(self.can_reward)
	local rotation = Vector3(0, 0, 0)
	local scale = Vector3(1, 1, 1)
	if info and scene_type == SceneType.Common then
		self.info = info
		self.root_node:SetActive(true)

		--判断显示模型还是图标
		if info.is_model == FunTrailerType.Icon or self.can_reward  then	--or self.can_reward
			self.show_model:SetValue(false)
			self.show_icon:SetValue(true)
			local bundle, asset = ResPath.GetMainUIButton(info.icon_view)
			self.trailer_icon:SetAsset(bundle, asset)
		elseif info.is_model == FunTrailerType.Model then
			local res_type = ""
			self.show_model:SetValue(true)
			if not self.model_view then
				self.model_view = RoleModel.New("mainui_function_trailer_panel")
				self.model_view:SetDisplay(self.model_display.ui3d_display)
			end
			if not self.mount_model_view then
				self.mount_model_view = RoleModel.New("mainui_function_trailer_mount_panel")
				self.mount_model_view:SetDisplay(self.mount_model_display.ui3d_display)
			end

			self.show_icon:SetValue(false)
			if info.res_type == FunResType.XIAN_NV then
				scale = Vector3(1, 1, 1)
			elseif info.res_type == FunResType.MOUNT then
				scale = Vector3(0.5, 0.5, 0.5)
				rotation = Vector3(0, 90, 0)
			elseif info.res_type == FunResType.WING then
			elseif info.res_type == FunResType.HALO then
			elseif info.res_type == FunResType.SHENGONG then
			elseif info.res_type == FunResType.SHENYI then
			elseif info.res_type == FunResType.ZHIBAO then
			elseif info.res_type == FunResType.GENERAL then
				scale = Vector3(0.5, 0.5, 0.5)
			elseif info.res_type == FunResType.SPIRITHALO then
			elseif info.res_type == FunResType.FAZHEN then
			end
			self.model_view:SetRotation(rotation)
			self.model_view:SetModelScale(scale)
			self.ani:SetTrigger("stop")

			if info.res_type == FunResType.GENERAL then
				self.model_display:SetActive(true)
				self.mount_model_display:SetActive(false)
				self.model_view:SetMainAsset(ResPath.GetMingJiangRes(info.res_show))
			elseif info.res_type == FunResType.SHENYI then
			self.model_display:SetActive(true)
				self.mount_model_display:SetActive(false)
				self.model_view:SetRoleResid(main_role:GetRoleResId())
				self.model_view:SetMantleResid(info.res_show)
			elseif info.res_type == FunResType.HALO then
			self.model_display:SetActive(true)
				self.mount_model_display:SetActive(false)
				self.model_view:SetRoleResid(main_role:GetRoleResId())
				self.model_view:SetHaloResid(info.res_show)
			elseif info.res_type == FunResType.MOUNT then
				self.model_display:SetActive(false)
				self.mount_model_display:SetActive(true)
				self.mount_model_view:SetMainAsset(ResPath["Get"..info.res_type.."Model"](info.res_show))
			elseif info.res_type == FunResType.SPIRITHALO then
				local bundle, asset = ResPath.GetGoddessNotLModel(11105)
				self.model_display:SetActive(true)
				self.mount_model_display:SetActive(false)
				self.model_view:SetMainAsset(bundle, asset)
				self.model_view:SetHaloResid(info.res_show, true)
			else
				self.model_display:SetActive(true)
				self.mount_model_display:SetActive(false)
				self.model_view:SetMainAsset(ResPath["Get"..info.res_type.."Model"](info.res_show))
			end
		end


		if self.info and self.can_reward and self.info.auto_level and level >= self.info.auto_level then
			OpenFunCtrl.Instance:SendAdvanceNoitceOperate(1, self.info.id)
			TipsCtrl.Instance:CloseFunTrailerTip()
		end

		local desc_list = Split(info.open_dec, "#")
		local desc = ""

		if self.can_reward then
			desc = Language.Common.LingQuJiangLi
		elseif #desc_list == 1 then
			desc = info.open_dec
		else
			desc = desc_list[1].."\n"..desc_list[2]
		end
		self.open_desc:SetValue(desc)

	else
		self.root_node:SetActive(false)
	end
end

function MainUIFunctiontrailer:TrailerClick()
	if self.info then
		TipsCtrl.Instance:OpenFunTrailerTip(self.info)
	end
end

-- function MainUIFunctiontrailer:SetZujiModel(info, display_type)
-- 	for i = 1, 3 do
-- 			local bundle, asset = ResPath.GetZuJiModel("UI_" .. info.res_show)
-- 		PrefabPool.Instance:Load(AssetID(bundle, asset), function (prefab)
-- 			if nil == prefab then
-- 				return
-- 			end
-- 			if self.foot_parent[i] then
-- 				local parent_transform = self.foot_parent[i].transform
-- 				for j = 0, parent_transform.childCount - 1 do
-- 					GameObject.Destroy(parent_transform:GetChild(j).gameObject)
-- 				end
-- 				local obj = GameObject.Instantiate(prefab)
-- 				local obj_transform = obj.transform
-- 				obj_transform:SetParent(parent_transform, false)
-- 				PrefabPool.Instance:Free(prefab)
-- 			end
-- 		end)
-- 	end
-- end

function MainUIFunctiontrailer:FlushRewardItem(_level)
	local level = _level or PlayerData.Instance.role_vo.level
	local info = WelfareData.Instance:GetRewardByLevel(level)
	local is_show_state = Scene.Instance:GetSceneType() == SceneType.Common
	if next(info) and is_show_state and level >= WelfareData.Instance:GetShowLimitLevel() then
		self.show_reward:SetValue(info.is_show == 1)
	else
		self.show_reward:SetValue(false)
	end

	self.reward_item:SetData({item_id = info.show_item, num = 1, is_bind = 0})
	local bunble, asset = ResPath.GetItemEffect()
	self.reward_item:SetSpecialEffect(bunble, asset)
	self.reward_item:ShowSpecialEffect(true)
	
	local can_get = WelfareData.Instance:UpLevelRewardCanGetState()
	self.level_text:SetValue(string.format(Language.Welfare.LevelText, info.level))
	if can_get then
		self.level_text:SetValue(string.format(Language.Welfare.CanGet))
	end
end

function MainUIFunctiontrailer:OnClickReward()
	ViewManager.Instance:Open(ViewName.Welfare, TabIndex.welfare_level_reward)
end

function MainUIFunctiontrailer:SetShowReward(vlaue)
	self.show_reward:SetValue(vlaue)
end
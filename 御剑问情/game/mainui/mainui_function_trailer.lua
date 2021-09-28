MainUIFunctiontrailer = MainUIFunctiontrailer or BaseClass(BaseRender)

local FunTrailerType =
{
	Icon = 0,
	Model = 1,
}

local DISPLAYNAME = {
	[8004001] = "trailer_view_wing",
	[11005] = "trailer_view_goddess",
	[10014] = "trailer_view_tianshen",
	[10999001] = "trailer_view_baby",
}

local FunResType =
{
	XIAN_NV = "Goddess",
	MOUNT = "Mount",
	WING = "Wing",
	HALO = "Halo",
	SPIRIT = "Spirit",
	SHENGONG = "GoddessWeapon",
	SHENYI = "Shenyi",
	TIANSHEN = "Tianshen",
	BABY = "Baby",
}

function MainUIFunctiontrailer:__init()
	self.trailer_icon = self:FindVariable("trailer_icon")
	self.show_icon = self:FindVariable("show_icon")
	self.show_model = self:FindVariable("show_model")
	self.open_desc = self:FindVariable("open_desc")
	self.show_eff = self:FindVariable("ShowEff")
	self.model_display = self:FindObj("model")
	self.ani = self:FindObj("model_go").animator
	self.can_reward = false
	self.is_open = false
	self:ListenEvent("trailer_click", BindTool.Bind(self.TrailerClick, self))
	self.had_open = false
	self.level = 0
	self.label = self:FindVariable("Label")
end

function MainUIFunctiontrailer:__delete()
	if nil ~= self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
	end
end

function MainUIFunctiontrailer:FlushView(info)
	local scene_type = Scene.Instance:GetSceneType()
	if self.info ~= info then
		self.had_open = false
	end
	if self.level < GameVoManager.Instance:GetMainRoleVo().level then
		self.had_open = false
		self.level = GameVoManager.Instance:GetMainRoleVo().level
	end

	if info then
		self.can_reward = self.level >= info.end_level and OpenFunData.Instance:GetTrailerLastRewardId() < info.id
	elseif self.info then
		self.can_reward = self.level >= self.info.end_level and OpenFunData.Instance:GetTrailerLastRewardId() < self.info.id
	end
	self.show_eff:SetValue(self.can_reward)
	if info and scene_type == SceneType.Common then
		self.info = info
		self.label:SetValue(self.info.open_name)
		self.root_node:SetActive(true)
		if info.is_model == FunTrailerType.Icon or self.can_reward then
			self.show_model:SetValue(false)
			self.show_icon:SetValue(true)
			local bundle, asset = ResPath.GetMainUI(info.icon_view)
			self.trailer_icon:SetAsset(bundle, asset)
		elseif info.is_model == FunTrailerType.Model then
			local display_type = 0
			local res_type = ""
			self.show_model:SetValue(true)
			if not self.model_view then
				self.model_view = RoleModel.New("trailer_view")
				self.model_view:SetDisplay(self.model_display.ui3d_display)
			end
			self.show_icon:SetValue(false)
			if info.res_type == FunResType.XIAN_NV then
				display_type = DISPLAY_TYPE.XIAN_NV
			elseif info.res_type == FunResType.MOUNT then
				display_type = DISPLAY_TYPE.MOUNT
			elseif info.res_type == FunResType.WING then
				display_type = DISPLAY_TYPE.WING
			elseif info.res_type == FunResType.HALO then
				display_type = DISPLAY_TYPE.HALO
			elseif info.res_type == FunResType.SHENGONG then
				display_type = DISPLAY_TYPE.SHENGONG_WEAPON
			elseif info.res_type == FunResType.SHENYI then
				display_type = DISPLAY_TYPE.SHENYI
			end

			if info.res_type == FunResType.SHENGONG then
				self.ani:SetTrigger("play")
			else
				self.ani:SetTrigger("stop")
			end
			self.model_view:SetPanelName(self:SetSpecialModle(info.res_show))

			if info.res_type == FunResType.BABY then
				self.model_view:SetMainAsset(ResPath.GetSpiritModel(info.res_show))
			elseif info.res_type == FunResType.TIANSHEN then
				self.model_view:SetMainAsset(ResPath.GetGeneralRes(info.res_show))
			elseif info.res_type ~= FunResType.XIAN_NV then
				self.model_view:SetMainAsset(ResPath["Get"..info.res_type.."Model"](info.res_show))
			else
				local model_info = {}
				model_info.role_res_id = tonumber(info.res_show)
				self.model_view:SetGoddessModelResInfo(model_info)
			end
		end
		if self.info and self.can_reward and self.level >= self.info.auto_level then
			OpenFunCtrl.Instance:SendAdvanceNoitceOperate(ADVANCE_NOTICE_OPERATE_TYPE.ADVANCE_NOTICE_FETCH_REWARD, self.info.id)
		end
		local desc_list = Split(info.open_dec, "#")
		local desc = ""

		if self.can_reward then
			desc = Language.Common.LingQuJiangLi
		elseif#desc_list == 1 then
			desc = info.open_dec
		else
			desc = desc_list[1]..desc_list[2]
		end
		self.open_desc:SetValue(desc)

-- 		if self.can_reward and not self.had_open  and MainUIView.Instance:GetActiveState() then
-- --			TipsCtrl.Instance:OpenFunTrailerTip(self.info)
-- 			self.had_open = true
-- 		end

	else
		self.root_node:SetActive(false)
	end


end

function MainUIFunctiontrailer:TrailerClick()
	if self.info then
		TipsCtrl.Instance:OpenFunTrailerTip(self.info)
	end
end

function MainUIFunctiontrailer:SetSpecialModle(modle_id)
	local display_name = "trailer_view"
	local id = tonumber(modle_id)
	for k,v in pairs(DISPLAYNAME) do
		if id == k then
			display_name = v
			break
		end
	end
	return display_name
end

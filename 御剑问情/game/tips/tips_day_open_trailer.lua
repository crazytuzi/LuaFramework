TipsDayOpenTrailerView = TipsDayOpenTrailerView or BaseClass(BaseView)

function TipsDayOpenTrailerView:__init()
	self.ui_config = {"uis/views/tips/funtrailer_prefab", "DayFunTrailerTips"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
end

function TipsDayOpenTrailerView:__delete()
end

function TipsDayOpenTrailerView:ReleaseCallBack()
	-- 清理变量和对象
	self.btn_text = nil
	self.reward_count = nil
	self.icon = nil
	self.des = nil
	self.show_display = nil
	self.model_can_rotate = nil

	for _, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
end

function TipsDayOpenTrailerView:LoadCallBack()
	self.model = RoleModel.New()
	self.model:SetDisplay(self:FindObj("Display").ui3d_display)

	self.btn_text = self:FindVariable("BtnText")
	self.reward_count = self:FindVariable("RewardCount")
	self.icon = self:FindVariable("Icon")
	self.des = self:FindVariable("Des")
	self.show_display = self:FindVariable("ShowDisplay")
	self.model_can_rotate = self:FindVariable("ModelCanRotate")					--模型是否可旋转

	self:ListenEvent("Click", BindTool.Bind(self.Click, self))
	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
	
	self.item_list = {}
	local item_cell = nil
	for i = 1, 3 do
		item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self:FindObj("Item" .. i))
		table.insert(self.item_list, item_cell)
	end
end

function TipsDayOpenTrailerView:OpenCallBack()
	self:Flush()
end

function TipsDayOpenTrailerView:CloseCallBack()

end

function TipsDayOpenTrailerView:Click()
	if self.can_reawrd then
		local trailer_info = OpenFunData.Instance:GetNowDayOpenTrailerInfo()
		if nil ~= trailer_info then
			OpenFunData.Instance:SetIsWaitDayRewardChange(true)
			--领取奖励
			OpenFunCtrl.Instance:SendAdvanceNoitceOperate(ADVANCE_NOTICE_OPERATE_TYPE.ADVANCE_NOTICE_DAY_FETCH_REWARD, trailer_info.id)
		end
	else
		self:Close()
	end
end

function TipsDayOpenTrailerView:CloseWindow()
	self:Close()
end

function TipsDayOpenTrailerView:SetModel(info)
	local res_type = info.res_type
	local res_show = info.res_show
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()

	self.model:ResetRotation()
	self.model:ClearModel()
	self.model_can_rotate:SetValue(true)
	self.model:SetPanelName("day_open_trailer_normal")

	if res_type == "huobanfz" then					--伙伴法阵
		local goddress_info = GoddessData.Instance:GetXianNvCfg(main_role_vo.use_xiannv_id)
		if nil ~= goddress_info then
			self.model:SetGoddessResid(goddress_info.resid)
			self.model:SetGoddessWingResid(res_show)
		end

	elseif res_type == "foot" then
		local info = {}
		info.prof = main_role_vo.prof
		info.sex = main_role_vo.sex
		info.appearance = {}
		info.appearance.fashion_body = main_role_vo.appearance.fashion_body

		self.model:SetModelResInfo(info)
		self.model:SetFootResid(res_show)
		self.model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
		self.model:SetPanelName("day_open_trailer_foot")

	elseif res_type == "fight_mount" then
		local bundle, asset = ResPath.GetFightMountModel(res_show)
		self.model:SetMainAsset(bundle, asset)
		self.model:SetPanelName("day_open_trailer_fight_mount")

	elseif res_type == "multi_mount" then
		local bundle, asset = ResPath.GetMountModel(res_show)
		self.model:SetMainAsset(bundle, asset)
		self.model:SetPanelName("day_open_trailer_multi_mount")

	elseif res_type == "shenbing" then
		self.model_can_rotate:SetValue(false)
		local bundle, asset = ResPath.GetHunQiModel(res_show)
		self.model:SetMainAsset(bundle, asset)
		self.model:SetPanelName("day_open_trailer_shenbing")
		
	elseif res_type == "halo" then
		local info = {}
		info.prof = main_role_vo.prof
		info.sex = main_role_vo.sex
		info.appearance = {}
		info.appearance.fashion_body = main_role_vo.appearance.fashion_body
		info.appearance.halo_used_imageid = res_show

		self.model:SetModelResInfo(info)

	elseif res_type == "yaoshi" then
		local info = {}
		info.prof = main_role_vo.prof
		info.sex = main_role_vo.sex
		info.appearance = {}
		info.appearance.fashion_body = main_role_vo.appearance.fashion_body

		self.model:SetModelResInfo(info)
		self.model:SetWaistResid(res_show)

	elseif res_type == "toushi" then
		local info = {}
		info.prof = main_role_vo.prof
		info.sex = main_role_vo.sex
		info.appearance = {}
		info.appearance.fashion_body = main_role_vo.appearance.fashion_body

		self.model:SetModelResInfo(info)
		self.model:SetTouShiResid(res_show)

	elseif res_type == "mask" then
		local info = {}
		info.prof = main_role_vo.prof
		info.sex = main_role_vo.sex
		info.appearance = {}
		info.appearance.fashion_body = main_role_vo.appearance.fashion_body

		self.model:SetModelResInfo(info)
		self.model:SetMaskResid(res_show)

	elseif res_type == "lingzhu" then
		self.model_can_rotate:SetValue(false)
		self.model:SetPanelName("day_open_trailer_lingzhu")
		local bundle, asset = ResPath.GetLingZhuModel(res_show, true)
		self.model:SetMainAsset(bundle, asset)

	elseif res_type == "xianbao" then
		self.model_can_rotate:SetValue(false)
		local bundle, asset = ResPath.GetXianBaoModel(res_show)
		self.model:SetMainAsset(bundle, asset)

	elseif res_type == "qilinbi" then
		--直接用女的资源目录
		local bundle, asset = ResPath.GetQilinBiModel(res_show, 0)
		self.model:SetMainAsset(bundle, asset)
		self.model:SetPanelName("day_open_trailer_qilinbi")
	end
end

function TipsDayOpenTrailerView:OnFlush()
	local trailer_info = OpenFunData.Instance:GetNowDayOpenTrailerInfo()
	if nil == trailer_info then
		return
	end

	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()

	--判断是否可以领取奖励
	self.can_reawrd = false
	if open_server_day == trailer_info.open_day and main_role_vo.level >= trailer_info.level_limit then
		self.can_reawrd = true
	end

	local btn_des = self.can_reawrd and Language.Common.UnLockDes or Language.Common.TomorrowDes
	self.btn_text:SetValue(btn_des)

	--奖励展示
	local reward_count = 0
	local item_cell = nil
	for k, v in pairs(trailer_info.reward_item) do
		reward_count = reward_count + 1

		item_cell = self.item_list[k + 1]
		if item_cell then
			item_cell:SetData(v)
		end
	end
	self.reward_count:SetValue(reward_count)

	--描述
	self.des:SetValue(trailer_info.fun_dec)

	--设置图标
	if trailer_info.res_icon ~= "" then
		local bundle, asset = ResPath.GetMainUI(trailer_info.res_icon)
		self.icon:SetAsset(bundle, asset)
	end

	--设置模型
	if trailer_info.is_model == 1 then
		self.show_display:SetValue(true)
		self:SetModel(trailer_info)
	else
		self.show_display:SetValue(false)
	end
end
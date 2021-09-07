require("game/national_warfare/yunbiao_view")
require("game/national_warfare/yingjiu_view")
require("game/national_warfare/dachen_view")
require("game/national_warfare/guoqi_view")
require("game/national_warfare/citan_view")
require("game/national_warfare/banzhuan_view")
require("game/national_warfare/camp_qiyun_view")

NationalWarfareView = NationalWarfareView or BaseClass(BaseView)

function NationalWarfareView:__init()
	self.ui_config = {"uis/views/nationalwarfareview","NationalWarfareView"}
	self:SetMaskBg()
	self.def_index = TabIndex.national_warfare_rescue
	self.camp_index = 1

	self.toggle = {}
	self.toggle_list = {}

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function NationalWarfareView:__delete()

end

function NationalWarfareView:ReleaseCallBack()
	self.show_yunbiao_times = nil
	self.yunbiao_times = nil
	self.show_yingjiu_times = nil
	self.yingjiu_times = nil
	self.show_citan_times = nil
	self.citan_times = nil
	self.show_banzhuan_times = nil
	self.banzhuan_times = nil
	self.show_yunbiao_word = nil
	self.show_banzhuan_word = nil
	self.show_camp_role_num = nil
	self.show_camp_title_image = nil
	self.national_warfare_role_camp = nil
	
	self.toggle = {}
	self.toggle_list = {}
	self.role_num = {}
	self.exp_radio = {}
	self.camp_name = {}
	self.camp_obj = {}
	self.camp_obj_pos = {}

	if self.yunbiao_view then
		self.yunbiao_view:DeleteMe()
		self.yunbiao_view = nil
	end

	if self.yingjiu_view then
		self.yingjiu_view:DeleteMe()
		self.yingjiu_view = nil
	end

	if self.dachen_view then
		self.dachen_view:DeleteMe()
		self.dachen_view = nil
	end

	if self.guoqi_view then
		self.guoqi_view:DeleteMe()
		self.guoqi_view = nil
	end

	if self.citan_view then
		self.citan_view:DeleteMe()
		self.citan_view = nil
	end

	if self.banzhuan_view then
		self.banzhuan_view:DeleteMe()
		self.banzhuan_view = nil
	end

	if self.qiyun_view then
		self.qiyun_view:DeleteMe()
		self.qiyun_view = nil
	end
	if self.money then
		self.money:DeleteMe()
		self.money = nil
	end

	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.NationalWarfare)
	end

	self.red_point_list = nil
	
	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end
end

function NationalWarfareView:LoadCallBack()
	self.show_yunbiao_word = self:FindVariable("show_yunbiao_word")
	self.show_banzhuan_word = self:FindVariable("show_banzhuan_word")
	self.show_camp_role_num = self:FindVariable("show_camp_role_num")
	self.show_camp_title_image = self:FindVariable("show_camp_title_image")

	self.yunbiao_times = self:FindVariable("YunBiaoTimes")
	self.yingjiu_times = self:FindVariable("YingJiuTimes")
	self.citan_times = self:FindVariable("CiTanTimes")
	self.banzhuan_times = self:FindVariable("BanZhuanTimes")

	self.red_point_list = {
		[RemindName.CampWarYingJiu] = self:FindVariable("ShowYingJiuTimes"),
		[RemindName.CampWarCiTan] = self:FindVariable("ShowCiTanTimes"),
		[RemindName.CampWarBanzhuang] = self:FindVariable("ShowBanZhuanTimes"),
		[RemindName.CampWarYunBiao] = self:FindVariable("ShowYunBiaoTimes"),
		[RemindName.CampWarQiYun] = self:FindVariable("ShowQiYunRp"),
		[RemindName.CampWarDaChen] = self:FindVariable("ShowDaChenRp"),
		[RemindName.CampWarGuoQi] = self:FindVariable("ShowGuoQiRp"),
	}

	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end

	self.money = MoneyBar.New()
	self.money:SetInstanceParent(self:FindObj("MoneyBar"))

	-- 监听UI事件
	self:ListenEvent("close_view", BindTool.Bind(self.HandleClose, self))
	-- self:ListenEvent("OnClickCampZhongLi", BindTool.Bind(self.OnClickCampZhongLi, self))
	self:ListenEvent("OnClickHelpTip", BindTool.Bind(self.OnClickHelpTip, self))

	self.role_num = {}
	self.exp_radio = {}
	for i = 1, CAMP_TYPE.CAMP_TYPE_MAX - 1 do
		self.role_num[i] = self:FindVariable("role_num"..i)
		self.exp_radio[i] = self:FindVariable("ExpRadio"..i)
	end
	for i = 1, 5 do
		self:ListenEvent("OnClickCamp" .. i, BindTool.Bind(self.OnClickCamp, self, i))
	end


	self.camp_name = {}
	self.camp_obj = {}
	self.camp_obj_pos = {}
	for i = 1, CAMP_TYPE.CAMP_TYPE_MAX - 1 do
		self.camp_name[i] = self:FindVariable("camp_name_" .. i)
		-- self.camp_obj[i] = self:FindObj("camp_" .. i)
		-- self.camp_obj_pos[i] = self.camp_obj[i].transform.localPosition
	end

	for i = 1, 5 do
		self.camp_obj[i] = self:FindObj("camp_" .. i)
		self.camp_obj_pos[i] = self.camp_obj[i].transform.localPosition
	end
	self.camp_zhongli_pos = self:FindObj("camp_zhongli").transform.localPosition
	NationalWarfareData.Instance:SetCampObjPos(self.camp_obj_pos)

	self.toggle = {}
	for i = 1, 7 do
		self.toggle[i] = self:FindObj("toggle_".. i)
	end

	self.toggle[1].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.national_warfare_rescue))
	self.toggle[2].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.national_warfare_spy))
	self.toggle[3].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.national_warfare_brick))
	self.toggle[4].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.national_warfare_dart))
	self.toggle[5].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.national_warfare_luck))
	self.toggle[6].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.national_warfare_minister))
	self.toggle[7].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.national_warfare_flag))

	self.toggle_list = {
		[TabIndex.national_warfare_rescue] = self.toggle[1].toggle,
		[TabIndex.national_warfare_spy] = self.toggle[2].toggle,
		[TabIndex.national_warfare_brick] = self.toggle[3].toggle,
		[TabIndex.national_warfare_dart] = self.toggle[4].toggle,
		[TabIndex.national_warfare_luck] = self.toggle[5].toggle,
		[TabIndex.national_warfare_minister] = self.toggle[6].toggle,
		[TabIndex.national_warfare_flag] = self.toggle[7].toggle,
	}

	-- 子面板
	self.yunbiao_view = YunBiaoView.New()
	local yunbiao_content = self:FindObj("YunBiaoContent")
	yunbiao_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.national_warfare_dart
		self.yunbiao_view:SetInstance(obj)
	end)

	self.yingjiu_view = YingJiuView.New()
	local yingjiu_content = self:FindObj("YingJiuContent")
	yingjiu_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.national_warfare_rescue
		self.yingjiu_view:SetInstance(obj)
	end)

	self.dachen_view = DaChenView.New()
	local dachen_content = self:FindObj("DaChenContent")
	dachen_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.national_warfare_minister
		self.dachen_view:SetInstance(obj)
	end)

	self.guoqi_view = GuoQiView.New()
	local guoqi_content = self:FindObj("GuoQiContent")
	guoqi_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.national_warfare_flag
		self.guoqi_view:SetInstance(obj)
	end)

	self.citan_view = CiTanView.New()
	local citan_content = self:FindObj("CiTanContent")
	citan_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.national_warfare_spy
		self.citan_view:SetInstance(obj)
	end)

	self.banzhuan_view = BanZhuanView.New()
	local banzhuan_content = self:FindObj("BanZhuanContent")
	banzhuan_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.national_warfare_brick
		self.banzhuan_view:SetInstance(obj)
	end)

	-- 气运
	self.qiyun_view = CampQiYunView.New()
	local qiyun_content = self:FindObj("QiYunContent")
	qiyun_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.show_index = TabIndex.national_warfare_luck
		self.qiyun_view:SetInstance(obj)
	end)
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.NationalWarfare, BindTool.Bind(self.GetUiCallBack, self))

	self:Flush()
end

function NationalWarfareView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function NationalWarfareView:OnFlush(param_list)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	for i = 1, 3 do
		local camp = i == vo.camp and 1 or 2
		local bundle, asset = ResPath.GetNationalWarfare("camp_name_" .. i .. "_" .. camp)
		self.camp_name[i]:SetAsset(bundle, asset)
	end
	-- local bundle, asset = ResPath.GetNationalWarfare(self.act_id)
	-- self.activity_bg:SetAsset(bundle, asset)
	self:FlushNum()

	self.show_yunbiao_word:SetValue(CampData.Instance:GetCampYunbiaoIsOpen() or ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.HUSONG))

	for k, v in pairs(param_list) do
		if k == "all" then
			if self.show_index == TabIndex.national_warfare_dart then
				if self.yunbiao_view then
					self.yunbiao_view:Flush()
				end
			elseif self.show_index == TabIndex.national_warfare_rescue then
				if self.yingjiu_view then
					self.yingjiu_view:Flush()
				end
			elseif self.show_index == TabIndex.national_warfare_minister then
				if self.dachen_view then
					self.dachen_view:Flush()
				end
			elseif self.show_index == TabIndex.national_warfare_flag then
				if self.guoqi_view then
					self.guoqi_view:Flush()
				end
			elseif self.show_index == TabIndex.national_warfare_spy then
				if self.citan_view then
					self.citan_view:Flush()
				end
			elseif self.show_index == TabIndex.national_warfare_brick then
				if self.banzhuan_view then
					self.banzhuan_view:Flush()
				end
			elseif self.show_index == TabIndex.national_warfare_luck then
				if self.qiyun_view then
					self.qiyun_view:Flush()
				end
			end
		elseif k == "flush_yunbiao_view" then
			if self.yunbiao_view then
				self.yunbiao_view:Flush(v)
			end
		elseif k == "flush_yunbiao_info_view" then
			if self.yunbiao_view then
				self.yunbiao_view:FlushYunBiaoInfo()
			end
		elseif k == "flush_yingjiu_view" then
			if self.yingjiu_view then
				self.yingjiu_view:Flush(v)
			end
		elseif k == "flush_dachen_view" then
			if self.dachen_view then
				self.dachen_view:Flush(v)
			end
		elseif k == "flush_guoqi_view" then
			if self.guoqi_view then
				self.guoqi_view:Flush(v)
			end
		elseif k == "flush_citian_view" then
			if self.citan_view then
				self.citan_view:Flush(v)
			end
		elseif k == "flush_banzhuan_view" then
			if self.banzhuan_view then
				self.banzhuan_view:Flush(v)
			end
		elseif k == "flush_qiyun_view" then
			if self.qiyun_view then
				self.qiyun_view:Flush(v)
			end
		elseif k == "change_to_index" then
			self:ChangeToIndex(v.index or self.def_index)
		end
	end
end

function NationalWarfareView:OnToggleChange(index, ison)
	if ison then
		self:ChangeToIndex(index)

		if index == TabIndex.national_warfare_luck then
			ClickOnceRemindList[RemindName.CampWarQiYun] = 0
			RemindManager.Instance:CreateIntervalRemindTimer(RemindName.CampWarQiYun)
		end
	end
end

function NationalWarfareView:ShowBanZhuanWord()
	local is_open = NationalWarfareData.Instance:GetCampBanZhuanIsOpen()
	if self.show_banzhuan_word then
		self.show_banzhuan_word:SetValue(is_open)
	end
end

function NationalWarfareView:ShowIndexCallBack(index)
	self.toggle_index = index % 6200 + 1
	self.show_camp_role_num:SetValue(not self.toggle[self.toggle_index].toggle.isOn)
	self.toggle_list[index].isOn = true
	self:Flush()
end

function NationalWarfareView:OpenCallBack()
	RemindManager.Instance:Fire(RemindName.CampWarYingJiu)
	RemindManager.Instance:Fire(RemindName.CampWarCiTan)
	CampCtrl.Instance:SendCampWarCommonOpera(CAMP_WAR_OPERA_TYPE.OPERA_TYPE_QUERY_QIYUN_STATUS)
	CampCtrl.Instance:SendCampWarCommonOpera(CAMP_WAR_OPERA_TYPE.OPERA_TYPE_GET_YUNBIAO_USERS, 0)
	self.show_camp_role_num:SetValue(false)
	self:ShowBanZhuanWord()
	self:ShowOrHideTab()
end

function NationalWarfareView:CloseCallBack()
	
end
	
function NationalWarfareView:FlushNum()
	--运镖标签数字
	local yunbiao_times = YunbiaoData.Instance:GetHusongRemainTimes()
	self.yunbiao_times:SetValue(yunbiao_times)

	--营救标签数字
	local accept_times, buy_times, max_accept_times = NationalWarfareData.GetYingJiuTimes()
	self.yingjiu_times:SetValue(max_accept_times + buy_times - accept_times)

	--刺探标签数字
	local citan_count = NationalWarfareData.Instance:GetCampCitanDayCount()
	self.citan_times:SetValue(citan_count)

	--搬砖标签数字
	local banzhuan_count = NationalWarfareData.Instance:GetCampBanzhuanDayCount()
	self.banzhuan_times:SetValue(banzhuan_count)
end
-----------------------阵营点击事件
function NationalWarfareView:OnClickCamp(index)
	self.camp_index = index
	local camp_scene_id = ConfigManager.Instance:GetAutoConfig("campconfg_auto").other
	NationalWarfareCtrl.Instance.SendSceneRoleCountReq(camp_scene_id[1]["scene_id_"..index],0)
	self.show_camp_role_num:SetValue(index == index)
	local bundle, asset = ResPath.GetCampIcon(index)
	self.show_camp_title_image:SetAsset(bundle, asset)
	if index == 4 then
		if self.show_index == TabIndex.national_warfare_dart then
			local can_yunbiao = YunbiaoData.Instance:GetIsHuShong()
			if can_yunbiao then
				local task_id = YunbiaoData.Instance:GetTaskIdByCamp()
				if task_id then
					TaskCtrl.Instance:DoTask(task_id)
					self:HandleClose()
				end
			end
		else
		end
	end
end

function NationalWarfareView:FlashCampRoleNum()
	local scene_role = NationalWarfareData.Instance:GetCurSceneCampRoleCount()
	if scene_role and next(scene_role) then
		for i=1, CAMP_TYPE.CAMP_TYPE_MAX - 1 do
			self.role_num[i]:SetValue(scene_role[i][i + 1])
			self.exp_radio[i]:SetValue(scene_role[i][i + 1]/100)
		end
	end
end

-----------------------------------
-- 关闭事件
function NationalWarfareView:HandleClose()
	ViewManager.Instance:Close(ViewName.NationalWarfare)
end

function NationalWarfareView:OnClickCampZhongLi()
	if self.show_index == TabIndex.national_warfare_dart then
		local can_yunbiao = YunbiaoData.Instance:GetIsHuShong()
		if can_yunbiao then
			local task_id = YunbiaoData.Instance:GetTaskIdByCamp()
			if task_id then
				TaskCtrl.Instance:DoTask(task_id)
				self:HandleClose()
			end
		end
	else
	end
end

function NationalWarfareView:OnClickHelpTip()
	if nil == self.toggle_index then
		self.toggle_index = 180
		TipsCtrl.Instance:ShowHelpTipView(self.toggle_index)
	else
		TipsCtrl.Instance:ShowHelpTipView(179 + self.toggle_index)
	end
	
end

function NationalWarfareView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.Tab then
		local index = TabIndex[ui_param]
		if index == self.show_index then
			return NextGuideStepFlag
		end
		if index == TabIndex.national_warfare_spy then
			if self.toggle[2].gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnToggleChange, self, TabIndex.national_warfare_spy)
				return self.toggle[2], callback
			end
		end
	elseif ui_name == GuideUIName.NationalWarfareRoleCamp then
		if self.yingjiu_view then
			return self.yingjiu_view:GetStartTaskBtn()
		end
	elseif ui_name == GuideUIName.NationalWarfareCitan then
		if self.citan_view then
			return self.citan_view:GetStartTaskBtn()
		end
	end
end

function NationalWarfareView:ShowOrHideTab()
	if not self:IsOpen() then return end
	local open_fun_data = OpenFunData.Instance
	self.toggle[1]:SetActive(open_fun_data:CheckIsHide("national_warfare_rescue"))
	self.toggle[2]:SetActive(open_fun_data:CheckIsHide("national_warfare_spy"))
	self.toggle[3]:SetActive(open_fun_data:CheckIsHide("national_warfare_brick"))
	self.toggle[4]:SetActive(open_fun_data:CheckIsHide("national_warfare_dart"))
	self.toggle[5]:SetActive(open_fun_data:CheckIsHide("national_warfare_luck"))
	self.toggle[6]:SetActive(open_fun_data:CheckIsHide("national_warfare_minister"))
	self.toggle[7]:SetActive(open_fun_data:CheckIsHide("national_warfare_flag"))	
end


CampInfoView = CampInfoView or BaseClass(BaseRender)

local CampName = {"齐", "楚", "魏"}

function CampInfoView:__init()
	self.role_king_id = 1				-- 国王位置是1
	self.role_display = {}
	self.role_model = {}
	self.is_model = {}
	self.model_name = {}
	self.is_name = {}
end

function CampInfoView:__delete()
	self.role_display = {}
	self.is_model = {}
	self.model_name = {}
	self.is_name = {}

	for k,v in pairs(self.role_model) do
		v:DeleteMe()
	end
	self.role_model = {}

	if self.role_info_callback then
		GlobalEventSystem:UnBind(self.role_info_callback)
		self.role_info_callback = nil
	end

	self.edit_text = nil
	self.label_camp = nil
	self.label_wangzu = nil
	self.label_fuhuo_num = nil
	self.label_guojia_notice = nil
	self.is_open_notice = nil
	self.res_role_state = nil
	if self.remind_change  then
	   RemindManager.Instance:UnBind(self.remind_change)
	   self.remind_change = nil
	end
	self.alliance_name = nil
end


function CampInfoView:LoadCallBack(instance)
	self.role_info_callback = GlobalEventSystem:Bind(OtherEventType.RoleInfo, BindTool.Bind(self.RoleInfoCallBack, self))
	self.edit_text = self:FindObj("EditText")

	-- 监听UI事件
	self:ListenEvent("OnBtnEditNotice", BindTool.Bind(self.OnBtnEditNoticeHandler, self))
	self:ListenEvent("OnBtnCheckRule", BindTool.Bind(self.OnBtnCheckRuleHandler, self))
	self:ListenEvent("OnBtnAffairs", BindTool.Bind(self.OnBtnAffairsHandler, self))
	self:ListenEvent("OnCloseNotice", BindTool.Bind(self.OnCloseNoticeHandler, self))
	self:ListenEvent("OnPublishNotice", BindTool.Bind(self.OnPublishNoticeHandler, self))
	self:ListenEvent("OnClickAlterCountryName", BindTool.Bind(self.OnAlterCountryNameHandler, self))

	for i = 1, GameEnum.CAMP_POST_UNIQUE_TYPE_COUNT do
		self:ListenEvent("OnClickRoleModel" .. i, BindTool.Bind(self.OnClickRoleModelHandler, self, i))
	end

	for i = 1, GameEnum.CAMP_POST_UNIQUE_TYPE_COUNT do
		self.role_display[i] = self:FindObj("Display" .. i)
		self.is_model[i] = self:FindVariable("IsModel" .. i)
		self.model_name[i] = self:FindVariable("ModelName" .. i)
		self.is_name[i] = self:FindVariable("IsName"..i)
	end

	-- 获取变量
	self.label_camp = self:FindVariable("LabelCamp")
	self.label_wangzu = self:FindVariable("LabelWangzu")
	self.label_fuhuo_num = self:FindVariable("LabelFuhuoNum")
	self.label_guojia_notice = self:FindVariable("LabelGuojiaNotice")
	self.is_open_notice = self:FindVariable("IsOpenNotice")
	self.is_can_redact = self:FindVariable("IsCanRedact")
	self.label_change_issue = self:FindVariable("ChangeIssue")
	self.is_but_redshow = self:FindVariable("IsButRedShow")
	self.res_role_state = self:FindVariable("RoleState")
	self.alliance_name = self:FindVariable("alliance_name")

	-- 初始化人物模型
	self:InitRoleModel()
	self:Flush()

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.CampInfo)
end

function CampInfoView:OnFlush(param_list)
	local camp_info = CampData.Instance:GetCampInfo()
	self.label_camp:SetValue(CampData.Instance:GetCampNameByCampType(camp_info.my_camp_type, false, false, true))
	self.alliance_name:SetValue(Language.Alliance[camp_info.alliance_camp])

	if camp_info.king_guild_name ~= "" then
		self.label_wangzu:SetValue(camp_info.king_guild_name)
	else
		self.label_wangzu:SetValue(Language.Common.No)
	end
	self.label_fuhuo_num:SetValue(camp_info.reborn_dan_num or Language.Common.No)
	

	self.label_guojia_notice:SetValue(camp_info.notice)

	local bundle, asset = ResPath.GetCampRes("lbl_state_2")
	local my_role_id = PlayerData.Instance.role_vo.role_id
	for k, v in pairs(camp_info.officer_list) do
		if v.role_id > 0 then
			CheckCtrl.Instance:SendQueryRoleInfoReq(v.role_id)
			if k == self.role_king_id and my_role_id == v.role_id then
				bundle, asset = ResPath.GetCampRes("lbl_state_3")
			end
		end
		self.is_model[k]:SetValue(v.role_id > 0)
		self.model_name[k]:SetValue(v.name or "")
	end
	self.res_role_state:SetAsset(bundle, asset)

	self:IsPlayNameShow()
end
--Camp面板是否显示对应官员的名字
function CampInfoView:IsPlayNameShow()
	local camp_info = CampData.Instance:GetCampInfo()
	for k,v in pairs(self.is_name) do 
		v:SetValue(camp_info.officer_list[k].role_id > 0)
	end
end

-- 初始化人物模型处理函数
function CampInfoView:InitRoleModel()
	for i = 1, GameEnum.CAMP_POST_UNIQUE_TYPE_COUNT do
		if not self.role_model[i] and self.role_display[i] then
			self.role_model[i] = RoleModel.New()
			self.role_model[i]:SetDisplay(self.role_display[i].ui3d_display)
		end
	end
end

function CampInfoView:RoleInfoCallBack(role_id, protocol)
	local camp_info = CampData.Instance:GetCampInfo()
	for k, v in pairs(camp_info.officer_list) do
		if v.role_id == role_id and self.role_model[k] then
			local cfg_pos = CampData.Instance:GetRoleModelPos(protocol.prof)
			self.role_model[k]:SetTransform(cfg_pos)
			self.role_model[k]:SetModelResInfo(protocol, false, true, false, false, true)
		end
	end
end

-- 点击官职
function CampInfoView:OnClickRoleModelHandler(i)
	local camp_info = CampData.Instance:GetCampInfo()
	local officer_list = camp_info.officer_list
	local my_name = PlayerData.Instance.role_vo.name

	local is_click = true
	if i == self.role_king_id then
		is_click = officer_list[self.role_king_id].name ~= my_name
	end
	if officer_list[i] and officer_list[i].name ~= "" and is_click then			-- 点击人物弹出信息
		if officer_list[self.role_king_id].name == my_name then
			ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.CampKing, officer_list[i].name)
		else
			ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.Default, officer_list[i].name)
		end

	elseif officer_list[i] and officer_list[i].name == "" and officer_list[self.role_king_id].name == my_name then		-- 点击人物任命
		CampData.Instance:SetAppointCampPost(i)
		ViewManager.Instance:Open(ViewName.CampAppoint)
	end
end

-- 打开修改公告面板
function CampInfoView:OnBtnEditNoticeHandler()
	local myguanzi = GameVoManager.Instance:GetMainRoleVo().camp_post
	if myguanzi == 1 then
		self.is_can_redact:SetValue(true)
		self.label_change_issue:SetValue(Language.Common.FaBu)
	else
		self.is_can_redact:SetValue(false)
		self.label_change_issue:SetValue(Language.Common.GuanBi)
	end
	self.is_open_notice:SetValue(true)
	local camp_info = CampData.Instance:GetCampInfo()
	self.edit_text.input_field.text = camp_info.notice

end

-- 关闭修改公告面板
function CampInfoView:OnCloseNoticeHandler()
	self.is_open_notice:SetValue(false)
end

-- 编辑公告
function CampInfoView:OnPublishNoticeHandler()
	if self.edit_text.input_field.text == "" then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.ContentNotNull)
		return
	end

	CampCtrl.Instance:SendCampPublishNotice(self.edit_text.input_field.text)
	self.is_open_notice:SetValue(false)
end

-- 查看规则
function CampInfoView:OnBtnCheckRuleHandler()
	-- 查看规则Tips
	TipsCtrl.Instance:ShowHelpTipView(170)
end

-- 打开内政面板
function CampInfoView:OnBtnAffairsHandler()
	ViewManager.Instance:Open(ViewName.CampAffairs)
end

-- 打开改国号面板
function CampInfoView:OnAlterCountryNameHandler()
	local callback = function (new_name)
		-- for k, v in pairs(CampName) do
		-- 	if new_name == v then
		-- 		SysMsgCtrl.Instance:ErrorRemind(Language.Camp.CanNotChangeName)
		-- 		return
		-- 	end
		-- end
		for k, v in pairs(CampData.Instance:GetCampNameList()) do
			if new_name == v then
				SysMsgCtrl.Instance:ErrorRemind(Language.Camp.CanNotChangeName)
				return
			end
		end

		CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_CHANGE_CAMP_NAME , 0, 0, 0, new_name)
	end 
	local camp_info = CampData.Instance:GetCampInfo()
	local camp_name = CampData.Instance:GetCampNameByCampType(camp_info.my_camp_type, false, false, true)
	local need_money = CampData.Instance:GetCampOtherCfg().change_name_need_gold
	CampCtrl.Instance:ShowAlterCountryName(callback, nil, camp_name, need_money)
end

function CampInfoView:RemindChangeCallBack(remind_name, num)
	self.is_but_redshow:SetValue(num > 0)
end
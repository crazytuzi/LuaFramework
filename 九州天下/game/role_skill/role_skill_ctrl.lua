require("game/role_skill/role_skill_data")
require("game/role_skill/role_skill_view")
require("game/role_skill/shenji_skill_view")
RoleSkillCtrl = RoleSkillCtrl or BaseClass(BaseController)
local FLOATING_X = 400
local FLOATING_Y = -50
function RoleSkillCtrl:__init()
	if RoleSkillCtrl.Instance then
		print_error("[RoleSkillCtrl] Attemp to create a singleton twice !")
	end
	RoleSkillCtrl.Instance = self

	self.data = RoleSkillData.New()
	self.view = RoleSkillView.New(ViewName.RoleSkillView)
	self.shenji_view = ShenJiSkillView.New(ViewName.ShenJiSkillView)
	self:RegisterAllProtocols()
	self.default_attr_list = {0, 0, 0}
	RemindManager.Instance:Register(RemindName.RoleTeamSkill, BindTool.Bind(self.CheckTeamSkillUpItem, self))
end

function RoleSkillCtrl:__delete()
	self.data:DeleteMe()
	self.view:DeleteMe()

	if self.shenji_view ~= nil then
		self.shenji_view:DeleteMe()
		self.shenji_view = nil
	end

	if self.floating_view then
		self.floating_view:DeleteMe()
		self.floating_view = nil 
	end
	RoleSkillCtrl.Instance = nil
	self.default_attr_list = nil
	RemindManager.Instance:UnRegister(RemindName.RoleTalent)
	RemindManager.Instance:UnRegister(RemindName.RoleTeamSkill)
end

function RoleSkillCtrl:GetView()
	return self.view
end

function RoleSkillCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCTalentSystemInfo, "OnTalentSystemInfo")
	self:RegisterProtocol(SCTeamSkillInfo, "OnTeamSkillInfo")

	--神级技能
	self:RegisterProtocol(CSShenjiSkillFetchRewardReq)
	self:RegisterProtocol(SCShenjiSkillInfo, "OnSCShenjiSkillInfo")

	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
end

function RoleSkillCtrl:OnTalentSystemInfo(protocol)
	self.data:SetRoleTalentData(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.RoleTalent)
end

function RoleSkillCtrl:SendTalentSystemOperateReq(type, page_index, talent_attr_list)
	local protocol = ProtocolPool.Instance:GetProtocol(CSTalentSystemOperateReq)
	protocol.type = type
	protocol.page_index = page_index or 0
	protocol.talent_attr_list = talent_attr_list or self.default_attr_list
	protocol:EncodeAndSend()
end

function RoleSkillCtrl:MainuiOpenCreate()
	--self:SendTalentSystemOperateReq(TALENT_SYSTEM_REQ_TYPE.TALENT_SYSTEM_REQ_TYPE_GET_INFO)
	RemindManager.Instance:Register(RemindName.RoleTalent, BindTool.Bind(self.CheckRoleTalentRedPoint, self))
end

function RoleSkillCtrl:CheckRoleTalentRedPoint()
	return self.data:CheckRoleTalentRedPoint()
end

function RoleSkillCtrl:OnTeamSkillUpGradeResult(result)
	if result == 1 then
		self.view:TeamSkillAutoUpGrade()
	else 
		self.view:StopTeamSkillUpGrade()
	end
	if self.view:IsOpen() then
		self:ShowFloatingTips()
	end
end

function RoleSkillCtrl:OnTeamSkillInfo(protocol)
	self.data:SetTeamSkillInfo(protocol)
	if protocol.reason == TEAM_SKILL_INFO_SC_TYPE.TEAM_SKILL_INFO_SC_TYPE_ADDEXP then
		self.view:Flush("add_exp")
	else
		self.view:Flush()
	end

	MainUICtrl.Instance:FlushView("check_team_skill")
	if self.view:IsOpen() then
		self:ShowFloatingTips()
	end
end

function RoleSkillCtrl:SendTeamSkillOperateReq(opera_type, param_1, param_2, param_3)
	local protocol = ProtocolPool.Instance:GetProtocol(CSTeamSkillOperaReq)
	protocol.opera_type = opera_type or 0
	protocol.param_1 = param_1 or 0
	protocol.param_2 = param_2 or 0
	protocol.param_3 = param_3 or 0
	protocol:EncodeAndSend()
end

function RoleSkillCtrl:CheckTeamSkillUpItem()
	for i = 1,TEAM_SKILL.TOTLE_NUM do
		local flag = RoleSkillData.Instance:IsShowTeamSkillRedPoint(i)
		if flag then
			return 1
		end
	end
	return 0
	-- local cfg = RoleSkillData.Instance:GetTeamSkillClientList()
	-- local other_cfg = RoleSkillData.Instance:GetTeamSkillOtherInfo()
	-- local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	-- for k,v in pairs(cfg) do
	-- 	local own_coin = main_role_vo.coin
	-- 	if ItemData.Instance:GetItemNumIsEnough(other_cfg.uplevel_skill_stuff_id, 1) and own_coin > other_cfg.uplevel_skill_need_coin then
	-- 		return 1
	-- 	end
	-- end
	-- return 0
end

function RoleSkillCtrl:ShowFloatingTips()
	local last_bless = self.data:GetLastBless()
	local last_grade = self.data:GetLastGrade()
	local info_list = self.data:SetLastInfo()
	local exp_bao = self.data:GetOtherByStr("c_exp_bao") or 0
	local cur_bless = info_list.exp or 0
	local cur_grade = info_list.level or 0
	local msg = "+" .. (cur_bless - last_bless)
	local color_msg = ToColorStr(msg, TEXT_COLOR.GREEN)

	if last_grade ~= cur_grade then
		--升阶提示
		TipsCtrl.Instance:ShowFloatingLabel(nil, 250, 30, false, true, ResPath.GetFloatTextRes("WordUpgradeSuccess"))
		-- return
	else
		local add_exp = cur_bless - last_bless
		if add_exp >= exp_bao then
			TipsCtrl.Instance:ShowFloatingLabel(nil, 250, 30, false, true, ResPath.GetFloatTextRes("WordBaojiUpgrade"))		
		end

		if add_exp > 0 then
			self.floating_view = TipsFloatingView.New()
			self.floating_view:Show(color_msg, FLOATING_X, FLOATING_Y, nil, nil, nil, nil, true)
		end
	end
	--if cur_bless <= last_bless then return end
end



function RoleSkillCtrl:SendShenJiSkillReq(req_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSShenjiSkillFetchRewardReq)
	protocol.req_type = req_type or 0
	protocol.param_1 = 0
	protocol:EncodeAndSend()
end

function RoleSkillCtrl:OnSCShenjiSkillInfo(protocol)
	self.data:SetShenJiSkillInfo(protocol)
	if OpenFunData.Instance:CheckIsHide("nationalwarfare") then
		MainUICtrl.Instance:SetButtonVisible(MainUIData.RemindingName.ShenJiSkill, protocol.has_fatch_reward == 0)
		RemindManager.Instance:Fire(RemindName.ShenJiSkill)
	end

	if self.shenji_view ~= nil and self.shenji_view:IsOpen() then
		self.shenji_view:Flush()
	end
end

function RoleSkillCtrl:OpenShenJIView()
	if self.shenji_view ~= nil then
		self.shenji_view:Open()
	end
end
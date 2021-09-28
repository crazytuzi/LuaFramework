require("game/baoju/achieve/achieve_data")
require("game/tips/tips_achievement_view")

AchieveCtrl = AchieveCtrl or BaseClass(BaseController)

function AchieveCtrl:__init()
	if AchieveCtrl.Instance then
		print_error("[AchieveCtrl] 尝试创建第二个单例模式")
		return
	end
	AchieveCtrl.Instance = self

	self.data = AchieveData.New()
	self.view = nil

	self.tips_achieve_list = {}

	self:RegisterAllProtocols()
end

function AchieveCtrl:__delete()
	self.data:DeleteMe()
	self.data = nil

	AchieveCtrl.Instance = nil

	for k,v in pairs(self.tips_achieve_list) do
		if v then
			v:DeleteMe()
		end
	end
end

function AchieveCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCChengJiuInfo, "OnAchieveInfo")
	self:RegisterProtocol(SCChengJiuRewardChange, "OnAchieveRewardChange")
	self:RegisterProtocol(SCChengJiuTitleViewChange, "OnAchieveTitleViewChange")
	self:RegisterProtocol(SCChengJiuRewardInfo, "OnChengJiuRewardInfo")

	self:RegisterProtocol(CSChengJiuOpera)

	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
end

-- 向服务器申请成就信息同步
function AchieveCtrl:MainuiOpenCreate()
	self:SendReqAchieveInfo()
end

--成就信息同步
function AchieveCtrl:OnAchieveInfo(protocol)
	self.data:OnAchieveInfo(protocol)

	if self.view ~= nil and self.view.root_node.gameObject.activeSelf then
		self.view:FlushView()
	end
	RemindManager.Instance:Fire(RemindName.Achieve_Overview)
	RemindManager.Instance:Fire(RemindName.Achieve_Title)
end

--成就奖励改变时主动通知
function AchieveCtrl:OnAchieveRewardChange(protocol)
	self.data:OnAchieveRewardChange(protocol)

	if self.view ~= nil and self.view.root_node.gameObject.activeSelf then
		self.view:FlushView()
	end
	RemindManager.Instance:Fire(RemindName.Achieve_Overview)
	RemindManager.Instance:Fire(RemindName.Achieve_Title)
end

-- 成就改变信息
function AchieveCtrl:OnChengJiuRewardInfo(protocol)
	self.data:SetChengJiuRewardInfo(protocol)
	-- local tips_achievement_view = TipsAchievementView.New()
	-- table.insert(self.tips_achieve_list,tips_achievement_view)
	-- tips_achievement_view:SetData(protocol)
	-- tips_achievement_view:Open()
	-- tips_achievement_view:Flush()
end

-- 成就操作请求
function AchieveCtrl:SendAchieveOpera(opera_type, param1)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSChengJiuOpera)
	send_protocol.opera_type= opera_type
	send_protocol.param1 = param1 or 0
	send_protocol:EncodeAndSend()
end

-- 请求成就信息（可仅在第一次打开面板时请求）
function AchieveCtrl:SendReqAchieveInfo()
	self:SendAchieveOpera(CHENGJIU_OPER_TYPE.CHENGJIU_REQ_INFO)
end

-- 称号升级
function AchieveCtrl:SendTitleUpGrade()
	self:SendAchieveOpera(CHENGJIU_OPER_TYPE.CHENGJIU_OPER_TITLE_UPLEVEL)
end

-- 领取奖励
function AchieveCtrl:SendFetchReward(reward_id)
	self:SendAchieveOpera(CHENGJIU_OPER_TYPE.CHENGJIU_OPER_FETCH_REWARD, reward_id)
end

--场景中角色称号等级改变
function AchieveCtrl:OnAchieveTitleViewChange(protocol)
	if self.view ~= nil then
		self.view.title_view:UpdateTitle()
	end

	local role = Scene.Instance:GetObj(protocol.obj_id)
	if role ~= nil and role.ReloadUIName ~= nil then
		role:SetAttr("chengjiu_title_level", protocol.title_level)
		role:ReloadUIName()
	end

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo.obj_id == protocol.obj_id then
		self.data:SetTitleLevel(protocol.title_level)
	end
end
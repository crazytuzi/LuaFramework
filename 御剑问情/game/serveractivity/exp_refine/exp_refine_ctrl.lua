require("game/serveractivity/exp_refine/exp_refine_data")
require("game/serveractivity/exp_refine/exp_refine_view")

ExpRefineCtrl = ExpRefineCtrl or BaseClass(BaseController)

function ExpRefineCtrl:__init()
	if ExpRefineCtrl.Instance then
		print_error("[ExpRefineCtrl]:Attempt to create singleton twice!")
	end
	ExpRefineCtrl.Instance = self

	self.view = ExpRefineView.New(ViewName.ExpRefine)
	self.data = ExpRefineData.New()

	self:RegisterAllProtocols()

	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpenCreate, self))
end

function ExpRefineCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	ExpRefineCtrl.Instance = nil
end

function ExpRefineCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAExpRefineInfo, "OnRAExpRefineInfo")

	self:RegisterProtocol(CSRAExpRefineReq)
end

function ExpRefineCtrl:MainuiOpenCreate()
	self:SendRAExpRefineReq(RA_EXP_REFINE_OPERA_TYPE.RA_EXP_REFINE_OPERA_TYPE_GET_INFO)
end

--经验炼制请求
function ExpRefineCtrl:SendRAExpRefineReq(opera_type)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSRAExpRefineReq)
	send_protocol.opera_type = opera_type or 0
	send_protocol:EncodeAndSend()
end

function ExpRefineCtrl:OnRAExpRefineInfo(protocol)
	self.data:SetRAExpRefineInfo(protocol)
	self.view:Flush()

	MainUICtrl.Instance:SetButtonVisible(MainUIData.RemindingName.ExpRefine, self.data:GetExpRefineBtnIsShow())
	RemindManager.Instance:Fire(RemindName.ExpRefine)
end

-- -- 经验炼制
-- RA_EXP_REFINE_OPERA_TYPE = {
-- 	RA_EXP_REFINE_OPERA_TYPE_BUY_EXP = 0,					-- 炼制
-- 	RA_EXP_REFINE_OPERA_TYPE_FETCH_REWARD_GOLD = 1,			-- 领取炼制红包
-- 	RA_EXP_REFINE_OPERA_TYPE_GET_INFO = 2,					-- 获取信息
-- }

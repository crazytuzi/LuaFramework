require("scripts/game/strength_fb/strengthfb_view")
require("scripts/game/strength_fb/strengthfb_data")
require("scripts/game/strength_fb/strengthfb_tips")
--require("scripts/game/strength_fb/strengthfb_guide_view")
require("scripts/game/strength_fb/strengthfb_falied_view")
require("scripts/game/strength_fb/strengthfb_success_view")
require("scripts/game/strength_fb/strengthfb_desc_tips")

-- 勇者闯关
StrenfthFbCtrl = StrenfthFbCtrl or BaseClass(BaseController)

function StrenfthFbCtrl:__init()
	if StrenfthFbCtrl.Instance ~= nil then
		ErrorLog("[StrenfthFbCtrl] attempt to create singleton twice!")
		return
	end
	StrenfthFbCtrl.Instance = self

	self.view = StrenfthFbView.New(ViewName.StrenfthFb)
	self.data = StrenfthFbData.New()

	self.failed_tip = FailedTip.New(ViewName.StrenfthFbFailedTip)
	self.eh_load_quit = GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind1(self.OnSceneLoadingQuite, self))
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind1(self.OnReqAllData, self))
	self:RegisterAllProtocols()
	self:RegisterAllEvents()
end

function StrenfthFbCtrl:__delete()
	if nil ~= self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	if nil ~= self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if nil ~= self.chest_tips then
		self.chest_tips:DeleteMe()
		self.chest_tips = nil
	end

	if nil ~= self.eh_load_quit then
		GlobalEventSystem:UnBind(self.eh_load_quit)
		self.eh_load_quit = nil
	end

	if self.strengthfb_enter_tips ~= nil then
		self.strengthfb_enter_tips:DeleteMe()
		self.strengthfb_enter_tips = nil
	end

	if self.sucess_tip ~= nil then
		self.sucess_tip:DeleteMe()
		self.sucess_tip = nil 
	end

	if self.failed_tip ~= nil then
		self.failed_tip:DeleteMe()
		self.failed_tip = nil 
	end

	if self.reward_tip ~= nil then
		self.reward_tip:DeleteMe()
		self.reward_tip = nil 
	end

	StrenfthFbCtrl.Instance = nil
end

function StrenfthFbCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCReturnFubenData, "OnReturnFubenData")
	self:RegisterProtocol(SCFuBenEnd, "OnFuBenEnd")
	self:RegisterProtocol(SCSweepFubenIss, "OnSweepFubenIss")
end

function StrenfthFbCtrl:RegisterAllEvents()
	
end

function StrenfthFbCtrl:OnSceneLoadingQuite()

end

function StrenfthFbCtrl:OpenView(page, level, data)
	if self.strengthfb_enter_tips == nil then
		self.strengthfb_enter_tips = StrengthfbEnterTips.New()
	end

	self.strengthfb_enter_tips:SetData(page, level, data)
	self.strengthfb_enter_tips:Open()
end

function StrenfthFbCtrl:OpenShowRewardView(page, star)
	if self.reward_tip == nil then 
		self.reward_tip = StrengthfbRewardTips.New()
	end
	self.reward_tip:SetData(page, star)
	self.reward_tip:Open()
end

function StrenfthFbCtrl:CloseTip()
	if self.reward_tip then
		if self.reward_tip:IsOpen() then
			self.reward_tip:Close()
		end
	end
end

function StrenfthFbCtrl:OnFuBenEnd(protocol)
	self.data:SetFubenEndData(protocol)
	self.view:Flush()
	if protocol.bool_sucess == 1 then
		if self.sucess_tip == nil then
			self.sucess_tip = SuccessTip.New()
		end
		self.sucess_tip:SetData(protocol.fuben_page, protocol.fuben_pos, protocol.tongguan_star)
		self.sucess_tip:Open()
	else
		if self.failed_tip == nil then
			self.failed_tip = FailedTip.New(ViewName.StrenfthFbFailedTip)
		end
		self.failed_tip:Open()
	end 
end

-- 扫荡副本下发
function StrenfthFbCtrl:OnSweepFubenIss(protocol)
	self.data:SetSweepFuben(protocol)
	self.view:Flush()
	if protocol.sweep_sucess == 1 then
		if self.sucess_tip == nil then
			self.sucess_tip = SuccessTip.New()
		end
		self.sucess_tip:SetData(protocol.sweep_chapter, protocol.sweep_shut, 3, protocol.sweep_time)
		self.sucess_tip:Open()
	end
end

function StrenfthFbCtrl:OnReturnFubenData(protocol)
	self.data:SetfuBenData(protocol)
	self.view:Flush()
end

function StrenfthFbCtrl:OnFuBenPanel(protocol)
	self.data:SetFuBenPanelData(protocol)
	FubenCtrl.Instance:SetTaskFollow()
end

--请求副本数据
function StrenfthFbCtrl:SendFubenData(fuben_page)
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqFuBenData)
	protocol.fuben_page = fuben_page
	protocol:EncodeAndSend()
end

--请求进入副本
function StrenfthFbCtrl:ReqEnterFuben(fuben_page, fuben_pos)
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqEnterFuben)
	protocol.fuben_page = fuben_page
	protocol.fuben_pos = fuben_pos
	protocol:EncodeAndSend()
end

-- 扫荡副本
function StrenfthFbCtrl:ReqSweepFuben(fuben_chapter, fuben_num, sweep_num)
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqSweepFuben)
	protocol.fuben_chapter = fuben_chapter
	protocol.fuben_num = fuben_num
	protocol.sweep_num = sweep_num
	protocol:EncodeAndSend()
end

--领取累计星级奖励
function StrenfthFbCtrl:GetFubenStarReWard(fuben_page, reward_index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetFubenStarReWard)
	protocol.fuben_page = fuben_page
	protocol.reward_index = reward_index
	protocol:EncodeAndSend()
end

function StrenfthFbCtrl:OnReqAllData()
	for i = 1, STRENFTHFB_MAX_GRADE do
		self:SendFubenData(i)
	end
end

function StrenfthFbCtrl:GetFubenReWard(times)
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqGetStrengthFbRward)
	protocol.times = times
	protocol:EncodeAndSend()
end
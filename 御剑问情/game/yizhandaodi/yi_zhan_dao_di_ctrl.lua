require("game/yizhandaodi/yi_zhan_dao_di_data")
require("game/yizhandaodi/yi_zhan_dao_di_view")

YiZhanDaoDiCtrl = YiZhanDaoDiCtrl or BaseClass(BaseController)

function YiZhanDaoDiCtrl:__init()
	if YiZhanDaoDiCtrl.Instance ~= nil then
		print_error("[YiZhanDaoDiCtrl] attempt to create singleton twice!")
		return
	end
	YiZhanDaoDiCtrl.Instance = self
	self:RegisterAllProtocols()
	self.view = YiZhanDaoDiView.New(ViewName.YiZhanDaoDiView)
	self.data = YiZhanDaoDiData.New()
end

function YiZhanDaoDiCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	YiZhanDaoDiCtrl.Instance = nil
end

function YiZhanDaoDiCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCYiZhanDaoDiRankInfo, "OnYiZhanDaoDiRankInfo")				-- 排行榜信息
	self:RegisterProtocol(SCYiZhanDaoDiTitleChange, "OnYiZhanDaoDiTitleChangeInfo")		-- 称号改变
	self:RegisterProtocol(SCYiZhanDaoDiLuckyInfo, "OnYiZhanDaoDiLuckyInfo")				-- 幸运玩家信息
	self:RegisterProtocol(SCYiZhanDaoDiKickout, "OnYiZhanDaoDiKickoutInfo")				-- 踢出信息
	self:RegisterProtocol(SCYiZhanDaoDiUserInfo, "OnYiZhanDaoDiUserInfo")				-- 主角信息
	self:RegisterProtocol(SCYiZhanDaoDiLastFirstInfo, "OnYiZhanDaoDiLastFirstInfo")		-- 活动上一次第一名玩家信息
end

function YiZhanDaoDiCtrl:OnYiZhanDaoDiRankInfo(protocol)
	self.data:SetYiZhanDaoDiRankInfo(protocol)

	self.view:Flush()
end

function YiZhanDaoDiCtrl:OnYiZhanDaoDiTitleChangeInfo(protocol)
	self.data:SetYiZhanDaoDiTitleChangeInfo(protocol)

	self:UpdateTitle()
end

function YiZhanDaoDiCtrl:OnYiZhanDaoDiLuckyInfo(protocol)
	self.data:SetYiZhanDaoDiLuckyInfo(protocol)

	FuBenCtrl.Instance:FlushFbIconView("yizhandaodi_info")
end

function YiZhanDaoDiCtrl:OnYiZhanDaoDiKickoutInfo(protocol)
	self.data:SetYiZhanDaoDiKickoutInfo(protocol)
end

function YiZhanDaoDiCtrl:OnYiZhanDaoDiLastFirstInfo(protocol)
	self.data:SetYiZhanDaoDiLastFirstInfo(protocol)
end

function YiZhanDaoDiCtrl:OnYiZhanDaoDiUserInfo(protocol)
	self.data:SetYiZhanDaoDiUserInfo(protocol)

	self.view:Flush()

	GlobalEventSystem:Fire(ObjectEventType.FIGHT_EFFECT_CHANGE)

	local buy_tip_view = TipsCtrl.Instance:GetInSprieFuBenView()
	if nil ~= buy_tip_view and buy_tip_view:IsOpen() then
		buy_tip_view:Flush()
	end
end

-- 购买BUFF请求
function YiZhanDaoDiCtrl:SendYiZhanDaoDiGuwuReq(guwu_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSYiZhanDaoDiGuwu)
	protocol.guwu_type = guwu_type or 0
	protocol:EncodeAndSend()
end

-- 更新称号
function YiZhanDaoDiCtrl:UpdateTitle()
	local title_change_info = self.data:GetYiZhanDaoDiTitleChangeInfo()
	local role_obj = Scene.Instance:GetRoleByObjId(title_change_info.obj_id)
	if nil == role_obj then
		return
	end

	local vo = role_obj:GetVo()
	vo.used_title_list = vo.used_title_list or {}
	vo.used_title_list[1] = tonumber(title_change_info.title_id)
	role_obj:SetAttr("used_title_list", vo.used_title_list)
end
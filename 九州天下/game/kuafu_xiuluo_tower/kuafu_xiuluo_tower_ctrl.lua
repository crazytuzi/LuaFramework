require("game/kuafu_xiuluo_tower/kuafu_xiuluo_tower_data")
require("game/kuafu_xiuluo_tower/kuafu_xiuluo_tower_fuben_info_view")
require("game/kuafu_xiuluo_tower/kuafu_xiuluo_tower_rank_list")
require("game/kuafu_xiuluo_tower/kuafu_xiuluo_tower_buy_view")

KuaFuXiuLuoTowerCtrl = KuaFuXiuLuoTowerCtrl or BaseClass(BaseController)

function KuaFuXiuLuoTowerCtrl:__init()
	if nil ~= KuaFuXiuLuoTowerCtrl.Instance then
		print_error("[KuaFuXiuLuoTowerCtrl] attempt to create singleton twice!")
		return
	end
	KuaFuXiuLuoTowerCtrl.Instance = self
	self.data = KuaFuXiuLuoTowerData.New()
	self.buy_view = KuaFuXiuLuoTowerBuyView.New(ViewName.FuXiuLuoTowerBuffView)
	self.fuben_info_view = KuaFuXiuLuoTowerFuBenInfoView.New()
	self:RegisterAllProtocols()
end

function KuaFuXiuLuoTowerCtrl:__delete()
	if nil ~= self.buy_view then
		self.buy_view:DeleteMe()
		self.buy_view = nil
	end
	if nil ~= self.fuben_info_view then
		self.fuben_info_view:DeleteMe()
		self.fuben_info_view = nil
	end
	if nil ~= self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	KuaFuXiuLuoTowerCtrl.Instance = nil
end

-- 注册协议
function KuaFuXiuLuoTowerCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCCrossXiuluoTowerSelfActivityInfo, "OnXiuLuoSelfInfo")
	self:RegisterProtocol(SCCrossXiuluoTowerRankInfo, "OnXiuLuoRankInfo")
	self:RegisterProtocol(SCCrossXiuluoTowerChangeLayerNotice, "OnXiuLuoLayerChange")
	self:RegisterProtocol(SCCrossXiuluoTowerUserResult, "OnXiuLuoUserResult")
	self:RegisterProtocol(SCCrossXiuluoTowerInfo, "OnXiuLuoInfo")
	self:RegisterProtocol(SCCrossXiuluoTowerBuffInfo, "OnXiuLuoBuffInfo")
	self:RegisterProtocol(SCCrossXiuluoTowerGatherInfo, "OnCrossXiuluoTowerGatherInfo")
end

--发送进入修罗塔副本
function KuaFuXiuLuoTowerCtrl:SendEnterXiuLuoTowerFuBen()
	CrossServerCtrl.Instance:SendCrossStartReq(ACTIVITY_TYPE.KF_XIULUO_TOWER)
end

--跨服修罗塔个人活动信息
function KuaFuXiuLuoTowerCtrl:OnXiuLuoSelfInfo(protocol)
	self.data:OnXiuLuoSelfInfo(protocol)
	self.fuben_info_view:OnSelfInfoChange()
end

--跨服修罗塔排行榜信息
function KuaFuXiuLuoTowerCtrl:OnXiuLuoRankInfo(protocol)
	self.data:SetRankList(protocol)
	self.fuben_info_view:FlushRank()
end

--跨服修罗塔改变层提示
function KuaFuXiuLuoTowerCtrl:OnXiuLuoLayerChange(protocol)
	self.fuben_info_view:OnLayerChange(protocol)
end

--跨服修罗塔属性加成
function KuaFuXiuLuoTowerCtrl:OnXiuLuoInfo(protocol)
	self.data:SetAttrInfo(protocol)
	self.buy_view:Flush()
end

--跨服修罗塔BUFF信息
function KuaFuXiuLuoTowerCtrl:OnXiuLuoBuffInfo(protocol)
	self.data:SetBuffInfo(protocol)
end

--跨服修罗塔结果
function KuaFuXiuLuoTowerCtrl:OnXiuLuoUserResult(protocol)
	local reward_cfg = KuaFuXiuLuoTowerData.Instance:GetReward()
	if reward_cfg and reward_cfg.reward_item then
		local temp_list = {reward_list = {}}
		for k,v in pairs(reward_cfg.reward_item) do
			if v and v.item_id > 0 then
				table.insert(temp_list.reward_list, v)
			end
		end
		TipsCtrl.Instance:OpenActivityRewardTip(temp_list)
	end
end
local inx = 0
--请求积分奖励
function KuaFuXiuLuoTowerCtrl:SendGetScoreReward()
	local can_get, result = KuaFuXiuLuoTowerData.Instance:GetCanGetReward()
	if can_get then
		local protocol = ProtocolPool.Instance:GetProtocol(CSCrossXiuluoTowerScoreRewardReq)
		-- protocol.index = result
		protocol.index = inx
		inx = inx + 1
		if inx > 5 then
			inx = 0
		end
		protocol:EncodeAndSend()
	else
		if result == 0 then
			--积分不足
			TipsCtrl.Instance:ShowSystemMsg(Language.XiuLuo.NotEnoughScore)
		elseif result == 1 then
			--已领取全部
			TipsCtrl.Instance:ShowSystemMsg(Language.XiuLuo.HaveGotAll)
		end
	end
end

-- 跨服修罗塔购买buff
function KuaFuXiuLuoTowerCtrl:SendCrossXiuluoTowerBuyBuff(is_buy_realive_count, is_use_gold_bind)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCrossXiuluoTowerBuyBuff)
	send_protocol.is_buy_realive_count = is_buy_realive_count
	send_protocol.is_use_gold_bind = is_use_gold_bind
	send_protocol:EncodeAndSend()
end

function KuaFuXiuLuoTowerCtrl:OpenFubenView()
	if self.fuben_info_view then
		self.fuben_info_view:Open()
	end
end

function KuaFuXiuLuoTowerCtrl:CloseFubenView()
	if self.fuben_info_view then
		self.fuben_info_view:Close()
	end
end

function KuaFuXiuLuoTowerCtrl:OnCrossXiuluoTowerGatherInfo(protocol)
	self.data:SetGatherInfo(protocol)
	if self.fuben_info_view then
		self.fuben_info_view:Flush()
	end
end
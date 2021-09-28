require("game/festivalactivity/festival_activity_happy_ernie/autumn_activity_panel_happy_ernie_view")
require("game/festivalactivity/festival_activity_happy_ernie/autumn_activity_panel_happy_ernie_data")
FestivalHappyErnieActivityCtrl = FestivalHappyErnieActivityCtrl or BaseClass(BaseController)
function FestivalHappyErnieActivityCtrl:__init()
	if nil ~= FestivalHappyErnieActivityCtrl.Instance then
		return
	end

	FestivalHappyErnieActivityCtrl.Instance = self

	self.autumn_huanleyao_data = AutumnHappyErnieData.New()

	self:RegisterAllProtocols()
end

function FestivalHappyErnieActivityCtrl:__delete()
	FestivalHappyErnieActivityCtrl.Instance = nil

    if self.autumn_huanleyao_data then
    	self.autumn_huanleyao_data:DeleteMe()
    end
end

function FestivalHappyErnieActivityCtrl:RegisterAllProtocols()
 --    --中秋连续充值
	-- self:RegisterProtocol(SCRAVersionContinueChongzhiInfo, "OnRAContinueChongzhiInfoZhongQiu")
    --中秋祈福
	self:RegisterProtocol(SCRAHuanLeYaoJiangTwoInfo, "OnSCRAMiJingXunBaoTwoInfo")
	self:RegisterProtocol(SCRAHuanLeYaoJiangTaoResultTwoInfo, "OnSCRAHappyErnieTaoResultTwoInfo")
end

-- ----------------中秋连续充值协议-----------
-- function FestivalHappyErnieActivityCtrl:OnRAContinueChongzhiInfoZhongQiu(protocol)
-- 	self.data:SetChongZhiZhongQiu(protocol)
-- 	FestivalActivityCtrl.Instance:FlushView("lianxuchongzhi")
-- 	RemindManager.Instance:Fire(RemindName.ZhongQiuLianXuChongZhi)
-- end

--------------中秋摇一摇---------------
function FestivalHappyErnieActivityCtrl:OnSCRAMiJingXunBaoTwoInfo(protocol)
	local server_time = TimeCtrl.Instance:GetServerTime()
	self.autumn_huanleyao_data:SetRAHappyErnieInfo(protocol)							-- 服务器下发协议
	FestivalActivityCtrl.Instance:FlushView("autumnhappyerniebiew")
	RemindManager.Instance:Fire(RemindName.ZhongQiuHappyErnieRemind)				-- 红点
	if server_time < protocol.ra_huanleyaojiang_next_free_tao_timestamp then
		RemindManager.Instance:AddNextRemindTime(RemindName.ZhongQiuHappyErnieRemind,protocol.ra_huanleyaojiang_next_free_tao_timestamp - server_time)
	end
end

function FestivalHappyErnieActivityCtrl:OnSCRAHappyErnieTaoResultTwoInfo(protocol)
	self.autumn_huanleyao_data:SetRAHappyErnieTaoResultInfo(protocol)												-- 服务器下发协议
	TipsCtrl.Instance:ShowTreasureView(self.autumn_huanleyao_data:GetChestShopMode())					-- 显示寻宝奖励界面
	FestivalActivityCtrl.Instance:FlushView("autumnhappyerniebiew")
	RemindManager.Instance:Fire(RemindName.ZhongQiuHappyErnieRemind)				-- 红点		
end


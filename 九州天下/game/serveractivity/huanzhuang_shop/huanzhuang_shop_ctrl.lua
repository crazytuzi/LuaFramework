require("game/serveractivity/huanzhuang_shop/huanzhuang_shop_view")
require("game/serveractivity/huanzhuang_shop/huanzhuang_shop_data")

HuanzhuangShopCtrl = HuanzhuangShopCtrl or BaseClass(BaseController)
function HuanzhuangShopCtrl:__init()
	if HuanzhuangShopCtrl.Instance then
		print_error("[HuanzhuangShopCtrl] Attemp to create a singleton twice !")
	end
	HuanzhuangShopCtrl.Instance = self

	self.huan_zhuang_shop_data = HuanzhuangShopData.New()
	self.huan_zhuang_shop_view = HuanzhuangShopView.New(ViewName.HuanZhuangShopView)

	self:RegisterAllProtocols()
	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
end

function HuanzhuangShopCtrl:__delete()
	HuanzhuangShopCtrl.Instance = nil

	if self.huan_zhuang_shop_view then
		self.huan_zhuang_shop_view:DeleteMe()
		self.huan_zhuang_shop_view = nil
	end

	if self.huan_zhuang_shop_data then
		self.huan_zhuang_shop_data:DeleteMe()
		self.huan_zhuang_shop_data = nil
	end

	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end
end

function HuanzhuangShopCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAMagicShopAllInfo, "OnSCRAMagicShopAllInfo")
end

function HuanzhuangShopCtrl:OnSCRAMagicShopAllInfo(protocol)
	self.huan_zhuang_shop_data:SetRAMagicShopAllInfo(protocol)
	RemindManager.Instance:Fire(RemindName.ShowHuanZhuangShopPoint)
	if self.huan_zhuang_shop_view then
		self.huan_zhuang_shop_view:Flush("FlsuhData")
	end

	local magic_shop_buy_flag = bit:d2b(self.huan_zhuang_shop_data:GetRAMagicShopAllInfo().magic_shop_buy_flag)
	local cfg = self.huan_zhuang_shop_data:GetHuanZhuangShopRewardCfgByShowType(HuanzhuangShopData.OPERATE.BUY)
	for k,v in ipairs(cfg) do
		if 0 == magic_shop_buy_flag[33 - k] and HuanzhuangShopData.Instance:GetLoginFlag() then
			break
		end
	end
end

function HuanzhuangShopCtrl:ActivityCallBack(activity_type, status)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAGIC_SHOP then
		MainUICtrl.Instance:ChangeHuanZhuangShopBtn(status == ACTIVITY_STATUS.OPEN and GameVoManager.Instance:GetMainRoleVo().level >= 130)
		if status == ACTIVITY_STATUS.OPEN then
			KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAGIC_SHOP, RA_KING_DRAW_OPERA_TYPE.RA_KING_DRAW_OPERA_TYPE_QUERY_INFO)
		end
	end 
end
require("game/exchange/exchange_data")
require("game/exchange/exchange_view")
require("game/exchange/exchange_tips_view")
ExchangeCtrl = ExchangeCtrl or BaseClass(BaseController)
function ExchangeCtrl:__init()
	if ExchangeCtrl.Instance then
		print_error("[ExchangeCtrl] Attemp to create a singleton twice !")
	end
	ExchangeCtrl.Instance = self
	self.data = ExchangeData.New()
	self.view = ExchangeView.New(ViewName.Exchange)
	self.tips_view = ExchangeTipView.New(ViewName.ExchangeTip)
	self:RegisterAllProtocols()
	self.score_change_callback_list = {}
end

function ExchangeCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	if self.tips_view then
		self.tips_view:DeleteMe()
		self.tips_view = nil
	end
	self.score_change_callback_list = {}
	ExchangeCtrl.Instance = nil
end

function ExchangeCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCSendScoreInfo,"OnScoreInfo")
	self:RegisterProtocol(SCSendScoreInfoNotice,"OnScoreNotice")
	self:RegisterProtocol(SCConvertRecordInfo, "OnConvertRecordInfo")
end

function ExchangeCtrl:GetExchangeContentView()
	self.view:GetExchangeContentView()
end

--请求购买物品
--function ExchangeCtrl:SendCSShopBuy(item_id, item_num, is_bind, is_use, reserve_ch1, reserve_ch2)
--	local protocol = ProtocolPool.Instance:GetProtocol(CSShopBuy)
--	protocol.scoretoitem_type = conver_type
--	protocol.item_id = item_id or 0
--	protocol.item_num = item_num or 0
--	protocol.is_bind = is_bind or 0
--	protocol.is_use = is_use or 0
--	protocol.reserve_ch1 = reserve_ch1 or 0
--	protocol.reserve_ch2 = reserve_ch2 or 0
--	protocol:EncodeAndSend()
--end

function ExchangeCtrl:SendCSShopBuy(item_id, item_num, is_bind, is_use, reserve_ch1, reserve_ch2, is_limit)
	local protocol = ProtocolPool.Instance:GetProtocol(CSShopBuy)
	protocol.scoretoitem_type = conver_type
	protocol.item_id = item_id or 0
	protocol.item_num = item_num or 0
	protocol.is_bind = is_bind or 0
	protocol.is_use = is_use or 0
	protocol.reserve_ch1 = reserve_ch1 or 0
	protocol.reserve_ch2 = reserve_ch2 or 0
	protocol.is_limit = is_limit or 0
	protocol:EncodeAndSend()
end

function ExchangeCtrl:OnConvertRecordInfo(protocol)
	local old_count = self.data:GetLifeTimeRecordCount()
	self.data:OnConvertRecordInfo(protocol)
	local new_count = self.data:GetLifeTimeRecordCount()
	local treasure_view = TreasureCtrl.Instance:GetView()
	if self.view:IsOpen() then
		local exchange_content_view = self.view:GetExchangeContentView()
		if exchange_content_view then
			if new_count > old_count then
				exchange_content_view:OnFlushListView()
			else
				exchange_content_view:FlushAllFrame()
			end
		end
	end
	if self.tips_view:IsOpen() and self.tips_view:IsLoaded() then
		self.tips_view:Flush()
	end
	if treasure_view:IsOpen() then
		--if treasure_view:GetShowIndex() == TabIndex.treasure_choujiang then
		--	local treasure_exchange_view = TreasureCtrl.Instance:GetTreasureExchangeView()
		--	if treasure_exchange_view then
		--		treasure_exchange_view:FlushAllCell()
		--	end
		--end
		treasure_view:Flush("exchange")
	end
end

function ExchangeCtrl:OnScoreInfo(protocol)
	self.data:OnScoreInfo(protocol)
	TreasureData.Instance:SetTreasureScore(protocol.chest_shop_treasure_credit)
	
	if self.tips_view:IsOpen() and self.tips_view:IsLoaded() then
		self.tips_view:Flush()
	end
	local treasure_view = TreasureCtrl.Instance:GetView()
	if treasure_view:IsOpen() then
		treasure_view:Flush("exchange")
	end

	self:DoNotify()
	-- 精灵积分
	SpiritData.Instance:SetSpiritExchangeScore(protocol.chest_shop_jingling_credit)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.Forge)

	-- 国家气运面板
	CampCtrl.Instance:Flush("flush_camp_fate_view")
end

function ExchangeCtrl:OnScoreNotice(protocol)
	local msg = ""
	if protocol.chest_shop_mojing > 0 then
		msg = string.format(Language.SysRemind.AddMoJing, protocol.chest_shop_mojing)
	elseif protocol.chest_shop_shengwang > 0 then
		msg = string.format(Language.SysRemind.AddShengWang, protocol.chest_shop_shengwang)
	elseif protocol.chest_shop_gongxun > 0 then
		msg = string.format(Language.SysRemind.AddGongxun, protocol.chest_shop_gongxun)
	elseif protocol.chest_shop_weiwang > 0 then
		msg = string.format(Language.SysRemind.AddWeiWang, protocol.chest_shop_weiwang)
	elseif protocol.chest_shop_treasure_credit > 0 then
		msg = string.format(Language.SysRemind.AddTreasure, protocol.chest_shop_treasure_credit)
	elseif protocol.chest_shop_jingling_credit > 0 then
		msg = string.format(Language.SysRemind.AddJingLing, protocol.chest_shop_jingling_credit)
	elseif protocol.chest_shop_happytree_grow > 0 then
		msg = string.format(Language.SysRemind.AddHappyTree, protocol.chest_shop_happytree_grow)
	elseif protocol.chest_shop_guojiaqiyun > 0 then
		msg = string.format(Language.SysRemind.AddFate, protocol.chest_shop_guojiaqiyun)
	elseif protocol.chest_shop_dailyscore > 0 then
		msg = string.format(Language.SysRemind.AddDailyScore, protocol.chest_shop_dailyscore)
	elseif protocol.chest_shop_cross_guildbattle_score > 0 then
		msg = string.format(Language.SysRemind.AddBattleScore, protocol.chest_shop_cross_guildbattle_score)
	elseif protocol.chest_shop_server_gold > 0 then
		msg = string.format(Language.SysRemind.AddGoldIngot, protocol.chest_shop_server_gold)
	end
	if msg ~= "" then 
		TipsCtrl.Instance:ShowFloatingLabel(msg)
	end
end

--消耗积分兑换物品请求
function ExchangeCtrl:SendScoreToItemConvertReq(conver_type, seq, num)
	local protocol = ProtocolPool.Instance:GetProtocol(CSScoreToItemConvert)
	protocol.scoretoitem_type = conver_type
	protocol.index = seq
	protocol.num = num
	protocol:EncodeAndSend()
end

--兑换记录信息请求
function ExchangeCtrl:SendGetConvertRecordInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetConvertRecordInfo)
	protocol:EncodeAndSend()
end

--获取积分数量请求
function ExchangeCtrl:SendGetSocreInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetSocreInfoReq)
	protocol:EncodeAndSend()
end

--注册积分改变回调
function ExchangeCtrl:NotifyWhenScoreChange(callback)
	self.score_change_callback_list[callback] = callback
end

--取消积分改变回调
function ExchangeCtrl:UnNotifyWhenScoreChange(callback)
	self.score_change_callback_list[callback] = nil
end

--积分改变回调
function ExchangeCtrl:DoNotify()
	for k,v in pairs(self.score_change_callback_list) do
		v()
	end
end

function ExchangeCtrl:ShowExchangeView(item_id, price_type, conver_type, close_call_back, cur_multile_price, multiple_time, is_max_multiple, click_func)
	self.tips_view:SetItemId(item_id, price_type, conver_type, close_call_back, cur_multile_price, multiple_time, is_max_multiple, click_func)
	self.tips_view:Open()
end

function ExchangeCtrl:GetToggleIndex()
	local tab_index = self.view:GetToggleIndex()
	if tab_index then
		return tab_index
	end
end
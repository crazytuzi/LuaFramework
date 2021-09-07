require("game/symbol/symbol_view")
require("game/symbol/symbol_data")
require("game/symbol/symbol_select_tips_view")

SymbolCtrl = SymbolCtrl or  BaseClass(BaseController)

function SymbolCtrl:__init()
	if SymbolCtrl.Instance ~= nil then
		ErrorLog("[SymbolCtrl] attempt to create singleton twice!")
		return
	end
	SymbolCtrl.Instance = self

	self:RegisterAllProtocols()

	self.data = SymbolData.New()
	self.view = SymbolView.New(ViewName.SymbolView)
	self.symbol_select_tips_view = SymbolSelectTipsView.New()

	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
end

function SymbolCtrl:__delete()
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
	self.item_data_event = nil

	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.symbol_select_tips_view ~= nil then
		self.symbol_select_tips_view:DeleteMe()
		self.symbol_select_tips_view = nil
	end

	SymbolCtrl.Instance = nil
end

function SymbolCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCElementHeartInfo, "OnElementHeartInfo")
	self:RegisterProtocol(SCElementShopInfo, "OnElementShopInfo")
	self:RegisterProtocol(SCElementTextureInfo, "OnElementTextureInfo")
	self:RegisterProtocol(SCCharmGhostSingleCharmInfo, "OnCharmGhostSingleCharmInfo")
	self:RegisterProtocol(SCElementHeartChouRewardListInfo, "OnElementHeartChouRewardListInfo")
	self:RegisterProtocol(SCElementProductListInfo, "OnElementProductListInfo")
	self:RegisterProtocol(SCElementXiLianAllInfo, "OnElementXiLianAllInfo")
	self:RegisterProtocol(SCElementXiLianSingleInfo, "OnElementXiLianSingleInfo")

end

-- 五行之灵信息
function SymbolCtrl:OnElementHeartInfo(protocol)
	self.data:SetElementHeartInfo(protocol)
	local index = next(protocol.element_list)
	if protocol.info_type == SymbolData.INFO_TYPE.WUXING_CHANGE and index then
		local info = protocol.element_list[index]
		local func = function ()
			self:SendSetElementHeartReq(info.id)
		end
		local cur_element = Language.Symbol.ElementsName[info.tartget_wuxing_type]
		TipsCtrl.Instance:ShowCommonTip(func, nil, string.format(Language.Symbol.ChangeElementText, cur_element))
	end
	self.view:Flush()
	
	RemindManager.Instance:Fire(RemindName.SymbolYuanSu)
	RemindManager.Instance:Fire(RemindName.SymbolYuanHuo)
	RemindManager.Instance:Fire(RemindName.SymbolYuanHun)
	RemindManager.Instance:Fire(RemindName.SymbolYuanShi)
end

-- 商店信息
function SymbolCtrl:OnElementShopInfo(protocol)
	self.data:SetElementShopInfo(protocol)
	self.view:Flush()
end

-- 元素之纹列表信息
function SymbolCtrl:OnElementTextureInfo(protocol)
	self.data:SetElementTextureInfo(protocol)
	self.view:Flush()
end

-- 单个元素之纹信息
function SymbolCtrl:OnCharmGhostSingleCharmInfo(protocol)
	self.data:SetCharmGhostSingleCharmInfo(protocol)
	self.view:Flush()
end

-- 抽奖奖品
function SymbolCtrl:OnElementHeartChouRewardListInfo(protocol)
	self.data:SetElementHeartChouRewardListInfo(protocol)
	if #protocol.reward_list == 1 then
		self.view:Flush("chou_reward", {item_id = protocol.reward_list[1].item_id})
	else
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_SYMBOL_NIUDAN)
	end
end

-- 产出列表
function SymbolCtrl:OnElementProductListInfo(protocol)
	self.data:SetElementProductListInfo(protocol)
	self.view:Flush()
	TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_SYMBOL)
end

-- 全部洗练信息
function SymbolCtrl:OnElementXiLianAllInfo(protocol)
	self.data:SetElementXiLianAllInfo(protocol)
	self.view:Flush()
end

-- 单个洗练信息
function SymbolCtrl:OnElementXiLianSingleInfo(protocol)
	self.data:SetElementXiLianSingleInfo(protocol)
	self.view:Flush("xi_lian_result")
end

-- 五行之灵激活请求
function SymbolCtrl:SendActiveElementHeartReq(id)
	self:SendElementHeartReq(ELEMENT_HEART_REQ_TYPE.ACTIVE_GHOST, id)
end

-- 五行之灵转换请求
function SymbolCtrl:SendChangeElementHeartReq(id)
	self:SendElementHeartReq(ELEMENT_HEART_REQ_TYPE.CHANGE_GHOST_WUXING_TYPE, id)
end

-- 五行之灵设置请求
function SymbolCtrl:SendSetElementHeartReq(id)
	self:SendElementHeartReq(ELEMENT_HEART_REQ_TYPE.SET_GHOST_WUXING_TYPE, id)
end

-- 五行之灵喂养请求
function SymbolCtrl:SendFeedElementHeartReq(id, virtual_id, num)
	self:SendElementHeartReq(ELEMENT_HEART_REQ_TYPE.FEED_ELEMENT, id, virtual_id, num)
end

-- 五行之灵领取请求
function SymbolCtrl:SendRewardElementHeartReq(id)
	self:SendElementHeartReq(ELEMENT_HEART_REQ_TYPE.GET_PRODUCT, id)
end

-- 五行之灵加速请求
function SymbolCtrl:SendProductElementHeartReq(id)
	self:SendElementHeartReq(ELEMENT_HEART_REQ_TYPE.PRODUCT_UP_SEED, id)
end

-- 五行之灵抽奖请求
function SymbolCtrl:SendChoujiangElementHeartReq(count, use_score)
	self:SendElementHeartReq(ELEMENT_HEART_REQ_TYPE.CHOUJIANG, count, use_score)
end

-- 五行之灵抽奖请求
function SymbolCtrl:SendChoujiangElementHeartReqAgain(cj_count, cj_use_score)
	self:SendChoujiangElementHeartReq(cj_count, cj_use_score)
end

-- 五行之灵洗练请求
function SymbolCtrl:SendXilianElementHeartReq(id, lock_flag, color, auto_buy)
	self:SendElementHeartReq(ELEMENT_HEART_REQ_TYPE.XILIAN, id, lock_flag, color, auto_buy)
end

-- 五行之灵背包清理请求
function SymbolCtrl:SendCleanBagElementHeartReq(is_merge)
	self:SendElementHeartReq(ELEMENT_HEART_REQ_TYPE.KNASACK_ORDER, is_merge)
end

--元素之纹升级请求
function SymbolCtrl:SendUpgradeCharmReq(e_index,bag_index)
	self:SendElementHeartReq(ELEMENT_HEART_REQ_TYPE.UPGRADE_CHARM, e_index,bag_index)
end

-- 五行之灵进阶请求
function SymbolCtrl:SendUpgradeGhostReq( element_id, is_one_key,is_auto_buy )
	self:SendElementHeartReq(ELEMENT_HEART_REQ_TYPE.UPGRADE_GHOST,element_id,is_one_key,is_auto_buy)
end

--五行之灵进阶结果返回
function SymbolCtrl:OnElementHeartUpgradeResult(result)
	self.view:Flush("heart_upgrade_result", {result})
end

-- 五行之灵符咒升级结果返回
function SymbolCtrl:OnElementTextureUpgradeResult(result)
	self.view:Flush("texture_upgrade_result", {result})
end

-- 刷新商店
function SymbolCtrl:SendShopRefreshtReq(is_use_score)
	self:SendElementHeartReq(ELEMENT_HEART_REQ_TYPE.SHOP_REFRSH, is_use_score)
end

-- 购买商店物品
function SymbolCtrl:SendShopBuyReq(seq)
	self:SendElementHeartReq(ELEMENT_HEART_REQ_TYPE.SHOP_BUY, seq)
end

-- 穿戴装备
function SymbolCtrl:SendPutOnEquipment(id, equip_index)
	self:SendElementHeartReq(ELEMENT_HEART_REQ_TYPE.PUTON_EQUIP, id, equip_index)
end

-- 装备升级
function SymbolCtrl:SendEquipUpgrade(id, is_auto)
	self:SendElementHeartReq(ELEMENT_HEART_REQ_TYPE.UPGRADE_EQUIP, id, is_auto)
end

-- 装备分解
function SymbolCtrl:SendEquipRecycle(grid_index, num)
	self:SendElementHeartReq(ELEMENT_HEART_REQ_TYPE.EQUIP_RECYCLE, grid_index, num)
end

-- 五行之灵操作请求
function SymbolCtrl:SendElementHeartReq(info_type, param1, param2, param3, param4)
	local protocol = ProtocolPool.Instance:GetProtocol(CSElementHeartReq)
	protocol.info_type = info_type
	protocol.param1 = param1 or 0
	protocol.param2 = param2 or 0
	protocol.param3 = param3 or 0
	protocol.param4 = param4 or 0
	protocol:EncodeAndSend()
end

-- 打开附魂选择提示界面
function SymbolCtrl:OpenSymbolSelectTips(callback)
	self.symbol_select_tips_view:SetCallBack(callback)
	self.symbol_select_tips_view:Open()
end

function SymbolCtrl:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	RemindManager.Instance:Fire(RemindName.SymbolYuanHuo)
	
	self.data:ClearCacheElementItemList()
	self.data:UpdateFoodList()
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

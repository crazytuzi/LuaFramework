KuaFuXiuLuoTowerBuyView = KuaFuXiuLuoTowerBuyView or BaseClass(BaseView)

function KuaFuXiuLuoTowerBuyView:__init()
	self.ui_config = {"uis/views/kuafuxiuluotower_prefab", "XiuLuoTaBuffView"}
end

function KuaFuXiuLuoTowerBuyView:__delete()
	UnityEngine.PlayerPrefs.DeleteKey("kf_xlt_inspire")
	UnityEngine.PlayerPrefs.DeleteKey("kf_xlt_buy_revive")
end

function KuaFuXiuLuoTowerBuyView:ReleaseCallBack()
	self.gongji_inspire = nil
	self.hp_inspire = nil
	self.max_inspire = nil
	self.once_inspire_cost = nil
	self.once_inspire_add = nil
	self.revive_count = nil
	self.max_buy = nil
	self.once_buy_cost = nil
end

function KuaFuXiuLuoTowerBuyView:OpenCallBack()
end

function KuaFuXiuLuoTowerBuyView:CloseCallBack()
	UnityEngine.PlayerPrefs.DeleteKey("kf_xlt_inspire")
	UnityEngine.PlayerPrefs.DeleteKey("kf_xlt_buy_revive")
end

function KuaFuXiuLuoTowerBuyView:SetTopTimeText()
	local state_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.KF_XIULUO_TOWER)
	if state_info ~= nil and state_info.status == 2 then
		self.top_time_text:SetValue(Language.Activity.KaiQiZhong)
	else
		local cfg = KuaFuXiuLuoTowerData.Instance:GetXiuLuoTowerOpenTimeCfg()
		self.top_time_text:SetValue(cfg.open_time..Language.Common.Open)
	end
end

function KuaFuXiuLuoTowerBuyView:LoadCallBack()
	self:ListenEvent("OnClickClose", BindTool.Bind(self.Close, self))
	self:ListenEvent("OnInspire", BindTool.Bind3(self.OnClickBuyHandler, self, 0, 0))
	self:ListenEvent("OnBuy", BindTool.Bind3(self.OnClickBuyHandler, self, 1, 1))

	self.gongji_inspire = self:FindVariable("GongjiInspire")
	self.hp_inspire = self:FindVariable("HpInspire")
	self.max_inspire = self:FindVariable("MaxInspire")
	self.once_inspire_cost = self:FindVariable("OnceInspireCost")
	self.once_inspire_add = self:FindVariable("OnceInspireAdd")
	self.revive_count = self:FindVariable("ReviveCount")
	self.max_buy = self:FindVariable("MaxBuy")
	self.once_buy_cost = self:FindVariable("OnceBuyCost")
	self:Flush()
end

function KuaFuXiuLuoTowerBuyView:OnClickBuyHandler(is_buy_realive_count, is_use_gold_bind)
	local other_cfg = ConfigManager.Instance:GetAutoConfig("kuafu_rongyudiantang_auto").other[1]
	if is_buy_realive_count == 0 then
		local func  = function ()
			KuaFuXiuLuoTowerCtrl.Instance:SendCrossXiuluoTowerBuyBuff(is_buy_realive_count, is_use_gold_bind)
		end
		TipsCtrl.Instance:ShowCommonAutoView("kf_xlt_inspire", string.format(Language.Honorhalls.GuwuTips, other_cfg.yb_guwu_cost), func)
	else
		local func  = function ()
			KuaFuXiuLuoTowerCtrl.Instance:SendCrossXiuluoTowerBuyBuff(is_buy_realive_count, is_use_gold_bind)
		end
		TipsCtrl.Instance:ShowCommonAutoView("kf_xlt_buy_revive", string.format(Language.Honorhalls.BuyFuhuoTips, other_cfg.buy_fuhuo_cost), func)
	end
end

function KuaFuXiuLuoTowerBuyView:OnFlush()
	local buff_info = KuaFuXiuLuoTowerData.Instance:GetAttrInfo()
	local other_cfg = ConfigManager.Instance:GetAutoConfig("kuafu_rongyudiantang_auto").other[1]

	self.gongji_inspire:SetValue(buff_info.add_gongji_per)
	self.hp_inspire:SetValue(buff_info.add_hp_per)
	self.max_inspire:SetValue(other_cfg.add_guwu)
	self.once_inspire_cost:SetValue(other_cfg.yb_guwu_cost)
	self.once_inspire_add:SetValue(5)
	self.revive_count:SetValue(buff_info.buy_realive_count + other_cfg.fuhuo_count)
	self.max_buy:SetValue(5)
	self.once_buy_cost:SetValue(other_cfg.buy_fuhuo_cost)
end


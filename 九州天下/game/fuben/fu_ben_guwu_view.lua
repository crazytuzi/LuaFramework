FuBenGuWuView = FuBenGuWuView or BaseClass(BaseView)
GONGJI_BUFF_TYPR = 0
JINGYAN_BUFF_TYPE = 23
PRODUCT_METHOD_TYPE = 24
function FuBenGuWuView:__init()
	self.ui_config = {"uis/views/fubenview", "FuBenGuWuView"}
	self:SetMaskBg(true)
	self.gongji_guwu_num = 0
	self.gold_guwu_num = 0
end

function FuBenGuWuView:LoadCallBack()
	self.gongji_guwu_value = self:FindVariable("GongJi_GuWu_Value")
	self.exp_guwu_value = self:FindVariable("Exp_GuWu_Value")
	self.gongji_max_jiacheng = self:FindVariable("GongJi_JiaCheng")
	self.exp_max_jiacheng = self:FindVariable("Exp_JiaCheng")
	self.gongji_bangyuan_value = self:FindVariable("GongJi_BangYuan_Value")
	self.exp_bangyuan_value = self:FindVariable("Exp_BangYuan_Value")
	self.gongji_pet = self:FindVariable("GongJi_Pet")
	self.exp_pet = self:FindVariable("Exp_Pet")
	self.gongji_btnenble = self:FindVariable("GongJiBtnEnble")
	self.jingyan_btnenble = self:FindVariable("JingYanBtnEnble")

	self:ListenEvent("CloseGuWuView",
		BindTool.Bind(self.OnCloseView, self))
	self:ListenEvent("OnClickGongJiGuWu",
		BindTool.Bind(self.OnClickGongJiGuWu, self))
	self:ListenEvent("OnClickGoldGuWu",
		BindTool.Bind(self.OnClickGoldGuWu, self))

	self:GuWuJiaCheng()
	self:GuWuPet()
end

function FuBenGuWuView:__delete()

end

function FuBenGuWuView:ReleaseCallBack()
-- 清理变量和对象
	self.gongji_guwu_value = nil
	self.exp_guwu_value = nil
	self.gongji_max_jiacheng = nil
	self.exp_max_jiacheng = nil
	self.gongji_bangyuan_value = nil
	self.exp_bangyuan_value = nil
	self.gongji_pet = nil
	self.exp_pet = nil
	self.gongji_btnenble = nil
	self.jingyan_btnenble = nil

	UnityEngine.PlayerPrefs.DeleteKey("gongji_guwu")
	UnityEngine.PlayerPrefs.DeleteKey("gold_guwu")
end

function FuBenGuWuView:OnCloseView()
	self:Close()
end

function FuBenGuWuView:OnClickGongJiGuWu()
	local daily_fb_cfg = FuBenData.Instance:GetExpDailyFb()
	local str = string.format(Language.FB.GongJiGuWu, daily_fb_cfg[0].fb_guwu_cost_bind_gold, daily_fb_cfg[0].fb_guwu_gongji_per)
	local yes_func = function ()
		FuBenCtrl.Instance:SendFbGuwuReq(0, GUWU_TYPE.GUWU_TYPE_GONGJI)
	end
	if UnityEngine.PlayerPrefs.GetInt("gongji_guwu") == 1 then
		yes_func()
	else
		TipsCtrl.Instance:ShowCommonTip(yes_func, nil, str, nil, nil, true, false, "gongji_guwu")
	end
end

function FuBenGuWuView:OnClickGoldGuWu()
	local daily_fb_cfg = FuBenData.Instance:GetExpDailyFb()
	local str = string.format(Language.FB.ExpGuWu, daily_fb_cfg[0].fb_guwu_cost_gold, daily_fb_cfg[0].fb_guwu_exp_per)
	local yes_func = function ()
		FuBenCtrl.Instance:SendFbGuwuReq(0, GUWU_TYPE.GUWU_TYPE_EXP)
	end
	if UnityEngine.PlayerPrefs.GetInt("gold_guwu") == 1 then
		yes_func()
	else
		TipsCtrl.Instance:ShowCommonTip(yes_func, nil, str, nil, nil, true, false, "gold_guwu")
	end
end

function FuBenGuWuView:GuWuJiaCheng()
	local daily_fb_cfg = FuBenData.Instance:GetExpDailyFb()
	self.gongji_max_jiacheng:SetValue(daily_fb_cfg[0].fb_guwu_gongji_max_per.."%")
	self.exp_max_jiacheng:SetValue(daily_fb_cfg[0].fb_guwu_exp_max_per.."%")
	self.gongji_bangyuan_value:SetValue(daily_fb_cfg[0].fb_guwu_cost_bind_gold)
	self.exp_bangyuan_value:SetValue(daily_fb_cfg[0].fb_guwu_cost_gold)
	self.gongji_pet:SetValue(daily_fb_cfg[0].fb_guwu_gongji_per)
	self.exp_pet:SetValue(daily_fb_cfg[0].fb_guwu_exp_per)
end

function FuBenGuWuView:GuWuPet()
	local daily_fb_cfg = FuBenData.Instance:GetExpDailyFb()
	local buff_info = FightData.Instance:GetMainRoleEffectList()
	if next(buff_info) then
		for k,v in pairs(buff_info) do
			if v.product_method == PRODUCT_METHOD_TYPE then
				if v.effect_type == GONGJI_BUFF_TYPR then
					if self.gongji_guwu_value then
						self.gongji_guwu_value:SetValue(v.merge_layer*daily_fb_cfg[0].fb_guwu_gongji_per .."%")
					end
					self.gongji_btnenble:SetValue(v.merge_layer < (daily_fb_cfg[0].fb_guwu_gongji_max_per / 10))
				else
					self.exp_guwu_value:SetValue(v.merge_layer*daily_fb_cfg[0].fb_guwu_exp_per .."%")
					self.jingyan_btnenble:SetValue(v.merge_layer < (daily_fb_cfg[0].fb_guwu_exp_max_per / 10))
				end
			end
		end
	end
end

--[[
祈愿
wangshuai

]]

_G.UIWishPanel = BaseUI:new("UIWishPanel")

function UIWishPanel:Create()
	self:AddSWF("WishPanel.swf",true,"center")
end;

function UIWishPanel:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:Hide()end;

	objSwf.buy_exp.click = function()self:BuyClick(enAttrType.eaExp)end;
	objSwf.buy_lingli.click = function() self:BuyClick(enAttrType.eaZhenQi) end;
	objSwf.buy_gold.click = function() self:BuyClick(enAttrType.eaBindGold)end;
	objSwf.upVipLvl.click = function() self:GoVipWindow() end;

end;

function UIWishPanel:IsTween()
	return true;
end
-- 面板类型
function UIWishPanel:GetPanelType()
	return 1;
end;
function UIWishPanel:IsShowSound()
	return true;
end


function UIWishPanel:OnShow()
	self:ShowInfo();
end;

function UIWishPanel:GoVipWindow()
	if not UIVip:IsShow() then 
		UIVip:Show();
		self:Hide();
	end;
end;

function UIWishPanel:OnHide()

end;

function UIWishPanel:ShowInfo()
	local objSwf = self.objSwf;
	local roleLvl = MainPlayerModel.humanDetailInfo.eaLevel;
	local cfg = t_dailybuy[roleLvl];
	-- 得到数量
	objSwf.exp_num.num = cfg.exp.."e"
	objSwf.lingli_num.num = cfg.lingli.."l"
	objSwf.jingbi_num.num = cfg.gold.."g"

	local curExpCfg = WishModel:GetWishInfo(enAttrType.eaExp)
	local curLingliCfg = WishModel:GetWishInfo(enAttrType.eaZhenQi)
	local curgGoldCfg = WishModel:GetWishInfo(enAttrType.eaBindGold)
	if not curExpCfg or not curLingliCfg or not curgGoldCfg then 
		return 
	end;

	-- 经验
	objSwf.txt_extNum.text = WishModel:GetConsumptionYuanBao(enAttrType.eaExp)
	objSwf.txt_expLast.htmlText = string.format(StrConfig['wish006'],curExpCfg.lastnum)

	-- 灵力
	objSwf.txt_lingliNum.text = WishModel:GetConsumptionYuanBao(enAttrType.eaZhenQi)
	objSwf.txt_lingliLast.htmlText = string.format(StrConfig['wish006'],curLingliCfg.lastnum)
 
	-- 金币
	objSwf.txt_goldNum.text = WishModel:GetConsumptionYuanBao(enAttrType.eaBindGold)
	objSwf.txt_goldLast.htmlText = string.format(StrConfig['wish006'],curgGoldCfg.lastnum)


end;

function UIWishPanel:BuyClick(type)
	WishController:WishBuy(type)
end;


function UIWishPanel:ListNotificationInterests()
	return {
		NotifyConsts.WishInfoUpdata,
		NotifyConsts.PlayerAttrChange,
	}
end

function UIWishPanel:HandleNotification(name,body)
	if not self.bShowState then return; end
	if name == NotifyConsts.WishInfoUpdata then
		self:ShowInfo();
	elseif name == NotifyConsts.PlayerAttrChange then 
		if body.type == enAttrType.eaLevel then 
			self:ShowInfo();
		end;
	end
end


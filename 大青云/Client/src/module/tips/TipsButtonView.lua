--[[
UI:按钮类Tips
lizhuangzhuang
2014年7月24日21:24:06
]]

_G.UITipsBtn = BaseUI:new("UITipsBtn");

UITipsBtn.tipsStr = "";
UITipsBtn.tipsDir = 0;

function UITipsBtn:Create()
	self:AddSWF("tipsBtn.swf",true,"float");
end

function UITipsBtn:OnLoaded(objSwf)
	objSwf.hitTestDisable = true
end

function UITipsBtn:NeverDeleteWhenHide()
	return true;
end

function UITipsBtn:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end;
	objSwf.tfTips.htmlText = self.tipsStr;
	objSwf.tfTips._height = objSwf.tfTips.textHeight + 24;
	objSwf.bg._width = objSwf.tfTips.textWidth + 24;
	objSwf.bg._height = objSwf.tfTips.textHeight + 24;
	
	local tipsX,tipsY = TipsUtils:GetTipsPos(objSwf.bg._width,objSwf.bg._height,self.tipsDir);
	objSwf._x = tipsX;
	objSwf._y = tipsY;
end

function UITipsBtn:HandleNotification(name,body)
	if name == NotifyConsts.StageMove then
		local objSwf = self.objSwf;
		if not objSwf then return; end
		local tipsX,tipsY = TipsUtils:GetTipsPos(objSwf.bg._width,objSwf.bg._height,self.tipsDir);
		objSwf._x = tipsX;
		objSwf._y = tipsY;
	elseif name == NotifyConsts.StageClick then
		local objSwf = self.objSwf
		if not objSwf then return end
		if self.itemID then
			if self.itemID == 92 then
				--试炼积分
				UIShopCarryOn:OpenShopByType(ShopConsts.T_Babel)
			elseif self.itemID == 51 then
				--荣誉 51
				UIShopCarryOn:OpenShopByType(ShopConsts.T_Honor)
			elseif self.itemID == 81 then
				-- 帮贡 81
				UIShopCarryOn:OpenShopByType(ShopConsts.T_Guild)
			elseif self.itemID == 13 then
				--绑元
				-- UIShoppingMall:Show()
				UIShoppingMall:OpenPanel(3)
			elseif self.itemID == 12 then
				--元宝
				-- UIShoppingMall:Show()
				UIShoppingMall:OpenPanel(2)
			end
		end
	end
end

function UITipsBtn:ListNotificationInterests()
	return {NotifyConsts.StageMove, NotifyConsts.StageClick};
end

function UITipsBtn:IsTween()
	return false;
end


--显示tips
--@param tipsStr	tips内容
--@param tipsDir	tips方位
function UITipsBtn:ShowTips(tipsStr,tipsDir,itemID)
	if not tipsStr then
		return;
	end
	self.itemID = itemID
	self.tipsStr = tipsStr;
	self.tipsDir = tipsDir;
	if self:IsShow() then
		self:OnShow();
	else
		self:Show();
	end
end
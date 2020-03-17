--[[
物品出售确认面板
lizhuangzhuang
2014年8月14日17:09:07
]]

_G.UIBagSellConfirm = BaseUI:new("UIBagSellConfirm");

UIBagSellConfirm.confirmFunc = nil;--确认回调
UIBagSellConfirm.cancelFunc = nil;--取消回调

function UIBagSellConfirm:Create()
	self:AddSWF("bagSellConfirmPanel.swf",true,"top");
end

function UIBagSellConfirm:OnLoaded(objSwf)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	objSwf.btnConfirm.click = function() self:OnBtnConfirmClick(); end
	objSwf.btnCancel.click = function() self:OnBtnCancelClick(); end
end

function UIBagSellConfirm:GetWidth()
	return 280;
end

function UIBagSellConfirm:GetHeight()
	return 208;
end

function UIBagSellConfirm:OnResize(wWith,wHeight)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.mcMask._width = wWith;
	objSwf.mcMask._height = wHeight;
end

function UIBagSellConfirm:OnShow()
	SoundManager:PlaySfx(2045);
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.btnCheckBox.selected = not BagModel.sellNeedConfirm;
	local wWith,wHeight = UIManager:GetWinSize();
	objSwf.mcMask._width = wWith;
	objSwf.mcMask._height = wHeight;
end

function UIBagSellConfirm:Open(bag,pos,confirmFunc,cancelFunc)
	--判断是否勾选了不在确认
	if not BagModel.sellNeedConfirm then
		if confirmFunc then confirmFunc(); end
		if cancelFunc then cancelFunc(); end
		return;
	end
	--判断配置，出售是否需要确认
	local bagVO = BagModel:GetBag(bag);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(pos);
	if not item then return; end
	local sellNeedConfirm = false;
	if item:GetShowType() == BagConsts.ShowType_Equip then
		local equipCfg = t_equip[item:GetTid()];
		if equipCfg and equipCfg.sellConfirm then
			sellNeedConfirm = true;
		else
			if item:IsValuable() then
				sellNeedConfirm = true;
			end
		end
	else
		local itemCfg = t_item[item:GetTid()];
		if itemCfg then
			sellNeedConfirm = itemCfg.sellConfirm;
		end
	end
	if not sellNeedConfirm then
		if confirmFunc then confirmFunc(); end
		if cancelFunc then cancelFunc(); end
		return;
	end
	--
	self.confirmFunc = confirmFunc;
	self.cancelFunc = cancelFunc;
	self:Show();
end

function UIBagSellConfirm:OnBtnCloseClick()
	if self.cancelFunc then
		self.cancelFunc();
	end
	self:Hide();
end

function UIBagSellConfirm:OnBtnCancelClick()
	if self.cancelFunc then
		self.cancelFunc();
	end
	self:Hide();
end

function UIBagSellConfirm:OnBtnConfirmClick()
	if self.confirmFunc then
		self.confirmFunc();
	end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	BagModel.sellNeedConfirm = not objSwf.btnCheckBox.selected;
	self:Hide();
end


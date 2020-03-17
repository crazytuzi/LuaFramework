--[[
卓越道具获得
lizhuangzhuang
2015年6月2日11:34:48
]]

_G.UIEquipSuperItemGet = BaseUI:new("UIEquipSuperItemGet");

UIEquipSuperItemGet.itemTid = 0;
UIEquipSuperItemGet.itemSuperVO = nil;

UIEquipSuperItemGet.isNoTip = false;

function UIEquipSuperItemGet:Create()
	self:AddSWF("superItemGet.swf",true,"center");
end

function UIEquipSuperItemGet:OnLoaded(objSwf)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	objSwf.btnConfirm.click = function() self:OnBtnConfirmClick(); end
	objSwf.item.rollOver = function() self:OnItemRollOver(); end
	objSwf.item.rollOut = function() self:OnItemRollOut(); end
end

function UIEquipSuperItemGet:Open(itemUid)
	if self.isNoTip then
		return;
	end
	--
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end
	local bagItem = bagVO:GetItemById(itemUid);
	if not bagItem then return; end
	--
	self.itemTid = bagItem:GetTid();
	self.itemSuperVO = EquipModel:GetItemSuperVO(itemUid);
	if self:IsShow() then
		self:OnShow();
		self:Top();
	else
		self:Show();
	end
end

function UIEquipSuperItemGet:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local slotVO = RewardSlotVO:new();
	slotVO.id = self.itemTid;
	slotVO.count = 0;
	objSwf.item:setData(slotVO:GetUIData());
	local cfg = t_item[self.itemTid];
	if cfg then
		objSwf.tfItemName.htmlText = string.format("<font color='%s'>%s</font>",TipsConsts:GetItemQualityColor(cfg.quality),cfg.name);
	end
	--
	objSwf.tfAttr.htmlText = self:GetSuperStr(self.itemSuperVO.id,self.itemSuperVO.val1);
end

function UIEquipSuperItemGet:GetSuperStr(id,val1)
	local cfg = t_fujiashuxing[id];
	if not cfg then return ""; end
	local attrStr = formatAttrStr(cfg.attrType,val1);
	return string.format("<font color='%s'>「%s」%s</font>",TipsConsts.SuperColor,cfg.name,attrStr);
end

function UIEquipSuperItemGet:OnItemRollOver()
	local itemTipsVO = ItemTipsUtil:GetItemTipsVO(self.itemTid,1);
	if not itemTipsVO then return; end
	itemTipsVO.itemSuperVO = self.itemSuperVO;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
end

function UIEquipSuperItemGet:OnItemRollOut()
	TipsManager:Hide();
end

function UIEquipSuperItemGet:OnBtnConfirmClick()
	local objSwf = self.objSwf;
	if objSwf.cbNoTip.selected then
		self.isNoTip = true;
	end
	self:Hide();
end

function UIEquipSuperItemGet:OnBtnCloseClick()
	local objSwf = self.objSwf;
	if objSwf.cbNoTip.selected then
		self.isNoTip = true;
	end
	self:Hide();
end

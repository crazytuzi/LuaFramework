--[[
装备开卓越孔
lizhuangzhuang
2015年10月20日15:33:14
]]

_G.UIEquipSuperOpenHole = BaseUI:new("UIEquipSuperOpenHole");

UIEquipSuperOpenHole.equipId = nil;--装备cid

function UIEquipSuperOpenHole:Create()
	self:AddSWF("equipSuperHole.swf",true,"center");
end

function UIEquipSuperOpenHole:OnLoaded(objSwf)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	objSwf.btnCancel.click = function() self:OnBtnCancelClick(); end
	objSwf.btnConfirm.click = function() self:OnBtnConfirmClick(); end
	objSwf.item.rollOver = function() self:OnItemRollOver(); end
	objSwf.item.rollOut = function() self:OnItemRollOut(); end
	objSwf.btnConfirm.label = StrConfig["equip1201"];
	objSwf.btnCancel.label = StrConfig["confirmName3"];
end

function UIEquipSuperOpenHole:Open(equipId)
	self.equipId = equipId;
	if self:IsShow() then
		self:OnShow();
	else
		self:Show();
	end
end

function UIEquipSuperOpenHole:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local slotVO = RewardSlotVO:new();
	slotVO.id = EquipConsts:GetSuperHoleItem();
	slotVO.count = 0;
	objSwf.item:setData( slotVO:GetUIData() );
	--
	local itemCfg = t_item[EquipConsts:GetSuperHoleItem()];
	if not itemCfg then return; end
	local str = "";
	local bagNum = BagModel:GetItemNumInBag(EquipConsts:GetSuperHoleItem());
	if bagNum >= EquipConsts:GetSuperHoleItemNum() then
		str = string.format(StrConfig["equip1202"],"#00ff00",itemCfg.name,EquipConsts:GetSuperHoleItemNum());
	else
		str = string.format(StrConfig["equip1202"],"#cc0000",itemCfg.name,EquipConsts:GetSuperHoleItemNum());
	end
	objSwf.tfContent.htmlText = str;
end

function UIEquipSuperOpenHole:OnHide()
	self.equipId = nil;
end

function UIEquipSuperOpenHole:ESCHide()
	return true;
end

function UIEquipSuperOpenHole:OnESC()
	self:OnBtnCloseClick();
end

function UIEquipSuperOpenHole:OnBtnConfirmClick()
	if not self.equipId then return; end
	EquipController:OpenSuperHole(self.equipId);
	self:Hide();
end

function UIEquipSuperOpenHole:OnBtnCloseClick()
	self:Hide();
end

function UIEquipSuperOpenHole:OnBtnCancelClick()
	self:Hide();
end

function UIEquipSuperOpenHole:OnItemRollOver()
	TipsManager:ShowItemTips(EquipConsts:GetSuperHoleItem());
end

function UIEquipSuperOpenHole:OnItemRollOut()
	TipsManager:Hide();
end

function UIEquipSuperOpenHole:HandleNotification(name,body)
	if name == NotifyConsts.BagItemNumChange then
		if body.id == EquipConsts:GetSuperHoleItem() then
			self:OnShow();
		end
	end
end

function UIEquipSuperOpenHole:ListNotificationInterests()
	return {NotifyConsts.BagItemNumChange};
end
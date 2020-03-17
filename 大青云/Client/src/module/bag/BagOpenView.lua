--[[
背包扩展
lizhuangzhuang
2014-10-10 21:30:03
]]

_G.UIBagOpen = BaseUI:new("UIBagOpen");

UIBagOpen.bagType = 0;
UIBagOpen.pos = 0;
--开启数量
UIBagOpen.openNum = 0;
--需要道具数量
UIBagOpen.itemNum = 0;

function UIBagOpen:Create()
	self:AddSWF("bagOpenPanel.swf",true,"center");
end

function UIBagOpen:OnLoaded(objSwf,name)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	objSwf.btnConfirm.click = function() self:OnBtnConfirmClick(); end
	objSwf.btnCancel.click = function() self:OnBtnCancelClick(); end
	objSwf.btnItem.rollOver = function() self:OnBtnItemRollOver(); end
	objSwf.btnItem.rollOut = function() self:OnBtnItemRollOut(); end
	--显示道具名
	local itemId = t_consts[5].val1;
	local itemCfg = t_item[itemId];
	if itemCfg then
		objSwf.btnItem.htmlLabel = "<u>" .. itemCfg.name .. "</u>";
	end
	objSwf.mcTitle:stop();
end

function UIBagOpen:Open(bagType,pos)
	self.bagType = bagType;
	self.pos = pos;
	if self:IsShow() then
		self:OnShow();
		self:Top();
	else
		self:Show();
	end
end

function UIBagOpen:OnShow()
	local objSwf = self:GetSWF("UIBagOpen");
	if not objSwf then return; end
	if self.bagType == BagConsts.BagType_Bag then
		objSwf.mcTitle:gotoAndStop(1);
	else
		objSwf.mcTitle:gotoAndStop(2);
	end
	local bagVO = BagModel:GetBag(self.bagType);
	if not bagVO then return; end
	--计算格子数量
	if self.pos + 1 > bagVO:GetTotalSize() then
		self:Hide();
		return;
	end
	self.openNum = self.pos + 1 - bagVO:GetSize();
	if self.openNum <= 0 then
		self:Hide();
		return;
	end
	objSwf.tfOpenNum.htmlText = string.format(StrConfig['bag22'],self.openNum);
	local cfgT = nil;
	if self.bagType == BagConsts.BagType_Bag then
		cfgT = t_packetcost;
	elseif self.bagType == BagConsts.BagType_Storage then
		cfgT = t_storagecost;
	end
	if not cfgT then return; end
	--显示开格子获得
	self.itemNum = 0;
	for i=1,self.openNum do
		local cfg = cfgT[bagVO:GetSize()+i-bagVO:GetDefaultSize()];
		self.itemNum  = self.itemNum + cfg.itemNum;
	end
	--条件
	self:ShowCondition();
end

function UIBagOpen:OnHide()
end

--显示条件
function UIBagOpen:ShowCondition()
	local objSwf = self:GetSWF("UIBagOpen");
	if not objSwf then return; end
	--道具消耗
	local currItemNum = BagModel:GetItemNumInBag(t_consts[5].val1);
	local str = currItemNum .."/".. self.itemNum;
	if currItemNum < self.itemNum then
		str = "<font color='#cc0000'>" .. str .. "</font>";
	else
		str = "<font color='#29cc00'>" .. str .. "</font>";
	end
	objSwf.tfItemNum.htmlText = str;
	--显示元宝
	local bindMoney = 0;
	local money = 0;
	if currItemNum < self.itemNum then
		money = (self.itemNum-currItemNum) * t_consts[5].val2;
		bindMoney = (self.itemNum-currItemNum) * t_consts[5].val3;
	end
	local currBindMoney = MainPlayerModel.humanDetailInfo.eaBindMoney;
	if currBindMoney < bindMoney then
		-- objSwf.tfBindMoney.htmlText = string.format(StrConfig['bag25'],bindMoney);
	else
		-- objSwf.tfBindMoney.htmlText = string.format(StrConfig['bag26'],bindMoney);
	end
	local currMoney = MainPlayerModel.humanDetailInfo.eaUnBindMoney;
	if currMoney < money then
		objSwf.tfMoney.htmlText = string.format(StrConfig['bag25'],money);
	else
		objSwf.tfMoney.htmlText = string.format(StrConfig['bag26'],money);
	end
end

function UIBagOpen:OnBtnItemRollOver()
	local objSwf = self:GetSWF("UIBagOpen");
	if not objSwf then return; end
	TipsManager:ShowItemTips(t_consts[5].val1);
end

function UIBagOpen:OnBtnItemRollOut()
	TipsManager:Hide();
end

function UIBagOpen:OnBtnConfirmClick()
	local objSwf = self:GetSWF("UIBagOpen");
	if not objSwf then return; end
	local moneyType = 1;--1元宝,2绑定元宝
	--检查条件
	local currItemNum = BagModel:GetItemNumInBag(t_consts[5].val1);
	--物品不足时检查元宝
	if currItemNum < self.itemNum then
		local money = (self.itemNum-currItemNum) * t_consts[5].val2;
		local bindMoney = (self.itemNum-currItemNum) * t_consts[5].val3;
		if moneyType==1 and money>MainPlayerModel.humanDetailInfo.eaUnBindMoney then
			FloatManager:AddNormal(StrConfig['bag27'],objSwf.btnConfirm);
			return;
		end
		if moneyType==2 and bindMoney>MainPlayerModel.humanDetailInfo.eaBindMoney then
			FloatManager:AddNormal(StrConfig['bag27'],objSwf.btnConfirm);
			return;
		end
	end
	BagController:ExpandBag(self.bagType,self.openNum,moneyType);
	self:Hide();
end

function UIBagOpen:OnBtnCloseClick()
	self:Hide();
end

function UIBagOpen:OnBtnCancelClick()
	self:Hide();
end

function UIBagOpen:HandleNotification(name,body)
	if not self.bShowState then return; end
	if not self:GetSWF("UIBagOpen") then return; end
	if name==NotifyConsts.BagAdd or name==NotifyConsts.BagRemove or name==NotifyConsts.BagUpdate then
		if body.type == BagConsts.BagType_Bag then
			self:ShowCondition();
		end
	elseif name == NotifyConsts.BagSlotOpen then
		if body.type == self.bagType then
			self:OnShow();
		end
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type==enAttrType.eaBindMoney or body.type==enAttrType.eaUnBindMoney then
			self:ShowCondition();
		end
	end
end

function UIBagOpen:ListNotificationInterests()
	return {NotifyConsts.BagAdd,NotifyConsts.BagRemove,NotifyConsts.BagUpdate,NotifyConsts.BagSlotOpen,
			NotifyConsts.PlayerAttrChange};
end
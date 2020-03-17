--[[
背包:批量使用
lizhuangzhuang
2014年8月5日21:30:50
]]

_G.UIBagBatchUse = BaseUI:new("UIBagBatchUse");

UIBagBatchUse.bagType = 0;--背包
UIBagBatchUse.pos = 0;--格子位置

function UIBagBatchUse:Create()
	self:AddSWF("bagSplitPanel.swf",true,"center");
end

function UIBagBatchUse:OnLoaded(objSwf,name)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	objSwf.btnConfirm.click = function() self:OnBtnConfirmClick(); end
	objSwf.btnCancel.click = function() self:OnBtnCancelClick(); end
	objSwf.item.rollOver    = function(e) self:OnItemRollOver(e); end
	objSwf.item.rollOut     = function() self:OnItemRollOut(); end
	
	objSwf.mcTitle:gotoAndStop(2);
	objSwf.labelNameKey.text = StrConfig["bag2"];
	
	objSwf.nsNum.change = function() print(objSwf.nsNum.value); end
end

function UIBagBatchUse:OnShow(name)
	if not self:ResetPanel() then
		self:Hide();
	end
end

--打开面板
--@param bagType 背包
--@param pos	 位置
function UIBagBatchUse:Open(bagType,pos)
	self.bagType = bagType;
	self.pos = pos;
	--检测物品是否可使用
	local bagVO = BagModel:GetBag(bagType);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(pos);
	if not item then return; end
	local canUseNum,rst = BagModel:GetItemCanUseNum(item:GetTid());
	if canUseNum == 0 then
		if rst == -1 then
			FloatManager:AddNormal(StrConfig['bag53']);
		else
			FloatManager:AddNormal(StrConfig['bag54']);
		end
		return;
	end
	--
	if self:IsShow() then
		if not self:ResetPanel() then
			self:Hide();
		end
		self:Top();
	else
		self:Show();
	end
end

function UIBagBatchUse:ResetPanel()
	local objSwf = self:GetSWF("UIBagBatchUse");
	if not objSwf then return; end
	local bagVO = BagModel:GetBag(self.bagType);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(self.pos);
	if not item then return; end
	local tid = item:GetTid();
	--

	local canUseNum,rst = BagModel:GetItemCanUseNum(item:GetTid());
	if canUseNum>0 and item:GetCount()>canUseNum then
		objSwf.nsNum.minimum = 1;
		objSwf.nsNum.maximum = canUseNum;
		objSwf.nsNum.value = canUseNum;
		if rst == -1 then
			objSwf.tfInfo.text = string.format(StrConfig['bag55'],canUseNum);
		else
			objSwf.tfInfo.text = string.format(StrConfig['bag56'],canUseNum);
		end
	else
		objSwf.tfInfo.text = "";
		objSwf.nsNum.minimum = 1;
		objSwf.nsNum.maximum = item:GetCount();
		objSwf.nsNum.value = item:GetCount();
	end
	--
	local itemConfig = t_item[tid];
	if itemConfig then
		-- objSwf.labelContent.text = string.format(StrConfig["bag3"],itemConfig.name);
		objSwf.txtOper.text = StrConfig["bag3"];
		objSwf.txtName.text = itemConfig.name;
		objSwf.txtName.textColor = TipsConsts:GetItemQualityColorVal( itemConfig.quality );
		--显示物品图标
		local slotVO = RewardSlotVO:new();
		slotVO.id = tid;
		slotVO.count = 0;
		objSwf.item:setData( slotVO:GetUIData() );
	end
	return true;
end

--点击确定
function UIBagBatchUse:OnBtnConfirmClick()
	local objSwf = self:GetSWF("UIBagBatchUse");
	if not objSwf then return; end
	local bagVO = BagModel:GetBag(self.bagType);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(self.pos);
	if not item then return; end
	if item:GetTid() ~= GiftsConsts.GiftsBoxID then
		BagController:UseItem(self.bagType,self.pos,objSwf.nsNum.value);
	else
		if objSwf.nsNum.value <= 0 then return;end
		local canUseNum,rst = BagModel:GetItemCanUseNum(item:GetTid());
		if canUseNum == 0 then
			if rst == -1 then
				FloatManager:AddNormal(StrConfig['bag53']);
			else
				FloatManager:AddNormal(StrConfig['bag54']);
			end
			return;
		end
		if canUseNum>0 and objSwf.nsNum.value>0 then
			BagController:QuickUseItem(self.bagType,self.pos,objSwf.nsNum.value)
		end
	end
	self:Hide();
end

--点击关闭
function UIBagBatchUse:OnBtnCloseClick()
	self:Hide();
end

--点击取消
function UIBagBatchUse:OnBtnCancelClick()
	self:Hide();
end

function UIBagBatchUse:OnItemRollOver(e)
	local target = e.target;
	if target.data and target.data.id then
		TipsManager:ShowItemTips( target.data.id);
	end
end

function UIBagBatchUse:OnItemRollOut()
	TipsManager:Hide();
end

function UIBagBatchUse:HandleNotification(name,body)
	if name == NotifyConsts.BagUpdate then
		if body.type == self.bagType and body.pos==self.pos then 
			self:ResetPanel();
		end
	elseif name == NotifyConsts.BagRemove then
		if body.type == self.bagType and body.pos==self.pos then 
			self:Hide();
		end
	end
end

function UIBagBatchUse:ListNotificationInterests()
	return {NotifyConsts.BagUpdate,NotifyConsts.BagRemove};
end
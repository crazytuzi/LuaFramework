--[[
背包拆分面板
lizhuangzhuang
2014年8月5日19:57:28
]]

_G.UIBagSplit = BaseUI:new("UIBagSplit");

UIBagSplit.bagType = 0;--背包
UIBagSplit.pos = 0;--格子位置

function UIBagSplit:Create()
	self:AddSWF("bagSplitPanel.swf",true,"center");
end

function UIBagSplit:OnLoaded(objSwf,name)
	objSwf.btnClose.click   = function() self:OnBtnCloseClick(); end
	objSwf.btnConfirm.click = function() self:OnBtnConfirmClick(); end
	objSwf.btnCancel.click  = function() self:OnBtnCancelClick(); end
	objSwf.item.rollOver    = function(e) self:OnItemRollOver(e); end
	objSwf.item.rollOut     = function() self:OnItemRollOut(); end
	
	objSwf.mcTitle:gotoAndStop(1);
	objSwf.labelNameKey.text = StrConfig["bag8"];
	objSwf.tfInfo.text = "";
end

function UIBagSplit:OnShow(name)
	SoundManager:PlaySfx(2045);
	if not self:ResetPanel() then
		self:Hide();
	end
end

--打开面板
--@param bagType	背包
--@param pos		位置
function UIBagSplit:Open( bagType, pos )
	self.bagType = bagType;
	self.pos = pos;
	if self:IsShow() then
		if not self:ResetPanel() then
			self:Hide();
		end
		self:Top();
	else
		self:Show();
	end
end

--重置面板
function UIBagSplit:ResetPanel()
	local objSwf = self:GetSWF("UIBagSplit");
	if not objSwf then return; end
	local bagVO = BagModel:GetBag(self.bagType);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(self.pos);
	if not item then return; end
	local tid = item:GetTid();
	--是否有拆分权限
	if not BagOperUtil:CheckHasOperRights(BagConsts.Oper_Split,item) then
		return;
	end
	if item:GetCount() <= 1 then
		return;
	end
	--
	objSwf.nsNum.minimum = 1;
	objSwf.nsNum.maximum = item:GetCount()-1;
	objSwf.nsNum.value = 1;
	--
	local itemConfig = t_item[tid];
	if itemConfig then
		-- objSwf.labelContent.text = string.format(StrConfig["bag9"],itemConfig.name);
		objSwf.txtOper.text = StrConfig["bag9"];
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

--点击关闭
function UIBagSplit:OnBtnCloseClick()
	self:Hide();
end

--点击确认
function UIBagSplit:OnBtnConfirmClick()
	local objSwf = self:GetSWF("UIBagSplit");
	if not objSwf then return; end
	BagController:SplitItem(self.bagType,self.pos,objSwf.nsNum.value);
	self:Hide();
end

--点击取消
function UIBagSplit:OnBtnCancelClick()
	self:Hide();
end

function UIBagSplit:OnItemRollOver(e)
	local target = e.target;
	if target.data and target.data.id then
		TipsManager:ShowItemTips( target.data.id);
	end
end

function UIBagSplit:OnItemRollOut()
	TipsManager:Hide();
end


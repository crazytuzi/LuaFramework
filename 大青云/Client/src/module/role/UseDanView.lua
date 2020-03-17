_G.UIUseDan = BaseUI:new("UIUseDan");

UIUseDan.itemId = nil;

function UIUseDan:Create()
	self:AddSWF("UseDanPanel.swf", true, "top");
end

function UIUseDan:OnLoaded(objSwf)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	objSwf.btnLianzhi.click = function() self:OnBtnLianzhiClick(); end
	objSwf.btnLianzhi:showEffect(ResUtil:GetButtonEffect10());
	
	RewardManager:RegisterListTips(objSwf.List);
	objSwf.toBag.click = function() self:OnToBagClick()end;
end
function UIUseDan:OnToBagClick()
	if not UIBag:IsShow() then
		UIBag:Show();
	else
		UIBag:Hide();
		UIBag:Show();
	end
end
function UIUseDan:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.toBag.htmlLabel = string.format(StrConfig['xiuweiPool23']);
	--显示礼包奖励
	local rewardList = RewardManager:Parse(self.rewardStr);
	local list = objSwf.List;
	list.dataProvider:cleanUp();
	list.dataProvider:push( unpack(rewardList) );
	list:invalidateData();
	list:scrollToIndex(0);

end
--点击关闭
function UIUseDan:OnBtnCloseClick()
	self:Hide();
end
--点击一键服用
function UIUseDan:OnBtnLianzhiClick()
	local danList = split(self.rewardStr,"#");
	for i,itemStr in ipairs(danList) do
		local itemvo = split(itemStr,",");
		BagController:UseItemByTid(BagConsts.BagType_Bag, tonumber(itemvo[1]), tonumber(itemvo[2]))
	end
	self:OnBtnCloseClick()
end
--点击下方按钮 
function UIUseDan:OnBtnConfirmClick()
	self:Hide();
end
function UIUseDan:GetPanelType()
	return 0;
end
function UIUseDan:ESCHide()
	return true;
end
--打开面板
--@param rewardStr  丹药list
function UIUseDan:Open(rewardStr)
	self.rewardStr = rewardStr;
	self:Show();
end
function UIUseDan:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.btnLianzhi:clearEffect();
end

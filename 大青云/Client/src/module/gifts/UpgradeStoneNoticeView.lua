--[[
	2015年10月13日, PM 11:08:54
	wangyanwei
	升阶石notic
]]

_G.UIUpgradeStoneNotice = BaseUI:new('UIUpgradeStoneNotice');

function UIUpgradeStoneNotice:Create()
	self:AddSWF('UpgradeStoneNotice.swf',true,'bottom')
end

function UIUpgradeStoneNotice:OnLoaded(objSwf)
	objSwf.btn_close.click = function () self:Hide(); end
	objSwf.btn_openVip.click = function () UIVip:Show();self:Hide(); end
	objSwf.item.rollOver = function () TipsManager:ShowItemTips(GiftsConsts.GiftsBoxID); end
	objSwf.item.rollOut = function () TipsManager:Hide(); end
end

function UIUpgradeStoneNotice:OnShow()
	self:DrawItem();
end

function UIUpgradeStoneNotice:DrawItem()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local id = GiftsConsts.GiftsBoxID;
	local cfg = RewardSlotVO:new();
	cfg.id = id;
	objSwf.item:setData(cfg:GetUIData());
	
	local byVip1Cfg = t_vippower[10318];
	if not objSwf then return end
	local zs1UseNum = byVip1Cfg.c_v1;
	objSwf.txt_num.num = zs1UseNum;
	
	local itemCfg = t_item[id];
	if not itemCfg then return end
	objSwf.txt_name.htmlText = string.format(StrConfig['stone005'],TipsConsts:GetItemQualityColor(itemCfg.quality),itemCfg.name);
end

function UIUpgradeStoneNotice:OnHide()
	
end

UIUpgradeStoneNotice.isOpenState = false;
function UIUpgradeStoneNotice:Open()
	if self.isOpenState then return end
	self.isOpenState = true;
	self:Show();
end
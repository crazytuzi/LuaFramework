--[[
每日杀戮属性
2015年3月19日18:14:11
haohu
]]

_G.UIDropValueDetail = BaseUI:new("UIDropValueDetail");

function UIDropValueDetail:Create()
	self:AddSWF("dropValueDetailPanel.swf", true, "center");
end

function UIDropValueDetail:OnLoaded( objSwf )
	objSwf.btnClose.click         = function() self:OnBtnCloseClick(); end
	objSwf.btnSet.click           = function() self:OnBtnSetClick(); end
	objSwf.numLoader.loadComplete = function() self:OnNumLoadComplete(); end
	RewardManager:RegisterListTips(objSwf.list1);
	RewardManager:RegisterListTips(objSwf.list2);
end

function UIDropValueDetail:OnShow()
	self:UpdateShow();
end

function UIDropValueDetail:UpdateShow()
	self:ShowDropDetail();
	self:ShowDrop();
end

function UIDropValueDetail:OnBtnCloseClick()
	self:Hide();
end

function UIDropValueDetail:OnBtnSetClick()
	if UIDropValueSetting:IsShow() then
		UIDropValueSetting:Hide();
	else
		UIDropValueSetting:Show();
	end
end

function UIDropValueDetail:OnNumLoadComplete()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local numLoader = objSwf.numLoader;
	local bg = objSwf.rateBg;
	numLoader._x = bg._x + (bg._width - numLoader._width) * 0.5;
	numLoader._y = bg._y + (bg._height - numLoader._height) * 0.5;
end

function UIDropValueDetail:ShowDropDetail()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local superDropRate = DropValueConsts:GetSuperDrop();
	local vipDrop = DropValueConsts:GetVipDrop();
	local level = DropValueModel:GetDropValueLevel();
	local _, multiple = DropValueConsts:GetDropValueInfo( level );
	local tianCiRate = multiple * DropValueConsts.BasicDropRate;
	local rateTotal = tianCiRate + DropValueConsts.BasicDropRate;
	objSwf.numLoader:drawStr( rateTotal.."e" );
	objSwf.txtDetail.htmlText = string.format( StrConfig['dropValue103'], DropValueConsts.BasicDropRate, superDropRate, vipDrop, tianCiRate );
end

function UIDropValueDetail:ShowDrop()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local items = DropValueModel:GetDropItems();
	-- 超级掉宝
	local list1 = objSwf.list1;
	local list2 = objSwf.list2;
	list1.dataProvider:cleanUp();
	list2.dataProvider:cleanUp();
	local item, vo;
	for i = 1, #items do
		item = items[i];
		vo = RewardSlotVO:new();
		vo.id = item.id;
		vo.count = item.num;
		local cfg = t_equip[vo.id] or t_item[vo.id];
		if cfg then
			vo.bind = cfg.bind or BagConsts.Bind_GetBind;
			if cfg.price >= DropValueConsts.SuperDropPrice then
				 -- 炒鸡碉堡
				list1.dataProvider:push( vo:GetUIData() );
			else
				-- 基础掉宝
				list2.dataProvider:push( vo:GetUIData() );
			end
		end
	end
	list1:invalidateData();
	list2:invalidateData();
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIDropValueDetail:ListNotificationInterests()
	return {
		NotifyConsts.SetDropValueLevel,
		NotifyConsts.DropItemRecord,
	};
end

--处理消息
function UIDropValueDetail:HandleNotification(name, body)
	if name == NotifyConsts.SetDropValueLevel then
		self:ShowDropDetail();
	elseif name == NotifyConsts.DropItemRecord then
		self:ShowDrop();
	end
end

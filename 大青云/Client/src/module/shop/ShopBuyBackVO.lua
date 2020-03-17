--[[
商店回购列表VO
lizhuangzhuang
2014年12月6日16:11:45 
]]

_G.ShopBuyBackVO = {};

ShopBuyBackVO.cid      = nil;
ShopBuyBackVO.tid      = 0;
ShopBuyBackVO.count    = 0;
ShopBuyBackVO.flags    = 0;
ShopBuyBackVO.strenLvl = 0
ShopBuyBackVO.extraLvl = 0
ShopBuyBackVO.superVO  = nil
ShopBuyBackVO.newSuperVO = nil;
ShopBuyBackVO.cfg      = nil

function ShopBuyBackVO:new()
	local obj = {};
	for k,v in pairs(ShopBuyBackVO) do
		obj[k] = v;
	end
	return obj;
end

function ShopBuyBackVO:GetTid()
	return self.tid;
end

--获取显示分类
function ShopBuyBackVO:GetShowType()
	return BagUtil:GetItemShowType(self.tid);
end


function ShopBuyBackVO:GetCount()
	return self.count;
end

--显示数量
function ShopBuyBackVO:GetShowCount()
	if self.count < 10000 then
		return self.count;
	else
		return toint( self.count / 10000, -1 ) .. "W";
	end
end

function ShopBuyBackVO:GetCfg()
	if not self.cfg then
		self.cfg = t_item[self.tid] or t_equip[self.tid];
	end
	return self.cfg
end

--回购价格
function ShopBuyBackVO:GetPrice()
	local cfg = self:GetCfg();
	if not cfg then return 0; end
	return cfg.price * self.count;
end

--获取绑定状态
function ShopBuyBackVO:GetBind()
	if bit.band(self.flags,BagItem.Flag_Bind) == BagItem.Flag_Bind then
		return BagConsts.Bind_Bind;
	else
		local cfg = self:GetCfg();
		if cfg then
			return cfg.bind;
		end
	end
	return BagConsts.Bind_None;
end

--获取是否显示绑定图标
function ShopBuyBackVO:GetShowBind()
	local bind = self:GetBind();
	return bind == BagConsts.Bind_GetBind or bind == BagConsts.Bind_Bind;
end

--获取图标
function ShopBuyBackVO:GetIcon(size)
	if t_equip[self.tid] then
		return ResUtil:GetItemIconUrl(t_equip[self.tid].icon,size);
	elseif t_item[self.tid] then
		return ResUtil:GetItemIconUrl(t_item[self.tid].icon,size);
	end
	return "";
end

--获取品质
function ShopBuyBackVO:GetQualityUrl(isSmall)
	local cfg = t_equip[self.tid];
	if not cfg then
		cfg = t_item[self.tid];
	end
	if not cfg then return ""; end
	return ResUtil:GetSlotQuality(cfg.quality,isSmall and nil or 54);
end

--获取品质
function ShopBuyBackVO:GetQuality()
	if t_equip[self.tid] then
		return t_equip[self.tid].quality;
	end
	if t_item[self.tid] then
		return t_item[self.tid].quality;
	end
	return 0;
end

--(是装备时)强化等级
function ShopBuyBackVO:GetStrenLvl()
	return self.strenLvl
end

--(是装备时)追加等级
function ShopBuyBackVO:GetExtraLvl()
	return self.extraLvl
end

--(是装备时)卓越属性
function ShopBuyBackVO:GetSuperVO()
	return self.superVO
end

--(是装备时)新卓越属性
function ShopBuyBackVO:GetNewSuperList()
	return self.newSuperList;
end

function ShopBuyBackVO:GetUIData()
	return self:GetItemUIData() .."*".. self:GetIconUIData();
end

function ShopBuyBackVO:GetItemUIData()
	local data = {};
	data.cid = self.cid;
	data.itemName = ShopUtils:GetItemNameById(self.tid);
	data.nameColor = ShopUtils:GetItemQualityColor(self.tid);
	data.iconMoneyURL = ResUtil:GetMoneyIconURL(enAttrType.eaBindGold);
	data.price = self:GetPrice();
	return UIData.encode(data);
end

--获取编码后的UI数据
function ShopBuyBackVO:GetIconUIData()
	local data = {};
	data.id            = self:GetTid();
	data.count         = self:GetCount();
	data.showCount     = self:GetShowCount();
	data.iconUrl       = self:GetIcon();
	data.bigIconUrl    = self:GetIcon("54");
	data.bind          = self:GetBind();
	data.showBind      = self:GetShowBind();
	data.quality       = self:GetQuality();
	data.qualityUrl    = self:GetQualityUrl(true);
	data.bigQualityUrl = self:GetQualityUrl();
	data.strenLvl      = self:GetStrenLvl();
	data.extraLvl      = self:GetExtraLvl();
	return UIData.encode(data);
end

--获取物品的TipsVO
function ShopBuyBackVO:GetTipsVO()
	local tipsVO = ItemTipsUtil:GetItemTipsVO(self:GetTid(),self:GetCount());
	if not tipsVO then return; end
	tipsVO.bindState   = self:GetBind();
	if self:GetShowType() == BagConsts.ShowType_Equip then
		tipsVO.strenLvl = self:GetStrenLvl();
		tipsVO.extraLvl = self:GetExtraLvl();--追加等级
		tipsVO.superVO  = self:GetSuperVO();--卓越属性
		tipsVO.newSuperList = self:GetNewSuperList();--新卓越属性

		local equipInfo = SmithingModel:GetEquipByPos(self:GetCfg().pos)
		if equipInfo then
			tipsVO.gemList = equipInfo.gems;
		end
	end
	--是否对比显示
	tipsVO.tipsShowType = TipsConsts.ShowType_Normal;
	return tipsVO;
end
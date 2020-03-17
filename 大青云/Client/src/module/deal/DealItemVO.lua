--[[
交易物品VO
2015年3月30日20:42:51
haohu
]]

_G.DealItemVO = {};

DealItemVO.pos        = nil; -- 格子号
DealItemVO.tid        = nil; -- 物品id
DealItemVO.count      = nil; -- 物品数量
DealItemVO.strenLvl   = nil; -- 强化等级
DealItemVO.strenVal   = nil; -- 强化值
DealItemVO.attrAddLvl = nil; -- 追加属性等级
DealItemVO.groupId 	  = nil; -- 套装id
DealItemVO.groupId2   = nil; -- 套装id2
DealItemVO.group2Level   = nil; -- 套装id2等级
DealItemVO.superNum   = nil; -- 卓越数量
DealItemVO.superList  = nil; -- 卓越属性列表
DealItemVO.newSuperList = nil;--新卓越属性

DealItemVO.hasItem    = nil;

function DealItemVO:new(pos)
	local vo = {};
	for k, v in pairs(self) do
		if type(v) == "function" then
			vo[k] = v;
		end
	end
	vo.pos = pos;
	vo:Clear();
	return vo;
end

function DealItemVO:Clear()
	self.tid        = 0;
	self.count      = 0;
	self.strenLvl   = 0;
	self.strenVal   = 0;
	self.attrAddLvl = 0;
	self.groupId 	= 0;
	self.groupId2 	= 0;
	self.group2Level 	= 0;
	self.superNum   = 0;
	self.superList  = {};
	self.newSuperList = nil;
	self.hasItem    = false;
end

 --vo.tid, vo.count, vo.strenLvl, vo.strenVal, vo.attrAddLvl, vo.gropuId vo.groupId2 vo.group2Level,
 --vo.superNum, vo.superList, vo.newSuperList
function DealItemVO:InitByVO( vo )
	for k, v in pairs(vo) do
		self[k] = v;
	end
	self.hasItem = true;
end

function DealItemVO:GetPos()
	return self.pos;
end

function DealItemVO:GetTid()
	return self.tid;
end

function DealItemVO:GetName()
	if not self.hasItem then return "" end
	local cfg = self:GetCfg();
	return cfg and cfg.name or "";
end

--获取显示分类
function DealItemVO:GetShowType()
	return BagUtil:GetItemShowType(self.tid);
end

function DealItemVO:GetCount()
	return self.count;
end

--显示数量
function DealItemVO:GetShowCount()
	if self.count < 10000 then
		return self.count;
	else
		return toint( self.count / 10000, -1 ) .. "W";
	end
end

function DealItemVO:GetCfg()
	local cfg = t_item[self.tid] or t_equip[self.tid]
	if not cfg then
		print("cannot find deal item config: ".. tostring(self.tid))
	end
	return cfg
end

--价格
function DealItemVO:GetPrice()
	local cfg = self:GetCfg();
	if not cfg then return 0; end
	return cfg.price * self.count;
end

--获取绑定状态
function DealItemVO:GetBind()
	return BagConsts.Bind_None;
end

--获取是否显示绑定图标
function DealItemVO:GetShowBind()
	return false;
end

--获取图标
function DealItemVO:GetIcon(size)
	local cfg = self:GetCfg();
	return cfg and ResUtil:GetItemIconUrl( cfg.icon, size ) or "";
end

--获取品质
function DealItemVO:GetQualityUrl(isSmall)
	local cfg = t_equip[self.tid];
	if not cfg then
		cfg = t_item[self.tid];
	end
	if not cfg then return ""; end
	return ResUtil:GetSlotQuality( cfg.quality, isSmall and 54 or nil );
end

--获取品质
function DealItemVO:GetQuality()
	if t_equip[self.tid] then
		return t_equip[self.tid].quality;
	end
	if t_item[self.tid] then
		return t_item[self.tid].quality;
	end
	return 0;
end

function DealItemVO:GetQualityColor()
	local cfg = self:GetCfg();
	local quality = cfg and cfg.quality;
	return quality and TipsConsts:GetItemQualityColorVal(quality);
end

--(是装备时)强化等级
function DealItemVO:GetStrenLvl()
	return self.strenLvl or 0;
end

--(是装备时)追加等级
function DealItemVO:GetExtraLvl()
	return self.extraLvl or 0;
end

--(是装备时)套装id
function DealItemVO:GetGroupId()
	return self.groupId or 0;
end

--(是新装备时)套装id2
function DealItemVO:GetGroupId2()
	return self.groupId2 or 0;
end

--(是新装备时)套装id2等级
function DealItemVO:GetGroupId2Level()
	return self.group2Level or 0
end

--(是装备时)卓越属性
function DealItemVO:GetSuperVO()
	local superVO = {};
	superVO.superNum  = self.superNum;
	superVO.superList = self.superList;
	return superVO;
end

--(是道具时)卓越属性
function DealItemVO:GetItemSuperVO()
	if not self.superList then
		return nil;
	end
	if self.superList[1].id == 0 then
		return nil;
	end
	return self.superList[1];
end


--获取拖拽类型
function DealItemVO:GetDragType()
	return 1;
end

--获取接受的拖入类型
function DealItemVO:GetDragAcceptType()
	return BagConsts.AllDragType;
end

function DealItemVO:GetUIData()
	return self:GetItemUIData() .. "*" .. self:GetIconUIData();
end

function DealItemVO:GetItemUIData()
	local data = {};
	data.itemName  = self:GetName();
	data.nameColor = self:GetQualityColor();
	data.pos       = self:GetPos();
	data.hasItem   = self.hasItem;
	return UIData.encode(data);
end

--获取编码后的UI数据
function DealItemVO:GetIconUIData()
	local data = {};
	data.pos         = self:GetPos();
	data.tid         = self:GetTid();
	data.dragType    = self:GetDragType();
	local acceptType = self:GetDragAcceptType();
	data.acceptType  = table.concat(acceptType, ",");
	data.hasItem     = self.hasItem
	data.iconUrl     = self:GetIcon();
	data.qualityUrl  = self:GetQualityUrl(true);
	data.showCount   = self:GetShowCount();
	data.count       = self:GetCount();
	data.quality     = self:GetQuality();
	data.strenLvl    = self:GetStrenLvl();
	-- if self.hasItem then
	-- 	trace("图标中村的数据")
	-- 	trace(data);
	-- 	trace("vo数据")
	-- 	trace(self);
	-- end
	return UIData.encode(data);
end

--获取物品的TipsVO
function DealItemVO:GetTipsVO()
	local cfg = self:GetCfg()
	if not cfg then return end
	local tipsVO = ItemTipsUtil:GetItemTipsVO(self:GetTid(),self:GetCount())
	if not tipsVO then return; end
	if self:GetShowType() == BagConsts.ShowType_Equip then
		tipsVO.strenLvl = self:GetStrenLvl();
		tipsVO.extraLvl = self:GetExtraLvl();--追加等级
		tipsVO.superVO  = self:GetSuperVO();--卓越属性
		tipsVO.groupId = self:GetGroupId();
		tipsVO.groupId2 = self:GetGroupId2();
		tipsVO.groupId2Level = self:GetGroupId2Level();
		tipsVO.newSuperList = self.newSuperList;

		local equipInfo = SmithingModel:GetEquipByPos(cfg.pos)
		if equipInfo then
			tipsVO.gemList = equipInfo.gems;
		end
	else
		tipsVO.itemSuperVO = self:GetItemSuperVO();
		if BagUtil:IsWing(self:GetTid()) then
			tipsVO.wingTime = self.strenLvl;
			tipsVO.wingAttrFlag = self.strenVal==1;
		end
	end
	--是否对比显示
	tipsVO.tipsShowType = TipsConsts.ShowType_Normal;
	return tipsVO;
end
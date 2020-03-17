--[[
背包的公用方法
lizhuangzhuang
2014年7月31日21:24:16
]]

_G.BagUtil = {};

--获取装备是否可穿戴
function BagUtil:GetEquipCanUse(id)
	local cfg = t_equip[id];
	if not cfg then
		return BagConsts.Error_Use;
	end
	if cfg.can_use then--true为不可穿
		return BagConsts.Error_Equip;
	end
	local info = MainPlayerModel.humanDetailInfo;
	if cfg.sex~=2 and cfg.sex~=info.eaSex then
		return BagConsts.Error_Sex;
	end
	if cfg.vocation~=0 and cfg.vocation~=info.eaProf then
		return BagConsts.Error_Prof;
	end
	-- if cfg.needlevel>info.eaRealmLvl then
	-- 	return BagConsts.Error_RealmLevel;
	-- end
	if cfg.pos>=BagConsts.Equip_H_AnJu and cfg.pos<=BagConsts.Equip_H_DengJu and cfg.step>0 then
		local horseLvl = MountModel:GetMountLvl();
		if horseLvl < cfg.step then
			return BagConsts.Error_HorseLevel;
		end
	end
	if cfg.pos>=BagConsts.Equip_L_XiangQuan and cfg.pos<=BagConsts.Equip_L_TouShi and cfg.step>0 then
		local lingShouLvl = SpiritsModel:GetLevel();
		if lingShouLvl < cfg.step then
			return BagConsts.Error_LingShouLevel;
		end
	end
	if cfg.pos>=BagConsts.Equip_LH_ZhuangJiao and cfg.pos<=BagConsts.Equip_LH_XiongJia and cfg.step>0 then
		local horseLingShouLvl = MountLingShouModel:GetMountLvl();
		if horseLingShouLvl - MountConsts.LingShouSpecailDownid < cfg.step then
			return BagConsts.Error_HorseLingShouLevel;
		end
	end
	if cfg.pos>=BagConsts.Equip_QZ_ZhenYan0 and cfg.pos<=BagConsts.Equip_QZ_ZhenYan8 and cfg.step>0 then
		local qizhanLvl = QiZhanModel:GetQZLevel();
		if qizhanLvl < cfg.step then
			return BagConsts.Error_QiZhanLevel;
		end
	end
	-- if cfg.pos>=BagConsts.Equip_SL_ZhenYan0 and cfg.pos<=BagConsts.Equip_SL_ZhenYan8 and cfg.step>0 then
	-- 	local qizhanLvl = ShenLingModel:GetLevel();
	-- 	if qizhanLvl < cfg.step then
	-- 		return BagConsts.Error_ShenLingLevel;
	-- 	end
	-- end
	if cfg.pos>=BagConsts.Equip_SB_0 and cfg.pos<=BagConsts.Equip_SB_3 and cfg.step>0 then
		local lv = MagicWeaponModel:GetLevel();
		if lv < cfg.step then
			return BagConsts.Error_MagicWeaponLevel;
		end
	end
	if cfg.pos>=BagConsts.Equip_LQ_0 and cfg.pos<=BagConsts.Equip_LQ_3 and cfg.step>0 then
		local lv = LingQiModel:GetLevel();
		if lv < cfg.step then
			return BagConsts.Error_LingQiLevel;
		end
	end
	if cfg.pos>=BagConsts.Equip_MY_0 and cfg.pos<=BagConsts.Equip_MY_3 and cfg.step>0 then
		local lv = MingYuModel:GetLevel();
		if lv < cfg.step then
			return BagConsts.Error_MingYuLevel;
		end
	end
	if cfg.pos>=BagConsts.Equip_BJ_0 and cfg.pos<=BagConsts.Equip_BJ_3 and cfg.step>0 then
		local lv = ArmorModel:GetLevel();
		if lv < cfg.step then
			return BagConsts.Error_ArmorLevel;
		end
	end
	return 1;
end

--获取物品是否可使用
function BagUtil:GetItemCanUse(id)
	local cfg = t_item[id];
	if not cfg then
		return BagConsts.Error_Use;
	end
	if not cfg.cuse then
		return BagConsts.Error_Use;
	end
	local info = MainPlayerModel.humanDetailInfo;
	if cfg.sex~=2 and cfg.sex~=info.eaSex then
		return BagConsts.Error_Sex;
	end
	if cfg.vocation~=0 and cfg.vocation~=info.eaProf then
		return BagConsts.Error_Prof;
	end
	--翅膀是境界等级,其余是人物等级
	-- if cfg.sub == BagConsts.SubT_Wing then
	-- 	-- if cfg.needlevel>info.eaRealmLvl then
	-- 	-- 	return BagConsts.Error_RealmLevel;
	-- 	-- end
	-- else
		if cfg.needlevel>info.eaLevel then
			return BagConsts.Error_Level;
		end
	-- end
	if BagModel:GetItemCD(id) > 0 then
		return BagConsts.Error_CD;
	end
	return 1;
end

--判断物品的使用等级
--物品:人物等级,坐骑:坐骑等级,装备:人物境界
function BagUtil:GetNeedLevel(tid)
	local cfg = t_equip[tid];
	if cfg then
		if cfg.pos>=BagConsts.Equip_H_AnJu and cfg.pos<=BagConsts.Equip_H_DengJu then
			return cfg.step;
		end
		if cfg.pos>=BagConsts.Equip_L_XiangQuan and cfg.pos<=BagConsts.Equip_L_TouShi then
			return cfg.step;
		end
		if cfg.pos>=BagConsts.Equip_LH_ZhuangJiao and cfg.pos<=BagConsts.Equip_LH_XiongJia then
			return cfg.step;
		end
		if cfg.pos>=BagConsts.Equip_LZ_ZhenYan0 and cfg.pos<=BagConsts.Equip_LZ_ZhenYan8 then
			return cfg.step;
		end
		if cfg.pos>=BagConsts.Equip_QZ_ZhenYan0 and cfg.pos<=BagConsts.Equip_QZ_ZhenYan8 then
			return cfg.step;
		end
		if cfg.pos>=BagConsts.Equip_SL_ZhenYan0 and cfg.pos<=BagConsts.Equip_SL_ZhenYan8 then
			return cfg.step;
		end
		return cfg.needlevel;
	end
	cfg = t_item[tid];
	if cfg then
		return cfg.needlevel;
	end
	return 0;
end

function BagUtil:GetNeedAttrOne(tid)
	local cfg = t_equip[tid];
	if cfg then
		local name ={}
		local value ={};
		local attList = split(cfg.need_attr,"#");
		if #attList >= 1 then
			name = split(attList[1],',')[1]
			value = toint(split(attList[1],',')[2])
			return name..'#'..value;
		end
	end
	return 0;
end

---获取物品的基础属性
function BagUtil:GetNeedAttr(tid)
	local cfg = t_equip[tid];
	if cfg then
		local name ={}
		local value ={};
		local attList ={};
		if cfg.astrict and cfg.astrict == 1 then      --该装备转生限制
			name = toint(cfg.astrict)
			value = toint(cfg.needlv)
			return name..'#'..value;
		end

		if cfg.astrict and cfg.astrict == 2 then  --改装备属性限制
			local attList = split(cfg.need_attr,"#");
			if #attList == 2 then
				name = split(attList[2],',')[1]
				value = toint(split(attList[2],',')[2])
				return name..'#'..value;
			else
				-- 留出其他扩展接口
			end
		end
	end
	return 0;
end

--判断装备是否可使用(取玩家信息)
----物品:人物等级,坐骑:坐骑等级,装备:人物境界
function BagUtil:GetLevelAccord(tid)
	local playerInfo = MainPlayerModel.humanDetailInfo;
	local cfg = t_equip[tid];
	if cfg then
		if cfg.pos>=BagConsts.Equip_H_AnJu and cfg.pos<=BagConsts.Equip_H_DengJu then
			return MountModel:GetMountLvl() >= BagUtil:GetNeedLevel(tid);
		elseif cfg.pos>=BagConsts.Equip_L_XiangQuan and cfg.pos<=BagConsts.Equip_L_TouShi then
			return SpiritsModel:GetLevel() >= BagUtil:GetNeedLevel(tid);
		elseif cfg.pos>=BagConsts.Equip_LH_ZhuangJiao and cfg.pos<=BagConsts.Equip_LH_XiongJia then
			return MountLingShouModel:GetMountLvl() - MountConsts.LingShouSpecailDownid >= BagUtil:GetNeedLevel(tid);
		elseif cfg.pos>=BagConsts.Equip_QZ_ZhenYan0 and cfg.pos<=BagConsts.Equip_QZ_ZhenYan8 then
			return QiZhanModel:GetQZLevel() >= BagUtil:GetNeedLevel(tid);
		-- elseif cfg.pos>=BagConsts.Equip_SL_ZhenYan0 and cfg.pos<=BagConsts.Equip_SL_ZhenYan8 then
		-- 	return ShenLingModel:GetLevel() >= BagUtil:GetNeedLevel(tid);
		elseif cfg.pos>=BagConsts.Equip_SB_Hun0 and cfg.pos<=BagConsts.Equip_SB_Hun8 then
			return MagicWeaponModel:GetLevel() >= BagUtil:GetNeedLevel(tid);
		else
			return playerInfo.eaLevel >= BagUtil:GetNeedLevel(tid);
		end
	end
	cfg = t_item[tid];
	if cfg then
		return playerInfo.eaLevel >= BagUtil:GetNeedLevel(tid);
	end
	return false;
end

--获取装备要放入的背包和格子号
function BagUtil:GetEquipPutBagPos(id)
	local equipConfig = t_equip[id];
	if not equipConfig then
		return -1,-1;
	end
	if equipConfig.pos>=BagConsts.Equip_WuQi and equipConfig.pos<=BagConsts.Equip_ShiZhuang then
		return BagConsts.BagType_Role,equipConfig.pos;
	end
	if equipConfig.pos>=BagConsts.Equip_H_AnJu and equipConfig.pos<=BagConsts.Equip_H_DengJu then
		return BagConsts.BagType_Horse,equipConfig.pos-BagConsts.Equip_H_AnJu;
	end
	if equipConfig.pos>=BagConsts.Equip_L_XiangQuan and equipConfig.pos<=BagConsts.Equip_L_TouShi then
		return BagConsts.BagType_LingShou,equipConfig.pos-BagConsts.Equip_L_XiangQuan;
	end
	if equipConfig.pos>=BagConsts.Equip_LH_ZhuangJiao and equipConfig.pos<=BagConsts.Equip_LH_XiongJia then
		return BagConsts.BagType_LingShouHorse,equipConfig.pos-BagConsts.Equip_LH_ZhuangJiao;
	end
	if equipConfig.pos>=BagConsts.Equip_LZ_ZhenYan0 and equipConfig.pos<=BagConsts.Equip_LZ_ZhenYan8 then
		return BagConsts.BagType_LingZhenZhenYan,equipConfig.pos-BagConsts.Equip_LZ_ZhenYan0;
	end
	if equipConfig.pos>=BagConsts.Equip_QZ_ZhenYan0 and equipConfig.pos<=BagConsts.Equip_QZ_ZhenYan8 then
		return BagConsts.BagType_QiZhan,equipConfig.pos-BagConsts.Equip_QZ_ZhenYan0;
	end
	-- if equipConfig.pos>=BagConsts.Equip_SL_ZhenYan0 and equipConfig.pos<=BagConsts.Equip_SL_ZhenYan8 then
	-- 	return BagConsts.BagType_ShenLing,equipConfig.pos-BagConsts.Equip_SL_ZhenYan0;
	-- end
	if equipConfig.pos>=BagConsts.Equip_MY_0 and equipConfig.pos<=BagConsts.Equip_MY_3 then
		return BagConsts.BagType_MingYu,equipConfig.pos-BagConsts.Equip_MY_0;
	end
	if equipConfig.pos>=BagConsts.Equip_BJ_0 and equipConfig.pos<=BagConsts.Equip_BJ_3 then
		return BagConsts.BagType_Armor,equipConfig.pos-BagConsts.Equip_BJ_0;
	end
	if equipConfig.pos>=BagConsts.Equip_SB_0 and equipConfig.pos<=BagConsts.Equip_SB_3 then
		return BagConsts.BagType_MagicWeapon,equipConfig.pos-BagConsts.Equip_SB_0;
	end
	if equipConfig.pos>=BagConsts.Equip_LQ_0 and equipConfig.pos<=BagConsts.Equip_LQ_3 then
		return BagConsts.BagType_LingQi,equipConfig.pos-BagConsts.Equip_LQ_0;
	end
	return -1,-1;
end

--获取装备类型
function BagUtil:GetEquipType(id)
	local equipConfig = t_equip[id];
	if not equipConfig then
		return -1;
	end
	return equipConfig.pos;
end

--根据背包格子获取装备类型
function BagUtil:GetEquipAtBagPos(bagType,pos)
	if bagType == BagConsts.BagType_Role then
		return pos;
	end
	if bagType == BagConsts.BagType_Horse then
		return BagConsts.Equip_H_AnJu+pos;
	end
	if bagType == BagConsts.BagType_LingShou then
		return BagConsts.Equip_L_XiangQuan+pos;
	end
	if bagType == BagConsts.BagType_LingShouHorse then
		return BagConsts.Equip_LH_ZhuangJiao+pos;
	end
	if bagType == BagConsts.BagType_LingZhenZhenYan then
		return BagConsts.Equip_LZ_ZhenYan0+pos;
	end
	if bagType == BagConsts.BagType_QiZhan then
		return BagConsts.Equip_QZ_ZhenYan0+pos;
	end
	-- if bagType == BagConsts.BagType_ShenLing then
	-- 	return BagConsts.Equip_SL_ZhenYan0+pos;
	-- end
	if bagType == BagConsts.BagType_MingYu then
		return BagConsts.Equip_MY_0+pos;
	end
	if bagType == BagConsts.BagType_Armor then
		return BagConsts.Equip_BJ_0+pos;
	end
	if bagType == BagConsts.BagType_MagicWeapon then
		return BagConsts.Equip_SB_0+pos;
	end
	if bagType == BagConsts.BagType_LingQi then
		return BagConsts.Equip_LQ_0+pos;
	end
	if bagType == BagConsts.BagType_RELIC then
		return BagConsts.Equip_Relic_0 + pos
	end
	return -1;
end

-- 获取圣物装备位
function BagUtil:GetRelicPos(id)
	for k, v in pairs(t_newequip) do
		if v.itemid == id then
			return v.part
		end
	end
end

-- 获取圣器id
function BagUtil:GetRelicId(id)
	for k, v in pairs(t_newequip) do
		if v.itemid == id and v.lv == 1 then
			return v.id
		end
	end
end

--是否是翅膀
function BagUtil:IsWing(id)
	local cfg = t_item[id];
	if not cfg then return false; end
	return cfg.sub == BagConsts.SubT_Wing;
end
--是否戒指
function BagUtil:IsRing(id)
	local cfg = t_item[id];
	if not cfg then return false; end
	return cfg.sub == BagConsts.SubT_Ring;
end;

--是否是圣物
function BagUtil:IsRelic(id)
	local cfg = t_item[id]
	if not cfg then return false end
	return cfg.sub == BagConsts.SubT_Relic
end

--是否是天神卡
function BagUtil:IsTianshenKa(id)
	local cfg = t_item[id]
	if not cfg then return false end
	return cfg.sub == BagConsts.SubT_Tianshenka
end

function BagUtil:IsItemFashion(id)
	local cfg = t_item[id];
	if not cfg then return false; end
	return cfg.fashion ~= 0
end

--获取物品的显示类型
function BagUtil:GetItemShowType(id)
	local str = tostring(id);
	if id>9999 and str:lead("2") then
		return BagConsts.ShowType_Equip;
	end
	local itemConfig = t_item[id];
	if not itemConfig then
		return;
	end
	if itemConfig.main == 1 then
		return BagConsts.ShowType_Consum;
	elseif itemConfig.main == 2 then
		return BagConsts.ShowType_Task;
	else
		return BagConsts.ShowType_Other;
	end
end

--获取物品图标
function BagUtil:GetItemIcon(id,big)
	local size = "";
	if big then
		size = "54";
	end
	local defaultIcon = "img://resfile/itemicon/default.png";
	if BagUtil:GetItemShowType(id) == BagConsts.ShowType_Equip then
		local equipConfig = t_equip[id];
		if not equipConfig then return defaultIcon; end
		return ResUtil:GetItemIconUrl(equipConfig.icon,size);
	end
	local itemConfig = t_item[id];
	if not itemConfig then return defaultIcon; end
	return ResUtil:GetItemIconUrl(itemConfig.icon,size);
end

--- 获取主界面装备图标
function BagUtil:GetEquipIcon(id)
	local defaultIcon = "img://resfile/itemicon/default.png";
	local equipConfig = t_equip[id];
	if not equipConfig then return defaultIcon; end
	return ResUtil:GetItemIconUrl(equipConfig.iconbig, "");
end

--获取物品标识
function BagUtil:GetItemBiaoShiUrl(id, size)
	if t_item[id] then 
		local str = t_item[id].identifying
		return ResUtil:GetBiaoShiUrl(str, size) 
	elseif t_equip[id] then 
		local str = t_equip[id].identifying
		return ResUtil:GetBiaoShiUrl(str, size) 
	end;
	return ""
end;

--根据分类获取背包内物品列表
function BagUtil:GetBagItemList(bagType,showType)
	local bagVO = BagModel:GetBag(bagType);
	if not bagVO then return; end;
	local bagTotalSize = bagVO:GetTotalSize();
	local bagOpenSize = bagVO:GetSize();
	local list = {};
	local itemlist = nil;--显示分类时的Item列表
	if showType ~= BagConsts.ShowType_All then
		itemlist = bagVO:GetItemListByShowType(showType);
	end
	for i=1,bagTotalSize do
		local slotVO = BagSlotVO:new();
		slotVO.bagType = bagType;
		slotVO.uiPos = i;
		slotVO.pos = i-1;
		if i<= bagOpenSize then--格子是否开启
			slotVO.opened = true;
			--如果是all,按格子逻辑排列
			if showType == BagConsts.ShowType_All then
				local item = bagVO:GetItemByPos(slotVO.pos);
				if item then--格子上有东西
					slotVO.hasItem = true;
					slotVO.id = item:GetId();
					slotVO.tid = item:GetTid();
					if BagUtil:IsRelic(item:GetTid()) then
						slotVO.relicLv = item:GetParam()
					end
					slotVO.count = item:GetCount();
					slotVO.bindState = item:GetBindState();
					slotVO.flags = item.flags;
				else
					slotVO.hasItem = false;
				end
			else
				--分类显示的话,按照all中顺序依次排列
				local item = itemlist[i];
				if item then
					slotVO.hasItem = true;
					slotVO.pos = item:GetPos();--重置逻辑格子
					if BagUtil:IsRelic(item:GetTid()) then
						slotVO.relicLv = item:GetParam()
					end
					slotVO.id = item:GetId();
					slotVO.tid = item:GetTid();
					slotVO.count = item:GetCount();
					slotVO.bindState = item:GetBindState();
					slotVO.flags = item.flags;
				else
					slotVO.hasItem = false;
					slotVO.pos = -1;
				end
			end
		else
			slotVO.opened = false;
		end
		table.push(list,slotVO);
	end
	return list;
end

--获取该装备位类型的装备列表
function BagUtil:GetListByEquipType(bagType,equippos)
	local bagVO = BagModel:GetBag(bagType);
	if not bagVO then return; end;
	local isHasEquip = false;
	local list = {};
	for i,item in pairs(bagVO.itemlist) do
		if item:GetShowType()==BagConsts.ShowType_Equip and item:GetCfg().pos==equippos then
			local playerinfo = MainPlayerModel.humanDetailInfo;
			if  t_equip[item:GetTid()].vocation == 0 or t_equip[item:GetTid()].vocation == playerinfo.eaProf then
				isHasEquip = true;
				local slotVO = BagSlotVO:new();
				slotVO.pos = item:GetPos();
				slotVO.bagType = BagConsts.ShowType_Equip;
				slotVO.opened = true;
				slotVO.hasItem = true;
				slotVO.tid = item:GetTid();
				if BagUtil:IsRelic(item:GetTid()) then
					slotVO.relicLv = item:GetParam()
				end
				slotVO.strenLvl = EquipModel:GetStrenLvl(item:GetId());
				table.push(list,slotVO);
			end
		end
	end
	--补全n个
	local last = 0;
	if #list == 0 then
		last = BagConsts.Equip_Quick_Count;
	else
		if #list%BagConsts.Equip_Quick_Count > 0 then
			last = BagConsts.Equip_Quick_Count - #list%BagConsts.Equip_Quick_Count;
		end
	end
	for i=1,last do
		local slotVO = BagSlotVO:new();
		slotVO.bagType = BagConsts.ShowType_Equip;
		slotVO.opened = true;
		slotVO.hasItem = false;
		table.push(list,slotVO);
	end
	return list, isHasEquip;
end

--获取神兵兵魂的装备列表
function BagUtil:GetHunListByEquipType(bagType)
	local bagVO = BagModel:GetBag(bagType);
	if not bagVO then return; end;
	local list = {};
	for i,item in pairs(bagVO.itemlist) do
		if item:GetShowType()==BagConsts.ShowType_Equip and item:GetCfg().pos>=BagConsts.Equip_SB_Hun0 and item:GetCfg().pos<=BagConsts.Equip_SB_Hun8 then
			local playerinfo = MainPlayerModel.humanDetailInfo;
			if  t_equip[item:GetTid()].vocation == 0 or t_equip[item:GetTid()].vocation == playerinfo.eaProf then
				local slotVO = BagSlotVO:new();
				slotVO.pos = item:GetPos();
				slotVO.bagType = BagConsts.ShowType_Equip;
				slotVO.opened = true;
				slotVO.hasItem = true;
				slotVO.tid = item:GetTid();
				slotVO.strenLvl = EquipModel:GetStrenLvl(item:GetId());
				table.push(list,slotVO);
			end
		end
	end
	--补全n个
	local last = 0;
	if #list == 0 then
		last = MagicWeaponConsts.SlotTotalNum;
	else
		if #list%MagicWeaponConsts.SlotTotalNum > 0 then
			last = MagicWeaponConsts.SlotTotalNum - #list%MagicWeaponConsts.SlotTotalNum;
		end
	end
	for i=1,last do
		local slotVO = BagSlotVO:new();
		slotVO.bagType = BagConsts.ShowType_Equip;
		slotVO.opened = true;
		slotVO.hasItem = false;
		table.push(list,slotVO);
	end
	return list;
end

--获取骑印的装备列表
function BagUtil:GetQiYinListByEquipType(bagType)
	local bagVO = BagModel:GetBag(bagType);
	if not bagVO then return; end;
	local list = {};
	for i,item in pairs(bagVO.itemlist) do
		if item:GetShowType()==BagConsts.ShowType_Equip and item:GetCfg().pos>=BagConsts.Equip_QZ_ZhenYan0 and item:GetCfg().pos<=BagConsts.Equip_QZ_ZhenYan8 then
			local playerinfo = MainPlayerModel.humanDetailInfo;
			if  t_equip[item:GetTid()].vocation == 0 or t_equip[item:GetTid()].vocation == playerinfo.eaProf then
				local slotVO = BagSlotVO:new();
				slotVO.pos = item:GetPos();
				slotVO.bagType = BagConsts.ShowType_Equip;
				slotVO.opened = true;
				slotVO.hasItem = true;
				slotVO.tid = item:GetTid();
				slotVO.strenLvl = EquipModel:GetStrenLvl(item:GetId());
				table.push(list,slotVO);
			end
		end
	end
	--补全n个
	local last = 0;
	if #list == 0 then
		last = QiZhanConsts.SlotTotalNum;
	else
		if #list%QiZhanConsts.SlotTotalNum > 0 then
			last = QiZhanConsts.SlotTotalNum - #list%QiZhanConsts.SlotTotalNum;
		end
	end
	for i=1,last do
		local slotVO = BagSlotVO:new();
		slotVO.bagType = BagConsts.ShowType_Equip;
		slotVO.opened = true;
		slotVO.hasItem = false;
		table.push(list,slotVO);
	end
	return list;
end

-- --获取神灵的装备列表
-- function BagUtil:GetShenLingListByEquipType(bagType)
-- 	local bagVO = BagModel:GetBag(bagType);
-- 	if not bagVO then return; end;
-- 	local list = {};
-- 	for i,item in pairs(bagVO.itemlist) do
-- 		if item:GetShowType()==BagConsts.ShowType_Equip and item:GetCfg().pos>=BagConsts.Equip_SL_ZhenYan0 and item:GetCfg().pos<=BagConsts.Equip_SL_ZhenYan8 then
-- 			local playerinfo = MainPlayerModel.humanDetailInfo;
-- 			if  t_equip[item:GetTid()].vocation == 0 or t_equip[item:GetTid()].vocation == playerinfo.eaProf then
-- 				local slotVO = BagSlotVO:new();
-- 				slotVO.pos = item:GetPos();
-- 				slotVO.bagType = BagConsts.ShowType_Equip;
-- 				slotVO.opened = true;
-- 				slotVO.hasItem = true;
-- 				slotVO.tid = item:GetTid();
-- 				slotVO.strenLvl = EquipModel:GetStrenLvl(item:GetId());
-- 				table.push(list,slotVO);
-- 			end
-- 		end
-- 	end
-- 	--补全n个
-- 	local last = 0;
-- 	if #list == 0 then
-- 		last = QiZhanConsts.SlotTotalNum;
-- 	else
-- 		if #list%QiZhanConsts.SlotTotalNum > 0 then
-- 			last = QiZhanConsts.SlotTotalNum - #list%QiZhanConsts.SlotTotalNum;
-- 		end
-- 	end
-- 	for i=1,last do
-- 		local slotVO = BagSlotVO:new();
-- 		slotVO.bagType = BagConsts.ShowType_Equip;
-- 		slotVO.opened = true;
-- 		slotVO.hasItem = false;
-- 		table.push(list,slotVO);
-- 	end
-- 	return list;
-- end

--根据物品子类获取物品列表
function BagUtil:GetItemListBySub(bagType,subType)
	local bagVO = BagModel:GetBag(bagType);
	if not bagVO then return; end;
	local isHasEquip = false;
	local list = {};
	for i,item in pairs(bagVO.itemlist) do
		if item:GetShowType()~=BagConsts.ShowType_Equip and item:GetCfg().sub==subType then
			isHasEquip = true;
			local slotVO = BagSlotVO:new();
			slotVO.pos = item:GetPos();
			slotVO.bagType = BagConsts.ShowType_Equip;
			slotVO.hasItem = true;
			slotVO.tid = item:GetTid();
			if BagUtil:IsRelic(item:GetTid()) then
				slotVO.relicLv = item:GetParam()
			end
			slotVO.strenLvl = EquipModel:GetStrenLvl(item:GetId());
			table.push(list,slotVO);
		end
	end
	--补全n个
	local last = 0;
	if #list == 0 then
		last = BagConsts.Equip_Quick_Count;
	else
		if #list%BagConsts.Equip_Quick_Count > 0 then
			last = BagConsts.Equip_Quick_Count - #list%BagConsts.Equip_Quick_Count;
		end
	end
	for i=1,last do
		local slotVO = BagSlotVO:new();
		slotVO.bagType = BagConsts.ShowType_Equip;
		slotVO.hasItem = false;
		table.push(list,slotVO);
	end
	return list, isHasEquip;
end
--检查是否是一个更牛逼的翅膀
function BagUtil:CheckBetterWing(bagType,pos,tid)
	local bagVO = BagModel:GetBag(bagType);
	if not bagVO then return false; end
	local item = bagVO:GetItemByPos(pos);
	if not item then return false; end
	if not item:ProfAccord() then return false; end
	local hasWingItem = BagUtil:GetCompareWing()
	-- print('======================检查是否是一个更牛逼的翅膀',hasWingItem,WingStarUtil:GetInWingCfgFight(tid))
	if hasWingItem then
		if hasWingItem < WingStarUtil:GetInWingCfgFight(tid) then--新得到的是一个更牛逼的翅膀
			return true;
		else
			return false;
		end
	else
		return true;
	end
end
--检查这个翅膀比身上的牛逼多少
function BagUtil:CheckBetterWingFightNum(bagType,pos,tid)
	local bagVO = BagModel:GetBag(bagType);
	if not bagVO then return false; end
	local item = bagVO:GetItemByPos(pos);
	if not item then return false; end
	if not item:ProfAccord() then return false; end
	local hasWingItem = BagUtil:GetCompareWing()
	if hasWingItem then
		if hasWingItem < WingStarUtil:GetInWingCfgFight(tid) then
			return WingStarUtil:GetInWingCfgFight(tid) - hasWingItem;
		end
	else
		return WingStarUtil:GetInWingCfgFight(tid)
	end
end
--获取一个人物的身上的翅膀的战力
function BagUtil:GetCompareWing()
	local wingItemList = BagUtil:GetBagItemList(BagConsts.BagType_RoleItem,BagConsts.ShowType_All);
	local wingID = nil;
	for i , v in pairs(wingItemList) do
		for j , k in pairs(t_wing) do
			if v.tid == k.itemId and k.itemId ~= 0 then
				wingID = k.id;
				break
			end
		end
	end
	if not wingID then return false; end
	local wingCfg = t_wing[wingID];
	if not wingCfg then return false; end
	return wingCfg.fight
end
--获取身上的翅膀
function BagUtil:GetCompareWingItem()
	local bagVO = BagModel:GetBag(BagConsts.BagType_RoleItem);
	if not bagVO then return; end
	local wingItemList = BagUtil:GetBagItemList(BagConsts.BagType_RoleItem,BagConsts.ShowType_All);
	for i , v in pairs(wingItemList) do
		for j , k in pairs(t_wing) do
			if v.tid == k.itemId and k.itemId ~= 0 then
				local item =  bagVO:GetItemById(v.id);
				if not item then
					return;
				else
					return item;
				end
			end
		end
	end
end
--获取一个物品的对比装备
function BagUtil:GetCompareEquip(bagType,pos)
	local bagVO = BagModel:GetBag(bagType);
	if not bagVO then return; end
	local item =  bagVO:GetItemByPos(pos);
	if not item then return; end
	local putBag,putPos = BagUtil:GetEquipPutBagPos(item:GetTid());
	if putBag<0 or putPos<0 then return; end
	local putBagVO = BagModel:GetBag(putBag);
	if not putBagVO then return; end
	local putItem = putBagVO:GetItemByPos(putPos);
	return putItem;
end


--检查是否是一件更牛逼的装备
function BagUtil:CheckBetterEquip(bagType,pos)
	local bagVO = BagModel:GetBag(bagType);
	if not bagVO then return false; end
	local item = bagVO:GetItemByPos(pos);
	if not item then return false; end
	if item:GetShowType() ~= BagConsts.ShowType_Equip then return false; end
	if not item:ProfAccord() then return false; end
	local hasEquipItem = BagUtil:GetCompareEquip(bagType,pos);
	if hasEquipItem then
		if hasEquipItem:GetFight() < item:GetFight() then
			return true;
		else
			return false;
		end
	else
		return true;
	end
end

--检查是这件装备比身上的牛逼多少
function BagUtil:CheckBetterFightNum(bagType,pos)
	local bagVO = BagModel:GetBag(bagType);
	if not bagVO then return false; end
	local item = bagVO:GetItemByPos(pos);
	if not item then return false; end
	if item:GetShowType() ~= BagConsts.ShowType_Equip then return false; end
	if not item:ProfAccord() then return false; end
	local hasEquipItem = BagUtil:GetCompareEquip(bagType,pos);
	if hasEquipItem then
		if item:GetFight() > hasEquipItem:GetFight() then
			return item:GetFight() - hasEquipItem:GetFight();
		end
	end
end

--特殊道具特殊特效
function BagUtil:GetSSlotQuality(itemId,size)
	if itemId == t_consts[124].val1 then
		return ResUtil:GetSlotQuality("fr",size);
	end
	return nil;
end

--获取背包蓝色装备的数量
function BagUtil:GetBlueEquipCount()
	local count = 0
	local bag = BagModel:GetBag(BagConsts.BagType_Bag);
	local equips = bag:GetItemListByShowType(BagConsts.ShowType_Equip);
	for k, equip in pairs(equips) do
		if equip:GetCfg().quality == 1 then
			count = count + 1
		end
	end
	return count
end
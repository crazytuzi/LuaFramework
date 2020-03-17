--[[
ItemTipsUtil
lizhuangzhuang
2014年8月19日10:16:48
]]

_G.ItemTipsUtil = {};

--获取背包内物品的TipsVO
function ItemTipsUtil:GetBagItemTipsVO(bag,pos)
	local bagVO = BagModel:GetBag(bag);
	if not bagVO then return nil; end
	local item = bagVO:GetItemByPos(pos);
	if not item then return nil; end
	if not t_equip[item:GetTid()] and not t_item[item:GetTid()] then 
		print("Error:Tips Error.Cannot find cfg.",item:GetTid());
		return nil; 
	end
	--
	local tipsVO = ItemTipsVO:new();
	self:CopyItemDataToTipsVO(item,tipsVO);
	local equip = EquipModel:GetEquipInfo(item:GetId())
	if equip then
		tipsVO.emptystarnum = equip.emptystarnum
	end
	--
	if item:GetShowType() == BagConsts.ShowType_Equip then
		tipsVO.tipsType = TipsConsts.Type_Equip;    ---装备
	elseif BagUtil:IsWing(item:GetTid()) then
		tipsVO.tipsType = TipsConsts.Type_Wing;     ---翅膀
	elseif BagUtil:IsRing(item:GetTid()) then 
		tipsVO.tipsType = TipsConsts.Type_Ring;     ---戒指
	elseif BagUtil:IsRelic(item:GetTid()) then
		tipsVO.tipsType = TipsConsts.Type_Relic  	---圣器
	elseif BagUtil:IsTianshenKa(item:GetTid()) then ---天神卡
		tipsVO.tipsType = TipsConsts.Type_NewTianshen
		tipsVO.isTianshen = false
	else
		tipsVO.tipsType = TipsConsts.Type_Item;     ---物品
	end
	--是否对比显示
	tipsVO.tipsShowType = TipsConsts.ShowType_Normal;
	if item:GetShowType()==BagConsts.ShowType_Equip and 
		(bag==BagConsts.BagType_Bag or bag==BagConsts.BagType_Storage) then
		local hasEquipItem = BagUtil:GetCompareEquip(bag,pos);
		if hasEquipItem then
			tipsVO.compareTipsVO = ItemTipsVO:new();
			self:CopyItemDataToTipsVO(hasEquipItem,tipsVO.compareTipsVO);
			tipsVO.compareTipsVO.isInBag = false;
			tipsVO.tipsShowType = TipsConsts.ShowType_Compare;
		end
	end
	if BagUtil:IsWing(item:GetTid()) and 
		(bag==BagConsts.BagType_Bag or bag==BagConsts.BagType_Storage) then
		local hasWingItem = BagUtil:GetCompareWingItem();
		if hasWingItem then
			tipsVO.compareTipsVO = ItemTipsVO:new();
			self:CopyItemDataToTipsVO(hasWingItem,tipsVO.compareTipsVO);
			tipsVO.compareTipsVO.isInBag = false;
			tipsVO.tipsShowType = TipsConsts.ShowType_Compare;
		end
	end
	return tipsVO;
end

--拷贝Item中需要的数据
function ItemTipsUtil:CopyItemDataToTipsVO(item,tipsVO)
	tipsVO.isInBag = true;
	tipsVO.id = item:GetTid();
	tipsVO.count = item:GetCount();
	tipsVO.cfg = item:GetCfg();
	tipsVO.iconUrl = BagUtil:GetItemIcon(item:GetTid(),true);
	tipsVO.levelAccord = item:LevelAccord();
	tipsVO.needLevel = item:GetNeedLevel();
	tipsVO.needAttr = item:GetNeedAttr();  -------基础属性
	tipsVO.needAttrOne = item:GetNeedAttrOne();
	tipsVO.param1 = item:GetParam()
	tipsVO.param2 = item:GetParam2()
	tipsVO.param4 = item:GetParam4()
	if item:GetBagType() == BagConsts.BagType_Role then
		tipsVO.equiped = true;
	elseif item:GetBagType() == BagConsts.BagType_Horse then
		tipsVO.equiped = true;
	elseif item:GetBagType() == BagConsts.BagType_LingShou then
		tipsVO.equiped = true;
	elseif item:GetBagType() == BagConsts.BagType_LingShouHorse then
		tipsVO.equiped = true;
	elseif item:GetBagType() == BagConsts.BagType_LingZhenZhenYan then
		tipsVO.equiped = true;
	elseif item:GetBagType() == BagConsts.BagType_QiZhan then
		tipsVO.equiped = true;	
	elseif item:GetBagType() == BagConsts.BagType_RoleItem then
		tipsVO.equiped = true;
	elseif item:GetBagType() == BagConsts.BagType_RELIC then
		tipsVO.equiped = true
	else
		tipsVO.equiped = false;
	end
	tipsVO.profAccord = item:ProfAccord();
	tipsVO.prof = item:GetProf();
	tipsVO.bindState = item:GetBindState();
	if BagUtil:GetItemShowType(item:GetTid()) == BagConsts.ShowType_Equip then
		tipsVO.strenLvl = EquipModel:GetStrenLvl(item:GetId());
		--追加等级
		tipsVO.extraLvl = EquipModel:GetExtraLvl(item:GetId());
		--卓越属性
		tipsVO.superVO = EquipModel:GetSuperVO(item:GetId());
		tipsVO.washList = EquipModel:getWashInfo(item:GetId())
		if SmithingModel:GetRingCid() and item:GetId() == SmithingModel:GetRingCid() then
			tipsVO.ring = SmithingModel:GetRingLv()
		end
		--
		if EquipModel:GetNewSuperVO(item:GetId()) then
			tipsVO.newSuperList = EquipModel:GetNewSuperVO(item:GetId()).newSuperList;
		end
		--宝石属性
		local equipInfo = SmithingModel:GetEquipByPos(tipsVO.cfg.pos)
		if equipInfo then
			tipsVO.gemList = equipInfo.gems;
		end

		if item:GetCfg().pos >= 0 and item:GetCfg().pos <= 10 then
			local quality = item:GetCfg().quality
			if quality >= BagConsts.Quality_Green1 and quality <= BagConsts.Quality_Green3 then
				tipsVO.newGroupInfo = EquipUtil:GetNewEquipGroupInfo()
			end
		end

		--炼化等级
		tipsVO.refinLvl = EquipModel:GetRefinLvlByPos(item:GetCfg().pos);
	else
		--道具卓越属性
		tipsVO.itemSuperVO = EquipModel:GetItemSuperVO(item:GetId());
		if BagUtil:IsWing(tipsVO.id) then
			tipsVO.wingTime = EquipModel:GetWingTime(item:GetId());
			tipsVO.wingAttrFlag = EquipModel:GetWingAttrFlag(item:GetId());
			if WingStarUpModel:GetWingStarLevel() and WingStarUpModel:GetWingStarLevel() > 0 then
				tipsVO.wingStarLevel = WingStarUpModel:GetWingStarLevel();
				tipsVO.wingID = WingStarUtil:GetInWingCfg().id;
				tipsVO.ismyself = true;
			end
		end
		tipsVO.reuseNum = item:GetUseCnt();
		tipsVO.reuseDayNum = item:GetTodayUse();
		if tipsVO.cfg.sub == 30 then
			tipsVO.reuse_day = item:GetReuseDay()
		end
	end
	if item:GetShowType() == BagConsts.ShowType_Equip then
		--神武
		-- if item:GetBagType() == BagConsts.BagType_Role and item:GetPos() == BagConsts.Equip_WuQi then
		-- 	tipsVO.shenWuLevel = ShenWuModel:GetLevel()
		-- 	tipsVO.shenWuStar = ShenWuModel:GetStar()
		-- 	tipsVO.shenWuSkills = ShenWuModel:GetShenWuSkills()
		-- end
		--套装
		tipsVO.groupId = EquipModel:GetGroupId(item:GetId())
		tipsVO.groupId2,tipsVO.groupId2Bind = EquipUtil:GetEquipGroupId(item:GetTid());
		tipsVO.groupId2Level = EquipModel:GetEquipGroupLevel(item:GetId())
		if tipsVO.cfg.pos>=BagConsts.Equip_WuQi and tipsVO.cfg.pos<=BagConsts.Equip_JieZhi2 then
			tipsVO.groupEList = BagModel:GetBag(BagConsts.BagType_Role):GetGroupEList();
		elseif tipsVO.cfg.pos>=BagConsts.Equip_H_AnJu and tipsVO.cfg.pos<=BagConsts.Equip_H_DengJu then
			tipsVO.groupEList = BagModel:GetBag(BagConsts.BagType_Horse):GetGroupEList();
		elseif tipsVO.cfg.pos>=BagConsts.Equip_L_XiangQuan and tipsVO.cfg.pos<=BagConsts.Equip_L_TouShi then
			tipsVO.groupEList = BagModel:GetBag(BagConsts.BagType_LingShou):GetGroupEList();
		elseif tipsVO.cfg.pos>=BagConsts.Equip_LH_ZhuangJiao and tipsVO.cfg.pos<=BagConsts.Equip_LH_XiongJia then
			tipsVO.groupEList = BagModel:GetBag(BagConsts.BagType_LingShouHorse):GetGroupEList();
		elseif tipsVO.cfg.pos>=BagConsts.Equip_LZ_ZhenYan0 and tipsVO.cfg.pos<=BagConsts.Equip_LZ_ZhenYan8 then
			tipsVO.groupEList = BagModel:GetBag(BagConsts.BagType_LingZhenZhenYan):GetGroupEList();
		elseif tipsVO.cfg.pos>=BagConsts.Equip_QZ_ZhenYan0 and tipsVO.cfg.pos<=BagConsts.Equip_QZ_ZhenYan8 then
			tipsVO.groupEList = BagModel:GetBag(BagConsts.BagType_QiZhan):GetGroupEList();		
		else
			tipsVO.groupEList = {};
		end
	end
end

--获取物品tipsVO
function ItemTipsUtil:GetItemTipsVO(id,count,bind)
	if not t_equip[id] and not t_item[id] then 
		print("Error:Tips Error.Cannot find cfg.",id);
		return nil; 
	end
	if not bind then bind=BagConsts.Bind_None; end
	local tipsVO = ItemTipsVO:new();
	tipsVO.isInBag = false;
	tipsVO.id = id;
	tipsVO.count = count;
	if t_equip[id] then
		tipsVO.tipsType = TipsConsts.Type_Equip;
		tipsVO.cfg = t_equip[id];
		--套装
		tipsVO.groupId = tipsVO.cfg.groupId;
		if tipsVO.cfg.pos>=BagConsts.Equip_WuQi and tipsVO.cfg.pos<=BagConsts.Equip_JieZhi2 then
			tipsVO.groupEList = BagModel:GetBag(BagConsts.BagType_Role):GetGroupEList();
		elseif tipsVO.cfg.pos>=BagConsts.Equip_H_AnJu and tipsVO.cfg.pos<=BagConsts.Equip_H_DengJu then
			tipsVO.groupEList = BagModel:GetBag(BagConsts.BagType_Horse):GetGroupEList();
		elseif tipsVO.cfg.pos>=BagConsts.Equip_L_XiangQuan and tipsVO.cfg.pos<=BagConsts.Equip_L_TouShi then
			tipsVO.groupEList = BagModel:GetBag(BagConsts.BagType_LingShou):GetGroupEList();
		elseif tipsVO.cfg.pos>=BagConsts.Equip_LH_ZhuangJiao and tipsVO.cfg.pos<=BagConsts.Equip_LH_XiongJia then
			tipsVO.groupEList = BagModel:GetBag(BagConsts.BagType_LingShouHorse):GetGroupEList();
		elseif tipsVO.cfg.pos>=BagConsts.Equip_LZ_ZhenYan0 and tipsVO.cfg.pos<=BagConsts.Equip_LZ_ZhenYan8 then
			tipsVO.groupEList = BagModel:GetBag(BagConsts.BagType_LingZhenZhenYan):GetGroupEList();
		elseif tipsVO.cfg.pos>=BagConsts.Equip_QZ_ZhenYan0 and tipsVO.cfg.pos<=BagConsts.Equip_QZ_ZhenYan8 then
			tipsVO.groupEList = BagModel:GetBag(BagConsts.BagType_QiZhan):GetGroupEList();	
		else
			tipsVO.groupEList = {};
		end
		--是否指定卓越属性,附加属性
		if BagUtil:GetEquipPutBagPos(id) == BagConsts.BagType_Role then
			if tipsVO.cfg.assin_super ~= "" then
				tipsVO.superVO = {superNum=0,superList={}};
				local t = split(tipsVO.cfg.assin_super,"#");
				for _,s in ipairs(t) do
					local t1 = split(s,",");
					tipsVO.superVO.superNum = tipsVO.superVO.superNum + 1;
					local vo = {};
					vo.id = toint(t1[1]);
					vo.val1 = toint(t1[2]);
					table.push(tipsVO.superVO.superList,vo);
				end
			else
				tipsVO.superDefStr = EquipConsts:DefaultSuperNum(tipsVO.cfg.quality);
			end
			if tipsVO.cfg.assin_supernew and tipsVO.cfg.assin_supernew ~= "" then
				tipsVO.newSuperList = {};
				local t = split(tipsVO.cfg.assin_supernew,"#");
				for _,s in ipairs(t) do
					local vo = {};
					vo.id = toint(s);
					local superNewCfg = t_zhuoyueshuxing[vo.id]
					if superNewCfg then
						vo.wash = toint(split(superNewCfg.val, ",")[1])
						table.push(tipsVO.newSuperList,vo);
					end
				end
			end
		end
		--指定强化星级
		tipsVO.strenLvl = tipsVO.cfg.star;

		--宝石属性
		local equipInfo = SmithingModel:GetEquipByPos(tipsVO.cfg.pos)
		if equipInfo then
			tipsVO.gemList = equipInfo.gems;
		end

		--- 给他预览身上的套装
		if tipsVO.cfg.pos >= 0 and tipsVO.cfg.pos <= 10 then
			local quality = tipsVO.cfg.quality
			if quality >= BagConsts.Quality_Green1 and quality <= BagConsts.Quality_Green3 then
				tipsVO.newGroupInfo = EquipUtil:GetNewEquipGroupInfo()
			end
		end
		if tipsVO.cfg.pos == BagConsts.Equip_JieZhi1 then
			--这里预览要给个假的
			tipsVO.ring = 1
		end
	else 
		if BagUtil:IsWing(id) then
			tipsVO.tipsType = TipsConsts.Type_Wing;
			--
		elseif BagUtil:IsRing(id) then 
			tipsVO.tipsType = TipsConsts.Type_Ring;
		elseif BagUtil:IsRelic(id) then
			tipsVO.param1 = BagUtil:GetRelicId(id)
			tipsVO.tipsType = TipsConsts.Type_Relic
		elseif BagUtil:IsTianshenKa(id) then ---天神卡
			tipsVO.tipsType = TipsConsts.Type_NewTianshen
			tipsVO.isTianshen = false
			tipsVO.param1 = nil
			tipsVO.param2 = nil
			tipsVO.param3 = nil
		else
			tipsVO.tipsType = TipsConsts.Type_Item;
		end
		tipsVO.cfg = t_item[id];
	end 
	tipsVO.iconUrl = BagUtil:GetItemIcon(id,true);
	local playerInfo = MainPlayerModel.humanDetailInfo;
	tipsVO.needLevel = BagUtil:GetNeedLevel(id);    ---需要的境界
	tipsVO.needAttrOne = BagUtil:GetNeedAttrOne(id) --获取属性第一条
	tipsVO.needAttr = BagUtil:GetNeedAttr(id);      --获取属性第二条
	tipsVO.levelAccord = BagUtil:GetLevelAccord(id);
	tipsVO.prof = tipsVO.cfg.vocation;   --职业限制  
	tipsVO.profAccord =	tipsVO.prof==0 and true or playerInfo.eaProf==tipsVO.prof and true or false;
	tipsVO.tipsShowType = TipsConsts.ShowType_Normal;
	tipsVO.bindState = bind;   ---绑定状态
	tipsVO.itemID = id
	-- 没有获取的装备也显示装备对比
	if BagUtil:GetItemShowType(id) == BagConsts.ShowType_Equip then
		local putBag,putPos = BagUtil:GetEquipPutBagPos(id);
		if putBag < 0 or putPos < 0 then return; end
		local putBagVO = BagModel:GetBag(putBag);
		if not putBagVO then return; end
		local putItem = putBagVO:GetItemByPos(putPos);  --根据装备位拿到装备
		if putItem then
			tipsVO.compareTipsVO = ItemTipsVO:new();
			self:CopyItemDataToTipsVO(putItem,tipsVO.compareTipsVO);
			tipsVO.compareTipsVO.isInBag = false;
			tipsVO.tipsShowType = TipsConsts.ShowType_Compare;
		end
	end
	--没有获得的翅膀也显示翅膀对比
	if BagUtil:IsWing(id) then
		local hasWingItem = BagUtil:GetCompareWingItem();
		if hasWingItem then
			tipsVO.compareTipsVO = ItemTipsVO:new();
			self:CopyItemDataToTipsVO(hasWingItem,tipsVO.compareTipsVO);
			tipsVO.compareTipsVO.isInBag = false;
			tipsVO.tipsShowType = TipsConsts.ShowType_Compare;
		end
	end
	return tipsVO;
end
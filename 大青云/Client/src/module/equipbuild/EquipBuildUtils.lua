--[[
装备打造
wangshuai
]]

_G.EquipBuildUtil = {};

-- 卓越分级                    	 极高     较高   一般   较低   极低
EquipBuildUtil.SuperPercent = {{100,10},{10,2},{2,1},{1,0.5},{0.5,0},}

-- 新卓越表头
-- 卓越属性表头
EquipBuildUtil.SuperGetTitleNew = {"attr1","attr2","attr3","attr4","attr5","attr6","attr7","attr8","attr9","attr10"}


--  得到当前装备可能生成的所有卓越
function EquipBuildUtil:GetAllSuperAtb(id,isVip,NeedSuperLenght,isInfomation)
	local equipCfg = t_equip[id];
	if not equipCfg then 
		print("Error: equipId is nil")
		return 
	end;
	-- t_superGet 表id
	local superGetId = 1000000 + (equipCfg.level * 10000) + (equipCfg.pos * 100)+equipCfg.quality--equipCfg.level * 10000 + (equipCfg.pos * 10) + equipCfg.quality;
	-- print(superGetId,"当前superget表id")

	local superGetCfg = t_zhuoyue[superGetId]

	if not superGetCfg then 
		print("superGetId","id 没取到",superGetId)
		print(equipCfg.level,equipCfg.pos,equipCfg.quality)
		trace(equipCfg)
		return 
	end;
	
	local superGetListNum = 0;
	local list = {};
	for i,info in ipairs(self.SuperGetTitleNew) do 
		if superGetCfg[info]then 
			if superGetCfg[info] ~= "" then 
				local supercfg = split(superGetCfg[info],",")
				-- trace(supercfg)
				local vo = {};
				vo.id = toint(supercfg[1])
				vo.percent = toint(supercfg[2])
				superGetListNum = superGetListNum + vo.percent;
				table.push(list,vo)
			end
		end;
	end;
	local allSuperAtbList = {};
	for ti,tle in ipairs(list) do
		local vo = {};
		vo.percent = string.format("%.1f",(tle.percent / superGetListNum) * 100); 
		local SuperId = tle.id;
		local SuperCfg = t_zhuoyueshuxing[SuperId];
		if isInfomation then 
			local vo = {};
			vo.id = SuperId;
			vo.val1 = SuperCfg.val;
			table.push(allSuperAtbList,vo)
		else
			local attrStr = formatAttrStr(SuperCfg.attrType,SuperCfg.val);
			vo.str = attrStr;
			table.push(allSuperAtbList,vo)
		end;
	end;


	if isInfomation then 
		return allSuperAtbList
	end;
	for al,super in ipairs(allSuperAtbList) do 
		for pr,cen in ipairs(self.SuperPercent) do
			local max = cen[1];
			local mini = cen[2];
			local percent = tonumber(super.percent)
			if percent < tonumber(max) and percent > tonumber(mini) then
				super.index = pr;
				break
			end;
		end;
	end;
	return allSuperAtbList
end;

-- 得到当前购买条件
function EquipBuildUtil:GetIsCanBuy(id,isvip,isBind)
	local cfg = t_equipcreate[id]

	local isVipc = -1;
	local ismoney = -1;
	local isenergy = -1;
	local isnum = -1;

	--不是任意VIP类型
	local viptype = VipController:GetVipType();
	if viptype > 0 then 
		isVipc = true;
	else
		isVipc = false;
	end;

	if type(isvip) == "number" then 
		if isvip == 0 then 
			isvip = false;
		else
			isvip = true;
		end;
	end;

	-- 判断数量
	if not cfg then return end;
	if isvip then 
		local materList = split(cfg.vip_material,"#")
		local matercfg1 = split(materList[1],",");
		local matercfg2 = split(materList[2],",");
		local vipNeedNum = toint(matercfg1[2]);
		local VipMyhaveNum = self:GetBindStateItemNumInBag(toint(matercfg1[1]),isBind);
		local vipNum = math.floor(VipMyhaveNum / vipNeedNum)
		local vipNeedNum2 = toint(matercfg2[2]);
		local VipMyhaveNum2 = self:GetBindStateItemNumInBag(toint(matercfg2[1]),isBind);
		local vipNum2 = math.floor(VipMyhaveNum2 / vipNeedNum)
		isnum = false;
		if VipMyhaveNum >= vipNeedNum then 
			if VipMyhaveNum2 >= vipNeedNum2 then 
				isnum = true;
			end;
		end;
	else
		local materList1 = split(cfg.material,",")
		local needNum = toint(materList1[2]);
		local myhaveNum = self:GetBindStateItemNumInBag(toint(materList1[1]),isBind);
		if needNum <= myhaveNum then 
			if isnum ~= false then 
				isnum =  true
			end;
		else
			isnum = false;
		end;
	end

	-- 判断钱
	local needMoney = cfg.money;
	local myMoney = MainPlayerModel.humanDetailInfo.eaBindGold + MainPlayerModel.humanDetailInfo.eaUnBindGold

	if myMoney < needMoney then 
		ismoney = false;
	else
		ismoney = true;
	end;

	-- 判断活力值
	local needEnergy = cfg.activity;
	local myenergy = MainPlayerModel.humanDetailInfo.eaEnergy;
	if myenergy < needEnergy then 
		isenergy = false;
	else
		isenergy = true;
	end;

	if isvip then 
		if not isVipc then 
			return false,1;
		end;
	end;
	if not ismoney then 
		return false,2;
	end;

	if not isenergy then 
		return false,3;
	end;

	if not isnum then 
		return false,4;
	end;

	return true,0;

end;
-- 极品追加
function EquipBuildUtil:GetNBAddAtb(id)
	local equipcfg = t_equip[id];
	if not equipcfg then 
		print("Error： equipID is nil",id)
	return end;
	local addAtbId = equipcfg.level*10+equipcfg.quality;
	local atbCfg = t_equipExtra[toint(addAtbId)];
	-- print(addAtbId)
	-- trace(atbCfg)
	local weightIndex = 0;
	for i,info in ipairs(atbCfg.weight) do
		if info > 0 then 
			weightIndex = i - 1;
		end;
	end;
	if weightIndex <= 0 then 
		return 0;
	end;
	return weightIndex;
end;

--  极品装备预览
function EquipBuildUtil:GetNBEquip(id,isVip)
	local equipcfg = t_equip[id];
	if not equipcfg then 
		print("Error： equipID is nil",id)
	return end;
	
	local addVal = self:GetNBAddAtb(id);
	local superlist = self:GetAllSuperAtb(id,isVip,nil,true);
	local superNum = self:GetAllSuperAtb(id,isVip,true)
	local cursuperList = {};
	for i= (#superlist-superNum + 1),(#superlist+superNum) do 
		table.push(cursuperList,superlist[i])
	end;
	local list = {};
	list.superList = cursuperList
	list.superNum = superNum
	return addVal,list
end;

-- 得到当前背包内物品，可打造几个次id装备
function EquipBuildUtil:GetCanBuildEquipNum(cid,isVip,isBind)
	local numList = {};
	local cfg = self:GetBuildId(cid)
	if not cfg then 
		print("errorID  : ",cid)
		debug.traceback();
		return;
	end;
	-- 我的活力值
	local myenergy = MainPlayerModel.humanDetailInfo.eaEnergy;
	-- 需要活力值
	local needEnergy = cfg.activity

	if isVip then
		local materList = split(cfg.vip_material,"#")
		local matercfg1 = split(materList[1],",");
		local matercfg2 = split(materList[2],",");

		local vipNeedNum = toint(matercfg1[2]);
		local vipNeedNum2 = toint(matercfg2[2]);
		local VipMyhaveNum = self:GetBindStateItemNumInBag(toint(matercfg1[1]),isBind);
		local VipMyhaveNum2 = self:GetBindStateItemNumInBag(toint(matercfg2[1]),isBind);
		local vipNum2 = math.floor(VipMyhaveNum / vipNeedNum)
		local vipNum = math.floor(VipMyhaveNum2 / vipNeedNum2)

		table.push(numList,vipNum2)
		table.push(numList,vipNum)
		--  活力值可造数量
		local energyNum = math.floor( myenergy / needEnergy);
		table.push(numList,energyNum)

	else
		-- 需要材料数量
		local materList1 = split(cfg.material,",")
		local needNum = toint(materList1[2]);
		-- 我的材料数量
		local myhaveNum = self:GetBindStateItemNumInBag(toint(materList1[1]),isBind);
		--  材料可造数量
		local canNum = math.floor(myhaveNum / needNum)
		--  活力值可造数量
		local energyNum = math.floor( myenergy / needEnergy);
		table.push(numList,canNum)
		table.push(numList,energyNum)
	end;

	for i=1,#numList-1 do 
		for i=1,#numList-1 do 
			if numList[i] > numList[i+1] then  
				numList[i] ,numList[i+1] = numList[i+1],numList[i];
			end;
		end;
	end;
	return numList[1]
end;


--获取玩家背包内某指定绑定状态的道具数量
function EquipBuildUtil:GetBindStateItemNumInBag(itemId,isBindcc)
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag)
	if not bagVO then return 0; end
	local bindnum = 0;
	local nobindnum = 0;
	local num = 0;
	for k,itemVO in pairs(bagVO.itemlist) do
		if itemVO:GetTid()==itemId then
			if itemVO:GetBindState() == BagConsts.Bind_Bind then 
				--全部是绑定材料
				bindnum = bindnum + itemVO:GetCount();
			else
				--全是非绑定材料
				nobindnum = nobindnum + itemVO:GetCount();
			end;
			num = num + itemVO:GetCount();
		end
	end
	if isBindcc == 0 then 
		return nobindnum
	elseif isBindcc == 1 then 
		return bindnum
	end;
	return num;
end

-- cid get cfg
function EquipBuildUtil:GetBuildId(cid)
	for i,info in ipairs(t_equipcreate) do 
		if info.cid == cid then 
			return info;
		end;
	end;
end;


-- get index 
function EquipBuildUtil:GetCurListindex(id,cid)
	local list = EquipBuildModel:GetScrollList(id)
	for i,info in ipairs(list) do 
		if info.cid == cid then 
			return i;
		end;
	end;
end;
--[[
	2015年12月11日16:45:06
	wangyanwei
]]

_G.WingStarUtil = {};

--获取强化所得属性 ps：  左侧汉字文本
function WingStarUtil:GetWingStarAttrStr()
	local wingCfg = self:GetInWingCfg();
	if not wingCfg then return end
	local wingAttrList = split(wingCfg.attr2,'#');
	local wingStarLevel = WingStarUpModel:GetWingStarLevel();
	if not wingStarLevel or wingStarLevel == 0 then 
		wingStarLevel = 1;
	end
	local cfg = t_wingequip[wingStarLevel];
	if not cfg then return end
	if cfg.attr ~= '' then						--额外翅膀属性
		local wingAttr = split(cfg.attr,'#');
		for i , v in ipairs(wingAttr) do
			local vo1 = split(v , ',');
			local isHave = false;
			for j , k in ipairs(wingAttrList) do
				local vo2 = split(k , ',');
				if vo1[1] == vo2[1] then
					isHave = true;
				end
			end
			if not isHave then
				table.push(wingAttrList,v)
			end
		end
	end
	return wingAttrList;
end

--获取翅膀升星所有获得的属性  ps: index 定向星级取属性  wingID定向翅膀ID取
function WingStarUtil:GetWingStarAttribute(index,wingID)
	local wingCfg = self:GetInWingCfg(wingID);
	if not wingCfg then return end
	
	local wingAttrList = split(wingCfg.attr2,'#');
	
	local attrList = {};
	
	local wingStarLevel = WingStarUpModel:GetWingStarLevel();
	if index then
		wingStarLevel = index;
	end
	if not wingStarLevel or wingStarLevel == 0 then 
		local cfg = t_wingequip[1];
		for _ , attr in ipairs(wingAttrList) do
			local vo = split(attr , ',');
			local attrName = vo[1];
			local attrNum = 0;
			attrList[attrName] = attrNum;
		end
		local attrCfg = split(cfg.attr , '#');
		
		for i , v in ipairs(attrCfg) do
			local vo = split(v , ',');
			for j , k in pairs(attrList) do
				if j == vo[1] then
					k = 0;
				else
					attrList[vo[1]] = 0;
				end
			end
		end
		
		return attrList
	end
	
	local cfg = t_wingequip[wingStarLevel];
	if not cfg then return end
	local attrPercen = cfg.times;
	for _ , attr in ipairs(wingAttrList) do
		local vo = split(attr , ',');
		local attrName = vo[1];
		local attrNum = tonumber(vo[2]);
		attrList[attrName] = attrNum * (attrPercen / 100) - attrNum ;
	end
	if cfg.attr ~= '' then						--额外翅膀属性
		local wingAttr = split(cfg.attr,'#');
		for i , v in ipairs(wingAttr) do
			local vo = split(v,',');
			local attrName = vo[1];
			local attrNum = tonumber(vo[2]);
			if attrList[attrName] then
				attrList[attrName] = attrList[attrName] + attrNum;
			else
				attrList[attrName] = attrNum;
			end
		end
	end
	return attrList;
end

--获取下阶增加的属性
function WingStarUtil:GetNextWingStarAttr()
	local wingStarLevel = WingStarUpModel:GetWingStarLevel();
	if not wingStarLevel then wingStarLevel = 0 end
	local nextAttrList = self:GetWingStarAttribute(wingStarLevel + 1);
	for attrName , attrNum in pairs(nextAttrList) do
		local _type = AttrParseUtil.AttMap[attrName];
		--百分比加成,VIP加成
		local addP = 0;
		if Attr_AttrPMap[_type] then
			addP = MainPlayerModel.humanDetailInfo[Attr_AttrPMap[_type]];
		end
		
		if attrIsPercent(_type) then
			nextAttrList[attrName] = attrNum * (1+addP)
		else
			nextAttrList[attrName] = toint(attrNum * (1+addP))
		end
	end
	
	local allwingStarAttr = self:GetAllWingStarAttr();
	if not allwingStarAttr then
		return nextAttrList;
	end
	
	for attrName , attrNum in pairs(nextAttrList) do
		if allwingStarAttr[attrName] then
			nextAttrList[attrName] = nextAttrList[attrName] - allwingStarAttr[attrName];
		end
	end
	
	return nextAttrList
end

--获取所有获得的属性
function WingStarUtil:GetAllWingStarAttr()
	local wingStarLevel = WingStarUpModel:GetWingStarLevel();
	if not wingStarLevel or wingStarLevel == 0 then return end
	local allAttrList = self:GetWingStarAttribute(wingStarLevel);
	for attrName , attrNum in pairs(allAttrList) do
		local _type = AttrParseUtil.AttMap[attrName];
		--百分比加成,VIP加成
		local addP = 0;
		if Attr_AttrPMap[_type] then
			addP = MainPlayerModel.humanDetailInfo[Attr_AttrPMap[_type]];
		end
		
		if attrIsPercent(_type) then
			allAttrList[attrName] = attrNum * (1+addP)
		else
			allAttrList[attrName] = toint(attrNum * (1+addP))
		end
	end
	return allAttrList
end

--获取所有所获得的属性  转为AttrParseUtil:Parse
function WingStarUtil:GetAllParseWingStarAttr(starLevel,wingID,ismyself)
	local allAttrList = self:GetWingStarAttribute(starLevel,wingID);
	if not allAttrList then return end
	if ismyself then
		for attrName , attrNum in pairs(allAttrList) do
			local _type = AttrParseUtil.AttMap[attrName];
			--百分比加成,VIP加成
			local addP = 0;
			if Attr_AttrPMap[_type] then
				addP = MainPlayerModel.humanDetailInfo[Attr_AttrPMap[_type]];
			end
			
			if attrIsPercent(_type) then
				allAttrList[attrName] = attrNum * (1+addP)
			else
				allAttrList[attrName] = toint(attrNum * (1+addP))
			end
		end
	end
	local list = {};
	for attrName , attrNum in pairs(allAttrList) do
		local vo = {};
		vo.type = AttrParseUtil.AttMap[attrName];
		if AttrP_AttrMap[vo.type] then
			vo.val = getAtrrShowVal(vo.type,attrNum);
		else
			vo.val = toint(attrNum);
		end
		table.push(list,vo)
	end
	return list;
end

--获取身上所穿戴的翅膀配表cfg  _wingID:指定ID的翅膀
function WingStarUtil:GetInWingCfg(_wingID)
	local wingItemList = BagUtil:GetBagItemList(BagConsts.BagType_RoleItem,BagConsts.ShowType_All);
	local wingID = nil;
	if _wingID then
		wingID = _wingID;
	else
		for i , v in pairs(wingItemList) do
			for j , k in pairs(t_wing) do
				if v.tid == k.itemId and k.itemId ~= 0 then
					wingID = k.id;
					break
				end
			end
		end
	end
	if not wingID then wingID = 1001; end
	local wingCfg = t_wing[wingID];
	return wingCfg
end
--根本翅膀的item表id 获得t_wing表对应的战斗力(也可以作为判断是不是翅膀）
function WingStarUtil:GetInWingCfgFight(tid)
	local wingFight = nil;
	for j , k in pairs(t_wing) do
		if tid == k.itemId and k.itemId ~= 0 then
			wingFight = k.fight;
			return wingFight;
		end
	end
	return false;
end




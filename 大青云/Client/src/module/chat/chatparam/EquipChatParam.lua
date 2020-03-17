--[[
装备
参数格式:type,equipId,自由参数
自由参数定义:
	stren=		强化等级
	extra=		追加等级
	groupId=	套装id
	groupId2=   新套装id
	groupId2Level=   新套装等级

	super=		卓越属性(superNum;id;val1;id;val1......)(这里在卓越属性的基础上增加了卓越孔等级)
	gem=		宝石属性(id;lvl;id;lvl.......)
	refin=		炼化等级
	newSuper=	新卓越属性(id;wash;id;wash;......)
lizhuangzhuang
2014年9月17日21:22:58
]]

_G.EquipChatParam = setmetatable({},{__index=ChatParam});

function EquipChatParam:GetType()
	return ChatConsts.ChatParam_Equip;
end

function EquipChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr);
	local equipId = toint(params[1]);
	local cfg = t_equip[equipId];
	if not cfg then return ""; end
	local str = "<font color='"..TipsConsts:GetItemQualityColor(cfg.quality).."'>["..cfg.name.."]</font>";
	if withLink then
		return self:GetLinkStr(str,paramStr);
	else
		return str;
	end
end

--装备编码
function EquipChatParam:EncodeEquip(bagItem)
	local str = "";
	local tId = bagItem:GetTid();
	--强化等级
	local strenLvl = EquipModel:GetStrenLvl(bagItem:GetId());
	str = str .. "stren=" .. strenLvl;
	--追加等级
	local extraLvl = EquipModel:GetExtraLvl(bagItem:GetId());
	str = str .. "," .. "extra=" .. extraLvl;
	--套装id
	local groupId = EquipModel:GetGroupId(bagItem:GetId());
	str = str .. "," .. "groupId=" .. groupId;
	--新套装id
	local groupId2 = EquipUtil:GetEquipGroupId(tId)
	str = str .. "," .. "groupId2=" .. groupId2;
	--新套装id等级
	local groupId2Level = EquipModel:GetEquipGroupLevel(bagItem:GetId());
	str = str .. "," .. "group2Level=" .. groupId2Level;
	--炼化等级
	local refinLvl = EquipModel:GetRefinLvlByPos(bagItem:GetCfg().pos);
	str = str .. "," .. "refin=" .. refinLvl;
	--卓越属性
	-- local superVO = EquipModel:GetSuperVO(bagItem:GetId());
	-- if superVO then
	-- 	local superStr = "";
	-- 	superStr = superStr .. superVO.superNum..";";
	-- 	for i,vo in ipairs(superVO.superList) do
	-- 		superStr = superStr .. vo.id ..";"..vo.val1;
	-- 		if i < #superVO.superList then
	-- 			superStr = superStr .. ";";
	-- 		end
	-- 	end
	-- 	str = str .. "," .. "super=" .. superStr;
	-- end
	-- 戒指属性
	if SmithingModel:GetRingCid() and SmithingModel:GetRingCid() == bagItem:GetId() then
		str = str .. "," .. "ring=" .. SmithingModel:GetRingLv()
	end
	--宝石属性
	local gemList
	local equipInfo = SmithingModel:GetEquipByPos(bagItem:GetCfg().pos)
	if equipInfo then
		gemList = equipInfo.gems;
	end

	if gemList and #gemList>0 then
		local gemStr = "";
		for i,vo in ipairs(gemList) do
			if vo.used then
				gemStr = gemStr .. vo.id ..";".. vo.level;
				local bHave = false
				for j = i + 1, #gemList do
					if gemList[j].used then
						bHave = true
					end
				end
				if bHave then
					gemStr = gemStr .. ";";
				end
			end
		end
		str = str .. "," .. "gem=" .. gemStr;
	end

	--套装属性
	local newGroupInfo
	if bagItem:GetCfg().pos >= 0 and bagItem:GetCfg().pos <= 10 then
		local quality = bagItem:GetCfg().quality
		if quality >= BagConsts.Quality_Green1 and quality <= BagConsts.Quality_Green3 then
			newGroupInfo = EquipUtil:GetNewEquipGroupInfo()
		end
	end
	if newGroupInfo then
		local groupstr = newGroupInfo[1] .. "#"
		local count = 0
		for k, v in pairs(newGroupInfo[2]) do
			groupstr = groupstr .. k
			count = count + 1
			if count ~= newGroupInfo[1] then
				groupstr = groupstr .. ";"
			end
		end
		groupstr = groupstr .. "#"
		local maxValue = 0
		for k, v in pairs(newGroupInfo[3]) do
			maxValue = maxValue + 1
		end
		count = 0
		for k, v in pairs(newGroupInfo[3]) do
			groupstr = groupstr .. v.name .. ";" .. v.val
			count = count + 1
			if count ~= maxValue then
				groupstr = groupstr .. ";"
			end
		end
		str = str .. "," .. "group=" .. groupstr
	end
	-- 洗练
	local washList = EquipModel:getWashInfo(bagItem:GetId())
	if washList and #washList > 0 then
		local washStr = ""
		for k, v in pairs(washList) do
			washStr = washStr .. v.id
			if washList[k + 1] then
				washStr = washStr ..";"
			end
		end
		str = str .. "," .. "wash=" .. washStr
	end
	--新卓越属性
	local newSuperVO = EquipModel:GetNewSuperVO(bagItem:GetId());
	if newSuperVO then
		local newSuperStr = "";
		for i,vo in ipairs(newSuperVO.newSuperList) do
			newSuperStr = newSuperStr .. vo.id ..";" .. vo.wash;
			if i < #newSuperVO.newSuperList then
				newSuperStr = newSuperStr .. ";";
			end
		end
		str = str .. "," .. "newSuper=" .. newSuperStr;
	end
	return self:Encode(tId,str);
end

function EquipChatParam:DoLinkOver(paramStr)
	local params = self:Decode(paramStr);
	local equipId = toint(params[1]);
	local cfg = t_equip[equipId];
	if not cfg then return; end
	local itemTipsVO = ItemTipsUtil:GetItemTipsVO(equipId,1);
	if not itemTipsVO then return; end
	--解析强化
	for i,s in ipairs(params) do
		if s:lead("stren=") then
			local str = string.sub(s,7,#s);
			itemTipsVO.strenLvl = toint(str);
		elseif s:lead("extra=") then
			local str = string.sub(s,7,#s);
			itemTipsVO.extraLvl = toint(str);
		elseif s:lead("refin=") then
			local str = string.sub(s,7,#s);
			itemTipsVO.refinLvl = toint(str);
		elseif s:lead("groupId=") then
			local str = string.sub(s,9,#s);
			itemTipsVO.groupId = toint(str);
		elseif s:lead("groupId2=") then
			local str = string.sub(s,10,#s);
			itemTipsVO.groupId2 = toint(str);
		elseif s:lead("group2Level=") then
			local str = string.sub(s,13,#s);
			itemTipsVO.groupId2Level = toint(str);
		elseif s:lead("ring=") then
			local str = string.sub(s,6,#s)
			itemTipsVO.ring = toint(str)
		-- elseif s:lead("super=") then
		-- 	local str = string.sub(s,7,#s);
		-- 	local superT = split(str,";");
		-- 	local superVO = {};
		-- 	superVO.superNum = toint(superT[1]);
		-- 	table.remove(superT,1,1);
		-- 	superVO.superList = {};
		-- 	for i=1,#superT do
		-- 		if i%2 == 1 then
		-- 			local vo = {};
		-- 			vo.id = toint(superT[i]);
		-- 			vo.val1 = toint(superT[i+1]);
		-- 			table.push(superVO.superList,vo);
		-- 		end
		-- 	end
		-- 	itemTipsVO.superVO = superVO;
		elseif s:lead("gem=") then
			local str = string.sub(s,5,#s);
			local gemT = split(str,";");
			local gemList = {};
			for i=1,#gemT do
				if i%2 == 1 then
					local vo = {};
					vo.used = true
					vo.id = toint(gemT[i]);
					vo.level = toint(gemT[i+1]);
					if vo.level > 0 then
						table.push(gemList,vo);
					end
				end
			end
			-- trace(gemList)
			itemTipsVO.gemList = gemList;
		elseif s:lead("group=") then
			local str = string.sub(s,7,#s);
			local groupTb = split(str,"#");
			itemTipsVO.newGroupInfo = {}
			itemTipsVO.newGroupInfo[1] = toint(groupTb[1])
			local groupTb2 = split(groupTb[2],";")
			itemTipsVO.newGroupInfo[2] = {}
			for k, v in pairs(groupTb2) do
				itemTipsVO.newGroupInfo[2][toint(v)] = 1
			end
			local groupTb3 = split(groupTb[3],";")
			itemTipsVO.newGroupInfo[3] = {}
			for i = 1, #groupTb3 do
				if i%2 == 1 then
					itemTipsVO.newGroupInfo[3][groupTb3[i]] = {val = toint(groupTb3[i + 1])}
				end
			end
			trace(itemTipsVO.newGroupInfo)
		elseif s:lead("wash=") then
			local str = string.sub(s,6,#s);
			local washT = split(str,";");
			local washList = {};
			for i=1,#washT do
				local vo = {};
				vo.id = toint(washT[i]);
				table.push(washList,vo);
			end
			itemTipsVO.washList = washList;
		elseif s:lead("newSuper=") then
			local str = string.sub(s,10,#s);
			local t = split(str,";");
			local newSuperList = {};
			for i=1,#t do
				if i%2 == 1 then
					local vo = {};
					vo.id = toint(t[i]);
					vo.wash = toint(t[i+1]);
					if vo.wash == 0 then
						local cfg = t_zhuoyueshuxing[vo.id];
						if cfg then
							vo.wash = cfg.val;
						end
					end
					table.push(newSuperList,vo);
				end
			end
			itemTipsVO.newSuperList = newSuperList;
		end
	end
	--和自身的做对比
	local meBag,mePos = BagUtil:GetEquipPutBagPos(equipId);
	if meBag>=0 and mePos>=0 then
		local meBagVO = BagModel:GetBag(meBag);
		if meBagVO then
			local meItem = meBagVO:GetItemByPos(mePos);
			if meItem then
				itemTipsVO.compareTipsVO = ItemTipsVO:new();
				ItemTipsUtil:CopyItemDataToTipsVO(meItem,itemTipsVO.compareTipsVO);
				itemTipsVO.compareTipsVO.isInBag = false;
				itemTipsVO.tipsShowType = TipsConsts.ShowType_Compare;
			end
		end
	end
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightUp);
end
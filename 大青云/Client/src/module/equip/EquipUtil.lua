--[[
装备Util
lizhuangzhuang
2014年11月14日14:48:47
]]

_G.EquipUtil = {};

--战斗力公式
EquipUtil.formulaList = nil;

function EquipUtil:Create()
	EquipUtil.formulaList = AttrParseUtil:Parse(t_consts[6].param);
	self:SetGroupList();
end

--用玩家当前百分比属性计算属性加成(用于养成系统)
function EquipUtil:GetAttrAddWithUser(attrlist)
	local playerInfo = MainPlayerModel.humanDetailInfo;
	for i,vo in ipairs(attrlist) do
		if Attr_AttrPMap[vo.type] then
			local percent = playerInfo[Attr_AttrPMap[vo.type]];--当前百分比值
			vo.val = vo.val * (1+percent);
		end
	end
	return attrlist;
end

--套装分组
EquipUtil.equipGrouList = {};
function EquipUtil:SetGroupList()
	local list = {};
	for Index=0,10 do 
		local indexVo = {};
		for i,info in pairs(t_equipgroup) do 
			if info.groupType == 1 then 
				local posVo = split(info.groupPos,"#");
				for p,pos in ipairs(posVo) do 
					if toint(pos) == Index then 
						local vo = {};
						vo.id = info.id;
						vo.name = info.name;
						table.push(indexVo,vo)
						break;
					end;
				end;
			end;
		end;
		list[Index] = indexVo
	end;
	self.equipGrouList = list;
	for i,info in ipairs(self.equipGrouList) do 
		table.sort(info,function(A,B)
			if A.id < B.id then
				return true;
			else
				return false;
			end
		end);
	end;
end;

function EquipUtil:GetGroupList(pos)
	if not pos then return {} end;
	if not self.equipGrouList[pos] then return {} end;
	return self.equipGrouList[pos];
end;


--获取人物装备VO
function EquipUtil:GetEquipUIVO(pos,isBig)
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return {}; end
	local item = bagVO:GetItemByPos(pos);
	local vo = {};
	vo.pos = pos;
	vo.isBig = isBig and true or false;
	vo.zbwPos = BagUtil:GetEquipAtBagPos(BagConsts.BagType_Role,pos);
	if item then
		vo.hasItem = true;
		EquipUtil:GetDataToEquipUIVO(vo,item,isBig);
	else
		vo.hasItem = false;	
	end
	return vo;
end

function EquipUtil:GetDataToEquipUIVO(vo,item,isBig,gray)
	if gray then
		vo.iconUrl = ImgUtil:GetRedImgUrl(BagUtil:GetItemIcon(item:GetTid(),isBig)) --ImgUtil:GetGrayImgUrl(BagUtil:GetItemIcon(item:GetTid(),isBig))
	else
		vo.iconUrl = BagUtil:GetItemIcon(item:GetTid(),isBig);
	end
	vo.qualityUrl = ResUtil:GetSlotQuality(t_equip[item:GetTid()].quality, isBig and 54 or nil);
	vo.quality = t_equip[item:GetTid()].quality;
	vo.strenLvl = EquipModel:GetStrenLvl(item:GetId());
	vo.super = 0;
	if t_equip[item:GetTid()].pos <= 10 then
		if vo.quality == BagConsts.Quality_Green1 then
			vo.super = 1;
		elseif vo.quality == BagConsts.Quality_Green2 then
			vo.super = 2;
		elseif vo.quality == BagConsts.Quality_Green3 then
			vo.super = 3;
		end
	end
	vo.showBind = item:GetBindState()==BagConsts.Bind_GetBind or item:GetBindState()==BagConsts.Bind_Bind;
	vo.groupBsUrl = self:GetIsShowEquipGroup(item);
end

-- 天神卡专用
function EquipUtil:GetDataToItemUIVO(vo,item)
	vo.iconUrl = BagUtil:GetItemIcon(item:GetTid());
	local quality = NewTianshenUtil:IsExpCard(item:GetTid()) and t_item[item:GetTid()].quality or NewTianshenUtil:GetShowQuality(item:GetParam())
	vo.qualityUrl = ResUtil:GetSlotQuality(quality);
	vo.quality = quality;
	vo.strenLvl = 0
	vo.super = 0;
	vo.showBind = item:GetBindState()==BagConsts.Bind_GetBind or item:GetBindState()==BagConsts.Bind_Bind;
end

function EquipUtil:GetIsShowEquipGroup(item)
	if item:GetBagType() == BagConsts.BagType_Role and item:GetPos() == BagConsts.Equip_WuQi then
		return ResUtil:GetShenWuSlotIcon(ShenWuModel:GetLevel(), ShenWuModel:GetStar())
	end
	local id = item:GetId()
	local groupId = EquipModel:GetGroupId2(id);
	if groupId and groupId > 0 then 
		local cfg = t_equipgroup[groupId]
		if cfg  then 
			return ResUtil:GetNewEquipGrouNameIcon(cfg.nameicon,nil,true)
		end;
		return ""
	end;
	return ""
end;

--获取装备基础属性
function EquipUtil:GetEquipBaseAttr(tid)
	local cfg = t_equip[tid];
	if not cfg then return {}; end
	local list = AttrParseUtil:Parse(cfg.baseAttr);
	return list;
end

function EquipUtil:GetStarAddFight(tid, starLv)
	if starLv == 0 then
		return 0
	end
	return PublicUtil:GetFigthValue(self:GetEquipStrenAttr(self:GetEquipBaseAttr(tid), starLv), t_equip[tid].level)
end

function EquipUtil:GetWashAddFight(id, tid)
	local washList = EquipModel:getWashInfo(id)
	local list = {}
	for k, v in pairs(washList) do
		local vo = {}
		local cfg = t_extraatt[v.id]
		vo.type = AttrParseUtil.AttMap[cfg.type]
		vo.name = cfg.type
		vo.lv = cfg.lv
		if attrIsPercent(vo.type) then
			vo.val = cfg.att/10000;
		else
			vo.val = cfg.att;
		end
		table.push(list, vo)
	end
	return PublicUtil:GetFigthValue(list, t_equip[tid].level)
end

--获取装备的强化属性
--@param ignoreAdd 是否忽略强化固定增加值
function EquipUtil:GetEquipStrenAttr(baseAttrList,strenLvl,ignoreAdd)
	local cfg = t_strenattr[strenLvl];
	if not cfg then 
		local list = {};
		for i,vo in ipairs(baseAttrList) do
			local addVO = {};
			addVO.type = vo.type;
			addVO.val = 0;
			table.push(list,addVO);
		end
		return list;
	end
	local list = {};
	local addAttrType = {"att","def","hp","mp","dodge","cri","hit","subdef", "absatt"};
	for i,vo in ipairs(baseAttrList) do
		local addVO = {};
		addVO.type = vo.type;
		--增加百分比
		addVO.val = toint(vo.val*cfg.addPercent/100,0.5);
		if not ignoreAdd then
			--固定增加值
			for j,addType in ipairs(addAttrType) do
				if vo.type == AttrParseUtil.AttMap[addType] then
					addVO.val = addVO.val + cfg[addType]; 
					break;
				end
			end
		end
		table.push(list,addVO);
	end
	return list;
end

--获取装备的炼化属性
--@param ignoreAdd 是否忽略强化固定增加值
function EquipUtil:GetEquipRefinAttr(baseAttrList,refinId,ignoreAdd)
	local cfg = t_refin[refinId];
	if not cfg then
		local list = {};
		for i,vo in ipairs(baseAttrList) do
			local addVO = {};
			addVO.type = vo.type;
			addVO.val = 0;
			table.push(list,addVO);
		end
		return list;
	end
	local list = {};
	for i,vo in ipairs(baseAttrList) do
		local addVO = {};
		addVO.type = vo.type;
		--增加百分比
		addVO.val = toint(vo.val*cfg.percentage/100,0.5);
		if not ignoreAdd then
			addVO.val = addVO.val + cfg.addVal;
		end
		table.push(list,addVO);
	end
	return list;
end

--获取装备强化激活的连锁id
--@param list 强化等级列表
function EquipUtil:GetStrenLinkId(nLv)
	local linkId = 0
	for i,cfg in ipairs(t_strenlink) do
		if nLv >= cfg.level then
			linkId = cfg.id;
		else
			break;
		end
	end
	return linkId;
end

--获取装备新卓越激活的连锁id
--@param num 卓越装备数量
function EquipUtil:GetNewSuperLinkId(num)
	local linkId = 0;
	for i,cfg in ipairs(t_zhuoyuelink) do
		if num >= cfg.num then
			linkId = cfg.id;
		else
			break;
		end	
	end
	return linkId;
end

function EquipUtil:GetGemLinkId(list)
	local linkid = 0;
	local curMiniNum = 0;
	for i,info in pairs(list) do 
		if not curMiniNum then 
			curMiniNum = info.lvl;
		else
			curMiniNum = curMiniNum + info.lvl;
		end
	end;
	for l,k in ipairs(t_gemlock) do 
		if curMiniNum >= k.lvl then
			linkid = k.id;
		else
			break;
		end
	end;
	return  linkid
end;

-- 得到长度
function EquipUtil:GetLenght(list)
	local num = 0;
	for i,info in pairs(list) do 
		num = num + 1;
	end;
	return num;
end
--属性累加
function EquipUtil:AddUpAttr(...)
	local list = {...};
	local adduplist = {};--累加值
	for i,attrlist in ipairs(list) do
		for j,vo in ipairs(attrlist) do
			local hasFind = false;
			for m,addUpVO in pairs(adduplist) do
				if addUpVO.type == vo.type then
					addUpVO.val = addUpVO.val + vo.val;
					hasFind = true;
					break;
				end
			end
			if not hasFind then
				local addUpVO = {};
				addUpVO.type = vo.type;
				addUpVO.val = vo.val;
				table.push(adduplist,addUpVO);
			end
		end
	end
	return adduplist;
end

--属性对比
--返回A相对B的属性变化
function EquipUtil:CompareAttr(attrListA,attrListB)
	local list = {};
	for i,attrA in ipairs(attrListA) do
		local hasFind = false;
		for j,attrB in ipairs(attrListB) do
			if attrA.type == attrB.type then
				local vo = {};
				vo.type = attrA.type;
				vo.val = attrA.val - attrB.val;
				table.push(list,vo);
				table.remove(attrListB,j,1);
				hasFind = true;
				break;
			end
		end
		if not hasFind then
			local vo = {};
			vo.type = attrA.type;
			vo.val = attrA.val;
			table.push(list,vo);
		end
	end
	for i,attrB in ipairs(attrListB) do
		local vo = {};
		vo.type = attrB.type;
		vo.val = -attrB.val;
		table.push(list,vo);
	end
	return list;
end

--根据属性计算战斗力
function EquipUtil:GetFight(attrlist,unint)
	local fight = 0;
	for i,vo in pairs(EquipUtil.formulaList) do
		for j,attrVO in pairs(attrlist) do
			if vo.type == attrVO.type then
				fight = fight + attrVO.val*vo.val;
			end
		end
	end
	--1级属性战斗力，仅客户端显示用
	local cList = AttrParseUtil:Parse(t_consts[77].param);
	for i,vo in pairs(cList) do
		for j,attrVO in pairs(attrlist) do
			if vo.type == attrVO.type then
				fight = fight + attrVO.val*vo.val;
			end
		end
	end
	if unint then return fight; end
	fight = toint(fight,0.5);
	return fight;
end

--- 计算装备战斗力
function EquipUtil:GetEquipFightValue(id, baseList, strenList, newSuperList, gemList, washList, ringList, relicList)
	local cfg = t_equip[id]
	local list = EquipUtil:AddUpAttr(baseList, strenList, newSuperList, gemList, washList, ringList, relicList)
	return PublicUtil:GetFigthValue(list, cfg and cfg.level)
end

--算装备评分
--装备评分 = 基础得分 +Σ卓越得分 +Σ附加得分 + 套装得分
function EquipUtil:GetEquipFight(id,groupId,groupId2,groupId2Level,refinLvl,strenLvl,extraLvl,superVO,newSuperList)
	return 0;   --changer:侯旭东
	--[[
	local baseScore,superScore,newSuperScore,groupScore,groupScore2 = 0,0,0,0,0;
	if BagUtil:GetEquipPutBagPos(id) == BagConsts.BagType_Role then
		baseScore = EquipUtil:GetRoleEquipBaseScore(id,refinLvl,strenLvl,extraLvl);
	elseif BagUtil:GetEquipPutBagPos(id) == BagConsts.BagType_Horse then
		baseScore = EquipUtil:GetHorseEquipBaseScore(id);
	elseif BagUtil:GetEquipPutBagPos(id) == BagConsts.BagType_LingShou then
		baseScore = EquipUtil:GetLingShowEquipBaseScore(id);
	elseif BagUtil:GetEquipPutBagPos(id) == BagConsts.BagType_LingShouHorse then
		baseScore = EquipUtil:GetLingShouHorseEquipBaseScore(id);
	elseif BagUtil:GetEquipPutBagPos(id) == BagConsts.BagType_LingZhenZhenYan then
		baseScore = EquipUtil:GetLingZhenZhenYanEquipBaseScore(id);	
	elseif BagUtil:GetEquipPutBagPos(id) == BagConsts.BagType_QiZhan then
		baseScore = EquipUtil:GetZhanQiZhenYanEquipBaseScore(id);
	elseif BagUtil:GetEquipPutBagPos(id) == BagConsts.BagType_ShenLing then
		baseScore = EquipUtil:GetShenLingZhenYanEquipBaseScore(id);
	end	
	
	--附加属性
	if superVO then
		for i=1,superVO.superNum do
			local vo = superVO.superList[i];
			if vo.id > 0 then
				local cfg = t_fujiashuxing[vo.id];
				superScore = superScore + vo.val1/cfg.attmax*cfg.grade; 
			end
		end
	end
	--卓越属性(得分=最小分+（最大分-最小分）/（最大属性-最小属性）*（当前属性-最小属性）)
	if newSuperList then
		for i=1,#newSuperList do
			local vo = newSuperList[i];
			if vo.id > 0 then
				local cfg = t_zhuoyueshuxing[vo.id];
				local maxVal = 0;
				local minVal = 0;
				local currVal = vo.wash;
				maxVal = cfg.val;
				local attrType = AttrParseUtil.AttMap[cfg.attrType];
				if attrType == enAttrType.eaKillHp then
					maxVal = 1/maxVal;
					currVal = 1/currVal;
				end

				local t = split(cfg.washrange,"#");
				if #t > 0 then
					for _,s in ipairs(t) do
						local rt = split(s,",");
						if #rt > 0 then
							local min = toint(rt[2]);
							if attrType == enAttrType.eaKillHp then
								min = 1/min;
							end
							minVal = minVal==0 and min or (min<minVal and min or minVal);
						end
					end
				end
				local score = cfg.grademin + (cfg.grade-cfg.grademin)*(currVal-minVal)/(maxVal-minVal);
				newSuperScore = newSuperScore + score;
			end
		end
	end
	--套装
	local groupCfg = t_equipgroup[groupId];
	if groupCfg then
		groupScore = groupCfg.grade;
	end
	--新套装
	local newGroupCfg =  t_equipgroup[groupId2];
	if newGroupCfg then
		local groupLvlCfg = EquipUtil:GetGroupLevelCfg( groupId2, groupId2Level )
		local poseattr = groupLvlCfg and groupLvlCfg.poseattr * 0.01 or 0
		groupScore2 = toint( newGroupCfg.grade * (1 + poseattr), -1 )
	end
	return toint(baseScore+superScore+newSuperScore+groupScore+groupScore2,0.5);
	--]]
end

--人物装备基础得分
--基础评分 = 等级 * 品质 * 部位 * 追加 *（1 + 升星）+炼化   
function EquipUtil:GetRoleEquipBaseScore(id,refinLvl,strenLvl,extraLvl)
	refinLvl = refinLvl or 0;
	strenLvl = strenLvl or 0;
	extraLvl = extraLvl or 0;
	local rst = 0;
	local cfg = t_equip[id];
	if not cfg then return 0; end
	local lvlCfg = t_equipgrade[cfg.level];
	if not lvlCfg then return 0; end
	local qualityCfg = t_equipgrade[cfg.quality];
	if not qualityCfg then return 0; end
	local posCfg = t_equipgrade[cfg.pos];
	if not posCfg then return 0; end
	rst = lvlCfg.level * qualityCfg.quality * posCfg.pos;
	local extraCfg = t_equipgrade[extraLvl];
	if extraCfg then
		rst = rst * extraCfg.extra;
	end
	local percent = 1;
	local strenCfg = t_equipgrade[strenLvl];
	if strenCfg then
		percent = percent + strenCfg.stren;
	end
	rst = rst * percent;
	local refinCfg = t_equipgrade[refinLvl];
	if refinCfg then
		rst = rst + refinCfg.refin;
	end
	return rst;
end

--坐骑装备基础得分
function EquipUtil:GetHorseEquipBaseScore(id)
	local cfg = t_equip[id];
	if not cfg then return 0; end
	local lvlCfg = t_equipgrade[cfg.level];
	if not lvlCfg then return 0; end
	local qualityCfg = t_equipgrade[cfg.quality];
	if not qualityCfg then return 0; end
	local posCfg = t_equipgrade[cfg.pos];
	if not posCfg then return 0; end
	return lvlCfg.horseLevel * qualityCfg.horseQuality * posCfg.horsePos;
end

--灵兽装备基础得分
function EquipUtil:GetLingShowEquipBaseScore(id)
	local cfg = t_equip[id];
	if not cfg then return 0; end
	local lvlCfg = t_equipgrade[cfg.level];
	if not lvlCfg then return 0; end
	local qualityCfg = t_equipgrade[cfg.quality];
	if not qualityCfg then return 0; end
	local posCfg = t_equipgrade[cfg.pos];
	if not posCfg then return 0; end
	return lvlCfg.lingshouLevel * qualityCfg.lingshouQuality * posCfg.lingshouPos;
end

--灵兽坐骑装备基础得分
function EquipUtil:GetLingShouHorseEquipBaseScore(id)
	local cfg = t_equip[id];
	if not cfg then return 0; end
	local lvlCfg = t_equipgrade[cfg.level];
	if not lvlCfg then return 0; end
	local qualityCfg = t_equipgrade[cfg.quality];
	if not qualityCfg then return 0; end
	local posCfg = t_equipgrade[cfg.pos];
	if not posCfg then return 0; end
	return lvlCfg.lingshouhorseLevel * qualityCfg.lingshouhorseQuality * posCfg.lingshouhorsePos;
end

--灵阵阵眼基础得分
-- function EquipUtil:GetLingZhenZhenYanEquipBaseScore(id)
-- 	local cfg = t_equip[id];
-- 	if not cfg then return 0; end
-- 	local lvlCfg = t_equipgrade[cfg.level];
-- 	if not lvlCfg then return 0; end
-- 	local qualityCfg = t_equipgrade[cfg.quality];
-- 	if not qualityCfg then return 0; end
-- 	local posCfg = t_equipgrade[cfg.pos];
-- 	if not posCfg then return 0; end
-- 	return lvlCfg.lingyinLevel * qualityCfg.lingyinQuality * posCfg.lingyinPos;
-- end

--战骑阵眼基础得分
function EquipUtil:GetZhanQiZhenYanEquipBaseScore(id)
	local cfg = t_equip[id];
	if not cfg then return 0; end
	local lvlCfg = t_equipgrade[cfg.level];
	if not lvlCfg then return 0; end
	local qualityCfg = t_equipgrade[cfg.quality];
	if not qualityCfg then return 0; end
	local posCfg = t_equipgrade[cfg.pos];
	if not posCfg then return 0; end
	return lvlCfg.qibingLevel * qualityCfg.qibingQuality * posCfg.qibingPos;
end

-- --神灵基础得分
-- function EquipUtil:GetShenLingZhenYanEquipBaseScore(id)
-- 	local cfg = t_equip[id];
-- 	if not cfg then return 0; end
-- 	local lvlCfg = t_equipgrade[cfg.level];
-- 	if not lvlCfg then return 0; end
-- 	local qualityCfg = t_equipgrade[cfg.quality];
-- 	if not qualityCfg then return 0; end
-- 	local posCfg = t_equipgrade[cfg.pos];
-- 	if not posCfg then return 0; end
-- 	return lvlCfg.shenlingLevel * qualityCfg.shenlingQuality * posCfg.shenlingPos;
-- end

--神兵兵魂基础得分
function EquipUtil:GetHunEquipBaseScore(id)
	local cfg = t_equip[id];
	if not cfg then return 0; end
	local lvlCfg = t_equipgrade[cfg.level];
	if not lvlCfg then return 0; end
	local qualityCfg = t_equipgrade[cfg.quality];
	if not qualityCfg then return 0; end
	local posCfg = t_equipgrade[cfg.pos];
	if not posCfg then return 0; end
	return lvlCfg.shenbingLevel * qualityCfg.shenbingQuality * posCfg.shenbingPos;
end

-- 得到装备炼化星级
function EquipUtil:GetRefinLinkId(list)
	local linkid = 0;
	local allReflen = 11
	local curReflen = self:GetLenght(list)
	if curReflen ~= allReflen then 
		return linkid ;
	end;
	local curMiniNum = nil;
	for i,info in pairs(list) do 
		if not curMiniNum then 
			curMiniNum = info.lvl;
		else
			if curMiniNum > info.lvl then 
				curMiniNum = info.lvl;
			end;
		end
	end;
	for l,k in ipairs(t_refinlink) do 
		if curMiniNum >= k.openlvl then
			linkid = k.id;
		else
			break;
		end
	end;
	return  linkid
end;

--炼化提醒
EquipUtil.refinlastTime = 0;
function EquipUtil:IsRemindRefin()
	local timeBo = false;
	local valBo = false;
	local lvlBo = false;
	local curTime = GetDayTime();
	if self.refinlastTime == 0 then 
		self.refinlastTime = curTime;
		timeBo = true;
	else
		local timePoor = curTime - self.refinlastTime;
		if timePoor >= 600 then 
			self.refinlastTime = GetDayTime();
			timeBo = true;
		else
			timeBo = false;
		end;
	end;
	local refinlist = EquipModel:GetRefinList();
	local miniLvl = 300;
	local miniCfg = nil;

	local mylvl = MainPlayerModel.humanDetailInfo.eaLevel;  -- 人物等级
	if mylvl > 0 then 
		return false;
	end;
	local maxNum = 0;
	for i,info in pairs(refinlist) do 
		if info then 
			if info.lvl >= mylvl then 
				maxNum = maxNum + 1;
			end;
			if info.lvl < miniLvl then 
				miniLvl = info.lvl;
				miniCfg = t_refin[info.id];
			end;
		end;
	end;

	if maxNum == 11 then 
		lvlBo = false;
	else
		lvlBo = true;
	end;
	local refinlenght = 0;
	for i,info  in pairs(refinlist) do 
		refinlenght = refinlenght + 1;
	end;
	if refinlenght == 11 then 
		if miniLvl == 300 then 
			valBo = false;
		end;
	else
		miniLvl = 1;
		miniCfg = t_refin[1];
	end;
	if not miniCfg then 
		miniCfg = {};
		miniCfg.consume = 0;
		valBo =  false;
	end;
	local needNum = miniCfg.consume * 5;
	local curNum = MainPlayerModel.humanDetailInfo.eaZhenQi;
	if curNum > needNum then 
		valBo = true;
	else
		valBo = false;
	end;
	if timeBo and valBo and lvlBo then 
		return true;
	end;	
	return false;
end;

function EquipUtil:GetConsumeItem(id)
	local itemId, isEnough;
	local hasEnoughItem = function( item, num )
		return BagModel:GetItemNumInBag( item ) >= num
	end
	local strenLvl = EquipModel:GetStrenLvl(id);
	if strenLvl<EquipConsts.StrenMaxStar then
		-- if hasEnoughItem( EquipConsts.itemLvlUp15Id, 1 ) then
			-- itemId = EquipConsts.itemLvlUp15Id
			-- isEnough = true
		-- else
			itemId = EquipConsts.itemLvlUpId
			isEnough = hasEnoughItem( EquipConsts.itemLvlUpId, 1 )
		--end
	else
		itemId = EquipConsts.itemJZLvlUpId;
		isEnough = hasEnoughItem( EquipConsts.itemJZLvlUpId, 1 );
	end
	return itemId, isEnough
end

function EquipUtil:GetGroupLevelCfg(groupId, groupLevel)
	local cfgIndex = groupId * 100 + groupLevel
	return t_equipgrouphuizhang[cfgIndex]
end

function EquipUtil:GetGroupPosCfg(groupId, pos)
	local cfgIndex = groupId * 100000 + pos
	return t_equipgrouppos[cfgIndex]
end

function EquipUtil:GetGroupPeelBackItem( equipId )
	local itemId, isBind, num
	local equipInfo = EquipModel:GetEquipInfo( equipId )
	if not equipInfo then return end
	local groupCfg = t_equipgroup[equipInfo.groupId2]
	if not groupCfg then return end
	local itemCfg = split(groupCfg.itemId,',')
	itemId = tonumber( itemCfg[1] )
	local num1 = tonumber( itemCfg[2] )
	local num2 = 0
	local groupId2, group2Level = equipInfo.groupId2, equipInfo.group2Level
	if groupId2 and groupId2 > 0 and group2Level and group2Level > 0 then
		for _, cfg in pairs(t_equipgrouphuizhang) do
			if groupId2 == cfg.groupid and cfg.level <= group2Level then
				local consumeNum = tonumber( split(cfg.item, ",")[2] ) or 0
				num2 = num2 + consumeNum
			end
		end
	end
	isBind = equipInfo.groupId2Bind
	num = num1 + num2
	return itemId, isBind, num
end

----------------------------------------------------------------------装备套装-----------------------------------------------------
function EquipUtil:GetEquipGroupId(id)
	if not t_equip[id] then return 0 end
	local extraCfg = t_equipgroupextra[t_equip[id].pos]
	if not extraCfg then return 0 end
	local equipGroupID = split(extraCfg.groupId, ",")
	for i = 1, 3 do
		if self:GetEquipGroupByPos(t_equip[id].pos, 4- i) > 0 then
			return toint(equipGroupID[4- i])
		end
	end
	return 0
end

function EquipUtil:GetEquipGroupByPos(pos, slot)
	local info = SmithingModel.equipGroup[pos]
	if info then
		return info[slot] and info[slot] or -2
	else
		return -2
	end
end

function EquipUtil:GetEquipGroupCfg(pos, slot)
	local extraCfg = t_equipgroupextra[pos]
	local equipGroupID = split(extraCfg.groupId, ",")
	if not equipGroupID[slot] then
		print("装备位未配置套装")
		return
	end
	local nLevel = self:GetEquipGroupByPos(pos, slot)
	return t_equipgrouppos[equipGroupID[slot] * 100000 + pos + 100 * (nLevel < 0 and 0 or nLevel)], nLevel
end

function EquipUtil:GetEquipNextGroupCfg(pos, slot)
	local extraCfg = t_equipgroupextra[pos]
	local equipGroupID = split(extraCfg.groupId, ",")
	if not equipGroupID[slot] then
		print("装备位未配置套装")
		return
	end
	local nLevel = self:GetEquipGroupByPos(pos, slot)
	return t_equipgrouppos[equipGroupID[slot] * 100000 + pos + 100 * (nLevel + 1)], nLevel
end


function EquipUtil:GetGroupIDByType(nType)
	if nType == 1 then
		return split(t_equipgroupextra[1].groupId, ",")
	else
		return split(t_equipgroupextra[7].groupId, ",")
	end
end

local sortFunc = function(a, b)
	return a[2] > b[2]
end

function EquipUtil:getEquipGroupActiveInfo(id)
	local tbList = {}
	for pos, extraCfg in pairs(t_equipgroupextra) do
		local equipGroupID = split(extraCfg.groupId, ",")
		for index, groupId in pairs(equipGroupID) do
			if toint(groupId) == id then
				local nLev = EquipUtil:GetEquipGroupByPos(pos, index)
				if nLev > 0 then
					table.push(tbList, {pos, nLev})
				end
				break
			end
		end
	end
	table.sort(tbList, sortFunc)
	return tbList
end

function EquipUtil:GetGroupInfo(id)
	local tbList = {}
	for pos, extraCfg in pairs(t_equipgroupextra) do
		local equipGroupID = split(extraCfg.groupId, ",")
		for index, groupId in pairs(equipGroupID) do
			if toint(groupId) == id then
				local nLev = EquipUtil:GetEquipGroupByPos(pos, index)
					table.push(tbList, {pos, nLev})
				break
			end
		end
	end
	table.sort(tbList, sortFunc)
	return tbList
end

function EquipUtil:GetGroupActiveNumByType(nType)
	local num = 0
	for k, v in pairs(self:GetGroupIDByType(nType)) do
		if self:getGroupIsHaveActive(toint(v)) then
			num = num + 1
		end
	end
	return num
end

function EquipUtil:getGroupIsHaveActive(id)
	return #self:getEquipGroupActiveInfo(id) > 0
	-- for k, v in pairs(self:getEquipGroupActiveInfo(id)) do
	-- 	if v[2] > 0 then
	-- 		return true
	-- 	end
	-- end
end

function EquipUtil:GetGroupSkillId(groupId)
	local list = {}
	local config = t_equipgrouphuizhang[100*groupId + 1]
	if config.skill1 and config.skill1 ~= 0 then
		table.push(list, config.skill1)
	end
	if config.skill2 and config.skill2 ~= 0 then
		table.push(list, config.skill2)
	end
	if config.skill3 and config.skill3 ~= 0 then
		table.push(list, config.skill3)
	end
	if config.skill4 and config.skill4 ~= 0 then
		table.push(list, config.skill4)
	end

	return list
end

function EquipUtil:GroupIsHaveActiveSkill(groupId, size)
	local list = self:GetEquipGroupAddProAndSkill(groupId)
	return list[size]
end

function EquipUtil:GetEquipGroupAddProAndSkill(id)
	local list = {}
	local info = self:getEquipGroupActiveInfo(id)

	if info[2] then
		-- 两件套
		local cfg = t_equipgrouphuizhang[100*id + info[2][2]]
		if cfg.two_attr and cfg.two_attr ~= "" then
			table.push(list, {2, AttrParseUtil:Parse(cfg.two_attr), cfg.skill1})
		end
	end

	if info[3] then
		--三件套
		local cfg = t_equipgrouphuizhang[100*id + info[3][2]]
		if cfg.three_attr and cfg.three_attr ~= "" then
			table.push(list, {3, AttrParseUtil:Parse(cfg.three_attr), cfg.skill2})
		end
	end

	if info[4] then
		--四件套
		local cfg = t_equipgrouphuizhang[100*id + info[4][2]]
		if cfg.four_attr and cfg.four_attr ~= "" then
			table.push(list, {4, AttrParseUtil:Parse(cfg.four_attr), cfg.skill3})
		end
	end

	if info[6] then
		--六件套
		local cfg = t_equipgrouphuizhang[100*id + info[6][2]]
		if cfg.six_attr and cfg.six_attr ~= "" then
			table.push(list, {6, AttrParseUtil:Parse(cfg.six_attr), cfg.skill4})
		end
	end

	return list
end

function EquipUtil:getEquipGroupAllPro()
	-- 这里处理下孔位属性 加上上面计算的套装属性就OK了

	local pro = {}
	for pos, v in pairs(SmithingModel.equipGroup) do
		local extraCfg = t_equipgroupextra[pos]
		local equipGroupID = split(extraCfg.groupId, ",")
		for slot, lv in pairs(v) do
			if lv >= 0 then
				pro = PublicUtil:GetFightListPlus(pro, 
					AttrParseUtil:Parse(t_equipgrouppos[equipGroupID[slot] * 100000 + pos + 100 * lv].attr))
			end
		end
	end

	for i = 1, 2 do
		local list = EquipUtil:GetGroupIDByType(i)
		for k, v in pairs(list) do
			local groupList = self:GetEquipGroupAddProAndSkill(toint(v))
			for k, v in pairs(groupList) do
				pro = PublicUtil:GetFightListPlus(pro, v[2])
			end
		end
	end
	return pro
end

function EquipUtil:GetEquipGroupLockNum(pos)
	local num = 0
	local info = SmithingModel:GetEquipGroupInfo(pos)
	for i = 1, 3 do
		if not info[i] or info[i] < -1 then
			num = num + 1
		end
	end
	return num
end

-----------------------------------------------------------传承-------------------------------------------------------
---传承第一步判定 至少可以升星或者洗练
function EquipUtil:EquipCanResp(equip)
	local config = t_equip[equip:GetTid()]
	if not config then return false end
	if config.pos>BagConsts.Equip_JieZhi2 or config.pos<BagConsts.Equip_WuQi then
		return false
	end
	if t_extraquality[config.quality].num == 0 and SmithingModel:GetMaxStarCount(equip:GetTid()) == 0 then
		return false
	end
	return true
end


function EquipUtil:IsCanResp(equip)
	local strenInfo = SmithingModel:GetEquipStrenInfo(equip)
	if not strenInfo then
		return false
	end
	local strenLvl = strenInfo.strenLvl
	local washInfo = EquipModel:getWashInfo(equip:GetId())
	if strenLvl <= 0 and #washInfo == 0 then
		--当前装备无法传承
		return false
	end
	return true
end

function EquipUtil:IsCanAcceptResp(selectEquip, acceptEquip)
	-- if t_equip[selectEquip:GetTid()].level > t_equip[acceptEquip:GetTid()].level then
	-- 	return false, -1
	-- end
	if self:IsCanRespStar(selectEquip, acceptEquip) or self:IsCanRespWash(selectEquip, acceptEquip) then
		return true
	end
	return false
end

function EquipUtil:IsCanRespStar(selectEquip, acceptEquip)
	-- 先简单判断一下星级
	if SmithingModel:GetEquipStrenInfo(selectEquip).strenLvl > SmithingModel:GetEquipStrenInfo(acceptEquip).strenLvl then
		return true
	end
end

function EquipUtil:IsEqualPart(selectEquip, acceptEquip)
	return t_equip[selectEquip:GetTid()].pos == t_equip[acceptEquip:GetTid()].pos
end

function EquipUtil:IsCanRespWash(selectEquip, acceptEquip)
	if not self:IsEqualPart(selectEquip, acceptEquip) then
		return false
	end
	if  t_extraquality[t_equip[acceptEquip:GetTid()].quality].num == 0 then
		return false
	end
	if EquipModel:GetWashLvByID(selectEquip:GetId()) > 0 and EquipModel:GetWashLvByID(selectEquip:GetId()) > EquipModel:GetWashLvByID(acceptEquip:GetId()) then
		return true
	end
	return false
end









---------------------------------------------------------------装备操作提示----------------------------------------------------------
function EquipUtil:IsHaveEquipCanStarUp()
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if bagVO then
		for i,pos in ipairs(EquipConsts.EquipStrenType) do
			local item = bagVO:GetItemByPos(pos);
			if item then
				if self:IsCanStarUp(item) then
					return true
				end
			end
		end
	end
	return false
end

function EquipUtil:IsCanStarUp(item)
	local equipInfo = SmithingModel:GetEquipStrenInfo(item)
	if not equipInfo then 
		return
	end
	local strenLvl = equipInfo.strenLvl or 0
	if SmithingModel:GetMaxStarCount(item:GetTid()) <= strenLvl then
		return false
	end
	strenLvl = strenLvl + 1
	if strenLvl > 12 and strenLvl < 24 then
		if equipInfo.emptystarnum == 0 then
			return false
		end
	end
	local config = t_stren[strenLvl];
	local has = BagModel:GetItemNumInBag(config.itemId);
	return has >= config.itemNum
end

function EquipUtil:IsCanStarUpByItem(item, type)
	local equipInfo = SmithingModel:GetEquipStrenInfo(item)
	if not equipInfo then
		return
	end
	local strenLvl = equipInfo.strenLvl or 0
	if SmithingModel:GetMaxStarCount(item:GetTid()) <= strenLvl then
		return false
	end
	if type == 1 and strenLvl >= 12 then
		return false
	end
	if type == 2 and (strenLvl >= 24 or strenLvl <= 12) then
		return false
	end
	return true
end

--[[
	是否有可以升星count次的装备
	与EquipUtil:IsHaveEquipCanStarUp()的区别在于，这个函数规定了升星的次数，当能升星的装备中能升星的次数满足了count，那么返回true
	EquipUtil:IsHaveEquipCanStarUp()只要能升星一次就行了
]]
function EquipUtil:IsHaveEquipCanStarUpByCount(count)
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if bagVO then
		for i,pos in ipairs(EquipConsts.EquipStrenType) do
			local item = bagVO:GetItemByPos(pos);
			if item then
				if self:GetCanStarUpCount(item) >= count then
					return true
				end
			end
		end
	end
	return false
end

function EquipUtil:GetCanStarUpCount(item)
	local equipInfo = SmithingModel:GetEquipStrenInfo(item)
	if not equipInfo then
		return 0
	end
	local strenLvl = equipInfo.strenLvl or 0
	if SmithingModel:GetMaxStarCount(item:GetTid()) <= strenLvl then
		return 0
	end
	strenLvl = strenLvl + 1
	if strenLvl > 12 then
		if equipInfo.emptystarnum == 0 then
			return 0
		end
	end
	local config = t_stren[strenLvl];
	local has = BagModel:GetItemNumInBag(config.itemId);
	return math.floor(has / config.itemNum);
end

function EquipUtil:GetGemOperateValue()
	for i = 0, 10 do
		local value = SmithingModel:GetNoticeStr(i)
		if value == 1 then
			return 1
		elseif value == 3 then
			return 3
		end
	end
	return 0
end

function EquipUtil:IsHaveGemCanIn()
	return self:GetGemOperateValue() == 1
end

function EquipUtil:IsHaveGemCanLvUp()
	return self:GetGemOperateValue() == 3
end

--- 宝石可操作5次
function EquipUtil:IsGemCanOpeTimes(times)
	times = times or 5
	local count = 0
	local flyCount = 0
	local itemCount = 0
	for i = 0, 10 do
		for j,gem in ipairs(SmithingModel:GetEquipByPos(i) and SmithingModel:GetEquipByPos(i).gems or {}) do
			if not SmithingModel:IsGemHoleLocked(gem) then
				if gem.lvLimit <= MainPlayerModel.humanDetailInfo.eaLevel then
					local group = SmithingModel:GetGemGroup(i);
					for k, config in pairs(group) do
						if config.slot == hole and config.level == gem.level + 1 then
							if BagModel:GetItemNumInBag(config.itemfly) > flyCount then
								count = count + 1
								flyCount = flyCount + 1
								if count >= times then
									return true
								end
							elseif BagModel:GetItemNumInBag(config.itemsume) >= config.itemnum + itemCount then
								count = count + 1
								itemCount = itemCount + config.itemNum
							end
							if count >= times then
								return true
							end
						end
					end
				end
			end
		end
	end
	return false
end

function EquipUtil:IsHaveEquipCanWash()
	local bag = BagModel:GetBag(BagConsts.BagType_Role);
	local equips = bag:GetItemListByShowType(BagConsts.ShowType_Equip);

	for k, item in pairs(equips) do
		if self:IsCanWash(item:GetId(), item:GetTid()) then
			return true
		end
	end
	return false
end

function EquipUtil:IsCanWash(id, tid)
	local washInfo = EquipModel:getWashInfo(id)
	local itemCfg = t_equip[tid]
	local lvConfig = t_extraclass[itemCfg.level]
	local qualityConfig = t_extraquality[itemCfg.quality]
	for i = 1, qualityConfig.num do
		local info = washInfo[i]
		if info then
			local cfg = t_extraatt[info.id]
			if cfg.lv < lvConfig.maxLv then
				local cost = split(qualityConfig.cost, ',')
				if BagModel:GetItemNumInBag(toint(cost[1])) >= toint(cost[2]) then
					return true
				end
			end
		else
			local cost = split(qualityConfig.activate, ',')
			if BagModel:GetItemNumInBag(toint(cost[1])) >= toint(cost[2]) then
				return true
			end
		end
	end
	return false
end
--[[
	是否有可以洗练count次的装备
	与EquipUtil:IsHaveEquipCanWash()的区别在于，这个函数规定了洗练的次数，当能洗练的装备中能洗练的次数满足了count，那么返回true
	EquipUtil:IsHaveEquipCanWash()只要能升星一次就行了
]]
function EquipUtil:IsHaveEquipCanWashByCount(count)
	local bag = BagModel:GetBag(BagConsts.BagType_Role);
	local equips = bag:GetItemListByShowType(BagConsts.ShowType_Equip);

	for k, item in pairs(equips) do
		if self:CanWashCount(item:GetId(), item:GetTid()) >= count then
			return true
		end
	end
	return false
end

function EquipUtil:CanWashCount(id, tid)
	local washInfo = EquipModel:getWashInfo(id)
	local itemCfg = t_equip[tid]
	local lvConfig = t_extraclass[itemCfg.level]
	local qualityConfig = t_extraquality[itemCfg.quality]
	for i = 1, qualityConfig.num do
		local info = washInfo[i]
		if info then
			local cfg = t_extraatt[info.id]
			if cfg.lv < lvConfig.maxLv then
				local cost = split(qualityConfig.cost, ',')
				return math.floor(BagModel:GetItemNumInBag(toint(cost[1])) / toint(cost[2]));
			end
		else
			local cost = split(qualityConfig.activate, ',')
			return math.floor(BagModel:GetItemNumInBag(toint(cost[1])) / toint(cost[2]));
		end
	end
	return 0;
end

function EquipUtil:IsHaveEquipGroupCanOperate()
	for i = 1, 10 do
		for j = 1, 3 do
			local cfg, nLevel = EquipUtil:GetEquipGroupCfg(i, j)
			local nextCfg = EquipUtil:GetEquipNextGroupCfg(i, j)
			local cost
			if nLevel == -2 then
				cost = split(cfg.unlock, ',')
			elseif nLevel == -1 then
				cost = split(cfg.activate, ',')
			elseif nextCfg then
				cost = split(nextCfg.item, ',')
			end
			if cost then
				if BagModel:GetItemNumInBag(toint(cost[1])) >= toint(cost[2]) then
					return true
				end
			end
		end
	end
end

function EquipUtil:IsCanLvUpRing()
	local uid = SmithingModel:GetRingCid()
	if not uid then return false end

	local lv = SmithingModel:GetRingLv()
	local cfg = t_ring[lv]
	if not cfg then return false end
	if not t_ring[lv + 1] then
		return false
	end

	if MainPlayerModel.humanDetailInfo.eaLevel < cfg.needlv then
		return false
	end

	if not cfg.consume or cfg.consume == "" then
		local monsterInfo = split(cfg.killmonster, ",")
		if SmithingModel:GetRingTaskNum() < toint(monsterInfo[2]) then
			return false
		end
	else
		local cost = split(cfg.consume, ",")
		local has = BagModel:GetItemNumInBag(toint(cost[1]));
		if has < toint(cost[2]) then
			return false
		end
	end
	return true
end

function EquipUtil:IsNewEquipCanAcceptResp(equip)
	local bag = BagModel:GetBag(BagConsts.BagType_Bag);
	local equips = bag:GetItemListByShowType(BagConsts.ShowType_Equip);
	for k, v in pairs(equips) do
		if self:IsCanAcceptResp(v, equip) then
			return true, v:GetId()
		end
	end
end

function EquipUtil:HasEquipCanAccpetResp(id, id2)
	local roleEquipBag = BagModel:GetBag(BagConsts.BagType_Role);
	local equip = roleEquipBag:GetItemById(id)

	local Bag = BagModel:GetBag(BagConsts.BagType_Bag);
	local equip2 = Bag:GetItemById(id2)
	if equip and equip2 then
		return self:IsCanAcceptResp(equip2, equip)
	end
	return false;
end

function EquipUtil:IsHaveRelicCanLvUp()
	-- 只判断身上穿的
	for i = 1, 3 do
		if self:IsRelicCanLvUp(i) then
			return true
		end
	end
	return false
end

function EquipUtil:IsRelicCanLvUp(i)
	local list = BagUtil:GetBagItemList(BagConsts.BagType_RELIC,BagConsts.ShowType_All)
	if list then
		if list[i] and list[i].hasItem then
			local relicID = list[i].relicLv
			local cfg = t_newequip[relicID]
			if cfg then
				local nextCfg = t_newequip[relicID + 1]
				if nextCfg then
					if nextCfg.astrict <= MainPlayerModel.humanDetailInfo.eaLevel and MainPlayerModel.humanDetailInfo.eaBindGold >= nextCfg.num then
						return true
					end
				end
			end
		end
	end
	return false
end

--- 获取我身上品质在5-7之间的装备数量以及属性加成
function EquipUtil:GetNewEquipGroupInfo()
	local equipList = {}
	local count = 0
	local attr = {}
	local bag = BagModel:GetBag(BagConsts.BagType_Role);
	
	for i = 0, 10 do
		local equip = bag:GetItemByPos(i)
		if equip then
			local cfg = t_equip[equip:GetTid()]
			if cfg.quality >= BagConsts.Quality_Green1 and cfg.quality <= BagConsts.Quality_Green3 then
				equipList[cfg.pos] = 1
				count = count + 1
				attr = PublicUtil:GetFightListPlus(attr, AttrParseUtil:Parse(cfg.baseAttr))
			end
		end
	end

	local valueInfo = t_consts[324]
	local per = 0
	if count >= 6 and count < 9 then
		per = valueInfo.val1
	elseif count >= 9 and count < 11 then
		per = valueInfo.val2
	elseif count == 11 then
		per = valueInfo.val3
	else
		attr = {}
	end
	for k, v in pairs(attr) do
		attr[k].val = math.ceil(attr[k].val * per/100)
	end
	return {count, equipList, attr}
end
--[[
SkillUtil
lizhuangzhuang
2014年8月23日12:38:56
]]

_G.SkillUtil = {};

SkillUtil.debugQuickly = false;
SkillUtil.frameType = -1;
SkillUtil.pointType = -1;
SkillUtil.additiveType = -1;
SkillUtil.additiveId = -1;
--获取主界面技能列表
function SkillUtil:GetMainPageSkillList()
	local list = {};
	for i=0,#SkillConsts.KeyMap do
		local slotVO = SkillSlotVO:new();
		local skillInfo = SkillModel:GetShortcutListByPos(i);
		slotVO.pos = i;
		if skillInfo and skillInfo.skillId>0 then
			slotVO.hasSkill = true;
			slotVO:SetSkillId(skillInfo.skillId);
			slotVO.consumEnough = SkillController:CheckConsume(skillInfo.skillId)==1;
			slotVO.hideSet = skillInfo.hideSet;
			slotVO.frameType = self.frameType;
			slotVO.pointType = self.pointType;
		else
			slotVO.hasSkill = false;
		end
		slotVO.hideSet = slotVO.hideSet or false;
		table.push(list,slotVO);
	end
	return list;
end

function SkillUtil:SetFrameType(type)
	self.frameType = type;
end

function SkillUtil:SetPointType(type)
	self.pointType = type;
end

function SkillUtil:SetAdditiveType(type)
	self.additiveType = type;
end

function SkillUtil:SetAdditiveId(id)
	self.additiveId = id;
end

function SkillUtil:GetSkillSolotVO(skill,sizeIcon)
	local vo = SkillSlotVO:new();
	vo.pos = skill.pos;
	if skill and skill.skillId>0 then
		vo.hasSkill = true;
		vo:SetSkillId(skill.skillId);
		vo.consumEnough = SkillController:CheckConsume(skill.skillId)==1;
		vo.hideSet = skill.hideSet;
		vo.sizeIcon=sizeIcon
		vo.frameType = self.frameType;
		vo.pointType = self.pointType;
	else
		vo.hasSkill = false;
	end
	vo.hideSet = vo.hideSet or false;
	return vo;
end

function SkillUtil:IsShortcutSkill(skillId)
	for i = 6, 15 do
		local skillInfo = SkillModel:GetShortcutListByPos(i)
		if skillInfo and skillInfo.skillId == skillId and t_skill[skillInfo.skillId] and t_skill[skillInfo.skillId].showtype >= SkillConsts.ShowType_Juexue1 and t_skill[skillInfo.skillId].showtype <= SkillConsts.ShowType_Juexue4 then
			return true
		end
	end
	return false
end

--根据显示类型获取技能列表
--返回list,vo{skillId,lvl}
function SkillUtil:GetSkillListByShow(showType)
	local cfg = t_skill;
	return SkillUtil:FilterShowTypeInCfgSkill(showType,cfg);  --FilterShowTypeInCfg
end

function SkillUtil:GetSkillListByShowMagicSkill(showType)
	local cfg = t_skill;
	return SkillUtil:FilterShowTypeInCfgSkill(showType,cfg);
end

--根据显示类型获取被动技能列表
function SkillUtil:GetPassiveSkillListByShow(showType)        --被动技能的显示类型是60
	local cfg = t_passiveskill;
	return SkillUtil:FilterShowTypeInCfgs(showType,cfg);
end

-----------------------通用技能-------------------
function SkillUtil:GetSkillListShowDzz(showType)
	local cfg = t_skill;
	return SkillUtil:FilterShowTypeInCfg(showType,cfg);  
end
function SkillUtil:GetPassiveSkillListShowDzz(showType)
	local cfg = t_passiveskill;
	return SkillUtil:FilterShowTypeInCfg(showType,cfg);
end
function SkillUtil:FilterShowTypeInCfg(showType,cfgT)
	if not cfgT then return; end
	if not showType then return; end
	local list = {};
	for k,cfg in pairs(cfgT) do
		if cfg.showtype==showType and cfg.level==1 then
			local userSkillVO = SkillModel:GetSkillInGroup(cfg.group_id);
			local vo = {};
			if userSkillVO then
				vo.skillId = userSkillVO:GetID();
				vo.lvl = userSkillVO:GetLvl();
				vo.cfg = cfg;
			else
				vo.skillId = cfg.id;
				vo.lvl = 0;
				vo.cfg = cfg;
			end
			table.push(list,vo);
		end
	end
	table.sort(list,function(A,B)
		local groupA = t_skillgroup[A.cfg.group_id];
		local groupB = t_skillgroup[B.cfg.group_id];
		return groupA.index < groupB.index;
	end);
	return list;
end



--过滤配表中的显示类型
function SkillUtil:FilterShowTypeInCfgs(showType,cfgT)
	if not cfgT then return; end
	if not showType then return; end
	local list = {};
	local gid = nil;
	for k,cfg in pairs(cfgT) do
		if cfg.showtype==showType and cfg.level==1 then 
			for k,v in pairs(t_xinfazu) do
				if cfg.id == v.startid then
					gid = v.id;
				end
			end

			local userSkillVO = SkillModel:GetSkillVo(gid);
			local vo = {};
			if userSkillVO then    --有数据
				vo.skillId = userSkillVO:GetID();
				vo.lvl = userSkillVO:GetLvl();
				vo.cfg = cfg;
				table.push(list,vo);
			else                   
				if showType == 60 then 
					for k,v in pairs(t_xinfazu) do   
						if v.startid == cfg.id then
							vo.skillId = v.startid
							vo.lvl = 0;
							vo.cfg = cfg;
							table.push(list,vo);
						end
					end
				end
			end  
		end										
	end    										
	table.sort( list, function(A,B) 
		local a = t_passiveskill[A.skillId]
		local b = t_passiveskill[B.skillId]
		return a.id< b.id
	end);
	return list;
end
--过滤配表中的显示类型
function SkillUtil:FilterShowTypeInCfgSkill(showType,cfgT)
	if not cfgT then return; end
	if not showType then return; end
	local list = {};
	local gid ;
	for k,cfg in pairs(cfgT) do
		if cfg.showtype==showType and cfg.level==1 then   --跟具类型确定是在技能表里面的初始技能
			local userSkillVO = nil
			if showType >= 5 and showType <= 8 then
				-- local gid = math.floor(cfg.id / 10000);
				for k,v in pairs(t_juexuezu) do
					if cfg.id == v.startid then
						gid = v.id;
					end
				end
				userSkillVO = SkillModel:GetSkillVo(gid);
			else
				userSkillVO = SkillModel:GetSkillInGroup(cfg.group_id);
			end
			local vo = {};
			if userSkillVO then
				vo.skillId = userSkillVO:GetID();
				vo.lvl = userSkillVO:GetLvl();
				vo.cfg = cfg;
				table.push(list,vo);
			else
				if showType >= 5 and showType <=8 then 
					for k,v in pairs(t_juexuezu) do     --绝学的初始化数据从juexuzu这张表里面进行读取
						if v.startid == cfg.id then
							vo.skillId = v.startid
							vo.lvl = 0;
							vo.cfg = cfg;
							table.push(list,vo);
						end
					end
				else                                    --普通技能
					vo.skillId = cfg.id;
					vo.lvl = 0;
					vo.cfg = cfg;
					table.push(list,vo);
				end
			end
		end										
	end    										
	table.sort( list, function(A,B) 
		local a = t_skill[A.skillId]
		local b = t_skill[B.skillId]
		if a == nil or b == nil then return list; end
		return a.group_id < b.group_id    -- changer:hoxudong date:2016-7-21 reason:按照组id进行排序，之前按照的是技能id
	end);
	return list;
end

--获取技能的最大等级
function SkillUtil:GetSkillMaxLvl(skillId)
	local cfg = t_skill[skillId] or t_passiveskill[skillId];
	if not cfg then return; end
	local maxLvl = cfg.level;
	if t_skillgroup[cfg.group_id] then
		maxLvl = t_skillgroup[cfg.group_id].maxLvl;
	end
	return maxLvl;
end

--获取一个技能可升级到最大等级技能
function SkillUtil:GetMaxSkillID(skillId)
	local cfg = t_skill[skillId];
	if not cfg then return 0; end
	while cfg.next_lv >0 do
		cfg = t_skill[cfg.next_lv];
		if not cfg then return 0; end
	end
	return cfg.id;
end

--获取一个被动技能可升级的最大等级技能
function SkillUtil:GetMaxPassiveSkillID(skillId)
	local cfg = t_passiveskill[skillId];
	if not cfg then return 0; end
	while cfg.next_lv >0 do
		cfg = t_passiveskill[cfg.next_lv];
		if not cfg then return 0; end
	end
	return cfg.id;
end

--获取技能的升级条件
--@param learn 是否是学习技能
--list vo{type:1等级2金币3灵力4物品5特殊条件(坐骑等级)6特殊条件(神兵等级)7特殊条件(宝甲等级)8武魂9灵阵10骑战11神灵12兵灵16战弩
--;id;num:数量;currNum:当前数量;state:true达成false不足},isPassSkill心法标识符
local isFirst = false;  
local currLvl = 1000000;
local currSkillId = 0;
local isPassSkill = false;
function SkillUtil:GetLvlUpCondition(skillId,learn,level,IsPassSkill)   ---学习时 learn == true   升级时 learn == false
	local cfg = nil;
	isFirst = learn
	if learn == nil then
		isFirst = false
	end
	currLvl = level
	if level == nil then
		currLvl = -1000000
	end
	currSkillId = skillId
	isPassSkill = IsPassSkill;
	if skillId < 1000000000 then             --主动技能
		cfg = t_skill[skillId];
	else
		cfg = t_passiveskill[skillId];       --被动技能
	end
	if not cfg then return {}; end
	local list = {};
	local baseCondition = SkillUtil:GetBaseLvlCon(cfg);
	if not baseCondition then
		return {};
	end
	for i,vo in ipairs(baseCondition) do
		table.push(list,vo);
	end
	local specailCondition = SkillUtil:GetSpecialLvlCon(cfg);
	for i,vo in ipairs(specailCondition) do
		table.push(list,vo);
	end
	return list;
end

----just for skill  adder:houxudong date:2016/6/6 21:43
--@adder:新增物品消耗时也提示 date:2016/7/21
function SkillUtil:GetLvlUpConditionForSkill(skillId,learn,level)
	local cfg = nil;
	isFirst = learn
	if learn == nil then
		isFirst = false
	end
	currLvl = level
	if level == nil then
		currLvl = -1000000
	end

	if skillId < 1000000000 then
		cfg = t_skill[skillId];
		if not learn then
			if cfg and cfg.next_lv then
				cfg = t_skill[cfg.next_lv];
			end
		end
	else
		cfg = t_passiveskill[skillId];
		if not learn then
			if cfg and cfg.next_lv then
				cfg = t_passiveskill[cfg.next_lv];
			end
		end
	end
	if not cfg then return {}; end
	local list = {};
	local baseCondition = SkillUtil:GetBaseLvlCon(cfg);
	for i,vo in ipairs(baseCondition) do
		table.push(list,vo);
	end
	local specailCondition = SkillUtil:GetSpecialLvlCon(cfg);
	for i,vo in ipairs(specailCondition) do
		table.push(list,vo);
	end
	return list;
end


--获取技能学习升级的基础条件
function SkillUtil:GetBaseLvlCon(cfg)
	local list = {};
	local skillId = cfg.id;
	local playInfo = MainPlayerModel.humanDetailInfo;
	local breachList = {};
	local tuPoItemList = {}
	-- print("++++++++cfg.needLvl",cfg.needLvl,skillId)
	if cfg.needLvl > 0 then
		local vo = {};
		vo.type = 1;
		vo.id = 0;
		vo.num = cfg.needLvl;
		vo.currNum = playInfo.eaLevel;
		vo.state = playInfo.eaLevel>=cfg.needLvl;
		table.push(list,vo);
	end
	-- print("++++++++cfg.needMoney",cfg.needMoney)
	if cfg.needMoney > 0 then
		local vo = {};
		vo.type = 2;
		vo.id = 0;
		vo.num = cfg.needMoney;
		vo.num = toint(vo.num,-1);
		-- 非绑定银两作废，现在只用绑定银两
		vo.currNum = playInfo.eaBindGold  --+playInfo.eaUnBindGold);
		vo.state = playInfo.eaBindGold >= vo.num;
		table.push(list,vo);
	end
	if cfg.needZhenQi > 0 then
		local vo = {};
		vo.type = 3;
		vo.id = 0;
		vo.num = cfg.needZhenQi;
		vo.num = toint(vo.num,-1);
		vo.currNum = playInfo.eaZhenQi;
		vo.state = playInfo.eaZhenQi>=vo.num;
		table.push(list,vo);
	end
	if cfg.needItem ~="" and currLvl < 0 then
		local itemList = split(cfg.needItem,"#");
		for k,itemStr in pairs(itemList) do
			local arr = split(itemStr,",");
			local vo = {};
			vo.type = 4;
			vo.id = toint(arr[1]);
			vo.num = toint(arr[2]);
			vo.currNum = BagModel:GetItemNumInBag(vo.id);
			vo.state = vo.currNum>=vo.num;
			table.push(list,vo);
		end
	end
	if cfg.needItem == "" and currLvl == 0 then
		local column;
		for k,v in pairs(t_juexuezu) do
			if v.startid == skillId then
				column = v.id;
			end
		end
		local cfg = nil;
		cfg = t_juexuezu[column]   --从绝学组表里面读取所需要物品的id和数量

		if isPassSkill then
			for k,v in pairs(t_xinfazu) do
				if v.startid == skillId then
					column = v.id;
				end
			end
			cfg = t_xinfazu[column]   --从心法组表里面读取所需要物品的id和数量
		end
		if not cfg then return; end
		local itemList = {}
		for k,v in pairs(cfg.needItem) do
			table.push(itemList,v)
		end
		local vo = {}
		vo.type = 4;                  --消耗物品
		vo.id = toint(itemList[1]);   --物品的id
		vo.num = toint(itemList[2]);  --物品的数量
		vo.currNum = BagModel:GetItemNumInBag(vo.id);
		vo.state = vo.currNum >= vo.num;
		table.push(list,vo);
	end

	if cfg.needItem == "" and isFirst  == false and currLvl > 0 then   --进入juexue表或者xinfa表读取消耗的配置
		local column;
		for k,v in pairs(t_juexue) do
			if v.id == currSkillId and v.spot == currLvl then
				column = v.column;
			end
		end
		local cfg = nil;
		cfg = t_juexue[column]   --从绝学表里面读取所需要物品的id和数量
		if isPassSkill then
			for k,v in pairs(t_xinfa) do
				if v.id == currSkillId and v.spot == currLvl then
					column = v.column;
				end
			end
			cfg = t_xinfa[column]   --从心法组表里面读取所需要物品的id和数量
		end
		if not cfg then return; end
		local itemList = {}
		for k,v in pairs(cfg.needItem) do
			table.push(itemList,v)
		end
		
		if currLvl == 10 then  --SkillUtil:GetSkillMaxLvl(currSkillId)
			if not cfg.breach or not cfg.consume then return; end 
			tuPoItemList = split(cfg.consume,",")
			if tuPoItemList[1] == 0 or tuPoItemList[2] == 0 then return; end
		end
		local vo = {}
		vo.type = 4;                  		--消耗物品
		vo.id = toint(itemList[1]) or 0;   	--物品的id
		vo.num = toint(itemList[2]) or 0;  	--物品的数量
		vo.currNum = BagModel:GetItemNumInBag(vo.id);
		vo.state = vo.currNum >= vo.num;
		vo.breach = false;
		if #tuPoItemList ~= 0 then 
			vo.id = toint(tuPoItemList[1]) or 0;                              -- 14  代表灵力
			vo.num = toint(tuPoItemList[2]) or 0;
			local iHave = 0
			if vo.id < 100 then
				iHave = MainPlayerModel.humanDetailInfo.eaBindGold
			else
				iHave = BagModel:GetItemNumInBag(vo.id);
			end
			vo.breach = iHave >= vo.num ;  --突破消耗灵气--状态
			vo.nextskillId = cfg.breach   --突破后的技能等级
		end
		table.push(list,vo);
	end
	return list;
end

--获取技能学习升级的特殊条件
function SkillUtil:GetSpecialLvlCon(cfg)
	if cfg.needSpecail <= 0 then return {}; end
	local list = {};
	--坐骑
	if cfg.showtype == SkillConsts.ShowType_Horse then
		local vo = {};
		vo.type = 5;
		vo.id = 0;
		vo.num = cfg.needSpecail;

		vo.currNum = MountModel.ridedMount.mountLevel;
		vo.state = vo.currNum>=vo.num;
	
		table.push(list,vo);
	elseif cfg.showtype == SkillConsts.ShowType_MagicWeapon then
		local vo = {};
		vo.type = 6;
		vo.id = 0;
		vo.num = cfg.needSpecail;
		vo.currNum = MagicWeaponModel:GetLevel();
		vo.state = vo.currNum>=vo.num;
		table.push(list,vo);
	elseif cfg.showtype == SkillConsts.ShowType_WuHun then
		local vo = {};
		vo.type = 8;
		vo.id = 0;
		vo.num = cfg.needSpecail;
		vo.currNum = SpiritsModel:GetLevel()
		vo.state = vo.currNum>=vo.num;
		table.push(list,vo);
	elseif cfg.showtype == SkillConsts.ShowType_QiZhan or cfg.showtype == SkillConsts.ShowType_QiZhanPassive then
		local vo = {};
		vo.type = 10;
		vo.id = 0;
		vo.num = cfg.needSpecail;
		vo.currNum = QiZhanModel:GetLevel() - QiZhanConsts.Downid;
		vo.state = vo.currNum>=vo.num;
		table.push(list,vo);
	elseif cfg.showtype == SkillConsts.ShowType_ShenWuPassive then
		local vo = {};
		vo.type = 14;
		vo.id = 0;
		vo.num = cfg.needSpecail;
		vo.currNum = ShenWuModel:GetLevel();
		vo.state = vo.currNum>=vo.num;
		table.push(list,vo);
	elseif cfg.showtype == SkillConsts.ShowType_LingQi then
		local vo = {};
		vo.type = 15;
		vo.id = 0;
		vo.num = cfg.needSpecail;
		vo.currNum = LingQiModel:GetLevel();
		vo.state = vo.currNum>=vo.num;
		table.push(list,vo);
	elseif cfg.showtype == SkillConsts.ShowType_MingYu then
		local vo = {};
		vo.type = 16;
		vo.id = 0;
		vo.num = cfg.needSpecail;
		vo.currNum = MingYuModel:GetLevel();
		vo.state = vo.currNum>=vo.num;
		table.push(list,vo);
	elseif cfg.showtype == SkillConsts.ShowType_Armor then
		local vo = {};
		vo.type = 17;
		vo.id = 0;
		vo.num = cfg.needSpecail;
		vo.currNum = ArmorModel:GetLevel();
		vo.state = vo.currNum>=vo.num;
		table.push(list,vo);
	end
	--
	for _,vo in ipairs(list) do
		vo.skillId = cfg.id;
	end
	return list;
end

--获取学习升级条件
--@return 名字,数量
function SkillUtil:GetConditionStr(vo)
	if vo.type == 1 then
		return StrConfig['commonAttr6'],string.format(StrConfig['skill107'],vo.num);
	elseif vo.type == 2 then
		return StrConfig['commonAttr11'],vo.num;
	elseif vo.type == 3 then
		return StrConfig['commonAttr14'],vo.num;  --修为
	elseif vo.type == 4 then
		local itemCfg = t_item[vo.id];
		if not itemCfg then return "",""; end
		return itemCfg.name, string.format("(%s/%s)",vo.currNum,vo.num);  --学习时物品的消耗 
	elseif vo.type == 5 then
		return StrConfig["skill111"], vo.num;
	elseif vo.type == 6 then
		return StrConfig["magicWeapon001"], vo.num;
	elseif vo.type == 7 then
		return StrConfig["baojia001"], vo.num;
	elseif vo.type == 8 then
		return StrConfig["wuhun57"], vo.num;
	elseif vo.type == 9 then
		return StrConfig["lingzhen1"], vo.num;
	elseif vo.type == 10 then
		return StrConfig["qizhan1"], vo.num;
	elseif vo.type == 12 then
		return StrConfig["magicWeapon053"], vo.num;
	elseif vo.type == 14 then
		return StrConfig["shenwu23"], vo.num;
	elseif vo.type == 15 then
		return StrConfig["lingQi001"], vo.num;
	elseif vo.type == 16 then
		return StrConfig["mingYu001"], vo.num;
	elseif vo.type == 17 then
		return StrConfig["armor001"], vo.num;
	end
	
	return "","";
end

--获得设置物品框里的物品是否能切换新的生命之石
function SkillUtil:GetIsChangeSCItem(tid)
	if BagModel:GetItemNumInBag(tid) <= 0 then
		return false;
	end
	if SkillModel.shortCutItem == tid then
		return false;
	end
	return true;
end

--当绝学可以学习的时候也有红点显示
--adder:houxudong date:2016/7/28
function SkillUtil:CheckJuexueCanLvlUp()
	local list;
	list = self:GetSkillListByShow(SkillConsts:GetBasicShowType() + 4);
	--过滤普攻和最高级技能
	for i=#list,1,-1 do
		local vo = list[i];
		local cfg = t_skill[vo.skillId];
		local maxLvl = cfg.level;
		if t_skillgroup[cfg.group_id] then
			maxLvl = t_skillgroup[cfg.group_id].maxLvl;
		end
		if maxLvl<=1 or vo.lvl==maxLvl then
			table.remove(list,i);
		end
	end
	if #list < 0 then return false; end
	for i,vo in ipairs(list) do
		if vo.lvl > 0 then
			local conditionlist = self:GetLvlUpCondition(vo.skillId,false,vo.lvl);
			local canLvlUp = true;
			for i,conditionVo in ipairs(conditionlist) do
				if conditionVo.state == false then
					canLvlUp = false;
					break;
				else
					canLvlUp = true
				end
				if vo.lvl == 10 then
					if conditionVo.breach then
						canLvlUp = true
					else
						canLvlUp = false
						break;
					end
				end
				
			end
			if canLvlUp then
				return true;
			end
		elseif vo.lvl == 0 then
			local conditionlist = SkillUtil:GetLvlUpCondition(vo.skillId,true,vo.lvl);
			local canLvlUp = true;
			for i,conditionVo in ipairs(conditionlist) do
				if not conditionVo.state then
					canLvlUp = false;
					break;
				end
			end
			-- WriteLog(LogType.Normal,true,'-------------houxudong2',canLvlUp)
			if canLvlUp then
				return true;
			end
		end
	end
	return false;
end

--当绝学可以学习的时候也有红点显示
--adder:houxudong date:2016/7/28
function SkillUtil:CheckXinfaCanLvlUp()
	local list = self:GetPassiveSkillListByShow(SkillConsts.ShowType_JuxuePassive);
		--过滤普攻和最高级技能
	for i=#list,1,-1 do
		local vo = list[i];
		local cfg = t_passiveskill[vo.skillId];
		local maxLvl = cfg.level;
		if t_skillgroup[cfg.group_id] then
			maxLvl = t_skillgroup[cfg.group_id].maxLvl;
		end
		if maxLvl<=1 or vo.lvl==maxLvl then
			table.remove(list,i);
		end
	end
	-- WriteLog(LogType.Normal,true,'-------------houxudong0',#list)
	if #list < 0 then return false; end
	for i,vo in ipairs(list) do
		if vo.lvl > 0 then    --升级，突破 
			local conditionlist = self:GetLvlUpCondition(vo.skillId,false,vo.lvl,true);
			local canLvlUp = true;
			for i,conditionVo in ipairs(conditionlist) do
				if conditionVo.state == false then
					canLvlUp = false;
					break;
				else
					canLvlUp = true
				end
				if vo.lvl == 10 then
					if conditionVo.breach then
						canLvlUp = true
					else
						canLvlUp = false
						break;
					end
				end
				
			end
			-- WriteLog(LogType.Normal,true,'-------------houxudong升级突破',canLvlUp)
			if canLvlUp then
				return true;
			end
		elseif vo.lvl == 0 then  --学习
			local conditionlist = SkillUtil:GetLvlUpCondition(vo.skillId,true,vo.lvl,true);
			local canLvlUp = true;
			for i,conditionVo in ipairs(conditionlist) do
				if not conditionVo.state then
					canLvlUp = false;
					break;
				end
			end
			-- WriteLog(LogType.Normal,true,'-------------houxudong 学习',canLvlUp)
			if canLvlUp then
				return true;
			end
		end
	end
	return false;
end
-- 检测功能是否开启
function SkillUtil:CheckSkillsFunc(id)
	local curRoleLvl = MainPlayerModel.humanDetailInfo.eaLevel
	local cfg = t_funcOpen[id];
	if not cfg then return false; end
	local openLevel = cfg.open_level
	if not openLevel then return false end
	if curRoleLvl >= toint(openLevel) then
		return true
	end
	return false,openLevel
end

--[[
DailyMustDoUtil
zhangshuhui
2015年3月18日14:50:00
]]

_G.DailyMustDoUtil = {};

--获取list
function DailyMustDoUtil:GetDailyMustDoList(type, style)
	local playerinfo = MainPlayerModel.humanDetailInfo;
	local list = {};
	for i, vo in pairs(t_bizuo) do
		if vo then
			if vo.type == 3 or vo.type - 1 == type then
				if playerinfo.eaLevel >= vo.level then
					if vo.type == 3 then
						if self:GetDailyMustNum(vo.id, type) >= 0 then
							if style == 0 then
								table.insert(list, vo);
							elseif vo.style == style then
								table.insert(list, vo);
							end
						end
					else
						if self:GetDailyMustNum(vo.id, type) >= 0 then
							if vo.type - 1 == type and style == 0 then
								table.insert(list, vo);
							elseif vo.type - 1 == type and vo.style == style then
								table.insert(list, vo);
							end
						end
					end
				end
			end
		end
	end

	table.sort(list, function(A, B)
		if A.id < B.id then
			return true;
		else
			return false;
		end
	end);
	return list;
end

--得到剩余次数
function DailyMustDoUtil:GetDailyMustNum(id, type)
	local vo = DailyMustDoModel:GetDailyVo(id);
	if vo then
		--今日必做
		if type == DailyMustDoConsts.typetoday then
			if vo.todaynum then
				return vo.todaynum;
			end

			--昨日追回
		elseif type == DailyMustDoConsts.typeyesterday then
			if vo.runnum then
				return vo.runnum;
			end
		end
	end

	return -1;
end

--得到该类型活动的总个数
function DailyMustDoUtil:GetDailyMustDoNum(type)
	local num = 0;
	local list = DailyMustDoModel:GetDailyList();
	for i, vo in pairs(list) do
		if vo then
			if type == DailyMustDoConsts.typetoday and vo.todaynum > 0 then
				num = num + 1;
			elseif type == DailyMustDoConsts.typeyesterday and vo.runnum > 0 then
				num = num + 1;
			end
		end
	end

	return num;
end

--得到奖励比值
function DailyMustDoUtil:GetRewardPecent(id, type, consumetype)
	local vo = t_bizuo[id];
	if not vo then
		return 0;
	end

	local playerinfo = MainPlayerModel.humanDetailInfo;

	local strpct = "";

	if type == DailyMustDoConsts.typetoday then
		--元宝
		if consumetype == DailyMustDoConsts.typeyuanbao then
			strpct = split(vo.viptodaypecent, ",");
			--银两
		elseif consumetype == DailyMustDoConsts.typeyinliang then
			strpct = split(vo.todaypecent, ",");
		end

		if playerinfo.eaLevel < 80 then
			return strpct[1];
		elseif playerinfo.eaLevel < 100 then
			return strpct[2];
		elseif playerinfo.eaLevel < 120 then
			return strpct[3];
		else
			return strpct[4];
		end
	elseif type == DailyMustDoConsts.typeyesterday then
		--元宝
		if consumetype == DailyMustDoConsts.typeyuanbao then
			return vo.viprunpecent;
			--银两
		elseif consumetype == DailyMustDoConsts.typeyinliang then
			return vo.runpecent;
		end
	end

	return 0;
end

--得到金钱消耗
function DailyMustDoUtil:GetConsumeNum(id, type, consumetype)
	local vo = t_bizuo[id];
	if not vo then
		return 0;
	end

	local num = 0;
	for i, vo in pairs(DailyMustDoModel.finishdailylist) do
		if vo then
			if vo.id == id then
				if type == DailyMustDoConsts.typetoday then
					num = vo.todaynum;
				elseif type == DailyMustDoConsts.typeyesterday then
					num = vo.runnum;
				end
			end
		end
	end

	if num <= 0 then
		return 0;
	end
	--灵兽墓地消耗1次金钱
	-- if id == 11 then
	-- 	num = 1;
	-- end

	--打包秘境消耗1次金钱
	if id == 13 then
		num = 1;
	end

	if type == DailyMustDoConsts.typetoday then
		--银两
		if consumetype == DailyMustDoConsts.typeyinliang then
			return vo.todayconsume_money * num;
			--元宝
		else
			return vo.todayconsume_yuanbao * num;
		end
	elseif type == DailyMustDoConsts.typeyesterday then
		--银两
		if consumetype == DailyMustDoConsts.typeyinliang then
			return vo.runconsume_money * num;
			--元宝
		else
			return vo.runconsume_yuanbao * num;
		end
	end

	return 0;
end

--一键消耗金钱
function DailyMustDoUtil:GetAllConstomeNum(type, consumetype)
	local num = 0;
	for i, vo in pairs(DailyMustDoModel.finishdailylist) do
		if vo then
			if type == DailyMustDoConsts.typetoday then
				num = num + self:GetConsumeNum(vo.id, type, consumetype);
			elseif type == DailyMustDoConsts.typeyesterday then
				num = num + self:GetConsumeNum(vo.id, type, consumetype);
			end
		end
	end

	return num;
end

function DailyMustDoUtil:GetToalCountReward(rewardStr, count)
	if not rewardStr or rewardStr == "" then return ""; end
	local result = {};
	local rewards = GetPoundTable(rewardStr)
	for k, v in pairs(rewards) do
		local r = GetCommaTable(v);
		local id = toint(r[1]);
		local num = math.ceil(toint(r[2]) * count);
		table.push(result, id .. "," .. num);
	end
	return table.concat(result, "#");
end

--得到奖励
--@type DailyMustDoConsts.typetoday  DailyMustDoConsts.typeyesterday
function DailyMustDoUtil:GetReward(paramid, spe_type, id, type)
	if not type then type = DailyMustDoConsts.typetoday; end
	local num = DailyMustDoUtil:GetDailyMustNum(id, type);
	local mylvl = DailyMustDoModel:GetReqLevel();
	if id == 1 or --四个单人副本的
			id == 2 or
			id == 3 or
			id == 4 then
		local bizuo = t_bizuo[id];
		if bizuo then
			local group = t_dungeons[bizuo.param].group;
			local dungeonvo = DungeonModel:GetDungeonGroup(group);
			local difficulty = dungeonvo and dungeonvo:GetCurrentDifficulty()
			if difficulty then
				local dungeonId = DungeonUtils:GetDungeonId(group, difficulty)
				local vo = t_dungeons[dungeonId]
				if vo then
					return DailyMustDoUtil:GetToalCountReward(vo.rewards, num);
				end
			end
		end
	elseif id == 5 or id == 7 then --日环,猎魔
		local cfg;
		if id == 5 then
			cfg = t_dailyquest;
		elseif id == 7 then
			cfg = t_todayquest;
		end

		local strArr = {};
		local totalExp = 0;
		local totalGold = 0;
		local items = {};
		local cfgItem = {};
		--日环奖励
		for k, v in pairs(cfg) do
			if mylvl >= v.minLevel and mylvl <= v.maxLevel then
				table.push(cfgItem, v);
			end
		end
		for i = 1, num do
			local v = cfgItem[i];
			totalExp = totalExp + v.expReward;
			totalGold = totalGold + v.moneyReward;
			local itemStrArr = GetPoundTable(v.itemReward);
			for k1, v1 in pairs(itemStrArr) do
				local itemId = toint(GetCommaTable(v1)[1]);
				local itemCount = toint(GetCommaTable(v1)[2]);
				if not items[itemId] then
					items[itemId] = 0;
				end
				items[itemId] = items[itemId] + itemCount;
			end
		end
		table.push(strArr, enAttrType.eaExp .. "," .. totalExp);
		table.push(strArr, enAttrType.eaBindGold .. "," .. totalGold);
		--日环额外奖励
		local groupCFG;
		if id == 5 then
			groupCFG = t_dailygroup;
			local title = { "reward_item", "reward_item15", "reward_item10", "reward_item5" };
			local leftNum = num;
			local max = math.ceil(leftNum / 5);
			for i = 1, max do
				local extRewardStr = groupCFG[mylvl][title[i]]
				local extRewardId = toint(GetCommaTable(extRewardStr)[1])
				local extRewardCount = toint(GetCommaTable(extRewardStr)[2])
				if not items[extRewardId] then
					items[extRewardId] = 0;
				end
				items[extRewardId] = items[extRewardId] + extRewardCount;
			end
		end
		for k, v in pairs(items) do
			table.push(strArr, k .. "," .. v);
		end
		local str = table.concat(strArr, "#");
		return str;
	elseif id == 9 then --悬赏
		local rewardstr = t_questagora_consts[1].rewarddaily .. "#" .. t_questagora_exp[mylvl].reward1 .. "#" .. t_questagora_consts[1].reward;
		return DailyMustDoUtil:GetToalCountReward(rewardstr, num);
	elseif id == 10 then --经验副本
		return DailyMustDoUtil:GetToalCountReward(DailyMustDoUtil:GetLiuShuiReward(num), num);
	elseif id == 11 then -- 天神战场 原来的组队升级
		local cfg = t_monkeytime[1];
		local rewardstr = cfg.firstReward;
		return DailyMustDoUtil:GetToalCountReward(rewardstr, num);
	elseif id == 12 then -- 牧野之战
		local passWave = MakinoBattleDungeonModel.passWave;
		local rewards = GetPoundTable(t_muyewar[1].reward);
		local strArr = {};
		for k, v in pairs(rewards) do
			local itemInfo = GetCommaTable(v);
			local id = toint(itemInfo[1])
			local count = toint(itemInfo[2])
			table.push(strArr, id .. "," .. count);
		end
		local rewardstr = table.concat(strArr, "#");
		return DailyMustDoUtil:GetToalCountReward(rewardstr, num * passWave);
	elseif id == 13 then --组队挑战
		local layerNum = QiZhanDungeonModel:GetNextLayerNum();
		local cfg = t_ridereward[layerNum];
		if not cfg then return end
		local rewardstr = cfg.reward;
		return DailyMustDoUtil:GetToalCountReward(rewardstr, num * layerNum);
	elseif id == 14 then --诛仙阵
		local cfg = t_zhuxianzhen[1];
		if not cfg then return nil; end
		local rewardstr = cfg.reward
		local itemInfo = GetCommaTable(rewardstr);
		local id = toint(itemInfo[1])
		local count = toint(itemInfo[2])
		return DailyMustDoUtil:GetToalCountReward(id .. "," .. count, num);
	elseif id == 19 then --秘境夺宝

	elseif id == 20 then --银两BOSS
	end



	-- 副本  id为1的龙魔宫的组id为1
	--[[
	if id == 1 or id == 2 or id == 7 then
		local dungeon = id;
		if dungeon == 7 then
			dungeon = 3;
		end
		local dungeonvo = DungeonModel:GetDungeonGroup( dungeon );
		local difficulty = dungeonvo and dungeonvo:GetCurrentDifficulty()
		if difficulty then
			local dungeonId = DungeonUtils:GetDungeonId( dungeon, difficulty )
			local vo = t_dungeons[dungeonId]
			if vo then
				return vo.rewards;
			end
		end
	-- 活动
	elseif id == 3 then
		return enAttrType.eaExp..","..BingNuUtils:GetRewardInfo(3);
	-- JJC
	elseif id == 6 then
		local grade = 0;
		local mylvl = MainPlayerModel.humanDetailInfo.eaLevel;
		for i,info in ipairs(t_jjc) do 
			local lvl = split(info.rank_range,",")
			local curmyLvl = ArenaModel.myRoleInfo.ranks  --排名
			if not curmyLvl or curmyLvl == 0 then return ""; end;
			if curmyLvl >= tonumber(lvl[1]) and curmyLvl <= tonumber(lvl[2]) then 
				grade = i;
				break;
			end;
		end;
		local cfg = t_jjcPrize[mylvl];
		local str = enAttrType.eaExp..","..cfg.exp[grade].."#"..enAttrType.eaBindGold..","..cfg.gold[grade].."#"..enAttrType.eaZhenQi..","..cfg.zhenqi[grade].."#".."51,"..cfg.honor[grade]
		return str;
	-- 灵光封魔
	elseif id == 4 then
		local mylvl = MainPlayerModel.humanDetailInfo.eaLevel;
		return enAttrType.eaExp..","..t_bizuolingguang[mylvl].exp;
	-- 日环任务
	elseif id == 5 then
		local mylvl = MainPlayerModel.humanDetailInfo.eaLevel;
		local str = "";
		str = enAttrType.eaExp..","..t_dailygroup[mylvl].reward_exp;
		str = str.."#"..enAttrType.eaBindGold..","..t_dailygroup[mylvl].reward_money;
		str = str.."#"..enAttrType.eaZhenQi..","..t_dailygroup[mylvl].reward_zhenqi;
		str = str.."#"..t_dailygroup[mylvl].reward_item;
		return str;
	--奇遇
	elseif id == 8 then
		local mylvl = MainPlayerModel.humanDetailInfo.eaLevel;
		return enAttrType.eaExp..","..t_qiyulevel[mylvl].reward_exp;
	--主宰之路
	elseif id == 10 then
		local maxid = DominateRouteModel:GetOpenMaxID();
		return t_zhuzairoad[maxid].rewardStr;
	--悬赏
	elseif id == 12 then
		local mylvl = MainPlayerModel.humanDetailInfo.eaLevel;
		local str = "";
		if t_fengyaogroup[mylvl] then
			for i,vo in pairs(t_fengyao) do
				if vo.group_id == t_fengyaogroup[mylvl].group then
					if vo.quality == 0 then
						str = enAttrType.eaExp..","..vo.expReward;
						return str;
					end
				end
			end
		end
	--福神降临
	elseif id == 14 then
		local mylvl = MainPlayerModel.humanDetailInfo.eaLevel;
		local str = "";
		if t_bizuofushen[mylvl] then
			return t_bizuofushen[mylvl].reward;
		end
	end
	]]
	return "";
end

--得到灵兽墓地奖励信息
-- function DailyMustDoUtil:GetLSMDReward(num)
-- 	if num < 0 then
-- 		return "";
-- 	end
-- 	local numindex = num;
-- 	if num == 0 then
-- 		--不然不知道奖励是啥
-- 		numindex = 10;
-- 	end
-- 	local list = {};
-- 	for i=1,numindex do
-- 		if t_lingshoumudi[i] then
-- 			local strreword = t_lingshoumudi[i].reword;
-- 			if strreword ~= "" then
-- 				local itemList = split(strreword,"#");
-- 				for i,itemStr in ipairs(itemList) do
-- 					local item = split(itemStr,",");
-- 					local vo = {};
-- 					vo.itemid = tonumber(item[1]);
-- 					vo.itemcount = tonumber(item[2]);
-- 					if list[vo.itemid] then
-- 						list[vo.itemid] = list[vo.itemid] + vo.itemcount
-- 					else
-- 						list[vo.itemid] = vo.itemcount
-- 					end
-- 				end
-- 			end
-- 		end
-- 	end
-- 	local str = "";
-- 	if num == 0 then
-- 		for i,vo in pairs(list) do
-- 			if str == "" then
-- 				str = i..",0";
-- 			else
-- 				str = str.."#"..i..",0";
-- 			end
-- 		end
-- 	else
-- 		for i,vo in pairs(list) do
-- 			if str == "" then
-- 				str = i..","..vo;
-- 			else
-- 				str = str.."#"..i..","..vo;
-- 			end
-- 		end
-- 	end
-- 	return str;
-- end

--得到经验副本奖励信息
function DailyMustDoUtil:GetLiuShuiReward(num)
	if num < 0 then
		return "";
	end
	local numindex = num;
	if numindex == 0 then
		return enAttrType.eaExp .. ",0";
	end
	local mylvl = MainPlayerModel.humanDetailInfo.eaLevel;
	return enAttrType.eaExp .. "," .. t_liushuifuben[math.ceil(mylvl / 5)].award_coe * WaterDungeonModel:GetBestMonster();
end

--得到打包秘境奖励信息
function DailyMustDoUtil:GetDaBaoMiJingReward(num)
	if num < 0 then
		return "";
	end
	local vo = t_consts[116];
	local itemid = vo.val2;
	local itemnum = toint(num / vo.val1);
	local numindex = itemnum;
	return itemid .. "," .. numindex;
end

--极限挑战是否有奖励
function DailyMustDoUtil:GetisHaveAwardJiXian()
	local dungeoninfo = ExtremityDungeonModel:GetMySelfInfo();
	if dungeoninfo.monsterNum and dungeoninfo.monsterNum > 0 then
		return true;
	end

	if dungeoninfo.bossNum and dungeoninfo.bossNum > 0 then
		return true;
	end

	return false;
end

--一键奖励列表（带礼包的）
function DailyMustDoUtil:GetAllReward(type)
	local ishavetool = false;
	local rewardlist = {};
	local list = DailyMustDoModel:GetDailyList();
	for i, vo in pairs(list) do
		if vo then
			if type == DailyMustDoConsts.typetoday and vo.todaynum > 0 then
				local bzvo = t_bizuo[vo.id];
				if bzvo then
					local rewards = self:GetReward(bzvo.param, bzvo.spe_type, vo.id, type);
					if rewards ~= "" then
						local todayrewadlist = RewardManager:ParseToVO(rewards);
						local num = self:GetDailyMustNum(bzvo.id, type);
						for j, jvo in pairs(todayrewadlist) do
							local ishave = false;
							for k, rewardvo in pairs(rewardlist) do
								if rewardvo.id == jvo.id then
									rewardvo.count = rewardvo.count + jvo.count * num;
									ishave = true;
									break;
								end
							end

							--还未添加该奖励
							if ishave == false then
								if jvo.id < DailyMustDoConsts.ITMEIDMAX then
									jvo.count = jvo.count * num;
									if num > 0 then
										table.insert(rewardlist, jvo);
									end
								else
									ishavetool = true;
								end
							end
						end
					end
				end
			elseif type == DailyMustDoConsts.typeyesterday and vo.runnum > 0 then
				local bzvo = t_bizuo[vo.id];
				if bzvo then
					local rewards = "";
					-- if vo.id == 11 then
					-- 	rewards = self:GetLSMDReward(vo.runnum);
					-- else
					--					if vo.id == 9 then
					--						rewards = self:GetLiuShuiReward(vo.runnum);
					--					elseif vo.id == 13 then
					--						rewards = self:GetDaBaoMiJingReward(vo.runnum);
					--					else
					rewards = self:GetReward(bzvo.param, bzvo.spe_type, vo.id, type);
					--					end
					if rewards ~= "" then
						local runrewardlist = RewardManager:ParseToVO(rewards);
						local num = self:GetDailyMustNum(bzvo.id, type);
						--灵兽墓地消耗1次金钱
						--						if bzvo.id == DailyMustDoConsts.LingShouMuDiId then
						--							num = 1;
						--						end

						--打包秘境消耗1次金钱
						--						if bzvo.id == DailyMustDoConsts.DaBaoMiJingId then
						--							num = 1;
						--						end
						for j, jvo in pairs(runrewardlist) do
							local ishave = false;
							for k, rewardvo in pairs(rewardlist) do
								if rewardvo.id == jvo.id then
									rewardvo.count = rewardvo.count + jvo.count * num;
									ishave = true;
									break;
								end
							end

							--还未添加该奖励
							if ishave == false then
								jvo.count = jvo.count * num;
								if num > 0 then
									table.insert(rewardlist, jvo);
								end
							end
						end
					end
				end
			end
		end
	end

	table.sort(rewardlist, function(A, B)
		if A.id < B.id then
			return true;
		else
			return false;
		end
	end);



	local allreward = "";
	for i, vo in pairs(rewardlist) do
		if i == 1 then
			local reward = vo.id .. "," .. vo.count;
			allreward = allreward .. reward;
		else
			local reward = vo.id .. "," .. vo.count;
			allreward = allreward .. "#" .. reward;
		end
	end

	return allreward;
end

--一键奖励详细列表
function DailyMustDoUtil:GetAllRewardList(type)
	local ishavetool = false;
	local rewardlist = {};
	local list = DailyMustDoModel:GetDailyList();
	for i, vo in pairs(list) do
		if vo then
			if type == DailyMustDoConsts.typetoday and vo.todaynum > 0 then
				local bzvo = t_bizuo[vo.id];
				if bzvo then
					local rewards = self:GetReward(bzvo.param, bzvo.spe_type, vo.id, type);
					if rewards ~= "" then
						local todayrewadlist = RewardManager:ParseToVO(rewards);
						local num = self:GetDailyMustNum(bzvo.id, type);
						for j, jvo in pairs(todayrewadlist) do
							local ishave = false;
							for k, rewardvo in pairs(rewardlist) do
								if rewardvo.id == jvo.id then
									rewardvo.count = rewardvo.count + jvo.count * num;
									ishave = true;
									break;
								end
							end

							--还未添加该奖励
							if ishave == false then
								jvo.count = jvo.count * num;
								table.insert(rewardlist, jvo);
							end
						end
					end
				end
			elseif type == DailyMustDoConsts.typeyesterday and vo.runnum > 0 then
				local bzvo = t_bizuo[vo.id];
				if bzvo then
					local rewards = "";
					-- if vo.id == 11 then
					-- 	rewards = self:GetLSMDReward(vo.runnum);
					-- else
					--					if vo.id == 9 then
					--						rewards = self:GetLiuShuiReward(vo.runnum);
					--					elseif vo.id == 13 then
					--						rewards = self:GetDaBaoMiJingReward(vo.runnum);
					--					else
					rewards = self:GetReward(bzvo.param, bzvo.spe_type, vo.id, type);
					--					end
					if rewards ~= "" then
						local runrewardlist = RewardManager:ParseToVO(rewards);
						local num = self:GetDailyMustNum(bzvo.id, type);
						for j, jvo in pairs(runrewardlist) do
							local ishave = false;
							for k, rewardvo in pairs(rewardlist) do
								if rewardvo.id == jvo.id then
									--									if vo.id == 5 then
									--										rewardvo.count = rewardvo.count + jvo.count;
									--									else
									rewardvo.count = rewardvo.count + jvo.count * num;
									--									end

									ishave = true;
									break;
								end
							end

							--还未添加该奖励
							if ishave == false then
								--								if vo.id ~= 5 then
								jvo.count = jvo.count * num;
								--								end
								table.insert(rewardlist, jvo);
							end
						end
					end
				end
			end
		end
	end

	table.sort(rewardlist, function(A, B)
		if A.id < B.id then
			return true;
		else
			return false;
		end
	end);

	return rewardlist;
end

--得到奖励文本
function DailyMustDoUtil:GetRewardInfoText(id, type, consumetype)
	local strreward = "";
	local strnum = "";
	local isnull = true;
	local rewardlist = {};
	local pctid = id;
	if id == 0 then
		pctid = 1;
		rewardlist = DailyMustDoUtil:GetAllReward(type);
	else
		local vo = t_bizuo[id];
		if not vo then
			return rewardlist, isnull;
		end
		local num = DailyMustDoUtil:GetDailyMustNum(vo.id, type);
		local rewards = DailyMustDoUtil:GetReward(vo.param, vo.spe_type, vo.id, type);
		local str = "";
		--		if vo.id == 5 and num > 0 then
		--			str = rewards;
		--		elseif vo.id == 9 then
		--			str = DailyMustDoUtil:GetLiuShuiReward(num);
		--			-- elseif vo.id == 11 then
		--			-- 	str = DailyMustDoUtil:GetLSMDReward(num);
		--		elseif vo.id == 13 then
		--			str = DailyMustDoUtil:GetDaBaoMiJingReward(num);
		--		else
		str = DailyMustDoUtil:Parse(rewards, num);
		--		end
		if str ~= "" then
			isnull = false;
		end
		rewardlist = str;
	end
	local rewardVoList = RewardManager:ParseToVO(rewardlist);
	local pecent = DailyMustDoUtil:GetRewardPecent(pctid, type, consumetype);
	for i, vo in pairs(rewardVoList) do
		if vo and t_item[vo.id] then
			if strreward == "" then
				local itemcount, itemxs = math.modf(vo.count * pecent / 100);
				if itemxs > 0 then
					itemcount = itemcount + 1;
				end

				strreward = vo.id .. "," .. itemcount;

				if itemcount > 0 then
					isnull = false;
				end
			else
				local itemcount, itemxs = math.modf(vo.count * pecent / 100);
				if itemxs > 0 then
					itemcount = itemcount + 1;
				end

				strreward = strreward .. "#" .. vo.id .. "," .. itemcount;

				if itemcount > 0 then
					isnull = false;
				end
			end
		end
	end
	return RewardManager:Parse(strreward), isnull;
end

--列表中是否有id
function DailyMustDoUtil:GetIsHaveId(list, id)
	local ishave = false;
	for k, vo in pairs(list) do
		if vo == id then
			ishave = true;
			break;
		end
	end

	return ishave;
end

--是否有新的开启
function DailyMustDoUtil:IsHaveNewOpen()
	local playerinfo = MainPlayerModel.humanDetailInfo;

	for i, vo in pairs(t_bizuo) do
		if vo then
			if playerinfo.eaLevel >= vo.level and DailyMustDoModel:GetReqLevel() < vo.level then
				return true;
			end
		end
	end

	return false;
end

--解析奖励信息
function DailyMustDoUtil:Parse(str, num)
	local strrewards = "";
	if str and str ~= "" then
		local itemList = split(str, "#");
		for i, itemStr in ipairs(itemList) do
			local item = split(itemStr, ",");
			local itemid = tonumber(item[1]);
--			local itemcount = tonumber(item[2]) * num;
			local itemcount = tonumber(item[2])
			if strrewards == "" then
				strrewards = itemid .. "," .. itemcount;
			else
				strrewards = strrewards .. "#" .. itemid .. "," .. itemcount;
			end
		end
	end
	return strrewards;
end

--得到今日扫荡副本活动剩余次数
function DailyMustDoUtil:GetDungeonDailyMustNum(id)
	for i, vo in pairs(t_bizuo) do
		if vo then
			if vo.param == id then
				return self:GetDailyMustNum(vo.id, DailyMustDoConsts.typetoday);
			end
		end
	end
	return -1;
end
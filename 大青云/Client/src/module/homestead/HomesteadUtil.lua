--[[
	jiayuan 
	wangshuai
]]

_G.HomesteadUtil = {};

function HomesteadUtil:GetHomeBuildCfg(id,lvl)
	local str = ""
	if id == HomesteadConsts.MainBuild then 
		str = "dadianNeed"
	elseif id == HomesteadConsts.XunxianBuild then 
		str = "fangxiantaiNeed"
	elseif id == HomesteadConsts.ZongmengBuild then 
		str = "renwudianNeed"
	end;
	local cfg = t_homebuild[lvl];
	if not cfg then 
		print("ERROR: At HomesteadUtil 19 line  homebuild Lvl is error lvl",lvl)
		return 
	end;
	local buildCfg = cfg[str];
	if not buildCfg then 
		print("ERROR: At HomesteadUtil 24 line Homebuild id is error id",id)
		return 
	end;
	return buildCfg
end;


function HomesteadUtil:GetUpBuildLvlBoolean(type)
	local curlvl = HomesteadModel:GetBuildInfoLvl(type);
	curlvl = curlvl + 1;
	local uplvlNeed = self:GetHomeBuildCfg(type,curlvl)
	if not uplvlNeed then 
		return false
	end;
	local list = AttrParseUtil:ParseAttrToMap(uplvlNeed)
	for i,info in pairs(list) do 
		local i = toint(i);
		local info = toint(info)
		if i == 10 then 
			local val = MainPlayerModel.humanDetailInfo[10] + MainPlayerModel.humanDetailInfo[11]
			if info > val then 
				FloatManager:AddNormal( StrConfig['equip505']); 
				return false;
			end;
		elseif i == 14 then 
			local val = MainPlayerModel.humanDetailInfo[i]
			if info > val  then 
				FloatManager:AddNormal( StrConfig['homestead002']); 
				return false;
			end;
		elseif t_item[i] then 
			local myhaveNum = BagModel:GetItemNumInBag(i);
			if info > myhaveNum then 
				FloatManager:AddNormal( StrConfig['homestead003']); 
				return false;
			end;
		end;
	end;
	return true;
end;

function HomesteadUtil:GetMyPupilData(isSort,id,listcc)
	local list = HomesteadModel:GetPupilList()
	local listadc = {}
	if isSort then 
		table.sort(list,function(A,B)
			if A.queststeat < B.queststeat then
				return true;
			else
				return false;
			end
		end);
		for ci,cfo in pairs(list) do 
			if not listcc[cfo.guid] then 
				table.push(listadc,cfo)
			end;
		end;
	end;
	local mydata = HomesteadUtil:GetPupilUidata(listadc,id)
	return mydata
end;

function HomesteadUtil:GetPupilUidata(list,id)
	local uidatacc = {};
	local nblist = nil
	if id then 
		nblist = self:GetNBpupil(id)
	end;
	for i,info in ipairs(list) do 
		local vo = {};
		vo.name = self:GetQualityColor(info.quality,info.roleName);
		vo.uid = info.guid;
		vo.iconSource = ResUtil:GetHomePupilIcon(info.iconId,"64");
		vo.lvl = string.format(StrConfig["homestead004"],info.lvl)
		vo.quality = info.quality
		vo.atb = info.atb;
		local queCfg = t_homequestfit[info.atb]
		if queCfg then 
			vo.abtType = self:GetQualityColor(info.quality,queCfg.quest);
		end;
		if nblist then 
			local voccasd = nblist[info.guid];
			if voccasd then 
				vo.showCun = true;
			else
				vo.showCun = false;
			end;
		else
			vo.showCun = false;
		end;
		vo.imgdesc = info.queststeat
		local duilist = UIData.encode(vo)
		local uilist = HomesteadUtil:GetUiSkillData(vo.uid)
		local skillStr = table.concat(uilist, "*");
		local str = duilist .. "*" .. skillStr;
		table.push(uidatacc, str);
	end;
	return uidatacc
end;

function HomesteadUtil:GetNBpupil(id)
	local pupillist = HomesteadModel:GetPupilList();
	local nbPList = {};
	local questVo = HomesteadModel:getAQuestInfo(id)
	for i,info in pairs(pupillist) do 
		local mCfg = t_homequestrange[questVo.tid];
		if mCfg.needAttr == info.atb then 
			nbPList[info.guid] = info;
		end;
	end;
	return nbPList;
end;

function HomesteadUtil:GetXunXianListData()
	local list = HomesteadModel:GetXunXianPupilInfo()
	local uidatacc = HomesteadUtil:GetPupilUidata(list)
	return uidatacc
end;

function HomesteadUtil:GetUiSkillData(uid,isBig)
	local vo = HomesteadModel:GetApupilList(uid)
	if not vo then 
		vo  = HomesteadModel:GetXunxianApupilList(uid)
		if not vo then 
			print("ERROR： 查无此人")
			return
		end;
	end;
	--trace(vo)
	local skillVo = vo.skillList;
	local uilist = {};
	for i,info in ipairs(skillVo) do 
		local voc = {};
		local skVo = t_homepupilskill[info.skillId]
		if skVo then 
			voc.iconUrl = ResUtil:GetHomeSkillImg(skVo.skillImage,isBig);
			voc.skillId = info.skillId
			table.push(uilist,UIData.encode(voc))
		end;
	end;
	return uilist;
end;

-- 得到怪物技能uidata；
function HomesteadUtil:GetUiBossSkillData(tid)
	local vo = t_homequestmon[tid];
	--trace(vo)
	local skillVo = split(vo.skill,",")
	--trace(skillVo)
	
	local uilist = {};
	for i,info in ipairs(skillVo) do 
		local voc = {};
		local beSkil = t_homepupilskill[toint(info)]
		if beSkil then 
			local skVo = t_homepupilskill[beSkil.skillResistTxt];
			if skVo then 
				voc.iconUrl = ResUtil:GetHomeSkillImg(skVo.skillImage);
				voc.skillId = beSkil.skillResistTxt
				table.push(uilist,UIData.encode(voc))
			end;
		end;
	end;
	return uilist;
end;

--得到当前任务的基础成功率
function HomesteadUtil:GetQuestBaseRate(questVo,pupil,boolean)
	local all = 100;
	
	-- 任务殿等级
	local questlvl = HomesteadModel:GetBuildInfoLvl(HomesteadConsts.ZongmengBuild);
	local questCfg = t_homequest[questlvl];
	if not questCfg then 
		print("ERROR：  questBuild lvl is error",questLvl)
		return 
	end;
	local rate = questCfg.questBaseRate[questVo.quality + 1] / 100;
	if not rate then 
		print("ERRIR:   questVo.quality is error ",questVo.quality)
		return 
	end;
	---任务配置
	local questCfg = t_homequestrange[questVo.tid]
	if not questCfg then 
		print("ERROR : questVo.tid is error ",questVo.tid)
		return 
	end;
	if boolean then 
		return rate;
	end;

	local n = 100 - rate; --基数

	--系数
	local cfg = t_consts[114]
	local cfg2 = t_consts[115]


	--怪物携带技能
	local MonsterskillList = {}
	for i,info in ipairs(questVo.monsterVo) do 
		local cfg = self:GetMonsterCfg(info.id);
		if cfg then 
			local skvo = split(cfg.skill,",");
			for ca,cao in ipairs(skvo) do 
				local cao = toint(cao)
				if t_homepupilskill[cao] then 
					local vo = {};
					vo.id = cao;
					vo.cfg = t_homepupilskill[cao] or {};
					table.push(MonsterskillList,vo);
				end;
			end;
		end;
	end;

	local y = cfg.val1 / 1000; --品质差系数 
	local z = cfg.val2 / 1000; --  职业成功率占比

	local zj = cfg2.val1 / 1000;--主要技能
	local cj = cfg2.val2 / 1000;--次要技能
	local fj = cfg2.val3 / 1000;--辅助技能

	local isAddKzy = false;
	local kzy = 0;

	local kkSkiA = 0 
	local kkSkiB = 0 
	local kkSkiC = 0 

	for i,info in pairs(pupil) do 
		if not isAddKzy then 
			if info.atb == questCfg.needAttr then 
				kzy = z * n --z职业成功率；
				isAddKzy = true;
			else
				kzy = 0;
			end
		end;

		local puSkiCfgA = nil
		local puSkiCfgB = nil
		local puSkiCfgC = nil

		local mA = 0
		local mB = 0
		local mC = 0
		if info.skillList[1] then
			puSkiCfgA = t_homepupilskill[info.skillList[1].skillId];
			if puSkiCfgA then 
				if MonsterskillList[1] then 
					mA = puSkiCfgA.quaility - (MonsterskillList[1].cfg.quaility or 0);
				else
					mA = puSkiCfgA.quaility;
				end;
			end;
		end;
		if info.skillList[2] then 
			puSkiCfgB = t_homepupilskill[info.skillList[2].skillId]
			if puSkiCfgB then 
				if MonsterskillList[2] then 
					mB = puSkiCfgB.quaility - (MonsterskillList[2].cfg.quaility or 0);
				else
					mB = puSkiCfgB.quaility
				end;
			end;
		end;
		if info.skillList[3] then 
			puSkiCfgC = t_homepupilskill[info.skillList[3].skillId]
			if puSkiCfgC then 
				if MonsterskillList[3] then 
					mC = puSkiCfgC.quaility - (MonsterskillList[3].cfg.quaility or 0);
				else
					mC = puSkiCfgC.quaility
				end;
			end;
		end; 

		local skiA = 0; --有主要技能，为1
		local skiB = 0; --次要
		local skiC = 0; --辅助

		if MonsterskillList[1] then 
			skiA = 1;
		end;
		if MonsterskillList[2] then 
			skiB = 1;
		end
		if MonsterskillList[3] then 
			skiC = 1;
		end;

		local pupilSkiA = 0;
		local pupilSkiB = 0;
		local pupilSkiC = 0;

		for i=1,3 do 
			if info.skillList[i] then 
				if info.skillList[i].skillId then 
					if info.skillList[i].skillId > 0 then 
						local homeCfg = t_homepupilskill[info.skillList[i].skillId];
						if homeCfg then 
							local skilGroup = MonsterskillList[i]
							if skilGroup then 
								skilGroup = skilGroup.cfg.group;
								local GrouCfg = t_homeskillcom[homeCfg.group];
								if GrouCfg["skillResist"..skilGroup] > 0 then 
									if i == 1 then 
										pupilSkiA = 1
									elseif i == 2 then 
										pupilSkiB = 1
									elseif i == 3 then 
										pupilSkiC = 1
									end;
								end;
							end;
						end;
					end;
				end;
			end;
		end;

		local cckkSkiA =  zj * skiA /(zj * skiA + cj * skiB + fj * skiC) * (1+y*mA) *n*(1-z) * pupilSkiA;
		local cckkSkiB =  cj * skiB /(zj * skiA + cj * skiB + fj * skiC) * (1+y*mB) *n*(1-z) * pupilSkiB;
		local cckkSkiC =  fj * skiC /(zj * skiA + cj * skiB + fj * skiC) * (1+y*mC) *n*(1-z) * pupilSkiC;
		
		if kkSkiA < cckkSkiA then 
			kkSkiA = cckkSkiA
		end;
		if kkSkiB < cckkSkiB then 
			kkSkiB = cckkSkiB
		end;
		if kkSkiC < cckkSkiC then 
			kkSkiC = cckkSkiC
		end;
	end;


	local val = rate + kzy + kkSkiA + kkSkiB + kkSkiC;
	if val > 100 then 
		val = 100;
	end;
	return val
end;

function HomesteadUtil:GetMonsterCfg(monsterid)
	local cfg = t_homequestmon[monsterid];
	if cfg then
		return cfg;
	end;
	return nil;
end;

function HomesteadUtil:GetMonsterSkillCfg(id)
	local cfg = t_homequestmon[id];
	if not cfg then return end;
	local slist = split(cfg.skill,",");
	local numlist = {};
	for i,info in pairs(slist) do 
		local skCfg = t_homepupilskill[toint(info)];
		table.push(numlist,skCfg.group)
	end;
	if numlist[1] and numlist[2] and numlist[3] then 
		return numlist[1],numlist[2],numlist[3]
	elseif numlist[1] and numlist[2] then 
		return numlist[1],numlist[2]
	elseif numlist[1] then 
		return numlist[1]
	end;
end;

--list1 我的技能
--list2 怪物技能
function HomesteadUtil:SkullContrast(list11,list22)
	local numlist = {};
	local list1 = {};
	local list2 = {};
	for li,ld in pairs(list11) do
		table.push(list1,ld)
	end;
	for ca,ao in pairs(list22) do
		table.push(list2,ao)
	end;
	for i,info in pairs(list1) do 
		local myskcfg = t_homepupilskill[info.skillId];
		if not myskcfg then 
			--print("ERROR: info.skillId is error",info.skillId)
		else
			for ca,fo in pairs(list2) do 
				local val = myskcfg["skillResist"..fo.id];
				if val and val > 0 then 
					list1[i] = nil;
					--numlist = numlist + val;
					table.push(numlist,val);
					break;
				end;
			end;
		end;
	end;
	local allNum = 0;
	for ca,ap in pairs(numlist) do
		allNum = allNum + ap;
	end;
	return allNum
end;

-- function HomesteadUtil:formRodQuestInfo()
-- 	local listvo = HomesteadModel:GetRodQuestInfoTwo();
-- 	local uidata = {};
-- 	for i,info in ipairs(listvo) do 
-- 		local str = "";
-- 		local year, month, day, hour, minute, second = CTimeFormat:todate(info.time,true);
-- 		local time = string.format('%02d-%02d-%02d %02d:%02d:%02d',year, month, day,hour, minute, second);
-- 		str = string.format(StrConfig["homesQuestinfo00"..info.type],time,info.roleName,info.rewardNum);
-- 		if info.rewardNum == 0 then 
-- 			str = string.format(StrConfig["homesQuestinfo002"],time,info.roleName,info.rewardNum);
-- 		end;
-- 		local vo  = {};
-- 		vo.txt =str;
-- 		table.push(uidata,UIData.encode(vo));
-- 	end;
-- 	return uidata;
-- end;	


function HomesteadUtil:formRodQuestInfo()
	local listvo = HomesteadModel:GetRodQuestInfoTwo();
	local uidata = {};
	for i,info in ipairs(listvo) do 
		local str = "";
		-- info.descID
		local year, month, day, hour, minute, second = CTimeFormat:todate(info.time,true);
		local time = string.format('<font color="#00ff00">%02d-%02d-%02d %02d:%02d:%02d</font><br/>',year, month, day,hour, minute, second);
		str = str .. time;

		local cfg = t_homefighttxt[info.descID];
		local desstr = {};
		local ddstr = {};
		if cfg then 
			if info.type == 0 then 
				ddstr = cfg.txt;
				local strAtt = enAttrTypeName[info.rewardType]
				if not strAtt then 
					if t_item[info.rewardType] then 
						strAtt = t_item[info.rewardType].name
					end;
				end;
				if strAtt then 
					desstr = {info.roleName,strAtt..'*'..info.rewardNum};
				else
					desstr = {info.roleName,info.rewardNum};
				end;

			elseif info.type == 1 then 
				ddstr = cfg.txt2;
				local strAtt = enAttrTypeName[info.rewardType]
				if not strAtt then 
					if t_item[info.rewardType] then 
						strAtt = t_item[info.rewardType].name
					end;
				end;
				if strAtt then 
					desstr = {info.roleName,strAtt..'*'..info.rewardNum};
				else
					desstr = {info.roleName,info.rewardNum};
				end;
			end;
		end;
		ddstr = self:GetStringSkInfo(desstr,ddstr)
		local vo = {};
		vo.txt =str .. ddstr;
		table.push(uidata,UIData.encode(vo));
	end;
	return uidata;
end;

function HomesteadUtil:GetStringSkInfo(param,str)
	local strcc = "";
	strcc =  string.gsub(str,"{[^{}]+}",function(pattern)
			local paramStr = string.sub(pattern,2,#pattern-1);--去大括号
			if tonumber(paramStr) == 1 then 
				return "<font color='#c8c8c8'><u>"..param[tonumber(paramStr)].."</u></font>"
			end;
			return param[tonumber(paramStr)]
		end)
	return strcc;
end;	



function HomesteadUtil:GetChineseTime(time)
	local cfg = t_homequesttime;
	for i,info in pairs(cfg) do 
		if info.time == time then 
			return info.ChineseTime;
		end;
	end;
	return ""
end;

function HomesteadUtil:GetQualityColor(quality,name) 
	if quality == 0 then
		return "<font color='#ffffff'>"..name.."</font>";
	elseif quality == 1 then
		return "<font color='#00b7ef'>"..name.."</font>";
	elseif quality == 2 then
		return "<font color='#b324f6'>"..name.."</font>";
	elseif quality == 3 then
		return "<font color='#ed4003'>"..name.."</font>";
	elseif quality == 4 then
		return "<font color='#f71b1b'>"..name.."</font>";
	end;
	return "<font color='#ffffff'>"..name.."</font>";
end;


function HomesteadUtil:GetQuestState()
	local myquest = HomesteadModel:GetMyQuestInfo();
	local lenght = self:GetLenght(myquest);
	if lenght > 0 then  -- 有任务状态
		--有任务完成
		for i,info in pairs(myquest) do 
			if info.lastTime <= 0 then 
				return 1
			end;
		end;
		--没有任务完成，有任务进行ing
		local time = 0;
		local list = {};
		for i,info in pairs(myquest) do 
			table.push(list,info)
		end;
		table.sort(list,function(A,B)
			if A.lastTime < B.lastTime then
				return true;
			else
				return false;
			end
		end);
		return 2,list[1].lastTime
	else -- 没有任务状态
		return 3
	end;
end;

function HomesteadUtil:GetLenght(list)
	local num = 0;
	for i,info in pairs(list) do 
		num = num + 1;
	end;
	return num;
end;

-- plist 弟子list
-- mlist 怪物list
function HomesteadUtil:GetSkillState(plist,monsterid)
	local plist1 = {};
	local mlist1 = {};
	local num = 0;
	for li,ld in pairs(plist) do
		num = num + 1;
		for ps,pk in ipairs(ld.skillList) do 
			local pskCfg = t_homepupilskill[pk.skillId];
			if pskCfg then 
				local vo = {};
				vo.skillId = pk.skillId;
				vo.group = pskCfg.group;
				table.push(plist1,vo)
			end;
		end;
	end;
	if num <= 0 then 
		return {false,false,false}
	end;
	
	local cfg = t_homequestmon[monsterid]
	if not cfg then 
		return {false,false,false}
	end;
	local skiCfg = split(cfg.skill,',');
	for ms,mk in ipairs(skiCfg) do
		--mk == skid
		local skCfg = t_homepupilskill[toint(mk)];
		if skCfg then 
			local vo = {};
			vo.skillId = toint(mk);
			vo.group = skCfg.group;
			table.push(mlist1,vo)
		end;
	end;
	
	local resultList = {};
	for i=1,3 do 
		local mVo = mlist1[i];
		if mVo then
			if plist1 then 	
				for pss,pkk in pairs(plist1) do 
					local pGroup = pkk.group;
					local mGroup = mVo.group;
					local cfg = t_homeskillcom[pGroup];
					if cfg then 
						local val = cfg["skillResist"..mGroup]
						if val > 0 then 
							resultList[i] = true;
							break;
						else
							resultList[i] = false;
						end;
					end;
				end;
			else
				resultList[i] = false;				
			end;
		else
			resultList[i] = false;
		end;
	end;
	return resultList
end;
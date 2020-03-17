--[[
LovelyPetUtil
zhangshuhui
2015年6月17日11:41:11
]]

_G.LovelyPetUtil = {};

function LovelyPetUtil:GetLovelyPetFight(lovelypetid)
	local petcfg = t_lovelypet[lovelypetid];
	if not petcfg then
		return 0;
	end
	
	local list = {};
	local attrList = split(petcfg.attr,"#");
	for i,attrStr in ipairs(attrList) do
		local attrvo = split(attrStr,",");
		local vo = {};
		vo.type = AttrParseUtil.AttMap[attrvo[1]];
		vo.val = tonumber(attrvo[2]);
		table.push(list,vo);
	end
	
	return PublicUtil:GetFigthValue(list);
end

function LovelyPetUtil:GetLovelyPetState(lovelypetid)
	for i,vo in ipairs (LovelyPetModel:GetLovelyPetList()) do
		if vo.id == lovelypetid then
			return vo.state;
		end
	end
	
	return LovelyPetConsts.type_notactive;
end

--得到萌宠limittime
function LovelyPetUtil:GetLovelyPetLimitTime(lovelypetid)
	local petcfg = t_lovelypet[lovelypetid];
	if not petcfg then
		return 0;
	end
	
	return petcfg.limit_time * 60;
end

--得到萌宠剩余时间
function LovelyPetUtil:GetLovelyPetTime(lovelypetid)
	for i,vo in ipairs (LovelyPetModel:GetLovelyPetList()) do
		if vo.id == lovelypetid then
			return vo.time,vo.servertime;
		end
	end
	
	return 0,0;
end

--得到萌宠UIlist
function LovelyPetUtil:GetLovelyPetUIList()
	local list = {};
	for i,lovelypetvo in ipairs(t_lovelypet) do
		local vo = {};
		vo.id = lovelypetvo.id;
		for i=1,4 do
			vo["iconUrl"..i] = ResUtil:GetLovelyPetIcon(lovelypetvo.stricon..i);
			vo["tfname"..i] = string.format( StrConfig["lovelypet100"..lovelypetvo.quality], lovelypetvo.name);
		end
		vo.qualityUrl = ResUtil:GetLovelyPetQualityIcon(lovelypetvo.quality);
		local state = self:GetLovelyPetState(lovelypetvo.id);
		vo.state = state;
		if state == LovelyPetConsts.type_notactive then
		elseif state == LovelyPetConsts.type_rest then
		elseif state == LovelyPetConsts.type_fight then
		elseif state == LovelyPetConsts.type_passtime then
		end
		
		local verSionName = Version:GetName();
		if not lovelypetvo.showPT then
			table.insert(list ,vo);
		else
			if lovelypetvo.showPT == '' or lovelypetvo.showPT == verSionName then
				table.insert(list ,vo);
			end
		end
	end
	
	table.sort(list,function(A,B)
		if A.id < B.id then
			return true;
		else
			return false;
		end
	end);
	
	local lovelypetUIList = {}
	for i,vo in pairs(list) do
		table.insert(lovelypetUIList ,UIData.encode(vo));
	end
	
	return lovelypetUIList;
end

--得到当前出战的萌宠模型id
function LovelyPetUtil:GetLovelyPetModelId(id)
	local lovelypetvo = t_lovelypet[id];
	if not lovelypetvo then
		return 0;
	end
	
	return lovelypetvo.model;
end

--得到当前出战的萌宠名称
function LovelyPetUtil:GetLovelyPetNameId(id)
	local lovelypetvo = t_lovelypet[id];
	if not lovelypetvo then
		return 0;
	end
	
	return lovelypetvo.name,lovelypetvo.quality;
end

--得到当前出战的萌宠buff描述
function LovelyPetUtil:GetLovelyPetBuffInfoId(id)
	local lovelypetvo = t_lovelypet[id];
	if not lovelypetvo then
		return 0;
	end
	
	return lovelypetvo.skillinfo;
end

--得到当前萌宠状态
function LovelyPetUtil:GetCurLovelyPetState(id)
	local curid = 0;
	local curstate = LovelyPetConsts.type_notactive;
	local list = LovelyPetModel:GetLovelyPetList();
	if id then
		for i,vo in ipairs (list) do
			if id == vo.id then
				return vo.id,vo.state;
			end
		end
	else
		local firstid = 0;
		local restid = 0;
		local passid = 0;
		for i,vo in ipairs (list) do
			if firstid == 0 then
				firstid = vo.id;
			end
			if vo.state == LovelyPetConsts.type_fight then
				return vo.id, vo.state;
			elseif vo.state == LovelyPetConsts.type_rest then
				if restid == 0 then
					restid = vo.id;
				end
				curstate = LovelyPetConsts.type_rest;
			elseif vo.state == LovelyPetConsts.type_passtime and curstate == LovelyPetConsts.type_notactive then
				if passid == 0 then
					passid = vo.id;
				end
				curstate = LovelyPetConsts.type_passtime;
			end
			if curstate == LovelyPetConsts.type_rest then
				curid = restid;
			elseif curstate == LovelyPetConsts.type_passtime then
				curid = passid;
			else
				curid = firstid;
			end
		end
	end
	
	return curid,curstate;
end

--牛牛激活等级
function LovelyPetUtil:GetNiuNiuLevel()
	local lovelypetvo = t_lovelypet[1];
	if not lovelypetvo then
		return 0;
	end
	
	return 45;
end

--当前萌宠废话
function LovelyPetUtil:GetChatInfo(id, state)
	local chatcfg = lovelypetchatcfg[id];
	if chatcfg then
		local vocfg = chatcfg[id*1000 + state];
		local list = vocfg.list;
		return list[math.random(#list)],vocfg.Intervaltime;
	end
	
	return "",0;
end

--当有宠物到期
function LovelyPetUtil:RemindCurrentPetOverdue()
	local curid,curstate = LovelyPetUtil:GetCurLovelyPetState();
	local hasResult = false;
	if curstate == LovelyPetConsts.type_passtime then
		if LovelyPetController.isshowremind == false then
			LovelyPetController.isshowremind = true;
			hasResult = true;

		end
	end
	if hasResult then
		RemindController:AddRemind(RemindConsts.Type_LovelyPet,1);
	else
		RemindController:AddRemind(RemindConsts.Type_LovelyPet,0);
	end
end

--返回是否有宠物是出战状态
function LovelyPetUtil:HasPetFight()
	local hasFight = false;
	for k, v in pairs(LovelyPetModel:GetLovelyPetList()) do
		if v.state == LovelyPetConsts.type_fight then
			hasFight = true;
			break;
		end
	end
	return hasFight;
end

function LovelyPetUtil:GetHasPetCount()
	local count = 0;
	for k, v in pairs(LovelyPetModel:GetLovelyPetList()) do
		if v.state == LovelyPetConsts.type_rest or v.state == LovelyPetConsts.type_fight then
			count = count + 1;
		end
	end
	return count;
end
--[[
FashionsUtil
zhangshuhui
2015年1月22日16:57:20
]]

_G.FashionsUtil = {};

--获取时装总属性list
function FashionsUtil:GetFashionsAttrList()
	local list = {};
	--限时时装列表
	for i,limitvo in pairs(FashionsModel.fashionslimitlist) do
		if t_fashions[limitvo.tid] then
			local listtemp = {};
			local str = t_fashions[limitvo.tid].attr;
			local formulaList = AttrParseUtil:Parse(str)
			for i,cfg in pairs(formulaList) do
				local vo = {};
				vo.type = cfg.type;
				vo.val = cfg.val; 
				table.push(listtemp,vo);
			end
			
			list = self:AddUpAttrIsNil(list, listtemp);
		end
	end
	
	--永久时装列表
	for i,forevervo in pairs(FashionsModel.fashionsforeverlist) do
		if t_fashions[forevervo.tid] then
			local listtemp = {};
			local str = t_fashions[forevervo.tid].attr;
			local formulaList = AttrParseUtil:Parse(str)
			for i,cfg in pairs(formulaList) do
				local vo = {};
				vo.type = cfg.type;
				vo.val = cfg.val; 
				table.push(listtemp,vo);
			end
			
			list = self:AddUpAttrIsNil(list, listtemp);
		end
	end
	
	for k,groupvo in pairs(t_fashiongroup) do
		--是否是限时的
		local islimit = false;
		for f,vo in pairs(t_fashions) do
			if vo.suit == groupvo.id then
				if vo.time ~= -1 then
					islimit = true;
				end
			end
		end
		if islimit then
			local havegrouppos1 = false;
			local havegrouppos2 = false;
			local havegrouppos3 = false;
			for i,limitvo in pairs(FashionsModel.fashionslimitlist) do
				if havegrouppos1 and havegrouppos2 and havegrouppos3 then
					break;
				end
				if t_fashions[limitvo.tid] then
					if t_fashions[limitvo.tid].suit == groupvo.id then
						if t_fashions[limitvo.tid].pos == 1 then
							havegrouppos1 = true;
						elseif t_fashions[limitvo.tid].pos == 2 then
							havegrouppos2 = true;
						elseif t_fashions[limitvo.tid].pos == 3 then
							havegrouppos3 = true;
						end
					end
				end
			end
			if havegrouppos1 and havegrouppos2 and havegrouppos3 then
				local str = groupvo.Attr;
				local formulaList = AttrParseUtil:Parse(str)
				local listtemp = {};
				for i,cfg in pairs(formulaList) do
					local vo = {};
					vo.type = cfg.type;
					vo.val = cfg.val; 
					table.push(listtemp,vo);
				end
				
				list = self:AddUpAttrIsNil(list, listtemp);
			end
		else
			local havegrouppos1 = false;
			local havegrouppos2 = false;
			local havegrouppos3 = false;
			for i,limitvo in pairs(FashionsModel.fashionsforeverlist) do
				if havegrouppos1 and havegrouppos2 and havegrouppos3 then
					break;
				end
				if t_fashions[limitvo.tid] then
					if t_fashions[limitvo.tid].suit == groupvo.id then
						if t_fashions[limitvo.tid].pos == 1 then
							havegrouppos1 = true;
						elseif t_fashions[limitvo.tid].pos == 2 then
							havegrouppos2 = true;
						elseif t_fashions[limitvo.tid].pos == 3 then
							havegrouppos3 = true;
						end
					end
				end
			end
			if havegrouppos1 and havegrouppos2 and havegrouppos3 then
				local str = groupvo.Attr;
				local formulaList = AttrParseUtil:Parse(str)
				local listtemp = {};
				for i,cfg in pairs(formulaList) do
					local vo = {};
					vo.type = cfg.type;
					vo.val = cfg.val; 
					table.push(listtemp,vo);
				end
				
				list = self:AddUpAttrIsNil(list, listtemp);
			end
		end
		
	end
	
	return list;
end

--加上个判断 是否为空
function FashionsUtil:AddUpAttrIsNil(list1,list2)
	if list1 == nil then
		return list2;
	end
	
	if list2 == nil then
		return list1;
	end
	
	return EquipUtil:AddUpAttr(list1,list2);
end

--根据组得到list
function FashionsUtil:GetForeverlistByGroup(group)
	local list = {};
	
	for i=1, FashionsConsts.totalSize do
		local data = {};
		data.uiPos = i;
		data.pos = i - 1;
		data.hasItem = false;
		data.posName = "";
		local index = group * 100 + i;
		local vo = t_fashions[index];
		if vo then
			data.hasItem = true;
			data.tid = vo.id;
			data.zhuangbanState = self:GetIsZhuangBan(vo.id);
			local stricon = MountUtil:GetListString(vo.icon, MainPlayerModel.humanDetailInfo.eaProf);
			local iconUrl = ResUtil:GetFanshionsIconImg(stricon);
			if self:GetisHaveFashions(vo.id) == true then
				data.iconUrl = iconUrl;
				data.lightState = true;
			else
				data.iconUrl = ImgUtil:GetGrayImgUrl(iconUrl);
				data.lightState = false;
			end
		end
		
		table.push(list,UIData.encode(data));
	end
	
	return list;
end

--得到限时时装list
function FashionsUtil:GetLimitlist()
	local list = {};
	
	local index = 0;
	for i=1,FashionsConsts.bagTotalSize do
		local data = {};
		data.uiPos = i;
		data.pos = i - 1;
		data.hasItem = false;
		data.posName = "";
		
		if i == index + 1 then
			local limitindex = 0
			for k,limitvo in pairs(FashionsModel.fashionslimitlist) do
				local vo = t_fashions[limitvo.tid];
				if vo then
					limitindex = limitindex + 1;
					if i == limitindex then
						index = limitindex;
						data.hasItem = true;
						data.tid = vo.id;
						data.zhuangbanState = self:GetIsZhuangBan(vo.id);
						local stricon = MountUtil:GetListString(vo.icon, MainPlayerModel.humanDetailInfo.eaProf);
						local iconUrl = ResUtil:GetFanshionsIconImg(stricon);
						if self:GetisHaveFashions(vo.id) == true then
							data.iconUrl = iconUrl;
							data.lightState = true;
						else
							data.iconUrl = ImgUtil:GetGrayImgUrl(iconUrl);
							data.lightState = false;
						end
						break;
					end
				end
			end
		end
		
		table.push(list,UIData.encode(data));
	end

	return list;
end

--得到限时时装list排序
function FashionsUtil:ManagerLimitlist()
	local templist = {};
	
	for k,limitvo in pairs(FashionsModel.fashionslimitlist) do
		local vo = {};
		vo.tid = limitvo.tid;
		vo.time = limitvo.time;
		
		if self:GetIsZhuangBan(limitvo.tid) == true then
			vo.state = 1;
		else
			vo.state = 0;
		end
		
		table.push(templist, vo);
	end
	
	--排序
	table.sort(templist,function(A,B)
		if A.state == B.state then
			if A.time == B.time then
				local nameA = t_fashiongroup[t_fashions[A.tid].suit].name;
				local nameB = t_fashiongroup[t_fashions[B.tid].suit].name;
				if nameA == nameB then
					if A.tid < B.tid then
						return true;
					else
						return false;
					end
				else
					if nameA < nameB then
						return true;
					else
						return false;
					end
				end
			else
				if A.time < B.time then
					return true;
				else
					return false;
				end
			end
		else
			if A.state > B.state then
				return true;
			else
				return false;
			end
		end		
	end);
	
	--重新赋值
	local index = 0;
	FashionsModel.fashionslimitlist = {};
	for k,limitvo in pairs(templist) do
		local vo = {};
		vo.tid = limitvo.tid;
		vo.time = limitvo.time;
		table.push(FashionsModel.fashionslimitlist, vo);
	end

	local list = {};
	
	local index = 0;
	for i=1,FashionsConsts.bagTotalSize do
		local data = {};
		data.uiPos = i;
		data.pos = i - 1;
		data.hasItem = false;
		data.posName = "";
		
		if i == index + 1 then
			local limitindex = 0
			for k,limitvo in pairs(templist) do
				local vo = t_fashions[limitvo.tid];
				if vo then
					limitindex = limitindex + 1;
					if i == limitindex then
						index = limitindex;
						data.hasItem = true;
						data.tid = vo.id;
						data.zhuangbanState = self:GetIsZhuangBan(vo.id);
						local stricon = MountUtil:GetListString(vo.icon, MainPlayerModel.humanDetailInfo.eaProf);
						local iconUrl = ResUtil:GetFanshionsIconImg(stricon);
						if self:GetisHaveFashions(vo.id) == true then
							data.iconUrl = iconUrl;
							data.lightState = true;
						else
							data.iconUrl = ImgUtil:GetGrayImgUrl(iconUrl);
							data.lightState = false;
						end
						break;
					end
				end
			end
		end
		
		table.push(list,UIData.encode(data));
	end

	return list;
end

--得到当前时装list
function FashionsUtil:GetCurFashionsList()
	local list = {};
	--武器
	local armsVO = {};
	armsVO.uiPos = 1;
	armsVO.pos = 0;
	armsVO.hasItem = false;
	armsVO.posName = "武器";
	if FashionsModel.fashionsArms ~= 0 then
		local vo = t_fashions[FashionsModel.fashionsArms];
		if vo then
			armsVO.hasItem = true;
			armsVO.tid = FashionsModel.fashionsArms;
			local stricon = MountUtil:GetListString(vo.icon, MainPlayerModel.humanDetailInfo.eaProf);
			armsVO.iconUrl = ResUtil:GetFanshionsIconImg(stricon);
			armsVO.posName = "";
			armsVO.lightState = true;
		end
	end
	table.push(list,UIData.encode(armsVO));
	
	--衣服
	local dressVO = {};
	dressVO.uiPos = 2;
	dressVO.pos = 1;
	dressVO.hasItem = false;
	dressVO.posName = "衣服";
	if FashionsModel.fashionsDress ~= 0 then
		local vo = t_fashions[FashionsModel.fashionsDress];
		if vo then
			dressVO.hasItem = true;
			dressVO.tid = FashionsModel.fashionsDress;
			local stricon = MountUtil:GetListString(vo.icon, MainPlayerModel.humanDetailInfo.eaProf);
			dressVO.iconUrl = ResUtil:GetFanshionsIconImg(stricon);
			dressVO.posName = "";
			dressVO.lightState = true;
		end
	end
	table.push(list,UIData.encode(dressVO));
	
	--头
	local headVO = {};
	headVO.uiPos = 3;
	headVO.pos = 2;
	headVO.hasItem = false;
	headVO.posName = "头";
	if FashionsModel.fashionsHead ~= 0 then
		local vo = t_fashions[FashionsModel.fashionsHead];
		if vo then
			headVO.hasItem = true;
			headVO.tid = FashionsModel.fashionsHead;
			local stricon = MountUtil:GetListString(vo.icon, MainPlayerModel.humanDetailInfo.eaProf);
			headVO.iconUrl = ResUtil:GetFanshionsIconImg(stricon);
			headVO.posName = "";
			headVO.lightState = true;
		end
	end
	table.push(list,UIData.encode(headVO));
	
	return list;
end

--得到当前时装list
function FashionsUtil:GetCurFashionsTipInfo()
	local fashionsnameinfo = "";
	local list = {};
	
	local info = MainPlayerModel.sMeShowInfo;
	
	--武器
	local armsVO = {};
	armsVO.uiPos = 1;
	armsVO.pos = 0;
	armsVO.hasItem = false;
	armsVO.posName = "";
	if info.dwFashionsArms ~= 0 then
		local vo = t_fashions[info.dwFashionsArms];
		if vo then
			armsVO.hasItem = true;
			armsVO.tid = info.dwFashionsArms;
			local stricon = MountUtil:GetListString(vo.icon, MainPlayerModel.humanDetailInfo.eaProf);
			armsVO.iconUrl = ResUtil:GetFanshionsIconImg(stricon);
			armsVO.posName = "";
			armsVO.lightState = true;
			
			table.push(list,UIData.encode(armsVO));
			fashionsnameinfo = vo.name;
		end
	end
	
	--衣服
	local dressVO = {};
	dressVO.uiPos = 2;
	dressVO.pos = 1;
	dressVO.hasItem = false;
	dressVO.posName = "";
	if info.dwFashionsDress ~= 0 then
		local vo = t_fashions[info.dwFashionsDress];
		if vo then
			dressVO.hasItem = true;
			dressVO.tid = info.dwFashionsDress;
			local stricon = MountUtil:GetListString(vo.icon, MainPlayerModel.humanDetailInfo.eaProf);
			dressVO.iconUrl = ResUtil:GetFanshionsIconImg(stricon);
			dressVO.posName = "";
			dressVO.lightState = true;
			
			table.push(list,UIData.encode(dressVO));
			if fashionsnameinfo == "" then
				fashionsnameinfo = vo.name;
			else
				fashionsnameinfo =fashionsnameinfo.."、"..vo.name;
			end
		end
	end
	
	--头
	local headVO = {};
	headVO.uiPos = 3;
	headVO.pos = 2;
	headVO.hasItem = false;
	headVO.posName = "";
	if info.dwFashionsHead ~= 0 then
		local vo = t_fashions[info.dwFashionsHead];
		if vo then
			headVO.hasItem = true;
			headVO.tid = info.dwFashionsHead;
			local stricon = MountUtil:GetListString(vo.icon, MainPlayerModel.humanDetailInfo.eaProf);
			headVO.iconUrl = ResUtil:GetFanshionsIconImg(stricon);
			headVO.posName = "";
			headVO.lightState = true;
			
			table.push(list,UIData.encode(headVO));
			if fashionsnameinfo == "" then
				fashionsnameinfo = vo.name;
			else
				fashionsnameinfo =fashionsnameinfo.."、"..vo.name;
			end
		end
	end
	
	return fashionsnameinfo,list;
end

--对套装组排序
function FashionsUtil:GetSortFashionsGroupList()
	local list = {};
	
	for i,groupvo in pairs(t_fashiongroup) do
		if groupvo then
			--判断是否是永久时装
			local isforever = false;
			for i,vo in pairs(t_fashions) do
				if vo.time == -1 and vo.suit == groupvo.id then
					table.push(list,groupvo);
					break;
				end
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
	
	return list;
end

function FashionsUtil:GetPosBytid(tid)
	if t_fashions[tid] then
		return t_fashions[tid].pos;
	end
	
	return 0;
end

function FashionsUtil:DressFashions(tid, type)
	local pos = self:GetPosBytid(tid);
	--穿
	if type == 1 then
		--武器
		if pos == 1 then
			FashionsModel:SetFashionsArms(tid);
		--衣服
		elseif pos == 2 then
			FashionsModel:SetFashionsDress(tid);
		--头
		elseif pos == 3 then
			FashionsModel:SetFashionsHead(tid);
		end
	--脱
	elseif type == 0 then
		--武器
		if pos == 1 then
			FashionsModel:SetFashionsArms(0);
		--衣服
		elseif pos == 2 then
			FashionsModel:SetFashionsDress(0);
		--头
		elseif pos == 3 then
			FashionsModel:SetFashionsHead(0);
		end
	end
end

--是否有该装备
function FashionsUtil:GetisHaveFashions(tid)
	local ishave = false;
	for i,cfg in pairs(FashionsModel.fashionslimitlist) do
		if tid == cfg.tid then
			ishave = true;
			break;
		end
	end
	
	if ishave == false then
		for i,cfg in pairs(FashionsModel.fashionsforeverlist) do
			if tid == cfg.tid then
				ishave = true;
				break;
			end
		end
	end
	
	--没有该装备
	if ishave == false then
		return false;
	end
	
	return true;
end

--该时装是否已装扮
function FashionsUtil:GetIsZhuangBan(tid)
	local ishave = self:GetisHaveFashions(tid);
	if ishave == false then
		return false;
	end
	--是否正在装扮
	if FashionsModel.fashionsArms == tid 
	or FashionsModel.fashionsDress == tid 
	or FashionsModel.fashionsHead == tid then
		return true;
	end
	
	return false;
end


--初始化当前时装
function FashionsUtil:InitFashionsInfo()
	local info = MainPlayerModel.sMeShowInfo;
	FashionsModel:SetFashionsArms(info.dwFashionsArms);
	FashionsModel:SetFashionsDress(info.dwFashionsDress);
	FashionsModel:SetFashionsHead(info.dwFashionsHead);
end

--当前是否有时装打扮
function FashionsUtil:IsHaveCurFashion()
	local info = MainPlayerModel.sMeShowInfo;
	if info.dwFashionsArms == 0 and info.dwFashionsDress == 0 and info.dwFashionsHead == 0 then
		return false;
	end
	
	return true;
end


--得到人物面板UIData
function FashionsUtil:GetRoleUIData(tid, pos)
	local vo = {};
	vo.uiPos = pos;
	vo.pos = pos - 1;
	vo.hasItem = false;
	if pos == 1 then
		vo.posName = "武器";
	elseif pos == 2 then
		vo.posName = "衣服";
	elseif pos == 3 then
		vo.posName = "头";
	end
	if tid ~= 0 then
		local fashionsvo = t_fashions[tid];
		if fashionsvo then
			vo.hasItem = true;
			vo.tid = tid;
			local stricon = MountUtil:GetListString(fashionsvo.icon, MainPlayerModel.humanDetailInfo.eaProf);
			vo.iconUrl = ResUtil:GetFanshionsIconImg(stricon);
			vo.posName = "";
			vo.lightState = true;
		end
	end
	
	return UIData.encode(vo);
end

--得到背包UIData
function FashionsUtil:GetUIData(tid, uiPos)
	-- local uiPos = self:GetuiPos(tid);
	-- if uiPos == 0 then
		-- return nil;
	-- end
	local vo = {};
	vo.uiPos = uiPos;
	vo.pos = uiPos - 1;
	vo.hasItem = false;
	vo.posName = "";
	if tid ~= 0 then
		local fashionsvo = t_fashions[tid];
		if fashionsvo then
			vo.hasItem = true;
			vo.tid = tid;
			vo.lightState = true;
			vo.zhuangbanState = self:GetIsZhuangBan(tid);
			local stricon = MountUtil:GetListString(fashionsvo.icon, MainPlayerModel.humanDetailInfo.eaProf);
			local iconUrl = ResUtil:GetFanshionsIconImg(stricon);
			
			if self:GetisHaveFashions(tid) == true then
				vo.iconUrl = iconUrl;
				vo.lightState = true;
			else
				vo.iconUrl = ImgUtil:GetGrayImgUrl(iconUrl);
				vo.lightState = false;
			end
		end
	end
	
	return UIData.encode(vo);
end
--是否有当前组所有的装备
function FashionsUtil:GetFashionsGroup(id)
    local cost=0;
    for i,cfg in pairs(t_fashions) do
     	if cfg.suit==id then
            if self:GetisHaveFashions(cfg.id) == true then
                cost=cost+1;  
            end
     	end
    end
    return cost==FashionsConsts.totalSize
	 
end
--得到时装背包uiPos
function FashionsUtil:GetuiPos(tid)
	local uiPos = 0;
	for i,cfg in pairs(FashionsModel.fashionslimitlist) do
		uiPos = uiPos + 1;
		if tid == cfg.tid then
			return uiPos;
		end
	end
	
	return 0;
end

--得到时装id
function FashionsUtil:GettidByGroupId(groupid, pos)
	for i,cfg in pairs(t_fashions) do
		if cfg then
			if cfg.suit == groupid and cfg.pos == pos then
				return cfg.id;
			end
		end
	end
	
	return false;
end

--得到限时时装数量
function FashionsUtil:GetFashionsNum()
	local count = 0;
	for i,cfg in pairs(FashionsModel.fashionslimitlist) do
		if cfg then
			count = count + 1;
		end
	end
	
	return count;
end

--当前时装是否是该套装
function FashionsUtil:GetIsCurFashions(groupid)
	local info = MainPlayerModel.sMeShowInfo;
	
	for i,cfg in pairs(t_fashions) do
		if cfg then
			if cfg.suit == groupid then
				--武器
				if cfg.pos == 1 then
					if info.dwFashionsArms ~= cfg.id then
						return false;
					end
				--衣服
				elseif cfg.pos == 2 then
					if info.dwFashionsDress ~= cfg.id then
						return false;
					end
				--头
				elseif cfg.pos == 3 then
					if info.dwFashionsHead ~= cfg.id then
						return false;
					end
				end
			end
		end
	end
	
	return true;
end

--获取该装备时间
function FashionsUtil:GetFashionsTime(tid)
	local ishave = false;
	for i,cfg in pairs(FashionsModel.fashionslimitlist) do
		if tid == cfg.tid then
			return cfg.time;
		end
	end
	
	if ishave == false then
		for i,cfg in pairs(FashionsModel.fashionsforeverlist) do
			if tid == cfg.tid then
				return cfg.time;
			end
		end
	end
	
	return 0;
end

--穿上婚礼礼服
function FashionsUtil:GetMerryFashions()
	local tid1 = 0;
	local tid2 = 0;
	local tid3 = 0;
	--永久时装列表
	for i,forevervo in pairs(FashionsModel.fashionsforeverlist) do
		local vo = t_fashions[forevervo.tid];
		if vo then
			if vo.suit == 6 or vo.suit == 7 then
				if tid1 == 0 then
					tid1 = vo.suit * 100 + 1;
					tid2 = vo.suit * 100 + 2;
					tid3 = vo.suit * 100 + 3;
				else
					if tid1 < vo.suit * 100 + 1 then
						tid1 = vo.suit * 100 + 1;
						tid2 = vo.suit * 100 + 2;
						tid3 = vo.suit * 100 + 3;
					end
				end				
			end
		end
	end
	return tid1,tid2,tid3;
end
--[[
jiayong
2016年9月27日20:51:50
]]

_G.TianShenUtil = {};


function TianShenUtil:GetAttrFight(attr)
  
  return AttrParseUtil:ParseAttrToMap(attr)
end
function TianShenUtil:GetStarGrowValue(modelid)
	local cfg = t_tianshenlv[modelid]
	return cfg and cfg.wish_max;
end

function TianShenUtil:GetCreateInfo()
	local cfglist = {};
	local oneLen=TianShenConsts.ListLen;
	for one=1,oneLen do
		local vo = {};
		vo.name = StrConfig["tianshen03"..one]
		vo.type = one
		cfglist[one] = vo;
	end;
	return cfglist
end
--获取列表VO
function TianShenUtil:GetSkillListVO(skillId, lvl)
	local vo = {};

	vo.skillId = skillId;
	local cfg = t_passiveskill[skillId];
	if not cfg then
	   cfg = t_skill[skillId];
	end
	if cfg then
		vo.name = cfg.name;
		vo.lvl = cfg.level;
		vo.iconUrl = ResUtil:GetSkillIconUrl(cfg.icon);
	end
	return vo;
end
function TianShenUtil:IsLevelFull(vo)
     
    local cfg=t_tianshenlv[vo.step]
    if cfg and cfg.next_id ==0 then
        if not TianShenUtil:IsBreakUp(vo) then 
       	  return true
        end
    end

end
function TianShenUtil:IsBreakFull(modelid)
    

    local cfg =t_tianshenlv[modelid]
     if cfg and cfg.reward_star ~= "" then
      return cfg
    end

end
function TianShenUtil:GetIsActive(modelid)
	local cfg= t_tianshenlv[modelid]
	if cfg and cfg.reward_star~="" then
	     return cfg 
	end
end
function TianShenUtil:IsBreakUp(vo)

	local count = 0
   	for i = vo.tid*1000, vo.step do
   		local cfg = t_tianshenlv[i];
   		if cfg.reward_star and t_tianshenlv[i].reward_star~="" then
   			count = count + 1;
   			if vo.star < count then
                 return true
   			end
   		end
   	end
   	return false
end
local funcAddPro = function(list1, list2)
	local list = {}
	for k, v in pairs(list1) do
		if not list[k] then
			list[k] = v
		else
			list[k] = list[k] + v
		end
	end
	for k, v in pairs(list2) do
		if not list[k] then
			list[k] = v
		else
			list[k] = list[k] + v
		end
	end
	return list
end
local funcAddPro2 = function(list1, list2)
    local list = {}
	for i,j in pairs(list2) do
		for k,v in pairs(list1) do
		 if not list1[i] then

             list1[i]=j;
             break
		  end
		end
	end
	return list1
end
local func = function(str)
	local map = {};
	local t = split(str,'#');
	for i = 1, #t do
		if t[i] ~= "" then
		local t1 = split(t[i],',');
		map[AttrParseUtil:GetCfgStr(toint(t1[1]))] = tonumber(t1[2]);
		end
	end
	return map
end

--当前属性值

function TianShenUtil:GetCurPro(id)
	local vo = TianShenModel:GetTianShenVO(id)
	local pro = {}
	local count = 0
    if vo.stepattrs and vo.stepattrs ~= "" then
		pro = func(vo.stepattrs)
	end
	local cfg = t_tianshenlv[id * 1000]
    local nextcfg=t_tianshenlv[vo.step+1]
	pro = funcAddPro(pro, AttrParseUtil:ParseAttrToMap(cfg.reward))
	
	for i = id * 1000, vo.step do
		cfg = t_tianshenlv[i];
		if cfg and cfg.reward_star and cfg.reward_star ~= "" then
			count = count + 1;
			if (i == vo.step and vo.star == count) or i~= vo.step then
				pro = funcAddPro(pro, AttrParseUtil:ParseAttrToMap(cfg.reward_star))
			end
        end
	end
	if nextcfg and nextcfg.reward ~= "" then 
	       if count == vo.star then 
		     pro= funcAddPro2(pro,AttrParseUtil:ParseAttrToMap(nextcfg.reward))
		   end
        end 
	return pro;
end
--当前星级属性值
function TianShenUtil:GetMaxProForCurLv(id)
	local vo = TianShenModel:GetTianShenVO(id)
	local cfg = t_tianshenlv[id * 1000]
	local pro = AttrParseUtil:ParseAttrToMap(cfg.reward)
	local count = 0
	for i = id *1000, vo.step do
		cfg = t_tianshenlv[i]
		if (i%1000 == 0) then
			local cfg1 = t_tianshenlv[i+1]
			if cfg1 then
				local pro1 = AttrParseUtil:ParseAttrToMap(cfg1.reward)
				for k, v in pairs(pro1) do
					pro1[k] = pro1[k] * cfg1.explain
				end
				pro = funcAddPro(pro, pro1)
			end
		elseif (cfg.reward_star and cfg.reward_star ~= "") then
			count = count + 1
			if (i == vo.step and vo.star == count) or i~= vo.step then
				pro = funcAddPro(pro, AttrParseUtil:ParseAttrToMap(cfg.reward_star))
				local cfg1 = t_tianshenlv[i+1]
				if cfg1 then
					local pro1 = AttrParseUtil:ParseAttrToMap(cfg1.reward)
					for k, v in pairs(pro1) do
						pro1[k] = pro1[k] * cfg1.explain
					end
					pro = funcAddPro(pro, pro1)
				end
			end
		end
	end
	if (vo.step==0) then
		local cfg1 = t_tianshenlv[id * 1000+1]
		if cfg1 then
			local pro1 = AttrParseUtil:ParseAttrToMap(cfg1.reward)
			for k, v in pairs(pro1) do
				pro1[k] = pro1[k] * cfg1.explain
			end
			pro = funcAddPro(pro, pro1)
		end
		return pro
	end
	return pro
end
--当前星级等级
function TianShenUtil:GetAttrLv(id)
	local vo = TianShenModel:GetTianShenVO(id)

	local pro = {}
	local count = 0
	local valueCount = {}

	for i = id * 1000, vo.step do
		local cfg = t_tianshenlv[i];

		if (i%1000 == 0 and vo.star >0) then
			local cfg1 = t_tianshenlv[i+1]
			if cfg1 then
				local pro1 = AttrParseUtil:ParseAttrToMap(cfg1.reward)
				for k, v in pairs(pro1) do
					pro1[k] = pro1[k] * cfg1.explain

					if not valueCount[k] then
						valueCount[k] = cfg1.explain
					else
						valueCount[k] = valueCount[k] + cfg1.explain
					end
				end
				pro = funcAddPro(pro, pro1)

		    end
		elseif (cfg.reward_star and cfg.reward_star ~= "") then
			count = count + 1
			if vo.star > count then
				local cfg1 = t_tianshenlv[i+1]
				if cfg1 then
					local pro1 = AttrParseUtil:ParseAttrToMap(cfg1.reward)
					for k, v in pairs(pro1) do
						pro1[k] = pro1[k] * cfg1.explain
						if not valueCount[k] then
							valueCount[k] = cfg1.explain
						else
							valueCount[k] = valueCount[k] + cfg1.explain
						end
					end
					pro = funcAddPro(pro, pro1)

				end
			else

			end
		else

	    end
	end
	if (vo.step==0) then
		local attr=t_tianshenlv[id*1000];
		local pro2 = AttrParseUtil:ParseAttrToMap(attr.reward)
		for k, v in pairs(pro2) do
			valueCount[k] = 0;
		end
		return valueCount;
	end

    local curPro = func(vo.stepattrs)
	local cfg = t_tianshenlv[vo.step]
	local pro1 = AttrParseUtil:ParseAttrToMap(cfg.reward)
	for k, v in pairs(curPro) do
		if pro[k] then
			valueCount[k] = (valueCount[k] or 0) + (v  - pro[k])/pro1[k]
		else
			valueCount[k] = (valueCount[k] or 0) + v/pro1[k]
		end
	end
	return valueCount
end
function TianShenUtil:Getcurlevel(vo)


   for i=vo.step ,(vo.id+1)*1000 do
   	 local cfg=t_tianshenlv[i];
   	 if cfg and cfg.reward_star ~= "" then
   	  return i%1000
   	 end
   end
   return "";
end
function TianShenUtil:GetNextLevel(vo)
    local const=0
    local pro={};
    for i=vo.tid*1000 ,(vo.id+1)*1000 do
   	 local cfg=t_tianshenlv[i];

   	 if cfg and cfg.reward_star ~="" then
   	 	const=const+1;
   	 	if const>vo.star and i~= vo.step then 
         return i%1000
        end
   	 end
    end
   return ""
end
function TianShenUtil:GetNextFight()
	local const=0
    for i=vo.tid*1000 ,(vo.id+1)*1000 do
   	 local cfg=t_tianshenlv[i];
   	 if cfg and cfg.reward_star ~="" then
   	 	const=const+1;
   	 	if const>vo.star and i~= vo.step then 
         return i%1000
        end
   	 end
    end
   return ""
end
function TianShenUtil:GetTransforNum(str)
  local fPro = {}
	for k, v in pairs(str) do
		local fVO = {};
		fVO.type = AttrParseUtil:getType(k);
		fVO.val = v;
		table.push(fPro, fVO);
	end
	return fPro
end
function TianShenUtil:GetActiveAttr(id)
    local count=0;
    local pro={}
	for i=id*1000 ,(id+1)*1000 do
		local cfg=t_tianshenlv[i+1];
		if cfg and cfg.reward_star~="" then
	        count=count+1
	        if count==5 then
	        pro=AttrParseUtil:Parse(cfg.reward)
	        end    
		end
	end
	return  pro
end
function TianShenUtil:GetOpenAttr(id)

	local count=0;
	local const=0;
	local list={};
	for i=id*1000 ,(id+1)*1000 do
		local cfg=t_tianshenlv[i+1];
		if cfg  and cfg.reward_star~="" then
	        local len=AttrParseUtil:Parse(cfg.reward)
	        if #len>3 and const~=#len then
            list[len[#len].name]=count;
	        end
	        const=#len
	        count=count+1;
		end
	end
	return list;
end
function TianShenUtil:GetAttrMap()
	local list={};
	local vo=TianShenModel:GetFightModel() or TianShenModel:GetTianShenVO(1); 
    local attMap = TianShenUtil:GetAllFight()
    for attr,value in pairs(attMap) do
        table.push(list,{proKey = attr, proValue = value})
    end
   return list;
end
function TianShenUtil:GetVipShowFight(attrmap, systemName)
	local attMap = {}
	local add = VipController:GetShowAddition(systemName)
	for k, v in pairs(attrmap) do
		local vo = {};
		vo.type = AttrParseUtil.AttMap[v.proKey];
		vo.val = v.proValue*add/100;
		table.push(attMap,vo);
	end
	return PublicUtil:GetFigthValue(attMap)
end
function TianShenUtil:GetAllFight()
	local proattr={};
    local bianshenInfo=TianShenModel:GetBianshenList()
    for k,vo in pairs(bianshenInfo) do
    	if vo.state==1 or vo.state==2 then 
         proattr=funcAddPro(proattr,TianShenUtil:GetCurPro(vo.tid));
    	end
    end
    return proattr;
end
-- 天神激活，天神升级，天神突破 
function TianShenUtil:CheckTianShenCanOperation( )
	if TianShenModel:GetTianshenActive() or TianShenModel:GetTianshenUpdata() or TianShenModel:GetTianshenStarUpdata() then
		return true
	end
	return false
end


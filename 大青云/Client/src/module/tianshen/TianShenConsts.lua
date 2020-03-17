--[[
天神附体常量
jiayong
2016年8月9日12:22:00
]]

_G.TianShenConsts = {};

TianShenConsts.questBuffid =2300001;               
TianShenConsts.Attrs = {"att","def","hp","hit","dodge","cri","defcri"};
TianShenConsts.MaxStar=5;
TianShenConsts.roleid=1000;
TianShenConsts.ListLen=3;
TianShenConsts.resultime = 20
TianShenConsts.size="70";
TianShenConsts.SkillKey = 
{
	_System.KeyS,
	_System.KeyD,
}

TianShenConsts.AttrNames = {
     ["att"]             = StrConfig['tianshen006'],
	 ["def"]             = StrConfig['tianshen007'],
	 ["hp"]              = StrConfig['tianshen008'],
     ["hit"]             = StrConfig['tianshen009'],
	 ["dodge"]           = StrConfig['tianshen010'],
	 ["cri"]             = StrConfig['tianshen011'],
     ["defcri"]          = StrConfig['tianshen012'],

}
local activeConsume
function TianShenConsts:GetActiveConsume(roleid)
	if not activeConsume then
		activeConsume = t_tianshen[roleid].act_item
	end
	return activeConsume
end
local questId
function TianShenConsts:GetquestId()
	if not questId then 
        for i,cfg in pairs(t_quest) do
   	        if cfg.questBuff and cfg.questBuff==TianShenConsts.questBuffid then 
            questId=cfg.id;
            end
        end
	end
   
    return questId;
end
function TianShenConsts:GetActiveItem(roleid)
     
	local cfg=t_tianshen[roleid];
	if not cfg then return; end
     local desTable =cfg.act_item
      local itemid = tonumber(desTable[1]);
	  local NbNum  = tonumber(desTable[2]);
	  return itemid,NbNum;
end
function TianShenConsts:GetLevelItem(modelid)
	local cfg=t_tianshenlv[modelid];
	if not cfg then return; end
      local desTable=split(t_tianshenlv[modelid].item_cost,",")
      local itemid = tonumber(desTable[1]);
	  local NbNum  = tonumber(desTable[2]);
	  return itemid,NbNum;	
end
function TianShenConsts:GetStarItem(modelid) 
	
	local cfg=t_tianshenlv[modelid];
	if not cfg then return; end
      local desTable=split(cfg.item_cost1,",")
      local itemid = tonumber(desTable[1]);
	  local NbNum  = tonumber(desTable[2]);
	  return itemid,NbNum;
end

--获取附体技能列表
function TianShenConsts:GetAttachedSkills(lv)
	local cfg=t_tianshenlv[lv];
	if not cfg then return; end
	local skills = split(cfg.skill_attached,",");
	local result = {};	
	for i,id in ipairs(skills) do
		local skill = SkillVO:new(toint(id));
		skill.selected = true;
		skill.pos = i;
		table.push(result,skill);
	end
	
	return result;
end

--被动技能
function TianShenConsts:GetPassivitySkill(lv)
  local cfg=t_tianshenlv[lv];
  if cfg and cfg.skill_pass then
     return cfg.skill_pass;
  end

end
function TianShenConsts:IsTransform(data)
	if not data then return; end
	if type(data) == "table" then
		local mode = TianShenModel:GetTianshenMode(data);
		return _and(mode,2) == 2;
	else
		local cfg = t_tianshen[data];
		if not cfg then
			return;
		end
		return _and(cfg.mode,2) == 2;
	end
end

function TianShenConsts:IsModelFollow(id)
	local cfg = t_bianshenmodel[id];
	if not cfg then
		return;
	end
	return _and(cfg.mode,1) == 1;
end

function TianShenConsts:IsModelTransform(id)
	local cfg = t_bianshenmodel[id];
	if not cfg then
		return;
	end
	return _and(cfg.mode,2) == 2;
end
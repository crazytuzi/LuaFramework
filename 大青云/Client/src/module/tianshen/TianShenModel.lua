--[[
天神附体
  jiayong
2015年2月2日18:18:18
--数据
]]
_G.TianShenModel = Module:new();

TianShenModel.bianshenInfo = {};
TianShenModel.isTransfor=false; 
TianShenModel.isguide=true;
function TianShenModel:SetTianshenListinfo(list)
     

	self.bianshenInfo = self:GetBianshenList();
-- tid 配置ID    star 星级 wish 当前灵力   model 当前外显  energy 当前能量    state  当前状态 1=休息 2=出战 3=变身"/>
	for i,info in ipairs(list) do
		local vo = self:GetTianShenVO(info.tid);
		vo.star=info.star;
		if vo.step ~=info.step then
			vo.attachedSkills = TianShenConsts:GetAttachedSkills(info.step);
		end
		vo.step=info.step;
		vo.model=info.model;
		vo.energy=info.energy;
		vo.state=info.state;
    vo.stepattrs=info.stepattrs;
		vo.lv = info.step%1000;
	  --WriteLog(LogType.Normal,true,'SetTianshenListinfo'..tostring(info.state));
	end
end
function TianShenModel:GetBianshenList()

	if #self.bianshenInfo <1 then
		self:InitBianshenList();
	end
	return self.bianshenInfo;
end

function TianShenModel:InitBianshenList()
      
    for k,v in pairs(t_tianshen) do
    	local vo  = self:GetTianShenVO(k);
		  table.push(self.bianshenInfo,vo);
    end

end
function TianShenModel:GetTianShenVO(id)
    
    for i,info in pairs(self.bianshenInfo) do
       if info and info.id==id then
         return info  
       end	
    end
   -- local vo  = self.bianshenInfo[id];
		local config = t_tianshen[id];
		local vo = {};
		vo.id=config.id;
		vo.tid=config.id;
    vo.star=0;
    vo.step=0;
    vo.model=0;
    vo.energy=0;
    vo.state=0;
    vo.stepattrs="";
    vo.column=config.column;
    vo.ranking=config.ranking
    vo.uihead=config.ui_head;
    vo.lvlimit = config.act_level;
    vo.iconUrl =  ResUtil:GetTianshenNormalIcon(vo.tid,false);
    vo.headUrl  = ResUtil:GetTianshenIcon(vo.tid,false);
    vo.name = config.name;
	vo.lv = 0;
  return vo;
end
--排序
function TianShenModel:GetTianshenActivate()
    local list={};
    for i,vo in ipairs(self.bianshenInfo) do
    	 if vo.state==1 then
    	 	table.push(list,vo)
    	 end
    end
   table.sort(list,function(A,B)
   	if A.ranking<B.ranking then 
   		return true
   	else
   		return false
   	end
   end)
   return list;
end
--是否激活                    
function TianShenModel:IsActive(roleId)
	 local vo =self:GetTianShenVO(roleId)
	 if vo.state==1 or vo.state==2 then
	  return vo
	 end
end 
--激活
function TianShenModel:GetActiveModel()
  for i, vo in ipairs(self.bianshenInfo) do
    if vo.state == 1 or vo.state==2 then
      return vo;
    end
  end
end
--休战
function TianShenModel:GetTruceModel()
  for i, vo in ipairs(self.bianshenInfo) do
    if vo.state == 1 then
      return vo;
    end
  end
end
--出战
function TianShenModel:GetFightModel()
  for i, vo in ipairs(self.bianshenInfo) do
    if vo.state == 2 then
      return vo;
    end
  end
end

--模型
function TianShenModel:GetTransModelId(vo)
    local index =vo.tid*100+vo.step
    if not index then
      return nil
    else
        return index;
    end
end
function TianShenModel:GetTranStarId(vo)
   local index =vo.tid*100+vo.star
    if not index then
      return nil
    else
        return index;
    end
end
--列表
function TianShenModel:GetTitleTable(id)
  local list={};
  for k,vo in pairs(self.bianshenInfo) do
    if vo and vo.column==id then
    vo.str=vo.name
    table.push(list,vo)
    end    
  end
    table.sort(list,function(A,B)
    if A.ranking<B.ranking then 
      return true
    else
      return false
    end
   end)
return list
end
----------------消息提示-----------------
--激活
function TianShenModel:GetTianshenActive()
    
	if not FuncManager:GetFuncIsOpen(FuncConsts.Tianshen) then return false  end
	local eaLevel= MainPlayerModel.humanDetailInfo.eaLevel;
	local list =self.bianshenInfo or self:GetBianshenList();
	for i,vo in ipairs(list) do
  if vo.lvlimit<=eaLevel and vo.state==0 then
    local itemid,NbNum =TianShenConsts:GetActiveItem(vo.tid)
    if not itemid then return false end
 	  local bagNum = BagModel:GetItemNumInBag(itemid);
 	    if bagNum >=NbNum then
        return vo; 

      end
    end
  end
     return false
end
--升阶
function TianShenModel:GetTianshenUpdata()

	if not FuncManager:GetFuncIsOpen(FuncConsts.Tianshen) then return false  end
  local eaLevel= MainPlayerModel.humanDetailInfo.eaLevel 
	for i,vo in ipairs(self.bianshenInfo) do
      if vo.lvlimit<=eaLevel and vo.state==1 or vo.state==2 then 
       if vo.star<TianShenConsts.MaxStar and not TianShenUtil:IsBreakUp(vo) then 
        local itemid,NbNum =TianShenConsts:GetLevelItem(vo.step)
        local bagNum = BagModel:GetItemNumInBag(itemid);
        if not itemid then return; end
        if bagNum>= NbNum then
            return true; 
          end
        end
      end
	end
	return false
end
--升星
function TianShenModel:GetTianshenStarUpdata()

	if not FuncManager:GetFuncIsOpen(FuncConsts.Tianshen) then return false  end
	local eaLevel= MainPlayerModel.humanDetailInfo.eaLevel 
	for i,vo in ipairs(self.bianshenInfo) do
      if vo.lvlimit<=eaLevel and vo.state==1 or vo.state==2 then 

      	if vo.star<TianShenConsts.MaxStar and TianShenUtil:IsBreakUp(vo) then 
        
        local itemid,NbNum =TianShenConsts:GetStarItem(vo.step)
        if not itemid then return false end
        local bagNum = BagModel:GetItemNumInBag(itemid);
        if bagNum>=NbNum then
         return true; 
        end
        end
      end
	end
	return false 
end
function TianShenModel:GetTianshenMode(vo)
	if not vo then return 0 end;
	local config = t_tianshen[vo.tid];
	if not config then return 0 end;
	return config.mode;
end
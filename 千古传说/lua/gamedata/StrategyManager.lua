--[[
******游戏数据阵法管理类*******

	-- by Stephen.tao
	-- 2013/12/05

	-- by haidong.gan
	-- 2014/4/10
]]


local StrategyManager = class("StrategyManager")

StrategyManager.UPDATE_STARTEGY_POS     = "StrategyManager.UPDATE_STARTEGY_POS";  --仅上阵角色位置掉换
StrategyManager.UPDATE_GENERRAL_LIST    = "StrategyManager.UPDATE_GENERRAL_LIST";  --上阵角色增减，刷新缘分
StrategyManager.AUTO_WAR_MATIX_RESULT   = "StrategyManager.AUTO_WAR_MATIX_RESULT";

function StrategyManager:ctor()
	self:init();
	TFDirector:addProto(s2c.WAR_MATIX_CONF_RESULT, self, self.onReceiveWarMatixConfResult);
	TFDirector:addProto(s2c.WAR_MATIX_CONF, self, self.onReceiveWarMatixConf);
	TFDirector:addProto(s2c.WAR_MATIX_SIZE_UPDATE, self, self.onReceiveWarMatixSizeUpdate);
	TFDirector:addProto(s2c.AUTO_WAR_MATIX_RESULT, self, self.onReceiveAutoMatixCom);
	
end

function StrategyManager:init()

	self.strategylist 	= {}					--当前阵型排列
	self.maxNum		 	= 7 					--最大人数
	self.num 			= 0 					--当前上阵人数 
	self.useId  		= 0 					--当前使用的阵法
end

function StrategyManager:restart( )
	self:dispose();
	self:init();
end

function StrategyManager:dispose()
	print("-----------------------StrategyManager:dispose()----------------------------");
	self.strategylist  	= nil;
	self.maxNum		 	= nil;			--最大人数
	self.num 			= nil;			--当前上阵人数 
	self.useId  		= nil;			--当前使用的阵法
end

--战阵请求处理结果
function StrategyManager:onReceiveWarMatixConfResult( event )
	local data = event.data;
	--print("StrategyManager:onReceiveWarMatixConfResult",data);
	hideLoading();

	self:changeStrategy(data.fromPos,data.toPos,data.userId);
	--modify by david.dai
	--CardRoleManager:UpdateRoleFate()
end

--更新战阵的开放位置上限信息
function StrategyManager:onReceiveWarMatixSizeUpdate( event )
	-- hideLoading();
	local data = event.data;
	self.maxNum = data.capacity;
end

--一键布阵完成
function StrategyManager:onReceiveAutoMatixCom( event )
	hideLoading();
	TFDirector:dispatchGlobalEventWith(StrategyManager.AUTO_WAR_MATIX_RESULT);
	-- toastMessage("一键布阵完成");
end

--战阵更新指令，服务器在某些时刻主动推动，下发给客户端
function StrategyManager:onReceiveWarMatixConf( event )
	-- hideLoading();
	local data = event.data;
	self.maxNum = data.capacity;
	--先全部下阵
    local roleList = self:getList();
    for index,roleGmId in pairs(roleList) do
    	local role = CardRoleManager:getRoleByGmid(roleGmId);
    	if (role) then
    		self:setRoleIndex(0, role );
    	end
    end

	for k,v in pairs(data.configure) do
		local role = CardRoleManager:getRoleByGmid(v.userId);
		if role then
			self:setRoleIndex( (v.index + 1), role );
		end
	end
	--CardRoleManager:UpdateRoleFate()
	self:updateAllFate(false)
	TFDirector:dispatchGlobalEventWith(StrategyManager.UPDATE_GENERRAL_LIST);
	
end


function StrategyManager:getList()
	return self.strategylist
end

function StrategyManager:getRoleByIndex(index)
	local gmId = self.strategylist[index];
	if gmId == nil or gmId == 0 then
		return nil;
	end
	local role = CardRoleManager:getRoleByGmid(gmId);
	if role then
		return role;
	end
end

function StrategyManager:setRoleIndex( index,role )

	-- print("StrategyManager:setRoleIndex( index,role )",index,role)
    --安全判断
    if role == nil then
        self.strategylist[index] = 0;
        return;
    end
    -- print("StrategyManager:setRoleIndex( index,role ) -------11111")
    --仅仅将卡牌下阵
	if index == 0 then
		if role.pos and role.pos ~= 0 then
        	self.strategylist[role.pos] = 0
        	TFDirector:dispatchGlobalEventWith(StrategyManager.UPDATE_STARTEGY_POS,role.pos);
        	role.pos = nil;
        	role:setPosByFightType(EnumFightStrategyType.StrategyType_PVE, 0)
    	end
    	-- print("StrategyManager:setRoleIndex( index,role ) -------2222")
		return;
	end
    
    --已经在阵上，先下阵(要到新的位置去)
	if role.pos and role.pos ~= 0 then
    	-- print("StrategyManager:setRoleIndex( index,role ) -------333")
    	self.strategylist[role.pos] = 0;
		TFDirector:dispatchGlobalEventWith(StrategyManager.UPDATE_STARTEGY_POS,role.pos);
	end

    --原先的位置上有卡牌，先将其下阵（替换）
	local oldRole = self:getRoleByIndex(index);
	if oldRole then
    	-- print("StrategyManager:setRoleIndex( index,role ) -------444",oldRole)
	    oldRole.pos = 0;
	    oldRole:setPosByFightType(EnumFightStrategyType.StrategyType_PVE, 0)
	end

	-- print("StrategyManager:setRoleIndex( index,role ) -------5555")

	self.strategylist[index] = role.gmId;

	role.pos = index;
	role:setPosByFightType(EnumFightStrategyType.StrategyType_PVE, index)
	TFDirector:dispatchGlobalEventWith(StrategyManager.UPDATE_STARTEGY_POS,index);
	TFDirector:dispatchGlobalEventWith("armyLayerMoveSpecial");

	-- print("StrategyManager:setRoleIndex( index,role ) -------6666",role)
end

--[[
战阵请求处理结果成功，开始换
modify by david.dai
在具体操作中对缘分进行特殊处理。
]]
function StrategyManager:changeStrategy(fromPos, toPos, roleGmId)
	print("StrategyManager:changeStrategy(fromPos, toPos, roleGmId)",fromPos, toPos, roleGmId)
	local role = nil
	--选中目标不在阵上
	if fromPos == 0 then
		--目标位置是否已经有角色
		if toPos ~= 0  then
			--下阵
			role = self:getRoleByIndex(toPos)
			if role then
				self:setRoleIndex(0,role)
				role:updateFate()
			end
		end
		--上阵
		role = CardRoleManager:getRoleByGmid(roleGmId)
		self:setRoleIndex(toPos,role)
	else
		--下阵
		if toPos == 0  then
			role = CardRoleManager:getRoleByGmid(roleGmId)
			self:setRoleIndex(0,role)
			role:updateFate()
		--交换
		else
			role = self:getRoleByIndex(toPos)
			if role then
				self:setRoleIndex(fromPos,role)
			end
			role = CardRoleManager:getRoleByGmid(roleGmId)
			self:setRoleIndex(toPos,role)
		end
	end

	self:updateAllFate(true)
	TFDirector:dispatchGlobalEventWith(StrategyManager.UPDATE_GENERRAL_LIST)
	TFDirector:dispatchGlobalEventWith("armyLayerPutSpecial");
end

function StrategyManager:getFightRoleNum()
	local num = 0;
	for i=1,10 do
		if self.strategylist[i] and self.strategylist[i] ~= 0 then
			num = num + 1;
		end
	end
	self.num = num;
	return num;
end

function StrategyManager:getPower()

	if 1 then
		return AssistFightManager:getStrategyPower( LineUpType.LineUp_Main )
	end

	local allPower = 0;
	for i=1,10 do
		if self.strategylist[i] and self.strategylist[i] ~= 0 then
			local role = CardRoleManager:getRoleByGmid(self.strategylist[i]);
            allPower = allPower + role:getpower();
		end
	end
	return allPower;
end

function StrategyManager:canAddFightRole()
	local num = self:getFightRoleNum();
	if self.maxNum > self.num then 
		return true;
	else
		return false;
	end
end

function StrategyManager:getMaxNum()
	return self.maxNum;
end

--通过序号获取上阵角色实例。所谓序号是指不为空的战阵位置
function StrategyManager:getFightRoleBySequence(sequence)
	local tmp = 0
	for i=1,10 do
		if self.strategylist[i] and self.strategylist[i] ~= 0 then
			tmp = tmp + 1
			if tmp == sequence then
				local role = CardRoleManager:getRoleByGmid(self.strategylist[i])
				return role
			end
		end
	end
	return nil
end

function StrategyManager:getRoleTemplateIdTable()
	local table = {}
	for i=1,10 do
		if self.strategylist[i] and self.strategylist[i] ~= 0 then
			local role = CardRoleManager:getRoleByGmid(self.strategylist[i])
			table[i] = role.id
		end
	end
	return table
end

function StrategyManager:getRoleByTemplateId(id)
	for i=1,10 do
		if self.strategylist[i] and self.strategylist[i] ~= 0 then

			local role = CardRoleManager:getRoleByGmid(self.strategylist[i])
			if role.id == id then 
				return role
			end
		end
	end
	return nil
end

--[[
更新所有战阵的角色的缘分
]]
function StrategyManager:updateAllFate( showMessage)
	for i=1,10 do
		if self.strategylist[i] and self.strategylist[i] ~= 0 then
			local role = CardRoleManager:getRoleByGmid(self.strategylist[i])
			role:updateFate(showMessage)
		end
	end
end

--[[
获取战力最高的角色
]]
function StrategyManager:getTopPowerRole()
	local top = nil
	for i=1,10 do
		if self.strategylist[i] and self.strategylist[i] ~= 0 then
			local role = CardRoleManager:getRoleByGmid(self.strategylist[i])
			if not top then
				top = role
			else
				if top.power < role.power then
					top = role
				end
			end
		end
	end
	return top
end

return StrategyManager:new();
--[[
存放点选目标的Buff, 用于UI显示
郝户
2014年10月18日16:48:02
]]
_G.classlist['BuffTargetModel'] = 'BuffTargetModel'
_G.BuffTargetModel = Module:new();
BuffTargetModel.objName = 'BuffTargetModel'
BuffTargetModel.buffList = {};

function BuffTargetModel:Rebuild( buffInfo )
	self:Clear();
	local targetBuffs = buffInfo:GetBuffList();
	for id, buff in pairs( targetBuffs ) do
		self:Add(buff);
	end
end

--增加一个buff
function BuffTargetModel:Add( buff )
	if self.buffList[buff.id] then
		Debug('Error:Has a buff in the target, cannot add.');
		return;
	end
	local vo = {};
	vo.id = buff.id;
	vo.tid = buff.buffId;
	vo.time = buff.time;
	vo.caster = buff.caster;
	vo.params = {};
	self.buffList[vo.id] = vo;
	self:sendNotification( NotifyConsts.TargetBuffRefresh );
end

--获取目标身上的一个buff
function BuffTargetModel:GetBuff(id)
	return self.buffList[id];
end

--清除所有buff
function BuffTargetModel:Clear()
	self.buffList = {}
	self:sendNotification( NotifyConsts.TargetBuffRefresh );
end

--移除一个buff
function BuffTargetModel:Remove(id)
	if self.buffList[id] then
		self.buffList[id] = nil;
		self:sendNotification( NotifyConsts.TargetBuffRefresh );
	end
end

--移除所有buff
function BuffTargetModel:Clear()
	self.buffList = {};
	self:sendNotification( NotifyConsts.TargetBuffRefresh );
end

--更新一个buff
function BuffTargetModel:Update( id, time, count, paramList )
	local buff = self.buffList[id];
	if buff then
		buff.time = time;
		buff.count = count;
		for i, paramVO in pairs( paramList ) do
			buff.params[i] = paramVO.value;
		end
		self:sendNotification( NotifyConsts.TargetBuffRefresh );
	end
end

--获取UI显示列表
function BuffTargetModel:GetShowList()
	local list = {};
	for id, buffVO in pairs(self.buffList) do
		local tid = buffVO.tid;
		local caster = buffVO.caster;
		local cfg = t_buff[tid];
		if cfg and cfg.showIcon then
			local vo = BuffUtils:HasSameCasterBuffInList(list, tid, caster);
			--如果有相同施法者释放的相同buff，累加count;
			if vo then
				vo.count = vo.count + 1;
				vo.time = math.min(buffVO.time, vo.time);
			else
				vo = {};
				vo.id = buffVO.id;
				vo.tid = buffVO.tid;
				vo.time = buffVO.time;
				vo.caster = buffVO.caster;
				vo.count = 1;
				vo.iconUrl = ResUtil:GetBuffIcon( cfg.icon );
				vo.priority = cfg.priority;
				table.push( list, vo );
			end
		end
	end
	table.sort( list, function(A, B) return A.priority < B.priority end )
	return list;
end

--客户端更新Buff剩余时间
function BuffTargetModel:UpdateBuffCD(dwInterval)
	for id, vo in pairs( self.buffList ) do
		local cfg = t_buff[ vo.tid ];
		if cfg and cfg.last_time ~= -1 then -- -1 为不限时的buff
			local restTime = vo.time - dwInterval;
			if restTime < 0 then
				self:Remove( vo.id );
			else
				vo.time = restTime;
			end
		end
	end
end


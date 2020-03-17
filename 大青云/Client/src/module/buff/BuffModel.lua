--[[
存放主玩家的Buff,用于UI显示
lizhuangzhuang
2014年9月16日14:58:41
]]
_G.classlist['BuffModel'] = 'BuffModel'
_G.BuffModel = Module:new();
BuffModel.objName = 'BuffModel'

BuffModel.buffList = {};

--增加一个buff
function BuffModel:Add(id,tid,time,caster)
	if self.buffList[id] then
		Debug('Error:Has a buff in main player,cannot add.');
		return;
	end
	local vo = {};
	vo.id = id;
	vo.tid = tid;
	vo.time = time;
	vo.caster = caster;
	vo.params = {};
	self.buffList[vo.id] = vo;
	self:sendNotification(NotifyConsts.BuffRefresh);
end

function BuffModel:GetAllBuff()
	return self.buffList
end

--获取玩家身上的一个buff
function BuffModel:GetBuff(id)
	return self.buffList[id];
end

--移除一个buff
function BuffModel:Remove(id)
	if self.buffList[id] then
		self.buffList[id] = nil;
		self:sendNotification( NotifyConsts.BuffRefresh );
	end
end

--清除所有buff
function BuffModel:Clear()
	self.buffList = {}
	self:sendNotification( NotifyConsts.BuffRefresh );
end

--获取UI显示列表
function BuffModel:GetShowList()
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
function BuffModel:UpdateBuffCD(dwInterval)
	for id, vo in pairs(self.buffList) do
		local cfg = t_buff[ vo.tid ];
		if cfg.last_time ~= -1 then -- -1 为不限时的buff
			local restTime = vo.time - dwInterval;
			if restTime < 0 then
				self:Remove(vo.id);
			else
				vo.time = restTime;
			end
		end
	end
end
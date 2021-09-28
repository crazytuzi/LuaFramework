------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE =require("logic/entity/i3k_npc").i3k_npc;
require("logic/entity/i3k_entity")
local ENTITYBASE = i3k_entity;

------------------------------------------------------
i3k_npc_disposable = i3k_class("i3k_npc_disposable", BASE);

function i3k_npc_disposable:ctor(guid)
	self._entityType	= eET_DisposableNPC;
	self._movePointIndex = 1 --寻路点index
	self._moveTick = 0 --计时器
	self._moveNeedTime = 0 -- 移动到下一个点所需要的时间 
	self._isNotCreateFloor = false --是否不创建寻路地板
end

function i3k_npc_disposable:Create(id)
	local basecfg = i3k_db_npc[id]
	if not basecfg then
		return false;
	end

	local cfg = i3k_db_monsters[basecfg.monsterID];
	if not cfg then
		return false;
	end

	local skills = { };
	if cfg.skills then
		for k, v in ipairs(cfg.skills) do
			skills[v] = { id = v, lvl = cfg.slevel[k] or 0 };
		end
	end
	
	self._baseCfg = basecfg;
	return self:CreateFromCfg(id, basecfg.remarkName, cfg, cfg.level, skills, true);
end

function i3k_npc_disposable:OnUpdate(dTime)
	ENTITYBASE.OnUpdate(self, dTime);	
end

function i3k_npc_disposable:OnLogic(dTick)
	ENTITYBASE.OnLogic(self, dTick);
	if self._moveNeedTime ~= 0 then
		self._moveTick = self._moveTick + dTick * i3k_engine_get_tick_step()
		if self._moveTick > self._moveNeedTime * 1000 then
			self._moveTick = 0
			self._movePointIndex = self._movePointIndex + 1
			if self._movePoints[self._movePointIndex] then
				self._moveNeedTime = self._movePoints[self._movePointIndex].time
				self:StartMove()				
			end
		end
	end
end

function i3k_npc_disposable:CreateTitle()
	local title = BASE.CreateTitle(self)
	return title;
end

function i3k_npc_disposable:IsAttackable(attacker)
	return false;
end

function i3k_npc_disposable:CanMove()
	return true
end

-- 设置多个寻路点
function i3k_npc_disposable:SetMovePoints(points, index, isNotFloot)
	self._isCreateFloor = isNotFloot
	self._movePoints = points
	self._movePointIndex = index
	self._moveNeedTime = points[index].time
	self:SetPos(i3k_world_pos_to_logic_pos((self._movePoints[index].point)))
	self:StartMove()
end

--TODO 优化
function i3k_npc_disposable:StartMove()
	local world = i3k_game_get_world()
	if world then
		local point = self._movePoints[self._movePointIndex].point
		local nextPoint = self._movePoints[self._movePointIndex].nextPoint
		local notRemove = #self._movePoints ~= self._movePointIndex
		world:DisposableNpcMove(self, nextPoint, false, notRemove, g_MOVE_STOP_DISTANCE)
		if not self._isCreateFloor then
		if notRemove then
			world:CreateNpcPathEntity(self._movePointIndex, i3k_world_pos_to_logic_pos(point))
		else
			world:CreateNpcPathEntity(self._movePointIndex, i3k_world_pos_to_logic_pos(point))
			world:CreateNpcPathEntity(self._movePointIndex + 1, i3k_world_pos_to_logic_pos(nextPoint))
		end
	end
end
end

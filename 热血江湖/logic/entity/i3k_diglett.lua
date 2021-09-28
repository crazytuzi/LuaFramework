------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/i3k_entity_net").i3k_entity_net;


------------------------------------------------------
i3k_diglett = i3k_class("i3k_diglett", BASE);
function i3k_diglett:ctor(guid)
	self._cfg = {}
	self._cfg.speed 	= 10
	self._isStand		= false
	self._entityType	= eET_Diglett;
	self._birthPos		= Engine.SVector3(0, 0, 0);
	self._timetick		= 0;
	self._groupType		= eGroupType_N -- 中立
	self._properties 	= self:InitProperties();
	self._isTrueDiglett = true
	self._lastStandTime = 0
	self._modelId		= 0
end

function i3k_diglett:createDiglett(id, modelId, isDiglett)
	self._id = id
	self._modelId = modelId
	self._isTrueDiglett = isDiglett
	--i3k_log(string.format("modelId :%s", modelId))
	--self:EnableOccluder(true)
	self:CreateRes(modelId)
end

function i3k_diglett:playRiseAct()
	local alist = {}
	table.insert(alist, {actionName = "born", actloopTimes = 1})
	table.insert(alist, {actionName = "stand", actloopTimes = -1})
	self:PlayActionList(alist, 1)
	self._lastStandTime = 0
	self._isStand = true
end

function i3k_diglett:playGrowAct()
	self:Play("grow", 1)
	self._isStand = false
	self._co = g_i3k_coroutine_mgr:StartCoroutine(function()
		local time = 0
		if self._isTrueDiglett then
			time = i3k_db_diglett_position.true_time
		else
			time = i3k_db_diglett_position.false_time
		end
		g_i3k_coroutine_mgr.WaitForSeconds(i3k_db_diglett_position.true_time)
		local world = i3k_game_get_world()
		if world then
			world:RemoveDigletts(self._id)
			self._co = nil
		end
	end)
end

function i3k_diglett:playDeathAct()
	self:Play("death", 1)
	self._isStand = false
	self._co = g_i3k_coroutine_mgr:StartCoroutine(function()
		if self._isTrueDiglett then
			g_i3k_coroutine_mgr.WaitForSeconds(i3k_db_diglett_position.death_time[1])
		else
			g_i3k_coroutine_mgr.WaitForSeconds(i3k_db_diglett_position.death_time[2])
		end
		local world = i3k_game_get_world()
		if world then
			world:RemoveDigletts(self._id)
			self._co = nil
		end
	end)
end

function i3k_diglett:OnSelected(val)
	if val then
		if self._isStand then
			if self._isTrueDiglett then
				i3k_sbean.findMooncake_click(g_i3k_db.i3k_db_open_hit_diglett_id(e_TYPE_DIGLETT), self._modelId, 1)
			else
				i3k_sbean.findMooncake_click(g_i3k_db.i3k_db_open_hit_diglett_id(e_TYPE_DIGLETT), self._modelId, 0)
			end
			self:playGrowAct()
		end
	end
end

function i3k_diglett:GetIsTrueDiglett()
	return self._isTrueDiglett
end

function i3k_diglett:OnUpdate(dTime)
	if self._isStand then
		self._lastStandTime = self._lastStandTime + dTime
		if self._lastStandTime >= 2 then
			self._lastStandTime = 0
			self:playDeathAct()
		end
	end
end

function i3k_diglett:CanRelease()
	return true;
end

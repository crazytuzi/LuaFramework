--Model3.lua
--/*-----------------------------------------------------------------
--* Module:  Model3.lua
--* Author:  Andy
--* Modified: 2016年05月24日
--* Purpose: 收益调整类
--* 52：副本收益限时调整 54：怪物收益限时调整 55：任务收益限时调整
-------------------------------------------------------------------*/

require ("base.class")
Model3 = class()

local prop = Property(Model3)
prop:accessor("modelID")
prop:accessor("activityID")
prop:accessor("roleID")
prop:accessor("roleSID")

function Model3:__init(modelID, activityID, roleID, roleSID)
    prop(self, "modelID", modelID)
    prop(self, "activityID", activityID)
    prop(self, "roleID", roleID)
	prop(self, "roleSID", roleSID)

	self._datas = {}
	self._datas.read = true
	self:initialize()
end

function Model3:req()
	local roleID, activityID = self:getRoleID(), self:getActivityID()
	local player = g_entityMgr:getPlayer(roleID)
	local model = g_DataMgr:getActivityConfig(self:getModelID(), activityID)
	if not player or not model then
		return
	end
	local ret = {}
	ret.modelID = model.modelID
	ret.activityID = activityID
	ret.startTick = model.startTime
	ret.endTick = model.endTime
	ret.desc = model.desc
	fireProtoMessage(roleID, ACTIVITY_SC_RET, "ActivityRet", ret)
	if self._datas.read then
		self._datas.read = false
		self:cast2DB()
	end
end

function Model3:initialize()
	self._datas.status = 1		--活动领取状态（0：可领取 1：未达成 2：已领取）
	self._datas.time = 0		--状态改变时间
end

function Model3:redDot()
	if self._datas.status == 0 or self._datas.read then
		return true
	end
	return false
end

--重置状态
function Model3:resetStatus()
	local model = g_DataMgr:getActivityConfig(self:getModelID(), self:getActivityID())
	if g_ActivityMgr:canLoop(model, self._datas.time) then
		self:initialize()
	end
end

function Model3:loadDBdata(datas)
	self._datas = datas
	self:resetStatus()
end

function Model3:cast2DB()
	g_ActivityMgr:cast2Cache(self:getRoleSID(), self:getModelID(), self:getActivityID(), self._datas)
end
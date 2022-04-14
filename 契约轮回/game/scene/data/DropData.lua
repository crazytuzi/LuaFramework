--
-- @Author: LaoY
-- @Date:   2018-09-26 17:19:52
--
DropData = DropData or class("DropData",ObjectData)
local DropData = DropData
function DropData:ctor()
	--/*掉落类型*/ 1.正常掉落 2.半虚拟掉落 3.
	self.drop_type = 1

	--  DROP_MODE_BAG = 1, -- 直接进背包
	-- 	DROP_MODE_SCENE = 2, -- 掉场景上
	-- 	DROP_MODE_DUMMY = 3, -- 虚拟掉落，需要拾取
	-- 	DROP_MODE_DUMMY2 = 4, -- 虚拟掉落，自动拾取

	self.drop_type = self.mode
	if not self.drop_type or self.drop_type == 0 then
		self.drop_type = enum.DROP_MODE.DROP_MODE_BAG
	end

	local from_object = SceneManager:GetInstance():GetObject(self.from)
	if from_object then
		self.from_pos = from_object:GetPosition()
	end
end

-- function DropData:IsContainSelf()
-- 	return self:IsBelongSelf() or not self:IsLock()
-- end

function DropData:IsBelongSelf()
	if table.isempty(self.belong) then
		return true
	end
	local main_role_id = RoleInfoModel:GetInstance():GetMainRoleId()
	for k,id in pairs(self.belong) do
		if id == main_role_id then
			return true
		end
	end
	return false
end

function DropData:IsLock()
	local cur_time = os.time()
	return cur_time <= self.unlock
end

function DropData:dctor()
end

--是否脱离服务端的九宫格
--服务端九宫格是正方形
local serverW = 700
local serverH = 600
function DropData.IsOutOfMainRole(actor)
	local main_role_pos
	local main_role = SceneManager:GetInstance():GetMainRole()
	if main_role then
		main_role_pos = main_role:GetPosition()
	end
	if not main_role_pos then
		local scene_info_data = SceneManager:GetInstance():GetSceneInfo()
		if scene_info_data then
			main_role_pos = scene_info_data.actor.coord
		end
	end
	if not main_role_pos then
		return true
	end
	local drop_pos = actor.coord
	if math.abs(main_role_pos.x - drop_pos.x) > serverW or math.abs(main_role_pos.y - drop_pos.y) > serverH then
		return true
	end 
	return false
end
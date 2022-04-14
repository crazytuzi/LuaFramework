-- 
-- @Author: LaoY
-- @Date:   2018-08-02 17:03:53
-- 

MonsterData = MonsterData or class("MonsterData",ObjectData)
local MonsterData = MonsterData
function MonsterData:ctor()
	if self.ext and self.ext.fission_id then
		local object = SceneManager:GetInstance():GetObject(self.ext.fission_id)
		if not object then
			self.ext.fission_id = nil
			self.ext.fission_x = nil
			self.ext.fission_y = nil
		end
	end

	-- local p_buff = {
	-- 	id = 304010003,
	-- 	type = 1,
	-- 	value = 1,
	-- 	eff = 1202,
	-- 	etime = os.time() + 10000,
	-- 	group = 0,
	-- }
	-- Yzprint('--LaoY MonsterData.lua,line 26--',self.uid)
	-- self:AddBuff(p_buff)
end

function MonsterData:dctor()
end

-- 是否是分裂怪
function MonsterData:IsFission()
	return self.ext and self.ext.fission_id ~= nil
end

-- 分裂怪初始的坐标
function MonsterData:GetFissionPos()
	return {x = self.ext.fission_x,y = self.ext.fission_y}
end
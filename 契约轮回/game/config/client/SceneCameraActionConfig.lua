--
-- @Author: LaoY
-- @Date:   2019-05-21 17:50:11
--


--[[
	@author LaoY
	@des	场景摄像机运动轨迹

	@param1 DelayTime 	延迟时间
	@param2 Scale 		开始摄像机的视野倍数
	@param3 ActionTime 	运动时间 多长回归到一倍大小
	@param4 PosType 	1 锁定位置 固定在中间
--]]
SceneCameraActionConfig = {
	-- 竞技场 场景
	[30371] = {
		DelayTime = 2.7,
		Scale = 1.4,
		ActionTime = 0.3,
		PosType = 1,
	},


}


local function HandlerConfig()
	for scene_id,config in pairs(SceneCameraActionConfig) do
		if not config.PosType then
			config.PosType = 1
		end
	end
end

HandlerConfig()
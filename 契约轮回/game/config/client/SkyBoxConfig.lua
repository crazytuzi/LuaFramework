--
-- @Author: LaoY
-- @Date:   2019-02-20 10:49:53
--

--[[
	@author LaoY
	@des	
	场景ID做key值

	/*配置说明*/
	@param1 res    		资源名字
	@param2 type    	天空盒运动类型 1.上下运动(会水平居中) 2.左右运动(会垂直居中) 3.上下左右运动
										11 自动上下运动
	/*以下选填*/
	@param  ref_scene	引用场景ID(天空盒也复用的才需要) 不填，默认和配置key是同一个
	@param  speed		每帧移动速度，自动滚动才有效
--]]	

-- 放前面的在底
SkyBoxConfig = {
	-- [11001] = {
	-- 	{assetName = "11001_1",type = 3,ref_scene = 11001},
	-- },
	-- [11003] = {
		-- {assetName = "11003_1",type = 3,ref_scene = 11003},
		-- {assetName = "11003_2",type = 3,ref_scene = 11003},
	-- },
	[30001] = {
		{assetName = "30001_1",type = 3,ref_scene = 30001},
		{assetName = "30001_2",type = 11,ref_scene = 30001,speed = -3},
	},
	[80001] = {
		{assetName = "80001",type = 1,ref_scene = 30001},
		{assetName = "80001_1",type = 3,ref_scene = 30001},
	},

}

-- SkyBoxConfig = {}
local function HandlerConfig()
	for scene_id,list in pairs(SkyBoxConfig) do
		local len = #list
		for index,v in pairs(list) do
			v.layer = (len - index + 1) * 10
			v.scene_id = scene_id
			if not v.ref_scene then
				v.ref_scene = scene_id
			end
		end
	end
end
HandlerConfig()
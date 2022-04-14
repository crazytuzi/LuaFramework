--
-- @Author: LaoY
-- @Date:   2018-11-30 14:37:24
--

--[[
	@author LaoY
	@des	每个跳跃点在哪个地方要写上注释，配置特殊最后一段跳跃要跳跃至目的地
	场景ID做key值
	跳跃点ID做key值

	/*配置说明*/
	@param1 end_pos 		当前结束坐标
	@param2 action_index 	动作序号 分跳跃点1 2 3 4（出正式动作后补上中文描述，ps：1翻滚跳跃 2旋转跳跃 3滑翔跳跃 4平移）
	@param3 rate 			可以接一下跳跃的跳跃动作完成比例，比如空中接力跳。0.5是最高点，1是已经落地;可不填，默认是1
	@param4 h_speed 			水平移动速度。可不填，默认
	@param4 v_speed 			垂直方向速度。可不填，默认
--]]
JumpConfig = {
	--新手村场景
	[11001] = {
		-- xxx跳跃至xxx
		[1] = {
			 {end_pos = {x=3048,y=7589},action_index = 1,rate = 1,h_speed = 1100,v_speed =300},
			 {end_pos = {x=3487,y=6974},action_index = 2,rate = 1,h_speed = 800,v_speed =450},
		},

		-- xxx跳跃至xxx
		[2] = {
			 {end_pos = {x=3048,y=7589},action_index = 1,rate = 1,h_speed = 800,v_speed =450},
			 {end_pos = {x=2169,y=8468},action_index = 2,rate = 1,h_speed = 1100,v_speed =300},
		},

		[3] = {
			  {end_pos = {x=8521,y=7402},action_index = 1,rate = 1,h_speed = 1200,v_speed =450},
			  {end_pos = {x=9160,y=7096},action_index = 2,rate = 1,h_speed = 1200,v_speed =200},
		},

		[4] = {
			 {end_pos = {x=8521,y=7459},action_index = 1,rate = 1,h_speed = 1200,v_speed =450},
			 {end_pos = {x=7679,y=7818},action_index = 2,rate = 1,h_speed = 1200,v_speed =200},
		},
		[5] = {
			 {end_pos = {x=8705,y=6173},action_index = 1,rate = 1,h_speed = 1000,v_speed =450},
			 {end_pos = {x=8254,y=5331},action_index = 2,rate = 1,h_speed = 1200,v_speed =200},
		},
		[6] = {
			 {end_pos = {x=8705,y=6173},action_index = 1,rate = 1,h_speed = 1200,v_speed =450},
			 {end_pos = {x=8760,y=6609},action_index = 2,rate = 1,h_speed = 1200,v_speed =200},
		},
		[7] = {
			 {end_pos = {x=1936,y=3367},action_index = 1,rate = 1,h_speed = 1000,v_speed =450},
			 {end_pos = {x=1487,y=2825},action_index = 2,rate = 1,h_speed = 1100,v_speed =200},
			 {end_pos = {x=1146,y=2189},action_index = 2,rate = 1,h_speed = 1000,v_speed =450},
		},
		[8] = {
			 {end_pos = {x=1487,y=2825},action_index = 1,rate = 1,h_speed = 1000,v_speed =450},
			 {end_pos = {x=1935,y=3367},action_index = 2,rate = 1,h_speed = 1100,v_speed =200},
			 {end_pos = {x=2997,y=3081},action_index = 2,rate = 1,h_speed = 1000,v_speed =450},
		},

	 },

	[11002] = {
		-- xxx跳跃至xxx
		[3] = {
			 -- {end_pos = {x=912,y=2598},action_index = 1,rate = 1,h_speed = 300},
		 {end_pos = {x=3080,y=2654},action_index = 2,rate = 1,h_speed = 800,v_speed =500},
		},

		-- xxx跳跃至xxx
		[4] = {
			 -- {end_pos = {x=1042,y=2664},action_index = 1,rate = 1,h_speed = 300},
			 {end_pos = {x=2481,y=3067},action_index = 2,rate = 1,h_speed = 800,v_speed =500},
		},

		[1] = {
			  {end_pos = {x=6800,y=3420},action_index = 1,rate = 0.3,h_speed = 300,v_speed =300},
			  {end_pos = {x=7036,y=3679},action_index = 2,rate = 0.6,h_speed = 400,v_speed =300},
			  {end_pos = {x=6672,y=4105},action_index = 3,rate = 1,h_speed = 600,v_speed =100},
		},

		[2] = {
			 {end_pos = {x=7036,y=3679},action_index = 1,rate = 0.3,h_speed = 400,v_speed =300},
			 {end_pos = {x=6800,y=3420},action_index = 2,rate = 0.6,h_speed = 400,v_speed =300},
			 {end_pos = {x=6931,y=3176},action_index = 3,rate = 1,h_speed = 400,v_speed =100},
			 
		},

	 },
	[11003] = {
		-- xxx跳跃至xxx
		[1] = {
			 -- {end_pos = {x=912,y=2598},action_index = 1,rate = 1,h_speed = 300},
		 {end_pos = {x=8381,y=5333},action_index = 2,rate = 1,h_speed = 1000,v_speed =300},
		},

		-- xxx跳跃至xxx
		[2] = {
			 -- {end_pos = {x=1042,y=2664},action_index = 1,rate = 1,h_speed = 300},
			 {end_pos = {x=8998,y=4591},action_index = 2,rate = 1,h_speed = 1000,v_speed =300},
		},


	 },
	[11004] = {
		-- xxx跳跃至xxx
		[8] = {
		 -- {end_pos = {x=4522,y=3157},action_index = 1,rate = 1,h_speed = 800,v_speed =100},
		 {end_pos = {x=5511,y=3727},action_index = 2,rate = 1,h_speed = 1100,v_speed =600},
		},

		-- xxx跳跃至xxx
		[9] = {
			 -- {end_pos = {x=1042,y=2664},action_index = 1,rate = 1,h_speed = 300},
			 {end_pos = {x=4188,y=2669},action_index = 3,rate = 1,h_speed = 1000,v_speed =600},
		},

		[13] = {
			  -- {end_pos = {x=6800,y=3420},action_index = 1,rate = 0.3,h_speed = 300,v_speed =300},
			  {end_pos = {x=3220,y=5517},action_index = 1,rate = 1,h_speed = 1000,v_speed =500},
			  {end_pos = {x=2562,y=5713},action_index = 2,rate = 1,h_speed = 1000,v_speed =500},
		},

		[14] = {
			 -- {end_pos = {x=7036,y=3679},action_index = 1,rate = 0.3,h_speed = 400,v_speed =300},
			 {end_pos = {x=3240,y=5477},action_index = 1,rate = 1,h_speed = 1000,v_speed =600},
			 {end_pos = {x=3773,y=5167},action_index = 2,rate = 1,h_speed = 1000,v_speed =600},
			 
		},
		[5] = {
			  -- {end_pos = {x=6800,y=3420},action_index = 1,rate = 0.3,h_speed = 300,v_speed =300},
			  {end_pos = {x=2564,y=6262},action_index = 1,rate = 1,h_speed = 1000,v_speed =600},
			  {end_pos = {x=2014,y=6531},action_index = 2,rate = 1,h_speed = 1000,v_speed =600},
		},

		[6] = {
			 -- {end_pos = {x=7036,y=3679},action_index = 1,rate = 0.3,h_speed = 400,v_speed =300},
			 {end_pos = {x=2564,y=6262},action_index = 2,rate = 1,h_speed = 1000,v_speed =600},
			 {end_pos = {x=2562,y=5713},action_index = 1,rate = 1,h_speed = 1000,v_speed =600},
			 
		},
     	[11] = {
			  {end_pos = {x=5348,y=5447},action_index = 1,rate =1,h_speed = 1200,v_speed =450},
			  {end_pos = {x=5994,y=5792},action_index = 2,rate = 1,h_speed = 1200,v_speed =450},
		},

		[12] = {
			 {end_pos = {x=5348,y=5447},action_index = 1,rate = 1,h_speed = 1200,v_speed =450},
			 {end_pos = {x=4724,y=5115},action_index = 2,rate = 1,h_speed = 1200,v_speed =450},
			 
		},
	 },

	[11006] = {
		-- xxx跳跃至xxx

		[1] = {
			  {end_pos = {x=7572,y=3759},action_index = 2,rate = 1,h_speed = 1200,v_speed =450},
		},

		[2] = {
			 {end_pos = {x=7223,y=2568},action_index = 2,rate = 1,h_speed = 1200,v_speed =450},		 
		},
	 },
}



function GetFlyJumpConfig(start_pos,end_pos,jump_count)
	local dis = Vector2.Distance(start_pos,end_pos)
	local speed = dis/2.0
	-- speed = speed < 500 and 500 or speed
	local dis_list = {}
	if dis > 1200 then
		dis_list = {400,800,dis}
	elseif dis > 800 then
		local average = dis/3
		dis_list = {average,average * 2,dis}
	elseif dis > 400 then
		local average = dis/2
		dis_list = {average,dis}
	else
		dis_list = {dis}
	end
	local config = {}
	for k,v in pairs(dis_list) do
		local rate = k == #dis_list and 1 or 0.5
		local index = k == #dis_list and 3 or k
		local pos = GetDirDistancePostion(start_pos,end_pos,v)
		config[k] = {end_pos = pos , action_index = index, rate = rate , h_speed = speed}
	end
	-- local cf = config[jump_count]
	-- return cf,jump_count == #config
	return config
end
-- 繁荣度配置

local function returnCfg(clientPlat)

	local commonCfg = {
		 -- 时间恢复繁荣度 /每分钟		
		 -- 60级 全满需要恢复1天	
		timeGetBoom=20,

		 -- 资源恢复	
		resGetBoom =
		{
		 -- count 资源量, value 繁荣度	
			r1={count=10000, value=1},
			r2={count=10000, value=1},
			r3={count=10000, value=1},
			r4={count=10000, value=1},
			gold={count=10000, value=1},

		},

		-- 钻石恢复
		gemsGetBoom = {0.1, 0.5, 1.0},
--		gemsGetBoom = { gems= 1, value = MaxBoom^0.25},
--		gemCost = {( MaxBoom - curBoom )/ maxBoom * maxBoom ^0.75}

		--繁荣度最大值 建筑的type作为索引
	    maxBoom=
	    {
	        t1  ={base=20,add=5},
	        t2  ={base=20,add=5},
	        t3  ={base=20,add=5},
	        t4  ={base=20,add=5},
	        t5  ={base=20,add=5},
	        t6  ={base=20,add=5},
	        t7  ={base=20,add=5},
	        t8  ={base=20,add=5},
	        t9  ={base=20,add=5},
	        t10 ={base=20,add=5},
	        t14 ={base=20,add=5},
			t18 ={base=20,add=5},
	    },


--		-- 繁荣度损失
--		value = (1 -fightMax) / (2*( 1 + fightMax))

		-- 效果
		effect =
		{
			--增加带兵量 {count 繁荣度， value 带兵量}
			troops = {count=500, value=5,},
			--增加资源量 {count 繁荣度， value 资源比例}
			resource = {count=1250, value=0.01},
		},

		 -- 溢出比例
		overflowRate=0.1,
		 -- 掠夺值比例
		pillageRate = 0.2,

	}

	return commonCfg
end

return returnCfg

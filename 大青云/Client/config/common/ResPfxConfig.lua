_G.ResPfxConfig =
{
-------------------------------标配、示例----------------------------
   --[ID] = { ----------标准配置，下面参数，如果没有则直接不填  或者值填nil，减少服务器判断时间，提高效率
	    --delay=2500,		--特效延迟时间
		--bBind = true; --设置特效不追尾     true:不追     false:追
		--pfxName = "TX_liandao_juesedenglu.pfx",
		--MoveStart=_Vector3.new(0,2.8,0),--特效起始偏移
		--MoveStop =nil,--技能结束偏移
		--MoveTime = nil,		--技能偏移时间
		--ScalingStart = nil, --放缩
		--ScalingStop = nil,
		--ScalingTime = nil,		
		--RotationStart = _Vector3.new(math.pi/2,0,0),--分别代表绕,x,y,z旋转的角度
		--RotationStop = nil,
		--RotationTime = nil, 
	--};
	---■■■■0号ID不要用，其他地方有需要0
	----------------------野外传送 传送门类型1用
	[1] = { 
	    delay=nil,		--特效延迟时间
		bBind = false;  --特效不追尾
		pfxName = "v_chuansongmen.pfx",
		MoveStart=_Vector3.new(0,0,3),--特效起始偏移
		MoveStop =_Vector3.new(0,math.pi/2,0),--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		RotationStart = nil,--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};

	----------------------副本传送 传送门类型2用
	[2] = { 
	    delay=nil,		--特效延迟时间
		bBind = false;  --特效不追尾
		pfxName = "chuansongmen_fuben_05.pfx",
		MoveStart=_Vector3.new(0,0,3),--特效起始偏移
		MoveStop =nil,--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		--RotationStart = _Vector3.new(math.pi/2,0,0),--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};
	---------------------选中光效---可攻击（红色）
	--点地面可行走
	[90001] = { 
	    delay=nil,		--特效延迟时间
		bBind = false;  --特效不追尾
		pfxName = "v_diandi.pfx",
		MoveStart=_Vector3.new(0,0,2),--特效起始偏移
		MoveStop =nil,--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		RotationStart = nil,--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};
	
	--点地面不可行走
	[90002] = { 
	    delay=nil,		--特效延迟时间
		bBind = false;  --特效不追尾
		pfxName = "v_jindian.pfx",
		MoveStart=_Vector3.new(0,0,2),--特效起始偏移
		MoveStop =nil,--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		RotationStart = nil,--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};

	--角色升级特效
	[90004] = {
		delay=nil,		--特效延迟时间
		bBind = false;  --特效不追尾
		pfxName = "v_zhujue_shengji.pfx",
		MoveStart=_Vector3.new(0,0,3),--特效起始偏移
		MoveStop =_Vector3.new(0,math.pi/2,0),--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		RotationStart = nil,--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};
	--怪物进入战斗状态的感叹号特效
	[10000] = { 
	    delay=nil,		--特效延迟时间
		bBind = true;  --特效不追尾
		pfxName = "v_gantanhao.pfx",
		--MoveStart=_Vector3.new(0, 0, 20),--特效起始偏移
		MoveStop =nil,--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		--RotationStart = _Vector3.new(math.pi/2,0,0),--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};
	--受击特效
	[10001] = { 
	    delay=nil,		--特效延迟时间
		bBind = true;  --特效不追尾
		pfxName = "v_boom_huo.pfx",
		MoveStart=_Vector3.new(0, -1, 0),--特效起始偏移
		MoveStop =nil,--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		--RotationStart = _Vector3.new(math.pi/2,0,0),--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};
	--受击特效
	[10002] = {
	    delay=nil,		--特效延迟时间
		bBind = true;  --特效不追尾
		pfxName = "v_boom.pfx",
		MoveStart=_Vector3.new(0, -1, 0),--特效起始偏移
		MoveStop =nil,--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		--RotationStart = _Vector3.new(math.pi/2,0,0),--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};
	--怪物定身特效
	[10003] = {
	    delay=nil,		--特效延迟时间
		bBind = true;  --特效不追尾
		pfxName = "v_guai_ding_06.pfx",
		--MoveStart=_Vector3.new(0, -1, 0),--特效起始偏移
		MoveStop =nil,--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		--RotationStart = _Vector3.new(math.pi/2,0,0),--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};
	--掉落爆装备特效
	[10004] = {
	    delay=nil,		--特效延迟时间
		bBind = true;  --特效不追尾
		pfxName = "v_UI_diaoluo.pfx",
		--MoveStart=_Vector3.new(0, -1, 0),--特效起始偏移
		MoveStop =nil,--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		--RotationStart = _Vector3.new(math.pi/2,0,0),--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};
	-- 宝箱特效紫色
	[10005] = {
	    delay=nil,		--特效延迟时间
		bBind = true;  --特效不追尾
		pfxName = "v_pfx_baoxiang_z.pfx",
		--MoveStart=_Vector3.new(0, -1, 0),--特效起始偏移
		MoveStop =nil,--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		--RotationStart = _Vector3.new(math.pi/2,0,0),--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};
	-- 宝箱特效橙色
	[10006] = {
	    delay=nil,		--特效延迟时间
		bBind = true;  --特效不追尾
		pfxName = "v_pfx_baoxiang_c.pfx",
		--MoveStart=_Vector3.new(0, -1, 0),--特效起始偏移
		MoveStop =nil,--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		--RotationStart = _Vector3.new(math.pi/2,0,0),--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};
	
	-- 武器特效紫色
	[10007] = {
	    delay=nil,		--特效延迟时间
		bBind = true;  --特效不追尾
		pfxName = "v_pfx_chuizi_z.pfx",
		-- MoveStart=_Vector3.new(2, 0, 0),--特效起始偏移
		MoveStop =nil,--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		-- RotationStart = _Vector3.new(math.pi/20,0,0),--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};

	--通用眩晕特效
	[10008] = {
	    delay=nil,		--特效延迟时间
		bBind = true;  --特效不追尾
		pfxName = "v_tongyongxuanyun.pfx",
		--MoveStart=_Vector3.new(0, -1, 0),--特效起始偏移
		MoveStop =nil,--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		--RotationStart = _Vector3.new(math.pi/2,0,0),--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};
	--打坐特效
	[10009] = {
	    delay=nil,		--特效延迟时间
		bBind = false;  --特效不追尾
		pfxName = "v_dazuo.pfx",
		--MoveStart=_Vector3.new(0, -1, 0),--特效起始偏移
		MoveStop =nil,--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		--RotationStart = _Vector3.new(math.pi/2,0,0),--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};
	--打坐传输特效
	[10010] = {
	    delay=nil,		--特效延迟时间
		bBind = false;  --特效不追尾
		pfxName = "v_dazuo_chuanshu.pfx",
		--MoveStart=_Vector3.new(0, -1, 0),--特效起始偏移
		MoveStop =nil,--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		--RotationStart = _Vector3.new(math.pi/2,0,0),--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};
		--QTE
	[10011] = {
	    delay=nil,		--特效延迟时间
		bBind = false;  --特效不追尾
		pfxName = "v_ty_xx.pfx",
		--MoveStart=_Vector3.new(0, -1, 0),--特效起始偏移
		MoveStop =nil,--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		--RotationStart = _Vector3.new(math.pi/2,0,0),--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};
	
	[10012] = { 
	    delay=nil,		--特效延迟时间
		bBind = false;  --特效不追尾
		pfxName = "v_chuansongmen.pfx",
		MoveStart=_Vector3.new(0,0,3),--特效起始偏移
		MoveStop =_Vector3.new(0,math.pi/2,0),--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		RotationStart = nil,--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};
	[10013] = { 
	    delay=nil,		--特效延迟时间
		bBind = false;  --特效不追尾
		pfxName = "v_chuansongmen.pfx",
		MoveStart=_Vector3.new(0,0,3),--特效起始偏移
		MoveStop =_Vector3.new(0,math.pi/2,0),--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		RotationStart = nil,--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};
	[10014] = { 
	    delay=nil,		--特效延迟时间
		bBind = false;  --特效不追尾
		pfxName = "v_chuansongmen.pfx",
		MoveStart=_Vector3.new(0,0,3),--特效起始偏移
		MoveStop =_Vector3.new(0,math.pi/2,0),--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		RotationStart = nil,--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};
	[10015] = { 
	    delay=nil,		--特效延迟时间
		bBind = false;  --特效不追尾
		pfxName = "v_ty_hit.pfx",
		--MoveStart=_Vector3.new(0, -1, 0),--特效起始偏移
		-- MoveStop =nil,--技能结束偏移
		-- MoveTime = nil,		--技能偏移时间
		-- ScalingStart = nil, --放缩
		-- ScalingStop = nil,
		-- ScalingTime = nil,		
		-- --RotationStart = _Vector3.new(math.pi/2,0,0),--分别代表绕,x,y,z旋转的角度
		-- RotationStop = nil,
		-- RotationTime = nil, 
	};
	[10016] = { 
	    delay=nil,		--特效延迟时间
		bBind = false;  --特效不追尾
		pfxName = "v_xuanzhong_languang.pfx",
		--MoveStart=_Vector3.new(0, 0, 0),--特效起始偏移
		-- MoveStop =nil,--技能结束偏移
		-- MoveTime = nil,		--技能偏移时间
		-- ScalingStart = nil, --放缩
		-- ScalingStop = nil,
		-- ScalingTime = nil,		
		-- --RotationStart = _Vector3.new(math.pi/2,0,0),--分别代表绕,x,y,z旋转的角度
		-- RotationStop = nil,
		-- RotationTime = nil, 
	};
	
	---------------------选中光效---不可攻击（玩家-蓝色）
	[10017] = { 
	    delay=nil,		--特效延迟时间
		bBind = false;  --特效不追尾
		pfxName = "v_xuanzhong_languang.pfx",
		--MoveStart=_Vector3.new(0, 0, 0),--特效起始偏移
		--MoveStop =nil,--技能结束偏移
		--MoveTime = nil,		--技能偏移时间
		--ScalingStart = nil, --放缩
		--ScalingStop = nil,
		--ScalingTime = nil,		
		--RotationStart = _Vector3.new(math.pi/2,0,0),--分别代表绕,x,y,z旋转的角度
		--RotationStop = nil,
		--RotationTime = nil, 
	};
	
	---------------------选中光效---boss
	[10018] = {
		bBind = false;  --特效不追尾
	    delay=nil,		--特效延迟时间
		pfxName = "v_xuanzhong_hongguang.pfx",
		--MoveStart=_Vector3.new(0, 0, 0),--特效起始偏移
		-- MoveStop =nil,--技能结束偏移
		-- MoveTime = nil,		--技能偏移时间
		-- ScalingStart = nil, --放缩
		-- ScalingStop = nil,
		-- ScalingTime = nil,		
		-- --RotationStart = _Vector3.new(math.pi/2,0,0),--分别代表绕,x,y,z旋转的角度
		-- RotationStop = nil,
		-- RotationTime = nil, 
	};
		---------------------选中光效---NPC
	[10019] = {
		bBind = false;  --特效不追尾
	    delay=nil,		--特效延迟时间
		pfxName = "v_xuanzhong_huangguang.pfx",
		MoveStart=_Vector3.new(0, 0, 0),--特效起始偏移
		-- MoveStop =nil,--技能结束偏移
		-- MoveTime = nil,		--技能偏移时间
		-- ScalingStart = nil, --放缩
		-- ScalingStop = nil,
		-- ScalingTime = nil,		
		-- --RotationStart = _Vector3.new(math.pi/2,0,0),--分别代表绕,x,y,z旋转的角度
		-- RotationStop = nil,
		-- RotationTime = nil, 
	};

		---------------------己方旗帜特效
	[10020] = {
		bBind = false;  --特效不追尾
	    delay=nil,		--特效延迟时间
		pfxName = "zc_qz_ywxz.pfx",
		--MoveStart=_Vector3.new(0, 0, 0),--特效起始偏移
		-- MoveStop =nil,--技能结束偏移
		-- MoveTime = nil,		--技能偏移时间
		-- ScalingStart = nil, --放缩
		-- ScalingStop = nil,
		-- ScalingTime = nil,		
		-- --RotationStart = _Vector3.new(math.pi/2,0,0),--分别代表绕,x,y,z旋转的角度
		-- RotationStop = nil,
		-- RotationTime = nil, 
	};
		---------------------敌方旗帜特效
	[10021] = {
		bBind = false;  --特效不追尾
	    delay=nil,		--特效延迟时间
		pfxName = "zc_qz_dqsj.pfx",
		--MoveStart=_Vector3.new(0, 0, 0),--特效起始偏移
		-- MoveStop =nil,--技能结束偏移
		-- MoveTime = nil,		--技能偏移时间
		-- ScalingStart = nil, --放缩
		-- ScalingStop = nil,
		-- ScalingTime = nil,		
		-- --RotationStart = _Vector3.new(math.pi/2,0,0),--分别代表绕,x,y,z旋转的角度
		-- RotationStop = nil,
		-- RotationTime = nil, 
	};
			--QTE
	[10022] = {
	    delay=nil,		--特效延迟时间
		bBind = false;  --特效不追尾
		pfxName = "v_jianxue.pfx",
		--MoveStart=_Vector3.new(0, -1, 0),--特效起始偏移
		MoveStop =nil,--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		--RotationStart = _Vector3.new(math.pi/2,0,0),--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};
	--神兵归位
	[10023] = {
	    delay=nil,		--特效延迟时间
		bBind = false;  --特效不追尾
		pfxName = "shenbingguiwei.pfx",
		--MoveStart=_Vector3.new(0, -1, 0),--特效起始偏移
		MoveStop =nil,--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		--RotationStart = _Vector3.new(math.pi/2,0,0),--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};
	--神兵消失
	[10024] = {
	    delay=nil,		--特效延迟时间
		bBind = false;  --特效不追尾
		pfxName = "shenbingguiwei_1.pfx",
		--MoveStart=_Vector3.new(0, -1, 0),--特效起始偏移
		MoveStop =nil,--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		--RotationStart = _Vector3.new(math.pi/2,0,0),--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};

	[10025] = {
	    delay=nil,		--特效延迟时间
		bBind = false;  --特效不追尾
		pfxName = "v_fenjiexian.pfx",
		--MoveStart=_Vector3.new(0, -1, 0),--特效起始偏移
		MoveStop =nil,--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		--RotationStart = _Vector3.new(math.pi/2,0,0),--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};
	[10026] = {
	    delay=nil,		--特效延迟时间
		bBind = false;  --特效不追尾
		pfxName = "v_dazuojiacheng.pfx",
		--MoveStart=_Vector3.new(0, -1, 0),--特效起始偏移
		MoveStop =nil,--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		--RotationStart = _Vector3.new(math.pi/2,0,0),--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};
	[10027] = {
	    delay=nil,		--特效延迟时间
		bBind = false;  --特效不追尾
		pfxName = "v_guangshu.pfx",
		--MoveStart=_Vector3.new(0, -1, 0),--特效起始偏移
		MoveStop =nil,--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		--RotationStart = _Vector3.new(math.pi/2,0,0),--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};
	[10028] = {
	    delay=nil,		--特效延迟时间
		bBind = false;  --特效不追尾
		pfxName = "v_lingzhen_quan.pfx",
		--MoveStart=_Vector3.new(0, -1, 0),--特效起始偏移
		MoveStop =nil,--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		--RotationStart = _Vector3.new(math.pi/2,0,0),--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};	
	[10029] = {
	    delay=nil,		--特效延迟时间
		bBind = false;  --特效不追尾
		pfxName = "v_lingzhen_hongquan.pfx",
		--MoveStart=_Vector3.new(0, -1, 0),--特效起始偏移
		MoveStop =nil,--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		--RotationStart = _Vector3.new(math.pi/2,0,0),--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};
		---------------------选中敌方玩家光效
	[10030] = {
		bBind = false;  --特效不追尾
	    delay=nil,		--特效延迟时间
		pfxName = "v_xuanzhong_hongguang.pfx",
		--MoveStart=_Vector3.new(0, 0, 0),--特效起始偏移
		-- MoveStop =nil,--技能结束偏移
		-- MoveTime = nil,		--技能偏移时间
		-- ScalingStart = nil, --放缩
		-- ScalingStop = nil,
		-- ScalingTime = nil,		
		-- --RotationStart = _Vector3.new(math.pi/2,0,0),--分别代表绕,x,y,z旋转的角度
		-- RotationStop = nil,
		-- RotationTime = nil, 
	};
	[10031] = {
		bBind = false;  --特效不追尾
	    delay=nil,		--特效延迟时间
		pfxName = "v_yanjing.pfx",
		--MoveStart=_Vector3.new(0, 0, 0),--特效起始偏移
		-- MoveStop =nil,--技能结束偏移
		-- MoveTime = nil,		--技能偏移时间
		-- ScalingStart = nil, --放缩
		-- ScalingStop = nil,
		-- ScalingTime = nil,		
		-- --RotationStart = _Vector3.new(math.pi/2,0,0),--分别代表绕,x,y,z旋转的角度
		-- RotationStop = nil,
		-- RotationTime = nil, 
	};
			---------------------选中友方玩家光效
	[10032] = {
		bBind = false;  --特效不追尾
	    delay=nil,		--特效延迟时间
		pfxName = "v_xuanzhong_lvguang.pfx",
		--MoveStart=_Vector3.new(0, 0, 0),--特效起始偏移
		-- MoveStop =nil,--技能结束偏移
		-- MoveTime = nil,		--技能偏移时间
		-- ScalingStart = nil, --放缩
		-- ScalingStop = nil,
		-- ScalingTime = nil,		
		-- --RotationStart = _Vector3.new(math.pi/2,0,0),--分别代表绕,x,y,z旋转的角度
		-- RotationStop = nil,
		-- RotationTime = nil, 
	};
		--Venus死亡复活特效
	[100000001] = {
		delay=nil,		--特效延迟时间
		bBind = false;  --特效不追尾
		pfxName = "v_fengshen_juesefuhuo.pfx",
		MoveStart=_Vector3.new(0,0,3),--特效起始偏移
		MoveStop =_Vector3.new(0,math.pi/2,0),--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		RotationStart = nil,--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};
	
	-------------------------------------------------------掉落物特效------------------------------------------------------------------
	[10041] = {
		delay=nil,		--特效延迟时间
		bBind = false;  --特效不追尾
		pfxName = "v_zhuangbei_lanse.pfx",
		MoveStart=  nil,--_Vector3.new(0,0,3),--特效起始偏移
		MoveStop =  nil,--_Vector3.new(0,math.pi/2,0),--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		RotationStart = nil,--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};	
	[10042] = {
		delay=nil,		--特效延迟时间
		bBind = false;  --特效不追尾
		pfxName = "v_zhuangbei_zise.pfx",
		MoveStart= nil, --_Vector3.new(0,0,3),--特效起始偏移
		MoveStop = nil, --_Vector3.new(0,math.pi/2,0),--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		RotationStart = nil,--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};	
	[10043] = {
		delay=nil,		--特效延迟时间
		bBind = false;  --特效不追尾
		pfxName = "v_zhuangbei_chengse.pfx",
		MoveStart= nil, --_Vector3.new(0,0,3),--特效起始偏移
		MoveStop = nil, --_Vector3.new(0,math.pi/2,0),--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		RotationStart = nil,--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};	
	[10044] = {
		delay=nil,		--特效延迟时间
		bBind = false;  --特效不追尾
		pfxName = "v_zhuangbei_hongse.pfx",
		MoveStart= nil, --_Vector3.new(0,0,3),--特效起始偏移
		MoveStop = nil, --_Vector3.new(0,math.pi/2,0),--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		RotationStart = nil,--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};	
	[10045] = {
		delay=nil,		--特效延迟时间
		bBind = false;  --特效不追尾
		pfxName = "v_zhuangbei_jinse.pfx",
		MoveStart= nil, --_Vector3.new(0,0,3),--特效起始偏移
		MoveStop = nil, --_Vector3.new(0,math.pi/2,0),--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		RotationStart = nil,--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};		
	[10046] = {
		delay=nil,		--特效延迟时间
		bBind = false;  --特效不追尾
		pfxName = "v_zhuangbei_jinse.pfx",
		MoveStart= nil, --_Vector3.new(0,0,3),--特效起始偏移
		MoveStop = nil, --_Vector3.new(0,math.pi/2,0),--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		RotationStart = nil,--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};	
	[10047] = {
		delay=nil,		--特效延迟时间
		bBind = false;  --特效不追尾
		pfxName = "v_zhuangbei_jinse.pfx",
		MoveStart= nil, --_Vector3.new(0,0,3),--特效起始偏移
		MoveStop = nil, --_Vector3.new(0,math.pi/2,0),--技能结束偏移
		MoveTime = nil,		--技能偏移时间
		ScalingStart = nil, --放缩
		ScalingStop = nil,
		ScalingTime = nil,		
		RotationStart = nil,--分别代表绕,x,y,z旋转的角度
		RotationStop = nil,
		RotationTime = nil, 
	};			
	-------------------------------------------------------掉落物特效------------------------------------------------------------------
}







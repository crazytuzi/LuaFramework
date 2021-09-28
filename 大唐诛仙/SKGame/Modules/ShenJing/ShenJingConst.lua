ShenJingConst = {}

local fun1 = function ()
	TowerController:GetInstance():RequireEnterTower()--进入大荒塔
end

local fun2 = function ()

end

local fun3 = function ()

end

local fun4 = function ()

end

local fun5 = function ()

end
ShenJingConst.HuanjingChanged = "0"

ShenJingConst.btnType = {
	[1] =	{fun = fun1,name="大荒塔",iconOpen = "ui://ny6nt56pez9zb",iconNoOpen = "ui://ny6nt56pez9zg"},
	[2] = {fun = fun2,name="幻境",iconOpen = "ui://ny6nt56pez9z9",iconNoOpen = "ui://ny6nt56pez9ze" },
	[3] = {fun = fun3,name="神境·仙域",iconOpen = "ui://ny6nt56pez9zc",iconNoOpen = "ui://ny6nt56pez9zh"},
	[4] = {fun = fun4,name="秘境",iconOpen = "ui://ny6nt56pez9z8",iconNoOpen = "ui://ny6nt56pez9zd"},
	[5] = {fun = fun5,name="古神试炼",iconOpen = "ui://ny6nt56pez9za",iconNoOpen = "ui://ny6nt56pez9zf"},
}

ShenJingConst.Open = {
	[1] = 1,
	[2] = 0,
	[3] = 0,
	[4] = 0,
	[5] = 0,
}

ShenJingConst.OpenState = {
	Open = 0,
	Close = -1
}

--神境子境开放等级
-- -1 表示不开放，其他表示对应等级开放
ShenJingConst.OpenLev = {
	[1] = 1, --大荒塔
	[2] = 1, --幻境
	[3] = 1, --神境仙域
	[4] = 1, --ShenJingConst.OpenState.Close, --秘境
	[5] = 1 --古神试炼
}


ShenJingConst.RedTipsDataKey = "ShenJingConst.RedTipsDataKey"

ShenJingConst.RedTipsState = {
	Has = "1",
	HasNo = "0",
	None = "-1"
}

ShenJingConst.ID_QIANJIEYE = 36100
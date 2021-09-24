local initdata = {}

-- login
initdata.login = {}
initdata.login.uid = ''       -- 用户id
initdata.login.name  = ''    -- 用户名称
initdata.login.email  = ''   -- 邮件
initdata.login.password = '' -- 密码
initdata.login.deviceId  ='' -- 设备id
initdata.login.invite  =''  -- 邀请人
initdata.login.regdate = ''  -- 安装日期
initdata.login.logindate = '' -- 登陆日期

-- info
initdata.userinfo = {}		                
initdata.userinfo.level = 1	-- 用户等级          
initdata.userinfo.exp = 100	-- 经验                
initdata.userinfo.energy = 20 -- 能量      
initdata.userinfo.honors = 100 -- 声望
initdata.userinfo.troops = 5 --    带兵等级         
initdata.userinfo.rank = 1	  -- 军衔        
initdata.userinfo.reputation = 1000 --  荣誉             
initdata.userinfo.vip = 7  -- vip等级
initdata.userinfo.buygems = 0-- 累计宝石 
initdata.userinfo.gems = 50 -- 宝石      
initdata.userinfo.gold = 65000	-- 金币             
initdata.userinfo.r1 = 5000  --  铁矿        
initdata.userinfo.r2 = 5000  --  石油           
initdata.userinfo.r3 = 5000  --  硅矿 	                 
initdata.userinfo.r4 = 5000  --  铀矿           
initdata.userinfo.mapx = -1 -- 地图坐标           
initdata.userinfo.mapy = -1 -- 地图坐标    
					         
-- user skill
initdata.skill = {}
initdata.skill.s101 = 0 --  精准
initdata.skill.s102 = 0 --  干扰
initdata.skill.s103 = 0 --  暴击
initdata.skill.s104 = 0 --  坚韧
initdata.skill.s105 = 0 --  火炮指挥
initdata.skill.s106 = 0 --  鱼雷指挥
initdata.skill.s107 = 0 --  导弹指挥
initdata.skill.s108 = 0 --  空袭指挥
initdata.skill.s109 = 0 --  战列舰维
initdata.skill.s110 = 0 --  潜艇维护
initdata.skill.s111 = 0 --  巡洋舰维
initdata.skill.s112 = 0 --  航母维护

-- user tech
initdata.tech = {}
initdata.tech.t01 = 0 --  加强型舰炮
initdata.tech.t02 = 0 -- 战列舰维护
initdata.tech.t03 = 0 -- 破甲鱼雷
initdata.tech.t04 = 0 -- 潜艇维护
initdata.tech.t05 = 0 -- 高爆弹头
initdata.tech.t06 = 0 -- 巡洋舰维护
initdata.tech.t07 = 0 -- 制导炸弹
initdata.tech.t08 = 0 -- 航母维护
initdata.tech.t09 = 0 -- 海岸炮攻击力
initdata.tech.t10 = 0 -- 海岸炮生命值
initdata.tech.t11 = 0 -- 导弹车攻击力
initdata.tech.t12 = 0 -- 导弹车生命值
initdata.tech.t13 = 0 -- 轰炸机攻击力
initdata.tech.t14 = 0 -- 轰炸机生命值
initdata.tech.t15 = 0 -- 铁矿冶炼
initdata.tech.t16 = 0 -- 石油分馏
initdata.tech.t17 = 0 -- 硅矿冶炼
initdata.tech.t18 = 0 -- 铀矿提纯
initdata.tech.t19 = 0 -- 铸币术
initdata.tech.t20 = 0 -- 战斗经验
initdata.tech.t21 = 0 -- 战斗掠夺
initdata.tech.t22 = 0 -- 高速航行
initdata.tech.t23 = 0 -- 建筑学
initdata.tech.t24 = 0 -- 载重
initdata.tech.t25 = 0 -- 储存技术
initdata.tech.t26 = 0 -- 预留A
initdata.tech.t27 = 0 -- 预留B

-- [queue]
initdata.queue = {}
initdata.queue.building_slot1 = 0
initdata.queue.building_slot2 = 0
initdata.queue.building_slot3 = 0
initdata.queue.building_slot4 = 0
initdata.queue.building_slot5 = 0
initdata.queue.building_slot6 = 0
initdata.queue.building_slot7 = 0
initdata.queue.ship_slot1 = 0
initdata.queue.ship_slot2 = 0
initdata.queue.shipdiy_slot1 = 0
initdata.queue.tech_slot1 = 0
initdata.queue.tech_slot2 = 0
initdata.queue.tech_slot3 = 0
initdata.queue.tech_slot4 = 0
initdata.queue.tech_slot5 = 0
initdata.queue.prop_slot1 = 0
initdata.queue.prop_slot2 = 0
initdata.queue.prop_slot3 = 0
initdata.queue.prop_slot4 = 0
initdata.queue.prop_slot5 = 0

-- [building]
initdata.building = {
	b01={t=1,l=1},
}

-- bag
initdata.bag = {
		b1={b1=2},
}

-- bookmark
initdata.bookmark = {
	{id=54, type=2, uid=1234, name='name', level=1, mapx=2, mapy=1},
	{id=54, type=2, uid=1234, name='name', level=1, mapx=2, mapy=1},
	{id=54, type=2, uid=1234, name='name', level=1, mapx=2, mapy=1},	{id=54, type=2, uid=1234, name='name', level=1, mapx=2, mapy=1},	{id=54, type=2, uid=1234, name='name', level=1, mapx=2, mapy=1},	{id=54, type=2, uid=1234, name='name', level=1, mapx=2, mapy=1},	{id=54, type=2, uid=1234, name='name', level=1, mapx=2, mapy=1},	{id=54, type=2, uid=1234, name='name', level=1, mapx=2, mapy=1},	{id=54, type=2, uid=1234, name='name', level=1, mapx=2, mapy=1},	{id=54, type=2, uid=1234, name='name', level=1, mapx=2, mapy=1},
}

-- [ships]
initdata.ships={
	b1=45,
	b2=45,	b3=45,	b4=45,
	b5=45,
	b6=45,
	b7=45,
	b8=45,
	b9=45,
	b10=45,
}

-- damagedships
initdata.damagedships={}

-- [task]
initdata.task={}

-- [dailytask]
initdata.dailytask = {}

-- strongpoint 
initdata.strongpoint={}

return initdata

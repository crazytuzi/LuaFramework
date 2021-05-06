module(..., package.seeall)
war_id=1
function testpartner()
	local lShapes = {301,302,303,308,311, 312,402}
	for i=1, 25 do
		local dPartner = {
			abnormal_attr_ratio = 400,
			attack = 228,
			critical_damage = 15000,
			critical_ratio = 800,
			cure_critical_ratio = 300,
			defense = 49,
			equip_plan_id = 1,
			grade = 1,
			mask = "ffffefe",
			max_hp = 1229,
			model_info = {
				shape = 301+i,
				skin = 203010,
			},
			name = "祁连",
			parid = i,
			partner_type = lShapes[i%(#lShapes-1) + 1],
			patahp = 1229,
			power = 1602,
			res_abnormal_ratio = 500,
			res_critical_ratio = 700,
			speed = 540,
			star = 1,
		}
		g_PartnerCtrl:AddPartner(dPartner)
	end
	CWarReplaceMenu.CountDown = function() end
end
function Test()
	
	-- FloatTest()
	-- testpartner()
	Start(2, 130, 2000)

	-- Prepare()
	-- local i = 2
	-- local function delay()
	-- 	if i > 2 then
	-- 		local function delay2()
	-- 			g_WarCtrl:End()
	-- 			Utils.AddTimer(callback(g_ResCtrl, "GC"),2 ,2)
	-- 		end
	-- 		Utils.AddTimer(delay2, 2 ,2)
	-- 		return false
	-- 	else
	-- 		i = i + 1
	-- 		g_ResCtrl:GC()
	-- 		local t = {add_type=1, war_id = war_id, camp_id=1, type=1,warrior={pflist={3201,3202}, wid = i, pid=i, pos = i, status={auto_skill=nil,name=tostring(i), status=1, mp=30, max_mp=30, hp=6000, max_hp=7000, model_info={shape=130, weapon= 2100}},}}
	-- 		netwar.GS2CWarAddWarrior(t)
	-- 		local t = {add_type=1, war_id = war_id, camp_id=2, type=1,warrior={pflist={3201,3202}, wid = 14+i, pid=14+i, pos = i, status={auto_skill=3201, name=tostring(14+i), status=1,mp=30, max_mp=30,hp=6000, max_hp=7000, model_info={shape=130, weapon= 2100}},}}
	-- 		netwar.GS2CWarAddWarrior(t)
	-- 		return true
	-- 	end


	-- end
	-- Utils.AddTimer(delay, 2, 3)
	-- netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 1, left_time=30})
	-- for i=1, 10 do
	-- 	netwar.GS2CWarBuffBout({war_id = war_id, wid=i, buff_id = 1038, bout=2, level=1})
	-- end
	-- netwar.GS2CWarDelWarrior({war_id=war_id, wid= 15})
	-- NormalAttackSub(1, 15)
	-- netwar.GS2CWarBoutEnd({war_id = war_id, bout_id = 1})
	-- netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 1, left_time=30})
	-- netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 2, left_time=15})
	-- netwar.GS2CWarBoutEnd({war_id = war_id, bout_id = 1})
	-- netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 1, left_time=30})
	-- AttackSub(1, 15)
	-- AddPartner()
	-- Prepare()
	-- netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 1, left_time=30})
	-- NormalAttackSub(1, 15)
	-- local t = {war_id = war_id, wid=1, type=1, damage=-999} 
	-- netwar.GS2CWarDamage(t)
	
	-- Speed()
	
	
	-- netwar
	-- netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 1, left_time=30})
	-- local t = {war_id = war_id, camp_id = 1, sp = 100}
	-- netwar.GS2CWarSP(t)
	local function delay()
		Speed()
		local atkid = 15
		local vicid = 1
		netwar.GS2CActionStart({war_id = war_id, wid = 2, action_id=1, left_time=30})
		netwar.GS2CWarAction({war_id=war_id, wid= atkid})
		local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=3201 ,magic_id = 1}
		netwar.GS2CWarSkill(t)
		local t = {war_id = war_id, wid=vicid, status={hp=9000, max_hp=10000}}
		netwar.GS2CWarWarriorStatus(t)
		local t = {war_id = war_id, wid=vicid, type=1, damage=-1000} 
		netwar.GS2CWarDamage(t)
		local t = {war_id = war_id, camp_id = 1, attack=1, sp = 50}
		netwar.GS2CWarSP(t)
		local t = {war_id = war_id, action_wid=15}
		netwar.GS2CActionEnd({war_id = war_id, wid = 1, action_id=1})
		netwar.GS2CActionStart({war_id = war_id, wid = 2, action_id= 2, left_time=30})
	-- 	local t = {war_id = war_id, wid=vicid, status={hp=8000, max_hp=10000}}
	-- 	netwar.GS2CWarWarriorStatus(t)
	-- 	local t = {war_id = war_id, wid=vicid, type=1, damage=-1000} 
	-- 	netwar.GS2CWarDamage(t)
	-- 	local t = {war_id = war_id, camp_id = 1, attack=1, sp = 25}
	-- 	netwar.GS2CWarSP(t)
	-- 	local t = {war_id = war_id, action_wid=15}
	-- 	netwar.GS2CWarGoback(t)
	-- 	netwar.GS2CWarBoutEnd({war_id = war_id, bout_id = 1})
	-- 	-- netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 2, left_time=30})
	-- end
	-- Utils.AddTimer(delay, 2, 2)
	-- local t = {war_id = war_id, wid=vicid, status={hp=8000}}
	-- netwar.GS2CWarWarriorStatus(t)
	-- local t = {war_id = war_id, wid=vicid, type=1, damage=-1000} 
	-- netwar.GS2CWarDamage(t)
	-- netwar.GS2CWarResult({war_id = war_id, win_side = 1})
	
	-- g_WarCtrl:ShowSceneEndWar()
	-- netwar.GS2CWarEndUI({war_id = war_id, player_exp={grade=0, exp=100}, partner_exp={
	-- 		{parid=9001, exp = 199},
	-- 	}, player_item={
	-- 		{sid = 100001, amount = 10}, 
	-- 	}})
	-- local atkid = 15
	-- local vicid = 1
	-- local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=1 ,magic_id = 1}
	-- netwar.GS2CWarSkill(t)
	-- local t = {war_id = war_id, wid=vicid, type=1, damage=-9} 
	-- netwar.GS2CWarDamage(t)

	-- local atkid = 15
	-- local vicid = 1
	-- local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=1 ,magic_id = 1}
	-- netwar.GS2CWarSkill(t)
	-- local t = {war_id = war_id, wid=vicid, type=1, damage=-9} 
	-- netwar.GS2CWarDamage(t)
	
	-- local t = {war_id = war_id, action_wlist={1}, select_wlist={1,2},skill_id=40102 ,magic_id = 1}
	-- netwar.GS2CWarSkill(t)
	-- netwar.GS2CWarBuffBout({war_id = war_id, wid=1, buff_id = 1001, bout=2, level=1})
	-- netwar.GS2CWarBuffBout({war_id = war_id, wid=2, buff_id = 1001, bout=2, level=1})
	-- netwar.GS2CWarBoutEnd({war_id = war_id})
	-- netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 1, left_time=30})
	-- netwar.GS2CWarGoback({war_id = war_id, action_wid=1})
	-- local function delay()

	-- 	local atkid = 1
	-- 	local vicid = 15
	-- 	local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=30201 ,magic_id = 1}
	-- 	netwar.GS2CWarSkill(t)
	-- 	local t = {war_id = war_id, wid=vicid, type=1, damage=-999} 
	-- 	netwar.GS2CWarDamage(t)
	-- 	netwar.GS2CWarDelWarrior({war_id=war_id, wid = vicid, del_type=2})
	-- 	-- local atkid = 1
	-- 	-- local vicid = 15
	-- 	-- local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid}, skill_id=30201 ,magic_id = 1}
	-- 	-- netwar.GS2CWarSkill(t)
	-- 	-- local t = {war_id = war_id, wid=atkid, type=1, damage=-1999} 
	-- 	-- netwar.GS2CWarDamage(t)
	-- 	-- -- netwar.GS2CWarBuffBout({war_id = war_id, wid=vicid, buff_id = 104, bout=2, level=1})
	-- 	-- -- local t = {war_id = war_id, wid=16, type=1, damage=-1999} 
	-- 	-- -- netwar.GS2CWarDamage(t)
	-- 	-- -- netwar.GS2CWarBuffBout({war_id = war_id, wid=16, buff_id = 104, bout=2, level=1})
	-- 	-- -- local t = {war_id = war_id, wid=vicid, type=1, damage=-1988} 
	-- 	-- -- netwar.GS2CWarDamage(t)
	-- 	-- -- local t = {war_id = war_id, wid=vicid, type=1, damage=-1997} 
	-- 	-- -- netwar.GS2CWarDamage(t)
	-- 	-- local t = {war_id = war_id, wid=atkid, status={status=2}}
	-- 	-- netwar.GS2CWarWarriorStatus(t)
	-- 	-- netwar.GS2CWarGoback({war_id = war_id, action_wid=atkid})

	-- 	-- local atkid = 15
	-- 	-- local vicid = 1
	-- 	-- local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=50701, magic_id = 1}
	-- 	-- netwar.GS2CWarSkill(t)
	-- 	-- local t = {war_id = war_id, wid=vicid, type=1, damage=-1986}
	-- 	-- netwar.GS2CWarDamage(t)
	-- 	-- local t = {war_id = war_id, wid=vicid, type=1, damage=-1986}
	-- 	-- netwar.GS2CWarDamage(t)
	-- 	-- -- local t = {war_id = war_id, wid=vicid, type=1, damage=-1986}
	-- 	-- -- netwar.GS2CWarDamage(t)
	-- 	-- netwar.GS2CWarGoback({war_id = war_id, action_wid=atkid})


	-- 	-- local atkid = 17
	-- 	-- local vicid = 1
	-- 	-- local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=50701, magic_id = 1}
	-- 	-- netwar.GS2CWarSkill(t)
	-- 	-- local t = {war_id = war_id, wid=vicid, type=1, damage=-1986}
	-- 	-- netwar.GS2CWarDamage(t)
	-- 	-- local t = {war_id = war_id, wid=vicid, type=1, damage=-1986}
	-- 	-- netwar.GS2CWarDamage(t)
	-- 	-- -- local t = {war_id = war_id, wid=vicid, type=1, damage=-1986}
	-- 	-- -- netwar.GS2CWarDamage(t)
	-- 	-- netwar.GS2CWarGoback({war_id = war_id, action_wid=atkid})


	-- 	-- local atkid = 18
	-- 	-- local vicid = 1
	-- 	-- local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=50701, magic_id = 1}
	-- 	-- netwar.GS2CWarSkill(t)
	-- 	-- local t = {war_id = war_id, wid=vicid, type=1, damage=-1986}
	-- 	-- netwar.GS2CWarDamage(t)
	-- 	-- local t = {war_id = war_id, wid=vicid, type=1, damage=-1986}
	-- 	-- netwar.GS2CWarDamage(t)
	-- 	-- -- local t = {war_id = war_id, wid=vicid, type=1, damage=-1986}
	-- 	-- -- netwar.GS2CWarDamage(t)
	-- 	-- netwar.GS2CWarGoback({war_id = war_id, action_wid=atkid})

	-- 	-- local atkid = 1
	-- 	-- local vicid = 15
	-- 	-- local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=3301 ,magic_id = 1}
	-- 	-- netwar.GS2CWarSkill(t)
	-- 	-- local t = {war_id = war_id, wid=vicid, type=1, damage=-1999} 
	-- 	-- netwar.GS2CWarDamage(t)
	-- 	-- local t = {war_id = war_id, wid=vicid, type=1, damage=-1988} 
	-- 	-- netwar.GS2CWarDamage(t)
	-- 	-- netwar.GS2CWarGoback({war_id = war_id, action_wid=atkid})
		
		
	-- 	-- local atkid = 2
	-- 	-- local vicid = 15
	-- 	-- local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=1 ,magic_id = 1}
	-- 	-- netwar.GS2CWarSkill(t)
	-- 	-- local t = {war_id = war_id, wid=vicid, type=1, damage=-999} 
	-- 	-- netwar.GS2CWarDamage(t)

	-- 	-- local atkid = 2
	-- 	-- local vicid = 15
	-- 	-- local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=1 ,magic_id = 1}
	-- 	-- netwar.GS2CWarSkill(t)
	-- 	-- local t = {war_id = war_id, wid=vicid, type=1, damage=-999} 
	-- 	-- netwar.GS2CWarDamage(t)

	-- 	-- local atkid = 2
	-- 	-- local vicid = 15
	-- 	-- local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=1 ,magic_id = 1}
	-- 	-- netwar.GS2CWarSkill(t)
	-- 	-- local t = {war_id = war_id, wid=vicid, type=1, damage=-999} 
	-- 	-- netwar.GS2CWarDamage(t)

		
	-- 	-- local atkid = 15
	-- 	-- local vicid = 2
	-- 	-- local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=1 ,magic_id = 1}
	-- 	-- netwar.GS2CWarSkill(t)
	-- 	-- local t = {war_id = war_id, wid=vicid, type=1, damage=-111} 
	-- 	-- netwar.GS2CWarDamage(t)

	-- 	-- netwar.GS2CWarGoback({war_id = war_id, action_wid=2})

	-- 	-- local atkid = 3
	-- 	-- local vicid = 16
	-- 	-- local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=50701 ,magic_id = 1}
	-- 	-- netwar.GS2CWarSkill(t)
	-- 	-- local t = {war_id = war_id, wid=vicid, type=1, damage=-9}
	-- 	-- netwar.GS2CWarDamage(t)
	-- 	-- -- netwar.GS2CWarFloat({war_id=war_id,float_info={victim_id=vicid, attack_id=atkid}})
	-- 	-- netwar.GS2CWarGoback({war_id = war_id, action_wid=atkid})
		
	-- 	-- local atkid = 4
	-- 	-- local vicid = 15
	-- 	-- local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=50701 ,magic_id = 1}
	-- 	-- netwar.GS2CWarSkill(t)
	-- 	-- local t = {war_id = war_id, wid=vicid, type=1, damage=-9} 
	-- 	-- netwar.GS2CWarDamage(t)
	-- 	-- netwar.GS2CWarGoback({war_id = war_id, action_wid=atkid})
	-- 	-- netwar.GS2CWarFloat({war_id=war_id,float_info={{victim_id=1, 
	-- 	-- 	attack_list={
	-- 	-- 	{attack_id=15, attack_cnt=2}, 
	-- 	-- 	{attack_id=16, attack_cnt=2}, 
	-- 	-- 	{attack_id=17, attack_cnt=2},
	-- 	-- 	{attack_id=18, attack_cnt=2},  
	-- 	-- 	}}}})

		
	-- 	-- netwar.GS2CWarBoutEnd({war_id = war_id})
	-- 	netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 1, left_time=30})
	end
	Utils.AddTimer(delay, 1, 1)
end

function Speed()
	local t = {
		{wid = 1, speed = 99},
		{wid = 2, speed =1000},
		{wid = 15, speed = 999},
	}
	for i=1, 10 do
		table.insert(t, {wid=16, speed=89999})
	end
	netwar.GS2CWarSpeed({war_id=war_id, speed_list=t})
end

function FloatTest(sk1, sk2)
	CWarBuff.ctor = function() end
	local function delay()
		local atkid = 1
		local vicid = 15
		netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 1, left_time=30})
		local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=sk1 ,magic_id = 1}
		netwar.GS2CWarSkill(t)
		local t = {war_id = war_id, wid=vicid, type=1, damage=-1999} 
		netwar.GS2CWarDamage(t)
		netwar.GS2CWarGoback({war_id = war_id, action_wid=atkid})

		local atkid = 2
		local vicid = 15
		local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=sk2 ,magic_id = 1}
		netwar.GS2CWarSkill(t)
		local t = {war_id = war_id, wid=vicid, type=1, damage=-999} 
		netwar.GS2CWarDamage(t)
		netwar.GS2CWarGoback({war_id = war_id, action_wid=atkid})

		local atkid = 3
		local vicid = 15
		local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=sk2 ,magic_id = 1}
		netwar.GS2CWarSkill(t)
		local t = {war_id = war_id, wid=vicid, type=1, damage=-9}
		netwar.GS2CWarDamage(t)
		-- netwar.GS2CWarFloat({war_id=war_id,float_info={victim_id=vicid, attack_id=atkid}})
		netwar.GS2CWarGoback({war_id = war_id, action_wid=atkid})
		
		-- local atkid = 4
		-- local vicid = 15
		-- local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid},skill_id=50701 ,magic_id = 1}
		-- netwar.GS2CWarSkill(t)
		-- local t = {war_id = war_id, wid=vicid, type=1, damage=-9} 
		-- netwar.GS2CWarDamage(t)
		-- netwar.GS2CWarGoback({war_id = war_id, action_wid=atkid})
		
		-- netwar.GS2CWarGoback({war_id = war_id, action_wid=atkid})
		netwar.GS2CWarBoutEnd({war_id = war_id})
	end
	-- Utils.AddTimer(delay, 0, 0)
	delay()
end

function Prepare()
	netwar.GS2CWarConfig({war_id = war_id, secs = 15})
end

function Start(cnt, palyershape, weapon, wartype)
	wartype = wartype or 1
	g_AttrCtrl:UpdateAttr({pid =1})
	netwar.GS2CShowWar({war_id = war_id, war_type=wartype})
	netwar.GS2CEnterWar()
	cnt = tonumber(cnt) or 1
	for i=1, cnt do
		local t = {war_id = war_id, camp_id=1, type=1,warrior={pflist = {3201,3202}, wid = i, pid=i, pos = i, status={auto_skill=nil,name=tostring(i), status=1, mp=30, max_mp=30, hp=6000, max_hp=7000, model_info={shape=palyershape, weapon= weapon}},}}
		netwar.GS2CWarAddWarrior(t)
		if wartype == define.War.Type.GuideBoss then
			if i == 1 then
				local t = {war_id = war_id, camp_id=2, type=1,warrior={pflist = {3201,3202}, wid = 14+i, pid=14+i, pos = i, status={auto_skill=nil, name=tostring(14+i), status=1,mp=30, max_mp=30,hp=6000, max_hp=7000, model_info={shape=1512, weapon= weapon}},}}
				netwar.GS2CWarAddWarrior(t)
			end
		else
			local t = {war_id = war_id, camp_id=2, type=1,warrior={pflist = {3201,3202}, wid = 14+i, pid=14+i, pos = i, status={auto_skill=nil, name=tostring(14+i), status=1,mp=30, max_mp=30,hp=6000, max_hp=7000, model_info={shape=palyershape, weapon= weapon}},}}
			netwar.GS2CWarAddWarrior(t)
		end
	end
	netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 1, left_time=30})
	netwar.GS2CActionStart({war_id = war_id, wid = 2, action_id=1, left_time=30})
end

function AddPartner()
	-- local t = {war_id = war_id, camp_id=1, type=4,partnerwarrior={ pflist = {3001}, wid = 2, name="test", parid=9000, pos = 5, owner=1, status={auto_skill=50701,status=1, mp=30, max_mp=30, hp=6000, max_hp=7000, model_info={shape=301}}, }}
	-- netwar.GS2CWarAddWarrior(t)
	local t = {war_id = war_id, camp_id=1, type=4,partnerwarrior={ pflist = {3202, 40402}, wid = 4, name="test", parid=9001, pos = 2, owner=1, status={auto_skill=50702, status=1, mp=30, max_mp=30, hp=6000, max_hp=7000, model_info={shape=401}}, }}
	netwar.GS2CWarAddWarrior(t)
	local t = {war_id = war_id, camp_id=1, type=4,partnerwarrior={ pflist = {3201, 3202}, wid = 5, name="test", parid=9002, pos = 5, owner=1, status={auto_skill=50701, status=1, mp=30, max_mp=30, hp=6000, max_hp=7000, model_info={shape=401}}, }}
	netwar.GS2CWarAddWarrior(t)
end

function NormalAttack(atkid, vicid)
	netwar.GS2CWarAction({war_id=war_id, wid= atkid})
	local t = {war_id = war_id, action_wid=atkid, select_wid=vicid}
	netwar.GS2CWarNormalAttack(t)
	local t = {war_id = war_id, wid=vicid, type=0, damage=-1000 } 
	netwar.GS2CWarDamage(t)
	local t = {war_id = war_id, wid=vicid, type = 1, status={hp=5000, mp = 30}}
	netwar.GS2CWarWarriorStatus(t)

	local t = {war_id = war_id, action_wid=vicid, select_wid=atkid}
	netwar.GS2CWarNormalAttack(t)
	local t = {war_id = war_id, wid=atkid, type=0, damage=-1000 } 
	netwar.GS2CWarDamage(t)
	local t = {war_id = war_id, wid=atkid, type = 1, status={hp=1000,mp = 20}}
	netwar.GS2CWarWarriorStatus(t)
	netwar.GS2CWarGoback({war_id = war_id, action_wid=vicid})
	netwar.GS2CWarGoback({war_id = war_id, action_wid=atkid})
	netwar.GS2CWarBoutEnd({war_id = war_id, bout_id = 1})
	netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 1, left_time=30})
end

function AttackSub(atkid, vicid)
	local t = {war_id = war_id, action_wlist={atkid}, select_wlist={vicid}, skill_id=1,magic_id = 1}
	netwar.GS2CWarSkill(t)
	local t = {war_id = war_id, wid=vicid, type=1, status={hp=0}}
	netwar.GS2CWarWarriorStatus(t)
	local t = {war_id = war_id, wid=vicid, type=1, status={status=2}}
	netwar.GS2CWarWarriorStatus(t)
	local t = {war_id = war_id, wid=vicid, type=1, damage=-999} 
	netwar.GS2CWarDamage(t)

	-- netwar.GS2CWarSP({war_id=war_id, camp_id=1, sp =50})
	-- netwar.GS2CWarGoback({war_id = war_id, action_wid=atkid})
	-- netwar.GS2CWarBoutEnd({war_id = war_id, bout_id = 1})
	netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 1, left_time=30})
end

function Magic(magic_id, magic_index, atk_list, vic_List, sSubType, vic_array)
	local lvic = {}
	if sSubType == "one" then
		for i, id in ipairs(vic_List) do
			local magic_index = magic_index
			local atk = atk_list
			local t = {war_id = war_id, action_wlist=atk, select_wlist={id},skill_id=magic_id ,magic_id = magic_index}
			netwar.GS2CWarSkill(t)
			local t = {war_id = war_id, wid=id, type=0, damage=-2000-i} 
			netwar.GS2CWarDamage(t)
			local t = {war_id = war_id, wid=id, status={hp=8000, max_hp=10000}}
			netwar.GS2CWarWarriorStatus(t)
		end
	elseif sSubType == "all" then
		local t = {war_id = war_id, action_wlist=atk_list, select_wlist=vic_List, skill_id=magic_id,magic_id = magic_index}
		netwar.GS2CWarSkill(t)
		for i, id in ipairs(vic_List) do
			local t = {war_id = war_id, wid=id, type=0, damage=-9999} 
			netwar.GS2CWarDamage(t)
			local t = {war_id = war_id, wid=id, status={hp=8000, max_hp=10000}}
			netwar.GS2CWarWarriorStatus(t)
		end
	elseif sSubType == "chain" then
		local pre_vic = nil
		for i, id in ipairs(vic_List) do
			local magic_index = (i ~= 1) and 2 or 1
			local atk
			if pre_vic then
				atk = {pre_vic}
			else
				atk = atk_list
			end
			local t = {war_id = war_id, action_wlist=atk, select_wlist={id},skill_id=magic_id ,magic_id = magic_index}
			netwar.GS2CWarSkill(t)
			local t = {war_id = war_id, wid=id, type=0, damage=-2000-i} 
			netwar.GS2CWarDamage(t)
			local t = {war_id = war_id, wid=id, status={hp=8000, max_hp=10000}}
			netwar.GS2CWarWarriorStatus(t)
			pre_vic = id
		end
	elseif sSubType == "sequence" then
		local i = 0
		while i <= #vic_List do
			local tmp = {}
			for k=1,vic_array do
				if vic_List[i+k] then
					table.insert(tmp, vic_List[i+k])
				end
			end
			if #tmp > 0 then
				table.insert(lvic, tmp)
			end
			i = i+vic_array
		end
		for i, ids in ipairs(lvic) do
			local magic_index = (i ~= 1) and 2 or 1
			local t = {war_id = war_id, action_wlist=atk_list, select_wlist=ids,skill_id=magic_id ,magic_id = magic_index}
			netwar.GS2CWarSkill(t)
			for k,id in ipairs(ids) do
				local t = {war_id = war_id, wid=id, type=0, damage=-2000-i} 
				netwar.GS2CWarDamage(t)
				local t = {war_id = war_id, wid=id, status={hp=8000, max_hp=10000}}
				netwar.GS2CWarWarriorStatus(t)
			end
		end

	end
	netwar.GS2CWarGoback({war_id = war_id, action_wid = atk_list[1]})
	-- local t = {war_id = war_id, action_wlist=lvic[#lvic], select_wlist=atk_list,skill_id=51301 ,magic_id = 1}
	-- netwar.GS2CWarSkill(t)
	-- for k,id in ipairs(atk_list) do
	-- 	local t = {war_id = war_id, wid=id, type=0, damage=-2000} 
	-- 	netwar.GS2CWarDamage(t)
	-- 	local t = {war_id = war_id, wid=id, status={hp=8000, max_hp=10000}}
	-- 	netwar.GS2CWarWarriorStatus(t)
	-- end
	-- netwar.GS2CWarGoback({war_id = war_id, action_wid = lvic[#lvic][1]})
	netwar.GS2CActionEnd({war_id = war_id, wid = 1, action_id=1})
	netwar.GS2CWarBoutEnd({war_id = war_id, bout_id = 0})
	netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 1})
end

function Escape(action_wid)
	netwar.GS2CWarEscape({war_id = war_id, action_wid=action_wid})
	netwar.GS2CWarBoutEnd({war_id = war_id, bout_id = 1})
	netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 1})
end

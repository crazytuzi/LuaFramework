function main(skillIndex)
	skillName = {
		"火球术",
		"治愈术",
		"基本剑术",
		"精神力战法",
		"大火球",
		"施毒术",
		"攻杀剑术",
		"抗拒火环",
		"地狱火",
		"疾光电影",
		"雷电术",
		"刺杀剑术",
		"灵魂火符",
		"幽灵盾",
		"神圣战甲术",
		"困魔咒",
		"召唤骷髅",
		"隐身术",
		"集体隐身术",
		"诱惑之光",
		"瞬息移动",
		"火墙",
		"爆裂火焰",
		"地狱雷光",
		"半月弯刀",
		"烈火剑法",
		"野蛮冲撞",
		"心灵启示",
		"群体治疗术",
		"召唤神兽",
		"魔法盾",
		"圣言术",
		"冰咆哮",
		nil,
		"灭天火",
		"无极真气",
		"气功波",
		nil,
		"寒冰掌",
		nil,
		nil,
		nil,
		"狮子吼",
		nil,
		nil,
		nil,
		nil,
		"噬血术",
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		"逐日剑法",
		"流星火雨"
	}

	if not SHOW_GUIDE then
		return 
	end

	if skillIndex == 3 then
		if PlayerSex == 0 then
			actor = createRole("小哥", "hero", 5, 55, 0, 0, nil, off2p(-2, 1), 7)
		else
			actor = createRole("小妹", "hero", 6, 55, 1, 1, nil, off2p(-2, 1), 7)
		end

		鸡 = createRole("鸡", 11, 160, 0, 0, 0, nil, off2p(-1, 1), 7)

		actor:say("快学基本剑术吧，这个被动技能得等级提升可以增加你的准确属性。", nil)
		delay(0.5)

		for i = 1, 3, 1 do
			actor:magic(3, 鸡, nil, DIR.right)
			delay(2)
		end
	elseif skillIndex == 7 then
		if PlayerSex == 0 then
			actor = createRole("小战士", "hero", 10, 57, 0, 0, nil, off2p(-2, 1), 7)
		else
			actor = createRole("小战士", "hero", 11, 57, 1, 1, nil, off2p(-2, 1), 7)
		end

		骷髅战士 = createRole("骷髅战士", 14, 22, 0, 0, 0, nil, off2p(-1, 1), 7)

		actor:say("攻杀剑术可以提高攻击的伤害，等级提升还能增加准确。", nil)
		delay(0.5)

		for i = 1, 3, 1 do
			actor:magic(7, 骷髅战士, nil, DIR.right)
			delay(1)

			骷髅战士.dir = DIR.left

			骷髅战士:playAct(ACTS.STRUCK)
			delay(1)
		end
	elseif skillIndex == 12 then
		if PlayerSex == 0 then
			actor = createRole("战士", "hero", 25, 35, 0, 0, nil, off2p(-2, 1), 8.3)
		else
			actor = createRole("战士", "hero", 22, 35, 1, 1, nil, off2p(-2, 1), 8.3)
		end

		红野猪 = createRole("红野猪", 19, 110, 0, 0, 0, nil, off2p(-1, 1), 4)
		红野猪.dir = DIR.left
		红野猪1 = createRole("红野猪", 19, 110, 0, 0, 0, nil, off2p(0, 1), 4)
		红野猪1.dir = DIR.left

		actor:say("25级可以学习刺杀剑术，它能对隔位的敌人造成伤害，不过你得学会如何走位。", nil)
		delay(0.5)

		for i = 1, 6, 1 do
			if i < 4 then
				actor:magic(12, 红野猪, nil, DIR.right)
				delay(0.7)
				红野猪:playAct(ACTS.STRUCK)
				红野猪1:playAct(ACTS.STRUCK)
			elseif i == 4 then
				actor:say("今后你还会发现，使用隔位刺杀来对付魔法盾和一些特别的怪物会有奇效。", nil)

				actor1 = createRole("男法师", "hero", 243, 56, 0, 0, nil, pos(actor.x + 2, actor.y), 4)

				actor1:addState("stMagicShield")
				actor:magic(12, actor1, nil, DIR.right)
				delay(0.7)
				actor1:playAct(ACTS.STRUCK)
			else
				actor:magic(12, actor1, nil, DIR.right)
				delay(0.7)
				actor1:playAct(ACTS.STRUCK)
			end

			delay(0.5)
		end
	elseif skillIndex == 25 then
		if PlayerSex == 0 then
			actor = createRole("战士", "hero", 246, 36, 0, 0, nil, off2p(-2, 1), 7)
		else
			actor = createRole("战士", "hero", 247, 36, 1, 1, nil, off2p(-2, 1), 7)
		end

		黑野猪 = createRole("黑野猪", 19, 111, 0, 0, 0, nil, off2p(-1, 0), 7)
		黑野猪1 = createRole("黑野猪", 19, 111, 0, 0, 0, nil, off2p(-1, 1), 7)
		黑野猪2 = createRole("黑野猪", 19, 111, 0, 0, 0, nil, off2p(-1, 2), 7)
		黑野猪3 = createRole("黑野猪", 19, 111, 0, 0, 0, nil, off2p(-2, 2), 7)
		黑野猪4 = createRole("黑野猪", 19, 111, 0, 0, 0, nil, off2p(-3, 2), 7)
		黑野猪.dir = DIR.left
		黑野猪1.dir = DIR.left
		黑野猪2.dir = DIR.leftUp
		黑野猪3.dir = DIR.up
		黑野猪4.dir = DIR.up

		actor:say("28级就可以学习半月弯刀，它可以同时攻击环绕在你周围的所有敌人。", nil)
		delay(0.5)

		for i = 1, 3, 1 do
			actor:magic(25, 黑野猪, nil, DIR.right)
			delay(0.7)
			黑野猪:playAct(ACTS.STRUCK)
			黑野猪1:playAct(ACTS.STRUCK)
			黑野猪2:playAct(ACTS.STRUCK)
			黑野猪3:playAct(ACTS.STRUCK)
			黑野猪4:playAct(ACTS.STRUCK)
			delay(1)
		end
	elseif skillIndex == 27 then
		if PlayerSex == 0 then
			actor = createRole("战士", "hero", 246, 32, 0, 0, nil, off2p(-2, 1), 8)
		else
			actor = createRole("战士", "hero", 247, 32, 1, 1, nil, off2p(-2, 1), 8)
		end

		actor:say("30级可以练习野蛮冲撞，撞开级别低于你的敌人。你可要小心别撞到障碍物上。", nil)

		actor.dir = DIR.right
		稻草人 = createRole("稻草人", 17, 27, 19, 1, 0, nil, pos(actor.x + 1, actor.y), 8)
		稻草人.dir = DIR.left

		delay(1.5)
		actor:magic(skillIndex, nil, pos(3, 0), DIR.right)
		稻草人:playAct(ACTS.ACT_BACKSTEP, pos(3, 0), DIR.left)
		稻草人:playAct(ACTS.STRUCK)
		delay(1.5)
		actor:say("如果你把这个技能练到3级，你会发现更多惊喜，当然前提是你要把等级提升到38级。", nil)

		稻草人1 = createRole("稻草人", 17, 27, 19, 1, 0, nil, pos(actor.x + 2, actor.y), 4.8)
		稻草人1.dir = DIR.right
		稻草人.dir = DIR.right
		actor.dir = DIR.bottom

		actor:playAct(ACT_WALK, pos(0, 1), DIR.bottom)
		delay(0.5)

		actor.dir = DIR.right

		actor:playAct(ACT_WALK, pos(3, 0), DIR.right)
		delay(0.5)

		actor.dir = DIR.up

		actor:playAct(ACT_WALK, pos(0, -1), DIR.up)
		delay(0.5)

		actor.dir = DIR.left

		delay(2)
		actor:magic(skillIndex, nil, pos(-3, 0), DIR.left)
		稻草人:playAct(ACTS.ACT_BACKSTEP, pos(-3, 0), DIR.right)
		稻草人:playAct(ACTS.STRUCK)
		稻草人1:playAct(ACTS.ACT_BACKSTEP, pos(-3, 0), DIR.right)
		稻草人1:playAct(ACTS.STRUCK)
	elseif skillIndex == 26 then
		if PlayerSex == 0 then
			actor = createRole("威武圣战", "hero", 328, 325, 0, 0, nil, off2p(-2, 1), 7)
		else
			actor = createRole("威武圣战", "hero", 331, 325, 1, 1, nil, off2p(-2, 1), 7)
		end

		白野猪 = createRole("白野猪", 19, 112, 0, 0, 0, nil, off2p(-1, 1), 7)

		actor:say("达到35级你已经可以学习烈火剑法了。这是战士重要的伤害技能，有7秒的冷却时间。", nil)
		delay(0.5)

		for i = 1, 3, 1 do
			actor:magic(26, 白野猪, nil, DIR.right)

			白野猪.dir = DIR.left

			delay(1)
			白野猪:playAct(ACTS.STRUCK)
			delay(1)
		end
	elseif skillIndex == 43 then
		if PlayerSex == 0 then
			actor = createRole("威武圣战", "hero", 352, 208, 0, 0, nil, off2p(-3, 2), 7)
		else
			actor = createRole("威武圣战", "hero", 353, 208, 1, 1, nil, off2p(-3, 2), 7)
		end

		红野猪 = createRole("红野猪", 19, 110, 0, 0, 0, nil, pos(actor.x + 1, actor.y), 3)
		红野猪1 = createRole("红野猪", 19, 110, 0, 0, 0, nil, pos(actor.x - 1, actor.y), 3)
		红野猪2 = createRole("红野猪", 19, 110, 0, 0, 0, nil, pos(actor.x, actor.y + 1), 3)
		红野猪3 = createRole("红野猪", 19, 110, 0, 0, 0, nil, pos(actor.x, actor.y - 1), 3)
		红野猪.dir = DIR.left
		红野猪1.dir = DIR.right
		红野猪2.dir = DIR.up

		actor:say("你可以学习狮子吼了，使用它能让怪物暂时麻痹。", nil)
		delay(1)
		actor:magic(43, 红野猪, nil, DIR.left)
		delay(1)
		红野猪:addState("stPoisonStone")
		红野猪1:addState("stPoisonStone")
		红野猪2:addState("stPoisonStone")
		红野猪3:addState("stPoisonStone")
		delay(1)

		沃玛战将 = createRole("沃玛战将", 19, 33, 0, 0, 0, nil, pos(actor.x + 2, actor.y + 2), 4)
		沃玛战将1 = createRole("沃玛战将", 19, 33, 0, 0, 0, nil, pos(actor.x + 2, actor.y), 4)
		沃玛战将2 = createRole("沃玛战将", 19, 33, 0, 0, 0, nil, pos(actor.x + 2, actor.y - 2), 4)
		沃玛战将3 = createRole("沃玛战将", 19, 33, 0, 0, 0, nil, pos(actor.x, actor.y + 2), 4)
		沃玛战将4 = createRole("沃玛战将", 19, 33, 0, 0, 0, nil, pos(actor.x, actor.y - 2), 4)
		沃玛战将5 = createRole("沃玛战将", 19, 33, 0, 0, 0, nil, pos(actor.x - 2, actor.y + 2), 4)
		沃玛战将6 = createRole("沃玛战将", 19, 33, 0, 0, 0, nil, pos(actor.x - 2, actor.y), 4)
		沃玛战将7 = createRole("沃玛战将", 19, 33, 0, 0, 0, nil, pos(actor.x - 2, actor.y - 2), 4)
		沃玛战将.dir = DIR.leftUp
		沃玛战将1.dir = DIR.left
		沃玛战将2.dir = DIR.leftBottom
		沃玛战将3.dir = DIR.up
		沃玛战将5.dir = DIR.rightUp
		沃玛战将6.dir = DIR.right
		沃玛战将7.dir = DIR.rightBottom

		actor:say("随着你等级的提升，你能够麻痹更多更强的怪物。", nil)
		delay(1)
		actor:magic(43, 沃玛战将, nil, DIR.left)
		delay(1)
		沃玛战将:addState("stPoisonStone")
		沃玛战将1:addState("stPoisonStone")
		沃玛战将2:addState("stPoisonStone")
		沃玛战将3:addState("stPoisonStone")
		沃玛战将4:addState("stPoisonStone")
		沃玛战将5:addState("stPoisonStone")
		沃玛战将6:addState("stPoisonStone")
		沃玛战将7:addState("stPoisonStone")
	elseif skillIndex == 58 then
		if PlayerSex == 0 then
			actor = createRole("威武圣战", "hero", 350, 347, 0, 0, nil, off2p(-2, 1), 7)
		else
			actor = createRole("威武圣战", "hero", 351, 347, 1, 1, nil, off2p(-2, 1), 7)
		end

		牛魔将军 = createRole("牛魔将军", 19, 204, 0, 0, 0, nil, pos(actor.x + 1, actor.y), 7)
		牛魔将军1 = createRole("牛魔将军", 19, 204, 0, 0, 0, nil, pos(actor.x + 2, actor.y), 7)
		牛魔将军2 = createRole("牛魔将军", 19, 204, 0, 0, 0, nil, pos(actor.x + 3, actor.y), 7)
		牛魔将军3 = createRole("牛魔将军", 19, 204, 0, 0, 0, nil, pos(actor.x + 4, actor.y), 7)
		牛魔将军.dir = DIR.left
		牛魔将军1.dir = DIR.left
		牛魔将军2.dir = DIR.left
		牛魔将军3.dir = DIR.left

		actor:say("47级可以学习战士高级技能逐日剑法，它能攻击直线上4格的敌人，有10秒的冷却时间。", nil)
		delay(0.5)

		for i = 1, 3, 1 do
			actor:magic(58, 牛魔将军, nil, DIR.right)
			delay(0.5)
			牛魔将军:playAct(ACTS.STRUCK)
			牛魔将军1:playAct(ACTS.STRUCK)
			牛魔将军2:playAct(ACTS.STRUCK)
			牛魔将军3:playAct(ACTS.STRUCK)
			delay(1.5)
		end
	elseif skillIndex == 1 then
		if PlayerSex == 0 then
			actor = createRole("小哥", "hero", 5, 55, 0, 0, nil, off2p(-2, 1), 7)
		else
			actor = createRole("小妹", "hero", 6, 55, 1, 1, nil, off2p(-2, 1), 7)
		end

		鸡 = createRole("鸡", 11, 160, 0, 0, 0, nil, off2p(2, 1), 7)

		actor:say("火球术是法师的基础法术，能对远处的敌人造成单体伤害。", nil)
		delay(0.5)

		for i = 1, 3, 1 do
			actor:magic(1, 鸡, nil, DIR.left)
			delay(1)
			鸡:playAct(ACTS.STRUCK)
			delay(1)
		end
	elseif skillIndex == 8 then
		if PlayerSex == 0 then
			actor = createRole("小哥", "hero", 5, 55, 0, 0, nil, off2p(-2, 1), 7)
		else
			actor = createRole("小妹", "hero", 6, 55, 1, 1, nil, off2p(-2, 1), 7)
		end

		actor:say("12级可以学习抗拒火环，可以推开四周的敌人，前提是他们级别比你低。", nil)
		delay(0.5)

		for i = 1, 2, 1 do
			钉耙猫 = createRole("钉耙猫", 17, 26, 0, 0, 0, nil, pos(actor.x + 1, actor.y), 3)
			钉耙猫1 = createRole("钉耙猫", 17, 26, 0, 0, 0, nil, pos(actor.x - 1, actor.y), 3)

			delay(1)
			actor:magic(8, 钉耙猫, nil, DIR.left)
			钉耙猫:playAct(ACTS.ACT_BACKSTEP, pos(2, 0), DIR.left)
			钉耙猫1:playAct(ACTS.ACT_BACKSTEP, pos(-2, 0), DIR.right)
			delay(2)
		end
	elseif skillIndex == 20 then
		if PlayerSex == 0 then
			actor = createRole("小法师", "hero", 10, 34, 0, 0, nil, off2p(-2, 1), 9)
		else
			actor = createRole("小法师", "hero", 11, 34, 1, 1, nil, off2p(-2, 1), 9)
		end

		半兽人 = createRole("半兽人", 19, 100, 0, 0, 0, nil, off2p(2, 1), 9)
		半兽人.dir = DIR.left

		delay(1)

		x, y, mapid = getPlayerLocation()

		actor:say("13级可以学习诱惑之光。你能干扰怪物使他们无法动弹，甚至能诱惑他们成为你的宝宝。", nil)
		actor:magic(20, 半兽人, nil, DIR.left)
		delay(1)
		半兽人:playAct(ACT_WALK, pos(-1, 0), DIR.left)
		delay(1)
		actor:magic(20, 半兽人, nil, DIR.left)
		delay(1)
		半兽人:setNameColor(color(175, 105, 47))
		delay(1)
		actor:magic(20, 半兽人, nil, DIR.left)
		delay(1)
		半兽人.role.info:setName("半兽人(" .. actor.name .. ")")
		delay(1)
		actor:say("现在去诱惑一个半兽人试试吧，随着你等级的提升，你将能够诱惑更多强力的怪物。", nil)
	elseif skillIndex == 9 then
		if PlayerSex == 0 then
			actor = createRole("小法师", "hero", 10, 34, 0, 0, nil, off2p(-2, 1), 7)
		else
			actor = createRole("小法师", "hero", 11, 34, 1, 1, nil, off2p(-2, 1), 7)
		end

		森林雪人 = createRole("森林雪人", 10, 1, 0, 0, 0, nil, pos(actor.x + 5, actor.y), 7)
		森林雪人1 = createRole("森林雪人", 10, 1, 0, 0, 0, nil, pos(actor.x + 2, actor.y), 7)
		森林雪人2 = createRole("森林雪人", 10, 1, 0, 0, 0, nil, pos(actor.x + 3, actor.y), 7)
		森林雪人3 = createRole("森林雪人", 10, 1, 0, 0, 0, nil, pos(actor.x + 4, actor.y), 7)
		森林雪人.dir = DIR.left
		森林雪人1.dir = DIR.left
		森林雪人2.dir = DIR.left
		森林雪人3.dir = DIR.left

		actor:say("16级可以学习地狱火，这是法师第一个群攻技能，可以对前排5格的敌人造成伤害。", nil)
		delay(0.5)

		for i = 1, 3, 1 do
			actor:magic(9, 森林雪人, nil, DIR.right)
			delay(1)
			森林雪人:playAct(ACTS.STRUCK)
			森林雪人1:playAct(ACTS.STRUCK)
			森林雪人2:playAct(ACTS.STRUCK)
			森林雪人3:playAct(ACTS.STRUCK)
			delay(0.5)
		end
	elseif skillIndex == 11 then
		if PlayerSex == 0 then
			actor = createRole("小法师", "hero", 10, 34, 0, 0, nil, off2p(-2, 1), 7)
		else
			actor = createRole("小法师", "hero", 11, 34, 1, 1, nil, off2p(-2, 1), 7)
		end

		沃玛战士 = createRole("沃玛战士", 19, 30, 0, 0, 0, nil, off2p(2, 1), 7)

		actor:say("17级可以学习法师的核心技能雷电术，可以造成强大的单体伤害。", nil)
		delay(0.5)

		for i = 1, 3, 1 do
			actor:magic(11, 沃玛战士, nil, DIR.left)
			delay(1)
			沃玛战士:playAct(ACTS.STRUCK)
			delay(1)
		end

		actor:say("这个技能是不死系怪物的恶梦，你不用再怕骷髅和僵尸的骚扰了。", nil)
	elseif skillIndex == 21 then
		if PlayerSex == 0 then
			actor = createRole("法师", "hero", 26, 82, 0, 0, nil, off2p(-2, 1), 7)
		else
			actor = createRole("法师", "hero", 23, 82, 1, 1, nil, off2p(-2, 1), 7)
		end

		actor:say("19级可以学习瞬息移动，使用技能会随机飞到上次路过的主城所在的地图。", nil)
		delay(0.5)
		actor:magic(21, nil, nil, DIR.left)
		delay(0.5)
		actor:playAct(ACTS.SPACEMOVE_SHOW, pos(3, 3), DIR.bottom)
		delay(1.5)
		actor:magic(21, nil, nil, DIR.left)
		delay(0.5)
		actor:playAct(ACTS.SPACEMOVE_SHOW, pos(-1, -3), DIR.bottom)
		delay(1.5)
		actor:magic(21, nil, nil, DIR.left)
		delay(0.5)
		actor:playAct(ACTS.SPACEMOVE_SHOW, pos(-2, -2), DIR.bottom)
		delay(1.5)
		actor:say("好好使用，可以帮你省下很多地牢逃脱卷。", nil)
	elseif skillIndex == 5 then
		if PlayerSex == 0 then
			actor = createRole("法师", "hero", 26, 82, 0, 0, nil, off2p(-2, 1), 7)
		else
			actor = createRole("法师", "hero", 23, 82, 1, 1, nil, off2p(-2, 1), 7)
		end

		沃玛战士 = createRole("沃玛战士", 19, 151, 0, 0, 0, nil, off2p(2, 1), 7)

		actor:say("19级别忘了学习大火球，这可比小火球厉害多了。", nil)
		delay(0.5)

		for i = 1, 3, 1 do
			actor:magic(5, 沃玛战士, nil, DIR.left)
			delay(1)
			沃玛战士:playAct(ACTS.STRUCK)
			delay(1)
		end
	elseif skillIndex == 23 then
		if PlayerSex == 0 then
			actor = createRole("法师", "hero", 243, 56, 0, 0, nil, off2p(-2, 1), 7)
		else
			actor = createRole("法师", "hero", 242, 56, 1, 1, nil, off2p(-2, 1), 7)
		end

		沃玛战将 = {
			createRole("沃玛战将", 19, 33, 0, 0, 0, nil, off2p(2, 1), 7),
			createRole("沃玛战将", 19, 33, 0, 0, 0, nil, off2p(3, 1), 7),
			createRole("沃玛战将", 19, 33, 0, 0, 0, nil, off2p(1, 1), 7),
			createRole("沃玛战将", 19, 33, 0, 0, 0, nil, off2p(2, 0), 7),
			createRole("沃玛战将", 19, 33, 0, 0, 0, nil, off2p(2, 2), 7),
			createRole("沃玛战将", 19, 33, 0, 0, 0, nil, off2p(3, 2), 7),
			createRole("沃玛战将", 19, 33, 0, 0, 0, nil, off2p(1, 0), 7),
			createRole("沃玛战将", 19, 33, 0, 0, 0, nil, off2p(3, 0), 7),
			createRole("沃玛战将", 19, 33, 0, 0, 0, nil, off2p(1, 2), 7)
		}

		actor:say("22级可以学习爆裂火焰，它能对3X3的范围造成伤害。", nil)
		delay(0.5)

		for i = 1, 3, 1 do
			actor:magic(23, 沃玛战将[1], nil, DIR.left)
			delay(0.5)

			for i = 1, 9, 1 do
				沃玛战将[i]:playAct(ACTS.STRUCK)
			end

			delay(1.5)
		end
	elseif skillIndex == 22 then
		if PlayerSex == 0 then
			actor = createRole("法师", "hero", 243, 166, 0, 0, nil, off2p(-2, 1), 7)
		else
			actor = createRole("法师", "hero", 242, 166, 1, 1, nil, off2p(-2, 1), 7)
		end

		黑色恶蛆 = {
			createRole("黑色恶蛆", 19, 74, 0, 0, 0, nil, off2p(2, 1), 7),
			createRole("黑色恶蛆", 19, 74, 0, 0, 0, nil, off2p(1, 1), 7),
			createRole("黑色恶蛆", 19, 74, 0, 0, 0, nil, off2p(3, 1), 7),
			createRole("黑色恶蛆", 19, 74, 0, 0, 0, nil, off2p(2, 2), 7),
			createRole("黑色恶蛆", 19, 74, 0, 0, 0, nil, off2p(2, 5), 7),
			createRole("黑色恶蛆", 19, 74, 0, 0, 0, nil, off2p(2, 4), 7),
			createRole("黑色恶蛆", 19, 74, 0, 0, 0, nil, off2p(2, 6), 7),
			createRole("黑色恶蛆", 19, 74, 0, 0, 0, nil, off2p(3, 5), 7),
			createRole("黑色恶蛆", 19, 74, 0, 0, 0, nil, off2p(-3, -3), 7),
			createRole("黑色恶蛆", 19, 74, 0, 0, 0, nil, off2p(-3, -4), 7),
			createRole("黑色恶蛆", 19, 74, 0, 0, 0, nil, off2p(-3, -2), 7),
			createRole("黑色恶蛆", 19, 74, 0, 0, 0, nil, off2p(-2, -3), 7)
		}

		actor:say("24级你可以学习火墙了，释放之后会持续燃烧，火墙中的敌人会受到持续伤害。", nil)
		delay(0.5)
		actor:magic(22, 黑色恶蛆[1], nil, DIR.left)
		delay(1)

		for i = 1, 4, 1 do
			黑色恶蛆[i]:playAct(ACTS.STRUCK)
		end

		delay(1)
		actor:magic(22, 黑色恶蛆[5], nil, DIR.left)
		delay(1)

		for i = 1, 8, 1 do
			黑色恶蛆[i]:playAct(ACTS.STRUCK)
		end

		delay(1)
		actor:magic(22, 黑色恶蛆[9], nil, DIR.left)
		delay(1)

		for i = 1, 12, 1 do
			黑色恶蛆[i]:playAct(ACTS.STRUCK)
		end

		delay(1)
		actor:say("随着你魔法力和技能等级的提升，你施放的火墙会越来越炽热。", nil)
	elseif skillIndex == 10 then
		if PlayerSex == 0 then
			actor = createRole("法师", "hero", 243, 166, 0, 0, nil, off2p(-2, 1), 7)
		else
			actor = createRole("法师", "hero", 242, 166, 1, 1, nil, off2p(-2, 1), 7)
		end

		黑野猪 = {
			createRole("黑野猪", 19, 111, 0, 0, 0, nil, off2p(2, 1), 7),
			createRole("黑野猪", 19, 111, 0, 0, 0, nil, off2p(3, 1), 7),
			createRole("黑野猪", 19, 111, 0, 0, 0, nil, off2p(4, 1), 7),
			createRole("黑野猪", 19, 111, 0, 0, 0, nil, off2p(5, 1), 7),
			createRole("黑野猪", 19, 111, 0, 0, 0, nil, off2p(6, 1), 7)
		}

		actor:say("26级可以学习疾光电影，能够对对直线上的敌人造成伤害。", nil)
		delay(0.5)

		for i = 1, 3, 1 do
			actor:magic(10, 黑野猪[1], nil, DIR.left)
			delay(1)

			for i = 1, 5, 1 do
				黑野猪[i]:playAct(ACTS.STRUCK)
			end

			delay(1)
		end
	elseif skillIndex == 24 then
		if PlayerSex == 0 then
			actor = createRole("法师", "hero", 243, 221, 0, 0, nil, off2p(2, 2), 7)
		else
			actor = createRole("法师", "hero", 242, 221, 1, 1, nil, off2p(2, 2), 7)
		end

		僵尸 = {
			createRole("僵尸", 41, 50, 0, 0, 0, nil, off2p(2, 1), 7),
			createRole("僵尸", 41, 50, 0, 0, 0, nil, off2p(1, 3), 7),
			createRole("僵尸", 41, 50, 0, 0, 0, nil, off2p(2, 3), 7),
			createRole("僵尸", 41, 50, 0, 0, 0, nil, off2p(1, 2), 7),
			createRole("僵尸", 41, 50, 0, 0, 0, nil, off2p(3, 1), 7),
			createRole("僵尸", 41, 50, 0, 0, 0, nil, off2p(3, 2), 7),
			createRole("僵尸", 41, 50, 0, 0, 0, nil, off2p(1, 1), 7),
			createRole("僵尸", 41, 50, 0, 0, 0, nil, off2p(3, 3), 7)
		}

		actor:say("30级可以学习地狱雷光，这个技能能够对四周多个不死系敌人造成伤害。", nil)
		delay(0.5)

		for i = 1, 3, 1 do
			actor:magic(24, 僵尸[1], nil, DIR.left)

			for i = 1, 8, 1 do
				僵尸[i]:dirTo(actor)
				僵尸[i]:playAct(ACTS.STRUCK)
			end

			delay(2)
		end

		actor:say("和你的朋友们一起使用这个技能，让怪物们毫无还手之力吧。", nil)
	elseif skillIndex == 31 then
		if PlayerSex == 0 then
			actor = createRole("法师", "hero", 243, 221, 0, 0, nil, off2p(-2, 1), 7)
		else
			actor = createRole("法师", "hero", 242, 221, 1, 1, nil, off2p(-2, 1), 7)
		end

		actor:say("31级能够学习魔法盾，这是法师最重要的防御技能。", nil)
		delay(0.5)

		for i = 1, 3, 1 do
			actor:magic(31, nil, nil, DIR.left)
			delay(0.5)
			actor:addState("stMagicShield")
			delay(1.5)
		end

		actor:say("别忘了在“设置”中开启自动魔法盾。", nil)
	elseif skillIndex == 32 then
		if PlayerSex == 0 then
			actor = createRole("法师", "hero", 243, 221, 0, 0, nil, off2p(-2, 1), 7)
		else
			actor = createRole("法师", "hero", 242, 221, 1, 1, nil, off2p(-2, 1), 7)
		end

		黑野猪 = {
			createRole("黑野猪", 19, 111, 0, 0, 0, nil, off2p(2, 1), 7),
			createRole("黑野猪", 19, 111, 0, 0, 0, nil, off2p(1, 2), 7),
			createRole("黑野猪", 19, 111, 0, 0, 0, nil, off2p(2, 0), 7)
		}

		actor:say("32级可以学习圣言术，有一定几率能够秒杀不死系怪物。", nil)
		delay(0.5)

		for i = 1, 3, 1 do
			actor:magic(32, 黑野猪[i], nil, DIR.left)
			delay(1)
			黑野猪[i]:playAct(ACTS.NOWDEATH)
			delay(1)
		end
	elseif skillIndex == 33 then
		if PlayerSex == 0 then
			actor = createRole("飘逸法神", "hero", 329, 324, 0, 0, nil, off2p(-2, 1), 7)
		else
			actor = createRole("飘逸法神", "hero", 332, 324, 1, 1, nil, off2p(-2, 1), 7)
		end

		黑色恶蛆 = {
			createRole("黑色恶蛆", 19, 74, 0, 0, 0, nil, off2p(2, 2), 7),
			createRole("黑色恶蛆", 19, 74, 0, 0, 0, nil, off2p(2, 1), 7),
			createRole("黑色恶蛆", 19, 74, 0, 0, 0, nil, off2p(1, 3), 7),
			createRole("黑色恶蛆", 19, 74, 0, 0, 0, nil, off2p(2, 3), 7),
			createRole("黑色恶蛆", 19, 74, 0, 0, 0, nil, off2p(1, 2), 7),
			createRole("黑色恶蛆", 19, 74, 0, 0, 0, nil, off2p(3, 1), 7),
			createRole("黑色恶蛆", 19, 74, 0, 0, 0, nil, off2p(3, 2), 7),
			createRole("黑色恶蛆", 19, 74, 0, 0, 0, nil, off2p(1, 1), 7),
			createRole("黑色恶蛆", 19, 74, 0, 0, 0, nil, off2p(3, 3), 7)
		}

		actor:say("达到35级你已经可以学习冰咆哮了，它能对3X3范围的敌人造成极大的伤害。", nil)
		delay(0.5)

		for i = 1, 3, 1 do
			actor:magic(33, 黑色恶蛆[1], nil, DIR.left)
			delay(1)

			for i = 1, 9, 1 do
				黑色恶蛆[i]:playAct(ACTS.STRUCK)
			end

			delay(1)
		end
	elseif skillIndex == 39 then
		if PlayerSex == 0 then
			actor = createRole("飘逸法神", "hero", 402, 210, 0, 0, nil, off2p(-2, 1), 7)
		else
			actor = createRole("飘逸法神", "hero", 403, 210, 1, 1, nil, off2p(-2, 1), 7)
		end

		红野猪 = createRole("红野猪", 19, 110, 0, 0, 0, nil, off2p(1, 1), 7)

		actor:say("你可以学习寒冰掌了，它不仅能够造成伤害，还有几率推动级别低于你的敌人。", nil)
		delay(0.5)

		for i = 1, 3, 1 do
			actor:magic(39, 红野猪, nil, DIR.left)
			delay(1)
			红野猪:playAct(ACTS.ACT_BACKSTEP, pos(1, 0), DIR.left)
			delay(1)
		end
	elseif skillIndex == 35 then
		if PlayerSex == 0 then
			actor = createRole("飘逸法神", "hero", 402, 210, 0, 0, nil, off2p(-2, 1), 7)
		else
			actor = createRole("飘逸法神", "hero", 403, 210, 1, 1, nil, off2p(-2, 1), 7)
		end

		白野猪 = createRole("白野猪", 19, 112, 0, 0, 0, nil, off2p(2, 1), 7)

		actor:say("你可以学习灭天火了，它不仅能够造成伤害，还能够灼烧敌人的魔法值。", nil)
		delay(0.5)

		for i = 1, 3, 1 do
			actor:magic(35, 白野猪, nil, DIR.left)
			delay(0.5)
			白野猪:playAct(ACTS.STRUCK)
			delay(1)
		end
	elseif skillIndex == 59 then
		if PlayerSex == 0 then
			actor = createRole("飘逸法神", "hero", 350, 348, 0, 0, nil, off2p(-2, 1), 7)
		else
			actor = createRole("飘逸法神", "hero", 351, 348, 1, 1, nil, off2p(-2, 1), 7)
		end

		火焰沃玛 = {
			createRole("火焰沃玛", 20, 31, 0, 0, 0, nil, off2p(2, 2), 7),
			createRole("火焰沃玛", 20, 31, 0, 0, 0, nil, off2p(2, 1), 7),
			createRole("火焰沃玛", 20, 31, 0, 0, 0, nil, off2p(1, 3), 7),
			createRole("火焰沃玛", 20, 31, 0, 0, 0, nil, off2p(2, 3), 7),
			createRole("火焰沃玛", 20, 31, 0, 0, 0, nil, off2p(1, 2), 7),
			createRole("火焰沃玛", 20, 31, 0, 0, 0, nil, off2p(3, 1), 7),
			createRole("火焰沃玛", 20, 31, 0, 0, 0, nil, off2p(3, 2), 7),
			createRole("火焰沃玛", 20, 31, 0, 0, 0, nil, off2p(1, 1), 7),
			createRole("火焰沃玛", 20, 31, 0, 0, 0, nil, off2p(3, 3), 7)
		}

		actor:say("47级可以学习法师高级技能流星火雨。高伤害、3X3的范围，群体技能的不二之选。", nil)
		delay(0.5)

		for i = 1, 3, 1 do
			actor:magic(59, 火焰沃玛[1], nil, DIR.left)
			delay(1)

			for i = 1, 9, 1 do
				火焰沃玛[i]:playAct(ACTS.STRUCK)
			end

			delay(1)
		end
	elseif skillIndex == 2 then
		if PlayerSex == 0 then
			actor = createRole("小哥", "hero", 5, 55, 0, 0, nil, off2p(-2, 1), 7)
		else
			actor = createRole("小妹", "hero", 6, 55, 1, 1, nil, off2p(-2, 1), 7)
		end

		actor:say("快学习治愈术吧，这样你就可以给自己和队友回复血量了。", nil)
		delay(0.5)

		for i = 1, 3, 1 do
			actor:magic(2, "player", nil, DIR.left)
			delay(2)
		end
	elseif skillIndex == 4 then
		if PlayerSex == 0 then
			actor = createRole("小哥", "hero", 5, 55, 0, 0, nil, off2p(-2, 1), 7)
		else
			actor = createRole("小妹", "hero", 6, 55, 1, 1, nil, off2p(-2, 1), 7)
		end

		actor:say("精神力战法是被动技能，它能够大幅提高你的准确。", nil)
	elseif skillIndex == 6 then
		if PlayerSex == 0 then
			actor = createRole("小道士", "hero", 10, 68, 0, 0, nil, off2p(-2, 1), 7)
		else
			actor = createRole("小道士", "hero", 11, 68, 1, 1, nil, off2p(-2, 1), 7)
		end

		骷髅 = createRole("骷髅", 14, 20, 0, 0, 0, nil, off2p(2, 1), 7)

		actor:say("14级可以学习施毒术，不过使用技能时必须佩戴红毒或者绿毒。", nil)
		delay(0.5)

		for i = 1, 2, 1 do
			actor:magic(6, 骷髅, nil, DIR.left)
			delay(1)

			if i == 1 then
				骷髅:addState("stPoisonGreen")
			else
				骷髅:addState("stPoisonRed")
			end

			delay(2)
		end

		actor:say("红毒可以加成伤害效果，绿毒可以限制体力回复。", nil)
	elseif skillIndex == 13 then
		if PlayerSex == 0 then
			actor = createRole("小道士", "hero", 10, 68, 0, 0, nil, off2p(-2, 1), 7)
		else
			actor = createRole("小道士", "hero", 11, 68, 1, 1, nil, off2p(-2, 1), 7)
		end

		僵尸 = createRole("僵尸", 41, 50, 0, 0, 0, nil, off2p(2, 1), 7)

		actor:say("18级你就可以学习灵魂火符了，这样你就能远程攻击敌人，别忘了佩戴护身符。", nil)
		delay(0.5)

		for i = 1, 3, 1 do
			actor:magic(13, 僵尸, nil, DIR.left)
			delay(1)
			僵尸:playAct(ACTS.STRUCK)
			delay(1)
		end
	elseif skillIndex == 17 then
		if PlayerSex == 0 then
			actor = createRole("小道士", "hero", 10, 68, 0, 0, nil, off2p(-2, 1), 7)
		else
			actor = createRole("小道士", "hero", 11, 68, 1, 1, nil, off2p(-2, 1), 7)
		end

		actor:say("19级可以学习召唤骷髅，技能等级越高，骷髅宝宝的等级也会越高。", nil)
		delay(0.5)
		actor:magic(17, nil, nil, DIR.left)
		delay(0.5)

		变异骷髅 = createRole("变异骷髅", 23, 37, 0, 0, 0, nil, pos(actor.x + 1, actor.y), 6)

		delay(3)
		actor:say("想要快速提升召唤熟练度，可以去大刀守卫那儿练习技能。", nil)
	elseif skillIndex == 18 then
		if PlayerSex == 0 then
			actor = createRole("道士", "hero", 27, 83, 0, 0, nil, off2p(-2, 1), 7)
		else
			actor = createRole("道士", "hero", 24, 83, 1, 1, nil, off2p(-2, 1), 7)
		end

		actor:say("20级可以学习隐身术，使用技能能够使大部分怪物都无法洞察你。", nil)
		delay(0.5)

		for i = 1, 3, 1 do
			actor:magic(18, nil, nil, DIR.left)
			delay(0.5)
			actor:addState("stHidden")
			delay(1.5)
		end
	elseif skillIndex == 19 then
		if PlayerSex == 0 then
			actor = createRole("道士", "hero", 27, 83, 0, 0, nil, off2p(-2, 1), 7)
		else
			actor = createRole("道士", "hero", 24, 83, 1, 1, nil, off2p(-2, 1), 7)
		end

		actor_1 = createRole("法师", "hero", 243, 56, 0, 0, nil, off2p(2, 1), 7)
		actor_2 = createRole("法师", "hero", 242, 56, 1, 1, nil, off2p(3, 1), 7)
		actor_3 = createRole("战士", "hero", 25, 35, 0, 0, nil, off2p(2, 2), 7)
		actor_4 = createRole("战士", "hero", 22, 35, 1, 1, nil, off2p(1, 1), 7)

		actor:say("21级可以学习集体隐身术，这样你也可以帮助队友实现隐身效果了。", nil)
		delay(1)

		for i = 1, 3, 1 do
			actor:magic(19, actor_1, nil, DIR.left)
			delay(1)
			actor_1:addState("stHidden")
			actor_2:addState("stHidden")
			actor_3:addState("stHidden")
			actor_4:addState("stHidden")
			delay(1)
		end
	elseif skillIndex == 14 then
		if PlayerSex == 0 then
			actor = createRole("道士", "hero", 245, 33, 0, 0, nil, off2p(-2, 0), 7)
		else
			actor = createRole("道士", "hero", 244, 33, 1, 1, nil, off2p(-2, 0), 7)
		end

		actor:say("22级可以学习幽灵盾，能够帮助范围内队友提高魔御。", nil)

		actor.dir = DIR.right

		delay(0.5)

		for i = 1, 3, 1 do
			x, y = getPlayerLocation()

			actor:magic(14, "player", nil, DIR.right)
			delay(2)
		end
	elseif skillIndex == 15 then
		if PlayerSex == 0 then
			actor = createRole("道士", "hero", 245, 33, 0, 0, nil, off2p(-2, 1), 7)
		else
			actor = createRole("道士", "hero", 244, 33, 1, 1, nil, off2p(-2, 1), 7)
		end

		actor:say("25级可以学习神圣战甲术，能够帮助范围内队友提高防御。", nil)
		delay(0.5)

		for i = 1, 3, 1 do
			actor:magic(15, "player", nil, DIR.right)
			delay(2)
		end
	elseif skillIndex == 28 then
		if PlayerSex == 0 then
			actor = createRole("道士", "hero", 245, 165, 0, 0, nil, off2p(-2, 1), 7)
		else
			actor = createRole("道士", "hero", 244, 165, 1, 1, nil, off2p(-2, 1), 7)
		end

		变异骷髅 = createRole("变异骷髅", 23, 37, 0, 0, 0, nil, off2p(2, 1), 7)

		actor:say("26级可以学习心灵启示，利用这个技能能在一定时间内查看目标的体力值。", nil)
		delay(0.5)

		for i = 1, 3, 1 do
			actor:magic(28, 变异骷髅, nil, DIR.left)
			delay(2)
		end
	elseif skillIndex == 16 then
		if PlayerSex == 0 then
			actor = createRole("道士", "hero", 245, 209, 0, 0, nil, off2p(-2, 1), 7)
		else
			actor = createRole("道士", "hero", 244, 209, 1, 1, nil, off2p(-2, 1), 7)
		end

		角蝇 = createRole("角蝇", 43, 41, 0, 0, 0, nil, off2p(2, 1), 7)

		actor:say("28级可以学习困魔咒，能困住范围内的怪物，升级后还可以对付更加强力的怪物。", nil)
		delay(0.5)

		for i = 1, 3, 1 do
			actor:magic(16, 角蝇, nil, DIR.left)
			delay(2)
		end
	elseif skillIndex == 29 then
		if PlayerSex == 0 then
			actor = createRole("道士", "hero", 245, 209, 0, 0, nil, off2p(-2, 1), 7)
		else
			actor = createRole("道士", "hero", 244, 209, 1, 1, nil, off2p(-2, 1), 7)
		end

		actor_1 = createRole("法师", "hero", 243, 56, 0, 0, nil, off2p(2, 1), 7)
		actor_2 = createRole("法师", "hero", 242, 56, 1, 1, nil, off2p(3, 1), 7)
		actor_3 = createRole("战士", "hero", 25, 35, 0, 0, nil, off2p(2, 2), 7)
		actor_4 = createRole("战士", "hero", 22, 35, 1, 1, nil, off2p(1, 1), 7)

		actor:say("33级可以学习群体治愈术，可恢复施放范围内所有玩家的体力值。", nil)
		delay(0.5)

		for i = 1, 3, 1 do
			actor:magic(29, actor_1, nil, DIR.left)
			delay(2)
		end
	elseif skillIndex == 30 then
		if PlayerSex == 0 then
			actor = createRole("逍遥天尊", "hero", 330, 326, 0, 0, nil, off2p(-2, 1), 7)
		else
			actor = createRole("逍遥天尊", "hero", 333, 326, 1, 1, nil, off2p(-2, 1), 7)
		end

		delay(0.5)
		actor:say("达到35级你已经可以学习召唤神兽了，你的神兽宝宝非常强大。", nil)
		actor:magic(30, nil, nil, DIR.left)
		delay(0.5)

		神兽 = createRole("神兽", 54, 170, 0, 0, 0, nil, pos(actor.x + 1, actor.y), 2)

		delay(2)

		神兽 = createRole("神兽", 55, 171, 0, 0, 0, nil, pos(actor.x + 1, actor.y), 4)

		神兽:playAct(ACTS.DIGUP)
		delay(1)
	elseif skillIndex == 37 then
		if PlayerSex == 0 then
			actor = createRole("逍遥天尊", "hero", 404, 326, 0, 0, nil, off2p(-2, 1), 7)
		else
			actor = createRole("逍遥天尊", "hero", 405, 326, 1, 1, nil, off2p(-2, 1), 7)
		end

		actor:say("你可以学习气功波了，只要是等级不比你高的敌人，你就能推开。", nil)
		delay(0.5)

		for i = 1, 2, 1 do
			神兽 = createRole("神兽", 54, 170, 0, 0, 0, nil, pos(actor.x + 1, actor.y), 3)
			神兽1 = createRole("神兽", 54, 170, 0, 0, 0, nil, pos(actor.x - 1, actor.y), 3)

			delay(1)
			actor:magic(37, nil, nil, DIR.left)
			神兽:playAct(ACTS.ACT_BACKSTEP, pos(2, 0), DIR.left)
			神兽1:playAct(ACTS.ACT_BACKSTEP, pos(-2, 0), DIR.right)
			delay(2)
		end
	elseif skillIndex == 36 then
		if PlayerSex == 0 then
			actor = createRole("逍遥天尊", "hero", 404, 326, 0, 0, nil, off2p(-2, 1), 7)
		else
			actor = createRole("逍遥天尊", "hero", 405, 326, 1, 1, nil, off2p(-2, 1), 7)
		end

		actor:say("你可以学习无极真气了，能够在大量提高自身的道术。", nil)
		delay(0.5)

		for i = 1, 3, 1 do
			actor:magic(36, nil, nil, DIR.left)
			delay(2)
		end
	elseif skillIndex == 48 then
		if PlayerSex == 0 then
			actor = createRole("逍遥天尊", "hero", 350, 349, 0, 0, nil, off2p(-2, 1), 7)
		else
			actor = createRole("逍遥天尊", "hero", 351, 349, 1, 1, nil, off2p(-2, 1), 7)
		end

		沃玛卫士 = createRole("沃玛卫士", 19, 151, 0, 0, 0, nil, off2p(2, 1), 7)

		actor:say("47级可以学习道士高级技能噬血书。可以无视地形对敌人造成伤害。", nil)
		delay(0.5)

		for i = 1, 3, 1 do
			actor:magic(48, 沃玛卫士, nil, DIR.left)
			delay(1)
			沃玛卫士:playAct(ACTS.STRUCK)
			delay(1)
		end
	end

	return 
end

return 

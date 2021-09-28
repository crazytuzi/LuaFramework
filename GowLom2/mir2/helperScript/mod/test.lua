function main(skillIndex)
	print("test")

	local testAll = false
	local testSkills = false
	local testWalkTo = false
	local testShowEquip = false
	local testNameColor = false
	local testSkillDir = false
	local testStateSkill = false
	local testAct = false
	local testGuide = false
	local testStage = false
	local testDialogNode = false
	local testEffect = false
	local testNewSkill = false
	local testSpaceMove = false
	local testRole = false
	local stress = true

	if testSkills or testAll then
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
			"流星火雨",
			[300.0] = "wer"
		}

		for skillIndex, v in pairs({
			[300.0] = "测试"
		}) do
			HELPER:say("现在发动的是:" .. skillName[skillIndex])

			if PlayerJob == "法师" then
				actor = createRole("至尊法师", "hero", 24, 19, 1, 0, pos(1, 0), nil, 500)
			elseif PlayerJob == "战士" then
				actor = createRole("至尊战士", "hero", 24, 19, 1, 0, pos(1, 0), nil, 500)
			else
				actor = createRole("至尊道士", "hero", 24, 19, 1, 0, pos(1, 0), nil, 500)
			end

			actor:dirTo("player")
			actor:setNameColor(color(255, 255, 0))

			if skillIndex == 27 then
				actor.dir = DIR.right

				delay(0.5)

				稻草人 = createRole("稻草人", 17, 27, 19, 1, 0, nil, pos(actor.x + 1, actor.y), 5)
				稻草人.dir = DIR.left

				delay(1)
				actor:magic(skillIndex, nil, pos(2, 0), DIR.right)
				稻草人:playAct(ACTS.ACT_BACKSTEP, pos(2, 0), DIR.left)
				稻草人:playAct(ACTS.ACT_STRUCK, pos(2, 0), DIR.left)
			else
				target = HELPER

				delay(0.5)
				actor:magic(skillIndex, "player")
			end

			delay(2)
		end
	end

	if testWalkTo or testAll then
		HELPER:walkTo(330, 260, "0", "走到比奇330,260，引导距离3，与玩家最大距离10", 3, 10, "waitEvt", "arriveEvt", "failtEvt", false)

		EVT.waitEvt = function ()
			HELPER:say("正在等待玩家")

			return 
		end
		EVT.failtEvt = function ()
			HELPER:say("目标不可达")
			HELPER:followPlayer()

			return 
		end

		waitEvt("arriveEvt")
		HELPER.say(slot17, "引导结束")
		HELPER:followPlayer()
	end

	if testShowEquip or testAll then
		actor = createRole("装备测试", "hero", nil, 19, 1, 0, pos(1, 0), nil, 5)

		actor:showEquip(3)
		HELPER:say("显示的应当是女性装备")
		delay(3)

		actor = createRole("装备测试2", "hero", nil, 19, 0, 1, pos(1, 0), nil, 5)

		actor:showEquip(3)
		HELPER:say("显示的应当是男性装备")
		delay(3)
	end

	if testNameColor or testAll then
		actor = createRole("名称颜色", "hero", nil, 19, 1, 0, pos(1, 1), nil)
		actor2 = createRole("名称颜色", "hero", nil, 19, 1, 0, pos(2, 2), nil)
		actor3 = createRole("名称颜色", "hero", nil, 19, 1, 0, pos(3, 3), nil)
		actor4 = createRole("名称颜色", "hero", nil, 19, 1, 0, pos(4, 4), nil)
		actor5 = createRole("名称颜色", "hero", nil, 19, 1, 0, pos(5, 5), nil)

		for k = 200, 255, 5 do
			actor:setNameColor(k)

			actor.name = k

			actor2:setNameColor(k + 1)

			actor2.name = k + 1

			actor3:setNameColor(k + 2)

			actor3.name = k + 2

			actor4:setNameColor(k + 3)

			actor4.name = k + 3

			actor5:setNameColor(k + 4)

			actor5.name = k + 4

			delay(3)
		end

		actor:removeSelf()
	end

	if testSkillDir or testAll then
		actor = createRole("技能方向", "hero", nil, 19, 1, 0, pos(1, 0), nil, 5)

		for k = 1, 5, 1 do
			actor:magic(30, nil, nil, DIR.up)
			delay(1)
			actor:magic(30, nil, nil, DIR.rightUp)
			delay(1)
			actor:magic(30, nil, nil, DIR.right)
			delay(1)
			actor:magic(30, nil, nil, DIR.rightBottom)
			delay(1)
			actor:magic(30, nil, nil, DIR.bottom)
			delay(1)
			actor:magic(30, nil, nil, DIR.leftBottom)
			delay(1)
			actor:magic(30, nil, nil, DIR.left)
			delay(1)
			actor:magic(30, nil, nil, DIR.leftUp)
			delay(1)
		end
	end

	if testStateSkill or testAll then
		actor = createRole("带状态技能测试", "hero", nil, 19, 1, 0, pos(1, 0), nil)
		actor2 = createRole("魔法受击者", "hero", nil, 19, 1, 0, pos(1, 5), nil)

		HELPER:say("火墙,必须带目标/坐标")
		actor:magic(22, actor2)
		delay(5)
		HELPER:say("困魔咒,必须带目标/坐标")
		actor:magic(16, actor2)
		delay(5)
		HELPER:say("魔法盾")
		actor:magic(31)
		delay(5)
		HELPER:say("隐身术")
		actor:magic(18)
		delay(5)
		HELPER:say("隐身术")
		actor:magic(18, actor2)
		delay(5)
		actor:removeSelf()
		actor2:removeSelf()
	end

	if testAct or testAll then
		actor = createRole("action类动作测试", "hero", nil, 19, 1, 0, pos(1, 0), nil)

		runActs({
			action.delay(0.5),
			action.callFunc(function ()
				print("ok~")

				return 
			end),
			actor.actWalkTo(slot19, off2p(5, 5).x, off2p(5, 5).y),
			action.callFunc(function ()
				print("ok~2")

				return 
			end)
		})
	end

	if testGuide or testAll then
		local testTwinkle = false
		local testTipText = false
		local testDragGuide = false
		local test = nil

		if testTwinkle then
			local flashHandler = GUIDE.twinkleNodeWidthName(slot21, "diy_布局", {
				w = 36,
				circle = false,
				h = 72
			})

			delay(5)
			GUIDE:stop()
		end

		if testTipText then
			local tip1 = GUIDE:showTipText("diy_布局", {
				"点击这里打开布局面板",
				22,
				1,
				align = "left"
			}, pos(400, 0))
			local tip2 = GUIDE:showTipText("diy_布局", {
				"点击这里打开布局面板",
				22,
				1,
				align = "top"
			}, pos(400, 0))
			local tip3 = GUIDE:showTipText("diy_布局", {
				"点击这里打开布局面板",
				22,
				1,
				align = "right"
			}, pos(400, 0))
			local tip4 = GUIDE:showTipText("diy_布局", {
				"点击这里打开布局面板",
				22,
				1,
				align = "bottom"
			}, pos(400, 0))

			delay(5)
			GUIDE:stop()
		end

		if testDragGuide then
			local handler1 = GUIDE:dragGuide("diy_布局", "diy_好友")
			local handler1 = GUIDE:dragGuide("diy_布局", "diy_好友", {
				finger = {
					flipY = true
				}
			})
			local handler2 = GUIDE:dragGuide("diy_布局", "diy_好友", {
				finger = {
					flipX = true
				}
			})
			local handler3 = GUIDE:dragGuide("diy_布局", "diy_好友", {
				finger = {
					flipY = true,
					flipX = true
				}
			})

			delay(7)
			GUIDE:stop()

			local handler1 = GUIDE:dragGuide("diy_布局", "diy_好友")

			delay(3)
			GUIDE:stop()
		end
	end

	if testStage then
		enterStage(0, 333, 260)
		enterStage(3, 333, 333)
		delay(0.5)
		stage:moveTo(340, 340, true, 10)
		delay(10)
		exitStage()
	end

	if testDialogNode then
		createSayDL("left::::", nil, 32, 5):pos(100, 100)
		createSayDR("right::::", nil, 32, 5):pos(400, 100)
	end

	if testEffect then
		print(EFFIDS.ET_FIRE)
		showEffect(EFFIDS.ET_FIRE, off2p(1, 1), 10)
	end

	if testNewSkill then
		actor = createRole("至尊战士", "hero", 24, 19, 1, 0, pos(1, 0), nil, 50)

		delay(1)
		actor:playBigSkill()

		return 
	end

	if testNewSkill then
		actor = createRole("至尊战士", "hero", 24, 19, 1, 0, pos(1, 0), nil, 50)

		delay(1)
		actor:playBigSkill1()
	end

	if testSpaceMove or testAll then
		actor = createRole("至尊战士", "hero", 24, 19, 1, 0, pos(1, 0), nil, 50)

		actor:playAct(ACTS.SPACEMOVE_SHOW)
	end

	if testRole then
		for k = 0, 7, 1 do
			actor = createRole("怪物", 14, 150, 0, 0, 0, pos(k*2, 0), nil)
			actor.dir = k

			runActsForever({
				actor:actAttack(3),
				actor:actDelay(1)
			})
		end

		for k = 0, 7, 1 do
			actor = createRole("攻击 人物_" .. k, "hero", 24, 19, 1, 0, pos(k*2, 3), nil)
			actor.dir = k

			runActsForever({
				actor:actAttack(3),
				actor:actDelay(1)
			})
		end

		local host = createRole("施法 受体", "hero", 24, 19, 1, 0, pos(5, 8), nil)

		for k = 0, 7, 1 do
			local cfg = DIR["_" .. k]
			actor = createRole("施法 人物_" .. k, "hero", 24, 19, 1, 0, pos(cfg[1]*2 + 5, cfg[2]*2 + 8), nil)
			actor.dir = k

			runActsForever({
				actor:actMagic("30", host, pos(1, 0)),
				actor:actDelay(1)
			})
		end
	end

	if stress then
		math.randomseed(0)

		local ret = {}
		local dress = {}

		for k, v in pairs(ITEMS) do
			if type(v) == "table" and (v.stdMode == 10 or v.stdMode == 11) then
				table.insert(dress, k)
			end
		end

		local magics = {
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
		local mid = {}

		for k, v in pairs(magics) do
			table.insert(mid, k)
		end

		enterStage("3", 504, 146, {
			disableSkip = true
		})

		local _pos = pos

		local function pos(x, y)
			return _pos(x + 504, y + 146)
		end

		local pre = nil
		useDress = true
		skill = true

		STAGE.setMapScale(slot24, 0.7)

		for _ = 1, 3, 1 do
			for y = -15, 15, 1 do
				for x = 0, 40, 1 do
					local dre = nil

					if useDress then
						dre = dress[math.random(#dress)]
					end

					local d = createRole("" .. (dress[x] or y), "hero", dre, nil, 0, y%7, nil, pos(x - 20, y), nil)

					if skill and pre then
						local tpre = pre

						d.role.node:performWithDelay(function ()
							d.role.node:runForever(action.seq({
								action.callFunc(function ()
									local id = mid[math.random(#mid)]

									d:magic(id, tpre)

									return 
								end),
								d.actDelay(slot4, math.random()*10)
							}))

							return 
						end, math.random()*10)
					elseif move then
						d.role.node.runs(slot38, {
							action.rep(action.seq(d.actPlayAct(d, ACTS.WALK, pos(-1, -1)), d.actDelay(d, 2)), 50)
						})
					end

					pre = d

					table.insert(ret, d)
				end
			end
		end
	end

	return 
end

return 

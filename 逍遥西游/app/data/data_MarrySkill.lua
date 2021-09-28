data_MarrySkill = {
  [10001] = {
    name = "亲密无间",
    icon = "10001",
    desc = "为伴侣回复#PPY#的气血和法力，冷却5回合",
    yhd = 0,
    initiative = 1,
    mpbase = 0,
    cd = 5,
    performType = 1,
    objAni = 0,
    dzAni = 0,
    calparam = {
      1,
      500,
      0.7
    }
  },
  [10002] = {
    name = "同仇敌忾",
    icon = "10002",
    desc = "#PPZ#概率使伴侣免疫法术伤害与物理伤害，持续1回合，冷却5回合",
    yhd = 0,
    initiative = 1,
    mpbase = 100,
    cd = 5,
    performType = 1,
    objAni = 56,
    dzAni = 0,
    calparam = {
      1,
      0.2,
      1,
      2200,
      1.1,
      40000,
      1.3
    }
  },
  [10003] = {
    name = "情深似海",
    icon = "10003",
    desc = "#PPZ#概率清除伴侣的所有负面效果，自身被控制时仍可以释放，每场战斗只能使用一次",
    yhd = 0,
    initiative = 1,
    mpbase = 800,
    cd = 0,
    performType = 1,
    objAni = 200,
    dzAni = 0,
    calparam = {
      0.1,
      1,
      2200,
      1.1,
      40000,
      1.5
    }
  },
  [10004] = {
    name = "缘起于此",
    icon = "10004",
    desc = "与伴侣组队时，抗致命增加10%，仅在与怪物之间的战斗有效（友好达到500自动激活）",
    yhd = 500,
    initiative = 2,
    mpbase = 0,
    cd = 0,
    performType = 0,
    objAni = 0,
    dzAni = 0,
    calparam = 0
  },
  [10005] = {
    name = "不离不弃",
    icon = "10005",
    desc = "与伴侣组队时，躲闪率增加5%，仅在与怪物之间的战斗有效（友好达到3500自动激活）",
    yhd = 3500,
    initiative = 2,
    mpbase = 0,
    cd = 0,
    performType = 0,
    objAni = 0,
    dzAni = 0,
    calparam = 0
  },
  [10006] = {
    name = "生死相随",
    icon = "10006",
    desc = "与伴侣组队时，虹吸抗性增加5%，仅在与怪物之间的战斗有效（友好达到8500自动激活）",
    yhd = 8000,
    initiative = 2,
    mpbase = 0,
    cd = 0,
    performType = 0,
    objAni = 0,
    dzAni = 0,
    calparam = 0
  },
  [10007] = {
    name = "情深似海",
    icon = "10007",
    desc = "与伴侣组队时，物理吸收增加5%，仅在与怪物之间的战斗有效（友好达到15000自动激活）",
    yhd = 15000,
    initiative = 2,
    mpbase = 0,
    cd = 0,
    performType = 0,
    objAni = 0,
    dzAni = 0,
    calparam = 0
  },
  [10008] = {
    name = "旷世奇缘 ",
    icon = "10008",
    desc = "与伴侣组队时，抓鬼、天庭、鬼王经验增加5%（友好达到25000自动激活）",
    yhd = 25000,
    initiative = 2,
    mpbase = 0,
    cd = 0,
    performType = 0,
    objAni = 0,
    dzAni = 0,
    calparam = 0
  }
}

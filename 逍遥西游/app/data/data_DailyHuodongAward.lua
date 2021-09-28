data_DailyHuodongAward = {
  [10001] = {
    TypeName = "豪华午餐",
    Title = "每日12:00-14:00可领取活力值与饱食度",
    Desc = "指定中午时间领取体力",
    OpenZs = 0,
    OpenLv = 1,
    AlwaysJudgeLvFlag = 0,
    Condition = {
      {12, 0},
      {14, 0}
    },
    Icon = "views/gift/pic_gift_wucan.png",
    showNumber = 1,
    Award = {
      Tili = 0,
      Gold = 0,
      Coin = 0,
      Silver = 0,
      Huoli = 200,
      BaoShiDu = 20,
      Item = {
        [90010] = 3
      }
    }
  },
  [10002] = {
    TypeName = "豪华晚餐",
    Title = "每日18:00-20:00可领取活力值与饱食度",
    Desc = "指定晚上时间领取体力",
    OpenZs = 0,
    OpenLv = 1,
    AlwaysJudgeLvFlag = 0,
    Condition = {
      {18, 0},
      {20, 0}
    },
    Icon = "views/gift/pic_gift_wancan.png",
    showNumber = 2,
    Award = {
      Tili = 0,
      Gold = 0,
      Coin = 0,
      Silver = 0,
      Huoli = 200,
      BaoShiDu = 20,
      Item = {
        [90010] = 3
      }
    }
  },
  [10003] = {
    TypeName = "师门任务",
    Title = "完成师门任务,获得奖券*1",
    Desc = "指定完成n次师门任务",
    OpenZs = 0,
    OpenLv = 22,
    AlwaysJudgeLvFlag = 0,
    Condition = {20},
    Icon = "views/gift/pic_gift_shimen.png",
    showNumber = 4,
    Award = {
      Tili = 0,
      Gold = 0,
      Coin = 0,
      Silver = 1500,
      Huoli = 300,
      BaoShiDu = 0,
      Item = {
        [93048] = 1
      }
    }
  },
  [10006] = {
    TypeName = "道道道",
    Title = "帮助钟馗收服鬼魂,获取经验",
    Desc = "指定完成n次抓鬼任务",
    OpenZs = 0,
    OpenLv = 25,
    AlwaysJudgeLvFlag = 0,
    Condition = {20},
    Icon = "views/gift/pic_gift_zhuagui.png",
    showNumber = 9,
    Award = {
      Tili = 0,
      Gold = 0,
      Coin = 100000,
      Silver = 0,
      Huoli = 50,
      BaoShiDu = 0,
      Item = {}
    }
  },
  [10007] = {
    TypeName = "天庭任务",
    Title = "收服天庭妖王,获取经验与蟠桃",
    Desc = "指定完成n次天庭任务",
    OpenZs = 0,
    OpenLv = 60,
    AlwaysJudgeLvFlag = 1,
    Condition = {1},
    Icon = "views/gift/pic_gift_tianting.png",
    showNumber = 5,
    Award = {
      Tili = 0,
      Gold = 0,
      Coin = 100000,
      Silver = 0,
      Huoli = 50,
      BaoShiDu = 0,
      Item = {}
    }
  },
  [10008] = {
    TypeName = "大雁塔除妖",
    Title = "清除大雁塔的妖魔,获得奖券*1",
    Desc = "指定完成n次大雁塔除妖",
    OpenZs = 0,
    OpenLv = 45,
    AlwaysJudgeLvFlag = 1,
    Condition = {1},
    Icon = "views/gift/pic_gift_dayanta.png",
    showNumber = 6,
    Award = {
      Tili = 0,
      Gold = 0,
      Coin = 100000,
      Silver = 0,
      Huoli = 100,
      BaoShiDu = 0,
      Item = {
        [93048] = 1
      }
    }
  },
  [10010] = {
    TypeName = "以武会友",
    Title = "挑战各路好手,赢取荣誉，获得奖券*1",
    Desc = "在比武场完成n次比武",
    OpenZs = 0,
    OpenLv = 30,
    AlwaysJudgeLvFlag = 0,
    Condition = {3},
    Icon = "views/gift/pic_gift_biwu.png",
    showNumber = 10,
    Award = {
      Tili = 0,
      Gold = 0,
      Coin = 0,
      Silver = 500,
      Huoli = 100,
      BaoShiDu = 0,
      Item = {
        [93048] = 1
      }
    }
  },
  [10012] = {
    TypeName = "月卡",
    Title = "购买月卡,每天领取300000元宝3个奖券",
    Desc = "购买月卡（月卡可重复购买,效果叠加）",
    OpenZs = 0,
    OpenLv = 1,
    AlwaysJudgeLvFlag = 0,
    Condition = {1},
    Icon = "views/gift/pic_gift_yueka.png",
    showNumber = 3,
    Award = {
      Tili = 0,
      Gold = 300000,
      Coin = 0,
      Silver = 0,
      Huoli = 0,
      BaoShiDu = 0,
      Item = {
        [93048] = 3
      }
    }
  },
  [10013] = {
    TypeName = "科举考试",
    Title = "10:00-18:45完成科举乡试",
    Desc = "参加完科举乡试",
    OpenZs = 0,
    OpenLv = 35,
    AlwaysJudgeLvFlag = 0,
    Condition = {1},
    Icon = "views/gift/pic_gift_keju.png",
    showNumber = 11,
    Award = {
      Tili = 0,
      Gold = 0,
      Coin = 50000,
      Silver = 0,
      Huoli = 100,
      BaoShiDu = 0,
      Item = {}
    }
  },
  [10014] = {
    TypeName = "鬼王任务",
    Title = "帮助地藏王收服鬼王,获取经验",
    Desc = "指定完成n次抓鬼任务",
    OpenZs = 0,
    OpenLv = 90,
    AlwaysJudgeLvFlag = 1,
    Condition = {20},
    Icon = "views/gift/pic_gift_zhuagui.png",
    showNumber = 8,
    Award = {
      Tili = 0,
      Gold = 0,
      Coin = 100000,
      Silver = 0,
      Huoli = 50,
      BaoShiDu = 0,
      Item = {}
    }
  },
  [10017] = {
    TypeName = "除魔卫道",
    Title = "清除野外的魔兽,获取经验与材料，获得奖券*1",
    Desc = "指定完成n次挂机地图的战斗",
    OpenZs = 0,
    OpenLv = 25,
    AlwaysJudgeLvFlag = 0,
    Condition = {50},
    Icon = "views/gift/pic_gift_guanqia.png",
    showNumber = 12,
    Award = {
      Tili = 0,
      Gold = 0,
      Coin = 50000,
      Silver = 0,
      Huoli = 200,
      BaoShiDu = 0,
      Item = {
        [93048] = 1
      }
    }
  },
  [10018] = {
    TypeName = "宝图任务",
    Title = "清剿盗贼获取藏宝图",
    Desc = "指定完成宝图任务,获得藏宝图n张",
    OpenZs = 0,
    OpenLv = 24,
    AlwaysJudgeLvFlag = 0,
    Condition = {10},
    Icon = "views/gift/pic_gift_baotu.png",
    showNumber = 7,
    Award = {
      Tili = 0,
      Gold = 0,
      Coin = 200000,
      Silver = 0,
      Huoli = 200,
      BaoShiDu = 0,
      Item = {}
    }
  },
  [10019] = {
    TypeName = "三界历练",
    Title = "完成三界历练,获取珍贵的赤金宝箱",
    Desc = "完成三界历练,获取珍贵的赤金宝箱",
    OpenZs = 0,
    OpenLv = 50,
    AlwaysJudgeLvFlag = 1,
    Condition = {0},
    Icon = "views/gift/pic_gift_ll.png",
    showNumber = 18,
    Award = {
      Tili = 0,
      Gold = 0,
      Coin = 0,
      Silver = 0,
      Huoli = 0,
      BaoShiDu = 0,
      Item = {}
    }
  },
  [10020] = {
    TypeName = "帮派跑商",
    Title = "完成帮派跑商,赚取铜钱与帮派资金",
    Desc = "完成帮派跑商,赚取铜钱与帮派资金",
    OpenZs = 0,
    OpenLv = 30,
    AlwaysJudgeLvFlag = 1,
    Condition = {0},
    Icon = "views/gift/pic_gift_bppx.png",
    showNumber = 19,
    Award = {
      Tili = 0,
      Gold = 0,
      Coin = 0,
      Silver = 0,
      Huoli = 0,
      BaoShiDu = 0,
      Item = {}
    }
  },
  [10021] = {
    TypeName = "帮派任务",
    Title = "完成帮派任务,获得帮派贡献与成就",
    Desc = "完成帮派任务,获得帮派贡献与成就",
    OpenZs = 0,
    OpenLv = 30,
    AlwaysJudgeLvFlag = 1,
    Condition = {0},
    Icon = "views/gift/pic_gift_shimen.png",
    showNumber = 20,
    Award = {
      Tili = 0,
      Gold = 0,
      Coin = 0,
      Silver = 0,
      Huoli = 0,
      BaoShiDu = 0,
      Item = {}
    }
  },
  [10022] = {
    TypeName = "修罗之争",
    Title = "帮助云游法师扫荡修罗一族,获取经验，获得奖券*1",
    Desc = "指定完成n次修罗任务",
    OpenZs = 0,
    OpenLv = 125,
    AlwaysJudgeLvFlag = 1,
    Condition = {20},
    Icon = "views/gift/pic_gift_baotu.png",
    showNumber = 21,
    Award = {
      Tili = 0,
      Gold = 0,
      Coin = 200000,
      Silver = 0,
      Huoli = 0,
      BaoShiDu = 0,
      Item = {
        [93048] = 1
      }
    }
  },
  [11001] = {
    TypeName = "擂台争霸",
    Title = "21:00-21:30,单人称霸擂台就在今晚",
    Desc = "参加擂台争霸获得荣誉点",
    OpenZs = 0,
    OpenLv = 60,
    AlwaysJudgeLvFlag = 1,
    Condition = {1},
    Icon = "views/gift/pic_gift_biwu.png",
    showNumber = 13,
    Award = {
      Tili = 0,
      Gold = 0,
      Coin = 0,
      Silver = 1000,
      Huoli = 0,
      BaoShiDu = 0,
      Item = {}
    }
  },
  [11002] = {
    TypeName = "通天幻境",
    Title = "11:00-23:00,挑战幻境获取技能书",
    Desc = "挑战通天幻境,获取技能书",
    OpenZs = 0,
    OpenLv = 70,
    AlwaysJudgeLvFlag = 1,
    Condition = {0},
    Icon = "views/gift/pic_gift_dayanta.png",
    showNumber = 14,
    Award = {
      Tili = 0,
      Gold = 0,
      Coin = 0,
      Silver = 0,
      Huoli = 0,
      BaoShiDu = 0,
      Item = {
        [93030] = 1
      }
    }
  },
  [11003] = {
    TypeName = "天兵神将",
    Title = "19:30-21:30,挑战各路神将,获取宝物",
    Desc = "挑战各路天兵神将,获取强化物品",
    OpenZs = 0,
    OpenLv = 30,
    AlwaysJudgeLvFlag = 1,
    Condition = {0},
    Icon = "views/gift/pic_gift_guanqia_hard.png",
    showNumber = 17,
    Award = {
      Tili = 0,
      Gold = 0,
      Coin = 0,
      Silver = 0,
      Huoli = 0,
      BaoShiDu = 0,
      Item = {}
    }
  },
  [11004] = {
    TypeName = "一战到底",
    Title = "20:40-22:00,组3人队伍一战到底",
    Desc = "组成你的铁三角势要一战到底",
    OpenZs = 0,
    OpenLv = 65,
    AlwaysJudgeLvFlag = 1,
    Condition = {1},
    Icon = "views/gift/pic_gift_biwu.png",
    showNumber = 15,
    Award = {
      Tili = 0,
      Gold = 0,
      Coin = 0,
      Silver = 1000,
      Huoli = 0,
      BaoShiDu = 0,
      Item = {}
    }
  },
  [11006] = {
    TypeName = "血战沙场",
    Title = "20:55-22:00,组5人队伍血战沙场",
    Desc = "组5人队伍血战沙场",
    OpenZs = 0,
    OpenLv = 65,
    AlwaysJudgeLvFlag = 1,
    Condition = {5},
    Icon = "views/gift/pic_gift_biwu.png",
    showNumber = 16,
    Award = {
      Tili = 0,
      Gold = 0,
      Coin = 0,
      Silver = 1000,
      Huoli = 0,
      BaoShiDu = 0,
      Item = {}
    }
  },
  [11007] = {
    TypeName = "天降宝箱",
    Title = "19:30-20:30,收集天降宝箱",
    Desc = "收集天降宝箱",
    OpenZs = 0,
    OpenLv = 40,
    AlwaysJudgeLvFlag = 1,
    Condition = {0},
    Icon = "views/gift/pic_gift.png",
    showNumber = 22,
    Award = {
      Tili = 0,
      Gold = 0,
      Coin = 0,
      Silver = 0,
      Huoli = 0,
      BaoShiDu = 0,
      Item = {}
    }
  },
  [11008] = {
    TypeName = "天地奇书",
    Title = "19:30-20:40,挑战副本获取技能残卷",
    Desc = "挑战奇书副本获取终极技能残卷",
    OpenZs = 0,
    OpenLv = 80,
    AlwaysJudgeLvFlag = 1,
    Condition = {0},
    Icon = "views/gift/pic_gift_bppx.png",
    showNumber = 23,
    Award = {
      Tili = 0,
      Gold = 0,
      Coin = 0,
      Silver = 0,
      Huoli = 0,
      BaoShiDu = 0,
      Item = {}
    }
  },
  [12001] = {
    TypeName = "屈原的试炼",
    Title = "挑战屈原魂魄,获取霸气称谓:骚气外露",
    Desc = "挑战屈原魂魄,获取霸气称谓",
    OpenZs = 0,
    OpenLv = 0,
    AlwaysJudgeLvFlag = 1,
    Condition = {0},
    Icon = "views/gift/pic_gift_quyuan.png",
    showNumber = 24,
    Award = {
      Tili = 0,
      Gold = 0,
      Coin = 0,
      Silver = 0,
      Huoli = 0,
      BaoShiDu = 0,
      Item = {}
    }
  },
  [12002] = {
    TypeName = "守护嫦娥",
    Title = "中秋节守护嫦娥,获得天灵果",
    Desc = "中秋节守护嫦娥,获得天灵果",
    OpenZs = 0,
    OpenLv = 0,
    AlwaysJudgeLvFlag = 1,
    Condition = {0},
    Icon = "views/gift/pic_gift_biwu.png",
    showNumber = 25,
    Award = {
      Tili = 0,
      Gold = 0,
      Coin = 0,
      Silver = 0,
      Huoli = 0,
      BaoShiDu = 0,
      Item = {}
    }
  }
}

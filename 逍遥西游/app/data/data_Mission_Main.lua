data_Mission_Main = {
  [10001] = {
    mnName = "初入江湖",
    missionDes = "你刚刚来到了异世界，先把自己的能力提升吧！",
    acceptDes = "None",
    needCmp = {0},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 0,
    rewardCoin = 500000,
    rewardGold = 0,
    rewardExp = 60,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 100011,
      param = 0,
      des = "与#<Y,>紫霞仙子#对话"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10002] = {
    mnName = "学习技艺",
    missionDes = "你刚刚来到了异世界，先把自己的能力提升吧！",
    acceptDes = "None",
    needCmp = {10001},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 0,
    rewardCoin = 200,
    rewardGold = 0,
    rewardExp = 985,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 2,
      talkId = 100021,
      param = 0,
      des = "与#<Y,N2,>#对话"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10003] = {
    mnName = "生存之道",
    missionDes = "你刚刚来到了异世界，先把自己的能力提升吧！",
    acceptDes = "None",
    needCmp = {10002},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 1,
    rewardCoin = 200,
    rewardGold = 0,
    rewardExp = 960,
    HelpWinAwardXiaYi = 10,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        1,
        1,
        false
      },
      talkId = 0,
      param = 0,
      des = "赶走在渔村捣乱的#<Y,>老虎#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10004] = {
    mnName = "报告战况",
    missionDes = "你刚刚来到了异世界，先把自己的能力提升吧！",
    acceptDes = "None",
    needCmp = {10003},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 1,
    rewardCoin = 500,
    rewardGold = 0,
    rewardExp = 3000,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {
      {30001, 1}
    },
    dst1 = {
      type = 101,
      data = 2,
      talkId = 100041,
      param = 0,
      des = "回复#<Y,N2,>#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10005] = {
    mnName = "长安铁匠",
    missionDes = "你刚刚来到了异世界，先把自己的能力提升吧！",
    acceptDes = "None",
    needCmp = {10004},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 1,
    rewardCoin = 800,
    rewardGold = 0,
    rewardExp = 5010,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90002,
      talkId = 100051,
      param = 0,
      des = "答谢长安城的#<Y,>铁匠#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10006] = {
    mnName = "村外野兽(1)",
    missionDes = "你刚刚来到了异世界，先把自己的能力提升吧！",
    acceptDes = "None",
    needCmp = {10005},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 1,
    rewardCoin = 1000,
    rewardGold = 0,
    rewardExp = 6000,
    HelpWinAwardXiaYi = 10,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        1,
        2,
        false
      },
      talkId = 0,
      param = 0,
      des = "消灭出现在渔村的#<Y,>老虎#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10007] = {
    mnName = "村外野兽(2)",
    missionDes = "你刚刚来到了异世界，先把自己的能力提升吧！",
    acceptDes = "None",
    needCmp = {10006},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 1,
    rewardCoin = 1400,
    rewardGold = 0,
    rewardExp = 8500,
    HelpWinAwardXiaYi = 10,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        1,
        3,
        false
      },
      talkId = 0,
      param = 0,
      des = "消灭出现在渔村的#<Y,>贪吃熊#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10008] = {
    mnName = "回复仙子",
    missionDes = "你的战斗力已经有了很大的提升了，尝试去获得召唤兽的力量吧！",
    acceptDes = "None",
    needCmp = {10007},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 2,
    rewardCoin = 2400,
    rewardGold = 0,
    rewardExp = 14310,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 100081,
      param = 0,
      des = "回复#<Y,>紫霞仙子#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10009] = {
    mnName = "灵兽",
    missionDes = "你的战斗力已经有了很大的提升了，尝试去获得召唤兽的力量吧！",
    acceptDes = "None",
    needCmp = {10008},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 2,
    rewardCoin = 4700,
    rewardGold = 0,
    rewardExp = 27900,
    HelpWinAwardXiaYi = 10,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        1,
        4,
        false
      },
      talkId = 0,
      param = 0,
      des = "战胜冒冒失失的#<Y,>灵熊#"
    },
    dst2 = {
      type = 101,
      data = 90907,
      talkId = 100092,
      param = 0,
      des = "回复#<Y,>紫霞仙子#"
    }
  },
  [10010] = {
    mnName = "获取召唤兽",
    missionDes = "你的战斗力已经有了很大的提升了，尝试去获得召唤兽的力量吧！",
    acceptDes = "None",
    needCmp = {10009},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 2,
    rewardCoin = 3900,
    rewardGold = 0,
    rewardExp = 23470,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 501,
      data = 114,
      talkId = 0,
      param = 0,
      des = "在召唤兽图鉴中获得#<Y,>灵熊#"
    },
    dst2 = {
      type = 101,
      data = 90907,
      talkId = 0,
      param = 0,
      des = "回复#<Y,>紫霞仙子#"
    }
  },
  [10011] = {
    mnName = "新伙伴",
    missionDes = "快速熟悉你的召唤兽吧",
    acceptDes = "None",
    needCmp = {10010},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 2,
    rewardCoin = 4000,
    rewardGold = 0,
    rewardExp = 24000,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 100101,
      param = 0,
      des = "回复#<Y,>紫霞仙子#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10012] = {
    mnName = "训练灵兽",
    missionDes = "快速熟悉你的召唤兽吧",
    acceptDes = "None",
    needCmp = {10011},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 2,
    rewardCoin = 4000,
    rewardGold = 0,
    rewardExp = 24000,
    HelpWinAwardXiaYi = 10,
    HelpLostAwardXiaYi = 0,
    rewardObj = {
      {2400100, 1}
    },
    dst1 = {
      type = 201,
      data = {
        1,
        5,
        false
      },
      talkId = 0,
      param = 0,
      des = "消灭#<Y,>纹额虎#"
    },
    dst2 = {
      type = 101,
      data = 90907,
      talkId = 100121,
      param = 0,
      des = "回复#<Y,>紫霞仙子#"
    }
  },
  [10013] = {
    mnName = "清扫",
    missionDes = "快速熟悉你的召唤兽吧",
    acceptDes = "None",
    needCmp = {10012},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 2,
    rewardCoin = 4000,
    rewardGold = 0,
    rewardExp = 24000,
    HelpWinAwardXiaYi = 10,
    HelpLostAwardXiaYi = 0,
    rewardObj = {
      {2500100, 1}
    },
    dst1 = {
      type = 201,
      data = {
        1,
        6,
        false
      },
      talkId = 0,
      param = 0,
      des = "赶跑捣乱的#<Y,>灰熊#"
    },
    dst2 = {
      type = 101,
      data = 2,
      talkId = 100141,
      param = 0,
      des = "让#<Y,N2,>#看看你的成长"
    }
  },
  [10014] = {
    mnName = "商人请求",
    missionDes = "长安城的杂货商有事找你，过去查看一番吧。",
    acceptDes = "None",
    needCmp = {10013},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 2,
    rewardCoin = 4800,
    rewardGold = 0,
    rewardExp = 29000,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90908,
      talkId = 100151,
      param = 0,
      des = "询问#<Y,>杂货商#发生了什么事"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10015] = {
    mnName = "采集药材",
    missionDes = "帮助杂货商老板采集草药。",
    acceptDes = "None",
    needCmp = {10014},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 2,
    rewardCoin = 6700,
    rewardGold = 0,
    rewardExp = 40000,
    HelpWinAwardXiaYi = 10,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 202,
      data = {
        1,
        7,
        false
      },
      talkId = 100161,
      param = {
        {
          21001,
          1,
          100
        }
      },
      des = "去#<Y,>双叉岭#收集药草"
    },
    dst2 = {
      type = 402,
      data = 90908,
      talkId = 100162,
      param = {
        {21001, 1}
      },
      des = "将草药交给#<Y,>杂货商#"
    }
  },
  [10016] = {
    mnName = "追随之人",
    missionDes = "None",
    acceptDes = "None",
    needCmp = {10015},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 2,
    rewardCoin = 11200,
    rewardGold = 0,
    rewardExp = 67100,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90915,
      talkId = 100171,
      param = 0,
      des = "寻找长安#<Y,>酒馆老板#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10017] = {
    mnName = "招募伙伴",
    missionDes = "None",
    acceptDes = "None",
    needCmp = {10016},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 2,
    rewardCoin = 10800,
    rewardGold = 0,
    rewardExp = 64800,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 501,
      data = 115,
      talkId = 0,
      param = 0,
      des = "招募一位#<Y,>伙伴#"
    },
    dst2 = {
      type = 101,
      data = 90915,
      talkId = 100181,
      param = 0,
      des = "回复#<Y,>酒馆老板#"
    }
  },
  [10018] = {
    mnName = "邪风所染",
    missionDes = "长安城的程员外遇到了麻烦事，过去看看吧。",
    acceptDes = "None",
    needCmp = {10017},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 2,
    rewardCoin = 10300,
    rewardGold = 0,
    rewardExp = 61800,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90909,
      talkId = 100191,
      param = 0,
      des = "拜访#<Y,>程员外#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10019] = {
    mnName = "清水溪",
    missionDes = "历年平和的渔村里，最近不知道发生了什么事情，原本温顺的动物，都变得很暴躁…",
    acceptDes = "None",
    needCmp = {10018},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 2,
    rewardCoin = 11700,
    rewardGold = 0,
    rewardExp = 70400,
    HelpWinAwardXiaYi = 10,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        1,
        8,
        false
      },
      talkId = 0,
      param = 0,
      des = "消灭出现在路口的#<Y,>赤眼虎#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10020] = {
    mnName = "骨骸地",
    missionDes = "历年平和的渔村里，最近不知道发生了什么事情，原本温顺的动物，都变得很暴躁…",
    acceptDes = "None",
    needCmp = {10019},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 2,
    rewardCoin = 6700,
    rewardGold = 0,
    rewardExp = 39900,
    HelpWinAwardXiaYi = 10,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        1,
        9,
        false
      },
      talkId = 0,
      param = 0,
      des = "打败#<Y,>小药兽#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10021] = {
    mnName = "邪风之源",
    missionDes = "程员外的公子在渔村的老宅中被袭击，去问问他吧，或许能打听得到渔村的变动。",
    acceptDes = "None",
    needCmp = {10020},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 2,
    rewardCoin = 6700,
    rewardGold = 0,
    rewardExp = 39900,
    HelpWinAwardXiaYi = 10,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 202,
      data = {
        1,
        10,
        false
      },
      talkId = 0,
      param = {
        {
          21002,
          1,
          100
        }
      },
      des = "从#<Y,>药统领#身上取得灵草"
    },
    dst2 = {
      type = 402,
      data = 90912,
      talkId = 100222,
      param = {
        {21002, 1}
      },
      des = "将灵草交给#<Y,>程公子#"
    }
  },
  [10022] = {
    mnName = "缘福洞口",
    missionDes = "程员外的公子在渔村的老宅中被袭击，去问问他吧，或许能打听得到渔村的变动。",
    acceptDes = "None",
    needCmp = {10021},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 18,
    rewardCoin = 7500,
    rewardGold = 0,
    rewardExp = 44900,
    HelpWinAwardXiaYi = 10,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        1,
        11,
        false
      },
      talkId = 0,
      param = 0,
      des = "去#<Y,>长安郊外#调查情况"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10023] = {
    mnName = "药池",
    missionDes = "程员外的公子在渔村的老宅中被袭击，去问问他吧，或许能打听得到渔村的变动。",
    acceptDes = "None",
    needCmp = {10022},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 18,
    rewardCoin = 7500,
    rewardGold = 0,
    rewardExp = 44900,
    HelpWinAwardXiaYi = 10,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        1,
        12,
        false
      },
      talkId = 0,
      param = 0,
      des = "消灭出现在#<Y,>长安郊外#的妖怪,引出大妖"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10024] = {
    mnName = "巨虫庭院",
    missionDes = "程员外的公子在渔村的老宅中被袭击，去问问他吧，或许能打听得到渔村的变动。",
    acceptDes = "None",
    needCmp = {10023},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 19,
    rewardCoin = 8400,
    rewardGold = 0,
    rewardExp = 50300,
    HelpWinAwardXiaYi = 10,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        1,
        13,
        false
      },
      talkId = 100251,
      param = 0,
      des = "消灭出现的#<Y,>绿果兽#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10025] = {
    mnName = "深入调查",
    missionDes = "程员外的公子在渔村的老宅中被袭击，去问问他吧，或许能打听得到渔村的变动。",
    acceptDes = "None",
    needCmp = {10024},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 19,
    rewardCoin = 8400,
    rewardGold = 0,
    rewardExp = 50300,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90909,
      talkId = 100261,
      param = 0,
      des = "将调查的情况告知#<Y,>程员外#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10026] = {
    mnName = "找出巢穴",
    missionDes = "听说长安城的药店老板是医王孙思邈的师弟，阅历丰富的他肯定知道些什么，找他聊聊吧。",
    acceptDes = "None",
    needCmp = {10025},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 20,
    rewardCoin = 9400,
    rewardGold = 0,
    rewardExp = 56200,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 90910,
      talkId = 100271,
      param = {
        {21003, 1}
      },
      des = "将情况告诉#<Y,>药店老板#"
    },
    dst2 = {
      type = 401,
      data = {
        4,
        28,
        19
      },
      talkId = 0,
      param = {
        {21003, 1}
      },
      des = "在#<Y,>郊外#使用虫药"
    }
  },
  [10027] = {
    mnName = "报告结果",
    missionDes = "听说长安城的药店老板是医王孙思邈的师弟，阅历丰富的他肯定知道些什么，找他聊聊吧。",
    acceptDes = "None",
    needCmp = {10026},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 20,
    rewardCoin = 9400,
    rewardGold = 0,
    rewardExp = 56200,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90910,
      talkId = 100281,
      param = 0,
      des = "向#<Y,>药店老板#报告情况"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10028] = {
    mnName = "果树林",
    missionDes = "听说长安城的药店老板是医王孙思邈的师弟，阅历丰富的他肯定知道些什么，找他聊聊吧。",
    acceptDes = "None",
    needCmp = {10027},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 20,
    rewardCoin = 10400,
    rewardGold = 0,
    rewardExp = 62400,
    HelpWinAwardXiaYi = 10,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        1,
        14,
        false
      },
      talkId = 0,
      param = 0,
      des = "消灭拦路的#<Y,>绿果兽#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10029] = {
    mnName = "异果园",
    missionDes = "听说长安城的药店老板是医王孙思邈的师弟，阅历丰富的他肯定知道些什么，找他聊聊吧。",
    acceptDes = "None",
    needCmp = {10028},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 20,
    rewardCoin = 10400,
    rewardGold = 0,
    rewardExp = 62400,
    HelpWinAwardXiaYi = 10,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        1,
        15,
        false
      },
      talkId = 0,
      param = 0,
      des = "消灭拦路的#<Y,>枯叶虫#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10030] = {
    mnName = "清剿妖虫",
    missionDes = "听说长安城的药店老板是医王孙思邈的师弟，阅历丰富的他肯定知道些什么，找他聊聊吧。",
    acceptDes = "None",
    needCmp = {10029},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 20,
    rewardCoin = 11500,
    rewardGold = 0,
    rewardExp = 69000,
    HelpWinAwardXiaYi = 10,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        1,
        16,
        false
      },
      talkId = 100311,
      param = 0,
      des = "剿灭#<Y,>灯火虫#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10031] = {
    mnName = "再会仙子",
    missionDes = "邪魔的力量越来越强大了，连远离尘世的渔村都被侵蚀，赶紧把渔村的情况告诉仙子吧。",
    acceptDes = "None",
    needCmp = {10030},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 20,
    rewardCoin = 11500,
    rewardGold = 0,
    rewardExp = 69000,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 100321,
      param = 0,
      des = "将所发生的事情告知#<Y,>紫霞仙子#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10032] = {
    mnName = "消灭幼虫",
    missionDes = "邪魔的力量越来越强大了，连远离尘世的渔村都被侵蚀，赶紧把渔村的情况告诉仙子吧。",
    acceptDes = "None",
    needCmp = {10031},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 20,
    rewardCoin = 12700,
    rewardGold = 0,
    rewardExp = 76100,
    HelpWinAwardXiaYi = 10,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        1,
        17,
        false
      },
      talkId = 100331,
      param = 0,
      des = "继续清理巢穴里面的#<Y,>妖虫#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10033] = {
    mnName = "妖兽拦截",
    missionDes = "邪魔的力量越来越强大了，连远离尘世的渔村都被侵蚀，赶紧把渔村的情况告诉仙子吧。",
    acceptDes = "None",
    needCmp = {10032},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 20,
    rewardCoin = 12700,
    rewardGold = 0,
    rewardExp = 76100,
    HelpWinAwardXiaYi = 10,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        1,
        18,
        false
      },
      talkId = 0,
      param = 0,
      des = "打败阻拦你去路的#<Y,>跳跳熊#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10034] = {
    mnName = "新的旅程",
    missionDes = "大雁塔中封印诛魔的经文被无天魔罗卷走一半，造成塔中封印减弱，如果不及时补救，群魔将会破印而出。问问法师，是否准备好西行取经。",
    acceptDes = "None",
    needCmp = {10033},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 20,
    rewardCoin = 12700,
    rewardGold = 0,
    rewardExp = 76100,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 100351,
      param = 0,
      des = "回复#<Y,>紫霞仙子#幼虫已灭的消息"
    },
    dst2 = {
      type = 101,
      data = 90911,
      talkId = 100352,
      param = 0,
      des = "去#<Y,>码头#寻找三藏法师"
    }
  },
  [10035] = {
    mnName = "教训(1称)",
    missionDes = "大雁塔中封印诛魔的经文被无天魔罗卷走一半，造成塔中封印减弱，如果不及时补救，群魔将会破印而出。问问法师，是否准备好西行取经。",
    acceptDes = "None",
    needCmp = {10034},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 20,
    rewardCoin = 12700,
    rewardGold = 0,
    rewardExp = 76100,
    HelpWinAwardXiaYi = 210,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        1,
        19,
        false
      },
      talkId = 0,
      param = 0,
      des = "教训#<Y,>渔村#出现的灵兽(建议组队前往)"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10036] = {
    mnName = "噩梦缠绕(1称)",
    missionDes = "得知身世的法师一直心绪不宁，为父母报仇的心愿充斥着法师的内心。被仇恨充满内心的法师知道此时非担大任之时。得知现状的你决定帮助法师解开心结。",
    acceptDes = "None",
    needCmp = {10035},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 20,
    rewardCoin = 13500,
    rewardGold = 0,
    rewardExp = 81000,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {
      {30043, 1}
    },
    dst1 = {
      type = 101,
      data = 90911,
      talkId = 100371,
      param = 0,
      des = "询问#<Y,>三藏法师#是否西行取经"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10201] = {
    mnName = "身世调查",
    missionDes = "得知身世的法师一直心绪不宁，为父母报仇的心愿充斥着法师的内心。被仇恨充满内心的法师知道此时非担大任之时。得知现状的你决定帮助法师解开心结。",
    acceptDes = "None",
    needCmp = {10036},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 25,
    rewardCoin = 2500,
    rewardGold = 0,
    rewardExp = 15124,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 102011,
      param = 0,
      des = "将情况告知#<Y,>紫霞仙子#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10202] = {
    mnName = "地府鬼将",
    missionDes = "得知身世的法师一直心绪不宁，为父母报仇的心愿充斥着法师的内心。被仇恨充满内心的法师知道此时非担大任之时。得知现状的你决定帮助法师解开心结。",
    acceptDes = "None",
    needCmp = {10201},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 25,
    rewardCoin = 2500,
    rewardGold = 0,
    rewardExp = 15124,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90916,
      talkId = 102021,
      param = 0,
      des = "向#<Y,>鬼将#打听陈光蕊的事情"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10203] = {
    mnName = "捉拿鬼魂(1)",
    missionDes = "得知身世的法师一直心绪不宁，为父母报仇的心愿充斥着法师的内心。被仇恨充满内心的法师知道此时非担大任之时。得知现状的你决定帮助法师解开心结。",
    acceptDes = "None",
    needCmp = {10202},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 25,
    rewardCoin = 6300,
    rewardGold = 0,
    rewardExp = 37810,
    HelpWinAwardXiaYi = 20,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        2,
        1,
        false
      },
      talkId = 102031,
      param = 0,
      des = "追捕逃至长安城的#<Y,>游魂野鬼#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10204] = {
    mnName = "捉拿鬼魂(2)",
    missionDes = "得知身世的法师一直心绪不宁，为父母报仇的心愿充斥着法师的内心。被仇恨充满内心的法师知道此时非担大任之时。得知现状的你决定帮助法师解开心结。",
    acceptDes = "None",
    needCmp = {10203},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 25,
    rewardCoin = 6300,
    rewardGold = 0,
    rewardExp = 37810,
    HelpWinAwardXiaYi = 20,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        2,
        2,
        false
      },
      talkId = 0,
      param = 0,
      des = "追捕逃至长安郊外的#<Y,>游魂野鬼#"
    },
    dst2 = {
      type = 101,
      data = 90916,
      talkId = 102051,
      param = 0,
      des = "回复#<Y,>鬼将#"
    }
  },
  [10205] = {
    mnName = "回复仙子",
    missionDes = "得知身世的法师一直心绪不宁，为父母报仇的心愿充斥着法师的内心。被仇恨充满内心的法师知道此时非担大任之时。得知现状的你决定帮助法师解开心结。",
    acceptDes = "None",
    needCmp = {10204},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 26,
    rewardCoin = 2600,
    rewardGold = 0,
    rewardExp = 15735,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 102061,
      param = 0,
      des = "回复#<Y,>紫霞仙子#调查结果"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10206] = {
    mnName = "原由",
    missionDes = "魔王寨里面住着一窝强盗，他们仗着魔王寨山高险峻，易守难攻，整日做着打家劫舍的事情。这不，长安城的杂货老板就遭了罪，一车货全部被那伙强盗给劫走...",
    acceptDes = "None",
    needCmp = {10205},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 26,
    rewardCoin = 2600,
    rewardGold = 0,
    rewardExp = 15735,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90908,
      talkId = 102071,
      param = 0,
      des = "询问#<Y,>杂货商#发生了什么事"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10207] = {
    mnName = "追踪物资",
    missionDes = "魔王寨里面住着一窝强盗，他们仗着魔王寨山高险峻，易守难攻，整日做着打家劫舍的事情。这不，长安城的杂货老板就遭了罪，一车货全部被那伙强盗给劫走...",
    acceptDes = "None",
    needCmp = {10206},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 26,
    rewardCoin = 6600,
    rewardGold = 0,
    rewardExp = 39339,
    HelpWinAwardXiaYi = 20,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 202,
      data = {
        2,
        3,
        false
      },
      talkId = 0,
      param = {
        {
          21006,
          1,
          100
        }
      },
      des = "从抢劫犯身上夺得#<Y,>地图#"
    },
    dst2 = {
      type = 402,
      data = 90917,
      talkId = 102091,
      param = {
        {21006, 1}
      },
      des = "将地图交给熟悉地形的#<Y,>长安居民#"
    }
  },
  [10208] = {
    mnName = "地图",
    missionDes = "魔王寨里面住着一窝强盗，他们仗着魔王寨山高险峻，易守难攻，整日做着打家劫舍的事情。这不，长安城的杂货老板就遭了罪，一车货全部被那伙强盗给劫走...",
    acceptDes = "None",
    needCmp = {10207},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 27,
    rewardCoin = 2700,
    rewardGold = 0,
    rewardExp = 16357,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90917,
      talkId = 102092,
      param = 0,
      des = "继续与#<Y,>长安居民#对话"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10209] = {
    mnName = "第二个哨点",
    missionDes = "魔王寨里面住着一窝强盗，他们仗着魔王寨山高险峻，易守难攻，整日做着打家劫舍的事情。这不，长安城的杂货老板就遭了罪，一车货全部被那伙强盗给劫走...",
    acceptDes = "None",
    needCmp = {10208},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 27,
    rewardCoin = 6800,
    rewardGold = 0,
    rewardExp = 40893,
    HelpWinAwardXiaYi = 20,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        2,
        4,
        false
      },
      talkId = 102101,
      param = 0,
      des = "清理第二个哨点的#<Y,>暴徒#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10210] = {
    mnName = "第三个哨点",
    missionDes = "魔王寨里面住着一窝强盗，他们仗着魔王寨山高险峻，易守难攻，整日做着打家劫舍的事情。这不，长安城的杂货老板就遭了罪，一车货全部被那伙强盗给劫走...",
    acceptDes = "None",
    needCmp = {10209},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 27,
    rewardCoin = 6800,
    rewardGold = 0,
    rewardExp = 40893,
    HelpWinAwardXiaYi = 20,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        2,
        5,
        false
      },
      talkId = 102111,
      param = 0,
      des = "清理第三个哨点的#<Y,>恶棍#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10211] = {
    mnName = "继续追查",
    missionDes = "魔王寨里面住着一窝强盗，他们仗着魔王寨山高险峻，易守难攻，整日做着打家劫舍的事情。这不，长安城的杂货老板就遭了罪，一车货全部被那伙强盗给劫走...",
    acceptDes = "None",
    needCmp = {10210},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 27,
    rewardCoin = 6800,
    rewardGold = 0,
    rewardExp = 40893,
    HelpWinAwardXiaYi = 20,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        2,
        6,
        false
      },
      talkId = 102121,
      param = 0,
      des = "从#<Y,>劫匪#口中打听货物消息"
    },
    dst2 = {
      type = 101,
      data = 90908,
      talkId = 102122,
      param = 0,
      des = "将货物消息告知#<Y,>杂货商#"
    }
  },
  [10212] = {
    mnName = "扫荡魔王寨(1)",
    missionDes = "魔王寨里面住着一窝强盗，他们仗着魔王寨山高险峻，易守难攻，整日做着打家劫舍的事情。这不，长安城的杂货老板就遭了罪，一车货全部被那伙强盗给劫走...",
    acceptDes = "None",
    needCmp = {10211},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 27,
    rewardCoin = 6800,
    rewardGold = 0,
    rewardExp = 40893,
    HelpWinAwardXiaYi = 20,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        2,
        7,
        false
      },
      talkId = 0,
      param = 0,
      des = "清除魔王寨的#<Y,>独眼龙#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10213] = {
    mnName = "扫荡魔王寨(2)",
    missionDes = "魔王寨里面住着一窝强盗，他们仗着魔王寨山高险峻，易守难攻，整日做着打家劫舍的事情。这不，长安城的杂货老板就遭了罪，一车货全部被那伙强盗给劫走...",
    acceptDes = "None",
    needCmp = {10212},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 27,
    rewardCoin = 6800,
    rewardGold = 0,
    rewardExp = 40893,
    HelpWinAwardXiaYi = 20,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        2,
        8,
        false
      },
      talkId = 0,
      param = 0,
      des = "清除魔王寨的#<Y,>山贼#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10214] = {
    mnName = "夺回物资",
    missionDes = "魔王寨里面住着一窝强盗，他们仗着魔王寨山高险峻，易守难攻，整日做着打家劫舍的事情。这不，长安城的杂货老板就遭了罪，一车货全部被那伙强盗给劫走...",
    acceptDes = "None",
    needCmp = {10213},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 27,
    rewardCoin = 6800,
    rewardGold = 0,
    rewardExp = 40893,
    HelpWinAwardXiaYi = 20,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 202,
      data = {
        2,
        9,
        false
      },
      talkId = 0,
      param = {
        {
          21007,
          1,
          100
        }
      },
      des = "从强盗头目刘全手中夺回#<Y,>物资#"
    },
    dst2 = {
      type = 402,
      data = 90908,
      talkId = 102152,
      param = {
        {21007, 1}
      },
      des = "将#<Y,>包裹#交还杂货商"
    }
  },
  [10215] = {
    mnName = "上古奇物",
    missionDes = "魔王寨里面住着一窝强盗，他们仗着魔王寨山高险峻，易守难攻，整日做着打家劫舍的事情。这不，长安城的杂货老板就遭了罪，一车货全部被那伙强盗给劫走...",
    acceptDes = "None",
    needCmp = {10214},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 28,
    rewardCoin = 2800,
    rewardGold = 0,
    rewardExp = 16989,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {
      {91000, 1}
    },
    dst1 = {
      type = 101,
      data = 90908,
      talkId = 102161,
      param = 0,
      des = "答谢#<Y,>杂货商老板#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10216] = {
    mnName = "回复仙子",
    missionDes = "魔王寨里面住着一窝强盗，他们仗着魔王寨山高险峻，易守难攻，整日做着打家劫舍的事情。这不，长安城的杂货老板就遭了罪，一车货全部被那伙强盗给劫走...",
    acceptDes = "None",
    needCmp = {10215},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 28,
    rewardCoin = 2800,
    rewardGold = 0,
    rewardExp = 16989,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 102162,
      param = 0,
      des = "向#<Y,>紫霞仙子#请教上古奇物"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10217] = {
    mnName = "父子见面",
    missionDes = "善有善报，法师父亲陈光蕊的善举，获得了龙王的帮助，使他还了阳。与父亲见面后的法师心中郁结已减大半。法师希望你能继续帮助他，替他救回母亲，彻底解开心结。",
    acceptDes = "None",
    needCmp = {10216},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 28,
    rewardCoin = 2800,
    rewardGold = 0,
    rewardExp = 16989,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 102171,
      param = 0,
      des = "继续与#<Y,>紫霞仙子#对话"
    },
    dst2 = {
      type = 101,
      data = 90918,
      talkId = 102172,
      param = 0,
      des = "探望#<Y,>三藏法师#父子"
    }
  },
  [10218] = {
    mnName = "藏污纳垢(1)",
    missionDes = "善有善报，法师父亲陈光蕊的善举，获得了龙王的帮助，使他还了阳。与父亲见面后的法师心中郁结已减大半。法师希望你能继续帮助他，替他救回母亲，彻底解开心结。",
    acceptDes = "None",
    needCmp = {10217},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 28,
    rewardCoin = 7100,
    rewardGold = 0,
    rewardExp = 42473,
    HelpWinAwardXiaYi = 20,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        2,
        10,
        false
      },
      talkId = 0,
      param = 0,
      des = "打败郊外的#<Y,>恶棍#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10219] = {
    mnName = "藏污纳垢(2)",
    missionDes = "善有善报，法师父亲陈光蕊的善举，获得了龙王的帮助，使他还了阳。与父亲见面后的法师心中郁结已减大半。法师希望你能继续帮助他，替他救回母亲，彻底解开心结。",
    acceptDes = "None",
    needCmp = {10218},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 28,
    rewardCoin = 7100,
    rewardGold = 0,
    rewardExp = 42473,
    HelpWinAwardXiaYi = 20,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        2,
        11,
        false
      },
      talkId = 0,
      param = 0,
      des = "消灭#<Y,>独眼龙#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10220] = {
    mnName = "解救生母",
    missionDes = "善有善报，法师父亲陈光蕊的善举，获得了龙王的帮助，使他还了阳。与父亲见面后的法师心中郁结已减大半。法师希望你能继续帮助他，替他救回母亲，彻底解开心结。",
    acceptDes = "None",
    needCmp = {10219},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 28,
    rewardCoin = 7100,
    rewardGold = 0,
    rewardExp = 42473,
    HelpWinAwardXiaYi = 20,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        2,
        12,
        false
      },
      talkId = 102211,
      param = 0,
      des = "铲除冒牌知府#<Y,>刘洪#,救出法师生母"
    },
    dst2 = {
      type = 101,
      data = 90918,
      talkId = 102212,
      param = 0,
      des = "回复#<Y,>三藏法师#"
    }
  },
  [10221] = {
    mnName = "殷温娇的委托",
    missionDes = "善有善报，法师父亲陈光蕊的善举，获得了龙王的帮助，使他还了阳。与父亲见面后的法师心中郁结已减大半。法师希望你能继续帮助他，替他救回母亲，彻底解开心结。",
    acceptDes = "None",
    needCmp = {10220},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 28,
    rewardCoin = 2800,
    rewardGold = 0,
    rewardExp = 16989,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90920,
      talkId = 102213,
      param = 0,
      des = "与#<Y,>殷温娇#对话"
    },
    dst2 = {
      type = 201,
      data = {
        2,
        13,
        false
      },
      talkId = 102221,
      wftalkId = 102222,
      param = 0,
      des = "从暴徒口中打听#<Y,>李彪#的下落"
    }
  },
  [10222] = {
    mnName = "搜查天水河",
    missionDes = "善有善报，法师父亲陈光蕊的善举，获得了龙王的帮助，使他还了阳。与父亲见面后的法师心中郁结已减大半。法师希望你能继续帮助他，替他救回母亲，彻底解开心结。",
    acceptDes = "None",
    needCmp = {10221},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 28,
    rewardCoin = 7100,
    rewardGold = 0,
    rewardExp = 42473,
    HelpWinAwardXiaYi = 20,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        2,
        14,
        false
      },
      talkId = 0,
      param = 0,
      des = "搜查#<Y,>天水河#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10223] = {
    mnName = "铲除恶人",
    missionDes = "善有善报，法师父亲陈光蕊的善举，获得了龙王的帮助，使他还了阳。与父亲见面后的法师心中郁结已减大半。法师希望你能继续帮助他，替他救回母亲，彻底解开心结。",
    acceptDes = "None",
    needCmp = {10222},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 28,
    rewardCoin = 7100,
    rewardGold = 0,
    rewardExp = 42473,
    HelpWinAwardXiaYi = 20,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        2,
        15,
        false
      },
      talkId = 102241,
      param = 0,
      des = "铲除流寇头目#<Y,>李彪#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10224] = {
    mnName = "解开心结",
    missionDes = "善有善报，法师父亲陈光蕊的善举，获得了龙王的帮助，使他还了阳。与父亲见面后的法师心中郁结已减大半。法师希望你能继续帮助他，替他救回母亲，彻底解开心结。",
    acceptDes = "None",
    needCmp = {10223},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 29,
    rewardCoin = 2900,
    rewardGold = 0,
    rewardExp = 17632,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90920,
      talkId = 102251,
      param = 0,
      des = "回复#<Y,>殷温娇#"
    },
    dst2 = {
      type = 101,
      data = 90918,
      talkId = 102252,
      param = 0,
      des = "询问#<Y,>三藏法师#心结是否解开"
    }
  },
  [10225] = {
    mnName = "酒馆异闻",
    missionDes = "酒馆老板的传家宝不见了，一切种种可疑迹象均指向了前晚来喝酒的一对夫妇。酒馆老板希望你能帮他寻回传家宝。",
    acceptDes = "None",
    needCmp = {10224},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 29,
    rewardCoin = 2900,
    rewardGold = 0,
    rewardExp = 17632,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 102261,
      param = 0,
      des = "回复#<Y,>紫霞仙子#"
    },
    dst2 = {
      type = 101,
      data = 90915,
      talkId = 102262,
      param = 0,
      des = "询问#<Y,>酒馆老板#发生何事"
    }
  },
  [10226] = {
    mnName = "打听线索",
    missionDes = "酒馆老板的传家宝不见了，一切种种可疑迹象均指向了前晚来喝酒的一对夫妇。酒馆老板希望你能帮他寻回传家宝。",
    acceptDes = "None",
    needCmp = {10225},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 29,
    rewardCoin = 2900,
    rewardGold = 0,
    rewardExp = 17632,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90929,
      talkId = 102271,
      param = 0,
      des = "向#<Y,>更夫#打探消息"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10227] = {
    mnName = "沿路追踪",
    missionDes = "酒馆老板的传家宝不见了，一切种种可疑迹象均指向了前晚来喝酒的一对夫妇。酒馆老板希望你能帮他寻回传家宝。",
    acceptDes = "None",
    needCmp = {10226},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 29,
    rewardCoin = 7300,
    rewardGold = 0,
    rewardExp = 44081,
    HelpWinAwardXiaYi = 20,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        2,
        16,
        false
      },
      talkId = 0,
      param = 0,
      des = "沿着#<Y,>城西#一路调查"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10228] = {
    mnName = "继续追踪",
    missionDes = "酒馆老板的传家宝不见了，一切种种可疑迹象均指向了前晚来喝酒的一对夫妇。酒馆老板希望你能帮他寻回传家宝。",
    acceptDes = "None",
    needCmp = {10227},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 29,
    rewardCoin = 7300,
    rewardGold = 0,
    rewardExp = 44081,
    HelpWinAwardXiaYi = 20,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        2,
        17,
        false
      },
      talkId = 0,
      param = 0,
      des = "继续沿着#<Y,>西路#一路调查"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10229] = {
    mnName = "香气迷踪",
    missionDes = "酒馆老板的传家宝不见了，一切种种可疑迹象均指向了前晚来喝酒的一对夫妇。酒馆老板希望你能帮他寻回传家宝。",
    acceptDes = "None",
    needCmp = {10228},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 29,
    rewardCoin = 7300,
    rewardGold = 0,
    rewardExp = 44081,
    HelpWinAwardXiaYi = 20,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        2,
        18,
        false
      },
      talkId = 102281,
      param = 0,
      des = "打败被妖气附体的#<Y,>百姓#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10230] = {
    mnName = "宝物下落",
    missionDes = "酒馆老板的传家宝不见了，一切种种可疑迹象均指向了前晚来喝酒的一对夫妇。酒馆老板希望你能帮他寻回传家宝。",
    acceptDes = "None",
    needCmp = {10229},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 30,
    rewardCoin = 7600,
    rewardGold = 0,
    rewardExp = 45718,
    HelpWinAwardXiaYi = 20,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        2,
        19,
        false
      },
      talkId = 102291,
      wftalkId = 102292,
      param = 0,
      des = "打探#<Y,>传家宝#下落"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10231] = {
    mnName = "回复消息",
    missionDes = "酒馆老板的传家宝不见了，一切种种可疑迹象均指向了前晚来喝酒的一对夫妇。酒馆老板希望你能帮他寻回传家宝。",
    acceptDes = "None",
    needCmp = {10230},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 30,
    rewardCoin = 3000,
    rewardGold = 0,
    rewardExp = 18287,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90915,
      talkId = 102301,
      param = 0,
      des = "与#<Y,>酒馆老板#对话"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10232] = {
    mnName = "猪妖拦截",
    missionDes = "酒馆老板的传家宝不见了，一切种种可疑迹象均指向了前晚来喝酒的一对夫妇。酒馆老板希望你能帮他寻回传家宝。",
    acceptDes = "None",
    needCmp = {10231},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 30,
    rewardCoin = 7600,
    rewardGold = 0,
    rewardExp = 45718,
    HelpWinAwardXiaYi = 20,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        2,
        20,
        false
      },
      talkId = 0,
      param = 0,
      des = "消灭妖怪手下#<Y,>猪怪#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10233] = {
    mnName = "清理妖和尚",
    missionDes = "酒馆老板的传家宝不见了，一切种种可疑迹象均指向了前晚来喝酒的一对夫妇。酒馆老板希望你能帮他寻回传家宝。",
    acceptDes = "None",
    needCmp = {10232},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 30,
    rewardCoin = 7600,
    rewardGold = 0,
    rewardExp = 45718,
    HelpWinAwardXiaYi = 20,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        2,
        21,
        false
      },
      talkId = 0,
      param = 0,
      des = "消灭拦截你的#<Y,>妖怪和尚#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10234] = {
    mnName = "传家之宝(2称)",
    missionDes = "酒馆老板的传家宝不见了，一切种种可疑迹象均指向了前晚来喝酒的一对夫妇。酒馆老板希望你能帮他寻回传家宝。",
    acceptDes = "None",
    needCmp = {10233},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 30,
    rewardCoin = 7600,
    rewardGold = 0,
    rewardExp = 45718,
    HelpWinAwardXiaYi = 220,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 202,
      data = {
        2,
        22,
        false
      },
      talkId = 0,
      param = {
        {
          21040,
          1,
          100
        }
      },
      des = "夺回被偷走的#<Y,>传家宝#(建议组队前往)"
    },
    dst2 = {
      type = 402,
      data = 90915,
      talkId = 102332,
      param = {
        {21040, 1}
      },
      des = "将石块交还给#<Y,>酒馆老板#"
    }
  },
  [10301] = {
    mnName = "着急的衙役",
    missionDes = "长安城近日频频出现珍稀物品失窃现象，这让当今天子十分震怒，遂降旨限令捕快们三日内破案。衙役查到此次失窃案件不是人为，这与无天魔罗有没有关系呢。紫霞仙子要你查明此事。",
    acceptDes = "None",
    needCmp = {10234},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 30,
    rewardCoin = 3000,
    rewardGold = 0,
    rewardExp = 18287,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 103011,
      param = 0,
      des = "与#<Y,>紫霞仙子#对话"
    },
    dst2 = {
      type = 101,
      data = 90921,
      talkId = 103012,
      param = 0,
      des = "向#<Y,>衙役#打听消息"
    }
  },
  [10302] = {
    mnName = "墨村村长",
    missionDes = "长安城近日频频出现珍稀物品失窃现象，这让当今天子十分震怒，遂降旨限令捕快们三日内破案。衙役查到此次失窃案件不是人为，这与无天魔罗有没有关系呢。紫霞仙子要你查明此事。",
    acceptDes = "None",
    needCmp = {10301},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 30,
    rewardCoin = 3000,
    rewardGold = 0,
    rewardExp = 18287,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90930,
      talkId = 103021,
      param = 0,
      des = "与#<Y,>衙役#对话"
    },
    dst2 = {
      type = 101,
      data = 90922,
      talkId = 103022,
      param = 0,
      des = "向#<Y,>墨村村长#打听情况"
    }
  },
  [10303] = {
    mnName = "村长的考验",
    missionDes = "长安城近日频频出现珍稀物品失窃现象，这让当今天子十分震怒，遂降旨限令捕快们三日内破案。衙役查到此次失窃案件不是人为，这与无天魔罗有没有关系呢。紫霞仙子要你查明此事。",
    acceptDes = "None",
    needCmp = {10302},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 30,
    rewardCoin = 7600,
    rewardGold = 0,
    rewardExp = 45718,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        3,
        1,
        false
      },
      talkId = 0,
      param = 0,
      des = "帮助墨老探查#<Y,>树林#中的情况"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10304] = {
    mnName = "妖怪的消息",
    missionDes = "长安城近日频频出现珍稀物品失窃现象，这让当今天子十分震怒，遂降旨限令捕快们三日内破案。衙役查到此次失窃案件不是人为，这与无天魔罗有没有关系呢。紫霞仙子要你查明此事。",
    acceptDes = "None",
    needCmp = {10303},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 30,
    rewardCoin = 3000,
    rewardGold = 0,
    rewardExp = 18287,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90922,
      talkId = 103041,
      param = 0,
      des = "回复#<Y,>墨村村长#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10305] = {
    mnName = "巡路妖",
    missionDes = "长安城近日频频出现珍稀物品失窃现象，这让当今天子十分震怒，遂降旨限令捕快们三日内破案。衙役查到此次失窃案件不是人为，这与无天魔罗有没有关系呢。紫霞仙子要你查明此事。",
    acceptDes = "None",
    needCmp = {10304},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 33,
    rewardCoin = 8500,
    rewardGold = 0,
    rewardExp = 50815,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        3,
        2,
        false
      },
      talkId = 103051,
      param = 0,
      des = "帮助墨老调查村中情况"
    },
    dst2 = {
      type = 101,
      data = 90922,
      talkId = 103052,
      param = 0,
      des = "向#<Y,>村长#交付任务"
    }
  },
  [10306] = {
    mnName = "双叉寻人(1)",
    missionDes = "长安城近日频频出现珍稀物品失窃现象，这让当今天子十分震怒，遂降旨限令捕快们三日内破案。衙役查到此次失窃案件不是人为，这与无天魔罗有没有关系呢。紫霞仙子要你查明此事。",
    acceptDes = "None",
    needCmp = {10305},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 33,
    rewardCoin = 8500,
    rewardGold = 0,
    rewardExp = 50815,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        3,
        3,
        false
      },
      talkId = 0,
      param = 0,
      des = "消灭#<Y,>石路口#出现的妖怪"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10307] = {
    mnName = "妖怪迷阵",
    missionDes = "长安城近日频频出现珍稀物品失窃现象，这让当今天子十分震怒，遂降旨限令捕快们三日内破案。衙役查到此次失窃案件不是人为，这与无天魔罗有没有关系呢。紫霞仙子要你查明此事。",
    acceptDes = "None",
    needCmp = {10306},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 33,
    rewardCoin = 8500,
    rewardGold = 0,
    rewardExp = 50815,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        3,
        4,
        false
      },
      talkId = 0,
      param = 0,
      des = "消灭#<Y,>跨天桥#出现的妖怪"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10308] = {
    mnName = "双叉寻人(2)",
    missionDes = "长安城近日频频出现珍稀物品失窃现象，这让当今天子十分震怒，遂降旨限令捕快们三日内破案。衙役查到此次失窃案件不是人为，这与无天魔罗有没有关系呢。紫霞仙子要你查明此事。",
    acceptDes = "None",
    needCmp = {10307},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 33,
    rewardCoin = 8500,
    rewardGold = 0,
    rewardExp = 50815,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        3,
        5,
        false
      },
      talkId = 103081,
      param = 0,
      des = "从#<Y,>落水鬼#口中打探廖四郎消息"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10309] = {
    mnName = "负伤农夫",
    missionDes = "长安城近日频频出现珍稀物品失窃现象，这让当今天子十分震怒，遂降旨限令捕快们三日内破案。衙役查到此次失窃案件不是人为，这与无天魔罗有没有关系呢。紫霞仙子要你查明此事。",
    acceptDes = "None",
    needCmp = {10308},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 33,
    rewardCoin = 3400,
    rewardGold = 0,
    rewardExp = 20326,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90923,
      talkId = 103091,
      param = 0,
      des = "听听#<Y,>廖四郎#说些什么"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10310] = {
    mnName = "扫荡山岭(1)",
    missionDes = "长安城近日频频出现珍稀物品失窃现象，这让当今天子十分震怒，遂降旨限令捕快们三日内破案。衙役查到此次失窃案件不是人为，这与无天魔罗有没有关系呢。紫霞仙子要你查明此事。",
    acceptDes = "None",
    needCmp = {10309},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 36,
    rewardCoin = 9400,
    rewardGold = 0,
    rewardExp = 56212,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        3,
        6,
        false
      },
      talkId = 0,
      param = 0,
      des = "帮助#<Y,>廖四郎#清理岭上的妖怪"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10311] = {
    mnName = "扫荡山岭(2)",
    missionDes = "长安城近日频频出现珍稀物品失窃现象，这让当今天子十分震怒，遂降旨限令捕快们三日内破案。衙役查到此次失窃案件不是人为，这与无天魔罗有没有关系呢。紫霞仙子要你查明此事。",
    acceptDes = "None",
    needCmp = {10310},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 36,
    rewardCoin = 9400,
    rewardGold = 0,
    rewardExp = 56212,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        3,
        7,
        false
      },
      talkId = 103101,
      param = 0,
      des = "帮助#<Y,>廖四郎#清理岭上的妖怪"
    },
    dst2 = {
      type = 101,
      data = 90923,
      talkId = 103102,
      param = 0,
      des = "向#<Y,>廖四郎#复命"
    }
  },
  [10312] = {
    mnName = "为民除害",
    missionDes = "长安城近日频频出现珍稀物品失窃现象，这让当今天子十分震怒，遂降旨限令捕快们三日内破案。衙役查到此次失窃案件不是人为，这与无天魔罗有没有关系呢。紫霞仙子要你查明此事。",
    acceptDes = "None",
    needCmp = {10311},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 36,
    rewardCoin = 9400,
    rewardGold = 0,
    rewardExp = 56212,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        3,
        8,
        false
      },
      talkId = 103121,
      wftalkId = 103122,
      param = 0,
      des = "深入魔王窟消灭#<Y,>妖怪头目#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10313] = {
    mnName = "破阵(1)",
    missionDes = "长安城近日频频出现珍稀物品失窃现象，这让当今天子十分震怒，遂降旨限令捕快们三日内破案。衙役查到此次失窃案件不是人为，这与无天魔罗有没有关系呢。紫霞仙子要你查明此事。",
    acceptDes = "None",
    needCmp = {10312},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 39,
    rewardCoin = 10300,
    rewardGold = 0,
    rewardExp = 61940,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        3,
        9,
        false
      },
      talkId = 0,
      param = 0,
      des = "消灭阵法小妖#<Y,>野鬼#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10314] = {
    mnName = "破阵(2)",
    missionDes = "长安城近日频频出现珍稀物品失窃现象，这让当今天子十分震怒，遂降旨限令捕快们三日内破案。衙役查到此次失窃案件不是人为，这与无天魔罗有没有关系呢。紫霞仙子要你查明此事。",
    acceptDes = "None",
    needCmp = {10313},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 39,
    rewardCoin = 10300,
    rewardGold = 0,
    rewardExp = 61940,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        3,
        10,
        false
      },
      talkId = 0,
      param = 0,
      des = "消灭阵法小妖#<Y,>野牛精#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10315] = {
    mnName = "破阵(3)",
    missionDes = "长安城近日频频出现珍稀物品失窃现象，这让当今天子十分震怒，遂降旨限令捕快们三日内破案。衙役查到此次失窃案件不是人为，这与无天魔罗有没有关系呢。紫霞仙子要你查明此事。",
    acceptDes = "None",
    needCmp = {10314},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 39,
    rewardCoin = 10300,
    rewardGold = 0,
    rewardExp = 61940,
    HelpWinAwardXiaYi = 255,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        3,
        11,
        false
      },
      talkId = 103151,
      param = 0,
      des = "破坏#<Y,>聚灵阵法#(建议组队前往)"
    },
    dst2 = {
      type = 101,
      data = 90921,
      talkId = 103152,
      param = 0,
      des = "将魔王窟发生的事情告诉#<Y,>衙役#"
    }
  },
  [10316] = {
    mnName = "清理妖怪",
    missionDes = "枯风山被摧毁后，有少量妖魔逃入了人间，频频发生的妖魔伤人事情让百姓们苦不堪言。各地急件上报请求朝廷派人除妖。衙役找到了你，希望你能为民除害。",
    acceptDes = "None",
    needCmp = {10315},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 39,
    rewardCoin = 10300,
    rewardGold = 0,
    rewardExp = 61940,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        3,
        12,
        false
      },
      talkId = 0,
      param = 0,
      des = "清理逃跑至长安郊外的#<Y,>倒霉鬼#"
    },
    dst2 = {
      type = 101,
      data = 90921,
      talkId = 103161,
      param = 0,
      des = "回复#<Y,>衙役#"
    }
  },
  [10317] = {
    mnName = "长安除妖",
    missionDes = "枯风山被摧毁后，有少量妖魔逃入了人间，频频发生的妖魔伤人事情让百姓们苦不堪言。各地急件上报请求朝廷派人除妖。衙役找到了你，希望你能为民除害。",
    acceptDes = "None",
    needCmp = {10316},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 39,
    rewardCoin = 10300,
    rewardGold = 0,
    rewardExp = 61940,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        3,
        13,
        false
      },
      talkId = 0,
      param = 0,
      des = "清理逃跑至长安城的#<Y,>丧气鬼#"
    },
    dst2 = {
      type = 101,
      data = 90921,
      talkId = 103171,
      param = 0,
      des = "回复#<Y,>衙役#"
    }
  },
  [10318] = {
    mnName = "渔村余孽",
    missionDes = "枯风山被摧毁后，有少量妖魔逃入了人间，频频发生的妖魔伤人事情让百姓们苦不堪言。各地急件上报请求朝廷派人除妖。衙役找到了你，希望你能为民除害。",
    acceptDes = "None",
    needCmp = {10317},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 42,
    rewardCoin = 11300,
    rewardGold = 0,
    rewardExp = 68029,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        3,
        14,
        false
      },
      talkId = 0,
      param = 0,
      des = "清理逃跑至#<Y,>渔村#的妖怪"
    },
    dst2 = {
      type = 101,
      data = 90921,
      talkId = 103182,
      param = 0,
      des = "回复#<Y,>衙役#"
    }
  },
  [10319] = {
    mnName = "仙子告急",
    missionDes = "多心经，佛家至宝，能趋吉避凶，保守元明。此经本在法师取经前交给他，可...仙子居然将如此重要的事情忘记了。仙子希望你找到法师，并将心经交给他。",
    acceptDes = "None",
    needCmp = {10318},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 42,
    rewardCoin = 4500,
    rewardGold = 0,
    rewardExp = 27211,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 103191,
      param = 0,
      des = "#<Y,>紫霞仙子#有事找你"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10320] = {
    mnName = "追踪踪迹",
    missionDes = "多心经，佛家至宝，能趋吉避凶，保守元明。此经本在法师取经前交给他，可...仙子居然将如此重要的事情忘记了。仙子希望你找到法师，并将心经交给他。",
    acceptDes = "None",
    needCmp = {10319},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 42,
    rewardCoin = 4500,
    rewardGold = 0,
    rewardExp = 27211,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90924,
      talkId = 103201,
      param = 0,
      des = "向#<Y,>婆婆#打听法师的踪迹"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10321] = {
    mnName = "搜索岭脚",
    missionDes = "多心经，佛家至宝，能趋吉避凶，保守元明。此经本在法师取经前交给他，可...仙子居然将如此重要的事情忘记了。仙子希望你找到法师，并将心经交给他。",
    acceptDes = "None",
    needCmp = {10320},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 42,
    rewardCoin = 11300,
    rewardGold = 0,
    rewardExp = 68029,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        3,
        15,
        false
      },
      talkId = 0,
      wftalkId = 103211,
      param = 0,
      des = "探查#<Y,>岭脚#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10322] = {
    mnName = "岭中营寨",
    missionDes = "多心经，佛家至宝，能趋吉避凶，保守元明。此经本在法师取经前交给他，可...仙子居然将如此重要的事情忘记了。仙子希望你找到法师，并将心经交给他。",
    acceptDes = "None",
    needCmp = {10321},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 45,
    rewardCoin = 12400,
    rewardGold = 0,
    rewardExp = 74510,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        3,
        16,
        false
      },
      talkId = 0,
      param = 0,
      des = "打败妖怪队长#<Y,>小钻风#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10323] = {
    mnName = "妖怪守卫",
    missionDes = "多心经，佛家至宝，能趋吉避凶，保守元明。此经本在法师取经前交给他，可...仙子居然将如此重要的事情忘记了。仙子希望你找到法师，并将心经交给他。",
    acceptDes = "None",
    needCmp = {10322},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 45,
    rewardCoin = 12400,
    rewardGold = 0,
    rewardExp = 74510,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        3,
        17,
        false
      },
      talkId = 0,
      param = 0,
      des = "打败妖怪守卫#<Y,>熊力士#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10324] = {
    mnName = "赴约黑熊",
    missionDes = "多心经，佛家至宝，能趋吉避凶，保守元明。此经本在法师取经前交给他，可...仙子居然将如此重要的事情忘记了。仙子希望你找到法师，并将心经交给他。",
    acceptDes = "None",
    needCmp = {10323},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 45,
    rewardCoin = 12400,
    rewardGold = 0,
    rewardExp = 74510,
    HelpWinAwardXiaYi = 255,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        3,
        18,
        false
      },
      talkId = 103241,
      param = 0,
      des = "铲除赴约的#<Y,>熊罢精#(建议组队前往)"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10325] = {
    mnName = "上当",
    missionDes = "多心经，佛家至宝，能趋吉避凶，保守元明。此经本在法师取经前交给他，可...仙子居然将如此重要的事情忘记了。仙子希望你找到法师，并将心经交给他。",
    acceptDes = "None",
    needCmp = {10324},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 45,
    rewardCoin = 5000,
    rewardGold = 0,
    rewardExp = 29804,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90924,
      talkId = 103242,
      param = 0,
      des = "质问#<Y,>许婆婆#为什么骗你"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10326] = {
    mnName = "急火燎燎(1)",
    missionDes = "多心经，佛家至宝，能趋吉避凶，保守元明。此经本在法师取经前交给他，可...仙子居然将如此重要的事情忘记了。仙子希望你找到法师，并将心经交给他。",
    acceptDes = "None",
    needCmp = {10325},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 48,
    rewardCoin = 13600,
    rewardGold = 0,
    rewardExp = 81416,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        3,
        19,
        false
      },
      talkId = 0,
      param = 0,
      des = "去魔王寨寻找#<Y,>三藏法师#踪迹"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10327] = {
    mnName = "急火燎燎(2)",
    missionDes = "多心经，佛家至宝，能趋吉避凶，保守元明。此经本在法师取经前交给他，可...仙子居然将如此重要的事情忘记了。仙子希望你找到法师，并将心经交给他。",
    acceptDes = "None",
    needCmp = {10326},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 48,
    rewardCoin = 13600,
    rewardGold = 0,
    rewardExp = 81416,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        3,
        20,
        false
      },
      talkId = 0,
      wftalkId = 103261,
      param = 0,
      des = "从#<Y,>回音鬼#口中探听法师情况"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10328] = {
    mnName = "捣毁宴会(3称)",
    missionDes = "多心经，佛家至宝，能趋吉避凶，保守元明。此经本在法师取经前交给他，可...仙子居然将如此重要的事情忘记了。仙子希望你找到法师，并将心经交给他。",
    acceptDes = "None",
    needCmp = {10327},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 48,
    rewardCoin = 13600,
    rewardGold = 0,
    rewardExp = 81416,
    HelpWinAwardXiaYi = 280,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        3,
        21,
        false
      },
      talkId = 103271,
      param = 0,
      des = "捣毁长生宴救出#<Y,>三藏法师#(建议组队前往)"
    },
    dst2 = {
      type = 101,
      data = 90925,
      talkId = 103272,
      param = 0,
      des = "安慰受惊吓的#<Y,>三藏法师#"
    }
  },
  [10329] = {
    mnName = "多心经(3称)",
    missionDes = "多心经，佛家至宝，能趋吉避凶，保守元明。此经本在法师取经前交给他，可...仙子居然将如此重要的事情忘记了。仙子希望你找到法师，并将心经交给他。",
    acceptDes = "None",
    needCmp = {10328},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 48,
    rewardCoin = 6800,
    rewardGold = 0,
    rewardExp = 40708,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 90907,
      talkId = 103281,
      param = {
        {21087, 1}
      },
      des = "回复#<Y,>紫霞仙子#"
    },
    dst2 = {
      type = 402,
      data = 90925,
      talkId = 103282,
      param = {
        {21087, 1}
      },
      des = "将#<Y,>多心经#交给法师"
    }
  },
  [10330] = {
    mnName = "大唐天司(3称)",
    missionDes = "多心经，佛家至宝，能趋吉避凶，保守元明。此经本在法师取经前交给他，可...仙子居然将如此重要的事情忘记了。仙子希望你找到法师，并将心经交给他。",
    acceptDes = "None",
    needCmp = {10329},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 48,
    rewardCoin = 5400,
    rewardGold = 0,
    rewardExp = 32566,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 103291,
      param = 0,
      des = "向#<Y,>紫霞仙子#交付任务"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10401] = {
    mnName = "有事相求",
    missionDes = "程咬金为保护圣上不受恶鬼伤害而身负重伤，至今昏迷不醒。众太医对此束手无策，只好命袁天罡想法子救人。袁天罡希望你能帮他去地府采集五朵海魂草。",
    acceptDes = "None",
    needCmp = {10330},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 50,
    rewardCoin = 5800,
    rewardGold = 0,
    rewardExp = 34508,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90926,
      talkId = 104011,
      param = 0,
      des = "问#<Y,>袁天罡#找你有何事"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10402] = {
    mnName = "地府之路",
    missionDes = "程咬金为保护圣上不受恶鬼伤害而身负重伤，至今昏迷不醒。众太医对此束手无策，只好命袁天罡想法子救人。袁天罡希望你能帮他去地府采集五朵海魂草。",
    acceptDes = "None",
    needCmp = {10401},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 50,
    rewardCoin = 14400,
    rewardGold = 0,
    rewardExp = 86271,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        4,
        1,
        false
      },
      talkId = 0,
      param = 0,
      des = "前往龙宫，进入#<Y,>地府#通道"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10403] = {
    mnName = "教训守将",
    missionDes = "程咬金为保护圣上不受恶鬼伤害而身负重伤，至今昏迷不醒。众太医对此束手无策，只好命袁天罡想法子救人。袁天罡希望你能帮他去地府采集五朵海魂草。",
    acceptDes = "None",
    needCmp = {10402},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 50,
    rewardCoin = 14400,
    rewardGold = 0,
    rewardExp = 86271,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        4,
        2,
        false
      },
      talkId = 104031,
      param = 0,
      des = "教训门将#<Y,>牛头#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10404] = {
    mnName = "回复袁天罡",
    missionDes = "程咬金为保护圣上不受恶鬼伤害而身负重伤，至今昏迷不醒。众太医对此束手无策，只好命袁天罡想法子救人。袁天罡希望你能帮他去地府采集五朵海魂草。",
    acceptDes = "None",
    needCmp = {10403},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 50,
    rewardCoin = 5800,
    rewardGold = 0,
    rewardExp = 34508,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90926,
      talkId = 104041,
      param = 0,
      des = "回复#<Y,>袁天罡#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10405] = {
    mnName = "海魂草(1)",
    missionDes = "程咬金为保护圣上不受恶鬼伤害而身负重伤，至今昏迷不醒。众太医对此束手无策，只好命袁天罡想法子救人。袁天罡希望你能帮他去地府采集五朵海魂草。",
    acceptDes = "None",
    needCmp = {10404},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 50,
    rewardCoin = 14400,
    rewardGold = 0,
    rewardExp = 86271,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        4,
        3,
        false
      },
      talkId = 0,
      param = 0,
      des = "打败魔王小妖#<Y,>丑妇人#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10406] = {
    mnName = "海魂草(2)",
    missionDes = "程咬金为保护圣上不受恶鬼伤害而身负重伤，至今昏迷不醒。众太医对此束手无策，只好命袁天罡想法子救人。袁天罡希望你能帮他去地府采集五朵海魂草。",
    acceptDes = "None",
    needCmp = {10405},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 50,
    rewardCoin = 14400,
    rewardGold = 0,
    rewardExp = 86271,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        4,
        4,
        false
      },
      talkId = 0,
      param = 0,
      des = "打败魔王小妖#<Y,>牛头#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10407] = {
    mnName = "海魂草(3)",
    missionDes = "程咬金为保护圣上不受恶鬼伤害而身负重伤，至今昏迷不醒。众太医对此束手无策，只好命袁天罡想法子救人。袁天罡希望你能帮他去地府采集五朵海魂草。",
    acceptDes = "None",
    needCmp = {10406},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 53,
    rewardCoin = 15700,
    rewardGold = 0,
    rewardExp = 93957,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 202,
      data = {
        4,
        5,
        false
      },
      talkId = 104071,
      param = {
        {
          21008,
          1,
          100
        }
      },
      des = "从#<Y,>海魂仙子#手中取得海魂草"
    },
    dst2 = {
      type = 402,
      data = 90926,
      talkId = 104072,
      param = {
        {21008, 1}
      },
      des = "把海魂草交给#<Y,>袁天罡#"
    }
  },
  [10408] = {
    mnName = "送药",
    missionDes = "程咬金深受程府仆人们的爱戴，得知程老将军受了伤，也是格外的关心。程府丫环听闻是地府恶鬼伤害了程老将军，请求你帮助程老将军，替他报得此仇。",
    acceptDes = "None",
    needCmp = {10407},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 53,
    rewardCoin = 7800,
    rewardGold = 0,
    rewardExp = 46978,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 90926,
      talkId = 104081,
      param = {
        {21008, 1}
      },
      des = "找#<Y,>袁天罡#取得草药"
    },
    dst2 = {
      type = 402,
      data = 90927,
      talkId = 104082,
      param = {
        {21008, 1}
      },
      des = "将海魂草交给将军府#<Y,>丫环#"
    }
  },
  [10409] = {
    mnName = "消灭恶鬼(1)",
    missionDes = "程咬金深受程府仆人们的爱戴，得知程老将军受了伤，也是格外的关心。程府丫环听闻是地府恶鬼伤害了程老将军，请求你帮助程老将军，替他报得此仇。",
    acceptDes = "None",
    needCmp = {10408},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 53,
    rewardCoin = 15700,
    rewardGold = 0,
    rewardExp = 93957,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        4,
        6,
        false
      },
      talkId = 0,
      param = 0,
      des = "探查#<Y,>邢台#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10410] = {
    mnName = "消灭恶鬼(2)",
    missionDes = "程咬金深受程府仆人们的爱戴，得知程老将军受了伤，也是格外的关心。程府丫环听闻是地府恶鬼伤害了程老将军，请求你帮助程老将军，替他报得此仇。",
    acceptDes = "None",
    needCmp = {10409},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 53,
    rewardCoin = 15700,
    rewardGold = 0,
    rewardExp = 93957,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        4,
        7,
        false
      },
      talkId = 0,
      param = 0,
      des = "穿过地府#<Y,>奈何桥#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10411] = {
    mnName = "消灭恶鬼(3)",
    missionDes = "程咬金深受程府仆人们的爱戴，得知程老将军受了伤，也是格外的关心。程府丫环听闻是地府恶鬼伤害了程老将军，请求你帮助程老将军，替他报得此仇。",
    acceptDes = "None",
    needCmp = {10410},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 56,
    rewardCoin = 17000,
    rewardGold = 0,
    rewardExp = 102159,
    HelpWinAwardXiaYi = 280,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        4,
        8,
        false
      },
      talkId = 104111,
      param = 0,
      des = "消灭作恶的#<Y,>十恶鬼王#(建议组队前往)"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10412] = {
    mnName = "探望程咬金",
    missionDes = "程咬金深受程府仆人们的爱戴，得知程老将军受了伤，也是格外的关心。程府丫环听闻是地府恶鬼伤害了程老将军，请求你帮助程老将军，替他报得此仇。",
    acceptDes = "None",
    needCmp = {10411},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 56,
    rewardCoin = 6800,
    rewardGold = 0,
    rewardExp = 40863,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90927,
      talkId = 104121,
      param = 0,
      des = "探望#<Y,>程咬金#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10413] = {
    mnName = "噩耗",
    missionDes = "是福不是祸，是祸躲不过。几经波折，李世民还是被地府带走了魂魄，陷入昏睡之中。唯恐朝廷混乱，封锁一切消息之后的袁天罡找到了你，希望你能帮助天下黎民，找到圣上魂魄。",
    acceptDes = "None",
    needCmp = {10412},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 56,
    rewardCoin = 6800,
    rewardGold = 0,
    rewardExp = 40863,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90926,
      talkId = 104131,
      param = 0,
      des = "#<Y,>袁天罡#有事找你"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10414] = {
    mnName = "恩怨",
    missionDes = "是福不是祸，是祸躲不过。几经波折，李世民还是被地府带走了魂魄，陷入昏睡之中。唯恐朝廷混乱，封锁一切消息之后的袁天罡找到了你，希望你能帮助天下黎民，找到圣上魂魄。",
    acceptDes = "None",
    needCmp = {10413},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 56,
    rewardCoin = 6800,
    rewardGold = 0,
    rewardExp = 40863,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90928,
      talkId = 104141,
      param = 0,
      des = "质问#<Y,>李鬼谷#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10415] = {
    mnName = "回复袁天罡",
    missionDes = "是福不是祸，是祸躲不过。几经波折，李世民还是被地府带走了魂魄，陷入昏睡之中。唯恐朝廷混乱，封锁一切消息之后的袁天罡找到了你，希望你能帮助天下黎民，找到圣上魂魄。",
    acceptDes = "None",
    needCmp = {10414},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 59,
    rewardCoin = 7400,
    rewardGold = 0,
    rewardExp = 44366,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90926,
      talkId = 104151,
      param = 0,
      des = "询问#<Y,>袁天罡#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10416] = {
    mnName = "探查小路",
    missionDes = "是福不是祸，是祸躲不过。几经波折，李世民还是被地府带走了魂魄，陷入昏睡之中。唯恐朝廷混乱，封锁一切消息之后的袁天罡找到了你，希望你能帮助天下黎民，找到圣上魂魄。",
    acceptDes = "None",
    needCmp = {10415},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 59,
    rewardCoin = 18500,
    rewardGold = 0,
    rewardExp = 110915,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        4,
        9,
        false
      },
      talkId = 0,
      wftalkId = 104161,
      param = 0,
      des = "在#<Y,>地府#搜索李世民主魂"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10417] = {
    mnName = "探查蛇涧",
    missionDes = "是福不是祸，是祸躲不过。几经波折，李世民还是被地府带走了魂魄，陷入昏睡之中。唯恐朝廷混乱，封锁一切消息之后的袁天罡找到了你，希望你能帮助天下黎民，找到圣上魂魄。",
    acceptDes = "None",
    needCmp = {10416},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 59,
    rewardCoin = 18500,
    rewardGold = 0,
    rewardExp = 110915,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        4,
        10,
        false
      },
      talkId = 0,
      wftalkId = 104171,
      param = 0,
      des = "在#<Y,>地府#搜索李世民主魂"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10418] = {
    mnName = "寻魂",
    missionDes = "是福不是祸，是祸躲不过。几经波折，李世民还是被地府带走了魂魄，陷入昏睡之中。唯恐朝廷混乱，封锁一切消息之后的袁天罡找到了你，希望你能帮助天下黎民，找到圣上魂魄。",
    acceptDes = "None",
    needCmp = {10417},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 59,
    rewardCoin = 18500,
    rewardGold = 0,
    rewardExp = 110915,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        4,
        11,
        false
      },
      talkId = 104181,
      param = 0,
      des = "在奈何桥上寻找#<Y,>李世民主魂#"
    },
    dst2 = {
      type = 101,
      data = 90926,
      talkId = 104182,
      param = 0,
      des = "回复#<Y,>袁天罡#"
    }
  },
  [10419] = {
    mnName = "解决办法",
    missionDes = "是福不是祸，是祸躲不过。几经波折，李世民还是被地府带走了魂魄，陷入昏睡之中。唯恐朝廷混乱，封锁一切消息之后的袁天罡找到了你，希望你能帮助天下黎民，找到圣上魂魄。",
    acceptDes = "None",
    needCmp = {10418},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 61,
    rewardCoin = 7800,
    rewardGold = 0,
    rewardExp = 46832,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 104191,
      param = 0,
      des = "向#<Y,>紫霞仙子#寻求解决之法"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10420] = {
    mnName = "生辰八字",
    missionDes = "是福不是祸，是祸躲不过。几经波折，李世民还是被地府带走了魂魄，陷入昏睡之中。唯恐朝廷混乱，封锁一切消息之后的袁天罡找到了你，希望你能帮助天下黎民，找到圣上魂魄。",
    acceptDes = "None",
    needCmp = {10419},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 61,
    rewardCoin = 7800,
    rewardGold = 0,
    rewardExp = 46832,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90926,
      talkId = 104201,
      param = 0,
      des = "向#<Y,>袁天罡#索要生辰八字"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10421] = {
    mnName = "巡路",
    missionDes = "是福不是祸，是祸躲不过。几经波折，李世民还是被地府带走了魂魄，陷入昏睡之中。唯恐朝廷混乱，封锁一切消息之后的袁天罡找到了你，希望你能帮助天下黎民，找到圣上魂魄。",
    acceptDes = "None",
    needCmp = {10420},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 61,
    rewardCoin = 19500,
    rewardGold = 0,
    rewardExp = 117080,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        4,
        12,
        false
      },
      talkId = 0,
      param = 0,
      des = "消灭地府巡逻使#<Y,>幽剑魂#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10422] = {
    mnName = "闯关",
    missionDes = "是福不是祸，是祸躲不过。几经波折，李世民还是被地府带走了魂魄，陷入昏睡之中。唯恐朝廷混乱，封锁一切消息之后的袁天罡找到了你，希望你能帮助天下黎民，找到圣上魂魄。",
    acceptDes = "None",
    needCmp = {10421},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 61,
    rewardCoin = 19500,
    rewardGold = 0,
    rewardExp = 117080,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        4,
        13,
        false
      },
      talkId = 104221,
      wftalkId = 104222,
      param = 0,
      des = "从#<Y,>子丑鬼#探听三生石头下落"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10423] = {
    mnName = "三生石",
    missionDes = "是福不是祸，是祸躲不过。几经波折，李世民还是被地府带走了魂魄，陷入昏睡之中。唯恐朝廷混乱，封锁一切消息之后的袁天罡找到了你，希望你能帮助天下黎民，找到圣上魂魄。",
    acceptDes = "None",
    needCmp = {10422},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 61,
    rewardCoin = 19500,
    rewardGold = 0,
    rewardExp = 117080,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        4,
        14,
        false
      },
      talkId = 104231,
      wftalkId = 104232,
      param = 0,
      des = "从#<Y,>石精灵#口中探知李世民下落"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10424] = {
    mnName = "回复袁天罡",
    missionDes = "是福不是祸，是祸躲不过。几经波折，李世民还是被地府带走了魂魄，陷入昏睡之中。唯恐朝廷混乱，封锁一切消息之后的袁天罡找到了你，希望你能帮助天下黎民，找到圣上魂魄。",
    acceptDes = "None",
    needCmp = {10423},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 61,
    rewardCoin = 7800,
    rewardGold = 0,
    rewardExp = 46832,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90926,
      talkId = 104241,
      param = 0,
      des = "将消息告知#<Y,>袁天罡#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10425] = {
    mnName = "探查酆都城(1)",
    missionDes = "是福不是祸，是祸躲不过。几经波折，李世民还是被地府带走了魂魄，陷入昏睡之中。唯恐朝廷混乱，封锁一切消息之后的袁天罡找到了你，希望你能帮助天下黎民，找到圣上魂魄。",
    acceptDes = "None",
    needCmp = {10424},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 63,
    rewardCoin = 20600,
    rewardGold = 0,
    rewardExp = 123521,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        4,
        15,
        false
      },
      talkId = 0,
      param = 0,
      des = "探查地府#<Y,>血河池#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10426] = {
    mnName = "探查酆都城(2)",
    missionDes = "是福不是祸，是祸躲不过。几经波折，李世民还是被地府带走了魂魄，陷入昏睡之中。唯恐朝廷混乱，封锁一切消息之后的袁天罡找到了你，希望你能帮助天下黎民，找到圣上魂魄。",
    acceptDes = "None",
    needCmp = {10425},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 63,
    rewardCoin = 20600,
    rewardGold = 0,
    rewardExp = 123521,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        4,
        16,
        false
      },
      talkId = 0,
      param = 0,
      des = "探查地府#<Y,>阴风林#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10427] = {
    mnName = "探查酆都城(3)",
    missionDes = "是福不是祸，是祸躲不过。几经波折，李世民还是被地府带走了魂魄，陷入昏睡之中。唯恐朝廷混乱，封锁一切消息之后的袁天罡找到了你，希望你能帮助天下黎民，找到圣上魂魄。",
    acceptDes = "None",
    needCmp = {10426},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 63,
    rewardCoin = 20600,
    rewardGold = 0,
    rewardExp = 123521,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        4,
        17,
        false
      },
      talkId = 0,
      param = 0,
      des = "打败酆都守将#<Y,>牛头#"
    },
    dst2 = {
      type = 101,
      data = 90926,
      talkId = 104272,
      param = 0,
      des = "回复#<Y,>袁天罡#"
    }
  },
  [10428] = {
    mnName = "水陆道场",
    missionDes = "是福不是祸，是祸躲不过。几经波折，李世民还是被地府带走了魂魄，陷入昏睡之中。唯恐朝廷混乱，封锁一切消息之后的袁天罡找到了你，希望你能帮助天下黎民，找到圣上魂魄。",
    acceptDes = "None",
    needCmp = {10427},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 63,
    rewardCoin = 20600,
    rewardGold = 0,
    rewardExp = 123521,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        4,
        18,
        false
      },
      talkId = 0,
      param = 0,
      des = "打败水陆道场#<Y,>子将#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10429] = {
    mnName = "生死薄",
    missionDes = "是福不是祸，是祸躲不过。几经波折，李世民还是被地府带走了魂魄，陷入昏睡之中。唯恐朝廷混乱，封锁一切消息之后的袁天罡找到了你，希望你能帮助天下黎民，找到圣上魂魄。",
    acceptDes = "None",
    needCmp = {10428},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 63,
    rewardCoin = 20600,
    rewardGold = 0,
    rewardExp = 123521,
    HelpWinAwardXiaYi = 330,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        4,
        19,
        false
      },
      talkId = 104291,
      wftalkId = 104292,
      param = 0,
      des = "从#<Y,>生死薄#中探知李世民的下落(建议组队前往)"
    },
    dst2 = {
      type = 101,
      data = 90926,
      talkId = 104293,
      param = 0,
      des = "将结果告知#<Y,>袁天罡#"
    }
  },
  [10430] = {
    mnName = "养魂丹",
    missionDes = "是福不是祸，是祸躲不过。几经波折，李世民还是被地府带走了魂魄，陷入昏睡之中。唯恐朝廷混乱，封锁一切消息之后的袁天罡找到了你，希望你能帮助天下黎民，找到圣上魂魄。",
    acceptDes = "None",
    needCmp = {10429},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 63,
    rewardCoin = 8200,
    rewardGold = 0,
    rewardExp = 49408,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90973,
      talkId = 104301,
      param = 0,
      des = "向#<Y,>孙思邈#求借养魂丹"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10431] = {
    mnName = "清扫妖兽",
    missionDes = "是福不是祸，是祸躲不过。几经波折，李世民还是被地府带走了魂魄，陷入昏睡之中。唯恐朝廷混乱，封锁一切消息之后的袁天罡找到了你，希望你能帮助天下黎民，找到圣上魂魄。",
    acceptDes = "None",
    needCmp = {10430},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 64,
    rewardCoin = 21100,
    rewardGold = 0,
    rewardExp = 126849,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        4,
        20,
        false
      },
      talkId = 0,
      param = 0,
      des = "消灭女儿国里的#<Y,>吞魂兽#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10432] = {
    mnName = "清扫狐精",
    missionDes = "是福不是祸，是祸躲不过。几经波折，李世民还是被地府带走了魂魄，陷入昏睡之中。唯恐朝廷混乱，封锁一切消息之后的袁天罡找到了你，希望你能帮助天下黎民，找到圣上魂魄。",
    acceptDes = "None",
    needCmp = {10431},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 64,
    rewardCoin = 21100,
    rewardGold = 0,
    rewardExp = 126849,
    HelpWinAwardXiaYi = 30,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        4,
        21,
        false
      },
      talkId = 0,
      param = 0,
      des = "消灭双叉岭里的#<Y,>血狐狸#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10433] = {
    mnName = "养魂丹",
    missionDes = "是福不是祸，是祸躲不过。几经波折，李世民还是被地府带走了魂魄，陷入昏睡之中。唯恐朝廷混乱，封锁一切消息之后的袁天罡找到了你，希望你能帮助天下黎民，找到圣上魂魄。",
    acceptDes = "None",
    needCmp = {10432},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 64,
    rewardCoin = 10600,
    rewardGold = 0,
    rewardExp = 63424,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 90973,
      talkId = 104331,
      param = {
        {21061, 1}
      },
      des = "向#<Y,>孙思邈#取得养魂丹"
    },
    dst2 = {
      type = 402,
      data = 90926,
      talkId = 104332,
      param = {
        {21061, 1}
      },
      des = "将养魂丹交给#<Y,>袁天罡#"
    }
  },
  [10434] = {
    mnName = "解救圣魂(4称)",
    missionDes = "是福不是祸，是祸躲不过。几经波折，李世民还是被地府带走了魂魄，陷入昏睡之中。唯恐朝廷混乱，封锁一切消息之后的袁天罡找到了你，希望你能帮助天下黎民，找到圣上魂魄。",
    acceptDes = "None",
    needCmp = {10433},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 64,
    rewardCoin = 21100,
    rewardGold = 0,
    rewardExp = 126849,
    HelpWinAwardXiaYi = 330,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        4,
        22,
        false
      },
      talkId = 104341,
      param = 0,
      des = "解救#<Y,>李世民#的主魂(建议组队前往)"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10501] = {
    mnName = "前因后果",
    missionDes = "所有的事情皆是因袁天罡与龙王打赌而起，龙王为了赢得赌局，却丢了性命，这才怪罪于李世民。袁天罡担心龙王的下属会报复生活在海岛渔村的居民，希望你能前去巡视一番。",
    acceptDes = "None",
    needCmp = {10434},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 65,
    rewardCoin = 8700,
    rewardGold = 0,
    rewardExp = 52100,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90926,
      talkId = 105011,
      param = 0,
      des = "向#<Y,>袁天罡#打听李世民的情况"
    },
    dst2 = {
      type = 101,
      data = 90926,
      talkId = 105012,
      param = 0,
      des = "继续与#<Y,>袁天罡#交谈"
    }
  },
  [10502] = {
    mnName = "渔村受难",
    missionDes = "“袁天罡真是个乌鸦嘴”，来到渔村后发现这里刚刚出了一场船祸--何万财家的货船被一阵飓风吹入海底。由于事发突然，你决定帮助何万财前去查探一番。",
    acceptDes = "None",
    needCmp = {10501},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 65,
    rewardCoin = 8700,
    rewardGold = 0,
    rewardExp = 52100,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90931,
      talkId = 105021,
      param = 0,
      des = "问#<Y,>何万财#发生了什么事"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10503] = {
    mnName = "探查深海",
    missionDes = "“袁天罡真是个乌鸦嘴”，来到渔村后发现这里刚刚出了一场船祸--何万财家的货船被一阵飓风吹入海底。由于事发突然，你决定帮助何万财前去查探一番。",
    acceptDes = "None",
    needCmp = {10502},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 65,
    rewardCoin = 21700,
    rewardGold = 0,
    rewardExp = 130251,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        5,
        1,
        false
      },
      talkId = 0,
      wftalkId = 105031,
      param = 0,
      des = "探查#<Y,>浅水湾#异象"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10504] = {
    mnName = "水下精怪",
    missionDes = "“袁天罡真是个乌鸦嘴”，来到渔村后发现这里刚刚出了一场船祸--何万财家的货船被一阵飓风吹入海底。由于事发突然，你决定帮助何万财前去查探一番。",
    acceptDes = "None",
    needCmp = {10503},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 65,
    rewardCoin = 21700,
    rewardGold = 0,
    rewardExp = 130251,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        5,
        2,
        false
      },
      talkId = 105041,
      param = 0,
      des = "消灭破坏船只的#<Y,>凶鳄#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10505] = {
    mnName = "回复商人",
    missionDes = "“袁天罡真是个乌鸦嘴”，来到渔村后发现这里刚刚出了一场船祸--何万财家的货船被一阵飓风吹入海底。由于事发突然，你决定帮助何万财前去查探一番。",
    acceptDes = "None",
    needCmp = {10504},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 65,
    rewardCoin = 8700,
    rewardGold = 0,
    rewardExp = 52100,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90931,
      talkId = 105051,
      param = 0,
      des = "回复商人#<Y,>何万财#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10506] = {
    mnName = "孤儿寡妻",
    missionDes = "船在人在，船毁人亡，作为船长的李公一直坚守着这条誓言，他也成为这场事故的唯一身亡者。李公之妻李大婶希望你能为她找到李公身前佩戴的玉佩，好作为平日祭拜之物。",
    acceptDes = "None",
    needCmp = {10505},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 67,
    rewardCoin = 11400,
    rewardGold = 0,
    rewardExp = 68641,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 90931,
      talkId = 105052,
      param = {
        {21012, 1}
      },
      des = "与#<Y,>何万财#聊天"
    },
    dst2 = {
      type = 402,
      data = 90932,
      talkId = 105053,
      param = {
        {21012, 1}
      },
      des = "将银票交给#<Y,>李大婶#"
    }
  },
  [10507] = {
    mnName = "祭拜之物",
    missionDes = "船在人在，船毁人亡，作为船长的李公一直坚守着这条誓言，他也成为这场事故的唯一身亡者。李公之妻李大婶希望你能为她找到李公身前佩戴的玉佩，好作为平日祭拜之物。",
    acceptDes = "None",
    needCmp = {10506},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 67,
    rewardCoin = 9200,
    rewardGold = 0,
    rewardExp = 54913,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90932,
      talkId = 105061,
      param = 0,
      des = "继续与#<Y,>李大婶#对话"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10508] = {
    mnName = "探索海底(1)",
    missionDes = "船在人在，船毁人亡，作为船长的李公一直坚守着这条誓言，他也成为这场事故的唯一身亡者。李公之妻李大婶希望你能为她找到李公身前佩戴的玉佩，好作为平日祭拜之物。",
    acceptDes = "None",
    needCmp = {10507},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 67,
    rewardCoin = 22900,
    rewardGold = 0,
    rewardExp = 137283,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        5,
        3,
        false
      },
      talkId = 0,
      wftalkId = 105071,
      param = 0,
      des = "从水地#<Y,>蚌精#身上追查玉佩踪迹"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10509] = {
    mnName = "探索海底(2)",
    missionDes = "船在人在，船毁人亡，作为船长的李公一直坚守着这条誓言，他也成为这场事故的唯一身亡者。李公之妻李大婶希望你能为她找到李公身前佩戴的玉佩，好作为平日祭拜之物。",
    acceptDes = "None",
    needCmp = {10508},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 67,
    rewardCoin = 22900,
    rewardGold = 0,
    rewardExp = 137283,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        5,
        4,
        false
      },
      talkId = 0,
      wftalkId = 105081,
      param = 0,
      des = "探查#<Y,>水草群#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10510] = {
    mnName = "寻回物件",
    missionDes = "船在人在，船毁人亡，作为船长的李公一直坚守着这条誓言，他也成为这场事故的唯一身亡者。李公之妻李大婶希望你能为她找到李公身前佩戴的玉佩，好作为平日祭拜之物。",
    acceptDes = "None",
    needCmp = {10509},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 69,
    rewardCoin = 24100,
    rewardGold = 0,
    rewardExp = 144632,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 202,
      data = {
        5,
        5,
        false
      },
      talkId = 105091,
      param = {
        {
          21013,
          1,
          100
        }
      },
      des = "从#<Y,>小钻风#手中夺回玉佩"
    },
    dst2 = {
      type = 402,
      data = 90932,
      talkId = 105092,
      param = {
        {21013, 1}
      },
      des = "将玉佩交给#<Y,>李大婶#确认"
    }
  },
  [10511] = {
    mnName = "回复袁天罡",
    missionDes = "袁天罡得知渔村发生的事情后，十分愤怒。他希望你能将渔村周边水域的水妖全部铲除，以绝后患。",
    acceptDes = "None",
    needCmp = {10510},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 69,
    rewardCoin = 9600,
    rewardGold = 0,
    rewardExp = 57853,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90926,
      talkId = 105101,
      param = 0,
      des = "将渔村发生的事情告诉#<Y,>袁天罡#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10512] = {
    mnName = "清理水妖(1)",
    missionDes = "袁天罡得知渔村发生的事情后，十分愤怒。他希望你能将渔村周边水域的水妖全部铲除，以绝后患。",
    acceptDes = "None",
    needCmp = {10511},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 69,
    rewardCoin = 24100,
    rewardGold = 0,
    rewardExp = 144632,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        5,
        6,
        false
      },
      talkId = 0,
      param = 0,
      des = "前往海底龙宫消灭水妖#<Y,>冰火麒麟#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10513] = {
    mnName = "清理水妖(2)",
    missionDes = "袁天罡得知渔村发生的事情后，十分愤怒。他希望你能将渔村周边水域的水妖全部铲除，以绝后患。",
    acceptDes = "None",
    needCmp = {10512},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 69,
    rewardCoin = 24100,
    rewardGold = 0,
    rewardExp = 144632,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        5,
        7,
        false
      },
      talkId = 0,
      param = 0,
      des = "消灭水妖#<Y,>海蛇精#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10514] = {
    mnName = "清理水妖(3)",
    missionDes = "袁天罡得知渔村发生的事情后，十分愤怒。他希望你能将渔村周边水域的水妖全部铲除，以绝后患。",
    acceptDes = "None",
    needCmp = {10513},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 71,
    rewardCoin = 25400,
    rewardGold = 0,
    rewardExp = 152312,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        5,
        8,
        false
      },
      talkId = 105131,
      param = 0,
      des = "铲除水族余孽#<Y,>鸣蛇#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10515] = {
    mnName = "袁天罡的请求",
    missionDes = "根据水族近期所犯的事情，袁天罡觉得那头该死的业龙肯定还活着。袁天罡希望你能去龙宫打探消息，帮他验证心中的猜想。",
    acceptDes = "None",
    needCmp = {10514},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 71,
    rewardCoin = 10200,
    rewardGold = 0,
    rewardExp = 60925,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90926,
      talkId = 105141,
      param = 0,
      des = "与#<Y,>袁天罡#对话"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10516] = {
    mnName = "打探(1)",
    missionDes = "根据水族近期所犯的事情，袁天罡觉得那头该死的业龙肯定还活着。袁天罡希望你能去龙宫打探消息，帮他验证心中的猜想。",
    acceptDes = "None",
    needCmp = {10515},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 71,
    rewardCoin = 25400,
    rewardGold = 0,
    rewardExp = 152312,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        5,
        9,
        false
      },
      talkId = 0,
      param = 0,
      des = "拷问#<Y,>精细嘴#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10517] = {
    mnName = "打探(2)",
    missionDes = "根据水族近期所犯的事情，袁天罡觉得那头该死的业龙肯定还活着。袁天罡希望你能去龙宫打探消息，帮他验证心中的猜想。",
    acceptDes = "None",
    needCmp = {10516},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 71,
    rewardCoin = 25400,
    rewardGold = 0,
    rewardExp = 152312,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        5,
        10,
        false
      },
      talkId = 0,
      param = 0,
      des = "拷问龙宫巡逻将领#<Y,>横公鱼#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10518] = {
    mnName = "打探(3)",
    missionDes = "根据水族近期所犯的事情，袁天罡觉得那头该死的业龙肯定还活着。袁天罡希望你能去龙宫打探消息，帮他验证心中的猜想。",
    acceptDes = "None",
    needCmp = {10517},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 73,
    rewardCoin = 26700,
    rewardGold = 0,
    rewardExp = 160339,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        5,
        11,
        false
      },
      talkId = 105171,
      param = 0,
      des = "从#<Y,>海将军#处探听龙王下落"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10519] = {
    mnName = "回复消息",
    missionDes = "根据水族近期所犯的事情，袁天罡觉得那头该死的业龙肯定还活着。袁天罡希望你能去龙宫打探消息，帮他验证心中的猜想。",
    acceptDes = "None",
    needCmp = {10518},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 73,
    rewardCoin = 10700,
    rewardGold = 0,
    rewardExp = 64135,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90926,
      talkId = 105181,
      param = 0,
      des = "将打听到的情况告知#<Y,>袁天罡#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10520] = {
    mnName = "借宝",
    missionDes = "李鬼谷拥有一宝名叫避水珠，此珠能防止水妖上岸。袁天罡希望你能去趟方寸山，向师兄李鬼谷借到此珠，并将避水珠埋藏在渔村。",
    acceptDes = "None",
    needCmp = {10519},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 73,
    rewardCoin = 10700,
    rewardGold = 0,
    rewardExp = 64135,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90928,
      talkId = 105191,
      param = 0,
      des = "找#<Y,>李鬼谷#借避水珠"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10521] = {
    mnName = "深海妖兽(1)",
    missionDes = "李鬼谷拥有一宝名叫避水珠，此珠能防止水妖上岸。袁天罡希望你能去趟方寸山，向师兄李鬼谷借到此珠，并将避水珠埋藏在渔村。",
    acceptDes = "None",
    needCmp = {10520},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 73,
    rewardCoin = 26700,
    rewardGold = 0,
    rewardExp = 160339,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        5,
        12,
        false
      },
      talkId = 0,
      param = 0,
      des = "击败镇守在莲花池的#<Y,>御水兽#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10522] = {
    mnName = "深海妖兽(2)",
    missionDes = "李鬼谷拥有一宝名叫避水珠，此珠能防止水妖上岸。袁天罡希望你能去趟方寸山，向师兄李鬼谷借到此珠，并将避水珠埋藏在渔村。",
    acceptDes = "None",
    needCmp = {10521},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 75,
    rewardCoin = 28100,
    rewardGold = 0,
    rewardExp = 168727,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        5,
        13,
        false
      },
      talkId = 0,
      param = 0,
      des = "击败镇守在莲花池的#<Y,>九花蛇#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10523] = {
    mnName = "抢夺珍珠",
    missionDes = "李鬼谷拥有一宝名叫避水珠，此珠能防止水妖上岸。袁天罡希望你能去趟方寸山，向师兄李鬼谷借到此珠，并将避水珠埋藏在渔村。",
    acceptDes = "None",
    needCmp = {10522},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 75,
    rewardCoin = 28100,
    rewardGold = 0,
    rewardExp = 168727,
    HelpWinAwardXiaYi = 365,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 202,
      data = {
        5,
        14,
        false
      },
      talkId = 105221,
      param = {
        {
          21014,
          1,
          100
        }
      },
      des = "从九幽手中抢夺#<Y,>珍珠#(建议组队前往)"
    },
    dst2 = {
      type = 402,
      data = 90928,
      talkId = 105222,
      param = {
        {21014, 1}
      },
      des = "将珍珠交给#<Y,>李鬼谷#"
    }
  },
  [10524] = {
    mnName = "避水珠",
    missionDes = "李鬼谷拥有一宝名叫避水珠，此珠能防止水妖上岸。袁天罡希望你能去趟方寸山，向师兄李鬼谷借到此珠，并将避水珠埋藏在渔村。",
    acceptDes = "None",
    needCmp = {10523},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 75,
    rewardCoin = 14100,
    rewardGold = 0,
    rewardExp = 84363,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 90928,
      talkId = 105231,
      param = {
        {21015, 1}
      },
      des = "找#<Y,>李鬼谷#求借避水珠"
    },
    dst2 = {
      type = 401,
      data = {
        1,
        19,
        20
      },
      talkId = 0,
      param = {
        {21015, 1}
      },
      des = "在#<Y,>东海渔村#使用避水珠"
    }
  },
  [10525] = {
    mnName = "回复袁天罡",
    missionDes = "业龙贼心不死，每次想到一些坏点子都是通知属下待其操办。想要阻止业龙对大唐进行破坏，必须先消灭其爪牙。",
    acceptDes = "None",
    needCmp = {10524},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 75,
    rewardCoin = 11200,
    rewardGold = 0,
    rewardExp = 67491,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90926,
      talkId = 105251,
      param = 0,
      des = "向#<Y,>袁天罡#交付任务"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10526] = {
    mnName = "骚乱(1)",
    missionDes = "业龙贼心不死，每次想到一些坏点子都是通知属下待其操办。想要阻止业龙对大唐进行破坏，必须先消灭其爪牙。",
    acceptDes = "None",
    needCmp = {10525},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 77,
    rewardCoin = 29600,
    rewardGold = 0,
    rewardExp = 177494,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        5,
        15,
        false
      },
      talkId = 0,
      param = 0,
      des = "扫平业龙爪牙#<Y,>蚌精#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10527] = {
    mnName = "骚乱(2)",
    missionDes = "业龙贼心不死，每次想到一些坏点子都是通知属下待其操办。想要阻止业龙对大唐进行破坏，必须先消灭其爪牙。",
    acceptDes = "None",
    needCmp = {10526},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 77,
    rewardCoin = 29600,
    rewardGold = 0,
    rewardExp = 177494,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        5,
        16,
        false
      },
      talkId = 0,
      param = 0,
      des = "击败业龙心腹#<Y,>海蛇精#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10528] = {
    mnName = "擒拿头目",
    missionDes = "业龙贼心不死，每次想到一些坏点子都是通知属下待其操办。想要阻止业龙对大唐进行破坏，必须先消灭其爪牙。",
    acceptDes = "None",
    needCmp = {10527},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 77,
    rewardCoin = 29600,
    rewardGold = 0,
    rewardExp = 177494,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        5,
        17,
        false
      },
      talkId = 0,
      param = 0,
      des = "困住垂云殿#<Y,>海将军#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10529] = {
    mnName = "奇怪的人",
    missionDes = "你把龙宫翻了个底朝天都未找到龙王的藏身之处。袁天罡告诉你这世上有种秘法能通过至亲之人之血的牵引，找到你需要找到的那个人。而那个人就在妖府的巢穴中...",
    acceptDes = "None",
    needCmp = {10528},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 77,
    rewardCoin = 11800,
    rewardGold = 0,
    rewardExp = 70997,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90926,
      talkId = 105291,
      param = 0,
      des = "向#<Y,>袁天罡#打听不了禅师的下落"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10530] = {
    mnName = "交易",
    missionDes = "你把龙宫翻了个底朝天都未找到龙王的藏身之处。袁天罡告诉你这世上有种秘法能通过至亲之人之血的牵引，找到你需要找到的那个人。而那个人就在妖府的巢穴中...",
    acceptDes = "None",
    needCmp = {10529},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 77,
    rewardCoin = 11800,
    rewardGold = 0,
    rewardExp = 70997,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90933,
      talkId = 105301,
      param = 0,
      des = "去魔王寨找#<Y,>不了禅师#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10531] = {
    mnName = "消灭冰火麒麟",
    missionDes = "你把龙宫翻了个底朝天都未找到龙王的藏身之处。袁天罡告诉你这世上有种秘法能通过至亲之人之血的牵引，找到你需要找到的那个人。而那个人就在妖府的巢穴中...",
    acceptDes = "None",
    needCmp = {10530},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 79,
    rewardCoin = 31100,
    rewardGold = 0,
    rewardExp = 186656,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        5,
        18,
        false
      },
      talkId = 0,
      param = 0,
      des = "帮助禅师消灭#<Y,>冰火麒麟#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10532] = {
    mnName = "回复禅师",
    missionDes = "你把龙宫翻了个底朝天都未找到龙王的藏身之处。袁天罡告诉你这世上有种秘法能通过至亲之人之血的牵引，找到你需要找到的那个人。而那个人就在妖府的巢穴中...",
    acceptDes = "None",
    needCmp = {10531},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 79,
    rewardCoin = 12400,
    rewardGold = 0,
    rewardExp = 74662,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90933,
      talkId = 105321,
      param = 0,
      des = "回复#<Y,>不了禅师#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10533] = {
    mnName = "浮珠宫女",
    missionDes = "你把龙宫翻了个底朝天都未找到龙王的藏身之处。袁天罡告诉你这世上有种秘法能通过至亲之人之血的牵引，找到你需要找到的那个人。而那个人就在妖府的巢穴中...",
    acceptDes = "None",
    needCmp = {10532},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 79,
    rewardCoin = 31100,
    rewardGold = 0,
    rewardExp = 186656,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        5,
        19,
        false
      },
      talkId = 0,
      param = 0,
      des = "赶走宫女#<Y,>丁时雨#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10534] = {
    mnName = "至亲之血",
    missionDes = "你把龙宫翻了个底朝天都未找到龙王的藏身之处。袁天罡告诉你这世上有种秘法能通过至亲之人之血的牵引，找到你需要找到的那个人。而那个人就在妖府的巢穴中...",
    acceptDes = "None",
    needCmp = {10533},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 79,
    rewardCoin = 31100,
    rewardGold = 0,
    rewardExp = 186656,
    HelpWinAwardXiaYi = 390,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 202,
      data = {
        5,
        20,
        false
      },
      talkId = 105341,
      param = {
        {
          21016,
          1,
          100
        }
      },
      des = "从龙宫公主身上取得#<Y,>血液#(建议组队前往)"
    },
    dst2 = {
      type = 402,
      data = 90933,
      talkId = 105342,
      param = {
        {21016, 1}
      },
      des = "将龙血交给#<Y,>不了禅师#"
    }
  },
  [10535] = {
    mnName = "回信",
    missionDes = "历经波折，终于找到了龙王藏身之处，得知消息的袁天罡也将从皇宫得来的口谕要你代当今天子传个口谕给龙王。去养魂殿，替李世民传达口谕。",
    acceptDes = "None",
    needCmp = {10534},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 79,
    rewardCoin = 12400,
    rewardGold = 0,
    rewardExp = 74662,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90926,
      talkId = 105351,
      param = 0,
      des = "将调查结果告知#<Y,>袁天罡#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10536] = {
    mnName = "龙口兵卫",
    missionDes = "历经波折，终于找到了龙王藏身之处，得知消息的袁天罡要你代当今天子传个口谕给龙王。去养魂殿，替李世民传达口谕。",
    acceptDes = "None",
    needCmp = {10535},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 79,
    rewardCoin = 31100,
    rewardGold = 0,
    rewardExp = 186656,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        5,
        21,
        false
      },
      talkId = 0,
      param = 0,
      des = "打败业龙守卫#<Y,>九幽#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10537] = {
    mnName = "龙王惊变(5称)",
    missionDes = "历经波折，终于找到了龙王藏身之处，得知消息的袁天罡要你代当今天子传个口谕给龙王。去养魂殿，替李世民传达口谕。",
    acceptDes = "None",
    needCmp = {10536},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 79,
    rewardCoin = 31100,
    rewardGold = 0,
    rewardExp = 186656,
    HelpWinAwardXiaYi = 415,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        5,
        22,
        false
      },
      talkId = 105371,
      param = 0,
      des = "消灭业龙#<Y,>龙王#(建议组队前往)"
    },
    dst2 = {
      type = 101,
      data = 90926,
      talkId = 105372,
      param = 0,
      des = "将龙王变节的消息告诉#<Y,>袁天罡#"
    }
  },
  [10601] = {
    mnName = "唐僧踪迹",
    missionDes = "乌斯藏国在仙界是出了名的妖魔之地，此地妖魔猖獗不说，数量还很多。紫霞仙子要你立即前往乌斯藏国，随行保护好西行取经的法师。",
    acceptDes = "None",
    needCmp = {10537},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 80,
    rewardCoin = 12800,
    rewardGold = 0,
    rewardExp = 76556,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 106011,
      param = 0,
      des = "向#<Y,>紫霞仙子#复命"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10602] = {
    mnName = "拦路小妖",
    missionDes = "乌斯藏国在仙界是出了名的妖魔之地，此地妖魔猖獗不说，数量还很多。紫霞仙子要你立即前往乌斯藏国，随行保护好西行取经的法师。",
    acceptDes = "None",
    needCmp = {10601},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 80,
    rewardCoin = 31900,
    rewardGold = 0,
    rewardExp = 191391,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        6,
        1,
        false
      },
      talkId = 106021,
      param = 0,
      des = "扫除阻挡去路的#<Y,>熊力士#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10603] = {
    mnName = "猪妖逞凶",
    missionDes = "乌斯藏国在仙界是出了名的妖魔之地，此地妖魔猖獗不说，数量还很多。紫霞仙子要你立即前往乌斯藏国，随行保护好西行取经的法师。",
    acceptDes = "None",
    needCmp = {10602},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 80,
    rewardCoin = 12800,
    rewardGold = 0,
    rewardExp = 76556,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90935,
      talkId = 106031,
      param = 0,
      des = "向#<Y,>高太公#确认路线"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10604] = {
    mnName = "赶跑猪妖",
    missionDes = "乌斯藏国在仙界是出了名的妖魔之地，此地妖魔猖獗不说，数量还很多。紫霞仙子要你立即前往乌斯藏国，随行保护好西行取经的法师。",
    acceptDes = "None",
    needCmp = {10603},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 80,
    rewardCoin = 31900,
    rewardGold = 0,
    rewardExp = 191391,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        6,
        2,
        false
      },
      talkId = 106041,
      param = 0,
      des = "赶走出现的#<Y,>猪妖#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10605] = {
    mnName = "高太公的请求",
    missionDes = "高太公家的小女儿于三年前不幸被一只可怕的妖魔所强占，苦不堪言的高家为了解救其女，一直在四处寻请降妖的法师，但从未成功。这一切，直到你来到高家庄...",
    acceptDes = "None",
    needCmp = {10604},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 83,
    rewardCoin = 13700,
    rewardGold = 0,
    rewardExp = 82495,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90935,
      talkId = 106051,
      param = 0,
      des = "与#<Y,>高太公#对话"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10606] = {
    mnName = "猪妖洞府",
    missionDes = "高太公家的小女儿于三年前不幸被一只可怕的妖魔所强占，苦不堪言的高家为了解救其女，一直在四处寻请降妖的法师，但从未成功。这一切，直到你来到高家庄...",
    acceptDes = "None",
    needCmp = {10605},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 83,
    rewardCoin = 13700,
    rewardGold = 0,
    rewardExp = 82495,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90936,
      talkId = 106061,
      param = 0,
      des = "从#<Y,>高翠兰#口中打听猪妖的消息"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10607] = {
    mnName = "搜查洞府(1)",
    missionDes = "高太公家的小女儿于三年前不幸被一只可怕的妖魔所强占，苦不堪言的高家为了解救其女，一直在四处寻请降妖的法师，但从未成功。这一切，直到你来到高家庄...",
    acceptDes = "None",
    needCmp = {10606},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 83,
    rewardCoin = 34400,
    rewardGold = 0,
    rewardExp = 206239,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        6,
        3,
        false
      },
      talkId = 0,
      param = 0,
      des = "搜查#<Y,>猪妖#的洞府"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10608] = {
    mnName = "搜查洞府(2)",
    missionDes = "高太公家的小女儿于三年前不幸被一只可怕的妖魔所强占，苦不堪言的高家为了解救其女，一直在四处寻请降妖的法师，但从未成功。这一切，直到你来到高家庄...",
    acceptDes = "None",
    needCmp = {10607},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 83,
    rewardCoin = 34400,
    rewardGold = 0,
    rewardExp = 206239,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        6,
        4,
        false
      },
      talkId = 0,
      param = 0,
      des = "消灭妖怪喽啰#<Y,>武魂#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10609] = {
    mnName = "铲除猪妖",
    missionDes = "高太公家的小女儿于三年前不幸被一只可怕的妖魔所强占，苦不堪言的高家为了解救其女，一直在四处寻请降妖的法师，但从未成功。这一切，直到你来到高家庄...",
    acceptDes = "None",
    needCmp = {10608},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 86,
    rewardCoin = 37000,
    rewardGold = 0,
    rewardExp = 222103,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        6,
        5,
        false
      },
      talkId = 106091,
      param = 0,
      des = "铲除强抢民女的#<Y,>猪妖#"
    },
    dst2 = {
      type = 101,
      data = 90936,
      talkId = 106092,
      param = 0,
      des = "向#<Y,>高翠兰#复命"
    }
  },
  [10610] = {
    mnName = "唐僧下落",
    missionDes = "八百流沙界，三千弱水深。鹅毛飘不起，芦花定底沉，流沙河不仅难以渡过，而且还被一个妖魔所霸占。在法师到达流沙河之前，你务必要将此妖消灭。",
    acceptDes = "None",
    needCmp = {10609},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 86,
    rewardCoin = 14800,
    rewardGold = 0,
    rewardExp = 88841,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90935,
      talkId = 106101,
      param = 0,
      des = "向高太公打听#<Y,>三藏法师#的下落"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10611] = {
    mnName = "中路遇阻",
    missionDes = "八百流沙界，三千弱水深。鹅毛飘不起，芦花定底沉，流沙河不仅难以渡过，而且还被一个妖魔所霸占。在法师到达流沙河之前，你务必要将此妖消灭。",
    acceptDes = "None",
    needCmp = {10610},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 86,
    rewardCoin = 37000,
    rewardGold = 0,
    rewardExp = 222103,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        6,
        6,
        false
      },
      talkId = 0,
      param = 0,
      des = "清除阻挡去路的#<Y,>裂地熊#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10612] = {
    mnName = "短兵相接",
    missionDes = "八百流沙界，三千弱水深。鹅毛飘不起，芦花定底沉，流沙河不仅难以渡过，而且还被一个妖魔所霸占。在法师到达流沙河之前，你务必要将此妖消灭。",
    acceptDes = "None",
    needCmp = {10611},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 86,
    rewardCoin = 37000,
    rewardGold = 0,
    rewardExp = 222103,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        6,
        7,
        false
      },
      talkId = 0,
      param = 0,
      des = "击败平阳大道上的#<Y,>毒刺儿#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10613] = {
    mnName = "大战流沙精",
    missionDes = "八百流沙界，三千弱水深。鹅毛飘不起，芦花定底沉，流沙河不仅难以渡过，而且还被一个妖魔所霸占。在法师到达流沙河之前，你务必要将此妖消灭。",
    acceptDes = "None",
    needCmp = {10612},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 89,
    rewardCoin = 39800,
    rewardGold = 0,
    rewardExp = 239052,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        6,
        8,
        false
      },
      talkId = 106131,
      wftalkId = 106132,
      param = 0,
      des = "铲除#<Y,>沙河精#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10614] = {
    mnName = "仙子委托",
    missionDes = "自从白晶晶与孙悟空分开后，她就一直对紫霞仙子与法师心存怨念。这次法师重新西行取经，必定会百般阻扰。紫霞仙子要你去白虎岭阻止白晶晶，防止她陷害三藏法师。",
    acceptDes = "None",
    needCmp = {10613},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 89,
    rewardCoin = 15900,
    rewardGold = 0,
    rewardExp = 95620,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90937,
      talkId = 106141,
      param = 0,
      des = "问#<Y,>紫霞仙子#为何突然出现此地"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10615] = {
    mnName = "劝说受阻",
    missionDes = "自从白晶晶与孙悟空分开后，她就一直对紫霞仙子与法师心存怨念。这次法师重新西行取经，必定会百般阻扰。紫霞仙子要你去白虎岭阻止白晶晶，防止她陷害三藏法师。",
    acceptDes = "None",
    needCmp = {10614},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 89,
    rewardCoin = 39800,
    rewardGold = 0,
    rewardExp = 239052,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        6,
        9,
        false
      },
      talkId = 106151,
      param = 0,
      des = "教训不肯传讯的#<Y,>小妖#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10616] = {
    mnName = "半山拦截",
    missionDes = "自从白晶晶与孙悟空分开后，她就一直对紫霞仙子与法师心存怨念。这次法师重新西行取经，必定会百般阻扰。紫霞仙子要你去白虎岭阻止白晶晶，防止她陷害三藏法师。",
    acceptDes = "None",
    needCmp = {10615},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 89,
    rewardCoin = 39800,
    rewardGold = 0,
    rewardExp = 239052,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        6,
        10,
        false
      },
      talkId = 0,
      param = 0,
      des = "打败拦截你的妖怪#<Y,>美蔚君#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10617] = {
    mnName = "白晶晶",
    missionDes = "自从白晶晶与孙悟空分开后，她就一直对紫霞仙子与法师心存怨念。这次法师重新西行取经，必定会百般阻扰。紫霞仙子要你去白虎岭阻止白晶晶，防止她陷害三藏法师。",
    acceptDes = "None",
    needCmp = {10616},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 92,
    rewardCoin = 42900,
    rewardGold = 0,
    rewardExp = 257158,
    HelpWinAwardXiaYi = 440,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        6,
        11,
        false
      },
      talkId = 106171,
      param = 0,
      des = "劝解#<Y,>白晶晶#(建议组队前往)"
    },
    dst2 = {
      type = 101,
      data = 90937,
      talkId = 106172,
      param = 0,
      des = "将结果告诉#<Y,>紫霞仙子#"
    }
  },
  [10618] = {
    mnName = "忠告",
    missionDes = "自从白晶晶与孙悟空分开后，她就一直对紫霞仙子与法师心存怨念。这次法师重新西行取经，必定会百般阻扰。紫霞仙子要你去白虎岭阻止白晶晶，防止她陷害三藏法师。",
    acceptDes = "None",
    needCmp = {10617},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 92,
    rewardCoin = 17100,
    rewardGold = 0,
    rewardExp = 102863,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90937,
      talkId = 106181,
      param = 0,
      des = "与#<Y,>紫霞仙子#对话"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10619] = {
    mnName = "扫荡(1)",
    missionDes = "自从白晶晶与孙悟空分开后，她就一直对紫霞仙子与法师心存怨念。这次法师重新西行取经，必定会百般阻扰。紫霞仙子要你去白虎岭阻止白晶晶，防止她陷害三藏法师。",
    acceptDes = "None",
    needCmp = {10618},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 92,
    rewardCoin = 42900,
    rewardGold = 0,
    rewardExp = 257158,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        6,
        12,
        false
      },
      talkId = 0,
      param = 0,
      des = "为法师扫清障碍，消灭女妖#<Y,>玄女#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10620] = {
    mnName = "扫荡(2)",
    missionDes = "自从白晶晶与孙悟空分开后，她就一直对紫霞仙子与法师心存怨念。这次法师重新西行取经，必定会百般阻扰。紫霞仙子要你去白虎岭阻止白晶晶，防止她陷害三藏法师。",
    acceptDes = "None",
    needCmp = {10619},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 92,
    rewardCoin = 42900,
    rewardGold = 0,
    rewardExp = 257158,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        6,
        13,
        false
      },
      talkId = 0,
      param = 0,
      des = "扫除林中#<Y,>七情大王#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10621] = {
    mnName = "识破妖计",
    missionDes = "自从白晶晶与孙悟空分开后，她就一直对紫霞仙子与法师心存怨念。这次法师重新西行取经，必定会百般阻扰。紫霞仙子要你去白虎岭阻止白晶晶，防止她陷害三藏法师。",
    acceptDes = "None",
    needCmp = {10620},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 95,
    rewardCoin = 46100,
    rewardGold = 0,
    rewardExp = 276500,
    HelpWinAwardXiaYi = 440,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        6,
        14,
        false
      },
      talkId = 106211,
      param = 0,
      des = "打败#<Y,>白骨精#化身(建议组队前往)"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10622] = {
    mnName = "回复仙子",
    missionDes = "自从白晶晶与孙悟空分开后，她就一直对紫霞仙子与法师心存怨念。这次法师重新西行取经，必定会百般阻扰。紫霞仙子要你去白虎岭阻止白晶晶，防止她陷害三藏法师。",
    acceptDes = "None",
    needCmp = {10621},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 95,
    rewardCoin = 18400,
    rewardGold = 0,
    rewardExp = 110600,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90937,
      talkId = 106221,
      param = 0,
      des = "向#<Y,>紫霞仙子#复命"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10623] = {
    mnName = "强盗行恶",
    missionDes = "“我的随身包裹被强盗抢走了”这是在号山上法师见到你时他开口说的第一句话。法师希望你去南面的树林里帮他夺回包裹。",
    acceptDes = "None",
    needCmp = {10622},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 95,
    rewardCoin = 18400,
    rewardGold = 0,
    rewardExp = 110600,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90938,
      talkId = 106231,
      param = 0,
      des = "去号山找到#<Y,>三藏法师#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10624] = {
    mnName = "追踪(1)",
    missionDes = "“我的随身包裹被强盗抢走了”这是在号山上法师见到你时他开口说的第一句话。法师希望你去南面的树林里帮他夺回包裹。",
    acceptDes = "None",
    needCmp = {10623},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 95,
    rewardCoin = 46100,
    rewardGold = 0,
    rewardExp = 276500,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        6,
        15,
        false
      },
      talkId = 0,
      param = 0,
      des = "追赶逃窜至#<Y,>方寸山#里的强盗"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10625] = {
    mnName = "追踪(2)",
    missionDes = "“我的随身包裹被强盗抢走了”这是在号山上法师见到你时他开口说的第一句话。法师希望你去南面的树林里帮他夺回包裹。",
    acceptDes = "None",
    needCmp = {10624},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 97,
    rewardCoin = 48400,
    rewardGold = 0,
    rewardExp = 290122,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        6,
        16,
        false
      },
      talkId = 0,
      param = 0,
      des = "消灭#<Y,>迷识魔王#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10626] = {
    mnName = "包袱下落",
    missionDes = "“我的随身包裹被强盗抢走了”这是在号山上法师见到你时他开口说的第一句话。法师希望你去南面的树林里帮他夺回包裹。",
    acceptDes = "None",
    needCmp = {10625},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 97,
    rewardCoin = 48400,
    rewardGold = 0,
    rewardExp = 290122,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        6,
        17,
        false
      },
      talkId = 106261,
      wftalkId = 106262,
      param = 0,
      des = "从强盗同伙口中打听#<Y,>包袱#去向"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10627] = {
    mnName = "回复唐僧",
    missionDes = "“我的随身包裹被强盗抢走了”这是在号山上法师见到你时他开口说的第一句话。法师希望你去南面的树林里帮他夺回包裹。",
    acceptDes = "None",
    needCmp = {10626},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 97,
    rewardCoin = 19300,
    rewardGold = 0,
    rewardExp = 116049,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90938,
      talkId = 106271,
      param = 0,
      des = "向#<Y,>唐僧#复命"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10628] = {
    mnName = "行踪暴露",
    missionDes = "“我的随身包裹被强盗抢走了”这是在号山上法师见到你时他开口说的第一句话。法师希望你去南面的树林里帮他夺回包裹。",
    acceptDes = "None",
    needCmp = {10627},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 97,
    rewardCoin = 48400,
    rewardGold = 0,
    rewardExp = 290122,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        6,
        18,
        false
      },
      talkId = 106281,
      param = 0,
      des = "行踪暴露，击败妖怪喽啰#<Y,>云里雾#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10629] = {
    mnName = "追兵",
    missionDes = "“我的随身包裹被强盗抢走了”这是在号山上法师见到你时他开口说的第一句话。法师希望你去南面的树林里帮他夺回包裹。",
    acceptDes = "None",
    needCmp = {10628},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 97,
    rewardCoin = 48400,
    rewardGold = 0,
    rewardExp = 290122,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        6,
        19,
        false
      },
      talkId = 0,
      param = 0,
      des = "击败妖怪追兵#<Y,>快如风#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10630] = {
    mnName = "圣婴使者",
    missionDes = "“我的随身包裹被强盗抢走了”这是在号山上法师见到你时他开口说的第一句话。法师希望你去南面的树林里帮他夺回包裹。",
    acceptDes = "None",
    needCmp = {10629},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 99,
    rewardCoin = 50700,
    rewardGold = 0,
    rewardExp = 304357,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        6,
        20,
        false
      },
      talkId = 106301,
      param = 0,
      des = "消灭赶来的圣婴使者#<Y,>六丁目#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10631] = {
    mnName = "土地神",
    missionDes = "糟糕！那丢失的包裹彻底将法师的行踪暴露给了号山上的圣婴魔王，待你匆忙赶回原地时却发现法师早已经不见。此时，负责管理号山的土地神悄悄出现在了你身旁...",
    acceptDes = "None",
    needCmp = {10630},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 99,
    rewardCoin = 20300,
    rewardGold = 0,
    rewardExp = 121743,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90939,
      talkId = 106311,
      param = 0,
      des = "与#<Y,>土地#对话"
    },
    dst2 = {
      type = 101,
      data = 90939,
      talkId = 106312,
      param = 0,
      des = "继续与#<Y,>土地神#交谈"
    }
  },
  [10632] = {
    mnName = "真火宝珠",
    missionDes = "糟糕！那丢失的包裹彻底将法师的行踪暴露给了号山上的圣婴魔王，待你匆忙赶回原地时却发现法师早已经不见。此时，负责管理号山的土地神悄悄出现在了你身旁...",
    acceptDes = "None",
    needCmp = {10631},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 99,
    rewardCoin = 50700,
    rewardGold = 0,
    rewardExp = 304357,
    HelpWinAwardXiaYi = 40,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        6,
        21,
        false
      },
      talkId = 0,
      param = 0,
      des = "去石梯毁掉#<Y,>真火宝珠#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10633] = {
    mnName = "圣婴大王(6称)",
    missionDes = "糟糕！那丢失的包裹彻底将法师的行踪暴露给了号山上的圣婴魔王，待你匆忙赶回原地时却发现法师早已经不见。此时，负责管理号山的土地神悄悄出现在了你身旁...",
    acceptDes = "None",
    needCmp = {10632},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 99,
    rewardCoin = 50700,
    rewardGold = 0,
    rewardExp = 304357,
    HelpWinAwardXiaYi = 440,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 202,
      data = {
        6,
        22,
        false
      },
      talkId = 0,
      param = {
        {
          21017,
          1,
          100
        }
      },
      des = "打败#<Y,>红孩儿#救出法师(建议组队前往)"
    },
    dst2 = {
      type = 402,
      data = 90938,
      talkId = 106341,
      param = {
        {21017, 1}
      },
      des = "将#<Y,>包袱#交给三藏法师"
    }
  },
  [10634] = {
    mnName = "不详先兆(6称)",
    missionDes = "糟糕！那丢失的包裹彻底将法师的行踪暴露给了号山上的圣婴魔王，待你匆忙赶回原地时却发现法师早已经不见。此时，负责管理号山的土地神悄悄出现在了你身旁...",
    acceptDes = "None",
    needCmp = {10633},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 99,
    rewardCoin = 20300,
    rewardGold = 0,
    rewardExp = 121743,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 106351,
      param = 0,
      des = "向#<Y,>紫霞仙子#复命"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10701] = {
    mnName = "衙役的苦恼",
    missionDes = "入我长生教，皆可得长生。这是大唐近期最热门的长生教的教义。中间一些人为了筹够入教的银两无恶不作，使得大唐的犯罪率急剧上升。这不，长安城杂货商就深受此害。",
    acceptDes = "None",
    needCmp = {10634},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 100,
    rewardCoin = 20800,
    rewardGold = 0,
    rewardExp = 124685,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90921,
      talkId = 107011,
      param = 0,
      des = "向#<Y,>衙役#打听长安城的近况"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10702] = {
    mnName = "了解情况",
    missionDes = "入我长生教，皆可得长生。这是大唐近期最热门的长生教的教义。中间一些人为了筹够入教的银两无恶不作，使得大唐的犯罪率急剧上升。这不，长安城杂货商就深受此害。",
    acceptDes = "None",
    needCmp = {10701},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 100,
    rewardCoin = 20800,
    rewardGold = 0,
    rewardExp = 124685,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90908,
      talkId = 107021,
      param = 0,
      des = "向#<Y,>杂货商#了解被骗的经过"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10703] = {
    mnName = "杂货商的儿子",
    missionDes = "入我长生教，皆可得长生。这是大唐近期最热门的长生教的教义。中间一些人为了筹够入教的银两无恶不作，使得大唐的犯罪率急剧上升。这不，长安城杂货商就深受此害。",
    acceptDes = "None",
    needCmp = {10702},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 100,
    rewardCoin = 52000,
    rewardGold = 0,
    rewardExp = 311712,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        7,
        1,
        false
      },
      talkId = 107031,
      wftalkId = 107032,
      param = 0,
      des = "去长安郊外找到#<Y,>杂货商的儿子#,并将他救出"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10704] = {
    mnName = "追回银票",
    missionDes = "从杂货商老板口中得知夺回的银票中有一部分是属于长安城首富钱掌柜的。你决定将这些银票替钱掌柜送去。",
    acceptDes = "None",
    needCmp = {10703},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 100,
    rewardCoin = 52000,
    rewardGold = 0,
    rewardExp = 311712,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 202,
      data = {
        7,
        2,
        false
      },
      talkId = 0,
      param = {
        {
          21012,
          1,
          100
        }
      },
      des = "追回被骗得#<Y,>银票#"
    },
    dst2 = {
      type = 402,
      data = 90908,
      talkId = 107042,
      param = {
        {21012, 1}
      },
      des = "将银票交给#<Y,>杂货商#"
    }
  },
  [10705] = {
    mnName = "银票(1)",
    missionDes = "从杂货商老板口中得知夺回的银票中有一部分是属于长安城首富钱掌柜的。你决定将这些银票替钱掌柜送去。",
    acceptDes = "None",
    needCmp = {10704},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 100,
    rewardCoin = 26000,
    rewardGold = 0,
    rewardExp = 155856,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 90908,
      talkId = 107051,
      param = {
        {21012, 1}
      },
      des = "继续与#<Y,>杂货商#交谈"
    },
    dst2 = {
      type = 402,
      data = 90941,
      talkId = 107052,
      param = {
        {21012, 1}
      },
      des = "将银票带给#<Y,>钱掌柜#"
    }
  },
  [10706] = {
    mnName = "银票(2)",
    missionDes = "从杂货商老板口中得知夺回的银票中有一部分是属于长安城首富钱掌柜的。你决定将这些银票替钱掌柜送去。",
    acceptDes = "None",
    needCmp = {10705},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 100,
    rewardCoin = 26000,
    rewardGold = 0,
    rewardExp = 155856,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 90941,
      talkId = 107061,
      param = {
        {21012, 1}
      },
      des = "继续与#<Y,>钱掌柜#交谈"
    },
    dst2 = {
      type = 402,
      data = 90921,
      talkId = 107062,
      param = {
        {21012, 1}
      },
      des = "将银票交给#<Y,>衙役#"
    }
  },
  [10707] = {
    mnName = "清理余孽(1)",
    missionDes = "为了阻止长生教的恶性发展，朝廷将长生教列入邪教名单。根据朝廷颁下来的密令，衙役找到了你，希望你能帮朝廷铲除长生教众教徒。",
    acceptDes = "None",
    needCmp = {10706},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 102,
    rewardCoin = 54500,
    rewardGold = 0,
    rewardExp = 326917,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        7,
        3,
        false
      },
      talkId = 0,
      param = 0,
      des = "帮助衙役清理躲在#<Y,>女儿国#的长生教教徒"
    },
    dst2 = {
      type = 101,
      data = 90921,
      talkId = 107072,
      param = 0,
      des = "向#<Y,>衙役#复命"
    }
  },
  [10708] = {
    mnName = "清理余孽(2)",
    missionDes = "为了阻止长生教的恶性发展，朝廷将长生教列入邪教名单。根据朝廷颁下来的密令，衙役找到了你，希望你能帮朝廷铲除长生教众教徒。",
    acceptDes = "None",
    needCmp = {10707},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 102,
    rewardCoin = 54500,
    rewardGold = 0,
    rewardExp = 326917,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        7,
        4,
        false
      },
      talkId = 0,
      param = 0,
      des = "帮助衙役清理躲在#<Y,>火焰山#的长生教教徒"
    },
    dst2 = {
      type = 101,
      data = 90921,
      talkId = 107082,
      param = 0,
      des = "向#<Y,>衙役#复命"
    }
  },
  [10709] = {
    mnName = "逃跑的教徒",
    missionDes = "为了阻止长生教的恶性发展，朝廷将长生教列入邪教名单。根据朝廷颁下来的密令，衙役找到了你，希望你能帮朝廷铲除长生教众教徒。",
    acceptDes = "None",
    needCmp = {10708},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 102,
    rewardCoin = 54500,
    rewardGold = 0,
    rewardExp = 326917,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        7,
        5,
        false
      },
      talkId = 107091,
      param = 0,
      des = "将躲在#<Y,>渔村#的长生教教徒一网打尽"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10710] = {
    mnName = "回复衙役",
    missionDes = "为了阻止长生教的恶性发展，朝廷将长生教列入邪教名单。根据朝廷颁下来的密令，衙役找到了你，希望你能帮朝廷铲除长生教众教徒。",
    acceptDes = "None",
    needCmp = {10709},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 102,
    rewardCoin = 21800,
    rewardGold = 0,
    rewardExp = 130766,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90921,
      talkId = 107101,
      param = 0,
      des = "向#<Y,>衙役#复命"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10711] = {
    mnName = "仙子解惑",
    missionDes = "长生教在朝廷的围剿下迅速败退，但这只是表面的胜利。此教为什么发展的如此迅速？他的起源又是哪里，这一切都需要你去解密。",
    acceptDes = "None",
    needCmp = {10710},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 102,
    rewardCoin = 21800,
    rewardGold = 0,
    rewardExp = 130766,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 107111,
      param = 0,
      des = "与#<Y,>紫霞仙子#谈谈"
    },
    dst2 = {
      type = 101,
      data = 90907,
      talkId = 107112,
      param = 0,
      des = "与#<Y,>紫霞仙子#对话"
    }
  },
  [10712] = {
    mnName = "搜查罪证(1)",
    missionDes = "长生教在朝廷的围剿下迅速败退，但这只是表面的胜利。此教为什么发展的如此迅速？他的起源又是哪里，这一切都需要你去解密。",
    acceptDes = "None",
    needCmp = {10711},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 104,
    rewardCoin = 57100,
    rewardGold = 0,
    rewardExp = 342803,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        7,
        6,
        false
      },
      talkId = 0,
      param = 0,
      des = "调查长生教是否源于#<Y,>方寸山#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10713] = {
    mnName = "搜查罪证(2)",
    missionDes = "长生教在朝廷的围剿下迅速败退，但这只是表面的胜利。此教为什么发展的如此迅速？他的起源又是哪里，这一切都需要你去解密。",
    acceptDes = "None",
    needCmp = {10712},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 104,
    rewardCoin = 57100,
    rewardGold = 0,
    rewardExp = 342803,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        7,
        7,
        false
      },
      talkId = 0,
      param = 0,
      des = "调查长生教是否源于#<Y,>方寸山#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10714] = {
    mnName = "搜查罪证(3)",
    missionDes = "长生教在朝廷的围剿下迅速败退，但这只是表面的胜利。此教为什么发展的如此迅速？他的起源又是哪里，这一切都需要你去解密。",
    acceptDes = "None",
    needCmp = {10713},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 104,
    rewardCoin = 57100,
    rewardGold = 0,
    rewardExp = 342803,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        7,
        8,
        false
      },
      talkId = 107141,
      param = 0,
      des = "调查长生教是否源于#<Y,>方寸山#"
    },
    dst2 = {
      type = 101,
      data = 90907,
      talkId = 107142,
      param = 0,
      des = "将调查结果告诉#<Y,>紫霞仙子#"
    }
  },
  [10715] = {
    mnName = "寻找真人(1)",
    missionDes = "长生教在朝廷的围剿下迅速败退，但这只是表面的胜利。此教为什么发展的如此迅速？他的起源又是哪里，这一切都需要你去解密。",
    acceptDes = "None",
    needCmp = {10714},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 104,
    rewardCoin = 57100,
    rewardGold = 0,
    rewardExp = 342803,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        7,
        9,
        false
      },
      talkId = 0,
      param = 0,
      des = "去#<Y,>贡香宝炉#处搜查罗真人踪迹"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10716] = {
    mnName = "寻找真人(2)",
    missionDes = "长生教在朝廷的围剿下迅速败退，但这只是表面的胜利。此教为什么发展的如此迅速？他的起源又是哪里，这一切都需要你去解密。",
    acceptDes = "None",
    needCmp = {10715},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 104,
    rewardCoin = 57100,
    rewardGold = 0,
    rewardExp = 342803,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        7,
        10,
        false
      },
      talkId = 0,
      param = 0,
      des = "探查罗真人住处#<Y,>宝正观#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10717] = {
    mnName = "罗真人",
    missionDes = "长生教在朝廷的围剿下迅速败退，但这只是表面的胜利。此教为什么发展的如此迅速？他的起源又是哪里，这一切都需要你去解密。",
    acceptDes = "None",
    needCmp = {10716},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 106,
    rewardCoin = 59900,
    rewardGold = 0,
    rewardExp = 359401,
    HelpWinAwardXiaYi = 450,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        7,
        11,
        false
      },
      talkId = 107151,
      param = 0,
      des = "前往#<Y,>清修居#调查情况(建议组队前往)"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10718] = {
    mnName = "回复仙子",
    missionDes = "为了破坏仙界根基，无天魔罗将封印于方寸后山中的赤炼妖姬给释放出来。没有菩提老祖坐镇的方寸山瞬间陷于妖姬的魔爪中。你必须立刻前往方寸后山，阻止无天魔罗的阴谋。",
    acceptDes = "None",
    needCmp = {10717},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 106,
    rewardCoin = 24000,
    rewardGold = 0,
    rewardExp = 143760,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 107161,
      param = 0,
      des = "将调查的情况告诉#<Y,>紫霞仙子#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10719] = {
    mnName = "调查后山(1)",
    missionDes = "为了破坏仙界根基，无天魔罗将封印于方寸后山中的赤炼妖姬给释放出来。没有菩提老祖坐镇的方寸山瞬间陷于妖姬的魔爪中。你必须立刻前往方寸后山，阻止无天魔罗的阴谋。",
    acceptDes = "None",
    needCmp = {10718},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 106,
    rewardCoin = 59900,
    rewardGold = 0,
    rewardExp = 359401,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        7,
        12,
        false
      },
      talkId = 0,
      param = 0,
      des = "探查方寸山#<Y,>后山#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10720] = {
    mnName = "调查后山(2)",
    missionDes = "为了破坏仙界根基，无天魔罗将封印于方寸后山中的赤炼妖姬给释放出来。没有菩提老祖坐镇的方寸山瞬间陷于妖姬的魔爪中。你必须立刻前往方寸后山，阻止无天魔罗的阴谋。",
    acceptDes = "None",
    needCmp = {10719},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 106,
    rewardCoin = 59900,
    rewardGold = 0,
    rewardExp = 359401,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        7,
        13,
        false
      },
      talkId = 0,
      wftalkId = 107172,
      param = 0,
      des = "盘问后山#<Y,>妖道童子#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10721] = {
    mnName = "调查后山(3)",
    missionDes = "为了破坏仙界根基，无天魔罗将封印于方寸后山中的赤炼妖姬给释放出来。没有菩提老祖坐镇的方寸山瞬间陷于妖姬的魔爪中。你必须立刻前往方寸后山，阻止无天魔罗的阴谋。",
    acceptDes = "None",
    needCmp = {10720},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 106,
    rewardCoin = 59900,
    rewardGold = 0,
    rewardExp = 359401,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        7,
        14,
        false
      },
      talkId = 0,
      param = 0,
      des = "消灭阻挡去路的#<Y,>守山熊#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10722] = {
    mnName = "调查后山(4)",
    missionDes = "为了破坏仙界根基，无天魔罗将封印于方寸后山中的赤炼妖姬给释放出来。没有菩提老祖坐镇的方寸山瞬间陷于妖姬的魔爪中。你必须立刻前往方寸后山，阻止无天魔罗的阴谋。",
    acceptDes = "None",
    needCmp = {10721},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 108,
    rewardCoin = 62800,
    rewardGold = 0,
    rewardExp = 376743,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        7,
        15,
        false
      },
      talkId = 107191,
      param = 0,
      des = "击败#<Y,>狐狸精#，试试能否得到信息"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10723] = {
    mnName = "回复仙子",
    missionDes = "为了破坏仙界根基，无天魔罗将封印于方寸后山中的赤炼妖姬给释放出来。没有菩提老祖坐镇的方寸山瞬间陷于妖姬的魔爪中。你必须立刻前往方寸后山，阻止无天魔罗的阴谋。",
    acceptDes = "None",
    needCmp = {10722},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 108,
    rewardCoin = 25100,
    rewardGold = 0,
    rewardExp = 150697,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 107201,
      param = 0,
      des = "将调查的情况告诉#<Y,>紫霞仙子#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10724] = {
    mnName = "探底(1)",
    missionDes = "为了破坏仙界根基，无天魔罗将封印于方寸后山中的赤炼妖姬给释放出来。没有菩提老祖坐镇的方寸山瞬间陷于妖姬的魔爪中。你必须立刻前往方寸后山，阻止无天魔罗的阴谋。",
    acceptDes = "None",
    needCmp = {10723},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 108,
    rewardCoin = 62800,
    rewardGold = 0,
    rewardExp = 376743,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        7,
        16,
        false
      },
      talkId = 0,
      param = 0,
      des = "继续深入方寸#<Y,>后山#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10725] = {
    mnName = "探底(2)",
    missionDes = "为了破坏仙界根基，无天魔罗将封印于方寸后山中的赤炼妖姬给释放出来。没有菩提老祖坐镇的方寸山瞬间陷于妖姬的魔爪中。你必须立刻前往方寸后山，阻止无天魔罗的阴谋。",
    acceptDes = "None",
    needCmp = {10724},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 108,
    rewardCoin = 62800,
    rewardGold = 0,
    rewardExp = 376743,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        7,
        17,
        false
      },
      talkId = 0,
      wftalkId = 107221,
      param = 0,
      des = "扫除阻挡去路的#<Y,>伶俐精#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10726] = {
    mnName = "指点方向",
    missionDes = "为了破坏仙界根基，无天魔罗将封印于方寸后山中的赤炼妖姬给释放出来。没有菩提老祖坐镇的方寸山瞬间陷于妖姬的魔爪中。你必须立刻前往方寸后山，阻止无天魔罗的阴谋。",
    acceptDes = "None",
    needCmp = {10725},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 108,
    rewardCoin = 25100,
    rewardGold = 0,
    rewardExp = 150697,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 107231,
      param = 0,
      des = "向#<Y,>紫霞仙子#复命"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10727] = {
    mnName = "破阵",
    missionDes = "为了破坏仙界根基，无天魔罗将封印于方寸后山中的赤炼妖姬给释放出来。没有菩提老祖坐镇的方寸山瞬间陷于妖姬的魔爪中。你必须立刻前往方寸后山，阻止无天魔罗的阴谋。",
    acceptDes = "None",
    needCmp = {10726},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 109,
    rewardCoin = 64300,
    rewardGold = 0,
    rewardExp = 385704,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        7,
        18,
        false
      },
      talkId = 0,
      wftalkId = 107241,
      param = 0,
      des = "破除#<Y,>呲显桥#处的阵眼"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10728] = {
    mnName = "深入调查",
    missionDes = "为了破坏仙界根基，无天魔罗将封印于方寸后山中的赤炼妖姬给释放出来。没有菩提老祖坐镇的方寸山瞬间陷于妖姬的魔爪中。你必须立刻前往方寸后山，阻止无天魔罗的阴谋。",
    acceptDes = "None",
    needCmp = {10727},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 109,
    rewardCoin = 64300,
    rewardGold = 0,
    rewardExp = 385704,
    HelpWinAwardXiaYi = 475,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        7,
        19,
        false
      },
      talkId = 107251,
      param = 0,
      des = "深入#<Y,>后山#调查妖怪首领(建议组队前往)"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10729] = {
    mnName = "赤炼妖姬",
    missionDes = "为了破坏仙界根基，无天魔罗将封印于方寸后山中的赤炼妖姬给释放出来。没有菩提老祖坐镇的方寸山瞬间陷于妖姬的魔爪中。你必须立刻前往方寸后山，阻止无天魔罗的阴谋。",
    acceptDes = "None",
    needCmp = {10728},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 109,
    rewardCoin = 25700,
    rewardGold = 0,
    rewardExp = 154281,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 107261,
      param = 0,
      des = "将调查到的情况告诉#<Y,>紫霞仙子#"
    },
    dst2 = {
      type = 101,
      data = 90942,
      talkId = 107262,
      param = 0,
      des = "向#<Y,>罗真人#打听线索"
    }
  },
  [10730] = {
    mnName = "查明异象",
    missionDes = "为了破坏仙界根基，无天魔罗将封印于方寸后山中的赤炼妖姬给释放出来。没有菩提老祖坐镇的方寸山瞬间陷于妖姬的魔爪中。你必须立刻前往方寸后山，阻止无天魔罗的阴谋。",
    acceptDes = "None",
    needCmp = {10729},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 109,
    rewardCoin = 64300,
    rewardGold = 0,
    rewardExp = 385704,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        7,
        20,
        false
      },
      talkId = 0,
      param = 0,
      des = "前去查明#<Y,>突豹泉#异象"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10731] = {
    mnName = "追查线索",
    missionDes = "为了破坏仙界根基，无天魔罗将封印于方寸后山中的赤炼妖姬给释放出来。没有菩提老祖坐镇的方寸山瞬间陷于妖姬的魔爪中。你必须立刻前往方寸后山，阻止无天魔罗的阴谋。",
    acceptDes = "None",
    needCmp = {10730},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 109,
    rewardCoin = 64300,
    rewardGold = 0,
    rewardExp = 385704,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        7,
        21,
        false
      },
      talkId = 0,
      param = 0,
      des = "追查#<Y,>圣果树#出现的线索"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10732] = {
    mnName = "消灭妖姬(7称)",
    missionDes = "为了破坏仙界根基，无天魔罗将封印于方寸后山中的赤炼妖姬给释放出来。没有菩提老祖坐镇的方寸山瞬间陷于妖姬的魔爪中。你必须立刻前往方寸后山，阻止无天魔罗的阴谋。",
    acceptDes = "None",
    needCmp = {10731},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 109,
    rewardCoin = 64300,
    rewardGold = 0,
    rewardExp = 385704,
    HelpWinAwardXiaYi = 475,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        7,
        22,
        false
      },
      talkId = 107291,
      param = 0,
      des = "消灭域外邪魔#<Y,>赤炼妖姬#(建议组队前往)"
    },
    dst2 = {
      type = 101,
      data = 90907,
      talkId = 107292,
      param = 0,
      des = "向#<Y,>紫霞仙子#交付任务"
    }
  },
  [10801] = {
    mnName = "路阻火焰山",
    missionDes = "当年齐天大圣大闹天宫时，一脚蹬倒了太上老君的八卦炉，致使炉中三块火石从天而降，形成了八百里的火焰山。此山无春无秋，四季皆热。凡人想要过这山，比登天还难...",
    acceptDes = "None",
    needCmp = {10732},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 110,
    rewardCoin = 26300,
    rewardGold = 0,
    rewardExp = 157944,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90943,
      talkId = 108011,
      param = 0,
      des = "#<Y,>土地神#有急事找你"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10802] = {
    mnName = "解渴之水",
    missionDes = "当年齐天大圣大闹天宫时，一脚蹬倒了太上老君的八卦炉，致使炉中三块火石从天而降，形成了八百里的火焰山。此山无春无秋，四季皆热。凡人想要过这山，比登天还难...",
    acceptDes = "None",
    needCmp = {10801},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 110,
    rewardCoin = 32900,
    rewardGold = 0,
    rewardExp = 197431,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 90943,
      talkId = 108012,
      param = {
        {21018, 1}
      },
      des = "与#<Y,>土地神#交谈取得清水"
    },
    dst2 = {
      type = 402,
      data = 90944,
      talkId = 108013,
      param = {
        {21018, 1}
      },
      des = "把水递给#<Y,>三藏法师#"
    }
  },
  [10803] = {
    mnName = "消灭火妖",
    missionDes = "当年齐天大圣大闹天宫时，一脚蹬倒了太上老君的八卦炉，致使炉中三块火石从天而降，形成了八百里的火焰山。此山无春无秋，四季皆热。凡人想要过这山，比登天还难...",
    acceptDes = "None",
    needCmp = {10802},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 110,
    rewardCoin = 65800,
    rewardGold = 0,
    rewardExp = 394862,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        8,
        1,
        false
      },
      talkId = 108021,
      param = 0,
      des = "去火焰山消灭#<Y,>赤焰妖#"
    },
    dst2 = {
      type = 101,
      data = 90944,
      talkId = 108022,
      param = 0,
      des = "向#<Y,>三藏法师#复命"
    }
  },
  [10804] = {
    mnName = "寻求办法",
    missionDes = "当年齐天大圣大闹天宫时，一脚蹬倒了太上老君的八卦炉，致使炉中三块火石从天而降，形成了八百里的火焰山。此山无春无秋，四季皆热。凡人想要过这山，比登天还难...",
    acceptDes = "None",
    needCmp = {10803},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 110,
    rewardCoin = 26300,
    rewardGold = 0,
    rewardExp = 157944,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90943,
      talkId = 108031,
      param = 0,
      des = "向#<Y,>土地神#求助"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10805] = {
    mnName = "消除隐患(1)",
    missionDes = "当年齐天大圣大闹天宫时，一脚蹬倒了太上老君的八卦炉，致使炉中三块火石从天而降，形成了八百里的火焰山。此山无春无秋，四季皆热。凡人想要过这山，比登天还难...",
    acceptDes = "None",
    needCmp = {10804},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 110,
    rewardCoin = 65800,
    rewardGold = 0,
    rewardExp = 394862,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        8,
        2,
        false
      },
      talkId = 0,
      param = 0,
      des = "为法师清除#<Y,>东面#的危险"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10806] = {
    mnName = "消除隐患(2)",
    missionDes = "当年齐天大圣大闹天宫时，一脚蹬倒了太上老君的八卦炉，致使炉中三块火石从天而降，形成了八百里的火焰山。此山无春无秋，四季皆热。凡人想要过这山，比登天还难...",
    acceptDes = "None",
    needCmp = {10805},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 113,
    rewardCoin = 70600,
    rewardGold = 0,
    rewardExp = 423571,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        8,
        3,
        false
      },
      talkId = 0,
      wftalkId = 108051,
      param = 0,
      des = "为法师清除#<Y,>西面#的危险"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10807] = {
    mnName = "缘由",
    missionDes = "当年齐天大圣大闹天宫时，一脚蹬倒了太上老君的八卦炉，致使炉中三块火石从天而降，形成了八百里的火焰山。此山无春无秋，四季皆热。凡人想要过这山，比登天还难...",
    acceptDes = "None",
    needCmp = {10806},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 113,
    rewardCoin = 28200,
    rewardGold = 0,
    rewardExp = 169428,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90943,
      talkId = 108061,
      param = 0,
      des = "询问#<Y,>土地神#火焰山的来历"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10808] = {
    mnName = "袁天罡之法",
    missionDes = "去积雷山拜见铁扇仙子之前，你最好给铁扇仙子准备一份见面礼，袁天罡说。按袁天罡的要求，替铁扇仙子准备礼物。",
    acceptDes = "None",
    needCmp = {10807},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 113,
    rewardCoin = 28200,
    rewardGold = 0,
    rewardExp = 169428,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90926,
      talkId = 108071,
      param = 0,
      des = "去长安找#<Y,>袁天罡#想办法"
    },
    dst2 = {
      type = 101,
      data = 90926,
      talkId = 108072,
      param = 0,
      des = "继续与#<Y,>袁天罡#交谈"
    }
  },
  [10809] = {
    mnName = "火焰晶石",
    missionDes = "去积雷山拜见铁扇仙子之前，你最好给铁扇仙子准备一份见面礼，袁天罡说。按袁天罡的要求，替铁扇仙子准备礼物。",
    acceptDes = "None",
    needCmp = {10808},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 113,
    rewardCoin = 70600,
    rewardGold = 0,
    rewardExp = 423571,
    HelpWinAwardXiaYi = 500,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 202,
      data = {
        8,
        4,
        false
      },
      talkId = 108081,
      param = {
        {
          21044,
          1,
          100
        }
      },
      des = "打败#<Y,>妖王#获得火焰晶石(建议组队前往)"
    },
    dst2 = {
      type = 402,
      data = 90926,
      talkId = 108082,
      param = {
        {21044, 1}
      },
      des = "将火焰晶石交给#<Y,>袁天罡#"
    }
  },
  [10810] = {
    mnName = "另一件事",
    missionDes = "去积雷山拜见铁扇仙子之前，你最好给铁扇仙子准备一份见面礼，袁天罡说。按袁天罡的要求，替铁扇仙子准备礼物。",
    acceptDes = "None",
    needCmp = {10809},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 113,
    rewardCoin = 28200,
    rewardGold = 0,
    rewardExp = 169428,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90926,
      talkId = 108083,
      param = 0,
      des = "继续与#<Y,>袁天罡#交谈"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10811] = {
    mnName = "骚乱小妖(1)",
    missionDes = "去积雷山拜见铁扇仙子之前，你最好给铁扇仙子准备一份见面礼，袁天罡说。按袁天罡的要求，替铁扇仙子准备礼物。",
    acceptDes = "None",
    needCmp = {10810},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 115,
    rewardCoin = 74000,
    rewardGold = 0,
    rewardExp = 443783,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        8,
        5,
        false
      },
      talkId = 0,
      param = 0,
      des = "探查#<Y,>火云高地#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10812] = {
    mnName = "骚乱小妖(2)",
    missionDes = "去积雷山拜见铁扇仙子之前，你最好给铁扇仙子准备一份见面礼，袁天罡说。按袁天罡的要求，替铁扇仙子准备礼物。",
    acceptDes = "None",
    needCmp = {10811},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 115,
    rewardCoin = 74000,
    rewardGold = 0,
    rewardExp = 443783,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        8,
        6,
        false
      },
      talkId = 0,
      param = 0,
      des = "探查#<Y,>牛骨堆#"
    },
    dst2 = {
      type = 101,
      data = 90926,
      talkId = 108084,
      param = 0,
      des = "回复#<Y,>袁天罡#"
    }
  },
  [10813] = {
    mnName = "天泉之水",
    missionDes = "去积雷山拜见铁扇仙子之前，你最好给铁扇仙子准备一份见面礼，袁天罡说。按袁天罡的要求，替铁扇仙子准备礼物。",
    acceptDes = "None",
    needCmp = {10812},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 115,
    rewardCoin = 29600,
    rewardGold = 0,
    rewardExp = 177513,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 91001,
      talkId = 108085,
      param = 0,
      des = "告诉#<Y,>小龙女#你的来意"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10814] = {
    mnName = "天泉之水",
    missionDes = "去积雷山拜见铁扇仙子之前，你最好给铁扇仙子准备一份见面礼，袁天罡说。按袁天罡的要求，替铁扇仙子准备礼物。",
    acceptDes = "None",
    needCmp = {10813},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 115,
    rewardCoin = 74000,
    rewardGold = 0,
    rewardExp = 443783,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        8,
        7,
        false
      },
      talkId = 0,
      param = 0,
      des = "替小龙女教训芭蕉洞#<Y,>宫女#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10815] = {
    mnName = "天泉之水",
    missionDes = "去积雷山拜见铁扇仙子之前，你最好给铁扇仙子准备一份见面礼，袁天罡说。按袁天罡的要求，替铁扇仙子准备礼物。",
    acceptDes = "None",
    needCmp = {10814},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 115,
    rewardCoin = 37000,
    rewardGold = 0,
    rewardExp = 221891,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 91001,
      talkId = 108086,
      param = {
        {21052, 1}
      },
      des = "回复小龙女,取得#<Y,>天泉水#"
    },
    dst2 = {
      type = 402,
      data = 90926,
      talkId = 108087,
      param = {
        {21052, 1}
      },
      des = "将天泉水交给#<Y,>袁天罡#"
    }
  },
  [10816] = {
    mnName = "琥珀晶",
    missionDes = "去积雷山拜见铁扇仙子之前，你最好给铁扇仙子准备一份见面礼，袁天罡说。按袁天罡的要求，替铁扇仙子准备礼物。",
    acceptDes = "None",
    needCmp = {10815},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 115,
    rewardCoin = 37000,
    rewardGold = 0,
    rewardExp = 221891,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 90926,
      talkId = 108088,
      param = {
        {21053, 1}
      },
      des = "向袁天罡取得#<Y,>琥珀晶#"
    },
    dst2 = {
      type = 402,
      data = 90946,
      talkId = 108111,
      param = {
        {21053, 1}
      },
      des = "将琥珀晶送予#<Y,>铁扇仙子#"
    }
  },
  [10817] = {
    mnName = "三事之约",
    missionDes = "想要铁扇仙子将宝扇借你，还需完成仙子口中的三件事。与铁扇仙子对话，完成三事之约。",
    acceptDes = "None",
    needCmp = {10816},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 116,
    rewardCoin = 30300,
    rewardGold = 0,
    rewardExp = 181690,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90946,
      talkId = 108112,
      param = 0,
      des = "继续与#<Y,>铁扇仙子#交谈"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10818] = {
    mnName = "蝎子洞",
    missionDes = "想要铁扇仙子将宝扇借你，还需完成仙子口中的三件事。与铁扇仙子对话，完成三事之约。",
    acceptDes = "None",
    needCmp = {10817},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 116,
    rewardCoin = 75700,
    rewardGold = 0,
    rewardExp = 454225,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        8,
        8,
        false
      },
      talkId = 0,
      param = 0,
      des = "探查#<Y,>干裂之地#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10819] = {
    mnName = "报仇",
    missionDes = "想要铁扇仙子将宝扇借你，还需完成仙子口中的三件事。与铁扇仙子对话，完成三事之约。",
    acceptDes = "None",
    needCmp = {10818},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 116,
    rewardCoin = 75700,
    rewardGold = 0,
    rewardExp = 454225,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        8,
        9,
        false
      },
      talkId = 0,
      param = 0,
      des = "完成第一件事,消灭#<Y,>蝎子精#"
    },
    dst2 = {
      type = 101,
      data = 90946,
      talkId = 108132,
      param = 0,
      des = "向#<Y,>铁扇仙子#复命"
    }
  },
  [10820] = {
    mnName = "教训狐狸精",
    missionDes = "想要铁扇仙子将宝扇借你，还需完成仙子口中的三件事。与铁扇仙子对话，完成三事之约。",
    acceptDes = "None",
    needCmp = {10819},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 116,
    rewardCoin = 75700,
    rewardGold = 0,
    rewardExp = 454225,
    HelpWinAwardXiaYi = 500,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        8,
        10,
        false
      },
      talkId = 108141,
      param = 0,
      des = "完成第二件事,教训#<Y,>狐狸精#(建议组队前往)"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10821] = {
    mnName = "回复公主",
    missionDes = "想要铁扇仙子将宝扇借你，还需完成仙子口中的三件事。与铁扇仙子对话，完成三事之约。",
    acceptDes = "None",
    needCmp = {10820},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 116,
    rewardCoin = 30300,
    rewardGold = 0,
    rewardExp = 181690,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90946,
      talkId = 108151,
      param = 0,
      des = "向#<Y,>铁扇仙子#复命"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10822] = {
    mnName = "第三件事情",
    missionDes = "想要铁扇仙子将宝扇借你，还需完成仙子口中的三件事。与铁扇仙子对话，完成三事之约。",
    acceptDes = "None",
    needCmp = {10821},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 116,
    rewardCoin = 30300,
    rewardGold = 0,
    rewardExp = 181690,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90946,
      talkId = 108161,
      param = 0,
      des = "询问#<Y,>铁扇仙子#第三件事情"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10823] = {
    mnName = "魔王踪迹",
    missionDes = "想要铁扇仙子将宝扇借你，还需完成仙子口中的三件事。与铁扇仙子对话，完成三事之约。",
    acceptDes = "None",
    needCmp = {10822},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 117,
    rewardCoin = 77500,
    rewardGold = 0,
    rewardExp = 464897,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        8,
        11,
        false
      },
      talkId = 0,
      wftalkId = 108172,
      param = 0,
      des = "打听#<Y,>牛魔王#的踪迹"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10824] = {
    mnName = "火焰台",
    missionDes = "想要铁扇仙子将宝扇借你，还需完成仙子口中的三件事。与铁扇仙子对话，完成三事之约。",
    acceptDes = "None",
    needCmp = {10823},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 117,
    rewardCoin = 77500,
    rewardGold = 0,
    rewardExp = 464897,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        8,
        12,
        false
      },
      talkId = 0,
      wftalkId = 108182,
      param = 0,
      des = "去火焰台打听#<Y,>牛魔王#踪迹"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10825] = {
    mnName = "教训牛魔王",
    missionDes = "想要铁扇仙子将宝扇借你，还需完成仙子口中的三件事。与铁扇仙子对话，完成三事之约。",
    acceptDes = "None",
    needCmp = {10824},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 117,
    rewardCoin = 77500,
    rewardGold = 0,
    rewardExp = 464897,
    HelpWinAwardXiaYi = 500,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        8,
        13,
        false
      },
      talkId = 108191,
      param = 0,
      des = "教训#<Y,>牛魔王#(建议组队前往)"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10826] = {
    mnName = "复命",
    missionDes = "想要铁扇仙子将宝扇借你，还需完成仙子口中的三件事。与铁扇仙子对话，完成三事之约。",
    acceptDes = "None",
    needCmp = {10825},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 117,
    rewardCoin = 31000,
    rewardGold = 0,
    rewardExp = 185959,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90946,
      talkId = 108201,
      param = 0,
      des = "告知#<Y,>铁扇仙子#三事已完"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10827] = {
    mnName = "秘闻",
    missionDes = "牛魔王告诉你宝扇灭火之法只治标不治本，如想彻底解决火焰山上的大火，还需请教土地才行。向土地打听灭火的之法。",
    acceptDes = "None",
    needCmp = {10826},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 117,
    rewardCoin = 31000,
    rewardGold = 0,
    rewardExp = 185959,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90947,
      talkId = 108211,
      param = 0,
      des = "与#<Y,>牛魔王#交谈"
    },
    dst2 = {
      type = 101,
      data = 90943,
      talkId = 108212,
      param = 0,
      des = "向#<Y,>土地神#打听灭火秘闻"
    }
  },
  [10828] = {
    mnName = "氤氲灵气",
    missionDes = "土地告诉你，要灭其大火，必先取得芭蕉扇中的氤氲灵气作为护身。灵气一旦从扇中剥离，芭蕉扇将会变成一把普通的扇子。你需要向铁扇仙子表决心，让她帮你取得扇中灵气。",
    acceptDes = "None",
    needCmp = {10827},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 120,
    rewardCoin = 33200,
    rewardGold = 0,
    rewardExp = 199339,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90946,
      talkId = 108221,
      param = 0,
      des = "获得宝扇中的#<Y,>氤氲灵气#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10829] = {
    mnName = "天石下落",
    missionDes = "饱受炎热之苦的铁扇仙子答应了你请求,将扇中灵气附于你身上。趁现在灵气护体，赶紧去浇灭火焰山的大火吧。",
    acceptDes = "None",
    needCmp = {10828},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 120,
    rewardCoin = 33200,
    rewardGold = 0,
    rewardExp = 199339,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90943,
      talkId = 108231,
      param = 0,
      des = "找#<Y,>土地神#打听天石下落"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10830] = {
    mnName = "清剿(1)",
    missionDes = "饱受炎热之苦的铁扇仙子答应了你请求,将扇中灵气附于你身上。趁现在灵气护体，赶紧去浇灭火焰山的大火吧。",
    acceptDes = "None",
    needCmp = {10829},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 120,
    rewardCoin = 83100,
    rewardGold = 0,
    rewardExp = 498349,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        8,
        14,
        false
      },
      talkId = 0,
      param = 0,
      des = "清剿#<Y,>火焰谷#外围的妖怪"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10831] = {
    mnName = "清剿(2)",
    missionDes = "饱受炎热之苦的铁扇仙子答应了你请求,将扇中灵气附于你身上。趁现在灵气护体，赶紧去浇灭火焰山的大火吧。",
    acceptDes = "None",
    needCmp = {10830},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 120,
    rewardCoin = 83100,
    rewardGold = 0,
    rewardExp = 498349,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        8,
        15,
        false
      },
      talkId = 0,
      param = 0,
      des = "清剿#<Y,>火焰谷#谷内出现的妖怪"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10832] = {
    mnName = "第一块天石",
    missionDes = "饱受炎热之苦的铁扇仙子答应了你请求,将扇中灵气附于你身上。趁现在灵气护体，赶紧去浇灭火焰山的大火吧。",
    acceptDes = "None",
    needCmp = {10831},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 120,
    rewardCoin = 83100,
    rewardGold = 0,
    rewardExp = 498349,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        8,
        16,
        false
      },
      talkId = 108261,
      param = 0,
      des = "浇灭第一块天石中的#<Y,>火灵#"
    },
    dst2 = {
      type = 101,
      data = 90943,
      talkId = 108262,
      param = 0,
      des = "向#<Y,>土地神#复命"
    }
  },
  [10833] = {
    mnName = "天石下落",
    missionDes = "饱受炎热之苦的铁扇仙子答应了你请求,将扇中灵气附于你身上。趁现在灵气护体，赶紧去浇灭火焰山的大火吧。",
    acceptDes = "None",
    needCmp = {10832},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 120,
    rewardCoin = 33200,
    rewardGold = 0,
    rewardExp = 199339,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90943,
      talkId = 108271,
      param = 0,
      des = "继续向#<Y,>土地神#打听天石下落"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10834] = {
    mnName = "清理(1)",
    missionDes = "饱受炎热之苦的铁扇仙子答应了你请求,将扇中灵气附于你身上。趁现在灵气护体，赶紧去浇灭火焰山的大火吧。",
    acceptDes = "None",
    needCmp = {10833},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 120,
    rewardCoin = 83100,
    rewardGold = 0,
    rewardExp = 498349,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        8,
        17,
        false
      },
      talkId = 0,
      param = 0,
      des = "探查#<Y,>绝望之地#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10835] = {
    mnName = "清理(2)",
    missionDes = "饱受炎热之苦的铁扇仙子答应了你请求,将扇中灵气附于你身上。趁现在灵气护体，赶紧去浇灭火焰山的大火吧。",
    acceptDes = "None",
    needCmp = {10834},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 120,
    rewardCoin = 83100,
    rewardGold = 0,
    rewardExp = 498349,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        8,
        18,
        false
      },
      talkId = 0,
      param = 0,
      des = "探查#<Y,>岩溶地带#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10836] = {
    mnName = "第二块天石",
    missionDes = "饱受炎热之苦的铁扇仙子答应了你请求,将扇中灵气附于你身上。趁现在灵气护体，赶紧去浇灭火焰山的大火吧。",
    acceptDes = "None",
    needCmp = {10835},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 120,
    rewardCoin = 83100,
    rewardGold = 0,
    rewardExp = 498349,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        8,
        19,
        false
      },
      talkId = 108301,
      param = 0,
      des = "浇灭第二块天石中的#<Y,>火灵#"
    },
    dst2 = {
      type = 101,
      data = 90943,
      talkId = 108302,
      param = 0,
      des = "向#<Y,>土地神#复命"
    }
  },
  [10837] = {
    mnName = "天石下落",
    missionDes = "饱受炎热之苦的铁扇仙子答应了你请求,将扇中灵气附于你身上。趁现在灵气护体，赶紧去浇灭火焰山的大火吧。",
    acceptDes = "None",
    needCmp = {10836},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 120,
    rewardCoin = 33200,
    rewardGold = 0,
    rewardExp = 199339,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90943,
      talkId = 108311,
      param = 0,
      des = "向#<Y,>土地神#打听第三块天石的下落"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10838] = {
    mnName = "解除厄难(1)",
    missionDes = "饱受炎热之苦的铁扇仙子答应了你请求,将扇中灵气附于你身上。趁现在灵气护体，赶紧去浇灭火焰山的大火吧。",
    acceptDes = "None",
    needCmp = {10837},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 120,
    rewardCoin = 83100,
    rewardGold = 0,
    rewardExp = 498349,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        8,
        20,
        false
      },
      talkId = 0,
      wftalkId = 108321,
      param = 0,
      des = "探查#<Y,>化铁池#,消灭群妖"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10839] = {
    mnName = "解除厄难(2)",
    missionDes = "饱受炎热之苦的铁扇仙子答应了你请求,将扇中灵气附于你身上。趁现在灵气护体，赶紧去浇灭火焰山的大火吧。",
    acceptDes = "None",
    needCmp = {10838},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 120,
    rewardCoin = 83100,
    rewardGold = 0,
    rewardExp = 498349,
    HelpWinAwardXiaYi = 50,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        8,
        21,
        false
      },
      talkId = 0,
      param = 0,
      des = "探查#<Y,>枯井#,消灭群妖"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10840] = {
    mnName = "第三块天石(8称)",
    missionDes = "饱受炎热之苦的铁扇仙子答应了你请求,将扇中灵气附于你身上。趁现在灵气护体，赶紧去浇灭火焰山的大火吧。",
    acceptDes = "None",
    needCmp = {10839},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 120,
    rewardCoin = 83100,
    rewardGold = 0,
    rewardExp = 498349,
    HelpWinAwardXiaYi = 500,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        8,
        22,
        false
      },
      talkId = 108341,
      param = 0,
      des = "浇灭第三块天石中的#<Y,>火灵#(建议组队前往)"
    },
    dst2 = {
      type = 101,
      data = 90943,
      talkId = 108342,
      param = 0,
      des = "向#<Y,>土地神#复命"
    }
  },
  [10901] = {
    mnName = "生病",
    missionDes = "法师经过子母河时，见河水清澈透净，口渴的他喝了一口河水，瞬间觉得腹痛难忍。你见法师肚子疼痛，决定去前面看看有没有医馆。",
    acceptDes = "None",
    needCmp = {10840},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 125,
    rewardCoin = 37300,
    rewardGold = 0,
    rewardExp = 223679,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90948,
      talkId = 109011,
      param = 0,
      des = "问问#<Y,>三藏法师#发生了什么事"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10902] = {
    mnName = "探查药馆",
    missionDes = "法师经过子母河时，见河水清澈透净，口渴的他喝了一口河水，瞬间觉得腹痛难忍。你见法师肚子疼痛，决定去前面看看有没有医馆。",
    acceptDes = "None",
    needCmp = {10901},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 125,
    rewardCoin = 93200,
    rewardGold = 0,
    rewardExp = 559199,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        9,
        1,
        false
      },
      talkId = 0,
      param = 0,
      des = "去前方看看有没有医馆"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10903] = {
    mnName = "奇怪的人",
    missionDes = "法师经过子母河时，见河水清澈透净，口渴的他喝了一口河水，瞬间觉得腹痛难忍。你见法师肚子疼痛，决定去前面看看有没有医馆。",
    acceptDes = "None",
    needCmp = {10902},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 125,
    rewardCoin = 37300,
    rewardGold = 0,
    rewardExp = 223679,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90949,
      talkId = 109031,
      param = 0,
      des = "向#<Y,>鱼怪#打听附近可有医馆"
    },
    dst2 = {
      type = 101,
      data = 90949,
      talkId = 109032,
      param = 0,
      des = "继续与#<Y,>河神#交谈"
    }
  },
  [10904] = {
    mnName = "杏林路",
    missionDes = "想要解除法师腹中胎气，就需要河神的琉璃瓶。但琉璃瓶被子母河中的妖怪夺走了。你决定帮助河神夺回琉璃瓶。",
    acceptDes = "None",
    needCmp = {10903},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 125,
    rewardCoin = 93200,
    rewardGold = 0,
    rewardExp = 559199,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        9,
        2,
        false
      },
      talkId = 0,
      param = 0,
      des = "消灭河边#<Y,>鱼妖#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10905] = {
    mnName = "夺回琉璃瓶",
    missionDes = "想要解除法师腹中胎气，就需要河神的琉璃瓶。但琉璃瓶被子母河中的妖怪夺走了。你决定帮助河神夺回琉璃瓶。",
    acceptDes = "None",
    needCmp = {10904},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 125,
    rewardCoin = 93200,
    rewardGold = 0,
    rewardExp = 559199,
    HelpWinAwardXiaYi = 510,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 202,
      data = {
        9,
        3,
        false
      },
      talkId = 109051,
      param = {
        {
          21019,
          1,
          100
        }
      },
      des = "从#<Y,>冥月猫妖#手中夺回琉璃瓶(建议组队前往)"
    },
    dst2 = {
      type = 402,
      data = 90949,
      talkId = 109052,
      param = {
        {21019, 1}
      },
      des = "将琉璃瓶交给#<Y,>河神#"
    }
  },
  [10906] = {
    mnName = "落阳之水(1)",
    missionDes = "光有琉璃瓶是不够的，还需要落阳水。从河神口中打听落阳水的下落，取得落阳水。",
    acceptDes = "None",
    needCmp = {10905},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 126,
    rewardCoin = 38100,
    rewardGold = 0,
    rewardExp = 228873,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90949,
      talkId = 109061,
      param = 0,
      des = "找#<Y,>河神#打听后续之法"
    },
    dst2 = {
      type = 101,
      data = 90948,
      talkId = 109062,
      param = 0,
      des = "询问#<Y,>三藏法师#病情如何"
    }
  },
  [10907] = {
    mnName = "缓解之法",
    missionDes = "光有琉璃瓶是不够的，还需要落阳水。从河神口中打听落阳水的下落，取得落阳水。",
    acceptDes = "None",
    needCmp = {10906},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 126,
    rewardCoin = 38100,
    rewardGold = 0,
    rewardExp = 228873,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90949,
      talkId = 109071,
      param = 0,
      des = "向#<Y,>河神#求助"
    },
    dst2 = {
      type = 101,
      data = 90951,
      talkId = 109072,
      param = 0,
      des = "找#<Y,>容婆婆#打听白术果下落"
    }
  },
  [10908] = {
    mnName = "肆乱之妖",
    missionDes = "光有琉璃瓶是不够的，还需要落阳水。从河神口中打听落阳水的下落，取得落阳水。",
    acceptDes = "None",
    needCmp = {10907},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 126,
    rewardCoin = 95400,
    rewardGold = 0,
    rewardExp = 572184,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        9,
        4,
        false
      },
      talkId = 0,
      param = 0,
      des = "消灭骚扰村民的#<Y,>妖怪#"
    },
    dst2 = {
      type = 101,
      data = 90951,
      talkId = 109081,
      param = 0,
      des = "继续向#<Y,>容婆婆#打听白术果的下落"
    }
  },
  [10909] = {
    mnName = "容婆婆的请求",
    missionDes = "光有琉璃瓶是不够的，还需要落阳水。从河神口中打听落阳水的下落，取得落阳水。",
    acceptDes = "None",
    needCmp = {10908},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 126,
    rewardCoin = 95400,
    rewardGold = 0,
    rewardExp = 572184,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        9,
        5,
        false
      },
      talkId = 0,
      param = 0,
      des = "帮助容婆婆消灭那些占地为王的#<Y,>冥灵妖#"
    },
    dst2 = {
      type = 101,
      data = 90951,
      talkId = 109091,
      param = 0,
      des = "向#<Y,>容婆婆#复命"
    }
  },
  [10910] = {
    mnName = "缓解腹痛",
    missionDes = "光有琉璃瓶是不够的，还需要落阳水。从河神口中打听落阳水的下落，取得落阳水。",
    acceptDes = "None",
    needCmp = {10909},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 126,
    rewardCoin = 47700,
    rewardGold = 0,
    rewardExp = 286092,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 90951,
      talkId = 109092,
      param = {
        {21022, 1}
      },
      des = "继续与#<Y,>容婆婆#交谈，取得白术果"
    },
    dst2 = {
      type = 402,
      data = 90948,
      talkId = 109093,
      param = {
        {21022, 1}
      },
      des = "将白术果交给#<Y,>三藏法师#服用"
    }
  },
  [10911] = {
    mnName = "落阳之水(2)",
    missionDes = "光有琉璃瓶是不够的，还需要落阳水。从河神口中打听落阳水的下落，取得落阳水。",
    acceptDes = "None",
    needCmp = {10910},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 126,
    rewardCoin = 95400,
    rewardGold = 0,
    rewardExp = 572184,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 202,
      data = {
        9,
        6,
        false
      },
      talkId = 109101,
      param = {
        {
          21023,
          1,
          100
        }
      },
      des = "从#<Y,>聚仙庵#中取得落阳水"
    },
    dst2 = {
      type = 402,
      data = 90949,
      talkId = 109102,
      param = {
        {21023, 1}
      },
      des = "将落阳水交给#<Y,>河神#去除毒性"
    }
  },
  [10912] = {
    mnName = "解除腹痛",
    missionDes = "光有琉璃瓶是不够的，还需要落阳水。从河神口中打听落阳水的下落，取得落阳水。",
    acceptDes = "None",
    needCmp = {10911},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 126,
    rewardCoin = 47700,
    rewardGold = 0,
    rewardExp = 286092,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 90949,
      talkId = 109111,
      param = {
        {21023, 1}
      },
      des = "与#<Y,>河神#交谈取得落阳水"
    },
    dst2 = {
      type = 402,
      data = 90948,
      talkId = 109112,
      param = {
        {21023, 1}
      },
      des = "向#<Y,>唐僧#复命"
    }
  },
  [10913] = {
    mnName = "河神解惑",
    missionDes = "落阳水的高价使得如意真仙和他的一帮徒弟们疯狂卖水，完全不顾饮用之人是否会有生命危险出现。河神希望你能为此地百姓着想，将这些毒瘤铲除。",
    acceptDes = "None",
    needCmp = {10912},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 126,
    rewardCoin = 38100,
    rewardGold = 0,
    rewardExp = 228873,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90949,
      talkId = 109121,
      param = 0,
      des = "与#<Y,>河神#对话"
    },
    dst2 = {
      type = 101,
      data = 90949,
      talkId = 109122,
      param = 0,
      des = "继续与#<Y,>河神#交谈"
    }
  },
  [10914] = {
    mnName = "摧毁庙宇(1)",
    missionDes = "落阳水的高价使得如意真仙和他的一帮徒弟们疯狂卖水，完全不顾饮用之人是否会有生命危险出现。河神希望你能为此地百姓着想，将这些毒瘤铲除。",
    acceptDes = "None",
    needCmp = {10913},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 127,
    rewardCoin = 97600,
    rewardGold = 0,
    rewardExp = 585455,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        9,
        7,
        false
      },
      talkId = 0,
      param = 0,
      des = "摧毁#<Y,>解阳山#中的道观"
    },
    dst2 = {
      type = 101,
      data = 90949,
      talkId = 109131,
      param = 0,
      des = "向#<Y,>河神#复命"
    }
  },
  [10915] = {
    mnName = "摧毁庙宇(2)",
    missionDes = "落阳水的高价使得如意真仙和他的一帮徒弟们疯狂卖水，完全不顾饮用之人是否会有生命危险出现。河神希望你能为此地百姓着想，将这些毒瘤铲除。",
    acceptDes = "None",
    needCmp = {10914},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 127,
    rewardCoin = 97600,
    rewardGold = 0,
    rewardExp = 585455,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        9,
        8,
        false
      },
      talkId = 0,
      param = 0,
      des = "摧毁#<Y,>赤峡谷#中的道观"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10916] = {
    mnName = "回复河神",
    missionDes = "落阳水的高价使得如意真仙和他的一帮徒弟们疯狂卖水，完全不顾饮用之人是否会有生命危险出现。河神希望你能为此地百姓着想，将这些毒瘤铲除。",
    acceptDes = "None",
    needCmp = {10915},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 127,
    rewardCoin = 39000,
    rewardGold = 0,
    rewardExp = 234182,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90949,
      talkId = 109151,
      param = 0,
      des = "向#<Y,>河神#复命"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10917] = {
    mnName = "铲除毒瘤",
    missionDes = "落阳水的高价使得如意真仙和他的一帮徒弟们疯狂卖水，完全不顾饮用之人是否会有生命危险出现。河神希望你能为此地百姓着想，将这些毒瘤铲除。",
    acceptDes = "None",
    needCmp = {10916},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 127,
    rewardCoin = 97600,
    rewardGold = 0,
    rewardExp = 585455,
    HelpWinAwardXiaYi = 510,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        9,
        9,
        false
      },
      talkId = 109161,
      param = 0,
      des = "铲除#<Y,>如意真仙#(建议组队前往)"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10918] = {
    mnName = "回复河神",
    missionDes = "落阳水的高价使得如意真仙和他的一帮徒弟们疯狂卖水，完全不顾饮用之人是否会有生命危险出现。河神希望你能为此地百姓着想，将这些毒瘤铲除。",
    acceptDes = "None",
    needCmp = {10917},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 127,
    rewardCoin = 39000,
    rewardGold = 0,
    rewardExp = 234182,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90949,
      talkId = 109171,
      param = 0,
      des = "向#<Y,>河神#交付任务"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10919] = {
    mnName = "婚事",
    missionDes = "女儿国的国王马上要举行婚礼了，在这个举国欢庆之时，你发现新郎居然是法师，这个发现可把你吓了一跳。赶紧将此消息告诉紫霞仙子，确定下一步的行动计划。",
    acceptDes = "None",
    needCmp = {10918},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 127,
    rewardCoin = 39000,
    rewardGold = 0,
    rewardExp = 234182,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90951,
      talkId = 109181,
      param = 0,
      des = "询问#<Y,>容婆婆#在干什么"
    },
    dst2 = {
      type = 101,
      data = 90951,
      talkId = 109182,
      param = 0,
      des = "继续#<Y,>容婆婆#交谈"
    }
  },
  [10920] = {
    mnName = "回复仙子",
    missionDes = "原来法师命中注定有这一劫。但不管如何，还是先找到法师向他确认此事的真实性吧。紫霞仙子要你找到法师，确认事情的真实性。",
    acceptDes = "None",
    needCmp = {10919},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 127,
    rewardCoin = 39000,
    rewardGold = 0,
    rewardExp = 234182,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 109191,
      param = 0,
      des = "将女儿国婚事告知#<Y,>紫霞仙子#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10921] = {
    mnName = "探查行踪(1)",
    missionDes = "原来法师命中注定有这一劫。但不管如何，还是先找到法师向他确认此事的真实性吧。紫霞仙子要你找到法师，确认事情的真实性。",
    acceptDes = "None",
    needCmp = {10920},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 127,
    rewardCoin = 97600,
    rewardGold = 0,
    rewardExp = 585455,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        9,
        10,
        false
      },
      talkId = 0,
      param = 0,
      des = "探查#<Y,>康庄大道#,寻找法师踪迹"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10922] = {
    mnName = "探查行踪(2)",
    missionDes = "原来法师命中注定有这一劫。但不管如何，还是先找到法师向他确认此事的真实性吧。紫霞仙子要你找到法师，确认事情的真实性。",
    acceptDes = "None",
    needCmp = {10921},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 128,
    rewardCoin = 99800,
    rewardGold = 0,
    rewardExp = 599018,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        9,
        11,
        false
      },
      talkId = 0,
      param = 0,
      des = "探查#<Y,>护城桥#,寻找法师踪迹"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10923] = {
    mnName = "探查行踪(3)",
    missionDes = "原来法师命中注定有这一劫。但不管如何，还是先找到法师向他确认此事的真实性吧。紫霞仙子要你找到法师，确认事情的真实性。",
    acceptDes = "None",
    needCmp = {10922},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 128,
    rewardCoin = 99800,
    rewardGold = 0,
    rewardExp = 599018,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        9,
        12,
        false
      },
      talkId = 109221,
      param = 0,
      des = "探查#<Y,>城关#,寻找法师踪迹"
    },
    dst2 = {
      type = 101,
      data = 90907,
      talkId = 109222,
      param = 0,
      des = "找到#<Y,>紫霞仙子#"
    }
  },
  [10924] = {
    mnName = "孽缘",
    missionDes = "传闻清心符能清除一个人的痴念。紫霞仙子要你找到镇元大仙，向他求借此符，替法师破开命中情结。",
    acceptDes = "None",
    needCmp = {10923},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 128,
    rewardCoin = 39900,
    rewardGold = 0,
    rewardExp = 239607,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90952,
      talkId = 109231,
      param = 0,
      des = "找到#<Y,>三藏法师#"
    },
    dst2 = {
      type = 101,
      data = 90907,
      talkId = 109232,
      param = 0,
      des = "找#<Y,>紫霞仙子#商量对策"
    }
  },
  [10925] = {
    mnName = "求借仙符",
    missionDes = "传闻清心符能清除一个人的痴念。紫霞仙子要你找到镇元大仙，向他求借此符，替法师破开命中情结。",
    acceptDes = "None",
    needCmp = {10924},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 128,
    rewardCoin = 39900,
    rewardGold = 0,
    rewardExp = 239607,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90903,
      talkId = 109241,
      param = 0,
      des = "找#<Y,>镇元大仙#求借清心符"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10926] = {
    mnName = "思念之情",
    missionDes = "传闻清心符能清除一个人的痴念。紫霞仙子要你找到镇元大仙，向他求借此符，替法师破开命中情结。",
    acceptDes = "None",
    needCmp = {10925},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 128,
    rewardCoin = 99800,
    rewardGold = 0,
    rewardExp = 599018,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        9,
        13,
        false
      },
      talkId = 109251,
      param = 0,
      des = "去#<Y,>万凤林#填埋泪之湖"
    },
    dst2 = {
      type = 101,
      data = 90903,
      talkId = 109252,
      param = 0,
      des = "向#<Y,>镇元大仙#复命"
    }
  },
  [10927] = {
    mnName = "询问第二情",
    missionDes = "传闻清心符能清除一个人的痴念。紫霞仙子要你找到镇元大仙，向他求借此符，替法师破开命中情结。",
    acceptDes = "None",
    needCmp = {10926},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 128,
    rewardCoin = 39900,
    rewardGold = 0,
    rewardExp = 239607,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90903,
      talkId = 109261,
      param = 0,
      des = "询问#<Y,>镇元大仙#什么是寄望之情"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10928] = {
    mnName = "寄望之情",
    missionDes = "传闻清心符能清除一个人的痴念。紫霞仙子要你找到镇元大仙，向他求借此符，替法师破开命中情结。",
    acceptDes = "None",
    needCmp = {10927},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 128,
    rewardCoin = 99800,
    rewardGold = 0,
    rewardExp = 599018,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        9,
        14,
        false
      },
      talkId = 0,
      param = 0,
      des = "去#<Y,>宫殿#烧毁手帕"
    },
    dst2 = {
      type = 101,
      data = 90903,
      talkId = 109271,
      param = 0,
      des = "向#<Y,>镇元大仙#复命"
    }
  },
  [10929] = {
    mnName = "清心符",
    missionDes = "传闻清心符能清除一个人的痴念。紫霞仙子要你找到镇元大仙，向他求借此符，替法师破开命中情结。",
    acceptDes = "None",
    needCmp = {10928},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 128,
    rewardCoin = 49900,
    rewardGold = 0,
    rewardExp = 299509,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 90903,
      talkId = 109281,
      param = {
        {21024, 1}
      },
      des = "向#<Y,>镇元大仙#取得清心符"
    },
    dst2 = {
      type = 401,
      data = {
        7,
        30,
        11
      },
      talkId = 0,
      param = {
        {21024, 1}
      },
      des = "在城外使用#<Y,>清心符#"
    }
  },
  [10930] = {
    mnName = "消灭情根",
    missionDes = "传闻清心符能清除一个人的痴念。紫霞仙子要你找到镇元大仙，向他求借此符，替法师破开命中情结。",
    acceptDes = "None",
    needCmp = {10929},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 128,
    rewardCoin = 99800,
    rewardGold = 0,
    rewardExp = 599018,
    HelpWinAwardXiaYi = 510,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        9,
        15,
        false
      },
      talkId = 109291,
      param = 0,
      des = "消灭#<Y,>女王的情根#(建议组队前往)"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10931] = {
    mnName = "送行",
    missionDes = "三世痴念已被你解除，相信国王不会向法师逼婚了。赶紧将此消息告诉法师吧。",
    acceptDes = "None",
    needCmp = {10930},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 128,
    rewardCoin = 39900,
    rewardGold = 0,
    rewardExp = 239607,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90952,
      talkId = 109301,
      param = 0,
      des = "与#<Y,>法师#会合"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10932] = {
    mnName = "千里追踪(1)",
    missionDes = "刚出狼窝，又入虎穴。桃花运泛滥的法师这才脱离女儿国国王囚禁，又被一个看上他的女妖精给摄走，唉！向国王打听此地情况，救出被掳走的法师。",
    acceptDes = "None",
    needCmp = {10931},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 128,
    rewardCoin = 99800,
    rewardGold = 0,
    rewardExp = 599018,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        9,
        16,
        false
      },
      talkId = 0,
      wftalkId = 109311,
      param = 0,
      des = "探查#<Y,>谷堆#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10933] = {
    mnName = "千里追踪(2)",
    missionDes = "刚出狼窝，又入虎穴。桃花运泛滥的法师这才脱离女儿国国王囚禁，又被一个看上他的女妖精给摄走，唉！向国王打听此地情况，救出被掳走的法师。",
    acceptDes = "None",
    needCmp = {10932},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 130,
    rewardCoin = 104500,
    rewardGold = 0,
    rewardExp = 627044,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        9,
        17,
        false
      },
      talkId = 0,
      wftalkId = 109322,
      param = 0,
      des = "探查#<Y,>泥泞路#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10934] = {
    mnName = "打听情况",
    missionDes = "刚出狼窝，又入虎穴。桃花运泛滥的法师这才脱离女儿国国王囚禁，又被一个看上他的女妖精给摄走，唉！向国王打听此地情况，救出被掳走的法师。",
    acceptDes = "None",
    needCmp = {10933},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 130,
    rewardCoin = 41800,
    rewardGold = 0,
    rewardExp = 250817,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90954,
      talkId = 109331,
      param = 0,
      des = "向#<Y,>国王#打听附近情况"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10935] = {
    mnName = "蝎兵",
    missionDes = "刚出狼窝，又入虎穴。桃花运泛滥的法师这才脱离女儿国国王囚禁，又被一个看上他的女妖精给摄走，唉！向国王打听此地情况，救出被掳走的法师。",
    acceptDes = "None",
    needCmp = {10934},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 130,
    rewardCoin = 104500,
    rewardGold = 0,
    rewardExp = 627044,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        9,
        18,
        false
      },
      talkId = 109341,
      param = 0,
      des = "探查#<Y,>毒敌山#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10936] = {
    mnName = "求助",
    missionDes = "刚出狼窝，又入虎穴。桃花运泛滥的法师这才脱离女儿国国王囚禁，又被一个看上他的女妖精给摄走，唉！向国王打听此地情况，救出被掳走的法师。",
    acceptDes = "None",
    needCmp = {10935},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 130,
    rewardCoin = 41800,
    rewardGold = 0,
    rewardExp = 250817,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 109351,
      param = 0,
      des = "找#<Y,>紫霞仙子#想办法"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10937] = {
    mnName = "雄黄粉(1)",
    missionDes = "刚出狼窝，又入虎穴。桃花运泛滥的法师这才脱离女儿国国王囚禁，又被一个看上他的女妖精给摄走，唉！向国王打听此地情况，救出被掳走的法师。",
    acceptDes = "None",
    needCmp = {10936},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 130,
    rewardCoin = 41800,
    rewardGold = 0,
    rewardExp = 250817,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90908,
      talkId = 109361,
      param = 0,
      des = "找#<Y,>杂货商#买雄黄粉"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10938] = {
    mnName = "双叉岭妖兽",
    missionDes = "刚出狼窝，又入虎穴。桃花运泛滥的法师这才脱离女儿国国王囚禁，又被一个看上他的女妖精给摄走，唉！向国王打听此地情况，救出被掳走的法师。",
    acceptDes = "None",
    needCmp = {10937},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 130,
    rewardCoin = 104500,
    rewardGold = 0,
    rewardExp = 627044,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        9,
        19,
        false
      },
      talkId = 0,
      param = 0,
      des = "消灭#<Y,>双叉岭#里的妖兽"
    },
    dst2 = {
      type = 101,
      data = 90908,
      talkId = 109371,
      param = 0,
      des = "向#<Y,>杂货商#复命"
    }
  },
  [10939] = {
    mnName = "雄黄粉(2)",
    missionDes = "刚出狼窝，又入虎穴。桃花运泛滥的法师这才脱离女儿国国王囚禁，又被一个看上他的女妖精给摄走，唉！向国王打听此地情况，救出被掳走的法师。",
    acceptDes = "None",
    needCmp = {10938},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 130,
    rewardCoin = 52300,
    rewardGold = 0,
    rewardExp = 313522,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 90908,
      talkId = 109381,
      param = {
        {21026, 1}
      },
      des = "继续与#<Y,>杂货商#交谈取得雄黄粉"
    },
    dst2 = {
      type = 401,
      data = {
        2,
        95,
        61
      },
      talkId = 0,
      param = {
        {21026, 1}
      },
      des = "去#<Y,>河边#将雄黄粉撒在身上"
    }
  },
  [10940] = {
    mnName = "深入蝎山(1)",
    missionDes = "刚出狼窝，又入虎穴。桃花运泛滥的法师这才脱离女儿国国王囚禁，又被一个看上他的女妖精给摄走，唉！向国王打听此地情况，救出被掳走的法师。",
    acceptDes = "None",
    needCmp = {10939},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 130,
    rewardCoin = 104500,
    rewardGold = 0,
    rewardExp = 627044,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        9,
        20,
        false
      },
      talkId = 0,
      param = 0,
      des = "消灭阻你去路的#<Y,>火焰妖#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10941] = {
    mnName = "深入蝎山(2)",
    missionDes = "刚出狼窝，又入虎穴。桃花运泛滥的法师这才脱离女儿国国王囚禁，又被一个看上他的女妖精给摄走，唉！向国王打听此地情况，救出被掳走的法师。",
    acceptDes = "None",
    needCmp = {10940},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 130,
    rewardCoin = 104500,
    rewardGold = 0,
    rewardExp = 627044,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        9,
        21,
        false
      },
      talkId = 0,
      param = 0,
      des = "消灭毒卫#<Y,>毒刺儿#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [10942] = {
    mnName = "扫荡蝎子精(9称)",
    missionDes = "刚出狼窝，又入虎穴。桃花运泛滥的法师这才脱离女儿国国王囚禁，又被一个看上他的女妖精给摄走，唉！向国王打听此地情况，救出被掳走的法师。",
    acceptDes = "None",
    needCmp = {10941},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 130,
    rewardCoin = 104500,
    rewardGold = 0,
    rewardExp = 627044,
    HelpWinAwardXiaYi = 510,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        9,
        22,
        false
      },
      talkId = 109411,
      param = 0,
      des = "消灭的#<Y,>琵琶精#,救出法师(建议组队前往)"
    },
    dst2 = {
      type = 101,
      data = 90955,
      talkId = 109412,
      param = 0,
      des = "与#<Y,>三藏法师#交谈"
    }
  },
  [10943] = {
    mnName = "通关牒文(9称)",
    missionDes = "刚出狼窝，又入虎穴。桃花运泛滥的法师这才脱离女儿国国王囚禁，又被一个看上他的女妖精给摄走，唉！向国王打听此地情况，救出被掳走的法师。",
    acceptDes = "None",
    needCmp = {10942},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 130,
    rewardCoin = 52300,
    rewardGold = 0,
    rewardExp = 313522,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 90954,
      talkId = 109421,
      param = {
        {21027, 1}
      },
      des = "向#<Y,>国王#取回通关文牒"
    },
    dst2 = {
      type = 402,
      data = 90955,
      talkId = 109422,
      param = {
        {21027, 1}
      },
      des = "将文牒交给#<Y,>三藏法师#"
    }
  },
  [11001] = {
    mnName = "仙子召唤",
    missionDes = "大雁塔中逃出去的其中三妖联合了无天魔罗，欲破坏整个人界，达到摧毁天地牢笼的目的。仙子需要你查到三妖的隐藏地点，去找袁天罡吧，他或许会有办法。",
    acceptDes = "None",
    needCmp = {10943},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 131,
    rewardCoin = 42800,
    rewardGold = 0,
    rewardExp = 256608,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 110011,
      param = 0,
      des = "询问#<Y,>紫霞仙子#发生何事"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11002] = {
    mnName = "袁天罡的委托",
    missionDes = "大雁塔中逃出去的其中三妖联合了无天魔罗，欲破坏整个人界，达到摧毁天地牢笼的目的。仙子需要你查到三妖的隐藏地点，去找袁天罡吧，他或许会有办法。",
    acceptDes = "None",
    needCmp = {11001},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 131,
    rewardCoin = 53500,
    rewardGold = 0,
    rewardExp = 320760,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 90926,
      talkId = 110021,
      param = {
        {21028, 1}
      },
      des = "找#<Y,>袁天罡#打听情况"
    },
    dst2 = {
      type = 402,
      data = 90928,
      talkId = 110022,
      param = {
        {21028, 1}
      },
      des = "将信交给#<Y,>李鬼谷#"
    }
  },
  [11003] = {
    mnName = "口信",
    missionDes = "大雁塔中逃出去的其中三妖联合了无天魔罗，欲破坏整个人界，达到摧毁天地牢笼的目的。仙子需要你查到三妖的隐藏地点，去找袁天罡吧，他或许会有办法。",
    acceptDes = "None",
    needCmp = {11002},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 131,
    rewardCoin = 42800,
    rewardGold = 0,
    rewardExp = 256608,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90928,
      talkId = 110031,
      param = 0,
      des = "#<Y,>李鬼谷#有事找你"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11004] = {
    mnName = "李鬼谷的口信",
    missionDes = "大雁塔中逃出去的其中三妖联合了无天魔罗，欲破坏整个人界，达到摧毁天地牢笼的目的。仙子需要你查到三妖的隐藏地点，去找袁天罡吧，他或许会有办法。",
    acceptDes = "None",
    needCmp = {11003},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 131,
    rewardCoin = 42800,
    rewardGold = 0,
    rewardExp = 256608,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90926,
      talkId = 110041,
      param = 0,
      des = "将口信告诉#<Y,>袁天罡#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11005] = {
    mnName = "凶象",
    missionDes = "大雁塔中逃出去的其中三妖联合了无天魔罗，欲破坏整个人界，达到摧毁天地牢笼的目的。仙子需要你查到三妖的隐藏地点，去找袁天罡吧，他或许会有办法。",
    acceptDes = "None",
    needCmp = {11004},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 131,
    rewardCoin = 42800,
    rewardGold = 0,
    rewardExp = 256608,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 110051,
      param = 0,
      des = "将结果告知#<Y,>紫霞仙子#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11006] = {
    mnName = "调查狮驼国",
    missionDes = "“白虎易位，三星结阵，破”这是李鬼谷通过星辰之术的推演三妖而得出的结果。根据袁天罡的解释，前往狮驼国调查情况。",
    acceptDes = "None",
    needCmp = {11005},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 131,
    rewardCoin = 106900,
    rewardGold = 0,
    rewardExp = 641520,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        10,
        1,
        false
      },
      talkId = 110061,
      wftalkId = 110062,
      param = 0,
      des = "遭遇#<Y,>神秘老头#阻拦"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11007] = {
    mnName = "一探究竟",
    missionDes = "“白虎易位，三星结阵，破”这是李鬼谷通过星辰之术的推演三妖而得出的结果。根据袁天罡的解释，前往狮驼国调查情况。",
    acceptDes = "None",
    needCmp = {11006},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 133,
    rewardCoin = 44800,
    rewardGold = 0,
    rewardExp = 268573,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90956,
      talkId = 110071,
      param = 0,
      des = "去龙宫找到#<Y,>神秘老人#"
    },
    dst2 = {
      type = 101,
      data = 90977,
      talkId = 110072,
      param = 0,
      des = "与#<Y,>太白金星#交谈"
    }
  },
  [11008] = {
    mnName = "骨骸之地(1)",
    missionDes = "“白虎易位，三星结阵，破”这是李鬼谷通过星辰之术的推演三妖而得出的结果。根据袁天罡的解释，前往狮驼国调查情况。",
    acceptDes = "None",
    needCmp = {11007},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 133,
    rewardCoin = 111900,
    rewardGold = 0,
    rewardExp = 671433,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        10,
        2,
        false
      },
      talkId = 0,
      param = 0,
      des = "杀死守卫#<Y,>武棍熊妖#,进入骨骸之地"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11009] = {
    mnName = "骨骸之地(2)",
    missionDes = "“白虎易位，三星结阵，破”这是李鬼谷通过星辰之术的推演三妖而得出的结果。根据袁天罡的解释，前往狮驼国调查情况。",
    acceptDes = "None",
    needCmp = {11008},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 133,
    rewardCoin = 111900,
    rewardGold = 0,
    rewardExp = 671433,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        10,
        3,
        false
      },
      talkId = 0,
      param = 0,
      des = "穿越#<Y,>骨骸之地#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11010] = {
    mnName = "妖精营寨",
    missionDes = "“白虎易位，三星结阵，破”这是李鬼谷通过星辰之术的推演三妖而得出的结果。根据袁天罡的解释，前往狮驼国调查情况。",
    acceptDes = "None",
    needCmp = {11009},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 133,
    rewardCoin = 111900,
    rewardGold = 0,
    rewardExp = 671433,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        10,
        4,
        false
      },
      talkId = 110101,
      param = 0,
      des = "消灭营寨里的#<Y,>小妖队长#"
    },
    dst2 = {
      type = 101,
      data = 90977,
      talkId = 110102,
      param = 0,
      des = "向#<Y,>太白金星#复命"
    }
  },
  [11011] = {
    mnName = "小分队",
    missionDes = "“白虎易位，三星结阵，破”这是李鬼谷通过星辰之术的推演三妖而得出的结果。根据袁天罡的解释，前往狮驼国调查情况。",
    acceptDes = "None",
    needCmp = {11010},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 133,
    rewardCoin = 111900,
    rewardGold = 0,
    rewardExp = 671433,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        10,
        5,
        false
      },
      talkId = 0,
      param = 0,
      des = "在魔王寨寻找#<Y,>幸存者#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11012] = {
    mnName = "幸存者的请求",
    missionDes = "通过幸存者提供的线索，将被困于黑风寨中的人们解救出来。",
    acceptDes = "None",
    needCmp = {11011},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 133,
    rewardCoin = 44800,
    rewardGold = 0,
    rewardExp = 268573,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90957,
      talkId = 110121,
      param = 0,
      des = "听听#<Y,>幸存者#说些什么"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11013] = {
    mnName = "解药",
    missionDes = "通过幸存者提供的线索，将被困于黑风寨中的人们解救出来。",
    acceptDes = "None",
    needCmp = {11012},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 133,
    rewardCoin = 111900,
    rewardGold = 0,
    rewardExp = 671433,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        10,
        6,
        false
      },
      talkId = 0,
      param = 0,
      des = "消灭#<Y,>玄英洞#值守妖怪"
    },
    dst2 = {
      type = 101,
      data = 90957,
      talkId = 110132,
      param = 0,
      des = "向#<Y,>幸存者#复命"
    }
  },
  [11014] = {
    mnName = "救人",
    missionDes = "通过幸存者提供的线索，将被困于黑风寨中的人们解救出来。",
    acceptDes = "None",
    needCmp = {11013},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 133,
    rewardCoin = 44800,
    rewardGold = 0,
    rewardExp = 268573,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90957,
      talkId = 110141,
      param = 0,
      des = "向#<Y,>幸存者#打听狮驼岭的情况"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11015] = {
    mnName = "黑风老妖",
    missionDes = "通过幸存者提供的线索，将被困于黑风寨中的人们解救出来。",
    acceptDes = "None",
    needCmp = {11014},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 134,
    rewardCoin = 114500,
    rewardGold = 0,
    rewardExp = 686884,
    HelpWinAwardXiaYi = 510,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        10,
        7,
        false
      },
      talkId = 110151,
      param = 0,
      des = "消灭#<Y,>黑风老妖#,拯救被关押的百姓(建议组队前往)"
    },
    dst2 = {
      type = 101,
      data = 90957,
      talkId = 110152,
      param = 0,
      des = "向#<Y,>幸存者#交付任务"
    }
  },
  [11016] = {
    mnName = "回复仙子",
    missionDes = "原本一个欣欣向荣的矿石国邦硬被三妖破坏的惨不忍睹，遍地都是血池，残尸，到处可见奇形怪异的妖怪。将调查的结果告诉紫霞仙子，好为大唐做预防。",
    acceptDes = "None",
    needCmp = {11015},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 134,
    rewardCoin = 45800,
    rewardGold = 0,
    rewardExp = 274753,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 110161,
      param = 0,
      des = "将狮驼国的情况告知#<Y,>紫霞仙子#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11017] = {
    mnName = "矿石下落",
    missionDes = "事出无常必有妖。妖怪们囚禁凡人居然是为了让他们在地洞里挖矿石。想不通此事的紫霞仙子要你必须找回一块矿石回来，来解答他们此番的行径。",
    acceptDes = "None",
    needCmp = {11016},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 134,
    rewardCoin = 45800,
    rewardGold = 0,
    rewardExp = 274753,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90957,
      talkId = 110171,
      param = 0,
      des = "与#<Y,>幸存者#交谈"
    },
    dst2 = {
      type = 101,
      data = 90957,
      talkId = 110172,
      param = 0,
      des = "向#<Y,>幸存者#打听矿石的情况"
    }
  },
  [11018] = {
    mnName = "清理障碍",
    missionDes = "事出无常必有妖。妖怪们囚禁凡人居然是为了让他们在地洞里挖矿石。想不通此事的紫霞仙子要你必须找回一块矿石回来，来解答他们此番的行径。",
    acceptDes = "None",
    needCmp = {11017},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 134,
    rewardCoin = 114500,
    rewardGold = 0,
    rewardExp = 686884,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        10,
        8,
        false
      },
      talkId = 0,
      param = 0,
      des = "探查#<Y,>熊罢窟#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11019] = {
    mnName = "回复幸存者",
    missionDes = "事出无常必有妖。妖怪们囚禁凡人居然是为了让他们在地洞里挖矿石。想不通此事的紫霞仙子要你必须找回一块矿石回来，来解答他们此番的行径。",
    acceptDes = "None",
    needCmp = {11018},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 134,
    rewardCoin = 45800,
    rewardGold = 0,
    rewardExp = 274753,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90957,
      talkId = 110191,
      param = 0,
      des = "向#<Y,>幸存者#复命"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11020] = {
    mnName = "探查野猪林",
    missionDes = "事出无常必有妖。妖怪们囚禁凡人居然是为了让他们在地洞里挖矿石。想不通此事的紫霞仙子要你必须找回一块矿石回来，来解答他们此番的行径。",
    acceptDes = "None",
    needCmp = {11019},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 134,
    rewardCoin = 114500,
    rewardGold = 0,
    rewardExp = 686884,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        10,
        9,
        false
      },
      talkId = 0,
      param = 0,
      des = "探查#<Y,>野猪林#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11021] = {
    mnName = "夺取矿石",
    missionDes = "事出无常必有妖。妖怪们囚禁凡人居然是为了让他们在地洞里挖矿石。想不通此事的紫霞仙子要你必须找回一块矿石回来，来解答他们此番的行径。",
    acceptDes = "None",
    needCmp = {11020},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 134,
    rewardCoin = 114500,
    rewardGold = 0,
    rewardExp = 686884,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 202,
      data = {
        10,
        10,
        false
      },
      talkId = 110211,
      param = {
        {
          21030,
          1,
          100
        }
      },
      des = "从#<Y,>迷魂蛇精#手中夺取矿石"
    },
    dst2 = {
      type = 402,
      data = 90907,
      talkId = 110212,
      param = {
        {21030, 1}
      },
      des = "将矿石交给#<Y,>紫霞仙子#辨认"
    }
  },
  [11022] = {
    mnName = "寻找观音",
    missionDes = "看守紫竹林的黑熊精不能忍受常年吃斋，拿走了菩萨的法宝之一天罡刀且偷溜下界。此事让菩萨的座下弟子小龙女十分气愤。小龙女要你去熊寨教训黑熊，夺回宝刀。",
    acceptDes = "None",
    needCmp = {11021},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 134,
    rewardCoin = 45800,
    rewardGold = 0,
    rewardExp = 274753,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90904,
      talkId = 110221,
      param = 0,
      des = "向#<Y,>观音菩萨#求助"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11023] = {
    mnName = "天罡刀",
    missionDes = "看守紫竹林的黑熊精不能忍受常年吃斋，拿走了菩萨的法宝之一天罡刀且偷溜下界。此事让菩萨的座下弟子小龙女十分气愤。小龙女要你去熊寨教训黑熊，夺回宝刀。",
    acceptDes = "None",
    needCmp = {11022},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 134,
    rewardCoin = 45800,
    rewardGold = 0,
    rewardExp = 274753,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 91001,
      talkId = 110231,
      param = 0,
      des = "找到菩萨弟子#<Y,>小龙女#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11024] = {
    mnName = "教训黑熊(1)",
    missionDes = "看守紫竹林的黑熊精不能忍受常年吃斋，拿走了菩萨的法宝之一天罡刀且偷溜下界。此事让菩萨的座下弟子小龙女十分气愤。小龙女要你去熊寨教训黑熊，夺回宝刀。",
    acceptDes = "None",
    needCmp = {11023},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 135,
    rewardCoin = 117100,
    rewardGold = 0,
    rewardExp = 702673,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        10,
        11,
        false
      },
      talkId = 0,
      param = 0,
      des = "探查#<Y,>腐石林#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11025] = {
    mnName = "教训黑熊(2)",
    missionDes = "看守紫竹林的黑熊精不能忍受常年吃斋，拿走了菩萨的法宝之一天罡刀且偷溜下界。此事让菩萨的座下弟子小龙女十分气愤。小龙女要你去熊寨教训黑熊，夺回宝刀。",
    acceptDes = "None",
    needCmp = {11024},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 135,
    rewardCoin = 117100,
    rewardGold = 0,
    rewardExp = 702673,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        10,
        12,
        false
      },
      talkId = 0,
      param = 0,
      des = "探查魔王寨#<Y,>石阶路#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11026] = {
    mnName = "夺回宝刀",
    missionDes = "看守紫竹林的黑熊精不能忍受常年吃斋，拿走了菩萨的法宝之一天罡刀且偷溜下界。此事让菩萨的座下弟子小龙女十分气愤。小龙女要你去熊寨教训黑熊，夺回宝刀。",
    acceptDes = "None",
    needCmp = {11025},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 135,
    rewardCoin = 117100,
    rewardGold = 0,
    rewardExp = 702673,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 202,
      data = {
        10,
        13,
        false
      },
      talkId = 110261,
      param = {
        {
          21031,
          1,
          100
        }
      },
      des = "打败#<Y,>混世黑熊#,夺回天罡刀"
    },
    dst2 = {
      type = 402,
      data = 91001,
      talkId = 110262,
      param = {
        {21031, 1}
      },
      des = "向#<Y,>小龙女#交付任务"
    }
  },
  [11027] = {
    mnName = "弱点",
    missionDes = "当年三妖之一的大妖王青面狮王是被观音菩萨封印于大雁塔中，所谓知己知彼百战不殆。向观音菩萨打听青面狮王的弱点。",
    acceptDes = "None",
    needCmp = {11026},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 135,
    rewardCoin = 46800,
    rewardGold = 0,
    rewardExp = 281069,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90904,
      talkId = 110271,
      param = 0,
      des = "向#<Y,>观音菩萨#打听青面狮王的弱点"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11028] = {
    mnName = "奇臭之物",
    missionDes = "当年三妖之一的大妖王青面狮王是被观音菩萨封印于大雁塔中，所谓知己知彼百战不殆。向观音菩萨打听青面狮王的弱点。",
    acceptDes = "None",
    needCmp = {11027},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 135,
    rewardCoin = 117100,
    rewardGold = 0,
    rewardExp = 702673,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        10,
        14,
        false
      },
      talkId = 110281,
      param = 0,
      des = "去方寸山消灭#<Y,>精细鬼#"
    },
    dst2 = {
      type = 101,
      data = 90904,
      talkId = 110282,
      param = 0,
      des = "向#<Y,>观音菩萨#交付任务"
    }
  },
  [11029] = {
    mnName = "路阻飞龙瀑",
    missionDes = "当年三妖之一的大妖王青面狮王是被观音菩萨封印于大雁塔中，所谓知己知彼百战不殆。向观音菩萨打听青面狮王的弱点。",
    acceptDes = "None",
    needCmp = {11028},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 135,
    rewardCoin = 117100,
    rewardGold = 0,
    rewardExp = 702673,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        10,
        15,
        false
      },
      talkId = 0,
      param = 0,
      des = "探查#<Y,>飞龙瀑#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11030] = {
    mnName = "青面狮王",
    missionDes = "当年三妖之一的大妖王青面狮王是被观音菩萨封印于大雁塔中，所谓知己知彼百战不殆。向观音菩萨打听青面狮王的弱点。",
    acceptDes = "None",
    needCmp = {11029},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 135,
    rewardCoin = 117100,
    rewardGold = 0,
    rewardExp = 702673,
    HelpWinAwardXiaYi = 510,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        10,
        16,
        false
      },
      talkId = 110301,
      param = 0,
      des = "消灭大妖王#<Y,>青面狮王#(建议组队前往)"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11031] = {
    mnName = "祛除污秽",
    missionDes = "当年三妖之一的大妖王青面狮王是被观音菩萨封印于大雁塔中，所谓知己知彼百战不殆。向观音菩萨打听青面狮王的弱点。",
    acceptDes = "None",
    needCmp = {11030},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 135,
    rewardCoin = 46800,
    rewardGold = 0,
    rewardExp = 281069,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90904,
      talkId = 110311,
      param = 0,
      des = "找#<Y,>观音菩萨#祛除体内污秽之气"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11032] = {
    mnName = "文殊的要求",
    missionDes = "去找普贤菩萨了解二妖王六牙妖像的情况。六牙妖象曾经是普贤菩萨的坐骑，普贤菩萨应该会知道一些对战妖象时需要注意的情况。",
    acceptDes = "None",
    needCmp = {11031},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 135,
    rewardCoin = 46800,
    rewardGold = 0,
    rewardExp = 281069,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90959,
      talkId = 110321,
      param = 0,
      des = "找#<Y,>普贤菩萨#打听六牙妖象的事情"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11033] = {
    mnName = "教训山妖",
    missionDes = "去找普贤菩萨了解二妖王六牙妖像的情况。六牙妖象曾经是普贤菩萨的坐骑，普贤菩萨应该会知道一些对战妖象时需要注意的情况。",
    acceptDes = "None",
    needCmp = {11032},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 135,
    rewardCoin = 117100,
    rewardGold = 0,
    rewardExp = 702673,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        10,
        17,
        false
      },
      talkId = 0,
      param = 0,
      des = "前往#<Y,>长安郊外#教训破坏庙宇的妖怪"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11034] = {
    mnName = "以暴制暴",
    missionDes = "去找普贤菩萨了解二妖王六牙妖像的情况。六牙妖象曾经是普贤菩萨的坐骑，普贤菩萨应该会知道一些对战妖象时需要注意的情况。",
    acceptDes = "None",
    needCmp = {11033},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 135,
    rewardCoin = 46800,
    rewardGold = 0,
    rewardExp = 281069,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90959,
      talkId = 110341,
      param = 0,
      des = "向#<Y,>普贤菩萨#复命"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11035] = {
    mnName = "象王守卫",
    missionDes = "去找普贤菩萨了解二妖王六牙妖像的情况。六牙妖象曾经是普贤菩萨的坐骑，普贤菩萨应该会知道一些对战妖象时需要注意的情况。",
    acceptDes = "None",
    needCmp = {11034},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 135,
    rewardCoin = 117100,
    rewardGold = 0,
    rewardExp = 702673,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        10,
        18,
        false
      },
      talkId = 0,
      param = 0,
      des = "打败象王守卫#<Y,>精细鬼#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11036] = {
    mnName = "六牙象王",
    missionDes = "去找普贤菩萨了解二妖王六牙妖像的情况。六牙妖象曾经是普贤菩萨的坐骑，普贤菩萨应该会知道一些对战妖象时需要注意的情况。",
    acceptDes = "None",
    needCmp = {11035},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 135,
    rewardCoin = 117100,
    rewardGold = 0,
    rewardExp = 702673,
    HelpWinAwardXiaYi = 510,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        10,
        19,
        false
      },
      talkId = 110361,
      param = 0,
      des = "消灭二妖王#<Y,>六牙象王#(建议组队前往)"
    },
    dst2 = {
      type = 101,
      data = 90959,
      talkId = 110362,
      param = 0,
      des = "向#<Y,>普贤菩萨#复命"
    }
  },
  [11037] = {
    mnName = "回复观音",
    missionDes = "三妖之中现在只剩下三妖王大鹏金雕了，大鹏金雕也是三妖中实力最强的妖王。",
    acceptDes = "None",
    needCmp = {11036},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 135,
    rewardCoin = 46800,
    rewardGold = 0,
    rewardExp = 281069,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90904,
      talkId = 110371,
      param = 0,
      des = "与#<Y,>观音菩萨#对话"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11038] = {
    mnName = "雕王护卫",
    missionDes = "三妖王大鹏金雕居然是如来佛祖的舅舅，听到这个消息后让你惊叹不已。这个舅舅好像不怎么让人省心呀，观音菩萨让希望你能打败大鹏金雕，阻止他为非作歹的行为。",
    acceptDes = "None",
    needCmp = {11037},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 135,
    rewardCoin = 117100,
    rewardGold = 0,
    rewardExp = 702673,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        10,
        20,
        false
      },
      talkId = 0,
      param = 0,
      des = "击败雕王护卫#<Y,>熊一刀#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11039] = {
    mnName = "象夫人",
    missionDes = "三妖王大鹏金雕居然是如来佛祖的舅舅，听到这个消息后让你惊叹不已。这个舅舅好像不怎么让人省心呀，观音菩萨让希望你能打败大鹏金雕，阻止他为非作歹的行为。",
    acceptDes = "None",
    needCmp = {11038},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 135,
    rewardCoin = 117100,
    rewardGold = 0,
    rewardExp = 702673,
    HelpWinAwardXiaYi = 60,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        10,
        21,
        false
      },
      talkId = 0,
      param = 0,
      des = "打败前来报仇的#<Y,>象夫人#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11040] = {
    mnName = "大鹏雕王(10称)",
    missionDes = "三妖王大鹏金雕居然是如来佛祖的舅舅，听到这个消息后让你惊叹不已。这个舅舅好像不怎么让人省心呀，观音菩萨让希望你能打败大鹏金雕，阻止他为非作歹的行为。",
    acceptDes = "None",
    needCmp = {11039},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 135,
    rewardCoin = 117100,
    rewardGold = 0,
    rewardExp = 702673,
    HelpWinAwardXiaYi = 510,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        10,
        22,
        false
      },
      talkId = 110401,
      param = 0,
      des = "消灭三妖王#<Y,>大鹏雕王#(建议组队前往)"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11041] = {
    mnName = "除尽3妖(10称)",
    missionDes = "三妖王大鹏金雕居然是如来佛祖的舅舅，听到这个消息后让你惊叹不已。这个舅舅好像不怎么让人省心呀，观音菩萨让希望你能打败大鹏金雕，阻止他为非作歹的行为。",
    acceptDes = "None",
    needCmp = {11040},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 135,
    rewardCoin = 46800,
    rewardGold = 0,
    rewardExp = 281069,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90904,
      talkId = 110411,
      param = 0,
      des = "向#<Y,>观音#交付任务"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11101] = {
    mnName = "传达消息",
    missionDes = "三妖俱灭，其他的小妖们也纷纷溃散，狮驼国正是百废待兴时，赶紧将这个好消息告诉狮驼国的幸存者们吧。",
    acceptDes = "None",
    needCmp = {11041},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 140,
    rewardCoin = 52500,
    rewardGold = 0,
    rewardExp = 314785,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 111011,
      param = 0,
      des = "回复#<Y,>紫霞仙子#"
    },
    dst2 = {
      type = 101,
      data = 90999,
      talkId = 111012,
      param = 0,
      des = "将好消息告诉#<Y,>幸存者#"
    }
  },
  [11102] = {
    mnName = "仙子委托",
    missionDes = "三妖俱灭，其他的小妖们也纷纷溃散，狮驼国正是百废待兴时，赶紧将这个好消息告诉狮驼国的幸存者们吧。",
    acceptDes = "None",
    needCmp = {11101},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 140,
    rewardCoin = 52500,
    rewardGold = 0,
    rewardExp = 314785,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 111021,
      param = 0,
      des = "#<Y,>紫霞仙子#有事找你"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11103] = {
    mnName = "探望好友(1)",
    missionDes = "大鹏金雕临死前讲的一番话总是浮现在你脑海中，难道真如他所说？刚好紫霞仙子需要你去天宫的百花园帮她采集炼丹所需要的药草。不如趁此机会，调查一下。",
    acceptDes = "None",
    needCmp = {11102},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 140,
    rewardCoin = 131200,
    rewardGold = 0,
    rewardExp = 786963,
    HelpWinAwardXiaYi = 70,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        11,
        1,
        false
      },
      talkId = 111031,
      wftalkId = 111032,
      param = 0,
      des = "击败#<Y,>南天门#值守天兵天将"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11104] = {
    mnName = "探望好友(2)",
    missionDes = "大鹏金雕临死前讲的一番话总是浮现在你脑海中，难道真如他所说？刚好紫霞仙子需要你去天宫的百花园帮她采集炼丹所需要的药草。不如趁此机会，调查一下。",
    acceptDes = "None",
    needCmp = {11103},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 140,
    rewardCoin = 131200,
    rewardGold = 0,
    rewardExp = 786963,
    HelpWinAwardXiaYi = 70,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        11,
        2,
        false
      },
      talkId = 111041,
      param = 0,
      des = "探望#<Y,>百草仙子#"
    },
    dst2 = {
      type = 101,
      data = 90907,
      talkId = 111042,
      param = 0,
      des = "向#<Y,>紫霞仙子#复命"
    }
  },
  [11105] = {
    mnName = "与仙子对话",
    missionDes = "将天宫百花园发生的事情和大鹏金雕所讲的话一并告诉紫霞仙子。",
    acceptDes = "None",
    needCmp = {11104},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 140,
    rewardCoin = 52500,
    rewardGold = 0,
    rewardExp = 314785,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 111051,
      param = 0,
      des = "告诉#<Y,>紫霞仙子#你心中疑问"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11106] = {
    mnName = "初见绮花",
    missionDes = "为了指引天运之人而长期停留于凡间的紫霞仙子听完你所讲的事后，也深深对天宫起了担忧之心。她希望你再去趟天宫，找到好友绮花仙子，向她打听一些的情况。",
    acceptDes = "None",
    needCmp = {11105},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 140,
    rewardCoin = 52500,
    rewardGold = 0,
    rewardExp = 314785,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90960,
      talkId = 111061,
      param = 0,
      des = "找#<Y,>绮花仙子#打听天宫近况"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11107] = {
    mnName = "值日功曹",
    missionDes = "为了指引天运之人而长期停留于凡间的紫霞仙子听完你所讲的事后，也深深对天宫起了担忧之心。她希望你再去趟天宫，找到好友绮花仙子，向她打听一些的情况。",
    acceptDes = "None",
    needCmp = {11106},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 141,
    rewardCoin = 134200,
    rewardGold = 0,
    rewardExp = 804944,
    HelpWinAwardXiaYi = 520,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        11,
        3,
        false
      },
      talkId = 111071,
      param = 0,
      des = "赶走值日功曹#<Y,>周登#(建议组队前往)"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11108] = {
    mnName = "金丹",
    missionDes = "根据绮花仙子所说，天宫出现的问题应该归咎于你现在手中所持的“金丹”了。将金丹带给紫霞仙子，也许她会知道些什么。",
    acceptDes = "None",
    needCmp = {11107},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 141,
    rewardCoin = 67100,
    rewardGold = 0,
    rewardExp = 402472,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 90960,
      talkId = 111081,
      param = {
        {21033, 1}
      },
      des = "继续#<Y,>绮花仙子#交谈"
    },
    dst2 = {
      type = 402,
      data = 90907,
      talkId = 111082,
      param = {
        {21033, 1}
      },
      des = "将金丹交给#<Y,>紫霞仙子#"
    }
  },
  [11109] = {
    mnName = "古怪的金丹(1)",
    missionDes = "根据绮花仙子所说，天宫出现的问题应该归咎于你现在手中所持的“金丹”了。将金丹带给紫霞仙子，也许她会知道些什么。",
    acceptDes = "None",
    needCmp = {11108},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 141,
    rewardCoin = 53700,
    rewardGold = 0,
    rewardExp = 321977,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 111091,
      param = 0,
      des = "询问#<Y,>紫霞仙子#是否发现金丹疑问"
    },
    dst2 = {
      type = 101,
      data = 90907,
      talkId = 111092,
      param = 0,
      des = "继续与#<Y,>紫霞仙子#对话"
    }
  },
  [11110] = {
    mnName = "口风",
    missionDes = "根据绮花仙子所说，天宫出现的问题应该归咎于你现在手中所持的“金丹”了。将金丹带给紫霞仙子，也许她会知道些什么。",
    acceptDes = "None",
    needCmp = {11109},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 141,
    rewardCoin = 134200,
    rewardGold = 0,
    rewardExp = 804944,
    HelpWinAwardXiaYi = 70,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        11,
        4,
        false
      },
      talkId = 0,
      param = 0,
      des = "打败变节的#<Y,>绮花仙子#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11111] = {
    mnName = "质问绮花",
    missionDes = "饱含仙灵之气的金丹居然是颗毒丹，这可把紫霞仙子吓坏了。紫霞仙子希望你去找绮花仙子，问她为何要加害于她。",
    acceptDes = "None",
    needCmp = {11110},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 141,
    rewardCoin = 53700,
    rewardGold = 0,
    rewardExp = 321977,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90960,
      talkId = 111111,
      param = 0,
      des = "质问#<Y,>绮花仙子#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11112] = {
    mnName = "仙桥守卫",
    missionDes = "饱含仙灵之气的金丹居然是颗毒丹，这可把紫霞仙子吓坏了。紫霞仙子希望你去找绮花仙子，问她为何要加害于她。",
    acceptDes = "None",
    needCmp = {11111},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 141,
    rewardCoin = 134200,
    rewardGold = 0,
    rewardExp = 804944,
    HelpWinAwardXiaYi = 70,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        11,
        5,
        false
      },
      talkId = 0,
      param = 0,
      des = "打败阻拦你的#<Y,>天将#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11113] = {
    mnName = "回复仙子",
    missionDes = "这颗来历不明的毒丹也许只有阅历丰富的仙界元老们才能知晓其出处。紫霞仙子让你带着这颗金丹去方寸找镇远大仙寻求帮助。",
    acceptDes = "None",
    needCmp = {11112},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 142,
    rewardCoin = 68600,
    rewardGold = 0,
    rewardExp = 411659,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 90907,
      talkId = 111131,
      param = {
        {21033, 1}
      },
      des = "告知#<Y,>紫霞仙子#所发生的事"
    },
    dst2 = {
      type = 402,
      data = 90903,
      talkId = 111132,
      param = {
        {21033, 1}
      },
      des = "将金丹交给#<Y,>镇元大仙#检验"
    }
  },
  [11114] = {
    mnName = "古怪的金丹(2)",
    missionDes = "这颗来历不明的毒丹也许只有阅历丰富的仙界元老们才能知晓其出处。紫霞仙子让你带着这颗金丹去方寸找镇远大仙寻求帮助。",
    acceptDes = "None",
    needCmp = {11113},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 142,
    rewardCoin = 54900,
    rewardGold = 0,
    rewardExp = 329327,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90903,
      talkId = 111141,
      param = 0,
      des = "向#<Y,>镇元大仙#了解金丹详情"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11115] = {
    mnName = "癸水",
    missionDes = "镇元大仙好像知道些什么，为了验证心中猜想。镇远大仙需要你去天宫收集一些癸水回来。",
    acceptDes = "None",
    needCmp = {11114},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 142,
    rewardCoin = 137200,
    rewardGold = 0,
    rewardExp = 823319,
    HelpWinAwardXiaYi = 520,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 202,
      data = {
        11,
        6,
        false
      },
      talkId = 111151,
      param = {
        {
          21034,
          1,
          100
        }
      },
      des = "击败巨灵神,获取#<Y,>癸水#(建议组队前往)"
    },
    dst2 = {
      type = 402,
      data = 90903,
      talkId = 111152,
      param = {
        {21034, 1}
      },
      des = "向#<Y,>镇元大仙#交付任务"
    }
  },
  [11116] = {
    mnName = "血蛊初现",
    missionDes = "镇元大仙好像知道些什么，为了验证心中猜想。镇远大仙需要你去天宫收集一些癸水回来。",
    acceptDes = "None",
    needCmp = {11115},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 142,
    rewardCoin = 54900,
    rewardGold = 0,
    rewardExp = 329327,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90903,
      talkId = 111161,
      param = 0,
      des = "向#<Y,>镇元大仙#了解金丹之秘"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11117] = {
    mnName = "火急消息",
    missionDes = "真相大白，原来金丹里面含有无天魔罗的些许精血，难怪如此的霸道、狠毒。谢过镇远大仙的帮助之后，快回去找紫霞仙子吧。",
    acceptDes = "None",
    needCmp = {11116},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 142,
    rewardCoin = 54900,
    rewardGold = 0,
    rewardExp = 329327,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 111171,
      param = 0,
      des = "告知#<Y,>紫霞仙子#金丹之秘"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11118] = {
    mnName = "药王",
    missionDes = "一生二，二生三，三生万物。万物又皆含五行，五行皆又相克。去找长安药王孙思邈吧，也许他会有克制血蛊的方法。",
    acceptDes = "None",
    needCmp = {11117},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 143,
    rewardCoin = 56100,
    rewardGold = 0,
    rewardExp = 336838,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90973,
      talkId = 111181,
      param = 0,
      des = "向药王请教#<Y,>解蛊方法#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11119] = {
    mnName = "血蛊(1)",
    missionDes = "一生二，二生三，三生万物。万物又皆含五行，五行皆又相克。去找长安药王孙思邈吧，也许他会有克制血蛊的方法。",
    acceptDes = "None",
    needCmp = {11118},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 143,
    rewardCoin = 140300,
    rewardGold = 0,
    rewardExp = 842095,
    HelpWinAwardXiaYi = 70,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        11,
        7,
        false
      },
      talkId = 0,
      param = 0,
      des = "前去#<Y,>天宫#寻找中蛊之人,并试图取得血液"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11120] = {
    mnName = "血蛊(2)",
    missionDes = "一生二，二生三，三生万物。万物又皆含五行，五行皆又相克。去找长安药王孙思邈吧，也许他会有克制血蛊的方法。",
    acceptDes = "None",
    needCmp = {11119},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 143,
    rewardCoin = 140300,
    rewardGold = 0,
    rewardExp = 842095,
    HelpWinAwardXiaYi = 70,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        11,
        8,
        false
      },
      talkId = 0,
      param = 0,
      des = "前去#<Y,>天宫#寻找中蛊之人,并试图取得血液"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11121] = {
    mnName = "血蛊(3)",
    missionDes = "一生二，二生三，三生万物。万物又皆含五行，五行皆又相克。去找长安药王孙思邈吧，也许他会有克制血蛊的方法。",
    acceptDes = "None",
    needCmp = {11120},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 143,
    rewardCoin = 140300,
    rewardGold = 0,
    rewardExp = 842095,
    HelpWinAwardXiaYi = 70,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 202,
      data = {
        11,
        9,
        false
      },
      talkId = 111231,
      param = {
        {
          21035,
          1,
          100
        }
      },
      des = "从护国天王#<Y,>丁力士#身上取得血液"
    },
    dst2 = {
      type = 402,
      data = 90973,
      talkId = 111232,
      param = {
        {21035, 1}
      },
      des = "将血液交给#<Y,>孙思邈#"
    }
  },
  [11122] = {
    mnName = "解蛊之法",
    missionDes = "一生二，二生三，三生万物。万物又皆含五行，五行皆又相克。去找长安药王孙思邈吧，也许他会有克制血蛊的方法。",
    acceptDes = "None",
    needCmp = {11121},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 143,
    rewardCoin = 56100,
    rewardGold = 0,
    rewardExp = 336838,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90973,
      talkId = 111241,
      param = 0,
      des = "让#<Y,>孙思邈#教你解蛊之法"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11123] = {
    mnName = "五谷解蛊",
    missionDes = "功夫不负有心人，经过几次尝试，孙神医终于找到克制血蛊之法了，快将这个好消息告诉紫霞仙子吧。",
    acceptDes = "None",
    needCmp = {11122},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 144,
    rewardCoin = 57400,
    rewardGold = 0,
    rewardExp = 344512,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 111251,
      param = 0,
      des = "将解蛊之法告诉#<Y,>紫霞仙子#"
    },
    dst2 = {
      type = 101,
      data = 90908,
      talkId = 111252,
      param = 0,
      des = "向#<Y,>杂货商#购买五谷"
    }
  },
  [11124] = {
    mnName = "试药",
    missionDes = "功夫不负有心人，经过几次尝试，孙神医终于找到克制血蛊之法了，快将这个好消息告诉紫霞仙子吧。",
    acceptDes = "None",
    needCmp = {11123},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 144,
    rewardCoin = 71800,
    rewardGold = 0,
    rewardExp = 430641,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 90908,
      talkId = 111253,
      param = {
        {21062, 1}
      },
      des = "与#<Y,>杂货商#交谈取得五谷"
    },
    dst2 = {
      type = 402,
      data = 90974,
      talkId = 111254,
      param = {
        {21062, 1}
      },
      des = "将#<Y,>五谷粉末#喂予绮花仙子"
    }
  },
  [11125] = {
    mnName = "药效",
    missionDes = "事关紧急，为了验证孙神医的克制之法，紫霞仙子希望你能用此法将绮花仙子救醒，顺便向她打探金丹的事情。",
    acceptDes = "None",
    needCmp = {11124},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 144,
    rewardCoin = 57400,
    rewardGold = 0,
    rewardExp = 344512,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90974,
      talkId = 111261,
      param = 0,
      des = "打探#<Y,>金丹#消息"
    },
    dst2 = {
      type = 101,
      data = 90907,
      talkId = 111262,
      param = 0,
      des = "向#<Y,>紫霞仙子#复命"
    }
  },
  [11126] = {
    mnName = "大力鬼王",
    missionDes = "种种疑问渐渐浮出水面，这是一个好的开始。根据那些被你救醒的仙友提供的线索，破开这片迷雾。",
    acceptDes = "None",
    needCmp = {11125},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 144,
    rewardCoin = 57400,
    rewardGold = 0,
    rewardExp = 344512,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 111271,
      param = 0,
      des = "打听#<Y,>鬼王#消息"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11127] = {
    mnName = "质问鬼王(1)",
    missionDes = "种种疑问渐渐浮出水面，这是一个好的开始。根据那些被你救醒的仙友提供的线索，破开这片迷雾。",
    acceptDes = "None",
    needCmp = {11126},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 144,
    rewardCoin = 143500,
    rewardGold = 0,
    rewardExp = 861282,
    HelpWinAwardXiaYi = 70,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        11,
        10,
        false
      },
      talkId = 0,
      param = 0,
      des = "击败鬼王好友#<Y,>广目天王#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11128] = {
    mnName = "质问鬼王(2)",
    missionDes = "种种疑问渐渐浮出水面，这是一个好的开始。根据那些被你救醒的仙友提供的线索，破开这片迷雾。",
    acceptDes = "None",
    needCmp = {11127},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 144,
    rewardCoin = 143500,
    rewardGold = 0,
    rewardExp = 861282,
    HelpWinAwardXiaYi = 70,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        11,
        11,
        false
      },
      talkId = 0,
      param = 0,
      des = "击败#<Y,>灵吉尊者#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11129] = {
    mnName = "质问鬼王(3)",
    missionDes = "种种疑问渐渐浮出水面，这是一个好的开始。根据那些被你救醒的仙友提供的线索，破开这片迷雾。",
    acceptDes = "None",
    needCmp = {11128},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 144,
    rewardCoin = 143500,
    rewardGold = 0,
    rewardExp = 861282,
    HelpWinAwardXiaYi = 70,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        11,
        12,
        false
      },
      talkId = 111301,
      param = 0,
      des = "从#<Y,>大力鬼王#处获取线索"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11130] = {
    mnName = "继续打探",
    missionDes = "种种疑问渐渐浮出水面，这是一个好的开始。根据那些被你救醒的仙友提供的线索，破开这片迷雾。",
    acceptDes = "None",
    needCmp = {11129},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 145,
    rewardCoin = 58700,
    rewardGold = 0,
    rewardExp = 352355,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 111311,
      param = 0,
      des = "找#<Y,>紫霞仙子#想办法"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11131] = {
    mnName = "寻人",
    missionDes = "种种疑问渐渐浮出水面，这是一个好的开始。根据那些被你救醒的仙友提供的线索，破开这片迷雾。",
    acceptDes = "None",
    needCmp = {11130},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 145,
    rewardCoin = 58700,
    rewardGold = 0,
    rewardExp = 352355,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90975,
      talkId = 111321,
      param = 0,
      des = "与#<Y,>增长天王#交谈"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11132] = {
    mnName = "疯癫的葛天师",
    missionDes = "种种疑问渐渐浮出水面，这是一个好的开始。根据那些被你救醒的仙友提供的线索，破开这片迷雾。",
    acceptDes = "None",
    needCmp = {11131},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 145,
    rewardCoin = 146800,
    rewardGold = 0,
    rewardExp = 880888,
    HelpWinAwardXiaYi = 70,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        11,
        13,
        false
      },
      talkId = 111331,
      wftalkId = 111332,
      param = 0,
      des = "去方寸山探望#<Y,>葛天师#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11133] = {
    mnName = "解毒",
    missionDes = "种种疑问渐渐浮出水面，这是一个好的开始。根据那些被你救醒的仙友提供的线索，破开这片迷雾。",
    acceptDes = "None",
    needCmp = {11132},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 145,
    rewardCoin = 58700,
    rewardGold = 0,
    rewardExp = 352355,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90975,
      talkId = 111341,
      param = 0,
      des = "将葛天师交给#<Y,>增长天王#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11134] = {
    mnName = "千里追踪",
    missionDes = "种种疑问渐渐浮出水面，这是一个好的开始。根据那些被你救醒的仙友提供的线索，破开这片迷雾。",
    acceptDes = "None",
    needCmp = {11133},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 145,
    rewardCoin = 146800,
    rewardGold = 0,
    rewardExp = 880888,
    HelpWinAwardXiaYi = 70,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        11,
        14,
        false
      },
      talkId = 0,
      param = 0,
      des = "追踪可疑的#<Y,>罗汉#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11135] = {
    mnName = "探望天师",
    missionDes = "“想要知道谁是真正幕后推手，必须将雷公、电母救醒”葛天师说。按照葛天师的要求，救出雷公、电母二人。",
    acceptDes = "None",
    needCmp = {11134},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 145,
    rewardCoin = 58700,
    rewardGold = 0,
    rewardExp = 352355,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90976,
      talkId = 111361,
      param = 0,
      des = "去天宫探望#<Y,>葛天师#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11136] = {
    mnName = "惩戒上仙",
    missionDes = "十日之期马上就要来临，没有雷、电二人派发的血蛊金丹，那些中毒之人将会变得狂躁、暴力。为了天宫秩序，葛天师希望你能帮助他将那些中毒之人一一擒回。",
    acceptDes = "None",
    needCmp = {11135},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 146,
    rewardCoin = 150200,
    rewardGold = 0,
    rewardExp = 900922,
    HelpWinAwardXiaYi = 520,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        11,
        15,
        false
      },
      talkId = 111371,
      param = 0,
      des = "惩戒#<Y,>雷公#、#<Y,>电母#(建议组队前往)"
    },
    dst2 = {
      type = 101,
      data = 90976,
      talkId = 111372,
      param = 0,
      des = "将雷电二人交给#<Y,>葛天师#"
    }
  },
  [11137] = {
    mnName = "救人(1)",
    missionDes = "十日之期马上就要来临，没有雷、电二人派发的血蛊金丹，那些中毒之人将会变得狂躁、暴力。为了天宫秩序，葛天师希望你能帮助他将那些中毒之人一一擒回。",
    acceptDes = "None",
    needCmp = {11136},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 146,
    rewardCoin = 150200,
    rewardGold = 0,
    rewardExp = 900922,
    HelpWinAwardXiaYi = 70,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        11,
        16,
        false
      },
      talkId = 0,
      param = 0,
      des = "去渔村击败身中毒蛊的#<Y,>罗汉#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11138] = {
    mnName = "救人(2)",
    missionDes = "十日之期马上就要来临，没有雷、电二人派发的血蛊金丹，那些中毒之人将会变得狂躁、暴力。为了天宫秩序，葛天师希望你能帮助他将那些中毒之人一一擒回。",
    acceptDes = "None",
    needCmp = {11137},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 146,
    rewardCoin = 150200,
    rewardGold = 0,
    rewardExp = 900922,
    HelpWinAwardXiaYi = 70,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        11,
        17,
        false
      },
      talkId = 0,
      wftalkId = 111391,
      param = 0,
      des = "去长安郊外击败值守#<Y,>功曹#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11139] = {
    mnName = "幕后推手",
    missionDes = "得知太白金星就是幕后黑手，紫霞仙子要你火速前往凌霄宝殿，通过太白金星找到血蛊金丹的本源所在...",
    acceptDes = "None",
    needCmp = {11138},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 146,
    rewardCoin = 60100,
    rewardGold = 0,
    rewardExp = 360369,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90976,
      talkId = 111401,
      param = 0,
      des = "找#<Y,>葛天师#取得黑手信息"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11140] = {
    mnName = "回复仙子",
    missionDes = "得知太白金星就是幕后黑手，紫霞仙子要你火速前往凌霄宝殿，通过太白金星找到血蛊金丹的本源所在...",
    acceptDes = "None",
    needCmp = {11139},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 146,
    rewardCoin = 60100,
    rewardGold = 0,
    rewardExp = 360369,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 111411,
      param = 0,
      des = "将结果告知#<Y,>紫霞仙子#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11141] = {
    mnName = "障碍",
    missionDes = "得知太白金星就是幕后黑手，紫霞仙子要你火速前往凌霄宝殿，通过太白金星找到血蛊金丹的本源所在...",
    acceptDes = "None",
    needCmp = {11140},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 146,
    rewardCoin = 150200,
    rewardGold = 0,
    rewardExp = 900922,
    HelpWinAwardXiaYi = 70,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        11,
        18,
        false
      },
      talkId = 0,
      param = 0,
      des = "打败阻拦你去路的#<Y,>龙女#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11142] = {
    mnName = "太白金星",
    missionDes = "得知太白金星就是幕后黑手，紫霞仙子要你火速前往凌霄宝殿，通过太白金星找到血蛊金丹的本源所在...",
    acceptDes = "None",
    needCmp = {11141},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 146,
    rewardCoin = 150200,
    rewardGold = 0,
    rewardExp = 900922,
    HelpWinAwardXiaYi = 520,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        11,
        19,
        false
      },
      talkId = 111431,
      wftalkId = 111432,
      param = 0,
      des = "打败变节的#<Y,>太白金星#(建议组队前往)"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11143] = {
    mnName = "真相",
    missionDes = "太白金星的叛变，金丹血蛊的出现。似乎，这一切的一切都是针对无天魔罗设下的一个陷阱。这是事实，还是谎言，只有菩提老祖才知道...",
    acceptDes = "None",
    needCmp = {11142},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 147,
    rewardCoin = 61400,
    rewardGold = 0,
    rewardExp = 368557,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90977,
      talkId = 111441,
      param = 0,
      des = "根据指示,找到#<Y,>太白金星#"
    },
    dst2 = {
      type = 101,
      data = 90977,
      talkId = 111442,
      param = 0,
      des = "继续与#<Y,>太白金星#交谈"
    }
  },
  [11144] = {
    mnName = "取证",
    missionDes = "太白金星的叛变，金丹血蛊的出现。似乎，这一切的一切都是针对无天魔罗设下的一个陷阱。这是事实，还是谎言，只有菩提老祖才知道...",
    acceptDes = "None",
    needCmp = {11143},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 147,
    rewardCoin = 61400,
    rewardGold = 0,
    rewardExp = 368557,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 111451,
      param = 0,
      des = "回复#<Y,>紫霞仙子#"
    },
    dst2 = {
      type = 101,
      data = 90907,
      talkId = 111452,
      param = 0,
      des = "向#<Y,>紫霞仙子#取证"
    }
  },
  [11145] = {
    mnName = "灭魔之路(1)",
    missionDes = "既然陷阱已经不能困住无天摩罗的分身了，那就只能将他斩杀于牢笼下。紫霞仙子希望你能去兜率宫，消灭无天魔罗的分身，阻止困龙升天。",
    acceptDes = "None",
    needCmp = {11144},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 147,
    rewardCoin = 153600,
    rewardGold = 0,
    rewardExp = 921394,
    HelpWinAwardXiaYi = 70,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        11,
        20,
        false
      },
      talkId = 0,
      param = 0,
      des = "打败#<Y,>守山熊#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11146] = {
    mnName = "灭魔之路(2)",
    missionDes = "既然陷阱已经不能困住无天摩罗的分身了，那就只能将他斩杀于牢笼下。紫霞仙子希望你能去兜率宫，消灭无天魔罗的分身，阻止困龙升天。",
    acceptDes = "None",
    needCmp = {11145},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 147,
    rewardCoin = 153600,
    rewardGold = 0,
    rewardExp = 921394,
    HelpWinAwardXiaYi = 70,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        11,
        21,
        false
      },
      talkId = 0,
      param = 0,
      des = "打败变节的#<Y,>武德星君#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [11147] = {
    mnName = "无天魔罗(11称)",
    missionDes = "既然陷阱已经不能困住无天摩罗的分身了，那就只能将他斩杀于牢笼下。紫霞仙子希望你能去兜率宫，消灭无天魔罗的分身，阻止困龙升天。",
    acceptDes = "None",
    needCmp = {11146},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 147,
    rewardCoin = 153600,
    rewardGold = 0,
    rewardExp = 921394,
    HelpWinAwardXiaYi = 520,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        11,
        22,
        false
      },
      talkId = 111481,
      param = 0,
      des = "去兜率宫消灭#<Y,>无天魔罗#(建议组队前往)"
    },
    dst2 = {
      type = 101,
      data = 90907,
      talkId = 111482,
      param = 0,
      des = "向#<Y,>紫霞仙子#交付任务"
    }
  }
}

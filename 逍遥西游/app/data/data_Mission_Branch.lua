data_Mission_Branch = {
  [20001] = {
    mnName = "迟来的货款",
    missionDes = "长安城杂货商老板一副愁眉苦脸的样子，问问他发生了什么事情吧。",
    acceptDes = "长安城#<Y,>杂货商#有事找你",
    needCmp = {0},
    startNpc = 90908,
    acceptTalkId = 170011,
    zs = 0,
    lv = 55,
    rewardCoin = 4000,
    rewardGold = 0,
    rewardExp = 39746,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90931,
      talkId = 170012,
      param = 0,
      des = "向渔村#<Y,>何万财#询问原因"
    },
    dst2 = {
      type = 101,
      data = 91004,
      talkId = 170013,
      param = 0,
      des = "找到失联的#<Y,>何万富#"
    }
  },
  [20002] = {
    mnName = "迟来的货款",
    missionDes = "长安城杂货商老板一副愁眉苦脸的样子，问问他发生了什么事情吧。",
    acceptDes = "向附近的#<Y,>墨老#打听情况",
    needCmp = {20001},
    startNpc = 90922,
    acceptTalkId = 170014,
    zs = 0,
    lv = 55,
    rewardCoin = 5000,
    rewardGold = 0,
    rewardExp = 49683,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 209,
      data = {16001, 4001},
      talkId = 170015,
      wftalkId = 170016,
      param = {
        {
          21012,
          1,
          100
        }
      },
      des = "从#<Y,>雌雄大盗#手中夺回银票"
    },
    dst2 = {
      type = 402,
      data = 91004,
      talkId = 170017,
      param = {
        {21012, 1}
      },
      des = "将银票交给#<Y,>何万富#"
    }
  },
  [20003] = {
    mnName = "迟来的货款",
    missionDes = "长安城杂货商老板一副愁眉苦脸的样子，问问他发生了什么事情吧。",
    acceptDes = "回复#<Y,>何万财#",
    needCmp = {20002},
    startNpc = 90931,
    acceptTalkId = 170018,
    zs = 0,
    lv = 55,
    rewardCoin = 4000,
    rewardGold = 0,
    rewardExp = 39746,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90908,
      talkId = 170019,
      param = 0,
      des = "回复#<Y,>杂货商#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20004] = {
    mnName = "捉迷藏",
    missionDes = "和小伙伴们一起玩捉迷藏的小紫找不到他们，着急的她开始在城内大声哭泣。刚好路过此地的你安慰一下小紫吧，顺便替她找到那些躲藏在角落里的小伙伴。",
    acceptDes = "安慰正在哭鼻子的#<Y,>小紫#",
    needCmp = {20003},
    startNpc = 95002,
    acceptTalkId = 170021,
    zs = 0,
    lv = 57,
    rewardCoin = 4200,
    rewardGold = 0,
    rewardExp = 42005,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 95003,
      talkId = 170022,
      param = 0,
      des = "去城东找到#<Y,>东东#"
    },
    dst2 = {
      type = 101,
      data = 95004,
      talkId = 170023,
      param = 0,
      des = "去城南找到#<Y,>茜茜#"
    }
  },
  [20005] = {
    mnName = "捉迷藏",
    missionDes = "和小伙伴们一起玩捉迷藏的小紫找不到他们，着急的她开始在城内大声哭泣。刚好路过此地的你安慰一下小紫吧，顺便替她找到那些躲藏在角落里的小伙伴。",
    acceptDes = "向#<Y,>墨老#打听#<Y,>贝贝#的下落",
    needCmp = {20004},
    startNpc = 90922,
    acceptTalkId = 170024,
    zs = 0,
    lv = 57,
    rewardCoin = 4200,
    rewardGold = 0,
    rewardExp = 42005,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 95005,
      talkId = 170025,
      param = 0,
      des = "去双叉岭找到#<Y,>贝贝#"
    },
    dst2 = {
      type = 208,
      data = {16002, 4002},
      talkId = 170026,
      param = 0,
      des = "消灭横空出现的#<Y,>老爷爷#"
    }
  },
  [20006] = {
    mnName = "捉迷藏",
    missionDes = "和小伙伴们一起玩捉迷藏的小紫找不到他们，着急的她开始在城内大声哭泣。刚好路过此地的你安慰一下小紫吧，顺便替她找到那些躲藏在角落里的小伙伴。",
    acceptDes = "安抚受惊吓的#<Y,>贝贝#",
    needCmp = {20005},
    startNpc = 95005,
    acceptTalkId = 170027,
    zs = 0,
    lv = 57,
    rewardCoin = 4200,
    rewardGold = 0,
    rewardExp = 42005,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 95002,
      talkId = 170028,
      param = 0,
      des = "将#<Y,>贝贝#带回小伙伴身边"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20007] = {
    mnName = "闹鬼",
    missionDes = "长安城首富钱掌柜家中闹鬼啦，这可把胆小的钱掌柜给吓得几天没有去钱库点过数。钱掌柜找到你，希望你能帮他消灭恶鬼，以保家中平安。",
    acceptDes = "询问#<Y,>钱掌柜#有何事找你",
    needCmp = {20006},
    startNpc = 90941,
    acceptTalkId = 170031,
    zs = 0,
    lv = 59,
    rewardCoin = 5500,
    rewardGold = 0,
    rewardExp = 55457,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16003, 4003},
      talkId = 170032,
      param = 0,
      des = "去长安郊外消灭#<Y,>恶鬼#"
    },
    dst2 = {
      type = 101,
      data = 90941,
      talkId = 170033,
      param = 0,
      des = "将情况告知#<Y,>钱掌柜#"
    }
  },
  [20008] = {
    mnName = "闹鬼",
    missionDes = "长安城首富钱掌柜家中闹鬼啦，这可把胆小的钱掌柜给吓得几天没有去钱库点过数。钱掌柜找到你，希望你能帮他消灭恶鬼，以保家中平安。",
    acceptDes = "向#<Y,>钱掌柜#了解情况",
    needCmp = {20007},
    startNpc = 90941,
    acceptTalkId = 170034,
    zs = 0,
    lv = 59,
    rewardCoin = 5500,
    rewardGold = 0,
    rewardExp = 55457,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16004, 4004},
      talkId = 170035,
      wftalkId = 170036,
      param = 0,
      des = "去化生寺处教训#<Y,>无用禅师#"
    },
    dst2 = {
      type = 101,
      data = 90941,
      talkId = 170037,
      param = 0,
      des = "把好消息告诉给#<Y,>钱掌柜#"
    }
  },
  [20009] = {
    mnName = "白衣书生",
    missionDes = "刚参加完御前科举的书生回到家中却发现家中娘子不见踪影，四处询问邻居们却被告知娘子是妖怪，这可急坏了书生。书生希望你帮他找回娘子墨玉红。",
    acceptDes = "长安#<Y,>书生#有事拜托你",
    needCmp = {20008},
    startNpc = 95009,
    acceptTalkId = 170041,
    zs = 0,
    lv = 60,
    rewardCoin = 4600,
    rewardGold = 0,
    rewardExp = 45585,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 95010,
      talkId = 170042,
      param = 0,
      des = "向邻居打听#<Y,>玉红#的情况"
    },
    dst2 = {
      type = 101,
      data = 90922,
      talkId = 170043,
      param = 0,
      des = "向#<Y,>墨老#打听玉红的情况"
    }
  },
  [20010] = {
    mnName = "白衣书生",
    missionDes = "刚参加完御前科举的书生回到家中却发现家中娘子不见踪影，四处询问邻居们却被告知娘子是妖怪，这可急坏了书生。书生希望你帮他找回娘子墨玉红。",
    acceptDes = "向#<Y,>墨老#取得埋葬地点",
    needCmp = {20009},
    startNpc = 90922,
    acceptTalkId = 170044,
    zs = 0,
    lv = 60,
    rewardCoin = 4600,
    rewardGold = 0,
    rewardExp = 45585,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 95009,
      talkId = 170045,
      param = 0,
      des = "将打听到的情况告诉#<Y,>书生#"
    },
    dst2 = {
      type = 208,
      data = {16005, 4005},
      talkId = 170046,
      param = 0,
      des = "消灭老树下的#<Y,>桃树精#"
    }
  },
  [20011] = {
    mnName = "白衣书生",
    missionDes = "刚参加完御前科举的书生回到家中却发现家中娘子不见踪影，四处询问邻居们却被告知娘子是妖怪，这可急坏了书生。书生希望你帮他找回娘子墨玉红。",
    acceptDes = "0",
    needCmp = {20010},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 60,
    rewardCoin = 4600,
    rewardGold = 0,
    rewardExp = 45585,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 95009,
      talkId = 170047,
      param = 0,
      des = "向#<Y,>书生#交付任务"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20012] = {
    mnName = "渔村野鬼",
    missionDes = "龙宫的水丞相擅自打通了地府通道，使得地府里的野鬼能顺着通道能通向人间，这样使得原本祥和的渔村遭受了重创。渡厄禅师希望你能帮助他恢复渔村安宁。",
    acceptDes = "#<Y,>渡远禅师#有事找你",
    needCmp = {20011},
    startNpc = 90901,
    acceptTalkId = 170051,
    zs = 0,
    lv = 62,
    rewardCoin = 4800,
    rewardGold = 0,
    rewardExp = 48106,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 95012,
      talkId = 170052,
      param = 0,
      des = "向#<Y,>渡厄禅师#了解恶鬼的情况"
    },
    dst2 = {
      type = 208,
      data = {16006, 4006},
      talkId = 170053,
      wftalkId = 170054,
      param = 0,
      des = "在#<Y,>渔村#巡逻"
    }
  },
  [20013] = {
    mnName = "渔村野鬼",
    missionDes = "龙宫的水丞相擅自打通了地府通道，使得地府里的野鬼能顺着通道能通向人间，这样使得原本祥和的渔村遭受了重创。渡厄禅师希望你能帮助他恢复渔村安宁。",
    acceptDes = "把巡逻情况告诉#<Y,>渡厄禅师#",
    needCmp = {20012},
    startNpc = 95012,
    acceptTalkId = 170055,
    zs = 0,
    lv = 62,
    rewardCoin = 6000,
    rewardGold = 0,
    rewardExp = 60132,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16007, 4007},
      talkId = 170056,
      param = 0,
      des = "去龙宫消灭#<Y,>水丞相#"
    },
    dst2 = {
      type = 101,
      data = 95012,
      talkId = 170057,
      param = 0,
      des = "向#<Y,>渡厄禅师#交付任务"
    }
  },
  [20014] = {
    mnName = "两小无猜",
    missionDes = "赵南星收到长安城寄来的信件后就一直愁眉苦展，似乎有重大事情发生。赶紧过去与他聊聊吧，问他到底发生了什么事情。",
    acceptDes = "渔村的#<Y,>赵南星#有事找你",
    needCmp = {20013},
    startNpc = 95015,
    acceptTalkId = 170061,
    zs = 0,
    lv = 64,
    rewardCoin = 6300,
    rewardGold = 0,
    rewardExp = 63424,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16008, 4008},
      talkId = 170062,
      param = 0,
      des = "教训集市里的#<Y,>恶霸#"
    },
    dst2 = {
      type = 101,
      data = 95015,
      talkId = 170063,
      param = 0,
      des = "告诉#<Y,>赵南星#玉佩的事情"
    }
  },
  [20015] = {
    mnName = "两小无猜",
    missionDes = "赵南星收到长安城寄来的信件后就一直愁眉苦展，似乎有重大事情发生。赶紧过去与他聊聊吧，问他到底发生了什么事情。",
    acceptDes = "0",
    needCmp = {20014},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 64,
    rewardCoin = 6300,
    rewardGold = 0,
    rewardExp = 63424,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 95015,
      talkId = 170064,
      param = {
        {21054, 1}
      },
      des = "继续与#<Y,>赵南星#交谈"
    },
    dst2 = {
      type = 402,
      data = 95017,
      talkId = 170065,
      param = {
        {21054, 1}
      },
      des = "将玉佩交给#<Y,>李双双#"
    }
  },
  [20016] = {
    mnName = "两小无猜",
    missionDes = "赵南星收到长安城寄来的信件后就一直愁眉苦展，似乎有重大事情发生。赶紧过去与他聊聊吧，问他到底发生了什么事情。",
    acceptDes = "0",
    needCmp = {20015},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 64,
    rewardCoin = 5100,
    rewardGold = 0,
    rewardExp = 50739,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 95015,
      talkId = 170066,
      param = 0,
      des = "告知#<Y,>赵南星#送玉佩成功"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20017] = {
    mnName = "僵尸出现",
    missionDes = "“城外有僵尸”最近这句话在长安城内广为流传，这可急坏了守护皇城的侍卫。侍卫希望你能找到这个谣言的传播者，并且帮他击破这个谣言。",
    acceptDes = "#<Y,>枪兵统领#有事找你",
    needCmp = {20016},
    startNpc = 95028,
    acceptTalkId = 170071,
    zs = 0,
    lv = 66,
    rewardCoin = 5300,
    rewardGold = 0,
    rewardExp = 53491,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 95018,
      talkId = 170072,
      param = 0,
      des = "向#<Y,>宋小生#了解谣言的情况"
    },
    dst2 = {
      type = 101,
      data = 95019,
      talkId = 170073,
      param = 0,
      des = "确认谣言是否来自#<Y,>天佑#"
    }
  },
  [20018] = {
    mnName = "僵尸出现",
    missionDes = "“城外有僵尸”最近这句话在长安城内广为流传，这可急坏了守护皇城的侍卫。侍卫希望你能找到这个谣言的传播者，并且帮他击破这个谣言。",
    acceptDes = "问#<Y,>天佑的奶奶#为什么撒谎",
    needCmp = {20017},
    startNpc = 95010,
    acceptTalkId = 170074,
    zs = 0,
    lv = 66,
    rewardCoin = 5300,
    rewardGold = 0,
    rewardExp = 53491,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 95028,
      talkId = 170075,
      param = 0,
      des = "告诉#<Y,>枪兵统领#你得来的情况"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20019] = {
    mnName = "僵尸出现",
    missionDes = "“城外有僵尸”最近这句话在长安城内广为流传，这可急坏了守护皇城的侍卫。侍卫希望你能找到这个谣言的传播者，并且帮他击破这个谣言。",
    acceptDes = "向#<Y,>枪兵统领了#了解破谣言的计划",
    needCmp = {20018},
    startNpc = 95028,
    acceptTalkId = 170076,
    zs = 0,
    lv = 66,
    rewardCoin = 6700,
    rewardGold = 0,
    rewardExp = 66864,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16009, 4009},
      talkId = 170077,
      param = 0,
      des = "去双叉岭消灭#<Y,>铜尸#"
    },
    dst2 = {
      type = 101,
      data = 95028,
      talkId = 170078,
      param = 0,
      des = "回复#<Y,>枪兵统领#"
    }
  },
  [20020] = {
    mnName = "失踪的妹妹",
    missionDes = "陈箐在姐姐陈英的带领之下第一次参加了化生寺的庙会节。正当姐姐替妹妹买好礼物时，回头却发现妹妹不见了。着急的姐姐希望你能帮她找回丢失的妹妹。",
    acceptDes = "安慰焦急的#<Y,>陈英#",
    needCmp = {20019},
    startNpc = 95021,
    acceptTalkId = 170081,
    zs = 0,
    lv = 68,
    rewardCoin = 5600,
    rewardGold = 0,
    rewardExp = 56367,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90908,
      talkId = 170082,
      param = 0,
      des = "向#<Y,>杂货商#打听陈箐的下落"
    },
    dst2 = {
      type = 101,
      data = 90302,
      talkId = 170083,
      param = 0,
      des = "向#<Y,>灵兽仙#打听陈箐的下落"
    }
  },
  [20021] = {
    mnName = "失踪的妹妹",
    missionDes = "陈箐在姐姐陈英的带领之下第一次参加了化生寺的庙会节。正当姐姐替妹妹买好礼物时，回头却发现妹妹不见了。着急的姐姐希望你能帮她找回丢失的妹妹。",
    acceptDes = "告诉#<Y,>陈箐#她家人在找她",
    needCmp = {20020},
    startNpc = 95022,
    acceptTalkId = 170084,
    zs = 0,
    lv = 68,
    rewardCoin = 7000,
    rewardGold = 0,
    rewardExp = 70458,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16010, 4010},
      talkId = 170085,
      param = 0,
      des = "消灭前方出现的#<Y,>妖怪#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20022] = {
    mnName = "失踪的妹妹",
    missionDes = "陈箐在姐姐陈英的带领之下第一次参加了化生寺的庙会节。正当姐姐替妹妹买好礼物时，回头却发现妹妹不见了。着急的姐姐希望你能帮她找回丢失的妹妹。",
    acceptDes = "看看#<Y,>陈箐#是否清醒",
    needCmp = {20021},
    startNpc = 95022,
    acceptTalkId = 170086,
    zs = 0,
    lv = 68,
    rewardCoin = 5600,
    rewardGold = 0,
    rewardExp = 56367,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 95021,
      talkId = 170087,
      param = 0,
      des = "向#<Y,>陈英#复命"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20023] = {
    mnName = "妖王的宝藏",
    missionDes = "长安城惊现宝藏之说，这让一些胆量过人的武士纷纷结队前往妖府挖宝。你根据酒馆老板提供的线索，找到了散布宝藏信息的侠客后，却发现其实这是个陷阱。",
    acceptDes = "与#<Y,>衙役#谈谈宝藏的事情",
    needCmp = {20022},
    startNpc = 90921,
    acceptTalkId = 170091,
    zs = 0,
    lv = 71,
    rewardCoin = 6100,
    rewardGold = 0,
    rewardExp = 60925,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90915,
      talkId = 170092,
      param = 0,
      des = "向#<Y,>酒店老板#打听宝藏的情况"
    },
    dst2 = {
      type = 101,
      data = 90915,
      talkId = 170093,
      param = 0,
      des = "打听#<Y,>落魄侠客#的下落"
    }
  },
  [20024] = {
    mnName = "妖王的宝藏",
    missionDes = "长安城惊现宝藏之说，这让一些胆量过人的武士纷纷结队前往妖府挖宝。你根据酒馆老板提供的线索，找到了散布宝藏信息的侠客后，却发现其实这是个陷阱。",
    acceptDes = "与#<Y,>侠客#达成口头协议",
    needCmp = {20023},
    startNpc = 95024,
    acceptTalkId = 170094,
    zs = 0,
    lv = 71,
    rewardCoin = 7600,
    rewardGold = 0,
    rewardExp = 76156,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16011, 4011},
      talkId = 170095,
      param = 0,
      des = "挑战魔王#<Y,>朱桀#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20025] = {
    mnName = "妖王的宝藏",
    missionDes = "长安城惊现宝藏之说，这让一些胆量过人的武士纷纷结队前往妖府挖宝。你根据酒馆老板提供的线索，找到了散布宝藏信息的侠客后，却发现其实这是个陷阱。",
    acceptDes = "把宝藏的骗局告诉#<Y,>衙役#",
    needCmp = {20024},
    startNpc = 90921,
    acceptTalkId = 170096,
    zs = 0,
    lv = 71,
    rewardCoin = 7600,
    rewardGold = 0,
    rewardExp = 76156,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16012, 4012},
      talkId = 170097,
      param = 0,
      des = "去魔王寨抓捕#<Y,>落魄的侠客#"
    },
    dst2 = {
      type = 101,
      data = 90921,
      talkId = 170098,
      param = 0,
      des = "将侠客交给#<Y,>衙役#"
    }
  },
  [20026] = {
    mnName = "鬼祟之人",
    missionDes = "从贝贝口中得知他受袁天罡之托，正在对对面的房子进行监控。你找袁天罡了解情况，他告诉你房子里隐藏的大量妖魔。袁天罡希望你能铲除这些妖魔，并查清他们在长安城做过些什么。",
    acceptDes = "看看树荫底下的#<Y,>小贝#在干什么",
    needCmp = {20025},
    startNpc = 95026,
    acceptTalkId = 170101,
    zs = 0,
    lv = 73,
    rewardCoin = 6400,
    rewardGold = 0,
    rewardExp = 64135,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90926,
      talkId = 170102,
      param = 0,
      des = "找#<Y,>袁天罡#探听情况"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20027] = {
    mnName = "鬼祟之人",
    missionDes = "从贝贝口中得知他受袁天罡之托，正在对对面的房子进行监控。你找袁天罡了解情况，他告诉你房子里隐藏的大量妖魔。袁天罡希望你能铲除这些妖魔，并查清他们在长安城做过些什么。",
    acceptDes = "0",
    needCmp = {20026},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 73,
    rewardCoin = 8000,
    rewardGold = 0,
    rewardExp = 80169,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 209,
      data = {16013, 4013},
      talkId = 170103,
      param = {
        {
          21055,
          1,
          100
        }
      },
      des = "消灭宅中#<Y,>妖魔#"
    },
    dst2 = {
      type = 402,
      data = 90926,
      talkId = 170104,
      param = {
        {21055, 1}
      },
      des = "将瓷瓶交给#<Y,>袁天罡#鉴定"
    }
  },
  [20028] = {
    mnName = "鬼祟之人",
    missionDes = "从贝贝口中得知他受袁天罡之托，正在对对面的房子进行监控。你找袁天罡了解情况，他告诉你房子里隐藏的大量妖魔。袁天罡希望你能铲除这些妖魔，并查清他们在长安城做过些什么。",
    acceptDes = "0",
    needCmp = {20027},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 73,
    rewardCoin = 6400,
    rewardGold = 0,
    rewardExp = 64135,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 95026,
      talkId = 170105,
      param = 0,
      des = "找到#<Y,>小贝#让他赶紧回家"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20029] = {
    mnName = "奇怪的石头",
    missionDes = "有人发现从岩晶矿中能打磨出黑色珍珠，这种发现让岩晶矿的价格瞬间提升了几倍。长安首富钱掌柜希望你能帮他找到一块岩晶石以作为母亲九十大寿的寿礼，结果你发现...",
    acceptDes = "问问#<Y,>杂货商#矿石的情况",
    needCmp = {20028},
    startNpc = 90908,
    acceptTalkId = 170111,
    zs = 0,
    lv = 75,
    rewardCoin = 6700,
    rewardGold = 0,
    rewardExp = 67491,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90941,
      talkId = 170112,
      param = 0,
      des = "与#<Y,>钱掌柜#聊聊矿石"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20030] = {
    mnName = "奇怪的石头",
    missionDes = "有人发现从岩晶矿中能打磨出黑色珍珠，这种发现让岩晶矿的价格瞬间提升了几倍。长安首富钱掌柜希望你能帮他找到一块岩晶石以作为母亲九十大寿的寿礼，结果你发现...",
    acceptDes = "#<Y,>钱掌柜#有事请你帮忙",
    needCmp = {20029},
    startNpc = 90941,
    acceptTalkId = 170113,
    zs = 0,
    lv = 75,
    rewardCoin = 8400,
    rewardGold = 0,
    rewardExp = 84363,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 209,
      data = {16014, 4014},
      talkId = 0,
      wftalkId = 170114,
      param = {
        {
          21056,
          1,
          100
        }
      },
      des = "打败#<Y,>石灵#获得岩晶矿"
    },
    dst2 = {
      type = 402,
      data = 90941,
      talkId = 170115,
      param = {
        {21056, 1}
      },
      des = "将岩晶矿交给#<Y,>钱掌柜#"
    }
  },
  [20031] = {
    mnName = "奇怪的石头",
    missionDes = "有人发现从岩晶矿中能打磨出黑色珍珠，这种发现让岩晶矿的价格瞬间提升了几倍。长安首富钱掌柜希望你能帮他找到一块岩晶石以作为母亲九十大寿的寿礼，结果你发现...",
    acceptDes = "找#<Y,>袁天罡#想办法",
    needCmp = {20030},
    startNpc = 90926,
    acceptTalkId = 170116,
    zs = 0,
    lv = 75,
    rewardCoin = 6700,
    rewardGold = 0,
    rewardExp = 67491,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90926,
      talkId = 170117,
      param = 0,
      des = "向#<Y,>袁天罡#取得妖怪的下落"
    },
    dst2 = {
      type = 208,
      data = {16015, 4015},
      talkId = 170118,
      param = 0,
      des = "去女儿国消灭#<Y,>擎天妖#"
    }
  },
  [20032] = {
    mnName = "奇怪的石头",
    missionDes = "有人发现从岩晶矿中能打磨出黑色珍珠，这种发现让岩晶矿的价格瞬间提升了几倍。长安首富钱掌柜希望你能帮他找到一块岩晶石以作为母亲九十大寿的寿礼，结果你发现...",
    acceptDes = "0",
    needCmp = {20031},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 75,
    rewardCoin = 6700,
    rewardGold = 0,
    rewardExp = 67491,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90926,
      talkId = 170119,
      param = 0,
      des = "答谢#<Y,>袁天罡#给你的帮助"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20033] = {
    mnName = "香妃竹",
    missionDes = "杂货商的女儿想要一把由香妃竹打造的笛子，这可把杂货商老板急坏了。杂货商希望你能帮他满足女儿的小小心愿。",
    acceptDes = "#<Y,>酒馆老板#有事找你",
    needCmp = {20032},
    startNpc = 90915,
    acceptTalkId = 170121,
    zs = 0,
    lv = 77,
    rewardCoin = 7100,
    rewardGold = 0,
    rewardExp = 70997,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90926,
      talkId = 170122,
      param = 0,
      des = "向#<Y,>袁天罡#打听香妃竹情况"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20034] = {
    mnName = "香妃竹",
    missionDes = "杂货商的女儿想要一把由香妃竹打造的笛子，这可把杂货商老板急坏了。杂货商希望你能帮他满足女儿的小小心愿。",
    acceptDes = "告诉#<Y,>酒馆老板#香妃竹的下落",
    needCmp = {20033},
    startNpc = 90915,
    acceptTalkId = 170123,
    zs = 0,
    lv = 77,
    rewardCoin = 8900,
    rewardGold = 0,
    rewardExp = 88747,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 209,
      data = {16016, 4016},
      talkId = 170124,
      param = {
        {
          21057,
          1,
          100
        }
      },
      des = "去方寸山找到#<Y,>竹熊#取得竹子"
    },
    dst2 = {
      type = 402,
      data = 90915,
      talkId = 170125,
      param = {
        {21057, 1}
      },
      des = "将香妃竹交给#<Y,>酒馆老板#"
    }
  },
  [20035] = {
    mnName = "捣乱鬼",
    missionDes = "小福发现每逢夜晚，院子里就开始发出咚咚咚的敲打声。这声音已经折腾着小福三天没有睡好觉。变成熊猫样的小福希望你能帮他调查此事。",
    acceptDes = "#<Y,>阿福#有事找你",
    needCmp = {20034},
    startNpc = 95031,
    acceptTalkId = 170131,
    zs = 0,
    lv = 78,
    rewardCoin = 9100,
    rewardGold = 0,
    rewardExp = 91012,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16017, 4017},
      talkId = 170132,
      param = 0,
      des = "去城东消灭#<Y,>捣乱鬼#"
    },
    dst2 = {
      type = 101,
      data = 95031,
      talkId = 170133,
      param = 0,
      des = "告知#<Y,>阿福#恶鬼已灭"
    }
  },
  [20036] = {
    mnName = "火麒麟",
    missionDes = "茜茜养了一只妖兽，这让村子里的村民感到恐惧。为了村民的安全着想，茜茜不得不将妖兽放逐村外。几年过去了，茜茜十分很想念它。茜茜希望你能代她探望那只妖兽。",
    acceptDes = "#<Y,>茜茜#有事拜托你",
    needCmp = {20035},
    startNpc = 95004,
    acceptTalkId = 170141,
    zs = 0,
    lv = 80,
    rewardCoin = 7700,
    rewardGold = 0,
    rewardExp = 76556,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90922,
      talkId = 170142,
      param = 0,
      des = "向#<Y,>墨老#打听妖兽的情况"
    },
    dst2 = {
      type = 208,
      data = {16018, 4018},
      talkId = 170143,
      wftalkId = 170144,
      param = 0,
      des = "找到墨老所说的#<Y,>方寸山弟子#"
    }
  },
  [20037] = {
    mnName = "火麒麟",
    missionDes = "茜茜养了一只妖兽，这让村子里的村民感到恐惧。为了村民的安全着想，茜茜不得不将妖兽放逐村外。几年过去了，茜茜十分很想念它。茜茜希望你能代她探望那只妖兽。",
    acceptDes = "去后山与#<Y,>火麒麟#对话",
    needCmp = {20036},
    startNpc = 95034,
    acceptTalkId = 170145,
    zs = 0,
    lv = 80,
    rewardCoin = 7700,
    rewardGold = 0,
    rewardExp = 76556,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 95004,
      talkId = 170146,
      param = 0,
      des = "将火麒麟的情况告诉#<Y,>茜茜#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20038] = {
    mnName = "祸水",
    missionDes = "化生寺内门出了个败类，这让德高望重的渡远禅师犯了嗔戒。此时他正在气急败坏的向你描述着这个弟子有多坏，渡远禅师希望你能帮他擒拿劣徒归寺。",
    acceptDes = "#<Y,>渡远禅师#有事找你",
    needCmp = {20037},
    startNpc = 90901,
    acceptTalkId = 170151,
    zs = 0,
    lv = 81,
    rewardCoin = 9800,
    rewardGold = 0,
    rewardExp = 98116,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16019, 4019},
      talkId = 170152,
      param = 0,
      des = "去城南抓捕#<Y,>公孙止#"
    },
    dst2 = {
      type = 101,
      data = 90901,
      talkId = 170153,
      param = 0,
      des = "将孽徒交给#<Y,>渡远禅师#"
    }
  },
  [20039] = {
    mnName = "消失的银两",
    missionDes = "何万财家的家财一夜之间全部消失，此番消息一出惊动了长安城里的贵族们。你闻得此信后前去探望何万财，只见他一脸惆怅的依附在大门口。看到此景，你决定帮他做些什么。",
    acceptDes = "向#<Y,>何万财#了解财物丢失的细节",
    needCmp = {20038},
    startNpc = 90931,
    acceptTalkId = 170161,
    zs = 0,
    lv = 83,
    rewardCoin = 8200,
    rewardGold = 0,
    rewardExp = 82495,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90921,
      talkId = 170162,
      param = 0,
      des = "找长安#<Y,>衙役#想办法"
    },
    dst2 = {
      type = 208,
      data = {16020, 4020},
      talkId = 170163,
      wftalkId = 170164,
      param = 0,
      des = "根据衙线索找到#<Y,>一品梅#"
    }
  },
  [20040] = {
    mnName = "消失的银两",
    missionDes = "何万财家的家财一夜之间全部消失，此番消息一出惊动了长安城里的贵族们。你闻得此信后前去探望何万财，只见他一脸惆怅的依附在大门口。看到此景，你决定帮他做些什么。",
    acceptDes = "求助#<Y,>紫霞仙子#",
    needCmp = {20039},
    startNpc = 90907,
    acceptTalkId = 170165,
    zs = 0,
    lv = 83,
    rewardCoin = 10300,
    rewardGold = 0,
    rewardExp = 103119,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16021, 4021},
      talkId = 170166,
      wftalkId = 170167,
      param = 0,
      des = "去地府教训#<Y,>罗判官#"
    },
    dst2 = {
      type = 101,
      data = 90931,
      talkId = 170168,
      param = 0,
      des = "询问#<Y,>何万财#银两是否回归"
    }
  },
  [20041] = {
    mnName = "玄灵角",
    missionDes = "扬我国威，彰显我朝为礼仪之邦。药王孙思邈受当今天子之命，前往车迟国为车迟国百姓根治传染病。在出发前孙思邈找到了你，希望你能帮他取得一些主药药引玄灵角。",
    acceptDes = "药王#<Y,>孙思邈#有事找你",
    needCmp = {20040},
    startNpc = 90973,
    acceptTalkId = 170171,
    zs = 0,
    lv = 84,
    rewardCoin = 10600,
    rewardGold = 0,
    rewardExp = 105705,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 209,
      data = {16022, 4022},
      talkId = 170172,
      param = {
        {
          21058,
          1,
          100
        }
      },
      des = "去方寸山取得#<Y,>玄灵角#"
    },
    dst2 = {
      type = 402,
      data = 90973,
      talkId = 170173,
      param = {
        {21058, 1}
      },
      des = "将玄灵角交给#<Y,>孙思邈#"
    }
  },
  [20042] = {
    mnName = "凤羽",
    missionDes = "众妖齐聚火焰山，这可把负责监视火焰山的魔王子弟子彭青吓了一跳。袁天罡得知此消息后知道兹事重大，他找到了你，希望你能代替彭青调查此事。",
    acceptDes = "#<Y,>袁天罡#有消息告诉你",
    needCmp = {20041},
    startNpc = 90926,
    acceptTalkId = 170181,
    zs = 0,
    lv = 86,
    rewardCoin = 8900,
    rewardGold = 0,
    rewardExp = 88841,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 95039,
      talkId = 170182,
      param = 0,
      des = "向#<Y,>彭青#打听火焰山的情况"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20043] = {
    mnName = "凤羽",
    missionDes = "众妖齐聚火焰山，这可把负责监视火焰山的魔王子弟子彭青吓了一跳。袁天罡得知此消息后知道兹事重大，他找到了你，希望你能代替彭青调查此事。",
    acceptDes = "0",
    needCmp = {20042},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 86,
    rewardCoin = 11100,
    rewardGold = 0,
    rewardExp = 111051,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 209,
      data = {16023, 4023},
      talkId = 170183,
      param = {
        {
          21059,
          1,
          100
        }
      },
      des = "拦截落单的#<Y,>炽火鸟#"
    },
    dst2 = {
      type = 402,
      data = 90926,
      talkId = 170184,
      param = {
        {21059, 1}
      },
      des = "将凤羽交给#<Y,>袁天罡#"
    }
  },
  [20044] = {
    mnName = "凤羽",
    missionDes = "众妖齐聚火焰山，这可把负责监视火焰山的魔王子弟子彭青吓了一跳。袁天罡得知此消息后知道兹事重大，他找到了你，希望你能代替彭青调查此事。",
    acceptDes = "找#<Y,>袁天罡#解开心中的疑问",
    needCmp = {20043},
    startNpc = 90926,
    acceptTalkId = 170185,
    zs = 0,
    lv = 86,
    rewardCoin = 11100,
    rewardGold = 0,
    rewardExp = 111051,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16024, 4024},
      talkId = 170186,
      wftalkId = 170187,
      param = 0,
      des = "从火焰山#<Y,>青翼鸟怪#口中打听消息"
    },
    dst2 = {
      type = 101,
      data = 90926,
      talkId = 170188,
      param = 0,
      des = "告知#<Y,>袁天罡#百鸟朝拜的消息"
    }
  },
  [20045] = {
    mnName = "石怪",
    missionDes = "双叉岭岭上出现了一个巨大的石怪，它试图摧毁整座双叉岭。如果不阻拦，双叉岭岭下的居民将会面临着生命危险。",
    acceptDes = "替受伤的#<Y,>化生寺弟子#疗伤",
    needCmp = {20044},
    startNpc = 90982,
    acceptTalkId = 170191,
    zs = 0,
    lv = 87,
    rewardCoin = 11400,
    rewardGold = 0,
    rewardExp = 113814,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16025, 4025},
      talkId = 170192,
      param = 0,
      des = "去双叉岭消灭#<Y,>石怪#"
    },
    dst2 = {
      type = 101,
      data = 90982,
      talkId = 170193,
      param = 0,
      des = "告知#<Y,>化生寺弟子#石怪已灭的消息"
    }
  },
  [20046] = {
    mnName = "石怪",
    missionDes = "双叉岭岭上出现了一个巨大的石怪，它试图摧毁整座双叉岭。如果不阻拦，双叉岭岭下的居民将会面临着生命危险。",
    acceptDes = "询问#<Y,>化生寺弟子#出现石怪的原因",
    needCmp = {20045},
    startNpc = 90982,
    acceptTalkId = 170194,
    zs = 0,
    lv = 87,
    rewardCoin = 9100,
    rewardGold = 0,
    rewardExp = 91051,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90901,
      talkId = 170195,
      param = 0,
      des = "向#<Y,>渡远禅师#了解原由"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20047] = {
    mnName = "广藿香",
    missionDes = "何万财得到一份来自长安城杂货商的物品清单，清单中所要的广藿香需要到千里之外的女儿国进行采购。但最近通往女儿国的路上出现了一些障碍，这可把何万财急的像热锅上的蚂蚁。",
    acceptDes = "#<Y,>杂货商#希望你能帮他送一封信",
    needCmp = {20046},
    startNpc = 90908,
    acceptTalkId = 170201,
    zs = 0,
    lv = 89,
    rewardCoin = 12000,
    rewardGold = 0,
    rewardExp = 119526,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 90908,
      talkId = 170202,
      param = {
        {21028, 1}
      },
      des = "继续与#<Y,>杂货商#交谈取得信件"
    },
    dst2 = {
      type = 402,
      data = 90931,
      talkId = 170203,
      param = {
        {21028, 1}
      },
      des = "将信交给渔村#<Y,>何万财#"
    }
  },
  [20048] = {
    mnName = "广藿香",
    missionDes = "何万财得到一份来自长安城杂货商的物品清单，清单中所要的广藿香需要到千里之外的女儿国进行采购。但最近通往女儿国的路上出现了一些障碍，这可把何万财急的像热锅上的蚂蚁。",
    acceptDes = "询问#<Y,>何万财#为何一脸苦闷表情",
    needCmp = {20047},
    startNpc = 90931,
    acceptTalkId = 170204,
    zs = 0,
    lv = 89,
    rewardCoin = 12000,
    rewardGold = 0,
    rewardExp = 119526,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16026, 4026},
      talkId = 170205,
      param = 0,
      des = "去女儿国消灭#<Y,>蝼蛄怪#"
    },
    dst2 = {
      type = 101,
      data = 90931,
      talkId = 170206,
      param = 0,
      des = "向#<Y,>何万财#交付任务"
    }
  },
  [20049] = {
    mnName = "孝心",
    missionDes = "常年在外征战的程咬金有一老毛病--老寒腿，这种老毛病致使他每逢冬天都苦不堪言。程府的丫环为了老将军的健康，请求你帮她取得一块火焰晶石来帮助老将军渡过一个不在寒冷的冬天。",
    acceptDes = "#<Y,>程家丫环#有事拜托你",
    needCmp = {20048},
    startNpc = 90927,
    acceptTalkId = 170211,
    zs = 0,
    lv = 90,
    rewardCoin = 12200,
    rewardGold = 0,
    rewardExp = 122477,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 209,
      data = {16027, 4027},
      talkId = 170212,
      param = {
        {
          21044,
          1,
          100
        }
      },
      des = "去火焰山取得#<Y,>火焰晶石#"
    },
    dst2 = {
      type = 402,
      data = 90927,
      talkId = 170213,
      param = {
        {21044, 1}
      },
      des = "将火焰晶石交给#<Y,>丫环#"
    }
  },
  [20050] = {
    mnName = "城内妖气",
    missionDes = "“城内有妖魔踪迹”这是袁天罡见到你开口说的第一句话。了解情况后的你打算替袁天罡找到隐藏在长安城内的妖怪。",
    acceptDes = "询问#<Y,>袁天罡#长安发生了什么事",
    needCmp = {20049},
    startNpc = 90926,
    acceptTalkId = 170231,
    zs = 0,
    lv = 92,
    rewardCoin = 10300,
    rewardGold = 0,
    rewardExp = 102863,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 170232,
      param = 0,
      des = "向#<Y,>紫霞仙子#求助"
    },
    dst2 = {
      type = 208,
      data = {16028, 4028},
      talkId = 170233,
      wftalkId = 170234,
      param = 0,
      des = "搜索#<Y,>长安城南#"
    }
  },
  [20051] = {
    mnName = "城内妖气",
    missionDes = "“城内有妖魔踪迹”这是袁天罡见到你开口说的第一句话。了解情况后的你打算替袁天罡找到隐藏在长安城内的妖怪。",
    acceptDes = "告诉#<Y,>袁天罡#城南所遇到的情况",
    needCmp = {20050},
    startNpc = 90926,
    acceptTalkId = 170235,
    zs = 0,
    lv = 92,
    rewardCoin = 12900,
    rewardGold = 0,
    rewardExp = 128579,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16029, 4029},
      talkId = 170236,
      param = 0,
      des = "搜索#<Y,>长安城北#"
    },
    dst2 = {
      type = 101,
      data = 90926,
      talkId = 170237,
      param = 0,
      des = "向#<Y,>袁天罡#交付任务"
    }
  },
  [20052] = {
    mnName = "知府公子",
    missionDes = "何知府自家公子三天未归，着急的何知府派遣了大量捕快到处搜寻。由于涉事范围广，而人手又不够，已经两天没有合过眼的衙役希望你能帮帮他。",
    acceptDes = "长安#<Y,>衙役#有急事找你",
    needCmp = {20051},
    startNpc = 90921,
    acceptTalkId = 170241,
    zs = 0,
    lv = 94,
    rewardCoin = 10800,
    rewardGold = 0,
    rewardExp = 107964,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90924,
      talkId = 170242,
      param = 0,
      des = "向郊外的#<Y,>许婆婆#打听情况"
    },
    dst2 = {
      type = 208,
      data = {16030, 4030},
      talkId = 0,
      wftalkId = 170243,
      param = 0,
      des = "消灭双叉岭出现的#<Y,>蝴蝶精#"
    }
  },
  [20053] = {
    mnName = "知府公子",
    missionDes = "何知府自家公子三天未归，着急的何知府派遣了大量捕快到处搜寻。由于涉事范围广，而人手又不够，已经两天没有合过眼的衙役希望你能帮帮他。",
    acceptDes = "找到失踪的#<Y,>何公子#",
    needCmp = {20052},
    startNpc = 95049,
    acceptTalkId = 170244,
    zs = 0,
    lv = 94,
    rewardCoin = 10800,
    rewardGold = 0,
    rewardExp = 107964,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90921,
      talkId = 170245,
      param = 0,
      des = "回复#<Y,>衙役#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20054] = {
    mnName = "知府公子",
    missionDes = "何知府自家公子三天未归，着急的何知府派遣了大量捕快到处搜寻。由于涉事范围广，而人手又不够，已经两天没有合过眼的衙役希望你能帮帮他。",
    acceptDes = "向#<Y,>衙役#交代后山蛇妖的事情",
    needCmp = {20053},
    startNpc = 90921,
    acceptTalkId = 170246,
    zs = 0,
    lv = 94,
    rewardCoin = 13500,
    rewardGold = 0,
    rewardExp = 134955,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16031, 4031},
      talkId = 170247,
      param = 0,
      des = "去郊外后山消灭#<Y,>蛇妖#"
    },
    dst2 = {
      type = 101,
      data = 90921,
      talkId = 170248,
      param = 0,
      des = "向#<Y,>衙役#交付任务"
    }
  },
  [20055] = {
    mnName = "混世魔王",
    missionDes = "袁天罡希望你能代他去看看好友程咬金，在看探望间如果程咬金有什么要求的话，袁天罡希望你能满足他。",
    acceptDes = "#<Y,>袁天罡#有事找你",
    needCmp = {20054},
    startNpc = 90926,
    acceptTalkId = 170251,
    zs = 0,
    lv = 96,
    rewardCoin = 11300,
    rewardGold = 0,
    rewardExp = 113294,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 95052,
      talkId = 170252,
      param = 0,
      des = "探望#<Y,>程咬金#"
    },
    dst2 = {
      type = 208,
      data = {16032, 4032},
      talkId = 0,
      param = 0,
      des = "打败#<Y,>程府侍卫#"
    }
  },
  [20056] = {
    mnName = "混世魔王",
    missionDes = "袁天罡希望你能代他去看看好友程咬金，在看探望间如果程咬金有什么要求的话，袁天罡希望你能满足他。",
    acceptDes = "听听#<Y,>程咬金#说些什么",
    needCmp = {20055},
    startNpc = 95052,
    acceptTalkId = 170253,
    zs = 0,
    lv = 96,
    rewardCoin = 11300,
    rewardGold = 0,
    rewardExp = 113294,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90926,
      talkId = 170254,
      param = 0,
      des = "将程府发生的事情告诉#<Y,>袁天罡#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20057] = {
    mnName = "龙女之托",
    missionDes = "二百多年前统领天庭千万水军的天蓬元帅因犯天条被打落凡间。时至今日，曾经气宇非凡的天蓬元帅因误入六道轮回，变成了一只猪妖，其灵智也收到了蒙蔽。菩萨希望你帮天蓬找回前世记忆。",
    acceptDes = "与#<Y,>小龙女#交谈",
    needCmp = {20056},
    startNpc = 91001,
    acceptTalkId = 170261,
    zs = 0,
    lv = 98,
    rewardCoin = 11900,
    rewardGold = 0,
    rewardExp = 118864,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90907,
      talkId = 170262,
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
  [20058] = {
    mnName = "龙女之托",
    missionDes = "二百多年前统领天庭千万水军的天蓬元帅因犯天条被打落凡间。时至今日，曾经气宇非凡的天蓬元帅因误入六道轮回，变成了一只猪妖，其灵智也收到了蒙蔽。菩萨希望你帮天蓬找回前世记忆。",
    acceptDes = "向双叉岭#<Y,>土地神#打听消息",
    needCmp = {20057},
    startNpc = 90939,
    acceptTalkId = 170263,
    zs = 0,
    lv = 98,
    rewardCoin = 14900,
    rewardGold = 0,
    rewardExp = 148581,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16033, 4033},
      talkId = 170264,
      wftalkId = 170265,
      param = 0,
      des = "去龙宫找到#<Y,>孤直公#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20059] = {
    mnName = "仙人指路",
    missionDes = "二百多年前统领天庭千万水军的天蓬元帅因犯天条被打落凡间。时至今日，曾经气宇非凡的天蓬元帅因误入六道轮回，变成了一只猪妖，其灵智也收到了蒙蔽。菩萨希望你帮天蓬找回前世记忆。",
    acceptDes = "将妖府发生的事情告诉#<Y,>紫霞仙子#",
    needCmp = {20058},
    startNpc = 90907,
    acceptTalkId = 170271,
    zs = 0,
    lv = 98,
    rewardCoin = 11900,
    rewardGold = 0,
    rewardExp = 118864,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 95054,
      talkId = 170272,
      param = 0,
      des = "去双叉岭找到#<Y,>天蓬元帅#"
    },
    dst2 = {
      type = 101,
      data = 95054,
      talkId = 170273,
      param = 0,
      des = "询问#<Y,>天蓬元帅#是否记起当年的事情"
    }
  },
  [20060] = {
    mnName = "仙人指路",
    missionDes = "二百多年前统领天庭千万水军的天蓬元帅因犯天条被打落凡间。时至今日，曾经气宇非凡的天蓬元帅因误入六道轮回，变成了一只猪妖，其灵智也收到了蒙蔽。菩萨希望你帮天蓬找回前世记忆。",
    acceptDes = "听听#<Y,>天蓬元帅#在嘀咕什么",
    needCmp = {20059},
    startNpc = 95054,
    acceptTalkId = 170274,
    zs = 0,
    lv = 98,
    rewardCoin = 11900,
    rewardGold = 0,
    rewardExp = 118864,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90939,
      talkId = 170275,
      param = 0,
      des = "向土地神打听#<Y,>幽冥#的下落"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20061] = {
    mnName = "仙人指路",
    missionDes = "二百多年前统领天庭千万水军的天蓬元帅因犯天条被打落凡间。时至今日，曾经气宇非凡的天蓬元帅因误入六道轮回，变成了一只猪妖，其灵智也收到了蒙蔽。菩萨希望你帮天蓬找回前世记忆。",
    acceptDes = "0",
    needCmp = {20060},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 98,
    rewardCoin = 14900,
    rewardGold = 0,
    rewardExp = 148581,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16034, 4034},
      talkId = 170276,
      param = 0,
      des = "去魔王寨打败#<Y,>幽冥#"
    },
    dst2 = {
      type = 101,
      data = 95054,
      talkId = 170277,
      param = 0,
      des = "向#<Y,>天蓬元帅#交付任务"
    }
  },
  [20062] = {
    mnName = "骗局",
    missionDes = "二百多年前统领天庭千万水军的天蓬元帅因犯天条被打落凡间。时至今日，曾经气宇非凡的天蓬元帅因误入六道轮回，变成了一只猪妖，其灵智也收到了蒙蔽。菩萨希望你帮天蓬找回前世记忆。",
    acceptDes = "向土地打听#<Y,>十八公#的事情",
    needCmp = {20061},
    startNpc = 90939,
    acceptTalkId = 170281,
    zs = 0,
    lv = 98,
    rewardCoin = 11900,
    rewardGold = 0,
    rewardExp = 118864,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 95055,
      talkId = 170282,
      param = 0,
      des = "找到#<Y,>十八公#打听月光石下落"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20063] = {
    mnName = "骗局",
    missionDes = "二百多年前统领天庭千万水军的天蓬元帅因犯天条被打落凡间。时至今日，曾经气宇非凡的天蓬元帅因误入六道轮回，变成了一只猪妖，其灵智也收到了蒙蔽。菩萨希望你帮天蓬找回前世记忆。",
    acceptDes = "答应#<Y,>十八公#的委托",
    needCmp = {20062},
    startNpc = 95055,
    acceptTalkId = 170283,
    zs = 0,
    lv = 98,
    rewardCoin = 14900,
    rewardGold = 0,
    rewardExp = 148581,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16035, 4035},
      talkId = 170284,
      param = 0,
      des = "去东海龙宫消灭#<Y,>北冥#"
    },
    dst2 = {
      type = 101,
      data = 95055,
      talkId = 170285,
      param = 0,
      des = "要#<Y,>十八公#兑现承诺"
    }
  },
  [20064] = {
    mnName = "骗局",
    missionDes = "二百多年前统领天庭千万水军的天蓬元帅因犯天条被打落凡间。时至今日，曾经气宇非凡的天蓬元帅因误入六道轮回，变成了一只猪妖，其灵智也收到了蒙蔽。菩萨希望你帮天蓬找回前世记忆。",
    acceptDes = "转达消息给#<Y,>化生寺护院#",
    needCmp = {20063},
    startNpc = 95058,
    acceptTalkId = 170286,
    zs = 0,
    lv = 98,
    rewardCoin = 14900,
    rewardGold = 0,
    rewardExp = 148581,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16036, 4036},
      talkId = 170287,
      param = 0,
      des = "消灭骗人的#<Y,>十八公#"
    },
    dst2 = {
      type = 101,
      data = 95058,
      talkId = 170288,
      param = 0,
      des = "向#<Y,>化生寺护院#交付任务"
    }
  },
  [20065] = {
    mnName = "月光石",
    missionDes = "二百多年前统领天庭千万水军的天蓬元帅因犯天条被打落凡间。时至今日，曾经气宇非凡的天蓬元帅因误入六道轮回，变成了一只猪妖，其灵智也收到了蒙蔽。菩萨希望你帮天蓬找回前世记忆。",
    acceptDes = "请求#<Y,>钱掌柜#帮忙",
    needCmp = {20064},
    startNpc = 90941,
    acceptTalkId = 170291,
    zs = 0,
    lv = 98,
    rewardCoin = 14900,
    rewardGold = 0,
    rewardExp = 148581,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 90941,
      talkId = 170292,
      param = {
        {21060, 1}
      },
      des = "继续与#<Y,>钱掌柜#对话,取得月光石"
    },
    dst2 = {
      type = 402,
      data = 95054,
      talkId = 170293,
      param = {
        {21060, 1}
      },
      des = "用月光石替#<Y,>天蓬元帅#恢复记忆"
    }
  },
  [20066] = {
    mnName = "月光石",
    missionDes = "二百多年前统领天庭千万水军的天蓬元帅因犯天条被打落凡间。时至今日，曾经气宇非凡的天蓬元帅因误入六道轮回，变成了一只猪妖，其灵智也收到了蒙蔽。菩萨希望你帮天蓬找回前世记忆。",
    acceptDes = "叫#<Y,>天蓬元帅#将月光石归还给你",
    needCmp = {20065},
    startNpc = 95054,
    acceptTalkId = 170294,
    zs = 0,
    lv = 98,
    rewardCoin = 11900,
    rewardGold = 0,
    rewardExp = 118864,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90904,
      talkId = 170295,
      param = 0,
      des = "向#<Y,>观音菩萨#伸冤"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20067] = {
    mnName = "月光石",
    missionDes = "二百多年前统领天庭千万水军的天蓬元帅因犯天条被打落凡间。时至今日，曾经气宇非凡的天蓬元帅因误入六道轮回，变成了一只猪妖，其灵智也收到了蒙蔽。菩萨希望你帮天蓬找回前世记忆。",
    acceptDes = "0",
    needCmp = {20066},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 98,
    rewardCoin = 14900,
    rewardGold = 0,
    rewardExp = 148581,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 209,
      data = {16037, 4037},
      talkId = 170296,
      wftalkId = 170297,
      param = {
        {
          21060,
          1,
          100
        }
      },
      des = "斩断#<Y,>天蓬元帅#的情丝夺回月光石"
    },
    dst2 = {
      type = 402,
      data = 90941,
      talkId = 170298,
      param = {
        {21060, 1}
      },
      des = "将月光石还给#<Y,>钱掌柜#"
    }
  },
  [20068] = {
    mnName = "月光石",
    missionDes = "二百多年前统领天庭千万水军的天蓬元帅因犯天条被打落凡间。时至今日，曾经气宇非凡的天蓬元帅因误入六道轮回，变成了一只猪妖，其灵智也收到了蒙蔽。菩萨希望你帮天蓬找回前世记忆。",
    acceptDes = "0",
    needCmp = {20067},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 98,
    rewardCoin = 11900,
    rewardGold = 0,
    rewardExp = 118864,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90904,
      talkId = 170299,
      param = 0,
      des = "回复#<Y,>观音菩萨#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20069] = {
    mnName = "失心的卷帘",
    missionDes = "卷帘大将自从打碎琉璃盏被贬下凡间之后，就沓讯全无，这让他的好友双锤天将很担心。双锤天将希望你能去双叉岭代他探望老朋友，结果去之后你发现...",
    acceptDes = "#<Y,>双锤天将#有事找你",
    needCmp = {20068},
    startNpc = 91002,
    acceptTalkId = 170301,
    zs = 0,
    lv = 100,
    rewardCoin = 12500,
    rewardGold = 0,
    rewardExp = 124685,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 95061,
      talkId = 170302,
      param = 0,
      des = "去双叉岭探望#<Y,>卷帘大将#"
    },
    dst2 = {
      type = 101,
      data = 91002,
      talkId = 170303,
      param = 0,
      des = "将卷帘大将的情况告知#<Y,>双锤天将#"
    }
  },
  [20070] = {
    mnName = "清心符",
    missionDes = "卷帘大将自从打碎琉璃盏被贬下凡间之后，就沓讯全无，这让他的好友双锤天将很担心。双锤天将希望你能去双叉岭代他探望老朋友，结果去之后你发现...",
    acceptDes = "向#<Y,>镇元大仙#求助",
    needCmp = {20069},
    startNpc = 90903,
    acceptTalkId = 170311,
    zs = 0,
    lv = 100,
    rewardCoin = 15600,
    rewardGold = 0,
    rewardExp = 155856,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 209,
      data = {16038, 4038},
      talkId = 170312,
      param = {
        {
          21064,
          1,
          100
        }
      },
      des = "取得#<Y,>护山神兽#灵血"
    },
    dst2 = {
      type = 402,
      data = 90903,
      talkId = 170313,
      param = {
        {21064, 1}
      },
      des = "将灵血交给#<Y,>镇元大仙#"
    }
  },
  [20071] = {
    mnName = "清心符",
    missionDes = "卷帘大将自从打碎琉璃盏被贬下凡间之后，就沓讯全无，这让他的好友双锤天将很担心。双锤天将希望你能去双叉岭代他探望老朋友，结果去之后你发现...",
    acceptDes = "0",
    needCmp = {20070},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 100,
    rewardCoin = 15600,
    rewardGold = 0,
    rewardExp = 155856,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 90903,
      talkId = 170314,
      param = {
        {21024, 1}
      },
      des = "与#<Y,>镇元大仙#交谈取得清心符"
    },
    dst2 = {
      type = 402,
      data = 95061,
      talkId = 170315,
      param = {
        {21024, 1}
      },
      des = "将清心符交由#<Y,>卷帘大将#引心魔现形"
    }
  },
  [20072] = {
    mnName = "心魔",
    missionDes = "卷帘大将自从打碎琉璃盏被贬下凡间之后，就沓讯全无，这让他的好友双锤天将很担心。双锤天将希望你能去双叉岭代他探望老朋友，结果去之后你发现...",
    acceptDes = "找#<Y,>袁天罡#推算心魔下落",
    needCmp = {20071},
    startNpc = 90926,
    acceptTalkId = 170321,
    zs = 0,
    lv = 100,
    rewardCoin = 12500,
    rewardGold = 0,
    rewardExp = 124685,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90926,
      talkId = 170322,
      param = 0,
      des = "向#<Y,>袁天罡#打听玄阴草的下落"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20073] = {
    mnName = "心魔",
    missionDes = "卷帘大将自从打碎琉璃盏被贬下凡间之后，就沓讯全无，这让他的好友双锤天将很担心。双锤天将希望你能去双叉岭代他探望老朋友，结果去之后你发现...",
    acceptDes = "0",
    needCmp = {20072},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 100,
    rewardCoin = 15600,
    rewardGold = 0,
    rewardExp = 155856,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 209,
      data = {16039, 4039},
      talkId = 170323,
      param = {
        {
          21011,
          1,
          100
        }
      },
      des = "打败#<Y,>夜叉王#取得玄阴草"
    },
    dst2 = {
      type = 402,
      data = 90926,
      talkId = 170324,
      param = {
        {21011, 1}
      },
      des = "将玄阴草交给#<Y,>袁天罡#"
    }
  },
  [20074] = {
    mnName = "心魔",
    missionDes = "卷帘大将自从打碎琉璃盏被贬下凡间之后，就沓讯全无，这让他的好友双锤天将很担心。双锤天将希望你能去双叉岭代他探望老朋友，结果去之后你发现...",
    acceptDes = "向#<Y,>袁天罡#取得心魔下落",
    needCmp = {20073},
    startNpc = 90926,
    acceptTalkId = 170325,
    zs = 0,
    lv = 100,
    rewardCoin = 15600,
    rewardGold = 0,
    rewardExp = 155856,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16040, 4040},
      talkId = 170326,
      param = 0,
      des = "去#<Y,>东海龙宫#消灭心魔"
    },
    dst2 = {
      type = 101,
      data = 95065,
      talkId = 170327,
      param = 0,
      des = "将所发生的事情告知#<Y,>卷帘大将#"
    }
  },
  [20075] = {
    mnName = "卷帘的委托",
    missionDes = "清醒后的卷帘告诉你，将打碎的琉璃盏碎片拼凑完整是他唯一的心愿。他希望你能帮他找回其他三块琉璃碎片，好让他有重回天宫为神的机会,根据菩萨指示，你决定帮助他。",
    acceptDes = "向#<Y,>卷帘#打听为何他面露难色",
    needCmp = {20074},
    startNpc = 95065,
    acceptTalkId = 170331,
    zs = 0,
    lv = 100,
    rewardCoin = 12500,
    rewardGold = 0,
    rewardExp = 124685,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90904,
      talkId = 170332,
      param = 0,
      des = "帮助卷帘向#<Y,>观音菩萨#求助"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20076] = {
    mnName = "卷帘的委托",
    missionDes = "清醒后的卷帘告诉你，将打碎的琉璃盏碎片拼凑完整是他唯一的心愿。他希望你能帮他找回其他三块琉璃碎片，好让他有重回天宫为神的机会,根据菩萨指示，你决定帮助他。",
    acceptDes = "0",
    needCmp = {20075},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 100,
    rewardCoin = 15600,
    rewardGold = 0,
    rewardExp = 155856,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 90904,
      talkId = 170333,
      param = {
        {21010, 1}
      },
      des = "继续与#<Y,>观音菩萨#交谈取得仙脂露"
    },
    dst2 = {
      type = 402,
      data = 95065,
      talkId = 170334,
      param = {
        {21010, 1}
      },
      des = "将仙脂露交给#<Y,>卷帘大将#"
    }
  },
  [20077] = {
    mnName = "第一块碎片",
    missionDes = "清醒后的卷帘告诉你，将打碎的琉璃盏碎片拼凑完整是他唯一的心愿。他希望你能帮他找回其他三块琉璃碎片，好让他有重回天宫为神的机会,根据菩萨指示，你决定帮助他。",
    acceptDes = "向#<Y,>卷帘#打听琉璃盏碎片的情况",
    needCmp = {20076},
    startNpc = 95065,
    acceptTalkId = 170341,
    zs = 0,
    lv = 100,
    rewardCoin = 12500,
    rewardGold = 0,
    rewardExp = 124685,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 95065,
      talkId = 170342,
      param = 0,
      des = "继续与#<Y,>卷帘大将#交谈"
    },
    dst2 = {
      type = 101,
      data = 90010,
      talkId = 170343,
      param = 0,
      des = "向#<Y,>龙王#打听琉璃碎片消息"
    }
  },
  [20078] = {
    mnName = "第一块碎片",
    missionDes = "清醒后的卷帘告诉你，将打碎的琉璃盏碎片拼凑完整是他唯一的心愿。他希望你能帮他找回其他三块琉璃碎片，好让他有重回天宫为神的机会,根据菩萨指示，你决定帮助他。",
    acceptDes = "去#<Y,>天宫#查探乌云的来源",
    needCmp = {20077},
    startNpc = 95066,
    acceptTalkId = 170344,
    zs = 0,
    lv = 100,
    rewardCoin = 15600,
    rewardGold = 0,
    rewardExp = 155856,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16041, 4041},
      talkId = 170345,
      param = 0,
      des = "驱散长安郊外的#<Y,>猎户#们"
    },
    dst2 = {
      type = 101,
      data = 95066,
      talkId = 170346,
      param = 0,
      des = "去天宫向#<Y,>青歌#复命"
    }
  },
  [20079] = {
    mnName = "第一块碎片",
    missionDes = "清醒后的卷帘告诉你，将打碎的琉璃盏碎片拼凑完整是他唯一的心愿。他希望你能帮他找回其他三块琉璃碎片，好让他有重回天宫为神的机会,根据菩萨指示，你决定帮助他。",
    acceptDes = "0",
    needCmp = {20078},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 100,
    rewardCoin = 15600,
    rewardGold = 0,
    rewardExp = 155856,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 90010,
      talkId = 170347,
      param = {
        {21063, 1}
      },
      des = "向#<Y,>龙王#复命"
    },
    dst2 = {
      type = 402,
      data = 95061,
      talkId = 170348,
      param = {
        {21063, 1}
      },
      des = "将碎片交给#<Y,>卷帘大将#"
    }
  },
  [20080] = {
    mnName = "丫环身世",
    missionDes = "清醒后的卷帘告诉你，将打碎的琉璃盏碎片拼凑完整是他唯一的心愿。他希望你能帮他找回其他三块琉璃碎片，好让他有重回天宫为神的机会,根据菩萨指示，你决定帮助他。",
    acceptDes = "前往长安城找到#<Y,>程府丫环#",
    needCmp = {20079},
    startNpc = 90927,
    acceptTalkId = 170351,
    zs = 0,
    lv = 100,
    rewardCoin = 12500,
    rewardGold = 0,
    rewardExp = 124685,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90927,
      talkId = 170352,
      param = 0,
      des = "继续与#<Y,>程府丫环#交谈"
    },
    dst2 = {
      type = 208,
      data = {16042, 4042},
      talkId = 170353,
      wftalkId = 170354,
      param = 0,
      des = "教训#<Y,>卷帘大将#"
    }
  },
  [20081] = {
    mnName = "丫环身世",
    missionDes = "清醒后的卷帘告诉你，将打碎的琉璃盏碎片拼凑完整是他唯一的心愿。他希望你能帮他找回其他三块琉璃碎片，好让他有重回天宫为神的机会,根据菩萨指示，你决定帮助他。",
    acceptDes = "0",
    needCmp = {20080},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 100,
    rewardCoin = 12500,
    rewardGold = 0,
    rewardExp = 124685,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 95061,
      talkId = 170355,
      param = 0,
      des = "与#<Y,>卷帘大#将对质"
    },
    dst2 = {
      type = 101,
      data = 90007,
      talkId = 170356,
      param = 0,
      des = "前往地府向#<Y,>钟馗#取证"
    }
  },
  [20082] = {
    mnName = "第二块碎片",
    missionDes = "清醒后的卷帘告诉你，将打碎的琉璃盏碎片拼凑完整是他唯一的心愿。他希望你能帮他找回其他三块琉璃碎片，好让他有重回天宫为神的机会,根据菩萨指示，你决定帮助他。",
    acceptDes = "将真相告诉#<Y,>程府丫环#",
    needCmp = {20081},
    startNpc = 90927,
    acceptTalkId = 170361,
    zs = 0,
    lv = 100,
    rewardCoin = 15600,
    rewardGold = 0,
    rewardExp = 155856,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16043, 4043},
      talkId = 170362,
      param = 0,
      des = "去城东逮捕凶手#<Y,>程丁#"
    },
    dst2 = {
      type = 101,
      data = 90921,
      talkId = 170363,
      param = 0,
      des = "将程丁交给长安#<Y,>衙役#"
    }
  },
  [20083] = {
    mnName = "第二块碎片",
    missionDes = "清醒后的卷帘告诉你，将打碎的琉璃盏碎片拼凑完整是他唯一的心愿。他希望你能帮他找回其他三块琉璃碎片，好让他有重回天宫为神的机会,根据菩萨指示，你决定帮助他。",
    acceptDes = "向#<Y,>程府丫环#复命",
    needCmp = {20082},
    startNpc = 90927,
    acceptTalkId = 170364,
    zs = 0,
    lv = 100,
    rewardCoin = 15600,
    rewardGold = 0,
    rewardExp = 155856,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 90927,
      talkId = 170365,
      param = {
        {21063, 1}
      },
      des = "与#<Y,>程府丫环#交谈取得碎片"
    },
    dst2 = {
      type = 402,
      data = 95061,
      talkId = 170366,
      param = {
        {21063, 1}
      },
      des = "将碎片带给#<Y,>卷帘大将#"
    }
  },
  [20084] = {
    mnName = "第二块碎片",
    missionDes = "清醒后的卷帘告诉你，将打碎的琉璃盏碎片拼凑完整是他唯一的心愿。他希望你能帮他找回其他三块琉璃碎片，好让他有重回天宫为神的机会,根据菩萨指示，你决定帮助他。",
    acceptDes = "0",
    needCmp = {20083},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 100,
    rewardCoin = 12500,
    rewardGold = 0,
    rewardExp = 124685,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 95061,
      talkId = 170367,
      param = 0,
      des = "安慰伤心的#<Y,>卷帘大将#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20085] = {
    mnName = "第三块碎片",
    missionDes = "清醒后的卷帘告诉你，将打碎的琉璃盏碎片拼凑完整是他唯一的心愿。他希望你能帮他找回其他三块琉璃碎片，好让他有重回天宫为神的机会,根据菩萨指示，你决定帮助他。",
    acceptDes = "找万事通#<Y,>袁天罡#想办法",
    needCmp = {20084},
    startNpc = 90926,
    acceptTalkId = 170371,
    zs = 0,
    lv = 100,
    rewardCoin = 12500,
    rewardGold = 0,
    rewardExp = 124685,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90928,
      talkId = 170372,
      param = 0,
      des = "向#<Y,>李鬼谷#打听碎片下落"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20086] = {
    mnName = "第三块碎片",
    missionDes = "清醒后的卷帘告诉你，将打碎的琉璃盏碎片拼凑完整是他唯一的心愿。他希望你能帮他找回其他三块琉璃碎片，好让他有重回天宫为神的机会,根据菩萨指示，你决定帮助他。",
    acceptDes = "0",
    needCmp = {20085},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 100,
    rewardCoin = 15600,
    rewardGold = 0,
    rewardExp = 155856,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 209,
      data = {16044, 4044},
      talkId = 170373,
      param = {
        {
          21063,
          1,
          100
        }
      },
      des = "从#<Y,>奔波儿灞#身上取得碎片"
    },
    dst2 = {
      type = 402,
      data = 95061,
      talkId = 170374,
      param = {
        {21063, 1}
      },
      des = "将碎片带给#<Y,>卷帘大将#"
    }
  },
  [20087] = {
    mnName = "第三块碎片",
    missionDes = "清醒后的卷帘告诉你，将打碎的琉璃盏碎片拼凑完整是他唯一的心愿。他希望你能帮他找回其他三块琉璃碎片，好让他有重回天宫为神的机会,根据菩萨指示，你决定帮助他。",
    acceptDes = "0",
    needCmp = {20086},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 100,
    rewardCoin = 15600,
    rewardGold = 0,
    rewardExp = 155856,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 209,
      data = {16045, 4045},
      talkId = 170375,
      param = {
        {
          21052,
          1,
          100
        }
      },
      des = "从#<Y,>莲花童子#身上取得无根之水"
    },
    dst2 = {
      type = 402,
      data = 95061,
      talkId = 170376,
      param = {
        {21052, 1}
      },
      des = "将无根之水带给#<Y,>卷帘大将#"
    }
  },
  [20088] = {
    mnName = "阪依",
    missionDes = "清醒后的卷帘告诉你，将打碎的琉璃盏碎片拼凑完整是他唯一的心愿。他希望你能帮他找回其他三块琉璃碎片，好让他有重回天宫为神的机会,根据菩萨指示，你决定帮助他。",
    acceptDes = "#<Y,>卷帘大将#有事拜托你",
    needCmp = {20087},
    startNpc = 95061,
    acceptTalkId = 170381,
    zs = 0,
    lv = 100,
    rewardCoin = 12500,
    rewardGold = 0,
    rewardExp = 124685,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90009,
      talkId = 170382,
      param = 0,
      des = "询问#<Y,>玉皇大帝#卷帘是否可以回归仙界"
    },
    dst2 = {
      type = 101,
      data = 90904,
      talkId = 170383,
      param = 0,
      des = "找#<Y,>观音菩萨#评理"
    }
  },
  [20089] = {
    mnName = "阪依",
    missionDes = "清醒后的卷帘告诉你，将打碎的琉璃盏碎片拼凑完整是他唯一的心愿。他希望你能帮他找回其他三块琉璃碎片，好让他有重回天宫为神的机会,根据菩萨指示，你决定帮助他。",
    acceptDes = "0",
    needCmp = {20088},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 0,
    lv = 100,
    rewardCoin = 12500,
    rewardGold = 0,
    rewardExp = 124685,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 95061,
      talkId = 170384,
      param = 0,
      des = "向#<Y,>卷帘大将#复命"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20090] = {
    mnName = "迷失的小生",
    missionDes = "枪兵统领告诉你城内宋家子弟宋小生与邪魔勾结，而目击者就是酒馆老板。枪兵统领希望你能查清此事。",
    acceptDes = "#<Y,>枪兵统领#有事找你",
    needCmp = {20089},
    startNpc = 95028,
    acceptTalkId = 170391,
    zs = 1,
    lv = 102,
    rewardCoin = 13100,
    rewardGold = 0,
    rewardExp = 130766,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90915,
      talkId = 170392,
      param = 0,
      des = "向#<Y,>酒馆老板#打听看他知道些什么"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20091] = {
    mnName = "迷失的小生",
    missionDes = "枪兵统领告诉你城内宋家子弟宋小生与邪魔勾结，而目击者就是酒馆老板。枪兵统领希望你能查清此事。",
    acceptDes = "0",
    needCmp = {20090},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 102,
    rewardCoin = 16300,
    rewardGold = 0,
    rewardExp = 163458,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 209,
      data = {16046, 4046},
      talkId = 170393,
      param = {
        {
          21007,
          1,
          100
        }
      },
      des = "从#<Y,>宋小生#身上夺取包裹"
    },
    dst2 = {
      type = 402,
      data = 95028,
      talkId = 170394,
      param = {
        {21007, 1}
      },
      des = "将得到的包裹交给#<Y,>枪兵统领#"
    }
  },
  [20092] = {
    mnName = "迷失的小生",
    missionDes = "枪兵统领告诉你城内宋家子弟宋小生与邪魔勾结，而目击者就是酒馆老板。枪兵统领希望你能查清此事。",
    acceptDes = "0",
    needCmp = {20091},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 102,
    rewardCoin = 13100,
    rewardGold = 0,
    rewardExp = 130766,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 95018,
      talkId = 170395,
      param = 0,
      des = "探望#<Y,>宋小生#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20093] = {
    mnName = "引魂妖",
    missionDes = "枪兵统领告诉你城内宋家子弟宋小生与邪魔勾结，而目击者就是酒馆老板。枪兵统领希望你能查清此事。",
    acceptDes = "向#<Y,>宋小生#打听引魂果的来处",
    needCmp = {20092},
    startNpc = 95018,
    acceptTalkId = 170396,
    zs = 1,
    lv = 102,
    rewardCoin = 16300,
    rewardGold = 0,
    rewardExp = 163458,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16047, 4047},
      talkId = 170397,
      param = 0,
      des = "消灭#<Y,>长安郊外#桃树下的妖怪"
    },
    dst2 = {
      type = 101,
      data = 95028,
      talkId = 170398,
      param = 0,
      des = "向#<Y,>枪兵统领#复命"
    }
  },
  [20094] = {
    mnName = "刑天宝斧",
    missionDes = "在天庭闲逛的你被一阵唠叨吵得头晕脑胀，原来是大力神灵把行刑需要的刑天宝斧丢失了。帮助这个白痴神仙找回宝斧...",
    acceptDes = "#<Y,>丁力天王#有事找你",
    needCmp = {20093},
    startNpc = 91003,
    acceptTalkId = 170401,
    zs = 1,
    lv = 105,
    rewardCoin = 14000,
    rewardGold = 0,
    rewardExp = 140404,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 95073,
      talkId = 170402,
      param = 0,
      des = "安慰受伤的#<Y,>小白#"
    },
    dst2 = {
      type = 101,
      data = 90908,
      talkId = 170403,
      param = 0,
      des = "找#<Y,>杂货商#购买肉干"
    }
  },
  [20095] = {
    mnName = "刑天宝斧",
    missionDes = "在天庭闲逛的你被一阵唠叨吵得头晕脑胀，原来是大力神灵把行刑需要的刑天宝斧丢失了。帮助这个白痴神仙找回宝斧...",
    acceptDes = "0",
    needCmp = {20094},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 105,
    rewardCoin = 17600,
    rewardGold = 0,
    rewardExp = 175505,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16048, 4048},
      talkId = 0,
      param = 0,
      des = "去留香阁消灭#<Y,>十三太保#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20096] = {
    mnName = "刑天宝斧",
    missionDes = "在天庭闲逛的你被一阵唠叨吵得头晕脑胀，原来是大力神灵把行刑需要的刑天宝斧丢失了。帮助这个白痴神仙找回宝斧...",
    acceptDes = "0",
    needCmp = {20095},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 105,
    rewardCoin = 17600,
    rewardGold = 0,
    rewardExp = 175505,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 90908,
      talkId = 170405,
      param = {
        {21065, 1}
      },
      des = "向#<Y,>杂货商#复命"
    },
    dst2 = {
      type = 402,
      data = 95073,
      talkId = 170406,
      param = {
        {21065, 1}
      },
      des = "将肉干带给#<Y,>小白#"
    }
  },
  [20097] = {
    mnName = "刑天宝斧",
    missionDes = "在天庭闲逛的你被一阵唠叨吵得头晕脑胀，原来是大力神灵把行刑需要的刑天宝斧丢失了。帮助这个白痴神仙找回宝斧...",
    acceptDes = "0",
    needCmp = {20096},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 105,
    rewardCoin = 17600,
    rewardGold = 0,
    rewardExp = 175505,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 95073,
      talkId = 170407,
      param = {
        {21066, 1}
      },
      des = "与#<Y,>小白#交谈取得刑天宝斧"
    },
    dst2 = {
      type = 402,
      data = 91003,
      talkId = 170408,
      param = {
        {21066, 1}
      },
      des = "将宝斧带给#<Y,>丁力天王#"
    }
  },
  [20098] = {
    mnName = "罪人",
    missionDes = "到天牢探监时你却发现小白龙已经越狱逃跑，去向不明。终于你在东海渔村找到惶恐的小白龙，一番交谈后，你决定帮他伸冤。",
    acceptDes = "向#<Y,>丁力天王#打听罪人是谁",
    needCmp = {20097},
    startNpc = 91003,
    acceptTalkId = 170411,
    zs = 1,
    lv = 105,
    rewardCoin = 17600,
    rewardGold = 0,
    rewardExp = 175505,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 91003,
      talkId = 170412,
      param = {
        {21067, 1}
      },
      des = "取得#<Y,>琼酿玉液#"
    },
    dst2 = {
      type = 402,
      data = 95074,
      talkId = 170413,
      param = {
        {21067, 1}
      },
      des = "将仙酒送给被禁锢的#<Y,>小白龙#"
    }
  },
  [20099] = {
    mnName = "罪人",
    missionDes = "到天牢探监时你却发现小白龙已经越狱逃跑，去向不明。终于你在东海渔村找到惶恐的小白龙，一番交谈后，你决定帮他伸冤。",
    acceptDes = "0",
    needCmp = {20098},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 105,
    rewardCoin = 14000,
    rewardGold = 0,
    rewardExp = 140404,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 95074,
      talkId = 170414,
      param = 0,
      des = "向#<Y,>小白龙#打听他所犯之事"
    },
    dst2 = {
      type = 101,
      data = 91003,
      talkId = 170415,
      param = 0,
      des = "向天王汇报#<Y,>小白龙#逃逸之事"
    }
  },
  [20100] = {
    mnName = "罪人",
    missionDes = "到天牢探监时你却发现小白龙已经越狱逃跑，去向不明。终于你在东海渔村找到惶恐的小白龙，一番交谈后，你决定帮他伸冤。",
    acceptDes = "0",
    needCmp = {20099},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 105,
    rewardCoin = 17600,
    rewardGold = 0,
    rewardExp = 175505,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16049, 4049},
      talkId = 170416,
      param = 0,
      des = "打败阻拦的#<Y,>四海龙女#"
    },
    dst2 = {
      type = 208,
      data = {16050, 4050},
      talkId = 170417,
      param = 0,
      des = "打败阻拦的大太子#<Y,>敖摩昂#"
    }
  },
  [20101] = {
    mnName = "罪人",
    missionDes = "到天牢探监时你却发现小白龙已经越狱逃跑，去向不明。终于你在东海渔村找到惶恐的小白龙，一番交谈后，你决定帮他伸冤。",
    acceptDes = "0",
    needCmp = {20100},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 105,
    rewardCoin = 14000,
    rewardGold = 0,
    rewardExp = 140404,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 95075,
      talkId = 170418,
      param = 0,
      des = "劝解大太子#<Y,>敖摩昂#"
    },
    dst2 = {
      type = 101,
      data = 95076,
      talkId = 170419,
      param = 0,
      des = "去渔村找到#<Y,>小白龙#"
    }
  },
  [20102] = {
    mnName = "冤屈",
    missionDes = "到天牢探监时你却发现小白龙已经越狱逃跑，去向不明。终于你在东海渔村找到惶恐的小白龙，一番交谈后，你决定帮他伸冤。",
    acceptDes = "将你的想法告诉#<Y,>丁力天王#",
    needCmp = {20101},
    startNpc = 91003,
    acceptTalkId = 170421,
    zs = 1,
    lv = 105,
    rewardCoin = 14000,
    rewardGold = 0,
    rewardExp = 140404,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90904,
      talkId = 170422,
      param = 0,
      des = "向#<Y,>观音菩萨#求助"
    },
    dst2 = {
      type = 101,
      data = 95077,
      talkId = 170423,
      param = 0,
      des = "去长安城找到#<Y,>万圣公主#"
    }
  },
  [20103] = {
    mnName = "冤屈",
    missionDes = "到天牢探监时你却发现小白龙已经越狱逃跑，去向不明。终于你在东海渔村找到惶恐的小白龙，一番交谈后，你决定帮他伸冤。",
    acceptDes = "0",
    needCmp = {20102},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 105,
    rewardCoin = 17600,
    rewardGold = 0,
    rewardExp = 175505,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 209,
      data = {16051, 4051},
      talkId = 0,
      param = {
        {
          21009,
          1,
          100
        }
      },
      des = "从#<Y,>灞波儿奔#手中夺取乌草"
    },
    dst2 = {
      type = 402,
      data = 95077,
      talkId = 170424,
      param = {
        {21009, 1}
      },
      des = "将乌草交给#<Y,>万圣公主#"
    }
  },
  [20104] = {
    mnName = "白龙归位",
    missionDes = "到天牢探监时你却发现小白龙已经越狱逃跑，去向不明。终于你在东海渔村找到惶恐的小白龙，一番交谈后，你决定帮他伸冤。",
    acceptDes = "找#<Y,>万圣公主#打听宝珠下落",
    needCmp = {20103},
    startNpc = 95077,
    acceptTalkId = 170431,
    zs = 1,
    lv = 105,
    rewardCoin = 17600,
    rewardGold = 0,
    rewardExp = 175505,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 209,
      data = {16052, 4052},
      talkId = 0,
      param = {
        {
          21069,
          1,
          100
        }
      },
      des = "夺取#<Y,>圣灵宝珠#"
    },
    dst2 = {
      type = 402,
      data = 90009,
      talkId = 170432,
      param = {
        {21069, 1}
      },
      des = "将宝珠交给#<Y,>玉帝#"
    }
  },
  [20105] = {
    mnName = "白龙归位",
    missionDes = "到天牢探监时你却发现小白龙已经越狱逃跑，去向不明。终于你在东海渔村找到惶恐的小白龙，一番交谈后，你决定帮他伸冤。",
    acceptDes = "0",
    needCmp = {20104},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 105,
    rewardCoin = 14000,
    rewardGold = 0,
    rewardExp = 140404,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90904,
      talkId = 170433,
      param = 0,
      des = "向#<Y,>观音菩萨#求助"
    },
    dst2 = {
      type = 101,
      data = 95074,
      talkId = 170434,
      param = 0,
      des = "向#<Y,>小白龙#复命"
    }
  },
  [20106] = {
    mnName = "祸乱墨村",
    missionDes = "自私自利的长生教教众们为了强占墨村后山的茶林，不惜放火烧毁整片山林。墨村村长为保村民们的财产不受损失，需要你帮忙扼制这些凶恶之徒。",
    acceptDes = "#<Y,>墨村村长#需要你的帮忙",
    needCmp = {20105},
    startNpc = 90922,
    acceptTalkId = 170441,
    zs = 1,
    lv = 107,
    rewardCoin = 18400,
    rewardGold = 0,
    rewardExp = 183988,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16053, 4053},
      talkId = 0,
      param = 0,
      des = "去后山消灭#<Y,>纵火者#"
    },
    dst2 = {
      type = 101,
      data = 90922,
      talkId = 170442,
      param = 0,
      des = "向#<Y,>墨老#复命"
    }
  },
  [20107] = {
    mnName = "祸乱墨村",
    missionDes = "自私自利的长生教教众们为了强占墨村后山的茶林，不惜放火烧毁整片山林。墨村村长为保村民们的财产不受损失，需要你帮忙扼制这些凶恶之徒。",
    acceptDes = "0",
    needCmp = {20106},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 107,
    rewardCoin = 14700,
    rewardGold = 0,
    rewardExp = 147191,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90922,
      talkId = 170443,
      param = 0,
      des = "向#<Y,>墨老#打听幕后主使是谁"
    },
    dst2 = {
      type = 208,
      data = {16054, 4054},
      talkId = 0,
      wftalkId = 170444,
      param = 0,
      des = "消灭主谋#<Y,>天尊道人#"
    }
  },
  [20108] = {
    mnName = "祸乱墨村",
    missionDes = "自私自利的长生教教众们为了强占墨村后山的茶林，不惜放火烧毁整片山林。墨村村长为保村民们的财产不受损失，需要你帮忙扼制这些凶恶之徒。",
    acceptDes = "0",
    needCmp = {20107},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 107,
    rewardCoin = 14700,
    rewardGold = 0,
    rewardExp = 147191,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90921,
      talkId = 170445,
      param = 0,
      des = "将#<Y,>道人#押至官府"
    },
    dst2 = {
      type = 101,
      data = 90922,
      talkId = 170446,
      param = 0,
      des = "向#<Y,>墨老#复命"
    }
  },
  [20109] = {
    mnName = "魇",
    missionDes = "惨遭横祸致死的杜大生因为无法进入轮回一直在人间到处游荡，他希望你能帮他找出无法轮回的原因。",
    acceptDes = "#<Y,>天佑奶奶#有事找你",
    needCmp = {20108},
    startNpc = 95010,
    acceptTalkId = 170451,
    zs = 1,
    lv = 109,
    rewardCoin = 19300,
    rewardGold = 0,
    rewardExp = 192852,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16055, 4055},
      talkId = 0,
      param = 0,
      des = "打败恶鬼#<Y,>杜大生#"
    },
    dst2 = {
      type = 101,
      data = 95078,
      talkId = 170452,
      param = 0,
      des = "质问#<Y,>杜大生#为何留恋人间"
    }
  },
  [20110] = {
    mnName = "魇",
    missionDes = "惨遭横祸致死的杜大生因为无法进入轮回一直在人间到处游荡，他希望你能帮他找出无法轮回的原因。",
    acceptDes = "0",
    needCmp = {20109},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 109,
    rewardCoin = 15400,
    rewardGold = 0,
    rewardExp = 154281,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 95078,
      talkId = 170453,
      param = 0,
      des = "继续与#<Y,>杜大生#交谈"
    },
    dst2 = {
      type = 101,
      data = 90916,
      talkId = 170454,
      param = 0,
      des = "向鬼将打听#<Y,>杜大生#的事情"
    }
  },
  [20111] = {
    mnName = "魇",
    missionDes = "惨遭横祸致死的杜大生因为无法进入轮回一直在人间到处游荡，他希望你能帮他找出无法轮回的原因。",
    acceptDes = "0",
    needCmp = {20110},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 109,
    rewardCoin = 15400,
    rewardGold = 0,
    rewardExp = 154281,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90007,
      talkId = 170455,
      param = 0,
      des = "向钟馗打听#<Y,>杜大生#的事情"
    },
    dst2 = {
      type = 101,
      data = 95078,
      talkId = 170456,
      param = 0,
      des = "告知#<Y,>杜大生#事因"
    }
  },
  [20112] = {
    mnName = "魇",
    missionDes = "惨遭横祸致死的杜大生因为无法进入轮回一直在人间到处游荡，他希望你能帮他找出无法轮回的原因。",
    acceptDes = "0",
    needCmp = {20111},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 109,
    rewardCoin = 19300,
    rewardGold = 0,
    rewardExp = 192852,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16056, 4056},
      talkId = 0,
      param = 0,
      des = "去妖怪洞穴消灭#<Y,>魇#"
    },
    dst2 = {
      type = 101,
      data = 95078,
      talkId = 170457,
      param = 0,
      des = "向#<Y,>杜大生#复命"
    }
  },
  [20113] = {
    mnName = "新的配方",
    missionDes = "酒馆老板最近不断的在尝试改良女儿红酿酒配方，他需要一颗千年珍珠作为铺料。由于此珠长安城并无售卖，酒馆老板希望你能帮他找到一颗珍珠。",
    acceptDes = "#<Y,>酒馆老板#需要你的帮助",
    needCmp = {20112},
    startNpc = 90915,
    acceptTalkId = 170461,
    zs = 1,
    lv = 110,
    rewardCoin = 19700,
    rewardGold = 0,
    rewardExp = 197431,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 209,
      data = {16057, 4057},
      talkId = 0,
      param = {
        {
          21014,
          1,
          100
        }
      },
      des = "从#<Y,>千年蚌精#手中取得珍珠"
    },
    dst2 = {
      type = 402,
      data = 90915,
      talkId = 170462,
      param = {
        {21014, 1}
      },
      des = "将珍珠带给#<Y,>酒馆老板#"
    }
  },
  [20114] = {
    mnName = "新的配方",
    missionDes = "酒馆老板最近不断的在尝试改良女儿红酿酒配方，他需要一颗千年珍珠作为铺料。由于此珠长安城并无售卖，酒馆老板希望你能帮他找到一颗珍珠。",
    acceptDes = "0",
    needCmp = {20113},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 110,
    rewardCoin = 15800,
    rewardGold = 0,
    rewardExp = 157944,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90915,
      talkId = 170463,
      param = 0,
      des = "品尝#<Y,>酒馆老板#新酿的美酒"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20115] = {
    mnName = "复仇",
    missionDes = "枪兵统领的弟弟在一次抓捕长生教教徒的行动中不慎惨遭埋伏，命丧火焰山。枪兵统领希望你能帮他报此杀弟之仇。",
    acceptDes = "听听#<Y,>枪兵统领#说些什么",
    needCmp = {20114},
    startNpc = 95028,
    acceptTalkId = 170471,
    zs = 1,
    lv = 111,
    rewardCoin = 20200,
    rewardGold = 0,
    rewardExp = 202111,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16058, 4058},
      talkId = 0,
      param = 0,
      des = "去火焰山消灭#<Y,>三清尊者#"
    },
    dst2 = {
      type = 101,
      data = 95028,
      talkId = 170472,
      param = 0,
      des = "向#<Y,>枪兵统领#复命"
    }
  },
  [20116] = {
    mnName = "传家宝剑",
    missionDes = "不怕贼偷，就怕贼惦记！刚出山的申魁公子来到长安城后四处炫耀他那把家传宝剑，结果被别人偷去..着急的申魁公子希望你能帮他寻回宝剑。",
    acceptDes = "#<Y,>申魁公子#需要你帮他找回宝剑",
    needCmp = {20115},
    startNpc = 95080,
    acceptTalkId = 170481,
    zs = 1,
    lv = 113,
    rewardCoin = 16900,
    rewardGold = 0,
    rewardExp = 169428,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90921,
      talkId = 170482,
      param = 0,
      des = "向#<Y,>衙役#打听附近可有偷儿"
    },
    dst2 = {
      type = 208,
      data = {16059, 4059},
      talkId = 0,
      param = 0,
      des = "去郊外找到#<Y,>留一手#"
    }
  },
  [20117] = {
    mnName = "传家宝剑",
    missionDes = "不怕贼偷，就怕贼惦记！刚出山的申魁公子来到长安城后四处炫耀他那把家传宝剑，结果被别人偷去..着急的申魁公子希望你能帮他寻回宝剑。",
    acceptDes = "0",
    needCmp = {20116},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 113,
    rewardCoin = 21200,
    rewardGold = 0,
    rewardExp = 211785,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 95094,
      talkId = 170484,
      param = {
        {21071, 1}
      },
      des = "向#<Y,>留一手#索要宝剑"
    },
    dst2 = {
      type = 402,
      data = 95080,
      talkId = 170485,
      param = {},
      des = "将宝剑交还#<Y,>申魁公子#"
    }
  },
  [20118] = {
    mnName = "污染之源",
    missionDes = "骆家庄的井水被堵死啦！李家公为了全村人的饮水，只身前往映月泉，结果发现映月泉早已是蝎子的天堂。着急的李家公找到你，希望你能帮助骆家庄解除这个难关。",
    acceptDes = "#<Y,>李家公#有事找你",
    needCmp = {20117},
    startNpc = 90991,
    acceptTalkId = 170491,
    zs = 1,
    lv = 115,
    rewardCoin = 22200,
    rewardGold = 0,
    rewardExp = 221891,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16060, 4060},
      talkId = 0,
      param = 0,
      des = "捣毁#<Y,>蝎巢#"
    },
    dst2 = {
      type = 101,
      data = 95095,
      talkId = 170492,
      param = 0,
      des = "劝退#<Y,>蝎群#"
    }
  },
  [20119] = {
    mnName = "污染之源",
    missionDes = "骆家庄的井水被堵死啦！李家公为了全村人的饮水，只身前往映月泉，结果发现映月泉早已是蝎子的天堂。着急的李家公找到你，希望你能帮助骆家庄解除这个难关。",
    acceptDes = "0",
    needCmp = {20118},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 115,
    rewardCoin = 22200,
    rewardGold = 0,
    rewardExp = 221891,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16061, 4061},
      talkId = 0,
      param = 0,
      des = "去火焰山消灭#<Y,>独眼怪#"
    },
    dst2 = {
      type = 101,
      data = 95095,
      talkId = 170493,
      param = 0,
      des = "向#<Y,>蝎王#复命"
    }
  },
  [20120] = {
    mnName = "污染之源",
    missionDes = "骆家庄的井水被堵死啦！李家公为了全村人的饮水，只身前往映月泉，结果发现映月泉早已是蝎子的天堂。着急的李家公找到你，希望你能帮助骆家庄解除这个难关。",
    acceptDes = "0",
    needCmp = {20119},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 115,
    rewardCoin = 17800,
    rewardGold = 0,
    rewardExp = 177513,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90991,
      talkId = 170494,
      param = 0,
      des = "告知#<Y,>李家公#蝎群已撤的消息"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20121] = {
    mnName = "聚魄珠",
    missionDes = "渔村的李婶希望你能代她去叫在渔村口玩耍的小虎子回家吃饭...",
    acceptDes = "#<Y,>李婶#有急事找你",
    needCmp = {20120},
    startNpc = 90932,
    acceptTalkId = 170501,
    zs = 1,
    lv = 117,
    rewardCoin = 18600,
    rewardGold = 0,
    rewardExp = 185959,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 95081,
      talkId = 170502,
      param = 0,
      des = "找到#<Y,>虎儿#"
    },
    dst2 = {
      type = 208,
      data = {16062, 4062},
      talkId = 170503,
      param = 0,
      des = "消灭郊外出现的#<Y,>千年巨鳄#"
    }
  },
  [20122] = {
    mnName = "聚魄珠",
    missionDes = "渔村的李婶希望你能代她去叫在渔村口玩耍的小虎子回家吃饭...",
    acceptDes = "0",
    needCmp = {20121},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 117,
    rewardCoin = 18600,
    rewardGold = 0,
    rewardExp = 185959,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 95096,
      talkId = 170504,
      param = 0,
      des = "与突然出现的#<Y,>霄雷幻蛇#交谈"
    },
    dst2 = {
      type = 208,
      data = {16063, 4063},
      talkId = 0,
      wftalkId = 170505,
      param = 0,
      des = "打败#<Y,>霄雷幻蛇#"
    }
  },
  [20123] = {
    mnName = "聚魄珠",
    missionDes = "渔村的李婶希望你能代她去叫在渔村口玩耍的小虎子回家吃饭...",
    acceptDes = "0",
    needCmp = {20122},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 117,
    rewardCoin = 23200,
    rewardGold = 0,
    rewardExp = 232448,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 95096,
      talkId = 170506,
      param = {
        {21072, 1}
      },
      des = "与#<Y,>霄雷幻蛇#交谈，取得灵珠"
    },
    dst2 = {
      type = 402,
      data = 90907,
      talkId = 170507,
      param = {
        {21072, 1}
      },
      des = "将灵珠交给#<Y,>紫霞仙子#辨认"
    }
  },
  [20124] = {
    mnName = "皇城失窃",
    missionDes = "上个月，有三名高手闯入皇宫大内，盗走了圣上珍藏的几幅名画，此事令圣上龙颜大怒。衙役希望你能帮他追回被偷的字画。",
    acceptDes = "与#<Y,>衙役#谈谈传闻的皇城失窃案",
    needCmp = {20123},
    startNpc = 90921,
    acceptTalkId = 170511,
    zs = 1,
    lv = 118,
    rewardCoin = 23800,
    rewardGold = 0,
    rewardExp = 237902,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 209,
      data = {16064, 4064},
      talkId = 0,
      param = {
        {
          21073,
          1,
          100
        }
      },
      des = "消灭#<Y,>护法#夺回字画"
    },
    dst2 = {
      type = 402,
      data = 90921,
      talkId = 170512,
      param = {
        {21073, 1}
      },
      des = "将游春图交给#<Y,>衙役#"
    }
  },
  [20125] = {
    mnName = "衙役的烦恼",
    missionDes = "捕头不是那么好当的！为了当个好捕头，一个称职的捕头，衙役可是卯足了劲...",
    acceptDes = "听听#<Y,>衙役#说些什么",
    needCmp = {20124},
    startNpc = 90921,
    acceptTalkId = 170521,
    zs = 1,
    lv = 119,
    rewardCoin = 19500,
    rewardGold = 0,
    rewardExp = 194781,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90915,
      talkId = 170522,
      param = 0,
      des = "向#<Y,>酒馆老板#取经"
    },
    dst2 = {
      type = 101,
      data = 90915,
      talkId = 170523,
      param = 0,
      des = "继续向#<Y,>酒馆老板#取经"
    }
  },
  [20126] = {
    mnName = "衙役的烦恼",
    missionDes = "捕头不是那么好当的！为了当个好捕头，一个称职的捕头，衙役可是卯足了劲...",
    acceptDes = "0",
    needCmp = {20125},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 119,
    rewardCoin = 19500,
    rewardGold = 0,
    rewardExp = 194781,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90921,
      talkId = 170524,
      param = 0,
      des = "将秘诀告知#<Y,>衙役#"
    },
    dst2 = {
      type = 208,
      data = {16065, 4065},
      talkId = 0,
      param = 0,
      des = "去方寸山消灭#<Y,>长生教教徒#"
    }
  },
  [20127] = {
    mnName = "衙役的烦恼",
    missionDes = "捕头不是那么好当的！为了当个好捕头，一个称职的捕头，衙役可是卯足了劲...",
    acceptDes = "0",
    needCmp = {20126},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 1,
    lv = 119,
    rewardCoin = 19500,
    rewardGold = 0,
    rewardExp = 194781,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90921,
      talkId = 170525,
      param = 0,
      des = "告诉#<Y,>衙役#什么叫做煞气"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20128] = {
    mnName = "亡羊补牢",
    missionDes = "为了封闭人间与地府的通道，先天道人将渔村改造成了一个巨型阵法。随着时间的变化，封印力量也慢慢削弱,直到...",
    acceptDes = "#<Y,>袁天罡#有事找你",
    needCmp = {20127},
    startNpc = 90926,
    acceptTalkId = 170531,
    zs = 2,
    lv = 121,
    rewardCoin = 20400,
    rewardGold = 0,
    rewardExp = 203997,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90926,
      talkId = 170532,
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
  [20129] = {
    mnName = "亡羊补牢",
    missionDes = "为了封闭人间与地府的通道，先天道人将渔村改造成了一个巨型阵法。随着时间的变化，封印力量也慢慢削弱,直到...",
    acceptDes = "0",
    needCmp = {20128},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 121,
    rewardCoin = 25500,
    rewardGold = 0,
    rewardExp = 254997,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16066, 4066},
      talkId = 0,
      param = 0,
      des = "去渔村消灭#<Y,>恶鬼#"
    },
    dst2 = {
      type = 101,
      data = 90926,
      talkId = 170533,
      param = 0,
      des = "告知#<Y,>袁天罡#恶鬼已灭的消息"
    }
  },
  [20130] = {
    mnName = "噬魂阵",
    missionDes = "渔村的封印被人为地触动了，并布下邪阵欲催生邪尸魃，事态紧急，赶紧向李鬼谷寻求帮助。",
    acceptDes = "#<Y,>袁天罡#好像想起些事情",
    needCmp = {20129},
    startNpc = 90926,
    acceptTalkId = 170541,
    zs = 2,
    lv = 122,
    rewardCoin = 20900,
    rewardGold = 0,
    rewardExp = 208758,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90928,
      talkId = 170542,
      param = 0,
      des = "向#<Y,>李鬼谷#寻求帮助"
    },
    dst2 = {
      type = 101,
      data = 90928,
      talkId = 170543,
      param = 0,
      des = "继续与#<Y,>李鬼谷#对话"
    }
  },
  [20131] = {
    mnName = "噬魂阵",
    missionDes = "渔村的封印被人为地触动了，并布下邪阵欲催生邪尸魃，事态紧急，赶紧向李鬼谷寻求帮助。",
    acceptDes = "0",
    needCmp = {20130},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 122,
    rewardCoin = 26100,
    rewardGold = 0,
    rewardExp = 260948,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 209,
      data = {16067, 4067},
      talkId = 0,
      param = {
        {
          21074,
          1,
          100
        }
      },
      des = "去地府夺取#<Y,>魃#眉心中的魔种"
    },
    dst2 = {
      type = 402,
      data = 90928,
      talkId = 170544,
      param = {},
      des = "将魔种带给#<Y,>李鬼谷#"
    }
  },
  [20132] = {
    mnName = "衙役的奖赏",
    missionDes = "有商家投诉双叉岭最近出现一伙山贼，专以打劫路过的商队。至此已有多家商队遭受了波及。衙役希望你能为民除害，去双叉岭将此等罪恶之徒绳之于法。",
    acceptDes = "听听#<Y,>衙役#说些什么",
    needCmp = {20131},
    startNpc = 90921,
    acceptTalkId = 170551,
    zs = 2,
    lv = 123,
    rewardCoin = 26700,
    rewardGold = 0,
    rewardExp = 267030,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16068, 4068},
      talkId = 0,
      param = 0,
      des = "去双叉岭消灭#<Y,>土匪#"
    },
    dst2 = {
      type = 101,
      data = 90921,
      talkId = 170552,
      param = 0,
      des = "向#<Y,>衙役#复命"
    }
  },
  [20133] = {
    mnName = "黑水玄蛇",
    missionDes = "魔王寨近日风云幻化，被阵阵氤氲妖气层层笼罩在其中，似有大妖衍生...妖王的诞生对不了禅师产生了威胁。不了禅师希望你能替他消灭此妖。",
    acceptDes = "#<Y,>不了禅师#有事找你",
    needCmp = {20132},
    startNpc = 90933,
    acceptTalkId = 170561,
    zs = 2,
    lv = 125,
    rewardCoin = 28000,
    rewardGold = 0,
    rewardExp = 279599,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16069, 4069},
      talkId = 0,
      param = 0,
      des = "消灭#<Y,>黑水玄蛇#"
    },
    dst2 = {
      type = 101,
      data = 90933,
      talkId = 170562,
      param = 0,
      des = "告知#<Y,>不了禅师#玄蛇已灭的消息"
    }
  },
  [20134] = {
    mnName = "农夫之托",
    missionDes = "东海渔村的农夫在采摘珍珠时不慎打扰了正在修炼的千年蚌精，突然出现的妖怪将农夫吓的半死。为了之后的安全着想，农夫希望你能帮他将此妖铲除。",
    acceptDes = "与渔村#<Y,>农夫#交谈",
    needCmp = {20133},
    startNpc = 95082,
    acceptTalkId = 170571,
    zs = 2,
    lv = 126,
    rewardCoin = 28600,
    rewardGold = 0,
    rewardExp = 286092,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16070, 4070},
      talkId = 0,
      param = 0,
      des = "帮助农夫消灭#<Y,>蚌精#"
    },
    dst2 = {
      type = 101,
      data = 95082,
      talkId = 170572,
      param = 0,
      des = "向#<Y,>农夫#复命"
    }
  },
  [20135] = {
    mnName = "血魄妖晶",
    missionDes = "李婶的孩子虎儿得了一种怪病，白天他长睡不行，夜晚大哭至天亮，看了好多大夫都不行，这可把李婶给急坏了...",
    acceptDes = "#<Y,>李婶#需要你的帮助",
    needCmp = {20134},
    startNpc = 90932,
    acceptTalkId = 170581,
    zs = 2,
    lv = 128,
    rewardCoin = 24000,
    rewardGold = 0,
    rewardExp = 239607,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90926,
      talkId = 170582,
      param = 0,
      des = "请袁天罡为#<Y,>虎儿#治病"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20136] = {
    mnName = "血魄妖晶",
    missionDes = "李婶的孩子虎儿得了一种怪病，白天他长睡不行，夜晚大哭至天亮，看了好多大夫都不行，这可把李婶给急坏了...",
    acceptDes = "0",
    needCmp = {20135},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 128,
    rewardCoin = 30000,
    rewardGold = 0,
    rewardExp = 299509,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 209,
      data = {16071, 4071},
      talkId = 0,
      param = {
        {
          21075,
          1,
          100
        }
      },
      des = "去渔村消灭#<Y,>血魄女妖#"
    },
    dst2 = {
      type = 402,
      data = 90926,
      talkId = 170583,
      param = {
        {21075, 1}
      },
      des = "向#<Y,>袁天罡#打听妖晶"
    }
  },
  [20137] = {
    mnName = "血魄妖晶",
    missionDes = "李婶的孩子虎儿得了一种怪病，白天他长睡不行，夜晚大哭至天亮，看了好多大夫都不行，这可把李婶给急坏了...",
    acceptDes = "0",
    needCmp = {20136},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 128,
    rewardCoin = 30000,
    rewardGold = 0,
    rewardExp = 299509,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 90926,
      talkId = 170584,
      param = {
        {21075, 1}
      },
      des = "继续与#<Y,>袁天罡#交谈取得的血魄妖晶"
    },
    dst2 = {
      type = 402,
      data = 90932,
      talkId = 170585,
      param = {
        {21075, 1}
      },
      des = "将血魄晶交给#<Y,>李婶#"
    }
  },
  [20138] = {
    mnName = "顽熊偷茶",
    missionDes = "李鬼谷酷爱名茶，受得好友渡远禅师馈赠，得到上品碧螺春。原打算回山细细品尝，途中却被一群灵熊偷取...",
    acceptDes = "安慰伤心的#<Y,>李鬼谷#",
    needCmp = {20137},
    startNpc = 90928,
    acceptTalkId = 170591,
    zs = 2,
    lv = 129,
    rewardCoin = 30600,
    rewardGold = 0,
    rewardExp = 306439,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 209,
      data = {16072, 4072},
      talkId = 0,
      param = {
        {
          21007,
          1,
          100
        }
      },
      des = "追回被窃的#<Y,>包裹#"
    },
    dst2 = {
      type = 402,
      data = 90928,
      talkId = 170592,
      param = {
        {21007, 1}
      },
      des = "将装有茶叶的包裹交给#<Y,>李鬼谷#"
    }
  },
  [20139] = {
    mnName = "月夜惊梦",
    missionDes = "火焰山出现了一头吃人的凝血幽熊，它的出现给世辈都居住在火焰山里的村民们造成巨大的困扰。村民--阿拉希望你能为民除害，消灭那头该死的熊。",
    acceptDes = "#<Y,>盆地居民#有事找你",
    needCmp = {20138},
    startNpc = 90994,
    acceptTalkId = 170601,
    zs = 2,
    lv = 130,
    rewardCoin = 31400,
    rewardGold = 0,
    rewardExp = 313522,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16073, 4073},
      talkId = 0,
      param = 0,
      des = "消灭#<Y,>凝血幽熊#"
    },
    dst2 = {
      type = 101,
      data = 90994,
      talkId = 170602,
      param = 0,
      des = "向#<Y,>盆地居民#复命"
    }
  },
  [20140] = {
    mnName = "幽熊首领",
    missionDes = "上次火焰山的居民让你杀死凝血幽熊，没想到引出了熊王的报复。帮人帮到底，你决定帮阿拉除掉熊王。",
    acceptDes = "#<Y,>盆地居民#有事找你",
    needCmp = {20139},
    startNpc = 90994,
    acceptTalkId = 170611,
    zs = 2,
    lv = 131,
    rewardCoin = 32100,
    rewardGold = 0,
    rewardExp = 320760,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16074, 4074},
      talkId = 0,
      param = 0,
      des = "消灭#<Y,>幽熊王#"
    },
    dst2 = {
      type = 101,
      data = 90994,
      talkId = 170612,
      param = 0,
      des = "告知#<Y,>盆地村民#熊王已灭的消息"
    }
  },
  [20141] = {
    mnName = "幽灯",
    missionDes = "双叉岭的土地因常年受到火焰山的鬼魅所滋扰而无法工作，这使得他无比气愤！土地神希望你能将滋扰他的鬼魅消灭掉，好让自己安心工作。",
    acceptDes = "与魔王寨#<Y,>土地神#交谈",
    needCmp = {20140},
    startNpc = 90943,
    acceptTalkId = 170621,
    zs = 2,
    lv = 133,
    rewardCoin = 33600,
    rewardGold = 0,
    rewardExp = 335716,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16075, 4075},
      talkId = 0,
      param = 0,
      des = "去火焰山消灭#<Y,>幽煞#"
    },
    dst2 = {
      type = 101,
      data = 90943,
      talkId = 170622,
      param = 0,
      des = "向#<Y,>土地神#复命"
    }
  },
  [20142] = {
    mnName = "叉岭异样",
    missionDes = "自从大雁塔封印力量减弱之后，各门派为防止民间有妖怪趁机作祟，各派遣座下弟子前往大唐各个区域值守。化生寺的住持渡远禅师很久没收到双叉岭弟子的消息了，十分担心...",
    acceptDes = "听听#<Y,>渡远禅师#说些什么",
    needCmp = {20141},
    startNpc = 90901,
    acceptTalkId = 170631,
    zs = 2,
    lv = 134,
    rewardCoin = 27500,
    rewardGold = 0,
    rewardExp = 274753,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90982,
      talkId = 170632,
      param = 0,
      des = "找到双叉岭的#<Y,>化生寺弟子#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20143] = {
    mnName = "叉岭异样",
    missionDes = "自从大雁塔封印力量减弱之后，各门派为防止民间有妖怪趁机作祟，各派遣座下弟子前往大唐各个区域值守。化生寺的住持渡远禅师很久没收到双叉岭弟子的消息了，十分担心...",
    acceptDes = "0",
    needCmp = {20142},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 134,
    rewardCoin = 34300,
    rewardGold = 0,
    rewardExp = 343442,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16076, 4076},
      talkId = 0,
      param = 0,
      des = "消灭#<Y,>玄冥鬼手#"
    },
    dst2 = {
      type = 101,
      data = 90982,
      talkId = 170633,
      param = 0,
      des = "向#<Y,>化生寺弟子#复命"
    }
  },
  [20144] = {
    mnName = "寻妻",
    missionDes = "长安城赵言自从妻子失踪以来，整日借酒消愁，十分颓废。他不想妻子就这样不明不白的消失不见了。赵言希望你能帮助他，帮他找到心爱的妻子。",
    acceptDes = "#<Y,>赵言#有事找你",
    needCmp = {20143},
    startNpc = 95083,
    acceptTalkId = 170641,
    zs = 2,
    lv = 136,
    rewardCoin = 28800,
    rewardGold = 0,
    rewardExp = 287523,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90983,
      talkId = 170642,
      param = 0,
      des = "向#<Y,>红娘#打听线索"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20145] = {
    mnName = "刁难(一)",
    missionDes = "长安城赵言自从妻子失踪以来，整日借酒消愁，十分颓废。他不想妻子就这样不明不白的消失不见了。赵言希望你能帮助他，帮他找到心爱的妻子。",
    acceptDes = "找到岭中#<Y,>无赖#",
    needCmp = {20144},
    startNpc = 95084,
    acceptTalkId = 170651,
    zs = 2,
    lv = 136,
    rewardCoin = 35900,
    rewardGold = 0,
    rewardExp = 359404,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 90915,
      talkId = 170652,
      param = {
        {21070, 1}
      },
      des = "向#<Y,>酒馆老板#取得美酒"
    },
    dst2 = {
      type = 402,
      data = 95084,
      talkId = 170653,
      param = {
        {21070, 1}
      },
      des = "将女儿红交给#<Y,>无赖#"
    }
  },
  [20146] = {
    mnName = "刁难(二)",
    missionDes = "长安城赵言自从妻子失踪以来，整日借酒消愁，十分颓废。他不想妻子就这样不明不白的消失不见了。赵言希望你能帮助他，帮他找到心爱的妻子。",
    acceptDes = "0",
    needCmp = {20145},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 136,
    rewardCoin = 35900,
    rewardGold = 0,
    rewardExp = 359404,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 90002,
      talkId = 170654,
      param = {
        {21076, 1}
      },
      des = "向#<Y,>铁匠#取得武器"
    },
    dst2 = {
      type = 402,
      data = 95084,
      talkId = 170655,
      param = {
        {21076, 1}
      },
      des = "将斩马刀交给#<Y,>无赖#"
    }
  },
  [20147] = {
    mnName = "招供",
    missionDes = "长安城赵言自从妻子失踪以来，整日借酒消愁，十分颓废。他不想妻子就这样不明不白的消失不见了。赵言希望你能帮助他，帮他找到心爱的妻子。",
    acceptDes = "向#<Y,>无赖#索取芝琳线索",
    needCmp = {20146},
    startNpc = 95084,
    acceptTalkId = 170661,
    zs = 2,
    lv = 136,
    rewardCoin = 35900,
    rewardGold = 0,
    rewardExp = 359404,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16077, 4077},
      talkId = 0,
      wftalkId = 170662,
      param = 0,
      des = "给耍泼的#<Y,>无赖#一点教训"
    },
    dst2 = {
      type = 101,
      data = 95084,
      talkId = 170663,
      param = 0,
      des = "继续与#<Y,>无赖#交谈"
    }
  },
  [20148] = {
    mnName = "无妄之灾",
    missionDes = "长安城赵言自从妻子失踪以来，整日借酒消愁，十分颓废。他不想妻子就这样不明不白的消失不见了。赵言希望你能帮助他，帮他找到心爱的妻子。",
    acceptDes = "顺河流找到落水的#<Y,>芝琳#",
    needCmp = {20147},
    startNpc = 95085,
    acceptTalkId = 170671,
    zs = 2,
    lv = 136,
    rewardCoin = 35900,
    rewardGold = 0,
    rewardExp = 359404,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16078, 4078},
      talkId = 0,
      param = 0,
      des = "消灭杀人犯#<Y,>金龙#"
    },
    dst2 = {
      type = 101,
      data = 95085,
      talkId = 170672,
      param = 0,
      des = "向#<Y,>芝琳#复命"
    }
  },
  [20149] = {
    mnName = "心愿（一）",
    missionDes = "长安城赵言自从妻子失踪以来，整日借酒消愁，十分颓废。他不想妻子就这样不明不白的消失不见了。赵言希望你能帮助他，帮他找到心爱的妻子。",
    acceptDes = "了解#<Y,>芝琳#的遗愿",
    needCmp = {20148},
    startNpc = 95085,
    acceptTalkId = 170681,
    zs = 2,
    lv = 136,
    rewardCoin = 28800,
    rewardGold = 0,
    rewardExp = 287523,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90926,
      talkId = 170682,
      param = 0,
      des = "找#<Y,>袁天罡#想办法"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20150] = {
    mnName = "心愿（二）",
    missionDes = "长安城赵言自从妻子失踪以来，整日借酒消愁，十分颓废。他不想妻子就这样不明不白的消失不见了。赵言希望你能帮助他，帮他找到心爱的妻子。",
    acceptDes = "0",
    needCmp = {20149},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 136,
    rewardCoin = 35900,
    rewardGold = 0,
    rewardExp = 359404,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 209,
      data = {16079, 4079},
      talkId = 0,
      param = {
        {
          21078,
          1,
          100
        }
      },
      des = "去地府取得#<Y,>忘忧花#"
    },
    dst2 = {
      type = 402,
      data = 90926,
      talkId = 170683,
      param = {
        {21078, 1}
      },
      des = "将忘忧花交给#<Y,>袁天罡#"
    }
  },
  [20151] = {
    mnName = "痴情（一）",
    missionDes = "长安城赵言自从妻子失踪以来，整日借酒消愁，十分颓废。他不想妻子就这样不明不白的消失不见了。赵言希望你能帮助他，帮他找到心爱的妻子。",
    acceptDes = "0",
    needCmp = {20150},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 136,
    rewardCoin = 35900,
    rewardGold = 0,
    rewardExp = 359404,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 90926,
      talkId = 170691,
      param = {
        {21079, 1}
      },
      des = "与#<Y,>袁天罡#交谈取得忘情水"
    },
    dst2 = {
      type = 402,
      data = 95083,
      talkId = 170692,
      param = {
        {21079, 1}
      },
      des = "将配有忘情水的酒拿给#<Y,>赵言#"
    }
  },
  [20152] = {
    mnName = "痴情（二）",
    missionDes = "长安城赵言自从妻子失踪以来，整日借酒消愁，十分颓废。他不想妻子就这样不明不白的消失不见了。赵言希望你能帮助他，帮他找到心爱的妻子。",
    acceptDes = "0",
    needCmp = {20151},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 136,
    rewardCoin = 28800,
    rewardGold = 0,
    rewardExp = 287523,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 95085,
      talkId = 170693,
      param = 0,
      des = "向#<Y,>芝琳#复命"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20153] = {
    mnName = "轻生者",
    missionDes = "从外务工回来的农夫途径渔村时，不慎被海底窜出的鱼怪抢走了荷包。荷包里包裹的可是一年存下来的辛苦银两",
    acceptDes = "询问#<Y,>农夫#伤心的原因",
    needCmp = {20152},
    startNpc = 95082,
    acceptTalkId = 170701,
    zs = 2,
    lv = 138,
    rewardCoin = 37600,
    rewardGold = 0,
    rewardExp = 376074,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 209,
      data = {16080, 4080},
      talkId = 0,
      param = {
        {
          21012,
          1,
          100
        }
      },
      des = "夺回被抢的#<Y,>银票#"
    },
    dst2 = {
      type = 402,
      data = 95082,
      talkId = 170702,
      param = {
        {21012, 1}
      },
      des = "将银票交给#<Y,>农夫#"
    }
  },
  [20154] = {
    mnName = "狐踪魅影",
    missionDes = "魔王寨有一狐妖，此妖全身雪白，常常化作人形到山下为非作歹，将百姓引入山中加以谋害。土地神希望你能保泽一方，将狐妖消灭。",
    acceptDes = "#<Y,>土地神#有事找你",
    needCmp = {20153},
    startNpc = 90943,
    acceptTalkId = 170711,
    zs = 2,
    lv = 139,
    rewardCoin = 38500,
    rewardGold = 0,
    rewardExp = 384683,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16081, 4081},
      talkId = 0,
      param = 0,
      des = "消灭魔王寨里的#<Y,>诡面狐精#"
    },
    dst2 = {
      type = 101,
      data = 90943,
      talkId = 170712,
      param = 0,
      des = "向#<Y,>土地神#复命"
    }
  },
  [20155] = {
    mnName = "悔恨难离",
    missionDes = "莫念凡曾有一妻唤芝琳，两人曾经如胶似漆。好景不长在，魔将茶罗看中了芝琳的美色，欲霸占为妻。莫念凡胆小怕事，弃妻而逃.时隔多年，每当他想到此事均懊悔不已...",
    acceptDes = "与#<Y,>莫念凡#聊天",
    needCmp = {20154},
    startNpc = 95086,
    acceptTalkId = 170721,
    zs = 2,
    lv = 141,
    rewardCoin = 32200,
    rewardGold = 0,
    rewardExp = 321977,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 95087,
      talkId = 170722,
      param = 0,
      des = "找到#<Y,>冷凝儿#"
    },
    dst2 = {
      type = 101,
      data = 95086,
      talkId = 170723,
      param = 0,
      des = "将冷凝儿情况告知#<Y,>莫念凡#"
    }
  },
  [20156] = {
    mnName = "悔恨难离",
    missionDes = "莫念凡曾有一妻唤芝琳，两人曾经如胶似漆。好景不长在，魔将茶罗看中了芝琳的美色，欲霸占为妻。莫念凡胆小怕事，弃妻而逃.时隔多年，每当他想到此事均懊悔不已...",
    acceptDes = "0",
    needCmp = {20155},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 141,
    rewardCoin = 32200,
    rewardGold = 0,
    rewardExp = 321977,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 95088,
      talkId = 170724,
      param = 0,
      des = "找到#<Y,>冷凝儿的七魄#"
    },
    dst2 = {
      type = 208,
      data = {16082, 4082},
      talkId = 0,
      param = 0,
      des = "去魔王寨消灭#<Y,>茶罗#"
    }
  },
  [20157] = {
    mnName = "悔恨难离",
    missionDes = "莫念凡曾有一妻唤芝琳，两人曾经如胶似漆。好景不长在，魔将茶罗看中了芝琳的美色，欲霸占为妻。莫念凡胆小怕事，弃妻而逃.时隔多年，每当他想到此事均懊悔不已...",
    acceptDes = "0",
    needCmp = {20156},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 141,
    rewardCoin = 32200,
    rewardGold = 0,
    rewardExp = 321977,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 95088,
      talkId = 170725,
      param = 0,
      des = "向#<Y,>冷凝儿七魄#复命"
    },
    dst2 = {
      type = 101,
      data = 95087,
      talkId = 170726,
      param = 0,
      des = "探望#<Y,>冷凝儿#"
    }
  },
  [20158] = {
    mnName = "悔恨难离",
    missionDes = "莫念凡曾有一妻唤芝琳，两人曾经如胶似漆。好景不长在，魔将茶罗看中了芝琳的美色，欲霸占为妻。莫念凡胆小怕事，弃妻而逃.时隔多年，每当他想到此事均懊悔不已...",
    acceptDes = "0",
    needCmp = {20157},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 2,
    lv = 141,
    rewardCoin = 32200,
    rewardGold = 0,
    rewardExp = 321977,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 95086,
      talkId = 170727,
      param = 0,
      des = "带话给#<Y,>莫念凡#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20159] = {
    mnName = "柯夫人求助",
    missionDes = "柯夫人的女婿追捕长生教教徒时不幸身亡，女儿因思念情郎，郁郁而终。柯夫人希望你能帮她消灭罪魁祸首甄无常，以慰藉其女在天之灵。",
    acceptDes = "#<Y,>柯夫人#需要你的帮助",
    needCmp = {20158},
    startNpc = 95097,
    acceptTalkId = 170731,
    zs = 3,
    lv = 142,
    rewardCoin = 41200,
    rewardGold = 0,
    rewardExp = 411659,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16083, 4083},
      talkId = 0,
      param = 0,
      des = "消灭#<Y,>甄无常#"
    },
    dst2 = {
      type = 101,
      data = 95097,
      talkId = 170732,
      param = 0,
      des = "将甄无常已死的消息告诉#<Y,>柯夫人#"
    }
  },
  [20160] = {
    mnName = "噬火毒蝎",
    missionDes = "“火焰山的蝎群扩张的速度太快了！”家住双叉岭的天蓬元帅向你抱怨的说。为防止双叉岭被蝎侵占，天蓬元帅希望你阻止它们。",
    acceptDes = "#<Y,>天蓬元帅#有事找你",
    needCmp = {20159},
    startNpc = 95054,
    acceptTalkId = 170741,
    zs = 3,
    lv = 143,
    rewardCoin = 42100,
    rewardGold = 0,
    rewardExp = 421047,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16084, 4084},
      talkId = 0,
      param = 0,
      des = "去火焰山消灭#<Y,>噬火毒蝎#"
    },
    dst2 = {
      type = 101,
      data = 95054,
      talkId = 170742,
      param = 0,
      des = "向#<Y,>天蓬元帅#复命"
    }
  },
  [20161] = {
    mnName = "悲伤的精细鬼",
    missionDes = "玉净瓶被骗了，为此事急得团团转的精细鬼找到了你，希望你能帮他从骗子蓬莱道长那里夺回玉净瓶。",
    acceptDes = "安慰伤心的#<Y,>精细鬼#",
    needCmp = {20160},
    startNpc = 95092,
    acceptTalkId = 170761,
    zs = 3,
    lv = 144,
    rewardCoin = 43100,
    rewardGold = 0,
    rewardExp = 430641,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 209,
      data = {16085, 4085},
      talkId = 0,
      param = {
        {
          21080,
          1,
          100
        }
      },
      des = "帮#<Y,>精细鬼#夺回被骗的玉净瓶"
    },
    dst2 = {
      type = 402,
      data = 95092,
      talkId = 170762,
      param = {
        {21080, 1}
      },
      des = "将玉净瓶交还#<Y,>精细鬼#"
    }
  },
  [20162] = {
    mnName = "骆村之危",
    missionDes = "风云变异，幻化莫测。不知道从何时起，魔王寨被层层妖气笼罩起来。身为骆家庄主事人李家公为保全村人的安全，恳求你帮他取得驱邪之物--赤虎牙。",
    acceptDes = "#<Y,>李家公#需要你的帮助",
    needCmp = {20161},
    startNpc = 90991,
    acceptTalkId = 170771,
    zs = 3,
    lv = 145,
    rewardCoin = 44000,
    rewardGold = 0,
    rewardExp = 440444,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 209,
      data = {16086, 4086},
      talkId = 0,
      param = {
        {
          21081,
          1,
          100
        }
      },
      des = "从#<Y,>赤眼虎#身上取得虎牙"
    },
    dst2 = {
      type = 402,
      data = 90991,
      talkId = 170772,
      param = {
        {21081, 1}
      },
      des = "将虎牙交给#<Y,>李家公#"
    }
  },
  [20163] = {
    mnName = "骆村之危",
    missionDes = "风云变异，幻化莫测。不知道从何时起，魔王寨被层层妖气笼罩起来。身为骆家庄主事人李家公为保全村人的安全，恳求你帮他取得驱邪之物--赤虎牙。",
    acceptDes = "0",
    needCmp = {20162},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 145,
    rewardCoin = 44000,
    rewardGold = 0,
    rewardExp = 440444,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16087, 4087},
      talkId = 0,
      param = 0,
      des = "去#<Y,>洞口#查探原因"
    },
    dst2 = {
      type = 101,
      data = 90991,
      talkId = 170774,
      param = 0,
      des = "向#<Y,>李家公#复命"
    }
  },
  [20164] = {
    mnName = "莫名之毒",
    missionDes = "孙婆婆门下弟子得了一种怪病，这种病会让人陷入一种似昏似睡的状态中,而且极具传染性。孙婆婆需要你替她通知外门弟子殴涧西，让她尽快想出解决之法。结果...",
    acceptDes = "#<Y,>孙婆婆#有事找你",
    needCmp = {20163},
    startNpc = 90902,
    acceptTalkId = 170781,
    zs = 3,
    lv = 147,
    rewardCoin = 46100,
    rewardGold = 0,
    rewardExp = 460697,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 95099,
      talkId = 170782,
      param = {
        {21082, 1}
      },
      des = "从#<Y,>欧涧西#身上取得解药"
    },
    dst2 = {
      type = 401,
      data = {
        4,
        18,
        9
      },
      talkId = 0,
      param = {
        {21082, 1}
      },
      des = "将#<Y,>解药#倒入河中"
    }
  },
  [20165] = {
    mnName = "莫名之毒",
    missionDes = "孙婆婆门下弟子得了一种怪病，这种病会让人陷入一种似昏似睡的状态中,而且极具传染性。孙婆婆需要你替她通知外门弟子殴涧西，让她尽快想出解决之法。结果...",
    acceptDes = "0",
    needCmp = {20164},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 147,
    rewardCoin = 46100,
    rewardGold = 0,
    rewardExp = 460697,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 95099,
      talkId = 170783,
      param = {
        {21083, 1}
      },
      des = "向#<Y,>欧涧西#复命"
    },
    dst2 = {
      type = 402,
      data = 90902,
      talkId = 170784,
      param = {
        {21083, 1}
      },
      des = "将妙灵丹带给#<Y,>孙婆婆#"
    }
  },
  [20166] = {
    mnName = "内鬼",
    missionDes = "孙婆婆门下弟子得了一种怪病，这种病会让人陷入一种似昏似睡的状态中,而且极具传染性。孙婆婆需要你替她通知外门弟子殴涧西，让她尽快想出解决之法。结果...",
    acceptDes = "#<Y,>孙婆婆#需要你的帮助",
    needCmp = {20165},
    startNpc = 90902,
    acceptTalkId = 170791,
    zs = 3,
    lv = 147,
    rewardCoin = 46100,
    rewardGold = 0,
    rewardExp = 460697,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16088, 4088},
      talkId = 170792,
      param = 0,
      des = "质问#<Y,>欧涧西#"
    },
    dst2 = {
      type = 101,
      data = 90902,
      talkId = 170793,
      param = 0,
      des = "将欧涧西是奸细的情况告诉#<Y,>孙婆婆#"
    }
  },
  [20167] = {
    mnName = "解毒",
    missionDes = "孙婆婆门下弟子得了一种怪病，这种病会让人陷入一种似昏似睡的状态中,而且极具传染性。孙婆婆需要你替她通知外门弟子殴涧西，让她尽快想出解决之法。结果...",
    acceptDes = "继续与#<Y,>孙婆婆#交谈",
    needCmp = {20166},
    startNpc = 90902,
    acceptTalkId = 170801,
    zs = 3,
    lv = 147,
    rewardCoin = 36900,
    rewardGold = 0,
    rewardExp = 368557,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90973,
      talkId = 170802,
      param = 0,
      des = "向#<Y,>孙思邈#求助"
    },
    dst2 = {
      type = 101,
      data = 95100,
      talkId = 170803,
      param = 0,
      des = "去桥头找到#<Y,>孙思邈#"
    }
  },
  [20168] = {
    mnName = "圣雪莲花",
    missionDes = "孙婆婆门下弟子得了一种怪病，这种病会让人陷入一种似昏似睡的状态中,而且极具传染性。孙婆婆需要你替她通知外门弟子殴涧西，让她尽快想出解决之法。结果...",
    acceptDes = "向#<Y,>袁天罡#打听圣雪莲花的下落",
    needCmp = {20167},
    startNpc = 90926,
    acceptTalkId = 170811,
    zs = 3,
    lv = 147,
    rewardCoin = 36900,
    rewardGold = 0,
    rewardExp = 368557,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90901,
      talkId = 170812,
      param = 0,
      des = "向#<Y,>渡远禅师#索要雪莲"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20169] = {
    mnName = "圣雪莲花",
    missionDes = "孙婆婆门下弟子得了一种怪病，这种病会让人陷入一种似昏似睡的状态中,而且极具传染性。孙婆婆需要你替她通知外门弟子殴涧西，让她尽快想出解决之法。结果...",
    acceptDes = "0",
    needCmp = {20168},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 147,
    rewardCoin = 46100,
    rewardGold = 0,
    rewardExp = 460697,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 209,
      data = {16089, 4089},
      talkId = 0,
      param = {
        {
          21084,
          1,
          100
        }
      },
      des = "打败#<Y,>神兽#夺得圣雪莲花"
    },
    dst2 = {
      type = 402,
      data = 90973,
      talkId = 170813,
      param = {
        {21084, 1}
      },
      des = "将圣雪莲花交给#<Y,>孙思邈#"
    }
  },
  [20170] = {
    mnName = "圣雪莲花",
    missionDes = "孙婆婆门下弟子得了一种怪病，这种病会让人陷入一种似昏似睡的状态中,而且极具传染性。孙婆婆需要你替她通知外门弟子殴涧西，让她尽快想出解决之法。结果...",
    acceptDes = "0",
    needCmp = {20169},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 147,
    rewardCoin = 46100,
    rewardGold = 0,
    rewardExp = 460697,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 90973,
      talkId = 170814,
      param = {
        {21085, 1}
      },
      des = "继续与#<Y,>孙思邈#交谈，取得圣莲水"
    },
    dst2 = {
      type = 401,
      data = {
        4,
        18,
        9
      },
      talkId = 0,
      param = {
        {21085, 1}
      },
      des = "将#<Y,>圣莲水#倾入河中"
    }
  },
  [20171] = {
    mnName = "圣雪莲花",
    missionDes = "孙婆婆门下弟子得了一种怪病，这种病会让人陷入一种似昏似睡的状态中,而且极具传染性。孙婆婆需要你替她通知外门弟子殴涧西，让她尽快想出解决之法。结果...",
    acceptDes = "0",
    needCmp = {20170},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 147,
    rewardCoin = 46100,
    rewardGold = 0,
    rewardExp = 460697,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    },
    dst2 = {
      type = 101,
      data = 90902,
      talkId = 170815,
      param = 0,
      des = "告诉#<Y,>孙婆婆#河中之毒已解的消息"
    }
  },
  [20172] = {
    mnName = "清理门徒",
    missionDes = "孙婆婆门下弟子得了一种怪病，这种病会让人陷入一种似昏似睡的状态中,而且极具传染性。孙婆婆需要你替她通知外门弟子殴涧西，让她尽快想出解决之法。结果...",
    acceptDes = "与#<Y,>孙婆婆#交谈",
    needCmp = {20171},
    startNpc = 90902,
    acceptTalkId = 170821,
    zs = 3,
    lv = 147,
    rewardCoin = 46100,
    rewardGold = 0,
    rewardExp = 460697,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16090, 4090},
      talkId = 0,
      param = 0,
      des = "消灭叛徒#<Y,>赵雪渃#"
    },
    dst2 = {
      type = 101,
      data = 90902,
      talkId = 170822,
      param = 0,
      des = "向#<Y,>孙婆婆#复命"
    }
  },
  [20173] = {
    mnName = "大奸之徒",
    missionDes = "燃灯和尚，本名楚燊，本是长安一贼窝头目，后犯命案逃窜至火焰山。墨老希望你能替天行道，铲除此等罪恶之人。",
    acceptDes = "#<Y,>墨老#需要你的帮助",
    needCmp = {20172},
    startNpc = 90922,
    acceptTalkId = 170831,
    zs = 3,
    lv = 148,
    rewardCoin = 47100,
    rewardGold = 0,
    rewardExp = 471156,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16091, 4091},
      talkId = 0,
      param = 0,
      des = "去火焰山消灭#<Y,>楚燊#"
    },
    dst2 = {
      type = 101,
      data = 90922,
      talkId = 170832,
      param = 0,
      des = "向#<Y,>墨老#复命"
    }
  },
  [20174] = {
    mnName = "困兽之斗",
    missionDes = "早已成为过街老鼠的长生教教徒居然还有一小部分躲藏在火焰山中以待重镇旗鼓，斩草要除根，铁扇仙子要你将此等余孽连根拔除。",
    acceptDes = "#<Y,>铁扇仙子#有事找你",
    needCmp = {20173},
    startNpc = 90946,
    acceptTalkId = 170841,
    zs = 3,
    lv = 149,
    rewardCoin = 48200,
    rewardGold = 0,
    rewardExp = 481844,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16092, 4092},
      talkId = 0,
      param = 0,
      des = "消灭#<Y,>长生教余孽#"
    },
    dst2 = {
      type = 101,
      data = 90946,
      talkId = 170842,
      param = 0,
      des = "告知#<Y,>铁扇仙子#余孽已灭的消息"
    }
  },
  [20175] = {
    mnName = "显圣",
    missionDes = "火焰山中有一火狐，仗着法力高深，化无。搅得山下居民个个心惶惶、少安宁。居住在火焰山山下的村民希望你能帮他们解除此害，好还他们一个安宁、繁盛的生活。",
    acceptDes = "#<Y,>盆地居民#有事找你",
    needCmp = {20174},
    startNpc = 90994,
    acceptTalkId = 170851,
    zs = 3,
    lv = 150,
    rewardCoin = 49300,
    rewardGold = 0,
    rewardExp = 492765,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16093, 4093},
      talkId = 0,
      param = 0,
      des = "消灭火焰山深处的#<Y,>火狐#"
    },
    dst2 = {
      type = 101,
      data = 90994,
      talkId = 170852,
      param = 0,
      des = "向#<Y,>盆地居民#复命"
    }
  },
  [20176] = {
    mnName = "匪患",
    missionDes = "骆家村的水源来自东边的月牙泉。但最近几天，许多饮用泉水的村民都印堂发黑，昏迷不醒...李家公希望你能调查此事。",
    acceptDes = "#<Y,>李家公#需要你的帮助",
    needCmp = {20175},
    startNpc = 90991,
    acceptTalkId = 170861,
    zs = 3,
    lv = 151,
    rewardCoin = 50400,
    rewardGold = 0,
    rewardExp = 503924,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 208,
      data = {16094, 4094},
      talkId = 0,
      param = 0,
      des = "消灭#<Y,>强盗头目#"
    },
    dst2 = {
      type = 101,
      data = 90991,
      talkId = 170862,
      param = 0,
      des = "向#<Y,>李家公#复命"
    }
  },
  [20177] = {
    mnName = "匪患",
    missionDes = "骆家村的水源来自东边的月牙泉。但最近几天，许多饮用泉水的村民都印堂发黑，昏迷不醒...李家公希望你能调查此事。",
    acceptDes = "0",
    needCmp = {20176},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 151,
    rewardCoin = 50400,
    rewardGold = 0,
    rewardExp = 503924,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 90973,
      talkId = 170863,
      param = {
        {21083, 1}
      },
      des = "向#<Y,>孙神医#求助，取得妙灵丹"
    },
    dst2 = {
      type = 402,
      data = 90991,
      talkId = 170864,
      param = {
        {21083, 1}
      },
      des = "将解药带给#<Y,>李家公#"
    }
  },
  [20178] = {
    mnName = "陈箐之托",
    missionDes = "陈古月为了填补家用，去了双叉岭打猎。时隔一日，女儿陈箐见父亲彻夜未归，急火燎燎的找到了你。乐于助人的你决定帮助陈箐找到她父亲。",
    acceptDes = "#<Y,>陈箐#需要你的帮助",
    needCmp = {20177},
    startNpc = 95022,
    acceptTalkId = 170751,
    zs = 3,
    lv = 153,
    rewardCoin = 42200,
    rewardGold = 0,
    rewardExp = 421582,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 95098,
      talkId = 170752,
      param = 0,
      des = "去双叉岭找到#<Y,>陈古月#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [20179] = {
    mnName = "陈箐之托",
    missionDes = "陈古月为了填补家用，去了双叉岭打猎。时隔一日，女儿陈箐见父亲彻夜未归，急火燎燎的找到了你。乐于助人的你决定帮助陈箐找到她父亲。",
    acceptDes = "0",
    needCmp = {20178},
    startNpc = 0,
    acceptTalkId = 0,
    zs = 3,
    lv = 153,
    rewardCoin = 52700,
    rewardGold = 0,
    rewardExp = 526978,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 209,
      data = {16095, 4095},
      talkId = 0,
      param = {
        {
          21007,
          1,
          100
        }
      },
      des = "去双叉岭后山#<Y,>狩猎#"
    },
    dst2 = {
      type = 402,
      data = 95098,
      talkId = 170753,
      param = {
        {21007, 1}
      },
      des = "将包裹交给#<Y,>陈古月#"
    }
  }
}

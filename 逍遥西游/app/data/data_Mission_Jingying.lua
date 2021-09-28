data_Mission_Jingying = {
  [60001] = {
    mnName = "渔村凶兽",
    missionDes = "渔村的村民近来都不敢出门，原来是一头恶虎在作怪，渡远禅师希望你能解决此虎，为渔村的安宁作一份贡献。",
    acceptDes = "#<Y,>渡远禅师#有事找你",
    needCmp = {10003},
    startNpc = 90901,
    acceptTalkId = 210011,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        1,
        1,
        true
      },
      talkId = 0,
      param = 0,
      des = "消灭密林中的#<Y,>恶虎#"
    },
    dst2 = {
      type = 101,
      data = 90901,
      talkId = 210031,
      param = 0,
      des = "向#<Y,>渡远禅师#复命"
    }
  },
  [60002] = {
    mnName = "发怒的灵兽",
    missionDes = "渔村村外的灵兽最近显得狂躁不安，整天发出吼叫声，使得村民们都不敢接近它，渡厄禅师希望你前去调查一番。",
    acceptDes = "#<Y,>渡厄禅师#有事找你",
    needCmp = {10009, 60001},
    startNpc = 95012,
    acceptTalkId = 210041,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        1,
        4,
        true
      },
      talkId = 0,
      param = 0,
      des = "安抚渔村西口的#<Y,>灵兽#"
    },
    dst2 = {
      type = 101,
      data = 95012,
      talkId = 210061,
      param = 0,
      des = "向#<Y,>渡厄禅师#复命"
    }
  },
  [60003] = {
    mnName = "行商之阻",
    missionDes = "渔村的商人何万财愁眉苦脸的，问问他发生了什么事情吧。",
    acceptDes = "#<Y,>何万财#寻求你的帮助",
    needCmp = {10015, 60002},
    startNpc = 90931,
    acceptTalkId = 210071,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        1,
        7,
        true
      },
      talkId = 0,
      param = 0,
      des = "清除隐雾林中的#<Y,>妖兽#"
    },
    dst2 = {
      type = 101,
      data = 90931,
      talkId = 210091,
      param = 0,
      des = "告知#<Y,>何万财#障碍已清除"
    }
  },
  [60004] = {
    mnName = "福缘宝地",
    missionDes = "渔村的福缘洞洞内灵气浓郁，到处生长着奇珍异草，是块宝地。奈何此洞被一只厉害的妖兽给霸占了，使得那些每次去洞内采药的人都要靠性命来换取药材…",
    acceptDes = "听听#<Y,>药店老板#说些什么",
    needCmp = {10021, 60003},
    startNpc = 90910,
    acceptTalkId = 210101,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        1,
        10,
        true
      },
      talkId = 0,
      param = 0,
      des = "教训缘福洞中的#<Y,>药统领#"
    },
    dst2 = {
      type = 101,
      data = 90910,
      talkId = 210121,
      param = 0,
      des = "向#<Y,>药店老板#复命"
    }
  },
  [60005] = {
    mnName = "妖虫",
    missionDes = "程家祖屋有妖虫出现，把正在祖屋中休养的程公子吓得半死。程员外是寺院的大主顾，渡远禅师希望你能帮他清理程家祖屋中妖虫。",
    acceptDes = "#<Y,>渡远禅师#有事找你",
    needCmp = {10024, 60004},
    startNpc = 90901,
    acceptTalkId = 210131,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        1,
        13,
        true
      },
      talkId = 0,
      param = 0,
      des = "消灭程家祖屋里的#<Y,>妖虫#"
    },
    dst2 = {
      type = 101,
      data = 90901,
      talkId = 210141,
      param = 0,
      des = "向#<Y,>渡远禅师#交付任务"
    }
  },
  [60006] = {
    mnName = "告知消息",
    missionDes = "程家祖屋的妖虫已经清理完毕，赶紧把这个好消息告诉程员外吧。",
    acceptDes = "告知#<Y,>渡远禅师#事情结果",
    needCmp = {60005},
    startNpc = 90901,
    acceptTalkId = 210151,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90909,
      talkId = 210152,
      param = 0,
      des = "通知#<Y,>程员外#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [60007] = {
    mnName = "后山虫巢",
    missionDes = "渔村宁静祥和的环境被一群虫妖给破坏了，牛魔王告诉你想要彻底消灭妖虫就必须先断其后。牛魔王座下弟子探得虫妖巢穴就在渔村后山的枯虫窟，得此消息的你快去剿灭它们吧。",
    acceptDes = "#<Y,>牛魔王#有事情找你",
    needCmp = {10030, 60006},
    startNpc = 90905,
    acceptTalkId = 210161,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        1,
        16,
        true
      },
      talkId = 0,
      param = 0,
      des = "剿灭枯虫窟里的#<Y,>幼虫#"
    },
    dst2 = {
      type = 101,
      data = 90905,
      talkId = 210181,
      param = 0,
      des = "告知#<Y,>牛魔王#虫灾已灭"
    }
  },
  [60008] = {
    mnName = "情与义",
    missionDes = "那些灵兽们个个又开始闹腾了，渔村村长说是因为你抓了它们其中一个小伙伴，让他们少了一个玩伴所以才找个样子。并让你赶紧去安抚它们。",
    acceptDes = "#<Y,>渔村村长#有事情找你",
    needCmp = {10035, 60007},
    startNpc = 90978,
    acceptTalkId = 210191,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        1,
        19,
        true
      },
      talkId = 0,
      param = 0,
      des = "安抚#<Y,>灵兽#"
    },
    dst2 = {
      type = 101,
      data = 90978,
      talkId = 210211,
      param = 0,
      des = "向#<Y,>渔村村长#交付任务"
    }
  },
  [60009] = {
    mnName = "强盗入侵",
    missionDes = "长安郊外的李家村被强盗骚扰，官兵们正在组织人手，但需要一点时间，此时救人如救火，衙门衙役希望你能速速前往现场，制止那些强盗们。",
    acceptDes = "#<Y,>衙役#有事情找你",
    needCmp = {10207, 60008},
    startNpc = 90921,
    acceptTalkId = 220011,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        2,
        3,
        true
      },
      talkId = 0,
      param = 0,
      des = "前往荫林茶铺消灭#<Y,>强盗#"
    },
    dst2 = {
      type = 101,
      data = 90921,
      talkId = 220031,
      param = 0,
      des = "向#<Y,>衙役#复命"
    }
  },
  [60010] = {
    mnName = "流窜的贼寇",
    missionDes = "探子在青云岭发现贼寇的踪迹，衙役希望你能帮忙清剿贼寇，事不宜迟，快些动身吧。",
    acceptDes = "向#<Y,>衙役#取得贼寇的消息",
    needCmp = {10211, 60009},
    startNpc = 90921,
    acceptTalkId = 220041,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        2,
        6,
        true
      },
      talkId = 0,
      param = 0,
      des = "清剿青云岭的#<Y,>贼寇#"
    },
    dst2 = {
      type = 101,
      data = 90921,
      talkId = 220061,
      param = 0,
      des = "通知#<Y,>衙役#贼寇已除"
    }
  },
  [60011] = {
    mnName = "压寨夫人",
    missionDes = "与杂货商老板聊天时得知长安城东宋家出了事情--宋老的闺女被山贼抢走做压寨夫人去了，气愤不已的你马上去找宋老问问当时的情况，或许有可能帮他救出闺女。",
    acceptDes = "与#<Y,>杂货商#对话",
    needCmp = {10214, 60010},
    startNpc = 90908,
    acceptTalkId = 220071,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90979,
      talkId = 220072,
      param = 0,
      des = "向#<Y,>宋老#了解情况"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [60012] = {
    mnName = "宋老的委托",
    missionDes = "原来宋乔乔是被暮云寨的寨主擒住，得知此情况的你答应了宋老的请求，帮他救回闺女。",
    acceptDes = "继续向#<Y,>宋老#打听情况",
    needCmp = {60011},
    startNpc = 90979,
    acceptTalkId = 220081,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        2,
        9,
        true
      },
      talkId = 0,
      param = 0,
      des = "前往暮云寨解救#<Y,>宋乔乔#"
    },
    dst2 = {
      type = 101,
      data = 90979,
      talkId = 220091,
      param = 0,
      des = "向#<Y,>宋老#交付任务"
    }
  },
  [60013] = {
    mnName = "罪人",
    missionDes = "江洲知府在任职期间贪赃枉法，使得当地百姓怨声载道。经过探子侦查，发现此知府是由贼子刘洪假冒顶替，衙役希望你能将罪大恶极的刘洪秘密抓回审问。",
    acceptDes = "#<Y,>衙役#有事情找你",
    needCmp = {10220, 60012},
    startNpc = 90921,
    acceptTalkId = 220101,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        2,
        12,
        true
      },
      talkId = 0,
      param = 0,
      des = "抓捕#<Y,>刘洪#"
    },
    dst2 = {
      type = 101,
      data = 90921,
      talkId = 220121,
      param = 0,
      des = "将刘洪交给#<Y,>衙役#"
    }
  },
  [60014] = {
    mnName = "悟时不晚",
    missionDes = "袁天罡知道了你帮助衙役捉拿要犯刘洪的事情，告诉你刘洪的同伙们正准备来长安劫狱。此时他们正在天水河处集结，袁天罡希望你能借此机会，将这些害群之马一起击破。",
    acceptDes = "#<Y,>袁天罡#有事找你",
    needCmp = {10223, 60013},
    startNpc = 90926,
    acceptTalkId = 220131,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        2,
        15,
        true
      },
      talkId = 0,
      param = 0,
      des = "前往#<Y,>天水河#清除余孽"
    },
    dst2 = {
      type = 101,
      data = 90926,
      talkId = 220151,
      param = 0,
      des = "向#<Y,>袁天罡#交付任务"
    }
  },
  [60015] = {
    mnName = "婆婆的委托",
    missionDes = "孙婆婆嘴里不知道在嘀咕什么，时不时的还摇下头，好像遇到什么难事似得。",
    acceptDes = "安慰心情不好的#<Y,>孙婆婆#",
    needCmp = {10230, 60014},
    startNpc = 90902,
    acceptTalkId = 220161,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        2,
        19,
        true
      },
      talkId = 0,
      param = 0,
      des = "完成#<Y,>婆婆#的委托"
    },
    dst2 = {
      type = 101,
      data = 90902,
      talkId = 220181,
      param = 0,
      des = "向#<Y,>孙婆婆#交付任务"
    }
  },
  [60016] = {
    mnName = "爪牙",
    missionDes = "灵翠峰本是山清水秀的一座山峰，自从峰上来了一个女妖，好好一座山峰被弄得乌烟瘴气，山上到处可见形形色色的妖精。",
    acceptDes = "#<Y,>紫霞仙子#有事委托你",
    needCmp = {10234, 60015},
    startNpc = 90907,
    acceptTalkId = 220191,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        2,
        22,
        true
      },
      talkId = 0,
      param = 0,
      des = "消灭无天魔罗的#<Y,>爪牙#"
    },
    dst2 = {
      type = 101,
      data = 90907,
      talkId = 220211,
      param = 0,
      des = "向#<Y,>紫霞仙子#交付任务"
    }
  },
  [60017] = {
    mnName = "丑陋的妖怪",
    missionDes = "从墨家村回来的小贝急急忙忙的到处找你不知道所为何事，快去看看吧。",
    acceptDes = "了解#<Y,>小贝#神色异常的原因",
    needCmp = {10305, 60016},
    startNpc = 90981,
    acceptTalkId = 230011,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        3,
        2,
        true
      },
      talkId = 0,
      param = 0,
      des = "前往墨村消灭#<Y,>赤身鬼#"
    },
    dst2 = {
      type = 101,
      data = 90981,
      talkId = 230031,
      param = 0,
      des = "向#<Y,>小贝#交付任务"
    }
  },
  [60018] = {
    mnName = "消失的家禽",
    missionDes = "墨家村出了件怪事，圈养在雾林的家禽一夜之间突然少了一半。墨家村的村长墨老见到此事正伤心不已，你快过去看看吧。",
    acceptDes = "向#<Y,>墨老#打听奇怪的事情",
    needCmp = {10308, 60017},
    startNpc = 90922,
    acceptTalkId = 230041,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        3,
        5,
        true
      },
      talkId = 0,
      param = 0,
      des = "前往雾林消灭#<Y,>野鬼#"
    },
    dst2 = {
      type = 101,
      data = 90922,
      talkId = 230061,
      param = 0,
      des = "向#<Y,>墨老#交付任务"
    }
  },
  [60019] = {
    mnName = "受伤的弟子",
    missionDes = "化生寺的弟子满身是血的躺在地上，为什么他会如此狼狈？赶紧过去为他疗伤吧，顺道打探一下情况。",
    acceptDes = "救助受伤的#<Y,>化生寺弟子#",
    needCmp = {10312, 60018},
    startNpc = 90982,
    acceptTalkId = 230071,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        3,
        8,
        true
      },
      talkId = 0,
      param = 0,
      des = "铲除枯风洞的#<Y,>独眼妖#"
    },
    dst2 = {
      type = 101,
      data = 90982,
      talkId = 230091,
      param = 0,
      des = "向#<Y,>化生寺弟子#交付任务"
    }
  },
  [60020] = {
    mnName = "高家祠堂",
    missionDes = "高家远在巩州城的管家来信说祖祠在闹鬼，高太公为此事急的不得了，正到处派人找人帮忙除恶鬼。",
    acceptDes = "#<Y,>高太公#有事找你",
    needCmp = {10315, 60019},
    startNpc = 90935,
    acceptTalkId = 230101,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        3,
        11,
        true
      },
      talkId = 0,
      param = 0,
      des = "消灭祠堂#<Y,>恶鬼#"
    },
    dst2 = {
      type = 101,
      data = 90935,
      talkId = 230121,
      param = 0,
      des = "向#<Y,>高太公#交付任务"
    }
  },
  [60021] = {
    mnName = "猪妖的威胁",
    missionDes = "西和渡口出现了一只极其贪吃猪妖，为了吃，它霸占了整个西河渡口运输食物的船只。恰巧杂货商老板的一批急货也在其中，杂货商老板希望你能帮铲除猪妖，让货物顺利的北上。",
    acceptDes = "#<Y,>杂货商老板#有事找你",
    needCmp = {10318, 60020},
    startNpc = 90908,
    acceptTalkId = 230131,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        3,
        14,
        true
      },
      talkId = 0,
      param = 0,
      des = "清理西河渡口的#<Y,>猪妖#"
    },
    dst2 = {
      type = 101,
      data = 90908,
      talkId = 230151,
      param = 0,
      des = "向#<Y,>杂货商#交付任务"
    }
  },
  [60022] = {
    mnName = "复仇",
    missionDes = "打更人的儿子去双叉岭游玩时被那里的熊罢精杀死，至今尸骨未存，希望你可以帮助自己为他儿子报仇。",
    acceptDes = "安慰伤心的#<Y,>更夫#",
    needCmp = {10324, 60021},
    startNpc = 90929,
    acceptTalkId = 230161,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        3,
        18,
        true
      },
      talkId = 0,
      param = 0,
      des = "杀死双叉岭的#<Y,>熊精#"
    },
    dst2 = {
      type = 101,
      data = 90929,
      talkId = 230181,
      param = 0,
      des = "向#<Y,>更夫#交付任务"
    }
  },
  [60023] = {
    mnName = "安息",
    missionDes = "荆棘路出现了一只老虎精，已经吃人无数了。行走的商人们现在都不敢出门行商。袁天罡希望你能帮忙铲除那条恶虎，恢复经商之路。",
    acceptDes = "#<Y,>袁天罡#有事情找你",
    needCmp = {10328, 60022},
    startNpc = 90926,
    acceptTalkId = 230191,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        3,
        21,
        true
      },
      talkId = 0,
      param = 0,
      des = "铲除#<Y,>猫将军#"
    },
    dst2 = {
      type = 101,
      data = 90926,
      talkId = 230211,
      param = 0,
      des = "向#<Y,>袁天罡#交付任务"
    }
  },
  [60024] = {
    mnName = "不负责的守将",
    missionDes = "最近阳间一直有野鬼在闹事，都不知道地府鬼门关的守将是干什么用的，袁天罡希望你能去趟鬼门关，给予守关人员一点教训。",
    acceptDes = "与#<Y,>袁天罡#对话",
    needCmp = {10403, 60023},
    startNpc = 90926,
    acceptTalkId = 240011,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        4,
        2,
        true
      },
      talkId = 0,
      param = 0,
      des = "教训鬼门关的#<Y,>守将#"
    },
    dst2 = {
      type = 101,
      data = 90926,
      talkId = 240031,
      param = 0,
      des = "向#<Y,>袁天罡#交付任务"
    }
  },
  [60025] = {
    mnName = "审判",
    missionDes = "黄泉路的官员玩忽职守，收游魂钱财，擅自放游魂进入奈何桥，导致奈何桥喝汤的游魂剧增，而孟婆的汤又不够…",
    acceptDes = "拜访#<Y,>鬼将#",
    needCmp = {10407, 60024},
    startNpc = 90916,
    acceptTalkId = 240041,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        4,
        5,
        true
      },
      talkId = 0,
      param = 0,
      des = "打败黄泉路#<Y,>值守官员#"
    },
    dst2 = {
      type = 101,
      data = 90916,
      talkId = 240061,
      param = 0,
      des = "向#<Y,>鬼将#交付任务"
    }
  },
  [60026] = {
    mnName = "恶劣环境",
    missionDes = "忘川河出现了本该在十八层地狱羁押的恶鬼，这个恶鬼在忘川河到处吸收其他游魂以此来壮大自己，孟婆希望你可以杀死他。",
    acceptDes = "#<Y,>孟婆#有事找你",
    needCmp = {10411, 60025},
    startNpc = 90008,
    acceptTalkId = 240071,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        4,
        8,
        true
      },
      talkId = 0,
      param = 0,
      des = "前往忘川河消灭#<Y,>鬼王#"
    },
    dst2 = {
      type = 101,
      data = 90008,
      talkId = 240091,
      param = 0,
      des = "向#<Y,>孟婆#交付任务"
    }
  },
  [60027] = {
    mnName = "珍贵药材",
    missionDes = "杂货商老板认为铜蛇皮是很珍贵的药材，希望你想办法去趟地府帮他弄一张过来。",
    acceptDes = "看看#<Y,>杂货商老板#需要些什么",
    needCmp = {10418, 60026},
    startNpc = 90908,
    acceptTalkId = 240101,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 202,
      data = {
        4,
        11,
        true
      },
      talkId = 0,
      param = {
        {
          21039,
          1,
          100
        }
      },
      des = "从#<Y,>铜蛇#身上取得铜蛇皮"
    },
    dst2 = {
      type = 402,
      data = 90908,
      talkId = 240121,
      param = {
        {21039, 1}
      },
      des = "向#<Y,>杂货商#交付任务"
    }
  },
  [60028] = {
    mnName = "情根",
    missionDes = "长安城内负责牵线的红娘有事找你，还不赶紧过去看看，说不定是为你介绍对象#<E:20>#",
    acceptDes = "#<Y,>红娘#寻求你的帮助",
    needCmp = {10423, 60027},
    startNpc = 90983,
    acceptTalkId = 240131,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        4,
        14,
        true
      },
      talkId = 0,
      param = 0,
      des = "向三生石打听#<Y,>李斌#下落"
    },
    dst2 = {
      type = 101,
      data = 90983,
      talkId = 240132,
      param = 0,
      des = "把打听到的消息告知#<Y,>红娘#"
    }
  },
  [60029] = {
    mnName = "情根",
    missionDes = "去了一趟三生石的你并没有查到李斌的任何消息，但凡人死后必定会去孟婆那里。去找孟婆打听打听吧。",
    acceptDes = "向#<Y,>孟婆#打听情况",
    needCmp = {60028},
    startNpc = 90008,
    acceptTalkId = 240141,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90983,
      talkId = 240161,
      param = 0,
      des = "向#<Y,>红娘#交付任务"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [60030] = {
    mnName = "种子",
    missionDes = "牛魔王找你居然想让你帮他收赌债，没办法，人在屋檐下不能不低头，以后实力若是超过了他，必将报此仇。",
    acceptDes = "#<Y,>牛魔王#有事找你",
    needCmp = {10427, 60029},
    startNpc = 90905,
    acceptTalkId = 240171,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 202,
      data = {
        4,
        17,
        true
      },
      talkId = 0,
      param = {
        {
          21012,
          1,
          100
        }
      },
      des = "教训#<Y,>牛头将#"
    },
    dst2 = {
      type = 402,
      data = 90905,
      talkId = 240191,
      param = {
        {21012, 1}
      },
      des = "向#<Y,>牛魔王#交付任务"
    }
  },
  [60031] = {
    mnName = "疑虑",
    missionDes = "袁天罡怀疑近期朝廷多数官员的死亡与地府有关，希望你能帮他查一下生死薄里的记录。",
    acceptDes = "#<Y,>袁天罡#有事找你",
    needCmp = {10429, 60030},
    startNpc = 90926,
    acceptTalkId = 240201,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        4,
        19,
        true
      },
      talkId = 0,
      param = 0,
      des = "挑战#<Y,>生死薄#"
    },
    dst2 = {
      type = 101,
      data = 90926,
      talkId = 240221,
      param = 0,
      des = "向#<Y,>袁天罡#交付任务"
    }
  },
  [60032] = {
    mnName = "真凶",
    missionDes = "凡间多起野鬼伤人事件经过紫霞仙子调查，已经有眉目了，快找紫霞仙子问问谁是真凶吧。",
    acceptDes = "向#<Y,>紫霞仙子#打听恶鬼情况",
    needCmp = {10434, 60031},
    startNpc = 90907,
    acceptTalkId = 240231,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        4,
        22,
        true
      },
      talkId = 0,
      param = 0,
      des = "挑战#<Y,>萧判官#"
    },
    dst2 = {
      type = 101,
      data = 90907,
      talkId = 240251,
      param = 0,
      des = "向#<Y,>紫霞仙子#交付任务"
    }
  },
  [60033] = {
    mnName = "隐藏的水妖",
    missionDes = "渔村的航海线路被巨鳄们给破坏，外地的商船进不来，本地的商船出不去，这可急死了村长。村长希望你能帮忙清理航线上的障碍。",
    acceptDes = "拜访#<Y,>渔村村长#",
    needCmp = {10504, 60032},
    startNpc = 90978,
    acceptTalkId = 250011,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        5,
        2,
        true
      },
      talkId = 0,
      param = 0,
      des = "消灭沉船遗址里的#<Y,>水妖#"
    },
    dst2 = {
      type = 101,
      data = 90978,
      talkId = 250012,
      param = 0,
      des = "向#<Y,>渔村村长#交付任务"
    }
  },
  [60034] = {
    mnName = "教训",
    missionDes = "渡厄禅师希望你可以帮助他去深海裂谷里教训那些总是偷偷溜上岸的小钻风怪。",
    acceptDes = "#<Y,>渡厄禅师#有事找你",
    needCmp = {10510, 60033},
    startNpc = 95012,
    acceptTalkId = 250021,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        5,
        5,
        true
      },
      talkId = 0,
      param = 0,
      des = "去深海裂谷消灭#<Y,>钻风怪#"
    },
    dst2 = {
      type = 101,
      data = 95012,
      talkId = 250022,
      param = 0,
      des = "向#<Y,>渡厄禅师#交付任务"
    }
  },
  [60035] = {
    mnName = "李鬼谷的委托",
    missionDes = "李鬼谷昔日为了恢复避水珠中的灵气而前往深海收集珍珠，却不料被深海妖兽发现而打伤。李鬼谷希望你能为他报此重伤之仇。",
    acceptDes = "探望受伤的#<Y,>李鬼谷#",
    needCmp = {10514, 60034},
    startNpc = 90928,
    acceptTalkId = 250031,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        5,
        8,
        true
      },
      talkId = 0,
      param = 0,
      des = "杀死巨礁拱门的#<Y,>水云兽#"
    },
    dst2 = {
      type = 101,
      data = 90928,
      talkId = 250032,
      param = 0,
      des = "向#<Y,>李鬼谷#交付任务"
    }
  },
  [60036] = {
    mnName = "水府",
    missionDes = "无家可归的阿花向你哭诉龙宫的海将军跋扈无比的行为，海将军为了扩建自己的水府将附近的水族全部赶走。弱小的阿花希望你能帮助她夺回巢穴。",
    acceptDes = "安慰哭泣的#<Y,>阿花#",
    needCmp = {10518, 60035},
    startNpc = 90987,
    acceptTalkId = 250041,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        5,
        11,
        true
      },
      talkId = 0,
      param = 0,
      des = "教训#<Y,>海将军#"
    },
    dst2 = {
      type = 101,
      data = 90987,
      talkId = 250042,
      param = 0,
      des = "向#<Y,>阿花#交付任务"
    }
  },
  [60037] = {
    mnName = "奇珍异味",
    missionDes = "钱掌柜在长安城是出了名了老饕，为了美食，不知道砸了多少银两在上面。这不，现在又在四处寻找横公幼鱼…",
    acceptDes = "#<Y,>钱掌柜#有事找你",
    needCmp = {10523, 60036},
    startNpc = 90941,
    acceptTalkId = 250051,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 202,
      data = {
        5,
        14,
        true
      },
      talkId = 0,
      param = {
        {
          21041,
          1,
          100
        }
      },
      des = "去#<Y,>海泉眼#获得鱼卵"
    },
    dst2 = {
      type = 402,
      data = 90941,
      talkId = 250052,
      param = {
        {21041, 1}
      },
      des = "将鱼卵交给#<Y,>钱掌柜#"
    }
  },
  [60038] = {
    mnName = "斩草除根",
    missionDes = "海将军还真是冥顽不灵，前脚答应不在祸害邻里，后脚立马原形毕露,等你走后又将阿花赶了出来...",
    acceptDes = "与#<Y,>阿花#对话",
    needCmp = {10528, 60037},
    startNpc = 90987,
    acceptTalkId = 250061,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        5,
        17,
        true
      },
      talkId = 0,
      param = 0,
      des = "前往垂云殿消灭#<Y,>海将军#"
    },
    dst2 = {
      type = 101,
      data = 90987,
      talkId = 250062,
      param = 0,
      des = "向#<Y,>阿花#交付任务"
    }
  },
  [60039] = {
    mnName = "消灭帮凶",
    missionDes = "衙役告诉你近来所有水族袭击大唐子民的事件都是由泾河龙王的女儿龙女安排的，为了大唐子民的安全，衙役希望你能铲除龙宫公主。",
    acceptDes = "#<Y,>衙役#正在找你",
    needCmp = {10534, 60038},
    startNpc = 90921,
    acceptTalkId = 250071,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        5,
        20,
        true
      },
      talkId = 0,
      param = 0,
      des = "消灭#<Y,>龙宫公主#"
    },
    dst2 = {
      type = 101,
      data = 90921,
      talkId = 250072,
      param = 0,
      des = "向#<Y,>衙役#交付任务"
    }
  },
  [60040] = {
    mnName = "涅槃",
    missionDes = "泾河龙王居然没死！袁天罡将这个震撼的消息告诉了你。原来泾河龙王的魂魄一直躲在养魂殿中，欲借先魂之力破茧重生。袁天罡希望你能阻止此事情发生。",
    acceptDes = "与#<Y,>袁天罡#对话",
    needCmp = {10537, 60039},
    startNpc = 90926,
    acceptTalkId = 250081,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        5,
        22,
        true
      },
      talkId = 0,
      param = 0,
      des = "破坏#<Y,>龙王#的计划"
    },
    dst2 = {
      type = 101,
      data = 90926,
      talkId = 250082,
      param = 0,
      des = "向#<Y,>袁天罡#交付任务"
    }
  },
  [60041] = {
    mnName = "喜宴逢妖",
    missionDes = "高太公新招的女婿居然是个猪妖，这可把高老庄高太公的脸面全部给毁了。高太公委托墨老帮他四处找能除妖的仙士，这不，墨老找到了你，希望你能请替高太公赶跑猪妖。",
    acceptDes = "与#<Y,>墨老#对话",
    needCmp = {10604, 60040},
    startNpc = 90922,
    acceptTalkId = 260011,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        6,
        2,
        true
      },
      talkId = 0,
      param = 0,
      des = "教训高老庄的#<Y,>猪妖#"
    },
    dst2 = {
      type = 101,
      data = 90935,
      talkId = 260012,
      param = 0,
      des = "向#<Y,>高太公#交付任务"
    }
  },
  [60042] = {
    mnName = "天蓬元帅",
    missionDes = "仙界的天蓬元帅自从被贬下凡间后，就开始自暴自弃的生活。身为他转生前的好友紫霞仙子实在看不惯天蓬元帅的行径，委托你前去云栈洞给天蓬元帅敲一下警钟。",
    acceptDes = "#<Y,>紫霞仙子#有事找你",
    needCmp = {10609, 60041},
    startNpc = 90907,
    acceptTalkId = 260021,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        6,
        5,
        true
      },
      talkId = 0,
      param = 0,
      des = "去云栈洞教训#<Y,>天蓬元帅#"
    },
    dst2 = {
      type = 101,
      data = 90907,
      talkId = 260022,
      param = 0,
      des = "回复#<Y,>紫霞仙子#"
    }
  },
  [60043] = {
    mnName = "拜见菩萨",
    missionDes = "仙界的天蓬元帅自从被贬下凡间后，就开始自暴自弃的生活。身为他转生前的好友紫霞仙子实在看不惯天蓬元帅的行径，委托你前去云栈洞给天蓬元帅敲一下警钟。",
    acceptDes = "继续与#<Y,>紫霞仙子#交谈",
    needCmp = {60042},
    startNpc = 90907,
    acceptTalkId = 260023,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90904,
      talkId = 260024,
      param = 0,
      des = "向#<Y,>观音菩萨#禀告元帅之事"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [60044] = {
    mnName = "点化卷帘",
    missionDes = "刚忙完天蓬元帅的事情，又轮着曾经犯事的卷帘大将。观音菩萨有个口谕需要你传达给流沙河的沙和尚...",
    acceptDes = "#<Y,>观音菩萨#有事找你",
    needCmp = {10613, 60043},
    startNpc = 90904,
    acceptTalkId = 260031,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        6,
        8,
        true
      },
      talkId = 0,
      param = 0,
      des = "敲打#<Y,>卷帘大将#"
    },
    dst2 = {
      type = 101,
      data = 90904,
      talkId = 260032,
      param = 0,
      des = "向#<Y,>观音菩萨#交付任务"
    }
  },
  [60045] = {
    mnName = "阿大的烦恼",
    missionDes = "自从至尊宝离开斧头帮之后，整个斧头帮就一蹶不振。志向远大的阿大为使斧头帮重整声威，竞选了斧头帮帮主。上任后的阿大第一件事就是...",
    acceptDes = "与#<Y,>阿大#交谈",
    needCmp = {10617, 60044},
    startNpc = 90988,
    acceptTalkId = 260041,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        6,
        11,
        true
      },
      talkId = 0,
      param = 0,
      des = "去白虎岭消灭#<Y,>女魔#"
    },
    dst2 = {
      type = 101,
      data = 90988,
      talkId = 260042,
      param = 0,
      des = "向#<Y,>阿大#交付任务"
    }
  },
  [60046] = {
    mnName = "清除三魔",
    missionDes = "长安城内各个商家的商队近期频繁出事，商家们根据商队留下的线索查到了是有妖怪在作祟。愤怒不已的商家们将此事闹上了朝廷。袁天罡希望你能铲除许家庄院的妖魔，以息民愤。",
    acceptDes = "#<Y,>袁天罡#有事找你",
    needCmp = {10621, 60045},
    startNpc = 90926,
    acceptTalkId = 260051,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        6,
        14,
        true
      },
      talkId = 0,
      param = 0,
      des = "去许家庄院消灭#<Y,>三魔#"
    },
    dst2 = {
      type = 101,
      data = 90926,
      talkId = 260052,
      param = 0,
      des = "向#<Y,>袁天罡#复命"
    }
  },
  [60047] = {
    mnName = "药草包",
    missionDes = "孙神医好友通过商队从乌鸡国给他捎来一个装满药材的包裹，商队经过号山时，结果被当地强盗抢了去。孙神医希望你能帮他夺回包裹。",
    acceptDes = "与药王#<Y,>孙思邈#对话",
    needCmp = {10626, 60046},
    startNpc = 90973,
    acceptTalkId = 260061,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 202,
      data = {
        6,
        17,
        true
      },
      talkId = 0,
      param = {
        {
          21007,
          1,
          100
        }
      },
      des = "帮助#<Y,>孙思邈#夺回包裹"
    },
    dst2 = {
      type = 402,
      data = 90973,
      talkId = 260062,
      param = {
        {21007, 1}
      },
      des = "向#<Y,>孙思邈#复命"
    }
  },
  [60048] = {
    mnName = "离家失所",
    missionDes = "温和的土地公公被一群凶恶的妖怪赶出了土地庙，知道此情况的你决定帮助土地公公夺回属于他的府邸。",
    acceptDes = "安慰伤心的#<Y,>土地神#",
    needCmp = {10630, 60047},
    startNpc = 90939,
    acceptTalkId = 260071,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        6,
        20,
        true
      },
      talkId = 0,
      param = 0,
      des = "去枯松涧教训#<Y,>六丁目#"
    },
    dst2 = {
      type = 101,
      data = 90939,
      talkId = 260072,
      param = 0,
      des = "回复#<Y,>土地神#"
    }
  },
  [60049] = {
    mnName = "罪祸之源",
    missionDes = "通过土地公公口中得知，原来号山上所出现的强盗、凶恶的妖怪等等一切罪恶之人都是靠圣婴大王所庇护，嫉恶如仇的你决定要将此罪祸之源铲除掉。",
    acceptDes = "与#<Y,>土地神#对话",
    needCmp = {10633, 60048},
    startNpc = 90939,
    acceptTalkId = 260081,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        6,
        22,
        true
      },
      talkId = 0,
      param = 0,
      des = "消灭火云洞内#<Y,>圣婴魔王#"
    },
    dst2 = {
      type = 101,
      data = 90939,
      talkId = 260082,
      param = 0,
      des = "向#<Y,>土地神#交付任务"
    }
  },
  [60050] = {
    mnName = "珍珠",
    missionDes = "本应该送给母亲做寿礼的珍珠结果给了长生教作为入教费，后来想通之后前去讨要却被殴打一番。衙役希望你能帮他同僚取回珍珠。",
    acceptDes = "#<Y,>衙役#有急事找你",
    needCmp = {10704, 60049},
    startNpc = 90921,
    acceptTalkId = 270011,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 202,
      data = {
        7,
        2,
        true
      },
      talkId = 0,
      param = {
        {
          21014,
          1,
          100
        }
      },
      des = "帮助衙役夺回#<Y,>珍珠#"
    },
    dst2 = {
      type = 402,
      data = 90921,
      talkId = 270012,
      param = {
        {21014, 1}
      },
      des = "将珍珠交给#<Y,>衙役#"
    }
  },
  [60051] = {
    mnName = "解救小熊",
    missionDes = "长生教为了获取源源不断的灵气，到处捕捉灵兽。受伤的小熊希望你能救救它。",
    acceptDes = "与受伤的#<Y,>小熊#对话",
    needCmp = {10709, 60050},
    startNpc = 90989,
    acceptTalkId = 270021,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        7,
        5,
        true
      },
      talkId = 0,
      param = 0,
      des = "赶跑追来的#<Y,>双锤武士#"
    },
    dst2 = {
      type = 101,
      data = 90989,
      talkId = 270022,
      param = 0,
      des = "回复#<Y,>小熊#"
    }
  },
  [60052] = {
    mnName = "解救小熊",
    missionDes = "长生教为了获取源源不断的灵气，到处捕捉灵兽。受伤的小熊希望你能救救它。",
    acceptDes = "询问#<Y,>小熊#被追捕的原因",
    needCmp = {60051},
    startNpc = 90989,
    acceptTalkId = 270023,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90978,
      talkId = 270024,
      param = 0,
      des = "将小熊托付给#<Y,>渔村村长#"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [60053] = {
    mnName = "村长的担忧",
    missionDes = "渔村村长听闻小熊的事件后，才知晓长生教原来是如此邪恶。知道真相的他开始深深为村里的村民担忧起来...",
    acceptDes = "与#<Y,>渔村村长#对话",
    needCmp = {10714, 60052},
    startNpc = 90978,
    acceptTalkId = 270031,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        7,
        8,
        true
      },
      talkId = 0,
      param = 0,
      des = "消灭奉天书院里的#<Y,>长生教教徒#"
    },
    dst2 = {
      type = 101,
      data = 90978,
      talkId = 270032,
      param = 0,
      des = "回复#<Y,>渔村村长#"
    }
  },
  [60054] = {
    mnName = "方寸仙器",
    missionDes = "方寸山的镇山之宝诛仙剑来历不明，但威力无比。 镇元大仙告诉你仙剑就在罗真人手中，而罗真人是长生教的创始人。一方仙器不能被邪道所利用，所以他希望你能从罗真人手中夺回诛仙剑。",
    acceptDes = "#<Y,>镇元大仙#有事找你",
    needCmp = {10717, 60053},
    startNpc = 90903,
    acceptTalkId = 270041,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 202,
      data = {
        7,
        11,
        true
      },
      talkId = 0,
      param = {
        {
          21042,
          1,
          100
        }
      },
      des = "打败罗真人夺回#<Y,>诛仙剑#"
    },
    dst2 = {
      type = 402,
      data = 90903,
      talkId = 270042,
      param = {
        {21042, 1}
      },
      des = "将诛仙剑交给#<Y,>镇元大仙#"
    }
  },
  [60055] = {
    mnName = "续魂珠",
    missionDes = "孙神医听闻七绝山有一宝名叫续魂珠，此物能起到起死回生的作用。他希望你能帮他弄到一颗，作为药性研究的样本。",
    acceptDes = "与#<Y,>孙思邈#对话",
    needCmp = {10722, 60054},
    startNpc = 90973,
    acceptTalkId = 270051,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 202,
      data = {
        7,
        15,
        true
      },
      talkId = 0,
      param = {
        {
          21043,
          1,
          100
        }
      },
      des = "去七绝山取得#<Y,>续魂珠#"
    },
    dst2 = {
      type = 402,
      data = 90973,
      talkId = 270052,
      param = {
        {21043, 1}
      },
      des = "将魂珠交给#<Y,>孙思邈#"
    }
  },
  [60056] = {
    mnName = "臭味来源",
    missionDes = "驼罗庄的西面，有一座七绝山，山上有很多柿子树，每年都能结许多柿子，长年累月，没人去摘，烂的柿子把七绝山变成了一条淤泥河。一刮西风烂柿子的怪味飘进庄来，奇臭无比",
    acceptDes = "与#<Y,>李家公#对话",
    needCmp = {10728, 60055},
    startNpc = 90991,
    acceptTalkId = 270061,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90991,
      talkId = 270062,
      param = 0,
      des = "继续与#<Y,>李家公#对话"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [60057] = {
    mnName = "大扫除",
    missionDes = "驼罗庄的西面，有一座七绝山，山上有很多柿子树，每年都能结许多柿子，长年累月，没人去摘，烂的柿子把七绝山变成了一条淤泥河。一刮西风烂柿子的怪味飘进庄来，奇臭无比",
    acceptDes = "继续与#<Y,>李家公#对话",
    needCmp = {60056},
    startNpc = 90991,
    acceptTalkId = 270063,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        7,
        19,
        true
      },
      talkId = 0,
      param = 0,
      des = "消灭#<Y,>牛妖#"
    },
    dst2 = {
      type = 101,
      data = 90991,
      talkId = 270064,
      param = 0,
      des = "向#<Y,>李家公#交付任务"
    }
  },
  [60058] = {
    mnName = "系铃人",
    missionDes = "封印在方寸后山中的域外邪魔赤炼妖姬借助无天魔罗的力量破印而出。善于控神之术的她将方寸山中弟子全部控制之于股掌之中。要消除他们身上的控制，就必须消灭赤炼妖姬。",
    acceptDes = "#<Y,>紫霞仙子#正到处找你",
    needCmp = {10732, 60057},
    startNpc = 90907,
    acceptTalkId = 270071,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        7,
        22,
        true
      },
      talkId = 0,
      param = 0,
      des = "前往后山消灭#<Y,>赤炼妖#"
    },
    dst2 = {
      type = 101,
      data = 90907,
      talkId = 270072,
      param = 0,
      des = "回复#<Y,>紫霞仙子#"
    }
  },
  [60059] = {
    mnName = "救火",
    missionDes = "住在火焰山盆地的村民家里着火了，火势及其的猛烈，村民到处喊邻居们救火，可火焰山的水比人命都还重要，每人出手帮助。路过此地的你看不惯村民们的行事风格，决定前去看看火势，结果发现是火妖在作乱。",
    acceptDes = "帮助#<Y,>盆地村民#",
    needCmp = {10803, 60058},
    startNpc = 90994,
    acceptTalkId = 280011,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        8,
        1,
        true
      },
      talkId = 0,
      param = 0,
      des = "消灭放火的#<Y,>赤焰妖#"
    },
    dst2 = {
      type = 101,
      data = 90994,
      talkId = 280012,
      param = 0,
      des = "向#<Y,>火焰山居民#复命"
    }
  },
  [60060] = {
    mnName = "袁天罡的请求",
    missionDes = "袁天罡最近神神秘秘的不知道在捣鼓些什么，这不，他又要你帮他去赤炎沙漠挖火焰晶石了。",
    acceptDes = "与#<Y,>袁天罡#对话",
    needCmp = {10809, 60059},
    startNpc = 90926,
    acceptTalkId = 280021,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 202,
      data = {
        8,
        4,
        true
      },
      talkId = 0,
      param = {
        {
          21044,
          1,
          100
        }
      },
      des = "获取#<Y,>火焰结晶#"
    },
    dst2 = {
      type = 402,
      data = 90926,
      talkId = 280022,
      param = {
        {21044, 1}
      },
      des = "向#<Y,>袁天罡#复命"
    }
  },
  [60061] = {
    mnName = "骄横的宫女",
    missionDes = "“铁扇仙子的宫女常常欺负前去朝拜的乡民”，这是土地公公跟你说过的话。连温和的土地公公都看不惯那宫女的行径了，你需要做点什么。",
    acceptDes = "#<Y,>土地神#有事委托你",
    needCmp = {10814, 60060},
    startNpc = 90943,
    acceptTalkId = 280031,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        8,
        7,
        true
      },
      talkId = 0,
      param = 0,
      des = "教训骄横的#<Y,>宫女#"
    },
    dst2 = {
      type = 101,
      data = 90943,
      talkId = 280032,
      param = 0,
      des = "回复#<Y,>土地神#"
    }
  },
  [60062] = {
    mnName = "玄金兽",
    missionDes = "玄金兽的父亲赤金兽因为赤金角被万岁狐狸强行夺取而丢了性命。长大之后的玄金兽想从万岁狐王之女玉面公主手中要回属于自己的遗物，结果每次都失败。伤心不已的玄金兽需要你的帮助。",
    acceptDes = "与#<Y,>玄金兽#对话",
    needCmp = {10820, 60061},
    startNpc = 90992,
    acceptTalkId = 280041,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 101,
      data = 90992,
      talkId = 280042,
      param = 0,
      des = "继续与#<Y,>玄金兽#对话"
    },
    dst2 = {
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [60063] = {
    mnName = "玄金兽",
    missionDes = "玄金兽的父亲赤金兽因为赤金角被万岁狐狸强行夺取而丢了性命。长大之后的玄金兽想从万岁狐王之女玉面公主手中要回属于自己的遗物，结果每次都失败。伤心不已的玄金兽需要你的帮助。",
    acceptDes = "继续与#<Y,>玄金兽#对话",
    needCmp = {60062},
    startNpc = 90992,
    acceptTalkId = 280043,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        8,
        10,
        true
      },
      talkId = 0,
      param = 0,
      des = "打败#<Y,>玉面公主#"
    },
    dst2 = {
      type = 101,
      data = 90993,
      talkId = 280044,
      param = 0,
      des = "质问#<Y,>玉面公主#"
    }
  },
  [60064] = {
    mnName = "赤金角",
    missionDes = "玄金兽的父亲赤金兽因为赤金角被万岁狐狸强行夺取而丢了性命。长大之后的玄金兽想从万岁狐王之女玉面公主手中要回属于自己的遗物，结果每次都失败。伤心不已的玄金兽需要你的帮助。",
    acceptDes = "诱导#<Y,>玉面公主#归还赤金角",
    needCmp = {10825, 60063},
    startNpc = 90993,
    acceptTalkId = 280051,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        8,
        13,
        true
      },
      talkId = 0,
      param = 0,
      des = "打败#<Y,>牛魔王#"
    },
    dst2 = {
      type = 101,
      data = 90993,
      talkId = 280052,
      param = 0,
      des = "回复#<Y,>玉面公主#"
    }
  },
  [60065] = {
    mnName = "赤金角",
    missionDes = "玄金兽的父亲赤金兽因为赤金角被万岁狐狸强行夺取而丢了性命。长大之后的玄金兽想从万岁狐王之女玉面公主手中要回属于自己的遗物，结果每次都失败。伤心不已的玄金兽需要你的帮助。",
    acceptDes = "与#<Y,>玉面公主#对话",
    needCmp = {60064},
    startNpc = 90993,
    acceptTalkId = 280053,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 301,
      data = 90993,
      talkId = 280054,
      param = {
        {21049, 1}
      },
      des = "向玉面公主索要#<Y,>赤金角#"
    },
    dst2 = {
      type = 402,
      data = 90992,
      talkId = 280055,
      param = {
        {21049, 1}
      },
      des = "将赤金角交给#<Y,>玄金兽#"
    }
  },
  [60066] = {
    mnName = "云罗沙",
    missionDes = "神神秘秘的袁天罡告终于冒泡了，他告诉你最近他一直在捣鼓一种阵法，这种阵法可以用来代替使用观星术时所消耗的珍贵材料。袁天罡希望你能去火焰谷里帮他弄一份云罗沙过来。",
    acceptDes = "#<Y,>袁天罡#有事找你",
    needCmp = {10832, 60065},
    startNpc = 90926,
    acceptTalkId = 280061,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 202,
      data = {
        8,
        16,
        true
      },
      talkId = 0,
      param = {
        {
          21047,
          1,
          100
        }
      },
      des = "获得#<Y,>云罗沙#"
    },
    dst2 = {
      type = 402,
      data = 90926,
      talkId = 280062,
      param = {
        {21047, 1}
      },
      des = "将云罗沙交给#<Y,>袁天罡#"
    }
  },
  [60067] = {
    mnName = "小贝的烦恼",
    missionDes = "小贝与隔壁家的小紫经常在一起玩耍，从小二人就两小无猜。小贝为了逗小紫开心，恳请你帮他去遥远的西方--赤地取得一块耀眼的水晶。",
    acceptDes = "与#<Y,>小贝#对话",
    needCmp = {10836, 60066},
    startNpc = 90981,
    acceptTalkId = 280071,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 202,
      data = {
        8,
        19,
        true
      },
      talkId = 0,
      param = {
        {
          21048,
          1,
          100
        }
      },
      des = "去赤地取得#<Y,>水晶#"
    },
    dst2 = {
      type = 402,
      data = 90981,
      talkId = 280072,
      param = {
        {21048, 1}
      },
      des = "将水晶交给#<Y,>小贝#"
    }
  },
  [60068] = {
    mnName = "心愿",
    missionDes = "百年前吉泰村深受天灾横祸，除了程员外爷爷以外，全村人无一幸免。时至如今，程员外的爷爷想要回归故土，但天灾未除。无法完成爷爷遗愿的程员外懊恼不已...",
    acceptDes = "与#<Y,>程员外#对话",
    needCmp = {10840, 60067},
    startNpc = 90909,
    acceptTalkId = 280081,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        8,
        22,
        true
      },
      talkId = 0,
      param = 0,
      des = "浇灭#<Y,>吉泰村#的大火"
    },
    dst2 = {
      type = 101,
      data = 90909,
      talkId = 280082,
      param = 0,
      des = "向#<Y,>程员外#交付任务"
    }
  },
  [60069] = {
    mnName = "商人的诉苦",
    missionDes = "子母河河中出现妖怪，这可把专门倒卖子母河河水的跑商吓得不轻。闻得此事的你决定去子母河看看。",
    acceptDes = "与#<Y,>商人#对话",
    needCmp = {10905, 60068},
    startNpc = 90995,
    acceptTalkId = 290011,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        9,
        3,
        true
      },
      talkId = 0,
      param = 0,
      des = "消灭#<Y,>子母河#中出现的妖怪"
    },
    dst2 = {
      type = 101,
      data = 90995,
      talkId = 290012,
      param = 0,
      des = "向#<Y,>商人#交付任务"
    }
  },
  [60070] = {
    mnName = "非法勾当",
    missionDes = "女儿国出现了一群唯利是图的道士，他们明里诵经念佛，暗里却操控着落阳水。为了扩建道观，他们将主意打到青霞仙子身上，这让仙子很生气。青霞仙子希望你能帮她赶走这些人。",
    acceptDes = "拜访#<Y,>青霞仙子#",
    needCmp = {10911, 60069},
    startNpc = 90906,
    acceptTalkId = 290021,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        9,
        6,
        true
      },
      talkId = 0,
      param = 0,
      des = "教训引阳驿站里的#<Y,>道姑#"
    },
    dst2 = {
      type = 101,
      data = 90906,
      talkId = 290022,
      param = 0,
      des = "向#<Y,>青霞仙子#交付任务"
    }
  },
  [60071] = {
    mnName = "不识泰山",
    missionDes = "以如意真仙为主的一群贪财之人，为了钱财而得罪了青霞仙子，青霞仙子希望你能将这个罪恶团伙连根拔起。",
    acceptDes = "与#<Y,>青霞仙子#对话",
    needCmp = {10917, 60070},
    startNpc = 90906,
    acceptTalkId = 290031,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        9,
        9,
        true
      },
      talkId = 0,
      param = 0,
      des = "打败#<Y,>引阳馆馆主#"
    },
    dst2 = {
      type = 101,
      data = 90906,
      talkId = 290032,
      param = 0,
      des = "向#<Y,>青霞仙子#交付任务"
    }
  },
  [60072] = {
    mnName = "冒牌将军",
    missionDes = "回家探亲的将军回宫之后发现自己被被替代了，而替换她的正是她自己，这让将军惊恐不已。护国将军希望你帮她查清此事。",
    acceptDes = "女儿国的#<Y,>护国将军#有事找你",
    needCmp = {10923, 60071},
    startNpc = 90996,
    acceptTalkId = 290041,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        9,
        12,
        true
      },
      talkId = 0,
      param = 0,
      des = "消灭#<Y,>冒牌将军#"
    },
    dst2 = {
      type = 101,
      data = 90996,
      talkId = 290042,
      param = 0,
      des = "回复#<Y,>护国将军#"
    }
  },
  [60073] = {
    mnName = "逼婚",
    missionDes = "路经女儿国的法师被此国国王逼婚，百般无奈的三藏法师向你求助，希望你能帮他脱离此困境。",
    acceptDes = "#<Y,>法师#有事找你",
    needCmp = {10930, 60072},
    startNpc = 90952,
    acceptTalkId = 290051,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        9,
        15,
        true
      },
      talkId = 0,
      param = 0,
      des = "阻止逼婚的#<Y,>国王#"
    },
    dst2 = {
      type = 101,
      data = 90952,
      talkId = 290052,
      param = 0,
      des = "向#<Y,>三藏法师#交付任务"
    }
  },
  [60074] = {
    mnName = "蝎尾",
    missionDes = "小灿的母亲卧病在床，身为孝子的小灿听大夫说蝎子尾巴里的毒能治疗他母亲的病，便孤身来到毒敌山准备捉毒蝎.奈何年纪善小，惧怕毒蝎，在山前止步不前。",
    acceptDes = "与#<Y,>小灿#对话",
    needCmp = {10935, 60073},
    startNpc = 90997,
    acceptTalkId = 290061,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 202,
      data = {
        9,
        18,
        true
      },
      talkId = 0,
      param = {
        {
          21050,
          1,
          100
        }
      },
      des = "前往毒敌山收集#<Y,>蝎尾#"
    },
    dst2 = {
      type = 402,
      data = 90997,
      talkId = 290062,
      param = {
        {21050, 1}
      },
      des = "将蝎尾交给#<Y,>小灿#"
    }
  },
  [60075] = {
    mnName = "隐患",
    missionDes = "女儿国将军知道假扮她的是蝎子精后，便对毒敌山展开了调查。功夫不负有心人，在毒敌山琵琶洞里，发现了一只蝎子精女王。将军为了国家安全着想，希望你能帮她消灭蝎精女王。",
    acceptDes = "与#<Y,>护国将军#对话",
    needCmp = {10942, 60074},
    startNpc = 90996,
    acceptTalkId = 290071,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        9,
        22,
        true
      },
      talkId = 0,
      param = 0,
      des = "前往琵琶洞消灭#<Y,>蝎子精#"
    },
    dst2 = {
      type = 101,
      data = 90996,
      talkId = 290072,
      param = 0,
      des = "回复#<Y,>护国将军#"
    }
  },
  [60076] = {
    mnName = "拦路老者",
    missionDes = "狮驼国每两年举行一次的矿石节马上要举办了，各地商人纷至沓来。在进入狮驼国地界时，大家被一个老者拦截于此。商人们怀疑有人想恶性竞争，独吞矿石，特请你能帮他赶走那位老者。",
    acceptDes = "#<Y,>商人#有事委托你",
    needCmp = {11006, 60075},
    startNpc = 90998,
    acceptTalkId = 150011,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        10,
        1,
        true
      },
      talkId = 0,
      param = 0,
      des = "打败拦路#<Y,>老者#"
    },
    dst2 = {
      type = 101,
      data = 90998,
      talkId = 150012,
      param = 0,
      des = "向#<Y,>商人#交付任务"
    }
  },
  [60077] = {
    mnName = "血仇",
    missionDes = "狮驼国自从被妖怪霸占以来，烧杀抢掠，无所不用其极。幸存者的一家老家小也因此而被波及，无一幸免。幸存者希望你能帮他报此家仇。",
    acceptDes = "#<Y,>幸存者#有事委托你",
    needCmp = {11010, 60076},
    startNpc = 90999,
    acceptTalkId = 150021,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        10,
        4,
        true
      },
      talkId = 0,
      param = 0,
      des = "消灭#<Y,>营寨#里的妖怪"
    },
    dst2 = {
      type = 101,
      data = 90999,
      talkId = 150022,
      param = 0,
      des = "向#<Y,>幸存者#交付任务"
    }
  },
  [60078] = {
    mnName = "紧急情况",
    missionDes = "黑风老妖靠吸食人的精气而活，只要给他时间。他的实力将无线膨大。为了凡间万千生灵，李鬼谷希望你能消灭黑风寨里的黑风老妖。",
    acceptDes = "#<Y,>李鬼谷#有事委托你",
    needCmp = {11015, 60077},
    startNpc = 90928,
    acceptTalkId = 150031,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        10,
        7,
        true
      },
      talkId = 0,
      param = 0,
      des = "消灭#<Y,>黑风老妖#"
    },
    dst2 = {
      type = 101,
      data = 90928,
      talkId = 150032,
      param = 0,
      des = "向#<Y,>李鬼谷#交付任务"
    }
  },
  [60079] = {
    mnName = "失踪的书生",
    missionDes = "根据高太公提供的线索，岐木森林出现了一只专门迷惑各地赶考书生的妖怪。这些书生都是国之栋梁，为了他们安全着想，高太公希望你能将此妖铲除。",
    acceptDes = "与#<Y,>高太公#对话",
    needCmp = {11021, 60078},
    startNpc = 90935,
    acceptTalkId = 150041,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        10,
        10,
        true
      },
      talkId = 0,
      param = 0,
      des = "前往岐木森林杀死#<Y,>迷魂蛇精#"
    },
    dst2 = {
      type = 101,
      data = 90935,
      talkId = 150042,
      param = 0,
      des = "回复#<Y,>高太公#"
    }
  },
  [60080] = {
    mnName = "熊王",
    missionDes = "狮驼国的妖怪们祸害狮驼国不够，居然跑到女儿国想要女儿国国王向他们俯首称臣。如若不同，将会遭受狮驼国一样的报复。为此，着急的护国将军找到了你，希望你能帮女儿国度过此劫难。",
    acceptDes = "#<Y,>护国将军#有事找你",
    needCmp = {11026, 60079},
    startNpc = 90996,
    acceptTalkId = 150051,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        10,
        13,
        true
      },
      talkId = 0,
      param = 0,
      des = "前往熊王寨杀死#<Y,>混世熊王#"
    },
    dst2 = {
      type = 101,
      data = 90996,
      talkId = 150052,
      param = 0,
      des = "向#<Y,>护国将军#交付任务"
    }
  },
  [60081] = {
    mnName = "试练石",
    missionDes = "不破不立，只有在生死之间的战斗才会挥发极致的潜力。仙子要求你拿明月山中的青面狮王作为自己的试炼石。",
    acceptDes = "与#<Y,>紫霞仙子#对话",
    needCmp = {11030, 60080},
    startNpc = 90907,
    acceptTalkId = 150061,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        10,
        16,
        true
      },
      talkId = 0,
      param = 0,
      des = "前往明月山杀死#<Y,>青面狮王#"
    },
    dst2 = {
      type = 101,
      data = 90907,
      talkId = 150062,
      param = 0,
      des = "向#<Y,>紫霞仙子#交付任务"
    }
  },
  [60082] = {
    mnName = "罪孽深重",
    missionDes = "妖就是妖，就不该对他有一丝怜悯之心。六牙妖象自从大雁塔逃出后，所犯的罪行罄竹难书，真当是鲜血染红了山岭，煞气遮挡了天空。化生寺弟子希望你能消灭此罪妖。",
    acceptDes = "与#<Y,>化生寺弟子#对话",
    needCmp = {11036, 60081},
    startNpc = 90982,
    acceptTalkId = 150071,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        10,
        19,
        true
      },
      talkId = 0,
      param = 0,
      des = "前往青山岭消灭#<Y,>六牙象王#"
    },
    dst2 = {
      type = 101,
      data = 90982,
      talkId = 150072,
      param = 0,
      des = "回复#<Y,>化生寺弟子#"
    }
  },
  [60083] = {
    mnName = "转世如来",
    missionDes = "自从如来为了扼制无天魔罗散去修为转世重生后，大鹏金雕无时不刻的都在寻找转世如来的下落。一旦被大鹏金雕找到，如来将会陷入万劫不复。长眉罗汉为了防止此事发生，要求你一定要将大鹏金雕铲除。",
    acceptDes = "#<Y,>长眉罗汉#有事找你",
    needCmp = {11040, 60082},
    startNpc = 91000,
    acceptTalkId = 150081,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        10,
        22,
        true
      },
      talkId = 0,
      param = 0,
      des = "消灭#<Y,>大鹏雕王#"
    },
    dst2 = {
      type = 101,
      data = 91000,
      talkId = 150082,
      param = 0,
      des = "向#<Y,>长眉罗汉#交付任务"
    }
  },
  [60084] = {
    mnName = "赌局",
    missionDes = "观音菩萨的座下弟子小龙女与人参娃娃打赌，谁要是能在孔雀开屏之日取得孔雀的羽毛，谁就是对方的老大。苦于小龙女被菩萨禁足，无法参与夺羽行动。小龙女希望你能帮她取得一根孔雀之羽。",
    acceptDes = "与#<Y,>小龙女#对话",
    needCmp = {11107, 60083},
    startNpc = 91001,
    acceptTalkId = 150111,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 202,
      data = {
        11,
        3,
        true
      },
      talkId = 0,
      param = {
        {
          21051,
          1,
          100
        }
      },
      des = "帮助小龙女取得#<Y,>孔雀羽毛#"
    },
    dst2 = {
      type = 402,
      data = 91001,
      talkId = 150112,
      param = {
        {21051, 1}
      },
      des = "向#<Y,>小龙女#交付任务"
    }
  },
  [60085] = {
    mnName = "恶仙",
    missionDes = "“巨灵神越来越放肆了，他居然想霸占整个蟠桃园的仙桃。”这是双锤天将对你说的。双锤天将希望你能教训一下巨灵神。",
    acceptDes = "与#<Y,>双锤天将#对话",
    needCmp = {11115, 60084},
    startNpc = 91002,
    acceptTalkId = 150121,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        11,
        6,
        true
      },
      talkId = 0,
      param = 0,
      des = "前往南天门教训#<Y,>巨灵神#"
    },
    dst2 = {
      type = 101,
      data = 91002,
      talkId = 150122,
      param = 0,
      des = "回复#<Y,>双锤天将#"
    }
  },
  [60086] = {
    mnName = "误事的天王",
    missionDes = "负责看守锁妖塔的丁力天王因为醉酒误事，使得锁妖塔中一些妖物乘机逃入人间。紫霞仙子要你找到丁力天王，好好教训他一番，要让他为此事负上全部责任。",
    acceptDes = "与#<Y,>紫霞仙子#对话",
    needCmp = {11121, 60085},
    startNpc = 90907,
    acceptTalkId = 150131,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
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
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [60087] = {
    mnName = "误事的天王",
    missionDes = "负责看守锁妖塔的丁力天王因为醉酒误事，使得锁妖塔中一些妖物乘机逃入人间。紫霞仙子要你找到丁力天王，好好教训他一番，要让他为此事负上全部责任。",
    acceptDes = "找到#<Y,>丁力天王#",
    needCmp = {60086},
    startNpc = 91003,
    acceptTalkId = 150132,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        11,
        9,
        true
      },
      talkId = 0,
      param = 0,
      des = "打醒喝醉的#<Y,>丁力天王#"
    },
    dst2 = {
      type = 101,
      data = 91003,
      talkId = 150133,
      param = 0,
      des = "告知#<Y,>丁力天王#妖兽逃跑的事"
    }
  },
  [60088] = {
    mnName = "监守自盗",
    missionDes = "双锤天将告诉你，企图霸占蟠桃园的是一群有组织，有计划的犯罪团伙。这群人除了听命于巨灵神，还以武仙大力鬼王为首是瞻。双锤天将希望你将此祸害铲除，以正视听。",
    acceptDes = "与#<Y,>双锤天将#对话",
    needCmp = {11129, 60087},
    startNpc = 91002,
    acceptTalkId = 150141,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        11,
        12,
        true
      },
      talkId = 0,
      param = 0,
      des = "前往蟠桃园打败#<Y,>大力鬼王#"
    },
    dst2 = {
      type = 101,
      data = 91002,
      talkId = 150142,
      param = 0,
      des = "向#<Y,>双锤天将#复命"
    }
  },
  [60089] = {
    mnName = "闪电之神",
    missionDes = "雷公、电母知道自己被无天魔罗控制所犯下的事后，就一直处于浑噩的状态，连日常里施雷布电都不曾参与，这可把紫霞仙子急死。紫霞仙子希望你能好好敲打一下雷公、电母，让他们知道身为仙人，有义务为凡间履行一份该有的责任。",
    acceptDes = "与#<Y,>紫霞仙子#对话",
    needCmp = {11136, 60088},
    startNpc = 90907,
    acceptTalkId = 150151,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        11,
        15,
        true
      },
      talkId = 0,
      param = 0,
      des = "教训#<Y,>雷公#、#<Y,>电母#二人"
    },
    dst2 = {
      type = 101,
      data = 90907,
      talkId = 150152,
      param = 0,
      des = "回复#<Y,>紫霞仙子#"
    }
  },
  [60090] = {
    mnName = "解救太白",
    missionDes = "太白金星为了诱敌深入，甘做被无天魔罗控制的爪牙。如何解除太白金星身上的控制成了紫霞仙子头痛的事情。紫霞仙子要你去找镇元大仙想办法。",
    acceptDes = "与#<Y,>紫霞仙子#对话",
    needCmp = {60089},
    startNpc = 90907,
    acceptTalkId = 150161,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
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
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [60091] = {
    mnName = "解救太白",
    missionDes = "“想要解除太白金星身上的控制，只需打败他心脏中一滴无天魔罗的精血即可”这是镇元大仙告诉你的办法。",
    acceptDes = "向#<Y,>镇元大仙#寻得求助",
    needCmp = {11142, 60090},
    startNpc = 90903,
    acceptTalkId = 150162,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        11,
        19,
        true
      },
      talkId = 0,
      param = 0,
      des = "帮助太白#<Y,>解除禁制#"
    },
    dst2 = {
      type = 101,
      data = 90977,
      talkId = 150163,
      param = 0,
      des = "将发生的事情告知#<Y,>太白金星#"
    }
  },
  [60092] = {
    mnName = "瓮中捉鳖",
    missionDes = "拖延计划被扰乱，这让获救后的太白金星狠狠的痛斥了你胡闹的行为。事已至此，不得不重新改变计划。太白金星希望你去兜率宫消灭无天魔罗的分身，来个瓮中捉鳖。",
    acceptDes = "与#<Y,>太白金星#对话",
    needCmp = {11147, 60091},
    startNpc = 90977,
    acceptTalkId = 150171,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
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
      type = 0,
      data = 0,
      talkId = 0,
      param = 0,
      des = "0"
    }
  },
  [60093] = {
    mnName = "瓮中捉鳖",
    missionDes = "拖延计划被扰乱，这让获救后的太白金星狠狠的痛斥了你胡闹的行为。事已至此，不得不重新改变计划。太白金星希望你去兜率宫消灭无天魔罗的分身，来个瓮中捉鳖。",
    acceptDes = "继续与#<Y,>太白金星#交谈",
    needCmp = {60092},
    startNpc = 90977,
    acceptTalkId = 150172,
    zs = 4,
    lv = 300,
    rewardCoin = 0,
    rewardGold = 0,
    rewardExp = 0,
    HelpWinAwardXiaYi = 0,
    HelpLostAwardXiaYi = 0,
    rewardObj = {},
    dst1 = {
      type = 201,
      data = {
        11,
        22,
        true
      },
      talkId = 0,
      param = 0,
      des = "前往兜率宫消灭#<Y,>无天魔罗分身#"
    },
    dst2 = {
      type = 101,
      data = 90977,
      talkId = 150173,
      param = 0,
      des = "向#<Y,>太白金星#复命"
    }
  }
}

local data_mail_mail = {
  [1] = {
    id = 1,
    type = 1,
    title = "竞技场防守胜利",
    content = "%s<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">在竞技场挑战你，但被你轻松击败了。</font>",
    battleType = 1,
    nothing = "玩家{%s}在竞技场挑战你，但被你轻松击败了"
  },
  [2] = {
    id = 2,
    type = 1,
    title = "竞技场防守失败",
    content = "%s<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">在竞技场轻松击败了你，你的竞技场排名降至第</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#4eff00\">%s</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">名。</font>",
    battleType = 1,
    nothing = "玩家{%s}在竞技场轻松击败了你，你的竞技场排名降至{%s}"
  },
  [3] = {
    id = 3,
    type = 1,
    title = "竞技场防守失败",
    content = "%s<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">在竞技场轻松击败了你，你的竞技场排名无变化。</font>",
    battleType = 1,
    nothing = "玩家{%s}在竞技场轻松击败了你，你的竞技场排名无变化。"
  },
  [4] = {
    id = 4,
    type = 3,
    title = "竞技场排名奖励",
    content = "<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">恭喜您在</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f7e461\">%s</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">的竞技场中取得了第</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#4eff00\">%s</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">名的成绩，获得奖励</font>%s%s",
    battleType = 0,
    nothing = "恭喜您在{%s}的竞技场中取得了第{%s}名的成绩，获得奖励{%s}{%s}"
  },
  [5] = {
    id = 5,
    type = 1,
    title = "宝物碎片被夺",
    content = "%s<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">抢夺了你的《</font>%s<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">》</font>",
    battleType = 2,
    nothing = "玩家{%s}抢夺了你的《{%s}"
  },
  [6] = {
    id = 6,
    type = 2,
    title = "申请好友",
    content = "%s<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">与您志趣相投，惺惺相惜，欲邀您携手共闯江湖。</font>",
    battleType = 0,
    nothing = "玩家{%s}与您志趣相投，惺惺相惜，欲邀您携手共闯江湖。"
  },
  [7] = {
    id = 7,
    type = 2,
    title = "好友留言",
    content = "%s<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">:</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f7e461\">%s</font>",
    battleType = 0,
    nothing = "{%s}:{%s}"
  },
  [8] = {
    id = 8,
    type = 1,
    title = "好友切磋",
    content = "<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">好友</font>%s<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">与你切磋武技，被你轻松击败。</font>",
    battleType = 0,
    nothing = "好友{%s}与你切磋武技，被你轻松击败"
  },
  [9] = {
    id = 9,
    type = 1,
    title = "好友切磋",
    content = "<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">好友</font>%s<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">与你切磋武技，你不慎落败。</font>",
    battleType = 0,
    nothing = "好友{%s}与你切磋武技，你不慎落败"
  },
  [10] = {
    id = 10,
    type = 2,
    title = "好友断交",
    content = "<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">好友</font>%s<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">与你志趣不和，与您割袍断意，分道扬镳。</font>",
    battleType = 0,
    nothing = "好友{%s}与你志趣不和，与您割袍断意，分道扬镳。"
  },
  [11] = {
    id = 11,
    type = 3,
    title = "入帮申请通过",
    content = "<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">%s同意了你的入帮申请。</font>",
    battleType = 0,
    nothing = "{%s}同意了你的入帮申请"
  },
  [12] = {
    id = 12,
    type = 3,
    title = "入帮申请被拒绝",
    content = "<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">%s拒绝了你的入帮申请。</font>",
    battleType = 0,
    nothing = "{%s}拒绝了你的入帮申请"
  },
  [13] = {
    id = 13,
    type = 3,
    title = "被请离帮派",
    content = "%s<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">将你请离了帮派。</font>",
    battleType = 0,
    nothing = "{%s}将你请离了帮派"
  },
  [14] = {
    id = 14,
    type = 1,
    title = "比武防守胜利",
    content = "%s<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">在比武场挑战你，但被你轻松击败了。</font>",
    battleType = 3,
    nothing = "玩家{%s}在比武场挑战你，但被你轻松击败了"
  },
  [15] = {
    id = 15,
    type = 1,
    title = "比武防守失败",
    content = "%s<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">在比武中轻松击败了你，你的排名为</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#4eff00\">%s</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">，积分减少</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#4eff00\">%s</font>",
    battleType = 3,
    nothing = "玩家{%s}在比武中轻松击败了你，你的排名变为{%s}，比武积分减少{%s}"
  },
  [16] = {
    id = 16,
    type = 1,
    title = "复仇防守胜利",
    content = "%s<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">对你发起了复仇，但被你轻松击败了。</font>",
    battleType = 3,
    nothing = "玩家{%s}对你发起了复仇，但被你轻松击败了"
  },
  [17] = {
    id = 17,
    type = 1,
    title = "复仇防守失败",
    content = "%s<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">在复仇中轻松击败了你，你的排名为</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#4eff00\">%s</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">，积分减少</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#4eff00\">%s</font>",
    battleType = 3,
    nothing = "玩家{%s}在在复仇中轻松击败了你，你的排名变为{%s}，比武积分减少{%s}"
  },
  [18] = {
    id = 18,
    type = 1,
    title = "天榜防守胜利",
    content = "%s<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">对你发起了天榜挑战，但被你轻松击败了。</font>",
    battleType = 3,
    nothing = "玩家{%s}对你发起了天榜挑战，但被你轻松击败了"
  },
  [19] = {
    id = 19,
    type = 1,
    title = "天榜防守失败",
    content = "%s<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">在天榜挑战中轻松击败了你，你的排名为第</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#4eff00\">%s</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">名。</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">你的比武积分减少</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#4eff00\">%s</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">。</font>",
    battleType = 3,
    nothing = "玩家{%s}在天榜挑战中轻松击败了你，你的排名为第{%s}。你的比武积分减少{%s}。"
  },
  [20] = {
    id = 20,
    type = 3,
    title = "比武排名奖励",
    content = "<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">恭喜您在</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f7e461\">%s</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">的比武中取得了第</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#4eff00\">%s</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">名的成绩，获得奖励</font>%s%s%s",
    battleType = 0,
    nothing = "恭喜您在{%s}的比武中取得了第{%s}名的成绩，获得奖励{%s}{%s}{%s}"
  },
  [21] = {
    id = 21,
    type = 3,
    title = "系统邮件",
    content = "<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f7e461\">%s</font>",
    battleType = 0,
    nothing = "随意填写，后台发送的邮件"
  },
  [22] = {
    id = 22,
    type = 1,
    title = "劫镖防守成功",
    content = "%s<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">妄图截镖，被你赶走了。</font>",
    battleType = 0,
    nothing = "%s妄图截镖，被你赶走了"
  },
  [23] = {
    id = 23,
    type = 1,
    title = "镖车被劫",
    content = "%s<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">截了你的镖车，损失一部分奖励。</font>",
    battleType = 0,
    nothing = "%s截了你的镖车，损失一部分奖励"
  },
  [24] = {
    id = 24,
    type = 3,
    title = "限时豪杰排名奖励",
    content = "<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">恭喜您在</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f7e461\">限时豪杰%s</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">活动中积分排名第</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#4eff00\">%s名</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\"><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">，请前往首页中领奖中心领取排名奖励。</font>",
    battleType = 0,
    nothing = "恭喜您在限时豪杰{%s}活动中积分排名第{%s}名，请前往首页中领奖中心领取排名奖励。"
  },
  [25] = {
    id = 25,
    type = 3,
    title = "限时豪杰积分奖励",
    content = "<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">恭喜您在</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f7e461\">限时豪杰%s</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">活动中积分达到了</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#4eff00\">%s</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">，获得奖励%s%s%s<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">，请前往首页中领奖中心领取积分奖励。</font>",
    battleType = 0,
    nothing = "恭喜您在限时豪杰{%s}活动中积分达到了{%s}，获得奖励{%s}{%s}{%s}，请前往首页中领奖中心领取积分奖励。"
  },
  [26] = {
    id = 26,
    type = 2,
    title = "切磋胜利",
    content = "%s<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">与你切磋武艺，被你轻松击败。</font>",
    battleType = 0,
    nothing = "%s与你切磋武艺，被你轻松击败。"
  },
  [27] = {
    id = 27,
    type = 2,
    title = "切磋失败",
    content = "%s<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">与你切磋武艺，将你轻松击败。</font>",
    battleType = 0,
    nothing = "%s与你切磋武艺，将你轻松击败。"
  },
  [28] = {
    id = 28,
    type = 3,
    title = "自荐帮主",
    content = "<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde\">帮主自荐结束，%s通过自荐成为了新的帮主</font>",
    battleType = 0,
    nothing = "帮主自荐结束，%s通过自荐成为了新的帮主"
  },
  [29] = {
    id = 29,
    type = 3,
    title = "青龙挑战自动开启",
    content = "<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#3ad149\">%s</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde1\">已设定了青龙挑战的自动开启时间为每天</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#ee0ccd\">%s</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde1\">，请您准时上线参与</font>",
    battleType = 0,
    nothing = "xx已设定了青龙挑战的自动开启时间为每天 hh:mm:ss，请您准时上线参与"
  },
  [30] = {
    id = 30,
    type = 3,
    title = "烧烤大会自动开启",
    content = "<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#3ad149\">%s</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde1\">已设定了烧烤大会的自动开启时间为每天</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#ee0ccd\">%s</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde1\">，请您准时上线参与</font>",
    battleType = 0,
    nothing = "xx已设定了帮派烧烤的自动开启时间为每天 #v1#，请您准时上线参与"
  },
  [31] = {
    id = 31,
    type = 3,
    title = "取消自动开启",
    content = "<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#3ad149\">%s</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde1\">取消了自动开启青龙挑战</font>",
    battleType = 0,
    nothing = "xx取消了自动开启青龙挑战"
  },
  [32] = {
    id = 32,
    type = 3,
    title = "取消自动开启",
    content = "<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#3ad149\">%s</font><font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#f6edde1\">取消了自动开启烧烤大会</font>",
    battleType = 0,
    nothing = "xx取消了自动开启帮派烧烤"
  }
}
return data_mail_mail

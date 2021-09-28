

---@classdef record_notice_info
local record_notice_info = {}
  
record_notice_info.id = 0 --编号  
record_notice_info.comment = "" --文字


notice_info = {
   _data = {
    [1] = {1,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#name#' /><text color='16709336' value='吉星高照，成功在' /><text color='15890701' value='#num2#' /><text color='16709336' value='招募中招到武将' /><text value='#num3#' /><text color='16709336' value='，可喜可贺！' /></root>",},
    [2] = {2,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#name#' /><text color='16709336' value='豪气万千，在' /><text  color='15890701' value='竞技场' /><text color='16709336' value='踏过千军万马，勇拔头筹！' /></root>",},
    [3] = {3,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#name#' /><text color='16709336' value='经过千锤百炼，成功将' /><text value='#num2#' /><text color='16709336' value='突破至' /><text color='15890701' value='+' /><text color='15890701' value='#num3#' /><text color='16709336' value='，实力大增！' /></root>",},
    [4] = {4,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#name#' /><text color='16709336' value='势如破竹，在' /><text  color='15890701' value='三国无双' /><text color='16709336' value='中一路闯至' /><text color='15890701' value='#num2#' /><text color='16709336' value='层，所向披靡！' /></root>",},
    [5] = {5,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#name#' /><text color='16709336' value='实力超群，在' /><text  color='15890701' value='主线副本' /><text color='16709336' value='积累' /><text  color='15890701' value='#num2#' /><text color='16709336' value='星数，令人敬仰！' /></root>",},
    [6] = {6,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#name#' /><text color='16709336' value='寻寻觅觅，终于在' /><text  color='15890701' value='名将副本' /><text color='16709336' value='中集齐所有三国志残片，真是厉害！' /></root>",},
    [7] = {7,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#name#' /><text color='16709336' value='在' /><text  color='15890701' value='领地攻讨' /><text color='16709336' value='巡逻时人品爆发，获得了' /><text  value='#num2#' /><text color='16709336' value='，撞大运了！' /></root>",},
    [8] = {8,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#name#' /><text color='16709336' value='在' /><text  color='15890701' value='幸运轮盘' /><text color='16709336' value='游戏中人品爆发，抽中' /><text color='#colGood#' value='#num#' /><text color='#colGood#' value='×' /><text color='#colGood#' value='#size#' /><text color='16709336' value='，让人羡慕嫉妒恨！' /></root>",},
    [9] = {9,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#name#' /><text color='16709336' value='在' /><text  color='15890701' value='豪华轮盘' /><text color='16709336' value='游戏中人品爆发，抽中' /><text color='#colGood#' value='#num#' /><text color='#colGood#' value='×' /><text color='#colGood#' value='#size#' /><text color='16709336' value='，让人羡慕嫉妒恨！' /></root>",},
    [10] = {10,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#name#' /><text color='16709336' value='在' /><text  color='15890701' value='幸运轮盘' /><text color='16709336' value='游戏中人品爆发，抽中' /><text  color='16771584' value='元宝' /><text color='16771584' value='×' /><text color='16771584' value='#size#' /><text color='16709336' value='，让人羡慕嫉妒恨！' /></root>",},
    [11] = {11,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#name#' /><text color='16709336' value='在' /><text  color='15890701' value='豪华轮盘' /><text color='16709336' value='游戏中人品爆发，抽中' /><text  color='16771584' value='元宝' /><text color='16771584' value='×' /><text color='16771584' value='#size#' /><text color='16709336' value='，让人羡慕嫉妒恨！' /></root>",},
    [12] = {12,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#name#' /><text color='16709336' value='在' /><text  color='15890701' value='巡游探宝' /><text color='16709336' value='中与红将惺惺相惜，红将欣然赠与' /><text color='#colGood#'  value='#name1#' /><text color='16709336' value='，让人羡慕嫉妒恨！' /></root>",},
    [13] = {13,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#name#' /><text color='16709336' value='击杀了精英副本' /><text  color='15890701' value='【#chapter_name#】' /><text color='16709336' value='的暴动BOSS' /><text color='#col1#' value='【#monster_name#】' /><text color='16709336' value='，获得了巨额宝藏！' /></root>",},
    [14] = {14,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#name1#' /><text color='16709336' value='攻进玩家' /><text color='#col1#' value='#name2#' /><text color='16709336' value='的粮仓,一举掠夺' /><text  color='15890701' value='#num#' /><text color='16709336' value='粮草！' /></root>",},
    [15] = {15,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='紫色武将之魂' /><text color='16709336' value='，获得了紫色武将' /><text value='#num2#' /><text color='16709336' value='！' /></root>",},
    [16] = {16,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='橙色武将之魂' /><text color='16709336' value='，获得了橙色武将' /><text value='#num2#' /><text color='16709336' value='！' /></root>",},
    [17] = {17,"<root><text color='16709336' value='哇！玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='天命石礼盒' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！这人品！上辈子肯定是雷锋！' /></root>",},
    [18] = {18,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='VIP0超值礼包' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！绝对良心游戏！' /></root>",},
    [19] = {19,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='VIP1超值礼包' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！好超值哦！' /></root>",},
    [20] = {20,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='VIP2超值礼包' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！好超值哦！' /></root>",},
    [21] = {21,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='VIP3超值礼包' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！好超值哦！' /></root>",},
    [22] = {22,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='VIP4超值礼包' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！好超值哦！' /></root>",},
    [23] = {23,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='VIP5超值礼包' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！礼物拿得手软哦！' /></root>",},
    [24] = {24,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='VIP6超值礼包' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！礼物拿得手软哦！' /></root>",},
    [25] = {25,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='VIP7超值礼包' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！礼物拿得手软哦！' /></root>",},
    [26] = {26,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='VIP8超值礼包' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！礼物拿得手软哦！' /></root>",},
    [27] = {27,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='VIP9超值礼包' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！礼物拿得手软哦！' /></root>",},
    [28] = {28,"<root><text color='16709336' value='土豪' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='VIP10超值礼包' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！不小心暴露了高富帅气质，惹来众人围观！' /></root>",},
    [29] = {29,"<root><text color='16709336' value='土豪' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='VIP11超值礼包' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！不小心暴露了高富帅气质，惹来众人围观！' /></root>",},
    [30] = {30,"<root><text color='16709336' value='神豪' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='VIP12超值礼包' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！不小心暴露了高富帅气质，惹来众人围观！' /></root>",},
    [31] = {31,"<root><text color='16709336' value='哇！玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='高级精炼石礼盒' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！这人品！上辈子肯定是雷锋！' /></root>",},
    [32] = {32,"<root><text color='16709336' value='哇！玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='宝物精炼石礼盒' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！这人品！上辈子肯定是雷锋！' /></root>",},
    [33] = {33,"<root><text color='16709336' value='哇！玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='觉醒丹礼盒' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！这人品！上辈子肯定是雷锋！' /></root>",},
    [34] = {34,"<root><text color='16709336' value='哇！玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='觉醒道具箱' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！这人品！上辈子肯定是雷锋！' /></root>",},
    [35] = {35,"<root><text color='16709336' value='哇！玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='紫将合击礼包' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！这人品！上辈子肯定是雷锋！' /></root>",},
    [36] = {36,"<root><text color='16709336' value='哇！玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='小型银两箱' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！这人品！上辈子肯定是雷锋！' /></root>",},
    [37] = {37,"<root><text color='16709336' value='哇！玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='中型银两箱' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！这人品！上辈子肯定是雷锋！' /></root>",},
    [38] = {38,"<root><text color='16709336' value='哇！玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='大型银两箱' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！这人品！上辈子肯定是雷锋！' /></root>",},
    [39] = {39,"<root><text color='16709336' value='哇！玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='黄金经验宝物礼盒' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！这人品！上辈子肯定是雷锋！' /></root>",},
    [40] = {40,"<root><text color='16709336' value='哇！玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='极品精炼石礼盒' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！这人品！上辈子肯定是雷锋！' /></root>",},
    [41] = {41,"<root><text color='16709336' value='土豪' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='红色宝物礼包' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！不小心暴露了高富帅气质，惹来众人围观！' /></root>",},
    [42] = {42,"<root><text color='16709336' value='神豪' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='荀彧时装宝箱' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！不小心暴露了高富帅气质，惹来众人围观！' /></root>",},
    [43] = {43,"<root><text color='16709336' value='神豪' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='诸葛亮时装宝箱' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！不小心暴露了高富帅气质，惹来众人围观！' /></root>",},
    [44] = {44,"<root><text color='16709336' value='神豪' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='孙坚时装宝箱' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！不小心暴露了高富帅气质，惹来众人围观！' /></root>",},
    [45] = {45,"<root><text color='16709336' value='神豪' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='吕布时装宝箱' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！不小心暴露了高富帅气质，惹来众人围观！' /></root>",},
    [46] = {46,"<root><text color='16709336' value='哇！玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='橙色装备箱子' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！这人品！上辈子肯定是雷锋！' /></root>",},
    [47] = {47,"<root><text color='16709336' value='土豪' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='觉醒道具箱-橙' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！不小心暴露了高富帅气质，惹来众人围观！' /></root>",},
    [48] = {48,"<root><text color='16709336' value='神豪' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='觉醒道具箱-红' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！不小心暴露了高富帅气质，惹来众人围观！' /></root>",},
    [49] = {49,"<root><text color='16709336' value='哇！玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='红色装备箱子' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！这人品！上辈子肯定是雷锋！' /></root>",},
    [50] = {50,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='争霸赛第1名宝箱' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！这就是战神的分量！' /></root>",},
    [51] = {51,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='争霸赛第2名宝箱' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！这就是战神的分量！' /></root>",},
    [52] = {52,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='争霸赛第3名宝箱' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！这就是战神的分量！' /></root>",},
    [53] = {53,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='争霸赛第4-10名宝箱' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！胜利的喜悦！' /></root>",},
    [54] = {54,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='争霸赛第11-25名宝箱' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！胜利的喜悦！' /></root>",},
    [55] = {55,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='争霸赛第26-50名宝箱' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！胜利的喜悦！' /></root>",},
    [56] = {56,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='叛军BOSS第一军团礼包' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！所以说军团一定要组织打叛军哦！' /></root>",},
    [57] = {57,"<root><text color='16709336' value='哇！玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='高级精炼箱' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！这人品！上辈子肯定是雷锋！' /></root>",},
    [58] = {58,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用了首次充值赠送的' /><text color='15890701' value='5元红包' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='从此走上高富帅的道路！！' /></root>",},
    [59] = {59,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用了首次充值赠送的' /><text color='15890701' value='10元红包' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='从此走上高富帅的道路！！' /></root>",},
    [60] = {60,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用了首次充值赠送的' /><text color='15890701' value='20元红包' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='从此走上高富帅的道路！！' /></root>",},
    [61] = {61,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用了首次充值赠送的' /><text color='15890701' value='30元红包' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='从此走上高富帅的道路！！' /></root>",},
    [62] = {62,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用了首次充值赠送的' /><text color='15890701' value='50元红包' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='从此走上高富帅的道路！！' /></root>",},
    [63] = {63,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用了首次充值赠送的' /><text color='15890701' value='98元红包' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='从此走上高富帅的道路！！' /></root>",},
    [64] = {64,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用了首次充值赠送的' /><text color='15890701' value='228元红包' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='从此走上高富帅的道路！！' /></root>",},
    [65] = {65,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用了首次充值赠送的' /><text color='15890701' value='328元红包' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='从此走上高富帅的道路！！' /></root>",},
    [66] = {66,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用了首次充值赠送的' /><text color='15890701' value='998元红包' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='从此走上高富帅的道路！！' /></root>",},
    [67] = {67,"<root><text color='16709336' value='哇！玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='月满中秋礼盒' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！这人品！上辈子肯定是雷锋！' /></root>",},
    [68] = {68,"<root><text color='16709336' value='哇！玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='国庆神将礼盒' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！这人品！上辈子肯定是雷锋！' /></root>",},
    [69] = {69,"<root><text color='16709336' value='哇！玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='国庆神兵礼盒' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！这人品！上辈子肯定是雷锋！' /></root>",},
    [70] = {70,"<root><text color='16709336' value='哇！玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='国庆战宠礼盒' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！这人品！上辈子肯定是雷锋！' /></root>",},
    [71] = {71,"<root><text color='16709336' value='哇！玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='重阳神兵礼盒' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！这人品！上辈子肯定是雷锋！' /></root>",},
    [72] = {72,"<root><text color='16709336' value='哇！玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='万圣神秘礼包' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！这人品！上辈子肯定是雷锋！' /></root>",},
    [73] = {73,"<root><text color='16709336' value='哇！玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='双11礼包' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！这人品！上辈子肯定是雷锋！' /></root>",},
    [74] = {74,"<root><text color='16709336' value='哇！玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='感恩节礼包' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！这人品！上辈子肯定是雷锋！' /></root>",},
    [75] = {75,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#name#' /><text color='16709336' value='受将灵护佑，成功在' /><text color='15890701' value='点将台' /><text color='16709336' value='中招募到' /><text value='#num1#' /><text color='16709336' value='，可喜可贺！' /></root>",},
    [76] = {76,"<root><text color='16709336' value='玩家' /><text color='#col#' value='#name#' /><text color='16709336' value='在' /><text color='15890701' value='名将试炼' /><text color='16709336' value='通过' /><text color='15890701' value='#dungeon_name#' /><text color='16709336' value='考验，获得' /><text value='#num3#' /></root>",},
    [77] = {77,"<root><text color='16709336' value='哇！玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='普通唤灵石' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！羡煞众人！' /></root>",},
    [78] = {78,"<root><text color='16709336' value='哇！玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='高级唤灵石' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！羡煞众人！' /></root>",},
    [79] = {79,"<root><text color='16709336' value='哇！玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='解封' /><text color='15890701' value='橙色将灵密匣' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！灵阵图可以再进一步了！' /></root>",},
    [80] = {80,"<root><text color='16709336' value='哇！玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='解封' /><text color='15890701' value='红色将灵密匣石' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！灵阵图可以再进一步了！' /></root>",},
    [81] = {81,"<root><text color='16709336' value='哇！玩家' /><text color='#col#' value='#num1#' /><text color='16709336' value='使用' /><text color='15890701' value='双12礼包' /><text color='16709336' value='，获得了' /><text value='#num2#' /><text color='16709336' value='！这人品！上辈子肯定是雷锋！' /></root>",},
    }
}



local __index_id = {
    [1] = 1,
    [10] = 10,
    [11] = 11,
    [12] = 12,
    [13] = 13,
    [14] = 14,
    [15] = 15,
    [16] = 16,
    [17] = 17,
    [18] = 18,
    [19] = 19,
    [2] = 2,
    [20] = 20,
    [21] = 21,
    [22] = 22,
    [23] = 23,
    [24] = 24,
    [25] = 25,
    [26] = 26,
    [27] = 27,
    [28] = 28,
    [29] = 29,
    [3] = 3,
    [30] = 30,
    [31] = 31,
    [32] = 32,
    [33] = 33,
    [34] = 34,
    [35] = 35,
    [36] = 36,
    [37] = 37,
    [38] = 38,
    [39] = 39,
    [4] = 4,
    [40] = 40,
    [41] = 41,
    [42] = 42,
    [43] = 43,
    [44] = 44,
    [45] = 45,
    [46] = 46,
    [47] = 47,
    [48] = 48,
    [49] = 49,
    [5] = 5,
    [50] = 50,
    [51] = 51,
    [52] = 52,
    [53] = 53,
    [54] = 54,
    [55] = 55,
    [56] = 56,
    [57] = 57,
    [58] = 58,
    [59] = 59,
    [6] = 6,
    [60] = 60,
    [61] = 61,
    [62] = 62,
    [63] = 63,
    [64] = 64,
    [65] = 65,
    [66] = 66,
    [67] = 67,
    [68] = 68,
    [69] = 69,
    [7] = 7,
    [70] = 70,
    [71] = 71,
    [72] = 72,
    [73] = 73,
    [74] = 74,
    [75] = 75,
    [76] = 76,
    [77] = 77,
    [78] = 78,
    [79] = 79,
    [8] = 8,
    [80] = 80,
    [81] = 81,
    [9] = 9,

}

local __key_map = {
  id = 1,
  comment = 2,

}



local m = { 
    __index = function(t, k) 
        if k == "toObject" then
            return function()  
                local o = {}
                for key, v in pairs (__key_map) do 
                    o[key] = t._raw[v]
                end
                return o
            end 
        end
        
        assert(__key_map[k], "cannot find " .. k .. " in record_notice_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function notice_info.getLength()
    return #notice_info._data
end



function notice_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_notice_info
function notice_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = notice_info._data[index]}, m)
    
end

---
--@return @class record_notice_info
function notice_info.get(id)
    
    return notice_info.indexOf(__index_id[id])
        
end



function notice_info.set(id, key, value)
    local record = notice_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function notice_info.get_index_data()
    return __index_id
end
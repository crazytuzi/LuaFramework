_G.Msg = 
{
    --/** AUTO_CODE_BEGIN_Protocol **************** don't touch this line ********************/
    --/** =============================== 自动生成的代码 =============================== **/

    --------------------------------------------------------
    -- 1 - 500 ( 预留 ) 
    --------------------------------------------------------

    --------------------------------------------------------
    -- 501 - 1000 ( 系统 ) 
    --------------------------------------------------------
    -- [501]角色心跳 -- 系统 
    REQ_SYSTEM_HEART                 = 501,[501] = "REQ_SYSTEM_HEART", 
    -- [502]服务器将断开连接 -- 系统 
    ACK_SYSTEM_DISCONNECT            = 502,[502] = "ACK_SYSTEM_DISCONNECT", 
    -- [510]时间校正 -- 系统 
    ACK_SYSTEM_TIME                  = 510,[510] = "ACK_SYSTEM_TIME", 
    -- [520]GM修改服务器时间 -- 系统 
    ACK_SYSTEM_TIME_GM               = 520,[520] = "ACK_SYSTEM_TIME_GM", 
    -- [700]错误代码 -- 系统 
    ACK_SYSTEM_ERROR                 = 700,[700] = "ACK_SYSTEM_ERROR", 
    -- [800]系统通知 -- 系统 
    ACK_SYSTEM_NOTICE                = 800,[800] = "ACK_SYSTEM_NOTICE", 
    -- [810]游戏广播 -- 系统 
    ACK_SYSTEM_BROADCAST             = 810,[810] = "ACK_SYSTEM_BROADCAST", 
    -- [811]广播信息块 -- 系统 
    ACK_SYSTEM_DATA_XXX              = 811,[811] = "ACK_SYSTEM_DATA_XXX", 
    -- [820]游戏提示 -- 系统 
    ACK_SYSTEM_TIPS                  = 820,[820] = "ACK_SYSTEM_TIPS", 
    -- [830]查询是否可充值 -- 系统 
    REQ_SYSTEM_PAY_CHECK             = 830,[830] = "REQ_SYSTEM_PAY_CHECK", 
    -- [840]充值查询结果返回 -- 系统 
    ACK_SYSTEM_PAY_STATE             = 840,[840] = "ACK_SYSTEM_PAY_STATE", 
    -- [850]系统活动限时开放 -- 系统 
    ACK_SYSTEM_ACTIVE_OPEN           = 850,[850] = "ACK_SYSTEM_ACTIVE_OPEN", 

    --------------------------------------------------------
    -- 1001 - 2000 ( 角色 ) 
    --------------------------------------------------------
    -- [1010]角色登录 -- 角色 
    REQ_ROLE_LOGIN                   = 1010,[1010] = "REQ_ROLE_LOGIN", 
    -- [1012]断线重连返回 -- 角色 
    ACK_ROLE_LOGIN_AG_ERR            = 1012,[1012] = "ACK_ROLE_LOGIN_AG_ERR", 
    -- [1020]创建角色 -- 角色 
    REQ_ROLE_CREATE                  = 1020,[1020] = "REQ_ROLE_CREATE", 
    -- [1021]创建/登录(有角色)成功 -- 角色 
    ACK_ROLE_LOGIN_OK_HAVE           = 1021,[1021] = "ACK_ROLE_LOGIN_OK_HAVE", 
    -- [1022]货币 -- 角色 
    ACK_ROLE_CURRENCY                = 1022,[1022] = "ACK_ROLE_CURRENCY", 
    -- [1023]登录成功(没有角色) -- 角色 
    ACK_ROLE_LOGIN_OK_NO_ROLE        = 1023,[1023] = "ACK_ROLE_LOGIN_OK_NO_ROLE", 
    -- [1024]请求随机名字 -- 角色 
    REQ_ROLE_RAND_NAME               = 1024,[1024] = "REQ_ROLE_RAND_NAME", 
    -- [1025]返回名字 -- 角色 
    ACK_ROLE_NAME                    = 1025,[1025] = "ACK_ROLE_NAME", 
    -- [1026]角色创建时间 -- 角色 
    ACK_ROLE_CREATE_TIME             = 1026,[1026] = "ACK_ROLE_CREATE_TIME", 
    -- [1027]角色生一级消耗时间 -- 角色 
    ACK_ROLE_TIME_USE                = 1027,[1027] = "ACK_ROLE_TIME_USE", 
    -- [1030]登录失败 -- 角色 
    ACK_ROLE_LOGIN_FAIL              = 1030,[1030] = "ACK_ROLE_LOGIN_FAIL", 
    -- [1050]创建失败 -- 角色 
    ACK_ROLE_CREATE_FAIL             = 1050,[1050] = "ACK_ROLE_CREATE_FAIL", 
    -- [1060]销毁角色 -- 角色 
    REQ_ROLE_DEL                     = 1060,[1060] = "REQ_ROLE_DEL", 
    -- [1061]销毁角色(成功) -- 角色 
    ACK_ROLE_DEL_OK                  = 1061,[1061] = "ACK_ROLE_DEL_OK", 
    -- [1063]销毁角色(失败) -- 角色 
    ACK_ROLE_DEL_FAIL                = 1063,[1063] = "ACK_ROLE_DEL_FAIL", 
    -- [1070]角色转职 -- 角色 
    REQ_ROLE_PRO_CHANGE              = 1070,[1070] = "REQ_ROLE_PRO_CHANGE", 
    -- [1075]转职成功 -- 角色 
    ACK_ROLE_CHANGE_PRO_REPLY        = 1075,[1075] = "ACK_ROLE_CHANGE_PRO_REPLY", 
    -- [1101]请求玩家属性 -- 角色 
    REQ_ROLE_PROPERTY                = 1101,[1101] = "REQ_ROLE_PROPERTY", 
    -- [1107]玩家属性(查看其它玩家专用) -- 角色 
    ACK_ROLE_PROPERTY_REVE2          = 1107,[1107] = "ACK_ROLE_PROPERTY_REVE2", 
    -- [1108]玩家属性 -- 角色 
    ACK_ROLE_PROPERTY_REVE           = 1108,[1108] = "ACK_ROLE_PROPERTY_REVE", 
    -- [1109]伙伴属性 -- 角色 
    ACK_ROLE_PARTNER_DATA            = 1109,[1109] = "ACK_ROLE_PARTNER_DATA", 
    -- [1110]称号信息块 -- 角色 
    ACK_ROLE_TITLE_MSG               = 1110,[1110] = "ACK_ROLE_TITLE_MSG", 
    -- [1111]神器信息块 -- 角色 
    ACK_ROLE_MAGIC_MSG               = 1111,[1111] = "ACK_ROLE_MAGIC_MSG", 
    -- [1115]请求玩家排名更新 -- 角色 
    REQ_ROLE_RANK_UPDATE             = 1115,[1115] = "REQ_ROLE_RANK_UPDATE", 
    -- [1121]请求玩家扩展属性(暂无效) -- 角色 
    REQ_ROLE_PROPERTY_EXT            = 1121,[1121] = "REQ_ROLE_PROPERTY_EXT", 
    -- [1128]玩家扩展属性(暂无效) -- 角色 
    ACK_ROLE_PROPERTY_EXT_R          = 1128,[1128] = "ACK_ROLE_PROPERTY_EXT_R", 
    -- [1130]玩家单个属性更新 -- 角色 
    ACK_ROLE_PROPERTY_UPDATE         = 1130,[1130] = "ACK_ROLE_PROPERTY_UPDATE", 
    -- [1131]玩家单个属性更新[字符串] -- 角色 
    ACK_ROLE_PROPERTY_UPDATE2        = 1131,[1131] = "ACK_ROLE_PROPERTY_UPDATE2", 
    -- [1140]请求NPC -- 角色 
    REQ_ROLE_REQUEST_NPC             = 1140,[1140] = "REQ_ROLE_REQUEST_NPC", 
    -- [1150]返回角色任务已开放系统 -- 角色 
    ACK_ROLE_SYS                     = 1150,[1150] = "ACK_ROLE_SYS", 
    -- [1160]角色任务开放系统 -- 角色 
    ACK_ROLE_OPEN_SYS                = 1160,[1160] = "ACK_ROLE_OPEN_SYS", 
    -- [1240]腾讯玩家登陆 -- 角色 
    REQ_ROLE_LOGIN_N                 = 1240,[1240] = "REQ_ROLE_LOGIN_N", 
    -- [1241]腾讯创建角色 -- 角色 
    REQ_ROLE_CREATE_N                = 1241,[1241] = "REQ_ROLE_CREATE_N", 
    -- [1260]请求精力值 -- 角色 
    REQ_ROLE_ENERGY                  = 1260,[1260] = "REQ_ROLE_ENERGY", 
    -- [1261]请求精力值成功 -- 角色 
    ACK_ROLE_ENERGY_OK               = 1261,[1261] = "ACK_ROLE_ENERGY_OK", 
    -- [1262]额外赠送精力 -- 角色 
    ACK_ROLE_BUFF_ENERGY             = 1262,[1262] = "ACK_ROLE_BUFF_ENERGY", 
    -- [1263]请求购买精力面板 -- 角色 
    REQ_ROLE_ASK_BUY_ENERGY          = 1263,[1263] = "REQ_ROLE_ASK_BUY_ENERGY", 
    -- [1264]请求购买面板成功 -- 角色 
    ACK_ROLE_OK_ASK_BUYE             = 1264,[1264] = "ACK_ROLE_OK_ASK_BUYE", 
    -- [1265]购买精力 -- 角色 
    REQ_ROLE_BUY_ENERGY              = 1265,[1265] = "REQ_ROLE_BUY_ENERGY", 
    -- [1267]购买精力成功 -- 角色 
    ACK_ROLE_OK_BUY_ENERGY           = 1267,[1267] = "ACK_ROLE_OK_BUY_ENERGY", 
    -- [1269]使用功能 -- 角色 
    REQ_ROLE_USE_SYS                 = 1269,[1269] = "REQ_ROLE_USE_SYS", 
    -- [1271]开启的系统ID(新) -- 角色 
    ACK_ROLE_SYS_ID_2                = 1271,[1271] = "ACK_ROLE_SYS_ID_2", 
    -- [1280]单个活动次数更新 -- 角色 
    ACK_ROLE_SYS_CHANGE              = 1280,[1280] = "ACK_ROLE_SYS_CHANGE", 
    -- [1310]请求VIP(自己) -- 角色 
    REQ_ROLE_VIP_MY                  = 1310,[1310] = "REQ_ROLE_VIP_MY", 
    -- [1311]请求vip回复 -- 角色 
    ACK_ROLE_LV_MY                   = 1311,[1311] = "ACK_ROLE_LV_MY", 
    -- [1312]请求玩家VIP -- 角色 
    REQ_ROLE_VIP                     = 1312,[1312] = "REQ_ROLE_VIP", 
    -- [1313]玩家VIP等级 -- 角色 
    ACK_ROLE_VIP_LV                  = 1313,[1313] = "ACK_ROLE_VIP_LV", 
    -- [1330]提醒签到 -- 角色 
    ACK_ROLE_NOTICE                  = 1330,[1330] = "ACK_ROLE_NOTICE", 
    -- [1331]请求签到面板 -- 角色 
    REQ_ROLE_REQUEST                 = 1331,[1331] = "REQ_ROLE_REQUEST", 
    -- [1332]请求签到面板成功 -- 角色 
    ACK_ROLE_OK_REQUEST              = 1332,[1332] = "ACK_ROLE_OK_REQUEST", 
    -- [1333]玩家点击签到 -- 角色 
    REQ_ROLE_CLICK                   = 1333,[1333] = "REQ_ROLE_CLICK", 
    -- [1334]玩家签到成功 -- 角色 
    ACK_ROLE_OK_CLICK                = 1334,[1334] = "ACK_ROLE_OK_CLICK", 
    -- [1340]在线奖励 -- 角色 
    ACK_ROLE_ONLINE_REWARD           = 1340,[1340] = "ACK_ROLE_ONLINE_REWARD", 
    -- [1341]等级礼包 -- 角色 
    ACK_ROLE_LEVEL_GIFT              = 1341,[1341] = "ACK_ROLE_LEVEL_GIFT", 
    -- [1350]领取 -- 角色 
    REQ_ROLE_ONLINE_OK               = 1350,[1350] = "REQ_ROLE_ONLINE_OK", 
    -- [1351]领取等级礼包 -- 角色 
    REQ_ROLE_LEVEL_GIFT_OK           = 1351,[1351] = "REQ_ROLE_LEVEL_GIFT_OK", 
    -- [1355]buff数据(欲废除) -- 角色 
    ACK_ROLE_BUFF_DATA               = 1355,[1355] = "ACK_ROLE_BUFF_DATA", 
    -- [1360]buff数据 -- 角色 
    ACK_ROLE_BUFF1_DATA              = 1360,[1360] = "ACK_ROLE_BUFF1_DATA", 
    -- [1365]buffs数据 -- 角色 
    ACK_ROLE_XXFFS_DATA              = 1365,[1365] = "ACK_ROLE_XXFFS_DATA", 
    -- [1370]通知加buff -- 角色 
    ACK_ROLE_BUFF                    = 1370,[1370] = "ACK_ROLE_BUFF", 
    -- [1375]请求领取体力 -- 角色 
    REQ_ROLE_BUFF_REQUEST            = 1375,[1375] = "REQ_ROLE_BUFF_REQUEST", 
    -- [1376]领取体力返回 -- 角色 
    ACK_ROLE_BUFF_REPLY              = 1376,[1376] = "ACK_ROLE_BUFF_REPLY", 
    -- [1380]属性加成请求 -- 角色 
    REQ_ROLE_ATTR_ADD_REQUEST        = 1380,[1380] = "REQ_ROLE_ATTR_ADD_REQUEST", 
    -- [1385]属性加成返回 -- 角色 
    ACK_ROLE_ATTR_ADD_REPLY          = 1385,[1385] = "ACK_ROLE_ATTR_ADD_REPLY", 
    -- [1390]属性加成信息块 -- 角色 
    ACK_ROLE_MSG_ATTR_ADD            = 1390,[1390] = "ACK_ROLE_MSG_ATTR_ADD", 
    -- [1395]请求是否有属性加成 -- 角色 
    REQ_ROLE_ATTR_ADD_FLAG           = 1395,[1395] = "REQ_ROLE_ATTR_ADD_FLAG", 
    -- [1396]是否有属性加成返回 -- 角色 
    ACK_ROLE_ATTR_FLAG_REPLY         = 1396,[1396] = "ACK_ROLE_ATTR_FLAG_REPLY", 
    -- [1397]玩家属性(新) -- 角色 
    ACK_ROLE_PRORERTY_REVENEW        = 1397,[1397] = "ACK_ROLE_PRORERTY_REVENEW", 
    -- [1400]玩家战斗对比请求 -- 角色 
    REQ_ROLE_REQUEST_COMPARE         = 1400,[1400] = "REQ_ROLE_REQUEST_COMPARE", 
    -- [1405]玩家战斗对比返回 -- 角色 
    ACK_ROLE_REPLY_COMPARE           = 1405,[1405] = "ACK_ROLE_REPLY_COMPARE", 
    -- [1408]战斗力信息块 -- 角色 
    ACK_ROLE_POWERFUL_XXX            = 1408,[1408] = "ACK_ROLE_POWERFUL_XXX", 
    -- [1430]系统标点 -- 角色 
    ACK_ROLE_SYS_POINTS              = 1430,[1430] = "ACK_ROLE_SYS_POINTS", 
    -- [1432]系统标点(切换守护专用) -- 角色 
    ACK_ROLE_SYS_POINTS_INN          = 1432,[1432] = "ACK_ROLE_SYS_POINTS_INN", 
    -- [1433]灵妖信息块 -- 角色 
    ACK_ROLE_MSG_LINGYAO             = 1433,[1433] = "ACK_ROLE_MSG_LINGYAO", 

    --------------------------------------------------------
    -- 2001 - 2500 ( 物品/背包 ) 
    --------------------------------------------------------
    -- [2001]物品信息块 -- 物品/背包 
    ACK_GOODS_XXX1                   = 2001,[2001] = "ACK_GOODS_XXX1", 
    -- [2002]属性信息块 -- 物品/背包 
    ACK_GOODS_XXX2                   = 2002,[2002] = "ACK_GOODS_XXX2", 
    -- [2003]插槽信息块 -- 物品/背包 
    ACK_GOODS_XXX3                   = 2003,[2003] = "ACK_GOODS_XXX3", 
    -- [2004]装备打造附加块 -- 物品/背包 
    ACK_GOODS_XXX4                   = 2004,[2004] = "ACK_GOODS_XXX4", 
    -- [2005]插槽属性块 -- 物品/背包 
    ACK_GOODS_XXX5                   = 2005,[2005] = "ACK_GOODS_XXX5", 
    -- [2006]基础属性块 -- 物品/背包 
    ACK_GOODS_ATTR_BASE              = 2006,[2006] = "ACK_GOODS_ATTR_BASE", 
    -- [2010]请求装备,背包物品信息 -- 物品/背包 
    REQ_GOODS_REQUEST                = 2010,[2010] = "REQ_GOODS_REQUEST", 
    -- [2020]请求返回数据 -- 物品/背包 
    ACK_GOODS_REVERSE                = 2020,[2020] = "ACK_GOODS_REVERSE", 
    -- [2040]消失物品/装备 -- 物品/背包 
    ACK_GOODS_REMOVE                 = 2040,[2040] = "ACK_GOODS_REMOVE", 
    -- [2050]物品/装备属性变化 -- 物品/背包 
    ACK_GOODS_CHANGE                 = 2050,[2050] = "ACK_GOODS_CHANGE", 
    -- [2060]获得|失去物品通知 -- 物品/背包 
    ACK_GOODS_CHANGE_NOTICE          = 2060,[2060] = "ACK_GOODS_CHANGE_NOTICE", 
    -- [2070]获得|失去货币通知 -- 物品/背包 
    ACK_GOODS_CURRENCY_CHANGE        = 2070,[2070] = "ACK_GOODS_CURRENCY_CHANGE", 
    -- [2080]物品/装备使用 -- 物品/背包 
    REQ_GOODS_USE                    = 2080,[2080] = "REQ_GOODS_USE", 
    -- [2081]伙伴经验丹使用成功 -- 物品/背包 
    ACK_GOODS_P_EXP_OK               = 2081,[2081] = "ACK_GOODS_P_EXP_OK", 
    -- [2090]使用物品(指定对象) -- 物品/背包 
    REQ_GOODS_TARGET_USE             = 2090,[2090] = "REQ_GOODS_TARGET_USE", 
    -- [2095]使用物品（得话费） -- 物品/背包 
    REQ_GOODS_HUAFEI_USE             = 2095,[2095] = "REQ_GOODS_HUAFEI_USE", 
    -- [2097]使用充值卡成功 -- 物品/背包 
    ACK_GOODS_HUAFEI_SUCCESS         = 2097,[2097] = "ACK_GOODS_HUAFEI_SUCCESS", 
    -- [2098]使用改名卡 -- 物品/背包 
    REQ_GOODS_CHANG_NAME             = 2098,[2098] = "REQ_GOODS_CHANG_NAME", 
    -- [2099]改名成功 -- 物品/背包 
    ACK_GOODS_CHANG_SUCCESS          = 2099,[2099] = "ACK_GOODS_CHANG_SUCCESS", 
    -- [2100]丢弃物品 -- 物品/背包 
    REQ_GOODS_LOSE                   = 2100,[2100] = "REQ_GOODS_LOSE", 
    -- [2225]请求容器扩充 -- 物品/背包 
    REQ_GOODS_ENLARGE_REQUEST        = 2225,[2225] = "REQ_GOODS_ENLARGE_REQUEST", 
    -- [2227]扩充需要的道具数量 -- 物品/背包 
    ACK_GOODS_ENLARGE_COST           = 2227,[2227] = "ACK_GOODS_ENLARGE_COST", 
    -- [2230]容器扩充成功 -- 物品/背包 
    ACK_GOODS_ENLARGE                = 2230,[2230] = "ACK_GOODS_ENLARGE", 
    -- [2240]请求角色装备信息 -- 物品/背包 
    REQ_GOODS_EQUIP_ASK              = 2240,[2240] = "REQ_GOODS_EQUIP_ASK", 
    -- [2242]角色装备信息返回 -- 物品/背包 
    ACK_GOODS_EQUIP_BACK             = 2242,[2242] = "ACK_GOODS_EQUIP_BACK", 
    -- [2245]部位信息块 -- 物品/背包 
    ACK_GOODS_MSG_PART_XXX           = 2245,[2245] = "ACK_GOODS_MSG_PART_XXX", 
    -- [2250]提取临时背包物品 -- 物品/背包 
    REQ_GOODS_PICK_TEMP              = 2250,[2250] = "REQ_GOODS_PICK_TEMP", 
    -- [2260]出售物品 -- 物品/背包 
    REQ_GOODS_SELL                   = 2260,[2260] = "REQ_GOODS_SELL", 
    -- [2261]批量出售背包物品 -- 物品/背包 
    REQ_GOODS_P_SELL                 = 2261,[2261] = "REQ_GOODS_P_SELL", 
    -- [2262]出售成功 -- 物品/背包 
    ACK_GOODS_SELL_OK                = 2262,[2262] = "ACK_GOODS_SELL_OK", 
    -- [2270]装备一键互换 -- 物品/背包 
    REQ_GOODS_EQUIP_SWAP             = 2270,[2270] = "REQ_GOODS_EQUIP_SWAP", 
    -- [2272]一键互换成功 -- 物品/背包 
    ACK_GOODS_SWAP_OK                = 2272,[2272] = "ACK_GOODS_SWAP_OK", 
    -- [2280]请求购回 -- 物品/背包 
    REQ_GOODS_BUY_BACK               = 2280,[2280] = "REQ_GOODS_BUY_BACK", 
    -- [2300]请求商店信息 -- 物品/背包 
    REQ_GOODS_SHOP_ASK               = 2300,[2300] = "REQ_GOODS_SHOP_ASK", 
    -- [2301]商店物品信息块 -- 物品/背包 
    ACK_GOODS_SHOP_XXX1              = 2301,[2301] = "ACK_GOODS_SHOP_XXX1", 
    -- [2310]商店数据返回 -- 物品/背包 
    ACK_GOODS_SHOP_BACK              = 2310,[2310] = "ACK_GOODS_SHOP_BACK", 
    -- [2320]购买商店物品 -- 物品/背包 
    REQ_GOODS_SHOP_BUY               = 2320,[2320] = "REQ_GOODS_SHOP_BUY", 
    -- [2321]商店购买成功 -- 物品/背包 
    ACK_GOODS_SHOP_BUY_OK            = 2321,[2321] = "ACK_GOODS_SHOP_BUY_OK", 
    -- [2327]元宵节活动将会获得的物品索引(0~11) -- 物品/背包 
    ACK_GOODS_LANTERN_INDEX          = 2327,[2327] = "ACK_GOODS_LANTERN_INDEX", 
    -- [2328]领取将要获得的物品 -- 物品/背包 
    REQ_GOODS_LANTERN_GET            = 2328,[2328] = "REQ_GOODS_LANTERN_GET", 
    -- [2329]请求元宵活动数据 -- 物品/背包 
    REQ_GOODS_LANTERN_ASK            = 2329,[2329] = "REQ_GOODS_LANTERN_ASK", 
    -- [2330]请求次数物品数据 -- 物品/背包 
    REQ_GOODS_TIMES_GOODS_ASK        = 2330,[2330] = "REQ_GOODS_TIMES_GOODS_ASK", 
    -- [2331]元宵活动数据返回 -- 物品/背包 
    ACK_GOODS_LANTERN_BACK           = 2331,[2331] = "ACK_GOODS_LANTERN_BACK", 
    -- [2332]次数物品数据返回 -- 物品/背包 
    ACK_GOODS_TIMES_GOODS_BACK       = 2332,[2332] = "ACK_GOODS_TIMES_GOODS_BACK", 
    -- [2333]次数物品数据块 -- 物品/背包 
    ACK_GOODS_TIMES_XXX1             = 2333,[2333] = "ACK_GOODS_TIMES_XXX1", 
    -- [2334]次数物品日志数据块 -- 物品/背包 
    ACK_GOODS_TIMES_XXX2             = 2334,[2334] = "ACK_GOODS_TIMES_XXX2", 
    -- [2335]元宵活动物品信息块 -- 物品/背包 
    ACK_GOODS_TIMES_XXX3             = 2335,[2335] = "ACK_GOODS_TIMES_XXX3", 
    -- [2336]检查特定活动物品是否可使用 -- 物品/背包 
    REQ_GOODS_ACTY_USE_CHECK         = 2336,[2336] = "REQ_GOODS_ACTY_USE_CHECK", 
    -- [2338]特定活动物品是否可使用 -- 物品/背包 
    ACK_GOODS_ACTY_USE_STATE         = 2338,[2338] = "ACK_GOODS_ACTY_USE_STATE", 

    --------------------------------------------------------
    -- 2501 - 3000 ( 物品/打造/强化 ) 
    --------------------------------------------------------
    -- [2510]装备首饰打造 -- 物品/打造/强化 
    REQ_MAKE_EQUIP                   = 2510,[2510] = "REQ_MAKE_EQUIP", 
    -- [2512]打造成功 -- 物品/打造/强化 
    ACK_MAKE_MAKE_OK                 = 2512,[2512] = "ACK_MAKE_MAKE_OK", 
    -- [2513]强化 -- 物品/打造/强化 
    REQ_MAKE_KEY_STREN               = 2513,[2513] = "REQ_MAKE_KEY_STREN", 
    -- [2515]装备强化 -- 物品/打造/强化 
    REQ_MAKE_STRENGTHEN              = 2515,[2515] = "REQ_MAKE_STRENGTHEN", 
    -- [2516]请求装备强化数据 -- 物品/打造/强化 
    REQ_MAKE_STREN_DATA_ASK          = 2516,[2516] = "REQ_MAKE_STREN_DATA_ASK", 
    -- [2517]下一级装备强化数据返回 -- 物品/打造/强化 
    ACK_MAKE_STREN_DATA_BACK         = 2517,[2517] = "ACK_MAKE_STREN_DATA_BACK", 
    -- [2518]强化消耗材料信息块 -- 物品/打造/强化 
    ACK_MAKE_STREN_COST_XXX          = 2518,[2518] = "ACK_MAKE_STREN_COST_XXX", 
    -- [2519]已强化到最高级 -- 物品/打造/强化 
    ACK_MAKE_STREN_MAX               = 2519,[2519] = "ACK_MAKE_STREN_MAX", 
    -- [2520]装备强化成功 -- 物品/打造/强化 
    ACK_MAKE_STRENGTHEN_OK           = 2520,[2520] = "ACK_MAKE_STRENGTHEN_OK", 
    -- [2522]法宝升阶 -- 物品/打造/强化 
    REQ_MAKE_MAGIC_UPGRADE           = 2522,[2522] = "REQ_MAKE_MAGIC_UPGRADE", 
    -- [2525]法宝升阶成功 -- 物品/打造/强化 
    ACK_MAKE_UPGRADE_OK              = 2525,[2525] = "ACK_MAKE_UPGRADE_OK", 
    -- [2530]装备洗练 -- 物品/打造/强化 
    REQ_MAKE_WASH                    = 2530,[2530] = "REQ_MAKE_WASH", 
    -- [2531]锁定属性位置 -- 物品/打造/强化 
    REQ_MAKE_MSG_POS                 = 2531,[2531] = "REQ_MAKE_MSG_POS", 
    -- [2532]洗练数据返回 -- 物品/打造/强化 
    ACK_MAKE_WASH_BACK               = 2532,[2532] = "ACK_MAKE_WASH_BACK", 
    -- [2535]附加属性数据块 -- 物品/打造/强化 
    ACK_MAKE_PLUS_MSG_XXX            = 2535,[2535] = "ACK_MAKE_PLUS_MSG_XXX", 
    -- [2536]附加属性数据块2 -- 物品/打造/强化 
    ACK_MAKE_PLUS_MSG_XXX2           = 2536,[2536] = "ACK_MAKE_PLUS_MSG_XXX2", 
    -- [2540]是否保留洗练数据 -- 物品/打造/强化 
    REQ_MAKE_WASH_SAVE               = 2540,[2540] = "REQ_MAKE_WASH_SAVE", 
    -- [2542]保留洗练属性成功 -- 物品/打造/强化 
    ACK_MAKE_WASH_OK                 = 2542,[2542] = "ACK_MAKE_WASH_OK", 
    -- [2550]宝石合成 -- 物品/打造/强化 
    REQ_MAKE_MAKE_COMPOSE            = 2550,[2550] = "REQ_MAKE_MAKE_COMPOSE", 
    -- [2552]灵珠合成成功 -- 物品/打造/强化 
    ACK_MAKE_COMPOSE_OK              = 2552,[2552] = "ACK_MAKE_COMPOSE_OK", 
    -- [2560]宝石镶嵌 -- 物品/打造/强化 
    REQ_MAKE_PEARL_INSET             = 2560,[2560] = "REQ_MAKE_PEARL_INSET", 
    -- [2561]镶嵌宝石成功 -- 物品/打造/强化 
    ACK_MAKE_PEARL_INSET_OK          = 2561,[2561] = "ACK_MAKE_PEARL_INSET_OK", 
    -- [2565]宝石一键镶嵌元宝数 -- 物品/打造/强化 
    ACK_MAKE_INSET_RMB               = 2565,[2565] = "ACK_MAKE_INSET_RMB", 
    -- [2570]拆除灵珠 -- 物品/打造/强化 
    REQ_MAKE_PEARL_REMOVE            = 2570,[2570] = "REQ_MAKE_PEARL_REMOVE", 
    -- [2580]法宝拆分 -- 物品/打造/强化 
    REQ_MAKE_MAGIC_PART              = 2580,[2580] = "REQ_MAKE_MAGIC_PART", 
    -- [2582]法宝拆分成功 -- 物品/打造/强化 
    ACK_MAKE_MAGIC_PART_OK           = 2582,[2582] = "ACK_MAKE_MAGIC_PART_OK", 
    -- [2590]装备附魔 -- 物品/打造/强化 
    REQ_MAKE_ENCHANT                 = 2590,[2590] = "REQ_MAKE_ENCHANT", 
    -- [2600]附魔成功 -- 物品/打造/强化 
    ACK_MAKE_ENCHANT_OK              = 2600,[2600] = "ACK_MAKE_ENCHANT_OK", 
    -- [2610]请求附魔消耗 -- 物品/打造/强化 
    REQ_MAKE_ENCHANT_S               = 2610,[2610] = "REQ_MAKE_ENCHANT_S", 
    -- [2620]附魔消耗 -- 物品/打造/强化 
    ACK_MAKE_ENCHANT_PAY             = 2620,[2620] = "ACK_MAKE_ENCHANT_PAY", 
    -- [2680]请求下一级升品数据 -- 物品/打造/强化 
    REQ_MAKE_EQUIP_NEXT              = 2680,[2680] = "REQ_MAKE_EQUIP_NEXT", 
    -- [2690]下一级打造装备数据返回 -- 物品/打造/强化 
    ACK_MAKE_EQUIP_NEXT_REPLY        = 2690,[2690] = "ACK_MAKE_EQUIP_NEXT_REPLY", 
    -- [2700]装备升品 -- 物品/打造/强化 
    REQ_MAKE_EQUIP_NEW               = 2700,[2700] = "REQ_MAKE_EQUIP_NEW", 
    -- [2710]装备升品返回(新的) -- 物品/打造/强化 
    ACK_MAKE_EQUIP_NEW_REPLY         = 2710,[2710] = "ACK_MAKE_EQUIP_NEW_REPLY", 
    -- [2720]记录洗练锁定位置 -- 物品/打造/强化 
    REQ_MAKE_LOCK                    = 2720,[2720] = "REQ_MAKE_LOCK", 
    -- [2724]部位强化请求 -- 物品/打造/强化 
    REQ_MAKE_PART_STREN_REQ          = 2724,[2724] = "REQ_MAKE_PART_STREN_REQ", 
    -- [2726]强化返回 -- 物品/打造/强化 
    ACK_MAKE_PART_STREN_REPLY        = 2726,[2726] = "ACK_MAKE_PART_STREN_REPLY", 
    -- [2730]强化部位 -- 物品/打造/强化 
    REQ_MAKE_PART_STREN              = 2730,[2730] = "REQ_MAKE_PART_STREN", 
    -- [2734]请求所有部位 -- 物品/打造/强化 
    REQ_MAKE_PART_ALL                = 2734,[2734] = "REQ_MAKE_PART_ALL", 
    -- [2736]所有部位返回 -- 物品/打造/强化 
    ACK_MAKE_PART_ALL_REP            = 2736,[2736] = "ACK_MAKE_PART_ALL_REP", 
    -- [2737]部位信息块 -- 物品/打造/强化 
    ACK_MAKE_PART_ALL_XXX            = 2737,[2737] = "ACK_MAKE_PART_ALL_XXX", 
    -- [2738]宝石信息块 -- 物品/打造/强化 
    ACK_MAKE_GEM_XXX                 = 2738,[2738] = "ACK_MAKE_GEM_XXX", 
    -- [2739]强化属性信息块 -- 物品/打造/强化 
    ACK_MAKE_PART_STREN_ATTR         = 2739,[2739] = "ACK_MAKE_PART_STREN_ATTR", 
    -- [2740]部位镶嵌宝石请求 -- 物品/打造/强化 
    REQ_MAKE_PART_INSERT_REQ         = 2740,[2740] = "REQ_MAKE_PART_INSERT_REQ", 
    -- [2745]部位镶嵌宝石返回 -- 物品/打造/强化 
    ACK_MAKE_PART_INSERT_REP         = 2745,[2745] = "ACK_MAKE_PART_INSERT_REP", 
    -- [2755]宝石镶嵌 -- 物品/打造/强化 
    REQ_MAKE_PART_INSERT             = 2755,[2755] = "REQ_MAKE_PART_INSERT", 
    -- [2760]部位宝石镶嵌升级 -- 物品/打造/强化 
    REQ_MAKE_PART_INSERT_UP          = 2760,[2760] = "REQ_MAKE_PART_INSERT_UP", 
    -- [2765]部位宝石拆卸 -- 物品/打造/强化 
    REQ_MAKE_PART_GEM_REMOVE         = 2765,[2765] = "REQ_MAKE_PART_GEM_REMOVE", 
    -- [2770]装备分解 -- 物品/打造/强化 
    REQ_MAKE_DECOMPOSE               = 2770,[2770] = "REQ_MAKE_DECOMPOSE", 
    -- [2775]分解物品信息块 -- 物品/打造/强化 
    REQ_MAKE_XXX_IDX                 = 2775,[2775] = "REQ_MAKE_XXX_IDX", 
    -- [2778]装备分解成功返回 -- 物品/打造/强化 
    ACK_MAKE_DECOMPOSE_REPLY         = 2778,[2778] = "ACK_MAKE_DECOMPOSE_REPLY", 
    -- [2800]玄晶 -- 物品/打造/强化 
    ACK_MAKE_XUANJING                = 2800,[2800] = "ACK_MAKE_XUANJING", 
    -- [2805]部位强化成功 -- 物品/打造/强化 
    ACK_MAKE_STREN_SUCCESS           = 2805,[2805] = "ACK_MAKE_STREN_SUCCESS", 
    -- [2810]部位镶嵌宝石结果返回 -- 物品/打造/强化 
    ACK_MAKE_PART_INSERT_FLAG        = 2810,[2810] = "ACK_MAKE_PART_INSERT_FLAG", 
    -- [2815]部位升级宝石结果返回 -- 物品/打造/强化 
    ACK_MAKE_PART_UP_FLAG            = 2815,[2815] = "ACK_MAKE_PART_UP_FLAG", 
    -- [2820]部位宝石一键镶嵌 -- 物品/打造/强化 
    REQ_MAKE_PART_INSERT_ONE         = 2820,[2820] = "REQ_MAKE_PART_INSERT_ONE", 
    -- [2825]部位宝石一键拆卸 -- 物品/打造/强化 
    REQ_MAKE_PART_REMOVE_ONE         = 2825,[2825] = "REQ_MAKE_PART_REMOVE_ONE", 

    --------------------------------------------------------
    -- 3001 - 3500 ( 任务 ) 
    --------------------------------------------------------
    -- [3210]请求任务列表 -- 任务 
    REQ_TASK_REQUEST_LIST            = 3210,[3210] = "REQ_TASK_REQUEST_LIST", 
    -- [3220]返回任务数据 -- 任务 
    ACK_TASK_DATA                    = 3220,[3220] = "ACK_TASK_DATA", 
    -- [3223]怪物信息块 -- 任务 
    ACK_TASK_MONSTER_DETAIL          = 3223,[3223] = "ACK_TASK_MONSTER_DETAIL", 
    -- [3225]任务剧情通知 -- 任务 
    ACK_TASK_TASK_DRAMA              = 3225,[3225] = "ACK_TASK_TASK_DRAMA", 
    -- [3230]接受任务 -- 任务 
    REQ_TASK_ACCEPT                  = 3230,[3230] = "REQ_TASK_ACCEPT", 
    -- [3240]放弃任务 -- 任务 
    REQ_TASK_CANCEL                  = 3240,[3240] = "REQ_TASK_CANCEL", 
    -- [3250]提交任务 -- 任务 
    REQ_TASK_SUBMIT                  = 3250,[3250] = "REQ_TASK_SUBMIT", 
    -- [3265]从列表中移除任务 -- 任务 
    ACK_TASK_REMOVE                  = 3265,[3265] = "ACK_TASK_REMOVE", 

    --------------------------------------------------------
    -- 3501 - 4000 ( 组队系统 ) 
    --------------------------------------------------------
    -- [3520]请求单个组队信息 -- 组队系统 
    REQ_TEAM_REQUEST                 = 3520,[3520] = "REQ_TEAM_REQUEST", 
    -- [3526]组队副本信息返回 -- 组队系统 
    ACK_TEAM_REPLY                   = 3526,[3526] = "ACK_TEAM_REPLY", 
    -- [3528]副本评星信息块 -- 组队系统 
    ACK_TEAM_MSG_EVA_XXX             = 3528,[3528] = "ACK_TEAM_MSG_EVA_XXX", 
    -- [3530]队伍信息块 -- 组队系统 
    ACK_TEAM_REPLY_MSG               = 3530,[3530] = "ACK_TEAM_REPLY_MSG", 
    -- [3540]快速加入 -- 组队系统 
    REQ_TEAM_QUICK_JOIN              = 3540,[3540] = "REQ_TEAM_QUICK_JOIN", 
    -- [3570]创建队伍 -- 组队系统 
    REQ_TEAM_CREAT                   = 3570,[3570] = "REQ_TEAM_CREAT", 
    -- [3572]队伍信息返回(new) -- 组队系统 
    ACK_TEAM_TEAM_INFO_NEW           = 3572,[3572] = "ACK_TEAM_TEAM_INFO_NEW", 
    -- [3574]队伍成员信息块(new) -- 组队系统 
    ACK_TEAM_MEM_MSG_NEW             = 3574,[3574] = "ACK_TEAM_MEM_MSG_NEW", 
    -- [3600]加入队伍 -- 组队系统 
    REQ_TEAM_JOIN                    = 3600,[3600] = "REQ_TEAM_JOIN", 
    -- [3610]离开队伍 -- 组队系统 
    REQ_TEAM_LEAVE                   = 3610,[3610] = "REQ_TEAM_LEAVE", 
    -- [3620]离队通知 -- 组队系统 
    ACK_TEAM_LEAVE_NOTICE            = 3620,[3620] = "ACK_TEAM_LEAVE_NOTICE", 
    -- [3630]踢出队员 -- 组队系统 
    REQ_TEAM_KICK                    = 3630,[3630] = "REQ_TEAM_KICK", 
    -- [3640]设置新队长 -- 组队系统 
    REQ_TEAM_SET_LEADER              = 3640,[3640] = "REQ_TEAM_SET_LEADER", 
    -- [3650]申请做队长 -- 组队系统 
    REQ_TEAM_APPLY_LEADER            = 3650,[3650] = "REQ_TEAM_APPLY_LEADER", 
    -- [3660]申请队长通知 -- 组队系统 
    ACK_TEAM_APPLY_NOTICE            = 3660,[3660] = "ACK_TEAM_APPLY_NOTICE", 
    -- [3670]新队长通知 -- 组队系统 
    ACK_TEAM_NEW_LEADER              = 3670,[3670] = "ACK_TEAM_NEW_LEADER", 
    -- [3680]邀请好友组队 -- 组队系统 
    REQ_TEAM_INVITE                  = 3680,[3680] = "REQ_TEAM_INVITE", 
    -- [3690]邀请好友成功 -- 组队系统 
    ACK_TEAM_INVITE_SUCCESS          = 3690,[3690] = "ACK_TEAM_INVITE_SUCCESS", 
    -- [3700]好友邀请返回 -- 组队系统 
    ACK_TEAM_INVITE_BACK             = 3700,[3700] = "ACK_TEAM_INVITE_BACK", 
    -- [3720]查询队伍是否存在 -- 组队系统 
    REQ_TEAM_LIVE_REQ                = 3720,[3720] = "REQ_TEAM_LIVE_REQ", 
    -- [3730]查询队伍返回 -- 组队系统 
    ACK_TEAM_LIVE_REP                = 3730,[3730] = "ACK_TEAM_LIVE_REP", 
    -- [3770]邀请好友返回 -- 组队系统 
    ACK_TEAM_INVITE_NOTICE           = 3770,[3770] = "ACK_TEAM_INVITE_NOTICE", 
    -- [3780]设置状态 -- 组队系统 
    REQ_TEAM_READY                   = 3780,[3780] = "REQ_TEAM_READY", 
    -- [3790]购买次数 -- 组队系统 
    REQ_TEAM_BUY_TIMES               = 3790,[3790] = "REQ_TEAM_BUY_TIMES", 
    -- [3800]购买成功 -- 组队系统 
    ACK_TEAM_BUY_SUCCESS             = 3800,[3800] = "ACK_TEAM_BUY_SUCCESS", 
    -- [3810]获取邀请玩家列表 -- 组队系统 
    REQ_TEAM_INVITE_LIST             = 3810,[3810] = "REQ_TEAM_INVITE_LIST", 
    -- [3820]邀请玩家列表返回 -- 组队系统 
    ACK_TEAM_LIST_REPLY              = 3820,[3820] = "ACK_TEAM_LIST_REPLY", 
    -- [3830]玩家信息块 -- 组队系统 
    ACK_TEAM_MSG_PLAYER              = 3830,[3830] = "ACK_TEAM_MSG_PLAYER", 
    -- [3835]购买次数信息 -- 组队系统 
    ACK_TEAM_BUY_INFO                = 3835,[3835] = "ACK_TEAM_BUY_INFO", 
    -- [3840]是否允许组队 -- 组队系统 
    REQ_TEAM_INVITE_STATE            = 3840,[3840] = "REQ_TEAM_INVITE_STATE", 

    --------------------------------------------------------
    -- 4001 - 4500 ( 好友 ) 
    --------------------------------------------------------
    -- [4010]根据请求类型 请求好友||最近联系人||黑名单面板 -- 好友 
    REQ_FRIEND_REQUES                = 4010,[4010] = "REQ_FRIEND_REQUES", 
    -- [4020]请求好友数据返回 -- 好友 
    ACK_FRIEND_INFO                  = 4020,[4020] = "ACK_FRIEND_INFO", 
    -- [4025]联系人信息块 -- 好友 
    ACK_FRIEND_MSG_ROLE_XX           = 4025,[4025] = "ACK_FRIEND_MSG_ROLE_XX", 
    -- [4030]删除好友 -- 好友 
    REQ_FRIEND_DEL                   = 4030,[4030] = "REQ_FRIEND_DEL", 
    -- [4040]好友删除成功 -- 好友 
    ACK_FRIEND_DEL_OK                = 4040,[4040] = "ACK_FRIEND_DEL_OK", 
    -- [4050]按名称搜索玩家 -- 好友 
    REQ_FRIEND_SEARCH_ADD            = 4050,[4050] = "REQ_FRIEND_SEARCH_ADD", 
    -- [4060]查找好友返回 -- 好友 
    ACK_FRIEND_SEARCH_REPLY          = 4060,[4060] = "ACK_FRIEND_SEARCH_REPLY", 
    -- [4070]添加好友 -- 好友 
    REQ_FRIEND_ADD                   = 4070,[4070] = "REQ_FRIEND_ADD", 
    -- [4075]人物信息块 -- 好友 
    REQ_FRIEND_MSG_ROLE_XXX          = 4075,[4075] = "REQ_FRIEND_MSG_ROLE_XXX", 
    -- [4090]发送添加好友通知 -- 好友 
    ACK_FRIEND_ADD_NOTICE            = 4090,[4090] = "ACK_FRIEND_ADD_NOTICE", 
    -- [4100]推荐好友 -- 好友 
    REQ_FRIEND_GET_FRIEND            = 4100,[4100] = "REQ_FRIEND_GET_FRIEND", 
    -- [4110] 好友界面中的推荐好友 -- 好友 
    ACK_FRIEND_GET_FRIEND_CB         = 4110,[4110] = "ACK_FRIEND_GET_FRIEND_CB", 
    -- [4200]系统推荐玩家数据返回 -- 好友 
    ACK_FRIEND_SYS_FRIEND            = 4200,[4200] = "ACK_FRIEND_SYS_FRIEND", 
    -- [4210]祝福好友 -- 好友 
    REQ_FRIEND_BLESS                 = 4210,[4210] = "REQ_FRIEND_BLESS", 
    -- [4215]祝福好友成功 -- 好友 
    ACK_FRIEND_BLESS_REPLY           = 4215,[4215] = "ACK_FRIEND_BLESS_REPLY", 
    -- [4217]祝福好友失败(让按钮变暗) -- 好友 
    ACK_FRIEND_BLESS_FAIL            = 4217,[4217] = "ACK_FRIEND_BLESS_FAIL", 
    -- [4220]一键祝福所有好友 -- 好友 
    REQ_FRIEND_BLESS_ALL             = 4220,[4220] = "REQ_FRIEND_BLESS_ALL", 
    -- [4230]领取好友祝福 -- 好友 
    REQ_FRIEND_BLESS_GET             = 4230,[4230] = "REQ_FRIEND_BLESS_GET", 
    -- [4235]领取好友祝福成功返回 -- 好友 
    ACK_FRIEND_BLESS_GET_REPLY       = 4235,[4235] = "ACK_FRIEND_BLESS_GET_REPLY", 
    -- [4240]一键领取所有好友祝福 -- 好友 
    REQ_FRIEND_BLESS_GET_ALL         = 4240,[4240] = "REQ_FRIEND_BLESS_GET_ALL", 
    -- [4250]添加好友成功 -- 好友 
    ACK_FRIEND_ADD_SUCCESS           = 4250,[4250] = "ACK_FRIEND_ADD_SUCCESS", 
    -- [4255]可祝福别人次数 -- 好友 
    REQ_FRIEND_BLESS_OTHER_TIME      = 4255,[4255] = "REQ_FRIEND_BLESS_OTHER_TIME", 
    -- [4260]剩余次数 -- 好友 
    ACK_FRIEND_REMAIN_TIMES          = 4260,[4260] = "ACK_FRIEND_REMAIN_TIMES", 
    -- [4270]好友(附近的人)邀请 -- 好友 
    REQ_FRIEND_INVITE                = 4270,[4270] = "REQ_FRIEND_INVITE", 
    -- [4275]好友邀请返回 -- 好友 
    ACK_FRIEND_INVITE_REPLY          = 4275,[4275] = "ACK_FRIEND_INVITE_REPLY", 
    -- [4280]好友邀请返回信息块 -- 好友 
    ACK_FRIEND_INVITE_MSG            = 4280,[4280] = "ACK_FRIEND_INVITE_MSG", 
    -- [4285]里面面板次数 -- 好友 
    REQ_FRIEND_TIME_REQUEST          = 4285,[4285] = "REQ_FRIEND_TIME_REQUEST", 
    -- [4290]次数返回 -- 好友 
    ACK_FRIEND_TIMES_REPLY           = 4290,[4290] = "ACK_FRIEND_TIMES_REPLY", 

    --------------------------------------------------------
    -- 5001 - 6000 ( 场景 ) 
    --------------------------------------------------------
    -- [5005]场景[行走,扣血,技能]打包 -- 场景 
    ACK_SCENE_PACKAGE                = 5005,[5005] = "ACK_SCENE_PACKAGE", 
    -- [5010]请求进入场景(飞) -- 场景 
    REQ_SCENE_ENTER_FLY              = 5010,[5010] = "REQ_SCENE_ENTER_FLY", 
    -- [5020]请求进入场景 -- 场景 
    REQ_SCENE_ENTER                  = 5020,[5020] = "REQ_SCENE_ENTER", 
    -- [5029]各种人物资源预加载 -- 场景 
    ACK_SCENE_ALL_SKIN               = 5029,[5029] = "ACK_SCENE_ALL_SKIN", 
    -- [5030]进入场景 -- 场景 
    ACK_SCENE_ENTER_OK               = 5030,[5030] = "ACK_SCENE_ENTER_OK", 
    -- [5040]行走数据 -- 场景 
    REQ_SCENE_REQUEST_PLAYERS        = 5040,[5040] = "REQ_SCENE_REQUEST_PLAYERS", 
    -- [5042]请求场景玩家列表(NEW) -- 场景 
    REQ_SCENE_REQ_PLAYERS_NEW        = 5042,[5042] = "REQ_SCENE_REQ_PLAYERS_NEW", 
    -- [5045]玩家信息列表 -- 场景 
    ACK_SCENE_PLAYER_LIST            = 5045,[5045] = "ACK_SCENE_PLAYER_LIST", 
    -- [5050]地图玩家数据 -- 场景 
    ACK_SCENE_ROLE_DATA              = 5050,[5050] = "ACK_SCENE_ROLE_DATA", 
    -- [5051]称号信息块 -- 场景 
    ACK_SCENE_TITLE_MSG              = 5051,[5051] = "ACK_SCENE_TITLE_MSG", 
    -- [5052]地图伙伴列表 -- 场景 
    ACK_SCENE_PARTNER_LIST           = 5052,[5052] = "ACK_SCENE_PARTNER_LIST", 
    -- [5053]神器信息块 -- 场景 
    ACK_SCENE_MAGIC_MSG              = 5053,[5053] = "ACK_SCENE_MAGIC_MSG", 
    -- [5055]地图伙伴数据 -- 场景 
    ACK_SCENE_PARTNER_DATA           = 5055,[5055] = "ACK_SCENE_PARTNER_DATA", 
    -- [5060]请求场景怪物数据 -- 场景 
    REQ_SCENE_REQUEST_MONSTER        = 5060,[5060] = "REQ_SCENE_REQUEST_MONSTER", 
    -- [5065]场景刷出第几波怪 -- 场景 
    ACK_SCENE_IDX_MONSTER            = 5065,[5065] = "ACK_SCENE_IDX_MONSTER", 
    -- [5070]怪物数据(刷新) -- 场景 
    ACK_SCENE_MONSTER_DATA           = 5070,[5070] = "ACK_SCENE_MONSTER_DATA", 
    -- [5072]场景刷出第几波怪 -- 场景 
    ACK_SCENE_IDX_MONSTER2           = 5072,[5072] = "ACK_SCENE_IDX_MONSTER2", 
    -- [5075]怪物数据2(刷新) -- 场景 
    ACK_SCENE_MONSTER_DATA2          = 5075,[5075] = "ACK_SCENE_MONSTER_DATA2", 
    -- [5080]行走数据(要广播也要记录位置) -- 场景 
    REQ_SCENE_MOVE                   = 5080,[5080] = "REQ_SCENE_MOVE", 
    -- [5085]行走数据(要广播,后端不记录位置         这条现在不管) -- 场景 
    REQ_SCENE_MOVE_NEW               = 5085,[5085] = "REQ_SCENE_MOVE_NEW", 
    -- [5086]世界boss移动位置 -- 场景 
    ACK_SCENE_WORLD_BOSS_POS         = 5086,[5086] = "ACK_SCENE_WORLD_BOSS_POS", 
    -- [5090]行走数据(地图广播) -- 场景 
    ACK_SCENE_MOVE_RECE              = 5090,[5090] = "ACK_SCENE_MOVE_RECE", 
    -- [5100]强设玩家坐标 -- 场景 
    ACK_SCENE_SET_PLAYER_XY          = 5100,[5100] = "ACK_SCENE_SET_PLAYER_XY", 
    -- [5110]离开场景 -- 场景 
    ACK_SCENE_OUT                    = 5110,[5110] = "ACK_SCENE_OUT", 
    -- [5120]杀怪连击次数 -- 场景 
    REQ_SCENE_CAROM_TIMES            = 5120,[5120] = "REQ_SCENE_CAROM_TIMES", 
    -- [5130]击杀怪物 -- 场景 
    REQ_SCENE_KILL_MONSTER           = 5130,[5130] = "REQ_SCENE_KILL_MONSTER", 
    -- [5140]被怪物击中 -- 场景 
    REQ_SCENE_HIT_TIMES              = 5140,[5140] = "REQ_SCENE_HIT_TIMES", 
    -- [5150]玩家死亡 -- 场景 
    REQ_SCENE_DIE                    = 5150,[5150] = "REQ_SCENE_DIE", 
    -- [5155]伙伴死亡 -- 场景 
    REQ_SCENE_DIE_PARTNER            = 5155,[5155] = "REQ_SCENE_DIE_PARTNER", 
    -- [5160]玩家可以复活 -- 场景 
    ACK_SCENE_RELIVE                 = 5160,[5160] = "ACK_SCENE_RELIVE", 
    -- [5170]玩家请求复活 -- 场景 
    REQ_SCENE_RELIVE_REQUEST         = 5170,[5170] = "REQ_SCENE_RELIVE_REQUEST", 
    -- [5180]玩家复活成功 -- 场景 
    ACK_SCENE_RELIVE_OK              = 5180,[5180] = "ACK_SCENE_RELIVE_OK", 
    -- [5185]血量更新(统一扣血) -- 场景 
    ACK_SCENE_HP_UPDATE_ALL          = 5185,[5185] = "ACK_SCENE_HP_UPDATE_ALL", 
    -- [5190]玩家|伙伴血量更新 -- 场景 
    ACK_SCENE_HP_UPDATE              = 5190,[5190] = "ACK_SCENE_HP_UPDATE", 
    -- [5200]退出场景 -- 场景 
    REQ_SCENE_ENTER_CITY             = 5200,[5200] = "REQ_SCENE_ENTER_CITY", 
    -- [5300]请求物品掉落 -- 场景 
    REQ_SCENE_GOODS_ASK              = 5300,[5300] = "REQ_SCENE_GOODS_ASK", 
    -- [5305]捡掉落物品 -- 场景 
    REQ_SCENE_GET_GOODS              = 5305,[5305] = "REQ_SCENE_GET_GOODS", 
    -- [5310]物品掉落返回 -- 场景 
    ACK_SCENE_GOODS_REPLY_NEW        = 5310,[5310] = "ACK_SCENE_GOODS_REPLY_NEW", 
    -- [5320]箱子请求物品掉落 -- 场景 
    REQ_SCENE_BOX_REQUEST            = 5320,[5320] = "REQ_SCENE_BOX_REQUEST", 
    -- [5340]加成属性(吃物品) -- 场景 
    ACK_SCENE_UP_ATTR                = 5340,[5340] = "ACK_SCENE_UP_ATTR", 
    -- [5350]帮派塔防倒计时 -- 场景 
    ACK_SCENE_CLAN_DEF_TIME          = 5350,[5350] = "ACK_SCENE_CLAN_DEF_TIME", 
    -- [5360]下一波波次 -- 场景 
    ACK_SCENE_NEXT_GATE              = 5360,[5360] = "ACK_SCENE_NEXT_GATE", 
    -- [5362]30秒后刷新下一层怪物 -- 场景 
    ACK_SCENE_REFRESH_NEXT           = 5362,[5362] = "ACK_SCENE_REFRESH_NEXT", 
    -- [5365]请选择正确的传送门进入下一层 -- 场景 
    ACK_SCENE_CHOOSE_DOOR            = 5365,[5365] = "ACK_SCENE_CHOOSE_DOOR", 
    -- [5370]设置战斗状态 -- 场景 
    REQ_SCENE_WAR_STATE              = 5370,[5370] = "REQ_SCENE_WAR_STATE", 
    -- [5380]战斗状态返回 -- 场景 
    ACK_SCENE_WAR_STATE_REPLY        = 5380,[5380] = "ACK_SCENE_WAR_STATE_REPLY", 
    -- [5400]场景加载完成 -- 场景 
    REQ_SCENE_LOAD_READY             = 5400,[5400] = "REQ_SCENE_LOAD_READY", 
    -- [5500]请求屏蔽其他玩家 -- 场景 
    REQ_SCENE_SCREEN_OTHER           = 5500,[5500] = "REQ_SCENE_SCREEN_OTHER", 
    -- [5550]取消屏蔽其他玩家信息 -- 场景 
    REQ_SCENE_CANCLE_SCREEN          = 5550,[5550] = "REQ_SCENE_CANCLE_SCREEN", 
    -- [5600]玩家或守护复活(真元技能) -- 场景 
    ACK_SCENE_WING_RELIVE            = 5600,[5600] = "ACK_SCENE_WING_RELIVE", 
    -- [5610]恢复血量(真元技能) -- 场景 
    ACK_SCENE_WING_HP                = 5610,[5610] = "ACK_SCENE_WING_HP", 
    -- [5630]切换场景前检查人物是否死亡 -- 场景 
    ACK_SCENE_CHECK_DEATH            = 5630,[5630] = "ACK_SCENE_CHECK_DEATH", 
    -- [5700]组队副本雇佣玩家 -- 场景 
    ACK_SCENE_TEAM_HIRE              = 5700,[5700] = "ACK_SCENE_TEAM_HIRE", 
    -- [5705]技能信息块 -- 场景 
    ACK_SCENE_MSG_SKILL_XXX          = 5705,[5705] = "ACK_SCENE_MSG_SKILL_XXX", 
    -- [5920]场景广播-无敌 -- 场景 
    ACK_SCENE_CHANGE_WUDI            = 5920,[5920] = "ACK_SCENE_CHANGE_WUDI", 
    -- [5921]场景广播-武器 -- 场景 
    ACK_SCENE_CHANGE_WUQI            = 5921,[5921] = "ACK_SCENE_CHANGE_WUQI", 
    -- [5922]场景广播-神羽 -- 场景 
    ACK_SCENE_CHANGE_FEATHER         = 5922,[5922] = "ACK_SCENE_CHANGE_FEATHER", 
    -- [5930]场景广播-帮派 -- 场景 
    ACK_SCENE_CHANGE_CLAN            = 5930,[5930] = "ACK_SCENE_CHANGE_CLAN", 
    -- [5940]场景广播-升级 -- 场景 
    ACK_SCENE_LEVEL_UP               = 5940,[5940] = "ACK_SCENE_LEVEL_UP", 
    -- [5950]场景广播-改变组队 -- 场景 
    ACK_SCENE_CHANGE_TEAM            = 5950,[5950] = "ACK_SCENE_CHANGE_TEAM", 
    -- [5960]场景广播--改变坐骑 -- 场景 
    ACK_SCENE_CHANGE_MOUNT           = 5960,[5960] = "ACK_SCENE_CHANGE_MOUNT", 
    -- [5965]场景广播--改变真元 -- 场景 
    ACK_SCENE_WING                   = 5965,[5965] = "ACK_SCENE_WING", 
    -- [5970]场景广播-改变战斗状态(is_war) -- 场景 
    ACK_SCENE_CHANGE_STATE           = 5970,[5970] = "ACK_SCENE_CHANGE_STATE", 
    -- [5980]场景广播-VIP -- 场景 
    ACK_SCENE_CHANGE_VIP             = 5980,[5980] = "ACK_SCENE_CHANGE_VIP", 
    -- [5990]场景广播-称号 -- 场景 
    ACK_SCENE_CHANG_TITLE            = 5990,[5990] = "ACK_SCENE_CHANG_TITLE", 
    -- [5992]场景广播-神器 -- 场景 
    ACK_SCENE_CHANG_MAGIC            = 5992,[5992] = "ACK_SCENE_CHANG_MAGIC", 
    -- [5994]场景广播-美人 -- 场景 
    ACK_SCENE_CHANG_MEIREN           = 5994,[5994] = "ACK_SCENE_CHANG_MEIREN", 
    -- [5996]场景广播-新手指导员 -- 场景 
    ACK_SCENE_CHANG_GUIDE            = 5996,[5996] = "ACK_SCENE_CHANG_GUIDE", 
    -- [5997]场景广播-改名 -- 场景 
    ACK_SCENE_CHANG_UNAME            = 5997,[5997] = "ACK_SCENE_CHANG_UNAME", 
    -- [5998]场景广播-幽灵 -- 场景 
    ACK_SCENE_CHANGE_STATE_DIE       = 5998,[5998] = "ACK_SCENE_CHANGE_STATE_DIE", 

    --------------------------------------------------------
    -- 6001 - 6500 ( 战斗 ) 
    --------------------------------------------------------
    -- [6010]战斗数据块 -- 战斗 
    ACK_WAR_PLAYER_WAR               = 6010,[6010] = "ACK_WAR_PLAYER_WAR", 
    -- [6015]自身战斗属性加成 -- 战斗 
    ACK_WAR_SELF_ADD                 = 6015,[6015] = "ACK_WAR_SELF_ADD", 
    -- [6021]战斗伤害广播new -- 战斗 
    REQ_WAR_HARM_NEW                 = 6021,[6021] = "REQ_WAR_HARM_NEW", 
    -- [6025]伤害统一发送 -- 战斗 
    REQ_WAR_HARM_ALL                 = 6025,[6025] = "REQ_WAR_HARM_ALL", 
    -- [6030]释放技能广播 -- 战斗 
    ACK_WAR_SKILL                    = 6030,[6030] = "ACK_WAR_SKILL", 
    -- [6040]释放技能 -- 战斗 
    REQ_WAR_USE_SKILL                = 6040,[6040] = "REQ_WAR_USE_SKILL", 
    -- [6050]邀请PK -- 战斗 
    REQ_WAR_PK                       = 6050,[6050] = "REQ_WAR_PK", 
    -- [6053]邀请PK返回 -- 战斗 
    ACK_WAR_PK_REPLY_SELF            = 6053,[6053] = "ACK_WAR_PK_REPLY_SELF", 
    -- [6055]取消邀请 -- 战斗 
    REQ_WAR_PK_CANCEL                = 6055,[6055] = "REQ_WAR_PK_CANCEL", 
    -- [6057]取消邀请返回 -- 战斗 
    ACK_WAR_PK_CANCEL_REPLY          = 6057,[6057] = "ACK_WAR_PK_CANCEL_REPLY", 
    -- [6060]收到切磋请求 -- 战斗 
    ACK_WAR_PK_RECEIVE               = 6060,[6060] = "ACK_WAR_PK_RECEIVE", 
    -- [6061]PK时间 -- 战斗 
    ACK_WAR_PK_TIME                  = 6061,[6061] = "ACK_WAR_PK_TIME", 
    -- [6070]切磋请求反馈 -- 战斗 
    REQ_WAR_PK_REPLY                 = 6070,[6070] = "REQ_WAR_PK_REPLY", 
    -- [6080]PK结束死亡广播 -- 战斗 
    ACK_WAR_PK_LOSE                  = 6080,[6080] = "ACK_WAR_PK_LOSE", 
    -- [6090]怪物击倒 -- 战斗 
    REQ_WAR_DOWN                     = 6090,[6090] = "REQ_WAR_DOWN", 
    -- [6100]请求更新血量 -- 战斗 
    REQ_WAR_HP_REQUEST               = 6100,[6100] = "REQ_WAR_HP_REQUEST", 
    -- [6110]血量更新返回 -- 战斗 
    ACK_WAR_HP_REPLY                 = 6110,[6110] = "ACK_WAR_HP_REPLY", 
    -- [6115]组队血量更新返回 -- 战斗 
    ACK_WAR_HP_REPLY2                = 6115,[6115] = "ACK_WAR_HP_REPLY2", 
    -- [6120]战斗技能验证 -- 战斗 
    REQ_WAR_SKILL_CHECK              = 6120,[6120] = "REQ_WAR_SKILL_CHECK", 
    -- [6125]技能信息块 -- 战斗 
    REQ_WAR_MSG_SKILL                = 6125,[6125] = "REQ_WAR_MSG_SKILL", 
    -- [6130]技能持续伤害 -- 战斗 
    REQ_WAR_SKILL_HARM               = 6130,[6130] = "REQ_WAR_SKILL_HARM", 
    -- [6200]PVP时间同步(请求) -- 战斗 
    REQ_WAR_PVP_TIME                 = 6200,[6200] = "REQ_WAR_PVP_TIME", 
    -- [6205]PVP时间同步(返回) -- 战斗 
    ACK_WAR_PVP_TIME_BACK            = 6205,[6205] = "ACK_WAR_PVP_TIME_BACK", 
    -- [6210]PVP玩家状态(上报) -- 战斗 
    REQ_WAR_PVP_STATE_UPLOAD         = 6210,[6210] = "REQ_WAR_PVP_STATE_UPLOAD", 
    -- [6215]PVP玩家状态信息(接收协议快) -- 战斗 
    ACK_WAR_PVP_STATE_GROUP          = 6215,[6215] = "ACK_WAR_PVP_STATE_GROUP", 
    -- [6220]PVP使用技能(请求) -- 战斗 
    REQ_WAR_PVP_USE_SKILL            = 6220,[6220] = "REQ_WAR_PVP_USE_SKILL", 
    -- [6225]PVP使用技能返回 -- 战斗 
    ACK_WAR_PVP_SKILL_BACK           = 6225,[6225] = "ACK_WAR_PVP_SKILL_BACK", 
    -- [6230]PVP玩家状态信息(请求) -- 战斗 
    REQ_WAR_PVP_STATE_REQ            = 6230,[6230] = "REQ_WAR_PVP_STATE_REQ", 
    -- [6235]PVP玩家状态(返回) -- 战斗 
    ACK_WAR_PVP_STATE_BACK           = 6235,[6235] = "ACK_WAR_PVP_STATE_BACK", 
    -- [6250]PVP发送行走数据 -- 战斗 
    REQ_WAR_PVP_MOVE                 = 6250,[6250] = "REQ_WAR_PVP_MOVE", 
    -- [6255]PVP发送技能数据 -- 战斗 
    REQ_WAR_PVP_SKILL                = 6255,[6255] = "REQ_WAR_PVP_SKILL", 
    -- [6260]PVP指令数据返回 -- 战斗 
    ACK_WAR_PVP_FRAME_MSG            = 6260,[6260] = "ACK_WAR_PVP_FRAME_MSG", 

    --------------------------------------------------------
    -- 6501 - 7000 ( 技能 ) 
    --------------------------------------------------------
    -- [6510]请求技能列表 -- 技能 
    REQ_SKILL_REQUEST                = 6510,[6510] = "REQ_SKILL_REQUEST", 
    -- [6520]技能列表数据 -- 技能 
    ACK_SKILL_LIST                   = 6520,[6520] = "ACK_SKILL_LIST", 
    -- [6525]升级技能 -- 技能 
    REQ_SKILL_LEARN                  = 6525,[6525] = "REQ_SKILL_LEARN", 
    -- [6530]技能信息 -- 技能 
    ACK_SKILL_INFO                   = 6530,[6530] = "ACK_SKILL_INFO", 
    -- [6540]装备技能 -- 技能 
    REQ_SKILL_EQUIP                  = 6540,[6540] = "REQ_SKILL_EQUIP", 
    -- [6545]装备技能信息 -- 技能 
    ACK_SKILL_EQUIP_INFO             = 6545,[6545] = "ACK_SKILL_EQUIP_INFO", 
    -- [6550]请求伙伴技能列表 -- 技能 
    REQ_SKILL_PARTNER                = 6550,[6550] = "REQ_SKILL_PARTNER", 
    -- [6555]请求学习技能 -- 技能 
    REQ_SKILL_UPPARENTLV             = 6555,[6555] = "REQ_SKILL_UPPARENTLV", 
    -- [6560]伙伴技能信息 -- 技能 
    ACK_SKILL_PARENTINFO             = 6560,[6560] = "ACK_SKILL_PARENTINFO", 

    --------------------------------------------------------
    -- 7001 - 8000 ( 副本 ) 
    --------------------------------------------------------
    -- [7005]请求所有通过副本 -- 副本 
    REQ_COPY_REQUEST_ALL             = 7005,[7005] = "REQ_COPY_REQUEST_ALL", 
    -- [7008]请求所有通过副本返回 -- 副本 
    ACK_COPY_ALL_REPLY               = 7008,[7008] = "ACK_COPY_ALL_REPLY", 
    -- [7010]章节信息 -- 副本 
    ACK_COPY_CHAP_DATA               = 7010,[7010] = "ACK_COPY_CHAP_DATA", 
    -- [7014]请求单个章节副本 -- 副本 
    REQ_COPY_REQUEST                 = 7014,[7014] = "REQ_COPY_REQUEST", 
    -- [7018]单个章节副本返回 -- 副本 
    ACK_COPY_CHAP_REPLY              = 7018,[7018] = "ACK_COPY_CHAP_REPLY", 
    -- [7022]副本信息块 -- 副本 
    ACK_COPY_COPY_DATA               = 7022,[7022] = "ACK_COPY_COPY_DATA", 
    -- [7024]请求副本是否开启 -- 副本 
    REQ_COPY_COPY_OPEN               = 7024,[7024] = "REQ_COPY_COPY_OPEN", 
    -- [7025]副本是否开启返回 -- 副本 
    ACK_COPY_COPY_OPEN_REPLY         = 7025,[7025] = "ACK_COPY_COPY_OPEN_REPLY", 
    -- [7026]单个副本信息块 -- 副本 
    ACK_COPY_COPY_ONE                = 7026,[7026] = "ACK_COPY_COPY_ONE", 
    -- [7028]请求一组副本 -- 副本 
    REQ_COPY_REQUEST_COPY            = 7028,[7028] = "REQ_COPY_REQUEST_COPY", 
    -- [7030]创建进入副本 -- 副本 
    REQ_COPY_CREAT                   = 7030,[7030] = "REQ_COPY_CREAT", 
    -- [7031](NEW)创建进入副本 -- 副本 
    REQ_COPY_NEW_CREAT               = 7031,[7031] = "REQ_COPY_NEW_CREAT", 
    -- [7032]验证通过 -- 副本 
    ACK_COPY_THROUGH                 = 7032,[7032] = "ACK_COPY_THROUGH", 
    -- [7040]副本计时 -- 副本 
    REQ_COPY_TIMING                  = 7040,[7040] = "REQ_COPY_TIMING", 
    -- [7050]时间同步 -- 副本 
    ACK_COPY_TIME_UPDATE             = 7050,[7050] = "ACK_COPY_TIME_UPDATE", 
    -- [7060]场景时间同步(生存,限时类型),倒计时 -- 副本 
    ACK_COPY_SCENE_TIME              = 7060,[7060] = "ACK_COPY_SCENE_TIME", 
    -- [7065]场景时间开始计时 -- 副本 
    ACK_COPY_SCENE_TIME2             = 7065,[7065] = "ACK_COPY_SCENE_TIME2", 
    -- [7070]请求精英魔王已进入和全部次数 -- 副本 
    REQ_COPY_IN_ALL                  = 7070,[7070] = "REQ_COPY_IN_ALL", 
    -- [7080]已进入和完成次数返回 -- 副本 
    ACK_COPY_IN_ALL_REPLY            = 7080,[7080] = "ACK_COPY_IN_ALL_REPLY", 
    -- [7110]挂机状态 -- 副本 
    ACK_COPY_UP_STATE                = 7110,[7110] = "ACK_COPY_UP_STATE", 
    -- [7120]妖王来袭通知 -- 副本 
    ACK_COPY_BOSS_NOTICE             = 7120,[7120] = "ACK_COPY_BOSS_NOTICE", 
    -- [7130]功能开放状态 -- 副本 
    ACK_COPY_STRONG_STATE            = 7130,[7130] = "ACK_COPY_STRONG_STATE", 
    -- [7140]请求购买挑战次数 -- 副本 
    REQ_COPY_BUY_REQUEST             = 7140,[7140] = "REQ_COPY_BUY_REQUEST", 
    -- [7710]进入副本场景返回信息 -- 副本 
    ACK_COPY_ENTER_SCENE_INFO        = 7710,[7710] = "ACK_COPY_ENTER_SCENE_INFO", 
    -- [7790]场景目标完成 -- 副本 
    ACK_COPY_SCENE_OVER              = 7790,[7790] = "ACK_COPY_SCENE_OVER", 
    -- [7795]通知副本完成 -- 副本 
    REQ_COPY_NOTICE_OVER             = 7795,[7795] = "REQ_COPY_NOTICE_OVER", 
    -- [7796](NEW)通知副本完成 -- 副本 
    REQ_COPY_NEW_NOTICE_OVER         = 7796,[7796] = "REQ_COPY_NEW_NOTICE_OVER", 
    -- [7800]副本完成 -- 副本 
    ACK_COPY_OVER                    = 7800,[7800] = "ACK_COPY_OVER", 
    -- [7805]副本物品信息块 -- 副本 
    ACK_COPY_MSG_GOODS               = 7805,[7805] = "ACK_COPY_MSG_GOODS", 
    -- [7810]副本失败 -- 副本 
    ACK_COPY_FAIL                    = 7810,[7810] = "ACK_COPY_FAIL", 
    -- [7820]退出副本 -- 副本 
    REQ_COPY_COPY_EXIT               = 7820,[7820] = "REQ_COPY_COPY_EXIT", 
    -- [7830]退出副本成功 -- 副本 
    ACK_COPY_EXIT_OK                 = 7830,[7830] = "ACK_COPY_EXIT_OK", 
    -- [7840]开始挂机 -- 副本 
    REQ_COPY_UP_START                = 7840,[7840] = "REQ_COPY_UP_START", 
    -- [7845]加速挂机 -- 副本 
    REQ_COPY_UP_SPEED                = 7845,[7845] = "REQ_COPY_UP_SPEED", 
    -- [7848]挂机请求 -- 副本 
    REQ_COPY_UP_REQUEST              = 7848,[7848] = "REQ_COPY_UP_REQUEST", 
    -- [7850]挂机返回 -- 副本 
    ACK_COPY_UP_RESULT               = 7850,[7850] = "ACK_COPY_UP_RESULT", 
    -- [7860]挂机完成 -- 副本 
    ACK_COPY_UP_OVER                 = 7860,[7860] = "ACK_COPY_UP_OVER", 
    -- [7864]登陆请求是否挂机 -- 副本 
    REQ_COPY_IS_UP                   = 7864,[7864] = "REQ_COPY_IS_UP", 
    -- [7865]登陆提醒挂机 -- 副本 
    ACK_COPY_LOGIN_NOTICE            = 7865,[7865] = "ACK_COPY_LOGIN_NOTICE", 
    -- [7870]停止挂机 -- 副本 
    REQ_COPY_UP_STOP                 = 7870,[7870] = "REQ_COPY_UP_STOP", 
    -- [7875]请求领取挂机奖励 -- 副本 
    REQ_COPY_UP_REWARD_GET           = 7875,[7875] = "REQ_COPY_UP_REWARD_GET", 
    -- [7877]领取挂机奖励返回 -- 副本 
    ACK_COPY_UP_REWARD_REPLY         = 7877,[7877] = "ACK_COPY_UP_REWARD_REPLY", 
    -- [7880]领取章节评价奖励 -- 副本 
    REQ_COPY_CHAP_REWARD             = 7880,[7880] = "REQ_COPY_CHAP_REWARD", 
    -- [7890]查询章节奖励返回 -- 副本 
    ACK_COPY_CHAP_RE_REP             = 7890,[7890] = "ACK_COPY_CHAP_RE_REP", 
    -- [7900]请求物品掉落 -- 副本 
    REQ_COPY_GOODS_ASK               = 7900,[7900] = "REQ_COPY_GOODS_ASK", 
    -- [7910]物品掉落返回 -- 副本 
    ACK_COPY_GOODS_REPLY             = 7910,[7910] = "ACK_COPY_GOODS_REPLY", 
    -- [7920]请求副本怪物数据 -- 副本 
    REQ_COPY_REQUEST_MONSTER         = 7920,[7920] = "REQ_COPY_REQUEST_MONSTER", 
    -- [7925]刷出第几波怪 -- 副本 
    ACK_COPY_IDX_MONSTER             = 7925,[7925] = "ACK_COPY_IDX_MONSTER", 
    -- [7930]怪物刷新 -- 副本 
    ACK_COPY_MONSTER_DATA            = 7930,[7930] = "ACK_COPY_MONSTER_DATA", 
    -- [7940]所有已经领取奖励章节 -- 副本 
    ACK_COPY_CHAP_REAWARD            = 7940,[7940] = "ACK_COPY_CHAP_REAWARD", 
    -- [7950]章节信息块 -- 副本 
    ACK_COPY_MSG_CHAP_ID             = 7950,[7950] = "ACK_COPY_MSG_CHAP_ID", 
    -- [7960]后端通知副本完成 -- 副本 
    ACK_COPY_COPY_OVER_SERVER        = 7960,[7960] = "ACK_COPY_COPY_OVER_SERVER", 
    -- [7970]组队开始前发送全部组员皮肤 -- 副本 
    ACK_COPY_TEAM_SKINS              = 7970,[7970] = "ACK_COPY_TEAM_SKINS", 
    -- [7975]皮肤信息块 -- 副本 
    ACK_COPY_MSG_SKINS               = 7975,[7975] = "ACK_COPY_MSG_SKINS", 
    -- [7980]技能信息块 -- 副本 
    ACK_COPY_MSG_SKILLS              = 7980,[7980] = "ACK_COPY_MSG_SKILLS", 
    -- [7985]副本通关翻牌 -- 副本 
    REQ_COPY_DRAW_REQUEST            = 7985,[7985] = "REQ_COPY_DRAW_REQUEST", 
    -- [7990]通关翻牌返回 -- 副本 
    ACK_COPY_DRAW_REPLY              = 7990,[7990] = "ACK_COPY_DRAW_REPLY", 
    -- [7995]翻牌物品信息块 -- 副本 
    ACK_COPY_MSG_DRAW_XXX            = 7995,[7995] = "ACK_COPY_MSG_DRAW_XXX", 
    -- [7997]准备翻牌 -- 副本 
    REQ_COPY_DRAW_READY              = 7997,[7997] = "REQ_COPY_DRAW_READY", 
    -- [7998]翻牌组队返回 -- 副本 
    ACK_COPY_DRAW_TEAM_REPLY         = 7998,[7998] = "ACK_COPY_DRAW_TEAM_REPLY", 

    --------------------------------------------------------
    -- 8501 - 9000 ( 邮件 ) 
    --------------------------------------------------------
    -- [8501]发送的邮件ID -- 邮件 
    REQ_MAIL_ID_SEND                 = 8501,[8501] = "REQ_MAIL_ID_SEND", 
    -- [8510]请求邮件列表 -- 邮件 
    REQ_MAIL_REQUEST                 = 8510,[8510] = "REQ_MAIL_REQUEST", 
    -- [8512]请求列表成功 -- 邮件 
    ACK_MAIL_LIST                    = 8512,[8512] = "ACK_MAIL_LIST", 
    -- [8513]邮件模块 -- 邮件 
    ACK_MAIL_MODEL                   = 8513,[8513] = "ACK_MAIL_MODEL", 
    -- [8530]请求发送邮件 -- 邮件 
    REQ_MAIL_SEND                    = 8530,[8530] = "REQ_MAIL_SEND", 
    -- [8532]发送邮件成功 -- 邮件 
    ACK_MAIL_OK_SEND                 = 8532,[8532] = "ACK_MAIL_OK_SEND", 
    -- [8540]请求读取邮件 -- 邮件 
    REQ_MAIL_READ                    = 8540,[8540] = "REQ_MAIL_READ", 
    -- [8542]读取邮件成功 -- 邮件 
    ACK_MAIL_INFO                    = 8542,[8542] = "ACK_MAIL_INFO", 
    -- [8543]虚拟物品协议块 -- 邮件 
    ACK_MAIL_VGOODS_MODEL            = 8543,[8543] = "ACK_MAIL_VGOODS_MODEL", 
    -- [8550]提取邮件物品 -- 邮件 
    REQ_MAIL_PICK                    = 8550,[8550] = "REQ_MAIL_PICK", 
    -- [8552]提取物品成功 -- 邮件 
    ACK_MAIL_OK_PICK                 = 8552,[8552] = "ACK_MAIL_OK_PICK", 
    -- [8560]删除邮件 -- 邮件 
    REQ_MAIL_DEL                     = 8560,[8560] = "REQ_MAIL_DEL", 
    -- [8562]邮件移出 -- 邮件 
    ACK_MAIL_OK_DEL                  = 8562,[8562] = "ACK_MAIL_OK_DEL", 
    -- [8563]删除邮件信息块 -- 邮件 
    ACK_MAIL_IDLIST                  = 8563,[8563] = "ACK_MAIL_IDLIST", 
    -- [8580]请求保存邮件 -- 邮件 
    REQ_MAIL_SAVE                    = 8580,[8580] = "REQ_MAIL_SAVE", 
    -- [8590]登录日志检查(邮件、竞技场等) -- 邮件 
    REQ_MAIL_LOGIN_CHECK             = 8590,[8590] = "REQ_MAIL_LOGIN_CHECK", 

    --------------------------------------------------------
    -- 9001 - 9500 ( 防沉迷 ) 
    --------------------------------------------------------
    -- [9020]防沉迷提示 -- 防沉迷 
    ACK_FCM_PROMPT                   = 9020,[9020] = "ACK_FCM_PROMPT", 

    --------------------------------------------------------
    -- 9501 - 10000 ( 聊天 ) 
    --------------------------------------------------------
    -- [9510]发送频道聊天 -- 聊天 
    REQ_CHAT_SEND                    = 9510,[9510] = "REQ_CHAT_SEND", 
    -- [9513]物品信息块 -- 聊天 
    REQ_CHAT_MSG_GOODS_XXX           = 9513,[9513] = "REQ_CHAT_MSG_GOODS_XXX", 
    -- [9515]收到频道聊天 -- 聊天 
    ACK_CHAT_RECE                    = 9515,[9515] = "ACK_CHAT_RECE", 
    -- [9518]聊天错误提示 -- 聊天 
    ACK_CHAT_ERROR                   = 9518,[9518] = "ACK_CHAT_ERROR", 
    -- [9520]发送语音聊天 -- 聊天 
    REQ_CHAT_SEND_YUYIN              = 9520,[9520] = "REQ_CHAT_SEND_YUYIN", 
    -- [9525]收到语音聊天 -- 聊天 
    ACK_CHAT_RECE_YUYIN              = 9525,[9525] = "ACK_CHAT_RECE_YUYIN", 
    -- [9526]发送名字私聊 -- 聊天 
    REQ_CHAT_NAME                    = 9526,[9526] = "REQ_CHAT_NAME", 
    -- [9527]玩家不在线 -- 聊天 
    ACK_CHAT_OFFICE_PLAYER           = 9527,[9527] = "ACK_CHAT_OFFICE_PLAYER", 
    -- [9530]收到私聊 -- 聊天 
    ACK_CHAT_RECE_PM                 = 9530,[9530] = "ACK_CHAT_RECE_PM", 
    -- [9540]请求语音信息 -- 聊天 
    REQ_CHAT_YUYIN_ASK               = 9540,[9540] = "REQ_CHAT_YUYIN_ASK", 
    -- [9550]语音信息返回 -- 聊天 
    ACK_CHAT_YUYIN_REPLY             = 9550,[9550] = "ACK_CHAT_YUYIN_REPLY", 
    -- [9560]请求聊天历史记录 -- 聊天 
    REQ_CHAT_HISTORY_REQUEST         = 9560,[9560] = "REQ_CHAT_HISTORY_REQUEST", 
    -- [9600]GM命令 -- 聊天 
    REQ_CHAT_GM                      = 9600,[9600] = "REQ_CHAT_GM", 

    --------------------------------------------------------
    -- 10001 - 10100 ( 祝福 ) 
    --------------------------------------------------------
    -- [10001]好友祝福 -- 祝福 
    REQ_WISH_SENT                    = 10001,[10001] = "REQ_WISH_SENT", 
    -- [10010]祝福成功 -- 祝福 
    ACK_WISH_SUCCESS                 = 10010,[10010] = "ACK_WISH_SUCCESS", 
    -- [10012]收到好友祝福 -- 祝福 
    ACK_WISH_RECV                    = 10012,[10012] = "ACK_WISH_RECV", 
    -- [10020]领取祝福经验 -- 祝福 
    REQ_WISH_EXPERIENCE              = 10020,[10020] = "REQ_WISH_EXPERIENCE", 
    -- [10022]领取祝福经验成功 -- 祝福 
    ACK_WISH_EXP_SUCCESS             = 10022,[10022] = "ACK_WISH_EXP_SUCCESS", 
    -- [10030]请求祝福经验信息 -- 祝福 
    REQ_WISH_EXP_DATA                = 10030,[10030] = "REQ_WISH_EXP_DATA", 
    -- [10032]祝福经验信息返回 -- 祝福 
    ACK_WISH_EXP_DATA_BACK           = 10032,[10032] = "ACK_WISH_EXP_DATA_BACK", 
    -- [10040]好友升级提示 -- 祝福 
    ACK_WISH_LV_UP                   = 10040,[10040] = "ACK_WISH_LV_UP", 
    -- [10050]双倍信息 -- 祝福 
    REQ_WISH_DOUBLE                  = 10050,[10050] = "REQ_WISH_DOUBLE", 
    -- [10052]双倍信息返回 -- 祝福 
    ACK_WISH_DOUBLE_DATA             = 10052,[10052] = "ACK_WISH_DOUBLE_DATA", 

    --------------------------------------------------------
    -- 10701 - 10800 ( 称号 ) 
    --------------------------------------------------------
    -- [10710]请求称号列表 -- 称号 
    REQ_TITLE_REQUEST                = 10710,[10710] = "REQ_TITLE_REQUEST", 
    -- [10730]称号列表数据返回 -- 称号 
    ACK_TITLE_LIST_BACK              = 10730,[10730] = "ACK_TITLE_LIST_BACK", 
    -- [10740]称号信息块 -- 称号 
    ACK_TITLE_MSG                    = 10740,[10740] = "ACK_TITLE_MSG", 
    -- [10750]穿戴称号 -- 称号 
    REQ_TITLE_DRESS                  = 10750,[10750] = "REQ_TITLE_DRESS", 
    -- [10755]穿戴称号返回结果 -- 称号 
    ACK_TITLE_DRESS_RES              = 10755,[10755] = "ACK_TITLE_DRESS_RES", 
    -- [10760]点击新激活的称号 -- 称号 
    REQ_TITLE_NEW                    = 10760,[10760] = "REQ_TITLE_NEW", 
    -- [10765]点击新称号返回 -- 称号 
    ACK_TITLE_NEW_RES                = 10765,[10765] = "ACK_TITLE_NEW_RES", 
    -- [10770]刷新面板 -- 称号 
    ACK_TITLE_REFRESH                = 10770,[10770] = "ACK_TITLE_REFRESH", 

    --------------------------------------------------------
    -- 10801 - 10900 ( 城镇BOSS ) 
    --------------------------------------------------------
    -- [10810]请求城镇BOSS列表 -- 城镇BOSS 
    REQ_CITY_BOSS_REQUEST            = 10810,[10810] = "REQ_CITY_BOSS_REQUEST", 
    -- [10820]城镇BOSS请求返回 -- 城镇BOSS 
    ACK_CITY_BOSS_REPLY              = 10820,[10820] = "ACK_CITY_BOSS_REPLY", 
    -- [10825]BOSS信息块 -- 城镇BOSS 
    ACK_CITY_BOSS_MSG_XXX            = 10825,[10825] = "ACK_CITY_BOSS_MSG_XXX", 
    -- [10830]请求进入城镇BOSS -- 城镇BOSS 
    REQ_CITY_BOSS_ENTER              = 10830,[10830] = "REQ_CITY_BOSS_ENTER", 
    -- [10850]BOSS信息请求 -- 城镇BOSS 
    REQ_CITY_BOSS_DATA_REQUEST       = 10850,[10850] = "REQ_CITY_BOSS_DATA_REQUEST", 
    -- [10870]玩家死亡协议 -- 城镇BOSS 
    ACK_CITY_BOSS_PLAYER_DIE         = 10870,[10870] = "ACK_CITY_BOSS_PLAYER_DIE", 

    --------------------------------------------------------
    -- 10901 - 12100 ( 真元 ) 
    --------------------------------------------------------
    -- [10910]激活真元 -- 真元 
    REQ_WING_ACTIVATE                = 10910,[10910] = "REQ_WING_ACTIVATE", 
    -- [10920]激活成功 -- 真元 
    ACK_WING_ACTIVATE_BACK           = 10920,[10920] = "ACK_WING_ACTIVATE_BACK", 
    -- [10930]请求真元 -- 真元 
    REQ_WING_REQUEST                 = 10930,[10930] = "REQ_WING_REQUEST", 
    -- [10940]真元信息返回 -- 真元 
    ACK_WING_REPLAY                  = 10940,[10940] = "ACK_WING_REPLAY", 
    -- [10950]真元信息块 -- 真元 
    ACK_WING_XXX_DATA                = 10950,[10950] = "ACK_WING_XXX_DATA", 
    -- [10960]真元强化 -- 真元 
    REQ_WING_STRENGTHEN              = 10960,[10960] = "REQ_WING_STRENGTHEN", 
    -- [10970]强化结果 -- 真元 
    ACK_WING_CUL_RESULT              = 10970,[10970] = "ACK_WING_CUL_RESULT", 
    -- [10980]真元佩戴|卸下 -- 真元 
    REQ_WING_RIDE                    = 10980,[10980] = "REQ_WING_RIDE", 
    -- [10990]佩戴|卸下成功 -- 真元 
    ACK_WING_RIDE_BACK               = 10990,[10990] = "ACK_WING_RIDE_BACK", 
    -- [11000]技能信息块 -- 真元 
    ACK_WING_XXXX                    = 11000,[11000] = "ACK_WING_XXXX", 
    -- [11010]已激活的技能 -- 真元 
    ACK_WING_JH_BACK                 = 11010,[11010] = "ACK_WING_JH_BACK", 

    --------------------------------------------------------
    -- 12101 - 12200 ( 坐骑 ) 
    --------------------------------------------------------
    -- [12110]骑乘|下骑 -- 坐骑 
    REQ_MOUNT_RIDE                   = 12110,[12110] = "REQ_MOUNT_RIDE", 
    -- [12120]骑乘|下骑成功 -- 坐骑 
    ACK_MOUNT_RIDE_BACK              = 12120,[12120] = "ACK_MOUNT_RIDE_BACK", 
    -- [12130]坐骑系统请求 -- 坐骑 
    REQ_MOUNT_REQUEST                = 12130,[12130] = "REQ_MOUNT_REQUEST", 
    -- [12135]坐骑系统请求返回 -- 坐骑 
    ACK_MOUNT_MOUNT_REPLY            = 12135,[12135] = "ACK_MOUNT_MOUNT_REPLY", 
    -- [12140]坐骑信息块 -- 坐骑 
    ACK_MOUNT_XXX_DATA               = 12140,[12140] = "ACK_MOUNT_XXX_DATA", 
    -- [12145]坐骑培养 -- 坐骑 
    REQ_MOUNT_UP_MOUNT               = 12145,[12145] = "REQ_MOUNT_UP_MOUNT", 
    -- [12155]坐骑培养结果 -- 坐骑 
    ACK_MOUNT_CUL_RESULT             = 12155,[12155] = "ACK_MOUNT_CUL_RESULT", 
    -- [12160]激活坐骑 -- 坐骑 
    REQ_MOUNT_ACTIVATE               = 12160,[12160] = "REQ_MOUNT_ACTIVATE", 
    -- [12170]激活成功 -- 坐骑 
    ACK_MOUNT_ACTIVATE_BACK          = 12170,[12170] = "ACK_MOUNT_ACTIVATE_BACK", 

    --------------------------------------------------------
    -- 12201 - 14000 ( 封神榜 ) 
    --------------------------------------------------------
    -- [12210]请求界面 -- 封神榜 
    REQ_EXPEDIT_REQUEST              = 12210,[12210] = "REQ_EXPEDIT_REQUEST", 
    -- [12220]面板信息 -- 封神榜 
    ACK_EXPEDIT_REPLY                = 12220,[12220] = "ACK_EXPEDIT_REPLY", 
    -- [12230]战报信息块 -- 封神榜 
    ACK_EXPEDIT_LOGS                 = 12230,[12230] = "ACK_EXPEDIT_LOGS", 
    -- [12240]开始匹配 -- 封神榜 
    REQ_EXPEDIT_BEGIN                = 12240,[12240] = "REQ_EXPEDIT_BEGIN", 
    -- [12242]对手信息 -- 封神榜 
    ACK_EXPEDIT_PK                   = 12242,[12242] = "ACK_EXPEDIT_PK", 
    -- [12245]开始战斗 -- 封神榜 
    REQ_EXPEDIT_FIGHT                = 12245,[12245] = "REQ_EXPEDIT_FIGHT", 
    -- [12250]战斗结果 -- 封神榜 
    REQ_EXPEDIT_FINISH               = 12250,[12250] = "REQ_EXPEDIT_FINISH", 
    -- [12252]结果返回 -- 封神榜 
    ACK_EXPEDIT_FINISH_MSG           = 12252,[12252] = "ACK_EXPEDIT_FINISH_MSG", 
    -- [12260]加次数 -- 封神榜 
    REQ_EXPEDIT_MATCH_TIMES          = 12260,[12260] = "REQ_EXPEDIT_MATCH_TIMES", 
    -- [12262]加次数成功 -- 封神榜 
    ACK_EXPEDIT_TIMES_SUCCESS        = 12262,[12262] = "ACK_EXPEDIT_TIMES_SUCCESS", 
    -- [12270]开始匹配(new) -- 封神榜 
    REQ_EXPEDIT_BEGIN_NEW            = 12270,[12270] = "REQ_EXPEDIT_BEGIN_NEW", 
    -- [12275]对手信息(new) -- 封神榜 
    ACK_EXPEDIT_PK_NEW               = 12275,[12275] = "ACK_EXPEDIT_PK_NEW", 

    --------------------------------------------------------
    -- 14001 - 16000 ( 阵营 ) 
    --------------------------------------------------------
    -- [14001]请求阵营信息 -- 阵营 
    REQ_COUNTRY_INFO                 = 14001,[14001] = "REQ_COUNTRY_INFO", 
    -- [14002]阵营信息 -- 阵营 
    ACK_COUNTRY_INFO_RESULT          = 14002,[14002] = "ACK_COUNTRY_INFO_RESULT", 
    -- [14010]选择阵营 -- 阵营 
    REQ_COUNTRY_SELECT               = 14010,[14010] = "REQ_COUNTRY_SELECT", 
    -- [14015]选择阵营结果 -- 阵营 
    ACK_COUNTRY_SELECT_RESULT        = 14015,[14015] = "ACK_COUNTRY_SELECT_RESULT", 
    -- [14020]改变阵营--前奏 -- 阵营 
    REQ_COUNTRY_CHANGE_PRE           = 14020,[14020] = "REQ_COUNTRY_CHANGE_PRE", 
    -- [14025]改变阵营 -- 阵营 
    REQ_COUNTRY_CHANGE               = 14025,[14025] = "REQ_COUNTRY_CHANGE", 
    -- [14027]改变阵营返回 -- 阵营 
    ACK_COUNTRY_CHANGE_RESULT        = 14027,[14027] = "ACK_COUNTRY_CHANGE_RESULT", 
    -- [14030]阵营排名 -- 阵营 
    REQ_COUNTRY_RANK                 = 14030,[14030] = "REQ_COUNTRY_RANK", 
    -- [14035]阵营排名结果 -- 阵营 
    ACK_COUNTRY_RANK_RESULT          = 14035,[14035] = "ACK_COUNTRY_RANK_RESULT", 
    -- [14040]发布阵营公告 -- 阵营 
    REQ_COUNTRY_PUBLISH_NOTICE       = 14040,[14040] = "REQ_COUNTRY_PUBLISH_NOTICE", 
    -- [14045]发布阵营公告返回(阵营广播) -- 阵营 
    ACK_COUNTRY_PUBLISH_NOTICE_R     = 14045,[14045] = "ACK_COUNTRY_PUBLISH_NOTICE_R", 
    -- [14050]任命官员 -- 阵营 
    REQ_COUNTRY_POST_APPOINT         = 14050,[14050] = "REQ_COUNTRY_POST_APPOINT", 
    -- [14060]罢免官员 -- 阵营 
    REQ_COUNTRY_POST_RECALL          = 14060,[14060] = "REQ_COUNTRY_POST_RECALL", 
    -- [14070]官员辞职 -- 阵营 
    REQ_COUNTRY_POST_RESIGN          = 14070,[14070] = "REQ_COUNTRY_POST_RESIGN", 
    -- [14080]阵营职位改变消息通知(阵营广播) -- 阵营 
    ACK_COUNTRY_POST_NOTICE          = 14080,[14080] = "ACK_COUNTRY_POST_NOTICE", 
    -- [14090]阵营事件广播 -- 阵营 
    ACK_COUNTRY_EVENT_BROADCAST      = 14090,[14090] = "ACK_COUNTRY_EVENT_BROADCAST", 

    --------------------------------------------------------
    -- 16001 - 16100 ( 节日活动 ) 
    --------------------------------------------------------
    -- [16010]收集物品 -- 节日活动 
    REQ_FESTIVAL_COLLECT_REQ         = 16010,[16010] = "REQ_FESTIVAL_COLLECT_REQ", 
    -- [16012]收集面板返回 -- 节日活动 
    ACK_FESTIVAL_COLLECT_REP         = 16012,[16012] = "ACK_FESTIVAL_COLLECT_REP", 
    -- [16015]礼包领取次数 -- 节日活动 
    ACK_FESTIVAL_PACKS               = 16015,[16015] = "ACK_FESTIVAL_PACKS", 
    -- [16020]收集物品领取(旧) -- 节日活动 
    REQ_FESTIVAL_COLLECT_GET         = 16020,[16020] = "REQ_FESTIVAL_COLLECT_GET", 
    -- [16022]领取成功 -- 节日活动 
    ACK_FESTIVAL_OK                  = 16022,[16022] = "ACK_FESTIVAL_OK", 
    -- [16030]使用礼包(旧) -- 节日活动 
    REQ_FESTIVAL_PACKS_GET           = 16030,[16030] = "REQ_FESTIVAL_PACKS_GET", 
    -- [16032]购买成功 -- 节日活动 
    ACK_FESTIVAL_OPEN                = 16032,[16032] = "ACK_FESTIVAL_OPEN", 
    -- [16040]时间(旧) -- 节日活动 
    REQ_FESTIVAL_TIME                = 16040,[16040] = "REQ_FESTIVAL_TIME", 
    -- [16042]时间返送(旧) -- 节日活动 
    ACK_FESTIVAL_GET_TIME            = 16042,[16042] = "ACK_FESTIVAL_GET_TIME", 
    -- [16050]时间及活动返送(不用) -- 节日活动 
    REQ_FESTIVAL_TIME_NEW            = 16050,[16050] = "REQ_FESTIVAL_TIME_NEW", 
    -- [16052]时间及活动返送(不用) -- 节日活动 
    ACK_FESTIVAL_GETTIME_NEW         = 16052,[16052] = "ACK_FESTIVAL_GETTIME_NEW", 
    -- [16060]收集物品奖励(新) -- 节日活动 
    REQ_FESTIVAL_COLLECT_NEW         = 16060,[16060] = "REQ_FESTIVAL_COLLECT_NEW", 
    -- [16070]购买礼包 -- 节日活动 
    REQ_FESTIVAL_PACKS_NEW           = 16070,[16070] = "REQ_FESTIVAL_PACKS_NEW", 

    --------------------------------------------------------
    -- 16101 - 16500 ( 开服七天 ) 
    --------------------------------------------------------
    -- [16110]开服七天 -- 开服七天 
    REQ_OPEN_REQUEST                 = 16110,[16110] = "REQ_OPEN_REQUEST", 
    -- [16112]开服返回 -- 开服七天 
    ACK_OPEN_REPLY                   = 16112,[16112] = "ACK_OPEN_REPLY", 
    -- [16114]领取id对应剩余次数 -- 开服七天 
    ACK_OPEN_MSG_TIMES               = 16114,[16114] = "ACK_OPEN_MSG_TIMES", 
    -- [16120]领取 -- 开服七天 
    REQ_OPEN_GET                     = 16120,[16120] = "REQ_OPEN_GET", 
    -- [16125]领取成功返回 -- 开服七天 
    ACK_OPEN_OPEN_GET_CB             = 16125,[16125] = "ACK_OPEN_OPEN_GET_CB", 
    -- [16130]服务器次数 -- 开服七天 
    ACK_OPEN_SERVER                  = 16130,[16130] = "ACK_OPEN_SERVER", 
    -- [16135]角标 -- 开服七天 
    REQ_OPEN_ICON_TIME               = 16135,[16135] = "REQ_OPEN_ICON_TIME", 
    -- [16142]返回所有类型上标次数 -- 开服七天 
    ACK_OPEN_ALLLOGO                 = 16142,[16142] = "ACK_OPEN_ALLLOGO", 
    -- [16144]类型与上标次数 -- 开服七天 
    ACK_OPEN_MSG_ALLLOGO             = 16144,[16144] = "ACK_OPEN_MSG_ALLLOGO", 
    -- [16159]排行榜请求 -- 开服七天 
    REQ_OPEN_RANK_REQUEST            = 16159,[16159] = "REQ_OPEN_RANK_REQUEST", 
    -- [16160]排行榜 -- 开服七天 
    ACK_OPEN_OPEN_RANK               = 16160,[16160] = "ACK_OPEN_OPEN_RANK", 
    -- [16165]排行信息块 -- 开服七天 
    ACK_OPEN_OPEN_RANK_MSG           = 16165,[16165] = "ACK_OPEN_OPEN_RANK_MSG", 
    -- [16170]开服第几天 -- 开服七天 
    REQ_OPEN_DAY_REQUEST             = 16170,[16170] = "REQ_OPEN_DAY_REQUEST", 
    -- [16175]开服返回 -- 开服七天 
    ACK_OPEN_DAY_CB                  = 16175,[16175] = "ACK_OPEN_DAY_CB", 

    --------------------------------------------------------
    -- 16501 - 16600 ( 积分转盘 ) 
    --------------------------------------------------------
    -- [16510]请求积分转盘 -- 积分转盘 
    REQ_POINTS_WHEEL_REQUEST         = 16510,[16510] = "REQ_POINTS_WHEEL_REQUEST", 
    -- [16522]充值积分转盘 -- 积分转盘 
    ACK_POINTS_WHEEL_FULL_REP        = 16522,[16522] = "ACK_POINTS_WHEEL_FULL_REP", 
    -- [16532]消费积分转盘 -- 积分转盘 
    ACK_POINTS_WHEEL_USE_REP         = 16532,[16532] = "ACK_POINTS_WHEEL_USE_REP", 
    -- [16540]开始充值转盘 -- 积分转盘 
    REQ_POINTS_WHEEL_FULL            = 16540,[16540] = "REQ_POINTS_WHEEL_FULL", 
    -- [16542]充值转盘获得返回 -- 积分转盘 
    ACK_POINTS_WHEEL_FULLREP         = 16542,[16542] = "ACK_POINTS_WHEEL_FULLREP", 
    -- [16550]开始消费转盘 -- 积分转盘 
    REQ_POINTS_WHEEL_USE             = 16550,[16550] = "REQ_POINTS_WHEEL_USE", 
    -- [16552]消费转盘获得返回 -- 积分转盘 
    ACK_POINTS_WHEEL_USEREP          = 16552,[16552] = "ACK_POINTS_WHEEL_USEREP", 

    --------------------------------------------------------
    -- 16601 - 16700 ( 练功系统 ) 
    --------------------------------------------------------
    -- [16610]请求练功界面 -- 练功系统 
    REQ_PRACTICE_REQUEST             = 16610,[16610] = "REQ_PRACTICE_REQUEST", 
    -- [16612]练功返回 -- 练功系统 
    ACK_PRACTICE_REPLY               = 16612,[16612] = "ACK_PRACTICE_REPLY", 
    -- [16620]领取练功经验 -- 练功系统 
    REQ_PRACTICE_COLLECT             = 16620,[16620] = "REQ_PRACTICE_COLLECT", 
    -- [16622]领取成功 -- 练功系统 
    ACK_PRACTICE_COLLECT_REP         = 16622,[16622] = "ACK_PRACTICE_COLLECT_REP", 

    --------------------------------------------------------
    -- 16701 - 16800 ( 精彩活动 ) 
    --------------------------------------------------------
    -- [16710]请求面板 -- 精彩活动 
    REQ_ART_CONSUME                  = 16710,[16710] = "REQ_ART_CONSUME", 
    -- [16712]面板返回 -- 精彩活动 
    ACK_ART_CONSUME_REPLY            = 16712,[16712] = "ACK_ART_CONSUME_REPLY", 
    -- [16715]活动id的信息块 -- 精彩活动 
    ACK_ART_MSG_CONSUME              = 16715,[16715] = "ACK_ART_MSG_CONSUME", 
    -- [16716]Id_sub状态 -- 精彩活动 
    ACK_ART_ID_STATE                 = 16716,[16716] = "ACK_ART_ID_STATE", 
    -- [16717]奖励物品信息快 -- 精彩活动 
    ACK_ART_GOOD_INFO                = 16717,[16717] = "ACK_ART_GOOD_INFO", 
    -- [16720]领取 -- 精彩活动 
    REQ_ART_CONSUME_GET              = 16720,[16720] = "REQ_ART_CONSUME_GET", 
    -- [16725]精彩活动节日奖励翻倍 -- 精彩活动 
    ACK_ART_HOLIDAY                  = 16725,[16725] = "ACK_ART_HOLIDAY", 
    -- [16740]请求排行 -- 精彩活动 
    REQ_ART_FULL                     = 16740,[16740] = "REQ_ART_FULL", 
    -- [16742]领取成功返回 -- 精彩活动 
    ACK_ART_SUCCESS_GET              = 16742,[16742] = "ACK_ART_SUCCESS_GET", 
    -- [16749]排行 -- 精彩活动 
    ACK_ART_RANK_TOP                 = 16749,[16749] = "ACK_ART_RANK_TOP", 
    -- [16750]排行榜 -- 精彩活动 
    ACK_ART_RANK                     = 16750,[16750] = "ACK_ART_RANK", 
    -- [16755]信息块 -- 精彩活动 
    ACK_ART_MSG_RANK                 = 16755,[16755] = "ACK_ART_MSG_RANK", 
    -- [16760]角标 -- 精彩活动 
    REQ_ART_ICON_TIME                = 16760,[16760] = "REQ_ART_ICON_TIME", 
    -- [16765]角标返回 -- 精彩活动 
    ACK_ART_ICON_CB                  = 16765,[16765] = "ACK_ART_ICON_CB", 
    -- [16770]信息块 -- 精彩活动 
    ACK_ART_ICON_MSG                 = 16770,[16770] = "ACK_ART_ICON_MSG", 
    -- [16771]领取奖励 -- 精彩活动 
    REQ_ART_REWARD                   = 16771,[16771] = "REQ_ART_REWARD", 
    -- [16772]领取奖励成功 -- 精彩活动 
    ACK_ART_REWARD_OK                = 16772,[16772] = "ACK_ART_REWARD_OK", 
    -- [16775]福泽天下请求面板 -- 精彩活动 
    REQ_ART_FZTX_REQUEST             = 16775,[16775] = "REQ_ART_FZTX_REQUEST", 
    -- [16780]福泽天下请求回 -- 精彩活动 
    ACK_ART_FZTX_CB                  = 16780,[16780] = "ACK_ART_FZTX_CB", 
    -- [16783]福泽天下信息块 -- 精彩活动 
    ACK_ART_MSG1                     = 16783,[16783] = "ACK_ART_MSG1", 
    -- [16785]福泽天下信息块2 -- 精彩活动 
    ACK_ART_MSG2                     = 16785,[16785] = "ACK_ART_MSG2", 
    -- [16790]领取福泽天下 -- 精彩活动 
    REQ_ART_GET_FZTX                 = 16790,[16790] = "REQ_ART_GET_FZTX", 
    -- [16793]福泽天下领取返回 -- 精彩活动 
    ACK_ART_GET_FZTX_CB              = 16793,[16793] = "ACK_ART_GET_FZTX_CB", 
    -- [16794]充值界面请求 -- 精彩活动 
    REQ_ART_CHARG_REQUEST            = 16794,[16794] = "REQ_ART_CHARG_REQUEST", 
    -- [16795]充值界面倍数显示 -- 精彩活动 
    ACK_ART_PER_CHARGE               = 16795,[16795] = "ACK_ART_PER_CHARGE", 
    -- [16796]充值信息块 -- 精彩活动 
    ACK_ART_MSG_CHARGE               = 16796,[16796] = "ACK_ART_MSG_CHARGE", 
    -- [16797]转盘活动物品 -- 精彩活动 
    REQ_ART_ZHUANPAN                 = 16797,[16797] = "REQ_ART_ZHUANPAN", 
    -- [16798]转盘物品(回) -- 精彩活动 
    ACK_ART_ZHUANPAN_GOOD            = 16798,[16798] = "ACK_ART_ZHUANPAN_GOOD", 
    -- [16799]信息块1798 -- 精彩活动 
    ACK_ART_ZHUANPAN_GOODMSG         = 16799,[16799] = "ACK_ART_ZHUANPAN_GOODMSG", 

    --------------------------------------------------------
    -- 18001 - 18100 ( 降魔之路 ) 
    --------------------------------------------------------
    -- [18010]请求界面 -- 降魔之路 
    REQ_XMZL_REQUEST                 = 18010,[18010] = "REQ_XMZL_REQUEST", 
    -- [18020]请求界面返回 -- 降魔之路 
    ACK_XMZL_REPLY                   = 18020,[18020] = "ACK_XMZL_REPLY", 
    -- [18025]属性块 -- 降魔之路 
    ACK_XMZL_ATTR_XXX                = 18025,[18025] = "ACK_XMZL_ATTR_XXX", 
    -- [18030]属性加点 -- 降魔之路 
    REQ_XMZL_ATTR_POINT_ADD          = 18030,[18030] = "REQ_XMZL_ATTR_POINT_ADD", 
    -- [18040]出战星宿 -- 降魔之路 
    REQ_XMZL_WING_CHEER              = 18040,[18040] = "REQ_XMZL_WING_CHEER", 
    -- [18050]出战星宿返回 -- 降魔之路 
    ACK_XMZL_WING_CHEER_REPLY        = 18050,[18050] = "ACK_XMZL_WING_CHEER_REPLY", 
    -- [18055]重置属性点 -- 降魔之路 
    REQ_XMZL_ATTR_POINT_RESET        = 18055,[18055] = "REQ_XMZL_ATTR_POINT_RESET", 
    -- [18060]属性重置成功 -- 降魔之路 
    ACK_XMZL_ATTR_POINT_REPLY        = 18060,[18060] = "ACK_XMZL_ATTR_POINT_REPLY", 
    -- [18065]属性点更新 -- 降魔之路 
    ACK_XMZL_ATTR_POINT              = 18065,[18065] = "ACK_XMZL_ATTR_POINT", 
    -- [18070]副本信息 -- 降魔之路 
    ACK_XMZL_COPYS                   = 18070,[18070] = "ACK_XMZL_COPYS", 
    -- [18075]副本信息块 -- 降魔之路 
    ACK_XMZL_COPY_XXX                = 18075,[18075] = "ACK_XMZL_COPY_XXX", 
    -- [18080]进入副本信息 -- 降魔之路 
    ACK_XMZL_PLAYER_INFO             = 18080,[18080] = "ACK_XMZL_PLAYER_INFO", 

    --------------------------------------------------------
    -- 18101 - 19100 ( 荣誉 ) 
    --------------------------------------------------------
    -- [18110]请求荣誉列表 -- 荣誉 
    REQ_HONOR_LIST_REQUEST           = 18110,[18110] = "REQ_HONOR_LIST_REQUEST", 
    -- [18120]领取奖励 -- 荣誉 
    REQ_HONOR_REWARD                 = 18120,[18120] = "REQ_HONOR_REWARD", 
    -- [18125]领取成功 -- 荣誉 
    ACK_HONOR_REWARD_OK              = 18125,[18125] = "ACK_HONOR_REWARD_OK", 
    -- [18130]荣誉状态列表 -- 荣誉 
    ACK_HONOR_LIST_RETURN            = 18130,[18130] = "ACK_HONOR_LIST_RETURN", 
    -- [18150]荣誉达成提示 -- 荣誉 
    ACK_HONOR_REACH_TIP              = 18150,[18150] = "ACK_HONOR_REACH_TIP", 

    --------------------------------------------------------
    -- 21101 - 21500 ( 活动-保卫经书 ) 
    --------------------------------------------------------
    -- [21110]请求参加怪物攻城 -- 活动-保卫经书 
    REQ_DEFEND_BOOK_REQUEST          = 21110,[21110] = "REQ_DEFEND_BOOK_REQUEST", 
    -- [21120]进入场景 -- 活动-保卫经书 
    ACK_DEFEND_BOOK_INTER_SCENE      = 21120,[21120] = "ACK_DEFEND_BOOK_INTER_SCENE", 
    -- [21122]倒计时 -- 活动-保卫经书 
    ACK_DEFEND_BOOK_TIME             = 21122,[21122] = "ACK_DEFEND_BOOK_TIME", 
    -- [21130]请求场景玩家数据 -- 活动-保卫经书 
    REQ_DEFEND_BOOK_ASK_PLAYER_DATE  = 21130,[21130] = "REQ_DEFEND_BOOK_ASK_PLAYER_DATE", 
    -- [21135]所有怪物数据返回 -- 活动-保卫经书 
    ACK_DEFEND_BOOK_OK_MONST_DATA    = 21135,[21135] = "ACK_DEFEND_BOOK_OK_MONST_DATA", 
    -- [21136]怪物数据组 -- 活动-保卫经书 
    ACK_DEFEND_BOOK_MONSTER          = 21136,[21136] = "ACK_DEFEND_BOOK_MONSTER", 
    -- [21137]怪物数据刷新 -- 活动-保卫经书 
    ACK_DEFEND_BOOK_MONSTER_DATA     = 21137,[21137] = "ACK_DEFEND_BOOK_MONSTER_DATA", 
    -- [21140]玩家对怪伤害值 -- 活动-保卫经书 
    ACK_DEFEND_BOOK_SELF_HARM        = 21140,[21140] = "ACK_DEFEND_BOOK_SELF_HARM", 
    -- [21145]对怪物累计伤害前10排名 -- 活动-保卫经书 
    ACK_DEFEND_BOOK_RANKING          = 21145,[21145] = "ACK_DEFEND_BOOK_RANKING", 
    -- [21150]排行榜数据 -- 活动-保卫经书 
    ACK_DEFEND_BOOK_RANK_DATA        = 21150,[21150] = "ACK_DEFEND_BOOK_RANK_DATA", 
    -- [21160]阵营积分数据 -- 活动-保卫经书 
    ACK_DEFEND_BOOK_CAMP_INTEGRAL    = 21160,[21160] = "ACK_DEFEND_BOOK_CAMP_INTEGRAL", 
    -- [21165]阵营积分数据_新 -- 活动-保卫经书 
    ACK_DEFEND_BOOK_CAMP_INTEGRAL_N  = 21165,[21165] = "ACK_DEFEND_BOOK_CAMP_INTEGRAL_N", 
    -- [21170]战壕数据 -- 活动-保卫经书 
    ACK_DEFEND_BOOK_TRENCH_DATE      = 21170,[21170] = "ACK_DEFEND_BOOK_TRENCH_DATE", 
    -- [21175]单个防守圈玩家数据 -- 活动-保卫经书 
    ACK_DEFEND_BOOK_PLAYER_DATE      = 21175,[21175] = "ACK_DEFEND_BOOK_PLAYER_DATE", 
    -- [21180]战壕玩家信息块 -- 活动-保卫经书 
    ACK_DEFEND_BOOK_DATE_TRENCH      = 21180,[21180] = "ACK_DEFEND_BOOK_DATE_TRENCH", 
    -- [21190]请求选择战壕 -- 活动-保卫经书 
    REQ_DEFEND_BOOK_ASK_TRENCH       = 21190,[21190] = "REQ_DEFEND_BOOK_ASK_TRENCH", 
    -- [21200]请求战壕结果 -- 活动-保卫经书 
    ACK_DEFEND_BOOK_OK_TRENCH        = 21200,[21200] = "ACK_DEFEND_BOOK_OK_TRENCH", 
    -- [21210]开始战斗 -- 活动-保卫经书 
    REQ_DEFEND_BOOK_START_WAR        = 21210,[21210] = "REQ_DEFEND_BOOK_START_WAR", 
    -- [21220]战斗结果返回 -- 活动-保卫经书 
    ACK_DEFEND_BOOK_WAR_RETRUN       = 21220,[21220] = "ACK_DEFEND_BOOK_WAR_RETRUN", 
    -- [21223]战斗怪物更新 -- 活动-保卫经书 
    ACK_DEFEND_BOOK_WAR_MONSTERS     = 21223,[21223] = "ACK_DEFEND_BOOK_WAR_MONSTERS", 
    -- [21225]玩家死亡 -- 活动-保卫经书 
    ACK_DEFEND_BOOK_KILL_PLAYERS     = 21225,[21225] = "ACK_DEFEND_BOOK_KILL_PLAYERS", 
    -- [21227]击杀掉落 -- 活动-保卫经书 
    ACK_DEFEND_BOOK_KILL_REWARDS     = 21227,[21227] = "ACK_DEFEND_BOOK_KILL_REWARDS", 
    -- [21230]请求拾取击杀奖励 -- 活动-保卫经书 
    REQ_DEFEND_BOOK_ASK_GET_REWARDS  = 21230,[21230] = "REQ_DEFEND_BOOK_ASK_GET_REWARDS", 
    -- [21232]拾取击杀奖励 -- 活动-保卫经书 
    ACK_DEFEND_BOOK_OK_GET_REWARDS   = 21232,[21232] = "ACK_DEFEND_BOOK_OK_GET_REWARDS", 
    -- [21240]复活 -- 活动-保卫经书 
    REQ_DEFEND_BOOK_REVIVE           = 21240,[21240] = "REQ_DEFEND_BOOK_REVIVE", 
    -- [21250]复活成功 -- 活动-保卫经书 
    ACK_DEFEND_BOOK_OK_REVIVE        = 21250,[21250] = "ACK_DEFEND_BOOK_OK_REVIVE", 
    -- [21260]请求退出战斗 -- 活动-保卫经书 
    REQ_DEFEND_BOOK_REQUEST_BACK     = 21260,[21260] = "REQ_DEFEND_BOOK_REQUEST_BACK", 
    -- [21270]开启增益 -- 活动-保卫经书 
    ACK_DEFEND_BOOK_START_BUFF       = 21270,[21270] = "ACK_DEFEND_BOOK_START_BUFF", 
    -- [21280]请求领取增益 -- 活动-保卫经书 
    REQ_DEFEND_BOOK_GAIN             = 21280,[21280] = "REQ_DEFEND_BOOK_GAIN", 
    -- [21290]领取增益成功 -- 活动-保卫经书 
    ACK_DEFEND_BOOK_OK_GAIN          = 21290,[21290] = "ACK_DEFEND_BOOK_OK_GAIN", 
    -- [21300]请求更换战壕 -- 活动-保卫经书 
    REQ_DEFEND_BOOK_CHANGE_TRENCH    = 21300,[21300] = "REQ_DEFEND_BOOK_CHANGE_TRENCH", 

    --------------------------------------------------------
    -- 22101 - 22200 ( 浮屠静修 ) 
    --------------------------------------------------------
    -- [22110]请求浮屠静修界面 -- 浮屠静修 
    REQ_FUTU_REQUEST                 = 22110,[22110] = "REQ_FUTU_REQUEST", 
    -- [22120]浮屠静修返回 -- 浮屠静修 
    ACK_FUTU_REPLY                   = 22120,[22120] = "ACK_FUTU_REPLY", 
    -- [22125]浮屠静修信息块 -- 浮屠静修 
    ACK_FUTU_MSG                     = 22125,[22125] = "ACK_FUTU_MSG", 
    -- [22130]浮屠静修单层信息块 -- 浮屠静修 
    ACK_FUTU_MSG2                    = 22130,[22130] = "ACK_FUTU_MSG2", 
    -- [22135]请求购买挑战次数 -- 浮屠静修 
    REQ_FUTU_TIMES_BUY               = 22135,[22135] = "REQ_FUTU_TIMES_BUY", 
    -- [22140]购买次数返回 -- 浮屠静修 
    ACK_FUTU_TIMES_REPLY             = 22140,[22140] = "ACK_FUTU_TIMES_REPLY", 
    -- [22145]请求查看战报 -- 浮屠静修 
    REQ_FUTU_HISTORY_REQ             = 22145,[22145] = "REQ_FUTU_HISTORY_REQ", 
    -- [22150]战报返回 -- 浮屠静修 
    ACK_FUTU_HISTORY_REP             = 22150,[22150] = "ACK_FUTU_HISTORY_REP", 
    -- [22155]历史信息块 -- 浮屠静修 
    ACK_FUTU_HISTORY_MSG             = 22155,[22155] = "ACK_FUTU_HISTORY_MSG", 
    -- [22156]奖励物品信息块 -- 浮屠静修 
    ACK_FUTU_HISTORY_MSG2            = 22156,[22156] = "ACK_FUTU_HISTORY_MSG2", 
    -- [22160]查看玩家 -- 浮屠静修 
    REQ_FUTU_PLAYER_REQ              = 22160,[22160] = "REQ_FUTU_PLAYER_REQ", 
    -- [22165]查看玩家返回 -- 浮屠静修 
    ACK_FUTU_PLAYER_REP              = 22165,[22165] = "ACK_FUTU_PLAYER_REP", 
    -- [22170]离开据点 -- 浮屠静修 
    REQ_FUTU_OUT                     = 22170,[22170] = "REQ_FUTU_OUT", 
    -- [22175]离开据点成功 -- 浮屠静修 
    ACK_FUTU_OUT_SUCCESS             = 22175,[22175] = "ACK_FUTU_OUT_SUCCESS", 
    -- [22180]浮屠静修开始挑战 -- 浮屠静修 
    REQ_FUTU_START                   = 22180,[22180] = "REQ_FUTU_START", 
    -- [22185]浮屠静修挑战结束 -- 浮屠静修 
    REQ_FUTU_OVER                    = 22185,[22185] = "REQ_FUTU_OVER", 
    -- [22190]浮屠静修挑战结束返回 -- 浮屠静修 
    ACK_FUTU_OVER_REP                = 22190,[22190] = "ACK_FUTU_OVER_REP", 
    -- [22195]浮屠静修剩余占领时间 -- 浮屠静修 
    ACK_FUTU_LEFT_TIME               = 22195,[22195] = "ACK_FUTU_LEFT_TIME", 
    -- [22198]查看说明，完成指引任务 -- 浮屠静修 
    REQ_FUTU_TASK_FINISH             = 22198,[22198] = "REQ_FUTU_TASK_FINISH", 

    --------------------------------------------------------
    -- 22201 - 22300 ( 每天消费 ) 
    --------------------------------------------------------
    -- [22210]每天消费界面 -- 每天消费 
    REQ_COST_FACE                    = 22210,[22210] = "REQ_COST_FACE", 
    -- [22212]消费板子返回 -- 每天消费 
    ACK_COST_FACE_BACK               = 22212,[22212] = "ACK_COST_FACE_BACK", 
    -- [22215]已领取奖励 -- 每天消费 
    ACK_COST_USE_ID                  = 22215,[22215] = "ACK_COST_USE_ID", 
    -- [22220]领奖 -- 每天消费 
    REQ_COST_GET                     = 22220,[22220] = "REQ_COST_GET", 
    -- [22222]成功 -- 每天消费 
    ACK_COST_SUCCESS                 = 22222,[22222] = "ACK_COST_SUCCESS", 

    --------------------------------------------------------
    -- 22301 - 22700 ( 节日转盘 ) 
    --------------------------------------------------------
    -- [22310]打开板子 -- 节日转盘 
    REQ_GALATURN_OPEN                = 22310,[22310] = "REQ_GALATURN_OPEN", 
    -- [22311]节日活动返回 -- 节日转盘 
    ACK_GALATURN_FUN_CB              = 22311,[22311] = "ACK_GALATURN_FUN_CB", 
    -- [22312]信息块(id) -- 节日转盘 
    ACK_GALATURN_MSG_ID              = 22312,[22312] = "ACK_GALATURN_MSG_ID", 
    -- [22313]节日转盘面板 -- 节日转盘 
    REQ_GALATURN_GALATURN            = 22313,[22313] = "REQ_GALATURN_GALATURN", 
    -- [22314]板子内容 -- 节日转盘 
    ACK_GALATURN_IN                  = 22314,[22314] = "ACK_GALATURN_IN", 
    -- [22315]转盘物品信息 -- 节日转盘 
    ACK_GALATURN_MSG_TURN_GOOD       = 22315,[22315] = "ACK_GALATURN_MSG_TURN_GOOD", 
    -- [22320]抽奖 -- 节日转盘 
    REQ_GALATURN_LOTTERY             = 22320,[22320] = "REQ_GALATURN_LOTTERY", 
    -- [22322]抽奖成功 -- 节日转盘 
    ACK_GALATURN_LOT_SUCCESS         = 22322,[22322] = "ACK_GALATURN_LOT_SUCCESS", 
    -- [22330]排名 -- 节日转盘 
    REQ_GALATURN_RANK                = 22330,[22330] = "REQ_GALATURN_RANK", 
    -- [22332]排名板子内容 -- 节日转盘 
    ACK_GALATURN_RANK_IN             = 22332,[22332] = "ACK_GALATURN_RANK_IN", 
    -- [22335]排名信息块 -- 节日转盘 
    ACK_GALATURN_RANK_MSG            = 22335,[22335] = "ACK_GALATURN_RANK_MSG", 
    -- [22337]排名物品奖励信息 -- 节日转盘 
    ACK_GALATURN_RANK_GOOD           = 22337,[22337] = "ACK_GALATURN_RANK_GOOD", 
    -- [22338]排行物品信息快 -- 节日转盘 
    ACK_GALATURN_MSG_RANK2_GOOD      = 22338,[22338] = "ACK_GALATURN_MSG_RANK2_GOOD", 
    -- [22340]积分奖励 -- 节日转盘 
    REQ_GALATURN_POINT               = 22340,[22340] = "REQ_GALATURN_POINT", 
    -- [22342]积分板子 -- 节日转盘 
    ACK_GALATURN_POINT_IN            = 22342,[22342] = "ACK_GALATURN_POINT_IN", 
    -- [22345]已领奖id -- 节日转盘 
    ACK_GALATURN_GET_ID              = 22345,[22345] = "ACK_GALATURN_GET_ID", 
    -- [22350]积分领奖 -- 节日转盘 
    REQ_GALATURN_POINT_GET           = 22350,[22350] = "REQ_GALATURN_POINT_GET", 
    -- [22352]领奖成功 -- 节日转盘 
    ACK_GALATURN_POI_SUCCESS         = 22352,[22352] = "ACK_GALATURN_POI_SUCCESS", 
    -- [22355]角标返回 -- 节日转盘 
    ACK_GALATURN_ICON_CB             = 22355,[22355] = "ACK_GALATURN_ICON_CB", 
    -- [22360]活动角标信息块 -- 节日转盘 
    ACK_GALATURN_MSG_ICON            = 22360,[22360] = "ACK_GALATURN_MSG_ICON", 

    --------------------------------------------------------
    -- 22701 - 22800 ( 日志 ) 
    --------------------------------------------------------
    -- [22760]获得|失去通知 -- 日志 
    ACK_GAME_LOGS_NOTICES            = 22760,[22760] = "ACK_GAME_LOGS_NOTICES", 
    -- [22770]信息组协议块 -- 日志 
    ACK_GAME_LOGS_MESS               = 22770,[22770] = "ACK_GAME_LOGS_MESS", 
    -- [22780]事件通知 -- 日志 
    ACK_GAME_LOGS_EVENT              = 22780,[22780] = "ACK_GAME_LOGS_EVENT", 
    -- [22781]字符串信息块 -- 日志 
    ACK_GAME_LOGS_STR_XXX            = 22781,[22781] = "ACK_GAME_LOGS_STR_XXX", 
    -- [22782]数字信息块 -- 日志 
    ACK_GAME_LOGS_INT_XXX            = 22782,[22782] = "ACK_GAME_LOGS_INT_XXX", 

    --------------------------------------------------------
    -- 22801 - 23100 ( 宠物 ) 
    --------------------------------------------------------
    -- [22810]宠物请求 -- 宠物 
    REQ_PET_REQUEST                  = 22810,[22810] = "REQ_PET_REQUEST", 
    -- [22820]返回宠物列表 -- 宠物 
    ACK_PET_REVERSE                  = 22820,[22820] = "ACK_PET_REVERSE", 
    -- [22825]技能信息块 -- 宠物 
    ACK_PET_SKILLS                   = 22825,[22825] = "ACK_PET_SKILLS", 
    -- [22827]皮肤信息块 -- 宠物 
    ACK_PET_SKINS                    = 22827,[22827] = "ACK_PET_SKINS", 
    -- [22850]召唤式神 -- 宠物 
    REQ_PET_CALL                     = 22850,[22850] = "REQ_PET_CALL", 
    -- [22860]召唤式神成功返回 -- 宠物 
    ACK_PET_CALL_OK                  = 22860,[22860] = "ACK_PET_CALL_OK", 
    -- [22870]宠物需消耗钻石数 -- 宠物 
    REQ_PET_NEED_RMB                 = 22870,[22870] = "REQ_PET_NEED_RMB", 
    -- [22875]修炼需要钻石返回 -- 宠物 
    ACK_PET_NEED_RMB_REPLY           = 22875,[22875] = "ACK_PET_NEED_RMB_REPLY", 
    -- [22880]宠物修炼 -- 宠物 
    REQ_PET_XIULIAN                  = 22880,[22880] = "REQ_PET_XIULIAN", 
    -- [22885]魔宠修炼成功返回 -- 宠物 
    ACK_PET_XIULIAN_OK               = 22885,[22885] = "ACK_PET_XIULIAN_OK", 
    -- [22900]宠物幻化 -- 宠物 
    REQ_PET_HUANHUA                  = 22900,[22900] = "REQ_PET_HUANHUA", 
    -- [22950]幻化成功返回 -- 宠物 
    ACK_PET_HUANHUA_REPLY            = 22950,[22950] = "ACK_PET_HUANHUA_REPLY", 
    -- [23000]请求幻化界面 -- 宠物 
    REQ_PET_HUANHUA_REQUEST          = 23000,[23000] = "REQ_PET_HUANHUA_REQUEST", 
    -- [23010]幻化界面返回 -- 宠物 
    ACK_PET_HH_REPLY_MSG             = 23010,[23010] = "ACK_PET_HH_REPLY_MSG", 

    --------------------------------------------------------
    -- 23101 - 23200 ( 活动-地下皇陵 ) 
    --------------------------------------------------------
    -- [23110]请求地下皇陵 -- 活动-地下皇陵 
    REQ_TOMB_REQUEST                 = 23110,[23110] = "REQ_TOMB_REQUEST", 
    -- [23112]探宝返回 -- 活动-地下皇陵 
    ACK_TOMB_REPLY                   = 23112,[23112] = "ACK_TOMB_REPLY", 
    -- [23120]开始探宝 -- 活动-地下皇陵 
    REQ_TOMB_DIG                     = 23120,[23120] = "REQ_TOMB_DIG", 
    -- [23122]获得返回 -- 活动-地下皇陵 
    ACK_TOMB_DIG_REP                 = 23122,[23122] = "ACK_TOMB_DIG_REP", 

    --------------------------------------------------------
    -- 23201 - 23300 ( 活动-全民寻宝 ) 
    --------------------------------------------------------
    -- [23210]请求全民寻宝 -- 活动-全民寻宝 
    REQ_ALLFIND_REQUEST              = 23210,[23210] = "REQ_ALLFIND_REQUEST", 
    -- [23212]寻宝界面返回(旧) -- 活动-全民寻宝 
    ACK_ALLFIND_REPLY                = 23212,[23212] = "ACK_ALLFIND_REPLY", 
    -- [23215]寻宝历史信息块返回(旧) -- 活动-全民寻宝 
    ACK_ALLFIND_MSG                  = 23215,[23215] = "ACK_ALLFIND_MSG", 
    -- [23218]次数信息块(新) -- 活动-全民寻宝 
    ACK_ALLFIND_MSG2                 = 23218,[23218] = "ACK_ALLFIND_MSG2", 
    -- [23220]开始寻宝(旧) -- 活动-全民寻宝 
    REQ_ALLFIND_DIG                  = 23220,[23220] = "REQ_ALLFIND_DIG", 
    -- [23222]寻宝返回 -- 活动-全民寻宝 
    ACK_ALLFIND_DIG_REP              = 23222,[23222] = "ACK_ALLFIND_DIG_REP", 
    -- [23230]请求积分兑换 -- 活动-全民寻宝 
    REQ_ALLFIND_SHOP                 = 23230,[23230] = "REQ_ALLFIND_SHOP", 
    -- [23232]购买成功 -- 活动-全民寻宝 
    ACK_ALLFIND_SHOP_SUCCESS         = 23232,[23232] = "ACK_ALLFIND_SHOP_SUCCESS", 
    -- [23242]寻宝界面返回(新) -- 活动-全民寻宝 
    ACK_ALLFIND_REP_NEW              = 23242,[23242] = "ACK_ALLFIND_REP_NEW", 
    -- [23245]历史信息块(新) -- 活动-全民寻宝 
    ACK_ALLFIND_MSG1                 = 23245,[23245] = "ACK_ALLFIND_MSG1", 
    -- [23250]开始寻宝(新) -- 活动-全民寻宝 
    REQ_ALLFIND_NEW_DIG              = 23250,[23250] = "REQ_ALLFIND_NEW_DIG", 

    --------------------------------------------------------
    -- 23301 - 23800 ( 奖励 ) 
    --------------------------------------------------------
    -- [23310]请求奖励 -- 奖励 
    REQ_REWARD_REQUEST               = 23310,[23310] = "REQ_REWARD_REQUEST", 
    -- [23312]在线领奖返回 -- 奖励 
    ACK_REWARD_ONLINE_REP            = 23312,[23312] = "ACK_REWARD_ONLINE_REP", 
    -- [23322]等级奖励返回 -- 奖励 
    ACK_REWARD_LV_REP                = 23322,[23322] = "ACK_REWARD_LV_REP", 
    -- [23325]等级奖励信息块 -- 奖励 
    ACK_REWARD_LV_MSG                = 23325,[23325] = "ACK_REWARD_LV_MSG", 
    -- [23332]每日领奖返回 -- 奖励 
    ACK_REWARD_DAILY_REP             = 23332,[23332] = "ACK_REWARD_DAILY_REP", 
    -- [23335]每日领奖信息块 -- 奖励 
    ACK_REWARD_DAILY_MSG             = 23335,[23335] = "ACK_REWARD_DAILY_MSG", 
    -- [23450]vip奖励信息 -- 奖励 
    REQ_REWARD_VIP_MSG               = 23450,[23450] = "REQ_REWARD_VIP_MSG", 
    -- [23495]vip奖励信息(返回) -- 奖励 
    ACK_REWARD_VIP_MSG_CB            = 23495,[23495] = "ACK_REWARD_VIP_MSG_CB", 
    -- [23500]vip奖励信息块 -- 奖励 
    ACK_REWARD_VIP_MSG_XXX           = 23500,[23500] = "ACK_REWARD_VIP_MSG_XXX", 
    -- [23505]vip奖励信息块2 -- 奖励 
    ACK_REWARD_VIP_MSG_XXX2          = 23505,[23505] = "ACK_REWARD_VIP_MSG_XXX2", 
    -- [23510]领取在线奖励 -- 奖励 
    REQ_REWARD_ONLINE                = 23510,[23510] = "REQ_REWARD_ONLINE", 
    -- [23520]领取等级奖励 -- 奖励 
    REQ_REWARD_LV                    = 23520,[23520] = "REQ_REWARD_LV", 
    -- [23530]领取每日奖励 -- 奖励 
    REQ_REWARD_DAILY                 = 23530,[23530] = "REQ_REWARD_DAILY", 
    -- [23540]领取vip奖励 -- 奖励 
    REQ_REWARD_VIP                   = 23540,[23540] = "REQ_REWARD_VIP", 
    -- [23545]领取vip奖励返回 -- 奖励 
    ACK_REWARD_VIP_REPLY             = 23545,[23545] = "ACK_REWARD_VIP_REPLY", 
    -- [23600]怀孕奖励刷新 -- 奖励 
    ACK_REWARD_PREGNANCY             = 23600,[23600] = "ACK_REWARD_PREGNANCY", 
    -- [23610]更新主界面数字 -- 奖励 
    REQ_REWARD_BEGIN                 = 23610,[23610] = "REQ_REWARD_BEGIN", 
    -- [23615]角标返回 -- 奖励 
    ACK_REWARD_ICON_TIME             = 23615,[23615] = "ACK_REWARD_ICON_TIME", 
    -- [23620]vip等级和总数 -- 奖励 
    ACK_REWARD_VIP_LV_RMB            = 23620,[23620] = "ACK_REWARD_VIP_LV_RMB", 
    -- [23630]所有已经冲过值的金额 -- 奖励 
    ACK_REWARD_LOGS_PAY              = 23630,[23630] = "ACK_REWARD_LOGS_PAY", 
    -- [23635]充值金额信息块 -- 奖励 
    ACK_REWARD_MSG_LOGS_PAY          = 23635,[23635] = "ACK_REWARD_MSG_LOGS_PAY", 
    -- [23640]登陆送礼领取奖励 -- 奖励 
    REQ_REWARD_LOGIN_GET             = 23640,[23640] = "REQ_REWARD_LOGIN_GET", 
    -- [23645]领取奖励成功 -- 奖励 
    ACK_REWARD_LOGIN_SUCCESS         = 23645,[23645] = "ACK_REWARD_LOGIN_SUCCESS", 
    -- [23650]请求登陆送礼界面 -- 奖励 
    REQ_REWARD_LOGIN_REQUEST         = 23650,[23650] = "REQ_REWARD_LOGIN_REQUEST", 
    -- [23660]登陆界面返回 -- 奖励 
    ACK_REWARD_LOGIN_REPLY           = 23660,[23660] = "ACK_REWARD_LOGIN_REPLY", 
    -- [23670]物品信息块 -- 奖励 
    ACK_REWARD_LOGIN_MSG_XXX         = 23670,[23670] = "ACK_REWARD_LOGIN_MSG_XXX", 
    -- [23675]请求主界面签到 -- 奖励 
    REQ_REWARD_REWARD_MAIN_REQU      = 23675,[23675] = "REQ_REWARD_REWARD_MAIN_REQU", 
    -- [23680]主界面签到 -- 奖励 
    ACK_REWARD_MAIN_LOGIN            = 23680,[23680] = "ACK_REWARD_MAIN_LOGIN", 

    --------------------------------------------------------
    -- 23801 - 24800 ( 竞技场 ) 
    --------------------------------------------------------
    -- [23810]进入竞技场 -- 竞技场 
    REQ_ARENA_JOIN                   = 23810,[23810] = "REQ_ARENA_JOIN", 
    -- [23820]可以挑战的玩家列表 -- 竞技场 
    ACK_ARENA_DEKARON                = 23820,[23820] = "ACK_ARENA_DEKARON", 
    -- [23821]可以挑战的玩家 -- 竞技场 
    ACK_ARENA_CANBECHALLAGE          = 23821,[23821] = "ACK_ARENA_CANBECHALLAGE", 
    -- [23828]挑战(新) -- 竞技场 
    REQ_ARENA_BATTLE_NEW             = 23828,[23828] = "REQ_ARENA_BATTLE_NEW", 
    -- [23829]验证通过 -- 竞技场 
    ACK_ARENA_THROUGH                = 23829,[23829] = "ACK_ARENA_THROUGH", 
    -- [23831]战斗信息块 -- 竞技场 
    ACK_ARENA_WAR_DATA               = 23831,[23831] = "ACK_ARENA_WAR_DATA", 
    -- [23835]挑战奖励 -- 竞技场 
    ACK_ARENA_WAR_REWARD             = 23835,[23835] = "ACK_ARENA_WAR_REWARD", 
    -- [23841]挑战结束(新) -- 竞技场 
    REQ_ARENA_FINISH_NEW             = 23841,[23841] = "REQ_ARENA_FINISH_NEW", 
    -- [23845]请求战报 -- 竞技场 
    REQ_ARENA_ASK_REDIO              = 23845,[23845] = "REQ_ARENA_ASK_REDIO", 
    -- [23850]战报 -- 竞技场 
    ACK_ARENA_RADIO                  = 23850,[23850] = "ACK_ARENA_RADIO", 
    -- [23860]购买挑战次数 -- 竞技场 
    REQ_ARENA_BUY                    = 23860,[23860] = "REQ_ARENA_BUY", 
    -- [23870]结果 -- 竞技场 
    ACK_ARENA_RESULT2                = 23870,[23870] = "ACK_ARENA_RESULT2", 
    -- [23880]确定购买 -- 竞技场 
    REQ_ARENA_BUY_YES                = 23880,[23880] = "REQ_ARENA_BUY_YES", 
    -- [23890]返回结果 -- 竞技场 
    ACK_ARENA_BUY_OK                 = 23890,[23890] = "ACK_ARENA_BUY_OK", 
    -- [23920]请求排行榜 -- 竞技场 
    REQ_ARENA_KILLER                 = 23920,[23920] = "REQ_ARENA_KILLER", 
    -- [23930]返回高手信息 -- 竞技场 
    ACK_ARENA_KILLER_DATA            = 23930,[23930] = "ACK_ARENA_KILLER_DATA", 
    -- [23931]高手信息 -- 竞技场 
    ACK_ARENA_ACE                    = 23931,[23931] = "ACK_ARENA_ACE", 
    -- [23940]返回最竞技场信息 -- 竞技场 
    ACK_ARENA_MAX_DATA               = 23940,[23940] = "ACK_ARENA_MAX_DATA", 
    -- [23950]每日竞技场排行榜奖励 -- 竞技场 
    ACK_ARENA_RANK_REWARD            = 23950,[23950] = "ACK_ARENA_RANK_REWARD", 
    -- [23970]领取结果 -- 竞技场 
    ACK_ARENA_GET_REWARD             = 23970,[23970] = "ACK_ARENA_GET_REWARD", 
    -- [24000]领取倒计时 -- 竞技场 
    ACK_ARENA_REWARD_TIMES           = 24000,[24000] = "ACK_ARENA_REWARD_TIMES", 
    -- [24005]cd冷却中 -- 竞技场 
    ACK_ARENA_CD_SEC                 = 24005,[24005] = "ACK_ARENA_CD_SEC", 
    -- [24010]清除CD时间 -- 竞技场 
    REQ_ARENA_CLEAN                  = 24010,[24010] = "REQ_ARENA_CLEAN", 
    -- [24020]清除成功 -- 竞技场 
    ACK_ARENA_CLEAN_OK               = 24020,[24020] = "ACK_ARENA_CLEAN_OK", 
    -- [24030]领取竞技铜钱 -- 竞技场 
    REQ_ARENA_DRAW_GOLD              = 24030,[24030] = "REQ_ARENA_DRAW_GOLD", 
    -- [24040]进入竞技场(新) -- 竞技场 
    REQ_ARENA_JOIN_NEW               = 24040,[24040] = "REQ_ARENA_JOIN_NEW", 
    -- [24050]可以挑战的玩家列表(新) -- 竞技场 
    ACK_ARENA_DEKARON_NEW            = 24050,[24050] = "ACK_ARENA_DEKARON_NEW", 
    -- [24060]玩家数据 -- 竞技场 
    ACK_ARENA_CHALL_NEW              = 24060,[24060] = "ACK_ARENA_CHALL_NEW", 

    --------------------------------------------------------
    -- 24801 - 24900 ( 排行榜 ) 
    --------------------------------------------------------
    -- [24810]请求排行榜 -- 排行榜 
    REQ_TOP_RANK                     = 24810,[24810] = "REQ_TOP_RANK", 
    -- [24823]排行榜信息(新) -- 排行榜 
    ACK_TOP_DATE_NEW2                = 24823,[24823] = "ACK_TOP_DATE_NEW2", 
    -- [24830]请求全部榜首 -- 排行榜 
    REQ_TOP_REQUEST                  = 24830,[24830] = "REQ_TOP_REQUEST", 
    -- [24840]全部榜首返回 -- 排行榜 
    ACK_TOP_REPLY                    = 24840,[24840] = "ACK_TOP_REPLY", 
    -- [24850]信息块 -- 排行榜 
    ACK_TOP_MSG_XXX                  = 24850,[24850] = "ACK_TOP_MSG_XXX", 

    --------------------------------------------------------
    -- 24901 - 24999 ( 新手卡 ) 
    --------------------------------------------------------
    -- [24910]领取卡 -- 新手卡 
    REQ_CARD_GETS                    = 24910,[24910] = "REQ_CARD_GETS", 
    -- [24920]领取成功 -- 新手卡 
    ACK_CARD_SUCCEED                 = 24920,[24920] = "ACK_CARD_SUCCEED", 
    -- [24925]每日首充请求 -- 新手卡 
    REQ_CARD_CHARGE_DAILY_ASK        = 24925,[24925] = "REQ_CARD_CHARGE_DAILY_ASK", 
    -- [24930]每日首充回 -- 新手卡 
    ACK_CARD_CHARGE_DAILY_CB         = 24930,[24930] = "ACK_CARD_CHARGE_DAILY_CB", 
    -- [24935]领取首充 -- 新手卡 
    REQ_CARD_CHARGE_GET              = 24935,[24935] = "REQ_CARD_CHARGE_GET", 
    -- [24940]领取成功返回 -- 新手卡 
    ACK_CARD_CHARGE_SUC              = 24940,[24940] = "ACK_CARD_CHARGE_SUC", 

    --------------------------------------------------------
    -- 25000 - 25499 ( 灵妖竞技场 ) 
    --------------------------------------------------------
    -- [25010]进入竞技场 -- 灵妖竞技场 
    REQ_LINGYAO_ARENA_JOIN           = 25010,[25010] = "REQ_LINGYAO_ARENA_JOIN", 
    -- [25020]可挑战玩家列表 -- 灵妖竞技场 
    ACK_LINGYAO_ARENA_DEKARON        = 25020,[25020] = "ACK_LINGYAO_ARENA_DEKARON", 
    -- [25025]可以挑战的玩家信息块 -- 灵妖竞技场 
    ACK_LINGYAO_ARENA_CANBECHALLAGE  = 25025,[25025] = "ACK_LINGYAO_ARENA_CANBECHALLAGE", 
    -- [25040]请求对手信息 -- 灵妖竞技场 
    REQ_LINGYAO_ARENA_RIVAL_REQUEST  = 25040,[25040] = "REQ_LINGYAO_ARENA_RIVAL_REQUEST", 
    -- [25045]对手信息返回 -- 灵妖竞技场 
    ACK_LINGYAO_ARENA_RIVAL_REPLY    = 25045,[25045] = "ACK_LINGYAO_ARENA_RIVAL_REPLY", 
    -- [25050]对手信息块 -- 灵妖竞技场 
    ACK_LINGYAO_ARENA_RIVAL_DATA     = 25050,[25050] = "ACK_LINGYAO_ARENA_RIVAL_DATA", 
    -- [25060]请求购买次数 -- 灵妖竞技场 
    REQ_LINGYAO_ARENA_BUY            = 25060,[25060] = "REQ_LINGYAO_ARENA_BUY", 
    -- [25062]购买提示返回 -- 灵妖竞技场 
    ACK_LINGYAO_ARENA_BUY_REPLY      = 25062,[25062] = "ACK_LINGYAO_ARENA_BUY_REPLY", 
    -- [25065]竞技场剩余次数返回 -- 灵妖竞技场 
    ACK_LINGYAO_ARENA_TIMES          = 25065,[25065] = "ACK_LINGYAO_ARENA_TIMES", 
    -- [25070]请求排行榜 -- 灵妖竞技场 
    REQ_LINGYAO_ARENA_RANK_REQUEST   = 25070,[25070] = "REQ_LINGYAO_ARENA_RANK_REQUEST", 
    -- [25075]排行榜返回 -- 灵妖竞技场 
    ACK_LINGYAO_ARENA_RANK_REPLY     = 25075,[25075] = "ACK_LINGYAO_ARENA_RANK_REPLY", 
    -- [25078]物品信息块 -- 灵妖竞技场 
    ACK_LINGYAO_ARENA_GOODS_DATA     = 25078,[25078] = "ACK_LINGYAO_ARENA_GOODS_DATA", 
    -- [25080]排行榜数据块 -- 灵妖竞技场 
    ACK_LINGYAO_ARENA_RANK_DATA      = 25080,[25080] = "ACK_LINGYAO_ARENA_RANK_DATA", 
    -- [25090]请求战报 -- 灵妖竞技场 
    REQ_LINGYAO_ARENA_REPORT         = 25090,[25090] = "REQ_LINGYAO_ARENA_REPORT", 
    -- [25092]战报返回 -- 灵妖竞技场 
    ACK_LINGYAO_ARENA_REPORT_REPLY   = 25092,[25092] = "ACK_LINGYAO_ARENA_REPORT_REPLY", 
    -- [25095]战报返回 -- 灵妖竞技场 
    ACK_LINGYAO_ARENA_REPORT_DATA    = 25095,[25095] = "ACK_LINGYAO_ARENA_REPORT_DATA", 
    -- [25097]cd冷却中 -- 灵妖竞技场 
    ACK_LINGYAO_ARENA_CD_SEC         = 25097,[25097] = "ACK_LINGYAO_ARENA_CD_SEC", 
    -- [25100]清除挑战CD -- 灵妖竞技场 
    REQ_LINGYAO_ARENA_CD_CLEAN       = 25100,[25100] = "REQ_LINGYAO_ARENA_CD_CLEAN", 
    -- [25105]CD清除返回 -- 灵妖竞技场 
    ACK_LINGYAO_ARENA_CD_CLEAN_OK    = 25105,[25105] = "ACK_LINGYAO_ARENA_CD_CLEAN_OK", 
    -- [25110]请求防守阵容 -- 灵妖竞技场 
    REQ_LINGYAO_ARENA_DEF            = 25110,[25110] = "REQ_LINGYAO_ARENA_DEF", 
    -- [25115]防守阵容返回 -- 灵妖竞技场 
    ACK_LINGYAO_ARENA_DEF_REPLY      = 25115,[25115] = "ACK_LINGYAO_ARENA_DEF_REPLY", 
    -- [25120]阵容信息块 -- 灵妖竞技场 
    ACK_LINGYAO_ARENA_DEF_DATA       = 25120,[25120] = "ACK_LINGYAO_ARENA_DEF_DATA", 
    -- [25125]阵容保存 -- 灵妖竞技场 
    REQ_LINGYAO_ARENA_BATTLE_SAVE    = 25125,[25125] = "REQ_LINGYAO_ARENA_BATTLE_SAVE", 
    -- [25130]领取分钟奖励 -- 灵妖竞技场 
    REQ_LINGYAO_ARENA_DRAW_REWARD    = 25130,[25130] = "REQ_LINGYAO_ARENA_DRAW_REWARD", 
    -- [25135]分钟奖励信息 -- 灵妖竞技场 
    ACK_LINGYAO_ARENA_REWARD_DATA    = 25135,[25135] = "ACK_LINGYAO_ARENA_REWARD_DATA", 
    -- [25140]挑战 -- 灵妖竞技场 
    REQ_LINGYAO_ARENA_BATTLE         = 25140,[25140] = "REQ_LINGYAO_ARENA_BATTLE", 
    -- [25142]挑战返回 -- 灵妖竞技场 
    ACK_LINGYAO_ARENA_BATTLE_REPLY   = 25142,[25142] = "ACK_LINGYAO_ARENA_BATTLE_REPLY", 
    -- [25144]灵妖信息块 -- 灵妖竞技场 
    ACK_LINGYAO_ARENA_DATA           = 25144,[25144] = "ACK_LINGYAO_ARENA_DATA", 
    -- [25148]验证通过 -- 灵妖竞技场 
    ACK_LINGYAO_ARENA_THROUGH        = 25148,[25148] = "ACK_LINGYAO_ARENA_THROUGH", 
    -- [25150]挑战完成返回 -- 灵妖竞技场 
    REQ_LINGYAO_ARENA_OVER           = 25150,[25150] = "REQ_LINGYAO_ARENA_OVER", 
    -- [25155]挑战完成返回 -- 灵妖竞技场 
    ACK_LINGYAO_ARENA_OVER_REPLY     = 25155,[25155] = "ACK_LINGYAO_ARENA_OVER_REPLY", 

    --------------------------------------------------------
    -- 25500 - 25999 ( 招财貔貅 ) 
    --------------------------------------------------------
    -- [25510]请求招财貔貅 -- 招财貔貅 
    REQ_WEAGOD_RMB_REQUEST           = 25510,[25510] = "REQ_WEAGOD_RMB_REQUEST", 
    -- [25520]返回招财貔貅 -- 招财貔貅 
    ACK_WEAGOD_RMB_REPLY             = 25520,[25520] = "ACK_WEAGOD_RMB_REPLY", 
    -- [25530]请求购买招财貔貅 -- 招财貔貅 
    REQ_WEAGOD_RMB_BUY               = 25530,[25530] = "REQ_WEAGOD_RMB_BUY", 
    -- [25540]成功购买招财貔貅 -- 招财貔貅 
    ACK_WEAGOD_RMB_SUCCESS           = 25540,[25540] = "ACK_WEAGOD_RMB_SUCCESS", 
    -- [25550]请求貔貅礼包领取 -- 招财貔貅 
    REQ_WEAGOD_RMB_GIFT_REQUEST      = 25550,[25550] = "REQ_WEAGOD_RMB_GIFT_REQUEST", 
    -- [25560]礼包领取返回 -- 招财貔貅 
    ACK_WEAGOD_RMB_GIFT_BACK         = 25560,[25560] = "ACK_WEAGOD_RMB_GIFT_BACK", 
    -- [25570]貔貅界面控制 -- 招财貔貅 
    ACK_WEAGOD_RMB_GUI_CONTROL       = 25570,[25570] = "ACK_WEAGOD_RMB_GUI_CONTROL", 
    -- [25580]请求貔貅界面 -- 招财貔貅 
    REQ_WEAGOD_RMB_CALL              = 25580,[25580] = "REQ_WEAGOD_RMB_CALL", 

    --------------------------------------------------------
    -- 26000 - 26999 ( NPC ) 
    --------------------------------------------------------
    -- [26000]请求NPC -- NPC 
    REQ_NPC_REQUEST                  = 26000,[26000] = "REQ_NPC_REQUEST", 
    -- [26005]队伍列表 -- NPC 
    ACK_NPC_LIST                     = 26005,[26005] = "ACK_NPC_LIST", 
    -- [26007]返回NPC副本ID -- NPC 
    ACK_NPC_COPY_ID                  = 26007,[26007] = "ACK_NPC_COPY_ID", 
    -- [26010]从NPC处滚蛋 -- NPC 
    REQ_NPC_SCRAM                    = 26010,[26010] = "REQ_NPC_SCRAM", 
    -- [26015]关闭组队面板 -- NPC 
    ACK_NPC_CLOSE                    = 26015,[26015] = "ACK_NPC_CLOSE", 
    -- [26020]通知--删除队伍 -- NPC 
    ACK_NPC_NOTICE_DELETE            = 26020,[26020] = "ACK_NPC_NOTICE_DELETE", 
    -- [26040]设置队长 -- NPC 
    REQ_NPC_SET_LEADER               = 26040,[26040] = "REQ_NPC_SET_LEADER", 
    -- [26050]加入队伍 -- NPC 
    REQ_NPC_JOIN                     = 26050,[26050] = "REQ_NPC_JOIN", 
    -- [26060]退出队伍 -- NPC 
    REQ_NPC_LEAVE                    = 26060,[26060] = "REQ_NPC_LEAVE", 
    -- [26070]踢出队员 -- NPC 
    REQ_NPC_KICK                     = 26070,[26070] = "REQ_NPC_KICK", 
    -- [26080]解散队伍 -- NPC 
    REQ_NPC_DISMISS                  = 26080,[26080] = "REQ_NPC_DISMISS", 
    -- [26100]NPC进入(战场|副本|各种组队玩法) -- NPC 
    REQ_NPC_TEAM_ENTER               = 26100,[26100] = "REQ_NPC_TEAM_ENTER", 
    -- [26110]隐藏队伍 -- NPC 
    ACK_NPC_NOTICE_HIDE              = 26110,[26110] = "ACK_NPC_NOTICE_HIDE", 

    --------------------------------------------------------
    -- 28000 - 29000 ( 布阵 ) 
    --------------------------------------------------------
    -- [28000]返回伙伴信息数据 -- 布阵 
    ACK_ARRAY_LIST_DATA              = 28000,[28000] = "ACK_ARRAY_LIST_DATA", 
    -- [28010]请求阵型系统 -- 布阵 
    REQ_ARRAY_LIST                   = 28010,[28010] = "REQ_ARRAY_LIST", 
    -- [28020]上阵 -- 布阵 
    REQ_ARRAY_UP_ARRAY               = 28020,[28020] = "REQ_ARRAY_UP_ARRAY", 
    -- [28030]下阵 -- 布阵 
    REQ_ARRAY_DOWN_ARRAY             = 28030,[28030] = "REQ_ARRAY_DOWN_ARRAY", 
    -- [28040]交换阵位 -- 布阵 
    REQ_ARRAY_EXCHANGE               = 28040,[28040] = "REQ_ARRAY_EXCHANGE", 
    -- [28050]布阵伙伴信息块 -- 布阵 
    ACK_ARRAY_ROLE_INFO              = 28050,[28050] = "ACK_ARRAY_ROLE_INFO", 

    --------------------------------------------------------
    -- 29001 - 29500 ( 洞府祈福 ) 
    --------------------------------------------------------
    -- [29010]请求洞府祈福 -- 洞府祈福 
    REQ_CLIFFORD_REQUEST             = 29010,[29010] = "REQ_CLIFFORD_REQUEST", 
    -- [29020]祈福界面 -- 洞府祈福 
    ACK_CLIFFORD_REPLY               = 29020,[29020] = "ACK_CLIFFORD_REPLY", 
    -- [29030]信息块 -- 洞府祈福 
    ACK_CLIFFORD_XXX                 = 29030,[29030] = "ACK_CLIFFORD_XXX", 
    -- [29035]信息块 -- 洞府祈福 
    ACK_CLIFFORD_XXXX                = 29035,[29035] = "ACK_CLIFFORD_XXXX", 
    -- [29040]祈福 -- 洞府祈福 
    REQ_CLIFFORD_START               = 29040,[29040] = "REQ_CLIFFORD_START", 
    -- [29050]祈福成功 -- 洞府祈福 
    ACK_CLIFFORD_OVER                = 29050,[29050] = "ACK_CLIFFORD_OVER", 
    -- [29060]领取箱子 -- 洞府祈福 
    REQ_CLIFFORD_LQ_REWAR            = 29060,[29060] = "REQ_CLIFFORD_LQ_REWAR", 
    -- [29070]领取箱子成功 -- 洞府祈福 
    ACK_CLIFFORD_LQ_BACK             = 29070,[29070] = "ACK_CLIFFORD_LQ_BACK", 

    --------------------------------------------------------
    -- 30501 - 31000 ( 攻略 ) 
    --------------------------------------------------------
    -- [30505]请求今日活跃度 -- 攻略 
    REQ_GONGLUE_HY                   = 30505,[30505] = "REQ_GONGLUE_HY", 
    -- [30510]活跃度信息反回 -- 攻略 
    ACK_GONGLUE_HY_DATA              = 30510,[30510] = "ACK_GONGLUE_HY_DATA", 
    -- [30520]请求活动日历 -- 攻略 
    REQ_GONGLUE_ACTIVITY_DAY         = 30520,[30520] = "REQ_GONGLUE_ACTIVITY_DAY", 
    -- [30530]当天日历数据 -- 攻略 
    ACK_GONGLUE_DAY_DATA             = 30530,[30530] = "ACK_GONGLUE_DAY_DATA", 
    -- [30540]请求我要变强 -- 攻略 
    REQ_GONGLUE_STRONG               = 30540,[30540] = "REQ_GONGLUE_STRONG", 
    -- [30550]变强数据反回 -- 攻略 
    ACK_GONGLUE_STRONG_DATA          = 30550,[30550] = "ACK_GONGLUE_STRONG_DATA", 
    -- [30555]领取活跃宝箱 -- 攻略 
    REQ_GONGLUE_BOX                  = 30555,[30555] = "REQ_GONGLUE_BOX", 
    -- [30560]领取宝箱成功 -- 攻略 
    ACK_GONGLUE_SUCCESS              = 30560,[30560] = "ACK_GONGLUE_SUCCESS", 

    --------------------------------------------------------
    -- 31001 - 32000 ( 灵妖系统 ) 
    --------------------------------------------------------
    -- [31110]请求灵妖界面 -- 灵妖系统 
    REQ_LINGYAO_REQUEST              = 31110,[31110] = "REQ_LINGYAO_REQUEST", 
    -- [31120]灵妖请求返回 -- 灵妖系统 
    ACK_LINGYAO_REPLY                = 31120,[31120] = "ACK_LINGYAO_REPLY", 
    -- [31130]灵妖信息块 -- 灵妖系统 
    ACK_LINGYAO_MSG_XXX              = 31130,[31130] = "ACK_LINGYAO_MSG_XXX", 
    -- [31150]灵妖激活 -- 灵妖系统 
    REQ_LINGYAO_JIHUO                = 31150,[31150] = "REQ_LINGYAO_JIHUO", 
    -- [31280]灵妖升级 -- 灵妖系统 
    REQ_LINGYAO_UPGRADE              = 31280,[31280] = "REQ_LINGYAO_UPGRADE", 
    -- [31360]灵妖升阶 -- 灵妖系统 
    REQ_LINGYAO_SHENGJIE             = 31360,[31360] = "REQ_LINGYAO_SHENGJIE", 
    -- [31365]灵妖升阶返回 -- 灵妖系统 
    ACK_LINGYAO_SHENJIE_BACK         = 31365,[31365] = "ACK_LINGYAO_SHENJIE_BACK", 
    -- [31515]妖魂 -- 灵妖系统 
    ACK_LINGYAO_RENOWN               = 31515,[31515] = "ACK_LINGYAO_RENOWN", 
    -- [31520]灵妖镶嵌符文(背包) -- 灵妖系统 
    REQ_LINGYAO_EQUIP                = 31520,[31520] = "REQ_LINGYAO_EQUIP", 
    -- [31530]灵妖镶嵌符文(其他灵妖身上) -- 灵妖系统 
    REQ_LINGYAO_EQUIP_OTHER          = 31530,[31530] = "REQ_LINGYAO_EQUIP_OTHER", 
    -- [31535]灵妖卸下符文 -- 灵妖系统 
    REQ_LINGYAO_EQUIP_OFF            = 31535,[31535] = "REQ_LINGYAO_EQUIP_OFF", 
    -- [31540]查看总属性加成 -- 灵妖系统 
    REQ_LINGYAO_ATTR_ALL             = 31540,[31540] = "REQ_LINGYAO_ATTR_ALL", 
    -- [31545]查看总属性返回 -- 灵妖系统 
    ACK_LINGYAO_ATTR_ALL_REPLY       = 31545,[31545] = "ACK_LINGYAO_ATTR_ALL_REPLY", 
    -- [31550]一键镶嵌 -- 灵妖系统 
    REQ_LINGYAO_EQUIP_ALL            = 31550,[31550] = "REQ_LINGYAO_EQUIP_ALL", 
    -- [31560]请求副本挑战次数 -- 灵妖系统 
    REQ_LINGYAO_COPY_TIMES           = 31560,[31560] = "REQ_LINGYAO_COPY_TIMES", 
    -- [31563]副本是否开启 -- 灵妖系统 
    ACK_LINGYAO_COPY_OPEN            = 31563,[31563] = "ACK_LINGYAO_COPY_OPEN", 
    -- [31570]元魂 -- 灵妖系统 
    ACK_LINGYAO_YUANHUN              = 31570,[31570] = "ACK_LINGYAO_YUANHUN", 

    --------------------------------------------------------
    -- 32001 - 33000 ( 摇钱树 ) 
    --------------------------------------------------------
    -- [32010]财神面板请求 -- 摇钱树 
    REQ_WEAGOD_REQUEST               = 32010,[32010] = "REQ_WEAGOD_REQUEST", 
    -- [32020]财神面板请求返回 -- 摇钱树 
    ACK_WEAGOD_REPLY                 = 32020,[32020] = "ACK_WEAGOD_REPLY", 
    -- [32025]招财信息块 -- 摇钱树 
    ACK_WEAGOD_WEAGOD_R_MSG          = 32025,[32025] = "ACK_WEAGOD_WEAGOD_R_MSG", 
    -- [32030]招财 -- 摇钱树 
    REQ_WEAGOD_GET_MONEY             = 32030,[32030] = "REQ_WEAGOD_GET_MONEY", 
    -- [32040]批量招财 -- 摇钱树 
    REQ_WEAGOD_PL_MONEY              = 32040,[32040] = "REQ_WEAGOD_PL_MONEY", 
    -- [32050]自动招财 -- 摇钱树 
    REQ_WEAGOD_AUTO_GET              = 32050,[32050] = "REQ_WEAGOD_AUTO_GET", 
    -- [32060]招财成功返回 -- 摇钱树 
    ACK_WEAGOD_SUCCESS               = 32060,[32060] = "ACK_WEAGOD_SUCCESS", 
    -- [32070]招财暴击 -- 摇钱树 
    ACK_WEAGOD_CRIT                  = 32070,[32070] = "ACK_WEAGOD_CRIT", 

    --------------------------------------------------------
    -- 33001 - 34000 ( 帮派 ) 
    --------------------------------------------------------
    -- [33010]请求帮派信息 -- 帮派 
    REQ_CLAN_ASK_CLAN                = 33010,[33010] = "REQ_CLAN_ASK_CLAN", 
    -- [33020]返加帮派基础数据1 -- 帮派 
    ACK_CLAN_OK_CLAN_DATA            = 33020,[33020] = "ACK_CLAN_OK_CLAN_DATA", 
    -- [33023]返加帮派基础数据2 -- 帮派 
    ACK_CLAN_OK_OTHER_DATA           = 33023,[33023] = "ACK_CLAN_OK_OTHER_DATA", 
    -- [33025]返加帮派日志数据3 -- 帮派 
    ACK_CLAN_CLAN_LOGS               = 33025,[33025] = "ACK_CLAN_CLAN_LOGS", 
    -- [33026]帮派日志数据块 -- 帮派 
    ACK_CLAN_LOGS_MSG                = 33026,[33026] = "ACK_CLAN_LOGS_MSG", 
    -- [33027]string数据块 -- 帮派 
    ACK_CLAN_STING_MSG               = 33027,[33027] = "ACK_CLAN_STING_MSG", 
    -- [33028]int数据块 -- 帮派 
    ACK_CLAN_INT_MSG                 = 33028,[33028] = "ACK_CLAN_INT_MSG", 
    -- [33030]请求帮派列表 -- 帮派 
    REQ_CLAN_ASL_CLANLIST            = 33030,[33030] = "REQ_CLAN_ASL_CLANLIST", 
    -- [33034]帮派列表返回 -- 帮派 
    ACK_CLAN_OK_CLANLIST             = 33034,[33034] = "ACK_CLAN_OK_CLANLIST", 
    -- [33036]已申请帮派列表 -- 帮派 
    ACK_CLAN_APPLIED_CLANLIST        = 33036,[33036] = "ACK_CLAN_APPLIED_CLANLIST", 
    -- [33037]请求|取消加入帮 -- 帮派 
    REQ_CLAN_ASK_CANCEL              = 33037,[33037] = "REQ_CLAN_ASK_CANCEL", 
    -- [33040]申请成功 -- 帮派 
    ACK_CLAN_OK_JOIN_CLAN            = 33040,[33040] = "ACK_CLAN_OK_JOIN_CLAN", 
    -- [33050]请求创建帮派 -- 帮派 
    REQ_CLAN_ASK_REBUILD_CLAN        = 33050,[33050] = "REQ_CLAN_ASK_REBUILD_CLAN", 
    -- [33060]创建成功 -- 帮派 
    ACK_CLAN_OK_REBUILD_CLAN         = 33060,[33060] = "ACK_CLAN_OK_REBUILD_CLAN", 
    -- [33070]请求入帮申请列表 -- 帮派 
    REQ_CLAN_ASK_JOIN_LIST           = 33070,[33070] = "REQ_CLAN_ASK_JOIN_LIST", 
    -- [33080]返回入帮申请列表 -- 帮派 
    ACK_CLAN_OK_JOIN_LIST            = 33080,[33080] = "ACK_CLAN_OK_JOIN_LIST", 
    -- [33085]入帮申请玩家信息块 -- 帮派 
    ACK_CLAN_USER_DATA               = 33085,[33085] = "ACK_CLAN_USER_DATA", 
    -- [33090]请求审核操作 -- 帮派 
    REQ_CLAN_ASK_AUDIT               = 33090,[33090] = "REQ_CLAN_ASK_AUDIT", 
    -- [33095]返回审核结果 -- 帮派 
    ACK_CLAN_OK_AUDIT                = 33095,[33095] = "ACK_CLAN_OK_AUDIT", 
    -- [33098]申请帮派审核成功 -- 帮派 
    ACK_CLAN_AUDIT_SUCCESS           = 33098,[33098] = "ACK_CLAN_AUDIT_SUCCESS", 
    -- [33110]请求修改帮派公告 -- 帮派 
    REQ_CLAN_ASK_RESET_CAST          = 33110,[33110] = "REQ_CLAN_ASK_RESET_CAST", 
    -- [33120]返回修改公告结果 -- 帮派 
    ACK_CLAN_OK_RESET_CAST           = 33120,[33120] = "ACK_CLAN_OK_RESET_CAST", 
    -- [33130]请求帮派成员列表 -- 帮派 
    REQ_CLAN_ASK_MEMBER_MSG          = 33130,[33130] = "REQ_CLAN_ASK_MEMBER_MSG", 
    -- [33135]请求设置成员职位 -- 帮派 
    REQ_CLAN_ASK_SET_POST            = 33135,[33135] = "REQ_CLAN_ASK_SET_POST", 
    -- [33140]返回帮派成员列表 -- 帮派 
    ACK_CLAN_OK_MEMBER_LIST          = 33140,[33140] = "ACK_CLAN_OK_MEMBER_LIST", 
    -- [33145]成员数据信息块 -- 帮派 
    ACK_CLAN_MEMBER_MSG              = 33145,[33145] = "ACK_CLAN_MEMBER_MSG", 
    -- [33150]请求退出|解散帮派 -- 帮派 
    REQ_CLAN_ASK_OUT_CLAN            = 33150,[33150] = "REQ_CLAN_ASK_OUT_CLAN", 
    -- [33160]退出帮派成功 -- 帮派 
    ACK_CLAN_OK_OUT_CLAN             = 33160,[33160] = "ACK_CLAN_OK_OUT_CLAN", 
    -- [33200]请求帮派技能面板 -- 帮派 
    REQ_CLAN_ASK_CLAN_SKILL          = 33200,[33200] = "REQ_CLAN_ASK_CLAN_SKILL", 
    -- [33210]返回帮派技能面板数据 -- 帮派 
    ACK_CLAN_OK_CLAN_SKILL           = 33210,[33210] = "ACK_CLAN_OK_CLAN_SKILL", 
    -- [33215]帮派技能属性数据块【33215】 -- 帮派 
    ACK_CLAN_CLAN_ATTR_DATA          = 33215,[33215] = "ACK_CLAN_CLAN_ATTR_DATA", 
    -- [33220]请求学习帮派技能 -- 帮派 
    REQ_CLAN_STUDY_SKILL             = 33220,[33220] = "REQ_CLAN_STUDY_SKILL", 
    -- [33305]玩家现有帮贡值 -- 帮派 
    ACK_CLAN_NOW_STAMINA             = 33305,[33305] = "ACK_CLAN_NOW_STAMINA", 
    -- [33310]返回活动面板数据 -- 帮派 
    ACK_CLAN_OK_ACTIVE_DATA          = 33310,[33310] = "ACK_CLAN_OK_ACTIVE_DATA", 
    -- [33315]帮派活动面板数据块 -- 帮派 
    ACK_CLAN_ACTIVE_MSG              = 33315,[33315] = "ACK_CLAN_ACTIVE_MSG", 
    -- [33320]请求互动面板 -- 帮派 
    REQ_CLAN_ASK_WATER               = 33320,[33320] = "REQ_CLAN_ASK_WATER", 
    -- [33325]请求开始互动 -- 帮派 
    REQ_CLAN_START_WATER             = 33325,[33325] = "REQ_CLAN_START_WATER", 
    -- [33330]返回浇水面板数据 -- 帮派 
    ACK_CLAN_OK_WATER_DATA           = 33330,[33330] = "ACK_CLAN_OK_WATER_DATA", 
    -- [33380]招募帮众 -- 帮派 
    REQ_CLAN_ZAOMU                   = 33380,[33380] = "REQ_CLAN_ZAOMU", 
    -- [33390]请求个人职位 -- 帮派 
    REQ_CLAN_SELF_POST               = 33390,[33390] = "REQ_CLAN_SELF_POST", 
    -- [33400]个人职位 -- 帮派 
    ACK_CLAN_POST_BACK               = 33400,[33400] = "ACK_CLAN_POST_BACK", 
    -- [33410]帮派角标 -- 帮派 
    ACK_CLAN_CORNER                  = 33410,[33410] = "ACK_CLAN_CORNER", 
    -- [33420]角标信息块 -- 帮派 
    ACK_CLAN_XXX                     = 33420,[33420] = "ACK_CLAN_XXX", 
    -- [33430]离开界面 -- 帮派 
    REQ_CLAN_LEAVE                   = 33430,[33430] = "REQ_CLAN_LEAVE", 
    -- [33440]弹劾洞主 -- 帮派 
    REQ_CLAN_TH_MASTER               = 33440,[33440] = "REQ_CLAN_TH_MASTER", 

    --------------------------------------------------------
    -- 34001 - 34250 ( 活动-龙宫寻宝 ) 
    --------------------------------------------------------
    -- [34010]请求寻宝界面 -- 活动-龙宫寻宝 
    REQ_DRAGON_ASK_JOIN_DRAGON       = 34010,[34010] = "REQ_DRAGON_ASK_JOIN_DRAGON", 
    -- [34020]请求界面成功 -- 活动-龙宫寻宝 
    ACK_DRAGON_OK_JOIN_DRAGON        = 34020,[34020] = "ACK_DRAGON_OK_JOIN_DRAGON", 
    -- [34030]开始寻宝 -- 活动-龙宫寻宝 
    REQ_DRAGON_START_DRAGON          = 34030,[34030] = "REQ_DRAGON_START_DRAGON", 
    -- [34040]寻宝结果_旧 -- 活动-龙宫寻宝 
    ACK_DRAGON_OK_START_DRAGON       = 34040,[34040] = "ACK_DRAGON_OK_START_DRAGON", 
    -- [34042]寻宝结果 -- 活动-龙宫寻宝 
    ACK_DRAGON_OK_START_NEW          = 34042,[34042] = "ACK_DRAGON_OK_START_NEW", 
    -- [34050]寻宝奖励信息块 -- 活动-龙宫寻宝 
    ACK_DRAGON_REWARDS_MSG           = 34050,[34050] = "ACK_DRAGON_REWARDS_MSG", 

    --------------------------------------------------------
    -- 34251 - 34500 ( 武器 ) 
    --------------------------------------------------------
    -- [34260]请求武器界面 -- 武器 
    REQ_WUQI_REQUEST                 = 34260,[34260] = "REQ_WUQI_REQUEST", 
    -- [34265]武器界面返回 -- 武器 
    ACK_WUQI_REPLY                   = 34265,[34265] = "ACK_WUQI_REPLY", 
    -- [34270]武器升级 -- 武器 
    REQ_WUQI_LV_UP                   = 34270,[34270] = "REQ_WUQI_LV_UP", 

    --------------------------------------------------------
    -- 34501 - 35000 ( 商城 ) 
    --------------------------------------------------------
    -- [34501]店铺物品信息块 -- 商城 
    ACK_SHOP_XXX1                    = 34501,[34501] = "ACK_SHOP_XXX1", 
    -- [34502]店铺物品信息块 -- 商城 
    ACK_SHOP_INFO_NEW                = 34502,[34502] = "ACK_SHOP_INFO_NEW", 
    -- [34510] 请求店铺面板 -- 商城 
    REQ_SHOP_REQUEST                 = 34510,[34510] = "REQ_SHOP_REQUEST", 
    -- [34511] 请求店铺面板成功 -- 商城 
    ACK_SHOP_REQUEST_OK              = 34511,[34511] = "ACK_SHOP_REQUEST_OK", 
    -- [34512]请求店铺面板成功 -- 商城 
    ACK_SHOP_REQUEST_OK_NEW          = 34512,[34512] = "ACK_SHOP_REQUEST_OK_NEW", 
    -- [34515]请求购买 -- 商城 
    REQ_SHOP_BUY                     = 34515,[34515] = "REQ_SHOP_BUY", 
    -- [34516]购买成功 -- 商城 
    ACK_SHOP_BUY_SUCC                = 34516,[34516] = "ACK_SHOP_BUY_SUCC", 
    -- [34520]请求积分数据 -- 商城 
    REQ_SHOP_ASK_INTEGRAL            = 34520,[34520] = "REQ_SHOP_ASK_INTEGRAL", 
    -- [34522]玩家积分数据 -- 商城 
    ACK_SHOP_INTEGRAL_BACK           = 34522,[34522] = "ACK_SHOP_INTEGRAL_BACK", 
    -- [34530]活动时间返回 -- 商城 
    ACK_SHOP_ACTIVE_TIME             = 34530,[34530] = "ACK_SHOP_ACTIVE_TIME", 

    --------------------------------------------------------
    -- 35001 - 36000 ( 苦工 ) 
    --------------------------------------------------------
    -- [35010]进入苦工系统 -- 苦工 
    REQ_MOIL_ENJOY_MOIL              = 35010,[35010] = "REQ_MOIL_ENJOY_MOIL", 
    -- [35020]返回自己身份信息 -- 苦工 
    ACK_MOIL_MOIL_DATA               = 35020,[35020] = "ACK_MOIL_MOIL_DATA", 
    -- [35021]苦工操作信息 -- 苦工 
    ACK_MOIL_MOIL_RS                 = 35021,[35021] = "ACK_MOIL_MOIL_RS", 
    -- [35025]玩家信息列表(抓捕,求救) -- 苦工 
    ACK_MOIL_PLAYER_DATA             = 35025,[35025] = "ACK_MOIL_PLAYER_DATA", 
    -- [35026]玩家信息块(抓捕,求救) -- 苦工 
    ACK_MOIL_MOIL_XXXX1              = 35026,[35026] = "ACK_MOIL_MOIL_XXXX1", 
    -- [35030]苦工系统操作 -- 苦工 
    REQ_MOIL_OPER                    = 35030,[35030] = "REQ_MOIL_OPER", 
    -- [35040]抓捕 -- 苦工 
    REQ_MOIL_CAPTRUE                 = 35040,[35040] = "REQ_MOIL_CAPTRUE", 
    -- [35041]抓捕结果 -- 苦工 
    REQ_MOIL_CALL_RES                = 35041,[35041] = "REQ_MOIL_CALL_RES", 
    -- [35045]抓捕返回 -- 苦工 
    ACK_MOIL_CAPTRUE_BACK            = 35045,[35045] = "ACK_MOIL_CAPTRUE_BACK", 
    -- [35050]互动 -- 苦工 
    REQ_MOIL_ACTIVE                  = 35050,[35050] = "REQ_MOIL_ACTIVE", 
    -- [35060]请求压榨/互动界面 -- 苦工 
    REQ_MOIL_PRESS_START             = 35060,[35060] = "REQ_MOIL_PRESS_START", 
    -- [35061]互动界面 -- 苦工 
    ACK_MOIL_PRESS_DATA              = 35061,[35061] = "ACK_MOIL_PRESS_DATA", 
    -- [35062]苦工信息 -- 苦工 
    ACK_MOIL_MOIL_XXXX2              = 35062,[35062] = "ACK_MOIL_MOIL_XXXX2", 
    -- [35064]苦工具体信息 -- 苦工 
    ACK_MOIL_MOIL_XXXX3              = 35064,[35064] = "ACK_MOIL_MOIL_XXXX3", 
    -- [35065]压榨苦工界面 -- 苦工 
    ACK_MOIL_PRESS_YDATA             = 35065,[35065] = "ACK_MOIL_PRESS_YDATA", 
    -- [35070]压榨/抽取/提取 -- 苦工 
    REQ_MOIL_PRESS                   = 35070,[35070] = "REQ_MOIL_PRESS", 
    -- [35080] 压榨结果 -- 苦工 
    ACK_MOIL_PRESS_RS                = 35080,[35080] = "ACK_MOIL_PRESS_RS", 
    -- [35100]释放苦工 -- 苦工 
    REQ_MOIL_RELEASE                 = 35100,[35100] = "REQ_MOIL_RELEASE", 
    -- [35110]结果 -- 苦工 
    ACK_MOIL_RELEASE_RS              = 35110,[35110] = "ACK_MOIL_RELEASE_RS", 
    -- [35120]购买抓捕次数 -- 苦工 
    REQ_MOIL_BUY_CAPTRUE             = 35120,[35120] = "REQ_MOIL_BUY_CAPTRUE", 
    -- [35130]返回消耗信息 -- 苦工 
    ACK_MOIL_BUY_OK                  = 35130,[35130] = "ACK_MOIL_BUY_OK", 
    -- [35150]解救/求解结果 -- 苦工 
    ACK_MOIL_CALL_BACK               = 35150,[35150] = "ACK_MOIL_CALL_BACK", 
    -- [35160]查看玩家苦工 -- 苦工 
    REQ_MOIL_LOOK_TMOILS             = 35160,[35160] = "REQ_MOIL_LOOK_TMOILS", 
    -- [35170]苦工列表 -- 苦工 
    ACK_MOIL_TMOILS_BACK             = 35170,[35170] = "ACK_MOIL_TMOILS_BACK", 

    --------------------------------------------------------
    -- 36001 - 37000 ( 三界杀 ) 
    --------------------------------------------------------
    -- [36010]请求三界杀 -- 三界杀 
    REQ_CIRCLE_ENJOY                 = 36010,[36010] = "REQ_CIRCLE_ENJOY", 
    -- [36011]当前章节信息(新) -- 三界杀 
    ACK_CIRCLE_2_DATA                = 36011,[36011] = "ACK_CIRCLE_2_DATA", 
    -- [36020]当前章节信息(废除) -- 三界杀 
    ACK_CIRCLE_DATA                  = 36020,[36020] = "ACK_CIRCLE_DATA", 
    -- [36021]当前信息块(废除) -- 三界杀 
    ACK_CIRCLE_DATA_GROUP            = 36021,[36021] = "ACK_CIRCLE_DATA_GROUP", 
    -- [36022]当前信息块(新) -- 三界杀 
    ACK_CIRCLE_2_DATA_GROUP          = 36022,[36022] = "ACK_CIRCLE_2_DATA_GROUP", 
    -- [36030]请求重置 -- 三界杀 
    REQ_CIRCLE_RESET                 = 36030,[36030] = "REQ_CIRCLE_RESET", 
    -- [36040]开始挑战 -- 三界杀 
    REQ_CIRCLE_WAR_START             = 36040,[36040] = "REQ_CIRCLE_WAR_START", 

    --------------------------------------------------------
    -- 37001 - 38000 ( 世界BOSS ) 
    --------------------------------------------------------
    -- [37004]请求面板 -- 世界BOSS 
    REQ_WORLD_BOSS_REQUEST           = 37004,[37004] = "REQ_WORLD_BOSS_REQUEST", 
    -- [37005]世界BOSS面板返回 -- 世界BOSS 
    ACK_WORLD_BOSS_REPLY             = 37005,[37005] = "ACK_WORLD_BOSS_REPLY", 
    -- [37007]世界BOSS状态信息块 -- 世界BOSS 
    ACK_WORLD_BOSS_XXX               = 37007,[37007] = "ACK_WORLD_BOSS_XXX", 
    -- [37010]进入boss -- 世界BOSS 
    REQ_WORLD_BOSS_CITY_BOOSS        = 37010,[37010] = "REQ_WORLD_BOSS_CITY_BOOSS", 
    -- [37020]返回地图数据 -- 世界BOSS 
    ACK_WORLD_BOSS_MAP_DATA          = 37020,[37020] = "ACK_WORLD_BOSS_MAP_DATA", 
    -- [37053]自己伤害 -- 世界BOSS 
    ACK_WORLD_BOSS_SELF_HP           = 37053,[37053] = "ACK_WORLD_BOSS_SELF_HP", 
    -- [37060]DPS排行 -- 世界BOSS 
    ACK_WORLD_BOSS_DPS               = 37060,[37060] = "ACK_WORLD_BOSS_DPS", 
    -- [37070]DPS排行块 -- 世界BOSS 
    ACK_WORLD_BOSS_DPS_XX            = 37070,[37070] = "ACK_WORLD_BOSS_DPS_XX", 
    -- [37090]返回结果 -- 世界BOSS 
    ACK_WORLD_BOSS_WAR_RS            = 37090,[37090] = "ACK_WORLD_BOSS_WAR_RS", 
    -- [37100]退出世界BOSS -- 世界BOSS 
    REQ_WORLD_BOSS_EXIT_S            = 37100,[37100] = "REQ_WORLD_BOSS_EXIT_S", 
    -- [37110]复活 -- 世界BOSS 
    REQ_WORLD_BOSS_REVIVE            = 37110,[37110] = "REQ_WORLD_BOSS_REVIVE", 
    -- [37120]复活成功 -- 世界BOSS 
    ACK_WORLD_BOSS_REVIVE_OK         = 37120,[37120] = "ACK_WORLD_BOSS_REVIVE_OK", 
    -- [37160]请求排行版 -- 世界BOSS 
    REQ_WORLD_BOSS_ASK_SETTLE        = 37160,[37160] = "REQ_WORLD_BOSS_ASK_SETTLE", 
    -- [37170]结算榜显示 -- 世界BOSS 
    ACK_WORLD_BOSS_SETTLEMENT        = 37170,[37170] = "ACK_WORLD_BOSS_SETTLEMENT", 
    -- [37180]结算块 -- 世界BOSS 
    ACK_WORLD_BOSS_SETTLE_DATA       = 37180,[37180] = "ACK_WORLD_BOSS_SETTLE_DATA", 
    -- [37190]移除boss -- 世界BOSS 
    ACK_WORLD_BOSS_BOSS_LEVEL        = 37190,[37190] = "ACK_WORLD_BOSS_BOSS_LEVEL", 
    -- [37200]元宝鼓舞 -- 世界BOSS 
    REQ_WORLD_BOSS_RMB_ATTR          = 37200,[37200] = "REQ_WORLD_BOSS_RMB_ATTR", 
    -- [37205]鼓舞消耗 -- 世界BOSS 
    ACK_WORLD_BOSS_RMB_USE           = 37205,[37205] = "ACK_WORLD_BOSS_RMB_USE", 
    -- [37210]加成伤害 -- 世界BOSS 
    ACK_WORLD_BOSS_UP_ATTR           = 37210,[37210] = "ACK_WORLD_BOSS_UP_ATTR", 
    -- [37230]boss的当前血量 -- 世界BOSS 
    ACK_WORLD_BOSS_NOW_HP            = 37230,[37230] = "ACK_WORLD_BOSS_NOW_HP", 
    -- [37240]玩家死亡 -- 世界BOSS 
    ACK_WORLD_BOSS_PLAYER_DIE        = 37240,[37240] = "ACK_WORLD_BOSS_PLAYER_DIE", 
    -- [37302]请求购买世界BOSS信息 -- 世界BOSS 
    REQ_WORLD_BOSS_BUY_INFO          = 37302,[37302] = "REQ_WORLD_BOSS_BUY_INFO", 
    -- [37304]世界BOSS购买信息返回 -- 世界BOSS 
    ACK_WORLD_BOSS_BUY_INFO_ANS      = 37304,[37304] = "ACK_WORLD_BOSS_BUY_INFO_ANS", 
    -- [37306]请求购买世界BOSS -- 世界BOSS 
    REQ_WORLD_BOSS_BUY_REQ           = 37306,[37306] = "REQ_WORLD_BOSS_BUY_REQ", 
    -- [37308]请求购买世界BOSS返回 -- 世界BOSS 
    ACK_WORLD_BOSS_BUY_ANS           = 37308,[37308] = "ACK_WORLD_BOSS_BUY_ANS", 

    --------------------------------------------------------
    -- 38001 - 39000 ( 目标任务 ) 
    --------------------------------------------------------
    -- [38005]请求目标数据 -- 目标任务 
    REQ_TARGET_LIST_ASK              = 38005,[38005] = "REQ_TARGET_LIST_ASK", 
    -- [38010]目标数据返回 -- 目标任务 
    ACK_TARGET_LIST_BACK             = 38010,[38010] = "ACK_TARGET_LIST_BACK", 
    -- [38015]目标数据信息块 -- 目标任务 
    ACK_TARGET_MSG_GROUP             = 38015,[38015] = "ACK_TARGET_MSG_GROUP", 
    -- [38030]领取目标奖励 -- 目标任务 
    REQ_TARGET_REWARD_REQUEST        = 38030,[38030] = "REQ_TARGET_REWARD_REQUEST", 

    --------------------------------------------------------
    -- 39001 - 39500 ( 噩梦副本 ) 
    --------------------------------------------------------
    -- [39010]请求英雄副本 -- 噩梦副本 
    REQ_HERO_REQUEST                 = 39010,[39010] = "REQ_HERO_REQUEST", 
    -- [39015]请求全部英雄副本 -- 噩梦副本 
    REQ_HERO_REQUEST_ALL             = 39015,[39015] = "REQ_HERO_REQUEST_ALL", 
    -- [39018]全部章节信息 -- 噩梦副本 
    ACK_HERO_ALL_CHAP_DATA           = 39018,[39018] = "ACK_HERO_ALL_CHAP_DATA", 
    -- [39020]当前章节信息 -- 噩梦副本 
    ACK_HERO_CHAP_DATA               = 39020,[39020] = "ACK_HERO_CHAP_DATA", 
    -- [39030]战役数据信息块 -- 噩梦副本 
    ACK_HERO_MSG_BATTLE              = 39030,[39030] = "ACK_HERO_MSG_BATTLE", 
    -- [39050]购买英雄副本次数 -- 噩梦副本 
    REQ_HERO_BUY_TIMES               = 39050,[39050] = "REQ_HERO_BUY_TIMES", 
    -- [39060]购买次数返回 -- 噩梦副本 
    ACK_HERO_BACK_TIMES              = 39060,[39060] = "ACK_HERO_BACK_TIMES", 
    -- [39070]当前章节信息(new) -- 噩梦副本 
    ACK_HERO_CHAP_DATA_NEW           = 39070,[39070] = "ACK_HERO_CHAP_DATA_NEW", 
    -- [39080]战役数据信息块(new) -- 噩梦副本 
    ACK_HERO_MSG_BATTLE_NEW          = 39080,[39080] = "ACK_HERO_MSG_BATTLE_NEW", 
    -- [39090]请求精英副本次数 -- 噩梦副本 
    REQ_HERO_TIMES                   = 39090,[39090] = "REQ_HERO_TIMES", 
    -- [39095]精英次数返回 -- 噩梦副本 
    ACK_HERO_TIMES_REPLY             = 39095,[39095] = "ACK_HERO_TIMES_REPLY", 

    --------------------------------------------------------
    -- 39500 - 40000 ( 珍宝副本 ) 
    --------------------------------------------------------
    -- [39510]请求珍宝副本 -- 珍宝副本 
    REQ_COPY_GEM_REQUEST             = 39510,[39510] = "REQ_COPY_GEM_REQUEST", 
    -- [39520]请求全部珍宝副本 -- 珍宝副本 
    REQ_COPY_GEM_REQUEST_ALL         = 39520,[39520] = "REQ_COPY_GEM_REQUEST_ALL", 
    -- [39530]返回全部珍宝副本 -- 珍宝副本 
    ACK_COPY_GEM_CHAP_DATA_ALL       = 39530,[39530] = "ACK_COPY_GEM_CHAP_DATA_ALL", 
    -- [39535]当前章节信息 -- 珍宝副本 
    ACK_COPY_GEM_CHAP_DATA           = 39535,[39535] = "ACK_COPY_GEM_CHAP_DATA", 
    -- [39540]副本信息块 -- 珍宝副本 
    ACK_COPY_GEM_MSG_COPYS           = 39540,[39540] = "ACK_COPY_GEM_MSG_COPYS", 
    -- [39550]购买次数 -- 珍宝副本 
    REQ_COPY_GEM_TIMES_BUY           = 39550,[39550] = "REQ_COPY_GEM_TIMES_BUY", 
    -- [39555]次数购买返回 -- 珍宝副本 
    ACK_COPY_GEM_TIMES_REPLY         = 39555,[39555] = "ACK_COPY_GEM_TIMES_REPLY", 

    --------------------------------------------------------
    -- 40001 - 40500 ( 签到抽奖 ) 
    --------------------------------------------------------
    -- [40010]登录抽奖页面 -- 签到抽奖 
    REQ_SIGN_REQUEST                 = 40010,[40010] = "REQ_SIGN_REQUEST", 
    -- [40022]登陆签到过的物品 -- 签到抽奖 
    ACK_SIGN_REPLY                   = 40022,[40022] = "ACK_SIGN_REPLY", 
    -- [40032]是否领取信息块 -- 签到抽奖 
    ACK_SIGN_YES_MSG                 = 40032,[40032] = "ACK_SIGN_YES_MSG", 
    -- [40035]12天抽奖记录 -- 签到抽奖 
    ACK_SIGN_HISTORY                 = 40035,[40035] = "ACK_SIGN_HISTORY", 
    -- [40038]历史记录 -- 签到抽奖 
    ACK_SIGN_HISTORY_REP             = 40038,[40038] = "ACK_SIGN_HISTORY_REP", 
    -- [40040]抽取奖励 -- 签到抽奖 
    REQ_SIGN_GET                     = 40040,[40040] = "REQ_SIGN_GET", 
    -- [40052]返回抽取奖励信息 -- 签到抽奖 
    ACK_SIGN_GET_REP                 = 40052,[40052] = "ACK_SIGN_GET_REP", 
    -- [40060]弹窗 -- 签到抽奖 
    REQ_SIGN_IS_POP                  = 40060,[40060] = "REQ_SIGN_IS_POP", 
    -- [40062]弹窗数据 -- 签到抽奖 
    ACK_SIGN_POP_DATA                = 40062,[40062] = "ACK_SIGN_POP_DATA", 
    -- [40112]7天抽奖返回 -- 签到抽奖 
    ACK_SIGN_SEVEN_REP               = 40112,[40112] = "ACK_SIGN_SEVEN_REP", 

    --------------------------------------------------------
    -- 40501 - 41500 ( 帮派战 ) 
    --------------------------------------------------------
    -- [40502]请求帮派战界面 -- 帮派战 
    REQ_GANG_WARFARE_REPLAY          = 40502,[40502] = "REQ_GANG_WARFARE_REPLAY", 
    -- [40503]界面返回 -- 帮派战 
    ACK_GANG_WARFARE_BACK            = 40503,[40503] = "ACK_GANG_WARFARE_BACK", 
    -- [40505]请求帮派分组信息 -- 帮派战 
    REQ_GANG_WARFARE_REQ             = 40505,[40505] = "REQ_GANG_WARFARE_REQ", 
    -- [40510]分组信息 -- 帮派战 
    ACK_GANG_WARFARE_GROUP           = 40510,[40510] = "ACK_GANG_WARFARE_GROUP", 
    -- [40515]层信息块 -- 帮派战 
    ACK_GANG_WARFARE_GROUP_DATA      = 40515,[40515] = "ACK_GANG_WARFARE_GROUP_DATA", 
    -- [40516]小组帮派信息 -- 帮派战 
    ACK_GANG_WARFARE_CLAN_XXXX       = 40516,[40516] = "ACK_GANG_WARFARE_CLAN_XXXX", 
    -- [40517]组信息块 -- 帮派战 
    ACK_GANG_WARFARE_GROUP_XXXX      = 40517,[40517] = "ACK_GANG_WARFARE_GROUP_XXXX", 
    -- [40520]帮派战个人信息 -- 帮派战 
    REQ_GANG_WARFARE_ONCE_REQ        = 40520,[40520] = "REQ_GANG_WARFARE_ONCE_REQ", 
    -- [40521]请求进入帮派战 -- 帮派战 
    REQ_GANG_WARFARE_ENTER_MAP       = 40521,[40521] = "REQ_GANG_WARFARE_ENTER_MAP", 
    -- [40522]请求战报 -- 帮派战 
    REQ_GANG_WARFARE_WAR_REPORT      = 40522,[40522] = "REQ_GANG_WARFARE_WAR_REPORT", 
    -- [40525]返回帮派战基本信息 -- 帮派战 
    ACK_GANG_WARFARE_TIME            = 40525,[40525] = "ACK_GANG_WARFARE_TIME", 
    -- [40530]帮派战个人信息 -- 帮派战 
    ACK_GANG_WARFARE_ONCE            = 40530,[40530] = "ACK_GANG_WARFARE_ONCE", 
    -- [40535]帮排战况信息 -- 帮派战 
    ACK_GANG_WARFARE_LIVE            = 40535,[40535] = "ACK_GANG_WARFARE_LIVE", 
    -- [40540]帮派战况信息块 -- 帮派战 
    ACK_GANG_WARFARE_LIVE_DATA       = 40540,[40540] = "ACK_GANG_WARFARE_LIVE_DATA", 
    -- [40541]比赛开始 -- 帮派战 
    ACK_GANG_WARFARE_WAR_START       = 40541,[40541] = "ACK_GANG_WARFARE_WAR_START", 
    -- [40542]self血量校正 -- 帮派战 
    ACK_GANG_WARFARE_SELF_HP         = 40542,[40542] = "ACK_GANG_WARFARE_SELF_HP", 
    -- [40544]主动复活 -- 帮派战 
    REQ_GANG_WARFARE_INITIATIVE_REC  = 40544,[40544] = "REQ_GANG_WARFARE_INITIATIVE_REC", 
    -- [40545]死亡/复活协议 -- 帮派战 
    ACK_GANG_WARFARE_DIE             = 40545,[40545] = "ACK_GANG_WARFARE_DIE", 
    -- [40546]复活成功 -- 帮派战 
    ACK_GANG_WARFARE_REC_SUCCESS     = 40546,[40546] = "ACK_GANG_WARFARE_REC_SUCCESS", 
    -- [40550]初赛战果 -- 帮派战 
    ACK_GANG_WARFARE_C_FINISH        = 40550,[40550] = "ACK_GANG_WARFARE_C_FINISH", 
    -- [40555]参赛战况信息块 -- 帮派战 
    ACK_GANG_WARFARE_PART_DATA       = 40555,[40555] = "ACK_GANG_WARFARE_PART_DATA", 
    -- [40560]退出帮派战 -- 帮派战 
    REQ_GANG_WARFARE_EXIT_WAR        = 40560,[40560] = "REQ_GANG_WARFARE_EXIT_WAR", 
    -- [40565]是否已经阵亡 -- 帮派战 
    ACK_GANG_WARFARE_IS_OVER         = 40565,[40565] = "ACK_GANG_WARFARE_IS_OVER", 

    --------------------------------------------------------
    -- 41501 - 41600 ( 成就系统 ) 
    --------------------------------------------------------
    -- [41510]请求成就系统面板 -- 成就系统 
    REQ_ACHIEVE_REQUEST              = 41510,[41510] = "REQ_ACHIEVE_REQUEST", 
    -- [41520]成就系统返回 -- 成就系统 
    ACK_ACHIEVE_RELPY                = 41520,[41520] = "ACK_ACHIEVE_RELPY", 
    -- [41530]成就信息块 -- 成就系统 
    ACK_ACHIEVE_MSG                  = 41530,[41530] = "ACK_ACHIEVE_MSG", 
    -- [41540]成就领取 -- 成就系统 
    REQ_ACHIEVE_GET_REWARD           = 41540,[41540] = "REQ_ACHIEVE_GET_REWARD", 
    -- [41550]请求成就角标 -- 成就系统 
    REQ_ACHIEVE_REQ_POINT            = 41550,[41550] = "REQ_ACHIEVE_REQ_POINT", 
    -- [41560]成就角标返回 -- 成就系统 
    ACK_ACHIEVE_ANS_POINT            = 41560,[41560] = "ACK_ACHIEVE_ANS_POINT", 
    -- [41570]成就角标信息块 -- 成就系统 
    ACK_ACHIEVE_MSG_POINTS           = 41570,[41570] = "ACK_ACHIEVE_MSG_POINTS", 

    --------------------------------------------------------
    -- 41601 - 41700 ( 节日活动-金钱副本 ) 
    --------------------------------------------------------
    -- [41610]请求界面 -- 节日活动-金钱副本 
    REQ_COPY_MONEY_REQUEST           = 41610,[41610] = "REQ_COPY_MONEY_REQUEST", 
    -- [41620]界面返回 -- 节日活动-金钱副本 
    ACK_COPY_MONEY_REPLY             = 41620,[41620] = "ACK_COPY_MONEY_REPLY", 
    -- [41630]开始挑战 -- 节日活动-金钱副本 
    REQ_COPY_MONEY_START_WAR         = 41630,[41630] = "REQ_COPY_MONEY_START_WAR", 
    -- [41635]开始挑战返回 -- 节日活动-金钱副本 
    ACK_COPY_MONEY_START_REPLY       = 41635,[41635] = "ACK_COPY_MONEY_START_REPLY", 
    -- [51640]挑战结束返回 -- 节日活动-金钱副本 
    ACK_COPY_MONEY_OVER_REPLY        = 51640,[51640] = "ACK_COPY_MONEY_OVER_REPLY", 

    --------------------------------------------------------
    -- 42501 - 43500 ( 收集卡片 ) 
    --------------------------------------------------------
    -- [42510]查询是否有卡片活动 -- 收集卡片 
    REQ_COLLECT_CARD_ASK_LIMIT       = 42510,[42510] = "REQ_COLLECT_CARD_ASK_LIMIT", 
    -- [42511]卡片活动状态有变化 -- 收集卡片 
    ACK_COLLECT_CARD_STATE_REFRESH   = 42511,[42511] = "ACK_COLLECT_CARD_STATE_REFRESH", 
    -- [42512]卡片活动开放结果 -- 收集卡片 
    ACK_COLLECT_CARD_LIMIT_RESULT    = 42512,[42512] = "ACK_COLLECT_CARD_LIMIT_RESULT", 
    -- [42520]请求卡片套装和奖励数据 -- 收集卡片 
    REQ_COLLECT_CARD_ASK_DATA        = 42520,[42520] = "REQ_COLLECT_CARD_ASK_DATA", 
    -- [42522]卡片套装和奖励数据返回 -- 收集卡片 
    ACK_COLLECT_CARD_DATA_BACK       = 42522,[42522] = "ACK_COLLECT_CARD_DATA_BACK", 
    -- [42524]套装数据信息块 -- 收集卡片 
    ACK_COLLECT_CARD_XXX1            = 42524,[42524] = "ACK_COLLECT_CARD_XXX1", 
    -- [42526]物品信息块 -- 收集卡片 
    ACK_COLLECT_CARD_XXX2            = 42526,[42526] = "ACK_COLLECT_CARD_XXX2", 
    -- [42528]虚拟货币信息块 -- 收集卡片 
    ACK_COLLECT_CARD_XXX3            = 42528,[42528] = "ACK_COLLECT_CARD_XXX3", 
    -- [42530]请求兑换卡片套装奖励 -- 收集卡片 
    REQ_COLLECT_CARD_EXCHANGE        = 42530,[42530] = "REQ_COLLECT_CARD_EXCHANGE", 
    -- [42532]兑换成功 -- 收集卡片 
    ACK_COLLECT_CARD_EXCHANGE_OK     = 42532,[42532] = "ACK_COLLECT_CARD_EXCHANGE_OK", 
    -- [42540]请求兑换所需金元 -- 收集卡片 
    REQ_COLLECT_CARD_EXCHANGE_COST   = 42540,[42540] = "REQ_COLLECT_CARD_EXCHANGE_COST", 
    -- [42542]兑换所需金元 -- 收集卡片 
    ACK_COLLECT_CARD_COST_BACK       = 42542,[42542] = "ACK_COLLECT_CARD_COST_BACK", 

    --------------------------------------------------------
    -- 43501 - 44500 ( 跨服战 ) 
    --------------------------------------------------------
    -- [43510]请求问鼎天宫 -- 跨服战 
    REQ_STRIDE_ENJOY                 = 43510,[43510] = "REQ_STRIDE_ENJOY", 
    -- [43520]进入成功 -- 跨服战 
    ACK_STRIDE_ENJOY_BACK            = 43520,[43520] = "ACK_STRIDE_ENJOY_BACK", 
    -- [43540]请求排行榜 -- 跨服战 
    REQ_STRIDE_RANK                  = 43540,[43540] = "REQ_STRIDE_RANK", 
    -- [43541]排行榜 -- 跨服战 
    ACK_STRIDE_RANK_HAIG             = 43541,[43541] = "ACK_STRIDE_RANK_HAIG", 
    -- [43542]排行榜数据块 -- 跨服战 
    ACK_STRIDE_HAIG_DATA             = 43542,[43542] = "ACK_STRIDE_HAIG_DATA", 
    -- [43543]个人排名信息 -- 跨服战 
    ACK_STRIDE_SELF_HAIG             = 43543,[43543] = "ACK_STRIDE_SELF_HAIG", 
    -- [43545]请求挑战列表 -- 跨服战 
    REQ_STRIDE_ASK_RANK_DATA         = 43545,[43545] = "REQ_STRIDE_ASK_RANK_DATA", 
    -- [43549]越级挑战的所有组别 -- 跨服战 
    ACK_STRIDE_YJ_GROUP              = 43549,[43549] = "ACK_STRIDE_YJ_GROUP", 
    -- [43550]挑战列表 -- 跨服战 
    ACK_STRIDE_RANK_DATA             = 43550,[43550] = "ACK_STRIDE_RANK_DATA", 
    -- [43551]数据块 -- 跨服战 
    ACK_STRIDE_RANK_2_DATA           = 43551,[43551] = "ACK_STRIDE_RANK_2_DATA", 
    -- [43552]可领的宝箱 -- 跨服战 
    ACK_STRIDE_CAN_AWARD             = 43552,[43552] = "ACK_STRIDE_CAN_AWARD", 
    -- [43553]领取宝箱 -- 跨服战 
    REQ_STRIDE_AWARD_NUM             = 43553,[43553] = "REQ_STRIDE_AWARD_NUM", 
    -- [43554]领取宝箱成功 -- 跨服战 
    ACK_STRIDE_AWARD_OK              = 43554,[43554] = "ACK_STRIDE_AWARD_OK", 
    -- [43555]战报日志 -- 跨服战 
    ACK_STRIDE_WAR_LOGS              = 43555,[43555] = "ACK_STRIDE_WAR_LOGS", 
    -- [43556]战报日志信息块 -- 跨服战 
    ACK_STRIDE_WAR_2_LOGS            = 43556,[43556] = "ACK_STRIDE_WAR_2_LOGS", 
    -- [43620]请求挑战 -- 跨服战 
    REQ_STRIDE_ASK_POWER             = 43620,[43620] = "REQ_STRIDE_ASK_POWER", 
    -- [43625]战力返回 -- 跨服战 
    ACK_STRIDE_POWER_BACK            = 43625,[43625] = "ACK_STRIDE_POWER_BACK", 
    -- [43630]挑战--问鼎天宫 -- 跨服战 
    REQ_STRIDE_STRIDE_WAR            = 43630,[43630] = "REQ_STRIDE_STRIDE_WAR", 
    -- [43631]挑战结束--问鼎天宫 -- 跨服战 
    REQ_STRIDE_WAR_OVER              = 43631,[43631] = "REQ_STRIDE_WAR_OVER", 
    -- [43633]挑战结果--问鼎天宫 -- 跨服战 
    ACK_STRIDE_STRIDE_WAR_RS         = 43633,[43633] = "ACK_STRIDE_STRIDE_WAR_RS", 
    -- [43634]挑战--决战凌霄 -- 跨服战 
    REQ_STRIDE_SUPERIOR_WAR          = 43634,[43634] = "REQ_STRIDE_SUPERIOR_WAR", 
    -- [43636]挑战结束--决战凌霄 -- 跨服战 
    REQ_STRIDE_SUPERIOR_OVER         = 43636,[43636] = "REQ_STRIDE_SUPERIOR_OVER", 
    -- [43637]挑战结果--决战凌霄 -- 跨服战 
    ACK_STRIDE_SUPERIOR_RS           = 43637,[43637] = "ACK_STRIDE_SUPERIOR_RS", 
    -- [43650]购买越级挑战 -- 跨服战 
    REQ_STRIDE_STRIDE_UP             = 43650,[43650] = "REQ_STRIDE_STRIDE_UP", 
    -- [43655]越级购买成功 -- 跨服战 
    ACK_STRIDE_BUY_CG                = 43655,[43655] = "ACK_STRIDE_BUY_CG", 
    -- [43660]购买挑战次数 -- 跨服战 
    REQ_STRIDE_BUY_COUNT             = 43660,[43660] = "REQ_STRIDE_BUY_COUNT", 
    -- [43670]购买成功 -- 跨服战 
    ACK_STRIDE_BUY_OK                = 43670,[43670] = "ACK_STRIDE_BUY_OK", 
    -- [43760]可领的宝箱 -- 跨服战 
    ACK_STRIDE_CAN_AWARD_SEC         = 43760,[43760] = "ACK_STRIDE_CAN_AWARD_SEC", 

    --------------------------------------------------------
    -- 44501 - 44600 ( 御前科举 ) 
    --------------------------------------------------------
    -- [44510]请求答题面板 -- 御前科举 
    REQ_KEJU_ASK_KEJU                = 44510,[44510] = "REQ_KEJU_ASK_KEJU", 
    -- [44520]答题面板返回 -- 御前科举 
    ACK_KEJU_ASK_REPLY               = 44520,[44520] = "ACK_KEJU_ASK_REPLY", 
    -- [44525]排行榜信息块 -- 御前科举 
    ACK_KEJU_XXX_RANK                = 44525,[44525] = "ACK_KEJU_XXX_RANK", 
    -- [44530]答题信息块（44540） -- 御前科举 
    ACK_KEJU_XXX_ANSWER              = 44530,[44530] = "ACK_KEJU_XXX_ANSWER", 
    -- [44540]可选答案信息 -- 御前科举 
    ACK_KEJU_MSG_OPTIONS             = 44540,[44540] = "ACK_KEJU_MSG_OPTIONS", 
    -- [44550]开始答题 -- 御前科举 
    REQ_KEJU_START                   = 44550,[44550] = "REQ_KEJU_START", 
    -- [44560]开始答题返回 -- 御前科举 
    ACK_KEJU_START_REPLY             = 44560,[44560] = "ACK_KEJU_START_REPLY", 
    -- [44562]答题 -- 御前科举 
    REQ_KEJU_ANSWER                  = 44562,[44562] = "REQ_KEJU_ANSWER", 
    -- [44565]答题返回 -- 御前科举 
    ACK_KEJU_ANSWER_REPLY            = 44565,[44565] = "ACK_KEJU_ANSWER_REPLY", 
    -- [44570]算卦去错 -- 御前科举 
    REQ_KEJU_OUT_WRONG               = 44570,[44570] = "REQ_KEJU_OUT_WRONG", 
    -- [44575]算卦去错返回 -- 御前科举 
    ACK_KEJU_OUT_WRONG_REPLY         = 44575,[44575] = "ACK_KEJU_OUT_WRONG_REPLY", 
    -- [44580]贿赂考官 -- 御前科举 
    REQ_KEJU_BRIBE                   = 44580,[44580] = "REQ_KEJU_BRIBE", 
    -- [44585]贿赂考官返回 -- 御前科举 
    ACK_KEJU_BRIBE_REPLY             = 44585,[44585] = "ACK_KEJU_BRIBE_REPLY", 

    --------------------------------------------------------
    -- 44601 - 44800 ( 悬赏任务 ) 
    --------------------------------------------------------
    -- [44610]请求任务 -- 悬赏任务 
    REQ_REWARD_TASK_REQUEST          = 44610,[44610] = "REQ_REWARD_TASK_REQUEST", 
    -- [44620]任务返回 -- 悬赏任务 
    ACK_REWARD_TASK_REPLAY           = 44620,[44620] = "ACK_REWARD_TASK_REPLAY", 
    -- [44630]任务信息块 -- 悬赏任务 
    ACK_REWARD_TASK_DATA             = 44630,[44630] = "ACK_REWARD_TASK_DATA", 
    -- [44640]接受任务 -- 悬赏任务 
    REQ_REWARD_TASK_ACCEPT           = 44640,[44640] = "REQ_REWARD_TASK_ACCEPT", 
    -- [44645]接受成功 -- 悬赏任务 
    ACK_REWARD_TASK_ACCEPT_BACK      = 44645,[44645] = "ACK_REWARD_TASK_ACCEPT_BACK", 
    -- [44650]提交领奖 -- 悬赏任务 
    REQ_REWARD_TASK_SUBMIT           = 44650,[44650] = "REQ_REWARD_TASK_SUBMIT", 
    -- [44660]快速完成任务 -- 悬赏任务 
    REQ_REWARD_TASK_COMPLETE         = 44660,[44660] = "REQ_REWARD_TASK_COMPLETE", 
    -- [44680]刷新任务 -- 悬赏任务 
    REQ_REWARD_TASK_REFRESH          = 44680,[44680] = "REQ_REWARD_TASK_REFRESH", 
    -- [44690]任务完成 -- 悬赏任务 
    ACK_REWARD_TASK_FINISH           = 44690,[44690] = "ACK_REWARD_TASK_FINISH", 

    --------------------------------------------------------
    -- 44801 - 45600 ( 跨服竞技场 ) 
    --------------------------------------------------------
    -- [44810]进入 -- 跨服竞技场 
    REQ_CROSS_JOIN                   = 44810,[44810] = "REQ_CROSS_JOIN", 
    -- [44820]可以挑战的玩家列表 -- 跨服竞技场 
    ACK_CROSS_DEKARON                = 44820,[44820] = "ACK_CROSS_DEKARON", 
    -- [44830]挑战 -- 跨服竞技场 
    REQ_CROSS_BATTLE                 = 44830,[44830] = "REQ_CROSS_BATTLE", 
    -- [44835]cd冷却中 -- 跨服竞技场 
    ACK_CROSS_CD_ONLINE_SEC          = 44835,[44835] = "ACK_CROSS_CD_ONLINE_SEC", 
    -- [44840]验证通过 -- 跨服竞技场 
    ACK_CROSS_THROUGH                = 44840,[44840] = "ACK_CROSS_THROUGH", 
    -- [44850]挑战结束 -- 跨服竞技场 
    REQ_CROSS_FINISH                 = 44850,[44850] = "REQ_CROSS_FINISH", 
    -- [44860]挑战奖励 -- 跨服竞技场 
    ACK_CROSS_WAR_REWARD             = 44860,[44860] = "ACK_CROSS_WAR_REWARD", 
    -- [44880]请求排行榜 -- 跨服竞技场 
    REQ_CROSS_RANKING_LISTS          = 44880,[44880] = "REQ_CROSS_RANKING_LISTS", 
    -- [44890]返回排行榜信息 -- 跨服竞技场 
    ACK_CROSS_RANKING_DATA           = 44890,[44890] = "ACK_CROSS_RANKING_DATA", 
    -- [44891]高手信息 -- 跨服竞技场 
    ACK_CROSS_RANK_XXX               = 44891,[44891] = "ACK_CROSS_RANK_XXX", 
    -- [44900]返回战报信息 -- 跨服竞技场 
    ACK_CROSS_MAX_DATA               = 44900,[44900] = "ACK_CROSS_MAX_DATA", 
    -- [44905]请求购买次数 -- 跨服竞技场 
    REQ_CROSS_ASK_BUY                = 44905,[44905] = "REQ_CROSS_ASK_BUY", 
    -- [44906]询价返回 -- 跨服竞技场 
    ACK_CROSS_ASK_BACK               = 44906,[44906] = "ACK_CROSS_ASK_BACK", 
    -- [44910]购买挑战次数 -- 跨服竞技场 
    REQ_CROSS_BUY                    = 44910,[44910] = "REQ_CROSS_BUY", 
    -- [44920]购买成功 -- 跨服竞技场 
    ACK_CROSS_BUY_OK                 = 44920,[44920] = "ACK_CROSS_BUY_OK", 
    -- [44950]奖励倒计时 -- 跨服竞技场 
    ACK_CROSS_REWARD_TIME            = 44950,[44950] = "ACK_CROSS_REWARD_TIME", 
    -- [44960]清除CD时间 -- 跨服竞技场 
    REQ_CROSS_CLEAN                  = 44960,[44960] = "REQ_CROSS_CLEAN", 
    -- [44970]清除成功 -- 跨服竞技场 
    ACK_CROSS_CLEAN_OK               = 44970,[44970] = "ACK_CROSS_CLEAN_OK", 

    --------------------------------------------------------
    -- 45601 - 46000 ( 活动-阵营战 ) 
    --------------------------------------------------------
    -- [45610]请求阵营战界面 -- 活动-阵营战 
    REQ_CAMPWAR_ASK_WAR              = 45610,[45610] = "REQ_CAMPWAR_ASK_WAR", 
    -- [45620]界面请求返回 -- 活动-阵营战 
    ACK_CAMPWAR_OK_ASK_WAR           = 45620,[45620] = "ACK_CAMPWAR_OK_ASK_WAR", 
    -- [45630]各种倒计时 -- 活动-阵营战 
    ACK_CAMPWAR_D_TIME               = 45630,[45630] = "ACK_CAMPWAR_D_TIME", 
    -- [45640]阵营积分数据 -- 活动-阵营战 
    ACK_CAMPWAR_CAMP_POINTS          = 45640,[45640] = "ACK_CAMPWAR_CAMP_POINTS", 
    -- [45650]连胜榜数据 -- 活动-阵营战 
    ACK_CAMPWAR_WINNING_STREAK       = 45650,[45650] = "ACK_CAMPWAR_WINNING_STREAK", 
    -- [45655]连胜玩家信息块 -- 活动-阵营战 
    ACK_CAMPWAR_PLY_DATA             = 45655,[45655] = "ACK_CAMPWAR_PLY_DATA", 
    -- [45670]个人战绩 -- 活动-阵营战 
    ACK_CAMPWAR_SELF_WAR             = 45670,[45670] = "ACK_CAMPWAR_SELF_WAR", 
    -- [45680]请求振奋 -- 活动-阵营战 
    REQ_CAMPWAR_ASK_BESTIR           = 45680,[45680] = "REQ_CAMPWAR_ASK_BESTIR", 
    -- [45690]请求振奋成功 -- 活动-阵营战 
    ACK_CAMPWAR_OK_BESTIR            = 45690,[45690] = "ACK_CAMPWAR_OK_BESTIR", 
    -- [45695]属性加成信息块 -- 活动-阵营战 
    ACK_CAMPWAR_ATTR_MSG             = 45695,[45695] = "ACK_CAMPWAR_ATTR_MSG", 
    -- [45720]开始匹配战斗 -- 活动-阵营战 
    REQ_CAMPWAR_START_MACHING        = 45720,[45720] = "REQ_CAMPWAR_START_MACHING", 
    -- [45750]战斗结束 -- 活动-阵营战 
    REQ_CAMPWAR_END_WAR              = 45750,[45750] = "REQ_CAMPWAR_END_WAR", 
    -- [45755]战报数据 -- 活动-阵营战 
    ACK_CAMPWAR_WAR_DATA             = 45755,[45755] = "ACK_CAMPWAR_WAR_DATA", 
    -- [45757]奖励数据块 -- 活动-阵营战 
    ACK_CAMPWAR_REWARDS_DATA         = 45757,[45757] = "ACK_CAMPWAR_REWARDS_DATA", 
    -- [45760]玩家死亡 -- 活动-阵营战 
    ACK_CAMPWAR_DIE                  = 45760,[45760] = "ACK_CAMPWAR_DIE", 
    -- [45770]复活（废） -- 活动-阵营战 
    REQ_CAMPWAR_RELIVE               = 45770,[45770] = "REQ_CAMPWAR_RELIVE", 
    -- [45780]复活成功（废） -- 活动-阵营战 
    ACK_CAMPWAR_OK_RELIVE            = 45780,[45780] = "ACK_CAMPWAR_OK_RELIVE", 
    -- [45790]请求退出活动 -- 活动-阵营战 
    REQ_CAMPWAR_ASK_BACK             = 45790,[45790] = "REQ_CAMPWAR_ASK_BACK", 
    -- [45800]请求设置战报数据类型 -- 活动-阵营战 
    REQ_CAMPWAR_ASK_WAR_DATA         = 45800,[45800] = "REQ_CAMPWAR_ASK_WAR_DATA", 
    -- [45810]战报数据返回 -- 活动-阵营战 
    ACK_CAMPWAR_OK_WARDATA           = 45810,[45810] = "ACK_CAMPWAR_OK_WARDATA", 
    -- [45850]活动结束 -- 活动-阵营战 
    ACK_CAMPWAR_CAMP_END             = 45850,[45850] = "ACK_CAMPWAR_CAMP_END", 

    --------------------------------------------------------
    -- 46001 - 46200 ( 每日转盘 ) 
    --------------------------------------------------------
    -- [46010]请求转盘 -- 每日转盘 
    REQ_WHEEL_REQUEST                = 46010,[46010] = "REQ_WHEEL_REQUEST", 
    -- [46012]转盘返回 -- 每日转盘 
    ACK_WHEEL_REPLY                  = 46012,[46012] = "ACK_WHEEL_REPLY", 
    -- [46015]抽奖信息块返回 -- 每日转盘 
    ACK_WHEEL_LOTTERY_MSG            = 46015,[46015] = "ACK_WHEEL_LOTTERY_MSG", 
    -- [46020]开始抽奖 -- 每日转盘 
    REQ_WHEEL_LOTTERY                = 46020,[46020] = "REQ_WHEEL_LOTTERY", 
    -- [46022]抽奖信息返回 -- 每日转盘 
    ACK_WHEEL_LOTTERY_REP            = 46022,[46022] = "ACK_WHEEL_LOTTERY_REP", 

    --------------------------------------------------------
    -- 46201 - 47200 ( 魔王副本 ) 
    --------------------------------------------------------
    -- [46210]请求魔王副本 -- 魔王副本 
    REQ_FIEND_REQUEST                = 46210,[46210] = "REQ_FIEND_REQUEST", 
    -- [46215]请求全部魔王副本 -- 魔王副本 
    REQ_FIEND_REQUEST_ALL            = 46215,[46215] = "REQ_FIEND_REQUEST_ALL", 
    -- [46218]全部章节信息 -- 魔王副本 
    ACK_FIEND_CHAP_DATA_ALL          = 46218,[46218] = "ACK_FIEND_CHAP_DATA_ALL", 
    -- [46220]当前章节信息 -- 魔王副本 
    ACK_FIEND_CHAP_DATA              = 46220,[46220] = "ACK_FIEND_CHAP_DATA", 
    -- [46230]战役数据信息块 -- 魔王副本 
    ACK_FIEND_MSG_BATTLE             = 46230,[46230] = "ACK_FIEND_MSG_BATTLE", 
    -- [46250]刷新魔王副本 -- 魔王副本 
    REQ_FIEND_FRESH_COPY             = 46250,[46250] = "REQ_FIEND_FRESH_COPY", 
    -- [46260]刷新魔王副本返回 -- 魔王副本 
    ACK_FIEND_FRESH_BACK             = 46260,[46260] = "ACK_FIEND_FRESH_BACK", 
    -- [46270]当前章节信息(new) -- 魔王副本 
    ACK_FIEND_CHAP_DATA_NEW          = 46270,[46270] = "ACK_FIEND_CHAP_DATA_NEW", 
    -- [46280]战役数据信息块(new -- 魔王副本 
    ACK_FIEND_MSG_BATTLE_NEW         = 46280,[46280] = "ACK_FIEND_MSG_BATTLE_NEW", 

    --------------------------------------------------------
    -- 47201 - 48200 ( 珍宝阁 ) 
    --------------------------------------------------------
    -- [47201]请求珍宝 -- 珍宝阁 
    REQ_TREASURE_LEVEL_ID            = 47201,[47201] = "REQ_TREASURE_LEVEL_ID", 
    -- [47210]藏宝阁面板 -- 珍宝阁 
    ACK_TREASURE_REQUEST_INFO        = 47210,[47210] = "ACK_TREASURE_REQUEST_INFO", 
    -- [47215]物品信息块 -- 珍宝阁 
    ACK_TREASURE_GOODSMSG            = 47215,[47215] = "ACK_TREASURE_GOODSMSG", 
    -- [47220]物品打造数据请求 -- 珍宝阁 
    REQ_TREASURE_GOODS_ID            = 47220,[47220] = "REQ_TREASURE_GOODS_ID", 
    -- [47230]打造成功 -- 珍宝阁 
    ACK_TREASURE_SUCCESS_DZ          = 47230,[47230] = "ACK_TREASURE_SUCCESS_DZ", 

    --------------------------------------------------------
    -- 48201 - 49200 ( 八卦系统 ) 
    --------------------------------------------------------
    -- [48201]仓库数据 -- 八卦系统 
    ACK_SYS_DOUQI_STORAGE_DATA       = 48201,[48201] = "ACK_SYS_DOUQI_STORAGE_DATA", 
    -- [48203]卦象信息块 -- 八卦系统 
    ACK_SYS_DOUQI_DOUQI_DATA         = 48203,[48203] = "ACK_SYS_DOUQI_DOUQI_DATA", 
    -- [48210]请求占卦界面 -- 八卦系统 
    REQ_SYS_DOUQI_ASK_GRASP_DOUQI    = 48210,[48210] = "REQ_SYS_DOUQI_ASK_GRASP_DOUQI", 
    -- [48211]请求开始占卦 -- 八卦系统 
    REQ_SYS_DOUQI_ASK_START_GRASP    = 48211,[48211] = "REQ_SYS_DOUQI_ASK_START_GRASP", 
    -- [48220]占卦界面信息返回 -- 八卦系统 
    ACK_SYS_DOUQI_OK_GRASP_DATA      = 48220,[48220] = "ACK_SYS_DOUQI_OK_GRASP_DATA", 
    -- [48223]一键占卦数据返回 -- 八卦系统 
    ACK_SYS_DOUQI_MORE_GRASP         = 48223,[48223] = "ACK_SYS_DOUQI_MORE_GRASP", 
    -- [48225]一键占卦数据 -- 八卦系统 
    ACK_SYS_DOUQI_MSG_MORE           = 48225,[48225] = "ACK_SYS_DOUQI_MSG_MORE", 
    -- [48230]请求装备卦象界面 -- 八卦系统 
    REQ_SYS_DOUQI_ASK_USR_GRASP      = 48230,[48230] = "REQ_SYS_DOUQI_ASK_USR_GRASP", 
    -- [48235]请求玩家已装备的卦象 -- 八卦系统 
    REQ_SYS_DOUQI_OTHER_USR_GRASP    = 48235,[48235] = "REQ_SYS_DOUQI_OTHER_USR_GRASP", 
    -- [48237]玩家vip等级信息 -- 八卦系统 
    ACK_SYS_DOUQI_VIP_LV             = 48237,[48237] = "ACK_SYS_DOUQI_VIP_LV", 
    -- [48242]装备界面信息返回 最新 -- 八卦系统 
    ACK_SYS_DOUQI_ROLE_NEW           = 48242,[48242] = "ACK_SYS_DOUQI_ROLE_NEW", 
    -- [48245]伙伴数据信息块 -- 八卦系统 
    ACK_SYS_DOUQI_ROLE_DATA          = 48245,[48245] = "ACK_SYS_DOUQI_ROLE_DATA", 
    -- [48280]请求一键吞噬 -- 八卦系统 
    REQ_SYS_DOUQI_ASK_EAT            = 48280,[48280] = "REQ_SYS_DOUQI_ASK_EAT", 
    -- [48285]吞噬结果 -- 八卦系统 
    ACK_SYS_DOUQI_EAT_STATE          = 48285,[48285] = "ACK_SYS_DOUQI_EAT_STATE", 
    -- [48290]吞噬结果信息块 -- 八卦系统 
    ACK_SYS_DOUQI_EAT_DATA           = 48290,[48290] = "ACK_SYS_DOUQI_EAT_DATA", 
    -- [48295]被吞者位置ID列表 -- 八卦系统 
    ACK_SYS_DOUQI_LAN_MSG            = 48295,[48295] = "ACK_SYS_DOUQI_LAN_MSG", 
    -- [48300]请求拾取卦象 -- 八卦系统 
    REQ_SYS_DOUQI_ASK_GET_DQ         = 48300,[48300] = "REQ_SYS_DOUQI_ASK_GET_DQ", 
    -- [48310]拾取成功 -- 八卦系统 
    ACK_SYS_DOUQI_OK_GET_DQ          = 48310,[48310] = "ACK_SYS_DOUQI_OK_GET_DQ", 
    -- [48380]请求移动卦象位置 -- 八卦系统 
    REQ_SYS_DOUQI_ASK_USE_DOUQI      = 48380,[48380] = "REQ_SYS_DOUQI_ASK_USE_DOUQI", 
    -- [48390]移动卦象成功 -- 八卦系统 
    ACK_SYS_DOUQI_OK_USE_DOUQI       = 48390,[48390] = "ACK_SYS_DOUQI_OK_USE_DOUQI", 
    -- [48394]请求玩家挂阵 -- 八卦系统 
    REQ_SYS_DOUQI_OTHER_CLEAR        = 48394,[48394] = "REQ_SYS_DOUQI_OTHER_CLEAR", 
    -- [48395]请求卦阵 -- 八卦系统 
    REQ_SYS_DOUQI_ASK_CLEAR          = 48395,[48395] = "REQ_SYS_DOUQI_ASK_CLEAR", 
    -- [48396]卦阵信息 -- 八卦系统 
    ACK_SYS_DOUQI_CLEAR_BACK         = 48396,[48396] = "ACK_SYS_DOUQI_CLEAR_BACK", 
    -- [48400]请求升级卦阵 -- 八卦系统 
    REQ_SYS_DOUQI_ASK_CLEAR_STORAG   = 48400,[48400] = "REQ_SYS_DOUQI_ASK_CLEAR_STORAG", 
    -- [48410]升级卦阵返回 -- 八卦系统 
    ACK_SYS_DOUQI_STORAG_BACK        = 48410,[48410] = "ACK_SYS_DOUQI_STORAG_BACK", 

    --------------------------------------------------------
    -- 49201 - 50200 ( 日常任务 ) 
    --------------------------------------------------------
    -- [49201]日常任务数据返回 -- 日常任务 
    ACK_DAILY_TASK_DATA              = 49201,[49201] = "ACK_DAILY_TASK_DATA", 
    -- [49202]请求任务数据 -- 日常任务 
    REQ_DAILY_TASK_REQUEST           = 49202,[49202] = "REQ_DAILY_TASK_REQUEST", 
    -- [49203]请求放弃任务 -- 日常任务 
    REQ_DAILY_TASK_DROP              = 49203,[49203] = "REQ_DAILY_TASK_DROP", 
    -- [49204]领取奖励 -- 日常任务 
    REQ_DAILY_TASK_REWARD            = 49204,[49204] = "REQ_DAILY_TASK_REWARD", 
    -- [49205]vip刷新次数 -- 日常任务 
    REQ_DAILY_TASK_VIP_REFRESH       = 49205,[49205] = "REQ_DAILY_TASK_VIP_REFRESH", 
    -- [49206]日常任务当前轮次 -- 日常任务 
    ACK_DAILY_TASK_TURN              = 49206,[49206] = "ACK_DAILY_TASK_TURN", 
    -- [49207]一键完成日常任务 -- 日常任务 
    REQ_DAILY_TASK_KEY               = 49207,[49207] = "REQ_DAILY_TASK_KEY", 

    --------------------------------------------------------
    -- 50201 - 50400 ( 翻翻乐 ) 
    --------------------------------------------------------
    -- [50210]请求剩余次数 -- 翻翻乐 
    REQ_FLSH_TIMES_REQUEST           = 50210,[50210] = "REQ_FLSH_TIMES_REQUEST", 
    -- [50220]次数返回 -- 翻翻乐 
    ACK_FLSH_TIMES_REPLY             = 50220,[50220] = "ACK_FLSH_TIMES_REPLY", 
    -- [50230]开始游戏 -- 翻翻乐 
    REQ_FLSH_GAME_START              = 50230,[50230] = "REQ_FLSH_GAME_START", 
    -- [50240]牌返回 -- 翻翻乐 
    ACK_FLSH_PAI_REPLY               = 50240,[50240] = "ACK_FLSH_PAI_REPLY", 
    -- [50245]牌信息块 -- 翻翻乐 
    ACK_FLSH_MSG_PAI_XXX             = 50245,[50245] = "ACK_FLSH_MSG_PAI_XXX", 
    -- [50260]换牌 -- 翻翻乐 
    REQ_FLSH_PAI_SWITCH              = 50260,[50260] = "REQ_FLSH_PAI_SWITCH", 
    -- [50261]牌的位置 -- 翻翻乐 
    REQ_FLSH_CARD_POS                = 50261,[50261] = "REQ_FLSH_CARD_POS", 
    -- [50280]领取奖励 -- 翻翻乐 
    REQ_FLSH_GET_REWARD              = 50280,[50280] = "REQ_FLSH_GET_REWARD", 
    -- [50290]奖励OK -- 翻翻乐 
    ACK_FLSH_REWARD_OK               = 50290,[50290] = "ACK_FLSH_REWARD_OK", 
    -- [50295]奖励返回 -- 翻翻乐 
    ACK_FLSH_FLSH_REWARD_POS         = 50295,[50295] = "ACK_FLSH_FLSH_REWARD_POS", 

    --------------------------------------------------------
    -- 50401 - 50700 ( 人物升级奖励 ) 
    --------------------------------------------------------
    -- [50401]申请 等级及状态 -- 人物升级奖励 
    REQ_LV_REWARD_REQUEST            = 50401,[50401] = "REQ_LV_REWARD_REQUEST", 
    -- [50405]领取等级及状态 -- 人物升级奖励 
    ACK_LV_REWARD_LV_STATE           = 50405,[50405] = "ACK_LV_REWARD_LV_STATE", 
    -- [50410]领取奖励 -- 人物升级奖励 
    REQ_LV_REWARD_REWARD_GET         = 50410,[50410] = "REQ_LV_REWARD_REWARD_GET", 

    --------------------------------------------------------
    -- 50701 - 51200 ( 对牌 ) 
    --------------------------------------------------------
    -- [50701]请求面板或重新开始 -- 对牌 
    REQ_MATCH_CARD_REQUEST           = 50701,[50701] = "REQ_MATCH_CARD_REQUEST", 
    -- [50705]面板回复 -- 对牌 
    ACK_MATCH_CARD_REPLY             = 50705,[50705] = "ACK_MATCH_CARD_REPLY", 
    -- [50710]牌位置与内容 -- 对牌 
    ACK_MATCH_CARD_CARD_MSG          = 50710,[50710] = "ACK_MATCH_CARD_CARD_MSG", 
    -- [50712]翻开一张 -- 对牌 
    REQ_MATCH_CARD_SIGN_CARD         = 50712,[50712] = "REQ_MATCH_CARD_SIGN_CARD", 
    -- [50715]对牌 -- 对牌 
    REQ_MATCH_CARD_REQUEST_MATCH     = 50715,[50715] = "REQ_MATCH_CARD_REQUEST_MATCH", 
    -- [50720]对牌回复 -- 对牌 
    ACK_MATCH_CARD_MATCH_REPLY       = 50720,[50720] = "ACK_MATCH_CARD_MATCH_REPLY", 
    -- [50725]申请偷看（1为一张，2为二张） -- 对牌 
    REQ_MATCH_CARD_LOOK              = 50725,[50725] = "REQ_MATCH_CARD_LOOK", 
    -- [50730]偷看回复 -- 对牌 
    ACK_MATCH_CARD_LOOK_REPLY        = 50730,[50730] = "ACK_MATCH_CARD_LOOK_REPLY", 
    -- [50735]偷看一对 -- 对牌 
    ACK_MATCH_CARD_LOOK_DOUBLE       = 50735,[50735] = "ACK_MATCH_CARD_LOOK_DOUBLE", 

    --------------------------------------------------------
    -- 51201 - 52100 ( 道劫 ) 
    --------------------------------------------------------
    -- [51210]请求道劫界面 -- 道劫 
    REQ_HOOK_REQUEST                 = 51210,[51210] = "REQ_HOOK_REQUEST", 
    -- [51215]返回解锁章节 -- 道劫 
    ACK_HOOK_RETURN                  = 51215,[51215] = "ACK_HOOK_RETURN", 
    -- [51220]章节信息 -- 道劫 
    ACK_HOOK_CHAP_DATA               = 51220,[51220] = "ACK_HOOK_CHAP_DATA", 
    -- [51225]副本信息 -- 道劫 
    ACK_HOOK_COPY_DATA               = 51225,[51225] = "ACK_HOOK_COPY_DATA", 
    -- [51230]请求副本信息 -- 道劫 
    REQ_HOOK_REQUEST_MSG             = 51230,[51230] = "REQ_HOOK_REQUEST_MSG", 
    -- [51235]请求副本信息返回 -- 道劫 
    ACK_HOOK_MSG_BACK                = 51235,[51235] = "ACK_HOOK_MSG_BACK", 

    --------------------------------------------------------
    -- 52101 - 52200 ( 神羽 ) 
    --------------------------------------------------------
    -- [52110]穿戴神羽 -- 神羽 
    REQ_FEATHER_DRESS                = 52110,[52110] = "REQ_FEATHER_DRESS", 
    -- [52115]穿戴神羽返回 -- 神羽 
    ACK_FEATHER_DRESS_REPLY          = 52115,[52115] = "ACK_FEATHER_DRESS_REPLY", 
    -- [52120]请求神羽界面 -- 神羽 
    REQ_FEATHER_REQUEST              = 52120,[52120] = "REQ_FEATHER_REQUEST", 
    -- [52125]神羽界面返回 -- 神羽 
    ACK_FEATHER_REPLY                = 52125,[52125] = "ACK_FEATHER_REPLY", 
    -- [52130]神羽信息块 -- 神羽 
    ACK_FEATHER_XXX_DATA             = 52130,[52130] = "ACK_FEATHER_XXX_DATA", 
    -- [52135]神羽升级 -- 神羽 
    REQ_FEATHER_LV_UP                = 52135,[52135] = "REQ_FEATHER_LV_UP", 
    -- [52140]神羽升级经验值飘字 -- 神羽 
    ACK_FEATHER_EXP_ADD              = 52140,[52140] = "ACK_FEATHER_EXP_ADD", 
    -- [52145]神羽升阶 -- 神羽 
    REQ_FEATHER_QUALITY_UP           = 52145,[52145] = "REQ_FEATHER_QUALITY_UP", 
    -- [52150]神羽激活 -- 神羽 
    REQ_FEATHER_ACTIVATE             = 52150,[52150] = "REQ_FEATHER_ACTIVATE", 
    -- [52180]神羽技能 -- 神羽 
    ACK_FEATHER_SKILL                = 52180,[52180] = "ACK_FEATHER_SKILL", 

    --------------------------------------------------------
    -- 52201 - 53200 ( 神兵系统 ) 
    --------------------------------------------------------
    -- [52205]请求强化面板 -- 神兵系统 
    REQ_MAGIC_EQUIP_STRENG           = 52205,[52205] = "REQ_MAGIC_EQUIP_STRENG", 
    -- [52210]强化面板返回 -- 神兵系统 
    ACK_MAGIC_EQUIP_STRENG_BACK      = 52210,[52210] = "ACK_MAGIC_EQUIP_STRENG_BACK", 
    -- [52213]属性信息块 -- 神兵系统 
    ACK_MAGIC_EQUIP_MSG_ATTR         = 52213,[52213] = "ACK_MAGIC_EQUIP_MSG_ATTR", 
    -- [52215]请求进阶面板 -- 神兵系统 
    REQ_MAGIC_EQUIP_REQUEST_ADVANCE  = 52215,[52215] = "REQ_MAGIC_EQUIP_REQUEST_ADVANCE", 
    -- [52217]请求进阶面板返回 -- 神兵系统 
    ACK_MAGIC_EQUIP_ADVANCE_BACK     = 52217,[52217] = "ACK_MAGIC_EQUIP_ADVANCE_BACK", 
    -- [52218]洗练属性信息块 -- 神兵系统 
    ACK_MAGIC_EQUIP_MSG_WASH_ATTR    = 52218,[52218] = "ACK_MAGIC_EQUIP_MSG_WASH_ATTR", 
    -- [52219]洗练属性信息块2 -- 神兵系统 
    ACK_MAGIC_EQUIP_MSG_WASH_ATTR2   = 52219,[52219] = "ACK_MAGIC_EQUIP_MSG_WASH_ATTR2", 
    -- [52220]强化 -- 神兵系统 
    REQ_MAGIC_EQUIP_ENHANCED         = 52220,[52220] = "REQ_MAGIC_EQUIP_ENHANCED", 
    -- [52225]洗练面板 -- 神兵系统 
    REQ_MAGIC_EQUIP_WASH_REQUEST     = 52225,[52225] = "REQ_MAGIC_EQUIP_WASH_REQUEST", 
    -- [52227]洗练面板返回 -- 神兵系统 
    ACK_MAGIC_EQUIP_WASH_BACK        = 52227,[52227] = "ACK_MAGIC_EQUIP_WASH_BACK", 
    -- [52230]进阶 -- 神兵系统 
    REQ_MAGIC_EQUIP_ADVANCE          = 52230,[52230] = "REQ_MAGIC_EQUIP_ADVANCE", 
    -- [52235]神器洗练 -- 神兵系统 
    REQ_MAGIC_EQUIP_WASH             = 52235,[52235] = "REQ_MAGIC_EQUIP_WASH", 
    -- [52237]洗练保存 -- 神兵系统 
    REQ_MAGIC_EQUIP_WASH_SAVE        = 52237,[52237] = "REQ_MAGIC_EQUIP_WASH_SAVE", 
    -- [52240]强化返回 -- 神兵系统 
    ACK_MAGIC_EQUIP_ENHANCED_REPLY   = 52240,[52240] = "ACK_MAGIC_EQUIP_ENHANCED_REPLY", 
    -- [52243]进阶返回 -- 神兵系统 
    ACK_MAGIC_EQUIP_ADVANCE_REPLY    = 52243,[52243] = "ACK_MAGIC_EQUIP_ADVANCE_REPLY", 
    -- [52245]洗练返回 -- 神兵系统 
    ACK_MAGIC_EQUIP_WASH_REPLY       = 52245,[52245] = "ACK_MAGIC_EQUIP_WASH_REPLY", 
    -- [52250]需要多少钱 -- 神兵系统 
    REQ_MAGIC_EQUIP_NEED_MONEY       = 52250,[52250] = "REQ_MAGIC_EQUIP_NEED_MONEY", 
    -- [52260]神器强化所需要钱数返回 -- 神兵系统 
    ACK_MAGIC_EQUIP_NEED_MONEY_REPLY = 52260,[52260] = "ACK_MAGIC_EQUIP_NEED_MONEY_REPLY", 
    -- [52300]请求下一级神器 -- 神兵系统 
    REQ_MAGIC_EQUIP_ASK_NEXT_ATTR    = 52300,[52300] = "REQ_MAGIC_EQUIP_ASK_NEXT_ATTR", 
    -- [52310]属性返回 -- 神兵系统 
    ACK_MAGIC_EQUIP_ATTR_REPLY       = 52310,[52310] = "ACK_MAGIC_EQUIP_ATTR_REPLY", 
    -- [52315]材料信息块 -- 神兵系统 
    ACK_MAGIC_EQUIP_MSG_ITEM_XXX     = 52315,[52315] = "ACK_MAGIC_EQUIP_MSG_ITEM_XXX", 
    -- [52320]属性值 -- 神兵系统 
    ACK_MAGIC_EQUIP_ATTR             = 52320,[52320] = "ACK_MAGIC_EQUIP_ATTR", 
    -- [52330]请求幻化界面 -- 神兵系统 
    REQ_MAGIC_EQUIP_REQUEST_HUANHUA  = 52330,[52330] = "REQ_MAGIC_EQUIP_REQUEST_HUANHUA", 
    -- [52340]幻化界面返回 -- 神兵系统 
    ACK_MAGIC_EQUIP_REPLY_HUANHUA    = 52340,[52340] = "ACK_MAGIC_EQUIP_REPLY_HUANHUA", 
    -- [52350]神器信息块 -- 神兵系统 
    ACK_MAGIC_EQUIP_MSG_MAGICS       = 52350,[52350] = "ACK_MAGIC_EQUIP_MSG_MAGICS", 
    -- [52360]开始幻化 -- 神兵系统 
    REQ_MAGIC_EQUIP_HUANHUA          = 52360,[52360] = "REQ_MAGIC_EQUIP_HUANHUA", 
    -- [52370]请求当前身上时装和翅膀 -- 神兵系统 
    REQ_MAGIC_EQUIP_REQUEST_SKINS    = 52370,[52370] = "REQ_MAGIC_EQUIP_REQUEST_SKINS", 
    -- [52380]返回当前身上时装和翅膀 -- 神兵系统 
    ACK_MAGIC_EQUIP_REPLY_SKINS      = 52380,[52380] = "ACK_MAGIC_EQUIP_REPLY_SKINS", 
    -- [52390]幻化成功 -- 神兵系统 
    ACK_MAGIC_EQUIP_HUANHUA_SUCCESS  = 52390,[52390] = "ACK_MAGIC_EQUIP_HUANHUA_SUCCESS", 
    -- [52400]请求神器界面 -- 神兵系统 
    REQ_MAGIC_EQUIP_REQUEST          = 52400,[52400] = "REQ_MAGIC_EQUIP_REQUEST", 
    -- [52405]神器界面返回 -- 神兵系统 
    ACK_MAGIC_EQUIP_REPLY            = 52405,[52405] = "ACK_MAGIC_EQUIP_REPLY", 
    -- [52410]请求单个神兵 -- 神兵系统 
    REQ_MAGIC_EQUIP_REQUEST_ONE      = 52410,[52410] = "REQ_MAGIC_EQUIP_REQUEST_ONE", 
    -- [52415]单个神兵请求返回 -- 神兵系统 
    ACK_MAGIC_EQUIP_REPLY_ONE        = 52415,[52415] = "ACK_MAGIC_EQUIP_REPLY_ONE", 
    -- [52420]使用神兵 -- 神兵系统 
    REQ_MAGIC_EQUIP_USE              = 52420,[52420] = "REQ_MAGIC_EQUIP_USE", 
    -- [52425]使用神兵返回 -- 神兵系统 
    ACK_MAGIC_EQUIP_USE_REPLY        = 52425,[52425] = "ACK_MAGIC_EQUIP_USE_REPLY", 
    -- [52430]卸下神兵成功 -- 神兵系统 
    ACK_MAGIC_EQUIP_OFF_OK           = 52430,[52430] = "ACK_MAGIC_EQUIP_OFF_OK", 

    --------------------------------------------------------
    -- 53201 - 54200 ( 三国基金 ) 
    --------------------------------------------------------
    -- [53210]请求三国基金面板 -- 三国基金 
    REQ_PRIVILEGE_REQUEST            = 53210,[53210] = "REQ_PRIVILEGE_REQUEST", 
    -- [53220]面板返回(废弃) -- 三国基金 
    ACK_PRIVILEGE_REPLY              = 53220,[53220] = "ACK_PRIVILEGE_REPLY", 
    -- [53223]领取信息块 -- 三国基金 
    ACK_PRIVILEGE_MSG_GET            = 53223,[53223] = "ACK_PRIVILEGE_MSG_GET", 
    -- [53225]全部投资信息块 -- 三国基金 
    ACK_PRIVILEGE_MSG                = 53225,[53225] = "ACK_PRIVILEGE_MSG", 
    -- [53230]开启投资理财 -- 三国基金 
    REQ_PRIVILEGE_OPEN               = 53230,[53230] = "REQ_PRIVILEGE_OPEN", 
    -- [53240]开启/领取基金返回 -- 三国基金 
    ACK_PRIVILEGE_OPEN_CB            = 53240,[53240] = "ACK_PRIVILEGE_OPEN_CB", 
    -- [53250]领取 -- 三国基金 
    REQ_PRIVILEGE_GET_REWARDS        = 53250,[53250] = "REQ_PRIVILEGE_GET_REWARDS", 
    -- [53251]领取成功返回 -- 三国基金 
    ACK_PRIVILEGE_GET_REWARDS_CB     = 53251,[53251] = "ACK_PRIVILEGE_GET_REWARDS_CB", 
    -- [53255]返回基金信息 -- 三国基金 
    ACK_PRIVILEGE_FUND_MSG           = 53255,[53255] = "ACK_PRIVILEGE_FUND_MSG", 

    --------------------------------------------------------
    -- 54201 - 54800 ( 帮派BOSS ) 
    --------------------------------------------------------
    -- [54220]请求开启社团BOSS -- 帮派BOSS 
    REQ_CLAN_BOSS_START_BOSS         = 54220,[54220] = "REQ_CLAN_BOSS_START_BOSS", 
    -- [54230]洞府boss挑战状态 -- 帮派BOSS 
    ACK_CLAN_BOSS_STATE              = 54230,[54230] = "ACK_CLAN_BOSS_STATE", 

    --------------------------------------------------------
    -- 54801 - 55000 ( 三界争锋 ) 
    --------------------------------------------------------
    -- [54810]请求三界争锋界面 -- 三界争锋 
    REQ_WRESTLE_REQUEST              = 54810,[54810] = "REQ_WRESTLE_REQUEST", 
    -- [54820]三界争锋界面返回 -- 三界争锋 
    ACK_WRESTLE_REPLY                = 54820,[54820] = "ACK_WRESTLE_REPLY", 
    -- [54830]报名信息块 -- 三界争锋 
    ACK_WRESTLE_BOOK_XXX             = 54830,[54830] = "ACK_WRESTLE_BOOK_XXX", 
    -- [54840]没有报名信息块 -- 三界争锋 
    ACK_WRESTLE_BOOK_NO_XXX          = 54840,[54840] = "ACK_WRESTLE_BOOK_NO_XXX", 
    -- [54850]初赛排行榜信息块 -- 三界争锋 
    ACK_WRESTLE_GROUP_XXX            = 54850,[54850] = "ACK_WRESTLE_GROUP_XXX", 
    -- [54855]排名信息块 -- 三界争锋 
    ACK_WRESTLE_RANK_XXX             = 54855,[54855] = "ACK_WRESTLE_RANK_XXX", 
    -- [54860]决赛信息块 -- 三界争锋 
    ACK_WRESTLE_FINAL_XXX            = 54860,[54860] = "ACK_WRESTLE_FINAL_XXX", 
    -- [54865]决赛详情信息块 -- 三界争锋 
    ACK_WRESTLE_FINAL_XXX2           = 54865,[54865] = "ACK_WRESTLE_FINAL_XXX2", 
    -- [54870]请求欢乐竞猜下注界面 -- 三界争锋 
    REQ_WRESTLE_REQUEST_GUESS        = 54870,[54870] = "REQ_WRESTLE_REQUEST_GUESS", 
    -- [54880]欢乐竞猜界面返回 -- 三界争锋 
    ACK_WRESTLE_REPLY_GUESS          = 54880,[54880] = "ACK_WRESTLE_REPLY_GUESS", 
    -- [54885]欢乐竞猜总竞猜金额 -- 三界争锋 
    ACK_WRESTLE_GUESS_TOTAL          = 54885,[54885] = "ACK_WRESTLE_GUESS_TOTAL", 
    -- [54890]欢乐竞猜下注 -- 三界争锋 
    REQ_WRESTLE_GUESS_BET            = 54890,[54890] = "REQ_WRESTLE_GUESS_BET", 
    -- [54895]请求报名 -- 三界争锋 
    REQ_WRESTLE_REQUEST_BOOK         = 54895,[54895] = "REQ_WRESTLE_REQUEST_BOOK", 
    -- [54900]请求报名返回 -- 三界争锋 
    ACK_WRESTLE_REPLY_BOOK           = 54900,[54900] = "ACK_WRESTLE_REPLY_BOOK", 
    -- [54910]报名成功返回 -- 三界争锋 
    ACK_WRESTLE_BOOK_SUCCESS         = 54910,[54910] = "ACK_WRESTLE_BOOK_SUCCESS", 
    -- [54920]请求其他小组数据 -- 三界争锋 
    REQ_WRESTLE_REQUEST_GROUP        = 54920,[54920] = "REQ_WRESTLE_REQUEST_GROUP", 
    -- [54930]请求我的比赛页面 -- 三界争锋 
    REQ_WRESTLE_REQUEST_MY_GAME      = 54930,[54930] = "REQ_WRESTLE_REQUEST_MY_GAME", 
    -- [54935]我的比赛返回 -- 三界争锋 
    ACK_WRESTLE_REPLY_MY_GAME        = 54935,[54935] = "ACK_WRESTLE_REPLY_MY_GAME", 
    -- [54940]时间倒计时 -- 三界争锋 
    ACK_WRESTLE_TIME                 = 54940,[54940] = "ACK_WRESTLE_TIME", 
    -- [54950]战斗结束结算 -- 三界争锋 
    ACK_WRESTLE_WAR_STATE            = 54950,[54950] = "ACK_WRESTLE_WAR_STATE", 
    -- [54955]请求王者争霸界面 -- 三界争锋 
    REQ_WRESTLE_REQUEST_KING         = 54955,[54955] = "REQ_WRESTLE_REQUEST_KING", 
    -- [54960]王者争霸界面返回 -- 三界争锋 
    ACK_WRESTLE_REPLY_KING           = 54960,[54960] = "ACK_WRESTLE_REPLY_KING", 
    -- [54965]输赢结果信息块 -- 三界争锋 
    ACK_WRESTLE_MSG_RES              = 54965,[54965] = "ACK_WRESTLE_MSG_RES", 

    --------------------------------------------------------
    -- 55001 - 55300 ( 独尊三界 ) 
    --------------------------------------------------------
    -- [55010]请求我的比赛页面 -- 独尊三界 
    REQ_TXDY_SUPER_REQUEST_MY_GAME   = 55010,[55010] = "REQ_TXDY_SUPER_REQUEST_MY_GAME", 
    -- [55015]我的比赛返回 -- 独尊三界 
    ACK_TXDY_SUPER_REPLY_MY_GAME     = 55015,[55015] = "ACK_TXDY_SUPER_REPLY_MY_GAME", 
    -- [55020]请求独尊三界界面 -- 独尊三界 
    REQ_TXDY_SUPER_REQUEST           = 55020,[55020] = "REQ_TXDY_SUPER_REQUEST", 
    -- [55023]独尊三界请求返回 -- 独尊三界 
    ACK_TXDY_SUPER_REPLY             = 55023,[55023] = "ACK_TXDY_SUPER_REPLY", 
    -- [55025]小组信息返回 -- 独尊三界 
    ACK_TXDY_SUPER_REPLY_GROUP       = 55025,[55025] = "ACK_TXDY_SUPER_REPLY_GROUP", 
    -- [55030]小组信息块 -- 独尊三界 
    ACK_TXDY_SUPER_MSG_XXX           = 55030,[55030] = "ACK_TXDY_SUPER_MSG_XXX", 
    -- [55040]决赛界面返回 -- 独尊三界 
    ACK_TXDY_SUPER_REPLY_FINAL       = 55040,[55040] = "ACK_TXDY_SUPER_REPLY_FINAL", 
    -- [55045]请求王者争霸界面 -- 独尊三界 
    REQ_TXDY_SUPER_REQUEST_KING      = 55045,[55045] = "REQ_TXDY_SUPER_REQUEST_KING", 
    -- [55050]王者争霸界面返回 -- 独尊三界 
    ACK_TXDY_SUPER_REPLY_KING        = 55050,[55050] = "ACK_TXDY_SUPER_REPLY_KING", 
    -- [55055]结果信息块 -- 独尊三界 
    ACK_TXDY_SUPER_MSG_RESULT        = 55055,[55055] = "ACK_TXDY_SUPER_MSG_RESULT", 
    -- [55060]各种倒计时 -- 独尊三界 
    ACK_TXDY_SUPER_TIME              = 55060,[55060] = "ACK_TXDY_SUPER_TIME", 
    -- [55065]请求竞猜榜 -- 独尊三界 
    REQ_TXDY_SUPER_REQUEST_GUESS     = 55065,[55065] = "REQ_TXDY_SUPER_REQUEST_GUESS", 
    -- [55070]竞猜榜返回 -- 独尊三界 
    ACK_TXDY_SUPER_REPLY_GUESS       = 55070,[55070] = "ACK_TXDY_SUPER_REPLY_GUESS", 
    -- [55075]竞猜数据块 -- 独尊三界 
    ACK_TXDY_SUPER_GUESS_XXX         = 55075,[55075] = "ACK_TXDY_SUPER_GUESS_XXX", 
    -- [55080]欢乐竞猜下注 -- 独尊三界 
    REQ_TXDY_SUPER_GUESS_BET         = 55080,[55080] = "REQ_TXDY_SUPER_GUESS_BET", 
    -- [55085]欢乐竞猜下注返回 -- 独尊三界 
    ACK_TXDY_SUPER_GUESS_BET_REPLY   = 55085,[55085] = "ACK_TXDY_SUPER_GUESS_BET_REPLY", 
    -- [55090]请求欢乐竞猜下注界面 -- 独尊三界 
    REQ_TXDY_SUPER_GUESS_BET_REQ     = 55090,[55090] = "REQ_TXDY_SUPER_GUESS_BET_REQ", 
    -- [55095]欢乐竞猜总竞猜金额 -- 独尊三界 
    ACK_TXDY_SUPER_GUESS_TOTAL       = 55095,[55095] = "ACK_TXDY_SUPER_GUESS_TOTAL", 
    -- [55100]战斗结算 -- 独尊三界 
    ACK_TXDY_SUPER_WAR_REPLY         = 55100,[55100] = "ACK_TXDY_SUPER_WAR_REPLY", 
    -- [55120]请求三界界主 -- 独尊三界 
    REQ_TXDY_SUPER_REQUEST_FIRST     = 55120,[55120] = "REQ_TXDY_SUPER_REQUEST_FIRST", 
    -- [55125]请求三界界主返回 -- 独尊三界 
    ACK_TXDY_SUPER_REPLY_FIRST       = 55125,[55125] = "ACK_TXDY_SUPER_REPLY_FIRST", 

    --------------------------------------------------------
    -- 55301 - 55800 ( 一骑当千 ) 
    --------------------------------------------------------
    -- [55310]请求准备界面 -- 一骑当千 
    REQ_THOUSAND_REQUEST             = 55310,[55310] = "REQ_THOUSAND_REQUEST", 
    -- [55320]准备界面返回 -- 一骑当千 
    ACK_THOUSAND_REPLY               = 55320,[55320] = "ACK_THOUSAND_REPLY", 
    -- [55330]信息块 -- 一骑当千 
    ACK_THOUSAND_MSG_XXX             = 55330,[55330] = "ACK_THOUSAND_MSG_XXX", 
    -- [55340]技能信息块 -- 一骑当千 
    ACK_THOUSAND_MSG_SKILL           = 55340,[55340] = "ACK_THOUSAND_MSG_SKILL", 
    -- [55350]请求购买页面 -- 一骑当千 
    REQ_THOUSAND_REQUEST_BUY         = 55350,[55350] = "REQ_THOUSAND_REQUEST_BUY", 
    -- [55360]购买页面返回 -- 一骑当千 
    ACK_THOUSAND_REPLY_BUY           = 55360,[55360] = "ACK_THOUSAND_REPLY_BUY", 
    -- [55370]确认购买 -- 一骑当千 
    REQ_THOUSAND_BUY                 = 55370,[55370] = "REQ_THOUSAND_BUY", 
    -- [55380]购买成功返回 -- 一骑当千 
    ACK_THOUSAND_BUY_SUCCESS         = 55380,[55380] = "ACK_THOUSAND_BUY_SUCCESS", 
    -- [55390]开始挑战 -- 一骑当千 
    REQ_THOUSAND_WAR_BEGIN           = 55390,[55390] = "REQ_THOUSAND_WAR_BEGIN", 
    -- [55395]开始挑战返回 -- 一骑当千 
    ACK_THOUSAND_WAR_REPLY           = 55395,[55395] = "ACK_THOUSAND_WAR_REPLY", 
    -- [55410]是否为新纪录 -- 一骑当千 
    ACK_THOUSAND_NEW_RECORD          = 55410,[55410] = "ACK_THOUSAND_NEW_RECORD", 
    -- [55450]请求排行榜 -- 一骑当千 
    REQ_THOUSAND_REQUEST_RANK        = 55450,[55450] = "REQ_THOUSAND_REQUEST_RANK", 
    -- [55455]排行榜返回 -- 一骑当千 
    ACK_THOUSAND_REPLY_RANK          = 55455,[55455] = "ACK_THOUSAND_REPLY_RANK", 
    -- [55460]排行榜信息块 -- 一骑当千 
    ACK_THOUSAND_MSG_RANK            = 55460,[55460] = "ACK_THOUSAND_MSG_RANK", 
    -- [55465]点击说明-完成任务指引 -- 一骑当千 
    REQ_THOUSAND_TASK_FINISH         = 55465,[55465] = "REQ_THOUSAND_TASK_FINISH", 

    --------------------------------------------------------
    -- 55801 - 56800 ( 拳皇生涯 ) 
    --------------------------------------------------------
    -- [55810]请求拳皇信息 -- 拳皇生涯 
    REQ_FIGHTERS_REQUEST             = 55810,[55810] = "REQ_FIGHTERS_REQUEST", 
    -- [55820]当前章节信息 -- 拳皇生涯 
    ACK_FIGHTERS_CHAP_DATA           = 55820,[55820] = "ACK_FIGHTERS_CHAP_DATA", 
    -- [55830]战役数据信息块 -- 拳皇生涯 
    ACK_FIGHTERS_MSG_BATTLE          = 55830,[55830] = "ACK_FIGHTERS_MSG_BATTLE", 
    -- [55840]下一层副本ID -- 拳皇生涯 
    ACK_FIGHTERS_NEXT_COPY_ID        = 55840,[55840] = "ACK_FIGHTERS_NEXT_COPY_ID", 
    -- [55860]开始挂机 -- 拳皇生涯 
    REQ_FIGHTERS_UP_START            = 55860,[55860] = "REQ_FIGHTERS_UP_START", 
    -- [55870]挂机返回 -- 拳皇生涯 
    ACK_FIGHTERS_UP_REPLY            = 55870,[55870] = "ACK_FIGHTERS_UP_REPLY", 
    -- [55875]物品信息块 -- 拳皇生涯 
    ACK_FIGHTERS_MSG_GOOD            = 55875,[55875] = "ACK_FIGHTERS_MSG_GOOD", 
    -- [55960]重置挂机 -- 拳皇生涯 
    REQ_FIGHTERS_UP_RESET            = 55960,[55960] = "REQ_FIGHTERS_UP_RESET", 

    --------------------------------------------------------
    -- 56801 - 57800 ( 系统设置 ) 
    --------------------------------------------------------
    -- [56810]勾选功能 -- 系统设置 
    REQ_SYS_SET_CHECK                = 56810,[56810] = "REQ_SYS_SET_CHECK", 
    -- [56820]各功能状态 -- 系统设置 
    ACK_SYS_SET_TYPE_STATE           = 56820,[56820] = "ACK_SYS_SET_TYPE_STATE", 
    -- [56830]状态信息块 -- 系统设置 
    ACK_SYS_SET_XXXXX                = 56830,[56830] = "ACK_SYS_SET_XXXXX", 
    -- [56840]领取奖励(微信) -- 系统设置 
    REQ_SYS_SET_WX_REPLY             = 56840,[56840] = "REQ_SYS_SET_WX_REPLY", 
    -- [56842]领取成功 -- 系统设置 
    ACK_SYS_SET_WX_PLY               = 56842,[56842] = "ACK_SYS_SET_WX_PLY", 
    -- [56845]请求微信奖励 -- 系统设置 
    REQ_SYS_SET_WX_ASK               = 56845,[56845] = "REQ_SYS_SET_WX_ASK", 
    -- [56850]微信奖励状态 -- 系统设置 
    ACK_SYS_SET_WX_BACK              = 56850,[56850] = "ACK_SYS_SET_WX_BACK", 

    --------------------------------------------------------
    -- 57801 - 58000 ( 阵法系统 ) 
    --------------------------------------------------------
    -- [57810]请求阵法信息 -- 阵法系统 
    REQ_MATRIX_REQUEST               = 57810,[57810] = "REQ_MATRIX_REQUEST", 
    -- [57820]当前阵法信息 -- 阵法系统 
    ACK_MATRIX_REPLY                 = 57820,[57820] = "ACK_MATRIX_REPLY", 
    -- [57830]点亮节点 -- 阵法系统 
    REQ_MATRIX_LIGHTS                = 57830,[57830] = "REQ_MATRIX_LIGHTS", 
    -- [57840]成功点亮 -- 阵法系统 
    ACK_MATRIX_LIGHTS_OK             = 57840,[57840] = "ACK_MATRIX_LIGHTS_OK", 
    -- [57850]阵法升阶 -- 阵法系统 
    REQ_MATRIX_UP_GRADE              = 57850,[57850] = "REQ_MATRIX_UP_GRADE", 
    -- [57855]自动升阶 -- 阵法系统 
    REQ_MATRIX_AUTOMATIC             = 57855,[57855] = "REQ_MATRIX_AUTOMATIC", 
    -- [57860]升阶返回 -- 阵法系统 
    ACK_MATRIX_UP_GRADE_BACK         = 57860,[57860] = "ACK_MATRIX_UP_GRADE_BACK", 
    -- [57870]激活高阶阵法技能 -- 阵法系统 
    REQ_MATRIX_OPEN                  = 57870,[57870] = "REQ_MATRIX_OPEN", 
    -- [57875]星石更新 -- 阵法系统 
    ACK_MATRIX_STONE                 = 57875,[57875] = "ACK_MATRIX_STONE", 

    --------------------------------------------------------
    -- 58001 - 58200 ( 月卡 ) 
    --------------------------------------------------------
    -- [58001]请求月卡信息 -- 月卡 
    REQ_YUEKA_REQUEST                = 58001,[58001] = "REQ_YUEKA_REQUEST", 
    -- [58005]月卡信息返回 -- 月卡 
    ACK_YUEKA_REQUEST_CB             = 58005,[58005] = "ACK_YUEKA_REQUEST_CB", 
    -- [58010]月卡信息块 -- 月卡 
    ACK_YUEKA_KA_MSG                 = 58010,[58010] = "ACK_YUEKA_KA_MSG", 
    -- [58020]购买月卡返回 -- 月卡 
    ACK_YUEKA_BUY_CB                 = 58020,[58020] = "ACK_YUEKA_BUY_CB", 
    -- [58025]领取月卡奖励 -- 月卡 
    REQ_YUEKA_GET_REWARDS            = 58025,[58025] = "REQ_YUEKA_GET_REWARDS", 
    -- [58030]领取月卡返回 -- 月卡 
    ACK_YUEKA_GET_REWARDS_CB         = 58030,[58030] = "ACK_YUEKA_GET_REWARDS_CB", 

    --------------------------------------------------------
    -- 58201 - 58300 ( N日首充 ) 
    --------------------------------------------------------
    -- [58201]N日首充请求 -- N日首充 
    REQ_N_CHARGE_REQUEST             = 58201,[58201] = "REQ_N_CHARGE_REQUEST", 
    -- [58203]请求第几天数据 -- N日首充 
    REQ_N_CHARGE_REQUEST_N           = 58203,[58203] = "REQ_N_CHARGE_REQUEST_N", 
    -- [58204]请求第几天数据（回） -- N日首充 
    ACK_N_CHARGE_REQUEST_N_CB        = 58204,[58204] = "ACK_N_CHARGE_REQUEST_N_CB", 
    -- [58205]请求返回 -- N日首充 
    ACK_N_CHARGE_REQUEST_CB          = 58205,[58205] = "ACK_N_CHARGE_REQUEST_CB", 
    -- [58210]领取 -- N日首充 
    REQ_N_CHARGE_GET_REWARDS         = 58210,[58210] = "REQ_N_CHARGE_GET_REWARDS", 
    -- [58215]领取返回 -- N日首充 
    ACK_N_CHARGE_GET_REPLY           = 58215,[58215] = "ACK_N_CHARGE_GET_REPLY", 

    --------------------------------------------------------
    -- 58301 - 58400 ( 抢红包 ) 
    --------------------------------------------------------
    -- [28301]通知 -- 抢红包 
    ACK_HONGBAO_SEND_ALL             = 28301,[28301] = "ACK_HONGBAO_SEND_ALL", 
    -- [58305]关闭通知 -- 抢红包 
    ACK_HONGBAO_SHUTDOWN             = 58305,[58305] = "ACK_HONGBAO_SHUTDOWN", 
    -- [58310]领取 -- 抢红包 
    REQ_HONGBAO_GET_REWARDS          = 58310,[58310] = "REQ_HONGBAO_GET_REWARDS", 
    -- [58315]领取成功返回 -- 抢红包 
    ACK_HONGBAO_GET_REWARDS_CB       = 58315,[58315] = "ACK_HONGBAO_GET_REWARDS_CB", 
    -- [58330]拥有的红包积分 -- 抢红包 
    ACK_HONGBAO_OWN_JIFEN            = 58330,[58330] = "ACK_HONGBAO_OWN_JIFEN", 

    --------------------------------------------------------
    -- 58401 - 58800 ( 精彩活动转盘 ) 
    --------------------------------------------------------
    -- [58401]请求转盘（放回） -- 精彩活动转盘 
    REQ_ART_ZHUANPAN_REQUEST_UNLIMIT = 58401,[58401] = "REQ_ART_ZHUANPAN_REQUEST_UNLIMIT", 
    -- [58403]请求返回（放回） -- 精彩活动转盘 
    ACK_ART_ZHUANPAN_UNLIMIT_CB      = 58403,[58403] = "ACK_ART_ZHUANPAN_UNLIMIT_CB", 
    -- [58405]抽奖(放回) -- 精彩活动转盘 
    REQ_ART_ZHUANPAN_LOTTERY_UNLIMIT = 58405,[58405] = "REQ_ART_ZHUANPAN_LOTTERY_UNLIMIT", 
    -- [58406]抽奖返回(放回式) -- 精彩活动转盘 
    ACK_ART_ZHUANPAN_UNLOTTERY_CB    = 58406,[58406] = "ACK_ART_ZHUANPAN_UNLOTTERY_CB", 
    -- [58407]抽奖十次(放回) -- 精彩活动转盘 
    REQ_ART_ZHUANPAN_LOTTERY_TEN     = 58407,[58407] = "REQ_ART_ZHUANPAN_LOTTERY_TEN", 
    -- [58408]抽奖十次(放回) -- 精彩活动转盘 
    ACK_ART_ZHUANPAN_TEN_UNLIMIT     = 58408,[58408] = "ACK_ART_ZHUANPAN_TEN_UNLIMIT", 
    -- [58409]信息快 -- 精彩活动转盘 
    ACK_ART_ZHUANPAN_TEN_MSG         = 58409,[58409] = "ACK_ART_ZHUANPAN_TEN_MSG", 
    -- [58410]请求转盘（不放回） -- 精彩活动转盘 
    REQ_ART_ZHUANPAN_REQUEST_LIMIT   = 58410,[58410] = "REQ_ART_ZHUANPAN_REQUEST_LIMIT", 
    -- [58413]请求返回（不放回） -- 精彩活动转盘 
    ACK_ART_ZHUANPAN_LIMIT_CB        = 58413,[58413] = "ACK_ART_ZHUANPAN_LIMIT_CB", 
    -- [58415]信息块 -- 精彩活动转盘 
    ACK_ART_ZHUANPAN_MSG             = 58415,[58415] = "ACK_ART_ZHUANPAN_MSG", 
    -- [58417]抽奖（不放回） -- 精彩活动转盘 
    REQ_ART_ZHUANPAN_LOTTERY_LIMIT   = 58417,[58417] = "REQ_ART_ZHUANPAN_LOTTERY_LIMIT", 
    -- [58420]抽奖返回(不放回式) -- 精彩活动转盘 
    ACK_ART_ZHUANPAN_LOTTERY_CB      = 58420,[58420] = "ACK_ART_ZHUANPAN_LOTTERY_CB", 

    --------------------------------------------------------
    -- 58801 - 59800 ( 侠客行 ) 
    --------------------------------------------------------
    -- [58810]请求侠客行任务数据 -- 侠客行 
    REQ_KNIGHT_REQUEST               = 58810,[58810] = "REQ_KNIGHT_REQUEST", 
    -- [58820]掷骰子任务数据返回 -- 侠客行 
    ACK_KNIGHT_REPLY                 = 58820,[58820] = "ACK_KNIGHT_REPLY", 
    -- [58830]请求掷骰子 -- 侠客行 
    REQ_KNIGHT_DO                    = 58830,[58830] = "REQ_KNIGHT_DO", 
    -- [58840]放弃侠客行任务 -- 侠客行 
    REQ_KNIGHT_DROP                  = 58840,[58840] = "REQ_KNIGHT_DROP", 
    -- [58850]提交侠客行任务 -- 侠客行 
    REQ_KNIGHT_SUBMIT                = 58850,[58850] = "REQ_KNIGHT_SUBMIT", 
    -- [58860]快速完成侠客行任务(vip金元) -- 侠客行 
    REQ_KNIGHT_FAST                  = 58860,[58860] = "REQ_KNIGHT_FAST", 

    --------------------------------------------------------
    -- 59801 - 60800 ( 美人系统 ) 
    --------------------------------------------------------
    -- [59810]请求美人主界面（属性加成） -- 美人系统 
    REQ_MEIREN_REQUEST_MAIN_ATT      = 59810,[59810] = "REQ_MEIREN_REQUEST_MAIN_ATT", 
    -- [59815]美人主界面属性 -- 美人系统 
    ACK_MEIREN_MAIN_ATTR             = 59815,[59815] = "ACK_MEIREN_MAIN_ATTR", 
    -- [59816]更随美人id -- 美人系统 
    ACK_MEIREN_GENSUI_MEIREN         = 59816,[59816] = "ACK_MEIREN_GENSUI_MEIREN", 
    -- [59820]激活的美人id -- 美人系统 
    ACK_MEIREN_MID                   = 59820,[59820] = "ACK_MEIREN_MID", 
    -- [59825]信息块(id) -- 美人系统 
    ACK_MEIREN_MSG_ID                = 59825,[59825] = "ACK_MEIREN_MSG_ID", 
    -- [59830]美人缠绵面板 -- 美人系统 
    REQ_MEIREN_REQUES_LINGERING      = 59830,[59830] = "REQ_MEIREN_REQUES_LINGERING", 
    -- [59840]美人缠绵面板（回） -- 美人系统 
    ACK_MEIREN_LINGERING_CB          = 59840,[59840] = "ACK_MEIREN_LINGERING_CB", 
    -- [59845]各个属性加成比率 -- 美人系统 
    ACK_MEIREN_PERCENT_ATTR          = 59845,[59845] = "ACK_MEIREN_PERCENT_ATTR", 
    -- [59860]缠绵一次 -- 美人系统 
    REQ_MEIREN_LINGERING             = 59860,[59860] = "REQ_MEIREN_LINGERING", 
    -- [59865]缠绵十次 -- 美人系统 
    REQ_MEIREN_LINGERING_TEN         = 59865,[59865] = "REQ_MEIREN_LINGERING_TEN", 
    -- [59870]缠绵回复 -- 美人系统 
    ACK_MEIREN_LINGERING_SUC         = 59870,[59870] = "ACK_MEIREN_LINGERING_SUC", 
    -- [59900]获得美人 -- 美人系统 
    REQ_MEIREN_GET                   = 59900,[59900] = "REQ_MEIREN_GET", 
    -- [59910]获得美人成功 -- 美人系统 
    ACK_MEIREN_GET_SUCCESS           = 59910,[59910] = "ACK_MEIREN_GET_SUCCESS", 
    -- [59920]美人跟随取消 -- 美人系统 
    REQ_MEIREN_FOLLOW                = 59920,[59920] = "REQ_MEIREN_FOLLOW", 
    -- [59925]美人跟随取消成功（回） -- 美人系统 
    ACK_MEIREN_FOLLOW_CB             = 59925,[59925] = "ACK_MEIREN_FOLLOW_CB", 
    -- [59930]请求亲密面板 -- 美人系统 
    REQ_MEIREN_HONEY_REQUEST         = 59930,[59930] = "REQ_MEIREN_HONEY_REQUEST", 
    -- [59935]亲密面板（回） -- 美人系统 
    ACK_MEIREN_HONEY_CB              = 59935,[59935] = "ACK_MEIREN_HONEY_CB", 
    -- [59937]请求美人亲密属性列表 -- 美人系统 
    REQ_MEIREN_ATTR_LIST             = 59937,[59937] = "REQ_MEIREN_ATTR_LIST", 
    -- [59940]亲密属性列表（回） -- 美人系统 
    ACK_MEIREN_HONNEY_LIST           = 59940,[59940] = "ACK_MEIREN_HONNEY_LIST", 
    -- [59945]亲密信息块 -- 美人系统 
    ACK_MEIREN_HONNEY_MSG            = 59945,[59945] = "ACK_MEIREN_HONNEY_MSG", 
    -- [59950]亲密一次 -- 美人系统 
    REQ_MEIREN_ONE_HONEY             = 59950,[59950] = "REQ_MEIREN_ONE_HONEY", 
    -- [59955]亲密十次 -- 美人系统 
    REQ_MEIREN_TEN_HONEY             = 59955,[59955] = "REQ_MEIREN_TEN_HONEY", 
    -- [60000]亲密（回） -- 美人系统 
    ACK_MEIREN_ONE_HONEY_CB          = 60000,[60000] = "ACK_MEIREN_ONE_HONEY_CB", 
    -- [60005]亲密后战力 -- 美人系统 
    ACK_MEIREN_HONEY_POWER           = 60005,[60005] = "ACK_MEIREN_HONEY_POWER", 
    -- [60007]亲密后缠绵面板刷新 -- 美人系统 
    ACK_MEIREN_HONEY_SKID            = 60007,[60007] = "ACK_MEIREN_HONEY_SKID", 

    --------------------------------------------------------
    -- 60801 - 61800 ( 押镖 ) 
    --------------------------------------------------------
    -- [60810]请求押镖信息 -- 押镖 
    REQ_ESCORT_REQUEST               = 60810,[60810] = "REQ_ESCORT_REQUEST", 
    -- [60815]个人护送时间 -- 押镖 
    ACK_ESCORT_TIME                  = 60815,[60815] = "ACK_ESCORT_TIME", 
    -- [60820]护送信息返回 -- 押镖 
    ACK_ESCORT_REPLY                 = 60820,[60820] = "ACK_ESCORT_REPLY", 
    -- [60821]正在押送的镖 -- 押镖 
    ACK_ESCORT_XXX1                  = 60821,[60821] = "ACK_ESCORT_XXX1", 
    -- [60822]所有的人战报 -- 押镖 
    ACK_ESCORT_XXX2                  = 60822,[60822] = "ACK_ESCORT_XXX2", 
    -- [60823]请求可邀请好友面板 -- 押镖 
    REQ_ESCORT_ASK_FRIEND            = 60823,[60823] = "REQ_ESCORT_ASK_FRIEND", 
    -- [60824]可邀请的好友 -- 押镖 
    ACK_ESCORT_FRIEND_DATA           = 60824,[60824] = "ACK_ESCORT_FRIEND_DATA", 
    -- [60825]请求护送面板 -- 押镖 
    REQ_ESCORT_ASK_HU                = 60825,[60825] = "REQ_ESCORT_ASK_HU", 
    -- [60826]护送面板返回 -- 押镖 
    ACK_ESCORT_HUSONG                = 60826,[60826] = "ACK_ESCORT_HUSONG", 
    -- [60828]请求个人战报 -- 押镖 
    REQ_ESCORT_OWN_REW               = 60828,[60828] = "REQ_ESCORT_OWN_REW", 
    -- [60829]个人的战报 -- 押镖 
    ACK_ESCORT_OWN_DATA              = 60829,[60829] = "ACK_ESCORT_OWN_DATA", 
    -- [60830]刷新护送美女 -- 押镖 
    REQ_ESCORT_REFRESH               = 60830,[60830] = "REQ_ESCORT_REFRESH", 
    -- [60835]直接召唤最高级美女 -- 押镖 
    REQ_ESCORT_CALL_MAX              = 60835,[60835] = "REQ_ESCORT_CALL_MAX", 
    -- [60880]开始护送 -- 押镖 
    REQ_ESCORT_BEGIN                 = 60880,[60880] = "REQ_ESCORT_BEGIN", 
    -- [60910]加速护送（直接到终点） -- 押镖 
    REQ_ESCORT_ACCELERATE            = 60910,[60910] = "REQ_ESCORT_ACCELERATE", 
    -- [60915]加速护送返回 -- 押镖 
    ACK_ESCORT_ACCEL_BACK            = 60915,[60915] = "ACK_ESCORT_ACCEL_BACK", 
    -- [60930]打劫 -- 押镖 
    REQ_ESCORT_ROBBERY               = 60930,[60930] = "REQ_ESCORT_ROBBERY", 
    -- [60950]打劫结果 -- 押镖 
    REQ_ESCORT_ROB_OVER              = 60950,[60950] = "REQ_ESCORT_ROB_OVER", 
    -- [60955]打劫结束返回 -- 押镖 
    ACK_ESCORT_OVER_BACK             = 60955,[60955] = "ACK_ESCORT_OVER_BACK", 
    -- [60960]离开面板 -- 押镖 
    REQ_ESCORT_LEAVE                 = 60960,[60960] = "REQ_ESCORT_LEAVE", 

    --------------------------------------------------------
    -- 61801 - 62800 ( 每日抽奖 ) 
    --------------------------------------------------------
    -- [61810]请求抽奖界面 -- 每日抽奖 
    REQ_DRAW_REQUEST                 = 61810,[61810] = "REQ_DRAW_REQUEST", 
    -- [61820]抽奖界面返回 -- 每日抽奖 
    ACK_DRAW_REPLY                   = 61820,[61820] = "ACK_DRAW_REPLY", 
    -- [61830]抽奖 -- 每日抽奖 
    REQ_DRAW_DRAW                    = 61830,[61830] = "REQ_DRAW_DRAW", 

    --------------------------------------------------------
    -- 62801 - 63800 ( 系统拍卖 ) 
    --------------------------------------------------------
    -- [62810]请求竞拍界面 -- 系统拍卖 
    REQ_AUCTION_REQUEST              = 62810,[62810] = "REQ_AUCTION_REQUEST", 
    -- [62820]界面返回 -- 系统拍卖 
    ACK_AUCTION_REPLY                = 62820,[62820] = "ACK_AUCTION_REPLY", 
    -- [62830]竞拍内容信息块 -- 系统拍卖 
    ACK_AUCTION_MSG                  = 62830,[62830] = "ACK_AUCTION_MSG", 
    -- [62840]竞拍一下 -- 系统拍卖 
    REQ_AUCTION_AUCTION              = 62840,[62840] = "REQ_AUCTION_AUCTION", 
    -- [62850]竞拍成功 -- 系统拍卖 
    ACK_AUCTION_SUCCESS              = 62850,[62850] = "ACK_AUCTION_SUCCESS", 

    --------------------------------------------------------
    -- 63801 - 64100 ( 帮派守卫战 ) 
    --------------------------------------------------------
    -- [63803]分配 -- 帮派守卫战 
    REQ_DEFENSE_UPORD                = 63803,[63803] = "REQ_DEFENSE_UPORD", 
    -- [63804]上下阵成功 -- 帮派守卫战 
    ACK_DEFENSE_REPLAY               = 63804,[63804] = "ACK_DEFENSE_REPLAY", 
    -- [63805]玩家位子信息块 -- 帮派守卫战 
    ACK_DEFENSE_USER_SEAT            = 63805,[63805] = "ACK_DEFENSE_USER_SEAT", 
    -- [63806]分组所有信息 -- 帮派守卫战 
    ACK_DEFENSE_ALL_GROUP            = 63806,[63806] = "ACK_DEFENSE_ALL_GROUP", 
    -- [63807]查看分配信息 -- 帮派守卫战 
    REQ_DEFENSE_VIEW                 = 63807,[63807] = "REQ_DEFENSE_VIEW", 
    -- [63808]请求保卫圣兽 -- 帮派守卫战 
    REQ_DEFENSE_BWJM                 = 63808,[63808] = "REQ_DEFENSE_BWJM", 
    -- [63809]界面返回 -- 帮派守卫战 
    ACK_DEFENSE_BWJM_BACK            = 63809,[63809] = "ACK_DEFENSE_BWJM_BACK", 
    -- [63810]请求参加守卫战 -- 帮派守卫战 
    REQ_DEFENSE_REQUEST              = 63810,[63810] = "REQ_DEFENSE_REQUEST", 
    -- [63815]请求地图数据 -- 帮派守卫战 
    REQ_DEFENSE_MAP_DATA             = 63815,[63815] = "REQ_DEFENSE_MAP_DATA", 
    -- [63820]返回地图数据 -- 帮派守卫战 
    ACK_DEFENSE_INTER                = 63820,[63820] = "ACK_DEFENSE_INTER", 
    -- [63830]波次信息 -- 帮派守卫战 
    ACK_DEFENSE_CEN_BO               = 63830,[63830] = "ACK_DEFENSE_CEN_BO", 
    -- [63840]自己当前血量 -- 帮派守卫战 
    ACK_DEFENSE_SELF_HP              = 63840,[63840] = "ACK_DEFENSE_SELF_HP", 
    -- [63890]个人击杀 -- 帮派守卫战 
    ACK_DEFENSE_SELF_KILL            = 63890,[63890] = "ACK_DEFENSE_SELF_KILL", 
    -- [63925]查看战报 -- 帮派守卫战 
    REQ_DEFENSE_PRE_DATA             = 63925,[63925] = "REQ_DEFENSE_PRE_DATA", 
    -- [63930]状态返回 -- 帮派守卫战 
    ACK_DEFENSE_DIED_STATE           = 63930,[63930] = "ACK_DEFENSE_DIED_STATE", 
    -- [63940]战报返回 -- 帮派守卫战 
    ACK_DEFENSE_ZHANBAO              = 63940,[63940] = "ACK_DEFENSE_ZHANBAO", 
    -- [63990]结算 -- 帮派守卫战 
    ACK_DEFENSE_OVER                 = 63990,[63990] = "ACK_DEFENSE_OVER", 
    -- [64000]战斗中信息 -- 帮派守卫战 
    ACK_DEFENSE_COMBAT_INFOR         = 64000,[64000] = "ACK_DEFENSE_COMBAT_INFOR", 
    -- [64010]信息块 -- 帮派守卫战 
    ACK_DEFENSE_XXX                  = 64010,[64010] = "ACK_DEFENSE_XXX", 
    -- [64030]请求复活 -- 帮派守卫战 
    REQ_DEFENSE_RESURREC             = 64030,[64030] = "REQ_DEFENSE_RESURREC", 
    -- [64040]复活成功 -- 帮派守卫战 
    ACK_DEFENSE_RESURREC_OK          = 64040,[64040] = "ACK_DEFENSE_RESURREC_OK", 

    --------------------------------------------------------
    -- 64101 - 64500 ( 占山为王 ) 
    --------------------------------------------------------
    -- [64110]请求活动界面 -- 占山为王 
    REQ_HILL_REQUEST                 = 64110,[64110] = "REQ_HILL_REQUEST", 
    -- [64120]界面返回 -- 占山为王 
    ACK_HILL_REPLAY                  = 64120,[64120] = "ACK_HILL_REPLAY", 
    -- [64130]防守方信息块 -- 占山为王 
    ACK_HILL_FS_DATA                 = 64130,[64130] = "ACK_HILL_FS_DATA", 
    -- [64140]请求排行榜 -- 占山为王 
    REQ_HILL_TOP                     = 64140,[64140] = "REQ_HILL_TOP", 
    -- [64150]帮派/个人排行 -- 占山为王 
    ACK_HILL_CLAN_TOP                = 64150,[64150] = "ACK_HILL_CLAN_TOP", 
    -- [64160]请求战报 -- 占山为王 
    REQ_HILL_REDIO                   = 64160,[64160] = "REQ_HILL_REDIO", 
    -- [64170]战报信息 -- 占山为王 
    ACK_HILL_REDIO_BACK              = 64170,[64170] = "ACK_HILL_REDIO_BACK", 
    -- [64180]战报信息块 -- 占山为王 
    ACK_HILL_REDIO_DATA              = 64180,[64180] = "ACK_HILL_REDIO_DATA", 
    -- [64185]cd冷却中 -- 占山为王 
    ACK_HILL_CD_SEC                  = 64185,[64185] = "ACK_HILL_CD_SEC", 
    -- [64190]挑战 -- 占山为王 
    REQ_HILL_BATTLE                  = 64190,[64190] = "REQ_HILL_BATTLE", 
    -- [64195]请求个人加成 -- 占山为王 
    REQ_HILL_ASK_ADD                 = 64195,[64195] = "REQ_HILL_ASK_ADD", 
    -- [64200]挑战结束 -- 占山为王 
    REQ_HILL_FINISH                  = 64200,[64200] = "REQ_HILL_FINISH", 
    -- [64205]挑战结果 -- 占山为王 
    ACK_HILL_FINISH_BACK             = 64205,[64205] = "ACK_HILL_FINISH_BACK", 
    -- [64210]清除cd -- 占山为王 
    REQ_HILL_CLEAN                   = 64210,[64210] = "REQ_HILL_CLEAN", 
    -- [64220]清除成功 -- 占山为王 
    ACK_HILL_CLEAN_OK                = 64220,[64220] = "ACK_HILL_CLEAN_OK", 

    --------------------------------------------------------
    -- 64801 - 65300 ( 挑战迷宫 ) 
    --------------------------------------------------------
    -- [64810]请求进入迷宫 -- 挑战迷宫 
    REQ_MAZE_REQUEST                 = 64810,[64810] = "REQ_MAZE_REQUEST", 
    -- [64820]迷宫界面返回 -- 挑战迷宫 
    ACK_MAZE_REPLY                   = 64820,[64820] = "ACK_MAZE_REPLY", 
    -- [64850]请求打开兑换商店 -- 挑战迷宫 
    REQ_MAZE_SHOP_REQUEST            = 64850,[64850] = "REQ_MAZE_SHOP_REQUEST", 
    -- [64860]兑换面板返回 -- 挑战迷宫 
    ACK_MAZE_SHOP_REPLY              = 64860,[64860] = "ACK_MAZE_SHOP_REPLY", 
    -- [64870]物品数据块 -- 挑战迷宫 
    ACK_MAZE_GOODS_XXX               = 64870,[64870] = "ACK_MAZE_GOODS_XXX", 
    -- [64880]开始探险 -- 挑战迷宫 
    REQ_MAZE_START                   = 64880,[64880] = "REQ_MAZE_START", 
    -- [64890]探险结束 -- 挑战迷宫 
    ACK_MAZE_OVER_BACK               = 64890,[64890] = "ACK_MAZE_OVER_BACK", 
    -- [64900]兑换物品 -- 挑战迷宫 
    REQ_MAZE_EXCHANGE                = 64900,[64900] = "REQ_MAZE_EXCHANGE", 
    -- [64910]兑换成功返回 -- 挑战迷宫 
    ACK_MAZE_EXCHANGE_BACK           = 64910,[64910] = "ACK_MAZE_EXCHANGE_BACK", 
    -- [65090]打开探险包裹 -- 挑战迷宫 
    REQ_MAZE_OPEN_BAG                = 65090,[65090] = "REQ_MAZE_OPEN_BAG", 
    -- [65100]探险包裹 -- 挑战迷宫 
    ACK_MAZE_BAG_BACK                = 65100,[65100] = "ACK_MAZE_BAG_BACK", 
    -- [65150]一键入包 -- 挑战迷宫 
    REQ_MAZE_PECK_UP                 = 65150,[65150] = "REQ_MAZE_PECK_UP", 
    -- [65160]入包成功 -- 挑战迷宫 
    ACK_MAZE_PECK_BACK               = 65160,[65160] = "ACK_MAZE_PECK_BACK", 

    --------------------------------------------------------
    -- 65301 - 65535 ( 秘宝活动 ) 
    --------------------------------------------------------
    -- [65310]请求秘宝活动界面 -- 秘宝活动 
    REQ_MIBAO_REQUEST                = 65310,[65310] = "REQ_MIBAO_REQUEST", 
    -- [65315]秘宝活动界面返回 -- 秘宝活动 
    ACK_MIBAO_REPLY                  = 65315,[65315] = "ACK_MIBAO_REPLY", 
    -- [65320]秘宝活动界面信息块 -- 秘宝活动 
    ACK_MIBAO_REPLY_DATA             = 65320,[65320] = "ACK_MIBAO_REPLY_DATA", 
    -- [65330]请求进入秘宝活动场景 -- 秘宝活动 
    REQ_MIBAO_ENTER                  = 65330,[65330] = "REQ_MIBAO_ENTER", 
    -- [65340]战斗击打箱子 -- 秘宝活动 
    REQ_MIBAO_BOX_HARM               = 65340,[65340] = "REQ_MIBAO_BOX_HARM", 
    -- [65345]箱子请求 -- 秘宝活动 
    REQ_MIBAO_BOX_REQUEST            = 65345,[65345] = "REQ_MIBAO_BOX_REQUEST", 
    -- [65350]箱子返回 -- 秘宝活动 
    ACK_MIBAO_BOX_REPLY              = 65350,[65350] = "ACK_MIBAO_BOX_REPLY", 
    -- [65355]箱子信息块 -- 秘宝活动 
    ACK_MIBAO_BOX_DATA               = 65355,[65355] = "ACK_MIBAO_BOX_DATA", 
    -- [65360]箱子消失 -- 秘宝活动 
    ACK_MIBAO_BOX_DISAPPEAR          = 65360,[65360] = "ACK_MIBAO_BOX_DISAPPEAR", 
    -- [65365]物品信息块 -- 秘宝活动 
    ACK_MIBAO_GOODS_LIST             = 65365,[65365] = "ACK_MIBAO_GOODS_LIST", 
    -- [65370]所有物品掉落信息 -- 秘宝活动 
    ACK_MIBAO_GOODS_ALL              = 65370,[65370] = "ACK_MIBAO_GOODS_ALL", 
    -- [65375]捡物品 -- 秘宝活动 
    REQ_MIBAO_GOODS_GET              = 65375,[65375] = "REQ_MIBAO_GOODS_GET", 
    -- [65380]物品消失 -- 秘宝活动 
    ACK_MIBAO_GOODS_DISAPPEAR        = 65380,[65380] = "ACK_MIBAO_GOODS_DISAPPEAR", 
    -- [65385]玩家当前血量 -- 秘宝活动 
    ACK_MIBAO_PLAYER_HP              = 65385,[65385] = "ACK_MIBAO_PLAYER_HP", 
    -- [65390]玩家死亡 -- 秘宝活动 
    ACK_MIBAO_PLAYER_DIE             = 65390,[65390] = "ACK_MIBAO_PLAYER_DIE", 
    -- [65400]玩家请求复活 -- 秘宝活动 
    REQ_MIBAO_REVIVE                 = 65400,[65400] = "REQ_MIBAO_REVIVE", 
    -- [65405]玩家复活返回 -- 秘宝活动 
    ACK_MIBAO_REVIVE_REPLY           = 65405,[65405] = "ACK_MIBAO_REVIVE_REPLY", 
    -- [65410]下一次箱子刷新时间 -- 秘宝活动 
    ACK_MIBAO_BOX_REFRESH_TIME       = 65410,[65410] = "ACK_MIBAO_BOX_REFRESH_TIME", 
    -- [65415]进入秘宝界面-完成任务指引 -- 秘宝活动 
    REQ_MIBAO_TASK_FINISH            = 65415,[65415] = "REQ_MIBAO_TASK_FINISH", 

    --------------------------------------------------------
    -- 65535 - 65535 ( ? ) 
    --------------------------------------------------------
    --/** =============================== 自动生成的代码 =============================== **/
    --/*************************** don't touch this line *********** AUTO_CODE_END_Protocol **/
}
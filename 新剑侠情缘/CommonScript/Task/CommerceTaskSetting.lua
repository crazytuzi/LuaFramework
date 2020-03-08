CommerceTask.tbCommerceNpc = { [10] = {nNpc = 190, nRandom = 200000}, [15] = {nNpc = 190, nRandom = 800000} };

CommerceTask.COMMERCE_TASK_REFRESH = 4 * 3600;  --凌晨4点刷新
CommerceTask.MAX_REPEAT  = 1; 					--任务重复次数
CommerceTask.START_LEVEL = 30; 					--开启等级

CommerceTask.MAX_HELP_COUNT = 3;-- 求助次数

CommerceTask.POOL_COUNT1 = 7;
CommerceTask.POOL_COUNT2 = 2;
CommerceTask.POOL_COUNT3 = 1;

CommerceTask.COMPLETE_COUNT = 6
CommerceTask.ALL_COMPLETE_COUNT = 10

CommerceTask.BASIC_AWARD        = {"Item", 786, 2} --基础奖励
CommerceTask.ADDITION_AWARD     = {"Item", 2266, 1} --附加奖励
CommerceTask.BASIC_MONEY_TYPE   = "Coin"
CommerceTask.BASIC_MONEY_NUM    = 1000  --收集1个后的奖励
CommerceTask.BASIC_EXP_AWARD    = 6

CommerceTask.ALL_COMPLETE_AWARD_B60 = {"Item", 3013, 10}--全部完成的奖励道具ID，小于60级  --黄金宝箱
CommerceTask.ALL_COMPLETE_AWARD_A60 = {"Item", 3013, 10}--全部完成的奖励道具ID，大于等于60级

CommerceTask.tbWildMap = {400, 401, 402, 403, 404, 405, 406, 407, 408, 409};


CommerceTask.tbVipHelpTimes = {
    {0, 10},
    {2, 20},
}

CommerceTask.szNotAllCompleteMsg = "您还有尚未装满的箱子，确定要完成任务吗？（装满所有箱子可以获得更多的奖励）"

CommerceTask.nHelpTimesVipLv = 5 --达到该vip等级可以多一次求助次数
CommerceTask.tbHelpAsynDataKey = { --与c代码里一致
--emASYNC_VALUE_COMMERCE_BEGIN
--emASYNC_VALUE_COMMERCE_HELP
--emASYNC_VALUE_COMMERCE_END
    {25, 28},
    {26, 29},
    {27, 30},
--emASYNC_VALUE_COMMERCE_4_ID
--emASYNC_VALUE_COMMERCE_4_STATE
    {61, 62},
}
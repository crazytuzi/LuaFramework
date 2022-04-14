--
-- @Author: LaoY
-- @Date:   2019-01-05 16:57:34
--

OperateEvent = {
    REQ_PROTO = "OperateEvent.REQ_PROTO", --请求协议


    UPDATE_INFO = "OperateEvent.UPDATE_INFO", --刷新信息

    UPDATEREDDOT = "OperateEvent.UPDATEREDDOT", --刷新红点;参数:主界面图标key，活动id，红点参数

    ACT_RECEIVE_FIN = "OperateEvent.ACT_RECEIVE_FIN", --活动列表接收后,
    ACT_START = 'OperateEvent.ACT_START', --广播活动开始事件

    REQUEST_GET_YY_INFO = "OperateEvent.REQUEST_GET_YY_INFO", --请求运营信息
    DLIVER_YY_INFO = "OperateEvent.DLIVER_YY_INFO", --派发运营信息事件

    REQUEST_YY_LOG = "OperateEvent.REQUEST_YY_LOG", --申请运管活动日志、记录
    DELIVER_YY_LOG = "OperateEvent.DELIVER_YY_LOG", --广播活动日志
    UPDATE_YY_LOG = "OperateEvent.UPDATE_YY_LOG", --活动日志更新

    REQUEST_GET_REWARD = "OperateEvent.REQUEST_GET_REWARD", --请求获取奖励
    SUCCESS_GET_REWARD = "OperateEvent.SUCCESS_GET_REWARD", --获取奖励成功广播

    --0元礼包
    REQUEST_FREE_GIFT_INFO = "OperateEvent.REQUEST_FREE_GIFT_INFO", --请求获取0元礼包活动信息
    DILIVER_FREE_GIFT_INFO = "OperateEvent.DILIVER_FREE_GIFT_INFO", --广播白给礼包活动信息

    REQUEST_FREE_GIFT_REWARD_FETCH = "OperateEvent.REQUEST_FREE_GIFT_REWARD_FETCH", --请求获取0元礼包的奖励获取
    DILIVER_FREE_GIFT_REWARD_FETCH = "OperateEvent.DILIVER_FREE_GIFT_REWARD_FETCH", --广播白给礼包的奖励获取

    --砸蛋
    REQUEST_LOTTERY_INFO = "OperateEvent.REQUEST_LOTTERY_INFO", --请求砸蛋信息
    DILIVER_LOTTERY_INFO = "OperateEvent.DILIVER_LOTTERY_INFO", --广播砸蛋info
    --砸开
    REQUEST_CRACK_EGG = "OperateEvent,REQUEST_CRACK_EGG", --请求砸蛋
    SUCCESS_CRACK_EGG = "OperateEvent.SUCCESS_CRACK_EGG", --成功砸开
    --刷新
    REQUEST_REFRESH_EGG = "OperateEvent.REQUEST_REFRESH_EGG", --刷新蛋池
    HANDLE_REFRESH_EGG = "OperateEvent.HANDLE_REFRESH_EGG", --刷新蛋池通知

    ---节日活动，烟火抽奖
    REQUEST_FIRE = "OperateEvent.REQUEST_FIRE", --申请抽奖
    SUCCESS_FIRE = "OperateEvent.SUCCESS_FIRE", --抽奖返回

    ---运营活动转盘
    REQUEST_D_INFO = "OperateEvent.REQUEST_DIAL_INFO", --转盘数据
    DILIVER_D_INFO = "OperateEvent.DILIVER_D_INFO",
    REQ_D_TURN = "OperateEvent.REQUEST_DIAL_TURN", --请求开转
    DILIVER_TURN_RESULT = "OperateEvent.DILIVER_TURN_RESULT",
    UPDATE_D_PRO = "OperateEvent.UPDATE_Dial_PROGRESS", --更新进度值

    ---跨服云购
    REQUEST_SHOP_BOUGHT_RECO = "OperateEvent.REQUEST_SHOP_BOUGHT_RECO", --请求跨服云购记录
    DILIVER_SHOP_BOUGHT_RECO = "OperateEvent.DILIVER_SHOP_BOUGHT_RECO", --广播跨服云购记录
    REQUEST_SHOP_INFO = "OperateEvent.REQUEST_SHOP_INFO", --云购info
    DILIVER_SHOP_INFO = "OperateEvent.DILIVER_SHOP_INFO",
    REQUEST_SHOP_BUY = "OperateEvent.RequestShopBuy", --购买
    DILIVER_BUY_RESULT = "OperateEvent.DiliverBuyResult",
}
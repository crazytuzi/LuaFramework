
-- 随机种子初始化
math.randomseed(os.time())

-- 调试模式
DEBUG_MODE = DEBUG_MODE or false

TRUE = 1
FALSE = 0

-- 禁止低功耗释放资源
DISABLE_LOWPOWER_FREE = false
-- 是否有用户中心，目前改为切换账号
HAS_USER_CENTER = true

-- 低功耗误操无超时
LOW_PERFORMANCE_TIMEOUT = 300

IS_SHOW_VOICE = true -- 显示语音

IS_TEST_SERVER = PLATFORM_NAME == "demo"

-- 当前帧频
FPS_RATE = 1

--资源图片加载的类型(分为本地和plist)
LOADTEXT_TYPE = ccui.TextureResType.localType

LOADTEXT_TYPE_PLIST = ccui.TextureResType.plistType

--创建场景对象的频率
ADD_OBJ_RATE = 15

--销毁场景玩家的频率
DEL_PLAYER_RATE = 25

--重连间隔事件
RECONNEST_INTERVAL = 5

 
--- sdk 文件
local SDK_91 = "sdk_91"
local sdk_pp = "sdk_pp"

PLATFORM_OS_WINDOWS  = 0
PLATFORM_OS_IOS  = 1
PLATFORM_OS_ANDROID  = 2

-------------------------------------------------------------------
local curSkd = SDK_91
G_platform = PLATFORM_OS_IOS
-------------------------------------------------------------------

G_SDK =  include(curSkd).new()

function sdk_InitPlatfromSdk()
	G_SDK:Init()
end	



--- 有的平台要求暂停游戏 调用平台api
function sdk_pauseGame()
	G_SDK:pauseGame()
end	

function sdk_loginCallBack()
	--- game connect
	--- 连接游戏服务器
end

--调用不同平台的登录 --（ios和android）交予各平台api去实现
function sdk_loginPressDown()
	G_SDK:loginCallBack()
end

---平台中心 进去用户中心
function sdk_platfromCenterPressDown()
	G_SDK:CenterPressDown()
end

---购买钻石 --调用各平台api发起支付
function sdk_buyGold(price,name,roleid,zone,biilNo)
	G_SDK:buyGold(price,name,roleid ,zone,biilNo)
end

--//离开平台
function sdk_SNSleavePlatform()
	G_SDK:SNSleavePlatform()
end





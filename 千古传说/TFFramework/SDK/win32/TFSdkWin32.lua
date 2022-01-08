local TFSdkWin32 = {}
TFSdkWin32.serverToken     = "" -- [string]校验服务器返回的token
TFSdkWin32.platformToken   = "" -- [string]渠道登录时返回的token
TFSdkWin32.uId             = "" -- [string]第三方渠道用户ID
TFSdkWin32.uName           = "" -- [string]第三方渠道用户昵称
TFSdkWin32.initPlatformCallBack = nil --[function]初始化sdk完成回调
TFSdkWin32.loginInCallBack  = nil --[function]登陆结果回调
TFSdkWin32.loginOutCallBack = nil --[function]登出回调
TFSdkWin32.payForProductCallBack = nil --[function]支付回调
TFSdkWin32.leavePlatCallBack = nil  --[function] 离开平台回调
TFSdkWin32.initTab = nil        --[table] init需要的参数配置表
TFSdkWin32.payTab  = nil        --[table] payForProduct需要的参数配置表
TFSdkWin32.bHasInited = false     --[bool] 是否初始化过
TFSdkWin32.bHasLoginIn = false    --[bool] 是否已经登录了sdk
TFSdkWin32.SERVER_CHECK_URL = "serverCheckURL" --用于提交到校验服务器校验sdk登录的有效性

--pay
TFSdkWin32.PAYRESULT_MSG ="resultMsg";   -- // 支付回调消息
TFSdkWin32.PAY_CODE  ="action"        --//支付回调状态码

TFSdkWin32.TOTAL_PRICES="totalPrices";    --商品价格(一般为总价)
TFSdkWin32.ORDER_NO ="orderNo";              --订单号
TFSdkWin32.ORDER_TITLE  ="orderTitle";         --订单名
TFSdkWin32.PAY_DESCRIPTION="payDescription";  --描述信息 
TFSdkWin32.PRODUCT_ID = "productId";  	--商品id
TFSdkWin32.PRODUCT_NAME  ="productName"; 	--商品名称
TFSdkWin32.PRODUCT_COUNT  ="productCount"; 	--商品数量
TFSdkWin32.USER_BALANCE   ="userBalance";	--用户余额
--role
TFSdkWin32.ROLE_ID="roleId";  		--角色id
TFSdkWin32.ROLE_NAME ="roleName"; 	--角色名称
TFSdkWin32.SERVER_ID ="serverId"; 		--区服id
TFSdkWin32.SERVER_NAME  ="serverName";	--区服名称
TFSdkWin32.ROLE_LEVEL ="roleLevel"; 	--角色等级
TFSdkWin32.VIP_LEVEL  ="vipLevel";		--vip等级
TFSdkWin32.PARTY_NAME="partyName";  	--工会名(帮派)
TFSdkWin32.GOOD_REGISTID= "goodRegistId";  	--注册商品id (畅游)

--- produceList const
TFSdkWin32.PRODUCT_LIST="productList";  --商品列表

function TFSdkWin32:init(callback)
end

function TFSdkWin32:login(callback)
end

function TFSdkWin32:payForProduct(productTab,callback)

end

function TFSdkWin32:switchAccount(callback)

end

function TFSdkWin32:enterPlatform()
  
end

function TFSdkWin32:setLoginInCallBack(callback)
    
end

function TFSdkWin32:setLoginOutCallBack(callback)
    
end

function TFSdkWin32:setLeavePlatCallBack(callback)
    
end

function TFSdkWin32:setAppID(szAppID)
    
end

function TFSdkWin32:setSdkName(szName)
   
end

function TFSdkWin32:setPlatformToken(szToken)
    
end

function TFSdkWin32:setUserID(szID)
 
end

function TFSdkWin32:setUserName(szName)
 
end

function TFSdkWin32:getSdkName()
end

function TFSdkWin32:getPlatformToken()
end

function TFSdkWin32:getUserID()
end

function TFSdkWin32:getUserName()
end

function TFSdkWin32:getCheckServerToken()
end


return TFSdkWin32


 --[[
 --
 -- @authors shan 
 -- @date    2014-11-16 11:38:29
 -- @version 
 --
 --]]


local SDKTkData = {}

local SDK_GLOBAL_NAME = "sdk.SDKTkData"
local SDK_CLASS_NAME = "SDKTkData"


if(device.platform == "android") then
	SDK_CLASS_NAME = "com/douzi/common/SDKTkData"
end

local sdk = "".. SDK_GLOBAL_NAME --cc.PACKAGE_NAME[SDK_GLOBAL_NAME]

SDKTkData.m_tkID = ""

--[[==================================]]

--[[

	appID
	channelID
]]	
function SDKTkData.onStart( )
	if(device.platform == "ios") then

		local appID = "06D7C9E06577F2D9B1EF89D545927AA3"
		local channelID = CSDKShell.getChannelID()

		SDKTkData.m_tkID = appID

		local args = {appID = appID, channelID = channelID}
		luaoc.callStaticMethod(SDK_CLASS_NAME, "onStart", args)

	elseif(device.platform == "android") then

		local appID = "FF76F0E90E523B49576AB2E91A460BAB"
		local channelID = tostring(CSDKShell.getChannelID())

		SDKTkData.m_tkID = appID

		local args = { appID, channelID }
		luaj.callStaticMethod(SDK_CLASS_NAME, "onStart", args, "(Ljava/lang/String;Ljava/lang/String;)V")

	end
end

--[[

]]
function SDKTkData.getTkID()
	return SDKTkData.m_tkID
end
--[[--

	设置基本信息
	/***
	@param accountId
    @param accountName
    @param level
    @param gameServer
 */
01-08 21:16:59.166: D/cocos2d-x debug info(30344): [16.0309] -     "accountId"   = "bai__2506046337"
01-08 21:16:59.166: D/cocos2d-x debug info(30344): [16.0311] -     "accountName" = "翠容雨澄"
01-08 21:16:59.166: D/cocos2d-x debug info(30344): [16.0312] -     "gameServer"  = "WebSystem"
01-08 21:16:59.166: D/cocos2d-x debug info(30344): [16.0313] -     "level"       = 3

]]
function SDKTkData.setBaseInfo(param)
	if(device.platform == "ios") then
		local args = param
		luaoc.callStaticMethod(SDK_CLASS_NAME, "setBaseInfo", args)
	elseif(device.platform == "android") then		
		local args = {param.accountId, param.accountName, param.level, param.gameServer}
		dump(args)
		luaj.callStaticMethod(SDK_CLASS_NAME, "setBaseInfo", args, "(Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;)V")
	end
end


--[[

	充值请求
	/**
 *	@method	onChargeRequst          虚拟币充值请求
 *	
 *	@param 	orderId                 订单id        类型:NSString
 *	@param 	iapId                   充值包id      类型:NSString
 *	@param 	currencyAmount          现金金额      类型:double
 *	@param 	currencyType            币种          类型:NSString
 *	@param 	virtualCurrencyAmount   虚拟币金额    类型:double
 *	@param 	paymentType             支付类型      类型:NSString
 */
]]
function SDKTkData.onChargeRequest( param )
	if(device.platform == "ios") then
		local args = param
		luaoc.callStaticMethod(SDK_CLASS_NAME, "onChargeRequest", args)
	elseif(device.platform == "android") then
		local args = {param.orderId, param.iapId, param.currencyAmount, param.currencyType, param.virtualCurrencyAmount, param.paymentType}		
		luaj.callStaticMethod(SDK_CLASS_NAME, "onChargeRequest", args, "(Ljava/lang/String;Ljava/lang/String;DLjava/lang/String;DLjava/lang/String;)V")
end
end


--[[
	充值成功
	/**
 *	@method	onChargeRequst          虚拟币充值请求
 *	@param 	orderId                 订单id        类型:NSString
 */
]]
function SDKTkData.onChargeSuccess( param )
	if(device.platform == "ios") then
		local args = param
		luaoc.callStaticMethod(SDK_CLASS_NAME, "onChargeSuccess", args)
	elseif(device.platform == "android") then
		local args = {param.orderId}
		luaj.callStaticMethod(SDK_CLASS_NAME, "onChargeSuccess", args, "(Ljava/lang/String;)V")
	end
end

--[[
	@param level
]]
function SDKTkData.setLevel( param)
	if(device.platform == "ios") then		
		local args = {level=param.level}
		luaoc.callStaticMethod(SDK_CLASS_NAME, "setLevel", args)
	elseif(device.platform == "android") then
		local args = {param.level}
		luaj.callStaticMethod(SDK_CLASS_NAME, "setLevel", args, "(I)V")
	end
end

return SDKTkData

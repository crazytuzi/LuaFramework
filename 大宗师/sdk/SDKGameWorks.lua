
local SDKGameWorks = {}

local SDK_GLOBAL_NAME = "sdk.SDKGameWorks"
local SDK_CLASS_NAME = "SDKGameWorks"

local sdk = "".. SDK_GLOBAL_NAME --cc.PACKAGE_NAME[SDK_GLOBAL_NAME]




local GameKey = "07ad0b5016db43da888e5dd8d6e1140a"
local ChannelID = CSDKShell.getChannelID() 
local platform = "ios"
local serverUrl = "http://dataapi.mobile.youxigongchang.com"

--[[--

初始化

初始化完成后，可以使用：

]]
function SDKGameWorks.InitGameWorks()
	if( ENABLE_GAME_WORKS == true) then
		if(device.platform == "ios") then 
			ChannelID = CSDKShell.getChannelID()
			printf(GameKey .. "," .. ChannelID)
		    local args = { GameKey = GameKey, ChannelID = ChannelID, platform = platform, serverUrl=serverUrl}

		    luaoc.callStaticMethod(SDK_CLASS_NAME, "InitGameWorks", args)
		end
	end
end



function SDKGameWorks.Login( userID, userType, serverno )
	if( ENABLE_GAME_WORKS == true) then
	    if(device.platform == "ios") then
		    local args = {userID = userID, userType = userType, serverno = serverno}
		    dump(args)
		    luaoc.callStaticMethod(SDK_CLASS_NAME, "Login", args)
		end
	end
end


function SDKGameWorks.CreateRole( user, serverno, rolemark )
	if( ENABLE_GAME_WORKS == true) then
	    if(device.platform == "ios") then
		    local args = {user = user, serverno = serverno, rolemark = user}
		    dump(args)
		    luaoc.callStaticMethod(SDK_CLASS_NAME, "CreateRole", args)
		end
	end
end


function SDKGameWorks.GameUpGrade( _grade, user, serverno, rolemark )
	if( ENABLE_GAME_WORKS == true) then
		if(device.platform == "ios") then
		    local args = {grade = _grade, user = user, serverno=serverno, rolemark = user}
		    dump(args)
		    luaoc.callStaticMethod(SDK_CLASS_NAME, "GameUpGrade", args)
		end
	end
end


function SDKGameWorks.GameBtClick( btnName )
	if( ENABLE_GAME_WORKS == true) then
		if(device.platform == "ios") then
		    local args = {name = btnName}
		    luaoc.callStaticMethod(SDK_CLASS_NAME, "GameBtClick", args)
		end
	end
end

--[[
/**
 *  提交订单
 *
 *  @param payname     payname 支付方式 必填
 *  @param amount      amount 金额 必填
 *  @param user        user 唯一标示一个用户 必填
 *  @param serverno    单机可选 网游必填 传入区服编号 默认使用最近一次的区服编号值
 *  @param ordernumber ordernumber 订单号 必填
 *  @param grade       单机可选 网游必填 当前等级
 *  @param productdesc productdesc 商品描述 选填
 *  @param rolemark    单机可选 网游必填 传入角色标识
 */

	接入点：购买成功后/支付成功后， 该选项接入点请一定要注意
	统计：游戏的收入信息，DAU， MDAY, WDAY等
]]
function SDKGameWorks.gameSubmitOrder( param )
	if( ENABLE_GAME_WORKS == true) then
		if(device.platform == "ios") then
		    local args = param
		    luaoc.callStaticMethod(SDK_CLASS_NAME, "gameSubmitOrder", args)
		end
	end
end

return SDKGameWorks

-- Filename: UserHandler.lua
-- Author: fang
-- Date: 2013-05-30
-- Purpose: 该文件用于登录数据模型

require "script/network/Network"
require "script/utils/LuaUtil"
--require "script/ui/login/LoginScene"
require "script/ui/create_user/UserLayer"
require "script/ui/main/MainScene"


module ("UserHandler", package.seeall)



isNewUser = false

local _loginInfo = nil

-- 玩家登录到游戏服务器
function login(cbName, dictData, bRet)
	if (cbName ~= "user.login") then
		return
	end
	if (bRet) then
		_loginInfo = dictData.ret
		-- if (dictData.ret == "ok") then
			Network.rpc(fnGetUsers, "user.getUsers", "user.getUsers", nil, true)
		-- end
	end
end

-- 是否有vip继承的相关信息
function hasVip()
	local isOpen = false
	local vipLv = 0
	if( table.isEmpty(_loginInfo) ==false )then
		if(_loginInfo.worldVip and (_loginInfo.worldVip == true or _loginInfo.worldVip == "true" ) ) then
			isOpen = true
			vipLv =  tonumber(_loginInfo.createVip)
		end
	end
	return isOpen, vipLv
end

-- 得到玩家所有的用户（支持一个帐户有多个角色）
function fnGetUsers(cbName, dictData, bRet)
	if (bRet) then
		local ret = dictData.ret

		if (#ret > 0) then
			local dictUserInfo = ret[1]
			local ccsUid = dictUserInfo.uid

			-- local pos, stop = string.find(dictUserInfo.uname, " ")
			-- if(pos == 1)then
			-- 	local b_64str = string.gsub(dictUserInfo.uname, " ", "")
			-- 	dictUserInfo.uname = CCCrypto:decodeBase64(b_64str)
			-- end

			local args = CCArray:createWithObject(CCString:create(ccsUid) )
            Network.rpc(fnUserLogin,"user.userLogin", "user.userLogin", args, true) 
        else
        	isNewUser = true
		    local userLayer = UserLayer.createUserLayer()
		    local scene = CCScene:create()
		    scene:addChild(userLayer)
		    CCDirector:sharedDirector():replaceScene(scene)
       end
    end
end

-- 使用uid用户进入游戏
function fnUserLogin(cbName, dictData, bRet)
    if (bRet) then
    	local ret = dictData.ret
    	if(false)then
    		-- 预留
			MainScene.loadOther()
			require "script/ui/shop/RechargeLayer"
			-- require "script/model/user/UserModel"
			RechargeLayer.showLayer( nil, nil, true )
			return
		end
  		if (ret == "ok") then
			require "script/network/RequestCenter"
            RequestCenter.user_getUser(fnGetUser, nil)
    	elseif ret.ret == "timeout" then
			require "script/ui/login/LoginScene"
			LoginScene.fnServerIsTimeout()
		elseif ret.ret == "full" then
			require "script/ui/login/LoginScene"
			LoginScene.fnServerIsFull()
		elseif ret.ret == "ban" then
			require "script/ui/login/LoginScene"
			LoginScene.fnIsBanned(ret.info)
		end
    end
end

-- 得到用户信息
function fnGetUser(cbName, dictData, bRet)
	if (bRet) then
		require "script/model/user/UserModel"

		local b_userinfo = dictData.ret
		local pos, stop = string.find(b_userinfo.uname, " ")
		if(pos ~= nil and pos == 1)then
			local b_64str = string.gsub(b_userinfo.uname, " ", "")
			if g_system_type == kBT_PLATFORM_IOS or g_system_type == kBT_PLATFORM_ANDROID then
				b_userinfo.uname = Base64.decode(b_64str)
			else
				b_userinfo.uname = CCCrypto:decodeBase64(b_64str)
			end
		end

		UserModel.setUserInfo(b_userinfo)
		if(isNewUser)then
			--通知Platform层创建新角色成功(并且能够得到roleId和roleName)
			Platform.sendInformationToPlatform(Platform.kCreateNewRole)
		end
		require "script/ui/login/LoginScene"
		LoginScene.setUserInfo (b_userinfo)
	end
end

function createUser( ... )
	-- body
end

local _bIsLoginStatus=false
function fnIsLoginStatus(rpcName)
	if rpcName == "user.login" then
		_bIsLoginStatus = true
	elseif rpcName=="user.getUser" then
		
	elseif _bIsLoginStatus and string.find(rpcName, "user") == 1 then
		return false
	elseif _bIsLoginStatus then
		return true
	end

	return false
end

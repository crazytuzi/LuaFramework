-- FileName: CountryWarController.lua 
-- Author: licong 
-- Date: 15/12/12 
-- Purpose: 国战战场控制器 


module("CountryWarController", package.seeall)

require "script/ui/countryWar/war/CountryWarPlaceData"
require "script/ui/countryWar/war/CountryWarPlaceService"
require "script/ui/countryWar/signUp/CountryWarSignData"

local _isSend = false

--[[
	@des 	: 1.进入战场
	@param 	:
	@return :
--]]
function enterWarPlace( p_callBack )
	local getLoginInfoCallFun = function ( p_loginInfo )

		if(p_loginInfo.ret == "ok")then
			_isSend = true
			-- 设置用户uuid
			CountryWarPlaceData.setUserUuid( p_loginInfo.uuid )

			-- 建立国战Socket
			performCallfunc(function ( ... )

				local isOk = Network.connectCountrySocket( p_loginInfo.serverIp, p_loginInfo.port )
				if(isOk)then
					-- 连接跨服服务器
					loginCross( p_loginInfo, p_callBack )
				else
					print("erro connectCountrySocket failed !!!")
				end
				_isSend = false

			end, 0.1)
		elseif(p_loginInfo.ret == "fail")then
			AnimationTip.showTip("fail")
		elseif(p_loginInfo.ret == "expired")then
			AnimationTip.showTip(GetLocalizeStringBy("lic_1765"))
		elseif(p_loginInfo.ret == "errtime")then
			AnimationTip.showTip("errtime")
		else
			print("erro getLoginInfo!")
		end
	end

	-- 检查国战socket
	local isConnect = Network.isSocketConnectedBy(Network.kSOCKET_TYPE_COUNTRY)
	local isLogin = CountryWarPlaceData.isLoginCrossOK()
	if( isConnect and isLogin)then
		-- 已连接直接enter
		enter( p_callBack )
	else
		-- 注销登陆
		logoutCross()

		if(_isSend == true) then
			return
		end
		-- 没有登录先登录跨服
		CountryWarPlaceService.getLoginInfo(getLoginInfoCallFun)
	end
end

--[[
	@des 	: 2.登陆到跨服接口
	@param 	:
	@return :
--]]
function loginCross( p_loginInfo, p_callBack )
	local loginCrossCallFun = function ( p_loginCrossInfo )
		-- 缓存登陆信息
		CountryWarPlaceData.setLoginCrossData( p_loginCrossInfo )
		-- 是否登陆成功
		local isLogin = CountryWarPlaceData.isLoginCrossOK()
		if( isLogin )then
			-- enter
			enter( p_callBack )
		else
			--关闭国战socket
			if Network.isSocketConnectedBy(Network.kSOCKET_TYPE_COUNTRY) then
				Network.closeSocketBy(Network.kSOCKET_TYPE_COUNTRY)
			end
		end
	end
	-- 2.登陆到跨服接口
	local serverId = UserModel.getServerId()
	local pid = UserModel.getPid()
	CountryWarPlaceService.loginCross(serverId,pid,p_loginInfo.token,loginCrossCallFun)
end

--[[
	@des 	: 3.enter接口
	@param 	:
	@return :
--]]
function enter( p_callBack )
	-- 我报名的国家
	local myCountryId = CountryWarSignData.getSignedCountryID()
	if(myCountryId == nil)then
		require "script/ui/countryWar/signUp/CountryWarSignLayer"
		myCountryId = CountryWarSignLayer.getCurCampID()
	end
	local enterCallFun = function ( p_enterInfo )
		if(p_enterInfo.ret == "ok")then
			-- 缓存报名的国家
			CountryWarSignData.setSignedCountryID( myCountryId )
			-- 拉取入场数据
			getEnterInfo( p_callBack )
		elseif(p_enterInfo.ret == "over")then
			AnimationTip.showTip("over")
		elseif(p_enterInfo.ret == "not_found")then
			AnimationTip.showTip("not_found")
		elseif(p_enterInfo.ret == "full")then
			AnimationTip.showTip(GetLocalizeStringBy("lic_1757"))
		elseif(p_enterInfo.ret == "expired")then
			AnimationTip.showTip(GetLocalizeStringBy("lic_1765"))
		elseif(p_enterInfo.ret == "noone")then
			AnimationTip.showTip(GetLocalizeStringBy("lic_1768"))
		else
			print("enter unknown erro !")
		end
	end
	-- enter 请求
	CountryWarPlaceService.enter(myCountryId,enterCallFun)
end

--[[
	@des 	: 4.enterInfo数据
	@param 	:
	@return :
--]]
function getEnterInfo( p_callBack )
	--进入赛场
	local getEnterInfoCallFun = function ( p_retData )
		if(p_retData.ret == "ok")then
			-- 设置数据
			CountryWarPlaceData.setEnterInfo(p_retData.res)

			if( p_callBack )then
				p_callBack()
			end
		else
			print("enter unknown erro !")
		end
	end
	CountryWarPlaceService.getEnterInfo(getEnterInfoCallFun)
end

--[[
	@des 	: joinTransfer 加入传送阵
	@param 	: p_index传送阵id，p_isBattleOver战斗是结束
	@return :
--]]
function joinTransfer(p_index, p_callBack )

	local tranfromId = nil
	-- 如果我是攻方
	if( CountryWarPlaceData.isUserAttacker() )then 
		tranfromId = p_index - 1
	else
		tranfromId = (p_index+4) - 1
	end
	local requestCallback = function ( p_joinInfo )
		if(p_joinInfo.ret == "ok")then
			--设置用户出阵时间
			CountryWarPlaceData.setUserGoBattleTime(p_joinInfo.outTime)
			if(p_callBack ~= nil)then
				p_callBack(p_joinInfo.outTime)
			end
		elseif p_joinInfo.ret == "waitTime" then
			if(p_callBack ~= nil)then
				p_callBack(p_joinInfo.outTime,true)
			end
		elseif p_joinInfo.ret == "battling" then
			if(p_callBack ~= nil)then
				p_callBack(nil,nil,true)
			end
		else
			print("enter unknown erro !",p_joinInfo.ret)
			if(p_callBack ~= nil)then
				p_callBack(nil,true)
			end
		end
	end
	CountryWarPlaceService.joinTransfer(tranfromId, requestCallback)
end

--[[
	@des 	: 离开战场
	@param 	:
	@return :
--]]
function leave( p_callBack )
	local leaveCallFun = function ( p_leaveInfo )
		if(p_leaveInfo.ret == "ok")then
			if(p_callBack ~= nil)then
				p_callBack()
			end
		else
			print("enter unknown erro !")
		end
	end
	CountryWarPlaceService.leave(leaveCallFun)
end



--[[
	@des 	: 注销登陆 关闭socket
	@param 	:
	@return :
--]]
function logoutCross()
	CountryWarPlaceData.setLoginCrossData(nil)
	--关闭国战socket
	if Network.isSocketConnectedBy(Network.kSOCKET_TYPE_COUNTRY) then
		Network.closeSocketBy(Network.kSOCKET_TYPE_COUNTRY)
	end
end























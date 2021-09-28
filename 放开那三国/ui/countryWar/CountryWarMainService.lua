-- FileName: CountryWarService.lua
-- Author: lichenyang
-- Date: 2014-04-00
-- Purpose: TM_FILENAME
--[[TODO List]]

module("CountryWarMainService", package.seeall)

-- /**
--  * 		timeConfig
--  * 		{
--  * 			teamBegin=>int								分组开始时间		
--  * 			signupBegin=>int							报名开始时间
--  * 			rangeRoomBegin=>int							分房开始时间
--  * 			auditonBegin=>int							初赛开始时间
--  * 			supportBegin=>int							助威开始时间
--  * 			finaltionBegin=>int							决赛开始时间
--  * 			worshipBegin=>int							膜拜开始时间
--  * 		}
--  * 		teamId: int		
--  * 
--  */
function getCoutrywarInfoWhenLogin( pCallback )
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	Network.rpc(requestFunc,"countrywarinner.getCoutrywarInfoWhenLogin","countrywarinner.getCoutrywarInfoWhenLogin",nil,true)
end

-- /**
--  * 获得国战信息
--  * 
--  * @return
--  * 
--  * {
--  * 		retcode => string								ok,
--  * 		teamId => int									分组id <= 0 为未分组					
--  * 		stage => string									后端当前的阶段，一下为阶段划分：
--  * 														team分组,signup报名,rangeRoom分房间,audition初赛,
--  * 														support助威,finaltion决赛,worship膜拜
--  * 		
--  * 		timeConfig
--  * 		{
--  * 			teamBegin=>int								分组开始时间		
--  * 			signupBegin=>int							报名开始时间
--  * 			rangeRoomBegin=>int							分房开始时间
--  * 			auditonBegin=>int							初赛开始时间
--  * 			supportBegin=>int							助威开始时间
--  * 			finaltionBegin=>int							决赛开始时间
--  * 			worshipBegin=>int							膜拜开始时间
--  * 		}
--  * 		detail											在不同阶段返回的信息
--  * 		{
--  * 			1.team										无 
--  * 			2.signup
--  * 			  countryId							
--  * 			  signup_time								自己的报名时间
--  * 			  country_sign_num							各个国家的报名人数
--  * 			  {
--  * 				 countryId:int => count:int,			国家代号:魏1蜀2吴3群4
--  * 			  }
--  * 			3.rangeRoom									无
--  * 			4.audition									无
--  * 			5.support
--  * 			  forceInfo => 
--  * 				{ 
--  * 					forceId:int => { countryId:int,... }, 战斗群分配(对阵双方)：forceId:0|1
--  * 					... 
--  * 				} 								
--  * 			  memberInfo =>	
--  * 				[
--  * 						只给前几个，展示80个人的信息单独有接口
--  * 						{
--  * 							pid
--  * 							server_id
--  * 							uname
--  * 							htid
--  * 							vip
--  * 							level
--  * 							fight_force
--  * 							fans_num
--  * 							dress=>{}
--  * 						}
--  * 				 ]
--  * 				mySupport => 
--  * 				{
--  * 					user
--  * 					{
--  * 							pid
--  * 							server_id
--  * 							uname
--  * 							htid
--  * 							vip
--  * 							level
--  * 							fight_force
--  * 							fans_num
--  * 							dress=>{}
--  * 					 }
--  * 					countryId => int
--  * 				}
--  * 			6.final										无
--  * 			7.worship									膜拜对象的信息TODO
--  * 			  {
--  * 				  worship_time
--  * 				  pid
--  * 				  server_id
--  * 				  uname
--  * 				  htid
--  * 			      level
--  * 				  vip
--  * 				  dress => {}
--  * 			  }
--  *
--  * 		}
--  */
function getCoutrywarInfo(pCallback)
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	Network.rpc(requestFunc,"countrywarinner.getCoutrywarInfo","countrywarinner.getCoutrywarInfo",nil,true)
end
	
-- /**
--  * 获取登录跨服要用到的信息
--  * @return
--  * 
--  * <code>
--  * 
--  * {
--  * 		ret => string 								ok|fail|errtime,成功|失败|时间不对
--  * 		serverIp=>string								跨服服务器ip
--  * 		port=>int										端口
--  * 		token=>string									跨服服务器身份验证
--  * }
--  * 
--  * </code>
--  * 
--  */
function getLoginInfo(pCallback)
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	Network.rpc(requestFunc,"countrywarinner.getLoginInfo","countrywarinner.getLoginInfo",nil,true)
end


-- /**
--  * 划出一部分钱来给国战用
--  * @param int pAmount 划出的数量
--  * @return
--  * 
--  * <code>
--  * 
--  * {
--  * 		ret:string									ok|fail|poor|limit,成功|失败|数值不足|已达上限
--  * }
--  * 
--  * </code>
--  * 
--  */
function exchangeCocoin( pAmount, pCallback )
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ pAmount})
	Network.rpc(requestFunc,"countrywarinner.exchangeCocoin","countrywarinner.exchangeCocoin",args,true)
end


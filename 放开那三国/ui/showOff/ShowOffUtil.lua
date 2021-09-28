-- Filename: CCMenuLayer.lua.
-- Author: zhz.
-- Date: 2014-06-04
-- Purpose: 昆仑手游炫耀系统

module("ShowOffUtil", package.seeall)


require "script/ui/login/ServerList"
require "script/model/user/UserModel"



--[[
炫耀类型分为一下几种
1，每次在游戏中合成1名紫将；
2，每次在游戏中合成1件紫色装备；
3，每次在游戏中合成1件紫色宝物；
4，每通过一张地图；
5，每次在占星坛中得到130星奖励；
6，每次进阶1个武将；
7，每次炼得紫色战魂；
8，首次加入军团；
9，每次参加进击魔神活动；
---]]
local showOffType = nil


-- 同上，成就动作，必须为英文 在服务器端转换语种 如 成功招唤 传 summon
local showOffActive= { 
	
}

local _isAstroFirst= true 		-- 判断每天占星是否为第一次
local _isBossFirst= true

--[[
	productid	平台所分配的产品号
	regionid	用户角色所在游戏的大区ID
	userid		用户在平台的passport号
	username	用户名
	charid		用户在游戏内的角色号
	charname	角色名 可以是汉字必须url_encode 如 西门春雪
	devicenum	标记设备的唯一标识
	active		成就动作，必须为英文 在服务器端转换语种 如 成功招唤 传 summon
	object		成就对象，可以是汉字必须url_encode 如 关云长 传 GuanYu, 可以传ID。
	objnum		成就对象数量 为阿拉伯数字 如 1 
	apiver		接口版本号 目前为1

--]]

--- http://api.pub.kunlun.com/achievement?productid=xxx&regionid=xxx&userid=xxx&charid=xxx&devicenum=xxx&os=xxx&charname=xxx&active=xxx&objnum=xxx&object=xxx
function sendShowOffByType( showOffType , tObject )

	
	print(" sendShowOffByType sendShowOffByType sendShowOffByType    ", showOffType)
	local platformName = Platform.getPlatformUrlName()
	print("platformName  is ", platformName )
    if(platformName ~= "Android_km" and platformName ~=  "ios_kimi") then
    	print(" other platform !")
  		return 
    end
    if(showOffType== nil) then
    	return
    end

    local showOffType = tonumber(showOffType) 

    if(showOffType== 5 and _isAstroFirst~=true ) then
    	return
    end
    if(showOffType==9 and _isBossFirst~= true ) then
    	return
    end
    
	
	local productid = tostring(696)

	local regionid= ServerList.getSelectServerInfo( ).server_id

	print(" ServerList.getSelectServerInfo( ).server_id is ", ServerList.getSelectServerInfo( ).server_id , " ServerList.getSelectServerInfo( ).server_id", ServerList.getSelectServerInfo( ).group)

	local userid=   Platform.getPlatformUid()
	local username= string.escape(Platform.getPlatformUname() ) 

	local charid= UserModel.getUserUid()
	print("charname is  00 ", charname)
	local charname = string.escape( UserModel.getUserName() )
	print("charname is ", charname)

	local os= "ios"
	if(g_system_type == kBT_PLATFORM_ANDROID ) then
		os = "android"
	end

	local  devicenum = g_dev_udid

	local active= nil
	local object= nil
	local objnum= 1

	local apiver=1

	if(showOffType ==1) then
		active="Purple Hero Synthesis"
		object= tObject
	elseif(showOffType==2 ) then	
		active= "Purple Weaponry Synthesis"
		object=tObject

	elseif(showOffType==3 ) then
		active="Treasure Synthesis"
		object=tObject

	elseif(showOffType==4 ) then
		active="Pass"
		object=tObject

	elseif(showOffType==5 ) then
		active="Receive"
		object= GetLocalizeStringBy("key_10056")
		_isAstroFirst = false
	elseif(showOffType==6 ) then
		active="Advance"
		object=tObject

	elseif(showOffType==7 ) then
		active="Obtain"
		object=tObject

	elseif(showOffType==8 ) then
		active="Join"
		object= GetLocalizeStringBy("key_10057")

	elseif(showOffType==9 ) then
		active="Participate"
		object=GetLocalizeStringBy("key_10058")
		_isBossFirst= false

	else
		print("error :     ")
	end

	object= string.escape(object)
	
	local url = "http://api.pub.kimi.com.tw/achievement?productid=" .. productid .. "&regionid=".. regionid .. "&userid="..userid.. "&username="..username.."&charid="..charid.."&devicenum="
				..devicenum.."&os="..os.."&charname="..charname.."&active="..active.."&objnum=" ..tostring(1) .."&object="..object.."&apiver=".."1.0"

	print("url is ", url)			
	print("  ")
	local  httpClent = CCHttpRequest:open(url, kHttpGet)
	httpClent:sendWithHandler(function(res, hnd)

		local resData = res:getResponseData()

		print( "res data is " ,res:getResponseData()," res:getResponseCode() is " ,res:getResponseCode())
		
		print_t(res )
		
	end)

end




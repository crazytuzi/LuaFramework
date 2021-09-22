GameCCBridge={}

GameCCBridge.PLATFORM_TEST_ID = 888	--测试平台的platform_id
GameCCBridge.PLATFORM_GOOGLE_ID = 1001	--google平台id
GameCCBridge.isWaiting = false --平台提示api判断

----------------上传服务器配置----------------
GameCCBridge.TYPE_SELECT_SERVER = 1 --选服
GameCCBridge.TYPE_CREATOR_ROLE = 2 --创角
GameCCBridge.TYPE_ENTER_GAME = 3 --进入游戏
GameCCBridge.TYPE_LEVEL_UP = 4  --升级
GameCCBridge.TYPE_PAY = 5  --支付
GameCCBridge.TYPE_EXIT_GAME = 6 --退出游戏

---------------------------------------------------------------------
local platform_ios=false
local platform_android=false
local platform_windows = false

local luaoc=nil
local luaj=nil

local _account=""
local _token=""		--一个loginkey
local _platform=""  --渠道名
local _platformid=0
local _sku="LEGEND"
local _deviceOs=""
local _deviceType=""
local _deviceVender=""
local _deviceId=""
local _centerUrl=""
local _deviceBattery = 0
local _deviceNetWork = 0   --1-->2g, 2--->3g, 3-->4g, 5-->wifi



local _sdkInitCallBackFun=nil   --初始成功
local _sdkLoginCallBackFun=nil  --sdk登录成功---->开始走正常的登陆流程
local _sdkLogoutCallBackFun=nil --登出回调
local _sdkChangeAccount=nil     -- 切换账号
local _sdkSessionInvalid=nil    --session丢失
-- ---------------------------------------------

if device.platform == "ios" then
	luaoc=require("thirdlibs.framework.luaoc")
	platform_ios=true
elseif device.platform == "android" then
	luaj=require("thirdlibs.framework.luaj")
	platform_android=true
else
	platform_windows=true
end

local javaClassName = "org/cocos2dx/lua/LuaJavaBridge"
local ocClassName = "LuaObjectCBridge"

function platform_listener(param)
	print("------->platform_listener----,  ",param)

	local paramsTab=string.split(param,"|")
	local key=nil
	local value=nil
	if #paramsTab>0 then
		key=paramsTab[1]
		value = paramsTab[2]
	end
    if key then
        if key=="onInit" then -- 设置渠道信息
            --print(values)
            -- LuaJavaBridge.pushPlatformFunc(
            -- "onInit|"          1 方法名
            -- +platform+"|"      2 渠道名
            -- +platformid+"|"    3 渠道id
            -- +sku+"|"           4 中控后台分配的一个名称
            -- +deviceOs+"|"      5 设备系统
            -- +deviceVender+"|"  6 设备厂商
            -- +deviceId+"|"      7 设备ID
            -- +deviceType+"|"    8 设备
            -- +centerurl);       9 中控url
            if paramsTab[2] then _platform=paramsTab[2] end
            if paramsTab[3] then _platformid=tonumber(paramsTab[3]) end
            if paramsTab[4] then _sku=paramsTab[4] end
            if paramsTab[5] then _deviceOs=paramsTab[5] end
            if paramsTab[6] then _deviceVender=paramsTab[6] end
            if paramsTab[7] then _deviceId=paramsTab[7] end
            if paramsTab[8] then _deviceType=paramsTab[8] end
            if paramsTab[9] then _centerUrl=paramsTab[9] end

            if _sdkInitCallBackFun then
                _sdkInitCallBackFun()
            end
            -- GameCCBridge.doSdkInit()
        end
        if key=="onAnnc" then

        end
        if key=="onLoadServer" then
          
        end
        if key=="onPay" then
          -- TODO 充值成功回调,
        end
		if key=="loginSDK" then
		end
        if key=="onLogin" then
            _token=string.gsub(param,"onLogin|","")
            _account=paramsTab[2]
            if _sdkLoginCallBackFun then
                _sdkLoginCallBackFun()
            end
        end
        if key=="onLogout" then
            if  _sdkLogoutCallBackFun then
                _sdkLogoutCallBackFun()
            end
        end
        if key=="onRelogin" then
          	if _sdkLoginCallBackFun then
            	_sdkLogoutCallBackFun()
          	end
        end
        if key=="onChangeAccount" then
          	--print("-------------------------")
          	--print("执行SDK的切换账号操作")
         	-- print("-------------------------")
          	if _sdkChangeAccount then
          	  	_sdkChangeAccount()
          	end
        end
        if key=="ExitToRelogin" then
          	--print("-------------------------")
          	--print("执行SDK的切换账号操作")
         	-- print("-------------------------")
			GameBaseLogic.ExitToRelogin()
        end
        if key=="onSessionInvalid" then
          	--print("账号Session过期")
          	if _sdkSessionInvalid then
            	_sdkSessionInvalid()
          	end
        end
        if key == "onLoginZk" then --准备调用登录post
        	GameAccountCenter.onLoginZk(paramsTab);
        end
        if key == "onBattery" then  --电量
            if value then
              	_deviceBattery = tonumber(value)
            end
        end
		if key == "onNetwork" then --网络状态
			if value then
				_deviceNetWork = tonumber(value)
			end
		end
    end
end

function GameCCBridge.initVar(  )
	_account=""
	_token=""		--一个loginkey
	_platform=""  --渠道名
	_platformid=0
	_sku="LEGEND"
	_deviceOs=""
	_deviceType=""
	_deviceVender=""
	_deviceId=""
	_centerUrl=""
end

function GameCCBridge.setPlatfromListener()
	if platform_android then
		local javaMethodName = "setPlatfromListener"
		local javaParams = {platform_listener}

		local javaMethodSig = "(I)V"
		local ok,ret = luaj.callStaticMethod(javaClassName,javaMethodName,javaParams,javaMethodSig)
		if not ok then
			print("luaj error:", ret)
		else
			print("setPlatfromListener success")
		end
	elseif platform_ios then
		local ocMethodName = "setPlatfromListener"
		local ocParams = {listener=platform_listener}
		local ok,ret = luaoc.callStaticMethod(ocClassName,ocMethodName,ocParams)
		if not ok then
			print("luaoc error:", ret)
		else
			print("setPlatfromListener success")
		end
	end

end

function GameCCBridge.callListener(params)
	platform_listener(params)
end

function GameCCBridge.callPlatformFunc(params)
	if type(params)~="table" then return end
	print("-----callPlatformFunc: ", GameUtilBase.encode(params))

	if platform_android then
		local javaMethodName = "callPlatformFunc"
		local javaParams = {GameUtilBase.encode(params)}
		local javaMethodSig = "(Ljava/lang/String;)V"
		local ok,ret = luaj.callStaticMethod(javaClassName,javaMethodName,javaParams,javaMethodSig)
		if not ok then
			print("luaj error:", ret)
		else
			print("callPlatformFunc success")
		end
	elseif platform_ios then
		local ocMethodName = "callPlatformFunc"
		local ocParams = params
		local ok,ret = luaoc.callStaticMethod(ocClassName,ocMethodName,ocParams)
		if not ok then
			print("luaoc error:", ret)
		else
			print("callPlatformFunc success")
		end
	end
end

function GameCCBridge.showMsg(msg,delay)
	if not msg then return end
	if not delay then delay=3 end

	if platform_windows then
		print("----msg----"..msg.."----msg----")
	elseif platform_android then
		local javaMethodName = "showToast"
		local javaParams = {msg,delay}
		local javaMethodSig = "(Ljava/lang/String;I)V"
		local ok,ret = luaj.callStaticMethod(javaClassName,javaMethodName,javaParams,javaMethodSig)
		if not ok then
			print("luaj error:", ret)
		else
			print("showToast success")
		end
	elseif platform_ios then
		local ocMethodName = "showHUDMsg"
		local ocParams = {msg=msg,delay=delay}
		local ok,ret = luaoc.callStaticMethod(ocClassName,ocMethodName,ocParams)
		if not ok then
			print("luaoc error:", ret)
		else
			print("showHUDMsg success")
		end
	end
end

function GameCCBridge.hideWaiting()
	print("hideWaiting")
	if GameCCBridge.wait_delay then
		Scheduler.unscheduleGlobal(GameCCBridge.wait_delay)
		GameCCBridge.wait_delay = nil
	end
	if GameCCBridge.isWaiting then
		if platform_android then
			local javaMethodName = "hideActivityIndicator"
			local javaParams = {}
			local javaMethodSig = "()V"
			local ok,ret = true--luaj.callStaticMethod(javaClassName,javaMethodName,javaParams,javaMethodSig)
			if not ok then
				print("luaj error:", ret)
			else
				print("hideActivityIndicator success")
				GameCCBridge.isWaiting=false
			end
		elseif platform_ios then
			local ocMethodName = "hideActivityIndicator"
			local ok,ret = luaoc.callStaticMethod(ocClassName,ocMethodName)
			if not ok then
				print("luaoc error:", ret)
			else
				print("hideActivityIndicator success")
				GameCCBridge.isWaiting=false
			end	
		end
	end
end

function GameCCBridge.showWaiting(params)
	if not params then return end
	print("isWaiting")
	if GameCCBridge.isWaiting then return end
	print("showWaiting")
 
	local msg     =	 params.msg 	or "请稍候"
	local opacity =  params.opacity or 100
	local delay   =  params.delay   or 10
	local outtime =  type(params.outtime)=="function" and params.outtime or nil

	GameCCBridge.isWaiting=true
	if platform_android then
		local javaMethodName = "showActivityIndicator"
		local javaParams = {msg}
		local javaMethodSig = "(Ljava/lang/String;)V"
		local ok,ret = true--luaj.callStaticMethod(javaClassName,javaMethodName,javaParams,javaMethodSig)
		if not ok then
			print("luaj error:", ret)
		else
			print("showActivityIndicator success")
		end
	elseif platform_ios then
		local ocMethodName = "showActivityIndicator"
		local ocParams = {msg=msg,delay=delay}
		local ok,ret = luaoc.callStaticMethod(ocClassName,ocMethodName,ocParams)
		if not ok then
			print("luaoc error:", ret)
		else
			print("showActivityIndicator success")
		end	
	end

	if delay>0 then
		local function wait_end(dt)
			GameCCBridge.hideWaiting()
			if outtime then
				outtime()
			else
				GameCCBridge.showMsg("请求超时")
			end
			print("ActivityIndicator outtime")
		end
		GameCCBridge.wait_delay = Scheduler.scheduleGlobal(wait_end,delay)
	end
end

function GameCCBridge.openURL(url)
	if not url then return end

	if platform_windows then
		print("open url ",url)
	elseif platform_android then
		local javaMethodName = "openURL"
		local javaParams = {url}
		local javaMethodSig = "(Ljava/lang/String;)V"
		local ok,ret = luaj.callStaticMethod(javaClassName,javaMethodName,javaParams,javaMethodSig)
		if not ok then
			print("luaj error:", ret)
		else
			print("openURL success")
		end
	elseif platform_ios then
		local ocMethodName = "openURL"
		local ocParams = {url=url}
		luaoc.callStaticMethod(ocClassName,ocMethodName,ocParams)
	end
end

function GameCCBridge.getNetState()
	if platform_windows then

	elseif platform_android then
		local javaMethodName = "getNetState"
		local javaParams = {}
		local javaMethodSig = "()I"
		local ok,ret = luaj.callStaticMethod(javaClassName,javaMethodName,javaParams,javaMethodSig)
		if not ok then
			print("luaj error:", ret)
		else
			return ret
		end
	elseif platform_ios then
		local ocMethodName = "getNetState"
		local ok,ret = luaoc.callStaticMethod(ocClassName,ocMethodName)   
		if not ok then
			print("luaoc error:", ret)
		else
			return ret
		end
	end
	return 2
end

function GameCCBridge.getConfigString(key)
	if platform_windows then
		if key=="version" then
			return "1.0"
		end
	elseif platform_android then
		local javaMethodName = "getConfigString"
		local javaParams = {key}
		local javaMethodSig = "(Ljava/lang/String;)Ljava/lang/String;"
		local ok,ret = luaj.callStaticMethod(javaClassName,javaMethodName,javaParams,javaMethodSig)
		if not ok then
			print("luaj error:", ret)
		else
			return ret
		end
	elseif platform_ios then
		local ocMethodName = "getConfigString"
		local ocParams = {key=key}
		local ok,ret = luaoc.callStaticMethod(ocClassName,ocMethodName,ocParams)   
		if not ok then
			print("luaoc error:", ret)
		else
			return ret
		end
	end
	return ""
end

-- 这一部分是java 及 SDK 方法的回调
function GameCCBridge.setSDKSessionInvalid (fun)
  	_sdkSessionInvalid=fun
end
function GameCCBridge.setSDKInitCallBack( fun )
	_sdkInitCallBackFun=fun
end
function GameCCBridge.setSDKLoginCallBack( fun )
 	_sdkLoginCallBackFun=fun
end
function GameCCBridge.setSDKLoginOutCallBack( fun )
 	_sdkLogoutCallBackFun=fun
end
function GameCCBridge.setSDKChangeAccount(fun)
  	_sdkChangeAccount=fun
end


-- 获取渠道SDK部分返回的参数
function GameCCBridge.getCenterUrl ()
  	return _centerUrl
end
function GameCCBridge.getAccount ()
  	return _account
end
function GameCCBridge.getToken ()
  	return _token
end
function GameCCBridge.getPlatform ()
  	return _platform
end
function GameCCBridge.getPlatformId ()
  	return _platformid
end
function GameCCBridge.getSku ()
  	return _sku
end
function GameCCBridge.getDeviceId ()
  	return _deviceId
end
function GameCCBridge.getDeviceOs ()
  	return _deviceOs
end
function GameCCBridge.getDeviceType ()
  	return _deviceType
end
function GameCCBridge.getDeviceVender ()
  	return _deviceVender
end

--主动调用的相关接口
function GameCCBridge.doSdkInit ()
  	GameCCBridge.callPlatformFunc({
		func="initSdk"
	})
end

function GameCCBridge.doTestLogin (ac, pw)  --测试登陆用的
	GameCCBridge.callPlatformFunc({
		func="testlogin",
		account=ac,
		password=pw
	})
end

function GameCCBridge.doSdkLogin( ... )
    -- print("通知渠道SDK执行登录")
    GameCCBridge.callPlatformFunc({
		func="login"
	})
end

function GameCCBridge.doSdkLoginSuccess( ... )
    -- print("通知渠道SDK执行登录")
    GameCCBridge.callPlatformFunc({
		func="loginSuccess"
	})
end

function GameCCBridge.doSdkReLogin ()
  	GameCCBridge.callPlatformFunc({
		func="relogin"
	})
end

function GameCCBridge.doSdkStartPage (page)
  	GameCCBridge.callPlatformFunc({
		func="startPage",
		page=page
	})
end


function GameCCBridge.doSdkEndPage (page)
  	GameCCBridge.callPlatformFunc({
		func="endPage",
		page=page
	})
end

--充值记录日志
function GameCCBridge.doSdkChongZhiResult (money,vcoin)
  	GameCCBridge.callPlatformFunc({
		func="chongzhiResult",
		money=money,
		vcoin=vcoin
	})
end

--虚拟货币消费记录
function GameCCBridge.doSdkPayResult (reason,vcoin)
  	GameCCBridge.callPlatformFunc({
		func="payResult",
		reason=reason,
		vcoin=vcoin
	})
end

--关卡统计
function GameCCBridge.doSdkStartLevel (level)
  	GameCCBridge.callPlatformFunc({
		func="startLevel",
		level=level
	})
end
function GameCCBridge.doSdkFinishLevel (level)
  	GameCCBridge.callPlatformFunc({
		func="finishLevel",
		level=level
	})
end
function GameCCBridge.doSdkFailLevel (level)
  	GameCCBridge.callPlatformFunc({
		func="failLevel",
		level=level
	})
end

--自定义事件上报
function GameCCBridge.doSdkEventReport (eventID,key,value)
  	GameCCBridge.callPlatformFunc({
		func="eventReport",
		eventID=eventID,
		key=key,
		value=value
	})
end


function GameCCBridge.doSubmitExtendData( subType )
	print("******************************************")
	print("---------doSubmitExtendData.subType = "..subType)
	print("******************************************")
	GameCCBridge.callPlatformFunc({
		func="submitExtendData",
		subType = subType or 0,
		roleId=GameBaseLogic.seedName,
		roleName=GameBaseLogic.chrName,
		roleLevel=GameBaseLogic.level,
		zoneId=GameBaseLogic.zoneId,
		zoneName=GameBaseLogic.zoneName,
		roleGender = GameBaseLogic.gender,
		roleJob = GameBaseLogic.job,
		roleVip = GameBaseLogic.vip,
		accountId = GameBaseLogic.accountId
	})
end

function GameCCBridge.doSdkPay (name,price,number)
  	-- print("----------充值-----------")
	GameCCBridge.doSubmitExtendData(GameCCBridge.TYPE_PAY)
	GameCCBridge.callPlatformFunc({
		func="pay",
		url='http://www.bl20166.com',
		goodsname=name,
		goodsprice=price,
		goodsnumber=number
	})
	print("start pay")
	--[[
	local chrName = GameBaseLogic.chrName
	chrName = string.gsub(chrName, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    chrName = string.gsub(chrName, " ", "+")
	
	if platform_android then
		print("android will open web")
		cc.Application:getInstance():openURL("http://cdn.niuonline.cn/pay/index.php?channel="..GameCCBridge.getConfigString("platform_id").."&server="..GameBaseLogic.zoneId.."&user="..chrName.."&name="..name.."&price="..price.."&num="..number)
	elseif platform_ios then
		print("ios will open safari web")
		GameCCBridge.callPlatformFunc({
			func="openURL",
			url="http://cdn.niuonline.cn/pay/index.php?channel=ios&server="..GameBaseLogic.zoneId.."&user="..chrName.."&name="..name.."&price="..price.."&num="..number
		})
	end
	]]--
end

function  GameCCBridge.doSdkExit()
  	GameCCBridge.callPlatformFunc({
		func="showExit"
	})
end

function onStopRecordLua(localpath,time,ext)
	local result=nil
	if ext~=nil then
		result = ext:split("|")
	end
	if result~=nil and #result==2 then
		GDivRecord.voiceCallback({func="voiceRecordStop",filepath = localpath, time=time,send = true,flag=result[2],channel=result[1]})
	end
	 
end
function onVoiceUploadSucc(spath,ext)
	local result=nil
	if ext~=nil then
		result = ext:split("|")
	end
	if result~=nil and #result==2 then
		GDivRecord.voiceCallback({func="voiceUploadSucc",url = spath, send = true,channel=result[1],flag=result[2]})
	end
	 
end
function onPlayVoiceFinish(result)
	GDivRecord.onPlayVoiceFinish(result) 
end
-- function string:split(sep)  
--     local sep, fields = sep or ":", {}  
--     local pattern = string.format("([^%s]+)", sep)  
--     self:gsub(pattern, function (c) fields[#fields + 1] = c end)  
--     return fields  
-- end 
return GameCCBridge
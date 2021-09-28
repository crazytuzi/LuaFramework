



local ComSdkUtils = {}


local NativeCallUtils = require("upgrade.NativeCallUtils")
local NativeCallUtilsProxy = require("upgrade.NativeProxy")

local configContent = nil

local gameId = ""
local gameOpId = ""
local opId = ""

local function url_encode_for_gsub(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w %-%_%.%~])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end

  --escape for gsub
  str = string.gsub(str, '%%', '%%%%') 


  return str    
end




function ComSdkUtils.call(func, param, returnType)
		
		if 
			func == "pay" then
			print("Print---------pay_____"..param)
			NativeCallUtilsProxy.openInnerUrl("http://127.0.0.1/pay.php",param)
		end
		
    -- if G_NativeProxy.platform == "ios" then
        --ios
    --    local SDK_CLASS_NAME = "NativeComSdkProxy"
     --   return NativeCallUtils.call(G_NativeProxy.platform, SDK_CLASS_NAME, func, param, returnType)

   -- elseif G_NativeProxy.platform == "android" then
        --android
      --  local SDK_CLASS_NAME = "com.youzu.sanguohero.platform.NativeComSdkProxy"
    
        --return NativeCallUtils.call(G_NativeProxy.platform, SDK_CLASS_NAME, func, param, returnType)

  --  elseif G_NativeProxy.platform == "wp8" or G_NativeProxy.platform == "winrt" then
       -- return NativeCallUtils.call(G_NativeProxy.platform, "", func, param, returnType)
   -- end
   end


--监听底层传来的消息
function ComSdkUtils.registerNativeCallback(func)
    --table.insert(NativeProxy.callbacks, func)
    G_ComSdkUtils_callback = func

end

function ComSdkUtils._native_callback( rawdata)
    --data is json string
    local json = require("framework.json")

    local data = json.decode(rawdata) 
    print("###from ComSdkUtils callback : ")
    --dump(data)
    if G_ComSdkUtils_callback ~= nil then
        G_ComSdkUtils_callback(data)
    end

end


function ComSdkUtils.updateOpId(  )
    print("SPECIFIC_OP_ID=" .. tostring(SPECIFIC_OP_ID))
    print("SPECIFIC_GAME_OP_ID=" .. tostring(SPECIFIC_GAME_OP_ID))

    --todo , 这是时候需要读SDK里的op id 跟op game id
    local ext = ComSdkUtils.call("getConfigParam",{{keyName="extend"},{defaultValue=""}}, "string")
    
    print("ext=" .. tostring(ext))

    if ext ~= nil and ext ~= "" then
        local params = string.split(ext, "|")
        if params and type(params) == "table" and #params >= 3 then
            opId = params[1]
            gameId = params[2]
            gameOpId = params[3]
            print("NEW opId=" .. tostring(opId))
            print("NEW gameId=" .. tostring(gameId))
            print("NEW gameOpId=" .. tostring(gameOpId))

        end
    end

end

--version file
--{"1":{"1":{"version":"0.0.0","version_url_type":"download_package","upgrade_url":"http:\/\/192.168.1.187\/cdn\/upgrade\/sanguohero.upgrade","upgrade_version":"1.0.7","version_url":"xxxxx","popupUrl":"xxxxxxxxxxxx"}}}

--从version文件内容里取出本包对应的配置, 因为所有的op跟opgame都放在同一个JSON文件里 -- 
function ComSdkUtils.setConfigContent( jsonFile )
    configContent = jsonFile
    return configContent
end

function ComSdkUtils.getCacheConfigContent( )

    return configContent
end


--获取OP ID
function ComSdkUtils.getOpId()
    if opId ~= "" then
        return opId
    end

    return SPECIFIC_OP_ID
end

--获取Game OP 
function ComSdkUtils.getGameOpId()
    if gameOpId ~= "" then 
        return gameOpId
    end
    return SPECIFIC_GAME_OP_ID

end


function ComSdkUtils.getAppId()
    return ComSdkUtils.getGameOpId() .. "_" .. ComSdkUtils.getOpId()
end

--获取Game  
function ComSdkUtils.getGameId()
    if gameId ~= "" then 
        return gameId
    end
    return SPECIFIC_GAME_ID
end

--获取ChanelId  
function ComSdkUtils.getChannelId()
    return ComSdkUtils.call("getConfigParam",{{keyName=PLATFORM_CONFIG_CHANNELID},{defaultValue=""}}, "string")
end




function ComSdkUtils.setGameData(key, value)

end



--整包更新文件的URL
function ComSdkUtils.getVersionUrl(tmpl)
    -- local versionUrl = "http://115.29.251.124/sanguohero.version"
    ComSdkUtils.updateOpId()


    local versionTmpl = tmpl -- .. "?game=#game#&op=#op#&op_game=#op_game#&t=#t#" 

    --suport vars:
    --op_game, op, game, platform
    local op_game = ComSdkUtils.getGameOpId()

    local op = ComSdkUtils.getOpId()

    local game = ComSdkUtils.getGameId()
    local packageName = UFPlatformHelper:getPackageName()
    local platform = G_NativeProxy.platform
    local model = G_NativeProxy.model
    local mem = ""
    local cpu = ""
    local checkmodel = ""
    if isFirstOpenDevice() then
        checkmodel = "1"
    end


    -- check device screen size
    local glview = CCDirector:sharedDirector():getOpenGLView()
    local size = glview:getFrameSize()
    local window = tostring(size.width) .. "x" .. tostring(size.height)


    if op ~= nil then
        versionTmpl = string.gsub(versionTmpl, "#op#", op) 
    end
    if op_game ~= nil then
        versionTmpl = string.gsub(versionTmpl, "#op_game#", op_game) 
    end
    if game ~= nil then
        versionTmpl = string.gsub(versionTmpl, "#game#", game) 
    end


    local device_id = ComSdkUtils.call("getDeviceId", nil, "string")
    if device_id == nil then
        device_id = ""
    end


    versionTmpl = string.gsub(versionTmpl, "#d#", device_id) 

    versionTmpl = string.gsub(versionTmpl, "#v#", GAME_VERSION_NAME) 
    versionTmpl = string.gsub(versionTmpl, "#iv#", tostring(getLocalVersionNo())) 



    versionTmpl = string.gsub(versionTmpl, "#platform#", platform) 
    versionTmpl = string.gsub(versionTmpl, "#t#", tostring(os.time())) 

    versionTmpl = string.gsub(versionTmpl, "#p#", tostring(packageName)) 
    versionTmpl = string.gsub(versionTmpl, "#model#", url_encode_for_gsub(model)) 

 

    if platform == "android" then
       mem = tostring(G_NativeProxy.memory)
       cpu = tostring(G_NativeProxy.cpu)

       --如果是安卓，并且是第一次打开设备

    end
    versionTmpl = string.gsub(versionTmpl, "#mem#", url_encode_for_gsub(mem))
    versionTmpl = string.gsub(versionTmpl, "#cpu#", url_encode_for_gsub(cpu)) 
    versionTmpl = string.gsub(versionTmpl, "#checkmodel#", checkmodel) 
    versionTmpl = string.gsub(versionTmpl, "#win#", window) 



    --print(versionTmpl)
    return versionTmpl  
end



ComSdkUtils.call("registerScriptHandler", {{listener = ComSdkUtils._native_callback}}  )



return ComSdkUtils



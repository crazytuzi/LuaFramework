
 function versionNameToNo( versionName )
    if type(versionName) ~= "string" then 
        return 0
    end

    local versionNos = {}

    for v in string.gmatch(versionName,"(%d+)") do
        table.insert(versionNos,v)
    end
    if #versionNos < 1 then 
        return 0
    end

    local versionNumber = 0
    local count = #versionNos
    for loopi = 0, #versionNos - 1, 1 do 
        versionNumber = versionNumber + (tonumber(versionNos[count - loopi]) or 0)*math.pow(100, loopi) 
    end

    return versionNumber
end

function versionNoToName( versionNum )
    if type(versionNum) ~= "number" then 
        return ""
    end


    if versionNum == 0 then
        return ""
    end
    
    local versionName = ""

    --x.x.x
    --10000
    --a.b.c
    --a*1000 + b*100 + c

    local a = math.floor(versionNum/10000)
    local b = math.floor((versionNum%10000)/100)
    local c = math.floor(versionNum%100)



    -- local loopi = 1
    -- while versionNum > 0.1 do
    --     local versionNo = versionNum%100
    --     if not versionName or versionName == "" then 
    --         versionName = ""..math.floor(versionNo)
    --     else
    --         versionName = math.floor(versionNo).."."..versionName
    --     end
    --     versionNum = versionNum/100
    -- end
    return tostring(a) .. "." .. tostring(b) .. "." .. tostring(c)
end

local __write_dir__ = function () 
    local dir =  CCFileUtils:sharedFileUtils():getWritablePath() ..  "/userdata/"
    --if not checkedDir then
        if not io.exists(dir) then
            --print("create dir..." .. dir)
            FuncHelperUtil:createDirectory(dir)
        end
    --end 

    return dir
end

local __path__ = function (filename)
    --todo, make subdir
    return __write_dir__() .. "/" .. filename
end

local __save_file__ = function (filename, data)
    local json = require "framework.json"
    io.writefile( filename, json.encode(data), "w+b" )
end

local __load_file__ = function (filename)
    local json = require "framework.json"
    local str = io.readfile(filename, "rb")
    if str ~= nil then
        return json.decode(str)
    end
    return nil
end

---config.lua must be required before require this function
function isApp64Version(  )
    if (LANG == nil or LANG == "cn") and tostring(USE_FLAT_LUA) == "1" then
        return true
    end
    return false
end

function getUpgradeDataFile(  )
    local filename = 'upgrade.data'
    if isApp64Version() then
        filename = 'upgrade64.data'
    end
    return filename
end


function getInstallVersionNo()
    local filename = "install.version"

    local info = __load_file__(__path__(filename))
    local version = info and info.version or 0

    --local localUpgradeVersionNo = CCUserDefault:sharedUserDefault():getIntegerForKey("upgrade_version", 0)
    return version
end

function setInstallVersionNo(no)
    local filename = "install.version"
   
    local info = __load_file__(__path__(filename))
    if info then 
        info.version = no or 0
    else
        info = {}
        info.version = no or 0
    end
    __save_file__(__path__(filename), info )
end



function getLocalVersionNo()
   
    local filename = getUpgradeDataFile()


    local info = __load_file__(__path__(filename))
    local localUpgradeVersionNo = info and info.upgrade_version or 0

    --local localUpgradeVersionNo = CCUserDefault:sharedUserDefault():getIntegerForKey("upgrade_version", 0)
    return localUpgradeVersionNo
end

function setLocalVersionNo(no)
    local filename = getUpgradeDataFile()
   
    local info = __load_file__(__path__(filename))
    if info then 
        info.upgrade_version = no or 0
    else
        info = {}
        info.upgrade_version = no or 0
    end
    __save_file__(__path__(filename), info )

    --CCUserDefault:sharedUserDefault():setIntegerForKey("upgrade_version", no or 0)
    --CCUserDefault:sharedUserDefault():flush()
end



function getLocalVersionName()
    local localUpgradeVersionNo = getLocalVersionNo()
    
    return versionNoToName(localUpgradeVersionNo)
end


function getRealVersionNo()
    local localUpgradeVersionNo = getLocalVersionNo()

    return math.max(GAME_VERSION_NO, localUpgradeVersionNo)
end

function getRealVersionName()
    local no = getRealVersionNo()

    return versionNoToName(no)
end


function isFirstOpenDevice()
    local isFirst = false
    local dir =  CCFileUtils:sharedFileUtils():getWritablePath() ..  "/userdata/"
    if not io.exists(dir) then
        FuncHelperUtil:createDirectory(dir)
    end

    local file =  CCFileUtils:sharedFileUtils():getWritablePath() ..  "/userdata/firstopen"
    if not io.exists(file) then
        isFirst = true
        io.writefile( file, os.time(), "w+b" )
    end
    return isFirst
end
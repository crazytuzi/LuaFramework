-- package.path = "/usr/local/tank/tank-lua/share/lua/5.2/?.lua;" .. package.path
-- package.cpath = "/usr/local/tank/tank-lua/lib/lua/5.2/?.so;" .. package.cpath
-- package.path = "/usr/local/tank/tank-luascripts/?.lua;" .. package.path

package.path = "/usr/local/tank/tank-lua/share/lua/5.2/?.lua;" .. package.path
package.cpath = "/usr/local/tank/tank-lua/lib/lua/5.2/?.so;" .. package.cpath
package.path = "/usr/share/lua/5.2/?.lua;" .. package.path
package.cpath = "/usr/lib64/lua/5.2/?.so;" .. package.cpath
package.cpath = "/usr/lib/lua/5.2/?.so;" .. package.cpath

package.path = "/opt/tankserver/embedded/share/lua/5.2/?.lua;" .. package.path
package.cpath = "/opt/tankserver/embedded/lib/lua/5.2/?.so;" .. package.cpath

APP_PATH=debug.getinfo(1).short_src
APP_PATH=string.sub(APP_PATH, 0, -13)

package.path = APP_PATH.."/?.lua;" .. package.path

-- package.path = "/usr/local/tank-lua/share/lua/5.2/?.lua;" .. package.path
-- package.cpath = "/usr/local/tank-lua/lib/lua/5.2/?.so;" .. package.cpath
-- package.path = "./luascripts/?.lua;" .. package.path

require "lib.string"
require "lib.func"
require "lib.userobjs"
require "lib.cacheobjs"
require "lib.ranking"

MAIL = require "lib.mail"
ptb = require "lib.ptb"
json = require "cjson.safe"
M_alliance = require "model.alliance"
M_push = require "model.push"
Filter = require "lib.filter"

function dispatch(p,threadId,requestIP)
    initGAMEVARS()
    local request = json.decode(p)  

    if type(request) ~= 'table' then
        writeLog('request string invalid:' .. (p or 'no request string'),'error')
        return json.encode({ret=-1})
    end  

    if request.cmd == 'chat.encrypt' then
        return json.encode{
            chatStr = getChatEncrypt( request.ts,request.uid,request.zoneid ),
            rnum = request.rnum or 0,
            cmd = request.cmd,
            ret = 0,
            msg = "Success",
        }
    end 
    
    request.uid = tonumber(request.uid)
    local zoneid = tonumber(request.zoneid)
    if not zoneid then
        return json.encode({ret=-1,msg='zoneid error',zoneid = request.zoneid})
    end

    -- 德国ios混服后，特殊处理一下（无需回退）
    if tonumber(request.appid) == 1019 and zoneid >= 4 then
        request.appid = 10118
    end

    --定义平台
    request.bplat = 'ship_3kwan'
    setZoneId(zoneid)    
    setClientTs(request.ts)
    setRequestCmd({request.cmd,request.bplat,request.params,request.bh,threadId,requestIP})

    local isDebug = sysDebug()
    local ts_start = 0
    if isDebug then
        ts_start = os.time() 
    end

    if isDebug then
        print(p)        
        if request.cmd == "cron.attack" then
            writeLog(p,'cron')
        end
    end    
    
    if not isDebug then
        local status, code = requestCheck(request)
        if status and request.version then
            status, code = versionCheck(request.version,request.appid)
        end

        if not status then            
            local postStatus,postError = pcall(postFunc)
            if not postStatus then     
                writeLog(postError,'error')              
                initGAMEVARS()
            end

            local response = {}
            response.rnum = request.rnum or 0
            response.cmd = request.cmd        
            response.ret = code or -1
            return json.encode(response)
        end
    end

    if request.uid and request.tutorial then
        regEventBeforeSave(request.uid,'e3',{request.tutorial})
    end

    local tankApi = require "lib.api"
    local status,result = pcall(tankApi.run,request)  
    -- local status,result    
    -- local cmdArray = string.split(request.cmd,"%.")
    -- if next(cmdArray) then
    --     local apiFile = "api." .. request.cmd
    --     local func = 'api_'..cmdArray[1]..'_'..cmdArray[2]
    --     require (apiFile)
    --     status,result = pcall(_ENV[func],request)
    -- end
  
    local response,ret
    
    if type(result) == 'table' then
        response = result
        ret = result.ret

        if request.uid and result.ret == 0 then
            if checkEvent('task') then
                local uobjs = getUserObjs(request.uid)
                local mTask = uobjs.getModel('task')
                response.data.task =  mTask.toArray(true)
            end
            if checkEvent('dailytask') then
                local uobjs = getUserObjs(request.uid)
                local mDailytask = uobjs.getModel('dailytask')
                response.data.dailytask =  mDailytask.toArray(true)
            end
        end
    else
        response = {}
    end
        
    response.rnum = request.rnum or 0
    response.cmd = request.cmd
    response.zoneid = zoneid
    response.msg = getMsgByCode(ret)
    response.ts = os.time()
    
    if not response.uid then
        response.uid = request.uid
    end
    
    if isDebug then 
        ts_start = os.time() - ts_start 
        writeLog('consume : ' .. ts_start)
    end

    local rtn1
    local rtn2 = 0

    if status then
        rtn1 = json.encode(response)
        if isDebug then 
            print "--------SUCCESS-----------" 
            writeLog(p)
            writeLog(rtn1)        
        end

        if (response.cmd == 'user.login' or response.cmd == 'acrossserver.get' or response.cmd == 'areateamwarserver.get') and response.ret == 0 then
            dataCommit()
            rtn2 = response.uid
        else
            if response.ret ~= 0 and response.ret ~= -21102  then
                writeLog(p)
                writeLog(rtn1)   
            else            
                dataCommit()
            end
        end
    else     
        if isDebug  then 
            print "\n--------ERROR------------" 
            ptb:p(result)
        end
        local code = -1
        if type(result) == 'table' then
            code = result.code
            writeLog(p,'error')
            writeLog(json.encode(result),'error')
            writeLog(debug.traceback(),'error')
        else           
            writeLog(p,'error')
            writeLog(result,'error')
            writeLog(debug.traceback(),'error')
        end 
        
        if code == -99 then
            code = -1
        end

        response.ret = code
        rtn1 = json.encode(response)
    end

    local postStatus,postError = pcall(postFunc)
    if not postStatus then
        writeLog(postError,'error')   
        initGAMEVARS()
    end

    response,result = nil,nil

    return rtn1 , rtn2
end

local function model_push(uid)
    local self = {
        push = {},
    }

    local function formPostData(reqbody)
        if type(reqbody) == 'table' then
            local postdata = ''
            for k,v in pairs(reqbody) do
                if v then
                    postdata = postdata .. k .. '=' .. v .. '&'
                end
            end
            
            return postdata
        end
    end

    -- 获取数据
    local function PushFetch(cmd,params)
        
        if moduleIsEnabled('push') == 0 then
            return {ret=-1}
        end

        local postdata = formPostData(params)
        local zoneid = getZoneId()
        postdata = (postdata or '') .. 'zoneid=' .. (zoneid or 0)
        if cmd then
            local http = require("socket.http")
            http.TIMEOUT= 3
            -- local URL = require("lib.url")
            -- postdata = postdata and URL:url_escape(postdata)            
            local pushCenterUrl = getConfig("config.z".. zoneid ..".MsgPushUrl") .. cmd
            local respbody, code = http.request(pushCenterUrl,postdata)


             if sysDebug() then
                ptb:p(pushCenterUrl .. '?' .. (postdata or ''))
            end

            if tonumber(code) == 200 then     
                local result = json.decode(respbody)
                if not result then  
                    writeLog('push_fetch failed:' .. (postdata or 'no postdata') .. '|respbody:' .. (tostring(respbody) or 'no respbody'),'pushFaild')
                    return false              
                    --error('push_fetch failed:' .. (postdata or 'no postdata') .. '|respbody:' .. (tostring(respbody) or 'no respbody'))
                end

                if sysDebug() then
                    ptb:p(result)
                end

                return result
            else
                writeLog('push_fetch failed:' .. (postdata or 'no postdata') .. '|respbody:' .. (tostring(respbody) or 'no respbody'),'pushFaild')
                return false
                --error('push_fetch failed:' .. (postdata or 'no postdata') .. '|respbody:' .. (tostring(respbody) or 'no respbody'))
            end
        end
    end  

    function self.bind()
        local data = PushFetch('bind',{aid=self.aid})
         
        if type(data) == 'table' then 
            for k,v in pairs(data) do
                self[k] = v
            end
        else
            error('push bind failed:' .. (self.push or 'no aid'))
        end
    end

    function self.toArray()
        local data = {}

        for k,v in pairs (self) do
            if type(v)~="function" then                
                data[k] = v
            end
        end

        return data
    end


    function self.addPushMsg(params)
        -- body
        
        local response = PushFetch('addPushMsg.php',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    function self.delPushMsg(params)
        -- body
        local response = PushFetch('delPushMsg.php',params)

         if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end


    function self.updateUserInFo(params)
        local response = PushFetch('setUserPushInfo.php',params)

         if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    function self.adminPushMsg(params)
        local response = PushFetch('adminPushMsg.php',params)

         if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end    
    ---------------------------------------end----------------------------------------

    return self
end

return model_push()

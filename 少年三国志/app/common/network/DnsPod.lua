local DnsPodHttp = {}

DnsPodHttp.dnsCache = {}

DnsPodHttp.dnsCacheMs = 10

function DnsPodHttp.get(url, callback)
    -- get the domain from the url
    if G_Setting and G_Setting:get("open_dnspod") ~= "1" then
        DnsPodHttp._get(url, callback)  
        return
    end

    local domain = string.match(url ,"^http://([%w_%-%.]+)")
    if domain ~= nil then 
        DnsPodHttp.getIp(domain, function(ip) 
            if ip == "" then
                --error
                DnsPodHttp._get(url, callback)     
            else
                --replace domain -> ip

                local newurl = string.gsub(url ,"^http://" .. domain, "http://" ..ip )

                DnsPodHttp._get(newurl, callback)   
            end
        end)
    else
        DnsPodHttp._get(url, callback)     
    end

end

function DnsPodHttp.getIp(domain, callback, withoutCache)
    if (not withoutCache)  and DnsPodHttp.dnsCache[domain] ~= nil and (FuncHelperUtil:getCurrentTime() - DnsPodHttp.dnsCache[domain]['start_time'] ) <= DnsPodHttp.dnsCacheMs  then
        callback(DnsPodHttp.dnsCache[domain]['ip'])    
        return
    end

    --if domain is pure ip?
    if string.match(domain, "^%d+%.%d+%.%d+%.%d+$") then
        callback(domain)   
        return
    end

    local url = "http://119.29.29.29/d?dn=" .. domain;
    
    DnsPodHttp._get(url, function(event) 
        local request = event.request
        local errorCode = request:getErrorCode()

        if errorCode ~= 0 then
            callback("") 
            return
        end

        local response = request:getResponseString()
        local ips = string.split(response, ";")
        if ips and #ips >= 1 and string.match(ips[1] ,"^(%d+%.%d+%.%d+%.%d+)") then
            DnsPodHttp.dnsCache[domain] = {start_time=FuncHelperUtil:getCurrentTime(), ip = ips[1]}
            callback(ips[1])
        else
            callback("")
        end
    end)
end


function DnsPodHttp._get(url, callback)
    -- print("dns pod url:" .. url)
    local request = uf_netManager:createHTTPRequestGet(url, function(event) 
        callback(event)
    end)
    request:start()
end


return DnsPodHttp



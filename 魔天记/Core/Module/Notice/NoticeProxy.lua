require "Core.Module.Pattern.Proxy"

NoticeProxy = Proxy:New();

NoticeType={ notice = 1, sales = 2, game = 3 }
NoticeTag={ new = "new", hot = "hot", boom = "boom" , nothing = ""}
local insert = table.insert
local _sortfunc = table.sort 

function NoticeProxy:OnRegister()
    
end
function NoticeProxy.GetNotices()
    local config = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_NOTICE);
    local time = tonumber(TimeUtil.GetTimeStr())
    --log( "lua: ct="..time ..",cdate=".. os.date())
    local ns = {}
    for k,v in pairs(config) do 
        local bt = tonumber(TimeUtil.GetTimeForStr(v.begin_time, "yyyy-MM-dd HH:mm:ss"))
        local tg = time - bt
        local et = tonumber(TimeUtil.GetTimeForStr(v.end_time, "yyyy-MM-dd HH:mm:ss"))
        --log(v.id .. ">id___tg="..tg .."_____bt="..bt..",et="..et)
        if tg > 0 and time < et then
            if v.type == NoticeType.notice then v.tag = NoticeTag.hot            
            elseif tg < 3 * Date.Day then v.tag = NoticeTag.new
            elseif tg < 11 * Date.Day then v.tag = NoticeTag.boom
            else v.tag = NoticeTag.nothing
            end
            insert(ns, v)
        end
    end
    _sortfunc(ns,function(c1, c2)
        if c1.order < c2.order then return true end
        return false
    end)
    return ns
end

function NoticeProxy:OnRemove()

end


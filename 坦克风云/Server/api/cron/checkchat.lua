-- 
-- 聊天监控-线上区服超过12个小时没有聊天信息进行报警（世界聊天），发送邮件提示
-- 每个小时检测userinfo注册人数 大于100 世界聊天log更新时间距当前小于12小时 发邮件
-- 
function api_cron_checkchat(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local function checktime(file,today)
        local last_line = nil
        for line in file:lines() do
            last_line = line
        end
        if not last_line then return true end
        
        local last = last_line:split(' ')
        local lasttb= last[1]:split(':')
       
        local hour = tonumber(lasttb[1]) or 0
        local min = tonumber(lasttb[2]) or 0
        local sec = tonumber(lasttb[3]) or 0      
       
        local opttime = os.time({year=today.year, month=today.month, day=today.day, hour=hour,min=min,sec=sec})
        local sytime = os.time()

        -- 国内的18个小时
        local internal = {"ship_3kwan","ship_3kwanios","ship_android","ship_yyb"}
        local plat = getClientPlat()
        local diftime  = 18*3600
        if not table.contains(internal,plat) then
            diftime = 24*3600
        end
        if sytime-opttime>diftime then
            return true
        end

        return false
    end
   
    local zoneid = getZoneId()
    local plat = getClientPlat()
    if zoneid>900 or plat=='def' then
        return false
    end

    local db = getDbo()
    local result = db:getRow("select count(*) as total from userinfo",{}) 
    local total = type(result)=='table' and tonumber(result.total) or 0
    local flag = false
    if total>100 then
        local cmdinfo = getRequestCmd()
        local cmd = cmdinfo[1]

        local config=getConfig("config.z"..zoneid)
        local chatUrl=config.chatUrl
        local chatport=tonumber(string.sub(chatUrl,string.len(chatUrl)-4,-2))
        
        local date = os.date('%Y%m%d')
        local path = '/opt/tankserver/game/gchatserver-node/log/'..(chatport-1)..'_channel.1.'..date..'.log'--世界聊天
        local file,err = io.open(path,"r+") 
        if not file then
            local yesterday = os.time()-86400
            date = os.date('%Y%m%d',yesterday)
            path = '/opt/tankserver/game/gchatserver-node/log/'..(chatport-1)..'_channel.1.'..date..'.log'
            file,err = io.open(path)
            if not file then
                flag = true
            else
                local today = {year=tonumber(os.date('%Y',yesterday)),month=tonumber(os.date('%m',yesterday)),day=tonumber(os.date('%d',yesterday))}
                flag = checktime(file,today)
            end 
        else
            local today = os.date("*t")
            flag = checktime(file,today)
        end   
    end

    if flag then
       local postdata = {
            plat = plat,--平台
            zid = zoneid,
            uid = 0,
            nickname = '系统',
            event = '线上区服超过12个小时没有聊天信息',
            cur = 0,--当前次数
            cmd = 'cron.checkchat',
            getnum = 0,
            ip = 0,--ip
            title='聊天监控',
        }

        sendqqemail(postdata)
    end

    response.ret=0
    response.msg ='Success'
    return response

end
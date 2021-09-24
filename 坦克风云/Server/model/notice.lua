local sysNotice = {}

function sysNotice:getNewNotice()    
    local ts = getClientTs()
    local st = ts + 7200

    local db = getDbo()
    local result = db:getAllRows("select * from notice where enabled = 'Y' and time_st <= :st and (time_end > :currTs or time_end = 0) order by id desc",{currTs=ts,st=st})

    -- print(db:getQueryString())
    
    if result then
        return result
    else
        return false
    end    
end

function sysNotice:getUnreadNotice(lasttime)
    local ts = getClientTs()
    lasttime = tonumber(lasttime) or 0

    local db = getDbo()
    -- local result = db:getAllRows("select * from notice where enabled = 'Y' and time_st <= :currTs and (time_end > :currTs or time_end = 0) and time_st > :lasttime",{currTs=ts,lasttime=lasttime})
    local result = db:getAllRows("select * from notice where enabled = 'Y' and time_st <= :currTs and (time_end > :currTs or time_end = 0) ",{currTs=ts,lasttime=lasttime})

    -- print(db:getQueryString())
    
    if result then
        return result
    else
        return false
    end 
end

function sysNotice:getUserNewNotice(mUserinfo,unread,appid,sys)
    if not appid then
        appid = 0
    end
    local notices = unread and self:getUnreadNotice(mUserinfo.flags.notice) or self:getNewNotice()
    local userNotices = {}
    local tmpUserNotices = {}
    local newNoticeNum = 0 -- 新公告
    -- for k,v in pairs(mUserinfo.flags.notice) do
    --     tmpUserNotices[v] = 1   
    -- end

    -- 1全服
    -- 2用户id
    -- 3等级
    -- 4主基地等级
    -- 5按注册时间
    if type(notices) == 'table' then
        local noticeType
        local baseLevel

        for k,v in pairs(notices) do
            local checkAppid = v.appid and tonumber(v.appid) or 0
            local checkFlag = checkAppid == 0 or appid == 0 or checkAppid == appid
            local nsys= v.sys or ''
            local checkSysFlag=true
            if nsys~=''  and  nsys~=0 and nsys~=sys   then checkSysFlag=false  end  
            if checkFlag and  checkSysFlag and  not tmpUserNotices[v.id] then
                
                noticeType = tonumber(v.type)

                if noticeType == 1 then
                    table.insert(userNotices,v)
                    -- 新公告
                    if unread and (tonumber(v.time_st) or 0) > (tonumber(mUserinfo.flags.notice) or 0)  then
                        newNoticeNum = newNoticeNum + 1
                    end
                elseif noticeType == 2 then
                    if mUserinfo.uid == tonumber(v.user_from) then
                        table.insert(userNotices,v)
                        -- 新公告
                        if unread and (tonumber(v.time_st) or 0) > (tonumber(mUserinfo.flags.notice) or 0)  then
                            newNoticeNum = newNoticeNum + 1
                        end

                    end
                elseif noticeType == 3 then
                    if mUserinfo.level >= (tonumber(v.user_from) or 0) and mUserinfo.level <= (tonumber(v.user_to) or 0) then
                        table.insert(userNotices,v)
                        -- 新公告
                        if unread and (tonumber(v.time_st) or 0) > (tonumber(mUserinfo.flags.notice) or 0)  then
                            newNoticeNum = newNoticeNum + 1
                        end

                    end
                elseif noticeType == 4 then
                    if not baseLevel then
                        local uobjs = getUserObjs(mUserinfo.uid,true) 
                        local mBuilding = uobjs.getModel('buildings')
                        baseLevel = mBuilding.getMainCityLevel()
                    end
                    if baseLevel >= (tonumber(v.user_from) or 0) and baseLevel <= (tonumber(v.user_to) or 0) then
                        table.insert(userNotices,v)
                        -- 新公告
                        if unread and (tonumber(v.time_st) or 0) > (tonumber(mUserinfo.flags.notice) or 0)  then
                            newNoticeNum = newNoticeNum + 1
                        end

                    end
                elseif noticeType == 5 then
                    if mUserinfo.regdate >= (tonumber(v.user_from) or 0) and mUserinfo.regdate <= (tonumber(v.user_to) or 0) then
                        table.insert(userNotices,v)
                        -- 新公告
                        if unread and (tonumber(v.time_st) or 0) > (tonumber(mUserinfo.flags.notice) or 0)  then
                            newNoticeNum = newNoticeNum + 1
                        end

                    end
                --vip限制邮件
                elseif noticeType == 6 then
                    if mUserinfo.vip >= (tonumber(v.user_from) or 0) and mUserinfo.vip <= (tonumber(v.user_to) or 0) then
                        table.insert(userNotices,v)
                        -- 新公告
                        if unread and (tonumber(v.time_st) or 0) > (tonumber(mUserinfo.flags.notice) or 0)  then
                            newNoticeNum = newNoticeNum + 1
                        end

                    end
                 --vip限制邮件
                elseif noticeType == 7 then
                    local st_arr = json.decode(v.user_from)
                    local et_arr = json.decode(v.user_to)
                    local l_st = tonumber(st_arr.level_st) or 0
                    local l_et = tonumber(et_arr.level_et) or 0
                    local v_st = tonumber(st_arr.vlevel_st) or 0
                    local v_et = tonumber(et_arr.vlevel_et) or 0
                    if mUserinfo.vip >= v_st and mUserinfo.vip <= v_et and mUserinfo.level >= l_st and mUserinfo.level <= l_et then
                        table.insert(userNotices,v)
                        -- 新公告
                        if unread and (tonumber(v.time_st) or 0) > (tonumber(mUserinfo.flags.notice) or 0)  then
                            newNoticeNum = newNoticeNum + 1
                        end

                    end
                end
            end
        end
    end
    return userNotices,newNoticeNum,#userNotices
end

function sysNotice:publicNotice(mUserinfo)
    local notices = self:getUserNewNotice(mUserinfo)
    local lastNid = {}
    local ts = getClientTs()

    if notices then
        for k,v in pairs(notices) do
            --mailSent(uid,sender,receiver,mail_from,mail_to,subject,content,mail_type,isRead)
            MAIL:mailSent(mUserinfo.uid,1,mUserinfo.uid,'',mUserinfo.nickname,v.title,v.content,1,0)     
            table.insert(lastNid,v.id)
        end
    end

    return lastNid
end

function sysNotice:getDisabledNotices()
    local ts = getClientTs()

    local db = getDbo()
    local result = db:getAllRows("select id from notice where enabled != 'Y' and time_st <= :currTs order by id",{currTs=ts})
    
    if type(result) == 'table' then
        local data = {}
        for k,v in pairs(result) do
            data[v.id] = 1
        end
        return data
    else
        return false
    end    
end

function sysNotice:getUserDisabledNotices(notices)
    if #notices < 1 then
        return {}
    end

    local ts = getClientTs() - 604800

    local db = getDbo()
    local result = db:getAllRows("select id from notice where id in (" .. table.concat(notices,',') .. ") and time_end <= :currTs",{currTs=ts})
    
    if type(result) == 'table' then
        local data = {}
        for k,v in pairs(result) do
            data[v.id] = 1
        end
        return data
    end    

end

function sysNotice:readNotice(nid)
    local db = getDbo()
    local result = db:getRow("select content from notice where id = :nid",{nid=nid})
    
    if type(result) == 'table' then        
        return result.content
    else
        return false
    end    
end

function sysNotice:compensationNotice(nid)
    local db = getDbo()
    local result = db:getRow("select * from notice where id = :nid and gift > 0 and enabled = 'Y' ",{nid=nid})
    
    if type(result) == 'table' then        
        return result
    else
        return false
    end    
end

return sysNotice
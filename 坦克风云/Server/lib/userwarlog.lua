-- 一元战场的事件
local userwarlogLib = {}
local userwarlogs={}

function userwarlogLib:getLog(round)
    return userwarlogs
end

--获取事件
function userwarlogLib:userList(uid,bid,maxeid,mineid)
    local db = getDbo()
    local page_rows = page_rows or 20
    local result = db:getAllRows("select id,uid,bid,content,update_at from userwarlog where uid=:uid  and bid=:bid and (id < :mineid or id > :maxeid) order by id desc limit ".. page_rows, {uid=uid,maxeid=maxeid,mineid=mineid,bid=bid})
    if result then
        return result
    else
        return {}
    end
end


--生成事件
-- uid  玩家id
-- type  事件的轮数
-- bid   本次的战斗id
-- content 事件内容
-- report  战报播发

function userwarlogLib:userSend(uid,round,bid,content,report)
    local db = getDbo()
    local lcontent=""
    local lreport=""
    if type(content)=='table' then
        lcontent=json.encode(content)
    end
    if type(report)=='table' then
        lreport=json.encode(report)
    end
    local logs={
        uid = tonumber(uid),
        round = tonumber(round),
        bid = bid,
        content=lcontent,
        report=lreport,
        update_at = getClientTs(),
    }


    local ret = db:insert('userwarlog',logs)
    if ret and ret > 0 then         
        logs.id = db.conn:getlastautoid()
        --logs.content=content
        --logs.report=nil
        --regSendMsg(uid,"userwar.event",{event=logs})
        --if tonumber(uid)==997000003 then
            --writeLog('userwar.event:'..json.encode({logs=logs}),'push')
        --end
        --[[local sms = {
            ret = 0,
            cmd = "userwar.event",
            msg='success',
            data = {event=logs},
            zoneid = getZoneId(),
            ts = getClientTs(),
        }
        --print(json.encode(sms))
        --sendMsgByUid(uid,json.encode(sms))
        ]]                    
        return logs.id
    end
     
    return false
end



function userwarlogLib:logCount(uid,bid)
    local db = getDbo()
    local count = 0
    local result = db:getRow("select max(round) as count from userwarlog where uid=:uid and bid=:bid ",{uid=uid,bid=bid})    
    if  type(result)=='table' and next(result) then
        count=result.count
    end
    return count
end
--获取播放战报
function userwarlogLib:userGet(id)
    local db = getDbo()
    local result = db:getRow("select report from userwarlog where  id=:id",{id=id})

    if result then  
        return json.decode(result.report)
    else
        return false
    end
end


-- 设置事件
-- uid  玩家id 
-- bid  战斗id
-- type 事件大类型 修正 探索等
-- status --玩家状态
-- action --  事件 or 行为
-- energy -- 行动力减少
-- point  -- 积分增减
-- subType -- 探索中的类型 
-- isHigh  -- 是否高级 
-- param   —参数，根据subType变化，subType为2是空table{p={p20=1,}},   —subType为1，  
-- round   -- 回合数
-- report  -- 战斗实践中的战报
function userwarlogLib:setEvent(uid,bid,stype,status,action,energy,point,subType,isHigh,param,round,report)
    param= param or {}
    energy=energy or 0
    local content={
        action,
        status,
        energy,
        point,
        subType,
        param,
        round,
        isHigh,
        
    }
    report=report or ""
    uid=tostring(uid)
    if type(userwarlogs[uid])~='table' then
        userwarlogs[uid]={}
    end

    local newcontent=userwarlogs[uid]['content'] or  {}
    local tmp={stype,content}
    table.insert(newcontent,tmp)
    userwarlogs[uid]['content']=newcontent
    userwarlogs[uid]['uid']=uid
    userwarlogs[uid]['bid']=bid
    userwarlogs[uid]['round']=round
    userwarlogs[uid]['report']=report
    return userwarlogs[uid]
    --return userwarlogLib:userSend(uid,type,bid,content,report)
end

function userwarlogLib:setRandEvent(uid,bid,round,btype,subType,status,param,push)
    uid=tostring(uid)
    if type(userwarlogs[uid])~='table' then
        userwarlogs[uid]={}
    end
    if tonumber(btype) ~= 100 then
        
        param= param or {}
        energy=energy or 0
        local content={
            2,
            status,
            0,
            0,
            subType,
            param,
            round,
            0,
        }
        
        report=report or ""

        local newcontent=userwarlogs[uid]['content'] or  {}
        local tmp={btype,content}
        table.insert(newcontent,tmp)
        userwarlogs[uid]['content']=newcontent
        userwarlogs[uid]['uid']=uid
        userwarlogs[uid]['bid']=bid
        userwarlogs[uid]['round']=round
        userwarlogs[uid]['report']=report
        
        if push then
            local sms = {
                ret = 0,
                cmd = "userwar.push",
                msg='success',
                data = {event = {tmp}},
                zoneid = getZoneId(),
                ts = getClientTs(),
            }
            sendMsgByUid(uid,json.encode(sms))
        end
    end
    return userwarlogs[uid]
end


function userwarlogLib:Commint(round,method)
    round=tostring(round)
    if type(userwarlogs)=='table' and next(userwarlogs) then
        for k,v in pairs(userwarlogs ) do
            if type(v)=='table' and next(v) then
                userwarlogLib:userSend(v.uid,v.round,v.bid,v.content,v.report)
            end
        end
        userwarlogs={}
    end
end

return userwarlogLib






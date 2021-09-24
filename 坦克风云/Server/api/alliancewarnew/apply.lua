-- 军团报名 
function api_alliancewarnew_apply(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid   = request.uid
    local point = tonumber (request.params.point) or 0
    local aid   = tonumber(request.params.aid) or 0
    local areaid= tonumber(request.params.areaid) or 0
    local date  = getWeeTs()
    if uid == nil or point == 0 or aid == 0 or areaid == 0 then
        response.ret = -102
        return response
    end
     
    if moduleIsEnabled('alliancewarnew') == 0 then
        response.ret = -4012
        return response
    end
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')
    if mUserinfo.alliance ~= aid then
        response.ret = -8023
        return response
    end

    local ts = getClientTs()
    local mAllianceWar = require "model.alliancewarnew"
    local warId = mAllianceWar.getWarId(areaid)
    local opts = mAllianceWar.getWarOpenTs(areaid)
    if not  mAllianceWar.isEnable() then
        response.ret = -4002
        return response
    end


    local allianceWarCfg = getConfig('allianceWar2Cfg')
    local ents = allianceWarCfg.signUpTime.finish[1]*3600+allianceWarCfg.signUpTime.finish[2]*60
    if (ts >=date+ents) then
        response.ret = -8053
        return response
    end

    if allianceWarCfg.minRegistrationFee> point then
       response.ret = -8042
       return response
    end

    local execRet, code = M_alliance.apply{uid=uid,aid=aid,point=point,date=date,areaid=areaid,warid=warId,apply_at=ts,ents=date+ents}
    
    if not execRet then
        response.ret = code
        return response
    end


     -- push -------------------------------------------------
    local mems = M_alliance.getMemberList{uid=uid,aid=aid}
    if mems then
        local cmd = 'alliancewarnew.memapplybattle'
        local data = {
                alliance = {
                    alliance={
                        commander = execRet.data.admin and execRet.data.admin.name,
                        members = {
                            
                        }
                    }
                }
            }

        if execRet.data.admin then
            table.insert(data.alliance.alliance.members,{uid=execRet.data.admin.uid,point=execRet.data.alliance.point,areaid=areaid})
        end

        for _,v in pairs( mems.data.members) do                        
            regSendMsg(v.uid,cmd,data)
        end
    end
    -- push -------------------------------------------------

    -- mail -------------------------------------------------
    --[[local mtype=9

    local content = {type=mtype,aName=execRet.data.alliance.name,point=execRet.data.alliance.point,usepoint=point,areaid=areaid}
    content = json.encode(content)
    MAIL:mailSent(uid,1,uid,'',mUserinfo.nickname,mtype,content,1,0)]]
    -- mail -------------------------------------------------
    --报名结束后定时发邮件把所有军团的排行1，2挤出来 剩下的把军团资金给退了.
    --发送开始战斗的定时脚本
    local send = execRet.data.send
    if(send ~=nil and send==1) then 
        local cronParams = {cmd ="alliancewarnew.sendbattlemsg",params={positionId=areaid,warId=warId}}

        if not(setGameCron(cronParams,(date+ents+5)-ts)) then
            setGameCron(cronParams,(date+ents+5)-ts) 
        end 
    end
    response.ret = 0
    response.msg = 'Success'
    response.data.areaid=areaid
    regStats('alliancebattle_daily',{aid=aid,point=point,areaid=areaid,apoint=execRet.data.alliance.point,name=execRet.data.alliance.name})
    response.data.point =execRet.data.alliance.point
    
    return response
   
end
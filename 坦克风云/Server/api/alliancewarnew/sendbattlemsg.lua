--军团战定时脚本发送邮件
function api_alliancewarnew_sendbattlemsg(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }


    local positionId = tonumber(request.params.positionId) -- 战场
    local date  = getWeeTs()
    local warId = request.params.warId
    local opents =tonumber(request.params.opents)
    local mAllianceWar = require "model.alliancewarnew"
    if warId==nil or opents==nil then

        
        warId = mAllianceWar.getWarId(positionId)
        opents = mAllianceWar.getWarOpenTs(positionId)
    end
   

    local execRet, code = M_alliance.sendbattlemsg{date=date,areaid=positionId,warId=warId,alliancewar=1}
    
    if not execRet then
        response.ret = code
        return response
    end


    local redmembers =execRet.data[1].members
    local redname =execRet.data[1].name
    local bluemembers={}
    local bluename=""
    if execRet.data[2] and type(execRet.data[2])=='table' then
        bluename =execRet.data[2].name
        bluemembers =execRet.data[2].members
        mAllianceWar.sendMsg(3,{opents.st,redname,bluename,positionId})
        
    end
    

    local uid = 1
    if type(redmembers)=="table"  and next(redmembers) then

        for _,n in pairs(redmembers) do
            local memuid = tonumber(n.uid)
               -- mail -------------------------------------------------
            local mtype=9

            local content = {type=mtype,redname=redname,bluename=bluename,opents=opents,alliancewarnew=1,pos="red",position=positionId}
            content = json.encode(content)
            MAIL:mailSent(memuid,1,memuid,'',n.name,mtype,content,1,0)
            uid=tonumber(n.uid)
            -- mail ------------------------------------------------- 

        end 

    end


    if type(bluemembers)=="table"  and next(bluemembers) then

        for _,n in pairs(bluemembers) do
            local memuid = tonumber(n.uid)
               -- mail -------------------------------------------------
            local mtype=9

            local content = {type=mtype,redname=redname,bluename=bluename,opents=opents,pos="blue"}
            content = json.encode(content)
            MAIL:mailSent(memuid,1,memuid,'',n.name,mtype,content,1,0)
            
            -- mail ------------------------------------------------- 

        end 

    end
       
    
    --军团活动收获日设置前十军团id
    if type(execRet.rank)=="table"  and uid >1000000 then
        activity_setopt(uid,'harvestDay',{alliance=execRet.rank})
    end

    response.ret = 0
    response.msg = 'Success'
    
    return response

    

end

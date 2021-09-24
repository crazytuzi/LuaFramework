function api_active_hardgetrichrank(request)
    local response = {
        ret=-1,
        msg="error",
        data={}
    }


    local uid = request.uid
    local rid= tostring(request.params.rid) or ''
    local uobjs = getUserObjs(uid)
       uobjs.load({"userinfo","useractive"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mUseractive = uobjs.getModel('useractive')


    local acname = "hardGetRich"

    -- 状态检测
    local activStatus = mUseractive.getActiveStatus(acname)
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local ranklist={}
    local r1 =''
    local r2 =''
    local r3 =''
    local r4 =''
    local gold=''

    local r1list =getActiveRanking(acname..'r1',mUseractive.info[acname].st)
    if type(r1list)=='table' and next(r1list) then
        for k,v in ipairs(r1list) do
            local uid = tonumber(v[1])
            if uid>0 then
                local uobjs = getUserObjs(uid,true)
                local userinfo = uobjs.getModel('userinfo')
                
                if k==1 then
                    r1=userinfo.nickname
                end 
                if rid~='r1' then
                    break
                end
                local item = {}   
                table.insert(item,userinfo.nickname)
                table.insert(item,(v[2] or 0))
                
                table.insert(ranklist,item)
            end    
        end
    end
    local r2list =getActiveRanking(acname..'r2',mUseractive.info[acname].st)
    if type(r2list)=='table' and next(r2list) then
        for k,v in ipairs(r2list) do
            local uid = tonumber(v[1])
            if uid>0 then
                local uobjs = getUserObjs(uid,true)
                local userinfo = uobjs.getModel('userinfo')
                
                if k==1 then
                    r2=userinfo.nickname
                end 
                if rid~='r2' then
                    break
                end
                local item = {}   
                table.insert(item,userinfo.nickname)
                table.insert(item,(v[2] or 0))
                
                table.insert(ranklist,item)
            end    
        end
    end
    local r3list =getActiveRanking(acname..'r3',mUseractive.info[acname].st)
    if type(r3list)=='table' and next(r3list) then
        for k,v in ipairs(r3list) do
            local uid = tonumber(v[1])
            if uid>0 then
                local uobjs = getUserObjs(uid,true)
                local userinfo = uobjs.getModel('userinfo')
                
                if k==1 then
                    r3=userinfo.nickname
                end 
                if rid~='r3' then
                    break
                end
                local item = {}   
                table.insert(item,userinfo.nickname)
                table.insert(item,(v[2] or 0))
                
                table.insert(ranklist,item)
            end    
        end
    end
    local r4list =getActiveRanking(acname..'r4',mUseractive.info[acname].st)
    if type(r4list)=='table' and  next(r4list) then
        for k,v in ipairs(r4list) do
            local uid = tonumber(v[1])
            if uid>0 then
                local uobjs = getUserObjs(uid,true)
                local userinfo = uobjs.getModel('userinfo')
                
                if k==1 then
                    r4=userinfo.nickname
                end 
                if rid~='r4' then
                    break
                end
                local item = {}   
                table.insert(item,userinfo.nickname)
                table.insert(item,(v[2] or 0))
                
                table.insert(ranklist,item)
            end    
        end
    end
    local goldlist =getActiveRanking(acname..'gold',mUseractive.info[acname].st)
    if type(goldlist)=='table' and next(goldlist) then
        for k,v in ipairs(goldlist) do
            local uid = tonumber(v[1])
            if uid>0 then
                local uobjs = getUserObjs(uid,true)
                local userinfo = uobjs.getModel('userinfo')
                
                if k==1 then
                    gold=userinfo.nickname
                end 
                if rid~='gold' then
                    break
                end
                local item = {}   
                table.insert(item,userinfo.nickname)
                table.insert(item,(v[2] or 0))
                
                table.insert(ranklist,item)
            end    
        end
    end

        

    response.ret = 0        
    response.msg = 'Success'
    response.data.firstname={r1,r2,r3,r4,gold}
    response.data.ranklist=ranklist
    return response 
end
function api_admin_updatemilitary(request)
    local response = {
            ret=-1,
            msg='error',
            data = {},
        }

    if type(request.params) ~= 'table' then
        response.ret = -102
        return response
    end
    local uid = request.uid
    local rank = math.abs(request.params.rank or 0)  
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task","userarena"})    

    local muserarena = uobjs.getModel('userarena')
    
    if rank==0  then
        return response
    end

    local defenderId=tonumber(getArenaUidByRank(rank))

    if not uid or defenderId <= 0 or rank <= 0  then
        response.ret = -102
        return response
    end


    local db = getDbo()
    db.conn:setautocommit(false)
    local myrank = muserarena.ranking
    if myrank <1 then
        return response
    end
    local dfuobjs=false
    if defenderId>1000000 then
        dfuobjs = getUserObjs(defenderId)
        dfuobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task","userarena"})    
        dmUserinfo = dfuobjs.getModel('userinfo')
        dmTroop = dfuobjs.getModel('troops')
        dmuserarena = dfuobjs.getModel('userarena')
        dmuserarena.ranking=myrank
    end

    muserarena.ranking=rank

    local flag 
    if uobjs.save() then  
        if  defenderId>1000000 and dfuobjs then
            if dfuobjs.save() and db.conn:commit() then
                flag = true
            end
        else
            if db.conn:commit() then
                flag = true
            end
        end  
       
    end


    if flag==true then

        --设置新的排名关系到缓存
    
        setArenaRanking(defenderId,myrank)
        
        setArenaRanking(uid,muserarena.ranking)
        response.ret = 0
        response.msg = 'Success'


    end

    return response

end
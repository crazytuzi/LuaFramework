function api_cron_attack(request)
    local response = {data={}}
    
    local cronId = request.params.cronid
    local target = request.params.target
    local attacker = request.params.attacker

    require "model.battle"
    local mBattle = model_battle()
    response.data.battle = mBattle.cronBattle(cronId,attacker,target)    

    if objM.save() then        
        response.ret = 0	    
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = 'Failed'
    end
    
    return response
end

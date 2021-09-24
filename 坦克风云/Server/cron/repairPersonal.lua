function api_test_repairPersonal()
   local response = {
        ret=-1,
        msg='error',
        data = {},
    }

      --返还鲜花的金币
    local config = getConfig("serverWarPersonalCfg")
    local gemConfig1 = config.betGem_1
    local gemConfig2 = config.betGem_2

    local function getGemsCost(gems, ggConfig)
        local result = 0
        for _,gemItem in pairs(ggConfig) do
            if gemItem <= gems then
                result = gemItem + result
            end
        end
        return result
    end

    local db = getDbo()
    local result = db:getAllRows('select uid,bet from crossinfo where bet like "%count%"')
    ptb:p(result)
    for i,v in pairs(result) do

        local uid = tonumber(v['uid'])
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","hero",'crossinfo'})
        local mUserinfo = uobjs.getModel('userinfo')
        local acrossinfo = uobjs.getModel('crossinfo')
        local addGems = 0
        local count = 0
        for ii,vv in pairs(acrossinfo.bet) do
            if type(vv) == "table" then
                for mmm, vvv in pairs(vv) do
                    if type(vvv) == "table" then
                        if vvv.type == 1 then
                            addGems = addGems + getGemsCost(gemConfig1[vvv.count], gemConfig1)
                        else
                            addGems = addGems + getGemsCost(gemConfig2[vvv.count], gemConfig2)
                        end
                        count = vvv.count
                    end
                end
            end
        end
        local oldGems = mUserinfo.gems
        ptb:p(addGems)

        if not takeReward(uid, {userinfo_gems=addGems}) then
            return  response
        end
        local newGems = mUserinfo.gems
        if addGems > 0 and uobjs.save() then
            writeLog("personalyazhu__"..uid.."__"..addGems.."__"..oldGems.."__"..newGems.."__"..count,"personalBet")
        end
    end
return response 
end
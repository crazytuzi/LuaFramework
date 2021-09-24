--建筑自动升级
function api_admin_chgacc(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local hit = {"a67", "a71", "a75", "a79", "a83", "a87", "a91", "a95"}
    local uids = { 1000857,
                1001449,
                1003931,
                1007679,
                1013282,
                1014285,
                1015059,
                1019848,
                2002841,
                2006023,
                2009032,
                2010951,
                2011177,
                2022096,
                2025058,
                }
    --local uids = {3002442}

    local self = {}
    --命中
    function self.in_arry( keyAcc )
        -- body
        for k, value in pairs(hit) do
            if keyAcc == value then
                return true
            end
        end

        return false
    end

    --拆卸身上的， 添加到仓库
    function self.work( )
        -- body
        for k, uid in pairs(uids) do 
            print( ' ---------start--------- ' .. uid)
            local uobjs = getUserObjs(tonumber(uid))
            uobjs.load({"accessory"})
            local mAcc = uobjs.getModel('accessory')
            writeLog(" uid : " .. uid , 'acc' )
            for kType, vType in pairs(mAcc.used) do
                for kPart, vPart in pairs(vType) do 
                    if self.in_arry(vPart[1]) then
                        print( '   find : ' .. vPart[1])
                       local eid, acc = mAcc.removeUsedAccessory(kType, kPart)
                       writeLog(acc , 'acc' )
                       print("      remove :  " .. eid)
                    end
                end
            end
            
            if uobjs.save() then
                print('  succ : ' ..  uid )
                writeLog('------succ--------- ' .. uid , 'acc' )
            end 
                       
        end     

    end


    --------------------------main---------------------------------

    self.work()

    response.msg ='succ'
    response.ret = 1

    return response
end

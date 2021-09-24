-- 刷新叛军
function api_map_refreshrebel(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    -- 叛军是否已开
    if not switchIsEnabled('acerebel') then
        response.ret = 0
        response.err = "switch not enable"
        response.msg = 'Success'
        return response
    end

    local mRebel = loadModel("model.rebelforces")

    if not mRebel.canRefresh() then
        response.error = "can not refresh"
        return response
    end

    -- 清除过期的叛军
    local cleanCount,worldRebelExp,reduceExp = mRebel:cleanExpireRebeForces()

    -- 刷新叛军
    local newRebels = mRebel:refreshRebelForces()

    -- 记一下日志
    writeLog{
        newRebels=newRebels,
        cleanCount=cleanCount,
        worldRebelExp=worldRebelExp,
        reduceExp=reduceExp
    }

    response.ret = 0
    response.msg = 'Success'

    return response
end

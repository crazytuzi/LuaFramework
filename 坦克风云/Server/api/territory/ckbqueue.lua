--  升级、建造定时任务
function api_territory_ckbqueue(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local aid = request.params.aid
    if aid == nil then return response end
    local lockkey = 'api_territory_ckbqueue'
    if not commonLock(aid,lockkey) then
        response.ret = 0
        return response
    end

    response.ret = 0
    local mAterritory = getModelObjs("aterritory",aid)
    local db = getDbo()
    db.conn:setautocommit(false)    

    -- 此处需要有返回值 并调用发送消息
    local updata = mAterritory.update()
    if type(updata)=='table' and next(updata) then
        -- 发消息
        local upflag = false
        for k,v in pairs(updata) do
            upflag = mAterritory.updateTerritoryMapLevel(v.bid,v.lv)
            if not upflag then
                 writeLog('建筑升级定时任务 更新地图失败：aid='..aid..'bid='..v.bid..'level='..v.lv,'territory')
                return response
            end
            mAterritory.upgradeBroadcast(v.bid,v.lv)
            writeLog('建筑升级定时任务：aid='..aid..'bid='..v.bid..'level='..v.lv,'territory')
        end

        local sflag=mAterritory.saveData()
        if sflag and upflag  then
            db.conn:commit()
            writeLog('建筑升级定时任务成功：aid='..aid..'data='..json.encode(updata),'territory')
        else
            writeLog('建筑升级定时任务失败 回滚：aid='..aid..'data='..json.encode(updata),'territory')
            db.conn:rollback()
        end
    end

    commonUnlock(aid,lockkey)

    response.msg ='Success'
    return response

end
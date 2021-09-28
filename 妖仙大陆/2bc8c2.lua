local VS = {}

function VS.requestPlayerInfo(playerId, cb, failCb)
    Pomelo.PlayerHandler.lookUpOtherPlayerRequest(playerId, 1, function (ex,json)
        if not ex then
            local data = json:ToData()
            
            cb(data.s2c_data)
        else
            failCb()
        end
    end,
    XmdsNetManage.PackExtData.New(false, false, failCb)
    )
end

function VS.requestPlayerAttrsInfo(playerId, cb, failCb)
    Pomelo.PlayerHandler.lookUpOtherPlayerRequest(playerId, 2, function (ex,json)
        if not ex then
            local data = json:ToData()
            
            cb(data.s2c_data)
        else
            failCb()
        end
    end,
    XmdsNetManage.PackExtData.New(false, false, failCb)
    )
end


return VS

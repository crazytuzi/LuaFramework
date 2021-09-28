local SubMapModel  = {}
SubMapModel.buyRawData = nil
SubMapModel.levelData  = nil


SubMapModel.curlevelId = 1
function SubMapModel.setRestNum(num)
    SubMapModel.buyRawData["2"].surplusCnt = num
    --设置剩余次数
end

function SubMapModel.getQiangGongNum()
    return SubMapModel.buyRawData.num

end

function SubMapModel.getCost()
    return SubMapModel.buyRawData.spend
end

function SubMapModel.isEnoughGold()
    if SubMapModel.buyRawData.spend > SubMapModel.buyRawData.gold then
        return false
    else
        return true
    end
end

function SubMapModel.isEnoughQiangGong()
    if SubMapModel.getQiangGongNum() > 0 then
        return true
    else
        return false
    end
end

function SubMapModel.getLianZhanNum()
    local _lianzhanCnt = SubMapModel.levelData.lianzhan
    if _lianzhanCnt > SubMapModel.getRestNum() then
       _lianzhanCnt = SubMapModel.getRestNum()
    end

    return _lianzhanCnt
end




function SubMapModel.sendBuy(param)
     RequestHelper.buyBatTimes({
        id = SubMapModel.curlevelId,
        act = 2,
        callback = function(data)
            print("buyRes")
            dump(data)  
            SubMapModel.buyRawData = data.rtnObj          
            param.callback() 
        end,
        errback = function ()
            -- device.showAlert("","")
            param.errorCB()
        end
        }) 
end

function SubMapModel.getRestNum()
   return SubMapModel.buyRawData.surplusCnt
end



function SubMapModel.sendPreview(param)
    RequestHelper.buyBatTimes({
        id = SubMapModel.curlevelId,
        act = 1,
        callback = function(data)
            print("preview")
            dump(data)
            SubMapModel.buyRawData = data.rtnObj
            param.callback() 
        end,
        errback = function ()
            
            param.errorCB()
        end
        }) 
end


return SubMapModel 
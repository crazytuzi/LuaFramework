local JingYingModel  = {}
JingYingModel.rawData = nil

function JingYingModel.setRestNum(num)
    JingYingModel.rawData["2"].surplusCnt = num
    --设置剩余次数
end

function JingYingModel.getRestNum()
    --剩余次数
    return JingYingModel.rawData["2"].surplusCnt
end

function JingYingModel.getCost()
    return JingYingModel.rawData["2"].spend
end

function JingYingModel.initData(data)
    JingYingModel.rawData = data
    JingYingModel.refreshGold(data.gold)

end

function JingYingModel.refreshGold(num)
    if num ~= nil then
        if game.player.m_gold ~= num then
            game.player.m_gold = num
            PostNotice(NoticeKey.CommonUpdate_Label_Gold)
        end
    end
end

function JingYingModel.getGold()
    return game.player.m_gold
end

function JingYingModel.buySuccess(data)
    print("buySuccess")
    dump(data)
   local rtnObj = data.rtnObj
    JingYingModel.rawData["2"].surplusCnt = rtnObj.surplusCnt
    JingYingModel.rawData["2"].buyCnt     = rtnObj.buyCnt
    JingYingModel.refreshGold(rtnObj.gold)
    JingYingModel.rawData["2"].spend = rtnObj.spend
end

function JingYingModel.getBuyCnt()
    return JingYingModel.rawData["2"].buyCnt
end

-- function JingYingModel.getItemId()
--     return JingYingModel.rawData["2"].itemId
-- end

-- function JingYingModel.getItemNum()
--     return JingYingModel.rawData["2"].num
-- end

function JingYingModel.getMaxLv()
    return JingYingModel.rawData["1"]
end

function JingYingModel.getLimit()
    return JingYingModel.rawData["2"].limit
end 	


return JingYingModel 
local HuoDongFuBenModel  = {}
-- HuoDongFuBenModel.rawData = nil

function HuoDongFuBenModel.setRestNum(id, num) 
    --设置剩余次数
    local fubenData = HuoDongFuBenModel.getFubenData(id)
    fubenData.surplusCnt = num 
end

function HuoDongFuBenModel.getRestNum(id)
    --剩余次数
    local fubenData = HuoDongFuBenModel.getFubenData(id)
    return fubenData.surplusCnt
end

-- function HuoDongFuBenModel.getCost()
--     return HuoDongFuBenModel.rawData["2"].spend
-- end

function HuoDongFuBenModel.getFubenData(id)
    -- body
    return HuoDongFuBenModel.rawData["1"][tostring(id)]
end

function HuoDongFuBenModel.getItemID(id)
    local fubenData = HuoDongFuBenModel.getFubenData(id)
    return fubenData.itemId
    -- body
end

function HuoDongFuBenModel.getItemNum(id)    
    local fubenData = HuoDongFuBenModel.getFubenData(id)
    return fubenData.num
end



function HuoDongFuBenModel.initData(data)
    HuoDongFuBenModel.rawData = data

    if data.gold ~= nil then
        game.player.m_gold = data.gold
    end
end

function HuoDongFuBenModel.getBuyCnt()
    return HuoDongFuBenModel.rawData["2"].buyCnt
end







function HuoDongFuBenModel.getLimit()
    return HuoDongFuBenModel.rawData["2"].limit
end


function  HuoDongFuBenModel.getFubenList()
    return HuoDongFuBenModel.rawData["1"]
end


return HuoDongFuBenModel 
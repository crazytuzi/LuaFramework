local LimitHeroModel  = {}

LimitHeroModel.rawData = nil 
function LimitHeroModel.sendInitRes(param)
    RequestHelper.getLimitInitData({
        callback = function(data)

            LimitHeroModel.rawData = data.rtnObj
            LimitHeroModel.init()
            param.callback()
        end
        })
end

function LimitHeroModel.init()
    local rawData = LimitHeroModel.rawData
    -- dump(rawData)

    LimitHeroModel.actEndTime = function() 
        return rawData.act_end_time
    end

    LimitHeroModel.actStartTime = function()
        return rawData.act_start_time
    end 

    LimitHeroModel.actEndTime_inMS = function()
        return rawData.actEndTime_inMS
    end

    LimitHeroModel.actRestTime = function() 
        return rawData.act_rest_time
    end

    LimitHeroModel.freeRestTime = function() 
        return rawData.free_rest_time
    end

    LimitHeroModel.costGold = function() 
        return rawData.gold_cost
    end


    LimitHeroModel.heroList = {} 
    for i = 1,3 do
        if rawData.lcb["card"..i] ~= 0 then
            LimitHeroModel.heroList[#LimitHeroModel.heroList + 1] = rawData.lcb["card"..i]
        end
    end

    LimitHeroModel.rewardList = {}
    for i = 1,4 do
        LimitHeroModel.rewardList[#LimitHeroModel.rewardList + 1] = rawData.lcb["reward"..i]
    end

    LimitHeroModel.luckNum = function() 
        return rawData.luck_num
    end

    LimitHeroModel.maxLuckNum = function() 
        return rawData.max_luck_num
    end

    LimitHeroModel.playerRank = function() 
        return rawData.player_rank
    end

    LimitHeroModel.getModifiedPlayerRank = function()
        local rankText = "1000名以外"
        local fontSize = 16
        if LimitHeroModel.playerRank() < 1000 then
            rankText = LimitHeroModel.playerRank()
            fontSize = 20
        end
        return rankText,fontSize
    end

    LimitHeroModel.playerScore = function() 
        return rawData.player_score
    end

    LimitHeroModel.restLuckNum = function() 
        return rawData.rest_luck_num
    end

    LimitHeroModel.rankList = function() 
        return rawData.rlblist
    end

    LimitHeroModel.rawData.oldLuck = rawData.luck_num

end

function LimitHeroModel.getScore()
    return LimitHeroModel.rawData.get_score
end



function LimitHeroModel.sendFreeDraw(param)
    RequestHelper.drawLimitHero({
        isFree = 1,
        callback = function(data)   
        print("fffffrrrreeeedraw")
            dump(data)
            LimitHeroModel.updateData(data)
   
            param.callback(data)
        end
        })

end

function LimitHeroModel.updateData(data)
   local cbData = data.rtnObj
   LimitHeroModel.rawData.oldLuck = LimitHeroModel.luckNum()

   for k,v in pairs(cbData) do
        LimitHeroModel.rawData[k] = v
    end 

end

function LimitHeroModel.getLuckNumThisTime()
    return  LimitHeroModel.luckNum() - LimitHeroModel.rawData.oldLuck
end

function LimitHeroModel.getHeroList()

    return LimitHeroModel.heroList
end




function LimitHeroModel.sendGoldDraw(param)
     RequestHelper.drawLimitHero({
        isFree = 0,
        callback = function(data)
            print("goldddddeeeedraw")
            dump(data)
            game.player.m_gold = game.player.m_gold - LimitHeroModel.costGold()
            LimitHeroModel.updateData(data)
            param.callback()
        end
        })
end

function LimitHeroModel.drawedHero()
    return LimitHeroModel.rawData.probItem
end

LimitHeroModel.isFreeAllowFreeDraw = false
function LimitHeroModel.getIsAllowFreeDraw()
    return LimitHeroModel.isFreeAllowFreeDraw
end

function LimitHeroModel.isAllowGoldDraw()
    if game.player.m_gold < LimitHeroModel.costGold() then
        return false
    else 
        return true
    end
end

return LimitHeroModel 
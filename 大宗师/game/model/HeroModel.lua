

local HeroModel = {}
	HeroModel.totalTable = {}
	-- HeroModel.sellTable = {}
    HeroModel.sellAbleData = nil

    HeroModel.debrisData = nil

HeroModel.expandCost = nil

HeroModel.soulList = {}

function HeroModel.sendHeroReq(param)
    RequestHelper.getHeroList({
        callback = function(data)            
            HeroModel.expandCost = {data["4"], data["5"]}
            HeroModel.setHeroTable(data["1"])
            param.callback()
    end})
end

function HeroModel.sendSoulReq(param)
    RequestHelper.getHeroDebrisList({
        callback = function(listData)
             HeroModel.soulList = listData["1"]
             param.callback()
        end})
end

function HeroModel.sendSellCardReq(param)
    RequestHelper.sendSellCardRes({
        callback = function(data)
            show_tip_label("出售成功,获得"..data["1"][1].."银币")
            game.player.m_silver=data["1"][2]
            PostNotice(NoticeKey.MainMenuScene_Update)
            PostNotice(NoticeKey.CommonUpdate_Label_Silver)
            param.callback()
        end,
        ids = param.sellStr
        })
end



function HeroModel.getCellValue(cellData,showRelation)

    local _showRelation = showRelation 

    local maxNum = 4000000
    local cellValue = 0
    if cellData.pos ~= nil and cellData.pos > 0 then
        cellValue = cellValue + maxNum
    end

    if _showRelation ~= 0 then 
        if cellData.relation ~= nil and #cellData.relation > 0  then
            cellValue = cellValue + maxNum/10
        end
    end

    if cellData.resId == 1 or cellData.resId == 2 then
        cellValue = cellValue + 1000000000
    end    

    local cardStaticData = ResMgr.getCardData(cellData.resId)
    --资质
    cellValue = cellValue + maxNum/(100*15)*cardStaticData.arr_zizhi[cellData.cls+1]


    --进阶等级
     cellValue = cellValue + maxNum/(1000*7) * cellData.cls--*maxNum/(32*7)

    --强化等级
    cellValue = cellValue + maxNum/10000 * cellData.level/100--*maxNum/(64*100)

     
    cellValue = cellValue + cellData.resId/100000

    -- print("cellValue "..cellValue)

    return cellValue
end

function HeroModel.getHeroChoseValue(cellData)
    local heroData = cellData.data
    return HeroModel.getCellValue(heroData,0)
end

function HeroModel.sortHeroChose(cellTable)
    table.sort(cellTable, function(a, b)
        return (HeroModel.getHeroChoseValue(a) > HeroModel.getHeroChoseValue(b))
    end)
end


function HeroModel.setHeroTable(cellTable)
    HeroModel.totalTable = cellTable
    HeroModel.sort(HeroModel.totalTable)
end

function HeroModel.sort( cellTable, reverse )
    
    table.sort(cellTable, function(a, b)
        if(reverse == true) then
            return (HeroModel.getCellValue(a) < HeroModel.getCellValue(b))
        else
            return (HeroModel.getCellValue(a) > HeroModel.getCellValue(b))
        end
     end)
end

function HeroModel.getSellAbleTable()
	local sellList = {}
     --过滤一下 将可以出售的留下
    for i = 1, #HeroModel.totalTable do         
        local resId =   HeroModel.totalTable[i].resId   
        local heroData = ResMgr.getCardData(resId)
        if heroData.sale == 1 then --策划表里配的 让卖的才能卖
            if HeroModel.totalTable[i].cls == 0  then --进阶+1及以上的不能卖
                if HeroModel.totalTable[i]["pos"] == 0 then --上阵的不能卖 --男女主角不能卖 --小伙伴不能卖
                    if HeroModel.totalTable[i]["lock"] ~= 1 then --被锁住的不能卖
                        sellList[#sellList + 1 ] = HeroModel.totalTable[i]
                    end
                end
            end
        end
    end
    HeroModel.sellAbleData = sellList
    return sellList
end

return HeroModel
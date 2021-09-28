module ("NewActiveUtil", package.seeall)

function sortRewardData()
    -- body
    local activeData = {}
    table.hcopy(NewActiveData.getData(),activeData)
    local status0Table = {}
    local status1Table = {}
    local status2Table = {}
    local rewardData = activeData.config.reward
    for k,v in pairs(rewardData)do
        if(tonumber(v.status)==0)then
            table.insert(status0Table,v)
        elseif(tonumber(v.status)==1)then
            table.insert(status1Table,v)
        else
            table.insert(status2Table,v)
        end
    end

    local function keySort0 ( status0Table1, status0Table2 )
        if(tonumber(status0Table1.num) < tonumber(status0Table2.num))then
            return true
        end
    end
    
    table.sort(status0Table,keySort0)

    local function keySort1 ( status1Table1, status1Table2 )
        if(tonumber(status1Table1.num) < tonumber(status1Table2.num))then
            return true
        end
    end
    
    table.sort(status1Table,keySort1)

    local function keySort2 ( status2Table1, status2Table2 )
        if(tonumber(status2Table1.num) < tonumber(status2Table2.num))then
            return true
        end
    end
    
    table.sort(status2Table,keySort2)
    local dataCache = {}
    for k,v in pairs(status0Table)do
        table.insert(dataCache,v)
    end

    for k,v in pairs(status1Table)do
        table.insert(dataCache,v)
    end

    for k,v in pairs(status2Table)do
        table.insert(dataCache,v)
    end
    local activeDataCopy = activeData
    activeDataCopy.config.reward = dataCache
    local pData = NewActiveData.getData()
  
    return activeDataCopy
end
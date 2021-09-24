 -- 地图热度配置
 -- maxHeat 热度上限
 -- point4Lv 热度分数对应的等级
 -- resourceSpeed 热度等级对应的资源采集速度加成比率
 -- pointIncrSpeed 热度分数增长速度X秒增加1
 -- pointDecrSpeed 热度分数减少速度X秒减少1
 -- lossValue 矿被抢或者从矿撤离后损失的热度分值比率
 -- attributeUp 等级对应的部队属性加成
local function returnCfg(clientPlat)
	local commonCfg={
		maxHeat={200,600,2000,4000,},
		point4Lv={150,450,1500,3000,},
		resourceSpeed={0.5,1,1.5,2,},
		pointIncrSpeed=80,
		pointDecrSpeed=20,
		lossValue=0.05,
	}

	local limit = {
        maxHeat = "mapHeatlevel" ,
        point4Lv = "mapHeatlevel",
    }

    if clientPlat ~= 'def' then
        if platCfg and type(platCfg[clientPlat]) == 'table' then
            for k,v in pairs(platCfg[clientPlat]) do
                commonCfg[k] = v
            end
        end

        if limit then
            local versionCfg =getVersionCfg()
            if versionCfg then
                for k,v in pairs(limit) do
                    if versionCfg[v] then
                        local max = #commonCfg[k]
                        if max > versionCfg[v] then
                            local startKey = versionCfg[v] + 1
                            for i=1,max-versionCfg[v] do
                                table.remove(commonCfg[k],startKey)
                            end
                        end
                    end
                end
            end
        end
    end

	return commonCfg
end

return returnCfg
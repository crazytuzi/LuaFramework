--[[
    文件名: PvpResult.lua
	描述: Pvp 战斗结果
	创建人: suntao
	创建时间: 2016.06.20
-- ]]

PvpResult = {}

-- 转到战斗结算页面, 支持的模块：eChallengeGrab、eChallengeArena、eChallengeWrestle、ePVPInter、eTeambattle
--[[
-- 暂未进行数据容错处理，请保证数据正确
	moduleSub			进行结算的模块
	serverData			服务器返回的战斗结果
	myInfo				我方信息（姓名 PlayerName, 战力 FAP, 获得星数(目前只有帮派战才会有)GetStar）
	enemyInfo			敌方信息（姓名 PlayerName, 战力 FAP, 玩家ID PlayerId）
--]]
function PvpResult.showPvpResultLayer(moduleSub, serverData, myInfo, enemyInfo)
    --serverData.FightInfo = nil
    --dump(serverData)
    -- 测试
    if DEBUG_S then
        serverData.IsWin = 0
        --serverData.IsWinLootSuccess = 0
        serverData.ChoiceGetGameResource = {    
            [1] = {
                Num = 3000,
                ModelId = 0,
                IsDrop = 1,
                ResourceTypeSub = 1112,
            },
            [2] = {
                ModelId = 13060101,
                Num = 1,
                IsDrop = 0,
                ResourceTypeSub = 1306,
            },
            [3] = {
                Num = 1000,
                ModelId = 0,
                IsDrop = 0,
                ResourceTypeSub = 1117,
            },
        }
        serverData.AddIntegral = 50
    end

    -- 特殊模块
    if moduleSub == ModuleSub.eTeambattle then
        serverData.IsWin = serverData.IsWin or serverData.FightInfo.IsWin
    end
    local dataType = type(serverData.IsWin)
    if dataType == "boolean" then
        dataType = true
    elseif dataType == "number" then
        dataType = 1
    end
    local layer
	if serverData.IsWin == dataType then
		-- 胜利
    	layer = LayerManager.addLayer({
    		name = "fightResult.PvpWinLayer",
    		cleanUp = false,
    		data = {
    			battleType = moduleSub, 
				result = serverData,
                myInfo = myInfo, 
                enemyInfo = enemyInfo or {},
    		},
            zOrder = Enums.ZOrderType.eWeakPop
    	})
    else
    	--失败
    	layer = LayerManager.addLayer({
    		name = "fightResult.PvpLoseLayer",
    		cleanUp = false,
    		data = {
    			battleType = moduleSub, 
				result = serverData,
                myInfo = myInfo, 
                enemyInfo = enemyInfo or {},
    		},
            zOrder = Enums.ZOrderType.eWeakPop
    	})
    end

    -- 
    ResultUtility.beforeTheEnd(layer)
    
    -- 检查是否升级
    PlayerAttrObj:showUpdateLayer()
end

return PvpResult

--[[
    文件名: CheckPve.lua
	描述: 校验 Pve 战斗结果
	创建人: liaoyuangang
	创建时间: 2016.06.10
-- ]]

CheckPve = {}

-- 处理普通副本服务器返回的校验数据
-- 当前支持模块：GGZJ、BDD、XXBZ、BattleNormal、BattleElite、BattleBoss
local function addResultLayer(moduleSub, serverData, starLv, myInfo, enemyInfo, extraData)
    --serverData.FightInfo = nil
    --dump(serverData)

    local pveWinLayer
    local layer
    if serverData.IsWin then
    	pveWinLayer = LayerManager.addLayer({
    		name = "fightResult.PveWinLayer",
    		cleanUp = false,
    		data = {
    			battleType = moduleSub,
				starCount = starLv,
				result = serverData,
                myInfo = myInfo,
                enemyInfo = enemyInfo,
                extraData = extraData,
    		},
            zOrder = Enums.ZOrderType.eWeakPop
    	})
        layer = pveWinLayer
    else
        -- 激活江湖悬赏失败后特殊引导
        if moduleSub == ModuleSub.eXrxs then
            Guide.manager:activeGuideManually(23)
        end
    	layer = LayerManager.addLayer({
    		name = "fightResult.PveLoseLayer",
    		cleanUp = false,
    		data = {
    			battleType = moduleSub,
				starCount = starLv,
				result = serverData,
                myInfo = myInfo,
                enemyInfo = enemyInfo,
                extraData = extraData,
    		},
            zOrder = Enums.ZOrderType.eWeakPop
    	})
    end

    --
    ResultUtility.beforeTheEnd(layer, function()
        -- 检查是否升级
        PlayerAttrObj:showUpdateLayer(function()
            -- 点击关闭之后执行战斗结算页面引导
            local _, _, eventID = Guide.manager:getGuideInfo()
            -- 此处引导需要静音(PveWinLayer弹出时已经播放过一次音效)
            return pveWinLayer and pveWinLayer:executeGuide(true)
        end)
    end)
end

-- 校验普通副本战斗结果
--[[
-- 参数
	fightResult: 战斗结果
	guideInfo: 额外信息，主要是新手引导的信息
]]
function CheckPve.battleNormal(chapterId, nodeId, starLv, fightData, guideInfo)
    if DEBUG_S then
        -- 测试
        local value = {
            IsWin = false,
            BaseGetGameResourceList = {
                [1] = {
                    PlayerAttr = {
                        [1] = {
                            ResourceTypeSub = 1112,
                            Num = 50,
                        },
                        [2] = {
                            ResourceTypeSub = 1101,
                            Num = 430,
                        },
                        [3] = {
                            ResourceTypeSub = 1117,
                            Num = 25,
                        },
                    },
                    Equip = {
                        [1] = {
                            Step = 0,
                            Lv = 0,
                            Id = "d877c1ea-d3cb-48e4-a94d-a2c27eb9316d",
                            GemId = "00000000-0000-0000-0000-000000000000",
                            GemModelID = 0,
                            EquipModelId = 13010221,
                        },
                    },
                },
            },
        }
        addResultLayer(ModuleSub.eBattleNormal, value, starLv)
        return
    end
    -- 如果是自动战斗，需要把当前所在的章节信息更新到 LayerManager 的堆栈信息中去
    if AutoFightObj:getAutoFight() then
        local tempStr = "battle.BattleNormalNodeLayer"
        local tempData = LayerManager.getRestoreData(tempStr)
        tempData = tempData or {}
        tempData.chapterId = chapterId
        LayerManager.setRestoreData(tempStr, tempData)
    end
	---------------- 是否有战斗后剧情 ---------------------
    if not fightData.result then
        guideInfo = nil -- 战斗失败不上传步骤
    else
        local guideID, ordinal, eventID = Guide.manager:getGuideInfoByType(GuideTriggerType.eBattleNodeOrdinalEnd, nodeId)
        if eventID and ordinal == 1 then  -- 战斗胜利 、引导还在进行中
            if guideInfo then
                table.insert(guideInfo, {
                    GuideId = tostring(guideID),
                    Ordinal = ordinal,
                })
            else
                guideInfo = Guide.manager:makeExtentionData(guideID, ordinal)
            end
        end
    end
    --------------------------------------------------------
    local isBreak = fightData.skipCallback ~= nil and fightData.skipCallback ~= false
    BattleObj:requestFight(chapterId, nodeId, starLv, fightData.result, fightData.data, isBreak, guideInfo, function(response)
    	if not response or response.Status ~= 0 then
            -- 删除战斗页面
            LayerManager.removeTopLayer(true)
    		return
    	end

    	local value = response.Value
    	if fightData.skipCallback then
    		fightData.skipCallback(value.IsWin, value.TargetCsHp)
    	end

    	if not value.IsWin then
    		-- 记录战斗失败的节点
    		AutoFightObj:setFailedNode(nodeId)

    		addResultLayer(ModuleSub.eBattleNormal, value, starLv)
    		return
    	end

    	--[[--------新手引导--------]]--
        CheckPve.executeGuide()

        -- 战斗后剧情
        local function __proc()
            local guideID, ordinal, typeEventID = Guide.manager:getGuideInfoByType(GuideTriggerType.eBattleNodeOrdinalEnd, nodeId)
            if not typeEventID then
                addResultLayer(ModuleSub.eBattleNormal, value, starLv)
                return
            end
            -- 战斗后剧情
            Guide.manager:showAfterBattleGuide(nodeId, function()
                addResultLayer(ModuleSub.eBattleNormal, value, starLv)
            end)
        end

        __proc()
    end)
end

function CheckPve.executeGuide()
    local _, _, eventID = Guide.manager:getGuideInfo()
    if table.indexof(Guide.config.battleEvent, eventID) then
        Guide.manager:nextStep(eventID, true)
    end
end

-- 校验精英副本战斗结果
function CheckPve.BattleElite(nodeId, fightData, extData)
    if DEBUG_S then
        -- 测试
        local value = {
            IsWin = false,
            BaseGetGameResourceList = {
                [1] = {
                    Goods = {
                        [1] = {
                            Num = 1,
                            ResourceTypeSub = 1604,
                            GoodsModelId = 16040002,
                        },
                        [2] = {
                            Num = 10,
                            ResourceTypeSub = 1605,
                            GoodsModelId = 16050001,
                        },
                        [3] = {
                            Num = 2,
                            ResourceTypeSub = 1605,
                            GoodsModelId = 16050011,
                        },
                    },
                    PlayerAttr = {
                        [1] = {
                            ResourceTypeSub = 1112,
                            Num = 4500,
                        },
                        [2] = {
                            ResourceTypeSub = 1111,
                            Num = 50,
                        },
                        [3] = {
                            ResourceTypeSub = 1117,
                            Num = 3800,
                        },
                    },
                },
            },
        }
        addResultLayer(ModuleSub.eBattleElite, value, 0, nil, nil, extraData)
        return
    end


	local isBreak = fightData.skipCallback ~= nil and fightData.skipCallback ~= false
    BattleObj:requestEliteFight(nodeId, fightData.result, fightData.data, isBreak, function(response)
        if not response or response.Status ~= 0 then
            -- 删除战斗页面
            LayerManager.removeTopLayer(true)
            return
        end

        local value = response.Value
        if fightData.skipCallback then
            fightData.skipCallback(value.IsWin, value.TargetCsHp)
        end

        addResultLayer(ModuleSub.eBattleElite, value)
    end)
end

-- 校验挑战妖王战斗结果
function CheckPve.BattleBoss(bossId, isfullFight, fightData, extData)
    if DEBUG_S then
        -- 测试
        local value = {
            IsWin = true,
            HurtValue = 920430,
            SingleJiFen = 150,
            BaseGetGameResourceList = {
                [1] = {
                    PlayerAttr = {
                        [1] = {
                            ResourceTypeSub = 1101,
                            Num = 450,
                        },
                    },
                },
            },
        }
        addResultLayer(ModuleSub.eBattleBoss, value)
        return
    end

	HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "BossBattle",
        methodName = "Fight",
        svrMethodData = {bossId, isfullFight, fightData.result, fightData.data},
        callback = function(response)
            if not response or response.Status ~= 0 then
                -- 删除战斗页面
                LayerManager.removeTopLayer(true)
                return
            end

            local value = response.Value
            value.IsWin = true
	    	addResultLayer(ModuleSub.eBattleBoss, value)
        end
    })
end

-- 校验限时宝藏战斗结果
--[[
-- 参数
    modelId: 宝藏模型Id
    fightData: 战斗结果数据
]]
function CheckPve.XXBZ(modelId, fightData)
    local extraData = {
        damage = fightData.damage,
    }

    if DEBUG_S then
        -- 测试
        local value = {
            IsWin = true,
            BaseGetGameResourceList = {
                [1] = {
                    PlayerAttr = {
                        [1] = {
                            ResourceTypeSub = 1112,
                            Num = 269620,
                        },
                    },
                },
            },
        }
        addResultLayer(ModuleSub.eXXBZ, value, 0, nil, nil, extraData)
        return
    end

	HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Xxbz",
        methodName = "Fight",
        svrMethodData = {modelId, fightData.result, fightData.data, fightData.damage, fightData.reward},
        callback = function(response)
            if not response or response.Status ~= 0 then
                -- 删除战斗页面
                LayerManager.removeTopLayer(true)
                return
            end

            local value = response.Value
            value.IsWin = true
	    	addResultLayer(ModuleSub.eXXBZ, value, 0, nil, nil, extraData)
        end
    })
end

-- 校验猎魔奇遇主宰挑战战斗结果
--[[
-- 参数
    id :副本id
    data: 操作数据
]]
function CheckPve.QuickexpMeetChallenge(id, data)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "QuickExp",
        methodName = "VerifyMeetChallegeFightInfo",
        svrMethodData = {id, data.data},
        callback = function(response)
            if not response or response.Status ~= 0 then
                -- 删除战斗页面
                LayerManager.removeTopLayer(true)
                return
            end
            local value = response.Value
            -- 挑战成功
            if value.IsWin then
                --  改变数据
                local tempStr = "quickExp.QuickExpMeetLayer"
                local tempData = LayerManager.getRestoreData(tempStr)
                --dump(tempData, "getRestoreData")

                tempData.notUpdateData = true
                if tempData.showMeetId then
                    for _, v in pairs(tempData.meetInfo) do
                        if v.Id == tempData.showMeetId then
                            v.IsDone = true
                            v.BaseGetGameResourceList = value.BaseGetGameResourceList
                            break
                        end
                    end
                else
                    local theMeetData = tempData.meetInfo[tempData.selIndex]
                    if theMeetData then
                        theMeetData.IsDone = true
                        theMeetData.BaseGetGameResourceList = value.BaseGetGameResourceList
                    end
                end
                LayerManager.setRestoreData(tempStr, tempData)
            end

            addResultLayer(ModuleSub.eQuickExpMeetChallenge, response.Value, 0, nil, nil, nil)
        end
    })
end

--校验门派战斗结果
--[[
    参数
    taskId: 任务Id
    fightData: 战斗操作数据
    curNum: 任务完成次数
--]]
function CheckPve.sectFight(taskId, fightData, curNum)
    local isBreak = fightData.skipCallback ~= nil and fightData.skipCallback ~= false
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "SectTask",
        methodName = "Fight",
        svrMethodData = {taskId, fightData.result, fightData.data, isBreak},
        callback = function(response)
            if not response or response.Status ~= 0 then
                -- 删除战斗页面
                LayerManager.removeTopLayer(true)
                return
            end
            local value = response.Value
            -- 挑战成功
            if value.IsWin then
                --  改变数据
                SectObj:refreshTaskProgress(taskId)
            end

            addResultLayer(ModuleSub.eSectTask, response.Value, 0, nil, nil, {taskId})
        end
    })
end

-- 校验神装塔战斗结果
--[[
-- 参数
    nodeId      关卡Id
    type        挑战难度
    result      boolean战斗结果
    data        战斗操作数据
]]
function CheckPve.bdd(fightData, nodeId, type)
    local nodeModel = BddNodeModel.items[nodeId]
    local extraData = {
        -- condition = BddClearanceModel.items[nodeModel.clearanceID].description,
        NodeId = nodeId
    }
    -- dump(fightData, "神装塔本地战斗结果验证数据")
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "BddInfo",
        methodName = "Fight",
        svrMethodData = {nodeId, fightData.result, fightData.data},
        callback = function(response)

            if not response or response.Status ~= 0 then
                -- 删除战斗页面
                LayerManager.removeTopLayer(true)
                return
            end

            local value = response.Value
            addResultLayer(ModuleSub.ePracticeBloodyDemonDomain, value, 0, nil, nil, extraData)
        end
    })
end

-- 校验大罗金库战斗结果
--[[
-- 参数
    myInfo = {  -- 玩家自己的信息
        PlayerName = "", -- 我的名字
        FAP = 0, -- 我的战力
    },
    enemyInfo = {  -- 对方信息
        PlayerName = "", -- 对方的名字
        FAP = 0, -- 对方的战力
    },
    fightData: -- 战斗接口回调的数据
]]
function CheckPve.ChallengeGGZJ(myInfo, enemyInfo, fightData)
    if DEBUG_S then
        -- 测试
        local value = {
            IsWin = false,
            BaseGetGameResourceList = {
                [1] = {
                    PlayerAttr = {
                        [1] = {
                            ResourceTypeSub = 1113,
                            Num = 312030,
                        },
                    },
                    Equip = {
                        [1] = {
                            Step = 0,
                            Lv = 0,
                            Id = "e4694678-3f57-4b4a-9618-28074b336e6c",
                            GemId = "00000000-0000-0000-0000-000000000000",
                            GemModelID = 0,
                            EquipModelId = 13050202,
                        },
                    },
                    Goods = {
                        [1] = {
                            Num = 1,
                            ResourceTypeSub = 1605,
                            GoodsModelId = 16050011,
                        },
                    },
                },
            },
            NodeId = 3,
            FightCount = 0,
        }
        addResultLayer(ModuleSub.eXrxs, value, 0, myInfo, enemyInfo)
        return
    end

    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "XrxsInfo",
        methodName = "Fight",
        svrMethodData = {fightData.nodeId, fightData.result, fightData.data or ""},
        callback = function(response)
            if not response or response.Status ~= 0 then
                -- 删除战斗页面
                LayerManager.removeTopLayer(true)
                return
            end

            local value = response.Value
            addResultLayer(ModuleSub.eXrxs, value, 0, myInfo, enemyInfo)
        end
    })
end

-- 校验国庆活动战斗结果
--[[
    params说明:
    id：副本Guid
    dataStr：操作数据
]]
function CheckPve.requestVerifyChallengeFightInfo(id, dataStr)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "TimedDiceInfo",
        methodName = "VerifyChallengeFightInfo",
        svrMethodData = {id, dataStr.data},
        callback = function(response)
            if not response or response.Status ~= 0 then
                -- 删除战斗页面
                LayerManager.removeTopLayer(true)
                return
            end

            local value = response.Value
            addResultLayer(ModuleSub.eQuickExpMeetChallenge, response.Value)
        end
    })
end

-- 校验珍兽塔普通挑战战斗结果
--[[
-- 参数
    fightData        战斗操作数据
]]
function CheckPve.Zsly(fightData)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "ZslyInfo",
        methodName = "FightCommonNode",
        svrMethodData = {fightData.result, fightData.data},
        callback = function(response)

            if not response or response.Status ~= 0 then
                -- 删除战斗页面
                LayerManager.removeTopLayer(true)
                return
            end

            local value = response.Value
            addResultLayer(ModuleSub.eZhenshouLaoyu, value)
        end
    })
end

-- 校验珍兽塔精英挑战战斗结果
--[[
-- 参数
    fightData        战斗操作数据
]]
function CheckPve.ZslyElite(fightData, nodeId)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "ZslyInfo",
        methodName = "FightEliteNode",
        svrMethodData = {fightData.result, fightData.data, nodeId},
        callback = function(response)

            if not response or response.Status ~= 0 then
                -- 删除战斗页面
                LayerManager.removeTopLayer(true)
                return
            end

            local value = response.Value
            addResultLayer(ModuleSub.eZhenshouLaoyu, value)
        end
    })
end

--[[
	文件名: CacheRoadOfHero.lua
	描述: 大侠之路缓存数据
	创建人: peiyaoqiang
	创建时间: 2018.3.1
--]]

--[[
任务状态：
	1 	-- 已接受，但未完成
	2 	-- 已完成，但尚未领取奖励
	3 	-- 已领取奖励，将自动开启下一个任务
--]]
local CacheRoadOfHero = class("CacheRoadOfHero", {})

-- 初始化
function CacheRoadOfHero:ctor()
    self.mainTaskId = 0 		-- 当前任务ID
    self.mainTaskState = 0      -- 当前任务状态
    self.mainTaskProg = 0		-- 当前任务进度
end

-- 重置数据
function CacheRoadOfHero:reset()
	self.mainTaskId = 0
    self.mainTaskState = 0
    self.mainTaskProg = 0
end

-- 返回当前的任务ID和状态
function CacheRoadOfHero:getCurrTask()
	return self.mainTaskId, self.mainTaskState, self.mainTaskProg
end

-- 更新当前的任务ID和状态
function CacheRoadOfHero:setCurrTask(item)
	if (item == nil) then
		return
	end
	if (item.MaintaskId == nil) and (item.MaintaskStatus == nil) then
		return
	end

    local newProg = item.MainTaskValue or 0
	local newId = item.MaintaskId or self.mainTaskId
	local newState = item.MaintaskStatus or self.mainTaskState
	local isChange = (self.mainTaskId ~= newId) or (self.mainTaskState ~= newState) or (self.mainTaskProg ~= newProg) 	-- 任务是否发生了变化

	-- 如果有状态从1变成2，表示有任务完成
	if (self.mainTaskId == newId) and (self.mainTaskState == 1) and (newState == 2) then
		self:getReward()
	end

	-- 修改新任务
	self.mainTaskId = newId
    self.mainTaskState = newState
	self.mainTaskProg = newProg

	-- 如果任务发生变化了，则推送通知
	if (isChange == true) then
		Notification:postNotification(EventsName.eRoadOfHeroStateChanged)
	end
end

-- 播放领奖特效并领奖
function CacheRoadOfHero:getReward(callback)
    local mainScene = LayerManager.getMainScene()
    local tmpParent = ui.newStdLayer()
    mainScene:addChild(tmpParent, Enums.ZOrderType.eChat + 1)

    -- 弹出完成提示
    Utility.performWithDelay(tmpParent, function ()
        ui.newEffect({
            parent = tmpParent,
            effectName = "effect_ui_dxzl_rwdc",
            animation = "chuxian",
            position = cc.p(320, 568),
            loop = false,
            endRelease = true,
            zorder = 99,
            endListener = function ()
                tmpParent:removeFromParent()
            end
        })

        ui.newEffect({
            parent = tmpParent,
            effectName = "effect_ui_jinpingbaojin",
            position = cc.p(320, 568),
            loop = false,
            endRelease = true,
            zorder = 99,
            endListener = function ()
                tmpParent:removeFromParent()
            end
        })

        -- 自动领奖
        self.requestDrawReward(callback)
    end, 0.01)
end

-- 获取每日任务的数据
function CacheRoadOfHero.requestDrawReward(callback)
    HttpClient:request({
        moduleName = "MaintaskInfo",
        methodName = "DrawMainTaskReward",
        guideInfo = Guide.helper:tryGetGuideSaveInfo(9006),
        callback = function (data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            --[[--------新手引导--------]]--
            local _, _, eventID = Guide.manager:getGuideInfo()
            if eventID == 9006 then
                Guide.manager:nextStep(eventID)
                Guide.manager:removeGuideLayer()
            end
            
            -- 飘窗显示,领取的宝箱奖品
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)
            -- 刷新缓存
            RoadOfHeroObj:setCurrTask({MaintaskId = data.Value.MainTaskInfo.Id, MaintaskStatus = data.Value.MainTaskInfo.Status, MainTaskValue = data.Value.MainTaskInfo.Value})

            if callback then
            	callback()
            end
        end
    })
end

return CacheRoadOfHero

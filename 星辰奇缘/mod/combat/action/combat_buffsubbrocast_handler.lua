-- 子播报buff处理

BuffBubBrocastHandler = BuffBubBrocastHandler or BaseClass(MinorBaseHandler)

function BuffBubBrocastHandler:__init(brocastCtx, minorAction, skillMotion)
    self.brocastCtx = brocastCtx
    self.minorAction = minorAction

    self.actionList = minorAction.actionList

    self.syncStart = SyncSupporter.New(self.brocastCtx)
    self.syncHit = SyncSupporter.New(self.brocastCtx)

    self.buffPlayList = self.brocastCtx.brocastData.buff_play_list
    if self.buffPlayList == nil then
        self.buffPlayList = {}
    end
end

function BuffBubBrocastHandler:Process()
    -- BaseUtils.dump(self.buffPlayList, "--------------子buff播报数据")
    -- 针对buff 20004 的特殊处理
    for i, buffData in ipairs(self.buffPlayList) do
        if buffData.buff_id == 20004 and buffData.action_type == 0 then
            for j = i + 1, #self.buffPlayList do 
                local buffData2 = self.buffPlayList[j]
                if buffData2.buff_id == 20004 and buffData2.action_type == 2 and buffData.target_id == buffData2.target_id and buffData.skill_fid == buffData2.skill_fid and buffData.caster_id == buffData2.caster_id and buffData.order == buffData2.order and buffData.sub_order == buffData2.sub_order then
                    local temp = buffData2
                    self.buffPlayList[j] = self.buffPlayList[i]
                    self.buffPlayList[i] = buffData2
                end
            end
        end
    end
    local order = 0
    local subOrder = 0
    local timeList = {}
    -- for _, actionData in ipairs(self.actionList) do
    for _, actionData in ipairs(self.minorAction.initActionList) do
        order = actionData.order
        subOrder = actionData.sub_order
        local key = CombatUtil.Key(order, subOrder)
        local lastTargID = nil
        local lastaction = nil
        if timeList[key] == nil then
            local isEndBrocast = true
            for i, buffData in ipairs(self.buffPlayList) do
                -- print(string.format("{buffData.order:%s == order:%s, buffData.sub_order:%s == subOrder:%s}"))
                -- if buffData.order == order and buffData.sub_order == subOrder and buffData.is_hit == 1 then
                if buffData.order == order and buffData.sub_order == subOrder then
                    if lastaction ~= nil and lastTargID == buffData.target_id then
                        lastTargID = buffData.target_id
                        local buffAction = BuffPlayAction.New(self.brocastCtx, buffData, self.minorAction.assetwrapper)
                        lastaction:AddEvent(CombatEventType.End, function()
                                buffAction:Play()
                            end
                        )
                        lastaction = buffAction
                        self.buffPlayList[i].handled = true
                    else
                        lastTargID = buffData.target_id
                        local buffAction = BuffPlayAction.New(self.brocastCtx, buffData, self.minorAction.assetwrapper)
                        lastaction = buffAction

                        -- local configData = CombatManager.Instance:GetCombatBuffData(buffData.buff_id)
                        -- if configData ~= nil and configData.isplay_at_start == 1 then
                        --     self.syncStart:AddAction(buffAction)
                        -- else
                        --     self.syncHit:AddAction(buffAction)
                        -- end
                        self.syncHit:AddAction(buffAction)
                        self.buffPlayList[i].handled = true
                    end
                end
            end
            for i, buffData in ipairs(self.buffPlayList) do
                if buffData.order == order and self.buffPlayList[i].handled ~= true then
                    -- if lastTargID == buffData.target_id then
                        lastTargID = buffData.target_id
                        local buffAction = BuffPlayAction.New(self.brocastCtx, buffData, self.minorAction.assetwrapper)
                        self.minorAction.majorAct:AddEvent(CombatEventType.End, function()
                                buffAction:Play()
                            end
                        )
                        lastaction = buffAction
                        self.buffPlayList[i].handled = true
                    -- else
                    --     lastTargID = buffData.target_id
                    --     local buffAction = BuffPlayAction.New(self.brocastCtx, buffData, self.minorAction.assetwrapper)
                    --     lastaction = buffAction
                    --     self.minorAction:AddEvent(CombatEventType.End, function()
                    --             buffAction:Play()
                    --         end
                    --     )
                    --     self.buffPlayList[i].handled = true
                    -- end
                end
            end
            timeList[key] = true
        end
    end
    -- self.minorAction.triggerStart:AddAction(self.syncStart)
    self.minorAction.triggerHit:AddAction(self.syncHit)
end

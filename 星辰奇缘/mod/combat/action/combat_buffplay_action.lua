-- buff播报
BuffPlayAction = BuffPlayAction or BaseClass(CombatBaseAction)

function BuffPlayAction:__init(brocastCtx, buffPlayData, assetwrapper)
    self.buffPlayData = buffPlayData
    self.targetCtrl = self:FindFighter(self.buffPlayData.target_id)
    self.assetwrapper = assetwrapper
end

function BuffPlayAction:Play()
    if self.targetCtrl == nil or BaseUtils.isnull(self.targetCtrl.transform) then
        Log.Info("目标战斗单位为空,buff播报跳过")
        self:OnActionEnd()
        return
    end
    -- BaseUtils.dump(self.buffPlayData, "子buff播报数据")
    -- self.buffPlayData.action_type = 1
    self.buffCtrl = self.targetCtrl.buffCtrl
    if self.buffPlayData.action_type == 0 then          -- 清除
        self.buffCtrl:DeleteBuff(self.buffPlayData.buff_id)
        self:DealTransformer()
        local action = AttrChangeEffect.New(self.brocastCtx, self.buffPlayData.target_changes, self.targetCtrl.fighterData.id, 0, 1, false, true)
        action:Play()
    elseif self.buffPlayData.action_type == 1 then    -- 添加
        if self.buffPlayData.is_hit == 1 then
            local data = BuffUiData.New()
            data:ConvertByPlayData(self.buffPlayData)
            self.buffCtrl:InsertUpdateBuff(data, self.assetwrapper)
            self:DealTransformer()
            local action = AttrChangeEffect.New(self.brocastCtx, self.buffPlayData.target_changes, self.targetCtrl.fighterData.id, 0, 1, false, true)
            action:Play()
        end
        if self.buffPlayData.special == nil then
            self.buffapplyeffect = BuffApplyEffect.New(self.brocastCtx, self.buffPlayData)
            self.buffapplyeffect:AddEvent(CombatEventType.End, function() self:OnActionEnd()  end)
        end
    elseif self.buffPlayData.action_type == 2 then    -- 定时生效
        local data = BuffUiData.New()
        data:ConvertByPlayData(self.buffPlayData)
        self.buffCtrl:InsertUpdateBuff(data, self.assetwrapper)
        local action = AttrChangeEffect.New(self.brocastCtx, self.buffPlayData.target_changes, self.targetCtrl.fighterData.id, 0, 1, false, true)
        action:Play()
    end
    if self.buffapplyeffect ~= nil then
        self.buffapplyeffect:Play()
    else
        self:OnActionEnd()
    end
end

function BuffPlayAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end

function BuffPlayAction:DealTransformer()
    local chgList = self.buffPlayData.target_changes
    for _, cdata in ipairs(chgList) do
        if cdata.change_type == 3 then
            local fctrl = self:FindFighter(self.buffPlayData.target_id)
            if fctrl ~= nil then
                local transformer = TransformerAction.New(self.brocastCtx, fctrl, cdata.change_val)
                transformer:Play()
            end
        end
    end
end

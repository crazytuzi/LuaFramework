-- buff播报
BuffSimplePlayAction = BuffSimplePlayAction or BaseClass(CombatBaseAction)

function BuffSimplePlayAction:__init(brocastCtx, buffData)
    self.buffData = buffData
    self.buffCtrl = self:FindFighter(self.buffData.fighter_id)
end

function BuffSimplePlayAction:Play()
    if self.buffCtrl ~= nil and self.buffCtrl.buffCtrl ~= nil then
        local buffList = self.buffData.buffs
        for _, data in ipairs(buffList) do
            local uidata = BuffUiData.New()
            uidata:ConvertByPlaySpData(data)
            self.buffCtrl.buffCtrl:InsertUpdateBuff(uidata)
        end
        self.buffCtrl.buffCtrl:BuffDataSync(buffList)
    end
    self:OnActionEnd()
end

function BuffSimplePlayAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end

-- buff播报 新创建fighter的时候用到
BuffInitAction = BuffInitAction or BaseClass(CombatBaseAction)

function BuffInitAction:__init(brocastCtx, buffListData, fighterId)
    self.buffListData = buffListData
    self.buffCtrl = self:FindFighter(fighterId)
end

function BuffInitAction:Play()
    for _, data in ipairs(self.buffListData) do
        local uidata = BuffUiData.New()
        uidata:ConvertByPlayData(data)
        self.buffCtrl.buffCtrl:InsertUpdateBuff(uidata)
    end
    self:OnActionEnd()
end

function BuffInitAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end

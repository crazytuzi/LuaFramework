-- 变身
TransformerAction = TransformerAction or BaseClass(CombatBaseAction)

function TransformerAction:__init(brocastCtx, fighterCtrl, changeVal)
    self.fighterCtrl = fighterCtrl
    self.changeVal = changeVal

    self.tpose = nil
    self.animationData = nil
    self.isDeal = false
end

function TransformerAction:Play()
    if self.changeVal ~= 0 then
        local npcData = CombatManager.Instance:GetNpcBaseData(self.changeVal)
        if npcData == nil then
            npcData = DataTransform.data_transform[self.changeVal]
            npcData.scale = 100
        end
        if npcData ~= nil then
            local callback = function(tpose, animationData)
                local scale = npcData.scale / 100
                self:Transformer(tpose, animationData)
                tpose.transform.localScale = Vector3(scale, scale, scale)
            end
            NpcTposeLoader.New(npcData.skin, npcData.res, npcData.animation_id, 1, callback)
            -- npc_tpose_loader.New(npcData.skin, npcData.res, npcData.animation_id, 1, callback)
        else
            Log.Error("变身播报出错，找不到NPC信息:" .. self.changeVal)
            self:OnActionEnd()
        end
    else
        self.fighterCtrl:TransformerRevert()
        self:OnActionEnd()
    end
end

function TransformerAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end

function TransformerAction:Transformer(tpose, animationData)
    tpose.name = "tpose"
    tpose.transform:SetParent(self.fighterCtrl.transform)
    Utils.ChangeLayersRecursively(tpose.transform, "CombatModel")
    tpose.transform.localPosition = Vector3(0, 0, 0)
    tpose.transform.localScale = Vector3(1, 1, 1)
    self.fighterCtrl:Transformer(tpose, animationData, self.changeVal)
end

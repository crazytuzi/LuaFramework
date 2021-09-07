-- --------------------------------
-- 剧情动作分配工厂
-- hosr
-- 管理本次剧情中用到的动作
-- 没有的新增，有的复用
-- 剧情结束销毁
-- --------------------------------
DramaActionFactory = DramaActionFactory or BaseClass()

function DramaActionFactory:__init()
    if DramaActionFactory.Instance then
        return
    end
    DramaActionFactory.Instance = self

    self.dramaTalk = nil
    self.unitMove = nil
    self.unitAct = nil
    self.unitDir = nil
    self.cameraMove = nil
    self.cameraReset = nil
    self.cameraZoom = nil
    self.cameraShake = nil
    self.getPet = nil
    self.feeling = nil
    self.roleJump = nil
    self.bubble = nil
    self.sceneEffect = nil
    self.unitEffect = nil
    self.firstBook = nil

    self.sceneEffectList = {}
end

function DramaActionFactory:__delete()
    self:Destroy()
end

function DramaActionFactory:Destroy()
    -- print("DramaActionFactory:Destroy")

    if self.dramaTalk ~= nil then
        self.dramaTalk:DeleteMe()
        self.dramaTalk = nil
    end
    if self.unitMove ~= nil then
        self.unitMove:DeleteMe()
        self.unitMove = nil
    end
    if self.unitAct ~= nil then
        self.unitAct:DeleteMe()
        self.unitAct = nil
    end
    if self.unitDir ~= nil then
        self.unitDir:DeleteMe()
        self.unitDir = nil
    end
    if self.cameraMove ~= nil then
        self.cameraMove:DeleteMe()
        self.cameraMove = nil
    end
    if self.cameraReset ~= nil then
        self.cameraReset:DeleteMe()
        self.cameraReset = nil
    end
    if self.cameraZoom ~= nil then
        self.cameraZoom:DeleteMe()
        self.cameraZoom = nil
    end
    if self.cameraShake ~= nil then
        self.cameraShake:DeleteMe()
        self.cameraShake = nil
    end
    if self.getPet ~= nil then
        self.getPet:DeleteMe()
        self.getPet = nil
    end
    if self.feeling ~= nil then
        self.feeling:DeleteMe()
        self.feeling = nil
    end
    if self.roleJump ~= nil then
        self.roleJump:DeleteMe()
        self.roleJump = nil
    end
    if self.bubble ~= nil then
        self.bubble:DeleteMe()
        self.bubble = nil
    end
    if self.sceneEffect ~= nil then
        self.sceneEffect:DeleteMe()
        self.sceneEffect = nil
    end
    if self.unitEffect ~= nil then
        self.unitEffect:DeleteMe()
        self.unitEffect = nil
    end
    if self.firstBook ~= nil then
        self.firstBook:DeleteMe()
        self.firstBook = nil
    end

    if self.sceneEffectList ~= nil then
        for i,v in ipairs(self.sceneEffectList) do
            v:DeleteMe()
        end
        self.sceneEffectList = nil
    end
end

function DramaActionFactory:GetAction(type)
    if type == DramaEumn.ActionType.Unittalk or type == DramaEumn.ActionType.Roletalk then
        if self.dramaTalk == nil then
            self.dramaTalk = DramaTalk.New()
        end
        return self.dramaTalk
    elseif type == DramaEumn.ActionType.Actrole or type == DramaEumn.ActionType.Actunit then
        if self.unitAct == nil then
            self.unitAct = DramaUnitAct.New()
        end
        return self.unitAct
    elseif type == DramaEumn.ActionType.Plotunitcreate or type == DramaEumn.ActionType.Plotunitdel then
        return DramaVirtualUnit.Instance
    elseif type == DramaEumn.ActionType.Plotunitmove then
        if self.unitMove == nil then
            self.unitMove = DramaUnitMove.New()
        end
        return self.unitMove
    elseif type == DramaEumn.ActionType.Unitdir or type == DramaEumn.ActionType.Roledir then
        if self.unitDir == nil then
            self.unitDir = DramaUnitDir.New()
        end
        return self.unitDir
    elseif type == DramaEumn.ActionType.Cameramoveto then
        if self.cameraMove == nil then
            self.cameraMove = DramaCameraMove.New()
        end
        return self.cameraMove
    elseif type == DramaEumn.ActionType.Camerareset then
        if self.cameraReset == nil then
            self.cameraReset = DramaCameraReset.New()
        end
        return self.cameraReset
    elseif type == DramaEumn.ActionType.Camerazoom then
        if self.cameraZoom == nil then
            self.cameraZoom = DramaCameraZoom.New()
        end
        return self.cameraZoom
    elseif type == DramaEumn.ActionType.Camerashake then
        if self.cameraShake == nil then
            self.cameraShake = DramaCameraShake.New()
        end
        return self.cameraShake
    elseif type == DramaEumn.ActionType.First_pet then
        if self.getPet == nil then
            -- self.getPet = DramaGetPet.New()
            self.getPet = DramaGetPetNew.New()
        end
        return self.getPet
    elseif type == DramaEumn.ActionType.Inter_monologue then
        if self.feeling == nil then
            self.feeling = DramaFeeling.New()
        end
        return self.feeling
    elseif type == DramaEumn.ActionType.Role_jump then
        if self.roleJump == nil then
            self.roleJump = DramaJump.New()
        end
        return self.roleJump
    elseif type == DramaEumn.ActionType.Unittalkbubble or type == DramaEumn.ActionType.Roletalkbubble then
        if self.bubble == nil then
            self.bubble = DramaBubble.New()
        end
        return self.bubble
    elseif type == DramaEumn.ActionType.Animationplaypoint or type == DramaEumn.ActionType.Animationplay then
        if self.sceneEffectList == nil then
            self.sceneEffectList = {}
        end
        local sceneEffect = DramaAnimationPoint.New()
        table.insert(self.sceneEffectList, sceneEffect)
        return sceneEffect
        -- if self.sceneEffect == nil then
        --     self.sceneEffect = DramaAnimationPoint.New()
        -- end
        -- return self.sceneEffect
    elseif type == DramaEumn.ActionType.Animationplayonrole or type == DramaEumn.ActionType.Animationplayonunit then
        if self.unitEffect == nil then
            self.unitEffect = DramaAnimationUnit.New()
        end
        return self.unitEffect
    elseif type == DramaEumn.ActionType.PetItemSkillGuide then
        if self.firstBook == nil then
            self.firstBook = DramaGetPetBook.New()
        end
        return self.firstBook
    elseif type == DramaEumn.ActionType.Opensys then
    end
end
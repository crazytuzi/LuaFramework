---
--- Created by R2D2.
--- DateTime: 2019/6/6 15:53
---
PetBossDungeonPanel = PetBossDungeonPanel or class("PetBossDungeonPanel", DungeonMainBasePanel)
local this = PetBossDungeonPanel

function PetBossDungeonPanel:ctor()
    self.abName = "dungeon"
    self.assetName = "PetBossDungeonPanel"

    self.dungeon_type = enum.SCENE_STYPE.SCENE_STYPE_BOSS_PET
    self.use_background = false
    self.change_scene_close = true

    self.sceneId = SceneManager:GetInstance():GetSceneId()

    self.modelEvents = {}

end

function PetBossDungeonPanel:dctor()

end

function PetBossDungeonPanel:Open()
    PetBossDungeonPanel.super.Open(self)
end

function PetBossDungeonPanel:LoadCallBack()

end

function PetBossDungeonPanel:AddEvent()

end

function MagicTowerDungeonPanel:OpenCallBack()

end

function MagicTowerDungeonPanel:CloseCallBack()

end

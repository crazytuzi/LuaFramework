-- NPC模型对象池
-- @author huangyq
-- @date   160726
GoNpcPool = GoNpcPool or BaseClass(GoBasePool)

function GoNpcPool:__init(parent)
    self.name = "npc_tpose"
    self.maxSize = 10
    self.parent = parent
    self.Type = GoPoolType.Npc

    self.checkerList = {
        -- 宠物
        GoNodeChecker.New(GoPoolType.Npc, 30027, {"Bip_R_Hand"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30029, {"Bip_R_Hand"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30037, {"Bip_R_Hand"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30127, {"Bip_R_Hand"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30227, {"Bip_R_Hand"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30129, {"Bip_R_Hand"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30229, {"Bip_R_Hand"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30137, {"Bip_R_Hand"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30237, {"Bip_R_Hand"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30046, {"bp_R_Ear", "bp_L_Ear", "bp_Tail"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30146, {"bp_R_Ear", "bp_L_Ear", "bp_Tail"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30246, {"bp_R_Ear", "bp_L_Ear", "bp_Tail"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30247, {"Bip_R_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30747 , {"Bip_R_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30050, {"Bone_Tail_03"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30150, {"Bone_Tail_03"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30250, {"Bone_Tail_03"})
        ,GoNodeChecker.New(GoPoolType.Npc, 10031 , {"Bip_L_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30651 , {"Bip_L_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30751 , {"Bip_L_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 10032, {"Bone_M_Hair_01"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30652, {"Bone_M_Hair_01"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30752, {"Bone_M_Hair_01"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30053, {"Bone_M_Hair_01", "Bone_Tail_03", "Bip_L_Middle_Proximal", "Bip_R_Middle_Proximal"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30153, {"Bone_M_Hair_01", "Bone_Tail_03", "Bip_L_Middle_Proximal", "Bip_R_Middle_Proximal"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30253, {"Bone_M_Hair_01", "Bone_Tail_03", "Bip_L_Middle_Proximal", "Bip_R_Middle_Proximal"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30353, {"Bone_M_Hair_01", "Bone_Tail_03", "Bip_L_Middle_Proximal", "Bip_R_Middle_Proximal"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30453, {"Bone_M_Hair_01", "Bone_Tail_03", "Bip_L_Middle_Proximal", "Bip_R_Middle_Proximal"})

        ,GoNodeChecker.New(GoPoolType.Npc, 30227, {"Bip_R_Hand"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30427, {"Bip_R_Hand"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30229, {"Bip_R_Hand"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30429, {"Bip_R_Hand"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30237, {"Bip_R_Hand"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30837, {"Bip_R_Hand"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30246, {"bp_L_Ear", "bp_R_Ear", "bp_Tail"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30446, {"bp_L_Ear", "bp_R_Ear", "bp_Tail"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30250, {"Bone_Tail_03"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30450, {"Bone_Tail_03"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30056, {"Bone_Tail_04"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30054, {"Bip_R_Weapon", "Bip_L_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30154, {"Bip_R_Weapon", "Bip_L_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30254, {"Bip_R_Weapon", "Bip_L_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30055, {"Bip_Hips"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30155, {"Bip_Hips"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30255, {"Bip_Hips"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30057, {"Bip_L_Hand", "Bip_R_Hand", "Bip_R_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30157, {"Bip_L_Hand", "Bip_R_Hand", "Bip_R_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30257, {"Bip_L_Hand", "Bip_R_Hand", "Bip_R_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30457, {"Bip_L_Lower Arm", "Bip_R_Lower Arm", "Bip_R_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30058, {"Bone_Other3_03", "Bip_L_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30158, {"Bone_Other3_03", "Bip_L_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30258, {"Bone_Other3_03", "Bip_L_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30358, {"Bone_Other3_03", "Bip_L_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30458, {"Bone_Other3_03", "Bip_L_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30059, {"Bip_R_Weapon", "Bip_L_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30159, {"Bip_R_Weapon", "Bip_L_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30259, {"Bip_R_Weapon", "Bip_L_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30060, {"Bip_R_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30160, {"Bip_R_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30260, {"Bip_R_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30061, {"Bip_R_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30161, {"Bip_R_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30261, {"Bip_R_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30361, {"Bip_R_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 40067, {"Bone_Other1_01"})
        ,GoNodeChecker.New(GoPoolType.Npc, 40167, {"Bone_Other1_01"})
        ,GoNodeChecker.New(GoPoolType.Npc, 41034, {"Bip_R_Weapon"})

        ,GoNodeChecker.New(GoPoolType.Npc, 30064, {"Bip_R_Weapon", "Bip_L_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30164, {"Bip_R_Weapon", "Bip_L_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30264, {"Bip_R_Weapon", "Bip_L_Weapon"})

        -- 其他
        ,GoNodeChecker.New(GoPoolType.Npc, 11025, {"Bip_L_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 70138, {"bp_star_01", "bp_star_02", "bp_star_03", "bp_star_04", "bp_star_05"})
        ,GoNodeChecker.New(GoPoolType.Npc, 71014, {"Bone_Tail_06", "Bip_Head"})
        ,GoNodeChecker.New(GoPoolType.Npc, 71114, {"Bone_Tail_06", "Bip_Head"})
        ,GoNodeChecker.New(GoPoolType.Npc, 71075, {"Bip_R_Weapon", "Bip_L_Weapon", "Bip_L_Hand"})
        ,GoNodeChecker.New(GoPoolType.Npc, 71015, {"Bip_R_Weapon", "Bip_L_Weapon", "Bip_L_Hand"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30062, {"Bip_L_Weapon", "Bip_R_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30162, {"Bip_L_Weapon", "Bip_R_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30262, {"Bip_L_Weapon", "Bip_R_Weapon"})
    }
    self:SetIgnoreFlag()
end

function GoNpcPool:__delete()
end

function GoNpcPool:Reset(poolObj, path)
    for _, checker in ipairs(self.checkerList) do
        checker:Check(path, poolObj)
    end
    self:ClearMesh(poolObj)
    self:ClearBpObj(poolObj, 2)
    self:ResetModel(poolObj)
end

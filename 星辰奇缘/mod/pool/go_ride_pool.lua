-- 坐骑
-- @author ljh
-- @date   160809
GoRidePool = GoRidePool or BaseClass(GoBasePool)

function GoRidePool:__init(parent)
    self.name = "ride_tpose"
    self.maxSize = 20
    self.timeout = 72
    self.parent = parent
    self.Type = GoPoolType.Ride
    self.checkerList = {
        -- 坐骑
        GoNodeChecker.New(GoPoolType.Ride, 80029, {"Bip_Spine"})
        ,GoNodeChecker.New(GoPoolType.Ride, 80129, {"Bip_Spine"})
        ,GoNodeChecker.New(GoPoolType.Ride, 80229, {"Bip_Spine"})
        ,GoNodeChecker.New(GoPoolType.Ride, 80429, {"Bip_Spine"})
        ,GoNodeChecker.New(GoPoolType.Ride, 80030, {"Bone04"})
        ,GoNodeChecker.New(GoPoolType.Ride, 80031, {"Bone01"})
        ,GoNodeChecker.New(GoPoolType.Ride, 80032, {"Bone01"})
        ,GoNodeChecker.New(GoPoolType.Ride, 80033, {"Bone_Other1_01"})
        ,GoNodeChecker.New(GoPoolType.Ride, 80034, {"Bone01"})
        ,GoNodeChecker.New(GoPoolType.Ride, 80134, {"Bone01"})
        ,GoNodeChecker.New(GoPoolType.Ride, 80234, {"Bone01"})
        ,GoNodeChecker.New(GoPoolType.Ride, 80334, {"Bone01"})
        ,GoNodeChecker.New(GoPoolType.Ride, 80035, {"Bone_M_Cloak_01"})
        ,GoNodeChecker.New(GoPoolType.Ride, 80235, {"Bone_M_Cloak_01"})
        ,GoNodeChecker.New(GoPoolType.Ride, 80335, {"Bone_M_Cloak_01"})
        ,GoNodeChecker.New(GoPoolType.Ride, 80435, {"Bone_M_Cloak_01"})
    }
    self:SetIgnoreFlag()
end

function GoRidePool:__delete()
end

function GoRidePool:Reset(poolObj, path)
    for _, checker in ipairs(self.checkerList) do
        checker:Check(path, poolObj)
    end
	self:ClearMesh(poolObj)
    self:ResetModel(poolObj)
    self:ClearBpObj(poolObj, 1)
end

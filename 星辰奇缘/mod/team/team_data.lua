-- -------------------------------------------
-- 队伍类型信息
-- -------------------------------------------
TeamTypeData = TeamTypeData or BaseClass()

function TeamTypeData:__init()
    self.team_formation = 0 -- 队伍当前使用阵法
    self.team_formation_lev = 0 -- 队伍当前使用阵法的等级
    self.type = 0 -- 类型
    self.lev_flag = 0 -- 等级要求
    self.status = TeamEumn.MatchStatus.None
    self.combat_num = 0
    self.last_join_time = 0
    self.match_time = 0 -- 匹配持续时间
end

function TeamTypeData:Update(proto)
    self.lev_flag = proto.lev_flag
    self.team_formation = proto.team_formation
    self.team_formation_lev = proto.team_formation_lev
    self.type = proto.type
    self.status = proto.status
    self.last_join_time = proto.last_join_time
    self.combat_num = proto.combat_num
end

function TeamTypeData:Reset()
    self.lev_flag = 0 -- 等级要求
    self.team_formation = 0 -- 队伍当前使用阵法
    self.team_formation_lev = 0 -- 队伍当前使用阵法的等级
    self.type = 0 -- 类型
    self.status = TeamEumn.MatchStatus.None
    self.match_time = 0 -- 匹配持续时间
end

-- ----------------------
-- 队伍成员信息
-- hosr
-- ----------------------
TeamData = TeamData or BaseClass()

function TeamData:__init()
    self.rid = 0  -- 角色Id
    self.platform = "" -- 平台标识
    self.zone_id = 0 -- 区号
    self.name = "" -- 名字
    self.sex = 0 -- 性别
    self.lev = 0 -- 等级
    self.face_id = 0 -- 头像id
    self.status = RoleEumn.TeamStatus.None -- 状态：0无队伍，1队长，2跟随，3暂离，4离线
    self.looks = {}  -- 外观
    self.fc = 0 -- 站力
    self.number = 1 -- 队伍编号

    self.matchStatus = TeamEumn.MatchStatus.None -- 队伍匹配状态
    self.uniqueid = "" -- 个人的唯一id

    self.join_type = TeamEumn.EnterType.None
    self.join_sub_type = 0
    self.join_time = 0
    self.combat_num = 0
end

function TeamData:Update(proto)
    for k,v in pairs(proto) do
        self[k] = v
    end
end

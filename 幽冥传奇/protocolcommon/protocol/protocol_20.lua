--===================================请求==================================
-- 获取副本剩余次数
CSGetFubenMutilUsedTimes = CSGetFubenMutilUsedTimes or BaseClass(BaseProtocolStruct)
function CSGetFubenMutilUsedTimes:__init()
    self:InitMsgType(20, 1)
    
end

function CSGetFubenMutilUsedTimes:Encode()
    self:WriteBegin()
end

-- 副本队伍列表
CSGetTeamInfo = CSGetTeamInfo or BaseClass(BaseProtocolStruct)
function CSGetTeamInfo:__init()
    self:InitMsgType(20, 2)
    self.fuben_type = 0
    self.fuben_id = 0
end

function CSGetTeamInfo:Encode()
    self:WriteBegin()
    MsgAdapter.WriteUChar(self.fuben_type)
    MsgAdapter.WriteUInt(self.fuben_id)
end


-- 创建队伍
CSCreateTeam = CSCreateTeam or BaseClass(BaseProtocolStruct)
function CSCreateTeam:__init()
    self:InitMsgType(20, 3)
    self.fuben_type = 0
    self.fuben_id = 0
end

function CSCreateTeam:Encode()
    self:WriteBegin()
    MsgAdapter.WriteUChar(self.fuben_type)
    MsgAdapter.WriteUInt(self.fuben_id)
end

-- 准备进入副本
CSPreEnterFuben = CSPreEnterFuben or BaseClass(BaseProtocolStruct)
function CSPreEnterFuben:__init()
    self:InitMsgType(20, 5)
    self.fuben_type = 0
    self.fuben_id = 0
    self.team_id = 0
    self.fuben_layer = 0
end

function CSPreEnterFuben:Encode()
    self:WriteBegin()
    MsgAdapter.WriteUChar(self.fuben_type)
    MsgAdapter.WriteUInt(self.fuben_id)
    MsgAdapter.WriteUInt(self.team_id)
    MsgAdapter.WriteUShort(self.fuben_layer)
end

-- 查看一个队伍的信息
CSGetTeamDetailInfo = CSGetTeamDetailInfo or BaseClass(BaseProtocolStruct)
function CSGetTeamDetailInfo:__init()
    self:InitMsgType(20, 6)
    self.fuben_type = 0
    self.fuben_id = 0
    self.team_id = 0
end

function CSGetTeamDetailInfo:Encode()
    self:WriteBegin()
    MsgAdapter.WriteUChar(self.fuben_type)
    MsgAdapter.WriteUInt(self.fuben_id)
    MsgAdapter.WriteUInt(self.team_id)
end

-- 进入副本
CSEnterFuben = CSEnterFuben or BaseClass(BaseProtocolStruct)
function CSEnterFuben:__init()
    self:InitMsgType(20, 8)
    self.fuben_type = 0
    self.fuben_layer = 0
end

function CSEnterFuben:Encode()
    self:WriteBegin()
    MsgAdapter.WriteUChar(self.fuben_type)
    MsgAdapter.WriteUShort(self.fuben_layer)
end


-- 申请加入队伍
CSJoinTeamRequest = CSJoinTeamRequest or BaseClass(BaseProtocolStruct)
function CSJoinTeamRequest:__init()
    self:InitMsgType(20, 9)
    self.fuben_type = 0
    self.fuben_id = 0
    self.team_id = 0
    self.fuben_layer = 0
end

function CSJoinTeamRequest:Encode()
    self:WriteBegin()
    MsgAdapter.WriteUChar(self.fuben_type)
    MsgAdapter.WriteUInt(self.fuben_id)
    MsgAdapter.WriteUInt(self.team_id)
    MsgAdapter.WriteUShort(self.fuben_layer)
end

-- 退出副本
CSExitFubenReq = CSExitFubenReq or BaseClass(BaseProtocolStruct)
function CSExitFubenReq:__init()
    self:InitMsgType(20, 10)
    self.fuben_id = 0
end

function CSExitFubenReq:Encode()
    self:WriteBegin()
    MsgAdapter.WriteUInt(self.fuben_id)
end

CSGetFubenEnterTimes = CSGetFubenEnterTimes or BaseClass(BaseProtocolStruct)
function CSGetFubenEnterTimes:__init()
    self:InitMsgType(20, 11)
    self.fuben_type = 0
end

function CSGetFubenEnterTimes:Encode()
    self:WriteBegin()
    MsgAdapter.WriteUChar(self.fuben_type)
end

-- 退出队伍
CSExitTeamRequest = CSExitTeamRequest or BaseClass(BaseProtocolStruct)
function CSExitTeamRequest:__init()
    self:InitMsgType(20, 15)
    self.fuben_type = 0
    self.fuben_id = 0
    self.team_id = 0
end

function CSExitTeamRequest:Encode()
    self:WriteBegin()
    MsgAdapter.WriteUChar(self.fuben_type)
    MsgAdapter.WriteUInt(self.fuben_id)
    MsgAdapter.WriteUInt(self.team_id)
end

-- 踢出队伍
CSOutMenberRequest = CSOutMenberRequest or BaseClass(BaseProtocolStruct)
function CSOutMenberRequest:__init()
    self:InitMsgType(20, 16)
    self.fuben_type = 0
    self.fuben_id = 0
    self.menber_id = 0
end

function CSOutMenberRequest:Encode()
    self:WriteBegin()
    MsgAdapter.WriteUChar(self.fuben_type)
    MsgAdapter.WriteUInt(self.fuben_id)
    MsgAdapter.WriteUInt(self.menber_id)
end

-- 解散队伍
CSDissolveTeam = CSDissolveTeam or BaseClass(BaseProtocolStruct)
function CSDissolveTeam:__init()
    self:InitMsgType(20, 17)
    self.fuben_type = 0
    self.fuben_id = 0
    self.team_id = 0
end

function CSDissolveTeam:Encode()
    self:WriteBegin()
    MsgAdapter.WriteUChar(self.fuben_type)
    MsgAdapter.WriteUInt(self.fuben_id)
    MsgAdapter.WriteUInt(self.team_id)
end

-- 是否打开多人副本面板
CSOpenFubenMutilView = CSOpenFubenMutilView or BaseClass(BaseProtocolStruct)
function CSOpenFubenMutilView:__init()
    self:InitMsgType(20, 18)
    self.is_open = -1
end

function CSOpenFubenMutilView:Encode()
    self:WriteBegin()
    MsgAdapter.WriteUChar(self.is_open)
end


-- 邀请副本组队
CSInvateFuben = CSInvateFuben or BaseClass(BaseProtocolStruct)
function CSInvateFuben:__init()
    self:InitMsgType(20, 19)
    self.fuben_type = 0
    self.msg_id = 0
end

function CSInvateFuben:Encode()
    self:WriteBegin()
    MsgAdapter.WriteUChar(self.fuben_type)
    MsgAdapter.WriteUChar(self.msg_id)
end


-- 领取奖励，进入下一层
CSGetFubenAward = CSGetFubenAward or BaseClass(BaseProtocolStruct)
function CSGetFubenAward:__init()
    self:InitMsgType(20, 20)
    self.fuben_type = 0
    self.current_layer = 0
    self.next_layer = 0
end

function CSGetFubenAward:Encode()
    self:WriteBegin()
    MsgAdapter.WriteUChar(self.fuben_type)
    MsgAdapter.WriteUShort(self.current_layer)
    MsgAdapter.WriteUShort(self.next_layer)
end

-- 队长点击开始行会禁地副本
CSStartHhjdReq = CSStartHhjdReq or BaseClass(BaseProtocolStruct)
function CSStartHhjdReq:__init()
    self:InitMsgType(20, 21)
end
function CSStartHhjdReq:Encode()
    self:WriteBegin()
end

--请求进入经验副本
CSReqEnterJiYanFuben = CSReqEnterJiYanFuben or BaseClass(BaseProtocolStruct)
function CSReqEnterJiYanFuben:__init( ... )
     self:InitMsgType(20, 23)
     self.foor_level = 0 -- 困难等级,从1开始
end

function CSReqEnterJiYanFuben:Encode( ... )
     self:WriteBegin()
     MsgAdapter.WriteUChar(self.foor_level)
end

--经验副本扫荡
CSSweepJIYanFuben = CSSweepJIYanFuben or BaseClass(BaseProtocolStruct)
function CSSweepJIYanFuben:__init( ... )
     self:InitMsgType(20, 24)
      self.foor_level = 0
end

function CSSweepJIYanFuben:Encode( ... )
     self:WriteBegin()
     MsgAdapter.WriteUChar(self.foor_level)
end

--领取经验副本奖励倍数
CSGetJiYanReWard = CSGetJiYanReWard or BaseClass(BaseProtocolStruct)
function CSGetJiYanReWard:__init( ... )
     self:InitMsgType(20, 25)
     self.get_index = 0
end

function CSGetJiYanReWard:Encode( ... )
    self:WriteBegin()
    MsgAdapter.WriteUChar(self.get_index)
end

-- 请求BOSS类型
-- CSBossTypeReq = CSBossTypeReq or BaseClass(BaseProtocolStruct)
-- function CSBossTypeReq:__init()
--     self:InitMsgType(20, 23)
--     self.boss_type = 0
-- end
-- function CSBossTypeReq:Encode()
--     self:WriteBegin()
--     MsgAdapter.WriteUChar(self.boss_type)
-- end

--通天塔操作
CSOpenrateBabel = CSOpenrateBabel or BaseClass(BaseProtocolStruct)
function CSOpenrateBabel:__init()
   self:InitMsgType(20, 26)
   self.operate_type = 0
end


function CSOpenrateBabel:Encode()
    self:WriteBegin()
    MsgAdapter.WriteUChar(self.operate_type)
end

--炼狱副本操作
CSEnterLianYuFuben = CSEnterLianYuFuben or BaseClass(BaseProtocolStruct)
function CSEnterLianYuFuben:__init()
   self:InitMsgType(20, 27)
   self.operate_type = 0
   self.reward_index = 0
end

function CSEnterLianYuFuben:Encode()
    self:WriteBegin()
    MsgAdapter.WriteUChar(self.operate_type)
    MsgAdapter.WriteUChar(self.reward_index)
end

--购买经验副本次数
CSBuyExpFubenTime = CSBuyExpFubenTime or BaseClass(BaseProtocolStruct)
function CSBuyExpFubenTime:__init()
   self:InitMsgType(20, 28)
end


function CSBuyExpFubenTime:Encode()
    self:WriteBegin()
end

--===================================下发==================================

-- 下发副本剩余次数
SCFubenMutilUsedTimes = SCFubenMutilUsedTimes or BaseClass(BaseProtocolStruct)
function SCFubenMutilUsedTimes:__init()
    self:InitMsgType(20, 1)
end

function SCFubenMutilUsedTimes:Decode()
    self.fuben_used_times_info = {}
    local count = MsgAdapter.ReadInt()
    for i = 1, count do
        local info = {}
        info.id = MsgAdapter.ReadUChar()
        info.used_times = MsgAdapter.ReadUShort()
        table.insert(self.fuben_used_times_info, info)
    end
end

-- 副本所有队伍列表
SCFubenMutilTeamInfo = SCFubenMutilTeamInfo or BaseClass(BaseProtocolStruct)
function SCFubenMutilTeamInfo:__init()
    self:InitMsgType(20, 2)
    self.fuben_type = 0
    self.team_count = 0
    self.team_info = {}
end

function SCFubenMutilTeamInfo:Decode()
    self.fuben_type = MsgAdapter.ReadUChar()
    self.team_count = MsgAdapter.ReadUShort()
    self.team_info = {}
    for i = 1, self.team_count do
        local info = {}
        info.fuben_id = MsgAdapter.ReadInt()
        info.fuben_layer = MsgAdapter.ReadUShort()
        info.team_id = MsgAdapter.ReadUInt()
        info.menber_count = MsgAdapter.ReadUShort()
        info.max_men_count = MsgAdapter.ReadUShort()
        info.state = MsgAdapter.ReadUChar()         -- 多人副本:1 等待组队， 2 已经进入副本; 行会禁地：0 等待，1 开始
        info.leader_name = MsgAdapter.ReadStr()
        table.insert(self.team_info, info)
    end
end

-- 队伍创建
SCTeamCreated = SCTeamCreated or BaseClass(BaseProtocolStruct)
function SCTeamCreated:__init()
    self:InitMsgType(20, 3)
    self.fuben_type = 0
    self.fuben_id = 0
    self.fuben_layer = 0
    self.team_id = 0
    self.menber_count = 0
    self.max_men_count = 0
    self.leader_name = ""
end

function SCTeamCreated:Decode()
    self.fuben_type = MsgAdapter.ReadUChar()
    self.fuben_id = MsgAdapter.ReadUInt()
    self.fuben_layer = MsgAdapter.ReadUShort()
    self.team_id = MsgAdapter.ReadUInt()
    self.menber_count = MsgAdapter.ReadUShort()
    self.max_men_count = MsgAdapter.ReadUShort()
    self.leader_name = MsgAdapter.ReadStr()
end

-- 准备进入副本
SCPreEnterFuben = SCPreEnterFuben or BaseClass(BaseProtocolStruct)
function SCPreEnterFuben:__init()
    self:InitMsgType(20, 5)
    self.fuben_type = 0
    self.fuben_id = 0
    self.fuben_layer = 0
    self.team_id = 0
    self.menber_id = 0
    self.is_ready = 0
end

function SCPreEnterFuben:Decode()
    self.fuben_type = MsgAdapter.ReadUChar()
    self.fuben_id = MsgAdapter.ReadUInt()
    self.fuben_layer = MsgAdapter.ReadUShort()
    self.team_id = MsgAdapter.ReadUInt()
    self.menber_id = MsgAdapter.ReadUInt()
    self.is_ready = MsgAdapter.ReadUChar()
end

-- 返回某队伍的详细情况
SCTeamDetailInfo = SCTeamDetailInfo or BaseClass(BaseProtocolStruct)
function SCTeamDetailInfo:__init()
    self:InitMsgType(20, 6)
    self.fuben_type = 0
    self.team_id = 0
    self.fuben_id = 0
    self.fuben_layer = 0
    self.menber_count = 0
    self.max_men_count = 0
    self.menber_info_list = {}
end

function SCTeamDetailInfo:Decode()
    self.fuben_type = MsgAdapter.ReadUChar()
    self.team_id = MsgAdapter.ReadUInt()
    self.fuben_id = MsgAdapter.ReadUInt()
    self.fuben_layer = MsgAdapter.ReadUShort()
    self.menber_count = MsgAdapter.ReadUShort()
    self.max_men_count = MsgAdapter.ReadUShort()
    self.menber_info_list = {}
    for i = 1, self.menber_count do
        local info = {}
        info.is_leader = MsgAdapter.ReadUChar()
        info.id = MsgAdapter.ReadUInt()
        info.model_id = MsgAdapter.ReadInt()
        info.weapon_id = MsgAdapter.ReadInt()
        info.level = MsgAdapter.ReadInt()
        info.sex = MsgAdapter.ReadUChar()
        info.wing_id = MsgAdapter.ReadInt()
        info.is_ready = MsgAdapter.ReadUChar()
        info.name = MsgAdapter.ReadStr()
        table.insert(self.menber_info_list, info)
    end
end

SCEnterFubenTimes = SCEnterFubenTimes or BaseClass(BaseProtocolStruct)
function SCEnterFubenTimes:__init()
    self:InitMsgType(20, 11)
    self.fuben_type = 0
    self.enter_times = 0
end

function SCEnterFubenTimes:Decode()
    self.fuben_type = MsgAdapter.ReadUChar()
    self.enter_times = MsgAdapter.ReadUChar()
end

SCMenberDecrease = SCMenberDecrease or BaseClass(BaseProtocolStruct)
function SCMenberDecrease:__init()
    self:InitMsgType(20, 14)
    self.fuben_type = 0
    self.fuben_id = 0
    self.fuben_layer = 0
    self.menber_id = 0
end

function SCMenberDecrease:Decode()
    self.fuben_type = MsgAdapter.ReadUChar()
    self.fuben_id = MsgAdapter.ReadUInt()
    self.fuben_layer = MsgAdapter.ReadUShort()
    self.menber_id = MsgAdapter.ReadUInt()
end

SCTeamDissolve = SCTeamDissolve or BaseClass(BaseProtocolStruct)
function SCTeamDissolve:__init()
    self:InitMsgType(20, 15)
    self.fuben_type = 0
    self.fuben_id = 0
    self.fuben_layer = 0
    self.team_id = 0
end

function SCTeamDissolve:Decode()
    self.fuben_type = MsgAdapter.ReadUChar()
    self.fuben_id = MsgAdapter.ReadUInt()
    self.fuben_layer = MsgAdapter.ReadUShort()
    self.team_id = MsgAdapter.ReadUInt()
end


SCMenberIncrease = SCMenberIncrease or BaseClass(BaseProtocolStruct)
function SCMenberIncrease:__init()
    self:InitMsgType(20, 16)
    self.fuben_type = 0
    self.fuben_id = 0
    self.fuben_layer = 0
    self.team_id = 0
    self.info = {}
end

function SCMenberIncrease:Decode()
    self.fuben_type = MsgAdapter.ReadUChar()
    self.fuben_id = MsgAdapter.ReadUInt()
    self.fuben_layer = MsgAdapter.ReadUShort()
    self.team_id = MsgAdapter.ReadUInt()

    self.info = {}
    self.info.id = MsgAdapter.ReadUInt()
    self.info.model_id = MsgAdapter.ReadInt()
    self.info.weapon_id = MsgAdapter.ReadInt()
    self.info.level = MsgAdapter.ReadInt()
    self.info.sex = MsgAdapter.ReadUChar()
    self.info.wing_id = MsgAdapter.ReadInt()
    self.info.is_ready = MsgAdapter.ReadUChar()
    self.info.name = MsgAdapter.ReadStr()
end

SCMonsterKilledCount = SCMonsterKilledCount or BaseClass(BaseProtocolStruct)
function SCMonsterKilledCount:__init()
    self:InitMsgType(20, 17)
    self.killed_count = 0
end

function SCMonsterKilledCount:Decode()
    self.killed_count = MsgAdapter.ReadUInt()
end


SCFirstFloorResult = SCFirstFloorResult or BaseClass(BaseProtocolStruct)
function SCFirstFloorResult:__init()
    self:InitMsgType(20, 18)
    self.result = 0
end

function SCFirstFloorResult:Decode()
    self.result = MsgAdapter.ReadUChar()
end

SCTeamLeaderChanged = SCTeamLeaderChanged or BaseClass(BaseProtocolStruct)
function SCTeamLeaderChanged:__init()
    self:InitMsgType(20, 19)
    self.fuben_type = 0
    self.fuben_id = 0
    self.fuben_layer = 0
    self.team_id = 0
    self.menber_id = 0
end

function SCTeamLeaderChanged:Decode()
    self.fuben_type = MsgAdapter.ReadUChar()
    self.fuben_id = MsgAdapter.ReadUInt()
    self.fuben_layer = MsgAdapter.ReadUShort()
    self.team_id = MsgAdapter.ReadUInt()
    self.menber_id = MsgAdapter.ReadUInt()
end

SCTeamStateChanged = SCTeamStateChanged or BaseClass(BaseProtocolStruct)
function SCTeamStateChanged:__init()
    self:InitMsgType(20, 22)
    self.fuben_type = 0
    self.fuben_layer = 0
    self.team_id = 0
    self.state = 0
end

function SCTeamStateChanged:Decode()
    self.fuben_type = MsgAdapter.ReadUChar()
    self.fuben_layer = MsgAdapter.ReadUShort()
    self.team_id = MsgAdapter.ReadUInt()
    self.state = MsgAdapter.ReadUChar()
end

--下发玩家所剩余行会禁地次数
SCHhjdFbLeftTimes = SCHhjdFbLeftTimes or BaseClass(BaseProtocolStruct)
function SCHhjdFbLeftTimes:__init()
    self:InitMsgType(20, 20)
    self.times = 0
end

function SCHhjdFbLeftTimes:Decode()
    self.times = MsgAdapter.ReadUChar()
end

--下发行会禁地副本信息
SCHhjdFbInfo = SCHhjdFbInfo or BaseClass(BaseProtocolStruct)
function SCHhjdFbInfo:__init()
    self:InitMsgType(20, 21)
    self.area_state = 0
end

function SCHhjdFbInfo:Decode()
    self.area_state = MsgAdapter.ReadUChar()
end

SCMenberDecInFuben = SCMenberDecInFuben or BaseClass(BaseProtocolStruct)
function SCMenberDecInFuben:__init()
    self:InitMsgType(20, 23)
    self.fuben_type = 0
    self.fuben_id = 0
    self.fuben_layer = 0
    self.menber_id = 0 
end

function SCMenberDecInFuben:Decode()
    self.fuben_type = MsgAdapter.ReadUChar()
    self.fuben_id = MsgAdapter.ReadUInt()
    self.fuben_layer = MsgAdapter.ReadUShort()
    self.menber_id = MsgAdapter.ReadUInt()
end

SCHhjdFbFinished = SCHhjdFbFinished or BaseClass(BaseProtocolStruct)
function SCHhjdFbFinished:__init()
    self:InitMsgType(20, 24)
end

function SCHhjdFbFinished:Decode()
end

--经验副本消息
SCJinYanFubenInfo = SCJinYanFubenInfo or BaseClass(BaseProtocolStruct)
function SCJinYanFubenInfo:__init( ... )
    self:InitMsgType(20, 26)
    self.is_had_max_Level = 0  --已经挑战过的最高难度等级
    self.is_had_max_bo_num  = 0 -- 已经挑战过的最高难度等级的最高波数
    self.last_level = 0          --上次挑战的难度等级
    self.last_bo_num = 0         --上次挑战通过波数
    self.had_figth_num  = 0      --挑战次数
    self.is_saodang = 0          --是否是扫荡
    self.buy_time = 0            --购买次数
end

function SCJinYanFubenInfo:Decode( ... )
    self.is_had_max_Level = MsgAdapter.ReadUChar()
    self.is_had_max_bo_num = MsgAdapter.ReadUChar()
    self.last_level = MsgAdapter.ReadUChar()
    self.last_bo_num = MsgAdapter.ReadUChar()
    self.had_figth_num = MsgAdapter.ReadUChar()
    self.is_saodang = MsgAdapter.ReadUChar()  
    self.buy_time = MsgAdapter.ReadUChar() 
end

--在经验副本里面击杀怪物
SCJinYanFubenInfoOnFuben = SCJinYanFubenInfoOnFuben or BaseClass(BaseProtocolStruct)
function SCJinYanFubenInfoOnFuben:__init( ... )
    self:InitMsgType(20, 27)
    self.is_had_max_Level = 0  --已经挑战过的最高难度等级
    self.is_had_max_bo_num  = 0 -- 已经挑战过的最高难度等级的最高波数
    self.last_level = 0          --上次挑战的难度等级
    self.last_bo_num = 0         --上次挑战通过波数
    self.had_figth_num  = 0      --挑战次数
    self.cur_had_bo_num = 0      --当前波数
    self.remain_moster_num = 0   --当前剩余怪物
    self.remain_time = 0         -- 副本剩余时间
end

function SCJinYanFubenInfoOnFuben:Decode( ... )
    self.is_had_max_Level = MsgAdapter.ReadUChar()
    self.is_had_max_bo_num = MsgAdapter.ReadUChar()
    self.last_level = MsgAdapter.ReadUChar()
    self.last_bo_num = MsgAdapter.ReadUChar()
    self.had_figth_num = MsgAdapter.ReadUChar()
    self.cur_had_bo_num = MsgAdapter.ReadUChar()
    self.remain_moster_num = MsgAdapter.ReadUShort()
    self.remain_time = MsgAdapter.ReadUInt()
end

-- boss类型下发
-- SCBossTypeData = SCBossTypeData or BaseClass(BaseProtocolStruct)
-- function SCBossTypeData:__init()
--     self:InitMsgType(20, 26)
--     self.scene_count = 0
--     self.boss_list = {}
-- end

-- function SCBossTypeData:Decode()
--     self.boss_list = {}
--     self.scene_count = MsgAdapter.ReadUShort()
   
--     for i = 1, self.scene_count do
--         local vo = {}
--         vo.scene_id = MsgAdapter.ReadUShort()
--         vo.boss_type = MsgAdapter.ReadUChar()
--         vo.boss_num = MsgAdapter.ReadUShort()
--         table.insert(self.boss_list, vo)
--     end
-- end

--==-通天塔------------
SCBabelData = SCBabelData or BaseClass(BaseProtocolStruct)
function SCBabelData:__init( ... )
    self:InitMsgType(20, 28)
    self.had_fight_num = 0
    self.add_fight_num = 0
    self.had_buy_num = 0
    self.sweep_num = 0
    self.togguang_level = 0
    self.chingjiang_num = 0
    self.had_chou_num = 0
    self.reward_index = 0
    self.is_success = 0
end

function SCBabelData:Decode( ... )
    self.had_fight_num =  MsgAdapter.ReadUShort()
    self.add_fight_num =  MsgAdapter.ReadUShort()
    self.had_buy_num =  MsgAdapter.ReadUChar()
    self.sweep_num =  MsgAdapter.ReadUChar()
    self.togguang_level =  MsgAdapter.ReadUShort()
    self.chingjiang_num =  MsgAdapter.ReadUShort()
    self.had_chou_num =  MsgAdapter.ReadUShort()
    self.reward_index =  MsgAdapter.ReadInt()
    self.is_success = MsgAdapter.ReadUChar()
end



SCBabelRankingListData = SCBabelRankingListData or BaseClass(BaseProtocolStruct)
function SCBabelRankingListData:__init()
    self:InitMsgType(20, 29)
    self.ranking_list_data= {}
    self.my_rank = 0
end


function SCBabelRankingListData:Decode()
    self.count = MsgAdapter.ReadUChar()
    self.ranking_list_data= {}
    for i=1,self.count do
        local v = {}
        v.name = MsgAdapter.ReadStr()
        v.floor = MsgAdapter.ReadInt()
        self.ranking_list_data[i] = v
    end
    self.my_rank = MsgAdapter.ReadUChar()
end


SCLianyuFuBenData = SCLianyuFuBenData or BaseClass(BaseProtocolStruct)
function SCLianyuFuBenData:__init()
    self:InitMsgType(20, 30)
    self.enter_times = 0
    self.had_buy_num = 0
    self.had_bo_num = 0
    self.max_bo_num = 0
    self.is_saodang = 0
end

function SCLianyuFuBenData:Decode()
    self.enter_times = MsgAdapter.ReadUChar()
    self.had_buy_num = MsgAdapter.ReadUChar()
    self.had_bo_num = MsgAdapter.ReadUChar()
    self.max_bo_num = MsgAdapter.ReadUChar()
    self.is_saodang = MsgAdapter.ReadUChar()
end

SCLianyuFuBenInFuBenData = SCLianyuFuBenInFuBenData or BaseClass(BaseProtocolStruct)
function SCLianyuFuBenInFuBenData:__init()
    self:InitMsgType(20, 31)
    self.enter_times = 0
    self.had_buy_num = 0
    self.had_bo_num = 0
    self.max_bo_num = 0
    self.cur_bo_num = 0
    self.remain_boss_num = 0
     self.remain_num = 0
end

function SCLianyuFuBenInFuBenData:Decode()
    self.enter_times = MsgAdapter.ReadUChar()
    self.had_buy_num = MsgAdapter.ReadUChar()
    self.had_bo_num = MsgAdapter.ReadUChar()
    self.max_bo_num = MsgAdapter.ReadUChar()
    self.cur_bo_num = MsgAdapter.ReadUChar()
    self.remain_boss_num = MsgAdapter.ReadUShort()

    self.remain_num = MsgAdapter.ReadUInt()
    -- body
end
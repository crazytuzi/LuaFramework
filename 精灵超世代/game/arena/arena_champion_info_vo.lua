-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      冠军赛每一场比赛的相信信息数据
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ArenaChampionInfoVo = ArenaChampionInfoVo or BaseClass(EventDispatcher) 

function ArenaChampionInfoVo:__init()
    self.step = 0                           -- 阶段信息, 0:未开始不需要显示对战信息,1:选拔赛 32:32强 4:4强
    self.round = 0                          -- 回合     
    self.a_bet = 0                          -- A方已投注值
    self.a_rid = 0                          -- A方角色id
    self.a_srv_id = 0                       -- A方服务器id
    self.a_name = ""                        -- A方名字
    self.a_lev = 0                          -- A方等级
    self.a_face = 0                         -- A方头像
    self.a_avatar_id = 0                    -- A方头像框
    self.a_sex = 0                          -- A方性别
    self.a_power = 0                        -- A方战力
    self.a_formation_type = 0               -- A方阵法类型
    self.a_formation_lev = 0                -- A方阵法等级
    self.a_plist = {}                       -- A方伙伴信息 pos bid lev quality star break_lev hurt behurt curt 
    self.b_bet = 0
    self.b_rid = 0
    self.b_srv_id = 0
    self.b_name = ""
    self.b_lev = 0
    self.b_face = 0
    self.b_avatar_id = 0
    self.b_sex = 0
    self.b_power = 0
    self.b_formation_type = 0
    self.b_formation_lev = 0
    self.b_plist = {}                       -- 伙伴信息 pos bid lev quality star break_lev hurt behurt curt 
    self.ret = 0                            -- 结果(0:未打 1:胜利 2:失败)"
    self.replay_id = 0                      -- 录像id
end

--==============================--
--desc:设置数据
--time:2018-08-04 02:35:49
--@data:
--@return 
--==============================--
function ArenaChampionInfoVo:updateData(data)
    for k, v in pairs(data) do
        if type(v) ~= "table" then
            self:setSingleInfo(k, v)
        else
            self[k] = v
        end
    end
end

function ArenaChampionInfoVo:setSingleInfo(key, value)
	if self[key] ~= value then
		self[key] = value
	end
end 
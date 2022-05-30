-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      战斗中的单位基础数据
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
BattleRoleVo = BattleRoleVo or BaseClass()

function BattleRoleVo:__init()
    self.pos                = 0             -- 九宫格位置
    self.group              = 0             -- 分组,左右之分
    self.owner_id           = 0             -- rid
    self.owner_srv_id       = ""
    self.object_type        = 2             -- 单位类型 1 角色 2 伙伴 3 怪物, 现在暂时没有角色了
    self.object_id          = 0             -- 单位唯一id
    self.object_bid         = 0             -- 基础id,匹配配置表
    self.object_name        = ""            -- 单位名字
    self.star               = 0             -- 伙伴星级
    self.sex                = 0             -- 单位性别
    self.career             = 0             -- 单位职业
    self.lev                = 0             -- 单位等级
    self.hp                 = 0             -- 当前血量
    self.hp_max             = 0             -- 最大气血上线
    self.face_id            = 0             -- 头像id
    self.is_awake           = 0             -- 作用于伙伴的是否觉醒,暂时作废
    self.round              = 0             -- 每个单位自己的回合数,暂时废弃
    self.skills             = {}            -- 角色或者伙伴技能,{skill_bid, end_round}--冷却回合暂时也废弃
    self.extra_data         = {}            -- 额外数据 {extra_key, extra_value}

    self.fight_type         = 0             -- 单位所属战斗类型
end

function BattleRoleVo:__delete()
end
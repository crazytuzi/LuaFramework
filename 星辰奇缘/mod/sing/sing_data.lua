-- -------------------------
-- 每条记录的数据格式
-- hosr
-- -------------------------
SingData = SingData or BaseClass()

function SingData:__init()
    self.id = 0 -- 歌曲id
    self.platform = "" -- 平台
    self.zone_id = 0 -- 区号
    self.rid = 0 -- 角色id
    self.name = "" -- 角色名
    self.sex = 0 -- 性别
    self.classes = 0 -- 职业
    self.lev = 0 -- 等级
    self.time = 0 -- 时长
    self.update_time = 0 -- 更新时间
    self.summary = "" -- 简介
    self.liked = 0 -- 好评数
    self.caster_num = 0 -- 播放数

    self.clip = nil -- 音频数据

    -- 状态
    self.state = SingEumn.State.Normal
    self.select = false
end

function SingData:Update(proto)
    for k,v in pairs(proto) do
        self[k] = v
    end
end
--
-- desc: 系统抽奖记录
-- user: chenyunhe
--
local function api_lotterylog_log(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
    }

    --[[
       1 将领：时间，普通招募/精锐招募/连续招募，奖励。
       2 超级装备：时间，普通研制单次/多次/高级研制单次/多次，奖励。
       3 幸运币：时间，普通探宝/高级探宝，奖励。
       4 海兵方阵：时间，普通招募/高级招募单次/多次，奖励。
       5 飞机技能：时间，普通招募单次/多次/高级招募单次/多次。
         6 装备研究所 时间，单多次 ，奖励。
    ]]
    -- 抽奖记录: 创建时间 抽奖类型 常规奖励 和谐版奖励 抽取次数
    -- "zid."..getZoneId().."lotterylog_"..name..uid
    -- 注： api.funmerg里面的快捷接口 跟策划确定过不需要记录
    local ltype = {
        [1] = "hero.lottery",-- 1普通招募 2精锐招募 3连续招募
        [2] = "sequip.addequip",-- 1普通研制单次/多次/ 2高级研制单次/多次
        [3] = "user.dailylottery",--1 普通探宝 2高级探宝
        [4] = "armor.lottery",--1普通招募 2高级招募单次/多次
        [5] = "plane.skill",--1普通招募单次/多次 2高级招募单次/多次
        [6] = "equip.lottery",--0单多次
    }

	-- 获取记录
    function self.action_get(request)
        local response = self.response
        local id = request.params.id
        local uid = request.uid
        if not uid or not ltype[id] then
            response.ret = -102
            return response
        end

        local redis =getRedis()
        local redkey ="zid."..getZoneId().."lotterylog_"..ltype[id]..uid
        local data =redis:get(redkey)
        data =json.decode(data)

        if type(data) ~= 'table' then data = {} end
        response.ret = 0
        response.msg = 'Success'
        response.data.report=data

        return response
    end

    return self
end

return api_lotterylog_log

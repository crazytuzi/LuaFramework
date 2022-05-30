-- --------------------------------------------------+
-- 假战斗处理
-- @author whjing2011@gmail.com
-- --------------------------------------------------*/
BattleLoop2 = BattleLoop2 or {}
BattleLoop2.talk_cd = 0  -- 说话控制cd

BattleLoop2.next_target_type_pos = 1
BattleLoop2.next_target_type_kill = 2

local col_info = {[1]=1,[2]=2,[3]=3,[4]=1,[5]=2,[6]=3,[7]=1,[8]=2,[9]=3} -- 位置转列
local col_pos_info = {[1]={1,4,7}, [2]={2,5,8}, [3]={3,6,9}}

-- 初始化战斗
function BattleLoop2.init(data)
    BattleLoop2.idx = 0
    BattleLoop2.data = data
    BattleLoop2.a_objects = {}
    BattleLoop2.target_objects = {}
    BattleLoop2.icon_res_list = {5, 2, 7}
    BattleLoop2.icon_idx = 0
    BattleLoop2.randWaveTargets()
    BattleLoop2.b_formation_type = data.b_formation_type or 1
    BattleLoop2.now_num = 0
    BattleLoop2.max_num = math.min(#data.partner_list, 3)
    BattleLoop2.needPlays = {}
    BattleLoop2.last_pos = 0
    BattleLoop2.last_time = 0
    BattleLoop2.a_col = {}
    BattleLoop2.target_play = {}
    BattleLoop2.cd_time = 1
    if #data.partner_list < 2 then
        BattleLoop2.cd_time = 2
    end
    local config = Config.DungeonData.data_drama_dungeon_info(data.dun_bid) or {}
    BattleLoop2.talk_list = config.talk_ids or {}

    local play = {}
    play.objects = {}     -- 已方单位
    play.target_list = {} -- 目标单位
    play.comabt_type = data.combat_type
    for i, v in ipairs(data.partner_list) do
        v.playing = 0
        BattleLoop2.a_objects[i] = v
        play.objects[i] = { pos = v.pos, bid = v.bid, star = v.star, object_type = 2, group = 1, hp = v.hp, hp_max = v.hp, skill_list = {}, fashion = v.use_skin }
        local col = col_info[v.pos]
        BattleLoop2.a_col[col] = BattleLoop2.a_col[col] or {rnum=0, enum=0}
        BattleLoop2.a_col[col].rnum = BattleLoop2.a_col[col].rnum + 1
        BattleLoop2.a_col[col][v.pos] = i
        for j, v1 in ipairs(v.skill_list) do
            table.insert(play.objects[i].skill_list, v1.sid)
        end
    end

    play.target_list[1] = BattleLoop2.nextTarget()
    return play
end

-- 随机产生下一个目标 返回nil时说明当前不能产生
function BattleLoop2.nextTarget(type)
    local now = os.time()
    if BattleLoop2.now_num >= BattleLoop2.max_num then 
        return 
    end
    if BattleLoop2.now_num > 0 and now - BattleLoop2.last_time < BattleLoop2.cd_time then -- 时间冷却
        return
    end
    local pos_list = {}
    local pos_list2 = {}
    local pos, col
    -- local formation_config = Config.FormationData.data_form_data[BattleLoop2.b_formation_type]
    -- for i, v in pairs(formation_config.pos) do
    for i=1, 9 do
        pos = i + GIRD_POS_OFFSET
        col = col_info[i]
        if BattleLoop2.target_objects[pos] == nil and BattleLoop2.a_col[col] ~= nil and BattleLoop2.last_pos ~= pos and BattleLoop2.a_col[col].rnum > BattleLoop2.a_col[col].enum then
            table.insert(pos_list, pos)
            if col_info[BattleLoop2.last_pos - GIRD_POS_OFFSET] ~= col then
                table.insert(pos_list2, pos)
            end
        end
    end
    if next(pos_list2) then
        pos_list = pos_list2
    end
    if next(pos_list) then -- 判断是否有可用空位
        pos = BattleLoop2.rand_item(pos_list)
        col = col_info[pos - GIRD_POS_OFFSET]
        BattleLoop2.a_col[col].enum = BattleLoop2.a_col[col].enum + 1
        local target = BattleLoop2.rand_item(BattleLoop2.b_objects)
        BattleLoop2.target_objects[pos] = target
        BattleLoop2.needPlays[pos] = true
        BattleLoop2.last_pos = pos
        BattleLoop2.last_time = now
        local icon = BattleLoop2.icon_res_list[BattleLoop2.icon_idx]
        BattleLoop2.icon_idx = BattleLoop2.icon_idx % #BattleLoop2.icon_res_list + 1
        BattleLoop2.now_num = BattleLoop2.now_num + 1
        --print("@@@@@@@@@nextTarget======>",BattleLoop2.now_num,BattleLoop2.max_num,pos)
        local play = BattleLoop2.init_play(pos)
        BattleLoop2.target_play[pos] = play
        return {pos = pos, bid = target.bid, star = target.star, hp_max = target.hp, hp = target.hp, object_type = 3, group = 2, skill_list = {}, icon = icon, actor = play.actor, effect_bid = play.effect_bid}
    end
end

-- 技能播报计算
function BattleLoop2.init_play(pos)
    local target = BattleLoop2.target_objects[pos]
    if target == nil or BattleLoop2.needPlays[pos] ~= true then return end
    -- local actor = BattleLoop2.rand_item(BattleLoop2.a_objects)
    local a_idx = BattleLoop2.selectActor(pos)
    -- print("play=============", pos, a_idx)
    BattleLoop2.needPlays[pos] = a_idx
    local actor = BattleLoop2.a_objects[a_idx]
    actor.playing = actor.playing + 1
    local skill = BattleLoop2.rand_item_by_key(actor.skill_list, 'rand')
    local play = { skill_plays = {}, actor = actor.pos, target = pos, skill_bid = skill.sid}
    local skill_idx = 1
    local effect_idx = 1
    local talk_pos, talk_content = BattleLoop2.rand_talk()
    local skill_play = { order = skill_idx, bid = actor.bid, actor = actor.pos, target = pos, skill_bid = skill.sid, effect_play = {}, talk_pos = talk_pos, talk_content = talk_content }
    local hp = target.hp
    for ei, e in pairs(skill.effect_list) do
        play.effect_bid = e.eid
        local hurt = math.random(e.min_hurt, e.max_hurt)
        local is_crit = 0
        if math.random(0, 1000) < actor.crit then
            hurt = math.ceil(hurt * 1.5)
            is_crit = 1
        end
        local dec_hp = hurt
        if ei < #skill.effect_list then
            dec_hp = math.ceil(math.min(hurt, hp) / #skill.effect_list)
        end
        hp = math.max(hp - dec_hp)
        local effect_play = { order = effect_idx, actor = actor.pos, target = pos, effect_bid = e.eid, hp = hp, hurt = -hurt, is_crit = is_crit }
        table.insert(skill_play.effect_play, effect_play)
        effect_idx = effect_idx + 1
    end
    table.insert(play.skill_plays, skill_play)
    return play
end

-- 技能数据读取
function BattleLoop2.play(pos)
    local play = BattleLoop2.target_play[pos]
    BattleLoop2.target_play[pos] = nil
    return play
end

--add by chenbin:
-- 选择进攻者 (选择同行中随机一个有空的宝可梦)
function BattleLoop2.selectActor(pos)
    local logic_pos = pos - GIRD_POS_OFFSET
    local col = col_info[logic_pos]
    local col_pos = col_pos_info[col]
    local a_col_pos = BattleLoop2.a_col[col]
    local a_idx, a_front_idx
    local avilbeIds = {}
    for i, a_pos in pairs(col_pos) do
        a_idx = a_col_pos[a_pos]
        if a_idx then
            a_front_idx = a_front_idx or a_idx
            if BattleLoop2.a_objects[a_idx].playing == 0 then
                table.insert(avilbeIds, a_idx)
            end
        end
    end
    if #avilbeIds > 0 then
        return BattleLoop2.rand_item(avilbeIds)
    end

    return a_front_idx
end

--废弃
-- 选择进攻者 (选择同行中 优先前排宝可梦)
function BattleLoop2.selectActor_old(pos)
    local logic_pos = pos - GIRD_POS_OFFSET
    local col = col_info[logic_pos]
    local col_pos = col_pos_info[col]
    local a_col_pos = BattleLoop2.a_col[col]
    local a_idx, a_front_idx
    for i, a_pos in pairs(col_pos) do
        a_idx = a_col_pos[a_pos]
        if a_idx then
            a_front_idx = a_front_idx or a_idx
            if BattleLoop2.a_objects[a_idx].playing == 0 then
                return a_idx
            end
        end
    end

    return a_front_idx
end

-- 技能播放完成
function BattleLoop2.playEnd(pos)
    --print("play=============end===", pos)
    local a_idx = BattleLoop2.needPlays[pos]
    if a_idx then
        local actor = BattleLoop2.a_objects[a_idx]
        actor.playing = actor.playing - 1
    end
    BattleLoop2.needPlays[pos] = nil
    BattleLoop2.target_objects[pos] = nil
    BattleLoop2.now_num = BattleLoop2.now_num - 1
    local col = col_info[pos - GIRD_POS_OFFSET]
    if BattleLoop2.a_col[col] then
        BattleLoop2.a_col[col].enum = BattleLoop2.a_col[col].enum - 1
    end
end

-- 随机说话 
function BattleLoop2.rand_talk()
    BattleLoop2.talk_cd = BattleLoop2.talk_cd - 1
    if BattleLoop2.talk_cd > 0 then return nil end
    local talk = BattleLoop2.rand_item_by_key2(BattleLoop2.talk_list, 2, 10000)
    if talk and talk[1] then
        BattleLoop2.talk_cd = 5 -- 确保说话最小间隔
        local target = BattleLoop2.rand_item(BattleLoop2.a_objects)
        return target.pos, Config.DungeonData.data_drama_talk[talk[1]]
    end
end

-- 更新目标数据信息
function BattleLoop2.randWaveTargets()
    if BattleLoop2.idx % 10 == 0 then
        if BattleLoop2.data and next(BattleLoop2.data.wave_list) ~= nil then
            BattleLoop2.b_objects = BattleLoop2.rand_item(BattleLoop2.data.wave_list).unit_list
        end
    end
    BattleLoop2.idx = BattleLoop2.idx + 1
end

-- 随机获取从获取中取出一项
function BattleLoop2.rand_item(tab)
    return tab[math.random(#tab)]
end

-- 按指定键随机一项
function BattleLoop2.rand_item_by_key(tab, key)
    local sum = 0
    for i, v in pairs(tab) do sum = sum + v[key] end
    return BattleLoop2.rand_item_by_key2(tab, key, sum)
end

-- 指定概率值随机
function BattleLoop2.rand_item_by_key2(tab, key, sum)
    local rand = math.random(1, sum)
    for i, v in pairs(tab) do
        sum = sum - v[key]
        if rand >= sum then return v end
    end
    return nil
end

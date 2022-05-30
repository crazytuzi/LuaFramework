-- --------------------------------------------------------------------
-- 巅峰冠军赛
--
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      后端锋林  策划 中建
-- <br/>Create: 2019-11-12
-- --------------------------------------------------------------------
ArenapeakchampionModel = ArenapeakchampionModel or BaseClass()

function ArenapeakchampionModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function ArenapeakchampionModel:config()
    --27700 协议内容
    self.main_data = nil
    -- 27701协议内容
    self.my_guess_data = nil

    --256强数据 self.match_data_256[赛区][组id] = pos_list(27709协议里面的 pos_list)
    self.match_data_256 = {} 
    self.max_group_256 = {}
    -- 64 强数据 self.match_data_64[赛区][组id] = pos_list(27709协议里面的 pos_list)
    self.match_data_64 = {} 
    self.max_group_64 = {}
    -- 8 强数据 self.match_data_8[赛区] = pos_list (27710协议里面的pos_list)
    self.match_data_8 = {}
end

function ArenapeakchampionModel:checkPeakChampionTotalRedPoint(need_check)
    local is_open = self:checkPeakChampionIsOpen(true)
    if not is_open then return false end

    local redpoint = self:getGuessRedPoint()
    if redpoint then
        PromptController:getInstance():getModel():addPromptData({type = PromptTypeConst.Peak_champion_arena_tips})
    else
        PromptController:getInstance():getModel():removePromptDataByTpye(PromptTypeConst.Peak_champion_arena_tips)
    end

    if self.main_data then
        if not redpoint then
            if self.my_match_redpoint or self.match_stage_redpoint then
                redpoint = true
            end
        end

        --点赞红点
        if not redpoint  then
            redpoint = self.is_worship_redpoint or false
        end
    end

    if need_check then
        GlobalEvent:getInstance():Fire(ArenapeakchampionEvent.ARENAPEAKCHAMPION_ALL_RED_POINT_EVENT)
        MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.ladder, {bid = CrossgroundConst.Red_Type.peakChampion, status = redpoint})
    end
    return redpoint
end

--点赞红点
function ArenapeakchampionModel:setWorshipRedPoint(count)
    if not count then return end
    local like_max = 3
    local config = Config.ArenaPeakChampionData.data_const.like_max
    if config then
        like_max = config.val or 3
    end
    if count >= like_max then
        self.is_worship_redpoint = false
    else
        self.is_worship_redpoint = true
    end
    self:checkPeakChampionTotalRedPoint(true)
end

function ArenapeakchampionModel:getWorshipRedPoint()
    return self.is_worship_redpoint or false
end

--获取是否竞猜的红点
function ArenapeakchampionModel:getGuessRedPoint()
    if self.main_data and self.my_bet_type then
        if self.main_data.step ~= 0 and self.main_data.step_status ~= 2 then
            if self.main_data.round_status == 2  then
                --竞猜阶段 我未下注
                if self.my_bet_type == 0 then 
                    return true
                end
            end
        end
    end
    return false
end

function ArenapeakchampionModel:setLoginRedPoint(data)
    if not data then  return end
    if not self.main_data then return end
    for i,v in ipairs(data.point_info) do
        if v.type == 1 then --我的赛程
            self.my_match_redpoint = (v.is_point == 0)
        elseif v.type == 2 then --晋级赛红点/64强红点
            if self.main_data.step == 256 or self.main_data.step == 64  or self.main_data.step == 8 then
                self.match_stage_redpoint = (v.is_point == 0)
            else
                self.match_stage_redpoint = false
            end
        end
    end
    self:checkPeakChampionTotalRedPoint(true)
end

function ArenapeakchampionModel:setMyMatchRedPoint(status)
    self.my_match_redpoint = status
    self:checkPeakChampionTotalRedPoint(true)
end

function ArenapeakchampionModel:setMatchStageRedPoint(status)
    self.match_stage_redpoint = status
    self:checkPeakChampionTotalRedPoint(true)
end

function ArenapeakchampionModel:setMainData(data)
    self.main_data = data
    if self.main_data and self.my_bet_type then
        self:checkPeakChampionTotalRedPoint(true)
    end

    --登陆检测一次
    if not self.check_cross_arena then
        self.check_cross_arena = true
        CrossarenaController:getInstance():getModel():checkCrossarenaPrompt()
    end
end

function ArenapeakchampionModel:getMainData()
    return self.main_data
end

--我的下注信息
function ArenapeakchampionModel:setBetTypeInfo(bet_type)
    self.my_bet_type = bet_type
    if self.main_data and self.my_bet_type then
        self:checkPeakChampionTotalRedPoint(true)
    end
end

function ArenapeakchampionModel:setMyGuessData(data)
    self.my_guess_data = data
end

function ArenapeakchampionModel:getMyGuessData()
    return self.my_guess_data
end

--256强数据
function ArenapeakchampionModel:setMatchData256(list, zone_id)
    if list then
        self.match_data_256[zone_id] = {}
        self.max_group_256[zone_id] = 0
        for i,v in ipairs(list) do
            self.match_data_256[zone_id][v.group] = v.pos_list
            if self.max_group_256[zone_id] < v.group then
                self.max_group_256[zone_id] = v.group
            end
        end
    else
        self.match_data_256[zone_id] = nil 
        self.max_group_256[zone_id] = 0   
    end
end

--根据组获取信息
function ArenapeakchampionModel:getMatchData256ByGroup(group, zone_id)
    if self.match_data_256 and self.match_data_256[zone_id] then
        return self.match_data_256[zone_id][group]
    end
    return nil
end

--64强数据
function ArenapeakchampionModel:setMatchData64(list, zone_id)
     if list then
        self.match_data_64[zone_id] = {}
        self.max_group_64[zone_id] = 0
        for i,v in ipairs(list) do
            self.match_data_64[zone_id][v.group] = v.pos_list
            if self.max_group_64[zone_id] < v.group then
                self.max_group_64[zone_id] = v.group
            end
        end
    else
        self.match_data_64[zone_id] = nil  
        self.max_group_64[zone_id] = 0  
    end
end
--根据组获取信息
function ArenapeakchampionModel:getMatchData64ByGroup(group, zone_id)
    if self.match_data_64 and self.match_data_64[zone_id] then
        return self.match_data_64[zone_id][group]
    end
    return nil
end

--8强数据
function ArenapeakchampionModel:setMatchData8(data, zone_id)
    self.match_data_8[zone_id] = data
end

function ArenapeakchampionModel:getMatchData8(zone_id)
    return self.match_data_8[zone_id]
end



--获取比赛的阶段描述
--return 比赛标题 , 比赛阶段
function ArenapeakchampionModel:getMacthText(step, round, round_status)
    if not step or not round then return end
    if step == 0 then
        if self:isBeforeOpenMacthTime() then
            return TI18N("即将开赛")
        else
            return TI18N("未开赛")
        end
    else
        local str = nil
        local str1 = nil
        if step == 1 then
            str = string.format(TI18N("预选赛第%s轮"), StringUtil.numToChinese(round))
        elseif step == 256 then
            if round == 1 then
                str = string.format(TI18N("晋级赛256进128"))
            else
                str = string.format(TI18N("晋级赛128进64"))
            end
        elseif step == 64 then
            if round == 1 then
                str = TI18N("冠军赛64进32")
            elseif round == 2 then
                str = TI18N("冠军赛32进16")
            else
                str = TI18N("冠军赛16进8")
            end
        elseif step == 8 then
            if round == 1 then
                str = TI18N("冠军赛8进4")
            elseif round == 2 then
                str = TI18N("冠军赛半决赛")
            else
                str = TI18N("冠军赛决赛")
            end
        end

        if round_status then
            if round_status == 2 then
                str1 = TI18N(" 竞猜阶段")
            elseif round_status == 3 then
                str1 = TI18N(" 对战阶段")
            else --默认休整阶段
                str1 = TI18N(" 休整阶段")
            end
        end
        return str, str1
    end
end

--获取比赛的阶段描述
--return 比赛标题 , 比赛阶段
function ArenapeakchampionModel:getMacthSingleText(step, round)
    if not self.main_data then return end
    local step = self.main_data.step or 0
    local round = self.main_data.round or 0
    if step == 0 or self.main_data.step_status == 2 then
        if self:isBeforeOpenMacthTime() then
            return TI18N("即将开赛")
        else
            return TI18N("未开赛")
        end
    else
        local str = nil
        if step == 1 then
            str = TI18N("预选赛")
        elseif step == 256 then
            if round == 1 then
                str = TI18N("256强赛")
            else
                str = TI18N("128强赛")
            end
        elseif step == 64 then
            if round == 1 then
                str = TI18N("64强赛")
            elseif round == 2 then
                str = TI18N("32强赛")
            else
                str = TI18N("16强赛")
            end
        elseif step == 8 then
            if round == 1 then
                str = TI18N("8强赛")
            elseif round == 2 then
                str = TI18N("半决赛")
            else
                str = TI18N("决赛")
            end
        end
        return str
    end
end

function ArenapeakchampionModel:isBeforeOpenMacthTime()
    if not self.main_data then return false end

    if self.main_data.step == 0 or self.main_data.step_status == 2 then

        local time = self.main_data.start_time - GameNet:getInstance():getTime()
        if time < 0 then
            time = 0
        end
        --策划说 离开启时间 5天 6个小时跨服竞技场赛就是巅峰冠军赛季
        local total_time =  5*24*60*60 + 6*60*60
        if time <= total_time then
            return true
        else
            return false
        end
    else
        return false
    end

end

function ArenapeakchampionModel:getSecondData(data, is_show_hurt, team_count)
    local a_defense = {}
    local order = team_count or 3 --得默认是3队
    for i,v in ipairs(data.a_defense) do
        a_defense[v.order] = v
    end
    local b_defense = {}
    for i,v in ipairs(data.b_defense) do
        b_defense[v.order] = v
    end
    local result_info = {}
    for i,v in ipairs(data.result_info) do
        result_info[v.order] = v
    end

    local table_insert = table.insert
    local second_data = {}
    second_data.arena_replay_infos = {}
    for i=1,order do
        local info_data = {}
        info_data.order = i
        if result_info[i] then
            info_data.round = result_info[i].round
            info_data.time = result_info[i].time
            info_data.ret = result_info[i].ret
            info_data.id = result_info[i].replay_id
            info_data.replay_sid = result_info[i].replay_sid
        end
        info_data.rid = data.a_rid
        info_data.srv_id = data.a_srv_id
        info_data.a_order = i
        info_data.a_tree_lv = data.a_sprite_lev

        info_data.a_sprite_data = data.a_sprites --兼容旧数据 
        for _,team_data in ipairs(data.a_sprites_list) do --如果新数据有就拿新数据的
            if team_data.team == info_data.order then
                info_data.a_sprite_data = team_data.sprites_list
            end
        end
        info_data.a_plist = {}
        if a_defense[i] then
            info_data.a_power = a_defense[i].power
            info_data.a_formation_type = a_defense[i].formation_type
            info_data.a_hallows_id = a_defense[i].hallows_id
            info_data.a_hallows_look_id = a_defense[i].hallows_look_id

            local formation_config = Config.FormationData.data_form_data[a_defense[i].formation_type]
            local dic_pos = {}
            if formation_config then
                for _, position in ipairs(formation_config.pos) do
                    dic_pos[position[1]] = position[2]
                end
            end

            for i,t in ipairs(a_defense[i].plist) do
                local p = {}
                p.pos = dic_pos[t.pos] or 1
                p.bid = t.bid
                p.id = t.id
                p.lev = t.lev
                p.star = t.star
                p.ext = t.ext
                if p.ext ~= nil and type(p.ext) == 'table' then
                    table_insert(p.ext, {key = 5, val = t.skin_id})
                else
                    p.ext = {{key = 5, val = t.skin_id}}
                end
                table_insert(info_data.a_plist, p)
            end
            
        else
            info_data.a_power = 0
            info_data.a_formation_type = 0
            info_data.a_hallows_id = 0
            info_data.a_hallows_look_id = 0
        end
        
        info_data.b_rid = data.b_rid
        info_data.b_srv_id = data.b_srv_id
        info_data.b_order = i
        info_data.b_tree_lv = data.b_sprite_lev
        info_data.b_sprite_data = data.b_sprites
        for _,team_data in ipairs(data.b_sprites_list) do --如果新数据有就拿新数据的
            if team_data.team == info_data.order then
                info_data.b_sprite_data = team_data.sprites_list
            end
        end
        info_data.b_plist = {}
        if b_defense[i] then
            info_data.b_power = b_defense[i].power
            info_data.b_formation_type = b_defense[i].formation_type
            info_data.b_hallows_id = b_defense[i].hallows_id
            info_data.b_hallows_look_id = b_defense[i].hallows_look_id

            local formation_config = Config.FormationData.data_form_data[b_defense[i].formation_type]
            local dic_pos = {}
            if formation_config then
                for _, position in ipairs(formation_config.pos) do
                    dic_pos[position[1]] = position[2]
                end
            end

            for i,t in ipairs(b_defense[i].plist) do
                local p = {}
                p.pos = dic_pos[t.pos] or 1
                p.bid = t.bid
                p.id = t.id
                p.lev = t.lev
                p.star = t.star
                p.ext = t.ext
                if p.ext ~= nil and type(p.ext) == 'table' then
                    table_insert(p.ext, {key = 5, val = t.skin_id})
                else
                    p.ext = {{key = 5, val = t.skin_id}}
                end
                
                table_insert(info_data.b_plist, p)
            end
        else
            info_data.b_power = 0
            info_data.b_formation_type = 0
            info_data.b_hallows_id = 0
            info_data.b_hallows_look_id = 0
        end
        

        if is_show_hurt then
            --数据
            info_data.hurt_statistics = {}
            local  hurt_statistics_data = {}
            hurt_statistics_data.type = 1 
            hurt_statistics_data.partner_hurts = {}
            if a_defense[i] then
                for i,t in ipairs(a_defense[i].plist) do
                    local p = {}
                    p.rid = data.a_rid
                    p.srvid = data.a_srv_id
                    p.id = t.id
                    p.bid = t.bid
                    p.star = t.star
                    p.lev = t.lev
                    p.camp_type = 1
                    local partner_data = Config.PartnerData.data_partner_base[t.bid]
                    if partner_data then
                        p.camp_type = partner_data.camp_type
                    end
                    p.dps = t.hurt
                    p.cure = t.curt
                    p.ext_data = t.ext
                    if p.ext_data ~= nil and type(p.ext_data) == 'table' then
                        table_insert(p.ext_data, {key = 5, val = t.skin_id})
                    else
                        p.ext_data = {{key = 5, val = t.skin_id}}
                    end
                    table_insert(hurt_statistics_data.partner_hurts,p )
                end
            end
            table_insert(info_data.hurt_statistics, hurt_statistics_data)

            local  hurt_statistics_data = {}
            hurt_statistics_data.type = 2
            hurt_statistics_data.partner_hurts = {}
            if b_defense[i] then
                for i,t in ipairs(b_defense[i].plist) do
                    local p = {}
                    p.rid = data.b_rid
                    p.srvid = data.b_srv_id
                    p.id = t.id
                    p.bid = t.bid
                    p.star = t.star
                    p.lev = t.lev
                    p.camp_type = 1
                    local partner_data = Config.PartnerData.data_partner_base[t.bid]
                    if partner_data then
                        p.camp_type = partner_data.camp_type
                    end
                    p.dps = t.hurt
                    p.cure = t.curt
                    p.ext_data = t.ext
                    if p.ext_data ~= nil and type(p.ext_data) == 'table' then
                        table_insert(p.ext_data, {key = 5, val = t.skin_id})
                    else
                        p.ext_data = {{key = 5, val = t.skin_id}}
                    end
                    table_insert(hurt_statistics_data.partner_hurts,p )
                end
            end
            table_insert(info_data.hurt_statistics, hurt_statistics_data)
        end

        table_insert(second_data.arena_replay_infos, info_data)
    end
    return second_data
end


function ArenapeakchampionModel:checkPeakChampionIsOpen(nottips)
    local role_vo = RoleController:getInstance():getRoleVo()
    local limit_cfg = Config.ArenaPeakChampionData.data_const["open_lev_limit"]
    if limit_cfg and role_vo and role_vo.lev < limit_cfg.val then
        if not nottips then
            message(limit_cfg.desc)
        end 
        return false, limit_cfg.desc
    end

    local world_lv_cfg = Config.ArenaPeakChampionData.data_const["open_world_lev_limit"]
    local world_lev = RoleController:getInstance():getModel():getWorldLev()
    if world_lev and world_lv_cfg and world_lev < world_lv_cfg.val then
        if not nottips then
            message(world_lv_cfg.desc)
        end 
        return false, world_lv_cfg.desc
    end

    return true
end

function ArenapeakchampionModel:__delete()
end
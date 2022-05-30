-- --------------------------------------------------------------------
-- 伙伴运行 红点计算
-- 
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--  伙伴运行 红点计算     
-- <br/>Create: 2018年12月20日
-- --------------------------------------------------------------------
HeroCalculate = HeroCalculate or BaseClass()

--是否是伙伴额外属性
function HeroCalculate.isEquipAttr(key)
    if key == "atk2" or key == "def2" or key == "hp2" or key == "speed2" or key == "hit_rate2" or
     key == "crit_rate2" or key == "hit_magic2" or key == "dodge_magic2" or key== "crit_ratio2" then 
        return true
    end
    return false
end


--判断是否需要千分比显示,参数为数字
function HeroCalculate.isShowPer(num)
    local value = Config.AttrData.data_id_to_key[num]
    local config = Config.AttrData.data_type[value]
    if config and config == 2 then 
        return true
    end
    return false
end
--判断是否需要千分比显示，参数为字符串
function HeroCalculate.isShowPerByStr(value)
    local config = Config.AttrData.data_type[value]
    if config and config == 2 then 
        return true
    end
    return false
end


--判断神器是否能穿戴
function HeroCalculate.getIsCanClothArtifact(bid)
    -- local partner_vo = PartnerController:getInstance():getModel():getPartnerByBid(bid)
    -- if not partner_vo then return false end

    -- local artifact_list = partner_vo.artifact_list or {}
    -- local list = {}
    -- for i,v in pairs(artifact_list) do
    --     list[v.artifact_pos] = v
    -- end

    -- local star = partner_vo.star or 0

    -- local other_star= Config.PartnerData.data_partner_const["assistant_shenqi"].val
    -- local main_star = Config.PartnerData.data_partner_const["main_shenqi"].val

    -- if star >=other_star and not list[1] then 
    --     return true
    -- end

    -- if star >=main_star and not list[2] then 
    --     return true
    -- end

    return false
end


--==============================--
--desc:计算战力的接口
--time:2018-06-21 01:56:53
--@attr_list:
--@return 
--==============================--
function HeroCalculate.calculatePower(attr_list)
    local total_power = 0
    if attr_list == nil or tableLen(attr_list) == 0 then 
        return total_power
    end
    local key, value = nil, nil
    for k,v in pairs(attr_list) do
        if type(v) == "table" and #v >= 2 then
            key = v[1]
            value = v[2]
        else
            key = k
            value = v
        end
        local power_cinfig  = Config.AttrData.data_power[key]
        if power_cinfig then
            local radio = power_cinfig.power 
            value = value - power_cinfig.not_to_power 
            total_power = total_power + value*radio*0.001
        end
    end
    return math.ceil(total_power)
end


--==============================--
--desc:计算神装评分的接口
--time:2018-06-21 01:56:53
--@attr_list:
--@return 
--==============================--
function HeroCalculate.holyEquipMentPower(attr_list)
    local total_power = 0
    if attr_list == nil or tableLen(attr_list) == 0 then 
        return total_power
    end
    local key, value = nil, nil
    for k,v in pairs(attr_list) do
        if type(v) == "table" and #v >= 2 then
            key = v[1]
            value = v[2]
        else
            key = k
            value = v
        end
    
        
        local power_cinfig  = Config.PartnerHolyEqmData.data_holy_attr_score[key]
        if power_cinfig then
            local radio = power_cinfig.score 
            total_power = total_power + value*radio*0.001
        end
    end
    return math.ceil(total_power)
end


-------------------------------------融合祭坛红点代码-----------------------------------
--计算熔炼祭坛所有红点
function HeroCalculate.checkAllStarFuseRedpoint()
    local dic_fuse_info =  HeroController:getInstance():getModel():getStarFuseList()
    if not dic_fuse_info then return false end
    -- 0表示全部宝可梦 
    local camp_fuse_info = dic_fuse_info[0]
    local is_redpoint = HeroCalculate.checkCampStarFuseRedpoint(camp_fuse_info)
    return is_redpoint
end

--消除红点记录
function HeroCalculate.clearAllStarFuseRedpointRecord()
    local dic_fuse_info =  HeroController:getInstance():getModel():getStarFuseList()
    if not dic_fuse_info then return false end
    -- 0表示全部宝可梦 
    local camp_fuse_info = dic_fuse_info[0]
    for i, fuse_data in ipairs(camp_fuse_info) do
        fuse_data.cur_redpoint = nil
    end
    
    --计算主界面熔炼祭坛的红点
    local status = HeroCalculate.checkAllStarFuseRedpoint()
    if status then
        --检测是否有新的
        status = HeroController:getInstance():getModel():checkNewFuseRedPoint()
        if status then
            HeroController:getInstance():sender11055(1)
        end
    end
    MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.guild, status)
end

--计算熔炼祭坛各阵营红点
function HeroCalculate.checkCampStarFuseRedpoint(camp_fuse_info)
    if not camp_fuse_info then return false end
    local is_all_redpoint = false
    local is_redpoint
    for i, fuse_data in ipairs(camp_fuse_info) do
        is_redpoint = HeroCalculate.checkSingleStarFuseRedPoint(fuse_data)
        if not is_all_redpoint and is_redpoint then
            is_all_redpoint = true
        end
    end
    return is_all_redpoint
end

--计算单个宝可梦数据红点 
function HeroCalculate.checkSingleStarFuseRedPoint(fuse_data)
    --cur_redpoint == nil 就是没有计算过红点的
    if fuse_data.cur_redpoint ~= nil then
        return fuse_data.cur_redpoint == 1
    end
    if not fuse_data.star_config then return false end
    local is_redpoint, need_count, total_count = HeroCalculate.checkSingleStarFuseRedPointByStarConfig(fuse_data.star_config)
    if is_redpoint then
        --有红点 类型 1  因为融合祭坛那边排序问题 这样定义 
        fuse_data.cur_redpoint = 1
    else
        --没有红点 类型 2
        fuse_data.cur_redpoint = 2
    end
    fuse_data.need_count = need_count or 0
    fuse_data.total_count = total_count or 0

    return is_redpoint
end

--计算升星红点红点根据升星表
--@is_ignore_master_card 是否忽视主卡(6星以上的升星逻辑)
--@partner_id 忽视主卡的 唯一id
function HeroCalculate.checkSingleStarFuseRedPointByStarConfig(star_config, is_ignore_master_card, partner_id)
    if not star_config then return false end
    local hero_item_data_list  ={}
    local index = 1
    local expend = star_config.expend1[1]
    --特定条件数据 结构 dic_the_conditions[bid][星级] = 数量
    local dic_the_conditions = {}
    --随机条件 dic_random_conditions[阵营][星级] = 数量
    local dic_random_conditions = {}
    --标志已用
    local dic_hero_id = {}
    local need_count = 0
    if not is_ignore_master_card then
        if expend then
            --指定的 {10402,4,1} : 10402: 表示bid, 4: 表示星级 1:表示数量
            local bid, star, count = expend[1], expend[2], expend[3]
            dic_the_conditions[bid] = {}
            dic_the_conditions[bid][star] = count
            need_count = need_count + count 
        end
        index = index + 1
    else
        dic_hero_id[partner_id] = 1
    end
    for i,expend in ipairs(star_config.expend2) do
        --指定的 {10402,4,1} : 10402: 表示bid, 4: 表示星级 1:表示数量
        local bid, star, count = expend[1], expend[2], expend[3]
        if dic_the_conditions[bid] == nil then
            dic_the_conditions[bid] = {}
        end
        if dic_the_conditions[bid][star] == nil then
            dic_the_conditions[bid][star] = count
        else
            dic_the_conditions[bid][star] = dic_the_conditions[bid][star] + count
        end
        need_count = need_count + count 
        index = index + 1
    end
    --4是和策划说好了最多4个
    if index <= 4 then
        --随机的 {1,4,2} : 1 表示阵营  4: 表示星级 2表示数量
        for i,expend in ipairs(star_config.expend3) do
            local camp, star, count = expend[1], expend[2], expend[3]
            if dic_random_conditions[camp] == nil then
                dic_random_conditions[camp] = {}
            end
            if dic_random_conditions[camp][star] == nil then
                dic_random_conditions[camp][star] = count
            else
                dic_random_conditions[camp][star] = dic_random_conditions[camp][star] + count
            end
            need_count = need_count + count 
            index = index + 1
            if index > 4 then
                break
            end
        end
    end
    --获取列表
    local model = HeroController:getInstance():getModel()
    local total_count = model:getHeroListByMatchInfo(dic_the_conditions, dic_random_conditions, dic_hero_id)
    return total_count >= need_count, need_count, total_count

    -- local dic_the_result, dic_random_result, total_count = model:getHeroListByMatchInfo(dic_the_conditions, dic_random_conditions)
    -- for bid, con in pairs(dic_the_conditions) do
    --     for star, count in pairs(con) do
    --         --说明有值
    --         if dic_the_result[bid] and dic_the_result[bid][star] then
    --             if #dic_the_result[bid][star] < count then
    --                 --数量都不够..直接返回
    --                 return false, need_count, total_count
    --             end
    --             for i=1,count do
    --                 local hero = table.remove(dic_the_result[bid][star], 1)
    --                 dic_hero_id[hero.partner_id] = true
    --             end
    --         else
    --             --需求的对象都没有
    --             return false, need_count, total_count
    --         end
    --     end
    -- end

    -- for camp, con in pairs(dic_random_conditions) do
    --     for star, count in pairs(con) do
    --         if dic_random_result[camp] and dic_random_result[camp][star] then
    --             local num = count
    --             for i,hero in ipairs(dic_random_result[camp][star]) do
    --                 if not dic_hero_id[hero.partner_id] then
    --                     num = num - 1
    --                     if num == 0 then
    --                         break
    --                     end
    --                 end
    --             end
    --             if num > 0 then
    --                 return false, need_count, total_count
    --             end
    --         else
    --            --需求的对象都没有
    --             return false, need_count, total_count
    --         end
    --     end
    -- end
    -- return true, need_count, total_count
end
-------------------------------------融合祭坛红点代码结束-----------------------------------


-------------------------------------宝可梦红点红点代码-----------------------------------
--检查所有有效宝可梦红点 
function HeroCalculate.checkAllHeroRedPoint()
    local redpoint_data1 = HeroCalculate.checkHeroRedPointByRedPointType(HeroConst.RedPointType.eRPLevelUp, true)
    local redpoint_data2 = HeroCalculate.checkHeroRedPointByRedPointType(HeroConst.RedPointType.eRPEquip, true)
    local redpoint_data3 = HeroCalculate.checkHeroRedPointByRedPointType(HeroConst.RedPointType.eRPStar, true)
    local redpoint_data4 = HeroCalculate.checkHeroRedPointByRedPointType(HeroConst.RedPointType.eRPTalent, true)
    --策划要求 天赋不算如主界面红点 但是算入宝可梦背包红点
    local data = {redpoint_data1, redpoint_data2, redpoint_data3} -- , redpoint_data4
    MainuiController:getInstance():setBtnRedPoint(MainuiConst.btn_index.partner,data)
    -- local status = redpoint_data1.status or redpoint_data2.status or redpoint_data3.status
    local data = {redpoint_data1, redpoint_data2, redpoint_data3, redpoint_data4}
    GlobalEvent:getInstance():Fire(HeroEvent.All_Hero_RedPoint_Event, data) 
end

--根据红点类型 清检测红点记录 
--@red_point_type 参考 HeroConst.RedPointType
--@ 是否只是返回 红点数据就好
function HeroCalculate.checkHeroRedPointByRedPointType(red_point_type, is_return)
    local hero_list = HeroController:getInstance():getModel():getHeroList()
    local redpoint_data = {}
    redpoint_data.bid = red_point_type
    redpoint_data.status = false
    for k, hero_vo in pairs(hero_list) do
        if HeroCalculate.isCheckHeroRedPointByHeroVo(hero_vo) then
            if red_point_type == HeroConst.RedPointType.eRPLevelUp then --等级
                redpoint_data.status = HeroCalculate.checkSingleHeroLevelUpRedPoint(hero_vo)
                if redpoint_data.status then 
                    break
                end
            elseif red_point_type == HeroConst.RedPointType.eRPEquip then --装备
                redpoint_data.status = HeroCalculate.checkSingleHeroEquipRedPoint(hero_vo)
                if redpoint_data.status then 
                    break
                end
            elseif red_point_type == HeroConst.RedPointType.eRPStar then --升星
                redpoint_data.status = HeroCalculate.checkSingleHeroUpgradeStarRedPoint(hero_vo)
                if redpoint_data.status then 
                    break
                end
            elseif red_point_type == HeroConst.RedPointType.eRPTalent then --天赋
                redpoint_data.status = HeroCalculate.checkSingleHeroTalentSkillRedPoint(hero_vo)
                if redpoint_data.status then 
                    break
                end
                
            end
        end
    end
    if is_return then
        return redpoint_data
    else
        if red_point_type ~= HeroConst.RedPointType.eRPTalent then --天赋
             --策划要求 天赋不算如主界面红点 但是算入宝可梦背包红点
            MainuiController:getInstance():setBtnRedPoint(MainuiConst.btn_index.partner,{redpoint_data})
        end
        GlobalEvent:getInstance():Fire(HeroEvent.All_Hero_RedPoint_Event, {redpoint_data}) 
    end
end



--根据红点类型 清空红点记录 
--@red_point_type 参考 HeroConst.RedPointType
--@is_delay 是否延迟检测
function HeroCalculate.clearAllHeroRecordByRedPointType(red_point_type, is_delay)
    --马上清除
    local model = HeroController:getInstance():getModel()
    local hero_list = model:getHeroList()
    for k, hero_vo in pairs(hero_list) do
        hero_vo.red_point[red_point_type] = nil 
    end

    local _delayFun = function()
        if HeroCalculate then 
            HeroCalculate.checkHeroRedPointByRedPointType(red_point_type)
            if red_point_type == HeroConst.RedPointType.eRPLevelUp or
              red_point_type == HeroConst.RedPointType.eRPTalent then
                --目前升级 和 天赋 用到延迟
                model.is_delay_redpoint_update[red_point_type] = false
            end
        end
    end

    if is_delay then
        --一秒后再算红点
        delayOnce(_delayFun, 1) --延迟一秒
    else
        _delayFun()
    end
    
end

--是否需要检测红点
function HeroCalculate.isCheckHeroRedPointByHeroVo(hero_vo)
    if not hero_vo then return false end
    -- 3 以后走配置表 
    --等于 > 3级 和 上阵的宝可梦需要检查红点 注意: hero_vo.lev > 3 暂时不要
    --hero_vo.is_in_form < 10 因为 is_in_form.改成 布阵类型 *10 + 序号了
    if  hero_vo:isFormDrama() then
        return true
    end
    return false
end

--检查单个宝可梦的红点信息
function HeroCalculate.checkSingleHeroRedPoint(hero_vo)
    local is_redpoint = false
    --升级 升阶红点
    is_redpoint = HeroCalculate.checkSingleHeroLevelUpRedPoint(hero_vo)
    if is_redpoint then return true end
    --装备红点
    is_redpoint = HeroCalculate.checkSingleHeroEquipRedPoint(hero_vo)
    if is_redpoint then return true end
    --升星红点
    is_redpoint = HeroCalculate.checkSingleHeroUpgradeStarRedPoint(hero_vo)
    if is_redpoint then return true end
    --天赋红点
    is_redpoint = HeroCalculate.checkSingleHeroTalentSkillRedPoint(hero_vo)
    return is_redpoint
end

-----------------------------宝可梦升级升阶的红点逻辑-------------------------
--是足够需要条件
--@limit 限制条件
--@ hero_vo 宝可梦信息
function HeroCalculate.isEnoughCondition(limit, hero_vo)
    local isNeed = true
    for i,v in ipairs(limit) do
        if v[1] == "star" then
            if hero_vo.star < v[2] then
                isNeed = false
            end
        end
    end
    return isNeed
end

--获取等级显示状态 
--@ return 0:表示满级  1: 表示可以升级 : 2:表示可以进阶  -1 表示出错了
function HeroCalculate.getHeroShowLevelStatus(hero_vo)
    local key = getNorKey(hero_vo.type, hero_vo.break_id, hero_vo.break_lev)
    local break_config = Config.PartnerData.data_partner_brach[key]
    if break_config == nil then return -1 end
    local next_key = getNorKey(hero_vo.type, hero_vo.break_id, hero_vo.break_lev + 1)
    local next_break_config = Config.PartnerData.data_partner_brach[next_key]

    local lev_max = break_config.lev_max
    local status = 0
    if next_break_config == nil then
        local key = getNorKey(hero_vo.bid, hero_vo.star)
        local star_config = Config.PartnerData.data_partner_star(key)
        if star_config and lev_max < star_config.lev_max then
            lev_max = star_config.lev_max
        end

        if hero_vo.lev >= lev_max then
            -- 都满了  满级状态
            status = 0
        else
            --等级不足 需要升级
            status = 1
        end
    else
        if next_break_config.limit and next(next_break_config.limit) ~= nil then
            if hero_vo.lev >= break_config.lev_max then
                --进阶有要求 需要升星
                local is_enough = HeroCalculate.isEnoughCondition(next_break_config.limit, hero_vo)
                if is_enough then
                    --可以进阶了
                    status = 2
                else
                    --不满足条件.显示满级状态
                    status = 0
                end
            else
                --等级不足 需要升级
                status = 1
            end
        else
            --没有限制
            if hero_vo.lev >= break_config.lev_max then
                --可以进阶了
                status = 2
            else
                 --等级不足 需要升级
                status = 1
            end
        end
    end
    return status
end
--检查单个宝可梦升级红点 及进阶红点
function HeroCalculate.checkSingleHeroLevelUpRedPoint(hero_vo)
    if not hero_vo then return false end
    if hero_vo.red_point[HeroConst.RedPointType.eRPLevelUp] ~= nil then
        return hero_vo.red_point[HeroConst.RedPointType.eRPLevelUp] == true
    end
    --共鸣中的宝可梦不应该有升级和进阶的
    if hero_vo.isResonateCrystalHero and hero_vo:isResonateCrystalHero() then
        return false
    end
    local status = HeroCalculate.getHeroShowLevelStatus(hero_vo)
    local is_redpoint = false
    if status == 1 then --升级
        local lev_config = Config.PartnerData.data_partner_lev[hero_vo.lev]
        if lev_config then
            local up_cost = lev_config.expend or {}
            local lev_redpoint = true
            for i,cost in ipairs(up_cost) do
                local count = BackpackController:getInstance():getModel():getItemNumByBid(cost[1])
                if count < cost[2] then
                    lev_redpoint = false
                end
            end
            is_redpoint = lev_redpoint
        end
    elseif status == 2 then --升阶
        local key = getNorKey(hero_vo.type, hero_vo.break_id, hero_vo.break_lev)
        local break_config = Config.PartnerData.data_partner_brach[key]
        if break_config then
            local cost_list = break_config.expend or {}
            local break_redpoint = true
            for i,cost in ipairs(cost_list) do
                local count = BackpackController:getInstance():getModel():getItemNumByBid(cost[1])
                if count < cost[2] then
                    break_redpoint = false
                end
            end
            is_redpoint = break_redpoint
        end
    end
    hero_vo.red_point[HeroConst.RedPointType.eRPLevelUp] = is_redpoint 
    return is_redpoint
end

-----------------------------宝可梦升级升阶的红点逻辑结束-------------------------


-----------------------------宝可梦升装备的红点逻辑-------------------------
--检测装备类型的红点
--@equip_type 装备类型
--@equip_vo 装备对象..如果为空说明没有装备
function HeroCalculate.checkSingleHeroEachPosEquipRedPoint(equip_type, equip_vo)
    local equip_type = equip_type or 1
    local backpack_model = BackpackController:getInstance():getModel()
    local equip_score_list = backpack_model:getAllEquipListByType(equip_type)

    if equip_vo == nil then
        --没有装备..判断是否有对应类型的装备
        if equip_score_list and next(equip_score_list) then
                --有红点
            return true
        end
    else
        --如果没有分数..算一个 ..
        if equip_vo.all_score == nil or equip_vo.all_score == 0 then
            equip_vo:setEnchantScore(0)
        end
        local score = equip_vo.all_score or 0
        if equip_score_list then
            --要判断当前装备比背包的装备评分底才显示红点
            for k,equip_item in pairs(equip_score_list) do
                if equip_item.all_score and equip_item.all_score > score then 
                    return true
                end
            end
        end    
    end
    
    return false
end
--检测符文类型的红点
--@equip_vo 符文对象..如果为空说明没有符文
function HeroCalculate.checkSingleArtifactRedPoint(equip_vo)
    local backpack_model = BackpackController:getInstance():getModel()
    local equip_score_list = backpack_model:getAllEquipListByType(BackPackConst.item_type.ARTIFACTCHIPS)

    if equip_vo == nil then
        --没有符文..判断是否有对应类型的符文
        if equip_score_list and next(equip_score_list) then
                --有红点
            return true
        end
    else
        -- local score = equip_vo.all_score or 0
        -- if equip_score_list then
        --     --要判断当前符文比背包的装备评分底才显示红点
        --     for k,equip_item in pairs(equip_score_list) do
        --         if equip_item.all_score and equip_item.all_score > score then 
        --             return true
        --         end
        --     end
        -- end    
    end
    
    return false
end


--检查单个宝可梦装备红点
function HeroCalculate.checkSingleHeroEquipRedPoint(hero_vo)
    if not hero_vo then return false end
    --如果个人装备还没有获取到.就不做判断 因为之前装备信息是11000协议获取的 后来改为 11025:获取基本信息 11026:获取属性装备等信息..需要等11026回来才做判断
    if not hero_vo:isInitAttr() then return false end
    if hero_vo.red_point[HeroConst.RedPointType.eRPEquip] ~= nil then
        return hero_vo.red_point[HeroConst.RedPointType.eRPEquip] == true
    end
    local is_redpoint
    local model = HeroController:getInstance():getModel()
    --装备
    local equip_list = model:getHeroEquipList(hero_vo.partner_id)
    local equip_type_list = HeroConst.EquipPosList or {}
    for i,equip_type in ipairs(equip_type_list) do
        is_redpoint = HeroCalculate.checkSingleHeroEachPosEquipRedPoint(equip_type, equip_list[equip_type])
        if is_redpoint then
            break
        end
    end

    -- --符文(神器)
    -- if not is_redpoint then
    --     local artifact_list = hero_vo.artifact_list or {}
    --     for i,artifact_lock in ipairs(model.artifact_lock_list) do
    --         if artifact_lock then
    --             if artifact_lock[1] == 'lev' then
    --                 if hero_vo.lev >= artifact_lock[2] then
    --                     is_redpoint = HeroCalculate.checkSingleArtifactRedPoint(artifact_list[i])
    --                     if is_redpoint then
    --                         break
    --                     end
    --                 end
    --             elseif artifact_lock[1] == 'star' then
    --                 if hero_vo.star >= artifact_lock[2] then
    --                     is_redpoint = HeroCalculate.checkSingleArtifactRedPoint(artifact_list[i])
    --                     if is_redpoint then
    --                         break
    --                     end
    --                 end
    --             end
    --         end
    --     end
    -- end

    hero_vo.red_point[HeroConst.RedPointType.eRPEquip] = is_redpoint
    return is_redpoint
end
-----------------------------宝可梦升装备的红点逻辑结束-------------------------
-----------------------------宝可梦升星的红点逻辑开始-------------------------

--检查单个宝可梦升星红点 
function HeroCalculate.checkSingleHeroUpgradeStarRedPoint(hero_vo)
    if not hero_vo then return false end
    if hero_vo.red_point[HeroConst.RedPointType.eRPStar] ~= nil then
        return hero_vo.red_point[HeroConst.RedPointType.eRPStar] == true
    end
    
    local star = hero_vo.star or 1
    local next_key = getNorKey(hero_vo.bid, star + 1)
    local next_star_config = Config.PartnerData.data_partner_star(next_key)
    if next_star_config == nil then
        --说明满星了
        hero_vo.red_point[HeroConst.RedPointType.eRPStar] = false
        return false
    end


    
    local star_config = next_star_config
    local is_redpoint = false
    local model =  HeroController:getInstance():getModel()
    if star == model.hero_info_upgrade_star_param2 then
            --10级升11有世界等级要求
        is_redpoint = model:checkOpenStar11()

    elseif star == model.hero_info_upgrade_star_param3 then
        --11星升12有世界等级要求
        is_redpoint = model:checkOpenStar12()
    elseif star == model.hero_info_upgrade_star_param4 then
        --12星升13有世界等级要求
        is_redpoint = model:checkOpenStar13()
    else
        is_redpoint = true
    end


    if is_redpoint then
        if star_config then
            
            is_redpoint = HeroCalculate.checkSingleStarFuseRedPointByStarConfig(star_config, true, hero_vo.partner_id)
            --计算消耗    
            if is_redpoint and next(star_config.other_expend) ~= nil  then
                for k,v in pairs(star_config.other_expend) do
                    local count = BackpackController:getInstance():getModel():getItemNumByBid(v[1])
                    if count < v[2] then
                        is_redpoint = false
                        break
                    end
                end
            end
        else
            is_redpoint = false
        end
    end

    hero_vo.red_point[HeroConst.RedPointType.eRPStar] = is_redpoint
    return is_redpoint
end
-----------------------------宝可梦升星的红点逻辑结束-------------------------

---------------------------------------天赋红点开始-------------------------------------------
--检查单个天赋技能红点
function HeroCalculate.checkSingleHeroTalentSkillRedPoint(hero_vo)
    if not hero_vo then return false end
    --首次升级到6星记录
    if hero_vo.is_open_talent == true then
        return true
    end
    if hero_vo.red_point[HeroConst.RedPointType.eRPTalent] ~= nil then
        return hero_vo.red_point[HeroConst.RedPointType.eRPTalent] == true
    end

    if not hero_vo:ishaveTalentData() then return false end
    local is_redpoint = false
    local dic_hero_talent_skill_learn_redpoint = HeroController:getInstance():getModel():getTalentRedpointRecord()
    local dic_skill_id = {}
    for pos,id in pairs(hero_vo.talent_skill_list) do
        dic_skill_id[id] = pos
    end
    for i,v in pairs(Config.PartnerSkillData.data_partner_skill_pos) do
        if hero_vo.talent_skill_list[v.pos] then
            --已装备技能 只需判断能否升级
            is_redpoint = HeroCalculate.checkSingleTalentSkillLevel(hero_vo.talent_skill_list[v.pos])
            if is_redpoint then
                break
            end
        else
            --未装备 先判断是否解锁位置 
            local is_lock = false
            if v.pos_limit[1] == 'star' then
                is_lock = (hero_vo.star >= v.pos_limit[2])
            end
            if is_lock then
                for id,v in pairs(dic_hero_talent_skill_learn_redpoint) do
                    if dic_skill_id[id] == nil then
                        is_redpoint = true
                        break
                    end
                end
                if is_redpoint then
                    break
                end
            end
        end
    end
    hero_vo.red_point[HeroConst.RedPointType.eRPTalent] = is_redpoint
    return is_redpoint
end
--判断天赋技能能否升级 @skill_id 技能id
function HeroCalculate.checkSingleTalentSkillLevel(skill_id)
    local config = Config.PartnerSkillData.data_partner_skill_level[skill_id]
    if config then
        local is_enough = true
        for i,cost in ipairs(config.expend) do
            local have_num = BackpackController:getInstance():getModel():getItemNumByBid(cost[1])
            if have_num < cost[2] then
                is_enough = false
                break
            end
        end
        return is_enough
    end
    return false
end
---------------------------------------天赋红点结束-------------------------------------------

---------------------------------------神装红点结束-------------------------------------------
function HeroCalculate.checkSingleHeroHolyEquipmentRedPoint(hero_vo)
    if not hero_vo then return false end
    local is_open = HeroController:getInstance():getModel():isOpenHolyEquipMentByHerovo(hero_vo)
    if not is_open then --没开启不判断
        return false
    end
    local equip_list = HeroController:getInstance():getModel():getHeroHolyEquipList(hero_vo.partner_id)

    if equip_list then
        local equip_type_list = HeroConst.HolyequipmentPosList
        for i,equip_type in ipairs(equip_type_list) do
            if equip_list[equip_type] == nil then
                local is_redpoint = HeroCalculate.checkHolyEquipmentByEquipType(equip_type)
                if is_redpoint then
                    return true
                end
            end
        end
    end
    return false
end

function HeroCalculate.checkHolyEquipmentByEquipType(equip_type)
    local equip_type = equip_type or 1
    local backpack_model = BackpackController:getInstance():getModel()
    local equip_score_list = backpack_model:getAllEquipListByType(equip_type)
    if not equip_score_list then return false end
    if next(equip_score_list)~= nil then
        return true
    end
    return false
end
---------------------------------------神装红点结束-------------------------------------------

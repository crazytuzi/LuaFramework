-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-05-13
-- --------------------------------------------------------------------
PartnersummonModel = PartnersummonModel or BaseClass()

function PartnersummonModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function PartnersummonModel:config()
    self.is_open_view = false -- 是否从主城打开过召唤界面（计算红点）
    self.recruit_data = {} -- 每个卡库的数据
    self.share_data = {}   -- 召唤分享数据
end

-- 设置召唤数据
function PartnersummonModel:setSummonData(data)
    if data then
        self.recruit_data = data.recruit_list
        self:setShareData(data)
        self:updateRedPoint()
        self:setFiveStarHeroIsOut(data.must_five_num)
        GlobalEvent:getInstance():Fire(PartnersummonEvent.updateSummonDataEvent, data)
    end
end
--五星的英雄10之内是否出来
function PartnersummonModel:setFiveStarHeroIsOut(out)
    self.five_star_hero = out
end
function PartnersummonModel:getFiveStarHeroIsOut()
    if self.five_star_hero then
        return self.five_star_hero
    end
    return 0
end

--更新某个\些卡库的数据
function PartnersummonModel:updateRecruitData( dataList )
    local group_ids = {}
    for k,newData in pairs(dataList) do
        for _,oldData in pairs(self.recruit_data) do
            if newData.group_id == oldData.group_id then
                table.insert(group_ids, newData.group_id)
                for key,value in pairs(newData) do
                    oldData[key] = value
                end
                break
            end
        end
    end
    GlobalEvent:getInstance():Fire(PartnersummonEvent.updateSummonSingleDataEvent, group_ids)
end

-- 更新某个卡库的CD时间、次数等数据
function PartnersummonModel:updateExtendData( data )
    local group_ids = {}
    for _,group_data in pairs(self.recruit_data) do
        if group_data.group_id == data.group_id then
            table.insert(group_ids, data.group_id)
            local draw_list = group_data.draw_list
            if draw_list then
                for k,v in pairs(draw_list) do
                    if v.times == 1 and v.kv_list then
                        if data.free_times then
                            self:updateKeyValList(v.kv_list, PartnersummonConst.Recruit_Key.Free_Count, data.free_times)
                        end
                        if data.free_cd_end then
                            self:updateKeyValList(v.kv_list, PartnersummonConst.Recruit_Key.Free_Time, data.free_cd_end)
                        end
                        break
                    end
                end
            end
        end
    end
    self:updateRedPoint()
    GlobalEvent:getInstance():Fire(PartnersummonEvent.updateSummonSingleDataEvent, group_ids)
end

-- 更新数据
function PartnersummonModel:updateKeyValList( kv_list, key, val )
    local is_have = false
    for _,kv in pairs(kv_list) do
        if kv.key == key then
            kv.val = val
            is_have = true
            break
        end
    end
    if is_have == false then
        local temp_kv = {}
        temp_kv.key = key
        temp_kv.val = val
        table.insert(kv_list, temp_kv)
    end
end

-- 设置分享数据
function PartnersummonModel:setShareData(data)
    if data then
        self.share_data = {is_share = data.is_share, is_day_share = data.is_day_share}
        GlobalEvent:getInstance():Fire(PartnersummonEvent.updateSummonShareDataEvent, data)
    end
end

function PartnersummonModel:getShareData()
    if self.share_data or next(self.share_data or {}) then
        return self.share_data
    end
end

--获取对应ID召唤组的服务端数据
function PartnersummonModel:getSummonProtoDataByGroupID(group_id)
    if self.recruit_data then
        local temp_data = {}
        if next(self.recruit_data or {}) ~= nil then
            for i, v in ipairs(self.recruit_data) do
                if v.group_id == group_id then
                    temp_data = v
                    break
                end
            end
        end
   
        return temp_data
    end
end

--获取所有开启的卡库id
function PartnersummonModel:getOpenSummonData()

end

-- 获取卡库列表数据（包含配置数据、服务端数据）
function PartnersummonModel:getSummonGroupData(  )
    local group_datas = {}
    local base_config = Config.RecruitData.data_partnersummon_data
    if base_config then
        for k,config in pairs(base_config) do
            if config.is_show == 0 then
                local proto_data = self:getSummonProtoDataByGroupID(config.group_id)
                table.insert(group_datas,{info_data = config, proto_data = proto_data, group_id = config.group_id})
            end
        end

        local function sortFunc( objA, objB )
            if objA.info_data.sort_id and objB.info_data.sort_id then
                return objA.info_data.sort_id < objB.info_data.sort_id
            else
                return false
            end
        end
        table.sort(group_datas, sortFunc)
    end
    return group_datas
end

-- 获取某一卡库的数据（包含配置数据、服务端数据）
function PartnersummonModel:getSummonGroupDataByGroupId( group_id )
    local group_data = {}
    local base_config = Config.RecruitData.data_partnersummon_data
    if base_config then
        local config = {}
        for k,v in pairs(base_config) do
            if v.group_id == group_id then
                config = v
                break
            end
        end
        local proto_data = self:getSummonProtoDataByGroupID(group_id)
        group_data = {info_data = config, proto_data = proto_data, group_id = group_id}
    end
    return group_data
end

-- 获取积分召唤所需的积分数
function PartnersummonModel:getScoreSummonNeedCount(  )
    local count = 0
    if Config.RecruitData.data_partnersummon_data[PartnersummonConst.Summon_Type.Score] then
        local exchange_once = Config.RecruitData.data_partnersummon_data[PartnersummonConst.Summon_Type.Score].exchange_once
        if exchange_once[1] then
            count = exchange_once[1][2] or 0
        end
    end
    return count
end

-- 更新红点
function PartnersummonModel:updateRedPoint()
    --是否有免费
    local is_show_red = false
    for k,rData in pairs(self.recruit_data) do
        if rData.draw_list then
            for _,dData in pairs(rData.draw_list) do
                if dData.kv_list then
                    for _,kv in pairs(dData.kv_list) do
                        if kv.key == PartnersummonConst.Recruit_Key.Free_Count and kv.val > 0 then
                            is_show_red = true
                            break
                        end
                    end
                end
            end
        end
    end
    -- 是否没从主城打开过召唤界面并且有召唤道具
    if not is_show_red and not self.is_open_view then
        local normal_item_num = BackpackController:getInstance():getModel():getItemNumByBid(PartnersummonConst.Normal_Id)
        local advanced_item_num = BackpackController:getInstance():getModel():getItemNumByBid(PartnersummonConst.Advanced_Id)
        if normal_item_num > 0 or advanced_item_num > 0 then
            is_show_red = true
        end
    end
    MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.summon, is_show_red)
end

-- 设置是否从主城打开过召唤界面
function PartnersummonModel:setOpenPartnerSummonFlag( status )
    self.is_open_view = status
    self:updateRedPoint()
end

function PartnersummonModel:getOpenPartnerSummonFlag(  )
    return self.is_open_view
end

function PartnersummonModel:__delete()
end

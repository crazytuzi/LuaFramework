--[[
    * 类注释写在这里-----------------
    * @author {AUTHOR}
    * <br/>Create: 2016-12-09
]]
RoleModel = RoleModel or BaseClass()

function RoleModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function RoleModel:config()
    self.role_vo = nil

    self.role_srv_day  =0 -- 无效，以下面的为准
    self.role_register_day = 0
    self.world_lev = 0
    self.open_srv_day = 0 -- 开服天数
    self.privilege_data = {} -- 特权激活状态

    --粉丝排行榜的数据
    self.fans_rank_data = nil

    --self.dic_role_growth_way[order] = data
    self.dic_role_growth_way = nil
    --他人的成长之路 只保存一个
    self.dic_other_growth_way = {}

    --留言信息存储结构 self.dic_message_board_list[srv_id_rid][bbs_id] = data
    self.dic_message_board_list = nil

    --成长之路嘉年华信息
    self.growth_way_carnival_data = nil

    --默认的城市音效 --测试音效 --"lwc"
    -- self.city_music_name = "s_002"

    self.red_point_data = {} --功能每天首次红点
end

-- 设世界等级
function RoleModel:setWorldLev(lev) 
    self.world_lev = lev
end

-- 获取世界等级
function RoleModel:getWorldLev()
    return self.world_lev
end

-- 设置开服天数
function RoleModel:setOpenSrvDay( day )
    self.open_srv_day = day
end

-- 获取开服天数
function RoleModel:getOpenSrvDay(  )
    return self.open_srv_day
end

-- 合服列表
function RoleModel:setServerList(data)
    self.serverList = {}
    for k, v in pairs(data) do
        self.serverList[v.srv_id] = 1
    end
end

-- 是否在本服里面
function RoleModel:isTheSame(srv_id)
    if self.serverList and srv_id then
        return self.serverList[srv_id] ~= nil
    end
    return true
end

--初始化角色基础数据
function RoleModel:initRoleBaseData(data_list)  
    self:initAttribute(data_list)
    dump(data_list, "--------------------------------------------角色数据----->")
    --派发事件
    self.role_vo:dispatchUpdateBaseAttr()
end

--资产信息改变
function RoleModel:initRoleAssetsData(data_list)
    self:initAttribute(data_list)
    --派发事件
    -- self.role_vo:dispatchUpdateAssets()
end

--活动资产信息改变
function RoleModel:initRoleActionAssetsData(holiday_assets, is_update)
    if not self.role_vo then
        self.role_vo = RoleVo.New()
    end

    if holiday_assets then
        self.role_vo:initActionAssetsData(holiday_assets, is_update)
    end
end

--记录玩家的注册天数以及所在服开服时间
function RoleModel:setSrvDay(data)
    if not data then return end
    self.role_srv_day =  data.open_time or 0                -- 开服时间
    self.role_register_day = data.reg_time or 0             -- 注册时间

    -- 特殊处理
    -- if self.role_srv_day < 1541347200 then
    --     require "config.temp_days_rank_data"
    -- end
end
--获取玩家的注册天数
function RoleModel:getRegisterDay()
    return self.role_register_day or 0
end
--所在服开服时间
function RoleModel:getSrvDay()
    return self.role_srv_day or 0
end
--资产更新
function RoleModel:updateRoleAssets(data)
    if self.role_vo then
        self.role_vo:setRoleAssset(data)
    end
end

-- 更新角色头像列表
function RoleModel:updateRoleHeadList(data)
    if self:getRoleVo() then
        self:getRoleVo():setRoleHeadList(data)
    end
end

-- 更新角色单个属性
function RoleModel:setRoleAttribute(key, value)
    if self.role_vo ~= nil then
        self.role_vo:setRoleAttribute(key, value)
    end
end

--所有属性改变都可以用这个
function RoleModel:initAttribute(data_list)
    if not self.role_vo then
        self.role_vo = RoleVo.New()
    end

    if data_list then
        self.role_vo:initAttributeData(data_list)
    end
end

-- 设置特权激活状态数据
function RoleModel:setPrivilegeData( data )
    self.privilege_data = data or {}
end

function RoleModel:getPrivilegeData(  )
    return self.privilege_data
end
-- 1快速作战特权 2远航普通特权 3远航高级特权 4元素圣殿特权 5特权灵窝
function RoleModel:checkPrivilegeStatus( id )
    local status = false
    for k,v in pairs(self.privilege_data) do
        if v.id == id then
            status = (v.status == 1)
            break
        end
    end
    return status
end

-- 1快速作战特权 2远航普通特权 3远航高级特权 4元素圣殿特权 5特权灵窝
function RoleModel:getPrivilegeDataById( id )
    for k,v in pairs(self.privilege_data) do
        if v.id == id then
            return v
        end
    end
end

--角色数据vo
function RoleModel:getRoleVo()
    return self.role_vo
end

--获取徽章点数对应的名字
function RoleModel:getHonorPointName(point)
    local point = point or 0
    local list = Config.RoomFeatData.data_honor_title_info
    if not list then return  end
    table.sort( list, function(a,b) return a.min < b.min end)

    local count = #list
    for i,v in ipairs(list) do
        if point >= v.min and point <= v.max then
            if i >= count then
                return v.name, v.res_id, -1
            else
                return v.name, v.res_id, list[i + 1].min, list[i + 1].name, list[i + 1].res_id 
            end
        end
    end
    if next(list) ~= nil then
       return list[count].name , list[count].res_id, -1
    end
end

--@data 协议 25830的协议结构
function RoleModel:setGrowthWayData(data)
    self.growth_way_max_count = data.max_num
    if not self.dic_role_growth_way then 
        self.dic_role_growth_way = {}
    end
    for i,v in ipairs(data.progress) do
        if self.dic_role_growth_way[v.order] == nil then
            --要判断空  要不然会覆盖在那边初始化的值
            self.dic_role_growth_way[v.order] = v
        end
    end
end

--检查是否有新的.有就有红点
function RoleModel:checkGrowthWayRedPoint(data)
    if self.dic_role_growth_way and data and #data.progress > 0 then 
        local order = data.progress[1].order
        if order and self.dic_role_growth_way[order] == nil then
            return true
        end
    end
    return false
end

--获取成长之路信息
function RoleModel:getGrowthWayData()
    return self.dic_role_growth_way or {}
end



--@data 协议 25832的协议结构
function RoleModel:setOtherGrowthWayData(data)
    if not self.dic_other_growth_way then 
        self.dic_other_growth_way = {}
    end
    local key = string.format("%s_%s", data.srv_id, data.rid)   
    if self.dic_other_growth_way[key] == nil then
        self.dic_other_growth_way[key] = {}
    end

    for i,v in ipairs(data.room_grow_info) do
        if self.dic_other_growth_way[key][v.order] == nil then
            --要判断空  要不然会覆盖在那边初始化的值
            self.dic_other_growth_way[key][v.order] = v
        end
    end
end

--获取成长之路信息
function RoleModel:getOtherGrowthWayData(rid, srv_id)
    if self.dic_other_growth_way  == nil then
        return {}
    end

    local key = string.format("%s_%s", srv_id, rid)  
    return self.dic_other_growth_way[key] or {}
end

--留言板数据
function RoleModel:initMessageBoardData(data)

    if self.dic_message_board_list == nil then
        self.dic_message_board_list = {}
    end

    local key
    if data.rid == nil or data.srv_id == nil then
        local role_vo = self:getRoleVo()
        if not role_vo then return end
        key = self:getKeyBySrvidAndRid(role_vo.srv_id, role_vo.rid)
    else
        key = self:getKeyBySrvidAndRid(data.srv_id, data.rid)
    end

    if self.dic_message_board_list[key] == nil then
        self.dic_message_board_list[key] = {}
    end
    self.message_board_max_count = data.max_num
    for i,v in ipairs(data.room_bbs_info) do
        self.dic_message_board_list[key][v.bbs_id] = v
    end
end

--根据id 删除留言板数据
function RoleModel:deleteMessageBoardDataByBbsid(bbs_id)
    if not bbs_id then return end
    local role_vo = self:getRoleVo()
    if not role_vo then return end
    local key = self:getKeyBySrvidAndRid(role_vo.srv_id, role_vo.rid)
    
    if self.dic_message_board_list and self.dic_message_board_list[key] then
        self.dic_message_board_list[key][bbs_id] = nil
    end
end

function RoleModel:getKeyBySrvidAndRid( srv_id, rid )
    return string.format("%s_%s", srv_id, rid)
end

--获取留言信息
function RoleModel:getMessageBoardData( srv_id, rid )
    local key = self:getKeyBySrvidAndRid(srv_id, rid)
    if self.dic_message_board_list and self.dic_message_board_list[key] then
        return self.dic_message_board_list[key]
    end
    return {}
end

function RoleModel:removeMessageBoardData( srv_id, rid )
    local key = self:getKeyBySrvidAndRid(srv_id, rid)
    if self.dic_message_board_list and self.dic_message_board_list[key] then
        self.dic_message_board_list[key] = nil
    end
end

function RoleModel:setGrowthWayCarnivalData(data)
    self.growth_way_carnival_data = data
end

--获取嘉年华信息:
--结构: data.id : data_growth_way_desc表id (0表示无)
 --     data.nmae: 宝可梦名字
function RoleModel:getGrowthWayCarnivalData(data)
    return self.growth_way_carnival_data
end

-- 自定义头像相关
function RoleModel:updateCustomFace(face_file, face_update_time)
    if self.role_vo then
        self.role_vo:setRoleAttribute("face_file", face_file)
        self.role_vo:setRoleAttribute("face_update_time", face_update_time)
    end
end

--设置功能红点数据
function RoleModel:setRedPointData(data)
    if data then
        self.red_point_data = data.id_list
    end
end

--获取功能红点数据
function RoleModel:getRedPointStatus(id)
    if self.red_point_data then
        for k,v in pairs(self.red_point_data) do
            if v.id == id then
                return false
            end
        end
    end
    return true
end

--更新功能红点数据
function RoleModel:updateRedPointData(id)
    if self.red_point_data then
        for k,v in pairs(self.red_point_data) do
            if v.id == id then
                return
            end
        end
        table.insert( self.red_point_data,{id = id} )
    end
end

function RoleModel:__delete()
    self.role_vo = nil
end

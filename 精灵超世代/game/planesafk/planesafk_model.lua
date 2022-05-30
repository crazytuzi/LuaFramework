-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      位面改版 参考afk的 后端 国辉 策划 中建
-- <br/>Create: 2020-02-05
-- --------------------------------------------------------------------
PlanesafkModel = PlanesafkModel or BaseClass()

function PlanesafkModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function PlanesafkModel:config()
    --当前地图id 
    self.map_id = nil
    --地图数据
    self.map_config = nil

    --角色当前位置
    self.cur_line = nil
    self.cur_index = nil

    --是否显示探索完毕
    self.is_show_search_finish = nil

    --登陆红点(一定要赋值 nil)
    self.planesafk_login_redpoint = nil
end

function PlanesafkModel:setIsShowSearchFinish(is_show)
    self.is_show_search_finish = is_show
end

function PlanesafkModel:getIsShowSearchFinish()
    return self.is_show_search_finish
end

-- 设置形象id
function PlanesafkModel:setPlanesRoleLookId( look_id )
    self.planes_look_id = look_id 
end

function PlanesafkModel:getPlanesRoleLookId(  )
    return self.planes_look_id 
end
-- 设置地图id
function PlanesafkModel:setMapData( data )
    if not data then return end
    if data.map_id then
        self.map_id = data.map_id
        self.map_config = Config.PlanesData.data_customs[self.map_id]
    end
end
--更新角色位置
function PlanesafkModel:updateRolePos(data)
    self.cur_line = data.line or 1
    self.cur_index = data.index or 3
end

function PlanesafkModel:getMapID( )
    return self.map_id or 1
end

--获取地图资源id
function PlanesafkModel:getMapResID( )
    if self.map_config then
        return self.map_config.res_id or "11"
    end
    return "11"
end

--获取角色位置
--@ return 当前行 ,当前索引
function PlanesafkModel:getRolePos()
    local cur_line = self.cur_line or 1
    local cur_index = self.cur_index or 3
    return cur_line, cur_index
end

--是否活动开启中
function PlanesafkModel:isHolidayOpen()
    return self.is_holiday_open
end

--设置活动开启中
function PlanesafkModel:setHolidayOpen(is_holiday)
    if is_holiday then
        self.is_holiday_open = (is_holiday == 1)
    end
end

-- 设置所有宝可梦数据
function PlanesafkModel:setAllPlanesHeroData( data )
    self.planes_hero_data = data
end

function PlanesafkModel:getAllPlanesHeroData(  )
    return self.planes_hero_data
end

function PlanesafkModel:getPlanesHireHeroData( id )
    if not self.planes_hero_data then return end
    for k,v in pairs(self.planes_hero_data) do
        if v.flag == 1 and v.partner_id == id then
            return v
        end
    end 
end

-- 更新我方宝可梦血量数据
function PlanesafkModel:updateMyHeroData( data_list )
    if not self.planes_hero_data then return end
    for _,n_data in pairs(data_list) do
        for k,o_data in pairs(self.planes_hero_data) do
            if o_data.flag == n_data.flag and o_data.partner_id == n_data.partner_id then
                o_data.hp_per = n_data.hp_per
                break
            end
        end 
    end
    GlobalEvent:getInstance():Fire(PlanesafkEvent.Get_Hero_Live_Event)
    
end

-- 获取宝可梦的剩余血量
function PlanesafkModel:getMyPlanesHeroHpPer( partner_id, flag )
    if not self.planes_hero_data then return end
    local hp_per = 100
    flag = flag or 0
    for k,v in pairs(self.planes_hero_data) do
        if v.flag == flag and v.partner_id == partner_id then
            hp_per = v.hp_per or 100
            break
        end
    end
    return hp_per
end

-- 是否有不满血的宝可梦
function PlanesafkModel:checkIsHaveHpNotFullHero(  )
    if not self.planes_hero_data then return end
    local is_have = false
    for k,v in pairs(self.planes_hero_data) do
        if v.hp_per < 100 then
            is_have = true
            break
        end
    end
    return is_have
end

-- 是否有死亡的宝可梦
function PlanesafkModel:checkIsHaveDieHero(  )
    if not self.planes_hero_data then return end
    local is_have = false
    for k,v in pairs(self.planes_hero_data) do
        if v.hp_per <= 0 then
            is_have = true
            break
        end
    end
    return is_have
end

-- 获取背景图标资源
function PlanesafkModel:getBgPathByResId( res_id )
    if res_id and res_id ~= "" then
        return string.format("resource/planes/grid_icon/%s.png", res_id)
    end
end

function PlanesafkModel:getPlanesAfkRedStatus(  )
    local red_status = self:getOrderactionRedpoint() or self.planesafk_login_redpoint
    return red_status
end

function PlanesafkModel:checkPlanesafkRedPoint()
    local is_show_red = false
    is_show_red = self:getPlanesAfkRedStatus()
    MainuiController:getInstance():setBtnRedPoint(MainuiConst.btn_index.esecsice, {bid=RedPointType.heroexpedit, status=is_show_red}) 
    GlobalEvent:getInstance():Fire(PlanesafkEvent.Update_Planes_Red_Event)
end

function PlanesafkModel:setPlanesafkLoginRedpointFalse()
    self.planesafk_login_redpoint = false
    self:checkPlanesafkRedPoint()
end

function PlanesafkModel:checkPlaneafkCanExploreRedPoint(data)
    if data and self.planesafk_login_redpoint == nil then
        self.planesafk_login_redpoint = false
        local planes_max_floor = 3
        local config = Config.PlanesData.data_const.planes_max_floor
        if config then
            planes_max_floor = config.val
        end
        if data.floor < planes_max_floor then
            self.planesafk_login_redpoint = true
        else
            if data.is_can_reward == 1 and data.is_reward == 1 then
                -- self.planesafk_login_redpoint = false
            else
                self.planesafk_login_redpoint = true
            end
        end
    end
    self:checkPlanesafkRedPoint()
end

--------------------------------战令-----------------------------------
function PlanesafkModel:setOrderactionData(data)
    self.orderaction_data = data
    if data then
        self:setGiftStatus(data.rmb_status)
    end
end

--获取当前周期
function PlanesafkModel:getCurPeriod()
	if self.orderaction_data and self.orderaction_data.period then
		return self.orderaction_data.period
	end
	return 1
end

--获取特权状态
function PlanesafkModel:getGiftStatus()
	if self.rmb_status then
		return self.rmb_status
	end
	return 0
end

function PlanesafkModel:getLevShowData(lev)
	if self.orderaction_data and self.orderaction_data.list and self.orderaction_data.list[lev] then
		return self.orderaction_data.list[lev]
	end
	return nil
end

--获取胜场
function PlanesafkModel:getWinCounts()
	if self.orderaction_data and self.orderaction_data.win_count then
		return self.orderaction_data.win_count
	end
	return 0
end

function PlanesafkModel:getCurDay()
	if self.orderaction_data and self.orderaction_data.cur_day then
		return self.orderaction_data.cur_day
	end
	return 1
end

function PlanesafkModel:setOrderactionRedStatus(status)
    self.orderaction_first_red_status = status
end

--设置特权状态
function PlanesafkModel:setGiftStatus(status)
	self.rmb_status = status
end

--获取战令红点
function PlanesafkModel:getOrderactionRedpoint()
    if self.orderaction_first_red_status == 1 then
        return true
    end

    if not self.orderaction_data then return false end

    local lev_reward_list = Config.ArenaEliteWarOrderData.data_lev_reward_list
    if lev_reward_list and lev_reward_list[self.orderaction_data.period] then
        for i,v in ipairs(lev_reward_list[self.orderaction_data.period]) do --self.orderaction_data.list
            local status = 0
	    	local rmb_status = 0
            local lev_list = self:getLevShowData(v.lev)
            if lev_list then
                status = lev_list.award_status
                rmb_status = lev_list.rmb_award_status
            end
            if v.lev <= self.orderaction_data.lev then
                if status == 0 then --可领
                    return true
                elseif rmb_status == 0 and self.orderaction_data.rmb_status == 1 then --可领
                    return true
                end
            end
        end
    end
    
    return false
end

--获取战令入口是否显示
function PlanesafkModel:getOrderIsShow()
	local configlv = Config.PlanesWarOrderData.data_constant.limit_lev
    local configday = Config.PlanesWarOrderData.data_constant.open_srv_day
    local open_srv_day = RoleController:getInstance():getModel():getOpenSrvDay()
    local rolevo = RoleController:getInstance():getModel():getRoleVo()
    -- 是否开启planes_war_order_data:
    if configday and configlv and rolevo and (open_srv_day < configday.val or rolevo.lev < configlv.val) then
        return false
    end
    return true
end


---------------------------------end-------------------------------------

function PlanesafkModel:__delete()
end
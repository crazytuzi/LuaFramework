-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--     冒险玩法UI数据处理
-- <br/>Create: 2018-05-22
-- --------------------------------------------------------------------
AdventureUIModel = AdventureUIModel or BaseClass()

function AdventureUIModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function AdventureUIModel:config()
    self.room_list = {}     -- 所有房间的
    self.base_data = {}     -- 当前冒险的基础数据
    self.buff_data = {}     -- buff数据
    self.holiday_buff_data = {} -- 活动buff数据

    self.form_list = {}     -- 当前上阵伙伴信息
    self.select_partner_id = 0  -- 当前选中的伙伴id

    self.red_status = false

    self.backpack_list = {}
    self.plist = {} --伙伴死亡情况信息
    self.before_room = 0
    self.plunder_record_list = {} --防御布阵掠夺记录
    self.is_first_record_red = true

    self.dic_mine_hero_list = {}

    --矿脉的挑战购买次数
    self.mine_buy_count = 0
    --矿脉的挑战次数
    self.challenge_count = 0


    --秘矿记录的红点
    self.mine_record_redpoint = false
    --秘矿挑战次数红点
    self.mine_count_redpoint = false

    --已达次数
    self.had_combat_num = 0
    --秘矿宝箱领取
    self.dic_receive_num = {}

    self.is_back_20647 = false
    self.is_back_20657 = false
    self.is_back_20659 = false

    --当前矿脉占领个数
    self.mine_occupy_count = 0
end


function AdventureUIModel:setScdata20647( data)
    self.is_back_20647 = true
    if not data then return end
    self.challenge_count = data.count

    self.had_combat_num = data.had_combat_num
    self.dic_receive_num = {}
    for i,v in ipairs(data.num_list) do
        self.dic_receive_num[v.num] = true
    end

    if self.is_back_20647 and self.is_back_20657 and self.is_back_20659 then
        self:checkRedPoint()
    end
end

function AdventureUIModel:setReceiveByNum(num)
    if self.dic_receive_num and num then
        self.dic_receive_num[num] = true
        self:checkRedPoint()
    end
end

--判断是否有红点
--is_not_check 不用处理主界面红点
function AdventureUIModel:checkRedPoint(is_not_check)
    -- body
    local is_redpoint = false
    --写死大于10层的时候才会有矿脉出现 也没想到什么好方法判断矿脉层开了
    if self.base_data and self.base_data.pass_id and self.base_data.pass_id >= 10 then
        is_redpoint = self.mine_record_redpoint
        if not is_redpoint then
            if self.mine_count_redpoint and self.challenge_count and self.challenge_count > 0 then
                is_redpoint = true
            else
                local box_reward_list = Config.AdventureMineData.data_box_reward
                if box_reward_list and self.dic_receive_num and self.had_combat_num then
                    for i,v in ipairs(box_reward_list) do
                        if self.had_combat_num >= v.num and not self.dic_receive_num[v.num] then
                            is_redpoint = true
                            break
                        end
                    end
                end
            end
        end
    end
    if not is_not_check then
        MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.adventure, {bid = AdventureActivityConst.Red_Type.adventure_mine, status = is_redpoint})
    end
    return is_redpoint
end


function AdventureUIModel:isMineRecordRedpoint()
    return self.mine_record_redpoint == true
end

function AdventureUIModel:setMineRecordRedpoint(is_redpoint)
    self.is_back_20657 = true
    if is_redpoint ~= nil then
        self.mine_record_redpoint = is_redpoint
    else
        self.mine_record_redpoint = false
    end

    if self.is_back_20647 and self.is_back_20657 and self.is_back_20659 then
        self:checkRedPoint()
    end
end

--设置挑战次数红点
function AdventureUIModel:setMineCountRedpoint(is_redpoint)
    self.is_back_20659 = true
    if is_redpoint ~= nil then
        self.mine_count_redpoint = is_redpoint
    else
        self.mine_count_redpoint = false
    end
    if self.is_back_20647 and self.is_back_20657 and self.is_back_20659 then
        self:checkRedPoint()
    end
end

function AdventureUIModel:setMineBuyCount( count )
    if count then
        self.mine_buy_count = count 
    end
end
function AdventureUIModel:getMineBuyCount(  )
    return self.mine_buy_count or 0
end

function AdventureUIModel:setChallengeCount( count )
    if count then
        local old_count = self.challenge_count
        self.challenge_count = count 

        if old_count and old_count ~= self.challenge_count then
            --有变化
            self:checkRedPoint()
            GlobalEvent:getInstance():Fire(AdventureEvent.ADVENTURE_MINE_CHALLEAGE_RED_POINT_EVENT)
        end
    end
end
function AdventureUIModel:getChallengeCount(  )
    return self.challenge_count or 0
end

--秘矿冒险的防守阵营信息
function AdventureUIModel:updateMineDefenseInfo(data)
    if not data then return end
    for id, hero_vo in pairs(self.dic_mine_hero_list) do
        if hero_vo.updateFormPos then
            if hero_vo.updateFormPos then
                hero_vo:updateFormPos(0, PartnerConst.Fun_Form.Adventure_Mine_Def)
            end
        end
    end
    self.dic_mine_hero_list = {}
    local model =  HeroController:getInstance():getModel()
    
    for i,v in ipairs(data.defense) do
        local hero_vo = model:getHeroById(v.id)
        if hero_vo then
            self.dic_mine_hero_list[v.id] = hero_vo
            if hero_vo.updateFormPos then
                --这里有点奇怪.bugly说updateFormPos is a nil value  说明hero的hero_list的对象里面有某个hero_vo的其他对象混了进来..
                hero_vo:updateFormPos(1, PartnerConst.Fun_Form.Adventure_Mine_Def)
            end
        end
    end
end
--连续战斗的次数
function AdventureUIModel:setFightSkipCount(count)
    self.fight_skip_count = count
end
function AdventureUIModel:getFightSkipCount()
    if self.fight_skip_count then
        return self.fight_skip_count
    end
    return 0
end

--获取战斗返回标志
function AdventureUIModel:setAdventureFightReturnTag(fight_return)
    self.fight_return = fight_return
end
function AdventureUIModel:getAdventureFightReturnTag()
    if self.fight_return then
        return self.fight_return
    end
    return false
end
--==============================--
--desc:获取当前上阵伙伴信息
--time:2019-01-24 02:16:50
--@data:
--@return 
--==============================-- 
function AdventureUIModel:updateFormPartner(data, partner_id)
    self.form_list = data
    self.select_partner_id = partner_id

    -- 这里判断一下如果列表为空,则显示一个红点,,,,,
    self:updateRedStatus(#data == 0)

    GlobalEvent:getInstance():Fire(AdventureEvent.UpdateAdventureForm)
end

function AdventureUIModel:updateRedStatus(status)
    self.red_status = status

    local is_open = AdventureActivityController:getInstance():isOpenActivity(AdventureActivityConst.Ground_Type.adventure)
    if is_open == false then
        self.red_status = false
    end
    MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.adventure, {bid = AdventureActivityConst.Red_Type.adventure, status = status})
end
--宝箱领取红点
function AdventureUIModel:setAdventureBoxStatus(data)
    self.box_status_list = {}
    for i,v in pairs(data.list) do
        self.box_status_list[v.id] = v.status
    end
    local red_point = false
    for i,v in pairs(data.list) do
        if v.status == 1 then
            red_point = true
            break
        end
    end
    self.box_redpoint = red_point
    GlobalEvent:getInstance():Fire(AdventureEvent.UpdateAdventureForm)

    local scene_adventure_redpiont = self:getAdventureRedPoint()
    MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.adventure, {bid = AdventureActivityConst.Red_Type.adventure, status = scene_adventure_redpiont})
end
function AdventureUIModel:getAdventureBoxStatus(id)
    if self.box_status_list and self.box_status_list[id] then
        return self.box_status_list[id]
    end
    return 0
end
--冒险红点
function AdventureUIModel:getAdventureRedPoint()
    local status = self.red_status or false
    local box_status = self.box_redpoint or false
    return (self.red_status or box_status)
end

function AdventureUIModel:getFormList()
    return self.form_list
end

--==============================--
--desc:全部伙伴是否都已经死亡
--time:2019-01-28 11:45:41
--@return 
--==============================--
function AdventureUIModel:allHeroIsDie()
    local is_die = true
    for k,v in pairs(self.form_list) do
        if v.now_hp ~= 0 then
            is_die = false
            break
        end
    end
    return is_die
end

function AdventureUIModel:getSelectPartnerID()
    return self.select_partner_id
end

function AdventureUIModel:updateSelectPartnerID(id)
    self.select_partner_id = id
    GlobalEvent:getInstance():Fire(AdventureEvent.UpdateAdventureSelectHero)
end

function AdventureUIModel:__delete()
    if self.role_vo ~= nil then
        if self.role_assets_event ~= nil then
            self.role_vo:UnBind(self.role_assets_event)
            self.role_assets_event = nil
        end
        self.role_vo = nil
    end
end

--==============================--
--desc:冒险的基础信息,对应协议的20600
--time:2018-10-13 09:28:35
--@data:
--@return 
--==============================--
function AdventureUIModel:setAdventureBaseData(data)
    self.base_data = data
    GlobalEvent:getInstance():Fire(AdventureEvent.Update_Room_Base_Info)
end

function AdventureUIModel:getAdventureBaseData()
    return self.base_data
end

function AdventureUIModel:setBuffData(data)
	self.buff_data = data.buff_list
    self.holiday_buff_data = data.holiday_buff_list
	GlobalEvent:getInstance():Fire(AdventureEvent.Update_Buff_Info)
end
function AdventureUIModel:getBuffData()
	if self.buff_data and next(self.buff_data or {}) ~= nil then
		return self.buff_data
	end
end
function AdventureUIModel:getHolidayBuffData(  )
    if self.holiday_buff_data and next(self.holiday_buff_data or {}) ~= nil then
        return self.holiday_buff_data
    end
end

function AdventureUIModel:setRoomList(data)
    if data == nil or data.room_list == nil then return end
    for i, v in ipairs(data.room_list) do
        self.room_list[v.id] = v
    end
	GlobalEvent:getInstance():Fire(AdventureEvent.Update_Room_Info)
end

function AdventureUIModel:getRoomList()
	if self.room_list and next(self.room_list or {}) ~= nil then
		return self.room_list
	end
end

function AdventureUIModel:updateRoomList(data)
    for i, v in ipairs(data.room_list) do
        local room = self.room_list[v.id]
        if room then
            room.status = v.status
            room.lock = v.lock
            room.evt_id = v.evt_id
            -- 如果对应的事件配置了自动开启，则当房间状态变为开启时，发送获取协议
            if room.status == AdventureConst.status.open then
                local evt_config = Config.AdventureData.data_adventure_event(room.evt_id)
                if evt_config and evt_config.auto_open == 1 then
                    delayOnce(function ()
                        AdventureController:getInstance():send20620(room.id, AdventureEvenHandleType.handle, {{type=4,val=1}})
                    end, (i-1)*0.5+1)
                end
            end
        end
    end
    GlobalEvent:getInstance():Fire(AdventureEvent.Update_Single_Room_Info,data)
end

function AdventureUIModel:getRoomInfoByRoomID(id)
    if self.room_list and next(self.room_list or {}) ~= nil then
        local data = nil
        for i, v in ipairs(self.room_list) do
            if v.id == id then
               data = v
               break
            end
        end
        return data
    end
end

function AdventureUIModel:getCurIndex(reset_num, config)
	local idx = reset_num + 1
	local free_num = 0
	local cost_num = 0
	local vip_lev = RoleController:getInstance():getRoleVo().vip_lev
	while config[idx] do
		if config[idx].cost == 0 then
			free_num = free_num + 1
		else
			if vip_lev >= config[idx].vip then
				cost_num = cost_num + 1
			end
		end
		idx = idx + 1
	end
	return free_num, cost_num
end

--计算衰减
--返回衰减值
function AdventureUIModel:getMineRate(floor, count)
    if not self.base_data or not floor or not count then return 0 end
    local id = math.floor((self.base_data.pass_id - floor)/10) * 10
    local attenuation_config = Config.AdventureMineData.data_attenuation_reward[id]
    if attenuation_config then
        local num = count * (1 - attenuation_config.dec_rate/1000)
        return math.floor(num + 0.5), attenuation_config.dec_rate
    end
    return count
end

--返回解锁数量
function AdventureUIModel:getMineLockCount()
    local count = 0
    local role_vo = RoleController:getInstance():getRoleVo()
    local config_list = Config.AdventureMineData.data_mine_unlock_info
    for k,config in pairs(config_list) do
        if next(config.open_cond) ~= nil then
            local con = config.open_cond[1]
            if con[1] == "lev" then
                if role_vo and role_vo.lev >= con[2] then
                   count = count + 1
                end
            elseif con[1] == "vip" then
                if role_vo and role_vo.vip_lev >= con[2] then
                    count = count + 1
                end
            end
        else
            count = count +1
        end
    end
    return count
end

function AdventureUIModel:setMineOccupyCount(count)
    self.mine_occupy_count = count or 0
end

function AdventureUIModel:getMineOccupyCount()
    return self.mine_occupy_count
end

-- 上一轮通关层数
function AdventureUIModel:setLastAdventureNum( num )
    self.last_adventure_num = num
end

function AdventureUIModel:getLastAdventureNum(  )
    return self.last_adventure_num
end
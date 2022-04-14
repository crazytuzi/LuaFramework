-- 
-- @Author: LaoY
-- @Date:   2018-07-22 17:52:02
-- 
MainModel = MainModel or class("MainModel", BaseModel)

MainModel.SwitchType = {
    City = 1,
    Dungeon = 2,
}
MainModel.OpenFunctionState = {
    Start = 1,
    End = 2,
}

MainModel.MiddleLeftBitState = {
    Dungeon = BitState.State[1],
    Boss = BitState.State[2],
    DungeonBoss = BitState.State[3],
    warrior = BitState.State[4],
}

function MainModel:ctor()
    MainModel.Instance = self
    self:Reset()
end

function MainModel:Reset()
    if not self.middle_left_bit_state then
        self.middle_left_bit_state = BitState()
    else
        self.middle_left_bit_state.value = 0
    end

    --vip经验池
    self.expPool = 0
    self.is_vip_out_date = false
    self.is_init_vfour_mention = false

    -- 右上角
    self.right_top_icon_list = {}
    self.right_red_dot_list = {}

    self.right_top_icon_sub_list = {}

    --左上角
    self.left_top_icon_list = {}

    -- 中间提示图标
    self.mid_tip_list = {}

    self.isShowPredi = false
    self.is_showing_model_predi = false     --是否正在显示模型预告

    --变强
    self.stronger_list = {}             --变强已添加过的模块列表

    self.levelRewards = {} --章节奖励

    self.top_right_global_pos_list = {}

    self.mecha_morph_buff       = false
    self.mecha_morph_even_kill  = 0
end

function MainModel.GetInstance()
    if MainModel.Instance == nil then
        MainModel()
    end
    return MainModel.Instance
end

function MainModel:ChangeMiddleLeftBit(bit, is_add)
    if is_add then
        self.middle_left_bit_state:Add(bit)
    else
        self.middle_left_bit_state:Remove(bit)
    end
    self:Brocast(MainEvent.UpdateMidLeftVisible)
end

function MainModel:GetSwitchType()
    local scene_type = SceneConfigManager:GetInstance():GetSceneType()
    return (scene_type == SceneConstant.SceneType.Feild or scene_type == SceneConstant.SceneType.City) and MainModel.SwitchType.City or MainModel.SwitchType.Dungeon
    -- return (scene_type == SceneConstant.SceneType.City) and MainModel.SwitchType.City or MainModel.SwitchType.Dungeon
end

--[[
    @author LaoY
    @des    更新右上角/右下角 图标红点
    @param1 key_str
    @param2 param     红点数量 数量大于0要显示红点;小于等于0不显示红点
    @param3 sign        标识符 选填。只有当key_str对应的图标支持多个的时候才需要填，多用于运营活动
--]]
function MainModel:UpdateReddot(key_str, param, sign)
    --Yzprint('--LaoY MainModel.lua,line 74--', key_str, param, sign)
    if self:GetRedDotParam(key_str, sign) == param then
        return
    end
    local key = key_str
    if sign and self:TopRightIconIsMul(key_str) then
        key = key_str .. "@" .. sign
    end
    self.right_red_dot_list[key] = param
   -- self:IsSubSys()
    -- self:Brocast(MainEvent.UpdateRightIcon, key_str, "reddot")
    self:Brocast(MainEvent.UpdateRedDot, key_str, param, sign)
end

function MainModel:GetRedDotParam(key_str, sign)
    local key = key_str

    if sign and self:TopRightIconIsMul(key_str) then
        key = key_str .. "@" .. sign
    end
    local param = self.right_red_dot_list[key]
    if param == nil then
        param = false
    end
    return param
end

function MainModel:GetSubRedDotParam(key_str)
    if not table.isempty(self.right_top_icon_sub_list[key_str]) then
        for i, v in pairs(self.right_top_icon_sub_list[key_str]) do
            local childKey = v.key_str
            local childSign = v.sign
            if self:GetRedDotParam(childKey,childSign) then
                return true
            end
        end
    end
    return false
end

function MainModel:TopRightIconIsMul(key_str)
    local config = IconConfig.TopRightConfig[key_str]
    return config and config.is_mul
end


--[[
    @author LaoY
    @des    更新右上角图标资源
    @param1 key_str
    @param2 res         资源 abName:assetName
--]]
function MainModel:SetRightIconRes(key_str, res)
    if self.right_top_icon_list[key_str] then
        self.right_top_icon_list[key_str].res = res
    else
        self.right_top_icon_list[key_str] = { key_str = key_str, res = res }
    end
    self:Brocast(MainEvent.UpdateRightIcon, key_str, "res")
end

--[[
    @author LaoY
    @des    
    @param1 key_str     配置key
    @param2 sign        标识符 选填。只有当key_str对应的图标支持多个的时候才需要填，多用于运营活动
    @param3 time_str    结束时间(结束不删除)|显示文本  number|string 
    @param4 del_time    删除时间                      删除时间；如果有结束时间没有删除时间，默认就是结束就删除
    @param5 is_notice   是否为预告                    默认false
    @param6 is_show_end 是否显示“已结束”字样         主界面图标倒计时处显示红色“已结束”字样
    @param7 is_yy_act   是否为运营活动
    @param8 act_id      运营活动id
--]]
local index = 0
function MainModel:AddRightTopIcon(key_str, sign, time_str, del_time, is_notice, is_show_end, is_yy_act, act_id)
    if LoginModel.IsIOSExamine then
        local tab = {
            ["questionnaire"] = 1,
            ["shop"] = 1,
            ["firstPay"] = 1,
            ["firstPayDime"] = 1,
        }
        if tab[key_str] then
            return
        end
    end
    if time_str and tonumber(time_str) then
        del_time = del_time == nil and time_str or del_time
    elseif del_time and tonumber(del_time) then
        time_str = time_str or del_time
    end
    local config = IconConfig.TopRightConfig[key_str]
    local key = key_str
    if not config then
        return
    end
    if config.is_mul and sign then
        key = key .. sign
    end
    if self.right_top_icon_list[key] then
        --logError("--1--"..key)
        local cf = self.right_top_icon_list[key]
        if cf.time_str == time_str and cf.del_time == del_time and cf.is_notice == is_notice and cf.is_show_end == is_show_end and cf.is_yy_act == is_yy_act then
            return
        end
        self.right_top_icon_list[key_str].time_str = time_str
        self.right_top_icon_list[key_str].del_time = del_time
        self.right_top_icon_list[key_str].is_notice = is_notice
        self.right_top_icon_list[key_str].is_show_end = is_show_end
        self.right_top_icon_list[key_str].is_yy_act = is_yy_act
        self.right_top_icon_list[key_str].cur_act_id = act_id


        self:Brocast(MainEvent.UpdateRightIcon, key, "data")
    else
        if not OpenTipModel.GetInstance():IsOpenSystem(config.id, config.sub_id) then
            return
        end
        if config.group then
            if not self.right_top_icon_sub_list[config.group] then
                self.right_top_icon_sub_list[config.group] ={}

                index = index + 1
                self.right_top_icon_list[config.group] = { key = config.group, key_str = config.group, sign = sign, time_str = time_str, del_time = del_time, is_notice = is_notice, is_show_end = is_show_end, is_yy_act = is_yy_act, create_index = index, cf = IconConfig.TopRightConfig[config.group] }
                self:Brocast(MainEvent.AddRightIcon, config.group)
            end
            if not self:IsContainSys(key) then
                table.insert(self.right_top_icon_sub_list[config.group],{ key = key, key_str = key_str, sign = sign, time_str = time_str, del_time = del_time, is_notice = is_notice, is_show_end = is_show_end, is_yy_act = is_yy_act, create_index = index, cf = config})
            end



        else
            index = index + 1
            self.right_top_icon_list[key] = { key = key, key_str = key_str, sign = sign, time_str = time_str, del_time = del_time, is_notice = is_notice, is_show_end = is_show_end, is_yy_act = is_yy_act, create_index = index, cf = config }
            self:Brocast(MainEvent.AddRightIcon, key)
        end
        --self.right_top_icon_sub_list = {}

       -- index = index + 1
        --self.right_top_icon_list[key] = { key = key, key_str = key_str, sign = sign, time_str = time_str, del_time = del_time, is_notice = is_notice, is_show_end = is_show_end, is_yy_act = is_yy_act, create_index = index, cf = config }
        --self:Brocast(MainEvent.AddRightIcon, key)
    end
end

--右上角图标
function MainModel:RemoveRightTopIcon(key_str, sign)
    local config = IconConfig.TopRightConfig[key_str]
    if config and config.is_mul then
        local del_list = {}
        local key
        if sign then
            key = key_str .. sign
        end


        for k, v in pairs(self.right_top_icon_list) do
            if (key == v.key) or (not key and key_str == v.key_str) then
                del_list[v.key] = true
            end
        end
        for key, v in pairs(del_list) do
            self.right_top_icon_list[key] = nil
            self:Brocast(MainEvent.RemoveRightIcon, key)
        end

    else

        if self.right_top_icon_list[key_str] then
            self.right_top_icon_list[key_str] = nil
            self:Brocast(MainEvent.RemoveRightIcon, key_str)
        else
            for sub_key, tab in pairs(self.right_top_icon_sub_list) do
                for i, v in pairs(tab) do
                    if key_str == v.key_str then
                        self.right_top_icon_sub_list[sub_key][i] = nil
                        self:Brocast(MainEvent.RemoveRightIcon, key_str)
                    end
                end
                if table.isempty(self.right_top_icon_sub_list[sub_key]) or table.nums(self.right_top_icon_sub_list[sub_key])== 0 then
                    self.right_top_icon_list[key_str] = nil
                    self:Brocast(MainEvent.RemoveRightIcon, key_str)
                end
            end
        end
    end
end

function MainModel:AddMidTipIcon(key_str, call_back, num, time, sign)
    local cf = IconConfig.MidTipConfig[key_str]
    local info = self.mid_tip_list[key_str]
    local cur_time = os.time()
    local is_update = true
    if info then
        if cf.is_mul then
            sign = sign or key_str
            if info[sign] then
                is_update = false
            end
            info[sign] = { key_str = key_str, call_back = call_back, num = num, end_time = time and (time + cur_time), sign = sign, add_time = cur_time }
        else
            info.key_str = key_str
            info.call_back = call_back
            info.num = num
            info.end_time = time and (time + cur_time)
            info.sign = sign
            info.add_time = cur_time
            is_update = false
        end
    else
        if cf.is_mul then
            self.mid_tip_list[key_str] = {}
            sign = sign or key_str
            self.mid_tip_list[key_str][sign] = { key_str = key_str, call_back = call_back, num = num, end_time = time and (time + cur_time), sign = sign, add_time = cur_time }
        else
            self.mid_tip_list[key_str] = { key_str = key_str, call_back = call_back, num = num, end_time = time and (time + cur_time), sign = sign }
            self.mid_tip_list[key_str].add_time = cur_time
        end
    end

    self:Brocast(MainEvent.AddMidTipIcon, key_str)
end

function MainModel:RemoveMidTipIcon(key_str, sign)
    local cf = IconConfig.MidTipConfig[key_str]
    local info = self.mid_tip_list[key_str]
    if info then
        if cf.is_mul then
            sign = sign or key_str
            info[sign] = nil
        else
            self.mid_tip_list[key_str] = nil
        end
        self:Brocast(MainEvent.RemoveMidTipIcon, key_str)
    end
end

function MainModel:GetMidIconShowList()
    local t = {}
    for key_str, info in pairs(self.mid_tip_list) do
        local cf = IconConfig.MidTipConfig[key_str]
        if cf.is_mul then
            for k, v in pairs(info) do
                t[#t + 1] = v
            end
        else
            t[#t + 1] = info
        end
    end
    local function call_back(a, b)
        if a.add_time == b.add_time then
            local a_cf = IconConfig.MidTipConfig[a.key_str]
            local b_cf = IconConfig.MidTipConfig[b.key_str]
            return a_cf.id < b_cf.id
        else
            return a.add_time < b.add_time
        end
    end
    table.sort(t, call_back)
    return t
end

function MainModel:SetStrongerSys(cf_id)
    --table.insert(self.stronger_list, 1, cf_id)
    local order = Config.db_stronger[cf_id].order
    self.stronger_list[order] = cf_id
end

function MainModel:DelStrongerSys(cf_id)
    local order = Config.db_stronger[cf_id].order
    self.stronger_list[order] = nil
end

function MainModel:CheckSysExist(cf_id)
    local list = self.stronger_list
    local is_exist = false
    for _, v in pairs(list) do
        if v == cf_id then
            is_exist = true
            break
        end
    end
    return is_exist
end

function MainModel:GetStrongSysNum()
    local num = 0
    for _, _ in pairs(self.stronger_list) do
        num = num + 1
    end
    return num
end

function MainModel:GetStrongList()
    local clone_list = clone(self.stronger_list)
    local interator = table.pairsByKey(clone_list)
    local list = {}
    for _, v in interator do
        list[#list + 1] = v
    end
    return list
end

function MainModel:CheckLevelRewards(level)
    for i = 1, #self.levelRewards do
        -- if level <= self.levelRewards[i].level then
        if self.levelRewards[i].isReceived == false then
            return self:GetTopItemCfg(self.levelRewards[i].level)
        end
        -- break
        --end
    end
    return self:GetTopItemCfg(level)
end

function MainModel:GetTopItemCfg(level)
    local cfg = Config.db_task_jump
    local index = 0
    for i, v in pairs(cfg) do
        local levelTab = String2Table(v.level)
        local minLv = levelTab[1]
        local maxLV = levelTab[2]
        if level > minLv and level <= maxLV then
            if v.next_id == 0 and level == maxLV and self:isRewardLevel(level) == true then
                return nil
            end
            return v
        end

    end
    return nil
end

function MainModel:isRewardLevel(level)
    for i, v in pairs(self.levelRewards) do
        if self.levelRewards[i].level == level then
            return self.levelRewards[i].isReceived
        end
    end
    return nil
end



--------------------左上角
--[[
    @author LaoY
    @des
    @param1 key_str     配置key
    @param2 sign        标识符 选填。只有当key_str对应的图标支持多个的时候才需要填，多用于运营活动
    @param3 time_str    结束时间(结束不删除)|显示文本  number|string
    @param4 del_time    删除时间                      删除时间；如果有结束时间没有删除时间，默认就是结束就删除
    @param5 is_notice   是否为预告                    默认false
    @param6 is_show_end 是否显示“已结束”字样         主界面图标倒计时处显示红色“已结束”字样
    @param7 is_yy_act   是否为运营活动
    @param8 act_id      运营活动id
--]]
local index = 0
function MainModel:AddLeftTopIcon(key_str, sign, time_str, del_time, is_notice, is_show_end, is_yy_act, act_id)
    if time_str and tonumber(time_str) then
        del_time = del_time == nil and time_str or del_time
    elseif del_time and tonumber(del_time) then
        time_str = time_str or del_time
    end
    local config = IconConfig.TopLeftConfig[key_str]
    local key = key_str
    if not config then
        return
    end
    if config.is_mul and sign then
        key = key .. sign
    end
    if self.left_top_icon_list[key] then
        local cf = self.left_top_icon_list[key]
        if cf.time_str == time_str and cf.del_time == del_time and cf.is_notice == is_notice and cf.is_show_end == is_show_end and cf.is_yy_act == is_yy_act then
            return
        end
        self.left_top_icon_list[key_str].time_str = time_str
        self.left_top_icon_list[key_str].del_time = del_time
        self.left_top_icon_list[key_str].is_notice = is_notice
        self.left_top_icon_list[key_str].is_show_end = is_show_end
        self.left_top_icon_list[key_str].is_yy_act = is_yy_act
        self.left_top_icon_list[key_str].cur_act_id = act_id
        self:Brocast(MainEvent.UpdateLeftIcon, key, "data")
    else
        if not OpenTipModel.GetInstance():IsOpenSystem(config.id, config.sub_id) then
            return
        end
        index = index + 1
        self.left_top_icon_list[key] = { key = key, key_str = key_str, sign = sign, time_str = time_str, del_time = del_time, is_notice = is_notice, is_show_end = is_show_end, is_yy_act = is_yy_act, create_index = index, cf = config }
        self:Brocast(MainEvent.AddLeftIcon, key)
    end
end

function MainModel:RemoveLeftTopIcon(key_str, sign)
    local config = IconConfig.TopLeftConfig[key_str]
    if config and config.is_mul then
        local del_list = {}
        local key
        if sign then
            key = key_str .. sign
        end
        for k, v in pairs(self.left_top_icon_list) do
            if (key == v.key) or (not key and key_str == v.key_str) then
                del_list[v.key] = true
            end
        end
        for key, v in pairs(del_list) do
            self.left_top_icon_list[key] = nil
            self:Brocast(MainEvent.RemoveLeftIcon, key)
        end
    else
        if self.left_top_icon_list[key_str] then
            self.left_top_icon_list[key_str] = nil
            self:Brocast(MainEvent.RemoveLeftIcon, key_str)
        end
    end
end

function MainModel:UpdateKillBuff()
    local buff_id = RoleInfoModel:GetInstance():GetMainRoleData():IsHaveBuffEffectType(enum.BUFF_EFFECT.BUFF_EFFECT_MECHA_MORPH)
    local bo = toBool(buff_id)
    if self.mecha_morph_buff == bo then
        return
    end
    self.mecha_morph_buff = bo
    if not self.mecha_morph_buff then
        self.mecha_morph_even_kill = 0
        local panel = lua_panelMgr:GetPanel(EvenKill)
        if panel then
            panel:ClosePanel()
        end
    else
        local panel = lua_panelMgr:GetPanelOrCreate(MachineArmorUltSkillShow)
		panel:Open()
    end
end

function MainModel:RetainEvenKillNum()
    if not self.mecha_morph_buff then
        return
    end
    self.mecha_morph_even_kill = self.mecha_morph_even_kill + 1

    local panel = lua_panelMgr:GetPanel(EvenKill)
    if not panel then
        panel = EvenKill()
        panel:Open()
    else
        panel:UpdateView()
    end
end

function MainModel:IsContainSys(key)
    for pKey, tab in pairs(self.right_top_icon_sub_list) do
        for i, v in pairs(tab) do
            if key == v.key_str then
                 return true
            end
        end
    end
    return false
end
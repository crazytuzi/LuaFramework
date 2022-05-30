-- --------------------------------------------------------------------
-- 宝可梦(伙伴)的对象数据
-- 
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      宝可梦(伙伴)的对象数据     
-- <br/>Create: 2018年11月14日
-- --------------------------------------------------------------------
HeroVo = HeroVo or BaseClass(EventDispatcher)

HeroVo.UPDATE_Partner_ATTR = "heroVo_update_attr11"

local table_insert = table.insert

function HeroVo:__init()
    self.partner_id     = 0  --此宝可梦的唯一标识id
    self.id             = 0  -- 已废弃用上面的, 如果有 那么一定是和 partner_id相等.
    self.bid            = 0  -- 此配置表对应宝可梦id
    
    self.camp_type      = 0  --阵营 配置表有 默认1

    self.rare_type      = 0                     --伙伴类型 1：N 2：R 3：SR 4：SSR
    self.name           = ""
    self.type           = 0                     -- 职业； [3]=TI18N("法攻"),[4]=TI18N("物攻"),[5]=TI18N("肉盾"),[6]=TI18N("辅助")
    self.face_id        = 0                     -- 头像id;
    self.lev            = 0
    self.exp            = 0                     -- 经验;
    self.break_lev      = 0    --突破等级
    self.max_exp        = 0    --经验上限
    self.star_step      = 0    --星星阶段
    self.star           = 0    --星数
    self.quality        = 0    --品质
    self.looks          = {}
    self.body_res       = ""
    self.res_id         = ""
    self.power          = 0  --战力
    self.rid            = 0
    self.srv_id         = ""
    self.recruit_type   = 1     -- 卡库 
    self.chips_id       = 0     -- 碎片id
    self.chips_num      = 0     -- 初始碎片数

    self.clothes_id     = 0    --时装id

    self.other_form     = 0

    self.fetter         = {}  -- 绑定的星命,多个      

    self.fetter_power   = 0   --星命加成战力 

    self.fetter_atk    = 0    --星命攻击加成
    self.fetter_hp      = 0   --星命生命加成
    self.fetter_speed   = 0   --星命速度加成
    self.fetter_def     = 0   --星命防御加成

     --属性部分
    self.atk            = 0    -- 攻击;
    self.def_p          = 0    -- 物防;
    self.def_s          = 0    -- 法防;
    self.hp             = 0    -- 气血;
    self.speed          = 0    -- 速度;
    self.def            = 0    -- 防御

    self.hit_rate       = 0    -- 命中
    self.dodge_rate     = 0    -- 闪避
    self.crit_rate      = 0    -- 暴击率;
    self.crit_ratio     = 0    -- 暴击伤害;
    self.hit_magic      = 0    -- 效果命中;
    self.dodge_magic    = 0    -- 效果抵抗;


    self.resonate_lev    = 0    -- 共鸣水晶等级(当值不为0 时 表示 该宝可梦共鸣中 并且该值记录是共鸣前的等级)

    --对应的属性列表
    self.group_attr     = {}   --成长值

    self.skills         = {}    --"技能列表{[1] = {skill_bid = xx}}
    self.break_skills   = {}   --突破技能列表
    self.eqm_list       = {}   --伙伴装备列表
    self.holy_eqm_list  = nil   --伙伴神装列表 ==nil 用于判断是否初始化
    self.artifact_list  = {}   --神器列表

    self.awaken_count   = 0   -- 觉醒次数,如果是0 就是没有觉醒
    self.awaken_skills  = {}

    self.form_param     = 100  --布阵的参数
    self.is_in_form     = 0   --是否在阵上，是的话为阵上位置 其值的 :逻辑是 PartnerConst.Fun_Form.xxx * self.form_param + pos
    self.dic_in_form    = {}  --在那个布阵信息 如: self.dic_in_form[PartnerConst.Fun_Form.Drama] = pos

    self.sort_order     = 0  --排序用
    self.show_order     = 0
    self.order          = 0
    -- self.dispather_order = 0

    self.is_lock = 0  --是否锁定..只要 self.dic_locks 列表中有一个被锁定.此值都是锁定的
    --判定是否锁定..尽量用 HeroVo:isLock()方法
    self.dic_locks = {}   --锁定信息 self.dic_locks[锁定类型] = 0 
    self.red_point =  {}   --红点列表 HeroConst.Red_Point_Type

    --天赋技能列表  self.talent_skill_list[位置] = skill_id
    self.talent_skill_list = nil

    self.reset_time = nil --重生时间(针对 100级以下的) nil 表示未初始化

    self.is_init_attr = false --是否初始化属性, 装备信息等内容 11026协议获取内容
    self.is_had_detailed = nil --是否有详细信息了(注意: 特指获取属性那块  而11026协议.是把11000分成两部分的第二部分的详细信息)
end

function HeroVo:getKey()
    return getNorKey(self.battle_id, self.id)
end

--==============================--
--desc:获取伙伴的唯一id
--time:2017-12-08 12:06:31
--@return 
--==============================--
function HeroVo:getId()
    if self.partner_id ~= 0 then
        return self.partner_id 
    else
        return self.id
    end
end

function HeroVo:initAttributeData(data)
    data = data or {}
    for k, v in pairs(data) do
        if k == "looks" then
            self:setLooks(v)
        elseif type(v) ~= "table" then
            self:setRoleAttribute(k, v)
        end
        if k == "show_order" then 
            self.sort_order = v
        end
    end    
end
--组合成基础属性
function HeroVo:getBaseAttr()
    local list = {}
    list[1] = {name ="hp",value = self.hp}
    list[2] = {name ="atk",value = self.atk}
    list[3] = {name ="def_p",value = self.def_p}
    list[4] = {name ="def_s",value = self.def_s}
    list[5] = {name = "speed",value = self.speed}
    return list
end
--组合成其他属性
function HeroVo:getOtherAttr()
    local list = {}
    list[1] = {name = "crit_rate",value = self.crit_rate+self.crit_rate2}
    list[2] = {name = "crit_ratio",value = self.crit_ratio+self.crit_ratio2}
    list[3] = {name = "hit_magic",value = self.hit_magic+self.hit_magic2}
    list[4] = {name = "dodge_magic",value = self.dodge_magic+self.dodge_magic2}
    return list
end
--装备属性
function HeroVo:getBaseEquipAttr()
    local list = {}
    list[1] = {name ="hp2",value = self.hp2}
    list[2] = {name ="atk2",value = self.atk2}
    list[3] = {name ="def_p2",value = self.def_p2}
    list[4] = {name ="def_s2",value = self.def_s2}
    list[5] = {name ="speed2",value = self.speed2}
    return list
end
--组合成其他装备属性
function HeroVo:getOtherEquipAttr()
    local list = {}
    list[1] = {name = "crit_rate2",value = self.crit_rate2}
    list[2] = {name = "crit_ratio2",value = self.crit_ratio2}
    list[3] = {name = "hit_magic2",value = self.hit_magic2}
    list[4] = {name = "dodge_magic2",value = self.dodge_magic2}
    return list
end
--其他装备属性更新
function HeroVo:updateEqipAttr(attr_list)
    attr_list = attr_list or {}
    for key,value in pairs(attr_list) do 
        if PartnerCalculate.isEquipAttr(key) == true then
            self:setRoleAttribute(key,value)
        end
    end
    if attr_list.power then 
        self:setRoleAttribute("power", attr_list.power)
    end
end
function HeroVo:setLooks(data_list)
    local is_change = (data_list and next(data_list) ~= nil)
    data_list = data_list or {}
    local looksVo
    for k1, v1 in pairs(data_list) do
        looksVo = self.loos[v1.looks_type]
        if looksVo then
            looksVo:setAntVo(V1)
        else
            looksVo = LooksVo.New()
            looksVo:setAntVo(V1)
            self.looks[v1.looks_type] = looksVo
        end
    end
    if is_change == true then
        self:dispatchUpdateAttrByKey("looks", self.looks)
    end
end

function HeroVo:updateHeroVo(vo)
    if vo then
        for k, v in pairs(vo) do
            self:setAttr(k, v)
            

            if k == "show_order" then 
                self.sort_order = v
            end
            -- 伙伴id
            -- if k == "id" and v ~= 0 then
            --     self.partner_id = v
            -- end
            if k == "eqms" then  -- 装备信息
                self:updateEqmList(v)
            end
            if k == "holy_eqm" then  -- 神装信息
                self:updateHolyEqmList(v)
            end
            if k == "artifacts" then --神器信息
                self:updateArtifactList(v)
            end
            if k == "is_lock" then --锁定逻辑
                self:updateLock(v) 
            end

            if k == "dower_skill" then
                self:updateSkill(v)
            end
            -- if k == "fetter" then
            --     self:updateFetter(v)
            -- end
        end
        self:Fire(HeroVo.UPDATE_Partner_ATTR,self)
    end
end

function HeroVo:setInitAttr()
    self.is_init_attr = true
end

--是否初始化属性
function HeroVo:isInitAttr()
    return self.is_init_attr
end

function HeroVo:setIsHadDetail(is_had)
    self.is_had_detailed = is_had
end

function HeroVo:updateSkill(list)
    self.talent_skill_list = {}
    for k,v in pairs(list) do
        self.talent_skill_list[v.pos] = v.skill_id
    end
end
--是否已有天赋数据
function HeroVo:ishaveTalentData()
    if self.talent_skill_list == nil then
        return false
    end
    return true
end
--根据符石的bid判断是否已领取该符石对应的天赋技能
function HeroVo:checkIsHaveTalentByBid( bid )
    local is_have = false
    for k,skill_id in pairs(self.talent_skill_list or {}) do
        local skill_cfg = Config.PartnerSkillData.data_partner_skill_item[skill_id]
        if skill_cfg then
            for _,v in pairs(skill_cfg.expend or {}) do
                if v == bid then
                   is_have = true
                   break 
                end
            end
        end
        if is_have then
            break
        end
    end
    return is_have
end

function HeroVo:updateLock(data)
    for i,v in ipairs(data) do
        self.dic_locks[v.lock_type] = v.is_lock 
    end
    self.is_lock = 0
    for i,is_lock in pairs(self.dic_locks) do
        if self.is_lock == 0 then
            self.is_lock = is_lock
        end
    end
end

--是否在锁定中..包括 1:宝可梦锁定 2 宝可梦置换锁定 98 共鸣锁定
--return 是否锁定  如果返回true ,还会返回 锁定类型 参考 HeroConst.LockType
function HeroVo:isLock()
    for k,v in pairs(self.dic_locks) do
        if v > 0 then
            return true , k
        end
    end
    return false    
end

--检查宝可梦锁定tips
--@ is_all 是否全部判定
--@ lock_type_list 需要检查的锁定类型 参考HeroConst.LockType
function HeroVo:checkHeroLockTips(is_all, lock_type_list, not_message)
    local lock_type_list = lock_type_list or {}
    if is_all then
        lock_type_list = {
            [1] = HeroConst.LockType.eFormLock, --优先判定已上阵
            [2] = HeroConst.LockType.eHeroLock, 
            [3] = HeroConst.LockType.eHeroChangeLock, 
            [4] = HeroConst.LockType.eHeroResonateLock, 
        }
    end

    for i,lock_type in ipairs(lock_type_list) do
        if lock_type == HeroConst.LockType.eFormLock then
            -- if self.is_in_form > 0 then
            if self:isInForm() then
                local fun_form_type =  math.floor(self.is_in_form/self.form_param)
                if not not_message then
                    if fun_form_type == PartnerConst.Fun_Form.Drama then
                        message(TI18N("该宝可梦在剧情阵容中已上阵"))
                    elseif fun_form_type == PartnerConst.Fun_Form.Arena then
                        message(TI18N("该宝可梦在竞技场防守阵容中已上阵"))
                    elseif fun_form_type == PartnerConst.Fun_Form.EliteMatch or 
                            fun_form_type == PartnerConst.Fun_Form.EliteKingMatch then
                        message(TI18N("该宝可梦已在超凡段位赛中上阵"))
                    elseif fun_form_type == PartnerConst.Fun_Form.CrossArenaDef then
                        message(TI18N("该宝可梦在跨服竞技场防守阵容中已上阵"))
                    elseif fun_form_type == PartnerConst.Fun_Form.Adventure_Mine_Def then
                        message(TI18N("该宝可梦秘矿冒险防守阵容中已上阵"))
                    elseif fun_form_type == PartnerConst.Fun_Form.ArenaTeam then
                        message(TI18N("该宝可梦组队竞技场阵容中已上阵"))
                    elseif fun_form_type == PartnerConst.Fun_Form.ArenapeakchampionDef then
                        message(TI18N("该宝可梦巅峰冠军赛阵容中已上阵"))
                    end
                end
                return true
            end
        else
            if self.dic_locks[lock_type] and self.dic_locks[lock_type] > 0 then
                if not not_message then
                    if lock_type == HeroConst.LockType.eHeroLock then
                        message(TI18N("该宝可梦已锁定，请前往宝可梦界面解锁"))
                    elseif lock_type == HeroConst.LockType.eHeroChangeLock then
                        message(TI18N("该宝可梦转换中，请前往先知圣殿解除"))
                    elseif lock_type == HeroConst.LockType.eHeroResonateLock then
                        message(TI18N("该宝可梦在原力水晶槽位中已上阵"))
                    end
                end
                return true
            end
        end
    end
    return false
end

--是否在阵法上
function HeroVo:isInForm()
    if self.is_in_form > 0 then
        local fun_form_type =  math.floor(self.is_in_form/self.form_param)
        --注意顺序..类型大的在后面小的在前面判断
        if fun_form_type == PartnerConst.Fun_Form.ArenaTeam then --组队竞技场
            local model = ArenateamController:getInstance():getModel()
            local my_team_info = model:getMyTeamInfo()
            if my_team_info and (my_team_info.state == 1 or my_team_info.state == 2) then
                return true
            else
                local count = 0
                for i,v in ipairs(self.dic_in_form) do
                    count = count + 1
                end
                if count >= 2 then
                    --后面有类似判断的这里也要写一份
                    --func()
                    return true
                end
            end
        -- elseif xxxxx的
        -- func()
        else 
            return true
        end
    end
    return false
end

--是否在剧情阵容中
function HeroVo:isFormDrama()
    if self.is_in_form > 0 then
        if self.dic_in_form and self.dic_in_form[PartnerConst.Fun_Form.Drama] ~= nil then
            return true 
        end
        return false
        -- local fun_form_type =  math.floor(self.is_in_form/self.form_param)
        -- if fun_form_type == PartnerConst.Fun_Form.Drama then
        --     return true
        -- end
    end
    return false
end

--==============================--
--desc:更新星命
--time:2018-09-18 09:40:46
--@v:
--@return 
--==============================--
function HeroVo:updateFetter(data)
    self.fetter = {}
    if data == nil or next(data) == nil then return end
    for i,v in ipairs(data) do
        table_insert(self.fetter, v.fetter)
    end
end

--==============================--
--desc:判断是否激活了一个星命
--time:2018-09-18 09:50:15
--@fetter_id:
--@return 
--==============================--
function HeroVo:checkFetter(fetter_id)
    for i,v in ipairs(self.fetter) do
        if v == fetter_id then
            return true
        end
    end
    return false
end

--==============================--
--desc:监测是否可以激活星命
--time:2018-09-18 09:50:41
--@return 
--==============================--
function HeroVo:checkEquipFetter()
    local config = Config.PartnerData.data_partner_const.fetter_open
    local limite_lev = 60
    if config then
        limite_lev = config.val
    end
    if #self.fetter >= 2 then
        return false
    end
    return true
end

function HeroVo:setAttr(key, val)
    if  self[key] ~= val then
        self[key] = val
    end
end
function HeroVo:getAttrByKey(key)
    return self[key]
end

--更新装备列表
function HeroVo:updateEqmList(vo)
    local list = vo or {}
    for i,v in pairs(list) do 
        local eqm_vo = self.eqm_list[v.type]
        if not eqm_vo then 
            eqm_vo = GoodsVo.New(v.base_id)
            self.eqm_list[v.type] = eqm_vo
        end

        if eqm_vo["initAttrData"] then
            eqm_vo:initAttrData(v)
        end
        eqm_vo:setEnchantScore(0)
    end 
    
    -- 这个时候有删除状态的处理,现在拥有的比更新回来的要大
    if tableLen(self.eqm_list) > tableLen(list) then
        for k,vo in pairs(self.eqm_list) do
            local is_dele = true
            for i,v in ipairs(list) do
                if k == v.type then
                    is_dele = false
                    break
                end
            end
            if is_dele == true then
                self.eqm_list[k] = nil
            end
        end
    end
end


--是否已有神装数据
function HeroVo:ishaveHolyEquipmentData()
    if self.holy_eqm_list == nil then
        return false
    end
    return true
end
--更新神装列表
function HeroVo:updateHolyEqmList(list)
    local list = list or {}
    if self.holy_eqm_list == nil then
        self.holy_eqm_list = {}
    end
    for i,v in ipairs(list) do 
        --继续类型
        local item_config = Config.ItemData.data_get_data(v.base_id)
        if item_config then
            v.type = item_config.type
            local eqm_vo = self.holy_eqm_list[v.type]
            if not eqm_vo then 
                eqm_vo = GoodsVo.New(v.base_id)
                self.holy_eqm_list[v.type] = eqm_vo
            end

            if eqm_vo["initAttrData"] then
                eqm_vo:initAttrData(v)
            end
            eqm_vo:setEnchantScore(0)
        end
    end 
    
    -- 这个时候有删除状态的处理,现在拥有的比更新回来的要大
    if tableLen(self.holy_eqm_list) > tableLen(list) then
        for k,vo in pairs(self.holy_eqm_list) do
            local is_dele = true
            for i,v in ipairs(list) do
                if k == v.type then
                    is_dele = false
                    break
                end
            end
            if is_dele == true then
                self.holy_eqm_list[k] = nil
            end
        end
    end
end

function HeroVo:updateRedPoint(index,bool)
    if bool ~= nil then 
        if self.red_point[index] ~= bool then 
            self.red_point[index] = bool
            self:Fire(HeroVo.UPDATE_Partner_ATTR,self)
        end
    end
end

function HeroVo:isRedStatus()
    for k,v in pairs(self.red_point) do
        if v == true then
            return true
        end
    end
    return false
end

--更新神器列表
function HeroVo:updateArtifactList(list)
    local list = list or {}
    local dic_pos = {}
    for i,v in ipairs(list) do
        dic_pos[v.artifact_pos] = v
    end
    --写死只有两个神器 (神器位置类型: 1, 2 )
    for i=1,2 do
        local artifact_data = dic_pos[i]
        local goods_vo = self.artifact_list[i]
        if artifact_data and goods_vo then --两个都有值 ..更新
            if goods_vo["initAttrData"] then
                goods_vo:initAttrData(artifact_data)
            end
        elseif artifact_data and goods_vo == nil then --数据有  goods没有 .新增
            goods_vo = GoodsVo.New(artifact_data.base_id)
            if goods_vo["initAttrData"] then
                goods_vo:initAttrData(artifact_data)
            end
            self.artifact_list[i] = goods_vo
        elseif artifact_data == nil and goods_vo then --数据没有  goods有 .删除
            self.artifact_list[i] = nil
            goods_vo:DeleteMe()
        end
    end
end

--- 获取主副圣器技能 type == 1 副神器, type == 2 主神器 , item_data.bid == 10420 主神器  10421 副神器
function HeroVo:getArtifactSkill(type)
    if self.artifact_list == nil or next(self.artifact_list) == nil then return end
    local skill_list = {}
    for k,v in pairs(self.artifact_list) do
        if v.extra then
            if type == 2 and self:checkArtifactType(v) then
                return v.extra
            elseif type == 1 and not self.checkArtifactType(v) then
                return v.extra
            end
        end
    end
end

--- 判断是不是主神器
function HeroVo:checkArtifactType(item)
    if item == nil then return false end
    if item.extra == nil or next(item.extra) == nil then return false end
    local is_main = false
    for i,v in ipairs(item.extra) do
        if v.extra_k == 2 then
            is_main = true
            break
        end
    end
    return is_main
end

--@fun_form_type --阵法类型
function HeroVo:updateFormPos(pos, fun_form_type)
    fun_form_type = fun_form_type or PartnerConst.Fun_Form.Drama
    pos = pos or 0
    self.is_in_form = 0

    if pos == 0 then
        self.dic_in_form[fun_form_type] = nil    
    else
        self.dic_in_form[fun_form_type] = pos
    end

    for _type, _pos in pairs(self.dic_in_form) do
        local cur_pos = _type * self.form_param + _pos
        if self.is_in_form == 0 then
            self.is_in_form = cur_pos
        else
            if self.is_in_form > cur_pos then
                self.is_in_form = cur_pos
            end
        end
    end
    self:updateHeroVo({["is_in_form"] = self.is_in_form})
end

function HeroVo:setRoleAttribute(key, value)
    if self[key] ~= value then
        self[key] = value
    end
end

--是否是共鸣水晶宝可梦
function HeroVo:isResonateCrystalHero()
    if self.resonate_lev and self.resonate_lev > 0 then
        -- if is_show_tips then
        --     message(TI18N("该宝可梦在原力水晶槽位中已上阵"))
        -- end
        return true
    end
    return false
end

--是否共鸣赋能的宝可梦
function HeroVo:isResonateHero()
    if self.end_time and self.end_time > 0 then
        return true
    end
    return false
end

function HeroVo:checkResonateHero()
    if self:isResonateHero() then
        message(TI18N("赋能宝可梦不可参与此玩法或选择"))
        return true
    end
    return false
end

--检查共鸣宝可梦根据阵法操作
function HeroVo:checkResonateHeroByFormType(form_type, not_tips)
    if not form_type then return false end
    if self:isResonateHero() then
        if form_type == PartnerConst.Fun_Form.Drama or     --剧情
            form_type == PartnerConst.Fun_Form.Startower or   --试练塔
            form_type == PartnerConst.Fun_Form.ElementWater or--元素神殿（水系）
            form_type == PartnerConst.Fun_Form.ElementFire or --元素神殿（火系）
            form_type == PartnerConst.Fun_Form.ElementWind or --元素神殿（风系）
            form_type == PartnerConst.Fun_Form.ElementLight or--元素神殿（光系）
            form_type == PartnerConst.Fun_Form.ElementDark or --元素神殿（暗系）
            form_type == PartnerConst.Fun_Form.GuildDun_AD then --公会boss
            return false
        end
        if not not_tips then
            message(TI18N("赋能宝可梦不可参与此玩法或选择"))
        end
        return true
    end
end

function HeroVo:initResetTime(reset_time)
    self.reset_time = reset_time
    -- self:Fire(HeroVo.UPDATE_Partner_ATTR,self) --暂时不需要
end
-- 是否有重生信息了
function HeroVo:isResetTimeInfo()
    return self.reset_time ~= nil
end

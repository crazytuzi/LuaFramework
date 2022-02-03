-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      石碑赋能
-- <br/> 2019年8月1日
-- --------------------------------------------------------------------
HeroResonateTabEmpowermentPanel = class("HeroResonateTabEmpowermentPanel", function()
    return ccui.Widget:create()
end)

local controller = HeroController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert
local role_vo = RoleController:getInstance():getRoleVo()

function HeroResonateTabEmpowermentPanel:ctor(parent)  
    self:config()
    self:layoutUI()
    self:registerEvents()
end

function HeroResonateTabEmpowermentPanel:config()
    -- self.size = cc.size(680,372.97)
    -- self:setContentSize(self.size)

    --天赋技能信息
    self.talent_skill_list = {}

    local config = Config.ResonateData.data_const.empowerment_span
    if config then
        self.empowerment_span = config.val
    else
        self.empowerment_span = 24
    end
    
end

function HeroResonateTabEmpowermentPanel:layoutUI()
    local csbPath = PathTool.getTargetCSB("hero/hero_resonate_tab_empowerment_panel")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    --读取文件的大小
    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.look_btn = self.main_container:getChildByName("look_btn")
    self.look_btn:setVisible(false)
    self.hero_node_1 = self.main_container:getChildByName("hero_node_1")
    self.hero_node_2 = self.main_container:getChildByName("hero_node_2")
    self.hero_item_1 = HeroExhibitionItem.new(0.7, false) 
    self.hero_node_1:addChild(self.hero_item_1)

    self.hero_item_2 = HeroExhibitionItem.new(0.8, true, nil, true)
    self.hero_item_2:addCallBack(function() self:onClickSelectHeroBtn() end)
    self.hero_node_2:addChild(self.hero_item_2)


    self.hero_item_tips = createRichLabel(20, cc.c4b(0xff,0xea,0xc6,0xff), cc.p(0,1),cc.p(-60, -60),nil,nil,1900)
    self.hero_node_2:addChild(self.hero_item_tips)

    self.item_node = self.main_container:getChildByName("item_node")

    self.cost_item = BackPackItem.new(false, true, false, 0.8, false, true, false)
    self.cost_item:setDefaultTip(true, nil, nil, 1)
    
    self.item_node:addChild(self.cost_item)

    -- BackpackController:getInstance():openTipsSource(true, item_config)
    -- local skill_panel1 = self.main_container:getChildByName("skill_panel1")
    -- local skill_panel2 = self.main_container:getChildByName("skill_panel2")

    local dic_config = Config.PartnerSkillData.data_partner_skill_pos or {}
    local config_list = {}
    
    for k,v in pairs(dic_config) do
        table_insert(config_list, v)
    end
    table.sort( config_list, function(a, b) return a.pos < b.pos end)
    self.config_list = config_list
    self.skill_item_list = {}
    for i=1,3 do
        local v = config_list[i]
        local skill_panel = self.main_container:getChildByName("skill_panel"..i)
        skill_panel:setScale(0.8)
        local item = {}
        item.icon = skill_panel:getChildByName("icon")
        item.lock_icon = skill_panel:getChildByName("lock_icon")
        item.skill_name_bg = skill_panel:getChildByName("skill_name_bg")
        item.skill_level_bg = skill_panel:getChildByName("skill_level_bg")
        item.redPoint = skill_panel:getChildByName("redPoint")
        item.redPoint:setVisible(false)
        item.skill_name = skill_panel:getChildByName("skill_name")
        item.skill_level = skill_panel:getChildByName("skill_level")
        registerButtonEventListener(skill_panel, function() self:onSkillClickByIndex(i, v) end ,false, 1)
        self.skill_item_list[i] = item
    end

    self.limit_time = self.main_container:getChildByName("limit_time")
    local tips = self.limit_time:getChildByName("tips")
    local str = TimeTool.getDayOrHour(self.empowerment_span * 60)
    tips:setString(string_format(TI18N("限时%s"),str))

    self.power_click = self.main_container:getChildByName("power_click")
    self.power = self.power_click:getChildByName("power")
    self:setPowerValue(0)

    self.limit_time:setVisible(false)
    self.power_click:setVisible(false)

    self.bottom_panel = self.main_container:getChildByName("bottom_panel")
    self.hero_star_tips = createRichLabel(20, cc.c4b(0xff,0xea,0xc6,0xff), cc.p(0.5,0.5),cc.p(360, 331),nil,nil,1900)
    self.bottom_panel:addChild(self.hero_star_tips)


    self.change_count_label = createRichLabel(22, cc.c4b(0xff,0xff,0xf,0xff), cc.p(1,0.5),cc.p(706, 143),nil,nil,1900)
    self.bottom_panel:addChild(self.change_count_label)

    self.resonate_btn = self.bottom_panel:getChildByName("resonate_btn")
    self.resonate_btn_label = self.resonate_btn:getChildByName("label")
    self.resonate_btn_label:setString(TI18N("赋能创造"))

    --消耗
    local cost_icon_1 = self.bottom_panel:getChildByName("cost_icon_1")
    cost_icon_1:setScale(0.8)
    local cost_txt_1 = self.bottom_panel:getChildByName("cost_txt_1")
    cost_txt_1:setString("")
    self.cost_icon = {cost_icon_1}
    self.cost_txt = {cost_txt_1}

end

--事件
function HeroResonateTabEmpowermentPanel:registerEvents()
    registerButtonEventListener(self.resonate_btn, function() self:onClickResonateBtn()  end ,true, 2)
    --详情
    registerButtonEventListener(self.look_btn, function(param,sender, event_type) 
        if self.parent and self.parent.is_move_effect then return end
        local config = Config.ResonateData.data_const.empowerment_rule_tips
        if config then
            TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
        end
    end ,true, 2)
     --共鸣赋能返回
    if self.hero_resonate_empowerment_event == nil then
        self.hero_resonate_empowerment_event = GlobalEvent:getInstance():Bind(HeroEvent.Hero_Resonate_Empowerment_Event, function(data)
            if not data then return end
            self:setScdata(data)
        end)
    end
    --共鸣赋能成功返回
    if self.hero_resonate_empowerment_success_event == nil then
        self.hero_resonate_empowerment_success_event = GlobalEvent:getInstance():Bind(HeroEvent.Hero_Resonate_Empowerment_Success_Event, function(data)
            self.select_hero_vo = nil
            self.talent_skill_list = {}
            self:initSelectHeroInfo()
            self:initSkillItemList()
            self:setBtnstatus()
            self:showEffect(PlayerAction.action_1, true)
        end)
    end

    --共鸣赋能成功返回
    if self.hero_resonate_skill_list_event == nil then
        self.hero_resonate_skill_list_event = GlobalEvent:getInstance():Bind(HeroEvent.Hero_Resonate_Skill_List_Event, function(data)
            if not data then return end
            self.dic_had_skill = {}
            for i,v in ipairs(data.skills) do
                self.dic_had_skill[v.skill_id] = 1
            end
        end)
    end

     --添加英雄选择返回事件
    if self.select_hero_event == nil then
        self.select_hero_event = GlobalEvent:getInstance():Bind(HeroEvent.Select_Hero_Event, function(dic_cur_select_list, form_type)
            if form_type  and form_type == HeroConst.SelectHeroType.eResonateEmpowerment then
                if dic_cur_select_list == nil or next(dic_cur_select_list) == nil then
                    self.select_hero_vo = nil
                    self.talent_skill_list = {}
                    self:initSelectHeroInfo()
                    self:initSkillItemList()
                    self:setBtnstatus()
                else
                    for id,v in pairs(dic_cur_select_list) do
                        if self.select_hero_vo and self.select_hero_vo.id ==  v.id then
                            self.select_hero_vo = nil
                        else
                            self.select_hero_vo = v
                            controller:sender26423(v.id, {}) 
                        end
                        self:initSelectHeroInfo()
                        self:initSkillItemList()
                        self:setBtnstatus()
                        break
                    end
                end
            end
        end)
    end
     --添加技能返回
    if self.select_skill_event == nil then
        self.select_skill_event = GlobalEvent:getInstance():Bind(HeroEvent.Hero_Resonate_Select_Skill_Event, function(pos, skill_id)
            if pos then
                self.talent_skill_list[pos] = skill_id
                self:initSkillItemList()
                if self.select_hero_vo then
                    local skills = {}
                    if self.talent_skill_list then
                        for pos,skill_id in ipairs(self.talent_skill_list) do
                            table_insert(skills, {pos = pos, skill_id = skill_id})
                        end
                    end
                    controller:sender26423(self.select_hero_vo.id, skills) 
                end
            end
        end)
    end
     --战力显示
    if self.hero_power_event == nil then
        self.hero_power_event = GlobalEvent:getInstance():Bind(HeroEvent.Hero_Resonate_Hero_Power_Event, function(data)
            if not data then return end
            if self.select_hero_vo and self.select_hero_vo.id == data.partner_id then
                self:setPowerValue(data.power)
            end
        end)
    end


    --物品道具增加 判断红点
    if not self.add_goods_event then
        self.add_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS, function(bag_code,temp_add)
            if bag_code ~= BackPackConst.Bag_Code.EQUIPS then 
                self:updateCostInfo()
            end
        end)
    end
    --物品道具删除 判断红点
    if not self.del_goods_event then
        self.del_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS, function(bag_code,temp_del)
            if bag_code ~= BackPackConst.Bag_Code.EQUIPS then 
                self:updateCostInfo()
            end
        end)
    end

    --物品道具改变 判断红点
    if not self.modify_goods_event then
        self.modify_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code,temp_list)
            if bag_code ~= BackPackConst.Bag_Code.EQUIPS then 
               self:updateCostInfo()
            end
        end)
    end

    if role_vo ~= nil then
        if self.role_lev_event == nil then
            self.role_lev_event =  role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, lev) 
                if key == "coin" then
                    self:updateCostInfo()
                -- elseif key == "hero_exp" then
                --     self:updateCostInfo(self.hero_vo)
                end
            end)
        end
    end
end

--点击换英雄
function HeroResonateTabEmpowermentPanel:onClickSelectHeroBtn()
    if not self.scdata then return end
    if self.scdata.star <= 5 then 
        return 
    end
    local setting = {}
    setting.select_condition = {}
    setting.select_condition.star_start = 4
    setting.select_condition.star_end = self.scdata.star
    setting.select_condition.camp_type = 0
    setting.select_condition.bid = 0
    setting.select_count = 1
    setting.dic_selected = {}
    if self.select_hero_vo then
        setting.dic_selected[self.select_hero_vo.id] = self.select_hero_vo
    end
    setting.form_type = HeroConst.SelectHeroType.eResonateEmpowerment
    local star1 = setting.select_condition.star_start
    local star2 = setting.select_condition.star_end
    setting.tips = string_format(TI18N("请选择下列<div fontcolor=#249003>%s星</div>至<div fontcolor=#249003>%s星</div>的英雄作为赋能创造的取样"), star1, star2)

    controller:openHeroSelectHeroPanel(true, setting)
end

--点击技能
--@ config Config.PartnerSkillData.data_partner_skill_pos
function HeroResonateTabEmpowermentPanel:onSkillClickByIndex(index, config)
    if not self.select_hero_vo then 
        message(TI18N("请先选择英雄"))
        return 
    end
    if not self.new_hero_vo then return end
    local is_open, lock_str = model:checkOpenTanlentByconfig(config, self.new_hero_vo)
    if not is_open then
        message(lock_str)
        return
    end
    local setting = {}
    setting.pos = index
    setting.dic_had_skill = self.dic_had_skill --or {[700033] = true, [700043] = true}
    setting.dic_other_skill = {}
    setting.career = self.new_hero_vo.type

    for i, skill_id in pairs(self.talent_skill_list) do
        if i == index then
            setting.select_skill_id = skill_id
        else
            setting.dic_other_skill[skill_id] = true
        end
    end
    controller:openHeroResonateSelectTalentSkillPanel(true, setting)
end
--赋能
function HeroResonateTabEmpowermentPanel:onClickResonateBtn()
    if not self.scdata then return end
    if self.scdata.num <= 0  then
        message(TI18N("赋能次数不足"))
        return
    end

    if not self.select_hero_vo then return end
    if self.scdata.star <= 0 then return end
    if self.is_click_resonate  then return end

    if not self.is_show_redpoint then
        self:sendResonate()
        return
    end

    if self.item_sound ~= nil then
        AudioManager:getInstance():removeEffectByData(self.item_sound)
    end
    self.item_sound = AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.COMMON, 'c_get02', false)
    self.is_click_resonate = true
    self:showEffect(PlayerAction.action_2, false)
end

function HeroResonateTabEmpowermentPanel:sendResonate()
    if not self.scdata then return end

    if not self.select_hero_vo then return end
    if self.scdata.star <= 0 then return end
    local partner_id = self.select_hero_vo.id
    local skills = {}
    if self.talent_skill_list then
        for pos,skill_id in pairs(self.talent_skill_list) do
            table_insert(skills, {pos = pos, skill_id = skill_id})
        end
    end
    controller:sender26421(partner_id, skills)
end

function HeroResonateTabEmpowermentPanel:setData(parent)
    self.parent = parent
    if self.scdata == nil then
        controller:sender26420()
    end
    self.talent_skill_list = {}
    self.select_hero_vo = nil
    self:initSelectHeroInfo()
end

function HeroResonateTabEmpowermentPanel:setPowerValue(value)
    if not value then return end
    self.power:setString(value)
end

function HeroResonateTabEmpowermentPanel:setScdata(data)
    self.scdata = data
    self.talent_skill_list = {}
    self:initSkillItemList()
    self:updateCostInfo()
    self:setBtnstatus()

    if self.change_count_label then
        local str = string_format(TI18N("<div fontcolor=#ffffff outline=2,#000000>剩余赋能次数:</div><div fontcolor=#90f34e outline=2,#000000> %s<div>"), data.num)
        self.change_count_label:setString(str)
    end

    self:showEffect(PlayerAction.action_1, true)
end

function HeroResonateTabEmpowermentPanel:showEffect(action, is_loop)
    local action = action or PlayerAction.action_1
    if self.record_action == nil or self.record_action ~= action then
        self.record_action = action
        local is_loop = is_loop or false
        if self.change_effect == nil then
            self.change_effect = createEffectSpine("E24316", cc.p(356, 640), cc.p(0.5, 0.5), is_loop, action, 
                function() self:effectSpineCompleteAction() end)
            self.main_container:addChild(self.change_effect, 1) 
        else
            self.change_effect:setAnimation(0, action, is_loop)
        end
    end
end

function HeroResonateTabEmpowermentPanel:effectSpineCompleteAction()
    self:showEffect(PlayerAction.action_1, true)
    if self.is_click_resonate then
        self.is_click_resonate = false
        self:sendResonate()
    end
end

function HeroResonateTabEmpowermentPanel:setBtnstatus()
    if self.scdata and self.scdata.star then
        local star = model.resonate_max_partner_lev or 0
        -- if count >=5 then
            if star >= 30 then --ff,0xea,0xc6
                self.hero_star_tips:setString(string_format(TI18N("<div fontcolor=#ffeac6 outline=2,#643223>赋能的目标星级为供奉英雄历史最高平均星级(当前<div fontcolor=#90f34e outline=2,#643223>%s</div>星)</div>"), self.scdata.star))
                if self.select_hero_vo == nil then
                    self.hero_item_tips:setString(TI18N("<div fontcolor=#ffeac6 outline=2,#643223>请放入赋能对象英雄<div>"))
                    self.hero_item_tips:setPositionX(-80)
                    self.resonate_btn_label:setString(TI18N("暂无赋能对象"))
                    self.resonate_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
                    setChildUnEnabled(true, self.resonate_btn)
                    self.resonate_btn:setTouchEnabled(false)
                else
                    self.hero_item_tips:setString("")
                    setChildUnEnabled(false, self.resonate_btn)
                    self.resonate_btn_label:enableOutline(Config.ColorData.data_color4[264], 2)
                    self.resonate_btn:setTouchEnabled(true)
                    self.resonate_btn_label:setString(TI18N("赋能创造"))
                end

            else
                self.hero_item_tips:setString(string_format(TI18N("<div fontcolor=#f23b3b outline=2,#000000>需圣阵中英雄\n总星级达30(%s/30)</div>"), star))
                self.hero_item_tips:setPositionX(-60)
                self.hero_star_tips:setString("")
                self.resonate_btn_label:setString(TI18N("暂无赋能对象"))
                self.resonate_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
                setChildUnEnabled(true, self.resonate_btn)
                self.resonate_btn:setTouchEnabled(false)
            end
        
        -- else
        --     -- self.hero_item_tips:setString(TI18N("<div fontcolor=#f23b3b outline=2,#000000>需在圣阵中\n配置5个英雄</div>"))
        --     -- self.hero_item_tips:setPositionX(-52)
        --     self.hero_item_tips:setString(string_format(TI18N("<div fontcolor=#f23b3b outline=2,#000000>需圣阵中英雄\n总星级达30(%s/30)</div>"), star))
        --     self.hero_item_tips:setPositionX(-60)
        --     self.hero_star_tips:setString("")
        --     self.resonate_btn_label:setString(TI18N("暂无赋能对象"))
        --     self.resonate_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
        --     setChildUnEnabled(true, self.resonate_btn)
        --     self.resonate_btn:setTouchEnabled(false)
        -- end
    end
end

function HeroResonateTabEmpowermentPanel:initSelectHeroInfo()
    if self.select_hero_vo then
        self.hero_item_2:setData(self.select_hero_vo)
        self.hero_item_2:showAddIcon(false)
        self.hero_item_2:showRedPoint(false)
        self.limit_time:setVisible(true)
        self.power_click:setVisible(true)
        self.hero_item_1:setVisible(true)

        self.new_hero_vo = deepCopy(self.select_hero_vo)
        self.new_hero_vo.star = self.scdata.star
        local key = getNorKey(self.new_hero_vo.bid, self.new_hero_vo.star)
        local star_config = Config.PartnerData.data_partner_star(key)
        local lev_max = 1
        if star_config then
            lev_max = star_config.lev_max
        end
        if model.resonate_cystal_lev and model.resonate_cystal_lev > lev_max then
            lev_max = model.resonate_cystal_lev
        end
        self.new_hero_vo.lev = lev_max
        self.hero_item_1:setData(self.new_hero_vo)
        self:updateSpine(self.new_hero_vo, false)
    else
        self.hero_item_2:setData(nil)
        self.hero_item_2:showAddIcon(true)
        self.hero_item_2:showRedPoint(self.is_show_redpoint == true)

        self.hero_item_1:setData(nil)
        if self.spine then
            self.spine:removeFromParent()
            self.spine = nil
        end
        self.record_spine_bid = nil
        self.record_spine_star = nil
        self.record_spine_skin = nil

        self.limit_time:setVisible(false)
        self.power_click:setVisible(false)
        self.hero_item_1:setVisible(false)
    end
end

--更新模型,也是初始化模型
--@is_refresh  是否需要检测
function HeroResonateTabEmpowermentPanel:updateSpine(hero_vo, is_refresh)
    if self.record_spine_bid and self.record_spine_bid == hero_vo.bid and 
        self.record_spine_star and self.record_spine_star == hero_vo.star and
        self.record_spine_skin and self.record_spine_skin == hero_vo.use_skin then
        if is_refresh then
            if self.spine then
                local action1 = cc.FadeOut:create(0.2)
                local action2 = cc.FadeIn:create(0.2)
                self.spine:runAction(cc.Sequence:create(action1,action2))
            end    
        end
        return
    end
    self.record_spine_bid = hero_vo.bid
    self.record_spine_star = hero_vo.star
    self.record_spine_skin = hero_vo.use_skin

    local fun = function()    
        if not self.spine then
            self.spine = BaseRole.new(BaseRole.type.partner, hero_vo, nil, {scale = 1, skin_id = hero_vo.use_skin})
            self.spine:setAnimation(0,PlayerAction.show,true) 
            self.spine:setCascade(true)
            self.spine:setPosition(cc.p(360,785))
            self.spine:setAnchorPoint(cc.p(0.5,0.5)) 
            -- self.spine:setScale(1)
            self.main_container:addChild(self.spine, 3) 

            if self.select_hero_vo.use_skin ~= 0 then
                --策划要求..填null的话皮肤也不显示阴影 
                local skin_config = Config.PartnerSkinData.data_skin_info[hero_vo.use_skin]
                if skin_config and skin_config.hero_camp_res == "null" then
                    self.spine:showShadowUI(false)
                end
            end
            
            self.spine:setCascade(true)
            self.spine:setOpacity(0)
            local action = cc.FadeIn:create(0.2)
            self.spine:runAction(action)
        end
    end
    if self.spine then
        self.can_click_btn = false
        self.spine:setCascade(true)
        local action = cc.FadeOut:create(0.2)
        self.spine:runAction(cc.Sequence:create(action, cc.CallFunc:create(function()
                doStopAllActions(self.spine)
                self.spine:removeFromParent()
                self.spine = nil
                self.can_click_btn = true
                fun()
        end)))
    else
        fun()
    end
end

function HeroResonateTabEmpowermentPanel:initSkillItemList()
    if not self.scdata then return end
    for i,v in ipairs(self.config_list) do
        if self.skill_item_list[i] then
            if self.talent_skill_list[v.pos] then
                local config = Config.SkillData.data_get_skill(self.talent_skill_list[v.pos])
                if config then
                    self.skill_item_list[i].icon:setVisible(true)
                    self.skill_item_list[i].skill_level_bg:setVisible(true)
                    self.skill_item_list[i].skill_level:setVisible(true)
                    self.skill_item_list[i].skill_name_bg:setVisible(true)
                    self.skill_item_list[i].skill_name:setVisible(true)
                    self.skill_item_list[i].lock_icon:setVisible(false)
                    local level = config.level
                    if config.client_lev and config.client_lev>0 then
                        level = config.client_lev
                    end
                    self.skill_item_list[i].skill_level:setString(level)
                    self.skill_item_list[i].skill_name:setString(config.name)
                    if self.skill_item_list[i].record_icon == nil or self.skill_item_list[i].record_icon ~= config.icon then
                        self.skill_item_list[i].record_icon = config.icon 
                        local skill_icon = PathTool.getSkillRes(config.icon, false)
                        loadSpriteTexture(self.skill_item_list[i].icon, skill_icon, LOADTEXT_TYPE)
                    end
                end
            else
                self.skill_item_list[i].icon:setVisible(false)
                self.skill_item_list[i].lock_icon:setVisible(true)
                self.skill_item_list[i].skill_level_bg:setVisible(false)
                self.skill_item_list[i].skill_level:setVisible(false)
                
                -- self.skill_item_list[i].redPoint:setVisible(false)
                local is_open, lock_str
                if self.select_hero_vo  then
                    is_open, lock_str = model:checkOpenTanlentByconfig(v, self.scdata)
                else
                    is_open, lock_str = model:checkOpenTanlentByconfig(v, {star = 5})
                end

                local res
                if is_open then
                    res = PathTool.getResFrame("common","common_90026")
                    self.skill_item_list[i].skill_name_bg:setVisible(false)
                    self.skill_item_list[i].skill_name:setVisible(false)
                else
                    res = PathTool.getResFrame("common","common_90009")
                    self.skill_item_list[i].skill_name_bg:setVisible(true)
                    self.skill_item_list[i].skill_name:setVisible(true)
                    self.skill_item_list[i].skill_name:setString(lock_str)
                end
                loadSpriteTexture(self.skill_item_list[i].lock_icon, res, LOADTEXT_TYPE_PLIST)
            end
        end
    end
end


function HeroResonateTabEmpowermentPanel:updateCostInfo(  )
    if not self.scdata then return end
    local config = Config.ResonateData.data_star_cost[self.scdata.star]

    self.is_show_redpoint = true

    local d_config
    if config and config.loss1 and next(config.loss1) ~= nil then
        local item_id = config.loss1[1][1] or 1
        local count = config.loss1[1][2] or 0
        self.cost_item:setBaseData(item_id, 1)
        local have_num = BackpackController:getInstance():getModel():getItemNumByBid(item_id)
        self.cost_item:setNeedNum(count, have_num)
        if count > have_num then
            self.is_show_redpoint = false
        end
    else
        d_config = Config.ResonateData.data_star_cost[10]
        if d_config and  d_config.loss1 and next(d_config.loss1) ~= nil then
            local item_id = d_config.loss1[1][1] or 1
            self.cost_item:setBaseData(item_id, 1)
        end
        self.is_show_redpoint = false
    end

    if config and config.loss2 and next(config.loss2) ~= nil then
        for i=1,1 do
            local cost_data = config.loss2[i]
            local cost_icon = self.cost_icon[i]
            local cost_txt = self.cost_txt[i]
            if cost_data then
                local bid = cost_data[1]
                local num = cost_data[2]
                local item_config = Config.ItemData.data_get_data(bid)
                if item_config then
                    cost_icon:loadTexture(PathTool.getItemRes(item_config.icon), LOADTEXT_TYPE)
                    local have_num = BackpackController:getInstance():getModel():getItemNumByBid(bid)
                    cost_txt:setString(MoneyTool.GetMoneyString(have_num) .. "/" .. MoneyTool.GetMoneyString(num))
                    if have_num >= num then
                        cost_txt:setTextColor(cc.c3b(255, 246, 228))
                    else
                        self.is_show_redpoint = false
                        cost_txt:setTextColor(cc.c3b(253, 71, 71))
                    end
                end
            else
                cost_txt:setString("")
            end
        end
    else
        if d_config and  d_config.loss2 and next(d_config.loss2) ~= nil then
            local bid = d_config.loss2[1][1] or 1
            local item_config = Config.ItemData.data_get_data(bid)
            if item_config and self.cost_icon[1] and self.cost_txt[1] then
                self.cost_icon[1]:loadTexture(PathTool.getItemRes(item_config.icon), LOADTEXT_TYPE)
                self.cost_txt[1]:setString(0)
            end
        end
    end

    if self.is_show_redpoint then
        --材料够了.还得判断是否有合法英雄 的问策划
        if not self.select_hero_vo then
            self.hero_item_2:showRedPoint(true)
        else
            self.hero_item_2:showRedPoint(false)
        end
    else
        self.hero_item_2:showRedPoint(false)
    end
end


function HeroResonateTabEmpowermentPanel:setVisibleStatus(bool)
    self:setVisible(bool)
end

--移除
function HeroResonateTabEmpowermentPanel:DeleteMe()
    if self.select_hero_event then
        GlobalEvent:getInstance():UnBind(self.select_hero_event)
        self.select_hero_event = nil
    end
    if self.select_skill_event then
        GlobalEvent:getInstance():UnBind(self.select_skill_event)
        self.select_skill_event = nil
    end
    if self.hero_power_event then
        GlobalEvent:getInstance():UnBind(self.hero_power_event)
        self.hero_power_event = nil
    end
    if self.hero_resonate_empowerment_event then
        GlobalEvent:getInstance():UnBind(self.hero_resonate_empowerment_event)
        self.hero_resonate_empowerment_event = nil
    end
    if self.hero_resonate_empowerment_success_event then
        GlobalEvent:getInstance():UnBind(self.hero_resonate_empowerment_success_event)
        self.hero_resonate_empowerment_success_event = nil
    end
    if self.hero_resonate_skill_list_event then
        GlobalEvent:getInstance():UnBind(self.hero_resonate_skill_list_event)
        self.hero_resonate_skill_list_event = nil
    end

    if self.modify_goods_event then
        GlobalEvent:getInstance():UnBind(self.modify_goods_event)
        self.modify_goods_event = nil
    end
    if self.add_goods_event then
        GlobalEvent:getInstance():UnBind(self.add_goods_event)
        self.add_goods_event = nil
    end
    if self.del_goods_event then
        GlobalEvent:getInstance():UnBind(self.del_goods_event)
        self.del_goods_event = nil
    end

    if role_vo then
        if self.role_lev_event then
            role_vo:UnBind(self.role_lev_event)
            self.role_lev_event = nil
        end
    end

    if self.change_effect then
        self.change_effect:clearTracks()
        self.change_effect:removeFromParent()
        self.change_effect = nil
    end
end

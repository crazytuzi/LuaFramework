--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-03-07 20:52:12
-- @description    : 
		-- 圣物界面
---------------------------------
HalidomMainPanel = class("HalidomMainPanel",function()
    return ccui.Layout:create()
end)

local _controller = HalidomController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _table_sort = table.sort
local _string_format = string.format

function HalidomMainPanel:ctor(callback)
    self.select_callback = callback
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("hero/hero_halidom_panle"))

    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd)

    self.cur_tab_index = HalidomConst.Tab_Index.Lvup      -- 当前选中的tab（解锁状态下）
    self.cur_view_status = HalidomConst.View_Status.Lock  -- 当前界面状态
    self.halidom_list = {}      -- 全部圣物数据
    self.cur_halidom = {}       -- 当前选中的圣物数据
    self.tab_list = {}
    self.lvup_cost_list = {}
    self.all_attr_list = {}
    self.base_attr_list = {}
    self.lock_cost_hero_data = {}  -- 解锁消耗的宝可梦数据
    self.step_cost_bid = 0      -- 进阶消耗的物品bid
    self.step_cost_num = 0      -- 进阶消耗的物品数量
    self.step_icon_list = {}    -- 阶数图标
    self.step_cost_hero_data = {}  -- 进阶消耗的宝可梦数据
    self.step_hero_list = {}    -- 进阶需要的宝可梦item列表
    self.step_limit_tips = ""   -- 未达到进阶条件的提示

    self.role_vo = RoleController:getInstance():getRoleVo()

    local res_list = {}
    _table_insert(res_list, {path = PathTool.getPlistImgForDownLoad("halidom", "halidom"), type = ResourcesType.plist})
    _table_insert(res_list, {path = PathTool.getPlistImgForDownLoad("bigbg/haildom", "haildom_bg_1"), type = ResourcesType.single})
    if self.init_res_load then
        self.init_res_load:DeleteMe()
        self.init_res_load = nil
    end
    self.init_res_load = ResourcesLoad.New()
    self.init_res_load:addAllList(res_list, function()
        self:loadResListCompleted()
    end)
end

-- 资源加载完成
function HalidomMainPanel:loadResListCompleted(  )
    self:initView()
    self:initHalidomData()
    self:registerEvent()

    -- 请求圣物数据
    _controller:sender22200()
end

function HalidomMainPanel:initView(  )
    self.container = self.root_wnd:getChildByName("container")

    self.halidom_sp = self.container:getChildByName("halidom_sp")
    self.pos_node = self.container:getChildByName("pos_node")
    self.name_txt = self.container:getChildByName("name_txt")

    self.explain_btn = self.container:getChildByName("explain_btn")
    self.left_btn = self.container:getChildByName("left_btn")
    self.right_btn = self.container:getChildByName("right_btn")

    local tab_container = self.container:getChildByName("tab_container")
    for i=1,2 do
        local object = {}
        local tab_btn = tab_container:getChildByName("tab_btn_"..i)
        if tab_btn then
            tab_btn:loadTextures(PathTool.getResFrame("common","common_2010"), "", "", LOADTEXT_TYPE_PLIST)
            local title = tab_btn:getChildByName("title")
            title:setTextColor(Config.ColorData.data_new_color4[6])
            if i == 1 then
                title:setString(TI18N("注能"))
            elseif i == 2 then
                title:setString(TI18N("进阶"))
            end
            local tips = tab_btn:getChildByName("tips")
            object.tab_btn = tab_btn
            object.label = title
            object.index = i
            object.tips = tips
            self.tab_list[i] = object
        end
    end

    -- 锁定层
    self.lock_panel = self.container:getChildByName("lock_panel")
    self.lock_desc_txt = self.lock_panel:getChildByName("lock_desc_txt")
    self.unlock_btn = self.lock_panel:getChildByName("unlock_btn")
    self.unlock_btn:getChildByName("label"):setString(TI18N("解锁"))

    -- 升级与进阶层
    self.open_panel = self.container:getChildByName("open_panel")
    self.attr_tips = self.open_panel:getChildByName("attr_tips")
    self.memoir_btn = self.open_panel:getChildByName("memoir_btn")
    -- 升级
    self.lvup_panel = self.open_panel:getChildByName("lvup_panel")
    self.lvup_panel:getChildByName("attr_title"):setString(TI18N("基础属性:"))
    self.lvup_panel:getChildByName("lv_title"):setString(TI18N("圣物等级:"))
    self.lv_txt = self.lvup_panel:getChildByName("lv_txt")
    self.max_lv_bg = self.lvup_panel:getChildByName("max_lv_bg")
    self.max_lv_bg:getChildByName("label"):setString(TI18N("已达等级上限"))
    local progress_bg = self.lvup_panel:getChildByName("progress_bg")
    self.lvup_progress = progress_bg:getChildByName("progress")
    self.lvup_progress:setScale9Enabled(true)
    self.lvup_progress:setPercent(0)
    self.progress_value = progress_bg:getChildByName("progress_value")
    self.progress_value:setString("0/0")
    self.zhuneng_title = self.lvup_panel:getChildByName("zhuneng_title")
    self.zhuneng_title:setString(TI18N("注能消耗:"))
    for i=1,2 do
        local lvup_cost_bg = self.lvup_panel:getChildByName("lvup_cost_bg_" .. i)
        if lvup_cost_bg then
            local cost_object = {}
            cost_object.cost_bg = lvup_cost_bg
            cost_object.res_icon = lvup_cost_bg:getChildByName("res_icon")
            cost_object.label = lvup_cost_bg:getChildByName("label")
            _table_insert(self.lvup_cost_list, cost_object)
        end
    end
    self.lvup_btn = self.lvup_panel:getChildByName("lvup_btn")
    self.lvup_btn:getChildByName("label"):setString(TI18N("注能"))
    self.lvup_btn_tips = self.lvup_btn:getChildByName("tips")

    -- 进阶
    self.step_panel = self.open_panel:getChildByName("step_panel")
    self.step_panel:getChildByName("step_title"):setString(TI18N("进阶:"))
    self.max_step_bg = self.step_panel:getChildByName("max_step_bg")
    self.max_step_bg:getChildByName("label"):setString(TI18N("该圣物已达最大阶数"))
    self.step_cost_bg = self.step_panel:getChildByName("step_cost_bg")
    self.step_cost_icon = self.step_cost_bg:getChildByName("res_icon")
    self.step_cost_label = self.step_cost_bg:getChildByName("label")
    self.step_btn = self.step_panel:getChildByName("step_btn")
    self.step_btn:getChildByName("label"):setString(TI18N("进阶"))
    self.step_btn_tips = self.step_btn:getChildByName("tips")
    self.step_limit_lv_bg = self.step_panel:getChildByName("step_limit_lv_bg")
    self.step_limit_label = self.step_limit_lv_bg:getChildByName("label")
    self.step_arrow = self.step_panel:getChildByName("step_arrow")
    self.btn_step_pre = self.step_panel:getChildByName("btn_step_pre")
end

function HalidomMainPanel:setData(  )
    self.cur_halidom_index = self.cur_halidom_index or self:getDefaultHalidomIndex()

    self:selectHalidomByIndex(self.cur_halidom_index, true)
    self:updateTabInfo()
    self:updateViewShow()
end

-- 选中某一圣物
function HalidomMainPanel:selectHalidomByIndex( index, force, tab_index )
    if self.cur_halidom_index == index and not force then return end
    self.cur_halidom_index = index
    self.cur_halidom = self.halidom_list[self.cur_halidom_index]
    if not self.cur_halidom then return end

    self.init_lvup_flag = false
    self.init_step_flag = false
    if _model:checkHalidomIsUnlock(self.cur_halidom.id) then
        self.cur_view_status = HalidomConst.View_Status.Unlock
    else
        self.cur_view_status = HalidomConst.View_Status.Lock
    end

    self:updateViewShow()
    self:updateTabInfo()
    self:updateHalidomBaseInfo()
    self:changeSelectedTab(tab_index or HalidomConst.Tab_Index.Lvup, true)
    self:updateTabRedStatus()

    -- 顶部阵营按钮选中
    if self.select_callback then
        self.select_callback(self.cur_halidom.camp)
    end
end

-- 根据阵营选择圣物
function HalidomMainPanel:choseHalidomByCamp( camp )
    local index = 1
    for i,hData in ipairs(self.halidom_list) do
        if hData.camp == camp then
            index = i
            break
        end
    end
    self:selectHalidomByIndex(index)
end

-- 初始化圣物数据
function HalidomMainPanel:initHalidomData(  )
    self.halidom_list = {}
    for k,config in pairs(Config.HalidomData.data_base) do
        local halidom_data = deepCopy(config)
        halidom_data.vo = _model:getHalidomDataById(config.id)
        _table_insert(self.halidom_list, halidom_data)
    end
    -- 按照id排序
    local function sortFunc( objA, objB )
        return objA.id < objB.id
    end
    _table_sort(self.halidom_list, sortFunc)
end

-- 更新圣物数据
function HalidomMainPanel:updateHalidomData(  )
    for k,halidom_data in pairs(self.halidom_list) do
        halidom_data.vo = _model:getHalidomDataById(halidom_data.id)
    end
end

-- 显示圣物基础信息
function HalidomMainPanel:updateHalidomBaseInfo(  )
    if not self.cur_halidom then return end

    -- 圣物特效
    local action = PlayerAction.action_1
    if self.cur_view_status == HalidomConst.View_Status.Lock then
        action = PlayerAction.action_1
    else
        action = PlayerAction.action_2
    end 
    if self.cur_halidom.effect_id and self.cur_halidom_effect_id ~= self.cur_halidom.effect_id then
        self.cur_halidom_effect_id = self.cur_halidom.effect_id
        --if self.halidom_model then
        --    self.halidom_model:clearTracks()
        --    self.halidom_model:removeFromParent()
        --    self.halidom_model = nil
        --end
        --self.halidom_model = createEffectSpine(PathTool.getEffectRes(self.cur_halidom_effect_id), cc.p(0, 0), cc.p(0.5,0.5), true, action)
        --self.pos_node:addChild(self.halidom_model)
        loadSpriteTexture(self.halidom_sp, "resource/halidom/halidom_"..self.cur_halidom.id..".png", LOADTEXT_TYPE)
    end
    --if self.halidom_model then
    --    self.halidom_model:setAnimation(0, action, true)
    --end

    if self.cur_view_status == HalidomConst.View_Status.Lock then
        --if self.halidom_model then
        --    setChildUnEnabled(true, self.halidom_model)
        --end
        setChildUnEnabled(true, self.halidom_sp)

        self.name_txt:setString(self.cur_halidom.name)
        self.lock_desc_txt:setString(self.cur_halidom.desc)
        if not self.lock_tips then
            self.lock_tips = createRichLabel(24, cc.c4b(100,50,35,255), cc.p(0.5, 0.5), cc.p(360, 230), nil, nil, 590)
            self.lock_panel:addChild(self.lock_tips)
        end
        self.lock_tips:setString(self.cur_halidom.lock_desc)

        local lock_loss = self.cur_halidom.loss[1]
        if lock_loss then
            --模拟 hero_vo 需要的数据
            self.lock_cost_hero_data = {}
            self.lock_cost_hero_data.bid = 0
            self.lock_cost_hero_data.camp_type = lock_loss[1]
            self.lock_cost_hero_data.star = lock_loss[2] or 0
            self.lock_cost_hero_data.count = lock_loss[3] or 0
            self.lock_cost_hero_data.lev = _string_format("%s/%s", 0, lock_loss[3] or 0)
            self.lock_cost_hero_data.dic_select_list = {}
            if not self.lock_loss_item then
                self.lock_loss_item = HeroExhibitionItem.new(0.7, true)
                self.lock_panel:addChild(self.lock_loss_item)
                self.lock_loss_item:setPosition(cc.p(150, 150))
                self.lock_loss_item:addCallBack(function (  )
                    HeroController:getInstance():openHeroUpgradeStarSelectPanel(true, self.lock_cost_hero_data, {}, HeroConst.SelectHeroType.eHalidom)
                end)
            end
            local default_head_id = HeroController:getInstance():getModel():getRandomHeroHeadByQuality(self.lock_cost_hero_data.star)
            self.lock_loss_item:setData(self.lock_cost_hero_data)
            self.lock_loss_item:setDefaultHead(default_head_id)
            self.lock_loss_item:setHeadUnEnabled(true)
        end
        self:updateHalidomRedStatus()
    else
        --if self.halidom_model then
        --    setChildUnEnabled(false, self.halidom_model)
        --end
        setChildUnEnabled(false, self.halidom_sp)

        self.name_txt:setString(self.cur_halidom.name .. "Lv." .. (self.cur_halidom.vo.lev or 1))
        local camp_name = HeroConst.CampName[self.cur_halidom.camp]
        self.attr_tips:setString(_string_format(TI18N("%s系宝可梦属性加成:"), camp_name))
        -- 总属性
        for k,v in pairs(self.all_attr_list) do
            v:setVisible(false)
        end
        if self.cur_halidom.vo then
            local attr_num = #(self.cur_halidom.vo.all_attr or {})
            local pos_x_list = HalidomConst.Attr_Pos_X[attr_num]
            for i,attr in ipairs(self.cur_halidom.vo.all_attr or {}) do
                local attr_id = attr.name
                local attr_key = Config.AttrData.data_id_to_key[attr_id]
                local attr_val = changeBtValueForHeroAttr(attr.val, attr_key) or 0
                local attr_name = Config.AttrData.data_key_to_name[attr_key]
                if attr_name then
                    local attr_text = self.all_attr_list[i]
                    if attr_text == nil then
                        attr_text = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(0.5, 0.5), cc.p(20, 28), nil, nil, 380)
                        self.open_panel:addChild(attr_text)
                        self.all_attr_list[i] = attr_text
                    end
                    local pos_x = pos_x_list[i] or 360
                    attr_text:setPosition(cc.p(pos_x, 470))
                    attr_text:setVisible(true)
                    local icon = PathTool.getAttrIconByStr(attr_key)
                    local is_per = PartnerCalculate.isShowPerByStr(attr_key)
                    if is_per == true then
                        attr_val = (attr_val/10) .."%"
                    end
                    local attr_str = _string_format("<img src='%s' scale=1 /> <div fontcolor=#3d5078> %s：</div><div fontcolor=#0e7709>%s</div>", PathTool.getResFrame("common", icon), attr_name, tostring(attr_val))
                    attr_text:setString(attr_str)
                end
            end
        end
    end
end

-- 显示升级数据
function HalidomMainPanel:updateLvupInfo( force )
    if not self.cur_halidom then return end

    local all_lvup_cfg = Config.HalidomData.data_lvup[self.cur_halidom.id]
    if not all_lvup_cfg then return end
    local lvup_cfg = all_lvup_cfg[self.cur_halidom.vo.lev]
    if not lvup_cfg then return end

    -- 基础属性:(配置表中的基础属性值+注能增加的属性值)
    for k,v in pairs(self.base_attr_list) do
        v:setVisible(false)
    end
    if lvup_cfg.attr then
        for i,v in ipairs(lvup_cfg.attr) do
            local attr_key = v[1]
            local attr_val = changeBtValueForHeroAttr(v[2], attr_key) or 0
            local attr_name = Config.AttrData.data_key_to_name[attr_key]
            if attr_name then
                local attr_text = self.base_attr_list[i]
                if attr_text == nil then
                    attr_text = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(0.5, 0.5), cc.p(20, 28), nil, nil, 380)
                    self.lvup_panel:addChild(attr_text)
                    self.base_attr_list[i] = attr_text
                end
                attr_text:setPosition(cc.p(240 + (i-1) * 180, 255))
                attr_text:setVisible(true)

                -- 注能增加的属性值
                local add_val = 0
                local zhuneng_count = self.cur_halidom.vo.exp/lvup_cfg.exp
                if zhuneng_count > 0 then
                    for _,eAttr in pairs(lvup_cfg.exp_attr) do
                        if attr_key == eAttr[1] then
                            add_val = zhuneng_count * eAttr[2]
                            break
                        end
                    end
                end
                attr_val = attr_val + add_val
                local icon = PathTool.getAttrIconByStr(attr_key)
                local is_per = PartnerCalculate.isShowPerByStr(attr_key)
                if is_per == true then
                    attr_val = (attr_val/10) .."%"
                end
                local attr_str = _string_format("<img src='%s' scale=1 /> <div fontcolor=#3d5078> %s：</div><div fontcolor=#3d5078>%s</div>", PathTool.getResFrame("common", icon), attr_name, tostring(attr_val))
                attr_text:setString(attr_str)
            end
        end
    end

    local max_lv = Config.HalidomData.data_max_lev[self.cur_halidom.id]
    local is_max_lv = false
    -- 是否达到最大等级
    if self.cur_halidom.vo.lev >= max_lv then
        self.max_lv_bg:setVisible(true)
        self.lv_txt:setVisible(false)
        self.zhuneng_title:setVisible(false)
        self.lvup_btn:setVisible(false)
        self.progress_value:setVisible(false)
        for k,v in pairs(self.lvup_cost_list) do
            v.cost_bg:setVisible(false)
        end
        is_max_lv = true
    else
        self.max_lv_bg:setVisible(false)
        self.lv_txt:setVisible(true)
        self.zhuneng_title:setVisible(true)
        self.lvup_btn:setVisible(true)
        self.progress_value:setVisible(true)
        for k,v in pairs(self.lvup_cost_list) do
            v.cost_bg:setVisible(true)
        end
        self.lv_txt:setString("Lv." .. self.cur_halidom.vo.lev)
    end
    
    -- 进度
    if is_max_lv then
        self.lvup_progress:setPercent(100)
    else
        local percent = self.cur_halidom.vo.exp / lvup_cfg.total_exp * 100
        self.lvup_progress:setPercent(percent)
        self.progress_value:setString(_string_format("%d/%d", self.cur_halidom.vo.exp , lvup_cfg.total_exp))
    end

    -- 刷新升级消耗的道具图标（等级变化或切换圣物时才刷新）
    if force and not is_max_lv then
        for k,v in pairs(self.lvup_cost_list) do
            v.cost_bg:setVisible(false)
        end
        for i,v in ipairs(lvup_cfg.loss) do
            local bid = v[1]
            local num = v[2]
            local cost_object = self.lvup_cost_list[i]
            local item_config = Config.ItemData.data_get_data(bid)
            if cost_object and item_config then
                cost_object.cost_bg:setVisible(true)
                cost_object.cost_num = num
                local have_num = BackpackController:getInstance():getModel():getItemNumByBid(bid)
                if num > have_num then
                    cost_object.label:setTextColor(Config.ColorData.data_new_color4[11])
                else
                    cost_object.label:setTextColor(Config.ColorData.data_new_color4[12])
                end
                cost_object.label:setString(MoneyTool.GetMoneyString(have_num) .. "/" .. MoneyTool.GetMoneyString(num))
                if cost_object.cost_bid ~= bid then
                    -- 记录一下消耗的bid，用于数量实时刷新
                    cost_object.cost_bid = bid
                    local item_res = PathTool.getItemRes(item_config.icon)
                    cost_object.res_icon:loadTexture(item_res, LOADTEXT_TYPE)
                end
            end
        end
    end
end

-- 刷新进阶数据显示
function HalidomMainPanel:updateStepInfo(  )
    if not self.cur_halidom then return end

    local all_step_cfg = Config.HalidomData.data_step[self.cur_halidom.id]
    if not all_step_cfg then return end
    local step_cfg = all_step_cfg[self.cur_halidom.vo.step]
    if not step_cfg then return end

    -- 进阶图标
    for k,v in pairs(self.step_icon_list) do
        v.step_icon_bg:setVisible(false)
    end
    local max_step_num = Config.HalidomData.data_max_step[self.cur_halidom.id]
    local show_step_num = self.cur_halidom.vo.step + 1
    if show_step_num > max_step_num then
        show_step_num = max_step_num
    end
    local start_x = 140
    local distance_x = 35
    for i=1,show_step_num do
        local step_object = self.step_icon_list[i]
        if step_object == nil then
            step_object = self:createStepIcon()
            self.step_icon_list[i] = step_object
        end
        if step_object and step_object.step_icon_bg then
            step_object.step_icon_bg:setVisible(true)
            step_object.step_icon_bg:setPosition(cc.p(start_x + (i-1)*distance_x, 245))
            step_object.step_icon:setVisible(i <= self.cur_halidom.vo.step)
        end
    end

    -- 是否达到最大阶数
    if self.max_step_skill then
        self.max_step_skill:setVisible(false)
    end
    if self.cur_step_skill then
        self.cur_step_skill:setVisible(false)
    end
    if self.next_step_skill then
        self.next_step_skill:setVisible(false)
    end
    for k,v in pairs(self.step_hero_list) do
        v:setVisible(false)
    end
    if self.cur_halidom.vo.step >= max_step_num then
        self.max_step_bg:setVisible(true)
        self.step_cost_bg:setVisible(false)
        self.step_btn:setVisible(false)
        self.step_limit_lv_bg:setVisible(false)
        self.step_arrow:setVisible(false)

        -- 满阶技能图标
        if step_cfg.skill_icon then
            if not self.max_step_skill then
                self.max_step_skill = self:createHalidomSkillItem()
                self.max_step_skill:setPosition(cc.p(330, 180))
                self.step_panel:addChild(self.max_step_skill)
            end
            self.max_step_skill:setVisible(true)
            self:setHalidomSkillItemData(self.max_step_skill, step_cfg.skill_icon)
            setChildUnEnabled(false, self.max_step_skill.skill_icon)
        end
    else
        self.max_step_bg:setVisible(false)
        self.step_cost_bg:setVisible(true)
        self.step_btn:setVisible(true)

        local next_step_cfg = all_step_cfg[self.cur_halidom.vo.step+1]
        if next_step_cfg then
            -- 是否达到进阶条件
            local step_is_open = false
            local limit_lv = 0
            for k,v in pairs(next_step_cfg.conds) do
                if v[1] == "lev" then
                    limit_lv = v[2]
                    if limit_lv <= self.cur_halidom.vo.lev then
                        step_is_open = true
                    end
                end
            end
            if next_step_cfg.conds[1] == "lev" then
                if next_step_cfg.conds[2] <= self.cur_halidom.vo.lev then
                    step_is_open = true
                end
            end
            if step_is_open then
                self.step_limit_tips = ""
                self.step_limit_lv_bg:setVisible(false)
            else
                self.step_limit_lv_bg:setVisible(true)
                self.step_limit_tips = _string_format(TI18N("%d级可进阶"), limit_lv)
                self.step_limit_label:setString(self.step_limit_tips)
            end
            -- 是否为初次进阶
            if self.cur_halidom.vo.step == 0 then
                self.step_arrow:setVisible(false)
                if next_step_cfg.skill_icon then
                    if not self.max_step_skill then
                        self.max_step_skill = self:createHalidomSkillItem()
                        self.max_step_skill:setPosition(cc.p(330, 180))
                        self.step_panel:addChild(self.max_step_skill)
                    end
                    self.max_step_skill:setVisible(true)
                    self:setHalidomSkillItemData(self.max_step_skill, next_step_cfg.skill_icon)
                    setChildUnEnabled(true, self.max_step_skill.skill_icon)
                end
            else
                self.step_arrow:setVisible(true)
                -- 当前阶级技能图标
                if step_cfg.skill_icon then
                    if not self.cur_step_skill then
                        self.cur_step_skill = self:createHalidomSkillItem()
                        self.cur_step_skill:setPosition(cc.p(210, 180))
                        self.step_panel:addChild(self.cur_step_skill)
                    end
                    self.cur_step_skill:setVisible(true)
                    self:setHalidomSkillItemData(self.cur_step_skill, step_cfg.skill_icon)
                end

                -- 下阶级技能图标
                if next_step_cfg.skill_icon then
                    if not self.next_step_skill then
                        self.next_step_skill = self:createHalidomSkillItem()
                        self.next_step_skill:setPosition(cc.p(450, 180))
                        self.step_panel:addChild(self.next_step_skill)
                    end
                    self.next_step_skill:setVisible(true)
                    self:setHalidomSkillItemData(self.next_step_skill, next_step_cfg.skill_icon, true)
                end
            end

            -- 进阶道具消耗
            local step_cost_cfg = next_step_cfg.loss_items[1]
            if step_cost_cfg then
                local bid = step_cost_cfg[1]
                local num = step_cost_cfg[2]
                self.step_cost_bid = bid
                self.step_cost_num = num
                local item_config = Config.ItemData.data_get_data(bid)
                if item_config then
                    local item_res = PathTool.getItemRes(item_config.icon)
                    self.step_cost_icon:loadTexture(item_res, LOADTEXT_TYPE)
                    local have_num = BackpackController:getInstance():getModel():getItemNumByBid(bid)
                    if num > have_num then
                        self.step_cost_label:setTextColor(Config.ColorData.data_new_color4[11])
                    else
                        self.step_cost_label:setTextColor(Config.ColorData.data_new_color4[12])
                    end
                    self.step_cost_label:setString(MoneyTool.GetMoneyString(have_num) .. "/" .. MoneyTool.GetMoneyString(num))
                end
            end

            -- 宝可梦消耗
            self.step_cost_hero_data = {}
            -- 指定宝可梦
            for i,v in ipairs(next_step_cfg.loss_fixed) do
                local hero_data = self:getHeroData(v[1], v[2], v[3])
                _table_insert(self.step_cost_hero_data, hero_data)
            end
            -- 随机宝可梦
            for i,v in ipairs(next_step_cfg.loss_rand) do
                local hero_data = self:getHeroData(nil, v[2], v[3], v[1])
                _table_insert(self.step_cost_hero_data, hero_data)
            end
            for i,hero_vo in ipairs(self.step_cost_hero_data) do
                local hero_item = self.step_hero_list[i]
                if hero_item == nil then
                    hero_item = HeroExhibitionItem.new(0.8, true)
                    hero_item:addCallBack(function() self:_onClickStepHeroData(i) end)
                    self.step_panel:addChild(hero_item)
                    self.step_hero_list[i] = hero_item
                end
                hero_item:setHeadUnEnabled(true)
                hero_item:setVisible(true)
                hero_item:setPosition(cc.p(120 + (i-1) * (HeroExhibitionItem.Width * 0.8 + 10), 80))
                if hero_vo.bid == 0 then
                    --随机卡的头像id
                    local default_head_id = HeroController:getInstance():getModel():getRandomHeroHeadByQuality(hero_vo.star)
                    hero_item:setData(hero_vo)
                    hero_item:setDefaultHead(default_head_id)
                else
                    hero_item:setData(hero_vo)
                end
                hero_item:setHeadUnEnabled(true)
            end
        end
    end
end

-- 创建一个圣物技能图标
function HalidomMainPanel:createHalidomSkillItem(  )
    local layer_size = cc.size(119, 119)
    local skill_layer = ccui.Layout:create()
    skill_layer:setAnchorPoint(cc.p(0.5, 0.5))
    skill_layer:setContentSize(layer_size)
    skill_layer:setTouchEnabled(true)
    skill_layer:setScale(0.8)

    registerButtonEventListener(skill_layer, function (  )
        if skill_layer.skill_id then
            TipsManager:getInstance():showHalidomSkillTips(skill_layer.skill_id)
        end
    end)

    local icon_kuang = createSprite(PathTool.getResFrame("common", "common_1005"), layer_size.width/2, layer_size.height/2, skill_layer, cc.p(0.5, 0.5))
    local skill_icon = createSprite(nil, layer_size.width/2, layer_size.height/2, skill_layer, cc.p(0.5, 0.5), LOADTEXT_TYPE)
    local lv_bg = createSprite(PathTool.getResFrame("common", "common_2018"), layer_size.width-5, layer_size.height-5, skill_layer, cc.p(0.5, 0.5))
    local lv_txt = createLabel(20,Config.ColorData.data_new_color4[1],nil,13,15,"1",lv_bg,1,cc.p(0.5,0.5))
    --local skill_name = createLabel(26,cc.c3b(100,50,35,255),nil,layer_size.width/2,0,"",skill_layer,nil,cc.p(0.5,1))

    skill_layer.icon_kuang = icon_kuang
    skill_layer.skill_icon = skill_icon
    skill_layer.lv_bg = lv_bg
    skill_layer.lv_txt = lv_txt
    --skill_layer.skill_name = skill_name

    return skill_layer
end

function HalidomMainPanel:setHalidomSkillItemData( skill_item, skill_id, next_flag )
    local skill_cfg = Config.HalidomData.data_skill[skill_id]
    if not skill_cfg then return end

    skill_item.skill_id = skill_id

    if skill_item.skill_icon then
        loadSpriteTexture(skill_item.skill_icon, PathTool.getSkillRes(skill_cfg.res_id), LOADTEXT_TYPE)
    end
    
    --[[if skill_item.skill_name then
        if next_flag then
            skill_item.skill_name:setString(TI18N("进阶预览"))
        else
            skill_item.skill_name:setString(skill_cfg.name)
        end
    end--]]

    if skill_item.lv_bg and skill_item.lv_txt then
        skill_item.lv_bg:setVisible(true)
        skill_item.lv_txt:setString(skill_cfg.lev)
    end
end

function HalidomMainPanel:_onClickStepHeroData( index )
    if not self.step_cost_hero_data[index] then return end
    --标志点击了那个
    self.step_cost_hero_data[index].is_select = true
    self.step_cost_hero_data[index].is_ignore_hero_hun = true
    HeroController:getInstance():openHeroUpgradeStarSelectPanel(true, self.step_cost_hero_data[index], {}, HeroConst.SelectHeroType.eHalidom)
end

-- 获取宝可梦数据
function HalidomMainPanel:getHeroData(bid, star, count, camp_type)
    --模拟 hero_vo 需要的数据
    local data = {}
    data.star = star or 0
    data.count = count or 0
    data.lev = _string_format("%s/%s", 0, count)
    
    if bid == nil then
        data.bid = 0 --表示随机卡
        data.camp_type = camp_type
    else
        local base_config = Config.PartnerData.data_partner_base[bid]
        if base_config then
            data.bid = bid
            data.camp_type = base_config.camp_type
        else
            return nil
        end
    end
    data.dic_select_list = {}
    return data
end

-- 刷新选择宝可梦数据
function HalidomMainPanel:updateSelectHeroInfo(  )
    if self.cur_view_status == HalidomConst.View_Status.Lock then -- 锁住状态
        local count = 0
        for k,v in pairs(self.lock_cost_hero_data.dic_select_list) do
            count = count + 1
        end
        self.lock_cost_hero_data.lev = _string_format("%s/%s", count, self.lock_cost_hero_data.count)
        if self.lock_loss_item then
            self.lock_loss_item.num_label:setString(self.lock_cost_hero_data.lev)
            if count > 0 then
                self.lock_loss_item:setHeadUnEnabled(false)
            else
                self.lock_loss_item:setHeadUnEnabled(true)
            end
        end
    elseif self.cur_tab_index == HalidomConst.Tab_Index.Step then -- 进阶
        if not self.step_cost_hero_data then return end
        for i,item in ipairs(self.step_cost_hero_data) do
            if item.is_select then
                item.is_select = false
                local count = 0
                for k,v in pairs(item.dic_select_list) do
                    count = count + 1
                end
                item.lev = _string_format("%s/%s", count, item.count)
                if self.step_hero_list[i] then
                    self.step_hero_list[i].num_label:setString(item.lev)
                    if count > 0 then
                        self.step_hero_list[i]:setHeadUnEnabled(false)
                    else
                        self.step_hero_list[i]:setHeadUnEnabled(true)
                    end
                end
            end
        end
    end
end

-- 创建一个阶数图标
function HalidomMainPanel:createStepIcon(  )
    local step_object = {}
    step_object.step_icon_bg = createSprite(PathTool.getResFrame("halidom","halidom_1002"), 0, 0, self.step_panel, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
    step_object.step_icon = createSprite(PathTool.getResFrame("halidom","halidom_1001"), 15, 17, step_object.step_icon_bg, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
    return step_object
end

-- 刷新消耗道具数量
function HalidomMainPanel:checkNeedUpdateItemNum( item_list )
    if item_list == nil or next(item_list) == nil then return end
    for k, v in pairs(item_list) do
        if v.config then
            local bid = v.config.id
            self:updateCostItemNumByBid(bid)
        end
    end
end

function HalidomMainPanel:updateCostItemNumByBid( bid )
    if self.cur_view_status == HalidomConst.View_Status.Unlock then
        if self.cur_tab_index == HalidomConst.Tab_Index.Lvup then
            for _,cost_object in pairs(self.lvup_cost_list) do
                if cost_object.cost_bid == bid then
                    local have_num = BackpackController:getInstance():getModel():getItemNumByBid(bid)
                    if cost_object.cost_num > have_num then
                        cost_object.label:setTextColor(Config.ColorData.data_new_color4[11])
                    else
                        cost_object.label:setTextColor(Config.ColorData.data_new_color4[12])
                    end
                    cost_object.label:setString(MoneyTool.GetMoneyString(have_num) .. "/" .. MoneyTool.GetMoneyString(cost_object.cost_num))
                    break
                end
            end
        elseif self.cur_tab_index == HalidomConst.Tab_Index.Step then
            if self.step_cost_bid == bid then
                local have_num = BackpackController:getInstance():getModel():getItemNumByBid(bid)
                if self.step_cost_num > have_num then
                    self.step_cost_label:setTextColor(Config.ColorData.data_new_color4[11])
                else
                    self.step_cost_label:setTextColor(Config.ColorData.data_new_color4[12])
                end
                self.step_cost_label:setString(MoneyTool.GetMoneyString(have_num) .. "/" .. MoneyTool.GetMoneyString(self.step_cost_num))
            end
        end
    end
end

-- 根据当前界面类型刷新界面显示状态
function HalidomMainPanel:updateViewShow(  )
    if self.cur_view_status == HalidomConst.View_Status.Lock then
        self.lock_panel:setVisible(true)
        self.open_panel:setVisible(false)
    else
        if self.cur_tab_index == HalidomConst.Tab_Index.Lvup then
            self.lock_panel:setVisible(false)
            self.open_panel:setVisible(true)
            self.lvup_panel:setVisible(true)
            self.step_panel:setVisible(false)
        elseif self.cur_tab_index == HalidomConst.Tab_Index.Step then
            self.lock_panel:setVisible(false)
            self.open_panel:setVisible(true)
            self.lvup_panel:setVisible(false)
            self.step_panel:setVisible(true)
        end
    end
end

-- 刷新tab按钮显示
function HalidomMainPanel:updateTabInfo(  )
    if self.cur_view_status == HalidomConst.View_Status.Lock then
        for i,object in ipairs(self.tab_list) do
            if i == 1 then
                object.label:setString(TI18N("解锁"))
            else
                object.tab_btn:setVisible(false)
            end
        end
        self:changeSelectedTab(1, true)
    else
        for i,object in ipairs(self.tab_list) do
            if i == 1 then
                object.label:setString(TI18N("注能"))
            elseif i == 2 then
                object.label:setString(TI18N("进阶"))
            end
            object.tab_btn:setVisible(true)
        end
        self:changeSelectedTab(self.cur_tab_index, true)
    end
end

-- 获取默认选中的圣物下标
function HalidomMainPanel:getDefaultHalidomIndex(  )
    return 1
    -- todo
end

function HalidomMainPanel:registerEvent(  )
    -- 规则说明
    registerButtonEventListener(self.explain_btn, function ( param,sender, event_type )
        local rule_cfg = Config.HalidomData.data_const["halidom_rule"]
        if rule_cfg then
            TipsManager:getInstance():showCommonTips(rule_cfg.desc, sender:getTouchBeganPosition())
        end
    end)

    -- 传记
    registerButtonEventListener(self.memoir_btn, function (  )
        if self.cur_halidom then
            HeroController:getInstance():openHeroLibraryStoryPanel(true, self.cur_halidom.name, self.cur_halidom.msc)
        end
    end)

    -- 向左翻
    registerButtonEventListener(self.left_btn, function (  )
        if self.cur_halidom_index and self.halidom_list and next(self.halidom_list) ~= nil then
            local select_index = self.cur_halidom_index
            if select_index <= 1 then
                select_index = #self.halidom_list
            else
                select_index = select_index - 1
            end
            self:selectHalidomByIndex(select_index)
        end
    end)

    -- 向右翻
    registerButtonEventListener(self.right_btn, function (  )
        if self.cur_halidom_index and self.halidom_list and next(self.halidom_list) ~= nil then
            local select_index = self.cur_halidom_index
            if select_index >= #self.halidom_list then
                select_index = 1
            else
                select_index = select_index + 1
            end
            self:selectHalidomByIndex(select_index)
        end
    end)

    -- 进阶总览
    registerButtonEventListener(self.btn_step_pre, function (  )
        if self.cur_halidom then
            _controller:openHalidomStepPreView(true, self.cur_halidom.id)
        end
    end, true)

    -- 解锁
    registerButtonEventListener(self.unlock_btn, function (  )
        if self.cur_halidom and self.lock_cost_hero_data.dic_select_list and next(self.lock_cost_hero_data.dic_select_list) ~= nil then
            local hero_list = {}
            for hero_id,v in pairs(self.lock_cost_hero_data.dic_select_list) do
                _table_insert(hero_list, {id = hero_id})
            end
            _controller:sender22202(self.cur_halidom.id, hero_list)
        else
            message(TI18N("所需宝可梦不足"))
        end
    end, true)

    -- 注能
    registerButtonEventListener(self.lvup_btn, function (  )
        if self.cur_halidom then
            _controller:sender22203(self.cur_halidom.id)
        end
    end, true)

    -- 进阶
    registerButtonEventListener(self.step_btn, function (  )
        if self.step_limit_tips ~= "" then
            message(self.step_limit_tips)
        elseif self.cur_halidom and self.step_cost_hero_data and next(self.step_cost_hero_data) ~= nil then
            local hero_list = {} -- 固定宝可梦id
            local random_list = {} -- 随机宝可梦id
            for i,item in ipairs(self.step_cost_hero_data) do
                local count = 0
                for k,v in pairs(item.dic_select_list) do
                    count = count + 1
                end
                if count < item.count then
                    message(TI18N("所需宝可梦不足"))
                    return
                end
                for k,v in pairs(item.dic_select_list) do
                    if item.bid == 0 then
                        --随机卡
                        _table_insert(random_list, {id = k})
                    else
                        --指定卡
                        _table_insert(hero_list, {id = k})
                    end
                end
            end
            _controller:sender22204(self.cur_halidom.id, hero_list, random_list)
        end
    end, true)

    for k, object in pairs(self.tab_list) do
	   if object.tab_btn then
            object.tab_btn:addTouchEventListener(function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    playTabButtonSound()
                    self:changeSelectedTab(object.index)
                end
            end)
        end
    end

    -- 圣物数据返回
    if not self.get_halidom_data_event then
        self.get_halidom_data_event = GlobalEvent:getInstance():Bind(HalidomEvent.Get_Halidom_Data_Event, function (  )
            self:setData()
        end)
    end

    -- 圣物数据更新
    if not self.update_halidom_data_event then
        self.update_halidom_data_event = GlobalEvent:getInstance():Bind(HalidomEvent.Update_Halidom_Data_Event, function ( id )
            self:updateHalidomData()
            if self.cur_halidom and self.cur_halidom.id == id then
                self:selectHalidomByIndex(self.cur_halidom_index, true, self.cur_tab_index)
            end
        end)
    end

    --添加宝可梦选择返回事件
    if self.update_hero_select_event == nil then
        self.update_hero_select_event = GlobalEvent:getInstance():Bind(HeroEvent.Upgrade_Star_Select_Event, function()
            self:updateSelectHeroInfo()
        end)
    end

    -- 圣物红点
    if self.update_halidom_red_event == nil then
        self.update_halidom_red_event = GlobalEvent:getInstance():Bind(HalidomEvent.Update_Halidom_Red_Event, function()
            self:updateHalidomData()
            self:updateHalidomRedStatus()
            self:updateTabRedStatus()
        end)
    end

    -- 物品数量变化
    if not self.goods_add_event then
        self.goods_add_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS, function(bag_code, item_list) 
            if bag_code ~= BackPackConst.Bag_Code.BACKPACK then return end
            self:checkNeedUpdateItemNum(item_list)
        end)
    end
    if not self.goods_modify_event then
        self.goods_modify_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code, item_list) 
            if bag_code ~= BackPackConst.Bag_Code.BACKPACK then return end
            self:checkNeedUpdateItemNum(item_list)
        end)
    end
    if not self.goods_delete_event then
        self.goods_delete_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS, function(bag_code, item_list) 
            if bag_code ~= BackPackConst.Bag_Code.BACKPACK then return end
            self:checkNeedUpdateItemNum(item_list)
        end)
    end
    -- 金币更新
    if not self.role_lev_event and self.role_vo then
        self.role_lev_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value) 
            if key == "coin" then 
                self:updateCostItemNumByBid(1)
            end
        end)
    end
end

function HalidomMainPanel:changeSelectedTab( index, force )
    if not force and self.tab_object ~= nil and self.tab_object.index == index then return end
    if self.tab_object then
        self.tab_object.tab_btn:loadTextures(PathTool.getResFrame("common","common_2010"), "", "", LOADTEXT_TYPE_PLIST)
        self.tab_object.label:setTextColor(Config.ColorData.data_new_color4[6])
        self.tab_object.label:disableEffect(cc.LabelEffect.SHADOW)
        self.tab_object = nil
    end
    self.tab_object = self.tab_list[index]
    if self.tab_object then
        self.tab_object.tab_btn:loadTextures(PathTool.getResFrame("common","common_2009"), "", "", LOADTEXT_TYPE_PLIST)
        self.tab_object.label:setTextColor(Config.ColorData.data_new_color4[1])
        self.tab_object.label:enableShadow(Config.ColorData.data_new_color4[2],cc.size(0, -2),2)
    end

    self.cur_tab_index = index
    self:updateViewShow()
    self:updateTabRedStatus()

    if self.cur_view_status == HalidomConst.View_Status.Unlock then
        if index == HalidomConst.Tab_Index.Lvup and not self.init_lvup_flag then
            self.init_lvup_flag = true
            self:updateLvupInfo(force)
            self:updateHalidomRedStatus()
        elseif index == HalidomConst.Tab_Index.Step and not self.init_step_flag then
            self.init_step_flag = true
            self:updateStepInfo(force)
            self:updateHalidomRedStatus()
        end
    end
end

-- 更新界面红点显示
function HalidomMainPanel:updateHalidomRedStatus(  )
    if not self.cur_halidom then return end
    if self.cur_view_status == HalidomConst.View_Status.Lock and self.lock_loss_item then
        if _model:checkHalidomIsCanUnlock(self.cur_halidom.id) then
            addRedPointToNodeByStatus( self.lock_loss_item, true, 15, 15, nil, 2)
        else
            addRedPointToNodeByStatus( self.lock_loss_item, false)
        end
    elseif self.cur_tab_index == HalidomConst.Tab_Index.Step then
        if self.cur_halidom.vo and next(self.cur_halidom.vo) ~= nil and self.cur_halidom.vo:getRedStatusByType(HalidomConst.Red_Type.Step) then
            for k,hero_item in pairs(self.step_hero_list) do
                addRedPointToNodeByStatus( hero_item, true, 15, 15, nil, 2)
            end
        else
            for k,hero_item in pairs(self.step_hero_list) do
                addRedPointToNodeByStatus( hero_item, false)
            end
        end
    end
end

-- 更新tab按钮红点
function HalidomMainPanel:updateTabRedStatus(  )
    if not self.cur_halidom then return end
    if self.cur_view_status == HalidomConst.View_Status.Lock then
        for i,tab_object in ipairs(self.tab_list) do
            tab_object.tips:setVisible(false)
        end
        return
    end
    if not self.cur_halidom.vo or next(self.cur_halidom.vo) == nil then return end
    for i,tab_object in ipairs(self.tab_list) do
        local red_status = false
        if self.cur_tab_index ~= i then
            if i == 1 then
                red_status = self.cur_halidom.vo:getRedStatusByType(HalidomConst.Red_Type.Lvup)
            else
                red_status = self.cur_halidom.vo:getRedStatusByType(HalidomConst.Red_Type.Step)
            end
        end
        tab_object.tips:setVisible(red_status)
    end

    if self.cur_tab_index == HalidomConst.Tab_Index.Lvup then
        local red_status = self.cur_halidom.vo:getRedStatusByType(HalidomConst.Red_Type.Lvup)
        self.lvup_btn_tips:setVisible(red_status)
    end
end

function HalidomMainPanel:DeleteMe(  )
	if self.init_res_load then
        self.init_res_load:DeleteMe()
        self.init_res_load = nil
    end
    if self.halidom_res_load then
        self.halidom_res_load:DeleteMe()
        self.halidom_res_load = nil
    end
    if self.lock_loss_item then
        self.lock_loss_item:DeleteMe()
        self.lock_loss_item = nil
    end
    for k,item in pairs(self.step_hero_list) do
        item:DeleteMe()
        item = nil
    end
    --if self.halidom_model then
    --    self.halidom_model:clearTracks()
    --    self.halidom_model:removeFromParent()
    --    self.halidom_model = nil
    --end
    if self.update_hero_select_event then
        GlobalEvent:getInstance():UnBind(self.update_hero_select_event)
        self.update_hero_select_event = nil
    end
    if self.get_halidom_data_event then
        GlobalEvent:getInstance():UnBind(self.get_halidom_data_event)
        self.get_halidom_data_event = nil
    end
    if self.update_halidom_data_event then
        GlobalEvent:getInstance():UnBind(self.update_halidom_data_event)
        self.update_halidom_data_event = nil
    end
    if self.update_halidom_red_event then
        GlobalEvent:getInstance():UnBind(self.update_halidom_red_event)
        self.update_halidom_red_event = nil
    end
    if self.goods_add_event then
        GlobalEvent:getInstance():UnBind(self.goods_add_event)
        self.goods_add_event = nil
    end
    if self.goods_modify_event then
        GlobalEvent:getInstance():UnBind(self.goods_modify_event)
        self.goods_modify_event = nil
    end
    if self.goods_delete_event then
        GlobalEvent:getInstance():UnBind(self.goods_delete_event)
        self.goods_delete_event = nil
    end
    if self.role_lev_event and self.role_vo then
        self.role_vo:UnBind(self.role_lev_event)
        self.role_lev_event = nil
    end
end
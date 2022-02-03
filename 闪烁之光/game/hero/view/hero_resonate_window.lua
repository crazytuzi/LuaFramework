-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @description:
--      共鸣主界面 
-- <br/>Create: 2019年7月31日
--
-- --------------------------------------------------------------------
HeroResonateWindow = HeroResonateWindow or BaseClass(BaseView)

local controller = HeroController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_sort = table.sort
local table_insert = table.insert
local math_floor = math.floor

function HeroResonateWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Full
    self.layout_name = "hero/hero_resonate_window"
    local res = "spine/E24315/%s.png"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("heroresonate", "heroresonate"), type = ResourcesType.plist},
        { path = string_format(res, "action"), type = ResourcesType.single },
        { path = string_format(res, "action2"), type = ResourcesType.single },
        { path = string_format(res, "action3"), type = ResourcesType.single }
    }

    self.view_list = {}

    self.role_vo = RoleController:getInstance():getRoleVo()

    self.delayTime_param = 0.5
end

function HeroResonateWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    -- self:setBackgroundImg("hero_resonate_bg1")

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.main_container:setZOrder(2)
    self.container = self.main_container:getChildByName("container")
    self.spirit_btn = self.main_container:getChildByName("spirit_btn")
    self.spirit_btn:setVisible(false)
    self.spirit_btn:getChildByName("label"):setString(TI18N("魔液炼金"))

    self.close_btn = self.main_container:getChildByName("close_btn")
    

    self.title_bg = self.main_container:getChildByName("title_bg")
    self.title_name = self.title_bg:getChildByName("title_name")
    self.title_name:setString(TI18N("水晶等级"))
    self.lev = createRichLabel(22, cc.c4b(0xff,0xff,0xff,0xff), cc.p(0.5, 0.5), cc.p(97,-21),nil,nil,600)
    self.title_bg:addChild(self.lev)
    self.title_bg_x, self.title_bg_y = self.title_bg:getPosition()


    self.top_panel = self.main_container:getChildByName("top_panel")
    self.look_btn = self.top_panel:getChildByName("look_btn")

    local tab_type_list = {
        [1] = HeroConst.ResonateType.eResonate,
        [2] = HeroConst.ResonateType.eStoneTablet,
        [3] = HeroConst.ResonateType.eEmpowerment,
    }

    local tab_name_list = {
        [HeroConst.ResonateType.eResonate] = TI18N("共鸣"),
        [HeroConst.ResonateType.eStoneTablet] = TI18N("增幅"),
        [HeroConst.ResonateType.eEmpowerment] = TI18N("赋能")
    }

    self.tab_list = {}
    self.tab_container = self.top_panel:getChildByName("tab_container")
    for i=1,3 do
        local tab_btn = self.tab_container:getChildByName("tab_btn_"..i)
        if tab_btn then
            local object = {}
            object.unselect_bg = tab_btn:getChildByName('unselect_bg')
            object.unselect_bg:setVisible(true)
            object.select_bg = tab_btn:getChildByName('select_bg')
            object.select_bg:setVisible(false)
            -- object.label:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff))
            object.lable = tab_btn:getChildByName("title")
            object.tab_btn = tab_btn
            object.index = tab_type_list[i]
            object.lable:setString(tab_name_list[object.index])
            self.tab_list[object.index] = object
        end
    end
    self.hero_param = 100
    local pos = {
        [5] = {-600,-600},
        [3] = {-400,-600},
        [1] = {0,-700},
        [2] = {400,-600},
        [4] = {600,-600},
    }
    self.item_lay_list = {}
    for i=1, 5 do
        local item_lay = self.main_container:getChildByName("item_lay_"..i)
        self.item_lay_list[i] = {}
        self.item_lay_list[i].btn = item_lay
        self.item_lay_list[i].add_img = item_lay:getChildByName("add_img")
        self.item_lay_list[i].add_img:setVisible(false)
        self.item_lay_list[i].lock_img = item_lay:getChildByName("lock_img")
        self.item_lay_list[i].lock_img:setVisible(false)
        self.item_lay_list[i].lock_tips = self.item_lay_list[i].lock_img:getChildByName("lock_tips")
        -- self.item_lay_list[i].lev_img = item_lay:getChildByName("lev_img")
        -- self.item_lay_list[i].lev_img:setVisible(false)
        -- self.item_lay_list[i].lev = self.item_lay_list[i].lev_img:getChildByName("lev")
        local x, y = item_lay:getPosition()
        self.item_lay_list[i].x = x
        self.item_lay_list[i].y = y
        self.item_lay_list[i].pos = pos[i]

        y = y + self.hero_param
        local zorder = math_floor(1000 - y)
        item_lay:setZOrder(zorder)
    end
    self:adaptationScreen()
end

--设置适配屏幕
function HeroResonateWindow:adaptationScreen()
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop(self.main_container)
    local bottom_y = display.getBottom(self.main_container)
    local left_x = display.getLeft(self.main_container)
    local right_x = display.getRight(self.main_container)

    local container_size = self.main_container:getContentSize()
    local tab_y = self.top_panel:getPositionY()
    self.top_panel:setPositionY(top_y - (container_size.height - tab_y))

    -- local spirit_btn_y = self.spirit_btn:getPositionY()
    -- self.spirit_btn:setPositionY(top_y - (container_size.height - spirit_btn_y))
    self.spirit_btn_x, self.spirit_btn_y = self.spirit_btn:getPosition()


    -- local bottom_panel_y = self.bottom_panel:getPositionY()
    -- self.bottom_panel:setPositionY(bottom_y + bottom_panel_y)
    local close_btn_y = self.close_btn:getPositionY()
    self.close_btn:setPositionY(bottom_y + close_btn_y)


    -- --主菜单 顶部的高度
    -- local top_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
    -- --主菜单 底部的高度
    -- local bottom_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
end

function HeroResonateWindow:setBackgroundImg(bg_name)
    local bg_res = PathTool.getPlistImgForDownLoad("bigbg/resonate", bg_name, true)
    if self.record_bg_res ~= bg_res then
        self.record_bg_res = bg_res
        self.item_load_bg = loadImageTextureFromCDN(self.background, bg_res, ResourcesType.single, self.item_load_bg) 
    end
end


function HeroResonateWindow:register_event()
    -- registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 2)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 2)
    registerButtonEventListener(self.spirit_btn, handler(self, self.onClickBtnSpirit) ,true, 1)

    registerButtonEventListener(self.look_btn, function(param,sender, event_type) 
        if self.is_move_effect then return end
        if self.select_index then
            if self.select_index == HeroConst.ResonateType.eResonate then
                local config = Config.ResonateData.data_const.rule_tips2
                if config then
                    TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
                end
            elseif self.select_index == HeroConst.ResonateType.eEmpowerment then
                local config = Config.ResonateData.data_const.empowerment_rule_tips
                if config then
                    TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
                end
            end
        end
    end ,true, 1)

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

    -- 提炼魔液红点
    self:addGlobalEvent(HeroEvent.Hero_Resonate_Extract_Redpoint_Event, function(status)
        self:checkSpiritBtnRedpoint()
    end)
    -- 共鸣石碑红点
    self:addGlobalEvent(HeroEvent.Hero_Resonate_Info_Event, function(data)
        if data then
            if data.list then
                self:updateHeroList(data.list)
            end
            self:checkStoneTabletRedpoint()
            self:checkOpenStatus()
        end
    end)
    -- 共鸣水晶英雄
    self:addGlobalEvent(HeroEvent.Hero_Resonate_Crystal_Info_Event, function(data)
        -- self.crystal_scdata = data
        if data and data.con_list then
            self:updateLevelInfo(data)
            self:updateHeroList(data.con_list)
        end
        self:checkOpenStatus()
    end)

    if self.role_vo ~= nil then
        if self.role_lev_event == nil then
            self.role_lev_event =  self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, lev) 
                if not self.item_lay_list then return end
                if not self.dic_hero_vo then return end
                if key == "lev" then
                    for pos,v in ipairs(self.item_lay_list) do
                        if self.dic_hero_vo[pos] == nil then
                            self:checkPosLockUI(pos)
                        end
                    end
                end
                -- self:updateCostInfo()
            end)
        end
    end

end

function HeroResonateWindow:onClickBtnClose()
    if self.is_move_effect then return end
    controller:openHeroResonateWindow(false)
end

--打开提炼界面
function HeroResonateWindow:onClickBtnSpirit()
    if self.is_move_effect then return end
    controller:openHeroResonateExtractPanel(true)
end

function HeroResonateWindow:checkSpiritBtnRedpoint()
    if model:isResonateExtractRedpoint() then
        addRedPointToNodeByStatus(self.spirit_btn, true, 5, 5)
    else
        addRedPointToNodeByStatus(self.spirit_btn, false, 5, 5)
    end
end

function HeroResonateWindow:checkStoneTabletRedpoint()
    if self.tab_list[HeroConst.ResonateType.eStoneTablet] and self.tab_list[HeroConst.ResonateType.eStoneTablet].tab_btn then
        local tab_btn = self.tab_list[HeroConst.ResonateType.eStoneTablet].tab_btn 
        if model.is_resonate_stone_redpoint and  self.select_index and self.select_index ~= HeroConst.ResonateType.eStoneTablet then
            addRedPointToNodeByStatus(tab_btn, true, 0, 5)
        else
            addRedPointToNodeByStatus(tab_btn, false, 0, 5)
        end
    end
    
end

function HeroResonateWindow:setItemLayVisiable(bool)
    if self.item_lay_list then
        for i,v in ipairs(self.item_lay_list) do
            v.btn:setVisible(bool)
            if v.btn.spine then
                v.btn.spine:setVisible(bool)
            end
        end
    end
end

function HeroResonateWindow:checkResonateCystal( )
    if model:isResonateCystalMaxLev() then
       self:setItemLayVisiable(false)
    else
       self:setItemLayVisiable(true)
    end
end

-- 切换标签页
function HeroResonateWindow:changeSelectedTab(index, not_check)
    if model.resonate_max_partner_lev == nil and index ~= HeroConst.ResonateType.eResonate then return end --标志 26400协议未回来.不能点击
    if self.dic_lock_info and self.dic_lock_info[index] then
        message(self.dic_lock_info[index])
        return
    end
    if self.is_move_effect then return end
    if not not_check and self.tab_object ~= nil and self.tab_object.index == index then return end
    --标识是否改变页签的
    local is_change_tab = false
    local old_select = nil
    if self.tab_object then
        self.tab_object.select_bg:setVisible(false)
        -- self.tab_object.label:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff))
        old_select = self.tab_object.index
        self.tab_object = nil
        is_change_tab = true
    end
    self.select_index = index
    self.tab_object = self.tab_list[index]
    if self.tab_object then
        self.tab_object.select_bg:setVisible(true)
        -- self.tab_object.label:setTextColor(cc.c4b(0xff, 0xed, 0xd6, 0xff))
    end

    if index == HeroConst.ResonateType.eResonate then
        --水晶
        self.look_btn:setVisible(true)
        -- self:setBackgroundImg("hero_resonate_bg1")
        if is_change_tab then
            self:setPrePanel() 
            if old_select and old_select == HeroConst.ResonateType.eEmpowerment then
                self:setEffectSpineAction(3)
            end
        else
            self:setEffectSpineAction(0)
        end
        self:checkResonateCystal()

    elseif index == HeroConst.ResonateType.eStoneTablet then
        --英雄石碑增益
        self.look_btn:setVisible(false)
        -- self:setBackgroundImg("hero_resonate_bg1")
        if is_change_tab then
            self:setPrePanel()
            self:setItemLayVisiable(true)
            if old_select and old_select == HeroConst.ResonateType.eEmpowerment then
                self:setEffectSpineAction(3)
            end
        else
            self:setEffectSpineAction(0)
        end
    elseif index == HeroConst.ResonateType.eEmpowerment then
        --英雄石碑注能
        self.look_btn:setVisible(true)
        -- self:setBackgroundImg("hero_resonate_bg2")
        if is_change_tab then
            self:setEffectSpineAction(1)
        else
            self:setEffectSpineAction(2)    
        end
    end
    self:checkStoneTabletRedpoint()
    if not is_change_tab then
        self:setPrePanel()
        if index ~= HeroConst.ResonateType.eEmpowerment and self.pre_panel and self.pre_panel.playEnterAnimatian  then
            self.pre_panel:playEnterAnimatian()
        end
    end
end

function HeroResonateWindow:setPrePanel()
    if not self.select_index then return end

    if self.pre_panel ~= nil then
        if self.pre_panel.setVisibleStatus then
            self.pre_panel:setVisibleStatus(false)
        else
            self.pre_panel:setVisible(false)
        end
    end
    self.pre_panel = self:createSubPanel(self.select_index)
    if self.pre_panel ~= nil then
        if self.pre_panel.setVisibleStatus then
            self.pre_panel:setVisibleStatus(true)
        else
            self.pre_panel:setVisible(true)
        end
    end
    self.pre_panel:setData(self)
    self:updateHeroListBySelect(self.select_index)
end

--@from_type 类型 0 表示石碑圣阵界面 1 表示从石碑到注能  2 赋能单帧 3 会到石碑
function HeroResonateWindow:setEffectSpineAction(from_type)
    self.is_move_effect = true
    self.from_type = from_type or 0
    local action-- = PlayerAction.action_1
    local is_loop = false
    if self.from_type == 1 then
        action = PlayerAction.action_1
        local panel = self.view_list[HeroConst.ResonateType.eStoneTablet]
        if panel then
            panel:runShowAction(true)
        end
        local panel = self.view_list[HeroConst.ResonateType.eResonate]
        if panel then
            panel:runShowAction(true)
        end
        self:runShowAction(true)
        self:spiritAction(false)
    elseif self.from_type == 2 then --单帧
        action = PlayerAction.action_2
        self.is_move_effect = false
    elseif self.from_type == 3 then
        action = PlayerAction.action_3
        local panel = self.view_list[HeroConst.ResonateType.eStoneTablet]
        if panel then
            panel:runShowAction(false)
        end
        local panel = self.view_list[HeroConst.ResonateType.eResonate]
        if panel then
            panel:runShowAction(false)
        end
        self:runShowAction(false)
        self:spiritAction(false)
        self:spiritAction(true, true)
    else
        action = "action0"
        is_loop = true
        self.is_move_effect = false
    end
    --特效
    if self.change_effect == nil then
        --特效完成一次调用函数
        self.change_effect = createEffectSpine("E24315", cc.p(360, 640), cc.p(0.5, 0.5), is_loop, action, 
            function() self:effectSpineCompleteAction() end)
        self.root_wnd:addChild(self.change_effect, 1) 
    else
        -- self.change_effect:setVisible(true)
        self.change_effect:setAnimation(0, action, is_loop)
    end
end

--完成一次调研函数
function HeroResonateWindow:effectSpineCompleteAction()
    if self.from_type == 1 then
        self:setPrePanel() 
        self:setEffectSpineAction(2)
        self:spiritAction(true, false)
    elseif self.from_type == 3 then
        self:setEffectSpineAction(0)
    end
    -- self.change_effect:setVisible(false)
    self.is_move_effect = false
    self:checkShowHeroList()
end

function HeroResonateWindow:spiritAction(is_show, is_delay)
    if not self.spirit_btn_x or not self.spirit_btn_y then return end
    self.spirit_btn:setTouchEnabled(false)
    local callback = function()
        self.spirit_btn:setTouchEnabled(true)
    end
    if is_show then
        local moveto = cc.MoveTo:create(0.2,cc.p(self.spirit_btn_x, self.spirit_btn_y))
        local fadeIn = cc.FadeIn:create(0.15)
        local spawn_action = cc.Spawn:create(moveto, fadeIn)
        if is_delay then
            self.spirit_btn:runAction(cc.Sequence:create(cc.DelayTime:create(1.1), spawn_action, cc.CallFunc:create(callback)))
        else
            self.spirit_btn:runAction(cc.Sequence:create(spawn_action, cc.CallFunc:create(callback)))
        end
    else
        local moveto = cc.MoveTo:create(0.6,cc.p(-100, self.spirit_btn_y))
        local fadeOut = cc.FadeOut:create(0.55)
        local spawn_action = cc.Spawn:create(moveto, fadeOut)
        self.spirit_btn:runAction(spawn_action)
    end
end

function HeroResonateWindow:createSubPanel(index)
    local panel = self.view_list[index]
    if panel == nil then
        if index == HeroConst.ResonateType.eResonate then
            --英雄共鸣
            panel = HeroResonateTabResonatePanel.new()
        elseif index == HeroConst.ResonateType.eStoneTablet then
            --英雄石碑增益
            panel = HeroResonateTabStoneTabletPanel.new(self)
        elseif index == HeroConst.ResonateType.eEmpowerment then
            --英雄石碑注能
            panel = HeroResonateTabEmpowermentPanel.new()
        end
        local size = self.container:getContentSize()
        panel:setPosition(cc.p(size.width * 0.5 , size.height * 0.5))
        self.container:addChild(panel)
        self.view_list[index] = panel
    end
    return panel
end



function HeroResonateWindow:openRootWnd(index)
    self.select_index =  index or HeroConst.ResonateType.eResonate
    self.is_send_proto = nil
    self:checkOpenStatus()
    self:changeSelectedTab(self.select_index)

    self:checkSpiritBtnRedpoint()
end

function HeroResonateWindow:checkOpenStatus()
    if model.resonate_max_partner_lev == nil then return end --标志 26400协议未回来.不能点击
    if self.is_check_open then return end
    self.is_check_open = true
    self.dic_lock_info = {}
    --增幅 开启条件
    local resonate_stone_condition = 50
    local tips 
    local config = Config.ResonateData.data_const.amp_all_start_limit
    if config then
        resonate_stone_condition = config.val
        tips = config.desc
    else
        tips = TI18N("供奉英雄总星级达到50")
    end
    if model.resonate_max_partner_lev < resonate_stone_condition then
        self.dic_lock_info[HeroConst.ResonateType.eStoneTablet] = tips
    else
        self.spirit_btn:setVisible(true)
    end

    --赋能开启条件
    local empowerment_condition = 30
    local config = Config.ResonateData.data_const.empowerment_condition
    if config then
        empowerment_condition = config.val
        tips = config.desc
    else
        tips = TI18N("供奉英雄总星级达到30")
    end
    
    if model.resonate_max_partner_lev < empowerment_condition then
        self.dic_lock_info[HeroConst.ResonateType.eEmpowerment] = tips
    end
    for k,v in pairs(self.dic_lock_info) do
        if self.tab_list[k] then
            --锁
            setChildUnEnabled(true, self.tab_list[k].tab_btn)
        else
            -- setChildUnEnabled(false, self.tab_list[k].tab_btn)
        end
    end
end


--更新等级
function HeroResonateWindow:updateLevelInfo(scdata)
    if model:isResonateCystalMaxLev() then
        if scdata.is_break == 1 then
            self.lev:setString(string_format("<div fontcolor=#FFEECC outline=2,#422A1B>Lv.<div fontcolor=#4BFFE8 outline=2,#422A1B>%s</div>/%s</div>", scdata.lev, scdata.max_cystal_lev))
        else
            self.lev:setString(string_format("<div fontcolor=#FFEECC outline=2,#422A1B>Lv.%s</div>", scdata.lev))
        end
    else
        self.lev:setString(string_format("<div fontcolor=#FFEECC outline=2,#422A1B>Lv.%s</div>", scdata.lev))
    end 
end

function HeroResonateWindow:updateHeroList(list)
    if not list then return end
    if self.dic_hero_vo then return end
    if not self.select_index then return end
    if self.select_index == HeroConst.ResonateType.eResonate and model:isResonateCystalMaxLev() then
        return
    end
    self.dic_partner_id = {}
    self.dic_hero_vo = {}
    for i,v in ipairs(list) do
        if v.id ~= 0 then
            local hero_vo = model:getHeroById(v.id)
            if hero_vo and next(hero_vo) ~= nil then
                table_insert(self.dic_hero_vo, hero_vo)
                self.dic_partner_id[hero_vo.partner_id] = hero_vo
                -- self.dic_hero_vo[v.pos] = hero_vo
            end
        end
    end
    local func = SortTools.tableLowerSorter({"lev","id"})
    table.sort( self.dic_hero_vo, func )
    self.is_must_init_hero = true
    self:checkShowHeroList()
end

function HeroResonateWindow:checkShowHeroList( )
    if self.is_move_effect then return end
    if self.is_must_init_hero then
        self.is_must_init_hero = false
        for pos,v in ipairs(self.item_lay_list) do
            if self.is_init_hero then
                delayRun(self.main_container, pos * 0.04, function()
                    self:updateHSingleHero(pos, v)
                end)
            else
                self:updateHSingleHero(pos, v)
            end
        end
        self.is_init_hero = false
    end
end

function HeroResonateWindow:updateHeroListBySelect(index)
    if not self.dic_hero_vo then return end
    for pos,v in ipairs(self.item_lay_list) do
        if self.dic_hero_vo[pos] == nil then 
            if v.btn and v.btn.lev_img then
                v.btn.lev_img:setVisible(false)
            end
            if v.btn.star_node then
                v.btn.star_node:setVisible(false)
            end
        else
            if v.btn and v.btn.lev_img then
                if index == HeroConst.ResonateType.eResonate then
                    v.btn.lev_img:setVisible(true)
                else
                    v.btn.lev_img:setVisible(false)
                end
            end
            if v.btn.star_node then
                if self.select_index == HeroConst.ResonateType.eResonate then
                    v.btn.star_node:setVisible(false)
                else
                    v.btn.star_node:setVisible(true)
                end
            end
        end 
    end
end


function HeroResonateWindow:updateHSingleHero(pos, v)
    if self.dic_hero_vo[pos] == nil then
                --判断解锁 
        self:checkPosLockUI(pos)
        if v.btn.spine then
            v.btn.spine:removeFromParent()
            v.btn.spine = nil
        end
        v.btn.record_spine_bid = nil
        v.btn.record_spine_star = nil
        v.btn.record_spine_skin = nil
        if v.btn.lev_img then
            v.btn.lev_img:setVisible(false)
        end
        if v.btn.star_node then
            v.btn.star_node:setVisible(false)
        end
    else
        v.lock_img:setVisible(false)
        v.add_img:setVisible(false)
        if v.btn.lev_img then
            if self.select_index == HeroConst.ResonateType.eResonate then
                v.btn.lev_img:setVisible(true)
            else
                v.btn.lev_img:setVisible(false)
            end
        end
        if v.btn.star_node then
            if self.select_index == HeroConst.ResonateType.eResonate then
                v.btn.star_node:setVisible(false)
            else
                v.btn.star_node:setVisible(true)
            end
        end
        -- v.lev:setString("Lv."..self.dic_hero_vo[pos].lev)
        self:updateAddSpine(pos, true, true)
        self:updateSpine(v.btn, self.dic_hero_vo[pos], false, pos)
    end
end

--检查位置解锁
function HeroResonateWindow:checkPosLockUI(pos)
    if not self.item_lay_list or not self.item_lay_list[pos] then return end
    local is_lock, lock_str = self:checkPosLockByPos(pos)
    if is_lock then
        self.item_lay_list[pos].lock_img:setVisible(true)
        self.item_lay_list[pos].lock_tips:setString(lock_str)
        self:updateAddSpine(pos, false)
    else
        self.item_lay_list[pos].lock_img:setVisible(false)
        self:updateAddSpine(pos, true)
    end
    -- self.item_lay_list[pos].add_img:setVisible(true)
end

function HeroResonateWindow:updateAddSpine(pos, is_show, is_not_add_mark)
    if not self.item_lay_list or not self.item_lay_list[pos] then return end
    if is_show then
        
        local action, x, y, scale
        scale = 1
        if pos == 4 then
            if is_not_add_mark then
                action = PlayerAction.action_4
            else
                action = PlayerAction.action_1
            end
            x = -204
            y = -44
        elseif pos == 2 then
            if is_not_add_mark then
                action = PlayerAction.action_5
            else
                action = PlayerAction.action_2
            end
            x = -90
            y = 15
        elseif pos == 3 then
            if is_not_add_mark then
                action = PlayerAction.action_5
            else
                action = PlayerAction.action_2
            end
            x = 199
            y = 15
            scale = -1
        elseif pos == 5 then
            if is_not_add_mark then
                action = PlayerAction.action_4
            else
                action = PlayerAction.action_1
            end
            x = 302
            y = -44
            scale = -1 
        else --pos == 1 
            if is_not_add_mark then
                action = PlayerAction.action_6
            else
                action = PlayerAction.action_3
            end
            x = 50
            y = 60
        end
        if self.item_lay_list[pos].add_spine == nil then
            self.item_lay_list[pos].add_spine = createEffectSpine("E24317", cc.p(x, y), cc.p(0.5, 0.5), true, action)
            self.item_lay_list[pos].btn:addChild(self.item_lay_list[pos].add_spine)
            self.item_lay_list[pos].add_spine:setScaleX(scale)
        else
            self.item_lay_list[pos].add_spine:setVisible(true) 
            self.item_lay_list[pos].add_spine:setAnimation(0, action, true)
        end
    else
        if self.item_lay_list[pos].add_spine then
            self.item_lay_list[pos].add_spine:setVisible(false)
        end
    end
end

function HeroResonateWindow:checkPosLockByPos(pos)
    local config = Config.ResonateData.data_pos_info[pos]
    if config then
        local is_lock = false
        local lock_str = ""
        for i,v in ipairs(config.pos_cond) do
            --配置表只有等级的限制 后面还有再加吧
            if v[1] == "lev" then
                if role_vo and role_vo.lev < v[2] then
                    is_lock = true
                    lock_str = lock_str..string_format(TI18N("%s级解锁"), v[2])
                end
            end
        end
        return is_lock, lock_str
    end
    return false
end

--更新模型,也是初始化模型
--@is_refresh  是否需要刷新(其实是假刷新)
function HeroResonateWindow:updateSpine(parent_panel, hero_vo, is_refresh, pos)
    if parent_panel.record_spine_bid and parent_panel.record_spine_bid == hero_vo.bid and 
        parent_panel.record_spine_star and parent_panel.record_spine_star == hero_vo.star and
        parent_panel.record_spine_skin and parent_panel.record_spine_skin == hero_vo.use_skin then
        if is_refresh then
            if parent_panel.spine then
                local action1 = cc.FadeOut:create(0.2)
                local action2 = cc.FadeIn:create(0.2)
                parent_panel.spine:runAction(cc.Sequence:create(action1,action2))
            end    
        end
        return
    end
    parent_panel.record_spine_bid = hero_vo.bid
    parent_panel.record_spine_star = hero_vo.star
    parent_panel.record_spine_skin = hero_vo.use_skin

    local fun = function()    
        if not parent_panel.spine then
            parent_panel.spine = BaseRole.new(BaseRole.type.partner, hero_vo, nil, {scale = 0.45, skin_id = hero_vo.use_skin})
            parent_panel.spine:setAnimation(0,PlayerAction.show,true) 
            parent_panel.spine:setCascade(true)
            local x, y = parent_panel:getPosition()
            parent_panel.spine:setPosition(cc.p(x, y + self.hero_param))
            -- parent_panel.spine:setPositionY(66)
            parent_panel.spine:setAnchorPoint(cc.p(0.5,0.5)) 
            -- parent_panel.spine:setScale(0.8)
            local pos1 = math_floor(1000 - y)
            self.main_container:addChild(parent_panel.spine, pos1) 
            parent_panel.spine:setOpacity(0)
            local action = cc.FadeIn:create(0.2)
            parent_panel.spine:runAction(action)
            self:createLevItem(parent_panel, hero_vo.lev, pos)
            self:createStar(parent_panel, hero_vo.star)
        end
    end
    if parent_panel.spine then
        doStopAllActions(parent_panel.spine)
        parent_panel.spine:removeFromParent()
        parent_panel.spine = nil
        fun()
    else
        fun()
    end
end

--创建等级item
function HeroResonateWindow:createLevItem(parent_panel, lev, pos)
    local spine = parent_panel.spine
    local bg = createImage(spine, PathTool.getResFrame("common", "common_1049"), 0, -100, cc.p(0.5, 0.5), true, 1, true)
    bg:setContentSize(cc.size(86, 41))
    bg:setCapInsets(cc.rect(14, 13, 14, 6))
    parent_panel.lev_img = bg
    local lev_str = "Lv."..lev
    if pos == 1 then 
        createLabel(20,cc.c4b(0x4B,0xFF,0xE8,0xff),cc.c4b(0x42,0x2A,0x1B,0xff),43,20,lev_str,bg,2,cc.p(0.5, 0.5))
    else
        createLabel(20,cc.c4b(0xFF,0xEE,0xCC,0xff),cc.c4b(0x42,0x2A,0x1B,0xff),43,20,lev_str,bg,2,cc.p(0.5, 0.5))
    end
    if self.select_index == HeroConst.ResonateType.eResonate then
        bg:setVisible(true)
    else
        bg:setVisible(false)
    end
end

function HeroResonateWindow:createStar(parent_panel, num)
    local spine = parent_panel.spine
    parent_panel.star_node = cc.Node:create()
    parent_panel.star_node:setCascadeOpacityEnabled(true)
    parent_panel.star_node:setName("createStar")
    parent_panel.star_node:setPosition(0, 84)
    spine:addChild(parent_panel.star_node)
    local num = num or 0
    local width = 26
    parent_panel.star_setting = model:createStar(num, parent_panel.star_node, parent_panel.star_setting, width)
    if self.select_index == HeroConst.ResonateType.eResonate then
        parent_panel.star_node:setVisible(false)
    else
        parent_panel.star_node:setVisible(true)
    end
end

function HeroResonateWindow:runShowAction(is_run)
    if is_run then
        if self.title_bg then
            local fadeOut = cc.FadeIn:create(0.8)
            local moveto = cc.MoveTo:create(0.8,cc.p(self.title_bg_x, 2000))
            local spawn_action = cc.Spawn:create(moveto, fadeOut)
            self.title_bg:runAction(spawn_action)
        end
        if self.item_lay_list then
            for i,v in ipairs(self.item_lay_list) do
                self:runActionTo(v)
            end
        end
    else
        if self.title_bg then
            self.title_bg:setPositionY(2000)
            local fadeIn = cc.FadeIn:create(0.65)
            local moveto = cc.MoveTo:create(0.65,cc.p(self.title_bg_x, self.title_bg_y))
            local spawn_action = cc.Spawn:create(moveto, fadeIn)
            self.title_bg:runAction(cc.Sequence:create(cc.DelayTime:create(self.delayTime_param), spawn_action))
        end
        if self.item_lay_list then
            for i,v in ipairs(self.item_lay_list) do
                self:runActionBack(v)
            end
        end
    end
end

function HeroResonateWindow:runActionTo(item)
    local node = item.btn
    local x = item.x + item.pos[1]
    local y = item.y + item.pos[2]
    local moveto = cc.MoveTo:create(0.8,cc.p(x, y))
    local fadeOut = cc.FadeOut:create(0.8)
    local spawn_action = cc.Spawn:create(moveto, fadeOut)
    node:runAction(cc.Sequence:create(spawn_action))
    if item.btn.spine then
        local moveto = cc.MoveTo:create(0.8,cc.p(x, y + self.hero_param))
        local fadeOut = cc.FadeOut:create(0.8)
        local scale = cc.ScaleTo:create(0.8, 3)
        local spawn_action = cc.Spawn:create(moveto, scale, fadeOut)
        item.btn.spine:runAction(cc.Sequence:create(spawn_action))
    end
end
function HeroResonateWindow:runActionBack(item)
    local node = item.btn

    local old_x = item.x + item.pos[1]
    local old_y = item.y + item.pos[2]
    node:setPosition(old_x, old_y)
    local x = item.x
    local y = item.y
    local moveto = cc.MoveTo:create(0.65,cc.p(x, y))
    local fadeIn = cc.FadeIn:create(0.65)
    local spawn_action = cc.Spawn:create(moveto, fadeIn)
    node:runAction(cc.Sequence:create(cc.DelayTime:create(self.delayTime_param), spawn_action))

    if item.btn.spine then
        item.btn.spine:setPosition(old_x, old_y + self.hero_param)
        item.btn.spine:setOpacity(0)
        item.btn.spine:setScale(3)
        local moveto = cc.MoveTo:create(0.65,cc.p(x, y + self.hero_param))
        local fadeIn = cc.FadeIn:create(0.65)
        local scale = cc.ScaleTo:create(0.65, 1)
        local spawn_action = cc.Spawn:create(moveto, scale, fadeIn)
        item.btn.spine:runAction(cc.Sequence:create(cc.DelayTime:create(self.delayTime_param), spawn_action))
    end
end



function HeroResonateWindow:close_callback()
    if self.change_effect then
        self.change_effect:clearTracks()
        self.change_effect:removeFromParent()
        self.change_effect = nil
    end

    if self.view_list then
        for i,v in pairs(self.view_list) do 
            if v and v["DeleteMe"] then
                v:DeleteMe()
            end
        end
    end
    self.view_list = nil

    if self.item_lay_list then
        for i,v in ipairs(self.item_lay_list) do
            if v.add_spine then
                v.add_spine:clearTracks()
                v.add_spine:removeFromParent()
                v.add_spine = nil
            end
            if v.btn and v.btn.spine then
                v.btn.spine:removeFromParent()
                v.btn.spine = nil
            end
        end
    end


    if self.item_load_bg then
        self.item_load_bg:DeleteMe()
    end
    self.item_load_bg = nil

    if self.role_vo then
        if self.role_lev_event then
            self.role_vo:UnBind(self.role_lev_event)
            self.role_lev_event = nil
        end
    end

    controller:openHeroResonateWindow(false)
end
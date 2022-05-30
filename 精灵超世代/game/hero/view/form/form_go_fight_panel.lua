-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @description:
--      通用战前布阵 
-- <br/>Create: 2018年12月3日
--
-- --------------------------------------------------------------------
FormGoFightPanel = FormGoFightPanel or BaseClass(BaseView)

local controller = HeroController:getInstance()
local elfin_controller = ElfinController:getInstance()
local model = controller:getModel()

local expedit_model = HeroExpeditController:getInstance():getModel()
local string_format = string.format
local table_sort = table.sort
local table_insert = table.insert
local table_remove = table.remove

function FormGoFightPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.is_full_screen = false
    self.win_type = WinType.Big
    self.layout_name = "hero/form_go_fight_panel"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("hero", "hero"), type = ResourcesType.plist},
        -- { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_56"), type = ResourcesType.single }
    }

    --位置名字
    self.pos_name_list = {}
    --宝可梦对象
    self.hero_item_list = {}
    --宝可梦对象位置的矩形区域
    self.pos_rect_list = {}

    --四个空白图片
    self.four_blank_img = {}
    --编队5个宝可梦数据
    -- self.five_hero_vo = {}
    self.cur_power = 0 
    self.cell_width = 88
    --9个位置
    self.nine_position = {
        [1] = cc.p(self.cell_width, -self.cell_width),
        [2] = cc.p(self.cell_width, 0),
        [3] = cc.p(self.cell_width, self.cell_width),
        [4] = cc.p(0, -self.cell_width),
        [5] = cc.p(0, 0),
        [6] = cc.p(0, self.cell_width),
        [7] = cc.p(-self.cell_width, -self.cell_width),
        [8] = cc.p(-self.cell_width, 0),
        [9] = cc.p(-self.cell_width, self.cell_width),
    }
--[[阵型位置
9   6   3
8   5   2
7   4   1
]]
    --移动的hero_item对象
    self.move_hero_item = nil


    --当前选择的队伍索引
    self.select_team_index = 0
    --编队5个宝可梦数据 self.five_hero_vo[self.select_team_index][n] = hero
    self.five_hero_vo = {}
    --队伍信息 self.team_data_list[self.select_team_index] = data data结构参考11211协议结构
    self.team_data_list = {}

    --精灵对应的队伍信息
    self.elfin_team_data_list = {}

    --formations 是 25605 协议下 formations 的结构体.
    --用于剧情保存阵容下 多队伍的数据 self.dic_more_team_data[PartnerConst.Fun_Form.Drama] = formations (目前用到的是 跨服竞技场,巅峰冠军赛)
    self.dic_more_team_data = {}
    -- 精灵
    self.elfin_item_list = {}
end

function FormGoFightPanel:open_callback()
     self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1) 
    self.title = self.main_container:getChildByName("win_title")
    self.title:setString(TI18N("宝可梦出战"))

    self.txt_cn_common_notice_1 = self.main_container:getChildByName("txt_cn_common_notice_1")

    -- self.main_container:getChildByName("exit_tips_label"):setString(TI18N("点击空白区域关闭窗口"))
    
    --阵营
    local camp_node = self.main_container:getChildByName("camp_node")
    self.camp_btn_list = {}
    self.camp_btn_list[0] = camp_node:getChildByName("camp_btn0")
    self.camp_btn_list[HeroConst.CampType.eWater] = camp_node:getChildByName("camp_btn1")
    self.camp_btn_list[HeroConst.CampType.eFire]  = camp_node:getChildByName("camp_btn2")
    self.camp_btn_list[HeroConst.CampType.eWind]  = camp_node:getChildByName("camp_btn3")
    self.camp_btn_list[HeroConst.CampType.eLight] = camp_node:getChildByName("camp_btn4")
    self.camp_btn_list[HeroConst.CampType.eDark]  = camp_node:getChildByName("camp_btn5")
    self.img_select = camp_node:getChildByName("img_select")
    local x, y = self.camp_btn_list[0]:getPosition()
    self.img_select:setPosition(x - 0.5, y + 1)

    self.form_panel = self.main_container:getChildByName("form_panel")
    self.form_list_panel = self.main_container:getChildByName("form_list_panel")

    --宝可梦列表
    self.lay_scrollview = self.main_container:getChildByName("lay_scrollview")
    self.no_vedio_image = self.main_container:getChildByName("no_vedio_image")
    self.no_vedio_label = self.main_container:getChildByName("no_vedio_label")
    self.no_vedio_label:setString(TI18N("暂无该类型宝可梦"))

    --下面5个宝可梦
    self.fight_hero_node = self.form_panel:getChildByName("fight_hero_node")
    local pos = {2,4,6,7,9}--一开始默认 第一个阵法位置
    for index=1,5 do
        local item = HeroExhibitionItem.new(0.75, false)
        item:setPosition(self.nine_position[pos[index]])
        self.fight_hero_node:addChild(item)
        self.hero_item_list[index] = item
    end
    for i=1,4 do
        self.four_blank_img[i] = self.fight_hero_node:getChildByName("hero_info_21_"..i) 
    end

    self.fight_hero_node:getChildByName("pos_label_1"):setString(TI18N("前"))
    self.fight_hero_node:getChildByName("pos_label_2"):setString(TI18N("中"))
    self.fight_hero_node:getChildByName("pos_label_3"):setString(TI18N("后"))

    self.pos_tips = self.fight_hero_node:getChildByName("pos_tips")
    self.pos_tips:setString(TI18N("从列表选择宝可梦，长按宝可梦可查看宝可梦详细信息"))

    --穿戴
    self.equip_btn = self.form_panel:getChildByName("equip_btn")

    local size = self.equip_btn:getContentSize()
    self.hallows_item = BackPackItem.new(false, false, false, 0.8)
    self.hallows_item:showAddIcon(true)
    self.hallows_item:setPosition(cc.p(size.width * 0.5, size.height * 0.5))
    self.equip_btn:addChild(self.hallows_item)

    self.equip_btn_label = self.equip_btn:getChildByName("label")
    self.equip_btn_label:setString(TI18N("点击装配"))
    -- 精灵
    self.elfin_btn = self.form_panel:getChildByName("elfin_btn")
    if self.elfin_btn then
        self.elfin_btn:getChildByName("label"):setString(TI18N("点击调整"))
        if ElfinController:getInstance():getModel():checkElfinIsOpen(true) then
            self.elfin_btn:setVisible(true)
        else
            self.elfin_btn:setVisible(false)
        end
    end
    --阵法
    self.form_change_btn = self.form_panel:getChildByName("form_change_btn")
    -- self.form_change_btn:getChildByName("label"):setString(TI18N("更换"))
    --出战
    self.fight_btn = self.form_panel:getChildByName("fight_btn")
    self.fight_btn:getChildByName("label"):setString(TI18N("开 战"))
    --保存布阵
    self.save_btn = self.form_panel:getChildByName("save_btn")
    self.save_btn:getChildByName("label"):setString(TI18N("保存布阵"))
    --一键上阵
    self.key_up_btn = self.form_panel:getChildByName("key_up_btn")
    self.key_up_btn:getChildByName("label"):setString(TI18N("一键上阵"))
     --阵法icon
    self.form_icon = self.form_change_btn:getChildByName("form_icon")

    --光环icon
    self.halo_btn = self.form_panel:getChildByName("halo_btn")
    self.halo_label = self.halo_btn:getChildByName("label")

    self.power_click = self.form_panel:getChildByName("power_click")
    local size = self.power_click:getContentSize()
    self.fight_label = CommonNum.new(20, self.power_click, 99999, - 2, cc.p(0.5, 0.5))
    self.fight_label:setPosition(size.width/2, size.height/2 + 12)

    self.close_btn = self.main_container:getChildByName("close_btn")

    if model.is_redpoint_form and self.form_change_btn then
        addRedPointToNodeByStatus(self.form_change_btn, true, 5, 5)
    end  
    if model.is_redpoint_hallows and self.equip_btn then
        addRedPointToNodeByStatus(self.equip_btn, true, 5, 5)
    end

    self.tab_btn = self.main_container:getChildByName("tab_btn")

    self.txt_cn_common_notice_1 = self.main_container:getChildByName("txt_cn_common_notice_1")

    self.team_tab_btn = self.main_container:getChildByName("team_tab_btn")
    local tab_name_list = {
        [1] = TI18N("总览"),
        [2] = TI18N("队伍一"),
        [3] = TI18N("队伍二"),
        [4] = TI18N("队伍三"),
    }
    self.team_tab_list = {}
    for i=1,4 do
        local tab_btn = self.team_tab_btn:getChildByName("tab_btn_"..i)
        if tab_btn then
            local object = {}
            object.select_img = tab_btn:getChildByName('select_img')
            object.select_img:setVisible(false)
            object.normal_img = tab_btn:getChildByName('normal_img')
            object.label = tab_btn:getChildByName("label")
            object.label:setTextColor(Config.ColorData.data_new_color4[6])
            if tab_name_list[i] then
                object.label:setString(tab_name_list[i])
            end
            object.tab_btn = tab_btn
            object.index = i
            self.team_tab_list[i] = object
        end
    end

    self.checkbox = self.form_panel:getChildByName("checkbox")
    if self.checkbox then --途中添加的为了避免出错 加判断
        self.checkbox:getChildByName("name"):setString(TI18N("跳过战斗"))
        self.checkbox:setVisible(false)
    end
end

function FormGoFightPanel:register_event()
    delayRun(self.background, 1, function ()
        registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn) ,false, 1)
    end)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn) ,true, 1)

    registerButtonEventListener(self.form_change_btn, handler(self, self.onClickFormChangeBtn) ,true, 2)
    registerButtonEventListener(self.halo_btn, handler(self, self.onClickHaloBtn) ,true, 2)
    registerButtonEventListener(self.fight_btn, handler(self, self.onClickFightBtn) ,true, 2)
    registerButtonEventListener(self.equip_btn, handler(self, self.onClickEquipBtn) ,true, 2)
    registerButtonEventListener(self.elfin_btn, handler(self, self.onClickElfinBtn), true)

    registerButtonEventListener(self.key_up_btn, handler(self, self.onClickKeyUpBtn) ,true, 2)
    registerButtonEventListener(self.save_btn, handler(self, self.onClickSaveBtn) ,true, 2)

     registerButtonEventListener(self.checkbox, function()
        local is_select = self.checkbox:isSelected()
        self.is_skip_fight = is_select
    end, true, 1) 

    if self.team_tab_list then
        for i,v in ipairs(self.team_tab_list) do
            registerButtonEventListener(v.tab_btn, function() self:onClickTeamTabBtn(v.index, true) end ,false, 2)
        end
    end

    --阵营按钮
    for select_camp, v in pairs(self.camp_btn_list) do
        registerButtonEventListener(v, function() self:onClickBtnShowByIndex(select_camp) end ,true, 2)
    end
    self.long_touch_type = LONG_TOUCH_INIT_TYPE
    for i,item in ipairs(self.hero_item_list) do
        item:addTouchEventListener(function(sender, event_type)
            --播放动作中 和 数据为空
            if self.is_play_item_action then return end
            if self.five_hero_vo[self.select_team_index] and self.five_hero_vo[self.select_team_index][i] == nil then return end
            if event_type == ccui.TouchEventType.began then
                self.touch_began = sender:getTouchBeganPosition()
                doStopAllActions(self.form_panel)
                self.long_touch_type = LONG_TOUCH_BEGAN_TYPE
                delayRun(self.form_panel, 0.6, function ()
                    if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
                        local hero_vo = self.five_hero_vo[self.select_team_index][i]
                        if hero_vo then
                            if self.fun_form_type == PartnerConst.Fun_Form.Planes and hero_vo.flag == 1 then
                                --雇佣兵
                                PlanesafkController:getInstance():sender28623(hero_vo.partner_id)
                            elseif (self.fun_form_type == PartnerConst.Fun_Form.EndLess or self.fun_form_type == PartnerConst.Fun_Form.EndLessWater or 
                            self.fun_form_type == PartnerConst.Fun_Form.EndLessFire or self.fun_form_type == PartnerConst.Fun_Form.EndLessWind or 
                            self.fun_form_type == PartnerConst.Fun_Form.EndLessLightDark) and hero_vo.is_endless then
                                LookController:getInstance():sender11061(hero_vo.rid, hero_vo.srv_id, hero_vo.id)
                            else
                                HeroController:getInstance():openHeroTipsPanel(true, self.five_hero_vo[self.select_team_index][i])
                            end
                        end
                    end
                    self.long_touch_type = LONG_TOUCH_END_TYPE
                end)
                
            elseif event_type == ccui.TouchEventType.moved then
                if self.long_touch_type == LONG_TOUCH_END_TYPE then
                    --事件触发了就不处理移动事件了
                    return 
                elseif self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
                    local touch_began = self.touch_began
                    local touch_end = sender:getTouchMovePosition()
                    if touch_began and touch_end and (math.abs(touch_end.x - touch_began.x) > 20 or math.abs(touch_end.y - touch_began.y) > 20) then 
                        --移动大于20了..表示取消长点击效果
                        doStopAllActions(self.form_panel)
                        self.long_touch_type = LONG_TOUCH_CANCEL_TYPE
                    end 
                end
                self:onClickHeroItemMove(i, sender)
            elseif event_type == ccui.TouchEventType.canceled then
                if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
                    doStopAllActions(self.form_panel)
                    self.long_touch_type = LONG_TOUCH_CANCEL_TYPE
                elseif self.long_touch_type == LONG_TOUCH_END_TYPE then
                    --事件触发了就不处理点击事件了
                    if self.move_hero_item then
                        self.move_hero_item:setPosition(-10000, 0)
                    end
                    item:setData(self.five_hero_vo[self.select_team_index][i])
                    return
                end

                self:onClickHeroItemCanceled(i, sender)
            elseif event_type == ccui.TouchEventType.ended then
                if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
                    doStopAllActions(self.form_panel)
                    self.long_touch_type = LONG_TOUCH_CANCEL_TYPE
                elseif self.long_touch_type == LONG_TOUCH_END_TYPE then
                    --事件触发了就不处理点击事件了
                    if self.move_hero_item then
                        self.move_hero_item:setPosition(-10000, 0)
                    end
                    item:setData(self.five_hero_vo[self.select_team_index][i])
                    return
                end

                self:onClickHeroItemEnd(i, sender)
            end
        end)
    end

    --精英赛的布阵信息返回
    self:addGlobalEvent(ElitematchEvent.Update_Elite_Fun_Form, function(data)
        if not data then return end
        if self.fun_form_type == PartnerConst.Fun_Form.Drama then
            --说明是在剧情布阵的
            for i,v in ipairs(self.tab_list) do
                if v.fun_form_type == PartnerConst.Fun_Form.EliteMatch then
                    if #data.formations > 0 then
                        self.team_data_list[i] = data.formations[1]
                        if self.select_team_index == i then
                            self:initFormInfo(self.team_data_list[i])
                        end
                    end
                end
            end
        else
            --常规赛
            if #data.formations > 0 then
                self.team_data_list = data.formations
                if self.team_data_list[self.select_team_index] then
                    table_sort(self.team_data_list[self.select_team_index], function(a, b) return a.order < b.order end)
                end
                self:setHeroIsSelect()
                self:initFormInfo(self.team_data_list[self.select_team_index])
            end
            self:setEliteMatchDefaultInfo(2)    
        end
    end)

    --精英赛的布阵信息
    self:addGlobalEvent(ElitematchEvent.Update_Elite_Save_Form, function(data)
        message(TI18N("保存布阵成功"))
        if self.fun_form_type == PartnerConst.Fun_Form.Drama then
            --说明是在剧情布阵的 不用关闭
            --默认 常规赛的 如有王者赛需要该表支持
            local match_type = match_type or ElitematchConst.MatchType.eNormalMatch
            ElitematchController:getInstance():sender24920(match_type)
        else
            self:onClickCloseBtn()    
        end
    end)

    -- 天界副本布阵信息
    self:addGlobalEvent(HeavenEvent.Update_Heaven_Fun_Form, function ( data )
        if #data.formations > 0 then
            self.team_data_list = data.formations
            table_sort(self.team_data_list[self.select_team_index], function(a, b) return a.order < b.order end)
            self:initFormInfo(self.team_data_list[self.select_team_index])
        end
        self:setEliteMatchDefaultInfo(2)
    end)

    -- 跨服竞技场
    self:addGlobalEvent(CrossarenaEvent.Update_Form_Data_Event, function ( data )
        if self.fun_form_type == PartnerConst.Fun_Form.Drama then
            if self.cur_tab_data and self.cur_tab_data.fun_form_type == PartnerConst.Fun_Form.CrossArenaDef then
                local formations = self:setTeamMactchDefaultInfo(3, data.formations, PartnerConst.Fun_Form.CrossArenaDef)
                self.dic_more_team_data[PartnerConst.Fun_Form.CrossArenaDef] = formations
                self:onClickTeamTabBtn(1)
            else
                for i,v in ipairs(self.tab_list) do
                    if v.fun_form_type == PartnerConst.Fun_Form.CrossArenaDef then
                        local formations = self:setTeamMactchDefaultInfo(3, data.formations, PartnerConst.Fun_Form.CrossArenaDef)
                        self.dic_more_team_data[PartnerConst.Fun_Form.CrossArenaDef] = formations
                        break
                    end
                end
            end
        else
            if self.fun_form_type ~= PartnerConst.Fun_Form.CrossArenaDef and self.fun_form_type ~= PartnerConst.Fun_Form.CrossArena then return end
            self.team_data_list = data.formations or {}
            table_insert(self.team_data_list, 1, {})
            self:initCrossarenaFormInfo()
            self:setEliteMatchDefaultInfo(3)
        end
    end)

    -- 巅峰竞技场 请求布阵
    self:addGlobalEvent(ArenapeakchampionEvent.ARENAPEAKCHAMPION_FROM_EVENT, function ( data )
        if self.fun_form_type == PartnerConst.Fun_Form.Drama then
            if self.cur_tab_data and self.cur_tab_data.fun_form_type == PartnerConst.Fun_Form.ArenapeakchampionDef then
                local formations = self:setTeamMactchDefaultInfo(3, data.formations, PartnerConst.Fun_Form.ArenapeakchampionDef)
                self.dic_more_team_data[PartnerConst.Fun_Form.ArenapeakchampionDef] = formations
                self:onClickTeamTabBtn(1)
            else
                for i,v in ipairs(self.tab_list) do
                    if v.fun_form_type == PartnerConst.Fun_Form.ArenapeakchampionDef then
                        local formations = self:setTeamMactchDefaultInfo(3, data.formations, PartnerConst.Fun_Form.ArenapeakchampionDef)
                        self.dic_more_team_data[PartnerConst.Fun_Form.ArenapeakchampionDef] = formations
                        break
                    end
                end
            end
        else
            if self.fun_form_type ~= PartnerConst.Fun_Form.ArenapeakchampionDef then return end
            self.team_data_list = data.formations or {}
            table_insert(self.team_data_list, 1, {})
            self:initCrossarenaFormInfo()
            self:setEliteMatchDefaultInfo(3)
        end
    end)
    -- 巅峰竞技场 保存布阵成功
    self:addGlobalEvent(ArenapeakchampionEvent.ARENAPEAKCHAMPION_SAVE_FROM_EVENT, function ( data )
        message(TI18N("保存布阵成功"))
        --在剧情阵容里面 不用关闭
        if self.fun_form_type ~= PartnerConst.Fun_Form.Drama then
            self:onClickCloseBtn()
        end
    end)

    -- 位面布阵数据
    self:addGlobalEvent(PlanesafkEvent.Get_Form_Data_Event, function ( data )
        self.team_data_list[self.select_team_index] = data
        self:initFormInfo(data)
    end)
    self:addGlobalEvent(PlanesafkEvent.Save_Form_Success_Event, function (  )
        message(TI18N("保存布阵成功"))
        self:onClickCloseBtn()
    end)

    --布阵信息返回
    self:addGlobalEvent(HeroEvent.Update_Fun_Form, function(data)
        if not data then return end
        if self.fun_form_type == PartnerConst.Fun_Form.Drama then
            --说明是在剧情布阵的 
            for i,v in ipairs(self.tab_list) do
                if data.type and v.fun_form_type == data.type then
                    self.team_data_list[i] = data 
                    if self.select_team_index == i then
                        self:initFormInfo(self.team_data_list[i])
                    end
                end
            end
        else 
            if self.fun_form_type and data.type and data.type == self.fun_form_type then
                self.team_data_list[self.select_team_index] = data
                self:initFormInfo(data)
            end
        end
    end)

    --发送出战协议
    self:addGlobalEvent(HeroEvent.Update_Save_Form, function(data)
        if self.form_show_type == HeroConst.FormShowType.eFormFight then --出战
            self:gotoFight() 
        else
            message(TI18N("保存布阵成功"))
            if self.fun_form_type == PartnerConst.Fun_Form.Drama then
                if data.type ~= PartnerConst.Fun_Form.Drama and data.type ~= PartnerConst.Fun_Form.Arena then
                    controller:sender11211(data.type)
                end
            else
                --其他的布阵都关闭
                self:onClickCloseBtn()
            end
        end
    end)

    -- 天界副本出战协议
    self:addGlobalEvent(HeavenEvent.Save_Heaven_Fun_Form, function (  )
        local chapter_id = self.setting.chapter_id
        local customs_id = self.setting.customs_id
        if self.form_show_type == HeroConst.FormShowType.eFormFight and chapter_id and customs_id then
            HeavenController:getInstance():sender25205(chapter_id, customs_id)
            self:onClickCloseBtn()
        end
    end)

    -- 跨服竞技场出战协议
    self:addGlobalEvent(CrossarenaEvent.Save_Crossarena_Form_Event, function (  )
        local rid = self.setting.rid
        local srv_id = self.setting.srv_id
        if self.form_show_type == HeroConst.FormShowType.eFormFight and rid and srv_id then
            CrossarenaController:getInstance():sender25606(rid, srv_id)
            CrossarenaController:getInstance():openCrossarenaRoleTips(false)
        end
        --在剧情阵容里面 不用关闭
        if self.fun_form_type ~= PartnerConst.Fun_Form.Drama then
            self:onClickCloseBtn()
        end
    end)
    -- 保存秘矿冒险布阵队伍
    self:addGlobalEvent(AdventureEvent.ADVENTURE_MINE_SAVE_FORM_EVENT, function (  )
        GlobalEvent:getInstance():Fire(AdventureEvent.ADVENTURE_MINE_SAVE_BACK_EVENT, self.mine_pos_info, self.formation_type, self.hallows_id)
        if self.fun_form_type and self.fun_form_type == PartnerConst.Fun_Form.Adventure_Mine_Def then
            self:onClickCloseBtn()
        end
    end)

    -- 进入战斗关闭当前
    self:addGlobalEvent(AdventureEvent.ADVENTURE_MINE_FIGHT_EVENT, function (  )
        self:onClickCloseBtn()
    end)

    -- 秘矿冒险的圣器列表
    self:addGlobalEvent(AdventureEvent.ADVENTURE_MINE_HALLOWS_LIST_EVENT, function (data)
        self.mine_hallows_id = {}
        if not data then return end

        for i,v in ipairs(data.list) do
            self.mine_hallows_id[v.hallows_id] = v
        end
        -- 没有的话 给一个默认的
        if self.hallows_id and self.hallows_id == 0 then
            local hallows_model = HallowsController:getInstance():getModel()
            local hallow_list = hallows_model:getHallowsList() or {}
            if hallows_model and hallow_list and next(hallow_list) ~= nil then
                local list = {}
                for i,v in ipairs(hallow_list) do
                    if not self.mine_hallows_id[v.id] then
                        table_insert(list, v)
                    end
                end
                if #list > 0 then
                    table_sort(list, function(objA, objB) return hallows_model:sortHallowsFunc(objA, objB) end)
                    self.hallows_id = list[1].id
                    self:updateHallowsIcon()
                end 
            end
        end
    end)
    
    self:addGlobalEvent(HeroEvent.Del_Hero_Event, function(list)
        self:updateHeroList(self.select_camp, true)
        self:updateFiveHeroItem()
    end)

    self:addGlobalEvent(ElfinEvent.Get_Elfin_Tree_Data_Event, function (  )
        if self.save_elfin_data then
            self:updateElfinList(self.save_elfin_data)
        end
    end)

    --阵法类型对应精灵数据
    self:addGlobalEvent(ElfinEvent.Elfin_Plan_From_Info_Event, function (data)
        self:initEflinInfoList(data)
    end)
end

function FormGoFightPanel:onClickCloseBtn(force)
    if not force and self.fun_form_type and self.fun_form_type == PartnerConst.Fun_Form.Monopoly_Evt then
        -- 大富翁事件的布阵界面不能关闭
        return
    elseif self.fun_form_type and self.fun_form_type == PartnerConst.Fun_Form.Adventure_Mine_Def then
        controller:openAdventureMineFormGoFightPanel(false)
        if self.setting and self.setting.end_time then
            local time = self.setting.end_time - GameNet:getInstance():getTime()
            if time > 0 then
                local adventure_controller = AdventureController:getInstance()
                if adventure_controller and adventure_controller.send20660 then
                --bugly报错(send20660 is a nil value). 兼容一下
                    adventure_controller:send20660(self.setting.floor, self.setting.room_id)
                end
            end
        end
    else
        controller:openFormGoFightPanel(false)
    end
end

--更换阵法
function FormGoFightPanel:onClickFormChangeBtn()
    if not self.formation_type then return end

    if model.is_redpoint_form and self.form_change_btn then
        model.is_redpoint_form = false
        addRedPointToNodeByStatus(self.form_change_btn, false, 5, 5)
    end  

    controller:openFormationSelectPanel(true, self.formation_type, function(formation_type, team_index)
        if formation_type and not tolua.isnull(self.root_wnd) then
            if not team_index then return end
            if not self.team_data_list[team_index] then return end
            
            self.formation_type = formation_type
            self.team_data_list[team_index].formation_type = formation_type
            if self.select_team_index == team_index then
                local formation_config = Config.FormationData.data_form_data[self.formation_type]
                if formation_config then
                    self:initFormationData(formation_config)
                end
                self:updateFormationIcon()
            end
        end
    end, self.select_team_index)
end

--光环
function FormGoFightPanel:onClickHaloBtn()
    BattleController:getInstance():openBattleCampView(true, self.halo_form_id_list)
end

--穿戴神器
function FormGoFightPanel:onClickEquipBtn()
    if not self.hallows_id then return end

    if self.fun_form_type == PartnerConst.Fun_Form.Adventure_Mine_Def then
        if not self.mine_hallows_id then return end
    end
    
    if model.is_redpoint_hallows and self.equip_btn then
        model.is_redpoint_hallows = false
        addRedPointToNodeByStatus(self.equip_btn, false, 5, 5)
    end

    local tab_data = self.tab_list[self.select_team_index]
    local dic_team_data, more_team_data = self:getDicTeamData(tab_data)

    local dic_equips = {}
    if more_team_data then
        for i,v in ipairs(more_team_data) do
            if v.hallows_id and v.hallows_id ~= 0 and (self.team_select_team_index - 1) ~= i then
                dic_equips[v.hallows_id] = i 
            end
        end
    else
        for i,v in pairs(dic_team_data) do
            if v.hallows_id and v.hallows_id ~= 0 and self.select_team_index ~= i then
                if self.fun_form_type == PartnerConst.Fun_Form.CrossArena or 
                    self.fun_form_type == PartnerConst.Fun_Form.CrossArenaDef or
                    self.fun_form_type == PartnerConst.Fun_Form.ArenapeakchampionDef then
                    dic_equips[v.hallows_id] = i - 1 -- 跨服竞技场要减去1（有总览）巅峰竞技场
                else
                    dic_equips[v.hallows_id] = i
                end
            end
        end
    end
    --去重
    if self.mine_hallows_id then
        for id,v in pairs(self.mine_hallows_id) do
            if id == self.hallows_id then
                self.mine_hallows_id[id] = nil
            end
        end
    end

    controller:openFormHallowsSelectPanel(true, self.hallows_id, function(hallows_id, team_index)
        if hallows_id then
            if not self.team_data_list or not self.team_data_list[team_index] then return end
            self.hallows_id = hallows_id
            if more_team_data then
                    local index = dic_equips[hallows_id]
                if hallows_id ~= 0 then
                    for i,v in ipairs(more_team_data) do
                        if v.hallows_id == hallows_id and index == i then
                            v.hallows_id = 0
                        end
                    end
                end
            else
                for i,team_data in pairs(dic_team_data) do
                    if team_data.hallows_id == hallows_id and team_index ~= i then
                        --说明替换了
                        team_data.hallows_id = 0
                    end
                end
            end
            self.team_data_list[team_index].hallows_id = hallows_id
            if self.fun_form_type ~= PartnerConst.Fun_Form.Drama and self.crossarena_form_list_panel then
                self.crossarena_form_list_panel:setData(self.team_data_list)
            end
            if self.select_team_index == team_index then
                self:updateHallowsIcon()
            end
        end
    end, dic_equips, self.select_team_index, self.mine_hallows_id)
end

-- 调整精灵
function FormGoFightPanel:onClickElfinBtn(  )
    if not self.elfin_team_data_list[self.select_team_index] then return end
    if not self.cur_tab_data then return end
    local elfin_tree_data = elfin_controller:getModel():getElfinTreeData()
    --古树信息没有回来不给点
    if next(elfin_tree_data) == nil then return end

    local setting = {}
    setting.fun_form_type = self.cur_tab_data.fun_form_type
    -- if self.fun_form_type == PartnerConst.Fun_Form.EliteMatch then
    --     local match_type = self.setting.match_type or ElitematchConst.MatchType.eNormalMatch
    --     if match_type == 2 then--王者赛
    --         setting.fun_form_type = PartnerConst.Fun_Form.EliteKingMatch
    --     end
    -- end
    self:setPlanSettingInfo(setting)
    ElfinController:getInstance():openElfinFightPlanPanel(true, setting)
    -- ElfinController:getInstance():openElfinAdjustWindow(true)
end

function FormGoFightPanel:setPlanSettingInfo(setting)
    if not setting then return end
    --team_list结构参考 26555协议team_list
    local _teamFilterInfo = function(team_list, filter_index)
        local dic_item_id = {}
        for _,v in pairs(team_list) do
            if filter_index ~= v.team then
                if v.sprites and next(v.sprites) ~= nil then
                    for __,sp in ipairs(v.sprites) do
                        if dic_item_id[sp.item_bid] == nil then
                            dic_item_id[sp.item_bid] = 1
                        else
                            dic_item_id[sp.item_bid] = dic_item_id[sp.item_bid] + 1
                        end
                    end
                end
            end
        end
        return dic_item_id
    end

    if self.fun_form_type == PartnerConst.Fun_Form.Drama then
        if self.cur_tab_data.fun_form_type == PartnerConst.Fun_Form.CrossArenaDef or 
            self.cur_tab_data.fun_form_type == PartnerConst.Fun_Form.ArenapeakchampionDef then
            -- setting.team_index = self.team_select_team_index - 1

            setting.team_index  = self.team_data_list[self.select_team_index].old_order
            if setting.team_index == nil then
                setting.team_index = self.team_select_team_index - 1
            end
            setting.dic_filter_item_id = _teamFilterInfo(self.elfin_team_data_list[self.select_team_index], setting.team_index)
            setting.cur_plan_data = self.elfin_team_data_list[self.select_team_index][setting.team_index + 1]
            setting.total_team_info = self.elfin_team_data_list[self.select_team_index]
        else
            setting.dic_filter_item_id = {}
            setting.cur_plan_data = self.elfin_team_data_list[self.select_team_index]
            setting.team_index = 1
        end
    else
        if self.fun_form_type == PartnerConst.Fun_Form.CrossArenaDef or 
            self.fun_form_type == PartnerConst.Fun_Form.CrossArena or
            self.fun_form_type == PartnerConst.Fun_Form.ArenapeakchampionDef then
            --多队伍 有总览的 需要跳过总览
            setting.team_index  = self.team_data_list[self.select_team_index].old_order
            if setting.team_index == nil then
                setting.team_index = self.select_team_index - 1
            end
            -- setting.team_index = self.select_team_index - 1
            setting.dic_filter_item_id = _teamFilterInfo(self.elfin_team_data_list, setting.team_index)
            setting.cur_plan_data = self.elfin_team_data_list[setting.team_index + 1]
            setting.total_team_info = self.elfin_team_data_list
        elseif self.fun_form_type == PartnerConst.Fun_Form.HeavenBoss then
            --多队伍没有总览的
            setting.team_index = self.select_team_index
            setting.dic_filter_item_id = _teamFilterInfo(self.elfin_team_data_list, setting.team_index)
            setting.cur_plan_data = self.elfin_team_data_list[self.select_team_index]
            setting.total_team_info = self.elfin_team_data_list
        elseif self.fun_form_type == PartnerConst.Fun_Form.EliteMatch then --段位赛
            local match_type = self.setting.match_type or ElitematchConst.MatchType.eNormalMatch
            if match_type == 1 then--段位赛的
                setting.dic_filter_item_id = {}
                setting.cur_plan_data = self.elfin_team_data_list[self.select_team_index]
                setting.team_index = 1
            else--王者赛的
                setting.team_index = self.select_team_index
                setting.dic_filter_item_id = _teamFilterInfo(self.elfin_team_data_list, setting.team_index)
                setting.cur_plan_data = self.elfin_team_data_list[self.select_team_index]
                setting.total_team_info = self.elfin_team_data_list
            end
            setting.match_type = match_type
        else
            setting.dic_filter_item_id = {}
            setting.cur_plan_data = self.elfin_team_data_list[self.select_team_index]
            setting.team_index = 1
        end
    end
end
function FormGoFightPanel:getDefaultTeamInfo(team_index)
    if self.default_team_info == nil then
        self.default_team_info = {}
    end
    if self.default_team_info[team_index] == nil then
        self.default_team_info[team_index] = {}
        self.default_team_info[team_index].sprites = {}
        for i=1,4 do
            local item_bid = ElfinController:getInstance():getModel():getElfinItemByPos(i)
            if item_bid ~= nil then
                table_insert(self.default_team_info[team_index].sprites, {pos = i, item_bid = 0})
            end
        end
        self.default_team_info[team_index].plan_id = 0
        self.default_team_info[team_index].team = team_index
    end
    return self.default_team_info[team_index]
end

function FormGoFightPanel:initEflinInfoList(data)
    if not self.tab_list then return end
    if self.fun_form_type == PartnerConst.Fun_Form.Drama then
        for i,v in ipairs(self.tab_list) do
            if v.fun_form_type == data.type then
                if v.fun_form_type == PartnerConst.Fun_Form.CrossArenaDef or  -- 跨服竞技场
                    v.fun_form_type == PartnerConst.Fun_Form.ArenapeakchampionDef then --巅峰冠军赛
                    self.elfin_team_data_list[v.index] = {} 
                    local old_order 
                    if self.team_data_list[self.select_team_index] then
                        old_order = self.team_data_list[self.select_team_index].old_order
                    end
                    local index_temp = self.team_select_team_index or 1
                    local cur_index = old_order or (index_temp - 1)

                    for i,team_data in ipairs(data.team_list) do
                        self.elfin_team_data_list[v.index][team_data.team + 1] = team_data
                        if cur_index == team_data.team then
                            self:updateElfinList(team_data) 
                        end
                    end
                    for i=2,4 do
                        if self.elfin_team_data_list[v.index][i] == nil then
                            self.elfin_team_data_list[v.index][i] = self:getDefaultTeamInfo(i - 1)
                        end
                    end
                else
                    self.elfin_team_data_list[v.index] = data.team_list[1]
                    if self.select_team_index == v.index then
                        self:updateElfinList(self.elfin_team_data_list[v.index]) 
                    end
                end
                break
            end
        end
    else
        if self.fun_form_type == data.type then

            local cur_index = self.select_team_index
            if self.fun_form_type == PartnerConst.Fun_Form.CrossArenaDef or 
                self.fun_form_type == PartnerConst.Fun_Form.CrossArena or
                self.fun_form_type == PartnerConst.Fun_Form.ArenapeakchampionDef then

                --多队伍 有总览的 需要跳过总览
                local old_order 
                if self.team_data_list[self.select_team_index] then
                    old_order = self.team_data_list[self.select_team_index].old_order
                end
                local temp_index = old_order or (self.select_team_index - 1)

                cur_index = temp_index + 1
                self.elfin_team_data_list = {}
                for i,v in ipairs(data.team_list) do
                    self.elfin_team_data_list[v.team + 1]  = v
                end
                for i=2,4 do
                    if self.elfin_team_data_list[i] == nil then
                        self.elfin_team_data_list[i] = self:getDefaultTeamInfo(i - 1)
                    end
                end
            elseif self.fun_form_type == PartnerConst.Fun_Form.HeavenBoss then --天界副本
                --多队伍没有总览的
                self.elfin_team_data_list = {}
                for i,v in ipairs(data.team_list) do
                    self.elfin_team_data_list[v.team]  = v
                end
                for i=1,2 do
                    if self.elfin_team_data_list[i] == nil then
                        self.elfin_team_data_list[i] = self:getDefaultTeamInfo(i)
                    end
                end
            elseif self.fun_form_type == PartnerConst.Fun_Form.EliteMatch then --段位赛
                local match_type = self.setting.match_type or ElitematchConst.MatchType.eNormalMatch
                if match_type == 1 then--段位赛的
                    self.elfin_team_data_list[1] = data.team_list[1]
                else--王者赛的
                   --在下面特殊处理
                end
            else
                self.elfin_team_data_list[1] = data.team_list[1]
            end
            --设置内容
            for i,v in ipairs(self.tab_list) do
                if v.index == cur_index then
                    self:updateElfinList(self.elfin_team_data_list[cur_index]) 
                end
            end
        elseif data.type == PartnerConst.Fun_Form.EliteKingMatch then --王者赛..比较特殊 = =
            local match_type = self.setting.match_type or ElitematchConst.MatchType.eNormalMatch
            if match_type == 2 then
                self.elfin_team_data_list = {}
                for i,v in ipairs(data.team_list) do
                    self.elfin_team_data_list[v.team]  = v
                end
                for i=1,2 do
                    if self.elfin_team_data_list[i] == nil then
                        self.elfin_team_data_list[i] = self:getDefaultTeamInfo(i)
                    end
                end
                for i,v in ipairs(self.tab_list) do
                    if v.index == self.select_team_index then
                        self:updateElfinList(self.elfin_team_data_list[self.select_team_index]) 
                    end
                end
            end
        end
    end
end

-- 更新精灵
function FormGoFightPanel:updateElfinList(data)
    if not self.elfin_btn then return end
    if not data then return end
    self.save_elfin_data = data --保存一下 用于古树信息返回处理用的..
    -- local elfin_bid_list = ElfinController:getInstance():getModel():getElfinTreeElfinList() or {}
    local elfin_bid_list = data.sprites
    local function getElfinBidByPos( pos )
        local elfin_bid
        for k,v in pairs(elfin_bid_list) do
            if v.pos == pos then
                elfin_bid = v.item_bid
                break
            end
        end
        return elfin_bid
    end

    local btnSize = self.elfin_btn:getContentSize()
    local offset = 38
    local posConf = {
        cc.p(btnSize.width/2 - offset, btnSize.width/2 + offset),
        cc.p(btnSize.width/2 + offset, btnSize.width/2 + offset),
        cc.p(btnSize.width/2 - offset, btnSize.width/2 - offset),
        cc.p(btnSize.width/2 + offset, btnSize.width/2 - offset),
    }
    
    for i=1,4 do
        local elfin_bid = getElfinBidByPos(i)
        local elfin_item = self.elfin_item_list[i]
        if elfin_item == nil then
            elfin_item = SkillItem.new(true, false, true, 0.6)
            local pos = posConf[i]
            elfin_item:setPosition(pos)
            self.elfin_btn:addChild(elfin_item)
            self.elfin_item_list[i] = elfin_item
        end
        local item_bid = ElfinController:getInstance():getModel():getElfinItemByPos(i)
        if item_bid then
            local bid = elfin_bid or 0
            elfin_item:showLockIcon(false)
            local elfin_cfg = Config.SpriteData.data_elfin_data(bid)
            if bid == 0 or not elfin_cfg then -- 已解锁，但未放置精灵
                elfin_item:setData()
            else
                local skill_cfg = Config.SkillData.data_get_skill(elfin_cfg.skill)
                if skill_cfg then
                    elfin_item:setData(skill_cfg)
                end
            end
        else
            elfin_item:setData()
            elfin_item:showLockIcon(true)
        end
    end
end

--一键上阵
function FormGoFightPanel:onClickKeyUpBtn()
    if not self.pos_name_list then return end
    if tolua.isnull(self.root_wnd) then return end
    if not self.five_hero_vo[self.select_team_index] then return end
    if not self.tab_list[self.select_team_index] then return end
    if not self.cur_tab_data then return end
    
    local key_pos_info_list = {}
    local _getPos = function(hero_vo)

        if hero_vo.pos_type == 1 then
            --1的默认是从1 找到3
        elseif hero_vo.pos_type == 3 then
            local lenght = #self.pos_name_list
            --从3往2往1找
            for i=lenght , 1, -1 do
                if key_pos_info_list[i] == nil then
                    return i
                end 
            end
            
        else --中间位置的
            --先找2的
            for i,pos in ipairs(self.pos_name_list) do
                if pos == hero_vo.pos_type then
                    if key_pos_info_list[i] == nil then
                        return i
                    end 
                end
            end
        end
        --上面没有从1 找到3
        for i,v in ipairs(self.pos_name_list) do
            if key_pos_info_list[i] == nil then
                return i
            end 
        end
        return nil
    end
    local hero_array = model:getAllHeroArray()
    hero_array:UpperSortByParams("power", "star", "lev", "sort_order")
    local index = 1
    local size = hero_array:GetSize() 
    if size == 0 then 
        message(TI18N("没有宝可梦"))
        return
    end

    -- --先清空选中
    local dic_bid = {}
    local tab_data = self.tab_list[self.select_team_index]
    local dic_team_data, more_team_data = self:getDicTeamData(tab_data)
    local fun_form_type = nil

    if more_team_data then
        if not self.team_select_team_index then return end
        fun_form_type = self.cur_tab_data.fun_form_type
        local index = self.team_select_team_index - 1
        for k,v in pairs(more_team_data) do
            local pos_info = v.pos_info or {}
            for _,info in pairs(pos_info) do
                local hero_vo = model:getHeroById(info.id)
                if hero_vo then
                    if v.order == index then 
                        hero_vo.is_ui_select = false
                    else
                        dic_bid[hero_vo.bid] = true
                    end
                end
            end
        end
    else
        for i,v in pairs(dic_team_data) do
            if self.five_hero_vo[i] then
                for k,hero_vo in pairs(self.five_hero_vo[i]) do
                    if self.select_team_index == i then
                        hero_vo.is_ui_select = false
                    else
                        dic_bid[hero_vo.bid] = true
                    end
                end
            end
        end
    end
    
    --判断是否重复宝可梦(重复宝可梦不能上阵)
    for i=1,size do 
        local hero_vo = hero_array:Get(i-1)
        if dic_bid[hero_vo.bid] == nil and self:checkOtherCondition(hero_vo, fun_form_type, more_team_data) then
            dic_bid[hero_vo.bid] = true
            local new_index = _getPos(hero_vo)
            if new_index == nil then
                break
            end
            key_pos_info_list[new_index] = hero_vo
            hero_vo.is_ui_select = true

            index = index + 1
            if index > 5 then
                break
            end
        end
    end

    local dic_change = {}

    for index, hero_vo in pairs(key_pos_info_list) do
        dic_change[index] = true
        self.five_hero_vo[self.select_team_index][index] = hero_vo
        if self.hero_item_list[index] then
            self.hero_item_list[index]:setData(self.five_hero_vo[self.select_team_index][index])
        end
    end
    for index, hero_vo in pairs(self.five_hero_vo[self.select_team_index]) do
        if dic_change[index] == nil then
            --说明一键上阵有空位置..空位置上面有旧的站位信息
            if self.hero_item_list[index] then
                self.hero_item_list[index]:setData(nil)
            end    
            self.five_hero_vo[self.select_team_index][index] = nil
        end
    end
    self:updateMoreTeamHeroInfo()
    self:updateFightPower()
    if self.list_view then
        self.list_view:resetCurrentItems()
    end
end

-- 判断一些特殊的宝可梦上阵条件
function FormGoFightPanel:checkOtherCondition( check_hero_vo , fun_form_type, more_team_data)
    if not self.five_hero_vo then return end

    local fun_form_type = fun_form_type or self.fun_form_type
    if fun_form_type == PartnerConst.Fun_Form.CrossArena or 
        fun_form_type == PartnerConst.Fun_Form.CrossArenaDef or
        fun_form_type == PartnerConst.Fun_Form.ArenapeakchampionDef then
        -- 跨服竞技场，同类宝可梦在所有队伍中不能超过3个
        local have_num = 0
        if more_team_data then
            --剧情上面的多队伍
            for k,v in pairs(more_team_data) do
                local pos_info = v.pos_info or {}
                for _,info in pairs(pos_info) do
                    local hero_vo = model:getHeroById(info.id)
                    if hero_vo then
                        if hero_vo.bid == check_hero_vo.bid then
                            have_num = have_num + 1
                        end
                        if have_num >= 2 then
                            return false
                        end
                    end
                end
            end 
        else
            for i,hero_datas in pairs(self.five_hero_vo) do
                for pos,hero_vo in pairs(hero_datas) do
                    if hero_vo.bid == check_hero_vo.bid then
                        have_num = have_num + 1
                    end
                    if have_num >= 2 then
                        return false
                    end
                end
                if have_num >= 2 then
                    return false
                end
            end
        end
    elseif fun_form_type == PartnerConst.Fun_Form.Adventure_Mine_Def then --秘矿冒险
        if self.dic_mine_hero_list and self.dic_mine_hero_list[check_hero_vo.id] then
            return false
        end
    elseif fun_form_type == PartnerConst.Fun_Form.Planes then --位面
        local con_cfg = Config.PlanesData.data_const["planes_filter_condition"]
        local hp_per = PlanesafkController:getInstance():getModel():getMyPlanesHeroHpPer(check_hero_vo.id)
        if hp_per <= 0 then --血量为0不可上阵
            return false
        elseif con_cfg and con_cfg.val[1] and check_hero_vo.lev < con_cfg.val[1] then -- 等级小于配置等级不可上阵
            return false
        end
    end

    if fun_form_type == PartnerConst.Fun_Form.Drama then
        local tab_data = self.tab_list[self.select_team_index]
        if check_hero_vo.checkResonateHeroByFormType and check_hero_vo:checkResonateHeroByFormType(tab_data.fun_form_type, true) then
            return false
        end
    elseif check_hero_vo.checkResonateHeroByFormType and check_hero_vo:checkResonateHeroByFormType(self.fun_form_type, true) then
        return false 
    end
    return true 
end

--保存布阵
function FormGoFightPanel:onClickSaveBtn()
    if self.fun_form_type == PartnerConst.Fun_Form.EliteMatch then
        --精英赛
        self:onFightEliteMatch()
    elseif self.fun_form_type == PartnerConst.Fun_Form.CrossArena or self.fun_form_type == PartnerConst.Fun_Form.CrossArenaDef then
        -- 跨服竞技场
        self:onFightCrossarena()
    elseif self.fun_form_type == PartnerConst.Fun_Form.ArenapeakchampionDef then
        --巅峰冠军赛
        self:onFightArenapeakchampion()
    elseif self.fun_form_type == PartnerConst.Fun_Form.Adventure_Mine_Def then
        --秘矿冒险
        self:onSaveAdventureMine()
    else
        if self.fun_form_type == PartnerConst.Fun_Form.Drama then
            --剧情布阵多队伍
            if self.cur_tab_data and self.cur_tab_data.fun_form_type ==  PartnerConst.Fun_Form.CrossArenaDef then -- 跨服竞技场
                --把当前更新到最新
                self:updateMoreTeamHeroInfo() 
                self:onFightCrossarena(self.dic_more_team_data[self.cur_tab_data.fun_form_type], self.cur_tab_data.fun_form_type, true)
            elseif self.cur_tab_data and self.cur_tab_data.fun_form_type ==  PartnerConst.Fun_Form.ArenapeakchampionDef then --巅峰冠军赛
                --把当前更新到最新
                self:updateMoreTeamHeroInfo()  
                self:onFightArenapeakchampion(self.dic_more_team_data[self.cur_tab_data.fun_form_type],  true)
            else
                self:onFightDrama()     
            end
        else
            self:onFightDrama()
        end
        
    end
end

function FormGoFightPanel:onSaveAdventureMine()
    if not self.five_hero_vo[self.select_team_index] then return end
    if not self.tab_list[self.select_team_index] then return end
    local floor = self.setting.floor
    local room_id = self.setting.room_id
    if not floor or not room_id then return end

    local pos_info = {}
    for i,v in pairs(self.five_hero_vo[self.select_team_index]) do
        local d = {}
        d.pos = i
        d.id = v.partner_id
        table_insert(pos_info, d)
    end
    if #pos_info == 0 then
        message(TI18N("至少需要上阵一个宝可梦"))
        return
    end
    self.mine_pos_info =  pos_info
    AdventureController:getInstance():send20646(floor, room_id, self.formation_type, pos_info, self.hallows_id)
end

--保存出战布阵信息
function FormGoFightPanel:onClickFightBtn()
    if not self.fun_form_type  then return end

    if self.fun_form_type == PartnerConst.Fun_Form.Expedit_Fight then
        --远征
        self:onFightExpedit()
    elseif self.fun_form_type == PartnerConst.Fun_Form.EndLess or self.fun_form_type == PartnerConst.Fun_Form.EndLessWater or 
    self.fun_form_type == PartnerConst.Fun_Form.EndLessFire or self.fun_form_type == PartnerConst.Fun_Form.EndLessWind or 
    self.fun_form_type == PartnerConst.Fun_Form.EndLessLightDark then
        --无尽试炼
        self:onFightEndLess()
    elseif self.fun_form_type == PartnerConst.Fun_Form.GuildDun_AD then
        -- 联盟副本
        self:onFightGuildDun()
    elseif self.fun_form_type == PartnerConst.Fun_Form.ElementWater 
        or self.fun_form_type == PartnerConst.Fun_Form.ElementFire
        or self.fun_form_type == PartnerConst.Fun_Form.ElementWind
        or self.fun_form_type == PartnerConst.Fun_Form.ElementLight
        or self.fun_form_type == PartnerConst.Fun_Form.ElementDark then
        -- 元素神殿
        self:onFightElement()
    elseif self.fun_form_type == PartnerConst.Fun_Form.Heaven
        or self.fun_form_type == PartnerConst.Fun_Form.HeavenBoss then
        -- 天界副本
        self:onFightHeaven()
    elseif self.fun_form_type == PartnerConst.Fun_Form.CrossArena
        or self.fun_form_type == PartnerConst.Fun_Form.CrossArenaDef then
        -- 跨服竞技场
        self:onFightCrossarena()
    elseif self.fun_form_type == PartnerConst.Fun_Form.LimitExercise then
        self:onFightLimitExercise()
    elseif self.fun_form_type == PartnerConst.Fun_Form.Sandybeach_boss then
        self:onFightSandybeachBoss()
    elseif self.fun_form_type == PartnerConst.Fun_Form.GuildSecretArea then
        --公会秘境
        self:onFightGuildSecretArea()
    elseif self.fun_form_type == PartnerConst.Fun_Form.Monopoly_Evt then
        -- 大富翁事件
        self:onFightMonopolyEvt()
    elseif self.fun_form_type == PartnerConst.Fun_Form.Monopoly_Boss then
        -- 大富翁boss
        self:onFightMonopolyBoss()
    elseif self.fun_form_type == PartnerConst.Fun_Form.PractiseTower then --新人练武场
        self:onFightPractiseTower()
    else
        --默认剧情通关 如果操作跟剧情一样 也可以默认此方法
        self:onFightDrama()
    end
end

--发送精英赛
function FormGoFightPanel:onFightEliteMatch(match_type)
    if not self.five_hero_vo[self.select_team_index] then return end
    local _type = match_type or self.setting.match_type


    local tab_data = self.tab_list[self.select_team_index]
    local dic_team_data = self:getDicTeamData(tab_data)

    local formations = {}
    for i,team_data in pairs(dic_team_data) do
        -- if _type == ElitematchConst.MatchType.eNormalMatch and i >= 2 then break end --常规赛只有一个队伍
        local data = {}
        local tab_data = self.tab_list[i]
        data.order = tab_data.order
        local pos_info = {}
        local list = self.five_hero_vo[i]
        if list then
            for j,v in pairs(list) do
                local tab = {}
                tab.pos = j
                tab.id = v.partner_id
                table_insert(pos_info, tab)   
            end
        end

        data.formation_type = team_data.formation_type
        data.hallows_id = team_data.hallows_id
        data.pos_info = pos_info
        table_insert(formations, data)
    end

    if _type == ElitematchConst.MatchType.eKingMatch then
        --表示王者赛
        local is_tips = false
        if not formations[2] then
            is_tips = true
        end
        for i,v in ipairs(formations) do
            if #v.pos_info == 0 then
                is_tips = true
                break
            end
        end

        if is_tips then
            --第二队伍未空.需要提示
            local str = TI18N("有队伍未设队伍信息确定要保存队伍？")
            CommonAlert.show( str, TI18N("确定"), function()
                ElitematchController:getInstance():sender24921(_type, formations)
            end, TI18N("取消"),nil,nil,nil,{title = TI18N("保存队伍")})
        else
            ElitematchController:getInstance():sender24921(_type, formations)        
        end
    else
        ElitematchController:getInstance():sender24921(_type, formations)    
    end
end

--发送挑战年兽
function FormGoFightPanel:onFightYearMonster()
    if not self.five_hero_vo[self.select_team_index] then return end
    if not self.setting then return end
    local grid_index = self.setting.grid_index

    local ext_list = {}
    -- 阵法 
    table_insert(ext_list, {type = ActionyearmonsterConstants.Proto_28203._1, val1 = self.formation_type, val2 = 0})
    -- 神器
    table_insert(ext_list, {type = ActionyearmonsterConstants.Proto_28203._2, val1 = self.hallows_id, val2 = 0})
    -- 宝可梦
    for i,v in pairs(self.five_hero_vo[self.select_team_index]) do
        table_insert(ext_list, {type = ActionyearmonsterConstants.Proto_28203._3, val1 = i, val2 = v.partner_id})
    end
    ActionyearmonsterController:getInstance():sender28203( self.setting.grid_index, 1, ext_list )
end

-- 打白色情人节boss
function FormGoFightPanel:onFightWhiteDayMonster()
    if not self.five_hero_vo[self.select_team_index] then return end

    local pos_info = {}
    for i,v in pairs(self.five_hero_vo[self.select_team_index]) do
        local tab = {}
        tab.pos = i
        tab.id = v.partner_id
        table_insert(pos_info, tab)
    end
    if next(pos_info) == nil then
        message(TI18N("至少需要上阵一个宝可梦"))
        return
    end
    local select_base_id = self.setting.select_base_id
    ActionController:getInstance():sender28801(select_base_id, self.formation_type, pos_info, self.hallows_id)
    self:onClickCloseBtn()
end

-- 新人练武场
function FormGoFightPanel:onFightPractiseTower()
    if not self.five_hero_vo[self.select_team_index] then return end

    local pos_info = {}
    for i,v in pairs(self.five_hero_vo[self.select_team_index]) do
        local tab = {}
        tab.pos = i
        tab.id = v.partner_id
        table_insert(pos_info, tab)
    end
    if next(pos_info) == nil then
        message(TI18N("至少需要上阵一个宝可梦"))
        return
    end
    if self.setting and self.setting.is_send == true then
        PractisetowerController:getInstance():openResultWindow(false)
    end
    
    if self.setting and self.setting.power and self.cur_power and self.setting.power> self.cur_power then
        local function fun()
            local select_base_id = self.setting.select_base_id
            PractisetowerController:getInstance():sender29101(select_base_id, self.formation_type, pos_info, self.hallows_id)
            self:onClickCloseBtn()
        end
        local settingPower = changeBtValueForPower(self.setting.power)
        local currentPower = changeBtValueForPower(self.cur_power)
        local str = string.format(TI18N('当前队伍战力未达推荐战力(<div fontColor=#d95014 >%s/%s</div>)，挑战难度较大，是否确认挑战？'), currentPower,settingPower)
        CommonAlert.show(str, TI18N('确定'), fun, TI18N('取消'), nil, CommonAlert.type.rich, nil, nil, nil, true)
        return
    end

    local select_base_id = self.setting.select_base_id
    PractisetowerController:getInstance():sender29101(select_base_id, self.formation_type, pos_info, self.hallows_id)
    self:onClickCloseBtn()
end

--发送联盟副本
function FormGoFightPanel:onFightGuildDun()
    if not self.five_hero_vo[self.select_team_index] then return end
    local pos_info = {}
    for i,v in pairs(self.five_hero_vo[self.select_team_index]) do
        local tab = {}
        tab.pos = i
        tab.id = v.partner_id
        table_insert(pos_info, tab)
    end
    local boss_id = self.setting.boss_id
    GuildbossController:getInstance():send21308(boss_id, self.formation_type, pos_info, self.hallows_id)
    self:onClickCloseBtn()
end
--发送公会秘境boss
function FormGoFightPanel:onFightGuildSecretArea()
    if not self.five_hero_vo[self.select_team_index] then return end
    local pos_info = {}
    for i,v in pairs(self.five_hero_vo[self.select_team_index]) do
        local tab = {}
        tab.pos = i
        tab.id = v.partner_id
        table_insert(pos_info, tab)
    end
    local boss_id = self.setting.boss_id
    GuildsecretareaController:getInstance():sender26802(boss_id, self.formation_type, pos_info, self.hallows_id)
    self:onClickCloseBtn()
end

--发送无尽试炼
function FormGoFightPanel:onFightEndLess()
    if not self.five_hero_vo[self.select_team_index] then return end
    local pos_info = {}
    for i,v in pairs(self.five_hero_vo[self.select_team_index]) do
        local tab = {}
        tab.pos = i
        tab.owner_id = v.rid
        tab.owner_srv_id = v.srv_id
        tab.id = v.partner_id
        table_insert(pos_info, tab)
    end
    
    local type = Endless_trailEvent.endless_type.old
    if self.fun_form_type == PartnerConst.Fun_Form.EndLessWater then--水系
        type = Endless_trailEvent.endless_type.water
    elseif self.fun_form_type == PartnerConst.Fun_Form.EndLessFire then--火系
        type = Endless_trailEvent.endless_type.fire
    elseif self.fun_form_type == PartnerConst.Fun_Form.EndLessWind then--风系
        type = Endless_trailEvent.endless_type.wind
    elseif self.fun_form_type == PartnerConst.Fun_Form.EndLessLightDark then--光暗系
        type = Endless_trailEvent.endless_type.light_dark
    end
    Endless_trailController:getInstance():send23901(type,self.formation_type, pos_info, self.hallows_id)
    self:onClickCloseBtn()
end

--发送试练塔
function FormGoFightPanel:onFightStarTower()
    local tower = self.setting.tower_lev or 0
    StartowerController:getInstance():sender11322(tower)
end
--发送远征
function FormGoFightPanel:onFightExpedit()
    if not self.five_hero_vo[self.select_team_index] then return end
    local pos_info = {}
    for i,v in pairs(self.five_hero_vo[self.select_team_index]) do
        local tab = {}
        tab.pos = i
        tab.owner_id = v.rid
        tab.owner_srv_id = v.srv_id
        tab.id = v.partner_id
        table_insert(pos_info, tab)
    end
    HeroExpeditController:getInstance():sender24403(self.formation_type, pos_info, self.hallows_id)
    self:onClickCloseBtn()
end

-- 元素圣殿
function FormGoFightPanel:onFightElement(  )
    if not self.five_hero_vo[self.select_team_index] then return end
    if not self:checkIsCanFight() then
        message(self.setting.limit_desc)
        return
    end

    local is_not_resonate_hero = false --是否有没有共鸣赋能宝可梦
    for i,hero_vo in pairs(self.five_hero_vo[self.select_team_index]) do
        if not (hero_vo.isResonateHero and hero_vo:isResonateHero()) then
            is_not_resonate_hero = true
        end
    end
    if not is_not_resonate_hero then
        --如果没有
        message(TI18N("至少上阵一个非赋能宝可梦"))
        return
    end
            
    local pos_info = {}
    for i,v in pairs(self.five_hero_vo[self.select_team_index]) do
        local tab = {}
        tab.pos = i
        tab.id = v.partner_id
        table_insert(pos_info, tab)
    end
    local ele_type = self.setting.ele_type
    local customs_id = self.setting.customs_id
    ElementController:getInstance():checkJoinHeavenBattle(ele_type, customs_id, self.formation_type, pos_info, self.hallows_id)
end

-- 大富翁事件
function FormGoFightPanel:onFightMonopolyEvt()
    if not self.five_hero_vo[self.select_team_index] then return end
            
    local pos_info = {}
    for i,v in pairs(self.five_hero_vo[self.select_team_index]) do
        table_insert(pos_info, {type = 2, arg1 = i, arg2 = v.partner_id})
    end
    if next(pos_info) == nil then
        message(TI18N("至少需要上阵一个宝可梦"))
        return
    end
    table_insert(pos_info, {type = 1, arg1 = self.formation_type, arg2 = 0})
    table_insert(pos_info, {type = 3, arg1 = self.hallows_id, arg2 = 0})
    MonopolyController:getInstance():sender27404(pos_info)
    self:onClickCloseBtn(true)
end

-- 大富翁boss
function FormGoFightPanel:onFightMonopolyBoss( )
    if not self.five_hero_vo[self.select_team_index] then return end

    local pos_info = {}
    for i,v in pairs(self.five_hero_vo[self.select_team_index]) do
        local tab = {}
        tab.pos = i
        tab.id = v.partner_id
        table_insert(pos_info, tab)
    end
    if next(pos_info) == nil then
        message(TI18N("至少需要上阵一个宝可梦"))
        return
    end
    local step_id = self.setting.step_id
    local boss_id = self.setting.boss_id
    MonopolyController:getInstance():sender27501(step_id, boss_id, self.formation_type, pos_info, self.hallows_id)
    self:onClickCloseBtn()
end

-- 天界副本
function FormGoFightPanel:onFightHeaven(  )
    if not self.five_hero_vo[self.select_team_index] then return end
    local _type = 1
    if self.fun_form_type == PartnerConst.Fun_Form.HeavenBoss then
        _type = 2
    end

    local tab_data = self.tab_list[self.select_team_index]
    local dic_team_data = self:getDicTeamData(tab_data)

    local formations = {}
    for i,team_data in pairs(dic_team_data) do
        local data = {}
        local tab_data = self.tab_list[i]
        data.order = tab_data.order
        local pos_info = {}
        local list = self.five_hero_vo[i]
        if list then
            for j,v in pairs(list) do
                local tab = {}
                tab.pos = j
                tab.id = v.partner_id
                table_insert(pos_info, tab)   
            end
        end

        data.formation_type = team_data.formation_type
        data.hallows_id = team_data.hallows_id
        data.pos_info = pos_info
        table_insert(formations, data)
    end

    local have_hero = false
    for i,v in ipairs(formations) do
        if #v.pos_info > 0 then
            have_hero = true
            break
        end
    end
    if not have_hero then
        message(TI18N("至少需要上阵一个宝可梦"))
        return
    end

    if _type == 2 then -- boss关
        local is_tips = false
        if not formations[2] then
            is_tips = true
        end
        for i,v in ipairs(formations) do
            if #v.pos_info == 0 then
                is_tips = true
                break
            end
        end

        if is_tips then
            --第二队伍未空.需要提示
            local str = TI18N("当前只布阵了一支队伍，确定要进入战斗吗？")
            CommonAlert.show( str, TI18N("确定"), function()
                HeavenController:getInstance():checkJoinHeavenBattle(_type, formations)
            end, TI18N("取消"),nil,nil,nil,{title = TI18N("保存队伍")})
        else
            HeavenController:getInstance():checkJoinHeavenBattle(_type, formations)
        end
    else
        HeavenController:getInstance():checkJoinHeavenBattle(_type, formations)    
    end
end

-- 跨服竞技场
--@ is_drama 是否 剧情上面的
function FormGoFightPanel:onFightCrossarena(team_data_list, fun_form_type, is_drama )
    local team_data_list = team_data_list or self.team_data_list
    local fun_form_type = fun_form_type or self.fun_form_type
    if team_data_list and next(team_data_list) ~= nil then
        -- 更新 self.team_data_list 数据
        if not is_drama then
            for i,v in ipairs(team_data_list) do
                if i > 1 then
                    v.pos_info = {}
                    local hero_datas = self.five_hero_vo[i]
                    if hero_datas then
                        for pos,hero_vo in pairs(hero_datas) do
                            local temp_data = {}
                            temp_data.id = hero_vo.id
                            temp_data.pos = pos
                            table_insert(v.pos_info, temp_data)
                        end
                    end
                end
            end
            table_remove(team_data_list, 1)
        end
        local temp_num = 0
        local hide_num = 0
        for k,v in pairs(team_data_list) do
            if v.pos_info and next(v.pos_info) ~= nil then
                temp_num = temp_num + 1
            end
            if v.is_hidden == 1 then
                hide_num = hide_num + 1
            end
        end
        if temp_num < 2 then
            message(TI18N("至少需2个队伍有宝可梦上阵"))
            return
        end

        local _type = 1
        if fun_form_type == PartnerConst.Fun_Form.CrossArenaDef then
            _type = 2
        end

        if _type == 2 and CrossarenaController:getInstance():getModel():checkIsCanHideTwoTeam() and hide_num ~= 2 then
            local hide_cfg = Config.ArenaClusterData.data_const["second_hide_rank"]
            if hide_cfg then
                message(string_format(TI18N("前%d名的玩家需要隐藏2队哦~"), hide_cfg.val))
            end
            return
        end
        local elfin_team_list = {}
        for i,v in ipairs(team_data_list) do
            if v.old_order == nil then
                table_insert(elfin_team_list, {team = v.order, old_team = v.order})
            else
                table_insert(elfin_team_list, {team = v.order, old_team = v.old_order})
            end
            v.old_order = nil
        end
        elfin_controller:send26564(fun_form_type, elfin_team_list)
        --这里需要清除
        CrossarenaController:getInstance():sender25604( _type, team_data_list )
    end
end

-- 巅峰冠军赛
--@ is_drama 是否 剧情上面的
function FormGoFightPanel:onFightArenapeakchampion(team_data_list, is_drama )
    local team_data_list = team_data_list or self.team_data_list
    if team_data_list and next(team_data_list) ~= nil then
        -- 更新 self.team_data_list 数据
        if not is_drama then
            for i,v in ipairs(team_data_list) do
                if i > 1 then
                    v.pos_info = {}
                    local hero_datas = self.five_hero_vo[i]
                    if hero_datas then
                        for pos,hero_vo in pairs(hero_datas) do
                            local temp_data = {}
                            temp_data.id = hero_vo.id
                            temp_data.pos = pos
                            table_insert(v.pos_info, temp_data)
                        end
                    end
                    v.is_hidden = nil
                end
            end
            table_remove(team_data_list, 1)
        end
        local temp_num = 0
        local hide_num = 0
        for k,v in pairs(team_data_list) do
            if v.pos_info and next(v.pos_info) ~= nil then
                temp_num = temp_num + 1
            end
        end
        if temp_num < 2 then
            message(TI18N("至少需2个队伍有宝可梦上阵"))
            return
        end
        local elfin_team_list = {}
        for i,v in ipairs(team_data_list) do
            if v.old_order == nil then
                table_insert(elfin_team_list, {team = v.order, old_team = v.order})
            else
                table_insert(elfin_team_list, {team = v.order, old_team = v.old_order})
            end
            v.old_order = nil
        end
        elfin_controller:send26564(PartnerConst.Fun_Form.ArenapeakchampionDef, elfin_team_list)

        ArenapeakchampionController:getInstance():sender27725(team_data_list)
    end
end

-- 是否满足开战条件
function FormGoFightPanel:checkIsCanFight(  )
    local is_can = true
    local limt_list = self.setting.limit or {}
    for i,v in ipairs(limt_list) do
        local camp_type = v[1]
        local need_num = v[2]
        if is_can then
            local have_num = 0
            for i,v in pairs(self.five_hero_vo[self.select_team_index]) do
                if v.camp_type == camp_type then
                    have_num = have_num + 1
                end
            end
            is_can = (have_num >= need_num)
        else
            break
        end
    end
    return is_can
end

--发送保存剧情布阵
function FormGoFightPanel:onFightDrama()
    if not self.five_hero_vo[self.select_team_index] then return end
    if not self.tab_list[self.select_team_index] then return end
    local tab_data = self.tab_list[self.select_team_index]
    local pos_info = {}
    for i,v in pairs(self.five_hero_vo[self.select_team_index]) do
        local d = {}
        d.pos = i
        d.id = v.partner_id
        if tab_data and tab_data.fun_form_type == PartnerConst.Fun_Form.Planes then -- 位面(雇佣的宝可梦也要加入阵容)
            d.flag = v.flag or 0
            table_insert(pos_info, d)
        else
            table_insert(pos_info, d)
        end
    end

    if #pos_info == 0 then
        message(TI18N("至少需要上阵一个宝可梦"))
        return
    end

    if tab_data.fun_form_type == PartnerConst.Fun_Form.EliteMatch then
        --现在只有常规赛.默认1..如果要加王者赛再考虑表的问题
        self:onFightEliteMatch(1)
    elseif tab_data.fun_form_type == PartnerConst.Fun_Form.Planes then -- 位面
        local planes_pos_info = {}
        for i,v in pairs(self.five_hero_vo[self.select_team_index]) do
            local d = {}
            d.pos = i
            d.id = v.partner_id
            if v.flag and v.flag == 1 then
                d.data = v
            end
            table_insert(planes_pos_info, d)
        end
        -- 更新守卫界面数据
        GlobalEvent:getInstance():Fire(PlanesafkEvent.Update_Form_Data_Event, self.formation_type, planes_pos_info)
        PlanesafkController:getInstance():sender28611(self.formation_type, pos_info, self.hallows_id)
    else
        if tab_data.fun_form_type == PartnerConst.Fun_Form.Drama then
            --剧情布阵需要判断赋能宝可梦
            local is_not_resonate_hero = false --是否有没有共鸣赋能宝可梦
            for i,hero_vo in pairs(self.five_hero_vo[self.select_team_index]) do
                if not (hero_vo.isResonateHero and hero_vo:isResonateHero()) then
                    is_not_resonate_hero = true
                end
            end
            if not is_not_resonate_hero then
                --如果没有
                message(TI18N("至少上阵一个非赋能宝可梦"))
                return
            end
        end

        controller:sender11212(tab_data.fun_form_type, self.formation_type, pos_info, self.hallows_id)
    end
    
end

--试炼之境的出战
function FormGoFightPanel:onFightLimitExercise()
    if not self.five_hero_vo[self.select_team_index] then return end
    if not self.tab_list[self.select_team_index] then return end
    local pos_info = {}
    for i,v in pairs(self.five_hero_vo[self.select_team_index]) do
        local d = {}
        d.pos = i
        d.id = v.partner_id
        table_insert(pos_info, d)
    end
    if #pos_info == 0 then
        message(TI18N("至少需要上阵一个宝可梦"))
        return
    end
    controller:sender11212(PartnerConst.Fun_Form.LimitExercise, self.formation_type, pos_info, self.hallows_id)
end
--沙滩战
function FormGoFightPanel:onFightSandybeachBoss()
    if not self.five_hero_vo[self.select_team_index] then return end
    if not self.tab_list[self.select_team_index] then return end
    local pos_info = {}
    for i,v in pairs(self.five_hero_vo[self.select_team_index]) do
        local d = {}
        d.pos = i
        d.id = v.partner_id
        table_insert(pos_info, d)
    end
    if #pos_info == 0 then
        message(TI18N("至少需要上阵一个宝可梦"))
        return
    end
    controller:sender11212(PartnerConst.Fun_Form.Sandybeach_boss, self.formation_type, pos_info, self.hallows_id)
end

--真正出战
function FormGoFightPanel:gotoFight()
    --试炼之镜 和 沙滩boss战.不关闭当前页面
    if self.fun_form_type ~= PartnerConst.Fun_Form.LimitExercise and 
        self.fun_form_type ~= PartnerConst.Fun_Form.Sandybeach_boss and
        self.fun_form_type ~= PartnerConst.Fun_Form.Adventure_Mine then
        self:onClickCloseBtn()
    end


    if self.fun_form_type == PartnerConst.Fun_Form.Drama then
        BattleDramaController:getInstance():send13003(0)
    elseif self.fun_form_type == PartnerConst.Fun_Form.Startower then
        --试练塔 --星命塔
        self:onFightStarTower()
    elseif self.fun_form_type == PartnerConst.Fun_Form.Sandybeach_boss then 
        -- ActionController:getInstance():sender25404()
    elseif self.fun_form_type == PartnerConst.Fun_Form.Adventure_Mine then 
        local floor = self.setting.floor
        local room_id = self.setting.room_id
        local is_skip = 0
        if self.is_skip_fight then
            is_skip = 1
        end
        AdventureController:getInstance():send20643(floor, room_id, is_skip)
    elseif self.fun_form_type == PartnerConst.Fun_Form.TermBegins then --开学季关卡副本
        ActiontermbeginsController:getInstance():sender26702()
    elseif self.fun_form_type == PartnerConst.Fun_Form.TermBeginsBoss then --开学季boss
        ActiontermbeginsController:getInstance():sender26707()
    elseif self.fun_form_type == PartnerConst.Fun_Form.YearMonster then --年兽
        self:onFightYearMonster()
    elseif self.fun_form_type == PartnerConst.Fun_Form.WhiteDay then --白色情人节
        self:onFightWhiteDayMonster()
    end   
end

--点击5个宝可梦Item move
function FormGoFightPanel:onClickHeroItemMove(index, sender)
    if not self.five_hero_vo[self.select_team_index] then return end
    --判断是否有移动
    self.is_move_hero = true

    if self.move_hero_item == nil then
        self.move_hero_item = HeroExhibitionItem.new(0.9, false)
        self.fight_hero_node:addChild(self.move_hero_item, 1)
    end
    self.move_hero_item:setData(self.five_hero_vo[self.select_team_index][index])
    self.hero_item_list[index]:setData(nil)


    local touch_pos = sender:getTouchMovePosition()
    local target_pos = self.fight_hero_node:convertToNodeSpace(touch_pos) 
    self.move_hero_item:setPosition(target_pos)
end

--点击5个宝可梦Item Cancel
function FormGoFightPanel:onClickHeroItemCanceled(index, sender)
    if not self.five_hero_vo[self.select_team_index] then return end
    self.is_move_hero = false
    if self.move_hero_item then
        --相当于隐藏
        self.move_hero_item:setPosition(-10000, 0)
    end

    local touch_pos = sender:getTouchMovePosition()
    local target_pos = self.fight_hero_node:convertToNodeSpace(touch_pos)
    for i,rect in ipairs(self.pos_rect_list) do
        if cc.rectContainsPoint( rect, target_pos ) then
            if i ~= index then
                --转换
                self.hero_item_list[i]:setData(self.five_hero_vo[self.select_team_index][index])
                -- self.hero_item_list[i]:showAddIcon(false)
                local temp_hero_vo = self.five_hero_vo[self.select_team_index][i]
                self.five_hero_vo[self.select_team_index][i] = self.five_hero_vo[self.select_team_index][index]

                if temp_hero_vo ~= nil then
                    self.hero_item_list[index]:setData(temp_hero_vo)
                    self.five_hero_vo[self.select_team_index][index] = temp_hero_vo
                else
                    self.hero_item_list[index]:setData(nil)
                    -- self.hero_item_list[index]:showAddIcon(true)
                    self.five_hero_vo[self.select_team_index][index] = nil
                end

                return
            else
                --点自己是下阵了 
                --这里系统直接执行 self:onClickHeroItemEnd()方法了
            end
        end
    end

    self.hero_item_list[index]:setData(self.five_hero_vo[self.select_team_index][index])

end

--点击5个宝可梦Item end
function FormGoFightPanel:onClickHeroItemEnd(index, sender)
    if not self.five_hero_vo[self.select_team_index] then return end
    -- if self.is_move_hero  then
    --     self:onClickHeroItemCanceled(index, sender)
    --     return
    -- end
    if self.move_hero_item then
        --相当于隐藏
        self.move_hero_item:setPosition(-10000, 0)
    end

    --说明是点击了 item 下阵
    if self.list_view then
        local item_list = self.list_view:getActiveCellList() or {}
        for i,item in ipairs(item_list) do
            local hero_vo = item:getData()

            if self.five_hero_vo[self.select_team_index][index] and hero_vo and hero_vo.partner_id == self.five_hero_vo[self.select_team_index][index].partner_id and
                hero_vo.rid == self.five_hero_vo[self.select_team_index][index].rid and 
                hero_vo.srv_id == self.five_hero_vo[self.select_team_index][index].srv_id then
                hero_vo.is_ui_select = false
                item:setSelected(hero_vo.is_ui_select)
                --结束位置 
                local world_pos = item:convertToWorldSpace(cc.p(HeroExhibitionItem.Width * 0.5, HeroExhibitionItem.Height * 0.5))    
                local end_pos = self.fight_hero_node:convertToNodeSpace(world_pos) 
                local x, y =  self.hero_item_list[index]:getPosition()
                self:showMoveEffect(cc.p(x,y), end_pos, hero_vo)

                self.hero_item_list[index]:setData(nil)
                -- self.hero_item_list[index]:showAddIcon(true)
                self.five_hero_vo[self.select_team_index][index] = nil
                self:updateMoreTeamHeroInfo()
                self:updateFightPower()
                return
            end
        end
    end
    --上面没有找到 直接下阵
    local hero_vo = self.five_hero_vo[self.select_team_index][index]
    if not hero_vo then return end
    local item = self.camp_btn_list[hero_vo.camp_type]
    if item == nil then
        --默认是全部那个
        item = self.camp_btn_list[0]
    end
    local world_pos = item:convertToWorldSpace(cc.p(58 * 0.5, 58 * 0.5))    
    local end_pos = self.fight_hero_node:convertToNodeSpace(world_pos) 
    local x, y =  self.hero_item_list[index]:getPosition()
    self:showMoveEffect(cc.p(x,y), end_pos, hero_vo)

    self.five_hero_vo[self.select_team_index][index].is_ui_select = false
    self.hero_item_list[index]:setData(nil)
    -- self.hero_item_list[index]:showAddIcon(true)
    self.five_hero_vo[self.select_team_index][index] = nil
    self:updateMoreTeamHeroInfo()
    self:updateFightPower()
end

--显示根据类型 0表示全部
function FormGoFightPanel:onClickBtnShowByIndex(select_camp)
    if self.img_select and self.camp_btn_list[select_camp] then
        local x, y = self.camp_btn_list[select_camp]:getPosition()
        self.img_select:setPosition(x - 0.5, y + 1)
    end
    self:updateHeroList(select_camp)
end

-- 灰化阵营按钮
function FormGoFightPanel:setCampBtnUnEnabled(list)
    if list and next(list) ~= nil and self.camp_btn_list and next(self.camp_btn_list) ~= nil then
        for k,v in pairs(list) do
            if self.camp_btn_list[v] then
                setChildUnEnabled(true, self.camp_btn_list[v])
                self.camp_btn_list[v]:setTouchEnabled(false)
            end
        end
    end
end

--@fun_form_type 布阵队伍类型
--@setting  不同的布阵类型 不同的设置信息
--@show_type 出战界面显示类型 1 出战 2 保存布阵 参考 HeroConst.FormShowType
function FormGoFightPanel:openRootWnd(fun_form_type, setting, show_type)

    self.fun_form_type = fun_form_type or PartnerConst.Fun_Form.Drama
    self.form_show_type = show_type or HeroConst.FormShowType.eFormFight

    self.select_team_index = 0
    self.setting = setting or {}
    --先初始化按钮
    self:initTabBtnList()
    local camp_lsit = {}
    --初始化宝可梦列表
    if self.fun_form_type == PartnerConst.Fun_Form.EndLessWater then--新版无尽需要处理特殊选中和灰化不可点击阵营
        self:onClickBtnShowByIndex(HeroConst.CampType.eWater)
        camp_lsit = {0,HeroConst.CampType.eFire,HeroConst.CampType.eWind,HeroConst.CampType.eLight,HeroConst.CampType.eDark}
    elseif self.fun_form_type == PartnerConst.Fun_Form.EndLessFire then
        self:onClickBtnShowByIndex(HeroConst.CampType.eFire)
        camp_lsit = {0,HeroConst.CampType.eWater,HeroConst.CampType.eWind,HeroConst.CampType.eLight,HeroConst.CampType.eDark}
    elseif self.fun_form_type == PartnerConst.Fun_Form.EndLessWind then
        self:onClickBtnShowByIndex(HeroConst.CampType.eWind)
        camp_lsit = {0,HeroConst.CampType.eWater,HeroConst.CampType.eFire,HeroConst.CampType.eLight,HeroConst.CampType.eDark}
    elseif self.fun_form_type == PartnerConst.Fun_Form.EndLessLightDark then
        self:onClickBtnShowByIndex(HeroConst.CampType.eLight)
        camp_lsit = {0,HeroConst.CampType.eWater,HeroConst.CampType.eFire,HeroConst.CampType.eWind}
    else
        self:onClickBtnShowByIndex(0)
    end
    
    self:setCampBtnUnEnabled(camp_lsit)

    --初始化阵法设置信息
    self:initFormSetInfo()

    self.close_btn:setVisible(self.fun_form_type ~= PartnerConst.Fun_Form.Monopoly_Evt)
    self.txt_cn_common_notice_1:setVisible(self.fun_form_type ~= PartnerConst.Fun_Form.Monopoly_Evt)

    self:setShowTypeUI()
end

--初始化阵法设置信息
function FormGoFightPanel:initFormSetInfo()
     --阵容打开前需要的设置
    if self.fun_form_type == PartnerConst.Fun_Form.ElementWater 
        or self.fun_form_type == PartnerConst.Fun_Form.ElementFire
        or self.fun_form_type == PartnerConst.Fun_Form.ElementWind
        or self.fun_form_type == PartnerConst.Fun_Form.ElementLight
        or self.fun_form_type == PartnerConst.Fun_Form.ElementDark then
        -- 出战条件提示
        if self.setting.limit_desc then
            self.pos_tips:setString(self.setting.limit_desc)
        end
    elseif self.fun_form_type == PartnerConst.Fun_Form.HeavenBoss then
        self.pos_tips:setString(TI18N("本关可上阵两支队伍"))
        self.pos_tips:setTextColor(cc.c3b(201,38,6))
    elseif self.fun_form_type == PartnerConst.Fun_Form.CrossArena or 
        self.fun_form_type == PartnerConst.Fun_Form.CrossArenaDef or --跨服竞技场
        self.fun_form_type == PartnerConst.Fun_Form.ArenapeakchampionDef then --巅峰冠军赛
        self.form_panel:setVisible(false)
        self.form_list_panel:setVisible(false)
    elseif self.fun_form_type == PartnerConst.Fun_Form.LimitExercise then
        -- self.pos_tips:setString(TI18N("开战后将扣除宝可梦参战次数，次数耗尽将无法继续战斗"))
    elseif self.fun_form_type == PartnerConst.Fun_Form.Adventure_Mine_Def then
        --秘矿冒险 防守
        if self.setting.is_occupy and self.save_btn then
            self.save_btn:getChildByName("label"):setString(TI18N("占 领"))
        end
        AdventureController:getInstance():send20658()
        self:addDownTime()
    elseif self.fun_form_type == PartnerConst.Fun_Form.Adventure_Mine then 
        --秘矿冒险 挑战
        self.is_skip_fight = SysEnv:getInstance():getBool(SysEnv.keys.adventure_mine_skip_fight, false)
        if self.checkbox then
            self.checkbox:setVisible(true)
            self.checkbox:setSelected(self.is_skip_fight)
        end
    elseif self.fun_form_type == PartnerConst.Fun_Form.EliteMatch then
        self:addDownTime()
    elseif self.fun_form_type == PartnerConst.Fun_Form.EndLessWater 
        or self.fun_form_type == PartnerConst.Fun_Form.EndLessFire
        or self.fun_form_type == PartnerConst.Fun_Form.EndLessWind
        or self.fun_form_type == PartnerConst.Fun_Form.EndLessLightDark then
        -- 出战条件提示
        if Endless_trailEvent.type_name[self.fun_form_type] then
            self.pos_tips:setString(string_format(TI18N("只可上阵%s宝可梦"),Endless_trailEvent.type_name[self.fun_form_type]))
            self.pos_tips:setTextColor(cc.c3b(36,144,3))
        end
    end
end
--发送获取队伍信息 根据队伍类型 
function FormGoFightPanel:sendByFormType(fun_form_type)

    if self.dic_is_sends == nil then
        self.dic_is_sends = {}
    end
    if self.dic_is_sends[fun_form_type] then
        return
    end
    self.dic_is_sends[fun_form_type] = true

    if fun_form_type == PartnerConst.Fun_Form.Drama then
        self:initDramaFormInfo()
    elseif fun_form_type == PartnerConst.Fun_Form.EliteMatch then
        local match_type = self.setting.match_type or ElitematchConst.MatchType.eNormalMatch
        ElitematchController:getInstance():sender24920(match_type)
    elseif fun_form_type == PartnerConst.Fun_Form.Heaven then
        HeavenController:getInstance():sender25210(1)
    elseif fun_form_type == PartnerConst.Fun_Form.HeavenBoss then
        HeavenController:getInstance():sender25210(2)
    elseif fun_form_type == PartnerConst.Fun_Form.CrossArena then
        CrossarenaController:getInstance():sender25605(1)
    elseif fun_form_type == PartnerConst.Fun_Form.CrossArenaDef then
        CrossarenaController:getInstance():sender25605(2)
    elseif fun_form_type == PartnerConst.Fun_Form.ArenapeakchampionDef then
        ArenapeakchampionController:getInstance():sender27726()
    elseif fun_form_type == PartnerConst.Fun_Form.Adventure_Mine_Def then
        --秘矿冒险
        self:initMineFormInfo()
    elseif fun_form_type == PartnerConst.Fun_Form.Planes then -- 位面
        PlanesafkController:getInstance():sender28612()
    else 
        --其他的都根据协议获取阵容
        controller:sender11211(fun_form_type)
    end

    --精灵布阵的获取
    if fun_form_type == PartnerConst.Fun_Form.EliteMatch then
        local match_type = self.setting.match_type or ElitematchConst.MatchType.eNormalMatch
        if match_type == 1 then
            elfin_controller:send26555(PartnerConst.Fun_Form.EliteMatch)
        else
            elfin_controller:send26555(PartnerConst.Fun_Form.EliteKingMatch)
        end
    else
        if self.elfin_team_data_list[self.select_team_index] then
            self:updateElfinList(self.elfin_team_data_list[self.select_team_index])
        else
            elfin_controller:send26555(fun_form_type)
        end
        
    end
end

function FormGoFightPanel:initTabBtnList()
    self.tab_list = {}
    if self.fun_form_type == PartnerConst.Fun_Form.Drama then
        if self.form_show_type == HeroConst.FormShowType.eFormFight then --出战 
            self:setTabData(self.fun_form_type, TI18N("队伍"), 1)
        else
            --剧情保存布阵 要显示好多
            local config_list =Config.PartnerData.data_partner_form
            for k,config in pairs(config_list) do
                self:setTabData(config.form_type, config.name, config.index, 1, false, true)
            end
        end
    elseif self.fun_form_type == PartnerConst.Fun_Form.EliteMatch then
        local is_multiple = false
        if self.setting.match_type and self.setting.match_type == ElitematchConst.MatchType.eKingMatch then
            is_multiple = true
        end
        self:setTabData(self.fun_form_type, TI18N("队伍一"), 1, 1,is_multiple)
        self:setTabData(self.fun_form_type, TI18N("队伍二"), 2, 2,is_multiple)
    elseif self.fun_form_type == PartnerConst.Fun_Form.HeavenBoss then
        self:setTabData(self.fun_form_type, TI18N("队伍一"), 1, 1,true)
        self:setTabData(self.fun_form_type, TI18N("队伍二"), 2, 2,true)
    elseif self.fun_form_type == PartnerConst.Fun_Form.CrossArena or 
        self.fun_form_type == PartnerConst.Fun_Form.CrossArenaDef or 
        self.fun_form_type == PartnerConst.Fun_Form.ArenapeakchampionDef then

        self:setTabData(self.fun_form_type, TI18N("总览"), 1, 0,false)
        self:setTabData(self.fun_form_type, TI18N("队伍一"), 2, 1,true)
        self:setTabData(self.fun_form_type, TI18N("队伍二"), 3, 2,true)
        self:setTabData(self.fun_form_type, TI18N("队伍三"), 4, 3,true)
    else
        self:setTabData(self.fun_form_type, TI18N("队伍"), 1)
    end
    local sort_func = SortTools.tableLowerSorter({"sort_index","index"})
    table_sort(self.tab_list, sort_func)
    self:checkTabUnlockInfo()
    self:updateTabBtnList()
end

--is_check @
function FormGoFightPanel:setTabData(fun_form_type, name, index, order, is_multiple, is_check)
    local tab_data = {}
    tab_data.fun_form_type = fun_form_type --阵法类型
    tab_data.name = name   --阵法名字
    tab_data.index = index --阵法排序
    tab_data.is_multiple = is_multiple or false --是否会有多队伍
    tab_data.order = order or 1 --队伍序号
    --是否要加一个需要加一个开启显示
    if is_check then
        tab_data.sort_index = 0 
        tab_data.is_lock = false
        if fun_form_type == PartnerConst.Fun_Form.Arena or fun_form_type == PartnerConst.Fun_Form.ArenaChampion  then 
            --竞技场的  冠军赛的开启条件
            -- local config = Config.CityData.data_base[CenterSceneBuild.arena]
            local is_open, desc = MainSceneController:getInstance():checkBuildIsOpen(CenterSceneBuild.arena)
            tab_data.is_lock = not is_open
            tab_data.is_lock_des = desc or TI18N("未解锁")
        elseif fun_form_type == PartnerConst.Fun_Form.Ladder then
            --天梯
            local is_open, desc = LadderController:getInstance():getModel():getLadderOpenStatus(true)
            tab_data.is_lock = not is_open
            tab_data.is_lock_des = desc or TI18N("未解锁")
        elseif fun_form_type == PartnerConst.Fun_Form.EliteMatch then
            --精英赛
            local is_open, _, desc = ElitematchController:getInstance():getModel():checkElitematchIsOpen(true)
            tab_data.is_lock = not is_open
            tab_data.is_lock_des = desc or TI18N("未解锁")
        elseif fun_form_type == PartnerConst.Fun_Form.ArenaTeam then --组队竞技场
            local is_open, _, desc = ArenateamController:getInstance():getModel():checkArenaTeamIsOpen(true)
            tab_data.is_lock_des = desc or TI18N("未解锁")
            tab_data.is_lock = not is_open
        elseif fun_form_type == PartnerConst.Fun_Form.CrossArenaDef then --跨服竞技场
            local is_open, desc = CrossarenaController:getInstance():getModel():getCrossarenaIsOpen(true)
            tab_data.is_lock = not is_open
            tab_data.is_lock_des = desc or TI18N("未解锁")
        elseif fun_form_type == PartnerConst.Fun_Form.ArenapeakchampionDef then --巅峰冠军赛
            local is_open, desc = ArenapeakchampionController:getInstance():getModel():checkPeakChampionIsOpen(true)
            tab_data.is_lock = not is_open
            tab_data.is_lock_des = desc or TI18N("未解锁")
        end
    else
        tab_data.sort_index = 0
        tab_data.is_lock = false
    end
    table_insert(self.tab_list, tab_data)
end 

function FormGoFightPanel:setShowTypeUI()
    if self.form_show_type == HeroConst.FormShowType.eFormFight then --出战 
        self.fight_btn:setVisible(true)
        self.save_btn:setVisible(false)
        self.key_up_btn:setVisible(false)
    elseif self.form_show_type == HeroConst.FormShowType.eFormSave then --保存
        self.fight_btn:setVisible(false)
        self.save_btn:setVisible(true)
        self.key_up_btn:setVisible(true)
    end
end

--队伍按钮列表
function FormGoFightPanel:updateTabBtnList()
    if not self.tab_btn then return end
    if not self.tab_btn_list_view then
        local size = self.tab_btn:getContentSize()
        local setting = {
            -- item_class = HeroExhibitionItem,      -- 单元类
            start_x = 0,                  -- 第一个单元的X起点
            space_x = 4,                    -- x方向的间隔
            start_y = 0,                    -- 第一个单元的Y起点
            space_y = 0,                   -- y方向的间隔
            item_width = 170,               -- 单元的尺寸width
            item_height = 50,              -- 单元的尺寸height
            -- row = 1,                        -- 行数，作用于水平滚动类型
            col = 5,                         -- 列数，作用于垂直滚动类型
            need_dynamic = true
        }
        self.tab_btn_list_view = CommonScrollViewSingleLayout.new(self.tab_btn, cc.p(size.width * 0.5, size.height * 0.5) , ScrollViewDir.horizontal, ScrollViewStartPos.top, size, setting, cc.p(0.5,0.5))

        self.tab_btn_list_view:registerScriptHandlerSingle(handler(self,self.createNewCellTabBtn), ScrollViewFuncType.CreateNewCell) --创建cell
        self.tab_btn_list_view:registerScriptHandlerSingle(handler(self,self.numberOfCellsTabBtn), ScrollViewFuncType.NumberOfCells) --获取数量
        self.tab_btn_list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndexTabBtn), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        self.tab_btn_list_view:registerScriptHandlerSingle(handler(self,self.onCellTouchedTabBtn), ScrollViewFuncType.OnCellTouched) --更新cell
    end
    self.tab_btn_list_view:reloadData(1)
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function FormGoFightPanel:createNewCellTabBtn(width, height)
    local cell = ccui.Widget:create()
    cell.root_wnd = createCSBNote(PathTool.getTargetCSB("hero/form_go_fight_tab_btn"))
    cell:addChild(cell.root_wnd)
    cell:setCascadeOpacityEnabled(true)
    cell:setAnchorPoint(cc.p(0.5, 0.5))
    cell:setContentSize(cc.size(width, height))
    cell.tab_btn = cell.root_wnd:getChildByName("tab_btn")
    cell.normal_img = cell.tab_btn:getChildByName("normal_img")
    cell.select_img = cell.tab_btn:getChildByName("select_img")
    cell.select_img:setVisible(false)
    -- cell.setOntouch
    cell.tab_btn:setSwallowTouches(false)
    cell.label = cell.tab_btn:getChildByName("label")

    --红点.目前处以隐藏..还没有需呀用到
    cell.red_point = cell.tab_btn:getChildByName("red_point")

    registerButtonEventListener(cell.tab_btn, function() self:onCellTouchedTabBtn(cell) end ,false, 2, nil, nil, nil, true)
    -- --回收用
    -- cell.DeleteMe = function() 
    -- end
    return cell
end

--获取数据数量
function FormGoFightPanel:numberOfCellsTabBtn()
    if not self.tab_list then return 0 end
    return #self.tab_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function FormGoFightPanel:updateCellByIndexTabBtn(cell, index)
    cell.index = index
    local tab_data = self.tab_list[index]
    if tab_data then
        cell.label:setString(tab_data.name)
        if self.select_team_index == index then
            cell.select_img:setVisible(true)
        else
            cell.select_img:setVisible(false)
        end

        if tab_data.is_lock ~= nil then
            if tab_data.is_lock then
                --cell.label:disableEffect(cc.LabelEffect.OUTLINE)
                cell.label:disableEffect(cc.LabelEffect.SHADOW)
                setChildUnEnabled(true, cell.tab_btn)
            else 
                if self.select_team_index and self.select_team_index == tab_data.index then
                    cell.label:setTextColor(Config.ColorData.data_new_color4[1])
                    cell.label:enableShadow(Config.ColorData.data_new_color4[2],cc.size(0, -2),2)
                else
                    cell.label:setTextColor(Config.ColorData.data_new_color4[6])
                    cell.label:disableEffect(cc.LabelEffect.SHADOW)
                end
                --cell.label:enableOutline(cc.c4b(0x2A, 0x16, 0x0E, 0xff), 2) --橙色
                setChildUnEnabled(false, cell.tab_btn)
            end
        end
    end
end

--inde :数据的索引
function FormGoFightPanel:onCellTouchedTabBtn(cell)
    local index = cell.index
    
    self:changeTabType(index, true)
end

-- @_type 参考 HeroConst.MainInfoTab 定义
--@check_repeat_click 是否检查重复点击
function FormGoFightPanel:changeTabType(index, check_repeat_click, is_move_tab)
    if not  self.tab_btn_list_view then return end
    if not self.tab_btn_list_view:isActiveByIndex(index) then
        --目前没有这样的需求, 功能暂时不支持
        --如果不在活跃中..不做事情
        return
    end
    if not index then return end
    if check_repeat_click and self.select_team_index == index then return end

    local tab_data = self.tab_list[index]

    if self.fun_form_type == PartnerConst.Fun_Form.EliteMatch then
        if index == 2 and tab_data.is_lock then
            if self.setting.match_type == ElitematchConst.MatchType.eKingMatch then
                local config = Config.ArenaEliteData.data_elite_const.second_team_open_condition
                if config then
                    message(config.desc)
                else
                    message(TI18N("解锁神器幻化外观【烈焰之剑】后开启"))
                end
            else
                message(TI18N("进入王者赛开启第二队伍的使用"))
            end
            return 
        end
    else
        if tab_data.is_lock then
            message(tab_data.is_lock_des)
            return
        end
    end
    
    if self.cur_tab ~= nil then
        -- self.cur_tab.label:setTextColor(Config.ColorData.data_color4[141])
        self.cur_tab.select_img:setVisible(false)
        self.cur_tab.label:setTextColor(Config.ColorData.data_new_color4[6])
        self.cur_tab.label:disableEffect(cc.LabelEffect.SHADOW)
    end
    self.select_team_index = index
    self.cur_tab_data = tab_data
    self.cur_tab =  self.tab_btn_list_view:getCellByIndex(self.select_team_index)

    if self.cur_tab ~= nil then
        -- self.cur_tab.label:setTextColor(Config.ColorData.data_color4[180])
        self.cur_tab.select_img:setVisible(true)
        self.cur_tab.label:setTextColor(Config.ColorData.data_new_color4[1])
        self.cur_tab.label:enableShadow(Config.ColorData.data_new_color4[2],cc.size(0, -2),2)
    end

    if tab_data then
        -- 跨服竞技场特殊处理（有总览）
        if tab_data.fun_form_type == PartnerConst.Fun_Form.CrossArena or 
            tab_data.fun_form_type == PartnerConst.Fun_Form.CrossArenaDef or
            tab_data.fun_form_type == PartnerConst.Fun_Form.ArenapeakchampionDef then

            if self.fun_form_type == PartnerConst.Fun_Form.Drama then
                --多队伍并且在剧情布阵打开 self.dic_more_team_data
                self.team_select_team_index = nil
                if self.dic_more_team_data[tab_data.fun_form_type] ~= nil then
                    --默认返回第一个
                    self:onClickTeamTabBtn(1)
                else
                    self:sendByFormType(tab_data.fun_form_type)
                end
                self:setMoreTeamUi(true)
            else
                if not self.team_data_list or next(self.team_data_list) == nil then
                    self:sendByFormType(tab_data.fun_form_type)
                else
                    self:initCrossarenaFormInfo()
                end

                self:setMoreTeamUi(false)
            end
        else
            if self.team_data_list[self.select_team_index] ~= nil then
                self.form_panel:setVisible(true)
                self.form_list_panel:setVisible(false)
                self:initFormInfo(self.team_data_list[self.select_team_index])
                if self.elfin_team_data_list[self.select_team_index] then
                    self:updateElfinList(self.elfin_team_data_list[self.select_team_index])
                end
            else
                self:sendByFormType(tab_data.fun_form_type)
            end
            self:setMoreTeamUi(false)
        end
    end
end

function FormGoFightPanel:setMoreTeamUi(is_more)
    if not self.team_tab_btn then return end
    if not self.txt_cn_common_notice_1 then return end

    if is_more then
        self.team_tab_btn:setVisible(true)
        self.txt_cn_common_notice_1:setVisible(false)
    else
        self.team_tab_btn:setVisible(false)
        self.txt_cn_common_notice_1:setVisible(true)
    end
end

--剧情界面多队伍的按钮
function FormGoFightPanel:onClickTeamTabBtn(index, is_check)
    if is_check and self.select_team_index and self.select_team_index == index then return end
    if not self.cur_tab_data then return end
    if not self.dic_more_team_data[self.cur_tab_data.fun_form_type] then return end

    if self.team_cur_tab ~= nil then
        self.team_cur_tab.select_img:setVisible(false)
        self.team_cur_tab.label:setTextColor(Config.ColorData.data_new_color4[6])
        self.team_cur_tab.label:disableEffect(cc.LabelEffect.SHADOW)
    end
    --标志是否需要更新数据 从 index =1 变到index = 非1的
    local is_change_data = false 
    --这里要处理 把 可能会修改的宝可梦数据 分
    if self.team_select_team_index ~= nil and self.team_select_team_index > 1 then
        --说明切换页签了
        local formation_type = self.team_data_list[self.select_team_index].formation_type
        local hallows_id = self.team_data_list[self.select_team_index].hallows_id
        self:updateMoreTeamHeroInfo(formation_type, hallows_id)
        
    else
        if self.team_select_team_index and self.team_select_team_index == 1 then
            if index ~= 1 then
                is_change_data = true
            end
        end
    end

    self.team_select_team_index = index
    self.team_cur_tab =  self.team_tab_list[index]

    if self.team_cur_tab ~= nil then
        self.team_cur_tab.select_img:setVisible(true)
        self.team_cur_tab.label:setTextColor(Config.ColorData.data_new_color4[1])
        self.team_cur_tab.label:enableShadow(Config.ColorData.data_new_color4[2],cc.size(0, -2),2)
    end

    self:teamInitFormInfo(index, is_change_data)
end

--更新多队伍宝可梦数据
function FormGoFightPanel:updateMoreTeamHeroInfo(formation_type, hallows_id)
    if self.fun_form_type == PartnerConst.Fun_Form.Drama and 
        self.cur_tab_data and (self.cur_tab_data.fun_form_type ==  PartnerConst.Fun_Form.CrossArenaDef or
        self.cur_tab_data.fun_form_type == PartnerConst.Fun_Form.ArenapeakchampionDef) then
        local index = self.team_select_team_index - 1
        local formation = self.dic_more_team_data[self.cur_tab_data.fun_form_type][index]
        local hero_datas = self.five_hero_vo[self.select_team_index]
        if hero_datas and formation then
            formation.pos_info = {}
            if formation_type then
                formation.formation_type = formation_type
            end
            if hallows_id then
                formation.hallows_id = hallows_id
            end
            --这里有一个优化点.单个的时候开可以只刷新单个
            for pos,hero_vo in pairs(hero_datas) do
                local temp_data = {}
                temp_data.id = hero_vo.id
                temp_data.pos = pos
                table_insert(formation.pos_info, temp_data)
            end
        end
    end
end

function FormGoFightPanel:checkTabUnlockInfo()
    --是否开启第二队伍  目前只有精英赛有
    if self.fun_form_type == PartnerConst.Fun_Form.EliteMatch then
        for i,tab_data in ipairs(self.tab_list) do

            if i == 2 then
                if self.setting.match_type == ElitematchConst.MatchType.eKingMatch then
                    --暂时只判断王者赛的是否解锁
                    local config = Config.ArenaEliteData.data_elite_const.second_team_open_condition
                    if config then
                        tab_data.is_lock = not HallowsController:getInstance():getModel():checkHallowsMagicIsHave(config.val) 
                    else
                        tab_data.is_lock = not HallowsController:getInstance():getModel():checkHallowsMagicIsHave(2) 
                    end
                else
                    tab_data.is_lock = true
                end
            else
                tab_data.is_lock = false
            end
        end
    end
end

--设置精英赛布阵信息的缺省数据 目前王者赛、天界副本boss关用
function FormGoFightPanel:setEliteMatchDefaultInfo(max_team_count)
    if not max_team_count then return end
    for i=1,max_team_count do
        if (self.setting.match_type and self.setting.match_type == ElitematchConst.MatchType.eKingMatch) or 
            self.fun_form_type == PartnerConst.Fun_Form.HeavenBoss or 
            self.fun_form_type == PartnerConst.Fun_Form.CrossArena or 
            self.fun_form_type == PartnerConst.Fun_Form.CrossArenaDef or
            self.fun_form_type == PartnerConst.Fun_Form.ArenapeakchampionDef then
            --目前只有王者赛有两个队伍
            if self.team_data_list[i] == nil then
                local data = {}
                data.formation_type = 1
                data.hallows_id = 0
                data.pos_info = {}
                self.team_data_list[i] = data
            end
        end
    end
end
--设置剧情布阵多队伍的布阵信息的缺省数据
function FormGoFightPanel:setTeamMactchDefaultInfo(max_team_count, formations, fun_form_type)
    if not max_team_count then return {} end
    local formations = formations or {}
    local  dic_order = {}
    for i,v in ipairs(formations) do
        dic_order[v.order] = v
    end
    for i=1,max_team_count do
        if dic_order[i] == nil then
            local data = {}
            data.formation_type = 1
            data.hallows_id = 0
            data.pos_info = {}
            data.order = i
            dic_order[i] = data
        end
    end
    return dic_order
end

function FormGoFightPanel:getDicTeamData(tab_data)
    if not tab_data then return {} end
    local dic_team_data = {}
    local more_team_data = nil
    if tab_data.is_multiple then
        for i,v in ipairs(self.tab_list) do
            if tab_data.fun_form_type == v.fun_form_type then
                dic_team_data[i] = self.team_data_list[i]
            end
        end
    else
        dic_team_data[self.select_team_index] = self.team_data_list[self.select_team_index]
        if self.fun_form_type == PartnerConst.Fun_Form.Drama and 
            (tab_data.fun_form_type == PartnerConst.Fun_Form.CrossArenaDef or tab_data.fun_form_type == PartnerConst.Fun_Form.ArenapeakchampionDef) then
            --剧情布阵 多队伍之跨服竞技场 巅峰冠军赛
            more_team_data = self.dic_more_team_data[tab_data.fun_form_type]
        end

    end
    return dic_team_data, more_team_data
end
--设置宝可梦已经被选中
function FormGoFightPanel:setHeroIsSelect()
    --清空选中状态
    local hero_list = model:getHeroList()
    for k, hero_vo in pairs(hero_list) do
        hero_vo.is_ui_select = nil
    end
    local tab_data = self.tab_list[self.select_team_index]
    if tab_data then
        --需要清空的队伍信息
        local dic_team_data, more_team_data = self:getDicTeamData(tab_data)
        for i,v in pairs(dic_team_data) do
            if self.five_hero_vo[i] == nil then
                self.five_hero_vo[i] = {}
                local pos_info = v.pos_info or {}
                for k,info in pairs(pos_info) do
                    local hero_vo
                    if self.fun_form_type == PartnerConst.Fun_Form.Planes and info.flag and info.flag == 1 then
                        for i,s_data in ipairs(self.show_list) do
                            if info.id == s_data.partner_id and s_data.flag == 1 then
                                hero_vo = s_data
                                break
                            end
                        end
                    else
                        hero_vo = model:getHeroById(info.id)
                    end
                    if hero_vo and next(hero_vo) ~= nil then
                        hero_vo.is_ui_select = true
                        self.five_hero_vo[i][info.pos] = hero_vo
                    else
                        self.five_hero_vo[i][info.pos] = nil
                    end
                end
            else
                for k,_hero_vo in pairs(self.five_hero_vo[i]) do
                    local hero_vo
                    if self.fun_form_type == PartnerConst.Fun_Form.Planes and _hero_vo.flag and _hero_vo.flag == 1 then
                        for i,s_data in ipairs(self.show_list) do
                            if _hero_vo.id == s_data.partner_id and s_data.flag == 1 then
                                hero_vo = s_data
                                break
                            end
                        end
                    else
                        hero_vo = model:getHeroById(_hero_vo.id)
                    end
                    if hero_vo and next(hero_vo) ~= nil then
                        hero_vo.is_ui_select = true
                    else
                        self.five_hero_vo[i][k] = nil
                    end
                end
            end
        end

        if more_team_data then
            for k,v in pairs(more_team_data) do
                local pos_info = v.pos_info or {}
                for _,info in pairs(pos_info) do
                    local hero_vo = model:getHeroById(info.id)
                    if hero_vo then
                        hero_vo.is_ui_select = true
                    end
                end
            end
        end
    end
end

--剧情布阵信息
function FormGoFightPanel:initDramaFormInfo()
    --是否布阵网络信息返回
    self.is_form_back = true
    local pos_list =  model:getMyPosList()
    local data = {}
    data.formation_type = model.use_formation_type
    data.hallows_id = model.use_hallows_id
    data.pos_info = pos_list
    self.team_data_list[self.select_team_index] = data
    self:initFormInfo(data)
end

--秘矿冒险的布阵信息
function FormGoFightPanel:initMineFormInfo()

    local dic_mine_hero_list = AdventureController:getInstance():getUiModel().dic_mine_hero_list or {}
    self.dic_mine_hero_list = deepCopy(dic_mine_hero_list)
    local defense = self.setting.defense or {}
    -- defense = {}
    --清除当前已经登陆的
    for i,v in ipairs(defense) do
        self.dic_mine_hero_list[v.id] = nil
    end
    --是否布阵网络信息返回
    self.is_form_back = true
    local data = {}
    data.formation_type = self.setting.formation_type or 1
    data.hallows_id = self.setting.hallows_id or 0
    data.pos_info = defense
    self.team_data_list[self.select_team_index] = data
    self:initFormInfo(data)
end
    
--其他布阵信息
function FormGoFightPanel:initFormInfo(data)
    if not data then return end
    local formation_config = Config.FormationData.data_form_data[data.formation_type]
    if not formation_config then return end
    --是否布阵网络信息返回
    self.is_form_back = true
    self.formation_type = data.formation_type
    self.hallows_id = data.hallows_id or 1
    self:initFormationData(formation_config)
    self:updateFormationIcon()
    self:updateFiveHeroItem()
    self:updateHallowsIcon()

    if self.form_list_panel then
        self.form_list_panel:setVisible(false)
    end
    if self.form_panel then
        self.form_panel:setVisible(true)
    end
end

-- 跨服竞技场
function FormGoFightPanel:initCrossarenaFormInfo(  )
    if not self.team_data_list then return end
    if self.select_team_index == 1 then
        self.form_panel:setVisible(false)
        self.form_list_panel:setVisible(true)
        if not self.crossarena_form_list_panel then
            self.crossarena_form_list_panel = CorssarenaFormListPanel.New(self.form_list_panel, self, self.form_show_type, self.fun_form_type)
        end
        
        -- 更新 self.team_data_list 中的宝可梦数据
        if not self._init_crossarena then
            self._init_crossarena = true
        else
            for i,v in ipairs(self.team_data_list) do
                if i > 1 then
                    v.pos_info = {}
                    local hero_datas = self.five_hero_vo[i]
                    if hero_datas then
                        for pos,hero_vo in pairs(hero_datas) do
                            local temp_data = {}
                            temp_data.id = hero_vo.id
                            temp_data.pos = pos
                            table_insert(v.pos_info, temp_data)
                        end
                    end
                    if v.old_order == nil then
                        v.old_order = v.order
                    end
                end
            end
        end

        self.crossarena_form_list_panel:setData(self.team_data_list)
        self.five_hero_vo = {}
        for k,v in pairs(self.team_data_list) do
            for _,info in pairs(v.pos_info or {}) do
                local hero_vo = model:getHeroById(info.id)
                if hero_vo then
                    hero_vo.is_ui_select = true
                end
            end
        end
        if self.list_view then
            self.list_view:resetCurrentItems()
        end
    else
        if self.crossarena_form_list_panel then
            self.team_data_list = self.crossarena_form_list_panel:getData()
        end
        if self.team_data_list[self.select_team_index] then
            self.form_panel:setVisible(true)
            self.form_list_panel:setVisible(false)
            self:initFormInfo(self.team_data_list[self.select_team_index])

            local old_order = self.team_data_list[self.select_team_index].old_order
            local cur_index = old_order or (self.select_team_index - 1)
            if self.elfin_team_data_list[cur_index + 1] then
                self:updateElfinList(self.elfin_team_data_list[cur_index + 1])
            end
        end
    end
end

--剧情布阵多队伍的form
function FormGoFightPanel:teamInitFormInfo(index, is_change_data)
    if not self.team_data_list then return end
    if not self.cur_tab_data then return end

    local cur_fun_form_type = self.cur_tab_data.fun_form_type
    if index == 1 then
        self.form_panel:setVisible(false)
        self.form_list_panel:setVisible(true)
        if not self.crossarena_form_list_panel then
            self.crossarena_form_list_panel = CorssarenaFormListPanel.New(self.form_list_panel, self, self.form_show_type, cur_fun_form_type)
        else
            self.crossarena_form_list_panel:setFunFormType(cur_fun_form_type)
        end

        local team_data_list = self.dic_more_team_data[self.cur_tab_data.fun_form_type]
        for i,v in ipairs(team_data_list) do
            if v.old_order == nil then
                v.old_order = v.order
            end
        end
        if not team_data_list then return end
        self.crossarena_form_list_panel:setData(team_data_list)
        for k,v in pairs(team_data_list) do
            local pos_info = v.pos_info or {}
            for _,info in pairs(pos_info) do
                local hero_vo = model:getHeroById(info.id)
                if hero_vo then
                    hero_vo.is_ui_select = true
                end
            end
        end
        if self.list_view then
            self.list_view:resetCurrentItems()
        end
    else
        if self.crossarena_form_list_panel then
            if is_change_data then
                local team_data_list = self.crossarena_form_list_panel:getData()
                -- local dic_pos_elfin = {}
                -- if self.elfin_team_data_list[self.select_team_index] then
                --     for i,v in pairs(self.elfin_team_data_list[self.select_team_index]) do
                --         dic_pos_elfin[i-1] = v
                --     end
                -- end
                for i,v in ipairs(team_data_list) do
                    local data = self.dic_more_team_data[self.cur_tab_data.fun_form_type][v.order]
                    if data and data.order == v.order then
                        for key,val in pairs(v) do
                            data[key] = val
                        end
                        -- if v.order ~= v.old_order then --说明那边变了队列
                        --     --精灵也要相应换位置
                        --     if self.elfin_team_data_list[self.select_team_index] then
                        --         self.elfin_team_data_list[self.select_team_index][v.order + 1] = dic_pos_elfin[v.old_order]
                        --     end
                        -- end
                        -- v.old_order = nil
                    end
                end
            end
            self.form_panel:setVisible(true)
            self.form_list_panel:setVisible(false)
            self.team_data_list[self.select_team_index] = self.dic_more_team_data[self.cur_tab_data.fun_form_type][index - 1]
            self.five_hero_vo[self.select_team_index] = nil

            if self.team_data_list[self.select_team_index] then
                self:initFormInfo(self.team_data_list[self.select_team_index])
            end
            if self.elfin_team_data_list[self.select_team_index] then
                -- sprites
                local old_order = self.team_data_list[self.select_team_index].old_order
                local cur_index = old_order or  (index - 1)
                if self.elfin_team_data_list[self.select_team_index][cur_index + 1] then
                    self:updateElfinList(self.elfin_team_data_list[self.select_team_index][cur_index + 1])
                end
            end
        end
    end
end

function FormGoFightPanel:initFormationData(formation_config)
    if not formation_config then return end
    -- self.dic_index_pos = {}
    -- self.dic_pos_index = {}
    local dic_pos_index = {}
    self.pos_name_list = {}
    self.pos_rect_list = {}
    local width = self.cell_width - 10
    for i,v in ipairs(formation_config.pos) do
        local index = v[1] 
        local pos = v[2] 
        -- self.dic_index_pos[index] = pos
        dic_pos_index[pos] = index
        -- self:updatePosItemByIndex(pos, index)
        --更新位置
        if self.hero_item_list[index] then
            self.hero_item_list[index]:setPosition(self.nine_position[pos])
        end
        if pos <= 3 then
            self.pos_name_list[index] = 1 --位置 前
        elseif pos > 3 and pos <= 6 then
            self.pos_name_list[index] = 2 --位置 中
        else
            self.pos_name_list[index] = 3 --位置 后
        end

        local x = self.nine_position[pos].x
        local y = self.nine_position[pos].y
        local rect = cc.rect( x - width*0.5 ,y - width*0.5 , width, width)
        self.pos_rect_list[index] = rect
    end

    --没使用的要变灰变暗
    local index = 1
    for pos=1,9 do
        if dic_pos_index[pos] == nil then
            self.four_blank_img[index]:setPosition(self.nine_position[pos])
            index = index + 1
            if index > 4 then
                break
            end
        end
    end
end

--更新阵法item
function FormGoFightPanel:updateFormationIcon()
    if not self.formation_type  then return end

    -- local res = PathTool.getResFrame("form", "form_icon_"..self.formation_type)
    local res = "res/resource/form/form_form_icon_"..self.formation_type..".png"
    loadSpriteTexture(self.form_icon, res, ccui.TextureResType.localType)
end

--更新神器item
function FormGoFightPanel:updateHallowsIcon()
    if not self.hallows_id  then return end
    if not self.hallows_item  then return end
    
    if self.hallows_id == 0 then
        self.hallows_item:setBaseData()
        self.hallows_item:setMagicIcon(false)
        self.hallows_item:showAddIcon(true)

        self.equip_btn_label:setString(TI18N("点击装配"))
    else
        local hallows_config = Config.HallowsData.data_base[self.hallows_id]
        if not hallows_config  then return end

        self.hallows_item:showAddIcon(false)
        local hallows_vo = HallowsController:getInstance():getModel():getHallowsById(self.hallows_id)
        if hallows_vo and hallows_vo.look_id ~= 0 then
            local magic_cfg = Config.HallowsData.data_magic[hallows_vo.look_id]
            if magic_cfg then
                self.hallows_item:setBaseData(magic_cfg.item_id)
                self.hallows_item:setMagicIcon(true)
            else
                self.hallows_item:setBaseData(hallows_config.item_id)
                self.hallows_item:setMagicIcon(false)
            end
        else
            self.hallows_item:setBaseData(hallows_config.item_id)
            self.hallows_item:setMagicIcon(false)
        end

        self.equip_btn_label:setString(TI18N("点击更换"))
    end
end

--更新5个宝可梦数据
function FormGoFightPanel:updateFiveHeroItem()
    self:setHeroIsSelect()
    for i,item in ipairs(self.hero_item_list) do
        if self.five_hero_vo[self.select_team_index] then
            if self.five_hero_vo[self.select_team_index][i] == nil then
                item:setData(nil)
            else
                item:setData(self.five_hero_vo[self.select_team_index][i])
            end    
        end
    end
    if self.list_view then
        self.list_view:resetCurrentItems()
    end
    self:updateFightPower()
end

function FormGoFightPanel:updateFightPower()
    if not self.five_hero_vo[self.select_team_index] then return end
    local power = 0
    for k,v in pairs(self.five_hero_vo[self.select_team_index]) do
        local p = v.power or 0
        power = power + p
    end
    --是否公会pvp
    local is_pvp = false
    if self.cur_tab_data and self.cur_tab_data.fun_form_type then
        is_pvp = model:isGuildPvpFrom(self.cur_tab_data.fun_form_type)
        local pvp_power = 0
        if is_pvp then
            local list = {}
            for k,v in pairs(self.five_hero_vo[self.select_team_index]) do
                if v.type and v.type ~= 0 then
                    table.insert(list, v.type)
                end
            end
            pvp_power = GuildskillController:getInstance():getModel():getPvpPowerByCareerlist(list)
        end
        if is_pvp and power > 0 and pvp_power > 0 then
            if self.pvp_arrow == nil  then
                self.pvp_arrow = createImage(self.power_click, PathTool.getResFrame("common","common_1086"), 0, 20, cc.p(0.5,0.5), true)
            else
                self.pvp_arrow:setVisible(true)
            end

            if self.show_pvp_tips == nil then
                self.show_pvp_tips = createLabel(20, cc.c3b(0x24,0x90,0x03), nil, 84, -12, TI18N("公会pvp属性战力提升"), self.power_click, nil, cc.p(0.5, 0.5))
            else
                self.show_pvp_tips:setVisible(true) 
            end
            power = power + pvp_power
        else
            --如果不满足条件默认是 不是pvp
            is_pvp = false
            if self.pvp_arrow then
                self.pvp_arrow:setVisible(false)
            end
            if self.show_pvp_tips then
                self.show_pvp_tips:setVisible(false)
            end
        end
    end
    
    self.cur_power = power
    power = changeBtValueForPower(power)
    self.fight_label:setNum(power)

    if is_pvp and self.pvp_arrow then
        --设置战力后需要重新显示一下新的位置
        local size = self.fight_label:getContentSize()
        local x = self.fight_label:getPositionX()

        self.pvp_arrow:setPositionX(x + size.width * 0.5 + 16) --16 箭头的宽度
    end
    --战力改变了说明光环也要变化一下
    self:calculateCampHaloType()
    -- 元素神殿需要变化条件提示颜色
    if self.fun_form_type == PartnerConst.Fun_Form.ElementWater 
        or self.fun_form_type == PartnerConst.Fun_Form.ElementFire
        or self.fun_form_type == PartnerConst.Fun_Form.ElementWind
        or self.fun_form_type == PartnerConst.Fun_Form.ElementLight
        or self.fun_form_type == PartnerConst.Fun_Form.ElementDark then
        self:updatePosTipsStatus()
    end
end

--计算阵型icon
function FormGoFightPanel:calculateCampHaloType()
    if not self.five_hero_vo[self.select_team_index] then return end
    local dic_camp = {}
    for i,v in pairs(self.five_hero_vo[self.select_team_index]) do
        if v.camp_type ~= nil then
            if dic_camp[v.camp_type] == nil then
                dic_camp[v.camp_type] = 1
            else
                dic_camp[v.camp_type] = dic_camp[v.camp_type] + 1
            end
        end
    end

    self.halo_form_id_list = BattleController:getInstance():getModel():getFormIdListByCamp(dic_camp)
    local halo_icon_config = BattleController:getInstance():getModel():getCampIconConfigByIds(self.halo_form_id_list)
    if halo_icon_config then
        local halo_res = PathTool.getCampGroupIcon(halo_icon_config.icon)
        self.halo_icon_load = loadImageTextureFromCDN(self.halo_btn, halo_res, ResourcesType.single, self.halo_icon_load)
        addCountForCampIcon(self.halo_btn, halo_icon_config.nums)
        self.halo_label:setString("")
        self:updateEffect(true, halo_res)
    else
        local halo_res = PathTool.getCampGroupIcon(1000)
        self.halo_icon_load = loadImageTextureFromCDN(self.halo_btn, halo_res, ResourcesType.single, self.halo_icon_load)
        addCountForCampIcon(self.halo_btn)
        self.halo_label:setString(TI18N("阵型"))
        self:updateEffect(false, halo_res)
    end
end
--播放特效
function FormGoFightPanel:updateEffect(status, halo_res)
    if status then
        if self.select == nil then
            local x, y = self.halo_btn:getPosition()
            --self.halo_effect = createSprite(halo_res, x, y, self.main_container, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
            self.select = createImage(self.form_panel, PathTool.getResFrame("common", "common_1101"), x, y, cc.p(0.5, 0.5), true)
            self.select:setScale(0.8)
        else
            --self.halo_effect:setVisible(true)
            self.select:setVisible(true)
        end

        --[[if self.hero_effect_res ~= halo_res then
            self.hero_effect_res = halo_res
            loadSpriteTexture(self.halo_effect, halo_res, LOADTEXT_TYPE_PLIST)
        end--]]

        --[[local scaleTo1 = cc.ScaleTo:create(0.8,0.92)
        local scaleTo2 = cc.ScaleTo:create(0.8,1.08)
        local sequence1 = cc.Sequence:create(scaleTo1, scaleTo2)
        local fadeTo1 = cc.FadeTo:create(0.8, 50)
        local fadeTo2 = cc.FadeTo:create(0.8, 150)
        local sequence2 = cc.Sequence:create(fadeTo1, fadeTo2)
        local spawn = cc.Spawn:create(sequence1, sequence2)--]]
        --self.halo_effect:runAction(cc.RepeatForever:create(spawn))

        local fadein = cc.FadeIn:create(0.6)
        local fadeout = cc.FadeOut:create(0.6)
        self.select:runAction(cc.RepeatForever:create(cc.Sequence:create(fadein, fadeout)))
    else
        if self.select then
            --doStopAllActions(self.halo_effect)
            doStopAllActions(self.select)
            --self.halo_effect:setVisible(false)
            self.select:setVisible(false)
        end
    end
end

-- 条件提示颜色变化
function FormGoFightPanel:updatePosTipsStatus(  )
    if self.setting.limit then
        if self:checkIsCanFight() then
            self.pos_tips:setTextColor(cc.c3b(36,144,3))
        else
            self.pos_tips:setTextColor(cc.c3b(201,38,6))
        end
    end
end

--创建宝可梦列表 
-- @select_camp 选中阵营
function FormGoFightPanel:updateHeroList(select_camp, must_reset)
    local select_camp = select_camp or 0
    if not must_reset and select_camp == self.select_camp then 
        return
    end
    if not self.list_view then
        local size = self.lay_scrollview:getContentSize()
        local scroll_view_size = cc.size(640, size.height)
        local setting = {
            -- item_class = HeroExhibitionItem,      -- 单元类
            start_x = 22,                  -- 第一个单元的X起点
            space_x = 0,                    -- x方向的间隔
            start_y = 4,                    -- 第一个单元的Y起点
            space_y = 0,                   -- y方向的间隔
            item_width = 120,               -- 单元的尺寸width
            item_height = 108,              -- 单元的尺寸height
            -- row = 1,                        -- 行数，作用于水平滚动类型
            col = 5,                         -- 列数，作用于垂直滚动类型
            need_dynamic = true
        }

        if self.fun_form_type == PartnerConst.Fun_Form.Planes then -- 位面冒险
            setting.space_y = 20
        end


        self.list_view = CommonScrollViewSingleLayout.new(self.lay_scrollview, cc.p(size.width * 0.5, size.height * 0.5) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0.5,0.5))

        self.list_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.list_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        -- self.list_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
    end
    
    self.select_camp = select_camp
     --宝可梦列表 (默认)
    local hero_array = model:getAllHeroArray()
    local vo = Array.New()
    
    local temp_power = 0
    for j=1,hero_array:GetSize() do
        local hero_vo = hero_array:Get(j-1)
        if select_camp == 0 or (select_camp == hero_vo.camp_type) then
            vo:PushBack(hero_vo)
        end
        if self.fun_form_type == PartnerConst.Fun_Form.EndLessLightDark and hero_vo and (hero_vo.camp_type == HeroConst.CampType.eLight or hero_vo.camp_type == HeroConst.CampType.eDark) then
            if hero_vo and temp_power < hero_vo.power then
                temp_power = hero_vo.power
            end
        elseif select_camp == 0 or (select_camp == hero_vo.camp_type) then
            if hero_vo and temp_power < hero_vo.power then
                temp_power = hero_vo.power
            end
        end
    end
    
    vo:UpperSortByParams("star","power","lev","sort_order")
    local show_list = vo.items
    
    if self.fun_form_type == PartnerConst.Fun_Form.Expedit_Fight then
        local employData = expedit_model:getExpeditEmployData()
        local partner_config = Config.PartnerData.data_partner_base

        --增加雇佣的宝可梦进入出征
        for i,v in pairs(employData) do
            v.partner_id = v.id
            v.camp_type = partner_config[v.bid].camp_type
            --支援的人物使用过之后就放到最后
            if v.is_used == 0 then
                table_insert(show_list,1,v)
            else
                table_insert(show_list,v)
            end
        end
    elseif self.fun_form_type == PartnerConst.Fun_Form.LimitExercise then
        -- local limitexercise_model = LimitExerciseController:getInstance():getModel()
        -- -- 宝可梦限制次数
        -- local hero_limit_count = 4
        -- local data_const = Config.HolidayBossNewData.data_const
        -- if data_const and data_const.partner_num then
        --     hero_limit_count = data_const.partner_num.val or 0
        -- end
        -- for i,v in pairs(show_list) do
        --     local _bool = limitexercise_model:isUpHero(v.bid)
        --     local double = 1
        --     if _bool then
        --         double = 2
        --     end
        --     v.double = double * hero_limit_count --是否双倍
        --     local count = limitexercise_model:getHeroUseId(v.partner_id)
        --     v.count = v.double - count --使用次数
        --     if v.count <= 0 then
        --         v.count = 0
        --     end
        --     local is_sort = v.double - count
        --     if is_sort <= 0 then
        --         is_sort = 0
        --     else
        --         is_sort = 1
        --     end
        --     v.is_sort = is_sort
        -- end
        -- local sort_func = SortTools.tableUpperSorter({"is_sort","star", "power", "lev", "sort_order"})
        -- table_sort(show_list, sort_func)

    elseif self.fun_form_type == PartnerConst.Fun_Form.EndLess or self.fun_form_type == PartnerConst.Fun_Form.EndLessWater or 
    self.fun_form_type == PartnerConst.Fun_Form.EndLessFire or self.fun_form_type == PartnerConst.Fun_Form.EndLessWind or 
    self.fun_form_type == PartnerConst.Fun_Form.EndLessLightDark then
        local list = self.setting.has_hire_list or {}
        local partner_config = Config.PartnerData.data_partner_base
        for i,v in ipairs(list) do
            if (temp_power and v.power <= temp_power*1.2) or self.fun_form_type == PartnerConst.Fun_Form.EndLess then
                local config  = partner_config[v.bid]
                if select_camp == 0 or (select_camp == config.camp_type) then
                    v.partner_id = v.id
                    v.camp_type = config.camp_type
                    v.is_endless = true --是否无尽试炼雇佣兵
                    table_insert(show_list,1,v)
                end
            end
        end   
    elseif self.fun_form_type == PartnerConst.Fun_Form.Planes then -- 位面冒险
        local partner_config = Config.PartnerData.data_partner_base
        local all_hero_list = PlanesafkController:getInstance():getModel():getAllPlanesHeroData() or {}
        show_list = {}
        for _,v in pairs(all_hero_list) do
            local config  = partner_config[v.bid]
            if select_camp == 0 or (select_camp == config.camp_type) then
                if v.flag == 1 then -- 雇佣的宝可梦
                    v.camp_type = config.camp_type
                    table_insert(show_list, v)
                else -- 自己的宝可梦
                    local hero_vo = model:getHeroById(v.partner_id)
                    if hero_vo then
                        table_insert(show_list, hero_vo)
                    end
                end
            end
        end
        local sort_func = SortTools.tableUpperSorter({"star","power","lev","flag"})
        table_sort(show_list, sort_func)
    end
    self.show_list = show_list
    -- local extendData = {scale = 0.9, can_click = true, from_type = _type, boold_type = true}
    self.list_view:reloadData()
    if #self.show_list == 0 then
        self.no_vedio_image:setVisible(true)
        self.no_vedio_label:setVisible(true)
        return
    else
        self.no_vedio_image:setVisible(false)
        self.no_vedio_label:setVisible(false)
    end
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function FormGoFightPanel:createNewCell(width, height)
    local cell = HeroExhibitionItem.new(0.9, true)
    if self.fun_form_type == PartnerConst.Fun_Form.Expedit_Fight then  --远征
        cell.from_type = HeroConst.ExhibitionItemType.eExpeditFight
        cell.boold_type = true
    elseif  self.fun_form_type == PartnerConst.Fun_Form.EndLess or self.fun_form_type == PartnerConst.Fun_Form.EndLessWater or 
    self.fun_form_type == PartnerConst.Fun_Form.EndLessFire or self.fun_form_type == PartnerConst.Fun_Form.EndLessWind or 
    self.fun_form_type == PartnerConst.Fun_Form.EndLessLightDark then -- 无尽试炼
        cell.from_type = HeroConst.ExhibitionItemType.eEndLessHero
    elseif self.fun_form_type == PartnerConst.Fun_Form.LimitExercise then  --试炼之境
        cell.from_type = HeroConst.ExhibitionItemType.eLimitExercise
    elseif self.fun_form_type == PartnerConst.Fun_Form.Planes then  --位面
        cell.from_type = HeroConst.ExhibitionItemType.ePlanes
    else --剧情布阵
        cell.from_type = HeroConst.ExhibitionItemType.eFormFight
    end
    cell:setLongTimeTouchEffect(true)
    cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end

--获取数据数量
function FormGoFightPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function FormGoFightPanel:updateCellByIndex(cell, index)
    cell.index = index
    local hero_vo = self.show_list[index]
    cell:setData(hero_vo)

    if self.fun_form_type == PartnerConst.Fun_Form.Adventure_Mine_Def then  --秘矿冒险
        if self.dic_mine_hero_list and self.dic_mine_hero_list[hero_vo.id] then
            cell:showStrTips(true,TI18N("防御中"),{c3b = cc.c3b(255,255,255)})
        else
            cell:showStrTips(false)
        end
    end
end

--点击cell .需要在 createNewCell 设置点击事件
function FormGoFightPanel:onCellTouched(cell)
    local index = cell.index
    local hero_vo = self.show_list[index]
    if hero_vo then
        self:selectHero(cell, hero_vo)
    end
end
--@hero_vo 宝可梦数据
function FormGoFightPanel:selectHero(item, hero_vo)
    --if not self.is_form_back then return end
    if not hero_vo  then return end
    if not item then return end
    if self.is_play_item_action then return end
    local tab_data = self.tab_list[self.select_team_index]

    --剧情多队伍的
    if self.fun_form_type == PartnerConst.Fun_Form.Drama and tab_data and 
        (tab_data.fun_form_type == PartnerConst.Fun_Form.CrossArenaDef or tab_data.fun_form_type == PartnerConst.Fun_Form.ArenapeakchampionDef) then
        if not self.team_select_team_index then return end
        if self.team_select_team_index == 1  then
            if self.crossarena_form_list_panel then
                self.crossarena_form_list_panel:onSelectHero(item, hero_vo)
            end
            return
        end
    end

    if (self.fun_form_type == PartnerConst.Fun_Form.CrossArena or 
        self.fun_form_type == PartnerConst.Fun_Form.CrossArenaDef or 
        self.fun_form_type == PartnerConst.Fun_Form.ArenapeakchampionDef) 
        and tab_data and tab_data.order == 0 and self.crossarena_form_list_panel then

        self.crossarena_form_list_panel:onSelectHero(item, hero_vo)
        return
    end

    if self.fun_form_type == PartnerConst.Fun_Form.Adventure_Mine_Def then  --秘矿冒险
        if self.dic_mine_hero_list and self.dic_mine_hero_list[hero_vo.id] then
            message(TI18N("已在别的秘矿防守阵容中"))
            return 
        end
    end

    if not self.five_hero_vo[self.select_team_index] then return end

    
    if self.fun_form_type == PartnerConst.Fun_Form.Expedit_Fight then
        local is_used = hero_vo.is_used or 0 --expedit_model:getHireHeroIsUsed(hero_vo.partner_id, hero_vo.rid, hero_vo.srv_id)
        if is_used == 1 then message(TI18N("雇佣的宝可梦只能使用一次哦")) return end

        --宝可梦死亡就不可能点击
        local blood = expedit_model:getHeroBloodById(hero_vo.partner_id, hero_vo.rid, hero_vo.srv_id)
        if blood <= 0 then return end
    elseif self.fun_form_type == PartnerConst.Fun_Form.Planes then -- 位面
        local hp_per = PlanesafkController:getInstance():getModel():getMyPlanesHeroHpPer(hero_vo.partner_id, hero_vo.flag)
        if hp_per <= 0 and not hero_vo.is_ui_select then
            message(TI18N("该宝可梦已阵亡"))
            return
        end
    end

    local dic_team_data, more_team_data = self:getDicTeamData(tab_data)
    local index = self:findHeroIndex(hero_vo, dic_team_data, more_team_data)
    if index ~= -1 then
        if self.hero_item_list[index] == nil then return end
        --是选中的 下阵了
        hero_vo.is_ui_select = false
        item:setSelected(hero_vo.is_ui_select)
        --结束位置 
        local world_pos = item:convertToWorldSpace(cc.p(HeroExhibitionItem.Width * 0.5, HeroExhibitionItem.Height * 0.5))    
        local end_pos = self.fight_hero_node:convertToNodeSpace(world_pos) 
        local x, y =  self.hero_item_list[index]:getPosition()

        self:showMoveEffect(cc.p(x,y), end_pos, hero_vo)
        self.hero_item_list[index]:setData(nil)
        -- self.hero_item_list[index]:showAddIcon(true)
        self.five_hero_vo[self.select_team_index][index] = nil
        self:updateMoreTeamHeroInfo()
        self:updateFightPower()

    else
        local count = 0
        for i,v in pairs(self.five_hero_vo[self.select_team_index]) do
            count = count + 1
        end
        if count >= 5 then
            message(TI18N("上阵人数已满"))
            return
        end

        if self.fun_form_type == PartnerConst.Fun_Form.Drama then
            if tab_data and hero_vo.checkResonateHeroByFormType and hero_vo:checkResonateHeroByFormType(tab_data.fun_form_type) then
                return 
            end
        elseif hero_vo.checkResonateHeroByFormType and hero_vo:checkResonateHeroByFormType(self.fun_form_type) then
            return 
        end

        --检查是否重复
        if self:checkSameHeroTips(hero_vo, dic_team_data, more_team_data, tab_data.fun_form_type) then
            return
        end
        
        --新增
        local new_index = self:getTheBestPos(hero_vo)
        if new_index == nil then
            message(TI18N("没有上阵位置"))
            return
        end

        local world_pos = item:convertToWorldSpace(cc.p(HeroExhibitionItem.Width * 0.5, HeroExhibitionItem.Height * 0.5))    
        local start_pos = self.fight_hero_node:convertToNodeSpace(world_pos) 
        local x, y =  self.hero_item_list[new_index]:getPosition()
        self:showMoveEffect(start_pos, cc.p(x,y), hero_vo, function()
            if self.hero_item_list and self.hero_item_list[new_index] then
                self.five_hero_vo[self.select_team_index][new_index] = hero_vo
                self.hero_item_list[new_index]:setData(self.five_hero_vo[self.select_team_index][new_index])
                -- self.hero_item_list[new_index]:showAddIcon(false)
                self:updateMoreTeamHeroInfo()
                self:updateFightPower()
            end
        end)
        hero_vo.is_ui_select = true
        item:setSelected(hero_vo.is_ui_select)
    end
end

--检查重复.然后有提示
function FormGoFightPanel:checkSameHeroTips(hero_vo, dic_team_data, more_team_data, fun_form_type)
    if more_team_data then
        --剧情多队伍
        for _,v in pairs(more_team_data) do
            local pos_info = v.pos_info or {}
            for k,info in pairs(pos_info) do
                local h_vo = model:getHeroById(info.id)
                if h_vo.bid == hero_vo.bid then
                    if v.order == (self.team_select_team_index - 1) then
                        message(TI18N("不能同时上阵2个相同宝可梦"))
                        return true
                    elseif not self:checkOtherCondition(h_vo, fun_form_type, more_team_data) then
                        message(TI18N("不能同时上阵3个同类宝可梦"))
                        return true
                    end
                end
            end
        end
    else
        for i,v in pairs(dic_team_data) do
            if self.five_hero_vo[i] then
                for k,h_vo in pairs(self.five_hero_vo[i]) do
                    if h_vo.bid == hero_vo.bid then
                        if self.fun_form_type == PartnerConst.Fun_Form.CrossArena or 
                            self.fun_form_type == PartnerConst.Fun_Form.CrossArenaDef or
                            self.fun_form_type == PartnerConst.Fun_Form.ArenapeakchampionDef then
                            if i == self.select_team_index then
                                message(TI18N("不能同时上阵2个相同宝可梦"))
                                return true
                            elseif not self:checkOtherCondition(h_vo) then
                                message(TI18N("不能同时上阵3个同类宝可梦"))
                                return true
                            end
                        else
                            if i == self.select_team_index then
                                message(TI18N("不能同时上阵2个相同宝可梦"))
                            else
                                message(TI18N("两支队伍中不可同时上阵2个相同的宝可梦"))
                            end
                            return true
                        end
                    end
                end
            end
        end
    end
end

--选择是否已在布阵上面的宝可梦
function FormGoFightPanel:findHeroIndex(hero_vo, dic_team_data, more_team_data)
    local team_index = 0
    local index = -1
    if more_team_data then
        --多队伍的 先从 本页面的宝可梦信息里面找
        local select_h_vo = nil
        local cur_order = (self.team_select_team_index - 1)
        for k,h_vo in pairs(self.five_hero_vo[self.select_team_index]) do
            if (h_vo.partner_id == hero_vo.partner_id) and (h_vo.rid == hero_vo.rid) and (h_vo.srv_id == hero_vo.srv_id) then
                index = k
                break
            end
        end

        if index == -1  then
            --没有找到再从 多队伍其他位置上面找
            for _,v in pairs(more_team_data) do
                local pos_info = v.pos_info or {}
                if v.order ~= cur_order then 
                    for k,info in pairs(pos_info) do
                        local h_vo = model:getHeroById(info.id)
                        if h_vo and (h_vo.partner_id == hero_vo.partner_id) and (h_vo.rid == hero_vo.rid) and (h_vo.srv_id == hero_vo.srv_id) then
                            team_index = v.order
                            select_h_vo = h_vo
                        end
                    end
                end
            end
        end
        
        if team_index ~= 0 and cur_order ~= 0 and cur_order ~= team_index then
            self:onClickTeamTabBtn(team_index + 1, true) 
            if select_h_vo then
                for i,v in pairs(self.five_hero_vo[self.select_team_index]) do
                    if v.id == select_h_vo.id then --寻找在其他队伍中 对应 位置index
                        index = i 
                    end
                end
            end
        end
        
    else
        for i,v in pairs(dic_team_data) do
            if self.five_hero_vo[i] then
                for k,h_vo in pairs(self.five_hero_vo[i]) do
                    if (h_vo.partner_id == hero_vo.partner_id) and (h_vo.rid == hero_vo.rid) and (h_vo.srv_id == hero_vo.srv_id) then
                        team_index = i
                        index = k
                        break
                    end
                end
            end
        end
        if team_index ~= 0 and self.select_team_index ~= team_index then
            self:changeTabType(team_index)
        end
    end
    return index
end

-- 根据 partner_id 选择/取消某一宝可梦
function FormGoFightPanel:getCellHeroItemByPartnerId( partner_id )
    if self.list_view then
        local item_list = self.list_view:getActiveCellList() or {}
        for i,item in ipairs(item_list) do
            local hero_vo = item:getData()
            if hero_vo.partner_id == partner_id then
                return item
            end
        end
    end
end

function FormGoFightPanel:getTheBestPos(hero_vo)
    if not self.five_hero_vo[self.select_team_index] then return end
    if hero_vo.pos_type == 1 then
        --1的默认是从1 找到3
    elseif hero_vo.pos_type == 3 then
        local lenght = #self.pos_name_list
        --从3往2往1找
        for i=lenght , 1, -1 do
            if self.five_hero_vo[self.select_team_index][i] == nil then
                return i
            end 
        end
    else --中间位置的
        --先找2的
        for i,pos in ipairs(self.pos_name_list) do
            if pos == hero_vo.pos_type then
                if self.five_hero_vo[self.select_team_index][i] == nil then
                    return i
                end 
            end
        end
    end
    --上面没有从1 找到3
    for i,v in ipairs(self.pos_name_list) do
        if self.five_hero_vo[self.select_team_index][i] == nil then
            return i
        end 
    end
    return nil
end

--显示移动效果
--@start_pos 开始位置 
--@end_pos 结束位置
function FormGoFightPanel:showMoveEffect(start_pos, end_pos, hero_vo, callback)
    self.is_play_item_action = true
    if self.move_hero_item == nil then
        self.move_hero_item = HeroExhibitionItem.new(0.9, false)
        self.fight_hero_node:addChild(self.move_hero_item, 1)
    end
    self.move_hero_item:setData(hero_vo)
    self.move_hero_item:setPosition(start_pos)
    local action1 = cc.MoveTo:create(0.2, end_pos)
    local callfunc = cc.CallFunc:create(function()
        if self.move_hero_item then
            self.move_hero_item:setPosition(-10000, 0)
        end
        self.is_play_item_action = false
        if callback then
            callback()
        end
    end)
    self.move_hero_item:runAction(cc.Sequence:create(action1,callfunc))
end

--添加倒计时 目前矿战布阵用
function FormGoFightPanel:addDownTime( )
    if not self.setting then return end
    if not self.setting.end_time then return end
    local time = self.setting.end_time - GameNet:getInstance():getTime()
    
    if self.down_time == nil then 
        local x, y = self.pos_tips:getPosition()
        self.down_time = createLabel(20,cc.c4b(0xff,0x00,0x00,0xff),nil,x, y,"",self.fight_hero_node,nil, cc.p(0.5,0.5))
        self.pos_tips:setVisible(false)
    end

    local callback = function(time) self:setTimeFormatString(time) end
    commonCountDownTime(self.down_time, time, {callback = callback})
end

function FormGoFightPanel:setTimeFormatString(time)
    if time <= 0 then
        if self.fun_form_type == PartnerConst.Fun_Form.EliteMatch then --段位赛
            --标志意外关闭的 ps: 进入战斗后,再关闭此界面. 如果没有此标志, baseview 会把上一级的界面显示出来 --by lwc
            self.close_by_other = true
        end
        self:onClickCloseBtn()
    else
        if self.fun_form_type == PartnerConst.Fun_Form.Adventure_Mine_Def then --矿战
            self.down_time:setString(string_format(TI18N("%s秒后自动放弃占领"), time))
        elseif self.fun_form_type == PartnerConst.Fun_Form.EliteMatch then --段位赛
            self.down_time:setString(string_format(TI18N("%s秒后自动进入战斗"), time))
        end
    end
end


function FormGoFightPanel:close_callback()
    doStopAllActions(self.background)
    doStopAllActions(self.form_panel)
    if self.down_time then
        doStopAllActions(self.down_time)
        self.down_time = nil
    end
    if self.halo_icon_load then
        self.halo_icon_load:DeleteMe()
        self.halo_icon_load = nil
    end
    if self.fight_label then
        self.fight_label:DeleteMe()
    end
    self.fight_label = nil
    if self.list_view then 
        self.list_view:DeleteMe()
        self.list_view = nil
    end
    if self.tab_btn_list_view then 
        self.tab_btn_list_view:DeleteMe()
        self.tab_btn_list_view = nil
    end
    if self.crossarena_form_list_panel then
        self.crossarena_form_list_panel:DeleteMe()
        self.crossarena_form_list_panel = nil
    end
    if self.hero_item_list then
        for i,v in ipairs(self.hero_item_list) do
            v:DeleteMe()
        end
        self.hero_item_list = {}
    end
    --清空选中状态

    if self.fun_form_type == PartnerConst.Fun_Form.Planes then -- 位面冒险
        local all_hero_list = PlanesafkController:getInstance():getModel():getAllPlanesHeroData()
        for _,v in pairs(all_hero_list) do
            v.is_ui_select = nil
        end
    elseif self.fun_form_type == PartnerConst.Fun_Form.EndLess or self.fun_form_type == PartnerConst.Fun_Form.EndLessWater or 
    self.fun_form_type == PartnerConst.Fun_Form.EndLessFire or self.fun_form_type == PartnerConst.Fun_Form.EndLessWind or 
    self.fun_form_type == PartnerConst.Fun_Form.EndLessLightDark then -- 无尽冒险
        local list = self.setting.has_hire_list or {}
        for i,v in ipairs(list) do
            v.is_ui_select = nil
        end   
    end
    
    local hero_list = model:getHeroList()
    for k, hero_vo in pairs(hero_list) do
        hero_vo.is_ui_select = nil
    end
    
    if self.hallows_item then
        self.hallows_item:DeleteMe()
        self.hallows_item = nil
    end
    for k, item in pairs(self.elfin_item_list) do
        item:DeleteMe()
        item = nil
    end

    if self.fun_form_type and self.fun_form_type == PartnerConst.Fun_Form.Adventure_Mine_Def then
        controller:openAdventureMineFormGoFightPanel(false)
    elseif self.fun_form_type and self.fun_form_type == PartnerConst.Fun_Form.Adventure_Mine then
        SysEnv:getInstance():set(SysEnv.keys.adventure_mine_skip_fight, self.is_skip_fight, true)
        controller:openFormGoFightPanel(false)
    else
        controller:openFormGoFightPanel(false)
    end
end



---form_go_fight_tab_btn
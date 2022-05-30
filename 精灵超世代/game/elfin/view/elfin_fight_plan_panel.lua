-------------------------------
-- @Author: lwc
-- @Date:   2020年3月17日
-- @Description:   精灵出战管理方案
-------------------------------
ElfinFightPlanPanel = ElfinFightPlanPanel or BaseClass(BaseView)

local _controller = ElfinController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format
local _table_insert = table.insert
local _table_sort = table.sort

function ElfinFightPlanPanel:__init()
    self.is_full_screen = false
    self.layout_name = "elfin/elfin_fight_plan_panel"
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG

    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("elfin", "elfin"), type = ResourcesType.plist},
    }

    self.plan_data = nil  -- 所有套装数据
    self.cur_elfin_item_list = {} -- 当前宝可梦的神装item
    self.role_vo = RoleController:getInstance():getRoleVo()

    --是否改名
    self.is_change_name = false
end

function ElfinFightPlanPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 1)
    self.main_container_size = self.main_container:getContentSize()
    self.main_container:getChildByName("wnd_title"):setString(TI18N("方案管理"))
    self.main_container:getChildByName("txt_tips"):setString(TI18N("点击方案中的精灵技能可进行编辑"))
    self.txt_cur_name = self.main_container:getChildByName("txt_cur_name")
    self.txt_cur_name:setString(TI18N("无方案"))

    self.close_btn = self.main_container:getChildByName("close_btn")
    self.btn_save = self.main_container:getChildByName("btn_save")
    self.btn_save:getChildByName("label"):setString(TI18N("保存为方案"))

    self.btn_disarm = self.main_container:getChildByName("btn_disarm")
    self.btn_disarm:getChildByName("label"):setString(TI18N("调 整"))

    self.cost_txt = self.main_container:getChildByName("cost_txt")
    self.cost_txt:setString("")
    self:updateCostInfo()

    local max_width = 580
    local item_width = max_width / 4
    local start_x = (self.main_container_size.width - max_width) * 0.5 + item_width * 0.5
    for i=1,4 do
        local skill_item = SkillItem.new(true, true, false, 0.8, true)
        -- local item = BackPackItem.new(false,true,nil,0.8, false)
        skill_item:addCallBack(function() self:onClikElfinItemIndex(i) end)
        skill_item:setPosition(start_x + (i-1)*item_width, 785)
        skill_item:showLevel(false)
        self.main_container:addChild(skill_item)
        self.cur_elfin_item_list[i] = skill_item
    end
end

function ElfinFightPlanPanel:updatePlanList( )
    if self.plan_scrollview == nil then
        local plan_list = self.main_container:getChildByName("plan_list")
        local scroll_view_size = plan_list:getContentSize()
        local setting = {
            start_x = 0,                  -- 第一个单元的X起点
            space_x = 0,                    -- x方向的间隔
            start_y = 0,                    -- 第一个单元的Y起点
            space_y = 0,                   -- y方向的间隔
            item_width = 606,               -- 单元的尺寸width
            item_height = 170,              -- 单元的尺寸height
            row = 0,                        -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            need_dynamic = true
        }
        self.plan_scrollview = CommonScrollViewSingleLayout.new(plan_list, cc.p(0, 0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))
        self.plan_scrollview:setSwallowTouches(false)

        self.plan_scrollview:registerScriptHandlerSingle(handler(self,self._createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.plan_scrollview:registerScriptHandlerSingle(handler(self,self._numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.plan_scrollview:registerScriptHandlerSingle(handler(self,self._updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end

    self.plan_scrollview:reloadData(nil, nil, true) --保持当前列表位置
end

function ElfinFightPlanPanel:_createNewCell(width, height)
    local cell = ElfinFightPlanItem.new(width, height, self)
    -- cell:setExtendData(self.hero_vo)
    return cell
end

function ElfinFightPlanPanel:_numberOfCells()
    if not self.plan_data then return 0 end
    return #self.plan_data
end

function ElfinFightPlanPanel:_updateCellByIndex(cell, index)
    if not self.plan_data then return end
    cell.index = index
    local cell_data = self.plan_data[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function ElfinFightPlanPanel:register_event()
    registerButtonEventListener(self.background, function() _controller:openElfinFightPlanPanel(false) end, true, 2)
    registerButtonEventListener(self.close_btn, function()  _controller:openElfinFightPlanPanel(false) end, true, 2)
    registerButtonEventListener(self.btn_save, handler(self, self.onSaveSuitsPlan), true, 1)
    registerButtonEventListener(self.btn_disarm, handler(self, self.onDisarmAllEquip), true, 1)

    self:addGlobalEvent(ElfinEvent.Elfin_Plan_Info_Event, function()
        self:updateElfinPlanData()
    end)
    
    if self.role_vo_update_event == nil then
        self.role_vo_update_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value) 
            if key == "gold" then
                self:updateCostInfo(value)
            end
        end)
    end
    --布阵保存
    self:addGlobalEvent(ElfinEvent.Elfin_Plan_From_Info_Event, function (data)
        local fun_form_type = self.fun_form_type
         if fun_form_type ==  PartnerConst.Fun_Form.EliteMatch then
            if self.match_type == 2 then --段位赛的王者赛 特殊处理
                fun_form_type = PartnerConst.Fun_Form.EliteKingMatch
            end
        end

        if fun_form_type and fun_form_type == data.type then
            self.total_team_info = data.team_list
            local team_index = self.team_index or 1
            
            for i,v in ipairs(data.team_list) do
                if v.team == team_index then
                    self.cur_plan_data = v
                    self:updatePlanzInfo() --更新之前的使用中
                    self.plan_id = v.plan_id
                    self:updatePlanzInfo() --更新之后的使用中
                    self:initCurElfinName()
                    self:updateCurElfinItemList()
                    break
                end
            end
            self:initFilterInfo(data)
        end
    end)
    --古树保存
    self:addGlobalEvent(ElfinEvent.Get_Elfin_Tree_Data_Event, function (data)
        self.cur_plan_data = _model:getElfinTreeData()
        self:updateCurElfinItemList()
    end)

    --更新信息
    self:addGlobalEvent(ElfinEvent.Elfin_Plan_Update_Event, function (data)
        if not data then return end
        local count = _model:getPlanCount()
        local cur_count = self:_numberOfCells()
        local max_count = Config.SpriteData.data_elfin_plan_length
        if cur_count == count then
            if count == max_count then
                if self.plan_data[max_count].is_open == nil then
                    --说明玩家格子已经全部开了 只需要更新就好
                    if self.plan_scrollview then
                        self.plan_scrollview:resetItemByIndex(data.id)
                    end
                else
                    self:initElfinData()
                    self:updatePlanList()
                end
            else
                self:initElfinData()
                self:updatePlanList()
            end
        else
            if self.plan_scrollview then
                self.plan_scrollview:resetItemByIndex(data.id)
            end
        end
        
        if  self.fun_form_type then
            _controller:send26555(self.fun_form_type)
        end
    end)
end

function ElfinFightPlanPanel:updatePlanzInfo()
    if self.plan_scrollview and self.plan_id ~= nil and self.plan_id ~= 0 then
        self.plan_scrollview:resetItemByIndex(self.plan_id)
    end
end

--刷新当前钻石数量
function ElfinFightPlanPanel:updateCostInfo(value)
    if value == nil then
        if self.role_vo and self.role_vo.gold then
            local gold = self.role_vo.gold
            self.cost_txt:setString(MoneyTool.GetMoneyString(gold))
        end
    else
        if self.cost_txt then
            self.cost_txt:setString(MoneyTool.GetMoneyString(value))
        end
    end
end

--保存为方案
function ElfinFightPlanPanel:onSaveSuitsPlan()
    if not self.cur_plan_data then return end
    if not self.cur_plan_data.sprites then return end

    local is_null = true
    for i,v in ipairs(self.cur_plan_data.sprites) do
        if v.item_bid ~= 0 then
            is_null = false
            break
        end
    end
    if is_null then
        message(TI18N("抱歉，列表为空不允许保存为方案"))
        return
    end
    local setting = {}
    setting.sprites = self.cur_plan_data.sprites
    setting.plan_data = self.plan_data
    setting.fun_form_type = self.fun_form_type
    setting.team_index = self.team_index
    _controller:openElfinFightPlanChooseTips(true, setting)
end

function ElfinFightPlanPanel:onClikElfinItemIndex()
    self:onDisarmAllEquip()
end

--一调整
function ElfinFightPlanPanel:onDisarmAllEquip()
    if not self.cur_plan_data then return end
    if not self.cur_plan_data.sprites then return end
    local setting = {}
    setting.from_type = 2

    --古树解锁下一个后..后端并没有把数据放到sprite里面..所以每次前端都需要根据古树那边解锁情况 来初始化位置
    local dic_sprites = {}
    for i,v in ipairs(self.cur_plan_data.sprites) do
        dic_sprites[v.pos] = v
    end
    for i=1,4 do
        local item_bid = _model:getElfinItemByPos(i)
        if item_bid and dic_sprites[i] == nil then
            dic_sprites[i] = {pos = i, item_bid = 0}
        end 
    end
    setting.sprites = {}
    for k,v in pairs(dic_sprites) do
        _table_insert(setting.sprites, v)
    end
    
    setting.dic_filter_item_id = self.dic_filter_item_id
    setting.callback = function(elfin_list)
        self:saveElfinlist(elfin_list)
    end
    _controller:openElfinAdjustWindow(true, setting)
end

function ElfinFightPlanPanel:saveElfinlist( elfin_list)
    if self.fun_form_type then
        local team_index = self.team_index or 1
        local fun_form_type = self.fun_form_type
        if self.fun_form_type ==  PartnerConst.Fun_Form.EliteMatch then
            if self.match_type == 2 then --段位赛的王者赛要过滤
                fun_form_type = PartnerConst.Fun_Form.EliteKingMatch
            end
        end
        _controller:send26560(fun_form_type, elfin_list, team_index)
    else
        --如果么有布阵类型 默认是古树上面的
        _controller:sender26514(elfin_list)
    end
end

--多队伍里面因为保存的问题.导致过滤条件有变化
function ElfinFightPlanPanel:initFilterInfo(data)
    if self.fun_form_type == data.type then
        if self.fun_form_type == PartnerConst.Fun_Form.CrossArenaDef or 
            self.fun_form_type == PartnerConst.Fun_Form.CrossArena or 
            self.fun_form_type == PartnerConst.Fun_Form.ArenapeakchampionDef or 
            self.fun_form_type == PartnerConst.Fun_Form.HeavenBoss then
            self.dic_filter_item_id = {}
            for i,v in ipairs(data.team_list) do
                if v.team ~= self.team_index then
                    for _,team_data in ipairs(v.sprites) do
                        if self.dic_filter_item_id[team_data.item_bid] == nil then
                            self.dic_filter_item_id[team_data.item_bid] = 1
                        else
                            self.dic_filter_item_id[team_data.item_bid] = self.dic_filter_item_id[team_data.item_bid] + 1
                        end
                    end
                    
                end
            end
        elseif self.fun_form_type ==  PartnerConst.Fun_Form.EliteMatch then
            if self.match_type == 2 then --段位赛的王者赛要过滤
                self.dic_filter_item_id = {}
                for i,v in ipairs(data.team_list) do
                    if v.team ~= self.team_index then
                        for _,team_data in ipairs(v.sprites) do
                            if self.dic_filter_item_id[team_data.item_bid] == nil then
                                self.dic_filter_item_id[team_data.item_bid] = 1
                            else
                                self.dic_filter_item_id[team_data.item_bid] = self.dic_filter_item_id[team_data.item_bid] + 1
                            end
                        end
                        
                    end
                end
            end
        end
    end
end


--seting.cur_plan_data 当前在上方的布阵信息 结构参考 26555 单个结构
function ElfinFightPlanPanel:openRootWnd(setting)
    self.setting = setting or {}
    self.cur_plan_data = self.setting.cur_plan_data or {}
    self.total_team_info = self.setting.total_team_info or {}
    self.plan_id = self.cur_plan_data.plan_id
    self.dic_filter_item_id =  self.setting.dic_filter_item_id or {}
    self.fun_form_type = self.setting.fun_form_type
    self.team_index = self.setting.team_index
    --段位赛的信息
    self.match_type = self.setting.match_type

    --获取神装套装信息 --不能缓存
    -- local data = _model:getPlanData()
    -- if data then
    --     self:updateElfinPlanData(data)
    -- else
        _controller:send26556() 
    -- end
end




function ElfinFightPlanPanel:updateElfinPlanData(data)
    self:initElfinData(data)
    self:initCurElfinName()
    self:updateCurElfinItemList()
    self:updatePlanList()
end

function ElfinFightPlanPanel:initElfinData(data)
    local data = data
    if data == nil then
        data = _model:getPlanData()
    end
    self.plan_data = {} --所有套装数据
    for id, v in pairs(data) do
        _table_insert(self.plan_data, v)
    end
    _table_sort(self.plan_data, SortTools.KeyLowerSorter("id"))
    local cell_num = #self.plan_data
    local config = Config.SpriteData.data_elfin_plan[cell_num + 1]
    if config then
        local lock_data = {}
        lock_data.is_open = 0
        lock_data.config = config
        _table_insert(self.plan_data, lock_data)
    end
end

--初始化宝可梦当前装配的方案名
function ElfinFightPlanPanel:initCurElfinName()
    if not self.plan_data then return end
    local name_str = TI18N("无方案")
    if self.cur_plan_data and self.cur_plan_data.plan_id then
        for k,v in pairs(self.plan_data) do
            if v.id == self.cur_plan_data.plan_id then
                name_str = _string_format(TI18N("已使用方案【%s】"), v.name)
            end
        end
    end
    self.txt_cur_name:setString(name_str)
end

--更新神装item显示
function ElfinFightPlanPanel:updateCurElfinItemList()
    if not self.cur_plan_data then return end
    if not self.cur_plan_data.sprites then return end
    local dic_item_pos = {}
    local is_not_have = true
    for i,v in ipairs(self.cur_plan_data.sprites) do
        dic_item_pos[v.pos] = v.item_bid
        if v.item_bid ~= 0 then
            is_not_have = false
        end
    end
    for pos,skill_item in ipairs(self.cur_elfin_item_list) do
        local item_bid = _model:getElfinItemByPos(pos)
        if item_bid then
            local bid = dic_item_pos[pos] or 0
            local elfin_cfg = Config.SpriteData.data_elfin_data(bid)
            if bid == 0 or not elfin_cfg then
                skill_item:setData()
                skill_item:showLevel(false)
                skill_item:showName(false)
            else
                local skill_cfg = Config.SkillData.data_get_skill(elfin_cfg.skill)
                if skill_cfg then
                    skill_item:showLevel(true)
                    skill_item:setData(skill_cfg)
                    -- skill_item:showName(true,skill_cfg.name, nil,nil,true)
                    skill_item:showName(true,skill_cfg.name,nil,20,true,nil,nil,cc.size(110,26))
                end
            end
        else
            skill_item:setData()
            skill_item:showLevel(false)
            skill_item:showLockIcon(true)
            skill_item:showName(false)
        end
    end

    if is_not_have then
        if self.show_tips_label == nil then
            self.show_tips_label = createRichLabel(22, cc.c3b(0x95,0x53,0x22), cc.p(0.5, 0.5), cc.p(self.main_container_size.width * 0.5, 730))
            self.show_tips_label:setString(TI18N("请先上阵精灵"))
            self.main_container:addChild(self.show_tips_label)
        else
            self.show_tips_label:setVisible(true)
        end
    else
        if self.show_tips_label then
            self.show_tips_label:setVisible(false)
        end
    end
end

function ElfinFightPlanPanel:close_callback()

    if self.role_vo_update_event ~= nil then
        if self.role_vo then
            self.role_vo:UnBind(self.role_vo_update_event)
        end
        self.role_vo_update_event = nil
    end

    if self.plan_scrollview then
        self.plan_scrollview:DeleteMe()
        self.plan_scrollview = nil
    end
    for k,v in pairs(self.cur_elfin_item_list) do
        v:DeleteMe()
        v = nil
    end
    _controller:openElfinFightPlanPanel(false)
end

-------------------------------
-- @Author: lwc
-- @Date:   2020年3月17日
-- @Description:   精灵方案item
-------------------------------
ElfinFightPlanItem = class("ElfinFightPlanItem", function()
    return ccui.Widget:create()
end)

function ElfinFightPlanItem:ctor(width, height, parent)
    self.parent = parent
    self:config(width, height)
    self:layoutUI()
    self:registerEvents()
end

function ElfinFightPlanItem:config(width, height)
    self.size = cc.size(width, height)
    self:setContentSize(self.size)
    
    self.equip_item_list = {} --装备item列表
end

function ElfinFightPlanItem:layoutUI()
    local csbPath = PathTool.getTargetCSB("elfin/elfin_fight_plan_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    self.main_container = self.root_wnd:getChildByName("main_container")

    
    self.txt_title = self.main_container:getChildByName("txt_title")
    self.btn_write = self.main_container:getChildByName("btn_write")
    self.btn_write:setTouchEnabled(true)
    self.btn_load = self.main_container:getChildByName("btn_load")
    self.btn_load:setVisible(false)
    self.btn_load_lable = self.btn_load:getChildByName("label")
    self.btn_load_lable:setString(TI18N("装配"))

    self.btn_open = self.main_container:getChildByName("btn_open")
    local btn_size = self.btn_open:getContentSize()
    self.btn_open_label = createRichLabel(24, Config.ColorData.data_new_color4[1], cc.p(0.5, 0.5), cc.p(btn_size.width/2, btn_size.height/2))
    self.btn_open:addChild(self.btn_open_label)
    self.txt_open_desc = self.main_container:getChildByName("txt_open_desc")
    self.txt_open_desc:setString(TI18N("花费钻石开启此方案"))

    self.elfin_item_list = {}
    local item_width = 112
    local start_x = 75
    for i=1,4 do
        local skill_item = SkillItem.new(true, true, false, 0.8, true)
        skill_item:setPosition(start_x + (i-1)*item_width, 66)
        skill_item:setClickInfo({clickScroll = true})
        skill_item:addCallBack(function() self:onClickSkillItem()  end)
        self.main_container:addChild(skill_item)
        self.elfin_item_list[i] = skill_item
    end
end

function ElfinFightPlanItem:registerEvents()
    registerButtonEventListener(self.btn_write, handler(self, self.onChangePlanName), true, 1)
    registerButtonEventListener(self.btn_load, handler(self, self.onLoadSuitsPlan), true, 1)
    registerButtonEventListener(self.btn_open, handler(self, self.onOpenHolyPlan), true, 1)
end

--修改方案名称
function ElfinFightPlanItem:onChangePlanName()
    if isQingmingShield and isQingmingShield() then
        return
    end
    if not self.data  then return end
    local function cancel_callback() 
        if self.alert then
            self.alert:close()
            self.alert = nil
        end
    end
    local function confirm_callback(str)
        if str == nil or str == "" then
            message(TI18N("方案名称不合法"))
            return
        end
        local text = string.gsub(str, "\n", "")
        if text then

            _controller:send26558(self.data.id, text)
            if self.alert then
                self.alert:close()
                self.alert = nil
            end
        end
    end
    self.alert = CommonAlert.showInputApply("", TI18N("方案名最多6个字"), TI18N("确 定"), 
        confirm_callback, TI18N("取 消"), cancel_callback, true, cancel_callback, 22, CommonAlert.type.rich, FALSE,
        cc.size(307, 50), 6, {off_x=15, off_y=-15})
    local label = createLabel(26,Config.ColorData.data_color4[175],nil,55,75,TI18N("方案名："),self.alert.alert_panel)
end

--给当前宝可梦装配当前方案
function ElfinFightPlanItem:onLoadSuitsPlan()
    if not self.parent then return end
    local cur_plan_data = self.parent.cur_plan_data
    if cur_plan_data and cur_plan_data.plan_id == self.data.id then
        message("该方案已装配")
        return
    end
    --记录为置灰的 就是空方案
    if self.is_gray then
        message("为空的方案不允许装配")
        return
    end
    local fun_form_type = self.parent.fun_form_type or 0    
    local team_index = self.parent.team_index or 0
    if fun_form_type == 0 and team_index == 0 then
        --说明是古树那边的
        _controller:sender26514(self.data.plan_sprites)
    else
        local status = SysEnv:getInstance():getBool(SysEnv.keys.elfin_plan_save_tip, false)
        if status then
            self:sendSaveProto()
        else
            local is_show_tip, same_list = self:checkSaveTips()
            if is_show_tip then
                local setting = {}
                setting.same_list = same_list
                setting.callback = function() self:sendSaveProto() end
                --确认是否卸下指定方案的装备并覆盖
                _controller:openElfinFightPlanSaveTips(true, setting)
            else
                self:sendSaveProto()
            end
        end
    end
end

--发送保存的协议
function ElfinFightPlanItem:sendSaveProto()
    local fun_form_type = self.parent.fun_form_type or 0    
    local team_index = self.parent.team_index or 0

    if fun_form_type ==  PartnerConst.Fun_Form.EliteMatch then
        if self.parent.match_type == 2 then --段位赛的王者赛要过滤
            fun_form_type = PartnerConst.Fun_Form.EliteKingMatch
        end
    end
    _controller:send26561(self.data.id, fun_form_type, team_index, self.data.plan_sprites)
end

--检查是否需要提示装配tips
function ElfinFightPlanItem:checkSaveTips()
    local fun_form_type = self.parent.fun_form_type or 0    
    local team_index = self.parent.team_index or 0

    if fun_form_type == PartnerConst.Fun_Form.CrossArenaDef or 
        fun_form_type == PartnerConst.Fun_Form.CrossArena or 
        fun_form_type == PartnerConst.Fun_Form.ArenapeakchampionDef or 
        fun_form_type == PartnerConst.Fun_Form.HeavenBoss then

        local total_team_info = self.parent.total_team_info or {}
        local cur_plan_data = self.parent.cur_plan_data or {}
        local same_list  = self:getCheckSameItemBid(total_team_info, cur_plan_data)
        if next(same_list) ~= nil then
            return true , same_list
        end
    elseif fun_form_type == PartnerConst.Fun_Form.EliteMatch  then
        local match_type = self.parent.match_type or 1
        if match_type == 2 then
            local total_team_info = self.parent.total_team_info or {}
            local cur_plan_data = self.parent.cur_plan_data or {}
            local same_list  = self:getCheckSameItemBid(total_team_info, cur_plan_data)
            if next(same_list) ~= nil then
                return true , same_list
            end
        end
    end
    return false
end
--获取重复bid信息
function ElfinFightPlanItem:getCheckSameItemBid(total_team_info, cur_plan_data)
    if not self.dic_item_pos then return {} end
    local same_list = {}
    local list = {}
    for k,v in pairs(total_team_info) do
        _table_insert(list, v)
    end
    _table_sort(list, function(a,b) return a.team < b.team end)

    --记录使用的精灵id dic_item_use[bid] = count
    dic_item_use = {}
    local team = cur_plan_data.team
    for __,bid in pairs(self.dic_item_pos) do
        if bid ~= 0 then
            for _,team_data in ipairs(list) do
                if team ~= team_data.team then
                    for i,v in ipairs(team_data.sprites) do
                        if v.item_bid == bid then
                            if dic_item_use[bid] == nil then
                                dic_item_use[bid] = 0
                            end
                            local pos = _model:getElfinTreeByBid(bid)
                            local count = BackpackController:getInstance():getModel():getBackPackItemNumByBid(bid) or 0
                            if pos ~= nil then
                                count = count + 1
                            end
                            if (count - dic_item_use[bid]) <= 1 then
                                --说明不够
                                local data = {}
                                data.team = team_data.team --记录队伍索引
                                data.item_bid = v.item_bid
                                _table_insert(same_list, data)
                            else
                                dic_item_use[bid] = dic_item_use[bid] + 1
                            end
                        end
                    end
                end
            end
        end
    end
    return same_list
end

--购买方案格子
function ElfinFightPlanItem:onOpenHolyPlan()
    if not self.data  then return end
    if not self.data.config  then return end
    local role_vo = RoleController:getInstance():getRoleVo()
    if not role_vo then return end
    local cur_gold = role_vo.gold
    local cost = self.data.config.expend
    if cost and cost[1] then
        local bid = cost[1][1]
        local num = cost[1][2]
        if cur_gold >= num then
            local item_config = Config.ItemData.data_get_data(bid)
            local tips_str = string.format(TI18N("是否花费<img src=%s visible=true scale=0.3 />%d开启<div fontColor=#d95014>【%s】</div>？"),PathTool.getItemRes(bid), num, self.data.config.name)    
            CommonAlert.show(tips_str, TI18N("确定"), function()
                _controller:send26562(self.data.config.id) --购买新的格子
            end, TI18N("取消"), nil, CommonAlert.type.rich)
        else
            local pay_config = nil
            local pay_type = cost[1][1]
            if type(pay_type) == 'number' then
                pay_config = Config.ItemData.data_get_data(pay_type)
            else
                pay_config = Config.ItemData.data_get_data(Config.ItemData.data_assets_label2id[pay_type])
            end
            if pay_config then
                if pay_config.id == Config.ItemData.data_assets_label2id.gold then
                    if FILTER_CHARGE then
                        message(TI18N("钻石不足"))
                    else
                        local function fun()
                            VipController:getInstance():openVipMainWindow(true, VIPTABCONST.CHARGE)
                        end
                        local str = string.format(TI18N('%s不足，是否前往充值？'), pay_config.name)
                        CommonAlert.show(str, TI18N('确定'), fun, TI18N('取消'), nil, CommonAlert.type.rich, nil, nil, nil, true)
                    end
                else
                    BackpackController:getInstance():openTipsSource(true, pay_config)
                end
            end
        end
    end
end

function ElfinFightPlanItem:onClickSkillItem()
    if not self.data then return end
    if not self.dic_item_pos then return end
    local setting = {}
    setting.from_type = 2
    local sprites = {}
    for i=1,4 do
        if self.dic_item_pos[i] then
            _table_insert(sprites, {pos = i, item_bid = self.dic_item_pos[i]})
        else
            local item_bid = _model:getElfinItemByPos(i)
            if item_bid then
                _table_insert(sprites, {pos = i, item_bid = 0})
            end     
        end
    end

    setting.sprites = sprites
    setting.dic_filter_item_id = {}
    setting.callback = function(elfin_list)
        _controller:send26557(self.data.id, elfin_list, 0, 0)
    end
    _controller:openElfinAdjustWindow(true, setting)
end

function ElfinFightPlanItem:updateName(name)
    if name then
        self.txt_title:setString(_string_format("【%s】", name)) -- 名称
    else
        if self.data and self.data.config then
            self.txt_title:setString(_string_format("【%s】", self.data.config.name)) -- 名称
        end
    end
end

function ElfinFightPlanItem:setData(data)
    if not data then return end
    self.data = data
    self:updateName(data.name)
    -- 是否开启
    if data.is_open == 0 then
        self.btn_load:setVisible(false)
        self.btn_write:setVisible(false)
        self.btn_open:setVisible(true)
        self.txt_open_desc:setVisible(true)

        if data.config and data.config.expend and  data.config.expend[1] then
            local bid =  data.config.expend[1][1]
            local num =  data.config.expend[1][2]
            local item_config = Config.ItemData.data_get_data(bid)
            if item_config then
                self.btn_open_label:setString(_string_format(TI18N("<img src='%s' scale=0.3 /> %d 开启"), PathTool.getItemRes(item_config.icon), num))
            end
        end
        for k,v in pairs(self.elfin_item_list) do
            v:setVisible(false)
        end
    else
        self.btn_load:setVisible(true)
        self.btn_write:setVisible(true)
        self.btn_open:setVisible(false)
        self.txt_open_desc:setVisible(false)

        --调整按钮位置
        local name_size = self.txt_title:getContentSize()
        self.btn_write:setPositionX(self.txt_title:getPositionX()+name_size.width+10)  
        self.is_gray = true
        self.dic_item_pos = {}
        for i,v in ipairs(data.plan_sprites) do
            self.dic_item_pos[v.pos] = v.item_bid
            if v.item_bid ~= 0 then
                self.is_gray = false
            end
        end

        if self.parent and self.parent.cur_plan_data and self.parent.cur_plan_data.plan_id == self.data.id then
            --使用中
            setChildUnEnabled(true, self.btn_load)
            --self.btn_load_lable:enableOutline(Config.ColorData.data_color4[2], 2)
            self.btn_load_lable:setString(TI18N("使用中"))
            self.btn_load:setTouchEnabled(false)
        else
            self.btn_load_lable:setString(TI18N("装配"))
            self.btn_load:setTouchEnabled(true)
            if self.is_gray then
                --置灰
                setChildUnEnabled(true, self.btn_load)
                --self.btn_load_lable:enableOutline(Config.ColorData.data_color4[2], 2)
            else
                setChildUnEnabled(false, self.btn_load)
                --self.btn_load_lable:enableOutline(Config.ColorData.data_color4[264], 2)
            end
        end
        

        for pos,skill_item in ipairs(self.elfin_item_list) do
            skill_item:setVisible(true)
            local item_bid = _model:getElfinItemByPos(pos)
            if item_bid then
                local elfin_cfg = Config.SpriteData.data_elfin_data(self.dic_item_pos[pos])
                if self.dic_item_pos[pos] == nil or self.dic_item_pos[pos] == 0 or not elfin_cfg then
                    skill_item:setData()
                    skill_item:showLevel(false)
                else
                    local skill_cfg = Config.SkillData.data_get_skill(elfin_cfg.skill)
                    if skill_cfg then
                        skill_item:setData(skill_cfg)
                    end
                end
            else
                skill_item:setData()
                skill_item:showLevel(false)
                skill_item:showLockIcon(true)
            end
        end
    end
end



function ElfinFightPlanItem:DeleteMe()
    for k,v in pairs(self.elfin_item_list) do
        v:DeleteMe()
        v = nil
    end
end

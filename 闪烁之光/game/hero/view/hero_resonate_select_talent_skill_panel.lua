--------------------------------------------
-- @Author  : lwc
-- @Date    : 2019年8月5日
-- @description    : 
        -- 共鸣选择天赋界面
---------------------------------
HeroResonateSelectTalentSkillPanel = HeroResonateSelectTalentSkillPanel or BaseClass(BaseView)

local controller = HeroController:getInstance()
local model = controller:getModel()

local table_insert = table.insert
local table_sort = table.sort
local string_format = string.format

function HeroResonateSelectTalentSkillPanel:__init()
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.res_list = {
        -- {path = PathTool.getPlistImgForDownLoad("homepet_travellingbag", "homepet_travellingbag"), type = ResourcesType.plist}
    }
    self.layout_name = "hero/hero_resonate_select_talent_skill_panel"

    --技能属性
    self.dic_skill_config = {}
end

function HeroResonateSelectTalentSkillPanel:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1) 

    local main_panel = self.main_container:getChildByName("main_panel")
    self.title = main_panel:getChildByName("win_title")
    self.title:setString(TI18N("选择技能"))

    self.close_btn = main_panel:getChildByName("close_btn")

    self.comfirm_btn = self.main_container:getChildByName("comfirm_btn")
    self.comfirm_btn_label = self.comfirm_btn:getChildByName("label")
    self.comfirm_btn_label:setString(TI18N("确 定"))
    self.cancel_btn = self.main_container:getChildByName("cancel_btn")
    self.cancel_btn:getChildByName("label"):setString(TI18N("取 消"))


    self.tab_container = self.main_container:getChildByName("tab_container")
    local tab_name_list = {
        [1] = TI18N("低级技能"),
        [2] = TI18N("中级技能"),
        [3] = TI18N("高级技能"),
    }
    self.tab_list = {}
    for i=1,3 do
        local tab_btn = self.tab_container:getChildByName("tab_btn_"..i)
        if tab_btn then
            local object = {}
            object.select_bg = tab_btn:getChildByName('select_bg')
            object.select_bg:setVisible(false)
            object.unselect_bg = tab_btn:getChildByName('unselect_bg')
            object.title = tab_btn:getChildByName("title")
            object.title:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff))
            if tab_name_list[i] then
                object.title:setString(tab_name_list[i])
            end
            object.tab_btn = tab_btn
            object.index = i
            self.tab_list[i] = object
        end
    end

    self.lay_srollview = self.main_container:getChildByName("lay_srollview")

    self.tips_label = self.main_container:getChildByName("tips_label")
    self.tips_label:setString(TI18N("只可选择当前已拥有的天赋技能"))
end

function HeroResonateSelectTalentSkillPanel:register_event(  )
    registerButtonEventListener(self.background, function() self:onClosedBtn() end,false, 2)
    registerButtonEventListener(self.close_btn, function() self:onClosedBtn() end ,true, 2)
    registerButtonEventListener(self.comfirm_btn, function() self:onComfirmBtn()  end ,true, 1)
    registerButtonEventListener(self.cancel_btn, function() self:onCancelBtn()  end ,true, 1)


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


    self:addGlobalEvent(HeroEvent.Hero_Resonate_Skill_List_Event, function(data)
        if not data then return end
        self.dic_had_skill = {}
        for i,v in ipairs(data.skills) do
            self.dic_had_skill[v.skill_id] = 1
        end
        self:setData()
    end)
end

--关闭
function HeroResonateSelectTalentSkillPanel:onClosedBtn()
    controller:openHeroResonateSelectTalentSkillPanel(false)
end

--确定
function HeroResonateSelectTalentSkillPanel:onComfirmBtn()
    if self.select_pos then
        GlobalEvent:getInstance():Fire(HeroEvent.Hero_Resonate_Select_Skill_Event, self.select_pos, self.select_skill_id)
    end
    self:onClosedBtn()
end
--取消
function HeroResonateSelectTalentSkillPanel:onCancelBtn()
    self:onClosedBtn()
end

-- 切换标签页
function HeroResonateSelectTalentSkillPanel:changeSelectedTab( index )
    if self.tab_object and self.tab_object.index == index then return end
    if self.tab_list[index] and self.tab_list[index].is_lock then return end

    if self.tab_object then
        self.tab_object.select_bg:setVisible(false)
        self.tab_object.title:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff))
        self.tab_object = nil
    end
    self.tab_object = self.tab_list[index]

    if self.tab_object then
        self.tab_object.select_bg:setVisible(true)
        self.tab_object.title:setTextColor(cc.c4b(0xff, 0xed, 0xd6, 0xff))
    end

    if self.select_cell and self.select_cell.skill_item then
        self.select_cell.skill_item:setTickSelected(false)
    end

    --数据
    self:updateList(index)
end

function HeroResonateSelectTalentSkillPanel:openRootWnd(setting)
    local setting = setting or {}
    self.select_skill_id = setting.select_skill_id
    self.dic_had_skill = setting.dic_had_skill
    self.dic_other_skill = setting.dic_other_skill -- 是table
    self.select_pos = setting.pos
    self.career = setting.career

    local partner_awakening_skill_config = Config.PartnerSkillData.data_partner_awakening_skill
    self.skill_config_list = {}
    local config_list = Config.PartnerSkillData.data_partner_skill_view
    for i,list in ipairs(config_list) do
        self.skill_config_list[i] = {}
        for _, id in ipairs(list) do
            if partner_awakening_skill_config[id] then
                --觉醒技能必须三号位置
                if self.career and self.select_pos == 3  then
                    local limit_career = partner_awakening_skill_config[id].limit_career
                    -- 判断是否是同职业的
                    if limit_career and next(limit_career) ~= nil then
                        if limit_career[1] and limit_career[1][1] == self.career then
                            table_insert(self.skill_config_list[i], id)
                        end
                    end
                end
            else
                table_insert(self.skill_config_list[i], id)
            end
        end
    end
    -- self.skill_config_list = deepCopy(Config.PartnerSkillData.data_partner_skill_view)
    if self.dic_had_skill then
        self:setData()
    else
        controller:sender26422()
    end
end

function HeroResonateSelectTalentSkillPanel:setData(  )
    if not self.dic_had_skill then return end
    local tab_index = 3
    self.select_index = nil

    local a_index = 0
    local b_index = 0
    local sort_func = function(a, b)
        a_index = self.dic_had_skill[a] or 0
        b_index = self.dic_had_skill[b] or 0
        if a_index == b_index then
            return a < b
        else
            return a_index > b_index
        end

    end
    for index, list in ipairs(self.skill_config_list) do
        table_sort(list, sort_func)    
    end

    if self.select_skill_id then
        for index, list in ipairs(self.skill_config_list) do
            for i,id in ipairs(list) do
                if self.select_skill_id == id then
                    tab_index = index
                    self.select_index = i
                end
            end
            
        end
    end
    self:changeSelectedTab(tab_index)
end
function HeroResonateSelectTalentSkillPanel:updateList(tab_index)
    if not tab_index then return end
    if not self.skill_config_list then return end
    if not self.dic_had_skill then return end
    if self.item_scrollview == nil then
        local scroll_view_size = self.lay_srollview:getContentSize()
        local width = scroll_view_size.width/4
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = width,                -- 单元的尺寸width
            item_height = 158,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 4,                         -- 列数，作用于垂直滚动类型
            once_num = 1,                    -- 每次创建的数量
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.lay_srollview, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
    end
    
    self.show_list = self.skill_config_list[tab_index] or {}
    self.item_scrollview:reloadData(self.select_index)
    self.select_index = nil

    if #self.show_list == 0 then
        commonShowEmptyIcon(self.lay_srollview, true, {text = TI18N("暂无技能信息")})
    else
        commonShowEmptyIcon(self.lay_srollview, false)
    end
end


--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function HeroResonateSelectTalentSkillPanel:createNewCell(width, height)
    local cell = ccui.Widget:create()
    -- cell.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_acc_level_up_gift_item"))
    -- cell:addChild(cell.root_wnd)
    cell:setCascadeOpacityEnabled(true)
    cell:setAnchorPoint(0,0)
    cell:setContentSize(cc.size(width, height))
    cell.skill_item = SkillItem.new(true,true,false,nil,nil,false)
    cell.skill_item:setPosition(width * 0.5, 90)
    cell:addChild(cell.skill_item)
    -- local cell = SkillItem.new(true,true,false,nil,nil,false)
    -- cell:setScale(0.9)

    cell.skill_item:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function HeroResonateSelectTalentSkillPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function HeroResonateSelectTalentSkillPanel:updateCellByIndex(cell, index)
    cell.index = index
    local skill_id = self.show_list[index]
    if not skill_id then return end

    if self.dic_skill_config[skill_id] == nil then
        self.dic_skill_config[skill_id] = Config.SkillData.data_get_skill(skill_id)
    end
    local config =  self.dic_skill_config[skill_id]
    if config then
        cell.skill_item:setData(config)
        cell.skill_item:showName(true,config.name, nil,nil,true)
    end

    if self.dic_other_skill[skill_id] then
        cell.skill_item:showRecommondIcon(true,2)
    else
        cell.skill_item:showRecommondIcon(false)
    end

    if self.dic_had_skill[skill_id] then
        cell.skill_item:showUnEnabled(false)
    else
        cell.skill_item:showUnEnabled(true)
    end

    if self.select_skill_id and self.select_skill_id == skill_id then
        cell.skill_item:setTickSelected(true)
    else
        cell.skill_item:setTickSelected(false)
    end
end

-- --点击cell .需要在 createNewCell 设置点击事件
function HeroResonateSelectTalentSkillPanel:onCellTouched(cell)
    if not cell.index then return end
    local skill_id = self.show_list[cell.index]
    if not skill_id then return end
    if not self.dic_had_skill then return end
    if self.dic_had_skill[skill_id] == nil then
        message(TI18N("此技能未拥有"))
        return
    end
    if self.dic_other_skill[skill_id] then
        message(TI18N("此技能已领悟"))
        return 
    end

    if self.select_cell and self.select_cell.skill_item then
        self.select_cell.skill_item:setTickSelected(false)
    end

    if self.select_skill_id and self.select_skill_id == skill_id and self.select_index == nil then
        --取消选中
        self.select_skill_id = nil
        self.select_cell = nil
    else
        self.select_skill_id = skill_id
        self.select_cell = cell
        if self.select_cell and self.select_cell.skill_item then
            self.select_cell.skill_item:setTickSelected(true)
        end
    end
    -- self:setComfirmStatus()
end

function HeroResonateSelectTalentSkillPanel:setComfirmStatus()
    if self.select_skill_id == nil then
        self.comfirm_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
        setChildUnEnabled(true, self.comfirm_btn)
        self.comfirm_btn:setTouchEnabled(false)
    else
        setChildUnEnabled(false, self.comfirm_btn)
        self.comfirm_btn_label:enableOutline(Config.ColorData.data_color4[264], 2)
        self.comfirm_btn:setTouchEnabled(true)
    end
end


function HeroResonateSelectTalentSkillPanel:close_callback()
    if self.item_list and next(self.item_list or {}) ~= nil then
        for i, v in ipairs(self.item_list) do
            if v.DeleteMe then
                v:DeleteMe()
            end
        end
    end
    self.item_list = {}

    controller:openHeroResonateSelectTalentSkillPanel(false)
end
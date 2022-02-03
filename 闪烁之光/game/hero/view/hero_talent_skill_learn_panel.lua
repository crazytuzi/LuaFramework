-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      天赋
-- <br/> 2018年11月20日
-- --------------------------------------------------------------------
HeroTalentSkillLearnPanel = HeroTalentSkillLearnPanel or BaseClass(BaseView)

local controller = HeroController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert
local table_remove = table.remove

function HeroTalentSkillLearnPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.is_full_screen = false
    self.layout_name = "hero/hero_talent_skill_learn_panel"

    self.res_list = {
        -- { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_3"), type = ResourcesType.single }
    }

    --消耗数据列表
    self.item_list = {}

    self.title_height = 60 --横条高度
end

function HeroTalentSkillLearnPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1) 
    self.title = self.main_container:getChildByName("win_title")
    self.title:setString(TI18N("天赋领悟"))

    self.show_item_node = self.main_container:getChildByName("show_item_node")
    self.skill_item = SkillItem.new(true,true,true,nil,nil,false)
    self.show_item_node:addChild(self.skill_item)
    self.skill_name = self.main_container:getChildByName("skill_name")
    local dec_node = self.main_container:getChildByName("dec_node")
    self.skill_desc = createRichLabel(22, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0, 1), cc.p(0,0),nil,nil,440)
    dec_node:addChild(self.skill_desc)
    self.no_vedio_image = self.main_container:getChildByName("no_vedio_image")
    self.no_vedio_label = self.main_container:getChildByName("no_vedio_label")
    self.no_vedio_label:setString(TI18N("暂时无技能"))

    self.lay_scrollview = self.main_container:getChildByName("lay_scrollview")

    self.cost_node = self.main_container:getChildByName("cost_node")
    self.select_btn = self.main_container:getChildByName("select_btn")
    self.select_btn:getChildByName("label"):setString(TI18N("领 悟"))

    -- self.close_btn = self.main_container:getChildByName("close_btn")
    self.cost_label = self.main_container:getChildByName("cost_label")
    self.cost_label:setString(TI18N("消耗:"))
end

function HeroTalentSkillLearnPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 1)
    -- registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,false,2)
    registerButtonEventListener(self.select_btn, handler(self, self.onClickBtnSelect) ,true, 2)

    --  --学习天赋技能返回
    -- self:addGlobalEvent(HeroEvent.Hero_Learn_Talent_Event, function(list)
    --     if not list then return end
    --     if not self.select_hero_vo then return end
        
    -- end)
end

--关闭
function HeroTalentSkillLearnPanel:onClickBtnClose()
    controller:openHeroTalentSkillLearnPanel(false)
end

--选择
function HeroTalentSkillLearnPanel:onClickBtnSelect()
    if not self.select_skill_data then
        return
    end

    if self.dic_have_skill_id.order_had == 1 then
        --已拥有
        return
    else
        controller:sender11096(self.hero_vo.partner_id, self.pos, self.select_skill_data.config.id)
        self:onClickBtnClose()
    end
end

--@ pos 技能位置
function HeroTalentSkillLearnPanel:openRootWnd(hero_vo, pos)
    if not hero_vo then return end
    if not pos  then return end
    self.pos = pos  
    self.hero_vo = hero_vo
    local config_list = Config.PartnerSkillData.data_partner_skill_learn
    if config_list and next(config_list) ~= nil then
        self.no_vedio_image:setVisible(false)
        self.no_vedio_label:setVisible(false)
        self:initSkillData(config_list)
    end
end



function HeroTalentSkillLearnPanel:initSkillData(config_list)
    self.skill_list  = {}
    self.dic_have_skill_id = {}
    local map_config = Config.PartnerSkillData.data_partner_skill_map
    for pos,id in pairs(self.hero_vo.talent_skill_list) do
        if map_config and map_config[id] then
            local lev_id = map_config[id]
            if map_config[lev_id] then
                self.dic_have_skill_id[map_config[lev_id]] = pos
            else
                self.dic_have_skill_id[lev_id] = pos
            end
        else
            self.dic_have_skill_id[id] = pos    
        end
    end

    --英雄职业对应名字
    career_order_name ={
        [HeroConst.CareerType.eMagician]    = "order_magician",
        [HeroConst.CareerType.eWarrior]     = "order_warrior",
        [HeroConst.CareerType.eTank]        = "order_tank",
        [HeroConst.CareerType.eSsistant]    = "order_ssistant",
    }

    local dic_hero_talent_skill_learn_redpoint = HeroController:getInstance():getModel():getTalentRedpointRecord()

    local dic_commend_skill = {}
    local commend_skill_config = Config.PartnerSkillData.data_partner_commend_skill[self.hero_vo.bid]
    if commend_skill_config then
        for i,skill_id in ipairs(commend_skill_config) do
            dic_commend_skill[skill_id] = i
        end
    end
    self.awakening_count = 0 --觉醒技能的数量
    for id, config in pairs(config_list) do
        local skill_data = {}
        skill_data.config = config
        skill_data.order = config.order
        if commend_skill_config then
            --该英雄有单独推荐的  用单独推荐初始化
            if dic_commend_skill[config.id] then
                skill_data.career_order = dic_commend_skill[config.id]
            else
                skill_data.career_order = 1000
            end
        else
            if career_order_name[self.hero_vo.type] then
                skill_data.career_order = config[career_order_name[self.hero_vo.type]]
            else
                skill_data.career_order = 1000
            end
        end
        if self.dic_have_skill_id[config.id] then
            skill_data.order_had = 1  --已拥有
        else
            skill_data.order_had = 2
        end

        if dic_hero_talent_skill_learn_redpoint[config.id] then
            skill_data.order_can = 1 --可领悟
        else
            skill_data.order_can = 2
        end

        if next(config.limit_career) ~= nil then
            --表示是觉醒技能
            if self:isShowAwakeningSkill() then
                local is_career = false
                for _,career_id in ipairs(config.limit_career[1]) do
                    if career_id == self.hero_vo.type then
                        is_career = true
                        break
                    end
                end
                if is_career then
                    skill_data.order_awakening = 1 --觉醒技能在
                    table_insert(self.skill_list, skill_data)  
                    self.awakening_count = self.awakening_count + 1
                end
            end
        else
            skill_data.order_awakening = 2
            table_insert(self.skill_list, skill_data)  
        end
        
    end
    local sort_func = SortTools.tableLowerSorter({"order_awakening","order_had", "order_can", "career_order", "order"})
    table.sort(self.skill_list, sort_func) 

    self:updateSkillList()
end

--是否显示觉醒技能 13星 第三个位置的
function HeroTalentSkillLearnPanel:isShowAwakeningSkill()
    if self.pos == 3 and self.hero_vo and self.hero_vo.star > model.hero_info_upgrade_star_param4 then
        return true
    end
    return false
end

--初始化13星星信息 并处理好显示位置
function HeroTalentSkillLearnPanel:initThirteenInfo()
    if self:isShowAwakeningSkill() then
        if not self.list_setting then return end
        if not self.awakening_count then return end
        local temp = self.awakening_count % 4
        if temp ~= 0 then --如果不是4的倍数 需要在后面补到4个
            local len = 4 - temp
            for i=1,len do
                table_insert(self.skill_list, self.awakening_count + i, {})
            end
            self.awakening_count = self.awakening_count + (4 - temp)
        end

        -- --计算位置
        local position_data_list = {}
        local item_width = self.list_setting.item_width
        local item_height = self.list_setting.item_height

        local scroll_height =  self.title_height * 2 + math.ceil(#self.skill_list/4) * item_height

        local y = scroll_height
        local x = 0
        local tittle_pos_y = 0 --第二个title的位置
        for i,v in ipairs(self.skill_list) do
            if i == 1 or  i == self.awakening_count + 1 then
                if i == self.awakening_count + 1 then
                    tittle_pos_y = y
                end
                y = y -  self.title_height
            end 
            local x = ((i - 1) % 4) * item_width + item_width * 0.5
            position_data_list[i] = cc.p(x, y - item_height * 0.5)

            if i > 1 and i % 4 == 0 then
                y = y - item_height
            end
        end

        return position_data_list, scroll_height, tittle_pos_y
    end
end

function HeroTalentSkillLearnPanel:createTitleItem(name,x, y)
    if not self.list_view then return end
    local size = cc.size(128, 50)
    local item = {}
    local res = PathTool.getResFrame("common","common_1057")
    item.bg = createImage(self.list_view.scroll_view, res, x, y - self.title_height *0.5 , cc.p(0.5, 0.5), true, nil, false)
    item.bg:setScale(5)
    item.label = createLabel(26, cc.c3b(0x64,0x32,0x23), nil, x, y - self.title_height *0.5, name, self.list_view.scroll_view, nil, cc.p(0.5, 0.5))
end

--创建英雄列表 
function HeroTalentSkillLearnPanel:updateSkillList()
    if self.list_view == nil then
        local scroll_view_size = self.lay_scrollview:getContentSize()
        local width = scroll_view_size.width/4
        
        self.list_setting = {
            start_x = 0,
            space_x = 0,
            start_y = 0,
            space_y = 0,
            item_width = width,
            item_height = 158,
            row = 0,
            col = 4,
            need_dynamic = true,
            -- position_data_list = position_data_list
        }
        local position_data_list, container_height, tittle_pos_y = self:initThirteenInfo()
        self.list_setting.position_data_list = position_data_list
        self.list_setting.container_height = container_height

        self.list_view = CommonScrollViewSingleLayout.new(self.lay_scrollview, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, self.list_setting, cc.p(0, 0)) 

        self.list_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.list_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        self.list_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell

        if self:isShowAwakeningSkill() then
            --显示两个标题
            self:createTitleItem(TI18N("职业专属觉醒天赋"), scroll_view_size.width*0.5, container_height)
            self:createTitleItem(TI18N("通用天赋"), scroll_view_size.width*0.5, tittle_pos_y)
        end
    end

    local select_index = nil
    for i,skill_data in ipairs(self.skill_list) do
        if select_index == nil and skill_data.config and skill_data.order_had ~= 1 then
            select_index = i
            break
        end
    end

    --容错
    if select_index == nil then
        select_index = 1
    end
    self.list_view.time_show_index = select_index
    self.list_view:reloadData(nil)
    self.list_view:setOnCellTouched(select_index)
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function HeroTalentSkillLearnPanel:createNewCell(width, height)
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
function HeroTalentSkillLearnPanel:numberOfCells()
    if not self.skill_list then return 0 end
    return #self.skill_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function HeroTalentSkillLearnPanel:updateCellByIndex(cell, index)
    cell.index = index
    local skill_data = self.skill_list[index]
    if skill_data and skill_data.config then
        
        local config = Config.SkillData.data_get_skill(skill_data.config.id)
        cell:setVisible(true)
        if config then
            cell.skill_item:setData(config)
            cell.skill_item:showName(true,config.name, nil,nil,true)
            if skill_data.order_had == 1 then --已学会
                cell.skill_item:showRecommondIcon(true,2)
            elseif skill_data.order_can == 1 then --已领悟
                cell.skill_item:showRecommondIcon(true,5)
            elseif skill_data.career_order ~= 1000 then --推荐
                cell.skill_item:showRecommondIcon(true,1)
            end
            if self.select_skill_data and self.select_skill_data.config.id == skill_data.config.id then
                cell.skill_item:setSelected(true)
            else
                cell.skill_item:setSelected(false)
            end
        end
    else
        cell:setVisible(false)
    end
end

--点击cell .需要在 createNewCell 设置点击事件
function HeroTalentSkillLearnPanel:onCellTouched(cell)
    local index = cell.index
    local skill_data = self.skill_list[index]
    if self.select_cell then
        self.select_cell.skill_item:setSelected(false)
    end
    self.select_cell = cell
    if self.select_cell then
        self.select_cell.skill_item:setSelected(true)
    end
    self:showSkillInfo(skill_data)
end

function HeroTalentSkillLearnPanel:showSkillInfo(skill_data)
    if not skill_data then return end
    self.select_skill_data = skill_data
    local config = Config.SkillData.data_get_skill(skill_data.config.id)
    if config then
        if self.skill_item then
            self.skill_item:setData(config)
        end
        self.skill_name:setString(config.name)
        self.skill_desc:setString(config.des)
        
    end
    self:showCostInfo(skill_data)
end

function HeroTalentSkillLearnPanel:showCostInfo(skill_data)
    if not skill_data then return end
    for i,item in ipairs(self.item_list) do
        item:setPositionX(10000) --相当于隐藏
    end

    local item_width = BackPackItem.Width + 10
    local start_x = - item_width * #skill_data.config.expend/2 + item_width * 0.5
    for i,cost in ipairs(skill_data.config.expend) do
        if self.item_list[i] == nil then
            self.item_list[i] = BackPackItem.new(true, true)
            self.item_list[i]:setAnchorPoint(0.5, 0.5)
            self.item_list[i]:setScale(0.8)
            self.cost_node:addChild(self.item_list[i])
        end
        local _x = start_x + (i - 1) * item_width
        self.item_list[i]:setPosition(_x, 0)
        local item_config = Config.ItemData.data_get_data(cost[1])
        if item_config then
            -- self.item_list[i]:setBaseData(cost[1], cost[2], true)
            self.item_list[i]:setData(item_config)
            local have_num = BackpackController:getInstance():getModel():getItemNumByBid(item_config.id)
            self.item_list[i]:setNeedNum(cost[2], have_num)
            self.item_list[i]:setDefaultTip(true, nil, nil , 1)
            local color = cc.c4b(0x64,0x32,0x23,0xff)
            -- local name = string_format("%sx%s", item_config.name, cost[2])
            self.item_list[i]:setGoodsName(item_config.name,nil,nil,color)
       
        end
    end
end

function HeroTalentSkillLearnPanel:close_callback()
    if self.list_view then 
        self.list_view:DeleteMe()
        self.list_view = nil
    end

    if self.skill_item then
        self.skill_item:DeleteMe()
        self.skill_item = nil
    end

    controller:openHeroTalentSkillLearnPanel(false)
end
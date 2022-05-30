-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      石碑增益
-- <br/> 2019年8月1日
-- --------------------------------------------------------------------
HeroResonateTabStoneTabletPanel = class("HeroResonateTabStoneTabletPanel", function()
    return ccui.Widget:create()
end)

local controller = HeroController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert

local math_floor = math.floor

function HeroResonateTabStoneTabletPanel:ctor(parent)  
    self.parent = parent
    self:config()
    self:layoutUI()
    self:registerEvents()
end
function HeroResonateTabStoneTabletPanel:config()
    -- self.size = cc.size(680,372.97)
    -- self:setContentSize(self.size)

    self.dic_config_level_up = {}
    self.dic_config_star_attr = {}

    local config = Config.ResonateData.data_const.attr_add_var1
    if config then
        self.param_star = config.val
    else
        self.param_star = 10
    end

    self.hero_param = 100
end

function HeroResonateTabStoneTabletPanel:layoutUI()
    local csbPath = PathTool.getTargetCSB("hero/hero_resonate_tab_stone_tablet_panel")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    --读取文件的大小
    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.bottom_panel = self.main_container:getChildByName("bottom_panel")
    
    self.level_panel = self.bottom_panel:getChildByName("level_panel")
    self.level_key = self.level_panel:getChildByName("key")
    self.level_key:setString(TI18N("增幅阶段:"))
    self.level_left = self.level_panel:getChildByName("left")
    self.level_arrow = self.level_panel:getChildByName("arrow_icon")
    self.level_right = self.level_panel:getChildByName("right")


    self.param_lay = self.bottom_panel:getChildByName("param_lay")
    local height = self.param_lay:getContentSize().height/3
    self.param_list = {}
    for i=1,3 do
        -- local param = self.bottom_panel:getChildByName("param"..i)
        local y = height * (3-i) + height * 0.5 
        self.param_list[i] = {}
        self.param_list[i].key = createRichLabel(20, Config.ColorData.data_new_color4[6], cc.p(0,0.5),cc.p(0, y),nil,nil,1900)
        self.param_list[i].left = createRichLabel(20, Config.ColorData.data_new_color4[6], cc.p(0,0.5),cc.p(118, y),nil,nil,1900)
        self.param_list[i].right = createRichLabel(20, Config.ColorData.data_new_color4[6], cc.p(0,0.5),cc.p(335, y),nil,nil,1900)
        --self.param_list[i].icon_bg = createRichLabel(20, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0,0.5),cc.p(335, y),nil,nil,1900)
        self.param_list[i].key_bg = createSprite(PathTool.getResFrame("common", "common_30019"), 12, y, nil, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
        self.param_list[i].arrow = createSprite(PathTool.getResFrame("common", "common_90017"), 310, y, nil, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)

        self.param_lay:addChild(self.param_list[i].key_bg)
        self.param_lay:addChild(self.param_list[i].key)
        self.param_lay:addChild(self.param_list[i].left)
        self.param_lay:addChild(self.param_list[i].right)
        self.param_lay:addChild(self.param_list[i].arrow)
    end
    --self.common_90034 = self.param_lay:getChildByName("common_90034")

    self.star_tips = createRichLabel(16, Config.ColorData.data_new_color4[11] , cc.p(0.5,0.5),cc.p(360, 360),nil,nil,1900)
    self.bottom_panel:addChild(self.star_tips)
    self.bottom_panel_x, self.bottom_panel_y = self.bottom_panel:getPosition()
    --消耗
    local cost_icon_1 = self.bottom_panel:getChildByName("cost_icon_1")
    cost_icon_1:setScale(0.8)
    local cost_icon_2 = self.bottom_panel:getChildByName("cost_icon_2")
    cost_icon_2:setScale(0.8)
    local cost_txt_1 = self.bottom_panel:getChildByName("cost_txt_1")
    local cost_txt_2 = self.bottom_panel:getChildByName("cost_txt_2")
    cost_txt_1:setString("")
    cost_txt_2:setString("")
    self.cost_icon = {cost_icon_1, cost_icon_2}
    self.cost_txt = {cost_txt_1, cost_txt_2}

    self.level_up_btn = self.bottom_panel:getChildByName("level_up_btn")
    self.level_up_btn_label = self.level_up_btn:getChildByName("label")
    self.level_up_btn_label:setString(TI18N("提 升"))
    -- self.main_container:getChildByName("advancedKey"):setString(TI18N("进阶:"))

    --self.look_btn = self.bottom_panel:getChildByName("look_btn")
end

function HeroResonateTabStoneTabletPanel:playEnterAnimatian()
    if not self.bottom_panel then return end
    commonOpenActionLeftMove(self.bottom_panel)
end

--事件
function HeroResonateTabStoneTabletPanel:registerEvents()
    registerButtonEventListener(self.level_up_btn, function() self:onClickLevelUpBtn()  end ,true, 2)

    --registerButtonEventListener(self.look_btn, function(param,sender, event_type)
    --    if self.parent and self.parent.is_move_effect then return end
    --    local config = Config.ResonateData.data_const.rule_tips
    --    if config then
    --        TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
    --    end
    --end ,true, 2, nil, 0.8)

    -- for i,v in ipairs(self.item_lay_list) do
    --     registerButtonEventListener(v.btn, function() self:onClickHeroBtn(i)  end ,false, 2)
    -- end

    --共鸣信息更新
    if self.hero_resonate_info_event == nil then
        self.hero_resonate_info_event = GlobalEvent:getInstance():Bind(HeroEvent.Hero_Resonate_Info_Event, function(data)
           if not data then return end
           self:setScData(data)
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

     --添加宝可梦选择返回事件
    if self.select_hero_event == nil then
        self.select_hero_event = GlobalEvent:getInstance():Bind(HeroEvent.Select_Hero_Event, function(dic_cur_select_list, form_type)
            if not self.select_pos then return end
            if form_type  and form_type == HeroConst.SelectHeroType.eResonateStone then
                if dic_cur_select_list == nil or next(dic_cur_select_list) == nil then
                    if self.dic_hero_vo[self.select_pos] then
                        --说明是卸下的
                        controller:sender26401(self.select_pos, self.dic_hero_vo[self.select_pos].id, 2)
                    end
                else
                    for id,v in pairs(dic_cur_select_list) do
                        if self.dic_hero_vo[self.select_pos] and id == self.dic_hero_vo[self.select_pos].id then
                            --说明是卸下的
                            -- controller:sender26401(self.select_pos, v.id, 2)
                        else
                            --说明切换或穿上的
                            controller:sender26401(self.select_pos, v.partner_id, 1)
                        end
                        break
                    end
                end
                self.select_pos = nil
            end
        end)
    end
end

function HeroResonateTabStoneTabletPanel:onClickHeroBtn(pos)
    local is_lock, lock_str = self:checkPosLockByPos(pos)
    if is_lock then
        message(lock_str)
        return 
    end
    if self.parent and self.parent.is_move_effect then return end
    if not self.dic_hero_vo then return end
    local config = Config.ResonateData.data_const.hero_star_condition
    local star = 5
    if config then
        star = config.val
    end

    self.select_pos = pos
    local setting = {}
    setting.select_condition = {}
    setting.select_condition.star_start = star
    setting.select_condition.camp_type = 0
    setting.select_condition.bid = 0
    setting.select_count = 1
    setting.form_type = HeroConst.SelectHeroType.eResonateStone
    setting.dic_selected = {}
    if self.dic_hero_vo[pos] then
        setting.dic_selected[self.dic_hero_vo[pos].id] = self.dic_hero_vo[pos]
    end
    setting.dic_filter_selected = {}
    setting.tips = TI18N("选择一个五星或以上星级的宝可梦配置到圣阵中")
    if model.dic_resonate_lock_info then
        for i,v in pairs(model.dic_resonate_lock_info) do
            if setting.dic_selected[v.id] == nil then
                setting.dic_filter_selected[v.id] = v
            end
        end
    end
    
    controller:openHeroSelectHeroPanel(true, setting)
end

function HeroResonateTabStoneTabletPanel:onClickLevelUpBtn()
    if self.parent and self.parent.is_move_effect then return end
    controller:sender26402()
end


function HeroResonateTabStoneTabletPanel:setData(parent)
    self.parent = parent
    self.is_init_hero = true
    if self.is_send_26400 then return end
    self.is_send_26400 = true
    controller:sender26400()
end

function HeroResonateTabStoneTabletPanel:setScData(scdata)
    self.scdata = scdata
    local is_max_level = model:isResonateMaxLevel(self.scdata.lev)
    if is_max_level then
        self.level_panel:setPositionX(360)
        self.level_left:setString(self.scdata.lev)
        self.level_right:setString("")
        self.level_arrow:setVisible(false)

        self.cost_icon[1]:setVisible(false)
        self.cost_icon[2]:setVisible(false)
        self.cost_txt[1]:setVisible(false)
        self.cost_txt[2]:setVisible(false)
        self.bottom_panel:getChildByName("cost_bg_1"):setVisible(false)
        self.bottom_panel:getChildByName("cost_bg_2"):setVisible(false)
        self.level_up_btn:setVisible(false)

        if self.max_lev_str == nil then
            local str = TI18N("已经达到满级!")
            self.max_lev_str = createLabel(24, cc.c4b(0x64,0x32,0x23,0xff),nil, 360,256,str,self.bottom_panel,nil, cc.p(0.5,0.5))
        end
    else
        self.level_left:setString(self.scdata.lev)
        self.level_right:setString(self.scdata.lev + 1)
        self.level_arrow:setVisible(true)
        self:updateCostInfo()
    end

    -- self:updateHeroList(self.scdata.list)
    self.dic_hero_vo = {}
    for i,v in ipairs(self.scdata.list) do
        if v.id ~= 0 then
            local hero_vo = model:getHeroById(v.id)
            if hero_vo and next(hero_vo) ~= nil then
                table_insert(self.dic_hero_vo, hero_vo)
            end
        end
    end
    self:updateAttrInfo(self.scdata.attr, is_max_level)


end

function HeroResonateTabStoneTabletPanel:checkResonateStoneRedpoint(  )
    if model.is_resonate_stone_redpoint then
        addRedPointToNodeByStatus(self.level_up_btn, true, 5, 5)
    else
        addRedPointToNodeByStatus(self.level_up_btn, false, 5, 5)
    end
end

function HeroResonateTabStoneTabletPanel:runShowAction(is_run)
    if is_run then
        --移开的
        if self.bottom_panel then
            local fadeOut = cc.FadeIn:create(0.8)
            local moveto = cc.MoveTo:create(0.8,cc.p(self.bottom_panel_x, -1000))
            local spawn_action = cc.Spawn:create(moveto, fadeOut)
            self.bottom_panel:runAction(spawn_action)
        end
    else
        self.delayTime_param = self.parent.delayTime_param or 0.5
        if self.bottom_panel then
            self.bottom_panel:setPositionY(-1000)
            local fadeIn = cc.FadeIn:create(0.65)
            local moveto = cc.MoveTo:create(0.65,cc.p(self.bottom_panel_x, self.bottom_panel_y))
            local spawn_action = cc.Spawn:create(moveto, fadeIn)
            self.bottom_panel:runAction(cc.Sequence:create(cc.DelayTime:create(self.delayTime_param), spawn_action))
        end
    end
end


function HeroResonateTabStoneTabletPanel:updateAttrInfo(attr, is_max_level)
    if not self.scdata then return end
    if not self.dic_hero_vo then return end

    local total_star = model.resonate_max_partner_lev or 0

    if self.dic_config_level_up[self.scdata.lev] == nil then
        self.dic_config_level_up[self.scdata.lev] = Config.ResonateData.data_level_up(self.scdata.lev)
    end
    if self.dic_config_level_up[self.scdata.lev + 1] == nil then
        self.dic_config_level_up[self.scdata.lev + 1] = Config.ResonateData.data_level_up(self.scdata.lev + 1)
    end
    if self.dic_config_star_attr[total_star] == nil then
        self.dic_config_star_attr[total_star] = Config.ResonateData.data_star_attr(total_star)
    end
    local level_up_config = self.dic_config_level_up[self.scdata.lev]
    local next_level_up_config = self.dic_config_level_up[self.scdata.lev + 1]
    local star_attr_config = self.dic_config_star_attr[total_star]
    if level_up_config == nil then return end

    local rio = 0
    if star_attr_config then
        rio = star_attr_config.rio
    end

    for i,v in ipairs(level_up_config.attr) do
        local total_val, add_val = self:countLevelAttr(v[2], rio, total_star, v[1])
        local param = self.param_list[i]
        if param then

            local res, attr_name, attr_val = commonGetAttrInfoByKeyValue(v[1], v[2])
            local attr_key_str = string_format("<img src='%s' scale=1 />     %s:", res, attr_name)
            param.key:setString(attr_key_str)
            local attr_val_str = string_format("%s<div fontcolor=#0e7709>(+%s)</div>", total_val, add_val)
            param.left:setString(attr_val_str)
            if next_level_up_config then --有下一级
                local base_val = next_level_up_config.attr[i][2] or 0
                local next_total_val, next_add_val = self:countLevelAttr(base_val, rio, total_star, v[1])
                local str = string_format("%s<div fontcolor=#0e7709>(+%s)</div>", next_total_val, next_add_val)
                param.right:setString(str)
                param.arrow:setVisible(true)

            else--满级
                param.arrow:setVisible(false)
                param.right:setString("")
            end 
        end
    end

    if next_level_up_config then
        --self.common_90034:setVisible(true)
        --self.param_lay:setPositionX(243)
    else
        --满级
        --self.common_90034:setVisible(false)
        --self.param_lay:setPositionX(360)
    end

    local per = rio/10
    local str = string_format(TI18N("(历史供奉宝可梦最高总星数为:%s, 星级加成:%s%%"), total_star, per)
    self.star_tips:setString(str)
end

--计算等级对应的属性
function HeroResonateTabStoneTabletPanel:countLevelAttr(base_val, base_add_val, total_star, attr_key)
    local base_val = base_val or 0
    local base_add_val = base_add_val or 0
    
    -- 某个属性总加成值 = 基础值*(1+总星级/(总星级+4))              
    local add_val = base_val * base_add_val/1000
    local total_val = base_val + add_val
    total_val = math_floor(total_val + 0.5)
    add_val = math_floor(add_val + 0.5)
    total_val = changeBtValueForHeroAttr(total_val, attr_key)
    add_val = changeBtValueForHeroAttr(add_val, attr_key)
    return total_val, add_val
end

function HeroResonateTabStoneTabletPanel:updateCostInfo(  )
    if not self.scdata then return end
    if self.dic_config_level_up[self.scdata.lev] == nil then
        self.dic_config_level_up[self.scdata.lev] = Config.ResonateData.data_level_up(self.scdata.lev)
    end
    local level_up_config = self.dic_config_level_up[self.scdata.lev]
    if not level_up_config then return end

    if level_up_config and level_up_config.expend and next(level_up_config.expend) ~= nil then
        for i=1,2 do
            local cost_data = level_up_config.expend[i]
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
                        cost_txt:setTextColor(Config.ColorData.data_new_color4[6] )
                    else
                        cost_txt:setTextColor(Config.ColorData.data_new_color4[11])
                    end
                end
            else
                cost_txt:setString("")
            end
        end
    end
    self:checkResonateStoneRedpoint()
end




function HeroResonateTabStoneTabletPanel:setVisibleStatus(bool)
    self:setVisible(bool)
end

--移除
function HeroResonateTabStoneTabletPanel:DeleteMe()
    if self.hero_resonate_info_event then
        GlobalEvent:getInstance():UnBind(self.hero_resonate_info_event)
        self.hero_resonate_info_event = nil
    end
    if self.select_hero_event then
        GlobalEvent:getInstance():UnBind(self.select_hero_event)
        self.select_hero_event = nil
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

    doStopAllActions(self.main_container)
    doStopAllActions(self.bottom_panel)

end

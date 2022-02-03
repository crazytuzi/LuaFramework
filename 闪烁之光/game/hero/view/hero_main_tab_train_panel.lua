-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      竖版伙伴培养信息面板
-- <br/> 2018年11月15日
-- --------------------------------------------------------------------
HeroMainTabTrainPanel = class("HeroMainTabTrainPanel", function()
    return ccui.Widget:create()
end)

local string_format = string.format
local controller = HeroController:getInstance()
local model = controller:getModel()
local table_insert = table.insert
local role_vo = RoleController:getInstance():getRoleVo()

function HeroMainTabTrainPanel:ctor(parent)  
    self:config()
    self:layoutUI()
    self:registerEvents()
end
function HeroMainTabTrainPanel:config()
    -- self.size = cc.size(680,372.97)
    -- self:setContentSize(self.size)
    --进阶icon
    self.break_icon_bg_list = {}
    self.break_icon_list = {}

    -- 属性列表..写死..
    self.attr_list = {[1]="atk",[2]="hp",[3]="def",[4]="speed"}

    --技能 
    self.skill_width = 88
    self.skill_item_list = {}

    --记录
    self.record_cost_res = {}

    self.cystal_max_lev_limit = 400
    local config = Config.ResonateData.data_const.cystal_max_lev_limit
    if config then
        self.cystal_max_lev_limit = config.val
    end
end

function HeroMainTabTrainPanel:layoutUI()
    local csbPath = PathTool.getTargetCSB("hero/hero_main_tab_train_panel")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    --读取文件的大小
    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.tab_panel = self.root_wnd:getChildByName("tab_panel")

    self.tab_panel:getChildByName("levelKey"):setString(TI18N("等级:"))
    self.tab_panel:getChildByName("advancedKey"):setString(TI18N("进阶:"))

    --进阶node
    self.advanced_node = self.tab_panel:getChildByName("advanced_node")
    --等级
    local level = self.tab_panel:getChildByName("level")
    level:setVisible(false)
    local x, y = level:getPosition()
    self.level = createRichLabel(24, cc.c4b(0x9E,0x50,0x1B,0xff), cc.p(0, 0.5), cc.p(x,y),nil,nil,600)
    self.tab_panel:addChild(self.level)
    --升级信息
    self.level_up_bg = self.tab_panel:getChildByName("bg_1")
    self.item_icon1 = self.tab_panel:getChildByName("item_icon1")
    self.item_icon2 = self.tab_panel:getChildByName("item_icon2")
    self.level_up_cost1 = self.tab_panel:getChildByName("level_up_cost1")
    self.level_up_cost2 = self.tab_panel:getChildByName("level_up_cost2")
    self.level_up_btn = self.tab_panel:getChildByName("level_up_btn")
    self.level_up_label = self.level_up_btn:getChildByName("label")

    --属性信息
    self.attr_icon_list = {}
    self.attr_icon_list[1] = self.tab_panel:getChildByName("attr_icon1")
    self.attr_icon_list[2] = self.tab_panel:getChildByName("attr_icon2")
    self.attr_icon_list[3] = self.tab_panel:getChildByName("attr_icon3")
    self.attr_icon_list[4] = self.tab_panel:getChildByName("attr_icon4")
    self.attr_label_list = {}
    self.attr_label_list[1] = self.tab_panel:getChildByName("attr_label1")
    self.attr_label_list[2] = self.tab_panel:getChildByName("attr_label2")
    self.attr_label_list[3] = self.tab_panel:getChildByName("attr_label3")
    self.attr_label_list[4] = self.tab_panel:getChildByName("attr_label4")

    --职业
    self.profession_icon = self.tab_panel:getChildByName("profession_icon")
    self.profession_icon:setPositionX(369)
    self.profession_name = self.tab_panel:getChildByName("profession_name")
    local x, y = self.profession_name:getPosition()
    x = x - 22
    self.profession_name:setPositionX(x)
    self.introduce_label = createLabel(24, cc.c3b(0x9e,0x50,0x1b), nil, x + 52, y, "", self.tab_panel, 2, cc.p(0,0.5))

    self.look_btn = self.tab_panel:getChildByName("look_btn")
    --技能scrollview
    self.skill_container = self.tab_panel:getChildByName("skill_container")
    self.skill_container:setScrollBarEnabled(false)
    self.skill_container:setTouchEnabled(false)
    self.skill_container_size = self.skill_container:getContentSize()

    --属性icon
    for i,attr_str in ipairs(self.attr_list) do
        if self.attr_icon_list[i] then
            local res_id = PathTool.getAttrIconByStr(attr_str)
            local res = PathTool.getResFrame("common",res_id)
            loadSpriteTexture(self.attr_icon_list[i], res, LOADTEXT_TYPE_PLIST)   
        end
    end

    self.fuse_btn_label = createRichLabel(22,cc.c3b(0x24,0x90,0x03), cc.p(0.5,0.5),cc.p(366, 300))
    self.fuse_btn_label:setString(string_format("<div href=xxx>%s</div>", TI18N("可在原力水晶中升级")))
    self.tab_panel:addChild(self.fuse_btn_label)

    self.fuse_btn_label:addTouchLinkListener(function(type, value, sender, pos)
        if self.hero_vo then
            JumpController:getInstance():jumpViewByEvtData({55})
        end
    end, { "click", "href" })
end

--事件
function HeroMainTabTrainPanel:registerEvents()
    -- registerButtonEventListener(self.level_up_btn, function() self:onClickLevelUpBtn()  end ,true, 2)
    self.level_up_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        
        if event_type == ccui.TouchEventType.began then
            self.is_click_btn = false --标志只点一次btn
            if GuideController:getInstance():isInGuide() then return end
            local sequence_action = cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(function() 
                self:startTimeTicket()
            end))
            self.sequence_action = self.level_up_btn:runAction(sequence_action)
            self.sequence_action:setTag(1)
        elseif event_type == ccui.TouchEventType.moved then

        elseif event_type == ccui.TouchEventType.canceled then
            self:clearTimeTicket()
        elseif event_type == ccui.TouchEventType.ended then
            self:clearTimeTicket()
            if not self.is_click_btn then
                playButtonSound2()
                GlobalEvent:getInstance():Fire(HeroEvent.Hero_Can_Play_Level_UP_Music_Event)
                self:onClickLevelUpBtn()
            end
        end
    end)

    --详情
    registerButtonEventListener(self.look_btn, function() self:onClickLookBtn()  end ,true, 2, nil, 0.8)

    --英雄信息更新
    if self.hero_data_update_event == nil then
        self.hero_data_update_event = GlobalEvent:getInstance():Bind(HeroEvent.Hero_Data_Update, function(hero_vo)
            if not hero_vo or not self.hero_vo then return end
            if hero_vo.partner_id == self.hero_vo.partner_id then
                self.is_send_level = false
                self:updateInfo(hero_vo)
                self.is_update_hero_info = true
                self:setUpdateRedPointInfo()
            end
        end)
    end  

    --英雄信息更新
    if self.hero_detail_data_update_event == nil then
        self.hero_detail_data_update_event = GlobalEvent:getInstance():Bind(HeroEvent.Hero_Detail_Data_Update, function(hero_vo)
            if not hero_vo or not self.hero_vo then return end
            if hero_vo.partner_id == self.hero_vo.partner_id then
               self:updateAttr(hero_vo)
            end
        end)
    end
    --穿戴装备影响属性
    if self.hero_equip_update_event == nil then
        self.hero_equip_update_event = GlobalEvent:getInstance():Bind(HeroEvent.Equip_Update_Event, function()
            if not self.hero_vo then return end
            self:updateAttr(self.hero_vo)
        end)
    end
    --穿戴符文(神器)影响属性
    if self.hero_artifact_update_event == nil then
        self.hero_artifact_update_event = GlobalEvent:getInstance():Bind(HeroEvent.Artifact_Update_Event, function()
            if not self.hero_vo then return end
            self:updateAttr(self.hero_vo)
        end)
    end
    if self.hero_level_redpoint_event == nil then
        self.hero_level_redpoint_event = GlobalEvent:getInstance():Bind(HeroEvent.Level_RedPoint_Event, function(hero_vo)
            if not self.hero_vo then return end
            self.is_update_res_info = true
            self:setUpdateRedPointInfo()
        end)
    end

    --物品道具增加 判断红点
    if not self.add_goods_event then
        self.add_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS, function(bag_code,temp_add)
            if self.show_model_type == HeroConst.BagTab.eBagHero then 
                if bag_code ~= BackPackConst.Bag_Code.EQUIPS then 
                    for i,item in pairs(temp_add) do
                        if item.base_id == model.upgrade_star_cost_id or item.base_id == model.upgrade_star_cost_id_2 then
                            self.hero_vo.red_point[HeroConst.RedPointType.eRPLevelUp] = nil 
                            self:updateLevelUpRedPoint()
                        end
                    end
                end
            end
        end)
    end
    --物品道具删除 判断红点
    if not self.del_goods_event then
        self.del_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS, function(bag_code,temp_del)
            if self.show_model_type == HeroConst.BagTab.eBagHero then 
                if bag_code ~= BackPackConst.Bag_Code.EQUIPS then 
                    for i,item in pairs(temp_del) do
                        if item.base_id == model.upgrade_star_cost_id or item.base_id == model.upgrade_star_cost_id_2 then
                            self.hero_vo.red_point[HeroConst.RedPointType.eRPLevelUp] = nil 
                            self:updateLevelUpRedPoint()
                        end
                    end
                end
            end
        end)
    end

    --物品道具改变 判断红点
    if not self.modify_goods_event then
        self.modify_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code,temp_list)
            if self.show_model_type == HeroConst.BagTab.eBagHero then 
                if bag_code ~= BackPackConst.Bag_Code.EQUIPS then 
                    for i,item in pairs(temp_list) do
                        if item.base_id == model.upgrade_star_cost_id or item.base_id == model.upgrade_star_cost_id_2 then
                            self.hero_vo.red_point[HeroConst.RedPointType.eRPLevelUp] = nil 
                            self:updateLevelUpRedPoint()
                        end
                    end
                end
            end
        end)
    end

    if role_vo ~= nil then
        if self.role_lev_event == nil then
            self.role_lev_event =  role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, lev) 
                if not self.hero_vo then return end
                local status = HeroCalculate.getHeroShowLevelStatus(self.hero_vo) 
                if status == 1 then
                    if key == "coin" then
                        self:updateCostInfo(self.hero_vo)
                    elseif key == "hero_exp" then
                        self:updateCostInfo(self.hero_vo)
                    end
                end
            end)
        end
    end
end

function HeroMainTabTrainPanel:setUpdateRedPointInfo()
    if self.is_update_res_info and self.is_update_hero_info then
        --清空红点记录
        self.hero_vo.red_point[HeroConst.RedPointType.eRPLevelUp] = nil 
        self:updateLevelUpRedPoint()
    end
end

function HeroMainTabTrainPanel:onClickLookBtn()
    if not self.hero_vo then return end
    controller:openHeroTipsAttrPanel(true, self.hero_vo, true)
end

--点击事件
function HeroMainTabTrainPanel:startTimeTicket()
    if self.time_ticket == nil then
        self.time_idnex = 0
        local _callback = function()
            self.is_click_btn = true
            -- playButtonSound2()
            self:onClickLevelUpBtn()
            self.time_idnex = self.time_idnex + 1
            if self.time_idnex > 5 then
                self.time_idnex = 0
                GlobalEvent:getInstance():Fire(HeroEvent.Hero_Can_Play_Level_UP_Music_Event)
            end
        end

        self.time_ticket = GlobalTimeTicket:getInstance():add(_callback, 5 / display.DEFAULT_FPS)
    end
end

function HeroMainTabTrainPanel:clearTimeTicket()
    if self.sequence_action then
        self.level_up_btn:stopActionByTag(1)
        -- self.level_up_btn:stopAction(self.sequence_action)
        self.sequence_action = nil
    end
    self.is_send_level = false
    if self.time_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.time_ticket)
        self.time_ticket = nil
    end
end 


--升级或者进阶
function HeroMainTabTrainPanel:onClickLevelUpBtn()
    if not self.hero_vo then return end
    local status = HeroCalculate.getHeroShowLevelStatus(self.hero_vo) 
    if status == 1 then
        if self.is_send_level then
            return
        end
        self.is_send_level = true
        --升级
        self.is_update_hero_info = false
        self.is_update_res_info = false
        controller:sender11003(self.hero_vo.id)
    elseif status == 2 then
        --可以进阶了
        controller:openHeroBreakPanel(true, self.hero_vo) 
    end
end

--@hero_vo 英雄数据
--@show_model_type 显示模式 1:英雄模式  2:图鉴模式 定义参考 HeroConst.BagTab.eBagHero
function HeroMainTabTrainPanel:setData(hero_vo, show_model_type)
    if not hero_vo then return end
    self.limit_lev_max = nil
    self.hero_vo = hero_vo
    self:updateInfo(hero_vo)
    self.show_model_type = show_model_type or HeroConst.BagTab.eBagHero
    if self.show_model_type == HeroConst.BagTab.eBagHero then
        self:updateLevelUpRedPoint()
    end

    if self.level_up_btn:isVisible() and self.hero_vo.isResonateCrystalHero and self.hero_vo:isResonateCrystalHero() then
        if self.tips == nil then
            local tips_str = TI18N("在原力水晶中无法升级")
            self.tips = createLabel(20, cc.c3b(0xd9,0x50,0x14), nil, 576, 350, tips_str, self.tab_panel, 2, cc.p(0.5,0.5))
        else
            self.tips:setVisible(true)
        end
        setChildUnEnabled(true, self.level_up_btn)
        self.level_up_label:enableOutline(Config.ColorData.data_color4[2], 2)
        self.level_up_btn:setTouchEnabled(false)
    else
        self.level_up_btn:setTouchEnabled(true)
        setChildUnEnabled(false, self.level_up_btn)
        self.level_up_label:enableOutline(Config.ColorData.data_color4[278], 2)
        if self.tips then
            self.tips:setVisible(false)
        end
    end
end

function HeroMainTabTrainPanel:updateInfo(hero_vo)
    if not hero_vo then return end
    
    local break_lev = hero_vo.break_lev
    local lev = hero_vo.lev
    if hero_vo.isResonateCrystalHero and hero_vo:isResonateCrystalHero() then
        lev = hero_vo.resonate_lev
        break_lev = hero_vo.resonate_break_lev
    end
    --进阶
    self:updateAdvanceInfo(hero_vo, break_lev)
    
    local key = getNorKey(hero_vo.type, hero_vo.break_id, break_lev)
    local break_config = Config.PartnerData.data_partner_brach[key]
    if not break_config then return end --没有数据就不处理了
    local next_key = getNorKey(hero_vo.type, hero_vo.break_id, break_lev + 1)
    local next_break_config = Config.PartnerData.data_partner_brach[next_key]

   
    if self.fuse_btn_label then
        self.fuse_btn_label:setVisible(false)
    end
    --上限等级
    local lev_max = break_config.lev_max
    self.limit_lev_max = lev_max
    if next_break_config == nil then
        local key = getNorKey(hero_vo.bid, hero_vo.star)
        local star_config = Config.PartnerData.data_partner_star(key)
        if star_config and lev_max < star_config.lev_max then
            lev_max = star_config.lev_max
            self.limit_lev_max = lev_max
        end

        if lev >= lev_max then
            -- 都满了  满级状态
            self:showMaxLevelUI(true)
            self.level_up_btn:setVisible(false)
            if self.fuse_btn_label and model:isResonateCystalMaxLev() and model:isCanShowLabelMaxLev(lev_max) then
                self.fuse_btn_label:setVisible(true)
            end
        else
            --等级不足 需要升级
            self.level_up_btn:setVisible(true)
            self:updateCostInfo(hero_vo)
        end
    else
        if next_break_config.limit and next(next_break_config.limit) ~= nil then
            if lev >= break_config.lev_max then
                --进阶有要求 需要升星
                local is_enough = HeroCalculate.isEnoughCondition(next_break_config.limit, hero_vo)
                if is_enough then
                    --可以进阶了
                    self:showMaxLevelUI(true)
                    self.level_up_btn:setVisible(true)
                    self.level_up_label:setString(TI18N("进阶"))
                else
                    --不满足条件.显示满级状态
                    self:showMaxLevelUI(true)
                    self.level_up_btn:setVisible(false)
                end
            else
                --等级不足 需要升级
                self.level_up_btn:setVisible(true)
                -- self:setLevName(hero_vo)
                -- self:showMaxLevelUI(false)
                self:updateCostInfo(hero_vo)
            end
        else
            --没有限制
            self.level_up_btn:setVisible(true)
            if lev >= break_config.lev_max then
                --可以进阶了
                self:showMaxLevelUI(true)
                self.level_up_label:setString(TI18N("进阶"))
            else
                -- self:setLevName(hero_vo)
                -- self:showMaxLevelUI(false)
                self:updateCostInfo(hero_vo)
            end
        end

    end
    
    if hero_vo.isResonateHero and hero_vo:isResonateHero() then
        self.level_up_btn:setVisible(false)
    end

    --等级
    if hero_vo.isResonateCrystalHero and hero_vo:isResonateCrystalHero() then
        if hero_vo.resonate_lev >= model:getCystalPreLevLimit() then
            local str = string_format("<div fontcolor=#00c8b3>%s</div>", hero_vo.lev)
            self.level:setString(str)   
            if hero_vo.lev >= self.cystal_max_lev_limit then --已经是满级就不显示了
                self.fuse_btn_label:setVisible(false) 
            end
        else
            local str = string_format("<div fontcolor=#00c8b3>%s</div>/%s", hero_vo.lev, lev_max)
            self.level:setString(str)    
        end
        
    else
        local str = string_format("%s/%s", hero_vo.lev, lev_max)
        self.level:setString(str)
    end
    --更新属性
    self:updateAttr(hero_vo)

    --职业
    local hero_type = hero_vo.type or 4
    local res = PathTool.getPartnerTypeIcon(hero_type)
    loadSpriteTexture(self.profession_icon, res, LOADTEXT_TYPE_PLIST)
    local name = HeroConst.CareerName[hero_type] or TI18N("无")
    self.profession_name:setString(name)
    if self.introduce_label then
        if hero_vo.introduce_str and hero_vo.introduce_str ~= "" then
            self.introduce_label:setString(hero_vo.introduce_str)
        else
            self.introduce_label:setString("")
        end
    end

    
    if hero_vo.isResonateCrystalHero and hero_vo:isResonateCrystalHero() then
        local key = getNorKey(hero_vo.type, hero_vo.break_id, hero_vo.break_lev)
        break_config = Config.PartnerData.data_partner_brach[key]
    end
    -- 技能
    self:initSkill(hero_vo, break_config)
end

function HeroMainTabTrainPanel:updateAttr(hero_vo)
    if not hero_vo then return end
    --属性
    for i,attr_str in ipairs(self.attr_list) do
        if self.attr_label_list[i] then
            local value = hero_vo[attr_str] or 0
            self.attr_label_list[i]:setString(value)
        end
    end
end

function HeroMainTabTrainPanel:updateLevelUpRedPoint()
    if not self.hero_vo then return end
    --升级按钮红点
    local is_redpoint = HeroCalculate.checkSingleHeroLevelUpRedPoint(self.hero_vo)
    addRedPointToNodeByStatus( self.level_up_btn, is_redpoint, 5, 5)
end

function HeroMainTabTrainPanel:setLevName(hero_vo, lev)
    if not hero_vo then return end
    if lev > 1 then
        self.level_up_label:setString(string_format(TI18N("升%s级"), lev))
    else
        self.level_up_label:setString(TI18N("升 级"))
    end
end

function HeroMainTabTrainPanel:updateCostInfo(hero_vo)
    if not hero_vo then return end
    if not self.limit_lev_max then return end

    local lev = hero_vo.lev or 1
    if hero_vo.isResonateCrystalHero and hero_vo:isResonateCrystalHero() then
        lev = hero_vo.resonate_lev or 1
    end

    self:showMaxLevelUI(false)
    local max_lev_num = 1
    if lev < 60 then
        max_lev_num = 5
    end
    --能升多少级
    --能够升级最大等级
    local can_upgrade_max_lev = lev
    local dic_cost_list = {} --总消耗

    local function _checkEnough(up_cost)
        local cur_cost_list = {}
        local is_enough = true
        for i,cost in ipairs(up_cost) do
            if dic_cost_list[cost[1]] == nil then
                dic_cost_list[cost[1]] = 0
            end
            cur_cost_list[cost[1]] = dic_cost_list[cost[1]] + cost[2]
            local count = BackpackController:getInstance():getModel():getItemNumByBid(cost[1]) or 0
            if count < cur_cost_list[cost[1]] then
                --不够了
                is_enough = false
            end
        end

        return is_enough, cur_cost_list
    end


    --升级消耗
    for i=1,max_lev_num do
        local lev1 = lev + i - 1
        if lev1 >= self.limit_lev_max then
            break
        end
        local lev_config = Config.PartnerData.data_partner_lev[lev1]
        if lev_config then

            local up_cost = lev_config.expend or {}
            local is_enough, cost_list = _checkEnough(up_cost)

            if is_enough then
                dic_cost_list = cost_list
                can_upgrade_max_lev = lev1
            else
                if i == 1 then
                    dic_cost_list = cost_list
                end
                break
            end
        end 
    end

    self:setLevName(hero_vo, can_upgrade_max_lev - lev + 1)
    local lev_config = Config.PartnerData.data_partner_lev[lev]
    if lev_config then
        local up_cost = lev_config.expend or {}
        for i,cost in ipairs(up_cost) do
            local config = Config.ItemData.data_get_data(cost[1])
            local item_icon = self["item_icon"..i]
            if config and item_icon then
                local head_icon = PathTool.getItemRes(config.icon, false)
                if self.record_cost_res[i] == nil or self.record_cost_res[i] ~= head_icon then
                    self.record_cost_res[i] = head_icon
                    loadSpriteTexture(item_icon, head_icon, LOADTEXT_TYPE) 
                    item_icon:setScale(0.3)       
                end
            end
            if self["level_up_cost"..i] then
                self["level_up_cost"..i]:setString(dic_cost_list[cost[1]])
                local count = BackpackController:getInstance():getModel():getItemNumByBid(cost[1])
                if dic_cost_list[cost[1]] and count < dic_cost_list[cost[1]] then
                    -- self["level_up_cost"..i]:enableOutline(cc.c4b(0xc7,0x0c,0x0c,0xff), 1)
                    self["level_up_cost"..i]:setTextColor(cc.c4b(0xc7,0x0c,0x0c,0xff))
                else
                    self["level_up_cost"..i]:setTextColor(cc.c4b(0x64,0x32,0x23,0xff))
                    -- self["level_up_cost"..i]:enableOutline(cc.c4b(0x00,0x00,0x00,0xff), 1)
                end
            end
        end
    end
end

function HeroMainTabTrainPanel:showMaxLevelUI(status)
    if status then
        if self.max_level_img == nil then
            local res = PathTool.getResFrame("hero","txt_cn_hero_info_16")
            self.max_level_img = createImage(self.tab_panel, res, 174, 298,cc.p(0.5,0.5),true)
        else
            self.max_level_img:setVisible(true)
        end
        self.level_up_bg:setVisible(false)
        self.item_icon1:setVisible(false)
        self.item_icon2:setVisible(false)
        self.level_up_cost1:setString("")
        self.level_up_cost2:setString("")
    else
        if self.max_level_img then
            self.max_level_img:setVisible(false)
        end
        self.level_up_bg:setVisible(true)
        self.item_icon1:setVisible(true)
        self.item_icon2:setVisible(true)
    end
end

--更新进阶显示
function HeroMainTabTrainPanel:updateAdvanceInfo(hero_vo, break_lev)
    local max_count = model:getHeroMaxBreakCountByInitStar(hero_vo.star)
    local star_width = 27 + 8
    local break_count = break_lev
    local x = 0
    for i,v in ipairs(self.break_icon_list) do
        v:setVisible(false)
    end
    for i=1,max_count do
        if i <= break_count then
            if not self.break_icon_list[i] then
                local res = PathTool.getResFrame("hero","hero_info_1")
                local star = createSprite(res, x + (i-1)*star_width, 0, self.advanced_node, cc.p(0,0.5), LOADTEXT_TYPE_PLIST, 1)
                -- star:setScale(0.6)
                self.break_icon_list[i] = star
            else
                self.break_icon_list[i]:setVisible(true)
            end
            
            if self.break_icon_bg_list[i] then
                self.break_icon_bg_list[i]:setVisible(false)
            end
        else
            if self.break_icon_list[i] then
                self.break_icon_list[i]:setVisible(false)
            end
            if not self.break_icon_bg_list[i] then
                local res = PathTool.getResFrame("hero","hero_info_2")
                local star = createSprite(res, x + (i-1)*star_width, 0, self.advanced_node, cc.p(0,0.5), LOADTEXT_TYPE_PLIST, 0)
                -- star:setScale(0.6)
                self.break_icon_bg_list[i] = star
            else
                self.break_icon_bg_list[i]:setVisible(true)
            end
        end
    end
end


function HeroMainTabTrainPanel:initSkill(hero_vo, break_config)
    local key = getNorKey(hero_vo.bid, hero_vo.star)
    local star_config = Config.PartnerData.data_partner_star(key)
    if star_config == nil then return end

    local skill_list = {}
    for i,v in ipairs(star_config.skills) do
        -- 不是普通攻击 1表示普通攻击
        if v[1] ~= 1 then
            table_insert(skill_list, v)
        end
    end
    --技能item的宽度
    local item_width = self.skill_width + 28
    local total_width = item_width * #skill_list
    local max_width = math.max(self.skill_container_size.width, total_width)
    self.skill_container:setInnerContainerSize(cc.size(max_width, self.skill_container_size.height))

    for i,v in ipairs(self.skill_item_list) do
        v:setVisible(false)
    end
    
    local x = 0
    if total_width > self.skill_container_size.width then
        --技能的总宽度大于 显示的宽度 就从左往右显示
        x = 0
    else
        --否则从中从中间显示
        x = (self.skill_container_size.width - total_width) * 0.5
    end

    for i,skill in ipairs(skill_list) do
        local config = Config.SkillData.data_get_skill(skill[2])
        if config then
            --是否锁住
            local is_lock = false
            if skill[1] > break_config.skill_num  then
                is_lock = true
            end
            if self.skill_item_list[i] == nil then
                self.skill_item_list[i] = {}
                self.skill_item_list[i] = SkillItem.new(true,true,true,0.8, true)
                self.skill_container:addChild(self.skill_item_list[i])
            end
            self.skill_item_list[i]:setData(config)
            self.skill_item_list[i]:showUnEnabled(is_lock)
            self.skill_item_list[i]:setVisible(true)
            self.skill_item_list[i]:setPosition( x + item_width * (i - 1) + item_width * 0.5, self.skill_width/2 + 6)
        else 
            print(string_format("技能表id: %s 没发现", tostring(skill.skill_bid)))
        end
    end
end


function HeroMainTabTrainPanel:setVisibleStatus(bool)
    self:setVisible(bool)
end

--移除
function HeroMainTabTrainPanel:DeleteMe()
    if self.hero_data_update_event then
        GlobalEvent:getInstance():UnBind(self.hero_data_update_event)
        self.hero_data_update_event = nil
    end
    if self.hero_detail_data_update_event then
        GlobalEvent:getInstance():UnBind(self.hero_detail_data_update_event)
        self.hero_detail_data_update_event = nil
    end
    if self.hero_equip_update_event then
        GlobalEvent:getInstance():UnBind(self.hero_equip_update_event)
        self.hero_equip_update_event = nil
    end
    if self.hero_artifact_update_event then
        GlobalEvent:getInstance():UnBind(self.hero_artifact_update_event)
        self.hero_artifact_update_event = nil
    end
    if self.hero_level_redpoint_event then
        GlobalEvent:getInstance():UnBind(self.hero_level_redpoint_event)
        self.hero_level_redpoint_event = nil
    end
    self:clearTimeTicket()

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
end

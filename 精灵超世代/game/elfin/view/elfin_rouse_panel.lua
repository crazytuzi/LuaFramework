--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-08-13 15:36:39
-- @description    : 
		-- 精灵主界面
---------------------------------
ElfinRousePanel = class("ElfinRousePanel",function()
    return ccui.Layout:create()
end)

local _controller = ElfinController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _table_sort = table.sort
local _string_format = string.format

function ElfinRousePanel:ctor()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("hero/hero_elfin_rouse_panel"))

    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd)

    -- 初始化数据
    self:initElfinData()

    -- 资源加载
    local res_list = {}
    _table_insert(res_list, {path = PathTool.getPlistImgForDownLoad("elfin", "elfin"), type = ResourcesType.plist})
    if self.init_res_load then
        self.init_res_load:DeleteMe()
        self.init_res_load = nil
    end
    self.init_res_load = ResourcesLoad.New()
    self.init_res_load:addAllList(res_list, function()
        if not tolua.isnull(self.root_wnd) then
            self:loadResListCompleted()
        end
    end)
end

function ElfinRousePanel:loadResListCompleted( )
	self:initView()
    self:registerEvent()

    self:changeSelectedTab()
    self:updateElfinRedInfo()
end


-- 初始化数据
function ElfinRousePanel:initElfinData(  )
    
    self.tree_elfin_list = {} -- 古树的四个精灵
    self.tree_skill_list = {} -- 古树的技能图标
    self.tree_attr_list = {}  -- 古树的属性
    self.tree_step_max = false  -- 古树是否达到当前阶级的最大等级
    self.tree_is_max_step = false -- 古树是否达到最大阶数
end

-- 初始化界面
function ElfinRousePanel:initView(  )
	self.container = self.root_wnd:getChildByName("container")

    self.elfin_book_txt = createRichLabel(24, Config.ColorData.data_new_color4[15], cc.p(1, 0.5), cc.p(700, 700))
    self.container:addChild(self.elfin_book_txt)
    self.elfin_book_txt:setString(_string_format(TI18N("<div href=xxx >传记 </div><img src='%s'/>"), PathTool.getResFrame("elfin","elfin_1016")))
    self.elfin_book_txt:addTouchEventListener(function (  )
        local tree_story_cfg = Config.SpriteData.data_const["ancient_story"]
        if tree_story_cfg then
            HeroController:getInstance():openHeroLibraryStoryPanel(true, TI18N("精灵古树 费普斯"), tree_story_cfg.desc)
        end
    end)

    -- 唤醒
    self.rouse_panel = self.container:getChildByName("rouse_panel")
    self.rouse_panel:getChildByName("rouse_name_txt"):setString(TI18N("精灵古树 费普斯"))
    self.rouse_panel:getChildByName("rouse_tips"):setString(TI18N("精灵依附在费普斯身上，可借助其古树之力与宝可梦协同作战"))
    self.rouse_panel:getChildByName("skill_title"):setString(TI18N("施法顺序:"))
    self.rouse_panel:getChildByName("rouse_lv_title"):setString(TI18N("复苏等级:"))
    self.rouse_panel:getChildByName("rouse_step_title"):setString(TI18N("唤醒阶段:"))

    self.rouse_bg = self.rouse_panel:getChildByName("rouse_bg")
    self.rouse_bg:ignoreContentAdaptWithSize(true)
    self.rouse_lv_txt = self.rouse_panel:getChildByName("rouse_lv_txt")
    self.rouse_step_txt = self.rouse_panel:getChildByName("rouse_step_txt")

    self.power_click = self.rouse_panel:getChildByName("power_click")
    self.score_title = self.power_click:getChildByName("score_title")
    self.score_title:setString(TI18N("评分："))
    self.fight_label = CommonNum.new(20, self.power_click, 99999, - 2, cc.p(0.5, 0.5))
    self.fight_label:setPosition(103, 35)

    self.rouse_rule_btn = self.rouse_panel:getChildByName("rouse_rule_btn")
    self.rouse_btn = self.rouse_panel:getChildByName("rouse_btn")
    self.rouse_btn_label = self.rouse_btn:getChildByName("label")
    self.rouse_btn_label:setString(TI18N("复苏"))
    self.adjust_btn = self.rouse_panel:getChildByName("adjust_btn")

    self.max_lv_sp = self.rouse_panel:getChildByName("max_lv_sp")
    self.rouse_cost_panel = self.rouse_panel:getChildByName("cost_panel")
    self.cost_objects = {}
    for i=1,2 do
        local object = {}
        object.res_icon = self.rouse_cost_panel:getChildByName("cost_res_icon_" .. i)
        object.cost_txt = self.rouse_cost_panel:getChildByName("cost_txt_" .. i)
        _table_insert(self.cost_objects, object)
    end
end

function ElfinRousePanel:registerEvent(  )

    registerButtonEventListener(self.rouse_btn, function (  )
        self:onClickRouseBtn()
    end, true)


    registerButtonEventListener(self.adjust_btn, function (  )
        self:onClickAdjustBtn()
    end, true)


    -- 复苏/唤醒
    self.rouse_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.began then
            if GuideController:getInstance():isInGuide() or self.tree_is_max_step == true then return end
            if not self.tree_step_max then -- 复苏支持长按
                local action = cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(function() 
                    self:startTimeTicket()
                end))
                self.sequence_action = self.rouse_btn:runAction(action)
                self.sequence_action:setTag(10086)
            end
        elseif event_type == ccui.TouchEventType.canceled then
            self:clearTimeTicket()
        elseif event_type == ccui.TouchEventType.ended then
            self:clearTimeTicket()
            self:onClickRouseBtn()
        end
    end)

    registerButtonEventListener(self.rouse_rule_btn, function ( param, sender, event_type )
        self:onClickRouseRuleBtn(param, sender, event_type)
    end, true, nil, nil, 0.8)



    -- 古树信息
    if not self.get_tree_data_event then
        self.get_tree_data_event = GlobalEvent:getInstance():Bind(ElfinEvent.Get_Elfin_Tree_Data_Event, function ( )
            self:updateRouseInfo()
        end)
    end

    -- 古树升级成功
    if not self.tree_up_lv_event then
        self.tree_up_lv_event = GlobalEvent:getInstance():Bind(ElfinEvent.Elfin_Tree_Lv_Up_Event, function ( )
           
        end)
    end


    -- 物品数量变化
    if not self.add_goods_event then
        self.add_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS, function(bag_code, item_list)
            if bag_code ~= BackPackConst.Bag_Code.BACKPACK then return end
            self:checkNeedUpdateItemNum(item_list)
        end)
    end
    if not self.del_goods_event then
        self.del_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS, function(bag_code, item_list)
            if bag_code ~= BackPackConst.Bag_Code.BACKPACK then return end
            self:checkNeedUpdateItemNum(item_list)
        end)
    end
    if not self.modify_goods_event then
        self.modify_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code, item_list)
            if bag_code ~= BackPackConst.Bag_Code.BACKPACK then return end
            self:checkNeedUpdateItemNum(item_list)
        end)
    end

    -- 红点
    if not self.update_red_status_event then
        self.update_red_status_event = GlobalEvent:getInstance():Bind(ElfinEvent.Update_Elfin_Red_Event, function ( bid, status )
            self:updateElfinRedInfo(bid, status)
        end)
    end
end

function ElfinRousePanel:changeSelectedTab()
    self:updateRouseInfo()
    if not self.init_rouse_flag then
        self.init_rouse_flag = true
        _controller:sender26510() -- 第一次切换标签页时请求古树信息
    end
end


---------------------@ 精灵古树相关
-- 更新古树
function ElfinRousePanel:updateRouseInfo(  )
    
    self.elfin_tree_data = _model:getElfinTreeData()

    if not self.elfin_tree_data or next(self.elfin_tree_data) == nil then return end

    local level_cfg = Config.SpriteData.data_tree_up_lv(self.elfin_tree_data.lev)
    local step_cfg = Config.SpriteData.data_tree_step[self.elfin_tree_data.break_lev]
    if not step_cfg or not level_cfg then return end

    -- 背景
    local tree_bg_res = PathTool.getElfinTreeBgRes(step_cfg.res_id)
    if not self.cur_tree_bg_res or self.cur_tree_bg_res ~= tree_bg_res then
        self.cur_tree_bg_res = tree_bg_res
        self.tree_bg_load = loadImageTextureFromCDN(self.rouse_bg, tree_bg_res, ResourcesType.single, self.tree_bg_load)
    end
    self.fight_label:setNum(changeBtValueForPower(self.elfin_tree_data.power))

    -- 四个精灵位置和技能
    local cd_order = 0
    for i=1,4 do
        local elfin_bid = self:getTreeElfinBidByPos(i)
        -- 技能
        local skill_item = self.tree_skill_list[i]
        if not skill_item then
            skill_item = SkillItem.new(true, true, true, 0.75, true)
            self.rouse_panel:addChild(skill_item)
            skill_item:setPosition(cc.p(210+(i-1)*112, 280))
            self.tree_skill_list[i] = skill_item
        end
        skill_item:showNoneText(false)
        skill_item:setSkillFirstCd(0)
        if elfin_bid then
            skill_item:showLockIcon(false)
            local elfin_cfg = Config.SpriteData.data_elfin_data(elfin_bid)
            if elfin_bid == 0 or not elfin_cfg then -- 已解锁，但未放置精灵
                skill_item:setData()
                skill_item:showName(false)
                skill_item:showLevel(false)
                skill_item:showNoneText(true, TI18N("请先将精灵附着在古树上~"))
            else
                local skill_cfg = Config.SkillData.data_get_skill(elfin_cfg.skill)
                if skill_cfg then
                    skill_item:showLevel(true)
                    skill_item:setData(skill_cfg)
                    --skill_item:showName(true,skill_cfg.name,nil,20,true,cc.c4b(0xff,0xf0,0xd2,0xff),PathTool.getResFrame("elfin","elfin_1022"),cc.size(110,26))
                    skill_item:showName(false)
                    if skill_cfg.type == "active_skill" then -- 主动技能
                        cd_order = cd_order + 1
                        skill_item:setSkillFirstCd(cd_order)
                    end
                end
            end
        else
            -- 未解锁精灵位置
            skill_item:setData()
            skill_item:showName(false)
            skill_item:showLevel(false)
            local need_step = Config.SpriteData.data_tree_limit[i]
            if need_step then
                skill_item:showLockIcon(true, nil, _string_format(TI18N("古树达到%s阶解锁"), StringUtil.numToChinese(need_step)))
            end
        end
        
        -- 精灵位置
        local elfin_item = self.tree_elfin_list[i]
        if not elfin_item then
            elfin_item = ElfinRouseItem.new()
            self.rouse_panel:addChild(elfin_item)
            local pos_x = 120 + (1-i%2)*500
            local pos_y = 600 - (math.ceil(i/2)-1)*130
            elfin_item:setPosition(cc.p(pos_x, pos_y))
            self.tree_elfin_list[i] = elfin_item
        end
        local elfin_info = {}
        elfin_info.elfin_bid = elfin_bid
        elfin_info.elfin_pos = i
        elfin_info.need_step = Config.SpriteData.data_tree_limit[i]
        elfin_item:setData(elfin_info)
    end

    -- 复苏等级
    self.rouse_lv_txt:setString(self.elfin_tree_data.lev .. "/" .. step_cfg.lev_max)
    -- 唤醒阶段
    self.rouse_step_txt:setString(StringUtil.numToChinese(self.elfin_tree_data.break_lev) .. TI18N("阶"))

    -- 属性
    for k,txt in pairs(self.tree_attr_list) do
        txt:setVisible(false)
    end
    for i,attr_key in ipairs(ElfinConst.Tree_Attrs) do
        local attr_val = self.elfin_tree_data[attr_key]
        attr_val = changeBtValueForHeroAttr(attr_val, attr_key)
        -- 是否为百分比
        if PartnerCalculate.isShowPerByStr(attr_key) then
            attr_val = (attr_val/100).."%"
        end
        local attr_txt = self.tree_attr_list[i]
        if not attr_txt then
            attr_txt = createRichLabel(24, Config.ColorData.data_new_color4[6], cc.p(0, 0.5), nil, nil, nil, 380)
            self.rouse_panel:addChild(attr_txt)
            self.tree_attr_list[i] = attr_txt
        end
        attr_txt:setVisible(true)
        local pos_x = 117 + (1-i%2)*305
        local pos_y = 168 - (math.ceil(i/2)-1)*47
        attr_txt:setPosition(cc.p(pos_x, pos_y))
        local attr_icon = PathTool.getAttrIconByStr(attr_key)
        attr_txt:setString(_string_format("<img src='%s' scale=1 /><div fontcolor=#3d5078>    %s</div>", PathTool.getResFrame("common", attr_icon), attr_val))
    end

    self.tree_is_max_step = false
    self.rouse_btn:setVisible(true)
    if self.elfin_tree_data.lev >= Config.SpriteData.data_tree_up_lv_length then
        self.tree_is_max_step = true
        for i=1,2 do
            self:showTreeCostInfo(false, i)
        end
        --self.max_lv_sp:setVisible(true)
        self.rouse_btn:setVisible(false)
        --self.max_lv_sp:setPositionX(360)
    else
        if self.elfin_tree_data.lev >= step_cfg.lev_max then -- 达到当前阶级最大等级，显示为唤醒
            self.rouse_btn_label:setString(TI18N("唤醒"))
            --self.max_lv_sp:setVisible(true)
            self.rouse_cost_panel:setVisible(false)
            self.tree_step_max = true
            self.tree_is_max_step = false
            --self.max_lv_sp:setPositionX(173)
        else -- 未达到当前阶级最大等级，显示为复苏
            --self.max_lv_sp:setVisible(false)
            self.rouse_cost_panel:setVisible(true)
            self.rouse_btn_label:setString(TI18N("复苏"))
            self.tree_step_max = false
            if level_cfg.expend then
                for i,v in ipairs(level_cfg.expend) do
                    local item_bid = v[1]
                    local item_num = v[2]
                    if i == 1 then
                        self.cost_item_bid_1 = item_bid
                        self.cost_item_need_num_1 = item_num
                    elseif i == 2 then
                        self.cost_item_bid_2 = item_bid
                        self.cost_item_need_num_2 = item_num
                    end
                    self:showTreeCostInfo(true, i, item_bid, item_num)
                end
            end
        end
    end
end

-- 根据位置获取对应精灵的id
function ElfinRousePanel:getTreeElfinBidByPos( pos )
    if not self.elfin_tree_data then return end

    local elfin_bid
    for k,v in pairs(self.elfin_tree_data.sprites) do
        if v.pos == pos then
            elfin_bid = v.item_bid
            break
        end
    end
    return elfin_bid
end

-- 显示消耗材料
function ElfinRousePanel:showTreeCostInfo( status, index, item_bid, need_num )
    local object = self.cost_objects[index]
    if not object then return end

    if status == true then
        object.res_icon:setVisible(true)
        object.cost_txt:setVisible(true)

        local item_cfg = Config.ItemData.data_get_data(item_bid)
        if item_cfg then
            local item_res = PathTool.getItemRes(item_cfg.icon)
            loadSpriteTexture(object.res_icon, item_res, LOADTEXT_TYPE)
            local have_num = BackpackController:getInstance():getModel():getItemNumByBid(item_bid)
            object.cost_txt:setString(string.format("%s/%s", MoneyTool.GetMoneyString(have_num, false), MoneyTool.GetMoneyString(need_num, false)))
            if have_num < need_num then
                object.cost_txt:setTextColor(Config.ColorData.data_new_color4[11])
            else
                object.cost_txt:setTextColor(Config.ColorData.data_new_color4[12])
            end
        end
    else
        object.res_icon:setVisible(false)
        object.cost_txt:setVisible(false)
    end
end

-- 道具数量变化
function ElfinRousePanel:checkNeedUpdateItemNum( item_list )
    if item_list == nil or next(item_list) == nil then return end
    for k, v in pairs(item_list) do
        if v.config then
            if self.cost_item_bid_1 and v.config.id == self.cost_item_bid_1 then
                self:showTreeCostInfo(true, 1, self.cost_item_bid_1, self.cost_item_need_num_1)
            elseif self.cost_item_bid_2 and v.config.id == self.cost_item_bid_2 then
                self:showTreeCostInfo(true, 2, self.cost_item_bid_2, self.cost_item_need_num_2)
            end
        end
    end
end




-- 唤醒\复苏
function ElfinRousePanel:onClickRouseBtn(  )
    if not self.elfin_tree_data then return end
    if self.tree_step_max == true then -- 唤醒(进阶)
        _controller:openElfinTreeStepWindow(true)
    else -- 复苏(升级)
        _controller:sender26511()
    end
end

-- 调整精灵顺序
function ElfinRousePanel:onClickAdjustBtn(  )
    _controller:openElfinAdjustWindow(true)
end

function ElfinRousePanel:startTimeTicket()
    if self.time_ticket == nil then
        self.can_play_lvup_sound = true
        self.time_idnex = 0
        local _callback = function()
            if self.tree_step_max == true then
                self:clearTimeTicket()
            else
                _controller:sender26511()
                self.can_play_lvup_sound = false
                self.time_idnex = self.time_idnex + 1
                if self.time_idnex > 2 then
                    self.time_idnex = 0
                    self.can_play_lvup_sound = true
                end
            end
        end
        self.time_ticket = GlobalTimeTicket:getInstance():add(_callback, 0.2)
    end
end

function ElfinRousePanel:clearTimeTicket()
    if self.sequence_action then
        self.rouse_btn:stopActionByTag(10086)
        self.sequence_action = nil
    end
    if self.time_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.time_ticket)
        self.time_ticket = nil
    end
end 

-- 唤醒规则
function ElfinRousePanel:onClickRouseRuleBtn( param, sender, event_type )
    local rule_cfg = Config.SpriteData.data_const["ancient_desc"]
    if rule_cfg then
        local p = sender:getTouchBeganPosition()
        local pos = cc.p(p.x, p.y - 300)
        TipsManager:getInstance():showCommonTips(rule_cfg.desc, pos, nil, nil, 600, true)
    end
end

------------------@ 红点
function ElfinRousePanel:updateElfinRedInfo( bid, status )
    if bid == HeroConst.RedPointType.eElfin_tree_lvup then -- 古树升级、进阶红点
        self:updateTreeLvupRedStatus()
    elseif bid == HeroConst.RedPointType.eElfin_empty_pos then -- 古树有可放置的精灵
        self:updateTreeElfinRedStatus()
    elseif bid == HeroConst.RedPointType.eElfin_compound then -- 上阵精灵是否有可合成的精灵
        self:updateTreeElfinRedStatus()
    elseif bid == HeroConst.RedPointType.eElfin_higher_lv then -- 上阵精灵是否有更高阶的同类精灵
        self:updateTreeElfinRedStatus() 
    else
        -- 古树升级、进阶红点
        self:updateTreeLvupRedStatus()
        -- 古树有可放置的精灵
        self:updateTreeElfinRedStatus()
    end
end


-- 古树升级、进阶红点
function ElfinRousePanel:updateTreeLvupRedStatus(  )
    local red_status = _model:getElfinRedStatusByRedBid(HeroConst.RedPointType.eElfin_tree_lvup)
    addRedPointToNodeByStatus(self.rouse_btn, red_status, 0, 0)
end

-- 古树有可放置的精灵红点
function ElfinRousePanel:updateTreeElfinRedStatus(  )
    if not self.tree_elfin_list then return end
    for k,item in pairs(self.tree_elfin_list) do
        item:updateResStatus()
    end
end


function ElfinRousePanel:DeleteMe(  )
    self:clearTimeTicket()
    for k,item in pairs(self.tree_skill_list) do
        item:DeleteMe()
        item = nil
    end
    for k,item in pairs(self.tree_elfin_list) do
        item:DeleteMe()
        item = nil
    end

	if self.init_res_load then
        self.init_res_load:DeleteMe()
        self.init_res_load = nil
    end
    if self.tree_bg_load then
        self.tree_bg_load:DeleteMe()
        self.tree_bg_load = nil
    end
 
    if self.fight_label then
        self.fight_label:DeleteMe()
    end
    self.fight_label = nil

    if self.get_tree_data_event then
        GlobalEvent:getInstance():UnBind(self.get_tree_data_event)
        self.get_tree_data_event = nil
    end
    if self.tree_up_lv_event then
        GlobalEvent:getInstance():UnBind(self.tree_up_lv_event)
        self.tree_up_lv_event = nil
    end
    
   
    if self.add_goods_event then
        GlobalEvent:getInstance():UnBind(self.add_goods_event)
        self.add_goods_event = nil
    end
    if self.del_goods_event then
        GlobalEvent:getInstance():UnBind(self.del_goods_event)
        self.del_goods_event = nil
    end
    if self.modify_goods_event then
        GlobalEvent:getInstance():UnBind(self.modify_goods_event)
        self.modify_goods_event = nil
    end
    if self.update_red_status_event then
        GlobalEvent:getInstance():UnBind(self.update_red_status_event)
        self.update_red_status_event = nil
    end
end
-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @description:
--      公会技能重置界面
-- <br/>Create: 2019年3月11日
--
-- --------------------------------------------------------------------
GuildskillResetPanel = GuildskillResetPanel or BaseClass(BaseView)

local table_insert = table.insert
local controller = GuildskillController:getInstance()
local model = controller:getModel()
local string_format = string.format

function GuildskillResetPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini
    self.layout_name = "hero/hero_reset_offer_panel"
end 

function GuildskillResetPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 2)
    self.win_title = container:getChildByName("win_title")
    self.win_title:setString(TI18N("技能重置"))

    self.dec_val = createRichLabel(24, cc.c4b(0x68, 0x45, 0x2a, 0xff), cc.p(0, 1), cc.p(50,491),12,nil,580)
    
    container:addChild(self.dec_val)
    self.cancel_btn = container:getChildByName("cancel_btn")
    self.cancel_btn_label = self.cancel_btn:getChildByName("label")
    self.cancel_btn_label:setString(TI18N("取 消"))
    self.cancel_btn_label:enableOutline(Config.ColorData.data_color4[263], 2)

    self.confirm_btn = container:getChildByName("confirm_btn")
    self.confirm_btn_label = self.confirm_btn:getChildByName("label")
    self.confirm_btn_label:setString(TI18N("确定重置"))
    self.confirm_btn_label:enableOutline(Config.ColorData.data_color4[264], 2)
    self.list_view = container:getChildByName("list_view")
    local size = self.list_view:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 16,                  -- 第一个单元的X起点
        space_x = 32,                    -- x方向的间隔
        start_y = 6,                    -- 第一个单元的Y起点
        space_y = 10,                   -- y方向的间隔
        item_width = 119,               -- 单元的尺寸width
        item_height = 119,              -- 单元的尺寸height
        row = 4,                        -- 行数，作用于水平滚动类型
        col = 4,                         -- 列数，作用于垂直滚动类型
        once_num = 4,
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewLayout.new(self.list_view, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, size, setting)

    self.close_btn = container:getChildByName("close_btn")
    self.container = container
end

function GuildskillResetPanel:register_event()
    registerButtonEventListener(self.close_btn, function() controller:openGuildskillResetPanel(false) end ,true, 1)
    registerButtonEventListener(self.background, function() controller:openGuildskillResetPanel(false) end ,false, 1)
    registerButtonEventListener(self.cancel_btn, function() controller:openGuildskillResetPanel(false) end ,true, 2)

    self.confirm_btn:addTouchEventListener(function(sender, event_type)
        if not self.can_click_btn then
            return
        end
        customClickAction(sender, event_type, scale)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            self:onConfirmButton()
        end
    end)
    
    self:addGlobalEvent(GuildskillEvent.UpdateSkillResetEvent, function(data)
        if not data then return end
        self:setData(data)
    end)
end

function GuildskillResetPanel:onConfirmButton()
    if not self.career then return end
    if self.reset_type == 1 then
        controller:send23705(self.career)
    else
        controller:send23709(self.career)
    end
    controller:openGuildskillResetPanel(false)
end
--@career 职业
--@重置类型 reset_type 1 原本的 默认 的
--@重置类型 reset_type 2 pvp的 
function GuildskillResetPanel:openRootWnd(career, reset_type)
    if not career then return end
    self.reset_type = reset_type or 1
    self.career = career
    if self.reset_type == 1 then
        controller:send23704(career) 
    else
        self:setPvpData(career)
    end
end

function GuildskillResetPanel:setPvpData(career)
    local pvp_career_data = model:getPvpskillInfoByCareer(career)
    if not pvp_career_data then return end
    --计算消耗
    local total_lev = 0
    local dic_item_id = {}
    for i,v in ipairs(pvp_career_data.attr_formation) do
        total_lev = total_lev + v.lev
        local key = getNorKey(v.id, v.lev)
        local config =  Config.GuildSkillData.data_pvp_attr_info(key)
        if config and next(config.return_res) ~= nil then
            for _,data in ipairs(config.return_res) do
                if dic_item_id[data[1]] == nil then
                    dic_item_id[data[1]] = data[2]
                else
                    dic_item_id[data[1]] = dic_item_id[data[1]] + data[2]
                end
            end
        end
    end

    local key = getNorKey(career, pvp_career_data.skill_lev)
    local pvp_skill_config = Config.GuildSkillData.data_pvp_skill_info(key)
    if pvp_skill_config then
        for _,data in ipairs(pvp_skill_config.return_res) do
            if dic_item_id[data[1]] == nil then
                dic_item_id[data[1]] = data[2]
            else
                dic_item_id[data[1]] = dic_item_id[data[1]] + data[2]
            end
        end
    end
    self:initCostInfo(total_lev)

    local item_list = {}
    for id,val in pairs(dic_item_id) do
        local item = {}
        item.id = id
        item.quantity = val
        table_insert(item_list, item)
    end

    local sort_func = SortTools.tableUpperSorter({"id"})
    table.sort(item_list, sort_func)
    self.item_scrollview:setData(item_list, nil, nil, {is_show_tips = true, is_other = false})

    self:updateBtnInfo()
end
--显示消耗信息(pvp)
function GuildskillResetPanel:initCostInfo(total_lev)
    total_lev = total_lev or 1
    --计算钻石消耗
    local count = 0
    local is_first = model:isPvpFisrtReset()
    if is_first then
        count = 300
        local config = Config.GuildSkillData.data_const.pvp_first_reset_consume
        if config then
            count = config.val
        end
    else
        local reset_consume_var1 = 500
        local config = Config.GuildSkillData.data_const.reset_consume_var1
        if config then
            reset_consume_var1 = config.val
        end

        local reset_consume_var2 = 15
        local config = Config.GuildSkillData.data_const.reset_consume_var2
        if config then
            reset_consume_var2 = config.val
        end
        --本系技能总等级 * 系数2
        local cost_count = total_lev * reset_consume_var2
        count = math.max(reset_consume_var1, cost_count)
    end

    local txt 
    local career_name = HeroConst.CareerName[self.career] or HeroConst.CareerName[HeroConst.CareerType.eWarrior]
    if count == 0 then
        txt = TI18N("本次消耗免费,重置后<div fontcolor=#c00b09>%s职业</div>所有<div fontcolor=#c00b09>PVP属性和技能</div>将被清空等级(变为未激活状态)，请慎重考虑！同时将返还所消耗的<div fontcolor=#df7d2a>100%%养成材料</div>")
        local str = string_format(txt, career_name)
        self.dec_val:setString(str)
    else 
        if is_first then
            txt = TI18N("首次重置只需要消耗<img src='%s' scale=0.3 />%s 重置后<div fontcolor=#c00b09>%s职业</div>所有<div fontcolor=#c00b09>PVP属性和技能</div>将被清空等级(变为未激活状态)，请慎重考虑！同时将返还所消耗的<div fontcolor=#df7d2a>100%%养成材料</div>")
        else
            txt = TI18N("重置需要消耗<img src='%s' scale=0.3 />%s 重置后<div fontcolor=#c00b09>%s职业</div>所有<div fontcolor=#c00b09>PVP属性和技能</div>将被清空等级(变为未激活状态)，请慎重考虑！同时将返还所消耗的<div fontcolor=#df7d2a>100%%养成材料</div>")
        end
        local item_id = Config.ItemData.data_assets_label2id.gold
        local iconsrc = PathTool.getItemRes(Config.ItemData.data_get_data(item_id).icon)
        local str = string_format(txt, iconsrc, count, career_name)
        self.dec_val:setString(str)
    end
end

--计算原本的
function GuildskillResetPanel:setData(data)
    if not data then return end
    local count =  data.gold or 0
    local txt 
    local career_name = HeroConst.CareerName[self.career] or HeroConst.CareerName[HeroConst.CareerType.eWarrior]
    if count == 0 then
        txt = TI18N("本次消耗免费,重置后<div fontcolor=#c00b09>%s职业</div>所有技能将被清空等级(变为未激活状态)，请慎重考虑！同时将返回所消耗的<div fontcolor=#df7d2a>100%%公会贡献和50%%金币</div>")
        local str = string_format(txt, career_name)
        self.dec_val:setString(str)
    else 
        if data.is_first == 1 then
            txt = TI18N("首次重置只需要消耗<img src='%s' scale=0.3 />%s 重置后<div fontcolor=#c00b09>%s职业</div>所有技能将被清空等级(变为未激活状态)，请慎重考虑！同时将返回所消耗的<div fontcolor=#df7d2a>100%%公会贡献和50%%金币</div>")
        else
            txt = TI18N("重置需要消耗<img src='%s' scale=0.3 />%s 重置后<div fontcolor=#c00b09>%s职业</div>所有技能将被清空等级(变为未激活状态)，请慎重考虑！同时将返回所消耗的<div fontcolor=#df7d2a>100%%公会贡献和50%%金币</div>")
        end
        local item_id = Config.ItemData.data_assets_label2id.gold
        local iconsrc = PathTool.getItemRes(Config.ItemData.data_get_data(item_id).icon)
        local str = string_format(txt, iconsrc, count, career_name)
        self.dec_val:setString(str)
    end

    local item_list = {}
    for i,v in ipairs(data.list) do
        local item = {}
        item.id = v.id
        item.quantity = v.num
        table_insert(item_list, item)
    end

    local sort_func = SortTools.tableUpperSorter({"id"})
    table.sort(item_list, sort_func)
    self.item_scrollview:setData(item_list, nil, nil, {is_show_tips = true, is_other = false})

    self:updateBtnInfo()
end

function GuildskillResetPanel:updateBtnInfo()
    if self.confirm_btn then
        local time = 5
        self.can_click_btn = false
        self.confirm_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
        setChildUnEnabled(true, self.confirm_btn)
        self:setBtnFormatString(time)
        self.confirm_btn:stopAllActions()
        self.confirm_btn_label:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),
            cc.CallFunc:create(function()
                time = time -1
                if time <= 0 then
                    self.confirm_btn:stopAllActions()
                    self.can_click_btn = true
                    setChildUnEnabled(false, self.confirm_btn)
                    self.confirm_btn_label:enableOutline(Config.ColorData.data_color4[264], 2)
                end
                self:setBtnFormatString(time)
        end))))
    end
end


function GuildskillResetPanel:setBtnFormatString(time)
    if time > 0 then
        local str = string_format(TI18N("确定重置(%s)"), time)
        self.confirm_btn_label:setString(str)
    else
        self.confirm_btn_label:setString(TI18N("确定重置"))
    end
end


function GuildskillResetPanel:close_callback()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    self.confirm_btn:stopAllActions()
    controller:openGuildskillResetPanel(false)
end



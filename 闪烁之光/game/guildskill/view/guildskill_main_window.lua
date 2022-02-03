-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @修改: lwc@syg.com(必填, 创建模块的人员)
-- @description:
--      公会技能的主界面
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildskillMainWindow = GuildskillMainWindow or BaseClass(BaseView) 

local controller = GuildskillController:getInstance()
local model = controller:getModel()
local table_insert = table.insert
local string_format = string.format
local role_vo = RoleController:getInstance():getRoleVo()
local backpack_model = BackpackController:getInstance():getModel()

function GuildskillMainWindow:__init()
    self.win_type           = WinType.Full
    self.is_full_screen     = true

    self.tab_list           = {}            -- 标签页
    self.attr_list          = {}            -- 综述性加成
    self.item_list          = {}            -- 6个单元集合
    self.singe_att_list     = {}            -- 单个的属性加成
    self.attr_value_list    = {}            -- 当前所累积属性的列表
    self.cur_info_group_id  = 0             -- 更新判断依据
    self.backpack_item_list = {}            -- 物品图标实例

    self.upgrade_cost_list  = {}            -- 点亮需要消耗的物品和资产
    self.cur_index = 1

    self.layout_name = "guildskill/guildskill_main_window"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("guildskill", "guildskill"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("guildskill", "guild_skill_bg", true), type = ResourcesType.single},
    }

    --最大等级
    self.pvp_max_lv = 160
    local config = Config.GuildSkillData.data_const.pvp_max_lv
    if config then
        self.pvp_max_lv = config.val
    end

    --原来的位置 下面代码 x y记录了
    --pvp 4 属性位置
    self.pvp_item_pos_list = {
        [1] = {151, 226},
        [2] = {220, 385},
        [3] = {454, 386},
        [4] = {524, 227},
    }  --pvp 4 属性位置
    self.actin_pvp_item_pos_list = {
        [1] = {115, 252},
        [2] = {195, 410},
        [3] = {482, 410},
        [4] = {561, 246},
    }

     --pvp 4 属性位置
    self.actin_item_pos_list = {
        [1] = {338, 388},
        [2] = {490, 298},
        [3] = {489, 168},
        [4] = {338, 80},
        [5] = {190, 168},
        [6] = {190, 306},
    }

    --按钮原位置
    self.handle_pos = cc.p(315, 32)
    --按钮在pvp页签下位置
    self.pvp_handle_pos = cc.p(544, 44)

    --消耗原来位置
    self.cost_pos = {
        [1] = cc.p(138, 97),
        [2] = cc.p(491, 97),
    }
    --消耗在pvp页签下位置
    self.pvp_cost_pos = {
        [1] = cc.p(87, 46),
        [2] = cc.p(306, 46),
    }

    --box_bg 原来高度
    self.box_pos_height = 122
    --box_bg 原来pvp高度
    self.pvp_box_pos_height = 165

    --原来的属性位置 --在配置显示综述性条目 定义值 
    self.attr_pos_x = {}
    --pvp的属性值 只有4个
    self.pvp_attr_pos_x = {
        [1] = 80,
        [2] = 330,
        [4] = 80,
        [5] = 330
    }
    --原来的位置
    self.single_item_pos_y = 0

    --pvp的位置
    self.pvp_single_item_pos_y = 292

    --标志是否显示pvp模块
    self.is_pvp_show = true
    -- --是否已经初始化的职业
    -- self.is_init_career = {}
    --pvp选择属性索引
    self.pvp_select_index = 1
    --action1-action4是普通的 战士 坦克 辅助 法师    action5——action8是pvp的 以此类推
    self.career_action_list = {
        --1 位置表示 普通显示动作, 2 表示 pvp显示动作  3.表示普通 常驻动作, 4 表示pvp的常驻动作
        [GuildskillConst.index.physics] = {"action1", "action5", "action11", "action55"},
        [GuildskillConst.index.defence] = {"action2", "action6", "action22", "action66"},
        [GuildskillConst.index.assist]  = {"action3", "action7", "action33", "action77"},
        [GuildskillConst.index.magic]   = {"action4", "action8", "action44", "action88"}
    }

    --pvp icon 对应名字
    self.pvp_icon_res = {
        [GuildskillConst.index.physics] = {"guildskill_3_6","guildskill_3_6","guildskill_3_2","guildskill_3_3"},
        [GuildskillConst.index.magic]   = {"guildskill_2_6","guildskill_2_6","guildskill_2_2","guildskill_2_3"},
        [GuildskillConst.index.defence] = {"guildskill_4_6","guildskill_4_6","guildskill_4_1","guildskill_4_4"},
        [GuildskillConst.index.assist]  = {"guildskill_5_6","guildskill_5_6","guildskill_5_1","guildskill_5_7"}
    }
end 

function GuildskillMainWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:loadTexture(PathTool.getPlistImgForDownLoad("guildskill", "guild_skill_bg", true), LOADTEXT_TYPE)
    self.background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.container_size = self.main_container:getContentSize()
    self:playEnterAnimatianByObj(self.main_container, 1)

    self.top_panel = self.main_container:getChildByName("top_panel")
    self.bottom_panel = self.main_container:getChildByName("bottom_panel")

    --top_panel的
    self.title_name = self.top_panel:getChildByName("title_name")
    self.title_name:setString(TI18N("公会技能"))
    self.explain_btn = self.top_panel:getChildByName("explain_btn")
    --pvp 和常规按钮
    self.change_btn = self.top_panel:getChildByName("change_btn")
    -- 4个标签页
    local tab_container = self.top_panel:getChildByName("tab_container")
    local name_list = {
        [1] = TI18N("战士职业"),
        [2] = TI18N("法师职业"),
        [3] = TI18N("坦克职业"),
        [4] = TI18N("辅助职业"),
    }
    --职业
    local caree_index = {
        [1] = GuildskillConst.index.physics,
        [2] = GuildskillConst.index.magic,
        [3] = GuildskillConst.index.defence,
        [4] = GuildskillConst.index.assist,
    }
    for i=1,4 do
        local tab_btn = tab_container:getChildByName("tab_btn_"..i)
        if tab_btn then
            local title = tab_btn:getChildByName("title")
            local tips = tab_btn:getChildByName("tips")
            local select_bg = tab_btn:getChildByName("select_bg")
            select_bg:setVisible(false)
            local name = name_list[i] or ""
            title:setString(name)
            local career = caree_index[i] or GuildskillConst.index.physics
            -- title:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff)) 
            tab_btn.select_bg = select_bg
            tab_btn.career = career
            tab_btn.label = title
            tab_btn.tips = tips
            tab_btn.index = i
            self.tab_list[career] = tab_btn
        end
    end

    self.career_desc = createRichLabel(24, cc.c3b(0xd3,0xba,0x80), cc.p(0.5, 0.5), cc.p(360, -36), nil, nil, 500) 
    self.top_panel:addChild(self.career_desc)

    --常规的
    self.main_panel = self.main_container:getChildByName("main_panel")
    self.middle_bg = self.main_panel:getChildByName("middle_bg")
    self.middle_icon = self.main_panel:getChildByName("middle_icon")
    -- self.middle_icon:setZOrder(3)

    self.power_click = self.top_panel:getChildByName("power_click")
    self.score_title = self.power_click:getChildByName("score_title")
    self.score_title:setString(TI18N("PVP战力："))
    self.fight_label = CommonNum.new(20, self.power_click, 99999, - 2, cc.p(0.5, 0.5))
    self.fight_label:setPosition(148, 29) 

    self.selected = self.main_panel:getChildByName("selected")
    breatheShineAction(self.selected)

      -- 6个单元
    for i=1,6 do
        local object = {}
        local item = self.main_panel:getChildByName("item_"..i)
        local item_lev = self.main_panel:getChildByName("item_lev_"..i)
        if item then
            object.node = item 
            object.lev = item_lev 
            object.index = i
            object.x = item:getPositionX()
            object.y = item:getPositionY()
            object.status = nil
            object.data = nil                   -- 先备注出来吧
            object.config = nil
            --前面4个因为pvp属性可以自由点击 所以需要加点击事件
            if i <= 4 then
                registerButtonEventListener(item, function() self:onItemBtn(i) end, true, 2)
            end
            self.item_list[i] = object
        end
    end

    -- 单个单元的属性加成展示
    self.single_item_attr_container = self.main_panel:getChildByName("single_item_attr_container")
    self.single_item_pos_y = self.single_item_attr_container:getPositionY()
    self.attr_title = self.single_item_attr_container:getChildByName("attr_title")
    self.attr_value = self.single_item_attr_container:getChildByName("attr_value")

    self.lev_upgrade_model = self.main_panel:getChildByName("lev_upgrade_model")     -- 升级的特效容器
    -- self.lev_upgrade_model:setZOrder(2)
      --bottom_panel 的
    self.box_bg = self.bottom_panel:getChildByName("box_bg") --旗子
    self.Sprite_5 = self.bottom_panel:getChildByName("Sprite_5") --旗子

    self.close_btn = self.bottom_panel:getChildByName("close_btn")
    self.reset_btn = self.bottom_panel:getChildByName("reset_btn")
    self.reset_btn_label = self.reset_btn:getChildByName("label")
    self.reset_btn_label:setPositionX(26)
    self.reset_btn_label:setString("")
    self.attr_desc = self.bottom_panel:getChildByName("attr_desc")
    self.attr_desc:setString(TI18N("加\n成\n总\n览")) 
    self.scroll_view = self.bottom_panel:getChildByName("scroll_view")
    self.scroll_view:setScrollBarEnabled(false)
    local size = self.scroll_view:getContentSize()

    
    -- 配置显示综述性条目
    local config = Config.GuildSkillData.data_const["attr_show_" .. self.cur_index]
    local _x, _y = 0, 0
    if config and config.val then
        local list_size = math.ceil(#config.val/3)
        local width = 200
        local height = 42
        local space_x = 8
        local space_y = 13
        local max_height = list_size * height + (list_size + 1) * space_y
        max_height = math.max(max_height, size.height)
        self.scroll_view:setInnerContainerSize(cc.size(size.width, max_height))
        for i,v in ipairs(config.val) do
            _x = ((i-1) % 3) * (width + space_x)
            if i == 3 or i == 6 then
                _x = _x - 16
            end
            _y = max_height - (7 + height * 0.5 + (math.floor((i - 1) / 3)) * (height + space_y)) - 2
            self.attr_pos_x[i] = _x + 6
            self.attr_list[i] = createRichLabel(22,cc.c3b(0x64,0x32,0x23),cc.p(0,0.5),cc.p(self.attr_pos_x[i], _y))
            self.scroll_view:addChild(self.attr_list[i])
        end
    end
    self.pvp_explain_btn = self.bottom_panel:getChildByName("pvp_explain_btn")

    self.cost_container = self.bottom_panel:getChildByName("cost_container")
    self.handle_btn = self.cost_container:getChildByName("handle_btn")
    self.handle_btn_label = self.handle_btn:getChildByName("label")
    self.handle_btn_label:setString("")
    -- 消耗
    self.cost_bg_list = {}
    for i=1, 2 do
        local cost_bg = self.cost_container:getChildByName("cost_bg_"..i)
        self.cost_bg_list[i] = {}
        self.cost_bg_list[i].cost_bg = cost_bg
        self.cost_bg_list[i].cost_icon = cost_bg:getChildByName("cost_icon")
        self.cost_bg_list[i].cost_txt = cost_bg:getChildByName("cost_txt")
    end


    self:adaptationScreen()
end

--设置适配屏幕
function GuildskillMainWindow:adaptationScreen()
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop(self.main_container)
    local bottom_y = display.getBottom(self.main_container)
    local left_x = display.getLeft(self.main_container)
    local right_x = display.getRight(self.main_container)

    local tab_y = self.top_panel:getPositionY()
    self.top_panel:setPositionY(top_y - (self.container_size.height - tab_y))

    local height = (top_y - self.container_size.height)
    local power_y = self.power_click:getPositionY()
    if height > 16 then
        height = 16
    elseif height < 0 then
        height = 0
    end
    self.power_click:setPositionY(power_y - height)

    local bottom_panel_y = self.bottom_panel:getPositionY()
    self.bottom_panel:setPositionY(bottom_y + bottom_panel_y)
    -- local close_btn_y = self.close_btn:getPositionY()
    -- self.close_btn:setPositionY(bottom_y + close_btn_y)
end

function GuildskillMainWindow:register_event()
    registerButtonEventListener(self.explain_btn, function(param,sender, event_type)
        local config = Config.GuildSkillData.data_const.game_rule
        if config then
            TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
        end
    end,true, 1)
    registerButtonEventListener(self.pvp_explain_btn, function(param,sender, event_type)
        local config = Config.GuildSkillData.data_const.pvp_game_rule
        if config then
            TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
        end
    end,true, 1, nil, 0.8)

    for k,tab_btn in pairs(self.tab_list) do
        tab_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playTabButtonSound()
                self:changeSelectedTab(tab_btn.career, tab_btn.index)
            end
        end)
    end

    registerButtonEventListener(self.close_btn, function() controller:openGuildSkillMainWindow(false) end,true, 2)
    registerButtonEventListener(self.reset_btn, function() self:onResetBtn() end,true, 2)
    registerButtonEventListener(self.handle_btn, function() self:onHandleBtn() end,true, 2)
    registerButtonEventListener(self.change_btn, function() self:onChangeBtn() end,true, 2)

    -- 初始化的时候做的，可能切换标签，或者第一次打开
    self:addGlobalEvent(GuildskillEvent.UpdateGuildSkillEvent, function(career)
        if self.selected_tab and self.selected_tab.career == career then
            self:updateShowSkillInfo(career)
        end
    end)

    -- 公会pvp 技能数据返回 只有登陆后快递打开公会信息的时候才有
    self:addGlobalEvent(GuildskillEvent.Guild_Pvp_Skill_Info_Event, function()
        if self.selected_tab then
            self:updateShowSkillInfo(self.selected_tab.career)
        end
    end) 
    -- 公会pvp 单个职业返回 主要刷新信息用
    self:addGlobalEvent(GuildskillEvent.Guild_Pvp_Career_Info_Event, function(career)
         if self.selected_tab and self.selected_tab.career == career then
            self:updatePvPSkillList(career)
        end     
    end) 
    -- 公会pvp 战力更新
    self:addGlobalEvent(GuildskillEvent.Guild_Pvp_Career_Update_Event, function(career, show_type, id)
         if self.selected_tab and self.selected_tab.career == career then
            self:updatePowerInfo(career, show_type, id)
        end     
    end)
    -- 突破成功返回
    self:addGlobalEvent(GuildskillEvent.Guild_Pvp_Career_Break_Event, function(career)
        if self.selected_tab and self.selected_tab.career == career then
            local pvp_career_data = model:getPvpskillInfoByCareer(career)
            if pvp_career_data and #pvp_career_data.attr_formation ~= 0 then
                self.is_pvp_show = true
            end
            self:updateShowSkillInfo(career)
        end     
    end)  

    --重置技能
    self:addGlobalEvent(GuildskillEvent.ResetGuildSkillEvent, function(career)
        if self.selected_tab and self.selected_tab.career == career then
            self:updateSkillList(career, nil, true)
        end
    end) 

    --更新技能
    if self.update_skillstatus_event == nil then
        self.update_skillstatus_event = GlobalEvent:getInstance():Bind(GuildskillEvent.UpdateSkillStatusEvent, function(career, skill_id)
            if self.selected_tab and self.selected_tab.career == career then
                self:updateGotoeLabelShowStatus(career)
                self:updateSkillItemById(skill_id)
            end
        end)
    end

    if self.update_skillupgrade_event == nil then
        self.update_skillupgrade_event = GlobalEvent:getInstance():Bind(GuildskillEvent.UpdateSkilUpgradeEvent, function(career, group_id)
            if self.selected_tab and self.selected_tab.career == career then
                self:updateSkillList(career, true)
            end
        end)
    end

    if self.update_guild_skill_red_event == nil then
        self.update_guild_skill_red_event = GlobalEvent:getInstance():Bind(GuildEvent.UpdateGuildRedStatus, function(bid, status) 
            self:updateGuildSkillRed(bid, status)
        end)
    end

    if role_vo then
        if self.update_role_assets_event == nil then
            self.update_role_assets_event = role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
                if self.selected_item and self.upgrade_cost_list then
                    if (self.upgrade_cost_list.base_list and self.upgrade_cost_list.base_list[key]) then
                        self:updateCostInfo()
                    elseif self.upgrade_cost_list.asset_list and self.upgrade_cost_list.asset_list[key] then 
                        self:updateCostInfo()
                    end
                end
            end)
        end
    end

    -- 删除一个物品更新,也需要判断当前标签页类型
    if self.add_item_data_event == nil then
        self.add_item_data_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS, function(bag_code, del_list)
            if bag_code ~= BackPackConst.Bag_Code.BACKPACK then return end
            -- self:changeNeedItemInfo(del_list)
            self:updateCostInfo()
        end)
    end

    if self.update_item_data_event == nil then
        self.update_item_data_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code, change_list)
            if bag_code ~= BackPackConst.Bag_Code.BACKPACK then return end
            -- self:changeNeedItemInfo(change_list)
            self:updateCostInfo()
        end)
    end
end

function GuildskillMainWindow:updatePowerInfo(career, show_type, id)
    if not career then return end
    local pvp_career_data = model:getPvpskillInfoByCareer(career)
    if not pvp_career_data then return end

    local career_power = 0
    local chang_power = 0
    for _,v in ipairs(pvp_career_data.attr_formation) do
        local key = getNorKey(v.id, v.lev)
        local config =  Config.GuildSkillData.data_pvp_attr_info(key)
        if config then
            career_power = career_power + config.power
        end
        if show_type == 2 and id == v.id then
            --拿上一级的做差异判断
            local key = getNorKey(v.id, v.lev - 1)
            local per_config =  Config.GuildSkillData.data_pvp_attr_info(key)
            if per_config then
                chang_power = config.power - per_config.power
            else
                -- 如果没有说明数据有错..就不提提示本次战力飘字了
                return
            end
            
        end
    end

    local key = getNorKey(career, pvp_career_data.skill_lev)
    local pvp_skill_config = Config.GuildSkillData.data_pvp_skill_info(key)
    if pvp_skill_config then
        career_power = career_power + pvp_skill_config.power
        if show_type == 1 then
            local key = getNorKey(career, pvp_career_data.skill_lev - 1)
            local per_pvp_skill_config = Config.GuildSkillData.data_pvp_skill_info(key)
            if per_pvp_skill_config then
                chang_power = pvp_skill_config.power - per_pvp_skill_config.power
            else
                -- 如果没有说明数据有错..就不提提示本次战力飘字了
                return
            end
        end
    end
    if chang_power <= 0  then
        --战斗力小了 无视
        return
    end
    local setting = {}
    setting.res_offset_x = -30
    GlobalMessageMgr:getInstance():showPowerMove( chang_power,PathTool.getResFrame("common", "txt_cn_common_90002_1"), career_power - chang_power, setting)
end

--重置本系技能
function GuildskillMainWindow:onResetBtn()
    if self.selected_tab and self.selected_tab.career then
        if self.is_pvp_show then 
            local pvp_career_data = model:getPvpskillInfoByCareer(self.selected_tab.career)

            local total_lev = 0
            for i,v in ipairs(pvp_career_data.attr_formation) do
                total_lev = total_lev + v.lev
            end
            if total_lev > 0 then
                GuildskillController:getInstance():openGuildskillResetPanel(true, self.selected_tab.career, 2)
            end
        else
            local object = model:getCareerSkillInfo(self.selected_tab.career)
            if object and object.had_skill_up then
                GuildskillController:getInstance():openGuildskillResetPanel(true, self.selected_tab.career, 1)
            end
        end
    end
end
--切换
function GuildskillMainWindow:onChangeBtn()
    if self.is_show_action then return end
    if self.selected_tab and self.selected_tab.career then
        local career = self.selected_tab.career
        local pvp_career_data = model:getPvpskillInfoByCareer(career)
        local object = model:getCareerSkillInfo(career)
        
        if not pvp_career_data then return end
        if not object then return end

        --后端决定 
        if #pvp_career_data.attr_formation == 0 then
            local max_lv_cfg = Config.GuildSkillData.data_const["max_lv"] -- 公会技能最大等级
            local max_lv = 40
            if max_lv_cfg then
                max_lv = max_lv_cfg.val
            end
            message(string_format(TI18N("本系技能达%s重天时开启"), max_lv))
            return 
        end

        self.is_pvp_show = not self.is_pvp_show
        self:changeShowSkillInfo(career, true)
    end
end

function GuildskillMainWindow:updateChangeBtnImg()
    local res 
    if self.is_pvp_show then
        res = PathTool.getResFrame("guildskill","txt_cn_guildskill_905")
    else
        res = PathTool.getResFrame("guildskill","txt_cn_guildskill_906")
    end
    if self.record_chang_btn_res ~= res then
        self.record_chang_btn_res = res
        self.change_btn:loadTexture(res, LOADTEXT_TYPE_PLIST)
    end
end

--升级 或者 突破
function GuildskillMainWindow:onHandleBtn()
    if self.is_pvp_show then
        --pvp 技能
        if self.selected_item and self.selected_item.data then
            if self.selected_tab and self.selected_tab.career then
                controller:send23707(self.selected_tab.career, self.selected_item.data.id)
            end
        end
    else
        --原本技能
        if self.selected_item and self.selected_item.data and self.selected_item.config then
            local config = self.selected_item.config
            local data = self.selected_item.data

            if config.lev >= 20 and data.status == GuildskillConst.status.activity then
                --已满级 可突破
                if self.selected_tab and self.selected_tab.career then
                    controller:send23706(self.selected_tab.career)
                end
            else
                controller:requestActivitySkill(self.selected_item.data.id)
            end
        end
    end
end
--点击pvp技能
function GuildskillMainWindow:onClickPvpSkillItem()
    if self.is_pvp_show then
        if self.selected_tab and self.selected_tab.career then
            controller:openGuildskillLevelUpPanel(true, self.selected_tab.career)
        end
    end
end


function GuildskillMainWindow:onItemBtn(index)
    self.selected_item = self.item_list[index]
    if self.selected_item == nil then return end

    self.pvp_select_index = index

    if not tolua.isnull(self.selected_item.node) and self.pvp_item_pos_list[index] then
        self.selected:setPosition(self.pvp_item_pos_list[index][1], self.pvp_item_pos_list[index][2])
    end
    -- 做显示属性切换
    local config = self.selected_item.config
    local data = self.selected_item.data
    if config and data then
        if config.client_attr and type(config.client_attr[1]) == "table" and (#config.client_attr[1] >= 2) then
            local key = getNorKey(data.id, data.lev + 1)
            local per_config =  Config.GuildSkillData.data_pvp_attr_info(key)
            if per_config then
                if per_config.client_attr and type(per_config.client_attr[1]) == "table" and (#per_config.client_attr[1] >= 2) then
                    self:updateSingleAttr(config.client_attr[1][1], per_config.client_attr[1][2] - config.client_attr[1][2] , config.desc)
                end
            else
                self:updateSingleAttr(config.client_attr[1][1], config.client_attr[1][2], config.desc)    
            end
            
        end
        self:updateCostInfo()
    end
end

function GuildskillMainWindow:openRootWnd(career)
    RoleController:getInstance():sender10986(RoleConst.red_point.red_point_2)
    RoleController:getInstance():getModel():updateRedPointData(RoleConst.red_point.red_point_2)
    GuildController:getInstance():getModel():updateGuildRedStatus(GuildConst.red_index.all_skill, false)
    career = career or GuildskillConst.index.physics
    local index = 1
    if self.tab_list[career] then
        index = self.tab_list[career].index 
    end
    self:changeSelectedTab(career, index)

    self:updateGuildSkillRed()
end

--==============================--
--desc:更新红点
--time:2018-08-07 07:17:39
--@bid:
--@status:
--@return 
--==============================--
function GuildskillMainWindow:updateGuildSkillRed(bid, status)
    if bid == nil then
        for k,tab_btn in pairs(self.tab_list) do
            local status = model:getRedStatus(tab_btn.career)
            if tab_btn.tips then
                tab_btn.tips:setVisible(status)
            end
        end
    elseif bid == GuildConst.red_index.skill_2 or bid == GuildConst.red_index.pvp_skill_2 then -- 魔法
        local tab_btn = self.tab_list[GuildskillConst.index.magic]
        if tab_btn and tab_btn.tips then
            tab_btn.tips:setVisible(status)
        end
    elseif bid == GuildConst.red_index.skill_3 or bid == GuildConst.red_index.pvp_skill_3 then
        local tab_btn = self.tab_list[GuildskillConst.index.physics]
        if tab_btn and tab_btn.tips then
            tab_btn.tips:setVisible(status)
        end
    elseif bid == GuildConst.red_index.skill_4 or bid == GuildConst.red_index.pvp_skill_4 then
        local tab_btn = self.tab_list[GuildskillConst.index.defence]
        if tab_btn and tab_btn.tips then
            tab_btn.tips:setVisible(status)
        end
    elseif bid == GuildConst.red_index.skill_5 or bid == GuildConst.red_index.pvp_skill_5 then
        local tab_btn = self.tab_list[GuildskillConst.index.assist]
        if tab_btn and tab_btn.tips then
            tab_btn.tips:setVisible(status)
        end
    end
end

--==============================--
--desc:标签页选中
--time:2018-06-20 10:23:45
--@career:
--@return 
--==============================--
function GuildskillMainWindow:changeSelectedTab(career, index)
    if self.is_show_action then return end
    if self.selected_tab ~= nil then
        if self.selected_tab.career == career then return end
    end
    self.cur_index = index
    if self.selected_tab then
        -- self.selected_tab.label:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff))
        self.selected_tab.select_bg:setVisible(false)
        self.selected_tab = nil
    end
    self.selected_tab = self.tab_list[career]
    if self.selected_tab then
        -- self.selected_tab.label:setTextColor(cc.c4b(0xff, 0xed, 0xd6, 0xff))
        self.selected_tab.select_bg:setVisible(true)
    end

    -- 做全部属性显示切换
    local object = model:getCareerSkillInfo(career)
    if object == nil then
        controller:requestCareerSkillInfo(career)
    else
        local pvp_info = model:getPvpskillInfo()
        --如果pvp 信息没有话.说明没有回来
        if pvp_info ~= nil then
            self:updateShowSkillInfo(career)
        end
    end
end


function GuildskillMainWindow:updateShowSkillInfo(career)
    if career == nil then return end

    --pvp信息
    local pvp_career_data = model:getPvpskillInfoByCareer(career)
    local object = model:getCareerSkillInfo(career)
    
    if not pvp_career_data then return end
    if not object then return end

    local is_chang_btn =false
    if not self.is_first_show  then --首次打开也会有动作
        self.is_first_show = true
        is_chang_btn = true
    end
    --后端决定 如果 此数据空的.表示未突破..要显示原本的样子
    if #pvp_career_data.attr_formation == 0 then
        if self.is_pvp_show then --如果当前是 pvp界面也要有动作
            is_chang_btn = true
        end 
        self.is_pvp_show = false
    else
        -- self.is_pvp_show = true
    end
     self:changeShowSkillInfo(career, is_chang_btn)
end

--变化 原来和 pvp的切换
-- -ischangbtn --是否从转换按钮的
function GuildskillMainWindow:changeShowSkillInfo(career, is_chang_btn)
    self:updateChangeBtnImg()

    if self.is_pvp_show then
        self.power_click:setVisible(true)
        self.pvp_explain_btn:setVisible(true)
        self.handle_btn:setPosition(self.pvp_handle_pos)
        self.box_bg:setContentSize(cc.size(678, self.pvp_box_pos_height))
        for i,v in ipairs(self.cost_bg_list) do
            if self.pvp_cost_pos[i] then
                v.cost_bg:setPosition(self.pvp_cost_pos[i])
            end
        end
        if self.max_lev_label then
            self.max_lev_label:setVisible(false)
        end

        self.single_item_attr_container:setPositionY(self.pvp_single_item_pos_y)

        self:updatePvPSkillList(career, is_chang_btn)
        if self.levupgrade_effect then
            self.levupgrade_effect:setVisible(false)
        end
    else
        self.power_click:setVisible(false)
        self.pvp_explain_btn:setVisible(false)
        self.handle_btn:setPosition(self.handle_pos)
        self.box_bg:setContentSize(cc.size(678, self.box_pos_height))
        for i,v in ipairs(self.cost_bg_list) do
            if self.cost_pos[i] then
                v.cost_bg:setPosition(self.cost_pos[i])
            end
        end
        if self.pvp_max_lev_label then
            self.pvp_max_lev_label:setVisible(false)
        end
        if self.pvp_skill_item then
            self.pvp_skill_item:setVisible(false)
        end
        if self.pvp_tips_lable then
            self.pvp_tips_lable:setVisible(false)
        end
        if self.show_pvp_tips then
            self.show_pvp_tips:setVisible(false)
        end
        self.single_item_attr_container:setPositionY(self.single_item_pos_y)

        self:updateSkillList(career, nil , true)
        -- self:handleLevUpgradeEffect(true, PlayerAction.action_2, true)
    end
    -- -- 关闭红点
    local bid = model:getCareerKey(career)
    model:updateGuildRedStatus(bid, false)

    self:updateMiddleBg(career , is_chang_btn)
    -- -- 设置显示
    self:updateSkillItemIcon(career, is_chang_btn)
end

--更新属性icon的显示
function GuildskillMainWindow:updateSkillItemIcon(career, is_chang_btn)
    local item_res_id = ""
    if is_chang_btn and self.selected then
        self.is_show_action = true
        self.selected:setVisible(false)
        self.selected:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function() 

            self.is_show_action = false
            self.selected:setVisible(true)
        end) ))
    end
    for i,v in ipairs(self.item_list) do
        if self.is_pvp_show then --pvp的
            if not tolua.isnull(v.node) then
                if i > 4 then
                    v.node:setVisible(false)
                    v.lev:setVisible(false)
                else
                    if self.pvp_icon_res[career] then
                        item_res_id = self.pvp_icon_res[career][i] or "guildskill_2_1"
                    end
                
                    v.node:loadTexture(PathTool.getResFrame("guildskill",item_res_id), LOADTEXT_TYPE_PLIST)
                    local pos = self.pvp_item_pos_list[i]
                    if pos then
                        local act_pos = self.actin_pvp_item_pos_list[i]
                        if is_chang_btn and act_pos then
                            if act_pos then
                                self:attrIconRunAction(v.node, act_pos[1], act_pos[2], pos[1], pos[2])
                                self:attrIconRunAction(v.lev, act_pos[1], act_pos[2] - 37, pos[1], pos[2]-37)
                            else
                                v.node:setPosition(pos[1], pos[2])
                                v.lev:setPosition(pos[1], pos[2] - 37)
                            end
                            
                        else
                            v.node:setPosition(pos[1], pos[2])
                            v.lev:setPosition(pos[1], pos[2] - 37)
                        end
                    end
                end
            end
        else
            --原来的
            if not tolua.isnull(v.node) then
                item_res_id = string_format("guildskill_%s_%s", career, i)
                v.node:loadTexture(PathTool.getResFrame("guildskill",item_res_id), LOADTEXT_TYPE_PLIST)
                
                if i > 4 then
                    v.node:setVisible(true)
                    v.lev:setVisible(true)
                end
                local act_pos =  self.actin_item_pos_list[i]
                if is_chang_btn and act_pos then
                    self:attrIconRunAction(v.node, act_pos[1], act_pos[2], v.x, v.y)
                    self:attrIconRunAction(v.lev, act_pos[1] - 37, act_pos[2], v.x, v.y-37)
                else
                    v.node:setPosition(v.x, v.y)
                    v.lev:setPosition(v.x, v.y - 37)
                end
                
            end
        end
    end
end

function GuildskillMainWindow:attrIconRunAction(node, start_x, start_y, end_x, end_y)
    if node then
        node:setPosition(start_x, start_y)
        node:setOpacity(0)
        node:setScale(0.6)
        local time = 0.2
        local act_move = cc.EaseBackOut:create(cc.MoveTo:create(time,cc.p(end_x, end_y)))
        local act_scale = cc.EaseBackOut:create(cc.ScaleTo:create(time,1))
        local fadeIn = cc.FadeIn:create(time)
        node:runAction(cc.Sequence:create(cc.DelayTime:create(0.29), cc.Spawn:create(act_move, act_scale, fadeIn)))
    end
    -- body
end

function GuildskillMainWindow:skillItemRunAction(node, start_x, start_y, end_x, end_y)
    if node then
        node:setPosition(start_x, start_y)
        node:setOpacity(0)
        node:setScale(0.6)
        local time = 0.2
        local act_move = cc.EaseBackOut:create(cc.MoveTo:create(time,cc.p(end_x, end_y)))
        local act_scale = cc.EaseBackOut:create(cc.ScaleTo:create(time,1))
        local fadeIn = cc.FadeIn:create(time)
        node:runAction(cc.Sequence:create(cc.DelayTime:create(0.29), cc.Spawn:create(act_move, act_scale, fadeIn)))
    end
    -- body
end

-- 刷新属性名称显示
function GuildskillMainWindow:updateSkillAttrNameAndVal(career)
    if self.is_pvp_show then
        local config_list = {}
        for i=1,4 do
            if  self.item_list[i] then
                config_list[i] = self.item_list[i].config    
            end
        end

        local _updateitem = function(index, index2)
            local attr_item = self.attr_list[index2]
            local config = config_list[index]
            if attr_item and config and config.client_attr and config.client_attr[1] then
                attr_item:setPositionX(self.pvp_attr_pos_x[index2])
                if #config.client_attr[1] >= 2 then
                    self:updateAttrItem(attr_item, config.client_attr[1][2], config.client_attr[1][1], config.desc)
                end
            end 
        end
        --位置关系 1234  1425 和策划协商 1 和 2 肯定是技能的. 如果不是 这边不会报错.但是显示会有错误
        _updateitem(1,1)
        _updateitem(2,4)
        _updateitem(3,2)
        _updateitem(4,5)
        if self.attr_list[3] then
            self.attr_list[3]:setVisible(false)
        end
        if self.attr_list[6] then
            self.attr_list[6]:setVisible(false)
        end
    else
        local config_str = "attr_show_" .. self.cur_index
        local config = Config.GuildSkillData.data_const[config_str]
        local _x, _y = 0, 0
        if config and config.val then
            for i,attr_key in ipairs(config.val) do
                local attr_item = self.attr_list[i]
                if attr_item then
                    if self.attr_pos_x[i] then
                        attr_item:setPositionX(self.attr_pos_x[i])
                    end
                    attr_item:setVisible(true)
                    
                    local attr_value =  self.attr_value_list[attr_key]
                    self:updateAttrItem(attr_item, attr_value, attr_key)
                end
            end
        end
    end
end

function GuildskillMainWindow:updateAttrItem(attr_item, data, attr_key, attr_str)
    data = data or 0
    if attr_str == nil then
        local attr_config = Config.AttrData.data_key_to_name[attr_key] 
        if attr_config then
            attr_str = attr_config
        else
            attr_str = ""
        end
    end
    local value_str = ""
    if PartnerCalculate.isShowPerByStr(attr_key) == true then
        value_str = "+" ..(data * 0.1) .. "%"
    else
        value_str = "+" .. data
    end

    local attr_res = PathTool.getAttrIconByStr(attr_key)
    local str_res = string.format("<img src='%s' scale=1.0 /><div fontcolor=#68452A> %s</div><div fontsize=24 fontcolor=#249004> %s</div>",PathTool.getResFrame("common", attr_res),attr_str,value_str)
    attr_item:setString(str_res)
end

--==============================--
--desc:设置指定技能id的状态
--time:2018-06-20 07:33:19
--@skill_id:
--@return 
--==============================--
function GuildskillMainWindow:updateSkillItemById(skill_id)
    if skill_id == nil then return end
    local update_list = {}
    for i, item in ipairs(self.item_list) do
        if item.data and item.data.id == skill_id and not tolua.isnull(item.node) then
            if item.status ~= item.data.status then
                item.status = item.data.status
                setChildUnEnabled(item.status ~= GuildskillConst.status.activity, item.node )
            end

            -- 这里在吧这个技能的属性累加到当前总记录的里面去，并且更新制动的汇总技能
            if item.config then
                for i, v in ipairs(item.config.attr_list) do
                    if type(v) == "table" and(#v >= 2) then
                        if self.attr_value_list[v[1]] == nil then
                            self.attr_value_list[v[1]] = 0
                        end
                        self.attr_value_list[v[1]] = self.attr_value_list[v[1]] + v[2]
                        -- 储存需要更新的属性key
                        table_insert(update_list, v[1])
                    end
                end
            end
            break
        end
    end

    -- 做属性的更新
    self:updateSkillAttrNameAndVal()

    -- 升级特效
    if self.selected_item and not tolua.isnull(self.selected_item.node) then
        local _x, _y = self.selected_item.node:getPosition()
        self:handleUpgradeEffect(true, cc.p(_x, _y))
    end

    -- 重新选择一下下一个待点亮的
    local index = 1
    if self.cur_skill_info and self.cur_skill_info.skill_ids then
        for i,item in ipairs(self.cur_skill_info.skill_ids) do
            if item.status == GuildskillConst.status.un_activity then
                index = i 
                break
            end
        end
        self:changeSelectedItem(index, true)
    end
end

--==============================--
--desc:播放特效
--time:2018-06-22 04:29:11
--@status:
--@return 
--==============================--
function GuildskillMainWindow:handleUpgradeEffect(status, pos)
    if status == false then
        if self.upgrade_effect ~= nil then
            self.upgrade_effect:removeFromParent()
            self.upgrade_effect = nil
        end
    else
        local function finish_func()
            if not tolua.isnull(self.upgrade_effect) then
                self.upgrade_effect:setVisible(false)
            end
        end
        if self.upgrade_effect == nil then
            if not tolua.isnull(self.main_panel) then
                self.upgrade_effect = createEffectSpine(PathTool.getEffectRes(150), pos, cc.p(0.5, 0.5), false, PlayerAction.action)
                self.main_panel:addChild(self.upgrade_effect)
            end
            self.upgrade_effect:registerSpineEventHandler(finish_func, sp.EventType.ANIMATION_COMPLETE) 
        end
        self.upgrade_effect:setPosition(pos)
        self.upgrade_effect:setVisible(true)
        self.upgrade_effect:setAnimation(0, PlayerAction.action, false) 
    end
end 

--==============================--
--desc:技能组升级的特效
--time:2018-06-22 04:47:23
--@status:
--@pos:
--@return 
--==============================--
function GuildskillMainWindow:handleLevUpgradeEffect(status, action, loop)
    if status == false then
        if self.levupgrade_effect ~= nil then
            self.levupgrade_effect:removeFromParent()
            self.levupgrade_effect = nil
        end
    else
        local function finish_func()
            if not tolua.isnull(self.levupgrade_effect) then
                self.levupgrade_effect:setVisible(false)
                -- if self.levupgrade_effect_action == PlayerAction.action_1 then
                --     self.levupgrade_effect_action = PlayerAction.action_2
                --     if self.levupgrade_effect then
                --         self.levupgrade_effect:setAnimation(0, self.levupgrade_effect_action, true)
                --     end
                -- end
            end
        end
        local action = action or PlayerAction.action_1
        -- self.levupgrade_effect_action = action
        local loop = loop or false
        if self.levupgrade_effect == nil then
            if not tolua.isnull(self.lev_upgrade_model) then
                local size = self.lev_upgrade_model:getContentSize()
                self.levupgrade_effect = createEffectSpine(PathTool.getEffectRes(152), cc.p(size.width*0.5, size.height*0.5), cc.p(0.5, 0.5), loop, action)
                self.lev_upgrade_model:addChild(self.levupgrade_effect, 2)
            end
            self.levupgrade_effect:registerSpineEventHandler(finish_func, sp.EventType.ANIMATION_COMPLETE)
        else
            self.levupgrade_effect:setVisible(true)
        end
        self.levupgrade_effect:setAnimation(0, action, loop)
    end
end


function GuildskillMainWindow:updateGotoeLabelShowStatus(career)
    if career == nil then return end
    local object = model:getCareerSkillInfo(career)
     if object then
        if object.had_skill_up then
            self.reset_btn:setVisible(true)
        else
            self.reset_btn:setVisible(false)
        end
    end
end

--初始化pvp技能信息
function GuildskillMainWindow:updatePvPSkillList(career, is_chang_btn) 
    if career == nil then return end
    --显示原本界面就不用处理此界面内容
    if not self.is_pvp_show  then return end
    local pvp_career_data = model:getPvpskillInfoByCareer(career)

    local total_lev = 0
    local power = 0
    for i,v in ipairs(pvp_career_data.attr_formation) do
        total_lev = total_lev + v.lev
        local skill_item = self.item_list[i]
        local key = getNorKey(v.id, v.lev)
        local config =  Config.GuildSkillData.data_pvp_attr_info(key)
        if skill_item and config then
            skill_item.data = v
            skill_item.config = config
            power = power + config.power
            -- 设置显示状态
            if not tolua.isnull(skill_item.node) then
                local status = (v.lev == 0)
                if skill_item.status ~= status then
                    skill_item.status = status
                    setChildUnEnabled(status, skill_item.node)
                end
                if skill_item.is_ontouch_status ~= true then
                    skill_item.is_ontouch_status = true
                    skill_item.node:setTouchEnabled(true)
                end
            end
            -- 设置技能等级
            if not tolua.isnull(skill_item.lev) then
                skill_item.lev:setString(v.lev)
            end 
        end
    end
    self:onItemBtn(self.pvp_select_index)

    if self.pvp_skill_item == nil then
        self.pvp_skill_item = SkillItem.new(true,true,false,1, true)
        self.pvp_skill_item:setPosition(338, 114)
        self.pvp_skill_item:setCascadeOpacityEnabled(true)
        self.pvp_skill_item:addCallBack(function() self:onClickPvpSkillItem() end)
        self.main_panel:addChild(self.pvp_skill_item)
    else
        self.pvp_skill_item:setVisible(true)
    end
    if is_chang_btn then
        self:skillItemRunAction(self.pvp_skill_item, 338, 90, 338, 114)
    end

    local skill_lev = pvp_career_data.skill_lev
    if skill_lev <= 0 then
        skill_lev = 1
    end 
    local key = getNorKey(career, skill_lev)
    local pvp_skill_config = Config.GuildSkillData.data_pvp_skill_info(key)
    if pvp_skill_config then
        
        local skill_config = Config.SkillData.data_get_skill(pvp_skill_config.skill_id)
        if pvp_career_data.skill_lev == 0 then
            --表示要锁住
            self.pvp_skill_item:showLevel(false)
            self.pvp_skill_item:setData(skill_config)
            self.pvp_skill_item:showLockIcon(true)
            self.pvp_skill_item:showUnEnabled(true)
        else
            power = power + pvp_skill_config.power
            self.pvp_skill_item:showLevel(true)
            self.pvp_skill_item:setData(skill_config)
            self.pvp_skill_item:showLockIcon(false)
            self.pvp_skill_item:showUnEnabled(false)
        end
        local status = model:checkGuildPvpOnlySkillRedpoit(career, pvp_career_data.skill_lev, pvp_career_data.attr_formation)
        self.pvp_skill_item:showArrowRedPoint(status)
        -- (bool,name,pos,fontSize, is_bg,fontColor,res_img,res_size)
        self.pvp_skill_item:showName(true,skill_config.name,nil,22,true,cc.c4b(0xff,0xef,0xd7,0xff),PathTool.getResFrame("common","common_90003"),cc.size(168,31))
    end

    if self.pvp_tips_lable == nil then
        self.pvp_tips_lable = createRichLabel(24, cc.c3b(0x95,0x53,0x22), cc.p(0.5, 0.5), cc.p(315, 116), nil, nil, 500)
        local str = string_format(TI18N("(以上<div fontcolor=#249003>属性</div>和<div fontcolor=#249003>技能</div>仅在PVP战斗中生效)")) 
        self.pvp_tips_lable:setString(str)
        self.cost_container:addChild(self.pvp_tips_lable)
    else
        self.pvp_tips_lable:setVisible(true)
    end
    self.fight_label:setNum(power)

    self:updateSkillAttrNameAndVal()
    if total_lev > 0 then
        self.reset_btn:setVisible(true)
        self.reset_btn_label:setString(TI18N("重置本系PVP技能"))
    else
        self.reset_btn:setVisible(false)
    end
    local str = self:getPvpDescText(career, total_lev)
    self.career_desc:setString(str)
end

function GuildskillMainWindow:getPvpDescText(career, lev)
    if career == GuildskillConst.index.physics then
        return string_format(TI18N("战士天赋总等级<div fontcolor='#249003'>(%s/%s)</div>"), lev, self.pvp_max_lv)
    elseif career == GuildskillConst.index.magic then
        return string_format(TI18N("法师天赋总等级<div fontcolor='#249003'>(%s/%s)</div>"), lev, self.pvp_max_lv)
    elseif career == GuildskillConst.index.defence then
        return string_format(TI18N("坦克天赋总等级<div fontcolor='#249003'>(%s/%s)</div>"), lev, self.pvp_max_lv)
    elseif career == GuildskillConst.index.assist then
        return string_format(TI18N("辅助天赋总等级<div fontcolor='#249003'>(%s/%s)</div>"), lev, self.pvp_max_lv)
    else
        return ""
    end
end

--==============================--
--desc:初始化技能列表
--time:2018-06-20 02:46:17
--@career:
--@return 
--==============================--
function GuildskillMainWindow:updateSkillList(career, is_upgrade, need_update)
    if career == nil then return end
    --显示pvp界面就不用处理此界面内容
    if self.is_pvp_show  then return end
    local object = model:getCareerSkillInfo(career)
    
    if object then
        -- 相同的技能组，不做更新处理了
        if not need_update and self.cur_info_group_id == object.group_id then return end
        self.cur_info_group_id = object.group_id
        self.cur_skill_info = object

        if object.had_skill_up then
            self.reset_btn:setVisible(true)
            self.reset_btn_label:setString(TI18N("重置本系常规技能"))
        else
            self.reset_btn:setVisible(false)
        end
        -- 下一块开启的描述显示
        local group_config = Config.GuildSkillData.data_group[getNorKey(career, object.group_id)] 
        if group_config ~= nil then
            local max_group = model:getCareerGroupMax(career)
            self.career_desc:setString(string_format("%s<div fontcolor='#249003'>(%s/%s)</div>",group_config.group_name, group_config.group_seq, max_group))
        end

        -- 给显示单位储存数据结构
        if object.skill_ids then
            local index = 0
            local skill_item = nil
            local config = nil
            for i, item in ipairs(object.skill_ids) do
                -- 储存对应技能单位属性
                skill_item = self.item_list[i]
                config = Config.GuildSkillData.data_info(item.id) 
                if skill_item and config then
                    skill_item.data = item
                    skill_item.config = config 
                    -- 设置显示状态
                    if not tolua.isnull(skill_item.node) then
                        if skill_item.status ~= item.status then
                            skill_item.status = item.status
                            setChildUnEnabled(item.status ~= GuildskillConst.status.activity, skill_item.node)
                        end

                        if skill_item.is_ontouch_status ~= false then
                            skill_item.is_ontouch_status = false
                            skill_item.node:setTouchEnabled(false)
                        end
                    end

                    
                    -- 设置技能等级
                    if not tolua.isnull(skill_item.lev) then
                        skill_item.lev:setString(config.lev)
                    end 
                end

                -- 选中当前待升级的那个
                if item.status == GuildskillConst.status.un_activity then
                    if index == 0 then
                        index = i 
                    end
                end
            end
            -- 如果遍历完了还是0，其实这个时候已经是最高等级了，那就随便选中一个
            if index == 0 then
                index = 1
            end
            self:changeSelectedItem(index, true) 
        end

        self:calculateTotalAttr()
    end

    -- 如果是升级，播放升级特效
    if is_upgrade == true then
        self:handleLevUpgradeEffect(true)
    end
end

function GuildskillMainWindow:updateMiddleBg(career, is_chang_btn)

    if self.Sprite_5 then
        if self.is_pvp_show then
            loadSpriteTexture(self.Sprite_5, PathTool.getResFrame("guildskill", "guildskill_903"), LOADTEXT_TYPE_PLIST)
            self.attr_desc:setString(TI18N("PVP\n 加\n 成\n 总\n 览"))
            self.attr_desc:setPositionX(19)  
        else
            loadSpriteTexture(self.Sprite_5, PathTool.getResFrame("guildskill", "guildskill_902"), LOADTEXT_TYPE_PLIST)     
            self.attr_desc:setString(TI18N("加\n成\n总\n览"))
            self.attr_desc:setPositionX(27)  
        end
    end
    if self.career_action_list[career] then
        local action, loop , change_action
        if is_chang_btn then
            loop = false
            if self.is_pvp_show then
                action = self.career_action_list[career][2]
                change_action = self.career_action_list[career][4]
            else
                action = self.career_action_list[career][1]
                change_action = self.career_action_list[career][3]
            end
        else
            loop = true
            if self.is_pvp_show then
                action = self.career_action_list[career][4]
            else
                action = self.career_action_list[career][3]
            end
        end
        self:showCareerActionEffect(true, action, loop, change_action)
    end

    -- local camp_res
    -- if self.is_pvp_show then
    --     camp_res  = PathTool.getPlistImgForDownLoad("guildskill","guildskill_bg_2", false)
    -- else
    --     camp_res  = PathTool.getPlistImgForDownLoad("guildskill","guildskill_bg", false)
    -- end
    -- if self.record_middle_res ~= camp_res then
    --     self.record_middle_res = camp_res
    --     self.middle_bg_load = loadSpriteTextureFromCDN(self.middle_bg, camp_res, ResourcesType.single, self.middle_bg_load) 
    -- end

    -- if career then
    --     local camp_res = PathTool.getPlistImgForDownLoad("guildskill","guildskill_career_"..career, false)
    --     if self.record_middle_icon_res ~= camp_res then
    --         self.record_middle_icon_res = camp_res
    --         self.middle_icon_load = loadSpriteTextureFromCDN(self.middle_icon, camp_res, ResourcesType.single, self.middle_icon_load) 
    --     end
    -- end
end

function GuildskillMainWindow:showCareerActionEffect(status, action, loop, change_action)
    if status then
        local action = action or "action11"
        local loop = loop or false
        self.record_career_action = action
        self.change_action = change_action

        if self.career_action_effect == nil then
            local size = self.lev_upgrade_model:getContentSize()
            self.career_action_effect = createEffectSpine("E27951", cc.p(size.width*0.5, size.height*0.5), cc.p(0.5, 0.5), loop, action)
            self.lev_upgrade_model:addChild(self.career_action_effect, 1)

            self.career_action_effect:registerSpineEventHandler(function() 
                if self.change_action and self.record_career_action ~= self.change_action then
                    self.record_career_action = self.change_action
                    self.change_action = nil
                    if self.career_action_effect then
                        self.career_action_effect:setAnimation(0, self.record_career_action, true)
                    end
                end
            end, sp.EventType.ANIMATION_COMPLETE)
        else
            self.career_action_effect:setAnimation(0, action, loop)
        end
    else
        if self.career_action_effect then
            self.career_action_effect:removeFromParent()
            self.career_action_effect = nil
        end
    end
end

--==============================--
--desc:计算当前总属性，这边会缓存属性，下一次点亮之后只需要累加处理
--time:2018-06-20 04:02:20
--@return 
--==============================--
function GuildskillMainWindow:calculateTotalAttr()
    if self.cur_skill_info == nil then return end
    local activity_skill_list = {}          -- 已经激活的技能
    if self.cur_skill_info.group_ids and next(self.cur_skill_info.group_ids) then
        -- 首先把已经激活的技能组里面包含的所有技能储存起来
        for i,v in ipairs(self.cur_skill_info.group_ids) do
            local group_config = Config.GuildSkillData.data_info_group[v.group_id]
            if group_config == nil then return end
            for n, m in ipairs(group_config) do
                table_insert(activity_skill_list, m.id)
            end
        end
    end

    -- 储存当前的技能组已经激活的技能
    if self.cur_skill_info.skill_ids and next(self.cur_skill_info.skill_ids) then
        for i,v in ipairs(self.cur_skill_info.skill_ids) do
            if v.status == GuildskillConst.status.activity then
                table_insert(activity_skill_list, v.id)
            end
        end
    end

    local activity_attr_dic = {}
    for i,v in ipairs(activity_skill_list) do
        local skill_config = Config.GuildSkillData.data_info(v)
        if skill_config ~= nil then
            for n, m in ipairs(skill_config.attr_list) do
                if activity_attr_dic[m[1]] == nil then
                    activity_attr_dic[m[1]] = 0
                end
                activity_attr_dic[m[1]] = activity_attr_dic[m[1]] + m[2]
            end
        end
    end

    -- 这里是判断所有的数据
    self.attr_value_list = activity_attr_dic
    self:updateSkillAttrNameAndVal()
end

--更新中间单条属性信息
function GuildskillMainWindow:updateSingleAttr(attr_key, attr_value, attr_str)
    if self.attr_title and self.attr_value then
        local attr_name
        if attr_str then
            attr_name = attr_str
        else
            attr_name = Config.AttrData.data_key_to_name[attr_key]
        end
        if attr_name then
            self.attr_title:setString(attr_name)
            -- 如果是百分比数值
            if PartnerCalculate.isShowPerByStr(attr_key) == true then
                self.attr_value:setString("+"..(attr_value*0.1).."%")
            else
                self.attr_value:setString("+"..attr_value)
            end
        end
    end
end

--==============================--
--desc:单元选中
--time:2018-06-20 10:24:26
--@index:
--@force:是否强制显示
--@return 
--==============================--
function GuildskillMainWindow:changeSelectedItem(index, force)
    if self.selected_item and (not force) then
        if self.selected_item.index == index then return end
    end
    self.selected_item = self.item_list[index]
    if self.selected_item == nil then return end

    if not tolua.isnull(self.selected_item.node) then
        self.selected:setPosition(self.selected_item.x, self.selected_item.y)
    end
 -- self.attr_title = self.single_item_attr_container:getChildByName("attr_title")
 --    self.attr_value = self.single_item_attr_container:getChildByName("attr_value")
    -- 做显示属性切换
    local config = self.selected_item.config
    if config then
        local attr_key = nil
        local attr_name = nil
        for i,v in ipairs(config.attr_list) do
            if type(v) == "table" and (#v >= 2) then
                self:updateSingleAttr(v[1], v[2])
            end
        end
        self:updateCostInfo()
    end
end

--==============================--
--desc:点亮消耗
--time:2018-06-21 01:53:14
--@return 
--==============================--
function GuildskillMainWindow:updateCostInfo()
    if self.selected_item == nil or self.selected_item.config == nil or self.selected_item.data == nil then return end
    if not self.selected_tab then return end
    local config = self.selected_item.config
    local data = self.selected_item.data
    
    if self.is_pvp_show then
        --pvp的
        local max_lev = Config.GuildSkillData.data_pvp_attr_max_lev[data.id]
        if max_lev and config.lev and config.lev >= max_lev  then
            --满级了
            for i,v in ipairs(self.cost_bg_list) do
                v.cost_bg:setVisible(false)
            end
            self.handle_btn:setVisible(false)
            if self.pvp_max_lev_label == nil then
                self.pvp_max_lev_label = createRichLabel(24, cc.c3b(0x64,0x32,0x23), cc.p(0.5, 0.5), cc.p(315, 44), nil, nil, 500) 
                self.pvp_max_lev_label:setString(TI18N("属性已达最大等级"))
                self.cost_container:addChild(self.pvp_max_lev_label)
            else
                self.pvp_max_lev_label:setVisible(true)
            end
        else
            self:updateCostDetailInfo(config.loss)
        end
    else
        --原来的
        if config.lev >= 40 and data.status == GuildskillConst.status.activity then
            for i,v in ipairs(self.cost_bg_list) do
                v.cost_bg:setVisible(false)
            end

            if self.max_lev_label == nil then
                self.max_lev_label = createRichLabel(24, cc.c3b(0x64,0x32,0x23), cc.p(0.5, 0.5), cc.p(315, 97), nil, nil, 500) 
                self.cost_container:addChild(self.max_lev_label) 
            else
                self.max_lev_label:setVisible(true) 
            end

            local career = self.selected_tab.career or GuildskillConst.index.physics
            local pvp_career_data = model:getPvpskillInfoByCareer(career)
            --说明玩家没有突破来
            if pvp_career_data and pvp_career_data.attr_formation and #pvp_career_data.attr_formation == 0 then
                local str = TI18N("突破后获得全新的<div fontcolor=#249003>PVP属性</div>和<div fontcolor=#249003>技能</div>")
                self.max_lev_label:setString(str)
                self.max_lev_label:setPositionY(97)
                setChildUnEnabled(false, self.handle_btn)
                self.handle_btn_label:enableOutline(Config.ColorData.data_color4[264],2)
                self.handle_btn:setVisible(true)
                self.handle_btn_label:setString(TI18N("突 破"))
            else
                self.max_lev_label:setString(TI18N("<div fontcolor=#249003>属性已达最大重天</div>"))
                self.max_lev_label:setPositionY(73)
                self.handle_btn:setVisible(false)
            end

        else
            self:updateCostDetailInfo(config.loss)
        end
    end
end

function GuildskillMainWindow:updateCostDetailInfo(cost)
    for i,v in ipairs(self.cost_bg_list) do
        v.cost_bg:setVisible(true)
    end
    self.handle_btn:setVisible(true)
    if self.max_lev_label then
        self.max_lev_label:setVisible(false)
    end

    if self.pvp_max_lev_label then
        self.pvp_max_lev_label:setVisible(false)
    end
    if self.upgrade_cost_list == nil then
        self.upgrade_cost_list = {}
    end
        -- self.upgrade_cost_list.base_list = {}       -- 基础消耗
    self.upgrade_cost_list.item_list = {}       -- 物品
    self.upgrade_cost_list.asset_list = {}      -- 资产物品   

    if cost then
        local condition_status = true
        for i=1,2 do
            local cost_data = cost[i]
            local cost_icon = self.cost_bg_list[i].cost_icon
            local cost_txt = self.cost_bg_list[i].cost_txt
            if cost_data then
                local bid = cost_data[1]
                local num = cost_data[2]
                local have_num = 0
                local item_config = Config.ItemData.data_get_data(bid)
                if item_config then
                    cost_icon:loadTexture(PathTool.getItemRes(item_config.icon), LOADTEXT_TYPE)
                    have_num = BackpackController:getInstance():getModel():getItemNumByBid(bid)
                    cost_txt:setString(MoneyTool.GetMoneyString(have_num) .. "/" .. MoneyTool.GetMoneyString(num))
                    if have_num >= num then
                        cost_txt:setTextColor(cc.c3b(255, 246, 228))
                    else
                        condition_status = false
                        cost_txt:setTextColor(cc.c3b(0xff,0x8b,0x8b))
                    end
                end

                local asset_key = Config.ItemData.data_assets_id2label[bid] 
                if asset_key ~= nil then       -- 资产
                    self.upgrade_cost_list.asset_list[asset_key] = true
                else
                    self.upgrade_cost_list.item_list[bid] = true
                end
            else
                cost_txt:setString("")
            end
        end

        self:checkUpgradeCostStatus(condition_status)
    end
end


--==============================--
--desc:设置更新状态
--time:2018-07-24 11:13:40
--@return 
--==============================--
function GuildskillMainWindow:checkUpgradeCostStatus(condition_status)
    if self.selected_item == nil or self.selected_item.config == nil then return end
    local config = self.selected_item.config


    local condition_type = 0  -- 1：消耗不足 2：满足 3：条件不足
    if config.guild_lev == nil or role_vo.guild_lev >= config.guild_lev then
        if condition_status == false then
            condition_type = 1
        else
            condition_type = 2
        end
    else
        condition_type = 3
    end

    -- if self.condition_type ~= condition_type then
    --     self.condition_type = condition_type
        if condition_type == 1 then
            -- self.handle_btn:setTouchEnabled(false)
            setChildUnEnabled(true, self.handle_btn)
            self.handle_btn_label:disableEffect()
            self.handle_btn_label:setString(TI18N("消耗不足"))
        elseif condition_type == 2 then
            -- self.handle_btn:setTouchEnabled(true)
            setChildUnEnabled(false, self.handle_btn)
            self.handle_btn_label:enableOutline(Config.ColorData.data_color4[264],2)
           
        elseif condition_type == 3 then
            -- self.condition_value:setVisible(true)
            -- self.condition_value:setString(string.format(TI18N("需要公会到达%s级"), config.guild_lev))
            -- self.handle_btn:setTouchEnabled(false)
            setChildUnEnabled(true, self.handle_btn)
            self.handle_btn_label:disableEffect()
            self.handle_btn_label:setString(TI18N("条件不足"))
        end
    -- end
    --因为加了 pvp 的所以这里切换也要变化 不能根据条件来了
    if condition_type == 2 then
        if self.is_pvp_show then
            self.handle_btn_label:setString(TI18N("升 级"))
            local cur_item = self.item_list[self.pvp_select_index]
            local is_status = true --满足条件
            if cur_item and cur_item.config then
                for i,item in ipairs(self.item_list) do
                    if i <= 4 and item.data and item.data.lev and item.data.lev < cur_item.config.need_lev  then
                        --不满足条件
                        is_status = false
                        break
                    end
                end
            end
            if not is_status then
                setChildUnEnabled(true, self.handle_btn)
                self.handle_btn_label:disableEffect()
                if self.show_pvp_tips == nil then
                    self.show_pvp_tips = createLabel(20, cc.c3b(0xff,0x00,0x00), nil, 544, 0, "", self.cost_container, nil, cc.p(0.5, 0.5))
                else
                    self.show_pvp_tips:setVisible(true) 
                end
                local str = string_format(TI18N("其他属性达%s级"), cur_item.config.need_lev)
                self.show_pvp_tips:setString(str)
            else

                setChildUnEnabled(false, self.handle_btn)
                self.handle_btn_label:enableOutline(Config.ColorData.data_color4[264],2)

                if self.show_pvp_tips then
                    self.show_pvp_tips:setVisible(false)
                end
            end
        else
            self.handle_btn_label:setString(TI18N("点 亮"))
            if self.show_pvp_tips then
                self.show_pvp_tips:setVisible(false)
            end
        end
    else
        if self.show_pvp_tips then
            self.show_pvp_tips:setVisible(false)
        end
    end
end


--==============================--
--desc:物品增删的时候处理
--time:2018-07-24 10:44:34
--@list:
--@return 
--==============================--
function GuildskillMainWindow:changeNeedItemInfo(list)
    if self.upgrade_cost_list == nil or self.upgrade_cost_list.item_list == nil then return end
    if list == nil or next(list) == nil then return end
    local list_dict = {}
    for i,vo in pairs(list) do
        if vo.base_id then
            list_dict[vo.base_id] = true
        end
    end
    local need_update = false
    self.auto_buy_item_price = 0
    for k, v in pairs(self.upgrade_cost_list.item_list) do
        if list_dict[k] == true then
            need_update = true
            local sum = backpack_model:getBackPackItemNumByBid(k) 
            if v.item and v.item.setNeedNum then
                v.item:setNeedNum(v.need_num, sum)
                if sum < v.need_num then
                    self.auto_buy_item_price = self.auto_buy_item_price + self:getItemPrice(k) * (v.need_num - sum)
                    v.condition_status = true
                else
                    v.condition_status = true
                end
            end
        end
    end
    if need_update == true then
        self:checkUpgradeCostStatus()
    end
end

function GuildskillMainWindow:close_callback()    
    -- if self.attr_list then
    --     for i,v in ipairs(self.attr_list) do
    --         v:DeleteMe()
    --     end
    --     self.attr_list = {}
    -- end

    self:handleUpgradeEffect(false)
    self:handleLevUpgradeEffect(false)

    if not tolua.isnull(self.selected) then
        self.selected:stopAllActions()
    end
    
    if self.fight_label then
        self.fight_label:DeleteMe()
        self.fight_label = nil
    end

    for k,v in pairs(self.backpack_item_list) do
        v:DeleteMe()
    end
    self.backpack_item_list = {}

    if self.update_guildskill_event then
        GlobalEvent:getInstance():UnBind(self.update_guildskill_event)
        self.update_guildskill_event = nil
    end
    if self.reset_guildskill_event then
        GlobalEvent:getInstance():UnBind(self.reset_guildskill_event)
        self.reset_guildskill_event = nil
    end
    if self.update_skillstatus_event then
        GlobalEvent:getInstance():UnBind(self.update_skillstatus_event)
        self.update_skillstatus_event = nil
    end
    if self.update_skillupgrade_event then
        GlobalEvent:getInstance():UnBind(self.update_skillupgrade_event)
        self.update_skillupgrade_event = nil
    end
    if self.update_guild_skill_red_event then
        GlobalEvent:getInstance():UnBind(self.update_guild_skill_red_event)
        self.update_guild_skill_red_event = nil
    end
    if self.add_item_data_event then
        GlobalEvent:getInstance():UnBind(self.add_item_data_event)
        self.add_item_data_event = nil
    end
    if self.update_item_data_event then
        GlobalEvent:getInstance():UnBind(self.update_item_data_event)
        self.update_item_data_event = nil
    end

    if role_vo then
        if self.update_role_assets_event ~= nil then 
            role_vo:UnBind(self.update_role_assets_event)
            self.update_role_assets_event = nil
        end
    end

    controller:openGuildSkillMainWindow(false)
end
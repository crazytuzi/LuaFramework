-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      快速战斗
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------

BattlDramaQuickBattleWindow = BattlDramaQuickBattleWindow or BaseClass(BaseView)

local controller = BattleDramaController:getInstance()
local model = BattleDramaController:getInstance():getModel()
local table_insert = table.insert

function BattlDramaQuickBattleWindow:__init()
    self.layout_name = "battledrama/battle_drama_quick_battle_windows"
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.quick_battle_status = 0 --0是免费,1是有道具,2是用钱3是次数用完不能点击
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_50"), type = ResourcesType.single },
    }
end

function BattlDramaQuickBattleWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("root")
    self:playEnterAnimatianByObj(self.main_container, 2)
    self.close_btn = self.main_container:getChildByName("close_btn")
    self.holid_up = self.main_container:getChildByName("holid_up")
    self.holid_up:getChildByName("Text_1"):setString(TI18N("活动UP!"))
    self.holid_up:setVisible(false)
    self.quick_num_label = createRichLabel(22, 175, cc.p(0.5, 0.5), cc.p(self.main_container:getContentSize().width/2,410), nil, nil, 1000)
    self.main_container:addChild(self.quick_num_label)


    self.quick_btn = createButton(self.main_container, TI18N("快速作战"), self.main_container:getContentSize().width/2,360, cc.size(220, 64), PathTool.getResFrame("common", "common_1017"), 26, Config.ColorData.data_color4[1])
    self.quick_btn:enableShadow(Config.ColorData.data_new_color4[3],cc.size(0, -2),2)

    self.source_btn = self.main_container:getChildByName("source_btn")
    self.source_btn:setVisible(false)
    --self.source_btn:getChildByName("label"):setString(TI18N("获取快速作战券"))

    self.main_container:getChildByName("use_title"):setString(TI18N("本关怪物掉落："))

    self.explain_btn = self.main_container:getChildByName("explain_btn")

    self.desc = self.main_container:getChildByName("desc")
    self.desc:setVisible(false)
    self.quick_desc = createRichLabel(22, 175, cc.p(0, 0.5), cc.p(100,780), 5, nil, 530)
    self.main_container:addChild(self.quick_desc)

    -- self.desc:setString(TI18N("使用快速作战券,可直接获得2小时\n的经验和物品收益"))
    self.btn_buy_quick = self.main_container:getChildByName("btn_buy_quick")
    self.btn_buy_quick:getChildByName("Text_2"):setString(TI18N("前往激活"))
    self.btn_buy_quick:setVisible(false)

    self.list_view = self.main_container:getChildByName("list_view")
    if self.item_scrollview == nil then
        local size = self.list_view:getContentSize()
        local setting = {
            item_class = BatttleQuickItem,      -- 单元类
            start_x = 22,                  -- 第一个单元的X起点
            space_x = 30,                    -- x方向的间隔
            start_y = 10,                    -- 第一个单元的Y起点
            space_y = 10,                   -- y方向的间隔
            item_width = 119,               -- 单元的尺寸width
            item_height = 119,              -- 单元的尺寸height
            row = 1,                        -- 行数，作用于水平滚动类型
            col = 4,                         -- 列数，作用于垂直滚动类型
        }
        self.item_scrollview = CommonScrollViewLayout.new(self.list_view, cc.p(0, 0) , ScrollViewDir.vertical, ScrollViewStartPos.top, size, setting)
    end
    
    -- 引导需要
    local button = self.quick_btn:getButton()
    button:setName("guidesign_quick_btn")
end

function BattlDramaQuickBattleWindow:updateData()
    local data = model:getDramaData()
    local quickdata = model:getQuickData() or {}
    local hook_max_time = model.hook_max_time or 120
    if quickdata then
        local status = RoleController:getInstance():getModel():checkPrivilegeStatus(1)
        local tips_str = string.format(TI18N("快速作战可获得<div fontcolor=#249003>%s</div>分钟挂机收益。"), hook_max_time)
        tips_str = tips_str .. "\n" .. string.format(TI18N("激活快速作战特权:每天免费<div fontcolor=#249003>3</div>次，额外购买<div fontcolor=#249003>11</div>次"))
        if status then
            tips_str = tips_str .. string.format(TI18N("<div fontcolor=#249003>(特权已激活)</div>"))
            self.btn_buy_quick:setVisible(false)
        else
            tips_str = tips_str .. string.format(TI18N("<div fontcolor=#c92606>(特权未激活)</div>"))
            self.btn_buy_quick:setVisible(true)
        end
        self.quick_desc:setString(tips_str)
    end

    if data and data.max_dun_id then
        local config = Config.DungeonData.data_drama_dungeon_info(data.max_dun_id)
        if config and config.quick_show_items then
            local list = {}
            local num = 0
            for i,v in ipairs(config.quick_show_items) do
                num = v[2]
                if quickdata and quickdata.fast_combat_add_time and quickdata.fast_combat_add_time > 0 then
                    num = num + math.floor(num * quickdata.fast_combat_add_time / hook_max_time)
                end
                table_insert( list, {bid = v[1], num = num} )
            end
            self.item_scrollview:setData(list)
        end
    end

    -- if Config.DungeonData.data_drama_quick_desc then
    --     local str = ""
    --     for i, v in ipairs(Config.DungeonData.data_drama_quick_desc) do
    --         str = str..v.desc.."\n" --.. string.format("<img src=%s visible=true scale=1 /> ", PathTool.getResFrame("common", "common_1004"))
    --     end
    --     self.desc_label:setString(str)
    -- end
    self.quick_data = BattleDramaController:getInstance():getModel():getQuickData()

    self:checkQuickBattle()
end

function BattlDramaQuickBattleWindow:register_event()
    if self.background then
        self.background:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playCloseSound()
                controller:openDramBattleQuickView(false) 
            end
        end)
    end
    --[[if self.source_btn then
        self.source_btn:addTouchEventListener(function(sender, event_type)
            customClickAction(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                if Config.DungeonData.data_drama_const["quick_swap_item"] and Config.DungeonData.data_drama_const["quick_swap_item"].val then
                    local config = Config.ItemData.data_get_data(Config.DungeonData.data_drama_const["quick_swap_item"].val)
                    BackpackController:getInstance():openTipsSource(true, config)
                end
            end
        end)
    end--]]
    if self.close_btn then
        self.close_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playCloseSound()
                controller:openDramBattleQuickView(false) 
            end
        end)
    end

    registerButtonEventListener(self.btn_buy_quick, function()
        VipController:getInstance():openVipMainWindow(true, VIPTABCONST.PRIVILEGE)
        --MallController:getInstance():openChargeShopWindow(true, MallConst.Charge_Shop_Type.Privilege)
    end ,false, 1)

    registerButtonEventListener(self.explain_btn, function(param,sender, event_type)
        local config = Config.DungeonData.data_drama_const.game_rule     
        TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
    end ,false, 1)

    if self.quick_btn then
        self.quick_btn:addTouchEventListener(function(sender, event_type)
            customClickAction(sender,event_type)
            if event_type == ccui.TouchEventType.ended then
                if self.quick_battle_status == 0 or self.quick_battle_status == 1 then
                    self:send13004()
                elseif self.quick_battle_status == 3 then
                    if not self.privilege_status then -- 未开通特权，则弹出提示
                        -- 改成直接跳转
                        VipController:getInstance():openVipMainWindow(true, VIPTABCONST.PRIVILEGE)
                        --MallController:getInstance():openChargeShopWindow(true, MallConst.Charge_Shop_Type.Privilege)
                        controller:openDramBattleQuickView(false)
                        --[[local str = TI18N("购买快速作战特权可增加每日快速作战次数（包含2次免费次数），是否前往购买？")
                        local function fun()
                            VipController:getInstance():openVipMainWindow(true, VIPTABCONST.PRIVILEGE)
                            controller:openDramBattleQuickView(false)
                        end
                        CommonAlert.show(str,TI18N("确认"), fun,TI18N("取消"),nil, CommonAlert.type.rich,nil, nil, nil, true)--]]
                    else
                        self:send13004()
                    end
                else
                    self.cost = self.cost or 0
                    local str = TI18N("本次快速作战花费")..string.format("<img src=%s visible=true scale=0.3 /><div>x%s</div>", PathTool.getItemRes(Config.ItemData.data_assets_label2id.gold), self.cost)
                    local function fun()
                        self:send13004()
                    end
                    CommonAlert.show(str,TI18N("确认"), fun,TI18N("取消"),nil, CommonAlert.type.rich,nil, nil, nil, true)
                end
            end
        end)
    end
    -- if not self.add_goods_event then
    --     self.add_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS, function(bag_code, data_list)
    --         if bag_code == BackPackConst.Bag_Code.BACKPACK then
    --             for i, v in pairs(data_list) do
    --                 if v and v.base_id and v.base_id == Config.DungeonData.data_drama_const["quick_swap_item"].val then
    --                    self:checkQuickBattle()
    --                 end
    --             end
    --         end
    --     end)
    -- end
    -- if not self.modify_add_event then
    --     self.modify_add_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code, data_list)
    --         if bag_code == BackPackConst.Bag_Code.BACKPACK then
    --             for i, v in pairs(data_list) do
    --                 if v and v.base_id and v.base_id == Config.DungeonData.data_drama_const["quick_swap_item"].val then
    --                    self:checkQuickBattle()
    --                 end
    --             end
    --         end
    --     end)
    -- end
    if not self.update_dram_quick_battle_event then
        self.update_dram_quick_battle_event = GlobalEvent:getInstance():Bind(Battle_dramaEvent.BattleDrama_Quick_Battle_Data, function(data)
            if data then
                self.quick_data = data
                self:updateData()
                -- self:checkQuickBattle()
            end
        end)
    end
end

--发送协议13004协议
function BattlDramaQuickBattleWindow:send13004()
    local role_vo =  RoleController:getInstance():getRoleVo()
    if not role_vo then return end
    local cur_energy = role_vo.energy
    local max_energy = role_vo.energy_max
    local qingbao_val = 0 -- 2个小时的情报值值
    local vip_add_per = 0 -- vip情报加成
    --vip加成暂时没有的
    -- local vip_config = Config.VipData.data_get_vip_info[role_vo.vip_lev]
    -- if vip_config and vip_config.val then
    --     for i,v in ipairs(vip_config.val) do
    --         if v[1] == "dungeon" then
    --             vip_add_per = v[2] /1000 --表填的是千分比
    --         end
    --     end
    -- end
    --情报时间
    local hook_max_time = model.hook_max_time or 120

    local drama_data = BattleDramaController:getInstance():getModel():getDramaData() or {}
    local config = Config.DungeonData.data_drama_dungeon_info(drama_data.dun_id)
    if config  and config.per_hook_items then
        for i,v in ipairs(config.per_hook_items ) do
            if v[1] == Config.ItemData.data_assets_label2id.energy then
                --情报
                qingbao_val = v[2] * hook_max_time * (1 + vip_add_per)
            end
        end
    end

    if (cur_energy + qingbao_val) > max_energy then
        local function call_back()
            BattleDramaController:getInstance():send13004()
        end

        local str = string.format(TI18N("注意:当前拥有<div fontcolor=#249003>%s/%s</div>远航情报,快速作战后,远航情报溢出部分将会损失,是否继续？"), cur_energy, max_energy)
        CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich,nil,
            {timer = 3, timer_for = true, off_y = 0, title = TI18N("提示")},24)
    else
        BattleDramaController:getInstance():send13004()
    end
end

function BattlDramaQuickBattleWindow:checkQuickBattle()
    if self.quick_data then
        self.privilege_status = RoleController:getInstance():getModel():checkPrivilegeStatus(1)

        if self.quick_data.is_holiday == 1 then
            self.holid_up:setVisible(true)
        else
            self.holid_up:setVisible(false)
        end
        -- 普通剩余次数（消耗钻石）
        local combat_num = self.quick_data.fast_combat_max - self.quick_data.fast_combat_num
        -- 特权剩余次数（消耗钻石）
        local privilege_num = Config.PrivilegeData.data_fast_combat_cost_length - self.quick_data.fast_combat_p_num
        local str = string.format("%s<div fontColor=#249003>%s</div>%s",TI18N("今日剩余:"),combat_num,TI18N("次"))

        if self.privilege_status then
            str = string.format("%s<div fontColor=#249003>%s+%s</div>%s",TI18N("今日剩余:"),combat_num, privilege_num,TI18N("次"))
        end
        
        --快速作战活动的次数增加
        if self.quick_data.is_holiday == 1 or self.privilege_status == true then
            if self.quick_data.is_holiday == 1 and self.privilege_status == true then --活动与特权同时存在
                local holid_num = Config.DungeonData.data_drama_const.hd_fast_combat_buy_time.val - self.quick_data.fast_combat_w_num
                str = string.format("%s<div fontColor=#249003>%s+%s</div>%s",TI18N("今日剩余:"),combat_num, holid_num+privilege_num,TI18N("次"))
            elseif self.privilege_status == true then --仅有特权
                str = string.format("%s<div fontColor=#249003>%s+%s</div>%s",TI18N("今日剩余:"),combat_num, privilege_num,TI18N("次"))
            else
                local holid_num = Config.DungeonData.data_drama_const.hd_fast_combat_buy_time.val - self.quick_data.fast_combat_w_num
                str = string.format("%s<div fontColor=#249003>%s+%s</div>%s",TI18N("今日剩余:"),combat_num, holid_num,TI18N("次"))
            end
        end

        self.cost = 0
        local btn_str = ""
        if self.quick_data.fast_combat_free_num > 0 then --代表是免费的
            btn_str = TI18N("<div fontcolor=#ffffff shadow=0,-2,2,#0e73b3>快速战斗</div>")
            self.quick_battle_status = 0
            str = TI18N("本次免费")
        else --不是免费的了
            if self.privilege_status then -- 特权开启
                self.quick_num_label:setVisible(true)
                -- 先判断普通次数是否用完
                local index = self.quick_data.fast_combat_num + 1
                local cost_config = Config.PrivilegeData.data_fast_combat_cost[self.quick_data.fast_combat_p_num+1]
                if Config.DungeonData.data_drama_quick_cost[index] then -- 普通次数未用完
                    self.quick_battle_status = 2
                    self.cost = Config.DungeonData.data_drama_quick_cost[index].cost
                    btn_str = string.format(TI18N("<img src=%s visible=true scale=0.25 /><div fontcolor=#ffffff shadow=0,-2,2,#0e73b3>%s 快速战斗</div>"),PathTool.getItemRes(Config.ItemData.data_assets_label2id.gold), self.cost)
                elseif cost_config then -- 特权次数未用完
                    self.quick_battle_status = 2
                    self.cost = cost_config.cost
                    btn_str = string.format(TI18N("<img src=%s visible=true scale=0.25 /><div fontcolor=#ffffff shadow=0,-2,2,#0e73b3>%s 快速战斗</div>"),PathTool.getItemRes(Config.ItemData.data_assets_label2id.gold), self.cost)
                else -- 所有次数都用完
                    self.quick_battle_status = 3
                    btn_str = TI18N("<div fontcolor=#ffffff outline=2,#764519>快速战斗</div>")
                end
            else -- 没有特权
                local index = self.quick_data.fast_combat_num + 1
                if Config.DungeonData.data_drama_quick_cost[index] then
                    self.quick_battle_status = 2
                    self.cost = Config.DungeonData.data_drama_quick_cost[index].cost
                    btn_str = string.format(TI18N("<img src=%s visible=true scale=0.25 /><div fontcolor=#ffffff shadow=0,-2,2,#0e73b3>%s 快速战斗</div>"),PathTool.getItemRes(Config.ItemData.data_assets_label2id.gold), self.cost)
                else -- 次数用完
                    local const = Config.DungeonData.data_drama_const
                    --快速作战活动的次数增加
                    if self.quick_data.is_holiday == 1 and self.quick_data.fast_combat_w_num < const.hd_fast_combat_buy_time.val then 
                        self.quick_battle_status = 2
                        self.cost = const.hd_fast_combat_lose.val[1][2]
                        btn_str = string.format(TI18N("<img src=%s visible=true scale=0.25 /><div fontcolor=#ffffff shadow=0,-2,2,#0e73b3>%s 快速战斗</div>"),PathTool.getItemRes(const.hd_fast_combat_lose.val[1][1]), self.cost)
                    else
                        self.quick_battle_status = 3
                        btn_str = TI18N("<div fontcolor=#ffffff shadow=0,-2,2,#0e73b3>获取更多次数</div>")
                    end
                end
            end 
        end
        self.quick_num_label:setString(str)
        self.quick_btn:setRichText(btn_str, 28)
    end
end

function BattlDramaQuickBattleWindow:openRootWnd()
    self:updateData()
end

function BattlDramaQuickBattleWindow:close_callback()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end

    if self.update_dram_quick_battle_event then
        GlobalEvent:getInstance():UnBind(self.update_dram_quick_battle_event)
        self.update_dram_quick_battle_event = nil
    end
    if self.add_goods_event then
        GlobalEvent:getInstance():UnBind(self.add_goods_event)
        self.add_goods_event = nil
    end
    if self.modify_add_event then
        GlobalEvent:getInstance():UnBind(self.modify_add_event)
        self.modify_add_event = nil
    end
	GlobalEvent:getInstance():Fire(BattleEvent.CLOSE_RESULT_VIEW)
    controller:openDramBattleQuickView(false)
end





-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
BatttleQuickItem = class("BatttleQuickItem", function()
    return ccui.Layout:create()
end)

function BatttleQuickItem:ctor()
    self:setContentSize(cc.size(BackPackItem.Width, BackPackItem.Height))
    self:setAnchorPoint(cc.p(0.5, 0.5))

    self.item = BackPackItem.new(false, true, false, 1, false, true)
    self.item:setPosition(BackPackItem.Width*0.5, BackPackItem.Height*0.5)
    self:addChild(self.item)

    self:registerEvent()
end

function BatttleQuickItem:registerEvent()

end

function BatttleQuickItem:setData(data)
    self.data = data
    if data then
        self.item:setBaseData(data.bid, data.num)
    end
end

function BatttleQuickItem:suspendAllActions()
end

function BatttleQuickItem:DeleteMe()
    if self.item then
        self.item:DeleteMe()
        self.item = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end

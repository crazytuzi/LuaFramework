-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      掉落信息总览面板
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
BattlDramaDropWindow = BattlDramaDropWindow or BaseClass(BaseView)

local controller = BattleDramaController:getInstance()

function BattlDramaDropWindow:__init()
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "battledrama/battle_drama_drop_windows"
    self.panel_list = {}
    self.tab_list = {}
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("battledrop", "battledrop"), type = ResourcesType.plist},
    }
    self.tab_array = {
        {label = TI18N("Boss掉落"),index = 1},
        {label = TI18N('挂机掉落'),index = 2},
    }
    self.cur_tab = nil
    self.cur_index = nil
end
function BattlDramaDropWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("root")
    self:playEnterAnimatianByObj(self.main_container, 2)
    self.close_btn = self.main_container:getChildByName("close_btn")
    self.back_container = self.main_container:getChildByName("back_container")

    self.world_btn = self.main_container:getChildByName("world_btn")
    self.world_btn:setVisible(false)

    self.tableContainer = self.main_container:getChildByName('tab_container')
    local tab_btn = nil
    local type, label = nil, nil
    for i = 1, #self.tab_array do
        tab_btn = self.tableContainer:getChildByName(string.format('tab_btn_%s', i))
        tab_btn.select_bg = tab_btn:getChildByName('select_bg')
        tab_btn.select_bg:setVisible(false)
        tab_btn.unselect_bg = tab_btn:getChildByName('unselect_bg')
        tab_btn.label = tab_btn:getChildByName('title')
        tab_btn:setBright(false)
        tab_btn.label:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff))
        type = self.tab_array[i].index
        label = self.tab_array[i].label
        tab_btn.type = type
        tab_btn.label:setString(label)
        self.tab_list[type] = tab_btn
    end
    self:updateSwapNum()
end

function BattlDramaDropWindow:register_event()
    if self.background then
        self.background:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                controller:openDramDropWindows(false) 
            end
        end)
    end
    if self.world_btn then
        self.world_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                WorldmapController:getInstance():openWorldMapMainWindow(true)
            end
        end)
    end
    if self.close_btn then
        self.close_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                controller:openDramDropWindows(false) 
            end
        end)
    end
    -- if self.add_btn then
    --     self.add_btn:addTouchEventListener(function (sender,event_type)
    --         if event_type == ccui.TouchEventType.ended then
    --             playButtonSound2()
    --             local config = Config.ItemData.data_get_data(Config.DungeonData.data_drama_const['swap_item'].val)
    --             if config then
    --                 BackpackController:getInstance():openTipsSource(true, config)
    --             end
    --         end
    --     end)
    -- end
    if self.tab_list then
        for k, tab_btn in pairs(self.tab_list) do
            tab_btn:addTouchEventListener(function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    playTabButtonSound()
                    if tab_btn.type ~= nil then
                        self:changeTabView(tab_btn.type)
                    end
                end
            end)
        end
    end
    if not self.update_dram_boss_data_event then
        self.update_dram_boss_data_event = GlobalEvent:getInstance():Bind(Battle_dramaEvent.BattleDrama_Boss_Update_Data, function()
            local num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(Config.DungeonData.data_drama_const["swap_item"].val)
            -- self.num_label:setString(num)
            self:updateSwapNum()
        end)
    end
    if not self.update_dram_boss_swap_event then
        self.update_dram_boss_swap_event = GlobalEvent:getInstance():Bind(Battle_dramaEvent.BattleDrama_Quick_Battle_Data, function()
            self:updateSwapNum()
        end)
    end
    
    -- if not self.add_goods_event then
    --     self.add_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS, function(bag_code, data_list)
    --         if bag_code == BackPackConst.Bag_Code.BACKPACK then
    --             for i, v in pairs(data_list) do
    --                 if v and v.base_id and v.base_id == Config.DungeonData.data_drama_const["swap_item"].val then
    --                    local num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(Config.DungeonData.data_drama_const['swap_item'].val)
    --                     self.num_label:setString(num)
    --                 end
    --             end
    --         end
    --     end)
    -- end
    -- if not self.modify_add_event then
    --     self.modify_add_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code, data_list)
    --          if bag_code == BackPackConst.Bag_Code.BACKPACK then
    --             for i, v in pairs(data_list) do
    --                 if v and v.base_id and v.base_id == Config.DungeonData.data_drama_const["swap_item"].val then
    --                    local num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(Config.DungeonData.data_drama_const['swap_item'].val)
    --                     self.num_label:setString(num)
    --                 end
    --             end
    --         end
    --     end)
    -- end
    
end


function BattlDramaDropWindow:updateSwapNum()
    -- local drama_data = BattleDramaController:getInstance():getModel():getDramaData()
    -- if drama_data then
    --     local str = string.format('<div fontColor=#764519>今天剩余扫荡次数: </div><div fontColor=#289b14>%s</div>', Config.DungeonData.data_drama_const["swap_time"].val- drama_data.auto_num)
    --     self.swap_desc_label:setString(str)
    -- end
end
function BattlDramaDropWindow:openRootWnd(max_dun_id,index)
    self.max_dun_id = max_dun_id
    index = index or 1
    self:changeTabView(index)
end

function BattlDramaDropWindow:changeTabView(index)
    if self.cur_index and self.cur_index == index then
        return
    end
    if self.cur_tab ~= nil then
        if self.cur_tab.label then
            self.cur_tab.label:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff))
        end
        self.cur_tab.select_bg:setVisible(false)
    end
    self.cur_tab = self.tab_list[index]
    if self.cur_tab ~= nil then
        if self.cur_tab.label then
            self.cur_tab.label:setTextColor(cc.c4b(0xff, 0xed, 0xd6, 0xff))
        end
        self.cur_tab.select_bg:setVisible(true)
    end
  
    if self.cur_panel ~= nil then
		self.cur_panel:setVisibleStatus(false)
		self.cur_panel = nil
	end
	local cur_panel = self.panel_list[index]
	if cur_panel == nil then
        if index == BattleShowRewardConst.Boss then
            cur_panel = BattleDramaDropBossTipsWindow.new(self.max_dun_id)
        elseif index == BattleShowRewardConst.Hook then
            cur_panel = BattlDramaDropTipsWindow.new(self.max_dun_id)
        end
		self.panel_list[index] = cur_panel
		if cur_panel ~= nil then
			self.main_container:addChild(cur_panel)
		end
	end

	if cur_panel ~= nil then
		cur_panel:setVisibleStatus(true) 
		self.cur_panel = cur_panel
		self.cur_index = index
    end
end

function BattlDramaDropWindow:close_callback()
    if self.item_list and next(self.item_list or {}) ~= nil then
        for i,v in ipairs(self.item_list) do
            if v then
                v:DeleteMe()
                v = nil
            end
        end
    end
    if self.modify_add_event then
        GlobalEvent:getInstance():UnBind(self.modify_add_event)
        self.modify_add_event = nil
    end
    if self.update_dram_boss_data_event then
        GlobalEvent:getInstance():UnBind(self.update_dram_boss_data_event)
        self.update_dram_boss_data_event = nil
    end
    if self.add_goods_event then
        GlobalEvent:getInstance():UnBind(self.add_goods_event)
        self.add_goods_event = nil
    end
    if self.update_dram_boss_swap_event then
        GlobalEvent:getInstance():UnBind(self.update_dram_boss_swap_event)
        self.update_dram_boss_swap_event = nil
    end
    if self.panel_list and next(self.panel_list or {}) ~= nil then
        for i, panel in pairs(self.panel_list) do
            if panel then
                panel:DeleteMe()
            end
        end
    end
    self.panel_list = {}
    self.item_list = {}
    controller:openDramDropWindows(false)
end
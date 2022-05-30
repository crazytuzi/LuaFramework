-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      剧情副本通关奖励
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
BattleDramaRewardWindow = BattleDramaRewardWindow or BaseClass(BaseView)

local controller = BattleDramaController:getInstance() 
local model = BattleDramaController:getInstance():getModel()
local string_format = string.format
local table_sort = table.sort
local table_insert = table.insert

function BattleDramaRewardWindow:__init(dun_id)
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.dun_id = dun_id
    self.layout_name = "battledrama/battle_drama_reward_window"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_61"), type = ResourcesType.single },
        {path = PathTool.getPlistImgForDownLoad("battledrop", "battledrop"), type = ResourcesType.plist},
    }
    self.item_list = {}
end
function BattleDramaRewardWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    self.container = container
    self:playEnterAnimatianByObj(self.container, 2)
    container:getChildByName("win_title"):setString(TI18N("奖励总览"))

    self.panel_bg = self.container:getChildByName("panel_bg")
    
    if not self.item_load then
        local res =  PathTool.getTargetRes("bigbg","bigbg_61", false, false)
        self.item_load = loadSpriteTextureFromCDN(self.panel_bg, res, ResourcesType.single, self.item_load)
    end

    -- self.close_btn = container:getChildByName("close_btn")
    self.no_vedio_image = container:getChildByName("no_vedio_image")
    self.no_vedio_label = container:getChildByName("no_vedio_label")
    self.list_panel = container:getChildByName("list_panel")

    local bgSize = self.list_panel:getContentSize()
    local scroll_view_size = cc.size(bgSize.width, bgSize.height-8)
    local setting = {
        item_class = BattlDramaRewardItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 8,                   -- y方向的间隔
        item_width = 614,               -- 单元的尺寸width
        item_height = 137,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        delay = 6,
        need_dynamic = true
    }

    self.item_scrollview = CommonScrollViewLayout.new(self.list_panel, cc.p(0,5) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
end

function BattleDramaRewardWindow:register_event()
    -- registerButtonEventListener(self.close_btn, handler(self, self._onClickBtnClose) ,false, 2)
    -- registerButtonEventListener(self.close_btn, function() controller:openDramRewardView(false) end ,false, 2)
    registerButtonEventListener(self.background, function() controller:openDramRewardView(false) end ,false, 2)
   
    if not self.update_dram_data_event then
        self.update_dram_data_event = GlobalEvent:getInstance():Bind(Battle_dramaEvent.BattleDrama_Update_Data, function(data)
            self:updateData()
        end)
    end
end

function BattleDramaRewardWindow:openRootWnd()
    --已领取信息
    self.dic_drama_reward_ids = model:getDicDramaRewardID()
    self:updateData()
end

function BattleDramaRewardWindow:updateData()
    self.cur_dun = 0
    self.max_dun_id = 0
    local drama_data = model:getDramaData()
    if drama_data then
        self.max_dun_id = drama_data.max_dun_id
        local cur_drama_dungeon_info = Config.DungeonData.data_drama_dungeon_info(drama_data.max_dun_id)
        if cur_drama_dungeon_info then
            self.cur_dun = cur_drama_dungeon_info.floor or 0
        end
    end

    if self.reward_list == nil then
        self.reward_list = {}
    end

    local list = Config.DungeonData.data_drama_reward
    for i,v in ipairs(list) do
        if self.reward_list[i] == nil then
            self.reward_list[i] = {}
        end
        self.reward_list[i].config_data = v
        self.reward_list[i].is_received = self.dic_drama_reward_ids[v.id] or false
        self.reward_list[i].cur_dun = self.cur_dun

        if self.max_dun_id >= v.limit_id then
            if self.reward_list[i].is_received then
                self.reward_list[i].sort_index = 3 --已领取
            else
                self.reward_list[i].sort_index = 1 --可领取
            end
        else
            self.reward_list[i].sort_index = 2   -- 前往 条件未满足
        end
    end
    --排序 
    table_sort(self.reward_list, function(a, b) 
        if a.sort_index == b.sort_index then
            return a.config_data.id < b.config_data.id
        else
            return a.sort_index < b.sort_index 
        end
    end)

    if next(self.reward_list) ~= nil then
        self.item_scrollview:setData(self.reward_list)
        self.no_vedio_image:setVisible(false)
        self.no_vedio_label:setVisible(false)
    else
        self.no_vedio_image:setVisible(true)
        self.no_vedio_label:setVisible(true)
    end
    
end

--更新根据id
function BattleDramaRewardWindow:udpateDataByID(id)
    if self.reward_list then
        for i,v in ipairs(self.reward_list) do
            if v.config_data.id == id then
                v.is_received = true
                v.sort_index = 3
            end
        end
        table_sort(self.reward_list, function(a, b) 
            if a.sort_index == b.sort_index then
                return a.config_data.id < b.config_data.id
            else
                return a.sort_index < b.sort_index 
            end
        end)
        self.item_scrollview:setData(self.reward_list)
        self.dic_drama_reward_ids[id] = true
    end
    
end

function BattleDramaRewardWindow:close_callback()
    if self.item_load then
        self.item_load:DeleteMe()
        self.item_load = nil
    end

    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end

    if self.update_dram_data_event then
        GlobalEvent:getInstance():UnBind(self.update_dram_data_event)
        self.update_dram_data_event = nil
    end
    controller:openDramRewardView(false)
end



BattlDramaRewardItem = class("BattlDramaRewardItem", function()
    return ccui.Widget:create()
end)

function BattlDramaRewardItem:ctor()
    self.ctrl = GuildwarController:getInstance()
    self.item_list = {}

    self:configUI()
    self:register_event()
    self.item_width = 90
end

function BattlDramaRewardItem:configUI(  )
    self.size = cc.size(614,137)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("battledrama/battle_drama_reward_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("root")
    self.name_label = self.container:getChildByName("name_label")
    
    self.img_received = self.container:getChildByName("img_received")

    self.comfirm_btn = self.container:getChildByName("comfirm_btn")
    local btn_size = self.comfirm_btn:getContentSize()
    self.comfirm_btn_label = createRichLabel(20, 1, cc.p(0.5, 0.5), cc.p(btn_size.width/2, btn_size.height/2))
    self.comfirm_btn:addChild(self.comfirm_btn_label)
    -- self.comfirm_btn:getChildByName("label")
    self.item_scrollview = self.container:getChildByName("item_scrollview")
    self.item_scrollview:setScrollBarEnabled(false)
    self.item_scrollview:setSwallowTouches(false)
    self.item_scrollview_size = self.item_scrollview:getContentSize()
    --item 对象
    self.item_list = {}

    self.img_received:setVisible(false)
end

function BattlDramaRewardItem:register_event(  )
    registerButtonEventListener(self.comfirm_btn, handler(self, self._onComfirmBtn) ,true, 2)
end

function BattlDramaRewardItem:_onComfirmBtn()
    if self.data then
        local drama_dungeon_info = Config.DungeonData.data_drama_dungeon_info(self.data.config_data.limit_id)
            --按钮显示
        if self.data.cur_dun  >= drama_dungeon_info.floor then
            if not self.data.is_received then
                controller:send13009(self.data.config_data.id)
            else
                -- message(TI18N("奖励已领取"))
            end
        else 
            controller:openDramRewardView(false)
        end
    end
end

--config_data 是表 Config.DungeonData.data_drama_reward的数据
function BattlDramaRewardItem:setData(data)
    self.data = data
    local config_data = data.config_data
    --名字
    local drama_dungeon_info = Config.DungeonData.data_drama_dungeon_info(config_data.limit_id)
    local cur_dun = data.cur_dun 
    if cur_dun > drama_dungeon_info.floor then
        cur_dun = drama_dungeon_info.floor
    end
    local str = string_format(TI18N("%s%s关(%s/%s)"), TI18N("通关"), drama_dungeon_info.floor, data.cur_dun, drama_dungeon_info.floor)
    self.name_label:setString(str)

    -- 引导需要
    if config_data then
        self.comfirm_btn:setTag(config_data.limit_id)
    end

    local is_received = data.is_received 
    --按钮显示
    if cur_dun >= drama_dungeon_info.floor then
        if is_received then
            self.img_received:setVisible(true)
            self.comfirm_btn:setVisible(false)
        else
            self.img_received:setVisible(false)
            self.comfirm_btn:setVisible(true)
            self.comfirm_btn:loadTexture(PathTool.getResFrame("common", "common_1017"), LOADTEXT_TYPE_PLIST)
            self.comfirm_btn_label:setString(TI18N("<div fontcolor=#ffffff shadow=0,-2,2,#0E73B3>领取</div>"))
    	    -- self.comfirm_btn_label:enableOutline(cc.c4b(0x76,0x45,0x19,0xff), 2)
        end
    else 
        --前往
        self.img_received:setVisible(false)
        self.comfirm_btn:setVisible(true)
        self.comfirm_btn:loadTexture(PathTool.getResFrame("common", "common_1018"), LOADTEXT_TYPE_PLIST)
        self.comfirm_btn_label:setString(TI18N("<div fontcolor=#ffffff shadow=0,-2,2,#854000>前往</div>"))
    	-- self.comfirm_btn_label:enableOutline(cc.c4b(0x29,0x4a,0x15,0xff), 2)
    end
    
    if self.item_list then
        for i,v in ipairs(self.item_list) do
            v:setVisible(false)
        end
    end
    --道具列表
    local scale = 0.75
    local offsetX = 10
    local item_count = #config_data.items
    local item_width = BackPackItem.Width * scale

    local total_width =  (item_width + offsetX) * item_count
    local max_width = math.max(self.item_scrollview_size.width, total_width)
    self.item_scrollview:setInnerContainerSize(cc.size(max_width, self.item_scrollview_size.height))

    self.start_x = offsetX * 0.5
    local item = nil
    local size = #config_data.items
    for i, v in ipairs(config_data.items) do
        item = self.item_list[i]
        if item then
            item:setVisible(true)
            local _x = self.start_x + (i - 1) * (item_width + offsetX) + 8
            item:setPosition(_x, self.item_scrollview_size.height * 0.5)
            item:setBaseData(v[1], v[2], true)
            item:setDefaultTip()
        else
            local dealey = i - size
            if dealey <= 0 then
                dealey = 1
            end
            delayRun(self.item_scrollview,dealey / display.DEFAULT_FPS,function ()
                if not self.item_list[i] then
                    item = BackPackItem.new(true, true)
                    item:setAnchorPoint(0, 0.5)
                    item:setScale(scale)
                    item:setSwallowTouches(false)
                    self.item_scrollview:addChild(item)
                    self.item_list[i] = item
                    local _x = self.start_x + (i - 1) * (item_width + offsetX) + 8
                    item:setPosition(_x, self.item_scrollview_size.height * 0.5)
                    item:setBaseData(v[1], v[2], true)
                    item:setDefaultTip()
                end
            end)
        end
    end
end

function BattlDramaRewardItem:DeleteMe(  )
    doStopAllActions(self.container)
    if self.item_list then
        for k,v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end
end
--------------------------------------------
-- @Author  : lwc
-- @Editor  : lwc
-- @Date    : 2018-10-15 20:35:23
-- @description    : 
        -- 星河神殿 挑战记录
---------------------------------
PrimusChallengeRecordPanel = PrimusChallengeRecordPanel or BaseClass(BaseView)

local controller = PrimusController:getInstance()
local model = controller:getModel()

function PrimusChallengeRecordPanel:__init(  )
    self.win_type = WinType.Mini
    self.is_full_screen = false
    self.res_list = {
        -- {path = PathTool.getPlistImgForDownLoad("guildwar", "guildwar"), type = ResourcesType.plist},
        -- {path = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_3"), type = ResourcesType.single }
    }
    self.layout_name = "primus/primus_challenge_record_panel"
end

function PrimusChallengeRecordPanel:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    self.container = container
    self:playEnterAnimatianByObj(self.container , 1)

    local win_title = container:getChildByName("win_title")
    win_title:setString(TI18N("挑战记录"))

    -- local title_label_1 = container:getChildByName("title_label_1")
    -- title_label_1:setString(TI18N("据点防守阵容"))

    self.close_btn = container:getChildByName("close_btn")
    self.no_vedio_image = container:getChildByName("no_vedio_image")
    self.no_vedio_label = container:getChildByName("no_vedio_label")
    self.time_label = container:getChildByName("time_label")
    self.list_panel = container:getChildByName("list_panel")

    -- local time_str = Config.GuildWarData.data_const.time_desc.desc or ""
    -- self.time_label:setString(time_str)

    local bgSize = self.list_panel:getContentSize()
    local scroll_view_size = cc.size(bgSize.width, bgSize.height-8)
    local setting = {
        item_class = PrimusChallengeRecordItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 616,               -- 单元的尺寸width
        item_height = 218,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        delay = 6
    }

    self.item_scrollview = CommonScrollViewLayout.new(self.list_panel, cc.p(0,5) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
end

function PrimusChallengeRecordPanel:register_event(  )
    self.background:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            controller:openPrimusChallengeRecordPanel(false)
        end
    end) 

    self.close_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            controller:openPrimusChallengeRecordPanel(false)
        end
    end) 

end

function PrimusChallengeRecordPanel:setData( data )
    data = data or {}
    -- 防守列表
    if data.list and next(data.list) ~= nil then
        self.item_scrollview:setData(data.list)
        self.no_vedio_image:setVisible(false)
        self.no_vedio_label:setVisible(false)
    else
        self.no_vedio_image:setVisible(true)
        self.no_vedio_label:setVisible(true)
    end
        
end

function PrimusChallengeRecordPanel:openRootWnd(data, g_id, g_sid, pos )
    --申请记录
    -- controller:requestPositionDefendData(g_id, g_sid, pos)
    self:setData(data)
end

function PrimusChallengeRecordPanel:close_callback(  )
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end

    if self.enemy_battle_array_panel then
        self.enemy_battle_array_panel:DeleteMe()
        self.enemy_battle_array_panel = nil
    end

    controller:openPrimusChallengeRecordPanel(false)
end

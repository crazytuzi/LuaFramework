-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      无尽试炼排行榜主界面
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
EndlessRankWindow = EndlessRankWindow or BaseClass(BaseView)

local controller = Endless_trailController:getInstance()
local model = Endless_trailController:getInstance():getModel()
local string_format = string.format

function EndlessRankWindow:__init(type)
    --self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Full
    self.endless_type = type
    self.is_full_screen = true
    self.title_str = TI18N("无尽试炼排行榜")

    --self.layout_name = "endlesstrail/endlesstrail_rank_window"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_3"), type = ResourcesType.single}
    }

    self.tab_info_list = {
        {label = TI18N("排行榜"), index = Endless_trailEvent.type.rank , status = true},
        {label = TI18N("奖励一览"),index = Endless_trailEvent.type.reward, status = true},
    }
    self.selected_tab = nil -- 当前选中的标签
    self.tab_list = {}
    self.panel_list = {}
end

function EndlessRankWindow:open_callback()
    -- self.background = self.root_wnd:getChildByName("background")
    -- if self.background ~= nil then
    --     self.background:setScale(display.getMaxScale())
    -- end

    -- self.root_csb = self.root_wnd:getChildByName("main_container")
    -- self.main_panel = self.root_csb:getChildByName("main_panel")
    -- self.main_view = self.main_panel:getChildByName("container")
    -- self.close_btn = self.main_panel:getChildByName("close_btn")
    -- self.win_title = self.main_panel:getChildByName("win_title")
    -- self.win_title:setString(TI18N("无尽试炼排行榜"))

    -- local tab_container = self.main_view:getChildByName("tab_container")
    -- for i = 1, 2 do
    --     local tab_btn = tab_container:getChildByName("tab_btn_" .. i)
    --     if tab_btn then
    --         local title = tab_btn:getChildByName("title")
    --         if i == 1 then
    --             title:setString(TI18N("排行榜"))
    --         elseif i == 2 then
    --             title:setString(TI18N("奖励一览"))
    --         end
    --         title:setTextColor(cc.c4b(0xf5, 0xe0, 0xb9, 0xff))

    --         tab_btn:setBright(false)
    --         tab_btn.index = i
    --         tab_btn.label = title
    --         self.tab_list[i] = tab_btn
    --     end
    -- end
    -- self.scroll_container = self.main_view:getChildByName("scroll_container")
end

function EndlessRankWindow:register_event()
    for k, tab_btn in pairs(self.tab_list) do
        tab_btn:addTouchEventListener(
            function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    playTabButtonSound()
                    self:changeSelectedTab(sender.index)
                end
            end
        )
    end
    if self.background then
        self.background:addTouchEventListener(
            function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    playTabButtonSound()
                    controller:openEndlessRankView(false) 
                end
            end
        )
    end
    if self.close_btn then
        self.close_btn:addTouchEventListener(
            function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    playTabButtonSound()
                    controller:openEndlessRankView(false) 
                end
            end
        )
    end
end

function EndlessRankWindow:openRootWnd(type)
    type = type or Endless_trailEvent.type.rank
    self:setSelecteTab(type)
end

function EndlessRankWindow:selectedTabCallBack(index)
    self:changeSelectedTab(index)
end
--==============================--
--desc:切换标签页
--time:2018-06-12 10:51:51
--@index:
--@return
--==============================--
function EndlessRankWindow:changeSelectedTab(index)
    if self.selected_tab ~= nil then
        if self.selected_tab.index == index then
            return
        end
    end
    if self.selected_tab then
        self.selected_tab.label:setTextColor(cc.c4b(0xf5, 0xe0, 0xb9, 0xff))
        self.selected_tab:setBright(false)
        self.selected_tab = nil
    end
    self.selected_tab = self.tab_list[index]
    if self.selected_tab then
        self.selected_tab.label:setTextColor(cc.c4b(0x59, 0x34, 0x29, 0xff))
        self.selected_tab:setBright(true)
    end
    if self.cur_panel ~= nil then
        self.cur_panel:setNodeVisible(false)
        self.cur_panel = nil
    end

    self.cur_panel = self.panel_list[index]
    if self.cur_panel == nil then
        if index == Endless_trailEvent.type.rank then
            self.cur_panel = EndlessRankPanel.new(self.endless_type)
        elseif index ==  Endless_trailEvent.type.reward then
            self.cur_panel = EndlessAwardsPanel.new(self.endless_type)
        end
        self.panel_list[index] = self.cur_panel
        self.container:addChild(self.cur_panel)
        if self.cur_panel.addToParent then
            self.cur_panel:addToParent()
        end

    end
    self.cur_panel:setNodeVisible(true)
end

function EndlessRankWindow:close_callback()
    controller:openEndlessRankView(false)

    for k, panel in pairs(self.panel_list) do
        panel:DeleteMe()
    end
    self.panel_list = {}
end

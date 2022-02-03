-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      公会副本排行榜
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildBossRankWindow = GuildBossRankWindow or BaseClass(BaseView)

local controller = GuildbossController:getInstance()
local model = GuildbossController:getInstance():getModel()
local string_format = string.format

function GuildBossRankWindow:__init()
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.win_type = WinType.Big

	self.is_full_screen = false
    self.layout_name = "guildboss/guildboss_rank_window"
    self.selected_tab = nil         -- 当前选中的标签
    self.tab_list = {}
    self.panel_list = {}

    self.res_list = {
    }
end

function GuildBossRankWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local main_container  = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container, 1)
    local main_panel  = main_container:getChildByName("main_panel")

    main_panel:getChildByName("win_title"):setString(TI18N("排行奖励"))
    main_panel:getChildByName("award_title"):setString(TI18N("奖励")) 
    main_panel:getChildByName("rank_title"):setString(TI18N("排名")) 
    main_panel:getChildByName("win_title"):setString(TI18N("排行奖励")) 
    main_panel:getChildByName("rewards_notice"):setString(TI18N("奖励在结算完成后通过邮件发放"))
    main_panel:getChildByName("close_notice"):setString(TI18N("点击黑色区域关闭窗口"))

    local scroll_view = main_panel:getChildByName("scroll_view")
    local size = scroll_view:getContentSize()
    local setting = {
        item_class = GuildBossRankItem,
        start_x = 0,
        space_x = 0,
        start_y = 0,
        space_y = 4,
        item_width = 596,
        item_height = 140,
        row = 0,
        col = 1,
        need_dynamic = true
    }
    self.scroll_view = CommonScrollViewLayout.new(scroll_view, nil, nil, nil, size, setting) 

    self.item = main_panel:getChildByName("item")
end

function GuildBossRankWindow:register_event()
    if self.background then
        self.background:addTouchEventListener(function (sender,event_type )
            if event_type == ccui.TouchEventType.ended then
                playTabButtonSound()
                controller:openGuildBossRankWindow(false) 
            end
        end)
    end
    if self.close_btn then
        self.close_btn:addTouchEventListener(function (sender,event_type )
            if event_type == ccui.TouchEventType.ended then
                playTabButtonSound()
                controller:openGuildBossRankWindow(false) 
            end
        end)
    end
end

function GuildBossRankWindow:openRootWnd(data)
    if data and data.config then
        local rewards_config = Config.GuildDunData.data_rank_reward[data.config.boss_id];
        if rewards_config then
            local temp_config = deepCopy(rewards_config)
            table.sort( temp_config, function(a, b) 
                return a.rank1 < b.rank1 
            end)
		    self.scroll_view:setData(temp_config, nil, nil, self.item)
        end
    end
end

function GuildBossRankWindow:close_callback()
	controller:openGuildBossRankWindow(false)
    if self.scroll_view then
        self.scroll_view:DeleteMe()
    end
    self.scroll_view = nil

    for k, panel in pairs(self.panel_list) do
        panel:DeleteMe()
    end
    self.panel_list = {}
end 


-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      联盟BOSS排行榜奖励
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildBossRankItem = class("GuildBossRankItem",function()
    return ccui.Layout:create()
end)

function GuildBossRankItem:ctor()
    self.item_list = {}
end

function GuildBossRankItem:setExtendData(node)
	if not tolua.isnull(node) and self.root_wnd == nil then
		local size = node:getContentSize()
		self:setAnchorPoint(cc.p(0.5, 0.5))
		self:setContentSize(size)

		self.root_wnd = node:clone()
		self.root_wnd:setVisible(true)
		self.root_wnd:setAnchorPoint(0.5, 0.5)
		self.root_wnd:setPosition(size.width * 0.5, size.height * 0.5) 
		self:addChild(self.root_wnd)

        self.rank_img = self.root_wnd:getChildByName("rank_img")
        self.rank_img:ignoreContentAdaptWithSize(true)
        self.rank_label = self.root_wnd:getChildByName("rank_label")
        self.item_container = self.root_wnd:getChildByName("item_container")
        self.total_width = self.item_container:getContentSize().width
    end
end

function GuildBossRankItem:setData(data)
    if data ~= nil then
        if data.rank2 <= 3 then
            self.rank_label:setVisible(false)
            if data.rank2 == 0 then
                self.rank_img:setVisible(false)
            else
                local res_id = PathTool.getResFrame("common", string.format("common_200%s", data.rank2))
                if self.rank_res_id ~= res_id then
                    self.rank_res_id = res_id
                    self.rank_img:loadTexture(res_id, LOADTEXT_TYPE_PLIST)
                end
                self.rank_img:setVisible(true)
            end
        else
            self.rank_img:setVisible(false)
            self.rank_label:setVisible(true)
            self.rank_label:setString(string.format("%s~%s", data.rank1, data.rank2))
        end 

        -- 先隐藏掉一些吧
        for k, item in pairs(self.item_list) do
            item:setVisible(false)
        end

        local item_config = nil
        local index = 1
        local item = nil
        local scale = 0.8
        local off = 10
        local _x, _y = 0, 55
        local sum = #data.award
        for i=sum,1,-1 do
            local v = data.award[i]
            item_config = Config.ItemData.data_get_data(v[1])
            if item_config then
                if self.item_list[index] == nil then
                    item = BackPackItem.new(false, true, false, scale, false, true) 
                    _x = self.total_width - ( (index-1)*(BackPackItem.Width*scale+off) + BackPackItem.Width*0.5*scale )
                    item:setPosition(_x, _y)
                    self.item_container:addChild(item)
                    self.item_list[index] = item
                end
                item = self.item_list[index]
                item:setBaseData(v[1],v[2])
                item:setVisible(true)
                index = index + 1
            end
        end
    end
end

function GuildBossRankItem:DeleteMe()
    for i,v in ipairs(self.item_list) do
        v:DeleteMe()
    end
    self.item_list = nil
    self:removeAllChildren()
    self:removeFromParent()
end

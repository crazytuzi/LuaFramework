-------------------------------------
-- @Author: zj@qqg.com
-- @Date:   2019-06-03 15:00:45
-- @Description: 公会公告面板
-------------------------------------
GuildNoticeWindow = GuildNoticeWindow or BaseClass(BaseView)

local controller = GuildController:getInstance()
local model = GuildController:getInstance():getModel()
local string_format = string.format
local table_insert = table.insert
local common_font_color = cc.c4b(0x64,0x32,0x23,0xff)

function GuildNoticeWindow:__init()
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.win_type = WinType.Big
	self.title_str = TI18N("公告列表")

    self.is_init = true
	self.cb_btn_list = {} --单选框列表
    self.notice_item_list = {} --日志列表
end

function GuildNoticeWindow:open_callback()
	self.main_view = createCSBNote(PathTool.getTargetCSB("guild/guild_notice_window"))
    self.main_view:setPositionY(self.main_view:getPositionY() + 10)
	self.container:addChild(self.main_view)

    self.background = self.main_view:getChildByName("background")

    self.img_day_bg = self.main_view:getChildByName("img_day_bg")
    self.txt_cur_day = self.main_view:getChildByName("txt_cur_day")
    self.txt_cur_day:setString("")

    self.btn_check_detail = self.main_view:getChildByName("btn_check_detail")
    self.btn_check_detail:getChildByName("name"):setString(TI18N("查看详情"))

    self.empty_tips = self.main_view:getChildByName("empty_tips")
    self.empty_tips:getChildByName("desc"):setString(TI18N("暂无新的消息"))

    local btn_name = {
    	[1] = TI18N("公会战情况"),
    	[2] = TI18N("公会捐献情况"),
    	[3] = TI18N("公会副本情况"),
	}
	for i=1,3 do
		local btn = self.main_view:getChildByName("btn_guild_"..i)
	    btn:getChildByName("name"):setString(btn_name[i])
	    btn.index = i
	    self.cb_btn_list[i] = btn
	end

    local background_size = self.background:getContentSize()
    self.list_size = cc.size(background_size.width, background_size.height - 10)
    self.scroll_view = createScrollView(self.list_size.width, self.list_size.height, 0, 5, self.background, ccui.ScrollViewDir.vertical)
    self.scroll_container = self.scroll_view:getInnerContainer() 
end

function GuildNoticeWindow:register_event()
    if self.update_notice_event == nil then
        self.update_notice_event = GlobalEvent:getInstance():Bind(GuildEvent.UpdateGuildNoticeList, function()
            self:updateNoticeList()
        end)
    end
    registerButtonEventListener(self.btn_check_detail, function()
        controller:openGuildMemberWindow(true, self.cur_index)
    end, true, 1, {}, 0.8)

    for k,btn in ipairs(self.cb_btn_list) do
    	btn:addEventListener(function ( sender,event_type )
            local status = true
	        if event_type == ccui.CheckBoxEventType.selected then
	            btn:setSelected(true)
	            self:updateNoticeList(btn.index)
	        elseif event_type == ccui.CheckBoxEventType.unselected then 
	            playButtonSound2()
                status = false
	            btn:setSelected(false)
                self:updateNoticeList()
	        end
            self:updateBtnStatus(btn.index, status)
	    end)
   	end
end

function GuildNoticeWindow:openRootWnd()
    controller:send13577()

    self:updateBtnStatus() --初始化选项框状态
    --公会日志红点恢复
    local status = model:getRedStatus(GuildConst.red_index.notice)
    if status then
        model:updateGuildRedStatus(GuildConst.red_index.notice, false)
    end
end

--刷新单选框状态
function GuildNoticeWindow:updateBtnStatus(index, status)
	local is_check_detail = false
	for k,btn in ipairs(self.cb_btn_list) do
		if not index then
			btn:setSelected(false)
		else
			if btn.index == index then
				is_check_detail = true
				btn:setSelected(status)
			else
				btn:setSelected(false)
			end
		end
	end
	if self.cur_index == GuildConst.show_type.all or not status then
		self.btn_check_detail:setVisible(false)
	else
		self.btn_check_detail:setVisible(is_check_detail)
	end
end

--刷新公告列表
function GuildNoticeWindow:updateNoticeList(index)
	self.cur_index = index or GuildConst.show_type.all
    local list = model:getGuildNoticeList(self.cur_index)
    
    local is_empty = false
    if next(list) == nil then
        is_empty = true
        self.txt_cur_day:setString(TimeTool.getMD3(tonumber(os.date())))
        if self.scroll_view then
            self.scroll_view:setVisible(false)
        end
    else
        self.txt_cur_day:setString("")
        if self.scroll_view then
            self.scroll_view:setVisible(true)
        end
    end
    self.img_day_bg:setVisible(is_empty)
    self.empty_tips:setVisible(is_empty)

    if self.notice_item_list and next(self.notice_item_list) ~= nil then
        for _,item in pairs(self.notice_item_list) do
            if item then
                item:setVisible(false)
            end
        end
        local con_size = cc.size(self.list_size.width, self.list_size.height)
        self.scroll_view:setInnerContainerSize(con_size)
        self.scroll_view:jumpToTop()
    end

    local height = 0
    local last_height = nil
    for i,v in ipairs(list) do
        delayRun(self.main_view, 0.02 * i,function ()
            local item = self.notice_item_list[i]
            if item == nil then
                item = GuildNoticeItem.new()
                self.scroll_container:addChild(item)
                self.notice_item_list[i] = item
            end
            item:setVisible(true)
            item:setData(v)
            height = height + item:getContentSize().height

            if not last_height then
                last_height = math.max(height, self.list_size.height)
            end
            last_height = last_height - item:getContentSize().height
            item:setPosition(cc.p(0, last_height))

            if height > self.list_size.height then
                self:adjustScrollViewSize(height)
            end
        end)
    end
end

function GuildNoticeWindow:adjustScrollViewSize(height)
    local max_height = math.max(height, self.list_size.height)
    local container_size = cc.size(self.list_size.width, max_height)
    self.scroll_view:setInnerContainerSize(container_size)

    if height >= self.list_size.height then
        self.scroll_view:setTouchEnabled(true)
    end

    local temp_height = max_height --顶部位置
    for _,item in pairs(self.notice_item_list) do
        if item then
            temp_height = temp_height - item:getContentSize().height
            item:setPosition(cc.p(0, temp_height))
        end
    end
end

function GuildNoticeWindow:close_callback()
    for k,v in pairs(self.notice_item_list) do
        v:DeleteMe()
        v = nil
    end
    if self.update_notice_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_notice_event)
        self.update_notice_event = nil
    end
    controller:openGuildNoticeWindow(false)
end

-- -------------------------------------------------------------------
-- @author: zj@qqg.com
-- @description: 公会公告子项
-- --------------------------------------------------------------------
GuildNoticeItem = class("GuildNoticeItem", function()
	return ccui.Layout:create()
end)

function GuildNoticeItem:ctor()
    self.size = cc.size(610, 200)
    self:setContentSize(self.size)

    self:layoutUI()
    self.is_init = true
    self.label_list = {} --文本数据列表
end

function GuildNoticeItem:layoutUI()
    self.container = ccui.Layout:create()
    self.container:setContentSize(self.size)
    self:addChild(self.container)

    self.img_time_bg = createImage(self.container, PathTool.getResFrame("common","common_90025"), 0, self.size.height, cc.p(0, 1), true, 1, true)
    self.img_time_bg:setContentSize(cc.size(self.size.width - 3, 44))

    self.day_label = createRichLabel(24, cc.c4b(0xff,0xf2,0xc7,0xff), cc.p(0, 0.5), cc.p(11, 22))
    self.day_label:setString("")
    self.img_time_bg:addChild(self.day_label)
end

function GuildNoticeItem:setData(data)
	self.data = data

    for k,list in pairs(self.label_list) do
        if list.item then
            list.item:setVisible(false)
        end
    end

    if data and next(data) ~= nil then
        local total_height = 50
        local line_space = 6
        for k,v in ipairs(data) do
            if self.is_init then
                self.is_init = false
                self.day_label:setString(TimeTool.getMD3(v.time))
            end
            local list = self.label_list[k]
            if not list then
                list = self:createOneNotice(v.time, v.role_name, v.msg)
                self.label_list[k] = list
            end
            if list.item then
                list.item:setVisible(true)
                list.time_label:setString(TimeTool.getHM(v.time))
                list.content_label:setString(string_format("<div fontcolor=#955322>%s</div> %s", v.role_name, v.msg))
                list.size = list.content_label:getContentSize().height

                total_height = total_height + list.size + line_space
            end
        end

        self.size = cc.size(610, total_height)
        self:setContentSize(self.size)
        self.container:setContentSize(self.size)
        self.container:setPosition(cc.p(3, 0))
        self.img_time_bg:setPosition(cc.p(0, self.size.height))

        local temp_height = 0
        for k,list in pairs(self.label_list) do
            if list.item and list.size then
                if k > 1 then
                    temp_height = temp_height + self.label_list[k-1].size + line_space
                end
                list.item:setPosition(cc.p(10, self.size.height - 50 - temp_height))
            end
        end
    end
end

function GuildNoticeItem:createOneNotice(time, name, content)
    local layout = ccui.Layout:create()
    local size = cc.size(560, 30)
    layout:setAnchorPoint(cc.p(0, 1))
    layout:setContentSize(size)
    self.container:addChild(layout)

    local time_label = createRichLabel(24, common_font_color, cc.p(0, 1), cc.p(10, size.height))
    time_label:setString(TimeTool.getHM(time))
    layout:addChild(time_label)

    local content_label = createRichLabel(24, common_font_color, cc.p(0, 1), cc.p(15 + time_label:getContentSize().width, size.height), 5, 0, 500)
    content_label:setString(string_format("<div fontcolor=#955322>%s</div> %s", name, content))
    layout:addChild(content_label)

    local list = {}
    list.item = layout
    list.time_label = time_label
    list.content_label = content_label
    list.size = content_label:getContentSize().height
    return list
end

function GuildNoticeItem:DeleteMe()
	self:removeAllChildren()
	self:removeFromParent()
end 
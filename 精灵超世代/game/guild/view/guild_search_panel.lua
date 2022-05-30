-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      公会查找面板
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildSearchPanel = class("GuildSearchPanel", function()
	return ccui.Layout:create()
end)

local controller = GuildController:getInstance()

function GuildSearchPanel:ctor(ctrl)
    self.panel_index = 1 -- 1:为搜索界面 2:为列表界面 3:为没有查找到界面

	self.root_wnd = createCSBNote(PathTool.getTargetCSB("guild/guild_search_panel"))
	self.size = self.root_wnd:getContentSize()
	self:setContentSize(self.size)
	
	self.root_wnd:setAnchorPoint(0.5, 0.5)
	self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
	self:addChild(self.root_wnd)

    self.background = self.root_wnd:getChildByName("background")
    self.background_width = self.background:getContentSize().width

    self.search_container = self.root_wnd:getChildByName("search_container")
    local desc = self.search_container:getChildByName("desc")
    desc:setString(TI18N("请输入完整公会名或关键词"))
    self.search_btn = self.search_container:getChildByName("search_btn")
    local label = self.search_btn:getChildByName("label")
    label:setString(TI18N("查找"))
    local res = PathTool.getResFrame("common", "common_99998")
    self.guild_value = createEditBox(self.search_container, res, cc.size(327, 50), 
    Config.ColorData.data_new_color4[16], 18, Config.ColorData.data_new_color4[26], 22,
    TI18N("请输入需要查找的内容"), nil, nil, LOADTEXT_TYPE_PLIST)
    self.guild_value:setAnchorPoint(cc.p(0.5, 0.5))
    -- self.guild_value:setPlaceholderFontColor(Config.ColorData.data_color4[151])
    self.guild_value:setFontColor(Config.ColorData.data_color4[151])
    self.guild_value:setPosition(cc.p(311, 113))
    self.guild_value:setMaxLength(20) 

    self.list_container = self.root_wnd:getChildByName("list_container")

    self.return_btn = self.list_container:getChildByName("return_btn")
    local label = self.return_btn:getChildByName("label")
    label:setString(TI18N("返回搜索")) 

    self.notice_container = self.root_wnd:getChildByName("notice_container")
    local desc = self.notice_container:getChildByName("desc")
    desc:setString(TI18N("抱歉，查找不到对应的公会，试试别的名字吧！")) 
    self.notice_btn = self.notice_container:getChildByName("notice_btn")
    local label = self.notice_btn:getChildByName("label")
    label:setString(TI18N("返回搜索")) 

    self:registerEvent()
end

function GuildSearchPanel:registerEvent()
    self.search_btn:addTouchEventListener(
        function(sender, event_type)
            customClickAction(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                local guild_name = self.guild_value:getText()
                if guild_name == "" then
                    message(TI18N("公会名字不得为空"))
                else
                    controller:requestGuildList(nil, nil, nil, guild_name) 
                end
            end
        end
    ) 
    self.return_btn:addTouchEventListener(              -- 列表界面的返回按钮
        function(sender, event_type)
            customClickAction(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                self:changeViewStatus(1)
            end
        end
    ) 
    self.notice_btn:addTouchEventListener(              -- 没有信息的返回按钮
        function(sender, event_type)
            customClickAction(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                self:changeViewStatus(1)
            end
        end
    ) 
    if self.update_guild_list_event == nil then
        self.update_guild_list_event = GlobalEvent:getInstance():Bind(GuildEvent.UpdateGuildList, function(type, list)
            if type ~= GuildConst.list_type.search then return end
            self:updateGuildList(list)
        end)
    end 
end

function GuildSearchPanel:addToParent(status)
	self:setVisible(status)
end

function GuildSearchPanel:changeViewStatus(index)
    if self.panel_index == index then return end
    -- 1:为搜索界面 2:为列表界面 3:为没有查找到界面
    self.panel_index = index
    self.search_container:setVisible(self.panel_index == 1) 
    self.list_container:setVisible(self.panel_index == 2)
    self.notice_container:setVisible(self.panel_index == 3)
    if self.panel_index == 1 then
        self.background:setContentSize(self.background_width, 780)
    else
        self.background:setContentSize(self.background_width, 702) 
    end
end

--==============================--
--desc:外部判断是不是在公会查找到的列表界面
--time:2018-06-03 10:09:41
--@return 
--==============================--
function GuildSearchPanel:checkIsInListStatus()
    return self.panel_index == 2
end

function GuildSearchPanel:changeToSearchListStatus()
    self:changeViewStatus(1)
end

function GuildSearchPanel:updateGuildList(list)
    if list == nil or next(list) == nil then
        self:changeViewStatus(3)
    else
        if self.scroll_view == nil then
            local size = self.list_container:getContentSize()
            local setting = {
            	item_class = GuildRequestItem,
            	start_x = 4,
            	space_x = 4,
            	start_y = 0,
            	space_y = - 3,
            	item_width = 616,
            	item_height = 134,
            	row = 0,
            	col = 1
            }
            self.scroll_view = CommonScrollViewLayout.new(self.list_container, nil, nil, nil, size, setting)
        end
        self.scroll_view:setData(list)
        self:changeViewStatus(2)
    end
end

function GuildSearchPanel:DeleteMe()
    if self.update_guild_list_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_guild_list_event)
        self.update_guild_list_event = nil
    end 
	if self.scroll_view then
		self.scroll_view:DeleteMe()
		self.scroll_view = nil
	end
end 
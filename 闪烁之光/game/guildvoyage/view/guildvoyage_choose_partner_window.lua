-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      选择伙伴界面
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildvoyageChoosePartnerWindow = GuildvoyageChoosePartnerWindow or BaseClass(BaseView)

local controller = GuildvoyageController:getInstance()
local model = controller:getModel()
local table_insert = table.insert

function GuildvoyageChoosePartnerWindow:__init(type)
	self.order_type = type
	self.win_type = WinType.Big
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.is_init = false
	self.res_list = {
	    {path = PathTool.getPlistImgForDownLoad("guildvoyage", "guildvoyage"), type = ResourcesType.plist}
	}
	self.layout_name = "guildvoyage/guildvoyage_choose_partner_window"
end 

function GuildvoyageChoosePartnerWindow:open_callback()
    local background = self.root_wnd:getChildByName("background")
    background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    container:getChildByName("win_title"):setString(TI18N("选择英雄"))

    self.close_btn = container:getChildByName("close_btn")

    self.item = container:getChildByName("item")

    self.list_view = container:getChildByName("list_view")
    local size = self.list_view:getContentSize()
    local setting = {
        item_class = GuildvoyageChoosePartnerItem,
        start_x = 4,
        space_x = 0,
        start_y = 2,
        space_y = -3.5,
        item_width = 555,
        item_height = 133,
        row = 0,
        col = 1,
        need_dynamic = true
    }
    self.scroll_view = CommonScrollViewLayout.new(self.list_view, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, size, setting, cc.p(0, 0)) 

    self.empty_tips = container:getChildByName("empty_tips")
	self.empty_tips:getChildByName("desc"):setString(TI18N("抱歉，没有可派遣的伙伴哦~"))
end

function GuildvoyageChoosePartnerWindow:register_event()
    self.close_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then 
            controller:openChoosePartnerWindow(false)
        end
    end)
end

function GuildvoyageChoosePartnerWindow:openRootWnd(partner_list)
    if partner_list then
        if #partner_list == 0 then
            self.empty_tips:setVisible(true)
            self.scroll_view:setVisible(false)
        else
            self.empty_tips:setVisible(false)
		    self.scroll_view:setData(partner_list, nil,nil, self.item)
            self.scroll_view:setVisible(true)
        end
    end
end

function GuildvoyageChoosePartnerWindow:close_callback()
    if self.scroll_view then
        self.scroll_view:DeleteMe()
        self.scroll_view = nil
    end
    controller:openChoosePartnerWindow(false)
end



-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      伙伴选择界面
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildvoyageChoosePartnerItem = class("GuildvoyageChoosePartnerItem", function()
	return ccui.Layout:create()
end)

function GuildvoyageChoosePartnerItem:ctor()
	self.item_list = {}
end

function GuildvoyageChoosePartnerItem:setExtendData(node)
	if not tolua.isnull(node) and self.root_wnd == nil then
		local size = node:getContentSize()
		self:setAnchorPoint(cc.p(0.5, 0.5))
		self:setContentSize(size)
		
		self.root_wnd = node:clone()
		self.root_wnd:setVisible(true)
		self.root_wnd:setAnchorPoint(0.5, 0.5)
		self.root_wnd:setPosition(size.width * 0.5, size.height * 0.5)
		self:addChild(self.root_wnd)

        self.bg_img = self.root_wnd:getChildByName("bg_img")
        self.career_img = self.root_wnd:getChildByName("career_img")
        self.career_name = self.root_wnd:getChildByName("career_name")
        self.partner_name = self.root_wnd:getChildByName("partner_name")
        self.partner_power = self.root_wnd:getChildByName("partner_power")
		
		self.handle_status = self.root_wnd:getChildByName("handle_status")
		self.handle_btn = self.root_wnd:getChildByName("handle_btn")
        self.handle_btn_label = self.handle_btn:getChildByName("label") 
		self.handle_btn_label:setString(TI18N("选择"))

        self.recommend = self.root_wnd:getChildByName("recommend")
		
        local item_container = self.root_wnd:getChildByName("item_container")
        self.item = HeroExhibitionItem.new(0.9, true) 
        self.item:setPosition(20, 20)
        item_container:addChild(self.item)
		
		self:setTouchEnabled(true)
		self:setSwallowTouches(false)
		self:registerEvent()
	end
end

function GuildvoyageChoosePartnerItem:registerEvent()
    self.handle_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then 
            playButtonSound2()
            if self.data ~= nil then
                if self.data.voyage_in_form == nil then
                    self.data.voyage_in_form = false
                end
                self.data.voyage_in_form = not self.data.voyage_in_form
                -- 只有取消上阵才做更新吧,因为不关闭面板
                if self.data.voyage_in_form == false then
                    self:changeInFormStatus()
                end

                GlobalEvent:getInstance():Fire(GuildvoyageEvent.AddToOrderPartnerListEvent, self.data)
            end
        end
    end)
end

function GuildvoyageChoosePartnerItem:setData(data)
    if data ~= nil then
        self.data = data
        local career_res = PathTool.getCareerIcon(data.type)
        if self.career_res ~= career_res then
            self.career_res = career_res
            self.career_img:loadTexture(career_res, LOADTEXT_TYPE_PLIST) 
        end
        self.partner_power:setString(data.power)
        self.recommend:setVisible(data.voyage_recommend == TRUE)
        self.career_name:setString("["..(PartnerConst.Hero_Type[data.type] or "").."]" )
        self.partner_name:setString(data.name)
        self.partner_name:setPositionX(self.career_name:getPositionX() + self.career_name:getContentSize().width)
        self.item:setData(data)
        self:changeInFormStatus()
    end
end

--==============================--
--desc:设置上下阵的状态,状态不一样,显示样子不一样
--time:2018-07-03 07:51:42
--@return 
--==============================--
function GuildvoyageChoosePartnerItem:changeInFormStatus()
    if self.data == nil then return end
    if self.data.voyage_in_form == true then
        self.bg_img:loadTexture(PathTool.getResFrame("common","common_1020"), LOADTEXT_TYPE_PLIST) 
        self.handle_btn:loadTexture(PathTool.getResFrame("common","common_1017"), LOADTEXT_TYPE_PLIST) 
        self.handle_btn_label:enableOutline(Config.ColorData.data_color4[157], 1) 
        self.handle_btn_label:setString(TI18N("下阵"))
    else
        self.bg_img:loadTexture(PathTool.getResFrame("common","common_1029"), LOADTEXT_TYPE_PLIST) 
        self.handle_btn:loadTexture(PathTool.getResFrame("common","common_1018"), LOADTEXT_TYPE_PLIST) 
        self.handle_btn_label:enableOutline(Config.ColorData.data_color4[167], 1) 
        self.handle_btn_label:setString(TI18N("选择"))
    end
end

function GuildvoyageChoosePartnerItem:DeleteMe()
    if self.item then
        self.item:DeleteMe()
        self.item = nil
    end
	self:removeAllChildren()
	self:removeFromParent()
end 
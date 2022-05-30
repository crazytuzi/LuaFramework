-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--     奖励一览界面
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
GuildBossRewardShowView = GuildBossRewardShowView or BaseClass(BaseView)

local controller = GuildbossController:getInstance()
local model = GuildbossController:getInstance():getModel()
function GuildBossRewardShowView:__init( ... )
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big
    self.title_str = TI18N("奖励一览")
    self.layout_name = "guildboss/guildboss_reward_show_view"
    self.is_full_screen = false
    self.selected_tab = nil -- 当前选中的标签
    self.tab_list = {}
    self.panel_list = {}
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("guildboss", "guildboss"), type = ResourcesType.plist}
    }
end

function GuildBossRewardShowView:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.root_csb = self.root_wnd:getChildByName("main_container")
    self.main_panel = self.root_csb:getChildByName("main_panel")
    self:playEnterAnimatianByObj(self.main_panel, 1)
    self.close_btn = self.main_panel:getChildByName("close_btn")
    local bg = createScale9Sprite(PathTool.getResFrame("common","common_1034"),self.main_panel:getContentSize().width/2,440)
    bg:setContentSize(cc.size(608,642))
    bg:setAnchorPoint(cc.p(0.5,0.5))
    self.main_panel:addChild(bg)
    local title_bg = createScale9Sprite(PathTool.getResFrame("common","common_1070"),338,730)
    title_bg:setContentSize(cc.size(600,57))
    self.main_panel:addChild(title_bg)
    local title_line = createSprite(PathTool.getResFrame("common","common_1069"),225,30,title_bg,cc.p(0.5,0.5))
    local title_name_1 = createLabel(24, 175,nil,100,30,TI18N("通关章节"),title_bg,nil,cc.p(0.5,0.5))
    local title_name_2 = createLabel(24, 175, nil, 410, 30, TI18N("对应结算奖励"), title_bg, nil, cc.p(0.5, 0.5))
    self.desc_label = createRichLabel(22, 175,cc.p(0,0.5),cc.p(35,100), nil, nil,1000)
    self.main_panel:addChild(self.desc_label)

    self.desc_label_2 = createRichLabel(22, 175, cc.p(0, 0.5), cc.p(35, 65), nil, nil, 1000)
    self.main_panel:addChild(self.desc_label_2)
    self.scroll_view_size = cc.size(600,580)
    local setting = {
        item_class = GuildBossRewardShowItem, -- 单元类
        start_x = 3, -- 第一个单元的X起点
        space_x = 5, -- x方向的间隔
        start_y = 0, -- 第一个单元的Y起点
        space_y = 0, -- y方向的间隔
        item_width = GuildBossRewardShowItem.Width, -- 单元的尺寸width
        item_height = GuildBossRewardShowItem.HEIGHT, -- 单元的尺寸height
        row = 0, -- 行数，作用于水平滚动类型
        col = 1, -- 列数，作用于垂直滚动类型
        --need_dynamic = true
    }
    self.list_view = CommonScrollViewLayout.new(self.main_panel, cc.p(35,125), ScrollViewDir.vertical, ScrollViewStartPos.bottom, self.scroll_view_size, setting)
end

function GuildBossRewardShowView:register_event()
    if self.background then
        self.background:addTouchEventListener(
            function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    playTabButtonSound()
                    controller:oepnGuildRewardShowView(false)
                end
            end
        )
    end
    if self.close_btn then
        self.close_btn:addTouchEventListener(
            function(sender, event_type)
                customClickAction(sender,event_type)
                if event_type == ccui.TouchEventType.ended then
                    playTabButtonSound()
                    controller:oepnGuildRewardShowView(false)
                end
            end
        )
    end

end


function GuildBossRewardShowView:updateData(data)
    if not data then return end
    self.base_info = model:getBaseInfo()

    self.desc_label:setString(Config.GuildDunData.data_const["reward_desc01"].desc)
    self.desc_label_2:setString(Config.GuildDunData.data_const["reward_desc02"].desc)
    self.list_view:setData(data)
    self.list_view:addEndCallBack(function ( ... )
        local pos = self:getCurRoomPos(self.base_info.fid)
        if pos then
            local final_y = self:getX(pos)
            self.list_view:updateMove(cc.p(self.list_view:getCurContainerPosX(), final_y), 0.1)
        end
    end)
end

function GuildBossRewardShowView:getCurRoomPos(k)
    if self.list_view then
        local list = self.list_view:getItemList()
        if list then
            for i, item in ipairs(list) do
                if item and item.data._index == k then
                    return item:getItemPosition()
                end
            end
        end
    end
end

function GuildBossRewardShowView:getX(pos)
    local final_y= 3 * GuildBossRewardShowItem.HEIGHT - pos.y
    if self.list_view and not tolua.isnull(self.list_view) then
        if final_y >=  GuildBossRewardShowItem.HEIGHT then
            final_y = 0
        elseif final_y < (self.scroll_view_size.height - self.list_view:getMaxSize().height) then
            final_y = self.scroll_view_size.height - self.list_view:getMaxSize().height
        end
    end
    return final_y
end




function GuildBossRewardShowView:openRootWnd()
    if Config.GuildDunData.data_chapter_reward  then
        self:updateData(Config.GuildDunData.data_chapter_reward)
    end
end

function GuildBossRewardShowView:close_callback()
    if self.list_view then
        self.list_view:DeleteMe()
        self.list_view = nil
    end
    controller:oepnGuildRewardShowView(false)
end


local table_insert = table.insert
--单项
GuildBossRewardShowItem = class("GuildBossRewardShowItem",function()
    return ccui.Widget:create()
end)

GuildBossRewardShowItem.HEIGHT = 123
GuildBossRewardShowItem.WIDTH = 599

function GuildBossRewardShowItem:ctor()
    self.item_list = {}
    self.size = cc.size(GuildBossRewardShowItem.WIDTH,GuildBossRewardShowItem.HEIGHT)
    self:setContentSize(self.size)
    self:setAnchorPoint(cc.p(0,1))
	local bg = createScale9Sprite(PathTool.getResFrame("common", "common_1029"),self.size.width/2,self.size.height/2)
    bg:setContentSize(cc.size(GuildBossRewardShowItem.WIDTH,GuildBossRewardShowItem.HEIGHT))
    self:addChild(bg)
    self.name = createRichLabel(26, 175, cc.p(0.5, 0.5), cc.p(100, 80), nil, nil, 1000)
    self:addChild(self.name)

    self.chapter_name = createRichLabel(20, 181, cc.p(0.5, 0.5), cc.p(100,40), nil, nil, 1000)
    self:addChild(self.chapter_name)
    self.scroll_view_size = cc.size(350,80)
    self.list_view = createScrollView( self.scroll_view_size.width, self.scroll_view_size.height,225,21,self,ccui.ScrollViewDir.horizontal)
    self.list_view:setSwallowTouches(false)
    self.tag = createSprite(PathTool.getResFrame("guildboss", "guildboss_1024"),0,30,self,cc.p(0,0))
    self.tag:setVisible(false)
end

function GuildBossRewardShowItem:setData(data)
    if data then
        self.data = data
        self.name:setString(data.chapter_name)
        self.chapter_name:setString(data.chapter_desc)
        local list = {}
        local scale = 0.7
        local base_info = model:getBaseInfo()
        self.tag:setVisible(false)
        if base_info.fid == data.id then
            self.tag:setVisible(true)
        end
        RenderMgr:getInstance():doNextFrame(function(  )
            local item_width = BackPackItem.Width * scale * tableLen(data.award_list)
            local max_width = math.max(item_width, self.list_view:getContentSize().width)
       
            self.list_view:setInnerContainerSize(cc.size(max_width, self.list_view:getContentSize().height))
            local start_x = (self.list_view:getContentSize().width - item_width) / 2
            for i, v in ipairs(data.award_list) do
                if not self.item_list[i] then
                    local item = BackPackItem.new(true, true)
                    item:setScale(scale)
                    item:setBaseData(v[1], v[2])
                    item:setDefaultTip()
                    local _x = start_x + (BackPackItem.Width * scale) * (i - 1) + BackPackItem.Width * scale * 0.5
                    if  item_width >  self.scroll_view_size.width then
                        _x = start_x + (BackPackItem.Width * scale) * (i - 1) + BackPackItem.Width * scale
                    end
                    item:setPosition(_x, self.list_view:getContentSize().height / 2)
                    self.list_view:addChild(item)
                    self.item_list[i] = item
                end
            end
        end)
	end
end

function GuildBossRewardShowItem:getItemPosition()
    if self then
        return cc.p(self:getPosition())
    end
end

function GuildBossRewardShowItem:DeleteMe()
    if self.item_list then
        for i,v in ipairs(self.item_list) do
            if v then
                v:DeleteMe()
            end
        end
    end
    self.item_list = {}
	self:removeAllChildren()
	self:removeFromParent()
end 
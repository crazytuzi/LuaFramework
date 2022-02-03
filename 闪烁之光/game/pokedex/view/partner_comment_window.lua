-- --------------------------------------------------------------------
-- 图鉴伙伴评论
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
-- --------------------------------------------------------------------
PartnerCommentWindow = PartnerCommentWindow or BaseClass(BaseView)

local table_sort = table.sort
function PartnerCommentWindow:__init(data)
    self.ctrl = PokedexController:getInstance()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.is_full_screen = false
    self.title_str = TI18N("评论")
    self.hero_data = data or {}
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("pokedex","pokedex"), type = ResourcesType.plist },
    }

    self.win_type = WinType.Big    
    self.default_msg = TI18N("请输入评论内容")
end

function PartnerCommentWindow:open_callback()
    local csbPath = PathTool.getTargetCSB("pokedex/pokedex_comment")
    local root = cc.CSLoader:createNode(csbPath)
    self.container:addChild(root)

    self.main_panel = root:getChildByName("main_panel")
    -- self:playEnterAnimatianByObj(self.main_panel , 2)

    --喜欢按钮
    self.like_btn = self.main_panel:getChildByName("like_btn")
    self.send_btn = self.main_panel:getChildByName("send_btn")
    self.send_btn:setTitleText(TI18N("发送"))
    local title = self.send_btn:getTitleRenderer()   
    title:enableOutline(Config.ColorData.data_color4[264], 2)
    --评论输入
    local size = cc.size(470,50)
    self.edit_box = createEditBox(self.main_panel, PathTool.getResFrame("common", "common_1021"),size, nil, 20, Config.ColorData.data_color3[151], 20, self.default_msg, nil, nil, LOADTEXT_TYPE_PLIST)
    self.edit_box:setAnchorPoint(cc.p(0,0))
    self.edit_box:setPlaceholderFontColor(Config.ColorData.data_color4[63])
    self.edit_box:setFontColor(Config.ColorData.data_color4[66])
    self.edit_box:setPosition(18,14)
    self.edit_box:setMaxLength(40)

    -- self:updateCommentList()
    self:createHeroMessage()
end

function PartnerCommentWindow:register_event()
    --请求整个评论列表
    if not self.get_list_event then 
        self.get_list_event= GlobalEvent:getInstance():Bind(PokedexEvent.Comment_List_Event,function(data)
            self.data = data
            self:updateCommentList()
        end)
    end    
    --评论返回
    if not self.comment_success_event then 
        self.comment_success_event = GlobalEvent:getInstance():Bind(PokedexEvent.Comment_Say_Event,function()
            self.ctrl:sender11041(self.hero_data.bid,1,100)
            self.edit_box:setText("")
        end)
    end
    --点击喜欢返回
    if not self.like_success_event then 
        self.like_success_event= GlobalEvent:getInstance():Bind(PokedexEvent.Comment_Like_Event,function()
            if not self.data then return end
            local res = PathTool.getResFrame("pokedex","pokedex_23")
            local like_num = self.data.like_num or 0
            local str = string.format( "<img src='%s' /> %s",res,like_num+1)
            self.like_num:setString(str)
            self.like_btn:setVisible(false)
        end)
    end    
    --点击点赞或踩返回
    if not self.zan_success_event then 
        self.zan_success_event= GlobalEvent:getInstance():Bind(PokedexEvent.Comment_Zan_Event,function(data)
            if self.select_item then 
                self.select_item:updateCommentNum(data)
            end
            self.select_item = nil
        end)
    end    
  
    self.like_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.data and self.data.like and self.data.like ==1 then 
                message(TI18N("你已设置为喜欢"))
                return
            end
            if not self.hero_data then return end
            self.ctrl:sender11042(self.hero_data.bid)
        end
    end)
    self.send_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if isQingmingShield and isQingmingShield() then
                return
            end
            if not self.hero_data then return end
            local msg = self.edit_box:getText() or ""
            if string.len(msg) <=0 then
                message(TI18N("请输入评论内容"))
                return
            end
            self.ctrl:sender11043(self.hero_data.bid,msg)
        end
    end)
end

function PartnerCommentWindow:createHeroMessage()
    --头像
    self.hero_item = HeroExhibitionItem.new()
    self.hero_item:setPosition(cc.p(85,740))
    self.main_panel:addChild(self.hero_item)
    self.hero_item:setData(self.hero_data)
    --名字
    self.hero_name = createLabel(26,cc.c3b(104, 69, 42),nil,160,755,"",self.main_panel,0, cc.p(0,0))
    self.hero_name:setString(self.hero_data.name)
    --喜欢人数
    self.like_num = createRichLabel(26,cc.c4b(175,77,30,255), cc.p(0,0), cc.p(160,700), 0, 0, 500)
    self.main_panel:addChild(self.like_num)
    --点评人数
    self.comment_num = createLabel(24,cc.c3b(104, 69, 42),nil,470,670,"",self.main_panel,0, cc.p(0,0))
end

function PartnerCommentWindow:openRootWnd()
    if not self.hero_data  then return end
    self.ctrl:sender11041(self.hero_data.bid,1,100)
end

function PartnerCommentWindow:updateCommentList()
    if not self.data then return end
    
    local res = PathTool.getResFrame("pokedex","pokedex_23")
    local like_num = self.data.like_num or 0
    local str = string.format( "<img src='%s' /> %s",res,like_num)
    self.like_num:setString(str)

    if self.data.partner_comments then
        local num = #self.data.partner_comments or 0
        self.comment_num:setString(TI18N("评论数：").. num)
    end

    local bool = true
    if self.data.like and self.data.like == 1 then 
        bool = false
    end
    self.like_btn:setVisible(bool)

    local scroll_view_size = cc.size(620,560)
    if not self.list_view then
        local setting = {
            item_class = PokedexCommentItem,      -- 单元类
            start_x = 4,                  -- 第一个单元的X起点
            space_x = 0,                    -- x方向的间隔
            start_y = 0,                    -- 第一个单元的Y起点
            space_y = 5,                   -- y方向的间隔
            item_width = 610,               -- 单元的尺寸width
            item_height = 150,              -- 单元的尺寸height
            row = 1,                        -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            need_dynamic = true
        }
        self.list_view = CommonScrollViewLayout.new(self.main_panel, cc.p(13, 95) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    end
    local list =self.data.partner_comments or {}
    local function callback(item,vo,index)
        if vo and next(vo)~=nil then
            self.select_item = item
            local partner_id = self.hero_data.bid or 0
            local comment_id = vo.comment_id or 0
            index =index or 1
            self.ctrl:sender11044(partner_id,comment_id,index)
		end
    end
    self.list_view:setData(list, callback)
end

--[[
    @desc: 设置标签页面板数据内容
    author:{author}
    time:2018-05-03 21:57:09
    return
]]
function PartnerCommentWindow:setPanelData()
end

function PartnerCommentWindow:close_callback()
    self.ctrl:openCommentWindow(false)
    if self.hero_item then
        self.hero_item:DeleteMe()
    end
    self.hero_item = nil

    if self.list_view then 
        self.list_view:DeleteMe()
        self.list_view = nil
    end
    if self.get_list_event then 
        GlobalEvent:getInstance():UnBind(self.get_list_event)
        self.get_list_event = nil
    end
    if self.like_success_event then 
        GlobalEvent:getInstance():UnBind(self.like_success_event)
        self.like_success_event = nil
    end
    if self.comment_success_event then 
        GlobalEvent:getInstance():UnBind(self.comment_success_event)
        self.comment_success_event = nil
    end
    if self.zan_success_event then 
        GlobalEvent:getInstance():UnBind(self.zan_success_event)
        self.zan_success_event = nil
    end
end



-- --------------------------------------------------------------------
-- 竖版奖励子项
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
PokedexCommentItem = class("PokedexCommentItem", function()
    return ccui.Widget:create()
end)

function PokedexCommentItem:ctor(open_type)  
    self.open_type = open_type or 1
    self:config()
    self:layoutUI()
    self:registerEvents()
end
function PokedexCommentItem:config()
    self.ctrl = StartowerController:getInstance()
    self.size = cc.size(610,150)
    self:setContentSize(self.size)
    self.attr_list = {}
    self.star_list = {}
end
function PokedexCommentItem:layoutUI()
    local csbPath = PathTool.getTargetCSB("pokedex/pokedex_comment_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)
    
    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self.bg = self.main_panel:getChildByName("bg")
   
    --热度图标
    self.hot_bg =self.main_panel:getChildByName("hot_bg") 
    self.hot_bg:setVisible(false)
    --踩按钮
    self.btn1 = self.main_panel:getChildByName("btn1") 
    local title = self.btn1:getChildByName("title") 
    self.btn1.title = title
    self.btn1:setCascadeOpacityEnabled(true)
    self.btn1_select = self.btn1:getChildByName("bg_select")
    self.btn1_unselect = self.btn1:getChildByName("bg_unselect")
    self.btn1_select:setVisible(false)
    self.btn1_unselect:setVisible(true)
    --点赞按钮
    self.btn2 = self.main_panel:getChildByName("btn2") 
    local title = self.btn2:getChildByName("title") 
    self.btn2.title = title
    self.btn2:setCascadeOpacityEnabled(true)
    self.btn2_select = self.btn2:getChildByName("bg_select")
    self.btn2_unselect = self.btn2:getChildByName("bg_unselect")
    self.btn2_select:setVisible(false)
    self.btn2_unselect:setVisible(true)
    --评论者名字
    self.goods_name = createLabel(26,cc.c3b(158, 80, 27),nil,50,120,"",self.main_panel,0, cc.p(0,0.5))
    --评论内容
    self.comment_label =createRichLabel(24, cc.c4b(104,69,42,255), cc.p(0,1), cc.p(50,90), 0, 0, 520)
    self.main_panel:addChild(self.comment_label)
 
end



function PokedexCommentItem:setData(data)
    if not data then return end
    self.data = data
    local name = data.name or ""
    self.goods_name:setString(name)

    local num = data.no_like_num
    self.btn1.title:setString(num)

    local num = data.like_num
    self.btn2.title:setString(num)

    local str = data.msg or ""
    self.comment_label:setString(str)

    if data._index and data._index <=3 then 
        self.hot_bg:setVisible(true)
    end
    if data.is_like then 
        if data.is_like == 0 then 
            self.btn1_unselect:setVisible(false)
            self.btn1_select:setVisible(true)
            self.btn2_unselect:setVisible(true)
            self.btn2_select:setVisible(false)
        elseif data.is_like == 1 then
            self.btn2_unselect:setVisible(false)
            self.btn2_select:setVisible(true)
            self.btn1_unselect:setVisible(true)
            self.btn1_select:setVisible(false)
        else
            self.btn1_select:setVisible(false)
            self.btn1_unselect:setVisible(true)
            self.btn2_select:setVisible(false)
            self.btn2_unselect:setVisible(true)
        end
    end
end
--事件
function PokedexCommentItem:registerEvents()
     self.btn1:addTouchEventListener(function(sender, event_type) 
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.call_fun then 
                self:call_fun(self.data,0)
            end
        end
    end)
    self.btn2:addTouchEventListener(function(sender, event_type) 
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.call_fun then 
                self:call_fun(self.data,1)
            end
        end
    end)
end
function PokedexCommentItem:updateCommentNum(vo)
    if not vo then return end
    if not self.data then return end
    local click_type = vo.type or 0 
    if click_type == 0 then 
        self.data.is_like = 0
        local num = self.data.no_like_num
        self.btn1.title:setString(num+1)
        --setChildDarkShader(true,self.btn1)
        self.btn1_unselect:setVisible(false)
        self.btn1_select:setVisible(true)
        self.btn2_unselect:setVisible(true)
        self.btn2_select:setVisible(false)
    else
        self.data.is_like = 1
        local num = self.data.like_num
        self.btn2.title:setString(num+1)
        --setChildDarkShader(true,self.btn2)
        self.btn2_unselect:setVisible(false)
        self.btn2_select:setVisible(true)
        self.btn1_unselect:setVisible(true)
        self.btn1_select:setVisible(false)
    end
end
function PokedexCommentItem:clickHandler()
    if self.call_fun then 
        self:call_fun(self.data)
    end
end
function PokedexCommentItem:addCallBack(call_fun)
    self.call_fun =call_fun
end

function PokedexCommentItem:DeleteMe()
    self.data = nil
    self:removeFromParent()
end





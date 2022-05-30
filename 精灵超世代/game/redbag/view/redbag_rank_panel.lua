-- --------------------------------------------------------------------
-- 发红包榜
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
RedBagRankPanel = class("RedBagRankPanel", function()
    return ccui.Widget:create()
end)
local table_insert = table.insert
function RedBagRankPanel:ctor(parent)  
    self:config()
    self:layoutUI()
    self:registerEvents()
end
function RedBagRankPanel:config()
    self.ctrl = RedbagController:getInstance()
    self.size = cc.size(644,740)
    self:setContentSize(self.size)
    self:setTouchEnabled(false)
  
end
function RedBagRankPanel:layoutUI()

    local csbPath = PathTool.getTargetCSB("redbag/redbag_rank")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)
    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self.size = self.main_panel:getContentSize()
    self.top_panel = self.main_panel:getChildByName("top_panel")
    self.look_btn = self.top_panel:getChildByName("look_btn")
    self.look_btn:setTitleText(TI18N("查看详情"))
    local title = self.look_btn:getTitleRenderer()   
    title:enableOutline(Config.ColorData.data_color4[264],2)

    self.no_label = createLabel(24,Config.ColorData.data_color4[1],nil,self.size.width/2,780,"",self.main_panel,0, cc.p(0.5,0))
    self.no_label:setString(TI18N("虚位以待！"))
    self.no_label:setVisible(false)
    --框
    self.head_bg = self.top_panel:getChildByName("head_bg")
    self.head_icon = PlayerHead.new(PlayerHead.type.circle)
	self.head_icon:setPosition(cc.p(53,53))
	self.head_icon:setAnchorPoint(cc.p(0.5,0.5))
	self.head_bg:addChild(self.head_icon)
    self.head_bg:setVisible(false)
    self.look_btn:setVisible(false)
   
    self.role_name = createLabel(24,Config.ColorData.data_color4[1],cc.c4b(0x8b,0x09,0x09,0xff),160,62,"",self.top_panel,2, cc.p(0,0.5))
    -- self:updateRankList()
end

function RedBagRankPanel:setData(data)
end

--事件
function RedBagRankPanel:registerEvents()
    self.look_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if not self.first_data  then return end
            local roleVo = RoleController:getInstance():getRoleVo()
            local touchPos = cc.p(sender:getTouchEndPosition().x+320,sender:getTouchEndPosition().y)
            if roleVo.rid==self.first_data.rid and roleVo.srv_id==self.first_data.srv_id then 
                message(TI18N("你连自己都不认识了么？"))
                return 
            end
			ChatController:getInstance():openFriendInfo(self.first_data,touchPos)
        end
    end)
    if not self.rank_list_event then 
        self.rank_list_event = GlobalEvent:getInstance():Bind(RedbagEvent.Rank_List_Event,function(data)
            self:updateMessage(data)
            self:updateRankList(data)
        end)
    end
end
function RedBagRankPanel:updateMessage(data)
    if not data then return end
    if not data.list or next(data.list) == nil then return end

    self.first_data = data.list[1]
    self.role_name:setString(self.first_data.name or "")

    self.head_icon:setHeadRes(self.first_data.face_id, false, LOADTEXT_TYPE, self.first_data.face_file, self.first_data.face_update_time)
    local circle_config =Config.AvatarData.data_avatar[self.first_data.avatar_bid]
    if circle_config then
        local res_id = circle_config.res_id or 1 
        local res = PathTool.getTargetRes("headcircle","txt_cn_headcircle_"..res_id,false,false)
        self.head_icon:showBg(res,nil,false,circle_config.offy)
    end

end
function RedBagRankPanel:updateRankList(data)
    if not data then 
        self:showEmptyIcon(true)
        return 
    end
    if not self.list_view then
        local scroll_view_size = cc.size(600,686)
        local setting = {
            item_class = RedRankItem,      -- 单元类
            start_x = -5,                  -- 第一个单元的X起点
            space_x = 30,                    -- x方向的间隔
            start_y = 0,                    -- 第一个单元的Y起点
            space_y = 2,                   -- y方向的间隔
            item_width = 600,               -- 单元的尺寸width
            item_height = 123,              -- 单元的尺寸height
            row = 1,                        -- 行数，作用于水平滚动类型
            col = 1                         -- 列数，作用于垂直滚动类型
        }
        self.list_view = CommonScrollViewLayout.new(self.main_panel, cc.p(27, 24) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    end
   
    local list =data.list or {}
    if not list or next(list) ==nil then 
        self:showEmptyIcon(true)
        return
    end
    self:showEmptyIcon(false)
    local function callback(item,vo)
    end
    self.list_view:setData(list, callback)
end
function RedBagRankPanel:setVisibleStatus(bool)
    self:setVisible(bool)
end

--显示空白
function RedBagRankPanel:showEmptyIcon(bool)
    self.head_bg:setVisible(not bool)
    self.look_btn:setVisible(not bool)
    if not self.empty_con and bool == false then return end

    if not self.empty_con then 
        local size = cc.size(200,200)
        self.empty_con = ccui.Widget:create()
        self.empty_con:setContentSize(size)
        self.empty_con:setAnchorPoint(cc.p(0.5,0))
        self.empty_con:setPosition(cc.p(self.size.width/2,330))
        self.main_panel:addChild(self.empty_con,10)
        local res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_3")
        local bg = createImage(self.empty_con, res, size.width/2, size.height/2, cc.p(0.5,0.5), false)
        self.empty_label = createLabel(26,Config.ColorData.data_color4[175],nil,size.width/2,-10,"",self.empty_con,0, cc.p(0.5,0))
    end
    local str = TI18N("暂无排行")
    self.empty_label:setString(str)
    self.empty_con:setVisible(bool)
    self.no_label:setVisible(bool)
end

function RedBagRankPanel:DeleteMe()
    if self.rank_list_event then 
        GlobalEvent:getInstance():UnBind(self.rank_list_event)
        self.rank_list_event = nil
    end
end



-- --------------------------------------------------------------------
-- 红包排行子项
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
RedRankItem = class("RedRankItem", function()
    return ccui.Widget:create()
end)

function RedRankItem:ctor()
    self:config()
    self:layoutUI()
    self:registerEvents()
end
function RedRankItem:config()
    self.size = cc.size(600,123)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)
    self:setAnchorPoint(cc.p(0.5,0.5))
    self.is_show_point = false
    self.star_list = {}
end
function RedRankItem:layoutUI()
    local csbPath = PathTool.getTargetCSB("redbag/redbag_rank_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)
    
    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self.rank_icon = createImage(self.main_panel, nil, 60,self.size.height/2, cc.p(0.5,0.5), true, 1, false)

    --名字
    self.role_name = createLabel(26,Config.ColorData.data_color4[175],nil,125,self.size.height/2,"",self.main_panel,0, cc.p(0,0.5))
    self.rank_index =  createLabel(30,Config.ColorData.data_color4[186],nil,50,self.size.height/2,"",self.main_panel,0, cc.p(0.5,0.5),"fonts/title.ttf")

    --发放总价值
    self.send_money = createLabel(22,Config.ColorData.data_color4[175],nil,355,self.size.height/2+15,"",self.main_panel,0, cc.p(0,0.5))
    --发放数
    self.send_num = createLabel(22,Config.ColorData.data_color4[186],nil,355,self.size.height/2-15,"",self.main_panel,0, cc.p(0,0.5))
end

function RedRankItem:setData(vo)
    if not vo then return end
  
    self.data = vo
	local index = vo._index
    self.index = index or 1

    self.rank_index:setString(self.index)
	if self.index >= 1 and self.index <= 3 then
        self.rank_index:setVisible(false)
        self.rank_icon:setVisible(true)
		self.rank_icon:loadTexture(PathTool.getResFrame("common","common_300"..self.index),LOADTEXT_TYPE_PLIST)
		self.rank_icon:setScale(0.7)
    else
        self.rank_index:setVisible(true)
        self.rank_icon:setVisible(false)
    end

    local name = vo.name or ""
    self.role_name:setString(name)
    local price = vo.price or ""
    self.send_money:setString(TI18N("发放总价值：")..price)
    local num = vo.num or 0
    self.send_num:setString(TI18N("发放红包数：")..num)
end

--事件
function RedRankItem:registerEvents()
    self:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.call_fun then
                self:call_fun(self.data)
            end
        end
    end)
end

function RedRankItem:clickHandler()
    if self.call_fun then 
        self:call_fun(self.data)
    end
end
function RedRankItem:addCallBack(call_fun)
    self.call_fun =call_fun
end


function RedRankItem:setVisibleStatus(bool)
    self:setVisible(bool)
end


function RedRankItem:getData(  )
    return self.data
end

function RedRankItem:DeleteMe()
    self:removeFromParent()
end







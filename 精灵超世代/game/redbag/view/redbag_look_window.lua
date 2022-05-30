-- --------------------------------------------------------------------
-- 查看红包界面
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
RedBagLookWindow = RedBagLookWindow or BaseClass(BaseView)

local table_sort = table.sort
function RedBagLookWindow:__init(data)
    self.ctrl = RedbagController:getInstance()
    self.is_full_screen = false
    self.layout_name = "redbag/redbag_look"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("redbag","redbag"), type = ResourcesType.plist },
    }
    self.effect_cache_list = {}
    self.win_type = WinType.Mini 
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.data = data
    self.cache_list = {}
end

function RedBagLookWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    
    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self:playEnterAnimatianByObj(self.main_panel , 2)
    self.size = self.main_panel:getContentSize()
    
    self.close_btn = self.main_panel:getChildByName("close_btn")
    self.label_panel = self.main_panel:getChildByName("label_panel")
    
    self.title = self.label_panel:getChildByName("title")

    self.head_icon = PlayerHead.new(PlayerHead.type.circle)
	self.main_panel:addChild(self.head_icon)
	self.head_icon:setPosition(cc.p(self.size.width/2,575))
	self.head_icon:setAnchorPoint(cc.p(0.5,0))
	self.head_icon:setTouchEnabled(true)
	-- self.head_icon:setScale(0.7)
	self.head_icon:addTouchEventListener(function(sender, event)
		if ccui.TouchEventType.ended == event and self.data then
			local roleVo = RoleController:getInstance():getRoleVo()
            local touchPos = cc.p(sender:getTouchEndPosition().x+320,sender:getTouchEndPosition().y)
            if roleVo.rid==self.data.rid and roleVo.srv_id==self.data.srv_id then 
                return 
            end
			ChatController:getInstance():openFriendInfo(self.data,touchPos)
		end
    end)

    self.status_bg = self.main_panel:getChildByName("status_bg")
    self.status_bg:setVisible(false)
    --红包寄语
    self.desc_label = createRichLabel(20,Config.ColorData.data_color4[1],cc.p(0.5,0),cc.p(self.size.width/2,680),nil,nil,500)
    self.label_panel:addChild(self.desc_label)
    --红包来自于
    self.role_name = createRichLabel(20,cc.c4b(0x70,0x00,0x16,0xff),cc.p(0.5,0),cc.p(self.size.width/2,560),nil,nil,500)
    self.label_panel:addChild(self.role_name)

    self.desc_label:setString(TI18N("我是描述描述描述"))
    self.role_name:setString(string.format(TI18N("<div fontcolor=#ffea96>我是名字啊哦</div>的红包")))

    --剩余个数
    self.less_num = createRichLabel(20,Config.ColorData.data_color4[1],cc.p(0,0),cc.p(20,30),nil,nil,500)
    self.label_panel:addChild(self.less_num)
    --剩余时间
    self.less_time = createRichLabel(20,Config.ColorData.data_color4[1],cc.p(0.5,0),cc.p(360,30),nil,nil,500)
    self.label_panel:addChild(self.less_time)
    self.less_time:setString(TI18N("剩余时间：00:00:00"))
end

function RedBagLookWindow:register_event()
    self.background:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            self.ctrl:openLookWindow(false)
        end
    end)
    self.close_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            self.ctrl:openLookWindow(false)
        end
    end)
    if not self.get_list_event then 
        self.get_list_event = GlobalEvent:getInstance():Bind(RedbagEvent.Get_List_Event,function(data)
            self:updateMessage(data)
            self:updateMemberList(data)
        end)
    end
end
function RedBagLookWindow:updateMessage(data)
    if not data then return end
    if not self.data then return end
    self.status_bg:setVisible(false)
    self.list_data = data
    self.head_icon:setHeadRes(data.face_id, false, LOADTEXT_TYPE, data.face_file, data.face_update_time)
    local circle_config =Config.AvatarData.data_avatar[data.avatar_bid]
    if circle_config then
        local res_id = circle_config.res_id or 1 
        local res = PathTool.getTargetRes("headcircle","txt_cn_headcircle_"..res_id,false,false)
        self.head_icon:showBg(res,nil,false,circle_config.offy)
    end

    local config = Config.GuildData.data_guild_red_bag[self.data.type]
    if not config then return end
    self.red_config = config
    self.title:setString(config.name)
    local name = data.name or ""
    self.role_name:setString(string.format(TI18N("<div fontcolor=#ffea96>%s</div>的红包"),name))

    local config = Config.GuildData.data_guild_red_bag[data.type]
    if config then
        self.desc_label:setString(config.msg)
    end

    if self.data.num >= self.data.max_num then 
        self.status_bg:setVisible(true)
    end

    self.less_num:setString(string.format(TI18N("剩余个数：%s/%s"),self.data.max_num-self.data.num , self.data.max_num))
    if self.less_timer then 
        GlobalTimeTicket:getInstance():remove(self.less_timer)
        self.less_timer = nil
    end
    local less_time = self.data.time or 0
    if less_time-GameNet:getInstance():getTime() <=0 then 
        self.less_time:setString(TI18N("剩余时间：已过期"))
        return
    end
    if not self.less_timer then 
        self.less_timer = GlobalTimeTicket:getInstance():add(function()
            self.less_time:setString(TI18N("剩余时间：") .. TimeTool.GetTimeFormatDay(less_time-GameNet:getInstance():getTime()))
            less_time = less_time -1
        end,1)
    end
end
function RedBagLookWindow:updateMemberList(data)
    if not self.list_view then
        local scroll_view_size = cc.size(450,400)
        local setting = {
            item_class = RedBagLookItem,      -- 单元类
            start_x = 1,                  -- 第一个单元的X起点
            space_x = 2,                    -- x方向的间隔
            start_y = 10,                    -- 第一个单元的Y起点
            space_y = 3,                   -- y方向的间隔
            item_width = 455,               -- 单元的尺寸width
            item_height = 93,              -- 单元的尺寸height
            row = 1,                        -- 行数，作用于水平滚动类型
            col = 1                         -- 列数，作用于垂直滚动类型
        }
        self.list_view = CommonScrollViewLayout.new(self.main_panel, cc.p(19, 66) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    end
   
    -- local data_list = data.list or {}
    local list = data.list or {}
    local sort_func = SortTools.tableUpperSorter({"val", "time"})
    table_sort(list, sort_func)
    -- for i,v in pairs(data_list) do
    --     list = {data=v,}
    -- end
    local function callback(item,vo)
    end

    self.list_view:setData(list, callback,nil,self.red_config)

end

function RedBagLookWindow:openRootWnd()
    if not self.data then return end
    self.ctrl:sender13540(self.data.id)
end
function RedBagLookWindow:setPanelData()
end

function RedBagLookWindow:close_callback()
    self.ctrl:openLookWindow(false)
    if self.list_view then 
        self.list_view:DeleteMe()
        self.list_view = nil
    end
    if self.head_icon then 
        self.head_icon:DeleteMe()
        self.head_icon = nil
    end
    if self.get_list_event then 
        GlobalEvent:getInstance():UnBind(self.get_list_event)
        self.get_list_event = nil
    end
    if self.less_timer then 
        GlobalTimeTicket:getInstance():remove(self.less_timer)
        self.less_timer = nil
    end
end








-- --------------------------------------------------------------------
-- 红包查看子项
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
RedBagLookItem = class("RedBagLookItem", function()
    return ccui.Widget:create()
end)

function RedBagLookItem:ctor(index)
    self:config()
    self:layoutUI()
    self:registerEvents()
end
function RedBagLookItem:config()
    self.ctrl = RedbagController:getInstance()
    self.size = cc.size(455,93)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)
    self:setAnchorPoint(cc.p(0.5,0.5))
end
function RedBagLookItem:layoutUI()
    local res = PathTool.getResFrame("redbag","redbag_7")
    self.bg = createImage(self, res, self.size.width/2, self.size.height/2, cc.p(0.5,0.5), true, 0, true)
    self.bg:setContentSize( self.size)

    local res = PathTool.getResFrame("redbag","redbag_6")
    self.me_bg = createImage(self, res, self.size.width/2, self.size.height/2, cc.p(0.5,0.5), true, 0, true)
    self.me_bg:setContentSize(self.size)
    self.me_bg:setVisible(false)

    self.head_icon = PlayerHead.new(PlayerHead.type.circle)
	self:addChild(self.head_icon)
	self.head_icon:setPosition(cc.p(10,44))
	self.head_icon:setAnchorPoint(cc.p(0,0.5))
	self.head_icon:setTouchEnabled(true)
	self.head_icon:setScale(0.7)
	self.head_icon:addTouchEventListener(function(sender, event)
		if ccui.TouchEventType.ended == event and self.data then
			local roleVo = RoleController:getInstance():getRoleVo()
			local touchPos = cc.p(sender:getTouchEndPosition().x+320,sender:getTouchEndPosition().y)
			if roleVo.rid==self.data.rid and roleVo.srv_id==self.data.srv_id then return end
			ChatController:getInstance():openFriendInfo(self.data,touchPos)
		end
    end)
    
    local res = PathTool.getResFrame("redbag","txt_cn_redbag_5")
    self.me_icon = createImage(self, res, 0, 47, cc.p(0,0), true, 1, false)
    self.me_icon:setVisible(false)
    --名字
    self.role_name = createRichLabel(20,Config.ColorData.data_color4[1],cc.p(0,0),cc.p(95,47),nil,nil,500)
    self:addChild(self.role_name)
    --时间
    self.get_time= createRichLabel(20,Config.ColorData.data_color4[1],cc.p(0,0),cc.p(95,13),nil,nil,500)
    self:addChild(self.get_time)
   
    --获得红包额度
    self.money_label= createRichLabel(24,Config.ColorData.data_color4[1],cc.p(1,0.5),cc.p(435,self.size.height/2),nil,nil,500)
    self:addChild(self.money_label)

    self.role_name:setString(TI18N("我是名字xx(成员)"))
    self.me_icon:setPositionX(self.role_name:getPositionX()+self.role_name:getContentSize().width+10)
    self.get_time:setString("7-12 19:00:00")
    local res = PathTool.getItemRes(2)
    self.money_label:setString(string.format("8888888<img src='%s' scale=0.4 />",res))
end

function RedBagLookItem:setData(vo)
    if not vo then return end
    if vo and vo._index and vo._index%2 ==0 then 
        self.bg:setVisible(true)
    else
        self.bg:setVisible(false)
    end
    self:showFirstIcon(false)
    if vo._index and vo._index == 1 then 
        self:showFirstIcon(true)
    end
    self.head_icon:setHeadRes(vo.face_id, false, LOADTEXT_TYPE, vo.face_file, vo.face_update_time)
    local circle_config =Config.AvatarData.data_avatar[vo.avatar_bid]
    if circle_config then
        local res_id = circle_config.res_id or 1 
        local res = PathTool.getTargetRes("headcircle","txt_cn_headcircle_"..res_id,false,false)
        self.head_icon:showBg(res,nil,false,circle_config.offy)
    end
    local name = vo.name or ""
    local post_num = vo.post or 3
    local post_config =  Config.GuildData.data_position[post_num]
    if post_config then
        local post = post_config.name or ""
        local str = string.format("%s(%s)",name,post)
        self.role_name:setString(str)
        self.me_icon:setPositionX(self.role_name:getPositionX()+self.role_name:getContentSize().width+10)
    end

    local get_time = TimeTool.getYMDHMS(vo.time or 0)
    self.get_time:setString(get_time)
    if not self.extend_data then return end
    local coin = self.extend_data.assets
    local val = vo.val or 0
    local item_id = Config.ItemData.data_assets_label2id[coin] or ""
    local item_config = Config.ItemData.data_get_data(item_id)
    if item_config then
        local res = PathTool.getItemRes(item_config.icon)
        local str = string.format(TI18N("%s <img src='%s' scale=0.35 />"),val,res)
        self.money_label:setString(str)
    end

    local role_vo = RoleController:getInstance():getRoleVo()
    self.me_icon:setVisible(false)
    if self.me_bg then 
        self.me_bg:setVisible(false)
    end
    if role_vo.rid == vo.rid and role_vo.srv_id == vo.srv_id then 
        self.me_icon:setVisible(true)
        self.me_bg:setVisible(true)
    end
   
end
function RedBagLookItem:showFirstIcon(bool)
    if bool == false and not self.first_icon then 
        return 
    end
    if not self.first_icon then 
        local res = PathTool.getResFrame("redbag","txt_cn_redbag_4")
        self.first_icon =  createImage(self, res, 34,70, cc.p(0.5,0.5), true, 10, false)
    end
    self.first_icon:setVisible(bool)
end
--事件
function RedBagLookItem:registerEvents()
    self:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.call_fun then
                self:call_fun(self.data)
            end
        end
    end)
end

function RedBagLookItem:clickHandler()
    if self.call_fun then 
        self:call_fun(self.data)
    end
end
function RedBagLookItem:addCallBack(call_fun)
    self.call_fun =call_fun
end
function RedBagLookItem:setExtendData(data)
    if not data then return end
    self.extend_data =data
end

function RedBagLookItem:setVisibleStatus(bool)
    self:setVisible(bool)
end


function RedBagLookItem:getData(  )
    return self.data
end

function RedBagLookItem:DeleteMe()
    if self.head_icon then
        self.head_icon:DeleteMe()
        self.head_icon = nil 
    end
    self:removeFromParent()
end
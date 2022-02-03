-- --------------------------------------------------------------------
-- 竖版个人荣誉
-- 
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
FriendGloryWindow = FriendGloryWindow or BaseClass(BaseView) 

function FriendGloryWindow:__init()
	self.ctrl = FriendController:getInstance()
    self.is_full_screen = false
    self.win_type = WinType.Mini  
    self.view_tag = ViewMgrTag.DIALOGUE_TAG  
    self.layout_name = "friend/friend_glory_window"       	
end

function FriendGloryWindow:open_callback(  )
	self.background_container = self.root_wnd:getChildByName("background_container")
    self.background = self.background_container:getChildByName("background")
    self.background_container:setScale(display.getMaxScale())

    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self:playEnterAnimatianByObj(self.main_panel, 2)
    self.close_btn = self.main_panel:getChildByName("close_btn")

    self.title_container = self.main_panel:getChildByName("title_container")
    self.title_label = self.title_container:getChildByName("title_label")
    self.title_label:setString(TI18N("个人荣誉"))

    self.info_con = self.main_panel:getChildByName("info_con")
    self.name = self.info_con:getChildByName("name")
    local guild_title = self.info_con:getChildByName("guild_title")
    guild_title:setString(TI18N("公会："))
    self.guild = self.info_con:getChildByName("guild")
    self.guild:setString(TI18N("暂无"))
    self.country = self.info_con:getChildByName("country")

    self.head = PlayerHead.new(PlayerHead.type.circle)
    self.head:setAnchorPoint(cc.p(0, 0))
    self.head:setPosition(cc.p(10, -5))
    self.info_con:addChild(self.head)

    self.vip_bg = self.info_con:getChildByName("Image_2")
    self.vip_icon = self.info_con:getChildByName("vip")
    self.vip_label = CommonNum.new(19, self.info_con, 1, -2, cc.p(0, 0.5))
	self.vip_label:setPosition(145, 85)
	self.vip_label:setNum(0)

    self.scrollCon = self.main_panel:getChildByName("scrollCon")
    local view_size = self.scrollCon:getContentSize()
    local scroll_view_size = cc.size(548, view_size.height - 12)

    local setting = {
        item_class = FriendGloryItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 2,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 2,                   -- y方向的间隔
        item_width = 548,               -- 单元的尺寸width
        item_height = 94,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1                         -- 列数，作用于垂直滚动类型
    }
    self.item_scrollview = CommonScrollViewLayout.new(self.scrollCon, cc.p(7,6) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
end

function FriendGloryWindow:register_event()
	if self.close_btn then
		self.close_btn:addTouchEventListener(function(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playCloseSound()
				self.ctrl:openFriendGloryWindow(false)
			end
		end)
	end
end

function FriendGloryWindow:updateData(  )
	if self.data == nil then return end
	self.name:setString(self.data.name)
    self.country:setPositionX(self.name:getPositionX()+self.name:getContentSize().width+5)
    self.head:setHeadRes(self.data.face_id, false, LOADTEXT_TYPE, self.data.face_file, self.data.face_update_time)
	if self.data.gname ~= "" then
		self.guild:setString(self.data.gname)
	end
    --头像框
    local vo = Config.AvatarData.data_avatar[self.data.avatar_base_id]
    if vo then
        local res_id = vo.res_id or 1 
        local res = PathTool.getTargetRes("headcircle","txt_cn_headcircle_"..res_id,false,false)
        self.head:showBg(res,nil,false,vo.offy)
    end

    self.head:setSex(self.data.sex,cc.p(70,4))

    -- 是否显示vip标识
    if self.data.is_show_vip and self.data.is_show_vip == 1 then
        self.vip_bg:setVisible(false)
        self.vip_icon:setVisible(false)
        self.vip_label:setVisible(false)
        self.name:setPositionX(120)
    else
        self.vip_bg:setVisible(true)
        self.vip_icon:setVisible(true)
        self.vip_label:setVisible(true)
        self.vip_label:setNum(self.data.vip_lev)
        self.name:setPositionX(172)
    end

    local list = self.data.honor_list
    table.sort(list, SortTools.KeyLowerSorter("type"))
    self.item_scrollview:setData(list)
end

function FriendGloryWindow:openRootWnd(data)
	self.data = data
	self:updateData()
end

function FriendGloryWindow:close_inheritback()
	self.ctrl:openFriendGloryWindow(false)
end

function FriendGloryWindow:close_callback()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end

    if self.vip_label then
        self.vip_label:DeleteMe()
        self.vip_label = nil
    end
	self.ctrl:openFriendGloryWindow(false)
end


-- --------------------------------------------------------------------
-- 竖版个人荣誉单个
-- 
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
FriendGloryItem = class("FriendGloryItem", function()
    return ccui.Widget:create()
end)

function FriendGloryItem:ctor()
    self:configUI()
end

function FriendGloryItem:configUI(  )
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("friend/friend_glory_item"))
    
    self:setAnchorPoint(cc.p(0, 1))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(544,94))
    --self:setTouchEnabled(true)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.my_title = self.main_container:getChildByName("my_title")
    self.my_val = self.main_container:getChildByName("my_val")
    local rank_title = self.main_container:getChildByName("rank_title")
    rank_title:setString(TI18N("全服排行："))
    self.rank = CommonNum.new(18, self.main_container, 0, -2, cc.p(0, 0.5))
    self.rank:setPosition(rank_title:getPositionX()+rank_title:getContentSize().width, rank_title:getPositionY()+12)

    self.no_rank = self.main_container:getChildByName("no_rank")
    self.no_rank:setVisible(false)

    self.power = self.main_container:getChildByName("power")
    self.power:setVisible(false)
end

function FriendGloryItem:setData( data )
    if data.type == 1 then --战力
        self.my_title:setString(TI18N("玩家战斗力："))
        if self.power_label == nil then
            self.power_label = CommonNum.new(20, self.power, 0, -2, cc.p(0, 0.5))
            self.power_label:setPosition(45, 24)
        end
        self.power:setVisible(true)
        self.power_label:setNum(data.val)
        self.my_val:setString("")
    elseif data.type == 2 then --推图进度
        self.my_title:setString(TI18N("玩家推图进度："))
        self.my_title:setPositionX(self.my_title:getPositionX() + 15)
        local config = Config.DungeonData.data_drama_dungeon_info(data.val)
        if config then
            self.my_val:setString(config.name)
        else
            self.my_val:setString(TI18N("暂无"))
        end
    elseif data.type == 3 then 
        self.my_title:setString(TI18N("玩家天梯杯数："))
        self.my_val:setString(data.val)
        self.my_title:setPositionX(self.my_title:getPositionX() + 15)
    elseif data.type == 4 then
        self.my_title:setString(TI18N("玩家伙伴数量："))
        self.my_title:setPositionX(self.my_title:getPositionX() + 15)
        self.my_val:setString(data.val)
    elseif data.type == 5 then
        self.my_title:setString(TI18N("试练塔排行："))
        self.my_title:setPositionX(self.my_title:getPositionX() + 15)
        self.my_val:setString(data.val)
    end

    if data.rank ~= 0 then
        self.no_rank:setVisible(false)
        self.rank:setVisible(true)
        self.rank:setNum(data.rank)
    else
        self.rank:setVisible(false)
        self.no_rank:setVisible(true)
    end
end

function FriendGloryItem:addCallBack( value )
    self.callback =  value
end

function FriendGloryItem:registerEvent()
    self:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.callback then
                self:callback()
            end
        end
    end)
end

function FriendGloryItem:DeleteMe()
    if self.rank then
        self.rank:DeleteMe()
        self.rank = nil
    end

    if self.power_label then
        self.power_label:DeleteMe()
        self.power_label = nil
    end

    if self.head then 
        self.head:DeleteMe()
        self.head = nil
    end

    self:removeAllChildren()
    self:removeFromParent()
end

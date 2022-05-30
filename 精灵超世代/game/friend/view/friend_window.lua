-- --------------------------------------------------------------------
-- 竖版好友
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
FriendWindow = FriendWindow or BaseClass(BaseView)

local table_insert = table.insert

function FriendWindow:__init()
    self.ctrl = FriendController:getInstance()
    self.is_full_screen = true
    self.win_type = WinType.Full              	
    self.title_str = TI18N("好友")
    self.empty_res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_3")
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("friend","friend"), type = ResourcesType.plist },
        { path = self.empty_res, type = ResourcesType.single },
    }
    self.tab_info_list = {
        {label=TI18N("我的好友"), index=FriendConst.Type.MyFriend, status=true},
        {label=TI18N("领取礼物"), index=FriendConst.Type.Award, status=true},
        {label=TI18N("申请列表"), index=FriendConst.Type.ApplyList, status=true},
        {label=TI18N("黑名单"), index=FriendConst.Type.BlackList, status=true},
    }
    self.view_list = {}
    self.friend_list = {}--因为4个标签页都是有列表。直接主界面创建复用

    self.scroll_width = 624
    self.scroll_height = 624

    self.rend_list = {}
    self.cache_list = {}
    self.is_init = true

    self.role_vo = RoleController:getInstance():getRoleVo()
end

function FriendWindow:open_callback()
    local size = self.container:getContentSize()
    self.list_view = ccui.Layout:create()
    self.list_view:setContentSize(cc.size(self.scroll_width, self.scroll_height))
    self.list_view:setAnchorPoint(cc.p(0.5, 1))
    self.list_view:setPosition(320, 784)
	self.list_view:setCascadeOpacityEnabled(true)
    self.container:addChild(self.list_view, 10)

    local setting = {
        item_class = FriendListItem,      -- 单元类
        start_x = 6,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 610,               -- 单元的尺寸width
        item_height = 114,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        once_num = 1,
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewLayout.new(self.list_view, cc.p(0, 0) , ScrollViewDir.vertical, ScrollViewStartPos.top, cc.size(self.scroll_width, self.scroll_height), setting)
end

-- function FriendWindow:setInviteCodeRedPointVisible(visible)
--     if not self.red_point then
--         self.red_point = createSprite(PathTool.getResFrame("mainui","mainui_1009"),0,0,self.container,cc.p(1,1),LOADTEXT_TYPE_PLIST)
--         self.red_point:setPosition(cc.p(657, -29))
--     end
--     if self.red_point then
--         self.red_point:setVisible(visible)
--     end
-- end

function FriendWindow:register_event()
    --申请好友列表返回
    self:addGlobalEvent(FriendEvent.FRIEND_APPLY, function()
        if self.cur_type ~= FriendConst.Type.ApplyList then return end
        self:updateFriendList(false)
    end)
    --赠送返回
    self:addGlobalEvent(FriendEvent.STRENGTH_UPDATE, function(data)
        if self.cur_type ~= FriendConst.Type.Award and self.cur_type ~= FriendConst.Type.MyFriend  then return end
        local list = data.list or {}
        local id_list = {}
        for i,v in pairs(list) do 
            id_list[getNorKey(v.rid,v.srv_id)] = v
        end
        local item_list = self.item_scrollview:getItemList()
        if item_list then
            for k,v in pairs(item_list) do
                local vo = v:getData()
                if vo and id_list[getNorKey(vo.rid,vo.srv_id)] then 
                    v:setData(id_list[getNorKey(vo.rid,vo.srv_id)])
                end
            end
        end
    end)
    --删除好友返回
    self:addGlobalEvent(FriendEvent.FRIEND_DELETE, function()
        if self.cur_type ~= FriendConst.Type.MyFriend and self.cur_type ~= FriendConst.Type.BlackList then return end
        self:updateFriendList(false, true)
    end)
    --增加好友
    self:addGlobalEvent(FriendEvent.UPDATE_APPLY, function()
        if self.cur_type ~= FriendConst.Type.MyFriend then 
            self:setTabTips(true,FriendConst.Type.MyFriend)
            if self.cur_type == FriendConst.Type.ApplyList then
                self:updateFriendList(false)
            end
        else
            self:updateFriendList(false)
        end    
        self:showRedPoint()
    end)

    --友情点变化更新
    if self.role_vo ~= nil then
        if self.role_assets_event == nil then
			self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
                if key == "friend_point" then
                    if self.cur_type == FriendConst.Type.MyFriend or self.cur_type == FriendConst.Type.Award then 
                        if self.pre_panel and self.pre_panel.setFriendPoint then 
                            self.pre_panel:setFriendPoint()
                        end
                    end
                end
			end)
		end
    end

    self:addGlobalEvent(FriendEvent.UPDATE_COUNT, function()
        self:updateFriendList(false)
        self:showRedPoint()
    end)
    --被删好友
    self:addGlobalEvent(FriendEvent.UPDATE_GROUP_COUNT, function()
        self:updateFriendList(false, true)
        self:showRedPoint()
    end)
    --有人来礼物
    self:addGlobalEvent(FriendEvent.FRIEND_LIST, function()
        self:updateFriendList(false)
        self:showRedPoint()
    end)
    --更新红点用
    self:addGlobalEvent(FriendEvent.Update_Red_Point, function()
        self:showRedPoint()
    end)

end

function FriendWindow:openRootWnd(type)
    type = type or FriendConst.Type.MyFriend
    self:setSelecteTab(type,true)
    self:showRedPoint()
    -- InviteCodeController:getInstance():sender19804()
end

--[[
    @desc: 切换标签页
    author:{author}
    time:2018-05-03 21:58:15
    --@type: 
    return
]]
function FriendWindow:selectedTabCallBack(type)
    type = type or FriendConst.Type.MyFriend
    if self.cur_type == type then return end
    self:changeFriendBtn(false)
    --切换到好友列表就把红点清掉
    self:setTabTips(false,FriendConst.Type.MyFriend)

    self.cur_type = type
    if self.pre_panel ~= nil then
        if self.pre_panel.setVisibleStatus then
            self.pre_panel:setVisibleStatus(false)
        end
    end

    self.pre_panel= self:createSubPanel(self.cur_type)
    if self.pre_panel ~= nil then
        if self.pre_panel.setVisibleStatus then
            self.pre_panel:setVisibleStatus(true)
        end
    end
    if self.cur_type == FriendConst.Type.MyFriend then 
        self.list_view:setContentSize(cc.size(self.scroll_width, 624))
        self.item_scrollview:resetSize(cc.size(self.scroll_width, 624))
    elseif self.cur_type == FriendConst.Type.Award then 
        self.list_view:setContentSize(cc.size(self.scroll_width, 684))
        self.item_scrollview:resetSize(cc.size(self.scroll_width, 684))
    else 
        self.list_view:setContentSize(cc.size(self.scroll_width, 734))
        self.item_scrollview:resetSize(cc.size(self.scroll_width, 734))
    end
    --更新列表数据
    self:updateFriendList(true)
end

function FriendWindow:createSubPanel(index)
    local panel = self.view_list[index]
    if panel == nil then
        if index == FriendConst.Type.MyFriend then
            panel = FriendListPanel.new()
        elseif index == FriendConst.Type.ApplyList then
            panel = FriendApplyPanel.new()
        elseif index == FriendConst.Type.Award then
            panel = FriendAwardPanel.new()
        elseif index == FriendConst.Type.BlackList then
            panel = FriendBlackPanel.new()
        end
        local size = self.container:getContentSize()
        panel:setPosition(cc.p(size.width/2,405))
        self.container:addChild(panel)
        self.view_list[index] = panel
    end
    if panel and panel.setCallFun then 
        panel:setCallFun(function(item_panel, is_del)
            if index == FriendConst.Type.MyFriend then  --删除好友
                is_del = is_del or false
                self:changeFriendBtn(is_del)
            end
        end)
    end
    return panel
end

--变更好友子项的按钮作用，true变为删除好友，false还原为私聊
function FriendWindow:changeFriendBtn(bool)
    self.del_friend_status = bool
    local item_list = self.item_scrollview:getItemList()
    if item_list then
        for k,v in pairs(item_list) do
            v:setDelStatus(bool)
        end
    end
end

function FriendWindow:getDelFriendStatus(  )
    return self.del_friend_status
end

function FriendWindow:updateFriendList(change_index, is_del)
    change_index = change_index or false
    self.rend_list = {}
    local list = {}
    if self.cur_type == FriendConst.Type.MyFriend then
        list = self.ctrl:getModel():getArray() or Array.New()
    elseif self.cur_type == FriendConst.Type.ApplyList then
        if change_index == true then
            self.ctrl:apply()    
            return
        else
            local array = Array.New()
            local apply_list = self.ctrl:getModel():getApplyList() or {}
            for i,v in pairs(apply_list) do 
                array:PushBack(v)
            end
            list = array
        end
        self:updateApplyNum()
    elseif self.cur_type == FriendConst.Type.Award then
        local array = self.ctrl:getModel():getArray() or Array.New()
        award_array = Array.New()
        for i=1,array:GetSize() do 
            local vo = array:Get(i-1) do 
                if vo and vo.is_draw == 1 then 
                    award_array:PushBack(vo)
                end
            end
        end
        list = award_array
    elseif self.cur_type == FriendConst.Type.BlackList then
        list = self.ctrl:getModel():getBlackArray() or Array.New()
    end

    if list and list.items then
        for k,v in pairs(list.items) do
            table_insert(self.rend_list, v)
        end
    end    
    self:showEmptyIcon(false)
    if #self.rend_list <= 0 then 
        self:showEmptyIcon(true)
    end
    self.pre_panel:setData(self.rend_list)

    -- 只有在我的好友界面才需要定住位置做更新
    if is_del == true and change_index == false and next(self.rend_list) ~= nil then
        self.item_scrollview:resetAddPosition(self.rend_list)
    else
        self.item_scrollview:setData(self.rend_list, nil, nil, self.cur_type)
    end
end

--更新申请数
function FriendWindow:updateApplyNum()
    if self.pre_panel and self.pre_panel.setApplyNum then 
        local num = self.ctrl:getModel():getApplyNum() or 0
        self.pre_panel:setApplyNum(num)
    end
end

function FriendWindow:setscheduleUpdate(status)
end

function FriendWindow:createItem(vo)    
end

--[[
    @desc: 设置标签页面板数据内容
    author:{author}
    time:2018-05-03 21:57:09
    return
]]
function FriendWindow:setPanelData()
end

--红点处理
function FriendWindow:showRedPoint()
    local award_num = self.ctrl:getModel():getAwardNum() or 0
    local appl_num =  self.ctrl:getModel():getApplyNum() or 0
    self:setTabTipsII(award_num,FriendConst.Type.Award)
    self:setTabTipsII(appl_num,FriendConst.Type.ApplyList)
    local list = {{bid=1,num = award_num},{bid=2,num = appl_num}}
    MainuiController:getInstance():setFunctionTipsStatus(MainuiConst.icon.friend, list)
end

--显示空白
function FriendWindow:showEmptyIcon(bool)
    if not self.empty_con and bool == false then return end
    if not self.empty_con then 
        local size = cc.size(200,200)
        self.empty_con = ccui.Widget:create()
        self.empty_con:setContentSize(size)
        self.empty_con:setPosition(cc.p(315,490))
        self.container:addChild(self.empty_con,100)

        local bg = createImage(self.empty_con, self.empty_res, size.width/2, size.height/2, cc.p(0.5,0.5), false)
        self.empty_label = createLabel(26,Config.ColorData.data_color4[274],nil,size.width/2,0,"",self.empty_con,0, cc.p(0.5,0))
    end
    local str = TI18N("暂无好友")
    if self.cur_type == FriendConst.Type.Award then 
        str = TI18N("暂无好友赠送")
    elseif self.cur_type == FriendConst.Type.ApplyList then 
        str = TI18N("暂无好友申请")
    elseif self.cur_type == FriendConst.Type.BlackList then 
        str = TI18N("黑名单列表为空")
    end
    self.empty_label:setString(str)
    self.empty_con:setVisible(bool)
end

function FriendWindow:close_callback()
    self.ctrl:openFriendWindow(false)
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end

    for i,v in pairs(self.view_list) do 
        if v and v["DeleteMe"] then
            v:DeleteMe()
        end
    end
    if self.role_vo ~= nil then
        if self.role_assets_event ~= nil then
            self.role_vo:UnBind(self.role_assets_event)
            self.role_assets_event = nil
        end
    end
    self.view_list = nil
end

-- --------------------------------------------------------------------
-- 竖版好友列表子项
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
FriendListItem = class("FriendListItem", function()
	return ccui.Widget:create()
end)

function FriendListItem:ctor(index,open_type)
	self.width = 610
    self.height = 114
	self.ctrl = FriendController:getInstance()
	self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(self.width,self.height))
    self:setAnchorPoint(cc.p(0.5, 0))
    self.index = index or 1
    self.item_list = {}
    self.is_del = false
    self.open_type = open_type or FriendConst.Type.MyFriend
	self:configUI()
end

function FriendListItem:clickHandler( ... )
	if self.call_fun then
   		self:call_fun(self.vo)
   	end
end
function FriendListItem:setTouchFunc( value )
	self.call_fun =  value
end

function FriendListItem:addCallBack( value )
	self.call_fun =  value
end

--[[
@功能:创建视图
@参数:
@返回值:
]]
function FriendListItem:configUI( ... )
    local csbPath = PathTool.getTargetCSB("friend/friend_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)
    self.root_wnd:setAnchorPoint(cc.p(0.5,0.5))
    self.root_wnd:setPosition(cc.p(self.width/2,self.height/2))

    self.main_panel = self.root_wnd:getChildByName("main_panel")
    --头像
    self.play_head = PlayerHead.new(PlayerHead.type.circle,nil,cc.size(96,96))
    self.main_panel:addChild(self.play_head)
    self.play_head:setPosition(cc.p(70,57))
    --名字
    self.role_name = createLabel(24,cc.c4b(0x76,0x45,0x19,0xff),nil,145,70,"",self.main_panel,0, cc.p(0,0))
    --战力
    self.role_power = createLabel(24,cc.c4b(0xb8,0x76,0x46,0xff),nil,145,20,"",self.main_panel,0, cc.p(0,0))
    --在线
    self.is_online = createLabel(24,cc.c4b(0xb8,0x76,0x46,0xff),nil,330,20,"",self.main_panel,0, cc.p(0,0))
end

function FriendListItem:setExtendData(open_type) 
    self.open_type = open_type
end

--[[
@功能:设置数据
@参数:
@返回值:
]]
function FriendListItem:setData(data)
    if data == nil then return end
    self:unBindEvent()
    self.vo = data
    -- if open_type then 
    --     self.open_type = open_type 
    -- end
    self:updateMessage()
    self.play_head:setHeadRes(data.face_id, false, LOADTEXT_TYPE, data.face_file, data.face_update_time)

    self.play_head:setHeadData(data)
    if data.lev then
        self.play_head:setLev(data.lev,cc.p(0,67))
    end
    self.play_head:addCallBack(function( )
        if self.open_type == FriendConst.Type.BlackList then
            ChatController:getInstance():openChatReportWindow(true, self.vo, 2)
        else
            self.ctrl:openFriendCheckPanel(true,self.vo)
        end
    end)
    if data.name then
        local name = data.name or ""
        if data.srv_id then 
            name = transformNameByServ(name, data.srv_id)
        end
        self.role_name:setString(name)
    end

    if data.power then
        local power = data.power or 0
        self.role_power:setString(TI18N("战力：")..power)
    end

    self:updateOnlineTime()
    self:addVoBindEvent()
end

--更新在线时间
function FriendListItem:updateOnlineTime()
    if not self.vo then return end
    if not self.is_online then return end
    local str 
    if self.vo.is_online and self.vo.is_online == 0 then 
        -- str = TI18N("离线")
        local time 
        if self.vo.login_out_time == 0 then
            time = TimeTool.day2s() * 4
        else
            local srv_time = GameNet:getInstance():getTime()
            time = srv_time - self.vo.login_out_time    
        end
        str = TimeTool.GetTimeFormatFriendShowTime(time)
    else
        str = TI18N("在线")
    end
    self.is_online:setString(str)
end

function FriendListItem:addVoBindEvent()
    -- 直接用数据去监听这样避免了刷新的频繁
    if type(self.vo) == "table" and self.vo and self.vo ~= nil and self.vo.Bind then
        if self.item_update_event == nil then
            self.item_update_event = self.vo:Bind(FriendVo.UPDATE_FRIEND_ATTR_LOGIN_OUT_TIME, function(vo)
                self:updateOnlineTime()
            end)
        end
    end
end


function FriendListItem:unBindEvent()
    if self.vo then
        if self.item_update_event ~= nil then
            self.vo:UnBind(self.item_update_event)
            self.item_update_event = nil
        end
        self.vo = nil
    end
end

--根据类型创建显隐相关控件
function FriendListItem:updateMessage()
    self:hideAllPanel()
    if self.open_type == FriendConst.Type.MyFriend then 
        self:updateMyFriend()
    elseif self.open_type == FriendConst.Type.Award then 
        self:updateAwardPanel()
    elseif self.open_type == FriendConst.Type.ApplyList then 
        self:updateApplyPanel()
    elseif self.open_type == FriendConst.Type.BlackList then  
        self:updateBlackPanel()
    elseif self.open_type == 5 then 
        self:updateRecommendPanel()
    end
end
function FriendListItem:hideAllPanel()
    if self.my_friend then 
        self.my_friend:setVisible(false)
    end
    if self.award_panel then 
        self.award_panel:setVisible(false)
    end
    if self.apply_panel then 
        self.apply_panel:setVisible(false)
    end
    if self.black_panel then 
        self.black_panel:setVisible(false)
    end
    if self.del_friend_btn then 
        self.del_friend_btn:setVisible(false)
    end

    if self.recommend_panel then 
        self.recommend_panel:setVisible(false)
    end
end
--更新好友列表的控件
function FriendListItem:updateMyFriend()
    self.is_del = self.ctrl:getFriendWndDelStatus()
    if not self.my_friend then 
        self.my_friend = ccui.Widget:create()
        self.my_friend:setContentSize(cc.size(self.width,self.height))
        self.my_friend:setAnchorPoint(cc.p(0.5,0.5))
        self.my_friend:setPosition(cc.p(self.width/2,self.height/2))
        self.main_panel:addChild(self.my_friend)
        --赠送按钮
        local res = PathTool.getResFrame("friend","friend_5")
        self.send_btn = createButton(self.my_friend, "", 445, 57,nil, res)
        self.send_btn:addTouchEventListener(function(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                if not self.vo then return end
                self.ctrl:sender_13316(0, self.vo.rid, self.vo.srv_id)
            end
        end)
        --私聊按钮
        local res = PathTool.getResFrame("common","common_1125")
        local str = TI18N("私聊")
        self.chat_btn = createButton(self.my_friend, str, 545, 57, cc.size(108,42), res, 18, Config.ColorData.data_color4[1])
        --self.chat_btn:getLabel():enableOutline(cc.c4b(0x76, 0x45, 0x19, 0xff),2)
        self.chat_btn:getLabel():enableShadow(Config.ColorData.data_new_color4[2],cc.size(0,-2),2)

        self.chat_btn:addTouchEventListener(function(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                ChatController:getInstance():openChatPanel(ChatConst.Channel.Friend,"friend",self.vo)
                --MainuiController:getInstance():openMianChatChannel(ChatConst.Channel.Friend,self.vo)
                FriendController:getInstance():openFriendWindow(false)
            end
        end)
    end

    if self.is_del == false then
        self.my_friend:setVisible(true)
    else
        if self.del_friend_btn then
            self.del_friend_btn:setVisible(true)
        end
    end

    if not self.vo then return end

    if self.vo.is_present and self.vo.is_present == 1 then 
        self.send_btn:setGrayAndUnClick(true)
    else
        self.send_btn:setGrayAndUnClick(false)
    end
end

--更新赠送的控件
function FriendListItem:updateAwardPanel()
    if not self.award_panel then 
        self.award_panel = ccui.Widget:create()
        self.award_panel:setContentSize(cc.size(self.width,self.height))
        self.award_panel:setAnchorPoint(cc.p(0.5,0.5))
        self.award_panel:setPosition(cc.p(self.width/2,self.height/2))
        self.main_panel:addChild(self.award_panel)

        --友情点标志
        local res = PathTool.getResFrame("friend","friend_2")
        self.friend_icon = createButton(self.award_panel, "", 432, 57, nil, res, 24, Config.ColorData.data_color4[1])
        self.friend_icon:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                if not self.vo then return end
                self.ctrl:sender_13316(1, self.vo.rid, self.vo.srv_id)
            end
        end)

        --赠送友情点按钮
        local res = PathTool.getResFrame("common","common_1125")
        local str = TI18N("回礼")
        self.return_btn = createButton(self.award_panel, str, 545, 57, cc.size(108,42), res, 18, Config.ColorData.data_color4[1])
        self.return_btn:getLabel():enableShadow(Config.ColorData.data_new_color4[2],cc.size(0,-2),2)

        self.return_btn:addTouchEventListener(function(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                if not self.vo then return end
                self.ctrl:sender_13316(0, self.vo.rid, self.vo.srv_id)
            end
        end)
    end
    self.return_btn:setGrayAndUnClick(false)

    --self.return_btn:getLabel():enableOutline(Config.ColorData.data_color4[277],2)
    self.friend_icon:setGrayAndUnClick(false)
    self.award_panel:setVisible(true)
   
    if not self.vo then return end
    if self.vo.is_present and self.vo.is_present == 1 then 
        self.return_btn:setGrayAndUnClick(true)
        --self.return_btn:getLabel():enableOutline(cc.c4b(0x79, 0x79, 0x79, 0xff),2)
    end
    if self.vo.is_draw and self.vo.is_draw == 0 then 
        self.friend_icon:setGrayAndUnClick(true)
    end
end
--更新申请列表的控件
function FriendListItem:updateApplyPanel()
    if not self.apply_panel then 
        self.apply_panel = ccui.Widget:create()
        self.apply_panel:setContentSize(cc.size(self.width,self.height))
        self.main_panel:addChild(self.apply_panel)
        self.apply_panel:setAnchorPoint(cc.p(0.5,0.5))
        self.apply_panel:setPosition(cc.p(self.width/2,self.height/2))
       

        --拒绝按钮
        local res = PathTool.getResFrame("common","common_1125")
        local str = TI18N("拒绝")
        self.cancel_btn = createButton(self.apply_panel, str, 435, 55, cc.size(108,42), res, 18, Config.ColorData.data_color4[1])
        --self.cancel_btn:getLabel():enableOutline(Config.ColorData.data_color4[277],2)
        self.cancel_btn:getLabel():enableShadow(Config.ColorData.data_new_color4[2],cc.size(0,-2),2)

        self.cancel_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                if not self.vo then return end
                self.ctrl:accept(self.vo.srv_id,self.vo.rid,0)
            end
        end)
        --接受按钮
        local res = PathTool.getResFrame("common","common_1125")
        local str = TI18N("接受")
        self.ok_btn = createButton(self.apply_panel, str, 545, 55, cc.size(108,42), res, 18, Config.ColorData.data_color4[1])
        --self.ok_btn:getLabel():enableOutline(Config.ColorData.data_color4[277],2)
        self.ok_btn:getLabel():enableShadow(Config.ColorData.data_new_color4[2],cc.size(0,-2),2)

        self.ok_btn:addTouchEventListener(function(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                if not self.vo then return end
                self.ctrl:accept(self.vo.srv_id,self.vo.rid,1)
            end
        end)
    end
    self.apply_panel:setVisible(true)

end

--更新黑名单的控件
function FriendListItem:updateBlackPanel()
    if not self.black_panel then 
        self.black_panel = ccui.Widget:create()
        self.black_panel:setContentSize(cc.size(self.width,self.height))
        self.black_panel:setAnchorPoint(cc.p(0.5,0.5))
        self.black_panel:setPosition(cc.p(self.width/2,self.height/2))
        self.main_panel:addChild(self.black_panel)


        --赠送友情点按钮
        local res = PathTool.getResFrame("common","common_1125")
        local str = TI18N("移除")
        self.del_btn = createButton(self.black_panel, str, 545, 57, cc.size(108,42), res, 18, Config.ColorData.data_color4[1])
        self.del_btn:getLabel():enableOutline(Config.ColorData.data_color4[277],2)
        self.del_btn:addTouchEventListener(function(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                if not self.vo then return end
                self.ctrl:deleteBlackList(self.vo.rid, self.vo.srv_id)
            end
        end)
    end
    self.black_panel:setVisible(true)

end



--更新推荐好友的控件
function FriendListItem:updateRecommendPanel()
    if not self.recommend_panel then 
        self.recommend_panel = ccui.Widget:create()
        self.recommend_panel:setContentSize(cc.size(self.width,self.height))
        self.recommend_panel:setAnchorPoint(cc.p(0.5,0.5))
        self.recommend_panel:setPosition(cc.p(self.width/2,self.height/2))
        self.main_panel:addChild(self.recommend_panel)


        --赠送友情点按钮
        local res = PathTool.getResFrame("common","common_1125")
        local str = TI18N("加为好友")
        self.add_btn = createButton(self.recommend_panel, str, 537, 57, cc.size(108,42), res, 18, Config.ColorData.data_color4[1])
        self.add_btn:addTouchEventListener(function(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                if not self.vo then return end
                self.ctrl:addOther(self.vo.srv_id,self.vo.rid)
                self.add_btn:setBtnLabel(TI18N("等待同意"))
                self.add_btn:setGrayAndUnClick(true)
                --self.add_btn:getLabel():enableOutline(cc.c4b(0x79, 0x79, 0x79, 0xff),2)
            end
        end)
    end
    self.add_btn:setGrayAndUnClick(false)
    self.add_btn:setBtnLabel(TI18N("加为好友"))
    self.add_btn:getLabel():enableShadow(Config.ColorData.data_new_color4[2],cc.size(0,-2),2)

    --self.add_btn:getLabel():enableOutline(Config.ColorData.data_color4[277],2)
    self.recommend_panel:setVisible(true)
end
function FriendListItem:isHaveData()
	if self.vo then
		return true
	end
	return false
end
function FriendListItem:setDelStatus(bool)
    if bool and bool == true then 
        self:hideAllPanel()
    end
    self.is_del = bool
    if not self.del_friend_btn and bool == false then return end 
    if not self.del_friend_btn then 
        local res = PathTool.getResFrame("common","common_1027")
        local str = TI18N("删除好友")
        self.del_friend_btn = createButton(self.main_panel, str, 525, 55, cc.size(127,53), res, 24, Config.ColorData.data_color4[1])
        self.del_friend_btn:getLabel():enableOutline(Config.ColorData.data_color4[277],2)
        self.del_friend_btn:addTouchEventListener(function(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                if not self.vo then return end
                self.ctrl:delOther( self.vo.srv_id, self.vo.rid )
            end
        end)
    end
    self.del_friend_btn:setVisible(bool)
    if bool == false then
        self:updateMyFriend()
    end
end

function FriendListItem:suspendAllActions()
end

function FriendListItem:getData( )
	return self.vo
end

function FriendListItem:DeleteMe()
    self:unBindEvent()
	self:removeAllChildren()
	self:removeFromParent()
end

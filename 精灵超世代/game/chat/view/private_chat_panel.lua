-- --------------------------------------------------------------------
-- 主聊天的私聊面板
--
-- @author: shuwen(必填, 创建模块的人员)
-- @editor: shuwen(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-5-5
-- --------------------------------------------------------------------
PrivateChatPanel = class("PrivateChatPanel", function()
    return ccui.Widget:create()
end)

function PrivateChatPanel:ctor(ctrl,parent)
	self.parent = parent
    self.parent:setCascadeOpacityEnabled(true)
    if parent then
        parent:addChild(self)
    end
	self.default_msg = "请输入信息"
    self.ctrl = ctrl
    self.model = self.ctrl:getModel()
    self.friendCtrl = FriendController:getInstance()
    self.friendModel = self.friendCtrl:getModel()
    self.design_height = 1280                       --美术设计的高度
    self.design_width = 720
    local parent_size = self.parent:getContentSize()
    self.size = cc.size(parent_size.width-10,parent_size.height-126)
    self.friend_list = {}
    self.select_friend = nil
    self:initCtrl()
    self:createRootWnd()
    self:configUI()
   
end

function PrivateChatPanel:createRootWnd()
	self:setCascadeOpacityEnabled(true)
	--self:setAnchorPoint(0.5, 0.5)
    self:setContentSize(self.size)
    --self:setPosition(cc.p(355,605))
    self:setAnchorPoint(0.5,0)
    self:setPosition(self.parent:getContentSize().width/2,108)
end

function PrivateChatPanel:configUI()
    self.bg1 = createScale9Sprite(PathTool.getResFrame("mainui","mainui_chat_1003"),0,0,LOADTEXT_TYPE_PLIST,self)
    self.bg1:setCapInsets(cc.rect(11, 10, 2, 2))
    self.bg1:setContentSize(cc.size(648,128))
    self.bg1:setAnchorPoint(0.5,1)
    self.bg1:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height-10))

	--好友列表
	self.friendScroll = createScrollView(self.bg1:getContentSize().width-20,self.bg1:getContentSize().height,10,self.bg1:getContentSize().height-3,self.bg1,ccui.ScrollViewDir.horizontal)
	self.friendScroll:setAnchorPoint(0,1)

    --聊天列表
    local size = cc.size(self.size.width-4,self.size.height-140)
    self.cose_list = NewCoseList.new(size,self,true)
    self.cose_list:setCascadeOpacityEnabled(true)
    self.cose_list:setPosition(0,0)
    self:addChild(self.cose_list,3)

    self:createFriend(self.model:getContectList2())
    --默认选中第一个
    if self.friend_list[1] then
    	self:initUserData(self.friend_list[1]:getData(),self.friend_list[1])
    end
     
end

function PrivateChatPanel:initCtrl()
    self:registerEvents(true)
    self.roleVo = RoleController:getInstance():getRoleVo()
    self.channel = ChatConst.Channel.Friend
end

function PrivateChatPanel:updateData(srv_id,rid)
	-- Debug.info(self.model:getContectList2())
	self:createFriend(self.model:getContectList2())
    if srv_id and rid then --有要选中的人
        local key = self:getFriendListData(srv_id,rid)
        if self.friend_list[key] then
            self:initUserData(self.friend_list[key]:getData(),self.friend_list[key])
        end
    else
        --默认选中第一个
        if self.friend_list[1] then
        	self:initUserData(self.friend_list[1]:getData(),self.friend_list[1])
        end
    end
     
end

function PrivateChatPanel:registerEvents(bool)
	if bool then 

        if not self.update_msg_evt then
            self.update_msg_evt = GlobalEvent:getInstance():Bind(EventId.CHAT_UPDATE_SELF, function(chatVo)
            	--Debug.info(chatVo)
            	if chatVo.flag == 2 then --对方对我说 有可能要新增上方列表
            		if self:checkIsInFriendList(chatVo.srv_id,chatVo.rid) then --在列表里就更新
            			if self.cose_list then
		                    self.cose_list:initData(self:getChatContent())
		                    self.cose_list:updateMsg()
		                end
		            else
		            	self:createFriend(self.model:getContectList2())
		            	if self.friend_list[1] then
					    	self:initUserData(self.friend_list[1]:getData(),self.friend_list[1])
					    end
            		end
            	else
            		if self.cose_list then
		                self.cose_list:initData(self:getChatContent())
		                self.cose_list:updateMsg()
		            end
                end
            end)
        end

        --增加好友
        if not self.update_friend_list then
            self.update_friend_list = GlobalEvent:getInstance():Bind(FriendEvent.UPDATE_APPLY,function()
                self:createFriend(self.model:getContectList2())
            end)
        end
        --删除拉黑好友
        if not self.del_friend_list then
            self.del_friend_list = GlobalEvent:getInstance():Bind(FriendEvent.FRIEND_DELETE,function()
                self:createFriend(self.model:getContectList2())
            end)
        end

        --删除了聊天记录
        if not self.update_cose_list then
        	self.update_cose_list = GlobalEvent:getInstance():Bind(ChatEvent.UpdatePrivateCoseList,function ( data )
        		if self.select_friend ~=nil then
        			local select_data = self.select_friend:getData()
        			if select_data.srv_id == data.srv_id and select_data.rid == data.rid then
        				self:createFriend(self.model:getContectList2())
        			end
        		end
        	end)
        end


        --GlobalEvent:getInstance():Fire(EventId.CHAT_CHANGE_SELF, true)
    else 
        --关闭监听
        if self.update_msg_evt then
            GlobalEvent:getInstance():UnBind(self.update_msg_evt)
            self.update_msg_evt = nil
        end

        if self.update_friend_list then
        	GlobalEvent:getInstance():UnBind(self.update_friend_list)
            self.update_friend_list = nil
        end

        if self.del_friend_list then
        	GlobalEvent:getInstance():UnBind(self.del_friend_list)
            self.del_friend_list = nil
        end

        if self.update_cose_list then
        	GlobalEvent:getInstance():UnBind(self.update_cose_list)
            self.update_cose_list = nil
        end

    end
end

function PrivateChatPanel:checkIsInFriendList(srv_id,rid)
	local count = 0
	for k,v in pairs(self.friend_list) do
		if v and v:getData() then
			local data = v:getData()
			if (data.srv_id.."_"..data.rid)==(srv_id.."_"..rid) then
				return true
			else
				count = count+1
				if count == #self.friend_list then
					return false
				end
			end
		end
	end
end

function PrivateChatPanel:getFriendListData( srv_id,rid )
    for k,v in pairs(self.friend_list) do
        if v and v:getData() then
            local data = v:getData()
            if (data.srv_id.."_"..data.rid)==(srv_id.."_"..rid) then
                return k
            end
        end
    end
end

function PrivateChatPanel:createFriend( data )
	--Debug.info(data)
 	if data == nil or tableLen(data) == 0 then 
        if self.friend_list then
            for k,v in pairs(self.friend_list) do
                if v["DeleteMe"] then
                    v:DeleteMe()
                end
            end
        end
        self.friend_list = {}
        self.friendScroll:removeAllChildren()
        self.cose_list:SetEnabled(false)
        self.select_friend = nil
        self.pre_key = nil
        self:showNoPeople(true)
    else
        self:showNoPeople(false)
        self.maxwidth = math.max(self.friendScroll:getContentSize().width,tableLen(data)*(PrivateChatFriendItem.Width+10))
        self.friendScroll:setInnerContainerSize(cc.size(self.maxwidth,self.friendScroll:getContentSize().height))
        self:clearItemList()
        local item 
        local index = 1
        for i,v in pairs(data) do
        	local temp_data = v
            if not self.friend_list[i] then
                local item = PrivateChatFriendItem.new(self.ctrl)
                self.friend_list[index] = item   
            end
            item = self.friend_list[index]
            self.friendScroll:addChild(item)
            item:setData(temp_data)
            item:setCallBack(function ( sender,event_type )
        		self:initUserData(sender:getData(),sender)
        	end)
            item:setPosition(70+(PrivateChatFriendItem.Width+10)*(index-1),self.friendScroll:getContentSize().height/2)  
            --self:initUserData(self.friend_list[1]:getData(),self.friend_list[1])
            index = index+1        
        end
    end
end

function PrivateChatPanel:showNoPeople(bool)
    if not self.no_people then
            --没人说话
        local res = PathTool.getEmptyMark()
        self.no_img = createImage(self, res, self.cose_list:getContentSize().width/2+1.5, 396, cc.p(0.5,0.5), false, 1, false)
        self.no_img:setScale(1.2)
        self.no_people =  createLabel(24,Config.ColorData.data_new_color4[6],nil,self.cose_list:getContentSize().width/2+1.5, self.no_img:getPositionY()-90,TI18N("暂时没有人说话"),self)
        self.no_people:setAnchorPoint(cc.p(0.5,0.5))
    end
    self.no_people:setVisible(bool)
    self.no_img:setVisible(bool)

    if not self.jumpToFriend then
        self.jumpToFriend = PrivateChatFriendItem.new(self.ctrl)
        self.jumpToFriend:setAnchorPoint(0,1)
        self.jumpToFriend:setPosition(self.friendScroll:getPositionX(),self.friendScroll:getPositionY()-3)
        self.jumpToFriend:setSelect(true)
        self.jumpToFriend:setEmptyStatus(true)
        self.bg1:addChild(self.jumpToFriend)
    end
    self.jumpToFriend:setVisible(bool)
end

function PrivateChatPanel:clearItemList(  )
    if self.friend_list then
        for k, item in pairs(self.friend_list) do
            if (not tolua.isnull(item)) and item.clearInfo then
                item:clearInfo()
            end
        end
    end

end

function PrivateChatPanel:initUserData(data,item)
	--Debug.info(data)
	if self.select_friend == nil then
		self.select_friend = item
	else
		self.select_friend:setSelect(false)
		self.select_friend = item
	end
	self.select_friend:setSelect(true)
    self.user_data = data
    if not self.user_data then return end
    self.key = self.user_data.srv_id .. "_" .. self.user_data.rid
    FriendController:getInstance():delPriCount(self.key)
    --self.friend_name:setString(StringFormat("与 <div fontSize=20 fontColor='#462305'>{0}</div> 聊天中", self.user_data.name or "error name"))
    --显示聊天记录
    if self.key ~= self.pre_key then
        self:initContent()  
        self.ctrl:noticeReader(self.user_data.srv_id,self.user_data.rid)
	    self.model:delRedList(self.user_data.srv_id,self.user_data.rid)
	else
		if self.cose_list then
            self.cose_list:initData(self:getChatContent())
            self.cose_list:updateMsg()
            self.ctrl:noticeReader(self.user_data.srv_id,self.user_data.rid)
		    self.model:delRedList(self.user_data.srv_id,self.user_data.rid)
        end
    end 
    self.pre_key = self.key  

    PromptController:getInstance():getModel():removePromptDataByTpye(PromptTypeConst.Private_chat)

end

function PrivateChatPanel:getCurSelectItem(  )
	return self.select_friend 
end

function PrivateChatPanel:getUserData(  )
	return self.user_data or {}
end

--初始化读取聊天内容
function PrivateChatPanel:initContent()
    local chat_list = self:getChatContent()
    self.cose_list:reset()
    self.cose_list:createMsg(chat_list)
end

function PrivateChatPanel:getKey( ... )
    return self.key
end

function PrivateChatPanel:getCostList(  )
	return self.cose_list
end

-- 获取聊天内容
function PrivateChatPanel:getChatContent()
	if self.user_data == nil then return end
    local key,data_list = self.ctrl.model:getFriendMsg(self.roleVo.srv_id,self.roleVo.rid,self.user_data.srv_id,self.user_data.rid)
    local array = Array.New()
    --Debug.info(data_list)
    if data_list and next(data_list)~=nil then
	    for i=1, #data_list do
	        if data_list[i].msg ~= "KaKa" then
	           array:PushBack(data_list[i])
	        end
	    end
	end
    return array
end

function PrivateChatPanel:setVisibleStatus( bool )
	self:setVisible(bool)
	self:registerEvents(bool)
	if bool == false then
		if self.select_friend ~= nil then
			self.select_friend:setSelect(false)
			self.select_friend = nil
		end
	end
	
    self.cose_list:SetEnabled(bool)
end


function PrivateChatPanel:closeView()
	if self.friend_list then
        for k,v in pairs(self.friend_list) do
            if v["DeleteMe"] then
                v:DeleteMe()
            end
        end
    end
    self.friend_list = {}
    self.friendScroll:removeAllChildren()

    if self.jumpToFriend and self.jumpToFriend["DeleteMe"] then
        self.jumpToFriend:DeleteMe()
    end
    self.jumpToFriend = nil

	self.ctrl:clearTarCacheData() -- 清掉私聊缓存数据
    ChatController:getInstance().model:writeToDefaultXML()
    ChatMgr:getInstance():showReportUI(false)
    self:registerEvents(false)
    RefController:getInstance():closeView()
    if self.cose_list then
       self.cose_list:SetEnabled(false)
       self.cose_list = nil
    end
end


-- --------------------------------------------------------------------
-- 主聊天的私聊面板单个人物
--
-- @author: shuwen(必填, 创建模块的人员)
-- @editor: shuwen(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-5-5
-- --------------------------------------------------------------------
PrivateChatFriendItem = class("PrivateChatFriendItem", function()
    return ccui.Widget:create()
end)

PrivateChatFriendItem.Width = 139
PrivateChatFriendItem.Height = 122

function PrivateChatFriendItem:ctor(ctrl) 
	self.ctrl = ctrl
	self:retain()
	self:setCascadeOpacityEnabled(true)
	self:setAnchorPoint(0.5, 0.5)
	self.size = cc.size(PrivateChatFriendItem.Width,PrivateChatFriendItem.Height)
    self:setContentSize(self.size)
	self:configUI()	
end

function PrivateChatFriendItem:configUI(  )
	self.bg =  createImage(self, PathTool.getResFrame("mainui","mainui_chat_1001"), 0, 0, cc.p(0,0),true)
    self.bg:setScale9Enabled(true)
    self.bg:setCapInsets(cc.rect(12, 15, 2, 2))
    self.bg:setCascadeOpacityEnabled(true)
    self.bg:setContentSize(self.size)
    self.bg:setTouchEnabled(true)

    self.head_icon = PlayerHead.new(PlayerHead.type.circle)
    self.head_icon:setTouchEnabled(false)
    self.head_icon:getHeadLayer():setScale(0.9)
    self.head_icon:setAnchorPoint(cc.p(0.5,0.5))
    self.head_icon:setPosition(71,61)
    self.bg:addChild(self.head_icon)

    self.name = createLabel(20,cc.c4b(0xfe,0xee,0xcf,0xff),cc.c4b(0x1f,0x13,0x09,0xff),self.bg:getContentSize().width/2,self.head_icon:getPositionY()-self.head_icon:getContentSize().height*0.8/2+10,"sss",self.bg,1)
    self.name:setAnchorPoint(cc.p(0.5, 1))

    self.select = createScale9Sprite(PathTool.getResFrame("mainui","mainui_chat_1002"),self.bg:getContentSize().width/2,self.bg:getContentSize().height/2,LOADTEXT_TYPE_PLIST,self.bg)
    self.select:setAnchorPoint(0.5,0.5)
    self.select:setContentSize(self.size)
    --self.select:setVisible(false)

    self.close_btn = CustomButton.New(self.bg, PathTool.getResFrame("common","common_1028"))
    self.close_btn:setAnchorPoint(cc.p(0.5,0.5))
    self.close_btn:setScale(0.7)
    self.close_btn:setPosition(cc.p(128,100))

	self:registerEvent()
	--self:setData()
end

function PrivateChatFriendItem:registerEvent()
	handleTouchEnded(self.close_btn, function()
		local confrim = function()
            if self.data then
                local roleVo = RoleController:getInstance():getRoleVo()
                ChatController:getInstance():getModel():deleteCache(roleVo.srv_id, roleVo.rid, self.data.srv_id, self.data.rid)
                GlobalEvent:getInstance():Fire(ChatEvent.UpdatePrivateCoseList,self.data)
            end
        end

        CommonAlert.show(TI18N("确定要删除该好友的所有聊天记录吗?"), TI18N("删除"), confrim, TI18N("取消"),nil)
    end)

    self.head_icon:addCallBack(function (  )
    	if self.call_back ~= nil then
            self.call_back(self)
        end
    end)
end

function PrivateChatFriendItem:setCallBack( call_back )
	self.call_back = call_back
end

function PrivateChatFriendItem:setSelect( bool )
	self.select:setVisible(not bool)
end

function PrivateChatFriendItem:setData( data )
	--Debug.info(data)
	self.data = data
	self.key = data.srv_id .. "_" .. data.rid
	self.head_icon:setLev(data.lev)
    --私聊上方的头像
    self.head_icon:setHeadRes(data.face_id, false, LOADTEXT_TYPE, data.face_file, data.face_update_time)
	self.name:setString(data.name)
end

--跳转用
function PrivateChatFriendItem:setEmptyStatus( status )
    if status then
        self.close_btn:setVisible(false)
        self.head_icon:setVisible(false)
        self.name:setVisible(false)
        if not self.addIcon then
            self.addIcon = createButton(self.bg, "", 70, 60, cc.size(62,64), PathTool.getResFrame("common","common_90026"))
        end
        self.addIcon:setVisible(true)
        self.addIcon:addTouchEventListener(function(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                ChatController:getInstance():closeChatUseAction()
                FriendController:getInstance():openFriendWindow(true)
            end
        end)
    end
end

function PrivateChatFriendItem:getData(  )
	return self.data
end

function PrivateChatFriendItem:getKey(  )
	return self.key or 0
end

function PrivateChatFriendItem:clearInfo()
    self:removeFromParent() 
end

function PrivateChatFriendItem:DeleteMe()
    if self.head_icon then 
        self.head_icon:DeleteMe()
    end
	self:removeAllChildren()
	self:removeFromParent()
	self:release()
end
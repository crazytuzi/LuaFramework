
FriendController = FriendController or class("FriendController",BaseController)
local FriendController = FriendController
local json = require "cjson"

function FriendController:ctor()
	FriendController.Instance = self
	self.model = FriendModel:GetInstance()
	self:AddEvents()
	self:RegisterAllProtocal()
end

function FriendController:dctor()
end

function FriendController:GetInstance()
	if not FriendController.Instance then
		FriendController.new()
	end
	return FriendController.Instance
end

function FriendController:RegisterAllProtocal(  )
	-- protobuff的模块名字，用到pb一定要写
	self.pb_module_name = "pb_1126_friend_pb"
    self:RegisterProtocal(proto.FRIEND_LIST, self.HandleFirendList)
    self:RegisterProtocal(proto.FRIEND_CONTACT, self.HandleContact)
    self:RegisterProtocal(proto.FRIEND_REQUEST, self.HandleAddFriend)
    self:RegisterProtocal(proto.FRIEND_REQUEST_LIST, self.HandleApplyList)
    self:RegisterProtocal(proto.FRIEND_ACCEPT, self.HandleAccept)
    self:RegisterProtocal(proto.FRIEND_REFUSE, self.HandleRefuse)
    self:RegisterProtocal(proto.FRIEND_DELETE, self.HandleDeleteFriend)
    self:RegisterProtocal(proto.FRIEND_ADDBLACK, self.HandleAddBlack)
    self:RegisterProtocal(proto.FRIEND_DELBLACK, self.HandleDelBlack)
    self:RegisterProtocal(proto.FRIEND_DELENEMY, self.HandleDelEnemy)
    self:RegisterProtocal(proto.FRIEND_RECOMMEND, self.HandleRecommend)
    self:RegisterProtocal(proto.FRIEND_SEARCH, self.HandleSearch)
    self:RegisterProtocal(proto.FRIEND_UPDATE, self.HandleUpdate)
    self:RegisterProtocal(proto.FRIEND_SEND_FLOWER,self.HandleSendFlower)
    self:RegisterProtocal(proto.FRIEND_RECEIVE_FLOWER, self.HandleReceiveFlower)
    self:RegisterProtocal(proto.FRIEND_FEEDBACK, self.HandleFeedback)
    self:RegisterProtocal(proto.FRIEND_ONLINE, self.HandleOnline)
    self:RegisterProtocal(proto.FRIEND_CONTACT_UPDATE, self.HandleContactUpdate)
    self:RegisterProtocal(proto.FRIEND_FLOWER, self.HandleFlower)
end

function FriendController:AddEvents()
	-- --请求基本信息
	local function call_back(roles)
		local panel = lua_panelMgr:GetPanelOrCreate(AddFriendPanel)
		panel:SetData(roles)
		panel:Open()
	end
	self.model:AddListener(FriendEvent.GetRecommends, call_back)

	local function call_back(data)
		if data.channel_id == enum.CHAT_CHANNEL.CHAT_CHANNEL_P2P then
			self.model:AddMessage(data)
			self.model:Brocast(FriendEvent.UpdateMessage, data)
			GlobalEvent:Brocast(FriendEvent.UpdateMessage)
		end
	end
	GlobalEvent:AddListener(ChatEvent.ReceiveMessage, call_back)

	local function call_back(sender, item_id)
		local panel = lua_panelMgr:GetPanelOrCreate(SendFlowerPanel)
		panel:SetData(sender, item_id)
		panel:Open()
	end
	self.model:AddListener(FriendEvent.ReceiveFlower, call_back)

	local function call_back(role, type_id)
		if type_id == 1 then  --回吻
			local panel = lua_panelMgr:GetPanelOrCreate(KissbackPanel)
			panel:SetData(role)
			panel:Open()
		elseif type_id == 2 then --好人卡
			local panel = lua_panelMgr:GetPanelOrCreate(GoodManPanel)
			panel:SetData(role)
			panel:Open()
		end
	end
	self.model:AddListener(FriendEvent.FeedBack, call_back)

	local function call_back(role)
		local panel = lua_panelMgr:GetPanelOrCreate(SendGiftPanel)
		if type(role) == "table" then
			panel:SetData(role)
		end
		panel:Open()
	end
	GlobalEvent:AddListener(FriendEvent.OpenSendGiftPanel, call_back)

	local function call_back()
		lua_panelMgr:GetPanelOrCreate(AddFriendPanel):Open()
	end
	GlobalEvent:AddListener(FriendEvent.OpenAddFriendPanel, call_back)
end

-- overwrite
function FriendController:GameStart()
	self:RequestFriendList()
	self:RequestApplyList()
	local messages = CacheManager:GetInstance():GetString("chat_message", "")
	if messages ~= "" then
		self.model.messages = json.decode(messages)
	end
end

----请求基本信息
function FriendController:RequestFriendList()
	local pb = self:GetPbObject("m_friend_list_tos")
	self:WriteMsg(proto.FRIEND_LIST,pb)
end

----服务的返回信息
function FriendController:HandleFirendList(  )
	local data = self:ReadMsg("m_friend_list_toc")
	self.model:SetFriendList(data.friends)
	GlobalEvent:Brocast(FriendEvent.HandleFriendList)
end

--最近联系人
function FriendController:RequestContact( )
	local pb = self:GetPbObject("m_friend_contact_tos")
	self:WriteMsg(proto.FRIEND_CONTACT,pb)
end

function FriendController:HandleContact(  )
	local data = self:ReadMsg("m_friend_contact_toc")
	self.model:SetContactList(data.friends)
	self.model:Brocast(FriendEvent.GetFriendList)
	self.model:ClearMessages()
end

--好友请求
function FriendController:RequestAddFriend(role_id)
	local pb = self:GetPbObject("m_friend_request_tos")
	pb.role_id = role_id
	self:WriteMsg(proto.FRIEND_REQUEST,pb)
end

function FriendController:HandleAddFriend()
	local data = self:ReadMsg("m_friend_request_toc")
	Notify.ShowText(ConfigLanguage.Mail.ApplySuccss)
end

--好友请求列表
function FriendController:RequestApplyList()
	local pb = self:GetPbObject("m_friend_request_list_tos")
	self:WriteMsg(proto.FRIEND_REQUEST_LIST,pb)
end

function FriendController:HandleApplyList()
	local data = self:ReadMsg("m_friend_request_list_toc")
	self.model:SetApplyList(data.lists)

	self.model:Brocast(FriendEvent.ApplyList)
	GlobalEvent:Brocast(FriendEvent.ApplyList)
end

--接受请求
function FriendController:RequestAccept(role_id)
	local pb = self:GetPbObject("m_friend_accept_tos")
	pb.role_id = role_id or 0
	self:WriteMsg(proto.FRIEND_ACCEPT,pb)
end

function FriendController:HandleAccept()
	local data = self:ReadMsg("m_friend_accept_toc")
	local role_ids = data.role_ids
	local fail_ids = data.fail_ids
	for i=1, #role_ids do
		self.model:RemoveFromApplyList(role_ids[i])
		local content = "We are now friends with each other! Let's play together~~"
		ChatController:GetInstance():RequestSendChat(enum.CHAT_CHANNEL.CHAT_CHANNEL_P2P, 0, content, nil,role_ids[i])
	end

	self.model:Brocast(FriendEvent.HandleAccept)
	GlobalEvent:Brocast(FriendEvent.HandleAccept)
end

--拒绝
function FriendController:RequestRefuse(role_id)
	local pb = self:GetPbObject("m_friend_refuse_tos")
	pb.role_id = role_id or 0
	self:WriteMsg(proto.FRIEND_REFUSE,pb)
end

function FriendController:HandleRefuse(role_id)
	local data = self:ReadMsg("m_friend_refuse_toc")
	local role_ids = data.role_ids
	for i=1, #role_ids do
		self.model:RemoveFromApplyList(role_ids[i])
	end

	self.model:Brocast(FriendEvent.HandleAccept)
	GlobalEvent:Brocast(FriendEvent.HandleAccept)
end

--删除好友
function FriendController:RequestDeleteFriend(role_ids)
	local pb = self:GetPbObject("m_friend_delete_tos")
	for i=1, #role_ids do 
		pb.role_ids:append(role_ids[i])
	end
	self:WriteMsg(proto.FRIEND_DELETE,pb)
end

function FriendController:HandleDeleteFriend()
	local data = self:ReadMsg("m_friend_delete_toc")
	local role_ids = data.role_ids
	for i=1, #role_ids do
		self.model:RemoveFriend(role_ids[i])
	end

	self.model:Brocast(FriendEvent.DeleteFriends)
end


--拉黑
function FriendController:RequestAddBlack(role_id)
	local pb = self:GetPbObject("m_friend_addblack_tos")
	pb.role_id = role_id
	self:WriteMsg(proto.FRIEND_ADDBLACK,pb)
end

function FriendController:HandleAddBlack()
	local data = self:ReadMsg("m_friend_addblack_toc")
	local role_id = data.role_id
	self.model:RemoveFriend(role_id)
	self.model:RemoveFromApplyList(role_id)

	self.model:Brocast(FriendEvent.HandleAccept)
	GlobalEvent:Brocast(FriendEvent.HandleAccept)
end

--移除黑名单
function FriendController:RequestDelBlack(role_id)
	local pb = self:GetPbObject("m_friend_delblack_tos")
	pb.role_id = role_id
	self:WriteMsg(proto.FRIEND_DELBLACK,pb)
end

function FriendController:HandleDelBlack()
	local data = self:ReadMsg("m_friend_delblack_toc")
	local role_id = data.role_id
	self.model:RemoveBlack(role_id)
end

--删除仇人
function FriendController:RequestDelEnemy(role_id)
	local pb = self:GetPbObject("m_friend_delenemy_tos")
	pb.role_id = role_id
	self:WriteMsg(proto.FRIEND_DELENEMY,pb)
end

function FriendController:HandleDelEnemy()
	local data = self:ReadMsg("m_friend_delenemy_toc")
	local role_id = data.role_id
end

--推荐好友
function FriendController:RequestRecommend()
	local pb = self:GetPbObject("m_friend_recommend_tos")
	self:WriteMsg(proto.FRIEND_RECOMMEND,pb)
end

function FriendController:HandleRecommend()
	local data = self:ReadMsg("m_friend_recommend_toc")
	local roles = data.roles

	self.model:Brocast(FriendEvent.GetRecommends, roles)
end

--搜索好友
function FriendController:RequestSearch(name)
	local pb = self:GetPbObject("m_friend_search_tos")
	pb.name = name
	self:WriteMsg(proto.FRIEND_SEARCH,pb)
end

function FriendController:HandleSearch()
	local data = self:ReadMsg("m_friend_search_toc")
	local role = data.base

	local roles = {}
	table.insert(roles, role)
	self.model:Brocast(FriendEvent.GetRecommends, roles)
end

--更新
function FriendController:HandleUpdate()
	local data = self:ReadMsg("m_friend_update_toc")
	local add = data.add
	local del = data.del
	self.model:SetFriendList(add)
	for i=1, #del do
		self.model:RemoveFriend(del[i])
		self.model:RemoveBlack(del[i])
	end

	self.model:Brocast(FriendEvent.UpdateFrinds)
end

--送花
function FriendController:RequestSendFlower(role_id, item_id)
	local pb = self:GetPbObject("m_friend_send_flower_tos")
	pb.role_id = role_id
	pb.item_id = item_id
	self:WriteMsg(proto.FRIEND_SEND_FLOWER,pb)
end 

function FriendController:HandleSendFlower()
	local data = self:ReadMsg("m_friend_send_flower_toc")
	Notify.ShowText("Flower sent")
end


function FriendController:HandleReceiveFlower()
	local data = self:ReadMsg("m_friend_receive_flower_toc")
	local sender = data.sender
	local flower = data.flower

	self.model:Brocast(FriendEvent.ReceiveFlower, sender, flower)
end

--回吻
function FriendController:RequestFeedback(role_id, type_id)
	local pb = self:GetPbObject("m_friend_feedback_tos")
	pb.role_id = role_id
	pb.type = type_id
	self:WriteMsg(proto.FRIEND_FEEDBACK,pb)
end

function FriendController:HandleFeedback()
	local data = self:ReadMsg("m_friend_feedback_toc")
	if data.to_self then
		Notify.ShowText("Sent")
		self.model:Brocast(FriendEvent.FeedBackClose)
	else
		local role = data.base
		local type_id = data.type
		self.model:Brocast(FriendEvent.FeedBack, role, type_id)
	end
end

--上下线
function FriendController:HandleOnline()
	local data = self:ReadMsg("m_friend_online_toc")
	dump(data)
	local role_id = data.role_id
	local name = data.name
	local is_online = data.is_online
	local role =  RoleInfoModel.GetInstance():GetMainRoleData()
	if role.marry ~= 0 then
		if name == role.mname then
			local str = "<color=#f53b3b>Your spouse has come online</color>"
			if is_online == false then
				str = "<color=#f53b3b>Your spouse has gone offline</color>"
			end
			Notify.ShowText(str)
		end
	end
	self.model:UpdatePFriendOnlie(role_id, is_online)
end

--添加联系人
function FriendController:AddContact(role_id)
	local pb = self:GetPbObject("m_friend_contact_update_tos")
	pb.role_id = role_id
	self:WriteMsg(proto.FRIEND_CONTACT_UPDATE, pb)
	self.model.need_open_panel = true
end

function FriendController:HandleContactUpdate()
	local data = self:ReadMsg("m_friend_contact_update_toc")
	local add = data.add

	self.model:UpdateContact(add)
	if self.model.need_open_panel then
		GlobalEvent:Brocast(MailEvent.OpenMailPanel, 1, add.base.id)
		self.model.need_open_panel = nil
	end
	self.model:Brocast(FriendEvent.UpdateFrinds)
end

function FriendController:HandleFlower()
	local data = self:ReadMsg("m_friend_flower_toc")
	self:PlayEffect(data.flower)
end

function FriendController:PlayEffect(item_id)
	if SettingModel:GetInstance():GetHideFlower() then
		return
	end
	local TopTransform = LayerManager.Instance:GetLayerByName(LayerManager.LayerNameList.Top)
	local itemcfg = Config.db_item[item_id]
	if itemcfg.effect ~= "" then
		if self.effect then
			return
		end
		local function call_back()
			self.effect = nil
		end
		self.effect = UIEffect(TopTransform, tonumber(itemcfg.effect), nil, nil, call_back)
	end
end


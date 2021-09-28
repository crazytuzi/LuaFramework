RegistModules("Gay/FriendModel")
RegistModules("Gay/FriendCommonPanel")

RegistModules("Gay/View/FriendPanel")
RegistModules("Gay/View/AddFriPanel")
RegistModules("Gay/View/AddFriItem")
RegistModules("Gay/View/FriendItem")
RegistModules("Gay/View/LookInfoPanel")
RegistModules("Gay/FriendConst")

RegistModules("ChatNew/Vo/ChatVo")
RegistModules("Gay/View/ChatInputPrivate")
RegistModules("Gay/View/ContentLeftPrivate")
RegistModules("Gay/View/ContentRightPrivate")
RegistModules("Gay/View/TypeSelectComPrivate")
RegistModules("Gay/View/TypeSelectPanelPrivate")

FriendController = BaseClass(LuaController)

function FriendController:GetInstance()
	if FriendController.inst == nil then
		FriendController.inst = FriendController.New()
	end
	return FriendController.inst
end

function FriendController:__init()
	self.model = FriendModel:GetInstance()
	if self.isInited then return end
	resMgr:AddUIAB("Gay")
	resMgr:AddUIAB("ChatNew")
	self.isInited = true

	self:Config()
	self:RegistProto()

end

function FriendController:Config()
	self:C_FriendList(1)
end

--注册协议
function FriendController:RegistProto()
	self:RegistProtocal("S_ApplyAddFriend")
	self:RegistProtocal("S_FriendList")
	self:RegistProtocal("S_ApplyMsgList")
	self:RegistProtocal("S_DeleteFriend")
	self:RegistProtocal("S_SerachFriend")
	self:RegistProtocal("S_ApplyDeal")
end	

function FriendController:Open(index)
	if index then
		self.model.isFriend = false
	else
		self.model.isFriend = true
	end

	if not self.friendCommonPanel or not self.friendCommonPanel.isInited then
		self.friendCommonPanel = FriendCommonPanel.New(index)
	end
	self.friendCommonPanel:Open( 0, index)
end

function FriendController:IsFriendChat(chatVo)
	if not chatVo then return end
	self.model.selectInd = 1
	self.model.isFriend = false
	for i,v in ipairs(self.model.friendList) do
	 	if v.playerId == chatVo.sendPlayerId then
	 		self.model.isFriend = true
	 		self.model.selectInd = i            -------
	 		break
	 	end
	end

	if self.model.isFriend == false then
		local isInrecent = false
		for i,v in ipairs(self.model.recentChatList) do
			if v.sendPlayerId == chatVo.sendPlayerId then
				isInrecent = true
				self.model.selectInd = i        -------
			end
		end
		if isInrecent == false then
			table.insert(self.model.recentChatList, chatVo)
			self.model.selectInd = #self.model.recentChatList
		end
		self:Open(1)
		self.model:DispatchEvent(FriendConst.RECENTCHAT)
	else
		self:Open()
	end

end

-------------------------------------接收消息--------------------------------------
-----------------------------------------------------------------------------------
function FriendController:S_ApplyAddFriend(buffer)                          --被申请的人收到的申请人的信息消息
	local msg = self:ParseMsg(friend_pb.S_ApplyAddFriend(), buffer)
	local isFri = false
	for i,v in ipairs(self.model.friendList) do
		if v.playerId == msg.applyMsg.playerId then
			isFri = true
			break
		end
	end
	if not isFri then
		GlobalDispatcher:DispatchEvent(EventName.MAINUI_RED_TIPS , {moduleId = FunctionConst.FunEnum.social , state = true})                                         --红点提示
		self.model:DispatchEvent(FriendConst.ApplyRed)
	end
end

function FriendController:S_FriendList(buffer)                              --接收不同类型好友列表信息1、好友 2、 3、 推荐
	local msg = self:ParseMsg(friend_pb.S_FriendList(), buffer)
	if msg.type == 1 then
		local onlineTab = {}
		local offlineTab = {}
		self.model.friendList = {}
		SerialiseProtobufList( msg.friendList, function ( item )       
			if tonumber(tostring(item.exitTime)) == 0 then
				table.insert(onlineTab, item)
			else
				table.insert(offlineTab, item)
			end
		end )
		table.sort(offlineTab, function(a,b)       
			return a.exitTime > b.exitTime
		end)
		for i,v in ipairs(offlineTab) do
		  	table.insert(onlineTab, v)
		end
		for i,v in ipairs(onlineTab) do
		  	table.insert(self.model.friendList, v)
		end  
		self.model:DispatchEvent(FriendConst.FRIENDLIST_LOAD)
		GlobalDispatcher:DispatchEvent(EventName.FriendListRefresh)    --好友列表 全局事件
	elseif msg.type == 3 then
		self.model.recommendList = {}
		SerialiseProtobufList( msg.friendList, function ( item )         
			table.insert(self.model.recommendList, item )
		end )
		self.model:DispatchEvent(FriendConst.RECOMMENDLIST_LOAD)
	end
end

function FriendController:S_ApplyMsgList(buffer)                            --接收申请列表信息
	local msg = self:ParseMsg(friend_pb.S_ApplyMsgList(), buffer)
	self.model.applyList = {}
	SerialiseProtobufList( msg.applyMsgList, function ( item )
		local isFri = false
		for i,v in ipairs(self.model.friendList) do
			if v.playerId == item.playerId then
				isFri = true
				break
			end
		end
		if not isFri then
			table.insert(self.model.applyList, item )
		end
	end )
	table.sort(self.model.applyList,function(a,b)
		return a.time > b.time                             
	end)
	local length = #self.model.applyList
	if length > 10 then
		for m = length, 11, -1 do 
			table.remove(self.model.applyList,m)
		end
	end	
	if #self.model.applyList > 0 then
		GlobalDispatcher:DispatchEvent(EventName.MAINUI_RED_TIPS , {moduleId = FunctionConst.FunEnum.social , state = true}) 
		self.model:DispatchEvent(FriendConst.ApplyRed)
	else
		GlobalDispatcher:DispatchEvent(EventName.MAINUI_RED_TIPS , {moduleId = FunctionConst.FunEnum.social , state = false})
		self.model:DispatchEvent(FriendConst.CloseApplyRed) 
	end
	self.model:DispatchEvent(FriendConst.APPLYLIST_LOAD) 
end

function FriendController:S_DeleteFriend(buffer)                            --接收删除好友
	local msg = self:ParseMsg(friend_pb.S_DeleteFriend(), buffer)
	for i = #self.model.friendList, 1 ,-1 do
		if self.model.friendList[i].playerId == msg.deletePlayerId then
			table.remove(self.model.friendList, i)
			break
		end
	end
	local mainPlayerId = SceneModel:GetInstance():GetMainPlayer().playerId
	local sessionId = self.model:GetSesstionId(msg.deletePlayerId, mainPlayerId)
	for k,v in pairs(self.model.chatList) do
		if k == sessionId then
			self.model.chatList[k] = nil
			break
		end
	end
	for i,v in ipairs(self.model.redList) do
		if v == msg.deletePlayerId then
			table.remove(self.model.redList, i)
			break
		end
	end

	self.model:DispatchEvent(FriendConst.DELETEFRIEND_TRUE)
end

function FriendController:S_SerachFriend(buffer)                            --接收搜索的玩家信息
	local msg = self:ParseMsg(friend_pb.S_SerachFriend(), buffer)
	self.model.recommendList = {}
	table.insert(self.model.recommendList, msg.friendMsg)
	self.model:DispatchEvent(FriendConst.RECOMMENDLIST_LOAD)
end

function FriendController:S_ApplyDeal(buffer)                               --申请人和接收人都接收到的好友消息处理
	local msg = self:ParseMsg(friend_pb.S_ApplyDeal(), buffer)
	if msg.state == 1 and #self.model.friendList < 50 then
		table.insert(self.model.friendList, msg.friendMsg)
		for i,v in ipairs(self.model.recentChatList) do
			if v.sendPlayerId == msg.friendMsg.playerId then
				table.remove(self.model.recentChatList, i)
				for j,k in ipairs(self.model.redListMo) do
					if k == v.sendPlayerId then
						table.remove(self.model.redListMo, j)
						table.insert(self.model.redList, v.sendPlayerId)
						break
					end
				end
				break
			end
		end
		self.model:DispatchEvent(FriendConst.ADDFRIEND_TRUE)
		self.model:DispatchEvent(FriendConst.IsNullApplyList)

	end

end

-------------------------------------发送消息--------------------------------------
-----------------------------------------------------------------------------------
function FriendController:C_ApplyAddFriend(applyPlayerId)    --发送申请添加好友（申请人编号）
	local msg = friend_pb.C_ApplyAddFriend()
	msg.applyPlayerId = applyPlayerId
	self:SendMsg("C_ApplyAddFriend", msg)
end

function FriendController:C_FriendList(type)                 --发送获取好友列表（好友列表类型：1 好友  2 江湖好友  3 推荐玩家）
	local msg = friend_pb.C_FriendList()
	msg.type = type
	self:SendMsg("C_FriendList", msg)
end

function FriendController:C_ApplyMsgList()                   --发送获取申请消息列表
	self:SendEmptyMsg(friend_pb, "C_ApplyMsgList")
end

function FriendController:C_DeleteFriend(deletePlayerId)     --发送删除好友（要删除的玩家编号）
	local msg = friend_pb.C_DeleteFriend()
	msg.deletePlayerId = deletePlayerId
	self:SendMsg("C_DeleteFriend", msg)
end

function FriendController:C_SerachFriend(playerName)         --发送搜索玩家（要搜索的玩家名字string)
	local msg = friend_pb.C_SerachFriend()
	msg.playerName = playerName
	self:SendMsg("C_SerachFriend", msg)
end

function FriendController:C_ApplyDeal(applyPlayerId,state)   --发送好友申请消息处理（申请人编号，回复请求状态 0 拒绝  1 同意）
	local msg = friend_pb.C_ApplyDeal()
	msg.applyPlayerId = applyPlayerId
	msg.state = state
	self:SendMsg("C_ApplyDeal", msg)
end

function FriendController:C_DeleteAllApply()              --发送清空申请列表消息
	self:SendEmptyMsg(friend_pb, "C_DeleteAllApply")
end

function FriendController:C_AgreeAllApply()              --发送全部同意消息
	self:SendEmptyMsg(friend_pb, "C_AgreeAllApply")
end


function FriendController:__delete()
	FriendController.inst = nil
	if self.model then
		self.model:Destroy()
	end
	self.model=nil
	if self.friendCommonPanel and self.friendCommonPanel.isInited then
		self.friendCommonPanel:Destroy()
	end
	self.friendCommonPanel = nil
end
-- --------------------------------------------------------------------
-- --------------------------------------------------------------------
InviteCodeController = InviteCodeController or BaseClass(BaseController)

function InviteCodeController:config()
    self.model = InviteCodeModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function InviteCodeController:getModel()
    return self.model
end

function InviteCodeController:registerEvents()

end

function InviteCodeController:registerProtocals()
	self:RegisterProtocal(19800, "handle19800")
	self:RegisterProtocal(19801, "handle19801")
	self:RegisterProtocal(19802, "handle19802")
	self:RegisterProtocal(19803, "handle19803")
	self:RegisterProtocal(19804, "handle19804")
	self:RegisterProtocal(19805, "handle19805")
	self:RegisterProtocal(19807, "handle19807")
	self:RegisterProtocal(19811, "handle19811")
	self:RegisterProtocal(19812, "handle19812")
	self:RegisterProtocal(10929, "handle10929")
	self:RegisterProtocal(10930, "handle10930")
end

function InviteCodeController:requestProto()
	self:sender19800()
	self:sender19804()
	self:sender19802()
	self:sender19811()
end
--个人邀请码
function InviteCodeController:sender19800()
	self:SendProtocal(19800, {})
end
function InviteCodeController:handle19800(data)
	self.model:setInviteCode(data.code)
	GlobalEvent:getInstance():Fire(InviteCodeEvent.Get_InviteCode_Event)
end
--绑定邀请码
function InviteCodeController:sender19801(code)
	local proto = {}
	proto.code = code
	self:SendProtocal(19801, proto)
end
function InviteCodeController:handle19801(data)
	message(data.msg)
	GlobalEvent:getInstance():Fire(InviteCodeEvent.BindCode_Invite_Event,data)
end
--奖励信息
function InviteCodeController:sender19804()
	self:SendProtocal(19804, {})
end
function InviteCodeController:handle19804(data)
	self.model:setInviteCodeTeskData(data.list)
	-- self:getInviteCodeRepoint(data.list)
	GlobalEvent:getInstance():Fire(InviteCodeEvent.InviteCode_My_Event)
end

--奖励领取
function InviteCodeController:sender19805(id)
	local proto = {}
	proto.id = id
	self:SendProtocal(19805, proto)
end
function InviteCodeController:handle19805(data)
	message(data.msg)
	if data.code == 1 then
		self.model:setUpdataInviteCodeTeskData(data)
		GlobalEvent:getInstance():Fire(InviteCodeEvent.InviteCode_My_Event)
	end
end
--绑定角色列表(已邀请的好友)
function InviteCodeController:sender19802()
	self:SendProtocal(19802, {})
end
function InviteCodeController:handle19802(data)
	self.model:setAlreadyFriendData(data.list)
	GlobalEvent:getInstance():Fire(InviteCodeEvent.InviteCode_BindRole_Event)
end
--绑定角色列表（推送）
function InviteCodeController:handle19803(data)
	self.model:setUpdataAlreadyFriendData(data)
	GlobalEvent:getInstance():Fire(InviteCodeEvent.InviteCode_BindRole_Updata_Event)
end

--自己所绑定的角色
function InviteCodeController:sender19807()
	self:SendProtocal(19807, {})
end
function InviteCodeController:handle19807(data)
	self.model:addFriendChatData(data)
end
--回归奖励信息
function InviteCodeController:sender19811()
	self:SendProtocal(19811, {})
end
function InviteCodeController:handle19811(data)
	-- dump(data,"******* handle19811 *******")
	self.model:setReturnReawrdList(data)
	GlobalEvent:getInstance():Fire(InviteCodeEvent.Return_InviteCode_Event)
end
--回归奖励领取
function InviteCodeController:sender19812(id)
	local proto = {}
	proto.id = id
	self:SendProtocal(19812, proto)
end
function InviteCodeController:handle19812(data)
	message(data.msg)
	if data.code == 1 then
		self.model:setUpdataReturnReawrdList(data)
		GlobalEvent:getInstance():Fire(InviteCodeEvent.Return_InviteCode_Event)
	end
end

--点击分享发送协议，主要是有活动的任务处理
function InviteCodeController:sender10929()
	self:SendProtocal(10929)
end
function InviteCodeController:handle10929(data)
	message(data.msg)
end

function InviteCodeController:handle10930(data)
	self.model:setOpenServerTime(data)
end

function InviteCodeController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end
--
-- @Author: chk
-- @Date:   2018-12-18 20:48:47
--
FactionCareerApplyLogItemSettor = FactionCareerApplyLogItemSettor or class("FactionCareerApplyLogItemSettor",BaseItem)
local FactionCareerApplyLogItemSettor = FactionCareerApplyLogItemSettor

function FactionCareerApplyLogItemSettor:ctor(parent_node,layer)
	self.abName = "faction"
	self.assetName = "FactionCareerApplyLogItem"
	self.layer = layer

	self.model = FactionModel:GetInstance()
	FactionCareerApplyLogItemSettor.super.Load(self)
end

function FactionCareerApplyLogItemSettor:dctor()
	if self.role_icon1 then
		self.role_icon1:destroy()
		self.role_icon1 = nil
	end
end

function FactionCareerApplyLogItemSettor:LoadCallBack()
	self.nodes = {
		"icon_bg/icon",
		"name",
		"status",
		"chatBtn",
		"giveGiftBtn",
		"vipTex",
		"chatBtn/stText",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()
	self.vipTex = GetText(self.vipTex)
	self.stTex = GetText(self.stText)
	self:UpdateItem()
end

function FactionCareerApplyLogItemSettor:AddEvent()

end

function FactionCareerApplyLogItemSettor:IsSelf(role_id)
	if role_id == self.data.base.id then
		return true
	else
		return false
	end
end


function FactionCareerApplyLogItemSettor:SetData(data)
	self.data = data
end

function FactionCareerApplyLogItemSettor:UpdateItem()
	local timeStr = TimeManager.Instance:GetDifTime(self.data.time,TimeManager.Instance:GetServerTime())
	local statusStr = "(" .. timeStr .. ")"
	if self.data.log == enum.GUILD_LOG.GUILD_LOG_JOIN then
		statusStr = ConfigLanguage.Faction.EnterFaction .. "\n" .. statusStr
	elseif self.data.log == enum.GUILD_LOG.GUILD_LOG_JOIN then
		statusStr = ConfigLanguage.Faction.EnterFaction .. "\n" .. statusStr
	elseif self.data.log == enum.GUILD_LOG.GUILD_LOG_APPROVE then
		statusStr = string.format(ConfigLanguage.Faction.AppointCareet,enumName.GUILD_POST[self.data.post])  .. "\n" .. statusStr
	end
	self.status:GetComponent('Text').text = statusStr

	self.name:GetComponent('Text').text = self.data.base.name
	self.vipTex.text = "V"..self.data.base.viplv
	--lua_resMgr:SetImageTexture(self,self.icon:GetComponent('Image'),"main_image","img_role_head_" ..
	--		self.data.base.career,true)
	if self.role_icon1 then
		self.role_icon1:destroy()
		self.role_icon1 = nil
	end
	local param = {}
	local function uploading_cb()
		--  logError("回调")
	end
	--param["is_squared"] = true
	--param["is_hide_frame"] = true
	param["size"] = 65
	param["uploading_cb"] = uploading_cb
	param["role_data"] = self.data.base
	self.role_icon1 = RoleIcon(self.icon)
	self.role_icon1:SetData(param)

	local id = RoleInfoModel.GetInstance():GetMainRoleId()
	SetVisible(self.chatBtn, id ~= self.data.base.id)
	
	if FriendModel.Instance:IsFriend(self.data.base.id) then
		local function call_back()
			FriendController:GetInstance():AddContact(self.data.base.id)
		end
		AddClickEvent(self.chatBtn.gameObject,call_back)
		self.stTex.text = "Greet"
	else
		self.stTex.text = "Add as friend" 
		local function call_back()
			local my_name = "<color=#ff9600>" .. self.data.base.name .. "</color>"
			local str = string.format(msgno[140008].desc, my_name)
			str = string.trim(str)
			GlobalEvent:Brocast(ChatEvent.AutoUnionSendTextMsg, str)
			FriendController:GetInstance():RequestAddFriend(self.data.base.id)
		end
		AddClickEvent(self.chatBtn.gameObject,call_back)	
	end 
	

	local function call_back()

		GlobalEvent:Brocast(FriendEvent.OpenSendGiftPanel,self.data.base)
	end
	AddClickEvent(self.giveGiftBtn.gameObject,call_back)
end

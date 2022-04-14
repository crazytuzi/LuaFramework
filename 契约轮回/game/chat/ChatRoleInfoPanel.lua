--
-- @Author: chk
-- @Date:   2018-09-05 10:18:11
--
ChatRoleInfoPanel = ChatRoleInfoPanel or class("ChatRoleInfoPanel",BasePanel)
local ChatRoleInfoPanel = ChatRoleInfoPanel

function ChatRoleInfoPanel:ctor()
	self.abName = "chat"
	self.assetName = "ChatRoleInfoPanel"
	self.layer = "UI"

	self.events = {}
	self.model = ChatModel:GetInstance()
	self.channel = ChatModel.PrivateChannel

end

function ChatRoleInfoPanel:dctor(  )
	for i, v in pairs(self.events) do
		self.model:RemoveListener(v)
	end
end

function ChatRoleInfoPanel:LoadCallBack( )
	self.nodes = {
		"bg/mask",
		"bg/nameBG/name",
		"bg/lv/lvValue",
		"bg/faction/factionValue",
		"bg/achievement /achievementValue",
		"bg/title/titleValue",
		"bg/honor/honorValue",
		"bg/friendness/friendnessValue",

		"bg/btns/CheckInfoBtn",
		"bg/btns/CheckSpaceBtn",
		"bg/btns/PrivateChatBtn",
		"bg/btns/AddFriendBtn",
		"bg/btns/ChatBtn",
		"bg/btns/JuBaoBtn",
		"bg/btns/VisitHomeBtn",
		"bg/btns/GiveGiftBtn",
		"bg/btns/ApplyFactionBtn",

		"bg/attackBtn",
		"bg/teamBtn",
	}

	self:GetChildren(self.nodes)
	self:AddEvent()

	self:SetInfo()
end

function ChatRoleInfoPanel:AddEvent( ... )
	local function call_back()
		self:Close()
	end
	AddClickEvent(self.mask.gameObject,call_back)

	local function call_back( ... )
		
	end

	AddClickEvent(self.CheckInfoBtn.gameObject,call_back)


	local function call_back( ... )
		
	end

	AddClickEvent(self.CheckSpaceBtn.gameObject,call_back)


	local function call_back( ... )
		
	end

	AddClickEvent(self.PrivateChatBtn.gameObject,call_back)


	local function call_back( ... )
		
	end

	AddClickEvent(self.AddFriendBtn.gameObject,call_back)


	local function call_back( ... )
		
	end

	AddClickEvent(self.ChatBtn.gameObject,call_back)


	local function call_back( ... )
		
	end

	AddClickEvent(self.JuBaoBtn.gameObject,call_back)


	local function call_back( ... )
		
	end

	AddClickEvent(self.VisitHomeBtn.gameObject,call_back)


	local function call_back( ... )
		
	end

	AddClickEvent(self.GiveGiftBtn.gameObject,call_back)


	local function call_back( ... )
		FactionController.GetInstance():RequestApplyEnterFaction(guild_id)
	end

	AddClickEvent(self.ApplyFactionBtn.gameObject,call_back)


	local function call_back( ... )
		-- body
	end

	AddClickEvent(self.attackBtn.gameObject,call_back)


	local function call_back( ... )
		
	end

	AddClickEvent(self.teamBtn.gameObject,call_back)


	self.events[#self.events+1] = self.model:AddListener(FactionEvent.ApplySucess,handler(self,self.DealApplyEnterFaction))
	-- self.events[#self.events+1] = self.model:AddListener()
end

function ChatRoleInfoPanel:Open(...)
	ChatRoleInfoPanel.super.Open(self)
	local param = {...}
	self.roleInfo = param[1]
end


function ChatRoleInfoPanel:DealApplyEnterFaction( ... )
	
end

function ChatRoleInfoPanel:DealCheckInfo( ... )
	-- body
end

function ChatRoleInfoPanel:SetInfo( ... )
	GetText(self.name).text  = self.roleInfo.name
	GetText(self.lvValue).text = self.roleInfo.level
	GetText(self.factionValue).text = self.roleInfo.guild_name
	GetText(self.achievementValue).text = self.roleInfo.achievementValue
	GetText(self.titleValue).text = self.roleInfo.title
	GetText(self.honorValue).text = self.roleInfo.honor
	GetText(self.friendnessValue).text = self.roleInfo.friendness
end


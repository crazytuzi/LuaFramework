require("game/pet/pet_data")
require("game/pet/pet_view")
PetCtrl = PetCtrl or BaseClass(BaseController)

function PetCtrl:__init()
	if PetCtrl.Instance then
		print_error("[PetCtrl] Attemp to create a singleton twice !")
	end
	PetCtrl.Instance = self

	self.data = PetData.New()
	self.view = PetView.New(ViewName.PetView)

	self:RegisterAllProtocols()
end

function PetCtrl:__delete()
	self.data:DeleteMe()
	self.view:DeleteMe()
	PetCtrl.Instance = nil
end

function PetCtrl:GetView()
	return self.view
end

function PetCtrl:RegisterAllProtocols()
	-- self:RegisterProtocol(SCLittlePetAllInfo, "OnSCLittlePetAllInfo")--
	-- self:RegisterProtocol(SCLittlePetSingleInfo, "OnSCLittlePetSingleInfo")--
	self:RegisterProtocol(SCLittlePetChangeInfo, "OnSCLittlePetChangeInfo")
	-- self:RegisterProtocol(SCLittlePetChouRewardList, "OnSCLittlePetChouRewardList") --
	-- self:RegisterProtocol(SCLittlePetNotifyInfo, "OnSCLittlePetNotifyInfo")--
	self:RegisterProtocol(SCLittlePetFriendInfo, "OnSCLittlePetFriendInfo")
	self:RegisterProtocol(SCLittlePetFriendPetListInfo, "OnSCLittlePetFriendPetListInfo")
	self:RegisterProtocol(SCLittlePetInteractLog, "OnSCLittlePetInteractLog")
	self:RegisterProtocol(SCLittlePetRename, "OnSCLittlePetRename")
end

function PetCtrl:OnSCLittlePetAllInfo(protocol)
	self.data:OnSCLittlePetAllInfo(protocol)
	local tips_pet_info_view = TipsCtrl.Instance:GetPetInfoView()

	if tips_pet_info_view:IsOpen() then
		tips_pet_info_view:Reload()
	end

	if self.data:IsFreeOperation() then
		PetForgeView.Instance:SetCurrentPetInfo(self.data:GetAllInfoList().pet_list[1])
		PetForgeView.Instance:ClearSelectList()
		self.data:SetFreeOperation(false)
	end

	if self.view:GetShowIndex() == 2 then
		PetForgeView.Instance:Reload()
	end

	if self.view:GetShowIndex() == 1 then
		PetParkView.Instance:FlushPet()
	end
end

function PetCtrl:OnSCLittlePetSingleInfo(protocol)
	-- print_log("######OnSCLittlePetSingleInfo####",protocol)
	-- print_warning(self.view:GetShowIndex())
	self.data:OnSCLittlePetSingleInfo(protocol)
	local pet_forge_view = PetForgeView.Instance
	if self.view:GetShowIndex() == 2 and not self.data:IsFreeOperation() then
			pet_forge_view:Reload()
	end
end

function PetCtrl:OnSCLittlePetChangeInfo(protocol)
	-- print_warning("####OnSCLittlePetChangeInfo#####",protocol)
	self.data:OnSCLittlePetChangeInfo(protocol)
	PetForgeView.Instance:OnFlush()
end

--抽奖信息
function PetCtrl:OnSCLittlePetChouRewardList(protocol)
	-- print_log("#########抽奖信息#######",protocol,self.data:GetIsMask())
	self.data:OnSCLittlePetChouRewardList(protocol)
	local achieve_view = PetAchieveView.Instance
	if achieve_view ~= nil then
		achieve_view:OnReward()
	end

	if ViewManager.Instance:IsOpen(ViewName.PetView) then
		self.view:PlayerDataChangeCallback("gold")
		self.view:PlayerDataChangeCallback("bind_gold")
	end
end

function PetCtrl:OnSCLittlePetNotifyInfo(protocol)
	if protocol.param1 > self.data:GetAllInfoList().score then
		self.add_youshan_value = protocol.param1 - self.data:GetAllInfoList().score
	end

	self.data:OnSCLittlePetNotifyInfo(protocol)
	local pet_park_view = PetParkView.Instance
	if pet_park_view ~= nil then
		if protocol.param_type == LITTLE_PET_NOTIFY_INFO_TYPE.LITTLE_PET_NOTIFY_INFO_FEED_DEGREE then
			local pet_attr_view = TipsCtrl.Instance:GetPetAttributeView()
			if pet_attr_view:IsOpen() then
				pet_attr_view:Reload()
			end
		elseif protocol.param_type == LITTLE_PET_NOTIFY_INFO_TYPE.LITTLE_PET_NOTIFY_INFO_INTERACT_TIMES then
			if self.view:GetShowIndex() == 1 then
				local str = string.format(Language.SysRemind.AddItem, "友善值", self.add_youshan_value )
				TipsCtrl.Instance:ShowFloatingLabel(str)
				PetParkView.Instance:FlushYouShanValue()
			end
		elseif protocol.param_type == LITTLE_PET_NOTIFY_INFO_TYPE.LITTLE_PET_NOTIFY_INFO_SCORE then
			local tips_pet_exchange_view = TipsCtrl.Instance:GetPetExchangeView()
			if tips_pet_exchange_view:IsOpen() then
				tips_pet_exchange_view:FlushMoney()
			end
			if self.view:GetShowIndex() == 1 then
				PetParkView.Instance:FlushYouShanValue()
			end
		--elseif protocol.param_type == LITTLE_PET_NOTIFY_INFO_TYPE.LITTLE_PET_NOTIFY_INFO_FREE_CHOU_TIMESTAMP then
		end
	end
end

function PetCtrl:OnSCLittlePetFriendInfo(protocol)
	self.data:OnSCLittlePetFriendInfo(protocol)
	PetParkView.Instance:FlushFriendClick()
end

function PetCtrl:OnSCLittlePetFriendPetListInfo(protocol)
	self.data:OnSCLittlePetFriendPetListInfo(protocol)
	local pet_park_view = PetParkView.Instance
	if pet_park_view ~= nil then
		pet_park_view:GoFriendPark()
	end
end

--互动返回
function PetCtrl:OnSCLittlePetInteractLog(protocol)
	-- print_log("########OnSCLittlePetInteractLog#####",protocol)
	self.data:OnSCLittlePetInteractLog(protocol)
	TipsCtrl.Instance:ShowPetYouShanView(protocol)
end

function PetCtrl:OnSCLittlePetRename(protocol)
	-- print_warning(protocol)
	self.data:OnSCLittlePetRename(protocol)
	if self.view:GetShowIndex() == 2 then
		PetForgeView.Instance:FLushItemData()
		PetForgeView.Instance:SetCurPetName()
	end
	local pet_park_view = PetParkView.Instance
	if pet_park_view ~= nil then
		pet_park_view:FlushPet()
	end
end

function PetCtrl:SendLittlePetREQ(opera_type, param1, param2, param3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSLittlePetREQ)
	send_protocol.opera_type = opera_type
	send_protocol.param1 = param1
	send_protocol.param2 = param2
	send_protocol.param3 = param3
	send_protocol:EncodeAndSend()
end

function PetCtrl:SendLittlePetRename(index, pet_name)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSLittlePetRename)
	send_protocol.index = index
	send_protocol.pet_name = pet_name
	send_protocol:EncodeAndSend()
end
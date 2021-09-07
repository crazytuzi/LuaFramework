DiedMailData = DiedMailData or BaseClass()

function DiedMailData:__init()
	if DiedMailData.Instance ~= nil then
		ErrorLog("[DiedMailData] Attemp to create a singleton twice !")
	end
	DiedMailData.Instance = self
	self.killer_list = {}
end

function DiedMailData:__delete()
	DiedMailData.Instance = nil
end

function DiedMailData:SetDieMailData(protocol)
	self.yesterday_die_times = protocol.yesterday_die_times
	self.killer_list = protocol.yesterday_killer_item_list
end

function DiedMailData:GetTotalDieTimes()
	return self.yesterday_die_times
end

function DiedMailData:GetKillerList()
	local kill_list = {}
	for i = 1,DIE_MAIL.SEND_KILLER_ITEM_COUNT do
		if next(self.killer_list) and self.killer_list[i].uid > 0 then
			kill_list[i] = self.killer_list[i]
		end
	end
	return kill_list
end


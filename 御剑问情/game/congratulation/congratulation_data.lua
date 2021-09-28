CongratulationData = CongratulationData or BaseClass()
function CongratulationData:__init()
	if CongratulationData.Instance then
		print_error("CongratulationData] Attemp to create a singleton twice !")
	end
	CongratulationData.Instance = self
	self.congratulation_list = {}
	self.temp_list = {}	
	self.tips_ison = false
	self.is_show_he_icon = true
end

function CongratulationData:__delete()
	self.congratulation_list = {}
	CongratulationData.Instance = nil
	self.tips = {}
	self.is_show_he_icon = true
end

function CongratulationData:PushCongratulation(cell)
	table.insert(self.congratulation_list,cell)
	table.insert(self.temp_list,cell)
end

function CongratulationData:GetCongratulationlist()
	return self.congratulation_list
end

function CongratulationData:PushTipCongratulation(cell)
	self.tips = cell
end

function CongratulationData:GetTips()
	return self.tips
end

function CongratulationData:SetAuto(ison, auto_type)
	self.tips_ison = ison
	self.tips_auto_type = auto_type
end

function CongratulationData:GetIsAuto()
	return self.tips_ison 
end

function CongratulationData:GetAutoType()
	return self.tips_auto_type
end

function CongratulationData:ClearTips()
	self.tips = {}
end

function CongratulationData:GetTempList()
	return self.temp_list
end

function CongratulationData:ClearTempList()
	self.temp_list = {}
end

function CongratulationData:GetExperience()
	local base = 2500
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	local const = 50
	return (my_level + const) * base
end

--主界面上的贺字图标是否能显示，距离上一次显示需要20秒
function CongratulationData:GetCanShowHe()
	return self.is_show_he_icon 
end

function CongratulationData:SetCanShowHe(is_show_he_icon)
	self.is_show_he_icon = is_show_he_icon
end


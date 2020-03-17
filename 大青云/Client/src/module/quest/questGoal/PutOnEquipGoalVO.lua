--[[
任务目标：穿装备
2015年5月26日18:27:48
haohu
]]

_G.PutOnEquipGoalVO = setmetatable( {}, {__index = QuestGoalVO} )

function PutOnEquipGoalVO:GetType()
	return QuestConsts.GoalType_PutOnEquip;
end

function PutOnEquipGoalVO:CreateGoalParam()
	local questVO = self.questVO
	if not questVO then return end
	local cfg = questVO:GetCfg()
	return split( cfg.questGoals, "#" )
end

function PutOnEquipGoalVO:DoGoal()
	local func = function() self:PutOnEquip() end
	-- UIEquipConfirm:Open(self:GetEquipId(), func)
	UICollectionShow:Open(func)
	-- UIConfirm:Open( '将刚刚获得的武器装备上', func )
end

function PutOnEquipGoalVO:PutOnEquip()
	local bagVO = BagModel:GetBag( BagConsts.BagType_Bag );
	if bagVO then
		local itemId = self:GetEquipId()
		for _, item in pairs( bagVO:GetItemList() ) do
			if item:GetTid() == itemId then
				BagController:EquipItem( BagConsts.BagType_Bag, item:GetPos() );
				return
			end
		end
	end
end

function PutOnEquipGoalVO:GetEquipId()
	local prof = MainPlayerModel.humanDetailInfo.eaProf
	local equipTab = self.goalParam
	for _, equipStr in pairs( equipTab ) do
		local vo = split(equipStr, ',')
		local equipProf = tonumber( vo[2] )
		if equipProf == prof then
			print(vo[1]) --男魔220000300
			return tonumber( vo[1] )
		end
	end
end

function PutOnEquipGoalVO:GetGoalLabel(size, color)
	local format = "<font size='%s' color='%s'>%s</font>";
	if not size then size = 14 end;
	if not color then color = "#ffffff" end;
	local strSize = tostring( size );
	local name = self:GetLabelContent();
	return string.format( format, strSize, color, name );
end

function PutOnEquipGoalVO:GetLabelContent()
	local questCfg = self.questVO:GetCfg();
	return questCfg.unFinishLink
end
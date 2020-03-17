--[[
    Created by IntelliJ IDEA.
    推荐挂机
    User: Hongbin Yang
    Date: 2016/12/5
    Time: 16:40
   ]]


_G.QuestHangVO = setmetatable({}, { __index = QuestVO })

QuestHangVO.targetId = -1;
QuestHangVO.monsterId = 0;
QuestHangVO.monsterPos = 0;
function QuestHangVO:GetType()
	return QuestConsts.Type_Hang;
end

function QuestHangVO:GetGoalType()
	return 0;
end

function QuestHangVO:GetId()
	return self.id;
end

function QuestHangVO:GetState()
	return self.state;
end

function QuestHangVO:CreateQuestGoal()
	return nil;
end

function QuestHangVO:GetTitleLabel()
	local lv = MainPlayerModel.humanDetailInfo.eaLevel;
	for k, v in pairs(t_guaji) do
		if lv >= v.minlv and lv <= v.maxlv then
			if k ~= self.targetId then
				self.targetId = k;
				local monsterArr = GetPoundTable(v.monsterPos);
				local monster = monsterArr[math.random(1, #monsterArr)];
				local monsterInfo = GetCommaTable(monster);
				local id = toint(monsterInfo[1])
				local pos = toint(monsterInfo[2])
				self.monsterId = id;
				self.monsterPos = pos;
			end
		end
	end
	local cfg = t_monster[self.monsterId];
	if not cfg then return ""; end
	local monsterName = cfg.name;
	local monsterLv = cfg.level;
	local txtTitle = string.format(StrConfig["quest943"], string.format( "<u><font color='"..QuestColor.COLOR_GREEN.."'>%s</font></u>", monsterName), monsterLv);
	return txtTitle;
end

function QuestHangVO:GetPlayRefresh()
	return false;
end

function QuestHangVO:GetPlayRewardEffect()
	return false;
end

function QuestHangVO:HasContent()
	return false;
end

function QuestHangVO:OnTitleClick()
	--寻路打怪
	local pos = QuestUtil:GetQuestPos( self.monsterPos )
	if not pos then return end
	local completeFunc = function()
		AutoBattleController:SetAutoHang();
	end
	MainPlayerController:DoAutoRun( pos.mapId, _Vector3.new( pos.x, pos.y, 0 ), completeFunc );
end

function QuestHangVO:GetTeleportType()
	return MapConsts.Teleport_Hang;
end

-- 是否可传送
function QuestHangVO:CanTitleTeleport()
	return true
end

function QuestHangVO:GetTeleportPos()
	return QuestUtil:GetQuestPos( self.monsterPos );
end
function QuestHangVO:DoGoal(auto)
	AutoBattleController:SetAutoHang();
end
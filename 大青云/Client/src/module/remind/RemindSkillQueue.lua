--[[
技能升级提示
zhangshuhui
2015年6月1日17:19:44
]]
_G.RemindSkillQueue = RemindQueue:new();

RemindSkillQueue.isShow = false;
function RemindSkillQueue:GetType()
	return RemindConsts.Type_Skill;
end;

function RemindSkillQueue:GetLibraryLink()
	return "RemindSkill";
end;

function RemindSkillQueue:GetPos()
	return 2;
end;

--是否显示
function RemindSkillQueue:GetIsShow()
	return self.isShow;
end


function RemindSkillQueue:GetShowIndex()
	return 3;
end;

function RemindSkillQueue:GetBtnWidth()
	return 60;
end
function RemindSkillQueue:GetTConstsID()
	return 217;
end

function RemindSkillQueue:CheckCondition()
	if SkillFunc:CheckCanLvlUp() then
		self:AddData(1);
		return true;
	else
		self:AddData(0);
		return false;
	end
end
function RemindSkillQueue:AddData(data) --1 显示 0 关闭
	if data == 0 then
		self.isShow = false
		self:HideButton()
		return
	end

	self.isShow = true
	self:RefreshData();
end;

function RemindSkillQueue:ClearData()
	self.isShow = false;
	self:RefreshData()
end

function RemindSkillQueue:DoClick()
	FuncManager:OpenFunc(FuncConsts.Skill,true);
	self.isShow = false;
	self:RefreshData()
end;

--鼠标移上
function RemindSkillQueue:DoRollOver()
	TipsManager:ShowBtnTips(string.format(StrConfig["skill50"]));
end
--鼠标移出处理
function RemindSkillQueue:DoRollOut()
	TipsManager:Hide();
end
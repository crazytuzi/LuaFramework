--[[
技能升级提示
zhangshuhui
2015年6月1日17:19:44
]]
_G.RemindSkillJueXueQueue = RemindQueue:new();

RemindSkillJueXueQueue.isShow = false;
function RemindSkillJueXueQueue:GetType()
	return RemindConsts.Type_SkillJueXue;
end;

function RemindSkillJueXueQueue:GetLibraryLink()
	return "RemindSkillJueXue";
end;

function RemindSkillJueXueQueue:GetPos()
	return 2;
end;

--是否显示
function RemindSkillJueXueQueue:GetIsShow()
	return self.isShow;
end


function RemindSkillJueXueQueue:GetShowIndex()
	return 41;
end;

function RemindSkillJueXueQueue:GetBtnWidth()
	return 60;
end
function RemindSkillJueXueQueue:GetTConstsID()
	return 226;
end

function RemindSkillJueXueQueue:CheckCondition()
	if SkillUtil:CheckJuexueCanLvlUp() then
		self:AddData(1);
		return true;
	else
		self:AddData(0);
		return false;
	end
end
function RemindSkillJueXueQueue:AddData(data) --1 显示 0 关闭
	if data == 0 then
		self.isShow = false
		self:HideButton()
		return
	end

	self.isShow = true
	self:RefreshData();
end;

function RemindSkillJueXueQueue:ClearData()
	self.isShow = false;
	self:RefreshData()
end

function RemindSkillJueXueQueue:DoClick()
	FuncManager:OpenFunc(FuncConsts.MagicSkill, true);
	self.isShow = false;
	self:RefreshData()
end;

--鼠标移上
function RemindSkillJueXueQueue:DoRollOver()
	TipsManager:ShowBtnTips(string.format(StrConfig["skill51"]));
end
--鼠标移出处理
function RemindSkillJueXueQueue:DoRollOut()
	TipsManager:Hide();
end
--[[
跨服擂台资格提醒队列
]]
_G.RemindContestZigeQueue = setmetatable({},{__index=RemindQueue});

RemindContestZigeQueue.isShow = true;
function RemindContestZigeQueue:GetType()
	return RemindConsts.Type_InterContestPreZige;
end;

function RemindContestZigeQueue:GetLibraryLink()
	return "RemindInterContestZige";
end;

function RemindContestZigeQueue:GetPos()
	return 2;
end;

--是否显示
function RemindContestZigeQueue:GetIsShow()
	return self.isShow;
end


function RemindContestZigeQueue:GetShowIndex()
	return 3;
end;

function RemindContestZigeQueue:GetBtnWidth()
	return 60;
end

function RemindContestZigeQueue:AddData(data) --1 显示 0 关闭
	if data == 0 then
		self.isShow = false
		self:HideButton()
		return
	end

	self.isShow = true
	self:RefreshData();
end;

function RemindContestZigeQueue:ClearData()
	self.isShow = false;
	self:RefreshData()
end

function RemindContestZigeQueue:DoClick()
	--FuncManager:OpenFunc(FuncConsts.Skill,true);
	InterContestController:ReqCrossArenaZige()
	
	self.isShow = false;
	self:RefreshData()
end;

--鼠标移上
function RemindContestZigeQueue:DoRollOver()
	TipsManager:ShowBtnTips(string.format(StrConfig["interServiceDungeon65"]));
end
--鼠标移出处理
function RemindContestZigeQueue:DoRollOut()
	TipsManager:Hide();
end

--[[
    Created by IntelliJ IDEA.
    
    User: Hongbin Yang
    Date: 2016/7/19
    Time: 17:18
   ]]

_G.RemindLovelyPetFightQueue = setmetatable({},{__index=RemindQueue});

RemindLovelyPetFightQueue.isShow = false;

function RemindLovelyPetFightQueue:GetType()
	return RemindConsts.Type_LovelyPetFight;
end;

function RemindLovelyPetFightQueue:GetLibraryLink()
	return "RemindLovelyPetFight";
end;

function RemindLovelyPetFightQueue:GetPos()
	return 2;
end;

--是否显示
function RemindLovelyPetFightQueue:GetIsShow()
	return self.isShow;
end


function RemindLovelyPetFightQueue:GetShowIndex()
	return 19;
end;

function RemindLovelyPetFightQueue:GetBtnWidth()
	return 60;
end
function RemindLovelyPetFightQueue:GetTConstsID()
	return 218;
end

function RemindLovelyPetFightQueue:CheckCondition()
	if not FuncManager:GetFuncIsOpen(FuncConsts.LovelyPet) then return false; end
	if LovelyPetUtil:HasPetFight() == false and LovelyPetUtil:GetHasPetCount() > 0 then
		self:AddData(1);
		return true;
	else
		self:AddData(0);
		return false;
	end
end
function RemindLovelyPetFightQueue:AddData(data) --1 没有任何出战  0 关闭
	if not FuncManager:GetFuncIsOpen(FuncConsts.LovelyPet) then return; end
	if data == 0 then
		self.isShow = false
		self:HideButton()
		return
	end

	self.isShow = true
	self:RefreshData();
end;

function RemindLovelyPetFightQueue:DoClick()
	FuncManager:OpenFunc(FuncConsts.LovelyPet,true);
	self.isShow = false;
	self:RefreshData()
end;

--鼠标移上
function RemindLovelyPetFightQueue:DoRollOver()
	TipsManager:ShowBtnTips(string.format(StrConfig["lovelypet28"]));
end
--鼠标移出处理
function RemindLovelyPetFightQueue:DoRollOut()
	TipsManager:Hide();
end
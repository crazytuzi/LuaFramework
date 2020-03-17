--[[
    Created by IntelliJ IDEA.
    
    User: Hongbin Yang
    Date: 2016/7/19
    Time: 17:51
   ]]


_G.RemindHuoYueDuUpQueue = RemindQueue:new();

function RemindHuoYueDuUpQueue:GetType()
	return RemindConsts.Type_HuoYueDuUp;
end

function RemindHuoYueDuUpQueue:GetLibraryLink()
	return "RemindHuoYueDuUp";
end

function RemindHuoYueDuUpQueue:GetPos()
	return 2;
end

function RemindHuoYueDuUpQueue:GetShowIndex()
	return 20;
end

--数字
function RemindHuoYueDuUpQueue:GetShowNum()
	return false;
end

function RemindHuoYueDuUpQueue:GetBtnWidth()
	return 60;
end
function RemindHuoYueDuUpQueue:GetTConstsID()
	return 215;
end

function RemindHuoYueDuUpQueue:CheckCondition()
	if not FuncManager:GetFuncIsOpen(FuncConsts.HuoYueDu) then return false; end

	if HuoYueDuController:GetXianjieUpdate() then
		self:AddData(1);
		return true;
	else
		self:AddData(0);
		return false;
	end
end
function RemindHuoYueDuUpQueue:AddData(data)
	if not FuncManager:GetFuncIsOpen(FuncConsts.HuoYueDu) then return; end
	if data == 0 then
		self:ClearData();
	else
		table.push(self.datalist, data);
	end
	self:RefreshData();
end

function RemindHuoYueDuUpQueue:DoClick()
	FuncManager:OpenFunc(FuncConsts.HuoYueDu);
end
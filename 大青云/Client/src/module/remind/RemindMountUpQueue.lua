--[[
    Created by IntelliJ IDEA.
    
    User: Hongbin Yang
    Date: 2016/7/19
    Time: 17:53
   ]]



_G.RemindMountUpQueue = RemindQueue:new();

function RemindMountUpQueue:GetType()
	return RemindConsts.Type_MountUp;
end

function RemindMountUpQueue:GetLibraryLink()
	return "RemindMountUp";
end

function RemindMountUpQueue:GetPos()
	return 2;
end

function RemindMountUpQueue:GetShowIndex()
	return 21;
end

--数字
function RemindMountUpQueue:GetShowNum()
	return false;
end

function RemindMountUpQueue:GetBtnWidth()
	return 60;
end
function RemindMountUpQueue:GetTConstsID()
	return 216;
end

function RemindMountUpQueue:CheckCondition()
	if not FuncManager:GetFuncIsOpen(FuncConsts.Horse) then return false; end


	if MountController:GetMountUpdate() then
		self:AddData(1);
		return true;
	else
		self:AddData(0);
		return false;
	end
end
function RemindMountUpQueue:AddData(data)
	if not FuncManager:GetFuncIsOpen(FuncConsts.Horse) then return; end

	if data == 0 then
		self:ClearData();
	else
		table.push(self.datalist, data);
	end
	self:RefreshData();
end

function RemindMountUpQueue:DoClick()
	FuncManager:OpenFunc(FuncConsts.Horse, false);

	self:ClearData();
	self:RefreshData();

end
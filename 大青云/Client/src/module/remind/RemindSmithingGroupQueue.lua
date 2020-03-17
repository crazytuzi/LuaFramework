--[[
    Created by IntelliJ IDEA.
    套装激活升级提示
    User: Hongbin Yang
    Date: 2016/8/1
    Time: 20:45
   ]]


_G.RemindSmithingGroupQueue = RemindQueue:new();

function RemindSmithingGroupQueue:GetType()
	return RemindConsts.Type_SmithingGroup;
end

function RemindSmithingGroupQueue:GetLibraryLink()
	return "RemindSmithingGroup";
end

function RemindSmithingGroupQueue:GetPos()
	return 2;
end

function RemindSmithingGroupQueue:GetShowIndex()
	return 39;
end

--数字
function RemindSmithingGroupQueue:GetShowNum()
	return false;
end

function RemindSmithingGroupQueue:GetBtnWidth()
	return 60;
end
function RemindSmithingGroupQueue:GetTConstsID()
	return 222;
end

function RemindSmithingGroupQueue:CheckCondition()
	if not FuncManager:GetFuncIsOpen(FuncConsts.GroupYangc) then return false; end

	if EquipUtil:IsHaveEquipGroupCanOperate() then
		self:AddData(1);
		return true;
	else
		self:AddData(0);
		return false;
	end
	return false;
end
function RemindSmithingGroupQueue:AddData(data)
	if not FuncManager:GetFuncIsOpen(FuncConsts.GroupYangc) then return; end
	if data == 0 then
		self:ClearData();
	else
		table.push(self.datalist, data);
	end
	self:RefreshData();
end

function RemindSmithingGroupQueue:DoClick()
	FuncManager:OpenFunc(FuncConsts.GroupYangc);

	self:ClearData();
	self:RefreshData();

end
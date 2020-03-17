--[[
    Created by IntelliJ IDEA.
    装备洗练提示
    User: Hongbin Yang
    Date: 2016/7/18
    Time: 21:39
   ]]



_G.RemindSmithingWashQueue = RemindQueue:new();

function RemindSmithingWashQueue:GetType()
	return RemindConsts.Type_SmithingWash;
end

function RemindSmithingWashQueue:GetLibraryLink()
	return "RemindSmithingWash";
end

function RemindSmithingWashQueue:GetPos()
	return 2;
end

function RemindSmithingWashQueue:GetShowIndex()
	return 18;
end

--数字
function RemindSmithingWashQueue:GetShowNum()
	return false;
end

function RemindSmithingWashQueue:GetBtnWidth()
	return 60;
end
function RemindSmithingWashQueue:GetTConstsID()
	return 214;
end

function RemindSmithingWashQueue:CheckCondition()
	if not FuncManager:GetFuncIsOpen(FuncConsts.SmithingWash) then return false; end
	if EquipUtil:IsHaveEquipCanWash() then
		self:AddData(1);
		return true;
	else
		self:AddData(0);
		return false;
	end
end
function RemindSmithingWashQueue:AddData(data)
	if not FuncManager:GetFuncIsOpen(FuncConsts.SmithingWash) then return; end

	if data == 0 then
		self:ClearData();
	else
		table.push(self.datalist, data);
	end
	self:RefreshData();
end

function RemindSmithingWashQueue:DoClick()
	FuncManager:OpenFunc(FuncConsts.SmithingWash);

	self:ClearData();
	self:RefreshData();
end


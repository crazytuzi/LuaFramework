--[[
    Created by IntelliJ IDEA.
    装备升星提醒
    User: Hongbin Yang
    Date: 2016/7/18
    Time: 20:47
   ]]


_G.RemindSmithingStarQueue = RemindQueue:new();

function RemindSmithingStarQueue:GetType()
	return RemindConsts.Type_SmithingStar;
end

function RemindSmithingStarQueue:GetLibraryLink()
	return "RemindSmithingStar";
end

function RemindSmithingStarQueue:GetPos()
	return 2;
end

function RemindSmithingStarQueue:GetShowIndex()
	return 16;
end

--数字
function RemindSmithingStarQueue:GetShowNum()
	return false;
end

function RemindSmithingStarQueue:GetBtnWidth()
	return 60;
end
function RemindSmithingStarQueue:GetTConstsID()
	return 212;
end

function RemindSmithingStarQueue:CheckCondition()
	if not FuncManager:GetFuncIsOpen(FuncConsts.EquipStren) then return false; end
	if EquipUtil:IsHaveEquipCanStarUp() then
		self:AddData(1);
		return true;
	else
		self:AddData(0);
		return false;
	end
end

function RemindSmithingStarQueue:AddData(data)
	if not FuncManager:GetFuncIsOpen(FuncConsts.EquipStren) then return; end

	if data == 0 then
		self:ClearData();
	else
		table.push(self.datalist, data);
	end
	self:RefreshData();
end

function RemindSmithingStarQueue:DoClick()
	FuncManager:OpenFunc(FuncConsts.EquipStren);

	self:ClearData();
	self:RefreshData();

end
--[[
    Created by IntelliJ IDEA.
    宝石镶嵌提示
    User: Hongbin Yang
    Date: 2016/7/18
    Time: 21:38
   ]]


_G.RemindSmithingInlayQueue = RemindQueue:new();

function RemindSmithingInlayQueue:GetType()
	return RemindConsts.Type_SmithingInlay;
end

function RemindSmithingInlayQueue:GetLibraryLink()
	return "RemindSmithingInlay";
end

function RemindSmithingInlayQueue:GetPos()
	return 2;
end

function RemindSmithingInlayQueue:GetShowIndex()
	return 17;
end

--数字
function RemindSmithingInlayQueue:GetShowNum()
	return false;
end

function RemindSmithingInlayQueue:GetBtnWidth()
	return 60;
end
function RemindSmithingInlayQueue:GetTConstsID()
	return 213;
end

function RemindSmithingInlayQueue:CheckCondition()
	if not FuncManager:GetFuncIsOpen(FuncConsts.EquipGem) then return false; end
	if EquipUtil:IsHaveGemCanIn() or EquipUtil:IsGemCanOpeTimes(5) then
		self:AddData(1);
		return true;
	else
		self:AddData(0);
		return false;
	end
end
function RemindSmithingInlayQueue:AddData(data)
	if not FuncManager:GetFuncIsOpen(FuncConsts.EquipGem) then return; end
	if data == 0 then
		self:ClearData();
	else
		table.push(self.datalist, data);
	end
	self:RefreshData();
end

function RemindSmithingInlayQueue:DoClick()
	FuncManager:OpenFunc(FuncConsts.EquipGem);

	self:ClearData();
	self:RefreshData();

end
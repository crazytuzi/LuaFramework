--[[
    Created by IntelliJ IDEA.
    神装收集
    User: Hongbin Yang
    Date: 2016/10/24
    Time: 20:10
   ]]


_G.RemindSmithingCollectionQueue = RemindQueue:new();

function RemindSmithingCollectionQueue:GetType()
	return RemindConsts.Type_SmithingCollection;
end

function RemindSmithingCollectionQueue:GetLibraryLink()
	return "RemindSmithingCollection";
end

function RemindSmithingCollectionQueue:GetPos()
	return 2;
end

function RemindSmithingCollectionQueue:GetShowIndex()
	return 40;
end

--数字
function RemindSmithingCollectionQueue:GetShowNum()
	return false;
end

function RemindSmithingCollectionQueue:GetBtnWidth()
	return 60;
end
function RemindSmithingCollectionQueue:GetTConstsID()
	return 225;
end

function RemindSmithingCollectionQueue:CheckCondition()
	if not FuncManager:GetFuncIsOpen(FuncConsts.equipCollect) then return false; end

	if SmithingModel:IsEquipCollectCanOperate1() then
		self:AddData(1);
		return true;
	else
		self:AddData(0);
		return false;
	end
	return false;
end
function RemindSmithingCollectionQueue:AddData(data)
	if not FuncManager:GetFuncIsOpen(FuncConsts.equipCollect) then return; end
	if data == 0 then
		self:ClearData();
	else
		table.push(self.datalist, data);
	end
	self:RefreshData();
end

function RemindSmithingCollectionQueue:DoClick()
	FuncManager:OpenFunc(FuncConsts.equipCollect);

	self:RefreshData();
end
--[[
    Created by IntelliJ IDEA.
    伏魔提醒
    User: Hongbin Yang
    Date: 2016/7/21
    Time: 15:47
   ]]


_G.RemindFuMoQueue = RemindQueue:new();

function RemindFuMoQueue:GetType()
	return RemindConsts.Type_FuMo;
end

function RemindFuMoQueue:GetLibraryLink()
	return "RemindFuMo";
end

function RemindFuMoQueue:GetPos()
	return 2;
end

function RemindFuMoQueue:GetShowIndex()
	return 22;
end

--数字
function RemindFuMoQueue:GetShowNum()
	return false;
end

function RemindFuMoQueue:GetBtnWidth()
	return 60;
end
function RemindFuMoQueue:GetTConstsID()
	return 219;
end

function RemindFuMoQueue:CheckCondition()
	if not FuncManager:GetFuncIsOpen(FuncConsts.Fumo) then return false; end
	if FumoUtil:isCanUpMap() then
		self:AddData(1);
		return true;
	else
		self:AddData(0);
		return false;
	end
end
function RemindFuMoQueue:AddData(data)
	if not FuncManager:GetFuncIsOpen(FuncConsts.Fumo) then return; end

	if data == 0 then
		self:ClearData();
	else
		table.push(self.datalist, data);
	end
	self:RefreshData();
end

function RemindFuMoQueue:DoClick()
	FuncManager:OpenFunc(FuncConsts.Fumo, false);

	self:ClearData();
	self:RefreshData();

end
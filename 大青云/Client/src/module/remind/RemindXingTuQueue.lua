--[[
    Created by IntelliJ IDEA.
    星图激活升级提醒
    User: Hongbin Yang
    Date: 2016/7/21
    Time: 15:57
   ]]



_G.RemindXingTuQueue = RemindQueue:new();

function RemindXingTuQueue:GetType()
	return RemindConsts.Type_XingTu;
end

function RemindXingTuQueue:GetLibraryLink()
	return "RemindXingTu";
end

function RemindXingTuQueue:GetPos()
	return 2;
end

function RemindXingTuQueue:GetShowIndex()
	return 23;
end

--数字
function RemindXingTuQueue:GetShowNum()
	return false;
end

function RemindXingTuQueue:GetBtnWidth()
	return 60;
end
function RemindXingTuQueue:GetTConstsID()
	return 220;
end

function RemindXingTuQueue:CheckCondition()
	if not FuncManager:GetFuncIsOpen(FuncConsts.Xingtu) then return false; end
	if XingtuModel:IsHaveCanLvUp() then
		self:AddData(1);
		return true;
	else
		self:AddData(0);
		return false;
	end
end
function RemindXingTuQueue:AddData(data)
	if not FuncManager:GetFuncIsOpen(FuncConsts.Xingtu) then return; end
	if data == 0 then
		self:ClearData();
	else
		table.push(self.datalist, data);
	end
	self:RefreshData();
end

function RemindXingTuQueue:DoClick()
	FuncManager:OpenFunc(FuncConsts.Xingtu, false);

	self:ClearData();
	self:RefreshData();

end
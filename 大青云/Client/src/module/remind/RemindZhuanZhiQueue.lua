--[[
    Created by IntelliJ IDEA.
    转职有奖励提醒
    User: Hongbin Yang
    Date: 2016/7/21
    Time: 15:58
   ]]


_G.RemindZhuanZhiQueue = RemindQueue:new();

function RemindZhuanZhiQueue:GetType()
	return RemindConsts.Type_ZhuanZhi;
end

function RemindZhuanZhiQueue:GetLibraryLink()
	return "RemindZhuanZhi";
end

function RemindZhuanZhiQueue:GetPos()
	return 2;
end

function RemindZhuanZhiQueue:GetShowIndex()
	return 24;
end

--数字
function RemindZhuanZhiQueue:GetShowNum()
	return false;
end

function RemindZhuanZhiQueue:GetBtnWidth()
	return 60;
end
function RemindZhuanZhiQueue:GetTConstsID()
	return 223;
end

function RemindZhuanZhiQueue:CheckCondition()
	if not FuncManager:GetFuncIsOpen(FuncConsts.ZhuanZhi) then return false; end
	if ZhuanZhiModel:IsHaveRewardCanGet() then
		self:AddData(1);
		return true;
	else
		self:AddData(0);
		return false;
	end
end
function RemindZhuanZhiQueue:AddData(data)
	if not FuncManager:GetFuncIsOpen(FuncConsts.ZhuanZhi) then return; end

	if data == 0 then
		self:ClearData();
	else
		table.push(self.datalist, data);
	end
	self:RefreshData();
end

function RemindZhuanZhiQueue:DoClick()
	FuncManager:OpenFunc(FuncConsts.ZhuanZhi, false);
end
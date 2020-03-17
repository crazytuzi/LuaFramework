--[[
    Created by IntelliJ IDEA.
    右下角功能提醒管理， 具体管理播放
    User: Hongbin Yang
    Date: 2016/8/27
    Time: 17:36
   ]]

_G.RemindFuncManager = {};

RemindFuncManager.showList = {};
RemindFuncManager.isShowing = false;
function RemindFuncManager:AddToShow(id)
	for k, v in pairs(self.showList) do
		if v == id then
			return;
		end
	end
	table.push(self.showList, id);
	self:ShowNext();
end

function RemindFuncManager:ShowNext()
	if self.isShowing then return; end
	if #self.showList <= 0 then return; end

	RemindFuncManager.isShowing = true;

	local toShowId = self.showList[1];
	RemindFuncView:Show(toShowId);
end

function RemindFuncManager:RemoveFirstOne()
	if #self.showList <= 0 then return; end
	table.remove(self.showList, 1);
end

function RemindFuncManager:IsOnShowList(id)
	for k, v in pairs(self.showList) do
		if v == id then
			return true;
		end
	end
	return false;
end

function RemindFuncManager:RemovePreshow(id)
	if not self:IsOnShowList(id) then return; end
	--第一个正在显示的,如果正在显示中，处理完后不再执行后续
	if self.showList[1] == id then
		if RemindFuncView:IsShow() then
			RemindFuncView:OnBtnCloseClick();
		end
		return;
	end
	--非第一个内容
	for i = 1, #self.showList do
		if self.showList[i] == id then
			table.remove(self.showList, i);
			break;
		end
	end
end
--[[
封妖完成提示
zhangshuhui
2015年2月11日15:49:44
]]
_G.RemindFengYaoQueue = setmetatable({},{__index=RemindQueue});

RemindFengYaoQueue.isShow = false;
function RemindFengYaoQueue:GetType()
	return RemindConsts.Type_FengYao;
end;

function RemindFengYaoQueue:GetLibraryLink()
	return "RemindFengYao";
end;

function RemindFengYaoQueue:GetPos()
	return 2;
end;

--是否显示
function RemindFengYaoQueue:GetIsShow()
	return self.isShow;
end


function RemindFengYaoQueue:GetShowIndex()
	return 3;
end;

function RemindFengYaoQueue:GetBtnWidth()
	return 60;
end
function RemindFengYaoQueue:GetTConstsID()
	return 224;
end

function RemindFengYaoQueue:CheckCondition()
	if FengYaoModel:HasCanReward() then
		self:AddData(1);
		return true;
	else
		self:AddData(0);
		return false
	end

end
function RemindFengYaoQueue:AddData(data) --1 显示 0 关闭
	--按着自动挂机写的，有问题不要找我啊。。。。。。。。
	if data == 0 then
		self.isShow = false
		self:HideButton()
		return
	end

	self.isShow = true
	self:RefreshData();
end;

function RemindFengYaoQueue:DoClick()
	FuncManager:OpenFunc(FuncConsts.FengYao,true);
	self.isShow = false;
	self:RefreshData()
end;

--鼠标移上
function RemindFengYaoQueue:DoRollOver()
	TipsManager:ShowBtnTips(string.format(StrConfig["fengyao25"]));
end
--鼠标移出处理
function RemindFengYaoQueue:DoRollOut()
	TipsManager:Hide();
end
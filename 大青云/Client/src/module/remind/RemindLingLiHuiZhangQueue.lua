--[[
聚灵碗刷新提示
zhangshuhui
2015年6月1日15:19:44
]]
_G.RemindLingLiHuiZhangQueue = setmetatable({},{__index=RemindQueue});

RemindLingLiHuiZhangQueue.isShow = true;
function RemindLingLiHuiZhangQueue:GetType()
	return RemindConsts.Type_HuiZhang;
end;

function RemindLingLiHuiZhangQueue:GetLibraryLink()
	return "RemindHuiZhang";
end;

function RemindLingLiHuiZhangQueue:GetPos()
	return 2;
end;

--是否显示
function RemindLingLiHuiZhangQueue:GetIsShow()
	return self.isShow;
end


function RemindLingLiHuiZhangQueue:GetShowIndex()
	return 3;
end;

function RemindLingLiHuiZhangQueue:GetBtnWidth()
	return 60;
end

function RemindLingLiHuiZhangQueue:AddData(data) --1 显示 0 关闭
	--按着自动挂机写的，有问题不要找我啊。。。。。。。。
	if data == 0 then
		self.isShow = false
		self:HideButton()
		return
	end

	self.isShow = true
	self:RefreshData();
end;

function RemindLingLiHuiZhangQueue:DoClick()
	FuncManager:OpenFunc( FuncConsts.Homestead, true);
	self.isShow = false;
	self:RefreshData()
end;

--鼠标移上
function RemindLingLiHuiZhangQueue:DoRollOver()
	TipsManager:ShowBtnTips(string.format(StrConfig["linglihuizhang39"]));
end
--鼠标移出处理
function RemindLingLiHuiZhangQueue:DoRollOut()
	TipsManager:Hide();
end
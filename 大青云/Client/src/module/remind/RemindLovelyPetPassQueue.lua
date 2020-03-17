--[[
萌宠到期提示和没有出战
zhangshuhui
2015年6月30日15:49:44
]]
_G.RemindLovelyPetPassQueue = setmetatable({},{__index=RemindQueue});

RemindLovelyPetPassQueue.isShow = false;
function RemindLovelyPetPassQueue:GetType()
	return RemindConsts.Type_LovelyPet;
end;

function RemindLovelyPetPassQueue:GetLibraryLink()
	return "RemindLovelyPetRenew";
end;

function RemindLovelyPetPassQueue:GetPos()
	return 2;
end;

--是否显示
function RemindLovelyPetPassQueue:GetIsShow()
	return self.isShow;
end


function RemindLovelyPetPassQueue:GetShowIndex()
	return 3;
end;

function RemindLovelyPetPassQueue:GetBtnWidth()
	return 60;
end

function RemindLovelyPetPassQueue:AddData(data) --1 显示当前到期   0 关闭
	if not FuncManager:GetFuncIsOpen(FuncConsts.LovelyPet) then return; end
	if data == 0 then
		self.isShow = false
		self:HideButton()
		return
	end

	self.isShow = true
	self:RefreshData();
end;

function RemindLovelyPetPassQueue:DoClick()
	FuncManager:OpenFunc(FuncConsts.LovelyPet,true);
	self.isShow = false;
	self:RefreshData()
end;

--鼠标移上
function RemindLovelyPetPassQueue:DoRollOver()
	TipsManager:ShowBtnTips(string.format(StrConfig["lovelypet16"]));
end
--鼠标移出处理
function RemindLovelyPetPassQueue:DoRollOut()
	TipsManager:Hide();
end
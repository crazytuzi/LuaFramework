--[[
	360特权
	wangshuai
]]

_G.UIWeishi360 = BaseUI:new("UIWeishi360")

UIWeishi360.curIndex = 0;

function UIWeishi360:Create()
	self:AddSWF("weishi360Panel.swf",true,"center")
end;

function UIWeishi360:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:Hide()end;

	for i=1,4 do 
		local item = objSwf["rewarditem"..i]
		RewardManager:RegisterListTips( item.itemlist );
		item.getReward_btn.click = function() self:OnGetRewardClick(item.getReward_btn)end;
	end;
	objSwf.scrollbar.scroll = function () self:OnScrollBar()end;
	objSwf.btn_OpenPath.click = function() self:OpenPath() end;
end;

function UIWeishi360:OpenPath()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	Version:Hd360Browse()
end;

function UIWeishi360:OnShow()
	local objSwf = self.objSwf;
	local list = t_weishi;
	objSwf.scrollbar:setScrollProperties(4,0,#list-4);
	objSwf.scrollbar.trackScrollPageSize = 4;
	objSwf.scrollbar.position = 0;

	self:ShowLIst();
end;

function UIWeishi360:OnHide()

end;

UIWeishi360.lastSendTime = 0;

function UIWeishi360:OnGetRewardClick(target)
	local isWeiShi = Version:IsShowHd360();
	if not isWeiShi then 
		local func = function ()
			Version:Hd360Browse()
		end
		UIConfirm:Open(StrConfig['yunying001'],func);
		return;
	end;
	
	--点击间隔
	if GetCurTime() - self.lastSendTime < 5000 then
		return;
	end
	self.lastSendTime = GetCurTime();
	
	WeishiController:ReqGetReward(1,target.id)
end;

function UIWeishi360:OnScrollBar()
	local objSwf = self.objSwf;
	local index = objSwf.scrollbar.position;
	self.curIndex = index;
	self:ShowLIst()

end;

function UIWeishi360:ShowLIst()
	local objSwf = self.objSwf;
	local listvo = t_weishi;

	local index = self.curIndex;
	local objSwf = self.objSwf;
	for i=1,4 do 
		local item = objSwf["rewarditem"..i];
		local data = listvo[i+index];
		if data then 
			item.getReward_btn.id = data.id;
			if data.level == 0 then 
				item.title.num = "t"
			elseif data.level == 999 then 
				item.title.num = "c"
			else
				item.title.num = "k"..data.level.."l"
			end;
			local bo = not Weishi360Model:GetCurLvlState(data.id)
			if bo == true then 
				item.getReward_btn.label = StrConfig["yunying003"]
			else
				item.getReward_btn.label = StrConfig["yunying002"]
			end;
			item.getReward_btn.disabled = bo
			local rewardStrList = RewardManager:Parse(data.reward);
			item.itemlist.dataProvider:cleanUp();
			item.itemlist.dataProvider:push(unpack(rewardStrList));
			item.itemlist:invalidateData();
			item._visible = true;
		else
			item._visible = false;
		end;
	end;
end;

-- 是否缓动
function UIWeishi360:IsTween()
	return true;
end

--面板类型
function UIWeishi360:GetPanelType()
	return 1;
end
--是否播放开启音效
function UIWeishi360:IsShowSound()
	return true;
end

function UIWeishi360:IsShowLoading()
	return true;
end

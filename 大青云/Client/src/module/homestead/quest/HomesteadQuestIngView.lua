--[[
	家园进行任务
	wangshuai

]]

_G.UIHomesQuestIng = BaseUI:new("UIHomesQuestIng")

UIHomesQuestIng.curIndex = 0;

function UIHomesQuestIng:Create()
	self:AddSWF("homesteadQuestIngPanel.swf",true,nil)
end;

function UIHomesQuestIng:OnLoaded(objSwf)
	objSwf.scrollbar.scroll = function () self:OnScrollBar()end;
	for i=1,6 do 
		RewardManager:RegisterListTips(objSwf["item"..i].rewardlist);
		objSwf["item"..i].getReward_btn.click = function() self:OnGetReward(objSwf["item"..i].getReward_btn)end;
	end;
end;

function UIHomesQuestIng:OnShow()

	HomesteadController:MyQuestInfo()
	self:UpdataUIData();
end;

function UIHomesQuestIng:OnHide()

end;

function UIHomesQuestIng:UpdataUIData()
	local objSwf = self.objSwf;
	self.list = HomesteadModel:GetMyQuestInfo();
	objSwf.scrollbar:setScrollProperties(6,0,#self.list-6);
	objSwf.scrollbar.trackScrollPageSize = 6;
	objSwf.scrollbar.position = 0;
	self:ShowQuestIngList();
end;

function UIHomesQuestIng:OnGetReward(target)
	HomesteadController:GetMyQuestReawrd(target.uid)
end;

function UIHomesQuestIng:OnScrollBar()
	local objSwf = self.objSwf;
	local index = objSwf.scrollbar.position;
	if self.curIndex == index then 
		return 
	end;
	self.curIndex = index;
	self:ShowQuestIngList()
end;

function UIHomesQuestIng:ShowQuestIngList()
	local index = self.curIndex;
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local volist = self.list;
	for i=1,6 do 
		local item = objSwf["item"..i];
		local data = volist[i+index];
		if data then 
			local cfg = t_homequestrange[data.tid]
			item.Name_txt.htmlText = HomesteadUtil:GetQualityColor(data.quality,cfg.QuestName) ;

			local questTypecfg = t_homequestfit[cfg.QuestType]
			if questTypecfg  then 
				item.type_txt.htmlText = questTypecfg.tips
			else
				item.type_txt.htmlText = "";
			end;
			--item.lvl_txt .htmlText = data.questlvl;
			if data.lastTime <= 0 then 
				item.getReward_btn._visible =  true;
				item.time_txt._visible = false;
				item.pro_mc._visible = false;
				item.getReward_btn.uid = data.guid;
			else
				item.getReward_btn._visible =  false;
				item.time_txt._visible = true;
				item.pro_mc._visible = true;
			end;

			local sourStr = ResUtil:GetHomeQuestIcon(cfg.QuestType * 10 + data.quality);
			if sourStr ~= item.icon_load.source then 
				item.icon_load.source = sourStr
			end;
			
			----奖励list
			local rewardList = {};
			local reward1 = RewardSlotVO:new()
			reward1.id = data.rewardType;
			reward1.count = data.rewardNum;

			local reward2 = RewardSlotVO:new();
			reward2.id = 64;
			reward2.count = data.pupilExp;

			if data.itemid and data.itemid ~= 0 then 
				local reward3 = RewardSlotVO:new();
				reward3.id = data.itemid;
				reward3.count = 1;
				table.push(rewardList,reward3:GetUIData())
			end;

			table.push(rewardList,reward1:GetUIData())
			table.push(rewardList,reward2:GetUIData())
			

			item.rewardlist.dataProvider:cleanUp();
			item.rewardlist.dataProvider:push(unpack(rewardList));
			item.rewardlist:invalidateData();
			item._visible = true;
		else
			item._visible = false;
		end;
	end;

	objSwf.questnum_txt.htmlText = #self.list; 
	self:UpdataQuestProgress();
end;

function UIHomesQuestIng:UpdataQuestProgress()
	if not self:IsShow() then  return end;
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local index = self.curIndex;
	local volist = self.list;
	for i=1,6 do 
		local item = objSwf["item"..i];
		local data = volist[i+index];
		if data then 
			local r,t,s,f = CTimeFormat:sec2formatEx(data.lastTime)
			if r >= 1 then 
				t = r * 24 + t
			end;
			item.time_txt.htmlText = string.format("%02d:%02d:%02d",t,s,f)
			item.pro_mc.maximum = data.MaxTime
			item.pro_mc.value = data.lastTime
		end;
	end;
end;

	-- notifaction
function UIHomesQuestIng:ListNotificationInterests()
	return {
		NotifyConsts.HomesteadUpdatTime,
		NotifyConsts.HomesteadMyQuestUpdata,
		}
end;
function UIHomesQuestIng:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.HomesteadMyQuestUpdata then 
		self:UpdataUIData()
	end;
end;
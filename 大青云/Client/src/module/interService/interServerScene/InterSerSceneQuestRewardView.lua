--[[
跨服场景任务奖励
]]

_G.UIInterSSQuestReward = BaseUI:new("UIInterSSQuestReward");


function UIInterSSQuestReward:Create()
	self:AddSWF("InterSerSceneQuestRewardPenl.swf", true, "center");
end;
function UIInterSSQuestReward:OnLoaded(objSwf)
	objSwf.scrollbar.scroll = function () self:OnScrollBar()end;
	for i=1,3 do 
		RewardManager:RegisterListTips(objSwf["item"..i].rewardlist);
		--objSwf["item"..i].check_btn.click = function() self:OnCheckClick(objSwf["item"..i].check_btn)end;
	end;
	objSwf.getReward.click = function() self:OnGetRewardClick()end;
	objSwf.closebtn.click = function() self:Hide()end;
end;

function UIInterSSQuestReward:OnGetRewardClick()
	InterSerSceneController:ReqInterSSQuestGetReward()
end;

function UIInterSSQuestReward:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local list = InterSerSceneModel:GetQuestRewardList()
	objSwf.scrollbar:setScrollProperties(3,0,#list-3);
	objSwf.scrollbar.trackScrollPageSize = 3;
	objSwf.scrollbar.position = 0;
	self:ShowUiList();
	self:SetRewardBtnState();
end;

function UIInterSSQuestReward:OnHide()

end;

function UIInterSSQuestReward:SetRewardBtnState()
	local objSwf =  self.objSwf;
	if not objSwf then return end;
	objSwf.getReward.disabled = not InterSerSceneModel:getRewardState();
end;
UIInterSSQuestReward.curIndex = 0;

function UIInterSSQuestReward:ShowUiList()
	local objSwf = self.objSwf
	local questVo =  InterSerSceneModel:GetQuestRewardList()
	local index = self.curIndex;
	for i=1,3 do 
		local item = objSwf['item'..i];
		local data = questVo[index + i]
		if data then 
			local cfg = t_kuafuquest[data.questId];
			if cfg then 
				item.Name_txt.htmlText = cfg.questName;
				item.start.star = "EquipStrenStar";
				item.start.value = cfg.questStar;
				--item.questtime_txt.htmlText = cfg.des;

				local rankReward = RewardManager:Parse(cfg.reward)
				item.rewardlist.dataProvider:cleanUp();
				item.rewardlist.dataProvider:push(unpack(rankReward));
				item.rewardlist:invalidateData();

				item.getReward._visible = data.state == 2 and true or false
				item._visible = true;
			else
				item._visible = false;
			end;
		else
			item._visible = false;
		end;
	end;
end;

function UIInterSSQuestReward:OnScrollBar()
	local objSwf = self.objSwf;
	local index = objSwf.scrollbar.position;
	self.curIndex = index;
	self:ShowUiList()
end;

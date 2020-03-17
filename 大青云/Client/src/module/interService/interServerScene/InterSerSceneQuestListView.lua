--[[
跨服场景任务
]]

-- _G.UIInterSSQuest= BaseUI:new("UIInterSSQuest");


-- _G.classlist['UIInterSSQuest'] = 'UIInterSSQuest'
_G.UIInterSSQuest = BaseUI:new("UIInterSSQuest");
_G.UIInterSSQuest.objName = 'UIInterSSQuest'
function UIInterSSQuest:new(szName)
	local obj = BaseUI:new(szName);
	for i,v in pairs(UIInterSSQuest) do
		--if type(v) == "function" then
			obj[i] = v;
		--end
	end
	return obj;
end


UIInterSSQuest.questIndex = 1;


function UIInterSSQuest:Create()
	self:AddSWF("interSerSceneQuestList.swf", true, "center");
end;

function UIInterSSQuest:OnLoaded(objSwf)
	for i=1,8 do 
		RewardManager:RegisterListTips(objSwf["item"..i].rewardlist);
		objSwf["item"..i].getBtn.click = function() self:OnGetQuestClick(i)end;
		objSwf['item'..i].qiQuestBtn.click = function() self:OnQiQuestClick(objSwf['item'..i].qiQuestBtn) end;
	end;

	objSwf.updata_Btn.click = function() self:OnUpdataQuest()end;
	objSwf.updata_Btn.rollOver = function() self:ShowUpdataTips() end;
	objSwf.updata_Btn.rollOut = function() TipsManager:Hide() end;


	objSwf.closebtn.click = function() self:Hide() end;

	objSwf.quest.click = function() self:OnQuestClick(1) end;
	objSwf.myquest.click = function() self:OnQuestClick(2) end;
end;


function UIInterSSQuest:ShowUpdataTips()
	local cfg = t_consts[304];
	if not cfg then return end;
	trace()
	TipsManager:ShowBtnTips(string.format(StrConfig['interServiceDungeon459'],cfg.val2 or 0 ))
end;	

function UIInterSSQuest:OnQuestClick(index)
	self.questIndex = index;
	self:UpdataUIShow();
end;


function UIInterSSQuest:OnShow()
	self.questIndex = 1;
	self.objSwf.quest.selected = true;
	InterSerSceneController:ReqInterSSQuestInfo(0)
	InterSerSceneController:ReqInterSSQuestMyInfo()
	self:UpdataUIShow();
	-- if not UIInterSSRight:IsShow() then 
	-- 	if MainInterServiceUI:IsShow() then 
	-- 		MainInterServiceUI:Hide();
	-- 	end;
	-- end;
end;

function UIInterSSQuest:DeleteWhenHide()
	return true;
end;


function UIInterSSQuest:OnHide()
	-- if not UIInterSSRight:IsShow() then 
	-- 	if not MainInterServiceUI:IsShow() then 
	-- 		MainInterServiceUI:Show();
	-- 	end;
	-- end;

end;

function UIInterSSQuest:OnUpdataQuest()
	if InterSerSceneModel:GetQuestUpdataNum() <= 0 then 
		FloatManager:AddNormal(StrConfig['interServiceDungeon440'])
		return
	end;
	InterSerSceneController:ReqInterSSQuestInfo(1)
	self:UpdataUIShow();
end;

function UIInterSSQuest:UpdataUIShow()
	self:ShowUiList();
	self:UpdataUITime();
	self:SetDayNum();
end;

function UIInterSSQuest:SetDayNum()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local num = InterSerSceneModel:GetCurDayNum()
	local maxNum = t_consts[301].val2;
	objSwf.dayNum_txt.htmlText = num .. "/" .. maxNum
end; 

function UIInterSSQuest:OnQiQuestClick(target)
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local okfun = function() 
		InterSerSceneController:ReqInterSSQuestDiscard(target.ccid)
	end
	UIConfirm:Open(string.format(StrConfig['interServiceDungeon437']),okfun);
end;

function UIInterSSQuest:OnGetQuestClick(index)
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local quest = InterSerSceneModel:GetCurQuestInfo();
	if not quest then return end;
	local vo = quest[index];

	local cfg = t_consts[301];
	if not cfg then 
		cfg.val2 = 0;
		print(debug.traceback())
	end;
	local myquestNum = InterSerSceneModel:GetMyQuestNum()
	if myquestNum >= cfg.val2 then 
		FloatManager:AddNormal(string.format(StrConfig["interServiceDungeon460"],cfg.val2))
		return 
	end
	InterSerSceneController:ReqInterSSQuestGet(vo.questId)
end;

function UIInterSSQuest:UpdataUITime()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	 local time = InterSerSceneModel:GetQuestUpdataNum()
	-- local t,s,f = CTimeFormat:sec2format(time)
	-- local str = string.format("%02d:%02d:%02d",t,s,f)
	objSwf.lastTime_txt.htmlText = time;
end;

function UIInterSSQuest:ShowUiList()
	local objSwf = self.objSwf
	local questVo =  {}
	if self.questIndex == 1 then 
		questVo = InterSerSceneModel:GetCurQuestInfo()
		objSwf.updata_Btn._visible = true;
	elseif self.questIndex == 2 then 
		questVo = InterSerSceneModel:GetMyQuestInfo()
		objSwf.updata_Btn._visible = false;
	end;
	for i=1,8 do 
		local item = objSwf['item'..i];
		local data = questVo[i]
		if data then 
			local cfg = t_kuafuquest[data.questId];
			if cfg then 
				if self.questIndex == 1 then 
					item.noGetRewad._visible = false;
					item.getReward._visible = false;
					item.questIng._visible = false;
					item.qiQuestBtn._visible = false;
					item.getBtn._visible = true;
					data.condition = 0;
				elseif self.questIndex == 2 then 
					item.getBtn._visible = false;
					if data.questState == 1 then 
						item.noGetRewad._visible = false;
						item.getReward._visible = false;
						item.questIng._visible = true;
						item.qiQuestBtn._visible = true;
					elseif data.questState == 2 then 
						item.noGetRewad._visible = true;
						item.getReward._visible = false;
						item.questIng._visible = false;
						item.qiQuestBtn._visible = false;
					elseif data.questState == 3 then 
						item.noGetRewad._visible = false;
						item.getReward._visible = true;
						item.questIng._visible = false;
						item.qiQuestBtn._visible = false;
					end;
				end;
				item.qiQuestBtn.ccid = data.questUId
				item.Name_txt.htmlText = cfg.questName;
				item.start.star = "EquipStrenStar";
				item.start.value = cfg.questStar;

				local str = StrConfig['interServiceDungeon409'];
				local numCfg = split(cfg.questGoals,",")
				local strc = ""
				local monsterCFG = t_monster[toint(numCfg[1])];

				if data.questState == 2 or data.questState == 3 then  -- 已完成
				if cfg.questType == 1 or cfg.questType == 2 then
						assert(monsterCFG, "not found monster:" .. numCfg[1] .. " from kuafuquestid:" .. data.questId);
						str = str .. "<font color='#00ff00'>" .. monsterCFG.name .. "</font>";
					elseif cfg.questType == 3 then 
						str = str .. StrConfig["interServiceDungeon435"] 
					end;
					strc = str .. StrConfig['interServiceDungeon436']
				else --任务未完成
					if cfg.questType == 1 or cfg.questType == 2 then
						assert(monsterCFG, "not found monster:" .. numCfg[1] .. " from kuafuquestid:" .. data.questId);
						str = str .. "<font color='#00ff00'>" .. monsterCFG.name .. "</font>";
						str = str .. "<font color='#c8c8c8'>(" .. data.condition .. "/" .. numCfg[2] .. ")</font>"
					elseif cfg.questType == 3 then 
						str = str .. StrConfig["interServiceDungeon435"] 
						str = str .. "<font color='#c8c8c8'>(" .. data.condition .. "/" .. numCfg[2] .. ")</font>"
					end;
					strc = str;
				end;


				item.questtime_txt.htmlText = strc;
				item.bg:gotoAndStop(cfg.questType)

				local rankReward = RewardManager:Parse(cfg.reward)
				item.rewardlist.dataProvider:cleanUp();
				item.rewardlist.dataProvider:push(unpack(rankReward));
				item.rewardlist:invalidateData();
				item._visible = true;
			else
				item._visible = false;
			end;
		else
			item._visible = false;
		end;
	end;
end;


-- notifaction
function UIInterSSQuest:ListNotificationInterests()
	return {
		NotifyConsts.InterSerSceneQuestUpdata,
		}
end;
function UIInterSSQuest:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.InterSerSceneQuestUpdata then
		self:UpdataUIShow();
	end;
end;

function UIInterSSQuest:ESCHide()
	return true;
end;
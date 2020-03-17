--[[
	家园任务列表
	wangshuai

]]

_G.UIHomesQuestList = BaseUI:new("UIHomesQuestList")

UIHomesQuestList.curIndex = 0;


function UIHomesQuestList:Create()
	self:AddSWF("homesteadQuestListPanel.swf",true,nil)
end;

function UIHomesQuestList:OnLoaded(objSwf)
	objSwf.scrollbar.scroll = function () self:OnScrollBar()end;
	for i=1,6 do 
		RewardManager:RegisterListTips(objSwf["item"..i].rewardlist);
		objSwf["item"..i].check_btn.click = function() self:OnCheckClick(objSwf["item"..i].check_btn)end;
	end;

	objSwf.updataQuest_btn.click = function() self:UpdataQuest() end;
	objSwf.updataQuest_btn.rollOver = function() self:UpdataOver() end;
	objSwf.updataQuest_btn.rollOut = function() TipsManager:Hide() end;
end;

function UIHomesQuestList:UpdataOver() 
	local num = HomesteadModel:GetQuestUpdataNum()
	if num == 0 then num = 1 end;
	local Questcfg = t_homepupilRe[num]
	if num > 10 then 
		Questcfg = t_homepupilRe[10]
	end;
	if not Questcfg then 
		Questcfg = t_homepupilRe[1];
	end;
	TipsManager:ShowBtnTips(string.format(StrConfig["homestead068"],Questcfg.need),TipsConsts.Dir_RightDown);
end;

function UIHomesQuestList:OnShow()
	HomesteadController:Questinfo(0)
	self:UpdataUiInfo(); 
	self:SetQuestUpdataTime();
end;

function UIHomesQuestList:OnHide()
	self.curIndex =0 
end;


UIHomesQuestList.isShowremind = true;
function UIHomesQuestList:UpdataQuest()
	local num = HomesteadModel:GetQuestUpdataNum();

	local Questcfg = t_homepupilRe[num]
	if num > 10 then 
		Questcfg = t_homepupilRe[10]
	end;
	if not Questcfg then 
		Questcfg = t_homepupilRe[1];
	end;

	local myYuanbao = MainPlayerModel.humanDetailInfo.eaUnBindMoney;
	if myYuanbao < Questcfg.need then 
		FloatManager:AddNormal( StrConfig['homestead047']);
		return 
	end;

	local func = function (desc) 
		--请求刷新
		self.isShowremind = not desc;
		HomesteadController:Questinfo(1)
	end
	if self.isShowremind then 
		UIConfirmWithNoTip:Open(string.format(StrConfig["homestead066"],"#00ff00",Questcfg.need),func)
	else
		HomesteadController:Questinfo(1)
	end
end;

function UIHomesQuestList:OnScrollBar()
	local objSwf = self.objSwf;
	local index = objSwf.scrollbar.position;
	self.curIndex = index;
	self:ShowUiList()
end;

function UIHomesQuestList:UpdataUiInfo()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local list = HomesteadModel:GetQuestInfo();
	objSwf.scrollbar:setScrollProperties(6,0,#list-6);
	objSwf.scrollbar.trackScrollPageSize = 6;
	objSwf.scrollbar.position = 0;
	self:ShowUiList();
end;

function UIHomesQuestList:ShowUiList()
	local objSwf = self.objSwf
	local questVo =  HomesteadModel:GetQuestInfo();
	local index = self.curIndex;
	for i=1,6 do 
		local item = objSwf['item'..i];
		local data = questVo[index + i]
		if data then 
			local cfg = t_homequestrange[data.tid];
			if not cfg then 
				-- trace(cfg)
				print(data.tid)
				print(debug.traceback());
				return
			end;
			item.check_btn.guid = data.guid;
		--	item.lvl_txt.htmlText = data.questlvl;
			item.Name_txt.htmlText =  HomesteadUtil:GetQualityColor(data.quality,cfg.QuestName);
		--	local read = HomesteadUtil:GetQuestBaseRate(data,nil,true)
			--item.succeed_txt.htmlText = string.format("%.2f",read).."%";
			--local t,s,f = CTimeFormat:sec2format(data.time)
			local sourStr = ResUtil:GetHomeQuestIcon(cfg.QuestType * 10 + data.quality);
			if sourStr ~= item.icon_load.source then 
				item.icon_load.source = sourStr
			end;
			local chineseTime = HomesteadUtil:GetChineseTime(data.time)
			item.questtime_txt.htmlText = chineseTime
			-- local monNum = 0;
			-- for i,info in pairs(data.monsterVo) do 
			-- 	if info.id > 0 then 
			-- 		monNum = monNum  + 1;
			-- 	end;
			-- end;
			--item.monterNum_mc:gotoAndStop(monNum)
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
				reward3.count = 1
				table.push(rewardList,reward3:GetUIData())
			end;
			--注掉任务接去状态，下个版本改~
			-- if data.questState == 1 then 
			-- 	item.check_btn.label = StrConfig['homestead070']
			-- else
			-- 	item.check_btn.label = StrConfig['homestead071']
			-- end;
			--item.check_btn.disabled = data.questState == 1 and true or false;
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
end;

function UIHomesQuestList:OnCheckClick(target)
	UIHomesAQuestVo:SetUIdata(target.guid)
	UIHomesteadMainView:ShowAquestView()
end;

function UIHomesQuestList:SetQuestUpdataTime()
	if not self:IsShow() then return end;
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local time = HomesteadModel:GetQuestTime()
	local t,s,f = CTimeFormat:sec2format(time)
	local str = string.format("%02d:%02d:%02d",t,s,f)
	objSwf.questnum_txt.htmlText = str;

end;

	-- notifaction
function UIHomesQuestList:ListNotificationInterests()
	return {
		NotifyConsts.HomesteadQuestlistUpdata,
		}
end;
function UIHomesQuestList:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.HomesteadQuestlistUpdata then
		self:UpdataUiInfo();
	end;
end;

-----------------------------以下是引导---------------------
function UIHomesQuestList:GetFirstQuestBtn()
	if not self:IsShow() then return nil; end
	return self.objSwf.item1.check_btn;
end

--直接打开第一个任务详情
function UIHomesQuestList:OpenFirstQuest()
	if not self:IsShow() then return; end
	local list = HomesteadModel:GetQuestInfo()
	local vo = list[1]
	UIHomesAQuestVo:SetUIdata(vo.guid)
	UIHomesteadMainView:ShowAquestView()
end
--[[
	战场奖励界面
	wangshuai
]]
_G.UIZhanChangReward = BaseUI:new("UIZhanChangReward")
	
UIZhanChangReward.isHaveVictory = false;
UIZhanChangReward.isHaveleisha = false;
UIZhanChangReward.isHavegongx = false;
UIZhanChangReward.itemList = {};

UIZhanChangReward.timerKey = nil;
UIZhanChangReward.time = 30;

function UIZhanChangReward:Create()
	self:AddSWF("zhancRewardpanel.swf",true,"center")
end;

function UIZhanChangReward:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:CloseBtn()end;
	for i=1,4 do 
		objSwf["item"..i].rollOver = function() self:ItemOver(i)end;
		objSwf["item"..i].rollOut = function() self:ItemOut(i)end;
 	end;
 	objSwf.closepanel.click = function() self:ClosePanel()end;

	objSwf.lastTimer.htmlText = string.format(StrConfig["zhanchang110"],30)
end;
function UIZhanChangReward:ItemOver(i)
	local vo = self.itemList[i];
	if not vo then return end;
	local tips = vo:GetTipsInfo();
	if not tips then return end;
	TipsManager:ShowTips(tips.tipsType,tips.info,tips.tipsShowType)
end;

function UIZhanChangReward:Ontimer()
	if not UIZhanChangReward.bShowState then return; end
	UIZhanChangReward.time = UIZhanChangReward.time - 1;
	local objSwf = UIZhanChangReward.objSwf;
	objSwf.lastTimer.htmlText = string.format(StrConfig["zhanchang110"],UIZhanChangReward.time)
	if UIZhanChangReward.time <= 0 then 
		TimerManager:UnRegisterTimer(UIZhanChangReward.timerKey);
		UIZhanChangReward.timerKey = nil;
		UIZhanChangReward:Hide();
	end;
end;


function UIZhanChangReward:ItemOut(i)
	TipsManager:Hide();
end;
function UIZhanChangReward:OnShow()
	local objSwf = self.objSwf;
	if UIZhanChErjiView:IsShow() then 
		UIZhanChErjiView:Hide();
	end;
	self.time = 30
	objSwf.lastTimer.htmlText = string.format(StrConfig["zhanchang110"],self.time)
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	self.timerKey = TimerManager:RegisterTimer(self.Ontimer,1000,self.time);

	local mycamp = ActivityZhanChang:GetMyCamp();
	local rewardInfo = ActivityZhanChang.zcReward;
	if rewardInfo.victory == mycamp then 
		-- 我赢了
		self.isHaveVictory = true;
		SoundManager:PlaySfx(2019);
	else
		-- 我输了
		self.isHaveVictory = false;
		SoundManager:PlaySfx(2020);
	end;

	local info1 = rewardInfo[1];
	local info2 = rewardInfo[2];
	local info3 = rewardInfo[3];

	objSwf.icon1.source = ResUtil:GetHeadIcon(info1.icon);
	objSwf.icon2.source = ResUtil:GetHeadIcon(info2.icon);
	objSwf.icon3.source = ResUtil:GetHeadIcon(info3.icon);

	objSwf.name1.htmlText = info1.roleName;
	objSwf.name2.htmlText = info2.roleName;
	objSwf.name3.htmlText = info3.roleName;

	objSwf.num1.num = info1.num
	objSwf.num2.num = info2.num
	objSwf.num3.num = info3.num

	-- 显示奖励模块
	self:ShowResward()
	-- 显示结果图片
	self:ShowResuiltImg()
end;
function UIZhanChangReward:ShowResuiltImg()
	local objSwf = self.objSwf;
	local rewardInfo = ActivityZhanChang.zcReward;
	local mycamp = ActivityZhanChang:GetMyCamp()
	if rewardInfo.victory == 7 then  -- 域外
		objSwf.myVictory._visible = false;
		objSwf.myFailure._visible = true;
	elseif rewardInfo.victory == 6 then  -- 大千 
		objSwf.myFailure._visible = false;
		objSwf.myVictory._visible = true;
	end;
	if mycamp == 7 then 
		objSwf.mycamp2_mc:gotoAndStop(1)
		objSwf.mycamp1_mc:gotoAndStop(2)
	elseif mycamp == 6 then 
		objSwf.mycamp2_mc:gotoAndStop(2)
		objSwf.mycamp1_mc:gotoAndStop(1)
	end;
end;

function UIZhanChangReward:ShowResward()
	local objSwf = self.objSwf
	local serverlvl = MainPlayerController:GetServerLvl();
	local cfg = t_campAward[serverlvl];
	local mycamp = ActivityZhanChang.zcInfoVo;
	local addnum,contr,lxnum = self:GetmyishaveReward();
	local rewardInfo = ActivityZhanChang.zcReward;  --奖励信息


	if addnum == 0 then 
		-- 未上榜
		self.isHaveleisha = false;
		objSwf.mynum1.htmlText = mycamp.addnum..string.format(StrConfig["zcReward022"]);
	else
		-- 上榜
		self.isHaveleisha = true;
		objSwf.mynum1.htmlText = mycamp.addnum..string.format(StrConfig["zcReward023"],addnum);
	end;
	if contr == 0 then 
		--未上榜
		self.isHavegongx = false;
		objSwf.mynum3.htmlText = mycamp.contr..string.format(StrConfig["zcReward022"]);
	else
		-- 上榜
		self.isHavegongx = true;
		objSwf.mynum3.htmlText = mycamp.contr..string.format(StrConfig["zcReward023"],contr);
	end;
	if lxnum == 0 then 
		-- 未上榜
		objSwf.mynum2.htmlText = mycamp.contnum..string.format(StrConfig["zcReward022"]);
	else
		-- 上榜
		objSwf.mynum2.htmlText = mycamp.contnum..string.format(StrConfig["zcReward023"],lxnum);
	end;



	local canyu = cfg.join;
	local itemvo = RewardSlotVO:new();
	itemvo.id = canyu;
	itemvo.count = 1;
	objSwf.item4:setData(itemvo:GetUIData());
	self.itemList[4] = itemvo;
	if self.isHaveVictory == true then 
		--  有胜利奖励
		local win  = cfg.win;
		local itemvo3 = RewardSlotVO:new();
		itemvo3.id = win;
		itemvo3.count = 1;
		objSwf.item3:setData(itemvo3:GetUIData());
		self.itemList[3] = itemvo3;
		objSwf.itemm3._visible = false;
	else
		objSwf.item3._visible =false;
		objSwf.itemm3._visible =true;
	end;

	if self.isHaveleisha == true then 
		-- 有累杀奖励
		--local jisha = split(cfg.kill,",");
		local itemvo1 = RewardSlotVO:new();
		--itemvo1.id = tonumber(jisha[addnum]);
		itemvo1.id = tonumber(cfg.kill[addnum]);
		itemvo1.count = 1;
		objSwf.item1:setData(itemvo1:GetUIData());
		self.itemList[1] = itemvo1;
		objSwf.itemm1._visible = false
	else
		objSwf.itemm1._visible = true;
		objSwf.item1._visible = false;
	end;
	if self.isHavegongx == true then 
		-- 有贡献奖励
		--local gongx = split(cfg.contri,",");
		local itemvo2 = RewardSlotVO:new();
		--itemvo2.id = tonumber(gongx[contr]);
		itemvo2.id = tonumber(cfg.contri[contr]);
		itemvo2.count = 1;
		objSwf.item2:setData(itemvo2:GetUIData())
		self.itemList[2] = itemvo2;
		objSwf.itemm2._visible = false;
	else
		objSwf.itemm2._visible = true;
		objSwf.item2._visible =false;
	end; 



end;

function UIZhanChangReward:GetGiftbag(id)
	return t_item[id];
end;

function UIZhanChangReward:GetmyishaveReward()
	local addnum = 0;
	local contr = 0;
	local lxnum = 0;

	local name = MainPlayerModel.humanDetailInfo.eaName;
	local leishalist = ActivityZhanChang.zcSkllList;
	local gongxianlist = ActivityZhanChang.zcContrList;
	local lianxulist =ActivityZhanChang.zclianxuMaxNum;

	for l,e in ipairs(leishalist) do 
		if e.roleName == name then 
			addnum = l;
		end;
	end;

	for g,x in ipairs(gongxianlist) do 
		if x.roleName == name then 
			contr = g;
		end;
	end;

	for i,s in ipairs(lianxulist) do 
		if s.roleName == name then 
			lxnum = i;
		end;
	end;

	return addnum,contr,lxnum;
end

function UIZhanChangReward:OnHide()	
	--请求领取奖励
	self.itemList = {};
	ActivityZhanChang:ReqZhancGetReward()
	local activity = ActivityModel:GetActivity(ActivityController:GetCurrId());
	if not activity then return; end
	ActivityController:QuitActivity(activity:GetId());
	ZhChFlagController:EscMap()

	self.isHaveVictory = false;
	self.isHaveleisha = false;
	self.isHavegongx = false;
end;

function UIZhanChangReward:CloseBtn()
	self:Hide();
end;

function UIZhanChangReward:ClosePanel()
	self:Hide();
end;

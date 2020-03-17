--[[DailyMustDoView
zhangshuhui
2015年3月18日14:50:00
]]

_G.UIDailyMustDoView = BaseUI:new("UIDailyMustDoView")

UIDailyMustDoView.tabButton = {};
--类型 0 今日必做，1昨日追回
UIDailyMustDoView.type = 0;
--奖励分类 0 全部，1 经验，2 银两，3 灵力，装备，5道具
UIDailyMustDoView.style = 0;

UIDailyMustDoView.awardlist = {};
UIDailyMustDoView.todayawardlistgroup = {};
UIDailyMustDoView.yestyawardlistgroup = {};
UIDailyMustDoView.awardlistcount = 3;--UI一页奖励总数
UIDailyMustDoView.curpageIndex = 0;--当前显示页数
UIDailyMustDoView.pagecount = 0;--总页数

function UIDailyMustDoView:Create()
	self:AddSWF("dailyMustDoPanel.swf", true, "center")
end

function UIDailyMustDoView:OnLoaded(objSwf,name)
	--关闭
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end;
	
	objSwf.MainBG.hitTestDisable = true;
	
	self.tabButton[DailyMustDoConsts.TODAY] = objSwf.btntoday;
	self.tabButton[DailyMustDoConsts.YESTY] = objSwf.btnyestd;
	self.tabButton[DailyMustDoConsts.ALL] = objSwf.btnall;
	self.tabButton[DailyMustDoConsts.EXP] = objSwf.btnexp;
	self.tabButton[DailyMustDoConsts.YINLIANG] = objSwf.btnyinliang;
	self.tabButton[DailyMustDoConsts.ZHENQI] = objSwf.btnzhenqi;
	self.tabButton[DailyMustDoConsts.EQUIT] = objSwf.btnequit;
	self.tabButton[DailyMustDoConsts.TOOL] = objSwf.btntool;
	for name,btn in pairs(self.tabButton) do
		btn.click = function() self:OnTabButtonClick(name); end;
	end
	
	--奖励列表
	self.todayawardlistgroup = {}
	self.yestyawardlistgroup = {}
	for i=1,self.awardlistcount do
		self.todayawardlistgroup[i] = objSwf.todaypanel["awardlist"..i];
		
		self.todayawardlistgroup[i].btnyinliang.click = function() self:OnBtnGetTDYLAwardClick(i) end
		self.todayawardlistgroup[i].btnyuanbao.click = function() self:OnBtnGetTDYBAwardClick(i) end

		self.todayawardlistgroup[i].btnyinliang.rollOver = function() self:OnBtnTDYinLiangRollOver(i); end
		self.todayawardlistgroup[i].btnyinliang.rollOut = function() TipsManager:Hide(); end
		self.todayawardlistgroup[i].btnyuanbao.rollOver = function() self:OnBtnTDYuanBaoRollOver(i); end
		self.todayawardlistgroup[i].btnyuanbao.rollOut = function() TipsManager:Hide(); end
		
		--特效播放完
		objSwf.todaypanel["awardlist"..i].effectfinish.complete = function() self:ShowImgFinish(i); end
		
		--TIP
		RewardManager:RegisterListTips(self.todayawardlistgroup[i].awardList);
		
		
		self.yestyawardlistgroup[i] = objSwf.yestypanel["awardlist"..i];
		
		self.yestyawardlistgroup[i].btnyinliang.click = function() self:OnBtnGetYDYLAwardClick(i) end
		self.yestyawardlistgroup[i].btnyuanbao.click = function() self:OnBtnGetYDYBAwardClick(i) end
		
		self.yestyawardlistgroup[i].btnyinliang.rollOver = function() self:OnBtnYDYinLiangRollOver(i); end
		self.yestyawardlistgroup[i].btnyinliang.rollOut = function() TipsManager:Hide(); end
		self.yestyawardlistgroup[i].btnyuanbao.rollOver = function() self:OnBtnYDYuanBaoRollOver(i); end
		self.yestyawardlistgroup[i].btnyuanbao.rollOut = function() TipsManager:Hide(); end
		
		--特效播放完
		objSwf.yestypanel["awardlist"..i].effectzhuihui.complete = function() self:ShowImgZhuiHui(i); end
		
		--TIP
		RewardManager:RegisterListTips(self.yestyawardlistgroup[i].awardList);
	end
	
	objSwf.todaypanel.btnallfinishyl.click = function() self:OnBtnGetAllTDYLAwardClick() end
	objSwf.todaypanel.btnallfinishyb.click = function() self:OnBtnGetAllTDYBAwardClick() end
	objSwf.yestypanel.btnallfinishyl.click = function() self:OnBtnGetAllYDYLAwardClick() end
	objSwf.yestypanel.btnallfinishyb.click = function() self:OnBtnGetAllYDYBAwardClick() end
	
	objSwf.todaypanel.btnallfinishyl.rollOver = function() self:OnBtnAllTDYLRollOver(); end
	objSwf.todaypanel.btnallfinishyl.rollOut = function() TipsManager:Hide(); end
	objSwf.todaypanel.btnallfinishyb.rollOver = function() self:OnBtnAllTDYBRollOver(); end
	objSwf.todaypanel.btnallfinishyb.rollOut = function() TipsManager:Hide(); end
	objSwf.yestypanel.btnallfinishyl.rollOver = function() self:OnBtnAllYDYLRollOver(); end
	objSwf.yestypanel.btnallfinishyl.rollOut = function() TipsManager:Hide(); end
	objSwf.yestypanel.btnallfinishyb.rollOver = function() self:OnBtnAllYDYBRollOver(); end
	objSwf.yestypanel.btnallfinishyb.rollOut = function() TipsManager:Hide(); end
		
	--TIP
	RewardManager:RegisterListTips(objSwf.todaypanel.awardList);
		
	--滚轮事件
	objSwf.todaypanel.scrollBar.scroll = function() self:OnTDScrollBarscrollClick(); end;
	objSwf.todaypanel.listscrollBar.scroll = function() self:OnTDListScrollBarscrollClick(); end;
	objSwf.todaypanel.listscrollBar._visible = false;
	
	objSwf.yestypanel.scrollBar.scroll = function() self:OnYDScrollBarscrollClick(); end;
	objSwf.yestypanel.listscrollBar.scroll = function() self:OnYDListScrollBarscrollClick(); end;
	objSwf.yestypanel.listscrollBar._visible = false;
end

function UIDailyMustDoView:OnDelete()
	for k,_ in pairs(self.tabButton) do
		self.tabButton[k] = nil;
	end
	for k,_ in pairs(self.todayawardlistgroup) do
		self.todayawardlistgroup[k] = nil;
	end
	for k,_ in pairs(self.yestyawardlistgroup) do
		self.yestyawardlistgroup[k] = nil;
	end
end


function UIDailyMustDoView:IsTween()
	return true;
end

function UIDailyMustDoView:GetPanelType()
	return 1;
end

function UIDailyMustDoView:IsShowSound()
	return true;
end

function UIDailyMustDoView:IsShowLoading()
	return true;
end

-- function UIDailyMustDoView:GetWidth()
	-- return 1;
-- end

-- function UIDailyMustDoView:GetHeight()
	-- return 1;
-- end

function UIDailyMustDoView:OnShow(name)
	--申请数据
	DungeonController:ReqDungeonUpdate();
	self:ReqGetDailyMustDoList();
	--初始化数据
	self:InitData();
	--显示
	self:OnTabButtonClick(DailyMustDoConsts.TODAY);
end

--点击关闭按钮
function UIDailyMustDoView:OnBtnCloseClick()
	self:Hide();
end

function UIDailyMustDoView:OnHide()
	UIDailyMustDoMsgBoxView:Hide();
end
-------------------事件------------------
function UIDailyMustDoView:OnBtnGetTDYLAwardClick(i)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local Index = self.curpageIndex + i;
	local vo = self.awardlist[Index];
	if not vo then return; end
	
	--已完成
	if DailyMustDoUtil:GetDailyMustNum(vo.id, self.type) == 0 then
		return;
	end
	
	UIDailyMustDoMsgBoxView:OpenPanel(vo.id, self.type, DailyMustDoConsts.typeyinliang, false);
end
function UIDailyMustDoView:OnBtnGetTDYBAwardClick(i)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if VipController:GetSaodang100() <= 0 then
		FloatManager:AddNormal( string.format( StrConfig["dailymustdo32"],StrConfig["dailymustdo100"..t_vippower[20319].type]), objSwf.todaypanel["awardlist"..i].btnyuanbao);
		return;
	end
	local Index = self.curpageIndex + i;
	local vo = self.awardlist[Index];
	if not vo then return; end
	
	--已完成
	if DailyMustDoUtil:GetDailyMustNum(vo.id, self.type) == 0 then
		return;
	end
	
	UIDailyMustDoMsgBoxView:OpenPanel(vo.id, self.type, DailyMustDoConsts.typeyuanbao, false);
end

function UIDailyMustDoView:OnBtnGetYDYLAwardClick(i)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local Index = self.curpageIndex + i;
	local vo = self.awardlist[Index];
	if not vo then return; end
	
	--已完成
	if DailyMustDoUtil:GetDailyMustNum(vo.id, self.type) == 0 then
		return;
	end
	
	UIDailyMustDoZhuiHuiBoxView:OpenPanel(vo.id, self.type, DailyMustDoConsts.typeyinliang, false);
end
function UIDailyMustDoView:OnBtnGetYDYBAwardClick(i)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if VipController:GetZiyuanzhuihui100() <= 0 then
		FloatManager:AddNormal( string.format( StrConfig["dailymustdo32"],StrConfig["dailymustdo100"..t_vippower[20319].type]), objSwf.yestypanel["awardlist"..i].btnyuanbao);
		return;
	end
	local Index = self.curpageIndex + i;
	local vo = self.awardlist[Index];
	if not vo then return; end
	
	--已完成
	if DailyMustDoUtil:GetDailyMustNum(vo.id, self.type) == 0 then
		return;
	end
	
	UIDailyMustDoZhuiHuiBoxView:OpenPanel(vo.id, self.type, DailyMustDoConsts.typeyuanbao, false);
end

function UIDailyMustDoView:OnBtnGetAllTDYLAwardClick()
	--如果全部完成了
	if DailyMustDoUtil:GetDailyMustDoNum(self.type) == 0 then
		return;
	end
	
	UIDailyMustDoMsgBoxView:OpenPanel(0, self.type, DailyMustDoConsts.typeyinliang, true);
end
function UIDailyMustDoView:OnBtnGetAllTDYBAwardClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if VipController:GetSaodang100() <= 0 then
		FloatManager:AddNormal( string.format( StrConfig["dailymustdo32"],StrConfig["dailymustdo100"..t_vippower[20319].type]), objSwf.todaypanel.btnallfinishyb);
		return;
	end
	--如果全部完成了
	if DailyMustDoUtil:GetDailyMustDoNum(self.type) == 0 then
		return;
	end
	
	UIDailyMustDoMsgBoxView:OpenPanel(0, self.type, DailyMustDoConsts.typeyuanbao, true);
end
function UIDailyMustDoView:OnBtnGetAllYDYLAwardClick()
	--如果全部完成了
	if DailyMustDoUtil:GetDailyMustDoNum(self.type) == 0 then
		return;
	end
	
	UIDailyMustDoZhuiHuiBoxView:OpenPanel(0, self.type, DailyMustDoConsts.typeyinliang, true);
	
	--DailyMustDoController:ReqFinishAllDailyMustDo(self.type, 1);
end
function UIDailyMustDoView:OnBtnGetAllYDYBAwardClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if VipController:GetZiyuanzhuihui100() <= 0 then
		FloatManager:AddNormal( string.format( StrConfig["dailymustdo32"],StrConfig["dailymustdo100"..t_vippower[20319].type]), objSwf.yestypanel.btnallfinishyb);
		return;
	end
	--如果全部完成了
	if DailyMustDoUtil:GetDailyMustDoNum(self.type) == 0 then
		return;
	end
	
	UIDailyMustDoZhuiHuiBoxView:OpenPanel(0, self.type, DailyMustDoConsts.typeyuanbao, true);
end

function UIDailyMustDoView:OnBtnTDYinLiangRollOver(i)
	local Index = self.curpageIndex + i;
	local vo = self.awardlist[Index];
	if not vo then return; end
	
	local consumenum = DailyMustDoUtil:GetConsumeNum(vo.id, self.type, DailyMustDoConsts.typeyinliang);
	local pecent = DailyMustDoUtil:GetRewardPecent(vo.id, self.type, DailyMustDoConsts.typeyinliang);
	
	local str = string.format( StrConfig["dailymustdo2"], string.format( StrConfig["dailymustdo7"], consumenum),pecent);
	
	TipsManager:ShowTips( TipsConsts.Type_Normal, str, TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
end
function UIDailyMustDoView:OnBtnTDYuanBaoRollOver(i)
	local Index = self.curpageIndex + i;
	local vo = self.awardlist[Index];
	if not vo then return; end
	
	local consumenum = DailyMustDoUtil:GetConsumeNum(vo.id, self.type, DailyMustDoConsts.typeyuanbao);
	local pecent = DailyMustDoUtil:GetRewardPecent(vo.id, self.type, DailyMustDoConsts.typeyuanbao);
	local str = StrConfig["dailymustdo34"]..string.format( StrConfig["dailymustdo2"], string.format( StrConfig["dailymustdo6"], consumenum),pecent);
	TipsManager:ShowTips( TipsConsts.Type_Normal, str, TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
end
function UIDailyMustDoView:OnBtnYDYinLiangRollOver(i)
	local Index = self.curpageIndex + i;
	local vo = self.awardlist[Index];
	if not vo then return; end
	
	local strname,strnum,isnull = DailyMustDoUtil:GetRewardInfoText(vo.id, self.type, DailyMustDoConsts.typeyuanbao);
	if isnull == true then
		local str = string.format( StrConfig["dailymustdo23"], string.format( StrConfig["dailymustdo7"], 0));
		TipsManager:ShowTips( TipsConsts.Type_Normal, str, TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
		return;
	end
	
	local consumenum = DailyMustDoUtil:GetConsumeNum(vo.id, self.type, DailyMustDoConsts.typeyinliang);
	local pecent = DailyMustDoUtil:GetRewardPecent(vo.id, self.type, DailyMustDoConsts.typeyinliang);
	local str = string.format( StrConfig["dailymustdo8"], string.format( StrConfig["dailymustdo7"], consumenum),pecent);
	
	TipsManager:ShowTips( TipsConsts.Type_Normal, str, TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
end
function UIDailyMustDoView:OnBtnYDYuanBaoRollOver(i)
	local Index = self.curpageIndex + i;
	local vo = self.awardlist[Index];
	if not vo then return; end
	
	local strname,strnum,isnull = DailyMustDoUtil:GetRewardInfoText(vo.id, self.type, DailyMustDoConsts.typeyuanbao);
	if isnull == true then
		local str = string.format( StrConfig["dailymustdo23"], string.format( StrConfig["dailymustdo7"], 0));
		TipsManager:ShowTips( TipsConsts.Type_Normal, str, TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
		return;
	end
	
	local consumenum = DailyMustDoUtil:GetConsumeNum(vo.id, self.type, DailyMustDoConsts.typeyuanbao);
	local pecent = DailyMustDoUtil:GetRewardPecent(vo.id, self.type, DailyMustDoConsts.typeyuanbao);
	local str = StrConfig["dailymustdo33"]..string.format( StrConfig["dailymustdo8"], string.format( StrConfig["dailymustdo6"], consumenum),pecent);
	
	TipsManager:ShowTips( TipsConsts.Type_Normal, str, TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
end

function UIDailyMustDoView:OnBtnAllTDYLRollOver()
	local allconstomenum = DailyMustDoUtil:GetAllConstomeNum(self.type, DailyMustDoConsts.typeyinliang);
	local pecent = DailyMustDoUtil:GetRewardPecent(1, self.type, DailyMustDoConsts.typeyinliang);
	local str = string.format( StrConfig["dailymustdo4"], string.format( StrConfig["dailymustdo7"], allconstomenum),pecent);
	
	TipsManager:ShowTips( TipsConsts.Type_Normal, str, TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
end
function UIDailyMustDoView:OnBtnAllTDYBRollOver()
	local allconstomenum = DailyMustDoUtil:GetAllConstomeNum(self.type, DailyMustDoConsts.typeyuanbao);
	local pecent = DailyMustDoUtil:GetRewardPecent(1, self.type, DailyMustDoConsts.typeyuanbao);
	local str = StrConfig["dailymustdo34"]..string.format( StrConfig["dailymustdo4"], string.format( StrConfig["dailymustdo6"], allconstomenum),pecent);
	
	TipsManager:ShowTips( TipsConsts.Type_Normal, str, TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
end
function UIDailyMustDoView:OnBtnAllYDYLRollOver()
	local strname,strnum,isnull = DailyMustDoUtil:GetRewardInfoText(0, self.type, DailyMustDoConsts.typeyinliang);
	if isnull == true then
		local str = string.format( StrConfig["dailymustdo25"], string.format( StrConfig["dailymustdo7"], 0));
		TipsManager:ShowTips( TipsConsts.Type_Normal, str, TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
		return;
	end

	local allconstomenum = DailyMustDoUtil:GetAllConstomeNum(self.type, DailyMustDoConsts.typeyinliang);
	local pecent = DailyMustDoUtil:GetRewardPecent(1, self.type, DailyMustDoConsts.typeyinliang);
	local str = string.format( StrConfig["dailymustdo10"], string.format( StrConfig["dailymustdo7"], allconstomenum),pecent);
	
	TipsManager:ShowTips( TipsConsts.Type_Normal, str, TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
end
function UIDailyMustDoView:OnBtnAllYDYBRollOver()
	local strname,strnum,isnull = DailyMustDoUtil:GetRewardInfoText(0, self.type, DailyMustDoConsts.typeyuanbao);
	if isnull == true then
		local str = string.format( StrConfig["dailymustdo25"], string.format( StrConfig["dailymustdo7"], 0));
		TipsManager:ShowTips( TipsConsts.Type_Normal, str, TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
		return;
	end
	
	local allconstomenum = DailyMustDoUtil:GetAllConstomeNum(self.type, DailyMustDoConsts.typeyuanbao);
	local pecent = DailyMustDoUtil:GetRewardPecent(1, self.type, DailyMustDoConsts.typeyuanbao);
	local str = StrConfig["dailymustdo33"]..string.format( StrConfig["dailymustdo10"], string.format( StrConfig["dailymustdo6"], allconstomenum),pecent);
	
	TipsManager:ShowTips( TipsConsts.Type_Normal, str, TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
end

function UIDailyMustDoView:OnTDScrollBarscrollClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	if not objSwf.todaypanel.scrollBar.position then
		return;
	end
	if not objSwf.todaypanel.listscrollBar.position then
		return;
	end
	
	--下限
	if objSwf.todaypanel.scrollBar.position < 0 then
		objSwf.todaypanel.scrollBar.position = 0;
		objSwf.todaypanel.listscrollBar.position = 0;
		return;
	end
	
	--上限
	if objSwf.todaypanel.scrollBar.position > self.pagecount then
		objSwf.todaypanel.scrollBar.position = self.pagecount;
		objSwf.todaypanel.listscrollBar.position = self.pagecount;
		return;
	end
	
	--未变
	if self.curpageIndex == objSwf.todaypanel.scrollBar.position then
		return;
	end
	objSwf.todaypanel.listscrollBar.position = objSwf.todaypanel.scrollBar.position;
	self.curpageIndex = objSwf.todaypanel.scrollBar.position;
	
	self:ShowTaskInfo();
end
function UIDailyMustDoView:OnTDListScrollBarscrollClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	if not objSwf.todaypanel.scrollBar.position then
		return;
	end
	if not objSwf.todaypanel.listscrollBar.position then
		return;
	end
	
	--下限
	if objSwf.todaypanel.listscrollBar.position < 0 then
		objSwf.todaypanel.listscrollBar.position = 0;
		objSwf.todaypanel.scrollBar.position = 0;
		return;
	end
	
	--上限
	if objSwf.todaypanel.listscrollBar.position > self.pagecount then
		objSwf.todaypanel.listscrollBar.position = self.pagecount;
		objSwf.todaypanel.scrollBar.position = self.pagecount;
		return;
	end
	
	--未变
	if self.curpageIndex == objSwf.todaypanel.listscrollBar.position then
		return;
	end
	objSwf.todaypanel.scrollBar.position = objSwf.todaypanel.listscrollBar.position;
	self.curpageIndex = objSwf.todaypanel.listscrollBar.position;
	
	self:ShowTaskInfo();
end
function UIDailyMustDoView:OnYDScrollBarscrollClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	if not objSwf.yestypanel.scrollBar.position then
		return;
	end
	if not objSwf.yestypanel.listscrollBar.position then
		return;
	end
	
	--下限
	if objSwf.yestypanel.scrollBar.position < 0 then
		objSwf.yestypanel.scrollBar.position = 0;
		objSwf.yestypanel.listscrollBar.position = 0;
		return;
	end
	
	--上限
	if objSwf.yestypanel.scrollBar.position > self.pagecount then
		objSwf.yestypanel.scrollBar.position = self.pagecount;
		objSwf.yestypanel.listscrollBar.position = self.pagecount;
		return;
	end
	
	--未变
	if self.curpageIndex == objSwf.yestypanel.scrollBar.position then
		return;
	end

	objSwf.yestypanel.listscrollBar.position = objSwf.yestypanel.scrollBar.position;
	self.curpageIndex = objSwf.yestypanel.scrollBar.position;
	
	self:ShowTaskInfo();
end
function UIDailyMustDoView:OnYDListScrollBarscrollClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	if not objSwf.yestypanel.scrollBar.position then
		return;
	end
	if not objSwf.yestypanel.listscrollBar.position then
		return;
	end
	
	--下限
	if objSwf.yestypanel.listscrollBar.position < 0 then
		objSwf.yestypanel.listscrollBar.position = 0;
		objSwf.yestypanel.scrollBar.position = 0;
		return;
	end
	
	--上限
	if objSwf.yestypanel.listscrollBar.position > self.pagecount then
		objSwf.yestypanel.listscrollBar.position = self.pagecount;
		objSwf.yestypanel.scrollBar.position = self.pagecount;
		return;
	end
	
	--未变
	if self.curpageIndex == objSwf.yestypanel.listscrollBar.position then
		return;
	end

	objSwf.yestypanel.scrollBar.position = objSwf.yestypanel.listscrollBar.position;
	self.curpageIndex = objSwf.yestypanel.listscrollBar.position;
	
	self:ShowTaskInfo();
end

function UIDailyMustDoView:ShowImgFinish(i)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	
	objSwf.todaypanel["awardlist"..i].imggetted._visible = true;
end
function UIDailyMustDoView:ShowImgZhuiHui(i)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	objSwf.yestypanel["awardlist"..i].imggetted._visible = true;
end

function UIDailyMustDoView:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.JinRiBiZuoList then
		self:ResetData();
		self:InitUI();
		self:ShowTaskInfo();
	elseif name == NotifyConsts.JinRiBiZuoListUpdata then
		self:UpdateTaskListInfo(body);
	elseif name == NotifyConsts.JinBiBiZuoUpdata then
		self:UpdateTaskInfo(body);
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaLevel then
			self:ReqGetDailyMustDoListlvl();
		end
	end
end

function UIDailyMustDoView:ListNotificationInterests()
	return {NotifyConsts.JinRiBiZuoList,
			NotifyConsts.JinRiBiZuoListUpdata,
			NotifyConsts.JinBiBiZuoUpdata,
			NotifyConsts.PlayerAttrChange};
end

function UIDailyMustDoView:ReqGetDailyMustDoList()
	DailyMustDoController:ReqGetDailyMustDoList();
end

function UIDailyMustDoView:ReqGetDailyMustDoListlvl()
	if DailyMustDoUtil:IsHaveNewOpen() == true then
		DailyMustDoController:ReqGetDailyMustDoList();
	end
end

function UIDailyMustDoView:InitData()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	self.type = DailyMustDoConsts.typetoday;
	self.style = 0;
end

function UIDailyMustDoView:ResetData()
	self.awardlist = {};
	self.awardlist = DailyMustDoUtil:GetDailyMustDoList(self.type, self.style);
	self.curpageIndex = 0;
	self.pagecount = #self.awardlist - self.awardlistcount;
	if self.pagecount < 0 then
		self.pagecount = 0;
	end
end

function UIDailyMustDoView:InitUI()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	if self.type == DailyMustDoConsts.typetoday then
		objSwf.todaypanel._visible = true;
		objSwf.todaypanel.imgnofinish._visible = false;
		objSwf.yestypanel._visible = false;
	
		objSwf.todaypanel.scrollBar:setScrollProperties(self.awardlistcount,0,self.pagecount);
		objSwf.todaypanel.scrollBar.trackScrollPageSize = self.awardlistcount;
		objSwf.todaypanel.scrollBar.position = 0;
	else
		objSwf.todaypanel._visible = false;
		objSwf.yestypanel._visible = true;
		objSwf.yestypanel.imgnozhuihui._visible = false;
	
		objSwf.yestypanel.scrollBar:setScrollProperties(self.awardlistcount,0,self.pagecount);
		objSwf.yestypanel.scrollBar.trackScrollPageSize = self.awardlistcount;
		objSwf.yestypanel.scrollBar.position = 0;
	end
end

--显示列表
function UIDailyMustDoView:ShowTaskInfo()
	if self.type == DailyMustDoConsts.typetoday then
		self:ShowTodayTaskInfo();
	else
		self:ShowYestdTaskInfo();
	end
end

--更新今日一键按钮
function UIDailyMustDoView:UpdateTodayBtnYIJIan()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--一键按钮
	if DailyMustDoUtil:GetDailyMustDoNum(self.type) == 0 then
		objSwf.todaypanel.btnallfinishyl.visible = false;
		objSwf.todaypanel.btnallfinishyb.visible = false;
	else
		objSwf.todaypanel.btnallfinishyl.visible = false;
		objSwf.todaypanel.btnallfinishyb.visible = false;
	end
end

--更新昨日一键按钮
function UIDailyMustDoView:UpdateYestyBtnYIJIan()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--一键按钮
	if DailyMustDoUtil:GetDailyMustDoNum(self.type) == 0 then
		objSwf.yestypanel.btnallfinishyl.visible = false;
		objSwf.yestypanel.btnallfinishyb.visible = false;
	else
		objSwf.yestypanel.btnallfinishyb.visible = true;
		objSwf.yestypanel.btnallfinishyb.visible = false;
	end
end

--更新总奖励信息
function UIDailyMustDoView:UpdateAllRewardList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local list = DailyMustDoUtil:GetAllReward(self.type);
	local awardList = RewardManager:Parse(list);
	objSwf.todaypanel.awardList.dataProvider:cleanUp();
	objSwf.todaypanel.awardList.dataProvider:push(unpack(awardList));
	objSwf.todaypanel.awardList:invalidateData();
end

--更新今日奖励信息
function UIDailyMustDoView:UpdateTodayRewardList(vo, i, num)
	local awardList = {};
	local rewards = DailyMustDoUtil:GetReward(vo.param, vo.spe_type, vo.id, self.type);
	local str = "";
	-- if vo.id == 11 then
	-- 	str = DailyMustDoUtil:GetLSMDReward(num);
	-- else
--	if vo.id == 9 then
--		str = DailyMustDoUtil:GetLiuShuiReward(num);
--	elseif vo.id == 13 then
--		str = DailyMustDoUtil:GetDaBaoMiJingReward(num);
--	else
		str = DailyMustDoUtil:Parse(rewards, num);
--	end
	--已完成
	if num == 0 then
		awardList = RewardManager:ParseBlack(str);
	--未完成
	else
		awardList = RewardManager:Parse(str);
	end
			
	self.todayawardlistgroup[i].awardList.dataProvider:cleanUp();
	self.todayawardlistgroup[i].awardList.dataProvider:push(unpack(awardList));
	self.todayawardlistgroup[i].awardList:invalidateData();
end

--更新昨日奖励信息
function UIDailyMustDoView:UpdateYestyRewardList(vo, i, num)
	local awardList = {};
	local rewards = DailyMustDoUtil:GetReward(vo.param, vo.spe_type, vo.id, self.type);
	local str = "";
--	if vo.id == 5 and num > 0 then
--		str = rewards;
--	elseif vo.id == 9 then
--		str = DailyMustDoUtil:GetLiuShuiReward(num);
	-- elseif vo.id == 11 then
	-- 	str = DailyMustDoUtil:GetLSMDReward(num);
--	elseif vo.id == 13 then
--		str = DailyMustDoUtil:GetDaBaoMiJingReward(num);
--	else
		str = DailyMustDoUtil:Parse(rewards, num);
--	end
	
	--已完成
	if num == 0 then
		awardList = RewardManager:ParseBlack(str);
	--未完成
	else
		awardList = RewardManager:Parse(str);
	end
			
	self.yestyawardlistgroup[i].awardList.dataProvider:cleanUp();
	self.yestyawardlistgroup[i].awardList.dataProvider:push(unpack(awardList));
	self.yestyawardlistgroup[i].awardList:invalidateData();
end

--显示今日必做
function UIDailyMustDoView:ShowTodayTaskInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	for i=1,self.awardlistcount do
		self.todayawardlistgroup[i]._visible = false;
		
		self.todayawardlistgroup[i].effectfinish.visible = false;
		self.todayawardlistgroup[i].effectfinish:stopEffect();
	end
	
	objSwf.todaypanel.imgnofinish._visible = false;
	if not self.awardlist or #self.awardlist == 0 then
		objSwf.todaypanel.imgnofinish._visible = true;
	end
	
	for i=1,self.awardlistcount do
		local PageIndex = self.curpageIndex + i;
		local vo = self.awardlist[PageIndex];
		if vo then
			self.todayawardlistgroup[i]._visible = true;
			
			--得到剩余次数
			local num = DailyMustDoUtil:GetDailyMustNum(vo.id, self.type);
			
			--已完成
			if num == 0 then
				self.todayawardlistgroup[i].tfloadername.htmlText = string.format(StrConfig["dailymustdo28"],vo.name);
				self.todayawardlistgroup[i].tfname.htmlText = string.format(StrConfig["dailymustdo28"],StrConfig["dailymustdo29"]);
				self.todayawardlistgroup[i].loaderbg.source = ImgUtil:GetGrayImgUrl(ResUtil:GetDailyMustDoNameURL(vo.bgicon));
				self.todayawardlistgroup[i].tfnum._visible = false;
				
				self.todayawardlistgroup[i].btnyinliang.visible = false;
				self.todayawardlistgroup[i].btnyuanbao.visible = false;
				self.todayawardlistgroup[i].imggetted._visible = true;
			--未完成
			else
				self.todayawardlistgroup[i].tfloadername.htmlText = vo.name;
				self.todayawardlistgroup[i].tfname.htmlText = StrConfig["dailymustdo29"];
				self.todayawardlistgroup[i].loaderbg.source = ResUtil:GetDailyMustDoNameURL(vo.bgicon);
				local str = string.format(StrConfig["dailymustdo1"],num);
				self.todayawardlistgroup[i].tfnum.text = str;
				self.todayawardlistgroup[i].tfnum._visible = true;
				
				self.todayawardlistgroup[i].btnyinliang.visible = true;
--				self.todayawardlistgroup[i].btnyuanbao.visible = true;
				self.todayawardlistgroup[i].btnyuanbao.visible = false;
				self.todayawardlistgroup[i].imggetted._visible = false;
			end
			
			self:UpdateTodayRewardList(vo, i, num);
		end
	end
	
	--总奖励信息
	self:UpdateAllRewardList();
	
	--一键按钮
	self:UpdateTodayBtnYIJIan();
end

--显示昨日追回
function UIDailyMustDoView:ShowYestdTaskInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	for i=1,self.awardlistcount do
		self.yestyawardlistgroup[i]._visible = false;
		
		self.yestyawardlistgroup[i].effectzhuihui.visible = false;
		self.yestyawardlistgroup[i].effectzhuihui:stopEffect();
	end
	
	objSwf.yestypanel.imgnozhuihui._visible = false;
	if not self.awardlist or #self.awardlist == 0 then
		objSwf.yestypanel.imgnozhuihui._visible = true;
	end
	
	for i=1,self.awardlistcount do
		local PageIndex = self.curpageIndex + i;
		local vo = self.awardlist[PageIndex];
		if vo then
			self.yestyawardlistgroup[i]._visible = true;
			
			--得到剩余次数
			local num = DailyMustDoUtil:GetDailyMustNum(vo.id, self.type);
			--已追回
			if num == 0 then
				self.yestyawardlistgroup[i].tfloadername.htmlText = string.format(StrConfig["dailymustdo28"],vo.name);
				self.yestyawardlistgroup[i].tfname.htmlText = string.format(StrConfig["dailymustdo28"],StrConfig["dailymustdo30"]);
				self.yestyawardlistgroup[i].loaderbg.source = ImgUtil:GetGrayImgUrl(ResUtil:GetDailyMustDoNameURL(vo.bgicon));
				self.yestyawardlistgroup[i].tfnum._visible = false;
				self.yestyawardlistgroup[i].btnyinliang.visible = false;
				self.yestyawardlistgroup[i].btnyuanbao.visible = false;
				self.yestyawardlistgroup[i].imggetted._visible = true;
			--未追回
			else
				self.yestyawardlistgroup[i].tfloadername.htmlText = vo.name;
				self.yestyawardlistgroup[i].tfname.htmlText = StrConfig["dailymustdo30"];
				self.yestyawardlistgroup[i].loaderbg.source = ResUtil:GetDailyMustDoNameURL(vo.bgicon);
				local str = "";
--				if vo.id == 11 or vo.id == 13 then
--					str = string.format(StrConfig["dailymustdo11"],1);
--				else
					str = string.format(StrConfig["dailymustdo11"],num);
--				end
				self.yestyawardlistgroup[i].tfnum.text = str;
				self.yestyawardlistgroup[i].tfnum._visible = true;
			
				self.yestyawardlistgroup[i].btnyinliang.visible = true;
--				self.yestyawardlistgroup[i].btnyuanbao.visible = true;
				self.yestyawardlistgroup[i].btnyuanbao.visible = false;
				self.yestyawardlistgroup[i].imggetted._visible = false;
			end
			
			self:UpdateYestyRewardList(vo, i, num);
		end
	end
	
	objSwf.yestypanel.yesinfo.htmlText = StrConfig["dailymustdo26"];
	
	--一键按钮
	self:UpdateYestyBtnYIJIan();
end


--点击标签
function UIDailyMustDoView:OnTabButtonClick(name)
	if not self.tabButton[name] then
		return;
	end
	self.tabButton[name].selected = true;

	if name == DailyMustDoConsts.TODAY then
		self.type = DailyMustDoConsts.typetoday;
		self.style = 0;
		self.tabButton[DailyMustDoConsts.ALL].selected = true;
	elseif name == DailyMustDoConsts.YESTY then
		self.type = DailyMustDoConsts.typeyesterday;
		self.style = 0;
		self.tabButton[DailyMustDoConsts.ALL].selected = true;
	elseif name == DailyMustDoConsts.ALL then
		self.style = 0;
	elseif name == DailyMustDoConsts.EXP then
		self.style = 1;
	elseif name == DailyMustDoConsts.YINLIANG then
		self.style = 2;
	elseif name == DailyMustDoConsts.ZHENQI then
		self.style = 3;
	elseif name == DailyMustDoConsts.EQUIT then
		self.style = 4;
	elseif name == DailyMustDoConsts.TOOL then
		self.style = 5;
	end
	
	self:ResetData();
	self:InitUI();
	self:ShowTaskInfo();
end

--更新活动列表
function UIDailyMustDoView:UpdateTaskListInfo(body)
	self:ResetData();
	self:InitUI();
	if body.type == DailyMustDoConsts.typetoday then
		self:UpdateTodayTaskListInfo(body);
	elseif body.type == DailyMustDoConsts.typeyesterday then
		self:UpdateYestyTaskListInfo(body);
	end
end

--更新今日扫荡活动列表
function UIDailyMustDoView:UpdateTodayTaskListInfo(body)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	for i=1,self.awardlistcount do
		self.todayawardlistgroup[i]._visible = false;
	end
	
	for i=1,self.awardlistcount do
		local PageIndex = self.curpageIndex + i;
		local vo = self.awardlist[PageIndex];
		if vo then
			self.todayawardlistgroup[i]._visible = true;
			
			--得到剩余次数
			local num = DailyMustDoUtil:GetDailyMustNum(vo.id, self.type);
			--已完成
			if num == 0 then
				self.todayawardlistgroup[i].tfloadername.htmlText = string.format(StrConfig["dailymustdo28"],vo.name);
				self.todayawardlistgroup[i].tfname.htmlText = string.format(StrConfig["dailymustdo28"],StrConfig["dailymustdo29"]);
				self.todayawardlistgroup[i].loaderbg.source = ImgUtil:GetGrayImgUrl(ResUtil:GetDailyMustDoNameURL(vo.bgicon));
				self.todayawardlistgroup[i].tfnum._visible = false;
				self.todayawardlistgroup[i].btnyinliang.visible = false;
				self.todayawardlistgroup[i].btnyuanbao.visible = false;
				
				-- 是否播放特效
				if DailyMustDoUtil:GetIsHaveId(body.list,vo.id) == true then
					self.todayawardlistgroup[i].effectfinish:playEffect(1)
				else
					self.todayawardlistgroup[i].imggetted._visible = true;
				end
			--未完成
			else
				self.todayawardlistgroup[i].tfloadername.htmlText = vo.name;
				self.todayawardlistgroup[i].tfname.htmlText = StrConfig["dailymustdo29"];
				self.todayawardlistgroup[i].loaderbg.source = ResUtil:GetDailyMustDoNameURL(vo.bgicon);
				local str = string.format(StrConfig["dailymustdo1"],num);
				self.todayawardlistgroup[i].tfnum.text = str;
				self.todayawardlistgroup[i].tfnum._visible = true;
				
				self.todayawardlistgroup[i].btnyinliang.visible = true;
--				self.todayawardlistgroup[i].btnyuanbao.visible = true;
				self.todayawardlistgroup[i].btnyuanbao.visible = false;
				self.todayawardlistgroup[i].imggetted._visible = false;
			end
			
			self:UpdateTodayRewardList(vo, i, num);
		end
	end
	
	--总奖励信息
	self:UpdateAllRewardList();
	
	--一键按钮
	self:UpdateTodayBtnYIJIan();
end

--更新昨日追回单个活动
function UIDailyMustDoView:UpdateYestyTaskListInfo(body)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	for i=1,self.awardlistcount do
		self.yestyawardlistgroup[i]._visible = false;
	end
	
	for i=1,self.awardlistcount do
		local PageIndex = self.curpageIndex + i;
		local vo = self.awardlist[PageIndex];
		if vo then
			self.yestyawardlistgroup[i]._visible = true;
			
			--得到剩余次数
			local num = DailyMustDoUtil:GetDailyMustNum(vo.id, self.type);
			--已追回
			if num == 0 then
				self.yestyawardlistgroup[i].tfloadername.htmlText = string.format(StrConfig["dailymustdo28"],vo.name);
				self.yestyawardlistgroup[i].tfname.htmlText = string.format(StrConfig["dailymustdo28"],StrConfig["dailymustdo30"]);
				self.yestyawardlistgroup[i].loaderbg.source = ImgUtil:GetGrayImgUrl(ResUtil:GetDailyMustDoNameURL(vo.bgicon));
				self.yestyawardlistgroup[i].tfnum._visible = false;
				self.yestyawardlistgroup[i].btnyinliang.visible = false;
				self.yestyawardlistgroup[i].btnyuanbao.visible = false;
				
				-- 是否播放特效
				if DailyMustDoUtil:GetIsHaveId(body.list,vo.id) == true then
					self.yestyawardlistgroup[i].effectzhuihui:playEffect(1)
				else
					self.yestyawardlistgroup[i].imggetted._visible = true;
				end
			--未追回
			else
				self.yestyawardlistgroup[i].tfloadername.htmlText = vo.name;
				self.yestyawardlistgroup[i].tfname.htmlText = StrConfig["dailymustdo30"];
				self.yestyawardlistgroup[i].loaderbg.source = ResUtil:GetDailyMustDoNameURL(vo.bgicon);
				local str = "";
--				if vo.id == 11 or vo.id == 13 then
--					str = string.format(StrConfig["dailymustdo11"],1);
--				else
					str = string.format(StrConfig["dailymustdo11"],num);
--				end
				self.yestyawardlistgroup[i].tfnum.text = str;
				self.yestyawardlistgroup[i].tfnum._visible = true;
			
				self.yestyawardlistgroup[i].btnyinliang.visible = true;
--				self.yestyawardlistgroup[i].btnyuanbao.visible = true;
				self.yestyawardlistgroup[i].btnyuanbao.visible = false;
				self.yestyawardlistgroup[i].imggetted._visible = false;
			end
			
			self:UpdateYestyRewardList(vo, i, num);
		end
	end
	
	--一键按钮
	self:UpdateYestyBtnYIJIan();
end

--更新单个活动
function UIDailyMustDoView:UpdateTaskInfo(body)
	if body.type == DailyMustDoConsts.typetoday then
		self:UpdateTodayTaskInfo(body);
	elseif body.type == DailyMustDoConsts.typeyesterday then
		self:UpdateYestyTaskInfo(body);
	end
end

--更新今日扫荡单个活动
function UIDailyMustDoView:UpdateTodayTaskInfo(body)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	if self.type == body.type then
		for i=1,self.awardlistcount do
			local PageIndex = self.curpageIndex + i;
			local vo = self.awardlist[PageIndex];
			if vo then
				if vo.id == body.id then
					--得到剩余次数
					local num = DailyMustDoUtil:GetDailyMustNum(body.id, self.type);
					--已完成
					if num == 0 then
						self.todayawardlistgroup[i].tfloadername.htmlText = string.format(StrConfig["dailymustdo28"],vo.name);
						self.todayawardlistgroup[i].tfname.htmlText = string.format(StrConfig["dailymustdo28"],StrConfig["dailymustdo29"]);
						self.todayawardlistgroup[i].loaderbg.source = ImgUtil:GetGrayImgUrl(ResUtil:GetDailyMustDoNameURL(vo.bgicon));
						self.todayawardlistgroup[i].tfnum._visible = false;
						
						self.todayawardlistgroup[i].btnyinliang.visible = false;
						self.todayawardlistgroup[i].btnyuanbao.visible = false;
						self.todayawardlistgroup[i].effectfinish:playEffect(1);
					--未完成
					else
						self.todayawardlistgroup[i].tfloadername.htmlText = vo.name;
						self.todayawardlistgroup[i].tfname.htmlText = StrConfig["dailymustdo29"];
						self.todayawardlistgroup[i].loaderbg.source = ResUtil:GetDailyMustDoNameURL(vo.bgicon);
						local str = string.format(StrConfig["dailymustdo1"],num);
						self.todayawardlistgroup[i].tfnum.text = str;
						self.todayawardlistgroup[i].tfnum._visible = true;
						
						self.todayawardlistgroup[i].btnyinliang.visible = true;
--						self.todayawardlistgroup[i].btnyuanbao.visible = true;
						self.todayawardlistgroup[i].btnyuanbao.visible = false;
						self.todayawardlistgroup[i].imggetted._visible = false;
					end
			
					self:UpdateTodayRewardList(vo, i, num);
				end
			end
		end
		
		--总奖励信息
		self:UpdateAllRewardList();
		
		--一键按钮
		self:UpdateTodayBtnYIJIan();
	end
end

--更新昨日追回单个活动
function UIDailyMustDoView:UpdateYestyTaskInfo(body)
	local objSwf = self.objSwf;
	if not objSwf then return; end	
	
	if self.type == body.type then
		for i=1,self.awardlistcount do
			local PageIndex = self.curpageIndex + i;
			local vo = self.awardlist[PageIndex];
			if vo then
				if vo.id == body.id then
					
					--得到剩余次数
					local num = DailyMustDoUtil:GetDailyMustNum(body.id, self.type);
					--已完成
					if num == 0 then
						self.yestyawardlistgroup[i].tfloadername.htmlText = string.format(StrConfig["dailymustdo28"],vo.name);
						self.yestyawardlistgroup[i].tfname.htmlText = string.format(StrConfig["dailymustdo28"],StrConfig["dailymustdo30"]);
						self.yestyawardlistgroup[i].loaderbg.source = ImgUtil:GetGrayImgUrl(ResUtil:GetDailyMustDoNameURL(vo.bgicon));
						self.yestyawardlistgroup[i].tfnum._visible = false;
						
						self.yestyawardlistgroup[i].btnyinliang.visible = false;
						self.yestyawardlistgroup[i].btnyuanbao.visible = false;
						self.yestyawardlistgroup[i].effectzhuihui:playEffect(1);
					--未完成
					else
						self.yestyawardlistgroup[i].tfloadername.htmlText = vo.name;
						self.yestyawardlistgroup[i].tfname.htmlText = StrConfig["dailymustdo30"];
						self.yestyawardlistgroup[i].loaderbg.source = ResUtil:GetDailyMustDoNameURL(vo.bgicon);
						local str = string.format(StrConfig["dailymustdo1"],num);
						self.yestyawardlistgroup[i].tfnum.text = str;
						self.yestyawardlistgroup[i].tfnum._visible = true;
						
						self.yestyawardlistgroup[i].btnyinliang.visible = true;
--						self.yestyawardlistgroup[i].btnyuanbao.visible = true;
						self.yestyawardlistgroup[i].btnyuanbao.visible = false;
						self.yestyawardlistgroup[i].imggetted._visible = false;
					end
					
					self:UpdateYestyRewardList(vo, i, num);
				end
			end
		end
		
		--一键按钮
		self:UpdateYestyBtnYIJIan();
	end
end
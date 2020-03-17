--[[
	家园抢夺任务
	wangshuai

]]

_G.UIHomesQuestRod = BaseUI:new("UIHomesQuestRod")

UIHomesQuestRod.curIndex = 0;

function UIHomesQuestRod:Create()
	self:AddSWF("homesteadQuestRodpanel.swf",true,nil)
end;

function UIHomesQuestRod:OnLoaded(objSwf)
	objSwf.scrollbar.scroll = function () self:OnScrollBar()end;
	
	for i=1,6 do 
		RewardManager:RegisterListTips(objSwf["item"..i].rewardlist);
		objSwf["item"..i].rod_btn.click = function() self:OnRodClick(objSwf["item"..i].rod_btn)end;
	end;
	objSwf.claertime_btn.click = function() self:ClaerTimeClick()end;
	objSwf.claertime_btn.rollOver = function()self:ClaerTimeOver()end;
	objSwf.claertime_btn.rollOut  = function()TipsManager:Hide()end;

	objSwf.updataRod_btn.click = function() self:UpdataRodList()end;

	objSwf.rodnumTips.rollOver = function() self:RodNumOver() end;
	objSwf.rodnumTips.rollOut  = function() TipsManager:Hide(); end;


	objSwf.rodinfolistscr:setScrollProperties(5,0,10);
	objSwf.rodinfolistscr.trackScrollPageSize = 5;
	objSwf.rodinfolistscr.position = 0;

	objSwf.roaAnimation.shi.playOver = function() self:OnPlayOver()end;
	objSwf.roaAnimation.cheng.playOver = function() self:OnPlayOver()end;
	self:ShowAnimation(0,false)
end;

function UIHomesQuestRod:OnPlayOver()
	self:ShowAnimation(0,false)
end;

function UIHomesQuestRod:ShowAnimation(type,bo)
	local objSwf = self.objSwf;
	objSwf.roaAnimation._visible = bo;
	if bo then 
		objSwf.roaAnimation.shi:gotoAndPlay(2)
		objSwf.roaAnimation.cheng:gotoAndPlay(2)
	else 
		objSwf.roaAnimation.shi:gotoAndStop(1)
		objSwf.roaAnimation.cheng:gotoAndStop(1)
	end;
	if type == 1 then  --成功
		objSwf.roaAnimation.shi._visible = false;
		objSwf.roaAnimation.cheng._visible = true;
	elseif type == 2 then -- 失败
		objSwf.roaAnimation.shi._visible = true;
		objSwf.roaAnimation.cheng._visible = false;
	end;
end;

function UIHomesQuestRod:OnShow()
	local objSwf = self.objSwf;
	HomesteadController:RodQuestInfo()
	self.list = HomesteadModel:GetRodQuestInfo()
	objSwf.scrollbar:setScrollProperties(6,0,#self.list-6);
	objSwf.scrollbar.trackScrollPageSize = 6;
	objSwf.scrollbar.position = 0;
	self:ShowRodItemList();
	self:rodinfolist();
	self:ShowCurNum()
end;

function UIHomesQuestRod:OnHide()
	
end;

function UIHomesQuestRod:RodNumOver()
	TipsManager:ShowBtnTips(string.format(StrConfig["homestead051"]),TipsConsts.Dir_RightDown);
end;

function UIHomesQuestRod:UpdataRodList()
	HomesteadController:RodQuestInfo()
end;

function UIHomesQuestRod:ClaerTimeClick()
	local vo = HomesteadModel:GetRodQuestNum();
	local cdNum = vo.rodCD or 0;
	local cfg = t_consts[95].fval
	local mymoney = MainPlayerModel.humanDetailInfo.eaUnBindMoney
	if cdNum <= 0 then 
		return 
	end;
	local num = math.ceil(cdNum / 60) * cfg;
	local func = function() 
		if num > mymoney then 
			FloatManager:AddNormal(StrConfig['homestead043'])
			return
		end;
		HomesteadController:AddRodQuestNum(1) 
	end;
	UIConfirm:Open(string.format(StrConfig["homestead013"],num),func);
end;

function UIHomesQuestRod:ClaerTimeOver()
	local val = t_consts[95].fval
	local cd = t_consts[95].val1
	TipsManager:ShowBtnTips(string.format(StrConfig["homestead014"],cd,val));
end;

function UIHomesQuestRod:OnRodClick(target)
	local vo = HomesteadModel:GetRodQuestNum();
	local lvl = HomesteadModel:GetBuildInfoLvl(HomesteadConsts.ZongmengBuild)
	local buildcfg = t_homebuild[lvl].renwulueduoMaxNum;
	if vo.rodNum >= buildcfg then 
		FloatManager:AddNormal(StrConfig['homestead040'])
		return 
	end;
	local timeCD = t_consts[95].val2 * 60;
	if vo.rodCD >= timeCD then 
		FloatManager:AddNormal(StrConfig['homestead041'])
		return 
	end;
	HomesteadController:GoRodQuest(target.uid)
end

function UIHomesQuestRod:ShowCurNum()
	local objSwf = self.objSwf;
	local vo = HomesteadModel:GetRodQuestNum();
	if not vo.rodNum then 
		print("ERROR: server not back data ")
		return 
	end;
	local lvl = HomesteadModel:GetBuildInfoLvl(HomesteadConsts.MainBuild)
	local buildcfg = t_homebuild[lvl].renwulueduoMaxNum;
	objSwf.num_txt.htmlText = vo.rodNum.."/"..buildcfg;
	local t,s,f = CTimeFormat:sec2format(vo.rodCD)
	local timeCD = t_consts[95].val2 * 60;
	if vo.rodCD >= timeCD then 
		objSwf.cd_txt.htmlText = string.format("<font color='#cc0000'>%02d:%02d:%02d</font>",t,s,f);
	else
		objSwf.cd_txt.htmlText = string.format("%02d:%02d:%02d",t,s,f);
	end;
end;

function UIHomesQuestRod:OnScrollBar()
	local objSwf = self.objSwf;
	local index = objSwf.scrollbar.position;
	self.curIndex = index;
	self:ShowRodItemList()

end;

function UIHomesQuestRod:ShowRodItemList()
	local objSwf = self.objSwf;
	local uidata = HomesteadModel:GetRodQuestInfo()
	local index = self.curIndex; 
	for i=1,6 do 
		local item = objSwf['item'..i];
		local data = uidata[i+index];
		if data then 
			item.Name_txt.htmlText = data.roleName;
			item.rolefight_txt.htmlText = data.fight;
			if data.rodNum >= 3 then 
				item.rod_btn.disabled = true;
			else
				item.rod_btn.disabled = false;
			end;
			item.rod_btn.uid = data.guid; 
			local rewardList = {};
			local reward1 = RewardSlotVO:new()
			reward1.id = data.rewardType;
			reward1.count = data.rewardNum;
			table.push(rewardList,reward1:GetUIData())
			item.rewardlist.dataProvider:cleanUp();
			item.rewardlist.dataProvider:push(unpack(rewardList));
			item.rewardlist:invalidateData();
			item._visible = true;
		else
			item._visible = false;
		end;
	end;
end;

function UIHomesQuestRod:rodinfolist()
	local objSwf = self.objSwf;
	local uidata = HomesteadUtil:formRodQuestInfo()
	objSwf.rodinfolist.dataProvider:cleanUp();
	objSwf.rodinfolist.dataProvider:push(unpack(uidata));
	objSwf.rodinfolist:invalidateData();
end;


	-- notifaction
function UIHomesQuestRod:ListNotificationInterests()
	return {
		NotifyConsts.HomesteadUpdatTime,
		NotifyConsts.HomesteadUpdatRodList,
		}
end;
function UIHomesQuestRod:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.HomesteadUpdatTime then
		self:ShowCurNum();
		--self:rodinfolist();
	elseif name == NotifyConsts.HomesteadUpdatRodList then 
		self:ShowRodItemList();
		self:rodinfolist();
		self:ShowCurNum();
	end;
end;
--[[
挖宝
wangshuai
]]

_G.UIWaBao = BaseUI:new("UIWaBao")

UIWaBao.curQuality = 0;
UIWaBao.getLevel = 0;

function UIWaBao:Create()
	self:AddSWF("wabaoPanel.swf",true,"center")
end;

function UIWaBao:OnLoaded(objSwf)
	objSwf.closepanel.click = function() self:Hide();end;
	RewardManager:RegisterListTips(objSwf.rewardZList);
	RewardManager:RegisterListTips(objSwf.rewardJList);


	for i=1,4 do 
		objSwf["lastNum"..i].rollOver = function()self:OnlastNumOver(i)end;
		objSwf["lastNum"..i].rollOut  = function() TipsManager:Hide()end;
		objSwf["wabao"..i].click = function() self:OnWabaoClick(i)end;
	end;

	objSwf.hecheng_lan_btn.click = function() self:GoHeChengPanl(1) end;
	objSwf.hecheng_zi_btn.click = function() self:GoHeChengPanl(2) end;
end;

function UIWaBao:GoHeChengPanl(type)
	local cfg = t_cangbaotu[type];
	if not cfg then return end;
	FuncManager:OpenFunc(FuncConsts.HeCheng,false,BagModel.compoundMap[cfg.id]);
end;

function UIWaBao:OnShow()
	self:OnInItInfo()
end

function UIWaBao:IsTween()
	return true;
end;

function UIWaBao:IsShowLoading()
	return true;
end;

function UIWaBao:GetPanelType()
	return 1;
end;

function UIWaBao:ESCHide()
	return true;
end;

function UIWaBao:IsShowSound()
	return true;
end;


function UIWaBao:OnHide()

end

function UIWaBao:OnShowWabaoBtnState()
	local objSwf = self.objSwf;
	for i,info in ipairs(t_cangbaotu) do
		if i <5 then 
			local myhave = BagModel:GetItemNumInBag(toint(info.id));
			if myhave <= 0 then 
				objSwf["wabao"..i].disabled = true;
			else
				objSwf["wabao"..i].disabled = false;
			end;	
		end;
	end;
end;

function UIWaBao:OnlastNumOver(i)
	local cfg = t_cangbaotu[i];
	if not cfg then 
		print('ERROR： cur quality，at cfg Can,t find')
		return end;
	local tipsvo = ItemTipsUtil:GetItemTipsVO(cfg.id)
	if not tipsvo then return; end
	TipsManager:ShowTips(tipsvo.tipsType,tipsvo,tipsvo.tipsShowType, TipsConsts.Dir_RightDown);
end;

function UIWaBao:OnWabaoClick(i)
	local lastNum = WaBaoModel:GetWabaoNum() 
	if lastNum <= 0 then 
		FloatManager:AddNormal(StrConfig["wabao005"]);
		return 
	end;
	self.curQuality = i
	WaBaoController:SureWabao(self.curQuality)
end;

function UIWaBao:OnInItInfo()
	local objSwf = self.objSwf;
	local data = WaBaoModel:GetWaBoaInfo()
	objSwf.lastnum.num = WaBaoModel:GetWabaoNum().."c";
	self:OnPickUpNo()
	self:ShowRewardZList();
	--self:ShowXunbaotuList();
	self:OnSetXunBaoTuNum();
	self:OnShowWabaoBtnState();
end;

-- 未接去任务。。。
function UIWaBao:OnPickUpNo()
	local objSwf = self.objSwf;
	self.getLevel = MainPlayerModel.humanDetailInfo.eaLevel;
	self.curQuality = 1;
end;

-- 取消任务
function UIWaBao:OnCancelWabap()
	WaBaoController:CancelWaboa()
	-- 要删除
	--WaBaoModel:ClaerData()
end;

function UIWaBao:OnSetXunBaoTuNum()
	local objSwf = self.objSwf;
	for i,info in ipairs(t_cangbaotu) do
	if i == 5  then break end;
	local myhave = BagModel:GetItemNumInBag(toint(info.id));
		local txt = string.format(StrConfig["wabaocang00"..i],myhave) 
		if myhave >= 1 then 
			txt = string.format(StrConfig['wabao001'],'#29cc00',txt);
		else
			txt = string.format(StrConfig["wabao001"],'#cc0000',txt);
		end;
		objSwf['lastNum'..i].htmlLabel = txt;
	end;
end;

UIWaBao.zhenList = {};
UIWaBao.jiaList = {};
-- 奖励
function UIWaBao:ShowRewardZList()
	local objSwf = self.objSwf;
	self.zhenList = {};
	self.jiaList = {};
	for i,info in ipairs(t_cangbaotu) do 
		if i == 5 then break end;
		local quailty = i;
		local waboaid = quailty * 10000 + self.getLevel;
		local wabaoLevelCfg = t_wabaolevel[waboaid];
		if not wabaoLevelCfg then
			print("ERROR:  of t_wabaolevel role level is error data  -----level:"..self.getLevel)
		 return end;
		local wabaoID = (wabaoLevelCfg.groupid * 100) + quailty
		local wabaoCfg = t_wabao[wabaoID];
		if not wabaoCfg then 
			print("ERROR: of t_wabao wabaoID is error data -----wabaoID:"..wabaoID);
			return 
		end;
		self:Panel1SetData(wabaoLevelCfg,wabaoCfg)
	end;
	self:DrawUIList();
end;



------------------------未接去任务展示
--未接去任务奖励展示
function UIWaBao:Panel1SetData(wabaoLevelCfg,wabaoCfg)
	local objSwf = self.objSwf;
	-- 奖励真
	local rewardZUidata = {};
	local rewardExp = RewardSlotVO:new();
	rewardExp.id = 7;
	rewardExp.count = wabaoLevelCfg.rewardExp;
	table.push(self.zhenList,rewardExp:GetUIData());

	local otherlist = AttrParseUtil:ParseAttrToMap(wabaoLevelCfg.reward);
	for i,info in pairs(otherlist) do 
		local rewardvo = RewardSlotVO:new();
		rewardvo.id = toint(i);
		rewardvo.count = info;
		table.push(self.zhenList,rewardvo:GetUIData());
	end;
	

	--奖励假
	local rewardJUIdata = {};
	local rewardData = AttrParseUtil:ParseAttrToMap(wabaoCfg.reward);
	for i,info in pairs(rewardData) do 
		local rewardvoc = RewardSlotVO:new();
		rewardvoc.id = toint(i);
		rewardvoc.count = info;
		table.push(self.jiaList,rewardvoc:GetUIData());
	end;
	
end;

function UIWaBao:DrawUIList()
	local objSwf = self.objSwf;
	objSwf.rewardZList.dataProvider:cleanUp();
	objSwf.rewardZList.dataProvider:push(unpack(self.zhenList));
	objSwf.rewardZList:invalidateData();
	objSwf.rewardJList.dataProvider:cleanUp();
	objSwf.rewardJList.dataProvider:push(unpack(self.jiaList));
	objSwf.rewardJList:invalidateData();
end;

-- notifaction
function UIWaBao:ListNotificationInterests()
	return {
			NotifyConsts.WabaoinfoUpdata;
			NotifyConsts.BagAdd,
			NotifyConsts.BagRemove,
			NotifyConsts.BagUpdate,
			NotifyConsts.PlayerAttrChange,
		}
end;
function UIWaBao:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.WabaoinfoUpdata then  
		WaBaoController:ShowUI()
		self:Hide();
	elseif name == NotifyConsts.BagAdd or NotifyConsts.BagRemove == name or name == NotifyConsts.BagUpdate or name == NotifyConsts.PlayerAttrChange then 
		self:OnInItInfo()
	end;
end;

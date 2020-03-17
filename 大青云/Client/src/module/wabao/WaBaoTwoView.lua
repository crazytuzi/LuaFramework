--[[
挖宝2
 wangshuaoi
]]

_G.UIWaBaoTwo= BaseUI:new("UIWaBaoTwo")

UIWaBaoTwo.getLevel = 0;
UIWaBaoTwo.curQuality = 0;
UIWaBaoTwo.curIndex = nil;

function UIWaBaoTwo:Create()
	self:AddSWF("wabaoPanelTow.swf",true,"center")
end;

function UIWaBaoTwo:OnLoaded(objSwf)
	objSwf.closepanel.click = function() self:Hide()end;
	objSwf.btn1.click = function() self:OnBtnClick(1)end;
	objSwf.btn2.click = function() self:OnBtnClick(2)end;
	objSwf.btnGo.click = function() self:OnChuanSongGO()end;
	objSwf.btnGo.rollOver = function() self:btnGoOver()end;
	objSwf.btnGo.rollOut = function() TipsManager:Hide(); end;
	objSwf.cancelbtn.click =function() self:OnCancelBtn()end;

	RewardManager:RegisterListTips(objSwf.rewardZListok);
	RewardManager:RegisterListTips(objSwf.rewardJListok);

end;

function UIWaBaoTwo:OnChuanSongGO()
	local val = t_consts[90].val2;
	local myLevel = MainPlayerModel.humanDetailInfo.eaLevel;
	if val > myLevel then 
			FloatManager:AddNormal( StrConfig["wabao011"] );
		return 
	end;
	local data = WaBaoModel:GetWaBoaInfo();
	if data then 
		local id = data["pos"..1];
		if id then 
			local cfg = t_wabaomap[id];
			if cfg then 
				if myLevel >= t_consts[90].val3 then
					local point = split(cfg.pos,',')
					MapController:Teleport( MapConsts.Teleport_QuestWabao, nil, cfg.mapid ,toint(point[1]),toint(point[2]));
					-- self:Hide();
					self.goFightAfterSceneChange = cfg.mapid ~= CPlayerMap:GetCurMapID()
					return
				end
				MapController:Teleport( MapConsts.Teleport_Wabao, nil, cfg.mapid );
			end;
		end;
	end;
end;

function UIWaBaoTwo:OnBtnTeleportClick()
	if self:IsShow() then
		self:Hide();
	end
	if self.goFightAfterSceneChange then
		MapController:AddSceneChangeCB( function()
			WaBaoController:SurePoint(true);
		end )
	else
		WaBaoController:SurePoint(true);
	end
end

function UIWaBaoTwo:btnGoOver()
	TipsManager:ShowBtnTips(StrConfig["wabao010"],TipsConsts.Dir_RightDown);
end;

function UIWaBaoTwo:OnShow()
	self:OnInItInfo()

end;

function UIWaBaoTwo:IsTween()
	return true;
end;

function UIWaBaoTwo:IsShowLoading()
	return true;
end;

function UIWaBaoTwo:GetPanelType()
	return 0;
end;

function UIWaBaoTwo:ESCHide()
	return true;
end;

function UIWaBaoTwo:IsShowSound()
	return true;
end;


function UIWaBaoTwo:OnHide()

end;

function UIWaBaoTwo:OnCancelBtn()
	WaBaoController:CancelWaboa()
end;

function UIWaBaoTwo:OnBtnClick(index)
	--print(index)
	self.curIndex = index;
	--print(self.curIndex)
	self:OnSureClick();
end;

function UIWaBaoTwo:OnSetPointState()
	local objSwf = self.objSwf;
	local data = WaBaoModel:GetWaBoaInfo()
	
	for i=1,2 do 
		local cfg = t_wabaomap[data["pos"..i]]
		if not cfg then 
			print("ERROR:  pos is error  ",data["pos"..i])
			return 
		end;
		local mapCfg = t_map[cfg.mapid];
		if not mapCfg then 
			print("ERROR:  pos is error  ",cfg.mapid)
			return 
		end;
		objSwf['btn'..i].label = mapCfg.name;
	end;
	--print("没有执行吗？-----------")
	if data.lookPoint and data.lookPoint ~= 0 then 
		if data.pos1 == data.lookPoint then 
			objSwf.btn1.disabled = true;
		elseif data.pos2 == data.lookPoint then 
			objSwf.btn2.disabled = true;
		end;
	else
		objSwf.btn1.disabled = false;
		objSwf.btn2.disabled = false;
	end;
end;

function UIWaBaoTwo:OnInItInfo()
	UIWaBaoTwo.getLevel = 0;
	UIWaBaoTwo.curQuality = 0;
	UIWaBaoTwo.curIndex = nil;



	local objSwf = self.objSwf;
	local data = WaBaoModel:GetWaBoaInfo()
	self.getLevel = data.getlvl;
	local lvlcfg = t_wabaolevel[data.wabaoid]
	self.curQuality = lvlcfg.quailty;
	objSwf.name:gotoAndStop(self.curQuality)

	objSwf.btn1.selected = false;
	objSwf.btn2.selected = false;

	self:ShowRewardZList();
	self:OnSetPointState();
end;

function UIWaBaoTwo:OnSureClick()
	local type = self.curIndex
	if not type then 
		FloatManager:AddNormal( StrConfig["wabao004"] );
		return;
	end;
	local objSwf = self.objSwf;
	local data = WaBaoModel:GetWaBoaInfo();
	local id = data["pos"..type];
	local cfg = t_wabaomap[id];
	local point = split(cfg.pos,",")
	local completeFuc = function()
		WaBaoController:SurePoint()
	end
	if not MainPlayerController:DoAutoRun(cfg.mapid,_Vector3.new(point[1],point[2],0),completeFuc) then
		FloatManager:AddSysNotice(2005014);--已达上限
	else
		MainPlayerController:DoAutoRun(cfg.mapid,_Vector3.new(point[1],point[2],0),completeFuc);
	end
	self:Hide();
end;

function UIWaBaoTwo:ShowRewardZList()
	local objSwf = self.objSwf;
	local waboaid = self.curQuality * 10000 + self.getLevel;
	local wabaoLevelCfg = t_wabaolevel[waboaid];
	if not wabaoLevelCfg then
		print("ERROR:  of t_wabaolevel role level is error data  -----level:"..level)
	 return end;
	local wabaoID = (wabaoLevelCfg.groupid * 100) + self.curQuality
	local wabaoCfg = t_wabao[wabaoID];
	if not wabaoCfg then 
		print("ERROR: of t_wabao wabaoID is error data -----wabaoID:"..wabaoID);
		return 
	end;
	self:Panel2SetData(wabaoLevelCfg,wabaoCfg);
end;

-- 接取人物展示
function UIWaBaoTwo:Panel2SetData(wabaoLevelCfg,wabaoCfg)
	local objSwf = self.objSwf;
	-- 界面2奖励真
	local rewardZUidataok = {};
	local rewardExp = RewardSlotVO:new();
	rewardExp.id = 7;
	rewardExp.count = wabaoLevelCfg.rewardExp;
	table.push(rewardZUidataok,rewardExp:GetUIData());

	local otherlist = AttrParseUtil:ParseAttrToMap(wabaoLevelCfg.reward);
	for i,info in pairs(otherlist) do 
		local rewardvo = RewardSlotVO:new();
		rewardvo.id = toint(i);
		rewardvo.count = info;
		table.push(rewardZUidataok,rewardvo:GetUIData());
	end;
	objSwf.rewardZListok.dataProvider:cleanUp();
	objSwf.rewardZListok.dataProvider:push(unpack(rewardZUidataok));
	objSwf.rewardZListok:invalidateData();

	--界面2奖励假
	local rewardJUIdataok = {};
	local rewardData = AttrParseUtil:ParseAttrToMap(wabaoCfg.reward);
	for i,info in pairs(rewardData) do 
		local rewardvoc = RewardSlotVO:new();
		rewardvoc.id = toint(i);
		rewardvoc.count = info;
		table.push(rewardJUIdataok,rewardvoc:GetUIData());
	end;
	objSwf.rewardJListok.dataProvider:cleanUp();
	objSwf.rewardJListok.dataProvider:push(unpack(rewardJUIdataok));
	objSwf.rewardJListok:invalidateData();
end;

-- notifaction
function UIWaBaoTwo:ListNotificationInterests()
	return {
			NotifyConsts.WabaoinfoPointUpdata,
			NotifyConsts.WabaoinfoCancel,
		}
end;

function UIWaBaoTwo:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.WabaoinfoPointUpdata then  
		self:OnInItInfo()
	elseif name == NotifyConsts.WabaoinfoCancel then 
		self:Hide();
		WaBaoController:ShowUI()
	end;
end;





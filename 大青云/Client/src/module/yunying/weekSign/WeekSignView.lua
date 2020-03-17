--[[
	2015年8月22日, PM 01:05:33
	wangyanwei
	七日登录奖励界面
]]

_G.UIWeekSign = BaseUI:new('UIWeekSign');
function UIWeekSign:Create()
	self:AddSWF('weekSignTabPanel.swf',true,'center');
end

function UIWeekSign:OnLoaded(objSwf)
	objSwf.btn_close.click = function () self:Hide(); end
	objSwf.rewardList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id);  end
	objSwf.rewardList.itemRollOut = function () TipsManager:Hide(); end
	for i = 1 , 7 do
		objSwf['tab_'..i].IconReward._visible=false;
		objSwf['tab_' .. i].click = function () objSwf.effect_getReward:stopEffect(); self.weekIndex = i; self:OnChangRewardList(); self:DrawReward(); end
	end
	objSwf.btn_getReward.click = function ()
		local isDoubleWeek = WeekSignModel:GetWeekInReward();
		local index = self.weekIndex;
		-- if isDoubleWeek then
		-- 	index = index + 7;
		-- end
		WeekSignController:OnSendRewardData(index) 
	end
	objSwf.effect_getReward.complete = function () objSwf.effect_getReward:stopEffect(); objSwf.icon_getReward._visible = true; end
end

UIWeekSign.weekIndex = 1;
UIWeekSign.inDoubleWeek = false;
function UIWeekSign:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return end
	self.weekIndex = WeekSignModel:OnGetRewardIndex() % 7;
	if WeekSignModel:OnGetRewardIndex() % 7 == 0 then
		self.weekIndex = 7;
	end
	objSwf.effect_getReward:stopEffect();
	objSwf['tab_' .. self.weekIndex].selected = true;
	self:OnDrawTitle();
	self:OnChangRewardList();
	self:DrawReward();
	self:OnShowTabEffect();
	self.inDoubleWeek = WeekSignModel:GetWeekInReward();
end

function UIWeekSign:OnShowTabEffect()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	local isDoubleWeek = WeekSignModel:GetWeekInReward();
	local weekSignData=WeekSignModel:OnGetWeekSingData()
	for i = 1 , 7 do 
		--if isDoubleWeek then

		-- 	local isReward = WeekSignModel:GetIndexIsReward(i + 7);
		-- 	objSwf['tabEffect_' .. i]._visible = isReward;
		-- 	local weekSign=weekSignData[i + 7];
		-- 	if weekSign and weekSign.id then 
		-- 	    objSwf['tab_'..i].IconReward._visible=weekSign.state~=1
		-- 	end
		-- else
			local isReward = WeekSignModel:GetIndexIsReward(i);
			objSwf['tabEffect_' .. i]._visible = isReward;
			local weekSign=weekSignData[i];
			if weekSign and weekSign.id then 
                objSwf['tab_'..i].IconReward._visible= weekSign.state~=1
			end
		--end

	end
    
        local weekIndex =WeekSignModel:GetProReward()
        if weekIndex%7 ==0 then 
        	weekIndex=7
        end
        objSwf.siGrowValue:setProgress(weekIndex,7)
	objSwf.fightLoader.num=self.weekIndex;--isDoubleWeek and  self.weekIndex + 7 or self.weekIndex;
end

function UIWeekSign:OnDrawTitle()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	local isDoubleWeek = WeekSignModel:GetWeekInReward();
	
	for i = 1 , 7 do
		local cfg ;
		--if isDoubleWeek then
			--cfg = t_sevenday[i + 7];
		--else
			cfg = t_sevenday[i];
		--end
		
		if cfg then
			objSwf['tab_' .. i].load_bg.source = ResUtil:GetIcon(cfg.modelpic);
			objSwf['tab_' .. i].load_bg.loaded = function()
				-- objSwf['tab_' .. i].load_bg._x = 0 - objSwf['tab_' .. i].load_bg._width / 2;
				-- objSwf['tab_' .. i].load_bg._y = 0 - objSwf['tab_' .. i].load_bg._height / 2 - 2;
			end;
			objSwf['tab_' .. i].load_name.source = ResUtil:GetIcon(cfg.dayiconname);
			objSwf['tab_' .. i].load_name.loaded = function()
				-- objSwf['tab_' .. i].load_name._x = 0 - objSwf['tab_' .. i].load_name._width / 2;
			end;
			 objSwf['tab_' .. i].load_gname.source = ResUtil:GetIcon(cfg.dayreward_name);
			-- objSwf['tab_' .. i].load_gname.loaded = function()
			-- end;
		end
	end
end

function UIWeekSign:OnChangRewardList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.icon_getReward._visible = false;
	objSwf.btn_getReward._visible = true;

	objSwf.rewardList.dataProvider:cleanUp();
	
	local isDoubleWeek = WeekSignModel:GetWeekInReward();   --是否是第二周
	
	local weekSignData = WeekSignModel:OnGetWeekSingData();
	local weekIndex = self.weekIndex;

	local cfg =t_sevenday[weekIndex]; --isDoubleWeek and t_sevenday[weekIndex + 7] or t_sevenday[weekIndex];
	if not cfg then return end
	local weekIndexData --= weekSignData[weekIndex];
	--if isDoubleWeek then
		--weekIndexData = weekSignData[weekIndex + 7];
	--else
		weekIndexData = weekSignData[weekIndex];
	--end
	local rewardList = {};
	--objSwf.btn_getReward.disabled = true;
	objSwf.btn_getReward._visible = false;
	local prof = MainPlayerModel.humanDetailInfo.eaProf
	local cfgKey = string.format( "prof%s_show", prof )
	local rewardStr = cfg[cfgKey]
	if "" == rewardStr then
		rewardStr = cfg.reward
	end
	if weekIndexData then
		if weekIndexData.id then
			if weekIndexData.state == 1 then  --未领取
				rewardList = RewardManager:Parse( rewardStr );
				--objSwf.btn_getReward.disabled = false;
				objSwf.btn_getReward._visible=true
				objSwf.rewarday.htmlText="";
           
			else
				objSwf.icon_getReward._visible = true;
				objSwf.btn_getReward._visible=false;
				objSwf.rewarday.htmlText="";
				rewardList = RewardManager:ParseBlack( rewardStr );
			end
        elseif weekIndexData.state == 0 then 
			local day=weekIndex-weekIndexData.login;    
		    objSwf.rewarday.htmlText=day==1 and StrConfig['weekSign001'] or string.format(StrConfig['weekSign002'],weekIndex); 
		    rewardList = RewardManager:Parse(rewardStr);   
		else
			

		end
	else
		rewardList = RewardManager:Parse(rewardStr);
	end
	objSwf.rewardList.dataProvider:push(unpack(rewardList));
	objSwf.rewardList:invalidateData();

end

--画奖励模型
function UIWeekSign:DrawReward()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.load_reward.hitTestDisable = true;
	
	local isDoubleWeek = WeekSignModel:GetWeekInReward();   --是否是第二周
	
	local weekIndex = self.weekIndex;
	
	local cfg = t_sevenday[weekIndex]; --isDoubleWeek and t_sevenday[weekIndex + 7] or t_sevenday[weekIndex];
	if not cfg then return end
	local rnameCfg = split(cfg.modelname,'#');
	local prof = MainPlayerModel.humanDetailInfo.eaProf
	if #rnameCfg > 1 then
		objSwf.load_rname.source = ResUtil:GetIcon(rnameCfg[prof]);
        objSwf.load_info.source=ResUtil:GetIcon(rnameCfg[prof]);
	else
		objSwf.load_rname.source = ResUtil:GetIcon(cfg.modelname);
	objSwf.load_info.source =ResUtil:GetIcon(cfg.reward_tips_name);
	end
	if not self.viewPort then self.viewPort = _Vector2.new(1800, 1200); end
	if not self.objUIDraw then
		self.objUIDraw = UISceneDraw:new('UIWeekSignDraw', objSwf.load_reward, self.viewPort, true);
	end
	self.objUIDraw:SetUILoader( objSwf.load_reward )
	objSwf.fightLoader.num=weekIndex;--isDoubleWeek and  weekIndex + 7 or weekIndex;
	local src = cfg.model_sen;
	self.objUIDraw:SetScene(src);
	self.objUIDraw:SetDraw(true);
end

UIWeekSign.defaultCfg = {
	EyePos   = _Vector3.new(0,-60,25),
	LookPos  = _Vector3.new(-10,0,10),
	VPort    = _Vector2.new( 1800, 1200 ),
	Rotation = 0
};

function UIWeekSign:GetWidth()
	return 1397;
end

function UIWeekSign:GetHeight()
	return 823;
end

function UIWeekSign:GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.Rotation = 0;
	return cfg;
end

function UIWeekSign:OnFlyIcon(index)
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	local selectedNum = index % 7;
	if selectedNum == 0 then selectedNum = 7; end
	if self.weekIndex ~= selectedNum then return end
	local cfg = t_sevenday[index];
	if not cfg then return end
	local prof = MainPlayerModel.humanDetailInfo.eaProf
	local cfgKey = string.format( "prof%s_show", prof )
	local rewardStr = cfg[cfgKey]
	if "" == rewardStr then
		rewardStr = cfg.reward
	end
	local rewardCfg = split(rewardStr,'#');
	for i , v in ipairs(rewardCfg) do
		local idCfg = split(v,',');
		local rewardList = RewardManager:ParseToVO(toint(idCfg[1]));
		local startPos = UIManager:PosLtoG(objSwf['item' .. i]);
		RewardManager:FlyIcon(rewardList,startPos,5,true,60);
	end
   
	
end

function UIWeekSign:OnPlayerGetEffect(index)
	local objSwf = self.objSwf ;
	if not objSwf then return end
	if self.weekIndex ~= index then return end
	objSwf.icon_getReward._visible = false;
	objSwf.effect_getReward:playEffect(1);
end

function UIWeekSign:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.effect_getReward:stopEffect();
	self.weekIndex = 1;
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	self.inDoubleWeek = false;
end

function UIWeekSign:IsTween()
	return true;
end

function UIWeekSign:GetPanelType()
	return 1;
end

function UIWeekSign:IsShowSound()
	return true;
end

function UIWeekSign:IsShowLoading()
	return true;
end

function UIWeekSign:HandleNotification(name,body)
	if name == NotifyConsts.WeekSignUpData then
		if body.result ~= 0 then
			return
		end
		self:OnChangRewardList();
		if body.id < 1 then
			return
		end
		--飞图标
		if not self.inDoubleWeek then
			if body.id > 7 then
				return
			end
		end
		self:OnFlyIcon(body.id);
		self:OnPlayerGetEffect(body.id)
		self:OnShowTabEffect();
	end
end

function UIWeekSign:ListNotificationInterests()
	return {
		NotifyConsts.WeekSignUpData,
	}
end
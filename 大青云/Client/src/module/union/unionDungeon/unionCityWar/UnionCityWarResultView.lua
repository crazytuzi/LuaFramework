--[[
帮派王城战，结果
wangshuai
]]

_G.UIUnionCityWarResult = BaseUI:new("UIUnionCityWarResult")

UIUnionCityWarResult.timerKey = nil;
UIUnionCityWarResult.allTimer = 30;
function UIUnionCityWarResult:Create()
	self:AddSWF("UnionCityWarRewardPanel.swf",true,"center")
end;

function UIUnionCityWarResult:OnLoaded(objSwf)
	objSwf.closePanel.click = function() self:ClosePanel() end;
	RewardManager:RegisterListTips(objSwf.myItemList);

end;

function UIUnionCityWarResult:OnShow()
	self.allTimer = 30;
	local objSwf = self.objSwf;
	self:RegTimer()
	self:SetDesc()
	self:ShowRewuard();
	-- 设置出现时间
	objSwf.timer.text = self.allTimer;
end;

function UIUnionCityWarResult:ShowRewuard()
	local objSwf = self.objSwf;
	local serverLvl = MainPlayerController:GetServerLvl();
	local roleLvl = MainPlayerModel.humanDetailInfo.eaLevel;
	local cfg = t_guildwangcheng[roleLvl];
	local result = tonumber(UnionCityWarModel:GetResult());

	local str = "";
	if result % 2 == 0 then 
		--胜利
		str = "win_"
		SoundManager:PlaySfx(2019);
	else 
		str = "lose_"
		SoundManager:PlaySfx(2020);
	end;


	local rewardList = RewardManager:Parse(enAttrType.eaExp..","..cfg[str.."exp"],"102,"..cfg[str.."liveness"],"80,"..cfg[str.."con"], enAttrType.eaBindGold..","..cfg[str.."gold"],"81,"..cfg[str.."loyalty"]);
	objSwf.myItemList.dataProvider:cleanUp();
	objSwf.myItemList.dataProvider:push(unpack(rewardList));
	objSwf.myItemList:invalidateData();
end;

function UIUnionCityWarResult:OnHide()
	UnionCityWarController:GetRewardItem()
	UnionCityWarController:Outwar()
	TimerManager:UnRegisterTimer(self.timerKey);
	self.timerKey = nil;
end;

function UIUnionCityWarResult:SetDesc()
	local objSwf = self.objSwf;
	local result = tonumber(UnionCityWarModel:GetResult());
	-- 10 进攻方胜利 20 防守方胜利 11 进攻方失败 21 防守方失败
	if result == 10 then 
		objSwf.desc.htmlText = StrConfig["unioncitywar814"]
		self:SetResultImg("win_gong")
	elseif result == 11 then 
		objSwf.desc.htmlText = StrConfig["unioncitywar817"]
		self:SetResultImg("defeat_gong")
	elseif result == 20 then 
		objSwf.desc.htmlText = StrConfig["unioncitywar815"]
		self:SetResultImg("win_shou")
	elseif result == 21 then 
		objSwf.desc.htmlText = StrConfig["unioncitywar818"]
		self:SetResultImg("defeat_shou")
	end;
end;

function UIUnionCityWarResult:SetResultImg(str)
	local objSwf = self.objSwf;
	local strlist = {"defeat_gong","win_gong","win_shou","defeat_shou"};
	for i,info in ipairs(strlist) do 
		if info == str then 
			objSwf[info]._visible = true;
		else
			objSwf[info]._visible = false; 
		end;
	end;
end;

function UIUnionCityWarResult:RegTimer()
	-- 注册TimerEvent
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	self.timerKey = TimerManager:RegisterTimer(self.Ontimer,1000,30);
end;

function UIUnionCityWarResult:Ontimer()
	if not UIUnionCityWarResult.bShowState then return; end
	local objSwf = UIUnionCityWarResult.objSwf;
	UIUnionCityWarResult.allTimer = UIUnionCityWarResult.allTimer - 1;
	objSwf.timer.text = UIUnionCityWarResult.allTimer;
	if UIUnionCityWarResult.allTimer <= 0 then 
		TimerManager:UnRegisterTimer(UIUnionCityWarResult.timerKey);
		UIUnionCityWarResult:Hide();
	end;
end;

function UIUnionCityWarResult:ClosePanel()
	local objSwf = self.objSwf;
	local startPos = UIManager:PosLtoG(objSwf.myItemList,0,0);
	local rewardList = RewardManager:ParseToVO(enAttrType.eaExp,"101","102",enAttrType.eaBindGold,'103');
	RewardManager:FlyIcon(rewardList,startPos,6,true,60);
	self:Hide()
end;
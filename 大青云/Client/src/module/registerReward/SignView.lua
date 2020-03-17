--[[
	签到
	2014年12月15日, PM 05:27:43
	wangyanwei
]]

_G.UISignPanel = BaseUI:new("UISignPanel");


function UISignPanel:Create()
	self:AddSWF("registerSignPanel.swf", true, nil);
end

function UISignPanel:OnLoaded(objSwf)
	objSwf.signState.click = function () self:OnSignClick() end       --签到补签点击
	objSwf.txt_vipInfo.text = StrConfig['registerReward53'];
	for i = 1 , 5 do
		objSwf["btn_" .. i].click = function () self:OnRewardClickHandler(i); end
		for j , v in pairs (t_signreward) do
			if v.id == i then
				objSwf["btn_" .. i].htmlLabel = string.format(StrConfig['registerReward54'],v.day);
			end
		end
		objSwf["tabReward_" .. i].complete = function () if not self:OnGetIsReward(i,1) then objSwf["tabReward_" .. i]:playEffect(1); end end
	end
	objSwf.randomList.itemRollOver = function(e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.randomList.itemRollOut = function() TipsManager:Hide(); end
	objSwf.btn_reward.click = function () self:OnClickReward(); end
	
	objSwf.signBtnEffect.visible = false;
	objSwf.getRewardBtn.visible = false;
	
	objSwf.signBtnEffect.complete = function () if not RegisterAwardModel:GetIndexSign(self.nowDay) then objSwf.signBtnEffect:playEffect(1); end end
	objSwf.getRewardBtn.complete = function () if not self:OnGetIsReward(self.setRewardIndex) then objSwf.getRewardBtn:playEffect(1); end end
	objSwf.signVipEffect.complete = function () objSwf.signVipEffect:playEffect(1); end
	objSwf.signGetEffect.complete = function () objSwf.signGetEffect:stopEffect(); objSwf.signGetEffect.visible = false; objSwf.signRewardMc._visible = true; end
	objSwf.btn_VIP.click = function () UIVip:Show() end
	objSwf.btn_VIP.visible = false;
end

function UISignPanel:OnHide()
	--self.txtChangeBoolean = true;
	--self:ChangeTxtNum();
	local objSwf = self.objSwf;
	objSwf.btn_reward.visible = false;
	objSwf.getRewardBtn:stopEffect()
	objSwf.btn_reward:clearEffect();
	
	objSwf.signGetEffect:stopEffect()
	objSwf.getRewardBtn.visible = false;
	objSwf.signGetEffect.visible = false;
	objSwf.signRewardMc._visible = false;
end

function UISignPanel:InitMC()
	local objSwf = self.objSwf;
	if not objSwf then return end
	for i = 1 , 42 do
		objSwf["signBg_" .. i]._visible = true;
		objSwf["sign_" .. i]._visible = true;
		objSwf["btnmakeSign_" .. i].visible = true;
		objSwf["btnadvan_" .. i].visible = true;
		objSwf["dayBg_" .. i]._visible = true;
		objSwf['toDay_' .. i]._visible = true;
		objSwf['future_' .. i]._visible = true;
		objSwf['yiqian_' .. i]._visible = true;
		objSwf['huiSignBg' .. i]._visible = false;
	end
end

function UISignPanel:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return end
	self:InitMC();
	self.gapDay = 0;   --当前日期与距离日期差了多少天
	self:OnChangeDatList();
	self:OnShowMySighList();
	self:OnRewardClickHandler(RegisterAwardModel:OnBackSignReward());
	objSwf.signVipEffect:playEffect(1);
	--self:OnChangeTxtNum();
	
	self:OnShowVipInfo();
end

--VIP相关显示
function UISignPanel:OnShowVipInfo()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local isVip = VipController:IsDiamondVip();		--是不是钻石VIP
	objSwf.btn_VIP.visible = not isVip;
	objSwf.txt_vipInfo._visible = not isVip;
	if isVip then
		objSwf.signVipEffect:stopEffect();
	else
		objSwf.signVipEffect:playEffect(0);
	end
end

--当前索引是否已领奖
function UISignPanel:OnGetIsReward(index,val)
	local num = 0;
	for i , v in pairs(t_signreward) do
		if v.id == index then
			num = v.day;
			break;
		end
	end
	local cfg = RegisterAwardModel:GetIndexSignReward(num);
	if val then
		if RegisterAwardModel:GetSignDayNum() < num and not cfg then return true end
	end	
	if not cfg then return false end
	if cfg.state ~= 1 then return false end
	return true;
end

--切换奖励内容
UISignPanel.setRewardIndex = 0;
function UISignPanel:OnRewardClickHandler(index)
	local objSwf = self.objSwf;
	objSwf.signGetEffect:stopEffect();
	objSwf.signGetEffect.visible = false;
	self.setRewardIndex = index;
	objSwf.signRewardMc._visible = false;
	objSwf.getRewardBtn:stopEffect()
	objSwf.getRewardBtn.visible = false;
	objSwf.btn_reward:clearEffect();
	objSwf["btn_" .. self.setRewardIndex].selected = true;
	local num = RegisterAwardModel:GetSignDayNum();
	local dayNum = 0;
	objSwf.btn_reward.visible = true;
	for i , v in pairs(t_signreward) do
		if v.id == index then
			dayNum = v.day;
			if num < v.day then
				objSwf.btn_reward.disabled = true;
				objSwf.getRewardBtn.visible = false;
				objSwf.btn_reward:clearEffect();
				objSwf.signRewardMc._visible = false;
			else
				objSwf.btn_reward.disabled = false;
				-- objSwf.getRewardBtn.visible = true;
				objSwf.btn_reward:showEffect(ResUtil:GetButtonEffect10());

			end
		end
	end
	if self:OnGetIsReward(index) then
		objSwf.signRewardMc._visible = true;
		objSwf.btn_reward.visible = false;
		objSwf.getRewardBtn.visible = false;
		objSwf.getRewardBtn:stopEffect();
		objSwf.btn_reward:clearEffect();
	else
		objSwf.signRewardMc._visible = false;
	end
	
	--播放签到次数达成领奖特效
	self:OnPlayerSignNumReward();
	
	local cfg = {};
	for i , v in pairs(t_signreward) do
		if v.id == index then
			cfg = v;
		end
	end
	local rewardList = {};
	if objSwf.btn_reward.visible then
		rewardList = RewardManager:Parse(cfg.common_reward);
	else
		rewardList = RewardManager:ParseBlack(cfg.common_reward);
	end
	objSwf.randomList.dataProvider:cleanUp();
	objSwf.randomList.dataProvider:push(unpack(rewardList));
	objSwf.randomList:invalidateData();
end

--播放签到次数达成领奖特效
function UISignPanel:OnPlayerSignNumReward()
	local objSwf = self.objSwf;
	if not objSwf then return end
	for i = 1 , 5 do
		if not self:OnGetIsReward(i,1) then
			objSwf["tabReward_" .. i].visible = true;
			objSwf["tabReward_" .. i]:playEffect(1);
		else
			objSwf["tabReward_" .. i]:stopEffect();
			objSwf["tabReward_" .. i].visible = false;
		end
	end
end

--播放领取特效
function UISignPanel:OnPlayRewardEffect(index)
	local objSwf = self.objSwf;
	if not objSwf then return end
	local rewardIndex = nil;
	for i , v in pairs(t_signreward) do
		if v.day == index then
			rewardIndex = v.id;
			break
		end
	end
	if self.setRewardIndex ~= rewardIndex then return end
	objSwf.btn_reward.visible = false;
	objSwf["tabReward_" .. rewardIndex].visible = false;
	objSwf.getRewardBtn.visible = false;
	objSwf.btn_reward:clearEffect();
	objSwf.signGetEffect.visible = true;
	objSwf.signGetEffect:playEffect(1);
	self:OnFlyIcon(index);
	self:OnPlayerSignNumReward();
end

function UISignPanel:OnFlyIcon(index)
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = split(t_signreward[index].common_reward,'#');
	for j , k in ipairs(cfg) do
		local idCfg = split(k,',');
		local rewardList = RewardManager:ParseToVO(toint(idCfg[1]));
		local startPos = UIManager:PosLtoG(objSwf['icon' .. j]);
		RewardManager:FlyIcon(rewardList,startPos,5,true,60);
	end
end

--点击签到
function UISignPanel:OnSignClick()
	RegisterAwardModel:GetSignData(self.nowDay,1);
	local objSwf = self.objSwf ;
	if not objSwf then return end
	local sx = objSwf["btnmakeSign_" .. self.McIndex]._x;
	local sy = objSwf["btnmakeSign_" .. self.McIndex]._y;
	local btn = objSwf[self:OnGetMcName()];
	if not btn then 
		btn = objSwf:attachMovie('SignEffect',
			self:OnGetMcName(),
			1
			);
	end
	btn._x = sx;
	btn._y = sy;
	if btn.initialized then
		btn:playEffect(1);
	else
		btn.init = function ()
			btn:playEffect(1);
		end
	end
	objSwf[self:OnGetMcName()].complete = function () btn.visible = false; end
end

function UISignPanel:OnGetMcName()
	return 'signEffect';
end

--点击领取奖励  rewardType 1是VIP奖励，2是普通玩家奖励
function UISignPanel:OnClickReward()
	local obj = {};
	for i , v in pairs(t_signreward) do
		if v.id == self.setRewardIndex then
			obj.day = v.day;
		end
	end
	obj.type = 0;
	RegisterAwardController:OnSendSignVipRewardHandler(obj);
end	
---------------------------------------------------------------对日历进行排序
UISignPanel.oldYear = 2000;
UISignPanel.oldMonth = 1;	 --2000年1月1日
UISignPanel.oldWeek = 6;     --那天是星期六
UISignPanel.gapDay = 0;   --当前日期与距离日期差了多少天

UISignPanel.nowMonth = 0;  --现在是几月；
UISignPanel.nowWeek = 0;   --这个月第一天是周几
UISignPanel.nowDay = 0;   --今天是几号
UISignPanel.lastMonthDayNum = 0;  --上个月多少天；
function UISignPanel:OnChangeDatList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.txt_info.text = UIStrConfig['registerReward505'];
	local timeData = CTimeFormat:todate(GetServerTime(), false);
	local yearData = split(timeData," ");  --得到现在服务器日期，并取到现在年月日
	local dayData = split(yearData[1],"-");   --得到年月日
	
	self.nowMonth = tonumber(dayData[2]);
	objSwf.txt_month.num = self.nowMonth;
	-->>上个月的信息
	local lastNum = self.nowMonth - 1;  --上个月是几月
	if lastNum == 0 then
		lastNum = 12;
		self.lastMonthDayNum = 31;
		self.nowMonthDayNum = 31;
	end
	self.nowDay = tonumber(dayData[3]);
	local state = RegisterAwardModel:GetIndexSign(self.nowDay);
	if state then
		objSwf.signBtnEffect.visible = false;
		objSwf.signBtnEffect:stopEffect();
		objSwf.signState:clearEffect();
	else
		-- objSwf.signBtnEffect.visible = true;
		-- objSwf.signBtnEffect:playEffect(1);
		objSwf.signState:showEffect(ResUtil:GetButtonEffect10());

		
	end
	
	local month31 = {1,3,5,7,8,10,12};
	local month30 = {4,6,9,11};
	
	local rpYear = false;
	for _year = self.oldYear , tonumber(dayData[1]) do
		if _year == tonumber(dayData[1])  then
			local monthNum = self.nowMonth ;
			for _month = self.oldMonth , monthNum - 1 do
				if _month == 2 then
					rpYear = (_year%4==0 and _year%100~=0)or(_year%400==0)
					self.gapDay = (rpYear and 29 or 28) + self.gapDay;
				else
					for j , k in pairs(month31) do
						if _month == k then 
							self.gapDay = self.gapDay + 31;
						end
						if lastNum == k then
							self.lastMonthDayNum = 31;
						end
						if self.nowMonth == k then
							self.nowMonthDayNum= 31;
						end
					end
					for j , k in pairs(month30) do
						if _month == k then 
							self.gapDay = self.gapDay + 30;
						end
						if lastNum == k then
							self.lastMonthDayNum = 30;
						end
						if self.nowMonth == k then
							self.nowMonthDayNum= 30;
						end
					end
				end
			end
		else
			self.gapDay = (((_year%4==0 and _year%100~=0)or(_year%400==0)) and 366 or 365) + self.gapDay;
		end
	end
	if lastNum == 2 then
		if rpYear then
			self.lastMonthDayNum = 29;
		else
			self.lastMonthDayNum = 28;
		end
	end
	if self.nowMonth == 2 then
		local _year = tonumber(dayData[1]);
		if (_year%4==0 and _year%100~=0)or(_year%400==0) then
			self.nowMonthDayNum = 29;
		else
			self.nowMonthDayNum = 28;
		end
	end
	local num = self.gapDay - (7 - self.oldWeek) ;
	self.nowWeek = num % 7;
end

--显示日历的签到未签到部分
UISignPanel.nowMonthDayNum = 0; --本月多少天
UISignPanel.McIndex = 0;
function UISignPanel:OnShowMySighList()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local num = 0;
	objSwf.dayNum.text = RegisterAwardModel:GetSignDayNum();
	for i = 1 , self.nowWeek do
		objSwf["signBg_" .. i]._visible = false;
		objSwf["sign_" .. i]._visible = false;
		objSwf["btnmakeSign_" .. i].visible = false;
		objSwf["btnadvan_" .. i].visible = false;
		objSwf["dayBg_" .. i]._visible = true;
		objSwf["future_" .. i]._visible = false;
		num = i;
		objSwf['toDay_' .. i]._visible = false;
		objSwf['yiqian_' .. i]._visible = false;
		objSwf['huiSignBg' .. i]._visible = true;
		--以前
		-- objSwf['txt_dayNum_' .. i].htmlText = string.format(StrConfig['registerReward1004'],self.lastMonthDayNum - (self.nowWeek - i));--以前
		objSwf['txt_dayNum1_' .. i].prefix = "v_qiandao_day_gray";
		objSwf['txt_dayNum1_' .. i].align = "center"
		objSwf['txt_dayNum1_' .. i].num = self.lastMonthDayNum - (self.nowWeek - i);
	end
	
	--提前签到天数
	local tiqianNum = VipController:GetTiqianqianNum() - RegisterAwardModel.vipTiqianNum ;
	if tiqianNum < 1 then
		tiqianNum = 1;
	end
	
	local showTiqianNum = 0;
	
	for i = 1 , self.nowMonthDayNum do
		if i == self.nowDay then
			objSwf['btnadvan_' .. (num + i)].visible = false;
			objSwf['btnmakeSign_' .. (num + i)].visible = false;
			if RegisterAwardModel:GetIndexSign(i) then
				objSwf['signBg_' .. (num + i)]._visible = true;
				objSwf['toDay_' .. (num + i)]._visible = false;
				objSwf['yiqian_' .. (num + i)]._visible = true;
			else
				objSwf['toDay_' .. (num + i)]._visible = true;
				objSwf['yiqian_' .. (num + i)]._visible = false;
				
			end
			self.McIndex = num + i;
			local aaa = (num + i) % 7;
			self:SignWeekDayNum(aaa);
			objSwf['sign_' .. (num + i)]._visible = false;
			-- objSwf['txt_dayNum_' .. (num + i)].htmlText = string.format(StrConfig['registerReward1001'],i);--今日
			objSwf['txt_dayNum1_' .. (num + i)].prefix = "v_qiandao_day"
			objSwf['txt_dayNum1_' .. (num + i)].align = "center"
			objSwf['txt_dayNum1_' .. (num + i)].num = i
			objSwf['future_' .. (num + i)]._visible = false;
			objSwf['dayBg_' .. (num + i)]._visible = false;
		else
			objSwf['signBg_' .. (num + i)]._visible = false;
			objSwf['yiqian_' .. (num + i)]._visible = false;
			if RegisterAwardModel:GetIndexSign(i) then
				objSwf['btnadvan_' .. (num + i)].visible = false;
				objSwf['btnmakeSign_' .. (num + i)].visible = false;
				objSwf['sign_' .. (num + i)]._visible = true;
				objSwf['dayBg_' .. (num + i)]._visible = true;
				objSwf['future_' .. (num + i)]._visible = false;
			else
				objSwf['sign_' .. (num + i)]._visible = false;
				if i < self.nowDay then
					objSwf['btnmakeSign_' .. (num + i)].visible = true;
					objSwf['btnmakeSign_' .. (num + i)].click = function() self:SignClickHandler(i,2); end;
					objSwf['btnmakeSign_' .. (num + i)].rollOver = function() TipsManager:ShowBtnTips( self:TipsBuqian(),TipsConsts.Dir_RightDown); end;
					objSwf['btnmakeSign_' .. (num + i)].rollOut = function() TipsManager:Hide(); end;
					objSwf['btnadvan_' .. (num + i)].visible = false;
					objSwf['future_' .. (num + i)]._visible = false;
					objSwf['dayBg_' .. (num + i)]._visible = true;
				else
					showTiqianNum = showTiqianNum + 1;
					objSwf['btnmakeSign_' .. (num + i)].visible = false;
					if showTiqianNum <= tiqianNum then					
						objSwf['btnadvan_' .. (num + i)].visible = true;
						objSwf['btnadvan_' .. (num + i)].click = function() self:SignClickHandler(i,3);  end;
						objSwf['btnadvan_' .. (num + i)].rollOver = function() TipsManager:ShowBtnTips( self:TipsTiQian(),TipsConsts.Dir_RightDown); end;
						objSwf['btnadvan_' .. (num + i)].rollOut = function() TipsManager:Hide(); end;
					else
						objSwf['btnadvan_' .. (num + i)].visible = false;
					end
					objSwf['dayBg_' .. (num + i)]._visible = false;
				end
			end
			-- objSwf['txt_dayNum_' .. (num + i)].htmlText = string.format(StrConfig['registerReward1002'],i);--正常
			objSwf['txt_dayNum1_' .. (num + i)].prefix = "v_qiandao_day"
			objSwf['txt_dayNum1_' .. (num + i)].align = "center"
			objSwf['txt_dayNum1_' .. (num + i)].num = i
			objSwf['toDay_' .. (num + i)]._visible = false;
		end
	end
	local state = RegisterAwardModel:GetIndexSign(self.nowDay);
	if state then
		objSwf.signState.label = StrConfig['registerReward56'];objSwf.signState.disabled = state;
		objSwf.signBtnEffect.visible = false;
		objSwf.signBtnEffect:stopEffect();
		objSwf.signState:clearEffect();

	else
		objSwf.signState.label = StrConfig['registerReward55'];objSwf.signState.disabled = state;
		-- objSwf.signBtnEffect.visible = true;
		-- objSwf.signBtnEffect:playEffect(1);
		objSwf.signState:showEffect(ResUtil:GetButtonEffect10());
	end
	local nextNum = 1;
	for i = self.nowMonthDayNum + num , 42 do
		if i > 41 then
			return 
		end
		objSwf["signBg_" .. (i + 1)]._visible = false;
		objSwf["sign_" .. (i + 1)]._visible = false;
		objSwf["btnmakeSign_" .. (i + 1)].visible = false;
		objSwf["btnadvan_" .. (i + 1)].visible = false;
		objSwf["dayBg_" .. (i + 1)]._visible = true;
		objSwf['toDay_' .. (i + 1)]._visible = false;
		objSwf['future_' .. (i + 1)]._visible = false;
		objSwf['yiqian_' .. (i + 1)]._visible = false;
		--未来
		-- objSwf['txt_dayNum_' .. (i + 1)].htmlText = string.format(StrConfig['registerReward1003'],nextNum);
		objSwf['txt_dayNum1_' .. (i + 1)].prefix = "v_qiandao_day_gray";
		objSwf['txt_dayNum1_' .. (i + 1)].align = "center"
		objSwf['txt_dayNum1_' .. (i + 1)].num = nextNum
		nextNum = nextNum + 1;
	end
end

--今天星期几
UISignPanel.weekIndex = 0;
function UISignPanel:SignWeekDayNum(num)
	local objSwf = self.objSwf;
	if not objSwf then return end
	if num < 7 and num > 1 then
		self.weekIndex = num - 1;
	elseif num == 0 then 
		self.weekIndex = 6;
	elseif num == 1 then
		self.weekIndex = 7;
	end
	-- objSwf.weekPanel['week_' .. self.weekIndex].selected = true;
end	

function UISignPanel:SignClickHandler(day,state)
	local vipLevel = MainPlayerModel.humanDetailInfo.eaVIPLevel;
	if vipLevel == 0 then
		FloatManager:AddNormal( StrConfig["registerReward100"] );
		return ;
	end
	-- local cfg = t_vip[vipLevel];
	if state == 2 then --补签
		if RegisterAwardModel.vipBuqianNum >= VipController:GetBuqianNum() then
			FloatManager:AddNormal( StrConfig["registerReward101"] );
			return
		end
	elseif state == 3 then --提前签
		if RegisterAwardModel.vipTiqianNum >= VipController:GetTiqianqianNum() then
			FloatManager:AddNormal( StrConfig["registerReward102"] );
			return
		end
	end
	RegisterAwardModel:GetSignData(day,state);
end

function UISignPanel:TipsTiQian()
	local str = '';
	local vipLevel = MainPlayerModel.humanDetailInfo.eaVIPLevel;
	-- local cfg = t_vip[vipLevel];
	str = str .. StrConfig['registerReward500'] .. '<br/>';
	local tiqianNum = VipController:GetTiqianqianNum();
	if tiqianNum <= 0 then tiqianNum = 0 end
	if vipLevel ~= 0 then
		str = str .. string.format(StrConfig['registerReward501'],vipLevel) .. '<br/>';
		str = str .. string.format(StrConfig['registerReward502'],tiqianNum - RegisterAwardModel.vipTiqianNum) .. '<br/>' .. BaseTips:GetLine2();
	else
		str = str .. string.format(StrConfig['registerReward501'],0) .. '<br/>';
		str = str .. string.format(StrConfig['registerReward502'],0) .. '<br/>' .. BaseTips:GetLine2();
	end
	
	local tiqian = VipController:GetTiqianqianList()
	for i = 0 , 10 do
		local str1 = '';
		if i < 10 then
			str1 = string.format(StrConfig['registerReward504'],i) .. ' ';
		else
			str1 = string.format(StrConfig['registerReward504'],i);
		end
		local str2 = '';
		if tiqian['c_v'..i] < 10 then
			str2 = ' ' .. tiqian['c_v'..i]
		else
			str2 = '' .. tiqian['c_v'..i]
		end
		str = str .. str1 .. string.format(StrConfig['registerReward503'],str2) .. '<br/>'
	end
	return str
end

function UISignPanel:TipsBuqian()
	local str = '';
	local vipLevel = MainPlayerModel.humanDetailInfo.eaVIPLevel;
	-- local cfg = t_vip[vipLevel];
	str = str .. StrConfig['registerReward600'] .. '<br/>';
	local buqianNum = VipController:GetBuqianNum();
	if buqianNum <= 0 then buqianNum = 0 end
	if vipLevel ~= 0 then
		str = str .. string.format(StrConfig['registerReward601'],vipLevel) .. '<br/>';
		str = str .. string.format(StrConfig['registerReward602'],buqianNum - RegisterAwardModel.vipBuqianNum) .. '<br/>' .. BaseTips:GetLine2();
	else
		str = str .. string.format(StrConfig['registerReward601'],0) .. '<br/>';
		str = str .. string.format(StrConfig['registerReward602'],0) .. '<br/>' .. BaseTips:GetLine2();
	end
	
	local buqian = VipController:GetBuqianNumList()
	for i = 0 , 10 do
		local str1 = '';
		if i < 10 then
			str1 = string.format(StrConfig['registerReward604'],i) .. ' ';
		else
			str1 = string.format(StrConfig['registerReward604'],i);
		end
		local str2 = '';
		if buqian['c_v'..i] < 10 then
			str2 = ' ' .. buqian['c_v'..i]
		else
			str2 = '' .. buqian['c_v'..i]
		end
		str = str .. str1 .. string.format(StrConfig['registerReward603'],str2) .. '<br/>'
	end
	return str
end

-----------------------------------------------------------------------------------
------------------------------        UI      -------------------------------------
-----------------------------------------------------------------------------------
function UISignPanel:HandleNotification(name,body)
	if not self.bShowState then return; end
	if name == NotifyConsts.UpdataSignState then
		-- self:OnShowMySighList();
		-- self:OnRewardClickHandler(self.setRewardIndex);
		self:OnShow();
	elseif name == NotifyConsts.SignRewardUpData then
		self:OnPlayRewardEffect(body.index);
		-- self:OnRewardClickHandler(self.setRewardIndex);
		-- self:OnShow();
	end
	
end
function UISignPanel:ListNotificationInterests()
	return {
		NotifyConsts.UpdataSignState,NotifyConsts.SignRewardUpData
	}
end
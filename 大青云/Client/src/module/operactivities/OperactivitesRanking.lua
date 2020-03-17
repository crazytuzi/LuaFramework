--[[
	展示
	2015年10月12日, PM 08:15:41
]]

_G.UIOperactivitesRanking = BaseUI:new('UIOperactivitesRanking');
UIOperactivitesRanking.remainTime = 0
UIOperactivitesRanking.timeType = 2
UIOperactivitesRanking.timerKey = nil;
UIOperactivitesRanking.showModel = ""
UIOperactivitesRanking.lastTime = 0
function UIOperactivitesRanking:Create()
	self:AddSWF('operactivitesRankReward.swf',true,nil);
end

function UIOperactivitesRanking:OnLoaded(objSwf)
	objSwf.list.handlerRewardClick = function (e) self:GetRewardClick(e); end
	objSwf.list.itemRewardRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.list.itemRewardRollOut = function () TipsManager:Hide(); end
	
	objSwf.uiRankList.btnRankList.click = function()
		self:ShowPanelFirst()
	end;
	objSwf.uiRankList.btnRankList.selected = true
	objSwf.uiRankList.btnFirst.click = function() 		
		self:ShowPanelRankList()
	end;
	-- objSwf.uiRankList.panelFirst._visible = false 
	-- objSwf.uiRankList.panelFirst.mcXuweiyidai._visible = false
	objSwf.uiRankList.panelFirst.labelName.text = ''
	objSwf.uiRankList.panelFirst.roleload.hitTestDisable = true;
end

function UIOperactivitesRanking:ShowPanelFirst()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	objSwf.uiRankList.panelFirst._visible = true 
	objSwf.uiRankList.rankList._visible = false  
	objSwf.uiRankList.panelFirst.labelName.text = ''
	self:DrawRole()
end

function UIOperactivitesRanking:ShowPanelRankList()
	local objSwf = self.objSwf
	if not objSwf then return end

	objSwf.uiRankList.panelFirst._visible = false 
	objSwf.uiRankList.rankList._visible = true   
	self:ShowRankList()
end

function UIOperactivitesRanking:OnShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	local group = OperActUIManager.currentGroupId	
	objSwf.uiRankList.btnRankList.selected = true
	OperactivitiesController:RespPartyInfo(group)
end

function UIOperactivitesRanking:UpdateUI()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	local group = OperActUIManager.currentGroupId	
	
	OperactivitiesController:ReqPartyRank(group)	
	
	objSwf.list.dataProvider:cleanUp();
	local allData = self:GetListData();
	objSwf.list.dataProvider:push( unpack(allData) );
	objSwf.list:invalidateData();
	
	objSwf.txtGroupTxt.text = OperactivitiesModel:GetGroupTxtByGroupId(group)
	objSwf.txtRemindTime.text = ""

	local mainType,subType = OperactivitiesModel:GetOperActType(group)
	local value, nameStr = 0, "当前阶数："
	if subType == 2 then
		--战力
		value = MainPlayerModel.humanDetailInfo.eaFight
		nameStr = "当前" ..OperactivitiesConsts.RankNameList[2]
	elseif subType == 3 then
		--坐骑
		value = MountUtil:GetMountLv()
	elseif subType == 9 then
		--神兵
		value = MagicWeaponModel:GetLevel()
	elseif subType == 10 then
		--法宝
		value = LingQiModel:GetLevel()
	elseif subType == 11 then
		--宝甲
		value = ArmorModel:GetLevel()
	else
		nameStr = nil
	end
	if not value or value < 0 then
		value = 0
	end
	if nameStr then
		objSwf.txtMyInfo.htmlText = nameStr .. "<font color='#00ff00'>" .. value .."<font>"
	else
		objSwf.txtMyInfo.htmlText = ""
	end
	--命玉 MingYuModel:GetLevel()

	local imgUrl = OperactivitiesModel:GetGroupImageByGroupId(group)
	if imgUrl and imgUrl ~= "" then
		imgUrl = ResUtil:GetOperActivityIcon(imgUrl)
		if imgUrl ~= objSwf.imgshow.source then
			objSwf.imgshow.source = imgUrl		
		end
	else
		objSwf.imgshow.source = ""
	end
	self.remainTime,self.timeType = OperactivitiesModel:GetGroupRemainTimeByGroupId(group)
	if self.remainTime > 0 then
		if self.timerKey then 
			TimerManager:UnRegisterTimer(self.timerKey);
			self.timerKey = nil;
		end;
		self.timerKey = TimerManager:RegisterTimer(function() self:Ontimer() end,1000,0);
		self:Ontimer();
	end
	
	if self.timeType == 2 then
		objSwf.labTimeRemain.text = StrConfig['operactivites19']
	elseif self.timeType == 3 then
		objSwf.labTimeRemain.text = StrConfig['operactivites20']
	else	
		objSwf.labTimeRemain.text = StrConfig['operactivites21']
	end
	
	local actVO = OperactivitiesModel:GetActVOByGroupId(group)
	self.showModel = OperactivitiesModel:GetModelScene(actVO.showModel)
	self:Show3DWeapon()
end

function UIOperactivitesRanking : Ontimer()
	local objSwf = self.objSwf
	if not objSwf then return end
	if self.remainTime < 0 then self.remainTime = 0 end
	local day,hour,mint,sec = CTimeFormat:sec2formatEx(self.remainTime)
	if day > 0 then
		objSwf.txtRemindTime.text = string.format(StrConfig["operactivites6"],day,hour,mint);
	else
		objSwf.txtRemindTime.text = string.format(StrConfig["operactivites7"],hour,mint);
	end
	
	self.remainTime = self.remainTime - 1
	if self.remainTime <= -10 then
		if self.timerKey then 
			TimerManager:UnRegisterTimer(self.timerKey);
			self.timerKey = nil;
			
		end;
		UIMainOperActivites:Hide()
	end
	
	local day,hour,mint,sec = CTimeFormat:sec2formatEx(GetLocalTime())
	FPrint('当前的小时和分'..hour..':'..mint..':'..sec)
	if hour == 0 and mint == 0 and sec >= 2 and sec <= 3 then
		if self.timerKey then 
			TimerManager:UnRegisterTimer(self.timerKey);
			self.timerKey = nil;
		end;
		UIMainOperActivites:Hide()
	end
end;


--所有数据
function UIOperactivitesRanking:GetListData()
	--将可领奖的放在上面  拆分，排序，重组
	local group = OperActUIManager.currentGroupId	
	local actList = OperactivitiesModel.groupList[group]	
	FPrint('UIOperactivitesRanking:GetListData所有数据'..group)
	-- FTrace(actList)
	
	local list = {}
	local vo;
	for i , v in ipairs(actList) do		
		vo = {};
		vo.id = v.id	
		vo.eachTxt = v.eachTxt or '没有配:id'..v.id
		if not v.isAward then v.isAward = 0 end
		if not v.reward then v.reward = '' end
		
		vo.isAward = v.isAward
		vo.reward = v.reward
		
		local majorStr = UIData.encode(vo);
		
		local rewardList = RewardManager:Parse( v.reward );
		local rewardStr = table.concat(rewardList, "*");
		local finalStr = majorStr .. "*" .. rewardStr;
		table.push(list, finalStr);
	end
	return list
end

function UIOperactivitesRanking:PlayYilingqu(actId)
	local objSwf = self.objSwf
	if not objSwf then return end
	--将可领奖的放在上面  拆分，排序，重组
	local group = OperActUIManager.currentGroupId	
	local actList = OperactivitiesModel.groupList[group]	
	
	local list = {}
	local vo;
	for i , v in ipairs(actList) do	
		if v.id == actId then
			local vo = {};
			if not v.isAward then v.isAward = 0 end
			if not v.reward then v.reward = '' end
			
			vo.id = v.id	
			vo.eachTxt = v.eachTxt or '没有配:id'..v.id
			vo.isAward = v.isAward
			vo.reward = v.reward
			
			local majorStr = UIData.encode(vo);
			
			local rewardList = RewardManager:Parse( v.reward );
			local rewardStr = table.concat(rewardList, "*");
			local finalStr = majorStr .. "*" .. rewardStr;
			
			self.objSwf.list.dataProvider[i - 1] = finalStr
			local uiSlot = self.objSwf.list:getRendererAt(i - 1)
			if uiSlot then
				uiSlot:setData(finalStr);
				if v.isAward == 2 then
					uiSlot:PlayYilingqu()
					OperactivitiesModel:GoRewardfun(uiSlot, v.reward)
				end
			end
		end
	end
	return list
end

-- 显示初始化list
function UIOperactivitesRanking:ShowRankList()
	local objSwf = self.objSwf
	if not objSwf then return end
	-- 清空数据
	objSwf.uiRankList.rankList.listtxt.dataProvider:cleanUp();
	objSwf.uiRankList.rankList.listtxt.dataProvider:push(unpack({}));
	objSwf.uiRankList.rankList.listtxt:invalidateData();
	
	local lisc = OperactivitiesModel.powerRankList
	FTrace(lisc, '显示初始化list')
	if not lisc then return end;
	local voc = {}
	for i,info in ipairs(lisc) do
		local vo = self:GetRoleItemUIdata(info,10)
		if vo then 
			table.push(voc,vo)
		end
	end;
	objSwf.uiRankList.rankList.listtxt.dataProvider:cleanUp();
	objSwf.uiRankList.rankList.listtxt.dataProvider:push(unpack(voc));
	objSwf.uiRankList.rankList.listtxt:invalidateData();
end;

function UIOperactivitesRanking:DrawRole()
	local objSwf = self.objSwf
	if not objSwf then return end
	if self.objUIRoleDraw then
		self.objUIRoleDraw:SetDraw(false);
		self.objUIRoleDraw:SetMesh(nil)
	end
	if self.objAvatar then 
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end;

	self.objSwf.uiRankList.panelFirst.mcXuweiyidai._visible = false
	local info = OperactivitiesModel.powerRankFirst
	if not info or not info.prof or info.prof < 1 or info.prof > 4 then 
		self.objSwf.uiRankList.panelFirst.mcXuweiyidai._visible = true
		return 		
	end

	local uiLoader = self.objSwf.uiRankList.panelFirst.roleload;
	local prof = info.prof;
	self.objSwf.uiRankList.panelFirst.labelName.text = info.roleName or ''

	if self.objAvatar then 
		self.objAvatar:ExitMap()
		self.objAvatar = nil;
	end;
	self.objAvatar = CPlayerAvatar:new();
	self.objAvatar:CreateByVO(info);

	--
    if not self.objUIRoleDraw then
		self.objUIRoleDraw = UIDraw:new("UIOperactivitesRankingRole",self.objAvatar, uiLoader,
							UIDrawRoleCfg[prof].VPort,UIDrawRoleCfg[prof].EyePos,UIDrawRoleCfg[prof].LookPos,
							0x00000000,"UIRole", prof);
	else
		self.objUIRoleDraw:SetUILoader(uiLoader);
		self.objUIRoleDraw:SetCamera(UIDrawRoleCfg[prof].VPort,UIDrawRoleCfg[prof].EyePos,UIDrawRoleCfg[prof].LookPos);
		self.objUIRoleDraw:SetMesh(self.objAvatar);
	end
	self.meshDir = 0;
	self.objAvatar.objMesh.transform:setRotation(0,0,1,self.meshDir);
	self.objUIRoleDraw:SetDraw(true);
	--播放特效
	-- if self.pfxName ~= nil then 
		-- self.objUIRoleDraw:StopPfx(self.pfxName)
	-- end;
	-- local sex = info.sex
	-- local pfxName = "ui_role_sex" ..sex.. ".pfx";
	-- local name,pfx = self.objUIRoleDraw:PlayPfx(pfxName);
	-- self.pfxName = name;
	-- 微调参数
	-- pfx.transform:setRotationX(UIDrawRoleCfg[prof].pfxRotationX);

end;

local labList = {}
function UIOperactivitesRanking:GetRoleItemUIdata(info)
	if not info then return end;
	
	local group = OperActUIManager.currentGroupId
	local actVO = OperactivitiesModel:GetActVOByGroupId(group)	
	
	local vo = {};	
	vo.roleName = info.name;	
	vo.isFirst = false;
	if info.rank == 3 then 
		vo.rank = "c";
		vo.isFirst = true;
	elseif info.rank == 2 then 
		vo.rank = "b";
		vo.isFirst = true;
	elseif info.rank == 1 then 
		vo.rank = "a";
		vo.isFirst = true;
	else 
		vo.rank = info.rank;
		vo.isFirst = false;
	end;
	vo.head = ''--ResUtil:GetHeadIcon60(info.prof)		
	vo.rankvlue = info.rank
	local subType = actVO.subType or 1
	local labName = OperactivitiesConsts.RankNameList[subType] or ''
	if subType == 5 then
		if t_wuhun[info.val] then
			local lv = t_wuhun[info.val].order or ''
			vo.fight = labName..lv
		else
			vo.fight = labName..'0'
		end
	else
		vo.fight = labName..info.val	
	end
	
	-- if info.role <= 0 or info.role > 4 then 
		-- print("*******Error********：abot roleType is nil . No ShowList   AT  ranklistSuitview  '119' line")
		-- return 
	-- end;	
	return UIData.encode(vo)
end;

--领奖点击
function UIOperactivitesRanking:GetRewardClick(e)
	if GetCurTime() - self.lastTime > OperactivitiesConsts.delayReawrd then
		FPrint('领奖点击'..e.item.id)	
		OperactivitiesController:ReqGetPartyAward(e.item.id, 1)
		self.lastTime = GetCurTime()
	end
end

function UIOperactivitesRanking:ListNotificationInterests()
	return {
		NotifyConsts.OperActivityInitInfo,
		NotifyConsts.UpdateOperActAwardState,
		NotifyConsts.UpdateGroupInfo,
		NotifyConsts.UpdateOperActPowerList,
		NotifyConsts.OperActivityInitState,
	}
end

function UIOperactivitesRanking:HandleNotification( name, body )
	if not self:IsShow() then
		return
	end 

	if name == NotifyConsts.OperActivityInitInfo then
		-- self:UpdateUI()
	elseif name == NotifyConsts.OperActivityInitState then
		self:UpdateUI()
	elseif name == NotifyConsts.UpdateOperActAwardState then
		self:PlayYilingqu(body.actId)
	elseif name == NotifyConsts.UpdateOperActPowerList then 
		self:ShowPanelFirst();  
	elseif name == NotifyConsts.UpdateGroupInfo then		
		local group = OperActUIManager.currentGroupId	
		if group == body.groupId then
			self:UpdateUI()
		end
	end	
end


function UIOperactivitesRanking:OnDelete()
	if self.objUIRoleDraw then
		self.objUIRoleDraw:SetUILoader(nil);
	end
	
	local name = 'UIOperactivitesRanking'
	local objUIDraw = UIDrawManager:GetUIDraw(name);
	if objUIDraw then
		objUIDraw:SetUILoader(nil);
	end
end

function UIOperactivitesRanking:OnHide()
	local objSwf = self.objSwf
	if not objSwf then return end
	if self.objUIRoleDraw then
		self.objUIRoleDraw:SetDraw(false);
		self.objUIRoleDraw:SetMesh(nil)
	end
	if self.objAvatar then 
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end;
	
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
	
	local name = 'UIOperactivitesRanking'
	local objUIDraw = UIDrawManager:GetUIDraw(name);
	if objUIDraw then
		objUIDraw:SetDraw(false);
	end
end;

function UIOperactivitesRanking:Show3DWeapon()
	local objSwf = self.objSwf
	if not objSwf then return end	
	
	if not self.showModel or self.showModel == "" then
		local name = 'UIOperactivitesRanking'
		local objUIDraw = UIDrawManager:GetUIDraw(name);
		if self.objUIDraw then
			self.objUIDraw:SetDraw(false);
		end
		return
	end
	
	local loader = objSwf.roleLoader
	local name      = 'UIOperactivitesRanking'
	if not self.objUIDraw then
		self.objUIDraw = UISceneDraw:new( name, loader, _Vector2.new(1800, 1200), true);
	end	
	self.objUIDraw:SetUILoader( loader )	
	local src = self.showModel
	if not src then return end
	self.objUIDraw:SetScene(src);	
	self.objUIDraw:SetDraw(true);	
end
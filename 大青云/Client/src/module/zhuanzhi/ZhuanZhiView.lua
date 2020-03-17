--[[
转职
 jiayong

]]
_G.UIZhuanZhiView=BaseUI:new("UIZhuanZhiView")
function UIZhuanZhiView:Create()
	self:AddSWF("zhuanzhipanel.swf",true,"center")
end
function UIZhuanZhiView:OnLoaded(objSwf)
    objSwf.closebtn.click = function() self:Hide()end
    for i = 1, 5 do
    	objSwf["item" ..i].rewardList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
		objSwf["item" ..i].rewardList.itemRollOut = function () TipsManager:Hide(); end
		objSwf["btn"  ..i].rollOver = function() TipsManager:ShowBtnTips(StrConfig['zhuanzhi' .. (i + 2)]) end
		objSwf["btn"  ..i].rollOut = function() TipsManager:Hide() end
    end
end

function UIZhuanZhiView:OnShow()
	--显示转职信息
	local lv = ZhuanZhiModel:GetLv()
	if lv < ZhuanZhiConsts.MaxLv then
		self.nIndex = lv + 1
	else
		self.nIndex = lv
	end
	self:showBtnInfo()
	self:ShowZhuanZhiInfo(true)	
end;

function UIZhuanZhiView:showBtnInfo()
	local objSwf = self.objSwf
	if not objSwf then return end

	for i = 1, 5 do
		local btn = objSwf["itemBtn" ..i]
		if i > 3 then
			btn._visible = false
		end
		local info = t_transferattr[i]
		btn.disabled = ZhuanZhiModel:GetLv() + 1 < i
		objSwf["btn" ..i]._visible = ZhuanZhiModel:GetLv() + 1 < i
		if i > 3 then
			objSwf["btn" ..i]._visible = false
		end
		if i == self.nIndex then
			btn.selected = true
		end
		btn.click = function() if self.nIndex ~= i then self.nIndex = i self:ShowZhuanZhiInfo(true) end end
	end
end

function UIZhuanZhiView:ShowZhuanZhiInfo(bInit)
	local objSwf = self.objSwf;
	if not objSwf then return end
	for i = 1, 5 do
		local UI = objSwf["item" ..i]
		local index = (self.nIndex - 1) * 5 + i
		local cfg = t_transfer[index]
		if cfg then
			UI._visible = true
			UI.btnQuest.visible = true
			local task = ZhuanZhiModel:getTask()
			if not task or task:GetId() ~= cfg.number then
				task = QuestFactory:CreateQuest(cfg.number, nil, QuestConsts.State_Going, {[1] = {current_count = 0}})
			end
			if not task then return; end
			for j = 1, 5 do
				UI["titleIcon" ..j]._visible = i == j
			end
			
			local val = split(task:GetCfg().val, ",")
			val = val[2] or val[1]
			UI.imggetted._visible = false
			UI.rewardPfx._visible = false
			UI.btn_getReward._visible = false  --领奖
			UI.btnQuest.click = function() task:DoGoal() end
			if ZhuanZhiModel:GetCount() >= index then
				-- 已完成
				UI.txt_detail.htmlText = string.format(StrConfig['zhuanzhi22'], task:GetCfg().describe)
				UI.txt_value.text = val .. "/" .. val
				UI.txt_value._visible = false
				UI.imggetted._visible = true
				UI.bggetted.click = function() end
			elseif ZhuanZhiModel:GetCount() + 1 < index then
				-- 未接取
				UI.txt_detail.htmlText = string.format(StrConfig['zhuanzhi23'], task:GetCfg().describe)
				UI.txt_value.htmlText = StrConfig['zhuanzhi1']
				UI.txt_value._visible = true
				UI.bggetted.click = function() end
				UI.btnQuest.click = function() FloatManager:AddNormal(StrConfig['zhuanzhi24']) end
			elseif task:GetState() == QuestConsts.State_CanFinish then
				-- 已完成(未领取)
				UI.rewardPfx._visible = true
				UI.txt_detail.htmlText = string.format(StrConfig['zhuanzhi22'], task:GetCfg().describe)
				UI.txt_value.text = val .. "/" .. val
				UI.btn_getReward._visible = true
				UI.txt_value._visible = false
				UI.bggetted.click = function() end
				UI.btn_getReward.click = function() ZhuanZhiController:AskGetReward(cfg.id) end
			else
				-- 未完成
				UI.txt_detail.htmlText = string.format(StrConfig['zhuanzhi21'], task:GetCfg().describe)
				UI.txt_value.text = task:GetGoal():GetCurrCount() .. "/" .. val	
				UI.txt_value._visible = true
				UI.bggetted.click = function() end
			end
			local randomList = RewardManager:Parse( cfg.reward );
			UI.rewardList.dataProvider:cleanUp();
			UI.rewardList.dataProvider:push(unpack(randomList));
			UI.rewardList:invalidateData();
		else
			UI._visible = false
			UI.btnQuest.visible = false
		end
	end
	if ZhuanZhiModel:GetLv() >= self.nIndex then
		objSwf.AutoBtn.visible = false
	else
		objSwf.AutoBtn.visible = false
		objSwf.AutoBtn.disabled = true
		objSwf.AutoBtn.click = function()
			if ZhuanZhiModel:GetCount() < (self.nIndex - 1) * 5 + 1 then
				FloatManager:AddNormal(StrConfig['zhuanzhi2']);
				return
			end

			local config = t_transferattr[self.nIndex]
			local costInfo = split(config.consume, '#')
			local okfun = function()
				for k, v in pairs(costInfo) do
					local cost = split(v,',');
					if BagModel:GetItemNumInBag(toint(cost[1])) < tonumber(cost[2]) then
						UIQuickBuyConfirm:Open(self,toint(cost[1]))
						FloatManager:AddNormal(StrConfig["equip507"])
						return
					end
				end
				ZhuanZhiController:AutoZhuanZhi();
			end
			local cost = split(costInfo[1],',')
			UIConfirm:Open(string.format(StrConfig["zhuanzhi11"], t_item[toint(cost[1])].name .. "X" .. cost[2]),okfun); 
		end
	end
	if bInit then
		self.objSwf:gotoAndPlay(1)
		self:ShowModelInfo()
	end
end

function UIZhuanZhiView:ShowModelInfo()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local zhuanzhiCfg = t_transferattr[self.nIndex]

	-- local cfg = t_item[zhuanzhiCfg.item]
	-- if not cfg then return end
	-- if cfg.modelDraw == "" then return; end
	-- local senName = "";
	-- local t = split(cfg.modelDraw,"#");
	-- if #t == 1 then
	-- 	senName = t[1];
	-- else
	-- 	senName = t[MainPlayerModel.humanDetailInfo.eaProf];
	-- end
	-- if not senName or senName=="" then return; end
	local loader = objSwf.loader
	
	if not self.objUIDraw then
		self.objUIDraw = UISceneDraw:new( "UIZhuanZhiView", loader, _Vector2.new(420, 570));
	end
	self.objUIDraw:SetDraw(false);
	self.objUIDraw:SetScene( zhuanzhiCfg.mode);
	self.objUIDraw:SetDraw( true );
	-- objSwf.txt_detail.htmlText = StrConfig['zhuanzhi10' ..self.nIndex]
	if zhuanzhiCfg.icon2 and zhuanzhiCfg.icon2 ~= "" then
		objSwf.iconDetail.source = ResUtil:GetZhuanZhiIcon(zhuanzhiCfg.icon2)
		objSwf.iconDetail._visible = true
	else
		objSwf.iconDetail._visible = false
	end
	if zhuanzhiCfg.modeicon and zhuanzhiCfg.modeicon ~= "" then
		objSwf.iconDetail1.source = ResUtil:GetZhuanZhiIcon(zhuanzhiCfg.modeicon, true)
		objSwf.iconDetail1._visible = true
	else
		objSwf.iconDetail1._visible = false
	end
	-- objSwf.fightLoader.num = PublicUtil:GetFigthValue(AttrParseUtil:Parse(zhuanzhiCfg.attr))
end

function UIZhuanZhiView:HandleNotification(name,body)
	if name == NotifyConsts.ZhuanZhiSuccess then
		local lv = ZhuanZhiModel:GetLv()
		if lv < ZhuanZhiConsts.MaxLv then
			self.nIndex = lv + 1
		else
			self.nIndex = lv
		end
		self:showBtnInfo()
		self:ShowZhuanZhiInfo(true)
	else
		self:ShowZhuanZhiInfo()
	end
end
function UIZhuanZhiView:ListNotificationInterests()
	return {
		NotifyConsts.ZhuanZhiSuccess,
		NotifyConsts.ZhuanZhiUpdate,
	}
end

function UIZhuanZhiView:IsShowSound()
	return true
end

function UIZhuanZhiView:OnHide()
	if ZhuanZhiModel:IsHaveRewardCanGet() then
		RemindController:AddRemind(RemindConsts.Type_ZhuanZhi, 1);
	else
		RemindController:AddRemind(RemindConsts.Type_ZhuanZhi, 0);
	end
	local uidraw = self.objUIDraw
	if uidraw then
		uidraw:SetDraw(false);
		uidraw:SetUILoader(nil);
		UIDrawManager:RemoveUIDraw(uidraw);
		self.objUIDraw = nil;
	end
	return true
end
function UIZhuanZhiView:GetWidth()
	return 1146;
end
function UIZhuanZhiView:GetHeight()
	return 687
end
function UIZhuanZhiView:IsShowLoading()
	return true;
end

function UIZhuanZhiView:IsTween()
	return true;
end
function UIZhuanZhiView:GetPanelType()
	return 1;
end
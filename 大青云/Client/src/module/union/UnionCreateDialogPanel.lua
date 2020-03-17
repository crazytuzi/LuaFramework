--[[
帮派:帮派列表面板
liyuan
2014年11月20日16:22:09
]]


_G.UIUnionCreateDialog = BaseUI:new("UIUnionCreateDialog")
UIUnionCreateDialog.maxNameLength = 16;--名字最大长度
UIUnionCreateDialog.maxNoticeLength = 120;
UIUnionCreateDialog.needItemId = 0
UIUnionCreateDialog.needItemNum = 0

function UIUnionCreateDialog:Create()
	self:AddSWF("unionCreateDialogPanel.swf", true, "top");
end

function UIUnionCreateDialog:OnLoaded(objSwf, name)
	for i=70, 76 do 
		objSwf['labUnion'..i].text = UIStrConfig['union'..i]
	end
	-- objSwf['labUnionVip'].text = ''
	-- objSwf['labUnionVip'].text = '3、'..UIStrConfig['union99']
	objSwf.btnCreate.click = function() 
		local unionNotice = ''
		unionNotice = ''
		if objSwf.labUnion73.text ~= objSwf.labUnion73.defaultText then
			unionNotice = objSwf.labUnion73.text or ''
			unionNotice = _G.strtrim(unionNotice)
		end
		
		local name = objSwf.labUnion72.text;
		if name == objSwf.labUnion72.defaultText then
			FloatManager:AddCenter(StrConfig['union57']);
			return;
		end
		if name == "" then
			FloatManager:AddCenter(StrConfig['union57']);
			return;
		end
		if string.getLen(name) > UIUnionCreateDialog.maxNameLength then
			FloatManager:AddCenter(StrConfig['union58']);
			return;
		end
		if name:find('[%p*%s*]')==1 then
			FloatManager:AddCenter(StrConfig['union58']);
			return;
		end
		local filterName = ChatUtil.filter:filter(name);
		if filterName:find("*") then
			FloatManager:AddCenter(StrConfig['union58']);
			return;
		end
		
		-- local vipLevel = MainPlayerModel.humanDetailInfo.eaVIPLevel;
		--VIP等级
		-- if vipLevel <= 0 then 
			-- FloatManager:AddCenter(UIStrConfig['union99']);
			-- return;
		-- end		
		local level = t_consts[15].val1 or 0
		--金币
		-- local myMoney = MainPlayerModel.humanDetailInfo.eaBindGold + MainPlayerModel.humanDetailInfo.eaUnBindGold
		-- if myMoney < money then
			-- FloatManager:AddSysNotice(2005024);--您尚未达到创建条件
			-- FloatManager:AddCenter(StrConfig['union71']);
			-- return;
		-- end
		
		if self.needItemId ~= 0 then						
			local itemNum = BagModel:GetItemNumInBag(self.needItemId)			
			if itemNum < self.needItemNum then
				FloatManager:AddCenter(StrConfig['union71']);
				return;
			end		
		end
		
		local mainPlayerLevel = MainPlayerModel.humanDetailInfo.eaLevel;
		--解锁等级
		if mainPlayerLevel < level then 
			-- FloatManager:AddSysNotice(2005024);--您尚未达到创建条件
			FloatManager:AddCenter(StrConfig['union71']);
			return;
		end
		
		UnionController:ReqCreateGuild(name, unionNotice) self:Hide() 
	end
	--close button
	objSwf.btnClose.click = function() self:OnBtnCloseClick() end
	objSwf.labUnion72.textChange = function()
								local name = objSwf.labUnion72.text;
								if string.getLen(name) > UIUnionCreateDialog.maxNameLength then
									FloatManager:AddCenter(StrConfig['union51']);
									objSwf.labUnion72.text = string.sub(name,1,-2)
								end
	end
	
	objSwf.labUnion73.textChange = function()
								local name = objSwf.labUnion73.text;
								if string.getLen(name) > UIUnionCreateDialog.maxNoticeLength then
									-- FloatManager:AddCenter(StrConfig['union51']);
									objSwf.labUnion73.text = string.sub(name,1,180)
								end
	end
	objSwf.btn_item.rollOver = function () if self.needItemId ~= 0 then TipsManager:ShowItemTips(self.needItemId); end end
	objSwf.btn_item.rollOut = function () TipsManager:Hide(); end
end

function UIUnionCreateDialog:OnShow()
	local objSwf = self.objSwf
	if not objSwf then return; end
	local itemList = split(t_consts[16].param, ',')
	self.needItemId = toint(itemList[1])
	self.needItemNum = toint(itemList[2])
	
	objSwf.labUnion72.text = ""
	objSwf.labUnion73.text = ""
	self:UpdateCreateCondition()
end


--消息处理
function UIUnionCreateDialog:HandleNotification(name,body)
	if not self.bShowState then return end
	local objSwf = self.objSwf
	if not objSwf then return; end
	
	if name == NotifyConsts.StageClick then
		if objSwf.labUnion72.focused then
			local ipSearchTarget = string.gsub(objSwf.labUnion72._target,"/",".");
			local ipSearchTarget1 = string.gsub(objSwf.btnCreate._target,"/",".");
			if string.find(body.target,ipSearchTarget) or string.find(body.target,ipSearchTarget1) then
				return;
			end
		end
		if objSwf.labUnion73.focused then
			local ipSearchTarget = string.gsub(objSwf.labUnion73._target,"/",".");
			local ipSearchTarget1 = string.gsub(objSwf.btnCreate._target,"/",".");
			if string.find(body.target,ipSearchTarget) or string.find(body.target,ipSearchTarget1) then
				return;
			end
		end
	
		self:OnIpSearchFocusOut()
	elseif name == NotifyConsts.StageFocusOut then
		self:OnIpSearchFocusOut()
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type==enAttrType.eaBindGold or body.type==enAttrType.eaUnBindGold or body.type == enAttrType.eaLevel or body.type == enAttrType.eaVIPLevel then
			self:UpdateCreateCondition();
		end
	elseif name == NotifyConsts.BagItemNumChange then
		if self.needItemId == body.id then
			self:UpdateCreateCondition()
		end
	end
end

-- 消息监听
function UIUnionCreateDialog:ListNotificationInterests()
	return {NotifyConsts.StageClick,
			NotifyConsts.StageFocusOut,
			NotifyConsts.BagItemNumChange,
			NotifyConsts.PlayerAttrChange};
end
function UIUnionCreateDialog:GetPanelType()
	return 0;
end

function UIUnionCreateDialog:ESCHide()
	return true;
end

------------------------------------------------------------------------------
--									UI事件处理
------------------------------------------------------------------------------
function UIUnionCreateDialog:UpdateCreateCondition()
	local objSwf = self.objSwf
	if not objSwf then return; end

	
	local level = t_consts[15].val1 or 0	
	
	local colorLevelStr = '#00ff00'	
	local colorReachedVIPStr = '#29CC00'	
	
	local isReachedLevelStr = StrConfig['union48']
	local isReachedVIPStr = StrConfig['union48']
	--银两	
	local colorStr = '#00ff00'
	if self.needItemId ~= 0 then
		local itemCfg = t_item[tonumber(self.needItemId)]
		
		local itemNum = BagModel:GetItemNumInBag(self.needItemId)
		-- SpiritsUtil:Print(self.needItemId..':'..itemNum)
		
		if itemNum < self.needItemNum then
			colorStr = '#ff0000'
		end
		objSwf.txtNeedMoney.htmlText = string.format(StrConfig["wuhun18"],colorStr,itemCfg.name,self.needItemNum);
	else 
		objSwf.txtNeedMoney.text = ""
	end
	
	local mainPlayerLevel = MainPlayerModel.humanDetailInfo.eaLevel;
	--解锁等级
	if mainPlayerLevel < level then 
		colorLevelStr = '#ff0000'
		isReachedLevelStr = StrConfig['union49']
	end
	
	local vipLevel = MainPlayerModel.humanDetailInfo.eaVIPLevel;
	--VIP等级
	if vipLevel <= 0 then 
		colorReachedVIPStr = '#780000'
		isReachedVIPStr = StrConfig['union49']
	end
	
	objSwf.labUnion77.text = string.format(UIStrConfig['union77'], level)
	objSwf.txtNeedLevel.htmlText = '<font color="'..colorLevelStr..'">'..string.format(StrConfig['union30'], level)..'</font><font color="'..colorLevelStr..'">('..isReachedLevelStr..')</font>'
	-- objSwf.txtNeedMoney.htmlText = '<font color="'..colorReachedMoneyStr..'">'..money..'('..isReachedMoneyStr..')</font>'
	-- objSwf.txtNeedVip.htmlText = '<font color="'..colorReachedVIPStr..'">('..isReachedVIPStr..')</font>'
end

function UIUnionCreateDialog:OnBtnCloseClick()
	self:Hide()
end

--输入文本失去焦点
function UIUnionCreateDialog:OnIpSearchFocusOut()
	local objSwf = self:GetSWF("UIUnionCreateDialog");
	if not objSwf then return; end
	if objSwf.labUnion72.focused and objSwf.labUnion72.text == '' then
		objSwf.labUnion72.focused = false;
	end
	if objSwf.labUnion73.focused and objSwf.labUnion73.text == '' then
		objSwf.labUnion73.focused = false;
	end
end
function UIUnionCreateDialog:IsShowSound()
	return true;
end

function UIUnionCreateDialog:IsShowLoading()
	return true;
end

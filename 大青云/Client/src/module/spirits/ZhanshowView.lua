--[[武魂界面主面板
liyuan
2014年9月28日10:33:06
]]

_G.UIzhanshou = BaseSlotPanel:new("UIzhanshou") 

UIzhanshou.hunzhuNum = 5
UIzhanshou.starthunzhuX = 482
UIzhanshou.starthunzhuY = 443
UIzhanshou.hunzhuGap = 63
UIzhanshou.isShowConfirm = false

UIzhanshou.roleRender = nil
UIzhanshou.isShowRole = false
UIzhanshou.roleVO = nil
UIzhanshou.isShowAni = false
UIzhanshou.currentShowLevel = 0
local last3dId = 0

--技能列表
UIzhanshou.skillicon = nil
UIzhanshou.skilllist = {}
UIzhanshou.skillTotalNum = 4;--UI上技能总数

UIzhanshou.zhudongskillicon = nil
UIzhanshou.zhudongskilllist = {}
UIzhanshou.zhudongskillTotalNum = 2
UIzhanshou.NumTimerId = nil
UIzhanshou.TipHunzhuNum = 100	--背包魂球超过100时提示全部灌注
UIzhanshou.isMouseDrag = false

UIzhanshou.slotTotalNum = 4;
UIzhanshou.list = {};

function UIzhanshou:Create()
	self:AddSWF("zhanshouPanel.swf", true, nil)	
end

local isShowDes = false
local mouseMoveX = 0
function UIzhanshou:OnLoaded(objSwf,name)
	self.roleRender = RoleDrawRender:New(objSwf.roleLoader, 'UIzhanshou',true)
	
	objSwf.btnRoleLeft.stateChange = function(e) 
		if objSwf.btnRadioLinshou.selected then
			if self.objUIDraw then
				self.objUIDraw:OnBtnRoleLeftStateChange(e.state); 
			end
		else
			self.roleRender:OnBtnRoleLeftStateChange(e.state); 
		end
	end;
	objSwf.btnRoleLeft.visible = false
	objSwf.btnRoleRight.stateChange = function(e) 
		if objSwf.btnRadioLinshou.selected then
			if self.objUIDraw then
				self.objUIDraw:OnBtnRoleRightStateChange(e.state); 
			end
		else
			self.roleRender:OnBtnRoleRightStateChange(e.state); 
		end
	end;
	objSwf.btnRoleRight.visible = false
	-- objSwf.mcJinjieGuanzhu.btnJinjie.click = function() self:OnBtnLevelUpClick() end
	-- objSwf.btnFusheng.click = function() self:AhjunctionWuhun() end
	objSwf.mcJinjieGuanzhu.btnGuanzhu.click = function() self:OnBtnFeedClick() end
	self:HideNextLevel()
	objSwf.mcJinjieGuanzhu.siPro.rollOver = function() self:OnProgressBarRollOver() end
	objSwf.mcJinjieGuanzhu.siPro.rollOut = function() self:OnProgressBarRollOut() end
	
	objSwf.btnShuXingDan.click = function() self:OnBtnFeedSXDClick() end
	--属性丹tip
	objSwf.btnShuXingDan.rollOver = function() self:OnShuXingDanRollOver(); end
	objSwf.btnShuXingDan.rollOut  = function()  UIMountFeedTip:Hide();  end
	
	--被动技能
	-- for i=1,self.skillTotalNum do
		-- self.skillicon[i] = objSwf["skill"..i]
		-- self.skillicon[i].btnskill.rollOver = function(e) skillBeidongRollOver(i); end
		-- self.skillicon[i].btnskill.rollOut  = function() self:OnSkillItemOut();  end
	-- end
	
	--主动技能
	-- for i=1,self.zhudongskillTotalNum do
		-- self.zhudongskillicon[i] = objSwf["skillZhudong"..i]
		-- self.zhudongskillicon[i].btnskill.rollOver = function(e) self:OnSkillItemOver(i); end
		-- self.zhudongskillicon[i].btnskill.rollOut  = function() self:OnSkillItemOut();  end
	-- end
	
	objSwf.mcJinjieGuanzhu.btnConsume.rollOver = function(e) self:OnWeiyangIconOver(e); end
	objSwf.mcJinjieGuanzhu.btnConsume.rollOut = function(e) self:OnWeiyangIconOut(e); end
	objSwf.mcJinjieGuanzhu.btnGuanzhu.rollOver = function(e) self:OnGuanzhuBtnOver(e); end
	objSwf.mcJinjieGuanzhu.btnGuanzhu.rollOut = function(e) self:OnWeiyangIconOut(e); end
	objSwf.mcJinjieGuanzhu.ball1.rollOver = function(e) self:OnHunzhu1IconOver(e); end
	objSwf.mcJinjieGuanzhu.ball1.rollOut = function(e) self:OnWeiyangIconOut(e); end
	objSwf.mcJinjieGuanzhu.ball2.rollOver = function(e) self:OnHunzhu2IconOver(e); end
	objSwf.mcJinjieGuanzhu.ball2.rollOut = function(e) self:OnWeiyangIconOut(e); end
	objSwf.mcJinjieGuanzhu.ball3.rollOver = function(e) self:OnHunzhu3IconOver(e); end
	objSwf.mcJinjieGuanzhu.ball3.rollOut = function(e) self:OnWeiyangIconOut(e); end
	objSwf.mcJinjieGuanzhu.ball4.rollOver = function(e) self:OnHunzhu4IconOver(e); end
	objSwf.mcJinjieGuanzhu.ball4.rollOut = function(e) self:OnWeiyangIconOut(e); end
	objSwf.mcJinjieGuanzhu.ball5.rollOver = function(e) self:OnHunzhu5IconOver(e); end
	objSwf.mcJinjieGuanzhu.ball5.rollOut = function(e) self:OnWeiyangIconOut(e); end
	objSwf.mcJinjie.btnStart.rollOver = function(e) self:ShowNextLevel(e); end
	objSwf.mcJinjie.btnAuto.rollOver = function(e) self:ShowNextLevel(e); end
	objSwf.mcJinjie.btnStart.rollOut = function(e) self:HideNextLevel(e); end
	objSwf.mcJinjie.btnAuto.rollOut = function(e) self:HideNextLevel(e); end
	objSwf.mcJinjieGuanzhu.proLoader.loadComplete    = function() 
			local objSwf = self.objSwf;
			if not objSwf then return end;
			local numLoader = objSwf.mcJinjieGuanzhu.proLoader;
			local bg = objSwf.mcJinjieGuanzhu.posSign;
			numLoader._x = bg._x - numLoader._width * 0.5;
			numLoader._y = bg._y - numLoader._height * 0.5;
		end
	self:HideAllHunZhunEffect(objSwf)
	objSwf.btnPre.click              = function() self:OnBtnPreClick(); end
	objSwf.btnNext.click             = function() self:OnBtnNextClick(); end
	objSwf.chkBoxUseModel.click      = function() self:OnChkBoxUseModelClick() end
	
	-- objSwf.labPower.text = UIStrConfig['wuhun19']
	-- objSwf.labAddPro.text = UIStrConfig['wuhun5']
	-- objSwf.labWuhunJinjie.text = UIStrConfig['wuhun7']
	-- objSwf.tflevelup.text = UIStrConfig['wuhun20']
	-- objSwf.tflevelup._visible = false
	for i=1,7 do
		objSwf['mcUpArrow'..i]._visible = false
	end
	for i = 0, 4 do
			objSwf.mcJinjieGuanzhu['ball'..(i + 1)].ballLoader.loaded = function() 
				local ballEffect = objSwf.mcJinjieGuanzhu['ball'..(i + 1)].ballLoader.content.effect;
				if ballEffect then
					ballEffect:playEffect(0);
				end
			end
	end
	-- objSwf.mcJinjieGuanzhu.progressBar:gotoAndStopEffect(1)
	-- objSwf.nsFeedNum.change = function(e) self:OnNsChange(e); end
	objSwf.incrementFight._visible = false
	objSwf.tfVIPFightAdd.text = ''
	-- objSwf.fight.numFight.loadComplete = function()	
										-- objSwf.fight.numFight.x = 580 + (230 - objSwf.fight.numFight.width)/2
										-- objSwf.mcUpArrowZhanDouLi._x = objSwf.fight.numFight.x + objSwf.fight.numFight.width + 25;
										-- objSwf.txtUpZhanDouLi._x = objSwf.mcUpArrowZhanDouLi._x + 5
								   -- end
	objSwf.imgName.loaded = function()
		-- objSwf.imgName._x = 159 + (432 - objSwf.imgName.content._width)/2
		-- objSwf.imgLevel._x = objSwf.imgName._x + objSwf.imgName.content._width + 5;
	end
	
	objSwf.btnRadioLinshou.click = function() 
		if not SpiritsModel:getWuhuVO() or not SpiritsModel:getWuhuVO().wuhunId or SpiritsModel:getWuhuVO().wuhunId == 0 then return end
		local wid = SpiritsModel:getWuhuVO().wuhunId
		-- FPrint(self.currentShowLevel..':'..wid)
		if self.currentShowLevel ~= 0 and self.currentShowLevel ~= wid then
			wid = self.currentShowLevel
			self:ShowViewWuhunInfo( self.currentShowLevel )
		end 
		
		local wuhunCfg = t_wuhun[wid]
		if not wuhunCfg then
			return
		end
		
		local cfg = t_lingshouui[wuhunCfg.ui_id];
		if not cfg then
			Error("Cannot find config of t_lingshouui. level:"..level);
			return;
		end
		-- objSwf.roleLoader._visible = false
		if self.roleRender then 
			self.roleRender:OnHide()
		end
		if self.objUIDraw then
			local dataArr = split(cfg.ui_node,"#");
			for k,v in pairs (dataArr) do
				self.objUIDraw:NodeVisible(v,true)
			end
		end
	end
	objSwf.btnRadioShenshou.click = function() 
		if not SpiritsModel:getWuhuVO() or not SpiritsModel:getWuhuVO().wuhunId or SpiritsModel:getWuhuVO().wuhunId == 0 then return end
		local wid = SpiritsModel:getWuhuVO().wuhunId
		-- FPrint(self.currentShowLevel..':'..wid)
		if self.currentShowLevel ~= 0 and self.currentShowLevel ~= wid then
			wid = self.currentShowLevel
			self:ShowViewWuhunInfo( self.currentShowLevel )
		end 
		
		local wuhunCfg = t_wuhun[wid]
		if not wuhunCfg then
			return
		end
		
		local cfg = t_lingshouui[wuhunCfg.ui_id];
		if not cfg then
			Error("Cannot find config of t_lingshouui. level:"..level);
			return;
		end
		self:SetRoleRender(wid)
		-- objSwf.roleLoader._visible = true
		if self.objUIDraw then
			local dataArr = split(cfg.ui_node,"#");
			for k,v in pairs (dataArr) do
				self.objUIDraw:NodeVisible(v,false)
			end
		end
	end
	objSwf.iconDes._alpha = 0
	objSwf.btnDesShow.rollOver = function()
		if isShowDes then return end
		local wuhunId = self.currentShowLevel
		if not wuhunId or wuhunId <= 0 then
			FPrint("要显示的武魂id不正确")
			return
		end
		local cfg = t_wuhun[wuhunId]
		if not cfg then return end
		local uiCfg = t_lingshouui[cfg.ui_id]
		if uiCfg and uiCfg.des_icon then
			objSwf.iconDes.desLoader.source = ResUtil:GetWuhunDesIcon(uiCfg.des_icon)
		end
		Tween:To(objSwf.iconDes,5,{_alpha=100});
		isShowDes = true
	end

	objSwf.btnDesShow.rollOut = function()
		self.isMouseDrag = false
		if self.objUIDraw then
		
			self.objUIDraw:OnBtnRoleRightStateChange("out"); 				
		end
		if self.roleRender then
			self.roleRender:OnBtnRoleRightStateChange("out");
		end
		if not isShowDes then return end
		
		Tween:To(objSwf.iconDes,1,{_alpha=0});
		isShowDes = false
	end
	
	objSwf.btnDesShow.press = function() 		
		local monsePosX = _sys:getRelativeMouse().x;--获取鼠标位置		
		mouseMoveX = monsePosX;   		       
		self.isMouseDrag = true
	end

	objSwf.btnDesShow.release = function()
		self.isMouseDrag = false
		if self.objUIDraw then
			self.objUIDraw:OnBtnRoleRightStateChange("release"); 				
		end
		if self.roleRender then
			self.roleRender:OnBtnRoleRightStateChange("release");
		end
	end
	UILevelUpSpirits:OnLoaded(objSwf.mcJinjie)
	
	--初始化格子
	for i=1,self.slotTotalNum do
		self:AddSlotItem(BaseItemSlot:new(objSwf["item"..i]),i);
	end
end

function UIzhanshou:OnDelete()
	self:RemoveAllSlotItem()
	self.zhudongskillicon = nil
	self.skillicon = nil
	if self.roleRender then
		self.roleRender:OnDelete()
		self.roleRender = nil;
	end
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
	
	UILevelUpSpirits:OnDelete()
end

function UIzhanshou:Update()
	if not self.bShowState then return end
	local objSwf = self.objSwf
	if not objSwf then return end
	
	if self.isMouseDrag then
		local monsePosX = _sys:getRelativeMouse().x;--获取鼠标位置		
		if mouseMoveX<monsePosX then
			local speed = monsePosX - mouseMoveX
			if objSwf.btnRadioLinshou.selected then
				if self.objUIDraw then
					self.objUIDraw:OnBtnRoleRightStateChange("down",speed); 
				end
			else
				if self.roleRender then
					self.roleRender:OnBtnRoleRightStateChange("down",speed); 
				end
			end           
		elseif mouseMoveX>monsePosX then 
			local speed = mouseMoveX - monsePosX
			if objSwf.btnRadioLinshou.selected then
				if self.objUIDraw then
					self.objUIDraw:OnBtnRoleLeftStateChange("down",speed); 
				end
			else
				if self.roleRender then
					self.roleRender:OnBtnRoleLeftStateChange("down",speed); 
				end
			end           
		end
		mouseMoveX = monsePosX;
	end	
	
	if objSwf.btnRadioShenshou.selected then
		if self.roleRender then 
			self.roleRender:Update() 
		end
	end
	
	if not SpiritsModel:getWuhuVO() or not SpiritsModel:getWuhuVO().wuhunId or SpiritsModel:getWuhuVO().wuhunId == 0 then return end
	local wuhunId = SpiritsModel:getWuhuVO().wuhunId
	local wid = SpiritsModel:getWuhuVO().wuhunId
	if self.currentShowLevel ~= 0 and self.currentShowLevel ~= wuhunId then
		wuhunId = self.currentShowLevel
	end 
	
	
	local wuhunCfg = t_wuhun[wuhunId]
	if not wuhunCfg then
		return
	end
	
	local cfg = t_lingshouui[wuhunCfg.ui_id];
	if not cfg then
		Error("Cannot find config of t_lingshouui. level:"..level);
		return;
	end
	
	if objSwf.btnRadioLinshou.selected then
		if self.objUIDraw then
			local dataArr = split(cfg.ui_node,"#");
			for k,v in pairs (dataArr) do
				self.objUIDraw:Update(v)
			end
		end
	end
	
	
end

function UIzhanshou:GetWidth(szName)
	return 1489 
end

function UIzhanshou:GetHeight(szName)
	return 744
end

function UIzhanshou:OnShow(name)
	local objSwf = self.objSwf
	if not objSwf then return end
	
	
	
	--被动技能
	if not self.skillicon then
		self.skillicon = {}
		for i=1,self.skillTotalNum do
			self.skillicon[i] = objSwf["skill"..i]
			self.skillicon[i].btnskill.rollOver = function(e) self:skillBeidongRollOver(i); end
			self.skillicon[i].btnskill.rollOut  = function() self:OnSkillItemOut();  end
		end
	end
	
	--主动技能
	if not self.zhudongskillicon then
		self.zhudongskillicon = {}
		for i=1,self.zhudongskillTotalNum do
			self.zhudongskillicon[i] = objSwf["skillZhudong"..i]
			self.zhudongskillicon[i].btnskill.rollOver = function(e) self:OnSkillItemOver(i); end
			self.zhudongskillicon[i].btnskill.rollOut  = function() self:OnSkillItemOut();  end
		end
	end
	
	self.isShowAni = true
	self.currentShowLevel = 0;
	self:ShowWuhunInfo()
	self:SetZhanshouAndLingshou()
	self:InitVip()
	self:ShowEquip();
	self:ShowUseModelState();
end

function UIzhanshou:InitVip()
	local objSwf = self.objSwf
	if not objSwf then return end
	--objSwf.btnVipBack.visible = false
	--objSwf.btnVipLvUp.visible = false	
	-- VIP权限
	-- if VipController:GetIsLingshouBack() == 1 then 
		-- objSwf.btnVipBack.disabled = false
	-- else
		-- objSwf.btnVipBack.disabled = true
	-- end
	objSwf.btnVipBack.click = function() UIVipBack:Open(VipConsts.TYPE_LINGSHOU) end	
	objSwf.btnVipBack.rollOver = function() self:OnBtnVipBackRollOver(); end
	objSwf.btnVipBack.rollOut  = function()  self:OnBtnVipBackrollOut();  end
	
	objSwf.btnVipLvUp.click = function() UIVip:Show() end	
	objSwf.btnVipLvUp.rollOver = function(e) 
		-- local vipLevel = VipController:GetVipLevel()
		-- local upRate = 0
		-- local attMap = nil
		-- local tipsTxt = ""
		-- local nextRate = 0
		-- if VipController:GetLingshouLvUp() > 0 then
		-- 	upRate = VipController:GetLingshouLvUp()
		-- 	local nextRate = VipController:GetLingshouLvUp(vipLevel + 1)
		-- 	attMap = self:GetAttMap()
		-- 	tipsTxt = VipController:GetLevelUpTips(attMap, upRate, nextRate)	
		-- else
		-- 	upRate = VipController:GetLingshouLvUp(1)
		-- 	attMap = self:GetAttMap()
		-- 	tipsTxt = VipController:GetNoVipTips(attMap, upRate)	
		-- end
	
		-- TipsManager:ShowTips( TipsConsts.Type_Normal, tipsTxt, TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );

		
		local attMap = self:GetAttMap()
		VipController:ShowAttrTips( attMap, UIVipAttrTips.ls ,VipConsts.TYPE_DIAMOND)
	end
	objSwf.btnVipLvUp.rollOut = function(e) VipController:HideAttrTips() end
end

function UIzhanshou:skillBeidongRollOver(i)
	local skillId = self.skilllist[i].skillId;
	local get = self.skilllist[i].lvl > 0;
	TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=skillId,condition=true,get=get,unShowLvlUpPrompt = true},TipsConsts.ShowType_Normal,
						TipsConsts.Dir_RightUp);
end

function UIzhanshou:SetZhanshouAndLingshou(wuhunId)
	local objSwf = self.objSwf
	if not objSwf then return end
	if not wuhunId then
		if not SpiritsModel:getWuhuVO() or not SpiritsModel:getWuhuVO().wuhunId or SpiritsModel:getWuhuVO().wuhunId == 0 then return end
		wuhunId = SpiritsModel:getWuhuVO().wuhunId
	end
	
	local wuhunCfg = t_wuhun[wuhunId]
	if not wuhunCfg then
		return
	end
	
	local cfg = t_lingshouui[wuhunCfg.ui_id];
	if not cfg then
		Error("Cannot find config of t_lingshouui. level:"..level);
		return;
	end
	
	if objSwf.btnRadioLinshou.selected then
		-- objSwf.roleLoader._visible = false
		if self.roleRender then 
			self.roleRender:OnHide()
		end
		if self.objUIDraw then
			local dataArr = split(cfg.ui_node,"#");
			for k,v in pairs (dataArr) do
				self.objUIDraw:NodeVisible(v,true)
			end
		end
	else
		-- objSwf.roleLoader._visible = true
		self:SetRoleRender(wuhunId)
		if self.objUIDraw then
			local dataArr = split(cfg.ui_node,"#");
			-- FTrace(dataArr)
			for k,v in pairs (dataArr) do
				self.objUIDraw:NodeVisible(v,false)
			end
		end
	end
end

function UIzhanshou:OnFullShow()
	local objSwf = self:GetSWF("UIzhanshou")
	if not objSwf then return end
	self.firstOpenState = false
	if not SpiritsModel:getWuhuVO() or not SpiritsModel:getWuhuVO().wuhunId or SpiritsModel:getWuhuVO().wuhunId == 0 then return end
	
	-- self:SetRoleRender(SpiritsModel:getWuhuVO().wuhunId)
end

function UIzhanshou:OnHide()
	if self.NumTimerId then 
		TimerManager:UnRegisterTimer(self.NumTimerId)
		self.NumTimerId = nil
	end
	last3dId = 0
	self.firstOpenState = true
	UIConfirm:Close(self.confirmUID);
	self.isShowConfirm = false
	if self.roleRender then 
		self.roleRender:OnHide()
	end
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	
	UILevelUpSpirits:OnHide()
	UIVipBack:Hide()
end

---------------------------------ui事件处理------------------------------------


-- 激活按钮的响应
function UIzhanshou:OnBtnActiveClick()
	if not SpiritsModel:getWuhuVO() or not SpiritsModel:getWuhuVO().wuhunId or SpiritsModel:getWuhuVO().wuhunId == 0 then return end
	SpiritsController:ActiveWuhun(SpiritsModel:getWuhuVO().wuhunId)
end

-- 附身按钮的响应
function UIzhanshou:AhjunctionWuhun()
	if not SpiritsModel:getWuhuVO() or not SpiritsModel:getWuhuVO().wuhunId or SpiritsModel:getWuhuVO().wuhunId == 0 then return end

	if SpiritsModel:GetWuhunState(SpiritsModel:getWuhuVO().wuhunId) == 1 then
		SpiritsController:AhjunctionWuhun(SpiritsModel:getWuhuVO().wuhunId, 0)
	else
		SpiritsController:AhjunctionWuhun(SpiritsModel:getWuhuVO().wuhunId, 1)
	end
end

UIzhanshou.lastSendTime = 0;

-- 喂养按钮的响应
function UIzhanshou:OnBtnFeedClick()
	if not SpiritsModel:getWuhuVO() or not SpiritsModel:getWuhuVO().wuhunId or SpiritsModel:getWuhuVO().wuhunId == 0 then return end
	if not SpiritsModel:getWuhuVO().wuhunId then return end

	if GetCurTime() - self.lastSendTime < 200 then
		return;
	end
	self.lastSendTime = GetCurTime();


	local feedNum = 1
	local feedTable = t_wuhun[SpiritsModel:getWuhuVO().wuhunId].feed_consume
	local feedItemId = feedTable[1]
	local bagItemNum = BagModel:GetItemNumInBag(feedItemId) or 0 --背包中的魂珠数量
	
	if bagItemNum >= UIzhanshou.TipHunzhuNum then
		feedNum = UIzhanshou:GetMaxFeedNum(0)
		local confirmFunc = function()
			self.isShowConfirm = false
			self:ConfirmFeedWuhun(feedNum)
		end
		local canncelFunc = function()
			-- FPrint('喂养按钮的取消')
			self.isShowConfirm = false
		end
		if not self.isShowConfirm then
			self.isShowConfirm = true
			self.confirmUID = UIConfirm:Open( StrConfig["wuhun48"], confirmFunc, canncelFunc, StrConfig['confirmName2'], StrConfig['confirmName3'] );
		end
	else
		self:ConfirmFeedWuhun(feedNum)
	end
end

function UIzhanshou:ConfirmFeedWuhun(guanzhuNum)
	local objSwf = self:GetSWF("UIzhanshou")
	--local guanzhuNum = 1--objSwf.nsFeedNum.value
	if not SpiritsModel:getWuhuVO() or not SpiritsModel:getWuhuVO().wuhunId or SpiritsModel:getWuhuVO().wuhunId == 0 then return end
	local wuhunId = SpiritsModel:getWuhuVO().wuhunId
	local cfg = t_wuhun[wuhunId]
	local shangxian = cfg.feed_progress -- 喂养进度上限
	local feedValue = SpiritsModel.currentWuhun.hunzhuProgress
	
	if feedValue >= shangxian*self.hunzhuNum then
		FloatManager:AddNormal( StrConfig["wuhun33"], objSwf.btnGuanzhu );
		return
	end
	
	if SpiritsUtil:CanFeed(SpiritsModel:getWuhuVO().wuhunId, guanzhuNum) == false then
		FloatManager:AddNormal( StrConfig["wuhun21"], objSwf.btnGuanzhu );
		return
	end

	SpiritsController:FeedWuhun(SpiritsModel:getWuhuVO().wuhunId, guanzhuNum)
end

--喂养进度条鼠标悬浮
function UIzhanshou:OnProgressBarRollOver()
	if not SpiritsModel:getWuhuVO() or not SpiritsModel:getWuhuVO().wuhunId or SpiritsModel:getWuhuVO().wuhunId == 0 then return end
	local att, def, hp, hit, dodge, critical, defcri = SpiritsUtil:GetPropertyUP(SpiritsModel:getWuhuVO().wuhunId)

	TipsManager:ShowBtnTips( string.format(StrConfig["wuhun20"],self:GetAttributeUpValueStr(att, def, hp, hit, dodge, critical, defcri)));
end

--喂养进度条鼠标滑离
function UIzhanshou:OnProgressBarRollOut()
	TipsManager:Hide();
end

function UIzhanshou:OnBtnVipBackRollOver()
	UIVipBackTips:Open( VipConsts.TYPE_LINGSHOU )
end

function UIzhanshou:OnBtnVipBackrollOut()
	UIVipBackTips:Hide()
end

--技能鼠标移上
function UIzhanshou:OnSkillItemOver(i)
	if not self.zhudongskilllist or not self.zhudongskilllist[i] then return end
	local skillId = self.zhudongskilllist[i].skillId;
	if not skillId then return end
	
	TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=tonumber(skillId), condition = true,unShowLvlUpPrompt =true, get = true},TipsConsts.ShowType_Normal,
						TipsConsts.Dir_RightUp);
end

--技能鼠标移出
function UIzhanshou:OnSkillItemOut(e)
	TipsManager:Hide();
end

--喂养道具鼠标移上
function UIzhanshou:OnWeiyangIconOver(e)
	local objSwf = self:GetSWF("UIzhanshou")
	if not SpiritsModel:getWuhuVO() then return end
	if not SpiritsModel:getWuhuVO() or not SpiritsModel:getWuhuVO().wuhunId or SpiritsModel:getWuhuVO().wuhunId == 0 then return end
	TipsManager:ShowItemTips(SpiritsUtil:GetFeedItemId(SpiritsModel:getWuhuVO().wuhunId))
end

--喂养道具鼠标移出
function UIzhanshou:OnWeiyangIconOut(e)
	TipsManager:Hide();
end

--激活道具鼠标移上
function UIzhanshou:ShowJihuotiaojian(e)
	-- SpiritsUtil:Print("ssssssss")

	local objSwf = self:GetSWF("UIzhanshou")
	if not SpiritsModel:getWuhuVO() or not SpiritsModel:getWuhuVO().wuhunId or SpiritsModel:getWuhuVO().wuhunId == 0 then return end
	local itemId = SpiritsUtil:GetActiveItemId(SpiritsModel:getWuhuVO().wuhunId)
	if itemId > 0 then
		TipsManager:ShowItemTips(itemId)
	end
end

--激活道具鼠标移出
function UIzhanshou:HideJihuotiaojian(e)
	TipsManager:Hide();
end

-- 喂养按钮的tips
function UIzhanshou:OnGuanzhuBtnOver(e)
	local objSwf = self:GetSWF("UIzhanshou")
	if not SpiritsModel:getWuhuVO() or not SpiritsModel:getWuhuVO().wuhunId or SpiritsModel:getWuhuVO().wuhunId == 0 then return end
	local itemId = SpiritsUtil:GetFeedItemId(SpiritsModel:getWuhuVO().wuhunId)
	
	-- 最大购买数
	-- local nsFeedNum = objSwf.nsFeedNum;
	-- nsFeedNum._value = self.defBuyNum;
	-- nsFeedNum:updateLabel();
	
	-- local guanzhuNum = objSwf.nsFeedNum.value
	local guanzhuNum = 1
	local colorStr = '#2fe00d'
	if not SpiritsUtil:CanFeed(SpiritsModel:getWuhuVO().wuhunId, guanzhuNum) then
		colorStr = '#780000'
	end
	
	if itemId > 0 then
		TipsManager:ShowBtnTips(string.format(StrConfig["wuhun28"],colorStr,SpiritsUtil:GetFeedItemNum(SpiritsModel:getWuhuVO().wuhunId, guanzhuNum)));
	end
end

function UIzhanshou:OnBtnFeedSXDClick(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local wuhuncfg = t_wuhun[SpiritsModel.currentWuhun.wuhunId];
	if not wuhuncfg then
		return;
	end
	
	if wuhuncfg.lingshoudan <= 0 then
		FloatManager:AddNormal( StrConfig["mount18"], objSwf.btnShuXingDan);
		return;
	end
	
	--属性丹上限
	local sXDCount = 0
	for k,cfg in pairs(t_wuhun) do
		if cfg.id == SpiritsModel.currentWuhun.wuhunId then
			sXDCount = cfg.lingshoudan
			break
		end
	end
	
	--已达到上限
	if SpiritsModel:GetPillNum() >= sXDCount then
		FloatManager:AddNormal( StrConfig["mount7"], objSwf.btnShuXingDan);
		return
	end
	
	--材料不足
	if MountUtil:GetJieJieItemNum(2) <= 0 then
		FloatManager:AddNormal( StrConfig["mount6"], objSwf.btnShuXingDan);
		return
	end
	
	MountController:FeedShuXingDan(2)
end

--属性丹tip
function UIzhanshou:OnShuXingDanRollOver()
	UIMountFeedTip:OpenPanel(2);
end

function UIzhanshou:OnHunzhu1IconOver(e)
	if not SpiritsModel:getWuhuVO() or not SpiritsModel:getWuhuVO().wuhunId or SpiritsModel:getWuhuVO().wuhunId == 0 then return end
	local att, def, hp, hit, dodge, critical, defcri = SpiritsUtil:GetCurrentHunzhuProperty(SpiritsModel:getWuhuVO().wuhunId, 1)
	-- FPrint('UIzhanshou:OnHunzhu1IconOver(e)')
	TipsManager:ShowBtnTips(string.format(StrConfig["wuhun29"],self:GetAttributeUpValueStr(att, def, hp, hit, dodge, critical, defcri)));
end

function UIzhanshou:OnHunzhu2IconOver(e)
	if not SpiritsModel:getWuhuVO() or not SpiritsModel:getWuhuVO().wuhunId or SpiritsModel:getWuhuVO().wuhunId == 0 then return end
	local att, def, hp, hit, dodge, critical, defcri = SpiritsUtil:GetCurrentHunzhuProperty(SpiritsModel:getWuhuVO().wuhunId, 2)
	
	TipsManager:ShowBtnTips(string.format(StrConfig["wuhun29"],self:GetAttributeUpValueStr(att, def, hp, hit, dodge, critical, defcri)));
end

function UIzhanshou:OnHunzhu3IconOver(e)
	if not SpiritsModel:getWuhuVO() or not SpiritsModel:getWuhuVO().wuhunId or SpiritsModel:getWuhuVO().wuhunId == 0 then return end
	local att, def, hp, hit, dodge, critical, defcri = SpiritsUtil:GetCurrentHunzhuProperty(SpiritsModel:getWuhuVO().wuhunId, 3)
	TipsManager:ShowBtnTips(string.format(StrConfig["wuhun29"],self:GetAttributeUpValueStr(att, def, hp, hit, dodge, critical, defcri)));
end

function UIzhanshou:OnHunzhu4IconOver(e)
	if not SpiritsModel:getWuhuVO() or not SpiritsModel:getWuhuVO().wuhunId or SpiritsModel:getWuhuVO().wuhunId == 0 then return end
	local att, def, hp, hit, dodge, critical, defcri = SpiritsUtil:GetCurrentHunzhuProperty(SpiritsModel:getWuhuVO().wuhunId, 4)
	
	TipsManager:ShowBtnTips(string.format(StrConfig["wuhun29"],self:GetAttributeUpValueStr(att, def, hp, hit, dodge, critical, defcri)));
end

function UIzhanshou:OnHunzhu5IconOver(e)
	if not SpiritsModel:getWuhuVO() or not SpiritsModel:getWuhuVO().wuhunId or SpiritsModel:getWuhuVO().wuhunId == 0 then return end
	local att, def, hp, hit, dodge, critical, defcri = SpiritsUtil:GetCurrentHunzhuProperty(SpiritsModel:getWuhuVO().wuhunId, 5)
	
	TipsManager:ShowBtnTips(string.format(StrConfig["wuhun29"],self:GetAttributeUpValueStr(att, def, hp, hit, dodge, critical, defcri)));
end

function UIzhanshou:GetAttributeUpValueStr(att, def, hp, hit, dodge, critical, defcri)
	local tipStr = ''
	if att > 0 then
		tipStr = tipStr .. '<br/>' .. StrConfig['wuhun39'] ..'  '.. att
	end
	if def > 0 then
		tipStr = tipStr .. '<br/>' .. StrConfig['wuhun40'] ..'  '..  def
	end
	if hp > 0 then
		tipStr = tipStr .. '<br/>' .. StrConfig['wuhun41'] ..'  '..  hp
	end
	if hit > 0 then
		tipStr = tipStr .. '<br/>' .. StrConfig['wuhun44'] ..'  '..  hit
	end
	if dodge > 0 then
		tipStr = tipStr .. '<br/>' .. StrConfig['wuhun43'] ..'  '..  dodge
	end
	if critical > 0 then
		tipStr = tipStr .. '<br/>' .. StrConfig['wuhun42'] ..'  '..  critical
	end
	if defcri > 0 then
		tipStr = tipStr .. '<br/>' .. StrConfig['wuhun42'] ..'  '..  defcri
	end
	
	return tipStr
end

-- function UIzhanshou:OnNsChange(e)
	-- local objSwf = self.objSwf;
	-- if not objSwf then return; end
	-- local ns = e.target;
	-- if ns.disabled then
		-- ns._value = 0
		-- ns:updateLabel()
		-- return
	-- end
	
	-- local chechNum = self:GetMaxFeedNum(ns.value)
	-- if ns._value > chechNum then
		-- ns._value = chechNum
		-- ns:updateLabel()
	-- end
-- end

function UIzhanshou:GetMaxFeedNum(inputNum)
	local objSwf = self.objSwf;
	if not objSwf then return; end
if not SpiritsModel:getWuhuVO() or not SpiritsModel:getWuhuVO().wuhunId or SpiritsModel:getWuhuVO().wuhunId == 0 then return end
	local feedNum = SpiritsModel.currentWuhun.feedNum
	local cfg = t_wuhun[SpiritsModel:getWuhuVO().wuhunId]
	local shangxian = cfg.feed_progress -- 喂养进度上限
	
	local feedTable = cfg.feed_consume
	local feedItemId = feedTable[1]
	local feedItemNum = feedTable[2]
	local bagItemNum = BagModel:GetItemNumInBag(feedItemId) or 0 --背包中的魂珠数量
	
	local guanzhuNum = math.floor(bagItemNum/feedItemNum)
	
	
	if feedNum >= shangxian*self.hunzhuNum then
		-- if inputNum > 0 then
			-- FloatManager:AddNormal( string.format( StrConfig['wuhun35'], 0 ),objSwf.mcJinjieGuanzhu.btnGuanzhu)--当前等阶武魂还能灌注XX次
		-- end
		return 0
	else
		local maxNum = shangxian*self.hunzhuNum - feedNum
		if guanzhuNum < maxNum then 
			-- if inputNum > bagItemNum then
				-- FloatManager:AddNormal( string.format( StrConfig['wuhun36'], bagItemNum ),objSwf.mcJinjieGuanzhu.btnGuanzhu)--背包内魂珠仅能灌注XX次
			-- end	
			return guanzhuNum 
		end
		
		-- if inputNum > maxNum then
				-- FloatManager:AddNormal( string.format( StrConfig['wuhun35'], maxNum ),objSwf.mcJinjieGuanzhu.btnGuanzhu)--当前等阶武魂还能灌注XX次
			-- end	
		return maxNum
	end
end



---------------------------------消息处理------------------------------------

--监听消息
function UIzhanshou:ListNotificationInterests()
	return {
		NotifyConsts.WuhunListUpdate, 
		NotifyConsts.WuhunUpdateFeed,
		NotifyConsts.BagItemNumChange,
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.PlayerModelChange,
		NotifyConsts.WuhunLevelUpUpdate,
		NotifyConsts.WuhunLevelUpFail,
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate,
		NotifyConsts.LingShouSXDChanged,
		NotifyConsts.ChangeZhanShouModel
	} 
end

--处理消息
function UIzhanshou:HandleNotification(name, body)
	if not self.bShowState then return end
	local objSwf = self.objSwf
	if not objSwf then return; end
	UILevelUpSpirits:HandleNotification(name, body)
	if name == NotifyConsts.WuhunListUpdate then
		self:ShowWuhunInfo() 
	elseif name == NotifyConsts.WuhunUpdateFeed then
		self:UpdateFeed(body.isShowFeedEffect)
	elseif name == NotifyConsts.BagItemNumChange then
		if not SpiritsModel:getWuhuVO() or not SpiritsModel:getWuhuVO().wuhunId or SpiritsModel:getWuhuVO().wuhunId == 0 then return end
		local wuhunId = SpiritsModel:getWuhuVO().wuhunId
		if not wuhunId or wuhunId == 0 then return end
				
		self:UpdateFeedItemInfo()
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaVIPLevel then
			self:InitVip()
		end
	elseif name == NotifyConsts.WuhunLevelUpUpdate then
		if body.isSucc then 
			local w,h = UIManager:GetWinSize()
			local pos = {w + 147,h + 167};
			-- UIEffectManager:PlayEffect(ResUtil:GetJinJieSuccess(),pos);
			-- SoundManager:PlaySfx(2030)
			MainSpiritsUI:Hide()
			UIZhanshouShowView:OpenPanel();
		end
	elseif name == NotifyConsts.PlayerModelChange then
		self:ShowWuhunInfo()
	elseif name == NotifyConsts.BagAdd then
		if body.type ~= BagConsts.BagType_LingShou then return; end
		self:DoAddItem(body.pos);
	elseif name == NotifyConsts.BagRemove then
		if body.type ~= BagConsts.BagType_LingShou then return; end
		self:DoRemoveItem(body.pos);
	elseif name == NotifyConsts.BagUpdate then
		if body.type ~= BagConsts.BagType_LingShou then return; end
		self:DoUpdateItem(body.pos);
	elseif name == NotifyConsts.LingShouSXDChanged then
		self:UpdateProperty(SpiritsModel:getWuhuVO().wuhunId, t_wuhun[SpiritsModel:getWuhuVO().wuhunId])
	elseif name == NotifyConsts.ChangeZhanShouModel then
		self:ShowUseModelState();
	end
end

function UIzhanshou:UpdateFeedItemInfo()
	local wuhunId = SpiritsModel:getWuhuVO().wuhunId
	if not wuhunId or wuhunId == 0 then return end

	local objSwf = self.objSwf
	local itemId = SpiritsUtil:GetFeedItemId(wuhunId)
	local labelItemColor = "#2fe00d"
	if UIzhanshou:GetMaxFeedNum(0) == 0 then
		objSwf.mcJinjieGuanzhu.btnGuanzhu.disabled = true
		labelItemColor = "#cc0000";
	else
		objSwf.mcJinjieGuanzhu.btnGuanzhu.disabled = false
	end
	local itemCfg = t_item[itemId];
	local itemName = itemCfg and itemCfg.name or "something wuhun";
	local itemNum = SpiritsUtil:GetFeedItemNum(SpiritsModel:getWuhuVO().wuhunId, 1)
	local hasNum = BagModel:GetItemNumInBag(itemId)
	objSwf.mcJinjieGuanzhu.btnConsume.data = {itemId = itemId, count = itemNum};
	local labelItemColor = BagModel:GetItemNumInBag( itemId ) >= itemNum and "#2fe00d" or "#cc0000";
	-- FPrint(string.format( StrConfig['wuhun60'], labelItemColor, itemName, itemNum, hasNum,labelItemColor))
	objSwf.mcJinjieGuanzhu.btnConsume.htmlLabel = string.format( StrConfig['wuhun60'], labelItemColor, itemName, itemNum,labelItemColor, hasNum);
end

---------------------------------ui逻辑------------------------------------

-- 显示武魂详细信息
function UIzhanshou:ShowWuhunInfo()
	local objSwf = self.objSwf
	if not objSwf then return end
	if not SpiritsModel:getWuhuVO() or not SpiritsModel:getWuhuVO().wuhunId or SpiritsModel:getWuhuVO().wuhunId == 0 then return end
	local wuhunId = self.currentShowLevel
	if self.currentShowLevel == 0 then
		wuhunId = SpiritsModel:getWuhuVO().wuhunId
	end
	if not wuhunId or wuhunId <= 0 then
		FPrint("要显示的武魂id不正确")
		return
	end

	local cfg = t_wuhun[wuhunId]
	if not cfg then return end
	objSwf.imgnotget._visible = false;
	self.currentShowLevel = wuhunId
	-- if not self.firstOpenState then
		-- self:SetRoleRender(wuhunId)
	-- end
	
	local uiCfg = t_lingshouui[cfg.ui_id]
	if uiCfg then
		objSwf.imgName.source = ResUtil:GetWuhunIcon(uiCfg.name_icon)
		-- if uiCfg.des_icon then
			-- objSwf.desLoader.source = ResUtil:GetWuhunDesIcon(uiCfg.des_icon)
		-- end
	end
	
	-- local lvlStr = tostring(cfg.order);
	-- if cfg.order == 10 then lvlStr = "a" end;
	objSwf.lvlLoader.source = ResUtil:GetFeedUpLvlImg(cfg.order);
	
	-- objSwf.imgLevel:drawStr( lvlStr );
	-- objSwf.imgLevel.source = ResUtil:GetWuhunLevelIconBig(cfg.order)
	objSwf.btnPre.disabled = cfg.order <= 1;
	objSwf.btnNext.disabled = (cfg.order == SpiritsModel:GetMaxLevel()) 
	if cfg.order == SpiritsModel:GetMaxLevel() then
		self:HideNextLevel()
	end
	-- 附身按钮状态
	self:UpdateFushenState(wuhunId, objSwf, cfg)	
	-- 被动技能
	self:UpdateSkill(wuhunId, objSwf, cfg) 
	-- 魂珠更新
	self:HideAllHunZhunEffect(objSwf)
	self:UpdateFeed()
	
	self:Show3DWeapon(wuhunId, false);
end

-- 显示武魂详细信息
function UIzhanshou:ShowViewWuhunInfo(wuhunId)
	local objSwf = self.objSwf
	if not objSwf then return end
	
	if not SpiritsModel:getWuhuVO() or not SpiritsModel:getWuhuVO().wuhunId or SpiritsModel:getWuhuVO().wuhunId == 0 then return end
	local curwuhunId = SpiritsModel:getWuhuVO().wuhunId
	if not wuhunId or wuhunId <= 0 then
		FPrint("要显示的武魂id不正确")
		return
	end
	
	local curCfg = t_wuhun[curwuhunId]
	if not curCfg then return end

	local cfg = t_wuhun[wuhunId]	
	if not cfg then return end
	
	local uiCfg = t_lingshouui[cfg.ui_id]
	if uiCfg then
		objSwf.imgName.source = ResUtil:GetWuhunIcon(uiCfg.name_icon)
		-- if uiCfg.des_icon then
			-- objSwf.desLoader.source = ResUtil:GetWuhunDesIcon(uiCfg.des_icon)
		-- end
	end
		
	-- local lvlStr = tostring(cfg.order);
	-- if cfg.order == 10 then lvlStr = "a" end;
	-- objSwf.imgLevel:drawStr( lvlStr );
	objSwf.lvlLoader.source = ResUtil:GetFeedUpLvlImg(cfg.order);
	objSwf.btnPre.disabled = cfg.order <= 1;
	objSwf.btnNext.disabled = (cfg.order == SpiritsModel:GetMaxLevel()) or (cfg.order >=curCfg.order + 1)
	if cfg.order == SpiritsModel:GetMaxLevel() then
		self:HideUPArrow()
	end
	objSwf.imgnotget._visible = false
	if cfg.order > curCfg.order then
		objSwf.imgnotget._visible = true;
		UIzhanshou:ShowNextLevel()
	else
		for i=1,7 do
			objSwf['mcUpArrow'..i]._visible = false
		end
		objSwf.labProUpShow.htmlText = ''
		objSwf.tfVIPFightAdd.text = ''
		objSwf.incrementFight._visible = false
		-- self:SetRoleRender(wuhunId)
		self:Show3DWeapon(wuhunId, false);
	end
	self:ShowUseModelState();
	-- self:SetZhanshouAndLingshou()
end

-- 技能

function UIzhanshou:UpdateSkill(wuhunId, objSwf, cfg)
	-- 被动技能
	for i=1, self.skillTotalNum do
		self.skillicon[i].visible = true
		self.skillicon[i].btnskill.visible = false
		self.skillicon[i].imgup.visible = false
		self.skillicon[i].iconLoader.visible = false
	end
	
	local list = SpiritsUtil:GetMountSortSkill();
	for i= 1, self.skillTotalNum do
		local listvo = SpiritsUtil:GetSkillListVO(list[i].skillId,list[i].lvl)
		if listvo then
			self.skillicon[i].btnskill.visible = true
			self.skillicon[i].iconLoader.visible = true
			
			if listvo.lvl == 0 then
				self.skillicon[i].iconLoader.source = ImgUtil:GetGrayImgUrl(listvo.iconUrl)
			else
				self.skillicon[i].iconLoader.source = listvo.iconUrl
			end
			
			self.skilllist[i] = listvo
		end
	end
	
	-- 主动技能
	local skillZhudongs = SpiritsUtil:GetWuhunSkillZhudong(wuhunId)
	for i=1, self.zhudongskillTotalNum do
		self.zhudongskillicon[i].visible = true
		self.zhudongskillicon[i].btnskill.visible = false
		self.zhudongskillicon[i].imgup.visible = false
		self.zhudongskillicon[i].iconLoader.visible = false
	end
	
	for i= 1, self.zhudongskillTotalNum do
		self.zhudongskillicon[i].btnskill.visible = true
		self.zhudongskillicon[i].iconLoader.visible = true
		local listvo = skillZhudongs[i]
		self.zhudongskillicon[i].iconLoader.source = listvo.iconUrl
		self.zhudongskilllist[i] = listvo
	end	
end

function UIzhanshou:GetAttMap()
	local attMap = {}
	local wuhunId = SpiritsModel:getWuhuVO().wuhunId
	local cfg = t_wuhun[wuhunId]
	if not cfg then return nil end
	
	local att, def, hp, hit, dodge, critical, defcri = SpiritsUtil:GetPropertyTotalUP(wuhunId, SpiritsModel.currentWuhun.feedNum)
		print("G========att, def, hp, hit, dodge, critical, defcri========")
	print(att, def, hp, hit, dodge, critical, defcri)
	local addPro = 0
	addPro = (cfg.prop_attack or 0) + att
	if addPro and addPro ~= 0 then
		table.push(attMap,{proKey = 'att', proValue = addPro})--attMap.att = addPro
	end
	addPro = (cfg.prop_defend or 0) + def
	if addPro and addPro ~= 0 then
		-- attMap.def = addPro
		table.push(attMap,{proKey = 'def', proValue =  addPro})
	end
	addPro = (cfg.prop_hp or 0) + hp
	if addPro and addPro ~= 0 then
		-- attMap.hp = addPro
		table.push(attMap,{proKey = 'hp', proValue =  addPro})
	end
	addPro = (cfg.prop_critical or 0) + critical
	if addPro and addPro ~= 0 then
		-- attMap.cri = addPro
		table.push(attMap,{proKey = 'cri', proValue =  addPro})
	end
	addPro = (cfg.prop_dodge or 0) + dodge
	if addPro and addPro ~= 0 then
		-- attMap.dodge = addPro
		table.push(attMap,{proKey = 'dodge', proValue =  addPro})
	end
	addPro = (cfg.prop_hit or 0) + hit
	if addPro and addPro ~= 0 then
		-- attMap.hit = addPro
		table.push(attMap,{proKey = 'hit', proValue =  addPro})
	end
	
	addPro = (cfg.prop_defcri or 0) + defcri
	if addPro and addPro ~= 0 then
		-- attMap.defcri = addPro
		table.push(attMap,{proKey = 'defcri', proValue =  addPro})
	end
	return attMap
end

-- 属性
function UIzhanshou:UpdateProperty(wuhunId, cfg)
	local objSwf = self.objSwf
	if not objSwf then return end
	local vipUPRate = VipController:GetLingshouLvUp()/100
	local addP = 0--属性加成
	local atttype = ''
	local att, def, hp, hit, dodge, critical, defcri = SpiritsUtil:GetPropertyTotalUP(wuhunId, SpiritsModel.currentWuhun.feedNum)
	local attsxd, defsxd, hpsxd = 0,0,0
	local str = ""
	str = str .. "<textformat leading='16'><p>"
	local addPro = 0
	addPro = (cfg.prop_attack or 0) + att
	if addPro and addPro ~= 0 then
		addP = 0
		atttype = AttrParseUtil.AttMap['att'];
		if Attr_AttrPMap[atttype] then
			addP = MainPlayerModel.humanDetailInfo[Attr_AttrPMap[atttype]];
		end
		addPro = toint((addPro + attsxd)*(1+addP+vipUPRate))
		str = str .. StrConfig["wuhun7"]..':    <font color = "#fbbf78"> '.. addPro ..' </font><br/>'
	end
	addPro = (cfg.prop_defend or 0) + def
	if addPro and addPro ~= 0 then
		-- addPro = addPro + math.floor(addPro*vipUPRate) + defsxd
		addP = 0
		atttype = AttrParseUtil.AttMap['def'];
		if Attr_AttrPMap[atttype] then
			addP = MainPlayerModel.humanDetailInfo[Attr_AttrPMap[atttype]];
		end
		addPro = toint((addPro + defsxd)*(1+addP+vipUPRate))
		str = str .. StrConfig["wuhun8"]..':    <font color = "#fbbf78"> '.. addPro ..' </font><br/>'
	end
	addPro = (cfg.prop_hp or 0) + hp
	if addPro and addPro ~= 0 then
		-- addPro = addPro + math.floor(addPro*vipUPRate) + hpsxd
		addP = 0
		atttype = AttrParseUtil.AttMap['hp'];
		if Attr_AttrPMap[atttype] then
			addP = MainPlayerModel.humanDetailInfo[Attr_AttrPMap[atttype]];
		end
		addPro = toint((addPro + hpsxd)*(1+addP+vipUPRate))
		str = str .. StrConfig["wuhun9"]..':    <font color = "#fbbf78"> '.. addPro ..' </font><br/>'
	end
	addPro = (cfg.prop_critical or 0) + critical
	if addPro and addPro ~= 0 then
		-- addPro = addPro + math.floor(addPro*vipUPRate)
		addP = 0
		atttype = AttrParseUtil.AttMap['cri'];
		if Attr_AttrPMap[atttype] then
			addP = MainPlayerModel.humanDetailInfo[Attr_AttrPMap[atttype]];
		end
		addPro = toint(addPro*(1+addP+vipUPRate))
		str = str .. StrConfig["wuhun10"]..':    <font color = "#fbbf78"> '.. addPro ..' </font><br/>'
	end
	addPro = (cfg.prop_dodge or 0) + dodge
	if addPro and addPro ~= 0 then
		-- addPro = addPro + math.floor(addPro*vipUPRate)
		addP = 0
		atttype = AttrParseUtil.AttMap['dodge'];
		if Attr_AttrPMap[atttype] then
			addP = MainPlayerModel.humanDetailInfo[Attr_AttrPMap[atttype]];
		end
		addPro = toint(addPro*(1+addP+vipUPRate))
		str = str .. StrConfig["wuhun11"]..':    <font color = "#fbbf78"> '.. addPro ..' </font><br/>'
	end
	addPro = (cfg.prop_hit or 0) + hit
	if addPro and addPro ~= 0 then
		-- addPro = addPro + math.floor(addPro*vipUPRate)
		addP = 0
		atttype = AttrParseUtil.AttMap['hit'];
		if Attr_AttrPMap[atttype] then
			addP = MainPlayerModel.humanDetailInfo[Attr_AttrPMap[atttype]];
		end
		addPro = toint(addPro*(1+addP+vipUPRate))
		str = str .. StrConfig["wuhun12"]..':    <font color = "#fbbf78"> '.. addPro ..' </font><br/>'
	end
	
	addPro = (cfg.prop_defcri or 0) + defcri
	if addPro and addPro ~= 0 then
		-- addPro = addPro + math.floor(addPro*vipUPRate)
		addP = 0
		atttype = AttrParseUtil.AttMap['defcri'];
		if Attr_AttrPMap[atttype] then
			addP = MainPlayerModel.humanDetailInfo[Attr_AttrPMap[atttype]];
		end
		addPro = toint(addPro*(1+addP+vipUPRate))
		str = str .. StrConfig["wuhun50"]..':    <font color = "#fbbf78"> '.. addPro ..' </font><br/>'
	end
	str = str .. "</p></textformat>"
	
	objSwf.labProShow.htmlText = str
	local basicAttList = UIzhanshou:GetBasicAtt()
	local fight = UIzhanshou:GetFight(basicAttList)
	objSwf.numLoaderFight.num = fight or 0
end

function UIzhanshou:GetFight(attrMap)
	local attrList = {};	
	if not attrMap then return end
	for i, attVO in pairs(attrMap) do		
		--百分比加成,VIP加成		
		local addP = 0;
		if Attr_AttrPMap[attVO.type] then
			addP = MainPlayerModel.humanDetailInfo[Attr_AttrPMap[attVO.type]];
		end
		local vipUPRate = VipController:GetLingshouLvUp()/100
		attVO.val = attVO.val * (1+addP+vipUPRate);
		table.push(attrList, attVO);
	end
	return EquipUtil:GetFight( attrList );
end

function UIzhanshou:GetBasicAtt(isNext)
	local wuhunId = SpiritsModel:getWuhuVO().wuhunId
	local cfg = t_wuhun[wuhunId]
	if not cfg then return nil end
	
	if isNext then
		if not cfg.order_next or cfg.order_next == 0 then return nil end
		
		wuhunId = cfg.order_next
		cfg = t_wuhun[cfg.order_next]
	end
	if not cfg then return nil end
	-- 战斗力显示
	local list = {}
	local att, def, hp, hit, dodge, critical, defcri = 0,0,0,0,0,0,0
	if isNext then
		att, def, hp, hit, dodge, critical, defcri = SpiritsUtil:GetPropertyTotalUP(wuhunId, 0)
	else
		att, def, hp, hit, dodge, critical, defcri = SpiritsUtil:GetPropertyTotalUP(wuhunId, SpiritsModel.currentWuhun.feedNum)
	end
	local attsxd, defsxd, hpsxd = 0,0,0
	if (cfg.prop_attack + att) ~= 0 then
		local vo = {};
		vo.type = enAttrType.eaGongJi;
		vo.val = toint(cfg.prop_attack + att + attsxd)
		table.push(list,vo);
	end
	
	if (cfg.prop_defend + def) ~= 0 then
		local vo = {};
		vo.type = enAttrType.eaFangYu;
		vo.val = toint(cfg.prop_defend + def + defsxd)
		table.push(list,vo);
	end
	
	if (cfg.prop_hp + hp) ~= 0 then
		local vo = {};
		vo.type = enAttrType.eaMaxHp;
		vo.val = toint(cfg.prop_hp + hp + hpsxd)
		table.push(list,vo);
	end
	
	if (cfg.prop_hit + hit) ~= 0 then
		local vo = {};
		vo.type = enAttrType.eaMingZhong;
		vo.val = toint(cfg.prop_hit + hit)
		table.push(list,vo);
	end
	
	if (cfg.prop_dodge + dodge) ~= 0 then
		local vo = {};
		vo.type = enAttrType.eaShanBi;
		vo.val = toint(cfg.prop_dodge + dodge)
		table.push(list,vo);
	end
	
	if (cfg.prop_critical + critical) ~= 0 then
		local vo = {};
		vo.type = enAttrType.eaBaoJi;
		vo.val = toint(cfg.prop_critical + critical)
		table.push(list,vo);
	end
	
	if (cfg.prop_defcri + defcri) ~= 0 then
		local vo = {};
		vo.type = enAttrType.eaRenXing;
		vo.val = toint(cfg.prop_defcri + defcri);
		table.push(list,vo);
	end
	-- SpiritsUtil:Trace(list)
	-- return EquipUtil:GetFight(list);
	return list	 
end

function UIzhanshou:GetSXDFight()
	-- 战斗力显示
	local list = {}
	local attsxd, defsxd, hpsxd = SpiritsUtil:GetSpiritsSXDAttrMap();
	if attsxd ~= 0 then
		local vo = {};
		vo.type = enAttrType.eaGongJi;
		vo.val = attsxd
		table.push(list,vo);
	end
	
	if defsxd ~= 0 then
		local vo = {};
		vo.type = enAttrType.eaFangYu;
		vo.val = defsxd
		table.push(list,vo);
	end
	
	if hpsxd ~= 0 then
		local vo = {};
		vo.type = enAttrType.eaMaxHp;
		vo.val = hpsxd
		table.push(list,vo);
	end
	return EquipUtil:GetFight(list);
end

-- 附身按钮状态
function UIzhanshou:UpdateFushenState(wuhunId, objSwf, cfg)
	-- objSwf.btnFusheng.disabled = false
	-- if SpiritsModel:GetWuhunState(wuhunId) == 1 then
		-- objSwf.btnFusheng.label = StrConfig["wuhun23"]
	-- else 
		-- objSwf.btnFusheng.label = UIStrConfig["wuhun4"]
	-- else
		-- objSwf.btnFusheng.label = UIStrConfig["wuhun4"]
		-- objSwf.btnFusheng.disabled = true
	-- end
end

--VIP加成战斗力
function UIzhanshou:GetVIPFightAdd(isNext)
	local upRate = VipController:GetLingshouLvUp()
	if upRate <= 0 then
		upRate = VipController:GetLingshouLvUp(VipConsts:GetMaxVipLevel())
	end
	
	local basicAttList = UIzhanshou:GetBasicAtt(isNext)
	local fight = UIzhanshou:GetFight(basicAttList) or 0
	return toint( fight * upRate * 0.01, 0.5 )
end

-- 魂珠更新
local lastHunzhu = nil
local showHunzhu = 0
local currentHunzhu = 0
local shangxian = 0 -- 喂养进度上限
local feedValue = 0
local feedNum = 0
function UIzhanshou:UpdateFeed(isShowFeedEffect)
	local objSwf = self.objSwf
	if not objSwf then return end
	if not SpiritsModel:getWuhuVO() or not SpiritsModel:getWuhuVO().wuhunId or SpiritsModel:getWuhuVO().wuhunId == 0 then return end
	local wuhunId = SpiritsModel:getWuhuVO().wuhunId
	local cfg = t_wuhun[wuhunId]
	objSwf.mcJinjieGuanzhu.maxLvlMc._visible = false
	
	
	-- 属性
	self:UpdateProperty(wuhunId, cfg)
	
	-- objSwf.labWuhunJinjie.text = UIStrConfig['wuhun7']
	objSwf.mcJinjieGuanzhu._visible = true
	
	-- 当前魂珠
	shangxian = cfg.feed_progress -- 喂养进度上限
	feedValue = SpiritsModel.currentWuhun.hunzhuProgress
	feedNum = SpiritsModel.currentWuhun.feedNum
	
	-- 进阶按钮状态
	if not cfg.order_next or cfg.order_next == 0 then
		UILevelUpSpirits:OnHide()
		objSwf.mcJinjieGuanzhu._visible = true
		objSwf.mcJinjieGuanzhu.btnGuanzhu._visible = true
		objSwf.mcJinjieGuanzhu.maxLvlMc._visible = false
		objSwf.mcJinjieGuanzhu.btnConsume._visible = true
		objSwf.mcJinjieGuanzhu.txtConsume._visible = true
		if feedNum >= shangxian*self.hunzhuNum then
			objSwf.mcJinjieGuanzhu._visible = true
			objSwf.mcJinjieGuanzhu.btnGuanzhu._visible = false
			objSwf.mcJinjieGuanzhu.maxLvlMc._visible = true
			objSwf.mcJinjieGuanzhu.btnConsume._visible = false
			objSwf.mcJinjieGuanzhu.txtConsume._visible = false
		end
	else
		if feedNum >= shangxian*self.hunzhuNum then
			-- objSwf.mcJinjieGuanzhu.effect_jinjie:playEffect(0)
			-- objSwf.mcJinjieGuanzhu.mcEffectJinjie._visible = true
			objSwf.mcJinjieGuanzhu._visible = false
			UILevelUpSpirits:OnShow()
		else
			-- objSwf.mcJinjieGuanzhu.effect_jinjie:stopEffect()
			-- objSwf.mcJinjieGuanzhu.mcEffectJinjie._visible = false
			objSwf.mcJinjieGuanzhu._visible = true
			objSwf.mcJinjieGuanzhu.btnGuanzhu._visible = true
			UILevelUpSpirits:OnHide()
		end
	end
	
	currentHunzhu = SpiritsModel:GetCurrentHunzhu(wuhunId) 
	-- FPrint('当前魂珠'..currentHunzhu)
	if not currentHunzhu then
		currentHunzhu = 0
	end
	
	if lastHunzhu then
		showHunzhu = lastHunzhu
	else
		showHunzhu = currentHunzhu
	end
	lastHunzhu = currentHunzhu
	
	-- objSwf.mcJinjieGuanzhu.btnJinjie._visible = true
	
	self:UpdateFeedItemInfo()
	if UIzhanshou:GetMaxFeedNum(0) == 0 then
		objSwf.mcJinjieGuanzhu.btnGuanzhu.disabled = true
	else
		objSwf.mcJinjieGuanzhu.btnGuanzhu.disabled = false
	end
	
	
	if isShowFeedEffect then
		self:startQiuFunc(true)
	else
		self:startQiuFunc()
	end
	-- objSwf.mcJinjieGuanzhu.siPro.maximum = shangxian;
	-- objSwf.mcJinjieGuanzhu.siPro.value = feedValue;
	-- self:qiuFunc()
	-- end
	-- SpiritsUtil:Print(feedValue..'+'..shangxian..'+'..self.hunzhuNum..'+'..currentHunzhu)
	
	-- objSwf.mcJinjieGuanzhu.txtProcess.text = feedValue.. "/" ..shangxian
	-- local proStr = string.format( "%sp%s", feedValue, shangxian );
	-- objSwf.mcJinjieGuanzhu.proLoader:drawStr( proStr );
	
	
	if feedValue >= shangxian then
		-- 超过上线显示特效
		-- SpiritsUtil:Print('超过上线显示特效')
		-- objSwf.mcJinjieGuanzhu.effect_guanzhu_baofa:playEffect(1)
	end
	
	
	
	
	
end

function UIzhanshou:qiuFunc(showTween)
	local objSwf = self.objSwf
	if not objSwf then return end
	
	--升满的播特效 正在升的图标 未升的灰色图标
	if not SpiritsModel:getWuhuVO() or not SpiritsModel:getWuhuVO().wuhunId or SpiritsModel:getWuhuVO().wuhunId == 0 then return end
	local wuhunId = SpiritsModel:getWuhuVO().wuhunId
	local cfg = t_wuhun[wuhunId]
	-- for i = 0, 4 do
		-- if currentHunzhu > i then
			-- self:SetUILoaderUrl(ResUtil:GetWuhunBallEffect(cfg.order), objSwf.mcJinjieGuanzhu['ball'..(i + 1)].ballLoader, true)--已喂满
		-- elseif currentHunzhu == i then--当前魂珠
			-- if feedValue >= shangxian then
				-- self:SetUILoaderUrl(ResUtil:GetWuhunBallEffect(cfg.order), objSwf.mcJinjieGuanzhu['ball'..(i + 1)].ballLoader, true)
			-- else
				-- self:SetUILoaderUrl(ResUtil:GetWuhunBallImg(cfg.order), objSwf.mcJinjieGuanzhu['ball'..(i + 1)].ballLoader)
			-- end
		-- else 
			-- self:SetUILoaderUrl(ResUtil:GetWuhunBallImg(0), objSwf.mcJinjieGuanzhu['ball'..(i + 1)].ballLoader)--不可用
		-- end
	-- end
	for i = 0, 4 do
		if currentHunzhu > i then
			self:SetUILoaderUrl(ResUtil:GetWuhunBallImg(1), i)
		else 
			if feedValue >= shangxian then
				self:SetUILoaderUrl(ResUtil:GetWuhunBallImg(1), i)
			else
				self:SetUILoaderUrl(ResUtil:GetWuhunBallImg(0), i)--不可用
			end
		end
	end
	
	if showTween then
		objSwf.mcJinjieGuanzhu.siPro:tweenProgress( feedValue, shangxian )
	else
		objSwf.mcJinjieGuanzhu.siPro:setProgress( feedValue, shangxian )
	end
	local proStr = string.format( "%sp%s", feedValue, shangxian );
	objSwf.mcJinjieGuanzhu.proLoader:drawStr( proStr );
end

function UIzhanshou:startQiuFunc(showTween)
	local objSwf = self.objSwf
	if not objSwf then return end

	if showHunzhu < currentHunzhu then
		if showTween then
			objSwf.mcJinjieGuanzhu.siPro:tweenProgress( shangxian, shangxian )
		else
			objSwf.mcJinjieGuanzhu.siPro:setProgress( shangxian, shangxian )
		end
		local proStr = string.format( "%sp%s", shangxian, shangxian );
		objSwf.mcJinjieGuanzhu.proLoader:drawStr( proStr );
		if self.NumTimerId then 
			TimerManager:UnRegisterTimer(self.NumTimerId)
			self.NumTimerId = nil
		end
		self.NumTimerId = TimerManager:RegisterTimer(function()
			if showTween then
				SoundManager:PlaySfx(2039)
			end
			objSwf.mcJinjieGuanzhu.siPro:setProgress( 0, shangxian )
			self:qiuFunc(showTween)
		end, 500, 1)
	else
		if showTween then
			SoundManager:PlaySfx(2040)
		end
		self:qiuFunc(showTween)
	end	
end

--[[
function UIzhanshou:qiu1Func()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	local wuhunId = SpiritsModel:getWuhuVO().wuhunId
	local cfg = t_wuhun[wuhunId]
	--升满的播特效 正在升的图标 未升的灰色图标
	for i = 0, 4 do
		if showHunzhu >= i then
			self:SetUILoaderUrl(ResUtil:GetWuhunBallEffect(cfg.order), objSwf.mcJinjieGuanzhu['ball'..(i + 1)].ballLoader, true)--已喂满
		else 
			self:SetUILoaderUrl(ResUtil:GetWuhunBallImg(0), objSwf.mcJinjieGuanzhu['ball'..(i + 1)].ballLoader)--不可用
		end
	end
	showHunzhu = showHunzhu + 1
	self:startQiuFunc()
end

function UIzhanshou:startQiuFunc()
	local objSwf = self.objSwf
	if not objSwf then return end

	if showHunzhu < currentHunzhu then
		objSwf.mcJinjieGuanzhu.progressBar.complete = function()
				self:qiu1Func()
			end
		if objSwf.mcJinjieGuanzhu.progressBar._currentframe >= 100 then
			objSwf.mcJinjieGuanzhu.progressBar:gotoAndStopEffect(1)
		end
		objSwf.mcJinjieGuanzhu.progressBar:moveToProcess(100, 100)
	else
		objSwf.mcJinjieGuanzhu.progressBar.complete = function()
				self:qiuFunc()
			end
		if objSwf.mcJinjieGuanzhu.progressBar._currentframe >= 100 then
			objSwf.mcJinjieGuanzhu.progressBar:gotoAndStopEffect(1)
		end
		objSwf.mcJinjieGuanzhu.progressBar:moveToProcess(feedValue, shangxian)
	end
end--]]

function UIzhanshou:SetUILoaderUrl(ballUrl, i, isSwf)
	if not self.objSwf then return end
	local ballLoader = self.objSwf.mcJinjieGuanzhu['ball'..(i + 1)].ballLoader
	if not ballLoader then return end
	
	if ballUrl and ballUrl ~= "" then
		if isSwf then
			UILoaderManager:LoadList({ballUrl}, function()
				if ballLoader.source ~= ballUrl then
					ballLoader.source = ballUrl
				end
			end)	
		else
			if ballLoader.source ~= ballUrl then
				ballLoader.source = ballUrl
			end
		end
	else
		ballLoader:unload()
	end
end

function UIzhanshou:HideAllHunZhunEffect(objSwf)
	-- objSwf.mcJinjieGuanzhu.effect_jinjie:stopEffect()
	-- objSwf.mcJinjieGuanzhu.effect_guanzhu_xunhuan:stopEffect()
	-- objSwf.mcJinjieGuanzhu.effect_guanzhu_baofa:stopEffect()
end

function UIzhanshou:ShowUPArrow()
	local objSwf = self:GetSWF("UIzhanshou")
	if not objSwf then return end
	if not SpiritsModel:getWuhuVO() or not SpiritsModel:getWuhuVO().wuhunId or SpiritsModel:getWuhuVO().wuhunId == 0 then return end
	local cfg = t_wuhun[SpiritsModel:getWuhuVO().wuhunId]
	if not cfg or not cfg.order_next or cfg.order_next == 0 then
		return
	end
	
	local list = {}
	local att, def, hp, hit, dodge, critical, defcri =  SpiritsUtil:GetPropertyNextUP(SpiritsModel:getWuhuVO().wuhunId, SpiritsModel.currentWuhun.feedNum)
	local totalatt, totaldef, totalhp, totalhit, totaldodge, totalcritical, totaldefcri = 0,0,0,0,0,0,0
	-- SpiritsUtil:GetPropertyTotalUP(SpiritsModel:getWuhuVO().wuhunId, SpiritsModel.currentWuhun.feedNum)
	
	for i=1,7 do
		objSwf['mcUpArrow'..i]._visible = false
	end
	local upNum = 0
	local str = ""
	str = str .. "<textformat leading='16'><p>"
	local addPro = 0
	addPro = (cfg.prop_attack or 0) + totalatt
	if addPro and addPro ~= 0 then
		if att ~= 0 then
			upNum = upNum + 1
			local vo = {};
			vo.type = enAttrType.eaGongJi;
			vo.val = att;
			table.push(list,vo);
			str = str .. '<font color = "#2fe00d"> +'..att ..' </font><br/>'
			objSwf['mcUpArrow1']._visible = true
		else
			str = str .. '<br/>'
		end
	end
	addPro = (cfg.prop_defend or 0) + totaldef
	if addPro and addPro ~= 0 then
		if def ~= 0 then
			upNum = upNum + 1
			str = str .. '</font><font color = "#2fe00d"> +'..def ..' </font><br/>'
			local vo = {};
			vo.type = enAttrType.eaFangYu;
			vo.val = def;
			table.push(list,vo);
			objSwf['mcUpArrow2']._visible = true
		else
			str = str .. '<br/>'
		end
	end
	addPro = (cfg.prop_hp or 0) + totalhp
	if addPro and addPro ~= 0 then
		if hp ~= 0 then
			upNum = upNum + 1
			str = str .. '</font><font color = "#2fe00d"> +'..hp ..' </font><br/>'
			local vo = {};
			vo.type = enAttrType.eaHp;
			vo.val = hp;
			table.push(list,vo);
			objSwf['mcUpArrow3']._visible = true
		else
			str = str .. '<br/>'
		end
	end
	addPro = (cfg.prop_critical or 0) + totalcritical
	if addPro and addPro ~= 0 then
		if critical ~= 0 then
			upNum = upNum + 1
			str = str .. '</font><font color = "#2fe00d"> +'..critical ..' </font><br/>'
			local vo = {};
			vo.type = enAttrType.eaBaoJi;
			vo.val = critical;
			table.push(list,vo);
			objSwf['mcUpArrow4']._visible = true
		else
			str = str .. '<br/>'
		end
	end
	addPro = (cfg.prop_dodge or 0) + totaldodge
	if addPro and addPro ~= 0 then
		if dodge ~= 0 then
			upNum = upNum + 1
			str = str .. '</font><font color = "#2fe00d"> +'..dodge ..' </font><br/>'
			local vo = {};
			vo.type = enAttrType.eaShanBi;
			vo.val = dodge;
			table.push(list,vo);
			objSwf['mcUpArrow5']._visible = true
		else
			str = str .. '<br/>'
		end
	end
	addPro = (cfg.prop_hit or 0) + totalhit
	if addPro and addPro ~= 0 then
		if hit ~= 0 then
			upNum = upNum + 1
			str = str .. '</font><font color = "#2fe00d"> +'..hit ..' </font><br/>'
			local vo = {};
			vo.type = enAttrType.eaMingZhong;
			vo.val = hit;
			table.push(list,vo);
			objSwf['mcUpArrow6']._visible = true
		else
			str = str .. '<br/>'
		end
	end
	
	addPro = (cfg.prop_defcri or 0) + totaldefcri
	if addPro and addPro ~= 0 then
		if defcri ~= 0 then
			upNum = upNum + 1
			str = str .. '</font><font color = "#2fe00d"> +'..defcri ..' </font><br/>'
			local vo = {};
			vo.type = enAttrType.eaRenXing;
			vo.val = defcri;
			table.push(list,vo);
			objSwf['mcUpArrow7']._visible = true
		else
			str = str .. '<br/>'
		end
	end
	str = str .. "</p></textformat>"
	objSwf.labProUpShow.htmlText = str
	
	-- if upNum > 0 then
		-- for i=1,upNum do
			-- if i <= 7 then
				-- objSwf['mcUpArrow'..i]._visible = true
			-- end
		-- end
	-- end
	
	if EquipUtil:GetFight(list) ~= 0 then
		objSwf.incrementFight._visible = true
		-- 战斗力显示
		local basicAttList = UIzhanshou:GetBasicAtt()
		local curFight = UIzhanshou:GetFight(basicAttList)
		
		local basicAttNextList = UIzhanshou:GetBasicAtt(true)
		local nextFight = UIzhanshou:GetFight(basicAttNextList)
		FPrint('当前战斗力'..curFight)
		FPrint('下一阶战斗力'..nextFight)
		
		objSwf.incrementFight.label = ''..nextFight - curFight
		-- objSwf.txtUpZhanDouLi.text = ''..EquipUtil:GetFight(list)
	else
		objSwf.incrementFight._visible = false
	end
	
	local vipFight = self:GetVIPFightAdd();
	local nextVIPFight = self:GetVIPFightAdd(true);
	FPrint(nextVIPFight..':'..vipFight)
	local addFight = nextVIPFight - vipFight
	if addFight < 0 then addFight = 0 end
	objSwf.tfVIPFightAdd.htmlText = string.format(StrConfig['vip100'],addFight);
end

-- 下阶预览
function UIzhanshou:ShowNextLevel()
	self:ShowUPArrow()
	local objSwf = self:GetSWF("UIzhanshou")
	if not objSwf then return end
	if not SpiritsModel:getWuhuVO() or not SpiritsModel:getWuhuVO().wuhunId or SpiritsModel:getWuhuVO().wuhunId == 0 then return end
	local cfg = t_wuhun[SpiritsModel:getWuhuVO().wuhunId]
	if not cfg or not cfg.order_next or cfg.order_next == 0 then
		return
	end
	
	-- objSwf.tflevelup._visible = true
	
	local nextCfg = t_wuhun[cfg.order_next]
	if nextCfg then
		-- objSwf.imgLevel.source = ResUtil:GetWuhunLevelIconBig(nextCfg.order)
		-- 属性
		local uiCfg = t_lingshouui[nextCfg.ui_id]
		if uiCfg then
			objSwf.imgName.source = ResUtil:GetWuhunIcon(uiCfg.name_icon)
			-- if uiCfg.des_icon then
				-- objSwf.desLoader.source = ResUtil:GetWuhunDesIcon(uiCfg.des_icon)
			-- end
		end
		objSwf.lvlLoader.source = ResUtil:GetFeedUpLvlImg(nextCfg.order);
		
		
		-- local lvlStr = tostring(nextCfg.order);
		-- if nextCfg.order == 10 then lvlStr = "a" end;
		-- objSwf.imgLevel:drawStr( lvlStr );
		-- self:SetRoleRender(nextCfg.id)
		self:Show3DWeapon(nextCfg.id)
		
		objSwf.imgnotget._visible = true;
		objSwf.btnPre.disabled = nextCfg.order <= 1;
		objSwf.btnNext.disabled = true
	end
end

function UIzhanshou:HideUPArrow()
	local objSwf = self:GetSWF("UIzhanshou") 
	if not objSwf then return end
	if not SpiritsModel:getWuhuVO() or not SpiritsModel:getWuhuVO().wuhunId or SpiritsModel:getWuhuVO().wuhunId == 0 then return end
	local wuhunId = SpiritsModel:getWuhuVO().wuhunId
	local cfg = t_wuhun[wuhunId]
	
	if not cfg or not cfg.order_next or cfg.order_next == 0 then
		return
	end
	
	for i=1,7 do
		objSwf['mcUpArrow'..i]._visible = false
	end
	
	objSwf.incrementFight._visible = false
	-- objSwf.tflevelup._visible = false
	objSwf.labProUpShow.htmlText = ''
	objSwf.tfVIPFightAdd.text = ''
end

-- 隐藏下阶预览
function UIzhanshou:HideNextLevel()
	local objSwf = self:GetSWF("UIzhanshou") 
	if not objSwf then return end
	if not SpiritsModel:getWuhuVO() or not SpiritsModel:getWuhuVO().wuhunId or SpiritsModel:getWuhuVO().wuhunId == 0 then return end
	local wuhunId = SpiritsModel:getWuhuVO().wuhunId
	local cfg = t_wuhun[wuhunId]
	
	if not cfg or not cfg.order_next or cfg.order_next == 0 then
		self:HideUPArrow()
		return
	end
	
	if SpiritsModel.isAutoLevelUp == false then
		self:HideUPArrow()
	end
	if cfg then
		-- 属性
		local uiCfg = t_lingshouui[cfg.ui_id]
		if uiCfg then
			objSwf.imgName.source = ResUtil:GetWuhunIcon(uiCfg.name_icon)
			-- if uiCfg.des_icon then
				-- objSwf.desLoader.source = ResUtil:GetWuhunDesIcon(uiCfg.des_icon)
			-- end
		end
		objSwf.lvlLoader.source = ResUtil:GetFeedUpLvlImg(cfg.order);
		
		-- local lvlStr = tostring(cfg.order);
		-- if cfg.order == 10 then lvlStr = "a" end;
		-- objSwf.imgLevel:drawStr( lvlStr );
		objSwf.imgnotget._visible = false;
		objSwf.btnPre.disabled = cfg.order <= 1;
		objSwf.btnNext.disabled = (cfg.order == SpiritsModel:GetMaxLevel()) 
		self.currentShowLevel = SpiritsModel:getWuhuVO().wuhunId
		-- self:SetRoleRender(SpiritsModel:getWuhuVO().wuhunId)
		self:Show3DWeapon(SpiritsModel:getWuhuVO().wuhunId)
	end
end

function UIzhanshou:SetRoleRender(wuhunId)
	-- if self.roleVO and self.roleVO.wuhunId == wuhunId and not firstOpenState then
		-- return
	-- end

	--if not self.roleVO then
		self.roleVO = {}
		local info = MainPlayerModel.sMeShowInfo;
		self.roleVO.prof = MainPlayerModel.humanDetailInfo.eaProf
		self.roleVO.arms = info.dwArms
		self.roleVO.dress = info.dwDress
		self.roleVO.fashionsHead = info.dwFashionsHead
		self.roleVO.fashionsArms = info.dwFashionsArms
		self.roleVO.fashionsDress = info.dwFashionsDress
		self.roleVO.wing = info.dwWing
		self.roleVO.suitflag = info.suitflag
		self.roleVO.sex = info.dwSex
	--end
	self.roleVO.wuhunId = wuhunId
	if self.roleRender then
		self.roleRender:DrawRole(self.roleVO, true)
	end
end

--获取Html文本
--@param text 显示的内容
--@param color 字体颜色
--@param size 字号
--@param withBr 是否换行,默认true
--@param bold 	是否加粗,默认false
function UIzhanshou:GetHtmlText(text,color,size,withBr,bold)
	if not color then color = TipsConsts.Default_Color; end
	if not size then size = TipsConsts.Default_Size; end
	if withBr==nil then withBr = true; end
	if bold==nil then bold = false; end
	local str = "<font color='" .. color .."' size='" .. size .. "'>";
	if bold then
		str = str .. "<b>" .. text .. "</b>";
	else
		str = str .. text;
	end
	str = str .. "</font>";
	if withBr then
		str = str .. "<br/>";
	end
	return str;
end

function UIzhanshou:OnBtnPreClick()
	self.isShowAni = true
	self.currentShowLevel = self.currentShowLevel - 1
	self:ShowViewWuhunInfo( self.currentShowLevel );
end

function UIzhanshou:OnBtnNextClick()
	self.isShowAni = true
	self.currentShowLevel = self.currentShowLevel + 1
	self:ShowViewWuhunInfo( self.currentShowLevel );
end

function UIzhanshou:OnChkBoxUseModelClick()
	local objSwf = self.objSwf
	if not objSwf then return end
	local currentShowLevel = self.currentShowLevel
	if not currentShowLevel then return end
	local useThisModel = objSwf.chkBoxUseModel.selected
	local currentLevel = SpiritsModel.selectedWuhunId
	if currentLevel == currentShowLevel and useThisModel == false then
		-- objSwf.chkBoxUseModel.selected = true
		return
	end
	local modelLevel = useThisModel and currentShowLevel or currentLevel
	
	-- --当前使用的是灵兽
	if not LinshouModel:getWuhuVO(SpiritsModel.selectedWuhunId) then
		SpiritsController:AhjunctionWuhun(modelLevel, SpiritsModel:GetWuhunState());
	else
		SpiritsController:AhjunctionWuhun(modelLevel, LinshouModel:getWuhuVO(SpiritsModel.selectedWuhunId).wuhunState);
	end
end

function UIzhanshou:ShowUseModelState()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.chkBoxUseModel.selected = SpiritsModel.selectedWuhunId == self.currentShowLevel
	objSwf.chkBoxUseModel.disabled = self.currentShowLevel > SpiritsModel.currentWuhun.wuhunId
end

-- 显示灵兽模型
local viewPort;

function UIzhanshou:Show3DWeapon(wuhunId)
	-- FPrint('显示灵兽模型'..last3dId..':'..wuhunId)
	if last3dId == wuhunId then return end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local wuhunCfg = t_wuhun[wuhunId]
	if not wuhunCfg then
		return
	end
	
	local cfg = t_lingshouui[wuhunCfg.ui_id];
	if not cfg then
		Error("Cannot find config of t_lingshouui. level:"..level);
		return;
	end
	
	if not self.objUIDraw then
		if not viewPort then viewPort = _Vector2.new(1333, 732); end
		self.objUIDraw = UISceneDraw:new( "UIzhanshouScene", objSwf.loader, viewPort );
	end
	self.objUIDraw:SetUILoader(objSwf.loader);
	
	if self.isShowAni then
		self.objUIDraw:SetScene( cfg.ui_sen, function()
			self:SetZhanshouAndLingshou(wuhunId)
			
			if not objSwf.btnRadioLinshou.selected then return end
			
			local modelCfg = t_lingshoumodel[cfg.model]
			if not modelCfg then return end
			
			local aniName = modelCfg.san_idle;
			if not aniName or aniName == "" then return end
			if not cfg.ui_node then return end
			local nodeName = split(cfg.ui_node, "#")
			if not nodeName or #nodeName < 1 then return end
			
			for k,v in pairs(nodeName) do
				self.objUIDraw:NodeAnimation( v, aniName );			
			end
			self.isShowAni = false
			if wuhunCfg.sound then
				SoundManager:PlaySfx(wuhunCfg.sound)
			end
		end );
	else
		self.objUIDraw:SetScene( cfg.ui_sen, function()
			self:SetZhanshouAndLingshou(wuhunId)
		end );
	end
	last3dId = wuhunId
	self.objUIDraw:SetDraw( true );
end


--------------------------------
function UIzhanshou:IsShowSound()
	return true;
end

function UIzhanshou:IsShowLoading()
	return true;
end
----------------------------以下是装备处理-------------------
--显示装备
function UIzhanshou:ShowEquip()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.list = BagUtil:GetBagItemList(BagConsts.BagType_LingShou,BagConsts.ShowType_All);
    objSwf.list.dataProvider:cleanUp();
	for i,slotVO in ipairs(self.list) do
		objSwf.list.dataProvider:push(slotVO:GetUIData());
	end
	objSwf.list:invalidateData();
end

--添加Item
function UIzhanshou:DoAddItem(pos)
	local bagVO = BagModel:GetBag(BagConsts.BagType_LingShou);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(pos);
	if not item then return; end;
	local objSwf = self.objSwf
	if not objSwf then return; end
	local bagSlotVO = self.list[pos+1];
	bagSlotVO.hasItem = true;
	bagSlotVO.id = item:GetId();
	bagSlotVO.tid = item:GetTid();
	bagSlotVO.count = item:GetCount();
	bagSlotVO.bindState = item:GetBindState();
	objSwf.list.dataProvider[pos] = bagSlotVO:GetUIData();
	local uiSlot = objSwf.list:getRendererAt(pos);
	if uiSlot then
		uiSlot:setData(bagSlotVO:GetUIData());
	end
end

--移除Item
function UIzhanshou:DoRemoveItem(pos)
	local objSwf = self.objSwf;
	if not objSwf then return; end;
	local bagSlotVO = self.list[pos+1];
	bagSlotVO.hasItem = false;
	objSwf.list.dataProvider[pos] = bagSlotVO:GetUIData();
	local uiSlot = objSwf.list:getRendererAt(pos);
	if uiSlot then
		uiSlot:setData(bagSlotVO:GetUIData());
	end
end

--更新Item
function UIzhanshou:DoUpdateItem(pos)
	local bagVO = BagModel:GetBag(BagConsts.BagType_LingShou);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(pos);
	if not item then return; end;
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local bagSlotVO = self.list[pos+1];
	bagSlotVO.id = item:GetId();
	bagSlotVO.tid = item:GetTid();
	bagSlotVO.count = item:GetCount();
	bagSlotVO.bindState = item:GetBindState();
	objSwf.list.dataProvider[pos] = bagSlotVO:GetUIData();
	local uiSlot = objSwf.list:getRendererAt(pos);
	if uiSlot then
		uiSlot:setData(bagSlotVO:GetUIData());
	end
end

function UIzhanshou:OnItemRollOver(item)
	local data = item:GetData();
	if not data.hasItem then
		TipsManager:ShowBtnTips(BagConsts:GetLingShouEquipNameByPos(data.pos));
		return;
	end
	TipsManager:ShowBagTips(BagConsts.BagType_LingShou,data.pos);
end

function UIzhanshou:OnItemRollOut(item)
	TipsManager:Hide();
end

function UIzhanshou:OnItemDragBegin(item)
	TipsManager:Hide();
end

function UIzhanshou:OnItemDragIn(fromData,toData)
	--来自背包的
	if fromData.bagType == BagConsts.BagType_Bag then
		--判断是否是装备
		if BagUtil:GetItemShowType(fromData.tid) ~= BagConsts.ShowType_Equip then
			return;
		end
		--判断装备位是否相同
		if BagUtil:GetEquipType(fromData.tid) ~= BagUtil:GetEquipAtBagPos(BagConsts.BagType_LingShou,toData.pos) then
			return;
		end
		--判断是否可穿戴
		if BagUtil:GetEquipCanUse(fromData.tid) < 0 then
			return;
		end
		BagController:SwapItem(fromData.bagType,fromData.pos,toData.bagType,toData.pos);
		return;
	end
end

--左键菜单
function UIzhanshou:OnItemClick(item)
	TipsManager:Hide();
	if UIBagQuickEquitView:IsShow() then
		UIBagQuickEquitView:Hide();
		return;
	end
	
	local itemData = item:GetData();
	if not itemData.opened then
		return;
	end
	if not itemData.hasItem then
		UIBagQuickEquitView:Open(item.mc, BagConsts.BagType_LingShou, itemData.pos+30, itemData.pos+30);
		return;
	end
	if _sys:isKeyDown(_System.KeyCtrl) then
		ChatQuickSend:SendItem(BagConsts.BagType_LingShou,itemData.pos);
		return;
	end
	
	UIBagQuickEquitView:Open(item.mc, BagConsts.BagType_LingShou, itemData.pos+30, itemData.pos);
end

--双击卸载
function UIzhanshou:OnItemDoubleClick(item)
	TipsManager:Hide();
	local data = item:GetData();
	if not data.hasItem  then
		return;
	end
	BagController:UnEquipItem(BagConsts.BagType_LingShou,data.pos);
end

--右键卸载
function UIzhanshou:OnItemRClick(item)
	TipsManager:Hide();
	local data = item:GetData();
	if not data.hasItem then
		return;
	end
	BagController:UnEquipItem(BagConsts.BagType_LingShou,data.pos);
end
---------------------------以上是装备处理--------------------------------------


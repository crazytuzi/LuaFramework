--[[坐骑界面主面板
zhangshuhui
2014年11月05日17:20:20
]]

_G.UIMountBasic = BaseSlotPanel:new("UIMountBasic");


UIMountBasic.slotTotalNum = 4;--UI上格子总数
UIMountBasic.list = {};--当前格子
UIMountBasic.numFightx = 0;--战斗力x坐标

UIMountBasic.objUIDraw = nil;--3d渲染器
UIMountBasic.mountTurnDir = 0;--坐骑旋转方向 0,不旋转;1左;-1右
UIMountBasic.meshDir = 0; --模型的当前方向
UIMountBasic.skillTotalNum = 6;--UI上技能总数
UIMountBasic.curModel = nil;

--当前显示的等阶
UIMountBasic.currentShowLevel = nil
--上次显示的等阶 鼠标悬浮进阶按钮前显示的坐骑
UIMountBasic.preShowLevel = nil;

UIMountBasic.oldstar = 0;--上次进阶时的坐骑星级

--技能列表
UIMountBasic.skillicon = {}
UIMountBasic.skilllist = {}

function UIMountBasic:Create()
	self:AddSWF("mountBasicPanel.swf", true, nil)

	self:AddChild(UIMountSkill, MountConsts.MOUNTSKILL);
end
local isShowMountDes = false
local mountmouseMoveX = 0
function UIMountBasic:OnLoaded(objSwf,name)
	self:GetChild(MountConsts.MOUNTSKILL):SetContainer(objSwf.childPanel1);
	objSwf.btnRoleLeft.stateChange = function(e) 
		if self.objUIDraw then
			self.objUIDraw:OnBtnRoleLeftStateChange(e.state);
		end
	end;
	objSwf.btnRoleLeft.visible = false
	objSwf.btnRoleRight.stateChange = function(e)
		if self.objUIDraw then
			self.objUIDraw:OnBtnRoleRightStateChange(e.state);
		end
	end;
	objSwf.btnRoleRight.visible = false
	objSwf.mountupPanel.siPro.trackWidthGap = 26;
	objSwf.btnShuXingDan.click = function() self:OnBtnUpClick() end
	
	--初始化格子
	for i=1,self.slotTotalNum do
		self:AddSlotItem(BaseItemSlot:new(objSwf["item"..i]),i);
	end
	
	--属性丹tip
	objSwf.btnShuXingDan.rollOver = function() self:OnShuXingDanRollOver(); end
	objSwf.btnShuXingDan.rollOut  = function()  UIMountFeedTip:Hide();  end
    --资质丹
	objSwf.btnZiZhiDan.click = function() self:OnBtnZZDClick() end
	objSwf.btnZiZhiDan.rollOver = function() self:OnZZDRollOver(); end
	objSwf.btnZiZhiDan.rollOut  = function()  UIMountFeedTip:Hide();  end


	
	objSwf.btnVipBack.rollOver = function() self:OnBtnVipBackRollOver(); end
	objSwf.btnVipBack.rollOut  = function()  self:OnBtnVipBackrollOut();  end
	
	objSwf.btnPre.click            = function() self:OnBtnPreClick(); end
	objSwf.btnNext.click           = function() self:OnBtnNextClick(); end
	  		
    	--技能
	for i=1,self.skillTotalNum do
		self.skillicon[i] = objSwf["skill"..i]
		self.skillicon[i].btnskill.rollOver = function(e) self:OnMountSkillTipRollOver(i); end
		self.skillicon[i].btnskill.rollOut  = function() self:OnMountSkillTipRollOut();  end
	end
	for i=1,self.skillTotalNum do
		self.skillicon[i].btnskill.click = function(e) self:OnBtnSkillClick(i) end
	end


	--战斗力值居中
	self.numFightx = objSwf.numFight._x
	objSwf.numFight.loadComplete = function()
									objSwf.numFight._x = self.numFightx - objSwf.numFight.width / 2
								end
								
								
	objSwf.mountupPanel.btnJinJie.click = function() self:OnBtnJinJieClick() end
	objSwf.mountupPanel.btnZiDongJinJie.click = function() self:OnBtnZiDongJinJieClick() end
	objSwf.mountupPanel.checkZiDong.click = function() self:OnCBoxClick()  end
	objSwf.mountupPanel.btnCancel.click = function() self:OnBtnCancel()  end
	
	--星tip
	objSwf.mountupPanel.btntip.rollOver = function() self:OnbtntipRollOver(); end
	objSwf.mountupPanel.btntip.rollOut  = function() self:OnbtntipRollOut();  end
	
	objSwf.mountupPanel.btnLingLiNum1.rollOver = function() self:OnbtnJinJieDanRollOver(); end
	objSwf.mountupPanel.btnLingLiNum1.rollOut = function() TipsManager:Hide(); end
	
	objSwf.mountupPanel.btnJinJie.rollOver = function() self:ShowJinJieGoldTip(); end
	objSwf.mountupPanel.btnJinJie.rollOut = function() self:ShowJinJieGoldTipOut(); end
	objSwf.mountupPanel.btnZiDongJinJie.rollOver = function() self:ShowJinJieGoldTip(); end
	objSwf.mountupPanel.btnZiDongJinJie.rollOut = function() self:ShowJinJieGoldTipOut(); end
	
	--objSwf.mountupPanel.proleftLoader.loadComplete = function() self:OnNumLeftComplete(); end
	--objSwf.mountupPanel.prorightLoader.loadComplete = function() self:OnNumRightComplete(); end

	for i=1,MountConsts.MountStarMax-1 do
		objSwf.mountupPanel["feixingeffect"..i].complete = function()
									self:ShowChengZhangXing(i);
								end
	end
	objSwf.mountupPanel.btnGotWay.htmlLabel = StrConfig["common002"];
	objSwf.mountupPanel.btnGotWay.click = function() self:OnQuickBuy() end
	objSwf.mountupPanel.siPro.tweenComplete = function() self:OnSiProTweenComplete() end -- 进度条缓动完成
	
	
	objSwf.iconDes._alpha = 0
	objSwf.btnDesShow.rollOver = function()
		if isShowMountDes then return end
		local mountId = self.currentShowLevel
		if not mountId or mountId <= 0 then
			FPrint("要显示的坐骑id不正确")
			return
		end
		local cfg = t_horse[mountId]
		if not cfg then
			cfg = t_horseskn[mountId];
			if not cfg then
				return
			end
		end
		if cfg and cfg.des_icon then
			local playerinfo = MainPlayerModel.humanDetailInfo;
			--local iconname = MountUtil:GetListString(cfg.des_icon, playerinfo.eaProf);
		--	objSwf.iconDes.desLoader.source = ResUtil:GetMountIconName(iconname);
		end
		--Tween:To(objSwf.iconDes,5,{_alpha=100});
		isShowMountDes = true
	end
	
	objSwf.btnDesShow.rollOut = function()
		self.isMouseDrag = false
		if self.objUIDraw then
			self.objUIDraw:OnBtnRoleRightStateChange("out"); 				
		end
		if not isShowMountDes then return end
		
		--Tween:To(objSwf.iconDes,1,{_alpha=0});
		isShowMountDes = false
	end
	
	objSwf.btnDesShow.press = function() 		
		local monsePosX = _sys:getRelativeMouse().x;--获取鼠标位置		
		mountmouseMoveX = monsePosX;   		       
		self.isMouseDrag = true
	end

	objSwf.btnDesShow.release = function()
		self.isMouseDrag = false
		if self.objUIDraw then
			self.objUIDraw:OnBtnRoleRightStateChange("release"); 				
		end
	end
	
								
	--模型防止阻挡鼠标
	objSwf.modelload.hitTestDisable = true;
end

function UIMountBasic:OnDelete()
	self:RemoveAllSlotItem();
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end
function UIMountBasic:OnQuickBuy()
	local itemId, itemNum, isEnough = MountUtil:GetConsumeItem(MountModel.ridedMount.mountLevel);
    UIQuickBuyConfirm:Open(self,itemId);
end
function UIMountBasic:Update()
	local objSwf = self.objSwf;
	if not objSwf then return end
	if not self.bShowState then return end
	
	if self.isMouseDrag then
		local monsePosX = _sys:getRelativeMouse().x;--获取鼠标位置		
		if mountmouseMoveX<monsePosX then
			local speed = monsePosX - mountmouseMoveX
			if self.objUIDraw then
				self.objUIDraw:OnBtnRoleRightStateChange("down",speed); 
			end
		elseif mountmouseMoveX>monsePosX then 
			local speed = mountmouseMoveX - monsePosX
			if self.objUIDraw then
				self.objUIDraw:OnBtnRoleLeftStateChange("down",speed); 
			end
		end
		mountmouseMoveX = monsePosX;
	end
	
	local cfg = {};
	if self.currentShowLevel < MountConsts.SpecailDownid then
		cfg = t_horse[self.currentShowLevel];
		
		if not cfg then
			Error("Cannot find config of horse. level:"..self.currentShowLevel);
			return;
		end
	else
		cfg = t_horseskn[self.currentShowLevel];
		
		if not cfg then
			Error("Cannot find config of t_horseskn. level:"..self.currentShowLevel);
			return;
		end
	end
	
	
	local ui_node =  MountUtil:GetMountSen(cfg.ui_node,MainPlayerModel.humanDetailInfo.eaProf);
	
	if self.objUIDraw then
		self.objUIDraw:Update(ui_node);
	end
end

function UIMountBasic:GetJinJieBtn()
	if not self:IsShow() then return; end
	return self.objSwf.mountupPanel.btnJinJie;
end

function UIMountBasic:OnShow(name)
	--初始化数据
	self:InitData();
	--初始化UI
	self:InitUI();
	--坐骑装备
	self:ShowEquip();
	--坐骑信息
	self:ShowMountInfo();
	--属性丹
	self:ShowShuXingDanInfo();
     --技能
	self:ShowSkillList();


	--升阶信息
	self:ShowChengZhangInfo();
	--自动进阶按钮
	self:ShowbtnZiDong(true);
	self:InitVip()

	self:ShowvipEffect();
    --属性丹 资质丹 特效
	--self:ShowAttrRed()

	self:showVipBackInfo()

	
end

function UIMountBasic:InitVip()
	local objSwf = self.objSwf
	if not objSwf then return end	
	
	objSwf.btnVipBack.click = function() UIVipBack:Open(VipConsts.TYPE_MOUNT) end
	objSwf.btnVipLvUp.click = function() UIVip:Show() end	
	objSwf.btnVipLvUp.rollOver = function(e) 
		local attMap = self:GetAttMap()
		VipController:ShowAttrTips( attMap, UIVipAttrTips.zq ,VipConsts.TYPE_DIAMOND)
	end
	objSwf.btnVipLvUp.rollOut = function(e) VipController:HideAttrTips() end

end

function UIMountBasic:InitData()
	SoundManager:StopSfx();
	
	self.oldstar = MountModel.ridedMount.mountStar;
	

end
--请求vip信息
function UIMountBasic:showVipBackInfo()
	VipController:ReqVipBackInfo(VipConsts.TYPE_MOUNT);
end
function UIMountBasic:OnHide()
	
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false)
		self.objUIDraw:SetUILoader(nil);
		UIDrawManager:RemoveUIDraw(self.objUIDraw);
		self.objUIDraw = nil
	end
	self.mountTurnDir = 0;
	
	MountController:SucCancelUpZiDong();
	UIVipBack:Hide()
end

function UIMountBasic:GetWidth()
	return 1489;
end

function UIMountBasic:GetHeight()
	return 760;
end

---------------------------------消息处理------------------------------------
function UIMountBasic:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self:GetSWF("UIMountBasic");
	if not objSwf then return; end
	if name == NotifyConsts.MountUsePillChanged then
		self:UpdateShuXingDanInfo();
		self:UpdateSXDInfo();
		self:PlayPillSuccessAninal();
		--self:ShowAttrRed();
	elseif name == NotifyConsts.MountLvUpSucChanged then
		self:ShowMountUpSucEffect();
		--self:ShowAttrRed()
	elseif name == NotifyConsts.MountXingUpSucChanged then
		self:UpdateMountAttrInfo();
		self:PlayProcessEffect();
		self:UpdateChengZhangNum();
		self:ShowUpShuZhi(body.addProgress,body.uptype);
		self:ShowUpEffect(body.mountStar);
		self:PlayStarSuccessAninal()
		SoundManager:PlaySfx(2039);
	elseif name == NotifyConsts.BagAdd then
		if body.type ~= BagConsts.BagType_Horse then return; end
		self:DoAddItem(body.pos);
		self:UpdateMountInfo()
	elseif name == NotifyConsts.BagRemove then
		if body.type ~= BagConsts.BagType_Horse then return; end
		self:DoRemoveItem(body.pos);
		self:UpdateMountInfo()
	elseif name == NotifyConsts.BagUpdate then
		if body.type ~= BagConsts.BagType_Horse then return; end
		self:DoUpdateItem(body.pos);
		self:UpdateMountInfo()
	elseif name == NotifyConsts.BagItemNumChange then
		self:UpdateShuXingDanInfo()
		self:UpdateSkillList()
		self:UpdateToolInfo()
		--self:ShowAttrRed()
	elseif name == NotifyConsts.SkillLearn then
		self:UpdateSkillLearn(body)
	elseif name == NotifyConsts.SkillLvlUp then
		self:UpdateSkillLvUp(body)
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaLevel then
			self:UpdateLevelInfo();
		elseif body.type==enAttrType.eaZhenQi then
			self:UpdateToolInfo();
		elseif body.type == enAttrType.eaVIPLevel then
			self:InitVip()
		end
	elseif name == NotifyConsts.MountRidedChangedState then
		self:UpdateBtnQCState();
	elseif name == NotifyConsts.MountRidedChanged then
		self:ShowMountInfo();
	elseif name == NotifyConsts.MountLvUpInfoChanged then
		self:PlayProcessEffect();
		self:UpdateChengZhangNum();
		self:ShowUpShuZhi(body.addProgress,body.uptype);
		SoundManager:PlaySfx(2040);
	elseif name == NotifyConsts.MountLvUpSucChanged then
		self:ShowMountUpSucEffect();
	elseif name == NotifyConsts.MountSucCancelZiDong then
		self:ShowbtnZiDong(true)
	elseif name == NotifyConsts.MountFailCancelZiDong then
		self:LackToolInfo(body)
	elseif name == NotifyConsts.VipJihuoEffect then 
		self:ShowvipEffect()
	elseif name ==	NotifyConsts.UseZZDChanged then 
		--self:ShowAttrRed()
	elseif name ==	NotifyConsts.VipBackInfo then 
        self:ShowvipEffect();
    elseif name ==  NotifyConsts.VipBackInfoChange then 
    	self:showVipBackInfo()
    	self:ShowvipEffect();
	end
end

function UIMountBasic:ListNotificationInterests()
	return {NotifyConsts.MountUsePillChanged,
			NotifyConsts.MountLvUpSucChanged,
			NotifyConsts.MountXingUpSucChanged,
			NotifyConsts.BagAdd,
			NotifyConsts.BagRemove,
			NotifyConsts.BagUpdate,
			NotifyConsts.BagItemNumChange,
			NotifyConsts.PlayerAttrChange,
			NotifyConsts.MountRidedChangedState,
			NotifyConsts.MountRidedChanged,
			NotifyConsts.MountLvUpInfoChanged,
			NotifyConsts.MountSucCancelZiDong,
			NotifyConsts.SkillLearn,
	        NotifyConsts.SkillLvlUp,
	        NotifyConsts.VipJihuoEffect,
	        NotifyConsts.UseZZDChanged,
	        NotifyConsts.VipBackInfo,
	        NotifyConsts.VipBackInfoChange,
			NotifyConsts.MountFailCancelZiDong};
			
end

---------------------------------ui事件处理------------------------------------

function UIMountBasic:OnBtnUpClick(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local horsecfg = t_horse[MountModel:GetMountLvl()];
	if not horsecfg then
		return;
	end
	
	if horsecfg.attr_dan <= 0 then
		FloatManager:AddNormal( StrConfig["mount18"], objSwf.btnShuXingDan);
		return;
	end
	
	--属性丹上限
	local sXDCount = 0
	for k,cfg in pairs(t_horse) do
		if cfg.id == MountModel.ridedMount.mountLevel then
			sXDCount = cfg.attr_dan
			break
		end
	end
	
	--已达到上限
	if MountModel.ridedMount.pillNum >= sXDCount then
		FloatManager:AddNormal( StrConfig["mount7"], objSwf.btnShuXingDan);
		return
	end
	
	--材料不足
	if MountUtil:GetJieJieItemNum(1) <= 0 then
		FloatManager:AddNormal( StrConfig["mount6"], objSwf.btnShuXingDan);
		return
	end
	
	MountController:FeedShuXingDan(1)

end
function UIMountBasic:ShowvipEffect()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local vo = VipModel:GetBackItemInfo(VipConsts.TYPE_MOUNT);
    if vo and vo.itemNum>0 then 
    	objSwf.vipeffect._visible=true
    	return  
    end
    objSwf.vipeffect._visible=false
end
function UIMountBasic:ShowMountUppPanel()
	UIMount:ShowChild(MountConsts.MOUNTLVUP, false);
end

--面板开关控制
function UIMountBasic:OnOffPanel(panel)
	if panel.bShowState then
		panel:Hide();
	else
		panel:Show();
	end
end

--属性丹tip
function UIMountBasic:OnShuXingDanRollOver()
	UIMountFeedTip:OpenPanel(1);
end

function UIMountBasic:OnBtnVipBackRollOver()
	UIVipBackTips:Open( VipConsts.TYPE_MOUNT )
end

function UIMountBasic:OnBtnVipBackrollOut()
	UIVipBackTips:Hide()
end

function UIMountBasic:OnbtntipRollOut()
	TipsManager:Hide();
	
	self:ShowCurAttrInfo();
end
function UIMountBasic:OnMountSkillTipRollOver(i)
    

	local skillId = self.skilllist[i].skillId;
	

	local get = self.skilllist[i].lvl > 0;
	TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=skillId,condition=true,get=get},TipsConsts.ShowType_Normal,
						TipsConsts.Dir_RightUp);
end

function UIMountBasic:OnMountSkillTipRollOut()
	TipsManager:Hide();
end
function UIMountBasic:ShowSkillList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	for i=1, self.skillTotalNum do
		self.skillicon[i]._visible = false
	end
	
	local list = MountUtil:GetMountSortSkill();

	for i= 1, self.skillTotalNum do
		local listvo = MountUtil:GetSkillListVO(list[i].skillId,list[i].lvl)

		if listvo then
		    
			self.skillicon[i]._visible = true
			self.skillicon[i].imgup.visible = false
		
			self.skillicon[i].btnskill.visible = true
			self.skillicon[i].iconLoader.visible = true
			
			if listvo.lvl == 0 then
				self.skillicon[i].iconLoader.source = ImgUtil:GetGrayImgUrl(listvo.iconUrl)
			else
			self.skillicon[i].iconLoader.source = listvo.iconUrl   
				if listvo.lvl < listvo.maxLvl then
					local str = listvo.needItem;
					local strvo = MountUtil:Parse(str)
					local itemNum = BagModel:GetItemNumInBag(strvo.itemid)
				end
				--升级条件
			end
			    local islearn=listvo.lvl == 0;
				if  listvo.lvl < listvo.maxLvl and MountUtil:GetCanLvlUpDzz(listvo.skillId,islearn) == true  then
					self.skillicon[i].imgup.visible = true
				end
			self.skilllist[i] = listvo
		end
	end
end

function UIMountBasic:UpdateSkillList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local list = MountUtil:GetMountSortSkill();
	

	for i= 1, self.skillTotalNum do
		local listvo = MountUtil:GetSkillListVO(list[i].skillId,list[i].lvl)
		if listvo then
			
			if listvo.lvl ~= 0 and listvo.lvl < listvo.maxLvl then
				--升级条件
				local str = listvo.needItem;
				local strvo = MountUtil:Parse(str)
				local itemNum = BagModel:GetItemNumInBag(strvo.itemid)
			end
			local islearn=listvo.lvl == 0;
			if listvo.lvl < listvo.maxLvl and MountUtil:GetCanLvlUpDzz(listvo.skillId,islearn) == true  then
			    self.skillicon[i].imgup.visible = true
			end
		end
	end
end

function UIMountBasic:UpdateSkillLearn(body)
	for i,vo in pairs(self.skilllist) do
		if vo.skillId == body.skillId then
			local list = MountUtil:GetMountSortSkill();
			local listvo = MountUtil:GetSkillListVO(list[i].skillId,list[i].lvl)
			if listvo then
				self.skillicon[i].btnskill.visible = true
				self.skillicon[i].iconLoader.visible = true
				self.skillicon[i].iconLoader.source = listvo.iconUrl

				--升级条件
				local str = listvo.needItem;
				local strvo = MountUtil:Parse(str)
				local itemNum = BagModel:GetItemNumInBag(strvo.itemid)
                local islearn=listvo.lvl == 0;
				if MountUtil:GetCanLvlUpDzz(listvo.skillId,islearn) == true then
					self.skillicon[i].imgup.visible = true
				else
					self.skillicon[i].imgup.visible = false
				end
				
				self.skilllist[i] = listvo
			end
		end
	end
end

function UIMountBasic:UpdateSkillLvUp(body)


	for i,vo in pairs(self.skilllist) do
		if vo.skillId == body.oldSkillId then
			local list = MountUtil:GetMountSortSkill();
			local listvo = MountUtil:GetSkillListVO(list[i].skillId,list[i].lvl)
			if listvo then
				self.skillicon[i].btnskill.visible = true
				self.skillicon[i].iconLoader.visible = true
				self.skillicon[i].iconLoader.source = listvo.iconUrl

				--升级条件
				local str = listvo.needItem;
				local strvo = MountUtil:Parse(str)
				local itemNum = BagModel:GetItemNumInBag(strvo.itemid)
				if MountUtil:GetCanLvlUpDzz(listvo.skillId) == true then
					self.skillicon[i].imgup.visible = true
				else
					self.skillicon[i].imgup.visible = false
				end
				
				self.skilllist[i] = listvo
			end
		end
	end
end
function UIMountBasic:OnBtnPreClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--模型
	self:DrawMount(self.currentShowLevel - 1, true)
	
	self:ShowNextMountInfo(self.currentShowLevel);
end

function UIMountBasic:OnBtnNextClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--模型
	self:DrawMount(self.currentShowLevel + 1, true)
	
	self:ShowNextMountInfo(self.currentShowLevel);
end

--显示信息
function UIMountBasic:GetAttMap()	
	--基本信息
	local info = MountUtil:GetMountBaseAttrList(MountModel.ridedMount.mountLevel,MountModel.ridedMount.mountStar)
	if info == nil then
		return nil
	end
	local attMap = {}
	for i,vo in ipairs(info) do
		if vo.type == enAttrType.eaGongJi then
			-- attMap.att = vo.val
			table.push(attMap,{proKey = 'att', proValue = vo.val})
		elseif vo.type == enAttrType.eaFangYu then
			-- attMap.def = vo.val
			table.push(attMap,{proKey = 'def', proValue = vo.val})
		elseif vo.type == enAttrType.eaMaxHp then
			-- attMap.hp = vo.val
			table.push(attMap,{proKey = 'hp', proValue = vo.val})
		elseif vo.type == enAttrType.eaBaoJi then
			-- attMap.cri = vo.val
			 table.push(attMap,{proKey = 'cri', proValue = vo.val})
		 elseif vo.type == enAttrType.eaRenXing then
			-- attMap.defcri = vo.val
			 table.push(attMap,{proKey = 'defcri', proValue = vo.val})
		elseif vo.type == enAttrType.eaMingZhong then
			-- attMap.hit = vo.val
			table.push(attMap,{proKey = 'hit', proValue = vo.val})
		elseif vo.type == enAttrType.eaShanBi then
			-- attMap.dodge = vo.val
			table.push(attMap,{proKey = 'dodge', proValue = vo.val})
		end
	end
	return attMap
end
---------------------------------ui逻辑------------------------------------

--显示信息
function UIMountBasic:ShowMountInfo()
	FPrint('UIMountBasic:ShowMountInfo')
	local objSwf = self:GetSWF("UIMountBasic");
	if not objSwf then return; end

	local mountinfo = nil;
	mountinfo = MountModel:GetMountVO(MountModel.ridedMount.mountLevel)
	if mountinfo == nil then
		return
	end
	local mountId = MountModel.ridedMount.mountLevel
	--local ridedinfo = {};
--	ridedinfo = MountModel:GetMountVO(MountModel.ridedMount.ridedId)
	--如果当前没有骑乘坐骑，默认显示当前阶
	-- if ridedinfo == nil then
	-- 	ridedinfo = mountinfo;
	-- end
	-- local mountId = MountModel.ridedMount.ridedId;
	-- if MountModel.ridedMount.ridedId > MountConsts.LingShouSpecailDownid then
	-- 	mountId = MountModel.ridedMount.mountLevel;
	-- end
	
	local playerinfo = MainPlayerModel.humanDetailInfo;
	
	--模型
	self:DrawMount(mountId, true)
	--名称资源
	-- local nameiconLevel = MountModel.ridedMount.ridedId;
	-- if MountModel.ridedMount.ridedId > MountConsts.LingShouSpecailDownid then
	-- 	nameiconLevel = MountModel.ridedMount.mountLevel;
	-- end
	local iconname = MountUtil:GetMountIconName(mountId, "nameIcon", playerinfo.eaProf)
	objSwf.nameLoader.source =  ResUtil:GetMountIconName(iconname)
	-- if mountId > MountConsts.SpecailDownid then
	-- 	mountId = MountModel.ridedMount.mountLevel;
	-- end
	objSwf.lvlLoader.source = ResUtil:GetFeedUpLvlImg(mountId);
	objSwf.imgnotget._visible = false;
	
	--骑乘状态
	self:UpdateBtnQCState();
	
	--显示进阶按钮
	self:UpdateBtnState();
	--属性名称
	for i = 9, 13 do
		objSwf["tfName"..i].htmlText = PublicStyle:GetAttrNameStr(UIStrConfig["mount"..i]);
	--objSwf.tfName14._visible = false;
	--objSwf.tfName15._visible = false;	
	end
	
	--基本信息
	local info = MountUtil:GetMountAttribute(MountModel.ridedMount.mountLevel,MountModel.ridedMount.mountStar)
	if info == nil then
		return
	end
	--FTrace(info, '基本信息')
	for i,vo in ipairs(info) do
		if vo.type == enAttrType.eaFight then
			objSwf.numFight.num = vo.val
		elseif vo.type == enAttrType.eaGongJi then
			objSwf.tfGongJi.htmlText = PublicStyle:GetAttrValStr(vo.val);
		elseif vo.type == enAttrType.eaFangYu then
			objSwf.tfFangYu.htmlText = PublicStyle:GetAttrValStr(vo.val);
		elseif vo.type == enAttrType.eaMaxHp then
			objSwf.tfShengMing.htmlText = PublicStyle:GetAttrValStr(vo.val);
		 elseif vo.type == enAttrType.eaBaoJi then
			 objSwf.tfBaoJi.htmlText = PublicStyle:GetAttrValStr(vo.val);
		 elseif vo.type == enAttrType.eaRenXing then
			-- objSwf.tfRenXing.htmlText = PublicStyle:GetAttrValStr(vo.val);
		elseif vo.type == enAttrType.eaMingZhong then
			objSwf.tfMingZhong.htmlText = PublicStyle:GetAttrValStr(vo.val);
		elseif vo.type == enAttrType.eaShanBi then
			objSwf.tfShanBi.htmlText = PublicStyle:GetAttrValStr(vo.val);
		elseif vo.type == enAttrType.eaMoveSpeed then
			--objSwf.tfSuDu.htmlText = PublicStyle:GetAttrValStr(vo.val);
		end
	end
	
	--清空属性加成信息
	objSwf.imgFightAdd.visible = false
	objSwf.imgGongJiAdd.visible = false
	objSwf.imgFangYuAdd.visible = false
	objSwf.imgShengMingAdd.visible = false
	 --objSwf.imgBaoJiAdd.visible = false
	 --objSwf.imgRenXingAdd.visible = false
	objSwf.imgMingZhongAdd.visible = false
	objSwf.imgShanBiAdd.visible = false
	--objSwf.imgSuDuAdd.visible = false
	
	objSwf.fightaddLoader.visible = false
	objSwf.tfGongJiAdd.text = ''
	objSwf.tfFangYuAdd.text = ''
	objSwf.tfShengMingAdd.text = ''
	-- objSwf.tfBaoJiAdd.text = ''
	-- objSwf.tfRenXingAdd.text = ''
	objSwf.tfMingZhongAdd.text = ''
	objSwf.tfShanBiAdd.text = ''
	--objSwf.tfSuDuAdd.text = ''
	objSwf.tfVIPFightAdd.text = ''
--	objSwf.tfBaoJiAdd.visible = false	
	--objSwf.tfRenXingAdd.visible = false		
end

--显示信息
function UIMountBasic:UpdateMountAttrInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	if self.currentShowLevel == MountModel.ridedMount.mountLevel + 1 then
		
		self:ShowNextMountInfo(self.currentShowLevel);
	else
		self:ShowZiDongNextAttrInfo()
	end
end
function UIMountBasic:ShowAttrRed()
 
    local objSwf = self.objSwf;
	if not objSwf then return; end

	local cfg = t_horse[MountModel.ridedMount.mountLevel];
	if not cfg then
		return;
	end
	if cfg.zizhi_dan <= 0 or cfg.attr_dan <= 0 then

		objSwf.btnZiZhiDan.effect._visible=false;
		objSwf.btnShuXingDan.effect._visible=false;
		return;
	end
	--资质丹上限
	local zzdCount = 0
	for k,cfg in pairs(t_horse) do
		if cfg.id == MountModel.ridedMount.mountLevel then
			zzdCount = cfg.zizhi_dan
			break
		end
	end
	if ZiZhiModel:GetZZNum(6) >= zzdCount or ZiZhiUtil:GetZZItemNum(6) <= 0 then
		objSwf.btnZiZhiDan.effect._visible=false;
	else
		objSwf.btnZiZhiDan.effect._visible=true;
	end

	--属性丹上限
	local sXDCount = 0
	for k,cfg in pairs(t_horse) do
		if cfg.id == MountModel.ridedMount.mountLevel then
			sXDCount = cfg.attr_dan
			break
		end
	end
	--已达到上限
	print(MountModel.ridedMount.pillNum,sXDCount)
	if MountModel.ridedMount.pillNum >= sXDCount or  MountUtil:GetJieJieItemNum(1) <= 0 then
		objSwf.btnShuXingDan.effect._visible=false;
	else
		objSwf.btnShuXingDan.effect._visible=true;
	end
end
function UIMountBasic:OnBtnZZDClick(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end

	local cfg = t_horse[MountModel.ridedMount.mountLevel];
    
	if not cfg then
		return;
	end
	if cfg.zizhi_dan <= 0 then
		FloatManager:AddNormal( string.format(StrConfig["zizhi1"], ZiZhiUtil:GetOpenLvByCFG(t_horse)), objSwf.btnZiZhiDan);
		return;
	end
	--资质丹上限
	local zzdCount = 0
	for k,cfg in pairs(t_horse) do
		if cfg.id == MountModel.ridedMount.mountLevel then
			zzdCount = cfg.zizhi_dan
			break
		end
	end
	--已达到上限
	if ZiZhiModel:GetZZNum(6) >= zzdCount then
		FloatManager:AddNormal( StrConfig["mount7"], objSwf.btnZiZhiDan);
		return
	end

	--材料不足
	if ZiZhiUtil:GetZZItemNum(6) <= 0 then
		FloatManager:AddNormal( StrConfig["mount6"], objSwf.btnZiZhiDan);
		return
	end
	ZiZhiController:FeedZZDan(6)
end

--属性丹tip
function UIMountBasic:OnZZDRollOver()
	UIMountFeedTip:OpenPanel(106);
end
--更新信息
function UIMountBasic:UpdateMountInfo()
	FPrint('UIMountBasic:UpdateMountInfo')
	local objSwf = self:GetSWF("UIMountBasic");
	if not objSwf then return; end

	local mountinfo = nil;
	mountinfo = MountModel:GetMountVO(MountModel.ridedMount.mountLevel)
	if mountinfo == nil then
		return
	end
	
	--基本信息
	local playerinfo = MainPlayerModel.humanDetailInfo;
	local info = MountUtil:GetMountAttribute(MountModel.ridedMount.mountLevel,MountModel.ridedMount.mountStar)
	if info == nil then
		return
	end

	for i,vo in ipairs(info) do
		if vo.type == enAttrType.eaFight then
			objSwf.numFight.num = vo.val
		elseif vo.type == enAttrType.eaGongJi then
			objSwf.tfGongJi.text = vo.val
		elseif vo.type == enAttrType.eaFangYu then
			objSwf.tfFangYu.text = vo.val
		elseif vo.type == enAttrType.eaMaxHp then
			objSwf.tfShengMing.text = vo.val
		 elseif vo.type == enAttrType.eaBaoJi then
			 objSwf.tfBaoJi.text = vo.val
		 elseif vo.type == enAttrType.eaRenXing then
			--objSwf.tfRenXing.text = vo.val
		elseif vo.type == enAttrType.eaMingZhong then
			objSwf.tfMingZhong.text = vo.val
		elseif vo.type == enAttrType.eaShanBi then
			objSwf.tfShanBi.text = vo.val
		elseif vo.type == enAttrType.eaMoveSpeed then
			--objSwf.tfSuDu.text = vo.val
		end	
	end

	--objSwf.tfRenXing.visible = false
	--objSwf.tfRenXing.visible = false
	
	--清空属性加成信息
	objSwf.imgFightAdd.visible = false
	objSwf.imgGongJiAdd.visible = false
	objSwf.imgFangYuAdd.visible = false
	objSwf.imgShengMingAdd.visible = false
	--objSwf.imgBaoJiAdd.visible = false
	--objSwf.imgRenXingAdd.visible = false
	objSwf.imgMingZhongAdd.visible = false
	objSwf.imgShanBiAdd.visible = false
	--objSwf.imgSuDuAdd.visible = false		
	
	objSwf.fightaddLoader.visible = false
	objSwf.tfGongJiAdd.text = ''
	objSwf.tfFangYuAdd.text = ''
	objSwf.tfShengMingAdd.text = ''
	--objSwf.tfBaoJiAdd.text = ''
	--objSwf.tfRenXingAdd.text = ''
	objSwf.tfMingZhongAdd.text = ''
	objSwf.tfShanBiAdd.text = ''
	--objSwf.tfSuDuAdd.text = ''
	objSwf.tfVIPFightAdd.text = ''
end

--更新喂养属性丹后的信息
function UIMountBasic:UpdateSXDInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	FPrint('UIMountBasic:UpdateSXDInfo')
	local mountinfo = nil;
	mountinfo = MountModel:GetMountVO(MountModel.ridedMount.mountLevel)
	if mountinfo == nil then
		return
	end
	
	--基本信息
	local playerinfo = MainPlayerModel.humanDetailInfo;
	local info = MountUtil:GetMountAttribute(MountModel.ridedMount.mountLevel,MountModel.ridedMount.mountStar)
	if info == nil then
		return
	end

	for i,vo in ipairs(info) do
		if vo.type == enAttrType.eaFight then
			objSwf.numFight.num = vo.val
		elseif vo.type == enAttrType.eaGongJi then
			objSwf.tfGongJi.text = vo.val
		elseif vo.type == enAttrType.eaFangYu then
			objSwf.tfFangYu.text = vo.val
		elseif vo.type == enAttrType.eaMaxHp then
			objSwf.tfShengMing.text = vo.val
		elseif vo.type == enAttrType.eaBaoJi then
			objSwf.tfBaoJi.text = vo.val
		elseif vo.type == enAttrType.eaRenXing then
			 --objSwf.tfRenXing.text = vo.val
		elseif vo.type == enAttrType.eaMingZhong then
			objSwf.tfMingZhong.text = vo.val
		elseif vo.type == enAttrType.eaShanBi then
			objSwf.tfShanBi.text = vo.val
		elseif vo.type == enAttrType.eaMoveSpeed then
			--objSwf.tfSuDu.text = vo.val
		end
	end
end

--更新等级
function UIMountBasic:UpdateLevelInfo()
end

--预览下一阶信息
local infostr;
function UIMountBasic:ShowNextMountInfo(mountLevel)
	
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local playerinfo = MainPlayerModel.humanDetailInfo;
	
	if not mountLevel then
		Error("mountLevel is nil");
		return;
	end
	
	local iconname = MountUtil:GetMountIconName(mountLevel, "nameIcon", playerinfo.eaProf)
	objSwf.nameLoader.source =  ResUtil:GetMountIconName(iconname)
	if mountLevel > MountConsts.SpecailDownid then
		mountLevel = MountModel.ridedMount.mountLevel;
	end
	objSwf.lvlLoader.source = ResUtil:GetFeedUpLvlImg(mountLevel);
	objSwf.imgnotget._visible = false;
	
	if mountLevel < MountModel.ridedMount.mountLevel then
		if not self.preShowLevel then
			return;
		end
	end
	
	--基本信息
	local info = MountUtil:GetMountAttribute(MountModel.ridedMount.mountLevel,MountModel.ridedMount.mountStar)
	if info == nil then
		return
	end
	FPrint('UIMountBasic:ShowNextMountInfo')
	for i,vo in ipairs(info) do
		if vo.type == enAttrType.eaFight then
			objSwf.numFight.num = vo.val
		elseif vo.type == enAttrType.eaGongJi then
			objSwf.tfGongJi.text = vo.val
		elseif vo.type == enAttrType.eaFangYu then
			objSwf.tfFangYu.text = vo.val
		elseif vo.type == enAttrType.eaMaxHp then
			objSwf.tfShengMing.text = vo.val
		elseif vo.type == enAttrType.eaBaoJi then
			objSwf.tfBaoJi.text = vo.val
		elseif vo.type == enAttrType.eaRenXing then
			--objSwf.tfRenXing.text = vo.val
		elseif vo.type == enAttrType.eaMingZhong then
			objSwf.tfMingZhong.text = vo.val
		elseif vo.type == enAttrType.eaShanBi then
			objSwf.tfShanBi.text = vo.val
		elseif vo.type == enAttrType.eaMoveSpeed then
			--objSwf.tfSuDu.text = vo.val
		end
	end
	
	--显示属性加成信息
	objSwf.fightaddLoader.visible = false
	objSwf.tfGongJiAdd.text = ''
	objSwf.tfFangYuAdd.text = ''
	objSwf.tfShengMingAdd.text = ''
	--objSwf.tfBaoJiAdd.text = ''
	--objSwf.tfRenXingAdd.text = ''
	objSwf.tfMingZhongAdd.text = ''
	objSwf.tfShanBiAdd.text = ''
	--objSwf.tfSuDuAdd.text = ''
	objSwf.tfVIPFightAdd.text = ''
	
	objSwf.imgFightAdd.visible = false
	objSwf.imgGongJiAdd.visible = false
	objSwf.imgFangYuAdd.visible = false
	objSwf.imgShengMingAdd.visible = false
	--objSwf.imgBaoJiAdd.visible = false
	--objSwf.imgRenXingAdd.visible = false
	objSwf.imgMingZhongAdd.visible = false
	objSwf.imgShanBiAdd.visible = false
	--objSwf.imgSuDuAdd.visible = false
	
	if mountLevel <= MountModel.ridedMount.mountLevel then
		self:ShowZiDongNextAttrInfo()
		return;
	end
	
	objSwf.imgnotget._visible = true;
	
	--预览下阶坐骑属性提成
	local infoless = MountUtil:GetLevelLessAttribute(MountModel.ridedMount.mountLevel,MountModel.ridedMount.mountStar)
	if infoless == nil then
		return
	end
	local lastStart = MountConsts.MountStarMax-MountModel.ridedMount.mountStar
	
    infostr =string.format(StrConfig['Mount137'],lastStart)

    --local infostr= string.format(StrConfig['Mount137'],lastStart) or string.format(StrConfig['Mount138'],lastStart);
	for i,vo in ipairs(infoless) do
		if vo.type == enAttrType.eaFight then
		    objSwf.fightaddLoader.visible=true
			objSwf.fightaddLoader.num =vo.val
			objSwf.imgFightAdd.visible = true
		elseif vo.type == enAttrType.eaGongJi then
			objSwf.tfGongJiAdd.text = "+"..vo.val..infostr
			objSwf.imgGongJiAdd.visible = true
		elseif vo.type == enAttrType.eaFangYu then
			objSwf.tfFangYuAdd.text = "+"..vo.val..infostr
			objSwf.imgFangYuAdd.visible = true
		elseif vo.type == enAttrType.eaMaxHp then
			objSwf.tfShengMingAdd.text = "+"..vo.val..infostr
			objSwf.imgShengMingAdd.visible = true
		elseif vo.type == enAttrType.eaBaoJi then
			-- objSwf.tfBaoJiAdd.text = "+"..vo.val..infostr
			--objSwf.imgBaoJiAdd.visible = true
		elseif vo.type == enAttrType.eaRenXing then
			--objSwf.tfRenXingAdd.text = "+"..vo.val..infostr
		--	objSwf.imgRenXingAdd.visible = true
		elseif vo.type == enAttrType.eaMingZhong then
			objSwf.tfMingZhongAdd.text = "+"..vo.val..infostr
			objSwf.imgMingZhongAdd.visible = true
		elseif vo.type == enAttrType.eaShanBi then
			objSwf.tfShanBiAdd.text = "+"..vo.val..infostr
			objSwf.imgShanBiAdd.visible = true
		elseif vo.type == enAttrType.eaMoveSpeed then
		--	objSwf.tfSuDuAdd.text = "+"..vo.val..infostr
			--objSwf.imgSuDuAdd.visible = true
		end
	end
	
	local fight = MountUtil:GetVipLessPower(MountModel.ridedMount.mountLevel,MountModel.ridedMount.mountStar) or 0
	--objSwf.tfVIPFightAdd.htmlText = string.format(StrConfig['vip100'],fight);
end

--预览下一星信息
function UIMountBasic:ShowNextAttrInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	 if self.currentShowLevel == MountModel.ridedMount.mountLevel + 1 then
	 	return;
	 end
	
	local playerinfo = MainPlayerModel.humanDetailInfo;
	
	--基本信息
	local info = MountUtil:GetMountAttribute(MountModel.ridedMount.mountLevel,MountModel.ridedMount.mountStar)

	if info == nil then
		return
	end
	FPrint('UIMountBasic:ShowNextAttrInfo')
	for i,vo in ipairs(info) do
		if vo.type == enAttrType.eaFight then
			objSwf.numFight.num = vo.val
		elseif vo.type == enAttrType.eaGongJi then
			objSwf.tfGongJi.text = vo.val
		elseif vo.type == enAttrType.eaFangYu then
			objSwf.tfFangYu.text = vo.val
		elseif vo.type == enAttrType.eaMaxHp then
			objSwf.tfShengMing.text = vo.val
		 elseif vo.type == enAttrType.eaBaoJi then
			 objSwf.tfBaoJi.text = vo.val
		 elseif vo.type == enAttrType.eaRenXing then
			 --objSwf.tfRenXing.text = vo.val
		elseif vo.type == enAttrType.eaMingZhong then
			objSwf.tfMingZhong.text = vo.val
		elseif vo.type == enAttrType.eaShanBi then
			objSwf.tfShanBi.text = vo.val
		elseif vo.type == enAttrType.eaMoveSpeed then
			--objSwf.tfSuDu.text = vo.val
		end
	end
	
	--显示属性加成信息
	objSwf.fightaddLoader.visible = false
	objSwf.tfGongJiAdd.text = ''
	objSwf.tfFangYuAdd.text = ''
	objSwf.tfShengMingAdd.text = ''
	-- objSwf.tfBaoJiAdd.text = ''
	 --objSwf.tfRenXingAdd.text = ''
	objSwf.tfMingZhongAdd.text = ''
	objSwf.tfShanBiAdd.text = ''
	--objSwf.tfSuDuAdd.text = ''
	objSwf.tfVIPFightAdd.text = ''
	
	objSwf.imgFightAdd.visible = false
	objSwf.imgGongJiAdd.visible = false
	objSwf.imgFangYuAdd.visible = false
	objSwf.imgShengMingAdd.visible = false
	-- objSwf.imgBaoJiAdd.visible = false
	-- objSwf.imgRenXingAdd.visible = false
	objSwf.imgMingZhongAdd.visible = false
	objSwf.imgShanBiAdd.visible = false
	--objSwf.imgSuDuAdd.visible = false
	
	--预览下阶坐骑属性提成
	local infoless = MountUtil:GetStarLessAttribute(MountModel.ridedMount.mountLevel,MountModel.ridedMount.mountStar)
	if infoless == nil then
		return
	end

	local lastStart = MountConsts.MountStarMax-MountModel.ridedMount.mountStar
	
    infostr =string.format(StrConfig['Mount137'],lastStart)
	
	for i,vo in ipairs(infoless) do
		if vo.type == enAttrType.eaFight then
			objSwf.fightaddLoader.visible=true
			objSwf.fightaddLoader.num =vo.val
			--objSwf.imgFightAdd.visible = true
		elseif vo.type == enAttrType.eaGongJi then
			objSwf.tfGongJiAdd.text = "+"..vo.val..infostr;
			objSwf.imgGongJiAdd.visible = true
		elseif vo.type == enAttrType.eaFangYu then
			objSwf.tfFangYuAdd.text = "+"..vo.val..infostr;
			objSwf.imgFangYuAdd.visible = true
		elseif vo.type == enAttrType.eaMaxHp then
			objSwf.tfShengMingAdd.text = "+"..vo.val..infostr;
			objSwf.imgShengMingAdd.visible = true
		elseif vo.type == enAttrType.eaBaoJi then
			-- objSwf.tfBaoJiAdd.text = "+"..vo.val.."(本颗星)"
			-- objSwf.imgBaoJiAdd.visible = true
		 elseif vo.type == enAttrType.eaRenXing then
			 --objSwf.tfRenXingAdd.text = "+"..vo.val.."(本颗星)"
			-- objSwf.imgRenXingAdd.visible = true
		elseif vo.type == enAttrType.eaMingZhong then
			objSwf.tfMingZhongAdd.text = "+"..vo.val..infostr;
			objSwf.imgMingZhongAdd.visible = true
		elseif vo.type == enAttrType.eaShanBi then
			objSwf.tfShanBiAdd.text = "+"..vo.val..infostr;
			objSwf.imgShanBiAdd.visible = true
		elseif vo.type == enAttrType.eaMoveSpeed then
			--objSwf.tfSuDuAdd.text = "+"..vo.val.."(每颗星)"
			--objSwf.imgSuDuAdd.visible = true
		end
	end
	
	local fight = MountUtil:GetVipStarLessPower(MountModel.ridedMount.mountLevel,MountModel.ridedMount.mountStar) or 0
	--objSwf.tfVIPFightAdd.htmlText = string.format(StrConfig['vip100'],fight);
end

--预览下一阶信息
function UIMountBasic:ShowCurAttrInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	if self.currentShowLevel == MountModel.ridedMount.mountLevel + 1 then
		return;
	end
	
	--如果当前正在自动进阶
	if MountController.biszidongup == 1 then
		return;
	end
	
	--显示属性加成信息

	objSwf.fightaddLoader.visible = false
	objSwf.tfGongJiAdd.text = ''
	objSwf.tfFangYuAdd.text = ''
	objSwf.tfShengMingAdd.text = ''
	--objSwf.tfBaoJiAdd.text = ''
	--objSwf.tfRenXingAdd.text = ''
	objSwf.tfMingZhongAdd.text = ''
	objSwf.tfShanBiAdd.text = ''
	--objSwf.tfSuDuAdd.text = ''
	objSwf.tfVIPFightAdd.text = ''
	
	objSwf.imgFightAdd.visible = false
	objSwf.imgGongJiAdd.visible = false
	objSwf.imgFangYuAdd.visible = false
	objSwf.imgShengMingAdd.visible = false
	--objSwf.imgBaoJiAdd.visible = false
	--objSwf.imgRenXingAdd.visible = false
	objSwf.imgMingZhongAdd.visible = false
	objSwf.imgShanBiAdd.visible = false
	--objSwf.imgSuDuAdd.visible = false
end

--返回当前阶
function UIMountBasic:ReturnCurMountInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--如果没有下一阶预览,不需要返回
	local mountinfo = nil;
	mountinfo = MountModel:GetMountVO(MountModel.ridedMount.mountLevel + 1)
	if mountinfo == nil then
		return
	end
	
	self:ShowMountInfo();
end

--预览属性丹后的信息
function UIMountBasic:ShowNextShuXingDanInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--显示属性加成信息
    objSwf.fightaddLoader.visible = false
	objSwf.tfGongJiAdd.text = ''
	objSwf.tfFangYuAdd.text = ''
	objSwf.tfShengMingAdd.text = ''
	--objSwf.tfBaoJiAdd.text = ''
	--objSwf.tfRenXingAdd.text = ''
	objSwf.tfMingZhongAdd.text = ''
	objSwf.tfShanBiAdd.text = ''
	objSwf.tfVIPFightAdd.text = ''
	
	objSwf.imgFightAdd.visible = false
	objSwf.imgGongJiAdd.visible = false
	objSwf.imgFangYuAdd.visible = false
	objSwf.imgShengMingAdd.visible = false
	--objSwf.imgBaoJiAdd.visible = false
	--objSwf.imgRenXingAdd.visible = false
	objSwf.imgMingZhongAdd.visible = false
	objSwf.imgShanBiAdd.visible = false
	
	local str = t_consts[8].param;
	local formulaList = AttrParseUtil:Parse(str)
	for i,vo in pairs(formulaList) do
		if vo.type == enAttrType.eaFight then
			objSwf.fightaddLoader.visible=true
			objSwf.fightaddLoader.num = vo.val
			objSwf.imgFightAdd.visible = true
		elseif vo.type == enAttrType.eaGongJi then
			objSwf.tfGongJiAdd.text = vo.val
			objSwf.imgGongJiAdd.visible = true
		elseif vo.type == enAttrType.eaFangYu then
			objSwf.tfFangYuAdd.text = vo.val
			objSwf.imgFangYuAdd.visible = true
		elseif vo.type == enAttrType.eaMaxHp then
			objSwf.tfShengMingAdd.text = vo.val
			objSwf.imgShengMingAdd.visible = true
		elseif vo.type == enAttrType.eaBaoJi then
			--objSwf.tfBaoJiAdd.text = vo.val
			--objSwf.imgBaoJiAdd.visible = true
		elseif vo.type == enAttrType.eaRenXing then
			--objSwf.tfRenXingAdd.text = vo.val
			--objSwf.imgRenXingAdd.visible = true
		elseif vo.type == enAttrType.eaMingZhong then
			objSwf.tfMingZhongAdd.text = vo.val
			objSwf.imgMingZhongAdd.visible = true
		elseif vo.type == enAttrType.eaShanBi then
			objSwf.tfShanBiAdd.text = vo.val
			objSwf.imgShanBiAdd.visible = true
		elseif vo.type == enAttrType.eaMoveSpeed then
			--objSwf.tfSuDuAdd.text = vo.val
			--objSwf.imgSuDuAdd.visible = true
		end
	end
	
	
end

--清空预览属性丹
function UIMountBasic:ClearNextShuXingDanInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--显示属性加成信息
	objSwf.fightaddLoader.visible = false
	objSwf.tfGongJiAdd.text = '';
	objSwf.tfFangYuAdd.text = '';
	objSwf.tfShengMingAdd.text = '';
	--objSwf.tfBaoJiAdd.text = '';
	--objSwf.tfRenXingAdd.text = '';
	objSwf.tfMingZhongAdd.text = '';
	objSwf.tfShanBiAdd.text = '';
	objSwf.tfVIPFightAdd.text = ''
	
	objSwf.imgFightAdd.visible = false;
	objSwf.imgGongJiAdd.visible = false;
	objSwf.imgFangYuAdd.visible = false;
	objSwf.imgShengMingAdd.visible = false;
	--objSwf.imgBaoJiAdd.visible = false;
	--objSwf.imgRenXingAdd.visible = false;
	objSwf.imgMingZhongAdd.visible = false;
	objSwf.imgShanBiAdd.visible = false;
end

--显示属性丹信息
function UIMountBasic:ShowShuXingDanInfo()
	local objSwf = self:GetSWF("UIMountBasic");
	if not objSwf then return; end
	
	local valinfo = t_consts[8]
	if valinfo == nil then
		return
	end
	
	local sXDItem = t_item[t_consts[8].val1]
	if sXDItem == nil then
		return
	end
	
	--进度条
	local sXDCount = 0
	for k,cfg in pairs(t_horse) do
		if cfg.id == MountModel.ridedMount.mountLevel then
			sXDCount = cfg.attr_dan
			break
		end
	end
end
function UIMountBasic:OnBtnSkillClick(i)
	--学习技能或者升级到下一个技能
	local vo = MountUtil:GetNextMountLvlSkillId(self.skilllist[i]);
	

	if vo then
        
		UIMountSkill.vo = vo;
		UIMountSkill.skillid = self.skilllist[i].skillId;
		if not UIMountSkill.bShowState then
		self:ShowChild(MountConsts.MOUNTSKILL);
		else
			UIMountSkill:ShowSkillInfo()

		end
	end
end
--更新属性丹信息
function UIMountBasic:UpdateShuXingDanInfo()
	local objSwf = self:GetSWF("UIMountBasic");
	if not objSwf then return; end
	
end

--更新进阶按钮
function UIMountBasic:UpdateBtnState()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	objSwf.mountupPanel._visible = false;
	objSwf.imgordermax._visible = false;
	if MountModel.ridedMount.mountLevel >= MountConsts.MountLevelMax then
		objSwf.imgordermax._visible = true;
	else
		objSwf.mountupPanel._visible = true;
	end
end

--更新骑乘按钮
function UIMountBasic : UpdateBtnQCState()
end

-- 创建配置文件
UIMountBasic.defaultCfg = {
									EyePos = _Vector3.new(0,-40,20),
									LookPos = _Vector3.new(0,0,10),
									VPort = _Vector2.new(900,530),
									Rotation = 0,
								  };
function UIMountBasic : GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.Rotation = self.defaultCfg.Rotation;
	return cfg;
end

-- 显示等级为level的3d坐骑模型
-- showActive: 是否播放激活动作
local viewMountPort;
function UIMountBasic : DrawMount( level, showActive )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not level then
		level = MountModel:GetMountLvl();
	end
	local cfg = {};
	--普通坐骑
	if level < MountConsts.SpecailDownid then
		cfg = t_horse[level];
		
		if not cfg then
			Error("Cannot find config of horse. level:"..level);
			return;
		end
	--特殊坐骑
	else
		cfg = t_horseskn[level];
		
		if not cfg then
			Error("Cannot find config of t_horseskn. level:"..level);
			return;
		end
	end
	
	objSwf.btnPre.disabled = level <= 1;
	objSwf.btnNext.disabled = level >= MountModel:GetMountLvl() + 1;
	if level >= MountConsts.MountLevelMax then
		objSwf.btnNext.disabled = true;
	end
	self.currentShowLevel = level;
	
	--临时处理 使用特殊皮肤时不允许预览上下阶
	if level > MountConsts.SpecailDownid then
		objSwf.btnPre.disabled = true;
		objSwf.btnNext.disabled = true;
	end
	
	local modelId = MountUtil:GetPlayerMountModelId(level)
	
	local modelCfg = t_mountmodel[modelId];
	if not modelCfg then
		Error("Cannot find config of MountModel. id:"..modelId);
		return;
	end
	if not self.objUIDraw then
		if not viewMountPort then viewMountPort = _Vector2.new(1500, 800); end
		self.objUIDraw = UISceneDraw:new( "MountBaseUI", objSwf.modelload, viewMountPort);
	end
	self.objUIDraw:SetUILoader(objSwf.modelload);
	
	-- local setUIPfxFunc = function()
		-- if modelCfg.effect and modelCfg.effect ~= ""then
			-- self.objUIDraw:PlayNodePfx( cfg.ui_node, modelCfg.effect);
		-- end
	-- end
	local ui_sen = MountUtil:GetMountSen(cfg.ui_sen,MainPlayerModel.humanDetailInfo.eaProf);
	local ui_node =  MountUtil:GetMountSen(cfg.ui_node,MainPlayerModel.humanDetailInfo.eaProf);
	
	if showActive then
		self.objUIDraw:SetScene( ui_sen, function()
			local aniName = modelCfg.san_show;
			if not aniName or aniName == "" then return end
			if not cfg.ui_node then return end
			local nodeName = split(ui_node, "#")
			if not nodeName or #nodeName < 1 then return end
				
			for k,v in pairs(nodeName) do
				self.objUIDraw:NodeAnimation( v, aniName );
			end
		end );
	else
		self.objUIDraw:SetScene( ui_sen, nil );
	end
	self.objUIDraw:NodeVisible(ui_node,true);
	self.objUIDraw:SetDraw( true );
	
	--播放音效
	self:PlayMountSound(level);
end;

function UIMountBasic:PlayMountSound(level)
	local soundid = MountUtil:GetMountSound(level,MainPlayerModel.humanDetailInfo.eaProf);
	if soundid > 0 then
		SoundManager:PlaySfx(soundid);
	end
end

---------------------------以下是装备处理--------------------------------------
--显示装备
function UIMountBasic:ShowEquip()
	local objSwf = self:GetSWF("UIMountBasic");
	if not objSwf then return; end
	self.list = BagUtil:GetBagItemList(BagConsts.BagType_Horse,BagConsts.ShowType_All);
    objSwf.list.dataProvider:cleanUp();
	for i,slotVO in ipairs(self.list) do
		objSwf.list.dataProvider:push(slotVO:GetUIData());
	end
	objSwf.list:invalidateData();
end

--获取指定位置的Item,飞图标用
function UIMountBasic:GetItemAtPos(pos)
	if not self.isFullShow then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local uiSlot = objSwf.list:getRendererAt(pos);
	return uiSlot;
end

--添加Item
function UIMountBasic:DoAddItem(pos)
	local bagVO = BagModel:GetBag(BagConsts.BagType_Horse);
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
function UIMountBasic:DoRemoveItem(pos)
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
function UIMountBasic:DoUpdateItem(pos)
	local bagVO = BagModel:GetBag(BagConsts.BagType_Horse);
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

function UIMountBasic:OnItemRollOver(item)
	local data = item:GetData();
	if not data.hasItem then
		TipsManager:ShowBtnTips(BagConsts:GetHorseEquipNameByPos(data.pos));
		return;
	end
	TipsManager:ShowBagTips(BagConsts.BagType_Horse,data.pos);
end

function UIMountBasic:OnItemRollOut(item)
	TipsManager:Hide();
end

function UIMountBasic:OnItemDragBegin(item)
	TipsManager:Hide();
end

function UIMountBasic:OnItemDragIn(fromData,toData)
	--来自背包的
	if fromData.bagType == BagConsts.BagType_Bag then
		--判断是否是装备
		if BagUtil:GetItemShowType(fromData.tid) ~= BagConsts.ShowType_Equip then
			return;
		end
		--判断装备位是否相同
		if BagUtil:GetEquipType(fromData.tid) ~= BagUtil:GetEquipAtBagPos(BagConsts.BagType_Horse,toData.pos) then
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
function UIMountBasic:OnItemClick(item)
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
		UIBagQuickEquitView:Open(item.mc, BagConsts.BagType_Horse, itemData.pos+20, itemData.pos+20);
		return;
	end
	if _sys:isKeyDown(_System.KeyCtrl) then
		ChatQuickSend:SendItem(BagConsts.BagType_Horse,itemData.pos);
		return;
	end
	
	UIBagQuickEquitView:Open(item.mc, BagConsts.BagType_Horse, itemData.pos+20, itemData.pos);
end

--双击卸载
function UIMountBasic:OnItemDoubleClick(item)
	TipsManager:Hide();
	local data = item:GetData();
	if not data.hasItem  then
		return;
	end
	BagController:UnEquipItem(BagConsts.BagType_Horse,data.pos);
end

--右键卸载
function UIMountBasic:OnItemRClick(item)
	TipsManager:Hide();
	local data = item:GetData();
	if not data.hasItem then
		return;
	end
	BagController:UnEquipItem(BagConsts.BagType_Horse,data.pos);
end
---------------------------以上是装备处理--------------------------------------



------------------------------------升阶部分-------------------------------------------------------

function UIMountBasic:ShowChengZhangInfo()
	local objSwf = self.objSwf 
	if not objSwf then return end
	
	local info = t_horse[MountModel.ridedMount.mountLevel]
	if info == nil then
		return
	end
	
	--成长星
	self:ShowChengZhangXing(MountModel.ridedMount.mountStar)
	
	--成长进度
	local curprogress = MountUtil:GetCurXingProgress(MountModel.ridedMount.mountLevel, MountModel.ridedMount.starProgress);
	objSwf.mountupPanel.siPro:setProgress( curprogress, info.wish_max / MountConsts.MountStarMax )
	
	  objSwf.mountupPanel.starvalue.htmlText=curprogress.."/"..info.wish_max / MountConsts.MountStarMax;
	--objSwf.mountupPanel.proleftLoader:drawStr( tostring(curprogress) );
	--objSwf.mountupPanel.prorightLoader:drawStr( tostring(info.wish_max / MountConsts.MountStarMax) );
	
	self:UpdateToolInfo();
end

--显示成长信息
function UIMountBasic:ShowChengZhangXing(xingji)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	xingji = MountModel.ridedMount.mountStar;
	
	objSwf.mountupPanel.noxing1.visible = true
	objSwf.mountupPanel.noxing2.visible = true
	objSwf.mountupPanel.noxing3.visible = true
	objSwf.mountupPanel.noxing4.visible = true
	objSwf.mountupPanel.noxing5.visible = true
	objSwf.mountupPanel.xing1.visible = false
	objSwf.mountupPanel.xing2.visible = false
	objSwf.mountupPanel.xing3.visible = false
	objSwf.mountupPanel.xing4.visible = false
	objSwf.mountupPanel.xing5.visible = false

	if xingji > 0 then
		objSwf.mountupPanel.xing1.visible = true
		objSwf.mountupPanel.noxing1.visible = false
	end
	if xingji >1 then
		objSwf.mountupPanel.xing2.visible = true
		objSwf.mountupPanel.noxing2.visible = false
	end
	if xingji >2 then
		objSwf.mountupPanel.xing3.visible = true
		objSwf.mountupPanel.noxing3.visible = false
	end
	if xingji > 3 then
		objSwf.mountupPanel.xing4.visible = true
		objSwf.mountupPanel.noxing4.visible = false
	end
	if xingji > 4 then
		objSwf.mountupPanel.xing5.visible = true
		objSwf.mountupPanel.noxing5.visible = false
	end
end

--道具变化通知更新
function UIMountBasic:UpdateToolInfo()
	local objSwf = self.objSwf 
	if not objSwf then return end
	
	local info = t_horse[MountModel.ridedMount.mountLevel]
	if info == nil then
		return
	end
	objSwf.mountupPanel.tfconstom.htmlText = UIStrConfig["mount21"];

	--进阶石是否足够
	local itemId, itemNum, isEnough = MountUtil:GetConsumeItem(MountModel.ridedMount.mountLevel);
	--进阶石足够
	local itemCfg = t_item[itemId];
	local itemName = itemCfg and itemCfg.name or "";
	local bagnum=BagModel:GetItemNumInBag(itemId);
	local labelItemColor = BagModel:GetItemNumInBag( itemId ) >= itemNum and "#00ff00" or "#ff0000";
	
	if isEnough then
	
		objSwf.mountupPanel.btnLingLiNum1.htmlLabel = string.format( StrConfig['Mount102'], itemName..itemNum)
		objSwf.mountupPanel.consumeNum.htmlText= string.format(StrConfig['Mount135'],bagnum);
	else
		objSwf.mountupPanel.btnLingLiNum1.htmlLabel = string.format( StrConfig['Mount103'], itemName..itemNum)
		 objSwf.mountupPanel.consumeNum.htmlText= string.format(StrConfig['Mount136'],bagnum);
	end
	objSwf.mountupPanel.checkZiDong.htmlLabel = string.format( StrConfig['mount23'], UIStrConfig['mount26']);
	self:UpdateBtnEffect();
end

function UIMountBasic:UpdateBtnEffect()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	
	local auto = false;
	if objSwf.mountupPanel.checkZiDong.selected == true then
		auto = true;
	end
	
	local isjinjie = MountUtil:GetIsCanJinJie(0,auto,MountModel.ridedMount.mountLevel);
     if isjinjie then 
   	 objSwf.mountupPanel.btnJinJie:showEffect(ResUtil:GetButtonEffect10())
	 objSwf.mountupPanel.btnZiDongJinJie:showEffect(ResUtil:GetButtonEffect10())
     else
     objSwf.mountupPanel.btnJinJie:clearEffect();
	 objSwf.mountupPanel.btnZiDongJinJie:clearEffect();
    end
end

--播放进度条特效
function UIMountBasic:PlayProcessEffect() -- todo1
	local objSwf = self.objSwf
	if not objSwf then return end
	
	local info = t_horse[MountModel.ridedMount.mountLevel];
	if info == nil then
		return;
	end
	
	local curprogress = MountUtil:GetCurXingProgress(MountModel.ridedMount.mountLevel, MountModel.ridedMount.starProgress);
	if self.oldstar < MountModel.ridedMount.mountStar then
		self.oldstar = MountModel.ridedMount.mountStar;
		objSwf.mountupPanel.siPro:setProgress( 0, info.wish_max / MountConsts.MountStarMax )
	end
	objSwf.mountupPanel.siPro:tweenProgress( curprogress, info.wish_max / MountConsts.MountStarMax, 0 )
end

--更新进度值
function UIMountBasic:UpdateChengZhangNum()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	local info = t_horse[MountModel.ridedMount.mountLevel];
	if info == nil then
		return;
	end
	
	local curprogress = MountUtil:GetCurXingProgress(MountModel.ridedMount.mountLevel, MountModel.ridedMount.starProgress);
	objSwf.mountupPanel.starvalue.htmlText=curprogress.."/"..info.wish_max / MountConsts.MountStarMax;
	--objSwf.mountupPanel.proleftLoader:drawStr( tostring(curprogress) );
	--objSwf.mountupPanel.prorightLoader:drawStr( tostring(info.wish_max / MountConsts.MountStarMax) );
end

--显示(成功进阶+26)
function UIMountBasic:ShowUpShuZhi(addProgress,uptype)
	local objSwf = self.objSwf
	if not objSwf then return end
	--objSwf.mountupPanel.mountdoubleeffect:stopEffect();
	if uptype == 1 then
		FloatManager:AddNormal( string.format(StrConfig["mount106"], addProgress) , objSwf.mountupPanel.btnnumaddshow)
	else
		local pos = UIManager:PosLtoG(objSwf.mountupPanel.doubleLoader,0,0);
		UIBingNuFloat:PlayEffect(ResUtil:GetChengZhangDoubleUrl(),pos,addProgress);
	end
end

--显示坐骑升阶成功特效
function UIMountBasic:ShowMountUpSucEffect()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	
	self:UpdateMountUpInfo()
	
	MountController:SucCancelUpZiDong();
	
	--关闭坐骑面板
	UIMount:Hide();
end

--更新升阶后
function UIMountBasic:UpdateMountUpInfo()
	--更新新坐骑信息
	--UIMountBasic:ShowChengZhangInfo();
	--展示新坐骑
	UIMountShowView:OpenPanel(MountModel:GetMountLvl());
end

--显示自动进阶按钮
function UIMountBasic:ShowbtnZiDong(bshow)
	local objSwf = self.objSwf 
	if not objSwf then return end
	
	self:ShowZiDongNextAttrInfo();
	
	--如果当前正在自动进阶
	if MountController.biszidongup == 1 then
		objSwf.mountupPanel.btnCancel.visible = true
		objSwf.mountupPanel.btnZiDongJinJie.visible = false
		return;
	end
	
	if bshow == true then
		objSwf.mountupPanel.btnCancel.visible = false
		objSwf.mountupPanel.btnZiDongJinJie.visible = true
	else
		objSwf.mountupPanel.btnCancel.visible = true
		objSwf.mountupPanel.btnZiDongJinJie.visible = false
	end
end

--自动进阶时显示增加属性
function UIMountBasic:ShowZiDongNextAttrInfo()
	if self.currentShowLevel > MountModel.ridedMount.mountLevel then
		return;
	end
	--如果当前正在自动进阶
	if MountController.biszidongup == 1 then
		self:ShowNextAttrInfo();
	else
		self:ShowCurAttrInfo();
	end
end

--材料不足提示信息
function UIMountBasic:LackToolInfo(body)
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	--进阶石不足
	if body.type == 1 then
		local itemId, itemNum, isEnough = MountUtil:GetConsumeItem(MountModel.ridedMount.mountLevel);
        UIQuickBuyConfirm:Open(self,itemId);
		--FloatManager:AddNormal( StrConfig["mount4"], objSwf.mountupPanel.btnZiDongJinJie);

	--银两不足
	elseif body.type == 2 then
		
		FloatManager:AddNormal( StrConfig["mount11"], objSwf.mountupPanel.btnZiDongJinJie);



	--灵力不足
	elseif body.type == 3 then
		--FloatManager:AddNormal( StrConfig["mount20"], objSwf.mountupPanel.btnZiDongJinJie);
	end
	
	self:ShowbtnZiDong(true);
end

--显示升星特效
function UIMountBasic:ShowUpEffect(xinglvl)
	local objSwf = self.objSwf;
	if not objSwf then return end;
	
	if xinglvl == 5 then
		return;
	end

	objSwf.mountupPanel["feixingeffect"..xinglvl]._visible = true;
	objSwf.mountupPanel["feixingeffect"..xinglvl]:playEffect(1);
end

--聚曝后显示星
function UIMountBasic:UpdateMountXingLvl()
	local objSwf = UIMountBasic.objSwf;
	if not objSwf then return end;
	
	--更新进度
	UIMountBasic:UpdateProcess();
	
	--显示当前星--聚曝期间继续进阶会出现错误，所以改成直接显示当前星级
	UIMountBasic:ShowChengZhangXing(MountModel.ridedMount.mountStar);
	UIMountBasic.xinglvl = 0;
end

function UIMountBasic:OnNumLeftComplete()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.mountupPanel.proleftLoader._x = objSwf.mountupPanel.bar._x - objSwf.mountupPanel.proleftLoader.width - 5
end

function UIMountBasic:OnNumRightComplete()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.mountupPanel.prorightLoader._x = objSwf.mountupPanel.bar._x + objSwf.mountupPanel.bar._width
end

function UIMountBasic:OnSiProTweenComplete()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	--objSwf.mountupPanel.shineEffect1:playEffect(2)
end

UIMountBasic.lastSendTime = 0;
--升阶
function UIMountBasic:OnBtnJinJieClick()

	self:OnGuideClick()
	
	local objSwf = self.objSwf 
	if not objSwf then return end
	
	--点击间隔
	if GetCurTime() - self.lastSendTime < 100 then
		return;
	end
	self.lastSendTime = GetCurTime();

	local nBuyType = 0
	if objSwf.mountupPanel.checkZiDong.selected == true then
		nBuyType = 1
	end
	
	if nBuyType == 0 then
		--材料不足
		if MountUtil:GetIsJinJieBytool(MountModel.ridedMount.mountLevel) == 0 then

			local itemId, itemNum, isEnough = MountUtil:GetConsumeItem(MountModel.ridedMount.mountLevel);
            UIQuickBuyConfirm:Open(self,itemId);
		--	FloatManager:AddNormal( StrConfig["mount4"], objSwf.mountupPanel.btnJinjie);
			
			return;
		end
	else
		--材料不足 元宝不足
		if MountUtil:GetIsJinJieBytool(MountModel.ridedMount.mountLevel) == 0 and MountUtil:GetIsJinJieByMoney(MountModel.ridedMount.mountLevel) == 0 then
			FloatManager:AddNormal( StrConfig["mount4"], objSwf.mountupPanel.btnJinjie);
			
			return;
		end
	end

	--银两不足
	if MountUtil:GetIsJinJieByYinLiang(MountModel.ridedMount.mountLevel) == 0 then
		FloatManager:AddNormal( StrConfig["mount11"], objSwf.mountupPanel.btnJinjie);
		return;
	end

	MountController.bstopzidongup = 1
	MountController:BuyMountUpTool(0 ,nBuyType)
end

--自动升阶
function UIMountBasic:OnBtnZiDongJinJieClick()
	self:OnGuideClick()

	local objSwf = self.objSwf 
	if not objSwf then return end	
	local nBuyType = 0  --没有选中自动从商店购买
	if objSwf.mountupPanel.checkZiDong.selected == true then
		nBuyType = 1    --选中
	end
	
	if nBuyType == 0 then
		--材料不足
		if MountUtil:GetIsJinJieBytool(MountModel.ridedMount.mountLevel) == 0 then

			local itemId, itemNum, isEnough = MountUtil:GetConsumeItem(MountModel.ridedMount.mountLevel);
            UIQuickBuyConfirm:Open(self,itemId);

			--FloatManager:AddNormal( StrConfig["mount4"], objSwf.mountupPanel.btnZiDongJinJie);
			return;
		end
	else
		--材料不足 元宝不足
		if MountUtil:GetIsJinJieBytool(MountModel.ridedMount.mountLevel) == 0 and MountUtil:GetIsJinJieByMoney(MountModel.ridedMount.mountLevel) == 0 then
			FloatManager:AddNormal( StrConfig["mount4"], objSwf.mountupPanel.btnZiDongJinJie);
			return;
		end
	end
	
	--银两不足
	if MountUtil:GetIsJinJieByYinLiang(MountModel.ridedMount.mountLevel) == 0 then
		FloatManager:AddNormal( StrConfig["mount11"], objSwf.mountupPanel.btnZiDongJinJie);
		return;
	end
	
	if MountController:MountUpZiDong(0,nBuyType) == 1 then
		--显示取消自动进阶按钮
		self:ShowbtnZiDong(false)
	end
end

--切换checkBox
function UIMountBasic:OnCBoxClick()
	local objSwf = self.objSwf 
	if not objSwf then return end
	
	MountController:SucCancelUpZiDong();
	
	self:UpdateBtnEffect();
end

--取消自动升阶
function UIMountBasic:OnBtnCancel()
	MountController:SucCancelUpZiDong()
end

---------------------------------tip------------------------------------
--鼠标悬浮属性名
function UIMountBasic:OnbtntipRollOver()
	local tipsTxt = "";
	tipsTxt = StrConfig["Mount101"];
	TipsManager:ShowTips( TipsConsts.Type_Normal, tipsTxt, TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
	
	self:ShowNextAttrInfo();
end

--鼠标悬浮属性名
function UIMountBasic:OnbtnJinJieDanRollOver()
	local objSwf = self.objSwf
	
	local itemId, itemNum, isEnough = MountUtil:GetConsumeItem(MountModel.ridedMount.mountLevel);
	if itemId > 0 then
		TipsManager:ShowItemTips(itemId)
	end
end

function UIMountBasic:OnTipsAreaRollOver()
	--TipsManager:ShowBtnTips( string.format( StrConfig["mount19"], MountModel.ridedMount.starProgress ) );
end

function UIMountBasic:ShowJinJieGoldTip()
	local objSwf = self.objSwf 
	if not objSwf then return end
	
	local info = t_horse[MountModel.ridedMount.mountLevel]
	if info == nil then
		return 0;
	end
	
	local strconstom = "";
	local toolItem = t_item[info.consume_item[1]];
	strconstom = toolItem.name..info.consume_item[2].."颗";
	
	TipsManager:ShowBtnTips( string.format( StrConfig["mount26"], strconstom, info.consume_money ),TipsConsts.Dir_RightDown);
	
	self.preShowLevel = self.currentShowLevel;
	if self.currentShowLevel == MountModel.ridedMount.mountLevel + 1 then
		return;
	end
	--模型
	self:DrawMount(MountModel.ridedMount.mountLevel + 1, true)
	
	self:ShowNextMountInfo(MountModel.ridedMount.mountLevel + 1);
end

function UIMountBasic:ShowJinJieGoldTipOut()
	TipsManager:Hide();
	
	if self.preShowLevel == MountModel.ridedMount.mountLevel + 1 then
		return;
	end
	
	--模型
	self:DrawMount(self.preShowLevel, true)
	
	self:ShowNextMountInfo(self.preShowLevel);
	
	self.preShowLevel = nil;
end

function UIMountBasic:InitUI()
	local objSwf = self.objSwf 
	if not objSwf then return end
	
	local info = t_horse[MountModel.ridedMount.mountLevel]
	if info == nil then
		return
	end
	
	objSwf.mountupPanel.tfconstom.text = UIStrConfig["mount21"];
	--进阶石不足的时候
	if MountUtil:GetIsJinJieBytool(MountModel.ridedMount.mountLevel) ~= 1 then
		objSwf.mountupPanel.checkZiDong.selected = false;
	end
	
	UIMountShowView:Hide();
end

--更新进度
function UIMountBasic:UpdateProcess()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	local info = t_horse[MountModel.ridedMount.mountLevel];
	if info == nil then
		return;
	end
	
	--成长星
	self:ShowChengZhangXing(MountModel.ridedMount.mountStar)

	--成长进度
	self:PlayProcessEffect();
	self:UpdateChengZhangNum();
end

function UIMountBasic:PlayStarSuccessAninal()
	local objUIDraw = self.objUIDraw
	if not objUIDraw then return end
	if not objUIDraw.sceneLoaded then return; end
	if not objUIDraw.objScene then return; end
	local lv = MountModel.ridedMount.mountLevel
	if not lv then return end

	local cfg = t_horse[lv]
	if not cfg then return end

	local skl = split(cfg.stranimationskl, "#")
	local ani = split(cfg.stranimation, "#")
	if #skl == 1 then
		skl = skl[1]
		ani = ani[1]
	else
		skl = split(skl[MainPlayerModel.humanDetailInfo.eaProf], ",")
		skl = skl[2]
		ani = split(ani[MainPlayerModel.humanDetailInfo.eaProf], ",")
		ani = ani[2]
	end
	local nodes = objUIDraw.objScene:getNodes();
	local node = nil
	for i,v in ipairs(nodes) do
		if v.mesh and v.mesh.skeleton and v.name:find(skl) then
			node = v;
			break;
		end
	end

	if not node then return; end
	local anima = node.mesh.skeleton:getAnima(ani);
	if not anima then
		anima = node.mesh.skeleton:addAnima(ani);
	end
	if not anima then
		print(ani)
	end

	anima:play();
end

function UIMountBasic:PlayPillSuccessAninal()
	local objUIDraw = self.objUIDraw
	if not objUIDraw then return end
	if not objUIDraw.sceneLoaded then return; end
	if not objUIDraw.objScene then return; end
	local lv = MountModel.ridedMount.mountLevel
	if not lv then return end

	local cfg = t_horse[lv]
	if not cfg then return end

	local skl = split(cfg.attanimationskl, "#")
	local ani = split(cfg.attanimation, "#")
	if #skl == 1 then
		skl = skl[1]
		ani = ani[1]
	else
		skl = split(skl[MainPlayerModel.humanDetailInfo.eaProf], ",")
		skl = skl[2]
		ani = split(ani[MainPlayerModel.humanDetailInfo.eaProf], ",")
		ani = ani[2]
	end
	local nodes = objUIDraw.objScene:getNodes();
	local node = nil
	for i,v in ipairs(nodes) do
		if v.mesh and v.mesh.skeleton and v.name:find(skl) then
			node = v;
			break;
		end
	end

	if not node then return; end
	local anima = node.mesh.skeleton:getAnima(ani);
	if not anima then
		anima = node.mesh.skeleton:addAnima(ani);
	end
	if not anima then
		print(ani)
	end

	anima:play();
end
---------------------------------------------------------------------------------------------

----------------------------------  点击任务接口 ----------------------------------------

function UIMountBasic:OnGuideClick()
	QuestController:TryQuestClick( QuestConsts.MountLvlUpClick )
end

------------------------------------------------------------------------------------------
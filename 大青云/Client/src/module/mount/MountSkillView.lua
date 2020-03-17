--[[
坐骑技能
zhangshuhui
2014年11月26日13:20:20
]]

_G.UIMountSkill = BaseUI:new("UIMountSkill")

UIMountSkill.vo = {}
UIMountSkill.skillid = 0

function UIMountSkill:Create()
	self:AddSWF("mountskillPanel.swf", true, "top")
end

function UIMountSkill:OnLoaded(objSwf)
	--关闭
	objSwf.btnclose.click = function() self:OnBtnCancel()  end
	--学习
	objSwf.btnstudy.click = function() self:OnBtnstudyclick()  end
	--升级
	objSwf.btnup.click = function() self:OnBtnupclick()  end
	
	objSwf.btnskill.rollOver = function() self:OnbtnskillRollOver(); end
	objSwf.btnskill.rollOut = function() TipsManager:Hide(); end
	
	objSwf.toolitem.rollOver = function(e) self:OnItemRollOver(e); end
	objSwf.toolitem.rollOut = function() TipsManager:Hide(); end
end

function UIMountSkill:OnBtnCancel()
	self:Hide()
	self.vo = {}
end

function UIMountSkill:OnHide()
	self.uiPanel    = nil;
	self.panelWidth = nil;
	self.offsetY    = nil;
	self.posX 		= nil;
	self.posY		= nil;
end
function UIMountSkill:OnBtnstudyclick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local listvo = MountUtil:GetSkillListVO(self.vo.skillId,self.vo.lvl)
	
	--未学习
	if self.vo.lvl == 1 then
		--学习条件
		local str = listvo.needItem;
		local strvo = MountUtil:Parse(str)
		local itemNum = BagModel:GetItemNumInBag(strvo.itemid)
		--达到学习条件
		if MountUtil:GetCanLvlUpDzz(self.vo.skillId, true) == true then
			SkillController:LearnSkill(self.vo.skillId)
		else
			FloatManager:AddNormal( StrConfig["mount8"], objSwf.btnstudy);
		end
	end
end
function UIMountSkill:OnBtnupclick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local listvo = MountUtil:GetSkillListVO(self.vo.skillId,self.vo.lvl)
	
	if self.vo.lvl > self.vo.maxLvl then
		FloatManager:AddNormal( StrConfig["mount10"], objSwf.btnup);
		return
	end
	
	--已学习
	if self.vo.lvl > 1 then
		--升级条件
		local str = listvo.needItem;
		local strvo = MountUtil:Parse(str)
		local itemNum = BagModel:GetItemNumInBag(strvo.itemid)
		--达到升级条件
		if MountUtil:GetCanLvlUpDzz(self.skillid) == true then
			SkillController:LvlUpSkill(self.skillid)
		else
			FloatManager:AddNormal( StrConfig["mount9"], objSwf.btnup);
		end
	end
end

function UIMountSkill:OnbtnskillRollOver()
	local skillId = self.skillid;
	local get = self.vo.lvl > 1;
	TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=skillId,condition=true,get=get},TipsConsts.ShowType_Normal,
						TipsConsts.Dir_RightDown);
end

function UIMountSkill:OnItemRollOver(e)
	local target = e.target;
	if target.data and target.data.id then
		TipsManager:ShowItemTips( target.data.id);
	end
end

function UIMountSkill:OnbtnskillbookRollOver()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local str = self.vo.needItem;
	local strvo = MountUtil:Parse(str)
	TipsManager:ShowItemTips(strvo.itemid)
end

--显示
function UIMountSkill:OnShow()
	self:ShowSkillInfo()
end

---------------------------------消息处理------------------------------------
function UIMountSkill:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.SkillLearn then
		self:UpdateSkillInfo(body)
	elseif name == NotifyConsts.SkillLvlUp then
		self:UpdateSkillInfo(body)
	elseif name == NotifyConsts.BagItemNumChange then
		self:UpdateBagChange()
	elseif name == NotifyConsts.MountLvUpSucChanged then
		self:ShowSkillInfo()
	end
end

function UIMountSkill:ListNotificationInterests()
	return {NotifyConsts.SkillLearn,
			NotifyConsts.SkillLvlUp,
			NotifyConsts.BagItemNumChange,
			NotifyConsts.MountLvUpSucChanged};
end

function UIMountSkill:UpdateSkillInfo(body)
	--学习提示
	if self.vo.lvl <= 1 then
		FloatManager:AddNormal(StrConfig["mount17"]);
	end
	
	self.vo = MountUtil:GetNextMountLvlSkillId(self.vo)
	
	--如果已经是最高级，直接关闭
	if not self.vo then
		self:OnBtnCancel();
		return;
	end
	self.skillid = body.skillId;
	self:ShowSkillInfo()
end

function UIMountSkill:ShowSkillInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	if not self.vo then
		return;
	end
	
	objSwf.btnstudy.visible = false
	objSwf.btnup.visible = false
	
	--图标
	objSwf.btnskill.iconskill.source = ResUtil:GetSkillIconUrl(self.vo.icon,"54");
	
	--道具图标
	local str = self.vo.needItem;
	local strvo = MountUtil:Parse(str)
	
	local slotVO = RewardSlotVO:new();
	slotVO.id = strvo.itemid;
	slotVO.count = 0;
	objSwf.toolitem:setData( slotVO:GetUIData() );
	
	--道具图标
	local str = self.vo.needItem;
	local strvo = MountUtil:Parse(str)
	local toolItem = t_item[strvo.itemid]
	if toolItem == nil then
		return
	end
	
	--消耗道具
	local itemNum = BagModel:GetItemNumInBag(strvo.itemid)
	
	--没有学习
	if self.vo.lvl == 1 then
		objSwf.btnstudy.visible = true
		
		local skillinfo = string.format( StrConfig['mount107'], self.vo.name,1)
		objSwf.tfskillinfo.htmlText = skillinfo
		
		if itemNum < strvo.num then
			local skilltool = string.format( StrConfig['mount111'],t_item[strvo.itemid].name,itemNum,strvo.num)
			objSwf.tfbookinfo.htmlText = skilltool
		else
			local skilltool = string.format( StrConfig['mount112'],t_item[strvo.itemid].name,itemNum,strvo.num)
			objSwf.tfbookinfo.htmlText = skilltool
		end
		
		--学习条件
		if self.vo.needSpecail > MountModel.ridedMount.mountLevel then
			local skilltiaojian = string.format( StrConfig['mount109'], self.vo.needSpecail)
			objSwf.tfskilltiaojian.htmlText = skilltiaojian
		else
			local skilltiaojian = string.format( StrConfig['mount110'], self.vo.needSpecail)
			objSwf.tfskilltiaojian.htmlText = skilltiaojian
		end
	else
		objSwf.btnup.visible = true
		
		local skillinfo = string.format( StrConfig['mount108'], self.vo.name,self.vo.lvl - 1)
		objSwf.tfskillinfo.htmlText = skillinfo
		
		
		if itemNum < strvo.num then
			local skilltool = string.format( StrConfig['mount111'],t_item[strvo.itemid].name,itemNum,strvo.num)
			objSwf.tfbookinfo.htmlText = skilltool
		else
			local skilltool = string.format( StrConfig['mount112'],t_item[strvo.itemid].name,itemNum,strvo.num)
			objSwf.tfbookinfo.htmlText = skilltool
		end
		
		--升级条件
		if self.vo.needSpecail > MountModel.ridedMount.mountLevel then
			local skilltiaojian = string.format( StrConfig['mount116'], self.vo.needSpecail)
			objSwf.tfskilltiaojian.htmlText = skilltiaojian
		else
			local skilltiaojian = string.format( StrConfig['mount117'], self.vo.needSpecail)
			objSwf.tfskilltiaojian.htmlText = skilltiaojian
		end
	end
end

function UIMountSkill:UpdateBagChange()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	if not self.vo then
		return;
	end
	
	--道具图标
	local str = self.vo.needItem;
	local strvo = MountUtil:Parse(str)
	local toolItem = t_item[strvo.itemid]
	if toolItem == nil then
		return
	end
	
	--消耗道具
	local itemNum = BagModel:GetItemNumInBag(strvo.itemid)
	
	--没有学习
	if self.vo.lvl == 1 then
		objSwf.btnstudy.visible = true
		
		local skillinfo = string.format( StrConfig['mount107'], self.vo.name,1)
		objSwf.tfskillinfo.htmlText = skillinfo
		
		if itemNum < strvo.num then
			local skilltool = string.format( StrConfig['mount111'],t_item[strvo.itemid].name,itemNum,strvo.num)
			objSwf.tfbookinfo.htmlText = skilltool
		else
			local skilltool = string.format( StrConfig['mount112'],t_item[strvo.itemid].name,itemNum,strvo.num)
			objSwf.tfbookinfo.htmlText = skilltool
		end
		
		--学习条件
		if self.vo.needSpecail > MountModel.ridedMount.mountLevel then
			local skilltiaojian = string.format( StrConfig['mount109'], self.vo.needSpecail)
			objSwf.tfskilltiaojian.htmlText = skilltiaojian
		else
			local skilltiaojian = string.format( StrConfig['mount110'], self.vo.needSpecail)
			objSwf.tfskilltiaojian.htmlText = skilltiaojian
		end
	else
		objSwf.btnup.visible = true
		
		local skillinfo = string.format( StrConfig['mount108'], self.vo.name,self.vo.lvl - 1)
		objSwf.tfskillinfo.htmlText = skillinfo
		
		
		if itemNum < strvo.num then
			local skilltool = string.format( StrConfig['mount111'],t_item[strvo.itemid].name,itemNum,strvo.num)
			objSwf.tfbookinfo.htmlText = skilltool
		else
			local skilltool = string.format( StrConfig['mount112'],t_item[strvo.itemid].name,itemNum,strvo.num)
			objSwf.tfbookinfo.htmlText = skilltool
		end
		
		--升级条件
		if self.vo.needSpecail > MountModel.ridedMount.mountLevel then
			local skilltiaojian = string.format( StrConfig['mount116'], self.vo.needSpecail)
			objSwf.tfskilltiaojian.htmlText = skilltiaojian
		else
			local skilltiaojian = string.format( StrConfig['mount117'], self.vo.needSpecail)
			objSwf.tfskilltiaojian.htmlText = skilltiaojian
		end
	end
end

function UIMountSkill:Update( interval )
	if not self.bShowState then return; end
	if not self.parent then return; end
	if not self.parent:IsShow() then
		self:Hide();
		return;
	end
	
	local posX, posY = self.parent.parent:GetPos();
	if self.posX ~= posX or self.posY ~= posY then
		self.posX, self.posY = posX, posY;
		self:SetPos(0, 0);
		self:Top();
	end
end
--[[
跨服副本面板
liyuan
]]

_G.UIInterServiceBossAddBlood = BaseUI:new("UIInterServiceBossAddBlood");
UIInterServiceBossAddBlood.cdTime = 0
UIInterServiceBossAddBlood.lastTime = 0
UIInterServiceBossAddBlood.isSend = false
function UIInterServiceBossAddBlood:Create()
	self:AddSWF("interServiceBossAddBlood.swf", true, "interserver");
end

function UIInterServiceBossAddBlood:OnLoaded(objSwf)
	local constCfg = t_consts[168]
	if constCfg then
		self.cdTime = constCfg.val2*1000
	end
	objSwf.btnSkill.click = function() 
		self:OnSkillClick()
	end
	
	objSwf.btnSkill.mcKeyDown._visible = false
	
	objSwf.btnSkill.rollOver = function()
		local tipsTxt = '使用后恢复50%生命。<br/>CD：20秒<br/>快捷键：T'
		TipsManager:ShowTips( TipsConsts.Type_Normal, tipsTxt, TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
	end
	objSwf.btnSkill.rollOut = function() TipsManager:Hide();  end
end

function UIInterServiceBossAddBlood:OnSkillClick()
	if not self:IsShow() then
		return
	end 
	local objSwf = self.objSwf 
	if not objSwf then return end	

	if self.isSend then return end
	local curhp = MainPlayerModel.humanDetailInfo.eaHp
	local alhp = MainPlayerModel.humanDetailInfo.eaMaxHp	
	if curhp >= alhp then 
		return
	end;
	
	local NowTime = GetCurTime()
	if NowTime - self.lastTime > self.cdTime then
		self.isSend = true
		InterServicePvpController:ReqUseCrossHp()
	end
end

function UIInterServiceBossAddBlood:ShowSCItemKeyDown(isDown)
	if not self:IsShow() then
		return
	end 
	local objSwf = self.objSwf 
	if not objSwf then return end
	
	objSwf.btnSkill.mcKeyDown._visible = isDown
end

function UIInterServiceBossAddBlood:UpdateCD(isSucc)
	local objSwf = self.objSwf 
	if not objSwf then return end
	
	self.isSend = false
	if not isSucc then return end
	objSwf.btnSkill.cd:playCD(self.cdTime)
	self.lastTime = GetCurTime()	
end

-----------------------------------------------------------------------
function UIInterServiceBossAddBlood:IsTween()
	return false;
end

function UIInterServiceBossAddBlood:GetPanelType()
	return 0;
end

function UIInterServiceBossAddBlood:IsShowSound()
	return false;
end

function UIInterServiceBossAddBlood:OnShow()
		
end

function UIInterServiceBossAddBlood:OnHide()
	
end

function UIInterServiceBossAddBlood:GetWidth()
	return 98;
end

function UIInterServiceBossAddBlood:GetHeight()
	return 73;
end

function UIInterServiceBossAddBlood:OnDelete()
	
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIInterServiceBossAddBlood:ListNotificationInterests()
	return {
		NotifyConsts.ISKuafuBossAddBlood
	};
end

--处理消息
function UIInterServiceBossAddBlood:HandleNotification(name, body)
	if not self:IsShow() then
		return
	end 

	if name == NotifyConsts.ISKuafuBossAddBlood then
		self:UpdateCD(body.isSucc)
	end
end


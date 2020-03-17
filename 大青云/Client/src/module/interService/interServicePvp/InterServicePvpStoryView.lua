--[[
跨服副本面板
liyuan
]]

_G.UIInterServicePvpStoryView = BaseUI:new("UIInterServicePvpStoryView");
UIInterServicePvpStoryView.timeId = nil
function UIInterServicePvpStoryView:Create()
	self:AddSWF("interServerStoryPanel.swf", true, "interserver");
end

function UIInterServicePvpStoryView:OnLoaded(objSwf)
	objSwf.btnHide.click = function()
		objSwf.mcbg.visible = false	
		objSwf.btnHide.visible = false
		objSwf.btnShow.visible = true
		objSwf.btnExit.visible = false
	end
	objSwf.btnShow.click = function()
		objSwf.mcbg.visible = true	
		objSwf.btnHide.visible = true
		objSwf.btnShow.visible = false
		objSwf.btnExit.visible = true
	end
	
	objSwf.btnExit.click = function() 
		if InterServicePvpController:IsBattleResult() then return end
		if self.confirmID then
			UIConfirm:Close(self.confirmID);
		end
		self.confirmID = UIConfirm:Open(StrConfig['interServiceDungeon6'],function() 
			InterServicePvpController:ReqQuitCrossFightPvp()
		end);
	end
end

function UIInterServicePvpStoryView:SetBtnBackDisabled(bDisabled)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not self:IsShow() then return end
	
	objSwf.btnExit.disabled = bDisabled
end
-----------------------------------------------------------------------
function UIInterServicePvpStoryView:IsTween()
	return false;
end

function UIInterServicePvpStoryView:GetPanelType()
	return 0;
end

function UIInterServicePvpStoryView:IsShowSound()
	return false;
end

function UIInterServicePvpStoryView:Update()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not self:IsShow() then return end
	if not InterServicePvpModel.otherRoleInfo then return end
	local roleId = InterServicePvpModel.otherRoleInfo.roleId
	local player = CPlayerMap:GetPlayer(roleId)
	if not player then return end
	
	local eaHp = toint(player.playerInfo[enAttrType.eaHp])
	local eaMaxHp = toint(player.playerInfo[enAttrType.eaMaxHp])
	objSwf.mcbg.siBlessing:setProgress( eaHp, eaMaxHp );
	objSwf.mcbg.tfblood.text = eaHp..'/'..eaMaxHp
end

function UIInterServicePvpStoryView:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end	
	local othernfo = InterServicePvpModel.otherRoleInfo
	-- objSwf.mcbg.tfName.text = othernfo.roleId
	objSwf.mcbg.tfServer.text = othernfo.groupid
	objSwf.mcbg.tfName.text = othernfo.name
	-- objSwf.mcbg.tfName.text = othernfo.prof
	local T_Name = "t_kuafudan"..Version:GetName();
	local KuaFuDanT = nil;
	if _G[T_Name] then
		KuaFuDanT = _G[T_Name];
	else
		KuaFuDanT = t_kuafudanyouxi;
		print("Error:cannot find t_kuafudan cfg by current version.")
	end
	objSwf.mcbg.tfLevel.text = "";
	local cfg = KuaFuDanT[othernfo.pvplv]
	if cfg then
		objSwf.mcbg.tfLevel.text = cfg.danName;
	end
	objSwf.mcbg.tfPower.text = othernfo.power
	self.countDownTime = othernfo.countDownTime or 0
	if self.countDownTime and self.countDownTime > 0 then
		self.timeId = TimerManager:RegisterTimer(function()
													if self.countDownTime <= 0 then TimerManager:UnRegisterTimer(self.timeId) return end
													self.countDownTime = self.countDownTime - 1		
													objSwf.mcbg.tfCountTime.text = DungeonUtils:ParseTime(self.countDownTime)
													-- if self.countDownTime <= 3 then
														-- self:PickUpItemAll()
													-- end
												end,1000,0)
	end
	
	-- objSwf.mcbg.siBlessing:setProgress( 57, 100 );
	-- objSwf.mcbg.tfblood.text = '57/100'
	objSwf.btnExit.disabled = false
end

function UIInterServicePvpStoryView:OnHide()
	if self.timeId then
		TimerManager:UnRegisterTimer(self.timeId)
		self.timeId = nil
	end
	if self.confirmID then
		UIConfirm:Close(self.confirmID);
	end
end

function UIInterServicePvpStoryView:GetWidth()
	return 247;
end

function UIInterServicePvpStoryView:GetHeight()
	return 327;
end

function UIInterServicePvpStoryView:OnBtnCloseClick()
	self:Hide();
end

function UIInterServicePvpStoryView:OnDelete()
	
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIInterServicePvpStoryView:ListNotificationInterests()
	return {
		
	};
end

--处理消息
function UIInterServicePvpStoryView:HandleNotification(name, body)
	
end


--[[
装备打造，活力值tips
wangshuai
]]

_G.UIEquipBuildTips = BaseUI:new("UIEquipBuildTips")

function UIEquipBuildTips:Create()
	self:AddSWF("equipBuildPanelTips.swf",true,"top")
end;

function UIEquipBuildTips:OnLoaded(objSwf)

end;

function UIEquipBuildTips:OnShow()
	local cfg = t_consts[68].val1;
	local val3 = t_consts[68].val3
	-- local viplvl = MainPlayerModel.humanDetailInfo.eaVIPLevel
	local vipSpeed = VipController:GetHuolizhiOnlineSpeed()
	local viplvl = VipController:GetVipLevel() + 1
	local MaxVipLvl = VipConsts:GetMaxVipLevel()
	if viplvl >= MaxVipLvl then 
		viplvl = MaxVipLvl
	end;
	local vipNextLevelSpeed = VipController:GetHuolizhiOnlineVal(nil,viplvl)
	local vipCfg = {}
	if vipSpeed <= 0 then --if viplvl <= 0 then 
		vipCfg = VipController:GetHuolizhiOnlineVal(1,1)--t_vip[1].vip_equipval;
	else
		if vipSpeed <= 0 then --if not t_vip[viplvl] then 
			cfg = 0;
		else
			cfg = vipSpeed--t_vip[viplvl].vip_equipval;
			if not cfg then 
				cfg = 0;
			end;
		end;
		if vipNextLevelSpeed <= 0 then --if not t_vip[viplvl+1] then 
			vipCfg = 0;
		else
			vipCfg = vipNextLevelSpeed--t_vip[viplvl+1].vip_equipval;
			if not vipCfg then 
				vipCfg = 0;
			end;
		end;
	end;
	local objSwf = self.objSwf;
	val3 = val3 / 60 
	if vipCfg < 0  then 
		vipCfg = 0;
	end;
	if val3 < 0 then 
		val3 = 0
	end;
	if vipSpeed <= 0 then --if viplvl <= 0 then 
		objSwf.huifu1.text = cfg..string.format(StrConfig["equipbuild018"],val3)
		objSwf.huifuV.text = vipCfg..string.format(StrConfig["equipbuild018"],val3)
	else
		objSwf.huifu1.text = cfg..string.format(StrConfig["equipbuild018"],val3)
		objSwf.huifuV.text = vipCfg..string.format(StrConfig["equipbuild018"],val3)
	end;
	self:UpdatePos();
end;

function UIEquipBuildTips:UpdatePos()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local monsePos = _sys:getRelativeMouse();--获取鼠标位置
	self.posX = monsePos.x;
	self.posY = monsePos.y;
	objSwf._x = monsePos.x + 25;
	
	if self.showtype == 0 then
		objSwf._y = monsePos.y - objSwf._height - 26;
	else
		objSwf._y = monsePos.y + 26;
	end
end

function UIEquipBuildTips:OnHide()

end;
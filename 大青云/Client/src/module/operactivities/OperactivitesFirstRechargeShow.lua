--[[
	首冲
]]

_G.UIOperactivitesFirstRechargeShow = BaseUI:new('UIOperactivitesFirstRechargeShow');

function UIOperactivitesFirstRechargeShow:Create()
	self:AddSWF('operactivitesFirstRechageShow.swf',true,'center');
end

function UIOperactivitesFirstRechargeShow:OnLoaded(objSwf)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end;
	RewardManager:RegisterListTips( objSwf.rewardList )
	
	objSwf.btnGet.click = function()
		if OperActivity1Btn:IsShow() then
			OperActUIManager:ShowHideOperActUI(OperactivitiesConsts.iconShouchong)
		else
			FPrint('首冲未开启')
		end
	end
end

function UIOperactivitesFirstRechargeShow:IsTween()
	return true
end

function UIOperactivitesFirstRechargeShow:GetPanelType()
	return 1
end

function UIOperactivitesFirstRechargeShow:IsShowSound()
	return true
end

function UIOperactivitesFirstRechargeShow:OnShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	local prof = MainPlayerModel.humanDetailInfo.eaProf; --取玩家职业
	
	local awardStr = ''
	if t_consts[124] then
		local itemId = t_consts[124].val1
		local awardList = split(t_consts[124].param,'|')
		awardStr = awardList[prof]
	end
	
	if awardStr ~= '' then
		objSwf.rewardList.dataProvider:cleanUp()
		objSwf.rewardList.dataProvider:push( unpack( RewardManager:Parse( awardStr ) ) )
		objSwf.rewardList:invalidateData()
	end
	
	self:Show3DWeapon()
end

function UIOperactivitesFirstRechargeShow:GetWidth()
	return 752
end

function UIOperactivitesFirstRechargeShow:GetHeight()
	return 374
end

function UIOperactivitesFirstRechargeShow:OnBtnCloseClick()
	self:Hide();
end


function UIOperactivitesFirstRechargeShow:OnHide()
	local name = 'UIOperactivitesFirstShow1'
	local objUIDraw1 = UIDrawManager:GetUIDraw(name);
	if self.objUIDraw1 then
		self.objUIDraw1:SetDraw(false);
	end
	
	-- name = 'UIOperactivitesFirstShow2'
	-- local objUIDraw2 = UIDrawManager:GetUIDraw(name);
	-- if self.objUIDraw2 then
		-- self.objUIDraw2:SetDraw(false);
	-- end
end

function UIOperactivitesFirstRechargeShow:OnDelete()
	local name = 'UIOperactivitesFirstShow1'
	local objUIDraw1 = UIDrawManager:GetUIDraw(name);
	if objUIDraw1 then
		objUIDraw1:SetUILoader(nil);
	end
	
	-- name = 'UIOperactivitesFirstShow2'
	-- local objUIDraw2 = UIDrawManager:GetUIDraw(name);
	-- if objUIDraw2 then
		-- objUIDraw2:SetUILoader(nil);
	-- end
end

function UIOperactivitesFirstRechargeShow:Show3DWeapon()
	local objSwf = self.objSwf
	if not objSwf then return end	
	
	local loader = objSwf.roleLoader1
	local name      = 'UIOperactivitesFirstShow1'
	if not self.objUIDraw1 then
		self.objUIDraw1 = UISceneDraw:new( name, loader, _Vector2.new(1800, 1200), true);
	end	
	self.objUIDraw1:SetUILoader( loader )	
	local src = 'sc_shenbing.sen'
	if not src then return end
	self.objUIDraw1:SetScene(src);	
	self.objUIDraw1:SetDraw(true);
	
	-- loader = objSwf.roleLoader2
	-- name      = 'UIOperactivitesFirstRechargeShow2'
	-- if not self.objUIDraw2 then
		-- self.objUIDraw2 = UISceneDraw:new( name, loader, _Vector2.new(1800, 1200), true);
	-- end	
	-- self.objUIDraw2:SetUILoader( loader )	
	-- local src = 'vip_zq_binghunma.sen'
	-- if not src then return end
	-- self.objUIDraw2:SetScene(src);	
	-- self.objUIDraw2:SetDraw(true);
end
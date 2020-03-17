--[[
    Created by IntelliJ IDEA.
    小眼睛界面
    User: Hongbin Yang
    Date: 2016/12/6
    Time: 21:40
   ]]

_G.SmallEyeView = BaseUI:new("UISmallEye");

function SmallEyeView:Create()
	self:AddSWF("mainPagesmalleye.swf", false, "highTop");
end

function SmallEyeView:OnLoaded(objSwf, name)
	objSwf.cbAll.click = function(e) self:OnAllSelect(); end
	objSwf.cbPlayer.click = function(e) self:OnPlayerSelect(); end
	objSwf.cbPlayerTianShen.click = function(e) self:OnPlayerTianShenSelect() end
	objSwf.cbPlayerMagicWeapon.click = function(e) self:OnPlayerMagicWeaponSelect() end
	objSwf.cbPlayerTitle.click = function(e) self:OnPlayerTitleSelect() end
	objSwf.cbMonster.click = function(e) self:OnMonsterSelect(); end
	objSwf.cbHp.click = function(e) self:OnHpSelect(); end

end

function SmallEyeView:OnShow()
	-- 写这个是为了和打开设置面板的时候设置一致,以免再调用设置面板中的代码时候有异常
	if not UISystemBasic.setState then
		UISetSystem.selecteNum = SetSystemModel.oldSetVal;
	end
	self:UpdateSelectedStatus();
	self:UpdateSmallEyeButton();
end

function SmallEyeView:UpdateSelectedStatus()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.cbPlayer.selected = SetSystemModel.SetModel:GetUnAllPlayerShowName();
	objSwf.cbPlayerTianShen.selected = not SetSystemModel:GetIsShowPlayerTianShen();
	objSwf.cbPlayerMagicWeapon.selected = not SetSystemModel:GetIsShowPlayerMagicWeapon();
	objSwf.cbPlayerTitle.selected = SetSystemModel.SetModel:GerIsShowTitle();
	objSwf.cbMonster.selected = SetSystemModel.SetModel:GetIsShowCommonMonster();
	objSwf.cbHp.selected = SetSystemModel.SetModel:GetIsOpenFlash();

	self:UpdateAllSelectedStatus();
end

function SmallEyeView:UpdateAllSelectedStatus()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if objSwf.cbPlayer.selected and
			objSwf.cbPlayerTianShen.selected and
			objSwf.cbPlayerMagicWeapon.selected and
			objSwf.cbPlayerTitle.selected and
			objSwf.cbMonster.selected and
			objSwf.cbHp.selected then
		objSwf.cbAll.selected = true;
	else
		objSwf.cbAll.selected = false;
	end
end

function SmallEyeView:OnAllSelect()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local allSelected = objSwf.cbAll.selected;
	if objSwf.cbPlayer.selected ~= allSelected then
		objSwf.cbPlayer.selected = allSelected;
		UISetSystem:OnPlayerChangeNum(SetSystemConsts.UNSHOWNUMNAME)
	end
	if objSwf.cbPlayerTianShen.selected ~= allSelected then
		objSwf.cbPlayerTianShen.selected = allSelected
		self:OnPlayerTianShenSelect();
	end
	if objSwf.cbPlayerMagicWeapon.selected ~= allSelected then
		objSwf.cbPlayerMagicWeapon.selected = allSelected
		self:OnPlayerMagicWeaponSelect();
	end
	if objSwf.cbPlayerTitle.selected ~= allSelected then
		objSwf.cbPlayerTitle.selected = allSelected;
		UISetSystem:OnPlayerChangeNum(SetSystemConsts.ISSHOWTITLE)
	end

	if objSwf.cbMonster.selected ~= allSelected then
		objSwf.cbMonster.selected = allSelected;
		UISetSystem:OnPlayerChangeNum(SetSystemConsts.ISSHOWCOMMONMONSTER)
	end
	if objSwf.cbHp.selected ~= allSelected then
		objSwf.cbHp.selected = allSelected;
		UISetSystem:OnPlayerChangeNum(SetSystemConsts.ISOPENFLASH)
	end
	self:Save()
	self:OnSelectSomeOne()
end

function SmallEyeView:OnPlayerSelect()
	UISetSystem:OnPlayerChangeNum(SetSystemConsts.UNSHOWNUMNAME)
	self:Save()
	self:OnSelectSomeOne()
end

function SmallEyeView:OnPlayerTianShenSelect()
	local selected = self.objSwf.cbPlayerTianShen.selected
	SetSystemModel:SaveIsShowPlayerTianShen(not selected);
	self:OnSelectSomeOne()
end

function SmallEyeView:OnPlayerMagicWeaponSelect()
	local selected = self.objSwf.cbPlayerMagicWeapon.selected
	SetSystemModel:SaveIsShowPlayerMagicWeapon(not selected);
	self:OnSelectSomeOne()
end

function SmallEyeView:OnPlayerTitleSelect()
	UISetSystem:OnPlayerChangeNum(SetSystemConsts.ISSHOWTITLE)
	self:Save()
	self:OnSelectSomeOne()
end

function SmallEyeView:OnMonsterSelect()
	UISetSystem:OnPlayerChangeNum(SetSystemConsts.ISSHOWCOMMONMONSTER)
	self:Save()
	self:OnSelectSomeOne()
end

function SmallEyeView:OnHpSelect()
	UISetSystem:OnPlayerChangeNum(SetSystemConsts.ISOPENFLASH)
	self:Save()
	self:OnSelectSomeOne()
end

function SmallEyeView:Save()
	UISystemBasic.setState = true;
	UISystemBasic:OnSetSave();
end

function SmallEyeView:OnSelectSomeOne()
	self:UpdateAllSelectedStatus();
	self:UpdateSmallEyeButton()
--	UISetSystem:OnShowSelecteBtn()
end

function SmallEyeView:UpdateSmallEyeButton()
	local setSysData = SetSystemModel.SetModel;
	if not setSysData then return; end
	if setSysData:GetUnAllPlayerShowName() or
			not SetSystemModel:GetIsShowPlayerTianShen() or
			not SetSystemModel:GetIsShowPlayerMagicWeapon() or
			setSysData:GerIsShowTitle() or
			setSysData:GetIsShowCommonMonster() or
			setSysData:GetIsOpenFlash() then
		UIMainTop:GetEyeBtn().selected = true;
	else
		UIMainTop:GetEyeBtn().selected = false;
	end
end

function SmallEyeView:OnHide()
	self:UpdateSmallEyeButton()
end

function SmallEyeView:GetPanelType()
	return 0;
end
function SmallEyeView:ListNotificationInterests()
	return {NotifyConsts.StageClick,NotifyConsts.StageFocusOut};
end
function SmallEyeView:HandleNotification(name,body)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.StageClick then
		local target = string.gsub(objSwf._target, "/",".");
		if string.find(body.target,target) then
			return
		end
		if self.args[1] then
			local target = string.gsub(self.args[1], "/",".");
			if string.find(body.target,target) then
				return;
			end
		end
		self:Hide();
	elseif name == NotifyConsts.StageFocusOut then
		self:Hide();
	end
end
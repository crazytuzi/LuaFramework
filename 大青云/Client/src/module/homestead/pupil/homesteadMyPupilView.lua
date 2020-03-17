--[[
	家园 弟子
	wangshuai
]]

_G.UIHomesteadMyPupil = BaseUI:new("UIHomesteadMyPupil");

UIHomesteadMyPupil.curPupilUid = 0;
UIHomesteadMyPupil.curIndex = 1;

function UIHomesteadMyPupil:Create()
	self:AddSWF("homesteadPupilPanel.swf",true,nil)

	self:AddChild(UIHomesAddPupilExp,"addPexp")
end;

function UIHomesteadMyPupil:OnLoaded(objSwf)
	self:GetChild("addPexp"):SetContainer(objSwf.childPanel);
	--objSwf.close_btn.click = function() self:Hide()end;
	objSwf.destory_btn.click = function() self:OndestoryPupil()end;

	objSwf.list.itemClick = function(e) self:itemClick(e)end;

	objSwf.listSkill.itemRollOver = function(e) self:SkillOver(e)end;
	objSwf.listSkill.itemRollOut = function() self:SkillOut()end;

	objSwf.addPupilExp_btn.click = function() self:OnpupilExp()end;
	objSwf.pupilMask._visible = false;

	-- objSwf.pupilRule.rollOver = function() self:PupilRuleOver()end;
	-- objSwf.pupilRule.rollOut  = function() TipsManager:Hide() end;
end;

function UIHomesteadMyPupil:PupilRuleOver()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	TipsManager:ShowBtnTips(StrConfig["homestead063"])
end;

function UIHomesteadMyPupil:OnShow()
	self.curIndex = 1;
	HomesteadController:ZongmengInfo()
	self:ShowPupilList()
end;

function UIHomesteadMyPupil:OnHide()
	self.curIndex = 1;
	if self.erjiPanelId then 
		UIConfirm:Close(self.erjiPanelId)
	end;
end

function UIHomesteadMyPupil:OnpupilExp()
	UIHomesAddPupilExp:SetPupilUid(self.curPupilUid)
	local name = "addPexp"
	local child = self:GetChild(name);
	if not child then
		return;
	end
	self:ShowChild(name);
end;

function UIHomesteadMyPupil:OndestoryPupil()
	local func = function() 
		HomesteadController:PupilRemove(self.curPupilUid)
	end;
	self.erjiPanelId = UIConfirm:Open(StrConfig["homestead005"],func);
	if UIHomesAddPupilExp:IsShow() then 
		UIHomesAddPupilExp:Hide();
	end;
end;

function UIHomesteadMyPupil:SkillOver(e)
	UIHomesSkillTips:SetSkillId(e.item.skillId)
end;

function UIHomesteadMyPupil:SkillOut()
	UIHomesSkillTips:Hide();
end;

function UIHomesteadMyPupil:itemClick(e)
	local objSwf = self.objSwf;
	local uid = e.item.uid;
	self.curIndex =  e.index + 1;
	self:ShowRightUi()
end;

function UIHomesteadMyPupil:ShowRightUi()
	local objSwf = self.objSwf;
	local pupil = HomesteadModel:GetPupilList();
	if pupil then 
		if not pupil[self.curIndex] then 
			self.curIndex = 1;
		end
		local uid = pupil[self.curIndex].guid
		objSwf.list.selectedIndex = self.curIndex - 1;
		self.curPupilUid = uid;
		local vo = HomesteadModel:GetApupilList(uid)
		objSwf.pupilName_txt.htmlText = HomesteadUtil:GetQualityColor(vo.quality,vo.roleName) ;
		objSwf.pupiLvl_txt.htmlText = string.format(StrConfig['homestead004'],vo.lvl);
		local pupCfg = t_homequestfit[vo.atb]
		objSwf.pupildesc_txt.htmlText = pupCfg.desc
		local maxExp = t_homepupilexp[vo.lvl]
		if not maxExp then 
			maxExp = {};
			maxExp.pupilExp = 0;
			print("ERROR: cur  pupilLvlId is error lvl",vo.lvl);
		end;
		objSwf.pupilExp_mc.maximum = maxExp.pupilExp;
		objSwf.pupilExp_mc.value = vo.exp;
		objSwf.quality_mc:gotoAndStop(vo.atb)
		objSwf.icon_mc.source = ResUtil:GetHomePupilIcon(vo.iconId,"64")
		--右侧面板技能
		self:ShowSkillList();
	else
		objSwf.pupilName_txt.htmlText =""
		objSwf.pupiLvl_txt.htmlText =""
		objSwf.pupildesc_txt.htmlText = ""
		objSwf.pupilExp_mc.maximum = 0
		objSwf.pupilExp_mc.value = 0
		objSwf.quality_mc:gotoAndStop(1)
		objSwf.icon_mc.source = ""
	end;
end;

function UIHomesteadMyPupil:ShowSkillList()
	local objSwf = self.objSwf;
	local uilist = HomesteadUtil:GetUiSkillData(self.curPupilUid,"64")
	objSwf.listSkill.dataProvider:cleanUp();
	objSwf.listSkill.dataProvider:push(unpack(uilist));
	objSwf.listSkill:invalidateData();
end;

function UIHomesteadMyPupil:ShowPupilList()
	local objSwf = self.objSwf;
	local pupil = HomesteadModel:GetPupilList();
	if #pupil == 0 then 
		objSwf.pupilMask._visible = true;
		return ;
	else
		objSwf.pupilMask._visible = false;
	end;
	local uilist = {};
	for i,info in ipairs(pupil) do 
		local vo = {};
		vo.name = HomesteadUtil:GetQualityColor(info.quality,info.roleName);
		vo.uid = info.guid;
		vo.iconSource = ResUtil:GetHomePupilIcon(info.iconId);
		vo.lvl = string.format(StrConfig["homestead004"],info.lvl)
		vo.isQuestIng =  info.queststeat
		-- if info.queststeat == 1 then 
		-- 	 = StrConfig["homestead016"]
		-- else
		-- 	vo.isQuestIng = StrConfig["homestead015"]
		-- end;
		vo.quality = info.quality;
		vo.atb = info.atb;
		table.push(uilist,UIData.encode(vo))
	end;
	objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push(unpack(uilist));
	objSwf.list:invalidateData();

	self:ShowRightUi();
end;

-- -- 居中
-- function UIHomesteadMyPupil:AutoSetPos()
-- 	if self.parent == nil then return; end
-- 	if not self.isLoaded then return; end
-- 	if not self.swfCfg then return; end
-- 	if not self.swfCfg.objSwf then return; end
-- 	local objSwf = self.swfCfg.objSwf;
-- 	local Vx = toint(HomesteadConsts.MainViewWH.width / 2) - objSwf._width/2
-- 	local Vy = toint(HomesteadConsts.MainViewWH.height / 2) - objSwf._height/2
-- 	objSwf.content._x = Vx--toint(x or objSwf.content._x,  -1); 
-- 	objSwf.content._y = Vy--toint(y or objSwf.content._y, -1);
-- end;

	-- notifaction
function UIHomesteadMyPupil:ListNotificationInterests()
	return {
		NotifyConsts.HomesteadMyPupilList,
		}
end;
function UIHomesteadMyPupil:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.HomesteadMyPupilList then
		self:ShowPupilList();
	end;
end;

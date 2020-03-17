--[[
家园主，面板
wangshuai
]]

_G.UIHomesteadMainView = BaseUI:new("UIHomesteadMainView")

UIHomesteadMainView.tabButton = {};
UIHomesteadMainView.curShowpanleName = {};

function UIHomesteadMainView:Create()
	self:AddSWF("homesteadMainPanel.swf",true,"center")

	self:AddChild(UIHomesteadSeleceView,"selectTools")
	self:AddChild(UIMainXunxian,"pupil");
	self:AddChild(UIHomesMainQuest,"mainQuest")
	self:AddChild(UIHomesAQuestVo,"aquest")
	self:AddChild(UILingLiHuiZhangView,"julingwan")
	self:AddChild(UIHomesMainBuildView,'mainbuid')
	self:AddChild(UIHomesQuestRod,"rod");

end;


function UIHomesteadMainView:OnLoaded(objSwf)
	-- self:GetChild("selectTools"):SetContainer(objSwf.childPanel);
	-- self:GetChild("pupil"):SetContainer(objSwf.childPanel);
	-- self:GetChild("mainQuest"):SetContainer(objSwf.childPanel);
	self:GetChild("aquest"):SetContainer(objSwf.childPanel);
	-- self:GetChild("julingwan"):SetContainer(objSwf.childPanel);


	objSwf.btnClose.click = function() self:Hide()end;

	self:GetChild("mainbuid"):SetContainer(objSwf.childPanel);
	self:GetChild("mainQuest"):SetContainer(objSwf.childPanel);
	self:GetChild("pupil"):SetContainer(objSwf.childPanel);
	self:GetChild("rod"):SetContainer(objSwf.childPanel);
	--self:GetChild("rodQuest"):SetContainer(objSwf.childPanel);
	
	self.tabButton["mainbuid"] = objSwf.build_btn1;
	self.tabButton["pupil"] = objSwf.build_btn2;
	self.tabButton["mainQuest"] = objSwf.build_btn3;
	self.tabButton["rod"] = objSwf.build_btn4;
	--self.tabButton["rodQuest"] = objSwf.build_btn4;

	for name,btn in pairs(self.tabButton) do 
		btn.click = function() self:OnTabButtonClick(name);end;
	end;
end;

function UIHomesteadMainView:SetBtnState()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local myLevel = MainPlayerModel.humanDetailInfo.eaLevel;
	local LvlCfg = t_homebuild[1];
	local xunOpenLvl = LvlCfg.fangxiantaiNeedlv;
	local questOpenLvl = LvlCfg.renwudianNeedlv;
	if xunOpenLvl > myLevel then 
		objSwf.build_btn2._visible = false;
	else
		objSwf.build_btn2._visible = true;
	end;
	if questOpenLvl > myLevel then 
		objSwf.build_btn3._visible = false;
		objSwf.build_btn4._visible = false;
	else 
		objSwf.build_btn3._visible = true;
		objSwf.build_btn4._visible = true;
	end;
end;

function UIHomesteadMainView:OnShow()
	HomesteadController:BuildInfo();
	--显示参数
	if self.args and #self.args > 0 then
		self:ShowUIHomesUI(self.args[1],self.args[2])
	else
		self:OnTabButtonClick("mainbuid")
	end

	self:SetBtnState();
end;

function UIHomesteadMainView:ShowUIHomesUI(name,...)
	if UIHomesAQuestVo:IsShow() then 
		UIHomesAQuestVo:Hide();
	end;
	local child = self:GetChild(name);
	if not child then
		return;
	end
	if self.tabButton[name] then 
		self.tabButton[name].selected = true;
	end;
	self:ShowChild(name,nil,...);
end;

function UIHomesteadMainView:OnTabButtonClick(name,...)
	if UIHomesAQuestVo:IsShow() then 
		UIHomesAQuestVo:Hide();
	end;
	if not self.tabButton[name] then
		return;
	end
	local child = self:GetChild(name);
	if not child then
		return;
	end
	self.tabButton[name].selected = true;
	self:ShowChild(name,nil,...);
end;

---- ----------------- ----------------------- -------------------
---- ----------------- ----------------------- -------------------


--显示任务详情
function UIHomesteadMainView:ShowAquestView()
	local name = "aquest"
	local child = self:GetChild(name);
	if not child then
		return;
	end
	self:ShowChild(name);
end;

--显示任务主面板
function UIHomesteadMainView:ShowMainQuestView(type)
	local name = "mainQuest"
	local child = self:GetChild(name);
	if not child then
		return;
	end
	if type then 
		self:ShowChild(name,'',{type});
	else
		self:ShowChild(name);
	end;
end;

---- ----------------- ----------------------- -------------------
---- ----------------- ----------------------- -------------------

-- notifaction
function UIHomesteadMainView:ListNotificationInterests()
	return {
		NotifyConsts.PlayerAttrChange,
		}
end;
function UIHomesteadMainView:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaLevel then 
			self:SetBtnState()
		end;
	end;
end;

---- ----------------- ----------------------- -------------------
---- ----------------- ----------------------- -------------------

function UIHomesteadMainView:IsTween()
	return true;
end

function UIHomesteadMainView:GetPanelType()
	return 1;
end

function UIHomesteadMainView:IsShowSound()
	return true;
end

function UIHomesteadMainView:GetHeight()
	return 676;
end

function UIHomesteadMainView:GetWidth()
	return 1058;
end;

function UIHomesteadMainView:IsShowLoading()
	return true;
end

--面板加载的附带资源
function UIHomesteadMainView:WithRes()
	 return {"homesteadMainBuildpanle.swf"}
end

_G.UIMainPageTianshen = BaseUI:new("UIMainPageTianshen");

UIMainPageTianshen.shortCutList = {};
UIMainPageTianshen.bean=0;
UIMainPageTianshen.defaultId=1001
function UIMainPageTianshen:Create()
	self:AddSWF("mainPageTianshen.swf", true, nil);
end
function UIMainPageTianshen:OnLoaded( objSwf )
	objSwf.btnBianshen.click = function() self:OnBtnTianshenClick(); end
    
    objSwf.btnTransforArea.click=function() self:OnTransforAreaClick();end
	objSwf.btnTransforArea.rollOver = function() self:OnTranforAreaRollOver(); end
	objSwf.btnTransforArea.rollOut = function() self:OnTranforAreaRollOut(); end

    objSwf.btntransforset.click=function() self:OntransforSetClick(); end
    objSwf.btntransforset.rollOver=function() self:OntransforSetrollOver(); end
    objSwf.btntransforset.rollOut=function() TipsManager:Hide(); end
	
	for i = 1,5 do
		local dou = objSwf['dadou'..i];
		dou.rollOver = function()
            self:OndadouRollOver();
		end
		dou.rollOut = function()
			TipsManager:Hide();
		end
	end

	objSwf.skillList.itemClick    = function(e) self:OnSkillItemClick(e); end
	objSwf.skillList.itemRollOut  = function(e) self:OnSkillItemOut(e); end
	objSwf.skillList.itemRollOver = function(e) self:OnSkillItemOver(e); end
	objSwf.btnTransforArea.disabled=true;
	objSwf.transforopen._visible=false;
end

function UIMainPageTianshen:OnShow()
	self:ShowTransfor();
	self:UpdateBean();
	self:ShowTransforOpen();
	self:RefreshSkillList();
	self:ShowAutoHangState();
end
function UIMainPageTianshen:ListNotificationInterests()
	return {
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.SkillPlayCD,
		NotifyConsts.SkillShortCutRefresh,
	    NotifyConsts.QuestUpdate,
		NotifyConsts.TianShenUpdate,
		--NotifyConsts.TianShenChangeModel,
		NotifyConsts.tianShenOutUpdata,
		NotifyConsts.TianShenActiveUpdate,
		NotifyConsts.AutoBattleSetInvalidate,
		
		--new--
		NotifyConsts.newtianShenUpUpdata,
	};
end
function UIMainPageTianshen:HandleNotification(name, body)
	if name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaWuHunSP then
			self:UpdateBean();
			self:CheckSkillConsum();
		elseif body.type == enAttrType.eaLevel then
			self:ShowTransforOpen();
		elseif body.type == enAttrType.eaMp then
			self:CheckSkillConsum();
		end
    elseif name ==NotifyConsts.QuestUpdate then
           self:ShowTransforOpen()
	elseif name == NotifyConsts.SkillPlayCD then
		self:SkillPlayCD(body.skillId,body.time);
	elseif name == NotifyConsts.SkillShortCutRefresh then
		self:RefreshSkillList();
	elseif name ==NotifyConsts.TianShenUpdate then
        self:ShowTransfor();
    elseif name ==NotifyConsts.TianShenActiveUpdate  then 
    	self:ShowActiveTransfor(body);
    	 self:ShowTransforOpen()
    elseif name ==NotifyConsts.tianShenOutUpdata then
    	self:ShowAutoHangState();
	--new--	
 	elseif name == NotifyConsts.newtianShenUpUpdata then
		if body.fightChanged then
			self:ShowTransfor();
			self:ShowAutoHangState();
			self:ShowTransforOpen()
		end
	end

end
--豆子
function UIMainPageTianshen:UpdateBean()
	local swf = self.objSwf;
	if not swf then return; end
	local info = MainPlayerModel.humanDetailInfo;
	local value = math.round(info.eaWuHunSP);
	for i = 0,5 do
		local dou = swf['dadou'..i];
		local active = value>=i;
		if dou then 
		    dou:gotoAndStop(active and 1 or 2 );
		end
		self.bean= active and i or self.bean;
	end
	--local frame = math.round((info.eaWuHunSP/5)*swf.TransforBar._totalFrames);
	--swf.TransforBar:gotoAndStop(frame);
end
function UIMainPageTianshen:OndadouRollOver()
	local num= MainPlayerModel.humanDetailInfo.eaWuHunSP;

	TipsManager:ShowBtnTips(PublicUtil.GetString("tianshen044",self.bean,5), TipsConsts.ShowType_Normal, TipsConsts.Dir_RightUp);
end
function UIMainPageTianshen:SkillPlayCD(skillId,time)
	local swf = self.objSwf;
	if not swf then return; end
	if not self.shortCutList then return; end
	if not swf.skillList._visible then return; end
	for k,vo in pairs(self.shortCutList) do
		if vo.skillId == skillId then
			local item = swf.skillList:getRendererAt(vo.pos-1);
			if not item then return; end
			item:playCD(time);
			return;
		end
	end
end
--挂机状态 自动更新
function UIMainPageTianshen:ShowAutoHangState()
	
   local objSwf = self.objSwf;
   if not objSwf then return; end
   objSwf.btntransforset.effect._visible=false;
   objSwf.icon_tinshen1._visible=false;
   if not FuncManager:GetFuncIsOpen(FuncConsts.NewTianshen) then 
   	return 
   end
   local vo=NewTianshenModel:GetTianshenByFightSize(0);	--new
   -- if not TianShenModel:GetFightModel() then	--old
   if not vo then 
   	    objSwf.icon_tinshen1._visible=true;
   end;
    if AutoBattleModel.autoCastTianShenSkill == 1 then
	    objSwf.btntransforset.effect._visible=true
	    TianShenController:SetHangEnabled(true)
	else
		TianShenController:SetHangEnabled(false)
	end

	-- local vo=TianShenModel:GetFightModel();	--old

	local tianshen = NewTianshenModel:GetTianshenByFightSize(0)
	if not tianshen then
		objSwf.tianshenLoader._visible = false
		return
	end
	
	objSwf.tianshenLoader._visible = true
	if objSwf.tianshenLoader.source ~= tianshen:GetMainNameUIcon() then
		objSwf.tianshenLoader.source = tianshen:GetMainNameUIcon()
	end
end
function UIMainPageTianshen:RefreshSkillList()
	local swf = self.objSwf;
	if not swf then return; end
	
	swf.skillList.dataProvider:cleanUp();
	swf.skillList._visible = false;
	self.shortCutList = self:GetAttachedSkills();
	if not self.shortCutList then
		for i=1,2 do
			local item = swf['item'..i];
			local effect = swf['effect'..i];
			item._visible = false;
			if effect then 
				effect._visible = false;
			end
		end
		return;
	end
	if #self.shortCutList>0 then
		swf.skillList._visible = true;
		
	    for i=1,#self.shortCutList do
			local item = swf['item'..i];
			if item then
				item._visible = true;
			end
			
			local skill = self.shortCutList[i];
			skill.consumEnough = SkillController:CheckConsume(skill.skillId)==1;
			swf.skillList.dataProvider:push(skill:GetUIData(true));
	    	
			local effect = swf['effect'..i];
			if effect then 
				effect._visible = skill.consumEnough;
			end
	    end
	end
	swf.skillList:invalidateData();
end

function UIMainPageTianshen:GetAttachedSkills()
	local result = {};
	-- local tianshen = TianShenModel:GetFightModel();
	local tianshen = NewTianshenModel:GetTianshenByFightSize(0);
	if not tianshen then
		return;
	end
	for i,skill in ipairs(tianshen.attachedSkills) do
		local vo = SkillUtil:GetSkillSolotVO(skill,TianShenConsts.size);
		vo.key = SetSystemConsts.KeyStrConsts[TianShenConsts.SkillKey[i]];
		table.push(result,vo);
	end
	return result;
end

function UIMainPageTianshen:OnSkillItemClick(e)
	if not e.item.hasSkill then return; end
	SkillController:PlayCastSkill(e.item.skillId);
end

function UIMainPageTianshen:OnSkillItemOver(e)
	if not e.item.hasSkill then return; end
	TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=e.item.skillId,additiveType = SkillConsts.ENUM_ADDITIVE_TYPE.TIANSHEN},TipsConsts.ShowType_Normal,
						TipsConsts.Dir_RightUp);
end

function UIMainPageTianshen:OnSkillItemOut(e)
	TipsManager:Hide();
end

function UIMainPageTianshen:OntransforSetClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	if not NewTianshenModel:GetTianshenByFightSize(0) then
		return;
	end
	if AutoBattleModel.autoCastTianShenSkill == 1 then

		AutoBattleModel.autoCastTianShenSkill = 0;
		TipsManager:ShowBtnTips(StrConfig["mainmenuset1"]);
        objSwf.btntransforset.effect._visible=false
        TianShenController:SetHangEnabled(false)
	else
		AutoBattleModel.autoCastTianShenSkill = 1;
		TipsManager:ShowBtnTips(StrConfig["mainmenuset2"]);
		objSwf.btntransforset.effect._visible=true;
		TianShenController:SetHangEnabled(true)
	end
	AutoBattleController:SaveAutoBattleSetting();
end

function UIMainPageTianshen:OnBtnTianshenClick()

    local objSwf = self.objSwf;
	if not objSwf then return; end
	
	FloatManager:AddNormal(StrConfig["mainmenuTianshen001"], objSwf.btnBianshen);
	
	-- if UITianshenSwitch:IsShow() then
	-- 	UITianshenSwitch:Hide();
	-- else
	-- 	UITianshenSwitch:Show(objSwf.btnBianshen._target);
	-- end
end
function UIMainPageTianshen:OnTransforAreaClick()
    
 
    if not FuncManager:GetFuncIsOpen(FuncConsts.NewTianshen) then 
        local playlv=MainPlayerModel.humanDetailInfo.eaLevel;
        local openlv=playlv>=t_funcOpen[FuncConsts.NewTianshen].open_level 
        if TianShenController.ReadyOpen then
            if openlv then
               FuncOpenController:ReqFunctionOpen(FuncConsts.NewTianshen);
            end
        end
    else
    	-- local zhantianshen=TianShenModel:GetFightModel();	--old
    	local zhantianshen=NewTianshenModel:GetTianshenByFightSize(0);
    	 if not zhantianshen then
            -- if UITianShenView:IsShow() then	--old
            if UINewTianshenBasic:IsShow() then
		        -- UITianShenView:Hide();	--old
		        UINewTianshenBasic:Hide();
            else
		        -- UITianShenView:Show();	--old
		        UINewTianshenBasic:Show();
            end
	    end
    end
end
function UIMainPageTianshen:OnTranforAreaRollOver()
     
    if TianShenController.ReadyOpen then
    	local playlv=MainPlayerModel.humanDetailInfo.eaLevel;
        local openlv=playlv>=t_funcOpen[FuncConsts.NewTianshen].open_level;
            if not openlv then 

            	--local vo=TianShenModel:GetTianShenVO(1) --old
            	local vo = NewTianshen:CreateZeroTianshen(self.defaultId)
		        if vo then
		            TipsManager:ShowTranforTips(vo); 
		        end
            end
	end 
end
function UIMainPageTianshen:OnTranforAreaRollOut()
    UITransforSkillTips:Close();
    TipsManager:Hide()
end
function UIMainPageTianshen:ShowTransforOpen()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local istransforopen = FuncManager:GetFuncIsOpen(FuncConsts.NewTianshen);
    local playlv=MainPlayerModel.humanDetailInfo.eaLevel;
	--开启了
	if istransforopen then
		objSwf.btnTransforArea.alwaysRollEvent = true;
		TianShenController.ReadyOpen=false;
		objSwf.btnTransforArea.disabled=false;
		TianShenModel.isguide=false;
		objSwf.transforopen._visible=false;  
	else 
		if  QuestUtil:IsTrunkFinished(TianShenConsts:GetquestId()) then
            TianShenController.ReadyOpen=true;
            local openlv=playlv>=t_funcOpen[FuncConsts.NewTianshen].open_level
            if openlv and TianShenModel.isguide then 

            	objSwf.btnTransforArea.alwaysRollEvent = false;
            	TianShenModel.isguide=false;
            	QuestScriptManager:DoScript("transforchangeguide");
            end
            objSwf.btnTransforArea.disabled=false;
            objSwf.transforopen._visible=true;
		end
	end
end
UIMainPageTianshen.tsOpenTimerKey = nil;
function UIMainPageTianshen:ShowTransfor()
	local objSwf =self.objSwf;
	if not objSwf then return; end
	-- self.zhanbianshen=TianShenModel:GetFightModel();	--old
	self.zhanbianshen=NewTianshenModel:GetTianshenByFightSize(0);
	if not self.zhanbianshen then
		self:DisposeTransfor();
		self:SetBeansVisible(false);
		return 
	end
	self:DrawTransfor();
	self:SetBeansVisible(true);
end

function UIMainPageTianshen:SetBeansVisible(visible)
	local swf = self.objSwf;
	for i = 1,5 do
		local dou = swf['dadou'..i];
		dou._visible = visible;
	end
end

function UIMainPageTianshen:DisposeTransfor()
	-- if self.objUIDraw then
	   -- self.objUIDraw:SetDraw(false);
	   -- self.objUIDraw:SetUILoader(nil);
	   -- UIDrawManager:RemoveUIDraw(self.objUIDraw);
	   -- self.objUIDraw = nil;
	-- end
	self.objSwf.tianshenLoader:unload();
	self.objSwf.tianshenLoader._visible = false;
end

function UIMainPageTianshen:DisposeDummy()
	if self.objUIDraw then
	   self.objUIDraw:SetDraw(false);
	   self.objUIDraw:SetUILoader(nil);
	   UIDrawManager:RemoveUIDraw(self.objUIDraw);
	   self.objUIDraw = nil;
	end
	
	if self.objAvatar then
	   self.objAvatar:ExitMap();
	   self.objAvatar = nil;
	end
end
local viewPort;
function UIMainPageTianshen:DrawTransfor()
    local objSwf = self.objSwf;
	if not objSwf then return; end
	--[[
	--objSwf.activeTransfor._visible=false;
    self:DisposeTransfor();

	local modelCfg = t_tianshenlv[self.zhanbianshen.step]
	if not modelCfg then
		return;
	end
	 -- objSwf.TransBar:gotoAndStop(self.zhanbianshen.energy);
	if not self.objUIDraw then
		if not viewPort then viewPort = _Vector2.new(150, 150); end
		self.objUIDraw = UISceneDraw:new( "MainPageTianshenView", objSwf.tianshenLoader, viewPort );
	else
		self.objUIDraw:SetUILoader(objSwf.tianshenLoader);
	end
	self.objUIDraw:SetScene(modelCfg.ui_head);
	self.objUIDraw:SetDraw(true)]]
	
end
function UIMainPageTianshen:ShowActiveTransfor(vo) 
	local objSwf = self.objSwf;
	if not objSwf then return; end

	if vo and vo.tid ==1 then
		TianShenController:SendChangeTianshen(1,1);  
		UITianShenShowView:OpenPanel();
	end
end

function UIMainPageTianshen:OntransforSetrollOver()
	if not TianShenModel:GetActiveModel() then return end
	if not NewTianshenModel:GetTianshenByFightSize(0) then return end
	if AutoBattleModel.autoCastTianShenSkill == 1 then
		TipsManager:ShowBtnTips(StrConfig["mainmenuset2"]);
	else
		TipsManager:ShowBtnTips(StrConfig["mainmenuset1"]);
	end
end
function UIMainPageTianshen:GetTransforBtn()
	if not self:IsShow() then return nil end
	return self.objSwf.btnTransforArea
end

function UIMainPageTianshen:SetTianShenProgressBar(leftTime, totalTime)
	--UIMainSkill.objSwf.btntianshenOpen.bar:gotoAndStop(math.floor((leftTime / totalTime) * 100));
end

function UIMainPageTianshen:GetAreaPos()
	local objSwf = self.objSwf;
	if not objSwf then return {x=0,y=0}; end
	return UIManager:PosLtoG(objSwf.btnTransforArea,0,0);
end

function UIMainPageTianshen:CheckSkillConsum()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not self.shortCutList then return; end
	for k,vo in pairs(self.shortCutList) do
		local consumEnough = SkillController:CheckConsume(vo.skillId)==1;
		local effect = objSwf['effect'..k];
		if effect then 
			effect._visible =consumEnough;
		end
		if consumEnough ~= vo.consumEnough then
			vo.consumEnough = consumEnough;
			local uiDataStr = vo:GetUIData(true);
			objSwf.skillList.dataProvider[vo.pos-1] = uiDataStr;
			local item = objSwf.skillList:getRendererAt(vo.pos-1);
			if item then
				item:setData(uiDataStr);
			end
		end
		
	end
end



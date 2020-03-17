--[[
技能栏设置面板
lizhuangzhuang
2014年10月10日14:42:53
]]

_G.UISkillShortCutSet = BaseUI:new("UISkillShortCutSet");

UISkillShortCutSet.type = nil;
UISkillShortCutSet.pos = 0;
UISkillShortCutSet.mc = nil;
--基础技能
UISkillShortCutSet.basicSkillList = {};
--绝学
UISkillShortCutSet.juexueSkillList = {};
--骑战技能
UISkillShortCutSet.qizhanSkillList = {};
--特殊技能
UISkillShortCutSet.specailSkillList = {};

UISkillShortCutSet.currPanelY = 0;

UISkillShortCutSet.panels = {"basicSkillPanel","specialPanel","qizhanPanel","juexuePanel"};

function UISkillShortCutSet:Create()
	self:AddSWF("skillShortCutSetting.swf",true,"center");
end

function UISkillShortCutSet:OnLoaded(objSwf)
	for _,name in ipairs(self.panels) do
		local ui = objSwf[name];
		ui.skillList.itemClick = function(e) self:OnSkillItemClick(e); end
		ui.skillList.itemRollOver = function(e) self:OnSkillItemRollOver(e); end
		ui.skillList.itemRollOut = function(e) self:OnSkillItemRollOut(e); end
		ui.skillList.bg._height = 0;
		ui.hitTestDisable = true;
		ui._visible = false;
	end
end

function UISkillShortCutSet:OnResize()
	self:Hide();
end

--@param pos 点击目标在列表中的索引，从0开始
--@param mc 点击目标技能格子mc
--@param type 显示类型：主界面技能设置，或者自动战斗技能设置
--@param skillType 显示的技能类型：1 基础技能，2 特殊技能, 默认为全部显示
function UISkillShortCutSet:Open( pos, mc, type, skillType)
	self.pos = pos;
	self.mc = mc;
	self.type = type or SkillConsts.MainPage;
	self.skillType = skillType;
	if self:IsShow() then
		self:OnHide();
		self:OnShow();
		self:SetUIPos();
	else
		self:Show();
	end
end

function UISkillShortCutSet:OnShow()
	self:ShowList();
	self:SetUIPos();
end

function UISkillShortCutSet:OnHide()
	self.mc = nil;
	local objSwf = self.objSwf;
	if not objSwf then return; end
	for _,name in ipairs(self.panels) do
		local ui = objSwf[name];
		ui._visible = false;
		ui.hitTestDisable = true;
		ui._y = 0;
		ui.skillList.bg._height = 0;
	end
end

function UISkillShortCutSet:SetUIPos()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local pos = nil;
	if self.mc then
		pos = UIManager:GetMcPos(self.mc);
		local width = self.mc.width or self.mc._width;
		pos.x = pos.x + width / 2;
	else
		pos = _sys:getRelativeMouse();
	end
	objSwf._x = pos.x - objSwf._width / 2;
	-- objSwf._y = pos.y - objSwf._height;
	objSwf._y = pos.y - self.currPanelY - 50;
end

function UISkillShortCutSet:ShowList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.basicSkillList = {};
	self.juexueSkillList = {};
	self.qizhanSkillList = {};
	self.specailSkillList = {};
	local basicSkillType = SkillConsts:GetBasicShowType();
	local juexueSkillType = SkillConsts:GetJuexueShowType();
	local qizhanSkillType = SkillConsts:GetQiZhanShowType();
	local forbidSkillId1, forbidSkillId2 = SkillConsts:GetForbidSkillGroupId()
	local shortCutInfo = SkillModel:GetShortcutListByPos(self.pos)
	local skillId = shortCutInfo and shortCutInfo.skillId or nil
	for i,skillVO in pairs(SkillModel.skillList) do
		local cfg = skillVO:GetCfg();
		if cfg and cfg.group_id ~= forbidSkillId1 and cfg.group_id ~= forbidSkillId2 and cfg.id ~= skillId then
			local listVO = {};
			listVO.hasItem = true;
			listVO.skillId = skillVO:GetID();
			listVO.iconUrl = ResUtil:GetSkillIconUrl(cfg.icon);
			if self.type == SkillConsts.MainPage then
				if self.skillType == basicSkillType and cfg.showtype == basicSkillType then
					table.push (self.basicSkillList, listVO );
				end
				if self.skillType == juexueSkillType and cfg.showtype == juexueSkillType then
					table.push(self.juexueSkillList,listVO);
				end
				if cfg.showtype == qizhanSkillType then
					table.push(self.qizhanSkillList,listVO);
				end
			elseif self.type == SkillConsts.AutoBattle then
				if AutoBattleUtils:ShowInSetting( listVO.skillId ) then
					if self.skillType == AutoBattleConsts.Normal then
						if cfg.showtype == basicSkillType then
							table.push (self.basicSkillList, listVO );
						end
						if cfg.showtype == juexueSkillType then
							table.push(self.juexueSkillList,listVO);
						end
					elseif self.skillType == AutoBattleConsts.Special then
						if AutoBattleUtils:GetSkillType( listVO.skillId ) == AutoBattleConsts.Special then
							table.push( self.specailSkillList, listVO );
						end
					end
				end
			end
		end
	end


	local sortFuc = function(A, B) return A.skillId < B.skillId; end
	table.sort( self.basicSkillList, sortFuc );
	table.sort( self.juexueSkillList, sortFuc);
	table.sort( self.qizhanSkillList, sortFuc);
	table.sort( self.specailSkillList, sortFuc);
	--
	self.currPanelY = 3;
	self:ShowSkillList(objSwf.basicSkillPanel,self.basicSkillList);
	self:ShowSkillList(objSwf.juexuePanel,self.juexueSkillList);
	self:ShowSkillList(objSwf.qizhanPanel,self.qizhanSkillList);
	self:ShowSkillList(objSwf.specialPanel,self.specailSkillList);
	objSwf.bg._height = self.currPanelY + 30;
	objSwf.mcArrow._y = self.currPanelY + 28;
end

--显示技能
function UISkillShortCutSet:ShowSkillList(panel,skilllist)
	if #skilllist <= 0 then return; end
	panel._visible = true;
	panel.hitTestDisable = false;
	local rows = toint(#skilllist/6,1);
	rows = rows<1 and 1 or rows;
	panel.skillList.bg._height = rows*55+50;
	panel._y = self.currPanelY;
	panel.skillList.dataProvider:cleanUp();
	for i, listVO in ipairs(skilllist) do
		panel.skillList.dataProvider:push( UIData.encode(listVO) );
	end
	--不足6个补齐
	local lastRowNum = #skilllist % 6;
	if lastRowNum>0 and lastRowNum<6 then
		for i=lastRowNum+1,6 do
			local listVO = {};
			listVO.hasItem = false;
			panel.skillList.dataProvider:push( UIData.encode(listVO) );
		end
	end
	panel.skillList:invalidateData();
	self.currPanelY = self.currPanelY + rows*55 + 50;
end

function UISkillShortCutSet:OnSkillItemClick(e)
	if not e.item.hasItem then return; end
	if self.type == SkillConsts.MainPage then
		local shortCutInfo = SkillModel:GetShortcutListByPos(self.pos);
		if shortCutInfo and shortCutInfo.skillId == e.item.skillId then
			return;
		end
		SkillController:SkillShortCutSet( self.pos, e.item.skillId );
	elseif self.type == SkillConsts.AutoBattle then
		local goalIndex = self.pos;
		local skillId = e.item.skillId;
		local autoBattleSkillType = AutoBattleUtils:GetSkillType( skillId );
		if autoBattleSkillType == AutoBattleConsts.Normal then
			UIAutoBattle:SetNormalSkill(goalIndex, skillId);
		elseif autoBattleSkillType == AutoBattleConsts.Special then
			UIAutoBattle:SetSpecialSkill(goalIndex, skillId);
		end
	end
	TipsManager:Hide();
	self:Hide();
end

function UISkillShortCutSet:OnSkillItemRollOver(e)
	if not e.item.hasItem then return; end
	TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=e.item.skillId},TipsConsts.ShowType_Normal,
						TipsConsts.Dir_RightUp);
end

function UISkillShortCutSet:OnSkillItemRollOut(e)
	TipsManager:Hide();
end

function UISkillShortCutSet:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.StageClick then
		local target = string.gsub(objSwf._target, "/",".");
		if string.find(body.target,target) then
			return
		end
		self:Hide();
	elseif name == NotifyConsts.StageFocusOut then
		self:Hide();
	end
end

function UISkillShortCutSet:ListNotificationInterests()
	return {NotifyConsts.StageClick,NotifyConsts.StageFocusOut};
end
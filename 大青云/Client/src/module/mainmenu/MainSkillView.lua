--[[
主面板:技能栏
lizhuangzhuang
2014年7月18日14:11:43
]]

_G.UIMainSkill = BaseUI:new("UIMainSkill");

UIMainSkill.skillList = {};
UIMainSkill.FLOAT_TIME = 2.5
UIMainSkill.FLOAT_DISTANCE = 125
UIMainSkill.SpecialShowLevel = 100;--显示特殊类技能的等级

UIMainSkill.isShowMoreSkill = true;  --修改true  以前false

UIMainSkill.funcBtnMap = {};

UIMainSkill.currFabaoSelect = nil;
UIMainSkill.objAvatar = nil;
UIMainSkill.currbianshenSelect=nil;
UIMainSkill.zhanbianshen=nil
function UIMainSkill:Create()
	self:AddSWF("mainPageSkill.swf", true, "interserver");
	self:AddChild( UIMainPageTianshen, UIMainPageTianshen:GetName() );
end

function UIMainSkill:OnLoaded(objSwf,name)

	self:GetChild( UIMainPageTianshen:GetName() ):SetContainer( objSwf.childPanel );

	objSwf.txtExp.autoSize = "center"
	objSwf.siExp.rollOver          = function() self:OnSiExpRollOver(); end;
	objSwf.siExp.rollOut           = function() self:OnSiExpRollOut(); end;

	objSwf.siExp.complete          = function(e) self:OnSiExpComplete(e) end
	objSwf.siHp.rollOver           = function() self:OnHPRollOver(); end;
	objSwf.siHp.rollOut            = function() self:OnHPRollOut();  end;

	objSwf.siMp.rollOver           = function() self:OnMPRollOver(); end;
	objSwf.siMp.rollOut            = function() self:OnMPRollOut();  end;


	objSwf.sliderHp.change         = function() TipsManager:Hide();self:OnSliderHpChange(); end
	objSwf.sliderHp.thumb.rollOver = function() self:OnSliderHpRollOver(); end
	objSwf.sliderHp.thumb.rollOut  = function() self:OnSliderRollOut(); end


	--objSwf.skillList.itemClick    = function(e) self:OnSkillItemClick(e); end
	objSwf.skillList.itemRollOut  = function(e) self:OnSkillItemOut(e); end
	objSwf.skillList.itemRollOver = function(e) self:OnSkillItemOver(e); end
	objSwf.skillList.itemSetClick = function(e) self:OnSkillItemSetClick(e); end
	for i=12,16 do

		objSwf["item"..i].visible = self.isShowMoreSkill;
	end
	objSwf.btnMoreSkill.click = function() self:OnBtnMoreSkillClick(); end

	objSwf.scItem.click = function() self:OnSCItemClick(); end
	objSwf.scItem.rollOver = function() self:OnSCItemRollOver(); end
	objSwf.scItem.rollOut = function() self:OnSCItemRollOut(); end
	objSwf.scItem.itemSetClick = function(e) self:OnSCItemSetClick(e); end

	self.funcBtnMap[FuncConsts.Pick] = objSwf.btnPick;
	self.funcBtnMap[FuncConsts.AutoBattle] = objSwf.btnBattle;
	self.funcBtnMap[FuncConsts.Ride] = objSwf.btnRide;
	self.funcBtnMap[FuncConsts.Sit] = objSwf.btnSit;
	self.funcBtnMap[FuncConsts.TP] = objSwf.btnTp;
	--self.funcBtnMap[FuncConsts.Homestead] = objSwf.btnHome;
	for funcId,btn in pairs(self.funcBtnMap) do
		btn.click = function() self:OnFuncBtnClick(funcId); end
		btn.rollOver = function() self:OnFuncBtnRollOver(funcId); end
		btn.rollOut = function() self:OnFuncBtnRollOut(funcId); end
	end

end

function UIMainSkill:WithRes()
	return {"mainPageTianshen.swf"};
end

function UIMainSkill:OnBtnMarryClick()
	local state = MarriageModel:GetMyMarryState()
	if state == MarriageConsts.marryMarried then
		MarriagController:ReqFlyToMate()
	end
end

function UIMainSkill:OnBtnMarryOver()
	TipsManager:ShowBtnTips(StrConfig['marriage075']);
end

function UIMainSkill:SetMarrySkill()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local state = MarriageModel:GetMyMarryState()
	if state == MarriageConsts.marrySingle or state == MarriageConsts.marryReserve
		or state == MarriageConsts.marryLeave then --单身 订婚 离婚
		--objSwf.btnMarry.visible = false;
	elseif state == MarriageConsts.marryMarried then --结婚
		--objSwf.btnMarry.visible = true;
	end;

end;

function UIMainSkill:NeverDeleteWhenHide()
	return true;
end

function UIMainSkill:OnShow()
	self:ShowExp();
	self:ShowSkillList();
	self:CheckShortCutItem()
	self:ShowShortCutItem();
	self:SetHp();
	self:SetMp();

	self:ShowSlider()
	self:ShowTiLi();
	self:ShowNuQi();

	self:CheckFuncBtnState();
	if UIWuhunSwitch:IsShow() then
		UIWuhunSwitch:Hide()
	end
	self:CheckInterServer();
	self:CheckShowMore();
	self:SetMarrySkill();
	-- self:ShowTransforOpen()

	self:GetChild(UIMainPageTianshen:GetName()):Show();

end

function UIMainSkill:GetHeight()
	return 161;
end

function UIMainSkill:GetWidth()
	return 1004
end
function UIMainSkill:CheckPlayParticle(exp)
	local objSwf = self.objSwf;
	if not objSwf then return end
	local level = MainPlayerModel.humanDetailInfo.eaLevel
	local lvlCfg = _G.t_lvup[level]
	if not lvlCfg then return false end
	local expPerParticle = lvlCfg.exp * lvlCfg.expParticle
	if exp >= expPerParticle then
		objSwf.siExp.isPlayBig = true;
	else
		objSwf.siExp.isPlayBig = false;
	end
end
--处理消息
function UIMainSkill:HandleNotification(name, body)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaExp then
			local expAdd = body.val - body.oldVal
			self:CheckPlayParticle(expAdd)
			self:ShowExp(body.val, body.oldVal);
			-- print('=============================NotifyConsts.eaExp',expAdd)
			-- print('=============================body.val',body.val)
			-- print('=============================body.oldVal',body.oldVal)



		elseif body.type ==enAttrType.eaTianShenEnergy then
			-- self:OnTransProgressBar()
		elseif body.type == enAttrType.eaLevel then
			local expAdd1 = body.val - body.oldVal
			-- print('=============================NotifyConsts.eaLevel',expAdd1)
			local exp = MainPlayerModel.humanDetailInfo.eaExp
			-- self:ShowFullExpEffect();
			-- self:ShowTransforOpen();
		elseif body.type == enAttrType.eaTiLi then
			self:ShowTiLi();
			self:CheckSkillConsum();
		elseif body.type == enAttrType.eaMaxWuHunSP then
			self:ShowNuQi();
			--self:ShowWuHunDou()
		elseif body.type == enAttrType.eaWuHunSP then
			self:ShowNuQi();
			self:CheckSkillConsum();
			--self:ShowWuHunDou()
		elseif body.type == enAttrType.eaMp or body.type == enAttrType.eaMaxMp then
			self:SetMp()

		elseif body.type == enAttrType.eaHp or body.type == enAttrType.eaMaxHp then
			self:SetHp()
			if self.isMouseOverHp then self:ShowHpTips(); end
		elseif body.type == enAttrType.eaMp then
			self:CheckSkillConsum();
		end
	elseif name == NotifyConsts.AutoBattleCfgChange then
		if body.cfgName == "takeDrugHp" then
			self:OnTakeDrugHpChange(body.value);
		end
	elseif name == NotifyConsts.AutoBattleSetInvalidate then
		self:OnTakeDrugHpChange( AutoBattleModel.takeDrugHp );
	elseif name == NotifyConsts.SkillPlayCD then
		self:SkillPlayCD(body.skillId,body.time);
	elseif name == NotifyConsts.SkillShortCutRefresh then
		self:ShowSkillList();
	elseif name == NotifyConsts.SkillShortCutChange then
		self:OnShortCutChange(body.pos);
	elseif name == NotifyConsts.WuhunListUpdate then
		--self:ShowWuHun();
	elseif name == NotifyConsts.BagItemNumChange then
		if body.id == SkillModel.shortCutItem then
			if self:CheckShortCutItem() then
				self:ShowShortCutItem();
			end
		end
	elseif name == NotifyConsts.BagItemCDUpdate then
		if body.type == BagConsts.BagType_Bag then
			self:ShowShortCutItem();
		end
	elseif name == NotifyConsts.ItemShortCutRefresh then
		self:ShowShortCutItem();
	elseif name == NotifyConsts.InterServerState then
		self:CheckInterServer();
	elseif name == NotifyConsts.MarryStateChange then
		self:SetMarrySkill();
	elseif name == NotifyConsts.FabaoChange then
		if body then
			--self:ShowFabao();
		end
	elseif name == NotifyConsts.FabaoListChange then
		--self:ShowFabao();

	elseif name ==NotifyConsts.TianShenUpdate then
        -- self:ShowTransfor();

    elseif name ==NotifyConsts.TianShenActiveUpdate  then
    	 -- self:ShowActiveTransfor(body)
    elseif name ==NotifyConsts.TianShenChangeModel then
    	-- self:ShowChangeTianshen()
 	end
end
function UIMainSkill:ListNotificationInterests()
	return {
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.SkillPlayCD,
		NotifyConsts.SkillShortCutRefresh,
		NotifyConsts.SkillShortCutChange,
		NotifyConsts.SkillLearn,
		NotifyConsts.SkillLvlUp,
		NotifyConsts.AutoBattleCfgChange,
		NotifyConsts.AutoBattleSetInvalidate,
		NotifyConsts.WuhunListUpdate,
		NotifyConsts.BagItemNumChange,
		NotifyConsts.BagItemCDUpdate,
		NotifyConsts.ItemShortCutRefresh,
		NotifyConsts.InterServerState,
		NotifyConsts.MarryStateChange,
		NotifyConsts.FabaoListChange,
		NotifyConsts.FabaoChange,
		NotifyConsts.TianShenUpdate,
		NotifyConsts.TianShenChangeModel,
		NotifyConsts.TianShenEnergy,
		NotifyConsts.TianShenActiveUpdate,
	};
end



----------------------------------------技能处理----------------------------
--显示技能列表
function UIMainSkill:ShowSkillList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.skillList = SkillUtil:GetMainPageSkillList();
	objSwf.skillList.dataProvider:cleanUp();
	for i,slotVO in ipairs(self.skillList) do
		objSwf.skillList.dataProvider:push(slotVO:GetUIData());
	end
	objSwf.skillList:invalidateData();
	self.zhanFabao = FabaoModel:GetFighting()
	if self.zhanFabao then
		SkillController:OnFabaoSkillChange(self.zhanFabao.sskill.modelId);
		SkillController:OnFabaoNSkillChange(self.zhanFabao.nskill.modelId);
	else
		SkillController:OnFabaoSkillChange(0);
		SkillController:OnFabaoNSkillChange(0);
	end
end


--播放技能CD
function UIMainSkill:SkillPlayCD(skillId,time)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local shortCutList = SkillModel:GetShortcutList();
	for k,vo in pairs(shortCutList) do
		if vo.skillId == skillId then
			local item = objSwf.skillList:getRendererAt(vo.pos);
			if not item then return; end
			item:playCD(time);
			return;
		end
	end
end

--得到SkillSlotVO
function UIMainSkill:GetSkillSlotVO(pos)
	for i,slotVO in ipairs(self.skillList) do
		if slotVO.pos == pos then
			return slotVO;
		end
	end
	return nil;
end

--检查技能消耗是否足够
function UIMainSkill:CheckSkillConsum()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local shortCutList = SkillModel:GetShortcutList();
	for k,vo in pairs(shortCutList) do
		if vo.skillId > 0 then
			local slotVO = self:GetSkillSlotVO(vo.pos);
			local consumEnough = SkillController:CheckConsume(vo.skillId)==1;
			if consumEnough ~= slotVO.consumEnough then
				slotVO.consumEnough = consumEnough;
				local uiDataStr = slotVO:GetUIData();
				objSwf.skillList.dataProvider[vo.pos] = uiDataStr;
				local item = objSwf.skillList:getRendererAt(vo.pos);
				if item then
					item:setData(uiDataStr);
				end
			end
		end

	end
end

--技能栏改变
function UIMainSkill:OnShortCutChange(pos)
	local objSwf = self.objSwf;
	if not objSwf then return; end

	if MainPlayerController:InTransforming() then
		return;
	end

	local shortCutVO = SkillModel:GetShortcutListByPos(pos);

	if not shortCutVO then return; end
	local slotVO = self:GetSkillSlotVO(pos);

	slotVO.skillId = shortCutVO.skillId;
	if shortCutVO.skillId > 0 then
		slotVO.hasSkill = true;
		slotVO.consumEnough = SkillController:CheckConsume(shortCutVO.skillId)==1;
	else
		slotVO.hasSkill = false;
	end
	local uiDataStr = slotVO:GetUIData();
	objSwf.skillList.dataProvider[pos] = uiDataStr;
	local item = objSwf.skillList:getRendererAt(pos);
	if item then
		item:setData(uiDataStr);
		local time = SkillModel:GetGroupCD(shortCutVO.skillId)
		if time > 0 then
			item:playCD(time)
		end
	end
end

--技能点击
function UIMainSkill:OnSkillItemClick(e)
	local index = e.index;
	if not e.item.hasSkill then return; end
	local config = t_skill[e.item.skillId];
	if not config then
		return;
	end
	if config.showtype == SkillConsts.ShowType_Fabao then
		-- 判断是否符合施法条件
		-- local result = SkillController:IsCanUseSkill(e.item.skillId)
		-- if result ~= 0 then
			-- SkillController:ShowNotice(e.item.skillId, result)
			-- return
		-- end
		FabaoController:SendFabaoSkill(e.item.skillId);
	else
		SkillController:PlayCastSkill(e.item.skillId)
	end
end

--技能鼠标移上
function UIMainSkill:OnSkillItemOver(e)
	if not e.item.hasSkill then return; end
	TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=e.item.skillId,additiveType=SkillUtil.additiveType},TipsConsts.ShowType_Normal,
						TipsConsts.Dir_RightUp);
end

--技能鼠标移出
function UIMainSkill:OnSkillItemOut(e)
	TipsManager:Hide();
end

--点击技能设置
function UIMainSkill:OnSkillItemSetClick(e)
	print(e.item.pos)
	if e.item.pos and e.item.pos < 6 then
		UISkillShortCutSet:Open(e.item.pos,e.renderer,nil, SkillConsts:GetBasicShowType());
	else
		UISkillShortCutSet:Open(e.item.pos,e.renderer,nil, SkillConsts:GetJuexueShowType());
	end
end

--显示技能鼠标按下效果
function UIMainSkill:ShowSkillKeyDown(pos,keyDown)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local item = objSwf.skillList:getRendererAt(pos);
	local desc = item or "null"
	WriteLog(LogType.Normal,true,"UIMainSkill:ShowSkillKeyDown"..pos..'desc'..tostring(desc));
	if item then
		item.keyDownState = keyDown;
	end
end

function UIMainSkill:OnBtnMoreSkillClick()

	self.isShowMoreSkill = not self.isShowMoreSkill;
	local objSwf = self.objSwf;
	if not objSwf then return; end
	for i=12,16 do
		objSwf["item"..i].visible = self.isShowMoreSkill;
	end
end

function UIMainSkill:CheckShowMore()
	if #self.skillList <= 0 then return; end
	for i,slotVO in ipairs(self.skillList) do
		if i>SkillConsts.KeyLineNum and i<=9 and slotVO.hasSkill then
			self.isShowMoreSkill = true;
			break;
		end
	end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	for i=12,16 do
		objSwf["item"..i].visible = self.isShowMoreSkill;
	end

end

--获取指定位置的格子全局坐标
function UIMainSkill:GetSkillItemPos(pos)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local item = objSwf.skillList:getRendererAt(pos);
	if item then
		return UIManager:PosLtoG(item.iconLoader,0,0);
	end
	return nil;
end
---------------------------------------------------

--经验值Tips
function UIMainSkill:OnSiExpRollOver()
	local info = MainPlayerModel.humanDetailInfo;
	local maxExp = 0;
	if t_lvup[info.eaLevel] then
		maxExp = t_lvup[info.eaLevel].exp;
	else
		maxExp = info.eaExp;
	end
	-- TipsManager:ShowBtnTips( string.format(StrConfig["mainmenuSkill01"],info.eaExp, t_lvup[info.eaLevel].exp) );

	TipsManager:ShowBtnTips( string.format( "经验值:%s/%s(%s%%)", _G.getNumShow3( info.eaExp ), _G.getNumShow3( maxExp ),string.format("%.2f",(info.eaExp/maxExp*100))))
end

function UIMainSkill:OnSiExpRollOut()
	TipsManager:Hide();
end

-----------------------------------------------------
--显示体力
function UIMainSkill:ShowTiLi()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local info = MainPlayerModel.humanDetailInfo;
	--objSwf.siTiLi.maximum = info.eaMaxTiLi;
--	objSwf.siTiLi.value = info.eaTiLi;
end

--体力tips
function UIMainSkill:OnSITiLiOver()
	local info = MainPlayerModel.humanDetailInfo;
	local tiliValue = math.min(info.eaTiLi, info.eaMaxTiLi)
	TipsManager:ShowBtnTips(string.format(StrConfig['mainmenuSkill13'],tiliValue,info.eaMaxTiLi));
end

----------------------技能快速点击特效------------------
function UIMainSkill:ShowSkillQuickClick(pos)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local skillItem = objSwf.skillList:getRendererAt(pos);
	if skillItem then
		objSwf.effQuickClick._x = skillItem._x + 20;
		objSwf.effQuickClick._y = skillItem._y + 13;
		objSwf.effQuickClick:playEffect(0);
	end
end
function UIMainSkill:HideSkillQuickClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	--objSwf.effQuickClick:stopEffect();
end

-------------------------------武魂处理------------------------
function UIMainSkill:ShowWuHun()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self:ShowWuHunDou()
	if not FuncManager:GetFuncIsOpen(FuncConsts.FaBao) then
		objSwf.btnWuhun.loader:unload();
		objSwf.btnWuhun.mcLock._visible = true;
		objSwf.btnWuhun.selected = false;
		return;
	end
	objSwf.btnWuhun.mcLock._visible = false;
	local fushenId = SpiritsModel:GetFushenWuhunId();
	if fushenId == 0 then
		objSwf.btnWuhun.loader:unload();
		return;
	end
	local cfg = t_wuhun[fushenId] or t_wuhunachieve[fushenId];
	if not cfg then
		objSwf.btnWuhun.loader:unload();
		return;
	end

	objSwf.btnWuhun.loader.source = ResUtil:GetWuhunMainIcon(cfg.main_icon);
end

function UIMainSkill:OnBtnWuhunOver()
	local wuhunId = SpiritsModel:GetFushenWuhunId()
	if wuhunId == 0 then
		if not FuncManager:GetFuncIsOpen(FuncConsts.FaBao) then
			local funcOpenCfg = t_funcOpen[FuncConsts.FaBao]
			if funcOpenCfg then
				local questCfg = t_quest[funcOpenCfg.open_prama]
				if questCfg then
					TipsManager:ShowBtnTips(string.format(StrConfig['wuhun58'],questCfg.minLevel,questCfg.name));
				end
			end
		end
		return
	end
	UISpiritsSkillTips:Open(wuhunId);
end

function UIMainSkill:OnBtnWuhunOut()
	UISpiritsSkillTips:Close();
	TipsManager:Hide();
end

function UIMainSkill:OnBtnWuhunClick()
	self:OnBtnWuhunOut();
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not FuncManager:GetFuncIsOpen(FuncConsts.FaBao) then
		FloatManager:AddNormal( StrConfig["wuhun59"], objSwf.btnWuhun);
		return
	end
	if UIWuhunSwitch:IsShow() then
		UIWuhunSwitch:Hide()
	else
		UIWuhunSwitch:Show(objSwf.btnWuhun._target)
	end
end

function UIMainSkill:ShowNuQi()
	--todo
	if true then return; end

	local objSwf = self.objSwf;
	if not objSwf then return; end
	local info = MainPlayerModel.humanDetailInfo;
	if info.eaMaxWuHunSP == 0 then
		objSwf.siNuQi.maximum = 9;
		objSwf.siNuQi.value = 0;
	else
		objSwf.siNuQi.maximum = info.eaMaxWuHunSP;
		objSwf.siNuQi.value = info.eaWuHunSP;
	end
end

function UIMainSkill:ShowSlider()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.sliderHp.track.visible = false;
	objSwf.sliderHp.value = AutoBattleModel.takeDrugHp or AutoBattleConsts.DefTakeDrugHp;
end

-----------------------------------------------经验显示↓------------------------------------------------------

--设置经验条
local expIncrease = 0
function UIMainSkill:ShowExp(exp, oldExp)
	if exp ~= nil and oldExp ~= nil then
		expIncrease = exp - oldExp
	end
	local objSwf = self.objSwf;
	if not objSwf then return end
	local info = MainPlayerModel.humanDetailInfo;
	local maxExp = 0;
	if t_lvup[info.eaLevel] then
		maxExp = t_lvup[info.eaLevel].exp;
	else
		maxExp = info.eaExp;
	end
	if oldExp and objSwf.siExp.maximum ~= maxExp then
		--发生升级
		objSwf.siExp.isPlayBig = true;
		objSwf.siExp.maximum = maxExp;
		local tweenExp = info.eaExp;
		objSwf.siExp:tweenProgress( tweenExp, maxExp, 1);
	else
		objSwf.siExp:tweenProgress( info.eaExp, maxExp, 0);
	end

	 objSwf.txtExp.text = string.format( "%s/%s(%s%%)", _G.getNumShow3( info.eaExp ), _G.getNumShow3( maxExp ),string.format("%.2f",(info.eaExp/maxExp*100)))
end
--经验条满格时特效
function UIMainSkill:ShowFullExpEffect()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.siExp._visible = false;
	if UIFullExp:IsShow() then
		UIFullExp:Hide()
		UIFullExp:Show()
	else
		UIFullExp:Show()
	end
end
function UIMainSkill:ShowSiExp()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.siExp._visible = true;
	UIFullExp:Hide()
end
function UIMainSkill:OnSiExpComplete(e)
	if expIncrease <= 0 then return end
	local label = self:GetExpFloatMc()
	label.text = "+" .. toint(expIncrease, 0.5)
	label._x      = e.target.indicatorX
	label._y      = 80
	label._alpha  = 100
	Tween:To( label, UIMainSkill.FLOAT_TIME, { _y = label._y - UIMainSkill.FLOAT_DISTANCE,
		_alpha = 0, ease = Quart.easeInOut }, { onComplete = function()
			self:ReturnExpFloatMc( label )
		end} )
end

local floatExpMcPool = {} -- 经验漂浮文字池
function UIMainSkill:GetExpFloatMc()
	local objSwf = self.objSwf
	if not objSwf then return end
	local depth = objSwf:getNextHighestDepth()
	local mc = table.remove( floatExpMcPool ) or objSwf:attachMovie( "LabelExpFloat",--TextField
		self:GetFloatMcName(), depth )
	return mc
end

function UIMainSkill:ReturnExpFloatMc(mc)
	if #floatExpMcPool < 10 then
		table.push( floatExpMcPool, mc )
		return
	end
	mc:removeMovieClip()
	mc = nil;
end

local mcCount = 0
function UIMainSkill:GetFloatMcName()
	mcCount = mcCount + 1
	return "floatMC" .. mcCount
end

function UIMainSkill:GetExpPosG()
	local objSwf = self.objSwf
	if not objSwf then return end
	local posXL = objSwf.siExp.indicatorX
	local posYL = 155
	return UIManager:PosLtoG( objSwf, posXL, posYL )
end
function UIMainSkill:GetTrueExpPosG()
	local objSwf = self.objSwf
	if not objSwf then return end
	local posXL = objSwf.siExp._x
	local posYL = 155
	return UIManager:PosLtoG( objSwf, posXL, posYL )
end

-----------------------------------------------经验显示↑------------------------------------------------------


-----------------------------------HP-----------------------
function UIMainSkill:SetHp()
	local objSwf = self.objSwf
	if not objSwf then return end
	local info = MainPlayerModel.humanDetailInfo;
	local hp, maxHp = info.eaHp, info.eaMaxHp
	objSwf.siHp.maximum = info.eaMaxHp;
	objSwf.siHp.value = info.eaHp;
	--objSwf.lowHpEffect._visible = (hp / maxHp) < 0.1
end
---------------------------------MP-------------------
function UIMainSkill:SetMp()
	local objSwf = self.objSwf
	if not objSwf then return end
	local info = MainPlayerModel.humanDetailInfo;
	local mp, maxMp = info.eaMp, info.eaMaxMp
	objSwf.siMp.maximum = info.eaMaxMp;
	objSwf.siMp.value = info.eaMp;



end

--血量Tips
function UIMainSkill:OnHPRollOver()
	self:ShowHpTips();
	self.isMouseOverHp = true;
end
function UIMainSkill:OnMPRollOver()
	self:ShowMpTips();
end
function UIMainSkill:OnHPRollOut()
	TipsManager:Hide();
	self.isMouseOverHp = false;
end
function UIMainSkill:OnMPRollOut()
	TipsManager:Hide();
end
function UIMainSkill:OnSliderHpChange()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local value = objSwf.sliderHp.value;
	AutoBattleModel:ChangeCfg( "takeDrugHp", value )
end

function UIMainSkill:OnSliderHpRollOver()
	TipsManager:ShowBtnTips( StrConfig["mainmenuSkill11"] );
end

function UIMainSkill:OnSliderRollOut()
	TipsManager:Hide();
end

function UIMainSkill:OnTakeDrugHpChange(value)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.sliderHp.value = value;
end
function UIMainSkill:ShowHpTips()
	local info = MainPlayerModel.humanDetailInfo;
	if not info then return; end
	local hpTxt = info.eaHp;
	local maxHpTxt = info.eaMaxHp;
	TipsManager:ShowBtnTips( string.format(StrConfig["hpbar1"], hpTxt, maxHpTxt ) );
end
function UIMainSkill:ShowMpTips()
	local info = MainPlayerModel.humanDetailInfo;
	if not info then return; end
	local mpTxt = info.eaMp;
	local maxMpTxt = info.eaMaxMp;
	TipsManager:ShowBtnTips( string.format(StrConfig["mpbar1"], mpTxt, maxMpTxt ) );
end

function UIMainSkill:ShowWuHunDou()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	local playerInfo = MainPlayerModel.humanDetailInfo;
	local wuhunDou = playerInfo.eaWuHunSP or 0
	for i = 1, 6 do
		if i <= wuhunDou then
			objSwf['wuhundou'..i]:gotoAndStop(1)
		else
			objSwf['wuhundou'..i]:gotoAndStop(2)
		end
	end
end

----------------------------技能栏物品---------------------------
function UIMainSkill:ShowShortCutItem()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local slotVO = {};
	slotVO.key = "";
	for i , v in pairs(SetSystemConsts.KeyStrConsts) do
		if i == SkillConsts.ShortCutItemKey then
			slotVO.key = v;
			break;
		end
	end
	if SkillModel.shortCutItem == 0 then
		slotVO.hasItem = false;
	else
		slotVO.hasItem = true;
		slotVO.iconUrl = BagUtil:GetItemIcon(SkillModel.shortCutItem);
		slotVO.lastCd = BagModel:GetItemCD(SkillModel.shortCutItem);
		slotVO.totalCd = BagModel:GetItemTotalCD(SkillModel.shortCutItem);
		slotVO.num = BagModel:GetItemNumInBag(SkillModel.shortCutItem);
	end
	-- print('-------------UIMainSkill:ShowShortCutItem',UIData.encode(slotVO));
	objSwf.scItem:setData(UIData.encode(slotVO));
end

--检查物品消耗
function UIMainSkill:CheckShortCutItem()
	if SkillModel.shortCutItem == 0 then
		return true;
	end
	local num = BagModel:GetItemNumInBag(SkillModel.shortCutItem);
	if num > 0 then
		return true;
	end
	SkillController:ItemShortCut(0);
	return false;
end

function UIMainSkill:OnSCItemClick()
	if SkillModel.shortCutItem == 0 then return; end
	if MainPlayerController.isInterServer then
		FloatManager:AddSkill(StrConfig["mainmenuSkill15"]);
		return;
	end
	local canuse = BagUtil:GetItemCanUse(SkillModel.shortCutItem);
	if canuse < 0 then
		FloatManager:AddSkill(BagConsts:GetErrorTips(canuse));
		return;
	end
	BagController:UseItemByTid(BagConsts.BagType_Bag,SkillModel.shortCutItem,1);
end

function UIMainSkill:OnSCItemRollOver()
	if SkillModel.shortCutItem == 0 then return; end
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end;
	local bagTotalSize = bagVO:GetTotalSize();
	local bagOpenSize = bagVO:GetSize();
	for i=1,bagTotalSize do
		if i<= bagOpenSize then--格子是否开启
			local item = bagVO:GetItemByPos(i-1);
			if item then--格子上有东西
				if item:GetTid() == SkillModel.shortCutItem then
					TipsManager:ShowBagTips(BagConsts.BagType_Bag,i-1);
					return;
				end
			end
		end
	end
	local tipsInfo = {};
	local itemTipsVO = ItemTipsUtil:GetItemTipsVO(SkillModel.shortCutItem,1);
	if not itemTipsVO then return; end
	tipsInfo.tipsShowType = itemTipsVO.tipsShowType;
	tipsInfo.tipsType = itemTipsVO.tipsType;
	tipsInfo.info = itemTipsVO;
	TipsManager:ShowTips(tipsInfo.tipsType,tipsInfo.info,tipsInfo.tipsShowType, TipsConsts.Dir_RightUp);
end

function UIMainSkill:OnSCItemRollOut()
	TipsManager:Hide();
end

function UIMainSkill:OnSCItemSetClick(e)
	UIItemShortCut:Open(e.renderer);
end

function UIMainSkill:ShowSCItemKeyDown(keyDown)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.scItem.keyDownState = keyDown;
end

----------------------家园-----------------------------
function UIMainSkill:CheckFuncBtnState()
	if not self:IsShow() then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	for funcId,btn in pairs(self.funcBtnMap) do
		if FuncManager:GetFuncIsOpen(funcId) then
			btn.disabled = false;
		else
			btn.disabled = true;
		end
	end
end

function UIMainSkill:OnFuncBtnClick(funcId)
	if MainPlayerController.isInterServer then return; end
	if FuncManager:GetFuncIsOpen(funcId) then
		FuncManager:OpenFunc(funcId);
	end
end

function UIMainSkill:OnFuncBtnRollOver(funcId)
	local func = FuncManager:GetFunc(funcId);
	if not func then return; end
	func:OnBtnRollOver();
end

function UIMainSkill:OnFuncBtnRollOut()
	TipsManager:Hide();
end
---------------------引导接口--------------------------
function UIMainSkill:GetWuhunSkillItem()
	if not self:IsShow() then return; end
	local objSwf = self.objSwf;
	return objSwf.skillList:getRendererAt(8);
end

function UIMainSkill:DoPlayWuhunSkill()
	local slotVO = self:GetSkillSlotVO(8)
	if not slotVO then return; end
	SkillController:PlayCastSkill(slotVO.skillId)
end

function UIMainSkill:GetWuhunBtn()
	if not self:IsShow() then return nil; end
	return self.objSwf.btnWuhun;
end

function UIMainSkill:GetFabaoBtn()
	if not self:IsShow() then return nil end
	return self.objSwf.btnFabao
end

function UIMainSkill:GetHomeBtn()
	if not self:IsShow() then return nil; end
	return self.objSwf.btnHome;
end
function UIMainSkill:GetFaliPosG()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	local posXL = objSwf.siMp._x+objSwf.siMp._width/2;
	local posYL = objSwf.siMp._y + 10;
	return UIManager:PosLtoG( objSwf, posXL, posYL )
end
function UIMainSkill:PlayEffZhuan()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.effZhuan:playEffect(1);
end
------------------------------------------------------------------------------------------

-------------------------------跨服中的处理-----------------------------------------------
function UIMainSkill:CheckInterServer()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	for funcId,btn in pairs(self.funcBtnMap) do
		if funcId ~= FuncConsts.Homestead then
			btn.visible = not MainPlayerController.isInterServer;
		end
	end
end


--- 获取item9位置用于定位
function UIMainSkill:GetItemNinePos()
	local objSwf = self.objSwf
	if not objSwf then return nil end
	return UIManager:PosLtoG(objSwf.item9, 0, -200)
end
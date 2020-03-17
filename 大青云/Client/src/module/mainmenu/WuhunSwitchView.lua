--[[武魂切换
ly
]]

_G.UIWuhunSwitch = BaseUI:new("UIWuhunSwitch");
local dy = 0
function UIWuhunSwitch:Create()
	self:AddSWF("wuhunSwitchPanel.swf", false, "highTop");
end

function UIWuhunSwitch:OnLoaded(objSwf)
	objSwf.tileListWuhun.itemClick = function(e) self:SwitchWuhun(e) end
	objSwf.tileListWuhun.itemRollOut  = function(e) TipsManager:Hide(); UISpiritsSkillTips:Close(); end
	objSwf.tileListWuhun.itemRollOver = function(e) self:showWuhunTips(e); end
end

function UIWuhunSwitch:OnShow()
	self:ShowWuHun()
end

function UIWuhunSwitch:OnHide()
	TipsManager:Hide();
	UISpiritsSkillTips:Close();
end

function UIWuhunSwitch:GetHeight()
	return 120;
end

function UIWuhunSwitch:GetWidth()
	return 318
end

function UIWuhunSwitch:OnResize(dwWidth,dwHeight)
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf._y = objSwf._y + dy
end

-------------------------------武魂处理-----------------------
function UIWuhunSwitch:ShowWuHun()
	local objSwf = self.objSwf
	if not objSwf then return end

	local wuhunActList = LinshouModel:GetActWuhunList()
	
	objSwf.tileListWuhun.dataProvider:cleanUp() 
	local wuhunVo = {}--空
	wuhunVo.isEmpty = true
	wuhunVo.imgUrl = ResUtil:GetWuhunMainIcon("empty");
	objSwf.tileListWuhun.dataProvider:push( UIData.encode(wuhunVo) )
	local wuhunNum = 1
	
	if SpiritsModel.selectedWuhunId then
		local wuhunVo = {}--武魂
		wuhunVo.isEmpty = false
		
		--当前使用的是神兽
		if SpiritsModel.selectedWuhunId < SpiritsConsts.SpiritsDownId then
			wuhunVo.wuhunId = SpiritsModel.currentWuhun.wuhunId
		else
			wuhunVo.wuhunId = SpiritsModel.selectedWuhunId
		end
		
		local cfg = t_wuhun[wuhunVo.wuhunId];
		if cfg then
			wuhunVo.imgUrl = ResUtil:GetWuhunMainIcon(cfg.main_icon);
		else
			wuhunVo.imgUrl = "";
		end
		
		objSwf.tileListWuhun.dataProvider:push( UIData.encode(wuhunVo) )
		wuhunNum = wuhunNum + 1
	end
	
	if #wuhunActList > 0 then
		for k,v in pairs(wuhunActList) do
			wuhunVo = {}
			wuhunVo.isEmpty = false
			wuhunVo.wuhunId = nil
			wuhunVo.skinId = v
			local cfg = t_wuhunachieve[v];
			if cfg then
				wuhunVo.imgUrl = ResUtil:GetWuhunMainIcon(cfg.main_icon);
			else
				wuhunVo.imgUrl = "";
			end
			
			objSwf.tileListWuhun.dataProvider:push( UIData.encode(wuhunVo) )
		end
		wuhunNum = wuhunNum + #wuhunActList
	end
	
	local row = toint(wuhunNum/5) + 1
	dy = -146
	objSwf.bg._height = 41 + row*54 + 14
	dy = dy + (3-row)*54
	
	objSwf.tileListWuhun:invalidateData()
	objSwf._y = objSwf._y + dy
end

function UIWuhunSwitch:SwitchWuhun(e)
	if e.item.isEmpty then
		SpiritsController:AhjunctionWuhun(e.item.wuhunId, 0)
		SpiritsController:AhjunctionWuhunshenshou(e.item.wuhunId, 0)
	elseif e.item.wuhunId then
		if SpiritsModel:GetFushenWuhunId() == e.item.wuhunId then 
			self:Hide();
			return 
		end
		self:OnGuideClick()
		SpiritsController:AhjunctionWuhun(e.item.wuhunId, 1)
	else
		if e.item.skinId then
			if SpiritsModel:GetFushenWuhunId() == e.item.skinId then 
				self:Hide();
				return
			end
			if LinshouUtil:GetLinshouTime(e.item.skinId) ~= 0 then
				SpiritsController:AhjunctionWuhun(e.item.skinId, 1)
			end
		end
	end
	self:Hide()
end

function UIWuhunSwitch:showWuhunTips(e)
	if e.item.isBg then
		return
	end
	local wuhunId = 0
	if e.item.isEmpty then
		TipsManager:ShowBtnTips(StrConfig["wuhun56"],TipsConsts.Dir_RightDown);
	elseif e.item.wuhunId then
		wuhunId = e.item.wuhunId
	elseif e.item.skinId then
		wuhunId = e.item.skinId
	end
	
	if wuhunId == 0 then return end
	UISpiritsSkillTips:Open(wuhunId);
end
----------------------------------  点击任务接口 ----------------------------------------
function UIWuhunSwitch:GetWuhunItem()
	if not self:IsShow() then return; end
	return self.objSwf.wuhunItem2;
end

-- 自动附身灵兽
function UIWuhunSwitch:AutoSelectLinshou()
	local wuhunId = SpiritsModel:GetWuhunId()
	-- FPrint('自动附身灵兽')
	if wuhunId then
		-- FPrint('自动附身灵兽'..wuhunId)
		SpiritsController:AhjunctionWuhun(wuhunId, 1)
	end
end

function UIWuhunSwitch:OnGuideClick()
	QuestController:TryQuestClick( QuestConsts.WuhunCoalesceClick ) -- 引导任务
end

function UIWuhunSwitch:HandleNotification(name,body)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.StageClick then
		--功能引导中，屏蔽
		if not FuncOpenController.keyEnable then return; end
		--
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

function UIWuhunSwitch:ListNotificationInterests()
	return {NotifyConsts.StageClick,NotifyConsts.StageFocusOut};
end
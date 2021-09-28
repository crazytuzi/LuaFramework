require "Core.Module.Common.UIComponent"
TargetFigthLabelPanel = class("TargetFigthLabelPanel", UIComponent)

local tremove = table.remove
local tinsert = table.insert
local maxNum = 30
local labels = {}
local cacheLabels = {}
local timer
function TargetFigthLabelPanel._OnTimerHandler()
	local ls = labels
	local len = #ls
	if len == 0 then return end
	local t = os.clock()
	for i = len, 1, - 1 do
		local l = ls[i]
		if t - l.startTime < 0.9 then break end
		l:Recycle()
		tremove(ls)
		tinsert(cacheLabels, l)
	end
end
--st伤害来源
function TargetFigthLabelPanel.Add(role, num, status, st)
	local l
	if #cacheLabels ~= 0 then l = tremove(cacheLabels) end
	if not l then
		if #labels < maxNum then
			l = TargetFigthLabelPanel:New()
			l:LoadUI()
		else
			l = tremove(labels)
		end
	end
	l:SetRole(role)
	l:SetValue(num, status, st)
	l:Play()
	l.startTime = os.clock()
	tinsert(labels, 1, l)
	
	if not timer then
		timer = Timer.New(TargetFigthLabelPanel._OnTimerHandler, 0.1, - 1, false);
		timer:Start()
	end
end
function TargetFigthLabelPanel.Clear()
	local ls = labels
	for i = 1, #ls do
		local l = ls[i]
		l:Recycle()
		tinsert(cacheLabels, l)
	end
	labels = {}
	if timer then timer:Stop() timer = nil end
end


TargetFigthLabelPanel.MISS = 3;
TargetFigthLabelPanel.ABSORPTION = 4
local crit = LanguageMgr.Get("attr/crit")
local fatal = LanguageMgr.Get("attr/fatal")
local eva = LanguageMgr.Get("attr/eva")
local absorption = LanguageMgr.Get("TargetFigthLabelPanel/absorption")
local random = math.random
local color = Color.New(1, 1, 1, 1)
local outScreenPos = Vector3(- 1000, - 1000, 0)
local parent = Scene.instance.uiHurtNumParent
local WorldToUI = UIUtil.WorldToUI
local SetPos = Util.SetPos
function TargetFigthLabelPanel:New()
	self = {};
	setmetatable(self, {__index = TargetFigthLabelPanel});
	return self;
end

function TargetFigthLabelPanel:LoadUI()
	local ui = UIUtil.GetUIGameObject(ResID.UI_TARGETFIGHTLABELPANEL, parent);
	self:Init(ui.transform);
end

function TargetFigthLabelPanel:SetRole(role)
	if(role) then
		self._role = role;
		self._roleTopTransform = role:GetTop();
		local pt = WorldToUI(self._roleTopTransform.position);
		pt.z = 0;
		SetPos(self._transform, pt.x, pt.y, pt.z)
	end
end

function TargetFigthLabelPanel:SetValue(num, status, st)
   
	num = num or 0;
	status = status or 0;
	st = st or 0
	local role = self._role;
        
	if(role) then
		if(st == 3 and num <= 0) then
			local top, bottom = ColorDataManager.GetPetHurtColor();
			self._txtLabel.fontSize = 45;
			self._txtLabel.gradientTop = top;
			self._txtLabel.gradientBottom = bottom;
			self._txtLabel.text = num;
		elseif(role.roleType == ControllerType.HERO) then
			self:_SetHeroFightLabel(num, status, st);
		else
			self:_SetTargetFightLabel(num, status, st);
		end
	end
end

-- 设置英雄战斗数字
function TargetFigthLabelPanel:_SetHeroFightLabel(num, status)
	
	if(self._txtLabel) then
		if(num > 0 and status ~= TargetFigthLabelPanel.ABSORPTION) then
			-- 恢复
			local top, bottom = ColorDataManager.GetFightTreatColor();
			self._txtLabel.fontSize = 38;
			self._txtLabel.gradientTop = top;
			self._txtLabel.gradientBottom = bottom;
			self._txtLabel.text = "+" .. num;
		else
			if(status == 0) then
				-- 普通
				local top, bottom = ColorDataManager.GetHeroHurtColor();
				self._txtLabel.fontSize = 20;
				self._txtLabel.gradientTop = top;
				self._txtLabel.gradientBottom = bottom;
				self._txtLabel.text = num;
			elseif(status == 1) then
				-- 暴击
				local top, bottom = ColorDataManager.GetHeroCritHurtColor();
				self._txtLabel.fontSize = 20;
				self._txtLabel.gradientTop = top;
				self._txtLabel.gradientBottom = bottom;
				self._txtLabel.text = num;
				-- self._txtLabel.text = "暴击" .. num;
			elseif(status == 2) then
				-- 必杀
				local top, bottom = ColorDataManager.GetHeroFatalHurtColor();
				self._txtLabel.fontSize = 20;
				self._txtLabel.gradientTop = top;
				self._txtLabel.gradientBottom = bottom;
				self._txtLabel.text = num;
				-- self._txtLabel.text = "必杀" .. num;
			elseif(status == TargetFigthLabelPanel.MISS) then
				-- 闪避
				local top, bottom = ColorDataManager.GetHeroMissColor();
				self._txtLabel.fontSize = 20;
				self._txtLabel.gradientTop = top;
				self._txtLabel.gradientBottom = bottom;
				self._txtLabel.text = eva;
			elseif(status == TargetFigthLabelPanel.ABSORPTION) then
				-- 吸收
				local top, bottom = ColorDataManager.GetHeroAbsorptionColor();
				self._txtLabel.fontSize = 20;
				self._txtLabel.gradientTop = top;
				self._txtLabel.gradientBottom = bottom;
				self._txtLabel.text = absorption;
			end
		end
	end
end

-- 设置目标战斗数字
function TargetFigthLabelPanel:_SetTargetFightLabel(num, status)
	if(self._txtLabel) then
		if(num > 0 and status ~= TargetFigthLabelPanel.ABSORPTION) then
			-- 恢复
			local top, bottom = ColorDataManager.GetFightTreatColor();
			self._txtLabel.fontSize = 28;
			self._txtLabel.gradientTop = top;
			self._txtLabel.gradientBottom = bottom;
			self._txtLabel.text = "+" .. num;
		else
			if(status == 0) then
				-- 普通
				local top, bottom = ColorDataManager.GetTargetHurtColor();
				self._txtLabel.fontSize = 28;
				self._txtLabel.gradientTop = top;
				self._txtLabel.gradientBottom = bottom;
				self._txtLabel.text = num;
			elseif(status == 1) then
				-- 暴击
				local top, bottom = ColorDataManager.GetTargetCritHurtColor();
				self._txtLabel.fontSize = 44;
				self._txtLabel.gradientTop = top;
				self._txtLabel.gradientBottom = bottom;
				self._txtLabel.text = crit .. num;
			elseif(status == 2) then
				-- 必杀
				local top, bottom = ColorDataManager.GetTargetFatalHurtColor();
				self._txtLabel.fontSize = 44;
				self._txtLabel.gradientTop = top;
				self._txtLabel.gradientBottom = bottom;
				self._txtLabel.text = fatal .. num;
			elseif(status == TargetFigthLabelPanel.MISS) then
				-- 闪避
				local top, bottom = ColorDataManager.GetTargetMissColor();
				self._txtLabel.fontSize = 28;
				self._txtLabel.gradientTop = top;
				self._txtLabel.gradientBottom = bottom;
				self._txtLabel.text = eva;
			elseif(status == TargetFigthLabelPanel.ABSORPTION) then
				-- 吸收
				local top, bottom = ColorDataManager.GetHeroAbsorptionColor();
				self._txtLabel.fontSize = 28;
				self._txtLabel.gradientTop = top;
				self._txtLabel.gradientBottom = bottom;
				self._txtLabel.text = absorption;
			end
		end
	end
end
function TargetFigthLabelPanel:Play()
	--self._gameObject:SetActive(true)
	if(self._animator) then
		if(random(1, 10) > 5) then
			self._animator:Play("left", - 1, 0)
		else
			self._animator:Play("right", - 1, 0)
		end
	end
end
function TargetFigthLabelPanel:Recycle()
	--self._gameObject:SetActive(false)
	self._role = nil;
	Util.SetPos(self._transform, outScreenPos.x, outScreenPos.y, outScreenPos.z)
end
function TargetFigthLabelPanel:_Init()
	local trsContent = UIUtil.GetChildByName(self._gameObject, "Transform", "trsContent");
	self._txtLabel = UIUtil.GetChildByName(trsContent, "UILabel", "txtLabel");
	self._txtLabel.color = color;
	self._animator = trsContent:GetComponent("Animator");
end
function TargetFigthLabelPanel:_Dispose()
	self._txtLabel = nil;
	self._animator = nil;
	self._role = nil;
	Resourcer.Recycle(self._gameObject, true);
end 
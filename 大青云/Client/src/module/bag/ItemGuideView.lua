--[[
物品提醒使用UI
lizhuangzhuang
2015年5月5日12:24:19
]]

_G.UIItemGuide = BaseUI:new("UIItemGuide");

UIItemGuide.list = {};
UIItemGuide.currVO = nil;

--不再提醒
UIItemGuide.noTipsMap = {};

UIItemGuide.isTweenHide = false;

function UIItemGuide:Create()
	if Version:IsLianYun() then
		self:AddSWF("itemGuideLianYun.swf",true,"top");
	else
		self:AddSWF("itemGuide.swf",true,"top");
	end
end

function UIItemGuide:OnLoaded(objSwf)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	objSwf.btnConfirm.click = function() self:OnBtnConfirmClick(); end
end

function UIItemGuide:NeverDeleteWhenHide()
	return true;
end

function UIItemGuide:IsTween()
	return true;
end

UIItemGuide.TweenScale = 50;
--打开效果
function UIItemGuide:TweenShowEff(callback)
	SoundManager:PlaySfx(2054);
	local objSwf = self.objSwf;
	local endX,endY = self:GetCfgPos();
	local startX = endX + self:GetWidth()/2 - self:GetWidth()*self.TweenScale/100/2;
	local startY = endY + self:GetHeight()/2 - self:GetHeight()*self.TweenScale/100/2;
	--
	objSwf._x = startX;
	objSwf._y = startY;
	objSwf._alpha = 50;
	objSwf._xscale = self.TweenScale;
	objSwf._yscale = self.TweenScale;
	--
	Tween:To( self.objSwf, 0.3, {_alpha = 100,_xscale=100,_yscale=100,_x=endX,_y=endY,ease=Back.easeInOut},
			{onComplete=callback});
end

--关闭效果
function UIItemGuide:TweenHideEff(callback)
	local objSwf = self.objSwf;
	local startX,startY = self:GetCfgPos();
	local endX = startX + self:GetWidth()/2 - self:GetWidth()*self.TweenScale/100/2;
	local endY = startY + self:GetHeight()/2 - self:GetHeight()*self.TweenScale/100/2;
	--
	objSwf._x = startX;
	objSwf._y = startY;
	objSwf._alpha = 100;
	objSwf._xscale = 100;
	objSwf._yscale = 100;
	--
	self.isTweenHide = true;
	Tween:To( self.objSwf, 0.3, {_alpha = 0,_xscale=self.TweenScale,_yscale=self.TweenScale,_x=endX,_y=endY,ease=Back.easeInOut},
			{onComplete=function()
				self.isTweenHide = false;
				callback();
			end});
end

function UIItemGuide:DoTweenShow()
	self:TweenShowEff(function()
		self:DoShow();
	end);
end

function UIItemGuide:DoTweenHide()
	self:TweenHideEff(function()
		self:DoHide();
	end);
end

function UIItemGuide:OnShow()
	self:ShowInfo();
	self:PlayEffects(true);
end

function UIItemGuide:OnHide()
	self:PlayEffects(false);
end

function UIItemGuide:PlayEffects(play)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if play then
		-- objSwf.edgeEffect:playEffect(0);
	else
		-- objSwf.edgeEffect:stopEffect();
	end
end

function UIItemGuide:ShowInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.cbNoTip.selected = false;
	local cfg = t_itemguide[self.currVO.id];
	if not cfg then return; end
	objSwf.tfTitle.htmlText = cfg.title;
	if self.currVO.text and self.currVO.text~="" then
		objSwf.tfContent.htmlText = self.currVO.text;
	else
		objSwf.tfContent.htmlText = cfg.content;
	end
	objSwf.btnConfirm.label = cfg.btntxt;
	if objSwf.txtbg then
		objSwf.txtbg._visible = self.currVO.id == 6 -- shihun
	end
end

function UIItemGuide:ShowNext()
	if #self.list <= 0 then
		self.currVO = nil;
		self:Hide();
		return;
	end
	self:TweenHideEff(function()
		self.currVO = nil;
		if #self.list > 0 then
			self.currVO = table.remove(self.list,1,1);
			self:TweenShowEff();
			self:ShowInfo();
		else
			self:Hide();
		end
	end);
end

function UIItemGuide:OnBtnCloseClick()
	if self.isTweenHide then
		return;
	end
	local objSwf = self.objSwf;
	if objSwf and objSwf.cbNoTip.selected then
		self.noTipsMap[self.currVO.id] = true;
	end
	self:ShowNext();
end

function UIItemGuide:OnBtnConfirmClick()
	if self.isTweenHide then
		return;
	end
	local objSwf = self.objSwf;
	if objSwf and objSwf.cbNoTip.selected then
		self.noTipsMap[self.currVO.id] = true;
	end
	--
	local cfg = t_itemguide[self.currVO.id];
	if cfg then
		if cfg.type == 1 then
			if cfg.param1 ~= "" then
				QuestScriptManager:DoScript(cfg.param1);
			end
		end
	end
	self:ShowNext();
end

---------------------------------------------------
function UIItemGuide:Open(id,text)
	if self.noTipsMap[id] then
		return;
	end
	local cfg = t_itemguide[id];
	if not cfg then return; end
	if not FuncManager:GetFuncIsOpen(cfg.fun_id) then return; end
	if self.currVO and self.currVO.id==id then return; end
	for i,vo in ipairs(self.list) do
		if vo.id == id then
			vo.text = text;
			return;
		end
	end
	local vo = {};
	vo.id = id;
	vo.text = text;
	if self.currVO then
		table.push(self.list,vo);
	elseif self.isTweenHide then
		table.push(self.list,vo);
	else
		self.currVO = vo;
		self:Show();
	end
end

--关闭所有
function UIItemGuide:CloseAll()
	self.list = {};
	self.currVO = nil;
	self:Hide();
end
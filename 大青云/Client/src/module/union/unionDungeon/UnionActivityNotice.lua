--[[
帮派活动提醒
wangshuai
]]
_G.UIUnionAcitvity = BaseUI:new("UIUnionAcitvity")

UIUnionAcitvity.showName = "";
UIUnionAcitvity.showTime = "";
UIUnionAcitvity.imgScore = "";
UIUnionAcitvity.IsOpen = false;
UIUnionAcitvity.curid = 0;
UIUnionAcitvity.IsShowState = false;
function UIUnionAcitvity:Create()
	self:AddSWF("unionactivityNotice.swf",true,"bottom")
end;

function UIUnionAcitvity:OnLoaded(objSwf)
	objSwf.mc.button.click = function() self:OnGoActiv() end;
	objSwf.mc.button.rollOver = function() self:OnActivOver() end;
	objSwf.mc.button.rollOut = function() self:OnActivOut() end;
	objSwf.mc.btnClose.click = function() self:OnCloseBottom() end;
end;

function UIUnionAcitvity:SetShowState(bo)
	self.IsShowState = bo;
	if self.IsShowState ==  true then
		self:Hide();
	end;
end;

function UIUnionAcitvity:OnCloseBottom()
	self:SetShowState(true)
end;

function UIUnionAcitvity:OnActivOver()
	UIUnionActivityNoticeTips:ShowTips(self.curid)
end;

function UIUnionAcitvity:OnActivOut()
	UIUnionActivityNoticeTips:Hide();
end;

function UIUnionAcitvity:OnGoActiv()
	--if self.curid == 2 then 
		UIUnion:SetFirstTab( UnionConsts.TabUnionDungeon )
		--UIUnionDungeonMain:SetFirstPanel(UnionDungeonConsts.UnionDungeonMap[self.curid])-- UnionDungeonConsts.WarActi );
		FuncManager:OpenFunc(FuncConsts.Guild)
	-- elseif self.curid == 3 then 
	-- 	UIUnion:SetFirstTab( UnionConsts.TabUnionDungeon )
	-- 	UIUnionDungeonMain:SetFirstPanel( UnionDungeonConsts.CityWarActi );
	-- 	FuncManager:OpenFunc(UnionConsts.FuncConstsGuild)
	-- end;
	self:SetShowState(true)
end;
function UIUnionAcitvity:OnShow()
	self:SetInfo()
	SoundManager:PlaySfx(2047);
end;
function UIUnionAcitvity:SetInfo()
	local objSwf = self.objSwf;
	--objSwf.mc.tf1.text = self.showName;
	objSwf.mc.tf2.text = self.showTime;
	if objSwf.mc.iconLoader.source ~= self.imgScore then 
		objSwf.mc.iconLoader.source = self.imgScore;
	end;
end;

function UIUnionAcitvity:SetShowInfo(id,num)
	if self.IsShowState == true then return end;
	if self.IsOpen == true then return end;
	self.curid = id;
	local cfg = t_guildActivity[id];
	self.showName = cfg.name;
	local t,s,m = self:GetCurtime(num)
	self.showTime = string.format(StrConfig['unionActivity001'],s,m)
	self.imgScore = ResUtil:GetUnionActivityNameURL(cfg.notice_img,true);
	if self:IsShow() then  
		self:SetInfo();
	else
		self:Show();
	end;
end;

function UIUnionAcitvity:OnHide()
	self.IsOpen = false
end;

function UIUnionAcitvity:GetCurtime(tim)
	local t,s,m = CTimeFormat:sec2format(tim)
	if t < 10 then
		t= "0"..t;
	end;
	if s < 10 then 
		s = "0"..s;
	end;
	if m < 10 then 
		m = "0"..m;
	end;
	return t,s,m
end;

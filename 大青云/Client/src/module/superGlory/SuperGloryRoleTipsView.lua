--[[
 人物tips
 wangshuai
]]
_G.UISuperGloryRoleTips = BaseUI:new("UISuperGloryRoleTips")

function UISuperGloryRoleTips:Create()
	self:AddSWF("SuperGloryRoleTitleTips.swf",true,"top")
end;

function UISuperGloryRoleTips:OnLoaded(objSwf)

end;

function UISuperGloryRoleTips:OnShow()
	local objSwf = self.objSwf;
	local info = SuperGloryModel:GetSuperManInfo();
	if not info then 
		self:Hide();
		return 
	end;

	objSwf.desc1.htmlText = StrConfig["SuperGlory810"];

	objSwf.desc3.htmlText = StrConfig["SuperGlory811"];

	local atbname = {"att","def","hp","hit","dodge","cri"};
	local cfg = t_citywar[1]
	local titleDesc = t_title[cfg.title]--t_title[10003];

	local atblist = {};
	for i,info in ipairs(atbname) do
		local vo = {};
		vo.name = AttrParseUtil.AttMap[info];
		vo.vlu = titleDesc[info]
		table.push(atblist,vo)
	end;

	local html = "";
	for i,info in ipairs(atblist) do 
		local name = enAttrTypeName[info.name]
		html = html.."<font color='#d5b772'>"..name.."： </font><font color='#00ff00'>+"..info.vlu.."</font><br/>"
	end;
	objSwf.desc2.htmlText = string.format(StrConfig["SuperGlory812"],html)

	local sour = ResUtil:GetTitleIconSwf(titleDesc.icon)

	local func = function ()
	 	local objSwf = self.objSwf;
	 	if not objSwf then return end;
		objSwf.titleLoader.source = sour;
	end
	UILoaderManager:LoadList({sour},func);	

	local toX ,toY =  TipsUtils:GetTipsPos(self:GetWidth(),self:GetHeight(),TipsConsts.Dir_RightDown,nil)
	objSwf._x = toX;
	objSwf._y = toY;
	self:DrawRole();
end;

function UISuperGloryRoleTips:DrawRole()
	local uiLoader = self.objSwf.modelload;
	
	local vo = {};
	local info = SuperGloryModel:GetSuperManInfo();
	if not info then 
		self:Hide();
		return end;
	vo.prof = info.prof
	vo.arms = info.arms
	vo.dress = info.dress
	vo.shoulder = info.dwShoulder;
	vo.fashionsHead = info.fashionshead
	vo.fashionsArms = info.fashionsdress
	vo.fashionsDress = info.fashionsdress
	vo.wuhunId = info.wuhunId
	vo.wing = info.wing
	vo.suitflag = info.suitflag
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
	self.objAvatar = CPlayerAvatar:new();
	self.objAvatar:CreateByVO(vo);
	--s
	local prof = info.prof; --取玩家职业
    if not self.objUIDraw then
		self.objUIDraw = UIDraw:new("SuperGloryRoleTips", self.objAvatar, uiLoader,
							UIDrawRoleCfg[prof].VPort,UIDrawRoleCfg[prof].EyePos,UIDrawRoleCfg[prof].LookPos,
							0x00000000,"UIRole", prof);
	else
		self.objUIDraw:SetUILoader(uiLoader);
		self.objUIDraw:SetCamera(UIDrawRoleCfg[prof].VPort,UIDrawRoleCfg[prof].EyePos,UIDrawRoleCfg[prof].LookPos);
		self.objUIDraw:SetMesh(self.objAvatar);
	end
	self.meshDir = 0;
	self.objAvatar.objMesh.transform:setRotation(0,0,1,self.meshDir);
	self.objUIDraw:SetDraw(true);
end;

--移除swf对象
function UISuperGloryRoleTips:OnDelete()
	if not self.objUIDraw then return end;
	self.objUIDraw:SetUILoader(nil)
end;

function UISuperGloryRoleTips:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetMesh(nil)
	end;
	if self.objAvatar then 
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end;
end;

function UISuperGloryRoleTips:GetWidth()
	return 548
end;
function UISuperGloryRoleTips:GetHeight()
	return 517
end;

function UISuperGloryRoleTips:Update()
	if not self.bShowState then return end;
	local objSwf = self.objSwf;
	local toX ,toY =  TipsUtils:GetTipsPos(self:GetWidth(),self:GetHeight(),TipsConsts.Dir_RightDown,nil)
	objSwf._x = toX;
	objSwf._y = toY;
end;
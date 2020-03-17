--[[
 至尊排行 坐骑tips
 wangshuai
]]

_G.UISuperGloryMountTips = BaseUI:new("UISuperGloryMountTips")

function UISuperGloryMountTips:Create()
	self:AddSWF("SuperGloryMountTitleTips.swf",true,"top")
end;

function UISuperGloryMountTips:OnLoaded(objSwf)

end;
function UISuperGloryMountTips:OnShow()
	local objSwf = self.objSwf;
	local info = SuperGloryModel:GetSuperManInfo();
	if not info then 
		self:Hide();
		return 
	end;

	objSwf.desc1.htmlText = StrConfig["SuperGlory813"];
	objSwf.desc3.htmlText = StrConfig["SuperGlory814"];


	local mountcfg = t_horseskn[201];
	if not mountcfg then return end;
	local atblist = AttrParseUtil:Parse(mountcfg.skin_attr);


	local html = "";
	for i,info in ipairs(atblist) do 
		local name = enAttrTypeName[info.type]
		html = html.."<font color='#ad70ff'>"..name.."： </font><font color='#ad70ff'>+"..info.val.."</font><br/>"
	end;

	objSwf.desc2.htmlText = string.format(StrConfig["SuperGlory815"],html);
	local toX ,toY =  TipsUtils:GetTipsPos(self:GetWidth(),self:GetHeight(),TipsConsts.Dir_RightDown,nil)
	objSwf._x = toX;
	objSwf._y = toY;
	self:DrawMount()
end;

function UISuperGloryMountTips:DrawMount()
	local mountcfg = t_horseskn[201];
	local info = SuperGloryModel:GetSuperManInfo();
	if not info then 
		self:Hide();
		return end;
	local modelid = mountcfg["model"..info.prof]
	if not modelid then return end;
	local objSwf = self.objSwf;
	if not objSwf then return end;

	local mountAvatar = CHorseAvatar:new(modelid)
	mountAvatar:Create(modelid);
	
	self.curModel = mountAvatar;
	local drawcfg = UIDrawMountConfigMax[modelid]
	if not drawcfg then 
		drawcfg = self:GetDefaultCfg();
		return 
	end;
	
	if not self.objUIDraw then 
		self.objUIDraw = UIDraw:new("SuperGloryMountTips",mountAvatar, objSwf.modelload,  
			drawcfg.VPort,   drawcfg.EyePos,  
			drawcfg.LookPos,  0x00000000,"UIMount");
	else 
		self.objUIDraw:SetUILoader(objSwf.modelload);
		self.objUIDraw:SetCamera(drawcfg.VPort,drawcfg.EyePos,drawcfg.LookPos);
		self.objUIDraw:SetMesh(mountAvatar);
	end;
	-- 模型旋转
	self.curModel.objMesh.transform:setRotation(0,0,1,drawcfg.Rotation);
	self.objUIDraw:SetDraw(true);

end;
--移除swf对象
function UISuperGloryMountTips:OnDelete()
	if not self.objUIDraw then return end;
	self.objUIDraw:SetUILoader(nil)
end;

function UISuperGloryMountTips:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetMesh(nil);
	end
	if self.curModel then
		self.curModel = nil
	end
end;

function UISuperGloryMountTips:GetWidth()
	return 548
end;
function UISuperGloryMountTips:GetHeight()
	return 517
end;

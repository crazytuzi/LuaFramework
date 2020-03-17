--[[
灵力获取帮助
wangshuai
]]

_G.UILingLiGet = BaseUI:new("UILingLiGet")

UILingLiGet.lenght = 7;

function UILingLiGet:Create()
	self:AddSWF("lingligetPanel.swf",true,"top")
end;

function UILingLiGet:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:Hide() end;
	for i=1,self.lenght do 
		objSwf["yindao"..i].click = function() self:OnYingdaoLCick(i)end;
		objSwf["yindao"..i].htmlLabel = StrConfig["lingliyindao10"..i]
	end;
end;


function UILingLiGet:OnShow()

end;

function UILingLiGet:OnHide()

end;

function UILingLiGet:OnYingdaoLCick(type)
	if type == 1 then 
		self:GetHomesJulingwan();
	elseif type == 2 then 
		--self:GetWish();
		self:GetActShuiguoleyuan();
	elseif type == 3 then 
		self:GetUnionAct();
	elseif type == 4 then 
	end;
end;

function UILingLiGet:GetHomesJulingwan()
	if FuncManager:GetFuncIsOpen( FuncConsts.Homestead ) == true then
		if not UIHomesteadMainView:IsShow() then
			FuncManager:OpenFunc( FuncConsts.Homestead, true);
		end
	else
		FloatManager:AddNormal( t_funcOpen[FuncConsts.Homestead].unOpenTips);
		return
	end
	if FuncManager:GetFuncIsOpen( FuncConsts.HuiZhang ) == true then
		if not UILingLiHuiZhangView:IsShow() then
			FuncManager:OpenFunc( FuncConsts.Homestead, true);
		end
	else
		FloatManager:AddNormal( t_funcOpen[FuncConsts.HuiZhang].unOpenTips);
	end
end;

function UILingLiGet:GetRihuan()

end;

function UILingLiGet:GetActShuiguoleyuan()
	if FuncManager:GetFuncIsOpen( FuncConsts.Activity ) == true then
		if not UIActivity:IsShow() then
			FuncManager:OpenFunc( FuncConsts.Activity, true ,10005);
		end
	else
		FloatManager:AddNormal( t_funcOpen[FuncConsts.Activity].unOpenTips);
	end
end;

function UILingLiGet:GetUnionAct()
	if FuncManager:GetFuncIsOpen( FuncConsts.Guild ) == true then
		UIUnion:SetFirstTab( UnionConsts.TabUnionDungeon )
		if not UIUnionManager:IsShow() then
			FuncManager:OpenFunc( FuncConsts.Guild, true );
		end
	else
		FloatManager:AddNormal( t_funcOpen[FuncConsts.Guild].unOpenTips);
	end
end;

function UILingLiGet:GetWish()
	if FuncManager:GetFuncIsOpen( FuncConsts.qiyuanWish ) == true then
		if not UIWishPanel:IsShow() then
			FuncManager:OpenFunc( FuncConsts.qiyuanWish, true );
		end
	else
		FloatManager:AddNormal( t_funcOpen[FuncConsts.qiyuanWish].unOpenTips);
	end
end;

function UILingLiGet:GetQiyuQuest()

end;
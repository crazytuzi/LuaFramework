--[[
商城特惠
2015年10月23日10:27:25
haohu
]]

_G.UIShoppingMallTehui = BaseUI:new("UIShoppingMallTehui")

function UIShoppingMallTehui:Create()
	self:AddSWF("shoppingMallTehui.swf", true, nil)
end

function UIShoppingMallTehui:OnLoaded( objSwf )
	objSwf.list.buyClick = function(e) self:OnBtnBuyClick(e)end;
	objSwf.list.iconRollOver = function(e) self:OnIconOver(e) end;
	objSwf.list.iconRollOut = function() TipsManager:Hide(); end;
	objSwf.loader1.hitTestDisable = true
	objSwf.loader2.hitTestDisable = true
end

function UIShoppingMallTehui:OnShow()
	self:ShowList()
	self:ShowType()
	self:Show3DModel()
end

function UIShoppingMallTehui:OnBtnBuyClick(e)
	local id = e.item.id;
	UIShopBuyConfirm:Open(id, ShopConsts.Policy_Single)
end

function UIShoppingMallTehui:OnIconOver(e)
	local cid = e.item.id;
	local cfg = t_shop[cid];
	if not cfg then
		Debug("not find cfg in t_shop,cid is :",cid)
	end
	TipsManager:ShowItemTips(cfg.itemId,1,TipsConsts.Dir_RightDown);
end

-- 翅膀，时装，小黄人
-- 改为翅膀，小黄人，时装
function UIShoppingMallTehui:ShowList()
	local objSwf = self.objSwf
	if not objSwf then return end
	local seq = { 1, 2, 3 }
	objSwf.list.dataProvider:cleanUp()
	for _, i in ipairs(seq) do
		if self.listUIData[i] then
			objSwf.list.dataProvider:push( self.listUIData[i] )
		end
	end
	objSwf.list:invalidateData()
end

function UIShoppingMallTehui:ShowType()
	local objSwf = self.objSwf
	if not objSwf then return end

	-- 再翅膀阶数标题就改下两行
	-- objSwf.item1.mengchong:gotoAndPlay("chibang2")
	objSwf.item1.mengchong:gotoAndPlay("mengchong")
	
	objSwf.item1.jueban:gotoAndPlay("xianshi")
	objSwf.item2.mengchong:gotoAndPlay("tianshen")
	objSwf.item2.jueban:gotoAndPlay("jueban")
	objSwf.item3.mengchong:gotoAndPlay("chibang3")
	objSwf.item3.jueban._visible = false
end

function UIShoppingMallTehui:Show3DModel()
	self:ShowChibangModel()
	self:ShowTianShen()
	self:ShowMengChongModel()
--	self:ShowShizhuangModel()
end

function UIShoppingMallTehui:ShowChibangModel()
	local objSwf = self.objSwf
	if not objSwf then return end
	local cfg = self.list[3] and self.list[3]:GetItemCfg()
	if not cfg then return end
--[[	if cfg.modelDraw == "" then return; end
	local senName = "";
	local t = split(cfg.modelDraw,"#");
	if #t == 1 then
		senName = t[1];
	else
		senName = t[MainPlayerModel.humanDetailInfo.eaProf];
	end]]
	local senName = "v_wing_qingluanyuyi_ui.sen"
	if not senName or senName=="" then return; end
	local loader = objSwf.loader3
	if not self.objUIDraw3 then
		self.objUIDraw3 = UISceneDraw:new( "tehui3", loader, _Vector2.new(500, 600) );
	end
	self.objUIDraw3:SetScene( senName );
	self.objUIDraw3:SetDraw( true );
end

function UIShoppingMallTehui:ShowTianShen()
	local objSwf = self.objSwf
	if not objSwf then return end
	local cfg = self.list[2] and self.list[2]:GetItemCfg()
	if not cfg then return end
	if cfg.modelDraw == "" then return; end
	local senName = "";
	local t = split(cfg.modelDraw,"#");
	if #t == 1 then
		senName = t[1];
	else
		senName = t[MainPlayerModel.humanDetailInfo.eaProf];
	end
	senName = "v_shangcheng_tianshen.sen"
	if not senName or senName=="" then return; end
	local loader = objSwf.loader2
	if not self.objUIDraw2 then
		self.objUIDraw2 = UISceneDraw:new( "tehui2", loader, _Vector2.new( 480, 600) );
	end
--[[	self.objUIDraw2:SetScene( senName, function()
		local mesh = self.objUIDraw2:GetNodeMesh("v_bs_pilimowang_fmt");
		if mesh then
			local pos = mesh.transform:getTranslation();
			mesh.transform:setTranslation(pos.x,pos.y, -5);
			mesh.transform:mulScalingLeft(_Vector3.new( 1.2, 1.2, 1.2 ));
		end
	end );]]
	self.objUIDraw2:SetScene( senName );
	self.objUIDraw2:SetDraw( true );
end

function UIShoppingMallTehui:ShowMengChongModel()
	local objSwf = self.objSwf
	if not objSwf then return end
	local cfg = self.list[1] and self.list[1]:GetItemCfg()
	if not cfg then return end
	if cfg.modelDraw == "" then return; end
	local senName = "";
	local t = split(cfg.modelDraw,"#");
	if #t == 1 then
		senName = t[1];
	else
		senName = t[MainPlayerModel.humanDetailInfo.eaProf];
	end
	senName = "v_shangcheng_chongwu.sen"
	if not senName or senName=="" then return; end
	local loader = objSwf.loader1
	if not self.objUIDraw1 then
		self.objUIDraw1 = UISceneDraw:new( "tehui1", loader, _Vector2.new( 340, 600) );
	end
	self.objUIDraw1:SetScene( senName );
	self.objUIDraw1:SetDraw( true );
end

function UIShoppingMallTehui:ShowShizhuangModel()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	local list = FashionsUtil:GetSortFashionsGroupList();
	local listvo = list[1];
	if listvo then
		local groupid = listvo.id
		local loader = objSwf.item3.loader
		local prof = MainPlayerModel.humanDetailInfo.eaProf; --玩家职业
		
		local vo = {};
		local info = MainPlayerModel.sMeShowInfo;
		vo.prof = MainPlayerModel.humanDetailInfo.eaProf
		vo.arms = info.dwArms
		vo.dress = info.dwDress
		vo.shoulder = info.dwShoulder;
		
		for i,cfg in pairs(t_fashions) do
			if cfg then
				if cfg.suit == groupid then
					--武器
					if cfg.pos == 1 then
						vo.fashionsArms = cfg.id;
					--衣服
					elseif cfg.pos == 2 then
						vo.fashionsDress = cfg.id;
					--头
					elseif cfg.pos == 3 then
						vo.fashionsHead = cfg.id;
					end
				end
			end
		end
		
		vo.wuhunId = 0
		vo.wing = 0
		if self.objAvatar then
			self.objAvatar:ExitMap();
			self.objAvatar = nil;
		end
		self.objAvatar = CPlayerAvatar:new();
		self.objAvatar:CreateByVO(vo);
		local EyePos = _Vector3.new(-11,-52,6)
		local LookPos = _Vector3.new(-11,0,0)
		local VPort = _Vector2.new( 800, 800 )
		if not self.objUIDraw then
			self.objUIDraw = UIDraw:new("UIFashionTehui", self.objAvatar, loader,
								VPort, EyePos, LookPos, 0x00000000,"UIFashionTehui", prof);
		else
			self.objUIDraw:SetUILoader(loader);
			self.objUIDraw:SetCamera(VPort, EyePos, LookPos);
			self.objUIDraw:SetMesh(self.objAvatar);
		end
		self.meshDir = 0;
		self.objAvatar.objMesh.transform:setRotation(0,0,1,self.meshDir);
		self.objUIDraw:SetDraw(true);
		--播放特效
		local sex = MainPlayerModel.humanDetailInfo.eaSex;
		local pfxName = "ui_role_sex" ..sex.. ".pfx";
		local name,pfx = self.objUIDraw:PlayPfx(pfxName);
		-- 微调参数
		pfx.transform:setRotationX(UIDrawFashionsRoleConfig[prof].pfxRotationX);
	end
end

function UIShoppingMallTehui:Open(listUIData, list)
	self.listUIData = listUIData
	self.list = list
	self:Show()
end

function UIShoppingMallTehui:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetMesh(nil);
	end
	for i = 1, 3 do
		local uidraw = self["objUIDraw"..i]
		if uidraw then
			uidraw:SetDraw(false);
			uidraw:SetUILoader(nil);
			UIDrawManager:RemoveUIDraw(uidraw);
			self["objUIDraw"..i] = nil;
		end
	end
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
end
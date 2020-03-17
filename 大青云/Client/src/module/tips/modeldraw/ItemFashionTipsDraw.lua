--[[
装备道具画模型
lizhuangzhuang
2015年10月13日20:10:40
]]

_G.ItemFashionTipsDraw = {};

ItemFashionTipsDraw.index = 0;

function ItemFashionTipsDraw:new()
	local obj = {};
	for k,v in pairs(ItemFashionTipsDraw) do
		if type(v) == "function" then
			obj[k] = v;
		end
	end
	return obj;
end

function ItemFashionTipsDraw:GetHeight()
	return 300;
end

function ItemFashionTipsDraw:Enter(uiLoader,groupid)
	uiLoader._y = 160;
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
	ItemFashionTipsDraw.index = ItemFashionTipsDraw.index + 1
	local EyePos = _Vector3.new(-8,-55,9)
	local LookPos = _Vector3.new(-8,0,3)
	if not self.objUIDraw then
		local prof = MainPlayerModel.humanDetailInfo.eaProf; --玩家职业
		self.objUIDraw = UIDraw:new("ItemFashionTips" .. ItemFashionTipsDraw.index, self.objAvatar, uiLoader,
							_Vector2.new(520,520), EyePos, LookPos, 0x00000000 );
	else
		self.objUIDraw:SetUILoader(uiLoader);
		self.objUIDraw:SetCamera(_Vector2.new(520,520), EyePos,LookPos);
		self.objUIDraw:SetMesh(self.objAvatar);
	end
	self.meshDir = 0;
	self.objAvatar.objMesh.transform:setRotation(0,0,1,self.meshDir);
	self.objUIDraw:SetDraw(true);
	--播放特效
	local sex = MainPlayerModel.humanDetailInfo.eaSex;
	local pfxName = "ui_role_sex" ..sex.. ".pfx";
	if self.objUIDraw then
		local name,pfx = self.objUIDraw:PlayPfx(pfxName);
		-- 微调参数
		pfx.transform:setRotationX(UIDrawFashionsRoleConfig[prof].pfxRotationX);
	end
end

function ItemFashionTipsDraw:Exit()
	if not self.objUIDraw then return; end
	self.objUIDraw:SetDraw(false);
	self.objUIDraw:SetUILoader(nil);
	UIDrawManager:RemoveUIDraw(self.objUIDraw);
	self.objUIDraw = nil;
	self.objAvatar:ExitMap();
	self.objAvatar = nil;
end

function ItemFashionTipsDraw:Update()
	self.meshDir = self.meshDir - math.pi/200;
	self.objAvatar.objMesh.transform:setRotation(0,0,1,self.meshDir);
end
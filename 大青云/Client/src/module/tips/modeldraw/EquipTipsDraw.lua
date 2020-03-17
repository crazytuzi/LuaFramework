--[[
装备Tips画模型
lizhuangzhuang
2015年3月13日16:08:37
]]

_G.EquipTipsDraw = {}

EquipTipsDraw.index = 0;

function EquipTipsDraw:new()
	local obj = {};
	for k,v in pairs(EquipTipsDraw) do
		if type(v) == "function" then
			obj[k] = v;
		end
	end
	return obj;
end

function EquipTipsDraw:GetHeight()
	return 200;
end

function EquipTipsDraw:Enter(uiloader,equipId)
	uiloader._y = 96;
	local cfg = t_equip[equipId];
	if not cfg then return; end
	if cfg.modelDraw == "" then return; end
	
	EquipTipsDraw.index = EquipTipsDraw.index + 1;

	self.objUIDraw = UISceneDraw:new("EquipTipsDraw"..EquipTipsDraw.index,uiloader,_Vector2.new(300,200));
	self.objUIDraw:SetScene(cfg.modelDraw);
	self.objUIDraw:SetDraw( true );
end

function EquipTipsDraw:Exit()
	if not self.objUIDraw then return; end
	self.objUIDraw:SetDraw(false);
	self.objUIDraw:SetUILoader(nil);
	UIDrawManager:RemoveUIDraw(self.objUIDraw);
	self.objUIDraw = nil;
end

function EquipTipsDraw:Update()
end
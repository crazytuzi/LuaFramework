--[[
翅膀tips画模型
lizhuangzhuang
2015年7月7日16:15:43
]]

_G.WingTipsDraw = {};

WingTipsDraw.index = 0;

function WingTipsDraw:new()
	local obj = {};
	for k,v in pairs(WingTipsDraw) do
		if type(v) == "function" then
			obj[k] = v;
		end
	end
	return obj;
end

function WingTipsDraw:GetHeight()
	return 250;
end

function WingTipsDraw:Enter(uiloader,wingId,itemId)
	uiloader._y = 60;
	local cfg = t_wing[wingId];
	WingTipsDraw.index = WingTipsDraw.index + 1;
	
	self.objAvatar = CAvatar:new();
	self.objAvatar.avtName = "wingtips";
	if not cfg then Debug("not find wingId in t_wing......",wingId,itemId) return end
	self.objAvatar:SetPart("Body",cfg.tipsSkn);
	self.objAvatar:ChangeSkl(cfg.tipsSkl);
	self.objAvatar:ExecAction(cfg.tipsSan,true);  --执行动作
	
	local drawCfg = UIDrawWingTipsCfg[itemId];
	if not drawCfg then
		drawCfg = {
			EyePos = _Vector3.new(0,-55,10),
			LookPos = _Vector3.new(0,0,-6),
			VPort = _Vector2.new(310,350),
		};
	end
	
	self.objUIDraw = UIDraw:new("WingTipsDraw"..WingTipsDraw.index,self.objAvatar,uiloader,
								drawCfg.VPort,drawCfg.EyePos,drawCfg.LookPos,
								0x00000000,"UIWing");
	self.objUIDraw:SetDraw(true);
end

function WingTipsDraw:Exit()
	if not self.objUIDraw then return; end
	self.objUIDraw:SetDraw(false);
	self.objUIDraw:SetUILoader(nil);
	UIDrawManager:RemoveUIDraw(self.objUIDraw);
	self.objUIDraw = nil;
	self.objAvatar = nil;
end

function WingTipsDraw:Update()

end
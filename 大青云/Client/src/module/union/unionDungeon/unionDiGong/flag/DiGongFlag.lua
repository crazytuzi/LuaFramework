--[[
设置模型，模型管理
zhangshuhui
]]
_G.DiGongFlag = {};

function DiGongFlag:NewDiGongFlag(cfg)
	local flag = {};
	setmetatable(flag,{__index = DiGongFlag})
	flag.x = cfg.x;
	flag.y = cfg.y;
	flag.type = "digongflag";
	flag.avatar = DiGongFlagAvatar:NewFlagAvatar()

	flag.avatar:InitAvatar();
	return flag;
end;
-- getId
function DiGongFlag:GetConfigId()
	return 0;
end;
--   设置数据，播放默认动作
function DiGongFlag:ShowDiGongFlag()
	self.avatar:EnterMap(self.x,self.y,0);
	self.avatar:ExecIdleAction() -- 播放默认动作
	self:ShowPfx()
end;

function DiGongFlag:ShowPfx()
	self.avatar:PlayerPfx(10020)
end

--- 得到坐标
function DiGongFlag:GetPos()
	if self.avatar then
		local pos = self.avatar:GetPos()
		if pos then
			return {x = pos.x, y = pos.y, z = pos.z}
		else
			return {x = self.x, y = self.y, z = 0}
		end
	else
		return {x = self.x, y = self.y, z = 0}
	end
end



local pos = _Vector3.new()
local name2d = _Vector2.new()
local pos2d = _Vector2.new()
local FlagFont = _Font.new("SIMHEI", 12, 0, 1, true)
function DiGongFlag:Update()
	if not UnionDiGongModel:GetIsAtUnionActivity() then return; end
	if not UnionDiGongModel:GetIsShowFlag() then return; end
	local faidx, faidy = UnionDiGongModel:GetFlagPos();
	local roleXy = MainPlayerController:GetPlayer():GetPos()
	local dx = roleXy.x - faidx;
	local dy = roleXy.y - faidy;
	local dist = math.sqrt(dx*dx+dy*dy);
	if dist > 200 then 
		return 
	end;

	local cfg = CUICardConfig[999]
    local mePos = self:GetPos()

    pos.x = 0
    pos.y = 0
    pos.z = 0--cfgFlag.flagHeight or 1

    pos.x = mePos.x + pos.x
    pos.y = mePos.y + pos.y
    pos.z = mePos.z + pos.z
    _rd:projectPoint( pos.x, pos.y, pos.z, pos2d)
    --name
    name2d.x, name2d.y = pos2d.x, pos2d.y + 24

    local name = "";
    FlagFont.edgeColor = cfg.title_edgeColor
	name = StrConfig["zhanchang120"];
	FlagFont.textColor = cfg.camp_OurColor
    FlagFont:drawText(name2d.x, name2d.y,
        name2d.x, name2d.y, name, _Font.hCenter + _Font.vTop)
end;



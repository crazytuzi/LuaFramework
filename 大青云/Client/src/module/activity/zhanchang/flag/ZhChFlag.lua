--[[
设置模型，模型管理
wangshuai
]]
_G.ZhChFlag = {};

function ZhChFlag:NewZhChFlag(id,camp)
	local flag = {};
	setmetatable(flag,{__index = ZhChFlag})

	local cfg = ZhChFlagConfig[id];
	flag.id = id;
	flag.camp = camp;
	flag.x = cfg.x;
	flag.y = cfg.y;
	flag.type = "flag";
	flag.faceto = cfg.dir;
	flag.avatar = ZhChFlagAvatar:NewFlagAvatar(id,camp)

	flag.avatar:InitAvatar();
	return flag;
end;
-- getId
function ZhChFlag:GetConfigId()
	return self.id;
end;
--   设置数据，播放默认动作
function ZhChFlag:ShowZhChFlag()
	self.avatar:EnterMap(self.x,self.y,self.faceto);
	self.avatar:ExecIdleAction() -- 播放默认动作
	self:ShowPfx()
end;

function ZhChFlag:ShowPfx()
	if self:GetCamp() then
		self.avatar:PlayerPfx(10020)
	else
		self.avatar:PlayerPfx(10021)
	end
end

function ZhChFlag:GetCamp()
	local rolecmp = ActivityZhanChang:GetMyCamp()
	if self.camp == rolecmp then 
		return true;
	end;
end;

--- 得到坐标
function ZhChFlag:GetPos()
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
function ZhChFlag:Update()
	if not ActivityZhanChang.isAtZhanchangAct then return; end
	local cofid = self.id;
	local faid = ZhChFlagConfig[cofid]
	local MyCamp = ActivityZhanChang:GetMyCamp()

	local roleXy = MainPlayerController:GetPlayer():GetPos()
	local dx = roleXy.x - faid.x;
	local dy = roleXy.y - faid.y;
	local dist = math.sqrt(dx*dx+dy*dy);
	if dist > 200 then 
		return 
	end;

	local cfgFlag = ZhanFlagModelConfig[self.camp];
	if not cfgFlag then 
		return 
	end;
	

	local cfg = CUICardConfig[999]
    local mePos = self:GetPos()

    pos.x = 0
    pos.y = 0
    pos.z = cfgFlag.flagHeight or 1

    pos.x = mePos.x + pos.x
    pos.y = mePos.y + pos.y
    pos.z = mePos.z + pos.z
    _rd:projectPoint( pos.x, pos.y, pos.z, pos2d)
    --name
    name2d.x, name2d.y = pos2d.x, pos2d.y + 24

    local name = "";
    FlagFont.edgeColor = cfg.title_edgeColor
	if MyCamp == cfgFlag.camp then 
		name = StrConfig["zhanchang121"];
		 FlagFont.textColor = cfg.camp_EnemyColor
	else
		name = StrConfig["zhanchang120"];
		 FlagFont.textColor = cfg.camp_OurColor
	end;
    FlagFont:drawText(name2d.x, name2d.y,
        name2d.x, name2d.y, name, _Font.hCenter + _Font.vTop)
end;



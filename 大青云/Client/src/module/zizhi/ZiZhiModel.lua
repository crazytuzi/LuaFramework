--[[
    Created by IntelliJ IDEA.
    
    User: Hongbin Yang
    Date: 2016/11/13
    Time: 3:56
   ]]
ZiZhiModel = Module:new();
ZiZhiModel.armorZZNum = 0;
ZiZhiModel.mingYuZZNum = 0;
ZiZhiModel.magicWeaponZZNum = 0;
ZiZhiModel.lingQiZZNum = 0;
ZiZhiModel.realmZZNum = 0;
ZiZhiModel.mountZZNum = 0;
--1、保甲 2 命玉 3神兵 4 法宝  5境界 6坐骑
function ZiZhiModel:SetZZNum(type, num)
	if type == 1 then
		self.armorZZNum = num;
		self:sendNotification(NotifyConsts.ArmorZZChanged);
	elseif type == 2 then
		self.mingYuZZNum = num;
		self:sendNotification(NotifyConsts.MingYuZZChanged);
	elseif type == 3 then
		self.magicWeaponZZNum = num;
		self:sendNotification(NotifyConsts.MagicWeaponZZChanged);
	elseif type == 4 then
		self.lingQiZZNum = num;
		self:sendNotification(NotifyConsts.LingQiZZChanged);
	elseif type == 5 then
		self.realmZZNum = num;
		self:sendNotification(NotifyConsts.RealmZZChanged);
	elseif type == 6 then
		self.mountZZNum = num;
		self:sendNotification(NotifyConsts.MountZZChanged);
	end
end

--1、保甲 2 命玉 3神兵 4 法宝  5境界 6坐骑
function ZiZhiModel:GetZZNum(type)
	if type == 1 then
		return self.armorZZNum
	elseif type == 2 then
		return self.mingYuZZNum
	elseif type == 3 then
		return self.magicWeaponZZNum
	elseif type == 4 then
		return self.lingQiZZNum
	elseif type == 5 then
		return self.realmZZNum
	elseif type == 6 then
		return self.mountZZNum
	end
end


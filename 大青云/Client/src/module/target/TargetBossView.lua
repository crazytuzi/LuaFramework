--[[
当前选中目标-BOSS
haohu
2014年8月19日19:55:04
]]

_G.UITargetBoss = UITargetMonster:new("UITargetBoss");

function UITargetBoss:UpdateHpBar(objSwf)
	local partNum = t_monster[TargetModel:GetId()].life_count;
	if partNum == 0 then return end
	objSwf.hpbar:init(TargetModel:GetHp(), TargetModel:GetMaxHp(), partNum, t_consts[209].val1, 402);
end

function UITargetBoss:UpdateHp()
	local objSwf = self.objSwf
	if not objSwf then return end
	self.objSwf.hpbar:updateProgress(TargetModel:GetHp(), true);


	local hp = TargetModel:GetHp();
	local maxHp = TargetModel:GetMaxHp();
	if hp and maxHp then
		local hpTxt = toint( hp, -1 );
		local maxHpTxt = toint( maxHp, 1 );
		local tipTxt = string.format("%s/%s", hpTxt, maxHpTxt );
		objSwf.hpNumTxt.htmlText = tipTxt;
	end

end

function UITargetBoss:GetSwfName()
	return "targetBoss.swf";
end

function UITargetBoss:OnHeadLoaded(e)
	local loader = e.target
	local img = loader.content
	local x,y = img._width / 2,img._height / 2;
	img._x = x * -1;
	img._y = y * -1;
end

function UITargetBoss:GetWidth()
	return 481;
end

function UITargetBoss:UpdateIcon()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local iconURL = self:GetIconUrl();
    objSwf.headLoader._visible = false	
	if iconURL and objSwf.headLoader.source ~= iconURL then
		objSwf.headLoader.source = iconURL; --头像
	end
end

function UITargetBoss:UpdateLvl()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	objSwf.txtLevel.text = self:GetLevel();
end
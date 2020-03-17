--[[
Tips的一些公用方法
lizhuangzhuang
2014年7月25日10:49:35
]]

_G.TipsUtils = {};

--Tips坐标相对目标点的偏移
TipsUtils.PosOffsetX = 15;
TipsUtils.PosOffsetY = 15;

--获取Tips的坐标
--@param tipsW		tips宽度
--@param tipsH		tips高度
--@param tipsDir	tips方位
function TipsUtils:GetTipsPos(tipsW,tipsH,tipsDir)
	local rdW = _rd.w;
	local rdH = _rd.h;
	local tipsX = 0;
	local tipsY = 0;
	local targetW = 0;
	local targetH = 0;
	local pos = _sys:getRelativeMouse();--获取鼠标位置
	if not tipsDir then
		tipsDir = TipsConsts.Dir_RightUp;
	end
	if tipsDir == TipsConsts.Dir_RightUp then
		tipsX = pos.x + targetW + self.PosOffsetX;
		tipsX = (tipsX+tipsW)>rdW and pos.x-tipsW-self.PosOffsetX or tipsX;--超出屏幕向左显示		
		tipsY = pos.y - self.PosOffsetY - tipsH;
		tipsY = tipsY<0 and 0 or tipsY;
	elseif tipsDir == TipsConsts.Dir_LeftUp then
		tipsX = pos.x + self.PosOffsetX - tipsW;
		tipsY = tipsX<0 and 0 or tipsX;
		tipsY = pos.y - self.PosOffsetY - tipsH;
		tipsY = tipsY<0 and 0 or tipsY;
	elseif tipsDir == TipsConsts.Dir_LeftDown then
		tipsX = pos.x + self.PosOffsetX - tipsW;
		tipsY = tipsX<0 and 0 or tipsX;
		tipsY = pos.y + targetH + self.PosOffsetY;
		tipsY = (tipsY+tipsH)>rdH and (rdH-tipsH) or tipsY;
	else -- 右下
		tipsX = pos.x + targetW + self.PosOffsetX;
		tipsX = (tipsX+tipsW)>rdW and pos.x-tipsW-self.PosOffsetX or tipsX;--超出屏幕向左显示
		tipsY = pos.y + targetH + self.PosOffsetY;
		tipsY = (tipsY+tipsH)>rdH and (rdH-tipsH) or tipsY;
	end
	tipsY = tipsY<0 and 0 or tipsY;
	tipsX = tipsX<0 and 0 or tipsX;
	return tipsX,tipsY;
end

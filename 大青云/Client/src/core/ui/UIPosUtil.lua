--[[
	UI面板自动调整位置工具
	haohu 2014年8月9日15:58:36
]]

_G.classlist['UIPosUtil'] = 'UIPosUtil'
_G.UIPosUtil = {}
_G.UIPosUtil.objName = 'UIPosUtil'
--[[
	获取UI面板的位置
	@szName: 面板的名称
	@winW, winH: 游戏窗口的宽高
	@panelW, panelH: UI面板的宽高
]]
function UIPosUtil:GetPos( szName, winW, winH, panelW, panelH )
	--配置表中没有的默认位置为水平垂直居中
	local cfgPos = PanelPosConfig[szName] or {center = 0, middle = 0 };
	return UIPosUtil:CalcPos(cfgPos, winW, winH, panelW, panelH);
end

function UIPosUtil:CalcPos(cfgPos, winW, winH, panelW, panelH)
	local xPos, yPos;
	--value如果是[0, 1)之间的数将被解读为百分比(以屏幕尺寸为基数)，1以上的数为像素数
	for alignName, value in pairs(cfgPos) do

		if alignName == "center" then
			xPos = math.abs(value) > 1 and winW/2 - panelW/2 + value or winW/2 - panelW/2 + winW*value;
		elseif alignName == "left" then
			xPos = math.abs(value) > 1 and value or winW*value;
		elseif alignName == "right" then
			xPos = math.abs(value) > 1 and winW - value - panelW or winW - winW*value - panelW;
		end

		if alignName == "middle" then
			yPos = math.abs(value) > 1 and winH/2 - panelH/2 + value or winH/2 - panelH/2 + winH*value;
		elseif alignName == "top" then
			yPos = math.abs(value) > 1 and value or winH*value;
		elseif alignName == "bottom" then
			yPos = math.abs(value) > 1 and winH - value - panelH or winH - winH*value - panelH;
		end

	end
	return toint(xPos,-1), toint(yPos,-1);
end
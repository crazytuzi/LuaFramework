--[[
主界面运营按钮管理
lizhuangzhuang
2015年5月14日16:44:25
]]

_G.YunYingBtnManager = {};

YunYingBtnManager.classMap = {};

--获取按钮对应的控制类
function YunYingBtnManager:GetBtn(id)
	return self.classMap[id];
end

--注册一个按钮的解析类
function YunYingBtnManager:RegisterBtnClass(id,class)
	if self.classMap[id] then
		print("Error:已存在运营按钮解析类.");
		return;
	end
	self.classMap[id] = class;
end

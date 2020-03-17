--[[
卓越Tips
lizhuangzhuang
2015年4月22日15:38:54
]]

_G.UIEquipSuperTips = BaseUI:new("UIEquipSuperTips");

function UIEquipSuperTips:Create()
	self:AddSWF("equipSuperTips.swf",true,"top");
end

function UIEquipSuperTips:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local pos = _sys:getRelativeMouse();
	objSwf._x = pos.x + 25;
	objSwf._y = pos.y + 25;
	--
	local pos = self.args[1];
	for i=1,3 do
		local item = objSwf["item"..i];
		local holeLevel = EquipModel:GetSuperHoleAtIndex(pos,i);
		local cfg = t_superHoleUp[holeLevel];
		if cfg then
			item.loader.source = ResUtil:GetSuperHoleIconUrl(cfg.icon);
			item.tf1.htmlText = "";
			item.tf2.htmlText = string.format(StrConfig["equip508"],holeLevel);
			item.tf3.htmlText = string.format(StrConfig["equip509"],cfg.addPercent);
		else
			item.loader.source = ResUtil:GetSuperHoleDefault();
			item.tf1.htmlText = StrConfig["equip510"];
			item.tf2.htmlText = "";
			item.tf3.htmlText = "";
		end
	end
	
end


function UIEquipSuperTips:HandleNotification(name,body)
	if name == NotifyConsts.StageMove then
		local objSwf = self.objSwf;
		if not objSwf then return; end
		local pos = _sys:getRelativeMouse();
		objSwf._x = pos.x + 25;
		objSwf._y = pos.y + 25;
		
	end
end

function UIEquipSuperTips:ListNotificationInterests()
	return {NotifyConsts.StageMove};
end
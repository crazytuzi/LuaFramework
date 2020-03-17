--[[
UI互斥
lizhuangzhuang
2014年9月11日10:53:35
]]
_G.classlist['UIMutexManager'] = 'UIMutexManager'
_G.UIMutexManager = {};
_G.UIMutexManager.objName = 'UIMutexManager'
--所有需要检查互斥的UI
UIMutexManager.uiList = {};
--特殊互斥关系
UIMutexManager.mutexMap = {
	["UIRole"] = {"UIStorage","UIEquip","UIShopCarryOn","UIDeal"},
	["UIStorage"] = {"UIRole","UIShopCarryOn","UIDeal"},
	["UIEquip"] = {"UIRole","UIBag"},
	["UIShopCarryOn"] = {"UIRole","UIStorage","UIDeal"},
	["UIDeal"] = {"UIStorage","UIRole","UIShopCarryOn"},
	["UIBag"] = {"UIEquip",'UIEquipSmelting','UIConsigmentMain'},
	["UIEquipSmelting"] = {"UIBag"},
	["UIConsigmentMain"] = {"UIBag"},
};

--注册所有类型不是0的UI
function UIMutexManager:Create()
	for i,ui in pairs(UIManager.uiList) do
		if ui:GetPanelType() > 0 then
			table.push(self.uiList,ui);
		end
	end
end

--检查互斥UI
function UIMutexManager:Check(uiName,uiType)
	--特殊互斥关系
	if self.mutexMap[uiName] then
		for i,name in ipairs(self.mutexMap[uiName]) do
			local ui = UIManager:GetUI(name);
			if ui and ui:IsShow() then
				ui:Hide();
			end
		end
	end
	if not uiType then return; end
	if uiType == 0 then return; end
	--
	for i,ui in ipairs(self.uiList) do
		if ui.szName ~= uiName then
			if ui:IsShow() then
				ui:Hide();
			end
		end
	end
end






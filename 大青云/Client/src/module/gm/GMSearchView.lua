--[[
GM查找
lizhuangzhuang
2015-10-14 16:01:00
]]

_G.UIGMSearch = BaseUI:new("UIGMSearch");

function UIGMSearch:Create()
	self:AddSWF("gmSearch.swf",true,"center");
end

function UIGMSearch:OnLoaded(objSwf)
	objSwf.btnClose.click = function() self:Hide(); end
	objSwf.btnSearch.click = function() self:OnBtnSearchClick(); end
	objSwf.list.itemClick = function(e) self:OnListItemClick(e); end
end

function UIGMSearch:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.input.text = "";
	objSwf.list.dataProvider:cleanUp();
	objSwf.list:invalidateData();
end

function UIGMSearch:OnBtnSearchClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local name = objSwf.input.text;
	if name == "" then
		FloatManager:AddCenter(StrConfig["gm026"]);
		return;
	end
	GMController:GMSearch(name);
end


function UIGMSearch:SetList(list)
	if not self:IsShow() then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.list.dataProvider:cleanUp();
	for i,vo in ipairs(list) do
		local uiVo = {};
		uiVo.id = vo.roleId;
		uiVo.tf1 = vo.name;
		uiVo.tf2 = "Lv." .. vo.level;
		objSwf.list.dataProvider:push(UIData.encode(uiVo));
	end
	objSwf.list:invalidateData();
end

function UIGMSearch:OnListItemClick(e)
	if not e.item then return; end
	local id = e.item.id;
	if not id then return; end
	if id == "0_0" then return; end
	UIGMRoleOper:Open(id);
end

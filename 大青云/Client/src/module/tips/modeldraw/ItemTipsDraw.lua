--[[
装备道具画模型
lizhuangzhuang
2015年10月13日20:10:40
]]

_G.ItemTipsDraw = {};

ItemTipsDraw.index = 0;

function ItemTipsDraw:new()
	local obj = {};
	for k,v in pairs(ItemTipsDraw) do
		if type(v) == "function" then
			obj[k] = v;
		end
	end
	return obj;
end

function ItemTipsDraw:GetHeight()
	return 200;
end

function ItemTipsDraw:Enter(uiloader,itemId, w, h)
	uiloader._y = 150;
	local cfg = t_item[itemId];
	if not cfg then return; end
	if cfg.modelDraw == "" then return; end
	
	ItemTipsDraw.index = ItemTipsDraw.index + 1;
	
	local senName = "";
	local t = split(cfg.modelDraw,"#");
	if #t == 1 then
		senName = t[1];
	else
		senName = t[MainPlayerModel.humanDetailInfo.eaProf];
	end
	if not senName or senName=="" then return; end
	if w then
		self.objUIDraw = UISceneDraw:new("ItemTipsDraw"..ItemTipsDraw.index,uiloader,_Vector2.new(w,h));
	else
		self.objUIDraw = UISceneDraw:new("ItemTipsDraw"..ItemTipsDraw.index,uiloader,_Vector2.new(300,200));
	end
	self.objUIDraw:SetScene(senName);
	self.objUIDraw:SetDraw( true );
end

function ItemTipsDraw:Exit()
	if not self.objUIDraw then return; end
	self.objUIDraw:SetDraw(false);
	self.objUIDraw:SetUILoader(nil);
	UIDrawManager:RemoveUIDraw(self.objUIDraw);
	self.objUIDraw = nil;
end

function ItemTipsDraw:Update()

end
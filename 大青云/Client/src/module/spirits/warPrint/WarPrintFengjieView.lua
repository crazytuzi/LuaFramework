--[[战印分解
wangshuai
]]

_G.UIWarPrintFengjie = BaseUI:new("UIWarPrintFengjie")

UIWarPrintFengjie.isPromot = false;
UIWarPrintFengjie.itemlist = {};
function UIWarPrintFengjie:Create()
	self:AddSWF("spiritWarPrintFenjie.swf",true,nil)
end;

function UIWarPrintFengjie:OnLoaded(objSwf)
	objSwf.closepenel.click = function() self:OnClosePanel()end;

	objSwf.fengjielist.itemClick = function(e) self:OnListClick(e) end;
	objSwf.fengjielist.itemRollOver = function(e) self:OnListOver(e) end;
	objSwf.fengjielist.itemRollOut  = function() TipsManager:Hide() end;

	objSwf.fenjiebtn.click = function() self:OnGoFengjie() end;
end;

function UIWarPrintFengjie:OnShow()
	self:OnShowItemList();
end
function UIWarPrintFengjie:OnGoFengjie()
	local listvo = {};
	for i,info in ipairs(self.itemlist) do 
		if info.state == true then 
			local vo = {};
			vo.pos = info.pos 
			table.push(listvo,vo)
		end;
	end;
	local len = WarPrintUtils:OnGetListLenght(listvo)
	if len <= 0 then
		FloatManager:AddNormal(StrConfig['warprint003']);
	return end;
	-- 提示
	if self.isPromot == false then 
		local okfunb = function (desc) 
			self.isPromot = desc;
			WarPrintController:OnReqItemDebris(listvo)
		end;
		UIConfirmWithNoTip:Open(StrConfig["warprint001"],okfunb);
		return 
	end;
	-- 请求分解
	WarPrintController:OnReqItemDebris(listvo)
end;
function UIWarPrintFengjie:OnListClick(e)
	local objSwf = self.objSwf;
	if not e.item then return end;
	local item = e.item;
	--objSwf.fengjielist.selectedIndex = -1

	for i,vo in ipairs(self.itemlist) do 
		if vo.pos == item.pos then 
			vo.state = not vo.state;
			local UIData = UIData.encode(vo);
			objSwf.fengjielist.dataProvider[i-1] = UIData;
			local uiItem = objSwf.fengjielist:getRendererAt(i-1);
			if uiItem then 
				uiItem:setData(UIData);
			end;
			break;
		end;
	end;
end;

function UIWarPrintFengjie:OnListOver(e)
	if not e.item then return end;
	local item = e.item;
	if not item.bagType or not item.pos then return end;
	local tipsvo = WarPrintUtils:OnGetItemTipsVO(item.bagType,item.pos)
	TipsManager:ShowTips(TipsConsts.Type_SpiritWarPrint,tipsvo,TipsConsts.ShowType_Normal,TipsConsts.Dir_RightDown);
end;
function UIWarPrintFengjie:OnShowItemList()
	local objSwf = self.objSwf;
	self.itemlist = {};
	local list = WarPrintUtils:GetSpiritHaveDataItem(WarPrintModel.spirit_Bag);
	local listvo = {};
	for i,info in pairs(list) do 
		local vo ={};
		WarPrintUtils:OnEquipItemData(info,vo)
		vo.state = false;
		local cfg = WarPrintUtils:OnGetItemCfg(info.tid);
		vo.debris = cfg.debris;
		if cfg.debris > 0 then 
			table.push(self.itemlist,vo)
			table.push(listvo,UIData.encode(vo));
		end;
	end;
	objSwf.fengjielist.dataProvider:cleanUp();
	objSwf.fengjielist.dataProvider:push(unpack(listvo));
	objSwf.fengjielist:invalidateData();
end;

function UIWarPrintFengjie:ListNotificationInterests()
	return {
			NotifyConsts.SpiritWarPrintItemUpdata,
			NotifyConsts.SpiritWarPrintItemRemove,
			NotifyConsts.SpiritWarPrintItemAdd,
		}
end;
function UIWarPrintFengjie:HandleNotification(name,body)
	if not self.bShowState then return end;
	if name == NotifyConsts.SpiritWarPrintItemUpdata then 
		self:OnShowItemList();
	elseif name == NotifyConsts.SpiritWarPrintItemRemove then 
		self:OnShowItemList();
	elseif name == NotifyConsts.SpiritWarPrintItemAdd then 
		self:OnShowItemList();
	end;
end;


function UIWarPrintFengjie:OnClosePanel()
	self:Hide();   
end;

function UIWarPrintFengjie:OnHide()

end;
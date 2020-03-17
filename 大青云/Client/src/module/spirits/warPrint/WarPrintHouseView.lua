--[[
 灵兽印记，仓库
 wangshuai
]]

_G.UIWarPrintHouse = BaseSlotPanel:new("UIWarPrintHouse")

UIWarPrintHouse.SlotTotalNum = 50;
function UIWarPrintHouse:Create()
	self:AddSWF("spiritWarPrintHouse.swf",true, "center")
end;

function UIWarPrintHouse:OnLoaded(objSwf)
	objSwf.closepanel.click = function() self:OnClosePanel()end;
	
	for i=1,self.SlotTotalNum do
		self:AddSlotItem(BaseItemSlot:new(objSwf["houseitem"..i]),i);
	end
end;

function UIWarPrintHouse:OnShow()
	self:OnShowHosueList();
end;

function UIWarPrintHouse:OnDelete()
	self:RemoveAllSlotItem();
end;

-- 左键click
function UIWarPrintHouse:OnItemClick(itemc)
	local item = itemc:GetData();
	if not item.open then return end;
	local list = WarPrintUtils:GetSpiritBagitem(WarPrintModel.spirit_Bag);
	local isChuan = false;
	for i,info in pairs(list) do 
		if info.isdata == false then 
			WarPrintController:OnReqItemSwap(WarPrintModel.spirit_House,item.pos,WarPrintModel.spirit_Bag,info.pos)
			isChuan =  true;
			break;
		end;
	end;
	if isChuan == false then
		FloatManager:AddNormal(StrConfig["warprintstore013"])
		return
	end;
end;
-- 右键click
function UIWarPrintHouse:OnItemRClick(item)

end;
-- 移入
function UIWarPrintHouse:OnItemRollOver(e)
	local item = e:GetData();
	if not item then return end;
	if item.open == false then return end;
	if not item.bagType or not item.pos then return end;
	local tipsvo = WarPrintUtils:OnGetItemTipsVO(item.bagType,item.pos)
	if not tipsvo then 
		print("Log : itemdata UIWarPrintHouse #56",item.bagType,item.pos)
		return 			
	end;
	TipsManager:ShowTips(TipsConsts.Type_SpiritWarPrint,tipsvo,TipsConsts.ShowType_Normal,TipsConsts.Dir_RightDown);
end;
-- 移除
function UIWarPrintHouse:OnItemRollOut(item)
	TipsManager:Hide();
end
--开始拖拽
function UIWarPrintHouse:OnItemDragBegin(item)
	--print("开始拖拽")
end;
-- 拖拽结束
function UIWarPrintHouse:OnItemDragEnd(item)
	--print("拖拽结束")
end;
-- 拖拽中
function UIWarPrintHouse:OnItemDragIn(fromData,toData)
	--print("拖拽中")
	if fromData.bagType==toData.bagType and fromData.pos==toData.pos then
		return;
	end
	if not fromData.open then 
		--当前格子没数据
		return 
	end;

	if toData.open == true then 
		-- 有数据
		if fromData.bagType ~= WarPrintModel.spirit_Wear then 
			-- 不是身上的装备  吞噬
			if fromData.pos == toData.pos and fromData.bagType == toData.bagType then return end; 
			local fromitem = WarPrintUtils:OnGetItem(fromData.bagType,fromData.pos);
			local toitem = WarPrintUtils:OnGetItem(toData.bagType,toData.pos);
			local toCfg = t_zhanyin[toitem.tid];
			if toCfg.ifequip == 1 then 
					FloatManager:AddNormal(StrConfig["warprint008"])
				return 
			end;
			self:OnTunshiDanci(toitem,fromitem)
		elseif fromData.bagType == WarPrintModel.spirit_Wear then
			WarPrintController:OnReqItemSwap(fromData.bagType,fromData.pos,toData.bagType,toData.pos)
		end;
	elseif toData.open == false then 
		-- 没数据 换格子
		WarPrintController:OnReqItemSwap(fromData.bagType,fromData.pos,toData.bagType,toData.pos)
	end;
end;
-- 单次吞噬
function UIWarPrintHouse:OnTunshiDanci(item,beitem)
	local cfg = WarPrintUtils:OnGetItemCfg(item.tid)
	local becfg = WarPrintUtils:OnGetItemCfg(beitem.tid)
	if not becfg then 
		print(debug.traceback(),beitem.tid)
		return end;
	local color = TipsConsts:GetItemQualityColor(becfg.quality)
	local str = string.format(StrConfig["warprint004"],color,becfg.name,becfg.lvl)
	if self.ConfiId then 
		UIConfirm:Close(self.ConfiId)
	end;
	local okfun = function () 
		-- WarPrintController:OnReqItemDuociTunshi(scrbag,scridx,dstbag,dstidx)
		WarPrintController:OnReqItemDuociTunshi(beitem.bagType,beitem.pos,item.bagType,item.pos);
	end;
	self.ConfiId = UIConfirm:Open(str,okfun);

end;

-- function UIWarPrintHouse:OnHouseItemOver(e)
-- 	if not e.item then return end;
-- 	local item = e.item;
-- 	if not item.bagType or not item.pos then return end;
-- 	local tipsvo = WarPrintUtils:OnGetItemTipsVO(item.bagType,item.pos)
-- 	TipsManager:ShowTips(TipsConsts.Type_SpiritWarPrint,tipsvo,TipsConsts.ShowType_Normal,TipsConsts.Dir_RightDown);
-- end;

function UIWarPrintHouse:OnShowHosueList()
	local objSwf = self.objSwf;
	local list = WarPrintUtils:GetSpiritBagitem(WarPrintModel.spirit_House)
	local listvo = {};
	for i,info in ipairs(list) do 
		local vo = {};
		WarPrintUtils:OnEquipItemData(info,vo);
		table.push(listvo,UIData.encode(vo));
	end;
	objSwf.baglist.dataProvider:cleanUp();
	objSwf.baglist.dataProvider:push(unpack(listvo));
	objSwf.baglist:invalidateData();

end;

function UIWarPrintHouse:ShowEquipListADD(pos)
	local item = WarPrintUtils:OnGetItem(WarPrintModel.spirit_House,pos)
	if not item then return end;
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local uidata = {};
	WarPrintUtils:OnEquipItemData(item,uidata)
	objSwf.baglist.dataProvider[pos] = UIData.encode(uidata);
	local uiSlot = objSwf.baglist:getRendererAt(pos);
	if uiSlot then
		uiSlot:setData(UIData.encode(uidata));
	end
end;

function UIWarPrintHouse:ShowEquipListRemove(pos)
	local objSwf = self.objSwf;
	if not objSwf then return; end;
	local item = WarPrintUtils:OnGetItem(WarPrintModel.spirit_House,pos)
	if not item then return end;
	local uidata = {};
	WarPrintUtils:OnEquipItemData(item,uidata)
	objSwf.baglist.dataProvider[pos] = UIData.encode(uidata);
	local uiSlot = objSwf.baglist:getRendererAt(pos);
	if uiSlot then
		uiSlot:setData(UIData.encode(uidata));
	end
end;

function UIWarPrintHouse:ListNotificationInterests()
	return {
			NotifyConsts.SpiritWarPrintItemSwap,
			NotifyConsts.SpiritWarPrintItemUpdata,
			NotifyConsts.SpiritWarPrintItemRemove,
			NotifyConsts.SpiritWarPrintItemAdd,
		}
end;
function UIWarPrintHouse:HandleNotification(name,body)
	if not self.bShowState then return end;
	if name == NotifyConsts.SpiritWarPrintItemSwap then 
		self:OnShowHosueList();
	elseif name == NotifyConsts.SpiritWarPrintItemUpdata then 
		self:ShowEquipListADD(body)
	elseif name == NotifyConsts.SpiritWarPrintItemRemove then 
		self:ShowEquipListRemove(body)
	elseif name == NotifyConsts.SpiritWarPrintItemAdd then 
		self:ShowEquipListADD(body)
	end;
end;



function UIWarPrintHouse:OnClosePanel()
	self:Hide();
end;
function UIWarPrintHouse:OnHide()

end;
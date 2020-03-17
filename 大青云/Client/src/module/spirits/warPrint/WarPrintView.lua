--[[
灵兽战印装备
wangshuai
]]
_G.UIWarPrintEquip = BaseSlotPanel:new("UIWarPrintEquip")

UIWarPrintEquip.SlotTotalNum = 10;
UIWarPrintEquip.FightX = 0;

function UIWarPrintEquip:Create()
	self:AddSWF("SpiritWarPrint.swf",true,nil)
end;

function UIWarPrintEquip:OnLoaded(objSwf)
	objSwf.GoBuyItem.click =function() self:OnGoBuyitem() end;

    --规则
	objSwf.rulesBtn.rollOver = function() TipsManager:ShowBtnTips(StrConfig['wuhun61'],TipsConsts.Dir_RightDown); end
	objSwf.rulesBtn.rollOut = function() TipsManager:Hide(); end
	
	-- objSwf.equiplist.itemClick = function(e) self:OnEquipItemClick(e) end;
	-- objSwf.equiplist.itemRollOver = function(e) self:OnEquipItemOver(e) end;
	-- objSwf.equiplist.itemRollOut = function() TipsManager:Hide() end;
	for i=1,self.SlotTotalNum do
		self:AddSlotItem(BaseItemSlot:new(objSwf["equipitem"..i]),i);
	end
	--战斗力显示位置调整，更加居中
	self.FightX = objSwf.numFight._x
	objSwf.numFight.loadComplete = function()
									objSwf.numFight._x = self.FightX - objSwf.numFight.width / 2
								end

end;


function UIWarPrintEquip:OnDelete()
	self:RemoveAllSlotItem();
end;

function UIWarPrintEquip:OnShow()
	self:OnShowEquipList()
	self:OnSetDebrisNum()
	self:OnShowequipAtb();
	self:UpdateUIDraw();
end;

-- 左键click
function UIWarPrintEquip:OnItemClick(itemc)
	local item = itemc:GetData();
	local list = WarPrintUtils:GetSpiritBagitem(WarPrintModel.spirit_Bag);
	if not item.open then return end;
	local isChuan = false;
	for i,info in pairs(list) do 
		if info.isdata == false then 
			isChuan = true;
			WarPrintController:OnReqItemSwap(WarPrintModel.spirit_Wear,item.pos,WarPrintModel.spirit_Bag,info.pos)
			break;
		end;
	end;
	if isChuan == false then
		FloatManager:AddNormal(StrConfig["warprintstore013"])
		return
	end;
end;
-- 右键click
function UIWarPrintEquip:OnItemRClick(item)
end;

-- 移入
function UIWarPrintEquip:OnItemRollOver(e)
	local item = e:GetData();
	if not item then return end;
	if item.isopen == false then--是否打开 
		local needLv = WarPrintUtils:GetOpenNeedLv(item.pos + 1);
		TipsManager:ShowBtnTips(string.format(StrConfig["warprintstore008"], needLv),TipsConsts.Dir_RightDown);
		return
	end;
	if item.open == false then  --打开后有没有数据
		TipsManager:ShowBtnTips(StrConfig["warprintstore007"],TipsConsts.Dir_RightDown);
		return 
	end;
	if not item.bagType or not item.pos then return end;
	local tipsvo = WarPrintUtils:OnGetItemTipsVO(item.bagType,item.pos)
	if not tipsvo then 
		print("Log : itemdata UIWarPrintEquip #85",item.bagType,item.pos)
		return end;
	TipsManager:ShowTips(TipsConsts.Type_SpiritWarPrint,tipsvo,TipsConsts.ShowType_Normal,TipsConsts.Dir_RightDown);
end;
-- 移除
function UIWarPrintEquip:OnItemRollOut(item)
	TipsManager:Hide();
end
--开始拖拽
function UIWarPrintEquip:OnItemDragBegin(item)
	--print("开始拖拽")
end;
-- 拖拽结束
function UIWarPrintEquip:OnItemDragEnd(item)
	--print("拖拽结束")
end;
-- 拖拽中
function UIWarPrintEquip:OnItemDragIn(fromData,toData)
	--print("拖拽中")
	if not fromData.open then 
		--当前格子没数据
		return 
	end;
	if toData.open == true then 
		-- 有数据 可以做换装备，只是可以。。先不管
		--print(fromData.bagType,toData.bagType);
		WarPrintController:OnReqItemSwap(fromData.bagType,fromData.pos,toData.bagType,toData.pos)
	elseif toData.open == false then 
		-- 没数据 可以做穿装备
		if toData.isopen == false then 
			return 
		end;
		--[[
		--不用判断这个，否则无法拖拽装备战印  yanghongbin/yaochunlong 2016-8-10
		if fromData.quality == 0 then 
			if toData.bagType == WarPrintModel.spirit_Wear then 
				FloatManager:AddNormal(StrConfig["warprint007"])
				return 
			end;
		end;
		]]
		WarPrintController:OnReqItemSwap(fromData.bagType,fromData.pos,toData.bagType,toData.pos)
	end;
end;
-- 分解碎片
function UIWarPrintEquip:OnSetDebrisNum()
	local objSwf = self.objSwf;
	local num = WarPrintModel.curDebris;
	objSwf.decomBtn.text = string.format(StrConfig["warprint006"],num)
end;
--  够买印记
function UIWarPrintEquip:OnGoBuyitem()
	UILianQiMainPanelView:OnTabButtonClick(FuncConsts.LingBao);
end;
--  显示装备属性加成
function UIWarPrintEquip:OnShowequipAtb()
	local objSwf = self.objSwf;
	local atblist = WarPrintUtils:OnGetItemAllAtb();
	local html = "";
	for i,info in pairs(atblist) do 
		if info then 
			local name = enAttrTypeName[i];
			local val = 0;
			if type(info) == "string" then
				val = info;
			else
				val = math.floor(info);
			end

			html = html .. "<font color='#d68637'>"..name..": </font><font color='#cdb64b'>"..val.."<br/></font>"
		end
	end;


	local listcccc = {};
	local atblist = WarPrintUtils:OnGetItemAllAtb(true);
	for i,info in pairs(atblist) do 
		if info then 
			local vo ={}
			vo.type = i;
			vo.val = info;
			table.push(listcccc,vo)
		end
	end;
	objSwf.atbTxt.htmlText = html;
	--更改为venus的战斗力计算
	local fight = PublicUtil:GetFigthValue(listcccc); --EquipUtil:GetFight(listcccc)
	objSwf.numFight.num = fight;
	WarPrintModel.fightScore = fight;
end;
--  显示当前身上装备
function UIWarPrintEquip:OnShowEquipList()
	if not self:IsShow() then return; end
	local objSwf = self.objSwf;
	WarPrintModel:SetOpenState();
	local list = WarPrintUtils:GetSpiritBagitem(WarPrintModel.spirit_Wear)
	local listvo = {};
	for i,info in ipairs(list) do 
		local vo = {};
		WarPrintUtils:OnEquipItemData(info,vo,true);
		table.push(listvo,UIData.encode(vo));
	end;
	objSwf.equiplist.dataProvider:cleanUp();
	objSwf.equiplist.dataProvider:push(unpack(listvo));
	objSwf.equiplist:invalidateData();

	WarPrintUtils:OnGetItemAllAtb()
end;
--更新模型显示
function UIWarPrintEquip:UpdateUIDraw()
	--模型
	if not self.objUIDraw then
		local viewPort = _Vector2.new(1000, 630);
		self.objUIDraw = UISceneDraw:new( "UIWarPrintEquip", self.objSwf.modelLoader, viewPort);
	end
	self.objUIDraw:SetUILoader( self.objSwf.modelLoader);
	self.objUIDraw:SetScene(t_zhanyinmodel[1001].ui_sen);
	self.objUIDraw:SetDraw( true );
end


function UIWarPrintEquip:ListNotificationInterests()
	return {
			NotifyConsts.SpiritWarPrintDebris,
			NotifyConsts.SpiritWarPrintItemSwap,
			NotifyConsts.WuhunLevelUpsucceed,
			NotifyConsts.PlayerAttrChange,
		}
end;
function UIWarPrintEquip:HandleNotification(name,body)
	if not self.bShowState then return end;
	if name == NotifyConsts.SpiritWarPrintDebris then 
		self:OnSetDebrisNum();
	elseif name == NotifyConsts.SpiritWarPrintItemSwap then 
		self:OnShowEquipList();
		self:OnShowequipAtb();
	elseif name == NotifyConsts.WuhunLevelUpsucceed then 
		self:OnShowEquipList();
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaLevel then
			self:OnShowEquipList();
		end
	end;
end;

function UIWarPrintEquip:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
		self.objUIDraw = nil;
	end
	if UIWarPrintExchange:IsShow() then
		UIWarPrintExchange:Hide()
	end;
end;

RegistModules("Bag/PkgConst") -- 常量
RegistModules("Bag/Vo/EquipInfo") -- 装备信息数据元
RegistModules("Bag/Vo/GoodsVo") -- 物品数据元
RegistModules("Bag/PkgModel") -- 背包

RegistModules("Bag/View/CustomTipLayer") -- 提示

RegistModules("Bag/View/PkgCell") -- 格子
RegistModules("Bag/View/PkgInfoPanel") -- 信息面板
RegistModules("Bag/View/PkgPanel") -- 格子面板

RegistModules("Bag/View/MedicineItem") -- 药品单元
RegistModules("Bag/View/MedicineUI") -- 药品ui
RegistModules("Bag/View/MedicinePanel") -- 药品面板

RegistModules("Bag/View/RefinedPanel")

RegistModules("Bag/PkgMainPanel") -- 总容器(管理 标签及其他面板切换)

PkgCtrl = BaseClass(LuaController)
function PkgCtrl:GetInstance()
	if PkgCtrl.inst == nil then
		PkgCtrl.inst = PkgCtrl.New()
	end
	return PkgCtrl.inst
end

function PkgCtrl:__init()
	self:Config()
	self:InitEvent()
	self:RegistProto()
end
function PkgCtrl:Config()
	self.view = nil
	self.model = PkgModel:GetInstance()
end
function PkgCtrl:InitEvent()
	-- print("-- 登入初始数据(仅一次)")
	local initData = function ()
		local login = LoginModel:GetInstance()
		self.model:SetBagGrid(login:GetBagGrid())
		self.model:SetListPlayerEquipments(login:GetListPlayerEquipments())
		self.model:SetListPlayerBags(login:GetListPlayerBags())
		self:ConfigMedicine() -- 初始药品栏
		GlobalDispatcher:DispatchEvent(EventName.BAG_INITED) -- 广播背包数据完成初始化
	end
	if not self.enterHandler then
		local function OnEnterDataHandle()
			GlobalDispatcher:RemoveEventListener(self.enterHandler)
			initData()
		end
		self.enterHandler = GlobalDispatcher:AddEventListener(EventName.ENTER_DATA_INITED, OnEnterDataHandle)
	end

	if not self.reloginHandle then
		self.reloginHandle = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE, function ()
			self.model:ReSet()
			local function OnEnterDataHandle()
				GlobalDispatcher:RemoveEventListener(self.enterHandler)
				initData()
			end
			self.enterHandler = GlobalDispatcher:AddEventListener(EventName.ENTER_DATA_INITED, OnEnterDataHandle)
		end)
	end
end
-- 订阅协议
function PkgCtrl:RegistProto()
	self:RegistProtocal("S_SynBagItem") -- 同步背包
	self:RegistProtocal("S_PutonDrug") -- 装备药品返回
	self:RegistProtocal("S_PutdownDrug") -- 卸下药品返回
	self:RegistProtocal("S_UseItem")-- 使用物品结果
end

-- 协议
-- 同步背包 装备及物品
function PkgCtrl:S_SynBagItem(buff)
	local msg = self:ParseMsg(bag_pb.S_SynBagItem(), buff)
	self.model:SetShowTip(msg.tigTag or 0)
	self.model:SetListPlayerEquipments(msg.listPlayerEquipments)
	self.model:SetListPlayerBags(msg.listPlayerBags)
end
-- 仅 [物品类型]
function PkgCtrl:S_UseItem( buff )
	local msg = self:ParseMsg(bag_pb.S_UseItem(),buff)
	GlobalDispatcher:DispatchEvent(EventName.USE_GOODS, msg.itemId, msg.num) -- 物品id 物品数量
	
	if msg.num ~= 0 then
		local cfg = GoodsVo.GetItemCfg(msg.itemId)
		if cfg then
			if cfg.tinyType == GoodsVo.TinyType.hp or cfg.tinyType == GoodsVo.TinyType.mp then -- 药品类
				if cfg.tinyType == GoodsVo.TinyType.hp then
					self.model:DelwearTableHp(cfg.id)
					GlobalDispatcher:Fire(EventName.USE_RED_MEDICINE)
				else
					self.model:DelwearTableMp(cfg.id)
					GlobalDispatcher:Fire(EventName.USE_BLUE_MEDICINE)
				end
				GlobalDispatcher:Fire(EventName.MEDICINE_CHANGE)
				EffectMgr.PlaySound("731010")
			end
		end
	end
end

function PkgCtrl:PushToWearTab(idx, itemIndex, id, isInit)
	local tab = nil
	if idx == 1 then
		tab = self.model.wearHpTable
	else
		tab = self.model.wearMpTable
	end
	local newTab = {}
	local index = 1
	for k, v in ipairs(tab) do
		if v and v > 0 then
			newTab[index] = v
			index = index + 1
		end
	end
	if isInit then
		if idx == 1 then
			self.model.prevHpTable = clone(self.model.wearHpTable)
			self.model.wearHpTable = newTab
		else
			self.model.prevMpTable = clone(self.model.wearMpTable)
			self.model.wearMpTable = newTab
		end
		return 
	end
	newTab[index] = id
	for i = index + 1, 3 do
		newTab[i] = 0
	end
	if idx == 1 then
		self.model.wearHpTable = newTab
	else
		self.model.wearMpTable = newTab
	end
end

-- 装备药品返回
function PkgCtrl:S_PutonDrug(buff)
	local msg = self:ParseMsg(bag_pb.S_PutonDrug(),buff)
	if msg.drugLumn then
		-- if msg.type == 1 then
		-- 	self.model.wearHpTable[msg.drugLumn.itemIndex+1] = msg.drugLumn.itemId
		-- elseif msg.type == 2 then
		-- 	self.model.wearMpTable[msg.drugLumn.itemIndex+1] = msg.drugLumn.itemId
		-- end
		self:PushToWearTab(msg.type, msg.drugLumn.itemIndex+1, msg.drugLumn.itemId)
		if msg.type == 1 then
			self.model.prevHpTable[msg.drugLumn.itemIndex+1] = msg.drugLumn.itemId
		elseif msg.type == 2 then
			self.model.prevMpTable[msg.drugLumn.itemIndex+1] = msg.drugLumn.itemId
		end
	end
	GlobalDispatcher:DispatchEvent(EventName.MEDICINE_CHANGE)
end
-- 卸下药品返回
function PkgCtrl:S_PutdownDrug(buff)
	local msg = self:ParseMsg(bag_pb.S_PutdownDrug(),buff)
	if msg.drugLumn then
		-- if msg.type == 1 then
		-- 	for k,v in pairs(self.model.wearHpTable) do
		-- 		if k == msg.drugLumn.itemIndex+1 then
		-- 			self.model.wearHpTable[k] = msg.drugLumn.itemId
		-- 		end
		-- 	end
		-- elseif msg.type == 2 then
		-- 	for k,v in pairs(self.model.wearMpTable) do
		-- 		if k == msg.drugLumn.itemIndex+1 then
		-- 			self.model.wearMpTable[k] = msg.drugLumn.itemId
		-- 		end
		-- 	end
		-- end
		self:PopFromWearTab(msg.type, msg.drugLumn.itemIndex+1, msg.drugLumn.itemId)
		if msg.type == 1 then
			for k,v in pairs(self.model.wearHpTable) do
				if k == msg.drugLumn.itemIndex+1 then
					self.model.prevHpTable[k] = msg.drugLumn.itemId
				end
			end
		elseif msg.type == 2 then
			for k,v in pairs(self.model.wearMpTable) do
				if k == msg.drugLumn.itemIndex+1 then
					self.model.prevMpTable[k] = msg.drugLumn.itemId
				end
			end
		end
	end
	GlobalDispatcher:DispatchEvent(EventName.MEDICINE_CHANGE)
end

function PkgCtrl:PopFromWearTab(idx, itemIndex, id)
	local prevTab, tab = nil, nil
	if idx == 1 then
		prevTab = self.model.prevHpTable
		tab = self.model.wearHpTable
	else
		prevTab = self.model.prevMpTable
		tab = self.model.wearMpTable
	end
	local itemId = prevTab[itemIndex]
	for k, v in pairs(tab) do
		if v == itemId then
			tab[k] = 0
		end
	end
	local newTab = {}
	local index = 1
	for k, v in ipairs(tab) do
		if v and v > 0 then
			newTab[index] = v
			index = index + 1
		end
	end
	if idx == 1 then
		self.model.wearHpTable = newTab
	else
		self.model.wearMpTable = newTab
	end
end

-- 登入时 配置装备快捷药品
function PkgCtrl:ConfigMedicine()
	local model = LoginModel:GetInstance()
	local drugHp = model:GetHpDrugLumns()
	local drugMp = model:GetMpDrugLumns()
	for i=1,#drugHp do --药剂 红药
		self.model.wearHpTable[drugHp[i].itemIndex+1] = drugHp[i].itemId
	end
	for i=1,#drugMp do --药剂 蓝药
		self.model.wearMpTable[drugMp[i].itemIndex+1] = drugMp[i].itemId
	end
	--self.model.prevHpTable = clone(self.model.wearHpTable)
	--self.model.prevMpTable = clone(self.model.wearMpTable)
	self:PushToWearTab(1, 0, 0, true)
	self:PushToWearTab(2, 0, 0, true)
	GlobalDispatcher:DispatchEvent(EventName.MEDICINE_CHANGE)
end

--装备一个药
function PkgCtrl:C_PutonDrug(pType,pId)
	local msg = bag_pb.C_PutonDrug()
	msg.type = pType
	msg.itemId = pId
	self:SendMsg("C_PutonDrug",msg)
end
--卸载一个药
function PkgCtrl:C_PutdownDrug(pType,pId)
	print("c_putdown ==>> ", pId)
	local msg = bag_pb.C_PutdownDrug()
	msg.type = pType
	msg.itemId = pId
	self:SendMsg("C_PutdownDrug",msg)
end
-- 眩晕状态下不能使用药品
function PkgCtrl:IsItemCanUse(playerBagId,num)
	local canUse = true
	if num ~= 0 then
		local vo = self.model:GetGoodsVoByServerBagId(playerBagId)
		local sCtrl = SceneController:GetInstance()
		if vo and vo.cfg then
			local cfg = vo.cfg
			if cfg and ( cfg.tinyType == GoodsVo.TinyType.hp or cfg.tinyType == GoodsVo.TinyType.mp ) and sCtrl:IsMainPlayerDizzy() then
				canUse = false
			end
		end
	end
	return canUse
end

-- 使用物品
function PkgCtrl:C_UseItem(playerBagId,num)
	local canUse = self:IsItemCanUse(playerBagId,num)
	if not canUse then return end
	if num == 0 then return end
	local msg = bag_pb.C_UseItem()
	msg.playerBagId = playerBagId
	msg.num = num or 1
	self:SendMsg("C_UseItem",msg)
end

--出售物品
function PkgCtrl:C_SellItem(playerBagId)
	local msg = bag_pb.C_SellItem()
	msg.playerBagId = playerBagId
	self:SendMsg("C_SellItem",msg)
end

--穿上装备
function PkgCtrl:C_PutOnEquipment(id)
 	local msg = equipment_pb.C_PutOnEquipment()
 	msg.playerEquipmentId = id
 	self:SendMsg("C_PutOnEquipment",msg)
 	EffectMgr.PlaySound("731012")
end 
--脱下装备
function PkgCtrl:C_PutDownEquipment(id)
	local msg = equipment_pb.C_PutDownEquipment()
 	msg.playerEquipmentId = id
 	self:SendMsg("C_PutDownEquipment",msg)
end

--整理背包
function PkgCtrl:C_TidyBag()
	self:SendEmptyMsg(bag_pb, "C_TidyBag")
end

-- 打开背包标签: 选定 物品类型bid,  装备类型bid, nil:保持原选择 或以传类型
function PkgCtrl:Open(...)
	local params = {...}
	local k, v = next(params) 
	if k and v then
		local bid = nil
		if type(v)=="table" then
			params = v
		end
		for i,v in ipairs(params) do
			local n = self.model:GetTotalByBid(v)
			if n ~= 0 then
				bid = v
				break
			end
		end
		self.model:SetOpenType(PkgConst.PanelType.bag)
		self.model:SetSelectGoodsBid(bid)
	end
	self:GetMainPanel():Open()
end
function PkgCtrl:Close()
	if self:IsExistView() then
		self:GetMainPanel():Close()
	end
end
-- 直接使用物品bid
function PkgCtrl:UseGoods(bid)
	local item = self.model:GetGoodsVoByBid(bid)
	if item == nil then return end
	self:C_UseItem(item.id,1)
end

-- 打开面板指定标签 t : PkgConst.PanelType, data: 指默认打开相关面板后的指向
function PkgCtrl:OpenByType(t, data)
	self.model:SetOpenType(t)
	if t == PkgConst.PanelType.bag or t == PkgConst.PanelType.composition then
		self.model:SetSelectGoodsBid(data)
	end
	self:GetMainPanel():Open()
end

-- 获取主面板
function PkgCtrl:GetMainPanel()
	if not self:IsExistView() then
		self.view = PkgMainPanel.New()
	end
	return self.view
end
-- 判断主面板是否存在
function PkgCtrl:IsExistView()
	return self.view and self.view.isInited
end

-- 销毁
function PkgCtrl:__delete()
	PkgCtrl.inst = nil
	GlobalDispatcher:RemoveEventListener(self.enterHandler)
	GlobalDispatcher:RemoveEventListener(self.reloginHandle)
	if self:IsExistView() then
		self.view:Destroy()
	end
	self.view = nil
	if self.model then
		self.model:Destroy()
		self.model = nil
	end
end
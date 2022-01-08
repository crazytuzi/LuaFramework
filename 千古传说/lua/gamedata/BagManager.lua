--[[
******游戏数据背包管理类*******

	-- by Stephen.tao
	-- 2013/11/27
]]


local BagManager = class("BagManager")

local itemArray = TFArray:new()
local GameItem = require('lua.gamedata.base.GameItem')
local CardEquipment = require('lua.gamedata.base.CardEquipment')

local CardSkyBook = require('lua.gamedata.base.CardSkyBook');

BagManager.itemArray = itemArray

BagManager.GEM_BULID_RESULT = "GemBulidResult"
BagManager.GEM_ONEKEY_BULID_RESULT = "GemOneKeyBulidResult"
BagManager.ItemAdd = "BagManager.ItemAdd"
BagManager.ItemChange = "BagManager.ItemChange"
BagManager.ItemDel = "BagManager.ItemDel"
BagManager.ITEMBATCH_USED_RESULT = "BagManager.ITEMBATCH_USED_RESULT"
BagManager.SUMMON_PALADIN = "BagManager.SUMMON_PALADIN"
BagManager.EQUIP_PIECE_MERGE = "BagManager.EQUIP_PIECE_MERGE"
BagManager.EQUIP_UPDATE = "BagManager.EQUIP_UPDATE"

function BagManager:ctor( Data )

	self:init(Data)
	self.isUseItem = false
	self:initItemUseMap()
	TFDirector:addProto(s2c.GET_BAG, self, self.getBagInfo)		--获取背包
	TFDirector:addProto(s2c.MULTIPLE_UPDATE, self, self.MultipleUpdate)
	TFDirector:addProto(s2c.CHANGED_STRUCT, self, self.ChangedStruct)
	TFDirector:addProto(s2c.GEM_BULID_RESULT, self, self.GemBulidResult)
	TFDirector:addProto(s2c.AUTO_MERGE_GEM_SUCCESS, self, self.autoMergeGemSuccess)
	TFDirector:addProto(s2c.ITEMBATCH_USED_RESULT, self, self.ItembatchUsedResult)
	TFDirector:addProto(s2c.SUMMON_PALADIN_RESULT, self, self.summonPaladinSuccessCallback)
	TFDirector:addProto(s2c.MERGE_EQUIPMENT_RESULT, self, self.MergeResult)	
end

--背包清零
function BagManager:restart(  )
	for v in itemArray:iterator() do
		v:dispose()
	end
	BagManager.itemArray:clear()
	self.isUseItem = false
end

function BagManager:init( Data )

--[[
------------测试代码啊------------------

	local gameItem = GameItem:new(10076)
	gameItem.num = 10
	self:AddItem(gameItem)

	local gameItem1 = GameItem:new(10077)
	gameItem1.num = 20
	self:AddItem(gameItem1)
-----------测试代码结束了---------------------]]

end

--背包销毁
function BagManager:dispose()

	for v in itemArray:iterator() do
		v.dispose()
	end
	BagManager.itemArray = nil

end

--获取背包道具的数量
function BagManager:getBagNum()
	return BagManager.itemArray:length()
end

--通过当前顺序index获得道具
function BagManager:getItemByIndex( index )
	return itemArray:getObjectAt(index)
end

function BagManager:getItemNumById( id )
	local item = self:getItemById(id);
	if not item then
		return 0;
	end
	return item.num
end

--[[
	--增加道具
]]
function BagManager:AddItem( item )
	if item==nil then
		return
	end
	for v in itemArray:iterator() do
		if v.id == id then
			v.num = v.num + item.num
			return
		end
	end
	itemArray:pushBack(item)
end

--[[
	--通过id获得背包道具信息
	--@返回道具
]]
function BagManager:getItemById( id )
	--print("getItem by : ",id)
	for v in itemArray:iterator() do
		if v.id == id then
			return v
		end
	end
end

--[[--
	返回指定装备类型的装备
	@param itemType: 道具类型
	@return 指定Key值的元素
]]	
function BagManager:getItemByType(itemType)
	if not itemType then
		return itemArray
	end

	local arrary = TFArray:new()
	if type(itemType) ~= 'table' then
		for v in itemArray:iterator() do
			if v.type == itemType then
				arrary:push(v)
			end
		end
	else
		for v in itemArray:iterator() do
			for k,_type in pairs(itemType) do
				if v.type == _type then
					arrary:push(v)
				end
			end
		end
	end
	return arrary
end

function BagManager:getDaojuItemList()
	local arrary = TFArray:new()
	local itemType = {EnumGameItemType.Item,EnumGameItemType.Box,EnumGameItemType.Stuff,EnumGameItemType.Token,EnumGameItemType.RandomPack,EnumGameItemType.HeadPicFrame}
	for v in itemArray:iterator() do
		if v.type == EnumGameItemType.Soul then
			if v.kind == 3 then
				arrary:push(v)
			end
		else
			for k,_type in pairs(itemType) do
				if v.type == _type then
					arrary:push(v)
				end
			end
		end
	end
	return arrary
end

--[[--
	返回指定装备类型的装备
	@param itemType: 道具类型
	@return 指定Key值的元素
]]	
function BagManager:getItemByKind(itemType ,kind)
	if not itemType then
		return itemArray
	end
	if not kind then
		return self:getItemByType(itemType)
	end

	local arrary = TFArray:new()

	if type(kind) ~= 'table' then
		for v in itemArray:iterator() do
			if v.type == itemType and v.kind == tonumber(kind) then
				arrary:push(v)
			end
		end
	else
		for v in itemArray:iterator() do
			if v.type == itemType then
				for _,_kind in pairs(kind) do
					if v.kind == tonumber(_kind) then
						arrary:push(v)
					end
				end
			end
		end
	end
	return arrary
end

--[[
	--通过id及个数删除背包物品
]]
function BagManager:changeItemById( id , num)
	for v in itemArray:iterator() do
		if v.id == id then
			if v.num + num  > 0 then
				v.num = v.num + num
			else
				itemArray:removeObject(v)
				return
			end
		end
	end
end

--[[
	--通过id及个数删除背包物品
]]
function BagManager:DelItemByid( id)
	for v in itemArray:iterator() do
		if v.id == id then
			itemArray:removeObject(v)
			TFDirector:dispatchGlobalEventWith(BagManager.ItemDel,v)
			return
		end
	end
end

--获取背包信息回调
function BagManager:getBagInfo(event)
	print("-------------------------getBagInfo-----------------")
	local data = event.data
	if data.equipmentlist and data.equipmentlist ~= NULL then
		print("equipment list size : ",#data.equipmentlist)
		for _,equip in pairs(data.equipmentlist) do
			--print(equip)
			self:AddEquipByNet(equip)
		end
		print("add equip by Net end : ",#data.equipmentlist)
	end
	if data.ItemInfo and data.ItemInfo ~= NULL then	
		for _,item in pairs(data.ItemInfo) do
			self:AddItemByNet(item,false)
		end
	end
	--added by wuqi
	if data.bibleInfo and data.bibleInfo ~= NULL then
		print("********** test get bibleInfo begin *************")
		-- local count = 0
		for _, item in pairs(data.bibleInfo) do
			-- count = count + 1
			-- print("++++", count, "++++")
			-- print("id = ", item.id)
			-- print("instanceId = ", item.instanceId)
			-- print("level = ", item.level)
			-- print("breachLevel = ", item.breachLevel)
			-- print("roleId = ", item.roleId)
			
			-- if item.essential then
			-- 	print("essentialNum = ", #item.essential)
			-- 	for i = 1, #item.essential do
			-- 		print("essential" .. i .. ":", "pos = ", item.essential[i].pos, "id = ", item.essential[i].id)
			-- 	end
			-- end

			-- print("++++", count, "++++")
			self:AddSkyBookByNet(item, false)
		end
		print("********** test get bibleInfo end *************")
	end
	print("-------------------------getBagInfo  ok--------------")
end

--服务器有多种道具或装备改变回调
function BagManager:MultipleUpdate(event)
	--print("-------------------------MultipleUpdate-----------------")
	local data = event.data
	if data.changedList and data.changedList ~= NULL then
		for _,changedList in pairs(data.changedList) do
			self:ChangedUpdata(changedList)
		end
	end
	--print("-------------------MultipleUpdate     ok-----------")
end

--服务器有单个道具或装备改变回调
function BagManager:ChangedStruct(event)
	--print("-------------------------ChangedStruct-----------------")
	local data = event.data
	self:ChangedUpdata(data)
	--print("-------------------------ChangedStruct  ok------------")
end
--服务器有道具或装备改变回调
function BagManager:ChangedUpdata(data)
	if data.type == 0 then      --creat
		--print("creat")
		if data.equipment ~= nil and data.equipment ~= NULL then
			self:AddEquipByNet( data.equipment)

			local cardRole = CardRoleManager:getIndexByGmid( data.userid );
			TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIP_OPERATION,{gmId = data.userid,equip = data.equipment}); 
		elseif data.item ~= nil and data.item ~= NULL then
			self:AddItemByNet(data.item,true)
		end
	elseif data.type == 1 then    --change
		--print("change")
		if data.equipment ~= nil and data.equipment ~= NULL then
			self:ChangeEquip(data.equipment)
			TFDirector:dispatchGlobalEventWith(BagManager.EQUIP_UPDATE,{}); 
		elseif data.item ~= nil and data.item ~= NULL then
			self:ChangeItemNum(data.item)
		end
	elseif data.type == 2 then 		--delete
		--print("delete")
		if data.equipment ~= nil and data.equipment ~= NULL then
			EquipmentManager:DelEquipmentByGmid(data.equipment.userid)
			TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIP_OPERATION,{gmId = data.userid,equip = data.equipment}); 
		elseif data.item ~= nil and data.item ~= NULL then
			self:DelItemByid(data.item.id)
		end
	end

end
--通过服务器消息增加道具
function BagManager:AddItemByNet( data,notify)
	local gameItem = GameItem:new(data.id)
	gameItem.num = data.num
	self:AddItem(gameItem)
	
	if notify then
		TFDirector:dispatchGlobalEventWith(BagManager.ItemAdd,gameItem)
	end
end

--改变道具数量
function BagManager:ChangeItemNum( data)
	local gameItem = self:getItemById(data.id)
	if gameItem == nil then 
		return
	end
	local oldNum = gameItem.num
	gameItem.num = data.num

	TFDirector:dispatchGlobalEventWith(BagManager.ItemChange,{item = gameItem,oldNum = oldNum})
end

--通过服务器返回消息增加装备
function BagManager:AddEquipByNet( data)
	local cardEquip = CardEquipment:new(data.id)
	cardEquip.gmId = data.userid
	cardEquip:setLevel(data.level)
	cardEquip.quality = data.quality
	cardEquip:setBaseAttribute( data.base_attr )
	cardEquip:setExtraAttribute( data.extra_attr )
	cardEquip:setGrow(data.grow)
	cardEquip.maxGem = data.holeNum
	cardEquip:setStar(data.star)
	cardEquip.refineLevel = data.refineLevel
	cardEquip.failPercent = math.floor(data.starFailFix/100)
	if data.gem then 
		for _,gempos in pairs(data.gem) do
			cardEquip:setGemPos(gempos.pos , gempos.id )
		end
	end
	cardEquip:UpdateAttr()

	--设置重铸
	cardEquip:setRecastInfo(data.recast)

	EquipmentManager:AddEquipment(cardEquip)				--加入背包
end
--通过服务器返回消息增加装备
function BagManager:AddSkyBookByNet(data)
	local skyBook = CardSkyBook:new(data.id)
	skyBook.instanceId = data.instanceId
	skyBook:setLevel(data.level)
	skyBook:setTupoLevel(data.breachLevel)
	skyBook.equip = data.roleId
	if data.essential then
		for _,essential in pairs(data.essential) do
			skyBook:setStonePos(essential.pos , essential.id )
		end
	end
	skyBook:updatePower()


	SkyBookManager:AddSkyBook(skyBook)				--加入背包
end

--added by wuqi
function BagManager:testAddSkyBook()	
	local base_id = 50001
	local step = 5
	for i = 1, 5 do
		local data = {}
		data.id = base_id + (i - 1) * step
		data.instanceId = data.id - 100
		data.level = i
		data.breachLevel = i - 1
		data.essential = {{pos = 1, id = 51001}, {pos = 2, id = 51002}}

		self:AddSkyBookByNet(data)
	end
end

--added by wuqi
function BagManager:testAddBookPiece()
	local base_id = 30095
	for i = 1, 5 do
		local gameItem = GameItem:new(base_id + i - 1)
		gameItem.num = 10
		self:AddItem(gameItem)
	end
end

--added by wuqi
function BagManager:testAddEssential()
	local base_id = 51000
	for i = 1, 5 do
		local gameItem = GameItem:new(base_id + i)
		gameItem.num = 10
		self:AddItem(gameItem)
	end
end

--对装备信息修改
function BagManager:ChangeEquip( data)
	local equip = EquipmentManager:getEquipByGmid(data.userid)
	if equip == nil then 
		return
	end
	print('data----------- ',data)
	--[[
	cardEquip.gmId = data.userid
	cardEquip:setLevel(data.level)
	cardEquip.quality = data.quality
	cardEquip:setBaseAttribute( data.base_attr )
	cardEquip:setExtraAttribute( data.extra_attr )
	cardEquip:setGrow(data.grow)
	cardEquip.maxGem = data.holeNum
	cardEquip:setStar(data.star)
	cardEquip.refineLevel = data.refineLevel
	cardEquip.failPercent = math.floor(data.starFailFix/100)
	]]
	equip:setLevel(data.level)
	equip:setGrow(data.grow)
	equip:setStar(data.star)
	equip.refineLevel = data.refineLevel
	equip.failPercent = math.floor(data.starFailFix/100)

	equip:setBaseAttribute( data.base_attr )
	equip:setExtraAttribute( data.extra_attr )
	equip.maxGem = data.holeNum
	if data.gem then		
		--重置bug
		if #data.gem >= 2 then
			for index,gempos in pairs(data.gem) do
				equip:setGemPos(gempos.pos , gempos.id )
			end
		else
			if data.gem[1] and data.gem[1].pos then
				local gempos = data.gem[1]
				equip:setGemPos(gempos.pos , gempos.id)
				if gempos.pos == 1 then
					equip:setGemPos(2 , nil)
				else
					equip:setGemPos(1 , nil)					
				end	
			end				
		end		
	else
		for i=1,2 do
			equip:setGemPos(i , nil )
		end		
	end	



	equip:UpdateAttr()
	equip:setRecastInfo(data.recast)
end
--出售道具
function BagManager:ItemSell( id , num )
	local Msg = 
	{
		id,
		num,
	}
	TFDirector:send(c2s.ITEM_SELL,Msg)
end
--宝石合成
function BagManager:GemBulid( id , istuhao)
	local Msg = 
	{
		id,
		istuhao,
	}
	TFDirector:send(c2s.GEM_BULID,Msg)
end

--一键合成宝石
function BagManager:autoMergeGemRequest( maxLevel)
	if maxLevel == nil then
		maxLevel = 6
	end
	showLoading()
	TFDirector:send(c2s.AUTO_MERGE_GEM_REQUEST,{maxLevel})
end
--道具出售返回
function BagManager:ItemSellResult( event )
-- //code = 0x1017
-- //道具出售
-- message ItemSellResult{
-- 	required int32 result = 1; //是否成功
-- }
	local data = event.data
	if data.result == 0 then
		
	end
end

--宝石合成返回
function BagManager:GemBulidResult( event )
-- //code = 0x1050
-- //宝石合成
-- message GemBulidResult{
-- 	required int32 result = 1; //是否成功
--	optional bool success = 2; //是否合成成功，当且仅当result为0时发送
-- }
	local data = event.data
	if data.result == 0 then
		TFDirector:dispatchGlobalEventWith(BagManager.GEM_BULID_RESULT,data.success)
	else
		
	end
end
--宝石合成返回
function BagManager:autoMergeGemSuccess( event )
	hideLoading();
	local data = event.data
	local chang = data.change or {}
	TFDirector:dispatchGlobalEventWith(BagManager.GEM_ONEKEY_BULID_RESULT,{chang})
end
function BagManager:ItembatchUsedResult( event )
	-- print("ItembatchUsedResult:",event.data)

	hideLoading();
	local data = event.data
	local item = ItemData:objectByID(data.itemId)
	local num = data.num ;
	local description = item.outline:gsub("#num#", num * item.usable);
	if description~= item.outline then
		toastMessage(description)
	end
	-- if item.id == 30003 then
	-- 	toastMessage("获得铜币 " .. num * item.usable);
	-- elseif item.id == 30010 or item.id == 30018 then
	-- 	toastMessage("获得体力 +" .. num * item.usable);
	-- elseif item.id == 30014 then
	-- 	toastMessage("增加".. item.usable*num .."次无量山挑战次数");
	-- end
	self.isUseItem = false
	TFDirector:dispatchGlobalEventWith(BagManager.ITEMBATCH_USED_RESULT,data.itemId)
	play_lingqu()
end

--注册特殊kind的道具使用回调事件
function BagManager:initItemUseMap()
	self.itemUseFunc = {}
	self.itemUseFunc[18] = self.item_Action_GotoSmithy
	self.itemUseFunc[30] = self.item_Action_Goto_Zhaomu
	self.itemUseFunc[31] = self.item_Action_Goto_Chat
	self.itemUseFunc[32] = self.item_Action_OpenBox
	self.itemUseFunc[47] = self.item_Action_UseFateItem
	self.itemUseFunc[49] = self.item_Action_Goto_ServerChat
	self.itemUseFunc[52] = self.item_Action_Goto_SBShop
	-- self.itemUseFunc[0] = self.item_Action_OpenChoiceBox
end

--使用道具
function BagManager:useItem( itemid ,oneUse)
	if oneUse == nil then
		oneUse = true
	end
	local holdItem = self:getItemById(itemid)
	if holdItem == nil then
		print("玩家没有该物品 id == " ..itemid)
		return
	end
	local item = holdItem.itemdata
	if item == nil then
		print("道具表无此数据 id == " ..itemid)
		return
	end

	-- 增加物品使用等级的判断 king
	local use_level = item.use_level or 0
	if MainPlayer:getLevel() < use_level then
		-- toastMessage("大侠，等级达到"..use_level.."才可以使用")
		toastMessage(stringUtils.format(localizable.BagManager_goods_use_level, use_level))
		return
	end

	--新增M选N礼包
	if item.type == EnumGameItemType.Box then
		local giftPackInfo = GiftPackData:objectByID(itemid)
		if giftPackInfo == nil then
			print("没有该宝箱内物品信息 宝箱id == ",itemid)
			return
		end
		if giftPackInfo.select_count ~= 0 then
			self:item_Action_OpenChoiceBox(itemid)
			return
		end
	end

	--新增随机礼包
	if item.type == EnumGameItemType.RandomPack then
		if holdItem.num > 1 then
			self:openUseMore(itemid)
		else
			self:item_Server_Use(itemid)
		end
		return
	end
	--合成头像框
	if item.type == EnumGameItemType.HeadPicFrame then
		if HeadPicFrameManager:isEnough(item.usable) == true then
			if HeadPicFrameManager:isUnlocked(item.usable) == false then
				BagManager:requestEquipMerge(item.id)
			else
				--toastMessage("不能合成已解锁的头像框!")
				toastMessage(localizable.BagManager_no_compound)
			end
		else
			--toastMessage("道具数量不足，不能合成头像框!")
			toastMessage(localizable.BagManager_buzu_no_compound)
		end
		return
	end

	if self.itemUseFunc and self.itemUseFunc[item.kind] then
		TFFunction.call(self.itemUseFunc[item.kind],self,itemid)
	else
		if holdItem.num > 1 or oneUse == false then
			self:openUseMore(itemid)
		else
			self:item_Server_Use(itemid)
		end
	end
end

function BagManager:CanMergeFrame(frameId)
	if HeadPicFrameManager:isUnlocked(frameId) == true then
		return false
	end
	if HeadPicFrameManager:isEnough(frameId) == false then
		return false
	end
	return true
end

--批量使用道具
function BagManager:useBatchItem( itemid, num )
	showLoading()
	local item = ItemData:objectByID(itemid)

	local Msg = 
	{
		itemid,
		num,
	}
	self.isUseItem = true
	TFDirector:send(c2s.ITEMBATCH_USED,Msg)
end

--打开背包界面
function BagManager:ShowBagLayer( type ,kind )
	local temp = {}
	temp.type = type
	temp.kind = kind
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.bag.BagLayer");
	-- local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.bag.BagLayer2");
    layer:loadData(temp);
    AlertManager:show();
    return layer
end

function BagManager:ShowBagLayerByButtonIndex( index )
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.bag.BagLayer");
    layer:loadData()
    AlertManager:show();
    layer:setSelectedButtonIndex(index)
    return layer
end

--发送使用物品消息
function BagManager:item_Server_Use( itemid )
	--print("BagManager:item_Server_Use( itemid ) : " , itemid)
	local Msg =
	{
		itemid,
	}
	self.isUseItem = true
	TFDirector:send(c2s.ITEM_USED,Msg)
end
--物品使用跳入招募界面
function BagManager:item_Action_Goto_Zhaomu(itemid)
	-- hideLoading()
	AlertManager:close()
	MallManager:openMallLayer()
end
--使用小喇叭进入聊天界面
function BagManager:item_Action_Goto_Chat(itemid)
	-- hideLoading()

    --modify by ZR ,暂时关闭千里传音功能
    --AlertManager:close()
	--ChatManager:showChatLayer()
end
--使用小喇叭进入聊天界面
function BagManager:item_Action_Goto_ServerChat(itemid)
	-- hideLoading()
	AlertManager:close()
	local chatlayer = ChatManager:showChatLayer()
	chatlayer:changeGroupChoice(3)
	chatlayer:refreshUI()
end

--天书商店
function BagManager:item_Action_Goto_SBShop(itemid)
	-- hideLoading()
	AdventureManager:openAdventureMallLayer()
end
--使用精炼石进入精炼
function BagManager:item_Action_GotoSmithy(itemid)
	-- hideLoading()
	AlertManager:close()
	EquipmentManager:OpenSmithyMainLaye()
end
--[[
验证宝箱是否可以打开
返回：0：能够打开；1：没有足够的宝箱；2：没有足够的钥匙；3：不是宝箱和钥匙
]]
function BagManager:isBoxHaveKeyToOpen(itemid)
	for v in BoxKeyCouple:iterator() do
		if v.goods_box_id == itemid or v.goods_box_key_id == itemid then --是宝箱或者钥匙
			local box = self:getItemById(v.goods_box_id)
			local key = self:getItemById(v.goods_box_key_id)
			if box == nil then
				return 1,v.goods_box_id,v.goods_box_key_id
			end
			if key == nil then
				return 2,v.goods_box_id,v.goods_box_key_id
			end
			return 0,v.goods_box_id,v.goods_box_key_id
		end
	end
	return 3
end

--打开宝箱
function BagManager:item_Action_OpenBox(itemid)
	local statusCode,boxId,keyId = self:isBoxHaveKeyToOpen(itemid)
	if statusCode == 1 then
		hideLoading()
		local boxItem = ItemData:objectByID(boxId)
		local keyItem = ItemData:objectByID(keyId)
		-- toastMessage("没有足够的宝箱 ["..boxItem.name .."]")
		toastMessage(stringUtils.format(localizable.BagManager_no_enough_box, boxItem.name))
		
	elseif statusCode == 2 then
		hideLoading()
		local boxItem = ItemData:objectByID(boxId)
		local keyItem = ItemData:objectByID(keyId)
		-- toastMessage("[" .. keyItem.name .. "]不足，可前往商城购买")
		-- toastMessage(stringUtils.format(localizable.BagManager_no_enough_key, keyItem.name))
		MallManager:checkShopOneKey(keyId)

	elseif statusCode == 3 then
		--toastMessage("该物品不是宝箱和钥匙：" .. itemid)
		toastMessage(stringUtils.format(localizable.BagManager_toast_text1, itemid))
	else
		local holdBox = self:getItemById(boxId)
		local holdKey = self:getItemById(keyId)
		local minNum = math.min(holdBox.num,holdKey.num)
		if minNum > 1 then
			self:openUseMore(itemid)
		else
			self:item_Server_Use(itemid)
		end
		return
	end
	
end

function BagManager:item_Action_UseFateItem( itemid )
	CardRoleManager:openRoleInfoByIndex(1)
end

function BagManager:item_Action_OpenChoiceBox(itemid)
	print("----itemid---",itemid)
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.bag.OpenChoiceBox",AlertManager.BLOCK_AND_GRAY,tween);
 	layer:setData(itemid)
    AlertManager:show();
end

function BagManager:goChoice(itemid, index)
	showLoading()
	local msg = {
		itemid,
		index
	}
	print("---msg--",msg)
	TFDirector:send(c2s.CHECK_BOX_USED, msg)	
end



--验证是否已经拥有了该侠魂对应的角色
function BagManager:isAlreadyHasRole(goods)
    local partner = CardRoleManager:getRoleById(goods.itemdata.usable)
    if partner then
        return true
    else
        return false
    end
end

--验证是否已经可以招募该侠魂对应的侠士
function BagManager:isEnoughToRecruit(goods)
    local roleData = RoleData:objectByID(goods.itemdata.usable)
    if roleData then
	    local recruitNum = roleData.merge_card_num
	    if goods.num < recruitNum then
	        return false
	    end
		return true
    end
    return false
end

--[[
    验证是否可招募
]]
function BagManager:isRecruitEnabled(data)
	if data.itemdata.type == EnumGameItemType.Soul and data.itemdata.kind ~=1 then
		return false
	end

    local alreadyHasRole = self:isAlreadyHasRole(data)
    local canRecruit = true
    if alreadyHasRole then
        canRecruit = false
    else
        canRecruit = self:isEnoughToRecruit(data)
    end

    return canRecruit,alreadyHasRole
end

function BagManager:isCanMerge(data)
    local itemdata = data:getData()
    if itemdata.kind < 6 then
    	local equipmentTemplate = EquipmentTemplateData:findByPieceId(itemdata.id)
    	if equipmentTemplate ~= nil then
    	    local needNumber = equipmentTemplate.merge_num
    	    if needNumber > data.num then
    	        return false
    	    else
    	        return true
    	    end
    	end
    else
    	local martialTemplate,needNumber = MartialData:findByMaterial(itemdata.id)
		if martialTemplate ~= nil then
			if needNumber > data.num then
    	        return false
    	    else
    	        return true
    	    end
    	end
	end
end

function BagManager:getBagDisplaySoul()
	local arrary = TFArray:new()
	for v in itemArray:iterator() do
		if v.type == EnumGameItemType.Soul and v.kind ==1 then
			arrary:push(v)
		end
	end
	return arrary
end

--红点判断逻辑
BagManager.canRecruitRPM = EnumServiceType.GOODS * 256 + 1
BagManager.canMergePieceRPM = EnumServiceType.GOODS * 256 + 2
BagManager.haveCanUsePropRPM = EnumServiceType.GOODS * 256 + 3
BagManager.haveGiftRPM = EnumServiceType.GOODS * 256 + 4

--是否该侠魂可招募
function BagManager:isCanZhaomu(id)
	local item = self:getItemById(id)
	return self:isRecruitEnabled(item)
end

--是否有侠魂可招募
function BagManager:isHaveCanZhaomu()
	local enabled = RedPointManager:isRedPointEnabled(BagManager.canRecruitRPM)
	if enabled then
		return true
	end

	for v in itemArray:iterator() do
		if v.type == EnumGameItemType.Soul then
			if self:isRecruitEnabled(v) then
				RedPointManager:isRedPointEnabled(BagManager.canRecruitRPM,true)
				return true
			end
		end
	end
	return false;
end


--是否该碎片可合成
function BagManager:isCanPiece(id)
	local item = self:getItemById(id)
	return self:isCanMerge(item)
end

--是否有碎片可合成
function BagManager:isHaveCanPiece( kind)
	if kind == nil then
		kind = 0 
	end
	for v in itemArray:iterator() do
		if v.type == EnumGameItemType.Piece and (kind == 0 or v.kind == kind) then
			local mergeable = self:isCanPiece(v.itemdata.id)
			if mergeable == true then
				return mergeable
			end
		end
	end
	return false
end

--是否有装备碎片可合成
function BagManager:isHaveCanEquipPiece()
	for v in itemArray:iterator() do
		if v.type == EnumGameItemType.Piece and v.itemdata.kind < 6 then
			local mergeable = self:isCanPiece(v.itemdata.id)
			if mergeable == true then
				return mergeable
			end
		end
	end
	return false
end

--是否该道具可使用
function BagManager:isCanProp(id)
	--只提示宝箱、钥匙、招财神符
	local item = self:getItemById(id)
	if not item then
		return false
	end

	if item.itemdata.type ~= EnumGameItemType.Item and item.itemdata.type ~= EnumGameItemType.Box and item.itemdata.type ~= EnumGameItemType.RandomPack then
		return false
	end
	if item.itemdata.type == EnumGameItemType.Item and item.itemdata.kind == 47 then
		return false
	end
	if item.itemdata.kind == 32 then
		local statusCode = self:isBoxHaveKeyToOpen(id)
		return statusCode == 0
	end

	return item.itemdata.usable ~= 0 
end

--是否该道具可使用
function BagManager:isCanPropQuick(item)
	if not item then
		return false
	end

	if item.itemdata.type == EnumGameItemType.HeadPicFrame then
        return BagManager:CanMergeFrame(item.itemdata.usable)
    end

	if item.itemdata.type ~= EnumGameItemType.Item and item.itemdata.type ~= EnumGameItemType.Box and item.itemdata.type ~= EnumGameItemType.RandomPack then
		return false
	end
	if item.itemdata.type == EnumGameItemType.Item and item.itemdata.kind == 47 then
		return false
	end

	if item.itemdata.kind == 32 then
		local statusCode = self:isBoxHaveKeyToOpen(item.itemdata.id)
		return statusCode == 0
	end

	return item.itemdata.usable ~= 0 
end

--是否有道具可使用
function BagManager:isHaveCanProp()
	for v in itemArray:iterator() do
		if v.kind == 23 then
			return true
		elseif v.kind == 32 then
			--缺少钥匙对数据比较
			local statusCode = self:isBoxHaveKeyToOpen(v.itemdata.id)
			if statusCode == 0 then
				return true
			end
		end
	end
	return false
end

--是否该礼包可使用
function BagManager:isCanGift(id)
	local item = self:getItemById(id)
	if not item then
		return false
	end
	return true
end

--是否有礼包可使用
function BagManager:isHaveCanGift()
	for v in itemArray:iterator() do
		if v.type == EnumGameItemType.Box or v.type == EnumGameItemType.RandomPack then
			return true
		end
	end
	return false;
end

--是否有宝箱
function BagManager:isHaveBox()
	for item in itemArray:iterator() do
		for box in BoxKeyCouple:iterator() do
			if box.goods_box_id == item.itemdata.id then 
				return true
			end
		end
	end
	return false
end


--是否有宝箱
function BagManager:getBox()
	for item in itemArray:iterator() do
		for box in BoxKeyCouple:iterator() do
			if box.goods_box_id == item.itemdata.id then 
				return item
			end
		end
	end
	return nil
end


--是否有可以合成的头像框碎片
function BagManager:isHaveCanFrame()
	for item in itemArray:iterator() do
		if item.type == EnumGameItemType.HeadPicFrame then
			return self:CanMergeFrame(item.itemdata.usable)
		end
	end
	return false
end

--请求服务器召唤侠士
function BagManager:requestSummonPaladin(soulId)
    self.summonSoulId = soulId
    local msg = {
        soulId,
    }
    showLoading()
    TFDirector:send(c2s.SUMMON_PALADIN,msg)
end

--召唤侠士成功回调函数
function BagManager:summonPaladinSuccessCallback(event)
    local data = event.data
    local unitInstance = CardRoleManager:getRoleByGmid(data.instanceId)
    if unitInstance == nil then
        print("server not put partner instance to me. i can not found it.",instanceId)
        return
    end

    hideLoading()
    self.summonSoulId = nil
    TFDirector:dispatchGlobalEventWith(BagManager.SUMMON_PALADIN,unitInstance)
 --    local layer = require("lua.logic.shop.GetHeroResultLayer"):new(unitInstance.id)
	-- AlertManager:addLayer(layer, AlertManager.BLOCK)
	-- AlertManager:show()
end

-- 碎片合成
function BagManager:requestEquipMerge(mergeTargetId)
	-- self.mergeTargetId = mergeTargetId
    local msg = {
        mergeTargetId,
    }

    showLoading()
    TFDirector:send(c2s.MERGE_EQUIPMENT,msg)

    -- local layer = require("lua.logic.bag.BagPieceMergeResult"):new(2)
	-- AlertManager:addLayer(layer, AlertManager.BLOCK_AND_GRAY)
	-- AlertManager:show()
end



function BagManager:MergeResult(event)
    local data = event.data
    local goodId = data.templateId
    if goodId == nil then
        print("server not put partner instance to me. i can not found it.",goodId)
        return
    end

    hideLoading()
    --通知合成成功
    TFDirector:dispatchGlobalEventWith(BagManager.EQUIP_PIECE_MERGE,goodId)

    local item = ItemData:objectByID(goodId)
    --added by wuqi
    if item.type == EnumGameItemType.SBStone then
    	--toastMessage("合成" .. item.name .. "成功")
    	toastMessage(stringUtils.format(localizable.BagManager_compound_success, item.name))
    	return
    end

    local layer = require("lua.logic.bag.BagPieceMergeResult"):new(goodId)
	AlertManager:addLayer(layer, AlertManager.BLOCK_AND_GRAY)
	AlertManager:show()
end


function BagManager:openUseMore( itemid  )
	local layer = require("lua.logic.common.OpenMore"):new(itemid)
	AlertManager:addLayer(layer, AlertManager.BLOCK_AND_GRAY)
	AlertManager:show()
end

return BagManager:new()

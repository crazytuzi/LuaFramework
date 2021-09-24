local BagProxy = classGc(function( self)
    self.m_bInitialized  = false
    self.m_maxcapacity   = 200
    self.m_bagGoodsList  = {}
    self.m_bagSellList   = {}
    self.m_goodsIdxList  = {}
    self.m_SellIdxList   = {}
    self.m_isGoodsSort   = false
    self.m_isGoodsSplit  = false

    self.m_clanlv         =0
    self.m_mainIconTypeArray={}

    self.IsActivityIconCCBIcreate = 0 --精彩活动特效变量
    self.isActivenessCCBIHere     = false

    local mediator=require("mod.support.BagProxyMediator")()
    mediator:setView(self)

    self.m_updateCom=CProxyUpdataCommand()
end)

function BagProxy.setInitialized(self, _bValue)
    self.m_bInitialized = _bValue
end
function BagProxy.getInitialized(self)
    return self.m_bInitialized
end

--背包当前最大容量
function BagProxy.setMaxCapacity( self, _data)
    self.m_maxcapacity = _data
end
function BagProxy.getMaxCapacity( self)
    return self.m_maxcapacity
end

--table
--背包中所有物品list
function BagProxy.setBackpackList(self,_goodsMsgList)
    local newGoodsList = {}
    local newGoodsCount= 0
    for pos=1,#_goodsMsgList do
        local goodsMsg=_goodsMsgList[pos]
        if goodsMsg.is_data then
            local checknode=self:getGoodById(goodsMsg.goods_id)
            if checknode~=nil then
                newGoodsCount=newGoodsCount+1
                newGoodsList[newGoodsCount]=goodsMsg
                self.m_goodsIdxList[goodsMsg.index]=newGoodsCount
            else
                print("[BagProxy.setBackpackList] lua error,no this goods in goods_cnf. id=%d",goodsMsg.goods_id)
            end
        end
    end

    self.m_isGoodsSort  = false
    self.m_isGoodsSplit = false
 	self.m_bagGoodsList = newGoodsList

    self:setInitialized(true)

    controller:sendCommand(self.m_updateCom)
end
function BagProxy.getBackpackList(self)
    self :sortGoodsList()
    return self.m_bagGoodsList
end


function BagProxy.setBagSellList(self,_goodsMsgList)
    print("BagProxy.setBagSellList",#_goodsMsgList)
    local newSellList   = {}
    local newSellCount  = 0
    for i=1,#_goodsMsgList do
        local goodsMsg=_goodsMsgList[i]
        if goodsMsg.is_data then
            local checknode = self:getGoodById(goodsMsg.goods_id)
            if checknode ~= nil then
                --购回物品
                newSellCount=newSellCount+1
                newSellList[newSellCount]=goodsMsg
                self.m_SellIdxList[goodsMsg.index]=newSellCount
            else
                print("[BagProxy.setBackpackList] lua error,no this goods in goods_cnf. id=%d",goodsMsg.goods_id)
            end
        end
    end

    self.m_bagSellList  = newSellList
    ---------------------------------------------------------
    controller:sendCommand(self.m_updateCom)
end

function BagProxy.getBagSellList(self)
    -- self :sortGoodsList()
    return self.m_bagSellList
end
--背包当前购回最大容量
function BagProxy.setSellMaxCapacity( self, _data)
    self.m_SellMaxCapacity = _data
end
function BagProxy.getSellMaxCapacity( self)
    return self.m_SellMaxCapacity
end

function BagProxy.someGoodsChuange( self, _goodsMsgList )
    print("BagProxy.someGoodsChuange")
    local isChuange = false
    for i=1,#_goodsMsgList do
        local goodsMsg=_goodsMsgList[i]
        if goodsMsg.is_data then
            local checknode = self:getGoodById(goodsMsg.goods_id)
            if checknode ~= nil then
                if self.m_goodsIdxList[goodsMsg.index] == nil then
                    local pos=#self.m_bagGoodsList+1
                    self.m_bagGoodsList[pos]=goodsMsg
                    self.m_goodsIdxList[goodsMsg.index]=pos
                else
                    local pos=self.m_goodsIdxList[goodsMsg.index]
                    self.m_bagGoodsList[pos]=goodsMsg
                end

                self:checkGoodsUseToMainUI(goodsMsg)

                self.m_isGoodsSort  = false
                self.m_isGoodsSplit = false
                isChuange = true
            else
                print("[BagProxy.someGoodsChuange] lua error,no this goods in goods_cnf. id=%d",goodsMsg.goods_id)
            end
        end
    end

    if isChuange == true then
        controller:sendCommand(self.m_updateCom)
    end
end

function BagProxy.sellGoodsChuange( self, _goodsMsgList )
    print("BagProxy.sellGoodsChuange")
    local isChuange = false
    for i=1,#_goodsMsgList do
        local goodsMsg=_goodsMsgList[i]
        if goodsMsg.is_data then
            local checknode = self:getGoodById(goodsMsg.goods_id)
            if checknode ~= nil then
                if self.m_bagSellList[goodsMsg.index] == nil then
                    local pos=#self.m_bagSellList+1
                    self.m_bagSellList[pos]=goodsMsg
                    self.m_SellIdxList[goodsMsg.index]=pos
                else
                    local pos = self.m_SellIdxList[goodsMsg.index]
                    self.m_bagSellList[pos] = goodsMsg
                end
   
                isChuange = true
            else
                print("[BagProxy.sellGoodsChuange] lua error,no this goods in goods_cnf. id=%d",goodsMsg.goods_id)
            end
        end
    end

    if isChuange == true then
        controller:sendCommand(self.m_updateCom)
    end
end

function BagProxy.removeSomeGoodsByIdx( self, _goodsIndexList )
    print("---BagProxy.removeSomeGoodsByIdx-->",_goodsIndexList)
    local newGoodsList  = {}
    local newGoodsCount = 0
    self.m_goodsIdxList = {}
    for i=1,#self.m_bagGoodsList do
        local goodsMsg=self.m_bagGoodsList[i]
        local index = goodsMsg.index
        if _goodsIndexList[index]~=true then
            --还有这个物品
            newGoodsCount=newGoodsCount+1
            newGoodsList[newGoodsCount]=goodsMsg
            self.m_goodsIdxList[index] =newGoodsCount
        else
            self:removeGoodsToMainUI(goodsMsg)
        end
    end

    self.m_bagGoodsList = newGoodsList
    self.m_isGoodsSort  = false
    self.m_isGoodsSplit = false

    controller:sendCommand(self.m_updateCom)
end

function BagProxy.removeSellGoodsByIdx( self, _goodsIndexList )
    local newSellList   = {}
    local newSellCount  = 0
    self.m_SellIdxList  = {}

    for i=1,#self.m_bagSellList do
        local goodsMsg=self.m_bagSellList[i]
        local index=goodsMsg.index
        if _goodsIndexList[index]~=true then
            --还有这个物品
            newSellCount=newSellCount+1
            newSellList[newSellCount]=goodsMsg
            self.m_SellIdxList[index]=newSellCount
        end
    end

    self.m_bagSellList  = newSellList
    
    controller:sendCommand(self.m_updateCom)
end

function BagProxy.sortGoodsList( self )
    if self.m_isGoodsSort==true then return end

    print("[背包缓存] 重新排序")
    local function local_sortFun( good1, good2 )
        if good1.goods_id == good2.goods_id then
            return good1.goods_num > good2.goods_num
        else
            return good1.goods_id > good2.goods_id
        end
    end
    table.sort( self.m_bagGoodsList, local_sortFun )
    for pos,goodsMsg in ipairs(self.m_bagGoodsList) do
        self.m_goodsIdxList[goodsMsg.index] = pos
    end
    self.m_isGoodsSort = true
end

function BagProxy.splitGoodsList( self )
    if self.m_isGoodsSplit == true then return end

    print("[背包缓存] 重新分类")
    --现在背包分类为 道具 宝石 装备 购回 合成

    self:sortGoodsList()

    self.m_bagEquipList       = {} --装备
    self.m_bagEquipAndExpList = {} --装备L经验丹
    self.m_gemstoneList       = {} --宝石
    self.m_materiallist       = {} --材料
    self.m_propslist          = {} --道具
    self.m_bagArtifactList    = {} --神器
    self.m_gemAndMateriaList  = {} --合成专用

    local bagEquipCount       = 0
    local bagEquipAndExpCount = 0
    local gemstoneCount       = 0
    local materialCount       = 0
    local propsCount          = 0
    local bagArtifactCount    = 0
    local gemAndMateriaCount  = 0

    self.m_rolebagList = {} --专门用于角色面板的装备背包 分解也可以用
    local roleBagCount = 0

    for i=1,#self.m_bagGoodsList do
        local v=self.m_bagGoodsList[i]
        if v.goods_type == _G.Const.CONST_GOODS_EQUIP then
            --装备更新
            bagEquipCount=bagEquipCount+1
            self.m_bagEquipList[bagEquipCount]=v

            bagEquipAndExpCount=bagEquipAndExpCount+1
            self.m_bagEquipAndExpList[bagEquipAndExpCount]=v

            roleBagCount=roleBagCount+1
            self.m_rolebagList[roleBagCount]=v
        elseif v.goods_type == _G.Const.CONST_GOODS_STERS then
            --宝石更新
            gemstoneCount=gemstoneCount+1
            self.m_gemstoneList[gemstoneCount]=v

            gemAndMateriaCount=gemAndMateriaCount+1
            self.m_gemAndMateriaList[gemAndMateriaCount]=v
        elseif v.goods_type == _G.Const.CONST_GOODS_MATERIAL then
            --材料更新
            materialCount=materialCount+1
            self.m_materiallist[materialCount]=v

            gemAndMateriaCount=gemAndMateriaCount+1
            self.m_gemAndMateriaList[gemAndMateriaCount]=v

            propsCount=propsCount+1
            self.m_propslist[propsCount]=v
        elseif v.goods_type == _G.Const.CONST_GOODS_MAGIC then
            --神器更新
            bagEquipCount=bagEquipCount+1
            self.m_bagEquipList[bagEquipCount]=v

            bagArtifactCount=bagArtifactCount+1
            self.m_bagArtifactList[bagArtifactCount]=v
        else
            propsCount=propsCount+1
            self.m_propslist[propsCount]=v

            gemAndMateriaCount=gemAndMateriaCount+1
            self.m_gemAndMateriaList[gemAndMateriaCount]=v
        end
    end

    self.m_isGoodsSplit = true
end

--背包中装备list
function BagProxy.getEquipmentList( self)
    self:splitGoodsList()
	return self.m_bagEquipList
end

--背包中装备和经验丹list
function BagProxy.getEquipAndExpList( self)
    self:splitGoodsList()
    return self.m_bagEquipAndExpList
end

 --专门用于角色面板的装备背包
function BagProxy.getRoleBagList( self)
    self:splitGoodsList()
    return self.m_rolebagList
end

--背包中宝石list
function BagProxy.getGemstoneList( self)
    self:splitGoodsList()
	return self.m_gemstoneList
end

--背包中神器list
function BagProxy.getArtifactList( self)
    self:splitGoodsList()
	return self.m_bagArtifactList
end

--背包中道具list
function BagProxy.getPropsList( self)
    self:splitGoodsList()
	return self.m_propslist
end

--背包中材料list
function BagProxy.getMaterialList( self)
    self:splitGoodsList()
	return self.m_materiallist
end

--背包中材料list
function BagProxy.getGemandmaterialist( self)
    self:splitGoodsList()
    return self.m_gemAndMateriaList
end

--获取背包某个物品的数量
function BagProxy.getGoodsCountById( self, _goodsId )
    local allGoods = self.m_bagGoodsList or {}
    local count    = 0
    for k,v in pairs(allGoods) do
        if _goodsId == v.goods_id then
            count = count + v.goods_num
        end
    end
    return count
end


function BagProxy.removeGoodsToMainUI( self, _goodsMsg )
    if not _G.pmainView then return end

    if _goodsMsg.goods_type==_G.Const.CONST_GOODS_EQUIP then
        _G.pmainView:removeSubGoodsUseView(_goodsMsg)
    elseif _goodsMsg.goods_type == _G.Const.CONST_GOODS_ORD then
        local goodsCnf = _G.Cfg.goods[_goodsMsg.goods_id]
        if goodsCnf then
            if goodsCnf.type_sub == _G.Const.CONST_GOODS_COMMON_GIFT
            or goodsCnf.type_sub == _G.Const.CONST_GOODS_COMMON_BOX
            or goodsCnf.type_sub == _G.Const.CONST_GOODS_WHEEL_GOODS then
                _G.pmainView:removeSubGoodsUseView(_goodsMsg)
            end
        end
    end
end

function BagProxy.checkGoodsUseToMainUI( self, goods_msg )
    if not _G.GLayerManager then return end

    if goods_msg.goods_type==_G.Const.CONST_GOODS_EQUIP
        and _G.g_Stage.m_isCity then
        --提示穿戴装备

        local function local_betterEquip(_uid)
            _G.GLayerManager:addSubView(_G.GLayerManager.type_useGoods,goods_msg,_uid)
        end

        local roleProperty = _G.GPropertyProxy:getMainPlay()
        local newGoodsCnf  = _G.Cfg.goods[goods_msg.goods_id]

        if newGoodsCnf~=nil and roleProperty~=nil and _G.g_Stage~=nil then
            local rolePro = roleProperty:getPro()
            local roleUid = roleProperty:getUid()
            local roleLv  = roleProperty:getLv()
            local useProList = newGoodsCnf.pro
            local canUse = false

            if roleLv<newGoodsCnf.lv then -- 判断装备等级
                return
            elseif useProList==nil or #useProList==0 then -- 通用
                canUse = true
            else
                for idx,pro in ipairs(useProList) do --判断职业
                    if pro.p==rolePro or pro.p==0 then
                        canUse=true
                        break
                    end
                end
            end

            if canUse then
                local equipList = roleProperty : getEquipList() or {}
                local curEquip  = nil
                
                for k,v in pairs(equipList) do
                    if v.index==newGoodsCnf.type_sub then
                        curEquip=v
                        break
                    end
                end

                if curEquip==nil or curEquip.powerful<goods_msg.powerful then
                    local_betterEquip(0)
                    return
                end
            end
            --拿到伙伴列表
            local myPartner=roleProperty:getWarPartner()
            if myPartner==nil then return end

            local curEquip2  = nil
            local equipList  = myPartner:getEquipList() --装备数据
            for k2,v2 in pairs(equipList) do
                if v2.index==newGoodsCnf.type_sub then
                    curEquip2=v2
                    break
                end
            end
            
            if curEquip2==nil or curEquip2.powerful<goods_msg.powerful then
                local_betterEquip(myPartner:getPartner_idx())
                return
            end
        end
    elseif goods_msg.goods_type == _G.Const.CONST_GOODS_ORD then
        --礼包使用提示
        local roleProperty = _G.GPropertyProxy:getMainPlay()
        local newGoodsCnf  = _G.Cfg.goods[goods_msg.goods_id]
        if newGoodsCnf~=nil and roleProperty~=nil and _G.g_Stage~=nil then
            if newGoodsCnf.type_sub == _G.Const.CONST_GOODS_COMMON_GIFT
            or newGoodsCnf.type_sub == _G.Const.CONST_GOODS_COMMON_BOX
            -- or newGoodsCnf.type_sub == _G.Const.CONST_GOODS_COMMON_MONEY_BAG
            or newGoodsCnf.type_sub == _G.Const.CONST_GOODS_WHEEL_GOODS then
                local roleLv=roleProperty:getLv()
                if roleLv>=newGoodsCnf.lv then
                    _G.GLayerManager:addSubView(_G.GLayerManager.type_useGoods,goods_msg)
                end
                
            end
        end
    end
end

function BagProxy.getGoodById(self,_goodsId)
	return _G.Cfg.goods[_goodsId]
end







function BagProxy.setMainIconTypeState(self,_type,_value)
    self.m_mainIconTypeArray[_type]=_value
end
function BagProxy.getMainIconTypeArray(self)
    return self.m_mainIconTypeArray
end

return BagProxy

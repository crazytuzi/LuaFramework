---
---Author: wry
---Date: 2019/9/16 17:47:56
---

StigmataModel = StigmataModel or class('StigmataModel', BaseModel)
local this = StigmataModel

function StigmataModel:ctor()
    StigmataModel.Instance = self
    self:Reset()
end

function StigmataModel:Clear()
    if self.loadItemsEvent then
        BagModel:GetInstance():RemoveListener(self.loadItemsEvent)
    end
    self.loadItemsEvent = nil
end

function StigmataModel:Reset()
    self.mainPanelData = {}     --左侧圣痕面板上装备的圣痕数据
    self.mainPanelPosData = {}    --左侧圣痕面板上的位置信息  bool列表 表示对应pos序号的位置是否可用
    self.playerData = {}        --玩家已装备圣痕的总属性数据
   
    if self.loadItemsEvent then
        BagModel:GetInstance():RemoveListener(self.loadItemsEvent)
    end

    self.loadItemsEvent = BagModel:GetInstance():AddListener(StigmataEvent.LoadStigmataItems,handler(self,self.LoadItems))

    
    self.NeedRequestBagInfo = true
    self.IsUpdateMainData = false

    self.ATTR = {

		[1] = "Current HP",

		[2] = "HP",

		[3] = "Speed (pixel/s), multiplier of 20",

		[4] = "ATK",

		[5] = "DEF",

		[6] = "Penetration",

		[7] = "Accuracy",

		[8] = "Dodge",

		[9] = "Crit",

		[10] = "TEN",

		[11] = "M. ATK",

		[12] = "M. DEF",

		[13] = "Attack Boost",

		[14] = "Damage Reduction",

		[15] = "Hit Chance",

		[16] = "Dodge Rate",

		[17] = "Armor",

		[18] = "Armor Penetration",

		[19] = "Block Rate",

		[20] = "Pierce",

		[21] = "Crit Rate",

		[22] = "Crit Resistance",

		[23] = "Concentrated Strike Rate",

		[24] = "Concentrated Strike Resistance",

		[25] = "Crit Damage",

		[26] = "Concentrated Strike Damage",

		[27] = "Increased Skill Damage",

		[28] = "Skill Damage Reduction",

		[29] = "Strike Rate",

		[30] = "Chance of Weakening",

		[31] = "Crit Damage Reduction",

		[32] = "Normal attack damage increase",

		[33] = "Block damage",

		[34] = "PVP Damage Resistance",

		[35] = "PVP Armor",

		[36] = "PVP Armor Penetration",

		[37] = "Boss Damage Boost",

		[38] = "Monster damage bonus",

		[39] = "Offensive skill CP",

		[40] = "Defensive skill CP",

		[41] = "Damage Reduction",

		[42] = "PVP Damage Resistance",

		[43] = "Concentrated skill damage reduction",

		[44] = "CP",

		[45] = "Absolute attack",

		[46] = "Absolute Evasion",

		[1100] = "Total Attribute Percentage (Overall)",

		[1102] = "HP Bonus",

		[1103] = "Speed bonus",

		[1104] = "Attack bonus",

		[1105] = "Defense Bonus",

		[1106] = "Penetration Bonus",

		[1107] = "Accuracy Bonus",

		[1108] = "Dodge Bonus",

		[1109] = "Crit Bonus",

		[1110] = "Tenacity Bonus",

		[1111] = "Spell damage bonus",

		[1112] = "Spell Defense Bonus",

		[1200] = "Total Attribute Percentage (Partial)",

		[1202] = "HP",

		[1204] = "ATK",

		[1205] = "DEF",

		[1206] = "Penetration",

		[1207] = "Accuracy",

		[1208] = "Dodge",

		[1209] = "Crit",

		[1210] = "TEN",

		[1211] = "M. ATK",

		[1212] = "M. DEF",

		[1302] = "Basic HP",

		[1304] = "Basic Attack",

		[1305] = "Basic Defense",

		[1306] = "Basic Penetration",

		[1404] = "Weapon Attack",

		[1406] = "Weapon Penetration",

		[1502] = "Armor HP",

		[1505] = "Armor Defense",

		[1604] = "Accessory Attack",

		[2000] = "EXP Bonus",

		[2001] = "Gold Drop Rate",

		[2002] = "Drop rate",

		[2003] = "Increase defense every 3 levels",

		[2004] = "Increase HP every 3 levels",

		[2005] = "Increase attack every 3 levels",

		[2006] = "Increase ATK by 10",

		[2007] = "Increase damage by 2% done to bosses every 50 levels",

		[2009] = "Reduce skill cd by",

		[2010] = "Enhancement Bonus",

	}

end

function StigmataModel.GetInstance()
    if StigmataModel.Instance == nil then
        StigmataModel.new()
    end
    return StigmataModel.Instance
end



--排序圣痕背包
--[[
    1，双属性圣痕>单属性圣痕>圣痕碎片
    2，身上没有属性的圣痕>身上已有属性的圣痕
    3，color，粉色>红色>橙色>紫色>蓝色>绿色>白色
    4，核心>普通
--]]
function StigmataModel:SortStigmataBag(items)

    for k, v in pairs(items) do
        local data = v
        data.color = Config.db_item[data.id].color
        data.slot = Config.db_soul[data.id].slot            --部位1普通2核心0为碎片
        data.typeList = self:ReturnSoulItemAttr_Type(Config.db_soul[data.id])
        data.canPutOn = self:SoulIsCanPutOnPlayer(data.id)  --已装备的圣痕中是否没有这个圣痕的属性
        items[k] = data
    end

    --排序
    table.sort(items, function(a,b)

       --圣痕属性数量
       if #a.typeList ~= #b.typeList then
           return #a.typeList > #b.typeList
       end

       --身上是否没有该属性
       if a.canPutOn ~= b.canPutOn then
           return a.canPutOn
       end

       --颜色
       if a.color ~= b.color then
           return a.color > b.color
       end

       --是否是核心
       if a.slot ~= b.slot then
           return a.slot == 2
       end

       --等级
      --[[  if a.extra ~= b.extra then
           return a.extra > b.extra
       end ]]


       --物品id
       if a.id ~= b.id then
           return a.id > b.id
       end

       
    end )
end

--获取可以进行分解的圣痕
function StigmataModel:GetSmeltStigmataList()
    local list = BagModel.GetInstance().stigmataItems

    local returnList = {}   --返回可分解得集合

    local oneTypeList = {}  --单属性集合

    for i, v in pairs(list) do
        local db_soul = Config.db_soul[v.id]


        if db_soul.slot == 0 then      
            --碎片直接加入
            table.insert(returnList,v)
        else
            local basTable = String2Table(db_soul.base)

            if #basTable < 2 then
               --单属性圣痕
               --先根据属性分类
               oneTypeList[basTable[1][1]] =  oneTypeList[basTable[1][1]] or {}
               table.insert( oneTypeList[basTable[1][1]], v )
            end
        end
    end

   
    --排序每一种单属性圣痕 将最好的放在第一个
    local function sort_func(a,b)
       local a_color = Config.db_item[a.id].color
       local b_color = Config.db_item[b.id].color
       if a_color ~= b_color then
           return a_color > b_color
       end

       if a.extra ~= b.extra then
           return a.extra > b.extra
       end

    end

    for k,v in pairs(oneTypeList) do
        table.sort(v, sort_func )
    end

    
    local attrAndItem = {}
    for k,v in pairs(self.mainPanelData) do
        local cfg = Config.db_soul[v.id]
        local attrType = self:ReturnSoulItemAttr_Type(cfg)
       
        for k2,v2 in pairs(attrType) do
            attrAndItem[v2] = v
        end
    end

    --将排序后各个属性表的第一个（也就是最好的那个）与身上装备的对比
    for k,v in pairs(oneTypeList) do

         --身上已经有这个属性了 就进行对比
        if attrAndItem[k] then
            --logError("身上存在属性" .. GetAttrNameByIndex(k) .. "开始对比") 

            local target = attrAndItem[k]  --身上需要对比的圣痕
            local item = v[1] --背包需要对比的圣痕

            local target_itemCfg = Config.db_item[target.id] 
            if target_itemCfg.color < item.color then
                --背包中的品质高 不进入可分解列表
                table.remove(v,1)
                --logError("背包中的属性"..GetAttrNameByIndex(k).."里最好的那个保留")
            elseif target_itemCfg.color == item.color and target.extra < item.extra then
                --背包中的品质和身上的品质相同 但等级更高 不进入可分解列表
                table.remove(v,1)
                --logError("背包中的属性"..GetAttrNameByIndex(k).."里最好的那个保留")
            else
                --logError("背包中的属性"..GetAttrNameByIndex(k).."里最好的那个不保留")
            end
        else
            --身上没有这个属性 就保留 不进入可分解列表
            table.remove(v,1)
            --logError("身上不存在属性" .. GetAttrNameByIndex(k) .. "，保留背包最好的") 
        end
    end

    for k,v in pairs(oneTypeList) do
        for k2,v2 in pairs(v) do
            --处理了最好的那个后 还得是低于红色的单属性圣痕才能分解
            local color =  Config.db_item[v2.id].color  --不要直接拿color 要走配置表 否则可能报错
            if color < 6 then
                table.insert( returnList,v2)
            end
           
        end
    end

    --排序
    local function sort_func2(a,b)
        local a_slot = Config.db_soul[a.id].slot
        local b_slot = Config.db_soul[b.id].slot       
        
        if a_slot ~= b_slot then
            return a_slot > b_slot
        end

        local a_color = Config.db_item[a.id].color
        local b_color = Config.db_item[b.id].color

        if a_color ~= b_color then
            return a_color > b_color
        end

        if a.extra ~= b.extra then
            return a.extra > b.extra
        end
    end

    table.sort( returnList,sort_func2)

    return returnList
end

--设置玩家已装备圣痕总的属性数据
function StigmataModel:SetPlayerData()
    self.playerData = {}
    if not self.mainPanelData or table.nums(self.mainPanelData) < 1 then
        return
    end

    local tData = {}    --界面数据

    for i, v in pairs(self.mainPanelData) do
        local data = Config.db_soul[v.id]
        --local data = Config.db_soul_level[tostring(v.id) .."@".. tostring(v.extra)]

        --基础属性
        local dataBase = String2Table(data.base)

        --升级属性
        local levelAttr = String2Table(Config.db_soul_level[v.id.."@"..v.extra].attrib)

        --总属性
        for k,v in pairs(levelAttr) do
            dataBase[k][2] = dataBase[k][2] + levelAttr[k][2]
        end
        table.insert(tData,dataBase)
    end

    for i, v in pairs(tData) do
        table.insert(self.playerData,v[1])
        if #v == 2 then
            table.insert(self.playerData,v[2])
        end
    end

    table.sort( self.playerData, function(a,b)
        return a[1] < b[1]
    end )

    return self.playerData
end


--返回圣痕属性类型  属性数字列表
--db_soulItemData  对应圣痕的表格数据
function StigmataModel:ReturnSoulItemAttr_Type(db_soulItemData)
    local attr_type = String2Table(db_soulItemData.base)

    local attr_typeIntList = {}

    for k, v in pairs(attr_type) do
        table.insert(attr_typeIntList,v[1])
    end
    
    return attr_typeIntList
end

--设置位置信息
function StigmataModel:SetPosData()
    local posData = {}  --位置是否可用

    local playerLV = RoleInfoModel:GetInstance():GetMainRoleLevel()
    for k, v in pairs(Config.db_soul_pos) do
        if v.level > playerLV  then
            posData[k] = false  --等级不足 不可用
        else
            posData[k] = true
        end
    end


    if not self.mainPanelData then
        self.mainPanelPosData = posData
        return
    end

    for i = 1, #posData do
        if self.mainPanelData[i] ~= nil then    --如果面板数据中位置已经存在数据，那就为不可用
            posData[i] = false
        end
    end

    self.mainPanelPosData = posData

end

--是否可装备当前属性的圣痕/身上没有对应属性
--id圣痕id
function StigmataModel:SoulIsCanPutOnPlayer(id)

    local db_soulItemData = Config.db_soul[id] --对应圣痕的表格数据
    local typeList = self:ReturnSoulItemAttr_Type(db_soulItemData)

    local typeNum = #typeList

    if self.playerData == nil or #self.playerData < 1 then
        return true
    end

    --已装备相同属性的圣痕，返回false
    for i, v in pairs(self.playerData) do
        if v[1] == typeList[1] then
            return false
        end
    end
    if typeNum == 2 then
        for i, v in pairs(self.playerData) do
            if v[1] == typeList[2] then
                return false
            end
        end
    end

    return true
end

--查看圣痕是否可装备
--id圣痕id
--当返回0时表示没有位置/不可装备    返回对应位置pos
function StigmataModel:ReturnCanSetPos(id)

    --slot圣痕slot  部位1普通2核心0为碎片
    local slot = Config.db_soul[id].slot
    if slot == 0 then
        return 0
    end

    for k, v in pairs(self.mainPanelPosData) do
        if slot == 2 and k == 1 then
            if self.mainPanelPosData[1] then
                return 1
            end
            return 0
        elseif k ~= 1 then
            if v and self:SoulIsCanPutOnPlayer(id) then
                return k
            end
        end
    end
    return 0
end

--是否有空余位置装备指定类型圣痕
--slot圣痕slot  部位1普通2核心0为碎片
function StigmataModel:HaveSetPos(slot)

    if slot == 0 then
        return false
    end


    for k, v in pairs(self.mainPanelPosData) do
        if slot == 2 and k == 1 then
            --核心位置是否可装备
            return self.mainPanelData[1] == nil and v == true
        elseif k~=1 then
            if self.mainPanelData[k] == nil and v == true then
                return true
            end
        end
    end

    return false
end

--是否有可装备到指定位置的圣痕
function StigmataModel:HavaCanPutOnToTargetPos(pos)

    if pos <=0 and pos >= 8 then
        logError("pos无效")
        return false
    end

    --判断位置类型
    local slot = 1
    if pos == 1 then
        slot = 2
    end

    
    local flag1  = self.mainPanelPosData[pos] == true and self.mainPanelData[pos] == nil
    if flag1 == false then
        --该位置无法装备圣痕
        return false
    end

    local items = BagModel.GetInstance().stigmataItems
    for k,v in pairs(items) do
         
         if Config.db_soul[v.id].slot == slot and self:ReturnCanSetPos(v.id) ~= 0 then
            --有可装备到该类型位置的圣痕
             return true
         end
    end

    return false

end

--获取已装备和背包上的id对应圣痕列表
function StigmataModel:GetPlayerSoul(id)
    local allSoul = {}

    for k, v in pairs(self.mainPanelData) do
        table.insert(allSoul,v)
    end

    local bagSoul = BagModel.GetInstance().stigmataItems
    for k, v in pairs(bagSoul) do
        table.insert(allSoul,v)
    end

    local souls = {}
    for k, v in pairs(allSoul) do
        if v.id == id then
            table.insert(souls,v)
        end
    end
    return souls
end

--圣痕升级
function StigmataModel:SoulLevelUp(pos)
    for k, v in pairs(self.mainPanelData) do
        if k == pos then
            v.extra = v.extra + 1
        end
    end

end

--是否有可升级圣痕
function StigmataModel:GetCanStigmataLevelUp(tData)

    tData = tData or self.mainPanelData

    --遍历所有左侧面板上的圣痕进行判断
    for k,v in pairs(tData) do
        if self:GetCanTargetStigmataLevelUp(v) then
            return true
        end
    end

    return false
end

--指定圣痕是否可升级
function StigmataModel:GetCanTargetStigmataLevelUp(item)

    --满级圣痕不可升级
    if item.extra >= 50 then
        return false
    end

    local db_soul_level = Config.db_soul_level[tostring(item.id) .."@".. tostring(item.extra)]
    local cost = String2Table(db_soul_level.cost)[2]
    local have = RoleInfoModel.GetInstance():GetRoleValue(String2Table(db_soul_level.cost)[1])
    if cost <= have then
        return true
    end
    return false
end

--圣痕背包中是否有可佩带圣痕
function StigmataModel:GetCanStigmataPutOn()
   local items = BagModel.GetInstance().stigmataItems
   for k,v in pairs(items) do
       if self:ReturnCanSetPos(v.id) ~= 0 then
           return true
       end
   end

   return false
end

--目标圣痕是否可跳转到合成
function StigmataModel:GetCanJump(item_id)
   
    local jump = Config.db_item[item_id].jump
    return jump ~= ''
    
end

--设置左侧圣痕信息
function StigmataModel:SetMainPanelData(data)

    if self.IsUpdateMainData then
        self.IsUpdateMainData = false

        --部分更新      
        for k,v in pairs(data) do
            self.mainPanelData[k] = v
        end

    else
        --完全替换
        self.mainPanelData = data
    end
    

    self:SetPosData()

    self:SetPlayerData()

    -- 变强-圣痕升级 检测
    local flag = self:GetCanStigmataLevelUp()
    GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger,56,flag)

    BagController:GetInstance():UpdateBagRedDot()
    self:Brocast(StigmataEvent.UpdateReddot)

    if not self.NeedRequestBagInfo then
        --不需要刷新背包
        self.NeedRequestBagInfo = true
    else
        BagController.Instance:RequestBagInfo(BagModel.Stigmata)
    end
   
end

function StigmataModel:LoadItems()

    -- 变强-圣痕佩戴 检测
    local flag = self:GetCanStigmataPutOn()
    GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger,57,flag)
    
    BagController:GetInstance():UpdateBagRedDot()
    self:Brocast(StigmataEvent.UpdateReddot)

    --自动分解检查
    local ctrl = StigmataController:GetInstance()
    if ctrl.setSoulDecomposeData and ctrl.setSoulDecomposeData.auto == 1 then
        
        local bagModel = BagModel:GetInstance()
        local count = table.nums(bagModel.stigmataItems)

      
        if bagModel.stigmataOpenCells - count  < 50 then
           local tab = self:GetSmeltStigmataList()
           
           local uidList = {}

            for k,v in pairs(tab) do

                if v.slot == 0 then
                    --圣痕碎片直接加入
                    uidList[v.uid] = v
                else
                    if v.color <= ctrl.setSoulDecomposeData.color then
                        --比自动分解设置的颜色小的圣痕加入分解列表里
                        uidList[v.uid] = v
                    end
                end

            end
            
            if table.nums(uidList)  ~= 0 then
                ctrl:RequestSoulDecompose(uidList)
            end
            
        end
    end
end


--根据索引获取属性中文名
function StigmataModel:GetAttrNameByIndex(index)
    return self.ATTR[index]
end
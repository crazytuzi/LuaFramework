-- 侠客信息
require("app.cfg.knight_info")
require("app.cfg.knight_halo_info")
require("app.cfg.association_info")
require("app.cfg.sanguozhi_info")
require("app.cfg.passive_skill_info")
require("app.cfg.knight_awaken_info")
require("app.cfg.item_awaken_info")
require("app.cfg.equipment_skill_info")
require("app.cfg.function_level_info")
require("app.cfg.knight_god_info")


local MergeEquipment = require("app.data.MergeEquipment")

local AttributesConst = require("app.const.AttributesConst")

local KnightConst = require("app.const.KnightConst")

local KnightsData = class("KnightsData")

local KnightConst = require("app.const.KnightConst")

function KnightsData:ctor()
    self._knightArr = {}
    self._knightIndex = {}

    self._mainKnightBaseId = 0
    self._mainKnightId = 0
end

function KnightsData:getMainKnightBaseId()
    return self._mainKnightBaseId
end

function KnightsData:resetLocalKnightInfo( buff )
    self._knightArr = {}
    self._knightIndex = {}

    for i, value in pairs(buff) do
        if type(value) == "table" and value["id"] ~= nil then
            self._knightArr[value["id"]] = value
            self._knightIndex[i] = value["id"]
        else
            __LogError("resetLocalKnightInfo: wrong data at index:%d", i)
        end
    end
    --这里排序无用
    --self:sortKnights()
end

function KnightsData:setMainKnightId( mainId )
    if not mainId or mainId < 1 then 
        return 
    end

    self._mainKnightId = mainId

    local curMainKnightId = self._mainKnightBaseId
    self._mainKnightBaseId = self:getBaseIdByKnightId(mainId)
    if curMainKnightId <= 0 then 
        self:_changeMainKnightName()
    end
end

-- 玩家修改角色名成功之后
function KnightsData:changeNameSucceed()
    --修改knight_info里面主将的名称
    if self._mainKnightBaseId > 0 then 
        __Log("_changeMainKnightName: baseId:%d, name=%s", self._mainKnightBaseId, G_Me.userData.name)
        local mainKnightBaseInfo = knight_info.get(self._mainKnightBaseId)
        if mainKnightBaseInfo then 
            local mainKnightBaseId = mainKnightBaseInfo.advance_code
            while mainKnightBaseId > 0 do
                -- if mainKnightBaseId > 0 then 
                knight_info.set(mainKnightBaseId, "name", G_Me.userData.name)
                -- end
                   --__Log("change baseId:%d, name=%s", mainKnightBaseId, G_Me.userData.name)

                mainKnightBaseInfo = knight_info.get(mainKnightBaseId)
                mainKnightBaseId = mainKnightBaseInfo and mainKnightBaseInfo.advanced_id or 0
            end
        end
    end
end

function KnightsData:_changeMainKnightName(  )
    
    --修改knight_info里面主将的名称
    if self._mainKnightBaseId > 0 then 
        __Log("_changeMainKnightName: baseId:%d, name=%s", self._mainKnightBaseId, G_Me.userData.name)
        local mainKnightBaseInfo = knight_info.get(self._mainKnightBaseId)
        if mainKnightBaseInfo then 
            local mainKnightBaseId = mainKnightBaseInfo.advance_code
            while mainKnightBaseId > 0 do
                if mainKnightBaseId > 0 then 
                    knight_info.set(mainKnightBaseId, "name", G_Me.userData.name)
                end
                   --__Log("change baseId:%d, name=%s", mainKnightBaseId, G_Me.userData.name)

                mainKnightBaseInfo = knight_info.get(mainKnightBaseId)
                mainKnightBaseId = mainKnightBaseInfo and mainKnightBaseInfo.advanced_id or 0
            end
        end
    end

    local changeResId = function ( baseId1, baseId2 )
        if type(baseId1) ~= "number" or type(baseId2) ~= "number" then 
            return 
        end

        local mainKnightBaseInfo = knight_info.get(baseId1)
        local replaceKnightBaseInfo = knight_info.get(baseId2)
        if not mainKnightBaseInfo or not replaceKnightBaseInfo then 
            return 
        end

        --__Log("changeResId:name=%s", mainKnightBaseInfo.name)
        --__Log("harmonyInfo: knightId1:%d(%s, %d), knightId2:%d(%s, %d)", 
          --  baseId1, mainKnightBaseInfo.name, mainKnightBaseInfo.res_id,  baseId2, replaceKnightBaseInfo.name, replaceKnightBaseInfo.res_id )
        local initAdvanceCode = mainKnightBaseInfo.advance_code
        knight_info.set(baseId1, "res_id", replaceKnightBaseInfo.res_id)

        local mainKnightBaseId = mainKnightBaseInfo.advance_code
        while mainKnightBaseId > 0 do
            if mainKnightBaseId > 0 then 
                --__Log("change knightId:%d, resId:%d -> %d", mainKnightBaseId, mainKnightBaseInfo.res_id, replaceKnightBaseInfo.res_id)
                knight_info.set(mainKnightBaseId, "res_id", replaceKnightBaseInfo.res_id)
            end                

            mainKnightBaseInfo = knight_info.get(mainKnightBaseId)
            if mainKnightBaseInfo.advance_code == initAdvanceCode then 
                mainKnightBaseId = mainKnightBaseInfo and mainKnightBaseInfo.advanced_id or 0
            else
                mainKnightBaseId = 0
            end
        end       
    end

    local appstoreVersion = (G_Setting:get("appstore_version") == "1")
    if appstoreVersion then 
        require("app.cfg.monster_info")
        require("app.cfg.Harmony2_info")
        require("app.cfg.Harmony3_info")
        require("app.cfg.Harmony_info")
        require("app.cfg.Harmony4")
        require("app.cfg.Harmony5")
        require("app.cfg.Harmony6_info")
        require("app.cfg.Harmony7_info")
        require("app.cfg.Harmony8_info")
        require("app.cfg.Harmony9_info")
        require("app.cfg.story_dungeon_info")
        require("app.cfg.story_barrier_info")
        require("app.cfg.dungeon_stage_info")
        require("app.cfg.dress_info")
        require("app.cfg.dead_battle_info")
        require("app.cfg.hard_dungeon_stage_info")

        --修改knight_info表里面res_id
        local length = Harmony_info.getLength()
        for i = 1, length do 
            local harmonyInfo = Harmony_info.get(i)
            if harmonyInfo then 
                changeResId(harmonyInfo.knightId1, harmonyInfo.knightId2)
            end
        end

        --修改monster_info表里面的res_id
        length = Harmony2_info.getLength()
        for i = 1, length do 
            local harmonyInfo = Harmony2_info.indexOf(i)
            if harmonyInfo then 
                local monsterInfo = monster_info.get(harmonyInfo.monsterId)
                if monsterInfo then 
                    --__Log("monsterId:%d, oldresId:%d, newResId:%d", 
                    --    harmonyInfo.monsterId, monsterInfo.res_id, harmonyInfo.resId)
                    monster_info.set(monsterInfo.id, "res_id", harmonyInfo.resId)
                end
            end
        end

        --修改fragment_info表里面的res_id
        length = Harmony3_info.getLength()
        for i = 1, length do 
            local harmonyInfo = Harmony3_info.indexOf(i)
            if harmonyInfo then 
                local fragmentInfo = fragment_info.get(harmonyInfo.fragmentId)
                if fragmentInfo then 
                    fragment_info.set(harmonyInfo.fragmentId, "res_id", harmonyInfo.resId)
                end
            end
        end

        length = Harmony4.getLength()
        for i = 1, length do 
            local harmonyInfo = Harmony4.indexOf(i)
            if harmonyInfo then 
                story_barrier_info.set(harmonyInfo.story_barrierId, "res_id", harmonyInfo.resId)
            end
        end

        length = Harmony5.getLength()
        for i = 1, length do 
            local harmonyInfo = Harmony5.indexOf(i)
            if harmonyInfo then 
                story_dungeon_info.set(harmonyInfo.story_dungeonId, "pic", harmonyInfo.resId)
            end
        end

        length = Harmony6_info.getLength()
        for i = 1, length do 
            local harmonyInfo = Harmony6_info.indexOf(i)
            if harmonyInfo then 
                dungeon_stage_info.set(harmonyInfo.dungeon_stageId, "image", harmonyInfo.resId)
            end
        end

        length = Harmony7_info.getLength()
        for i = 1, length do 
            local harmonyInfo = Harmony7_info.indexOf(i)
            if harmonyInfo then 
                dress_info.set(harmonyInfo.dress_infoId, "woman_res_id", harmonyInfo.resId)
            end
        end

        length = Harmony9_info.getLength()
        for i = 1, length do 
            local harmonyInfo = Harmony9_info.indexOf(i)
            if harmonyInfo then 
                dead_battle_info.set(harmonyInfo.dead_battle_infoId, "monster_image", harmonyInfo.resId)
            end
        end

        if Harmony8_info then 
            length = Harmony8_info.getLength()
            for i = 1, length do 
                local harmonyInfo = Harmony8_info.indexOf(i)
                if harmonyInfo then 
                   hard_dungeon_stage_info.set(harmonyInfo.hard_dungeon_stageId, "image", harmonyInfo.resId)
                end
            end
        end
        
    end
end

function KnightsData:addKnightToList(knight)

    self._knightArr[knight["id"]] = knight
    self._knightIndex[#self._knightIndex+1] = knight["id"]
end


function KnightsData:updateKnight(knight)
    if not knight then 
        return 
    end

    self._knightArr[knight["id"]] = knight

    if knight["id"] == self._mainKnightId and knight["base_id"] ~= self._mainKnightBaseId then 
        self._mainKnightBaseId = knight["base_id"]
        self:_changeMainKnightName()
    end
end

--function KnightsData:addKnightInfo( knights )
  --  for i, value in pairs(knights) do
   --     if type(value) == "table" and value["id"] ~= nil then
   --         self._knightArr[value["id"]] = value
  --          self._knightIndex[i] = value["id"]
   --     end
  --  end
--end

--function KnightsData:updateKnightInfo( knights )
--    for i, value in pairs(knights) do
   --     if type(value) == "table" and value["id"] ~= nil then
   --         self._knightArr[value["id"]] = value
   --         self._knightIndex[i] = value["id"]
   --     end
  --  end
--end

--function KnightsData:removeKnightInfo( knightIds )
--    for i, value in pairs(knightIds) do
--        self._knightArr[value] = nil
--
 --       self:_removeKnightId(value)
 --   end
--end

--function KnightsData:_removeKnightId( knightId )
 --   for i, value in pairs(self._knightIndex) do
  --      if knightId == value then
  --          table.remove(self._knightIndex, i)
  --          return 
 --       end
--    end
--end

function KnightsData:sortKnights()
    local sortFunc = function(indexA,indexB)
        if indexA == self._mainKnightId then 
            return true 
        end

        if indexB == self._mainKnightId then 
            return false
        end
        
        local a = self:getKnightByKnightId(indexA)
        local b = self:getKnightByKnightId(indexB)
        
        local teamA = G_Me.formationData:getKnightTeamId(a.id)
        local teamB = G_Me.formationData:getKnightTeamId(b.id)
        --local teamA = G_Me.formationData:isKnightInTeam(1,a.id)
        --local teamB = G_Me.formationData:isKnightInTeam(1,b.id)
        --local a01 = teamA and 1 or 0
        --local b01 = teamB and 1 or 0
        if teamA ~= teamB then
            if teamA > 0 and teamB > 0 then 
                return teamA < teamB
            else
                return teamA ~= 0 
            end
        end
        
        local kniA = knight_info.get(a.base_id)
        local kniB = knight_info.get(b.base_id)
        if not kniA then 
            __LogError("a wrong knigh info for baseid:%d", a.base_id)
            return false
        end
        if not kniB then 
            __LogError("b wrong knigh info for baseid:%d", b.base_id)
            return true
        end
        --再比较品质
        if kniA.quality ~= kniB.quality then
            return kniA.quality > kniB.quality
        end
        
        if kniA.advanced_level ~= kniB.advanced_level then 
            return kniA.advanced_level > kniB.advanced_level 
        end

        --再比较等级
        if a.level ~= b.level then
            return a.level > b.level
        end

        if a.awaken_level ~= b.awaken_level then 
            return a.awaken_level > b.awaken_level
        end

        return a.base_id > b.base_id
    end
    
    table.sort(self._knightIndex or {}, sortFunc)
end

function KnightsData:getKnightCount(  )
    --__Log("size of knight arr:%d", table.getn(self._knightArr))
    --return table.getn(self._knightArr)
    local count = 0;
    for i, _ in pairs(self._knightIndex) do
            count = count + 1
    end
    return count
end

function KnightsData:getKnightByIndex( index )
    return self._knightIndex[index]
end

function KnightsData:getMainKightInfo(  )
    local mainKnightId = G_Me.formationData:getMainKnightId() or 0
    return self:getKnightByKnightId(mainKnightId)
end

function KnightsData:getKnightExceptKnightId( index, knightId )
    if not knightId then
        return self:getKnightByIndex(index)
    end

    local validIndex = 0
    for i, value in pairs(self._knightIndex) do
        if value ~= knightId then
            validIndex = validIndex + 1
        end

        if index == validIndex then
            return value
        end
    end

    return 0
end

function KnightsData:getBaseIdByKnightId( knightId )    
    if type(knightId) == "number" and knightId > 0 then
        local knight = self:getKnightByKnightId(knightId)
        if knight ~= nil and type(knight) == "table" then
            return knight["base_id"]
        end
    end

    return 0
end

function KnightsData:getKnightAttributes( baseId, level )
    local knightBaseInfo = knight_info.get(baseId)
    if not knightBaseInfo then
        return nil
    end

    level = level or 1
    local attributes = {}
    attributes["hp"] = knightBaseInfo.base_hp + (level - 1)*knightBaseInfo.develop_hp
    attributes["md"] = knightBaseInfo.base_magical_defence + (level - 1)*knightBaseInfo.develop_magical_defence
    attributes["pd"] = knightBaseInfo.base_physical_defence + (level - 1)*knightBaseInfo.develop_physical_defence
    if knightBaseInfo.damage_type == 1 then
        attributes["at"] = knightBaseInfo.base_physical_attack + (level - 1)*knightBaseInfo.develop_physical_attack
    else
        attributes["at"] = knightBaseInfo.base_magical_attack + (level - 1)*knightBaseInfo.develop_magical_attack
    end

    return attributes
end

--这里的index是Id
function KnightsData:removeKnightByIndex(index)
    for i,v in ipairs(self._knightIndex) do
        if v == index then
            self._knightArr[v] = nil
            table.remove(self._knightIndex, i)
        end
    end
end

function KnightsData:getKnightByKnightId( knightId )
    return self._knightArr[knightId]
end

function KnightsData:getKnightsList(  )
    return self._knightArr
end



function KnightsData:getSellKnightsList()
    require("app.cfg.knight_advance_info")
    local list = {}
    local advanceMaps = {}

    --单独新建一个map
    for i=1,knight_advance_info.getLength() do
        local advance = knight_advance_info.indexOf(i)
        advanceMaps[advance.advanced_level] = advance
    end

    for i,v in ipairs(self._knightIndex)do
        local kni = self._knightArr[v]
        if kni ~= nil then
            local teamId = G_Me.formationData:getKnightTeamId(kni.id)
            if teamId == 0 then
                local knight = knight_info.get(kni.base_id)
                local advanceInfo = advanceMaps[knight.advanced_level]

                local recycleMoney = 0
                if advanceInfo ~= nil then
                    recycleMoney = advanceInfo.recycle_money
                end
                local data = clone(kni) 
                data["checked"] = false
                data["money"] = knight.price + recycleMoney + data.exp 
                -- data.money = data.money + equip.price
                table.insert(list,data)
            end 
        end
    end
    return list
end

function KnightsData:getKnightsIdListCopy(  )
    local copyList = {}
    self:sortKnights()
    for key, value in pairs(self._knightIndex) do 
        table.insert(copyList, #copyList + 1, value);
    end

    return copyList
end

function KnightsData:_isLevelHigher( knightId1, knightId2 )
    if knightId1 == nil then
        return false
    end

    if knightId2 == nil then 
        return true
    end

    local knightInfo1 = self._knightArr[knightId1]
    local knightInfo2 = self._knightArr[knightId2]

--return true
    return knightInfo1["level"] > knightInfo2["level"]
end

function KnightsData:getStrenghenKnights( exceptKnights )
    local knightArr = {}
    for i, value in pairs(self._knightIndex) do
        if exceptKnights[value] == nil then
            table.insert(knightArr, #knightArr + 1, value)
        end
    end

    return knightArr
end

function KnightsData:getJingJieKnights(  )
    local knightArr = {}
    for i, value in pairs(self._knightArr) do 
        local baseId = value["base_id"]
        local baseInfo = knight_info.get(baseId)
        if baseInfo then
            if baseInfo.potential == 23 and baseInfo.advanced_level < 6 then
                table.insert(knightArr, #knightArr + 1, value["id"])
            elseif baseInfo.potential == 20 and baseInfo.advanced_level < 6 then
                table.insert(knightArr, #knightArr + 1, value["id"])
            elseif baseInfo.potential == 18 and baseInfo.advanced_level < 6 then
                table.insert(knightArr, #knightArr + 1, value["id"])
            elseif baseInfo.potential == 13 and baseInfo.advanced_level < 4 then
                table.insert(knightArr, #knightArr + 1, value["id"])
            elseif baseInfo.potential == 12 and baseInfo.advanced_level < 4 then
                table.insert(knightArr, #knightArr + 1, value["id"])
            elseif baseInfo.potential == 8 and baseInfo.advanced_level < 3 then
                table.insert(knightArr, #knightArr + 1, value["id"])
            elseif baseInfo.potential == 5 and baseInfo.advanced_level < 2 then
                table.insert(knightArr, #knightArr + 1, value["id"])
            end
        end
    end

    return knightArr
end

function KnightsData:canKnightStrengthen( knightId )
    if not knightId or knightId < 1 then
        return false
    end

    local mainKnightId = G_Me.formationData:getMainKnightId()
    if not mainKnightId or mainKnightId == knightId then 
        return false
    end

    local knightInfo = self:getKnightByKnightId(knightId)       
    local mainKnightInfo = self:getKnightByKnightId(mainKnightId)
    if knightInfo and mainKnightInfo and knightInfo["level"] < mainKnightInfo["level"] then
        return true
    end

    return false
end

-- levelFlag: 
function KnightsData:canJingJieWithKnightId( knightId, strictCmp )
    local knightInfo = self:getKnightByKnightId(knightId)
    if not knightInfo then
        return false
    end

    return self:canJingjieWithBaseId(knightInfo["base_id"], knightInfo["level"], strictCmp)
end

function KnightsData:canJingjieWithBaseId( baseId, level, strictCmp )
    local baseInfo = knight_info.get(baseId)
    if not baseInfo then
        return false
    end

    if not (baseInfo.advanced_level < 15) then 
        return false
    end

    if strictCmp then
        require("app.cfg.knight_advance_info")
        local levelBan = knight_advance_info.get(baseInfo.type, baseInfo.advanced_level).level_ban
        return level >= levelBan, baseInfo.advanced_id > 0
    else
        return true, baseInfo.advanced_id > 0 
    end
end

function KnightsData:getJineJieResultKnightInfo( baseId )
    local knightBaseInfo = knight_info.get(baseId)
    if knightBaseInfo == nil then
        return nil
    end

    return knight_info.get(knightBaseInfo.advanced_id)
end

function KnightsData:hasEnoughKnight( advanceCode, count, exceptKnights )
    local validKnights = self:getCostKnight(advanceCode, exceptKnights)
    return #validKnights >= count
end

--突破觉醒时消耗卡牌 等级不超过10级，突破不超过1阶，天命不超过2级，觉醒等级不超过1
function KnightsData:getCostKnight( advanceCode, exceptKnights, advancedLevel )
    if not advanceCode then 
        return {}
    end

    advancedLevel = advancedLevel or 0
    exceptKnights = exceptKnights or {}

    local validKnight = {}
    for id, value in pairs(self._knightArr) do 
        if not exceptKnights[id] then
            local baseId = value["base_id"]

            local haloLevel = value["halo_level"] or 1
            local awakenLevel = value["awaken_level"] or 0

            local knightInfo = knight_info.get(baseId)
            if knightInfo then
                if (knightInfo.advance_code == advanceCode) then
                    if (value.level == 1 and advancedLevel < 0) or 
                       (advancedLevel >= 0 and knightInfo.advanced_level <= advancedLevel and
                        value.level < 10 and haloLevel < 2 and awakenLevel < 1 ) then
                        table.insert(validKnight, #validKnight + 1, id)
                    end
                end
            end
        end
    end

    return validKnight
end

function KnightsData:getMaterialKnight( exceptKnights )
    local knightArr = {}
    for i, value in pairs(self._knightIndex) do
        if exceptKnights[value] == nil then
            table.insert(knightArr, #knightArr + 1, value)
        end
    end

    return knightArr
end

function KnightsData:getKnightAcquireExp( knightId )
    local knightInfo = self:getKnightByKnightId(knightId)
    if knightInfo == nil then
        return 0
    end

    local exp = knightInfo["exp"] or 0
    local baseId = knightInfo["base_id"]
    if not baseId or baseId < 1 then
        return 0
    end

    local knightBaseInfo = knight_info.get(baseId)
    if knightBaseInfo == nil then
        return 0
    end

    return exp + knightBaseInfo.food_exp
end

function KnightsData:getKnightAdvancedLevel( advancedLevel )
    local ret = 0
    if advancedLevel == 5 or advancedLevel == 7 then
        ret = 1
    elseif advancedLevel == 8 then
        ret = 2
    elseif advancedLevel == 9 then
        ret = 3
    end

    return ret
end

function KnightsData:getKnightTrainingRange( knightId )
    local knightInfo = self:getKnightByKnightId(knightId)
    
    return self:calcTraingRange( knightInfo and knightInfo["level"] or 0, knightInfo and knightInfo["base_id"] or 0)
end

function KnightsData:calcTraingRange( level, baseId )
    baseId = baseId or 0
    level = level or 0

    local trainingRange = {}
    local knightBaseInfo = knight_info.get(baseId)
    if knightBaseInfo then
        knightBaseInfo = knight_info.get(knightBaseInfo.training_model)
    end

    if not knightBaseInfo then
        return trainingRange
    end
    
    require("app.cfg.knight_training_info")

    local trainingIndex = self:getTrainingSection(level)

    local trainingInfo = knight_training_info.get(trainingIndex)
    if trainingInfo and knightBaseInfo then 
        trainingRange["hp_max"] = math.floor(((knightBaseInfo.base_hp + 
            (trainingInfo.stage_correspond_level - 1) * knightBaseInfo.develop_hp) * trainingInfo.stage_uplimit_percentage) / 100)
        if knightBaseInfo.damage_type == 1 then
            trainingRange["at_max"] = math.floor(((knightBaseInfo.base_physical_attack + 
                (trainingInfo.stage_correspond_level - 1) * knightBaseInfo.develop_physical_attack) * trainingInfo.stage_uplimit_percentage) / 100)
        else
            trainingRange["at_max"] = math.floor(((knightBaseInfo.base_magical_attack + 
                (trainingInfo.stage_correspond_level - 1) * knightBaseInfo.develop_magical_attack) * trainingInfo.stage_uplimit_percentage) / 100)
        end

        trainingRange["pd_max"] = math.floor(((knightBaseInfo.base_physical_defence + 
            (trainingInfo.stage_correspond_level - 1) * knightBaseInfo.develop_physical_defence) * trainingInfo.stage_uplimit_percentage) / 100)
        trainingRange["md_max"] = math.floor(((knightBaseInfo.base_magical_defence + 
            (trainingInfo.stage_correspond_level - 1) * knightBaseInfo.develop_magical_defence) * trainingInfo.stage_uplimit_percentage) / 100)
    end

    return trainingRange
end

function KnightsData:getTrainingSection( level )
    local trainingIndex = 0
    require("app.cfg.knight_training_info")
    
    for i=1,knight_training_info.getLength() do
        local value = knight_training_info.indexOf(i)
        if level >= value.stage_start_level and level <= value.stage_end_level then
            return value.id 
        end
    end

    return trainingIndex
end

function KnightsData:isKnightCanTraining( knightId )
    local funLevelConst = require("app.const.FunctionLevelConst")
    local moduleUnlock = G_moduleUnlock:isModuleUnlock(funLevelConst.KNIGHT_TRAINING)
    local knightInfo = self:getKnightByKnightId(knightId)
    if not knightInfo then 
        return moduleUnlock, false
    end

    local trainingIndex = self:getTrainingSection(knightInfo["level"] or 0)
    if trainingIndex < 1 then
        return moduleUnlock, false
    end

    local trainingRange = self:calcTraingRange(knightInfo["level"] or 0, knightInfo["base_id"] or 0)
  --  if #trainingRange == 0 then
   --     return false
   -- end

    local trainingData = knightInfo["training"] or nil
    if not trainingData then
        return moduleUnlock, false
    end

    local hpValue = trainingData["hp"] or 0
    local atValue = trainingData["at"] or 0
    local pdValue = trainingData["pd"] or 0
    local mdValue = trainingData["md"] or 0

    local hpMax = trainingRange["hp_max"] or 0
    local atMax = trainingRange["at_max"] or 0
    local pdMax = trainingRange["pd_max"] or 0
    local mdMax = trainingRange["md_max"] or 0

    return moduleUnlock, hpValue < hpMax or atValue < atMax or pdValue < pdMax or mdValue < mdMax
end

function KnightsData:isKnightGuanghuanOpen( knightId )
    local funLevelConst = require("app.const.FunctionLevelConst")
    local moduleUnlock = G_moduleUnlock:isModuleUnlock(funLevelConst.KNIGHT_GUANGHUAN)
    if not moduleUnlock then 
        return moduleUnlock, false, false
    end

    local knightInfo = self:getKnightByKnightId(knightId)
    if not knightInfo then 
        return moduleUnlock, false, false
    end

    local baseId = knightInfo["base_id"]
    local knightBaseInfo = nil
    if type(baseId) == "number" then
        knightBaseInfo = knight_info.get(baseId)
        if not knightBaseInfo then
            return moduleUnlock, knightInfo.halo_level < 15, false
        end    
    end

    return moduleUnlock, knightInfo.halo_level < 15, knightBaseInfo and knightBaseInfo.quality > 1
end

-- function KnightsData:getTrainingKnights(  )
--     local knightArr = {}

--     for i, value in pairs(self._knightArr) do 
--         local trainingIndex = self:getTrainingSection(value["level"] or 0)
--         if trainingIndex > 0 and self:isKnightCanTraining(value["id"]) then
--             table.insert(knightArr, #knightArr + 1, value["id"])
--         end
--     end

--     return knightArr
-- end

function KnightsData:getGuanghuanKnights(  )
    local knightArr = {}

    for i, value in pairs(self._knightArr) do 
        local haloLevel = value["halo_level"] or 1
        if haloLevel < 10 then
           table.insert(knightArr, #knightArr + 1, value["id"])
        end 
    end

    return knightArr
end

function KnightsData:calcKnightHp( knightId )
    local knightInfo = self:getKnightByKnightId(knightId)
    if knightInfo == nil then
        return 0
    end

    local baseId = knightInfo["base_id"]
    if not baseId or baseId < 1 then
        return 0
    end

    local knightBaseInfo = knight_info.get(baseId)
    if knightBaseInfo == nil then
        return 0
    end
    local level = knightInfo["level"]
    return knightBaseInfo.base_hp + (level - 1)*knightBaseInfo.develop_hp
end

function KnightsData:calcAttack( knightId )
    local knightInfo = self:getKnightByKnightId(knightId)
    if knightInfo == nil then
        return 0
    end

    local baseId = knightInfo["base_id"]
    if not baseId or baseId < 1 then
        return 0
    end

    return self:calcAttackByBaseId(baseId, knightInfo["level"])
end

function KnightsData:calcAttackByBaseId( baseId, level )
    level = level or 1
    local knightBaseInfo = knight_info.get(baseId)
    if knightBaseInfo == nil then
        return 0
    end

    if knightBaseInfo.damage_type == 1 then
        return knightBaseInfo.base_physical_attack + (level - 1)*knightBaseInfo.develop_physical_attack
    else
        return knightBaseInfo.base_magical_attack + (level - 1)*knightBaseInfo.develop_magical_attack
    end
end

function KnightsData:calcPhysicalDefence( knightId )
    local knightInfo = self:getKnightByKnightId(knightId)
    if knightInfo == nil then
        return 0
    end

    local baseId = knightInfo["base_id"]
    if not baseId or baseId < 1 then
        return 0
    end

    local knightBaseInfo = knight_info.get(baseId)
    if knightBaseInfo == nil then
        return 0
    end
    local level = knightInfo["level"]

    return knightBaseInfo.base_physical_defence + (level - 1)*knightBaseInfo.develop_physical_defence
end

function KnightsData:calcMagicDefence( knightId )
    local knightInfo = self:getKnightByKnightId(knightId)
    if knightInfo == nil then
        return 0
    end

    local baseId = knightInfo["base_id"]
    if not baseId or baseId < 1 then
        return 0
    end

    local knightBaseInfo = knight_info.get(baseId)
    if knightBaseInfo == nil then
        return 0
    end
    local level = knightInfo["level"]

    return knightBaseInfo.base_magical_defence + (level - 1)*knightBaseInfo.develop_magical_defence
end


function KnightsData:calcAssocition( baseId )
        local baseInfo = knight_info.get(baseId or 0)
        if not baseInfo then
            return nil
        end

        require("app.cfg.association_info")
        local associtionKnightArr = {}
       
        local findKnightAssociation = function ( associtionId )
            local associtionInfo = association_info.get(associtionId)            
            local associtionKnights = {}
            local count = 0
            if associtionInfo then 
                if associtionInfo.info_type == 1 then
                    if associtionInfo.info_value_1 > 0 then
                        count = count + 1
                        associtionKnights[associtionInfo.info_value_1] = 1
                        --associtionKnights[associtionInfo.info_value_1.."_name"] = associtionInfo.name
                    end
                    if associtionInfo.info_value_2 > 0 then
                        count = count + 1
                        associtionKnights[associtionInfo.info_value_2] = 1
                        --associtionKnights[associtionInfo.info_value_2.."_name"] = associtionInfo.name
                    end
                    if associtionInfo.info_value_3 > 0 then
                        count = count + 1
                        associtionKnights[associtionInfo.info_value_3] = 1
                        --associtionKnights[associtionInfo.info_value_3.."_name"] = associtionInfo.name
                    end
                    if associtionInfo.info_value_4 > 0 then
                        count = count + 1
                        associtionKnights[associtionInfo.info_value_4] = 1
                        --associtionKnights[associtionInfo.info_value_4.."_name"] = associtionInfo.name
                    end
                    if associtionInfo.info_value_5 > 0 then
                        count = count + 1
                        associtionKnights[associtionInfo.info_value_5] = 1
                        --associtionKnights[associtionInfo.info_value_5.."_name"] = associtionInfo.name
                    end
                end
            end

            return associtionKnights, count
        end

        -- 计算武将之间的缘分关系
        local associtionKnights, count = findKnightAssociation(baseInfo.association_1)
        if count > 0 then
            associtionKnightArr[baseInfo.association_1] = associtionKnights
        end
        associtionKnights, count = findKnightAssociation(baseInfo.association_2)
        if count > 0 then
            associtionKnightArr[baseInfo.association_2] = associtionKnights
        end
        associtionKnights, count = findKnightAssociation(baseInfo.association_3)
        if count > 0 then
            associtionKnightArr[baseInfo.association_3] = associtionKnights
        end
        associtionKnights, count = findKnightAssociation(baseInfo.association_4)
        if count > 0 then
            associtionKnightArr[baseInfo.association_4] = associtionKnights
        end
        associtionKnights, count = findKnightAssociation(baseInfo.association_5)
        if count > 0 then
            associtionKnightArr[baseInfo.association_5] = associtionKnights
        end
        associtionKnights, count = findKnightAssociation(baseInfo.association_6)
        if count > 0 then
            associtionKnightArr[baseInfo.association_6] = associtionKnights
        end

            -- 针对主将可能多出6个缘分
        if baseInfo.association_7 > 0 then 
            associtionKnights, count = findKnightAssociation(baseInfo.association_7)
            if count > 0 then
                associtionKnightArr[baseInfo.association_7] = associtionKnights
            end
        end
        if baseInfo.association_8 > 0 then 
            associtionKnights, count = findKnightAssociation(baseInfo.association_8)
            if count > 0 then
                associtionKnightArr[baseInfo.association_8] = associtionKnights
            end
        end
        if baseInfo.association_9 > 0 then 
            associtionKnights, count = findKnightAssociation(baseInfo.association_9)
            if count > 0 then
                associtionKnightArr[baseInfo.association_9] = associtionKnights
            end
        end
        if baseInfo.association_10 > 0 then 
            associtionKnights, count = findKnightAssociation(baseInfo.association_10)
            if count > 0 then
                associtionKnightArr[baseInfo.association_10] = associtionKnights
            end
        end
        if baseInfo.association_11 > 0 then 
            associtionKnights, count = findKnightAssociation(baseInfo.association_11)
            if count > 0 then
                associtionKnightArr[baseInfo.association_11] = associtionKnights
            end
        end
        if baseInfo.association_12 > 0 then 
            associtionKnights, count = findKnightAssociation(baseInfo.association_12)
            if count > 0 then
                associtionKnightArr[baseInfo.association_12] = associtionKnights
            end
        end


    return associtionKnightArr
end

function KnightsData:getRequireKnightJipan( exceptPos )
    exceptPos = exceptPos or 0

    local knightsList = {}
    local arr = G_Me.formationData:getFirstTeamKnightIds()
    for key, value in pairs(arr) do 
        if value > 0 and key ~= exceptPos then
            local knightInfo = self:getKnightByKnightId(value)
            if knightInfo then
                local baseId = knightInfo["base_id"] or 0 
                local knightBaseInfo = knight_info.get(baseId)
                if knightBaseInfo then
                    knightsList[knightBaseInfo.advance_code] = self:calcAssocition(baseId)
                    knightsList[knightBaseInfo.advance_code]["name"] = knightBaseInfo.name
                end
            end            
        end
    end

    arr = G_Me.formationData:getSecondTeamKnightIds()
    for key, value in pairs(arr) do 
        if value > 0 and (key + 6) ~= exceptPos then
            local knightInfo = self:getKnightByKnightId(value)
            if knightInfo then
                local baseId = knightInfo["base_id"] or 0 
                local knightBaseInfo = knight_info.get(baseId)
                if knightBaseInfo then
                    knightsList[knightBaseInfo.advance_code] = {1}
                    knightsList[knightBaseInfo.advance_code]["name"] = knightBaseInfo.name
                end
            end            
        end
    end

    return knightsList
end

function KnightsData:calcKnightJipanForEquip( advanceCode, pos )
    
end

function KnightsData:getRequireKnightHeji( exceptPos )
    exceptPos = exceptPos or 0

    require("app.cfg.skill_info")

    local knightsList = {}
    local arr = G_Me.formationData:getFirstTeamKnightIds()
    for key, value in pairs(arr) do 
        if value > 0 and key ~= exceptPos then
            local knightInfo = self:getKnightByKnightId(value)
            if knightInfo then
                local baseId = knightInfo["base_id"] or 0 
                local knightBaseInfo = knight_info.get(baseId)
                if knightBaseInfo then
                    local hejiList = {}
                    if knightBaseInfo.release_knight_1 > 0 then 
                        hejiList[knightBaseInfo.release_knight_1] = 1 
                    end
                    if knightBaseInfo.release_knight_2 > 0 then 
                        hejiList[knightBaseInfo.release_knight_2] = 1 
                    end
                    if knightBaseInfo.release_knight_1 > 0 or knightBaseInfo.release_knight_2 > 0 then 
                        knightsList[knightBaseInfo.advance_code] = hejiList
                       -- knightsList[knightBaseInfo.advance_code]["name"] = knightBaseInfo.name
                    end
                end
            end            
        end
    end

    return knightsList
end

function KnightsData:getRequireEquipJipan( knightPos, equipPos )
    if type(knightPos) ~= "number" or type(equipPos) ~= "number" or knightPos < 1 or equipPos < 1 then 
        return 
    end

    local findEquipAssociation = function ( associtionId )
            local associtionInfo = association_info.get(associtionId)            
            local associtionKnights = {}
            local count = 0
            if associtionInfo then 
                if associtionInfo.info_type == 2 or associtionInfo.info_type == 3 then
                    if associtionInfo.info_value_1 > 0 then
                        count = count + 1
                        associtionKnights[associtionInfo.info_value_1] = 1
                    end
                    if associtionInfo.info_value_2 > 0 then
                        count = count + 1
                        associtionKnights[associtionInfo.info_value_2] = 1
                    end
                    if associtionInfo.info_value_3 > 0 then
                        count = count + 1
                        associtionKnights[associtionInfo.info_value_3] = 1
                    end
                    if associtionInfo.info_value_4 > 0 then
                        count = count + 1
                        associtionKnights[associtionInfo.info_value_4] = 1
                    end
                    if associtionInfo.info_value_5 > 0 then
                        count = count + 1
                        associtionKnights[associtionInfo.info_value_5] = 1
                    end
                end
            end

            return associtionKnights, count
        end

        local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex( 1, knightPos )
        if not baseId or baseId < 1 then 
            return 
        end 

        local baseInfo = knight_info.get(baseId)
        if not baseInfo then 
            return 
        end

        local associtionEquipArr = {}
        local associtionKnights, count = findEquipAssociation(baseInfo.association_1)
            if count > 0 then
                associtionEquipArr[baseInfo.association_1] = associtionKnights
            end
            associtionKnights, count = findEquipAssociation(baseInfo.association_2)
            if count > 0 then
                associtionEquipArr[baseInfo.association_2] = associtionKnights
            end
            associtionKnights, count = findEquipAssociation(baseInfo.association_3)
            if count > 0 then
                associtionEquipArr[baseInfo.association_3] = associtionKnights
            end
            associtionKnights, count = findEquipAssociation(baseInfo.association_4)
            if count > 0 then
                associtionEquipArr[baseInfo.association_4] = associtionKnights
            end
            associtionKnights, count = findEquipAssociation(baseInfo.association_5)
            if count > 0 then
                associtionEquipArr[baseInfo.association_5] = associtionKnights
            end
            associtionKnights, count = findEquipAssociation(baseInfo.association_6)
            if count > 0 then
                associtionEquipArr[baseInfo.association_6] = associtionKnights
            end

            -- 针对主将可能多出6个缘分
            if baseInfo.association_7 > 0 then 
                associtionKnights, count = findEquipAssociation(baseInfo.association_7)
                if count > 0 then
                    associtionEquipArr[baseInfo.association_7] = associtionKnights
                end
            end
            if baseInfo.association_8 > 0 then 
                associtionKnights, count = findEquipAssociation(baseInfo.association_8)
                if count > 0 then
                    associtionEquipArr[baseInfo.association_8] = associtionKnights
                end
            end
            if baseInfo.association_9 > 0 then 
                associtionKnights, count = findEquipAssociation(baseInfo.association_9)
                if count > 0 then
                    associtionEquipArr[baseInfo.association_9] = associtionKnights
                end
            end
            if baseInfo.association_10 > 0 then 
                associtionKnights, count = findEquipAssociation(baseInfo.association_10)
                if count > 0 then
                    associtionEquipArr[baseInfo.association_10] = associtionKnights
                end
            end
            if baseInfo.association_11 > 0 then 
                associtionKnights, count = findEquipAssociation(baseInfo.association_11)
                if count > 0 then
                   associtionEquipArr[baseInfo.association_11] = associtionKnights
                end
            end
            if baseInfo.association_12 > 0 then 
                associtionKnights, count = findEquipAssociation(baseInfo.association_12)
                if count > 0 then
                    associtionEquipArr[baseInfo.association_12] = associtionKnights
                end
            end

            return associtionEquipArr
end

function KnightsData:calcJiPanByNewKnight( knightId )
    if not knightId or knightId <= 0  then 
        return 
    end

    require("app.cfg.knight_info")
    local mainKnightInfo = self:getKnightByKnightId(knightId)
    if not mainKnightInfo then
        __LogError("Invalid knightId")
        return 
    end
    local mainKnightBaseId = mainKnightInfo["base_id"]
    local mainKnightBaseInfo = knight_info.get(mainKnightBaseId)
    if not mainKnightBaseInfo then
        return 
    end
    local mainKnightAdvanceId = mainKnightBaseInfo.advance_code

    local knightsList = {}
    local knightAdvanceList = {}
    local arr = G_Me.formationData:getFirstTeamKnightIds()
    for key, value in pairs(arr) do 
        if value > 0 and value ~= knightId then
            local secondKnightInfo = self:getKnightByKnightId(value)
            if secondKnightInfo then
                knightsList[secondKnightInfo["base_id"]] = 1
                local knightBaseInfo = knight_info.get(secondKnightInfo["base_id"])
                if knightBaseInfo then
                    knightAdvanceList[knightBaseInfo.advance_code] = 1
                end
            end            
        end
    end
    arr = G_Me.formationData:getSecondTeamKnightIds()
    for key, value in pairs(arr) do 
        if value > 0 and value ~= knightId then
            local secondKnightInfo = self:getKnightByKnightId(value)
            if secondKnightInfo then
                local knightBaseInfo = knight_info.get(secondKnightInfo["base_id"])
                if knightBaseInfo then
                    knightAdvanceList[knightBaseInfo.advance_code] = 1
                end
            end            
        end
    end

    local calcAssocition = function ( baseId, mainKnightId, knightAdvanceId )
        local baseInfo = knight_info.get(baseId)
        if not baseInfo then
            return nil
        end

        local associtionKnightArr = {}
        local associtionEquipArr = {}

        require("app.cfg.association_info")
        local findKnightAssociation = function ( associtionId )
            local associtionInfo = association_info.get(associtionId)            
            local associtionKnights = {}
            local count = 0
            if associtionInfo then 
                if associtionInfo.info_type == 1 then
                    if associtionInfo.info_value_1 > 0 then
                        count = count + 1
                        associtionKnights[associtionInfo.info_value_1] = 1
                    end
                    if associtionInfo.info_value_2 > 0 then
                        count = count + 1
                        associtionKnights[associtionInfo.info_value_2] = 1
                    end
                    if associtionInfo.info_value_3 > 0 then
                        count = count + 1
                        associtionKnights[associtionInfo.info_value_3] = 1
                    end
                    if associtionInfo.info_value_4 > 0 then
                        count = count + 1
                        associtionKnights[associtionInfo.info_value_4] = 1
                    end
                    if associtionInfo.info_value_5 > 0 then
                        count = count + 1
                        associtionKnights[associtionInfo.info_value_5] = 1
                    end
                end
            end

            return associtionKnights, count
        end

        -- 计算武将之间的缘分关系
        local associtionKnights, count = findKnightAssociation(baseInfo.association_1)
        if count > 0 and (associtionKnights[knightAdvanceId] or baseId == mainKnightId) then
            associtionKnightArr[baseInfo.association_1] = associtionKnights
        end
        associtionKnights, count = findKnightAssociation(baseInfo.association_2)
        if count > 0 and (associtionKnights[knightAdvanceId] or baseId == mainKnightId) then
            associtionKnightArr[baseInfo.association_2] = associtionKnights
        end
        associtionKnights, count = findKnightAssociation(baseInfo.association_3)
        if count > 0 and (associtionKnights[knightAdvanceId] or baseId == mainKnightId) then
            associtionKnightArr[baseInfo.association_3] = associtionKnights
        end
        associtionKnights, count = findKnightAssociation(baseInfo.association_4)
        if count > 0 and (associtionKnights[knightAdvanceId] or baseId == mainKnightId) then
            associtionKnightArr[baseInfo.association_4] = associtionKnights
        end
        associtionKnights, count = findKnightAssociation(baseInfo.association_5)
        if count > 0 and (associtionKnights[knightAdvanceId] or baseId == mainKnightId) then
            associtionKnightArr[baseInfo.association_5] = associtionKnights
        end
        associtionKnights, count = findKnightAssociation(baseInfo.association_6)
        if count > 0 and (associtionKnights[knightAdvanceId] or baseId == mainKnightId) then
            associtionKnightArr[baseInfo.association_6] = associtionKnights
        end

            -- 针对主将可能多出6个缘分
        if baseInfo.association_7 > 0 then 
            associtionKnights, count = findKnightAssociation(baseInfo.association_7)
            if count > 0 then
                associtionKnightArr[baseInfo.association_7] = associtionKnights
            end
        end
        if baseInfo.association_8 > 0 then 
            associtionKnights, count = findKnightAssociation(baseInfo.association_8)
            if count > 0 then
                associtionKnightArr[baseInfo.association_8] = associtionKnights
            end
        end
        if baseInfo.association_9 > 0 then 
            associtionKnights, count = findKnightAssociation(baseInfo.association_9)
            if count > 0 then
                associtionKnightArr[baseInfo.association_9] = associtionKnights
            end
        end
        if baseInfo.association_10 > 0 then 
            associtionKnights, count = findKnightAssociation(baseInfo.association_10)
            if count > 0 then
                associtionKnightArr[baseInfo.association_10] = associtionKnights
            end
        end
        if baseInfo.association_11 > 0 then 
            associtionKnights, count = findKnightAssociation(baseInfo.association_11)
            if count > 0 then
                associtionKnightArr[baseInfo.association_11] = associtionKnights
            end
        end
        if baseInfo.association_12 > 0 then 
            associtionKnights, count = findKnightAssociation(baseInfo.association_12)
            if count > 0 then
                associtionKnightArr[baseInfo.association_12] = associtionKnights
            end
        end


        local findEquipAssociation = function ( associtionId )
            local associtionInfo = association_info.get(associtionId)            
            local associtionKnights = {}
            local count = 0
            if associtionInfo then 
                if associtionInfo.info_type == 2 or associtionInfo.info_type == 3 then
                    if associtionInfo.info_value_1 > 0 then
                        count = count + 1
                        associtionKnights[associtionInfo.info_value_1] = 1
                    end
                    if associtionInfo.info_value_2 > 0 then
                        count = count + 1
                        associtionKnights[associtionInfo.info_value_2] = 1
                    end
                    if associtionInfo.info_value_3 > 0 then
                        count = count + 1
                        associtionKnights[associtionInfo.info_value_3] = 1
                    end
                    if associtionInfo.info_value_4 > 0 then
                        count = count + 1
                        associtionKnights[associtionInfo.info_value_4] = 1
                    end
                    if associtionInfo.info_value_5 > 0 then
                        count = count + 1
                        associtionKnights[associtionInfo.info_value_5] = 1
                    end
                end
            end

            return associtionKnights, count
        end

        if mainKnightId == baseId then
        -- 计算装备与武将的缘分关系
            local associtionKnights, count = findEquipAssociation(baseInfo.association_1)
            if count > 0 then
                associtionEquipArr[baseInfo.association_1] = associtionKnights
            end
            associtionKnights, count = findEquipAssociation(baseInfo.association_2)
            if count > 0 then
                associtionEquipArr[baseInfo.association_2] = associtionKnights
            end
            associtionKnights, count = findEquipAssociation(baseInfo.association_3)
            if count > 0 then
                associtionEquipArr[baseInfo.association_3] = associtionKnights
            end
            associtionKnights, count = findEquipAssociation(baseInfo.association_4)
            if count > 0 then
                associtionEquipArr[baseInfo.association_4] = associtionKnights
            end
            associtionKnights, count = findEquipAssociation(baseInfo.association_5)
            if count > 0 then
                associtionEquipArr[baseInfo.association_5] = associtionKnights
            end
            associtionKnights, count = findEquipAssociation(baseInfo.association_6)
            if count > 0 then
                associtionEquipArr[baseInfo.association_6] = associtionKnights
            end

            -- 针对主将可能多出6个缘分
            if baseInfo.association_7 > 0 then 
                associtionKnights, count = findEquipAssociation(baseInfo.association_7)
                if count > 0 then
                    associtionEquipArr[baseInfo.association_7] = associtionKnights
                end
            end
            if baseInfo.association_8 > 0 then 
                associtionKnights, count = findEquipAssociation(baseInfo.association_8)
                if count > 0 then
                    associtionEquipArr[baseInfo.association_8] = associtionKnights
                end
            end
            if baseInfo.association_9 > 0 then 
                associtionKnights, count = findEquipAssociation(baseInfo.association_9)
                if count > 0 then
                    associtionEquipArr[baseInfo.association_9] = associtionKnights
                end
            end
            if baseInfo.association_10 > 0 then 
                associtionKnights, count = findEquipAssociation(baseInfo.association_10)
                if count > 0 then
                    associtionEquipArr[baseInfo.association_10] = associtionKnights
                end
            end
            if baseInfo.association_11 > 0 then 
                associtionKnights, count = findEquipAssociation(baseInfo.association_11)
                if count > 0 then
                   associtionEquipArr[baseInfo.association_11] = associtionKnights
                end
            end
            if baseInfo.association_12 > 0 then 
                associtionKnights, count = findEquipAssociation(baseInfo.association_12)
                if count > 0 then
                    associtionEquipArr[baseInfo.association_12] = associtionKnights
                end
            end
        end

        return associtionKnightArr, associtionEquipArr
    end

    local compareKnightAssociationInfo = function( knightAssociation, knight, advancedIdList, activeAssocition, mainAdvancedId ) 
            if not knightAssociation or not advancedIdList then
                return 
            end

            activeAssocition = activeAssocition or {}
            for associtionId, knightArr in pairs(knightAssociation) do 
                -- local associtionIsActive = false
                -- for key, knightId in pairs(knightArr) do 
                --     if (key == mainAdvancedId) or (advancedIdList[key] and key ~= mainAdvancedId) then 
                --         associtionIsActive = true
                --         __Log("mainAdvancedId:%d, ke:%d", mainAdvancedId, key)
                --         dump(advancedIdList)
                --         dump(knightArr)
                --     end
                -- end
                local associtionIsActive = true
                for key, knightId in pairs(knightArr) do
                    if key ~= mainAdvancedId and not advancedIdList[key] then 
                        associtionIsActive = false
                    end
                end

                if associtionIsActive then
                    table.insert(activeAssocition, #activeAssocition + 1, {knight, associtionId, knight == mainKnightBaseId and 1 or 0})
                end
            end

            return activeAssocition
    end

    local compareEquipAssociationInfo = function( equipAssociation, knight, activeAssocition, mainKnightAdvanceId ) 
            if not equipAssociation then
                return 
            end

            local teamId, slotId = G_Me.formationData:getTeamSlotByKnightId(knight)
            if not teamId or teamId == 2 or slotId < 1 or slotId > 6 then 
                return 
            end

            local equips = G_Me.formationData:getFightEquipByPos(teamId, slotId)
            local treasures = G_Me.formationData:getFightTreasureByPos(teamId, slotId)

            local equipIds = {}
            for key, value in pairs(equips) do 
                local equipInfo = G_Me.bagData.equipmentList:getItemByKey(value)
                if equipInfo then 
                    equipIds[equipInfo["base_id"]] = 1
                end
            end
            for key, value in pairs(treasures) do 
                local equipInfo = G_Me.bagData.treasureList:getItemByKey(value)
                if equipInfo then 
                    equipIds[equipInfo["base_id"]] = 1
                end
            end

            activeAssocition = activeAssocition or {}
            for associtionId, equipArr in pairs(equipAssociation) do 
                local associtionIsActive = false
                for key, equipId in pairs(equipArr) do 
                    if key and equipIds[key] then 
                        associtionIsActive = true
                    end
                end

                if associtionIsActive then
                    table.insert(activeAssocition, #activeAssocition + 1, {mainKnightAdvanceId, associtionId, 1})
                end
            end

            return activeAssocition
    end

    local activeAssocitionList = {}

    local mainKnightAssociation, mainEquipAssocition = calcAssocition(mainKnightBaseId, mainKnightBaseId, mainKnightAdvanceId)
    compareKnightAssociationInfo(mainKnightAssociation, mainKnightBaseId, knightAdvanceList, activeAssocitionList, mainKnightAdvanceId)
    
    compareEquipAssociationInfo(mainEquipAssocition, knightId, activeAssocitionList, mainKnightAdvanceId)
    for key, value in pairs(knightsList) do 
        local knightAssociation, equipAssocition = calcAssocition(key, mainKnightBaseId, mainKnightAdvanceId)
        compareKnightAssociationInfo(knightAssociation, key, knightAdvanceList, activeAssocitionList, mainKnightAdvanceId) 
    end    

    return activeAssocitionList
end


-- 武将一级属性(生命，物攻，魔攻，物防，魔防)   
--  （武将胚子属性+武将强化属性+武将培养属性+装备胚子属性+装备强化属性+装备精炼属性+装备套装属性+宝物精炼属性+三国志碎片属性）
--   *（1+武将光环百分比+武将点灯组合百分比+宝物胚子百分比+宝物强化百分比）
-- 武将二级属性（命中率，回避率，暴击率，闪避率，伤害增加，伤害减免）    
--  （武将被动技能+装备精炼+宝物胚子+宝物强化+宝物精炼+装备套装）

--获得侠客的1级属性(4个)
local function _knightPrint(str)
   -- print(str)
end


--knight为服务器返回的knight不是knight_info里的
function KnightsData:getKnightAttr1ByKnight(knightInfo)
    if not knightInfo then 
        return {}    
    end
    local knightId = knightInfo.id
    local baseId = knightInfo["base_id"]   
    local knightBaseInfo = knight_info.get(baseId)
    
    local damage_type = knightBaseInfo.damage_type --1是物攻 2是魔攻

    local hp = 0
    local phyAttack = 0
    local magicAttack = 0
    local phyDefense = 0
    local magicDefense = 0
    _knightPrint("================武将胚子值================")

    _knightPrint("base:" .. baseId)
    _knightPrint("hp:" .. knightBaseInfo.base_hp)
    _knightPrint("phyAttack:" .. knightBaseInfo.base_physical_attack)
    _knightPrint("magicAttack:" .. knightBaseInfo.base_magical_attack)
    _knightPrint("phyDefense:" .. knightBaseInfo.base_physical_defence)
    _knightPrint("magicDefense:" .. knightBaseInfo.base_magical_defence)

    --武将胚子属性+武将强化属性
    local level = knightInfo["level"]
    hp = knightBaseInfo.base_hp + (level - 1)*knightBaseInfo.develop_hp
    phyAttack = knightBaseInfo.base_physical_attack + (level - 1)*knightBaseInfo.develop_physical_attack
    magicAttack = knightBaseInfo.base_magical_attack+ (level - 1)*knightBaseInfo.develop_magical_attack
    phyDefense = knightBaseInfo.base_physical_defence + (level - 1)*knightBaseInfo.develop_physical_defence
    magicDefense = knightBaseInfo.base_magical_defence+ (level - 1)*knightBaseInfo.develop_magical_defence

    _knightPrint("================武将强化值================")
    _knightPrint("hp:" .. hp)
    _knightPrint("phyAttack:" .. phyAttack)
    _knightPrint("magicAttack:" .. magicAttack)
    _knightPrint("phyDefense:" .. phyDefense)
    _knightPrint("magicDefense:" .. magicDefense)

    --武将培养属性
    hp = hp + knightInfo.training.hp
    phyAttack = phyAttack + (damage_type == 1 and knightInfo.training.at or 0)
    magicAttack = magicAttack + (damage_type == 2 and knightInfo.training.at or 0)
    phyDefense = phyDefense + knightInfo.training.pd
    magicDefense = magicDefense + knightInfo.training.md

    _knightPrint("================培养加成之后================")
    _knightPrint("hp:" .. hp)
    _knightPrint("phyAttack:" .. phyAttack)
    _knightPrint("magicAttack:" .. magicAttack)
    _knightPrint("phyDefense:" .. phyDefense)
    _knightPrint("magicDefense:" .. magicDefense)

    _knightPrint("================下面开始计算各种属性加成================")

    --下面的要根据各种type value来计算属性
    
    -- 查看装备和宝物的加成
    local hpRate = 0
    local phyAttackRate = 0
    local magicAttackRate = 0
    local phyDefenseRate = 0
    local magicDefenseRate = 0

    local hpAdd = 0
    local phyAttackAdd = 0
    local magicAttackAdd = 0
    local phyDefenseAdd = 0
    local magicDefenseAdd = 0

    local function addValue(attrInfo)
        if attrInfo.type > 0 and attrInfo.value > 0 then
            _knightPrint("type=" .. attrInfo.type .. ", value=" .. attrInfo.value)

        end

        if attrInfo.type == AttributesConst.ATTRIBUTE_TYPE.ATTRIBUTE_WUGONG_P then
            if damage_type == 1 then
                phyAttackRate = phyAttackRate + attrInfo.value/ 10
            end
        elseif attrInfo.type == AttributesConst.ATTRIBUTE_TYPE.ATTRIBUTE_MOGONG_P then
            if damage_type == 2 then
                magicAttackRate = magicAttackRate + attrInfo.value/ 10
            end
        elseif attrInfo.type == AttributesConst.ATTRIBUTE_TYPE.ATTRIBUTE_WUFANG_P then
            --物防率
            phyDefenseRate = phyDefenseRate + attrInfo.value / 10
        elseif attrInfo.type == AttributesConst.ATTRIBUTE_TYPE.ATTRIBUTE_MOFANG_P then
            --魔防率
            magicDefenseRate = magicDefenseRate + attrInfo.value/ 10
        elseif attrInfo.type == AttributesConst.ATTRIBUTE_TYPE.ATTRIBUTE_SHENGMING_P then
            --HP率
            hpRate = hpRate + attrInfo.value/ 10
        elseif attrInfo.type == AttributesConst.ATTRIBUTE_TYPE.ATTRIBUTE_GONGJI_P then
            --攻击率
            if damage_type == 1 then
                phyAttackRate = phyAttackRate + attrInfo.value/ 10
            else
                magicAttackRate = magicAttackRate + attrInfo.value/ 10
            end
        elseif attrInfo.type == AttributesConst.ATTRIBUTE_TYPE.ATTRIBUTE_WUGONG then
            if damage_type == 1 then
                phyAttackAdd = phyAttackAdd + attrInfo.value
            end
        elseif attrInfo.type == AttributesConst.ATTRIBUTE_TYPE.ATTRIBUTE_MOGONG then
            if damage_type == 2 then
                magicAttackAdd = magicAttackAdd + attrInfo.value
            end
        elseif attrInfo.type == AttributesConst.ATTRIBUTE_TYPE.ATTRIBUTE_WUFANG then
            --物防
            phyDefenseAdd = phyDefenseAdd + attrInfo.value
        elseif attrInfo.type == AttributesConst.ATTRIBUTE_TYPE.ATTRIBUTE_MOFANG then
            --魔防
            magicDefenseAdd = magicDefenseAdd + attrInfo.value
        elseif attrInfo.type == AttributesConst.ATTRIBUTE_TYPE.ATTRIBUTE_SHENGMING then
            --HP
            hpAdd = hpAdd + attrInfo.value
        elseif attrInfo.type == AttributesConst.ATTRIBUTE_TYPE.ATTRIBUTE_GONGJI then
            --攻击
            if damage_type == 1 then
                phyAttackAdd = phyAttackAdd + attrInfo.value

            else
                magicAttackAdd = magicAttackAdd + attrInfo.value

            end
        elseif attrInfo.type == AttributesConst.ATTRIBUTE_TYPE.ATTRIBUTE_FANGYU then
            magicDefenseAdd = magicDefenseAdd + attrInfo.value
            phyDefenseAdd = phyDefenseAdd + attrInfo.value
        
        elseif attrInfo.type == AttributesConst.ATTRIBUTE_TYPE.ATTRIBUTE_WUFANG_AND_MOFANG_P then
            -- 同时增加物防和魔防百分比
            phyDefenseRate = phyDefenseRate + attrInfo.value / 10
            magicDefenseRate = magicDefenseRate + attrInfo.value/ 10
        elseif attrInfo.type == AttributesConst.ATTRIBUTE_TYPE.ATTRIBUTE_ALL_ADD then
            --HP率
            hpRate = hpRate + attrInfo.value/ 10
            phyDefenseRate = phyDefenseRate + attrInfo.value / 10
            magicDefenseRate = magicDefenseRate + attrInfo.value/ 10
            --攻击率
            if damage_type == 1 then
                phyAttackRate = phyAttackRate + attrInfo.value/ 10
            else
                magicAttackRate = magicAttackRate + attrInfo.value/ 10
            end
        end
    end

    local team,slot = G_Me.formationData:getTeamSlotByKnightId(knightId)
    if team  == 1 then
        --获取这个slot阵容位上 4个装备 2个宝物
        _knightPrint("=====上阵装备加成=====")

        local equipments = {}
        for i=1,4 do 
            local fightEquipment = G_Me.formationData:getFightEquipmentBySlot(team, slot, i)
            if fightEquipment ~= nil and fightEquipment ~= 0 then
                local equipment = G_Me.bagData.equipmentList:getItemByKey(fightEquipment)
                local strengthAttrs =  equipment:getStrengthAttrs()
                local refineAttrs = equipment:getRefineAttrs()
                local starAttrs = equipment:getStarAttrs()
                
                for a, attr in ipairs(strengthAttrs) do
                     addValue(attr)
                end
                for a, attr in ipairs(refineAttrs) do
                     addValue(attr)
                end
                for a, attr in ipairs(starAttrs) do
                     addValue(attr)
                end
                
                local baseInfo = equipment:getInfo()
                -- 一个装备最多可能有4个神兵技能，而且可以同时生效？
                for i=1, 10 do
                    local equipmentSkillId = baseInfo["equipment_skill_"..i]
                    if equipmentSkillId and equipmentSkillId ~= 0 then
                        local equipmentSkillInfo = equipment_skill_info.get(equipmentSkillId)
                        assert(equipmentSkillInfo, "Could not find the equipmentSkillInfo with id: "..tostring(equipmentSkillId))
                        
                        -- open_value表示开启等级显示，还有一个open_type表示开启等级类型，默认1是装备精炼等级，2是宝物精炼等级，因为不统一所以先不考虑整理
                        if equipment.refining_level >= equipmentSkillInfo.open_value then
                            addValue{
                                type = equipmentSkillInfo.attribute_type,
                                value = equipmentSkillInfo.attribute_value
                            }
                        end
                    end
                end
                
                table.insert(equipments, equipment)


            end
        end
        _knightPrint("=====上阵宝物加成=====")

        for i=1,2 do 
            local fightTreasure = G_Me.formationData:getFightTreasureBySlot(team, slot, i)
            if fightTreasure ~= nil and fightTreasure ~= 0 then
                local treasure = G_Me.bagData.treasureList:getItemByKey(fightTreasure)
                local strengthAttrs =  treasure:getStrengthAttrs()
                local refineAttrs = treasure:getRefineAttrs()  
                
                for a, attr in ipairs(strengthAttrs) do
                     addValue(attr)
                end
                for a, attr in ipairs(refineAttrs) do
                     addValue(attr)
                end
                
                local baseInfo = treasure:getInfo()
                -- 宝物与装备一致
                for i=1, 10 do
                    local treasureSkillId = baseInfo["equipment_skill_"..i]
                    if treasureSkillId and treasureSkillId ~= 0 then
                        local equipmentSkillInfo = equipment_skill_info.get(treasureSkillId)
                        assert(equipmentSkillInfo, "Could not find the equipmentSkillInfo with id: "..tostring(treasureSkillId))
                        
                        if treasure.refining_level >= equipmentSkillInfo.open_value then
                            addValue{
                                type = equipmentSkillInfo.attribute_type,
                                value = equipmentSkillInfo.attribute_value
                            }
                        end
                    end
                end
            end
        end

        --计算套装属性
        local suites = MergeEquipment.getSuitListFromEquipmentList(equipments)
        if #suites > 0 then
            _knightPrint("=====套装加成=====")
            for i,v in ipairs(suites) do 
                local attrs = v.attrs
                for a, attr in ipairs(attrs) do
                   addValue(attr)
                end
            end
        end

        -- 将灵属性加成
        local heroSoulAttrs = G_Me.heroSoulData:getChartAttrs()
        for k, v in pairs(heroSoulAttrs) do
            addValue({type = k, value = v})
        end


        --三国志碎片加成
        --_knightPrint("======三国志碎片加成======")
        -- local sanguozhiList = G_Me.storyDungeonData:getSanGuoZhiFinishList()
        -- if sanguozhiList ~= nil then
        --     for sid, v in pairs(sanguozhiList) do
        --      local record_sanguozhi_info = sanguozhi_info.get(sid)
        --      if record_sanguozhi_info then
        --          hpAdd = hpAdd + record_sanguozhi_info.health_add
        --          if damage_type == 1 then
        --              phyAttackAdd = phyAttackAdd + record_sanguozhi_info.attack_add
        --          else
        --              magicAttackAdd = magicAttackAdd + record_sanguozhi_info.attack_add
        --          end


        --          phyDefenseAdd = phyDefenseAdd + record_sanguozhi_info.physical_defence_add
        --          magicDefenseAdd = magicDefenseAdd + record_sanguozhi_info.magical_defence_add

        --          _knightPrint("hpAdd +" .. record_sanguozhi_info.health_add)

        --          _knightPrint("attack +" .. record_sanguozhi_info.attack_add)

        --          _knightPrint("phyDefenseAdd +" .. record_sanguozhi_info.physical_defence_add)

        --          _knightPrint("magicDefenseAdd +" .. record_sanguozhi_info.magical_defence_add)

        --      end
        --     end   
        -- end


        
        _knightPrint("====== 强化大师======")
        require("app.cfg.team_target_info")
        --装备强化
        local function addTeamTargetInfo(record) 
            for i=1,4 do 
                local typeKey = "att_type_" ..i 
                local valueKey = "att_value_" .. i 
                if record[valueKey] > 0 then
                    addValue({type = record[typeKey] , value=record[valueKey] })
                end
               
            end
        end
        local _, lastTaretLevel, _ = G_Me.formationData:getKnightEquipTarget(true, slot)

        if lastTaretLevel >0 then
            --有装备强化加成
            local record = team_target_info.get(1, lastTaretLevel)
            if record then

                addTeamTargetInfo(record)
            end
        end

        local _, lastTaretLevelRefine, _ = G_Me.formationData:getKnightEquipTarget(false, slot)

        if lastTaretLevelRefine >0 then
            --有装备精炼加成
            local record = team_target_info.get(3, lastTaretLevelRefine)
            if record then

                addTeamTargetInfo(record)
            end
        end


        local _, lastTaretLevelTreasure, _ = G_Me.formationData:getKnightTreasureTarget(true, slot)

        if lastTaretLevelTreasure >0 then
            --有宝物强化加成
            local record = team_target_info.get(2, lastTaretLevelTreasure)
            if record then
                addTeamTargetInfo(record)
            end
        end

        local _, lastTaretLevelTreasureRefine, _ = G_Me.formationData:getKnightTreasureTarget(false, slot)

        if lastTaretLevelTreasureRefine >0 then
            --有宝物精炼加成
            local record = team_target_info.get(4, lastTaretLevelTreasureRefine)
            if record then

                addTeamTargetInfo(record)
            end
        end


        --三国志点星,加成
        local list = G_Me.sanguozhiData:getAttrList()
        if list ~= nil then
            for type,value in pairs(list) do
                addValue({type = type, value=value})
            end
        end



        --光环加成
        _knightPrint("======光环加成======")

        local halo_level_record = knight_halo_info.get(knightInfo.halo_level)
        hpRate = hpRate + halo_level_record.health_add/10
        if damage_type == 1 then
            phyAttackRate = phyAttackRate + halo_level_record.attack_add/10
            _knightPrint("phyAttackRate +" .. halo_level_record.attack_add)

        else
            magicAttackRate = magicAttackRate + halo_level_record.attack_add/10
            _knightPrint("magicAttackRate +" .. halo_level_record.attack_add)

        end
        phyDefenseRate = phyDefenseRate + halo_level_record.phy_defence_add/10
        magicDefenseRate = magicDefenseRate + halo_level_record.magic_defence_add/10
        
        _knightPrint("phyDefenseRate + " .. halo_level_record.phy_defence_add)
        _knightPrint("magicDefenseRate + " .. halo_level_record.magic_defence_add)



        --羁绊关系
        _knightPrint("======羁绊加成======")
        local jibans = knightInfo.association
        local function addJibanAttr(type, value)
            if type == 0 then
                return
            end
            _knightPrint("jiban, type="  .. type .. ",value=" .. value)

            -- 1. 生命
            -- 2. 物攻and物攻
            -- 3. 物防and魔防
            if type == 1 then
                hpRate = hpRate + value/10
            elseif type == 2 then
                if damage_type == 1 then
                    phyAttackRate = phyAttackRate + value/10
                else
                    magicAttackRate = magicAttackRate + value/10
                end
            elseif type == 3 then
                phyDefenseRate = phyDefenseRate + value/10
          
                magicDefenseRate = magicDefenseRate + value/10
            end

        end
        if #jibans > 0 then
            for i,aid in ipairs(jibans) do 
                local jiban_record = association_info.get(aid)
                if jiban_record then 
                --狗日的紫夜, 这个地方 type又自己定义了一套,我再给TMD映射回来
                    addJibanAttr(jiban_record.type_1, jiban_record.value_1)
                    addJibanAttr(jiban_record.type_2, jiban_record.value_2)
                else
                    __LogError("wrong jiban for aid:%d", aid or 0)
                end

            end

            
        end

        _knightPrint("======小伙伴护佑加成======")
        local _, friendTargetStrengthLevel, _ = G_Me.formationData:getKnightFriendTarget(1)
        if G_moduleUnlock:isModuleUnlock(require("app.const.FunctionLevelConst").KNIGHT_FRIEND_ZHUWEI) and friendTargetStrengthLevel > 0 then
            local friendTargetStrengthInfo = team_target_info.get(5, friendTargetStrengthLevel)
            for i = 1 , 4 do 
                if friendTargetStrengthInfo["att_type_"..i] > 0 then
                    addValue({type=friendTargetStrengthInfo["att_type_"..i], value=friendTargetStrengthInfo["att_value_"..i]})
                end
            end
        end

        local knightPassiveSkillAdd = function ( skill )
                 if skill.affect_type ==7 then
                     _knightPrint("加成: " .. tostring(skill.directions))

                     --攻击千分比
                     if damage_type == 1 then
                         phyAttackRate = phyAttackRate + skill.affect_value/10

                     else
                         magicAttackRate = magicAttackRate + skill.affect_value/10

                     end
                 elseif skill.affect_type ==17 then
                     _knightPrint("加成: " .. tostring(skill.directions))

                     --生命绝对值   
                     hpAdd = hpAdd + skill.affect_value
                 elseif skill.affect_type ==16  then
                     _knightPrint("加成: " .. tostring(skill.directions))

                     --攻击绝对值
                     if damage_type == 1 then
                         phyAttackAdd = phyAttackAdd +  skill.affect_value
                     else
                         magicAttackAdd = magicAttackAdd +  skill.affect_value
                     end
                 elseif skill.affect_type ==9 then
                     _knightPrint("加成: " .. tostring(skill.directions))
                     --print(knightBaseInfo.group .. ",".. skill.affect_target .. "," .. skill.id )
                     --生命千分比
                     hpRate = hpRate + skill.affect_value/10
                 elseif skill.affect_type ==8 then
                     _knightPrint("加成: " .. tostring(skill.directions))
                     --防御千分比
                     phyDefenseRate = phyDefenseRate +skill.affect_value/10
                     magicDefenseRate = magicDefenseRate + skill.affect_value/10
                 elseif skill.affect_type == 18 then
                     -- 防御加成
                     phyDefenseAdd = phyDefenseAdd + skill.affect_value
                     magicDefenseAdd = magicDefenseAdd + skill.affect_value
                 elseif skill.affect_type == 19 then
                     -- 攻击 物防 魔防 生命 同时增加千分比
                     if damage_type == 1 then
                         phyAttackRate = phyAttackRate + skill.affect_value/10
                     else
                         magicAttackRate = magicAttackRate + skill.affect_value/10
                     end
                     hpRate = hpRate + skill.affect_value/10
                     phyDefenseRate = phyDefenseRate + skill.affect_value/10
                     magicDefenseRate = magicDefenseRate + skill.affect_value/10
                 end
        end

        _knightPrint("被动属性加成.." .. tostring(knightBaseInfo.name))
        local function getPassiveAdd(theKnightInfo)
            local passive_skills = theKnightInfo.passive_skill

            if passive_skills and #passive_skills > 0 then
                for i, skill_id in ipairs(passive_skills) do 
                    local skill = passive_skill_info.get(skill_id)   
                    if  skill then   
                        local hasEffect = false
                        if (skill.affect_target == 1 and theKnightInfo.id == knightId) or (skill.affect_target == 2) then
                            hasEffect = true 
                        elseif skill.affect_target == 3 or  skill.affect_target == 4 or  skill.affect_target == 5 or  skill.affect_target == 6 then
                            --3 对应group 1, 4 对应group2, ...
                            if knightBaseInfo.group == skill.affect_target - 2 then
                                hasEffect = true 
                            end
                        end    

                        if hasEffect then
                            knightPassiveSkillAdd(skill)
                        end  

                    else
                        __LogError("Wrong skill info for passive_skills id=:%d", skill_id)
                    end
                end
                
            end
        end
        getPassiveAdd(knightInfo)


        _knightPrint("队友的被动属性加成.." )


        local knightsId = G_Me.formationData:getFirstTeamKnightIds()
        for i, kid in ipairs(knightsId) do 
            if kid > 0 and kid ~= knightId then
                local knight = self:getKnightByKnightId(kid)
                if knight then
                    getPassiveAdd(knight)
                end
            end
        end

        --如果是主角，需要判断时装
        local attrs, totalAttrs = G_Me.dressData:getAttrs()

        if baseId == self._mainKnightBaseId then
            for k,v in pairs(attrs) do 
                addValue({ type=k , value = v})
            end        
        end

        for k,v in pairs(totalAttrs) do 
            addValue({ type=k , value = v})
        end

        --宠物图鉴加成
        local attrs = G_Me.bagData.petData:getComposeAttr()

        for k,v in pairs(attrs) do
            addValue({ type=k , value = v})
        end

        --军团科技加成
        local techData = G_Me.legionData:getTechAdd()
        for k,v in pairs(techData) do
            addValue({ type=k , value = v})
        end

        -- 战宠护佑加成
        local petProtectId = G_Me.formationData:getProtectPetIdByPos(slot)
        if petProtectId > 0 then
            local petInfo = G_Me.bagData.petData:getPetById(petProtectId)
            local petBaseInfo = pet_info.get(petInfo.base_id)
            if petInfo and petBaseInfo then
                local nAttack, nHp, nPhyDef, nMagDef = G_Me.bagData.petData:getBaseAttr(petInfo.level, petInfo.base_id, petInfo.addition_lvl)
                local function calcAttr(attr)
                    return math.floor(attr * petBaseInfo.protect_account / 1000 )
                end
                addValue({type = AttributesConst.ATTRIBUTE_TYPE.ATTRIBUTE_GONGJI, value = calcAttr(nAttack)})
                addValue({type = AttributesConst.ATTRIBUTE_TYPE.ATTRIBUTE_SHENGMING, value = calcAttr(nHp)})
                addValue({type = AttributesConst.ATTRIBUTE_TYPE.ATTRIBUTE_WUFANG, value = calcAttr(nPhyDef)})
                addValue({type = AttributesConst.ATTRIBUTE_TYPE.ATTRIBUTE_MOFANG, value = calcAttr(nMagDef)})
            end
        end

        --武将化神加成
        _knightPrint("化神属性加成.." )
        local godInfo
        if knightInfo.pulse_level == 0 then
            if knightBaseInfo.god_pre_id > 0 then
                local preKnightBaseInfo = knight_info.get(knightBaseInfo.god_pre_id)
                if preKnightBaseInfo.god_add_id > 0 then
                    godInfo = knight_god_info.get(preKnightBaseInfo.god_add_id, KnightConst.KNIGHT_GOD_ZHENGJIE - 1)
                end
            end
        else
            godInfo = knight_god_info.get(knightBaseInfo.god_add_id, knightInfo.pulse_level)
        end

        if godInfo then
            addValue({type = AttributesConst.ATTRIBUTE_TYPE.ATTRIBUTE_GONGJI, value = godInfo.pulse_att})
            addValue({type = AttributesConst.ATTRIBUTE_TYPE.ATTRIBUTE_SHENGMING, value = godInfo.pulse_hp})
            addValue({type = AttributesConst.ATTRIBUTE_TYPE.ATTRIBUTE_WUFANG, value = godInfo.pulse_phy_def})
            addValue({type = AttributesConst.ATTRIBUTE_TYPE.ATTRIBUTE_MOFANG, value = godInfo.pulse_mag_def})

        end


        --技能加成
        local function getPassiveSkillAdd(passive_skills,kid)
            if passive_skills and #passive_skills > 0 then
                for i, skill_id in ipairs(passive_skills) do 
                    local skill = passive_skill_info.get(skill_id)   
                    if  skill then   
                        local hasEffect = false
                        if (skill.affect_target == 1 and kid == knightId) or (skill.affect_target == 2) then
                            hasEffect = true 
                        elseif skill.affect_target == 3 or  skill.affect_target == 4 or  skill.affect_target == 5 or  skill.affect_target == 6 then
                            --3 对应group 1, 4 对应group2, ...
                            if knightBaseInfo.group == skill.affect_target - 2 then
                                hasEffect = true 
                            end
                        end    

                        if hasEffect then
                            knightPassiveSkillAdd(skill)
                        end

                    else
                        __LogError("Wrong skill info for passive_skills id=:%d", skill_id)
                    end
                end
                
            end
        end
        --时装技能加成
        local attrs = G_Me.dressData:getDressSkill()
        getPassiveSkillAdd(attrs,self._mainKnightId)

        --战宠加成并不需要显示
        -- --战宠加成
        -- for index = 1 , 6 do
        --     local formationIndex, _ = G_Me.formationData:getFormationIndexAndKnighId(team,index)
        --     if slot == formationIndex then
        --         local petAddData = G_Me.bagData.petData:getAddAttrOnKnight(index)
        --         if petAddData then
        --             knightPassiveSkillAdd(petAddData)
        --         end
        --     end
        -- end

        -- 称号加成
        if baseId == self._mainKnightBaseId then
            local titleId = G_Me.userData.title_id
            if titleId > 0 and (not G_Me.bagData:isTitleOutOfDate(titleId)) then
                require("app.cfg.title_info")
                local titleInfo = title_info.get(titleId)

                local strengthType1 = titleInfo.strength_type_1
                local strengthValue1 = titleInfo.strength_value_1

                local strengthType2 = titleInfo.strength_type_2
                local strengthValue2 = titleInfo.strength_value_2

                if strengthType1 > 0 and strengthValue1 > 0 then
                    addValue({ type=strengthType1 , value = strengthValue1})
                end
                if strengthType2 > 0 and strengthValue2 > 0 then
                    addValue({ type=strengthType2 , value = strengthValue2}) 
                end
                
            end
        end

    end
    
    -- 觉醒相关
    -- 觉醒等级加成
    if knightInfo.awaken_level > 0 then
        
        local awakenKnightInfo = knight_awaken_info.get(knightBaseInfo.awaken_code, knightInfo.awaken_level)
        assert(awakenKnightInfo, "Could not find the knight awaken info with awakenCode and awakenLevel: "..knightBaseInfo.awaken_code..", "..knightInfo.awaken_level)
        
        -- 4种属性加成
        for i=1, 4 do
            addValue {type=awakenKnightInfo["strength_type_"..i], value=awakenKnightInfo["strength_value_"..i]}
        end
    end
    
    -- 觉醒装备加成
    for i=1, #knightInfo.awaken_items do
        local itemId = knightInfo.awaken_items[i]
        if itemId ~= 0 then
            
            local itemInfo = item_awaken_info.get(itemId)
            assert(itemInfo, "Could not find the item awaken info with id: "..tostring(itemId))
            
            local MergeEquipment = require "app.data.MergeEquipment"
            for i=1, 3 do
                if itemInfo["str_type_"..i] ~= 0 then
                    addValue{type = itemInfo["str_type_"..i], value = itemInfo["str_value_"..i]}
                end
            end
        end
    end
    
    -- 觉醒天赋解锁
    if knightInfo.awaken_level > 0 and knightInfo.awaken_level >= 10 then
        
        local awakenKnightInfo = knight_awaken_info.get(knightBaseInfo.awaken_code, knightInfo.awaken_level - knightInfo.awaken_level % 10)
        assert(awakenKnightInfo, "Could not find the knight awaken info with awakenCode and awakenLevel: "..knightBaseInfo.awaken_code..", "..knightInfo.awaken_level)
        
        local passiveSkillInfo = passive_skill_info.get(awakenKnightInfo.ability_id)
        assert(passiveSkillInfo, "Could not find the passiveSkillInfo with id: "..awakenKnightInfo.ability_id)
        
        if passiveSkillInfo.affect_type == 19 then
            -- 攻击、防御、生命最大值各增加x%
            -- 物防 and 魔防
            addValue {type = AttributesConst.ATTRIBUTE_TYPE.ATTRIBUTE_WUFANG_P, value = passiveSkillInfo.affect_value}
            addValue {type = AttributesConst.ATTRIBUTE_TYPE.ATTRIBUTE_MOFANG_P, value = passiveSkillInfo.affect_value}
            -- 物攻 or 魔攻
            addValue {type = AttributesConst.ATTRIBUTE_TYPE.ATTRIBUTE_GONGJI_P, value = passiveSkillInfo.affect_value}
            -- 生命
            addValue {type = AttributesConst.ATTRIBUTE_TYPE.ATTRIBUTE_SHENGMING_P, value = passiveSkillInfo.affect_value}
        end 
    end
    
    _knightPrint("最后总的加成..")
    _knightPrint("hp=" .. hp .. "+" ..hpAdd .. ", * 百分比 100 + " .. hpRate)
    _knightPrint("phyAttack=" .. phyAttack .. "+" ..phyAttackAdd .. ", * 百分比 100 + " .. phyAttackRate)
    _knightPrint("magicAttack=" .. magicAttack .. "+" ..magicAttackAdd .. ", * 百分比 100 + " .. magicAttackRate)
    _knightPrint("phyDefense=" .. phyDefense .. "+" ..phyDefenseAdd .. ", * 百分比 100 + " .. phyDefenseRate)
    _knightPrint("magicDefense=" .. magicDefense .. "+" ..magicDefenseAdd .. ", * 百分比 100 + " .. magicDefenseRate)



    local attack = 0
    if damage_type == 1 then
        attack = math.floor( (phyAttack + phyAttackAdd)*(1+phyAttackRate/100) )
    else
        attack = math.floor( (magicAttack + magicAttackAdd)*(1+magicAttackRate/100) )
    end

    local result= {
        hp = math.floor( (hp + hpAdd)*(1+hpRate/100) ),
        attack = attack,
        phyDefense = math.floor( (phyDefense + phyDefenseAdd)*(1+phyDefenseRate/100) ),
        magicDefense = math.floor( (magicDefense + magicDefenseAdd)*(1+magicDefenseRate/100) ),
    }
    --dump(result)
    return result
end

function KnightsData:getKnightAttr1( knightId )
    local knightInfo = self:getKnightByKnightId(knightId)
    return self:getKnightAttr1ByKnight(knightInfo)
end

-- 觉醒相关
function KnightsData:isKnightAwakenValid( knightId )
    
    local knightInfo = self:getKnightByKnightId(knightId)
    
    local knightConfig = knight_info.get(knightInfo.base_id)
    assert(knightConfig, "Could not find the knight with base_id: "..tostring(knightInfo.base_id))
    
    local FunctionLevelConst = require "app.const.FunctionLevelConst"
    local awakenUnlock = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.AWAKEN)
    
    local awakenKnightLevelValid = G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.AWAKEN) <= knightInfo.level
    
    local awakenQualityLimit = (knightConfig.potential >= 20) or knightInfo.id == G_Me.formationData:getMainKnightId()
    
    local awakenLevel = knightInfo.awaken_level
    if awakenLevel ~= 0 then
        local awakenKnightInfo = knight_awaken_info.get(knightConfig.awaken_code, awakenLevel)
        assert(awakenKnightInfo, "Could not find the awakenKnightInfo with awakenCode and awakenLevel: "..knightConfig.awaken_code..", "..awakenLevel)
    end
    
    local noAwakenMaxLevel = awakenLevel == 0 and true or knight_awaken_info.get(knightConfig.awaken_code, awakenLevel).next_awaken_id ~= 0
    
    -- 依次是功能解锁，品质为橙色或红色或主角，角色等级达到，角色觉醒未满级
    return awakenUnlock, awakenQualityLimit, awakenKnightLevelValid, noAwakenMaxLevel
    
end

function KnightsData:isEquippedAwakenItem(knightId, itemId, posId)
    
    local knightInfo = self:getKnightByKnightId(knightId)
    
    local awakenItems = rawget(knightInfo, "awaken_items") or {}
    
    if awakenItems[posId] == itemId then
        return true
    end

    return false

end

function KnightsData:isFullEquippedAwakenItem(knightId)
    
    local knightInfo = self:getKnightByKnightId(knightId)
    
    local cardConfig = knight_info.get(knightInfo.base_id)
    assert(cardConfig, "Could not find the card config with id:"..knightInfo.base_id)
    
    local awakenKnightInfo = knight_awaken_info.get(cardConfig.awaken_code, knightInfo.awaken_level)
    assert(awakenKnightInfo, "Could not find the awakenKnightInfo with awaken_code and awakenLevel: "..cardConfig.awaken_code..", "..knightInfo.awaken_level)
    
    local awakenItems = rawget(knightInfo, "awaken_items") or {}
    
    local count = 0
    for i=1, #awakenItems do
        if awakenItems[i] ~= 0 then
            count = count + 1
        end
    end
    
    return count == awakenKnightInfo.item_num
end

-- 获取当前武将获取的觉醒等级，正常级别从0~3，如果-1表示不能觉醒或者不显示星星的武将，总之-1就是不显示星星
function KnightsData:getKnightAwakenLevelByKnightId(knightId)
    local knightInfo = self:getKnightByKnightId(knightId)
    if not knightInfo then 
        return 0
    end
    --assert(knightInfo, "Could not find the knightInfo with knightId: "..knightId)
    
    local FunctionLevelConst = require "app.const.FunctionLevelConst"
    if not G_moduleUnlock:isModuleUnlock(FunctionLevelConst.AWAKEN)                         -- 觉醒功能未开启
        or (knight_info.get(knightInfo.base_id).potential < 20 and knightInfo.id ~= G_Me.formationData:getMainKnightId())  -- 武将品质不是橙色及以上且不是主角
        or knightInfo.level < G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.AWAKEN) -- 当前武将的等级没有到觉醒开启等级
        then
        return -1
    end
    
    return math.floor(knightInfo.awaken_level / 10)
    
end

-- 获取当前武将觉醒的天赋
-- 返回参数格式
--[[
    {
        1 = {
            isActivated = false     -- 是否激活
            talentTitle = "xxx"     -- 天赋名
            talentDesc = "xxx"      -- 天赋文本内容
        },
        2 = {
            isActivated = false
            talentTitle = "xxx"
            talentDesc = "xxx"
        },
        ...
    }
]]
function KnightsData:getKnightAwakenTalent(knightId)
    
    local knightInfo = self:getKnightByKnightId(knightId)
    assert(knightInfo, "Could not find the knightInfo with knightId: "..knightId)
    
    local _t = {container = {}}
    _t.add = function(_isActivated, _talentTitle, _talentDesc)
        _t.container[#_t.container+1] = {isActivated = _isActivated, talentTitle = _talentTitle, talentDesc = _talentDesc}
    end
    
    _t.pack = function()
        return clone(_t.container)
    end
    
    -- 最多六星  2.0.50版本临时改成5星
    for i=1, 5 do
        local isActivated = knightInfo.awaken_level >= i*10

        local knightConfig = knight_info.get(knightInfo.base_id)
        assert(knightConfig, "Could not find the knight config with id: "..knightInfo.base_id)

        local awakenKnightInfo = knight_awaken_info.get(knightConfig.awaken_code, i*10)
        assert(awakenKnightInfo, "Could not find the awaken knight config with awaken_code and awaken_level: "..knightConfig.awaken_code..","..knightInfo.awaken_level)

        local passiveSkillInfo = passive_skill_info.get(awakenKnightInfo.ability_id)
        assert(passiveSkillInfo, "Could not find the passiveSkillInfo with id: "..awakenKnightInfo.ability_id)

        _t.add(isActivated, passiveSkillInfo.name, passiveSkillInfo.directions)

    end
    
    return _t.pack()
    
end

-- 是否有足够材料觉醒
function KnightsData:hasEnoughAwakenMaterial(knightId)
    
    -- 先检查武将是否有效
    if self:getKnightAwakenLevelByKnightId(knightId) == -1 then
        return false
    end
    
    local knightInfo = self:getKnightByKnightId(knightId)
    assert(knightInfo, "Could not find the knightInfo with knightId: "..knightId)

    local cardConfig = knight_info.get(knightInfo.base_id)
    assert(cardConfig, "Could not find the card config with id:"..knightInfo.base_id)
    
    local awakenKnightInfo = knight_awaken_info.get(cardConfig.awaken_code, knightInfo.awaken_level)
    assert(awakenKnightInfo, "Could not find the awakenKnightInfo with awaken_code and awakenLevel: "..cardConfig.awaken_code..", "..knightInfo.awaken_level)
    
    local enoughMaterial = true
    
    for index=1, 2 do
    
        local _type = awakenKnightInfo["cost_"..index.."_type"]
        
        if _type ~= 0 then
            
            if _type == 1 then
                _type = G_Goods.TYPE_KNIGHT
            elseif _type == 2 then
                _type = G_Goods.TYPE_ITEM
            end
            
            local _value = awakenKnightInfo["cost_"..index.."_value"]
            local _size = awakenKnightInfo["cost_"..index.."_size"]

            if _type == G_Goods.TYPE_KNIGHT then    
                local costKnightList = G_Me.bagData.knightsData:getCostKnight(_value, {[self._mainKnightId]=1})
                local knightNums = #costKnightList
                local expectNums = _size

                enoughMaterial = enoughMaterial and knightNums >= expectNums
                
            elseif _type == G_Goods.TYPE_ITEM then
                local itemNums = G_Me.bagData:getPropCount(_value)
                local expectNums = _size

                enoughMaterial = enoughMaterial and itemNums >= expectNums
                
            end
            
        end
    end
    
    return enoughMaterial
    
end

-- 检查当前武将是否有觉醒装备可以装备，或者可以觉醒了，这里函数名并没有修改
-- 返回true表示可以，false表示不可以
function KnightsData:hasAwakenEquipmentToEquip(knightId)
    
    -- 先检查武将是否有效
    if self:getKnightAwakenLevelByKnightId(knightId) == -1 then
        return false
    end
    
    local knightInfo = self:getKnightByKnightId(knightId)
    assert(knightInfo, "Could not find the knightInfo with knightId: "..knightId)

    local cardConfig = knight_info.get(knightInfo.base_id)
    assert(cardConfig, "Could not find the card config with id:"..knightInfo.base_id)
    
    local awakenKnightInfo = knight_awaken_info.get(cardConfig.awaken_code, knightInfo.awaken_level)
    assert(awakenKnightInfo, "Could not find the awakenKnightInfo with awaken_code and awakenLevel: "..cardConfig.awaken_code..", "..knightInfo.awaken_level)
    
    local canBeEquipped = false
    
    for i=1, 4 do
        local itemId = awakenKnightInfo["item_id_"..i]
        if itemId ~= 0 then
            -- 是否可装备且当前未被装备
            canBeEquipped = canBeEquipped or (G_Me.bagData:containAwakenItem(itemId) and not self:isEquippedAwakenItem(knightId, itemId, i))
        end
    end
    
    -- 觉醒等级是否满足
    local enoughLevel = knightInfo.level >= awakenKnightInfo.level_ban
    
    -- 是否穿齐装备
    local beEquippedFull = self:isFullEquippedAwakenItem(knightId)
    
    -- 是否满足材料
    local enoughMaterial = self:hasEnoughAwakenMaterial(knightId)
    
    -- 更新觉醒花费，返回是否足够
    local enoughMoney = G_Me.userData.money >= awakenKnightInfo.money_cost
    
    return canBeEquipped or (enoughLevel and beEquippedFull and enoughMaterial and enoughMoney)
    
end

-- 武将化神相关

-- 功能是否开启
-- return : 1. bool 是否开启 2. number 未开启type(1等级不足，2突破等级不足 3参数武将id错误 4没找到武将信息) 3 .string 开启提示字符串
KnightsData.GOD_PINZHI_NOT_ENOUGH = 1 -- 品质不足
KnightsData.GOD_LEVEL_NOT_ENOUGH = 2 -- 等级不足
KnightsData.GOD_ADVANCED_LEVEL_NOT_ENOUGH = 3 -- 突破等级不足
KnightsData.GOD_OPENING_SOON = 4 -- 敬请期待
KnightsData.GOD_MAX_LEVEL = 5 -- 满级
function KnightsData:isGodOpen(knightId)
    
    local funLevelConst = require("app.const.FunctionLevelConst")
    local moduleUnlock = G_moduleUnlock:isModuleUnlock(funLevelConst.KNIGHT_GOD)

    if not knightId then
        return false, 0
    end 

    local knightInfo = self:getKnightByKnightId(knightId)
    if not knightInfo then
        return false, 0
    end

    local knightBaseInfo = knight_info.get(knightInfo.base_id)
    if not knightBaseInfo then
        return false, 0
    end

    if knightId == G_Me.formationData:getMainKnightId() then 
        -- if knightBaseInfo.potential < KnightConst.KNIGHT_GOD_MAIN_POTENTIAL then
        --     return false, KnightsData.GOD_PINZHI_NOT_ENOUGH
        -- end
        return false, KnightsData.GOD_OPENING_SOON
    elseif knightBaseInfo.potential < KnightConst.KNIGHT_GOD_POTENTIAL then
        return false, KnightsData.GOD_PINZHI_NOT_ENOUGH 
    end

    if not moduleUnlock then
        local funLevelInfo = function_level_info.get(funLevelConst.KNIGHT_GOD)
        local text = funLevelInfo and funLevelInfo.comment or "Un-locked!"
        return false, KnightsData.GOD_LEVEL_NOT_ENOUGH, text
    end

    if knightBaseInfo.advanced_level < 8 then
        return false, KnightsData.GOD_ADVANCED_LEVEL_NOT_ENOUGH 
    end

    if self:isMaxGodLevel(knightId) then
        return false, KnightsData.GOD_MAX_LEVEL
    end

    return true
end

function KnightsData:getGodLevelByBaseInfo(knightBaseInfo, pulse_level)

    if not knightBaseInfo then
        __LogError("KnightsData:getGodLevelByBaseInfo() knightBaseInfo is nil")
        return 0
    end

    -- 一个大阶有4个小阶,橙将有六个大阶，红将有三个大阶
    local godLevel = ( (knightBaseInfo.god_level % 3) * KnightConst.KNIGHT_GOD_ZHENGJIE) +pulse_level

    if knightBaseInfo.god_level == 3 and knightBaseInfo.god_id == 0 then
        godLevel = KnightConst.KNIGHT_GOD_RED_MAX_LEVEL
    end
    if knightBaseInfo.god_level == 6 and knightBaseInfo.god_id == 0 then
        godLevel = KnightConst.KNIGHT_GOD_RED_MAX_LEVEL
    end

    return godLevel
end

function KnightsData:getGodLevel(knightId)

    if not knightId then
        return 0
    end 

    local knightInfo = self:getKnightByKnightId(knightId)
    if not knightInfo then
        return 0
    end

    local knightBaseInfo = knight_info.get(knightInfo.base_id)
    if not knightBaseInfo then
        return 0
    end

    return self:getGodLevelByBaseInfo(knightBaseInfo, knightInfo.pulse_level)
end

function KnightsData:getNextGodLevel(knightId)
    if not knightId then
        return 0
    end 

    local knightInfo = self:getKnightByKnightId(knightId)
    if not knightInfo then
        return 0
    end

    local knightBaseInfo = knight_info.get(knightInfo.base_id)
    if not knightBaseInfo then
        return 0
    end

    -- 一个大阶有三个小阶
    local nowLevel = ((knightBaseInfo.god_level % 3) * 5) + knightInfo.pulse_level
    -- 橙色武将的最大等级是18级
    local maxLevel = knightBaseInfo.potential >= KnightConst.KNIGHT_GOD_RED_POTENTIAL 
    and KnightConst.KNIGHT_GOD_RED_MAX_LEVEL 
    or KnightConst.KNIGHT_GOD_CHENG_MAX_LEVEL

    local nextLevel = nowLevel < maxLevel and nowLevel + 1 or maxLevel

    if knightBaseInfo.god_level == 3 and knightBaseInfo.god_id == 0 then
        nextLevel = KnightConst.KNIGHT_GOD_RED_MAX_LEVEL
    end
    if knightBaseInfo.god_level == 6 and knightBaseInfo.god_id == 0 then
        nextLevel = KnightConst.KNIGHT_GOD_RED_MAX_LEVEL
    end
    return nextLevel
end

function KnightsData:isMaxGodLevel(knightId)
    local nowLevel = self:getGodLevel(knightId)
    local nextLevel = self:getNextGodLevel(knightId)

    if nowLevel == nextLevel then
        return true
    end
    return false
end

-- 化神的加成属性
function KnightsData:_getGodAttrsTablesGodInfo(knightBaseInfo, pulseLevel)

    if pulseLevel ~= 0 then

        local knightGodInfo = knight_god_info.get(knightBaseInfo.god_add_id, pulseLevel)
        if knightGodInfo then
            return {
                knightGodInfo.pulse_att,
                knightGodInfo.pulse_hp,
                knightGodInfo.pulse_phy_def,
                knightGodInfo.pulse_mag_def,
            }
        end
    else
        return {0,0,0,0}
    end
end

-- 属性
function KnightsData:getGodAttrsTablesInfo(knightBaseInfo, level, pulseLevel, knightBaseInfo2, pulseLevel2)

    if not knightBaseInfo then
        __LogError("knightBaseInfo is nil")
        return nil
    end

    -- if not knightBaseInfo2 then
    --  __LogError("knightBaseInfo2 is nil")
    -- end
    local attrsTablesGodInfo

    if pulseLevel ~= 0 then
        attrsTablesGodInfo= self:_getGodAttrsTablesGodInfo(knightBaseInfo, pulseLevel)
    elseif knightBaseInfo.god_pre_id > 0 then
        
        local preKnightBaseInfo = knight_info.get(knightBaseInfo.god_pre_id)
        attrsTablesGodInfo = self:_getGodAttrsTablesGodInfo(preKnightBaseInfo, KnightConst.KNIGHT_GOD_ZHENGJIE - 1)
    end
     
    if knightBaseInfo2 then
        attrsTablesGodInfo = self:_getGodAttrsTablesGodInfo(knightBaseInfo2, pulseLevel2)
    end

    if not attrsTablesGodInfo then 
        attrsTablesGodInfo = {0, 0, 0, 0}
    end

    -- 减去0阶的属性
    local zeroBaseInfo = knightBaseInfo
    for i = 1, KnightConst.KNIGHT_GOD_MAX_LEVEL * 2 do
        if zeroBaseInfo.god_level ~= 0 then
            zeroBaseInfo = knight_info.get(zeroBaseInfo.god_pre_id)
        end
    end

    return {
        G_Me.bagData.knightsData:calcAttackByBaseId(knightBaseInfo.id, level) + attrsTablesGodInfo[1] 
        - G_Me.bagData.knightsData:calcAttackByBaseId(zeroBaseInfo.id, level),

        knightBaseInfo.base_hp + (level - 1)*knightBaseInfo.develop_hp + attrsTablesGodInfo[2] 
        - (zeroBaseInfo.base_hp + (level - 1)*zeroBaseInfo.develop_hp),

        knightBaseInfo.base_physical_defence + (level - 1)*knightBaseInfo.develop_physical_defence + attrsTablesGodInfo[3] 
        - (zeroBaseInfo.base_physical_defence + (level - 1)*zeroBaseInfo.develop_physical_defence),
        
        knightBaseInfo.base_magical_defence + (level - 1)*knightBaseInfo.develop_magical_defence + attrsTablesGodInfo[4] 
        - (zeroBaseInfo.base_magical_defence + (level - 1)*zeroBaseInfo.develop_magical_defence),
    }
end

-- return {攻击，生命，物防，法防}
function KnightsData:getGodAttrs(knightId)
    
    if not knightId then
        __LogError("KnightsData:getGodAttrs() knightId is nil")
        return
    end 

    local knightInfo = self:getKnightByKnightId(knightId)
    if not knightInfo then
        __LogError("KnightsData:getGodAttrs() knightInfo is nil, knightId = " .. knightId)
        return
    end

    local knightBaseInfo = knight_info.get(knightInfo.base_id)
    if not knightBaseInfo then
        __LogError("KnightsData:getGodAttrs() knightBaseInfo is nil, knightBaseId = " .. knightInfo.base_id)
        return
    end

    return self:getGodAttrsTablesInfo(knightBaseInfo, knightInfo.level, knightInfo.pulse_level)

end

return KnightsData

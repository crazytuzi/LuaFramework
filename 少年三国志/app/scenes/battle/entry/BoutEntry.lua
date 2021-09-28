-- BoutEntry

require "app.cfg.knight_info"
require "app.cfg.monster_info"

local BattleFieldConst = require "app.scenes.battle.BattleFieldConst"
local LocationFactory = require "app.scenes.battle.Location"
local PetSprite = require "app.scenes.battle.PetSprite"
local SpEntry = require "app.scenes.battle.entry.SpEntry"
local PetBuffShowEntry = require "app.scenes.battle.entry.PetBuffShowEntry"
local PetBuffEntry = require "app.scenes.battle.entry.PetBuffEntry"

local BoutEntry = class("BoutEntry", require "app.scenes.battle.entry.Entry")

function BoutEntry:ctor(data, objects, battleField, message, curWave, waveAmount, battleType)
        
    self._message = message
    self._curWave = curWave
    self._waveAmount = waveAmount
    self._battleType = battleType
    
    BoutEntry.super.ctor(self, data, objects, battleField)
end

function BoutEntry:initEntry()
    
    BoutEntry.super.initEntry(self)
    
    local bout = self._data
    local knights = self._objects
    local battleField = self._battleField
    local message = self._message
    local pets = self._battleField:getPets()
    
    -- 先创建角色（敌方）和战宠
    self:_loadEnemy(knights[2], bout.enemy_team+1)
    self:_loadPet(pets, true)
    self:_loadPet(pets, false)
    
    -- 插入一个出场动画
    -- 构建一个入口集合用来添加同一时间播放的多序列的entry
    local Entry = require "app.scenes.battle.entry.Entry"
    local ActionEntry = require "app.scenes.battle.entry.ActionEntry"
    
    local entrySet = Entry.new()
    for key, knight in pairs(knights[2]) do
        
        knight:setHPVisible(false)
        knight:setNameVisible(false)
        knight:setAwakenStarVisible(false)
        knight:setAngerVisible(false)
        
        if not knight.isBoss then
            -- 因为要做动画，所以先设置武将透明度为0
            knight:getCardBase():setOpacity(0)
            knight:getCardSprite():setOpacity(0)
            
            local appearEntry = ActionEntry.new(knight:getCardConfig().quality >= 4 and BattleFieldConst.action.CHAR_SHOW or BattleFieldConst.action.CHAR_SHOW_LOW, knight, battleField)
            -- 每一个entry添加到一个新的队列，目的是为了同步播放，而不是顺序播放。同时绑定一个key（knight）
            entrySet:addEntryToNewQueue(appearEntry, appearEntry.updateEntry, nil, knight)
        else
            -- 大boss则设为不可见
            knight:setVisible(false)
            local check = nil
            entrySet:addEntryToNewQueue(nil, function(_, frameIndex)
                if not check then
                    check = knight:playAppear()
                else
                    knight:setVisible(true)
                end
                return check(frameIndex)
            end, nil, knight)
        end

        -- 开始呼吸动作、显示血条以及怒气条等
        -- 在这个key(knight)的队尾增加显示血条的函数
        entrySet:addOnceEntryToQueue(nil, function()
            knight:setBreathAniEnabled(true)
            knight:setHPVisible(true)
            knight:setNameVisible(true)
            knight:setAwakenStarVisible(true)
            knight:setAngerVisible(true)
            return true
        end, nil, knight)
    end

    -- 音效
    entrySet:addEntryToNewQueue(nil, function()
        require("app.sound.SoundManager"):playSound(require("app.const.SoundConst").BattleSound.BATTLE_APPEAR)
        return true
    end)
    
    self:addEntryToQueue(entrySet, entrySet.updateEntry)
    
    -- 波数动画
    if self._waveAmount > 1 then
        local WaveEntry = require "app.scenes.battle.entry.WaveEntry"
        local waveEntry = WaveEntry.create(self._curWave, self._waveAmount, battleField)
        self:addEntryToQueue(waveEntry, waveEntry.updateEntry)
    end
    
    if self._battleType == battleField.ARENA_BATTLE then
        local VSEntry = require "app.scenes.battle.entry.VSEntry"
        
        local packVSInfo = {}
        packVSInfo.first = bout.rounds[1].attacks[1].identity
        
        packVSInfo.myself = packVSInfo.myself or {}
        local _, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, 1)
        packVSInfo.myself.id = baseId
        packVSInfo.myself.name = G_Me.userData.name
        packVSInfo.myself.power = G_Me.userData.fight_value
        packVSInfo.myself.dress_id = G_Me.dressData:getDressed() and G_Me.dressData:getDressed().base_id or 0   -- 这里的base_id就是dress_id
        packVSInfo.myself.clid = G_Me.userData:getClothId()
        packVSInfo.myself.cltm = G_Me.userData.cloth_time
        packVSInfo.myself.clop = G_Me.userData.cloth_open
        packVSInfo.enemy = battleField:getPackParams("enemy")
        for k, knight in pairs(battleField:getEnemyKnight()) do
            -- 更换敌方主角
            if knight:getCardConfig().id == packVSInfo.enemy.id then
                local units = self._message.enemy_teams[bout.enemy_team + 1].units
                for k2,enemy in pairs(units) do
                    -- 获取敌方主角的clid 
                    if enemy.clid and enemy.clid ~= 0 and G_Me.userData:checkCltm(enemy.cltm) and enemy.clop then 
                        packVSInfo.enemy.clid = enemy.clid
                        packVSInfo.enemy.cltm = enemy.cltm
                        packVSInfo.enemy.clop = enemy.clop
                    end 
                end
                packVSInfo.enemy.dress_id = knight:getCardConfig().dress_id
                break
            end
        end
        
        local vsEntry = VSEntry.create(packVSInfo, battleField)
        self:addEntryToQueue(vsEntry, vsEntry.updateEntry)
    end
    
    -- 战宠出场
    local petAppearEntry = nil
    for k, v in pairs(pets) do
        if not petAppearEntry then
            petAppearEntry = Entry.new()
        end

        -- 宠物光环-影子冒出&大字“宠物神炼加成”
        local showEntry = PetBuffShowEntry.new(v, nil, battleField)
        petAppearEntry:addEntryToQueue(showEntry, showEntry.updateEntry, nil, v)

        -- 宠物光环BUFF
        local petBuffSet = Entry.new()
        local units = {}
        local team = v._isHeroPet and 1 or 2
        if v._isHeroPet then 
            units = self._message.own_teams[bout.own_team + 1].units
        else
            units = self._message.enemy_teams[bout.enemy_team + 1].units
        end

        for i = 1, #units do
            local unit = units[i]
            local petHaloType = rawget(unit, "pet_halo_type")
            local petHaloValue = rawget(unit, "pet_halo_value")
            if petHaloType and petHaloValue and petHaloType > 0 and petHaloValue > 0 then
                local knight = knights[team][tostring(unit.position + 1)]

                -- buff effect
                local effectEntry = SpEntry.new({spId = "sp_zc_jiacheng"}, self, battleField)
                knight:addChild(effectEntry:getObject())
                petBuffSet:addEntryToQueue(effectEntry, effectEntry.updateEntry, nil, "buff_effect_" .. team .."_" .. i)

                -- buff number
                local petBuffEntry = PetBuffEntry.new(petHaloType, petHaloValue, nil, knight, battleField)
                petBuffSet:addEntryToNewQueue(petBuffEntry, petBuffEntry.updateEntry, nil, "buff_num_" .. team .. "_" .. i)
            end
        end

        -- 跳buff的同时，宠物虚影出现
        petBuffSet:addEntryToNewQueue(nil, function() v:playAppear() return true end)

        if petBuffSet then
            petAppearEntry:addEntryToQueue(petBuffSet, petBuffSet.updateEntry, nil, v)
        end
    end

    if petAppearEntry then
        self:addEntryToQueue(petAppearEntry, petAppearEntry.updateEntry)
    end

    local RoundEntry = require "app.scenes.battle.entry.RoundEntry"
    
    local roundIndex = 0
    local realRound = 0 -- 战宠回合不计入回合数显示,因此不能直接用roundIndex作回合数
    
    local function nextRound()
        -- 回合数递增
        roundIndex = roundIndex + 1
        local roundData = bout.rounds[roundIndex]

        -- 只有武将攻击回合才更新回合数，战宠回合不更新
        if roundData and roundData.type == BattleFieldConst.ROUND_NORMAL then
            realRound = realRound + 1
        end

        -- 更新回合数显示
        self:addOnceEntryToQueue(nil, function()
            if not self._roundLabel then
                
                self._roundLabel = display.newNode()
                battleField:addToDataNode(self._roundLabel)
                
                local label = Label:create()
                label:setFontName(G_Path.getBattleLabelFont())
                label:setFontSize(28)
                label:setColor(ccc3(0xfe, 0xf6, 0xd8))
                label:createStroke(Colors.strokeBlack, 1)
                label:setText(G_lang:get("LANG_BATTLEFIELD_ROUND", {curRound = realRound, roundAmount = 20}))
                
                self._roundLabel:addChild(label)
                
                label:setPosition(ccp(display.width-label:getContentSize().width/2-10, display.height-label:getContentSize().height/2-10))
                
                local roundName = Label:create()
                roundName:setFontName(G_Path.getBattleLabelFont())
                roundName:setFontSize(28)
                roundName:setColor(ccc3(0xf1, 0xdd, 0x90))
                roundName:createStroke(Colors.strokeBlack, 1)
                roundName:setText(G_lang:get("LANG_BATTLEFIELD_ROUND_NAME"))
                
                self._roundLabel:addChild(roundName)
                
                roundName:setPosition(ccpAdd(ccp(label:getPosition()), ccp(-0.5 * (label:getContentSize().width + roundName:getContentSize().width), 0)))
                
                self._roundLabel.setString = function(_, text)
                    label:setText(text)
                end
                
            else
                self._roundLabel:setString(G_lang:get("LANG_BATTLEFIELD_ROUND", {curRound = realRound, roundAmount = 20}))
            end
            
            return true
        end)
        
        -- 如果回合结束则直接返回true
        if not roundData then return true end
        -- 创建RoundEntry
        local round = RoundEntry.new(roundData, knights, battleField)   
        self:addEntryToQueue(round, round.updateEntry)
        
        -- 下一回合
        self:addOnceEntryToQueue(nil, nextRound)
        
        battleField:dispatchEvent(battleField.BATTLE_ROUND_UPDATE, realRound)
        
        return true
    end

    nextRound()
   
end

-- 载入敌人
function BoutEntry:_loadEnemy(knights, teamIndex)

    -- 获取战斗敌方英雄数据
    local datas = self._message.enemy_teams[teamIndex].units
    local name = rawget(self._message, "enemy_name")

    -- 绘制
    local EnemyCardSprite = require "app.scenes.battle.EnemyCardSprite"
    local BossCardSprite = require "app.scenes.battle.BossCardSprite"
    local battleType = self._battleField:getPackParams("battleType")
    
    for i=1, #datas do
        local data = datas[i]
        
        local anger = rawget(data, "anger") or 0

        local role_info = self._message.tp == 1 and knight_info or monster_info
        local card = role_info.get(data.id)
        assert(card, "Could not find the card with id: "..data.id)
        
        local cardSprite = nil
        local createCard = card.is_boss ~= "0" and BossCardSprite.new or EnemyCardSprite.new
        
        local hpTotal = data.hp
        if battleType == self._battleField.MOSHEN_BATTLE or
           battleType == self._battleField.REBEL_BOSS or
           battleType == self._battleField.CRUSADE_BATTLE then
            hpTotal = data.max_hp
        elseif battleType == self._battleField.LEGION_BATTLE then
            hpTotal = self._message.tp == 1 and card.base_hp or card.hp
        elseif battleType == self._battleField.LEGION_CROSS_BATTLE then
            hpTotal = data.hp -- 军团群英战的总hp只从服务器读
        end
        local clid = 0
        if rawget(data, "clid") and G_Me.userData:checkCltm(rawget(data, "cltm")) and rawget(data, "clop") then 
            clid = rawget(data, "clid")
        end
        -- 1表示是主角，如果主角有名字（服务器获取）则直接读取，否则读取本地数据缓存，data.name是unit中自己加的字段，主要是剧情战报（本地）自己更改的名字
        cardSprite = createCard(card, rawget(data, "name") or (card.type == 1 and (name or card.name) or card.name), data.hp, hpTotal, 2, data.position+1, anger, self._battleField, 
            rawget(data, "dress_id"), rawget(data, "awaken") or 0, clid, rawget(self._message, "enemy_fight_base") or 1)
        
        local position = LocationFactory.getEnemyPositionByIndex(data.position+1)
        cardSprite:setPositionXY(position[1], position[2])
        
        if card.is_boss == "0" then
            cardSprite:setScale(LocationFactory.getScaleByPosition(position))
        end

        -- 存储敌人，根据位置编号
        knights[tostring(data.position+1)] = cardSprite
        
        -- 设置order也需要根据实际位置来计算
        self._battleField:addToCardNode(cardSprite, position[2]*-1 + data.position)
    end
end

function BoutEntry:_loadPet(petArray, isHeroPet)
    if not petArray then
        return
    end

    -- get the base ID of the pet
    local boutData  = self._data
    local petBaseId = nil
    if isHeroPet then 
        petBaseId = rawget(self._message.own_teams[boutData.own_team + 1], "pet")
    else
        petBaseId = rawget(self._message.enemy_teams[boutData.enemy_team + 1], "pet")
    end

    -- create pet
    if petBaseId and petBaseId > 0 then
        local petSprite = PetSprite.new(petBaseId, isHeroPet, self._battleField)
        local arrIndex  = isHeroPet and 1 or 2
        petArray[arrIndex] = petSprite

        -- 本方战宠以5号位的武将位置为基准
        -- 对方战宠以2号位的武将位置为基准
        local position = isHeroPet and LocationFactory.getSelfPositionByIndex(5)
                                   or  LocationFactory.getEnemyPositionByIndex(2)
        local scale = LocationFactory.getScaleByPosition(position)
        petSprite:setPositionXY(position[1], position[2])
        petSprite:setScale(scale)

        self._battleField:addToPetShadowNode(petSprite)
    end
end

function BoutEntry:destroyEntry()
    BoutEntry.super.destroyEntry(self)
    if self._roundLabel then
        self._roundLabel:removeFromParent()
        self._roundLabel = nil
    end
end

return BoutEntry

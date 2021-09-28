--[[
    filename: ComBattle.Data.BattleSpdy.lua
    description: 缓存
    date: 2016.11.23

    author: 杨科
    email:  h3rvgo@gmail.com
-- ]]


local BattleSpdy = class("BattleSpdy", function()
    return {}
end)

function BattleSpdy:ctor(params)
    self.buffItems_ = {}
    self.heroItems_ = {}
    self.skillItems_ = {}
    self.partnerItems_ = {}
end


function BattleSpdy:getBuffItem(buffId)
    if not buffId then
        return nil
    end
    if self.buffItems_[buffId] == nil then
        local item = bd.data_config.BuffModel.items[buffId]
        if not item then
            self.buffItems_[buffId] = false
        else
            local function loadBuffEffect(s)
                if s and type(s) == "string" and s ~= "0" then
                    return self:loadBuffType(s)
                else
                    return s
                end
            end

            -- BUFF触发时效果
            item.displayBegin = loadBuffEffect(item.displayBegin)

            -- BUFF执行时效果
            item.displayExec = loadBuffEffect(item.displayExec)

            -- BUFF移除时效果
            item.displayEnd = loadBuffEffect(item.displayEnd)

            self.buffItems_[buffId] = {
                id           = item.ID,
                name         = item.name,
                type         = item.stateEnum,
                displayBegin = item.displayBegin,
                displayExec  = item.displayExec,
                displayEnd   = item.displayEnd,
            }
        end
    end
    return self.buffItems_[buffId]
end


-- @加载buff效果配置
function BattleSpdy:loadBuffType(s)
    if s == "" then
        return nil
    end

    local result = {}
    local fileItems = ld.split(s, "||")

    for _, item in ipairs(fileItems) do
        local show_type, file_type, file_name = unpack(ld.split(item, ","))
        if show_type and show_type ~= ""
            and file_type and file_type ~= ""
            and file_name and file_name ~= ""
          then
            show_type = tonumber(show_type)
            file_type = tonumber(file_type)

            local showItem = {
                showType = show_type,
                picture  = file_type == bd.CONST.buffFileType.ePicture and file_name .. ".png" or nil,
                effect   = file_type == bd.CONST.buffFileType.eEffect and file_name or nil,
                audio    = file_type == bd.CONST.buffFileType.eAudio and file_name or nil
            }
            if showItem.picture or showItem.effect then
                table.insert(result, showItem)
            end
        end
    end

    return next(result) and result or nil
end


function BattleSpdy:getHeroItem(heroId)
    if self.heroItems_[heroId] == nil then
        local item = HeroModel.items[heroId]
        if not item then
            self.heroItems_[heroId] = false
        else
            local jointSkillSound = Utility.getJointSkilSound(item)
            local skillSound, staySound = Utility.getHeroSound(item)
            self.heroItems_[heroId] = {
                id          = item.ID,
                name        = item.name,
                quality     = item.quality,
                race        = item.raceID,
                specialType = item.specialType,
                largePic    = item.largePic,
                smallPic    = item.smallPic,
                skillPic    = item.skillPic and (item.skillPic .. ".png"),
                skillId     = item.RAID,
                normalId    = item.NAID,
                comboSkillId= item.UAID,
                skillSound  = skillSound,
                staySound   = staySound,
                drawingPicA = item.drawingPicA,
                drawingPicB = item.drawingPicB,
                jpintPic    = item.jpintPic,
                jointSkillSound = jointSkillSound,
            }
        end
    end

    return self.heroItems_[heroId]
end


function BattleSpdy:getSkillItem(skillId)
    if self.skillItems_[skillId] == nil then
        local item = AttackModel.items[skillId]
        if not item then
            self.skillItems_[skillId] = false
        else
            local buffList = bd.func.split(item.buffList, ",")
            if buffList then
                for k, v in pairs(buffList) do
                    buffList[k] = tonumber(v)
                end
            end
            self.skillItems_[skillId] = {
                id             = item.ID,
                name           = item.name,
                useRP          = item.useRP,
                buffList       = buffList or {},
                targetCampEnum = item.targetCampEnum,
                targetNum      = item.targetNum,
                effectShowType = item.effectShowType,
                effectCode     = (item.effectCode ~= "" and item.effectCode)
                                    or "config_default",
            }
        end
    end

    return self.skillItems_[skillId]
end

-- @获取组合技羁绊英雄ID
function BattleSpdy:getHeroPartner(heroId)
    if self.partnerItems_[heroId] == nil then
        local hero = IllusionModel.items[heroId] or HeroModel.items[heroId]

        if hero and hero.jointID > 0 then
            require("Config.HeroJointModel")
            local joint = HeroJointModel.items[hero.jointID]
            if joint and joint.mainHeroID == heroId then
                self.partnerItems_[heroId] = joint.aidHeroID
            end
            
        else
            self.partnerItems_[heroId] = false
        end
    end

    return self.partnerItems_[heroId]
end


return BattleSpdy

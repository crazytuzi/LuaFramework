AudioEnginer = {}
--require "AudioEngine"
local stop_Effect = nil
local stop_Music = nil
local randMusForSkill = 0
local randMusForNPC = 0
local randMusForStep = 0
local skillSoundLimit = 3
local monsterSoundLimit = 5
local lastSKillTime,nowSkillTime = 0,0
local lastMosterTime,nowMosterTime = 0,0
local lastLiuVoice = nil

function AudioEnginer.stopAllEffects()
    cc.SimpleAudioEngine:getInstance():stopAllEffects()
    ccexp.AudioEngine:stopAll()
end

function AudioEnginer.setIsNoPlayEffects(noplay)   
    cc.SimpleAudioEngine:getInstance():SetStopEffect(noplay);

    stop_Effect = noplay
    
    if noplay then
        AudioEnginer.stopAllEffects()
    end

    if G_MAINSCENE and G_MAINSCENE.map_layer then
        if G_MAINSCENE.map_layer:hasPath() and not noplay then
            local rideState = true
            local mapInfo = getConfigItemByKey("MapInfo","q_map_id",G_MAINSCENE.map_layer.mapID)
            if (not (G_RIDING_INFO.id and G_RIDING_INFO.id[1])) or (not mapInfo.q_map_ride or tonumber(mapInfo.q_map_ride) ~= 1) or not G_ROLE_MAIN.up_ride then
              rideState = nil
            end
            if G_MY_STEP_SOUND then
                AudioEnginer.stopEffect(G_MY_STEP_SOUND) 
                G_MY_STEP_SOUND = nil
            end
            G_MY_STEP_SOUND =  AudioEnginer.randStepMus(rideState) 
        end
    end
end

function AudioEnginer.stopEffect(idex)
    if idex then
        cc.SimpleAudioEngine:getInstance():stopEffect(idex)
        ccexp.AudioEngine:stop(idex)
    end
end

function AudioEnginer.setMusicVolume(volume)
    if volume and cc.SimpleAudioEngine:getInstance() then
        cc.SimpleAudioEngine:getInstance():setMusicVolume(volume)
    end
end

function AudioEnginer.getMusicVolume()
    return cc.SimpleAudioEngine:getInstance():getMusicVolume()
end

function AudioEnginer.getEffectsVolume()
    return cc.SimpleAudioEngine:getInstance():getEffectsVolume()
end

function AudioEnginer.playEffectOld(filename, isLoop,specialTurn)
	if stop_Effect and not specialTurn then 
		return
	end
    local loopValue = false
    if nil ~= isLoop then
        loopValue = isLoop
    end
    --AudioEnginer.setEffectsVolume(0.6)
    return cc.SimpleAudioEngine:getInstance():playEffect(filename, loopValue)
end

function AudioEnginer.playEffect(filename, isLoop) 
    if stop_Effect then 
        return
    end

    local loopValue = false
    if nil ~= isLoop then
        loopValue = isLoop
    end
    --AudioEnginer.setEffectsVolume(0.6)    
    if isIOS() then
        return cc.SimpleAudioEngine:getInstance():playEffect(filename, loopValue)
    end

    return ccexp.AudioEngine:play2d(filename, loopValue)
end

function AudioEnginer.playLiuEffect(filename, isLoop)
    if stop_Effect then 
        return
    end
    if lastLiuVoice then
        AudioEnginer.stopEffect(lastLiuVoice)
        lastLiuVoice = nil
    end

    if isIOS() then
        lastLiuVoice = cc.SimpleAudioEngine:getInstance():playEffect(filename, loopValue)
    else
        lastLiuVoice = ccexp.AudioEngine:play2d(filename, loopValue)
    end
    
    local loopValue = false
    if nil ~= isLoop then
        loopValue = isLoop
    end
    return lastLiuVoice
end

function AudioEnginer.setIsNoPlayMusic(noplay)
    cc.SimpleAudioEngine:getInstance():SetStopMusic(noplay);

    stop_Music = noplay
    --print("setIsNoPlayMusic"..tostring(noplay))
    if noplay then
        cc.SimpleAudioEngine:getInstance():stopMusic(true)
    end
end

function AudioEnginer.pauseMusic()
    cc.SimpleAudioEngine:getInstance():pauseMusic()
end

function AudioEnginer.resumeMusic()
    cc.SimpleAudioEngine:getInstance():resumeMusic()
end

function AudioEnginer.stopMusic()
    cc.SimpleAudioEngine:getInstance():stopMusic(true)
end

function AudioEnginer.playMusic(filename, isLoop)
	if stop_Music then 
		return
	end
	cc.SimpleAudioEngine:getInstance():stopMusic(true)
    local loopValue = false
    if nil ~= isLoop then
        loopValue = isLoop
    end
    cc.SimpleAudioEngine:getInstance():playMusic(filename, loopValue)
end

function AudioEnginer.setEffectsVolume(volume)
    cc.SimpleAudioEngine:getInstance():setEffectsVolume(volume)
end

function AudioEnginer.pauseEffect(handle)
    cc.SimpleAudioEngine:getInstance():pauseEffect(handle)
end

function AudioEnginer.resumeEffect(handle)
    cc.SimpleAudioEngine:getInstance():resumeEffect(handle)
end

function AudioEnginer.preloadEffect(filename)
    cc.SimpleAudioEngine:getInstance():preloadEffect(filename)
end

function AudioEnginer.playTouchPointEffect()
    --AudioEnginer.playEffect("sounds/actionMusic/17.mp3", false)
    AudioEnginer.playEffect("sounds/uiMusic/ui_click.mp3", false)
end

function AudioEnginer.isBackgroundMusicPlaying()
    return cc.SimpleAudioEngine:getInstance():isMusicPlaying()
end

function AudioEnginer.randSkillMusic(skill_id,isme)

    lastSKillTime = os.time()
    skillSoundLimit = skillSoundLimit - 1
    if skillSoundLimit > 0 or isme then
        local sound = getConfigItemByKey("SkillCfg","skillID",skill_id,"sound")
        local manySound = getConfigItemByKey("SkillCfg","skillID",skill_id,"manysou")
        if sound then
            if manySound and tonumber(manySound) > 0 then
                local s = math.floor(math.random(1,tonumber(manySound)))
                if randMusForSkill == 0 or randMusForSkill ~= s then
                    AudioEnginer.playEffect("sounds/skillMusic/"..sound.."_"..s..".mp3",false)
                    randMusForSkill = s
                elseif randMusForSkill == s then
                    if (s+1) > tonumber(manySound) then
                        s = 1
                    else
                        s = s + 1
                    end
                    AudioEnginer.playEffect("sounds/skillMusic/"..sound.."_"..s..".mp3",false)
                    randMusForSkill = s
                end
            else
                AudioEnginer.playEffect("sounds/skillMusic/"..sound..".mp3",false)
            end
        end
    end
    if lastSKillTime - nowSkillTime > 0 then
        skillSoundLimit = 3
    end    
    nowSkillTime = lastSKillTime    
end

function AudioEnginer.randMonsterMus(monster_id,typeId)
    lastMosterTime = os.time()
    monsterSoundLimit = monsterSoundLimit - 1
    if typeId and monster_id and monsterSoundLimit > 0 then
        local monster_mus = getConfigItemByKey("monster","q_id",monster_id,"sound")
        local manySound = getConfigItemByKey("monster","q_id",monster_id,"manysou")
        local musTab = {}
        if manySound then
            musTab = stringsplit(manySound,"_")
        end
        if monster_mus then    
            if typeId == 1 then                
                if musTab[1] then
                    if tonumber(musTab[1]) > 1 then
                        local s = math.floor(math.random(1,tonumber(musTab[1])))
                        AudioEnginer.playEffect("sounds/monsterMusic/"..monster_mus.."/attack_"..s..".mp3",false)                 
                    elseif tonumber(musTab[1]) == 1 then
                        AudioEnginer.playEffect("sounds/monsterMusic/"..monster_mus.."/attack.mp3",false)
                    end
                end
            elseif typeId == 2 then
                if musTab[2] then
                    if tonumber(musTab[2]) > 1 then
                    -- if cc.FileUtils:getInstance():isFileExist("sounds/monsterMusic/"..monster_mus.."/4.mp3") then
                        local s = math.floor(math.random(1,tonumber(musTab[2])))
                        AudioEnginer.playEffect("sounds/monsterMusic/"..monster_mus.."/hurt_"..s..".mp3",false)
                    elseif tonumber(musTab[2]) == 1 then
                        AudioEnginer.playEffect("sounds/monsterMusic/"..monster_mus.."/hurt.mp3",false)
                    end
                end
            elseif typeId == 3 then
                if musTab[3] then
                    if tonumber(musTab[3]) > 1 then
                    -- if cc.FileUtils:getInstance():isFileExist("sounds/monsterMusic/"..monster_mus.."/4.mp3") then
                        local s = math.floor(math.random(1,tonumber(musTab[3])))
                        AudioEnginer.playEffect("sounds/monsterMusic/"..monster_mus.."/death_"..s..".mp3",false)
                    elseif tonumber(musTab[3]) == 1 then
                        AudioEnginer.playEffect("sounds/monsterMusic/"..monster_mus.."/death.mp3",false)
                    end
                end         
            end
        end
    end
    if lastMosterTime - nowMosterTime > 0 then
        monsterSoundLimit = 5
    end    
    nowMosterTime = lastMosterTime    
end

function AudioEnginer.randNPCMus(npc_id,npcVoiceId)
    if getGameSetById(GAME_SET_NPC_VOICE) == 1 then
        local manySound = getConfigItemByKey("NPC","q_id",npc_id,"manysou")
        local tempVoice = nil
        if manySound and tonumber(manySound) > 0 then
            local s = math.floor(math.random(1,tonumber(manySound)))
            if randMusForNPC == 0 or randMusForNPC ~= s then
                    tempVoice = AudioEnginer.playEffectOld("sounds/npcVoice/"..npcVoiceId.."_"..s..".mp3",false,true)
                    randMusForNPC = s
            elseif randMusForNPC == s then
                if (s+1) > tonumber(manySound) then
                    s = 1
                else
                    s = s + 1
                end
                tempVoice = AudioEnginer.playEffectOld("sounds/npcVoice/"..npcVoiceId.."_"..s..".mp3",false,true)
                randMusForNPC = s
            end      
        else
            tempVoice = AudioEnginer.playEffectOld("sounds/npcVoice/"..npcVoiceId..".mp3",false,true)
        end
        return tempVoice
    end
end

function AudioEnginer.randStepMus(stepType,ride_id)
    local stepMus = nil
    --local rate1 = 1
    --local rate = MRoleStruct:getAttr(ROLE_MOVE_SPEED)/100
    if (stepType and G_MAINSCENE.map_layer:hasPath()) or (G_RIDING_INFO and G_RIDING_INFO.state and not G_MAINSCENE.map_layer:hasPath() ) then
    -- if stepType then
        -- rate1 = (rate and rate * 1.3 ) or 1.3
        local realRate = G_ROLE_MAIN.ride_id or ride_id
        local rideMus = "horse_run"
        if realRate == 8888 or realRate == 3102 then
            rideMus = "kylin_run"
        end
        stepMus = AudioEnginer.playEffect("sounds/actionMusic/"..rideMus..".mp3", true)
    else
        -- rate1 = (rate and rate * 2 ) or 2
        local s = math.floor(math.random(1,6))
        if randMusForStep == 0 or randMusForStep ~= s then
            stepMus = AudioEnginer.playEffect("sounds/actionMusic/step_"..s..".mp3", true)
            randMusForStep = s
        elseif randMusForStep == s then
            if (s+1) > 6 then
                s = 1
            else
                s = s + 1
            end
            stepMus = AudioEnginer.playEffect("sounds/actionMusic/step_"..s..".mp3", true)
            randMusForStep = s
        end        
    end
    return stepMus
end
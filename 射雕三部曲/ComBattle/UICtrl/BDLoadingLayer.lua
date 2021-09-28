--[[
    filename: ComBattle.UICtrl.BDLoadingLayer.lua
    description: 战斗自由预加载页面
    date: 2016.11.18

    author: 杨科
    email:  h3rvgo@gmail.com
-- ]]

local BDLoadingLayer = class("BDLoadingLayer", function(params)
    local layer = cc.Layer:create()
    layer:enableNodeEvents()
    return layer
end)


function BDLoadingLayer:ctor(params)
    self.battleData = params.battleData
    self.battleSpdy = params.spdy
    self.async = params.async
    self.callback = params.callback

    if self.async then
        return
    end

    --背景
    local bgList = bd.ui_config.loadingMapPic
    local sprite = cc.Sprite:create(bgList[math.random(1,#bgList)])
    if sprite then
        if bd.project == "project_huanzhu" or bd.project == "project_shediao" then
            sprite:setScale(bd.ui_config.MinScale)
        else
            sprite:setScale(bd.ui_config.MaxScale)
        end
        sprite:setPosition(bd.ui_config.cx , bd.ui_config.cy)
        self:addChild(sprite)
    end

    -- tips
    if bd.patch and bd.patch.getLoadingTips then
        self.tipsLabel = bd.interface.newLabel({
            text = bd.patch.getLoadingTips(),
            size = 22 * Adapter.MinScale,
            x    = display.cx,
            y    = 135 * bd.ui_config.AutoScaleY,
        })
        self:addChild(self.tipsLabel)
    end

    --创建进度条
    self.progress = bd.interface.newProgress({
        bgImage   = bd.ui_config.loadingBgPic,
        barImage  = bd.ui_config.loadingFrontPic,
        currValue = 0,
        maxValue  = 100,
        needLabel = true,
        font      = "Arial",
        color     = cc.c3b(255, 255, 100),
    })
    self.progress:setScaleY(1.2 * bd.ui_config.MinScale)
    self.progress:setScaleX(bd.ui_config.MinScale)
    self.progress:setAnchorPoint(cc.p(0.5, 0.5))
    self.progress:setPosition(cc.p(bd.ui_config.cx, 100*bd.ui_config.AutoScaleY))
    self.progress:setMaxValue(100)
    self:addChild(self.progress)

    if bd.ui_config.loadingFlagPic then
        self.loadingFlag = bd.interface.newSprite({
            img    = bd.ui_config.loadingFlagPic,
            parent = self.progress,
            anchor = cc.p(1.18, 0.2),
        })
        local size = self.progress.mBarSprite:getContentSize()
        self.loadingFlag:setPositionX(self.progress.mBarSprite:getPositionX())
        self.loadingFlag:setPositionY(size.height)
    end
end


function BDLoadingLayer:onEnterTransitionFinish()
    if self.mOnEnterTransitionFinished then
        return
    end
    self.mOnEnterTransitionFinished = true

    -- 射雕直接回调，然后异步加载资源
    if self.async then
        bd.func.performWithDelay(self, self.callback, 0)
    end

    -- 获取需要加载的资源
    local spine, audio, pic = self:getFiles()
    if bd.ui_config.heroEntryEffect then
        table.insert(spine, 1, bd.ui_config.heroEntryEffect[1])
    end

    self.spineFiles = clone(spine)
    self.audioFile = clone(audio)
    self.pictureFiles = clone(pic)

    local totalCnt = #spine + #audio + #pic
    local totalTime = 2.5 -- 设定的加载时间
    local outtime = 0   -- 已耗时
    local doneCnt = 0   -- 已完成的数量
    local flag = 0

    local math_ceil = math.ceil
    local table_remove = table.remove

    local function onUpdate(delta)
        outtime = outtime + delta

        -- 应该加载完成的数量
        local outCnt = math_ceil(totalCnt * outtime / totalTime)
        -- 本帧需要完成的数量
        local cnt = outCnt - doneCnt
        if cnt <= 0 then
            cnt = 1 -- 保证至少加载一个文件
        end

        -- 修改
        cnt = 2
        doneCnt = doneCnt + cnt

        local cb = self.async and bd.func.getChecker(function()
            if not tolua.isnull(self) then
                self.callNext()
            end
        end, cnt) or nil

        -- 每帧只加载一个spine
        if next(spine) then
            local f = spine[1]
            cnt = cnt - 1
            table_remove(spine, 1)

            self:loadSpineRes(f, cb)
        end

        if next(audio) then
            local f = audio[1]
            cnt = cnt - 1
            table_remove(audio, 1)

            self:loadAudio(f)
            local _ = cb and cb()
        end

        if next(pic) then
            for k = #pic, 1, -1 do
                if cnt == 0 then
                    break
                end

                cnt = cnt - 1
                local f = pic[k]
                table_remove(pic, k)

                self:loadPic(f, cb)
            end
        end

        if self.progress then
            if doneCnt >= totalCnt then
                self.progress:setCurrValue(100)
                self:unscheduleUpdate()
                local size = self.progress.mBarSprite:getContentSize()
                self.loadingFlag:setPositionX(size.width)

                if self.callback then
                    bd.func.performWithDelay(self, function()
                        self.callback(self)
                    end, 0.001)
                end
            else
                local percent = doneCnt * 100 / totalCnt
                self.progress:setCurrValue(percent)
                if self.loadingFlag then
                    local size = self.progress.mBarSprite:getContentSize()
                    self.loadingFlag:setPositionX(size.width * percent / 100)
                end
            end
        end
    end

    if self.async then
        self.callNext = function()
            onUpdate(0.1)
        end
        self.callNext()
    else
        self:onUpdate(onUpdate)
    end
end

function BDLoadingLayer:onExit()
    if self.spineFiles then
        for _, v in pairs(self.spineFiles) do
            SkeletonCache:release(v .. ".skel")
        end
    end

    if self.audioFile then
        for _, v in pairs(self.audioFile) do
        end
    end

    if self.pictureFiles then
    end
end


-- 获取需要加载的文件
function BDLoadingLayer:getFiles()
    local stageCount = self.battleData:get_battle_stageCount()
    local stageData = self.battleData.battle_.stageData

    local pictures = bd.patch and bd.patch.preloadPictures and clone(bd.patch.preloadPictures) or {}
    local largePics = bd.patch and bd.patch.preloadSpines and clone(bd.patch.preloadSpines) or {}
    local audioFiles = bd.patch and bd.patch.preloadAudios and clone(bd.patch.preloadAudios) or {}

    local skillIDs = {}
    local heroIDs = {}

    local params = self.battleData:get_battle_params()
    if params.map then
        pictures[params.map] = true
    end

    -- 遍历关卡数据
    for _, data in ipairs(stageData) do
        local function load_hero(list)
            for i, hero in pairs(list) do
                if next(hero) ~= nil then
                    heroIDs[hero.HeroModelId] = true
                    pictures[bd.interface.getAvatar(hero.HeroModelId, hero.Step)] = true
                    self:findHeroFiles(largePics, hero)
                    self:findSkillID(skillIDs, hero)

                    --缓存英雄待机形象
                    if g_editor_mode_hero_data == nil then
                        if i <= 6 or i >= 12 then
                            bd.interface.cacheHeroDaijiImage(bd.layer, hero.LargePic)
                        end
                    end
                end
            end
        end

        -- 遍历主将
        load_hero(data.HeroList)
        if data.StorageList then
            for _, list in pairs(data.StorageList) do
                load_hero(list)
            end
        end

        -- 遍历宠物
        if data.PetList then
            for _, pet in pairs(data.PetList) do
                -- self:findHeroFiles(largePics, pet)
                -- self:findSkillID(skillIDs, pet)
            end
        end

        -- 遍历开场技
        if data.PetList2 then
            for _, pet in pairs(data.PetList2) do
            end
        end

        if data.PetList3 then
            for _, pet in ipairs(data.PetList3) do
                largePics[ZhenshouModel.items[pet.HeroModelId].bigPic] = true
            end
        end
    end

    local device = IPlatform and IPlatform:getInstance():getConfigItem("OldDevice")
    if (device ~= "1") then
        -- 旧设备不加载以下资源

        -- 通过技能ID查找技能代码，再查找资源
        for id in pairs(skillIDs) do
            local skill_config = bd.interface.getSkillById(id)

            -- 特效文件
            if skill_config.res then
                for _, f in pairs(skill_config.res) do
                    largePics[f] = true
                end
            end

            if skill_config.audio then
                for _, f in pairs(skill_config.audio) do
                    audioFiles[f] = true
                end
            end
        end

        -- 通过HeroModelID获取技能音效
        for id in pairs(heroIDs) do
            local f = bd.interface.getAudioById(id)
            if f then
                audioFiles[f] = true
            end
        end

        if bd.patch and bd.patch.getPreLoadFiles then
            local v1, v2, v3 = bd.patch.getPreLoadFiles(self.battleData, self.battleSpdy)
            self:appendFiles(pictures, largePics, audioFiles, v1, v2, v3)
        end

        -- 所有BUFF特效
        for k in pairs(bd.ui_config.buffEffectPostOffset) do
            largePics[k] = true
        end
        -- 所有BUFF图片
        if bd.patch and bd.patch.buffTagImages then
            for _, v in pairs(bd.patch.buffTagImages) do
                pictures[v] = true
            end
        end
    end

    if self.battleData.getPreLoadFiles then
        local v1, v2, v3 = self.battleData:getPreLoadFiles(self.battleData, self.battleSpdy)
        self:appendFiles(pictures, largePics, audioFiles, v1, v2, v3)
    end

    return bd.func.getKey(largePics), bd.func.getKey(audioFiles), bd.func.getKey(pictures)
end


-- @查找人物骨骼文件
function BDLoadingLayer:findHeroFiles(list, hero)
    local heroPic = hero.LargePic
    if (not heroPic) or (heroPic == "") then
        local item = HeroModel.items[hero.HeroModelId]
        heroPic = item and item.largePic
    end

    if heroPic then
        list[heroPic] = true
    end
end


-- @查找技能ID
function BDLoadingLayer:findSkillID(list, hero)
    if hero.NAId then
        list[hero.NAId] = true
    end

    if hero.RAId then
        list[hero.RAId] = true
    end
end


-- @查找buff资源
function BDLoadingLayer:findBuffFile(largePics, pictures, buffId)
    local function insert(buff)
        if not buff then
            return
        end

        for _, v in ipairs(buff) do
            if v.effect then
                largePics[v.effect] = true
            elseif v.picture then
                pictures[v.picture] = true
            end
        end
    end

    local buff = self.battleSpdy:getBuffItem(buffId)
    if buff then
        insert(buff.displayBegin)
        insert(buff.displayExec)
        insert(buff.displayEnd)
    end
end


-- @
function BDLoadingLayer:appendFiles(pictures, largePics, audioFiles, v1, v2, v3)
    for k in pairs(v1) do
        pictures[k] = true
    end
    for k in pairs(v2) do
        largePics[k] = true
    end
    for k in pairs(v3) do
        audioFiles[k] = true
    end
end

-- @加载spine资源
function BDLoadingLayer:loadSpineRes(file, cb)
    if not cc.FileUtils:getInstance():isFileExist(file .. ".skel") then
        return cb and cb()
    end

    bd.log.info("load "..file)

    if self.async then
        SkeletonCache:getDataAsync(file .. ".skel", file .. ".atlas", 1, cb)
    else
        SkeletonCache:preload(file .. ".skel", file .. ".atlas", 1)
    end
end


-- @加载音效文件
function BDLoadingLayer:loadAudio(file)
    if not cc.FileUtils:getInstance():isFileExist(file) then
        return
    end

    bd.log.info("load "..file)
end


-- @加载图片
function BDLoadingLayer:loadPic(file, cb)
    if not cc.FileUtils:getInstance():isFileExist(file) then
        return
    end

    bd.log.info("load "..file)
    display.loadImage(file, cb)
end

return BDLoadingLayer

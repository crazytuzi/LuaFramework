
--
-- Author: Kumo.Wang
-- 時裝衣櫃数据管理
--

local QBaseModel = import("...models.QBaseModel")
local QFashion = class("QFashion", QBaseModel)

local QUIViewController = import("...ui.QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QActorProp = import("...models.QActorProp")

QFashion.EVENT_EXTRAPROP_UPDATE = "QFASHION.EVENT_EXTRAPROP_UPDATE"
QFashion.EVENT_REFRESH_FORCE = "QFASHION.EVENT_REFRESH_FORCE"
QFashion.NEW_DAY = "QFASHION.NEW_DAY"

QFashion.NO_QUALITY = "0"
QFashion.PRIMARY_QUALITY = "1"
QFashion.MIDDLE_QUALITY = "2"
QFashion.SENIOR_QUALITY = "3"
QFashion.BEST_QUALITY = "4"
QFashion.TOP_QUALITY = "5"

QFashion.FUNC_TYPE_FASHION = "QFASHION.FUNC_TYPE_FASHION" -- 寶籙
QFashion.FUNC_TYPE_FASHION_COMBINATION = "QFASHION.FUNC_TYPE_FASHION_COMBINATION" -- 繪卷

QFashion.TYPE_FOR_NOT_EXTRAPROP = 3 -- 非全局属性，单人属性的绘卷类型(作废了，因为策划在里面也混进了全队属性，那么只能通过属性的key单独判断)

function QFashion:ctor()
    QFashion.super.ctor(self)
end

function QFashion:init()
    self._dispatchTBl = {}

    -- self._skinIdSkinConfigDataDic = {} -- 保存皮膚量表數據。key：皮膚skinId字段。value：量表數據
    -- self._heroIdSkinConfigDataDic = {} -- 保存皮膚量表數據。key：皮膚heroId字段。value：量表數據
    -- self._qualitySkinConfigDataDic = {} -- 保存皮膚量表數據。key：皮膚quality字段。value：量表數據

    self._wardrobePropConfigDic = {} -- 保存皮膚衣櫃屬性量表數據。key：皮膚quality字段。value：量表數據
    self._skinCombinationConfigList = {} -- 保存皮膚繪卷屬性量表數據。

    self._activitySkinDic = {} -- 保存后端给的已经激活的英雄皮肤。key：皮膚skinId。value：true
    self._activityWardrobeIdDic = {} -- 保存后端给的已经激活的衣柜属性id。key：皮膚quality。value：衣柜属性id
    self._activityPictureIdDic = {} -- 保存后端给的已经激活的绘卷属性id。key：绘卷属性id。value：绘卷config

    self.allQuality = {self.PRIMARY_QUALITY, self.MIDDLE_QUALITY, self.SENIOR_QUALITY, self.BEST_QUALITY, self.TOP_QUALITY}
end

function QFashion:loginEnd(callback)
    QFashion.super.loginEnd(self)
    self:_addEvent()
end

function QFashion:disappear()
    QFashion.super.disappear(self)
    -- self._skinIdSkinConfigDataDic = {} 
    -- self._heroIdSkinConfigDataDic = {} 
    -- self._qualitySkinConfigDataDic = {}
    self:_removeEvent()
end

function QFashion:_addEvent()
    self:_removeEvent()
    -- self._userEventProxy = cc.EventProxy.new(remote.user)
    -- self._userEventProxy:addEventListener(remote.user.EVENT_TIME_REFRESH, handler(self, self.refreshTimeHandler))
end

function QFashion:_removeEvent()
    -- if self._userEventProxy ~= nil then
    --     self._userEventProxy:removeAllEventListeners()
    --     self._userEventProxy = nil
    -- end
end

--打开衣柜界面
function QFashion:openDialog(callback)
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFashionMain", 
        options = {selectedSkinId = nil, selectedHeroId = nil, selectedSkinQuality = nil, callback = nil}})
end

function QFashion:openDialogForFashionCombination(callback)
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFashionCombinationMain", 
        options = {selectedFashionCombinationId = nil, callback = nil}})
end

-- function QFashion:refreshTimeHandler(event)
--     if event.time == nil or event.time == 0 then
--         -- self._skinIdSkinConfigDataDic = {} 
--         -- self._heroIdSkinConfigDataDic = {} 
--         -- self._qualitySkinConfigDataDic = {}
--         self:dispatchEvent( { name = QFashion.NEW_DAY } )
--     end

--     if event.time == nil or event.time == 5 then
--     end
-- end

--------------数据储存.KUMOFLAG.--------------

-- 保存已經激活的皮膚id
function QFashion:setActivityHeroSkins(heroSkins)
    for _, value in ipairs(heroSkins) do
        self._activitySkinDic[tostring(value.skinId)] = true
    end
end

function QFashion:setActivityInfo(data)
    if data.skinWardrobeIds then
        self:_setSkinWardrobeIds(data.skinWardrobeIds)
    end

    if data.skinPictureIds then
        self:_setSkinPictureIds(data.skinPictureIds)
    end

    self:dispatchEvent({name = QFashion.EVENT_EXTRAPROP_UPDATE, skinWardrobe = data.skinWardrobeIds or self._skinWardrobeIds, skinPicture = data.skinPictureIds or self._skinPictureIds})
    self:dispatchEvent({name = QFashion.EVENT_REFRESH_FORCE})
end

function QFashion:getSkinPictureIds()
    return self._skinPictureIds or {}
end

-- 根據皮膚的品質獲取皮膚的量表數據。quality缺失，返回{}。
function QFashion:getSkinConfigDataListByQuality( quality )
    if not quality then return {} end

    local tbl = {}
    local config = db:getStaticByName("character_skins")
    for _, v in pairs(config) do
        if v.is_show ~= 0 and not db:checkHeroShields(v.skins_id, SHIELDS_TYPE.SKIN_ID) then
            if v.quality then
                if not tbl[tostring(v.quality)] then
                    tbl[tostring(v.quality)] = {}
                end
                table.insert(tbl[tostring(v.quality)], v)
            end
        end
    end

    if tbl and tbl[tostring(quality)] then
        table.sort(tbl[tostring(quality)], function(a, b)
                local isActivityA = self:checkSkinActivityBySkinId(a.skins_id)
                local isActivityB = self:checkSkinActivityBySkinId(b.skins_id)
                if isActivityA ~= isActivityB then
                    return isActivityA
                elseif a.character_id ~= b.character_id then
                    return a.character_id < b.character_id
                else
                    return a.skins_id < b.skins_id
                end
            end)
        return tbl[tostring(quality)]
    end

    if quality and tbl and tbl[tostring(quality)] then
        return tbl[tostring(quality)]
    end

    return {}
end

function QFashion:getSkinConfigDataBySkinId( skinId )
    if not skinId then return {} end

    local tbl = {}
    local config = db:getStaticByName("character_skins")
    for _, v in pairs(config) do
        if tostring(v.skins_id) == tostring(skinId) then
            if v.is_show ~= 0 and not db:checkHeroShields(v.skins_id, SHIELDS_TYPE.SKIN_ID) then
                return v
            end
            return {}
        end
    end
    
    return {}
end

-- @quality 可省略
function QFashion:getSkinConfigDataByHeroId( heroId, quality )
    if not heroId then return {} end

    local tbl = {}
    local config = db:getStaticByName("character_skins")
    for _, v in pairs(config) do
        if tostring(v.character_id) == tostring(heroId) then
            if v.is_show ~= 0 and not db:checkHeroShields(v.skins_id, SHIELDS_TYPE.SKIN_ID) and v.quality and v.quality ~= self.NO_QUALITY then
                if not tbl[tostring(v.character_id)] then
                    tbl[tostring(v.character_id)] = {}
                end
                table.insert(tbl[tostring(v.character_id)], v)
            end
        end
    end

    table.sort(tbl, function(a, b)
            if a.quality ~= b.quality then
                return tonumber(a.quality) > tonumber(b.quality)
            else
                local isActivityA = self:checkSkinActivityBySkinId(a.skins_id)
                local isActivityB = self:checkSkinActivityBySkinId(b.skins_id)
                if isActivityA ~= isActivityB then
                    return isActivityA
                else
                    if a.character_id ~= b.character_id then
                        return a.character_id < b.character_id
                    else
                        return a.skins_id < b.skins_id
                    end
                end
            end
        end)

    if quality then
        for _, config in ipairs(tbl[tostring(heroId)]) do
            if tostring(config.quality) == tostring(quality) then
                -- 因为之前排序按照品质排过了，匹配到的第一个就可以返回
                return config
            end
        end
    end

    return tbl[tostring(heroId)][1]
end


function QFashion:getCombinationDataList()
    if self._skinCombinationConfigList and #self._skinCombinationConfigList > 0 then 
        return self._skinCombinationConfigList
    end

    local configs = db:getStaticByName("skins_combination_skills")
    for _, config in pairs(configs) do
        table.insert(self._skinCombinationConfigList, config)
    end

    table.sort(self._skinCombinationConfigList, function(a, b)
            return a.id > b.id
        end)

    return self._skinCombinationConfigList
end

--------------调用素材.KUMOFLAG.--------------

--------------便民工具.KUMOFLAG.--------------

function QFashion:checkRedTips()
    if self:checkFashionRedTips() then
        return true
    end

    if self:checkFashionCombinationRedTips() then
        return true
    end

    return false
end

function QFashion:checkFashionRedTips()
    for _, quality in ipairs(self.allQuality) do
        if self:checkFashionRedTipByQuality(quality) then
            return true
        end
    end

    return false
end

function QFashion:checkFashionRedTipByQuality(quality)
    local skinConfigList = self:getSkinConfigDataListByQuality(quality)
    local _, nextConfig = self:getActivedWardrobeConfigAndNextConfigByQuality(quality)
    if not nextConfig then
        return false
    end
    local needCount = tonumber(nextConfig.condition)
    local acvitityCount = 0
    for _, v in ipairs(skinConfigList) do
        local isActivity = self:checkSkinActivityBySkinId(v.skins_id)
        if isActivity then
            acvitityCount = acvitityCount + 1
        end
    end
    if acvitityCount >= needCount then 
        return true
    end

    return false
end

function QFashion:checkFashionCombinationRedTips()
    local combinationDataList = self:getCombinationDataList()
    for _, data in ipairs(combinationDataList) do
        local isActivity = false
        if data.id then
            isActivity = self:checkActivedPictureId(data.id)
        end
        if not isActivity and data.character_skins then
            local tbl = string.split(data.character_skins, ";")
            local totalNumber = #tbl
            local curNumber = 0
            if totalNumber > 0 then
                for _, id in ipairs(tbl) do
                    if self:checkSkinActivityBySkinId(id) then
                        curNumber = curNumber + 1
                    end
                end

                
                if curNumber >= totalNumber then
                    return true
                end
            end
        end
    end

    return false
end

function QFashion:getQualityCNameByQuality( quality )
    local quality = tostring(quality)
    if quality == self.PRIMARY_QUALITY then
        return "经典"
    elseif quality == self.MIDDLE_QUALITY then
        return "珍贵"
    elseif quality == self.SENIOR_QUALITY then
        return "稀有"
    elseif quality == self.BEST_QUALITY then
        return "极品"
    elseif quality == self.TOP_QUALITY then
        return "臻品"
    end
    return ""
end

function QFashion:checkSkinActivityBySkinId( skinId )
    if self._activitySkinDic then
        return self._activitySkinDic[tostring(skinId)]
    end

    return false
end

function QFashion:getActivedWardrobeConfigAndNextConfigByQuality( quality )
    local curConfig = nil
    local nextConfig = nil

    if not quality then return curConfig, nextConfig end

    local curActivedId = nil
    local curActivedConfig = self:getCurActivedWardrobeConfigByQuality(quality)
    if curActivedConfig then
        curActivedId = curActivedConfig.id
    end
    if curActivedId then
        if self._wardrobePropConfigDic[tostring(quality)] then
            local isFind = false
            for index, config in ipairs(self._wardrobePropConfigDic[tostring(quality)]) do
                if tostring(config.id) == tostring(curActivedId) then
                    curConfig = config
                    isFind = true
                elseif isFind then
                    return curConfig, config
                end
            end

            return curConfig, nextConfig
        end
    else
        if self._wardrobePropConfigDic[tostring(quality)] and self._wardrobePropConfigDic[tostring(quality)][1] then
            return curConfig, self._wardrobePropConfigDic[tostring(quality)][1]
        end
    end

    local configs = db:getStaticByName("skins_wardrobe_prop")
    for _, config in pairs(configs) do
        if config.quality and config.quality ~= self.NO_QUALITY then
            if not self._wardrobePropConfigDic[tostring(config.quality)] then
                self._wardrobePropConfigDic[tostring(config.quality)] = {}
            end
            table.insert(self._wardrobePropConfigDic[tostring(config.quality)], config)
        end
    end

    for _, configList in pairs(self._wardrobePropConfigDic) do
        table.sort(configList, function(a, b)
                return a.condition < b.condition
            end)
    end

    if curActivedId then
        if self._wardrobePropConfigDic[tostring(quality)] then
            local isFind = false
            for index, config in ipairs(self._wardrobePropConfigDic[tostring(quality)]) do
                if tostring(config.id) == tostring(curActivedId) then
                    curConfig = config
                    isFind = true
                elseif isFind then
                    return curConfig, config
                end
            end

            return curConfig, nextConfig
        end
    else
        if self._wardrobePropConfigDic[tostring(quality)] and self._wardrobePropConfigDic[tostring(quality)][1] then
            return curConfig, self._wardrobePropConfigDic[tostring(quality)][1]
        end
    end

    return curConfig, nextConfig
end

function QFashion:checkActivedPictureId( id )
    return self._activityPictureIdDic[tostring(id)]
end

function QFashion:getCurActivedWardrobeConfigByQuality( quality )
    return self._activityWardrobeIdDic[tostring(quality)]
end

function QFashion:getHeadTitlePathByQuality( quality )
    return QResPath("fashionHeadTitle")[tonumber(quality)]
end

function QFashion:getHeadColorByQuality( quality )
    local quality = tostring(quality)

    if quality == self.PRIMARY_QUALITY then
        return COLORS.B
    elseif quality == self.MIDDLE_QUALITY then
        return COLORS.C
    elseif quality == self.SENIOR_QUALITY then
        return COLORS.D
    elseif quality == self.BEST_QUALITY then
        return COLORS.E
    elseif quality == self.TOP_QUALITY then
        return COLORS.F
    end
end

function QFashion:checkExistHeroById( id )
    local haveHerosID = remote.herosUtil:getHaveHero()
    for _, haveId in ipairs(haveHerosID) do
        if tostring(haveId) == tostring(id) then
            return true
        end
    end

    return false
end

--------------数据处理.KUMOFLAG.--------------

function QFashion:responseHandler( response, successFunc, failFunc )
    if successFunc then 
        successFunc(response) 
        self:_dispatchAll()
        return
    end

    if failFunc then 
        failFunc(response)
    end

    self:_dispatchAll()
end

function QFashion:pushHandler( data )
    -- QPrintTable(data)
end

-- SKIN_WARDROBE_ACTIVE                            = 10110;                    // 皮肤衣柜激活 UserSkinWardrobeActiveRequest
-- SKIN_PICTURE_ACTIVE                             = 10111;                    // 皮肤画卷激活 UserSkinPictureActiveRequest


-- optional int32 id = 1;//激活的衣柜id
function QFashion:userSkinWardrobeActiveRequest(id, success, fail, status)
    local userSkinWardrobeActiveRequest = {id = tonumber(id)}
    local request = { api = "SKIN_WARDROBE_ACTIVE", userSkinWardrobeActiveRequest = userSkinWardrobeActiveRequest}
    app:getClient():requestPackageHandler("SKIN_WARDROBE_ACTIVE", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional int32 id = 1;//激活的画卷id
function QFashion:userSkinPictureActiveRequest(id, success, fail, status)
    local userSkinPictureActiveRequest = {id = tonumber(id)}
    local request = { api = "SKIN_PICTURE_ACTIVE", userSkinPictureActiveRequest = userSkinPictureActiveRequest}
    app:getClient():requestPackageHandler("SKIN_PICTURE_ACTIVE", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--------------本地工具.KUMOFLAG.--------------

function QFashion:_dispatchAll()
    if not self._dispatchTBl or table.nums(self._dispatchTBl) == 0 then return end
    local tbl = {}
    for _, eventTbl in pairs(self._dispatchTBl) do
        if not tbl[eventTbl.name] or table.nums(eventTbl) > 1 then
            QPrintTable(eventTbl)
            self:dispatchEvent(eventTbl)
            tbl[eventTbl.name] = true
        end
    end
    self._dispatchTBl = {}
end

function QFashion:_setSkinWardrobeIds(skinWardrobeIds)
    self._skinWardrobeIds = skinWardrobeIds
    local configs = db:getStaticByName("skins_wardrobe_prop")
    for _, config in pairs(configs) do
        for _, id in ipairs(skinWardrobeIds) do
            if tostring(config.id) == tostring(id) then
                self._activityWardrobeIdDic[tostring(config.quality)] = config
            end
        end
    end
end

function QFashion:_setSkinPictureIds(skinPictureIds)
    self._skinPictureIds = skinPictureIds
    local configs = db:getStaticByName("skins_combination_skills")
    for _, config in pairs(configs) do
        for _, id in ipairs(skinPictureIds) do
            if tostring(config.id) == tostring(id) then
                self._activityPictureIdDic[tostring(config.id)] = config
            end
        end
    end
end

return QFashion

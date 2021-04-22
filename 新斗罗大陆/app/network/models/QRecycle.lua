--
-- Kumo.Wang
-- 回收站數據類
--

local QBaseModel = import("...models.QBaseModel")
local QRecycle = class("QRecycle", QBaseModel)

local QUIViewController = import("...ui.QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QVIPUtil = import("...utils.QVIPUtil")

QRecycle.PARENT = 1 -- 父按鈕
QRecycle.CHILD = 2 -- 子按鈕
QRecycle.NORMAL = 3 -- 非父非子按鈕

function QRecycle:ctor()
    QRecycle.super.ctor(self)
    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    --[[ --舉例的配置，就是支持子菜單的配置，可以參考，功能需求不是來自策劃，所以暫時不對外
        ["1"] = {id = 1, name = "魂师养成", displayIndex = 1, member = {
                    ["101"] = {id = 101, name = "材料分解", displayIndex = 1, unlockKey = nil, dataProxy = ""},
                    ["102"] = {id = 102, name = "魂师重生", displayIndex = 2, unlockKey = nil, dataProxy = ""},
                }},
        ["103"] = {id = 103, name = "魂师分解", displayIndex = 2, unlockKey = nil, dataProxy = ""},
        ["104"] = {id = 104, name = "魂师碎片分解", displayIndex = 3, unlockKey = "UNLOCK_MATERIAL_RECYCLE", dataProxy = ""},
    ]]
    -- 注意：id是唯一的
    self._recycleMenuConfigs = {
        ["101"] = {id = 101, name = "魂师重生", displayIndex = 1, unlockKey = nil, class = "QUIWidgetRecycleForHeroReset"},
        ["102"] = {id = 102, name = "魂骨重生", displayIndex = 2, unlockKey = "UNLOCK_GEMSTONE", class = "QUIWidgetRecycleForGemReset"},
        ["103"] = {id = 103, name = "暗器重生", displayIndex = 3, unlockKey = "UNLOCK_ZUOQI", class = "QUIWidgetRecycleForMountReset"},
        ["104"] = {id = 104, name = "外附魂骨重生", displayIndex = 4, unlockKey = "UNLOCK_ZHUBAO", class = "QUIWidgetRecycleForSparReset"},
        ["105"] = {id = 105, name = "仙品重生", displayIndex = 5, unlockKey = "UNLOCK_MAGIC_HERB", class = "QUIWidgetRecycleForMagicHerbReset"},
        ["106"] = {id = 106, name = "魂灵重生", displayIndex = 6, unlockKey = "UNLOCK_SOUL_SPIRIT", class = "QUIWidgetRecycleForSoulSpiritReset"},
        ["107"] = {id = 107, name = "神器重生", displayIndex = 7, unlockKey = "UNLOCK_GOD_ARM", class = "QUIWidgetRecycleForGodarmReset"},

        ["201"] = {id = 201, name = "材料分解", displayIndex = 101, unlockKey = "UNLOCK_MATERIAL_RECYCLE", class = "QUIWidgetRecycleForMaterial"},
        ["202"] = {id = 202, name = "魂师碎片分解", displayIndex = 102, unlockKey = nil, class = "QUIWidgetRecycleForHeroFragmentRecover"},
        ["203"] = {id = 203, name = "魂骨碎片分解", displayIndex = 103, unlockKey = "UNLOCK_GEMSTONE", class = "QUIWidgetRecycleForGemFragmentRecover"},
        ["204"] = {id = 204, name = "暗器碎片分解", displayIndex = 104, unlockKey = "UNLOCK_ZUOQI", class = "QUIWidgetRecycleForMountFragmentRecover"},
        ["205"] = {id = 205, name = "外骨碎片分解", displayIndex = 105, unlockKey = "UNLOCK_ZHUBAO", class = "QUIWidgetRecycleForSparFragmentRecover"},
        ["206"] = {id = 206, name = "魂灵碎片分解", displayIndex = 106, unlockKey = "UNLOCK_SOUL_SPIRIT", class = "QUIWidgetRecycleForSoulSpiritFragmentRecover"},
        ["207"] = {id = 207, name = "神器碎片分解", displayIndex = 107, unlockKey = "UNLOCK_GOD_ARM", class = "QUIWidgetRecycleForGodarmFragmentRecover"},

        ["301"] = {id = 301, name = "魂师分解", displayIndex = 1001, unlockKey = nil, class = nil},
        ["302"] = {id = 302, name = "觉醒分解", displayIndex = 1002, unlockKey = "UNLOCK_ENCHANT", class = nil},
        ["303"] = {id = 303, name = "魂骨分解", displayIndex = 1003, unlockKey = "UNLOCK_GEMSTONE", class = nil},
        ["304"] = {id = 304, name = "暗器分解", displayIndex = 1004, unlockKey = "UNLOCK_ZUOQI", class = nil},
        ["305"] = {id = 305, name = "武魂真身分解", displayIndex = 1005, unlockKey = "UNLOCK_ARTIFACT", class = nil},
        ["306"] = {id = 306, name = "外附魂骨分解", displayIndex = 1006, unlockKey = "UNLOCK_ZHUBAO", class = nil},
        ["307"] = {id = 307, name = "仙品分解", displayIndex = 1007, unlockKey = "UNLOCK_MAGIC_HERB", class = nil},
        ["308"] = {id = 308, name = "魂灵分解", displayIndex = 1008, unlockKey = "UNLOCK_SOUL_SPIRIT", class = nil},
        ["309"] = {id = 309, name = "神器分解", displayIndex = 1009, unlockKey = "UNLOCK_GOD_ARM", class = nil},
    }
end

function QRecycle:didappear()
    QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_USER_TEAM_UP, self._teamUpEvent, self)
end

function QRecycle:loginEnd()
    self._isUnlock = false

    self._lastCheckMenuBtnDataLevel = -1
    self._lastCheckMenuBtnDataVIP = -1
    self._menuBtnData = {} -- 回收站菜单按钮数据缓存

    self.curSelectedId = 101 -- 記錄回收站當前按鈕的id
end

function QRecycle:disappear()
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_USER_TEAM_UP, self._teamUpEvent, self)
    self:_removeEvent()
end

function QRecycle:openDialog(options)
    if self:checkUnlock(true) then
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRecycle", options = options})
    end
end

--------------数据储存.KUMOFLAG.--------------
--------------调用素材.KUMOFLAG.--------------

--------------便民工具.KUMOFLAG.--------------

function QRecycle:checkUnlock(isTips, tips)
    if not self._isUnlock and app.unlock:checkLock("UNLOCK_REBIRTH", isTips, tips) then
        -- isUnlock作为登入后首次解锁的标记，然后做一个首次解锁的处理，拉取一次数据。
        self._isUnlock = true
        self:_addEvent()
    end
    return self._isUnlock
end

function QRecycle:getRecycleMenuButtonData()
    if not self._menuBtnData or #self._menuBtnData == 0 or self._lastCheckMenuBtnDataLevel ~= remote.user.level or self._lastCheckMenuBtnDataVIP ~= QVIPUtil:VIPLevel() then
        for _, config in pairs(self._recycleMenuConfigs) do
            local isUnlock = false
            if config.member then
                for _, value in pairs(config.member) do
                    if not value.unlockKey or app.unlock:checkLock(value.unlockKey) then
                        isUnlock = true
                        break
                    end
                end
            else
                if not config.unlockKey or app.unlock:checkLock(config.unlockKey) then
                    isUnlock = true
                end
            end

            if isUnlock then
                table.insert(self._menuBtnData, config)
            end
        end

        table.sort(self._menuBtnData, function(a, b)
            if a.displayIndex ~= b.displayIndex then
                return a.displayIndex < b.displayIndex
            else
                return a.id < b.id
            end
        end)
    end

    self._lastCheckMenuBtnDataLevel = remote.user.level
    self._lastCheckMenuBtnDataVIP = QVIPUtil:VIPLevel()
    return self._menuBtnData
end

function QRecycle:getRecycleSubmenuButtonDataByParentId(parentId)
    local parentConfig = self._recycleMenuConfigs[tostring(parentId)]
    if not parentId or not parentConfig then return end

    local tbl = {}
    for _, config in pairs(parentConfig.member) do
        if not config.unlockKey or app.unlock:checkLock(config.unlockKey) then
            config.isSubmenu = true
            config.parentId = parentId
            table.insert(tbl, config)
        end
    end

    table.sort(tbl, function(a, b)
        if a.displayIndex ~= b.displayIndex then
            return a.displayIndex < b.displayIndex
        else
            return a.id < b.id
        end
    end)

    return tbl
end

function QRecycle:getRecycleParentIdByChildId(childId)
    for _, config in pairs(self._recycleMenuConfigs) do
        if config.member then
            for _, value in pairs(config.member) do
                if value.id == childId and (not value.unlockKey or app.unlock:checkLock(value.unlockKey)) then
                    return config.id
                end
            end
        end
    end
end

function QRecycle:getRecycleButtonTypeById(id)
    if not id then return end

    local parentConfig = self._recycleMenuConfigs[tostring(id)]
    if parentConfig then
        if parentConfig.member then
            return QRecycle.PARENT
        else
            return QRecycle.NORMAL
        end
    end

    

    return QRecycle.CHILD
end


--------------数据处理.KUMOFLAG.--------------


function QRecycle:responseHandler( response, successFunc, failFunc )
    -- QPrintTable( response )

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

function QRecycle:pushHandler( data )
    -- QPrintTable(data)
end


--------------本地工具.KUMOFLAG.--------------

function QRecycle:_addEvent()
    self:_removeEvent()
end

function QRecycle:_removeEvent()
end

function QRecycle:_teamUpEvent(event)
end

function QRecycle:_dispatchAll()
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

function QRecycle:makeDelegate( delegateFunc )
    if type(delegateFunc) == "function" then
        self._delegateFunc = delegateFunc
    end
end

function QRecycle:delDelegate()
    self._delegateFunc = nil
end

function QRecycle:doDelegate(...)
    if self._delegateFunc and type(self._delegateFunc) == "function" then
        self._delegateFunc(...)
    end
end

return QRecycle
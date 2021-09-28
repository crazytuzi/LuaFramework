--[[author: lvxiaolong
date: 2013/10/30
function: flower effect dialog
]]

require "ui.dialog"
require "utils.mhsdutils"
require "manager.beanconfigmanager"

FlowerEffectDlg = {
    m_arrInfoEffect = {},
}
setmetatable(FlowerEffectDlg, Dialog)
FlowerEffectDlg.__index = FlowerEffectDlg 

CT_MAX_FLOWER_EFFECT = 3
g_arrQueueFlowerEffect = {}

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance

function FlowerEffectDlg.IsShow()
    --LogInfo("FlowerEffectDlg.IsShow")

    if _instance and _instance:IsVisible() then
        return true
    end

    return false
end

function FlowerEffectDlg.getInstance()
	LogInfo("FlowerEffectDlg.getInstance")
    if not _instance then
        _instance = FlowerEffectDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function FlowerEffectDlg.AddFlowerEffectInfo(effectid)
    LogInfo("____FlowerEffectDlg.AddFlowerEffectInfo")
    
    if effectid and effectid >= 0 then
        local index = #g_arrQueueFlowerEffect+1
        
        local dlgEffect = FlowerEffectDlg.getInstanceAndShow()
        
        if dlgEffect then
            local indexEmpty = dlgEffect:GetEmptyEffectIndex()
            print("____indexEmpty: " .. indexEmpty)
            if indexEmpty > 0 then
                dlgEffect:SetEffectInfo(effectid, indexEmpty)
            else
                print("____no empty index")
                g_arrQueueFlowerEffect[index] = effectid
            end
        else
            print("____error not get FlowerEffectDlg.getInstanceAndShow")
        end
    else
        print("____error not correct when addflowereffect info")
    end
end

function FlowerEffectDlg.getInstanceAndShow()
	LogInfo("____FlowerEffectDlg.getInstanceAndShow")
    if not _instance then
        _instance = FlowerEffectDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end

    return _instance
end

function FlowerEffectDlg.getInstanceNotCreate()
    --print("FlowerEffectDlg.getInstanceNotCreate")
    return _instance
end

function FlowerEffectDlg.DestroyDialog()
    print("____FlowerEffectDlg.DestroyDialog")
	if _instance then
		_instance:OnClose() 
		_instance = nil
	end
end

function FlowerEffectDlg.ToggleOpenClose()
	if not _instance then 
		_instance = FlowerEffectDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
----/////////////////////////////////////////------

function FlowerEffectDlg.GetLayoutFileName()
    return "flowereffect.layout"
end

function FlowerEffectDlg:OnCreate()
	LogInfo("enter FlowerEffectDlg oncreate")

    Dialog.OnCreate(self)
    --self:GetWindow():setModalState(true)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    
    self.m_arrWndEffect = {}
    for i = 1, CT_MAX_FLOWER_EFFECT, 1 do
        self.m_arrWndEffect[i] = winMgr:getWindow("flowereffect/effect" .. tostring(i-1))
    end

    self:ClearCurInfo()
    
    self:GetWindow():subscribeEvent("WindowUpdate", FlowerEffectDlg.HandleWindowUpdate, self)

	LogInfo("exit FlowerEffectDlg OnCreate")
end

function FlowerEffectDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, FlowerEffectDlg)
    
    --self.m_eDialogType[DialogTypeTable.eDlgTypeBattleClose] = 1
    --self.m_eDialogType[DialogTypeTable.eDlgTypeInScreenCenter] = 1

    return self
end

function FlowerEffectDlg:ClearCurInfo()
    LogInfo("____FlowerEffectDlg:ClearCurInfo")
    
    if GetGameUIManager() then
        for i = 1, CT_MAX_FLOWER_EFFECT, 1 do
            if GetGameUIManager():IsWindowHaveEffect(self.m_arrWndEffect[i]) then
                GetGameUIManager():RemoveUIEffect(self.m_arrWndEffect[i])
            end
        end
    else
        print("____error not GetGameUIManager")
    end
    
    self.m_arrInfoEffect = {}
    for i = 1, CT_MAX_FLOWER_EFFECT, 1 do
        self.m_arrInfoEffect[i] = {}
        self.m_arrInfoEffect[i].effectid = -1
        self.m_arrInfoEffect[i].time = -1
    end
end

function FlowerEffectDlg:HandleWindowUpdate(eventArgs)
    
    local timePast = 1000 * CEGUI.toUpdateEventArgs(eventArgs).d_timeSinceLastFrame
    
    for i = 1, CT_MAX_FLOWER_EFFECT, 1 do
        if self.m_arrInfoEffect[i].effectid >= 0 and self.m_arrInfoEffect[i].time >= 0 then
            self.m_arrInfoEffect[i].time = self.m_arrInfoEffect[i].time - timePast
            
            if self.m_arrInfoEffect[i].time <= 0 then
                self:ClearEffectInfo(i)
            end
        end
    end
    
    local countCheck = #g_arrQueueFlowerEffect
    if countCheck > CT_MAX_FLOWER_EFFECT then
        countCheck = CT_MAX_FLOWER_EFFECT
    end
    local newStartIndexInQueue = 1
    for i = 1, countCheck, 1 do
        local emptyIndex = self:GetEmptyEffectIndex()
        if emptyIndex > 0 then
            print("____flower effect update")
            print("____emptyIndex: " .. emptyIndex)
            print("____use histroy to fill flower effect dlg effect id: " .. g_arrQueueFlowerEffect[i])
            self:SetEffectInfo(g_arrQueueFlowerEffect[i], emptyIndex)
            newStartIndexInQueue = i+1
        end
    end
    if newStartIndexInQueue > 1 then
        local num = #g_arrQueueFlowerEffect
        local stepDre = newStartIndexInQueue-1
        for i = newStartIndexInQueue, num, 1 do
            g_arrQueueFlowerEffect[i-stepDre] = g_arrQueueFlowerEffect[i]
        end
        local startEmptyIndex = num-newStartIndexInQueue+2
        for i = startEmptyIndex, num, 1 do
            g_arrQueueFlowerEffect[i] = nil
        end
    end

    local curEffCount = self:GetCurEffectCount()
    if curEffCount <= 0 and #g_arrQueueFlowerEffect <= 0 then
        FlowerEffectDlg.DestroyDialog()
    end
    
    return true
end

function FlowerEffectDlg:GetCurEffectCount()
    --print("____FlowerEffectDlg:GetCurEffectCount")
    
    local count = 0
    for i = 1, CT_MAX_FLOWER_EFFECT, 1 do
        if self.m_arrInfoEffect[i] and self.m_arrInfoEffect[i].effectid >= 0 and self.m_arrInfoEffect[i].time >= 0 then
           count = count + 1 
        end
    end
    
    return count
end

function FlowerEffectDlg:GetEmptyEffectIndex()
    --print("____FlowerEffectDlg:GetEmptyEffectIndex")
    
    local index = -1
    for i = 1, CT_MAX_FLOWER_EFFECT, 1 do
        if not self.m_arrInfoEffect[i] then
            index = i
            break
        elseif self.m_arrInfoEffect[i].effectid < 0 and self.m_arrInfoEffect[i].time < 0 then
            index = i
            break
        end
    end
    
    return index
end

function FlowerEffectDlg:ClearEffectInfo(index)
    LogInfo("____FlowerEffectDlg:ClearEffectInfo")
    
    print("____index: " .. index)
    
    if index <= 0 or index > CT_MAX_FLOWER_EFFECT then
        print("____error index out of range")
        return
    end
    
    if GetGameUIManager() then
        self.m_arrInfoEffect[index] = self.m_arrInfoEffect[index] or {}
        self.m_arrInfoEffect[index].effectid = -1
        self.m_arrInfoEffect[index].time = -1

        if GetGameUIManager():IsWindowHaveEffect(self.m_arrWndEffect[index]) then
            GetGameUIManager():RemoveUIEffect(self.m_arrWndEffect[index])
        end
    else
        print("____error no GetGameUIManager")
    end
end

function FlowerEffectDlg:SetEffectInfo(effectid, index)
    LogInfo("____FlowerEffectDlg:SetEffectInfo")
    
    print("____index: " .. index)

    if index <= 0 or index > CT_MAX_FLOWER_EFFECT then
        print("____error index out of range")
        return
    end

    if effectid and effectid > 0 then
        print("____effectid: " .. effectid)
    end

    local pathEff = MHSD_UTILS.get_effectpathFromCeffectPathTable(effectid)
    print("____pathEff: " .. pathEff)
    if effectid and effectid >= 0 and pathEff ~= "" then
        
        if GetGameUIManager() then
            self.m_arrInfoEffect[index] = self.m_arrInfoEffect[index] or {}
            self.m_arrInfoEffect[index].effectid = effectid
            self.m_arrInfoEffect[index].time = 15000

            if GetGameUIManager():IsWindowHaveEffect(self.m_arrWndEffect[index]) then
                GetGameUIManager():RemoveUIEffect(self.m_arrWndEffect[index])
            end

            GetGameUIManager():AddUIEffect(self.m_arrWndEffect[index], pathEff)
        else
            print("____error no GetGameUIManager")
        end
        
    else
        print("____error when set effect info")
    end
end

return FlowerEffectDlg





local saddtitle = require "protocoldef.knight.gsp.title.saddtitle"
function saddtitle:process()
	LogInfo("____saddtitle:process")
	require "ui.chengwei.chengweidlg"
    
    if GetDataManager() then
        GetDataManager():AddTitle(self.info.titleid, self.info.name, self.info.availtime)

        local dlgChengWei = ChengWeiDlg.getInstanceNotCreate()
        if dlgChengWei and ChengWeiDlg.IsShow() then
            dlgChengWei:RefreshAll()
        end
        
        ChengWeiCell.SendOnTitle(self.info.titleid)
    end
end

local sremovetitle = require "protocoldef.knight.gsp.title.sremovetitle"
function sremovetitle:process()
	LogInfo("____sremovetitle:process")
	require "ui.chengwei.chengweidlg"
    
    if GetDataManager() then
        GetDataManager():RemoveTitle(self.titleid)
        
        local dlgChengWei = ChengWeiDlg.getInstanceNotCreate()
        if dlgChengWei and ChengWeiDlg.IsShow() then
            dlgChengWei:RefreshAll()
        end
    end
end

local sontitle = require "protocoldef.knight.gsp.title.sontitle"
function sontitle:process()
	LogInfo("____sontitle:process")
	require "ui.chengwei.chengweidlg"
    
    if GetDataManager() then
        GetDataManager():UpdateCurTitle(self.roleid, self.titleid, self.titlename)
        
        if GetDataManager():IsPlayerSelf(self.roleid) then
            local dlgChengWei = ChengWeiDlg.getInstanceNotCreate()
            if dlgChengWei and ChengWeiDlg.IsShow() then
                dlgChengWei:RefreshCurTitleID()
                dlgChengWei:RefreshLightPart()
            end
        end
    end
end

local sofftitle = require "protocoldef.knight.gsp.title.sofftitle"
function sofftitle:process()
	LogInfo("____sofftitle:process")
	require "ui.chengwei.chengweidlg"
    
    if GetDataManager() then
        GetDataManager():UnloadCurTitle(self.roleid)
        
        if GetDataManager():IsPlayerSelf(self.roleid) then
            local dlgChengWei = ChengWeiDlg.getInstanceNotCreate()
            if dlgChengWei and ChengWeiDlg.IsShow() then
                dlgChengWei:RefreshCurTitleID()
                dlgChengWei:RefreshLightPart()
            end
        end
    end
end








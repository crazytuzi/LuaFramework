local ssendcamprankrank = require "protocoldef.knight.gsp.ranklist.ssendcamprankrank"
function ssendcamprankrank:process()
	LogInfo("ssendcamprankrank process")
	require "ui.camp.campranklistdlg"
	CampRankListDlg.getInstanceAndShow():refreshInfo(self.page, self.hasmore, self.camp, self.myscore, self.mytitle, self.recordlist)
end

local stakeawardsucess = require "protocoldef.knight.gsp.ranklist.stakeawardsucess"
function stakeawardsucess:process()
	LogInfo("stakeawardsucess process")
	require "ui.rank.rankinglist"
	RankingList.TakeAwardSuccess(self.ranktype)
end

local sgetrolename = require "protocoldef.knight.gsp.ranklist.sgetrolename"
function sgetrolename:process()
    LogInfo("____sgetrolename:process")
	require "ui.flower.flowersend"
    
    local dlgSendFlower = FlowerSendDlg.getInstanceNotCreate()
    if dlgSendFlower then
        dlgSendFlower:RefreshPlayerNameSendTo(self.roleid, self.rolename)
    end
end

local sgiverosenew = require "protocoldef.knight.gsp.ranklist.sgiverosenew"
function sgiverosenew:process()
	require "ui.flower.flowerreceived"
    LogInfo("____sgiverosenew:process")
    
    FlowerReceivedDlg.AddFlowerReceiveInfo(self.senderroleid, self.rolename, self.rosenum)
end

local susexianhua = require "protocoldef.knight.gsp.ranklist.susexianhua"
function susexianhua:process()
    LogInfo("____susexianhua:process")
	require "ui.flower.flowersend"
    
    FlowerSendDlg.SetPlayerSendToAndShow(self.roleid, self.rolename)
end

local sthanksgiver = require "protocoldef.knight.gsp.ranklist.sthanksgiver"
function sthanksgiver:process()
    LogInfo("____sthanksgiver:process")
	require "ui.flower.flowerthanks"
    
    if self.thankstype == 1 then
        FlowerThanksDlg.AddFlowerThanksInfo(self.roleshape, self.rolename)
    end
end

local splayroseeffect = require "protocoldef.knight.gsp.ranklist.splayroseeffect"
function splayroseeffect:process()
    print("____splayroseeffect:process")
	require "ui.flower.flowereffect"
    
    if GetDataManager() and GetDataManager():GetMainCharacterLevel() > 20 then
        FlowerEffectDlg.AddFlowerEffectInfo(self.effectid)
    end
end

-- 排行榜查看功能
-- 这里都是从协议中的Table中浅拷贝的数据，请勿执行修改操作
local sranklevelinfo = require "protocoldef.knight.gsp.ranklist.getrankinfo.sranklevelinfo"
function sranklevelinfo:process()
    print("____sranklevelinfo:process")

    local RankLevelViewDlg = require "ui.rank.ranklevelviewdlg"
    RankLevelViewDlg.curData = self

    local dlg = RankLevelViewDlg.getInstanceAndShow()
    if dlg then
        dlg:RefreshView()
    end
end

local srankzongheinfo = require "protocoldef.knight.gsp.ranklist.getrankinfo.srankzongheinfo"
function srankzongheinfo:process()
    print("____srankzongheinfo:process")

    local RankZongheViewDlg = require "ui.rank.rankzongheviewdlg"
    RankZongheViewDlg.curData = self

    local dlg = RankZongheViewDlg.getInstanceAndShow()
    if dlg then
        dlg:RefreshView()
    end
end

local srankxiakeinfo = require "protocoldef.knight.gsp.ranklist.getrankinfo.srankxiakeinfo"
function srankxiakeinfo:process()
    print("____srankxiakeinfo:process")

    local RankXiakeViewDlg = require "ui.rank.rankxiakeviewdlg"
    RankXiakeViewDlg.curData = self

    local dlg = RankXiakeViewDlg.getInstanceAndShow()
    if dlg then
        dlg:RefreshView()
    end
end

local srankpetinfo = require "protocoldef.knight.gsp.ranklist.getrankinfo.srankpetinfo"
function srankpetinfo:process()
    print("____srankpetinfo:process")

    local RankPetViewDlg = require "ui.rank.rankpetviewdlg"
    RankPetViewDlg.curData = self

    local dlg = RankPetViewDlg.getInstanceAndShow()
    if dlg then
        dlg:RefreshView()
    end
end
-- End













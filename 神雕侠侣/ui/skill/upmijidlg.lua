-- upmijidlg.lua
-- It is a dialog for miji skill
-- create by wuyao in 2014-3-10
require "ui.dialog"
require "ui.skill.wulinmijimanager"
require "utils.mhsdutils"

UpMijiDlg = {}
setmetatable(UpMijiDlg, Dialog)
UpMijiDlg.__index = UpMijiDlg 

local CanjuanID = 39646

-- For singleton
local _instance
function UpMijiDlg.getInstance()
    if not _instance then
        _instance = UpMijiDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function UpMijiDlg.getInstanceAndShow()
    if not _instance then
        _instance = UpMijiDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end

    return _instance
end

function UpMijiDlg.getInstanceNotCreate()
    return _instance
end

function UpMijiDlg.DestroyDialog()
    if _instance then
        _instance:OnClose() 
        _instance = nil
    end
end

function UpMijiDlg.ToggleOpenClose()
    if not _instance then 
        _instance = UpMijiDlg:new() 
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function UpMijiDlg.GetLayoutFileName()
    return "wulinmijisecond.layout"
end

function UpMijiDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, UpMijiDlg)

    return self
end

function UpMijiDlg:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    self.WLMgr = WulinmijiManager.getInstance()

    self.m_txtTittle = winMgr:getWindow("wulinmijisecond/up/text0")
    self.m_txtContext = winMgr:getWindow("wulinmijisecond/up/text1")
    self.m_txtLevel = winMgr:getWindow("wulinmijisecond/up/logo/text")
    self.m_imgIcon = winMgr:getWindow("wulinmijisecond/up/logo/menpai")

    self.m_btnTupo = CEGUI.toPushButton(winMgr:getWindow("wulinmijisecond/up/button"))
    self.m_btnShengji = CEGUI.toPushButton(winMgr:getWindow("wulinmijisecond/button"))
    self.m_btnTupo:subscribeEvent("Clicked", UpMijiDlg.HandleTupoBtnClicked, self)
    self.m_btnShengji:subscribeEvent("Clicked", UpMijiDlg.HandleShengjiBtnClicked, self)

    self.m_rebStar = CEGUI.toRichEditbox(winMgr:getWindow("wulinmijisecond/up/star"))

    self.m_txtCurRateTitle = winMgr:getWindow("wulinmijisecond/bot0/text1")
    self.m_txtCurValueTitle = winMgr:getWindow("wulinmijisecond/bot0/text3")
    self.m_txtNextRateTitle = winMgr:getWindow("wulinmijisecond/bot1/text1")
    self.m_txtNextValueTitle = winMgr:getWindow("wulinmijisecond/bot1/text3")

    self.m_txtCurRate = winMgr:getWindow("wulinmijisecond/bot0/text2")
    self.m_txtCurValue = winMgr:getWindow("wulinmijisecond/bot0/text4")
    self.m_txtNextRate = winMgr:getWindow("wulinmijisecond/bot1/text2")
    self.m_txtNextValue = winMgr:getWindow("wulinmijisecond/bot1/text4")
    self.m_itemCost = CEGUI.toItemCell(winMgr:getWindow("wulinmijisecond/itemcell"))

    local itembean = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(CanjuanID)
    self.m_itemCost:SetImage(GetIconManager():GetItemIconByID(itembean.icon))

    self.m_itemCost:setID(CanjuanID)
    MHSD_UTILS.SetWindowShowtips(self.m_itemCost)

    self:RefreshView()
end

-- Refresh the view
-- @return : no return
function UpMijiDlg:RefreshView()
    -- Make data
    local mijiInfo = self.WLMgr:GetMijiInfo()
    local curRecord = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cwulinmijispecial"):getRecorder(mijiInfo.id)
    local curChong = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cwulinmijichongshu"):getRecorder(mijiInfo.floor)
    local nextRecord = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cwulinmijispecial"):getRecorder(curRecord.nextskillid)

    if nextRecord == nil then
        nextRecord = curRecord
    end

    -- Set top describe
    self.m_txtTittle:setText(curRecord.name)
    self.m_txtContext:setText(curRecord.describe)
    self.m_txtLevel:setText(curRecord.skillgrade)
    self.m_imgIcon:setProperty("Image", curRecord.icon)

    -- Set level describe
    local msg = nil
    if curRecord.probability ~= "0" then
        msg = curRecord.probability
        if curRecord.menpai == 17 then
            msg = string.gsub(msg, "%$parameter1%$", tostring(curRecord.Sprobability*curChong.promote))
        else
            msg = string.gsub(msg, "%$parameter1%$", tostring(curRecord.Sprobability*curChong.promote*0.01))
        end
        self.m_txtCurRate:setText(msg)
    else
        self.m_txtCurRate:setText("")
    end

    if curRecord.effect ~= "0" then
        msg = curRecord.effect
        msg = string.gsub(msg, "%$parameter1%$", tostring(curRecord.Seffect*curChong.promote))
        self.m_txtCurValue:setText(msg)
    else
        self.m_txtCurValue:setText("")
    end

    if nextRecord.probability ~= "0" then
        msg = nextRecord.probability
        if curRecord.menpai == 17 then
            msg = string.gsub(msg, "%$parameter1%$", tostring(curRecord.Sprobability*curChong.promote))
        else
            msg = string.gsub(msg, "%$parameter1%$", tostring(curRecord.Sprobability*curChong.promote*0.01))
        end
        self.m_txtNextRate:setText(msg)
    else
        self.m_txtNextRate:setText("")
    end    

    if nextRecord.effect ~= "0" then
        msg = nextRecord.effect
        msg = string.gsub(msg, "%$parameter1%$", tostring(nextRecord.Seffect*curChong.promote))
        self.m_txtNextValue:setText(msg)
    else
        self.m_txtNextValue:setText("")
    end


    self.m_txtCurRateTitle:setText(curRecord.describe1)
    self.m_txtCurValueTitle:setText(curRecord.describe2)

    self.m_txtNextRateTitle:setText(nextRecord.describe1)
    self.m_txtNextValueTitle:setText(nextRecord.describe2)

    -- Set need cell
    if curRecord.nextskillid > 0 then
        self.m_btnShengji:setEnabled(true)
        self.m_itemCost:SetTextUnit(tostring(nextRecord.needcj))
    else
        self.m_btnShengji:setEnabled(false)
    end

    -- Set stars
    self.m_rebStar:Clear()
    self.m_rebStar:SetEmotionScale(CEGUI.Vector2(0.6, 0.6))
    for i=1, mijiInfo.floor, 1 do
        self.m_rebStar:AppendEmotion(165)
    end
    for i=mijiInfo.floor+1, 8, 1 do
        self.m_rebStar:AppendEmotion(160)
    end
    self.m_rebStar:Refresh()
end

-- Callback of tupo button
-- @return : no return
function UpMijiDlg:HandleTupoBtnClicked(args)
    self.WLMgr:RequireMijiTupo()
end

-- Callback of shengji button
-- @return : no return
function UpMijiDlg:HandleShengjiBtnClicked(args)
    self.WLMgr:RequireMijiShengji()
end

return UpMijiDlg
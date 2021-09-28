-- wulinmijidlg.lua
-- It is a dialog for wulinmiji
-- create by wuyao in 2014-3-10
require "ui.dialog"
require "ui.skill.wulinmijimanager"
require "ui.skill.upmijidlg"
require "ui.skill.wulintipsdlg"
require "utils.mhsdutils"

-- data of this Dialog

WulinmijiDlg = {}

setmetatable(WulinmijiDlg, Dialog)
WulinmijiDlg.__index = WulinmijiDlg
local JingJieDianID = 39832

local BackgroundImage = {{imageset = "component14", image = "skillboxblue"},
                         {imageset = "component14", image = "skillboxpurple"},
                         {imageset = "component14", image = "skillboxorange"},
                         {imageset = "component14", image = "skillboxgoldon"},}

local JingjieImage = {[0] = "set:MainControl30 image:wujingjie",
                      [1] = "set:MainControl30 image:lianjinghuaqi",
                      [2] = "set:MainControl30 image:lianqihuashen",
                      [3] = "set:MainControl30 image:lianshenhuanxu",}

-- For singleton
local _instance;
function WulinmijiDlg.getInstance()
    if not _instance then
        _instance = WulinmijiDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function WulinmijiDlg.getInstanceAndShow()
    if not _instance then
        _instance = WulinmijiDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
        _instance.m_pMainFrame:setAlpha(1)
    end

    return _instance
end

function WulinmijiDlg.getInstanceNotCreate()
    return _instance
end

function WulinmijiDlg:OnClose()
    Dialog.OnClose(self)
    _instance = nil
end

function WulinmijiDlg.DestroyDialog()
    if _instance then
        if SkillLable.getInstanceNotCreate() then
            SkillLable.getInstanceNotCreate().DestroyDialog()
        else
            _instance:CloseDialog()
        end

    end
end

function WulinmijiDlg:CloseDialog()
    if _instance ~= nil then
        _instance:OnClose()
        _instance = nil
    end
end

function WulinmijiDlg.ToggleOpenClose()
    if not _instance then 
        _instance = WulinmijiDlg:new() 
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function WulinmijiDlg.GetLayoutFileName()
    return "wulinmiji.layout"
end

function WulinmijiDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, WulinmijiDlg)

    return self
end

function WulinmijiDlg:OnCreate()

    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    self.WLMgr = WulinmijiManager.getInstance()

    -- Left

    self.m_iSelectPos = 1
    self.m_vSkillBox = {}
    self.m_vSkillLine = {}
    for i=1, 10, 1 do
        self.m_vSkillBox[i] = {}
        self.m_vSkillBox[i].wnd = CEGUI.toSkillBox(winMgr:getWindow("wulinmiji/statictext/left/skillbox" .. tostring(i-1)))
        self.m_vSkillBox[i].num = winMgr:getWindow("wulinmiji/statictext/left/skillbox" .. tostring(i-1) .. "/image/text")
        self.m_vSkillBox[i].flag = winMgr:getWindow("wulinmiji/statictext/left/kuang" .. tostring(i-1))

        self.m_vSkillBox[i].wnd:setUserString("index", tostring(i))
        self.m_vSkillBox[i].wnd:subscribeEvent("SKillBoxClick", WulinmijiDlg.HandleSkillboxClicked, self)
    end

    for i=2, 10, 1 do
        self.m_vSkillLine[i] = winMgr:getWindow("wulinmiji/statictext/left/lineimage" .. tostring(i))
    end

    self.m_btnJingjie = CEGUI.toPushButton(winMgr:getWindow("wulinmiji/statictext/left/imagebutton"))
    self.m_btnChong = CEGUI.toPushButton(winMgr:getWindow("wulinmiji/statictext/left/imagebutton1"))
    self.m_btnChong:subscribeEvent("Clicked", WulinmijiDlg.HandleChongButtonClicked, self)
    self.m_btnJingjie:subscribeEvent("Clicked", WulinmijiDlg.HandleJingjieButtonClicked, self)

    -- Right
    self.m_iStepAdd = 10
    self.m_txtTitle = winMgr:getWindow("wulinmiji/statictext/right/bot/title/name0/text")
    self.m_txtDescribe = winMgr:getWindow("wulinmiji/statictext/right/info/text")
    self.m_txtCurLevel = winMgr:getWindow("wulinmiji/statictext/right/text/text")
    self.m_txtNextLevel = winMgr:getWindow("wulinmiji/statictext/right/text1/text")
    self.m_txtCurAddNum = winMgr:getWindow("wulinmiji/statictext/right/text2")
    self.m_txtNextAddNum = winMgr:getWindow("wulinmiji/statictext/right/text3")
    self.m_pbProgress = CEGUI.toProgressBar(winMgr:getWindow("wulinmiji/statictext/right/commoncase/bot/progress"))
    self.m_txtCurStep = winMgr:getWindow("wulinmiji/statictext/right/commoncase/bot/text4")
    self.m_txtLeftPoint = winMgr:getWindow("wulinmiji/statictext/right/downtext1")
    self.m_btnAdd = winMgr:getWindow("wulinmiji/statictext/right/commoncase/bot/add")
    self.m_btnReduction = winMgr:getWindow("wulinmiji/statictext/right/commoncase/bot/reduction")
    self.m_btnStudy = winMgr:getWindow("wulinmiji/statictext/right/button")
    self.m_itemCost = CEGUI.toItemCell(winMgr:getWindow("wulinmiji/statictext/right/commoncase/item0"))

    self.m_btnAdd:subscribeEvent("Clicked", WulinmijiDlg.HandleAddStepClicked, self)
    self.m_btnReduction:subscribeEvent("Clicked", WulinmijiDlg.HandleReductionStepClicked, self)
    self.m_btnStudy:subscribeEvent("Clicked", WulinmijiDlg.HandleStudyButtonClicked, self)

    self:RefreshLeftView()
    self:RefreshRightView()

end

-- Init skillboxes from WulinmijiManager
-- return : no return
function WulinmijiDlg:RefreshLeftView()
    local winMgr = CEGUI.WindowManager:getSingleton()
    local integralSum = 0
    local skillTable = self.WLMgr:GetSkillTable()
    if skillTable ~= nil then
        for i=1, 10, 1 do
            local curRecord = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cwulinmijiskill"):getRecorder(skillTable[i].id)
            self.m_vSkillBox[i].wnd:SetBackgroundDynamic(true)
            self.m_vSkillBox[i].wnd:SetBackGroundImage(CEGUI.String(BackgroundImage[curRecord.color].imageset), CEGUI.String(BackgroundImage[curRecord.color].image))
            self.m_vSkillBox[i].wnd:SetImage(GetIconManager():GetImageByID(curRecord.icon))
            self.m_vSkillBox[i].num:setText(tostring(curRecord.skilllevel))
            integralSum = integralSum + curRecord.integral
        end
    end

    if skillTable ~= nil then
        for i=1, 10, 1 do
            self.m_vSkillBox[i].wnd:SetAshy(false)
            local curRecord = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cwulinmijiskill"):getRecorder(skillTable[i].id)
            if curRecord.needintegral > integralSum then
                self.m_vSkillBox[i].wnd:SetAshy(true)
            end
        end
    end

    -- for i=1, 10 ,1 do
    --     self.m_vSkillBox[i].wnd:SetSelected(false)
    -- end

    -- self.m_vSkillBox[self.m_iSelectPos].wnd:SetSelected(true)

    self.m_btnChong:setProperty("HoverImage", "set:MainControl30 image:chongshu" .. self.WLMgr:GetMijiInfo().floor)
    self.m_btnChong:setProperty("NormalImage", "set:MainControl30 image:chongshu" .. self.WLMgr:GetMijiInfo().floor)
    self.m_btnChong:setProperty("PushedImage", "set:MainControl30 image:chongshu" .. self.WLMgr:GetMijiInfo().floor)
    self.m_btnChong:setProperty("DisabledImage", "set:MainControl30 image:chongshu" .. self.WLMgr:GetMijiInfo().floor)

    self.m_btnJingjie:setProperty("HoverImage", JingjieImage[self.WLMgr:GetJingjie()])
    self.m_btnJingjie:setProperty("NormalImage", JingjieImage[self.WLMgr:GetJingjie()])
    self.m_btnJingjie:setProperty("PushedImage", JingjieImage[self.WLMgr:GetJingjie()])
    self.m_btnJingjie:setProperty("DisabledImage", JingjieImage[self.WLMgr:GetJingjie()])


    for i=1, 10, 1 do
        if i == self.m_iSelectPos then
            self.m_vSkillBox[i].flag:setVisible(true)
        else
            self.m_vSkillBox[i].flag:setVisible(false)
        end
    end
end

-- Refresh Info with select skill
-- return : no return
function WulinmijiDlg:RefreshRightView()
    local winMgr = CEGUI.WindowManager:getSingleton()
    local skillTable = self.WLMgr:GetSkillTable()
    local curRecord = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cwulinmijiskill"):getRecorder(skillTable[self.m_iSelectPos].id)
    local nextLevelRecord = nil
    if curRecord.nextskillid > 0 then
        nextLevelRecord = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cwulinmijiskill"):getRecorder(curRecord.nextskillid)
    else
        nextLevelRecord = curRecord
    end
    self.m_txtTitle:setText(curRecord.skillname)
    self.m_txtDescribe:setText(curRecord.describe)
    self.m_txtCurLevel:setText(curRecord.skilllevel)
    self.m_txtNextLevel:setText(nextLevelRecord.skilllevel)
    self.m_txtCurAddNum:setText(curRecord.number)
    self.m_txtNextAddNum:setText(nextLevelRecord.number)
    self.m_pbProgress:setText(skillTable[self.m_iSelectPos].curPoint .. "/" .. nextLevelRecord.needjjd)
    if nextLevelRecord.needjjd > 0 then
        self.m_pbProgress:setProgress(skillTable[self.m_iSelectPos].curPoint/nextLevelRecord.needjjd)
    else
        self.m_pbProgress:setProgress(0)
    end
    self.m_txtCurStep:setText(self.m_iStepAdd)
    self.m_txtLeftPoint:setText(self.WLMgr:GetCurPoint())

    if curRecord.nextskillid > 0 then
        self.m_btnStudy:setEnabled(true)
    else
        self.m_btnStudy:setEnabled(false)
    end

    local itembean = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(JingJieDianID)
    self.m_itemCost:SetImage(GetIconManager():GetItemIconByID(itembean.icon))
    self.m_itemCost:setID(JingJieDianID)
    MHSD_UTILS.SetWindowShowtips(self.m_itemCost)

end

-- Callback of left skill boxes, change selected skill and refresh right view
-- @return : no return
function WulinmijiDlg:HandleSkillboxClicked(args)
    local e = CEGUI.toWindowEventArgs(args)
    local index = e.window:getUserString("index")
    
    self.m_iSelectPos = tonumber(index)
    self:RefreshRightView()
    self:RefreshLeftView()
end

-- Callback of add button
-- @return : no return
function WulinmijiDlg:HandleAddStepClicked(args)
    if self.m_iStepAdd < 100 then 
        self.m_iStepAdd = self.m_iStepAdd + 10
    else
        self.m_iStepAdd = self.m_iStepAdd + 100
    end

    if self.m_iStepAdd < 10 then
        self.m_iStepAdd = 10
    elseif self.m_iStepAdd > 1000 then
        self.m_iStepAdd = 1000
    end

    self:RefreshRightView()
end

-- Callback of reduction button
-- @return : no return
function WulinmijiDlg:HandleReductionStepClicked(args)
    if self.m_iStepAdd <= 100 then 
        self.m_iStepAdd = self.m_iStepAdd - 10
    else
        self.m_iStepAdd = self.m_iStepAdd - 100
    end

    if self.m_iStepAdd < 10 then
        self.m_iStepAdd = 10
    elseif self.m_iStepAdd > 1000 then
        self.m_iStepAdd = 1000
    end

    self:RefreshRightView()
end

-- Callback of study button
-- @return : no return
function WulinmijiDlg:HandleStudyButtonClicked(args)
    local skillTable = self.WLMgr:GetSkillTable()
    local curRecord = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cwulinmijiskill"):getRecorder(skillTable[self.m_iSelectPos].id)
    local point = self.m_iStepAdd
    local skillid = skillTable[self.m_iSelectPos].id
    self.WLMgr:RequireStudy(skillid, point)
end

-- Callback of miji button
-- @return : no return
function WulinmijiDlg:HandleChongButtonClicked(args)
    UpMijiDlg.getInstanceAndShow()
end

-- Callback of jingjie button
-- @return : no return
function WulinmijiDlg:HandleJingjieButtonClicked(args)
    WulinTipsDlg.getInstanceAndShow()
end

return WulinmijiDlg
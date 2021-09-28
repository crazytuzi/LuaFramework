local Dialog = require "ui.dialog"
local MHSD_UTILS = require "utils.mhsdutils"
local TableUtil = require "utils.tableutil"

local RankPetViewDlg = {}
setmetatable(RankPetViewDlg, Dialog)
RankPetViewDlg.__index = RankPetViewDlg

RankPetViewDlg.curData = nil

local _instance
function RankPetViewDlg.getInstance()
    if not _instance then
        _instance = RankPetViewDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function RankPetViewDlg.getInstanceAndShow()
    if not _instance then
        _instance = RankPetViewDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end

    return _instance
end

function RankPetViewDlg.getInstanceNotCreate()
    return _instance
end

function RankPetViewDlg.DestroyDialog()
    RankPetViewDlg.curData = nil
    if _instance then
        _instance:OnClose() 
        _instance = nil
    end
end

function RankPetViewDlg.ToggleOpenClose()
    if not _instance then 
        _instance = RankPetViewDlg:new() 
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function RankPetViewDlg.GetLayoutFileName()
    return "listchognwuview.layout"
end

function RankPetViewDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, RankPetViewDlg)

    return self
end

function RankPetViewDlg:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()

    self.SpriteWnd = winMgr:getWindow("listchongwuview/StarBack")
    self.spMoreList = CEGUI.toScrollablePane(winMgr:getWindow("listchongwuview/info"))

    self.txtDiyName = winMgr:getWindow("listchongwuview/life3")
    self.txtPetName = winMgr:getWindow("listchongwuview/life1")
    self.txtScore = winMgr:getWindow("listchongwuview/life2")
    self.txtType = winMgr:getWindow("listchongwuview/life")
    self.txtRank = winMgr:getWindow("listchongwuview/rank/text")

    self.ebStar = CEGUI.toRichEditbox(winMgr:getWindow("listchongwuview/StarBack/back"))
    self.ebStar:SetEmotionScale(CEGUI.Vector2(0.4, 0.4))
end

function RankPetViewDlg:RefreshView()
    if RankPetViewDlg.curData == nil then
        LogErr("RankPetViewDlg.curData is nil in RankPetViewDlg:RefreshView")
        return
    end

    local winMgr = CEGUI.WindowManager:getSingleton()

    local petRecord = knight.gsp.pet.GetCPetAttrTableInstance():getRecorder(RankPetViewDlg.curData.petid)

    -- 界面上固定显示的信息

    self.txtDiyName:setText(tostring(RankPetViewDlg.curData.petname))
    self.txtPetName:setText(tostring(petRecord.name))
    self.txtScore:setText(tostring(RankPetViewDlg.curData.petscore))
    self.txtType:setText(tostring(petRecord.chengzhangleixing))
    self.txtRank:setText(tostring(RankPetViewDlg.curData.rank+1))

    local wndHeight = self.SpriteWnd:getPixelSize().height
    local wndWidth = self.SpriteWnd:getPixelSize().width

    local PetSprite = GetGameUIManager():AddWindowSprite(self.SpriteWnd, petRecord.modelid, XiaoPang.XPDIR_BOTTOMRIGHT, wndWidth/2.0, wndHeight-20, false)
    PetSprite:SetUIScale(0.7)

    local petStarConfig = knight.gsp.pet.GetCPetstarsTableInstance():getRecorder(RankPetViewDlg.curData.starid )
    local stars = petStarConfig.stars 
    self.ebStar:Clear()
    for i = 7,0,-1 do
        local starLevel = stars % (10 ^(i + 1)) / (10 ^ i)
        if starLevel > 0 then
            self.ebStar:AppendEmotion(149 + starLevel)
        end
    end
    self.ebStar:Refresh()

    -- 下方的滑动信息

    self.spMoreList:cleanupNonAutoChildren()
    local height = 1

        -- 生命和真气

        local wndHpMp = winMgr:loadWindowLayout("listchongwucell1.layout")

        local txtHp = winMgr:getWindow("listchongwucell1/shengming/text")
        local txtMp = winMgr:getWindow("listchongwucell1/zhenqi/text")

        self.spMoreList:addChildWindow(wndHpMp)
        wndHpMp:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0,1.0),CEGUI.UDim(0.0,height)))
        height = height + wndHpMp:getPixelSize().height + 5

        txtHp:setText(tostring(RankPetViewDlg.curData.maxhp))
        txtMp:setText(tostring(RankPetViewDlg.curData.maxmp))

        -- 主要属性及资质

        local wndPetMain = winMgr:loadWindowLayout("listchongwucell2.layout")

        local txtAttackApt = winMgr:getWindow("listchongwucell2/attackText/text")
        local txtDefendApt = winMgr:getWindow("listchongwucell2/attackText1/text")
        local txtPhyforceApt = winMgr:getWindow("listchongwucell2/attackText2/text")
        local txtMagicApt = winMgr:getWindow("listchongwucell2/attackText3/text")
        local txtSpeedApt = winMgr:getWindow("listchongwucell2/attackText4/text")
        local txtAttack = winMgr:getWindow("listchongwucell2/attackText5/text")
        local txtMagic = winMgr:getWindow("listchongwucell2/attackText6/text")
        local txtDefend = winMgr:getWindow("listchongwucell2/attackText7/text")
        local txtMacicDefend = winMgr:getWindow("listchongwucell2/attackText8/text")
        local txtSpeed = winMgr:getWindow("listchongwucell2/attackText9/text")

        self.spMoreList:addChildWindow(wndPetMain)
        wndPetMain:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0,1.0),CEGUI.UDim(0.0,height)))
        height = height + wndPetMain:getPixelSize().height + 5

        txtAttackApt:setText(tostring(RankPetViewDlg.curData.attackapt))
        txtDefendApt:setText(tostring(RankPetViewDlg.curData.defendapt))
        txtPhyforceApt:setText(tostring(RankPetViewDlg.curData.phyforceapt))
        txtMagicApt:setText(tostring(RankPetViewDlg.curData.magicapt))
        txtSpeedApt:setText(tostring(RankPetViewDlg.curData.speedapt))
        txtAttack:setText(tostring(RankPetViewDlg.curData.attack))
        txtMagic:setText(tostring(RankPetViewDlg.curData.magicattack))
        txtDefend:setText(tostring(RankPetViewDlg.curData.defend))
        txtMacicDefend:setText(tostring(RankPetViewDlg.curData.magicdef))
        txtSpeed:setText(tostring(RankPetViewDlg.curData.speed))

        -- 宠物技能

        if TableUtil.tablelength(RankPetViewDlg.curData.skills) > 0 then

            -- 宠物技能标签

            local wndSkillLabel = winMgr:loadWindowLayout("listline.layout", "rankviewpet01")

            local txtSkillLabel =  winMgr:getWindow("rankviewpet01" .. "listline/pic")

            self.spMoreList:addChildWindow(wndSkillLabel)
            wndSkillLabel:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0,1.0),CEGUI.UDim(0.0,height)))
            height = height + wndSkillLabel:getPixelSize().height + 5

            txtSkillLabel:setText(tostring(MHSD_UTILS.get_resstring(3162)))

            -- 宠物技能细节

            local skillIndex = 0
            for k, curSkillID in pairs(RankPetViewDlg.curData.skills) do
                skillIndex = skillIndex + 1
                local curSkillInfo = knight.gsp.skill.GetCPetSkillConfigTableInstance():getRecorder(curSkillID)
                local wndSkill = winMgr:loadWindowLayout("listchongwucell3.layout", tostring(skillIndex))
                self.spMoreList:addChildWindow(wndSkill)
                if skillIndex%2 == 1 then
                    wndSkill:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0,1.0),CEGUI.UDim(0.0,height)))
                    if skillIndex >= TableUtil.tablelength(RankPetViewDlg.curData.skills) then
                        height = height + wndSkill:getPixelSize().height + 5
                    end
                else
                    wndSkill:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0,1.0+wndSkill:getPixelSize().width),CEGUI.UDim(0.0,height)))
                    height = height + wndSkill:getPixelSize().height + 5
                end


                local txtSkillName = winMgr:getWindow(tostring(skillIndex) .. "listchongwucell3/skill1")

                txtSkillName:setText(tostring(curSkillInfo.skillname))
            end
        end

        -- 宠物护符

        if TableUtil.tablelength(RankPetViewDlg.curData.petamulets) > 0 then

            -- 宠物护符标签

            local wndHufuLabel = winMgr:loadWindowLayout("listline.layout", "rankviewpet02")

            local txtHufuLabel =  winMgr:getWindow("rankviewpet02" .. "listline/pic")

            self.spMoreList:addChildWindow(wndHufuLabel)
            wndHufuLabel:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0,1.0),CEGUI.UDim(0.0,height)))
            height = height + wndHufuLabel:getPixelSize().height + 5

            txtHufuLabel:setText(tostring(MHSD_UTILS.get_resstring(3164)))

            -- 宠物护符细节

            local hufuIndex = 0
            for k, curHufuID in pairs(RankPetViewDlg.curData.petamulets) do
                hufuIndex = hufuIndex + 1
                local curHufuInfo = BeanConfigManager.getInstance():GetTableByName("knight.gsp.item.cpetamulet"):getRecorder(curHufuID)
                local wndHufu = winMgr:loadWindowLayout("listchongwucell4.layout", tostring(hufuIndex))
                self.spMoreList:addChildWindow(wndHufu)
                if hufuIndex%2 == 1 then
                    wndHufu:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0,1.0),CEGUI.UDim(0.0,height)))
                    if hufuIndex >= TableUtil.tablelength(RankPetViewDlg.curData.petamulets) then
                        height = height + wndHufu:getPixelSize().height + 5
                    end
                else
                    wndHufu:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0,1.0+wndHufu:getPixelSize().width),CEGUI.UDim(0.0,height)))
                    height = height + wndHufu:getPixelSize().height + 5
                end


                local txtHufuName = winMgr:getWindow(tostring(hufuIndex) .. "listchongwucell4/skill1")

                txtHufuName:setText(tostring(curHufuInfo.amuletname))
            end
        end

        -- 宠物雕文

        if TableUtil.tablelength(RankPetViewDlg.curData.petdiaowen) > 0 then

            -- 宠物雕文标签

            local wndDiaowenLabel = winMgr:loadWindowLayout("listline.layout", "rankviewpet03")

            local txtDiaowenLabel =  winMgr:getWindow("rankviewpet03" .. "listline/pic")

            self.spMoreList:addChildWindow(wndDiaowenLabel)
            wndDiaowenLabel:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0,1.0),CEGUI.UDim(0.0,height)))
            height = height + wndDiaowenLabel:getPixelSize().height + 5

            txtDiaowenLabel:setText(tostring(MHSD_UTILS.get_resstring(3165)))

            -- 宠物雕文细节

            local DiaowenIndex = 0
            for curDiaowenID, curDiaowenNum in pairs(RankPetViewDlg.curData.petdiaowen) do
                DiaowenIndex = DiaowenIndex + 1
                local curDiaowenInfo = BeanConfigManager.getInstance():GetTableByName("knight.gsp.item.cpetglyoh"):getRecorder(curDiaowenID)
                local wndDiaowen = winMgr:loadWindowLayout("listchongwucell5.layout", tostring(DiaowenIndex))
                self.spMoreList:addChildWindow(wndDiaowen)
                if DiaowenIndex%2 == 1 then
                    wndDiaowen:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0,1.0),CEGUI.UDim(0.0,height)))
                    if DiaowenIndex >= TableUtil.tablelength(RankPetViewDlg.curData.petdiaowen) then
                        height = height + wndDiaowen:getPixelSize().height + 5
                    end
                else
                    wndDiaowen:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0,1.0+wndDiaowen:getPixelSize().width),CEGUI.UDim(0.0,height)))
                    height = height + wndDiaowen:getPixelSize().height + 5
                end


                local txtDiaowenName = winMgr:getWindow(tostring(DiaowenIndex) .. "listchongwucell5/skill1")

                txtDiaowenName:setText(tostring(curDiaowenInfo.name) .. "(" .. tostring(curDiaowenNum) .. "/" .. tostring(curDiaowenInfo.num) .. ")")
            end
        end

    -- 下方滑动信息 end
end

return RankPetViewDlg
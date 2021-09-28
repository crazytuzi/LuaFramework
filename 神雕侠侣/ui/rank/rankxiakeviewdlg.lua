local Dialog = require "ui.dialog"
local MHSD_UTILS = require "utils.mhsdutils"
local TableUtil = require "utils.tableutil"

local RankXiakeViewDlg = {}
setmetatable(RankXiakeViewDlg, Dialog)
RankXiakeViewDlg.__index = RankXiakeViewDlg

RankXiakeViewDlg.curData = nil 

local XiakeColor = {"set:MainControl12 image:NPCbackwhite",
                    "set:MainControl12 image:NPCbackgreen",
                    "set:MainControl12 image:NPCbackblue",
                    "set:MainControl12 image:NPCbackpurple",
                    "set:MainControl12 image:NPCbackorange",
                    "set:MainControl12 image:NPCbackgold",
                    "set:MainControl7 image:NPCbackpink",
                    "set:MainControl7 image:NPCbackred",
                    }

local _instance
function RankXiakeViewDlg.getInstance()
    if not _instance then
        _instance = RankXiakeViewDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function RankXiakeViewDlg.getInstanceAndShow()
    if not _instance then
        _instance = RankXiakeViewDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end

    return _instance
end

function RankXiakeViewDlg.getInstanceNotCreate()
    return _instance
end

function RankXiakeViewDlg.DestroyDialog()
    RankXiakeViewDlg.curData = nil 
    if _instance then
        _instance:OnClose() 
        _instance = nil
    end
end

function RankXiakeViewDlg.ToggleOpenClose()
    if not _instance then 
        _instance = RankXiakeViewDlg:new() 
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function RankXiakeViewDlg.GetLayoutFileName()
    return "listxiakeview.layout"
end

function RankXiakeViewDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, RankXiakeViewDlg)

    return self
end

function RankXiakeViewDlg:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()

    -- 界面中部的侠客数据

    self.txtHealthTitle = winMgr:getWindow("listxiakeview/right/txt0")
    self.txtAttackTitle = winMgr:getWindow("listxiakeview/right/txt1")
    self.txtDefendTitle = winMgr:getWindow("listxiakeview/right/txt2")
    self.txtMagicDefendTitle = winMgr:getWindow("listxiakeview/right/txt3")
    self.txtSpeedTitle = winMgr:getWindow("listxiakeview/right/txt4")

    self.txtHealth = winMgr:getWindow("listxiakeview/right/num")
    self.txtAttack = winMgr:getWindow("listxiakeview/right/num1")
    self.txtDefend = winMgr:getWindow("listxiakeview/right/num2")
    self.txtMagicDefend = winMgr:getWindow("listxiakeview/right/num3")
    self.txtSpeed = winMgr:getWindow("listxiakeview/right/num4")

    self.vStar = {}
    for i = 1, 5, 1 do
        self.vStar[i] = CEGUI.Window.toRichEditbox(winMgr:getWindow("listxiakeview/right/txt/box" .. (i-1)))
    end

    -- 界面中部的侠客头像

    self.imgBack = winMgr:getWindow("listxiakeview/right/role")
    self.imgIcon = winMgr:getWindow("listxiakeview/right/role/icon")
    self.imgIcon:setMousePassThroughEnabled(true)
    self.imgStar = winMgr:getWindow("listxiakeview/right/role/mark")
    self.imgStar:setMousePassThroughEnabled(true)
    self.txtLevel = winMgr:getWindow("listxiakeview/right/role/level")
    self.txtLevel:setMousePassThroughEnabled(true)
    self.txtName = winMgr:getWindow("listxiakeview/right/role/name")
    self.txtName:setMousePassThroughEnabled(true)
    self.imgElite = winMgr:getWindow("listxiakeview/right/role/elite")
    self.imgElite:setMousePassThroughEnabled(true)

    -- 侠客缘和侠客技能面板

    self.spMoreList = CEGUI.toScrollablePane(winMgr:getWindow("listxiakeview/scrollpane"))

    -- 界面上方的四个侠客头像

    self.vCell = {}
    for i=1, 4, 1 do
        self.vCell[i] = {}
        self.vCell[i].icon = winMgr:getWindow("listxiakeview/right/role/icon" .. tostring(i))
        self.vCell[i].icon:setMousePassThroughEnabled(true)
        self.vCell[i].level = winMgr:getWindow("listxiakeview/right/role/level" .. tostring(i))
        self.vCell[i].level:setMousePassThroughEnabled(true)
        self.vCell[i].star = winMgr:getWindow("listxiakeview/right/role/mark" .. tostring(i))
        self.vCell[i].star:setMousePassThroughEnabled(true)
        self.vCell[i].elite = winMgr:getWindow("listxiakeview/right/role/elite" .. tostring(i))
        self.vCell[i].elite:setMousePassThroughEnabled(true)
        self.vCell[i].name = winMgr:getWindow("listxiakeview/right/role/name" .. tostring(i))
        self.vCell[i].name:setMousePassThroughEnabled(true)
        self.vCell[i].back = winMgr:getWindow("listxiakeview/right/role" .. tostring(i))
    end
    self.vCell[1].back:subscribeEvent("MouseButtonUp", RankXiakeViewDlg.HandleCell1Clicked, self)
    self.vCell[2].back:subscribeEvent("MouseButtonUp", RankXiakeViewDlg.HandleCell2Clicked, self)
    self.vCell[3].back:subscribeEvent("MouseButtonUp", RankXiakeViewDlg.HandleCell3Clicked, self)
    self.vCell[4].back:subscribeEvent("MouseButtonUp", RankXiakeViewDlg.HandleCell4Clicked, self)

    -- 侠客排名

    self.txtRank = winMgr:getWindow("listxiakeview/rank/text")
end

function RankXiakeViewDlg:HandleCell1Clicked(args)
    self:SetCurXiake(1)
end

function RankXiakeViewDlg:HandleCell2Clicked(args)
    self:SetCurXiake(2)
end

function RankXiakeViewDlg:HandleCell3Clicked(args)
    self:SetCurXiake(3)
end

function RankXiakeViewDlg:HandleCell4Clicked(args)
    self:SetCurXiake(4)
end

function RankXiakeViewDlg:RefreshView()
    if RankXiakeViewDlg.curData == nil then
        LogErr("RankXiakeViewDlg.curData is nil in RankXiakeViewDlg:RefreshView")
        return
    end

    -- 设置排名

    self.txtRank:setText(tostring(RankXiakeViewDlg.curData.rank+1))

    -- 设置界面上方的四个侠客头像

    for i=1, 4, 1 do
        local curXiakeData = RankXiakeViewDlg.curData.xiakeinfo[i] -- 协议中数据
        if curXiakeData then
            local curXiakeInfo = knight.gsp.npc.GetCXiakexinxiTableInstance():getRecorder(curXiakeData.xiakeid) -- 侠客信息配置表
            local curXiakeMonster = knight.gsp.npc.GetCMonsterConfigTableInstance():getRecorder(curXiakeData.xiakeid) -- 头像用得配置表

            self.vCell[i].back:setVisible(true)
            self.vCell[i].back:setProperty("Image", XiakeColor[curXiakeData.color])

            local color = require "utils.scene_common".GetPetNameColor(curXiakeData.color)
            self.vCell[i].name:setText(color .. curXiakeInfo.name)

            local shape= knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(curXiakeMonster.modelID)
            local path = GetIconManager():GetImagePathByID(shape.headID):c_str()
            self.vCell[i].icon:setProperty("Image", path)

            self.vCell[i].level:setText(tostring(curXiakeData.level))

            if curXiakeData.starlv > 0 then
                self.vCell[i].star:setVisible(true)
                self.vCell[i].star:setProperty("Image", "set:MainControl7 image:NPCLevel" .. tostring(curXiakeData.starlv))
            else
                self.vCell[i].star:setVisible(false)
            end

            if curXiakeData.elite == 1 then
                self.vCell[i].elite:setVisible(true)
            else
                self.vCell[i].elite:setVisible(false)
            end
        else
            self.vCell[i].back:setVisible(false)
        end
    end

    -- 设置下方被选中的侠客

    if RankXiakeViewDlg.curData.xiakeinfo[1] then
        -- 有侠客时设置为第一个侠客
        self:SetCurXiake(1)
    else
        -- 没有侠客时隐藏下方界面
        self:SetCurXiake(0)
    end
end

function RankXiakeViewDlg:SetCurXiake(index)
    if index >= 1 and index <= 4 then 
        if RankXiakeViewDlg.curData == nil then
            LogErr("RankXiakeViewDlg.curData is nil in RankXiakeViewDlg:SetCurXiake")
            return
        end

        local winMgr = CEGUI.WindowManager:getSingleton()

        -- 设置当前侠客信息的显示
        -- string.format("%d", curXiakeData.xxxx)
        -- 四舍五入时0.5会被舍掉，侠客面板这么写的

        local curXiakeData = RankXiakeViewDlg.curData.xiakeinfo[index] -- 协议中数据
        local curXiakeInfo = knight.gsp.npc.GetCXiakexinxiTableInstance():getRecorder(curXiakeData.xiakeid) -- 配置表中数据
        local curXiakeMonster = knight.gsp.npc.GetCMonsterConfigTableInstance():getRecorder(curXiakeData.xiakeid) -- 头像用的配置表
        self.txtHealth:setVisible(true)
        self.txtHealth:setText(tostring(string.format("%d", curXiakeData.maxhp)))
        self.txtSpeed:setVisible(true)
        self.txtSpeed:setText(tostring(string.format("%d", curXiakeData.speed)))
        self.txtDefend:setVisible(true)
        self.txtDefend:setText(tostring(string.format("%d", curXiakeData.defend)))
        self.txtMagicDefend:setVisible(true)
        self.txtMagicDefend:setText(tostring(string.format("%d", curXiakeData.magicdef)))

        self.txtHealthTitle:setVisible(true)
        self.txtAttackTitle:setVisible(true)
        self.txtSpeed:setVisible(true)
        self.txtDefendTitle:setVisible(true)
        self.txtMagicDefendTitle:setVisible(true)

        -- 伤害分内功和外功

		self.txtAttack:setVisible(true)

        if curXiakeInfo.waigong == 1 then
			self.txtAttackTitle:setText(MHSD_UTILS.get_resstring(2751)..":")
            self.txtAttack:setText(tostring(string.format("%d", curXiakeData.attack)))
		else
			self.txtAttackTitle:setText(MHSD_UTILS.get_resstring(2750)..":")
            self.txtAttack:setText(tostring(string.format("%d", curXiakeData.magicattack)))
		end

		-- 侠客星级

        for i = 1, 5, 1 do
            self.vStar[i]:Clear()
            self.vStar[i]:SetEmotionScale(CEGUI.Vector2(0.4, 0.4))
            -- 伤害星级分内功和外功，只显示一种
            local k = i
            if i >= 3 then
            	k = k+1
            elseif k == 2 then -- 伤害星级分内功和外功，只显示一种
            	if curXiakeInfo.waigong == 1 then
            		k = 2 -- 外功
            	else
            		k = 3 -- 内功
            	end
            end


            local curProp = curXiakeData.cgprops.props[k]
            if curProp and curProp.star and curProp.color >= 1 and curProp.color <= 7 then
                for j = 1, curProp.star, 1 do
                    self.vStar[i]:AppendEmotion(150 + curProp.color)
                end
            end
            self.vStar[i]:Refresh()
        end

        -- 设置当前侠客头像的显示

        self.imgBack:setVisible(true)
        self.imgBack:setProperty("Image", XiakeColor[curXiakeData.color])

        local color = require "utils.scene_common".GetPetNameColor(curXiakeData.color)
        self.txtName:setText(color .. curXiakeInfo.name)

        local shape= knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(curXiakeMonster.modelID)
        local path = GetIconManager():GetImagePathByID(shape.headID):c_str()
        self.imgIcon:setProperty("Image", path)

        self.txtLevel:setText(tostring(curXiakeData.level))

        if curXiakeData.starlv > 0 then
            self.imgStar:setVisible(true)
            self.imgStar:setProperty("Image", "set:MainControl7 image:NPCLevel" .. tostring(curXiakeData.starlv))
        else
            self.imgStar:setVisible(false)
        end

        if curXiakeData.elite == 1 then
            self.imgElite:setVisible(true)
        else
            self.imgElite:setVisible(false)
        end

        -- 下方滑动信息

        self.spMoreList:cleanupNonAutoChildren()
        local height = 1.0

            -- 侠客缘

            if  TableUtil.tablelength(curXiakeData.yuanids) > 0 then

                -- 标签

                local wndYuanLabel = winMgr:loadWindowLayout("listline.layout", "rankviewxiake01")

                local txtYuanLabel =  winMgr:getWindow("rankviewxiake01" .. "listline/pic")

                self.spMoreList:addChildWindow(wndYuanLabel)
                wndYuanLabel:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0,1.0),CEGUI.UDim(0.0,height)))
                height = height + wndYuanLabel:getPixelSize().height + 5

                txtYuanLabel:setText(tostring(MHSD_UTILS.get_resstring(3163)))

                -- 侠客缘细节

                local yuanIndex = 0
                for k, curYuanID in pairs(curXiakeData.yuanids) do
                    yuanIndex = yuanIndex + 1
                    local curYuanInfo = knight.gsp.npc.GetCXiakeyuanTableInstance():getRecorder(curYuanID)
                    local wndYuan = winMgr:loadWindowLayout("listxiakecell1.layout", tostring(yuanIndex))
                    self.spMoreList:addChildWindow(wndYuan)
                    wndYuan:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0,1.0),CEGUI.UDim(0.0,height)))
                    height = height + wndYuan:getPixelSize().height + 5


                    local txtYuanContext = winMgr:getWindow(tostring(yuanIndex) .. "listxiakecell1/kuangkuang1")

                    txtYuanContext:setText(tostring(curYuanInfo.des))
                end

            end

            -- 侠客技能

            if  TableUtil.tablelength(curXiakeData.skills) > 0 then

                -- 侠客技能标签

                local wndSkillLabel = winMgr:loadWindowLayout("listline.layout", "rankviewxiake02")

                local txtSkillLabel =  winMgr:getWindow("rankviewxiake02" .. "listline/pic")

                self.spMoreList:addChildWindow(wndSkillLabel)
                wndSkillLabel:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0,1.0),CEGUI.UDim(0.0,height)))
                height = height + wndSkillLabel:getPixelSize().height + 5

                txtSkillLabel:setText(tostring(MHSD_UTILS.get_resstring(3162)))

                -- 侠客技能细节

                local skillIndex = 0
                for k, curSkillID in pairs(curXiakeData.skills) do
                    skillIndex = skillIndex + 1
                    local curSkillInfo = knight.gsp.npc.GetCXiakeskillTableInstance():getRecorder(curSkillID);
                    local wndSkill = winMgr:loadWindowLayout("listxiakecell2.layout", tostring(skillIndex))
                    self.spMoreList:addChildWindow(wndSkill)
                    if skillIndex%2 == 1 then
                        wndSkill:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0,1.0),CEGUI.UDim(0.0,height)))
                        if skillIndex >= TableUtil.tablelength(curXiakeData.skills) then
                            height = height + wndSkill:getPixelSize().height + 5
                        end
                    else
                        wndSkill:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0,1.0+wndSkill:getPixelSize().width),CEGUI.UDim(0.0,height)))
                        height = height + wndSkill:getPixelSize().height + 5
                    end


                    local txtSkillName = winMgr:getWindow(tostring(skillIndex) .. "listxiakecell2/skill1")

                    txtSkillName:setText(tostring(curSkillInfo.skillname))
                end
            end

            -- 侠客修行

            if curXiakeData.practicelevel > 1 then

                -- 侠客修行标签

                local wndXiuXingLabel = winMgr:loadWindowLayout("listline.layout", "rankviewxiake03")

                local txtXiuXingLabel =  winMgr:getWindow("rankviewxiake03" .. "listline/pic")

                self.spMoreList:addChildWindow(wndXiuXingLabel)
                wndXiuXingLabel:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0,1.0),CEGUI.UDim(0.0,height)))
                height = height + wndXiuXingLabel:getPixelSize().height + 5

                txtXiuXingLabel:setText(tostring(MHSD_UTILS.get_resstring(3166)))

                -- 侠客修行细节

                local curXiuxingInfo = BeanConfigManager.getInstance():GetTableByName("knight.gsp.npc.cxiakepracticerealmconfig"):getRecorder(curXiakeData.practicelevel)
                local wndXiuxing = winMgr:loadWindowLayout("listxiakecell3.layout")

                self.spMoreList:addChildWindow(wndXiuxing)
                wndXiuxing:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0,1.0),CEGUI.UDim(0.0,height)))
                height = height + wndXiuxing:getPixelSize().height + 5

                local txtXiuxingName = winMgr:getWindow("listxiakecell3/skill1")

                txtXiuxingName:setText(tostring(curXiuxingInfo.realmName))
            end                

        -- 下方滑动信息 end

    -- 无侠客时的处理

    else
        self.imgBack:setVisible(false)
        self.txtHealth:setVisible(false)
        self.txtAttack:setVisible(false)
        self.txtMagicAttack:setVisible(false)
        self.txtDefend:setVisible(false)
        self.txtMagicDefend:setVisible(false)
        self.txtHealthTitle:setVisible(false)
        self.txtAttackTitle:setVisible(false)
        self.txtMagicAttackTitle:setVisible(false)
        self.txtDefendTitle:setVisible(false)
        self.txtMagicDefendTitle:setVisible(false)
    end
end

return RankXiakeViewDlg
--[[
******帮派修炼场——研究*******

    -- by yao
    -- 2015/1/9
]]

local PracticeStudyLayer = class("PracticeStudyLayer", BaseLayer)

local btnPageTexture = {
    {
        imgSelect = "ui_new/faction/xiulian/btn_pt2.png",
        imgNormal = "ui_new/faction/xiulian/btn_pt1.png",
    },
    {
        imgSelect = "ui_new/faction/xiulian/btn_xl2.png",
        imgNormal = "ui_new/faction/xiulian/btn_xl1.png",
    },
}

function PracticeStudyLayer:ctor(data)
    self.super.ctor(self,data)
    self.tabViewTiaomu = nil            --tableview
    self.cellModel = nil                
    self.btnTable = {}                  --tableview的修炼按钮
    self.closeBtn = nil                 --关闭按钮
    self.btnkaiqi = {}                  --开启按钮
    self.study_level = 0
    self.consumeBoom = 0                --消耗的繁荣度
    self.skillpic = {}                  --技能图片
    self.effect = nil                   --研究成功特效
    self.clickIndex = nil

    self:init("lua.uiconfig_mango_new.faction.PracticeStudy")
end

function PracticeStudyLayer:initUI(ui)
	self.super.initUI(self,ui)

    
    self.practicStudyInfo = FactionPracticeManager:getHouseDetailInfo()
    
    self.btnPage = {}
    for i=1,2 do
        self.btnPage[i] = i
        self.btnPage[i] = TFDirector:getChildByPath(ui, "btn_"..i)
    end
    self:refreshTableView(1)

    self.guildPracticeNum = GuildPracticeData:getGuildPracticeTypeNum(self.currBtnIndex,1)
    --创建TabView
    self.tabViewTiaomuUI = TFDirector:getChildByPath(ui, "Panel_Study")
    self.tabViewTiaomu =  TFTableView:create()
    self.tabViewTiaomu:setTableViewSize(self.tabViewTiaomuUI:getContentSize())
    self.tabViewTiaomu:setDirection(TFTableView.TFSCROLLVERTICAL)
    self.tabViewTiaomu:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    self.tabViewTiaomu.logic = self
    self.tabViewTiaomuUI:addChild(self.tabViewTiaomu)
    self.tabViewTiaomu:setPosition(ccp(0,0))

    self.img_lines = TFDirector:getChildByPath(ui, "img_lines")
    self.img_linexia = TFDirector:getChildByPath(ui, "img_linexia")

    self.cellModel  = TFDirector:getChildByPath(self.tabViewTiaomuUI, 'bg_1')
    self.cellModel:setVisible(false) 
    self.cellModelX =  self.cellModel:getPositionX()
    self.cellModelY =  self.cellModel:getContentSize().height/2-- - 10

    self.closeBtn = TFDirector:getChildByPath(ui, "btn_close")
end

function PracticeStudyLayer:loadData(pageIndex)
end

function PracticeStudyLayer:removeUI()
    self.super.removeUI(self)
end

-----断线重连支持方法
function PracticeStudyLayer:onShow()
    self.super.onShow(self)
end

function PracticeStudyLayer:registerEvents()
    self.super.registerEvents(self)

    --注册TabView事件
    self.tabViewTiaomu:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    self.tabViewTiaomu:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    self.tabViewTiaomu:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)
    self.tabViewTiaomu:addMEListener(TFTABLEVIEW_SCROLL, self.tableScroll)
    self.tabViewTiaomu:reloadData()

    self.closeBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCloseBtnCallBack))

    self.studySucess = function(event)
        self.tabViewTiaomu:reloadData()
        if self.study_level == 1 then
            --toastMessage("开启成功")
            toastMessage(localizable.practiceStudyLayer_open_suc)
            FactionManager:useFactionBoom(self.consumeBoom)
        else
            --toastMessage("研究成功")
            toastMessage(localizable.practiceStudyLayer_yanjiu_suc)
            FactionManager:useFactionBoom(self.consumeBoom)
        end
        self:addSkillpicEffect()
    end;
    TFDirector:addMEGlobalListener(FactionPracticeManager.studySucess ,self.studySucess ) ;

    for i=1,2 do
        self.btnPage[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onSelectBtnClick))
        self.btnPage[i].logic = self
        self.btnPage[i].idx = i
    end
end

function PracticeStudyLayer:removeEvents()
    self.tabViewTiaomu:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.tabViewTiaomu:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.tabViewTiaomu:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)

    self.closeBtn:removeMEListener(TFWIDGET_CLICK)

    TFDirector:removeMEGlobalListener(FactionPracticeManager.studySucess ,self.studySucess)
    self.studySucess = nil

    for i=1,2 do
        self.btnPage[i]:removeMEListener(TFWIDGET_CLICK)
    end
    self.super.removeEvents(self)
end

function PracticeStudyLayer:dispose()
    self.super.dispose(self)
end

function PracticeStudyLayer.cellSizeForTable(table,idx)
    return 130,650
end

function PracticeStudyLayer.numberOfCellsInTableView(table)
    local self = table.logic
    local num = self.guildPracticeNum
    return num
end

function PracticeStudyLayer.tableCellAtIndex(table, idx)

    local self = table.logic
    local cell = table:dequeueCell()
    --cell:remove
    print("idx:",idx)
    local panel = nil
    if cell == nil then
        cell = TFTableViewCell:create()
        panel = self.cellModel:clone()
        local size = panel:getContentSize()
        panel:setPosition(ccp(self.cellModelX, self.cellModelY))
        cell:addChild(panel)
        panel:setVisible(true)
        cell.panelNode = panel
    else
        panel = cell.panelNode
    end
    self:cellInfoSet(panel, idx+1)

    return cell
end

function PracticeStudyLayer:cellInfoSet(panel, idx)

    local skilltitle    = TFDirector:getChildByPath(panel, "txt1")
    local skillLevel    = TFDirector:getChildByPath(panel, "txt2")
    local nowConfig     = TFDirector:getChildByPath(panel, "txt3")
    local nowconfigNum  = TFDirector:getChildByPath(nowConfig, "txt4")
    local maxConfig     = TFDirector:getChildByPath(panel, "txt_dangqian")
    local maxConfigNum  = TFDirector:getChildByPath(maxConfig, "txt_level")
    local txt_xiaohao   = TFDirector:getChildByPath(panel, "txt_xiaohao")
    local xiaohaoNum    = TFDirector:getChildByPath(txt_xiaohao, "txt_level")
    local skillKuag     = TFDirector:getChildByPath(panel, "img_kuang")
    local skillpic      = TFDirector:getChildByPath(skillKuag, "img_tu")
    local btn_yanjiu    = TFDirector:getChildByPath(panel, "btn_yanjiu")
    local btn_kaiqi     = TFDirector:getChildByPath(panel, "btn_kaiqi")
    local img_jiantou   = TFDirector:getChildByPath(panel, "img_jiantou")

    local currSkillType = idx
    if self.currBtnIndex == 2 then
        currSkillType = GuildPracticeData:getGuildPracticeTypeNum(1,1)
        currSkillType = currSkillType + idx
    end
    local guildPracticeByType = GuildPracticeData:getGuildPracticeByType(currSkillType,1)
    local studyInfo = GuildPracticeStudyData:getGuildPracticeStudyByType(currSkillType)
    local level  = 0
    if next(self.practicStudyInfo) ~= nil and self.practicStudyInfo[currSkillType] ~= nil then
        level = self.practicStudyInfo[currSkillType]
    end    
    
    --技能描述
    skilltitle:setText(guildPracticeByType[1].title)
    --技能等级
    skillLevel:setText("Lv" .. level)

    -- local config = math.abs(GuildPracticeData:getNowConfigByLevel(currSkillType,level))
    -- local confignext = math.abs(GuildPracticeData:getNowConfigByLevel(currSkillType,level+1))
    -- --属性提升
    -- nowconfigNum:setText(config/100 .. "%")
    -- local nextconfigNum = TFDirector:getChildByPath(nowConfig, "txt5")
    -- nextconfigNum:setText(confignext/100 .. "%")
    nowconfigNum:setText(level)
    local nextconfigNum = TFDirector:getChildByPath(nowConfig, "txt5")
    nextconfigNum:setText(level+1)

    --当前最高等级
    -- local maxcofig = math.abs(GuildPracticeData:getNowConfigByLevel(idx,#guildPracticeByType))
    -- maxConfigNum:setText(maxcofig/100 .. "%")
    -- local maxcofig = math.abs(GuildPracticeData:getNowConfigByLevel(currSkillType,#guildPracticeByType))
    
    local maxlevel = GuildPracticeRuleData:getStudyMaxLevel(FactionPracticeManager:getXLCLevel(), currSkillType)
    maxConfigNum:setText(maxlevel)

    --繁荣度消耗
    if level < #studyInfo then
        xiaohaoNum:setText(studyInfo[level+1].boom)
    else
        xiaohaoNum:setText("---")
    end
    
    --技能图片
    --
    if self.currBtnIndex == 2 then
        skillKuag:setTexture("")
    else
        skillKuag:setTexture("ui_new/faction/xiulian/img_kuang.png")
    end

    skillpic:setTexture("ui_new/faction/xiulian/" .. guildPracticeByType[1].icon .. ".png")
    self.skillpic[currSkillType] = skillpic

     --if self.effect ~= nil then
    self.skillpic[currSkillType]:removeAllChildren()
        --self.effect:removeFromParent()
       -- self.effect = nil
   -- end
   
    --研究按钮
    btn_yanjiu.logic = self
    btn_yanjiu.skillpic = skillpic
    btn_yanjiu.tag = 100+currSkillType
    btn_yanjiu:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onYanjiuClick))

    --开启按钮
    btn_kaiqi.logic = self
    btn_kaiqi.skillpic = skillpic
    btn_kaiqi.tag = 1000+currSkillType
    btn_kaiqi:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onKaiqiClick))

    if level <= 0 then
        btn_kaiqi:setVisible(true)
        btn_yanjiu:setVisible(false)
        btn_kaiqi:setTouchEnabled(true)
        btn_yanjiu:setTouchEnabled(false)
        img_jiantou:setVisible(true)
        nextconfigNum:setVisible(true)
    elseif level >= #studyInfo then
        btn_kaiqi:setVisible(false)
        btn_yanjiu:setTouchEnabled(false)
        btn_yanjiu:setVisible(true)
        btn_yanjiu:setTextureNormal("ui_new/faction/xiulian/img_manji.png")
        img_jiantou:setVisible(false)
        nextconfigNum:setVisible(false)
    else
        btn_kaiqi:setVisible(false)
        btn_yanjiu:setVisible(true)
        btn_kaiqi:setTouchEnabled(false)
        btn_yanjiu:setTouchEnabled(true)
        img_jiantou:setVisible(true)
        nextconfigNum:setVisible(true)
        btn_yanjiu:setTextureNormal("ui_new/faction/xiulian/btn_yanjiu2.png")
    end 
end

--研究按钮回调函数
function PracticeStudyLayer.onYanjiuClick(sender)
    local tag       = sender.tag
    local self      = sender.logic
    local index     = tag - 100
    local info      = self.practicStudyInfo
    self.clickIndex = index

    local studyInfo = GuildPracticeStudyData:getGuildPracticeStudyByType(index)
    local ownboom   = FactionManager:getFactionBoom()
    local level     = info[index]
    local neesBoom  = 0
    local myPost    = FactionManager:getPostInFaction()

    local guildPracticeByType = GuildPracticeData:getGuildPracticeByType(index,1)
    if level < #guildPracticeByType then
        neesBoom  = studyInfo[level+1].boom
    end
    --print("ownboom:",ownboom)
    if myPost ~= 1 and myPost ~= 2 then
        toastMessage(localizable.Field_No_Permissions)
        return
    elseif ownboom < neesBoom then
        toastMessage(localizable.NoT_Enough_Prosperity)
        return
    end

    if next(info) ~= nil and info[index] ~= nil then
        --local maxlevel = #guildPracticeByType
        local practicelevel = FactionPracticeManager:getXLCLevel()
        local maxlevel = GuildPracticeRuleData:getStudyMaxLevel(practicelevel,index)
        if info[index] >= #guildPracticeByType then
            toastMessage(localizable.Field_Research_skill_max_level2)
        elseif info[index] >= maxlevel then
            toastMessage(localizable.Field_Research_skill_max_level)
        else
            -- local str = TFLanguageManager:getString(ErrorCodeData.Field_Research_skill)
            -- str = string.format(str,neesBoom,level+1,guildPracticeByType[1].title)            
            local str = stringUtils.format(localizable.Field_Research_skill,neesBoom,level+1,guildPracticeByType[1].title)

            self:openCell(index, str)
            self.consumeBoom = neesBoom
            self.study_level = level +1
        end 
    end
end

--开启按钮回调函数
function PracticeStudyLayer.onKaiqiClick(sender)
    -- body
    local tag       = sender.tag
    local self      = sender.logic
    local index     = tag - 1000
    local info      = self.practicStudyInfo
    local studyInfo = GuildPracticeStudyData:getGuildPracticeStudyByType(index)
    local myPost    = FactionManager:getPostInFaction()
    local ownboom   = FactionManager:getFactionBoom()
    local neesBoom  = studyInfo[1].boom
    self.clickIndex = index

    if myPost ~= 1 and myPost ~= 2 then
        toastMessage(localizable.Field_Study_skill_no_open)
        return
    elseif ownboom < neesBoom then
        toastMessage(localizable.NoT_Enough_Prosperity)
        return
    end

    -- local str = TFLanguageManager:getString(ErrorCodeData.Field_Open_skill)

    local guildPracticeByType = GuildPracticeData:getGuildPracticeByType(index,1)

    -- str = string.format(str, neesBoom, guildPracticeByType[1].title)

    local str = stringUtils.format(localizable.Field_Open_skill, neesBoom, guildPracticeByType[1].title)

    self:openCell(index, str)
    self.consumeBoom = neesBoom
    self.study_level = 1
end

--关闭按钮回调函数
function PracticeStudyLayer.onCloseBtnCallBack(sender)
    -- body
    AlertManager:close()
end

function PracticeStudyLayer:openCell(index, str)
    CommonManager:showOperateSureLayer(
        function()
            FactionPracticeManager:requestStudy(index)
        end,
        function()
        end,
        {
            --title = "提示" ,
            title = localizable.common_tips ,
            msg = str,
            uiconfig = "lua.uiconfig_mango_new.common.OperateSure1"
        }
    )
end

function PracticeStudyLayer:addSkillpicEffect()
    -- body
    --[[
    if self.effect ~= nil then
        self.effect:removeFromParent()
        self.effect = nil
    end
    ]]
    TFResourceHelper:instance():addArmatureFromJsonFile("effect/equiIntensify.xml")
    self.effect = TFArmature:create("equiIntensify_anim")
    if self.effect == nil then
        return
    end
    self.effect:setZOrder(100)
    self.effect:setAnimationFps(GameConfig.ANIM_FPS)
    self.effect:playByIndex(0, -1, -1, 0)
    self.effect:setPosition(ccp(346,-35))
    if self.currBtnIndex == 2 then
        self.effect:setPosition(ccp(356,-22))
    end
    self.skillpic[self.clickIndex]:addChild(self.effect,10)
    -- self.effect:addMEListener(TFARMATURE_COMPLETE, function ()
    --         self.tabViewTiaomu:reloadData()
    -- end) 
end


function PracticeStudyLayer.onSelectBtnClick( btn )
    local self = btn.logic
    local idx = btn.idx
    if self.currBtnIndex == idx then
        return
    end
    if FactionPracticeManager:checkIsOpenSecondPage() then
        self:refreshTableView(idx)
    end
end

function PracticeStudyLayer:refreshTableView( idx )
    self.currBtnIndex = idx

    for i=1,2 do
        if i == idx then
            self.btnPage[i]:setTextureNormal(btnPageTexture[i].imgSelect)
        else
            self.btnPage[i]:setTextureNormal(btnPageTexture[i].imgNormal)
        end
    end

    if self.tabViewTiaomu then
        self.tabViewTiaomu:reloadData()
    end
end

function PracticeStudyLayer:refreshArrowBtn()
    local currPosition = self.tabViewTiaomu:getContentOffset()
    print("currPosition = ",currPosition)
    if self.tabViewTiaomu then
        local offsetMax = self.tabViewTiaomuUI:getContentSize().height-130*self.guildPracticeNum
        local currPosition = self.tabViewTiaomu:getContentOffset()
        if currPosition.y < 0 and offsetMax >= currPosition.y then
            self.img_lines:setVisible(false)
        else
            self.img_lines:setVisible(true)
        end

        if currPosition.y >= 0 then
            self.img_linexia:setVisible(false)
        else
            self.img_linexia:setVisible(true)
        end
    end
end

function PracticeStudyLayer.tableScroll( table )
    local self = table.logic
    self:refreshArrowBtn()
end
return PracticeStudyLayer
--[[
******帮派修炼选择*******

    -- by yao
    -- 2015/1/7
]]

local PracticeChooseLayer = class("PracticeChooseLayer", BaseLayer)

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

function PracticeChooseLayer:ctor(data)
    self.super.ctor(self,data)
    self.tabViewTiaomu = nil            --tableview
    
    self.roleName = nil                 --角色名字
    self.rolequallity = nil             --角色品质
    self.skilldateTable = {}            --技能table
    self.guildPracticeInfo = nil
    self.practicePos = nil
    self.roleId = nil
    self.xiakeLayer = nil
    self.chooseCardRole = nil
    self.consumeBoom = 0                --消耗的繁荣度

    self:init("lua.uiconfig_mango_new.faction.PracticeChoose")
end

function PracticeChooseLayer:initUI(ui)
	self.super.initUI(self,ui)

	self.generalHead = CommonManager:addGeneralHead( self ,10)
    self.generalHead:setData(ModuleType.PracticeXL,{HeadResType.FACTION_GX,HeadResType.COIN,HeadResType.SYCEE})    

    self.btnPage = {}
    for i=1,2 do
        self.btnPage[i] = i
        self.btnPage[i] = TFDirector:getChildByPath(ui, "btn_"..i)
    end
    self:refreshTableView(1)
    --创建TabView
    self.tabViewTiaomuUI = TFDirector:getChildByPath(ui, "panel_practiceitem")
    self.tabViewTiaomu =  TFTableView:create()
    self.tabViewTiaomu:setTableViewSize(self.tabViewTiaomuUI:getContentSize())
    self.tabViewTiaomu:setDirection(TFTableView.TFSCROLLVERTICAL)    
    self.tabViewTiaomu:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    self.tabViewTiaomu.logic = self
    self.tabViewTiaomuUI:addChild(self.tabViewTiaomu)
    self.tabViewTiaomu:setPosition(ccp(0,0))

    self.cellModel = {}
    for i=1,2 do
        self.cellModel[i] = TFDirector:getChildByPath(self.tabViewTiaomuUI, 'bg'..i)
        self.cellModel[i]:setVisible(false)
    end
    
    --self.panel_list = TFDirector:getChildByPath(ui,'panel_list')
    -- local pageView = TPageView:create()
    -- self.pageView = pageView
    -- pageView:setBounceEnabled(false)
    -- pageView:setTouchEnabled(true)
    -- pageView:setBackGroundColorType(TF_LAYOUT_COLOR_NONE)
    -- pageView:setSize(self.panel_list:getContentSize())
    -- pageView:setPosition(self.panel_list:getPosition())
    -- pageView:setAnchorPoint(self.panel_list:getAnchorPoint())
    -- local function onPageChange()
    --     self:onPageChange();
    -- end
    -- pageView:setChangeFunc(onPageChange)
    -- local function itemAdd(index)
    --     return  self:addPage(index);
    -- end
    -- pageView:setAddFunc(itemAdd)
    -- self.panel_list:addChild(pageView,2)
    self.guildPracticeNum = GuildPracticeData:getGuildPracticeTypeNum(self.currBtnIndex,1)

    --名字背景
    self.img_diwen = TFDirector:getChildByPath(ui, "img_diwen1")
    self.img_diwen:setVisible(false)
    self.img_tou = TFDirector:getChildByPath(ui, "img_tou")
    --人物名
    self.roleName = TFDirector:getChildByPath(ui, "txt_name")
    self.roleName:setText("")
    --人物品质
    self.rolequallity = TFDirector:getChildByPath(ui, "img_quality")
    self.rolequallity:setVisible(false)
    --人物头像1
    self.panel_rolehead1 = TFDirector:getChildByPath(ui, "panel_rolehead1")
    self.imagehead = TFDirector:getChildByPath(self.panel_rolehead1, "img_touxiang")
    self.imagehead:setVisible(false)
    --职业
    self.img_zhiye = TFDirector:getChildByPath(ui, "img_zhiye")
    self.btn_icon = TFDirector:getChildByPath(ui, "btn_icon")
    self.btn_icon:setVisible(false)
    --左右按钮
    -- self.btn_pageleft = TFDirector:getChildByPath(ui, "btn_pageleft")
    -- self.btn_pageleft.logic = self
    -- self.btn_pageleft:setTag(1)
    -- self.btn_pageleft:setZOrder(3)
    -- self.btn_pageleft:setVisible(false)
    -- self.btn_pageright = TFDirector:getChildByPath(ui, "btn_pageright")
    -- self.btn_pageright.logic = self
    -- self.btn_pageright:setTag(2)
    -- self.btn_pageright:setZOrder(3)
    -- self.btn_pageright:setVisible(false)
    --更换侠客按钮
    --self.panel_roleshuxing = TFDirector:getChildByPath(ui, "panel_roleshuxing")
    self.btn_qiehuan = TFDirector:getChildByPath(ui, "btn_qiehuan")
    self.btn_qiehuan:setTag(3)
    self.btn_qiehuan:setZOrder(3)
    self.btn_qiehuan.logic = self
    self.btn_qiehuan:setVisible(false)
    --加号按钮
    self.btn_jiahao = TFDirector:getChildByPath(ui, "btn_jiahao")
    self.btn_jiahao:setTag(4)
    self.btn_jiahao:setZOrder(3)
    self.btn_jiahao.logic = self
    self.btn_jiahao:setVisible(true)

    self.img_lines = TFDirector:getChildByPath(ui, "img_lines")
    self.img_linexia = TFDirector:getChildByPath(ui, "img_linexia")
end

function PracticeChooseLayer:loadData(pos)
    -- self.pageView:_removeAllPages();
    -- self.pageView:setMaxLength(5)
    -- self.pageList        = {};
    -- self:showInfoForPage(pageIndex);
    -- self.pageView:InitIndex(pageIndex); 
    self.practicePos    =   pos
    self.roleId         =   nil
    self.chooseCardRole =   nil
end

function PracticeChooseLayer:removeUI()
    self.super.removeUI(self)
end

-----断线重连支持方法
function PracticeChooseLayer:onShow()
    self.super.onShow(self)
    self.generalHead:onShow()

    if self.xiakeLayer == nil then
        local filter_list = FactionPracticeManager:getHouseCardList()
        self:showXiake(filter_list)
    end
end

function PracticeChooseLayer:registerEvents()
    self.super.registerEvents(self)
    if self.generalHead then
        self.generalHead:registerEvents()
    end

    --注册TabView事件
    self.tabViewTiaomu:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    self.tabViewTiaomu:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    self.tabViewTiaomu:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)
    self.tabViewTiaomu:addMEListener(TFTABLEVIEW_SCROLL, self.tableScroll)
    self.tabViewTiaomu:reloadData()

    self.btn_qiehuan:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onExchangeButtonClick))
    self.btn_jiahao:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onAddButtonClick))

    self.practiceSucess = function(event)
        -- FactionManager:useFactionBoom(self.consumeBoom)
        AlertManager:close()
    end;
    TFDirector:addMEGlobalListener(FactionPracticeManager.startPracticeSucess,self.practiceSucess ) ;

    for i=1,2 do
        self.btnPage[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onSelectBtnClick))
        self.btnPage[i].logic = self
        self.btnPage[i].idx = i
    end

end

function PracticeChooseLayer:removeEvents()
	if self.generalHead then
        self.generalHead:removeEvents()
    end
    self.tabViewTiaomu:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.tabViewTiaomu:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.tabViewTiaomu:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)

    self.btn_qiehuan:removeMEListener(TFWIDGET_CLICK)
    self.btn_jiahao:removeMEListener(TFWIDGET_CLICK)

    TFDirector:removeMEGlobalListener(FactionPracticeManager.startPracticeSucess,self.practiceSucess)
    self.practiceSucess = nil

    for i=1,2 do
        self.btnPage[i]:removeMEListener(TFWIDGET_CLICK)
    end

    self.super.removeEvents(self)
end

function PracticeChooseLayer:dispose()
    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end
    self.super.dispose(self)
end

function PracticeChooseLayer.cellSizeForTable(table,idx)
    -- local self = table.logic
    -- if self.currBtnIndex == 2 then
    --     return 145,600
    -- end
    -- return 120,600
    return 145,600
end

function PracticeChooseLayer.numberOfCellsInTableView(table)
    local self = table.logic
    local num = self.guildPracticeNum
    return num
end

function PracticeChooseLayer.tableCellAtIndex(table, idx)

    local self = table.logic
    local cell = table:dequeueCell()
    print("idx:",idx)
    local panel = nil
    if cell == nil then
        cell = TFTableViewCell:create()
        cell.panelNode = {}
        for i=1,2 do
            local panelNode = self.cellModel[i]:clone()
            local posx = self.cellModel[i]:getPositionX()
            local size = self.cellModel[i]:getContentSize()
            panelNode:setPosition(ccp(posx, size.height/2 - 0))
            cell:addChild(panelNode)
            panelNode:setVisible(false)
            cell.panelNode[i] = panelNode
        end        
    end

    for i=1,2 do
        cell.panelNode[i]:setVisible(false)
    end
    panel = cell.panelNode[self.currBtnIndex]
    panel:setVisible(true)   
    self:cellInfoSet( panel, idx+1)

    return cell
end

function PracticeChooseLayer:cellInfoSet(panel, idx)
    
    local skilltitle = TFDirector:getChildByPath(panel, "txt1")
    local skillLevel = TFDirector:getChildByPath(panel, "txt2")
    local nowConfig = TFDirector:getChildByPath(panel, "txt3")
    local nowconfigNum = TFDirector:getChildByPath(nowConfig, "txt4")
    local nextConfig = TFDirector:getChildByPath(panel, "txt_dangqian")
    local nextConfigNum = TFDirector:getChildByPath(nextConfig, "txt_level")
    local skillKuang = TFDirector:getChildByPath(panel, "img_kuang")
    local skillpic = TFDirector:getChildByPath(skillKuang, "img_tu")
    local btn_xiulian = TFDirector:getChildByPath(panel, "btn_xiulian")
    local img_newprice_bg = TFDirector:getChildByPath(panel, "img_newprice_bg")
    local img_res_icon = TFDirector:getChildByPath(img_newprice_bg, "img_res_icon")
    local txt_price = TFDirector:getChildByPath(img_newprice_bg, "txt_price")
    local img_manji = TFDirector:getChildByPath(panel, "img_manji")
    local txt_kaiqi = TFDirector:getChildByPath(panel, "txt_kaiqi")

    local currSkillType = idx
    if self.currBtnIndex == 2 then
        currSkillType = GuildPracticeData:getGuildPracticeTypeNum(1,1)
        currSkillType = currSkillType + idx
    end

    local level = 0
    local profession = 1
    if self.chooseCardRole ~= nil then
        level = self.chooseCardRole:getFactionPracticeLevelByType(currSkillType)
        profession = self.chooseCardRole.outline
    end

    local guildPracticeByType = GuildPracticeData:getGuildPracticeByType(currSkillType,profession)
    local practicStudyInfo = FactionPracticeManager:getHouseDetailInfo()
    local studyInfo = GuildPracticeStudyData:getGuildPracticeStudyByType(currSkillType)
    local maxstudylevel = #studyInfo

    --研究等级
    local studylevel = 0
    if next(practicStudyInfo) ~= nil and practicStudyInfo[currSkillType] ~= nil then
        studylevel = practicStudyInfo[currSkillType]
    end
    
    --技能描述
    skilltitle:setText(guildPracticeByType[1].title)
    --技能等级
    skillLevel:setText("Lv" .. level .. "/" .. studylevel)
    if level > studylevel then
        skillLevel:setColor(ccc3(255,0,0))
    else
        skillLevel:setColor(ccc3(0,0,0))
    end
    --当前属性
    local config,isPrecent = GuildPracticeData:getNowConfigByLevel(currSkillType,level,profession)
    config = math.abs(config)
    if isPrecent then
        nowconfigNum:setText(config/100 .. "%")
    else
        nowconfigNum:setText(config)
    end
    --下级属性
    local confignext,isPrecentNext = GuildPracticeData:getNowConfigByLevel(currSkillType,level+1,profession)
    confignext = math.abs(confignext)
    if isPrecentNext then
        nextConfigNum:setText(confignext/100 .. "%")
    else
        nextConfigNum:setText(confignext)
    end
    --技能图片
    if self.currBtnIndex == 2 then
        skillKuang:setTexture("ui_new/faction/xiulian/" .. guildPracticeByType[1].icon .. ".png")
    else
        skillpic:setTexture("ui_new/faction/xiulian/" .. guildPracticeByType[1].icon .. ".png")
    end

    --消耗图片
    local boom,boomEx = 0,0
    if level >= maxstudylevel then
        txt_price:setText(0)
        boom = 0
        nextConfigNum:setText("---")

        if self.currBtnIndex == 2 then
            local priceNode = TFDirector:getChildByPath(panel,"img_newprice_bg")
            txt_price = TFDirector:getChildByPath(priceNode, "txt_price")
            txt_price:setText(0)
            priceNode = TFDirector:getChildByPath(panel,"img_newprice_bg2")
            txt_price = TFDirector:getChildByPath(priceNode, "txt_price")
            txt_price1 = TFDirector:getChildByPath(priceNode, "txt_price1")
            txt_price2 = TFDirector:getChildByPath(priceNode, "txt_price2")
            txt_price:setText(0)
        end
    else
        local dedicationTbl = string.split(studyInfo[level+1].start_practice, "|")
        local start_practice = stringToNumberTable(dedicationTbl[1],"_")
        boom = start_practice[3]

        if dedicationTbl[2] then
            start_practice = stringToNumberTable(dedicationTbl[2],"_")
            boomEx = start_practice[3]
            
        end
                
        if self.currBtnIndex == 2 then
            local priceNode = TFDirector:getChildByPath(panel,"img_newprice_bg")
            txt_price = TFDirector:getChildByPath(priceNode, "txt_price")
            txt_price:setText(boom)
            priceNode = TFDirector:getChildByPath(panel,"img_newprice_bg2")
            txt_price = TFDirector:getChildByPath(priceNode, "txt_price")
            txt_price1 = TFDirector:getChildByPath(priceNode, "txt_price1")
            txt_price2 = TFDirector:getChildByPath(priceNode, "txt_price2")

            local goodsId = start_practice[2]
            local numInBag = BagManager:getItemNumById(goodsId)
            local img_res_icon = TFDirector:getChildByPath(priceNode, "img_res_icon")
            if goodsId == 30118 then
                img_res_icon:setTexture('ui_new/faction/xiulian/img_xld1.png')
            elseif goodsId == 30119 then
                img_res_icon:setTexture('ui_new/faction/xiulian/img_xld2.png')
            elseif goodsId == 30120 then
                img_res_icon:setTexture('ui_new/faction/xiulian/img_xld3.png')
            end
            txt_price:setText('/' ..boomEx)
            if numInBag < boomEx then
                txt_price1:setVisible(true)
                txt_price1:setText(numInBag)
                txt_price2:setVisible(false)
            else
                txt_price2:setVisible(true)
                txt_price2:setText(numInBag)
                txt_price1:setVisible(false)
            end            
        else
            txt_price:setText(boom)
        end
    end

    --修炼按钮
    btn_xiulian:setTag(100+currSkillType)
    btn_xiulian.logic = self
    btn_xiulian:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onLearnButtonClick))
    btn_xiulian.boom = boom
    btn_xiulian.boomEx = boomEx
    
    --已满级--待开启
    if level >= maxstudylevel then
        img_manji:setVisible(true)
        txt_kaiqi:setVisible(false)
        btn_xiulian:setVisible(false)
        img_newprice_bg:setVisible(false)
    elseif studylevel == 0 then
        img_manji:setVisible(false)
        txt_kaiqi:setVisible(true)
        btn_xiulian:setVisible(false)
        img_newprice_bg:setVisible(false)
    else
        img_manji:setVisible(false)
        txt_kaiqi:setVisible(false)
        btn_xiulian:setVisible(true)
        img_newprice_bg:setVisible(true) 
    end 
end

--添加滑动页
function PracticeChooseLayer:addPage(pageIndex)
    -- local pagepanel = TFPanel:create();
    -- pagepanel:setSize(self.panel_list:getContentSize())
    -- local image = self.imagehead:clone()
    -- image:setPosition(ccp(110,240))
    -- pagepanel:addChild(image)
    -- image:setVisible(true)
    -- -- local pagebg = nil;
    -- -- local function addpageBg()
    -- --     if self.pageMapNode == nil then
    -- --         page = createUIByLuaNew(self.imagehead);
    -- --         self.pageMapNode = page
    -- --         self.pageMapNode:retain()
    -- --     end
    -- --     page = self.pageMapNode:clone()

    -- --     page:setSize(self.panel_list:getContentSize())
    -- --     pagepanel:addChild(page);
    -- -- end
    -- -- addpageBg()
    -- -- self.pageList[pageIndex] = pagepanel; 
    -- return pagepanel;
end
function PracticeChooseLayer:onPageChange()
    --local pageIndex = self.pageView:_getCurPageIndex()
    --self:showInfoForPage(pageIndex);
end
function PracticeChooseLayer:showInfoForPage(pageIndex)
end

--修炼按钮回到函数
function PracticeChooseLayer.onLearnButtonClick(sender)
    -- body
    local tag           = sender:getTag()
    local self          = sender.logic
    local practiceType  = tag - 100
    self.consumeBoom    = sender.boom
    if self.chooseCardRole == nil then
        local filter_list = FactionPracticeManager:getHouseCardList()
        self:showXiake(filter_list)
        print("role is nil 111111111111111111")
        return
    end
  
    local practicStudyInfo = FactionPracticeManager:getHouseDetailInfo() or {}
    local nowMaxLevel = practicStudyInfo[practiceType] or 0
    local level = self.chooseCardRole:getFactionPracticeLevelByType(practiceType)

    studyInfo = GuildPracticeStudyData:getPracticeInfoByTypeAndLevel( practiceType,level+1 )
    local checkIsTool = nil
    --判断道具是否足够
    if studyInfo then
        local dedicationTbl = string.split(studyInfo.start_practice, "|")
        if dedicationTbl[2] then
            local start_practice = stringToNumberTable(dedicationTbl[2],"_")
            local goodsId = start_practice[2]
            local goodsNum = start_practice[3]
            local numberInBag = BagManager:getItemNumById(goodsId)
            if numberInBag < goodsNum then
                local item = ItemData:objectByID(goodsId)
                checkIsTool = item.name
            end
        end
    end
    
    local str = ""
    if nowMaxLevel <= 0 then
        str = localizable.Field_Study_skill_no_open
        toastMessage(str)
    elseif level >= nowMaxLevel then
        str = localizable.Field_Study_skill_max_level
        toastMessage(str)
    elseif MainPlayer:getDedication() < self.consumeBoom then
        str = localizable.Guild_Dedication_Not
        toastMessage(str)        
    elseif checkIsTool then
        str = stringUtils.format(localizable.Guild_Dedication_Tool_Not,checkIsTool)
        toastMessage(str)    
    else
        print("self.practicePos:",self.practicePos)
        print("self.roleId:",self.roleId)
        print("practiceType:",practiceType)
        if self.practicePos ~= nil and self.roleId ~= nil and practiceType ~= nil then
            FactionPracticeManager:requestStartPractice(self.practicePos,self.roleId,practiceType)
        end
    end
end

--更换侠客按钮回调函数
function PracticeChooseLayer.onExchangeButtonClick(sender)
    local tag = sender:getTag()
    local self = sender.logic
    local filter_list = FactionPracticeManager:getHouseCardList()
    local filterlist = filter_list
    filterlist:pushBack(self.chooseCardRole)
    self:showXiake(filterlist)
end

--加号按钮回调函数
function PracticeChooseLayer.onAddButtonClick(sender)
    local tag = sender:getTag()
    local self = sender.logic
    local filter_list = FactionPracticeManager:getHouseCardList()
    self:showXiake(filter_list)
end

function PracticeChooseLayer:updateChooseRole(cardRole)
    -- body
    self.img_zhiye:setTexture("ui_new/fight/zhiye_".. cardRole.outline ..".png")
    self.imagehead:setVisible(true)
    self.btn_jiahao:setVisible(false)
    self.btn_qiehuan:setVisible(true)
    self.roleName:setText(cardRole.name)
    --人物品质
    self.rolequallity:setTexture(GetFontByQuality(cardRole.quality))
    self.imagehead:setTexture(cardRole:getHeadPath())
    --self.img_type:setTexture("ui_new/common/img_role_type" .. self.cardRole.outline .. ".png")
    self.rolequallity:setVisible(true)
    -- self.img_diwen:setTexture(GetRoleNameBgByQuality(cardRole.quality))
    -- self.img_diwen:setVisible(true)
    self.tabViewTiaomu:reloadData()
    self.btn_icon:setTextureNormal(GetColorRoadIconByQuality(cardRole.quality))
    self.btn_icon:setVisible(true)
end

function PracticeChooseLayer:showXiake(filter_list)
    -- body
    --显示角色选择界面
    local role_list = CardRoleManager.cardRoleList
    --local filter_list = FactionPracticeManager:getHouseCardList()
    local layer  = require("lua.logic.factionPractice.PracticeRoleSelect"):new()
    AlertManager:addLayer(layer,AlertManager.BLOCK,AlertManager.TWEEN_NONE)
    self.clickCallBack = function (cardRole)
        --print("===2222===cardRole",cardRole)
        layer:moveOut()
        self.roleId =cardRole.gmId
        self.chooseCardRole = cardRole
        self:updateChooseRole(cardRole)
        --print("self.roleId:",self.roleId)
        play_chongxue()
    end
    --layer:initDateByFilter( role_list, filter_list,'请选择侠客',self.clickCallBack)
    layer:initDateByFilter( role_list, filter_list,localizable.practiceChooseLayer_check_hero,self.clickCallBack)
    
    AlertManager:show()
    self.xiakeLayer = layer
end

function PracticeChooseLayer.onSelectBtnClick( btn )
    local self = btn.logic
    local idx = btn.idx
    if self.currBtnIndex == idx then
        return
    end
    if FactionPracticeManager:checkIsOpenSecondPage() then
        self:refreshTableView(idx)
    end
end

function PracticeChooseLayer:refreshTableView( idx )
    self.currBtnIndex = idx

    for i=1,2 do
        if i == idx then
            self.btnPage[i]:setTextureNormal(btnPageTexture[i].imgSelect)
        else
            self.btnPage[i]:setTextureNormal(btnPageTexture[i].imgNormal)
        end
    end
    self.guildPracticeNum = GuildPracticeData:getGuildPracticeTypeNum(self.currBtnIndex,1)
    if self.tabViewTiaomu then
        self.tabViewTiaomu:reloadData()
        self.tabViewTiaomu:setScrollToBegin()
    end
end
function PracticeChooseLayer:refreshArrowBtn()
    local currPosition = self.tabViewTiaomu:getContentOffset()
    
    if self.tabViewTiaomu then
        local cellHeight = 145
        if self.currBtnIndex == 1 then
            cellHeight = 120
        end
        local offsetMax = self.tabViewTiaomuUI:getContentSize().height-cellHeight*self.guildPracticeNum
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

function PracticeChooseLayer.tableScroll( table )
    local self = table.logic
    self:refreshArrowBtn()
end
return PracticeChooseLayer
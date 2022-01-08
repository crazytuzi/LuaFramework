--[[
******后山之乱*******

    -- by yao
    -- 2015/12/25
]]

local HoushanLayer = class("HoushanLayer", BaseLayer)

function HoushanLayer:ctor(data)
    self.super.ctor(self,data)
    self.generalHead = nil          --头部
    self.txt_chapter = nil          --章节
    self.buttonArr = {}             --按钮保存数组
    self.bar_exp1 = nil             --进度比例
    self.txt_jindu = nil            --进度数值
    self.shengyulabel = nil         --今日剩余次数文字
    self.shengyucishu = nil         --剩余次数
    self.panel_list = nil   
    self.pageMapNode = nil          --地图节点
    self.pageList = {}              --保存页数  
    self.bosslist = {}              --保存所有boss的列表    
    self.chapterNum = nil           --章节数量 
    self.unlockBoss = 0             -- 解锁的boss
    self.selectIndex = 0            --正在攻打的章节
    self.rewardeffect = nil         --宝箱特效
    self.updateRewardEffectCallBack = nil
    self.updateHoushanCallBack = nil
    self.IsClickItem = false        --是否点击了boss
    self.clickBoss = nil            --点击了第几个boss

    self:init("lua.uiconfig_mango_new.faction.HoushanLayer")
end

function HoushanLayer:initUI(ui)
	self.super.initUI(self,ui)

    self.chapterNum = HoushanManager:getHoushanChapterNum()

	self.generalHead = CommonManager:addGeneralHead( self ,10)
    self.generalHead:setData(ModuleType.Hs_Faction,{HeadResType.FACTION_GX,HeadResType.COIN,HeadResType.SYCEE})

    --1.左翻按钮 2.右翻按钮 3.奖励按钮 4.章节排行按钮 5.伤害排行按钮
    self.buttonArr = {TFDirector:getChildByPath(ui,'btn_pageleft'),TFDirector:getChildByPath(ui,'btn_pageright'),
    TFDirector:getChildByPath(ui,'btn_baoxiang'),TFDirector:getChildByPath(ui,'btn_zjph'),TFDirector:getChildByPath(ui,'btn_shph')}
    for k,v in pairs(self.buttonArr) do
       v:setTag(k)
       v.logic = self
    end

    self.img_bg = TFDirector:getChildByPath(ui,'Image_HoushanLayer_2')
    self.panel_list = TFDirector:getChildByPath(ui,'panel_list')
    self.txt_chapter = TFDirector:getChildByPath(ui,'txt_chapter')
    self.bar_exp1 = TFDirector:getChildByPath(ui,'bar_exp1') 
    self.txt_jindu = TFDirector:getChildByPath(ui,'txt_jindu')  
    self.shengyucishu = TFDirector:getChildByPath(ui,'LabelBMFont_HoushanLayer_1')
    self.shengyulabel = TFDirector:getChildByPath(ui,'txt_jr')
    self.img_map = TFDirector:getChildByPath(ui, 'img_map')
    local map_eft = Public:addEffect("jingzhongjie3", self.img_map, 180, 200, 1)
    map_eft:setScale(2.0)

    local pageView = TPageView:create()
    self.pageView = pageView

    pageView:setBounceEnabled(false)
    pageView:setTouchEnabled(true)
    pageView:setBackGroundColorType(TF_LAYOUT_COLOR_NONE)
    pageView:setSize(self.panel_list:getContentSize())
    pageView:setPosition(self.panel_list:getPosition())
    pageView:setAnchorPoint(self.panel_list:getAnchorPoint())

    local function onPageChange()
        self:onPageChange();
    end
    pageView:setChangeFunc(onPageChange)

    local function itemAdd(index)
        return self:addPage(index);
    end
    pageView:setAddFunc(itemAdd)

    self.panel_list:addChild(pageView)

    Public:addEffectWidthPosY("cloud2", self.img_bg, 10)
    Public:addEffectWidthPosY("cloud1", self.panel_list, 100)
end

function HoushanLayer:loadData(chapterIndex)
    self.selectIndex = chapterIndex
    self:refreshMissionList(chapterIndex, false)
end

function HoushanLayer:refreshMissionList(pageIndex, bgAnim)
    self.pageView:_removeAllPages();
    self.pageView:setMaxLength(self.chapterNum)
    self.pageList        = {};
    self:showInfoForPage(pageIndex, bgAnim);
    self.pageView:InitIndex(pageIndex);
end

--添加滑动页
function HoushanLayer:addPage(pageIndex)
    local pagepanel = TFPanel:create();
    pagepanel:setSize(self.panel_list:getContentSize())
    local page = nil
    local function addMap()
        if self.pageMapNode == nil then
            page = createUIByLuaNew("lua.uiconfig_mango_new.faction.HoushanMapItem");
            self.pageMapNode = page
            self.pageMapNode:retain()
        end
        page = self.pageMapNode:clone()
        page:setSize(self.panel_list:getContentSize())
        pagepanel:addChild(page);

        -- local zhangjieInfo = HoushanManager:getGuildZone()
        -- local img_map = TFDirector:getChildByPath(page, 'img_map');
        -- img_map:setTexture("bg_jpg/" .. zhangjieInfo[pageIndex].map_img .. ".jpg");
        -- img_map:setTexture("bg_jpg/houshanpoint/" .. zhangjieInfo[pageIndex].map_img .. ".png");

        -- local contentSize = page:getContentSize()
        -- img_map:setPosition(ccp(contentSize.width/2,contentSize.height/2))
        -- local mappoint = TFImage:create("bg_jpg/houshanpoint/" .. zhangjieInfo[pageIndex].hspoint_imp .. ".png")
        -- img_map:addChild(mappoint,21)

        self:updateBossInfo(pageIndex,page)
    end
    addMap()
    self.pageList[pageIndex] = pagepanel; 
    return pagepanel;
end

function HoushanLayer:onPageChange()
    local pageIndex = self.pageView:_getCurPageIndex()
    self:showInfoForPage(pageIndex, true);
end

--按钮回到函数
function HoushanLayer.onButtonClick(sender)
	-- body
    local tag = sender:getTag()
    local self = sender.logic
    if tag == 1 then
        --左翻按钮回调
        local pageIndex = self.pageView:getCurPageIndex() ;
        self.pageView:scrollToPage(pageIndex - 1);
    elseif tag == 2 then
        --右翻按钮回调
        local pageIndex = self.pageView:getCurPageIndex() ;
        self.pageView:scrollToPage(pageIndex + 1);
    elseif tag == 3 then
        --奖励排行按钮回调
        FactionManager:openHoushanRewardLayer(self.selectIndex)
    elseif tag == 4 then
        --章节排行按钮回调
        FactionManager:openZonePassRank(self.selectIndex)
    elseif tag == 5 then
        --伤害排行按钮回调
        FactionManager:openCheckPointRank(self.selectIndex)
    end
end

function HoushanLayer:showInfoForPage(pageIndex,bgAnim)
    local pageCount = self.chapterNum
    if pageIndex == 1 then
        self.buttonArr[1]:setVisible(false)
        self.buttonArr[2]:setVisible(true)
    elseif pageIndex == pageCount then
        self.buttonArr[1]:setVisible(true)
        self.buttonArr[2]:setVisible(false)
    else
        self.buttonArr[1]:setVisible(true)
        self.buttonArr[2]:setVisible(true)
    end
    
    self.selectIndex = pageIndex
    self:showUIData(pageIndex, bgAnim)
end

function HoushanLayer:showBgAnimation(map_img, bgAnim)
    self.img_map:setAlpha(1)
    self.img_map:setScale(1)
    TFDirector:killTween(self.bgFadeIn)
    TFDirector:killTween(self.bgFadeOut)
    if bgAnim then
        self.bgFadeIn = 
        {
            target = self.img_map,
            {
                duration = 0.2,
                alpha = 1,
                scale = 1
            }
        }
        self.bgFadeOut = 
        {
            target = self.img_map,
            {
                duration = 0.1,
                alpha = 0,
                scale = 1.5
            },
            onComplete = function ()
                self.img_map:setTexture("bg_jpg/houshanpoint/" .. map_img .. ".png")
                TFDirector:toTween(self.bgFadeIn)
            end
        }
        TFDirector:toTween(self.bgFadeOut)
    end
end

--显示UI数据
function HoushanLayer:showUIData(pageIndex, bgAnim)
    -- body
   -- local zhangjie = {"第一章   ","第二章   ","第三章   ","第四章   ","第五章   ","第六章   ","第七章   ","第八章   ","第九章   ","第十章   "}
    local zhangjie = localizable.houshanLayer_chapter
    local guildzone = HoushanManager:getGuildZone()
    local zoneDpsAward = HoushanManager:getGuildZoneDpsAwardByZoneId(pageIndex)
    local zonePersonalInfo = HoushanManager:getZonePersonalInfoByZoneId(pageIndex)

    local txt_chapterName = stringUtils.format(localizable.houshanLayer_chapter,numberToChinese(pageIndex),guildzone[pageIndex].name)  
    self.txt_chapter:setText(txt_chapterName)

    local zoneDpsNum = #zoneDpsAward
    print('zonePersonalInfozonePersonalInfo = ',zonePersonalInfo)
    if zonePersonalInfo == nil then
        self.bar_exp1:setPercent(0)
        self.txt_jindu:setText("0" .. "/" .. zoneDpsAward[zoneDpsNum].hurt)
        self.shengyucishu:setText(2)
    else
        local checkpoints = zonePersonalInfo.checkpoints
        print('checkpointscheckpoints = ',checkpoints)
        if checkpoints == nil then
            self.bar_exp1:setPercent(0)
            self.txt_jindu:setText("0" .. "/" .. zoneDpsAward[zoneDpsNum].hurt)
        else
            local hurtall = 0
            for k,v in pairs(checkpoints) do
                hurtall = v.hurt + hurtall
            end
            self.bar_exp1:setPercent(hurtall/zoneDpsAward[zoneDpsNum].hurt*100)
            self.txt_jindu:setText(hurtall .. "/" .. zoneDpsAward[zoneDpsNum].hurt)
        end
    end

    local chapterInfo = HoushanManager:getGuildZoneInfoByZoneId(pageIndex)
    if chapterInfo == nil then
        self.shengyucishu:setVisible(false)
        --self.shengyulabel:setText("暂未开启")
        self.shengyulabel:setText(localizable.commom_no_open2)
        self.buttonArr[3]:setTouchEnabled(false)
        self.buttonArr[3]:setGrayEnabled(true)
        self.buttonArr[4]:setTouchEnabled(false)
        self.buttonArr[4]:setGrayEnabled(true)
        self.buttonArr[5]:setTouchEnabled(false)
        self.buttonArr[5]:setGrayEnabled(true)
    elseif chapterInfo.pass == true then
        self.shengyucishu:setVisible(false)
        --self.shengyulabel:setText("已通关")
        self.shengyulabel:setText(localizable.common_tonguan)
        self.buttonArr[3]:setTouchEnabled(true)
        self.buttonArr[3]:setGrayEnabled(false)
        self.buttonArr[4]:setTouchEnabled(true)
        self.buttonArr[4]:setGrayEnabled(false)
        self.buttonArr[5]:setTouchEnabled(true)   
        self.buttonArr[5]:setGrayEnabled(false)
    else
        if chapterInfo.zoneId ~= 0 then
            self.shengyucishu:setVisible(true)
            self.buttonArr[3]:setTouchEnabled(true)
            self.buttonArr[3]:setGrayEnabled(false)  
            self.buttonArr[4]:setTouchEnabled(true)
            self.buttonArr[4]:setGrayEnabled(false)
            self.buttonArr[5]:setTouchEnabled(true)   
            self.buttonArr[5]:setGrayEnabled(false)
            if zonePersonalInfo == nil then
                self.shengyulabel:setText(localizable.houshanLayer_times)
                --self.shengyulabel:setText("今日挑战次数：")
                self.shengyucishu:setText(2)
            elseif zonePersonalInfo.challengeCount > 2 then
                self.shengyucishu:setText(0)
                --self.shengyulabel:setText("今日挑战次数：")
                self.shengyulabel:setText(localizable.houshanLayer_times)
            else
                local attackNum = zonePersonalInfo.challengeCount
                self.shengyucishu:setText(2-attackNum)
                --self.shengyulabel:setText("今日挑战次数：")
                self.shengyulabel:setText(localizable.houshanLayer_times)
            end   
        else
            self.shengyucishu:setVisible(false)
            --self.shengyulabel:setText("暂未开启")
            self.shengyulabel:setText(localizable.commom_no_open2)
            self.buttonArr[3]:setTouchEnabled(false)
            self.buttonArr[3]:setGrayEnabled(true)
            self.buttonArr[4]:setTouchEnabled(false)
            self.buttonArr[4]:setGrayEnabled(true)
            self.buttonArr[5]:setTouchEnabled(false)
            self.buttonArr[5]:setGrayEnabled(true)
        end
    end

    self:showBgAnimation(guildzone[pageIndex].map_img, bgAnim)
    self:setRewardEffect(pageIndex)
end

function HoushanLayer:updateBossInfo(pageIndex,page)
    -- body
    --服务器章节信息
    self.unlockBoss = 0
    local chapterInfo = HoushanManager:getGuildZoneInfoByZoneId(pageIndex)
    print("chapterInfo = ",chapterInfo)
    local oneChapterInfo = HoushanManager:getHoushanListByZoneId(pageIndex)
    local bossarr = {}
    local bossNum = #oneChapterInfo
    local bossState = 1         --1.未解锁 2.已开启 3.战斗中 4.已击杀
    local checkpoints = nil
    if chapterInfo~=nil then
        checkpoints = chapterInfo.checkpoints
        local function sortCheckPointId(a,b)
            return a.checkpointId < b.checkpointId
        end
        table.sort(checkpoints, sortCheckPointId)
    end

    for i=1,bossNum do
        local checkpointId = 100+i
        local index = i
        if chapterInfo==nil then
            if pageIndex==1 and i==1 then
                bossState = 2
                self.unlockBoss = 1
            else
                bossState = 1
            end
        else
            local checkpoint = chapterInfo.checkpoints[i]
            checkpointId = checkpoint.checkpointId
            index = checkpointId-100*pageIndex

            if chapterInfo.zoneId == 0 then
                bossState = 1
            else
                if chapterInfo.pass == true then
                    bossState = 4
                else
                    local time = MainPlayer:getNowtime()
                    local playerid = MainPlayer:getPlayerId() 
                    local severplayerId = chapterInfo.lockPlayerId

                    if checkpoint.pass == true then
                        bossState = 4
                    elseif self.unlockBoss == 0 then
                        self.unlockBoss = i
                        bossState = 2
                        if severplayerId == 0 or playerid == severplayerId then
                            bossState = 2
                        elseif chapterInfo.lockTime ~= 0 and time<math.floor(chapterInfo.lockTime/1000) then
                            bossState = 3
                        end
                    else
                         bossState = 1
                    end

                end
            end 
        end
        --print("bossState:",bossState)
        if next(self.bosslist) == nil then
            local bossItem = require('lua.logic.faction.HoushanBoss'):new()
            bossItem:setPosition(ccp(oneChapterInfo[index].missonPosX,oneChapterInfo[index].missonPosY))
            page:addChild(bossItem,3)
            bossItem:setData(pageIndex,index,bossState,chapterInfo,self)
            table.insert(bossarr,bossItem)
        elseif next(self.bosslist) ~= nil and self.bosslist[pageIndex] == nil then
            local bossItem = require('lua.logic.faction.HoushanBoss'):new()
            bossItem:setPosition(ccp(oneChapterInfo[index].missonPosX,oneChapterInfo[index].missonPosY))
            page:addChild(bossItem,3)
            bossItem:setData(pageIndex,index,bossState,chapterInfo,self)
            table.insert(bossarr,bossItem)
        else
            bossarr = self.bosslist[pageIndex]
            local bossItem = bossarr[index]
            bossItem:setData(pageIndex,index,bossState,chapterInfo,self)
        end
        
    end
    self.bosslist[pageIndex] = bossarr
    if self.IsClickItem == true then
        local bossCheckPoint = pageIndex*100 + self.clickBoss
        local islock = FactionManager:getZoneCheckPointState(pageIndex, bossCheckPoint )
        if islock == 2 then
            local zonePersonalInfo = HoushanManager:getZonePersonalInfoByZoneId(pageIndex) or {}
            local challengeNum = zonePersonalInfo.challengeCount or 0
            if challengeNum >= 2 then
                --toastMessage("挑战次数不足！")
                toastMessage(localizable.common_no_fight_times)
            else
                HoushanManager:lockedZone(pageIndex)
            end
        end
        self.IsClickItem = false
    end
end

function HoushanLayer:setRewardEffect(pageIndex)
    -- body
    local ishaveEffect = FactionManager:isCanGetRewardByZoneId(pageIndex)
    if ishaveEffect == true then
        if self.rewardeffect == nil then
            TFResourceHelper:instance():addArmatureFromJsonFile("effect/ui/northClimbBox.xml")
            self.rewardeffect = TFArmature:create("northClimbBox_anim")
            if self.rewardeffect == nil then
                return
            end
            self.rewardeffect:setAnimationFps(GameConfig.ANIM_FPS)
            self.rewardeffect:playByIndex(0, -1, -1, 1)
            self.rewardeffect:setZOrder(10)
            self.buttonArr[3]:addChild(self.rewardeffect)
            
        else
            self.rewardeffect:setVisible(true)
            
        end
    else
        if self.rewardeffect~= nil then
            self.rewardeffect:setVisible(false)
        end
    end
    
end

function HoushanLayer:removeUI()
    if self.pageMapNode then
        self.pageMapNode:release()
        self.pageMapNode = nil
    end

    self.super.removeUI(self)
end

-----断线重连支持方法
function HoushanLayer:onShow()
    self.super.onShow(self)
    self.generalHead:onShow()
end

function HoushanLayer:registerEvents()
    self.super.registerEvents(self)

    if self.generalHead then
        self.generalHead:registerEvents()
    end

    for k,v in pairs(self.buttonArr) do
        v:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onButtonClick))
    end

    self.updateHoushanCallBack = function(event)
        self:updateBossInfo(self.selectIndex,nil)
        self:showUIData(self.selectIndex, false)
    end;
    TFDirector:addMEGlobalListener(HoushanManager.EVENT_UPDATE_HOUSHAN ,self.updateHoushanCallBack) ;

    self.updateRewardEffectCallBack = function(event)
        self:setRewardEffect(self.selectIndex)
    end;
    TFDirector:addMEGlobalListener(HoushanManager.EVENT_UPDATE_HOUSHANREWARDEFFECT ,self.updateRewardEffectCallBack ) ;
end

function HoushanLayer:removeEvents()
	if self.generalHead then
        self.generalHead:removeEvents()
    end

    for k,v in pairs(self.buttonArr) do
        v:removeMEListener(TFWIDGET_CLICK)
    end

    for k,v in pairs(self.bosslist) do
        for m,n in pairs(v) do
            n:removeEvents()
        end
    end
    TFDirector:removeMEGlobalListener(HoushanManager.EVENT_UPDATE_HOUSHAN ,self.updateHoushanCallBack);
    TFDirector:removeMEGlobalListener(HoushanManager.EVENT_UPDATE_HOUSHANREWARDEFFECT ,self.updateRewardEffectCallBack);
    self.updateHoushanCallBack = nil
    self.updateRewardEffectCallBack = nil

    self.super.removeEvents(self)
end

function HoushanLayer:dispose()
    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end

    self.super.dispose(self)
end

return HoushanLayer
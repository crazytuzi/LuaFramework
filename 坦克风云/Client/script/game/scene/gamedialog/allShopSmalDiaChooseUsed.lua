allShopSmalDiaChooseUsed=smallDialog:new()

function allShopSmalDiaChooseUsed:new(layerNum,getTb)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.layerNum=layerNum
    nc.useDataTb = getTb
    nc.wholeBgSp=nil
    nc.dialogWidth=nil
    nc.dialogHeight=nil
    nc.isTouch=nil
    nc.bgLayer=nil
    nc.bgSize=nil
    nc.dialogLayer=nil

    return nc
end

function allShopSmalDiaChooseUsed:init()
    base:addNeedRefresh(self)
    self.dialogWidth=500
    self.dialogHeight=400

    self.isTouch=nil
    local addW = 110
    local addH = 130
    local function nilFunc()
    end
    local function closeCall( )

        return self:close()
    end

    local titleStr =  (self.useDataTb and self.useDataTb["titleStr"]) and self.useDataTb["titleStr"] or getlocal("dialog_title_prompt")
    local dialogBg = nil
    local useClose = true
    if self.useDataTb and self.useDataTb.subTitleTb then
        self.subTitleTb = self.useDataTb.subTitleTb
        if SizeOfTable(self.subTitleTb) == 1 then
            self.dialogHeight = 250
        end
        self.selectShopType = self.useDataTb.selectShopType
    end
        dialogBg = G_getNewDialogBg(CCSizeMake(self.dialogWidth,self.dialogHeight),titleStr,30,nil,self.layerNum,useClose,closeCall)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self:show()
    self.dialogLayer:addChild(self.bgLayer,1)
    self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)
    
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
    touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(250)
    touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg)

    if self.useDataTb then
        self:addObjDescAndBtn()
    end

    sceneGame:addChild(self.dialogLayer,self.layerNum)
    self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    return self.dialogLayer
end

function allShopSmalDiaChooseUsed:addObjDescAndBtn()
    local sDesNums = SizeOfTable(self.subTitleTb)
    local usePosyScale = {0.75,0.25}
    if self.useDataTb and self.useDataTb.selectShopType then
        sDesNums = self:specialHandle(self.useDataTb.selectShopType,sDesNums)
    end
    local function goToNewDiaCall(tag,obj)
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        print("tag====>>>>",tag)
        self:gotoNow(tag)
    end
    -- print("sDesNums=====>>>>",sDesNums,SizeOfTable(self.subTitleTb))
    for i=1,sDesNums do
        local adaWidth = 100
        if G_isAsia() == false then
            adaWidth = 200
        end 
        local gotoStr = GetTTFLabelWrap(self.subTitleTb[i],24,CCSizeMake(self.dialogWidth - adaWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
        gotoStr:setAnchorPoint(ccp(0,0.5))
        self.bgLayer:addChild(gotoStr)

        local gotoMenu = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",goToNewDiaCall,i,getlocal("activity_heartOfIron_goto"),33)
        gotoMenu:setScale(0.7)
        gotoMenu:setAnchorPoint(ccp(1,0.5))
        gotBtn=CCMenu:createWithItem(gotoMenu);
        gotBtn:setTouchPriority(-(self.layerNum-1)*20-3);
        self.bgLayer:addChild(gotBtn)

        if sDesNums == 1 then
            gotoStr:setPosition(ccp(25,(self.dialogHeight - 66) *0.5))
        else
            gotoStr:setPosition(ccp(25,(self.dialogHeight - 66) *usePosyScale[i]))
        end
        gotBtn:setPosition(ccp(self.dialogWidth - 30,gotoStr:getPositionY()))
        
    end

    if sDesNums == 2 then
        local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function()end)
        lineSp:setContentSize(CCSizeMake(self.dialogWidth - 40,lineSp:getContentSize().height))
        lineSp:setPosition(ccp(self.bgLayer:getContentSize().width * 0.5,(self.dialogHeight - 66) * 0.5))
        self.bgLayer:addChild(lineSp)
    end
end
function allShopSmalDiaChooseUsed:specialHandle(selectShopType,oldNum)
    
    if selectShopType == "army" then
        if base.allianceWar2Switch == 0 and base.isAllianceWarSwitch == 0 then
            return 1
        end
        return oldNum
    else
        return oldNum
    end
end

function allShopSmalDiaChooseUsed:gotoNow(btnNum)
    local selectShopType = self.useDataTb.selectShopType or ""
    local useBtnNum = btnNum
    if self:isCanGo(selectShopType,btnNum) == false  then
        do return end
    end
    activityAndNoteDialog:closeAllDialog()

    if selectShopType =="feat" then
        allShopVoApi:removeSelfAllDia()
        self:close()--小板子
    end
        -- print("self.layerNum--allShopSmalDiaChooseUsed---->>>>",self.layerNum)
        if selectShopType == "army" then
            if btnNum == 1 then--军团科技
                    local function realInit()
                        allShopVoApi:removeSelfAllDia()
                        self:close()--小板子
                        -- if allianceVoApi:isHasAlliance()==false then
                        --     require "luascript/script/game/scene/gamedialog/allianceDialog/allianceDialog"
                        --     local td=allianceDialog:new(1,3)
                        --     G_AllianceDialogTb[1]=td
                        --     local tbArr={getlocal("recommendList"),getlocal("alliance_list_scene_create")}
                        --     local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("alliance_list_scene_name"),true,3)
                        --     sceneGame:addChild(dialog,3)

                        -- else
                        --     allianceEventVoApi:clear()
                        --     require "luascript/script/game/scene/gamedialog/allianceDialog/allianceExistDialog"
                        --     local td=allianceExistDialog:new(1,3)
                        --     G_AllianceDialogTb[1]=td
                        --     local tbArr={getlocal("alliance_info_title"),getlocal("alliance_function"),getlocal("alliance_list_scene_list")}
                        --     local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("alliance_list_scene_name"),true,3)
                        --     sceneGame:addChild(dialog,3)
                        --     td:tabClick(1)

                        --     G_goAllianceFunctionDialog("alliance_technology",3 + 1)
                        -- end
                        allianceVoApi:showAllianceDialog(3,"alliance_technology")
                    end
                    local delay = CCDelayTime:create(0.4)
                    local fc= CCCallFunc:create(realInit)
                    local acArr=CCArray:create()
                    acArr:addObject(delay)
                    acArr:addObject(fc)
                    local seq=CCSequence:create(acArr)
                    self.dialogLayer:runAction(seq)
            else--军团战

                local function realInit()
                    allShopVoApi:removeSelfAllDia()
                    self:close()--小板子
                    
                    require "luascript/script/game/scene/gamedialog/arenaDialog/arenaTotalDialog"
                    local td=arenaTotalDialog:new(3)
                    local tbArr={}
                    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("arena_total"),true,3)
                    sceneGame:addChild(dialog,3)

                    if base.allianceWar2Switch == 1 then--新版
                          local td=allianceWar2OverviewDialog:new(4)
                          local tbArr={}
                          local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("alliance_war"),true,4)
                          sceneGame:addChild(dialog,4)
                    elseif base.isAllianceWarSwitch == 1 then
                          local td=allianceWarOverviewDialog:new(4)
                          local tbArr={}
                          local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("alliance_war"),false,4)
                          sceneGame:addChild(dialog,4)
                    end

                end
                local delay = CCDelayTime:create(0.4)
                local fc= CCCallFunc:create(realInit)
                local acArr=CCArray:create()
                acArr:addObject(delay)
                acArr:addObject(fc)
                local seq=CCSequence:create(acArr)
                self.dialogLayer:runAction(seq)
            end
        elseif selectShopType == "drill" then--演习
                local function realInit()
                    allShopVoApi:removeSelfAllDia()
                    self:close()--小板子

                    require "luascript/script/game/scene/gamedialog/arenaDialog/arenaTotalDialog"
                    local td=arenaTotalDialog:new(3)
                    local tbArr={}
                    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("arena_total"),true,3)
                    sceneGame:addChild(dialog,3)

                    require "luascript/script/game/scene/gamedialog/shambattleDialog/shamBattleDialog"
                    local td=shamBattleDialog:new()
                    local tbArr={}
                    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("arena_title"),true,4)
                    sceneGame:addChild(dialog,4)
                end
                
                local delay = CCDelayTime:create(0.4)
                local fc= CCCallFunc:create(realInit)
                local acArr=CCArray:create()
                acArr:addObject(delay)
                acArr:addObject(fc)
                local seq=CCSequence:create(acArr)
                self.dialogLayer:runAction(seq)

        elseif selectShopType =="expe" then--远征
                local function realInit()
                    allShopVoApi:removeSelfAllDia()
                    self:close()--小板子
                    return G_goToDialog("eb",4)
                end
                local delay = CCDelayTime:create(0.4)
                local fc= CCCallFunc:create(realInit)
                local acArr=CCArray:create()
                acArr:addObject(delay)
                acArr:addObject(fc)
               local seq=CCSequence:create(acArr)
               self.dialogLayer:runAction(seq)
        elseif selectShopType == "diff" then--异元
                local function realInit()
                    allShopVoApi:removeSelfAllDia()
                    self:close()--小板子

                    require "luascript/script/game/scene/gamedialog/arenaDialog/arenaTotalDialog"
                    local td=arenaTotalDialog:new(3)
                    local tbArr={}
                    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("arena_total"),true,3)
                    sceneGame:addChild(dialog,3)

                    require "luascript/script/game/scene/gamedialog/dimensionalWar/dimensionalWarDialog"
                    local td=dimensionalWarDialog:new()
                    local tbArr={}
                    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("dimensionalWar_title"),true,4)
                    sceneGame:addChild(dialog,4)

                end
                local delay = CCDelayTime:create(0.4)
                local fc= CCCallFunc:create(realInit)
                local acArr=CCArray:create()
                acArr:addObject(delay)
                acArr:addObject(fc)
                local seq=CCSequence:create(acArr)
                self.dialogLayer:runAction(seq)
        elseif selectShopType == "seiko" then--精工
                local function realInit()
                    allShopVoApi:removeSelfAllDia()
                    self:close()--小板子

                    require "luascript/script/game/scene/gamedialog/heroDialog/heroTotalDialog"
                    local td=heroTotalDialog:new()
                    local tbArr={}
                    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("sample_build_name_12"),true,3)
                    sceneGame:addChild(dialog,3)

                    require "luascript/script/game/scene/gamedialog/heroDialog/heroEquipLabDialog" 
                    local td=heroEquipLabDialog:new(false)
                    local tbArr={}
                    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("equip_lab_title"),true,4)
                    sceneGame:addChild(dialog,4)
                end

                local delay = CCDelayTime:create(0.4)
                local fc= CCCallFunc:create(realInit)
                local acArr=CCArray:create()
                acArr:addObject(delay)
                acArr:addObject(fc)
                local seq=CCSequence:create(acArr)
                self.dialogLayer:runAction(seq)
        elseif selectShopType =="feat" then--军功
                mainUI:changeToWorld()
        elseif selectShopType =="matr" then--矩阵
            if otherGuideMgr:checkGuide(18)==false and playerVoApi:getPlayerLevel()==armorCfg.openLvLimit then
                allShopVoApi:removeSelfAllDia()
                self:close()
                armorMatrixVoApi:showArmorMatrixDialog(3)
                do return end
            end
            -- print("11111111111",otherGuideMgr:checkGuide(18))

                    if btnNum == 1 then
                        local function realInit()
                            allShopVoApi:removeSelfAllDia()
                            self:close()

                            if armorMatrixVoApi:canOpenArmorMatrixDialog(true) then
                                local function showCallback()
                                    armorMatrixVoApi:showArmorMatrixDialog(3)
                                    armorMatrixVoApi:showRecruitDialog(4)
                                end
                                armorMatrixVoApi:armorGetData(showCallback)
                            end
                        end

                        local delay = CCDelayTime:create(0.4)
                        local fc= CCCallFunc:create(realInit)
                        local acArr=CCArray:create()
                        acArr:addObject(delay)
                        acArr:addObject(fc)
                        local seq=CCSequence:create(acArr)
                        self.dialogLayer:runAction(seq)
                    else
                        local function realInit()
                            allShopVoApi:removeSelfAllDia()
                            self:close()
                            if armorMatrixVoApi:canOpenArmorMatrixDialog(true) then
                                local function showCallback()
                                    armorMatrixVoApi:showArmorMatrixDialog(3)
                                    armorMatrixVoApi:showBagDialog(4)
                                end
                                armorMatrixVoApi:armorGetData(showCallback)
                            end
                        end

                        local delay = CCDelayTime:create(0.4)
                        local fc= CCCallFunc:create(realInit)
                        local acArr=CCArray:create()
                        acArr:addObject(delay)
                        acArr:addObject(fc)
                        local seq=CCSequence:create(acArr)
                        self.dialogLayer:runAction(seq)

                    end
        else
            print("error~~~~~~~~~~~~~~selectShopType=====>>>>",selectShopType)
        end
        
end

function allShopSmalDiaChooseUsed:isCanGo(selectKey,useNum)--商店跳转功能 等级限制提示
    local curLv = playerVoApi:getPlayerLevel()--needRoleLevel
    local NeedTipLv = 0
    if selectKey == "army" then
        if useNum == 1 and curLv < 5 then
            NeedTipLv = 5
        elseif useNum == 2 then
            local selfAlliance=allianceVoApi:getSelfAlliance()
            if(selfAlliance==nil or selfAlliance.aid<=0)then
                  smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allianceWar_errorNeedAlliance"),30)
                 return false
            end
        end
    elseif selectKey == "drill" and curLv < 10 then
        NeedTipLv = 10
    elseif selectKey == "expe" and curLv < 25 then
        NeedTipLv = 25
    elseif selectKey == "diff" and curLv < 30 then
        NeedTipLv = 30
    elseif selectKey == "seiko" and curLv < 30 then
        NeedTipLv = 30
    elseif selectKey == "feat" and curLv < 3 then
        NeedTipLv = 3
    elseif selectKey == "matr" and curLv < 3 then        
        NeedTipLv = 3
    end

    if selectKey == "feat" and rpShopVoApi:checkShopOpen() == false then -- 军功不到开放时间
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("not_to_time"),30)
        return false
    end

    if NeedTipLv > 0 then
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("needRoleLevel",{NeedTipLv}),30)
        return false
    end
    return true
end
function allShopSmalDiaChooseUsed:dispose()
    self.id = nil
    self.checkSp = nil
    self.wholeBgSp=nil
    self.dialogWidth=nil
    self.dialogHeight=nil
    self.awardBtn = nil
    self.isTouch=nil
    self.bgLayer=nil
    self.bgSize=nil
    self.dialogLayer=nil
    self.timeLb = nil
end


function allShopSmalDiaChooseUsed:close()
    self.awardBtn = nil
    self.timeLb = nil
    self.checkSp = nil
    self.wholeBgSp=nil
    self.dialogWidth=nil
    self.dialogHeight=nil
    self.isTouch=nil
    self.bgLayer=nil
    self.bgSize=nil
    if self and self.dialogLayer then
        self.dialogLayer:removeFromParentAndCleanup(true)
        self.dialogLayer=nil
    end
    base:removeFromNeedRefresh(self)
end
--[[
******后山Boss信息界面层*******

    -- by yao
    -- 2015/12/25
]]

local HoushanBossDetail = class("HoushanBossDetail", BaseLayer)

function HoushanBossDetail:ctor(data)
    self.super.ctor(self,data)
    self.closebtn = nil         --关闭按钮
    self.btn_army = nil         --布阵按钮
    self.btn_attack = nil       --挑战按钮
    self.txt_title = nil        --标题
    -- self.img_boss = nil         --boss图片
    self.txt_number = nil       --挑战次数
    self.txt_zhanli = nil       --推荐战力
    self.txt_windetail = nil    --击杀奖励的经验和繁荣度等
    self.daojishi = nil         --倒计时
    self.rolebutton = {}        --人物按钮
    self.txt_duihua = nil       --对话
    self.tableView = nil        --tableview
    self.txt_point = nil        --今日挑战次数文字

    self.chapter = nil          --章节
    self.bossIndex = nil        --第几个boss
    self.updateHoushanDetail = nil
    self.tenMinuteTime = nil    --十分钟限制
    self.istenMinute = false    --是否挑战了十分钟
    self.xuetiao = {}           --血条
    self.xuetiaodi = {}         --血条底
    self.wangpic = {}           --亡字
    self.Isclose = false        --是否关闭界面
   
    self:init("lua.uiconfig_mango_new.faction.BossDetail")
end

function HoushanBossDetail:initUI(ui)
	self.super.initUI(self,ui)

    self.closebtn   = TFDirector:getChildByPath(ui,'Btn_close')
    self.btn_army   = TFDirector:getChildByPath(ui,'btn_army')
    self.btn_attack = TFDirector:getChildByPath(ui,'btn_attack')

    self.closebtn.logic = self
    self.closebtn:setTag(1)
    self.btn_army.logic = self
    self.btn_army:setTag(2)
    self.btn_attack.logic = self
    self.btn_attack:setTag(3)

    -- self.img_boss       = TFDirector:getChildByPath(ui, 'img_boss')
    self.panel_boss     = TFDirector:getChildByPath(ui, 'panel_boss')
    self.txt_number     = TFDirector:getChildByPath(ui, 'txt_number')
    self.txt_zhanli     = TFDirector:getChildByPath(ui, 'txt_zhanli')
    self.txt_windetail  = TFDirector:getChildByPath(ui, 'txt_windetail')
    self.txt_title      = TFDirector:getChildByPath(ui, 'txt_title')
    self.daojishi       = TFDirector:getChildByPath(ui, 'Label_BossDetail_1')
    self.txt_duihua     = TFDirector:getChildByPath(ui, 'txt_duihua')
    self.panel_reward   = TFDirector:getChildByPath(ui, 'panel_reward')
    self.txt_point      = TFDirector:getChildByPath(ui, 'txt_point')

    self.rolebutton     = {}
    for i=1,9 do
        local btnName = "panel_item" .. i;
        self.rolebutton[i] = TFDirector:getChildByPath(ui, btnName);
        btnName = "btn_icon"..i;
        self.rolebutton[i].bg = TFDirector:getChildByPath(ui, btnName);
        self.rolebutton[i].bg:setVisible(false);
        self.rolebutton[i].icon = TFDirector:getChildByPath(self.rolebutton[i].bg ,"img_touxiang");
        self.rolebutton[i].icon:setVisible(false);
        self.rolebutton[i].img_zhiye = TFDirector:getChildByPath(self.rolebutton[i], "img_zhiye");
        self.rolebutton[i].img_zhiye:setVisible(false);
        self.rolebutton[i].quality = TFDirector:getChildByPath(ui, btnName);

        --血条底
        local xtd = TFImage:create("ui_new/bloodybattle/xz_xueliangdirendi.png")
        xtd:setPosition(ccp(5,-35))
        self.rolebutton[i].bg:addChild(xtd,1)
        self.rolebutton[i].xuetiaodi = xtd
        --血条
        local xt = TFLoadingBar:create()
        xt:setTexture("ui_new/bloodybattle/xz_xueliangdiren.png")
        xt:setPosition(ccp(10,-35))
        self.rolebutton[i].bg:addChild(xt,3)
        self.rolebutton[i].xuetiao = xt
        --亡字
        local wz = TFImage:create("ui_new/bloodybattle/xz_wang.png")
        wz:setPosition(ccp(20,20))
        self.rolebutton[i].bg:addChild(wz,3)
        self.rolebutton[i].wang = wz
    end
end

function HoushanBossDetail:setData(chapter,bossIndex)
    -- body
    self.chapter = chapter
    self.bossIndex = bossIndex

    local oneChapterInfo = HoushanManager:getHoushanListByZoneId(chapter)
    local severInfo = HoushanManager:getGuildZoneInfoByZoneId(chapter)
    local zonePersonalInfo = HoushanManager:getZonePersonalInfoByZoneId(chapter)

    -- self.img_boss:setTexture("icon/rolebig/" .. oneChapterInfo[bossIndex].icon .. ".png")
    if self.armature then
        self.armature:removeFromParent()
    end
    local armatureID = oneChapterInfo[bossIndex].rolebig
    ModelManager:addResourceFromFile(1, armatureID, 1)
    self.armature = ModelManager:createResource(1, armatureID)
    self.panel_boss:addChild(self.armature)
    ModelManager:playWithNameAndIndex(self.armature, "stand", -1, 1, -1, -1)

    self.txt_zhanli:setText(oneChapterInfo[bossIndex].power)
    --self.txt_windetail:setText("击杀：帮派经验+" .. oneChapterInfo[bossIndex].exp .. "     帮派繁荣度+" .. oneChapterInfo[bossIndex].boom)
    self.txt_windetail:setText(stringUtils.format(localizable.houshanBoss_kill_tips,oneChapterInfo[bossIndex].exp,oneChapterInfo[bossIndex].boom))
    
    self.txt_title:setText(oneChapterInfo[bossIndex].name)
    self.txt_duihua:setText(oneChapterInfo[bossIndex].description)

    --self.txt_point:setText("今日剩余次数：")
    self.txt_point:setText(localizable.houshanBoss_lefttimes)
    if zonePersonalInfo == nil then
        self.txt_number:setText(2)
    elseif zonePersonalInfo.challengeCount >= 2 then
        self.txt_number:setText(0)
    else
        local attackNum = zonePersonalInfo.challengeCount
        self.txt_number:setText(2-attackNum)
    end

    local checkpoints = {}
    local states = {}
    if severInfo ~= nil then
        checkpoints = severInfo.checkpoints
        local function sortCheckPointId(a,b)
            return a.checkpointId < b.checkpointId
        end
        table.sort(checkpoints, sortCheckPointId)     
        states = checkpoints[bossIndex].states
        --print("states333333 = ",states)
    end
    local onebossInfo = oneChapterInfo[bossIndex]
    local formations = onebossInfo.formations
    local npc = NPCData:GetNPCListByIds(formations)
    for index=1,9 do
        local role = npc[index]
        if  role ~= nil then
            self.rolebutton[index].icon:setVisible(true);
            self.rolebutton[index].icon:setTexture(role:getHeadPath());

            self.rolebutton[index].bg:setVisible(true);
            self.rolebutton[index].bg.role = role;

            self.rolebutton[index].bg.logic = self;
            self.rolebutton[index].bg:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.cellClickHandle),1);

            self.rolebutton[index].img_zhiye:setVisible(true);
            self.rolebutton[index].img_zhiye:setTexture("ui_new/fight/zhiye_".. RoleData:objectByID(role.role_id).outline ..".png");
            self.rolebutton[index].img_zhiye:setZOrder(2)
            self.rolebutton[index].img_zhiye:setPosition(ccp(-35,-30))
            
            self.rolebutton[index].quality:setTextureNormal(GetColorRoadIconByQualitySmall(role.quality))
            -- self.button[index].quality:setTextureNormal(GetRoleBgByWuXueLevel_circle_small(role.martialLevel));

            if next(states) ~= nil then
                for k,v in pairs(states) do
                    -- print("index:",index)
                    -- print("v.index:",v.index)
                    -- print("v.hp:",v.hp)
                    -- print("v.maxHp:",v.maxHp)
                    if v.index + 1 == index and v.hp == 0 then
                        self.rolebutton[index].bg:setGrayEnabled(true)
                        self.rolebutton[index].bg:setGrayEnabled(true)
                        self.rolebutton[index].xuetiao:setPercent(0)
                        self.rolebutton[index].wang:setVisible(true)
                        self.rolebutton[index].wang:setGrayEnabled(false)
                        self.rolebutton[index].bg:setTouchEnabled(false)
                    elseif v.index + 1 == index and v.hp ~= 0 then    
                        self.rolebutton[index].bg:setGrayEnabled(false) 
                        self.rolebutton[index].xuetiao:setPercent(v.hp/v.maxHp*100)
                        self.rolebutton[index].wang:setVisible(false)
                        self.rolebutton[index].bg:setGrayEnabled(false)  
                        self.rolebutton[index].bg:setTouchEnabled(true)               
                    end
                end
            end
        else
            self.rolebutton[index].img_zhiye:setVisible(false);  
            self.rolebutton[index].icon:setVisible(false);
            self.rolebutton[index].bg:setVisible(false);     
        end
    end
    self:drawReward()
    self:countdownTime()
end

function HoushanBossDetail:countdownTime()
    if self.countDownTimer then
        return
    end
    local cutDownTime = 120
    local function showCutDownString( times )
        local str
        local min = math.floor(times/60)
        local sec = times%60
        str = string.format("%02d",min)..":"..string.format("%02d",sec)     
        return str
    end
    local timeStr = showCutDownString( cutDownTime )
    self.daojishi:setText(timeStr)
    self.countDownTimer = TFDirector:addTimer(1000, -1, nil, 
        function () 
        if cutDownTime <= 0 then
            local info = HoushanManager:getHoushanListByZoneId(self.chapter)
            local checkpoint_id = info[self.bossIndex].checkpoint_id 
            timeStr = showCutDownString( cutDownTime )
            self:removeOwnTimer(self.countDownTimer)
            self.daojishi:setText(timeStr)  
            AlertManager:closeAllToLayer(self)
            HoushanManager:setTwoMinuteBackBossLayer(self)  
        else
            cutDownTime = cutDownTime - 1
            timeStr = showCutDownString( cutDownTime )
            self.daojishi:setText(timeStr)
        end
    end)
end

function HoushanBossDetail:removeUI()
	self.super.removeUI(self)
end


function HoushanBossDetail.onButtonClick(sender)
	-- body
    local tag = sender:getTag()
    local self = sender.logic
    if tag == 1 then
        self:removeOwnTimer(self.countDownTimer)
        HoushanManager:unlockZone(self.chapter)
        AlertManager:closeAllToLayer(self)
    elseif tag == 2 then
        CardRoleManager:openRoleList(false);
    elseif tag == 3 then
        local info = HoushanManager:getHoushanListByZoneId(self.chapter)
        local checkpoint_id = info[self.bossIndex].checkpoint_id
        self:removeOwnTimer(self.countDownTimer)
        self:tenMinuteTimeLimite()
        HoushanManager:requestTiaozhan(self.chapter, checkpoint_id)
        --AlertManager:close(AlertManager.TWEEN_NONE);
    end
end

function HoushanBossDetail.cellClickHandle(sender)
    local self = sender.logic;
    local role = sender.role;

    Public:ShowItemTipLayer(role.role_id, EnumDropType.ROLE, 1,role.level)
end

function HoushanBossDetail:drawReward()
    local bossInfo = HoushanManager:getHoushanListByZoneId(self.chapter)
    self.rewardList = HoushanManager:getDropItemListByBossInfo(bossInfo[self.bossIndex])

    if self.tableView ~= nil then
        self.tableView:reloadData()
        self.tableView:setScrollToBegin(false)
        return
    end

    local  tableView =  TFTableView:create()
    tableView:setTableViewSize(self.panel_reward:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    tableView:setPosition(ccp(0,0))
    self.tableView = tableView
    self.tableView.logic = self


    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, HoushanBossDetail.cellSizeForTable)
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, HoushanBossDetail.tableCellAtIndex)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, HoushanBossDetail.numberOfCellsInTableView)
    tableView:reloadData()

    -- self:addChild(self.tableView,1)
    self.panel_reward:addChild(self.tableView,1)
end

function HoushanBossDetail.cellSizeForTable(table, idx)
    return 90, 90
end

function HoushanBossDetail.tableCellAtIndex(table, idx)
    local self = table.logic
    local cell = table:dequeueCell()
    local node = nil
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true

        for i=1,3 do
            local node = Public:createIconNumNode(reward)
            node:setScale(0.7);

            node:setPosition(ccp(100*(i-1), 0))
            cell:addChild(node)
            node:setTag(600 + i)
        end
    end
    self:drawCell(cell, idx)
    return cell
end

function HoushanBossDetail.numberOfCellsInTableView(table)
    local self = table.logic
    local totalNum = self.rewardList:length()
    --local totalNum = 5
    return math.ceil(totalNum/3)
end

function HoushanBossDetail:drawCell(cell, cellIndex)
    local totalNum = self.rewardList:length()
    --local totalNum = 5

    for i=1,3 do
        local index = cellIndex * 3 + i
        local node  = cell:getChildByTag(600+i)

        node:setVisible(false)
        if index <= totalNum then
            node.index = index
            node:setVisible(true)
            self:drawRewardNode(node)
        end

    end
end

function HoushanBossDetail:drawRewardNode(node)
    local index = node.index
    local rewardItem = self.rewardList:getObjectAt(index)
    Public:loadIconNode(node,rewardItem)

    CommonManager:setRedPoint(node, MartialManager:dropRewardRedPoint(rewardItem), "dropRewardRedPoint", ccp(80,80))
end

-----断线重连支持方法
function HoushanBossDetail:onShow()
    self.super.onShow(self)
    -- print('Public:currentScene().__cname = ',Public:currentScene().__cname)
    if Public:currentScene().__cname  ~= 'HomeScene' then
        return
    end
    -- print('123123')

    local zonePersonalInfo = HoushanManager:getZonePersonalInfoByZoneId(self.chapter)
    local chapterInfo = HoushanManager:getGuildZoneInfoByZoneId(self.chapter)
    if zonePersonalInfo ~= nil  then
        if zonePersonalInfo.challengeCount >= 2 and self.Isclose == false then
            self.Isclose = true
            self:closeLayer()
            return
        end
    end
    -- print('chapterInfochapterInfoJJ',chapterInfo)
    -- print('self.Isclose',self.Isclose)
    if chapterInfo~=nil and chapterInfo.checkpoints~=nil and self.Isclose == false then
        local checkpoints = chapterInfo.checkpoints
        for k,v in pairs(checkpoints) do
            if v.checkpointId == self.chapter*100+self.bossIndex and v.pass == true then
                self.Isclose = true
                self:closeLayer()
                -- print("fffffffffffffffffffffffffff")
                return
            end
        end
    end 
    if self.istenMinute == true then
        self.istenMinute = false
        self:closeLayer()  
        HoushanManager:setTenMinuteBackBossLayer(self)       
        return 
    end
end

function HoushanBossDetail:registerEvents()
    self.super.registerEvents(self)

    self.closebtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onButtonClick))
    self.btn_army:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onButtonClick))
    self.btn_attack:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onButtonClick))

    self.updateHoushanDetail = function(event)
        self:removeOwnTimer(self.countDownTimer)
        self:setData(self.chapter,self.bossIndex)
    end;
    TFDirector:addMEGlobalListener(HoushanManager.EVENT_UPDATE_HOUSHANDETAIL ,self.updateHoushanDetail ) ;

    self.closeLimitCallBack = function(event)
        self:removeOwnTimer(self.tenMinuteTime)
        HoushanManager:setTenSecondBackBossLayer()
    end;
    TFDirector:addMEGlobalListener(FightManager.FactionBossFightLeave ,self.closeLimitCallBack ) ;

    self.resetTenMinuteTime = function(event)
        self:removeOwnTimer(self.tenMinuteTime) 
    end;
    TFDirector:addMEGlobalListener(FightManager.FactionBossFightResult ,self.resetTenMinuteTime ) ;    
end

function HoushanBossDetail:removeEvents()
    self.closebtn:removeMEListener(TFWIDGET_CLICK)
    self.btn_army:removeMEListener(TFWIDGET_CLICK)
    self.btn_attack:removeMEListener(TFWIDGET_CLICK)
    TFDirector:removeMEGlobalListener(HoushanManager.EVENT_UPDATE_HOUSHANDETAIL ,self.updateHoushanDetail);
    self.updateHoushanDetail = nil 
    TFDirector:removeMEGlobalListener(FightManager.FactionBossFightLeave ,self.closeLimitCallBack)
    self.closeLimitCallBack = nil
    TFDirector:removeMEGlobalListener(FightManager.FactionBossFightResult ,self.resetTenMinuteTime)
    self.resetTenMinuteTime = nil

    self:removeOwnTimer(self.countDownTimer) 
    self:removeOwnTimer(self.tenMinuteTime) 

    self.super.removeEvents(self)
end

function HoushanBossDetail:dispose()
    self.super.dispose(self)
end

function HoushanBossDetail:closeLayer()
    self:removeOwnTimer(self.countDownTimer) 
    self:removeOwnTimer(self.tenMinuteTime) 
    HoushanManager:unlockZone(self.chapter)
    AlertManager:closeAllToLayer(self)
end

function HoushanBossDetail:tenMinuteTimeLimite()
    if self.tenMinuteTime then
        return
    end
    local cutDownTime = 600
    self.tenMinuteTime = TFDirector:addTimer(1000, -1, nil, 
        function () 
        if cutDownTime <= 0 then
            self:removeOwnTimer(self.tenMinuteTime)  
            self.istenMinute = true
            TFDirector:dispatchGlobalEventWith(FightManager.LeaveFightCommand, {})
        else
            cutDownTime = cutDownTime - 1
        end
    end)
end

function HoushanBossDetail:removeOwnTimer(timerId)
    if timerId then
        TFDirector:removeTimer(timerId)
        if timerId == self.tenMinuteTime then
            self.tenMinuteTime = nil
        elseif timerId == self.countDownTimer then
            self.countDownTimer = nil
        end
    end 
end

return HoushanBossDetail

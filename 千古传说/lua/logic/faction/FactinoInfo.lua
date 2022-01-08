--[[
******帮派基本信息*******

	-- by quanhuan
	-- 2015/10/26
	
]]

local FactinoInfo = class("FactinoInfo",BaseLayer)

function FactinoInfo:ctor(data)
	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.faction.FactinoInfo")
end

function FactinoInfo:initUI( ui )
	self.super.initUI(self, ui) 

	self.txt_name = TFDirector:getChildByPath(ui, "txt_name")
	self.txt_level = TFDirector:getChildByPath(ui, "txt_level")
	self.bar_exp = TFDirector:getChildByPath(ui, "bar_exp")
	self.txt_exp = TFDirector:getChildByPath(ui, "txt_exp")
	self.txt_renshu = TFDirector:getChildByPath(ui, "txt_renshu")
	self.txt_bzname = TFDirector:getChildByPath(ui, "txt_bzname")
	self.txt_zhanli = TFDirector:getChildByPath(ui, "txt_zhanli")
	self.txt_id = TFDirector:getChildByPath(ui, "txt_id")

	local panel = TFDirector:getChildByPath(ui, "bg_xy")
	self.xxXiugai = TFDirector:getChildByPath(panel, "btn_xiugai")
	self.xxXiugai.logic = self
	self.xxTxtArea = TFDirector:getChildByPath(panel, "TxtArea_xy")

	panel = TFDirector:getChildByPath(ui, "bg_gg")
	self.ggXiugai = TFDirector:getChildByPath(panel, "btn_xiugai")
	self.ggXiugai.logic = self
	self.ggTxtArea = TFDirector:getChildByPath(panel, "TxtArea_gg")

    self.bar_exp:setDirection(TFLOADINGBAR_LEFT)
    self.bar_exp:setPercent(0)
    self.bar_exp:setVisible(true)

	self.btn_js = TFDirector:getChildByPath(ui, "btn_js")
	self.btn_tuichu = TFDirector:getChildByPath(ui, "btn_tuichu")
	self.btn_levelup = TFDirector:getChildByPath(ui, "btn_shengji")
    self.btn_sqjr = TFDirector:getChildByPath(ui, "btn_sqjr")
    self.btn_qxjs = TFDirector:getChildByPath(ui, "btn_qxjs")
    self.btn_qxjs.txtTime = TFDirector:getChildByPath(self.btn_qxjs, "txt_time")
    self.btn_qxsq = TFDirector:getChildByPath(ui, "btn_qxsq")
    self.btn_sqjr.logic = self
    self.btn_qxjs.logic = self
    self.btn_qxsq.logic = self
    self.btn_levelup.logic = self
    self.btn_youjian = TFDirector:getChildByPath(ui, "btn_youjian")
    self.btn_youjian.logic = self

    self.countDownTimer = nil

    self.level_effect = Public:addBtnWaterEffect(self.btn_levelup, true,1)
    self.level_effect:setVisible(false)


    self.btn_bianji     = TFDirector:getChildByPath(ui, "btn_bianji")
    self.btn_gaiming    = TFDirector:getChildByPath(ui, "btn_gaiming")

    self.btn_bianji:setVisible(false)

    local myPost = FactionManager:getPostInFaction()
    if myPost ~= 1 then
        self.btn_gaiming:setVisible(false)
        self.btn_bianji:setVisible(false)
    else
        self.btn_gaiming:setVisible(true)
        self.btn_bianji:setVisible(true)
    end

    self.bg_qizhi = TFDirector:getChildByPath(ui, 'bg_qizhi')
    self.img_qi = TFDirector:getChildByPath(ui, 'img_qi')
end

function FactinoInfo:removeUI()
   	self.super.removeUI(self)
end

function FactinoInfo:onShow()
    self.super.onShow(self)
end

function FactinoInfo:registerEvents()

	if self.registerEventCallFlag then
		return
	end

	self.super.registerEvents(self)

	self.btn_js:addMEListener(TFWIDGET_CLICK, audioClickfun(self.dissolvedButtonClick))
	self.btn_tuichu:addMEListener(TFWIDGET_CLICK, audioClickfun(self.tuichuButtonClick))
	self.xxXiugai:addMEListener(TFWIDGET_CLICK, audioClickfun(self.xxChangeButtonClick))
	self.ggXiugai:addMEListener(TFWIDGET_CLICK, audioClickfun(self.ggChangeButtonClick))
    self.btn_sqjr:addMEListener(TFWIDGET_CLICK, audioClickfun(self.sqjrButtonClick))
    self.btn_qxjs:addMEListener(TFWIDGET_CLICK, audioClickfun(self.qxjsButtonClick))
    self.btn_qxsq:addMEListener(TFWIDGET_CLICK, audioClickfun(self.qxsqButtonClick))
    self.btn_levelup:addMEListener(TFWIDGET_CLICK, audioClickfun(self.levelUpButtonClick))
    self.btn_bianji:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBannerEdit))
    self.btn_bianji.logic = self
    self.btn_youjian:addMEListener(TFWIDGET_CLICK, audioClickfun(self.youjianButtonClick))

    --公告/宣言 信息刷新
    self.modifyNoticeUpdateCallBack = function (event)
        if self.modifyTextIndex == 1 then
            self.ggTxtArea:setText(self.modifyText)            
        else
            self.xxTxtArea:setText(self.modifyText)
        end
    end
    TFDirector:addMEGlobalListener(FactionManager.modifyNoticeUpdate, self.modifyNoticeUpdateCallBack)

    --帮派升级 
    self.levelUpUpdateCallBack = function (event)
        local layer =  AlertManager:addLayerByFile("lua.logic.faction.FationLevelUp", AlertManager.BLOCK_AND_GRAY)
        print("old = ",self.oldLevel)
        layer:setLevel(self.oldLevel, self.oldLevel+1)
        AlertManager:show()
        self:refreshWindow()
    end
    TFDirector:addMEGlobalListener(FactionManager.levelUpUpdate, self.levelUpUpdateCallBack)

    self.bannerUpdateCallBack = function (event)
        local data = event.data[1][1]
        local bannerInfo = stringToNumberTable(data, '_')
        self.bg_qizhi:setTexture(FactionManager:getBannerBgPath(bannerInfo[1],bannerInfo[2]))
        self.img_qi:setTexture(FactionManager:getBannerIconPath(bannerInfo[3],bannerInfo[4]))   
        toastMessage(localizable.Guild_flag_modify) 
    end
    TFDirector:addMEGlobalListener(FactionManager.bannerUpdate, self.bannerUpdateCallBack)

	self.registerEventCallFlag = true

    self.btn_gaiming:addMEListener(TFWIDGET_CLICK, audioClickfun(self.modifyNameButtonClick))
end

function FactinoInfo:removeEvents()
	
    self.super.removeEvents(self)

    self.btn_js:removeMEListener(TFWIDGET_CLICK)
    self.btn_tuichu:removeMEListener(TFWIDGET_CLICK)
    self.xxXiugai:removeMEListener(TFWIDGET_CLICK)
    self.ggXiugai:removeMEListener(TFWIDGET_CLICK)
    self.btn_sqjr:removeMEListener(TFWIDGET_CLICK)
    self.btn_qxjs:removeMEListener(TFWIDGET_CLICK)
    self.btn_qxsq:removeMEListener(TFWIDGET_CLICK)
    self.btn_levelup:removeMEListener(TFWIDGET_CLICK)

    TFDirector:removeMEGlobalListener(FactionManager.modifyNoticeUpdate, self.modifyNoticeUpdateCallBack)    
    self.modifyNoticeUpdateCallBack = nil
    TFDirector:removeMEGlobalListener(FactionManager.levelUpUpdate, self.levelUpUpdateCallBack)  
    self.levelUpUpdateCallBack = nil
    TFDirector:removeMEGlobalListener(FactionManager.bannerUpdate, self.bannerUpdateCallBack)
    self.bannerUpdateCallBack = nil

    if self.countDownTimer then
        TFDirector:removeTimer(self.countDownTimer)
        self.countDownTimer = nil
    end

    self.registerEventCallFlag = nil
end

function FactinoInfo:dispose()
    self.super.dispose(self)
end

function FactinoInfo:refreshWindow()

    local identity = FactionManager:getCurrIdentity()
    self.btn_qxjs:setVisible(false)

    if identity == "others" then
        local info = FactionManager:getFactionInfo()
        if info.apply then
            self.btn_sqjr:setVisible(false)
            self.btn_qxsq:setVisible(true)
        else
            self.btn_sqjr:setVisible(true)
            self.btn_qxsq:setVisible(false)            
        end
        self.btn_js:setVisible(false)
        self.btn_tuichu:setVisible(false)
        self.btn_levelup:setVisible(false)
        self.xxXiugai:setVisible(false)
        self.ggXiugai:setVisible(false)
        self.btn_bianji:setVisible(false)
        self.btn_youjian:setVisible(false)
    else    
        local currPost = FactionManager:getPostInFaction()
        self.btn_youjian:setVisible(true)
        if currPost == FactionManager.Leader then
            self.xxXiugai:setVisible(true)
            self.ggXiugai:setVisible(true)
            self.btn_js:setVisible(true)
            self.btn_tuichu:setVisible(false)
            self.btn_levelup:setVisible(true)
        elseif currPost == FactionManager.DeputyLeader then
            self.xxXiugai:setVisible(true)
            self.ggXiugai:setVisible(true)
            self.btn_js:setVisible(false)
            self.btn_tuichu:setVisible(true)
            self.btn_levelup:setVisible(true)
        else
            self.xxXiugai:setVisible(false)
            self.ggXiugai:setVisible(false)
            self.btn_js:setVisible(false)
            self.btn_tuichu:setVisible(true)
            self.btn_levelup:setVisible(false)
            self.btn_youjian:setVisible(false)
        end    
        if FactionManager:canViewRedLevelUp() then
            self.level_effect:setVisible(true)
        else 
            self.level_effect:setVisible(false)
        end
    end

    self:baseInfoSet()
end

function FactinoInfo:baseInfoSet()
    
    local info = FactionManager:getFactionInfo()
    if info then
        print('info.bannerId = ',info.bannerId)
        local bannerInfo = stringToNumberTable(info.bannerId, '_')
        self.bg_qizhi:setTexture(FactionManager:getBannerBgPath(bannerInfo[1],bannerInfo[2]))
        self.img_qi:setTexture(FactionManager:getBannerIconPath(bannerInfo[3],bannerInfo[4]))

        self.txt_name:setText(info.name)
        self.txt_level:setText(info.level..'d')
        local currExp = info.exp
        local totalExp = FactionManager:getFactionLevelUpExp(info.level+1)    --需要读表
        self.bar_exp:setPercent(math.floor(currExp*100/totalExp))
        self.txt_exp:setText(currExp.."/"..totalExp)
        local maxMember = FactionManager:getFactionMaxMember(info.level)
        self.txt_renshu:setText(info.memberCount.."/"..maxMember)
        self.txt_bzname:setText(info.presidentName)
        self.txt_zhanli:setText(info.power)
        self.txt_id:setText(info.guildId)
        self.xxTxtArea:setText(info.declaration)
        self.ggTxtArea:setText(info.notice)
        if info.state == 2 and FactionManager:getPostInFaction() == 1 then
            self.btn_js:setVisible(false)
            self.btn_qxjs:setVisible(true)
            if self.countDownTimer then
                TFDirector:removeTimer(self.countDownTimer)
                self.countDownTimer = nil
            end            
            
            local info = FactionManager:getFactionInfo()
            
            self.countDown = math.floor(info.operateTime/1000) - MainPlayer:getNowtime()
            local timeStr = FactionManager:getTimeString( self.countDown )
            self.btn_qxjs.txtTime:setText(timeStr)

            self.countDownTimer = TFDirector:addTimer(1000, -1, nil, function () 
                if self.countDown <= 0 then
                    if self.countDownTimer then
                        TFDirector:removeTimer(self.countDownTimer)
                        self.countDownTimer = nil
                    end
                    local timeStr = FactionManager:getTimeString( self.countDown )
                    self.btn_qxjs.txtTime:setText(timeStr)
                    --退出帮派
                else
                    self.countDown = self.countDown - 1
                    local timeStr = FactionManager:getTimeString( self.countDown )--os.date("%X", self.countDown)
                    self.btn_qxjs.txtTime:setText(timeStr)
                end
            end)
        elseif self.countDownTimer then
            if self.countDownTimer then
                TFDirector:removeTimer(self.countDownTimer)
                self.countDownTimer = nil
            end
        end  
    end
end

function FactinoInfo.dissolvedButtonClick()
	--解散帮派
    local info = FactionManager:getFactionInfo()
    if info.state == 1 then
        --toastMessage("帮主正在禅让")
        toastMessage(localizable.factionInfo_text1)
    elseif info.state == 2 then
        --toastMessage("帮派正在解散")
        toastMessage(localizable.factionInfo_text2)
    elseif info.state == 3 then 
        --toastMessage("帮主正在被弹劾") 
        toastMessage(localizable.factionInfo_text3)

    else
    	--local msg = "是否确认解散帮派,帮派解散后,\n".."所有帮派成员将被强制解散"
        local  msg =localizable.factionInfo_exit_tips
        CommonManager:showOperateSureLayer(
            function()
                FactionManager:requestAppoint(OperateType.dissolved, MainPlayer:getPlayerId())
            end,
            function()
                AlertManager:close()
            end,
            {
                --title = "解散帮派",
                title = localizable.factionInfo_exit ,
                msg = msg,
            }
        )
    end
end
function FactinoInfo.qxjsButtonClick(btn)
    --取消解散帮派
    local info = FactionManager:getFactionInfo()
    currTime = math.floor(info.operateTime/1000) - MainPlayer:getNowtime()

    local subText = FactionManager:getTimeStringChinese( currTime )

    --local msg = "帮派将在"..subText.."后\n解散，是否终止？"
    local msg = stringUtils.format(localizable.factionInfo_exit_stop,subText)
    CommonManager:showOperateSureLayer(
        function()
            FactionManager:requestAppoint(OperateType.Canceldissolved, MainPlayer:getPlayerId())
        end,
        function()
            AlertManager:close()
        end,
        {
        title = localizable.factionInfo_exit_stop,
        msg = msg,
        }
    )
end
function FactinoInfo.qxsqButtonClick( btn )
    local info = FactionManager:getFactionInfo()
    FactionManager:requestCancelJoinFaction( info.guildId )
    AlertManager:close()
end



function FactinoInfo.tuichuButtonClick()
	--退出帮派
	--local msg = "是否确认退出帮派?\n(贡献度和帮派技能将保留)"
    local msg = localizable.factionInfo_exit_ok
    local uiconfig =  "lua.uiconfig_mango_new.faction.jsTipsPop";
    local flieName = "lua.logic.faction.jsTipsPop"

    local layer = AlertManager:addLayerByFile(flieName,AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1);
    layer.toScene = Public:currentScene();
    layer:setUIConfig(uiconfig);

    layer:setBtnHandle(function()
        FactionManager:requestExitFaction()
        end,
        function()
            AlertManager:close()
        end);
    --layer:setTitle("退出帮派");
    layer:setTitle(localizable.factionInfo_exit_fa);
    layer:setMsg(msg);

    AlertManager:show()
end

function FactinoInfo.xxChangeButtonClick( btn )

	local self = btn.logic
	local msg = self.xxTxtArea:getText()
    FactionManager:showNoticePopLayer(
        function(data)
            --if 权限不够
            local post = FactionManager:getPostInFaction()
            if post == 1 or post == 2 then
                self.modifyText = data
                self.modifyTextIndex = 2
                local MsgInfo = {2,data}
                FactionManager:modifyFactionNotice(MsgInfo)
            else
                --toastMessage("权限不够")
                toastMessage(localizable.common_no_power)            
                TFDirector:dispatchGlobalEventWith(FactionManager.refreshWindow ,{})
            end
        end,
        function()
            --AlertManager:close()
        end,
        {
        --title = "帮派宣言",
        title = localizable.factionInfo_xuanyan,
        msg = msg,
        MaxLength = 40,
        }
    )
	
end

function FactinoInfo.ggChangeButtonClick( btn )

	local self = btn.logic
	local msg = self.ggTxtArea:getText()
    FactionManager:showNoticePopLayer(
        function(data)
            local post = FactionManager:getPostInFaction()
            if post == 1 or post == 2 then            
                self.modifyText = data
                self.modifyTextIndex = 1
                local MsgInfo = {1,data}
                FactionManager:modifyFactionNotice(MsgInfo)   
            else        
                --toastMessage("权限不够")
                toastMessage(localizable.common_no_power)

                TFDirector:dispatchGlobalEventWith(FactionManager.refreshWindow ,{})
            end
        end,
        function()
            --AlertManager:close()
        end,
        {
            --title = "帮派公告",
            title = localizable.factionInfo_gonggao,
            msg = msg,
            MaxLength = 120,
        }
    )
end
function FactinoInfo.levelUpButtonClick( btn )
    local self = btn.logic
    local info = FactionManager:getFactionInfo()
    local currExp = info.exp
    local maxExp = FactionManager:getFactionLevelUpExp(info.level+1)    --需要读表
    local maxLevel = FactionLevelUpData:length()
    if info.level >= maxLevel then
        --toastMessage("帮派等级已达满级")
        toastMessage(localizable.factionInfo_dingji)
        return 
    end

    local post = FactionManager:getPostInFaction()
    if post == 1 or post == 2 then   
        if currExp >= maxExp then
            self.oldLevel = info.level
            FactionManager:requestAppoint(OperateType.levelup, MainPlayer:getPlayerId())
        else
            --toastMessage("经验不够")
            toastMessage(localizable.factionInfo_jianyan)
        end
    else
        --toastMessage("权限不够")
        toastMessage(localizable.common_no_power)
        
        TFDirector:dispatchGlobalEventWith(FactionManager.refreshWindow ,{})
    end
end

function FactinoInfo.sqjrButtonClick( btn )
    if FactionManager:checkCanJoinFaction() == false then
        --toastMessage("退出帮派时间没有超过24小时")
        toastMessage(localizable.factionInfo_exit_time)
        return
    end    
    local info = FactionManager:getFactionInfo()
    FactionManager:requestJoinFaction( info.guildId )
    AlertManager:close()
end


function FactinoInfo.modifyNameButtonClick( btn )
    FactionManager:EnterModifyFationName()
end


function FactinoInfo.modifyBannerButtonClick( btn )
    --toastMessage("修改帮会旗帜即将开放")
    toastMessage(localizable.factionInfo_edit_qizhi)
end

function FactinoInfo.onBannerEdit( btn )
    local self = btn.logic
    local myPost = FactionManager:getPostInFaction()
    if myPost ~= 1 then
        --toastMessage('权限不够')
        toastMessage(localizable.common_no_power)
        return
    end
    local info = FactionManager:getFactionInfo()
    if info then
        local bannerInfo = stringToNumberTable(info.bannerId, '_')
        local ChoseInfo = {}
        ChoseInfo.bannerBg = bannerInfo[1] or 1
        ChoseInfo.bannerBgColor = bannerInfo[2] or 1
        ChoseInfo.bannerIcon = bannerInfo[3] or 1
        ChoseInfo.bannerIconColor = bannerInfo[4] or 1
        local layer  = require("lua.logic.faction.EditBannerLayer"):new()
        AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
        layer:setData(ChoseInfo,true)
        AlertManager:show()
    end
end

function FactinoInfo.youjianButtonClick( btn )
    local self = btn.logic
    local myPost = FactionManager:getPostInFaction()
    if myPost ~= 1 and myPost ~= 2 then
        --toastMessage('权限不够')
        toastMessage(localizable.common_no_power)
        return
    end    
    local layer  = require("lua.logic.faction.FactionMailLayer"):new()
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
    AlertManager:show()
end
return FactinoInfo
--[[
******跨服个人战-资格赛排名信息*******

	-- by quanhuan
	-- 2016/2/22
	
]]

local KuaFuResultLayer = class("KuaFuResultLayer",BaseLayer)

function KuaFuResultLayer:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.kuafuwulin.KuaFuResult")
end

function KuaFuResultLayer:initUI( ui )

	self.super.initUI(self, ui)

    self.generalHead = CommonManager:addGeneralHead(self)
    self.generalHead:setData(ModuleType.KFWLDH,{HeadResType.SYCEE})

    self.txt_time1 = TFDirector:getChildByPath(ui, 'txt_tips')
    self.txt_time2 = TFDirector:getChildByPath(ui, 'txt_lefttime')
    local panel_role = TFDirector:getChildByPath(ui,'panel_role')
    self.panel_sz = TFDirector:getChildByPath(panel_role, 'panel_sz')
    self.panel_bf = TFDirector:getChildByPath(panel_role, 'panel_bf')
    self.img_hongdi = TFDirector:getChildByPath(ui, 'img_hongdi')
    self.roleList = {}
    for i=1,5 do
        self.roleList[i] = TFDirector:getChildByPath(self.panel_sz, 'role'..i)
    end
    --panel_role
    self.txt_serverName0 = TFDirector:getChildByPath(self.panel_sz, 'txt_servername')
    
    self.txt_name0 = TFDirector:getChildByPath(self.panel_sz, 'txt_name')
    self.txt_zhandouli0 = TFDirector:getChildByPath(self.panel_sz, 'txt_zhandouli')
    self.img_headIcon0 = TFDirector:getChildByPath(self.panel_sz, 'icon_head')

    self.txt_serverName = TFDirector:getChildByPath(self.panel_bf, 'txt_servername')
    self.txt_name = TFDirector:getChildByPath(self.panel_bf, 'txt_name')
    self.txt_zhandouli = TFDirector:getChildByPath(self.panel_bf, 'txt_zhandouli')
    self.img_headIcon = TFDirector:getChildByPath(self.panel_bf, 'icon_head')

    self.txt_rank = TFDirector:getChildByPath(self.ui, 'txt_shunxu')
    self.txt_paiming = TFDirector:getChildByPath(self.panel_bf, 'txt_bfpaiming')
    self.txt_ruxuan = TFDirector:getChildByPath(ui, 'txt_ruxuan')
    
    self.btn_shop = TFDirector:getChildByPath(ui, 'btn_kfsd')
    self.btn_rule = TFDirector:getChildByPath(ui, 'btn_guizhe')
    self.btn_reward = TFDirector:getChildByPath(ui, 'btn_jiangli')

end

function KuaFuResultLayer.OnRuleClick( sender )
    CommonManager:showRuleLyaer('kuafuwulindahui')
end

function KuaFuResultLayer.OnRewardClick( sender )
    local layer = AlertManager:addLayerByFile("lua.logic.multiServerFight.KuaFuRewardLayer",AlertManager.BLOCK_AND_GRAY);
    AlertManager:show()
end

function KuaFuResultLayer.OnShopClick( sender )
    MallManager:openMallLayerByType(EnumMallType.HonorMall,1)
end

function KuaFuResultLayer:removeUI()
	self.super.removeUI(self)
end

function KuaFuResultLayer:onShow()
    self.super.onShow(self)
    self.generalHead:onShow()
end

function KuaFuResultLayer:setInfo(info)
    print('info = ',info)
    self.info = info
    info.serverName = info.serverName or ""
    self.txt_serverName0:setText(info.serverName)
    info.name = info.name or ""
    self.txt_name0:setText(info.name)
    info.power = info.power or 0
    self.txt_zhandouli0:setText(info.power)
    local roleConfig = RoleData:objectByID(info.useCoin)
    if roleConfig then
        self.img_headIcon0:setTexture(roleConfig:getIconPath())
    end
    Public:addFrameImg(self.img_headIcon0,info.framId)
    if info.myRank == 0 or info.myRank == nil then
        self.txt_rank:setVisible(false)
        self.txt_ruxuan:setVisible(true)
    else
        self.txt_rank:setText(info.myRank.."")
        self.txt_rank:setVisible(true)
        self.txt_ruxuan:setVisible(false)
    end
    if info.serverPlayerName ~= nil then
        self.panel_bf:setVisible(true)
        self.txt_serverName:setText(info.serverServerName.."")
        self.txt_name:setText(info.serverPlayerName.."")
        self.txt_zhandouli:setText(info.serverPower.."")
        local roleConfig = RoleData:objectByID(info.serverUseCoin)
        self.img_headIcon:setTexture(roleConfig:getIconPath())
        Public:addFrameImg(self.img_headIcon,info.serverFramId)
        self.txt_paiming:setText(stringUtils.format(localizable.multiFight_myRank,info.serverRank))
    else
        self.panel_bf:setVisible(false)
    end
    self:loadFormation(info.formation)
    self:setTime(info.lastOpenTime)
end

function KuaFuResultLayer:loadFormation(formation)
    local roleIdList,len = stringToNumberTable(formation,',')
    local scaleList = {1,0.9,0.9,0.8,0.8}
    for i=1,len do
        local roleAnim = GameResourceManager:getRoleAniById(roleIdList[i])
        roleAnim:setPosition(ccp(0,0))
        self.roleList[i]:addChild(roleAnim)
        roleAnim:play("stand", -1, -1, 1)
        -- roleAnim:setScale(scaleList[i] or 1)

        TFResourceHelper:instance():addArmatureFromJsonFile("effect/main_role2.xml")
        local effect2 = TFArmature:create("main_role2_anim")
        if effect2 ~= nil then
            effect2:setAnimationFps(GameConfig.ANIM_FPS)
            effect2:playByIndex(0, -1, -1, 1)
            effect2:setZOrder(-1)
            effect2:setPosition(ccp(0, -20))
            roleAnim:addChild(effect2)
        end 
    end
end

function KuaFuResultLayer:setTime(lastTime)
    
    if lastTime == nil or lastTime == 0 then
        self.img_hongdi:setVisible(false)
        self.txt_time1:setText(localizable.multiFight_result_timetxt)
        self.txt_time2:setText(localizable.multiFight_result_timetxt)
    else
        self.img_hongdi:setVisible(true)
        lastTime = lastTime/1000
        local feedTime = ConstantData:objectByID("Personal.Battle.Cycle").value * 24 * 60 * 60
        local time1 = lastTime + feedTime
        local timeData = os.date("*t",time1)
        self.txt_time1:setText(stringUtils.format(localizable.multiFight_result_opentime,timeData.month,timeData.day))
        self.desTime = time1
        local function MakeTimerStr()
            local time2 = self.desTime - MainPlayer:getNowtime()
            local tDay = math.floor(time2/(3600*24))
            time2 = time2 - tDay * 3600*24
            local tHour = math.floor(time2/3600)
            time2 = time2 - tHour*3600
            local tMin = math.floor(time2/60)
            time2 = time2 - tMin*60
            local tSec = math.floor(time2)
            local strList = ""
            if tDay > 0 then
                strList = tDay..localizable.time_day_txt
            end
            if tHour > 0 then
                strList = strList..tHour..localizable.time_hour_txt
            end
            if tMin > 0 then
                strList = strList..tMin..localizable.time_minute_txt
            end
            if tSec <= 0 then 
                tSec = 0
            end
            strList = strList..tSec..localizable.time_second_txt
            self.txt_time2:setText(strList)        
        end
        MakeTimerStr()
        self.updateTimerID = TFDirector:addTimer(1000, -1, nil, 
        function()
            MakeTimerStr()
        end)
    end
end

function KuaFuResultLayer:registerEvents()
	self.super.registerEvents(self)
    if self.generalHead then
        self.generalHead:registerEvents()
    end

    self.btn_shop.logic = self;
    self.btn_shop:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.OnShopClick),1);

    self.btn_rule.logic = self;
    self.btn_rule:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.OnRuleClick),1);

    self.btn_reward.logic = self;
    self.btn_reward:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.OnRewardClick),1);
end

function KuaFuResultLayer:removeEvents()

    self.super.removeEvents(self)

	if self.generalHead then
        self.generalHead:removeEvents()
    end	

end

function KuaFuResultLayer:dispose()
    if self.updateTimerID then
        TFDirector:removeTimer(self.updateTimerID)
        self.updateTimerID = nil
    end
    self.super.dispose(self)
end

return KuaFuResultLayer
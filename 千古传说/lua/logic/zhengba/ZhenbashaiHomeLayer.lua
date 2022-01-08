local ZhenbashaiHomeLayer = class("ZhenbashaiHomeLayer", BaseLayer);

CREATE_SCENE_FUN(ZhenbashaiHomeLayer);
CREATE_PANEL_FUN(ZhenbashaiHomeLayer);

--[[
******争霸赛-欢迎界面*******

]]

function ZhenbashaiHomeLayer:ctor(data)
    self.super.ctor(self,data);
    
    self:init("lua.uiconfig_mango_new.zhenbashai.ZhenbashaiHomeLayer");

    WeekRaceManager:requestLastChampion()
end

function ZhenbashaiHomeLayer:loadHomeData(data)
    self.homeInfo = data;
    
    self:refreshUI();
end

function ZhenbashaiHomeLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI();
end

function ZhenbashaiHomeLayer:refreshBaseUI()
end

function ZhenbashaiHomeLayer:refreshUI()
    -- if not self.isShow then
    --     return;
    -- end
end

function ZhenbashaiHomeLayer:initUI(ui)
    self.super.initUI(self,ui);
    -- self.btn_close      = TFDirector:getChildByPath(ui, 'btn_close');
    self.btn_star         = TFDirector:getChildByPath(ui, 'btn_star');
    self.icon_battletime1      = TFDirector:getChildByPath(ui, 'icon_battletime1');
    self.icon_battletime2      = TFDirector:getChildByPath(ui, 'icon_battletime2');
    self.icon_battletime2:setVisible(false)
    if ZhengbaManager:getActivityStatus() == 5 then
        self.icon_battletime2:setVisible(true)
        self.icon_battletime1:setVisible(false)    
    elseif ZhengbaManager:getActivityStatus() == 1 then
        self.icon_battletime1:setVisible(false)
    else
        self.icon_battletime1:setVisible(true)
    end
    self.txt_name      = TFDirector:getChildByPath(ui, 'txt_name');
    -- self.txt_name:setText("虚席以待")
    self.txt_name:setText(localizable.common_wait)

    self.posRole = {}
    for i=1,5 do
        self.posRole[i] = TFDirector:getChildByPath(ui, 'role'..i)
    end
    self.Img_nobody = TFDirector:getChildByPath(ui, 'Img_nobody')
    self.Img_nobody:setVisible(true)
end

function ZhenbashaiHomeLayer.onGoClickHandle(sender)
    if ZhengbaManager:getActivityStatus() == 1 then
        -- toastMessage("活动未开始")
        toastMessage(localizable.WeekRaceManager_huodong_weikaishi)
        return
    elseif ZhengbaManager:getActivityStatus() == 5 then
        WeekRaceManager:requestRaceInfo(true)
        return
    end
    ZhengbaManager:openZhengbaMainLayer()
end

function ZhenbashaiHomeLayer:removeUI()
    self.super.removeUI(self)
end

function ZhenbashaiHomeLayer:registerEvents()
    self.super.registerEvents(self)

    self.btn_star.logic    = self
    self.btn_star:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onGoClickHandle),1)


    self.gainChampionsInfo = function(event)
        if ZhengbaManager:getActivityStatus() == 1 then
            self.icon_battletime1:setVisible(false)
        else
            self.icon_battletime1:setVisible(true)
        end
    end
    TFDirector:addMEGlobalListener(ZhengbaManager.GAINCHAMPIONSINFO ,self.gainChampionsInfo)

    self.lastChampionMsg = function(event)
        self:showHeroList(event.data[1][1])
    end
    TFDirector:addMEGlobalListener(WeekRaceManager.lastChampionMsg ,self.lastChampionMsg)
end

function ZhenbashaiHomeLayer:removeEvents()
    self.super.removeEvents(self)
    TFDirector:removeMEGlobalListener(ZhengbaManager.GAINCHAMPIONSINFO ,self.gainChampionsInfo)        
    self.gainChampionsInfo = nil

    TFDirector:removeMEGlobalListener(WeekRaceManager.lastChampionMsg ,self.lastChampionMsg)      
    self.lastChampionMsg = nil

    if self.roleAnimId then
        for k,v in pairs(self.roleAnimId) do
            GameResourceManager:deleRoleAniById(v)
        end
        self.roleAnimId = nil
    end
end

function ZhenbashaiHomeLayer:showHeroList( data )

    print('data = ',data)
    self.roleAnimId = {}
    if data then    
        local idBuff = data.id   
        if idBuff then 
            for k,v in pairs(idBuff) do
                if v ~= 0 then
                    self.Img_nobody:setVisible(false)
                    local idx = #self.roleAnimId + 1
                    local roleAnim = GameResourceManager:getRoleAniById(v)
                    roleAnim:setPosition(ccp(0,0))
                    roleAnim:play("stand", -1, -1, 1)
                    self.posRole[idx]:setZOrder(20-idx)
                    self.posRole[idx]:addChild(roleAnim)
                    
                    self.roleAnimId[idx] = v
                    --加阴影
                    TFResourceHelper:instance():addArmatureFromJsonFile("effect/main_role2.xml")
                    local effect2 = TFArmature:create("main_role2_anim")
                    if effect2 ~= nil then
                        effect2:setAnimationFps(GameConfig.ANIM_FPS)
                        effect2:playByIndex(0, -1, -1, 1)
                        effect2:setZOrder(-1)
                        effect2:setPosition(ccp(0, -10))
                        roleAnim:addChild(effect2)
                    end                    
                end
            end
        end
        local len = string.len(data.name)
        if len < 1 then
            -- self.txt_name:setText('虚席以待')
            self.txt_name:setText(localizable.common_wait)
        else
            self.txt_name:setText(data.name)
        end
    end
end
return ZhenbashaiHomeLayer;

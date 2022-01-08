--[[
******关卡-跳转*******
    -- by quanhuan
]]
local MissionSkipLayer = class("MissionSkipLayer", BaseLayer);

function MissionSkipLayer:ctor()
    self.super.ctor(self);
    self:init("lua.uiconfig_mango_new.mission.Skip");
end

function MissionSkipLayer:loadData(mapid,difficulty)
    self.difficulty = difficulty
    self.mapid = mapid

    self.Img_back:setVisible(false)
    self.Txt_title:setVisible(false)
    self.Txt_content:setVisible(false)
    self.Btn_getstar:setVisible(false)
    self.Btn_goon:setVisible(false)
    self.Txt_num:setVisible(false)
    self.panelBoxView:setVisible(false)
    self.Txt_content:setString("")

    self.enableUi = false
    self.stringBuff = nil
end

function MissionSkipLayer:setBtnHandle(goonhandle, getstarhandle)

    if self.Btn_getstar then
        self.Btn_getstar.logic       = self
        self.Btn_getstar:addMEListener(TFWIDGET_CLICK,audioClickfun(function()
            AlertManager:close(AlertManager.TWEEN_NONE)
            getstarhandle()                    
        end),1)
    end

    if self.Btn_goon then
        self.Btn_goon.logic   = self   
        self.Btn_goon:addMEListener(TFWIDGET_CLICK, audioClickfun(function()
            AlertManager:close(AlertManager.TWEEN_NONE)  
            goonhandle()                      
        end),1)
    end

end

function MissionSkipLayer:initUI(ui)
    self.super.initUI(self,ui)

    self.Panel_anim = TFDirector:getChildByPath(ui, 'Panel_anim')
    self.Img_back = TFDirector:getChildByPath(ui, 'Img_back')
    self.Txt_title = TFDirector:getChildByPath(ui, 'Txt_title')
    self.Txt_content = TFDirector:getChildByPath(ui, 'Txt_content')
    self.Btn_getstar = TFDirector:getChildByPath(ui, 'Btn_getstar')
    self.Btn_goon = TFDirector:getChildByPath(ui, 'Btn_goon')
    self.Txt_num = TFDirector:getChildByPath(ui, 'Txt_num')

    self.panelBoxView       = TFDirector:getChildByPath(ui, 'panelBoxView')
    self.mapBoxView = require("lua.logic.mission.MissionStarBox"):new()
    self.panelBoxView:addChild(self.mapBoxView)
end

function MissionSkipLayer:removeUI()
    self.super.removeUI(self)
end

function MissionSkipLayer:dispose()  
    self.super.dispose(self)
end

function MissionSkipLayer:onShow()  
    
    self:refreshUI()
    self:playEffectAnim()

end

function MissionSkipLayer:refreshUI()

    if self.enableUi then
        if self.mapBoxView then
            self.mapBoxView:loadData(self.mapid,self.difficulty)
        end
        --self.Img_back:setVisible(true)
        self.Txt_title:setVisible(true)
        self.Txt_content:setVisible(true)
        self.Txt_num:setVisible(true)
        self.panelBoxView:setVisible(true)
        self.Btn_goon:setVisible(true)
        --map name
        local map = MissionManager:getMapById(self.mapid);
        self.Txt_title:setText(map.name);

        --current star
        local curStar = MissionManager:getStarlevelCount(self.mapid,self.difficulty);
        local maxStar = MissionManager:getMaxStarlevelCount(self.mapid,self.difficulty);
        self.Txt_num:setString(curStar.."/"..maxStar)
      
        --content
        if self.stringBuff == nil then
             self.stringBuff = ""
             local stringIndex = 1
             self.stringBuffTimeId = TFDirector:addTimer(66, -1, nil, 
                function() 
                    local c = string.sub(map.detail,stringIndex,stringIndex)
                    b = string.byte(c)
                    if b > 128 then
                        self.stringBuff = self.stringBuff..string.sub(map.detail,stringIndex,stringIndex+2)
                        stringIndex = stringIndex + 3
                    else
                        self.stringBuff = self.stringBuff..c
                        stringIndex = stringIndex + 1
                    end

                    if stringIndex >= #map.detail then
                        if self.stringBuffTimeId then
                            TFDirector:removeTimer(self.stringBuffTimeId)
                            self.stringBuffTimeId = nil
                        end
                    end
                    self.Txt_content:setString(self.stringBuff)
                end)
        else
            self.Txt_content:setString(self.stringBuff)
        end
       
        

        if curStar >= maxStar then
            --只显示一个 继续闯关的 按钮
            self.Btn_getstar:setVisible(false)
            self.Btn_getstar:setTouchEnabled(false)
        else
            self.Btn_getstar:setVisible(true)
            self.Btn_getstar:setTouchEnabled(true)
        end
    end
end

--注册事件
function MissionSkipLayer:registerEvents()
    self.super.registerEvents(self)
    if self.mapBoxView then
        self.mapBoxView:callRegisterEvents()
    end
end

function MissionSkipLayer:removeEvents()
    self.super.removeEvents(self)

    self.Btn_getstar:removeMEListener(TFWIDGET_CLICK)
    self.Btn_goon:removeMEListener(TFWIDGET_CLICK)

 
    if self.effect then
        for i=1,#self.effect do
            if self.effect[i] then
                self.effect[i]:removeFromParent()
            end
        end        
    end        
    self.effect = nil
    self.enableUi = false
   

    if self.stringBuffTimeId then
        TFDirector:removeTimer(self.stringBuffTimeId)
        self.stringBuffTimeId = nil
    end

    if self.mapBoxView then
        self.mapBoxView:callRemoveEvents()
    end

end


function MissionSkipLayer:playEffectAnim()

    local FPS_T = GameConfig.ANIM_FPS
    if self.effect == nil then
        self.effect = {}
        self.enableUi = false

        for i=1,3 do        
            local resPath = "effect/skip_"..i..".xml"
            TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
            self.effect[i] = TFArmature:create("skip_"..i.."_anim")
            self.effect[i]:setAnimationFps(FPS_T)
            self.effect[i]:setPosition(ccp(0,6))
            self.Panel_anim:addChild(self.effect[i])
            self.effect[i]:setVisible(false)
        end

        local temp1 = 0
        self.effect[1]:playByIndex(0, -1, -1, 0)
        self.effect[1]:setVisible(true)
        self.effect[1]:setPosition(ccp(0,190))
        self.effect[2]:setPosition(ccp(0,190))

        self.effect[1]:addMEListener(TFARMATURE_UPDATE, function ()
            temp1 = temp1 + 1
            if temp1 >= 3 then
                self.effect[1]:removeMEListener(TFARMATURE_UPDATE)
                self.effect[2]:playByIndex(0, -1, -1, 1)
                self.effect[2]:setVisible(true)
                self.effect[2]:setScale(0.2)
                self.effect[2]:setAlpha(0)
                local toastTween1 = {
                    target = self.effect[1],                   
                    {
                        duration = 2*(1000/FPS_T)/1000,
                        alpha = 1,
                        scale = 1.27,
                        y = self.effect[1]:getPositionY() + 160
                    },
                    {
                        duration = 0,
                        onComplete = function()
                        end
                    }
                }
                
                local toastTween2 = {
                    target = self.effect[2],                   
                    {
                        duration = 2*(1000/FPS_T)/1000,
                        alpha = 1,
                        scale = 1.27,
                        y = self.effect[2]:getPositionY() + 160
                    },
                    {
                        duration = 5*(1000/FPS_T)/1000,
                        scale = 1
                    },
                    {
                        duration = 0,
                        onComplete = function()
                        end
                    }
                }
                TFDirector:toTween(toastTween1);
                TFDirector:toTween(toastTween2);
            end
        end)

        local temp3 = 0
        self.effect[3]:playByIndex(0, -1, -1, 0)
        self.effect[3]:setVisible(true)
        self.effect[3]:addMEListener(TFARMATURE_UPDATE, function ()
            temp3 = temp3 + 1
            if temp3 == 22 then
                self.effect[3]:removeMEListener(TFARMATURE_UPDATE)
                self.enableUi = true
                self:refreshUI()
            end
        end)
    end
end

return MissionSkipLayer

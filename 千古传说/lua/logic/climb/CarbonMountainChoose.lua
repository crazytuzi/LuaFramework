--[[
******无量山-万能副本详情*******

    -- by haidong.gan
    -- 2013/11/27
]]
local CarbonMountainChoose = class("CarbonMountainChoose", BaseLayer)

CREATE_SCENE_FUN(CarbonMountainChoose)
CREATE_PANEL_FUN(CarbonMountainChoose)

CarbonMountainChoose.LIST_ITEM_WIDTH = 200 

function CarbonMountainChoose:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.climb.CarbonMountainChoose")
end

function CarbonMountainChoose:initUI(ui)
    self.super.initUI(self,ui)

    self.Panel_Content = TFDirector:getChildByPath(ui, 'Panel_Content')

    -- self.btn_close          = TFDirector:getChildByPath(ui, 'btn_close')

    self.btn_1 = TFDirector:getChildByPath(ui, 'btn_pt')
    self.btn_2 = TFDirector:getChildByPath(ui, 'btn_kn')
    self.btn_3 = TFDirector:getChildByPath(ui, 'btn_zs')
    self.btn_4 = TFDirector:getChildByPath(ui, 'btn_cs')

    self.btn_1.index = 0
    self.btn_1.logic = self
    self.btn_2.index = 1
    self.btn_2.logic = self
    self.btn_3.index = 2
    self.btn_3.logic = self
    self.btn_4.index = 3
    self.btn_4.logic = self


    self.txt_times = TFDirector:getChildByPath(ui, 'txt_num')



    self.btnList = {}
    self.btnList[1] = self.btn_1
    self.btnList[2] = self.btn_2
    self.btnList[3] = self.btn_3
    self.btnList[4] = self.btn_4

    self.descList = {}
    self.starList = {}
    for i=1,4 do
        self.descList[i] = TFDirector:getChildByPath(self.btnList[i], 'txt_yikaiqi')
        self.starList[i] = {}
        for j=1,3 do
            local starNode = TFDirector:getChildByPath(self.btnList[i], 'img_stardi'..j)
            self.starList[i][j] = TFDirector:getChildByPath(starNode, 'img_star')
        end
    end

end

function CarbonMountainChoose:loadData(index)
    -- self.carbonItem = MoHeYaConfigure:objectAt(index)
    print("CarbonMountainChoose:loadData index = ", index)
    self.index = index
end

function CarbonMountainChoose:onShow()
    self.super.onShow(self)
    self:refreshUI()
    self:refreshBaseUI()
end

function CarbonMountainChoose:refreshBaseUI()

end

function CarbonMountainChoose:refreshUI()
    if not self.isShow then
        return
    end

    -- local index = 1 + (self.index -1) * 3
    local index = self.index
    local carbonItem = MoHeYaConfigure:objectAt(index)

    local resInfo = MainPlayer:GetChallengeTimesInfo(carbonItem.res_type)
    self.txt_times:setText(resInfo.currentValue)


    local desc = ""
    local carbonItemDiff1 = MoHeYaConfigure:objectAt(index + 1);
    if carbonItemDiff1.open_level >  MainPlayer:getLevel() then
        self.btnList[2]:setTextureNormal("ui_new/climb/MK_kunnan2.png");
        -- self.descList[2] = carbonItemDiff2.open_level.."级开启"
        --desc = carbonItemDiff1.open_level.."级开启"
        desc =stringUtils.format(localizable.common_open_level, carbonItemDiff1.open_level)
    else
        --desc = "已开启"
        desc = localizable.commom_open
    end
    self.descList[2]:setText(desc)

    local carbonItemDiff2 = MoHeYaConfigure:objectAt(index + 2);
    if carbonItemDiff2.open_level >  MainPlayer:getLevel() then
        self.btnList[3]:setTextureNormal("ui_new/climb/MK_zongshi2.png");
        -- self.descList[3] = carbonItemDiff2.open_level.."级开启"

        --desc = carbonItemDiff2.open_level.."级开启"
        desc = stringUtils.format(localizable.common_open_level, carbonItemDiff2.open_level)

    else
        -- self.descList[3] = "已开启"
        --desc  = "已开启"
        desc  = localizable.commom_open
    end

    self.descList[3]:setText(desc)

    local carbonItemDiff2 = MoHeYaConfigure:objectAt(index + 3);
    if carbonItemDiff2.open_level >  MainPlayer:getLevel() then
        self.btnList[4]:setTextureNormal("ui_new/climb/MK_cs2.png");
        -- self.descList[4] = carbonItemDiff2.open_level.."级开启"

        --desc = carbonItemDiff2.open_level.."级开启"
        desc =stringUtils.format(localizable.common_open_level, carbonItemDiff2.open_level)

    else
        -- self.descList[4] = "已开启"

        --desc  = "已开启"
        desc  = localizable.commom_open
    end
    self.descList[4]:setText(desc)

    for i=1,4 do
        local star = ClimbManager:getCarbonStarByID( index + i - 1 )
        for j=1,3 do
            if j <= star then
                self.starList[i][j]:setVisible(true)
            else
                self.starList[i][j]:setVisible(false)
            end
        end
    end
end




--   local status = MissionManager:getMissionPassStatus(missionId)
function CarbonMountainChoose.onAttackClickHandle(sender)
    local self = sender.logic
    print("onAttackClickHandle self.index = ", self.index)
-- 781号bug 策划说的要优化  策划：司徒。。。以后有问题找她
    local carbonItem = MoHeYaConfigure:objectAt(self.index)
    if carbonItem then
        local resConfigure = PlayerResConfigure:objectByID(carbonItem.res_type)
        local resInfo = MainPlayer:GetChallengeTimesInfo(carbonItem.res_type)
        local waitRemainExpression = resInfo:getWaitTimeExpression()

        if resInfo.currentValue < 1 then
            --toastMessage("今日挑战次数已用完")
            toastMessage(localizable.common_fight_times)
            return
        elseif waitRemainExpression ~= nil then
            --toastMessage("冷却 " .. waitRemainExpression .. " 后可再挑战")
            toastMessage(stringUtils.format(localizable.carbonMountain_cd,waitRemainExpression))
            return
        end
    end
--***********************************************
    local index = sender.index + self.index

    AlertManager:close()
    ClimbManager:showCarbonDetailLayer(index)
end


--注册事件
function CarbonMountainChoose:registerEvents()
   self.super.registerEvents(self)

   ADD_ALERT_CLOSE_LISTENER(self, self.Panel_Content)
   --  self.btn_close:setClickAreaLength(100)
    
   -- self.btn_attack.logic = self
   -- self.btn_attack:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onAttackClickHandle),1)

   -- self.btn_army.logic = self
   -- self.btn_army:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onArmyClickHandle),1)

   self.btn_1:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onAttackClickHandle),1)
   self.btn_2:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onAttackClickHandle),1)
   self.btn_3:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onAttackClickHandle),1)
   self.btn_4:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onAttackClickHandle),1)

end

function CarbonMountainChoose:removeEvents()

end



return CarbonMountainChoose

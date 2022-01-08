--[[
******选矿界面*******
    -- by yao
    -- 2016/1/12
]]

local ChooseMineralLayer = class("ChooseMineralLayer", BaseLayer)

function ChooseMineralLayer:ctor(data)
    self.super.ctor(self,data)
    self.checkedIndex   = 0
    self.kuangshiArr    = {}
    self.checkEffect    = nil
    self.holeType       = 1
    self.mineralInfo    = {}
    self.ui             = ui
    self.isRefresh      = false     --是否点击了更新按钮
    self:init("lua.uiconfig_mango_new.mining.xuankuang1")
end

function ChooseMineralLayer:initUI(ui)
	self.super.initUI(self,ui)
    self.ui = ui
    self.generalHead = CommonManager:addGeneralHead( self ,10)
    self.generalHead:setData(ModuleType.ChooseMineral,{HeadResType.JIEKUANGLING,HeadResType.COIN,HeadResType.SYCEE})

    --刷新按钮
    self.btn_shuaxin    = TFDirector:getChildByPath(ui, "btn_shuaxin")
    --采矿布阵按钮
    self.btn_ckbz       = TFDirector:getChildByPath(ui, "btn_ckbz")
    --找人护矿按钮
    self.btn_zrhk       = TFDirector:getChildByPath(ui, "btn_zrhk")
    --采矿按钮
    self.btn_caikuang   = TFDirector:getChildByPath(ui, "btn_caikuang")
    --选中框
    self.img_select     = TFDirector:getChildByPath(ui, "img_select")
    --刷新消耗
    self.txt_price      = TFDirector:getChildByPath(ui, "txt_price")
    self.bg_role        = TFDirector:getChildByPath(ui, "bg_role")
    self.btn_imgrole       = TFDirector:getChildByPath(ui, "btn_imgrole")
    self.txt_name       = TFDirector:getChildByPath(ui, "txt_name")
    -- 

    self.img_res_bg       = TFDirector:getChildByPath(ui, "img_res_bg")
    self.txt_freetime       = TFDirector:getChildByPath(ui, "txt_freetime")


    self.btn_shuaxin.logic  = self
    self.btn_ckbz.logic     = self
    self.btn_zrhk.logic     = self
    self.btn_caikuang.logic = self
end

function ChooseMineralLayer:loadData(type)
    self.holeType = type
    local info = MiningManager:getMineralDetailInfo()
    self.mineralInfo = info[type]
    self.checkedIndex = self.mineralInfo.type
    self:showUIData()
end

function ChooseMineralLayer:removeUI()
    self.super.removeUI(self)
end

-----断线重连支持方法
function ChooseMineralLayer:onShow()
    self.super.onShow(self)
    self.generalHead:onShow()
end

function ChooseMineralLayer:registerEvents()
    self.super.registerEvents(self)
    if self.generalHead then
        self.generalHead:registerEvents()
    end

    self.btn_shuaxin:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onShuaXinCallBack))
    self.btn_ckbz:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCaikuangBuzhenCallBack))
    self.btn_zrhk:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onZhaorenHukuangCallBack))
    self.btn_caikuang:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCaikuangCallBack))

    self.eventUpdateCheckMineral = function(event)
        local info = MiningManager:getMineralDetailInfo()
        self.mineralInfo = info[self.holeType]
        self.checkedIndex = self.mineralInfo.type
        MiningManager:setMyProtectPlayer(self.holeType, self.mineralInfo.playerId)
        self:showUIData()
        if self.isRefresh then
            self.isRefresh = false
            self:addCheckedEffect()
            play_caikuang_shuaxin()
        end
    end;
    TFDirector:addMEGlobalListener(MiningManager.EVENT_UPDATE_MINERALINFO, self.eventUpdateCheckMineral)
    self.eventUpdateMineResult = function(event)
        --print("采矿成功")
        AlertManager:close()
        play_chongxue()
    end;
    TFDirector:addMEGlobalListener(MiningManager.EVENT_UPDATE_MINERESULT, self.eventUpdateMineResult)
end

function ChooseMineralLayer:removeEvents()
    self.btn_shuaxin:removeMEListener(TFWIDGET_CLICK)
    self.btn_ckbz:removeMEListener(TFWIDGET_CLICK)
    self.btn_zrhk:removeMEListener(TFWIDGET_CLICK)
    self.btn_caikuang:removeMEListener(TFWIDGET_CLICK)

    TFDirector:removeMEGlobalListener(MiningManager.EVENT_UPDATE_MINERALINFO, self.eventUpdateCheckMineral)
    TFDirector:removeMEGlobalListener(MiningManager.EVENT_UPDATE_MINERESULT, self.eventUpdateMineResult)
    if self.generalHead then
        self.generalHead:removeEvents()
    end
    self.super.removeEvents(self)
end

function ChooseMineralLayer:dispose()
    self.super.dispose(self)
end

function ChooseMineralLayer:showUIData()
    if self.checkedIndex >= 4 then
        self.btn_shuaxin:setGrayEnabled(true)
        self.btn_shuaxin:setTouchEnabled(false)
    else
        self.btn_shuaxin:setGrayEnabled(false)
        self.btn_shuaxin:setTouchEnabled(true)
    end
    local num = 4
    for i=1,num do
        local bgkuang       = TFDirector:getChildByPath(self.ui, "bg_kuang" .. i)
        local img_ks        = TFDirector:getChildByPath(bgkuang, "img_ks")
        local img_name      = TFDirector:getChildByPath(bgkuang, "img_name")
        local img_tongbi    = TFDirector:getChildByPath(bgkuang, "img_tongbi")
        local txt_changchu  = TFDirector:getChildByPath(bgkuang, "txt_changchu")

        
        --img_tongbi:setTexture()
        -- txt_changchu:setText(mineInfo.reward_coin)
        -- rewardCoin * (int(sqrt(等级*95000)-10))
        local level = MainPlayer:getLevel()
        local result = math.sqrt(level*9.5)-10
        local mineInfo = MineTemplateData:getMinetempById(i,self.holeType)
        local coin = math.ceil(mineInfo.reward_number * result) --(int(sqrt(等级*95000)-10))
        txt_changchu:setText(coin)

        if self.holeType == 1 then
            img_ks:setTexture("ui_new/mining/img_ks" .. i .. ".png")
            img_name:setTexture("ui_new/mining/img_k" .. i .. ".png")
            img_tongbi:setTexture("ui_new/common/xx_tongbi_icon.png")
            if i >= 3 then
                local bg_changchu2  = TFDirector:getChildByPath(bgkuang, "bg_changchu2")
                local img_tongbi2    = TFDirector:getChildByPath(bg_changchu2, "img_tongbi")
                local txt_changchu2  = TFDirector:getChildByPath(bg_changchu2, "txt_changchu")
                img_tongbi2:setTexture("ui_new/common/yuanbao2.png")
                --txt_changchu2:setText("微量")
                txt_changchu2:setText(localizable.chooseMinLayer_trace)
                if i == 4 then
                    --txt_changchu2:setText("少量")
                    txt_changchu2:setText(localizable.chooseMinLayer_little)
                end
            end
        else
            img_ks:setTexture("ui_new/mining/img_ks" .. i+4 .. ".png")
            img_name:setTexture("ui_new/mining/img_k" .. i+4 .. ".png")
            img_tongbi:setTexture("ui_new/smithy/intensify_stone_s.png")
            if i >= 3 then
                local bg_changchu2  = TFDirector:getChildByPath(bgkuang, "bg_changchu2")
                local img_tongbi2    = TFDirector:getChildByPath(bg_changchu2, "img_tongbi")
                local txt_changchu2  = TFDirector:getChildByPath(bg_changchu2, "txt_changchu")
                img_tongbi2:setTexture("ui_new/common/xx_baoshi_icon.png")
                txt_changchu2:setText(localizable.chooseMinLayer_trace)
                --txt_changchu2:setText("微量")
                if i == 4 then
                    txt_changchu2:setText(localizable.chooseMinLayer_little)
                    --txt_changchu2:setText("少量")
                end
            end
        end

        self.kuangshiArr[i] = bgkuang
    end

    local guardPlayerInfo = self.mineralInfo.guardInfo
    if guardPlayerInfo == nil then
        self.btn_imgrole:setVisible(false)
        self.txt_name:setText("")
    else
        local RoleIcon = RoleData:objectByID(guardPlayerInfo.icon)                      --pck change head icon and head icon frame
        Public:addFrameImg(self.btn_imgrole,guardPlayerInfo.headPicFrame)              --end
        Public:addInfoListen(self.btn_imgrole,true,1,guardPlayerInfo.playerId)
        --self.bg_role:setTexture(GetColorRoadIconByQuality(RoleIcon.quality))
        self.btn_imgrole:setTextureNormal(RoleIcon:getIconPath())           
        self.btn_imgrole:setVisible(true)
        --self.btn_imgrole:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onRoleCallBack))
        self.btn_imgrole.id = RoleIcon.id
        self.btn_imgrole.logic = self
        self.btn_imgrole.role = RoleIcon
        --print("RoleIcon.id:",RoleIcon.id)
        self.txt_name:setText(guardPlayerInfo.name)
    end   

    local needprice = MiningManager:getRefreshNeedYuanbao()
    self.txt_price:setText(needprice)
    self.img_select:setPosition(self.kuangshiArr[self.checkedIndex]:getPosition())

    local leftFreeRefreshTime = MiningManager.roleMineInfo.leftFreeRefreshTime or 0
    if leftFreeRefreshTime > 0 then
        self.txt_freetime:setVisible(true)
        self.img_res_bg:setVisible(false)
        --self.txt_freetime:setText("免费次数:"..leftFreeRefreshTime)
        self.txt_freetime:setText(stringUtils.format(localizable.chooseMinLayer_free,leftFreeRefreshTime))
    else
        self.txt_freetime:setVisible(false)
        self.img_res_bg:setVisible(true)
    end
end

--刷新按钮回调
function ChooseMineralLayer.onShuaXinCallBack(sender) 
    local self = sender.logic
    MiningManager:requestRefreshMine(self.holeType)
    self.isRefresh = true
end

--采矿布阵按钮回调
function ChooseMineralLayer.onCaikuangBuzhenCallBack(sender) 
    local self = sender.logic
    MiningManager:gotoMiningArmyLayer(self.holeType) 
end

--找人护矿按钮回调
function ChooseMineralLayer.onZhaorenHukuangCallBack(sender) 
    local self = sender.logic
    -- MiningManager:gotoAskForHelp(self.holeType)
    EmployManager:openHireTeamLayer(self.holeType,function ( hireInfo )
        print("请求护矿  hireInfo = ", hireInfo)
        MiningManager:reauestGuardMine(hireInfo.playerId, self.holeType)
    end)
end

--采矿按钮回调
function ChooseMineralLayer.onCaikuangCallBack(sender) 
    local self = sender.logic
    local guardPlayerInfo = self.mineralInfo.guardInfo
    local friendId = 0
    if guardPlayerInfo ~= nil then
        friendId = guardPlayerInfo.playerId
    end
    local IsHaveRoleList = MiningManager:getIsHaveRoleListByIndex(self.holeType)
    if IsHaveRoleList == false then
        --toastMessage("至少上阵一个侠客")
        toastMessage(localizable.commont_team_one)
    else
        if friendId == 0 then
            --local str = "没有选择护矿者，将更容易受到打劫，是否确认独自采矿？"
            local str = localizable.Mining_No_Protector
            self:openCell(str,self.holeType,friendId)
        else
            MiningManager:requestMine(self.holeType,friendId)
        end
    end
      
end

--选中矿石特效
function ChooseMineralLayer:addCheckedEffect()
    if self.checkEffect ~= nil then
        self.checkEffect:removeFromParent()
    end
    TFResourceHelper:instance():addArmatureFromJsonFile("effect/yabiao2.xml")
    self.checkEffect = TFArmature:create("yabiao2_anim")
    if self.checkEffect == nil then
        return  
    end
    self.checkEffect:setAnimationFps(GameConfig.ANIM_FPS)
    self.checkEffect:setPosition(ccp(440, 0))
    self.checkEffect:setTag(100)
    self.checkEffect:setScale(2)
    self.kuangshiArr[self.checkedIndex]:addChild(self.checkEffect,1)
    self.checkEffect:playByIndex(0, -1, -1, 0)
end

--提示
function ChooseMineralLayer:openCell(str,holeType,friendId)
    CommonManager:showOperateSureLayer(
        function()
            MiningManager:requestMine(holeType,friendId)
        end,
        function()
            AlertManager:close()
        end,
        {
            --title = "提示" ,
            title = localizable.common_tips ,
            msg = str,
            uiconfig = "lua.uiconfig_mango_new.common.OperateSure"
        }
    )
end

--点击人物返回
function ChooseMineralLayer.onRoleCallBack(sender)
    local self = sender.logic
    local id   = sender.id
    local role = sender.role
    Public:ShowItemTipLayer(role.id, EnumDropType.ROLE, 1,role.level)
end

return ChooseMineralLayer
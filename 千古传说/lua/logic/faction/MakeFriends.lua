--[[
******帮派结交界面*******

	-- by quanhuan
	-- 2015/10/29
	
]]

local MakeFriends = class("MakeFriends",BaseLayer)

function MakeFriends:ctor(data)
	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.faction.MakeFriends")
end

function MakeFriends:initUI( ui )
	self.super.initUI(self, ui) 

    self.btnClose = TFDirector:getChildByPath(ui, "btn_close")
    self.txtNum = TFDirector:getChildByPath(ui, "txt_cishu")

    local btnName = {"Button_xjhw","Button_yjjl","Button_tggs"}
    self.btnTab = {}
    for i=1,3 do
        self.btnTab[i] = {}
        self.btnTab[i].btn = TFDirector:getChildByPath(ui, btnName[i])
        self.btnTab[i].tili = TFDirector:getChildByPath(self.btnTab[i].btn, "txt_tili")
        self.btnTab[i].use = TFDirector:getChildByPath(self.btnTab[i].btn, "txt_mf")
        self.btnTab[i].vip = TFDirector:getChildByPath(self.btnTab[i].btn, "txt_vip")
        self.btnTab[i].btn.idx = i
    end
end

function MakeFriends:removeUI()
   	self.super.removeUI(self)
end

function MakeFriends:onShow()
    self.super.onShow(self)
end

function MakeFriends:registerEvents()

	self.super.registerEvents(self)

    self.btnClose:addMEListener(TFWIDGET_CLICK, audioClickfun(self.closeButtonClick))
    for i=1,3 do
        self.btnTab[i].btn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnTabClick))
    end
end

function MakeFriends:removeEvents()
	
    print("removeEvents")
    self.super.removeEvents(self)

    self.btnClose:removeMEListener(TFWIDGET_CLICK)
    for i=1,3 do
        self.btnTab[i].btn:removeMEListener(TFWIDGET_CLICK)
    end
end

function MakeFriends:dispose()
    self.super.dispose(self)
end

function MakeFriends:refreshWindow()
    local currTimes = FactionManager:getCurrMakePlayerTimes()
    local totalTimes = FactionManager:getTotalMakePlayerTimes()
    currTimes = totalTimes - currTimes
    if currTimes < 0 then
        currTimes = 0
    end
	self.txtNum:setText(currTimes)

    local vipTable = {}
    for v in VipData:iterator() do
        if v.benefit_code == 7000 then
            local idx = #vipTable + 1
            vipTable[idx] = v.vip_level
        end
    end

    self.btnTab[2].vip:setText("o"..vipTable[2])
    self.btnTab[3].vip:setText("o"..vipTable[3])   

end

function MakeFriends.closeButtonClick( btn )
    AlertManager:close()
end

function MakeFriends.btnTabClick( btn )
    local idx = btn.idx

    if FactionManager:isCanMakePlayerWithType(idx) then
        if idx == 1 and MainPlayer:getCoin() < 20000 then
            --toastMessage("铜币不够")
            toastMessage(localizable.common_no_tongbi)
        elseif idx == 2 and MainPlayer:getSycee() < 30 then
            --toastMessage("元宝不够")
            toastMessage(localizable.common_no_yuanbao)
        elseif idx == 3 and MainPlayer:getSycee() < 150 then
            --toastMessage("元宝不够")
            toastMessage(localizable.common_no_yuanbao)           
        else
            FactionManager:requestMakePlayer(idx)    
        end
    else
        
        local list = VipData:getVipListByType( 7000)
        for v in list:iterator() do
            if v.benefit_value == idx then
                if MainPlayer:getVipLevel() < v.vip_level then
                     local msg =  stringUtils.format(localizable.vip_factionMakeFriend_not_enough,v.vip_level,localizable.faction_makeFriend_show[idx]);
                    CommonManager:showOperateSureLayer(
                            function()
                                PayManager:showPayLayer();
                            end,
                            nil,
                            {
                            --title = "提升VIP",
			                title = localizable.common_vip_up,
                            msg = msg,
                            uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
                            }
                    )
                end
                return
            end
        end
        -- toastMessage("请提升VIP等级")
    end
end

return MakeFriends
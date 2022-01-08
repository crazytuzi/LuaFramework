--test
local MainPlayerLayer2 = class("MainPlayerLayer2", BaseLayer)


CREATE_PANEL_FUN(MainPlayerLayer2)

function MainPlayerLayer2:ctor()
    print("MainPlayerLayer2 ctor")
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.main.MainPlayerLayer")
end


function MainPlayerLayer2:initUI(ui)
    print("MainPlayerLayer2 initUI")
	self.super.initUI(self,ui)

    self.btn_close      = TFDirector:getChildByPath(ui, 'btn_close')
    self.btn_rename		= TFDirector:getChildByPath(ui, 'btn_rename')
    self.btn_setting	= TFDirector:getChildByPath(ui, 'btn_shezhi')

    self.txt_sycee		= TFDirector:getChildByPath(ui, 'txt_sycee')
    self.txt_coin       = TFDirector:getChildByPath(ui, 'txt_coin')
    self.txt_zhenqi     = TFDirector:getChildByPath(ui, 'txt_zhenqi')
    self.txt_power      = TFDirector:getChildByPath(ui, 'txt_power')

    self.txt_vip        = TFDirector:getChildByPath(ui, 'txt_vip')
    self.img_vip        = TFDirector:getChildByPath(ui, 'img_vip')

    self.txt_id         = TFDirector:getChildByPath(ui, 'Label_MainPlayerLayer_1')
    self.txt_name       = TFDirector:getChildByPath(ui, 'txt_name')
    self.txt_level      = TFDirector:getChildByPath(ui, 'txt_level')
    self.bar_exp        = TFDirector:getChildByPath(ui, 'bar_exp')
    self.txt_exp        = TFDirector:getChildByPath(ui, 'txt_exp')

    self.txt_equip_max    = TFDirector:getChildByPath(ui, 'txt_equip_max')
    self.txt_level_max    = TFDirector:getChildByPath(ui, 'txt_level_max')
    self.txt_role_max     = TFDirector:getChildByPath(ui, 'txt_role_max')
    self.zhaunhuanBtn     = TFDirector:getChildByPath(ui, 'btn_genhuanzhujue')
    self.btn_SetHeadIcon  = TFDirector:getChildByPath(ui, 'btn_genhuantouxiang')
    self.btn_SetFrame     = TFDirector:getChildByPath(ui, 'btn_genhuanbiankuang-Copy1')

    self.bg_touxiang    = TFDirector:getChildByPath(ui, 'bg_touxiang')
    self.touxiang       = TFDirector:getChildByPath(ui, 'Image_MainPlayerLayer_1')


    self.node_pointArr        = {}
    self.txt_timesValue_arr   = {}
    self.txt_timeLeft_arr     = {}
    for i=1,4 do
        self.node_pointArr[i] = TFDirector:getChildByPath(ui, 'img_point_' .. i)
        self.txt_timesValue_arr[i] = TFDirector:getChildByPath(self.node_pointArr[i], 'txt_value')
        self.txt_timeLeft_arr[i] = TFDirector:getChildByPath(self.node_pointArr[i], 'txt_time')
    end
    self.node_pointArr[4]:setVisible(false) 
    self.img_head     = TFDirector:getChildByPath(ui, 'img_icon')


    self.img_new_vip = TFDirector:getChildByPath(ui, "img_new_vip")
    self.btn_tequan = TFDirector:getChildByPath(ui, "btn_VIPtequan")
    
    	-- !! logic = self
    self.btn_tequan.logic = self
end

function MainPlayerLayer2:onShow()
    self.super.onShow(self)
    print("MainPlayerLayer2 onShow")
    self:refreshBaseUI();
    self:refreshUI();
    self:refreshTiemsUI();
end

function MainPlayerLayer2:refreshBaseUI()
	self:refreshTiemsUI();

	self.onUpdated = function(event)
		self:refreshTiemsUI();
	end;

	if not self.nTimerId then 
		self.nTimerId = TFDirector:addTimer(1000, -1, nil, self.onUpdated); 
	end
end

function MainPlayerLayer2:refreshUI()
	if not self.isShow then
		return;
	end

	if CommonManager:isTuhao() then
		self.btn_tequan:setVisible(true)
	else
		self.btn_tequan:setVisible(false)
	end

	self.img_vip:setVisible(true)
	self.img_new_vip:setVisible(false)

	if MainPlayer:getVipLevel() > 0 then
		self.img_vip:setVisible(true)
		self.txt_vip:setText("o"..MainPlayer:getVipLevel())

		local vipLevel = MainPlayer:getVipLevel()
        --modify by zr VIP等级显示
        --[[
		if vipLevel > 15 then
			self.txt_vip:setVisible(false)
			self.img_new_vip:setVisible(true)
			--self:addVip
		end]]--
	else
		self.img_vip:setVisible(false)
		self.img_new_vip:setVisible(false)
	end

	self.img_head:setTexture("ui_new/team/team_role_"..MainPlayer:getProfession()..".png")
	self.touxiang:setTexture(MainPlayer:getIconPath())

	self.txt_id:setText(MainPlayer:getPlayerId())
	self.txt_name:setText(MainPlayer:getPlayerName())
	self.txt_level:setText(MainPlayer:getLevel() .. " d:")

	self.txt_role_max:setText(stringUtils.format(localizable.common_person, StrategyManager:getFightRoleNum() , StrategyManager:getMaxNum() ))
    self.txt_equip_max:setText("装备强化上上上：".. ConstantData:getValue("Equip.StrengthenMax.Multiple")*MainPlayer:getLevel() .."级")
    
    --CommonManager:setRedPoint(self.btn_SetFrame, HeadPicFrameManager:haveFirstGetFrame(),"haveFirstGetFrame",ccp(10,0))
	CommonManager:setRedPoint(self.btn_SetFrame, true,"haveFirstGetFrame",ccp(10,0))

--[[
	local b = CommonManager:isTuhao() and CommonManager:getTuhaoFreeTimes() > 0 
    if b then
        CommonManager:updateRedPoint(self.btn_tequan, true, ccp(self.btn_tequan:getSize().width / 2 - 35, self.btn_tequan:getSize().height / 2 - 25))  
    else
        CommonManager:removeRedPoint(self.btn_tequan)
    end 
]]
        CommonManager:updateRedPoint(self.btn_tequan, true, ccp(self.btn_tequan:getSize().width / 2 - 35, self.btn_tequan:getSize().height / 2 - 25))  
    
end

function MainPlayerLayer2:refreshTiemsUI()
	for type=1,3 do
		local pointInfo = MainPlayer:GetChallengeTimesInfo(type)

		local leftChallengeTimes = pointInfo:getLeftChallengeTimes()
		self.txt_timesValue_arr[type]:setText(leftChallengeTimes)

        if pointInfo.cdLeaveTimeOjb then
            local leftCoolTime = pointInfo.cdLeaveTimeOjb:getOneRecoverTime()
            if leftCoolTime > 0 and leftChallengeTimes  < pointInfo.maxValue then
                self.txt_timeLeft_arr[type]:setVisible(true)
                self.txt_timeLeft_arr[type]:setText(pointInfo.cdLeaveTimeOjb:getOneRecoverTimeString())
            else
                self.txt_timeLeft_arr[type]:setVisible(false)
            end
        else
            self.txt_timeLeft_arr[type]:setVisible(false)
        end
	end
end

function MainPlayerLayer2:removeUI()

    self.super.removeUI(self)
    print("MainPlayerLayer2 removeUI")
end


function MainPlayerLayer2.onRenameClickHandle(sender)
    local self = sender.logic

    CommonManager:showReNameLayer();
end

function MainPlayerLayer2.onVipTequanClickHandle(sender)
    if not CommonManager:isTuhao() then
        toastMessage(localizable.common_vip_not_tuhao1)
        return
    end
    local self = sender.logic
    CommonManager:showTuhaoPopLayer(
        function(data)            
            NotifyManager:addTuhaoChatNotify(MainPlayer:getPlayerName(), data, MainPlayer:getVipLevel())
        end,
        function()            
        end,
        {
            title = localizable.mainPlayerLayer_tuhao_xuanyan,
            msg = msg,
            MaxLength = 40,
        }
    )
end


function MainPlayerLayer2:registerEvents()
    self.super.registerEvents(self);
    ADD_ALERT_CLOSE_LISTENER(self, self.btn_close);

    self.btn_close:setClickAreaLength(100);
    print("MainPlayerLayer2 registerEvents")


    self.btn_rename.logic = self;
    self.btn_rename:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onRenameClickHandle),1);

	self.updateChallengeTimesCallBack = function(event)
        self:refreshBaseUI();
    end;
    TFDirector:addMEGlobalListener(MainPlayer.ChallengeTimesChange ,self.updateChallengeTimesCallBack ) ;

end

function MainPlayerLayer2:removeEvents()
	print("MainPlayerLayer2 removeEvents")

    TFDirector:removeMEGlobalListener(MainPlayer.ChallengeTimesChange,self.updateChallengeTimesCallBack);
    
    if self.nTimerId then
        TFDirector:removeTimer(self.nTimerId);
        self.nTimerId = nil;
    end

	self.super.removeEvents();
end

return MainPlayerLayer2
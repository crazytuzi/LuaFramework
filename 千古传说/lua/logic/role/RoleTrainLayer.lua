--[[
******角色经脉*******
    -- by haidong.gan
    -- 2014/4/10
]]
local RoleTrainLayer = class("RoleTrainLayer", BaseLayer)

--local trainNames = {"带脉","冲脉","任脉","督脉","跷脉","维脉"};
local trainNames = localizable.trainLayer_trainNames
local trainImgs = {"js_daimai_icon.png","js_chongmai_icon.png","js_renmai_icon.png","js_dumai_icon.png","js_raomai_icon.png","js_weimai_icon.png"};

function RoleTrainLayer:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.role.TrainLayer");
end

function RoleTrainLayer:initUI(ui)
	self.super.initUI(self,ui)

    self.generalHead = CommonManager:addGeneralHead( self )

    self.generalHead:setData(ModuleType.RoleTrain,{HeadResType.COIN,HeadResType.SYCEE,HeadResType.GENUINE_QI})

    self.panel_role     = TFDirector:getChildByPath(ui, 'panel_rolehead');
    self.panel_content     = TFDirector:getChildByPath(ui, 'panel_content');

    self.img_role       = TFDirector:getChildByPath(self.panel_role, 'img_head');
    self.txt_level      = TFDirector:getChildByPath(self.panel_role, 'txt_lev');
    self.lb_max      	= TFDirector:getChildByPath(self, 'txt_wenben_icon');

    self.txt_name       = TFDirector:getChildByPath(self.panel_role, 'txt_name');
    self.img_quality    = TFDirector:getChildByPath(self.panel_role, 'img_quality');
    self.txt_power      = TFDirector:getChildByPath(self.panel_role, 'txt_power');
    self.img_type       = TFDirector:getChildByPath(self.panel_role, 'img_zhiye');
    self.imgStarList = {}
    for i=1,5 do
        self.imgStarList[i] = TFDirector:getChildByPath(self.panel_role, "img_stars"..i)
    end


	self.btn_through = TFDirector:getChildByPath(ui, 'btn_through');
	self.btn_uplevl  = TFDirector:getChildByPath(ui, 'btn_uplevl');
	self.btn_jump    = TFDirector:getChildByPath(ui, 'btn_jump');


    self.panel_detail     = TFDirector:getChildByPath(ui, 'Panel_meridiandetails');
	
	-- self.txt_acupointName = TFDirector:getChildByPath(ui, 'txt_acupointName');
	self.img_acupointIcon = TFDirector:getChildByPath(self.panel_detail, 'img_jingmainame');
	self.txt_acupoint_growupvalue      = TFDirector:getChildByPath(self.panel_detail, 'txt_growupvalue');
	self.txt_acupoint_level      = TFDirector:getChildByPath(self.panel_detail, 'txt_level');
	self.bar_acupoint_level      = TFDirector:getChildByPath(self.panel_detail, 'bar_level');
	self.txt_acupoint_effectValue = TFDirector:getChildByPath(self.panel_detail, 'txt_jingmaishuxingvalue');
	self.txt_acupoint_effectName = TFDirector:getChildByPath(self.panel_detail, 'txt_jingmaishuxing');
	
	-- self.txt_acupoint_effectNum  = TFDirector:getChildByPath(self.panel_detail, 'txt_acupoint_effectNum');
	self.txt_acupoint_xiahunNeed = TFDirector:getChildByPath(self, 'txt_xiaohao2');
	self.txt_xiaohao1 = TFDirector:getChildByPath(self, 'txt_xiaohao1');
	self.img_point = TFDirector:getChildByPath(self, 'img_point');

	self.img_acupoint_quality = TFDirector:getChildByPath(self.panel_detail, 'img_quality');
	
	self.panel_arr      = TFDirector:getChildByPath(ui, 'Panel_meridiandetails');
    self.img_diwen1        = TFDirector:getChildByPath(ui, 'img_diwen1')

	-- self.txt_acupoint_openLevel  = TFDirector:getChildByPath(ui, 'txt_acupoint_openLevel');

	self.img_xian1Arr = {}
	self.img_xian2Arr = {}

	self.img_acupointArr = {}
	self.btn_pointArr = {}
	self.btn_suoArr = {}
	self.bar_levelArr = {}
	self.img_xuanzhongArr = {}
	self.img_mingchengArr = {}

	for i=1,#trainNames do
		self.img_acupointArr[i] = TFDirector:getChildByPath(self.ui, 'img_acupoint'..i)

		self.btn_pointArr[i] = TFDirector:getChildByPath(self.img_acupointArr[i], 'btn_point')
		self.btn_suoArr[i] = TFDirector:getChildByPath(self.img_acupointArr[i], 'btn_suo')
		self.bar_levelArr[i] = TFDirector:getChildByPath(self.img_acupointArr[i], 'bar_jidu')
		
		self.img_xuanzhongArr[i] = TFDirector:getChildByPath(self.img_acupointArr[i], 'img_xuanzhong')
		self.img_mingchengArr[i] = TFDirector:getChildByPath(self.img_acupointArr[i], 'img_mingcheng')

		self.img_xian1Arr[i] = TFDirector:getChildByPath(self.img_acupointArr[i], 'img_xian1')
		self.img_xian1Arr[i]:setVisible(false);
		self.img_xian2Arr[i]  = TFDirector:getChildByPath(self.img_acupointArr[i], 'img_xian2')
		self.img_xian2Arr[i]:setVisible(false);
	end
end
function RoleTrainLayer:removeUI()
    self.super.removeUI(self)
end

function RoleTrainLayer:dispose()
	if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end

    self.super.dispose(self)
end

function RoleTrainLayer:loadData(roleGmId)
    self.roleGmId   = roleGmId;
end

function RoleTrainLayer:onShow()
	self.super.onShow(self)
	self.generalHead:onShow();
    self:refreshBaseUI();
    self:refreshUI();
end

function RoleTrainLayer:refreshBaseUI()

end

function RoleTrainLayer:refreshUI()
    if not self.isShow then
        return;
    end
    self.cardRole = CardRoleManager:getRoleByGmid(self.roleGmId);

	self.img_role:setTexture(self.cardRole:getBigImagePath());
    self.txt_name:setText(self.cardRole.name);
    -- self.txt_name:setColor(GetColorByQuality(self.cardRole.quality));
    self.img_quality:setTexture(GetFontByQuality(self.cardRole.quality));

    -- self.img_diwen1:setTexture(GetRoleNameBgByQuality(self.cardRole.quality))

    
    self.txt_level:setText(self.cardRole.level);
    self.txt_power:setText(self.cardRole.power);
    self.img_type:setTexture("ui_new/common/img_role_type" .. self.cardRole.outline .. ".png");
    
    -- if self.cardRole.maxExp == 0 then
    --     self.txt_exp:setText("满级")
    --     self.bar_exp:setPercent(100)
    -- else
    --     self.bar_exp:setPercent((self.cardRole.curExp/self.cardRole.maxExp)*100);
    --     self.txt_exp:setText((self.cardRole.curExp.."/"..self.cardRole.maxExp));
    -- end

    -- for i=1,5 do
    --     if (self.cardRole.starlevel >= i) then
    --          self.imgStarList[i]:setVisible(true);
    --     else
    --          self.imgStarList[i]:setVisible(false);
    --     end
    -- end

  --   for i=1,3 do
		-- local img_youshishuxing = TFDirector:getChildByPath(self.ui, 'img_youshishuxing'..i)
		-- img_youshishuxing:setVisible(false);
  --   end

  --  local arrStr = self.cardRole:getOutline();

  --  if #arrStr == 1 then
		-- local img_youshishuxing = TFDirector:getChildByPath(self.ui, 'img_youshishuxing'..3)
		-- local txt_youshishuxing = TFDirector:getChildByPath(img_youshishuxing, 'txt_youshishuxing')
		-- txt_youshishuxing:setText(arrStr[1]);
		-- img_youshishuxing:setVisible(true);
  --  end

	-- if #arrStr == 2 then
	-- 	for i=1,2 do
	-- 		local img_youshishuxing = TFDirector:getChildByPath(self.ui, 'img_youshishuxing'..i)
	-- 		local txt_youshishuxing = TFDirector:getChildByPath(img_youshishuxing, 'txt_youshishuxing')
	-- 		txt_youshishuxing:setText(arrStr[i]);
	-- 		img_youshishuxing:setVisible(true);
	-- 	end
	-- end

	local isAllToMaxLevel = true;

	for i=1,#trainNames do
		
		local acupointInfo = self.cardRole:GetAcupointInfo(i)
		if acupointInfo ~= nil then
			self.btn_pointArr[i]:setVisible(true);
			self.btn_suoArr[i]:setVisible(false);
			self.bar_levelArr[i]:setVisible(true);
			self.img_xuanzhongArr[i]:setVisible(true);
		else
			self.btn_pointArr[i]:setVisible(false);
			self.btn_suoArr[i]:setVisible(true);
			self.bar_levelArr[i]:setVisible(false);
			self.img_xuanzhongArr[i]:setVisible(false);
		end

		self.btn_pointArr[i]:setBright(true);
		self.img_xuanzhongArr[i]:setVisible(false);

		local effect = TFDirector:getChildByPath(self.ui, 'Panel_shuxing'..i)
		local effect_open = TFDirector:getChildByPath(effect, 'Panel_jihuo')
		local effect_not_open = TFDirector:getChildByPath(effect, 'Panel_weijihuo')
		
		-- local txt_effectText  = TFDirector:getChildByPath(effect, 'txt_effectText')
		local txt_effectNum = TFDirector:getChildByPath(effect, 'txt_shuxingzhi')
		local txt_effectName = TFDirector:getChildByPath(effect, 'txt_shuxing')
		-- txt_effectText:setText(trainNames[i] .. ":");

		if acupointInfo ~= nil then
			effect_open:setVisible(true);
			effect_not_open:setVisible(false);
			local table_arr = GetAttrByString(acupointInfo.buffStr);
		    for attribute,num in pairs(table_arr) do
		        txt_effectName:setText(AttributeTypeStr[attribute]);
			    txt_effectNum:setText("+"..num);
		        break;
		    end

    		local maxLevel = CardRoleManager:getTrainMaxLevel(self.cardRole.gmId);
    		if acupointInfo.level < maxLevel then
    			isAllToMaxLevel = false;
    		end

    		self.bar_levelArr[i]:setPercent((acupointInfo.level/maxLevel)*100);
		else
			effect_open:setVisible(false);
			effect_not_open:setVisible(true);
			local txt_wenben = TFDirector:getChildByPath(effect_not_open, 'txt_wenben')
			--txt_wenben:setText("突破到" .. QUALITY_STR[ConstantData:getValue("Pulse.Position" .. i .. ".Quality.open")] .. "品后开放")
			txt_wenben:setText(stringUtils.format(localizable.roleTrain_text1 ,QUALITY_STR[ConstantData:getValue("Pulse.Position" .. i .. ".Quality.open")] ))
		end

	end
	local selectAcupointIndex  = self.selectAcupointIndex;
    if self.selectAcupointIndex then

	else
		selectAcupointIndex = 1;
		local maxLevel = CardRoleManager:getTrainMaxLevel(self.cardRole.gmId);
		for i=1,#trainNames do
			local acupointInfo = self.cardRole:GetAcupointInfo(i)
			if acupointInfo and acupointInfo.level < maxLevel then
				 selectAcupointIndex = i;
	    		break;
			end
    	end
	end

	self:showAcupointView(selectAcupointIndex);


	self.isAllToMaxLevel = isAllToMaxLevel;
	if isAllToMaxLevel then
		self.btn_through:setShaderProgramDefault(true)
		self.haveLongTouch = false;
		self.isUping = false;
		self.isUplevlTouch = false;
	else
		self.btn_through:setShaderProgram("GrayShader", true)
	end

	if self.cardRole.quality == QUALITY_JIA then
		self.btn_through:setVisible(false);
	end
end

function RoleTrainLayer:registerEvents(ui)
	self.super.registerEvents(self);
    -- ADD_ALERT_CLOSE_LISTENER(self,self.btn_close);
    -- self.btn_close:setClickAreaLength(100);
    self.btn_through.logic     = self;
    self.btn_uplevl.logic     = self;
    self.btn_jump.logic     = self;

	self.btn_through:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onThroughClickHandle),1);
	self.btn_uplevl:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onUplevlClickHandle),1);
    self.btn_uplevl:addMEListener(TFWIDGET_TOUCHBEGAN, self.onUplevlTouchBeganHandle);
    self.btn_uplevl:addMEListener(TFWIDGET_TOUCHMOVED, self.onUplevlTouchMovedHandle);
    self.btn_uplevl:addMEListener(TFWIDGET_TOUCHENDED, self.onUplevlTouchEndedHandle);

	self.btn_jump:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onJumpClickHandle),1);

	for i=1,#trainNames do
		self.img_acupointArr[i]:setTag(i);
        self.img_acupointArr[i].logic = self;
		self.img_acupointArr[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onAcupointClickHandle,play_xuanze));

		self.btn_pointArr[i]:setTag(i);
        self.btn_pointArr[i].logic = self;
		self.btn_pointArr[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onAcupointClickHandle,play_xuanze));

		self.btn_suoArr[i]:setTag(i);
        self.btn_suoArr[i].logic = self;
		self.btn_suoArr[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onAcupointClickHandle,play_xuanze));
	end

    self.RoleAcupointUpdate = function(event)
        self:refreshUI()
    end
    TFDirector:addMEGlobalListener(CardRoleManager.UPDATE_ROLE_TRAIN_INFO,  self.RoleAcupointUpdate)
    TFDirector:addMEGlobalListener(CardRoleManager.UPDATE_ALL_ROLE_TRAIN_INFO,  self.RoleAcupointUpdate)

    self.onRoleBreakResult = function(event)
	    for i=1,#trainNames do
			self.btn_pointArr[i]:setVisible(false)
			self.btn_suoArr[i]:setVisible(false)
			self.bar_levelArr[i]:setVisible(false)
			
			self.img_xuanzhongArr[i]:setVisible(false)
			-- self.img_mingchengArr[i]:setVisible(false)
		end

        local resPath = "effect/role_train.xml"
        TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        local effect = TFArmature:create("role_train_anim")

        effect:setAnimationFps(GameConfig.ANIM_FPS)

        effect:setPosition(ccp(483.5,305))
        self.panel_content:addChild(effect,2)

        effect:addMEListener(TFARMATURE_COMPLETE,function()
            effect:removeMEListener(TFARMATURE_COMPLETE) 
            effect:removeFromParent()

	        for i=1,#trainNames do
				self.btn_pointArr[i]:setVisible(true)
				self.btn_suoArr[i]:setVisible(true)
				self.bar_levelArr[i]:setVisible(true)
				
				self.img_xuanzhongArr[i]:setVisible(true)
				self.img_mingchengArr[i]:setVisible(true)
			end

            -- self:refreshUI();
        end)

        if self.oldQuality == QUALITY_DING then
       	 	effect:playByIndex(3, -1, -1, 0)
        end
        if self.oldQuality == QUALITY_BING then
        	effect:playByIndex(4, -1, -1, 0)
        end
        if self.oldQuality == QUALITY_YI then
        	effect:playByIndex(5, -1, -1, 0)
        end

 		self.breakTimeId = TFDirector:addTimer(500 + self.oldQuality * 700, 1, nil, function()
			CardRoleManager:openRoleBreakResultLayer( self.cardRole.gmId );
        end);

       	self:showAcupointView(1);
    end

    TFDirector:addMEGlobalListener(CardRoleManager.ROLE_BREAKTHROUGH_RESULT,  self.onRoleBreakResult);

    self.updateUserDataCallBack = function(event)
        self:refreshBaseUI();
    end;
    TFDirector:addMEGlobalListener(MainPlayer.CoinChange ,self.updateUserDataCallBack ) ;
    TFDirector:addMEGlobalListener(MainPlayer.SyceeChange ,self.updateUserDataCallBack ) ;
    TFDirector:addMEGlobalListener(MainPlayer.GenuineQiChange ,self.updateUserDataCallBack ) ;

    self.upLevelResultCallBack = function(event)
    	local acupointIndex = self.selectAcupointIndex;
    	local effect = self.bar_levelArr[acupointIndex].effect;
    	if not effect or not effect:getParent() then
	        local resPath = "effect/role_train.xml"
	        TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
	        effect = TFArmature:create("role_train_anim")

	        effect:setAnimationFps(GameConfig.ANIM_FPS)

	        -- effect:setPosition(ccp(btn_point:getSize().width/2,btn_point:getSize().height/2))
	        self.bar_levelArr[acupointIndex]:addChild(effect,2)
	        self.bar_levelArr[acupointIndex].effect = effect;

	        effect:addMEListener(TFARMATURE_COMPLETE,function()
	            effect:removeMEListener(TFARMATURE_COMPLETE) 
	            effect:removeFromParent()
	            self.bar_levelArr[acupointIndex].effect = nil;
	        end)
        end
        effect:playByIndex((math.random() * 10) % 3, -1, -1, 0)

 		self.levelupTimeId = TFDirector:addTimer(10, 1, nil, function()
	    	local acupointInfo = event.data[1].acupointInfo;
			local level = acupointInfo.level;
			local attributeStr = "";

		    local table_arr = GetAttrByString(acupointInfo.buffStr);
		    for attribute,num in pairs(table_arr) do
				attributeStr = AttributeTypeStr[attribute] .. "+" .. (num - self.acupointInfoAttributeNum[level - 1]);
		        break;
		    end
		    self.isUping = false;
		    --toastMessage("升级至" .. level .. "级，" .. attributeStr);
		    toastMessage(stringUtils.format(localizable.roleTrain_text2,level,attributeStr));

	 		self.levelupLongTimeId = TFDirector:addTimer(200, 1, nil, function()
			    if self.isUplevlTouch then
			    	self:uplevl();
			    end
	        end);

        end);
     


		local maxLevel = CardRoleManager:getTrainMaxLevel(self.cardRole.gmId);
		local acupointInfo = self.cardRole:GetAcupointInfo(acupointIndex)

		if acupointInfo.level < maxLevel then

		else
			local selectAcupointIndex = 1;
			for i=1,#trainNames do
				local acupointInfo = self.cardRole:GetAcupointInfo(i)
				if acupointInfo and acupointInfo.level < maxLevel then
					selectAcupointIndex = i;
					break;
				end
			end
			self:showAcupointView(selectAcupointIndex);
		end

    end;
    TFDirector:addMEGlobalListener(CardRoleManager.UPLEVEL_ACUPOINT_MSG_RESULT,self.upLevelResultCallBack);


    if self.generalHead then
        self.generalHead:registerEvents()
    end
end

function RoleTrainLayer:removeEvents()
    self.super.removeEvents(self);

    TFDirector:removeMEGlobalListener(MainPlayer.CoinChange ,self.updateUserDataCallBack);
    TFDirector:removeMEGlobalListener(MainPlayer.SyceeChange ,self.updateUserDataCallBack);
    TFDirector:removeMEGlobalListener(MainPlayer.GenuineQiChange ,self.updateUserDataCallBack);

    TFDirector:removeMEGlobalListener(CardRoleManager.UPLEVEL_ACUPOINT_MSG_RESULT ,self.upLevelResultCallBack);
    TFDirector:removeMEGlobalListener(CardRoleManager.ROLE_BREAKTHROUGH_RESULT,  self.onRoleBreakResult);
    
    TFDirector:removeMEGlobalListener(CardRoleManager.UPDATE_ROLE_TRAIN_INFO, self.RoleAcupointUpdate)
    TFDirector:removeMEGlobalListener(CardRoleManager.UPDATE_ALL_ROLE_TRAIN_INFO, self.RoleAcupointUpdate)

    TFDirector:removeTimer(self.levelupTimeId);
    self.levelupTimeId = nil;

    TFDirector:removeTimer(self.levelupLongTimeId);
    self.levelupLongTimeId = nil;

    TFDirector:removeTimer(self.breakTimeId);
    self.breakTimeId = nil;

    if self.generalHead then
        self.generalHead:removeEvents()
    end
end

function RoleTrainLayer.onThroughClickHandle(sender)
	local self = sender.logic;
	self.isUping = false;
	if self.isAllToMaxLevel then
		self.oldQuality =  self.cardRole.quality
		self.oldPower = self.cardRole.power
	    CardRoleManager:roleBreakthrough(self.cardRole.gmId);
   	else
   		--toastMessage("所有经脉满级时方可进行突破");
   		toastMessage(localizable.roleTrain_text3)
   	end
end

function RoleTrainLayer:uplevl()
	if self.isUping then
		return;
	end

	local acupointInfo = self.cardRole:GetAcupointInfo(self.selectAcupointIndex)

	if not MainPlayer:isEnoughGenuineQi( self:getNeed(acupointInfo) , true) then
		return;
	end


	self.acupointInfoAttributeNum = self.acupointInfoAttributeNum or {}

    local table_arr = GetAttrByString(acupointInfo.buffStr);
    for attribute,num in pairs(table_arr) do
		self.acupointInfoAttributeNum[acupointInfo.level] = num;
        break;
    end
    self.isUping = true;
    CardRoleManager:upLevelAcupont(self.cardRole.gmId,self.selectAcupointIndex);
end

function RoleTrainLayer.onUplevlClickHandle(sender)
	local self = sender.logic;
	if not self.haveLongTouch then
		self:uplevl();
	end
end

function RoleTrainLayer.onUplevlTouchBeganHandle(sender)
    local self = sender.logic;
 	self.haveLongTouch = false;
    local function onLongTouch()
	    self.isUplevlTouch = true;
	    self.haveLongTouch = true;

    	TFDirector:removeTimer(self.longTouchTimerId);
	    self:uplevl();
    end

    self.longTouchTimerId = TFDirector:addTimer(300, 1, nil, onLongTouch); 
end

function RoleTrainLayer.onUplevlTouchMovedHandle(sender)
    local self = sender.logic;
    -- TFDirector:removeTimer(self.longTouchTimerId);
    -- self.isUplevlTouch = false;
end

function RoleTrainLayer.onUplevlTouchEndedHandle(sender)
    local self = sender.logic;
    TFDirector:removeTimer(self.longTouchTimerId);
    self.isUplevlTouch = false;
end

function RoleTrainLayer.onJumpClickHandle(sender)
	local self = sender.logic;
	AlertManager:closeAll();

	ActivityManager:showLayer(ActivityManager.TAP_Arena);
end

function RoleTrainLayer.onAcupointClickHandle(sender)
	local self = sender.logic;
	local index = sender:getTag();

	local acupointInfo = self.cardRole:GetAcupointInfo(index);
	if acupointInfo == nil then
		--toastMessage("突破到" .. QUALITY_STR[ConstantData:getValue("Pulse.Position" .. index .. ".Quality.open")] .. "品后开放!")
		toastMessage(stringUtils.format(localizable.roleTrain_text1 ,QUALITY_STR[ConstantData:getValue("Pulse.Position" .. i .. ".Quality.open")] ))
			
		return;
	end
	
	if index == self.selectAcupointIndex then
		return;
	end

    self:showAcupointView(index);
end

function RoleTrainLayer:showAcupointView(index)

	if self.selectAcupointIndex ~= nil then
		local prevAcupoint = self.cardRole:GetAcupointInfo(self.selectAcupointIndex)
		if prevAcupoint then
			self.btn_pointArr[self.selectAcupointIndex]:setBright(true);
			self.img_xuanzhongArr[self.selectAcupointIndex]:setVisible(false);
			self.img_xian1Arr[self.selectAcupointIndex]:setVisible(false);
			self.img_xian2Arr[self.selectAcupointIndex]:setVisible(false);
		end
	end

	local acupointInfo = self.cardRole:GetAcupointInfo(index)
	if acupointInfo then
		self.btn_pointArr[index]:setBright(true);
		self.img_xuanzhongArr[index]:setVisible(true);
		self.img_xian1Arr[index]:setVisible(true);
		self.img_xian2Arr[index]:setVisible(true);
	end

	self.selectAcupointIndex = index
	self:updateSelectAcupoint()
end

function RoleTrainLayer:updateSelectAcupoint()
	local acupointInfo = self.cardRole:GetAcupointInfo(self.selectAcupointIndex);


	--已开放
	if acupointInfo ~= nil then
		-- self.txt_acupointName:setText(trainNames[self.selectAcupointIndex]);
		self.img_acupointIcon:setVisible(true);
		self.img_acupointIcon:setTexture("ui_new/rolerisingstar/" ..trainImgs[self.selectAcupointIndex] );


		self.panel_arr:setVisible(true);

		local maxLevel = CardRoleManager:getTrainMaxLevel(self.cardRole.gmId);
		self.txt_acupoint_level:setText(acupointInfo.level .. "/" .. maxLevel);
    	self.bar_acupoint_level:setPercent((acupointInfo.level/maxLevel)*100);

		if acupointInfo.level < maxLevel then
    		self.btn_uplevl:setVisible(true);
    		self.lb_max:setVisible(false);
    		self.txt_acupoint_xiahunNeed:setVisible(true);
    		self.txt_xiaohao1:setVisible(true);
    		self.img_point:setVisible(true);
    		
    	else
    		self.btn_uplevl:setVisible(false);
    		self.lb_max:setVisible(true);
    		self.txt_acupoint_xiahunNeed:setVisible(false);
    		self.txt_xiaohao1:setVisible(false);
    		self.img_point:setVisible(false);
    	end
    	self.txt_acupoint_growupvalue:setText(CardRoleManager:getTrainGrowupvalue(self.cardRole.gmId,self.selectAcupointIndex));

	    local table_arr = GetAttrByString(acupointInfo.buffStr);
	    for attribute,num in pairs(table_arr) do
			self.txt_acupoint_effectName:setText(AttributeTypeStr[attribute] .. "：" );
			self.txt_acupoint_effectValue:setText("+"..num);

	        break;
	    end

	    self.img_acupoint_quality:setTexture(GetFontByQuality(acupointInfo.quality));

		self.txt_acupoint_xiahunNeed:setText(self:getNeed(acupointInfo));


	else
		self.panel_arr:setVisible(false);

		-- self.txt_acupoint_openLevel:setText(ConstantData:getValue("Pulse.Position" .. self.selectAcupointIndex .. ".Level.open") .. "级开放！");
	end	
end

function RoleTrainLayer:getNeed(acupointInfo)
	local config = require("lua.table.t_s_role_pulse_level_rule");
	for v in config:iterator() do
		if v.level == acupointInfo.level and v.quality == acupointInfo.quality then
			return v.next_level_inspiration;
		end
	end
end

return RoleTrainLayer

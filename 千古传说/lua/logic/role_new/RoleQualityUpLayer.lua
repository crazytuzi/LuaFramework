
local RoleQualityUpLayer = class("RoleQualityUpLayer", BaseLayer)

function RoleQualityUpLayer:ctor(data)

	self.super.ctor(self, data)
	self.cardRole = CardRoleManager:getRoleById(MainPlayer.profession)
	self.isItemFull = true
	self:init("lua.uiconfig_mango_new.climb.QimenShengpin")

end

function RoleQualityUpLayer:initUI( ui )

	self.super.initUI(self, ui)

	self.btn_starup = TFDirector:getChildByPath(ui,"Btn_starup")
	self.btn_starup.logic = self
	self.btn_return = TFDirector:getChildByPath(ui, "btn_return")
	self.btn_return.logic = self

	self.star = {}
	for i=1,5 do
		self.star[i] = TFDirector:getChildByPath(ui, "img_star_light_"..i)
		self.star[i]:setVisible(false)
	end
	self.heroPanel = TFDirector:getChildByPath(ui,"panel_list")

	--detail
	self.img_attr = {}
	for i=1,5 do
		self.img_attr[i] = TFDirector:getChildByPath(ui,"img_attr"..i)
		self.img_attr[i].txt_curr = TFDirector:getChildByPath(self.img_attr[i],"txt_base")
		self.img_attr[i].txt_next = TFDirector:getChildByPath(self.img_attr[i],"txt_new")
		self.img_attr[i].Img_to = TFDirector:getChildByPath(self.img_attr[i],"Img_to")
	end

	self.icon_panel = {}
	for i=1,3 do
		self.icon_panel[i] = TFDirector:getChildByPath(ui,"icon_panel"..i)
	end


	self.panel_info = {}
	self.panel_info[1] = TFDirector:getChildByPath(ui,"panel_info1")
	self.panel_info[2] = TFDirector:getChildByPath(ui,"panel_info2")

	self.conditions = {}
	self.conditions[1] = {}
	self.conditions[2] = {}
	self.conditions[1].des =TFDirector:getChildByPath(ui,"txt_tiaojian1")
	self.conditions[2].des =TFDirector:getChildByPath(ui,"txt_tiaojian2")
	self.conditions[1].num =TFDirector:getChildByPath(ui,"txt_tiaojian3")
	self.conditions[2].num =TFDirector:getChildByPath(ui,"txt_tiaojian4")

end

function RoleQualityUpLayer:removeUI()
	self.super.removeUI(self)
end


function RoleQualityUpLayer:onShow()
	self:refreshUI()
end

function RoleQualityUpLayer:refreshUI()
	self:onShowLeftInfo()
	self:onShowRightInfo()
end

function RoleQualityUpLayer:registerEvents()
	self.super.registerEvents(self)

	self.btn_starup:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onQualityUpClickHandle),1)
	ADD_ALERT_CLOSE_LISTENER(self, self.btn_return);

    self.RoleStarUpResultCallBack = function (event)
        self:onUpStarUpCompelete()
    end
    TFDirector:addMEGlobalListener(CardRoleManager.ROLE_BREAKTHROUGH_RESULT,self.RoleStarUpResultCallBack)


end

function RoleQualityUpLayer:removeEvents()
  	self.btn_starup:removeMEListener(TFWIDGET_CLICK)

    TFDirector:removeMEGlobalListener(CardRoleManager.ROLE_BREAKTHROUGH_RESULT,self.RoleStarUpResultCallBack)
    self.RoleStarUpResultCallBack = nil
    self.super.removeEvents(self)
end

function RoleQualityUpLayer.onQualityUpClickHandle( sender )
	local self = sender.logic
	-- self:onUpStarUpCompelete()
	if self.isItemFull == false then
		--toastMessage("升品所需道具不足")
		toastMessage(localizable.roleQualityUp_notenough)
		return
	end

    self.oldarr = {}
    --角色属性
    for i=1,EnumAttributeType.Max do
        self.oldarr[i] = self.cardRole:getTotalAttribute(i)
    end

    -- self.old_quality = self.cardRole.quality
    -- self.old_starlevel = self.cardRole.starlevel
    -- self.old_power = self.cardRole.power

    CardRoleManager:roleBreakthrough( self.cardRole.gmId  )
    -- AlertManager:close()
end


function RoleQualityUpLayer:onShowLeftInfo()
	for i=1,5 do
		self.star[i]:setVisible(false)
	end
	for i=1,self.cardRole.starlevel do
		local starIdx = i
		local starTextrue = 'ui_new/common/xl_dadian22_icon.png'
		if i > 5 then
			starTextrue = 'ui_new/common/xl_dadian23_icon.png'
			starIdx = i - 5
		end
		self.star[starIdx]:setTexture(starTextrue)
		self.star[starIdx]:setVisible(true)
	end

	if self.heroPanel.img then self.heroPanel.img:removeFromParent() end
	self.heroPanel.img = Public:addModel(self.cardRole.image, self.heroPanel, 180, 80, "stand", 1)

	-- if self.heroPanel.img then
	-- 	self.heroPanel.img:setTexture(self.cardRole:getBigImagePath())
	-- else
	-- 	local img_role = TFImage:create(self.cardRole:getBigImagePath())
	-- 	img_role:setScale(0.65)
	-- 	img_role:setFlipX(true)
	-- 	img_role:setAnchorPoint(ccp(0.5,0.5))
	-- 	img_role:setPosition(ccp(320/2,500/2))
	-- 	self.heroPanel.img = img_role
	-- 	self.heroPanel:addChild(img_role)
	-- end
end

function RoleQualityUpLayer:onShowRightInfo()

	local trainItem_curr = RoleTrainData:getRoleTrainByQuality(self.cardRole.quality, self.cardRole.starlevel)
    local newCardRoleData = RoleData:objectByID(self.cardRole.id)
    local level_up        = newCardRoleData:GetAttrLevelUp()

    local trainItem_next = RoleTrainData:getRoleTrainByQuality(self.cardRole.quality+1, self.cardRole.starlevel)
	for i=1,5 do
		local currStar = trainItem_curr.streng_then * level_up[i]
		local nextStar = trainItem_next.streng_then * level_up[i]
		self.img_attr[i].txt_curr:setText(currStar)
		self.img_attr[i].txt_next:setText(nextStar)
    end

    for i=1,2 do
		local img_quality = TFDirector:getChildByPath(self.panel_info[i],"img_quality")
		img_quality:setTexture(GetColorIconByQuality(self.cardRole.quality+i-1))
		local img_icon = TFDirector:getChildByPath(self.panel_info[i],"img_icon")
		img_icon:setTexture(self.cardRole:getIconPath());
		local img_zhiye = TFDirector:getChildByPath(self.panel_info[i],"img_zhiye")
		img_zhiye:setTexture("ui_new/fight/zhiye_".. self.cardRole.outline ..".png");
		local img_martialLevel = TFDirector:getChildByPath(self.panel_info[i],"img_martialLevel")
		img_martialLevel:setTexture(GetFightRoleIconByWuXueLevel(self.cardRole.martialLevel))
		local txt_lv = TFDirector:getChildByPath(self.panel_info[i],"txt_lv")
		txt_lv:setText(self.cardRole.level)
		local txt_name = TFDirector:getChildByPath(self.panel_info[i],"txt_name")
		txt_name:setText(self.cardRole.name)
    end

    local config = QualityDevelopConfig:objectByID(self.cardRole.id)

    local qimen_table = numberToChineseTable(config.qimen)
    local qimen_str = ""
    for i=1,#qimen_table do
    	qimen_str = qimen_str .. qimen_table[i]
    end
	--self.conditions[1].des:setText("突破奇门遁"..qimen_str.."重")
	self.conditions[1].des:setText(stringUtils.format(localizable.roleQualityUp_tupo1,qimen_str))

	local star_level_table = numberToChineseTable(config.star_level)
    local star_level_str = ""
    for i=1,#star_level_table do
    	star_level_str = star_level_str .. star_level_table[i]
    end
	--self.conditions[2].des:setText("主角突破至"..star_level_str.."星")
	self.conditions[2].des:setText(stringUtils.format(localizable.roleQualityUp_tupo2, star_level_str))

	local info = CardRoleManager:getQimenInfo() or {}
    local currLevel = info.level or 0
    -- currLevel = currLevel + 1

    local txt_num_widget = TFDirector:getChildByPath(self.ui,"txt_tiaojian3_num")
	self.conditions[1].num:setText("/"..config.qimen..")")
	txt_num_widget:setText(currLevel)
	if currLevel >= config.qimen  then
		txt_num_widget:setColor(ccc3(0,0,0))
	else
		txt_num_widget:setColor(ccc3(255,0,4))
	end

    txt_num_widget = TFDirector:getChildByPath(self.ui,"txt_tiaojian4_num")
	self.conditions[2].num:setText("/"..config.star_level..")")
	txt_num_widget:setText(self.cardRole.starlevel)
	if self.cardRole.starlevel >= config.star_level  then
		txt_num_widget:setColor(ccc3(0,0,0))
	else
		txt_num_widget:setColor(ccc3(255,0,4))
	end
	if currLevel >= config.qimen and self.cardRole.starlevel >= config.star_level then
		self.btn_starup:setGrayEnabled(false)
		self.btn_starup:setTouchEnabled(true)
	else
		self.btn_starup:setGrayEnabled(true)
		self.btn_starup:setTouchEnabled(false)
	end

	self.isItemFull = true

	local cost_material = GetAttrByString(config.items)
	local index = 1
	for k,v in pairs(cost_material) do
		if self.icon_panel[index].icon == nil then
			local icon = require('lua.logic.role_new.RoleStarUpPreviewNumCell'):new()
			icon:setScale(0.85)
			self.icon_panel[index]:addChild(icon)
			self.icon_panel[index].icon = icon
		end
		self.icon_panel[index].icon:setVisible(true)
		local curr_num = BagManager:getItemNumById( k )
		self.icon_panel[index].icon:setData(k,curr_num,v)
		if curr_num < v then
			self.isItemFull = false
		end
		index = index + 1
	end
	for i=index,3 do
		if self.icon_panel[index].icon then
			self.icon_panel[index].icon:setVisible(false)
		end
	end

end


function RoleQualityUpLayer:onUpStarUpCompelete()
	AlertManager:close()
    local layer =  AlertManager:addLayerByFile("lua.logic.role_new.QualityUpResultLayer", AlertManager.BLOCK_AND_GRAY_CLOSE)
    -- layer:loadData(self.cardRole.gmId,self.oldarr,self.old_power)
    layer:playEffect(self.cardRole)
    AlertManager:show()
end

return RoleQualityUpLayer
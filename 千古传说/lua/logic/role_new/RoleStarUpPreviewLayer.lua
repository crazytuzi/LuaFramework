
local RoleStarUpPreviewLayer = class("RoleStarUpPreviewLayer", BaseLayer)

function RoleStarUpPreviewLayer:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.role_new.RoleStarUpPreview")

end

function RoleStarUpPreviewLayer:initUI( ui )

	self.super.initUI(self, ui)

	self.Btn_tupo = TFDirector:getChildByPath(ui,"Btn_tupo")
	self.Btn_tupo.logic = self
	self.btn_close = TFDirector:getChildByPath(ui, "btn_close")
	self.btn_close.logic = self

	self.txt_suoxu = TFDirector:getChildByPath(ui,'txt_suoxu')

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

	self.icon_panel = TFDirector:getChildByPath(ui,"icon_panel")

	self.txt_levelLimit = TFDirector:getChildByPath(ui,"txt_levelLimit")

	--创建TabView
	self.right_panel = TFDirector:getChildByPath(ui,"bg_tupo")
    self.TabViewUI = TFDirector:getChildByPath(self.right_panel, "panel_list")
    self.TabView =  TFTableView:create()
    self.TabView:setTableViewSize(self.TabViewUI:getContentSize())
    self.TabView:setDirection(TFTableView.TFSCROLLVERTICAL)    
    self.TabView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    self.TabView.logic = self
    self.TabViewUI:getParent():addChild(self.TabView)
    self.TabView:setPosition(self.TabViewUI:getPosition())
    self.TabViewUI_size = self.TabViewUI:getContentSize()

    self.iconBuff = {}
end

function RoleStarUpPreviewLayer:removeUI()
	
	self.super.removeUI(self)

end

function RoleStarUpPreviewLayer:dispose()

end

function RoleStarUpPreviewLayer:onShow()
	self:refreshUI()
	if self.firstShow == true then
    	self.ui:runAnimation("Action0",1);
    	self.firstShow = false
    end

    if self.TabView then
    	local offset_position = {}--= {6,6,5,4,3,2,1,0,0}
    	for i=1,self.cardRole.maxStar do
    		if i == 1 or i == 2 then
    			offset_position[i] = self.cardRole.maxStar - 2
    		else
    			offset_position[i] = self.cardRole.maxStar - i
    		end    		
    	end
    	offset_position[self.cardRole.maxStar + 1] = 0
    	local offset = offset_position[self.cardRole.starlevel+1]

    	self.TabView:setContentOffset(ccp(0,-(118*offset)))
    end
end

function RoleStarUpPreviewLayer:refreshUI()

	if self.roleGoodsList == nil then
		self.roleGoodsList = TFArray:new()
	else
		self.roleGoodsList:clear()
	end
	if self.cardRole.starlevel < self.cardRole.maxStar then
		local RoleStarLevelInfo = self.roleInfoList:getObjectAt(self.cardRole.starlevel+1)
		local item = {}
		item.id = self.cardRole.soul_card_id
		item.num = RoleStarLevelInfo.soul_num
		self.roleGoodsList:push(item)
		if #RoleStarLevelInfo.other_goods_id > 0 then
			local activity	= string.split(RoleStarLevelInfo.other_goods_id,'_')
			local itemGood = {}
			itemGood.id	 = tonumber(activity[1])
			itemGood.num = tonumber(activity[2])
			self.roleGoodsList:push(itemGood)
		end

		self.levelLimit = RoleStarLevelInfo.role_level or 0
		--self.txt_levelLimit:setText("需求等级:"..self.levelLimit)
		self.txt_levelLimit:setText(stringUtils.format(localizable.roleStartupPre_needlevel,self.levelLimit))
	end



	self:onShowLeftInfo()
	self:onShowRightInfo()

	if self.TabView then
		self.TabView:reloadData()
		self.TabView:setScrollToBegin()
	end
end

function RoleStarUpPreviewLayer:registerEvents()
	self.super.registerEvents(self)

	self.Btn_tupo:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onTupoClickHandle),1)
	self.btn_close:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCloseClickHandle),1)

	--注册TabView事件
    self.TabView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    self.TabView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    self.TabView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)

    self.RoleStarUpResultCallBack = function (event)
        self:onUpStarUpCompelete()
    end
    TFDirector:addMEGlobalListener(CardRoleManager.ROLE_PRACTICE_RESULT,self.RoleStarUpResultCallBack)


end

function RoleStarUpPreviewLayer:removeEvents()
    self.super.removeEvents(self)
  	self.Btn_tupo:removeMEListener(TFWIDGET_CLICK)
	self.btn_close:removeMEListener(TFWIDGET_CLICK)

	self.TabView:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)

    TFDirector:removeMEGlobalListener(CardRoleManager.ROLE_PRACTICE_RESULT,self.RoleStarUpResultCallBack)
    self.RoleStarUpResultCallBack = nil
end

function RoleStarUpPreviewLayer:SetData(gmId)
	self.gmId = gmId
	self.firstShow = true
	self.bShowTuPu = nil

	local cardRole = CardRoleManager:getRoleByGmid( self.gmId )
	self.cardRole = clone(cardRole)
	self.roleInfoList = RoleTalentData:GetRoleStarInfoByRoleId( self.cardRole.id )

	self.Btn_tupo:setVisible(true)
	self.txt_suoxu:setVisible(true)
	self.txt_levelLimit:setVisible(true)
	self.icon_panel:setVisible(true)
end

function RoleStarUpPreviewLayer:setDataInTupu(cardRole)
	self.bShowTuPu = true
	self.firstShow = true

	self.cardRole = cardRole
	self.roleInfoList = RoleTalentData:GetRoleStarInfoByRoleId( self.cardRole.id )

	self.Btn_tupo:setVisible(false)
	self.txt_suoxu:setVisible(false)
	self.txt_levelLimit:setVisible(false)
	self.icon_panel:setVisible(false)
end

function RoleStarUpPreviewLayer.onTupoClickHandle( sender )
	
	local self = sender.logic
	
    if self.cardRole:getHaveSoulNum() < self.cardRole:getUpstarNeedSoulNum() then

        if self.cardRole:getIsMainPlayer() then
            --self:gotoEmploy()
            --toastMessage("请前往摩诃崖获取更多的主角侠魂")
            toastMessage(localizable.roleInfoLayer_py_goto)
        else
            --CommonManager:showNeedRoleComfirmLayer()
            local layer = AlertManager:addLayerByFile("lua.logic.common.NoticeLayer",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1);
		    --layer:setTitle("侠魂不足")
		    layer:setTitle(localizable.roleStartupPre_xiahun)
		    --[[
		    local Msg = {
		    	"1.可使用侠义值在酒馆侠魂商店中兑换",
		    	"2.可在商店中购买",
		    	"3.可在群豪谱处使用积分兑换",
		    	"4.可在宗师关卡中获得",
		    	"5.可在雁门关、摩诃崖获得侠魂"
			}
			]]
			local Msg = localizable.roleStartupPre_msg
			layer:setMsg(Msg);
			layer:setBtnHandle(function ()			    
		    end,function ()
		    end);
		    AlertManager:show();
        end
        return
    end

    if self.cardRole.level < self.levelLimit then   
        CommonManager:showOperateSureLayer(
            function()                
            end,
            function()
                AlertManager:close()
            end,
            {
            --title = "提示" ,
            --msg = "侠客等级不足",
            title = localizable.common_tips ,
            msg = localizable.roleStartupPre_player,
            uiconfig = "lua.uiconfig_mango_new.common.OperateSure1"
            }
        )
	    return
    end
    local goodsItem = self.roleGoodsList:getObjectAt(2)
    if goodsItem then
	    local itemNumInBag = BagManager:getItemNumById( goodsItem.id )
	    if itemNumInBag < goodsItem.num then
			CommonManager:showOperateSureLayer(
	            function()                
	            end,
	            function()
	                AlertManager:close()
	            end,
	            {
	            --title = "提示" ,
	            title = localizable.common_tips ,
	           -- msg = "突破道具不足",
	            msg = localizable.roleStartupPre_pro,
	            uiconfig = "lua.uiconfig_mango_new.common.OperateSure1"
	            }
	        )	
		    return    	
	    end
	end


    self.oldarr = {}
    --角色属性
    for i=1,EnumAttributeType.Max do
        self.oldarr[i] = self.cardRole:getTotalAttribute(i)
    end

    self.old_quality = self.cardRole.quality
    self.old_starlevel = self.cardRole.starlevel
    self.old_power = self.cardRole.power

    CardRoleManager:roleStarUp( self.cardRole.gmId  )
    -- local layer =  AlertManager:addLayerByFile("lua.logic.role_new.RoleStarUpResultNewLayer", AlertManager.BLOCK_AND_GRAY)
    -- layer:loadData(self.cardRole.gmId,self.oldarr,self.old_power)
    -- layer:setOldValue(self.old_quality, self.old_starlevel)
    -- AlertManager:show()
end

function RoleStarUpPreviewLayer.onCloseClickHandle( sender )
	AlertManager:close(AlertManager.TWEEN_NONE)
end

function RoleStarUpPreviewLayer:onShowLeftInfo()
	if self.cardRole == nil then
		print("cannot find the role card by gmId",self.gmId)
		return;
	end
	-- for i=1,5 do
	-- 	if i <= self.cardRole.starlevel then
	-- 		self.star[i]:setVisible(true)
	-- 	else
	-- 		self.star[i]:setVisible(false)
	-- 	end
	-- end	
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

	self.heroPanel:removeAllChildren()

	local armatureID = self.cardRole.image
    ModelManager:addResourceFromFile(1, armatureID, 1)
    local model = ModelManager:createResource(1, armatureID)
    model:setPosition(ccp(self.heroPanel:getSize().width / 2, 50))
    -- model:setScale(0.9)
    ModelManager:playWithNameAndIndex(model, "stand", -1, 1, -1, -1)
    self.heroPanel:addChild(model)
    -- self.heroPanel.img = model
end

function RoleStarUpPreviewLayer:onShowRightInfo()

	local trainItem_curr = RoleTrainData:getRoleTrainByQuality(self.cardRole.quality, self.cardRole.starlevel)
    local newCardRoleData = RoleData:objectByID(self.cardRole.id)
    local level_up        = newCardRoleData:GetAttrLevelUp()

    for k,v in pairs(self.iconBuff) do
    	v:removeFromParent()
    end
    self.iconBuff = {}

	if self.cardRole.starlevel >= self.cardRole.maxStar then
		--达到5星最大值
		for i=1,5 do
			local currStar = trainItem_curr.streng_then * level_up[i]	   
			self.img_attr[i].txt_curr:setText(currStar)
			self.img_attr[i].txt_next:setVisible(false)
			self.img_attr[i].Img_to:setVisible(false)
		end
		self.Btn_tupo:setGrayEnabled(true)
		self.Btn_tupo:setTouchEnabled(false)
		self.txt_levelLimit:setVisible(false)
		return;
	else
		for i=1,5 do
			self.img_attr[i].txt_next:setVisible(true)
			self.img_attr[i].Img_to:setVisible(true)
		end
		self.Btn_tupo:setGrayEnabled(false)
		self.Btn_tupo:setTouchEnabled(true)
		self.txt_levelLimit:setVisible(true)
	end	

    local trainItem_next = RoleTrainData:getRoleTrainByQuality(self.cardRole.quality, self.cardRole.starlevel+1) 
	for i=1,5 do        
	    local currStar = trainItem_curr.streng_then * level_up[i]
	    local nextStar = trainItem_next.streng_then * level_up[i]
		self.img_attr[i].txt_curr:setText(currStar)
		self.img_attr[i].txt_next:setText(nextStar)
    end

    if self.bShowTuPu == nil then
	    for i=1,self.roleGoodsList:size() do
	    	local item = self.roleGoodsList:getObjectAt(i)
	    	print("self.roleGoodsList = ",self.roleGoodsList)
	    	local icon = require('lua.logic.role_new.RoleStarUpPreviewNumCell'):new()
	    	icon:setPosition(ccp((i-1)*(self.icon_panel:getContentSize().width + 10), 0))
	    	local curr_num = BagManager:getItemNumById( item.id )
	    	icon:setData(item.id,curr_num,item.num)
	    	self.icon_panel:addChild(icon)
	    	local index = #self.iconBuff
	    	self.iconBuff[index+1] = icon
	    end
	end
end

function RoleStarUpPreviewLayer.cellSizeForTable(table,idx)
    return 118,465
end

function RoleStarUpPreviewLayer.tableCellAtIndex(table, idx)

	local self = table.logic
	local cell = table:dequeueCell()

	if cell == nil then
		cell = TFTableViewCell:create()		
	    local panel = require('lua.logic.role_new.RoleStarUpPreviewCell'):new()        

	    local offset_x = self.TabViewUI:getContentSize().width-panel:getContentSize().width

		panel:setPosition(ccp(offset_x/2,0))
	    cell:addChild(panel)
    	cell.panel = panel
	end

	cell.panel:setData(self.cardRole,self.roleInfoList:getObjectAt(idx+1))
    return cell
end

function RoleStarUpPreviewLayer.numberOfCellsInTableView(table)	
	local self = table.logic
    return self.cardRole.maxStar
end

function RoleStarUpPreviewLayer:onUpStarUpCompelete()
    local layer =  AlertManager:addLayerByFile("lua.logic.role_new.RoleStarUpResultNewLayer", AlertManager.BLOCK_AND_GRAY)
    layer:loadData(self.cardRole.gmId,self.oldarr,self.old_power)
    layer:setOldValue(self.old_quality, self.old_starlevel)
    AlertManager:show()

    local cardRole = CardRoleManager:getRoleByGmid( self.gmId )
	self.cardRole = clone(cardRole)
end

return RoleStarUpPreviewLayer
--Date 2016-3-24
--yongkang
--装备传承主界面

local SmritiMain = class("SmritiMain",BaseLayer)

function SmritiMain:ctor(data)
	self.super.ctor(self, data)
	self.gmIds = {}
	self.gmIds[1] = 0
	self.gmIds[2] = 0							
	self:init("lua.uiconfig_mango_new.smithy.ZhuangBeiChuanCheng")	
end

function SmritiMain:initUI( ui )
	self.super.initUI(self,ui)
	self.generalHead = CommonManager:addGeneralHead(self)
    self.generalHead:setData(ModuleType.Smriti,{HeadResType.COIN,HeadResType.SYCEE})
    self.panel_content = TFDirector:getChildByPath(ui, 'panel_content')
    self.btn_smriti = TFDirector:getChildByPath(ui, 'btn_chuancheng')
    self.btn_bangzhu = TFDirector:getChildByPath(ui,'btn_bangzhu')

    self.panelTops = {}
    local leftPanel =  TFDirector:getChildByPath(ui, 'panel_xuanzhong')
    local rightPanel =  TFDirector:getChildByPath(ui, 'panel_wupin')
    table.insert(self.panelTops,leftPanel)
    table.insert(self.panelTops,rightPanel)

    for k,panel in pairs(self.panelTops) do
    	panel.quality_bg = TFDirector:getChildByPath(panel,'btn_icon')
    	panel.img_wupin = TFDirector:getChildByPath(panel,'img_wupin')
        panel.icon_add = TFDirector:getChildByPath(panel,'btn_wupin')
        panel.img_arrow = TFDirector:getChildByPath(panel,'img_arrow')
        panel.bg_wupin = TFDirector:getChildByPath(panel,'bg_wupin')
    end
    --未选中 选中
    self.img_bg_state ={"ui_new/Zhuzhan/bg_zhuzhan2.png","ui_new/Zhuzhan/bg_zhuzhan3.png"}
    self.img_bg_icon ={"ui_new/smithy/btn_wupin1.png","ui_new/smithy/btn_wupin2.png"}
    --属性面板
    self.panel_details ={}
    local panel_shuxing = TFDirector:getChildByPath(ui,'panel_shuxing')
    for i=1,2 do
    	local panel_details ={}
    	local detailsNode = TFDirector:getChildByPath(panel_shuxing,'panel_details' .. i)
    	panel_details.details_node = detailsNode
    	--基础属性
        panel_details.base_attr = {} 
    	panel_details.base_attr.txt_base = TFDirector:getChildByPath(detailsNode,'txt_attr_base')
    	panel_details.base_attr.txt_base_val = TFDirector:getChildByPath(detailsNode,'txt_attr_base_val')
    	--附加属性
        panel_details.attr_extra ={}
    	for i=1,4 do
    		local attr_extra = {}
    		attr_extra.txt_extra = TFDirector:getChildByPath(detailsNode,'txt_attr_extra_'..i)
    		attr_extra.txt_extra_val = TFDirector:getChildByPath(detailsNode,'txt_attr_extra_val_'..i)
    		attr_extra.txt_extra_val:setText("999"..i)
    		table.insert(panel_details.attr_extra,attr_extra)
    	end
    	--宝石
        panel_details.attr_gem ={}
    	for i=1,2 do
    	  	 local attr_gem ={}
    	  	 attr_gem.txt_gem = TFDirector:getChildByPath(detailsNode,'txt_attr_gem'..i)
    	  	 attr_gem.txt_gem_val = TFDirector:getChildByPath(detailsNode,'txt_attr_gem_val'..i)
    	  	 attr_gem.txt_gem_val:setText("666"..i)
    	  	 attr_gem.img_gem = TFDirector:getChildByPath(detailsNode,'img_gem'..i)
    	  	 table.insert(panel_details.attr_gem,attr_gem)
    	end  
    	--	 
        table.insert(self.panel_details,panel_details)
    end
    --other
    self.others = {}
    -- for i=1,5 do
    --    local img = TFDirector:getChildByPath(panel_shuxing,"img_"..i )
    --    table.insert(self.others,img)
    -- end
    local txt_needDesc = TFDirector:getChildByPath(panel_shuxing,"txt_wenben")
    table.insert(self.others,txt_needDesc)

    --战斗力显示
    self.panel_totals = {}
    for i=1,2 do  
      	local panel_totals ={}
    	local totalNode = TFDirector:getChildByPath(panel_shuxing,'panel_total' .. i)
    	panel_totals.total_node = totalNode
    	local txt_power_details = TFDirector:getChildByPath(totalNode,'txt_power_details')
    	panel_totals.txt_power_details = txt_power_details
    	table.insert(self.panel_totals,panel_totals)
    end

    --需要物品
    self.panle_needs ={}
    for i=1,2 do
    	local qualityNode = TFDirector:getChildByPath(panel_shuxing,'img_quality' .. i)
    	local img_icon = TFDirector:getChildByPath(qualityNode,'img_icon')
    	local txt_numb = TFDirector:getChildByPath(qualityNode,'txt_numb')  
    	table.insert(self.panle_needs,{need_node = qualityNode,img_icon = img_icon,txt_numb = txt_numb})
    end
    --设置为未选中
    for k,panel in pairs(self.panelTops) do        
        panel.img_arrow:setVisible(false)
        panel.bg_wupin:setTexture(self.img_bg_state[1])
        panel.icon_add:setTexture(self.img_bg_icon[1])       
    end


    self:refreshUI()
end

function SmritiMain:loadData(equipList)
    self.equipList = equipList
end


function SmritiMain.onBtnAdd(sender)
	local self = sender.logic
	local index = sender.index
	if index == 1 then --选择传承装备       
		if self.gmIds[1] ~= 0 then
            self.gmIds[1] = 0
            self:refreshUI()
        else    
            local layer = require("lua.logic.smithy.SmritiSelect"):new()
    		layer:setParent(self)
            layer:setGmId(self.gmIds[2])           
    	    AlertManager:addLayer(layer,AlertManager.BLOCK,AlertManager.TWEEN_NONE)
    	    AlertManager:show()

            local panel = self.panelTops[1]
            panel.img_arrow:setVisible(true)
            panel.bg_wupin:setTexture(self.img_bg_state[2])
            panel.icon_add:setTexture(self.img_bg_icon[2])
        end      
	elseif index == 2 then --选择接受传承的装备
        if self.gmIds[2] ~= 0 then
            self.gmIds[2] = 0 
            self:refreshUI()
        else    
    		local layer = require("lua.logic.smithy.SmritiAccept"):new()
    		layer:setParent(self)
    		layer:setGmId(self.gmIds[1])
    	    AlertManager:addLayer(layer,AlertManager.BLOCK,AlertManager.TWEEN_NONE)
    	    AlertManager:show()

            local panel = self.panelTops[2]
            panel.img_arrow:setVisible(true)
            panel.bg_wupin:setTexture(self.img_bg_state[2])
            panel.icon_add:setTexture(self.img_bg_icon[2])

        end
	else
		print("error")
	end
    --[[
    for k,panel in pairs(self.panelTops) do
        if k ~= index then
            panel.img_arrow:setVisible(false)
            panel.bg_wupin:setTexture(self.img_bg_state[1])
            panel.icon_add:setTexture(self.img_bg_icon[1])
        else
            panel.img_arrow:setVisible(true)
            panel.bg_wupin:setTexture(self.img_bg_state[2])
            panel.icon_add:setTexture(self.img_bg_icon[2])
        end
    end    
]]
end

function SmritiMain.onBtnPro(sender)    
    local self = sender.logic
    --local rewardItem = self.rewardItem
    local index = sender.index
    print(index.."-------index--------")
    print(self.items)
    if #self.items >= 2 then
        rewardItem = self.items[index]
        Public:ShowItemTipLayer(rewardItem.itemId, rewardItem.type);
    end
end

function SmritiMain.onBtnSmriti(sender)
    local self = sender.logic
    if self.gmIds[1] == 0  or self.gmIds[2] == 0 then 
        toastMessage(localizable.smritiMain_text1)
    else
        CommonManager:showOperateSureLayer(
        function()
            if self.checkItem then
                local bagItem = BagManager:getItemById(self.checkItem.itemId) or {}
                local number = bagItem.num or 0
                print('number = ',number)
                if number < self.checkItem.number then
                    if MallManager:checkShopOneKey( self.checkItem.itemId ) then
                        return
                    end
                end
            end
            EquipmentManager:EquipSmriti(self.gmIds[1],self.gmIds[2]) 
        end,
        function()
            AlertManager:close()
        end,
        {
            title = localizable.smritiMain_tips ,
            msg = localizable.smritiMain_ok,
        }
        )        
    end 
end

function SmritiMain.onBtnBangzhu()
    CommonManager:showRuleLyaer( 'zhuangbeizhihuan' )
end
--刷新图标区信息
function SmritiMain:refreshUI()
	for index,gmId in pairs(self.gmIds) do
		if gmId ~= 0 then			
			self.panel_details[index].details_node:setVisible(true)	
			self.panel_totals[index].total_node:setVisible(true)		 
			--self.panle_needs[index].need_node:setVisible(true)		 
		    self.panelTops[index].quality_bg:setVisible(true) 
		    local equip = EquipmentManager:getEquipByGmid(gmId)
		    if equip == nil  then
        	    print("equipment not found .",self.gmId)
        	    return
    	    end
    	
    	    --Icon
    	    local panel = self.panelTops[index]
    	    panel.quality_bg:setTexture(GetColorIconByQuality(equip.quality))
    	    panel.img_wupin:setTexture(equip:GetTextrue())
    	    EquipmentManager:BindEffectOnEquip(panel.quality_bg, equip)
    	
    	    --具体信息
	        --基础属性
	        local panel_details = self.panel_details[index]
	        local baseAttr = equip:getBaseAttributeWithRecast():getAttribute()
	        for i=1,(EnumAttributeType.Max-1) do
	            if baseAttr[i] then
	                panel_details.base_attr.txt_base:setText(AttributeTypeStr[i])
	                panel_details.base_attr.txt_base_val:setText("+ " .. covertToDisplayValue(i,baseAttr[i]))
	            end
	        end

	        --附加属性
	        local attr_extra = panel_details.attr_extra
	        local extraAttr,indexTable = equip:getExtraAttributeWithRecast():getAttribute()
	        local notEmptyIndex = 1
	        for k,i in pairs(indexTable) do
	            if extraAttr[i] then  
	                attr_extra[notEmptyIndex].txt_extra:setVisible(true)
	                attr_extra[notEmptyIndex].txt_extra_val:setVisible(true)
                   -- self.others[i + 1]:setVisible(true)

 				    attr_extra[notEmptyIndex].txt_extra:setText(AttributeTypeStr[i])
	                attr_extra[notEmptyIndex].txt_extra_val:setText("+ " .. covertToDisplayValue(i,extraAttr[i]))
	                notEmptyIndex = notEmptyIndex + 1
	            end
	        end
	        --检测是否附加属性不足3条
	        for i = notEmptyIndex,EquipmentManager.kMaxExtraAttributeSize do
	            attr_extra[i].txt_extra:setVisible(false)
	            attr_extra[i].txt_extra_val:setVisible(false)
               -- self.others[i + 1]:setVisible(false)
	        end

	        --宝石
	        local attr_gem = panel_details.attr_gem
            print(EquipmentManager.kGemMergeTargetNum .. "---kGemMergeTargetNum")
	        for i=1,EquipmentManager.kGemMergeTargetNum do
	            local item = ItemData:objectByID(equip:getGemPos(i))
	            if item then
                    print("gem----------true----"..i)
	                attr_gem[i].img_gem:setVisible(true)
	                attr_gem[i].txt_gem:setVisible(true)
                    attr_gem[i].txt_gem_val:setVisible(true)

	                local gem = GemData:objectByID(equip:getGemPos(i))
	                if gem then
	                    local attributekind , attributenum = gem:getAttribute()
	                    attr_gem[i].img_gem:setTexture(item:GetPath())
	            	    attr_gem[i].txt_gem:setText(AttributeTypeStr[attributekind])
	            	    attr_gem[i].txt_gem_val:setText("+ " .. covertToDisplayValue(attributekind,attributenum))
	                end
	            else
                    print("gem------------false-----" .. i)
	                attr_gem[i].img_gem:setVisible(false)	        	
	                attr_gem[i].txt_gem:setVisible(false)
	                attr_gem[i].txt_gem_val:setVisible(false)
	            end
	            -- end
	        end
	        --总战斗力
	        self.panel_totals[index].txt_power_details:setText(equip:getpower())
	    else
            self.panelTops[index].quality_bg:setVisible(false) 
            self.panel_details[index].details_node:setVisible(false) 
            self.panel_totals[index].total_node:setVisible(false)         
            --self.panle_needs[index].need_node:setVisible(false)
        end   
    end
    if self.gmIds[1] ~=0 and self.gmIds[2] ~= 0 then    

        for i,panel in ipairs(self.panle_needs) do
            panel.need_node:setVisible(true)
        end
        self.items ={}
        local equip = EquipmentManager:getEquipByGmid(self.gmIds[1])
        local dataConfig = EquipmentCCData:objectByID(equip.quality)  
        local temptbl = string.split(dataConfig.consume,'|')            --分解"|"
        for k,v in pairs(temptbl) do
            local panel = self.panle_needs[k]
            local temp = string.split(v,'_')               --分解'_',集合为 key，vaule 2个元素
            local item = {}
            item.type = tonumber(temp[1])
            item.itemId = tonumber(temp[2])
            item.number = tonumber(temp[3])
            table.insert(self.items,item)
            local reward = BaseDataManager:getReward(item)  
            if item.type == 1 then
                self.checkItem = clone(item)
            end
            if item.itemId ~= 0 then
                local number = BagManager:getItemById(item.itemId)
                print("number-----------------------------")
                print(number)
                if  number then
                    panel.txt_numb:setText( number.num .."/".. reward.number) 
                else
                    panel.txt_numb:setText( 0 .."/".. reward.number)  
                end                    
            else
                panel.txt_numb:setText(reward.number)
            end
            panel.img_icon:setTexture(reward.path)

            if itemType == EnumDropType.GOODS then
                local itemInfo = ItemData:objectByID(item.itemId)
                if itemInfo.type == EnumGameItemType.Soul or itemInfo.type == EnumGameItemType.Piece then
                    Public:addPieceImg(panel.img_icon,reward,true)
                end
                panel.need_node:setTexture(GetBackgroundForGoods(itemInfo))
            else
                print("quality--------"..reward.quality)
                panel.need_node:setTexture(GetColorIconByQuality(reward.quality))
            end    
        end 

        self.others[1]:setVisible(true) 
        -- self.others[6]:setVisible(true) 
        local extraAttr,indexTable = equip:getExtraAttributeWithRecast():getAttribute()
	    local notEmptyIndex = 1   
        for k,i in pairs(indexTable) do
	            if extraAttr[i] then  	
                    -- self.others[k+1]:setVisible(true)               
	                notEmptyIndex = notEmptyIndex + 1
	            end
	        end
	        --检测是否附加属性不足3条
	        for i = notEmptyIndex,EquipmentManager.kMaxExtraAttributeSize do	           
                -- self.others[i+1]:setVisible(false)
	        end  
    else

        -- for i,v in ipairs(self.others) do
        --     v:setVisible(false)
        -- end
        for i,v in ipairs(self.panle_needs) do
            v.need_node:setVisible(false)
        end
    end 


    for k,panel in pairs(self.panelTops) do
        if  self.gmIds[k] == 0 then
            panel.img_arrow:setVisible(false)
            panel.bg_wupin:setTexture(self.img_bg_state[1])
            panel.icon_add:setTexture(self.img_bg_icon[1])
        end
    end    

end

function SmritiMain:setSelectId(selectGmId) 
	self.gmIds[1] = selectGmId
	self:refreshUI()
end

function SmritiMain:setAcceptId(accoptGmId)
	self.gmIds[2] = accoptGmId
	self:refreshUI()
end

function SmritiMain:removeUI()
   	self.super.removeUI(self)  
end

function SmritiMain:onShow()
    self.super.onShow(self)
    self.generalHead:onShow();

    self:refreshUI()
end

function SmritiMain:registerEvents()
	self.super.registerEvents(self)    
	if self.generalHead then
        self.generalHead:registerEvents()
    end

    self.btn_smriti:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBtnSmriti))
    self.btn_smriti.logic = self

    self.btn_bangzhu:addMEListener(TFWIDGET_CLICK,audioClickfun(self.onBtnBangzhu))

    for k,panel in pairs(self.panelTops) do
    	panel.quality_bg:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBtnAdd))
    	panel.icon_add:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBtnAdd))
    	
    	panel.quality_bg.logic = self
    	panel.quality_bg.index = k

    	panel.icon_add.logic = self
    	panel.icon_add.index = k
    end

    for k,panel in ipairs(self.panle_needs) do
        panel.need_node:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBtnPro))
        panel.need_node.logic = self
        panel.need_node.index = k
    end

    --成功
    self.smritiCallBack =  function (event)
        self:playEffect()
        
    end


    TFDirector:addMEGlobalListener(EquipmentManager.EQUIP_SMIRITI ,self.smritiCallBack)
end

function SmritiMain:playEffect()
    if self.gmIds[1] == 0 or self.gmIds[2] == 0 then 
        return
    end    

    if self.effect then
        self.effect:playByIndex(0, -1, -1, 0)    
    else 
        local filePath = "effect/smriti.xml"
        TFResourceHelper:instance():addArmatureFromJsonFile(filePath)
        local effect = TFArmature:create("smriti_anim")
        effect:setAnimationFps(GameConfig.ANIM_FPS)
        effect:setPosition(ccp(480 ,320))  
        effect:playByIndex(0, -1, -1, 0)        
        effect:setVisible(true)
        self.panel_content:addChild(effect,100)
        self.effect = effect
    end
    self.effect:addMEListener(TFARMATURE_COMPLETE,
        function()
            self.effect:removeMEListener(TFARMATURE_COMPLETE) 
            self:refreshUI()
        end)
    --self:refreshUI()
end


function SmritiMain:removeEvents()
	self.super.removeEvents(self)
	if self.generalHead then
        self.generalHead:removeEvents()
    end
    TFDirector:removeMEGlobalListener(EquipmentManager.EQUIP_SMIRITI ,self.smritiCallBack)
end


function SmritiMain:dispose()
    self.super.dispose(self)
     if self.generalHead then
    	self.generalHead:dispose()
    	self.generalHead = nil
    end
    --self.effect = nil
end

return SmritiMain

--endregion

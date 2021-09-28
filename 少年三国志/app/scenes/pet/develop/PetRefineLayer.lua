local PetRefineLayer = class("PetRefineLayer",UFCCSNormalLayer)
local MergeEquipment = require("app.data.MergeEquipment")
local ItemConst = require("app.const.ItemConst")
local RefineItemCell = require("app.scenes.pet.develop.PetRefineItemCell")
local EffectNode = require "app.common.effects.EffectNode"
require("app.cfg.pet_info")
require("app.cfg.pet_addition_info")
require("app.cfg.item_info")

local refineItems = {ItemConst.ITEM_ID.PET_REFINE_ITEM1, ItemConst.ITEM_ID.PET_REFINE_ITEM2, ItemConst.ITEM_ID.PET_REFINE_ITEM3  }
local iconList = {[ItemConst.ITEM_ID.PET_REFINE_ITEM1] = "ui/yangcheng/chujishenlianshi1.png",
			[ItemConst.ITEM_ID.PET_REFINE_ITEM2] = "ui/yangcheng/zhongjishenlianshi1.png",
			[ItemConst.ITEM_ID.PET_REFINE_ITEM3] = "ui/yangcheng/gaojishenlianshi1.png",}
local boardList = {[ItemConst.ITEM_ID.PET_REFINE_ITEM1] = "ui/yangcheng/pinji_zhongji.png",
			[ItemConst.ITEM_ID.PET_REFINE_ITEM2] = "ui/yangcheng/pinji_gaoji.png",
			[ItemConst.ITEM_ID.PET_REFINE_ITEM3] = "ui/yangcheng/pinji_jipin.png",}

function PetRefineLayer:create(container)
    local layer = PetRefineLayer.new("ui_layout/petbag_Refine.json",container) 
    return layer
end

function PetRefineLayer:ctor(json,container)
	self.super.ctor(self,json)
	self._container = container
	self._pet = container:getPet()
	
	self._expLabel = self:getLabelByName("Label_exp")
	self._expLabel:createStroke(Colors.strokeBrown, 1)
            self._tipsLabel = self:getLabelByName("Label_tips")
            self._tipsLabel:createStroke(Colors.strokeBrown, 1)

	self._refineClickCount = 0
	self._refineClickShowCount = 0
            self:initContainer()
	self:initCells()

            self:registerWidgetClickEvent("Label_target", function ( ... )
                require("app.scenes.pet.develop.PetRefineTarget").show(self._pet)
            end)
            self:registerBtnClickEvent("Button_fastRefine",function ()
                if  self._playing then
                    return false
                end
                self._oldRefineLevel = self._pet.addition_lvl
                local layer = require("app.scenes.equipment.FastRefineLayer")
                layer.show(layer.TYPE_PET,self._pet)
            end)
end

function PetRefineLayer:onLayerEnter()
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_PET_UPADDITION, self._onRefineResult, self)
	self:updateView()
end


function PetRefineLayer:initContainer( )
    local open = G_moduleUnlock:isModuleUnlock(require("app.const.FunctionLevelConst").FAST_REFINE)
    self:getButtonByName("Button_fastRefine"):setVisible(open)

    local baseOffset = open and 1 or 0
    self:getImageViewByName("Image_barBg"):setPositionXY(404-baseOffset*40,22)
    self:getImageViewByName("Image_barBg"):setScaleX(open and 0.90 or 1)
    self:getLabelByName("Label_exp"):setPositionXY(404-baseOffset*40,22)
    self:getPanelByName("Panel_item"):setPositionXY(20-baseOffset*40,17)
end

function PetRefineLayer:enter()
	self._pet = G_Me.bagData.petData:getPetById(self._pet.id) 
	self:updateView()
	self._playing = false
	G_flyAttribute._clearFlyAttributes( )
	self:enterViewAnime()
end

function PetRefineLayer:exit(callback)
	self:exitViewAnime(callback)
end

function PetRefineLayer:enterViewAnime()
	G_GlobalFunc.flyIntoScreenLR( {self:getPanelByName("Panel_left")} ,
	    true, 0.2, 2, 20)
	G_GlobalFunc.flyIntoScreenLR( {self:getPanelByName("Panel_right")} ,
	    false, 0.2, 2, 20)
	G_GlobalFunc.flyIntoScreenTB({self:getPanelByName("Panel_botton_move")}, 
	    false, 0.2, 2, 20)

end

function PetRefineLayer:exitViewAnime(callback)
	G_GlobalFunc.flyOutScreenLR( {self:getPanelByName("Panel_left")} ,
	    true, 0.2, 2, 20)
	G_GlobalFunc.flyOutScreenLR( {self:getPanelByName("Panel_right")} ,
	    false, 0.2, 2, 20)
	G_GlobalFunc.flyOutScreenTB({self:getPanelByName("Panel_botton_move")}, 
	    false, 0.2, 2, 20,callback)
	
end

function PetRefineLayer:updateView()
	local petInfo = pet_info.get(self._pet.base_id)
	self._additionId = petInfo.addition_id
	self:updateAttr()
	self:updateProgessBar()
	self:updateCells()

	self:getLabelByName("Label_title3"):setText(G_lang:get("LANG_PET_REFINE_JIESHU"))
	self:getLabelByName("Label_level3"):setText(G_lang:get("LANG_PET_REFINE_JIE",{level=self._pet.addition_lvl}))
end

function PetRefineLayer:adapterLayer()
	local maxHeight = display.height
	self:getPanelByName("Panel_middle"):setPosition(ccp(0,maxHeight*2/3-250))
	self:getPanelByName("Panel_bottom"):setPosition(ccp(0,0))
end

function PetRefineLayer:updateAttr()
	self:getPanelByName("Panel_right"):setVisible(true)
	local info = pet_info.get(self._pet.base_id)
	for i = 1 , 2 do 
		local level = self._pet.addition_lvl-1+i
		local titleLabel = self:getLabelByName("Label_title"..i)
		titleLabel:setText(G_lang:get("LANG_PET_REFINE_TITLE",{level=level}))
		titleLabel:createStroke(Colors.strokeBrown, 1)
		local data = pet_addition_info.get(self._additionId,level)
                            local attrAdd = false
		if data then
			local refData = {}
			for t = 1 , 6 do 
				if data["type_"..t] > 0 then
					table.insert(refData,#refData+1,{index=t,type=data["type_"..t], value=data["value_"..t]})
				end
			end
			for j = 1 , 7 do 
				if refData[j] then
					local typeLabel = self:getLabelByName("Label_type"..i.."_"..j)
					local valueLabel = self:getLabelByName("Label_value"..i.."_"..j)
					local _,_,strtype,strvalue = MergeEquipment.convertPassiveSkillTypeAndValue(refData[j].type, refData[j].value)
					typeLabel:setText(refData[j].index.." "..strtype)
					valueLabel:setText("+"..strvalue)
					typeLabel:setVisible(true)
					valueLabel:setVisible(true)
					typeLabel:createStroke(Colors.strokeBrown, 1)
					valueLabel:createStroke(Colors.strokeBrown, 1)
				elseif not attrAdd then
                                                            attrAdd = true
                                                            local typeLabel = self:getLabelByName("Label_type"..i.."_"..j)
                                                            local valueLabel = self:getLabelByName("Label_value"..i.."_"..j)
                                                            typeLabel:setVisible(true)
                                                            valueLabel:setVisible(true)
                                                            typeLabel:createStroke(Colors.strokeBrown, 1)
                                                            valueLabel:createStroke(Colors.strokeBrown, 1)
                                                            local addAttr1,addAttr2 = G_Me.bagData.petData:getAttrAddShow(self._pet.base_id,level)
                                                            if addAttr1 then
                                                                typeLabel:setVisible(true)
                                                                valueLabel:setVisible(true)
                                                                typeLabel:setText(G_lang:get("LANG_PET_ATTR_ADD2"))
                                                                valueLabel:setText(addAttr2)
                                                            else
                                                                typeLabel:setVisible(false)
                                                                valueLabel:setVisible(false)
                                                            end
                                                    else
					local typeLabel = self:getLabelByName("Label_type"..i.."_"..j)
					local valueLabel = self:getLabelByName("Label_value"..i.."_"..j)
					typeLabel:setVisible(false)
					valueLabel:setVisible(false)
				end
			end

			self:updateAttrPanel(self:getImageViewByName("Image_hero"..i),data,i)
		else
			if i == 2 then
				self:getPanelByName("Panel_right"):setVisible(false)
			end
		end
	end
end

function PetRefineLayer:updateAttrPanel(panel,data,index)
	panel:removeAllChildrenWithCleanup(true)
	for i = 1 , 6 do 
		local img = self:getImageViewByName("heroImg"..index..i)
		local imgList = {"ui/pet/zhanwei-liang.png","ui/pet/zhanwei-hui.png"}
		if not img then
			img = ImageView:create()
			img:loadTexture(data["type_"..i]>0 and imgList[1] or imgList[2])
			img:setScale(0.75)
			local label = G_GlobalFunc.createGameLabel( i, 24, Colors.darkColors.DESCRIPTION, Colors.strokeBrown, CCSizeMake(16, 0), true )
			img:addChild(label)
			label:setPosition(ccp(0,0))
			img:setName("heroLabel"..index..i)
			label:setName("heroImg"..index..i)
			panel:addChild(img)
			local size = panel:getSize()
			img:setPosition(ccp((size.width+20)/4*((i-1)%3-1),(size.height+20)/3*(0.5-math.floor((i-1)/3))))
		else
			img:loadTexture(data["type_"..i]>0 and imgList[1] or imgList[2])
		end
	end
end

-- 设置进度�?
function PetRefineLayer:updateProgessBar()

	local curExp = G_Me.bagData.petData:getLeftRefineExp(self._pet)
	local needExp = pet_addition_info.get(self._additionId,self._pet.addition_lvl).exp

	if self._refineClickShowCount > 0 then
	    local baseInfo = item_info.get(self._useRefineItemId)
	    curExp = curExp + self._refineClickShowCount * baseInfo.item_value
	end
	
	self._expLabel:setText(G_lang:get("LANG_PET_STRENGTH_GETEXP",{curExp=curExp,totalExp=needExp}))

	local progress = self:getLoadingBarByName("ProgressBar_exp")

	local percent1 = curExp * 100 / needExp
	progress:setPercent(percent1)

	self:updateCells()

            local state = self._pet.addition_lvl < G_Me.bagData.petData:getMaxRefineLevel() and not G_Me.bagData.petData:couldRefine(self._pet)
            self._tipsLabel:setVisible(state)
            if state then
                self._tipsLabel:setText(G_lang:get("LANG_PET_REFINE_CONTINUE_NEED",{level=G_Me.bagData.petData:getNextRefineLevel(self._pet)}))
            end
end

function PetRefineLayer:initCells()

	self._cell1 = RefineItemCell.new(refineItems[1],iconList[refineItems[1]],boardList[refineItems[1]])
	self._cell2 = RefineItemCell.new(refineItems[2],iconList[refineItems[2]],boardList[refineItems[2]])
	self._cell3 = RefineItemCell.new(refineItems[3],iconList[refineItems[3]],boardList[refineItems[3]])
	self._cell1:setCallback(handler(self,  self.onClick))
	self._cell2:setCallback(handler(self,  self.onClick))
	self._cell3:setCallback(handler(self,  self.onClick))

            local gap = G_moduleUnlock:isModuleUnlock(require("app.const.FunctionLevelConst").FAST_REFINE) and 25 or 35
	local hlayout = require("app.common.layout.HLayout").new(self:getPanelByName("Panel_item"), gap, "center")
	hlayout:add(self._cell1)
	hlayout:add(self._cell2)
	hlayout:add(self._cell3)
end

function PetRefineLayer:updateCells()

	self._cell1:updateData(self._pet,self._useRefineItemId == refineItems[1] and self._refineClickShowCount or 0) 
	self._cell2:updateData(self._pet,self._useRefineItemId == refineItems[2] and self._refineClickShowCount or 0) 
	self._cell3:updateData(self._pet,self._useRefineItemId == refineItems[3] and self._refineClickShowCount or 0) 


end

function PetRefineLayer:onClick(refineItemId, cell, _type)
    if  self._playing then
        return false
    end

    self._refineCellPosition = cell:getImagePosition()
    self._useRefineItemId = refineItemId
    
    -- local level = self._pet.addition_lvl
    -- local maxLevel = G_Me.bagData.petData:getMaxRefineLevel()
    -- if level >= maxLevel then
    local funLevelConst = require("app.const.FunctionLevelConst")
    if not G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.PET_REFINE) then
        return
    end
    if self._pet.addition_lvl >= G_Me.bagData.petData:getMaxRefineLevel() then
        G_MovingTip:showMovingTip(G_lang:get("LANG_PET_REFINE_MAX"))
        return false
    end
    if not G_Me.bagData.petData:couldRefine(self._pet) then
        G_MovingTip:showMovingTip(G_lang:get("LANG_PET_REFINE_CONTINUE",{level=G_Me.bagData.petData:getNextRefineLevel(self._pet)}))
        return false
    end

    if _type then
        self._oldRefineLevel = self._pet.addition_lvl
        self._refineClickCount = self._refineClickCount + 1
        self._refineClickShowCount = self._refineClickCount
        self:_flyIcon()
        if self:checkUpLevel() then
            self:endRefine()
        else
            if self._schedule == nil then
                self._schedule = GlobalFunc.addTimer(0.1, handler(self, self._onUpdate))
            end
        end
        return true
    end

    if self._refineClickCount == 1 then
        local x, y = self:getLabelByName("Label_exp"):convertToWorldSpaceXY(0, 0)
        require("app.scenes.common.CommonInfoTipLayer").show(G_lang:get("LANG_KNIGHT_GUANZHI_REPEAT_TIP"), y + 60, 2)
    end

    if self._refineClickCount > 0 then
        self:endRefine()
    end

    return true
end

function PetRefineLayer:endRefine()

    if self._schedule then
        GlobalFunc.removeTimer(self._schedule)
        self._schedule = nil
    end

    G_HandlersManager.petHandler:sendPetUpAddition(self._pet.id, self._useRefineItemId,self._refineClickCount)
    self._refineClickCount = 0
    -- self._playing = true
    
end


function PetRefineLayer:checkUpLevel()
	if self._refineClickCount > 0 then
		local leftRefineExp = G_Me.bagData.petData:getLeftRefineExp(self._pet)
		local baseInfo = item_info.get(self._useRefineItemId)
		leftRefineExp = leftRefineExp + self._refineClickCount * baseInfo.item_value
		local expNeed = G_Me.bagData.petData.getRefineNeedExp(self._pet)
		return leftRefineExp >= expNeed
	else
		return false
	end
	return false
end


function PetRefineLayer:_onUpdate( )
        local refineItemInfo = G_Me.bagData.propList:getItemByKey(self._useRefineItemId)
        local baseInfo = item_info.get(self._useRefineItemId)
        if refineItemInfo and refineItemInfo.num > self._refineClickCount then
            self._refineClickCount = self._refineClickCount + 1
            self._refineClickShowCount = self._refineClickCount
            self:_flyIcon()
            if self:checkUpLevel() then
                self:endRefine()
            end
        else
            G_MovingTip:showMovingTip(G_lang:get("LANG_NO_ENOUGH_AMOUNT", {item_name=baseInfo.name}))
            self:endRefine()
        end 
end

function PetRefineLayer:stopCellEffect()
    self._cell1:stopEffect()
    self._cell2:stopEffect()
    self._cell3:stopEffect()
end


function PetRefineLayer:_onRefineResult(data)    
    if data.ret == NetMsg_ERROR.RET_OK then
        local baseInfo = item_info.get(self._useRefineItemId)
        -- self._pet = G_Me.bagData.petData:getPetById(self._pet.id) 
        local pet = self._pet
        self._refineClickShowCount = self._refineClickCount

        local refineAni = function ( levelup )
            if levelup then
                self._playing = true
                self:stopCellEffect()
                local nextLevel = pet.addition_lvl

                local addId = pet_info.get(pet.base_id).addition_id
                local attrs = pet_addition_info.get(addId,self._oldRefineLevel )
                local attrsNext = pet_addition_info.get(addId,nextLevel)
                local deltaAttr = {}
                --属性变�?
                for i=1,6 do
                	if attrsNext["type_"..i] > 0 then
			local _,_,strType,strValue = MergeEquipment.convertPassiveSkillTypeAndValue(attrsNext["type_"..i], attrsNext["value_"..i]-attrs["value_"..i])
			local deltaString = G_lang:get("LANG_PET_REFINE_ATTR_ADD",{index=i,attrType=strType})
			-- deltaAttr[i] = {title=deltaString,value=strValue}
			table.insert(deltaAttr,#deltaAttr+1,{title=deltaString,value=strValue})
		end
                end

                local finishEffect  = false
                local finish_callback = function()
                    if G_SceneObserver:getSceneName() ~= "PetDevelopeScene" then
                        return
                    end
                    if finishEffect then
                        self._playing = false
                        self:updateView()

                    end

                end

                -- if self._effect == nil then 
                --         self._effect = EffectNode.new("effect_particle_star", 
                --             function(event, frameIndex)
                --                 if event == "forever" then
                --                     self:_stopEffect()
                --                     finishEffect = true
                --                     self:_flyAttr(deltaAttr,finish_callback)
                --                 end
                --             end
                --         )
                -- end
                -- self._container:getEffectNode():addNode(self._effect)

                if self._fire == nil then 
                    self._fire = EffectNode.new("effect_shoulan_shenlian", 
                        function(event, frameIndex)
                            if event == "finish" then
			if self._fire then
				self._fire:removeFromParentAndCleanup(true)
				self._fire = nil
			end
	                        	self:_stopEffect()
			finishEffect = true
			self:_flyAttr(deltaAttr,finish_callback)
                            end
                        end
                    )
                    self._fire:setPosition(ccp(0,100))
                    self._container:getEffectNode():addNode(self._fire)
                    self._fire:play()
                end
            else
                -- self:updateView()
                self._playing = false
                self:updateProgessBar()
            end
        end
        local levelup = self._oldRefineLevel < self._pet.addition_lvl
        self._playing = true
        refineAni(levelup)
    end
end

function PetRefineLayer:_flyIcon( )

    local baseInfo = item_info.get(self._useRefineItemId)
    local pet = self._pet

    local addXXXX = function ( )
        -- 精炼�?XXXX 
        local pt = self:getLabelByName("Label_exp"):convertToWorldSpace(ccp(0, 0))
        pt.y = pt.y + 60
        local tip = require("app.scenes.equipment.tip.EquipmentRefineTip").new()
        tip:setPosition(pt)
        tip:playWithText(G_lang:get("LANG_REFINE_TIP", {refine_exp=baseInfo.item_value}))
        tip:setScale(2)
        local moveScale = CCScaleTo:create(1.0,1)
        tip:runAction(moveScale)
        uf_notifyLayer:getTipNode():addChild(tip) 
    end
    
    local panel = self:getPanelByName("Panel_bottom")
    --产生一个icon, 缩小飞到经验�?
    -- local icon = CCSprite:create(G_Path.getItemIcon(baseInfo.res_id))
    local icon = CCSprite:create(G_Path.getItemIcon(baseInfo.res_id))
    icon:setPosition(panel:convertToNodeSpace(self._refineCellPosition))
    icon:setScale(0.9)
    local rect = icon:getContentSize()
    local pos = ccp(0,0)
    if self._useRefineItemId == refineItems[1] then 
        pos = ccp(-rect.width/2,0)
    elseif self._useRefineItemId == refineItems[2] then 
        pos = ccp(-rect.width/6,0)
    elseif self._useRefineItemId == refineItems[3] then 
        pos = ccp(rect.width/6,0)
    elseif self._useRefineItemId == refineItems[4] then 
        pos = ccp(rect.width/2,0)
    end
    local emiter = CCParticleSystemQuad:create("particles/lizi1.plist")
    emiter:setPosition(pos)
    icon:addChild(emiter)
    panel:addNode(icon,10)
    transition.scaleTo(icon, {time=0.6, scaleX=0.1, scaleY =0.1})
    transition.fadeTo(icon, {time=0.6, opacity=0})
    local ptx, pty = self:getImageViewByName("Image_barBg"):convertToWorldSpaceXY(self:getLabelByName("Label_exp"):getPosition())
    ptx, pty = panel:convertToNodeSpaceXY(ptx,pty)
    local moveto = CCMoveTo:create(0.6, ccp(ptx, pty))
    local seq= transition.sequence({
        moveto,
        CCCallFunc:create(
            function() 
                emiter:stopSystem()
                self:updateProgessBar()
                addXXXX()
                local added = nil
                added = EffectNode.new("effect_jinglian_xiaoshi", 
                    function(event, frameIndex)
                        if event == "finish" then
                            if added then
                                added:removeFromParentAndCleanup(true)
                            end
                        end
                    end
                )
                self:addChild(added)
                added:setPosition(ccp(ptx, pty+10))
                added:play()
                icon:removeFromParentAndCleanup(true)
            end
        )
    })
    icon:runAction(seq)
end

function PetRefineLayer:_flyAttr( deltaAttr,finish_callback)

	G_flyAttribute._clearFlyAttributes()

	local info = pet_info.get(self._pet.base_id)
	local deltaLevel = self._pet.addition_lvl - self._oldRefineLevel
	local levelTxt = G_lang:get("LANG_PET_LIAN_MOVE", {pet=info.name,level=self._pet.addition_lvl})

	local basePos = ccp(320,200)
	G_flyAttribute.addNormalText(levelTxt,Colors.uiColors.ORANGE, self:getLabelByName("Label_level3"))

	--属性加�?
	for k, v in pairs(deltaAttr) do 
	    G_flyAttribute.addAttriChange(v.title, v.value, self:getLabelByName("Label_value1_"..k))
	end

	G_flyAttribute.play(function ( ... )
	    finish_callback()
	end)
end


function PetRefineLayer:_stopEffect()

    if self._effect  ~= nil then

        self._effect:stop()
        self._effect:removeFromParentAndCleanup(true)
        self._effect = nil    
    end
end

function PetRefineLayer:exit()
        if self._fire then
            self._fire:removeFromParentAndCleanup(true)
            self._fire = nil
        end
        finishEffect = true
end

return PetRefineLayer
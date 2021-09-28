--ChangeLegionIconLayer.lua

require("app.cfg.corps_frame_info")

local ChangeLegionIconLayer = class("ChangeLegionIconLayer", UFCCSModelLayer)


function ChangeLegionIconLayer.show( ... )
	local changeLegion = ChangeLegionIconLayer.new("ui_layout/legion_ChangeLegionIcon.json", Colors.modelColor, ...)
	uf_sceneManager:getCurScene():addChild(changeLegion)
end

function ChangeLegionIconLayer:ctor( ... )
	self._defaultIcon = 0
	self._defaultIconBack = 0

	self.super.ctor(self, ...)
end

function ChangeLegionIconLayer:onLayerLoad( ... )
	self:closeAtReturn(true)
	self:registerBtnClickEvent("Button_cancel", handler(self, self._onCancelClick))
	self:registerBtnClickEvent("Button_close", handler(self, self._onCancelClick))
	self:registerBtnClickEvent("Button_save", handler(self, self._onSaveClick))

	self:enableLabelStroke("Label_title_1", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_title_2", Colors.strokeBrown, 2 )

	self:_initIconBacks()

	local detailCorp = G_Me.legionData:getCorpDetail()
	-- 军团ICON
	self:registerWidgetClickEvent("Image_icon_1", function ( ... )
		self:_onSelectIcon( 1 )
	end)
	self:registerWidgetClickEvent("Image_icon_2", function ( ... )
		self:_onSelectIcon( 2 )
	end)
	self:registerWidgetClickEvent("Image_icon_3", function ( ... )
		self:_onSelectIcon( 3 )
	end)	
	self:_onSelectIcon((detailCorp and detailCorp.icon_pic > 0) and detailCorp.icon_pic or 1)

	-- 军团ICON边框
	self:registerWidgetClickEvent("Image_frame_1", function ( ... )
		self:_onSelectIconBack( 1 )
	end)
		
	self:_onSelectIconBack(detailCorp and detailCorp.icon_frame or 1)
end

function ChangeLegionIconLayer:onLayerEnter( ... )
	self:showAtCenter(true)
	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_back"), "smoving_bounce")
end

function ChangeLegionIconLayer:_onCancelClick( ... )
	self:animationToClose()
end

function ChangeLegionIconLayer:_onSelectIcon( index )
	index = index or 1

	if index == self._defaultIcon then 
		return 
	end

	self._defaultIcon = index
	self:showWidgetByName("Image_gou_1", index == 1)
	self:showWidgetByName("Image_gou_2", index == 2)
	self:showWidgetByName("Image_gou_3", index == 3)
end

function ChangeLegionIconLayer:_onSelectIconBack( index )
	index = index or 1

	if index == self._defaultIconBack then 
		return 
	end

	self._defaultIconBack = index
	self:showWidgetByName("Image_frame_gou_1", index == 1)
	self:showWidgetByName("Image_frame_gou_2", index == 2)
	self:showWidgetByName("Image_frame_gou_3", index == 3)

end

function ChangeLegionIconLayer:_onSaveClick( ... )
	local detailCorp = G_Me.legionData:getCorpDetail() 
	if not detailCorp then 
		return 
	end

	if detailCorp.position < 1 then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_NO_CHANGE_ICON_RIGHT"))
	end

	if ((detailCorp.icon_pic ~= self._defaultIcon) or (detailCorp.icon_frame ~= self._defaultIconBack)) then 
		G_HandlersManager.legionHandler:sendModifyCorp(detailCorp.announcement, 
			self._defaultIcon, self._defaultIconBack, detailCorp.notification)
	end

	self:animationToClose()
end

function ChangeLegionIconLayer:_initIconBacks( ... )
	local corpsFrameInfo2 = corps_frame_info.get(2)
	local detailCorp = G_Me.legionData:getCorpDetail() 
	local corpLevel = detailCorp.level or 1
	
	self:showWidgetByName("Image_lock_2", not corpsFrameInfo2 or corpsFrameInfo2.value > corpLevel) 
	--self:enableWidgetByName("Image_frame_2", corpsFrameInfo2 and corpsFrameInfo2.value <= corpLevel)
	self:registerWidgetClickEvent("Image_frame_2", function ( ... )
		if corpsFrameInfo2 and corpsFrameInfo2.value <= corpLevel then
			self:_onSelectIconBack( 2 )
		else
			local label = self:getLabelByName("Label_frame_2")
			--G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CHANGE_ICON_BACK_LOCK", 
			--	{levelValue=corpsFrameInfo2.value or 1, iconName=label and label:getStringValue() or ""}))
			G_MovingTip:showMovingTip(corpsFrameInfo2 and corpsFrameInfo2.tips)
		end
	end)

	local corpsFrameInfo3 = corps_frame_info.get(3)
	self:showWidgetByName("Image_lock_3", not corpsFrameInfo3 or corpsFrameInfo3.value > corpLevel) 
	--self:enableWidgetByName("Image_frame_3", corpsFrameInfo3 and corpsFrameInfo3.value <= corpLevel)
	self:registerWidgetClickEvent("Image_frame_3", function ( ... )
		if corpsFrameInfo3 and corpsFrameInfo3.value <= corpLevel then 
			self:_onSelectIconBack( 3 )
		else
			local label = self:getLabelByName("Label_frame_3")
			--G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CHANGE_ICON_BACK_LOCK", 
				--{levelValue=corpsFrameInfo2.value or 1, iconName=label and label:getStringValue() or ""}))
			G_MovingTip:showMovingTip(corpsFrameInfo3 and corpsFrameInfo3.tips)
		end
	end)
end

return ChangeLegionIconLayer

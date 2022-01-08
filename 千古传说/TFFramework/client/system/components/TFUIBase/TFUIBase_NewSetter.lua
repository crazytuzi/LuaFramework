local setmetatable 						= setmetatable
local string 							= string
local ccp 								= ccp
local ccs 								= ccs
local me 								= me

local TFMargin							= TFMargin
local TFGridLayoutParameter 			= TFGridLayoutParameter

local TF_SIZE_PERCENT					= TF_SIZE_PERCENT
local TF_SIZE_RELATIVE					= TF_SIZE_RELATIVE
local TF_SIZE_FRAMESIZE					= TF_SIZE_FRAMESIZE
local TF_SIZE_ADAPT						= TF_SIZE_ADAPT

local TF_L_GRAVITY_TOP					= TF_L_GRAVITY_TOP
local TF_L_GRAVITY_CENTER_VERTICAL		= TF_L_GRAVITY_CENTER_VERTICAL
local TF_L_GRAVITY_BOTTOM				= TF_L_GRAVITY_BOTTOM
local TF_L_GRAVITY_LEFT					= TF_L_GRAVITY_LEFT
local TF_L_GRAVITY_CENTER_HORIZONTAL	= TF_L_GRAVITY_CENTER_HORIZONTAL
local TF_L_GRAVITY_RIGHT				= TF_L_GRAVITY_RIGHT

local setFuncs_new 		= {}
TFUIBase_setFuncs_new 	= setFuncs_new

local cs
setFuncs_new["TFWidget"] = {
	['UIEditorData']	= function(obj, val) if val then obj.UIEditorData = val end end,
	['tag'] 			= function(obj, val) if val then obj:setTag(val) end end,
	['touchAble'] 		= function(obj, val) if val then obj:setTouchEnabled(val) end end,
	['name'] 			= function(obj, val) if val then obj:setName(val) end end,
	['Scale'] 			= function(obj, val) if val then obj:setScaleX(val.x); obj:setScaleY(val.y) end end,
	['rotation'] 		= function(obj, val) if val then obj:setRotation(val) end end,
	['visible'] 		= function(obj, val) if val ~= nil then obj:setVisible(val) end end,
	['ZOrder'] 			= function(obj, val) if val then obj:setZOrder(val) end end,
	['opacity'] 		= function(obj, val) if val and obj.setOpacity then obj:setOpacity(val) end end,
	['anchorPoint'] 	= function(obj, val) if val then obj:setAnchorPoint(val) end end,
	['UILayout'] 		= function(obj, val) if val then setFuncs_new:setLayoutByTable(obj, val) end end,
	['flipX'] 			= function(obj, val) if val ~= nil and obj.setFlipX then obj:setFlipX(val) end end,
	['flipY'] 			= function(obj, val) if val ~= nil and obj.setFlipY then obj:setFlipY(val) end end,
	['TextBase']		= function (obj, val) if next(val) then setFuncs_new:setTextBase(obj, val) end end,
	['HitType'] 		= function(obj, val) 
							if not val.nHitType or val.nHitType == 0 then return end
							obj:setHitType(val.nHitType)
							if val.nHitType == 1 then
								val.tHitRectSize = val.tHitRectSize or ccs(0, 0)
								val.tHitOriginPoint = val.tHitOriginPoint or ccp(0, 0)
								obj:setHitRect(val.tHitRectSize, val.tHitOriginPoint) 
							end
							if val.nHitType == 2 and val.nHitRadius then obj:setHitRadius(val.nHitRadius) end
						end,
	-- todo different class has different init blend
	['BlendFunc'] 		= function(obj, val) 
							if next(val) and obj.setBlendFunc then 
								local blend = ccBlendFunc()
								blend.src = val.nSrc
								blend.dst = val.nDst
								obj:setBlendFunc(blend) 
							end 
						end,
	['Size'] 			= function(obj, val) 
							if not next(val) then return end
							if obj.ignoreContentAdaptWithSize then 
								obj:ignoreContentAdaptWithSize(val.bIgnoreSize) 
							end
							if not val.bIgnoreSize then 
								if val.tSize then 
									obj:setSize(val.tSize)
									if obj.setTextAreaSize then
										obj:setTextAreaSize(val.tSize)
									end
									if obj.setRichTextSize then
										obj:setRichTextSize(ccs(width, height))
									end
								end
								if val.nSizeType then
									obj:setSizeType(val.nSizeType)
									if val.nSizeType == TF_SIZE_PERCENT then
										obj:setSizePercent(val.tSizePercent)
									end
									if val.nSizeType == TF_SIZE_RELATIVE then
										obj:setSizeRelative(val.tSizeRelative)
									end
									if val.nSizeType == TF_SIZE_FRAMESIZE then
										local width, height = me.EGLView:getFrameSize().width * val.tSizePercent.x, me.EGLView:getFrameSize().height * val.tSizePercent.y
										obj:setSize(ccs(width, height))
										if obj.setTextAreaSize then
											obj:setTextAreaSize(val.tSize)
										end
										if obj.setRichTextSize then
											obj:setRichTextSize(ccs(width, height))
										end
									end
									if val.nSizeType == TF_SIZE_ADAPT and obj.setDesignResolutionSize then
										val.nResolutionPolicyType = val.nResolutionPolicyType
										val.tDesignSize = val.tDesignSize
										obj:setDesignResolutionSize(val.tDesignSize.width, val.tDesignSize.height, val.nResolutionPolicyType)
									end
								end
								if val.BgScale9Enable  then
									if obj.setScale9Enabled then
										obj:setScale9Enabled(true)
										if val.tScale9RectPos then
											obj:setCapInsets(CCRectMake(val.tScale9RectPos.x, val.tScale9RectPos.y, val.tScale9RectSize.width, val.tScale9RectSize.height))
										end
									elseif obj.setBackGroundImageScale9Enabled then
										obj:setBackGroundImageScale9Enabled(true)
										if val.tScale9RectPos then
											obj:setBackGroundImageCapInsets(CCRectMake(val.tScale9RectPos.x, val.tScale9RectPos.y, val.tScale9RectSize.width, val.tScale9RectSize.height))
										end
									end
								end
								if val.bCorrdEnabled then
									obj:setImageSizeType(2)
								end
							end 
							-- if not val.tSize then
							-- 	print("setSize size is nil!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!", obj:getDescription(), obj:getName())
							-- end
						end,
	['ColorMixing'] 	= function(obj, color) 
							if color and (color.r ~= 255 or color.g ~= 255 or color.b ~= 255) and obj.setColor then
								obj:setColor(color)
							end 
						end,
	-- not base but image base
	['PanelRelativeSizeModel'] 	= function(obj, model) 
							if model and type(model) == 'table' then
								if model['PanelRelativeEnable'] then
									local nPer = model['PanelRelativeSizePercentage']
									local size = me.EGLView:getDesignResolutionSize()
									obj:setSize(ccs(size.width * nPer / 100, size.height * nPer / 100))
								end
							end
						end,
	['Script'] 			= function (obj, val) 
							if val ~= nil then 
								for _, szPath in pairs(val) do 
									if type(szPath) == 'string' then 
										obj:addComponent(szPath)
									end
								end
							end
						end
}

setFuncs_new["TFWidget"].__index = setFuncs_new["TFWidget"]

setFuncs_new["TFImage"] 		= setmetatable({}, setFuncs_new["TFWidget"])
setFuncs_new["TFLabel"] 		= setmetatable({}, setFuncs_new["TFWidget"])
setFuncs_new["TFPanel"] 		= setmetatable({}, setFuncs_new["TFWidget"])
setFuncs_new["TFButton"] 		= setmetatable({}, setFuncs_new["TFWidget"])
setFuncs_new["TFArmature"] 		= setmetatable({}, setFuncs_new["TFWidget"])
setFuncs_new["TFCheckBox"] 		= setmetatable({}, setFuncs_new["TFWidget"])
setFuncs_new["TFCoverFlow"] 	= setmetatable({}, setFuncs_new["TFWidget"])
setFuncs_new["TFGroupButton"] 	= setmetatable({}, setFuncs_new["TFWidget"])
setFuncs_new["TFButtonGroup"] 	= setmetatable({}, setFuncs_new["TFWidget"])
setFuncs_new["TFLabelBMFont"] 	= setmetatable({}, setFuncs_new["TFWidget"])
setFuncs_new["TFListView"] 		= setmetatable({}, setFuncs_new["TFWidget"])
setFuncs_new["TFLoadingBar"] 	= setmetatable({}, setFuncs_new["TFWidget"])
setFuncs_new["TFMovieClip"] 	= setmetatable({}, setFuncs_new["TFWidget"])
setFuncs_new["TFPageView"] 		= setmetatable({}, setFuncs_new["TFWidget"])
setFuncs_new["TFParticle"] 		= setmetatable({}, setFuncs_new["TFWidget"])
setFuncs_new["TFScrollView"] 	= setmetatable({}, setFuncs_new["TFWidget"])
setFuncs_new["TFSlider"] 		= setmetatable({}, setFuncs_new["TFWidget"])
setFuncs_new["TFTableView"] 	= setmetatable({}, setFuncs_new["TFWidget"])
setFuncs_new["TFTableViewCell"] = setmetatable({}, setFuncs_new["TFWidget"])
setFuncs_new["TFTextField"] 	= setmetatable({}, setFuncs_new["TFWidget"])
setFuncs_new["TFRichText"] 		= setmetatable({}, setFuncs_new["TFWidget"])

-- override touchAble
setFuncs_new["TFImage"]['touchAble'] 		= function(obj, val) if val then obj:setTouchEnabled(true) end end
setFuncs_new["TFLabel"]['touchAble'] 		= function(obj, val) if val then obj:setTouchEnabled(true) end end
setFuncs_new["TFPanel"]['touchAble'] 		= function(obj, val) if val then obj:setTouchEnabled(true) end end
setFuncs_new["TFArmature"]['touchAble'] 	= function(obj, val) if val then obj:setTouchEnabled(true) end end
setFuncs_new["TFLabelBMFont"]['touchAble'] 	= function(obj, val) if val then obj:setTouchEnabled(true) end end
setFuncs_new["TFMovieClip"]['touchAble'] 	= function(obj, val) if val then obj:setTouchEnabled(true) end end
setFuncs_new["TFParticle"]['touchAble'] 	= function(obj, val) if val then obj:setTouchEnabled(true) end end
setFuncs_new["TFTextField"]['touchAble'] 	= function(obj, val) if val then obj:setTouchEnabled(true) end end

function setFuncs_new:setLayoutByTable(target, tParam)
	if tParam.tPosition then
		target:setPosition(tParam.tPosition)
	end

	if tParam.IsPercent then
		target:setPositionType(TF_POSITION_PERCENT)
		if tParam.tPosPercent then
			local x, y = tParam.tPosPercent.x, tParam.tPosPercent.y
			target:setPositionPercent(ccp(x, y))
		end
	end

	if target:getParent() then
		local layoutParameter
		tParam.nParentLayoutType = target:getParent():getLayoutType()
		if tParam.nParentLayoutType == TF_LAYOUT_ABSOLUTE then return end
		if tParam.nParentLayoutType == TF_LAYOUT_LINEAR_VERTICAL or tParam.nParentLayoutType == TF_LAYOUT_LINEAR_HORIZONTAL then
			layoutParameter	= TFLinearLayoutParameter:create()
			local eNum = 0
			if tParam.nParentLayoutType == TF_LAYOUT_LINEAR_VERTICAL then
				if tParam.nLinearVertical == 0 then eNum = TF_L_GRAVITY_LEFT end
				if tParam.nLinearVertical == 1 then eNum = TF_L_GRAVITY_CENTER_HORIZONTAL end
				if tParam.nLinearVertical == 2 then eNum = TF_L_GRAVITY_RIGHT end
			else
				if tParam.nLinearHorizon == 0 then eNum = TF_L_GRAVITY_TOP end
				if tParam.nLinearHorizon == 1 then eNum = TF_L_GRAVITY_CENTER_VERTICAL end
				if tParam.nLinearHorizon == 2 then eNum = TF_L_GRAVITY_BOTTOM end
			end
			layoutParameter:setGravity(eNum)
		elseif tParam.nParentLayoutType == TF_LAYOUT_RELATIVE then
			layoutParameter = TFRelativeLayoutParameter:create()
			layoutParameter:setRelativeName(target:getName())
			layoutParameter:setRelativeToWidgetName(tParam.szRelativeToName)
			local nAlign = 0
			if tParam.szRelativeToName ~= target:getParent():getName() and tParam.szRelativeToName ~= "" then
				-- todo change the C++ enum order
				local preParent = target:getParent():getParent()
				if preParent and preParent:getDescription() == "TFScrollView" and preParent:getName() == tParam.szRelativeToName then
					nAlign = tParam.nRelativeVertical * 3 + tParam.nRelativeHorizon + 1
				else
					if tParam.nRelativePadding == 0 or tParam.nRelativePadding == 2 then
						if tParam.nRelativePadding == 0 then
							nAlign = 3 + tParam.nRelativeVertical + 10
						else
							nAlign = 3*tParam.nRelativePadding + tParam.nRelativeVertical + 10
						end
					else
						if tParam.nRelativePadding == 3 then
							nAlign = tParam.nRelativePadding * 3 + tParam.nRelativeHorizon + 10
						else
							nAlign = 0 + tParam.nRelativeHorizon + 10
						end
					end
				end
			else
				nAlign = tParam.nRelativeVertical * 3 + tParam.nRelativeHorizon + 1
			end
			layoutParameter:setAlign(nAlign)
		elseif tParam.nParentLayoutType == TF_LAYOUT_GRID then
			layoutParameter = TFGridLayoutParameter:create()
		end

		if layoutParameter and tParam.tMargin then
			layoutParameter:setMargin(TFMargin(tParam.tMargin.left, tParam.tMargin.top, tParam.tMargin.right, tParam.tMargin.bottom))
		end

		if layoutParameter then
			target:setLayoutParameter(layoutParameter)
		end	
	end
end

function setFuncs_new:setTextBase(target, tParam)
	if tParam.szText and target.setText then
    	target:convertSpecialChar(tParam)
		target:setText(tParam.szText)
	end

	if target.setFontName and tParam.szFontName then
		target:setFontName(tParam.szFontName)
	end

	if target.setFontSize and tParam.tFontSize then
		target:setFontSize(tParam.tFontSize)
	end

	if target.setFontColor and tParam.tFontColor then
		target:setFontColor(tParam.tFontColor)
	elseif target.setFontFillColor and tParam.tFontColor then
		target:setFontFillColor(tParam.tFontColor)
	end

	if target.setTextHorizontalAlignment and tParam.nTextAlignHorizon then
		target:setTextHorizontalAlignment(tParam.nTextAlignHorizon)
	end

	if target.setTextVerticalAlignment and tParam.nTextAlignVertical then
		target:setTextVerticalAlignment(tParam.nTextAlignVertical)
	end

	-- touch effect, scale
	if target.setTouchScaleChangeAble and tParam.bEffectEnabled then 
		target:setTouchScaleChangeAble(tParam.bEffectEnabled)
	end

	if tParam.bEnableStroke then
		local label = target
		if target.getLabel then
			label = target:getLabel()
		end
		label:enableStroke(tParam.tStrokeColor, tParam.nStrokeSize)
	end

	if tParam.bEnableShadow then
		local label = target
		if target.getLabel then
			label = target:getLabel()
		end
		label:enableShadow(tParam.tShadowColor, tParam.tShadowOffset, tParam.tShadowOpacity)
	end

end

function setFuncs_new:reorganizeData(val)
	local pVal = {}
	if val.classname == "TFPage" then val.classname = "TFPanel" end
	pVal.classname = val.classname
	pVal.components = val.components
	pVal.tBaseData = {}
	pVal.UIEditorData = {}
	pVal.tLayoutBase = {}


	--Editor edit data
	pVal.UIEditorData = val.DiyPropertyViewModel

	-- base data
	pVal.tBaseData.nTag 			= val.tag or 0
	pVal.tBaseData.bTouchAble 		= val.touchAble
	pVal.tBaseData.szName 		= val.name
	pVal.tBaseData.tScale 			= val.scale
	pVal.tBaseData.nRotation 		= val.rotation
	pVal.tBaseData.bVisible 		= val.visible
	pVal.tBaseData.ZOrder 			= val.ZOrder or val.baseNum
	pVal.tBaseData.nOpacity 		= val.opacity
	pVal.tBaseData.tAnchorPoint 		= val.anchorPoint
	if val.mixedValueColor then val.mixedValueColor.a = val.opacity end
	pVal.tBaseData.tMixColor		= val.mixedValueColor
	pVal.tBaseData.nHitType 		= val.hitType
	pVal.tBaseData.tHitOriginPoint		= val.hitOriginPoint
	pVal.tBaseData.tHitRectSize		= val.hitSquaredSize
	pVal.tBaseData.nHitRadius		= val.hitRadius	
	pVal.tBaseData.tColor 			= val.mixedColor
	pVal.tBaseData.bFlipX			= val.hFlip
	pVal.tBaseData.bFlipY			= val.vFlipV
	pVal.tBaseData.tScript			= val.Script
	pVal.tBaseData.tBlend			= {nSrc = val.originMixed, nDst = val.targetMixed}

	pVal.tSizeBase = {}
	pVal.tSizeBase.bIgnoreSize 		= val.ignoreSize
	pVal.tSizeBase.nSizeType 		= val.sizeType
	pVal.tSizeBase.bCorrdEnabled		= val.isTile
	pVal.tSizeBase.tSize 			= val.size
	if val.sizepercent then
		pVal.tSizeBase.tSizePercent	= ccp(val.sizepercent.x / 100, val.sizepercent.y / 100)
	end
	-- pVal.tSizeBase.tSizeRelative		= val.tSizeRelative
	pVal.tSizeBase.BgScale9Enable	= val.backGroundScale9Enable
	pVal.tSizeBase.tScale9RectPos	= val.originPoint or {x = 0, y = 0}
	pVal.tSizeBase.tScale9RectSize	= val.squaredSize or {width = 0, height = 0}
	pVal.tSizeBase.nResolutionPolicyType	= val.designResolutionPolicy or 0
	pVal.tSizeBase.tDesignSize 		= val.designResolutionSize or {width = 400, height = 400}

	pVal.tTextBase = {}
	pVal.tTextBase.szFontName		= val.fontName
	pVal.tTextBase.tFontSize		= val.fontSize
	pVal.tTextBase.szText			= val.text
	pVal.tTextBase.tFontColor		= val.fontColor
	pVal.tTextBase.nTextAlignHorizon	= val.hTextAlign
	pVal.tTextBase.nTextAlignVertical	= val.vTextAlign
	pVal.tTextBase.bEffectEnabled		= val.bEffectEnabled
	pVal.tTextBase.tStrokeColor 		= val.fontStrokeColor or ccc3(255, 255, 255)
	pVal.tTextBase.nStrokeSize		= val.fontStrokeSize or 1
	pVal.tTextBase.bEnableStroke		= val.fontStroke
	pVal.tTextBase.bEnableShadow	= val.isShadow
	pVal.tTextBase.tShadowOpacity	= (val.shadowOpacity or 255) / 255
	if val.shadowOffset then pVal.tTextBase.tShadowOffset = ccs(val.shadowOffset.x, val.shadowOffset.y) else pVal.tTextBase.tShadowOffset = ccs(0, 0) end
	pVal.tTextBase.tShadowColor		= val.shadowColor or ccc3(255, 255, 255)

	-- layout property
	pVal.tLayoutBase.nLayoutType 		= val.layoutType
	pVal.tLayoutBase.IsPercent 		= val.percentage
	pVal.tLayoutBase.tPosition 		= val.position
	if val.percentPosition then
		pVal.tLayoutBase.tPosPercent	 = ccp(val.percentPosition.x / 100, val.percentPosition.y / 100)
	end
	pVal.tLayoutBase.tMargin 		= val.margin
	pVal.tLayoutBase.szRelativeToName 	= val.relativeToName
	pVal.tLayoutBase.nRelativePadding 	= val.nAlign or 0
	pVal.tLayoutBase.nRelativeHorizon 	= val.nRHAlign or 0
	pVal.tLayoutBase.nRelativeVertical 	= val.nRVAlign or 0
	pVal.tLayoutBase.nLinearHorizon 	= val.nVAlign or 0
	pVal.tLayoutBase.nLinearVertical 	= val.nHAlign or 0
	pVal.tLayoutBase.nParentLayoutType	= val.parentLayout
	pVal.tLayoutBase.nGridPriority 	= val.nGridPriority or 0
	if val.grids then
		pVal.tLayoutBase.nRows 			= val.grids.x
		pVal.tLayoutBase.nColumns 		= val.grids.y
	end
	if val.gridpadding then
		pVal.tLayoutBase.nRowPadding 	= val.gridpadding.x
		pVal.tLayoutBase.nColumnPadding = val.gridpadding.y
	end

	--panel property
	if val.classname == "TFPanel" or val.classname == "TFScrollView" or val.classname == "TFButtonGroup" or val.classname == "TFPageView" then
		pVal.tPanelProperty = {}
		pVal.tPanelProperty.bIsOpenClipping = val.bIsOpenClipping
		pVal.tPanelProperty.szTexturePath	= val.panelTexturePath
		pVal.tPanelProperty.nColorType		= val.colorType
		pVal.tPanelProperty.tSingleColor	= val.singleColor or ccc3(255, 255, 255)
		if val.BackGroundColor then
			pVal.tPanelProperty.tBeginColor		= val.BackGroundColor.beginColor or ccc3(255, 255, 255)
			pVal.tPanelProperty.tEndColor		= val.BackGroundColor.endColor or ccc3(255, 255, 255)
		end
		pVal.tPanelProperty.BgColorVector	= val.backGroundColorVector or ccp(1, 1)
		pVal.tPanelProperty.nBgColorOpacity	= val.bgColorOpacity or 255
	end

	-- button
	if val.classname == "TFButton" or val.classname == "TFTextButton" or val.classname == "TFGroupButton" then
		pVal.tButtonProperty = {}
		pVal.tButtonProperty.szNormalTexture		= val.normalTexture
		pVal.tButtonProperty.szPressedTexture		= val.pressedTexture
		pVal.tButtonProperty.szDisabledTexture		= val.disabledTexture
		pVal.bIsClickHightLight				= val.clickHighLight
	end

	if val.classname == "TFCheckBox" then
		pVal.tCheckBoxProperty = {}
		pVal.tCheckBoxProperty.nSelectedState			= val.selectedState
		pVal.tCheckBoxProperty.nClickType				= val.clickType
		pVal.tCheckBoxProperty.szBackGroundTexture			= val.backGroundTexture
		pVal.tCheckBoxProperty.szBackGroundSelectedTexture	= val.backGroundSelectedTexture
		pVal.tCheckBoxProperty.szBackGroundDisabledTexture	= val.backGroundDisabledTexture
		pVal.tCheckBoxProperty.szFrontCrossTexture			= val.frontCrossTexture
		pVal.tCheckBoxProperty.szFrontCrossDisabledTexture		= val.frontCrossDisabledTexture
	end

	if val.classname == "TFImage" then
		pVal.tImageProperty = {}
		pVal.tImageProperty.szTexturePath	= val.texturePath or val.url
	end

	if val.classname == "TFLabel" then
		pVal.tLabelProperty = {}
	end

	if val.classname == "TFIconLabel" or val.compPath then
		pVal.compPath = "luacomponents.common.TFIconLabel"
		pVal.tIconLabelProperty = {}
		pVal.tIconLabelProperty.szIcon			= val.Icon
		pVal.tIconLabelProperty.nIconVerticalAlign	= val.nIconVerticalAlign
		pVal.tIconLabelProperty.nGap			= val.nGap
		pVal.tIconLabelProperty.nIconDir		= val.nIconAlign
	end

	if val.classname == "TFLabelBMFont" then
		pVal.tLabelBMFontProperty = {}
		pVal.tLabelBMFontProperty.szFileName		= val.fileNameData
		pVal.tLabelBMFontProperty.szText 		= val.text
	end

	if val.classname == "TFTextField" then
		pVal.tTextFieldProperty = {}
		pVal.tTextFieldProperty.szPlaceHolder		= val.placeHolder
		if val.isCursor == nil then val.isCursor = true end
		pVal.tTextFieldProperty.bCursorEnabled	= val.isCursor
		pVal.tTextFieldProperty.bPasswordEnabled	= val.isPassword
		pVal.tTextFieldProperty.szPasswordChar	= val.passwordChar or "*"
		pVal.tTextFieldProperty.nMaxLength		= val.maxLength
		pVal.tTextFieldProperty.nKeyBoardType		= val.keyBoardType
	end

	if val.classname == "TFLoadingBar" then
		pVal.tLoadingBarProperty = {}
		pVal.tLoadingBarProperty.nPercent 		= val.percent
		pVal.tLoadingBarProperty.szTexture 		= val.texturePath
		pVal.tLoadingBarProperty.nDirection 		= val.direction
	end

	if val.classname == "TFSlider" then
		pVal.tSliderProperty = {}
		pVal.tSliderProperty.szBarTexture		= val.loadBarTexture
		pVal.tSliderProperty.szProgressTexture		= val.silderValueTexture
		pVal.tSliderProperty.szTexturenormal		= val.texturenormal
		pVal.tSliderProperty.szTexturepressed		= val.texturepressed
		pVal.tSliderProperty.szTexturedisable		= val.texturedisable
		pVal.tSliderProperty.nPercent			= val.percent
	end

	if val.classname == "TFScrollView" then
		pVal.tScrollViewProperty = {}
		pVal.tScrollViewProperty.bBounceEnabel 	= val.bounceEnable
		pVal.tScrollViewProperty.nDirection		= val.scrollWay
		if val.scrollArea then
			pVal.tScrollViewProperty.tInnerSize		= ccs(val.scrollArea.x, val.scrollArea.y)
		end
	end

	if val.classname == "TFPageView" then
		pVal.tPageViewProperty = {}
		pVal.tPageViewProperty.bBounceEnabel 	= val.bounceEnable
	end

	if val.classname == "TFButtonGroup" then
		pVal.tButtonGroupProperty = {}
		pVal.tButtonGroupProperty.nPriority		= val.layoutType or 1
		pVal.tButtonGroupProperty.nRowColumn	= val.count
		pVal.tButtonGroupProperty.szLayoutDirect	= val.layoutVector
		pVal.tButtonGroupProperty.tGap		= val.spacing
	end

	if val.classname == "TFGroupButton" then
		pVal.tGroupButtonProperty = {}
		pVal.tGroupButtonProperty.bIsSelected 		= val.isSelected
		pVal.tGroupButtonProperty.tSelectedColor	= val.selectedColor
		pVal.tGroupButtonProperty.tNormalColor		= val.fontColor
		pVal.tGroupButtonProperty.szNormalTexture	= val.normalTexture
		pVal.tGroupButtonProperty.szPressedTexture	= val.pressedTexture
	end

	if val.classname == "TFMovieClip" then
		pVal.tMovieClipProperty = {}
		pVal.tMovieClipProperty.bIsPlay			= val.isPlay
		pVal.tMovieClipProperty.szFileName		= val.fileName
		pVal.tMovieClipProperty.nLoop			= val.cycles or -1
		pVal.tMovieClipProperty.nDelay			= val.delay or 0
		pVal.tMovieClipProperty.szAnimationName	= val.animationName
	end

	if val.classname == "TFArmature" then
		pVal.tArmatureProperty = {}
		pVal.tArmatureProperty.bIsPlay			= val.isPlay
		pVal.tArmatureProperty.szFileName		= val.fileName
		pVal.tArmatureProperty.nLoopType		= val.loopType
		pVal.tArmatureProperty.nDuration		= val.duration
		pVal.tArmatureProperty.nTween			= val.tween
		pVal.tArmatureProperty.nRate			= val.rate
		pVal.tArmatureProperty.szArmatureName	= val.animationName
		pVal.tArmatureProperty.szAnimationName	= val.actionName
		pVal.tArmatureProperty.szArmaturePath 	= val.fileName
	end

	if val.classname == "TFParticle" then
		pVal.tMEParticleProperty = {}
		pVal.tMEParticleProperty.szParticlePath	= val.fileName
		pVal.tMEParticleProperty.bIsPlaying		= val.isPlay
		pVal.tMEParticleProperty.texturePath		= val.texturePath
		pVal.tMEParticleProperty.EmitterMode		= val.EmitterMode
		-- model A
		if val.EmitterMode == kCCParticleModeGravity then
			pVal.tMEParticleProperty.Gravity		= val.Gravity
			pVal.tMEParticleProperty.Speed			= val.Speed.x
			pVal.tMEParticleProperty.SpeedVar		= val.Speed.y
			pVal.tMEParticleProperty.TangentialAccel	= val.TangentialAccel.x
			pVal.tMEParticleProperty.TangentialAccelVar	= val.TangentialAccel.y
			pVal.tMEParticleProperty.RadialAccel		= val.RadialAccel.x
			pVal.tMEParticleProperty.RadialAccelVar	= val.RadialAccel.y
		else
		-- model B
			pVal.tMEParticleProperty.StartRadius		= val.MaxRadius.x
			pVal.tMEParticleProperty.StartRadiusVar	= val.MaxRadius.y
			pVal.tMEParticleProperty.EndRadius		= val.MinRadius.x
			pVal.tMEParticleProperty.EndRadiusVar		= val.MinRadius.y
			pVal.tMEParticleProperty.RotatePerSecond	= val.RotateSecond.x
			pVal.tMEParticleProperty.RotatePerSecondVar	= val.RotateSecond.y
		end
		--Base attribute
		pVal.tMEParticleProperty.Duration		= val.duration
		pVal.tMEParticleProperty.SourcePosition	= val.SourcePosition
		pVal.tMEParticleProperty.PosVar		= val.PosVar
		pVal.tMEParticleProperty.Life			= val.Life.x
		pVal.tMEParticleProperty.LifeVar		= val.Life.y
		pVal.tMEParticleProperty.Angle			= val.Angle.x
		pVal.tMEParticleProperty.AngleVar		= val.Angle.y
		pVal.tMEParticleProperty.StartSize		= val.StartSize.x
		pVal.tMEParticleProperty.StartSizeVar		= val.StartSize.y
		pVal.tMEParticleProperty.EndSize		= val.EndSize.x
		pVal.tMEParticleProperty.EndSizeVar		= val.EndSize.y
		pVal.tMEParticleProperty.StartColor		= val.StartColor
		pVal.tMEParticleProperty.StartColorVar		= val.StartColorVar
		pVal.tMEParticleProperty.EndColor		= val.EndColor
		pVal.tMEParticleProperty.EndColorVar		= val.EndColorVar
		pVal.tMEParticleProperty.StartSpin		= val.StartSpin.x
		pVal.tMEParticleProperty.StartSpinVar		= val.StartSpin.y
		pVal.tMEParticleProperty.EndSpin		= val.EndSpin.x
		pVal.tMEParticleProperty.EndSpinVar		= val.EndSpin.y
		pVal.tMEParticleProperty.TotalParticles		= val.TotalParticles
		-- pVal.tMEParticleProperty.EmissionRate		= val.
	end

	if val.classname == "TFNew" then
		pVal.tMENewProperty = {}
	end

	return pVal
end
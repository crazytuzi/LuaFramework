local TFUIBase 					= TFUIBase
local TFUIBase_setFuncs 		= TFUIBase_setFuncs
local TFUIBase_setFuncs_new 	= TFUIBase_setFuncs_new
local TFUI_VERSION_MEEDITOR 	= TFUI_VERSION_MEEDITOR
local TFUI_VERSION_NEWMEEDITOR 	= TFUI_VERSION_NEWMEEDITOR
local TFUI_VERSION_ALPHA 		= TFUI_VERSION_ALPHA
local TF_TEX_TYPE_LOCAL 		= TF_TEX_TYPE_LOCAL
local TF_TEX_TYPE_PLIST 		= TF_TEX_TYPE_PLIST
local ccc3 						= ccc3
local ccp 						= ccp
local bit_and 					= bit_and
local bit_rshift				= bit_rshift
local CCSizeMake 				= CCSizeMake
local CCRectMake 				= CCRectMake
local string 					= string

function TFUIBase:initMEPanel(pval, parent)
	if TFUIBase.version == TFUI_VERSION_COCOSTUDIO then
		self:initMEPanel_COCOSTUDIO(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_ALPHA then
		self:initMEPanel_ALPHA(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_MEEDITOR then
		self:initMEPanel_MEEDITOR(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_NEWMEEDITOR then
		self:initMEPanel_NEWMEEDITOR(pval, parent)
	end
end

function TFUIBase:initMEPanel_MEEDITOR(pval, parent)
	local val = pval
	self:initMEWidget(pval, parent)
	if val['clipAble'] and self.setClippingEnabled then
		local bIsClipAble = val['clipAble'] == "True"
		self:setClippingEnabled(bIsClipAble)
	end

	if val['uipanelviewmodel'] and tolua.type(val['uipanelviewmodel']) ~= "string" and self.setLayoutType then 
		--[[
		0:abs 1:v 2:h 3:r
		]]
		local tParams = val['uipanelviewmodel']
		local nType = tParams.nType
		if not self.bIsBigMap then
			self:setLayoutType(nType + 0)
		end

		if tParams.rows then 
			self:setRows(tParams.rows)
		end

		if tParams.rowPadding then 
			self:setRowPadding(tParams.rowPadding)
		end

		if tParams.columns then 
			self:setColumns(tParams.columns)
		end

		if tParams.columnPadding then 
			self:setColumnPadding(tParams.columnPadding)
		end

		if tParams.gridPriority then
			self:setGridLayoutPriority(tParams.gridPriority)
		end
	end

	if val['bIsOpenClipping'] ~= nil then
		local bRet = val['bIsOpenClipping'] == 'True'
		self:setClippingEnabled(bRet)
	end

	if val['panelTexturePath'] and self.setBackGroundImage then
		local textureType = TF_TEX_TYPE_LOCAL
		if val['panelTexturePath_plist'] and val['panelTexturePath_plist'] ~= "" then
			TFUIBase:loadPlistOrPvrTexture( val['panelTexturePath_plist'] )
			textureType = TF_TEX_TYPE_PLIST
		end

		self:setBackGroundImage(val['panelTexturePath'], textureType)
	end

	if val['backGroundScale9Enable'] and self.setBackGroundImageScale9Enabled then
		local bIsNotScale9Enable = val['backGroundScale9Enable'] == "False"
		if not bIsNotScale9Enable then 
			self:setBackGroundImageScale9Enabled(true)
			local t9Param = {}
			string.gsub(val['backGroundScale9Enable'], '(%w*):([#A-Za-z0-9]*)', function(szKey, szVal)
				if szKey then 
					t9Param[szKey] = szVal
				end
			end)
			local cx = t9Param['capInsetsX'] + 0
			local cy = t9Param['capInsetsY'] + 0
			local cw = t9Param['capInsetsWidth'] + 0
			local ch = t9Param['capInsetsHeight'] + 0
			self:setBackGroundImageCapInsets(CCRectMake(cx, cy, cw, ch))
		end
	end	

	if val['colorType'] and self.setBackGroundColorType then
		local szParam = val.colorType
		local nColorType = szParam[1] + 0
		local tColorParam = {}
		string.gsub(szParam, '(%w*):([#%-A-Za-z0-9%.]*)', function(szKey, szVal)
			if szKey then 
				tColorParam[szKey] = szVal
			end
		end)

		self:setBackGroundColorType(nColorType)
		if nColorType == 2 then
			local color = tColorParam['GraduallyChangingColorStart']
			local scr = ('0x' .. color['4:5']) + 0
			local scg = ('0x' .. color['6:7']) + 0
			local scb = ('0x' .. color['8:9']) + 0

			color = tColorParam['GraduallyChangingColorEnd']
			local ecr = ('0x' .. color['4:5']) + 0
			local ecg = ('0x' .. color['6:7']) + 0
			local ecb = ('0x' .. color['8:9']) + 0

			self:setBackGroundColor(ccc3(scr, scg, scb), ccc3(ecr, ecg, ecb))
			if (tColorParam['vectorX'] or tColorParam['vectorY']) and self.setBackGroundColorVector then 
				print(tColorParam['vectorX'], tColorParam['vectorY'], self:getName())
				local x = tColorParam['vectorX'] + 0 or 0
				local y = tColorParam['vectorY'] + 0 or 0
				self:setBackGroundColorVector(ccp(x, y))
			end	
		elseif nColorType == 1 then
			local color = tColorParam['SingleColor']
			local r = ('0x' .. color['4:5']) + 0
			local g = ('0x' .. color['6:7']) + 0
			local b = ('0x' .. color['8:9']) + 0
			self:setBackGroundColor(ccc3(r, g, b))
		end

		if val['bgColorOpacity'] and self.setBackGroundColorOpacity then
			self:setBackGroundColorOpacity(val['bgColorOpacity'] + 0)
		end
	end

	if val['gridEnabled'] and self.setGridLayoutEnabled then
		self:setGridLayoutEnabled(val['gridEnabled'])
	end



	self:initMEColorProps(pval, parent)
	
	if val['sizeType'] ~= nil and val['sizeType'] + 0 == 4 then
		self:setSizeType(val['sizeType'])
		self:setDesignResolutionSize(val['DesignWidth'] + 0, val['DesignHeight'] + 0, val['DesignType'] + 0)
	end

	self:initBaseControl(pval, parent)
end

function TFUIBase:initMEPanel_NEWMEEDITOR(pval, parent)
	self:initMEWidget(pval, parent)
	local val = pval.tPanelProperty
	local tLayout = pval.tLayoutBase


	if val.bIsOpenClipping ~= nil and self.setClippingEnabled then
		self:setClippingEnabled(val.bIsOpenClipping)
	end

	if tLayout then
		if not self.bIsBigMap and tLayout.nLayoutType then
			self:setLayoutType(tLayout.nLayoutType)
		end
		if tLayout.nRows then
			self:setRows(tLayout.nRows)
			self:setColumns(tLayout.nColumns)
		end
		if tLayout.nRowPadding then
			self:setRowPadding(tLayout.nRowPadding)
			self:setColumnPadding(tLayout.nColumnPadding)
		end
		if tLayout.nGridPriority then
			self:setGridLayoutPriority(tLayout.nGridPriority)
		end
	end

	if val.nColorType and self.setBackGroundColorType then
		self:setBackGroundColorType(val.nColorType)
		if val.nColorType == TF_LAYOUT_COLOR_SOLID then
			self:setBackGroundColor(val.tSingleColor)
		elseif val.nColorType == TF_LAYOUT_COLOR_GRADIENT then
			self:setBackGroundColor(val.tBeginColor, val.tEndColor)
			self:setBackGroundColorVector(val.BgColorVector)
		end
		self:setBackGroundColorOpacity(val.nBgColorOpacity)
	end
	
	if self.setBackGroundImage and val.szTexturePath then
		self:setBackGroundImage(val.szTexturePath)
	end
	
	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end

function TFUIBase:initMEPanel_COCOSTUDIO(pval, parent)
	local val = pval.options
	self:initMEWidget(pval, parent)
	if val['clipAble'] and self.setClippingEnabled then
		self:setClippingEnabled(val['clipAble'])
	end

	if val['backGroundScale9Enable'] and self.setBackGroundImageScale9Enabled then
		self:setBackGroundImageScale9Enabled(val['backGroundScale9Enable'])
	end

	if (val['vectorX'] or val['vectorY']) and self.setBackGroundColorVector then 
		local x = val['vectorX'] or 0
		local y = val['vectorY'] or 0
		self:setBackGroundColorVector(ccp(x, y))
	end	

	-- generator by cocostudio
	if val['bgColorR'] then
		local cr 			= val["bgColorR"]
		local cg 			= val["bgColorG"]
		local cb 			= val["bgColorB"]
				
		local scr 			= val["bgStartColorR"]
		local scg 			= val["bgStartColorG"]
		local scb 			= val["bgStartColorB"]
				
		local ecr 			= val["bgEndColorR"]
		local ecg 			= val["bgEndColorG"]
		local ecb 			= val["bgEndColorB"]
		
		local co 			= val["bgColorOpacity"]
		local colorType 	= val["colorType"]

		self:setBackGroundColorType(colorType)
		if colorType == 2 then
			self:setBackGroundColor(ccc3(scr, scg, scb),ccc3(ecr, ecg, ecb))
		elseif colorType == 1 then
			self:setBackGroundColor(ccc3(cr, cg, cb))
		end
		self:setBackGroundColorOpacity(co)
	end	

	local backGroundImageDic = val['backGroundImageData']	
	if backGroundImageDic and backGroundImageDic.path then
		local backGroundImageType = backGroundImageDic.resourceType
		if backGroundImageType == 0 then
			local path = backGroundImageDic.path
			self:setBackGroundImage(path)
		else
			me.FrameCache:addSpriteFramesWithFile(backGroundImageDic.plistFile)
			self:setBackGroundImage(backGroundImageDic.path, TF_TEX_TYPE_PLIST)
		end
	end

	if val['backGroundScale9Enable'] and val['capInsetsX'] then
		local cx = val['capInsetsX']
		local cy = val['capInsetsY']
		local cw = val['capInsetsWidth']
		local ch = val['capInsetsHeight']
		self:setBackGroundImageCapInsets(CCRectMake(cx, cy, cw, ch))
	end

	if val['gridEnabled'] then
		self:setGridLayoutEnabled(val['gridEnabled'])
	end
	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end

function TFUIBase:initMEPanel_ALPHA(pval, parent)
	local val = pval
	self:initMEWidget(pval, parent)
	if val['isClip'] and self.setClippingEnabled then
		self:setClippingEnabled(val['isClip'])
	end

	if val['layoutType'] and self.setLayoutType then
		self:setLayoutType(val.layoutType)
	end 

	if val['backGroundScale9Enable'] and self.setBackGroundImageScale9Enabled then
		self:setBackGroundImageScale9Enabled(val['backGroundScale9Enable'])
	end

	if (val['vectorX'] or val['vectorY']) and self.setBackGroundColorVector then 
		local x = val['vectorX'] or 0
		local y = val['vectorY'] or 0
		self:setBackGroundColorVector(ccp(x, y))
	end	

	-- generator by cocostudio
	if val['bgColorR'] then
		local cr 			= val["bgColorR"]
		local cg 			= val["bgColorG"]
		local cb 			= val["bgColorB"]
				
		local scr 			= val["bgStartColorR"]
		local scg 			= val["bgStartColorG"]
		local scb 			= val["bgStartColorB"]
				
		local ecr 			= val["bgEndColorR"]
		local ecg 			= val["bgEndColorG"]
		local ecb 			= val["bgEndColorB"]
		
		local co 			= val["bgColorOpacity"]
		local colorType 	= val["colorType"]

		self:setBackGroundColorType(colorType)
		if colorType == 2 then
			self:setBackGroundColor(ccc3(scr, scg, scb),ccc3(ecr, ecg, ecb))
		elseif colorType == 1 then
			self:setBackGroundColor(ccc3(cr, cg, cb))
		end
		self:setBackGroundColorOpacity(co)
	end	

	if val['backGroundScale9Enable'] and val['capInsetsX'] then
		local cx = val['capInsetsX']
		local cy = val['capInsetsY']
		local cw = val['capInsetsWidth']
		local ch = val['capInsetsHeight']
		self:setBackGroundImageCapInsets(CCRectMake(cx, cy, cw, ch))
	end

	if val['gridEnabled'] then
		self:setGridLayoutEnabled(val['gridEnabled'])
	end
	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end
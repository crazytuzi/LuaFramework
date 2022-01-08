local TFUIBase 					= TFUIBase
local TFUI_VERSION_MEEDITOR 	= TFUI_VERSION_MEEDITOR
local TFUI_VERSION_NEWMEEDITOR 	= TFUI_VERSION_NEWMEEDITOR
local TFUI_VERSION_ALPHA 		= TFUI_VERSION_ALPHA
local TF_TEX_TYPE_LOCAL 		= TF_TEX_TYPE_LOCAL
local TF_TEX_TYPE_PLIST 		= TF_TEX_TYPE_PLIST
local ccc3 						= ccc3
local CCSizeMake 				= CCSizeMake
local string 					= string

function TFUIBase:initMEButtonGroup(pval, parent)
	if TFUIBase.version == TFUI_VERSION_MEEDITOR then
		self:initMEButtonGroup_MEEDITOR(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_NEWMEEDITOR then
		self:initMEButtonGroup_NEWMEEDITOR(pval, parent)
	end
end

function TFUIBase:initMEButtonGroup_MEEDITOR( pVal, parent )
	self:initMEPanel(pVal, parent)

	if pVal['touchAble'] and self.setTouchEnabled then 
		local bIsTouchAble = pVal['touchAble'] =="True"
		self:setTouchEnabled(bIsTouchAble)
	end


	local val = {}
	if pVal['buttonGroupModel'] then
		val = pVal['buttonGroupModel']
	end

	if val['nVGap'] and self.setVGap then
		self:setVGap(val.nVGap)
	end

	if val['nHGap'] and self.setHGap then
		self:setHGap(val.nHGap)
	end

	if val['gap'] and self.setGap then
		self:setGap(val.gap)
	end

	if val['szLayoutDirect'] and self.setLayoutDirect then
		self:setLayoutDirect(val.szLayoutDirect)
	end

	if val['szLayoutType'] and self.setLayoutType then
		self:setLayoutType(val.szLayoutType)
	end

	if val['nRow'] then
		if val.szLayoutType == 'vertical' then
			self:setColumn(val.nRow)
		else
			self:setRows(val.nRow)
		end
	end

	-- if val['nColumn'] and self.setColumn then
	-- 	self:setColumn(val.nColumn)
	-- end

	if val['tChildren'] then
		tParams = val['tChildren']
		for i, v in pairs(tParams) do
			local groupBtn = TFGroupButton:create()
			local index = v.nIndex or -1
			if v.szNormalTexture and v.szNormalTexture ~= "" then
				local textureType = TF_TEX_TYPE_LOCAL
				if v.szNormalTexture_plist and v.szNormalTexture_plist ~= "" then
					TFUIBase:loadPlistOrPvrTexture( v.szNormalTexture_plist )
					textureType = TF_TEX_TYPE_PLIST
				end

				groupBtn:setNormalTexture(v.szNormalTexture, textureType)
			end
			if v.szPressedTexture and  v.szPressedTexture ~= "" then
				local textureType = TF_TEX_TYPE_LOCAL
				if v.szPressedTexture_plist and v.szPressedTexture_plist ~= "" then
					TFUIBase:loadPlistOrPvrTexture( v.szPressedTexture_plist )
					textureType = TF_TEX_TYPE_PLIST
				end

				groupBtn:setPressedTexture(v.szPressedTexture, textureType)
			end

			if v.szText then
				groupBtn:setText(v.szText)
			end
			if v.bIsSelected ~= nil then
				groupBtn:setSelect(v.bIsSelected)
			end
			if v.FontSize then
				groupBtn:setFontSize(v.FontSize)
			end
			if v.FontName then
				groupBtn:setFontName(v.FontName)
			end
			if v.FontColor then
				local r = ('0x' .. v.FontColor['4:5']) + 0
				local g = ('0x' .. v.FontColor['6:7']) + 0
				local b = ('0x' .. v.FontColor['8:9']) + 0
				groupBtn:setNormalColor(ccc3(r, g, b))
			end
			if v.SelectedColor then
				local r = ('0x' .. v.SelectedColor['4:5']) + 0
				local g = ('0x' .. v.SelectedColor['6:7']) + 0
				local b = ('0x' .. v.SelectedColor['8:9']) + 0
				groupBtn:setSelectedColor(ccc3(r, g, b))
			end
			if v.ButtonSize then
				groupBtn:setSize(CCSizeMake(v.ButtonSize.width, v.ButtonSize.height))
			end
			if v.backGroundScale9Enable then
				local bIsNotScale9Enable = v.backGroundScale9Enable == "False"
				if not bIsNotScale9Enable then 
					groupBtn:setScale9Enabled(true)
					local t9Param = {}
					string.gsub(v.backGroundScale9Enable, '(%w*):([#A-Za-z0-9]*)', function(szKey, szVal)
						if szKey then 
							t9Param[szKey] = szVal
						end
					end)
					local cx = t9Param['capInsetsX'] + 0
					local cy = t9Param['capInsetsY'] + 0
					local cw = t9Param['capInsetsWidth'] + 0
					local ch = t9Param['capInsetsHeight'] + 0
					local rect = CCRectMake(cx, cy, cw, ch)
					groupBtn:setCapInsets(rect)
				end
			end
			self:addGroupButton(groupBtn)
		end
		self:doLayout()
	end

	self:initMEColorProps(pVal, parent)
end

function TFUIBase:initMEButtonGroup_NEWMEEDITOR( pval, parent )
	self:initMEPanel(pval, parent)
--[[

		pVal.tButtonGroupProperty.nPriority		= val.layoutType
		pVal.tButtonGroupProperty.nRowColumn	= val.count
		pVal.tButtonGroupProperty.szLayoutDirect	= val.layoutVector
		pVal.tButtonGroupProperty.tGap		= val.spacing
]]
	local val = {}
	val = pval.tButtonGroupProperty

	if val.tGap and self.setHGap then
		self:setHGap(val.tGap.x)
	end

	if val.tGap and self.setVGap then
		self:setVGap(val.tGap.y)
	end

	if val.nPriority and self.setLayoutType then
		if val.nPriority == 0 then
			self:setLayoutType("horizontal")
		elseif val.nPriority == 1 then
			self:setLayoutType("vertical")
		end
	end

	if val.szLayoutDirect and self.setLayoutDirect then
		local szType = val.szLayoutDirect
		if val.szLayoutDirect == 0 then
			szType = "left_top"
		elseif val.szLayoutDirect == 1 then
			szType = "right_top"
		elseif val.szLayoutDirect == 2 then
			szType = "left_bottom"
		elseif val.szLayoutDirect == 3 then
			szType = "right_bottom"
		end
		self:setLayoutDirect(szType)
	end

	if val.nRowColumn then
		if val.nPriority == 1 then
			self:setColumn(val.nRowColumn)
		else
			self:setRows(val.nRowColumn)
		end
	end

	self:initMEColorProps(pval, parent)
	-- self:initBaseControl(pval, parent)
end

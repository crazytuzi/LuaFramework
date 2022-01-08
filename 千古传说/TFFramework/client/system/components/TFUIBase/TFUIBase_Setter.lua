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


local setFuncs = {}
TFUIBase_setFuncs = setFuncs

local cs
setFuncs["TFWidget"] = {
	['tag'] 				= function(obj, val) if val then obj:setTag(val) end end,
	['ignoreSize'] 			= function(obj, val) if obj.ignoreContentAdaptWithSize then obj:ignoreContentAdaptWithSize(val == 'True') end end,
	['touchAble'] 			= function(obj, val) if val then obj:setTouchEnabled(val == 'True') end end,
	['name'] 				= function(obj, val) if val and val ~= '' then obj:setName(val) end end,
	['scaleX'] 				= function(obj, val) if val then obj:setScaleX(val + 0) end end,
	['scaleY'] 				= function(obj, val) if val then obj:setScaleY(val + 0) end end,
	['rotation'] 			= function(obj, val) if val then obj:setRotation(val + 0) end end,
	['rotateX'] 			= function(obj, val) if val then obj:setRotationX(val + 0) end end,
	['rotateY'] 			= function(obj, val) if val then obj:setRotationY(val + 0) end end,
	['ZOrder'] 				= function(obj, val) if val and val ~= '0' then obj:setZOrder(val + 0) end end,
	['baseNum'] 			= function(obj, val) if val and val ~= '0' then obj:setZOrder(val + 0) end end,
	['layoutType'] 			= function(obj, val) if val and val ~= '0' then obj:setLayoutType(val + 0) end end,
	['opacity'] 			= function(obj, val) if val and obj.setOpacity then obj:setOpacity(val) end end,
	['flipX'] 				= function(obj, val) if val and val ~= 'False' then obj:setFlipX(true) end end,
	['flipY'] 				= function(obj, val) if val and val ~= 'False' then obj:setFlipY(true) end end,
	['UILayoutViewModel'] 	= function(obj, val) if val then obj:setLayoutByTable(val) end end,
	['layout'] 				= function(obj, val) if val then obj:setLayoutByTable(val) end end,
	['DiyPropertyViewModel']= function(obj, val) if val and type(val) == 'table' then obj.UIEditorData = val end end,
	['size'] 				= function(obj, ignoreSize, width, height)
								if ignoreSize == false or ignoreSize == 'False' then 
									if width or height then 
										width = width or 0
										height = height or 0
										cs = obj:getSize()
										width = width or cs.width
										height = height or cs.height
										obj:setSize(ccs(width, height))
										if obj.setRichTextSize then
											obj:setRichTextSize(ccs(width, height))
										end
									end
								end
							end,
	['sizeType'] 		= function(obj, sizeType, x, y)
							if sizeType == '1' then 
								obj:setSizeType(TF_SIZE_PERCENT)
								x = x or 0
								y = y or 0
								obj:setSizePercent(ccp((x+0)/100, (y+0)/100))
								if obj.setRichTextSize then
									obj:setRichTextSize(obj:getSize())
								end
							end
						end,
	['position'] 		= function(obj, x, y) 
							if x or y then 
								x = x or 0
								y = y or 0
								obj:setPosition(ccp(x, y))
							end
						end,
	['visible'] 		= function(obj, val)
							local bIsVisible = val == "True" or val == nil or val == true
							obj:setVisible(bIsVisible)
						end,
	['HitType'] 		= function(obj, val) 
							if not val or val.nHitType == 0 then return end
							obj:setHitType(val.nHitType)
							if val.nHitType == 1 then
								val.nHitWidth = val.nHitWidth or 0
								val.nHitHeight =  val.nHitHeight or 0
								val.nXpos = val.nXpos or 0
								val.nYpos =  val.nYpos or 0
								obj:setHitRect(ccs(val.nHitWidth, val.nHitHeight), ccp(val.nXpos, val.nYpos))
							end
							if val.nHitType == 2 and val.nRadius then obj:setHitRadius(val.nRadius) end
						end,
	['ColorMixing'] 	= function(obj, color) 
							if obj.setColor and color and color ~= '#FFFFFFFF' then
								local r = ('0x' .. color['4:5']) + 0
								local g = ('0x' .. color['6:7']) + 0
								local b = ('0x' .. color['8:9']) + 0
								obj:setColor(ccc3(r, g, b))
							end 
						end,
	['anchorPoint'] 	= function(obj, ax, ay) 
							if ax or ay then 
								ax = ax or 0.5
								ay = ay or 0.5
								obj:setAnchorPoint(ccp(ax, ay))
							end 
						end,
	['PanelRelativeSizeModel'] 	= function(obj, model) 
							if model and type(model) == 'table' then
								if model['PanelRelativeEnable'] and obj:getSizeType() == TF_SIZE_ABSOLUTE then
									local nPer = model['PanelRelativeSizePercentage'] or 100
									local size = me.EGLView:getDesignResolutionSize()
									obj:setSize(ccs(size.width * nPer / 100, size.height * nPer / 100))
								end
							end 
						end,
	-- todo different class has different init blend
	['srcBlendFunc'] 	= function(obj, val) if val and obj.setBlendFunc then 
							local blend = ccBlendFunc()
							blend.src = val
							blend.dst = obj:getBlendFunc().dst + 0
							obj:setBlendFunc(blend) 
							end 
						end,
	['dstBlendFunc'] 	= function(obj, val) if val and obj.setBlendFunc then 
							local blend = ccBlendFunc()
							blend.src = obj:getBlendFunc().src + 0
							blend.dst = val
							obj:setBlendFunc(blend) 
							end 
						end,
	-- todo remove
	['percentPosition'] = function(obj, val) 
							if not val then return end
							local tNums = string.split(val, ',')
							string.gsub(tNums[1], '(.-)%%', function(num) tNums[1] = num / 100 end)
							string.gsub(tNums[2], '(.-)%%', function(num) tNums[2] = num / 100 end)
							obj:setPositionType(TF_POSITION_PERCENT)
							obj:setPositionPercent(ccp(tNums[1], tNums[2]))
						end,
	['percentSize'] 	= function(obj, val) 
							if val then
								local tNums = string.split(val, ',')
								string.gsub(tNums[1], '(.-)%%', function(num) tNums[1] = num / 100 end)
								string.gsub(tNums[2], '(.-)%%', function(num) tNums[2] = num / 100 end)
								obj:setSizeType(TF_SIZE_PERCENT)
								obj:setSizePercent(ccp(tNums[1], tNums[2]))
							end 
						end,
	
}

setFuncs["TFWidget"].__index = setFuncs["TFWidget"]

setFuncs["TFImage"] 		= setmetatable({}, setFuncs["TFWidget"])
setFuncs["TFLabel"] 		= setmetatable({}, setFuncs["TFWidget"])
setFuncs["TFPanel"] 		= setmetatable({}, setFuncs["TFWidget"])
setFuncs["TFButton"] 		= setmetatable({}, setFuncs["TFWidget"])
setFuncs["TFArmature"] 		= setmetatable({}, setFuncs["TFWidget"])
setFuncs["TFCheckBox"] 		= setmetatable({}, setFuncs["TFWidget"])
setFuncs["TFCoverFlow"] 	= setmetatable({}, setFuncs["TFWidget"])
setFuncs["TFGroupButton"] 	= setmetatable({}, setFuncs["TFWidget"])
setFuncs["TFButtonGroup"] 	= setmetatable({}, setFuncs["TFWidget"])
setFuncs["TFLabelBMFont"] 	= setmetatable({}, setFuncs["TFWidget"])
setFuncs["TFListView"] 		= setmetatable({}, setFuncs["TFWidget"])
setFuncs["TFLoadingBar"] 	= setmetatable({}, setFuncs["TFWidget"])
setFuncs["TFMovieClip"] 	= setmetatable({}, setFuncs["TFWidget"])
setFuncs["TFPageView"] 		= setmetatable({}, setFuncs["TFWidget"])
setFuncs["TFParticle"] 		= setmetatable({}, setFuncs["TFWidget"])
setFuncs["TFScrollView"] 	= setmetatable({}, setFuncs["TFWidget"])
setFuncs["TFSlider"] 		= setmetatable({}, setFuncs["TFWidget"])
setFuncs["TFTableView"] 	= setmetatable({}, setFuncs["TFWidget"])
setFuncs["TFTableViewCell"] = setmetatable({}, setFuncs["TFWidget"])
setFuncs["TFTextField"] 	= setmetatable({}, setFuncs["TFWidget"])
setFuncs["TFRichText"] 		= setmetatable({}, setFuncs["TFWidget"])

-- override touchAble
setFuncs["TFImage"]['touchAble'] 		= function(obj, val) if val == 'True' then obj:setTouchEnabled(true) end end
setFuncs["TFLabel"]['touchAble'] 		= function(obj, val) if val == 'True' then obj:setTouchEnabled(true) end end
setFuncs["TFPanel"]['touchAble'] 		= function(obj, val) if val == 'True' then obj:setTouchEnabled(true) end end
setFuncs["TFArmature"]['touchAble'] 	= function(obj, val) if val == 'True' then obj:setTouchEnabled(true) end end
setFuncs["TFLabelBMFont"]['touchAble'] 	= function(obj, val) if val == 'True' then obj:setTouchEnabled(true) end end
setFuncs["TFMovieClip"]['touchAble'] 	= function(obj, val) if val == 'True' then obj:setTouchEnabled(true) end end
setFuncs["TFParticle"]['touchAble'] 	= function(obj, val) if val == 'True' then obj:setTouchEnabled(true) end end
setFuncs["TFTextField"]['touchAble'] 	= function(obj, val) if val == 'True' then obj:setTouchEnabled(true) end end

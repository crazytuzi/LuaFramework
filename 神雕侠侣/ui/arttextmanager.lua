local manager = {}
local dlg = {}
local singledialog = require "ui.singletondialog"
setmetatable(dlg, singledialog)
dlg.__index = dlg
function dlg.new()
	local self = {}
	setmetatable(self, dlg)
	function self.GetLayoutFileName()
		return "familygouhuo.layout"
	end
	require "ui.dialog".OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.plus = winMgr:getWindow("familygouhuo/plus")
	self.nums = {}
	for i = 0, 3 do
		table.insert(self.nums, winMgr:getWindow("familygouhuo/num"..i))
	end
	return self
end

local function getNumberEffectid(num) 
	return "geffect/number/addexp/"..num
	--[[
    local pEffectConfig
    if num == 0 then
        pEffectConfig = knight.gsp.effect.GetCcoloreffectTableInstance():getRecorder(10)
    else
        pEffectConfig = knight.gsp.effect.GetCcoloreffectTableInstance():getRecorder(num)
    end
    return pEffectConfig.green
    switch (color) {
        case 1:
            return pEffectConfig->red;
        case 2:
            return pEffectConfig->yellow;
        case 3:
            return pEffectConfig->blue;
        case 4:
           
        default:
            break;
    }
    return 0;
    --]]
end

local function getPlusEffectid()
	return "geffect/number/addexp/plus"
--	return getNumberEffectid(100)
end

local function shownum(val)
	LogInsane("shownum="..val)
	local d = dlg:getInstance()
	local curval = val
 	
 	local i = 0
 	local t = {}
 	while curval ~= 0 and i < 10 do
 		i = i + 1
 		local a = math.floor(curval % 10)
 		table.insert(t, a)
 		curval = math.floor(curval / 10)
 	end
 	if #t > 0 then
 		GetGameUIManager():AddUIEffect(d.plus, getPlusEffectid(), false)
 	end
 	for j = 1, #t do
 		d.nums[j]:setVisible(true)
 		GetGameUIManager():AddUIEffect(d.nums[j], 
 			getNumberEffectid(t[#t - j + 1]) , false)
 	end
 	for j = #t+1, #d.nums do
 		d.nums[j]:setVisible(false)
 	end
end

return shownum
--KnightPageBase.lua

local KnightPageBase = class("KnightPageBase", function (  )
	return CCSPageCellBase:create()
end)

function KnightPageBase._create_( page, jsonFile, baseId, fragmentId )
	if not page then 
		return nil
	end

	page:initData(baseId, fragmentId)
	if jsonFile and page then 
		page:initWithJson(jsonFile)
		page._jsonFile = jsonFile
	end
	page:_afterLayerLoad()

	return page
end

function KnightPageBase:ctor( ... )
	self._jsonFile = nil
	self._baseId = 0
	self._fragmentId = 0
end

function KnightPageBase:initData( baseId, fragmentId )
	self._baseId = baseId
	self._fragmentId = fragmentId
end

function KnightPageBase:delayLoad( jsonFile )
	self._jsonFile = jsonFile
	
end

function KnightPageBase:doDelayLoad(  )
	if self._jsonFile then
		self:initWithJson(self._jsonFile)
	end

	self:_afterLayerLoad()
end

function KnightPageBase:_afterLayerLoad( ... )
	self:afterLayerLoad()
end

function KnightPageBase:afterLayerLoad( ... )
	
end


return KnightPageBase

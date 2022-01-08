local nMax = 4

local objCCp	= {}
local nCCpIndex = 1


local objSize	= {}
local nSizeIndex = 1

local objRect	= {}
local nRectIndex = 1

local objColor	= {}
local nColorIndex = 1

local _CCSize = CCSize
--local _CCRect = CCRect

function ccp(fX ,fY)

	if objCCp[nCCpIndex] then
		objCCp[nCCpIndex].x = fX
		objCCp[nCCpIndex].y = fY
	else
		objCCp[nCCpIndex] = CCPoint:new(fX , fY);
	end

	local objRet = objCCp[nCCpIndex]
	if nCCpIndex >= nMax then
		nCCpIndex = 1
	else
		nCCpIndex = nCCpIndex + 1
	end
	return objRet
end


function CCSize(fWidth , fHeight)
	if objSize[nSizeIndex] then
		objSize[nSizeIndex].width = fWidth
		objSize[nSizeIndex].height = fHeight
	else
		objSize[nSizeIndex] = _CCSize(fWidth , fHeight);
	end

	local objRet = objSize[nSizeIndex]
	if nSizeIndex >= nMax then
		nSizeIndex = 1
	else
		nSizeIndex = nSizeIndex + 1
	end
	return objRet
end
CCSizeMake = CCSize

function CCRectMake(fX , fY , fWidth , fHeight)

	if objRect[nRectIndex] then
		objRect[nRectIndex].origin.x = fX
		objRect[nRectIndex].origin.y = fY
		objRect[nRectIndex].size.width = fWidth
		objRect[nRectIndex].size.height = fHeight
	else
		objRect[nRectIndex] = CCRect();--fX , fY , nWidth , nHeight
		objRect[nRectIndex].origin.x = fX
		objRect[nRectIndex].origin.y = fY
		objRect[nRectIndex].size.width = fWidth
		objRect[nRectIndex].size.height = fHeight
	end

	local objRet = objRect[nRectIndex]
	if nRectIndex >= nMax then
		nRectIndex = 1
	else
		nRectIndex = nRectIndex + 1
	end
	return objRet
end


function ccc3(r , g , b)
	if objColor[nColorIndex] then
		objColor[nColorIndex].r = r
		objColor[nColorIndex].g = g
		objColor[nColorIndex].b = b
	else
		objColor[nColorIndex] = ccColor3B();
		objColor[nColorIndex].r = r
		objColor[nColorIndex].g = g
		objColor[nColorIndex].b = b
	end

	local objRet = objColor[nColorIndex]
	if nColorIndex >= nMax then
		nColorIndex = 1
	else
		nColorIndex = nColorIndex + 1
	end
	return objRet
end





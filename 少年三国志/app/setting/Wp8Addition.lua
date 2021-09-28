--Wp8Addition.lua


local _WP8_ = {}

function _WP8_.CCRectContainXY( rect, ptx, pty )
	return ptx >= rect.origin.x and (ptx <= rect.origin.x + rect.size.width) and
			pty >= rect.origin.y and (pty <= rect.origin.y + rect.size.height)
end

function _WP8_.CCRectContainPt( rect, pt)
	return _WP8_.CCRectContainXY(rect, pt.x, pt.y)
end

function _WP8_.drawPolygon( drawNode, ptArr, count, fillClr, width, borderClr )
	if device.platform == "wp8" or device.platform == "winrt" then 
		FuncHelperUtil:drawPolygon(drawNode, ptArr, fillClr, width, borderClr)
	else
		if drawNode then 
			drawNode:drawPolygon(ptArr:fetchPoints(), count, fillClr, width, borderClr )
		end
	end
end

return _WP8_
local  RedPoints = {}
--local sub_top,sub_bottom = 1,2
RedPoints[1] = {}
RedPoints[2] = {}
RedPoints[9] = {}

function RedPoints:insertRedPoint(c_type,id)
	local subid = id or 1
	if c_type then
		--dump(RedPoints,"2333333333333333333")
		RedPoints[subid][c_type] = true
		if G_MAINSCENE and G_MAINSCENE.refreshRedPoints then
			G_MAINSCENE:refreshRedPoints(subid)
		end
	end
end

function RedPoints:removeRedPoint(c_type,id)
	local subid = id or 1
	if c_type then
		RedPoints[subid][c_type] = nil
		if G_MAINSCENE and G_MAINSCENE.refreshRedPoints then
			G_MAINSCENE:refreshRedPoints(subid)
		end
	end
end

function RedPoints:isHasRedPoint(id)
	local subid = id or 1
	return tablenums(RedPoints[subid]) > 0 
end

function RedPoints:isHasSubRedPoint(c_type,id)
	local subid = id or 1
	return RedPoints[subid][c_type]
end


return RedPoints
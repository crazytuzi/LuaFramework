


local function GetNaviFlag(api,check_end)
	local points = {'20','12','17','18','19'}
	local walls = {'空气墙5','空气墙2','空气墙3'}
	local index = 2
	for i,v in ipairs(walls) do
		local isenable = api.Scene.IsDecorationEnable(v)
		if i == #walls and check_end and isenable then
			return nil
		end
		if isenable then
			break
		else
			index = index + 1
		end
	end
	return points[1],points[index]
end

function start(api,...)
	local step = api.Net.GetStep()
	if step then return end
	local check_end = false
	Helper.WaitCheckFunction(function ()
		local p1,p2 = GetNaviFlag(api,check_end)
		if not p1 then
			return true
		end
			
		check_end = p2 == '19'
		local fx,fy = api.Scene.GetFlagPositon(p1)
		local tx,ty = api.Scene.GetFlagPositon(p2)
		api.Scene.ShowNavi(fx,fy,tx,ty)	
	end)
	api.Wait()
	
end

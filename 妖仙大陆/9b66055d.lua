

function start(api,...)
	local ux,uy = api.Scene.GetActorPostion()
	
	local Camera = api.Camera
	Camera.SetDramaCamera(true)
	Camera.SetPosition(ux,uy)
	local x,y,z = Camera.GetEulerAngles()
	print(x,y,z)
	api.Sleep(2)
	Camera.MoveToEulerAngles(x+40,y,z,7)
	api.Sleep(2)
end

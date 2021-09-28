local keys = {"id","findTarget","findType","sceneId","desc"} 
local cfg = {
	[1]={1,"6.0,0.1,14.2",0,1002,"讨伐"},
	[2]={2,"12.9,0.1,15.7",0,1002,"入侵"}
}
local data = {}
function cfg:Get(key)
	if data[key] then return data[key] end
	local t = {}
	for i, v in ipairs(cfg[key]) do
		t[keys[i]]=v
	end
	data[key]=t
	return t
end
return cfg
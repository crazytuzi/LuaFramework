MReloadUtil = {}

function MReloadUtil:Reload()

os.execute("/Users/songjianbang/bushu.sh");

for k,v in pairs(package.loaded) do
	if MReloadUtil.NeedToReload(k) then
		print(k)
		package.loaded[k] = nil
		require(k)
	end
end

print("reload finished!");

end

function MReloadUtil.NeedToReload(name)
	local need = false
	local needtoload = {
						"ui", 
						}
	for k,v in pairs(needtoload) do
		if string.find(name, v) then
			need = true
		end
	end

	return need
end

return MReloadUtil;

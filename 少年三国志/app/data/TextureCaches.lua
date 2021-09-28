--TextureCaches.lua


local TextureCaches = {}


TextureCaches.cache_texture_png = {
	[1] = "ui/common/common_1.png",
	[2] = "ui/dungeon/map_1.png",
	[3] = "ui/dungeon/map_2.png",
	[4] = "ui/dungeon/map_3.png",
	[5] = "ui/dungeon/map_4.png",
	[6] = "ui/background/back_mainbt.png",
	[7] = "ui/background/back_zrbt.png",
	[8] = "ui/background/bg_common.png",
	--[2] = "ui/text/txt.png",
	--[3] = "ui/text/txt_big_btn.png",
	--[4] = "ui/text/txt_small_btn.png",
	--[5] = "ui/text/txt_title.png",
}


function TextureCaches.loadCacheTextures( )
	for key, value in pairs(TextureCaches.cache_texture_png) do 
		TextureManger:getInstance():cacheTextureWithImage(value)
	end

	
end

function TextureCaches.unloadCacheTextures( )
	for key, value in pairs(TextureCaches.cache_texture_png) do 
		TextureManger:getInstance():clearCacheWithImage(value)
	end
end

return TextureCaches

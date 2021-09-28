--ResourceHelper.lua


ResourceHelper = {}

function ResourceHelper.clearUnusedTextures(  )
	TextureManger:getInstance():releaseUnusedTexture( false )
end

function ResourceHelper.showTextureReleaseLog(  )
	TextureManger:getInstance():showTextureLog(true)
end

function ResourceHelper.hideTextureReleaseLog(  )
	TextureManger:getInstance():showTextureLog(false)
end


function ResourceHelper.showTextureWatcher(  )
	TextureManger:getInstance():showTextureWatcher(true)
end

function ResourceHelper.hideTextureWatcher(  )
	TextureManger:getInstance():showTextureWatcher(false)
end

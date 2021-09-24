local FilesUtil=classGc(function(self)end)

function FilesUtil.check( self, _szPath )
    return gc.FileStream:existsFromResourcePath( _szPath )
end

function FilesUtil.pathExists( self, _szPath )
    local isExists = gc.FileStream:existsFromResourcePath( _szPath )
    if isExists == true then
        return true
    end
    self:WarningMessage( _szPath )
    return false
end

function FilesUtil.WarningMessage( self, _szPath )
    local warningTitle="Error Path"
    --CCMessageBox( _szPath, warningTitle )
    gcprint(_szPath.."&"..warningTitle)
    error(_szPath..warningTitle)
end

return FilesUtil
TFClientUpdate = TFClientUpdate:GetClientUpdate()

function TFClientUpdate:initConfig()
    if TFClientResourceUpdate then
        local newUpdateFun =  TFClientResourceUpdate:GetClientResourceUpdate()

        newUpdateFun:SetUpdateLastBinFile("/../Library/lastfile.bin")
        newUpdateFun:SetUpdateLastestFile("check.xml")
        newUpdateFun:SetUpdateDefaultVersion("2.0.0")
        return
    end
    
	TFClientUpdate:SetUpdateLastBinFile("/../Library/lastfile.bin")
    TFClientUpdate:SetUpdateLastestFile("version.xml")
    TFClientUpdate:SetUpdateEditionPath("edition/")
    TFClientUpdate:SetUpateVersionFileType(".xml")
    TFClientUpdate:SetUpdateDefaultVersion("2.0.0")

end

TFClientUpdate:initConfig()
return  TFClientUpdate
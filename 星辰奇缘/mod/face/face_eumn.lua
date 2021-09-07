FaceEumn = FaceEumn or {}

FaceEumn.FaceType = FaceEumn.FaceType or {
    Small = 1,      -- 小表情
    Big = 2,        -- 大表情
}

FaceEumn.GetBigPath = FaceEumn.GetBigPath or function(faceId)
    if faceId < 225 then
        return AssetConfig.bigface1
    else
        return ""
    end
end

local M = {}

local UnityMaterial = typeof(UnityEngine.Material)

function M.init()
    M["role_occlusion"] = AssetManager.LoadObjectLocal("misc/material", "RoleOcclusion", UnityMaterial)
end

return M


local M = {}

local UnityMaterial = typeof(UnityEngine.Material)

function M.init()
    M["role_occlusion"] = AssetManager.LoadObjectLocal("misc/material", "RoleOcclusion", UnityMaterial)
    M["role_transparent_occlusion"] = AssetManager.LoadObjectLocal("misc/material", "RoleTransparentOcclusion", UnityMaterial)
    M["role_ghost_1"] = AssetManager.LoadObjectLocal("misc/material", "RoleGhost_1", UnityMaterial)
    M["role_ghost_2"] = AssetManager.LoadObjectLocal("misc/material", "RoleGhost_2", UnityMaterial)
    M["role_ghost_3"] = AssetManager.LoadObjectLocal("misc/material", "RoleGhost_3", UnityMaterial)
    M["role_ghost_4"] = AssetManager.LoadObjectLocal("misc/material", "RoleGhost_4", UnityMaterial)
end

return M